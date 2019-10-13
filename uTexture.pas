unit uTexture;
interface
uses OpenGL, Windows, Graphics, Classes, JPEG, SysUtils;

const
  // standaard waarden
  DefaultGammaFactor = 1.0;
  DefaultTexEnvMode = GL_REPLACE;

  // Targa (.TGA) ondersteunde file types
  TGA_unCompressed = 2;
  TGA_RLECompressed = 10;

type
  // RGB
  TColorRGB = packed record
                R,G,B: Byte;
              end;
  PColorRGB = ^TColorRGB;
  TRGBList = packed array[0..0] of TColorRGB;
  PRGBList = ^TRGBList;

  // RGBA
  TColorRGBA = packed record
                 R,G,B,A: Byte;
               end;
  PColorRGBA = ^TColorRGBA;
  TRGBAList = packed array[0..0] of TColorRGBA;
  PRGBAList = ^TRGBAList;

  // Targa (.TGA) file header
  TTargaHeader = packed record
    bIDFieldSize : Byte;                  // Characters in ID field
    bClrMapType : Byte;                   // Color map type
    bImageType : Byte;                    // Image type
   {lClrMapSpec : array[0..4] of Byte;    // Color map specification}
    lClrMapSpec : packed record
      wFirstEntryIndex: Word;
      wLength: Word;
      bEntrySize: Byte;
    end;
    wXOrigin : Word;                      // X origin
    wYOrigin : Word;                      // Y origin
    wWidth : Word;                        // Bitmap width
    wHeight : Word;                       // Bitmap height
    bBitsPixel : Byte;                    // Bits per pixel
    bImageDescriptor : Byte;              // Image descriptor
  end;

  TLoadedTexture = record
                     Filename: string;
                     TextureHandle: GLuint;
                     AlphaData: boolean;
                     Width, Height: integer;
                   end;

  TObjTexture = class(TObject)
                private
                  SearchPaths: array of string;
                  AlreadyLoaded: array of TLoadedTexture;
                  //
                  HasAlphaData: boolean;
                  PixelData: pRGBAlist;
                  vGamma: Single;
                  //24b RGB BMP omzetten naar 32b RGBA pixeldata
                  procedure GetPixelDataFromBitmap(var BMP: TBitmap; var PixelData: pRGBAlist);
                  //24b pixeldata gamma aanpassing
                  procedure GammaPixelData(const PixelData: Pointer; Width,Height: Integer; PixelFormatIn: GLuint; Factor: Single);
                  // bepaal of een file met een opgegeven naam al eens is geladen,
                  // en geef indien de texture-handle terug..
                  procedure AddLoadedTexture(Filename:string; TextureHandle:GLuint; HasAlpha:boolean; Width,Height:integer);
                  function TextureAlreadyLoaded(Filename: string; var TextureHandle : GLuint) : boolean;
                  // bestanden laden en textures aanmaken..
                  function LoadTextureJPG(Filename: string) : GLuint;
                  function LoadTextureBMP(Filename: string) : GLuint;
                  function LoadTextureTGA(Filename: string) : GLuint;
                  function LoadTextureRAW(Filename: string) : GLuint;
                public
                  // object
                  constructor Create;
                  destructor Destroy; override;
                  // de gamma factor instellen voor volgende textures
                  procedure Set_GammaFactor(Gamma: Single); //1.0 = standaard (geen aanpassing)
                  // een texture aanmaken
                  function TextureFromPixelData(Width, Height: Integer; PixelFormatIn,PixelFormatOut: GLuint; Mipmaps: boolean; const PixelData: Pointer) : GLuint;
                  // pixeldata schrijven naar een afbeelding-bestand (.BMP)
                  procedure SaveToFile(const PixelData: Pointer; Width, Height: Integer; PixelFormatIn: GLuint; Filename: string);
                  // voeg een directory toe aan de lijst zoekpaden voor textures
                  procedure AddSearchDir(Path: string);
                  function SearchDir_Count : integer; //het aantal paden om te doorzoeken naar textures
                  function Texture_Count : integer;   //het aantal geladen textures
                  // zoek een texture-bestand op alleen de naam, en resulteer:  pad+filenaam+extensie,.. anders ''
                  function FindTexture(var Filename: string) : boolean;
                  // Laad een texture en geef de texture-handle terug..
                  // Als de texture al eens is geladen, geef de handle van een reeds bestaande texture terug..
                  // (OpenGL moet hiervoor actief zijn)
                  function LoadTexture(Filename: string) : GLuint; overload;
                  function LoadTexture(Filename: string; Gamma: Single): GLuint; overload;
                  // textures wissen
                  procedure DeleteTexture(TextureHandle: GLuint);
                  procedure DeleteTextures;

                  //-- hulpfuncties
                  // gegevens opvragen van een texture-bestand, zonder de texture aan te maken in OpenGL
                  // Het resultaat = false, als de texture niet wordt gevonden, anders true.
                  function GetTextureInfo(Filename: string; var Extension: string; var Width,Height: Integer): boolean;
                  // controleer of een texture een alpha-kanaal bevat
                  function HasAlpha(TextureHandle: GLuint) : boolean;
                end;

(*
var Textures : TObjTexture;
*)


implementation
uses Math, uOpenGL;


{ TObjTexture }
constructor TObjTexture.Create;
begin
  // Object initiëren
  inherited;
  // Data initialiseren
  SetLength(SearchPaths, 0);
  SetLength(AlreadyLoaded, 0);
  Set_GammaFactor(DefaultGammaFactor);
end;

destructor TObjTexture.Destroy;
begin
  // Data finaliseren
  DeleteTextures;
  SetLength(SearchPaths, 0);
  SetLength(AlreadyLoaded, 0);
  // Object finaliseren
  inherited;
end;




function TObjTexture.Texture_Count: integer;
begin
  Result := Length(AlreadyLoaded);
end;

procedure TObjTexture.AddSearchDir(Path: string);
var L: integer;
begin
  L := Length(SearchPaths);
  SetLength(SearchPaths, L+1);
  SearchPaths[L] := Path;
end;

function TObjTexture.SearchDir_Count: integer;
begin
  Result := Length(SearchPaths);
end;

procedure TObjTexture.Set_GammaFactor(Gamma: Single);
begin
  if abs(Gamma) <> vGamma then vGamma := abs(Gamma);
end;



procedure TObjTexture.GammaPixelData(const PixelData: Pointer; Width,Height: Integer; PixelFormatIn: GLuint; Factor: Single);
var r,g,b, m: single;
    r_,g_,b_: byte;
    pixel: integer;
    bpp: byte; //bytes per pixel
begin
  // alleen 24b-RGB RGB en 32b-RGBA ondersteund vooralsnog..
  if PixelFormatIn = GL_RGB then bpp := 3 else
  if PixelFormatIn = GL_RGBA then bpp := 4 else Exit;

  for pixel:=0 to Width*Height-1 do begin
    //24b RGB waarden lezen
    asm
      mov ecx, PixelData
      mov al, [ecx]
      mov r_, al
      mov al, [ecx+1]
      mov g_, al
      mov al, [ecx+2]
      mov b_, al
    end;
    r := r_ * Factor;
    g := g_ * Factor;
    b := b_ * Factor;
    m := max(r,max(g,b));
    if m>255.0 then begin
      m := m / 255.0;
      r := r / m;
      g := g / m;
      b := b / m;
    end;
    r_ := trunc(r);
    g_ := trunc(g);
    b_ := trunc(b);
    //pixeldata terug schrijven..
    asm
      mov ecx, PixelData
      mov al, r_
      mov [ecx], al
      mov al, g_
      mov [ecx+1], al
      mov al, b_
      mov [ecx+2], al
    end;
    //volgende pixel adresseren
    if bpp=3 then begin
      asm
        add PixelData, 3
      end;
    end else begin
      asm
        add PixelData, 4
      end;
    end;
  end;
end;

procedure TObjTexture.GetPixelDataFromBitmap(var BMP: TBitmap; var PixelData: pRGBAlist);
var x,y,W,H: integer;
    pixLine: PRGBlist;
begin
  // BMP-pixelformat = 24b BGR
  W := BMP.Width;
  H := BMP.Height;
  for y:=0 to H-1 do begin
    // De eerste (bovenste) lijn pixels in een BMP begint onderaan
    pixLine := BMP.ScanLine[H-1-y];
    for x:=0 to W-1 do begin
      // RGB is andersom (als BGR) opgeslagen
      PixelData[y*W+x].R := pixLine[x].B;
      PixelData[y*W+x].G := pixLine[x].G;
      PixelData[y*W+x].B := pixLine[x].R;
      PixelData[y*W+x].A := $FF;
    end;
  end;
end;

function TObjTexture.TextureFromPixelData(Width,Height: Integer; PixelFormatIn,PixelFormatOut: GLuint; Mipmaps: boolean; const PixelData: Pointer): GLuint;
var TextureHandle: GLuint;
begin
  glEnable(GL_TEXTURE_2D); // texturing inschakelen
  glGenTextures(1, TextureHandle); //1 vrije texturehandle alloceren
  if TextureHandle>0 then begin
    // evt. gamma-correctie uitvoeren op de pixeldata
    if vGamma <> 1.0 then GammaPixelData(PixelData, Width,Height, PixelFormatIn, vGamma);
    //
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glBindTexture(GL_TEXTURE_2D, TextureHandle);
(*
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP ); //GL_REPEAT
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP );
*)
    if Mipmaps then begin
      glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
      glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      gluBuild2DMipmaps(GL_TEXTURE_2D, PixelFormatIn, Width,Height, PixelFormatOut, GL_UNSIGNED_BYTE, PixelData);
    end else begin
      glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
      glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      glTexImage2D(GL_TEXTURE_2D, 0, PixelFormatIn, Width,Height, 0, PixelFormatOut, GL_UNSIGNED_BYTE, PixelData);
    end;
  end;
  Result := TextureHandle;
end;


function TObjTexture.LoadTextureJPG(Filename: string): GLuint;
var JPG: TJPEGImage;
    BMP: TBitmap;
begin
  Result := 0;  //ongeldige texturehandle..
  // JPG laden..
  JPG := TJPEGImage.Create;
  try
    try
      JPG.LoadFromFile(Filename);
      // een bitmap vullen met pixeldata..
      BMP := TBitmap.Create;
      try
        BMP.Width := JPG.Width;
        BMP.Height := JPG.Height;
        BMP.PixelFormat := pf24bit;
        BMP.HandleType := bmDIB;
        BMP.PixelFormat := pf24bit;  //geen alpha kanaal
        BMP.Canvas.Draw(0,0, JPG);
        BMP.Canvas.Draw(0,0, JPG); //wazig
        // BMP-PixelData van BGR naar RGBA
        GetMem(PixelData, BMP.Width*BMP.Height*4);
        try
          GetPixelDataFromBitmap(BMP, PixelData);
          // RGBA-PixelData naar Texture
          Result := TextureFromPixelData(BMP.Width,BMP.Height, GL_RGB, GL_RGBA, true, PixelData);
          HasAlphaData := false;
        finally
          FreeMem(PixelData); //pixeldata vrijgeven..
        end;
      finally
        BMP.Free;
      end;
    finally
      JPG.Free;
    end;
  except
    Exit;
  end;
end;

function TObjTexture.LoadTextureBMP(Filename: string): GLuint;
var BMP : TBitmap;
begin
  BMP := TBitmap.Create;
  try
    BMP.LoadFromFile(Filename);
    BMP.HandleType := bmDIB;
    BMP.PixelFormat := pf24bit;  //geen alpha kanaal in BMP (als RGB/BGR lezen)
    // BMP-PixelData van BGR naar RGBA
    GetMem(PixelData, BMP.Width*BMP.Height*4);
    try
      GetPixelDataFromBitmap(BMP, PixelData);
      // RGBA-PixelData naar Texture
      Result := TextureFromPixelData(BMP.Width,BMP.Height, GL_RGB,GL_RGBA, true, PixelData);
      HasAlphaData := false;
    finally
      FreeMem(PixelData); //pixeldata vrijgeven..
    end;
  finally
    BMP.Free;
  end
end;

function TObjTexture.LoadTextureTGA(Filename: string): GLuint;
var F : File;
    BytesToRead: integer;
    TGAHeader : TTargaHeader;

    HasPalette,
    IsRLEcompressed,
    FlipH, FlipV: boolean;
    Palette: array of byte;
    P: ^Byte;

    n,i,j, W,H : Integer;
    pixelSize : byte;
    pixels : array of byte;
    chunkHeader : Byte;

    pixRGB : PRGBlist;
    pixRGBA : PRGBAlist;

    RLEPacketHeader,
    RLEPacketLength: byte;
  //--
  procedure CopyPixel(i, PixelSize, Modulo: integer; SwapColors: boolean);
  begin
    case PixelSize of
      3 : begin //RGB of BGR
            if SwapColors then begin
              PixelData[i].R := pixels[(i*PixelSize+2) mod Modulo];  //B
              PixelData[i].G := pixels[(i*PixelSize+1) mod Modulo];  //G
              PixelData[i].B := pixels[(i*PixelSize) mod Modulo];    //R
            end else begin
              PixelData[i].R := pixels[(i*PixelSize) mod Modulo];    //R
              PixelData[i].G := pixels[(i*PixelSize+1) mod Modulo];  //G
              PixelData[i].B := pixels[(i*PixelSize+2) mod Modulo];  //B
            end;
            PixelData[i].A := 255;
          end;
      4 : begin //RGBA of BGRA
            if SwapColors then begin
              PixelData[i].R := pixels[(i*PixelSize+2) mod Modulo];  //B
              PixelData[i].G := pixels[(i*PixelSize+1) mod Modulo];  //G
              PixelData[i].B := pixels[(i*PixelSize) mod Modulo];    //R
              PixelData[i].A := pixels[(i*PixelSize+3) mod Modulo];  //A
            end else begin
              PixelData[i].R := pixels[(i*PixelSize) mod Modulo];    //R
              PixelData[i].G := pixels[(i*PixelSize+1) mod Modulo];  //G
              PixelData[i].B := pixels[(i*PixelSize+2) mod Modulo];  //B
              PixelData[i].A := pixels[(i*PixelSize+3) mod Modulo];  //A
            end;
          end;
    end;
  end;
  //--
begin
  Result := 0;
  // Laad een RLE-compressed of uncompressed .TGA file
  AssignFile(F, Filename);
  try
    {$I-}
    Reset(F, 1);
    {$I+}
    if (IOResult<>0) then Exit;
    // De TGA file-header inlezen
    {$I-}
    BlockRead(F, TGAHeader, SizeOf(TTargaHeader), n);
    {$I+}
    if (IOResult<>0) or (n<>SizeOf(TTargaHeader)) then Exit;
    // TGA-formaat verifiëren
    HasPalette := (TGAHeader.bClrMapType = 1);
    IsRLEcompressed := (TGAHeader.bImageType >= 9);
    pixelSize := TGAHeader.bBitsPixel div 8;
    FlipH := (TGAHeader.bImageDescriptor and (1 shl 4) <> 0);
    FlipV := (TGAHeader.bImageDescriptor and (1 shl 5) = 0);
    W := TGAHeader.wWidth;
    H := TGAHeader.wHeight;

    // evt. palette laden
    if HasPalette then begin
      SetLength(Palette, TGAHeader.lClrMapSpec.wLength * TGAHeader.lClrMapSpec.bEntrySize div 8);
      {$I-}
      BlockRead(F, Palette, SizeOf(Palette), n);
      {$I+}
      if (IOResult<>0) or (n<>SizeOf(Palette)) then Exit;
    end;

    // Pixel-data geheugen alloceren voor RGBA
    GetMem(PixelData, W*H*4);
    try
      if not IsRLEcompressed then begin
        // De pixeldata inlezen
        if (pixelSize=3) or (pixelSize=4) then begin
          BytesToRead := W*H*pixelSize;
          SetLength(pixels, BytesToRead);
          try
            {$I-}
            Blockread(F, pixels[0], BytesToRead, n);
            {$I+}
            if (IOResult<>0) or (n<>BytesToRead) then Exit;
            // pixels overnemen naar texture-pixeldata
            for i:=0 to W*H-1 do CopyPixel(i, pixelSize, BytesToRead, true);
          finally
            SetLength(pixels, 0);
          end;
        end;
      end else begin  //RLE-compressed
        BytesToRead := pixelSize;
        SetLength(pixels, BytesToRead);
        try
          i := 0;
          while i <= W*H-1 do begin
            {$I-}
            Blockread(F, RLEPacketHeader, 1, n);
            {$I+}
            if (IOResult<>0) or (n<>1) then Exit;
            //
            RLEPacketLength := (RLEPacketHeader and $7F) + 1;
            if (RLEPacketHeader and $80) <> 0 then begin //Run Length packet
              {$I-}
              Blockread(F, pixels[0], pixelSize, n);
              {$I+}
              if (IOResult<>0) or (n<>BytesToRead) then Exit;
              //
              for j:=0 to RLEPacketLength-1 do begin
                CopyPixel(i, pixelSize, BytesToRead, true);
                Inc(i);
              end;
            end else begin //raw packet
              for j:=0 to RLEPacketLength-1 do begin
                {$I-}
                Blockread(F, pixels[0], BytesToRead, n);
                {$I+}
                if (IOResult<>0) or (n<>BytesToRead) then Exit;
                //
                CopyPixel(i, pixelSize, BytesToRead, true);
                Inc(i);
              end;
            end;
          end;
        finally
          SetLength(pixels, 0);
        end;
      end;
    finally
      // RGBA-PixelData naar Texture
      {if (pixelSize=3) then
        Result := TextureFromPixelData(W,H, GL_RGB,GL_RGBA, false, PixelData)
      else}
        Result := TextureFromPixelData(W,H, GL_RGBA,GL_RGBA, false, PixelData);
      FreeMem(PixelData);
      HasAlphaData := (pixelSize=4);
    end;
  finally
    CloseFile(F);
    SetLength(Palette, 0);
  end;
end;

function TObjTexture.LoadTextureRAW(Filename: string): GLuint;
begin
  Result := 0;
  HasAlphaData := false;
end;


function TObjTexture.FindTexture(var Filename: string): boolean;
  //-------
  function FileDoesExist(var Filename: string) : boolean;
  var p: integer;
      FP,FN: string;
  begin
    Result := false;
    FP := ExtractFilePath(Filename);
    FN := ExtractFilename(Filename);
    for p:=0 to Length(SearchPaths)-1 do begin
      Filename := SearchPaths[p] + FP + FN;
      Result := FileExists(Filename);
      if Result then Break;
    end;
  end;
  //-------
const Extensions : array[0..2] of string = ('.TGA', '.BMP', '.JPG');
var FP,FN,Ext, s: string;
    e: integer;
begin
  // backslashes maken van slashes
  Filename := StringReplace(Filename, '/', '\', [rfReplaceAll, rfIgnoreCase]);
  //
  s := Filename;
  Result := FileExists(Filename);
  if not Result then begin
    Ext := UpperCase(ExtractFileExt(s));
    if Ext <> '' then
      Result := FileDoesExist(Filename)
    else begin
      FP := ExtractFilePath(s);
      FN := ExtractFilename(s);
      for e:=0 to 2 do begin
        Filename := FP + FN + Extensions[e];
        Result := FileDoesExist(Filename);
        if Result then Exit;
      end;
    end;
  end;
  if not Result then Filename := s;
end;


function TObjTexture.LoadTexture(Filename: string): gluint;
var FN,Ext: string;
    W,H: integer;
begin
  Result := 0;  //ongeldige texturehandle..
  FN := Filename;
  if not FindTexture(FN) then Exit; //doorzoek evt. alle searchdirs..
  if not TextureAlreadyLoaded(FN, Result) then begin
    // laden die afbeelding..
    Ext := UpperCase(ExtractFileExt(FN));
    if Ext = '.JPG' then Result := LoadTextureJPG(FN) else
    if Ext = '.BMP' then Result := LoadTextureBMP(FN) else
    if Ext = '.TGA' then Result := LoadTextureTGA(FN) else
    if Ext = '.RAW' then Result := 0 {LoadTextureRAW(FN)};
    // geladen en aangemaakte textures aan de lijst toevoegen
    GetTextureInfo(FN,Ext,W,H);
    if Result>0 then AddLoadedTexture(FN, Result, HasAlphaData, W,H);
  end;
end;

function TObjTexture.LoadTexture(Filename: string; Gamma: Single): GLuint;
begin
  Set_GammaFactor(Gamma);
  Result := LoadTexture(Filename); //de andere overloaded function aanroepen..
  Set_GammaFactor(1.0); //gamma herstellen op standaard-waarde
end;


procedure TObjTexture.AddLoadedTexture(Filename: string; TextureHandle: GLuint; HasAlpha: boolean; Width,Height:integer);
var L: integer;
begin
  if not (TextureHandle>0) then Exit;
  L := Length(AlreadyLoaded);
  SetLength(AlreadyLoaded, L+1);
  AlreadyLoaded[L].Filename := Filename;
  AlreadyLoaded[L].TextureHandle := TextureHandle;
  AlreadyLoaded[L].AlphaData := HasAlpha;
  AlreadyLoaded[L].Width := Width;
  AlreadyLoaded[L].Height := Height;
end;

function TObjTexture.TextureAlreadyLoaded(Filename: string; var TextureHandle: GLuint): boolean;
var i: integer;
begin
  Result := false;  //ongeldige handle
  for i:=0 to Length(AlreadyLoaded)-1 do
    if Filename = AlreadyLoaded[i].Filename then begin
      TextureHandle := AlreadyLoaded[i].TextureHandle;
      Result := true;
      Break;
    end;
end;


procedure TObjTexture.DeleteTexture(TextureHandle: GLuint);
var L,i,j: integer;
begin
  if TextureHandle > 0 then begin
    // de texture uit de lijst met geladen textures verwijderen..
    L := Length(AlreadyLoaded);
    for i:=0 to L-1 do
      if TextureHandle = AlreadyLoaded[i].TextureHandle then begin
        // wissen die texture..
        if glIsTexture(TextureHandle) then glDeleteTextures(1, @TextureHandle);
        //alle elementen vanaf index [i+1] naar [i] kopiëren..
        for j:=i+1 to L-1 do AlreadyLoaded[j-1] := AlreadyLoaded[j];
        // array 1 korter maken..
        SetLength(AlreadyLoaded, L-1);
      end;
  end;
end;

procedure TObjTexture.DeleteTextures;
var L,i: integer;
begin
  // de texture uit de lijst met geladen textures verwijderen..
  L := Length(AlreadyLoaded);
  for i:=0 to L-1 do
    if AlreadyLoaded[i].TextureHandle <> 0 then
      // wissen die texture..
      if glIsTexture(AlreadyLoaded[i].TextureHandle) then glDeleteTextures(1, @AlreadyLoaded[i].TextureHandle);
  SetLength(AlreadyLoaded, 0);
end;



procedure TObjTexture.SaveToFile(const PixelData: Pointer; Width,Height: Integer; PixelFormatIn: GLuint; Filename: string);
var BMP: TBitmap;
    x,y: integer;
    R,G,B, bpp: Byte;
begin
  if PixelFormatIn = GL_RGB then bpp := 3 else
  if PixelFormatIn = GL_RGBA then bpp := 4 else Exit;
  //
  BMP := TBitmap.Create;
  try
    BMP.HandleType := bmDIB;
    BMP.Width := Width;
    BMP.Height := Height;
    // pixeldata overnemen naar de bitmap
    if bpp=3 then BMP.PixelFormat := pf24bit else
    if bpp=4 then BMP.PixelFormat := pf32bit;
    for y:=0 to Height-1 do
      for x:=0 to Width-1 do begin
        asm
          mov ecx, PixelData
          mov al, [ecx]
          mov R, al
          mov al, [ecx+1]
          mov G, al
          mov al, [ecx+2]
          mov B, al
        end;
        //volgende pixel adresseren
        if bpp=3 then begin
          asm
            add PixelData, 3
          end;
        end else begin
          asm
            add PixelData, 4
          end;
        end;
        // pixel naar canvas overnemen
        BMP.Canvas.Pixels[x,y] := RGB(R,G,B);
      end;
    BMP.SaveToFile(Filename);
  finally
    BMP.Free;
  end;
end;


function TObjTexture.HasAlpha(TextureHandle: GLuint): boolean;
var L,i: integer;
begin
  // de texture uit de lijst met geladen textures verwijderen..
  L := Length(AlreadyLoaded);
  for i:=0 to L-1 do
    if AlreadyLoaded[i].TextureHandle = TextureHandle then begin
      Result := AlreadyLoaded[i].AlphaData;
      Exit;
    end;
end;

function TObjTexture.GetTextureInfo(Filename: string; var Extension: string; var Width,Height: Integer): boolean;
var JPG: TJPEGImage;
    BMP: TBitmap;
    F : File;
    n: integer;
    TGAHeader : TTargaHeader;
begin
  Result := false;
  // bestaat het bestand wel?
  if not FindTexture(Filename) then Exit;

  // de extensie
  Extension := UpperCase(ExtractFileExt(Filename));
  // de breedte en hoogte
  Width := 0;
  Height := 0;
  // JPG
  if Extension = '.JPG' then begin
    JPG := TJPEGImage.Create;
    try
      try
        JPG.LoadFromFile(Filename);
        Width := JPG.Width;
        Height := JPG.Height;
        Result := true;
      finally
        JPG.Free;
      end;
    except
      Exit;
    end;
  end else
  // BMP
    if Extension = '.BMP' then begin
      BMP := TBitmap.Create;
      try
        try
          BMP.LoadFromFile(Filename);
          Width := BMP.Width;
          Height := BMP.Height;
          Result := true;
        finally
          BMP.Free;
        end;
      except
        Exit;
      end;
    end else
  // TGA
      if Extension = '.TGA' then begin
        try
          AssignFile(F, Filename);
          try
            {$I-}
            Reset(F, 1);
            {$I+}
            if (IOResult<>0) then Exit;
            // De TGA file-header inlezen
            {$I-}
            BlockRead(F, TGAHeader, SizeOf(TTargaHeader), n);
            {$I+}
            if (IOResult<>0) or (n<>SizeOf(TTargaHeader)) then Exit;
            Width := TGAHeader.wWidth;
            Height := TGAHeader.wHeight;
            Result := true;
          finally
            CloseFile(F);
          end;
        except
          Exit;
        end;
      end;
end;



(*
initialization
  Textures := TObjTexture.Create;

finalization
  Textures.Free;
*)



end.
