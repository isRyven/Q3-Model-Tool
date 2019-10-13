unit u3DTypes;
interface
uses OpenGL;
{$A8}

type
  // een vector
  TVector = packed record
    case Boolean of
      TRUE: (X,Y,Z: Single;);                    // 3x single
      FALSE: (XYZ: array[0..2] of Single;);
    end;
  TVector4f = packed record
    X,Y,Z,W: Single;                  // 4x single
  end;
  TVector3f = TVector;
  TVector2f = packed record
    X, Y : single;
  end;
  TVector3i = packed record
    X,Y,Z: Integer;
  end;
  TVector2i = packed record
    X,Y: Integer;
  end;

  TVectorDynArray = array of TVector;

  TTerrainvertex = packed record
    R,G,B,A: GLfloat;
    X,Y,Z: GLfloat;
//    Normal: TVector;
  end;

  //--- 3D-Studio typen --------------------------------------------------------
  // een 3DS LIN_COLOR
  TRGBA = packed record
            R,G,B,A: Single;                    // 4x 4 bytes floating points
          end;

  // een 3DS COLOR24
  TRGB = packed record
           R,G,B: Byte;                         // 3x byte
         end;

  // een 3DS bounding box
  TBoundingBox = packed record
                   Min,Max: TVector;
                 end;

  // Een row-major matrix (een OpenGL-matrix is column-major!)
  TMatrix = packed record
              V: array[0..3] of TVector;        // 4x TVector   => 3x4 matrix
            end;
  TMatrix4x4 = array[0..3,0..3] of Single;      // 4x4 Singles (column-major)

  // quaternion
  TQuaternion = packed record
                  X,Y,Z,W: Single;              // 4x single
                end;

  // een polygon
  TPolygon = packed record
               Vertex: TVectorDynArray;         //dynamische array van vertex
             end;

  // een 3DS vlak
  TFace = packed record
            V1,V2,V3: Word;                     //index in de array "Vertex"
            Flag: Word;
            Normal: TVector;                    //de normaal op dit vlak
          end;

  // een algemene lijn
  TLine = packed record
    p         : TVector;                        // een punt op de lijn
    Direction : TVector;                        // de richtingsvector
  end;

  // een algemeen vlak (Plane)
  TPlane = packed record
    Normal : TVector;                           // Plane normaal
    d      : Single;                            // De afstand: plane - oorsprong
  end;

  // een algemene bol (Sphere)
  TSphere = record
    Center : TVector;
    Radius : Single;                            // De straal
  end;

  // een 3DS face-group
  TFaceGroup = record
                 MaterialName: string;          // de naam van het materiaal dat alle faces in deze groep gebruiken
                 FaceIndex: array of Integer;   // indexes naar de faces
               end;

  // 3DS texture coordinaten
  TTexCoords = packed record
                 U,V: Single;
               end;

  // een 3DS track-header (keyframer)
  T3DSTrackHeader = record
                      Flags: word;
                      unknown1, unknown2: Integer;
                      KeyCount: Integer;  // het aantal keys in deze track.
                    end;

  // een 3DS key-header (keyframer)
  T3DSKeyHeader = record
                    Time: Integer;        // frame positie
                    SplineFlags: word;    // Als de flag gezet is, dan lezen uit bestand, anders niet..
                    Tension,              //  SplineFlags and $01
                    Continuity,           //  SplineFlags and $02
                    Bias,                 //  SplineFlags and $04
                    EaseTo,               //  SplineFlags and $08
                    EaseFrom: Single;     //  SplineFlags and $10
                  end;

  // een 3DS rotatie-key (keyframer)
  T3DSKeyRotation = record
                      Angle,
                      X,Y,Z: Single
                    end;

  //
  TAnimation = record
                 Index: SmallInt;                        // object-index in array Hierarchy
                 Name: string;                           // object-name in array Hierarchy
                 PosKeyHeaders: array of T3DSKeyHeader;  // translatie
                 Position: array of TVector;
                 RotKeyHeaders: array of T3DSKeyHeader;  // rotatie
                 Rotation: array of T3DSKeyRotation;
               end;

  //
  TTexture = record
               Name: string;                    // bestandsnaam van de texture
               Handle: word;                    // OpenGL texture handle (GLuint)
               Blend: Single;                   // De dekking van de texture op het object
               R,G,B: Single;                   // de kleur van het materiaal
             end;

  // alle waarden in bereik[0.0 .. 1.0] (op Shininess na)
  TMaterial = record
                Name: string;
                Ambient,
                Diffuse,
                Specular,
                Emission: TRGBA;
                Shininess,                      // waarden in bereik[0..128]
                Transparency: Single;
                TwoSided: Boolean;
                Texture: TTexture;
                Reflection: TTexture;
              end;

  // een 3DS Triangle-Object (4100)
  TTriObj = record
              Points: array of TVector;
              Faces: array of TFace;
              Normals: array of TVector;
              TexCoords: array of TTexCoords;
              Flags: array of Byte;
              FaceGroups: array of TFaceGroup;
              SmoothingGroups: array of Integer;// Smoothing voor elke Face
              // "unieke vertex" hulp-arrays
              SPoints: array of TVector;        // gecorrigeerde smoothed vertices
              SSmooth: array of Integer;        // smoothing voor elke vertex
              SNormals: array of TVector;       // Vertex-Normals (aantal Faces*3 elementen)
              STexCoords: array of TTexCoords;  // gecorrigeerde smoothed vertices-texture coordinaten
            end;

  TNamedObj = record
                Name: string;
                DisplayList: word;
                MeshMatrix : TMatrix;
                InverseMeshMatrix: TMatrix4x4;
                PivotPoint,
                InversePivotPoint,
                Center: TVector;
                SmoothAngle: Single;
                BoundingBox: TBoundingBox;
                Animation: TAnimation;
                TriObjs: array of TTriObj;
              end;

  THierarchy = record
                 Name: string;           //object-naam
                 Index,                  //index**      (** = in de array 'NamedObjs')
                 ParentIndex,            //de index** van de parent (-1 bij een root-object zonder parent)
                 Root: SmallInt;         //index** van de root-parent van dit object (-1 als dit object geen TRI_OBJ bezit)
                 Children: array of SmallInt; //alle children-indexes** van dit object
               end;


implementation
{$A8}

end.
