unit uMD3;
interface
uses classes, StdCtrls, ExtCtrls, u3DTypes, uQ3Shaders;

// http://icculus.org/homepages/phaethon/q3a/formats/md3format.html

const
  MAX_QPATH = 64;
  MD3_MAX_LODS = 4;
  MD3_MAX_FRAMES = 1024;      // per model
  MD3_MAX_TAGS = 16;          // per frame
  MD3_MAX_SURFACES = 32;      // per model
  MD3_MAX_SHADERS = 256;      // per surface
  MD3_MAX_VERTS = 1024;       // per surface    //was 4096 but prints a message from ET: "has more than 1025 verts on a surface"
  MD3_MAX_TRIANGLES = 8192;   // per surface
  MD3_XYZ_SCALE = 1.0/64.0;
  MD3_XYZ_SCALE_1 = 64.0;
  IDP3 = $33504449; // 'IDP3' cardinal
  TAG3 = $33474154; // 'TAG3' cardinal

type
  q3string = packed array[0..MAX_QPATH-1] of char;

  TTagFileHeader = packed record
    Ident: cardinal;            // == 'TAG3'
    Version: cardinal;
    Num_Tags: cardinal;
    Ofs_End: cardinal;
  end;

  TVec3 = packed record
            X,Y,Z: single;
          end;

  TShader = packed record
              Name: q3string;
              Shader_Index: Integer;  //intern gebruik
            end;

  TTriangle = packed record
                Index1,                //vertex 1 index
                Index2,                //vertex 2 index
                Index3: cardinal;      //vertex 3 index
              end;

  TTextureCoords = packed record       // 0.0 .. 1.0
                    S,
                    T: single;
                  end;

  TVertex = packed record
              X,                       // X * MD3_XYZ_SCALE == X-coordinaat
              Y,                       // Y * MD3_XYZ_SCALE == Y-coordinaat
              Z: SmallInt;             // Z * MD3_XYZ_SCALE == Z-coordinaat
              Normal: word;            // gecodeerde normaal
            end;

  TSurface1 = packed record
               Ident: cardinal;        // == 'IDP3'
               Name: q3string;
               Flags: cardinal;
               Num_Frames: cardinal;   //het aantal animatie frames
               Num_Shaders: cardinal;  //het aantal shaders
               Num_Verts: cardinal;    //het aantal vertexes
               Num_Triangles: cardinal;//het aantal triangles
               Ofs_Triangles: cardinal;
               Ofs_Shaders: cardinal;
               Ofs_ST: cardinal;
               Ofs_XYZNormal: cardinal;
               Ofs_End: cardinal;
             end;
  TSurface = packed record
               Values: TSurface1;
               // Shaders array
               Shaders: packed array of TShader;
               // Triangles array
               Triangles: packed array of TTriangle;
               // ST texture-coords array
               TextureCoords: packed array of TTextureCoords;
               // XYZNormals array
               Vertex: packed array of TVertex;
             end;

  TFrame = packed record
             Min_Bounds: TVector;
             Max_Bounds: TVector;
             Local_Origin: TVector;
             Radius: single;
             Name: array[0..15] of char;
           end;

  TTag = packed record
           Name: q3string;
           Origin: TVector;
           Axis: packed array[0..2] of TVector;
         end;

  THeader1 = packed record
           Ident: cardinal;            // == 'IDP3'
           Version: cardinal;
           Name: q3string;
           Flags: cardinal;
           Num_Frames: cardinal;       //maximale waarde = MD3_MAX_FRAMES
           Num_Tags: cardinal;         //maximale waarde = MD3_MAX_TAGS
           Num_Surfaces: cardinal;     //maximale waarde = MD3_MAX_SURFACES
           Num_Skins: cardinal;
           Ofs_Frames: cardinal;        //offset van 1e frame-object (vanaf start TMD3)
           Ofs_Tags: cardinal;          //offset van 1e tag-object    " "
           Ofs_Surfaces: cardinal;      //offset van 1e surface-object  " "
           Ofs_EOF: cardinal;           //offset einde van MD3-object   " "
         end;
  THeader = packed record
           Values: THeader1;
           // frames array
           Frames: packed array of TFrame;
           // tags array
           Tags: packed array of TTag;  // Num_Frames * Num_Tags
           // surfaces array
           Surfaces: packed array of TSurface;
         end;


  TMD3 = class(TObject)
  private
    Fopen, Fsave: TFilestream;
    function IsMD3 : boolean;
    //
    function Size_Header : cardinal;
    function Size_Frames : cardinal;
    function Size_Tags : cardinal;
    function Size_Surfaces : cardinal;
    function Size_File : cardinal;
    function Size_SurfaceHeader : cardinal;
    function Size_SurfaceShaders(SurfaceIndex: cardinal) : cardinal;
    function Size_SurfaceTriangles(SurfaceIndex: cardinal) : cardinal;
    function Size_SurfaceTexCoords(SurfaceIndex: cardinal) : cardinal;
    function Size_SurfaceVertex(SurfaceIndex: cardinal) : cardinal;
    function Size_Surface(SurfaceIndex: cardinal) : cardinal;
    //
    function ClosestTriangle(const origin:TVector; var SurfaceIndex:integer; var TriangleIndex:integer) : boolean;
    function CalcBaseFromTriangle(const SurfaceIndex, TriangleIndex:integer) : TMatrix4x4;
    function CalcTransformMatrixFromBases(const Base1,Base2:TMatrix4x4; const Origin1,Origin2:TVector) : TMatrix4x4;
  public
    Header : THeader;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure ClearMemory;
    function StringToQ3(const aString: string) : q3string;
    procedure DecodeNormal(const Normal: word; var X,Y,Z: single);
    procedure EncodeNormal(const Normal:TVector; var Value: word); overload;
    procedure EncodeNormal(const X,Y,Z:single; var Value: word); overload;
    //
    procedure CalcDimensions(FrameNr:integer; var BoundsMin:TVector; var BoundsMax:TVector; var Center:TVector);
    //
    procedure ChangeShader(Index: Integer; Name: string);
    //
    procedure AddTags(Filename: string);
    procedure AddTag(const aTag: TTag);
    procedure SaveTags(Filename: string);
    procedure TagsInvertX;
    procedure TagsInvertY;
    procedure TagsInvertZ;
    procedure TagsSwapXY;
    procedure TagsSwapXZ;
    procedure TagsSwapYZ;
    //
    procedure FlipXcoords;
    procedure FlipYcoords;
    procedure FlipZcoords;
    procedure FlipNormals;
    procedure FlipWinding;
    //
    procedure RotateModel(const M:TMatrix4x4);
    procedure RotateModelX(const Degrees:single);
    procedure RotateModelY(const Degrees:single);
    procedure RotateModelZ(const Degrees:single);
    // swap texture-coördinaten
    procedure TexCoords_SwapST_UV(SurfaceIndex: cardinal);
    // surface-normals opnieuw berekenen
    procedure CalculateSurfaceNormals(SurfaceNr:integer);
    // geen echte weld.. vertices blijven aparte indexen behouden
    procedure WeldVertices(SurfaceNr:integer; Distance:Single);
    // smooth surface
    procedure SmoothSurface(SurfaceNr:integer);
    // remove a surface
    procedure RemoveSurface(SurfaceNr:integer);
    // compact as many surfaces (with same shader) into as few as possible
    procedure CompactSurfaces;
    //
    function LoadFromFile(Filename: string) : boolean;
    function SaveToFile(Filename: string) : boolean;
    //
    function AddFrame(Filename:string; var ErrorString:string) : boolean;
    function AddFrames(Filename:string; var ErrorString:string) : boolean;
    function InsertFrameAt(FrameNr:cardinal; Filename:string) : boolean;
    function DeleteFrame(FrameNr: cardinal) : boolean;
    //
    procedure InitShaders;
    procedure FreeShaders;
    function IsTextured : boolean;
    procedure Render;
  end;


var MD3 : TMD3;

(*
  normaal-word:
  _____________________________________________
  |15 14 13 12 11 10 9 8   |  7 6 5 4 3 2 1 0 |
  ---------------------------------------------
  |lat (latitude)          |  lng (longitude) |
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯


  Decoding: (Code in q3tools/q3map/misc_model.c:InsertMD3Model)
    lat := ((normal shr 8) and 255) * (2 * pi ) / 255
    lng := (normal and 255) * (2 * pi) / 255
    normal.x := cos(lat) * sin(lng)
    normal.y := sin(lat) * sin(lng)
    normal.z := cos(lng)



  Encoding: (Code in q3tools/common/mathlib.c:NormalToLatLong)
    lng := atan2(y/x) * 255 / (2 * pi)
    lat := acos(z) * 255 / (2 * pi)
    lng := lower 8 bits of lng
    lat := lower 8 bits of lat
    normal := (lat shl 8) or (lng)

  Two special vectors are the ones that point up and point down,
  as these values for z result in a singularity for acos.
  The special case of straight-up is:
    normal := 0

  And the special case of straight down is:
    lat := 0
    lng := 128
    normal := (lat shl 8) or (lng)
  or, shorter:
    normal := 32768
*)


//------------------------------------------------------------------------------
implementation
uses SysUtils, uCalc, Math;

constructor TMD3.Create;
begin
  ClearMemory;
end;

destructor TMD3.Destroy;
begin
  ClearMemory;
  inherited;
end;


procedure TMD3.ClearMemory;
var i: integer;
begin
  // memory
  with Header do begin
    SetLength(Frames, 0);
    SetLength(Tags, 0);
    for i:=0 to Values.Num_Surfaces-1 do
      with Surfaces[i] do begin
        SetLength(Shaders, 0);
        SetLength(Triangles, 0);
        SetLength(TextureCoords, 0);
        SetLength(Vertex, 0);
      end;
    SetLength(Surfaces, 0);
    with Values do begin
      Num_Frames := 0;
      Num_Tags := 0;
      Num_Surfaces := 0;
      Num_Skins := 0;
    end;
  end;
  // textures uit een shader-bestand
  for i:=0 to Header.Values.Num_Surfaces-1 do
    Shaders.DeleteShader(Header.Surfaces[i].Shaders[0].Shader_Index);
(*
  for i:=0 to Length(ShaderFile)-1 do
    SetLength(ShaderFile[i].Textures, 0);
  SetLength(ShaderFile, 0);
*)
(*
  for i:=0 to Length(GameShaders)-1 do
    SetLength(GameShaders[i].Shaders, 0);
  SetLength(GameShaders, 0);
*)
end;

procedure TMD3.Clear;
begin
  ClearMemory;
end;




//------------------------------------------------------------------------------
function TMD3.Size_Header: cardinal;
begin
  Result := SizeOf(THeader1);
end;

function TMD3.Size_Frames: cardinal;
begin
  Result := Header.Values.Num_Frames * SizeOf(TFrame);
end;

function TMD3.Size_Tags: cardinal;
begin
  Result := Header.Values.Num_Frames * Header.Values.Num_Tags * SizeOf(TTag);
end;

function TMD3.Size_Surfaces: cardinal;
var s: integer;
begin
  Result := 0;
  for s:=0 to Header.Values.Num_Surfaces-1 do Inc(Result, Size_Surface(s));
end;

function TMD3.Size_File: cardinal;
begin
  Result := Size_Header + Size_Frames + Size_Tags + Size_Surfaces;
end;

function TMD3.Size_SurfaceHeader: cardinal;
begin
  Result := SizeOf(TSurface1);
end;

function TMD3.Size_SurfaceShaders(SurfaceIndex: cardinal): cardinal;
var Size: cardinal;
begin
  Result := 0;
  if SurfaceIndex < 0 then Exit;
  if SurfaceIndex > Header.Values.Num_Surfaces-1 then Exit;
  Size := Header.Surfaces[SurfaceIndex].Values.Num_Shaders * SizeOf(TShader);
  Inc(Result, Size);
end;

function TMD3.Size_SurfaceTriangles(SurfaceIndex: cardinal): cardinal;
var Size: cardinal;
begin
  Result := 0;
  if SurfaceIndex < 0 then Exit;
  if SurfaceIndex > Header.Values.Num_Surfaces-1 then Exit;
  Size := Header.Surfaces[SurfaceIndex].Values.Num_Triangles * SizeOf(TTriangle);
  Inc(Result, Size);
end;

function TMD3.Size_SurfaceTexCoords(SurfaceIndex: cardinal): cardinal;
var Size: cardinal;
begin
  Result := 0;
  if SurfaceIndex < 0 then Exit;
  if SurfaceIndex > Header.Values.Num_Surfaces-1 then Exit;
  Size := Header.Surfaces[SurfaceIndex].Values.Num_Verts * SizeOf(TTextureCoords);
  Inc(Result, Size);
end;

function TMD3.Size_SurfaceVertex(SurfaceIndex: cardinal): cardinal;
var Size: cardinal;
begin
  Result := 0;
  if SurfaceIndex < 0 then Exit;
  if SurfaceIndex > Header.Values.Num_Surfaces-1 then Exit;
  Size := Header.Values.Num_Frames * Header.Surfaces[SurfaceIndex].Values.Num_Verts * SizeOf(TVertex);
  Inc(Result, Size);
end;

function TMD3.Size_Surface(SurfaceIndex: cardinal): cardinal;
begin
  Result := 0;
  if SurfaceIndex < 0 then Exit;
  if SurfaceIndex > Header.Values.Num_Surfaces-1 then Exit;
  Inc(Result, Size_SurfaceHeader);
  Inc(Result, Size_SurfaceShaders(SurfaceIndex));
  Inc(Result, Size_SurfaceTriangles(SurfaceIndex));
  Inc(Result, Size_SurfaceTexCoords(SurfaceIndex));
  Inc(Result, Size_SurfaceVertex(SurfaceIndex));
end;



//------------------------------------------------------------------------------
function TMD3.StringToQ3(const aString: string): q3string;
var Len, i: integer;
begin
  Len := Length(aString);
  if Len > MAX_QPATH then Len := MAX_QPATH;
  for i:=0 to Len-1 do Result[i] := aString[1+i];
  for i:=Len to MAX_QPATH-1 do Result[i] := chr(0);
end;

procedure TMD3.DecodeNormal(const Normal:word; var X, Y, Z: single);
var lat, lng: single;
begin
  //Decoding: (Code in q3tools/q3map/misc_model.c:InsertMD3Model)
  case Normal of
        0: begin
             X := 0.0;
             Y := 0.0;
             Z := 1.0;
           end;
    32768: begin
             X := 0.0;
             Y := 0.0;
             Z := -1.0;
           end;
  else
    lat := ((Normal shr 8) and $FF) / 255.0 * (2 * Pi );
    lng := (Normal and $FF) / 255.0 * (2 * Pi);
    X := cos(lat) * sin(lng);
    Y := sin(lat) * sin(lng);
    Z := cos(lng);
  end;
end;

procedure TMD3.EncodeNormal(const Normal: TVector; var Value: word);
var lng,lat: single;
    N: TVector;
begin
  N := UnitVector(Normal);
  if AlmostSameVector(N, ZAxisVector, 0.01) then
    Value := 0
  else
    if AlmostSameVector(N, NegativeZAxisVector, 0.01) then
      Value := 32768
    else begin
{      lng := ATan2(N.Y,N.X) * 255.0 / (2 * Pi);
      lat := ArcCos(N.Z) * 255.0 / (2 * Pi);
}
      lat := uCalc.ATan2(N.Y,N.X) * constRadToDeg / 360*255;
      lng := ArcCos(N.Z) * constRadToDeg / 360*255;
(*
x, y, z = normal
lng = math.acos(z)
lat = math.acos(x / math.sin(lng))
retval = ((lat & 0xFF) << 8) | (lng & 0xFF)
*)
{
lng := ArcCos(N.Z)* 255.0 / (2 * Pi);
lat := ArcCos(N.X/Sin(lng))* 255.0 / (2 * Pi);
}
      Value := ((Round(lat) and $FF) shl 8) + (Round(lng) and $FF);
    end;
end;

procedure TMD3.EncodeNormal(const X, Y, Z: single; var Value: word);
var N: TVector;
begin
  N := Vector(X,Y,Z);
  EncodeNormal(N, Value);
end;



function TMD3.IsMD3: boolean;
begin
  Result := (Header.Values.Ident = IDP3);
end;


procedure TMD3.TexCoords_SwapST_UV(SurfaceIndex: cardinal);
var j: integer;
begin
  if SurfaceIndex < 0 then Exit;
  if SurfaceIndex > Header.Values.Num_Surfaces-1 then Exit;
  for j:=0 to Header.Surfaces[SurfaceIndex].Values.Num_Verts-1 do
    Header.Surfaces[SurfaceIndex].TextureCoords[j].T := 1.0 - Header.Surfaces[SurfaceIndex].TextureCoords[j].T;
end;


procedure TMD3.ChangeShader(Index: Integer; Name: string);
var L: integer;
begin
  if Header.Values.Num_Surfaces < 1 then Exit;
  if (Index < 0) or (Index >= Header.Values.Num_Surfaces) then Exit;
  if Header.Surfaces[Index].Values.Num_Shaders < 1 then Exit;
  // string overnemen
  for L:=1 to Length(Name) do
    Header.Surfaces[Index].Shaders[0].Name[L-1] := Name[L];
  // opvullen met nullen
  for L:=Length(Name)+1 to MAX_QPATH-1 do
    Header.Surfaces[Index].Shaders[0].Name[L-1] := chr(0);
end;




//------------------------------------------------------------------------------
function TMD3.LoadFromFile(Filename: string): boolean;
var N, Size: cardinal;
    i,j,f: integer;
    FP: Int64;
    strX,strY,strZ, strV: string;
begin
  Result := false;
  Clear; //clear model memory
  SetLength(SkinShaders, 0);  //skins verwijderen

  // stream handle
  Fopen := TFileStream.Create(Filename, fmOpenRead);
  try
    try
      N := Fopen.Read(Header.Values, Size_Header);
      if N<>Size_Header then Exit;
      Result := IsMD3;
      if not Result then Exit;

      // Frames laden
      Fopen.Position := Header.Values.Ofs_Frames;
      SetLength(Header.Frames, Header.Values.Num_Frames);
      Size := Size_Frames;
      N := Fopen.Read(Header.Frames[0], Size);
      Result := (N=Size);
      if not Result then Exit;
      
{ ischbinz fix tegen foute boundingbox:
Header.Frames[0].Min_Bounds := vector(-7.526827, -8.115809, -0.126671);
Header.Frames[0].Max_Bounds := vector(8.078770, 7.489825, 18.962357);
Header.Frames[0].Local_Origin := vector(0,0,0);
Header.Frames[0].Radius := 17.7985763549805;
}
      // Tags laden
      if Header.Values.Num_Tags > 0 then begin
        Fopen.Position := Header.Values.Ofs_Tags;
        // (lees in totaal 'Size_Tags' bytes aan data)
        SetLength(Header.Tags, Header.Values.Num_Frames * Header.Values.Num_Tags);
        for f:=0 to Header.Values.Num_Frames-1 do begin
          Size := Header.Values.Num_Tags * SizeOf(TTag);
          j := f * Header.Values.Num_Tags;
          N := Fopen.Read(Header.Tags[j], Size);
          Result := (N=Size);
          if not Result then Exit;
        end;
      end;

      // Surfaces laden
      SetLength(Header.Surfaces, Header.Values.Num_Surfaces);
      FP := Header.Values.Ofs_Surfaces;
      for i:=0 to Header.Values.Num_Surfaces-1 do begin
        Fopen.Position := FP;
        Size := Size_SurfaceHeader;
        N := Fopen.Read(Header.Surfaces[i].Values, Size);
        Result := (N=Size);
        if not Result then Exit;
        // Shaders
        Fopen.Position := FP + Header.Surfaces[i].Values.Ofs_Shaders;
        SetLength(Header.Surfaces[i].Shaders, Header.Surfaces[i].Values.Num_Shaders);
        Size := Size_SurfaceShaders(i);
        N := Fopen.Read(Header.Surfaces[i].Shaders[0], Size);
        Result := (N=Size);
        if not Result then Exit;
        // lege shaders array herstellen..
        if Header.Surfaces[i].Values.Num_Shaders=0 then begin
          Header.Surfaces[i].Values.Num_Shaders := 1;
          SetLength(Header.Surfaces[i].Shaders, Header.Surfaces[i].Values.Num_Shaders);
        end;
        // Triangles
        Fopen.Position := FP + Header.Surfaces[i].Values.Ofs_Triangles;
        SetLength(Header.Surfaces[i].Triangles, Header.Surfaces[i].Values.Num_Triangles);
        Size := Size_SurfaceTriangles(i);
        N := Fopen.Read(Header.Surfaces[i].Triangles[0], Size);
        Result := (N=Size);
        if not Result then Exit;
        // TextureCoords
        Fopen.Position := FP + Header.Surfaces[i].Values.Ofs_ST;
        SetLength(Header.Surfaces[i].TextureCoords, Header.Surfaces[i].Values.Num_Verts);
        Size := Size_SurfaceTexCoords(i);
        N := Fopen.Read(Header.Surfaces[i].TextureCoords[0], Size);
        Result := (N=Size);
        if not Result then Exit;
        // texturemapping van ST naar UV converteren
        TexCoords_SwapST_UV(i);
        // Vertex
        Fopen.Position := FP + Header.Surfaces[i].Values.Ofs_XYZNormal;
        SetLength(Header.Surfaces[i].Vertex, Header.Surfaces[i].Values.Num_Verts * Header.Surfaces[i].Values.Num_Frames);
        Size := Size_SurfaceVertex(i);
        N := Fopen.Read(Header.Surfaces[i].Vertex[0], Size);
        Result := (N=Size);
        if not Result then Exit;
        // filepointer op volgende surface-blok
        FP := FP + Header.Surfaces[i].Values.Ofs_End;
      end;

    except
      //
    end;
  finally
    Fopen.Free;
  end;
end;


//------------------------------------------------------------------------------
function TMD3.SaveToFile(Filename: string): boolean;
var N,i,j, Size: integer;
begin
  // bestand opslaan
  Fsave := TFileStream.Create(Filename, fmCreate);
  try
    try
      // offsets instellen
      Header.Values.Ofs_Frames := Size_Header;
      Header.Values.Ofs_Tags := Header.Values.Ofs_Frames + Size_Frames;
      Header.Values.Ofs_Surfaces := Header.Values.Ofs_Tags + Size_Tags;
      Header.Values.Ofs_EOF := Header.Values.Ofs_Surfaces + Size_Surfaces;
      for i:=0 to Header.Values.Num_Surfaces-1 do begin
        Header.Surfaces[i].Values.Ofs_Shaders := Size_SurfaceHeader;
        Header.Surfaces[i].Values.Ofs_Triangles := Header.Surfaces[i].Values.Ofs_Shaders + Size_SurfaceShaders(i);
        Header.Surfaces[i].Values.Ofs_ST := Header.Surfaces[i].Values.Ofs_Triangles + Size_SurfaceTriangles(i);
        Header.Surfaces[i].Values.Ofs_XYZNormal := Header.Surfaces[i].Values.Ofs_ST + Size_SurfaceTexCoords(i);
        Header.Surfaces[i].Values.Ofs_End := Header.Surfaces[i].Values.Ofs_XYZNormal + Size_SurfaceVertex(i);
      end;

      // header
      Size := Size_Header;
      Fsave.WriteBuffer(Header.Values, Size);
      // frames
      Size := Size_Frames;
      Fsave.WriteBuffer(Header.Frames[0], Size);
      // tags
      Size := Size_Tags;
      Fsave.WriteBuffer(Header.Tags[0], Size);
      // surfaces
      for i:=0 to Header.Values.Num_Surfaces-1 do begin
        // surface header
        Size := Size_SurfaceHeader;
        Fsave.WriteBuffer(Header.Surfaces[i].Values, Size);
        // surface shaders
        Size := Size_SurfaceShaders(i);
        Fsave.WriteBuffer(Header.Surfaces[i].Shaders[0], Size);
        // surface triangles
        Size := Size_SurfaceTriangles(i);
        Fsave.WriteBuffer(Header.Surfaces[i].Triangles[0], Size);

        // surface texture-coordinates
        // texturemapping van UV naar ST converteren
        TexCoords_SwapST_UV(i);
        // schrijven
        Size := Size_SurfaceTexCoords(i);
        Fsave.WriteBuffer(Header.Surfaces[i].TextureCoords[0], Size);
        // texturemapping van ST naar UV converteren
        TexCoords_SwapST_UV(i);

        // surface vertex
        Size := Size_SurfaceVertex(i);
        Fsave.WriteBuffer(Header.Surfaces[i].Vertex[0], Size);
      end;
    except
    end;
  finally
    Fsave.Free;
  end;
end;



//------------------------------------------------------------------------------
procedure TMD3.AddTags(Filename: string);
var Ftags: TFileStream;
    TagsHeader: TTagFileHeader;
    ID, N, TagsInFile,Ntags, Nframes, Size: cardinal;
    t,f: integer;
    newTags: packed array of TTag;
begin
  Ftags := TFileStream.Create(Filename, fmOpenRead);
  try
    Ftags.Position := 0;
    N := Ftags.Read(TagsHeader,SizeOf(TTagFileHeader));
    if N<>SizeOf(TTagFileHeader) then Exit;
    if TagsHeader.Ident<>TAG3 then Exit;
    if TagsHeader.Version<>1 then Exit;
    if TagsHeader.Num_Tags=0 then Exit;

    // het aantal toe te voegen tags bepalen (en array vergroten)
    TagsInFile := TagsHeader.Num_Tags;
    Ntags := Header.Values.Num_Tags;
    Inc(Header.Values.Num_Tags, TagsInFile);
    Nframes := Header.Values.Num_Frames;
    SetLength(Header.Tags, (Ntags+TagsInFile)*Nframes);

    // de tags lezen
    SetLength(newTags, TagsInFile);
    Size := TagsInFile * SizeOf(TTag);
    Ftags.Position := $10; //4*cardinal
    N := Ftags.Read(newTags[0], Size);
    if N<>Size then Exit;

    for f:=Nframes-1 downto 0 do begin
      if Ntags>0 then begin
        for t:=Ntags-1 downto 0 do begin
          Header.Tags[f*(Ntags+TagsInFile)+t] := Header.Tags[f*Ntags+t];
          for N:=0 to TagsInFile-1 do
            Header.Tags[f*(Ntags+TagsInFile)+Ntags+N] := newTags[N];
        end;
      end else begin
        for N:=0 to TagsInFile-1 do
          Header.Tags[f*TagsInFile+N] := newTags[N];
      end;
    end;
  finally
    SetLength(newTags, 0);
    Ftags.Free;
  end;
end;

procedure TMD3.AddTag(const aTag: TTag);
var Ntags,t, Nframes,f, Size: integer;
begin
  // 1 tag toevoegen (en array vergroten)
  Ntags := Header.Values.Num_Tags;
  Inc(Header.Values.Num_Tags, 1);
  Nframes := Header.Values.Num_Frames;
  SetLength(Header.Tags, (Ntags+1)*Nframes);
  for f:=Nframes-1 downto 0 do
    for t:=0 to Header.Values.Num_Tags-1 do begin
      Header.Tags[f*(Ntags+1)+t] := Header.Tags[f*Ntags+t];
      Header.Tags[f*(Ntags+1)+Ntags] := aTag;
      {Header.Tags[f*(Ntags+1)+Ntags].Name := aTag.Name;
      Header.Tags[f*(Ntags+1)+Ntags].Origin := aTag.Origin;
      Header.Tags[f*(Ntags+1)+Ntags].Axis[0] := aTag.Axis[0];
      Header.Tags[f*(Ntags+1)+Ntags].Axis[1] := aTag.Axis[1];
      Header.Tags[f*(Ntags+1)+Ntags].Axis[2] := aTag.Axis[2];}
    end;
end;

procedure TMD3.SaveTags(Filename: string);
var Ftags: TFileStream;
    TagsHeader: TTagFileHeader;
    t: integer;
    Size: cardinal;
begin
  if Header.Values.Num_Tags=0 then Exit;
  Ftags := TFileStream.Create(Filename, fmCreate);
  try
    // header vullen
    TagsHeader.Ident := TAG3;
    TagsHeader.Version := 1;
    TagsHeader.Num_Tags := Header.Values.Num_Tags;
    TagsHeader.Ofs_End := SizeOf(TTagFileHeader) + (Header.Values.Num_Tags * SizeOf(TTag));
    //
    Size := SizeOf(TTagFileHeader);
    Ftags.WriteBuffer(TagsHeader, Size);
    for t:=0 to Header.Values.Num_Tags-1 do begin
      Size := SizeOf(TTag);
      Ftags.WriteBuffer(Header.Tags[t], Size);
    end;
  finally
    Ftags.Free;
  end;
end;

procedure TMD3.TagsInvertX;
var Ntags,t, Nframes,f: cardinal;
begin
  Ntags := Header.Values.Num_Tags;
  if Ntags=0 then Exit;
  Nframes := Header.Values.Num_Frames;
  if Nframes=0 then Exit;
  for f:=Nframes-1 downto 0 do
    for t:=0 to Ntags-1 do
      Header.Tags[f*Ntags+t].Axis[0] := InverseVector(Header.Tags[f*Ntags+t].Axis[0]);
end;

procedure TMD3.TagsInvertY;
var Ntags,t, Nframes,f: cardinal;
begin
  Ntags := Header.Values.Num_Tags;
  if Ntags=0 then Exit;
  Nframes := Header.Values.Num_Frames;
  if Nframes=0 then Exit;
  for f:=Nframes-1 downto 0 do
    for t:=0 to Ntags-1 do
      Header.Tags[f*Ntags+t].Axis[1] := InverseVector(Header.Tags[f*Ntags+t].Axis[1]);
end;

procedure TMD3.TagsInvertZ;
var Ntags,t, Nframes,f: cardinal;
begin
  Ntags := Header.Values.Num_Tags;
  if Ntags=0 then Exit;
  Nframes := Header.Values.Num_Frames;
  if Nframes=0 then Exit;
  for f:=Nframes-1 downto 0 do
    for t:=0 to Ntags-1 do
      Header.Tags[f*Ntags+t].Axis[2] := InverseVector(Header.Tags[f*Ntags+t].Axis[2]);
end;

procedure TMD3.TagsSwapXY;
var Ntags,t, Nframes,f: cardinal;
    tmp: TVector;
begin
  Ntags := Header.Values.Num_Tags;
  if Ntags=0 then Exit;
  Nframes := Header.Values.Num_Frames;
  if Nframes=0 then Exit;
  for f:=Nframes-1 downto 0 do
    for t:=0 to Ntags-1 do begin
      tmp := Header.Tags[f*Ntags+t].Axis[0];
      Header.Tags[f*Ntags+t].Axis[0] := Header.Tags[f*Ntags+t].Axis[1];
      Header.Tags[f*Ntags+t].Axis[1] := tmp;
    end;
end;

procedure TMD3.TagsSwapXZ;
var Ntags,t, Nframes,f: cardinal;
    tmp: TVector;
begin
  Ntags := Header.Values.Num_Tags;
  if Ntags=0 then Exit;
  Nframes := Header.Values.Num_Frames;
  if Nframes=0 then Exit;
  for f:=Nframes-1 downto 0 do
    for t:=0 to Ntags-1 do begin
      tmp := Header.Tags[f*Ntags+t].Axis[0];
      Header.Tags[f*Ntags+t].Axis[0] := Header.Tags[f*Ntags+t].Axis[2];
      Header.Tags[f*Ntags+t].Axis[2] := tmp;
    end;
end;

procedure TMD3.TagsSwapYZ;
var Ntags,t, Nframes,f: cardinal;
    tmp: TVector;
begin
  Ntags := Header.Values.Num_Tags;
  if Ntags=0 then Exit;
  Nframes := Header.Values.Num_Frames;
  if Nframes=0 then Exit;
  for f:=Nframes-1 downto 0 do
    for t:=0 to Ntags-1 do begin
      tmp := Header.Tags[f*Ntags+t].Axis[1];
      Header.Tags[f*Ntags+t].Axis[1] := Header.Tags[f*Ntags+t].Axis[2];
      Header.Tags[f*Ntags+t].Axis[2] := tmp;
    end;
end;


//------------------------------------------------------------------------------
function TMD3.AddFrame(Filename: string; var ErrorString:string): boolean;
var Fopen: TFileStream;
    fn: string;
    N, Size: cardinal;
    i,j,f: integer;
    FP: Int64;
    strX,strY,strZ, strV, s1,s2: string;
    AddFromMD3 : TMD3;
begin
  Result := false;
  ErrorString := '';
  fn := ExtractFilename(Filename);

  AddFromMD3 := TMD3.Create;
  try
    AddFromMD3.ClearMemory; //clear model memory

    // stream handle
    Fopen := TFileStream.Create(Filename, fmOpenRead);
    try
      try
        // header
        N := Fopen.Read(AddFromMD3.Header.Values, SizeOf(THeader1));
        if N<>SizeOf(THeader1) then begin
          ErrorString := 'Could not read header: '+ fn;
          Exit;
        end;
        Result := AddFromMD3.IsMD3;
        if not Result then begin
          ErrorString := 'No MD3 format: '+ fn;
          Exit;
        end;
        // test of er tenminste 1 frame is..
        Result := (AddFromMD3.Header.Values.Num_Frames>0);
        if not Result then begin
          ErrorString := 'No frame-data: '+ fn;
          Exit;
        end;
        // test of het aantal tags gelijk is..
        Result := (AddFromMD3.Header.Values.Num_Tags = Header.Values.Num_Tags);
        if not Result then begin
          ErrorString := 'Number of tags not equal: '+ fn;
          Exit;
        end;

        // Frames laden
        Fopen.Position := AddFromMD3.Header.Values.Ofs_Frames;
        SetLength(AddFromMD3.Header.Frames, AddFromMD3.Header.Values.Num_Frames);
        Size := AddFromMD3.Header.Values.Num_Frames * SizeOf(TFrame);
        N := Fopen.Read(AddFromMD3.Header.Frames[0], Size);
        Result := (N=Size);
        if not Result then begin
          ErrorString := 'Error reading frame-data: '+ fn;
          Exit;
        end;

        // Tags laden
        if AddFromMD3.Header.Values.Num_Tags > 0 then begin
          Fopen.Position := AddFromMD3.Header.Values.Ofs_Tags;
          SetLength(AddFromMD3.Header.Tags, AddFromMD3.Header.Values.Num_Frames * AddFromMD3.Header.Values.Num_Tags);
          if AddFromMD3.Header.Values.Num_Tags>0 then
            for f:=0 to AddFromMD3.Header.Values.Num_Frames-1 do begin
              Size := AddFromMD3.Header.Values.Num_Tags * SizeOf(TTag);
              j := f * AddFromMD3.Header.Values.Num_Tags;
              N := Fopen.Read(AddFromMD3.Header.Tags[j], Size);
              Result := (N=Size);
              if not Result then begin
                ErrorString := 'Error reading tag-data: '+ fn;
                Exit;
              end;
              // bestaat deze tag ook in de geladen MD3??
              s1 := string(AddFromMD3.Header.Tags[j].Name);
              s2 := string(Header.Tags[j].Name);
              Result := (s1 = s2);
              if not Result then begin
                ErrorString := 'Tag "'+ s1 +'" found, expected "'+ s2 +'" in: '+ fn;
                Exit;
              end;
            end;
        end;

        // Surfaces laden
        SetLength(AddFromMD3.Header.Surfaces, AddFromMD3.Header.Values.Num_Surfaces);
        FP := AddFromMD3.Header.Values.Ofs_Surfaces;
        for i:=0 to AddFromMD3.Header.Values.Num_Surfaces-1 do begin
          Fopen.Position := FP;
          Size := SizeOf(TSurface1);
          N := Fopen.Read(AddFromMD3.Header.Surfaces[i].Values, Size);
          Result := (N=Size);
          if not Result then begin
            ErrorString := 'Error reading surface['+ IntToStr(i) +']-header: '+ fn;
            Exit;
          end;
          s1 := string(AddFromMD3.Header.Surfaces[i].Values.Name);
          // controleer of de MD3-to-add past bij de geladen MD3 op het form
          Result := (AddFromMD3.Header.Surfaces[i].Values.Num_Shaders = Header.Surfaces[i].Values.Num_Shaders);
          if not Result then begin
            ErrorString := 'Number of shaders not equal for surface["'+ s1 +'"]: '+ fn;
            Exit;
          end;

          Result := (AddFromMD3.Header.Surfaces[i].Values.Num_Triangles = Header.Surfaces[i].Values.Num_Triangles);
          if not Result then begin
            ErrorString := 'Number of triangles not equal for surface["'+ s1 +'"]: '+ fn;
            Exit;
          end;
          Result := (AddFromMD3.Header.Surfaces[i].Values.Num_Verts = Header.Surfaces[i].Values.Num_Verts);
          if not Result then begin
            ErrorString := 'Number of vertexes not equal for surface["'+ s1 +'"]: '+ fn;
            Exit;
          end;

          // Shaders...
          // Triangles...
          // TextureCoords...
          // Vertex
          Fopen.Position := FP + AddFromMD3.Header.Surfaces[i].Values.Ofs_XYZNormal;
          SetLength(AddFromMD3.Header.Surfaces[i].Vertex, AddFromMD3.Header.Surfaces[i].Values.Num_Verts * AddFromMD3.Header.Surfaces[i].Values.Num_Frames);
          Size := AddFromMD3.Header.Surfaces[i].Values.Num_Verts * AddFromMD3.Header.Surfaces[i].Values.Num_Frames * SizeOf(TVertex);
          N := Fopen.Read(AddFromMD3.Header.Surfaces[i].Vertex[0], Size);
          Result := (N=Size);
          if not Result then begin
            ErrorString := 'Error reading vertex-data for surface["'+ s1 +'"]: '+ fn;
            Exit;
          end;
          // filepointer op volgende surface-blok
          FP := FP + AddFromMD3.Header.Surfaces[i].Values.Ofs_End;
        end;

        // de gelezen data toevoegen aan de bestaande/geladen MD3:
        // Frames:
        Inc(Header.Values.Num_Frames, 1);  //!!
        SetLength(Header.Frames, Header.Values.Num_Frames);
        Header.Frames[Header.Values.Num_Frames-1] := AddFromMD3.Header.Frames[0];
        Header.Frames[Header.Values.Num_Frames-1].Name := 'C merged';
        // Tags:
        SetLength(Header.Tags, Header.Values.Num_Frames * Header.Values.Num_Tags);
        j := (Header.Values.Num_Frames-1) * Header.Values.Num_Tags;
        for i:=0 to Header.Values.Num_Tags-1 do  //maar 1 frame overnemen
          Header.Tags[j+i] := AddFromMD3.Header.Tags[i];
        // Surfaces:
        for i:=0 to Header.Values.Num_Surfaces-1 do begin
          //Inc(Header.Surfaces[i].Values.Num_Frames, 1);  //!!
          Header.Surfaces[i].Values.Num_Frames := Header.Values.Num_Frames;
          SetLength(Header.Surfaces[i].Vertex, Header.Surfaces[i].Values.Num_Verts * Header.Surfaces[i].Values.Num_Frames);
          f := Header.Surfaces[i].Values.Num_Verts * (Header.Surfaces[i].Values.Num_Frames-1);
          for j:=0 to Header.Surfaces[i].Values.Num_Verts-1 do
            Header.Surfaces[i].Vertex[f+j] := AddFromMD3.Header.Surfaces[i].Vertex[j];
        end;

      except
        //
      end;
    finally
      Fopen.Free;
    end;
  finally
    AddFromMD3.Free;
  end;
end;

function TMD3.AddFrames(Filename:string;  var ErrorString:string): boolean;
var Fopen: TFileStream;
    fn: string;
    N, Size: cardinal;
    i,j,f, OldFrameCount,NewFrameCount,frame: integer;
    FP: Int64;
    strX,strY,strZ, strV, s1,s2: string;
    AddFromMD3 : TMD3;
begin
  Result := false;
  ErrorString := '';
  fn := ExtractFilename(Filename);

  AddFromMD3 := TMD3.Create;
  try
    AddFromMD3.ClearMemory; //clear model memory

    // stream handle
    Fopen := TFileStream.Create(Filename, fmOpenRead);
    try
      try
        // header
        N := Fopen.Read(AddFromMD3.Header.Values, SizeOf(THeader1));
        if N<>SizeOf(THeader1) then begin
          ErrorString := 'Could not read header: '+ fn;
          Exit;
        end;
        Result := AddFromMD3.IsMD3;
        if not Result then begin
          ErrorString := 'No MD3 format: '+ fn;
          Exit;
        end;
        // test of er tenminste 1 frame is..
        Result := (AddFromMD3.Header.Values.Num_Frames>0);
        if not Result then begin
          ErrorString := 'No frame-data: '+ fn;
          Exit;
        end;
        // test of het aantal tags gelijk is..
        Result := (AddFromMD3.Header.Values.Num_Tags = Header.Values.Num_Tags);
        if not Result then begin
          ErrorString := 'Number of tags not equal: '+ fn;
          Exit;
        end;

        // Frames laden
        Fopen.Position := AddFromMD3.Header.Values.Ofs_Frames;
        SetLength(AddFromMD3.Header.Frames, AddFromMD3.Header.Values.Num_Frames);
        Size := AddFromMD3.Header.Values.Num_Frames * SizeOf(TFrame);
        N := Fopen.Read(AddFromMD3.Header.Frames[0], Size);
        Result := (N=Size);
        if not Result then begin
          ErrorString := 'Error reading frame-data: '+ fn;
          Exit;
        end;

        // Tags laden
        if AddFromMD3.Header.Values.Num_Tags > 0 then begin
          Fopen.Position := AddFromMD3.Header.Values.Ofs_Tags;
          SetLength(AddFromMD3.Header.Tags, AddFromMD3.Header.Values.Num_Frames * AddFromMD3.Header.Values.Num_Tags);
          if AddFromMD3.Header.Values.Num_Tags>0 then
            for f:=0 to AddFromMD3.Header.Values.Num_Frames-1 do begin
              Size := AddFromMD3.Header.Values.Num_Tags * SizeOf(TTag);
              j := f * AddFromMD3.Header.Values.Num_Tags;
              N := Fopen.Read(AddFromMD3.Header.Tags[j], Size);
              Result := (N=Size);
              if not Result then begin
                ErrorString := 'Error reading tag-data: '+ fn;
                Exit;
              end;
              // bestaat deze tag ook in de geladen MD3??
              s1 := string(AddFromMD3.Header.Tags[j].Name);
              s2 := string(Header.Tags[(j mod AddFromMD3.Header.Values.Num_Tags)].Name);
              Result := (s1 = s2);
              if not Result then begin
                ErrorString := 'Tag "'+ s1 +'" found, expected "'+ s2 +'" in: '+ fn;
                Exit;
              end;
            end;
        end;

        // Surfaces laden
        SetLength(AddFromMD3.Header.Surfaces, AddFromMD3.Header.Values.Num_Surfaces);
        FP := AddFromMD3.Header.Values.Ofs_Surfaces;
        for i:=0 to AddFromMD3.Header.Values.Num_Surfaces-1 do begin
          Fopen.Position := FP;
          Size := SizeOf(TSurface1);
          N := Fopen.Read(AddFromMD3.Header.Surfaces[i].Values, Size);
          Result := (N=Size);
          if not Result then begin
            ErrorString := 'Error reading surface['+ IntToStr(i) +']-header: '+ fn;
            Exit;
          end;
          s1 := string(AddFromMD3.Header.Surfaces[i].Values.Name);
          // controleer of de MD3-to-add past bij de geladen MD3 op het form
          Result := (AddFromMD3.Header.Surfaces[i].Values.Num_Shaders = Header.Surfaces[i].Values.Num_Shaders);
          if not Result then begin
            ErrorString := 'Number of shaders not equal for surface["'+ s1 +'"]: '+ fn;
            Exit;
          end;
          Result := (AddFromMD3.Header.Surfaces[i].Values.Num_Triangles = Header.Surfaces[i].Values.Num_Triangles);
          if not Result then begin
            ErrorString := 'Number of triangles not equal for surface["'+ s1 +'"]: '+ fn;
            Exit;
          end;
          Result := (AddFromMD3.Header.Surfaces[i].Values.Num_Verts = Header.Surfaces[i].Values.Num_Verts);
          if not Result then begin
            ErrorString := 'Number of vertexes not equal for surface["'+ s1 +'"]: '+ fn;
            Exit;
          end;
          // Shaders...
          // Triangles...
          // TextureCoords...
          // Vertex
          Fopen.Position := FP + AddFromMD3.Header.Surfaces[i].Values.Ofs_XYZNormal;
          SetLength(AddFromMD3.Header.Surfaces[i].Vertex, AddFromMD3.Header.Surfaces[i].Values.Num_Verts * AddFromMD3.Header.Surfaces[i].Values.Num_Frames);
          Size := AddFromMD3.Header.Surfaces[i].Values.Num_Verts * AddFromMD3.Header.Surfaces[i].Values.Num_Frames * SizeOf(TVertex);
          N := Fopen.Read(AddFromMD3.Header.Surfaces[i].Vertex[0], Size);
          Result := (N=Size);
          if not Result then begin
            ErrorString := 'Error reading vertex-data for surface["'+ s1 +'"]: '+ fn;
            Exit;
          end;
          // filepointer op volgende surface-blok
          FP := FP + AddFromMD3.Header.Surfaces[i].Values.Ofs_End;
        end;

        // de gelezen data toevoegen aan de bestaande/geladen MD3:
        // Frames:
        OldFrameCount := Header.Values.Num_Frames;
        NewFrameCount := OldFrameCount + AddFromMD3.Header.Values.Num_Frames;
        Header.Values.Num_Frames := NewFrameCount;
        SetLength(Header.Frames, NewFrameCount);
        for frame:=0 to AddFromMD3.Header.Values.Num_Frames-1 do begin
          Header.Frames[OldFrameCount+frame] := AddFromMD3.Header.Frames[frame];
          Header.Frames[OldFrameCount+frame].Name := 'C merged';
        end;
        // Tags:
        SetLength(Header.Tags, NewFrameCount * Header.Values.Num_Tags);
        for frame:=0 to AddFromMD3.Header.Values.Num_Frames-1 do begin
          j := (OldFrameCount+frame) * Header.Values.Num_Tags;
          for i:=0 to Header.Values.Num_Tags-1 do
            Header.Tags[j+i] := AddFromMD3.Header.Tags[(frame*Header.Values.Num_Tags)+i];
        end;
        // Surfaces:
        for i:=0 to Header.Values.Num_Surfaces-1 do begin
          //Inc(Header.Surfaces[i].Values.Num_Frames, 1);  //!!
          Header.Surfaces[i].Values.Num_Frames := NewFrameCount;
          SetLength(Header.Surfaces[i].Vertex, Header.Surfaces[i].Values.Num_Verts * Header.Surfaces[i].Values.Num_Frames);
          for frame:=0 to AddFromMD3.Header.Values.Num_Frames-1 do begin
            f := Header.Surfaces[i].Values.Num_Verts * (OldFrameCount+frame);
            for j:=0 to Header.Surfaces[i].Values.Num_Verts-1 do
              Header.Surfaces[i].Vertex[f+j] := AddFromMD3.Header.Surfaces[i].Vertex[(frame*Header.Surfaces[i].Values.Num_Verts)+j];
          end;
        end;
      except
        //
      end;
    finally
      Fopen.Free;
    end;
  finally
    AddFromMD3.Free;
  end;
end;

function TMD3.InsertFrameAt(FrameNr: cardinal; Filename: string): boolean;
begin
  //
end;

function TMD3.DeleteFrame(FrameNr: cardinal): boolean;
var i,j,k,f,f2,t: integer;
begin
  if Header.Values.Num_Frames = 1 then Exit; // altijd 1 frame laten bestaan
  if FrameNr < 0 then Exit;
  if FrameNr > Header.Values.Num_Frames-1 then Exit;

  // Frames:
  for i:=FrameNr to Header.Values.Num_Frames-1-1 do
    Header.Frames[i] := Header.Frames[i+1];
  SetLength(Header.Frames, Header.Values.Num_Frames-1);
  // Tags:
  for i:=FrameNr to Header.Values.Num_Frames-1-1 do
    for t:=0 to Header.Values.Num_Tags-1 do
      Header.Tags[i*Header.Values.Num_Tags+t] := Header.Tags[(i+1)*Header.Values.Num_Tags+t];
    //Move(Header.Tags[i+1], Header.Tags[i], SizeOf(TTag));
  SetLength(Header.Tags, (Header.Values.Num_Frames-1) * Header.Values.Num_Tags);
  // Surfaces:
  for i:=0 to Header.Values.Num_Surfaces-1 do begin
    Header.Surfaces[i].Values.Num_Frames := Header.Values.Num_Frames-1;
    for k:=FrameNr to Header.Values.Num_Frames-1-1 do begin
      f := k * Header.Surfaces[i].Values.Num_Verts;
      f2 := (k+1) * Header.Surfaces[i].Values.Num_Verts;
      for j:=0 to Header.Surfaces[i].Values.Num_Verts-1 do
        Header.Surfaces[i].Vertex[f+j] := Header.Surfaces[i].Vertex[f2+j];
    end;
  end;

  Dec(Header.Values.Num_Frames);
end;





procedure TMD3.InitShaders;
begin
  //
end;

procedure TMD3.FreeShaders;
begin
  //
end;

function TMD3.IsTextured: boolean;
begin
  //
end;

procedure TMD3.Render;
begin
  //
end;


procedure TMD3.FlipXcoords;
var s,v,nv,f,t,nt: integer;
    N: Word;
    x,y,z, tmp: single;
    Vec: TVector;
begin
  // vertex
  for s:=0 to Header.Values.Num_Surfaces-1 do begin
    nv := Header.Surfaces[s].Values.Num_Verts;
    for f:=0 to Header.Values.Num_Frames-1 do begin
      // frames
{      Header.Frames[f].Min_Bounds.X := -Header.Frames[f].Min_Bounds.X;
      Header.Frames[f].Max_Bounds.X := -Header.Frames[f].Max_Bounds.X;}
      tmp := Header.Frames[f].Min_Bounds.X;
      Header.Frames[f].Min_Bounds.X := -Header.Frames[f].Max_Bounds.X;
      Header.Frames[f].Max_Bounds.X := -tmp;
      Header.Frames[f].Local_Origin.X := -Header.Frames[f].Local_Origin.X;
      // vertex
      for v:=0 to Header.Surfaces[s].Values.Num_Verts-1 do begin
        // position
        Header.Surfaces[s].Vertex[f*nv+v].X := -Header.Surfaces[s].Vertex[f*nv+v].X;
        // normal
        N := Header.Surfaces[s].Vertex[f*nv+v].Normal;
        DecodeNormal(N,x,y,z);
        if x<>0.0 then x:=-x;
        EncodeNormal(x,y,z,N);
        Header.Surfaces[s].Vertex[f*nv+v].Normal := N;
      end;
    end;
  end;
  // tags
  nt := Header.Values.Num_Tags;
  for f:=0 to Header.Values.Num_Frames-1 do
    for t:=0 to Header.Values.Num_Tags-1 do begin
      Header.Tags[f*nt+t].Origin.X := -Header.Tags[f*nt+t].Origin.X;
      Header.Tags[f*nt+t].Axis[0].X := -Header.Tags[f*nt+t].Axis[0].X;
      Header.Tags[f*nt+t].Axis[1].X := -Header.Tags[f*nt+t].Axis[1].X;
      Header.Tags[f*nt+t].Axis[2].X := -Header.Tags[f*nt+t].Axis[2].X;
    end;
  FlipWinding;
end;

procedure TMD3.FlipYcoords;
var s,v,nv,f,t,nt: integer;
    N: Word;
    x,y,z, tmp: single;
    Vec: TVector;
begin
  // vertex
  for s:=0 to Header.Values.Num_Surfaces-1 do begin
    nv := Header.Surfaces[s].Values.Num_Verts;
    for f:=0 to Header.Values.Num_Frames-1 do begin
      // frames
{      Header.Frames[f].Min_Bounds.Y := -Header.Frames[f].Min_Bounds.Y;
      Header.Frames[f].Max_Bounds.Y := -Header.Frames[f].Max_Bounds.Y;}
      tmp := Header.Frames[f].Min_Bounds.Y;
      Header.Frames[f].Min_Bounds.Y := -Header.Frames[f].Max_Bounds.Y;
      Header.Frames[f].Max_Bounds.Y := -tmp;
      Header.Frames[f].Local_Origin.Y := -Header.Frames[f].Local_Origin.Y;
      // vertex
      for v:=0 to Header.Surfaces[s].Values.Num_Verts-1 do begin
        // position
        Header.Surfaces[s].Vertex[f*nv+v].Y := -Header.Surfaces[s].Vertex[f*nv+v].Y;
        // normal
        N := Header.Surfaces[s].Vertex[f*nv+v].Normal;
        DecodeNormal(N,x,y,z);
        if y<>0.0 then y:=-y;
        EncodeNormal(x,y,z,N);
        Header.Surfaces[s].Vertex[f*nv+v].Normal := N;
      end;
    end;
  end;
  // tags
  nt := Header.Values.Num_Tags;
  for f:=0 to Header.Values.Num_Frames-1 do
    for t:=0 to Header.Values.Num_Tags-1 do begin
      Header.Tags[f*nt+t].Origin.Y := -Header.Tags[f*nt+t].Origin.Y;
      Header.Tags[f*nt+t].Axis[0].Y := -Header.Tags[f*nt+t].Axis[0].Y;
      Header.Tags[f*nt+t].Axis[1].Y := -Header.Tags[f*nt+t].Axis[1].Y;
      Header.Tags[f*nt+t].Axis[2].Y := -Header.Tags[f*nt+t].Axis[2].Y;
    end;
  FlipWinding;
end;

procedure TMD3.FlipZcoords;
var s,v,nv,f,t,nt: integer;
    N: Word;
    x,y,z, tmp: single;
    Vec: TVector;
begin
  // vertex
  for s:=0 to Header.Values.Num_Surfaces-1 do begin
    nv := Header.Surfaces[s].Values.Num_Verts;
    for f:=0 to Header.Values.Num_Frames-1 do begin
      // frames
{      Header.Frames[f].Min_Bounds.Z := -Header.Frames[f].Min_Bounds.Z;
      Header.Frames[f].Max_Bounds.Z := -Header.Frames[f].Max_Bounds.Z;}
      tmp := Header.Frames[f].Min_Bounds.Z;
      Header.Frames[f].Min_Bounds.Z := -Header.Frames[f].Max_Bounds.Z;
      Header.Frames[f].Max_Bounds.Z := -tmp;
      Header.Frames[f].Local_Origin.Z := -Header.Frames[f].Local_Origin.Z;
      // vertex
      for v:=0 to Header.Surfaces[s].Values.Num_Verts-1 do begin
        // position
        Header.Surfaces[s].Vertex[f*nv+v].Z := -Header.Surfaces[s].Vertex[f*nv+v].Z;
        // normal
        N := Header.Surfaces[s].Vertex[f*nv+v].Normal;
        DecodeNormal(N,x,y,z);
        if z<>0.0 then z:=-z;
        EncodeNormal(x,y,z,N);
        Header.Surfaces[s].Vertex[f*nv+v].Normal := N;
      end;
    end;
  end;
  // tags
  nt := Header.Values.Num_Tags;
  for f:=0 to Header.Values.Num_Frames-1 do
    for t:=0 to Header.Values.Num_Tags-1 do begin
      Header.Tags[f*nt+t].Origin.Z := -Header.Tags[f*nt+t].Origin.Z;
      Header.Tags[f*nt+t].Axis[0].Z := -Header.Tags[f*nt+t].Axis[0].Z;
      Header.Tags[f*nt+t].Axis[1].Z := -Header.Tags[f*nt+t].Axis[1].Z;
      Header.Tags[f*nt+t].Axis[2].Z := -Header.Tags[f*nt+t].Axis[2].Z;
    end;
  FlipWinding;
end;

procedure TMD3.FlipNormals;
var s,nv,f,v: integer;
    N: word;
    Vec: TVector;
    x,y,z: single;
begin
  // vertex
  for s:=0 to Header.Values.Num_Surfaces-1 do begin
    nv := Header.Surfaces[s].Values.Num_Verts;
    for f:=0 to Header.Values.Num_Frames-1 do
      for v:=0 to nv-1 do begin
        // normal
        N := Header.Surfaces[s].Vertex[f*nv+v].Normal;
        DecodeNormal(N,x,y,z);
        Vec := Vector(-x,-y,-z);
        EncodeNormal(Vec,N);
        Header.Surfaces[s].Vertex[f*nv+v].Normal := N;
      end;
  end;
//  FlipWinding;
end;

procedure TMD3.FlipWinding;
var s,t: integer;
    tmp: cardinal;
begin
  // flip winding CCW->CW, or CW->CCW
  for s:=0 to Header.Values.Num_Surfaces-1 do
    for t:=0 to Header.Surfaces[s].Values.Num_Triangles-1 do begin
      tmp := Header.Surfaces[s].Triangles[t].Index1;
      Header.Surfaces[s].Triangles[t].Index1 := Header.Surfaces[s].Triangles[t].Index3;
      Header.Surfaces[s].Triangles[t].Index3 := tmp;
    end;
end;


procedure TMD3.CalculateSurfaceNormals(SurfaceNr: integer);
var f,tr,nt,nv,nf: integer;
    vi1,vi2,vi3: cardinal;
    V1,V2,V3, Normal: TVector;
    N: word;
begin
  if Header.Values.Num_Surfaces=0 then Exit;
  if Header.Values.Num_Frames=0 then Exit;
  if (SurfaceNr<0) or (SurfaceNr>=Header.Values.Num_Surfaces) then Exit;
  nf := Header.Values.Num_Frames;
  for f:=0 to nf-1 do begin
    nt := Header.Surfaces[SurfaceNr].Values.Num_Triangles;
    nv := Header.Surfaces[SurfaceNr].Values.Num_Verts;
    for tr:=0 to nt-1 do begin
      vi1 := Header.Surfaces[SurfaceNr].Triangles[tr].Index1;
      vi2 := Header.Surfaces[SurfaceNr].Triangles[tr].Index2;
      vi3 := Header.Surfaces[SurfaceNr].Triangles[tr].Index3;
      with Header.Surfaces[SurfaceNr].Vertex[f*nv+vi1] do begin
        V1.X := X * MD3_XYZ_SCALE;
        V1.Y := Y * MD3_XYZ_SCALE;
        V1.Z := Z * MD3_XYZ_SCALE;
      end;
      with Header.Surfaces[SurfaceNr].Vertex[f*nv+vi2] do begin
        V2.X := X * MD3_XYZ_SCALE;
        V2.Y := Y * MD3_XYZ_SCALE;
        V2.Z := Z * MD3_XYZ_SCALE;
      end;
      with Header.Surfaces[SurfaceNr].Vertex[f*nv+vi3] do begin
        V3.X := X * MD3_XYZ_SCALE;
        V3.Y := Y * MD3_XYZ_SCALE;
        V3.Z := Z * MD3_XYZ_SCALE;
      end;
      Normal := PlaneNormal(V3,V2,V1);  // order reversed
      EncodeNormal(Normal, N);
      Header.Surfaces[SurfaceNr].Vertex[f*nv+vi1].Normal := N;
      Header.Surfaces[SurfaceNr].Vertex[f*nv+vi2].Normal := N;
      Header.Surfaces[SurfaceNr].Vertex[f*nv+vi3].Normal := N;
    end;
  end;
end;


procedure TMD3.WeldVertices(SurfaceNr:integer; Distance:Single);
type TIntArray = array of integer;
var NrWelt,i,f,nv,v,v2,vi,vi2: integer;
    welt: TIntArray;
    b: boolean;
    Position,Normal, Position2,Normal2, AvgNormal: TVector;
    nx,ny,nz: single;
    N: word;
begin
  //--- Weld the same vertices per surface
  try
    for f:=0 to Header.Values.Num_Frames-1 do begin
      nv := Header.Surfaces[SurfaceNr].Values.Num_Verts;
      for v:=0 to nv-1 do begin
        vi := f*nv+v;
        // vertex data
        Position.X := Header.Surfaces[SurfaceNr].Vertex[vi].X * MD3_XYZ_SCALE;
        Position.Y := Header.Surfaces[SurfaceNr].Vertex[vi].Y * MD3_XYZ_SCALE;
        Position.Z := Header.Surfaces[SurfaceNr].Vertex[vi].Z * MD3_XYZ_SCALE;
{        DecodeNormal(Header.Surfaces[SurfaceNr].Vertex[vi].Normal, nx,ny,nz);
        Normal := Vector(nx,ny,nz);
        // tbv gemiddelde normaal
        AvgNormal := Normal;}
        NrWelt := 1;
        SetLength(welt, NrWelt);
        welt[NrWelt-1] := vi;

        // zoeken in alle andere vertices..
        for v2:=v+1 to nv-1 do begin
          vi2 := f*nv+v2;
          // vertex data
          Position2.X := Header.Surfaces[SurfaceNr].Vertex[vi2].X * MD3_XYZ_SCALE;
          Position2.Y := Header.Surfaces[SurfaceNr].Vertex[vi2].Y * MD3_XYZ_SCALE;
          Position2.Z := Header.Surfaces[SurfaceNr].Vertex[vi2].Z * MD3_XYZ_SCALE;
{          DecodeNormal(Header.Surfaces[SurfaceNr].Vertex[vi2].Normal, nx,ny,nz);
          Normal2 := Vector(nx,ny,nz);}
          // zijn de punten bijna gelijk??
          if AlmostSameVector(Position, Position2, Distance) then begin
{            // gemiddelde normaal berekenen
            AvgNormal := AddVector(AvgNormal, Normal2);}
            // aan "versmolten" array toevoegen
            Inc(NrWelt);
            SetLength(welt, NrWelt);
            welt[NrWelt-1] := vi2;
          end;
        end;

{        // gemiddelde normaal berekenen
        AvgNormal := Scalevector(AvgNormal, 1/Length(welt));}
        for i:=0 to Length(welt)-1 do begin
          // weld
          Header.Surfaces[SurfaceNr].Vertex[welt[i]].X := Header.Surfaces[SurfaceNr].Vertex[welt[0]].X;
          Header.Surfaces[SurfaceNr].Vertex[welt[i]].Y := Header.Surfaces[SurfaceNr].Vertex[welt[0]].Y;
          Header.Surfaces[SurfaceNr].Vertex[welt[i]].Z := Header.Surfaces[SurfaceNr].Vertex[welt[0]].Z;

//          Header.Surfaces[SurfaceNr].Vertex[welt[i]].Normal := Header.Surfaces[SurfaceNr].Vertex[welt[0]].Normal;
{
          // smooth
          EncodeNormal(AvgNormal, N);
          Vertices[welt[i]].Normal := N;
}
        end;

      end;
    end;
  finally
    SetLength(welt, 0);
  end;
end;

procedure TMD3.SmoothSurface(SurfaceNr: integer);
type TIntArray = array of integer;
var NrWelt,i,f,nv,v,v2,vi,vi2: integer;
    welt: TIntArray;
    b: boolean;
    Position,Normal, Position2,Normal2, AvgNormal: TVector;
    nx,ny,nz: single;
    N: word;
begin
  //--- smooth the same vertices per surface
  try
    for f:=0 to Header.Values.Num_Frames-1 do begin
      nv := Header.Surfaces[SurfaceNr].Values.Num_Verts;
      for v:=0 to nv-1 do begin
        vi := f*nv+v;
        // vertex data
        Position.X := Header.Surfaces[SurfaceNr].Vertex[vi].X * MD3_XYZ_SCALE;
        Position.Y := Header.Surfaces[SurfaceNr].Vertex[vi].Y * MD3_XYZ_SCALE;
        Position.Z := Header.Surfaces[SurfaceNr].Vertex[vi].Z * MD3_XYZ_SCALE;
        DecodeNormal(Header.Surfaces[SurfaceNr].Vertex[vi].Normal, nx,ny,nz);
        Normal := Vector(nx,ny,nz);
        // tbv gemiddelde normaal
        AvgNormal := Normal;
        NrWelt := 1;
        SetLength(welt, NrWelt);
        welt[NrWelt-1] := vi;

        // zoeken in alle andere vertices..
        for v2:=v+1 to nv-1 do begin
          vi2 := f*nv+v2;
          // vertex data
          Position2.X := Header.Surfaces[SurfaceNr].Vertex[vi2].X * MD3_XYZ_SCALE;
          Position2.Y := Header.Surfaces[SurfaceNr].Vertex[vi2].Y * MD3_XYZ_SCALE;
          Position2.Z := Header.Surfaces[SurfaceNr].Vertex[vi2].Z * MD3_XYZ_SCALE;
          DecodeNormal(Header.Surfaces[SurfaceNr].Vertex[vi2].Normal, nx,ny,nz);
          Normal2 := Vector(nx,ny,nz);
          // zijn de punten bijna gelijk??
          if AlmostSameVector(Position, Position2, 0.02) then begin
            // gemiddelde normaal berekenen
            AvgNormal := AddVector(AvgNormal, Normal2);
            // aan "versmolten" array toevoegen
            Inc(NrWelt);
            SetLength(welt, NrWelt);
            welt[NrWelt-1] := vi2;
          end;
        end;

        // gemiddelde normaal berekenen
        AvgNormal := Scalevector(AvgNormal, 1/Length(welt));
        for i:=0 to Length(welt)-1 do begin
{          // weld
          Header.Surfaces[SurfaceNr].Vertex[welt[i]].X := Header.Surfaces[SurfaceNr].Vertex[welt[0]].X;
          Header.Surfaces[SurfaceNr].Vertex[welt[i]].Y := Header.Surfaces[SurfaceNr].Vertex[welt[0]].Y;
          Header.Surfaces[SurfaceNr].Vertex[welt[i]].Z := Header.Surfaces[SurfaceNr].Vertex[welt[0]].Z;}

          // smooth
          EncodeNormal(AvgNormal, N);
          Header.Surfaces[SurfaceNr].Vertex[welt[i]].Normal := N;
        end;

      end;
    end;
  finally
    SetLength(welt, 0);
  end;
end;


procedure TMD3.RemoveSurface(SurfaceNr: integer);
var s, i: integer;
begin
  if (SurfaceNr<0) or (SurfaceNr>=Header.Values.Num_Surfaces) then Exit;
  // deallocate the arrays..
  SetLength(Header.Surfaces[SurfaceNr].Shaders, 0);
  SetLength(Header.Surfaces[SurfaceNr].Triangles, 0);
  SetLength(Header.Surfaces[SurfaceNr].TextureCoords, 0);
  SetLength(Header.Surfaces[SurfaceNr].Vertex, 0);
  // remove the surface, and adjust the surfaces array
  for s:=SurfaceNr+1 to Header.Values.Num_Surfaces-1 do begin
    // surface header values
    Header.Surfaces[s-1].Values.Ident := Header.Surfaces[s].Values.Ident;
    Header.Surfaces[s-1].Values.Name := Header.Surfaces[s].Values.Name;
    Header.Surfaces[s-1].Values.Flags := Header.Surfaces[s].Values.Flags;
    Header.Surfaces[s-1].Values.Num_Frames := Header.Surfaces[s].Values.Num_Frames;
    Header.Surfaces[s-1].Values.Num_Shaders := Header.Surfaces[s].Values.Num_Shaders;
    Header.Surfaces[s-1].Values.Num_Verts := Header.Surfaces[s].Values.Num_Verts;
    Header.Surfaces[s-1].Values.Num_Triangles := Header.Surfaces[s].Values.Num_Triangles;
    // surface arrays
    SetLength(Header.Surfaces[s-1].Shaders, Length(Header.Surfaces[s].Shaders));
    for i:=0 to Length(Header.Surfaces[s].Shaders)-1 do begin
      Header.Surfaces[s-1].Shaders[i].Name := Header.Surfaces[s].Shaders[i].Name;
      Header.Surfaces[s-1].Shaders[i].Shader_Index := Header.Surfaces[s].Shaders[i].Shader_Index;
    end;
    SetLength(Header.Surfaces[s-1].Triangles, Length(Header.Surfaces[s].Triangles));
    for i:=0 to Length(Header.Surfaces[s].Triangles)-1 do begin
      Header.Surfaces[s-1].Triangles[i].Index1 := Header.Surfaces[s].Triangles[i].Index1;
      Header.Surfaces[s-1].Triangles[i].Index2 := Header.Surfaces[s].Triangles[i].Index2;
      Header.Surfaces[s-1].Triangles[i].Index3 := Header.Surfaces[s].Triangles[i].Index3;
    end;
    SetLength(Header.Surfaces[s-1].TextureCoords, Length(Header.Surfaces[s].TextureCoords));
    for i:=0 to Length(Header.Surfaces[s].TextureCoords)-1 do begin
      Header.Surfaces[s-1].TextureCoords[i].S := Header.Surfaces[s].TextureCoords[i].S;
      Header.Surfaces[s-1].TextureCoords[i].T := Header.Surfaces[s].TextureCoords[i].T;
    end;
    SetLength(Header.Surfaces[s-1].Vertex, Length(Header.Surfaces[s].Vertex));
    for i:=0 to Length(Header.Surfaces[s].Vertex)-1 do begin
      Header.Surfaces[s-1].Vertex[i].X := Header.Surfaces[s].Vertex[i].X;
      Header.Surfaces[s-1].Vertex[i].Y := Header.Surfaces[s].Vertex[i].Y;
      Header.Surfaces[s-1].Vertex[i].Z := Header.Surfaces[s].Vertex[i].Z;
      Header.Surfaces[s-1].Vertex[i].Normal := Header.Surfaces[s].Vertex[i].Normal;
    end;
  end;
  //
  Dec(Header.Values.Num_Surfaces);
end;


procedure TMD3.CompactSurfaces;
var s,s2, sv,st, nverts, ntris, f,tv,tv2, i, idx,idx2: integer;
    shader: string;
    freed: array[0..4*MD3_MAX_SURFACES-1] of boolean; // extra elements to support invalid models..
begin
  for s:=0 to Header.Values.Num_Surfaces-1 do freed[s] := false;
  for s:=0 to Header.Values.Num_Surfaces-1 do begin
    // is this surface already moved?..
    if freed[s] then Continue;
    // howmuch room is there for more vertexes/triangles?
    nverts := MD3_MAX_VERTS - Header.Surfaces[s].Values.Num_Verts;
    ntris := MD3_MAX_TRIANGLES - Header.Surfaces[s].Values.Num_Triangles;
    shader := string(Header.Surfaces[s].Shaders[0].Name);
    // find more surfaces with the same shader..
    for s2:=s+1 to Header.Values.Num_Surfaces-1 do begin
      // is this surface already moved?..
      if freed[s2] then Continue;
      //
      if string(Header.Surfaces[s2].Shaders[0].Name) = shader then begin
        // does it fit?..
        if (Header.Surfaces[s2].Values.Num_Verts < nverts) and (Header.Surfaces[s2].Values.Num_Triangles < ntris) then begin
          // it fits, so move surface[s2] into surface[s]..
          Dec(nverts, Header.Surfaces[s2].Values.Num_Verts);
          Dec(ntris, Header.Surfaces[s2].Values.Num_Triangles);
          sv := Header.Surfaces[s].Values.Num_Verts;
          st := Header.Surfaces[s].Values.Num_Triangles;
          // surface header values
          Header.Surfaces[s].Values.Num_Verts := sv + Header.Surfaces[s2].Values.Num_Verts;
          Header.Surfaces[s].Values.Num_Triangles := st + Header.Surfaces[s2].Values.Num_Triangles;
          // surface arrays
          SetLength(Header.Surfaces[s].Triangles, Header.Surfaces[s].Values.Num_Triangles);
          for i:=0 to Header.Surfaces[s2].Values.Num_Triangles-1 do begin
            idx := st+i;
            Header.Surfaces[s].Triangles[idx].Index1 := sv + Header.Surfaces[s2].Triangles[i].Index1;
            Header.Surfaces[s].Triangles[idx].Index2 := sv + Header.Surfaces[s2].Triangles[i].Index2;
            Header.Surfaces[s].Triangles[idx].Index3 := sv + Header.Surfaces[s2].Triangles[i].Index3;
          end;
          SetLength(Header.Surfaces[s].TextureCoords, Header.Surfaces[s].Values.Num_Verts);
          for i:=0 to Header.Surfaces[s2].Values.Num_Verts-1 do begin
            idx := sv+i;
            Header.Surfaces[s].TextureCoords[idx].S := Header.Surfaces[s2].TextureCoords[i].S;
            Header.Surfaces[s].TextureCoords[idx].T := Header.Surfaces[s2].TextureCoords[i].T;
          end;
          tv := Header.Surfaces[s].Values.Num_Verts;
          tv2 := Header.Surfaces[s2].Values.Num_Verts;
          SetLength(Header.Surfaces[s].Vertex, Header.Values.Num_Frames * tv);
          for f:=Header.Values.Num_Frames-1 downto 0 do begin
            for i:=sv-1 downto 0 do begin
              idx := f*tv+i;
              idx2 := f*sv+i;
              Header.Surfaces[s].Vertex[idx].X := Header.Surfaces[s].Vertex[idx2].X;
              Header.Surfaces[s].Vertex[idx].Y := Header.Surfaces[s].Vertex[idx2].Y;
              Header.Surfaces[s].Vertex[idx].Z := Header.Surfaces[s].Vertex[idx2].Z;
              Header.Surfaces[s].Vertex[idx].Normal := Header.Surfaces[s].Vertex[idx2].Normal;
            end;
            for i:=tv2-1 downto 0 do begin
              idx := f*tv+sv+i;
              idx2 := f*tv2+i;
              Header.Surfaces[s].Vertex[idx].X := Header.Surfaces[s2].Vertex[idx2].X;
              Header.Surfaces[s].Vertex[idx].Y := Header.Surfaces[s2].Vertex[idx2].Y;
              Header.Surfaces[s].Vertex[idx].Z := Header.Surfaces[s2].Vertex[idx2].Z;
              Header.Surfaces[s].Vertex[idx].Normal := Header.Surfaces[s2].Vertex[idx2].Normal;
            end;
          end;
          // clear surface[s2]..
          Header.Surfaces[s2].Values.Ident := 0;
          Header.Surfaces[s2].Values.Name := MD3.StringToQ3('');
          Header.Surfaces[s2].Values.Flags := 0;
          Header.Surfaces[s2].Values.Num_Frames := 0;
          Header.Surfaces[s2].Values.Num_Shaders := 0;
          Header.Surfaces[s2].Values.Num_Verts := 0;
          Header.Surfaces[s2].Values.Num_Triangles := 0;
          SetLength(Header.Surfaces[s2].Shaders, 0);
          SetLength(Header.Surfaces[s2].Triangles, 0);
          SetLength(Header.Surfaces[s2].TextureCoords, 0);
          SetLength(Header.Surfaces[s2].Vertex, 0);
          // this surface is now free..
          freed[s2] := true;
        end else begin
          // found a duplicate shader, but there is no more room in surface[s]..
          // skip for now, and look for another surface that might fit..
        end;
      end;
    end;
  end;

  // fill the gaps in the array..
  s := 0;
  while s<Header.Values.Num_Surfaces do begin
    // find a hole in the array..
    if not freed[s] then begin
      Inc(s);
      Continue;
    end;
    // pick the last surface to fill the hole..
    for s2:=Header.Values.Num_Surfaces-1 downto 0 do begin
      if freed[s2] then Continue;
      if s2<=s then Break;
      // move surface[s2] to surface[s]..
      Header.Surfaces[s].Values.Ident := Header.Surfaces[s2].Values.Ident;
      Header.Surfaces[s].Values.Name := Header.Surfaces[s2].Values.Name;
      Header.Surfaces[s].Values.Flags := Header.Surfaces[s2].Values.Flags;
      Header.Surfaces[s].Values.Num_Frames := Header.Surfaces[s2].Values.Num_Frames;
      Header.Surfaces[s].Values.Num_Shaders := Header.Surfaces[s2].Values.Num_Shaders;
      Header.Surfaces[s].Values.Num_Verts := Header.Surfaces[s2].Values.Num_Verts;
      Header.Surfaces[s].Values.Num_Triangles := Header.Surfaces[s2].Values.Num_Triangles;
      //
      SetLength(Header.Surfaces[s].Shaders, Header.Surfaces[s2].Values.Num_Shaders);
      Header.Surfaces[s].Shaders[0].Name := Header.Surfaces[s2].Shaders[0].Name;
      Header.Surfaces[s].Shaders[0].Shader_Index := Header.Surfaces[s2].Shaders[0].Shader_Index;
      //
      SetLength(Header.Surfaces[s].Triangles, Header.Surfaces[s2].Values.Num_Triangles);
      for i:=0 to Header.Surfaces[s2].Values.Num_Triangles-1 do begin
        Header.Surfaces[s].Triangles[i].Index1 := Header.Surfaces[s2].Triangles[i].Index1;
        Header.Surfaces[s].Triangles[i].Index2 := Header.Surfaces[s2].Triangles[i].Index2;
        Header.Surfaces[s].Triangles[i].Index3 := Header.Surfaces[s2].Triangles[i].Index3;
      end;
      SetLength(Header.Surfaces[s].TextureCoords, Header.Surfaces[s2].Values.Num_Verts);
      for i:=0 to Header.Surfaces[s2].Values.Num_Verts-1 do begin
        Header.Surfaces[s].TextureCoords[i].S := Header.Surfaces[s2].TextureCoords[i].S;
        Header.Surfaces[s].TextureCoords[i].T := Header.Surfaces[s2].TextureCoords[i].T;
      end;

      tv := Header.Surfaces[s2].Values.Num_Verts;
      SetLength(Header.Surfaces[s].Vertex, tv * Header.Values.Num_Frames);
      for f:=0 to Header.Values.Num_Frames-1 do
        for i:=0 to tv-1 do begin
          Header.Surfaces[s].Vertex[f*tv+i].X := Header.Surfaces[s2].Vertex[f*tv+i].X;
          Header.Surfaces[s].Vertex[f*tv+i].Y := Header.Surfaces[s2].Vertex[f*tv+i].Y;
          Header.Surfaces[s].Vertex[f*tv+i].Z := Header.Surfaces[s2].Vertex[f*tv+i].Z;
          Header.Surfaces[s].Vertex[f*tv+i].Normal := Header.Surfaces[s2].Vertex[f*tv+i].Normal;
        end;
      // this surface is now free..
      Header.Surfaces[s2].Values.Ident := 0;
      Header.Surfaces[s2].Values.Name := MD3.StringToQ3('');
      Header.Surfaces[s2].Values.Flags := 0;
      Header.Surfaces[s2].Values.Num_Frames := 0;
      Header.Surfaces[s2].Values.Num_Shaders := 0;
      Header.Surfaces[s2].Values.Num_Verts := 0;
      Header.Surfaces[s2].Values.Num_Triangles := 0;
      SetLength(Header.Surfaces[s2].Shaders, 0);
      SetLength(Header.Surfaces[s2].Triangles, 0);
      SetLength(Header.Surfaces[s2].TextureCoords, 0);
      SetLength(Header.Surfaces[s2].Vertex, 0);
      //
      freed[s2] := true;
      freed[s] := false;
      Break;
    end;
    if s2<=s then Break;
    Inc(s);
  end;

  i := 0;
  for s:=0 to Header.Values.Num_Surfaces-1 do
    if not freed[s] then Inc(i);
  SetLength(Header.Surfaces, i);
  Header.Values.Num_Surfaces := i;
end;


procedure TMD3.CalcDimensions(FrameNr: integer; var BoundsMin, BoundsMax, Center: TVector);
var MinX,MaxX,MinY,MaxY,MinZ,MaxZ: Single;
    nv,v,s: integer;
    Vec: TVector;
begin
  BoundsMin := NullVector;
  BoundsMax := NullVector;
  Center := NullVector;
  if Header.Values.Num_Frames<1 then Exit;
  if (FrameNr<0) or (FrameNr>=Header.Values.Num_Frames) then Exit;

  // zoek de min/max; Eerste check is een hit..
  MinX := 3.4E38;
  MaxX := 1.5E-45;
  MinY := 3.4E38;
  MaxY := 1.5E-45;
  MinZ := 3.4E38;
  MaxZ := 1.5E-45;
  // surafces
  for s:=0 to Header.Values.Num_Surfaces-1 do begin
    nv := Header.Surfaces[s].Values.Num_Verts;
{    for f:=0 to Header.Values.Num_Frames-1 do begin}
      // frames: vertex
      for v:=0 to Header.Surfaces[s].Values.Num_Verts-1 do begin
        // position
        with Header.Surfaces[s].Vertex[FrameNr*nv+v] do Vec := Vector(X*MD3_XYZ_SCALE, Y*MD3_XYZ_SCALE, Z*MD3_XYZ_SCALE);
        if Vec.X<MinX then MinX:=Vec.X;
        if Vec.X>MaxX then MaxX:=Vec.X;
        if Vec.Y<MinY then MinY:=Vec.Y;
        if Vec.Y>MaxY then MaxY:=Vec.Y;
        if Vec.Z<MinZ then MinZ:=Vec.Z;
        if Vec.Z>MaxZ then MaxZ:=Vec.Z;
      end;
{    end;}
  end;
  // resultaten
  BoundsMin := Vector(MinX,MinY,MinZ);
  BoundsMax := Vector(MaxX,MaxY,MaxZ);
  Center := ScaleVector(AddVector(BoundsMin,BoundsMax), 0.5);
end;


procedure TMD3.RotateModel(const M:TMatrix4x4);
var s,nv,v,f,nt,t:integer;
    Vec, Center: TVector;
    N: word;
    nx,ny,nz: single;
begin
  // surfaces
  for s:=0 to Header.Values.Num_Surfaces-1 do begin
    nv := Header.Surfaces[s].Values.Num_Verts;
    for f:=0 to Header.Values.Num_Frames-1 do begin
      // frames: vertex
      for v:=0 to Header.Surfaces[s].Values.Num_Verts-1 do begin
        // position
        with Header.Surfaces[s].Vertex[f*nv+v] do Vec := Vector(X*MD3_XYZ_SCALE, Y*MD3_XYZ_SCALE, Z*MD3_XYZ_SCALE);
        Vec := TransformVector(Vec, M);
        with Header.Surfaces[s].Vertex[f*nv+v] do begin
          X := Round(Vec.X * MD3_XYZ_SCALE_1);
          Y := Round(Vec.Y * MD3_XYZ_SCALE_1);
          Z := Round(Vec.Z * MD3_XYZ_SCALE_1);
        end;
        // normal
        N := Header.Surfaces[s].Vertex[f*nv+v].Normal;
        DecodeNormal(N, nx,ny,nz);
        Vec := Vector(nx,ny,nz);
        Vec := TransformVector(Vec, M);
        MD3.EncodeNormal(Vec,N);
        Header.Surfaces[s].Vertex[f*nv+v].Normal := N;
      end;
      // frames: header
      CalcDimensions(f, Header.Frames[f].Min_Bounds,Header.Frames[f].Max_Bounds, Center);
      Vec := Header.Frames[f].Local_Origin;
      Vec := TransformVector(Vec, M);
      Header.Frames[f].Local_Origin := Vec;
    end;
  end;
  // tags
  nt := Header.Values.Num_Tags;
  for f:=0 to Header.Values.Num_Frames-1 do
    for t:=0 to Header.Values.Num_Tags-1 do begin
      // origin
      Vec := Header.Tags[f*nt+t].Origin;
      Vec := TransformVector(Vec, M);
      Header.Tags[f*nt+t].Origin := Vec;
      // axis X
      Vec := Header.Tags[f*nt+t].Axis[0];
      Vec := TransformVector(Vec, M);
      Header.Tags[f*nt+t].Axis[0] := Vec;
      // axis Y
      Vec := Header.Tags[f*nt+t].Axis[1];
      Vec := TransformVector(Vec, M);
      Header.Tags[f*nt+t].Axis[1] := Vec;
      // axis Z
      Vec := Header.Tags[f*nt+t].Axis[2];
      Vec := TransformVector(Vec, M);
      Header.Tags[f*nt+t].Axis[2] := Vec;
    end;
end;

procedure TMD3.RotateModelX(const Degrees:single);
var M: TMatrix4x4;
begin
  // het complete model roteren om zijn origin
  M := XRotationMatrix(Degrees);
  RotateModel(M);
end;

procedure TMD3.RotateModelY(const Degrees:single);
var M: TMatrix4x4;
begin
  // het complete model roteren om zijn origin
  M := YRotationMatrix(Degrees);
  RotateModel(M);
end;

procedure TMD3.RotateModelZ(const Degrees:single);
var M: TMatrix4x4;
begin
  // het complete model roteren om zijn origin
  M := ZRotationMatrix(Degrees);
  RotateModel(M);
end;


// Vind de triangle die het dichtst bij origin is..
// Doorzoek alleen frame[0] in geval van een geanimeerde MD3
function TMD3.ClosestTriangle(const origin:TVector; var SurfaceIndex, TriangleIndex: integer): boolean;
const MAX_DIST = 999999;
var s,t: integer;
    p1,p2,p3: integer;
    v1,v2,v3: TVector;
    closestSurf, closestTri, closestVert: integer;
    distance, closestDistance: single;
begin
  closestSurf := -1;  // ongeldig..
  closestTri := -1;
  closestVert := -1;
  closestDistance := MAX_DIST; // next test is a hit..
  for s:=0 to Header.Values.Num_Surfaces-1 do begin
    for t:=0 to Header.Surfaces[s].Values.Num_Triangles-1 do begin
      p1 := Header.Surfaces[s].Triangles[t].Index1;
      p2 := Header.Surfaces[s].Triangles[t].Index2;
      p3 := Header.Surfaces[s].Triangles[t].Index3;
      with Header.Surfaces[s].Vertex[p1] do v1 := Vector(X * MD3_XYZ_SCALE, Y * MD3_XYZ_SCALE, Z * MD3_XYZ_SCALE);
      with Header.Surfaces[s].Vertex[p2] do v2 := Vector(X * MD3_XYZ_SCALE, Y * MD3_XYZ_SCALE, Z * MD3_XYZ_SCALE);
      with Header.Surfaces[s].Vertex[p3] do v3 := Vector(X * MD3_XYZ_SCALE, Y * MD3_XYZ_SCALE, Z * MD3_XYZ_SCALE);
      // point 1
      distance := VectorLength(SubVector(origin,v1));
      if distance < closestDistance then begin
        closestDistance := distance;
        closestSurf := s;
        closestTri := t;
        closestVert := p1;
      end;
      // point 2
      distance := VectorLength(SubVector(origin,v2));
      if distance < closestDistance then begin
        closestDistance := distance;
        closestSurf := s;
        closestTri := t;
        closestVert := p2;
      end;
      // point 3
      distance := VectorLength(SubVector(origin,v3));
      if distance < closestDistance then begin
        closestDistance := distance;
        closestSurf := s;
        closestTri := t;
        closestVert := p3;
      end;
    end;
  end;

  // Did not find a vertex?..
  if closestDistance = MAX_DIST then begin
    Result := false;
    SurfaceIndex := -1;
    TriangleIndex := -1;
  end else begin
    Result := true;
    SurfaceIndex := closestSurf;
    TriangleIndex := closestTri;
  end;
end;


// Calculate the base from a triangle..
// Use the plane's normal as the Z-axis of the base.
// Use the (unit)vector PlaneOrigin-p1 as the X-axis of the base.
function TMD3.CalcBaseFromTriangle(const SurfaceIndex, TriangleIndex: integer): TMatrix4x4;
var Plane: TPlane;
    PlaneOrg: TVector;
    p1,p2,p3: integer;
    v1,v2,v3: TVector;
    Xaxis, Yaxis, Zaxis: TVector;
begin
  // calculate the plane
  p1 := Header.Surfaces[SurfaceIndex].Triangles[TriangleIndex].Index1;
  p2 := Header.Surfaces[SurfaceIndex].Triangles[TriangleIndex].Index2;
  p3 := Header.Surfaces[SurfaceIndex].Triangles[TriangleIndex].Index3;
  with Header.Surfaces[SurfaceIndex].Vertex[p1] do v1 := Vector(X * MD3_XYZ_SCALE, Y * MD3_XYZ_SCALE, Z * MD3_XYZ_SCALE);
  with Header.Surfaces[SurfaceIndex].Vertex[p2] do v2 := Vector(X * MD3_XYZ_SCALE, Y * MD3_XYZ_SCALE, Z * MD3_XYZ_SCALE);
  with Header.Surfaces[SurfaceIndex].Vertex[p3] do v3 := Vector(X * MD3_XYZ_SCALE, Y * MD3_XYZ_SCALE, Z * MD3_XYZ_SCALE);
  Plane.Normal := PlaneNormal(v1, v2, v3);
  Plane.d := PlaneDistance(Plane.Normal, v1);
  PlaneOrg := PlaneOrigin(Plane.Normal, Plane.d);
  // calculate the base
  ZAxis := Plane.Normal;
  Xaxis := UnitVector(SubVector(v1,PlaneOrg));
  Yaxis := CrossProduct(Xaxis,Zaxis);
  //
  Result := Matrix4x4(Xaxis.X, Yaxis.X, Zaxis.X, 0,
                      Xaxis.Y, Yaxis.Y, Zaxis.Y, 0,
                      Xaxis.Z, Yaxis.Z, Zaxis.Z, 0,
                      0,       0,       0,       1);
end;

// calculate the cosine rotationmatrix that transforms base1 to base2
function TMD3.CalcTransformMatrixFromBases(const Base1,Base2:TMatrix4x4; const Origin1,Origin2:TVector): TMatrix4x4;
var u1,u2,u3, v1,v2,v3, t: TVector;
    d1,d2,d3: Single;
begin
  u1 := Vector(Base1[0,0], Base1[1,0], Base1[2,0]);
  u2 := Vector(Base1[0,1], Base1[1,1], Base1[2,1]);
  u3 := Vector(Base1[0,2], Base1[1,2], Base1[2,2]);
  //
  v1 := Vector(Base2[0,0], Base2[1,0], Base2[2,0]);
  v2 := Vector(Base2[0,1], Base2[1,1], Base2[2,1]);
  v3 := Vector(Base2[0,2], Base2[1,2], Base2[2,2]);
  //
  d1 := DotProduct(u1,v1);
  d2 := DotProduct(u2,v2);
  d3 := DotProduct(u3,v3);
  Result := MultiplyMatrix( XRotationMatrix(ArcCos(d1*constRadToDeg)), YRotationMatrix(ArcCos(d2*constRadToDeg)) );
  Result := MultiplyMatrix( Result, ZRotationMatrix(ArcCos(d3*constRadToDeg)) );
  t := SubVector(Origin2, Origin1);
  Result[0,3] := t.X;
  Result[1,3] := t.Y;
  Result[2,3] := t.Z;
end;






//------------------------------------------------------------------------------
initialization
  MD3 := TMD3.Create;
finalization
  MD3.Free;



end.

