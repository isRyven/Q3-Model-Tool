// Een (level-editor) .MAP file inlezen in mijn MAP-object. ("mapversion" "220")
//
// Alle informatie is opgeslagen in blokken tussen "{" en "}" tekens (op aparte regels).
// Elke informatie-blok bevat als eerste info de classname van de opgeslagen informatie.
// De "classname" "worldspawn" blok bevat alle brushes met texturenamen/normalen ed.
// Elke brush binnen de "worldspawn"-blok is weer apart gemarkeerd; Tussen "{" & "}".
// Een voorbeeld van 2 brush definities:
//   {
//   ( 720 1136 -128 ) ( 752 1136 -128 ) ( 752 1168 -128 ) AAATRIGGER [ 1 0 0 0 ] [ 0 -1 0 -16 ] 0 1 1
//   ( 752 1136 -64 ) ( 720 1136 -64 ) ( 720 1168 -64 ) AAATRIGGER [ 1 0 0 0 ] [ 0 -1 0 -16 ] 0 1 1
//   ( 752 1136 -128 ) ( 720 1136 -128 ) ( 720 1136 -64 ) AAATRIGGER [ 1 0 0 0 ] [ 0 0 -1 -32 ] 0 1 1
//   ( 752 1168 -128 ) ( 752 1136 -128 ) ( 752 1136 -64 ) AAATRIGGER [ 0 1 0 16 ] [ 0 0 -1 -32 ] 0 1 1
//   ( 720 1168 -128 ) ( 752 1168 -128 ) ( 752 1168 -64 ) AAATRIGGER [ 1 0 0 0 ] [ 0 0 -1 -32 ] 0 1 1
//   ( 720 1136 -128 ) ( 720 1168 -128 ) ( 720 1168 -64 ) AAATRIGGER [ 0 1 0 16 ] [ 0 0 -1 -32 ] 0 1 1
//   }
//   {
//   ( 132 629 -109 ) ( 132 629 -48 ) ( 138 629 -48 ) COMMON/0_CLIP [ 6.12303e-017 0 -1 0 ] [ -1 0 -6.12303e-017 -30 ] 90 1 -1.2
//   ( 132 633 -48 ) ( 132 633 -109 ) ( 138 633 -109 ) COMMON/0_CLIP [ 6.12303e-017 0 -1 0 ] [ -1 0 -6.12303e-017 -30 ] 90 1 -1.2
//   ( 132 629 -48 ) ( 132 629 -109 ) ( 132 633 -109 ) COMMON/0_CLIP [ 0 6.12303e-017 -1 0 ] [ 0 -1 -6.12303e-017 5 ] 90 1 1.2
//   ( 138 629 -48 ) ( 132 629 -48 ) ( 132 633 -48 ) COMMON/0_CLIP [ -1 -1.22461e-016 0 29 ] [ -1.22461e-016 1 0 5 ] 180 1 -1.2
//   ( 138 633 -48 ) ( 138 633 -109 ) ( 138 629 -109 ) COMMON/0_CLIP [ 0 6.12303e-017 -1 0 ] [ 0 -1 -6.12303e-017 5 ] 90 1 1.2
//   ( 138 633 -109 ) ( 132 633 -109 ) ( 132 629 -109 ) COMMON/0_CLIP [ -1 -1.22461e-016 0 29 ] [ -1.22461e-016 1 0 5 ] 180 1 -1.2
//   }
// De eerste 3 vectoren (tussen "(" & ")" tekens) bevatten de punten van een triangle (CCW).
// Daarna volgt de naam van de gebruikte texture (zonder extensie).
// Tussen de 1e stel brackets "[" & "]": texture-coord-axis [ U.x U.y U.z shift[0] ]
// Tussen de 2e stel brackets: [ V.x V.y V.z shift[1] ]
// De laatste 3 cijfers op een regel bevatten: texture.rotate, texture.scale[0] & texture.scale[1]
//
// Vanwege variaties in .MAP file-formats tussen (bv) HalfLife- & Wolfenstein- .MAPs,
// hier enige uitleg:
//
//  HalfLife brush-regel:
//   ( 720 1136 -128 ) ( 720 1168 -128 ) ( 720 1168 -64 ) AAATRIGGER [ 0 1 0 16 ] [ 0 0 -1 -32 ] 0 1 1
//   ( V1(x,y,z) ) ( V2(x,y,z) ) ( V3(x,y,z) ) texture [ U-as-normaal(x,y,z) U-shift ] [ V-as-normaal(x,y,z) V-shift ] Rotatie U-scale V-scale
//
//  Quake3 (Wolfenstein) brush-regel:
//   ( 1008 -80 128 ) ( 1008 -80 144 ) ( 704 -80 144 ) tobruk_wall_sd/tobruk_wall_base1 0.000000 0.000000 0.000000 0.500000 0.500000 134217728 0 0
//   ( V1(x,y,z) ) ( V2(x,y,z) ) ( V3(x,y,z) ) texture normal-x normal-y normal-z U-scale V-scale ??rotatie?? U-shift V-shift
//


unit uMap;
interface
uses OpenGL, u3DTypes, uOpenGL, uFrustum, uCalc, StdCtrls, Classes, uTexture, uMD3,
     uQ3Shaders, ComCtrls;

const
  MaxWorld = 16384;
  Xas=1; Yas=2; Zas=3;

type
  VectorList = array of TVector;

  TMapVertex = packed record
    Color          : array[0..3] of Single;    // RGBA kleur voor deze vertex
    Normal         : TVector3f;                // (x, y, z) normaal vector
    Position       : TVector3f;                // (x, y, z) positie
    TextureCoord   : TVector2f;                // (u, v) texture coordinaten
  end;

  TMapFace = record
    Normal         : TVector3f;                // De normaal van deze face
    N_Vertices     : Integer;                  // Het aantal vertices van deze face
    startVertIndex : Integer;                  // De start-index van de 1e face-vertex
    VertIndex      : array of Integer;         // Alle indexen in een array
    TextureIndex   : Integer;                  // De index van de texture in de array Textures
    ShaderName     : string;
  end;

  TMapPlane = record
    Normal           : TVector3f;
    Distance         : Single;
    P0,P1,P2, Center : TVector;                 // de eerste 3 punten zoals opgegeven in de .MAP file + face-center
    ShaderName       : string;
    TextureIndex     : Integer;                 // De index van de texture in de array Textures
    TextureAxisU,
    TextureAxisV     : TVector;
    TextureRotation,
    TextureShiftU,
    TextureShiftV    : Single;
    TextureScaleU,
    TextureScaleV    : Single;
    MaxAs,MaxAsSign  : integer;
  end;

  TMapTexture = record
    Filename      : string;
    TextureWidth,
    TextureHeight : Integer;
    Handle        : GLuint;
  end;

  TFoundTextureSizes = record
    ShaderName: string;
    Width, Height: cardinal;
  end;

  TLevelMap = class(TObject)
    private
      StatusBar: TStatusBar;
      MapName: string;
      //
      N_Vertices     : Integer;              // Het aantal vertices
      Vertices       : array of TMapVertex;  // Vertices
      N_Faces        : Integer;              // Het aantal faces
      Faces          : array of TMapFace;    // Faces
      N_Textures     : Integer;              // Het aantal textures
      Textures       : array of TMapTexture; // Textures
      // MD3 surfaces array
      Surfaces       : packed array of TSurface;    // uMD3
      //
      MapLoaded      : boolean;
      N_FacesDrawn   : Integer;              // Het aantal getekende faces
      N_Brushes      : Integer;              // het aantal verwerkte brushes

      // texture grootte opzoeken
      TextureSizes: array of TFoundTextureSizes;

      //hulpfuncties..
      function SplitString(const s: string; var ToStringList: TStringList) : integer;
      function StringToFloatDef(const s: string; DefaultValue: Single) : Single;
      function StringToIntDef(const s: string; DefaultValue: Integer) : Integer;

//      procedure CalcUVAxis(var aPlane:TMapPlane; P1,P2,P3, Normal: TVector; RotDeg: Single; var AxisU, AxisV: TVector);
      procedure CalcUVAxis(var aPlane:TMapPlane; var AxisU, AxisV: TVector);
      function Vector3iToVector3f(V3i: TVector3i) : TVector;

      // texture-coordinaten uitrekenen voor 1 punt (van een vlak met een texture)
      function CalcTextureCoords(var aPlane:TMapPlane; aVertex:TVector; aTextureIndex:Integer) : TVector2f;
      //
      procedure CorrectTextureCoords(startVertexIndex, N_Verts: Integer);
      // texture al opgenomen in de array Textures??  zoja: resulteer het index-nummer, anders -1
      function IsTextureInList(var Filename: string) : Integer;
      // voeg een nieuwe texture toe aan de lijst Textures, en resulteer het index-nummer
      function AddTextureToList(Filename: string; Width,Height: Integer) : Integer;
      //
      procedure ProcessBrush(var SLB: TStringList);
      procedure ProcessClass(var SL: TStringList);
      //
(*
      procedure InitTextures;
      procedure FreeTextures;
*)
    public
      constructor Create;
      destructor Destroy; override;
      procedure Clear;
      //
      function IsMapLoaded : boolean;
      function GetNFaces : integer;
      function GetNFacesDrawn : integer;
      //
      procedure DisplayMap(CameraPosition: TVector);
      //
      function LoadMAP(const Filename:string; cStatusBar:TStatusBar) : Boolean;
      //
      function ConvertToMD3(var MD3:TMD3) : boolean;
  end;

var LevelMAP : TLevelMap;

implementation
uses StrUtils, SysUtils, Math, Dialogs, Unit1,Unit2;



{ TLevelMap }
constructor TLevelMap.Create;
begin
  DecimalSeparator := '.';
  Clear;
end;

destructor TLevelMap.Destroy;
begin
  Clear;
  inherited;
end;

procedure TLevelMap.Clear;
begin
(*
  // alle textures van deze map kunnen weg
  FreeTextures;
*)
  //
  MapLoaded := false;
  // het hele object legen..
  N_Vertices := 0;
  SetLength(Vertices, 0);
  N_Faces := 0;
  SetLength(Faces, 0);
  N_Textures := 0;
  SetLength(Textures, 0);
  N_FacesDrawn := 0;
end;




function TLevelMap.IsMapLoaded: boolean;
begin
  Result := MapLoaded;
end;

function TLevelMap.GetNFaces: integer;
begin
  Result := Length(Faces);
end;

function TLevelMap.GetNFacesDrawn: integer;
begin
  Result := N_FacesDrawn;
end;



function TLevelMap.Vector3iToVector3f(V3i: TVector3i): TVector;
begin
  Result.X := V3i.X * 1.0;
  Result.Y := V3i.Y * 1.0;
  Result.Z := V3i.Z * 1.0;
end;


function TLevelMap.SplitString(const s: string; var ToStringList: TStringList): integer;
const SpaceDelimiter = [' '];
begin
  Result := ExtractStrings( SpaceDelimiter, []{SpaceDelimiter}, pchar(s), ToStringList );
end;

function TLevelMap.StringToFloatDef(const s: string; DefaultValue: Single) : Single;
var code: integer;
    Value: Single;
begin
  Result := DefaultValue;
  try
    Val(s, Value, code);
    if code=0 then Result := Value;
  except
    Exit;
  end;
end;

function TLevelMap.StringToIntDef(const s: string; DefaultValue: Integer) : Integer;
var code: integer;
    Value: Integer;
begin
  Result := DefaultValue;
  try
    Val(s, Value, code);
    if code=0 then Result := Value;
  except
    Exit;
  end;
end;



//procedure TLevelMap.CalcUVAxis(var aPlane:TMapPlane; P1,P2,P3, Normal: TVector; RotDeg: Single; var AxisU, AxisV: TVector);
procedure TLevelMap.CalcUVAxis(var aPlane:TMapPlane; var AxisU, AxisV: TVector);
var N, V, V1,V2,V3, origin: TVector;
    RotX,RotY,RotZ, Rot: Double;
    MaxAs: Integer;
    i: integer;
    M: TMatrix4x4;
    S,C,tmp, tmpX,tmpY,tmpZ: Single;
  //----------------------------------------------------------------------------
  procedure SwapAxisU;
  begin
    AxisU.X := -AxisU.X;
    AxisU.Y := -AxisU.Y;
    AxisU.Z := -AxisU.Z;
  end;
  //----------------------------------------------------------------------------
  procedure SwapAxisV;
  begin
    AxisV.X := -AxisV.X;
    AxisV.Y := -AxisV.Y;
    AxisV.Z := -AxisV.Z;
  end;
  //----------------------------------------------------------------------------
  function MySign(Value:single) : integer;
  begin
    if Value=0 then Result := 1
               else Result := Sign(Value);
  end;
  //----------------------------------------------------------------------------
begin
  N := aPlane.Normal;

  if Abs(N.X) < 1E-6 then N.X := 0.0;
  if Abs(N.Y) < 1E-6 then N.Y := 0.0;
  if Abs(N.Z) < 1E-6 then N.Z := 0.0;

  if Abs(1.0-Abs(N.X)) < 1E-3 then N.X := MySign(N.X)*1.0;
  if Abs(1.0-Abs(N.Y)) < 1E-3 then N.Y := MySign(N.Y)*1.0;
  if Abs(1.0-Abs(N.Z)) < 1E-3 then N.Z := MySign(N.Z)*1.0;

  // maximale coordinaat/richting zoeken
  if (abs(N.Z)>=abs(N.X)) then begin
    if (abs(N.Z)>=abs(N.Y)) then MaxAs:=Zas else MaxAs:=Yas;
  end else
    if (abs(N.X)>=abs(N.Y)) then MaxAs:=Xas else MaxAs:=Yas;
  // de normaal N wijst dus het meest in de richting MaxAs

  aPlane.MaxAs := MaxAs;
  case MaxAs of
    Xas: aPlane.MaxAsSign := MySign(N.X);
    Yas: aPlane.MaxAsSign := MySign(N.Y);
    Zas: aPlane.MaxAsSign := MySign(N.Z);
  end;

  case MaxAs of
    Xas: begin
           AxisU := UnitVector(CrossProduct(Vector(0,0,-1),N));
           AxisV := UnitVector(CrossProduct(N, AxisU));
           AxisU := UnitVector(CrossProduct(N, AxisV));
           if aPlane.MaxAsSign=1 then
             if N.X<>1 then SwapAxisU;
           {if N.Z=0 then} AxisU := NegativeYAxisVector;
           AxisV := NegativeZAxisVector;
        end;
    Yas: begin
           AxisU := UnitVector(CrossProduct(Vector(0,0,1),N));
           AxisV := UnitVector(CrossProduct(N, AxisU));
           AxisU := UnitVector(CrossProduct(N, AxisV));
           if aPlane.MaxAsSign=1 then
             if N.Y<>1 then SwapAxisU;
{           if N.X=0 then} AxisU := NegativeXAxisVector;
           AxisV := NegativeZAxisVector;
         end;
    Zas: begin
           AxisU := UnitVector(CrossProduct(Vector(0,1,0),N));
           AxisV := UnitVector(CrossProduct(N, AxisU));
           AxisU := UnitVector(CrossProduct(N, AxisV));
{           if aPlane.MaxAsSign=1 then
             if N.Z<>1 then SwapAxisU;}
           aPlane.TextureRotation := -aPlane.TextureRotation;
{           if N.Y=0 then} AxisU := NegativeXAxisVector;
           AxisV := YAxisVector;
         end;
  end;
end;


function TLevelMap.CalcTextureCoords(var aPlane:TMapPlane; aVertex:TVector; aTextureIndex:Integer): TVector2f;
var tmp,
    A,S,C,
    InvW,InvH,
    ShiftW,ShiftH,
    InvScaleW,InvScaleH,
    U,V: Single;
    M,M2,M3: TMatrix4x4;
    N, origin, Vec,Vx,Vy,Vz,
    aU,aV, T1,T2,T3: TVector;
    MaxAs: Integer;
begin
  // De texture-coördinaten voor 1 vertex:
  // Tu = (V · Nu)        Ou           Tu & Tv: 2 texture-coördinaten
  //       _______ / Su + __                 V: vertex waarvan de texCoords worden berekend
  //         w            w            Nu & Nv: texture as-normalen
  //                                     w & h: texture breedte & hoogte (pixels)
  // Tv = (V · Nv)        Ov           Su & Sv: texture scale
  //       _______ / Sv + __           Ou & Ov: texture offset (shift)
  //         h            h

  Result.X := 0;
  Result.Y := 0;
  if aTextureIndex < 0 then Exit;
  if Textures[aTextureIndex].Filename = '' then Exit;

  InvW := 1.0 / Textures[aTextureIndex].TextureWidth;
  InvH := 1.0 / Textures[aTextureIndex].TextureHeight;

  InvScaleW := 1.0 / aPlane.TextureScaleU;
  InvScaleH := 1.0 / aPlane.TextureScaleV;

  ShiftW := aPlane.TextureShiftU * InvW;
  ShiftH := aPlane.TextureShiftV * InvH;

  Vec := aVertex;
  // rotatie
  A := aPlane.TextureRotation;
  uCalc.SinCos(A, S,C);
  case aPlane.MaxAs of
    Xas: begin
      A := Vec.Y;
      Vec.Y := A*C - Vec.Z*S;      // AxisU
      Vec.Z := A*S + Vec.Z*C;      // AxisV
    end;
    Zas: begin
      A := Vec.X;
      Vec.X := A*C - Vec.Y*S;      // AxisU
      Vec.Y := A*S + Vec.Y*C;      // AxisV
    end;
    Yas: begin
      A := Vec.X;
      Vec.X := A*C - Vec.Z*S;       // AxisU
      Vec.Z := A*S + Vec.Z*C;       // AxisV
    end;
  end;
  // scale,shift
  Result.X := DotProduct(Vec, aPlane.TextureAxisU) * InvW * InvScaleW + ShiftW;
  Result.Y := DotProduct(Vec, aPlane.TextureAxisV) * InvH * InvScaleH + ShiftH;
end;


procedure TLevelMap.CorrectTextureCoords(startVertexIndex, N_Verts: Integer);
var Nearest: Single;
    NearestIndex, j: Integer;
    U,V: Single;
begin
  // doorloop alle punten van 1 polygon/face
  // en pas de texture-coords. aan in een bereik -1..1

  // Eerst de U-coördinaat
  Nearest := Vertices[startVertexIndex].TextureCoord.X;
  NearestIndex := startVertexIndex;
  for j:=0 to N_Verts-1 do begin
    U := Vertices[startVertexIndex+j].TextureCoord.X;
    // coord. niet in bereik -1..1 ??, anders is ie al goed..
    if Abs(U) > 1 then begin
      if Abs(U) < Abs(Nearest) then begin
        Nearest := U;
        NearestIndex := startVertexIndex+j;
      end;
    end else begin
      // alle coords. zijn al goed.
      Exit;
    end;
  end;
  for j:=0 to N_Verts-1 do
    Vertices[startVertexIndex+j].TextureCoord.X := Vertices[startVertexIndex+j].TextureCoord.X - Nearest;

  // de V-coördinaat
  Nearest := Vertices[startVertexIndex].TextureCoord.Y;
  NearestIndex := startVertexIndex;
  for j:=0 to N_Verts-1 do begin
    V := Vertices[startVertexIndex+j].TextureCoord.Y;
    // coord. niet in bereik -1..1 ??, anders is ie al goed..
    if Abs(V) > 1 then begin
      if Abs(V) < Abs(Nearest) then begin
        Nearest := V;
        NearestIndex := startVertexIndex+j;
      end;
    end else begin
      // alle coords. zijn al goed.
      Exit;
    end;
  end;
  for j:=0 to N_Verts-1 do
    Vertices[startVertexIndex+j].TextureCoord.Y := Vertices[startVertexIndex+j].TextureCoord.Y - Nearest;
end;


function TLevelMap.IsTextureInList(var Filename: string): Integer;
var i: integer;
    n: string;
begin
  Result := -1;
  n := Filename;
  if not OGL.Textures.FindTexture(n) then Exit;
  Filename := n;
  for i:=0 to N_Textures-1 do begin
    if Textures[i].Filename = n then begin
      Result := i;
      Exit;
    end;
  end;
end;

function TLevelMap.AddTextureToList(Filename: string; Width,Height: Integer): Integer;
var TextureFilename, Extension: string;
    TextureResource: TTextureResource;
    ShaderIndex: integer;
    W,H: integer;
    t: integer;
    b: boolean;
    OnlyFilename: string;
begin
  Inc(N_Textures);
  SetLength(Textures, N_Textures);
  Result := N_Textures-1;
  Textures[Result].Filename := Filename;

  W := Width;
  H := Height;
  // zoek de texture-grootte
  b := false;
  for t:=0 to Length(TextureSizes)-1 do
    if TextureSizes[t].ShaderName = Filename then begin
      W := TextureSizes[t].Width;
      H := TextureSizes[t].Height;
      b := true;
      Break;
    end;
  if not b then begin
    // opzoeken..
    OnlyFilename := AnsiReplaceStr(Filename,'/','\');
    OnlyFilename := ExtractFilename(OnlyFilename);
    if uQ3Shaders.Shaders.Locate('', Filename,
                                 Form1.LoadedFrom, Form1.TmpDir, Form1.GameDir, Form1.ModelDir,
                                 dlgPK3.MapPK3, dlgPK3.PathDir,
                                 TextureFilename, TextureResource, ShaderIndex) then begin
      Extension := ExtractFileExt(TextureFilename);
      OGL.Textures.GetTextureInfo(TextureFilename, Extension, W,H);
    end else
      if uQ3Shaders.Shaders.Locate('', 'textures/'+Filename,
                                   Form1.LoadedFrom, Form1.TmpDir, Form1.GameDir, Form1.ModelDir,
                                   dlgPK3.MapPK3, dlgPK3.PathDir,
                                   TextureFilename, TextureResource, ShaderIndex) then begin
        Extension := ExtractFileExt(TextureFilename);
        OGL.Textures.GetTextureInfo(TextureFilename, Extension, W,H);
      end else
        if uQ3Shaders.Shaders.Locate('', OnlyFilename,
                                     Form1.LoadedFrom, Form1.TmpDir, Form1.GameDir, Form1.ModelDir,
                                     dlgPK3.MapPK3, dlgPK3.PathDir,
                                     TextureFilename, TextureResource, ShaderIndex) then begin
          Extension := ExtractFileExt(TextureFilename);
          OGL.Textures.GetTextureInfo(TextureFilename, Extension, W,H);
        end;
    // en toevoegen aan de lookup-array..
    t := Length(TextureSizes);
    SetLength(TextureSizes, t+1);
    TextureSizes[t].ShaderName := Filename;
    TextureSizes[t].Width := W;
    TextureSizes[t].Height := H;
  end;

  
  Textures[Result].TextureWidth := W{Width};
  Textures[Result].TextureHeight := H{Height};
  Textures[Result].Handle := 0;
end;

(*
procedure TLevelMap.InitTextures;
var i: integer;
begin
  for i:=0 to N_Textures-1 do
    if Textures[i].Handle = 0 then
      Textures[i].Handle := OGL.Textures.LoadTexture(Textures[i].Filename);
end;

procedure TLevelMap.FreeTextures;
var i: integer;
begin
  for i:=0 to N_Textures-1 do
    OGL.Textures.DeleteTexture(Textures[i].Handle);
  N_Textures := 0;
  SetLength(Textures, 0);
end;
*)




procedure TLevelMap.ProcessBrush(var SLB: TStringList);
var Vi1, Vi2, Vi3: TVector3i;
    Vf1, Vf2, Vf3: TVector;
    shaderName, TextureExtension: string;
    TextureWidth, TextureHeight: Integer;
    TextureAxisU4, TextureAxisV4: TVector4f;
    TextureIndex: Integer;
    i,j,k,L,m,Len,LF,LV, ii: integer;
    BrushPlanes: array of TMapPlane;
    Plane1, Plane2, Plane3: TPlane;
    N_PlanesA, N_FacesA: Integer;
    FacesA: array of VectorList; // voor elke plane, een array met face-vertices
    tmpList: VectorList;
    valid, reSort, b: boolean;
    N, V, tmpV, BestAxis: TVector;
    s,s2: string;
    AxisN: Integer;
    tmpFloat: Single;
    LineSL: TStringList;
    BrushCenter: TVector;
  //--------------------------------------------------------------------------
  function VectorInWorld(aV: TVector): boolean;
  begin
    Result := false;
    if (aV.X < -MaxWorld) or (aV.X > MaxWorld) then Exit;
    if (aV.Y < -MaxWorld) or (aV.Y > MaxWorld) then Exit;
    if (aV.Z < -MaxWorld) or (aV.Z > MaxWorld) then Exit;
    Result := true;
  end;
  //--------------------------------------------------------------------------
  function VectorInList(var VL: VectorList; aV: TVector): boolean;
  var m: integer;
  begin
    for m:=0 to Length(VL)-1 do begin
      // 0.15 is net wat groter dan 0.125, de kleinste grid-afstand
      if AlmostSameVector(aV, VL[m], 0.15) then begin
        Result := true;
        Exit;
      end;
    end;
    Result := false;
  end;
  //--------------------------------------------------------------------------
  procedure AddVectorToList(var VL: VectorList; aV: TVector);
  var Len: integer;
  begin
    Len := Length(VL);
    SetLength(VL, Len+1);
    VL[Len] := aV;
  end;
  //--------------------------------------------------------------------------
  // punten rangschikken op volgorde in de polygon
  function SortVectorList(var VL: VectorList; N: TVector) : boolean;
  const FrontFaced = GL_CCW;
  var Center, chkN, A,B, tmpV: TVector;
      i,j, Smallest: integer;
      SmallestAngle, Angle: Double;
      Plane: TPlane;
  begin
    Result := false;
    // het centrum van de face bepalen
    Len := Length(VL);
    if Len=0 then Exit;

    Center := NullVector;
    for i:=0 to Len-1 do Center := AddVector(Center, VL[i]);
    Center := ScaleVector(Center, 1.0/Len);

    // alle punten in deze face doorlopen
    for i:=0 to Len-2 do begin
      Smallest := -1;
      SmallestAngle := -1.0;  // 180 graden

      // het vlak, loodrecht op de te checken plane,
      // tbv testen de volgorde in de polygon
      chkN := PlaneNormal(VL[i], Center, AddVector(Center,N));
      Plane.Normal := chkN;
      Plane.d := PlaneDistance(chkN, VL[i]);

      // een vector samenstellen, die loopt vanuit Center naar punt[i] in de polygon
      A := SubVector(VL[i], Center);
      A := UnitVector(A);

      for j:=i+1 to Len-1 do begin
        // ligt het punt voor?-, of achter het vlak P?
        if DotProduct(Plane.Normal, VL[j]) + Plane.d >= 0 then begin
          // het punt ligt ervoor..

          // een vector samenstellen, die loopt vanuit Center naar punt[j] in de polygon
          B := SubVector(VL[j], Center);
          B := UnitVector(B);

          // bereken de hoek tussen de vectoren A & B..
          // vector A loopt van het Center naar punt[i],
          // vector B loopt van het Center naar punt[j].
          Angle := DotProduct(A,B);
          // Angle bevat nu de invCos van de hoek tussen A&B.
          // cos   0 graden =  1
          // cos  90 graden =  0
          // cos 180 graden = -1
          // cos 270 graden =  0

          // Als de hoek kleiner is, is de invCos groter
          if Angle >= SmallestAngle then begin
            SmallestAngle := Angle;
            Smallest := j;
          end;
        end;
      end;

      // swap punt[i+1] met punt[Smallest]
      if (Smallest<>i+1) and (Smallest<>-1) then begin
        tmpV := VL[i+1];
        VL[i+1] := VL[Smallest];
        VL[Smallest] := tmpV;
        //
        Result := true;
      end;
    end;

{
//    if not IsCCW(VL, Center) then begin
      // vertices volgorde in de face omkeren
      for j:=0 to (Len div 2)-1 do begin
        tmpV := VL[j];
        VL[j] := VL[Len-1-j];
        VL[Len-1-j] := tmpV;
      end;
//    end;
}
  end;
  //--------------------------------------------------------------------------
begin
  Inc(N_Brushes);
  StatusBar.SimpleText := 'Processing brush '+ IntToStr(N_Brushes);
  StatusBar.Invalidate;

  if (SLB.Count<1) then begin
    SLB.Clear;
    Exit;
  end;

  N_PlanesA := SLB.Count;

  // De planes in deze brush converteren naar TPlane's..
  SetLength(BrushPlanes, N_PlanesA);
  for i:=0 to N_PlanesA-1 do begin

    // de string, (1 regel van de brush uit de .MAP-file), opsplitsen in een lijst met losse "woorden"/getallen
    LineSL := TStringList.Create;
    LineSL.Clear;
    try
      //Q3
      //( 2296 -1928 32 ) ( 2296 -1912 32 ) ( 2296 -1928 224 ) egypt_walls_sd/stucco01_decor01 0 -16 0 0.500000 -0.500000 134217728 0 0
      SplitString(SLB.Strings[i], LineSL);
      if LineSL.Count<15 then Continue; //volgende plane testen..
      // vertices
      Vf1.X := StringToFloatDef(LineSL.Strings[1], 0);
      Vf1.Y := StringToFloatDef(LineSL.Strings[2], 0);
      Vf1.Z := StringToFloatDef(LineSL.Strings[3], 0);
      Vf2.X := StringToFloatDef(LineSL.Strings[6], 0);
      Vf2.Y := StringToFloatDef(LineSL.Strings[7], 0);
      Vf2.Z := StringToFloatDef(LineSL.Strings[8], 0);
      Vf3.X := StringToFloatDef(LineSL.Strings[11], 0);
      Vf3.Y := StringToFloatDef(LineSL.Strings[12], 0);
      Vf3.Z := StringToFloatDef(LineSL.Strings[13], 0);
{      // normal
      N.X := StringToFloatDef(LineSL.Strings[16], 0);
      N.Y := StringToFloatDef(LineSL.Strings[17], 0);
      N.Z := StringToFloatDef(LineSL.Strings[18], 0);}

      // Z-coördinaat omdraaien
      Vf1.Z := -Vf1.Z;
      Vf2.Z := -Vf2.Z;
      Vf3.Z := -Vf3.Z;

      BrushPlanes[i].P0 := Vf1;    //-Z
      BrushPlanes[i].P1 := Vf3;
      BrushPlanes[i].P2 := Vf2;
      N := PlaneNormal(Vf1, Vf3, Vf2);
      //
      if N.X=0 then N.X:=+0;
      if N.Y=0 then N.Y:=+0;
      if N.Z=0 then N.Z:=+0;
      if 1-Abs(N.X)<0.001 then N.X:=Sign(N.X);
      if 1-Abs(N.Y)<0.001 then N.Y:=Sign(N.Y);
      if 1-Abs(N.Z)<0.001 then N.Z:=Sign(N.Z);
      //
      BrushPlanes[i].Normal := N;
      BrushPlanes[i].Distance := PlaneDistance(N, Vf1);

      // shader/texture
      ShaderName := LineSL.Strings[15];
      BrushPlanes[i].ShaderName := Shadername;
      BrushPlanes[i].TextureShiftU := StringToFloatDef(LineSL.Strings[16], 0);
      BrushPlanes[i].TextureShiftV := StringToFloatDef(LineSL.Strings[17], 0);
      BrushPlanes[i].TextureRotation := StringToFloatDef(LineSL.Strings[18], 0);
      BrushPlanes[i].TextureScaleU := StringToFloatDef(LineSL.Strings[19], 1);
      BrushPlanes[i].TextureScaleV := StringToFloatDef(LineSL.Strings[20], 1);
      // correcties
      if BrushPlanes[i].TextureScaleU = 0 then BrushPlanes[i].TextureScaleU := 1;
      if BrushPlanes[i].TextureScaleV = 0 then BrushPlanes[i].TextureScaleV := 1;
    finally
      LineSL.Free;
    end;

    // de texture van dit vlak/face
    // check of de texture al is opgenomen in de array Textures,
    // en geef meteen de absolute TextureFilename terug (indien de texture bestaat in 1 van de zoekpaden)
    // (indien texture niet is gevonden, de TextureFilename onveranderd laten)
    TextureIndex := IsTextureInList(ShaderName);
    // texture nog niet in de lijst met textures??
    if TextureIndex = -1 then
      // texture toevoegen aan de array Textures (als de texture bestaat en dus de info ervan kan worden opgevraagd)
{      if OGL.Textures.GetTextureInfo(ShaderName, TextureExtension, TextureWidth, TextureHeight) then
        TextureIndex := AddTextureToList(ShaderName, TextureWidth, TextureHeight);}
        TextureIndex := AddTextureToList(ShaderName, 256,256);//test!!!!!DEBUG!!!!!
    BrushPlanes[i].TextureIndex := TextureIndex;
  end;

  // De planes van deze brush omzetten naar faces (met hoekpunten).
  SetLength(FacesA, N_PlanesA);
  for i:=0 to N_PlanesA-1 do SetLength(FacesA[i], 0);

  // Daarvoor alle mogelijke combinaties van planes doorlopen van deze brush..
  for i:=0 to N_PlanesA-3 do begin
    for j:=i+1 to N_PlanesA-2 do begin
      for k:=j+1 to N_PlanesA-1 do begin
        // niet dezelfde planes vergelijken..
        if (i<>j) and (i<>k) and (j<>k) then begin
          // de 3 planes
          Plane1.Normal := BrushPlanes[i].Normal;
          Plane1.d := BrushPlanes[i].Distance;
          Plane2.Normal := BrushPlanes[j].Normal;
          Plane2.d := BrushPlanes[j].Distance;
          Plane3.Normal := BrushPlanes[k].Normal;
          Plane3.d := BrushPlanes[k].Distance;
          // snijden de planes??
          if PlanesIntersectionPoint(Plane1, Plane2, Plane3, V) {and VectorInWorld(V)} then begin
            // is het snijpunt V in de brush??
            valid := true;
            for L:=0 to N_PlanesA-1 do begin
              if (L<>i) and (L<>j) and (L<>k) then begin
                // punt buiten de brush?
                if DotProduct(BrushPlanes[L].Normal, V) - BrushPlanes[L].Distance > 0  then begin
                  valid := false;
                  break;
                end;
              end;
            end;
            if valid then begin
              // snijpunt nog niet opgenomen in de Faces-array??
              if not VectorInList(FacesA[i], V) then AddVectorToList(FacesA[i], V);
              if not VectorInList(FacesA[j], V) then AddVectorToList(FacesA[j], V);
              if not VectorInList(FacesA[k], V) then AddVectorToList(FacesA[k], V);
            end;
          end;
        end;
      end;
    end;
  end;

  // Nu hebben we een array FacesA, met N_PlanesA elementen.
  // Voor elk vlak is er een array van punten (in dat vlak).
  for i:=0 to N_PlanesA-1 do begin
    Len := Length(FacesA[i]);
    if Len>=3 then begin

      // CCW ordenen
      reSort := SortVectorList(FacesA[i], BrushPlanes[i].Normal);
{
if not reSort then begin
  BrushPlanes[i].Normal := InverseVector(BrushPlanes[i].Normal);
  BrushPlanes[i].Distance := -BrushPlanes[i].Distance;
end;
}
      // U- & V-as voor het texture-coordinaat-stelsel uitrekenen
      CalcUVAxis(BrushPlanes[i], BrushPlanes[i].TextureAxisU, BrushPlanes[i].TextureAxisV);

      //
      LF := Length(Faces);
      LV := Length(Vertices);
      // punten toevoegen als een face van de map..
      SetLength(Faces, LF+1);
      N_Faces := LF+1;
      Faces[LF].N_Vertices := Len;
      Faces[LF].startVertIndex := LV;
      Faces[LF].Normal := BrushPlanes[i].Normal;
      Faces[LF].ShaderName := BrushPlanes[i].ShaderName;
      Faces[LF].TextureIndex := BrushPlanes[i].TextureIndex;
      // Deze vertices toevoegen..
      SetLength(Vertices, LV+Len);
      N_Vertices := LV+Len;
      for j:=0 to Len-1 do begin
        Vertices[LV+j].Normal := BrushPlanes[i].Normal;
        Vertices[LV+j].Position := FacesA[i][j];
        // de texture-coördinaten uitrekenen
        Vertices[LV+j].TextureCoord := CalcTextureCoords(BrushPlanes[i], Vertices[LV+j].Position, BrushPlanes[i].TextureIndex);
      end;

      // de texture-coördinaten normaliseren naar een bereik[-1..1]
      // Dit moet per polygon worden verwerkt.
//      CorrectTextureCoords(LV, Len);
    end;
  end;

  for i:=0 to N_PlanesA-1 do SetLength(FacesA[i], 0);
  SetLength(FacesA, 0);
  SetLength(BrushPlanes, 0);
  // na verwerking van de brush, de stringlist legen voor de volgende verwerking
  SLB.Clear;
end;


procedure TLevelMap.ProcessClass(var SL: TStringList);
var i: integer;
    SLB: TStringList;
    Level: integer;
    isClassname,
    isWorldspawn: boolean;
begin
  StatusBar.SimpleText := 'Processing class: worldspawn..';

  // bepaal de classname voor deze gelezen class info-blok..
  // dat is de eerste regel in de stringlist.
  if SL.Count <= 0 then Exit;
  // !NB: SL.Strings[0] = '{' nu..
  //      SL.Strings[SL.Count-1] = '}'

  // brushes zoeken en verwerken..
  // Maar dan alleen als ze onderdeel zijn van de blok: "classname" "worldspawn".
  // Al die andere info is game-gerelateerd, en daar heb ik niks aan.

  i := 0;
  repeat
    isClassname := (Pos('"classname"', SL.Strings[i])>0);
    isWorldspawn := (isClassname and (Pos('worldspawn', SL.Strings[i])>0));
    if isWorldspawn then Break;
    Inc(i);
  until (i>SL.Count-1) {or (SL.Strings[i]='{')};

  if isWorldspawn then begin
    SLB := TStringList.Create;
    SLB.Clear;
    Level := 0;
    for i:=0 to SL.Count-1 do begin
      if (Level=2) and (SL.Strings[i]<>'}') then SLB.Add(SL.Strings[i]);
      if SL.Strings[i] = '{' then Inc(Level) else
      if SL.Strings[i] = '}' then begin
        Dec(Level);
        // Is er een compleet Brush-blok ingelezen in de stringlist?..dan verwerken.
        if Level<2 then ProcessBrush(SLB);
      end;
    end;
    SLB.Free;
  end;
  // na verwerking van de class, de stringlist legen voor de volgende verwerking
  SL.Clear;
end;


function TLevelMap.LoadMAP(const Filename: string; cStatusBar:TStatusBar): Boolean;
var F : TextFile;
    s: string;
    sl, slFile: TStringList;
    Level, LineNr: integer;
begin
  Result := false;
  StatusBar := cStatusBar;
  N_Brushes := 0;
  MapLoaded := false;
  MapName := Filename;
  s := ExtractFilename(MapName);
  MapName := Copy(s,1,Length(s)-Length(ExtractFileExt(MapName)));

  // object legen..
  StatusBar.SimpleText := 'Loading map..';
  Clear;
  SetLength(TextureSizes, 0);
  if not FileExists(Filename) then Exit;

  // eerst de hele file inlezen in een stringlist
  slFile := TStringList.Create;
  slFile.Clear;
  slFile.LoadFromFile(Filename);
  // tbv. per regel lezen & verwerken van het ASCII-bestand..
  sl := TStringList.Create; //de stringlist aanmaken..
  sl.Clear;

  SetLength(Faces, 0);
  SetLength(Vertices, 0);
  N_Faces := 0;
  N_Vertices := 0;

  try

    Level := 0; //voor verwerking {} binnen {}
    for LineNr:=0 to slFile.Count-1 do begin
      // Lees een compleet blok tussen de eerstvolgend gevonden { } tekens
      s := slFile.Strings[LineNr];
      // commentaar en lege regels negeren..
      if (Pos('//', s)=0) and (s<>'') then begin //geen commentaar = 0, wel commentaar > 0
        sl.Add(s);
        if s = '{' then Inc(Level) else    // Het begin van een blok?..
        if s = '}' then begin              // Het einde van een blok?..
          Dec(Level);
          // Is er een compleet ClassName-blok ingelezen in de stringlist?..dan verwerken.
          if Level = 0 then begin
            ProcessClass(sl);
            Break; // alleen de eerste entity (worldspawn) verwerken
          end;
        end;
      end;
    end;
(*
    // Alle textures van deze map laden en aanmaken in OpenGL
    InitTextures;
*)    
  finally
    //de stringlists verwijderen.
    sl.Free;
    slFile.Free;
    // lookup-array tbv. textures
    SetLength(TextureSizes, 0);
  end;
  MapLoaded := true;
  Result := true;
end;


procedure TLevelMap.DisplayMap(CameraPosition: TVector);
var i,j: integer;
    N,V1,V2,V3: TVector;
    doTexturing, doDrawFace: boolean;
begin
  if not MapLoaded then Exit;

  glDepthFunc(GL_LESS);     //z-buffer 1e gang..(alles wat dichterbij ligt, dan wat al getekend is)
  glDisable(GL_LIGHTING);
  glDisable(GL_BLEND);
  glFrontFace(GL_CCW);
  glCullFace(GL_BACK);
  glEnable(GL_CULL_FACE);
  glPolygonMode(GL_FRONT, GL_FILL);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE); //GL_DECAL, GL_MODULATE, GL_REPLACE
(*
  glVertexPointer(3, GL_FLOAT, sizeof(TMapVertex), @Vertices[0].Position);
  glEnableClientState(GL_VERTEX_ARRAY);

  glNormalPointer(GL_FLOAT, sizeof(TMapVertex), @Vertices[0].Normal);
  glEnableClientState(GL_NORMAL_ARRAY);

  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
*)

  // het aantal getekende faces resetten
  N_FacesDrawn := 0;

  // alle faces doorlopen
  for i:=0 to Length(Faces)-1 do begin

    // ligt er 1 punt van de face binnen het frustum?  dan tekenen..
    doDrawFace := false;
    for j:=0 to Faces[i].N_Vertices-1 do begin
      if OGL.Frustum.PointInside(Vertices[Faces[i].startVertIndex+j].Position) then begin
        doDrawFace := true;
        Break;
      end;
    end;

    //alleen tekenen als de face in het frustum is
    if doDrawFace then begin
      Inc(N_FacesDrawn);
//    glDrawArrays(GL_TRIANGLE_FAN, Faces[i].startVertIndex, Faces[i].N_Vertices);
//      glDrawArrays(GL_POLYGON, Faces[i].startVertIndex, Faces[i].N_Vertices);

      // texture
      doTexturing := (Faces[i].TextureIndex > -1);
      if doTexturing then begin
        // opac afbeelden
        glDepthMask(GL_TRUE);
        glDepthFunc(GL_LESS);
        glDisable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE);
        //
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, Textures[Faces[i].TextureIndex].Handle);
        // de textured face afbeelden
        glBegin(GL_POLYGON);
          glColor3f(1.0, 1.0, 1.0);
          glNormal3f(Faces[i].Normal.X, Faces[i].Normal.Y, Faces[i].Normal.Z);
          for j:=0 to Faces[i].N_Vertices-1 do begin
            if doTexturing then glTexCoord2f(Vertices[Faces[i].startVertIndex+j].TextureCoord.X, Vertices[Faces[i].startVertIndex+j].TextureCoord.Y);
            glVertex3fv(@Vertices[Faces[i].startVertIndex+j].Position);
          end;
        glEnd;

      end else begin
        // transparant afbeelden
        glDepthMask(GL_TRUE);
        glDepthFunc(GL_LEQUAL);
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_SRC_ALPHA);
        //
        glDisable(GL_TEXTURE_2D);
        glBegin(GL_POLYGON);
          glColor4f(1,1,1, 0.2); //entity kleur
          glNormal3f(Faces[i].Normal.X, Faces[i].Normal.Y, Faces[i].Normal.Z);
          for j:=0 to Faces[i].N_Vertices-1 do begin
            glVertex3fv(@Vertices[Faces[i].startVertIndex+j].Position);
          end;
        glEnd;

      end;

    end;
  end;

  glDepthFunc(GL_LESS);
  glDisable(GL_BLEND);
  glBlendFunc(GL_ONE, GL_ONE);
(*
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_NORMAL_ARRAY);
*)
end;



function TLevelMap.ConvertToMD3(var MD3: TMD3): boolean;
const FrameName:array[0..15] of char = 'C MAP Convert'#0'  ';
      WeldDistance = 0.15;
type TIntArray = array of Integer;
var Shaders: TStringList;
    sh, msg: string;
    s,i,i2,f,f2,j, Len,LenFaces,LenVerts,LenFaceVerts,
    idx,idxTexture,idxTextureOld,idxOld,idxOld2, NrWelt: integer;
    xchg,done,done2,welt: TIntarray;
    N: word;
    MinX,MaxX,MinY,MaxY,MinZ,MaxZ: Single; //boundingbox
    V, Normal: TVector;
    b: boolean;
//--
  function GetNewIndex(var Arr:TIntArray; OldIndex:integer) : integer;
  var Len,Count,e: integer;
  begin
    Result := -1;
    Len := Length(Arr);
    for e:=0 to Len-1 do
      if Arr[e]=OldIndex then begin
        Result := e;
        Exit;
      end;
    // niet gevonden in array, dus nu toevoegen
    if Result = -1 then begin
      SetLength(Arr, Len+1);
      Arr[Len] := OldIndex;
      Result := Len;
    end;
  end;
//--
begin
  Result := false;
  if not MapLoaded then Exit;

  MD3.Clear;

  Shaders := TStringList.Create;
  Shaders.CaseSensitive := false;
  try

    // alle faces doorlopen op zoek naar unieke shaders
    for f:=0 to Length(Faces)-1 do begin
      sh := Faces[f].ShaderName;
      if Pos('common/', sh)>0 then Continue; // common shaders negeren..
      if sh='NULL' then Continue; // lege shaders negeren..
      if Shaders.IndexOf(sh) = -1 then Shaders.Add(sh);
    end;
    // MD3 limiet controle
    if Shaders.Count > MD3_MAX_SURFACES then begin
      msg := 'MAX_SURFACES limit exceeded: '+ IntToStr(Shaders.Count) +' > '+ IntToStr(MD3_MAX_SURFACES) +#13#10+
             'Too many shaders/textures used..';
      ShowMessage(msg);
      MD3.Clear;
      Exit;
    end;

    // bounding box
    MinX := 3.3E38;
    MaxX := -1.4E44;
    MinY := 3.3E38;
    MaxY := -1.4E44;
    MinZ := 3.3E38;
    MaxZ := -1.4E44;

    // surfaces array vullen
    SetLength(MD3.Header.Surfaces, Shaders.Count);
    for s:=0 to Shaders.Count-1 do begin
      // surface header
      MD3.Header.Surfaces[s].Values.Ident         := IDP3;
      MD3.Header.Surfaces[s].Values.Flags         := 0;
      MD3.Header.Surfaces[s].Values.Num_Frames    := 1;
      MD3.Header.Surfaces[s].Values.Name          := MD3.StringToQ3('surface'+IntToStr(s));

      // shader
      MD3.Header.Surfaces[s].Values.Num_Shaders := 1;
      SetLength(MD3.Header.Surfaces[s].Shaders, 1);
      MD3.Header.Surfaces[s].Shaders[0].Name := MD3.StringToQ3('textures/'+Shaders.Strings[s]);

      // index conversie array
      SetLength(xchg, 0);
      LenFaces := 0; // meteen het aantal faces in dit surface tellen
      LenFaceVerts := 0;
      for f:=0 to Length(Faces)-1 do begin
        if Faces[f].ShaderName <> Shaders.Strings[s] then Continue;
        // totaal vertices in dit surface
        Inc(LenFaceVerts, Faces[f].N_Vertices);
        // index conversie array vullen voor dit surface
        for i:=0 to Faces[f].N_Vertices-1 do GetNewIndex(xchg, Faces[f].startVertIndex+i);

//Inc(LenFaces,Faces[f].N_Vertices-2);
        case Faces[f].N_Vertices of
          3: Inc(LenFaces,1); // 1 tri per triangle :-)
          4: Inc(LenFaces,2); // 2 tris per quad
        else
//!       // only use quad-shaped faces..
//!       msg := 'Invalid BRUSH shape for this tool version: FACE_VERTS '+ IntToStr(Faces[f].N_Vertices) +' > 4' +#13#10+
//!              'Too many vetices used in face..';
//!       ShowMessage(msg);
//!       MD3.Clear;
//!       Exit;
//!     end;
          // use any shaped face..                    // !
          Inc(LenFaces, Faces[f].N_Vertices-2);       // !
        end;

      end;
      LenVerts := Length(xchg);

      // Vertex:
LenVerts:=LenFaceVerts; //!!!!!DEBUG!!!!!
      // MD3 limiet controle
      if LenVerts > MD3_MAX_VERTS then begin
        msg := 'MAX_VERTS limit exceeded: '+ IntToStr(LenVerts) +' > '+ IntToStr(MD3_MAX_VERTS) +#13#10+
               'Too many vetices used with the same shader/texture..' +#13#10+
               'Shadername: '+ Shaders.Strings[s];
        ShowMessage(msg);
        MD3.Clear;
        Exit;
      end;
      // vertex-data & textureCoords overnemen..
      MD3.Header.Surfaces[s].Values.Num_Verts := LenVerts;
      SetLength(MD3.Header.Surfaces[s].Vertex, LenVerts);
      SetLength(MD3.Header.Surfaces[s].TextureCoords, LenVerts);
      for f:=0 to Length(Faces)-1 do begin
        if Faces[f].ShaderName <> Shaders.Strings[s] then Continue;
        for i:=0 to Faces[f].N_Vertices-1 do begin
{!!
idxOld := Faces[f].VertIndex[i];
}
          idxOld := Faces[f].startVertIndex+i;
idxTextureOld := Faces[f].startVertIndex+i;
          idx := GetNewIndex(xchg, idxOld);
          MD3.Header.Surfaces[s].Vertex[idx].X := Round(Vertices[idxOld].Position.X * MD3_XYZ_SCALE_1);
          MD3.Header.Surfaces[s].Vertex[idx].Y := Round(Vertices[idxOld].Position.Y * MD3_XYZ_SCALE_1);
          MD3.Header.Surfaces[s].Vertex[idx].Z := Round(Vertices[idxOld].Position.Z * MD3_XYZ_SCALE_1);
          MD3.EncodeNormal(Vertices[idxOld].Normal, N);
          MD3.Header.Surfaces[s].Vertex[idx].Normal := N;
          // texture-coördinaten
{          MD3.Header.Surfaces[s].TextureCoords[idx].S := Vertices[idxOld].TextureCoord.X;
          MD3.Header.Surfaces[s].TextureCoords[idx].T := 1.0-Vertices[idxOld].TextureCoord.Y;}
MD3.Header.Surfaces[s].TextureCoords[idx].S := Vertices[idxTextureOld].TextureCoord.X;
MD3.Header.Surfaces[s].TextureCoords[idx].T := 1.0-Vertices[idxTextureOld].TextureCoord.Y;
          // boundingbox
          if Vertices[idxOld].Position.X < MinX then MinX := Vertices[idxOld].Position.X;
          if Vertices[idxOld].Position.X > MaxX then MaxX := Vertices[idxOld].Position.X;
          if Vertices[idxOld].Position.Y < MinY then MinY := Vertices[idxOld].Position.Y;
          if Vertices[idxOld].Position.Y > MaxY then MaxY := Vertices[idxOld].Position.Y;
          if Vertices[idxOld].Position.Z < MinZ then MinZ := Vertices[idxOld].Position.Z;
          if Vertices[idxOld].Position.Z > MaxZ then MaxZ := Vertices[idxOld].Position.Z;
        end;
      end;

      // Triangles:
      // MD3 limiet controle
      if LenFaces > MD3_MAX_TRIANGLES then begin
        msg := 'MAX_TRIANGLES limit exceeded: '+ IntToStr(LenFaces) +' > '+ IntToStr(MD3_MAX_TRIANGLES) +#13#10+
               'Too many brushes used with the same shader/texture..' +#13#10+
               'Shadername: '+ Shaders.Strings[s];
        ShowMessage(msg);
        MD3.Clear;
        Exit;
      end;
      // triangle-data overnemen..
      MD3.Header.Surfaces[s].Values.Num_Triangles := LenFaces;
      SetLength(MD3.Header.Surfaces[s].Triangles, LenFaces);
      idx := 0;
      for f:=0 to Length(Faces)-1 do begin
        if Faces[f].ShaderName <> Shaders.Strings[s] then Continue;
        MD3.Header.Surfaces[s].Triangles[idx].Index1 := GetNewIndex(xchg, Faces[f].startVertIndex+2);
        MD3.Header.Surfaces[s].Triangles[idx].Index2 := GetNewIndex(xchg, Faces[f].startVertIndex+1);
        MD3.Header.Surfaces[s].Triangles[idx].Index3 := GetNewIndex(xchg, Faces[f].startVertIndex+0);
{MD3.Header.Surfaces[s].Triangles[idx].Index1 := GetNewIndex(xchg, Faces[f].VertIndex[2]);
MD3.Header.Surfaces[s].Triangles[idx].Index2 := GetNewIndex(xchg, Faces[f].VertIndex[1]);
MD3.Header.Surfaces[s].Triangles[idx].Index3 := GetNewIndex(xchg, Faces[f].VertIndex[0]);}
        Inc(idx);

        // quads maken van rechthoekige brushes..
        if Faces[f].N_Vertices=4 then begin
          MD3.Header.Surfaces[s].Triangles[idx].Index1 := GetNewIndex(xchg, Faces[f].startVertIndex+0);
          MD3.Header.Surfaces[s].Triangles[idx].Index2 := GetNewIndex(xchg, Faces[f].startVertIndex+3);
          MD3.Header.Surfaces[s].Triangles[idx].Index3 := GetNewIndex(xchg, Faces[f].startVertIndex+2);
{MD3.Header.Surfaces[s].Triangles[idx].Index1 := GetNewIndex(xchg, Faces[f].VertIndex[0]);
MD3.Header.Surfaces[s].Triangles[idx].Index2 := GetNewIndex(xchg, Faces[f].VertIndex[3]);
MD3.Header.Surfaces[s].Triangles[idx].Index3 := GetNewIndex(xchg, Faces[f].VertIndex[2]);}
          Inc(idx);
        end else

        //! use any shaped face..
        if Faces[f].N_Vertices>4 then begin
          for i:=1 to Faces[f].N_Vertices-3 do begin
            MD3.Header.Surfaces[s].Triangles[idx].Index1 := GetNewIndex(xchg, Faces[f].startVertIndex+i+2);
            MD3.Header.Surfaces[s].Triangles[idx].Index2 := GetNewIndex(xchg, Faces[f].startVertIndex+i+1);
            MD3.Header.Surfaces[s].Triangles[idx].Index3 := GetNewIndex(xchg, Faces[f].startVertIndex+0);
            Inc(idx);
          end;
        end;

      end;
    end;

    // Header
    with MD3.Header.Values do begin
      Ident := IDP3;
      Version := 15;
      Name := MD3.StringToQ3('C_Converted_From_Map_'+MapName);
      Flags := 0;
      Num_Frames := 1;   // geen animatie
      Num_Tags := 0;     // geen tags
      Num_Surfaces := Shaders.Count;
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

    Result := true;
  finally
    SetLength(xchg, 0);
    Shaders.Free;
  end;
(*
  // Offsets worden in SaveToFile gezet
  SaveAsDialog.DefaultExt := '.MD3';
  SaveAsDialog.Filter := 'Quake 3 model (.MD3)|*.MD3';
  SaveAsDialog.Title := 'Save a model';
  if not SaveAsDialog.Execute then Exit;
  if not MD3.SaveToFile(SaveAsDialog.FileName) then Exit;
  gbModel.Caption := ExtractFilename(SaveAsDialog.FileName);
*)
end;




initialization
  LevelMAP := TLevelMap.Create;
finalization
  LevelMAP.Free;

end.


