unit uFont;
interface
uses Windows, OpenGL;

type
  // tbv. regel indeling
  TLineVAlignment = (laTop, laBottom {, laLeft, laRight});

const
  // de verzameling characters in het OpenGL font
  FirstCharacter = 32;
  LastCharacter  = 126;
  N_Characters   = LastCharacter - FirstCharacter + 1;
  // tbv. regel indeling
  DefLineSpacing = 0;  //2/12;  //2 pixels per 12px font verhouding


type
  TGLFont = class(TObject)
  private
    // de eerste displaylist van een compleet font
    DisplayListBase: GLuint;
    // het true-type Windows font in 256 display-lists (voor elk character 1)
    GMF: array[FirstCharacter..N_Characters-1] of GLYPHMETRICSFLOAT;
    // geladen font instellingen
    Family: string;
    SizePx: integer;  // de grootte van het font in pixels
    is3D: boolean;
    procedure PrintText(const Value: string);
  published
  public
    // object
    constructor Create;
    destructor Destroy; override;
    //
    function CreateFontDLs(DC: HDC; RC: HGLRC; Fontname: string; FontSize: integer; Font3D: boolean) : GLuint;
    procedure DeleteFont;
    function IsFontLoaded : boolean;
    // op pixel afstand vanaf de linker-onder hoek van het scherm
    procedure PrintXY(X,Y: integer; const Value: string; ScrW,ScrH: integer);
    procedure PrintXYZ(X,Y,Z: GLfloat; const Value: string);
    // per regel afbeelden..vanaf boven, of vanaf beneden (Alignment)
    procedure PrintLine(Row: integer; const Value: string; VAlign: TLineVAlignment; ScrW,ScrH: integer);
  end;


  // een verzameling fonts
  TGLFonts = class(TObject)
  private
    fFonts: array of TGLFont;
    function GetFont(I:integer) : TGLFont;
    function GetFontCount : integer;
    {procedure SetFont(I:integer; Value: TGLFont);}
  published
//    property Font[I:integer]:TGLFont read GetFont {write SetFont};
  public
    property Font[I:integer]:TGLFont read GetFont {write SetFont};
    property FontCount:integer read GetFontCount;
    // object
    constructor Create;
    destructor Destroy; override;
    //
    function AddFont(DC: HDC; RC: HGLRC; Fontname: string; FontSize: integer; Font3D: boolean) : GLuint;
  end;



implementation

{ TGLFont }
constructor TGLFont.Create;
begin
  DisplayListBase := 0; //ongeldige DisplayList handle
  Family := '';
  SizePx := 0;
  is3D := false;
end;

destructor TGLFont.Destroy;
begin
  DeleteFont;
  //
  inherited;
end;



function TGLFont.CreateFontDLs(DC: HDC; RC: HGLRC; Fontname: string; FontSize: integer; Font3D: boolean) : GLuint;
var F,F1: HFONT;
    b: boolean;
begin
  Family := Fontname;
  SizePx := FontSize;
  is3D := Font3D;
  {wglMakeCurrent(DC, RC);}
  glPushMatrix;
  // displaylist handles reserveren..
  DisplayListBase := glGenLists(N_Characters);
  // maak een verwijzing naar het gewenste font (italic, underline, strike, weight,..)
  F := CreateFont(FontSize, 0, 0, 0, FW_NORMAL, 0, 0, 0, ANSI_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY, FF_DONTCARE + DEFAULT_PITCH, PChar(Fontname));
  F1 := SelectObject(DC, F);
  // 2D of 3D?
  if Font3D then
    // ==== outlined font ======================================================
    // Maak een array van displaylists voor een true-type font.
    // De glyphs 0..255 (256 in totaal) worden met een 0.05 extrusie een bepaalde
    // 3D-"dikte" gegeven. De deviation staat standaard op 0.0, dwz. dat de
    // characters net zo precies worden als het font.
    //
    // selecteer het font en glyphes aanmaken
    b := wglUseFontOutlines(DC, FirstCharacter, N_Characters, DisplayListBase, 0.0, 0.05, WGL_FONT_POLYGONS, @GMF[FirstCharacter])
  else
    // ==== bitmapped font =====================================================
    b := wglUseFontBitmaps(DC, FirstCharacter, N_Characters-1, DisplayListBase);
  SelectObject(DC, F1);
  DeleteObject(F);
  if not b then
    if DisplayListBase > 0 then begin
      glDeleteLists(DisplayListBase, N_Characters);
      DisplayListBase := 0;
      Family := '';
      {Msg("FontList is niet aangemaakt!");}
    end;
  glPopMatrix;
  Result := DisplayListBase;
end;

procedure TGLFont.DeleteFont;
{var i: integer;}
begin
  // DisplayLists wissen..
  if DisplayListBase > 0 then glDeleteLists(DisplayListBase, N_Characters);
(*
  if DisplayListBase > 0 then begin
    for i:=0 to N_Characters-1 do
      if glIsList(DisplayListBase+i) then glDeleteLists(DisplayListBase+i, 1);
  end;
*)
  DisplayListBase := 0;
  Family := '';
  SizePx := 0;
  is3D := false;
end;

function TGLFont.IsFontLoaded: boolean;
begin
  Result := (DisplayListBase<>0);
end;



procedure TGLFont.PrintText(const Value: string);
var L: integer;
begin
  L := Length(Value);
  glDisable(GL_LIGHTING);
  glDisable(GL_TEXTURE_2D);
  glDisable(GL_BLEND);
  glPushAttrib(GL_LIST_BIT);
  glListBase(DisplayListBase - FirstCharacter);
  glCallLists(L, GL_UNSIGNED_BYTE, @Value[1]);
  glPopAttrib;
end;

procedure TGLFont.PrintXY(X, Y: integer; const Value: string; ScrW,ScrH: integer);
begin
//  glPushMatrix;
  {glPushAttrib(GL_TRANSFORM_BIT or GL_VIEWPORT_BIT);}
  glDisable(GL_DEPTH_TEST);
  // orthogonaal afbeelden (geen perspectief)
  glViewPort(0,0,ScrW,ScrH);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho(0,ScrW, 0,ScrH, -1,1);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  // de tekenpositie instellen en de tekst afbeelden
  glRasterPos2i(X,Y); //een kleine correctie..
  PrintText(Value);
  //
  {glPopAttrib;}
//  glPopMatrix;
end;

procedure TGLFont.PrintLine(Row: integer; const Value: string; VAlign: TLineVAlignment; ScrW, ScrH: integer);
const MarginLeft=2;  MarginBottom=2;
var LineHeight, NLines,NLines1, DeltaPx,
    X,Y: integer;
begin
  // bereken het aantal regels met de huidige viewport dimensies
  LineHeight := SizePx + Round(DefLineSpacing);
  NLines := ScrH div LineHeight;
  DeltaPx := ScrH - (NLines * LineHeight);
  NLines1 := NLines - 1;
  // regel nog in beeld?
  if (Row<0) or (Row>NLines1) then Exit;
  // positie vanaf links
  X := MarginLeft;
  // regel vanaf boven? of onder?..
  case VAlign of
    laTop    : Y := (NLines1-Row)*LineHeight + DeltaPx;
    laBottom : Y := Row*LineHeight;
  end;
  Y := Y + MarginBottom;
  PrintXY(X,Y, Value, ScrW,ScrH);
end;

procedure TGLFont.PrintXYZ(X, Y, Z: GLfloat; const Value: string);
begin
  glPushMatrix;
  glFrontFace(GL_CW);
  glCullFace(GL_BACK);
  glEnable(GL_CULL_FACE);
  //
  glRasterPos3f(X,Y,Z);
  PrintText(Value);
  glPopMatrix;
end;



{--- TGLFonts -----------------------------------}
constructor TGLFonts.Create;
begin
  SetLength(fFonts, 0);
end;

destructor TGLFonts.Destroy;
var f: integer;
begin
  for f:=Low(fFonts) to High(fFonts) do
    with fFonts[f] do begin
      if IsFontLoaded then DeleteFont;
      Free;
    end;
  SetLength(fFonts, 0);
  //
  inherited;
end;

// property
function TGLFonts.GetFont(I: integer): TGLFont;
begin
  Result := nil;
  if (I<Low(fFonts)) or (I>High(fFonts)) then Exit;
  Result := fFonts[I];
end;

function TGLFonts.GetFontCount: integer;
begin
  Result := Length(fFonts);
end;



function TGLFonts.AddFont(DC: HDC; RC: HGLRC; Fontname: string; FontSize: integer; Font3D: boolean): GLuint;
var Len: integer;
begin
  Len := Length(fFonts);
  SetLength(fFonts, Len+1);
  fFonts[Len] := TGLFont.Create;
  Result := fFonts[Len].CreateFontDLs(DC,RC, Fontname,FontSize, Font3D);
end;



end.
