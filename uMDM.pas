unit uMDM;
interface
uses uMD3, uMDX, classes, SysUtils, u3DTypes, uCalc, dialogs;

// http://remont.ifrance.com/model_et/files/mdm&mdx.htm

// quick LOD fixes voor Berzerk's model (LOD/collapsemap opgeven die 100% LOD blijft houden)
{$UNDEF BerzerkrIschbinzFix}
// een collapsemap uitrekenen
{$UNDEF LOD}

const
  IDMDM = $574D444D; // 'MDMW' cardinal

  LOD_PERCENTAGE = 50.0;
  LOD_FRAMENR = 4274;    // rare kikker-houding..

  MDM_MAX_VERTEX = 6000;
  MDM_MAX_SURFACES = 32;
  MDM_MAX_TRIANGLES = 8192;
  MDM_MAX_BONES = 128;
  MDM_MAX_TAGS = 128;

type
  TMDMTag = packed record
    Name: q3string;
    Axis: packed array[0..2] of TVector;     // Coordinates of the three vetices which form the tag's figure. (rot-matrix??)
    AttachToBone: cardinal;
    Offset: TVector;                         // 3D vector which determines the direction of the tag triangle from the bone.
    Num_Bones: cardinal;                     // number of related bones in the list
    Ofs_BoneList: cardinal;                  // Offset to the Index list. it should be 0x80.
    Ofs_TagDataEnd: cardinal;                // Offset to the end of this tag data.
    BoneList: packed array of cardinal;      // length = TMDMTag.Num_Bones
  end;

  TMDMSurfaceBoneRefs = packed array of cardinal; // length = TMDMSurfaceHeader.Num_BoneRefs

  TMDMCollapseMap = packed array of cardinal; // length = TMDMSurfaceHeader.Num_Verts

  TMDMTriangle = {packed record
    VertexIndexes:} packed array[0..2] of cardinal;
  {end;}

  TMDMWeight = packed record
    BoneIndex: cardinal;
    Weight: Single;
    BoneSpace: TVector;
  end;

  TMDMVertex = packed record
    Normal: TVector;
    TexCoordU, TexCoordV: Single;
    Num_BoneWeights: cardinal;
    Weights: packed array of TMDMWeight; // length = Num_BoneWeights
  end;

  TMDMSurfaceHeader = packed record
    Ident: cardinal;                // Surface data identification, should be 9.
    SurfaceName: q3string;
    ShaderName: q3string;
    ShaderIndex: Integer;          // intern gebruik
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

  TMDMSurface = packed record
    Values: TMDMSurfaceHeader;
    Vertex: packed array of TMDMVertex;       // length = TMDMSurfaceHeader.Num_Verts
    Triangles: packed array of TMDMTriangle;  // length = TMDMSurfaceHeader.Num_Triangles
    CollapseMap: TMDMCollapseMap;
    BoneRefs: TMDMSurfaceBoneRefs;
  end;

  TMDMHeader = packed record
    Ident: cardinal;                 // "MDMW"
    Version: cardinal;               // should be 3
    Name: q3string;
    LOD_bias: Single;
    LOD_scale: Single;
    Num_Surfaces: cardinal;
    Ofs_Surfaces: cardinal;
    Num_Tags: cardinal;
    Ofs_Tags: cardinal;
    Ofs_EOF: cardinal;
  end;

  // tbv. interne LOD afhandeling
  TLODrec = record
    Max: integer;
    Value: integer;
  end;

  TMDM = class(TObject)
  private
    Fopen, Fsave: TFilestream;
    function IsMDM : boolean;
    function Size_Header : cardinal;
    function Size_SurfaceHeader : cardinal;
    function Size_SurfaceVertex(SurfaceIndex: cardinal) : cardinal;
    function Size_SurfaceTriangles(SurfaceIndex: cardinal) : cardinal;
    function Size_SurfaceCollapseMap(SurfaceIndex: cardinal) : cardinal;
    function Size_SurfaceBoneRefs(SurfaceIndex: cardinal) : cardinal;
    function Size_Surface(SurfaceIndex: cardinal) : cardinal;
    function Size_Surfaces : cardinal;
    function Size_Tags : cardinal;
  public
    // tbv. uitrekenen vertexpos, bonepos & bonemat
    BonePos: array of TVector;
    BoneMat: array of TMatrix4x4;
    BoneMat_1: array of TMatrix4x4;
    VertexPos: array of TVector;
    VertexNormal: array of TVector;
    TagOrigin: array of TVector;
    TagAxis: array of array[0..2] of TVector;
    LOD_minimums: array[0..31] of TLODrec;  //max_surfaces
    //
    Header: TMDMHeader;
    Surfaces: packed array of TMDMSurface;   // length = TMDMHeader.Num_Surfaces
    Tags: packed array of TMDMTag;           // length = TMDMHeader.Num_Tags
    //
    function LoadFromFile(Filename: string): boolean;
    function SaveToFile(Filename: string) : boolean;
    function LoadTagsFromFile(Filename: string): boolean;
    //
    procedure CalcModel(const MDX:TMDX; const FrameNr:cardinal; const SurfaceNr:cardinal);
    procedure CalcSurfaceNormals(const MDX:TMDX; const FrameNr:cardinal; const SurfaceNr:cardinal);
    procedure SmoothSurface(const MDX:TMDX; const SurfaceNr:integer);
    procedure Clear;
    function GetTotalVertexCount : cardinal;
    function GetTotalTrianglesCount : cardinal;
    function HasLOD : boolean;
    procedure ChangeShader(Index: Integer; Name: string);
  end;


var MDM : TMDM;


implementation
uses uCollapseMap, Math;


function TMDM.IsMDM: boolean;
begin
  Result := (Header.Ident = IDMDM);
end;


procedure TMDM.Clear;
var i,j: integer;
begin
  for i:=0 to Header.Num_Surfaces-1 do begin
    if Length(Surfaces)<=i then Continue;
    for j:=0 to Surfaces[i].Values.Num_Verts-1 do SetLength(Surfaces[i].Vertex[j].Weights, 0);
    SetLength(Surfaces[i].Triangles, 0);
    SetLength(Surfaces[i].CollapseMap, 0);
    SetLength(Surfaces[i].BoneRefs, 0);
  end;
  Header.Num_Surfaces := 0;
  for i:=0 to Header.Num_Tags-1 do begin
    if Length(Tags)<=i then Continue;
    SetLength(Tags[i].BoneList, 0);
  end;
  Header.Num_Tags := 0;
end;


function TMDM.LoadFromFile(Filename: string): boolean;
var N, Size: cardinal;
    s,v,t: integer;
    FP: Int64;
    tmp: TVector;
    msg: string;
begin
  Result := false;
  Fopen := TFileStream.Create(Filename, fmOpenRead);
  try
    try
      // Header
      N := Fopen.Read(Header, SizeOf(TMDMHeader));
      if N<>SizeOf(TMDMHeader) then Exit;
      Result := IsMDM;
      if not Result then Exit;
      // check limits
      if Header.Num_Surfaces > MDM_MAX_SURFACES then begin
        msg := 'MAX_SURFACES limit exceeded: '+ IntToStr(Header.Num_Surfaces) +' > '+ IntToStr(MDM_MAX_SURFACES) +#13#10+ 'Continue loading?..';
        if MessageDlg(msg, mtConfirmation, [mbYes, mbNo], 0) = 7{mrNo} then begin
          Clear;
          Result := false;
          Exit;
        end;
      end;
      if Header.Num_Tags > MDM_MAX_TAGS then begin
        msg := 'MAX_TAGS limit exceeded: '+ IntToStr(Header.Num_Tags) +' > '+ IntToStr(MDM_MAX_TAGS) +#13#10+ 'Continue loading?..';
        if MessageDlg(msg, mtConfirmation, [mbYes, mbNo], 0) = 7{mrNo} then begin
          Clear;
          Result := false;
          Exit;
        end;
      end;
      //
{$IFDEF BerzerkrIschbinzFix}
        Header.LOD_bias := 1;
        Header.LOD_scale := 0;
{$ENDIF}
{$IFDEF LOD}
        Header.LOD_bias := 1;
        Header.LOD_scale := 0;
{$ENDIF}
      // Surfaces laden
      FP := Header.Ofs_Surfaces;
      SetLength(Surfaces, Header.Num_Surfaces);
//!      SetLength(LOD_minimums, Header.Num_Surfaces); //interne LOD afhandeling
      for s:=0 to Header.Num_Surfaces-1 do begin
        Fopen.Position := FP;
        // surface header
        Size := SizeOf(TMDMSurfaceHeader);
        N := Fopen.Read(Surfaces[s].Values, Size);
        Result := (N=Size);
        if not Result then Exit;
        // check limits
        if Surfaces[s].Values.Num_Verts > MDM_MAX_VERTEX then begin
          msg := 'MAX_VERTICES limit exceeded: '+ IntToStr(Surfaces[s].Values.Num_Verts) +' > '+ IntToStr(MDM_MAX_VERTEX) +#13#10+ 'Continue loading?..';
          if MessageDlg(msg, mtConfirmation, [mbYes, mbNo], 0) = 7{mrNo} then begin
            Clear;
            Result := false;
            Exit;
          end;
        end;
        if Surfaces[s].Values.Num_Triangles > MDM_MAX_TRIANGLES then begin
          msg := 'MAX_TRIANGLES limit exceeded: '+ IntToStr(Surfaces[s].Values.Num_Triangles) +' > '+ IntToStr(MDM_MAX_TRIANGLES) +#13#10+ 'Continue loading?..';
          if MessageDlg(msg, mtConfirmation, [mbYes, mbNo], 0) = 7{mrNo} then begin
            Clear;
            Result := false;
            Exit;
          end;
        end;
        // interne LOD afhandeling
        LOD_minimums[s].Max := Surfaces[s].Values.Num_Verts;
        LOD_minimums[s].Value := LOD_minimums[s].Max;
{$IFDEF BerzerkrIschbinzFix}
          Surfaces[s].Values.LOD_minimum := Surfaces[s].Values.Num_Verts;
{$ENDIF}
{$IFDEF LOD}
          Surfaces[s].Values.LOD_minimum := Floor(Surfaces[s].Values.Num_Verts /100.0 *LOD_PERCENTAGE);
{$ENDIF}
        // surface vertex
        Fopen.Position := FP + Surfaces[s].Values.Ofs_Verts;
        SetLength(Surfaces[s].Vertex, Surfaces[s].Values.Num_Verts);
        for v:=0 to Surfaces[s].Values.Num_Verts-1 do begin
          Size := 24;  //5*single + cardinal
          N := Fopen.Read(Surfaces[s].Vertex[v], Size);
          Result := (N=Size);
          if not Result then Exit;
          // vertex bone-weights
          SetLength(Surfaces[s].Vertex[v].Weights, Surfaces[s].Vertex[v].Num_BoneWeights);
          Size := Surfaces[s].Vertex[v].Num_BoneWeights * SizeOf(TMDMWeight);
          if Size>0 then begin
            N := Fopen.Read(Surfaces[s].Vertex[v].Weights[0], Size);
            Result := (N=Size);
            if not Result then Exit;
          end;
        end;
        // surface triangles
        Fopen.Position := FP + Surfaces[s].Values.Ofs_Triangles;
        SetLength(Surfaces[s].Triangles, Surfaces[s].Values.Num_Triangles);
        Size := Surfaces[s].Values.Num_Triangles * SizeOf(TMDMTriangle);
        if Size>0 then begin
          N := Fopen.Read(Surfaces[s].Triangles[0], Size);
          Result := (N=Size);
          if not Result then Exit;
        end;
        // CollapseMap
        Fopen.Position := FP + Surfaces[s].Values.Ofs_CollapseMap;
        SetLength(Surfaces[s].CollapseMap, Surfaces[s].Values.Num_Verts);
        Size := Surfaces[s].Values.Num_Verts * 4; //cardinal
        if Size>0 then begin
          N := Fopen.Read(Surfaces[s].CollapseMap[0], Size);
          Result := (N=Size);
          if not Result then Exit;
        end;
{$IFDEF BerzerkrIschbinzFix}
          //collapsemap orginele vertex-indexes gebruiken
          for v:=0 to Surfaces[s].Values.Num_Verts-1 do Surfaces[s].CollapseMap[v] := v;
{$ENDIF}
        // BoneRefs
        Fopen.Position := FP + Surfaces[s].Values.Ofs_BoneRefs;
        SetLength(Surfaces[s].BoneRefs, Surfaces[s].Values.Num_BoneRefs);
        Size := Surfaces[s].Values.Num_BoneRefs * 4; //cardinal    //SizeOf(TMDMBoneRef);
        if Size>0 then begin
          N := Fopen.Read(Surfaces[s].BoneRefs[0], Size);
          Result := (N=Size);
          if not Result then Exit;
        end;
        //
        FP := FP + Surfaces[s].Values.Ofs_SurfaceDataEnd;
      end;
      // Tags
      Fopen.Position := Header.Ofs_Tags;
      SetLength(Tags, Header.Num_Tags);
      for t:=0 to Header.Num_Tags-1 do begin
        Size := MAX_QPATH + 9*4 + 4 + 3*4 + 4 + 4 + 4;
        N := Fopen.Read(Tags[t].Name, Size);
{
        // assen corrigeren
        tmp := Tags[t].Axis[0];
        Tags[t].Axis[0] := Tags[t].Axis[1];
        Tags[t].Axis[1] := Tags[t].Axis[2];
        Tags[t].Axis[2] := tmp;
}        
        //
        Result := (N=Size);
        if not Result then Exit;
        // tag bonelist
        SetLength(Tags[t].BoneList, Tags[t].Num_Bones);
        Size := Tags[t].Num_Bones * 4; //cardinal
        if Size>0 then begin
          N := Fopen.Read(Tags[t].BoneList[0], Size);
          Result := (N=Size);
          if not Result then Exit;
        end;
      end;
      Result := true;
    except
      //
    end;
  finally
    Fopen.Free;
  end;
end;


function TMDM.SaveToFile(Filename: string): boolean;
var s, Size, v,w,t,br: cardinal;
begin
  Result := true;
  // offsets
  Header.Ofs_Surfaces := Size_Header;
  Header.Ofs_Tags     := Header.Ofs_Surfaces + Size_Surfaces;
  Header.Ofs_EOF      := Header.Ofs_Tags + Size_Tags;
  Size := 0;
  for s:=0 to Header.Num_Surfaces-1 do begin
    Surfaces[s].Values.Ofs_SurfaceHeader  := -(Size_Header + Size);
    Surfaces[s].Values.Ofs_Verts          := Size_SurfaceHeader;
    Surfaces[s].Values.Ofs_Triangles      := Surfaces[s].Values.Ofs_Verts + Size_SurfaceVertex(s);
    Surfaces[s].Values.Ofs_CollapseMap    := Surfaces[s].Values.Ofs_Triangles + Size_SurfaceTriangles(s);
    Surfaces[s].Values.Ofs_BoneRefs       := Surfaces[s].Values.Ofs_CollapseMap + Size_SurfaceCollapseMap(s);
    Surfaces[s].Values.Ofs_SurfaceDataEnd := Surfaces[s].Values.Ofs_BoneRefs + Size_SurfaceBoneRefs(s);
    Size := Size + Size_Surface(s);
  end;

  // bestand opslaan
  Fsave := TFileStream.Create(Filename, fmCreate);
  try
    try
      // Header
      Size := Size_Header;
      Fsave.WriteBuffer(Header, Size);
      // Surfaces
      for s:=0 to Header.Num_Surfaces-1 do begin
        // surface header
        Size := Size_SurfaceHeader;
        Fsave.WriteBuffer(Surfaces[s].Values, Size);
        // surface vertexes
        for v:=0 to Surfaces[s].Values.Num_Verts-1 do begin
          Fsave.WriteBuffer(Surfaces[s].Vertex[v].Normal.X, 6*4);
          for w:=0 to Surfaces[s].Vertex[v].Num_BoneWeights-1 do
            Fsave.WriteBuffer(Surfaces[s].Vertex[v].Weights[w], SizeOf(TMDMWeight));
        end;
        // surface triangles
        for t:=0 to Surfaces[s].Values.Num_Triangles-1 do
          Fsave.WriteBuffer(Surfaces[s].Triangles[t][0], 3*4);
{$IFDEF LOD}
        //collapsemap uitrekenen
        Surfaces[s].Values.LOD_minimum := Floor(Surfaces[s].Values.Num_Verts / 100.0 * LOD_PERCENTAGE);
        CM.LOD(LOD_PERCENTAGE, self, MDX, LOD_FRAMENR, s);
        for v:=0 to Surfaces[s].Values.Num_Verts-1 do
          Surfaces[s].CollapseMap[v] := CM.collapse_map[v];
          //Surfaces[s].CollapseMap[v] := CM.CMap(v, Surfaces[s].Values.LOD_minimum);
{$ENDIF}
        // surface collapsemap
        If Surfaces[s].Values.Num_Verts>0 then begin
          Size := Size_SurfaceCollapseMap(s);
          Fsave.WriteBuffer(Surfaces[s].CollapseMap[0], Size);
        end;
        // surface bonerefs
        If Surfaces[s].Values.Num_BoneRefs>0 then begin
          Size := Size_SurfaceBoneRefs(s);
          Fsave.WriteBuffer(Surfaces[s].BoneRefs[0], Size);
        end;
      end;
      // Tags
      for t:=0 to Header.Num_Tags-1 do begin
        Fsave.WriteBuffer(Tags[t].Name, MAX_QPATH+ 3*3*4 + 7*4);
        if Tags[t].Num_Bones>0 then
          Fsave.WriteBuffer(Tags[t].BoneList[0], Tags[t].Num_Bones * 4);
      end;
    except
      Result := false;
    end;
  finally
    Fsave.Free;
  end;
end;

function TMDM.LoadTagsFromFile(Filename: string): boolean;
var N, Size: cardinal;
    s,v,t: integer;
    FP: Int64;
    tmp: TVector;
    msg: string;
    tmpHeader: TMDMHeader;
begin
  Result := false;
  Fopen := TFileStream.Create(Filename, fmOpenRead);
  try
    try
      // Header
      N := Fopen.Read(tmpHeader, SizeOf(TMDMHeader));
      if N<>SizeOf(TMDMHeader) then Exit;
      Result := IsMDM;
      if not Result then Exit;
      // check limits
      if tmpHeader.Num_Tags > MDM_MAX_TAGS then begin
        msg := 'MAX_TAGS limit exceeded: '+ IntToStr(tmpHeader.Num_Tags) +' > '+ IntToStr(MDM_MAX_TAGS) +#13#10+ 'Continue loading?..';
        if MessageDlg(msg, mtConfirmation, [mbYes, mbNo], 0) = 7{mrNo} then begin
          Clear;
          Result := false;
          Exit;
        end;
      end;
      // Tags
      Fopen.Position := tmpHeader.Ofs_Tags;
      SetLength(Tags, tmpHeader.Num_Tags);
      for t:=0 to tmpHeader.Num_Tags-1 do begin
        Size := MAX_QPATH + 9*4 + 4 + 3*4 + 4 + 4 + 4;
        N := Fopen.Read(Tags[t].Name, Size);
        Result := (N=Size);
        if not Result then Exit;
        // tag bonelist
        SetLength(Tags[t].BoneList, Tags[t].Num_Bones);
        Size := Tags[t].Num_Bones * 4; //cardinal
        if Size>0 then begin
          N := Fopen.Read(Tags[t].BoneList[0], Size);
          Result := (N=Size);
          if not Result then Exit;
        end;
      end;
      Result := true;
    except
      //
    end;
  finally
    Fopen.Free;
  end;
end;



procedure TMDM.CalcModel(const MDX:TMDX; const FrameNr:cardinal; const SurfaceNr:cardinal);
var roll,yaw,pitch, tmp, weight: Single;
    bi,pidx,wi,vi,ti: integer;
    M: TMatrix4x4;
    d, bs, V: TVector;
    N: word;
    BCount, VCount, TCount: integer;
begin
  if FrameNr>=MDX.Header.Num_Frames then Exit;

  if SurfaceNr<{MDM.}Header.Num_Surfaces then
    VCount := {MDM.}Surfaces[SurfaceNr].Values.Num_Verts
  else
    VCount := 0;
  BCount := MDX.Header.Num_Bones;
  TCount := {MDM.}Header.Num_Tags;

  SetLength(BonePos, BCount);
  SetLength(BoneMat, BCount);
  SetLength(BoneMat_1, BCount);
  SetLength(VertexPos, VCount);
  SetLength(VertexNormal, VCount);
  SetLength(TagOrigin, TCount);
  SetLength(TagAxis, TCount);

  //--- bones
  for bi:=0 to BCount-1 do begin
{
if (string(MDX.Bones[bi].Name)='Bip01 R Toe0') or (string(MDX.Bones[bi].Name)='Bip01 L Toe0') then begin
//  MDX.Bones[bi].ParentDistance := 7.4794168472; //MDX lengte
  MDX.Bones[bi].ParentDistance := 5.8;
end;
}
    pidx := MDX.Bones[bi].ParentIndex;
    if pidx = -1 then
      BonePos[bi] := NullVector
    else begin
      tmp := MDX.Bones[bi].ParentDistance;
      pitch := -MDX.Frames[FrameNr].CompressedBoneFrame[bi].OffsetAngle_Pitch * MDX_DEG;
{
if (string(MDX.Bones[bi].Name)='Bip01 R Toe0') or (string(MDX.Bones[bi].Name)='Bip01 L Toe0') then begin
  pitch := pitch+15;
end;
}
      yaw := MDX.Frames[FrameNr].CompressedBoneFrame[bi].OffsetAngle_Yaw * MDX_DEG;
      M := MultiplyMatrix(YRotationMatrix(pitch), ZRotationMatrix(yaw));
      d := TransformVector(Vector(tmp,0,0), M);
      BonePos[bi] := AddVector(BonePos[pidx], d);
    end;
    // rotatie matrix
    roll := MDX.Frames[FrameNr].CompressedBoneFrame[bi].Angle_Roll * MDX_DEG;
    pitch := -MDX.Frames[FrameNr].CompressedBoneFrame[bi].Angle_Pitch * MDX_DEG;
    yaw := MDX.Frames[FrameNr].CompressedBoneFrame[bi].Angle_Yaw * MDX_DEG;
    BoneMat[bi] := MultiplyMatrix(MultiplyMatrix(XRotationMatrix(roll), YRotationMatrix(pitch)), ZRotationMatrix(yaw));
    // inverse rot.mat.
    BoneMat_1[bi] := BoneMat[bi];
    InverseMatrix(BoneMat_1[bi]); //TransposeMatrix is genoeg voor een rotatie-matrix
  end;

  //--- vertex
  for vi:=0 to VCount-1 do begin
    VertexPos[vi] := NullVector;
    VertexNormal[vi] := NullVector;
    for wi:=0 to {MDM.}Surfaces[SurfaceNr].Vertex[vi].Num_BoneWeights-1 do begin
      weight := {MDM.}Surfaces[SurfaceNr].Vertex[vi].Weights[wi].Weight;
      bi := {MDM.}Surfaces[SurfaceNr].Vertex[vi].Weights[wi].BoneIndex;
      bs := {MDM.}Surfaces[SurfaceNr].Vertex[vi].Weights[wi].BoneSpace;
      bs.Y := -bs.Y;
      // vertex
      V := TransformVector(bs, BoneMat_1[bi]);
      V := AddVector(V, BonePos[bi]);
      V := ScaleVector(V, weight);
      VertexPos[vi] := AddVector(VertexPos[vi], V);
      // vertexNormal
      V := Surfaces[SurfaceNr].Vertex[vi].Normal;
      V.Y := -V.Y;
      V := TransformVector(V, BoneMat_1[bi]);
      V := ScaleVector(V, weight);
      VertexNormal[vi] := AddVector(VertexNormal[vi], V);
    end;
  end;

  //--- tags
  for ti:=0 to TCount-1 do begin
    // origin
    bi := Tags[ti].AttachToBone;
    bs := Tags[ti].Offset;
    bs.Y := -bs.Y;
    V := TransformVector(bs, BoneMat_1[bi]);
    V := AddVector(V, BonePos[bi]);
    TagOrigin[ti] := V;
    //axis
    TagAxis[ti][0] := TransformVector(Tags[ti].Axis[0], BoneMat_1[bi]);
    TagAxis[ti][1] := TransformVector(Tags[ti].Axis[1], BoneMat_1[bi]);
    TagAxis[ti][2] := TransformVector(Tags[ti].Axis[2], BoneMat_1[bi]);
  end;

  // corrigeren
  for bi:=0 to BCount-1 do BonePos[bi].Z := -BonePos[bi].Z;
  for vi:=0 to VCount-1 do begin
    VertexPos[vi].Z := -VertexPos[vi].Z;
    VertexNormal[vi].Z := -VertexNormal[vi].Z;
  end;
  for ti:=0 to TCount-1 do begin
    TagOrigin[ti].Z := -TagOrigin[ti].Z;
    TagAxis[ti][0].Z := -TagAxis[ti][0].Z;
    TagAxis[ti][1].Z := -TagAxis[ti][1].Z;
    TagAxis[ti][2].Z := -TagAxis[ti][2].Z;
  end;


{ //test op dezelfde vertex meer dan 1 index heeft (dubbel erin)
vi:=0;
while vi<VCount-1 do begin
  for pidx:=vi to VCount-1 do begin
    if pidx=vi then Continue;
    if (VertexPos[vi].X=VertexPos[pidx].X) and (VertexPos[vi].Y=VertexPos[pidx].Y) and (VertexPos[vi].Z=VertexPos[pidx].Z) then begin
//      ShowMessage('VertexPos['+inttostr(vi)+'] = VertexPos['+inttostr(pidx)+']');
//      Surfaces[SurfaceNr].Vertex[vi] := Surfaces[SurfaceNr].Vertex[pidx];
      for ti:=0 to Surfaces[SurfaceNr].Values.Num_Triangles-1 do
        for bi:=0 to 2 do
          if Surfaces[SurfaceNr].Triangles[ti][bi] = pidx then Surfaces[SurfaceNr].Triangles[ti][bi] := vi;
//      vi:=0;
    end;
  end;
  Inc(vi);
end;}

  {SetLength(VertexNormal, 0);
  SetLength(VertexPos, 0);
  SetLength(BoneMat, 0);
  SetLength(BoneMat_1, 0);
  SetLength(BonePos, 0);
  SetLength(TagOrigin, 0);
  SetLength(TagAxis, 0);}
end;


procedure TMDM.CalcSurfaceNormals(const MDX:TMDX; const FrameNr,SurfaceNr:cardinal);
type TIntArray = array of integer;
var done: TIntArray;
var BCount, VCount, TrCount,
    vi,tri,wi,bi, vi1,vi2,vi3: integer;
    isDone: boolean;
    weight: single;
    Normal,Normal2, N,V: TVector;
//--
  function CheckNormal(VertexIndex:integer) : TVector;
  var d: integer;
  begin
    Result := Normal2;
    isDone := false;
    for d:=0 to Length(done)-1 do begin
      if done[d]=VertexIndex then begin
        isDone := true;
        Break;
      end;
    end;
    if not isDone then begin
      d := Length(done);
      SetLength(done, d+1);
      done[d] := VertexIndex;
    end else begin
      Result := UnitVector(AverageVector([Normal2,VertexNormal[VertexIndex]]));
      VertexNormal[VertexIndex] := Result;
    end;
    Result.Z := -Result.Z;  //!!!!!
  end;
//--
begin
  if FrameNr>=MDX.Header.Num_Frames then Exit;
  if SurfaceNr>={MDM.}Header.Num_Surfaces then Exit;
  if {MDM.}Surfaces[SurfaceNr].Values.Num_Triangles=0 then Exit;
  if {MDM.}Surfaces[SurfaceNr].Values.Num_Verts=0 then Exit;

  VCount := {MDM.}Surfaces[SurfaceNr].Values.Num_Verts;
  TrCount := {MDM.}Surfaces[SurfaceNr].Values.Num_Triangles;
  BCount := MDX.Header.Num_Bones;

  {MDM.}CalcModel(MDX, FrameNr, SurfaceNr);

  SetLength(done, 0);
  try
    //--- triangle-vertices
    for tri:=0 to TrCount-1 do begin
      vi1 := {MDM.}Surfaces[SurfaceNr].Triangles[tri][2];  // order
      vi2 := {MDM.}Surfaces[SurfaceNr].Triangles[tri][1];
      vi3 := {MDM.}Surfaces[SurfaceNr].Triangles[tri][0];


      // nieuwe face-normal berekenen
      Normal := PlaneNormal(VertexPos[vi1], VertexPos[vi2], VertexPos[vi3]);
      // winding controleren, en evt. omkeren..
      if not TriangleIsCCW(VertexPos[vi1], VertexPos[vi2], VertexPos[vi3], Normal) then begin
        // winding omkeren
        vi1 := {MDM.}Surfaces[SurfaceNr].Triangles[tri][2];
        {MDM.}Surfaces[SurfaceNr].Triangles[tri][2] := {MDM.}Surfaces[SurfaceNr].Triangles[tri][0];
        {MDM.}Surfaces[SurfaceNr].Triangles[tri][0] := vi1;
        //
        vi1 := {MDM.}Surfaces[SurfaceNr].Triangles[tri][2];  // order
        vi2 := {MDM.}Surfaces[SurfaceNr].Triangles[tri][1];
        vi3 := {MDM.}Surfaces[SurfaceNr].Triangles[tri][0];
        Normal := PlaneNormal(VertexPos[vi1], VertexPos[vi2], VertexPos[vi3]);
      end;

      Normal2 := Normal;

      // vi1
      Normal := CheckNormal(vi1);
      N := NullVector;
      for wi:=0 to {MDM.}Surfaces[SurfaceNr].Vertex[vi1].Num_BoneWeights-1 do begin
        weight := {MDM.}Surfaces[SurfaceNr].Vertex[vi1].Weights[wi].Weight;
        bi := {MDM.}Surfaces[SurfaceNr].Vertex[vi1].Weights[wi].BoneIndex;
        V := ScaleVector(Normal, weight);
        V := TransformVector(V, BoneMat[bi]);
        V.Y := -V.Y;
        N := AddVector(N,V);
      end;
      Surfaces[SurfaceNr].Vertex[vi1].Normal := N;

      // vi2
      Normal := CheckNormal(vi2);
      N := NullVector;
      for wi:=0 to {MDM.}Surfaces[SurfaceNr].Vertex[vi2].Num_BoneWeights-1 do begin
        weight := {MDM.}Surfaces[SurfaceNr].Vertex[vi2].Weights[wi].Weight;
        bi := {MDM.}Surfaces[SurfaceNr].Vertex[vi2].Weights[wi].BoneIndex;
        V := ScaleVector(Normal, weight);
        V := TransformVector(V, BoneMat[bi]);
        V.Y := -V.Y;
        N := AddVector(N,V);
      end;
      Surfaces[SurfaceNr].Vertex[vi2].Normal := N;

      // vi3
      Normal := CheckNormal(vi3);
      N := NullVector;
      for wi:=0 to {MDM.}Surfaces[SurfaceNr].Vertex[vi3].Num_BoneWeights-1 do begin
        weight := {MDM.}Surfaces[SurfaceNr].Vertex[vi3].Weights[wi].Weight;
        bi := {MDM.}Surfaces[SurfaceNr].Vertex[vi3].Weights[wi].BoneIndex;
        V := ScaleVector(Normal, weight);
        V := TransformVector(V, BoneMat[bi]);
        V.Y := -V.Y;
        N := AddVector(N,V);
      end;
      Surfaces[SurfaceNr].Vertex[vi3].Normal := N;

    end;
  finally
    SetLength(done, 0);
  end;
end;


procedure TMDM.SmoothSurface(const MDX:TMDX; const SurfaceNr:integer);
type TIntArray = array of integer;
var welt: TIntArray;
    done: TIntArray;
    NrWelt,NrDone, VCount,TrCount,
    vi,vi2, wi,bi, i,d: integer;
    doneContinue: boolean;
    Position,Normal, Position2,Normal2, AvgNormal, V,N: TVector;
    weight, totalWeight: Single;
begin
  if MDX.Header.Num_Frames=0 then Exit;
  if SurfaceNr>={MDM.}Header.Num_Surfaces then Exit;
  if {MDM.}Surfaces[SurfaceNr].Values.Num_Triangles=0 then Exit;
  if {MDM.}Surfaces[SurfaceNr].Values.Num_Verts=0 then Exit;

  TrCount := {MDM.}Surfaces[SurfaceNr].Values.Num_Triangles;
  VCount := {MDM.}Surfaces[SurfaceNr].Values.Num_Verts;

  CalcSurfaceNormals(MDX, 0, SurfaceNr);

  try
    NrDone := 0;
    SetLength(done, 0);
    //--- triangle-vertices
    for vi:=0 to VCount-1 do begin
      Position := VertexPos[vi];
      Normal := VertexNormal[vi];
(*
      // vertex al behandeld??
      doneContinue := false;
      for d:=0 to NrDone-1 do begin
        if done[d]=vi then begin
          doneContinue := true;
          Break;
        end;
      end;
      if doneContinue then Continue;
*)
      // tbv gemiddelde normaal
      AvgNormal := Normal;
      NrWelt := 1;
      SetLength(welt, NrWelt);
      welt[NrWelt-1] := vi;
      // deze vertex is behandeld
      NrDone := 1;
      SetLength(done, NrDone);
      done[NrDone-1] := vi;

      // zoeken in alle andere vertices..
      for vi2:=vi+1 to VCount-1 do begin
//      for vi2:=0 to VCount-1 do begin
        Position2 := VertexPos[vi2];
        Normal2 := VertexNormal[vi2];
        // zijn de punten bijna gelijk??
        if AlmostSameVector(Position, Position2, 0.02) then begin
          // gemiddelde normaal berekenen
          AvgNormal := AddVector(AvgNormal, Normal2);
          // aan "versmolten" array toevoegen
          Inc(NrWelt);
          SetLength(welt, NrWelt);
          welt[NrWelt-1] := vi2;
          //
          Inc(NrDone);
          SetLength(done, NrDone);
          done[NrDone-1] := vi2;
        end;
      end;

      // gemiddelde normaal berekenen
      AvgNormal := Scalevector(AvgNormal, 1/Length(welt));
      for i:=0 to Length(welt)-1 do begin
        // calced array
        VertexNormal[welt[i]] := AvgNormal;
        // model vertex-normal
AvgNormal.Z := -AvgNormal.Z;
        totalWeight := 0.0;
        N := NullVector;
        for wi:=0 to {MDM.}Surfaces[SurfaceNr].Vertex[vi].Num_BoneWeights-1 do begin
          weight := {MDM.}Surfaces[SurfaceNr].Vertex[vi].Weights[wi].Weight;
          totalWeight := totalWeight + weight;
          bi := {MDM.}Surfaces[SurfaceNr].Vertex[vi].Weights[wi].BoneIndex;
          V := ScaleVector(AvgNormal, weight);
          V := TransformVector(V, BoneMat[bi]);
          V.Y := -V.Y;
          N := AddVector(N,V);
        end;
        Surfaces[SurfaceNr].Vertex[vi].Normal := N;
{        if totalWeight > 1 then ShowMessage('totalWeight > 1');}
      end;
    end;
  finally
    SetLength(welt, 0);
    SetLength(done, 0);
  end;
end;




function TMDM.Size_Header: cardinal;
begin
  Result := SizeOf(TMDMHeader);
end;

function TMDM.Size_SurfaceHeader: cardinal;
begin
  Result := SizeOf(TMDMSurfaceHeader);
end;

function TMDM.Size_SurfaceVertex(SurfaceIndex: cardinal): cardinal;
var Size,v: cardinal;
begin
  Result := 0;
  if SurfaceIndex < 0 then Exit;
  if SurfaceIndex > Header.Num_Surfaces-1 then Exit;
  Size := 0;
  for v:=0 to Surfaces[SurfaceIndex].Values.Num_Verts-1 do begin
    Inc(Size, 6*4);
    Inc(Size, Surfaces[SurfaceIndex].Vertex[v].Num_BoneWeights * SizeOf(TMDMWeight));
  end;
  Inc(Result, Size);
end;

function TMDM.Size_SurfaceTriangles(SurfaceIndex: cardinal): cardinal;
begin
  Result := 0;
  if SurfaceIndex < 0 then Exit;
  if SurfaceIndex > Header.Num_Surfaces-1 then Exit;
  Result := Surfaces[SurfaceIndex].Values.Num_Triangles * SizeOf(TMDMTriangle);
end;

function TMDM.Size_SurfaceCollapseMap(SurfaceIndex: cardinal): cardinal;
begin
  Result := 0;
  if SurfaceIndex < 0 then Exit;
  if SurfaceIndex > Header.Num_Surfaces-1 then Exit;
  Result := Surfaces[SurfaceIndex].Values.Num_Verts * 4; //cardinal
end;

function TMDM.Size_SurfaceBoneRefs(SurfaceIndex: cardinal): cardinal;
begin
  Result := 0;
  if SurfaceIndex < 0 then Exit;
  if SurfaceIndex > Header.Num_Surfaces-1 then Exit;
  Result := Surfaces[SurfaceIndex].Values.Num_BoneRefs * 4; //cardinal
end;

function TMDM.Size_Surface(SurfaceIndex: cardinal): cardinal;
begin
  Result := 0;
  if SurfaceIndex < 0 then Exit;
  if SurfaceIndex > Header.Num_Surfaces-1 then Exit;
  Inc(Result, Size_SurfaceHeader);
  Inc(Result, Size_SurfaceVertex(SurfaceIndex));
  Inc(Result, Size_SurfaceTriangles(SurfaceIndex));
  Inc(Result, Size_SurfaceCollapseMap(SurfaceIndex));
  Inc(Result, Size_SurfaceBoneRefs(SurfaceIndex));
end;

function TMDM.Size_Surfaces: cardinal;
var s: integer;
begin
  Result := 0;
  for s:=0 to Header.Num_Surfaces-1 do Inc(Result, Size_Surface(s));
end;

function TMDM.Size_Tags: cardinal;
var Size,t: cardinal;
begin
  Result := 0;
  for t:=0 to Header.Num_Tags-1 do begin
    Size := MAX_QPATH + 9*4 + 4 + 3*4 + 4 + 4 + 4;
    Inc(Result, Size);
    Size := Tags[t].Num_Bones * 4; //cardinal
    Inc(Result, Size);
  end;
end;




function TMDM.GetTotalVertexCount: cardinal;
var i: integer;
begin
  Result := 0;
  for i:=0 to Header.Num_Surfaces-1 do
    Inc(Result, Surfaces[i].Values.Num_Verts);
end;

function TMDM.GetTotalTrianglesCount: cardinal;
var i: integer;
begin
  Result := 0;
  for i:=0 to Header.Num_Surfaces-1 do
    Inc(Result, Surfaces[i].Values.Num_Triangles);
end;

function TMDM.HasLOD: boolean;
var s,c: integer;
begin
  Result := true;
  for s:=0 to Header.Num_Surfaces-1 do
    for c:=0 to Surfaces[s].Values.Num_Verts-1 do
      if Surfaces[s].CollapseMap[c]<>0 then Exit;
  Result := false;
end;

procedure TMDM.ChangeShader(Index: Integer; Name: string);
var L: integer;
begin
  if Header.Num_Surfaces < 1 then Exit;
  if (Index < 0) or (Index >= Header.Num_Surfaces) then Exit;
  // string overnemen
  for L:=1 to Length(Name) do
    Surfaces[Index].Values.ShaderName[L-1] := Name[L];
  // opvullen met nullen
  for L:=Length(Name)+1 to MAX_QPATH-1 do
    Surfaces[Index].Values.ShaderName[L-1] := chr(0);
end;




initialization
  MDM := TMDM.Create;
finalization
  MDM.Free;

end.
