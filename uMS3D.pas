unit uMS3D;
interface
uses classes, SysUtils, u3DTypes, uCalc, uMD3, uMDM,uMDX, Forms,Windows, ComCtrls;

// fileformat taken from this webpage: http://chumbalum.swissquake.ch/ms3d/ms3dspec.txt

// Mesh Transformation:
//
// 0. Build the transformation matrices from the rotation and position
// 1. Multiply the vertices by the inverse of local reference matrix (lmatrix0)
// 2. then translate the result by (lmatrix0 * keyFramesTrans)
// 3. then multiply the result by (lmatrix0 * keyFramesRot)
//
// For normals skip step 2.

const
  LOD_FRAMENR = 0; //!!!!!DEBUG!!!!!

  IDMS3D = 'MS3D000000';

  // bitflags
  MS3D_SELECTED  = 1;
  MS3D_HIDDEN    = 2;
  MS3D_SELECTED2 = 4;
  MS3D_DIRTY     = 8;

type
  TMS3DHeader = packed record
    Id: packed array[0..9] of char;      // always "MS3D000000"
    Version: cardinal;                   // 4
  end;

  TMS3DVertex = packed record
    Flags: byte;                         // SELECTED | SELECTED2 | HIDDEN
    Position: TVector;
    BoneID: byte;                        // $FF (-1) = no bone
    ReferenceCount: byte;
  end;

  TMS3DTriangle = packed record
    Flags: word;                         // SELECTED | SELECTED2 | HIDDEN
    VertexIndexes: packed array[0..2] of word;
    VertexNormals: packed array[0..2] of TVector;
    TexCoords_S: packed array[0..2] of Single;
    TexCoords_T: packed array[0..2] of Single;
    SmoothingGroup: byte;                // 1..32
    GroupIndex: byte;
  end;

  TMS3DGroup = packed record
    Flags: byte;                         // SELECTED | HIDDEN
    Name: packed array[0..31] of char;
    Num_Triangles: word;
    TriangleIndexes: packed array of word; // length = Num_Triangles  (=> dynamic length)
    MaterialIndex: byte;                 // $FF (-1) = no material
  end;

  TMS3DMaterial = packed record
    Name: packed array[0..31] of char;
    Ambient: TVector4f;                  // !
    Diffuse: TVector4f;                  // !
    Specular: TVector4f;                 // !
    Emissive: TVector4f;                 // !
    Shininess: Single;                   // 0.0 .. 128.0
    Transparency: Single;                // 0.0 .. 1.0
    Mode: byte;                          // 0, 1, 2 is unused now
    Texture: packed array[0..127] of char;  // texture.bmp
    AlphaMap: packed array[0..127] of char; // alpha.bmp
  end;

  TMS3DKeyFrameRot = packed record
    Time: Single;                        // time in seconds
    Rotation: packed array[0..2] of Single;  // x,y,z angles
  end;

  TMS3DKeyFramePos = packed record
    Time: Single;                        // time in seconds
    Position: packed array[0..2] of Single;  // local position
  end;

  TMS3DBone = packed record              // dynamic length record
    Flags: byte;                         // SELECTED | DIRTY
    Name: packed array[0..31] of char;
    ParentName: packed array[0..31] of char;
    Rotation: TVector;                   // local reference matrix
    Position: TVector;
    Num_KeyFrameRot: word;
    Num_KeyFramePos: word;
    KeyFrameRot: packed array of TMS3DKeyFrameRot;  // local animation matrices
    KeyFramePos: packed array of TMS3DKeyFramePos;  //
  end;

  TMS3DComment = packed record           // the comment can be any length
    Index: cardinal;                     // index of group, material or joint
    CommentLength: cardinal;             // length of comment (terminating '\0' is not saved), "MC" has comment length of 2 (not 3)
    Comment: packed array of char;
  end;

  TMS3DVertexEx1 = packed record
    BoneIDs: packed array[0..2] of byte; // index of joint or -1, if -1, then that weight is ignored, since subVersion 1
    Weights: packed array[0..2] of byte; // vertex weight ranging from 0 - 255, last weight is computed by 1.0 - sum(all weights), since subVersion 1
    // weight[0] is the weight for boneId in ms3d_vertex_t
    // weight[1] is the weight for boneIds[0]
    // weight[2] is the weight for boneIds[1]
    // 1.0f - weight[0] - weight[1] - weight[2] is the weight for boneIds[2]
  end;

  TMS3DVertexEx2 = packed record
    BoneIDs: packed array[0..2] of byte; // index of joint or -1, if -1, then that weight is ignored, since subVersion 1
    Weights: packed array[0..2] of byte; // vertex weight ranging from 0 - 100, last weight is computed by 1.0 - sum(all weights), since subVersion 1
    // weight[0] is the weight for boneId in ms3d_vertex_t
    // weight[1] is the weight for boneIds[0]
    // weight[2] is the weight for boneIds[1]
    // 1.0f - weight[0] - weight[1] - weight[2] is the weight for boneIds[2]
    Extra: cardinal;                     // vertex extra, which can be used as color or anything else, since subVersion 2
  end;

  TMS3DBoneEx = packed record
    Color: packed array[0..2] of Single; // joint color, since subVersion == 1
  end;

  TMS3DModelEx = packed record
    JointSize: Single;                   // joint size, since subVersion == 1
    TransparencyMode: cardinal;          // 0 = simple, 1 = depth buffered with alpha ref, 2 = depth sorted triangles, since subVersion == 1
    AlphaRef: Single;                    // alpha reference value for transparencyMode = 1, since subVersion == 1
  end;


  //--- tbv calcmodel vertex/bones animatie
  TJoint = record
    localRotation: TVector;
    localTranslation: TVector;
    AbsMatrix,
    RelMatrix,
    FinalMatrix: TMatrix4x4;
    ParentIndex: integer;
  end;



  TMS3D = class(TObject)
  private
    Fopen: TFilestream;
    function IsMS3D : boolean;
  public
    // tbv. uitrekenen vertexpos, bonepos & bonemat
    Joints: array of TJoint;
    BonePos: array of TVector;
    BoneMat: array of TMatrix4x4;
    BoneMat_1: array of TMatrix4x4;
    VertexPos: array of TVector;
    VertexNormal: array of TVector;

    // file data
    Header: TMS3DHeader;
    Num_Vertex: word;
    Vertex: packed array of TMS3DVertex;        // length = Num_Vertex
    Num_Triangles: word;
    Triangles: packed array of TMS3DTriangle;   // length = Num_Triangles
    Num_Groups: word;
    Groups: packed array of TMS3DGroup;         // length = Num_Groups
    Num_Materials: word;
    Materials: packed array of TMS3DMaterial;   // length = Num_Materials
    // keyframe data
    AnimationFPS: Single;
    CurrentTime: Single;
    TotalFrames: cardinal;
    // bones
    Num_Bones: word;
    Bones: packed array of TMS3DBone;           // length = Num_Bones
    // comments
    SubVersion_Comments: cardinal;              // ==1, subVersion of the comments part, which is not available in older files
    Num_GroupComments: cardinal;
    GroupComments: packed array of TMS3DComment;
    Num_MaterialComments: cardinal;
    MaterialComments: packed array of TMS3DComment;
    Num_BoneComments: cardinal;
    BoneComments: packed array of TMS3DComment;
    Num_ModelComments: cardinal;                // which is always 0 or 1
    ModelComments: packed array of TMS3DComment;
    // vertex extra info
    SubVersion_VertexExtra: cardinal;           // ==2, subVersion of vertex extra information like bone weights, extra etc.
    VertexExtraInfo: packed array of TMS3DVertexEx2;  // length = Num_Vertex
    // bone extra info
    SubVersion_BoneExtra: cardinal;             // subVersion of bone extra information like color etc
    BoneExtraInfo: packed array of TMS3DBoneEx; // length = Num_Bones
    // model extra info
    SubVersion_ModelExtra: cardinal;             // ==1, subVersion of model extra information
    ModelExtraInfo: TMS3DModelEx;
    //
    function LoadFromFile(Filename: string): boolean;
    function ConvertToMD3(var MD3:TMD3) : boolean;
    function ConvertToMDMMDX(var MDM:TMDM; var MDX:TMDX; cStatusBar:TStatusBar; var msg:string) : boolean;
    procedure CalcModel(const FrameNr:cardinal);
  end;


var MS3D : TMS3D;



implementation
{ TMS3D }

function TMS3D.IsMS3D: boolean;
begin
  Result := (string(Header.Id) = IDMS3D);
end;

function TMS3D.LoadFromFile(Filename: string): boolean;
var i, N, Size: integer;
begin
  Result := false;
  Fopen := TFileStream.Create(Filename, fmOpenRead);
  try
    try
      // Header
      N := Fopen.Read(Header, SizeOf(TMS3DHeader));
      if N<>SizeOf(TMS3DHeader) then Exit;
      Result := IsMS3D;
      if not Result then Exit;
      // vertices
      N := Fopen.Read(Num_Vertex, 2);
      if N<>2 then Exit;
      SetLength(Vertex, Num_Vertex);
      Size := Num_Vertex * SizeOf(TMS3DVertex);
      N := Fopen.Read(Vertex[0], Size);
      if N<>Size then Exit;
      // triangles
      N := Fopen.Read(Num_Triangles, 2);
      if N<>2 then Exit;
      SetLength(Triangles, Num_Triangles);
      Size := Num_Triangles * SizeOf(TMS3DTriangle);
      N := Fopen.Read(Triangles[0], Size);
      if N<>Size then Exit;
      // groups
      N := Fopen.Read(Num_Groups, 2);
      if N<>2 then Exit;
      SetLength(Groups, Num_Groups);
      for i:=0 to Num_Groups-1 do begin
        Size := 1 + 32 + 2;
        N := Fopen.Read(Groups[i].Flags, Size);
        if N<>Size then Exit;
        SetLength(Groups[i].TriangleIndexes, Groups[i].Num_Triangles);
        Size := Groups[i].Num_Triangles * 2;
        N := Fopen.Read(Groups[i].TriangleIndexes[0], Size);
        if N<>Size then Exit;
        N := Fopen.Read(Groups[i].MaterialIndex, 1);
        if N<>1 then Exit;
      end;
      // materials
      N := Fopen.Read(Num_Materials, 2);
      if N<>2 then Exit;
      SetLength(Materials, Num_Materials);
      Size := Num_Materials * SizeOf(TMS3DMaterial);
      N := Fopen.Read(Materials[0], Size);
      if N<>Size then Exit;
      // keyframe data
      N := Fopen.Read(AnimationFPS, 4);
      if N<>4 then Exit;
      N := Fopen.Read(CurrentTime, 4);
      if N<>4 then Exit;
      N := Fopen.Read(TotalFrames, 4);
      if N<>4 then Exit;
      // bones
      N := Fopen.Read(Num_Bones, 2);
      if N<>2 then Exit;
      SetLength(Bones, Num_Bones);
      for i:=0 to Num_Bones-1 do begin
        Size := 1 + 32 + 32 + (3*4) + (3*4) + 2 + 2;
        N := Fopen.Read(Bones[i].Flags, Size);
        if N<>Size then Exit;
        SetLength(Bones[i].KeyFrameRot, Bones[i].Num_KeyFrameRot);
        Size := Bones[i].Num_KeyFrameRot * SizeOf(TMS3DKeyFrameRot);
        N := Fopen.Read(Bones[i].KeyFrameRot[0], Size);
        if N<>Size then Exit;
        SetLength(Bones[i].KeyFramePos, Bones[i].Num_KeyFramePos);
        Size := Bones[i].Num_KeyFramePos * SizeOf(TMS3DKeyFramePos);
        N := Fopen.Read(Bones[i].KeyFramePos[0], Size);
        if N<>Size then Exit;
      end;

      Result := true;

      // groupcomments
      N := Fopen.Read(SubVersion_Comments, 4);
      if N<>4 then Exit;
      N := Fopen.Read(Num_GroupComments, 4);
      if N<>4 then Exit;
      SetLength(GroupComments, Num_GroupComments);
      for i:=0 to Num_GroupComments-1 do begin
        N := Fopen.Read(GroupComments[i].Index, 4);
        if N<>4 then Exit;
        N := Fopen.Read(GroupComments[i].CommentLength, 4);
        if N<>4 then Exit;
        SetLength(GroupComments[i].Comment, GroupComments[i].CommentLength);
        N := Fopen.Read(GroupComments[i].Comment[0], GroupComments[i].CommentLength);
        if N<>GroupComments[i].CommentLength then Exit;
      end;
      // MaterialComments
      N := Fopen.Read(Num_MaterialComments, 4);
      if N<>4 then Exit;
      SetLength(MaterialComments, Num_MaterialComments);
      for i:=0 to Num_MaterialComments-1 do begin
        N := Fopen.Read(MaterialComments[i].Index, 4);
        if N<>4 then Exit;
        N := Fopen.Read(MaterialComments[i].CommentLength, 4);
        if N<>4 then Exit;
        SetLength(MaterialComments[i].Comment, MaterialComments[i].CommentLength);
        N := Fopen.Read(MaterialComments[i].Comment[0], MaterialComments[i].CommentLength);
        if N<>MaterialComments[i].CommentLength then Exit;
      end;
      // BoneComments
      N := Fopen.Read(Num_BoneComments, 4);
      if N<>4 then Exit;
      SetLength(BoneComments, Num_BoneComments);
      for i:=0 to Num_BoneComments-1 do begin
        N := Fopen.Read(BoneComments[i].Index, 4);
        if N<>4 then Exit;
        N := Fopen.Read(BoneComments[i].CommentLength, 4);
        if N<>4 then Exit;
        SetLength(BoneComments[i].Comment, BoneComments[i].CommentLength);
        N := Fopen.Read(BoneComments[i].Comment[0], BoneComments[i].CommentLength);
        if N<>BoneComments[i].CommentLength then Exit;
      end;
      // ModelComments
      N := Fopen.Read(Num_ModelComments, 4);
      if N<>4 then Exit;
      SetLength(ModelComments, Num_ModelComments);
      for i:=0 to Num_ModelComments-1 do begin
        N := Fopen.Read(ModelComments[i].Index, 4);
        if N<>4 then Exit;
        N := Fopen.Read(ModelComments[i].CommentLength, 4);
        if N<>4 then Exit;
        SetLength(ModelComments[i].Comment, ModelComments[i].CommentLength);
        N := Fopen.Read(ModelComments[i].Comment[0], ModelComments[i].CommentLength);
        if N<>ModelComments[i].CommentLength then Exit;
      end;
      // vertex extra info
      N := Fopen.Read(SubVersion_VertexExtra, 4);
      if N<>4 then Exit;
      SetLength(VertexExtraInfo, Num_Vertex);
      Size := Num_Vertex * SizeOf(TMS3DVertexEx2);
      N := Fopen.Read(VertexExtraInfo[0], Size);
      if N<>Size then Exit;
      // bone extra info
      N := Fopen.Read(SubVersion_BoneExtra, 4);
      if N<>4 then Exit;
      SetLength(BoneExtraInfo, Num_Bones);
      Size := Num_Bones * SizeOf(TMS3DBoneEx);
      N := Fopen.Read(BoneExtraInfo[0], Size);
      if N<>Size then Exit;
      // model extra info
      N := Fopen.Read(SubVersion_ModelExtra, 4);
      if N<>4 then Exit;
      N := Fopen.Read(ModelExtraInfo, SizeOf(TMS3DModelEx));
      if N<>SizeOf(TMS3DModelEx) then Exit;
      //
      Result := true;
    except
      //
    end;
  finally
    Fopen.Free;
  end;
end;


function TMS3D.ConvertToMD3(var MD3: TMD3): boolean;
const FrameName:array[0..15] of char = 'C MS3D Convert'#0' ';
var g,gt,ti,t,v,s,i: integer;
    Vec,Normal: TVector;
    texS,texT: Single;
    N: word;
    MinX,MaxX,MinY,MaxY,MinZ,MaxZ, AbsMax,ScaleFactor: Single; //boundingbox
    DoScaleDown: integer;
    nTags,TagNr, nGroups,GroupNr: integer;
    V1,V2,V3: TVector;
    Side1_2, Side2_3, Side3_1: Single;
    msg: string;
begin
  Result := false;
  // is conversie naar MD3 mogelijk?? (geen bones in dit model)
  if Num_Bones>0 then Exit;

  try
    MD3.Clear;

    // het aantal tags & groups tellen
    nTags := 0;
    nGroups := 0;
    for g:=0 to Num_Groups-1 do
      if Pos('tag_',Groups[g].Name)=1 then Inc(nTags)
                                      else Inc(nGroups);
    SetLength(MD3.Header.Tags, nTags);
    SetLength(MD3.Header.Surfaces, nGroups);

    // MD3 boundries testen om de evt. scalefactor te bepalen..
    MinX := 3.3E38;
    MaxX := -1.4E44;
    MinY := 3.3E38;
    MaxY := -1.4E44;
    MinZ := 3.3E38;
    MaxZ := -1.4E44;
    for g:=0 to Num_Groups-1 do begin
      // tags nu overslaan, niet op boundry testen..
      if Pos('tag_',Groups[g].Name)=1 then Continue;
      //
      for gt:=0 to Groups[g].Num_Triangles-1 do begin
        ti := Groups[g].TriangleIndexes[gt];
        for t:=0 to 2 do begin
          v := Triangles[ti].VertexIndexes[t];
          Vec := Vertex[v].Position;
          if Vec.X < MinX then MinX := Vec.X;
          if Vec.X > MaxX then MaxX := Vec.X;
          if Vec.Y < MinY then MinY := Vec.Y;
          if Vec.Y > MaxY then MaxY := Vec.Y;
          if Vec.Z < MinZ then MinZ := Vec.Z;
          if Vec.Z > MaxZ then MaxZ := Vec.Z;
        end;
      end;
    end;
    if (MinX<=-512) or (MaxX>=512) or
       (MinY<=-512) or (MaxY>=512) or
       (MinZ<=-512) or (MaxZ>=512) then begin
      // coordinaten buiten bereik voor MD3..
      DoScaleDown := Application.MessageBox(PChar('The model coordinates are out of the MD3-bounds.'#13#10'Scale the model down?'),
                                            PChar('Confirmation'),
                                            MB_YESNOCANCEL);
      if (DoScaleDown=IDNO) or (DoScaleDown=IDCANCEL) then begin
        msg := 'MS3D-model coordinates are exceeding the MD3 bounds: -511 to 511';
        MD3.Clear;
        Exit;
      end;
      // maximale waarde bepalen
      AbsMax := Abs(MinX);
      if Abs(MaxX) > AbsMax then AbsMax := Abs(MaxX);
      if Abs(MinY) > AbsMax then AbsMax := Abs(MinY);
      if Abs(MaxY) > AbsMax then AbsMax := Abs(MaxY);
      if Abs(MinZ) > AbsMax then AbsMax := Abs(MinZ);
      if Abs(MaxZ) > AbsMax then AbsMax := Abs(MaxZ);
      ScaleFactor := 511.0 / AbsMax;
      msg := 'MS3D-model scaled down to fit MD3-bounds';
    end else
      ScaleFactor := 1.0;

    // bounding box resetten..
    MinX := 3.3E38;
    MaxX := -1.4E44;
    MinY := 3.3E38;
    MaxY := -1.4E44;
    MinZ := 3.3E38;
    MaxZ := -1.4E44;

    // groups verwerken..
    GroupNr := 0;
    TagNr := 0;
    for g:=0 to Num_Groups-1 do begin

      // tags
      if Pos('tag_',Groups[g].Name)=1 then begin
        MD3.Header.Tags[TagNr].Name := MD3.StringToQ3(Groups[g].Name);
        // check triangle
        if Groups[g].Num_Triangles=1 then begin
          ti := Groups[g].TriangleIndexes[0];
          V1 := Vertex[Triangles[ti].VertexIndexes[0]].Position;
          V2 := Vertex[Triangles[ti].VertexIndexes[1]].Position;
          V3 := Vertex[Triangles[ti].VertexIndexes[2]].Position;
          V1 := ScaleVector(V1, ScaleFactor);
          V2 := ScaleVector(V2, ScaleFactor);
          V3 := ScaleVector(V3, ScaleFactor);
          // MS3D tag
          //  -X +-----+
          //      \    |
          //       \   |
          //        \  |
          //         \ |
          //          \|
          //           +
          //          +Z
          // zoek de rechte hoek
          if Abs(DotProduct(SubVector(V1,V2),SubVector(V1,V3)))<0.001 then begin
            MD3.Header.Tags[TagNr].Origin := V1;
            Side1_2 := VectorLength(SubVector(V1,V2));
            Side3_1 := VectorLength(SubVector(V3,V1));
            if Side1_2>Side3_1 then begin
              MD3.Header.Tags[TagNr].Axis[2] := UnitVector(SubVector(V2,V1));
              MD3.Header.Tags[TagNr].Axis[0] := UnitVector(SubVector(V1,V3));
            end else begin
              MD3.Header.Tags[TagNr].Axis[2] := UnitVector(SubVector(V3,V1));
              MD3.Header.Tags[TagNr].Axis[0] := UnitVector(SubVector(V1,V2));
            end;
          end else
          if Abs(DotProduct(SubVector(V2,V3),SubVector(V2,V1)))<0.001 then begin
            MD3.Header.Tags[TagNr].Origin := V2;
            Side1_2 := VectorLength(SubVector(V1,V2));
            Side2_3 := VectorLength(SubVector(V2,V3));
            if Side1_2>Side2_3 then begin
              MD3.Header.Tags[TagNr].Axis[2] := UnitVector(SubVector(V1,V2));
              MD3.Header.Tags[TagNr].Axis[0] := UnitVector(SubVector(V2,V3));
            end else begin
              MD3.Header.Tags[TagNr].Axis[2] := UnitVector(SubVector(V3,V2));
              MD3.Header.Tags[TagNr].Axis[0] := UnitVector(SubVector(V2,V1));
            end;
          end else
          if Abs(DotProduct(SubVector(V3,V1),SubVector(V3,V2)))<0.001 then begin
            MD3.Header.Tags[TagNr].Origin := V3;
            Side3_1 := VectorLength(SubVector(V3,V1));
            Side2_3 := VectorLength(SubVector(V2,V3));
            if Side3_1>Side2_3 then begin
              MD3.Header.Tags[TagNr].Axis[2] := UnitVector(SubVector(V1,V3));
              MD3.Header.Tags[TagNr].Axis[0] := UnitVector(SubVector(V3,V2));
            end else begin
              MD3.Header.Tags[TagNr].Axis[2] := UnitVector(SubVector(V2,V3));
              MD3.Header.Tags[TagNr].Axis[0] := UnitVector(SubVector(V2,V3));
            end;
          end;
          MD3.Header.Tags[TagNr].Axis[1] := UnitVector(CrossProduct(MD3.Header.Tags[TagNr].Axis[2], MD3.Header.Tags[TagNr].Axis[0]));
        end;
        Inc(TagNr);
        Continue;
      end;

      // MD3 surface header
      MD3.Header.Surfaces[GroupNr].Values.Ident         := IDP3;
      MD3.Header.Surfaces[GroupNr].Values.Flags         := 0;
      MD3.Header.Surfaces[GroupNr].Values.Name          := MD3.StringToQ3(Groups[g].Name);
      MD3.Header.Surfaces[GroupNr].Values.Num_Frames    := 1; //!!!!!DEBUG!!!!!
      MD3.Header.Surfaces[GroupNr].Values.Num_Verts     := Groups[g].Num_Triangles * 3;
      MD3.Header.Surfaces[GroupNr].Values.Num_Triangles := Groups[g].Num_Triangles;
      MD3.Header.Surfaces[GroupNr].Values.Num_Shaders   := 1;
      SetLength(MD3.Header.Surfaces[GroupNr].Shaders, 1);
      if Groups[g].MaterialIndex<>$FF then
        MD3.Header.Surfaces[GroupNr].Shaders[0].Name    := MD3.StringToQ3({'textures/'+}Materials[Groups[g].MaterialIndex].Texture)
      else
        MD3.Header.Surfaces[GroupNr].Shaders[0].Name    := MD3.StringToQ3('');
      // arrays alloceren
      SetLength(MD3.Header.Surfaces[GroupNr].Vertex, Groups[g].Num_Triangles * 3);
      SetLength(MD3.Header.Surfaces[GroupNr].TextureCoords, Groups[g].Num_Triangles * 3);
      SetLength(MD3.Header.Surfaces[GroupNr].Triangles, Groups[g].Num_Triangles);
      MD3.Header.Surfaces[GroupNr].Values.Num_Verts := Groups[g].Num_Triangles * 3;
      MD3.Header.Surfaces[GroupNr].Values.Num_Triangles := Groups[g].Num_Triangles;
      //
      for gt:=0 to Groups[g].Num_Triangles-1 do begin
        ti := Groups[g].TriangleIndexes[gt];
        for t:=0 to 2 do begin
          v := Triangles[ti].VertexIndexes[t];
          Vec := Vertex[v].Position;
          Normal := Triangles[ti].VertexNormals[t];
          texS := Triangles[ti].TexCoords_S[t];
          texT := Triangles[ti].TexCoords_T[t];
          //
          Vec := ScaleVector(Vec, ScaleFactor);
          MD3.Header.Surfaces[GroupNr].Vertex[gt*3+t].X := Round(Vec.X * MD3_XYZ_SCALE_1);
          MD3.Header.Surfaces[GroupNr].Vertex[gt*3+t].Y := Round(Vec.Y * MD3_XYZ_SCALE_1);
          MD3.Header.Surfaces[GroupNr].Vertex[gt*3+t].Z := Round(Vec.Z * MD3_XYZ_SCALE_1);
          MD3.EncodeNormal(Normal, N);
          MD3.Header.Surfaces[GroupNr].Vertex[gt*3+t].Normal := N;
          //
          MD3.Header.Surfaces[GroupNr].TextureCoords[gt*3+t].S := texS;
          MD3.Header.Surfaces[GroupNr].TextureCoords[gt*3+t].T := texT;
          //
          case t of
            0: MD3.Header.Surfaces[GroupNr].Triangles[gt].Index1 := gt*3+t;
            1: MD3.Header.Surfaces[GroupNr].Triangles[gt].Index2 := gt*3+t;
            2: MD3.Header.Surfaces[GroupNr].Triangles[gt].Index3 := gt*3+t;
          end;
          // boundingbox
          if Vec.X < MinX then MinX := Vec.X;
          if Vec.X > MaxX then MaxX := Vec.X;
          if Vec.Y < MinY then MinY := Vec.Y;
          if Vec.Y > MaxY then MaxY := Vec.Y;
          if Vec.Z < MinZ then MinZ := Vec.Z;
          if Vec.Z > MaxZ then MaxZ := Vec.Z;
        end;
      end;
      // volgende group
      Inc(GroupNr);
    end;

    // Header
    with MD3.Header.Values do begin
      Ident := IDP3;
      Version := 15;
      Name := MD3.StringToQ3('C_Converted_From_MS3D');
      Flags := 0;
      Num_Frames := 1;   // geen animatie
      Num_Tags := nTags;     
      Num_Surfaces := nGroups;
      Num_Skins := 0;
    end;

    // Frames
    SetLength(MD3.Header.Frames, 1);
    MD3.Header.Frames[0].Min_Bounds   := Vector(MinX,MinY,MinZ);
    MD3.Header.Frames[0].Max_Bounds   := Vector(MaxX,MaxY,MaxZ);
    MD3.Header.Frames[0].Local_Origin := ScaleVector(Vector(MaxX+MinX, MaxY+MinY, MaxZ+MinZ), 0.5);
    MD3.Header.Frames[0].Radius       := Vectorlength(SubVector(MD3.Header.Frames[0].Max_Bounds, MD3.Header.Frames[0].Min_Bounds)) * 0.5;
    for i:=0 to 15 do MD3.Header.Frames[0].Name[i] := FrameName[i];

    // winding omkeren
    MD3.FlipWinding;

    Result := true;
  finally
    //
  end;
end;

function TMS3D.ConvertToMDMMDX(var MDM:TMDM; var MDX:TMDX; cStatusBar:TStatusBar; var msg:string): boolean;
var MDX2MS3Dbones: array[0..255] of integer;
    MS3D2MDXbones: array[0..255] of integer;
    MDX_BoneCount: cardinal;
    tmpInt, f,b,v,br: integer;
    Vec, Vec2: TVector;
    MinX,MaxX,MinY,MaxY,MinZ,MaxZ: Single; //boundingbox
    nTags, nGroups, g: integer;
//--
  function MS3D_BoneCount : integer;
  var b: integer;
  begin
    Result := 0;
    for b:=0 to Num_Bones-1 do begin
      if Pos('tag_', string(Bones[b].Name))=1 then Continue;  // is een tag
      Inc(Result);
    end;
  end;
//--
  function MS3D_TagCount : integer;
  var b: integer;
  begin
    Result := 0;
    for b:=0 to Num_Bones-1 do begin
      if Pos('tag_', string(Bones[b].Name))=0 then Continue;  // is een bone
      Inc(Result);
    end;
  end;
//--
  function convertBones : integer;
  var b: integer;
  begin
    Result := 0; // aantal echte bones, (dus geen tags erbij)
    for b:=0 to Num_Bones-1 do begin
      MS3D2MDXbones[b] := -1;
      MDX2MS3Dbones[Result] := 0;
      if Pos('tag_', string(Bones[b].Name))>0 then Continue; //tag overslaan..
      MS3D2MDXbones[b] := Result;
      MDX2MS3Dbones[Result] := b;
      Inc(Result);
    end;
  end;
//--
  function FindTorsoParent : integer;
  var b: integer;
  begin
    Result := -1;
    for b:=0 to Num_Bones-1 do begin
      if string(Bones[b].Name)='Bip01 Spine' then begin
        Result := MS3D2MDXbones[b];
        Exit;
      end;
    end;
  end;
//--
  function FindIndex(BoneName:string) : integer;
  var b: integer;
  begin
    Result := -1;
    if BoneName='' then Exit;
    for b:=0 to Num_Bones-1 do begin
      if string(Bones[b].Name)=BoneName then begin
        Result := b;
        Exit;
      end;
    end;
  end;
//--
  function FindParentIndex(BoneName:string) : integer;
  var b,bp: integer;
      s: string;
  begin
    Result := -1;
    b := FindIndex(BoneName);
    if b=-1 then Exit;
    s := string(Bones[b].ParentName);
    Result := FindIndex(s);
  end;
//--
  function SetupJoints : boolean;
  var b,p: integer;
  begin
    Result := true;
    SetLength(Joints, Num_Bones);
    for b:=0 to Num_Bones-1 do begin
      p := FindParentIndex(string(Bones[b].Name));
      Joints[b].ParentIndex := p;
      Joints[b].localRotation := Bones[b].Rotation;
      Joints[b].localTranslation := Bones[b].Position;
      Joints[b].RelMatrix := RotationMatrix_Rad(Bones[b].Rotation);
      Joints[b].RelMatrix := SetMatrixTranslation(Joints[b].RelMatrix, Bones[b].Position);
      // parent transformatie verwerken
      if p = -1 then
        Joints[b].AbsMatrix := Joints[b].RelMatrix
      else
        Joints[b].AbsMatrix := MultiplyMatrix(Joints[p].AbsMatrix, Joints[b].RelMatrix);
    end;
  end;
//--
begin
  Result := false;
  // MDM/MDX legen
  MDM.Clear;
  MDX.Clear;

  try
    MDX_BoneCount := convertBones; // tags uit MS3D filteren, en indexes omzetten

    //--- MDX ------------------------------------------------------------------
    // Header
    tmpInt := FindTorsoParent;
    if tmpInt=-1 then begin
      msg := 'TorsoParent bone ''Bip01 Spine'' does not exist';
      {MDM.Clear;
      MDX.Clear;}
      Exit;
    end;
    MDX.Header.TorsoParent := tmpInt;              // index van 'Bip01 Spine'
    MDX.Header.Ident       := IDMDX;
    MDX.Header.Version     := 2;
    MDX.Header.Name        := 'c_ms3d.mdx';        //'output/animations/human/base/body.mdx'
    MDX.Header.Num_Frames  := TotalFrames;
    MDX.Header.Num_Bones   := MDX_BoneCount;

    // Frames
    SetupJoints;  // bones matrices
    SetLength(MDX.Frames, TotalFrames);
    for f:=0 to MDX.Header.Num_Frames-1 do begin

      cStatusBar.SimpleText := 'Converting to MDX: frame '+ IntToStr(f) +' of '+ IntToStr(MDX.Header.Num_Frames);

      CalcModel(f);

      if Num_Vertex>0 then begin
        // boundingbox bepalen
        MinX := 3.3E38;
        MaxX := -1.4E44;
        MinY := 3.3E38;
        MaxY := -1.4E44;
        MinZ := 3.3E38;
        MaxZ := -1.4E44;
        //
        for v:=0 to Num_Vertex-1 do begin
          if VertexPos[v].X < MinX then MinX := VertexPos[v].X;
          if VertexPos[v].X > MaxX then MaxX := VertexPos[v].X;
          if VertexPos[v].Y < MinY then MinY := VertexPos[v].Y;
          if VertexPos[v].Y > MaxY then MaxY := VertexPos[v].Y;
          if VertexPos[v].Z < MinZ then MinZ := VertexPos[v].Z;
          if VertexPos[v].Z > MaxZ then MaxZ := VertexPos[v].Z;
        end;
        //
        MDX.Frames[f].Min_Bounds   := Vector(MinX,MinY,MinZ);
        MDX.Frames[f].Max_Bounds   := Vector(MaxX,MaxY,MaxZ);
        MDX.Frames[f].Local_Origin := ScaleVector(Vector(MaxX+MinX, MaxY+MinY, MaxZ+MinZ), 0.5);
        MDX.Frames[f].Radius       := Vectorlength(SubVector(MDX.Frames[f].Max_Bounds, MDX.Frames[f].Min_Bounds)) * 0.5;
        MDX.Frames[f].ParentOffset := NullVector; //!!!!!DEBUG!!!!!!!!!!!!!!!!!!
      end else begin
        MDX.Frames[f].Min_Bounds   := NullVector;
        MDX.Frames[f].Max_Bounds   := NullVector;
        MDX.Frames[f].Local_Origin := NullVector;
        MDX.Frames[f].Radius       := 0;
        MDX.Frames[f].ParentOffset := NullVector; //!!!!!DEBUG!!!!!!!!!!!!!!!!!!
      end;

      SetLength(MDX.Frames[f].CompressedBoneFrame, MDX_BoneCount);
      for b:=0 to MDX_BoneCount-1 do begin

        Vec := ScaleVector(Vector(Bones[MDX2MS3Dbones[b]].KeyFrameRot[f].Rotation),  constRadToDeg * (1/MDX_DEG));
        MDX.Frames[f].CompressedBoneFrame[b].Angle_Pitch       := Round(Vec.Y);
        MDX.Frames[f].CompressedBoneFrame[b].Angle_Yaw         := Round(Vec.Z);
        MDX.Frames[f].CompressedBoneFrame[b].Angle_Roll        := Round(Vec.X);
{
        Vec := ScaleVector(Bones[MDX2MS3Dbones[b]].Rotation,  constRadToDeg * (1/MDX_DEG));
        MDX.Frames[f].CompressedBoneFrame[b].OffsetAngle_Pitch := Round(Vec.Y);
        MDX.Frames[f].CompressedBoneFrame[b].OffsetAngle_Yaw   := Round(Vec.Z);
}
        Vec := ScaleVector(Vector(Bones[MDX2MS3Dbones[b]].KeyFrameRot[f].Rotation), constRadToDeg * (1/MDX_DEG));
        MDX.Frames[f].CompressedBoneFrame[b].OffsetAngle_Pitch := Round(Vec.Y);
        MDX.Frames[f].CompressedBoneFrame[b].OffsetAngle_Yaw   := Round(Vec.Z);
      end;
    end;

    // Bones
    SetLength(MDX.Bones, MDX_BoneCount);
    for b:=0 to MDX.Header.Num_Bones-1 do begin
      MDX.Bones[b].Name           := MD3.StringToQ3(string(Bones[MDX2MS3Dbones[b]].Name));
      br := FindParentIndex(string(Bones[MDX2MS3Dbones[b]].Name));
      MDX.Bones[b].ParentIndex    := br;
      if MDX.Bones[b].ParentIndex<>-1 then MDX.Bones[b].ParentIndex := MS3D2MDXbones[br];
      MDX.Bones[b].TorsoWeight    := 0; //!!!!!DEBUG!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      if br=-1 then
        MDX.Bones[b].ParentDistance := 0 //VectorLength(BonePos[MDX2MS3Dbones[b]])
      else begin
        Vec := BonePos[MDX2MS3Dbones[b]];
        Vec2 := BonePos[br];
        MDX.Bones[b].ParentDistance := VectorLength(SubVector(Vec,Vec2));
      end;
      MDX.Bones[b].Flags          := 0;
    end;

    //--- MDM ------------------------------------------------------------------
    // het aantal tags & groups tellen
    nTags := 0;
    nGroups := 0;
    for g:=0 to Num_Groups-1 do
      if Pos('tag_',Groups[g].Name)=1 then Inc(nTags)
                                      else Inc(nGroups);

    // Header
    MDM.Header.Ident        := IDMDM;
    MDM.Header.Version      := 3;
    MDM.Header.Name         := 'c_ms3d.mdx';
    MDM.Header.LOD_bias     := 1;
    MDM.Header.LOD_scale    := 0;
    MDM.Header.Num_Surfaces := 0; //nGroups;
//    if nTags>0 then  //!!!!!DEBUG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    MDM.Header.Num_Tags     := 0; //MS3D_TagCount; // bone-tags

    Result := true;

  finally
  end;
end;


procedure TMS3D.CalcModel(const FrameNr: cardinal);
(*
// Mesh Transformation:
//
// 0. Build the transformation matrices from the rotation and position
// 1. Multiply the vertices by the inverse of local reference matrix (lmatrix0)
// 2. then translate the result by (lmatrix0 * keyFramesTrans)
// 3. then multiply the result by (lmatrix0 * keyFramesRot)
// For normals skip step 2.
*)
var b,v: integer;
    M: TMatrix4x4;
    Vec: TVector;
begin
  SetLength(BonePos, Num_Bones);
  SetLength(BoneMat, Num_Bones);
  SetLength(BoneMat_1, Num_Bones);
  SetLength(VertexPos, Num_Vertex);
  SetLength(VertexNormal, Num_Vertex);

  for b:=0 to Num_Bones-1 do begin
    // bonepos
    M := RotationMatrix_Rad(Vector(Bones[b].KeyFrameRot[FrameNr].Rotation));
    M := SetMatrixTranslation(Joints[b].FinalMatrix, Vector(Bones[b].KeyFramePos[FrameNr].Position));
    M := MultiplyMatrix(Joints[b].RelMatrix, M);
    if Joints[b].ParentIndex = -1 then begin
      Joints[b].FinalMatrix := M;
    end else begin
      Joints[b].FinalMatrix := MultiplyMatrix(Joints[Joints[b].ParentIndex].FinalMatrix, M);
    end;
    BonePos[b] := TransformVector(Bones[b].Position, MatrixInverse(Joints[b].FinalMatrix));

    BoneMat[b] := Joints[b].FinalMatrix;
    // inverse matrix
    BoneMat_1[b] := BoneMat[b];
    InverseMatrix(BoneMat_1[b]); //TransposeMatrix is genoeg voor een rotatie-matrix

{
    for v:=0 to Num_Vertex-1 do begin
    end;
}
  end;
end;


initialization
  MS3D := TMS3D.Create;
finalization
  MS3D.Free;

end.
