unit uQ3Shaders;
interface


// shader-files ----------------------------------------------------------------
const
  // waar komt de texture uiteindelijk vandaan??
  // bitmasks TextureResource:
  trNone       = $00000000;
  trGame       = $00000001;   // dit is een standaard resource van het spel
  trShader     = $00000002;   // dit is een shader (uit een shader-file)
  trTexture    = $00000004;   // dit is een texture (uit een texture-file)
  trSurface    = $00000008;   // het surface bevat de naam van de shader
  trSkinFile   = $00000010;   // uit een skin-file
  trShaderList = $00000020;   // via een shader de shaderlist
  trPK3        = $00000040;   // via een pk3 (pak0.pk3 of custom map-pk3)

//  trMask       = (trGame+trShader+trTexture+trSkinFile+trShaderList+trPK3);

  // ShaderResource (tbv shaderfiles):
  srShaderList = trShaderList;
  srMap        = trPK3;
  srGame       = (trPK3 + trGame);

type
  TTextureResource = cardinal;

  TLoadedFrom = (lfNone, lfGame, lfPK3, lfFile);

  TCull = (cNone, cDisable, cTwoSided, cFront, cBack);
  TAlphaFunc = (afNone, afGT0, afLT128, afGE128);

  TShaderTexture = record
                     ShaderName: string;
                     Map: string;
                     Cull: TCull;
                     EnvMap: boolean;
                     BlendFuncSrc, BlendFuncDst: cardinal;
                     AlphaFunc: TAlphafunc;
                     clamped: boolean;
                     Sky: boolean;
                     animMap, videoMap, lightMap, whiteImage: boolean;
                     PolygonOffset: boolean;
                     TextureHandle: cardinal;   // OpenGL handle
                     HasAlphaData: boolean;
                     TexturePass: integer;
                     Width, Height: integer;
                     FoundFilename: string;
                     tcModScrollX, tcModScrollY, tcModRotate,
                     CurrentTCMODscrollX, CurrentTCMODscrollY, CurrentTCMODrotate: single;
                     autosprite: boolean;
                   end;
  TShaderObj = record
                 TextureResource: TTextureResource;
                 Textures: array of TShaderTexture;
               end;
  TShaderFileObj = array of TShaderObj;  // elk surface een TShaderObj

type
  TShaders = class(TObject)
             public
               ShaderFile: TShaderFileObj;  //modellen gebruiken hun interne 'ShaderIndex' voor verwijzingen in deze array
               //
               destructor Destroy; override;
               //
               // 2 namen meegeven ivm. inconsistentie naamgeving
               // Filename = shaderfile
               // shadername(2) = naam van shader + alternatieve naam
               // resultaat = de index in de array ShaderFile
               function FetchShader(Filename, ShaderName,ShaderName2:string; const TextureResource:TTextureResource) : cardinal;
               // resultaat = de index in de array ShaderFile
               function FetchTexture(Texturename:string; Filename:string; const TextureResource:TTextureResource) : cardinal;
               // wis een geladen shader + OpenGL texture(s)
               procedure DeleteShader(ShaderIndex:cardinal);
               // wis alle geladen shaders (ook OpenGL textures)
               procedure DeleteAllShaders;
               // zoek een shader/texture voor een opgegeven SurfaceName/ShaderName,
               // en resulteer (evt) in TextureResource waar de shader (of texture) is gevonden
               // Het resultaat van de function zelf geeft aan OF er wel wat is gevonden..
               // De FileName heeft een absoluut pad op een lokale harddisk (evt. na unzippen uit pk3).
               function Locate(const inSurfaceName,inShaderName:string;
                               const LoadedFrom:TLoadedFrom;
                               const TmpDir,GameDir,ModelDir,MapDir,MapFile:string;
                               var Filename:string;
                               var TextureResource:TTextureResource;
                               var ShaderIndex:integer) : boolean;
             end;
var
  Shaders: TShaders;


// tbv. zoeken van shaders in bestanden
type
  TETShader = record
                  inPK3: boolean;     // false=inFile (scripts/*.shader), true=inPK3
                  Filename: string;
                  PAK_Index: integer;
                  Shaders: array of string;
                end;
  TETShaders = array of TETShader;
var
  ShaderListShaders: TETShaders;    // de shader-files in de lijst   Filename=absoluut pad op HD
  MapShaders: TETShaders;           // de shaders in een map-pk3     Filename=relatief pad in PK3
  GameShaders: TETShaders;          // de shaders in de pak0.pk3     Filename=relatief pad in PK3


// skin files ------------------------------------------------------------------
type
  TSkinRec = record
               SurfaceName,
               ShaderName,
               FoundShadername: string;
             end;
  TSkin = array of TSkinRec;
var
  SkinShaders: TSkin;


// pak files -------------------------------------------------------------------
type
  // tbv de PAKs combobox objecten
  TStrObject = class(TObject)
  public
    FullPath,
    ShortName,
    TmpDir: string;
    hasTextures,
    hasShaders,
    hasModels: boolean;
  end;
var
  PAKsList: array of TStrObject;


function SkinShaderForSurface(SurfaceName:string) : string;
procedure SetSkinToModel(SurfaceName, ReplacementShader:string);



implementation
uses classes, SysUtils, StrUtils, OpenGL, uOpenGL, ZipForge;


function SkinShaderForSurface(SurfaceName:string) : string;
var Len, i: integer;
begin
  Result := '';
  Len := Length(SkinShaders);
  if Len=0 then Exit;
  for i:=0 to Len-1 do
    if SkinShaders[i].SurfaceName = SurfaceName then begin
      Result := SkinShaders[i].FoundShadername;
      Exit;
    end;
end;

procedure SetSkinToModel(SurfaceName, ReplacementShader:string);
var Len, i: integer;
begin
  Len := Length(SkinShaders);
  if Len=0 then Exit;
  for i:=0 to Len-1 do
    if SkinShaders[i].SurfaceName = SurfaceName then begin
      SkinShaders[i].FoundShadername := ReplacementShader;
      Exit;
    end;
end;


{--- TShaders -----------------------------------------------------------------}
destructor TShaders.Destroy;
begin
  DeleteAllShaders;
  inherited;
end;

procedure TShaders.DeleteShader(ShaderIndex:cardinal);
var Len,LenT,t: integer;
begin
  Len := Length(ShaderFile);
  if ShaderIndex >= Len then Exit;
  // oude textures wissen
  LenT := Length(ShaderFile[ShaderIndex].Textures);
  if LenT>0 then begin
    for t:=0 to LenT-1 do
      OGL.Textures.DeleteTexture(ShaderFile[ShaderIndex].Textures[t].TextureHandle);
    SetLength(ShaderFile[ShaderIndex].Textures, 0);
  end;
end;

procedure TShaders.DeleteAllShaders;
var Len,LenT,s,t: integer;
begin
  Len := Length(ShaderFile);
  for s:=0 to Len-1 do begin
    // oude textures wissen
    LenT := Length(ShaderFile[s].Textures);
    if LenT>0 then begin
      for t:=0 to LenT-1 do
        OGL.Textures.DeleteTexture(ShaderFile[s].Textures[t].TextureHandle); //!!!!!DEBUG!!!!!
      SetLength(ShaderFile[s].Textures, 0);
    end;
  end;
  SetLength(ShaderFile, 0);
end;

function TShaders.FetchTexture(Texturename:string; Filename:string; const TextureResource:TTextureResource): cardinal;
var Len,LenT: integer;
begin
  // een shader entry toevoegen
  Len := Length(ShaderFile);
  SetLength(ShaderFile, Len+1);
  ShaderFile[Len].TextureResource := TextureResource;
  // texture toevoegen
  LenT := Length(ShaderFile[Len].Textures);
  SetLength(ShaderFile[Len].Textures, LenT+1);
  with ShaderFile[Len].Textures[LenT] do begin
    ShaderName := '';
    Map := Texturename;
    Cull := cBack;
    EnvMap := false;
    BlendFuncSrc := GL_DST_COLOR; // blendfunc filter
    BlendFuncDst := GL_ZERO;      // blendfunc filter
    clamped := false;
    FoundFilename := Filename;
  end;
  Result := Len;  // shaderindex
end;

function TShaders.FetchShader(Filename, ShaderName,ShaderName2:string; const TextureResource:TTextureResource): cardinal;
var List: TStringList;
    tmp: TShaderTexture;
    L,L2,p,p2,Len,LenT: integer;
    s,sl,s2,s3, bfsrc,bfdst: string;
    Found, FoundTexturePass, b: boolean;
begin
  // shader-bestand laden en texture-maps zoeken..
{ // evt. oude textures wissen
  Len := Length(ShaderFile[surface].Textures);
  if Len>0 then begin
    for p:=0 to Len-1 do
      OGL.Textures.DeleteTexture(ShaderFile[surface].Textures[p].TextureHandle);
    SetLength(ShaderFile[surface].Textures, 0);
  end;}

// shader al eerder opgezocht??
Len := Length(ShaderFile);
for p:=0 to Len-1 do
  if Length(ShaderFile[p].Textures)>0 then
    if (ShaderFile[p].Textures[0].ShaderName = ShaderName) or
       (ShaderFile[p].Textures[0].ShaderName = ShaderName2) then begin
      Result := p;
      Exit;
    end;

  // een shader entry toevoegen
  Len := Length(ShaderFile);
  SetLength(ShaderFile, Len+1);
  ShaderFile[Len].TextureResource := TextureResource;
  Result := Len; //ShaderIndex

  // shaderbestand inlezen
  List := TStringList.Create;
  try
    List.LoadFromFile(Filename);

    // alle regels opschonen
    for L:=0 to List.Count-1 do begin
      s := List.Strings[L];
      // wis commentaar
      p := Pos('//',s);
      if p>0 then s := Copy(s,1,p-1);
      // trim
      s := Trim(LowerCase(s));
      //
      List.Strings[L] := s;
    end;

    //
    Found := false;
    for L:=0 to List.Count-1 do begin
      sl := List.Strings[L];

      // shadername gevonden??
      p := Pos(ShaderName, sl);
      b := (p>0) and (Length(ShaderName)=Length(sl));
      if not b then begin
        p := Pos(ShaderName2, sl);
        b := (p>0) and (Length(ShaderName2)=Length(sl));
if b then ShaderName := ShaderName2;
      end;
      if not b then begin
        s3 := AnsiReplaceStr(ShaderName2, '\','/');
        p := Pos(s3, sl);
        b := (p>0) and (Length(s3)=Length(sl));
if b then ShaderName := ShaderName2;
      end;
      //
      if b then begin
        // shader gevonden..
        Found := true;

        // lees de openings {
        L2 := L;
        repeat
          Inc(L2);
          if L2<=List.Count-1 then begin
            sl := List.Strings[L2];
            p := Pos('{', sl);
          end;
        until (p>0) or (L2>List.Count-1);
        if p>0 then begin
          // { gevonden..

          // lees de shader-params -----------------------------------------
          tmp.ShaderName := ShaderName;
          tmp.Map := '';
          tmp.clamped := false;
          tmp.animMap := false;
          tmp.videoMap := false;
          tmp.lightMap := false;
          tmp.whiteImage := false;
          tmp.PolygonOffset := false;
          tmp.Cull := cBack;
          tmp.EnvMap := false;
          tmp.Sky := false;
          tmp.AlphaFunc := afNone;
          tmp.BlendFuncSrc := GL_DST_COLOR;
          tmp.BlendFuncDst := GL_ZERO;
          tmp.FoundFilename := '';
          tmp.tcModScrollX := 0.0;
          tmp.tcModScrollY := 0.0;
          tmp.tcModRotate := 0.0;
          tmp.CurrentTCMODscrollX := 0.0;
          tmp.CurrentTCMODscrollY := 0.0;
          tmp.CurrentTCMODrotate := 0.0;
          tmp.autosprite := false;

          sl := '';
          while not ((Pos('{',sl)>0) or (Pos('}',sl)>0)) do begin
            Inc(L2);
            sl := List.Strings[L2];

            // lees "cull"..
            p := Pos('cull', sl);
            if p>0 then begin
              p := Pos('disable', sl);
              if p>0 then begin
                tmp.Cull := cNone;
              end else begin
                p := Pos('none', sl);
                if p>0 then begin
                  tmp.Cull := cNone;
                end else begin
                  p := Pos('twosided', sl);
                  if p>0 then begin
                    tmp.Cull := cNone;
                  end else begin
                    p := Pos('front', sl);
                    if p>0 then begin
                      tmp.Cull := cFront;
                    end else begin
                      p := Pos('back', sl);
                      if p>0 then begin
                        tmp.Cull := cBack;
                      end else begin
                      end;
                    end;
                  end;
                end;
              end;
            end;

            // polygonOffset
            p := Pos('polygonoffset', sl);
            if p>0 then begin
              tmp.PolygonOffset := true;
            end;

            // qer_alphafunc
            p := Pos('qer_alphafunc', sl);
            if p>0 then begin
              s2 := Trim(Copy(sl,p+13,Length(sl)));
              if Pos('less',s2)>0 then tmp.AlphaFunc := afLT128;
              if Pos('gequal',s2)>0 then tmp.AlphaFunc := afGE128;
              if Pos('greater',s2)>0 then tmp.AlphaFunc := afGT0;
            end;

            // lees "implicitMap"..
            p := Pos('implicitmap', sl);
            if p>0 then begin
              // lees de (enige) texture
              sl := Trim(Copy(sl,p+11,Length(sl)));
              if sl='-' then sl := ShaderName;
              tmp.Map := sl;
              tmp.BlendFuncSrc := GL_DST_COLOR;
              tmp.BlendFuncDst := GL_ZERO;
            end;

            // lees "implicitMask"..
            p := Pos('implicitmask', sl);
            if p>0 then begin
              // lees de (enige) texture
              sl := Trim(Copy(sl,p+12,Length(sl)));
              if sl='-' then sl := ShaderName;
              tmp.Map := sl;
              tmp.BlendFuncSrc := GL_SRC_ALPHA;
              tmp.BlendFuncDst := GL_ONE_MINUS_SRC_ALPHA;
              tmp.AlphaFunc := afGT0; //afGE128
            end;

            // surfaceparm sky
            // skyparms "textures/UJE_01/sky/uje_lake2" 512 -
            // if sl='-' then sl := ShaderName;
            p := Pos('surfaceparm', sl);
            if p>0 then begin
              p := Pos('sky', sl);
              if p>0 then begin
                tmp.Sky := true;
              end;
            end;

            // deformVertexes autosprite(2)
            p := Pos('deformvertexes', sl);
            if p>0 then begin
              p := Pos('autosprite', sl); //autosprite2 ook meenemen..
              if p>0 then begin
                tmp.autosprite := true;
              end;
            end;

          end;
          // een (implicit) mapping gevonden??
          if tmp.Map<>'' then begin
            // texture toevoegen aan de array
            LenT := Length(ShaderFile[Len].Textures);
            SetLength(ShaderFile[Len].Textures, LenT+1);
            ShaderFile[Len].Textures[LenT] := tmp;
            {ShaderFile[Len].TextureResource := TextureResource;}
          end;


          FoundTexturePass := true; //ga ervan uit dat er een texture-stage volgt
          while FoundTexturePass do begin

            // alle gegevens verzamelen in een tijdelijk object
            tmp.Map := '';
            //tmp.Cull := cBack;
            tmp.EnvMap := false;
            {tmp.BlendFuncSrc := GL_DST_COLOR; //filter
            tmp.BlendFuncDst := GL_ZERO;      //filter}
            tmp.BlendFuncSrc := GL_ZERO;      //none
            tmp.BlendFuncDst := GL_ZERO;      //none
            {tmp.AlphaFunc := afNone;}
            tmp.clamped := false;
            tmp.animMap := false;
            tmp.videoMap := false;
            tmp.lightMap := false;
            tmp.whiteImage := false;
            tmp.TextureHandle := 0;
            tmp.HasAlphaData := false;
            tmp.FoundFilename := '';
            tmp.tcModScrollX := 0.0;
            tmp.tcModScrollY := 0.0;
            tmp.tcModRotate := 0.0;
            tmp.CurrentTCMODscrollX := 0.0;
            tmp.CurrentTCMODscrollY := 0.0;
            tmp.CurrentTCMODrotate := 0.0;
            //tmp.autosprite := false;

            if Pos('{',sl) > 0 then begin
              // texture-stage gevonden.. ----------------------------------
              sl := '';
              while not (Pos('}',sl)>0) do begin
                Inc(L2);
                sl := List.Strings[L2];

                // lees "Map"..
                p := Pos('map', sl);
                if p>0 then begin
                  // test op "clampMap"
                  tmp.clamped := (Pos('clampmap', sl)>0);
                  // test op "videoMap"
                  tmp.videoMap := (Pos('videomap', sl)>0);
                  // test op "animMap"
                  tmp.animMap := (Pos('animmap', sl)>0);
                  // lightmap & whiteimage
                  tmp.lightMap := (Pos('$lightmap', sl)>0);
                  tmp.whiteImage := (Pos('$whiteimage', sl)>0);
                  // lees de texture voor deze draw-stage
                  if tmp.animMap then begin
                    // pak de eerste texture:
                    // skip de frequency
                    p := p+4;
                    repeat Inc(p) until ((sl[p]<>'') and (sl[p]<>#9));
                    p2 := PosEx(' ', sl,p);
                    if p2=0 then p2 := PosEx(#9, sl,p);
                    // lees de texture
                    if p2>0 then begin
                      repeat Inc(p2) until ((sl[p2]<>'') and (sl[p2]<>#9));
                      p := PosEx(' ', sl,p2);
                      if p=0 then p := PosEx(#9, sl,p2);
                      tmp.Map := Trim(Copy(sl,p2,p-p2));
                    end;
                  end else begin
                    if tmp.lightMap then tmp.Map := '$lightmap';
                    if tmp.whiteImage then tmp.Map := '$whiteimage';
                    if (tmp.videoMap or tmp.lightMap or tmp.whiteImage) then
                      Continue
                    else
                      tmp.Map := Trim(Copy(sl,p+3,Length(sl)));
                  end;
                end;

                // lees environment map
                p := Pos('tcgen', sl);
                p2 := Pos('environment', sl);
                if ((p>0) and (p2>0)) then tmp.EnvMap := true;

                // lees tcMod scroll
                p := Pos('tcmod', sl);
                p2 := Pos('scroll', sl);
                if ((p>0) and (p2>0)) then begin
                  s2 := Trim(Copy(sl,p2+6,Length(sl)));
                  p := Pos(' ', s2);
                  if p=0 then p := Pos(#9, s2);
                  if not TryStrToFloat(Copy(s2,1,p-1), tmp.tcModScrollX) then begin
                    tmp.tcModScrollX := 0.0;
                    tmp.tcModScrollY := 0.0;
                  end else begin
                    s2 := Trim(Copy(s2,p,Length(s2)));
                    if not TryStrToFloat(s2, tmp.tcModScrollY) then begin
                      tmp.tcModScrollX := 0.0;
                      tmp.tcModScrollY := 0.0;
                    end;
                  end;
                end;

                // lees tcMod rotate
                p := Pos('tcmod', sl);
                p2 := Pos('rotate', sl);
                if ((p>0) and (p2>0)) then begin
                  s2 := Trim(Copy(sl,p2+6,Length(sl)));
                  if not TryStrToFloat(Copy(s2,1,Length(s2)), tmp.tcModRotate) then
                    tmp.tcModRotate := 0.0;
                end;

                // lees alphafunc
                p := Pos('alphafunc', sl);
                if p>0 then begin
                  s2 := Trim(Copy(sl,p+9,Length(sl)));
                  if s2='gt0' then tmp.AlphaFunc := afGT0;
                  if s2='lt128' then tmp.AlphaFunc := afLT128;
                  if s2='ge128' then tmp.AlphaFunc := afGE128;
                end;

                // lees BlendFunc
                p := Pos('blendfunc', sl);
                if p>0 then begin
                 sl := Trim(Copy(sl,p+9,Length(sl)));
                 if Pos('add', sl)>0 then begin
                    tmp.BlendFuncSrc := GL_ONE;
                    tmp.BlendFuncDst := GL_ONE;
                  end else
                  if Pos('filter', sl)>0 then begin
                    tmp.BlendFuncSrc := GL_DST_COLOR;
                    tmp.BlendFuncDst := GL_ZERO;
                  end else
                  if Pos('blend', sl)>0 then begin
                    tmp.BlendFuncSrc := GL_SRC_ALPHA;
                    tmp.BlendFuncDst := GL_ONE_MINUS_SRC_ALPHA;
                  end else begin
                    // regel lezen om custom blendfunc te achterhalen
                    bfsrc := 'gl_dst_color'; //filter
                    bfdst := 'gl_zero';      //filter
                    p := Pos(' ',sl);
                    if p=0 then p := Pos(#9,sl);
                    if p>0 then begin
                      bfsrc := Trim(Copy(sl,1,p));
                      bfdst := Trim(Copy(sl,p,Length(sl)));
                    end;

                    if bfsrc='gl_one' then tmp.BlendFuncSrc := GL_ONE;
                    if bfsrc='gl_zero' then tmp.BlendFuncSrc := GL_ZERO;
                    if bfsrc='gl_dst_color' then tmp.BlendFuncSrc := GL_DST_COLOR;
                    if bfsrc='gl_one_minus_dst_color' then tmp.BlendFuncSrc := GL_ONE_MINUS_DST_COLOR;
                    if bfsrc='gl_src_alpha' then tmp.BlendFuncSrc := GL_SRC_ALPHA;
                    if bfsrc='gl_one_minus_src_alpha' then tmp.BlendFuncSrc := GL_ONE_MINUS_SRC_ALPHA;

                    if bfdst='gl_one' then tmp.BlendFuncDst := GL_ONE;
                    if bfdst='gl_zero' then tmp.BlendFuncDst := GL_ZERO;
                    if bfdst='gl_src_color' then tmp.BlendFuncDst := GL_SRC_COLOR;
                    if bfdst='gl_one_minus_src_color' then tmp.BlendFuncDst := GL_ONE_MINUS_SRC_COLOR;
                    if bfdst='gl_src_alpha' then tmp.BlendFuncDst := GL_SRC_ALPHA;
                    if bfdst='gl_one_minus_src_alpha' then tmp.BlendFuncDst := GL_ONE_MINUS_SRC_ALPHA;
                  end;
                end;
              end;


              // fixes..
(*
              if tmp.EnvMap then
                if tmp.HasAlphaData then begin
                  tmp.BlendFuncSrc := GL_ONE;
                  tmp.BlendFuncDst := GL_ONE;
                end;
              if (tmp.BlendFuncSrc=GL_SRC_ALPHA) and (tmp.BlendFuncDst=GL_ONE_MINUS_SRC_ALPHA) and
                  tmp.HasAlphaData and (not tmp.EnvMap) then
                tmp.AlphaFunc := afGT0;
*)
              // tijdelijke gegevens overnemen naar ShaderFile:
              // texture toevoegen aan de array
              LenT := Length(ShaderFile[Len].Textures);
              SetLength(ShaderFile[Len].Textures, LenT+1);
              ShaderFile[Len].Textures[LenT] := tmp;
              {ShaderFile[Len].TextureResource := TextureResource;}

              // controleer op een eventuele volgende draw-stage
              sl := '';
              while not ((Pos('{',sl)>0) or (Pos('}',sl)>0)) do begin
                Inc(L2);
                sl := List.Strings[L2];
              end;
              if Pos('{',sl) > 0 then begin
                // nog een draw-stage gevonden..
                Continue; //while FoundTexturePass
              end else begin
                // einde shader gevonden..
                Break; //while FoundTexturePass
              end;

            end else
              if Pos('}',sl) > 0 then begin
                // einde shader gevonden..
                Break; //while FoundTexturePass
              end;
          end; // while FoundTexturePass
        end;
        //
        Break; //for L
      end; //p>0
    end; //for L
{          if not Found then begin
      StatusBar.SimpleText := 'Shader not found: '+ ShaderName;
    end;}

  finally
    List.Free;
  end;
end;




function TShaders.Locate(const inSurfaceName,inShaderName:string;
                         const LoadedFrom:TLoadedFrom;
                         const TmpDir,GameDir,ModelDir,MapDir,MapFile:string;   //mapdir = dlgPK3.MapPK3
                         var Filename:string;                                   //mapfile = dlgPK3.PathDir
                         var TextureResource:TTextureResource;
                         var ShaderIndex:integer): boolean;
var SurfaceName,ShaderName,ShaderName2, s,s2,s3,path, FoundTexturename,FoundFilename: string;
    ShaderExists, NeedsSkin, isTextureName, TextureExists, Found: boolean;
    sIndex,ssIndex, Len,L: integer;
//------------------------------------------------------------------------------
// zoek een shader in de ShaderList,Mapshaders en/of de GameShaders
function ShaderNameFound(const Name:string; var TextureResource:TTextureResource; var sIndex,ssIndex:integer) : boolean;
var gs,gss, Len,LenS: integer;
    Name2,Name3,s: string;
    Found: boolean;
begin
  // zoek de shaders erbij, voor de bestandsnaam.
  // Als er een shader bestaat met de naam van de Surface,..
  // ..krijgt die shader voorrang op een evt. aanwezige texture.
  Found := false;
  sIndex := -1;
  ssIndex := -1;
  Name2 := AnsiReplaceStr(Name, '\','/');   //tjonge jonge zeg.. consistent zijn ze niet..
  Name3 := AnsiReplaceStr(Name, '/','\');   //tjonge jonge zeg.. consistent zijn ze niet..
(*
  // zoek eerst lokaal in de ModelDir
  if ModelDir<>'' then begin
    //todo??
  end;
*)
  // Zoek vervolgens in de ShaderList shaders
  Len := Length(ShaderListShaders);
  for gs:=0 to Len-1 do begin
    LenS := Length(ShaderListShaders[gs].Shaders);
    for gss:=0 to LenS-1 do begin
      if (ShaderListShaders[gs].Shaders[gss] = Name) or
         (ShaderListShaders[gs].Shaders[gss] = Name2) then begin
        Found := true;
        TextureResource := (TextureResource or trShader);
        TextureResource := (TextureResource or trShaderList);
        sIndex := gs;
        ssIndex := gss;
        Break;
      end;
    end;
    if Found then Break;
  end;
  // Zoek vervolgens in de MapShaders (custom.pk3)
  if not Found then begin
    Len := Length(MapShaders);
    for gs:=0 to Len-1 do begin
      LenS := Length(MapShaders[gs].Shaders);
      for gss:=0 to LenS-1 do begin
        if (MapShaders[gs].Shaders[gss] = Name) or
           (MapShaders[gs].Shaders[gss] = Name2) then begin
          Found := true;
          TextureResource := (TextureResource or trShader);
          TextureResource := (TextureResource or trPK3);
          sIndex := gs;
          ssIndex := gss;
          Break;
        end;
      end;
      if Found then Break;
    end;
  end;
  // Zoek als laatst in de GameShaders (pak0.pk3)
  if not Found then begin
    Len := Length(GameShaders);
    for gs:=0 to Len-1 do begin
      LenS := Length(GameShaders[gs].Shaders);
      for gss:=0 to LenS-1 do begin
        if (GameShaders[gs].Shaders[gss] = Name) or
           (GameShaders[gs].Shaders[gss] = Name2) then begin
          Found := true;
          TextureResource := (TextureResource or trShader);
          TextureResource := (TextureResource or trGame);
          TextureResource := (TextureResource or trPK3);
          sIndex := gs;
          ssIndex := gss;
          Break;
        end;
      end;
      if Found then Break;
    end;
  end;
  //
  Result := Found;
end;
//------------------------------------------------------------------------------
function GetShaderFilename(const TextureResource:TTextureResource; const sIndex:integer) : string;
var s,s2: string;
    fromShaderList,fromMap,fromGame: boolean;
begin
  s := '';
  fromShaderList := ((TextureResource and trShaderList)>0);
  fromMap := (((TextureResource and trPK3)>0) and ((TextureResource and trGame)=0));
  fromGame := (((TextureResource and trPK3)>0) and ((TextureResource and trGame)>0));
  if fromShaderList then begin
    {//s := 'SHADERLIST:\\'+ ExtractFilename(ShaderListShaders[sIndex].Filename);}
    s := ShaderListShaders[sIndex].Filename;
  end else
    if fromMap then begin
      s2 := AnsiReplaceStr(MapShaders[sIndex].Filename, '\','/');   //tjonge jonge zeg.. consistent zijn ze niet..
      s2 := ExtractFilename(s2);
      {//s := 'MAP:\\scripts\'+ s2;}
      s := TmpDir +'tmpmap\scripts\'+ MapShaders[sIndex].Filename;
    end else
      if fromGame then begin
        if not GameShaders[sIndex].inPK3 then begin // lokaal op HD aanwezig
          s := GameDir +'etmain\scripts\'+ GameShaders[sIndex].Filename;
        end else begin
          {//s := 'GAME:\\scripts\'+ GameShaders[sIndex].Filename;}
          {s := TmpDir +'scripts\'+ GameShaders[sIndex].Filename;}
          s := PAKsList[GameShaders[sIndex].PAK_Index].TmpDir +'scripts\'+ GameShaders[sIndex].Filename;
        end;
      end;
  Result := s;
end;
//------------------------------------------------------------------------------
function TextureNameFound(const Name:string; var TextureResource:TTextureResource; var FoundTexturename:string; var FoundFilename:string) : boolean;
var s,s2,s3,path: string;
    Zip: TZipForge;
    ai: TZFArchiveItem;
    gp: integer;
begin
  Zip := TZipForge.Create(nil);
  try
    Result := false;
    FoundTexturename := '';
    FoundFilename := '';
    if Name='' then Exit;
    // zoek texture
    s := AnsiReplaceStr(Name, '/','\');
    path := ExtractFilePath(s);
    s := ExtractFilename(s);

    if LoadedFrom = lfFile then begin
      // zoek texture in ModelDir
      if ModelDir<>'' then begin
        if FileExists(ModelDir+s) then s2 := s else begin
          s3 := ExtractFileExt(s);
          if s3<>'' then s := Copy(s,1,Length(s)-Length(s3));
          if FileExists(ModelDir+s+'.tga') then s2 := s+'.tga' else
            if FileExists(ModelDir+s+'.jpg') then s2 := s+'.jpg' else
              if FileExists(ModelDir+s+'.bmp') then s2 := s+'.bmp';
        end;
      end;
      if s2<>'' then begin
        // texture gevonden in ModelDir
        Result := true;
        FoundTexturename := s2;
        FoundFilename := ModelDir+s2;
        TextureResource := (TextureResource or trTexture);
      end;
      if Result then Exit;
      // zoek evt. met relatief pad-info
      s2 := '';
      if path = ModelDir then
        if FileExists(ModelDir+s) then s2 := s else
          if FileExists(ModelDir+s+'.tga') then s2 := s+'.tga' else
            if FileExists(ModelDir+s+'.jpg') then s2 := s+'.jpg' else
              if FileExists(ModelDir+s+'.bmp') then s2 := s+'.bmp';
      if s2<>'' then begin
        // texture gevonden in ModelDir
        Result := true;
        FoundTexturename := s2;
        FoundFilename := ModelDir+s2;
        TextureResource := (TextureResource or trTexture);
      end;
    end;
    if Result then Exit;

    // Zoek in map.pk3
    if MapFile{dlgPK3.MapPK3}<>'' then begin
      Zip.FileName := MapFile{dlgPK3.MapPK3};
      Zip.OpenArchive(fmOpenRead);
      Zip.BaseDir := TmpDir+'tmpmap\';
      try
        s2 := path + s;
        s3 := ExtractFileExt(s);
        Result := Zip.FindFirst(s2,ai,faAnyFile);
        if Result then
          FoundFilename := TmpDir+'tmpmap\' + s2 //ai.StoredPath + ai.FileName;
        else begin
          if s3<>'' then s := Copy(s,1,Length(s)-Length(s3));
          s2 := path + s +'.tga';
          Result := Zip.FindFirst(s2,ai,faAnyFile);
          if Result then
            FoundFilename := TmpDir+'tmpmap\' + s2
          else begin
            s2 := path + s +'.jpg';
            Result := Zip.FindFirst(s2,ai,faAnyFile);
            if Result then
              FoundFilename := TmpDir+'tmpmap\' + s2
            else begin
              s2 := path + s +'.bmp';
              Result := Zip.FindFirst(s2,ai,faAnyFile);
              if Result then
                FoundFilename := TmpDir+'tmpmap\' + s2
            end;
          end;
        end;
        // bestand uitpakken
        if Result then begin
          FoundTexturename := s2;
          FoundFilename := TmpDir+'tmpmap\'+s2;
          TextureResource := (TextureResource or trTexture);
          TextureResource := (TextureResource or trPK3);
          Zip.ExtractFiles(FoundFilename);
        end;
      finally
        Zip.CloseArchive;
      end;
    end;
    if Result then Exit;

    // zoek eventueel texture in GAME-PAK files (pak0.pk3)
    for gp:=0 to Length(PAKsList)-1 do begin
      Zip.FileName := PAKsList[gp].FullPath; // GameDir +'etmain\pak0.pk3';
      Zip.OpenArchive(fmOpenRead);
      Zip.BaseDir := PAKsList[gp].TmpDir; // TmpDir;
      try
        s2 := path + s;
        Result := Zip.FindFirst(s2,ai,faAnyFile);
        if Result then
          {FoundFilename := TmpDir + s2 //ai.StoredPath + ai.FileName;}
          FoundFilename := PAKsList[gp].TmpDir + s2 //ai.StoredPath + ai.FileName;
        else begin
          s2 := ChangeFileExt(path+s, '.tga'); //path + s +'.tga';
          Result := Zip.FindFirst(s2,ai,faAnyFile);
          if Result then
            {FoundFilename := TmpDir + s2 //ai.StoredPath + ai.FileName;}
            FoundFilename := PAKsList[gp].TmpDir + s2 //ai.StoredPath + ai.FileName;
          else begin
            s2 := ChangeFileExt(path+s, '.jpg'); //path + s +'.jpg';
            Result := Zip.FindFirst(s2,ai,faAnyFile);
            if Result then
              {FoundFilename := TmpDir + s2 //ai.StoredPath + ai.FileName;}
              FoundFilename := PAKsList[gp].TmpDir + s2 //ai.StoredPath + ai.FileName;
            else begin
              s2 := ChangeFileExt(path+s, '.bmp'); //path + s +'.bmp';
              Result := Zip.FindFirst(s2,ai,faAnyFile);
              if Result then
                {FoundFilename := TmpDir + s2 //ai.StoredPath + ai.FileName;}
                FoundFilename := PAKsList[gp].TmpDir + s2; //ai.StoredPath + ai.FileName;
            end;
          end;
        end;
        // bestand uitpakken
        if Result then begin
          FoundTexturename := s2;
          FoundFilename := PAKsList[gp].TmpDir+s2;
          TextureResource := (TextureResource or trTexture);
          TextureResource := (TextureResource or trGame);
          TextureResource := (TextureResource or trPK3);
          Zip.ExtractFiles(s2{FoundFilename});
          Break;
        end;
      finally
        Zip.CloseArchive;
      end;
    end;
  finally
    Zip.CloseArchive;
    Zip.Free;
  end;
end;
//------------------------------------------------------------------------------
begin
  ShaderIndex := -1;
  SurfaceName := AnsiReplaceStr(SurfaceName, '"','');
  ShaderName := '';
  TextureResource := trNone;

  // Test of er een shader bestaat met de naam van het SURFACE:
  // ..dan ModelPath als prefix gebruiken als relatieve pad voor SurfaceName
  if SurfaceName<>'' then begin
    s := ModelDir + SurfaceName;
    s := AnsiReplaceStr(s, '/','\');
    s2 := ExtractFileExt(s);
    if s2='' then begin
      // shadernaam opgegeven. Bestaat de shader??
      ShaderExists := ShaderNameFound(s, TextureResource, sIndex,ssIndex);
      if ShaderExists then begin
        // shader opgegeven, en shader gevonden..
        TextureResource := (TextureResource or trSurface);
        ShaderName := SurfaceName;
      end;
    end;
  end;

  //
  if TextureResource = trNone then ShaderName := inShaderName;
  ShaderName := LowerCase(inShaderName);
  ShaderName := AnsiReplaceStr(ShaderName, '"','');
  NeedsSkin := (ShaderName='');
  s := ShaderName;
  s := AnsiReplaceStr(s, '/','\');
  s := ExtractFilename(s);
  s2 := ExtractFileExt(s);
  isTextureName := (s2<>'');
  TextureExists := false;
  ShaderExists := false;
  // Bepaal het te laden bestand voor een shader:
  Filename := '';

  // is er een skin-shader voor dit surface??
  Len := Length(SkinShaders);
  for L:=0 to Len-1 do
    if SkinShaders[L].SurfaceName = SurfaceName then begin
      // skin gevonden
      TextureResource := (TextureResource or trSkinFile);
      s := SkinShaders[L].ShaderName;// SkinShaders[L].SurfaceName;
      s := AnsiReplaceStr(s, '/','\');
      path := ExtractFilePath(s);
      s2 := ExtractFileExt(s);
      s := ExtractFilename(s);
      // De skin kan een shader of texture bevatten
      ShaderName := SkinShaders[L].ShaderName;
      isTextureName := (s2<>'');
      Break;
    end;

  // shadernaam of texturenaam opgegeven??
  if not isTextureName then begin
    // shadernaam opgegeven. Bestaat de shader??
    ShaderExists := ShaderNameFound(ShaderName, TextureResource, sIndex,ssIndex);
    if ShaderExists then begin
      // shader opgegeven, en shader gevonden..
      ShaderName2 := ShaderName;
      Filename := GetShaderFilename(TextureResource, sIndex);
      if (TextureResource and trSkinFile)>0 then SetSkinToModel(SurfaceName, ShaderName);
    end else begin
      // shader bestaat niet, zoek naar een gelijknamige texture
      TextureExists := TextureNameFound(ShaderName, TextureResource, FoundTexturename, s3);
      if TextureExists then begin
        // shader opgegeven, en texture gevonden.. s3 is ingevuld.
        ShaderIndex := Shaders.FetchTexture(FoundTexturename,s3, TextureResource);
        if (TextureResource and trSkinFile)>0 then SetSkinToModel(SurfaceName, ShaderName);
      end;
    end;
  end else begin
    // texturenaam opgegeven. Bestaat er een shader voor de texture??
    // strip extensie om te zoeken naar een shader
    Len := Length(s2);
    ShaderName2 := Copy(ShaderName, 1, Length(ShaderName)-Len);
    //
    ShaderExists := ShaderNameFound(Shadername2, TextureResource, sIndex,ssIndex);
    if ShaderExists then begin
      // texturenaam opgegeven, en shader gevonden..
      Filename := GetShaderFilename(TextureResource, sIndex);
      if (TextureResource and trSkinFile)>0 then SetSkinToModel(SurfaceName, ShaderName2);
    end else begin
      // texturenaam opgegeven, maar geen shader gevonden..
      TextureExists := TextureNameFound(ShaderName, TextureResource, FoundTexturename, s3);
      if TextureExists then begin
        // texture opgegeven, en texture gevonden.. Filename is ingevuld.
        ShaderIndex := Shaders.FetchTexture(FoundTexturename,s3, TextureResource);
        if (TextureResource and trSkinFile)>0 then SetSkinToModel(SurfaceName, ShaderName);
      end;
    end;
  end;
  // is er een shader gevonden??
  Found := ({(ShaderIndex>-1) or} ((Filename<>'') and FileExists(Filename)));

  // shader-bestand laden en texture-maps zoeken..
  if Found then begin
(*
        // evt. oude textures wissen
        Len := Length(ShaderFile[surface].Textures);
        if Len>0 then begin
          for p:=0 to Len-1 do
            OGL.Textures.DeleteTexture(ShaderFile[surface].Textures[p].TextureHandle);
          SetLength(ShaderFile[surface].Textures, 0);
        end;
*)
    ShaderIndex := Shaders.FetchShader(Filename, Shadername,Shadername2, TextureResource);
  end;

  Filename := '';
  if ShaderIndex>-1 then begin
    if Length(ShaderFile)>0 then
      if Length(ShaderFile[ShaderIndex].Textures)>0 then begin
        if TextureNameFound(ShaderFile[ShaderIndex].Textures[0].Map, TextureResource, FoundTexturename, FoundFilename) then
{          if (TextureResource and trPK3)>0 then
            Filename := TmpDir + FoundFilename
          else
            Filename := ModelDir + FoundFilename;}
          Filename := FoundFilename;
    end;
  end;
  Result := (Filename<>'');
end;



initialization
  Shaders := TShaders.Create;
finalization
  Shaders.Free;

end.
