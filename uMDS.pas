unit uMDS;
interface
uses classes, SysUtils, u3DTypes, uMD3, uMDM,uMDX, uCalc;

// http://remont.ifrance.com/model_et/files/mds_files.htm

const
  IDMDS = $5753444D; // 'MDSW' cardinal

  LOD_FRAMENR = 3812;    // rare kikker-houding..

type
  TMDSSurfaceBoneRefs = packed array of cardinal; // length = TMDMSurfaceHeader.Num_BoneRefs

  TMDSCollapseMap = packed array of cardinal; // length = TMDSSurfaceHeader.Num_Verts

  TMDSTriangle = packed record
    VertexIndexes: packed array[0..2] of cardinal;
  end;

  TMDSWeight = packed record
    BoneIndex: cardinal;
    Weight: Single;
    BoneSpace: TVector;
  end;

  TMDSVertex = packed record
    Normal: TVector;
    TexCoordU, TexCoordV: Single;
    Num_BoneWeights: cardinal;
    FixedParent: cardinal;  // Stay equidistant from this parent
    FixedDistance: Single;  // Fixed distance from parent
    Weights: packed array of TMDSWeight; // length = Num_BoneWeights
  end;

  TMDSSurfaceHeader = packed record
    Ident: cardinal;                // always 8
    SurfaceName: q3string;
    ShaderName: q3string;
    ShaderIndex: cardinal;
    LOD_minimum: cardinal;
    Ofs_SurfaceHeader: Integer;
    Num_Verts: cardinal;
    Ofs_Verts: cardinal;
    Num_Triangles: cardinal;
    Ofs_Triangles: cardinal;
    Ofs_CollapseMap: cardinal;
    Num_BoneRefs: cardinal;
    Ofs_BoneRefs: cardinal;
    Ofs_SurfaceDataEnd: cardinal;
  end;

  TMDSSurface = packed record
    Values: TMDSSurfaceHeader;
    Vertex: packed array of TMDSVertex;       // length = TMDSSurfaceHeader.Num_Verts
    Triangles: packed array of TMDSTriangle;  // length = TMDSSurfaceHeader.Num_Triangles
    CollapseMap: TMDSCollapseMap;
    BoneRefs: TMDSSurfaceBoneRefs;
  end;

  TMDSCompressedBoneFrame = packed record
    Angle_Pitch,                     // degrees = * 180.0/32767.0
    Angle_Yaw,
    Angle_Roll: SmallInt;
    unused: SmallInt;
    OffsetAngle_Pitch,
    OffsetAngle_Yaw: SmallInt; 
  end;

  TMDSFrame = packed record
    Min_Bounds: TVector;
    Max_Bounds: TVector;
    Local_Origin: TVector;
    Radius: single;
    ParentOffset: TVector;
    CompressedBoneFrame: packed array of TMDSCompressedBoneFrame; // length = TMDSHeader.Num_Bones
  end;

  TMDSTag = packed record
    Name: q3string;
    TorsoWeight: Single;
    BoneIndex: cardinal;
  end;

  TMDSBone = packed record
    Name: q3string;
    ParentIndex: Integer;
    TorsoWeight: Single;
    ParentDistance: Single;
    Flags: cardinal;
  end;

  TMDSHeader = packed record
    Ident: cardinal;                 // "MDSW"
    Version: cardinal;               // 4
    Name: q3string;
    LOD_scale: Single;
    LOD_bias: Single;
    Num_Frames: cardinal;
    Num_Bones: cardinal;
    Ofs_Frames: cardinal;
    Ofs_Bones: cardinal;
    TorsoParent: cardinal;
    Num_Surfaces: cardinal;
    Ofs_Surfaces: cardinal;
    Num_Tags: cardinal;
    Ofs_Tags: cardinal;
    Ofs_EOF: cardinal;
  end;


  TMDS = class(TObject)
  private
    Fopen: TFilestream;
    BonePos: array of TVector;
    BoneMat: array of TMatrix4x4;
    BoneMat_1: array of TMatrix4x4;
    function IsMDS : boolean;
  public
    Header: TMDSHeader;
    Surfaces: packed array of TMDSSurface;   // length = TMDSHeader.Num_Surfaces
    Frames: packed array of TMDSFrame;
    Bones: packed array of TMDSBone;
    Tags: packed array of TMDSTag;           // length = TMDSHeader.Num_Tags
    function LoadFromFile(Filename: string): boolean;
    procedure ConvertToMDMMDX(var MDM:TMDM; var MDX:TMDX);
  end;


var MDS : TMDS;


implementation

{ TMDS }

function TMDS.IsMDS: boolean;
begin
  Result := (Header.Ident = IDMDS);
end;

function TMDS.LoadFromFile(Filename: string): boolean;
var N, Size: cardinal;
    s,v,t,f: integer;
    FP: Int64;
begin
  Result := false;
  Fopen := TFileStream.Create(Filename, fmOpenRead);
  try
    try
      // Header
      N := Fopen.Read(Header, SizeOf(TMDSHeader));
      if N<>SizeOf(TMDSHeader) then Exit;
      Result := IsMDS;
      if not Result then Exit;
      // Surfaces laden
      FP := Header.Ofs_Surfaces;
      SetLength(Surfaces, Header.Num_Surfaces);
      for s:=0 to Header.Num_Surfaces-1 do begin
        Fopen.Position := FP;
        // surface header
        Size := SizeOf(TMDSSurfaceHeader);
        N := Fopen.Read(Surfaces[s].Values, Size);
        Result := (N=Size);
        if not Result then Exit;
        // surface vertex
        Fopen.Position := FP + Surfaces[s].Values.Ofs_Verts;
        SetLength(Surfaces[s].Vertex, Surfaces[s].Values.Num_Verts);
        for v:=0 to Surfaces[s].Values.Num_Verts-1 do begin
          Size := 32;  //5*single + 2*cardinal + single
          N := Fopen.Read(Surfaces[s].Vertex[v], Size);
          Result := (N=Size);
          if not Result then Exit;
          // vertex bone-weights
          SetLength(Surfaces[s].Vertex[v].Weights, Surfaces[s].Vertex[v].Num_BoneWeights);
          Size := Surfaces[s].Vertex[v].Num_BoneWeights * SizeOf(TMDSWeight);
          N := Fopen.Read(Surfaces[s].Vertex[v].Weights[0], Size);
          Result := (N=Size);
          if not Result then Exit;
        end;
        // surface triangles
        Fopen.Position := FP + Surfaces[s].Values.Ofs_Triangles;
        SetLength(Surfaces[s].Triangles, Surfaces[s].Values.Num_Triangles);
        Size := Surfaces[s].Values.Num_Triangles * SizeOf(TMDSTriangle);
        N := Fopen.Read(Surfaces[s].Triangles[0], Size);
        Result := (N=Size);
        if not Result then Exit;
        // CollapseMap
        Fopen.Position := FP + Surfaces[s].Values.Ofs_CollapseMap;
        SetLength(Surfaces[s].CollapseMap, Surfaces[s].Values.Num_Verts);
        Size := Surfaces[s].Values.Num_Verts * 4; //cardinal
        N := Fopen.Read(Surfaces[s].CollapseMap[0], Size);
        Result := (N=Size);
        if not Result then Exit;
        // BoneRefs
        Fopen.Position := FP + Surfaces[s].Values.Ofs_BoneRefs;
        SetLength(Surfaces[s].BoneRefs, Surfaces[s].Values.Num_BoneRefs);
        Size := Surfaces[s].Values.Num_BoneRefs * 4; //cardinal    //SizeOf(TMDMBoneRef);
        N := Fopen.Read(Surfaces[s].BoneRefs[0], Size);
        Result := (N=Size);
        if not Result then Exit;
        //
        FP := FP + Surfaces[s].Values.Ofs_SurfaceDataEnd;
      end;
      // Tags
      Fopen.Position := Header.Ofs_Tags;
      SetLength(Tags, Header.Num_Tags);
      Size := Header.Num_Tags * SizeOf(TMDSTag);
      N := Fopen.Read(Tags[0], Size);
      Result := (N=Size);
      if not Result then Exit;
      // Bones
      Fopen.Position := Header.Ofs_Bones;
      SetLength(Bones, Header.Num_Bones);
      Size := Header.Num_Bones * SizeOf(TMDSBone);
      N := Fopen.Read(Bones[0], Size);
      Result := (N=Size);
      if not Result then Exit;
      // Frames
      Fopen.Position := Header.Ofs_Frames;
      SetLength(Frames, Header.Num_Frames);
      for f:=0 to Header.Num_Frames-1 do begin
        Size := 3*4 + 3*4 + 3*4 + 4 + 3*4;
        N := Fopen.Read(Frames[f].Min_Bounds, Size);
        Result := (N=Size);
        if not Result then Exit;
        // compressed bones
        SetLength(Frames[f].CompressedBoneFrame, Header.Num_Bones);
        Size := Header.Num_Bones * SizeOf(TMDSCompressedBoneFrame);
        N := Fopen.Read(Frames[f].CompressedBoneFrame[0], Size);
        Result := (N=Size);
        if not Result then Exit;
      end;
    except
      //
    end;
  finally
    Fopen.Free;
  end;
end;


procedure TMDS.ConvertToMDMMDX(var MDM:TMDM; var MDX:TMDX);
var s,v,w,t,br,f,b,l,bp: cardinal;
    pidx: integer;
    list: array[0..255] of integer;
    M: TMatrix4x4;
    roll, pitch, yaw, tmp: Single;
    MDX2MDSbones: array[0..127] of integer;
    MDS2MDXbones: array[0..127] of integer;
    MDX_BoneCount: cardinal;
VV,d:TVector;
//--
  function MDS_BoneCount : integer;
  var b: integer;
  begin
    Result := 0;
    for b:=0 to MDS.Header.Num_Bones-1 do begin
      if MDS.Bones[b].Flags<>0 then Continue;  // is een tag
      Inc(Result);
    end;
  end;
//--
  function MDS_TagCount : integer;
  var b: integer;
  begin
    Result := 0;
    for b:=0 to MDS.Header.Num_Bones-1 do begin
      if MDS.Bones[b].Flags=0 then Continue;  // is een bone
      Inc(Result);
    end;
  end;
//--
  function convertBones : integer;
  var b: integer;
  begin
    Result := 0; // aantal echte bones, (dus geen tags erbij)
    for b:=0 to MDS.Header.Num_Bones-1 do begin
      MDS2MDXbones[b] := -1;
      if MDS.Bones[b].Flags<>0 then Continue;
      MDS2MDXbones[b] := Result;
      MDX2MDSbones[Result] := b;
      Inc(Result);
{      MDS2MDXbones[b] := Result;
      MDX2MDSbones[Result] := b;
      if MDS.Bones[b].Flags=0 then Inc(Result); // is een bone}
    end;
  end;
//--
  function findMDSBoneForTag(Index:integer) : integer;
  var b: integer;
  begin
    Result := -1;
    for b:=0 to MDS.Header.Num_Bones-1 do begin
      if MDS.Bones[b].Flags=0 then Inc(Result); // is een bone
      if string(MDS.Bones[b].Name) = string(MDS.Tags[Index].Name) then begin
        Result := b;
        Exit;
      end;
    end;
  end;
//--
begin
  // MDM/MDX legen
  MDM.Clear;
  MDX.Clear;

  MDX_BoneCount := convertBones; // tags uit MDS filteren, en indexes omzetten

  //--- MDX --------------------------------------------------------------------
  // Header
  MDX.Header.Ident       := IDMDX;
  MDX.Header.Version     := 2;
  MDX.Header.Name        := MDS.Header.Name;        //'output/animations/human/base/body.mdx'
  MDX.Header.Num_Frames  := MDS.Header.Num_Frames;
  MDX.Header.Num_Bones   := MDX_BoneCount {MDS.Header.Num_Bones};
  MDX.Header.TorsoParent := MDS.Header.TorsoParent;
  // Frames
  SetLength(MDX.Frames, MDS.Header.Num_Frames);
  for f:=0 to MDX.Header.Num_Frames-1 do begin
    MDX.Frames[f].Min_Bounds   := MDS.Frames[f].Min_Bounds;
    MDX.Frames[f].Max_Bounds   := MDS.Frames[f].Max_Bounds;
    MDX.Frames[f].Local_Origin := MDS.Frames[f].Local_Origin;
    MDX.Frames[f].Radius       := MDS.Frames[f].Radius;
    MDX.Frames[f].ParentOffset := MDS.Frames[f].ParentOffset;
    SetLength(MDX.Frames[f].CompressedBoneFrame, MDX_BoneCount {MDS.Header.Num_Bones});
    for b:=0 to MDX.Header.Num_Bones-1 do begin
{      MDX.Frames[f].CompressedBoneFrame[b].Angle_Pitch       := MDS.Frames[f].CompressedBoneFrame[b].Angle_Pitch;
      MDX.Frames[f].CompressedBoneFrame[b].Angle_Yaw         := MDS.Frames[f].CompressedBoneFrame[b].Angle_Yaw;
      MDX.Frames[f].CompressedBoneFrame[b].Angle_Roll        := MDS.Frames[f].CompressedBoneFrame[b].Angle_Roll;
      MDX.Frames[f].CompressedBoneFrame[b].OffsetAngle_Pitch := MDS.Frames[f].CompressedBoneFrame[b].OffsetAngle_Pitch;
      MDX.Frames[f].CompressedBoneFrame[b].OffsetAngle_Yaw   := MDS.Frames[f].CompressedBoneFrame[b].OffsetAngle_Yaw;}
      MDX.Frames[f].CompressedBoneFrame[b].Angle_Pitch       := MDS.Frames[f].CompressedBoneFrame[MDX2MDSbones[b]].Angle_Pitch;
      MDX.Frames[f].CompressedBoneFrame[b].Angle_Yaw         := MDS.Frames[f].CompressedBoneFrame[MDX2MDSbones[b]].Angle_Yaw;
      MDX.Frames[f].CompressedBoneFrame[b].Angle_Roll        := MDS.Frames[f].CompressedBoneFrame[MDX2MDSbones[b]].Angle_Roll;
      MDX.Frames[f].CompressedBoneFrame[b].OffsetAngle_Pitch := MDS.Frames[f].CompressedBoneFrame[MDX2MDSbones[b]].OffsetAngle_Pitch;
      MDX.Frames[f].CompressedBoneFrame[b].OffsetAngle_Yaw   := MDS.Frames[f].CompressedBoneFrame[MDX2MDSbones[b]].OffsetAngle_Yaw;
    end;
  end;
  // Bones
  SetLength(MDX.Bones, MDX_BoneCount {MDS.Header.Num_Bones});
  for b:=0 to MDX.Header.Num_Bones-1 do begin
    br := MDX2MDSbones[b];
{    MDX.Bones[b].Name           := MDS.Bones[b].Name;
    MDX.Bones[b].ParentIndex    := MDS.Bones[b].ParentIndex;
    MDX.Bones[b].TorsoWeight    := MDS.Bones[b].TorsoWeight;
    MDX.Bones[b].ParentDistance := MDS.Bones[b].ParentDistance;
    MDX.Bones[b].Flags          := MDS.Bones[b].Flags;}
    MDX.Bones[b].Name           := MDS.Bones[br].Name;
    MDX.Bones[b].ParentIndex    := MDS.Bones[br].ParentIndex;
    if MDX.Bones[b].ParentIndex<>-1 then MDX.Bones[b].ParentIndex := MDS2MDXbones[MDX.Bones[b].ParentIndex];
    MDX.Bones[b].TorsoWeight    := MDS.Bones[br].TorsoWeight;
    MDX.Bones[b].ParentDistance := MDS.Bones[br].ParentDistance;
    MDX.Bones[b].Flags          := MDS.Bones[br].Flags;
  end;

  //--- MDM --------------------------------------------------------------------
  // Header
  MDM.Header.Ident        := IDMDM;
  MDM.Header.Version      := 3;
  MDM.Header.Name         := MDS.Header.Name;
  MDM.Header.LOD_bias     := MDS.Header.LOD_bias;
  MDM.Header.LOD_scale    := MDS.Header.LOD_scale;
  MDM.Header.Num_Surfaces := MDS.Header.Num_Surfaces;
  MDM.Header.Num_Tags     := MDS_TagCount {MDS.Header.Num_Tags};
  // Surfaces
  SetLength(MDM.Surfaces, MDM.Header.Num_Surfaces);
  for s:=0 to MDM.Header.Num_Surfaces-1 do begin
    // surface header
    MDM.Surfaces[s].Values.Ident         := 9;
    MDM.Surfaces[s].Values.SurfaceName   := MDS.Surfaces[s].Values.SurfaceName;
    MDM.Surfaces[s].Values.ShaderName    := MDS.Surfaces[s].Values.ShaderName;
    MDM.Surfaces[s].Values.LOD_minimum   := MDS.Surfaces[s].Values.LOD_minimum;
    MDM.Surfaces[s].Values.Num_Verts     := MDS.Surfaces[s].Values.Num_Verts;
    MDM.Surfaces[s].Values.Num_Triangles := MDS.Surfaces[s].Values.Num_Triangles;
    MDM.Surfaces[s].Values.Num_BoneRefs  := MDS.Surfaces[s].Values.Num_BoneRefs;
    // vertex
    SetLength(MDM.Surfaces[s].Vertex, MDM.Surfaces[s].Values.Num_Verts);
    for v:=0 to MDM.Surfaces[s].Values.Num_Verts-1 do begin
      MDM.Surfaces[s].Vertex[v].Normal.X        := MDS.Surfaces[s].Vertex[v].Normal.X;
      MDM.Surfaces[s].Vertex[v].Normal.Y        := MDS.Surfaces[s].Vertex[v].Normal.Y;
      MDM.Surfaces[s].Vertex[v].Normal.Z        := MDS.Surfaces[s].Vertex[v].Normal.Z;
      MDM.Surfaces[s].Vertex[v].TexCoordU       := MDS.Surfaces[s].Vertex[v].TexCoordU;
      MDM.Surfaces[s].Vertex[v].TexCoordV       := MDS.Surfaces[s].Vertex[v].TexCoordV;
      MDM.Surfaces[s].Vertex[v].Num_BoneWeights := MDS.Surfaces[s].Vertex[v].Num_BoneWeights;
      SetLength(MDM.Surfaces[s].Vertex[v].Weights, MDM.Surfaces[s].Vertex[v].Num_BoneWeights);
      for w:=0 to MDM.Surfaces[s].Vertex[v].Num_BoneWeights-1 do begin
{        MDM.Surfaces[s].Vertex[v].Weights[w].BoneIndex := MDS.Surfaces[s].Vertex[v].Weights[w].BoneIndex;}
        MDM.Surfaces[s].Vertex[v].Weights[w].BoneIndex := MDS2MDXbones[MDS.Surfaces[s].Vertex[v].Weights[w].BoneIndex];
        MDM.Surfaces[s].Vertex[v].Weights[w].Weight    := MDS.Surfaces[s].Vertex[v].Weights[w].Weight;
        MDM.Surfaces[s].Vertex[v].Weights[w].BoneSpace := MDS.Surfaces[s].Vertex[v].Weights[w].BoneSpace;
      end;
    end;
    // Triangles
    SetLength(MDM.Surfaces[s].Triangles, MDM.Surfaces[s].Values.Num_Triangles);
    for t:=0 to MDM.Surfaces[s].Values.Num_Triangles-1 do begin
      MDM.Surfaces[s].Triangles[t][0] := MDS.Surfaces[s].Triangles[t].VertexIndexes[0];
      MDM.Surfaces[s].Triangles[t][1] := MDS.Surfaces[s].Triangles[t].VertexIndexes[1];
      MDM.Surfaces[s].Triangles[t][2] := MDS.Surfaces[s].Triangles[t].VertexIndexes[2];
    end;
    // CollapseMap
    SetLength(MDM.Surfaces[s].CollapseMap, MDM.Surfaces[s].Values.Num_Verts);
    for v:=0 to MDM.Surfaces[s].Values.Num_Verts-1 do
      MDM.Surfaces[s].CollapseMap[v] := MDS.Surfaces[s].CollapseMap[v];
    // BoneRefs
    SetLength(MDM.Surfaces[s].BoneRefs, MDM.Surfaces[s].Values.Num_BoneRefs);
    for br:=0 to MDM.Surfaces[s].Values.Num_BoneRefs-1 do
{      MDM.Surfaces[s].BoneRefs[br] := MDS.Surfaces[s].BoneRefs[br];}
      MDM.Surfaces[s].BoneRefs[br] := MDS2MDXbones[MDS.Surfaces[s].BoneRefs[br]];
  end;

  // Tags
  // ..eerst alle bones posities en rotatie-matrices bepalen
  SetLength(BonePos, MDS.Header.Num_Bones);
  SetLength(BoneMat, MDS.Header.Num_Bones);
  SetLength(BoneMat_1, MDS.Header.Num_Bones);
  if LOD_FRAMENR>=MDS.Header.Num_Frames-1 then f:=0 else f:=LOD_FRAMENR;
  for b:=0 to MDS.Header.Num_Bones-1 do begin
    if MDS.Bones[b].Flags<>0 then Continue;  // is een tag
    pidx := MDS.Bones[b].ParentIndex;
    if pidx = -1 then
      BonePos[b] := NullVector
    else begin
      tmp := MDS.Bones[b].ParentDistance;
      pitch := -MDS.Frames[f].CompressedBoneFrame[b].OffsetAngle_Pitch * MDX_DEG;
      yaw := MDS.Frames[f].CompressedBoneFrame[b].OffsetAngle_Yaw * MDX_DEG;
      M := MultiplyMatrix(YRotationMatrix(pitch), ZRotationMatrix(yaw));
      d := TransformVector(Vector(tmp,0,0), M);
      BonePos[b] := AddVector(BonePos[pidx], d);
    end;
    // rotatie matrix
    roll := MDS.Frames[f].CompressedBoneFrame[b].Angle_Roll * MDX_DEG;
    pitch := -MDS.Frames[f].CompressedBoneFrame[b].Angle_Pitch * MDX_DEG;
    yaw := MDS.Frames[f].CompressedBoneFrame[b].Angle_Yaw * MDX_DEG;
    BoneMat[b] := MultiplyMatrix(MultiplyMatrix(XRotationMatrix(roll), YRotationMatrix(pitch)), ZRotationMatrix(yaw));
    // inverse rot.mat.
    BoneMat_1[b] := BoneMat[b];
    InverseMatrix(BoneMat_1[b]); //TransposeMatrix is genoeg voor een rotatie-matrix
  end;

{for b:=0 to MDS.Header.Num_Bones-1 do begin
  BonePos[b].Z := -BonePos[b].Z;
end;}

  SetLength(MDM.Tags, MDM.Header.Num_Tags);
  for t:=0 to MDM.Header.Num_Tags-1 do begin
{    for b:=0 to MDS.Header.Num_Bones-1 do begin
      // is dit een tag?  // Bit 0 is set if bone is a tag
      if (MDX.Bones[b].Flags and $00000001)=0 then Continue;}
      MDM.Tags[t].Name := MDS.Tags[t].Name;
      br := MDS.Tags[t].BoneIndex;
      bp := MDS.Bones[br].ParentIndex;
//!br := MDS.Bones[MDS.Tags[t].BoneIndex].ParentIndex;
      b := MDS2MDXbones[br];
      MDM.Tags[t].AttachToBone := MDS2MDXbones[bp];

      // bonelist opstellen: vanaf parent -> children
      l := 0;
      pidx := bp{br};
      repeat
        pidx := MDS.Bones[pidx].ParentIndex;
        list[l] := MDS2MDXbones[pidx];
        Inc(l);
      until pidx = -1;
      MDM.Tags[t].Num_Bones := l;
      SetLength(MDM.Tags[t].BoneList, l);
      for v:=0 to l-1 do MDM.Tags[t].BoneList[v] := list[l-1-v];
//BonePos[br].Z := -BonePos[br].Z;

//br := MDS.Bones[br].ParentIndex;


      // tag origin
// result - bonepos
// * bonemat
// .y := -.y
//      VV := BonePos[br]; VV.Z:=-VV.Z; //Vector(-MDS.Bones[br].ParentDistance,0,0); //resultaat
//VV := BonePos[br];  VV.X := VV.X - MDS.Bones[br].ParentDistance;
      MDM.Tags[t].Offset := TransformVector(SubVector(NullVector,BonePos[br]), BoneMat[br]);
{M := IdentityMatrix4x4;
M[0,3] := -BonePos[br].X;
M[1,3] := -BonePos[br].Y;
M[2,3] := -BonePos[br].Z;
M := MultiplyMatrix(M, BoneMat[br]);
VV := Vector(MDS.Bones[br].ParentDistance,0,0);
MDM.Tags[t].Offset := TransformVector(VV,M);}
{      MDM.Tags[t].Offset.Y := -MDM.Tags[t].Offset.Y;}
//      MDM.Tags[t].Offset.X := MDM.Tags[t].Offset.X - MDS.Bones[br].ParentDistance;
//MDM.Tags[t].Offset := BonePos[br];
//MDM.Tags[t].Offset.Z := -MDM.Tags[t].Offset.Z;
{tmp:=MDM.Tags[t].Offset.Z;
      MDM.Tags[t].Offset.Z := -MDM.Tags[t].Offset.Y;
      MDM.Tags[t].Offset.Y := -tmp;}
//MDM.Tags[t].Offset.Y := -MDM.Tags[t].Offset.Y;
//MDM.Tags[t].Offset.Z := -MDM.Tags[t].Offset.Z;
(*
      pitch := -MDS.Frames[0].CompressedBoneFrame[br].OffsetAngle_Pitch * MDX_DEG;
      yaw := MDS.Frames[0].CompressedBoneFrame[br].OffsetAngle_Yaw * MDX_DEG;
      M := MultiplyMatrix(YRotationMatrix(pitch), ZRotationMatrix(yaw));
//M := MultiplyMatrix(M, XRotationMatrix(-90));
//InverseMatrix(M);
      MDM.Tags[t].Offset := TransformVector(Vector(MDS.Bones[br].ParentDistance,0,0), M);
//MDM.Tags[t].Offset.Y := -MDM.Tags[t].Offset.Y;
*)
      // tag axis
      roll := MDS.Frames[LOD_FRAMENR].CompressedBoneFrame[br].Angle_Roll * MDX_DEG;
      pitch := -MDS.Frames[LOD_FRAMENR].CompressedBoneFrame[br].Angle_Pitch * MDX_DEG;
      yaw := MDS.Frames[LOD_FRAMENR].CompressedBoneFrame[br].Angle_Yaw * MDX_DEG;
      M := MultiplyMatrix(MultiplyMatrix(XRotationMatrix(roll), YRotationMatrix(pitch)), ZRotationMatrix(yaw));
//M := MultiplyMatrix(M, XRotationMatrix(-90));
//InverseMatrix(M);
//V := TransformVector(bs, BoneMat_1[bi]);
//M := BoneMat_1[br];
//InverseMatrix(M);
      MDM.Tags[t].Axis[0] := TransformVector(XAxisVector, M);
      MDM.Tags[t].Axis[1] := TransformVector(YAxisVector, M);
      MDM.Tags[t].Axis[2] := TransformVector(ZAxisVector, M);
{MDM.Tags[t].Axis[0].Y := -MDM.Tags[t].Axis[0].Y;
MDM.Tags[t].Axis[1].Y := -MDM.Tags[t].Axis[1].Y;
MDM.Tags[t].Axis[2].Y := -MDM.Tags[t].Axis[2].Y;}
//MDM.Tags[t].Axis[1] := InverseVector(MDM.Tags[t].Axis[1]);
//!Inc(t);
//!    end;
  end;
end;



initialization
  MDS := TMDS.Create;
finalization
  MDS.Free;

end.
