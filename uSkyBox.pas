unit uSkyBox;
interface
uses OpenGL, uConst, uCamera, u3DTypes;

const
  // de skybox
  texLeft   = 0;
  texRight  = 1;
  texBottom = 2;
  texTop    = 3;
  texNear   = 4;
  texFar    = 5;

  planeLeftT   = 0;
  planeLeftB   = 1;
  planeRightT  = 2;
  planeRightB  = 3;
  planeBottom  = 4;
  planeTop     = 5;
  planeNearT   = 6;
  planeNearB   = 7;
  planeFarT    = 8;
  planeFarB    = 9;

  
type
(*
  TTexture = record
               Name: string;                    // bestandsnaam van de texture
               Handle: word;                    // OpenGL texture handle (GLuint)
               Blend: Single;                   // De dekking van de texture op het object
             end;
*)
  PSkyBox = ^TSkyBox;
  TSkyBox = class(TObject)
            private
              OGL: TObject;                                // OGL parent object
              // tbv. de properties
              local_Active,                                // actief
              local_Paused: boolean;                       // gepauzeerd
              //-- /properties
              Texture: array[texLeft..texFar] of TTexture; // Left,Right,Bottom,Top,Near,Far, clouds
              DisplayList: GLuint;
              // tbv. de properties
              procedure SetActive(const Value: boolean);
              procedure SetPaused(const Value: boolean);
              function TextureHandleForPlane(PlaneNr: integer): GLuint;
              //
              procedure CreateDisplayList;
              procedure DeleteDisplayList;
            published
              property Active: boolean read local_Active write SetActive;
              property Paused: boolean read local_Paused write SetPaused;
            public
              WireFrame: boolean;
              // object
              constructor Create(const Parent: TObject);
              destructor Destroy; override;
              //
              procedure ToggleActive;
              procedure TogglePaused;
              // kan alleen als OpenGL actief is (geldige RC nodig)
              function InitTextures(FilenameLeft, FilenameRight, FilenameBottom, FilenameTop, FilenameNear, FilenameFar: string) : boolean; overload;
              function InitTextures(FilenamePrefix: string) : boolean; overload;
              procedure FreeTextures; //kan alleen als OpenGL actief is (geldige RC nodig)
              //
              procedure Render(const Camera: TCamera);
            end;



(*
var SkyBox: TSkyBox;
*)

implementation
uses uCalc, uOpenGL, uTexture;

{ TSkyBox }
//-- properties lezen en aanpassen/schijven
procedure TSkyBox.SetActive(const Value: boolean);
begin
  if Value <> local_Active then
    local_Active := Value;
end;
procedure TSkyBox.SetPaused(const Value: boolean);
begin
  if Value <> local_Paused then
    local_Paused := Value;
end;
//--
procedure TSkyBox.ToggleActive;
begin
  local_Active := not local_Active;
end;
procedure TSkyBox.TogglePaused;
begin
  local_Paused := not local_Paused;
end;
//-- /properties



constructor TSkyBox.Create(const Parent: TObject);
var i: integer;
begin
  // Object initiëren
  inherited Create;
  OGL := Parent;
  local_Active := false;
  local_Paused := false;
  // Data initialiseren
  for i:=texLeft to texFar do Texture[i].Handle := 0;
  DisplayList := 0;
end;

destructor TSkyBox.Destroy;
begin
  // Data finaliseren
  FreeTextures;
  // Object finaliseren
  inherited;
end;




function TSkyBox.InitTextures(FilenameLeft, FilenameRight, FilenameBottom, FilenameTop, FilenameNear, FilenameFar: string) : boolean;
var i: integer;
begin
  if not (OGL as TOGL).Active then begin
    Result := false;
    Exit;
  end;
  // de huidige displaylist verwijderen
  DeleteDisplayList;
  // de textures van de skybox
  Texture[texLeft].Name := FilenameLeft;
  Texture[texRight].Name := FilenameRight;
  Texture[texBottom].Name := FilenameBottom;
  Texture[texTop].Name := FilenameTop;
  Texture[texNear].Name := FilenameNear;
  Texture[texFar].Name := FilenameFar;
  // textures laden en aanmaken
  for i:=texLeft to texFar do
    if Texture[i].Name <> '' then begin
      Texture[i].Handle :=  (OGL as TOGL).Textures.LoadTexture(Texture[i].Name, 1.0);
      if Texture[i].Handle = 0 then begin
        Texture[i].Name := '';
        Result := false;
        Active := false;
        FreeTextures;
        Exit;
      end;
    end;
  // Een nieuwe displaylist comipleren
  CreateDisplayList;
  //
  Result := true;
end;

function TSkyBox.InitTextures(FilenamePrefix: string): boolean;
var i: integer;
begin

  // ajjj
  if not (OGL as TOGL).Active then begin
    Result := false;
    Exit;
  end;

  // de huidige displaylist verwijderen
  DeleteDisplayList;
  // de textures van de skybox
  Texture[texLeft].Name := FilenamePrefix +'Left'; {.bmp}
  Texture[texRight].Name := FilenamePrefix +'Right';
  Texture[texBottom].Name := FilenamePrefix +'Bottom';
  Texture[texTop].Name := FilenamePrefix +'Top';
  Texture[texNear].Name := FilenamePrefix +'Front';
  Texture[texFar].Name := FilenamePrefix +'Back';
  // textures laden en aanmaken
  for i:=texLeft to texFar do
    if Texture[i].Name <> '' then begin
      Texture[i].Handle :=  (OGL as TOGL).Textures.LoadTexture(Texture[i].Name, 1.0);
      if Texture[i].Handle = 0 then begin
        Texture[i].Name := '';
        FreeTextures;
        Result := false;
        Active := false;
        Exit;
      end;
    end;
  // Een nieuwe displaylist comipleren
  CreateDisplayList;
  //
  Result := true;
end;


procedure TSkyBox.FreeTextures;
var i: integer;
begin
  // de OpenGL-displaylist verwijderen
  DeleteDisplayList;
  // de textures wissen
  for i:=texLeft to texFar do begin
    (OGL as TOGL).Textures.DeleteTexture(Texture[i].Handle);
    Texture[i].Name := '';
  end;
end;



procedure TSkyBox.Render(const Camera: TCamera);
begin
  if (not Active) or Paused then Exit;

  glPushMatrix;
    // Alleen op de positie van de camera.Eye verschuiven..niet roteren
    with Camera.Position do glTranslatef(X, Y, Z);
    // de displaylist uitvoeren
    if DisplayList<>0 then glCallList(DisplayList);
  glPopMatrix;
end;




function TSkyBox.TextureHandleForPlane(PlaneNr: integer): GLuint;
begin
  case PlaneNr of
(*
    planeLeftT  : Result := Texture[texLeft].Handle;
    planeLeftB  : Result := 0{Texture[texLeft].Handle};
    planeRightT : Result := Texture[texRight].Handle;
    planeRightB : Result := 0{Texture[texRight].Handle};
    planeBottom : Result := 0{Texture[texBottom].Handle};
    planeTop    : Result := Texture[texTop].Handle;
    planeNearT  : Result := Texture[texNear].Handle;
    planeNearB  : Result := 0{Texture[texNear].Handle};
    planeFarT   : Result := Texture[texFar].Handle;
    planeFarB   : Result := 0{Texture[texFar].Handle};
*)
    planeLeftT  : Result := Texture[texLeft].Handle;
    planeLeftB  : Result := Texture[texLeft].Handle;
    planeRightT : Result := Texture[texRight].Handle;
    planeRightB : Result := Texture[texRight].Handle;
    planeBottom : Result := Texture[texBottom].Handle;
    planeTop    : Result := Texture[texTop].Handle;
    planeNearT  : Result := Texture[texNear].Handle;
    planeNearB  : Result := Texture[texNear].Handle;
    planeFarT   : Result := Texture[texFar].Handle;
    planeFarB   : Result := Texture[texFar].Handle;
  else
    Result := Texture[texTop].Handle;
  end;
end;


procedure TSkyBox.CreateDisplayList;
const NLen = -1.0; //normalen met richting naar binnen
      //de vertices                                                                             //      7---------6
      VertexArray: array[0..11,0..2] of single = ((-SkyBoxSize,  0,               SkyBoxSize),  //     /|        /|        y
                                                  ( SkyBoxSize,  0,               SkyBoxSize),  //    / |       / |        |
                                                  ( SkyBoxSize,  0.5*SkyBoxSize,  SkyBoxSize),  //   3---------2  |        |___x
                                                  (-SkyBoxSize,  0.5*SkyBoxSize,  SkyBoxSize),  //   |  |      |  |       /
                                                  (-SkyBoxSize,  0,              -SkyBoxSize),  //   |  4------|--5      z
                                                  ( SkyBoxSize,  0,              -SkyBoxSize),  //   | /|      | /|
                                                  ( SkyBoxSize,  0.5*SkyBoxSize, -SkyBoxSize),  //   |/ |      |/ |
                                                  (-SkyBoxSize,  0.5*SkyBoxSize, -SkyBoxSize),  //   0---------1  |
                                                  (-SkyBoxSize, -0.5*SkyBoxSize,  SkyBoxSize),  //   |  |      |  |
                                                  ( SkyBoxSize, -0.5*SkyBoxSize,  SkyBoxSize),  //   |  10-----|--11
                                                  (-SkyBoxSize, -0.5*SkyBoxSize, -SkyBoxSize),  //   | /       | /
                                                  ( SkyBoxSize, -0.5*SkyBoxSize, -SkyBoxSize)); //   |/        |/
                                                                                                //   8---------9
      //index voor 6 zijden met elk 4 punten (quad)
      IndexArray: array[0..39] of byte = (0,4,7,3,          //links
                                          8,10,4,0,
                                          5,1,2,6,          //rechts
                                          11,9,1,5,
                                      //  4,0,1,5,          //onder
                                          10,8,9,11,
                                          6,2,3,7,          //boven
                                          1,0,3,2,          //achter
                                          9,8,0,1,
                                          4,5,6,7,          //voor
                                          10,11,5,4);
      NormalArray: array[0..9,0..2] of single = ((1,0,0),   //links
                                                 (1,0,0),
                                                 (-1,0,0),  //rechts
                                                 (-1,0,0),
                                                 (0,1,0),   //onder
                                                 (0,-1,0),  //boven
                                                 (0,0,1),   //achter
                                                 (0,0,1),
                                                 (0,0,-1),  //voor
                                                 (0,0,-1));

      FogCoordArray: array[0..11] of single = (1.0,  //
                                               1.0,
                                               0.0,
                                               0.0,
                                               1.0,  //
                                               1.0,
                                               0.0,
                                               0.0,
                                               1.0,  //
                                               1.0,
                                               1.0,
                                               1.0);

      TexCoordArray: array[0..39,0..1] of single = ((0,0.5),  //links   0,4,7,3
         {      7---------6                }        (1,0.5),
         {     /|        /|        y       }        (1,1),
         {    / |       / |        |       }        (0,1),
         {   3---------2  |        |___x   }        (0,0),    //        8,10,4,0
         {   |  |      |  |       /        }        (1,0),
         {   |  4------|--5      z         }        (1,0.5),
         {   | /|      | /|                }        (0,0.5),
         {   |/ |      |/ |                }        (0,0.5),  //rechts  5,1,2,6
         {   0---------1  |                }        (1,0.5),
         {   |  |      |  |                }        (1,1),
         {   |  10-----|--11               }        (0,1),
         {   | /       | /                 }        (0,0),    //        11,9,1,5
         {   |/        |/                  }        (1,0),
         {   8---------9                   }        (1,0.5),
         {                                 }        (0,0.5),
                                                    (0,0),    //onder   10,8,9,11
                                                    (1,0),
                                                    (1,1),
                                                    (0,1),
                                                    (0,0),    //boven   6,2,3,7
                                                    (1,0),
                                                    (1,1),
                                                    (0,1),
                                                    (0,0.5),  //achter  1,0,3,2
                                                    (1,0.5),
                                                    (1,1),
                                                    (0,1),
                                                    (0,0),    //        9,8,0,1
                                                    (1,0),
                                                    (1,0.5),
                                                    (0,0.5),
                                                    (0,0.5),  //voor    4,5,6,7
                                                    (1,0.5),
                                                    (1,1),
                                                    (0,1),
                                                    (0,0),    //        10,11,5,4
                                                    (1,0),
                                                    (1,0.5),
                                                    (0,0.5));
var i,j, Index: integer;
    TexHandle: GLuint;
begin
(*
  glEnableClientState(GL_VERTEX_ARRAY);
  glVertexPointer(3, GL_FLOAT, 0, @VertexArray[0]);
  glEnableClientState(GL_NORMAL_ARRAY);
  glNormalPointer(GL_FLOAT, 0, @NormalArray[0,0]);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  glTexCoordPointer(2, GL_FLOAT, 0, @TexCoordArray[0,0]);
*)
  DisplayList := glGenLists(1);
  if DisplayList <> 0 then begin
    glNewList(DisplayList, GL_COMPILE);

      glEnable(GL_DEPTH_TEST);
      glDepthFunc(GL_LESS);
//glDisable(GL_DEPTH_TEST);
      {glDepthRange(0.0, 12.0);}
      {glDepthMask(GL_FALSE);}
      glFrontFace(GL_CCW);
      glCullFace(GL_BACK);
      glEnable(GL_CULL_FACE);
      glPolygonMode(GL_FRONT, GL_FILL);
      glDisable(GL_FOG);
      glDisable(GL_LIGHTING);  // belichting tijdelijk uitschakelen
      glDisable(GL_BLEND);     // blending uit
      glEnable(GL_TEXTURE_2D); // texturing inschakelen

      //
      glColor3f(1.0,1.0,1.0);
      for i:=planeLeftT to planeFarB do begin
        // Eerst een texture binden
        TexHandle := TextureHandleForPlane(i);
        glBindTexture(GL_TEXTURE_2D, TexHandle);
        // geen texture aanwezig??
        if TexHandle = 0 then begin
          // teken een face met kleur(RGB)
          glBegin(GL_QUADS);
            for j:=0 to 3 do begin
              Index := IndexArray[i*4+j];
              glVertex3fv( @VertexArray[Index] );
            end;
          glEnd;
        end else begin
          // dan de texture instellingen
          glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
          //belangrijk te "plakken" aan de randen, anders naadjes.
          glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); // OpenGL 1.2
          glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

          // teken een face met kleur(RGB) & texture(TexHandle)
          glBegin(GL_QUADS);
            glNormal3f(NormalArray[i,0], NormalArray[i,1], NormalArray[i,2]);
            for j:=0 to 3 do begin
              Index := IndexArray[i*4+j];
              glTexCoord2f(TexCoordArray[i*4+j,0], TexCoordArray[i*4+j,1]);
              glVertex3fv( @VertexArray[Index] );
            end;
          glEnd;
(*
          glDrawArrays(GL_QUADS, IndexArray[i*4], 4);
          glDrawElements(GL_QUADS, 4, GL_UNSIGNED_BYTE, @IndexArray[i*4]);
*)
        end;
      end;
      //
    glEndList;
(*
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
*)

    {glDepthFunc(GL_LESS);}
    {glDepthRange(0.0, 1.0);}
    {glDepthMask(GL_TRUE);}
  end;
end;

procedure TSkyBox.DeleteDisplayList;
begin
  if DisplayList <> 0 then
    if glIsList(DisplayList) then
      glDeleteLists(DisplayList, 1);
  DisplayList := 0;
end;







(*
initialization
  SkyBox := TSkyBox.Create;

finalization
  SkyBox.Free;
*)

end.

