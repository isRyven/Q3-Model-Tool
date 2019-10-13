unit uASE;
interface
uses Classes, SysUtils, StrUtils, Dialogs, Forms, Windows, u3DTypes, uCalc, uMD3;

type
  TASEHeader = record
    Filename: string;
    ID: string;
    Comment: string;
  end;

  TASEColor = record
    R,G,B: single;
  end;

  TASESubMaterial = record
    Name: string;
    Transparency: single;                   // 0.0 - 1.0
    Texture: string;
    IsEnvMap: boolean;
  end;

  TASEMaterial = record
    Name: string;
    Transparency: single;                   // 0.0 - 1.0
    Texture: string;
    SubMaterials: array of TASESubMaterial;
  end;

  TASEFace = record
    VertexIndexes: array[0..2] of cardinal;        // index in array TASEMesh.Vertex_List
    Edges: array[0..2] of boolean;
    SmoothingGroup: cardinal;
    MaterialIndex: cardinal;                       // index in array TASE.Materials
  end;

  TASETextureCoords = record
    U,V: single;
  end;

  TASETextureFaces = record
    TextureCoordsIndexes: array[0..2] of cardinal; // index in array TASEMesh.TextureCoords
  end;

  TASEMesh = record
    FrameNumber: cardinal;
    Vertex_List: array of TVector;
    Faces_List: array of TASEFace;
    TextureCoords: array of TASETextureCoords;
    TextureFaces: array of TASETextureFaces;
  end;

  TASEObject = record
    Name: string;
    Meshes: array of TASEMesh;
  end;


  TASE = class(TObject)
  private
    Header: TASEHeader;
    Materials: array of TASEMaterial;
    Objects: array of TASEObject;
    //
    function GetName(s:string) : string;
    function GetFloat(s:string) : Single;
    function GetInteger(s:string) : Integer;
    function GetVertex(s:string) : TVector;
    function GetFace(s:string) : TASEFace;
    function GetTextureCoords(s:string) : TASETextureCoords;
    function GetTextureFace(s:string) : TASETextureFaces;
  public
    procedure Clear;
    function LoadFromFile(const Filename:string; var msg:string) : boolean;
    function ConvertToMD3(var MD3:TMD3; var msg:string): boolean;
  end;

var
  ASE: TASE;

implementation

function TASE.GetName(s: string): string;
var p0,p1: integer;
begin
  Result := '';
  if s='' then Exit;
  // resulteer de naam (zonder quotes)
  p0 := Pos('"', s);
  if p0=0 then Exit;
  Inc(p0);
  p1 := PosEx('"', s, p0);
  if p1=0 then p1 := Length(s)+1
          else Dec(p1);
  Result := Copy(s, p0, p1-p0+1);
end;

function TASE.GetFloat(s: string): Single;
var p0,p1: integer;
    strFloat: string;
    valFloat: Single;
begin
  Result := 0.0;
  if s='' then Exit;
  // resulteer de float op einde regel
  p0 := Pos(' ', s);
  if p0=0 then p0 := Pos(#9, s);
  if p0=0 then Exit;
  Inc(p0);
  p1 := Length(s)+1;
  strFloat := Copy(s, p0, p1-p0+1);
  if TryStrToFloat(strFloat, valFloat) then Result := valFloat;
end;

function TASE.GetInteger(s: string): Integer;
var p0,p1: integer;
    strInteger: string;
    valInteger: Integer;
begin
  Result := 0;
  if s='' then Exit;
  // resulteer de integer op einde regel
  p0 := Pos(' ', s);
  if p0=0 then p0 := Pos(#9, s);
  if p0=0 then Exit;
  Inc(p0);
  p1 := Length(s)+1;
  strInteger := Copy(s, p0, p1-p0+1);
  if TryStrToInt(strInteger, valInteger) then Result := valInteger;
end;

// "*MESH_VERTEX 2711 85.5756	11.7410	-4.7888"
function TASE.GetVertex(s: string): TVector;
var p0,p1: integer;
    strFloat: string;
    valFloat: Single;
    valVector: TVector;
begin
  Result := NullVector;
  if s='' then Exit;
  // resulteer de vector op einde regel
  p0 := PosEx(#9, s, 14); //TAB
  if p0=0 then Exit;
  Inc(p0);
  p1 := PosEx(#9, s, p0);
  if p1=0 then Exit;
  strFloat := Copy(s, p0, p1-p0);
  if TryStrToFloat(strFloat, valFloat) then valVector.X := valFloat else Exit;
  p0 := p1+1;
  p1 := PosEx(#9, s, p0);
  if p1=0 then Exit;
  strFloat := Copy(s, p0, p1-p0);
  if TryStrToFloat(strFloat, valFloat) then valVector.Y := valFloat else Exit;
  p0 := p1+1;
  p1 := Length(s)+1;
  strFloat := Copy(s, p0, p1-p0);
  if TryStrToFloat(strFloat, valFloat) then valVector.Z := valFloat else Exit;
  Result := valVector;
end;

// "*MESH_FACE    0:    A:   13 B:   10 C:    9 AB:    1 BC:    1 CA:    1	 *MESH_SMOOTHING 4 	*MESH_MTLID 0"
function TASE.GetFace(s: string): TASEFace;
var p0,p1: integer;
    strInteger: string;
    valInteger: Integer;
begin
  if s='' then Exit;
  // resulteer de face
  p0 := Pos('A:', s);
  if p0=0 then Exit;
  Inc(p0, 2);
  p1 := PosEx('B:', s, p0);
  if p1=0 then Exit;
  strInteger := Trim(Copy(s, p0, p1-p0));
  if TryStrToInt(strInteger, valInteger) then Result.VertexIndexes[0] := valInteger;
  p0 := p1+2;
  p1 := PosEx('C:', s, p0);
  if p1=0 then Exit;
  strInteger := Trim(Copy(s, p0, p1-p0));
  if TryStrToInt(strInteger, valInteger) then Result.VertexIndexes[1] := valInteger;
  p0 := p1+2;
  p1 := PosEx('AB:', s, p0);
  if p1=0 then Exit;
  strInteger := Trim(Copy(s, p0, p1-p0));
  if TryStrToInt(strInteger, valInteger) then Result.VertexIndexes[2] := valInteger;
  p0 := p1+3;
  p1 := PosEx('BC:', s, p0);
  if p1=0 then Exit;
  strInteger := Trim(Copy(s, p0, p1-p0));
  if TryStrToInt(strInteger, valInteger) then Result.Edges[0] := (valInteger=1);
  p0 := p1+3;
  p1 := PosEx('CA:', s, p0);
  if p1=0 then Exit;
  strInteger := Trim(Copy(s, p0, p1-p0));
  if TryStrToInt(strInteger, valInteger) then Result.Edges[1] := (valInteger=1);
  p0 := p1+3;
  p1 := PosEx('*MESH_SMOOTHING', s, p0);
  if p1=0 then Exit;
  strInteger := Trim(Copy(s, p0, p1-p0));
  if TryStrToInt(strInteger, valInteger) then Result.Edges[2] := (valInteger=1);
  p0 := p1+15;
  p1 := PosEx('*MESH_MTLID', s, p0);
  if p1=0 then Exit;
  strInteger := Trim(Copy(s, p0, p1-p0));
  if TryStrToInt(strInteger, valInteger) then Result.SmoothingGroup := valInteger;
  p0 := p1+11;
  p1 := Length(s)+1;
  strInteger := Trim(Copy(s, p0, p1-p0));
  if TryStrToInt(strInteger, valInteger) then Result.MaterialIndex := valInteger;
end;

// "*MESH_TVERT 0  0.000  0.000  0.500"
function TASE.GetTextureCoords(s: string): TASETextureCoords;
var p0,p1: integer;
    strFloat: string;
    valFloat: Single;
begin
  // resulteer de 2 texture coördinaten
  p0 := PosEx(#9, s, 13); //TAB
  if p0=0 then Exit;
  Inc(p0);
  p1 := PosEx(#9, s, p0);
  if p1=0 then Exit;
  strFloat := Copy(s, p0, p1-p0);
  if TryStrToFloat(strFloat, valFloat) then Result.U := valFloat else Exit;
  p0 := p1+1;
  p1 := PosEx(#9, s, p0);
  strFloat := Copy(s, p0, p1-p0);
  if TryStrToFloat(strFloat, valFloat) then Result.V := valFloat else Exit;
end;

// "*MESH_TFACE 0  3  0  2"
function TASE.GetTextureFace(s: string): TASETextureFaces;
var p0,p1: integer;
    strInteger: string;
    valInteger: Integer;
begin
  // resulteer de 3 indexes naar de texture-coördinaten
  p0 := PosEx(#9, s, 13); //TAB
  if p0=0 then Exit;
  Inc(p0);
  p1 := PosEx(#9, s, p0);
  strInteger := Trim(Copy(s, p0, p1-p0));
  if TryStrToInt(strInteger, valInteger) then Result.TextureCoordsIndexes[0] := valInteger;
  p0 := p1+1;
  p1 := PosEx(#9, s, p0);
  strInteger := Trim(Copy(s, p0, p1-p0));
  if TryStrToInt(strInteger, valInteger) then Result.TextureCoordsIndexes[1] := valInteger;
  p0 := p1+1;
  p1 := Length(s)+1;
  strInteger := Trim(Copy(s, p0, p1-p0));
  if TryStrToInt(strInteger, valInteger) then Result.TextureCoordsIndexes[2] := valInteger;
end;


procedure TASE.Clear;
var Len,LenM,m,o: integer;
begin
  // header
  Header.Filename := '';
  Header.ID := '';
  Header.Comment := '';
  // materials
  Len := Length(Materials);
  for m:=0 to Len-1 do SetLength(Materials[m].SubMaterials, 0);
  SetLength(Materials, 0);
  // objects
  Len := Length(Objects);
  for o:=0 to Len-1 do
    for m:=0 to Length(Objects[o].Meshes)-1 do begin
      SetLength(Objects[o].Meshes[m].Vertex_List, 0);
      SetLength(Objects[o].Meshes[m].Faces_List, 0);
      SetLength(Objects[o].Meshes[m].TextureCoords, 0);
      SetLength(Objects[o].Meshes[m].TextureFaces, 0);
    end;
  SetLength(Objects, 0);
end;


function TASE.LoadFromFile(const Filename:string; var msg:string): boolean;
var i, Len, MatRef,tmpInt: integer;
    s: string;
    sl: TStringList;
    MaterialNr, SubMaterialNr, ObjectNr, MeshNr: integer;
    LevelID, LevelSubMaterial, LevelReflect, LevelDiffuse,
    LevelMeshVertexList, LevelMeshFaceList, LevelTextureVertexList, LevelTextureFaceList: boolean;
begin
  Result := false;
  sl := TStringList.Create;
  {ASE.}Clear;

  // bestaat de file??
  if not FileExists(Filename) then begin
    msg := 'File does not exist: '+ Filename;
    Exit;
  end;
  Header.Filename := ExtractFilename(Filename);

  try
    sl.Clear;
    sl.LoadFromFile(Filename);

    MaterialNr := -1;
    SubMaterialNr := -1;
    ObjectNr := -1;
    MeshNr := -1;
    LevelID := true;
    LevelSubMaterial := false;
    LevelReflect := false;
    LevelDiffuse := false;
    LevelMeshVertexList := false;
    LevelMeshFaceList := false;
    LevelTextureVertexList := false;
    LevelTextureFaceList := false;

    for i:=0 to sl.Count-1 do begin
      s := trim(sl.Strings[i]);
      if s='' then Continue;

      // tbv. snellere afhandeling deze tests bovenaan de lus..
      if LevelMeshVertexList then begin
        if (Pos('*MESH_VERTEX ', s)>0) or (Pos('*MESH_VERTEX'#9'', s)>0) then begin
          Len := Length(Objects[ObjectNr].Meshes[MeshNr].Vertex_List);
          SetLength(Objects[ObjectNr].Meshes[MeshNr].Vertex_List, Len+1);
          Objects[ObjectNr].Meshes[MeshNr].Vertex_List[Len] := GetVertex(s);
          Continue;
        end;
      end else
      if LevelMeshFaceList then begin
        if (Pos('*MESH_FACE ', s)>0) or (Pos('*MESH_FACE'#9'', s)>0) then begin
          Len := Length(Objects[ObjectNr].Meshes[MeshNr].Faces_List);
          SetLength(Objects[ObjectNr].Meshes[MeshNr].Faces_List, Len+1);
          Objects[ObjectNr].Meshes[MeshNr].Faces_List[Len] := GetFace(s);
          Continue;
        end;
      end else
      if LevelTextureVertexList then begin
        if Pos('*MESH_TVERT', s)>0 then begin
          Len := Length(Objects[ObjectNr].Meshes[MeshNr].TextureCoords);
          SetLength(Objects[ObjectNr].Meshes[MeshNr].TextureCoords, Len+1);
          Objects[ObjectNr].Meshes[MeshNr].TextureCoords[Len] := GetTextureCoords(s);
          Continue;
        end;
      end else
      if LevelTextureFaceList then begin
        if Pos('*MESH_TFACE', s)>0 then begin
          Len := Length(Objects[ObjectNr].Meshes[MeshNr].TextureFaces);
          SetLength(Objects[ObjectNr].Meshes[MeshNr].TextureFaces, Len+1);
          Objects[ObjectNr].Meshes[MeshNr].TextureFaces[Len] := GetTextureFace(s);
          Continue;
        end;
      end;

      // lees header
      if LevelID then begin
        if Pos('*3DSMAX_ASCIIEXPORT', s)>0 then begin
          Header.ID := s;
          LevelID := false;
        end else begin
          msg := 'File is no valid ASE: '+ Filename;
          Exit;
        end;
      end else
      if Pos('*COMMENT', s)>0 then begin
        Header.Comment := s;
      end else

      // lees material-list
      if Pos('*MATERIAL_LIST', s)>0 then begin
        LevelSubMaterial := false;
        LevelReflect := false;
        LevelDiffuse := false;
      end else
      // *MATERIAL
      if (Pos('*MATERIAL ', s)>0) or (Pos('*MATERIAL'#9'', s)>0) then begin
        Len := Length(Materials);
        SetLength(Materials, Len+1);
        MaterialNr := Len;
        LevelSubMaterial := false;
        LevelReflect := false;
        LevelDiffuse := false;
      end else
      if Pos('*MATERIAL_NAME', s)>0 then begin
        if not LevelSubMaterial then Materials[MaterialNr].Name := GetName(s)
                                else Materials[MaterialNr].SubMaterials[SubMaterialNr].Name := GetName(s);
      end else
      if Pos('*MATERIAL_TRANSPARENCY', s)>0 then begin
        if not LevelSubMaterial then Materials[MaterialNr].Transparency := GetFloat(s)
                                else Materials[MaterialNr].SubMaterials[SubMaterialNr].Transparency := GetFloat(s);
      end else
      // *SUBMATERIAL
      if Pos('*SUBMATERIAL', s)>0 then begin
        Len := Length(Materials[MaterialNr].SubMaterials);
        SetLength(Materials[MaterialNr].SubMaterials, Len+1);
        SubMaterialNr := Len;
        LevelSubMaterial := true;
        LevelReflect := false;
        LevelDiffuse := false;
      end else
      if Pos('*MAP_REFLECT', s)>0 then begin
        LevelReflect := true;
        LevelDiffuse := false;
      end else
      if Pos('*MAP_DIFFUSE', s)>0 then begin
        LevelReflect := false;
        LevelDiffuse := true;
      end else
      if (Pos('*BITMAP ', s)>0) or (Pos('*BITMAP'#9'', s)>0) then begin
        if LevelSubMaterial then begin
          with Materials[MaterialNr].SubMaterials[SubMaterialNr] do
            if LevelReflect then begin
              Texture := GetName(s);
              IsEnvMap := true;
            end else
            if LevelDiffuse then begin
              Texture := GetName(s);
              IsEnvMap := false;
            end;
        end else
          {if LevelDiffuse then} Materials[MaterialNr].Texture := GetName(s);
      end else
      // *GEOMOBJECT
      if Pos('*GEOMOBJECT', s)>0 then begin
        Len := Length(Objects);
        SetLength(Objects, Len+1);
        ObjectNr := Len;
        LevelReflect := false;
        LevelDiffuse := false;
        LevelMeshVertexList := false;
        LevelMeshFaceList := false;
        LevelTextureVertexList := false;
        LevelTextureFaceList := false;
      end else
      if Pos('*NODE_NAME', s)>0 then begin
        Objects[ObjectNr].Name := GetName(s);
      end else
      // *MESH
      if (Pos('*MESH ', s)>0) or (Pos('*MESH'#9'', s)>0) then begin
        Len := Length(Objects[ObjectNr].Meshes);
        SetLength(Objects[ObjectNr].Meshes, Len+1);
        MeshNr := Len;
      end else
      if Pos('*TIMEVALUE', s)>0 then begin
        Objects[ObjectNr].Meshes[MeshNr].FrameNumber := GetInteger(s);
      end else
      if Pos('*MESH_VERTEX_LIST', s)>0 then begin
        LevelMeshVertexList := true;
        LevelMeshFaceList := false;
        LevelTextureVertexList := false;
        LevelTextureFaceList := false;
      end else
      if Pos('*MESH_FACE_LIST', s)>0 then begin
        LevelMeshVertexList := false;
        LevelMeshFaceList := true;
        LevelTextureVertexList := false;
        LevelTextureFaceList := false;
      end else
      if Pos('*MESH_TVERTLIST', s)>0 then begin
        LevelMeshVertexList := false;
        LevelMeshFaceList := false;
        LevelTextureVertexList := true;
        LevelTextureFaceList := false;
      end else
      if Pos('*MESH_TFACELIST', s)>0 then begin
        LevelMeshVertexList := false;
        LevelMeshFaceList := false;
        LevelTextureVertexList := false;
        LevelTextureFaceList := true;
      end else
      if Pos('*MATERIAL_REF', s)>0 then begin
        Len := Length(Objects[ObjectNr].Meshes[MeshNr].Faces_List);
        MatRef := GetInteger(s);
        for tmpInt:=0 to Len-1 do
          Objects[ObjectNr].Meshes[MeshNr].Faces_List[tmpInt].MaterialIndex := MatRef;
      end;

    end;
    msg := '';
    Result := true;
  finally
    sl.Free;
  end;
end;


function TASE.ConvertToMD3(var MD3:TMD3; var msg:string): boolean;
const FrameName:array[0..15] of char = 'C ASE Convert'#0'  ';
var MinX,MaxX,MinY,MaxY,MinZ,MaxZ: Single; //boundingbox
    Num_Materials, Num_SubMaterials, Num_Objects, Num_Meshes, Num_Verts, Num_Faces,
    LenVerts, LenFaces, SurfaceNr: integer;
    s,subs,o,m,f,i,v: integer;
    strTexture: string;
    vi1,vi2,vi3, idx: integer;
    v1,v2,v3, Normal, Vec: TVector;
    N: word;
    DoScaleDown: integer;
    AbsMax, ScaleFactor: Single;
//--
  function IgnoreShader(s:string) : boolean;
  begin
    Result := ((Pos('common/',s)>0) or (Pos('common\',s)>0) or (Pos('noshader',s)>0) or (Pos('NULL',s)>0));
  end;
//--
begin
  Result := false;
  MD3.Clear;


  // test op "lege" shaders
  Num_Materials := 0;
  for m:=0 to Length(Materials)-1 do
    if not IgnoreShader(Materials[m].Texture) then Inc(Num_Materials);

  // MD3 limiet controle
  {Num_Materials := Length(Materials);}
  if Num_Materials > MD3_MAX_SURFACES then begin
    msg := 'MAX_SURFACES limit exceeded: '+ IntToStr(Num_Materials) +' > '+ IntToStr(MD3_MAX_SURFACES) +#13#10+
           'Too many materials/shaders/textures used..';
    ShowMessage(msg);
    Exit;
  end;


  // test of coördinaten buiten bereik vallen voor MD3 ( < -512 of > 512 )
  // bounding box
  MinX := 3.3E38;
  MaxX := -1.4E44;
  MinY := 3.3E38;
  MaxY := -1.4E44;
  MinZ := 3.3E38;
  MaxZ := -1.4E44;
  //
  for o:=0 to Num_Objects-1 do begin
    for m:=0 to Length(Objects[o].Meshes)-1 do
      for v:=0 to Length(Objects[o].Meshes[m].Vertex_List)-1 do begin
        Vec := Objects[o].Meshes[m].Vertex_List[v];
        if Vec.X < MinX then MinX := Vec.X;
        if Vec.X > MaxX then MaxX := Vec.X;
        if Vec.Y < MinY then MinY := Vec.Y;
        if Vec.Y > MaxY then MaxY := Vec.Y;
        if Vec.Z < MinZ then MinZ := Vec.Z;
        if Vec.Z > MaxZ then MaxZ := Vec.Z;
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
      msg := 'ASE-model coordinates are exceeding the MD3 bounds: -511 to 511';
      MD3.Clear;
      Exit;
    end;
    msg := 'ASE-model scaled down to fit MD3-bounds';
    // maximale waarde bepalen
    AbsMax := Abs(MinX);
    if Abs(MaxX) > AbsMax then AbsMax := Abs(MaxX);
    if Abs(MinY) > AbsMax then AbsMax := Abs(MinY);
    if Abs(MaxY) > AbsMax then AbsMax := Abs(MaxY);
    if Abs(MinZ) > AbsMax then AbsMax := Abs(MinZ);
    if Abs(MaxZ) > AbsMax then AbsMax := Abs(MaxZ);
    ScaleFactor := 511.0 / AbsMax;
  end else
    ScaleFactor := 1.0;


  // bounding box resetten
  MinX := 3.3E38;
  MaxX := -1.4E44;
  MinY := 3.3E38;
  MaxY := -1.4E44;
  MinZ := 3.3E38;
  MaxZ := -1.4E44;

  // surfaces array vullen
  SetLength(MD3.Header.Surfaces, Num_Materials);
  SurfaceNr := 0;
  for s:=0 to Length(Materials)-1 do begin
    if IgnoreShader(Materials[s].Texture) then Continue;

    // surface header
    MD3.Header.Surfaces[SurfaceNr].Values.Ident         := IDP3;
    MD3.Header.Surfaces[SurfaceNr].Values.Flags         := 0;
    MD3.Header.Surfaces[SurfaceNr].Values.Num_Frames    := 1;
    MD3.Header.Surfaces[SurfaceNr].Values.Name          := MD3.StringToQ3(Materials[s].Name);

    // shader
    MD3.Header.Surfaces[SurfaceNr].Values.Num_Shaders := 1;
    SetLength(MD3.Header.Surfaces[SurfaceNr].Shaders, 1);
    strTexture := '';
    if Materials[s].Texture='' then begin
      Num_SubMaterials := Length(Materials[s].SubMaterials);
      for subs:=0 to Num_SubMaterials-1 do
        with Materials[s].SubMaterials[subs] do
          if (Texture<>'') and (not IsEnvMap) then
            strTexture := Texture;
    end else
      strTexture := Materials[s].Texture;
    MD3.Header.Surfaces[SurfaceNr].Shaders[0].Name := MD3.StringToQ3(strTexture);

    // vertex
    LenVerts := 0;
    LenFaces := 0;
    // doorloop alle objects, op zoek naar faces met eenzelfde material
    Num_Objects := Length(Objects);
    Num_Verts := 0;
    Num_Faces := 0;
    for o:=0 to Num_Objects-1 do begin
      Num_Meshes := Length(Objects[o].Meshes);
      for m:=0 to Num_Meshes-1 do begin
        Num_Faces := Length(Objects[o].Meshes[m].Faces_List);
        for f:=0 to Num_Faces-1 do begin
          if Objects[o].Meshes[m].Faces_List[f].MaterialIndex = s then begin
            // vertex & texturecoords
            idx := LenVerts;
            Inc(LenVerts, 3);
            MD3.Header.Surfaces[SurfaceNr].Values.Num_Verts := LenVerts;
            SetLength(MD3.Header.Surfaces[SurfaceNr].Vertex, LenVerts);
            SetLength(MD3.Header.Surfaces[SurfaceNr].TextureCoords, LenVerts);
            //
            vi1 := Objects[o].Meshes[m].Faces_List[f].VertexIndexes[0];
            vi2 := Objects[o].Meshes[m].Faces_List[f].VertexIndexes[1];
            vi3 := Objects[o].Meshes[m].Faces_List[f].VertexIndexes[2];
            v1 := Objects[o].Meshes[m].Vertex_List[vi1];
            v2 := Objects[o].Meshes[m].Vertex_List[vi2];
            v3 := Objects[o].Meshes[m].Vertex_List[vi3];
            // evt. scale
            v1 := ScaleVector(v1, ScaleFactor);
            v2 := ScaleVector(v2, ScaleFactor);
            v3 := ScaleVector(v3, ScaleFactor);
            // normaal
            Normal := PlaneNormal(v1,v2,v3);
            MD3.EncodeNormal(Normal, N);
            //
            MD3.Header.Surfaces[SurfaceNr].Vertex[idx].X := Round(v1.X * MD3_XYZ_SCALE_1);
            MD3.Header.Surfaces[SurfaceNr].Vertex[idx].Y := Round(v1.Y * MD3_XYZ_SCALE_1);
            MD3.Header.Surfaces[SurfaceNr].Vertex[idx].Z := Round(v1.Z * MD3_XYZ_SCALE_1);
            MD3.Header.Surfaces[SurfaceNr].Vertex[idx].Normal := N;
            if Length(Objects[o].Meshes[m].TextureFaces)>0 then begin
              i := Objects[o].Meshes[m].TextureFaces[f].TextureCoordsIndexes[0];
              MD3.Header.Surfaces[SurfaceNr].TextureCoords[idx].S := Objects[o].Meshes[m].TextureCoords[i].U;
              MD3.Header.Surfaces[SurfaceNr].TextureCoords[idx].T := 1.0-Objects[o].Meshes[m].TextureCoords[i].V;
            end;
            Inc(idx);
            MD3.Header.Surfaces[SurfaceNr].Vertex[idx].X := Round(v2.X * MD3_XYZ_SCALE_1);
            MD3.Header.Surfaces[SurfaceNr].Vertex[idx].Y := Round(v2.Y * MD3_XYZ_SCALE_1);
            MD3.Header.Surfaces[SurfaceNr].Vertex[idx].Z := Round(v2.Z * MD3_XYZ_SCALE_1);
            MD3.Header.Surfaces[SurfaceNr].Vertex[idx].Normal := N;
            if Length(Objects[o].Meshes[m].TextureFaces)>0 then begin
              i := Objects[o].Meshes[m].TextureFaces[f].TextureCoordsIndexes[1];
              MD3.Header.Surfaces[SurfaceNr].TextureCoords[idx].S := Objects[o].Meshes[m].TextureCoords[i].U;
              MD3.Header.Surfaces[SurfaceNr].TextureCoords[idx].T := 1.0-Objects[o].Meshes[m].TextureCoords[i].V;
            end;
            Inc(idx);
            MD3.Header.Surfaces[SurfaceNr].Vertex[idx].X := Round(v3.X * MD3_XYZ_SCALE_1);
            MD3.Header.Surfaces[SurfaceNr].Vertex[idx].Y := Round(v3.Y * MD3_XYZ_SCALE_1);
            MD3.Header.Surfaces[SurfaceNr].Vertex[idx].Z := Round(v3.Z * MD3_XYZ_SCALE_1);
            MD3.Header.Surfaces[SurfaceNr].Vertex[idx].Normal := N;
            if Length(Objects[o].Meshes[m].TextureFaces)>0 then begin
              i := Objects[o].Meshes[m].TextureFaces[f].TextureCoordsIndexes[2];
              MD3.Header.Surfaces[SurfaceNr].TextureCoords[idx].S := Objects[o].Meshes[m].TextureCoords[i].U;
              MD3.Header.Surfaces[SurfaceNr].TextureCoords[idx].T := 1.0-Objects[o].Meshes[m].TextureCoords[i].V;
            end;
            // faces/triangles
            Inc(LenFaces);
            MD3.Header.Surfaces[SurfaceNr].Values.Num_Triangles := LenFaces;
            SetLength(MD3.Header.Surfaces[SurfaceNr].Triangles, LenFaces);
            MD3.Header.Surfaces[SurfaceNr].Triangles[LenFaces-1].Index1 := idx-2;
            MD3.Header.Surfaces[SurfaceNr].Triangles[LenFaces-1].Index2 := idx-1;
            MD3.Header.Surfaces[SurfaceNr].Triangles[LenFaces-1].Index3 := idx;

            // boundingbox
            if v1.X < MinX then MinX := v1.X;
            if v1.X > MaxX then MaxX := v1.X;
            if v1.Y < MinY then MinY := v1.Y;
            if v1.Y > MaxY then MaxY := v1.Y;
            if v1.Z < MinZ then MinZ := v1.Z;
            if v1.Z > MaxZ then MaxZ := v1.Z;
            //
            if v2.X < MinX then MinX := v2.X;
            if v2.X > MaxX then MaxX := v2.X;
            if v2.Y < MinY then MinY := v2.Y;
            if v2.Y > MaxY then MaxY := v2.Y;
            if v2.Z < MinZ then MinZ := v2.Z;
            if v2.Z > MaxZ then MaxZ := v2.Z;
            //
            if v3.X < MinX then MinX := v3.X;
            if v3.X > MaxX then MaxX := v3.X;
            if v3.Y < MinY then MinY := v3.Y;
            if v3.Y > MaxY then MaxY := v3.Y;
            if v3.Z < MinZ then MinZ := v3.Z;
            if v3.Z > MaxZ then MaxZ := v3.Z;

          end;
        end;
      end;
    end;
    // MD3 limiet controle..
    if LenVerts >= MD3_MAX_VERTS then begin
      msg := 'MAX_VERTS limit exceeded: '+ IntToStr(LenVerts) +' > '+ IntToStr(MD3_MAX_VERTS) +#13#10+
             'Too many vetices used with the same material/shader/texture..' +#13#10+
             'Material: '+ Materials[s].Name;
      ShowMessage(msg);
      MD3.Clear;
      Exit;
    end;
    if LenFaces > MD3_MAX_TRIANGLES then begin
      msg := 'MAX_TRIANGLES limit exceeded: '+ IntToStr(LenFaces) +' > '+ IntToStr(MD3_MAX_TRIANGLES) +#13#10+
             'Too many faces used with the same material/shader/texture..' +#13#10+
             'Material: '+ Materials[s].Name;
      ShowMessage(msg);
      MD3.Clear;
      Exit;
    end;
    // volgende surface..
    Inc(SurfaceNr);
  end;

  // Header
  with MD3.Header.Values do begin
    Ident := IDP3;
    Version := 15;
    Name := MD3.StringToQ3('C_Converted_From_ASE_'+ Header.Filename);
    Flags := 0;
    Num_Frames := 1;   // geen animatie
    Num_Tags := 0;     // geen tags
    Num_Surfaces := Num_Materials;
    Num_Skins := 0;
  end;

  // Tags
  SetLength(MD3.Header.Tags, 0);

  // Frames
  SetLength(MD3.Header.Frames, 1);
  MD3.Header.Frames[0].Min_Bounds   := Vector(MinX,MinY,MinZ);
  MD3.Header.Frames[0].Max_Bounds   := Vector(MaxX,MaxY,MaxZ);
  MD3.Header.Frames[0].Local_Origin := ScaleVector(Vector(MaxX+MinX, MaxY+MinY, MaxZ+MinZ), 0.5);
  MD3.Header.Frames[0].Radius       := Vectorlength(SubVector(MD3.Header.Frames[0].Max_Bounds, MD3.Header.Frames[0].Min_Bounds)) * 0.5;
  for i:=0 to 15 do MD3.Header.Frames[0].Name[i] := FrameName[i];

  // CCW maken
  MD3.FlipWinding;

  msg := 'ASE converted to MD3';
  Result := true;
end;


initialization
  ASE := TASE.Create;
finalization
  ASE.Free;

end.
