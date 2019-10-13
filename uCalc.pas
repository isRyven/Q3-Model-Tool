unit uCalc;
interface
uses u3DTypes, Graphics; //graphics alleen voor TColor conversie procs..
{$DEFINE SSE_OPCODES}   // SSE code
{$UNDEF SSE3_OPCODES}   // SSE3 code
{$DEFINE SSE_UNALIGNED} // SSE unaligned code
{$A8}

//=== Lijstukken ===============================================================
// Een lijnstuk heeft een beginpunt(P1) en een eindpunt(P2).
// De richting van het lijnstuk: P2-P1 (richtingsvector).
// De vergelijking van een lijnstuk: P = P1 + k*(P2-P1)   waarbij geldt: 0<k<1


//=== Vlakken ==================================================================
// Vlakken zonder afmetingen, alleen een richting(A,B,C) en een afstand tot de oorsprong(-D).
// De vergelijking van een vlak: Ax + By +Cz + D = 0
// De normaal op het vlak is vector(A,B,C)
// De afstand tot de oorsprong is -D   (D=-(Ax+By+Cz))
// Elk punt(x,y,z) ligt op het vlak als geldt: uitkomst = 0
// Een punt ligt voor het vlak als geldt: uitkomst > 0
// Een punt ligt achter het vlak als geldt: uitkomst < 0


//=== Circels en Bollen ========================================================
// De vergelijking van een (2D) circel waarvan het centrum op de oorsprong ligt:
// X² + Y² - R² = 0
// Elk punt(x,y) ligt op de circel als het aan deze vergelijking voldoet.
// Als X² + Y² - R² < 0 dan ligt het punt binnen de circel.
// Als de uitkomst van de vergelijking > 0 is, valt het punt buiten de circel.


//=== Snijpunten ===============================================================
//--- Het snijpunt van 3 vlakken bepalen:
//  |x|   | n1.x n1.y n1.z |   |d1|
//  |y| = | n2.x n2.y n2.z | X |d2|
//  |z|   | n3.x n3.y n3.z |   |d3|
// resultaat = true als er een snijpunt is, anders false..
//
//
// De wiskundige vergelijking voor de punten (x,y) in een 2-dimensionaal assenstelsel, die een cirkel vormen met middelpunt (x0,y0) en straal r is:
// (x - x0)2 + (y - y0)2 = r2
//
//--- Een lijn snijden met een vlak (plane):
// ( * betekent het dotproduct)
// Een snijpunt voldoet aan beide vergelijkingen (voor lijnen & vlakken).
// Dus: p = org+u*dir (lijn)   en   p*normal-k = 0 (vlak)
// Na substitutie:   (org+u*dir)*normal-k = 0
//                   org*normal + u*dir*normal - k = 0
//                   u*dir*normal = k - (org*normal)
//                   u = (k-org*normal) / (dir*normal)
// Als (dir*normal)=0 dan zijn de lijn en het vlak evenwijdig aan elkaar (geen snijpunt dan).
// Anders kan het snijpunt berekend worden door de waarde van   u  in de lijn-vergelijking
// in te vullen.
//
//--- Een lijn snijden met een bol (sphere):
// Een snijpunt voldoet aan beide vergelijkingen (voor lijnen & bollen).
// Dus: p = org+u*dir (lijn)   en   |p-origin| = radius (bol)
// Na substitutie:      |(org+u*dir)-origin| = radius
//                 <=>  (org+u*dir-origin)² = radius²
// Vereenvoudigen, waarbij geldt: A = dir²
//                                B = 2*dir*(org-origin)
//                                C = (org-origin)²
//                  =>  u = -B ± Sqrt(B²-4AC) * 2A
// Als A=0 (dir²=0) dan is er geen snijpunt van de lijn met de bol.
// Als Sqrt(B²-4AC)=0 dan is er maar 1 raakpunt op u=-B/2A.
// In de andere gevallen zijn er 2 snijpunten voor de gevonden u waarde.
// De punten zijn te vinden door u in tevullen in de lijn-vergelijking.


//=== Reflecteren ==============================================================
// Een inkomende vector laten reflecteren op een geraakt vlak.
//
//        PlaneNormal         Bereken eerst lengte N
//        ·                   Scale de plane-normal met N
//      S |                   Bereken de lengte S
//   ·----+----·              N+S = reflectie-vector
//    \   |   /
//   V \ N|  / Result
//      \ | /
//   ____\|/__________
//
//


//=== BillBoard ================================================================
// Een billboard-quad resulteren.
// Een billboard is altijd loodrecht op de line-of-sight gericht.
// Punt "Position" is het middelpunt van de quad.
//
// V4_______V3
//  |       |
//  |   .P  |      P = Position
//  |_______|
// V1       V2
//
const
  // 2*Pi radialen = 360 graden
  constDegToRad : Single = Pi/180.0;            // 1 graad  =  constDegToRad radialen
  constRadToDeg : Single = 180.0/Pi;            // 1 radiaal = constRadToDeg graden

  EPSILON       = 0.0001;

  signbit       : cardinal = $80000000;         // Sign-bit voor een Single
  notsignbit    : cardinal = $7FFFFFFF;         //



// algemeen
procedure SinCos(Degrees:Single; var Sine, Cosine: Single); assembler; register;  //Alpha in graden
function ATan2(Y, X: Extended): Extended;
function GetAngleFOV(Size, Distance: Single) : Single;

// kleuren
procedure TColorToRGB(const aColor: TColor; var R,G,B: single); //TColor -> RGB [0.0  .. 1.0]
procedure RGBToTColor(const R,G,B: single; var aColor: TColor); //TColor -> RGB [0.0  .. 1.0]


// Vector berekeningen
function Vector(X,Y,Z: Single) : TVector; overload;
function Vector(XYZ: array of single) : TVector; overload;
function NullVector : TVector;
function XAxisVector : TVector;
function YAxisVector : TVector;
function ZAxisVector : TVector;
function NegativeXAxisVector : TVector;
function NegativeYAxisVector : TVector;
function NegativeZAxisVector : TVector;
function SameVector(V1,V2: TVector) : boolean;
function AlmostSameVector(V1,V2: TVector; const epsilon:single) : boolean;
function AverageVector(V: array of TVector) : TVector;
function AxisAlignedVector(V: TVector) : boolean;
function RandomizeVector(V: TVector; R: Single) : TVector; overload;  //x, y & z met willekeurige waarden veranderen. R=het max. verschil met het orgineel.




//==============================================================================
// InverseVector
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
{$A8}
  function InverseVector(const V: TVector) : TVector; assembler; register;
{$ELSE}
  function InverseVector(V: TVector) : TVector;
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// AbsVector
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
  function AbsVector(const V: TVector) : TVector; assembler; register;
{$ELSE}
  function AbsVector(V: TVector) : TVector;
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// AddVector
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
  function AddVector(const V1,V2: TVector) : TVector; assembler; register;
{$ELSE}
  function AddVector(V1,V2: TVector) : TVector;
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// SubVector
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
  function SubVector(const V1,V2: TVector) : TVector; assembler; register;
{$ELSE}
  function SubVector(V1,V2: TVector) : TVector;
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// ScaleVector
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
  function ScaleVector(const V: TVector; const Factor: Single) : TVector; assembler; register;
{$ELSE}
  function ScaleVector(V: TVector; Factor: Single) : TVector;
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// VectorLength
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
  function VectorLength(const V: TVector) : Single; assembler; register;
{$ELSE}
  function VectorLength(V: TVector) : Single;
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// UnitVector
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
  function UnitVector(const V: TVector) : TVector; assembler; register;
//  function UnitVector(const V: TVector) : TVector;
{$ELSE}
  function UnitVector(V: TVector) : TVector;
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// CrossProduct
//------------------------------------------------------------------------------
// Het CrossProduct levert als resultaat een vector die loodrecht staat (perpendicular) op de 2 aangeleverde vectoren.
{$IFDEF SSE_OPCODES}
  function CrossProduct(const V1,V2: TVector) : TVector; assembler; register;
{$ELSE}
  function CrossProduct(V1,V2: TVector) : TVector; assembler; register;
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// DotProduct
// Als V1 & V2 unitvectors zijn (lengte 1) dan levert de functie dotProduct
// als resultaat de cosinus tussen de 2 vectoren; Dus hoek = InvCos(DotProduct(V1,V2))
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
  // SSE DotProduct
  function DotProduct(const V1,V2: TVector) : Single; assembler; register;
{$ELSE}
  function DotProduct(V1,V2: TVector) : Single; assembler; register;
{$ENDIF}
//------------------------------------------------------------------------------


function VectorLERP(const V1,V2: TVector; weight: single) : TVector; // weight in [0..1]

// lijnstuk berekeningen
// vindt het punt op lijnstuk(LA-LB) dat het dichtst ligt bij punt P
function ClosestPointOnLine(LA,LB, P: TVector) : TVector;

// Matrix berekeningen
function Matrix4x4(C0R0,C1R0,C2R0,C3R0, C0R1,C1R1,C2R1,C3R1, C0R2,C1R2,C2R2,C3R2, C0R3,C1R3,C2R3,C3R3: Single) : TMatrix4x4;
function IdentityMatrix4x4 : TMatrix4x4;

procedure TransposeMatrix(const M:TMatrix4x4; var M1:TMatrix4x4); overload;
procedure TransposeMatrix(var M:TMatrix4x4); overload;

//==============================================================================
// MultiplyMatrix
//------------------------------------------------------------------------------
function MultiplyMatrix(const A,B: TMatrix4x4) : TMatrix4x4;
{$IFDEF SSE_OPCODES} // gebruik SSE routines
  {$IFDEF SSE_UNALIGNED}
    procedure SSEMultiplyMatrixU(var R: TMatrix4x4; const A,B: TMatrix4x4); assembler; register;   // unaligned
  {$ELSE}
    procedure SSEMultiplyMatrix(var R: TMatrix4x4; const A,B: TMatrix4x4); assembler; register;    //   aligned
  {$ENDIF}
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// TransformVector
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
  // SSE routines (aligned/unaligned)
  function TransformVector(const V: TVector; const M: TMatrix4x4) : TVector;  assembler; register;
{$ELSE}
  function TransformVector(V: TVector; M: TMatrix4x4) : TVector;
{$ENDIF}
//------------------------------------------------------------------------------

(*
procedure GetScreenCoords(V: TVector; var ScreenX,ScreenY: integer);
*)

//roteer punt A om punt B over een hoek R (B blijft dus stilstaan, A beweegt)
function RotateX(A,B: TVector; DegX: Single) : TVector; //"oude" routine's
function RotateY(A,B: TVector; DegY: Single) : TVector; //  "       "
function RotateZ(A,B: TVector; DegZ: Single) : TVector; //  "       "
//rotatie matrices aanmaken..
function XRotationMatrix(DegX: Single) : TMatrix4x4;  //DegX graden om de X-as
function YRotationMatrix(DegY: Single) : TMatrix4x4;  //DegY graden om de Y-as
function ZRotationMatrix(DegZ: Single) : TMatrix4x4;  //DegZ graden om de Z-as
//roteer punt A om punt B over hoeken R.X, R.Y & R.Z   (B blijft dus stilstaan, A beweegt)
function Rotate(A,B, R: TVector) : TVector;
function AxisRotationMatrix(Axis: TVector; Deg: Single) : TMatrix4x4;
//een matrix resulteren voor de opgegeven rotaties in radialen
function RotationMatrix_Rad(RadX,RadY,RadZ: single) : TMatrix4x4; overload;
function RotationMatrix_Rad(Radians:TVector) : TMatrix4x4; overload;

// zet alleen de translatie van een matrix
function SetMatrixTranslation(M:TMatrix4x4; Translation:TVector) : TMatrix4x4;

//==============================================================================
// ScaleMatrix
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
  procedure ScaleMatrix(var M: TMatrix4x4; const Factor: Single); assembler; register;
{$ELSE}
  procedure ScaleMatrix(var M: TMatrix4x4; Factor: Single);
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// MatrixDetInternal
//------------------------------------------------------------------------------
(*
{$IFDEF SSE_OPCODES}
  function MatrixDetInternal(const M: TM9): Single; assembler; register;
{$ELSE}
*)
  function MatrixDetInternal(a1, a2, a3, b1, b2, b3, c1, c2, c3: Single): Single;
(*
{$ENDIF}
*)
//------------------------------------------------------------------------------


//==============================================================================
// MatrixDeterminant
//------------------------------------------------------------------------------

{$IFDEF SSE_OPCODES}
  function MatrixDeterminant(const M: TMatrix4x4) : Single; assembler; register;
{$ELSE}

  function MatrixDeterminant(M: TMatrix4x4) : Single;

{$ENDIF}

// 3x3 variant
function Matrix3x3Determinant(M: TMatrix4x4) : Single;
//------------------------------------------------------------------------------

function CofactorMatrix(M: TMatrix4x4) : TMatrix4x4;
function MatrixInverse(M: TMatrix4x4) : TMatrix4x4;

procedure MatrixAdjoint(var M: TMatrix4x4);
procedure InverseMatrix(var M: TMatrix4x4);


// quaternions
procedure QuaternionToMatrix(var Q:TQuaternion; var M:TMatrix4x4);
procedure MatrixToQuaternion(var M:TMatrix4x4; var Q:TQuaternion);
function QuaternionMagnitude(Q:TQuaternion) : single;
procedure QuaternionNormalize(var Q:TQuaternion);
procedure QuaternionGetRotationAxisAndAngle(Q:TQuaternion; var Axis:TVector; var Angle:Single);
procedure QuaternionRotationAxisAndAngleToQuaternion(Axis:TVector; Angle:Single; var Q:TQuaternion);

// Planes berekeningen.
// vlakken zonder afmetingen, alleen een richting(A,B,C) en een afstand tot de oorsprong(-D)
function PlaneNormal(V1,V2,V3: TVector) : TVector;
function PlaneDistance(Normal, PointOnPlane: TVector) : Single;
function PlaneOrigin(Normal: TVector; DistanceToOrigin: Single) : TVector;

// een lijn snijden met een vlak
{function LinePlaneIntersectionPoint(const Line: TLine; const Plane: TPlane; var S: TVector) : boolean;}
function LinePlaneIntersectionPoint(const L0,L1, P0,P1,P2: TVector; var S: TVector) : boolean; overload;
function LinePlaneIntersectionPoint(const LineOrigin,LineDirection, PlaneNormal,PointOnPlane: TVector; var S: TVector) : boolean; overload;

// een lijn snijden met een (bounding)box (evt. snijpunt in S terug)
// L0 & L1 zijn punten op de lijn
function LineBoxIntersectionPoint(const L0,L1: TVector; const BoundingBox: TBoundingBox; var S: TVector) : boolean;
// ..dezelfde functie met andere parameters: LineDirection is een (richtings)vector
function LineBoxIntersectionPoint2(const LineOrigin,LineDirection: TVector; const BoundingBox: TBoundingBox; var S: TVector) : boolean;

// Het snijpunt van 3 planes bepalen:
// resultaat = true als er een snijpunt is (snijpunt in S), anders false..
function PlanesIntersectionPoint(P1,P2,P3: TPlane; var S: TVector) : boolean;

// een punt V projecteren op een vlak (gegeven door de normaal en een (willekeurig) punt op het vlak
function ProjectPointToPlane(V, PlaneNormal, PointOnPlane: TVector) : TVector;

// een vector reflecteren op een vlak
function ReflectVectorOnPlane(const Direction, PlaneNormal: TVector): TVector;

// een billboard quad resulteren.
procedure BillBoard(const Position:TVector;  var V1,V2,V3:TVector); overload;
procedure BillBoard(const Position,LineOfSight: TVector; const Size: Single; var V1,V2,V3,V4: TVector); overload;
procedure BillBoard(const Position,LineOfSight: TVector; const SizeX,SizeY: Single; var V1,V2,V3,V4: TVector); overload;


// triangles
function TriangleIsCCW(const V1,V2,V3, Normal: TVector) : boolean;

//circels en bollen berekeningen.


implementation
uses Math;
{$A8}


//=== Algemeen =================================================================

procedure SinCos(Degrees:Single; var Sine, Cosine: Single); assembler; register;
const Rad : extended = Pi/180.0;
// sinus als resultaat in ST(1)
// cosinus in ST(0)
asm
  fld    Rad
  fld    Degrees
  fmulp
  fsincos
  fstp   dword ptr [edx]  // cos
  fstp   dword ptr [eax]  // sin
  //fwait
end;

function ATan2(Y, X: Extended): Extended;
asm
  fld Y
  fld X
  fpatan
  //fwait
end;

function GetAngleFOV(Size, Distance: Single) : Single;
var Angle: Single;
begin
  Angle := 2.0 * ATan2(Size/2, Distance);
  Result := Angle * constRadToDeg;
end;


procedure TColorToRGB(const aColor: TColor; var R,G,B: single); //TColor -> RGB [0.0  .. 1.0]
begin
  R := (aColor and $000000FF) / 255;
  G := ((aColor and $0000FF00) shr 8) / 255;
  B := ((aColor and $00FF0000) shr 16) / 255;
end;
procedure RGBToTColor(const R,G,B: single; var aColor: TColor); //TColor -> RGB [0.0  .. 1.0]
begin
  aColor := (Floor(B*255) shl 16) + (Floor(G*255) shl 8) + Floor(R*255);
end;
//=== Vector berekeningen ======================================================

function Vector(X,Y,Z: Single) : TVector;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
end;

function Vector(XYZ: array of single) : TVector;
begin
  if Length(XYZ)>=1 then Result.X := XYZ[0];
  if Length(XYZ)>=2 then Result.Y := XYZ[1];
  if Length(XYZ)>=3 then Result.Z := XYZ[2];
end;

function NullVector : TVector;
begin
  Result := Vector(0, 0, 0);
end;

function XAxisVector : TVector;
begin
  Result := Vector(1, 0, 0);
end;

function YAxisVector : TVector;
begin
  Result := Vector(0, 1, 0);
end;

function ZAxisVector : TVector;
begin
  Result := Vector(0, 0, 1);
end;

function NegativeXAxisVector : TVector;
begin
  Result := Vector(-1, 0, 0);
end;

function NegativeYAxisVector : TVector;
begin
  Result := Vector(0, -1, 0);
end;

function NegativeZAxisVector : TVector;
begin
  Result := Vector(0, 0, -1);
end;

function SameVector(V1,V2: TVector) : boolean;
var x,y,z: boolean;
begin
  x := (V1.X = V2.X);
  y := (V1.Y = V2.Y);
  z := (V1.Z = V2.Z);
  Result := (x and y and z);
end;

function AlmostSameVector(V1,V2: TVector; const epsilon:single) : boolean;
var x,y,z: boolean;
begin
  x := (abs(V1.X - V2.X) < epsilon);
  y := (abs(V1.Y - V2.Y) < epsilon);
  z := (abs(V1.Z - V2.Z) < epsilon);
  Result := (x and y and z);
end;

function AverageVector(V: array of TVector) : TVector;
var Len,i: integer;
begin
  Result := NullVector;
  Len := Length(V);
  if Len=0 then Exit;
  for i:=0 to Len-1 do Result := AddVector(Result, V[i]);
  Result := ScaleVector(Result, 1/Len);
end;

function AxisAlignedVector(V: TVector) : boolean;
var x,y,z: boolean;
    UV: TVector;
begin
  UV := UnitVector(V);
  x := (1.0 - abs(UV.X) < EPSILON);
  y := (1.0 - abs(UV.Y) < EPSILON);
  z := (1.0 - abs(UV.Z) < EPSILON);
  Result := (x or y or z);  //??
end;

function RandomizeVector(V: TVector; R: Single) : TVector;
var RX,RY,RZ,
    SX,SY,SZ,
    CX,CY,CZ: Single;
    UV: TVector;
    Len: Single;
begin
  // De cosinus van de hoek R uitrekenen.
  // Er geldt nu: DotProduct(V, V_R) = C (maximaal)   en V_R is de doel-richting na randomizeVector
  // =>     V.X*V_R.X + V.Y*V_R.Y + V.Z*V_R.Z <= C

  // 3 willekeurige hoeken tot R graden
  RX := Random(Round(R*1000))/1000;
  RY := Random(Round(R*1000))/1000;
  RZ := Random(Round(R*1000))/1000;
  // de cosinus van de hoeken
  SinCos(RX, SX,CX);
  SinCos(RY, SY,CY);
  SinCos(RZ, SZ,CZ);
  UV := UnitVector(V);
  Len := VectorLength(V);
  Result := ScaleVector( Vector( UV.X*CZ*SY, UV.Y*CX*SZ, UV.Z*CY*SX), Len);
end;


//==============================================================================
// InverseVector
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
{$A8}
  // EAX = V
  function InverseVector(const V: TVector) : TVector; assembler; register;
  asm
    movss    xmm0, dword ptr [eax+8]     // xmm0[0..31] := V1.Z
    movhps   xmm0, qword ptr [eax]       // xmm0[64..95] := V1.X,  xmm1[96..127] := V1.Y
    // flip sign-bit
    movss    xmm1, [signbit]
    shufps   xmm1, xmm1, 0
    xorps    xmm0, xmm1
    //
    movss    dword ptr [Result.Z], xmm0  // Result.Z := xmm0[0..31]
    movhps   qword ptr [Result.X], xmm0  // Result.X := xmm0[64..95],  Result.Y := xmm0[96..127]
  end;
{$ELSE}
  function InverseVector(V: TVector) : TVector;
  begin
    Result.X := -V.X;
    Result.Y := -V.Y;
    Result.Z := -V.Z;
  end;
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// AbsVector
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
{$A8}
  // EAX = V
  function AbsVector(const V: TVector) : TVector; assembler; register;
  asm
    movss    xmm0, dword ptr [eax+8]     // xmm0[0..31] := V1.Z
    movhps   xmm0, qword ptr [eax]       // xmm0[64..95] := V1.X,  xmm1[96..127] := V1.Y
    // clear sign-bit
    movss    xmm1, [notsignbit]
    shufps   xmm1, xmm1, 0
    andps    xmm0, xmm1
    //
    movss    dword ptr [Result.Z], xmm0  // Result.Z := xmm0[0..31]
    movhps   qword ptr [Result.X], xmm0  // Result.X := xmm0[64..95],  Result.Y := xmm0[96..127]
  end;
{$ELSE}
  function AbsVector(V: TVector) : TVector;
  begin
    Result.X := Abs(V.X);
    Result.Y := Abs(V.Y);
    Result.Z := Abs(V.Z);
  end;
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// AddVector
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
{$A8}
  // EAX = V1
  // EDX = V2
  function AddVector(const V1,V2: TVector) : TVector; assembler; register;
  asm
    movss    xmm0, dword ptr [eax+8]     // xmm0[0..31] := V1.Z
    movss    xmm1, dword ptr [edx+8]     // xmm1[0..31] := V2.Z
    movhps   xmm0, qword ptr [eax]       // xmm0[64..95] := V1.X,  xmm1[96..127] := V1.Y
    movhps   xmm1, qword ptr [edx]       // xmm1[64..95] := V2.X,  xmm1[96..127] := V2.Y
    addps    xmm0, xmm1
    movss    dword ptr [Result.Z], xmm0  // Result.Z := xmm0[0..31]
    movhps   qword ptr [Result.X], xmm0  // Result.X := xmm0[64..95],  Result.Y := xmm0[96..127]
  end;
{$ELSE}
  function AddVector(V1,V2: TVector) : TVector;
  begin
    Result.X := V1.X + V2.X;
    Result.Y := V1.Y + V2.Y;
    Result.Z := V1.Z + V2.Z;
  end;
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// SubVector
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
{$A8}
  function SubVector(const V1,V2: TVector) : TVector; assembler; register;
  asm
    movss    xmm0, dword ptr [eax+8]     // xmm0[0..31] := V1.Z
    movss    xmm1, dword ptr [edx+8]     // xmm1[0..31] := V2.Z
    movhps   xmm0, qword ptr [eax]       // xmm0[64..95] := V1.X,  xmm1[96..127] := V1.Y
    movhps   xmm1, qword ptr [edx]       // xmm1[64..95] := V2.X,  xmm1[96..127] := V2.Y
    subps    xmm0, xmm1
    movss    dword ptr [Result.Z], xmm0  // Result.Z := xmm0[0..31]
    movhps   qword ptr [Result.X], xmm0  // Result.X := xmm0[64..95],  Result.Y := xmm0[96..127]
  end;
{$ELSE}
  function SubVector(V1,V2: TVector) : TVector;
  begin
    Result.X := V1.X - V2.X;
    Result.Y := V1.Y - V2.Y;
    Result.Z := V1.Z - V2.Z;
  end;
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// ScaleVector
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
{$A8}
  // EAX = V
  // EDX = Factor
  function ScaleVector(const V: TVector; const Factor: Single) : TVector; assembler; register;
  asm
    movss    xmm0, dword ptr [Factor]    // xmm0 := Factor
    movss    xmm1, dword ptr [eax+8]     // xmm1[0..31] := V.Z
    shufps   xmm0, xmm0, 0               // xmm0 := Factor Factor Factor Factor
    movhps   xmm1, qword ptr [eax]       // xmm1[64..95] := V.X,  xmm1[96..127] := V.Y
    mulps    xmm1, xmm0
    movss    dword ptr [Result.Z], xmm1  // Result.Z := xmm1[0..31]
    movhps   qword ptr [Result.X], xmm1  // Result.X := xmm1[64..95],  Result.Y := xmm1[96..127]
  end;
{$ELSE}
  function ScaleVector(V: TVector; Factor: Single) : TVector;
  begin
    Result.X := V.X * Factor;
    Result.Y := V.Y * Factor;
    Result.Z := V.Z * Factor;
  end;
{$ENDIF}


//==============================================================================
// VectorLength
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
  function VectorLength(const V: TVector) : Single; assembler; register;
  asm
    // DotProduct(V,V)
    movss    xmm1, dword ptr [eax+8]     // xmm1[0..31] := V1.Z
    movhps   xmm1, qword ptr [eax]       // xmm1[64..95] := V1.X,  xmm1[96..127] := V1.Y
    mulps    xmm1, xmm1
    {$IFDEF SSE3_OPCODES}
      db $F2, $0F, $7C, $C9              // haddps xmm1, xmm1
      db $F2, $0F, $7C, $C9              // haddps xmm1, xmm1
    {$ELSE}
      movhlps  xmm0, xmm1                // xmm0[0..31] := V1.X*V2.X,  xmm0[32..63] := V1.Y*V2.Y
      movaps   xmm3, xmm0
      shufps   xmm3, xmm3, 01010101b     // xmm3[0..31] := V1.Y*V2.Y
      addss    xmm1, xmm0                // + X*X
      addss    xmm1, xmm3                // + Y*Y
    {$ENDIF}
    // sqrt(DotProduct)
    sqrtss   xmm0, xmm1
    movss    dword ptr [Result], xmm0
  end;
{$ELSE}
  function VectorLength(V: TVector) : Single;
  var D: Single;
  begin
    D := DotProduct(V,V);
    Result := Sqrt(D);
  end;
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// UnitVector
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
  function UnitVector(const V: TVector) : TVector; assembler; register;
  var R: TVector;
      s: single;
  begin
    asm
      // xmm1 := DotProduct(V,V)
      movss    xmm1, dword ptr [eax+8]     // xmm1 := 0 0 0 V1.Z                xmm1[0..31] := V1.Z
      movhps   xmm1, qword ptr [eax]       // xmm1 := V1.Y V1.X 0 V1.Z          xmm1[64..95] := V1.X,  xmm1[96..127] := V1.Y
      movaps   xmm2, xmm1                  // vector bewaren in xmm2
      mulps    xmm1, xmm1
      {$IFDEF SSE3_OPCODES}
        db $F2, $0F, $7C, $C9              // haddps xmm1, xmm1
        db $F2, $0F, $7C, $C9              // haddps xmm1, xmm1
      {$ELSE}
        movhlps  xmm0, xmm1                // xmm0[0..31] := V1.X*V2.X,  xmm0[32..63] := V1.Y*V2.Y
        movaps   xmm3, xmm0
        shufps   xmm3, xmm3, 01010101b     // xmm3[0..31] := V1.Y*V2.Y
        addss    xmm1, xmm0                // + X*X
        addss    xmm1, xmm3                // + Y*Y
      {$ENDIF}
movss    dword ptr [s], xmm1
end;
if s = 0 then
  R := V
else begin
asm
      // xmm0 := 1/sqrt(D)
      rsqrtss  xmm0, xmm1                  // xmm0 := 1/sqrt(D)
      // ScaleVector(V,xmm0)
      shufps   xmm0, xmm0, 0               // xmm0 := Factor Factor Factor Factor
      mulps    xmm2, xmm0
      movss    dword ptr [R.Z], xmm2       // Result.Z := xmm2[0..31]
      movhps   qword ptr [R.X], xmm2       // Result.X := xmm2[64..95],  Result.Y := xmm2[96..127]
    end;
end;    
    Result := R;
  end;
{$ELSE}
  function UnitVector(V: TVector) : TVector;
  var L: Single;
  begin
    L := VectorLength(V);
    if L = 0.0 then Result := V
               else Result := ScaleVector(V, 1/L);
  end;
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// CrossProduct
//------------------------------------------------------------------------------
// Result.X := (V1.Y * V2.Z) - (V1.Z * V2.Y);    // E - F
// Result.Y := (V1.Z * V2.X) - (V1.X * V2.Z);    // C - D
// Result.Z := (V1.X * V2.Y) - (V1.Y * V2.X);    // A - B
{$IFDEF SSE_OPCODES}
  // EAX = V1
  // EDX = V2
  function CrossProduct(const V1,V2: TVector) : TVector; assembler; register;
  asm
    movss    xmm1, dword ptr [eax+8]     // xmm1[0..31] := V1.Z
    movss    xmm2, dword ptr [edx+8]     // xmm2[0..31] := V2.Z
    movhps   xmm1, qword ptr [eax]       // xmm1[64..95] := V1.X,  xmm1[96..127] := V1.Y
    movhps   xmm2, qword ptr [edx]       // xmm2[64..95] := V2.X,  xmm2[96..127] := V2.Y

    movaps   xmm3, xmm1                  // xmm3 := V1.Y V1.X ? V1.Z
    movaps   xmm4, xmm2                  // xmm4 := V2.Y V2.X ? V2.Z

    shufps   xmm3, xmm3, 00110110b       // xmm3 := V1.Z V1.Y ? V1.X
    shufps   xmm4, xmm4, 10000111b       // xmm4 := V2.X V2.Z ? V2.Y
    shufps   xmm1, xmm1, 10000111b       // xmm1 := V1.X V1.Z ? V1.Y
    shufps   xmm2, xmm2, 00110110b       // xmm2 := V2.Z V2.Y ? V2.X

    mulps    xmm4, xmm3                  // xmm4 := C E ? A
    mulps    xmm2, xmm1                  // xmm2 := D F ? B

    subps    xmm4, xmm2

    movhps   qword ptr [Result.X], xmm4
    movss    dword ptr [Result.Z], xmm4
  end;
{$ELSE}
  function CrossProduct(V1,V2: TVector) : TVector; assembler; register;
  asm
    fld    dword ptr [eax + 4]         // ST(0) := V1.y
    fmul   dword ptr [edx + 8]         // ST(0) := ST(0) * V2.z
    fld    dword ptr [eax + 8]         // ST(0) -> ST(1);  ST(0) := V1.z
    fmul   dword ptr [edx + 4]         // ST(0) := ST(0) * V2.y
    fsubp                              // ST(0) := ST(0) - ST(1);    <- ST(1)

    fld    dword ptr [eax + 8]         // ST(0) := V1.y
    fmul   dword ptr [edx + 0]         // ST(0) := ST(0) * V2.x
    fld    dword ptr [eax + 0]         // ST(0) -> ST(1);  ST(0) := V1.x
    fmul   dword ptr [edx + 8]         // ST(0) := ST(0) * V2.z
    fsubp                              // ST(0) := ST(0) - ST(1);    <- ST(1)

    fld    dword ptr [eax + 0]         // ST(0) := V1.x
    fmul   dword ptr [edx + 4]         // ST(0) := ST(0) * V2.y
    fld    dword ptr [eax + 4]         // ST(0) -> ST(1);  ST(0) := V1.y
    fmul   dword ptr [edx + 0]         // ST(0) := ST(0) * V2.x
    fsubp                              // ST(0) := ST(0) - ST(1);    <- ST(1)

    fstp   dword ptr [Result.Z]        // <- ST(0)
    fstp   dword ptr [Result.Y]        // <- ST(0)
    fstp   dword ptr [Result.X]        // <- ST(0)
    //fwait
  end;
{$ENDIF}

//------------------------------------------------------------------------------


//==============================================================================
// DotProduct
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
  // Result := V1.X*V2.X + V1.Y*V2.Y + V1.Z*V2.Z;

  // SSE DotProduct routine
  function DotProduct(const V1,V2: TVector) : Single; assembler; register;
  asm
    movss    xmm1, dword ptr [eax+8]   // xmm1[0..31] := V1.Z
    movss    xmm2, dword ptr [edx+8]   // xmm2[0..31] := V2.Z
    movhps   xmm1, qword ptr [eax]     // xmm1[64..95] := V1.X,  xmm1[96..127] := V1.Y
    movhps   xmm2, qword ptr [edx]     // xmm2[64..95] := V2.X,  xmm2[96..127] := V2.Y
    mulps    xmm1, xmm2
    {$IFDEF SSE3_OPCODES}
      db $F2, $0F, $7C, $C9            // haddps xmm1, xmm1
      db $F2, $0F, $7C, $C9            // haddps xmm1, xmm1
    {$ELSE}
      movhlps  xmm0, xmm1              // xmm0[0..31] := V1.X*V2.X,  xmm0[32..63] := V1.Y*V2.Y
      movaps   xmm3, xmm0
      shufps   xmm3, xmm3, 01010101b   // xmm3[0..31] := V1.Y*V2.Y
      addss    xmm1, xmm0
      addss    xmm1, xmm3
    {$ENDIF}
    movss    dword ptr [Result], xmm1
(*
    movss	   xmm0, dword ptr [eax]     // xmm0 = ??   ??   ??   V1.z
    movss	   xmm1, dword ptr [edx]     // xmm1 = ??   ??   ??   V2.z
    mulps    xmm0, xmm1                // xmm0 = ??   ??   ??   V1.z*V2.z

    movss	   xmm1, dword ptr [eax+4]   // xmm1 = ??   ??   ??   V1.y
    movss	   xmm2, dword ptr [edx+4]   // xmm2 = ??   ??   ??   V2.y
    mulps    xmm1, xmm2                // xmm1 = ??   ??   ??   V1.y*V2.y

    movss	   xmm2, dword ptr [eax+8]   // xmm2 = ??   ??   ??   V1.x
    movss	   xmm3, dword ptr [edx+8]   // xmm3 = ??   ??   ??   V2.x
    mulps    xmm2, xmm3                // xmm2 = ??   ??   ??   V1.x*V2.x

    addps    xmm0, xmm1                // xmm0 = ??   ??   ??   V1.z*V2.z + V1.y*V2.y
    addps    xmm0, xmm2                // xmm0 = ??   ??   ??   V1.z*V2.z + V1.y*V2.y + V1.x*V2.x
    movss    [Result], xmm0
*)
  end;
{$ELSE}
  function DotProduct(V1,V2: TVector) : Single; assembler; register;
  // (Zie delphi help voor de 'register' aanduiding bij de functie-declaratie)
  // EAX bevat het adres van V1
  // EDX bevat het adres van V2
  // resultaat in ST(0).
  asm
    fld    dword ptr [eax]             // ST(0) := V1.x
    fmul   dword ptr [edx]             // ST(0) := ST(0) * V2.x
    fld    dword ptr [eax + 4]         // ST(0) -> ST(1);  ST(0) := V1.y
    fmul   dword ptr [edx + 4]         // ST(0) := ST(0) * V2.y
    faddp                              // ST(0) := ST(0) + ST(1)
    fld    dword ptr [eax + 8]         // ST(0) -> ST(1);  ST(0) := V1.z
    fmul   dword ptr [edx + 8]         // ST(0) := ST(0) * V2.z
    faddp                              // ST(0) := ST(0) + ST(1)
  end;
{$ENDIF}
//------------------------------------------------------------------------------



function VectorLERP(const V1,V2: TVector; Weight: single) : TVector; // weight in [0..1]
begin
  Result.X := (1-Weight)*V1.X + Weight*V2.X;
  Result.Y := (1-Weight)*V1.Y + Weight*V2.Y;
  Result.Z := (1-Weight)*V1.Z + Weight*V2.Z;
end;



//=== Lijnstuk berekeningen ====================================================
function ClosestPointOnLine(LA,LB, P: TVector) : TVector;
var V1,V2,V3: TVector;
    L, distance: single;
begin
  // maak een vlak met de 2 punten van het lijnstuk en het 3e punt P..
  V1 := SubVector(P, LA);
  V2 := UnitVector(SubVector(LB, LA));  //alleen de richting gebruiken, niet de grootte..
  // de lengte van het lijnstuk
  L := VectorLength(SubVector(LA, LB));
  // de afstand vanaf punt P tot het lijnstuk
  distance := DotProduct(V2,V1);
  //
  if distance <= 0 then
    Result := LA
  else
  if distance >= L then
    Result := LB
  else begin
    // maak een vector V3 met een richting V2 en lengte distance
    V3 := ScaleVector(V2, distance);
    Result := AddVector(LA, V3);
  end;
end;



//=== Matrix berekeningen ======================================================
// Mijn matrices zijn row-major zijn opgesteld als in OpenGL.
// (blz. 673 van de OpenGL Programming Guide)


function Matrix4x4(C0R0,C1R0,C2R0,C3R0, C0R1,C1R1,C2R1,C3R1, C0R2,C1R2,C2R2,C3R2, C0R3,C1R3,C2R3,C3R3: Single) : TMatrix4x4;
begin
  Result[0,0]:=C0R0;  Result[0,1]:=C1R0;  Result[0,2]:=C2R0;  Result[0,3]:=C3R0;
  Result[1,0]:=C0R1;  Result[1,1]:=C1R1;  Result[1,2]:=C2R1;  Result[1,3]:=C3R1;
  Result[2,0]:=C0R2;  Result[2,1]:=C1R2;  Result[2,2]:=C2R2;  Result[2,3]:=C3R2;
  Result[3,0]:=C0R3;  Result[3,1]:=C1R3;  Result[3,2]:=C2R3;  Result[3,3]:=C3R3;
end;

function IdentityMatrix4x4 : TMatrix4x4;
const IdentityMatrix: TMatrix4x4 = ((1,0,0,0), (0,1,0,0), (0,0,1,0), (0,0,0,1));
begin
  Result := IdentityMatrix;
end;

procedure TransposeMatrix(const M:TMatrix4x4; var M1:TMatrix4x4);
var r,c: integer;
begin
  for r:=0 to 3 do
    for c:=0 to 3 do
      M1[c,r] := M[r,c];
end;
procedure TransposeMatrix(var M:TMatrix4x4);
var r,c: integer;
    tmp: Single;
begin
  for r:=0 to 3 do begin
    for c:=r to 3 do begin
      if c=r then continue;
      tmp := M[r,c];
      M[r,c] := M[c,r];
      M[c,r] := tmp;
    end;
  end;
end;

//==============================================================================
// MultiplyMatrix
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES} // gebruik SSE routines
  {$IFDEF SSE_UNALIGNED} // unaligned code
    function MultiplyMatrix(const A,B: TMatrix4x4) : TMatrix4x4;
    var M: TMatrix4x4;
    begin
      SSEMultiplyMatrixU(M, A,B);
      Result := M;
    end;

    procedure SSEMultiplyMatrixU(var R: TMatrix4x4; const A,B: TMatrix4x4); assembler; register;
    asm
      movss	   xmm0, dword ptr [edx]        // A
      movups   xmm1, [ecx]                  // B
      shufps   xmm0, xmm0, 0
      movss	   xmm2, dword ptr [edx+4]
      mulps	   xmm0, xmm1
      shufps   xmm2, xmm2, 0
      movups   xmm3, [ecx+10h]
      movss	   xmm7, dword ptr [edx+8]
      mulps	   xmm2, xmm3
      shufps   xmm7, xmm7, 0
      addps	   xmm0, xmm2
      movups   xmm4, [ecx+20h]
      movss	   xmm2, dword ptr [edx+0Ch]
      mulps	   xmm7, xmm4
      shufps   xmm2, xmm2, 0
      addps	   xmm0, xmm7
      movups   xmm5, [ecx+30h]
      movss	   xmm6, dword ptr [edx+10h]
      mulps	   xmm2, xmm5
      movss	   xmm7, dword ptr [edx+14h]
      shufps   xmm6, xmm6, 0
      addps	   xmm0, xmm2
      shufps   xmm7, xmm7, 0
      movlps   qword ptr [eax], xmm0        // R
      movhps   qword ptr [eax+8], xmm0      // R
      mulps	   xmm7, xmm3
      movss	   xmm0, dword ptr [edx+18h]
      mulps	   xmm6, xmm1
      shufps   xmm0, xmm0, 0
      addps	   xmm6, xmm7
      mulps	   xmm0, xmm4
      movss	   xmm2, dword ptr [edx+24h]
      addps	   xmm6, xmm0
      movss	   xmm0, dword ptr [edx+1Ch]
      movss	   xmm7, dword ptr [edx+20h]
      shufps   xmm0, xmm0, 0
      shufps   xmm7, xmm7, 0
      mulps	   xmm0, xmm5
      mulps	   xmm7, xmm1
      addps	   xmm6, xmm0
      shufps   xmm2, xmm2, 0
      movlps   qword ptr [eax+10h], xmm6
      movhps   qword ptr [eax+18h], xmm6
      mulps	   xmm2, xmm3
      movss	   xmm6, dword ptr [edx+28h]
      addps	   xmm7, xmm2
      shufps   xmm6, xmm6, 0
      movss	   xmm2, dword ptr [edx+2Ch]
      mulps	   xmm6, xmm4
      shufps   xmm2, xmm2, 0
      addps	   xmm7, xmm6
      mulps	   xmm2, xmm5
      movss	   xmm0, dword ptr [edx+34h]
      addps	   xmm7, xmm2
      shufps   xmm0, xmm0, 0
      movlps   qword ptr [eax+20h], xmm7
      movss	   xmm2, dword ptr [edx+30h]
      movhps   qword ptr [eax+28h], xmm7
      mulps	   xmm0, xmm3
      shufps   xmm2, xmm2, 0
      movss	   xmm6, dword ptr [edx+38h]
      mulps	   xmm2, xmm1
      shufps   xmm6, xmm6, 0
      addps	   xmm2, xmm0
      mulps	   xmm6, xmm4
      movss	   xmm7, dword ptr [edx+3Ch]
      shufps   xmm7, xmm7, 0
      addps	   xmm2, xmm6
      mulps	   xmm7, xmm5
      addps	   xmm2, xmm7
      movups   [eax+30h], xmm2
    end;
  {$ELSE}  // aligned
    function MultiplyMatrix(const A,B: TMatrix4x4) : TMatrix4x4;
    var M: TMatrix4x4;
    begin
      SSEMultiplyMatrix(M, A,B);
      Result := M;
    end;

    // EAX = R
    // EDX = A
    // ECX = B
    procedure SSEMultiplyMatrix(var R: TMatrix4x4; const A,B: TMatrix4x4); assembler; register;
    asm
      movss	   xmm0, dword ptr [edx]          // xmm0 := A[0,0]
      movaps   xmm1, [ecx]                    // xmm1 := B[0,0..3]
      shufps   xmm0, xmm0, 0                  // xmm0 := A[0,0] A[0,0] A[0,0] A[0,0]
      movss	   xmm2, dword ptr [edx+4]        // xmm2 := A[0,1]
      mulps	   xmm0, xmm1                     // xmm0 := A[0,0]*B[0,0] A[0,0]*B[0,1] A[0,0]*B[0,2] A[0,0]*B[0,3]
      shufps   xmm2, xmm2, 0                  // xmm2 := A[0,1] A[0,1] A[0,1] A[0,1]
      movaps   xmm3, [ecx+10h]                // xmm3 := B[1,0..3]
      movss	   xmm7, dword ptr [edx+8]        // xmm7 := A[0,2]
      mulps	   xmm2, xmm3                     // xmm2 := A[0,1]*B[1,0] A[0,1]*B[1,1] A[0,1]*B[1,2] A[0,1]*B[1,3]
      shufps   xmm7, xmm7, 0                  // xmm7 := A[0,2] A[0,2] A[0,2] A[0,2]
      addps	   xmm0, xmm2                     // xmm0 := A[0,0]*B[0,0]+A[0,1]*B[1,0] A[0,0]*B[0,1]+A[0,1]*B[1,1] A[0,0]*B[0,2]+A[0,1]*B[1,2] A[0,0]*B[0,3]+A[0,1]*B[1,3]
      movaps   xmm4, [ecx+20h]                // xmm4 := B[2,0..3]
      movss	   xmm2, dword ptr [edx+0Ch]      // xmm2 := A[0,3]
      mulps	   xmm7, xmm4                     // xmm7 := A[0,2]*B[2,0] A[0,2]*B[2,1] A[0,2]*B[2,2] A[0,2]*B[2,3]
      shufps   xmm2, xmm2, 0                  // xmm2 := A[0,3] A[0,3] A[0,3] A[0,3]
      addps	   xmm0, xmm7                     // xmm0 := A[0,0]*B[0,0]+A[0,1]*B[1,0]+A[0,2]*B[2,0] A[0,0]*B[0,1]+A[0,1]*B[1,1]+A[0,2]*B[2,1] A[0,0]*B[0,2]+A[0,1]*B[1,2]+A[0,2]*B[2,2] A[0,0]*B[0,3]+A[0,1]*B[1,3]+A[0,2]*B[2,3]
      movaps   xmm5, [ecx+30h]                // xmm5 := B[3,0..3]
      movss	   xmm6, dword ptr [edx+10h]      // xmm6 := A[1,0]
      mulps	   xmm2, xmm5                     // xmm2 := A[0,3]*B[3,0] A[0,3]*B[3,1] A[0,3]*B[3,2] A[0,3]*B[3,3]
      movss	   xmm7, dword ptr [edx+14h]      // xmm7 := A[1,1]
      shufps   xmm6, xmm6, 0                  // xmm6 := A[1,0] A[1,0] A[1,0] A[1,0]
      addps	   xmm0, xmm2                     // xmm0 := A[0,0]*B[0,0]+A[0,1]*B[1,0]+A[0,2]*B[2,0]+A[0,3]*B[3,0] A[0,0]*B[0,1]+A[0,1]*B[1,1]+A[0,2]*B[2,1]+A[0,3]*B[3,1] A[0,0]*B[0,2]+A[0,1]*B[1,2]+A[0,2]*B[2,2]+A[0,3]*B[3,2] A[0,0]*B[0,3]+A[0,1]*B[1,3]+A[0,2]*B[2,3]+A[0,3]*B[3,3]
      shufps   xmm7, xmm7, 0                  // xmm7 := A[1,1] A[1,1] A[1,1] A[1,1]
      movlps   qword ptr [eax], xmm0          // R[0,0..3] := xmm0
      movhps   qword ptr [eax+8], xmm0        //
      mulps	   xmm7, xmm3                     //
      movss	   xmm0, dword ptr [edx+18h]
      mulps	   xmm6, xmm1
      shufps   xmm0, xmm0, 0
      addps	   xmm6, xmm7
      mulps	   xmm0, xmm4
      movss	   xmm2, dword ptr [edx+24h]
      addps	   xmm6, xmm0
      movss	   xmm0, dword ptr [edx+1Ch]
      movss	   xmm7, dword ptr [edx+20h]
      shufps   xmm0, xmm0, 0
      shufps   xmm7, xmm7, 0
      mulps	   xmm0, xmm5
      mulps	   xmm7, xmm1
      addps	   xmm6, xmm0
      shufps   xmm2, xmm2, 0
      movlps   qword ptr [eax+10h], xmm6
      movhps   qword ptr [eax+18h], xmm6
      mulps	   xmm2, xmm3
      movss	   xmm6, dword ptr [edx+28h]
      addps	   xmm7, xmm2
      shufps   xmm6, xmm6, 0
      movss	   xmm2, dword ptr [edx+2Ch]
      mulps	   xmm6, xmm4
      shufps   xmm2, xmm2, 0
      addps	   xmm7, xmm6
      mulps	   xmm2, xmm5
      movss	   xmm0, dword ptr [edx+34h]
      addps	   xmm7, xmm2
      shufps   xmm0, xmm0, 0
      movlps   qword ptr [eax+20h], xmm7
      movss	   xmm2, dword ptr [edx+30h]
      movhps   qword ptr [eax+28h], xmm7
      mulps	   xmm0, xmm3
      shufps   xmm2, xmm2, 0
      movss	   xmm6, dword ptr [edx+38h]
      mulps	   xmm2, xmm1
      shufps   xmm6, xmm6, 0
      addps	   xmm2, xmm0
      mulps	   xmm6, xmm4
      movss	   xmm7, dword ptr [edx+3Ch]
      shufps   xmm7, xmm7, 0
      addps	   xmm2, xmm6
      mulps	   xmm7, xmm5
      addps	   xmm2, xmm7
      movaps   [eax+30h], xmm2
    end;
  {$ENDIF}
{$ELSE}
  function MultiplyMatrix(const A,B: TMatrix4x4) : TMatrix4x4;
  var C,R: Byte;
  begin
    for R:=0 to 3 do
      for C:=0 to 3 do
        Result[R,C] := A[R,0] * B[0,C] + A[R,1] * B[1,C] + A[R,2] * B[2,C] + A[R,3] * B[3,C];
  end;
{$ENDIF}
//------------------------------------------------------------------------------




//==============================================================================
// TransformVector
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
  {$A8}
  {$IFDEF SSE_UNALIGNED}
    // SSE unaligned code

    // EAX bevat het adres van V
    // EDX bevat het adres van M
    function TransformVector(const V: TVector; const M: TMatrix4x4) : TVector;  assembler; register;
    asm
      movss	   xmm0, dword ptr [eax]       // xmm0 :=  ?   ?   ?  V.x
      movss	   xmm1, dword ptr [eax+4]     // xmm1 :=  ?   ?   ?  V.y
      movss	   xmm2, dword ptr [eax+8]     // xmm2 :=  ?   ?   ?  V.z

      shufps   xmm0, xmm0, 0               // xmm0 := V.x V.x V.x V.x
      shufps   xmm1, xmm1, 0               // xmm1 := V.y V.y V.y V.y
      shufps   xmm2, xmm2, 0               // xmm2 := V.z V.z V.z V.z

      movups   xmm3, [edx]                 // xmm3 := M[0,0..3]
      movups   xmm4, [edx+16]              // xmm4 := M[1,0..3]
      movups   xmm5, [edx+32]              // xmm5 := M[2,0..3]
      movups   xmm6, [edx+48]              // xmm6 := M[3,0..3]

      mulps	   xmm0, xmm3                  // xmm0 := V.x*M[0,0] V.x*M[0,1] V.x*M[0,2] V.x*M[0,3]
      mulps	   xmm1, xmm4                  // xmm1 := V.y*M[1,0] V.y*M[1,1] V.y*M[1,2] V.y*M[1,3]
      mulps	   xmm2, xmm5                  // xmm2 := V.z*M[2,0] V.z*M[2,1] V.z*M[2,2] V.z*M[2,3]

      addps	   xmm0, xmm1                  //
      addps	   xmm0, xmm2                  // xmm0 := (V.x*M[0,0] + V.y*M[1,0] + V.z*M[2,0]) (V.x*M[0,1] + V.y*M[1,1] + V.z*M[2,1]) (V.x*M[0,2] + V.y*M[1,2] + V.z*M[2,2]) (??)
      addps    xmm0, xmm6                  // xmm6  =  M[3,0]                                 M[3,1]                                 M[3,2]                                 ??

      movlps   qword ptr [Result], xmm0    // Result.X := xmm0[0..31],  Result.Y := xmm0[32..63]
      shufps   xmm0, xmm0, 10101010b       // xmm0 := xmm0[64..95] xmm0[64..95] xmm0[64..95] xmm0[64..95]
      movss    [Result.Z], xmm0
    end;
  {$ELSE}
    // SSE aligned code
    function TransformVector(const V: TVector; const M: TMatrix4x4) : TVector;  assembler; register;
    asm
      movss	   xmm0, dword ptr [eax]       // xmm0 :=  ?   ?   ?  V.x
      movss	   xmm1, dword ptr [eax+4]     // xmm1 :=  ?   ?   ?  V.y
      movss	   xmm2, dword ptr [eax+8]     // xmm2 :=  ?   ?   ?  V.z

      shufps   xmm0, xmm0, 0               // xmm0 := V.x V.x V.x V.x
      shufps   xmm1, xmm1, 0               // xmm1 := V.y V.y V.y V.y
      shufps   xmm2, xmm2, 0               // xmm2 := V.z V.z V.z V.z

      movaps   xmm3, [edx]                 // xmm3 := M[0,0..3]
      movaps   xmm4, [edx+16]              // xmm4 := M[1,0..3]
      movaps   xmm5, [edx+32]              // xmm5 := M[2,0..3]
      movaps   xmm6, [edx+48]              // xmm6 := M[3,0..3]

      mulps	   xmm0, xmm3                  // xmm0 := V.x*M[0,0] V.x*M[0,1] V.x*M[0,2] V.x*M[0,3]
      mulps	   xmm1, xmm4                  // xmm1 := V.y*M[1,0] V.y*M[1,1] V.y*M[1,2] V.y*M[1,3]
      mulps	   xmm2, xmm5                  // xmm2 := V.z*M[2,0] V.z*M[2,1] V.z*M[2,2] V.z*M[2,3]

      addps	   xmm0, xmm1                  //
      addps	   xmm0, xmm2                  // xmm0 := (V.x*M[0,0] + V.y*M[1,0] + V.z*M[2,0]) (V.x*M[0,1] + V.y*M[1,1] + V.z*M[2,1]) (V.x*M[0,2] + V.y*M[1,2] + V.z*M[2,2]) (??)
      addps    xmm0, xmm6                  // xmm6  =  M[3,0]                                 M[3,1]                                 M[3,2]                                 ??

      movlps   qword ptr [Result], xmm0    // Result.X := xmm0[0..31],  Result.Y := xmm0[32..63]
      shufps   xmm0, xmm0, 10101010b       // xmm0 := xmm0[64..95] xmm0[64..95] xmm0[64..95] xmm0[64..95]
      movss    [Result.Z], xmm0
    end;
  {$ENDIF}
{$ELSE}
  function TransformVector(V: TVector; M: TMatrix4x4) : TVector;
  begin
    Result.X := V.X * M[0,0] + V.Y * M[1,0] + V.Z * M[2,0] + M[3,0];
    Result.Y := V.X * M[0,1] + V.Y * M[1,1] + V.Z * M[2,1] + M[3,1];
    Result.Z := V.X * M[0,2] + V.Y * M[1,2] + V.Z * M[2,2] + M[3,2];
  end;
{$ENDIF}
//------------------------------------------------------------------------------




function RotateX(A,B: TVector; DegX: Single) : TVector;
var V: TVector;
    C,S: Single;
begin
  Result := A;
  if DegX <> 0 then begin
    SinCos(DegX, S,C);
    V := SubVector(A,B);
    Result.Y := B.Y + C*V.Y - S*V.Z;
    Result.Z := B.Z + S*V.Y + C*V.Z;
  end;
end;
function RotateY(A,B: TVector; DegY: Single) : TVector;
var V: TVector;
    C,S: Single;
begin
  Result := A;
  if DegY <> 0 then begin
    SinCos(DegY, S,C);
    V := SubVector(A,B);
    Result.X := B.X + C*V.X + S*V.Z;
    Result.Z := B.Z - S*V.X + C*V.Z;
  end;
end;
function RotateZ(A,B: TVector; DegZ: Single) : TVector;
var V: TVector;
    C,S: Single;
begin
  Result := A;
  if DegZ <> 0 then begin
    SinCos(DegZ, S,C);
    V := SubVector(A,B);
    Result.X := B.X + C*V.Y - S*V.X;
    Result.Y := B.Y + S*V.Y + C*V.X;
  end;
end;

function XRotationMatrix(DegX: Single) : TMatrix4x4;
var C,S: Single;
begin
  SinCos(DegX, S,C);
  Result := Matrix4x4(1,0,0,0, 0,C,-S,0, 0,S,C,0, 0,0,0,1);
end;
function YRotationMatrix(DegY: Single) : TMatrix4x4;
var C,S: Single;
begin
  SinCos(DegY, S,C);
  Result := Matrix4x4(C,0,S,0, 0,1,0,0, -S,0,C,0, 0,0,0,1);
end;
function ZRotationMatrix(DegZ: Single) : TMatrix4x4;
var C,S: Single;
begin
  SinCos(DegZ, S,C);
  Result := Matrix4x4(C,-S,0,0, S,C,0,0, 0,0,1,0, 0,0,0,1);
end;


function Rotate(A,B, R: TVector) : TVector;
var M: TMatrix4x4;
begin
  M := MultiplyMatrix(MultiplyMatrix(XRotationMatrix(R.X), YRotationMatrix(R.Y)), ZRotationMatrix(R.Z));
  Result := TransformVector(SubVector(A,B), M);
end;


function AxisRotationMatrix(Axis: TVector; Deg: Single) : TMatrix4x4;
var S,C,C1, L: Single;
    A: TVector;
begin
  SinCos(Deg, S,C);
  C1 := 1 - C;
  A := Axis;
  L := VectorLength(A);
  if L=0 then
    Result := IdentityMatrix4x4
  else begin
    A := UnitVector(A);
    Result[0,0] := (C1 * Sqr(A.X)) + C;
    Result[0,1] := (C1 * A.X * A.Y) - (A.Z * S);
    Result[0,2] := (C1 * A.Z * A.X) + (A.Y * S);
    Result[0,3] := 0;
    //
    Result[1,0] := (C1 * A.X * A.Y) + (A.Z * S);
    Result[1,1] := (C1 * Sqr(A.Y)) + C;
    Result[1,2] := (C1 * A.Y * A.Z) - (A.X * S);
    Result[1,3] := 0;
    //
    Result[2,0] := (C1 * A.Z * A.X) - (A.Y * S);
    Result[2,1] := (C1 * A.Y * A.Z) + (A.X * S);
    Result[2,2] := (C1 * Sqr(A.Z)) + C;
    Result[2,3] := 0;
    //
    Result[3,0] := 0;
    Result[3,1] := 0;
    Result[3,2] := 0;
    Result[3,3] := 1;
  end;
end;


function RotationMatrix_Rad(RadX,RadY,RadZ: single) : TMatrix4x4; overload;
var cr,sr, cp,sp, cy,sy, srsp,crsp: single;
begin
  cr := Cos(RadX);
  sr := Sin(RadX);
  cp := Cos(RadY);
  sp := Sin(RadY);
  cy := Cos(RadZ);
  sy := Sin(RadZ);

  Result[0,0] := cp*cy;
  Result[0,1] := cp*sy;
  Result[0,2] := -sp;
  Result[0,3] := 0.0;

  srsp := sr*sp;
  crsp := cr*sp;

  Result[1,0] := srsp*cy - cr*sy;
  Result[1,1] := srsp*sy + cr*cy;
  Result[1,2] := sr*cp;
  Result[1,3] := 0.0;

  Result[2,0] := crsp*cy + sr*sy;
  Result[2,1] := crsp*sy - sr*cy;
  Result[2,2] := cr*cp;
  Result[2,3] := 0.0;

  Result[3,0] := 0.0;
  Result[3,1] := 0.0;
  Result[3,2] := 0.0;
  Result[3,3] := 1.0;
end;

function RotationMatrix_Rad(Radians:TVector) : TMatrix4x4; overload;
begin
  Result := RotationMatrix_Rad(Radians.X, Radians.Y, Radians.Z);
end;


function SetMatrixTranslation(M:TMatrix4x4; Translation:TVector) : TMatrix4x4;
begin
  Result := M;
  Result[3,0] := Translation.X;
  Result[3,1] := Translation.Y;
  Result[3,2] := Translation.Z;
end;

//==============================================================================
// ScaleMatrix
//------------------------------------------------------------------------------
{$IFDEF SSE_OPCODES}
  {$A8}
  {$IFDEF SSE_UNALIGNED}
    // unaligned SSE code
    procedure ScaleMatrix(var M: TMatrix4x4; const Factor: Single); assembler; register;
    asm
      movups  xmm1, [eax]
      movups  xmm2, [eax+$10]
      movups  xmm3, [eax+$20]
      movups  xmm4, [eax+$30]

      movss   xmm0, [Factor]
      shufps  xmm0, xmm0, 0

      mulps   xmm1, xmm0
      mulps   xmm2, xmm0
      mulps   xmm3, xmm0
      mulps   xmm4, xmm0

      movups  [eax], xmm1
      movups  [eax+$10], xmm2
      movups  [eax+$20], xmm3
      movups  [eax+$30], xmm4
    end;
  {$ELSE}
    // aligned SSE code
    procedure ScaleMatrix(var M: TMatrix4x4; const Factor: Single); assembler; register;
    asm
      movaps  xmm1, [eax]
      movaps  xmm2, [eax+$10]
      movaps  xmm3, [eax+$20]
      movaps  xmm4, [eax+$30]

      movss   xmm0, [Factor]
      shufps  xmm0, xmm0, 0

      mulps   xmm1, xmm0
      mulps   xmm2, xmm0
      mulps   xmm3, xmm0
      mulps   xmm4, xmm0

      movaps  [eax], xmm1
      movaps  [eax+$10], xmm2
      movaps  [eax+$20], xmm3
      movaps  [eax+$30], xmm4
    end;
  {$ENDIF}
{$ELSE}
  procedure ScaleMatrix(var M: TMatrix4x4; Factor: Single);
  var I, J: Integer;
  begin
    for I := 0 to 3 do
      for J := 0 to 3 do M[I,J] := M[I,J] * Factor;
  end;
{$ENDIF}
//------------------------------------------------------------------------------


//==============================================================================
// MatrixDetInternal
//------------------------------------------------------------------------------
// internal version for the determinant of a 3x3 matrix
(*
{$IFDEF SSE_OPCODES}
  {$A8}
  {$IFDEF SSE_UNALIGNED}
    // SSE unaligned code
  {$ELSE}
    // SSE aligned code
  {$ENDIF}
{$ELSE}
*)
  function MatrixDetInternal(a1, a2, a3, b1, b2, b3, c1, c2, c3: Single): Single;
  begin
    Result := a1 * (b2 * c3 - b3 * c2) -
              b1 * (a2 * c3 - a3 * c2) +
              c1 * (a2 * b3 - a3 * b2);
  end;
(*
{$ENDIF}
*)
//------------------------------------------------------------------------------


//==============================================================================
// MatrixDeterminant
//------------------------------------------------------------------------------
// M00 * (M11*(M22*M33-M32*M23) - M12*(M21*M33-M31*M23) + M13*(M21*M32-M31*M22)) -
// M01 * (M10*(M22*M33-M32*M23) - M12*(M20*M33-M30*M23) + M13*(M20*M32-M30*M22)) +
// M02 * (M10*(M21*M33-M31*M23) - M11*(M20*M33-M30*M23) + M13*(M20*M31-M30*M21)) -
// M03 * (M10*(M21*M32-M31*M22) - M11*(M20*M32-M30*M22) + M12*(M20*M31-M30*M21))
//
// M00 * (M11*A                 - M12*B                 + M13*C)                 -
// M01 * (M10*D                 - M12*E                 + M13*F)                 +
// M02 * (M10*G                 - M11*H                 + M13*I)                 -
// M03 * (M10*J                 - M11*K                 + M12*L)
//
// M -             M +
// N +       <=>  -N +
// O -             O +
// P              -P
//
// 40 vermenigvldigingen & 18 aftrekkingen & 5 optellingen.
{$IFDEF SSE_OPCODES}
  {$A8}
  {$IFDEF SSE_UNALIGNED}
    // unaligned SSE code
    function MatrixDeterminant(const M: TMatrix4x4) : Single; assembler; register;
    asm
      movups    xmm0, [eax+$20]              // xmm0 := M23 M22 M21 M20
      movups    xmm1, [eax+$30]              // xmm1 := M33 M32 M31 M30

      movaps    xmm2, xmm0
      movaps    xmm3, xmm1
      movaps    xmm4, xmm0
      movaps    xmm5, xmm1

      shufps    xmm0, xmm0, 11111110b        // xmm0 := M23 M23 M23 M22
      shufps    xmm1, xmm1, 10100101b        // xmm1 := M32 M32 M31 M31
      shufps    xmm2, xmm2, 10100101b        // xmm2 := M22 M22 M21 M21
      shufps    xmm3, xmm3, 11111110b        // xmm3 := M33 M33 M33 M32
      shufps    xmm4, xmm4, 01000000b        // xmm4 := M21 M20 M20 M20
      shufps    xmm5, xmm5, 01000000b        // xmm5 := M31 M30 M30 M30

      movaps    xmm6, xmm3
      movaps    xmm7, xmm1

      mulps     xmm3, xmm2                   // xmm3 := M22*M33 M22*M33 M21*M33 M21*M32
      mulps     xmm1, xmm0                   // xmm1 := M32*M23 M32*M23 M31*M23 M31*M22
      mulps     xmm6, xmm4                   // xmm6 := M21*M33 M20*M33 M20*M33 M20*M32
      mulps     xmm0, xmm5                   // xmm0 := M31*M23 M30*M23 M30*M23 M30*M22
      mulps     xmm4, xmm7                   // xmm4 := M21*M32 M20*M32 M20*M31 M20*M31
      mulps     xmm5, xmm2                   // xmm5 := M31*M22 M30*M22 M30*M21 M30*M21

      subps     xmm3, xmm1                   // xmm3 := A       D       G       J
      subps     xmm6, xmm0                   // xmm6 := B       E       H       K
      subps     xmm4, xmm5                   // xmm4 := C       F       I       L

      movups    xmm1, [eax+$10]              // xmm1 := M13 M12 M11 M10

      movaps    xmm2, xmm1
      movaps    xmm0, xmm1

      shufps    xmm0, xmm0, 01000000b        // xmm0 := M11 M10 M10 M10
      shufps    xmm1, xmm1, 10100101b        // xmm1 := M12 M12 M11 M11
      shufps    xmm2, xmm2, 11111110b        // xmm2 := M13 M13 M13 M12

      mulps     xmm0, xmm3                   // xmm0 := M11*A M10*D M10*G M10*J
      mulps     xmm1, xmm6                   // xmm1 := M12*B M12*E M11*H M11*K
      mulps     xmm2, xmm4                   // xmm2 := M13*C M13*F M13*I M12*L

      subps     xmm0, xmm1                   // xmm0 := M11*A-M12*B M10*D-M12*E M10*G-M11*H M10*J-M11*K
      addps     xmm0, xmm2                   // xmm0 := M11*A-M12*B+M13*C M10*D-M12*E+M13*F M10*G-M11*H+M13*I M10*J-M11*K+M12*L

      movups    xmm1, [eax]                  // xmm1 := M03 M02 M01 M00
      shufps    xmm1, xmm1, 00011011b        // xmm1 := M00 M01 M02 M03

      mulps     xmm0, xmm1                   // xmm0 := M00*(M11*A-M12*B+M13*C) M01*(M10*D-M12*E+M13*F) M02*(M10*G-M11*H+M13*I) M03*(M10*J-M11*K+M12*L)

      {$IFDEF SSE3_OPCODES}
        movss   xmm2, [signbit]
        shufps  xmm2, xmm2, 11001100b        // + - + -
        xorps   xmm0, xmm2                   // xmm0 :=  M -N  O   -P

        db $F2, $0F, $7C, $C0                // haddps xmm0, xmm0       xmm0 :=  ?  ?  M-N  O-P
        db $F2, $0F, $7C, $C0                // haddps xmm0, xmm0       xmm0 :=  ?  ?  ?    M-N+O-P

        movss     [Result], xmm0
      {$ELSE}
        movaps  xmm1, xmm0
        movaps  xmm2, xmm0
        movaps  xmm3, xmm0

        shufps  xmm1, xmm1, 01010101b        // xmm1 := ? ? ? O
        shufps  xmm2, xmm2, 10101010b        // xmm2 := ? ? ? N
        shufps  xmm3, xmm3, 11111111b        // xmm3 := ? ? ? M

        subss   xmm3, xmm2                   // xmm3 := ? ? ? M-N
        addss   xmm3, xmm1                   // xmm3 := ? ? ? M-N+O
        subss   xmm3, xmm0                   // xmm3 := ? ? ? M-N+O-P

        movss   [Result], xmm3
      {$ENDIF}
    end;
  {$ELSE}
    // SSE aligned code
    function MatrixDeterminant(const M: TMatrix4x4) : Single; assembler; register;
    asm
      movaps    xmm0, [eax+$20]              // xmm0 := M23 M22 M21 M20
      movaps    xmm1, [eax+$30]              // xmm1 := M33 M32 M31 M30

      movaps    xmm2, xmm0
      movaps    xmm3, xmm1
      movaps    xmm4, xmm0
      movaps    xmm5, xmm1

      shufps    xmm0, xmm0, 11111110b        // xmm0 := M23 M23 M23 M22
      shufps    xmm1, xmm1, 10100101b        // xmm1 := M32 M32 M31 M31
      shufps    xmm2, xmm2, 10100101b        // xmm2 := M22 M22 M21 M21
      shufps    xmm3, xmm3, 11111110b        // xmm3 := M33 M33 M33 M32
      shufps    xmm4, xmm4, 01000000b        // xmm4 := M21 M20 M20 M20
      shufps    xmm5, xmm5, 01000000b        // xmm5 := M31 M30 M30 M30

      movaps    xmm6, xmm3
      movaps    xmm7, xmm1

      mulps     xmm3, xmm2                   // xmm3 := M22*M33 M22*M33 M21*M33 M21*M32
      mulps     xmm1, xmm0                   // xmm1 := M32*M23 M32*M23 M31*M23 M31*M22
      mulps     xmm6, xmm4                   // xmm6 := M21*M33 M20*M33 M20*M33 M20*M32
      mulps     xmm0, xmm5                   // xmm0 := M31*M23 M30*M23 M30*M23 M30*M22
      mulps     xmm4, xmm7                   // xmm4 := M21*M32 M20*M32 M20*M31 M20*M31
      mulps     xmm5, xmm2                   // xmm5 := M31*M22 M30*M22 M30*M21 M30*M21

      subps     xmm3, xmm1                   // xmm3 := A       D       G       J
      subps     xmm6, xmm0                   // xmm6 := B       E       H       K
      subps     xmm4, xmm5                   // xmm4 := C       F       I       L

      movaps    xmm1, [eax+$10]              // xmm1 := M13 M12 M11 M10

      movaps    xmm2, xmm1
      movaps    xmm0, xmm1

      shufps    xmm0, xmm0, 01000000b        // xmm0 := M11 M10 M10 M10
      shufps    xmm1, xmm1, 10100101b        // xmm1 := M12 M12 M11 M11
      shufps    xmm2, xmm2, 11111110b        // xmm2 := M13 M13 M13 M12

      mulps     xmm0, xmm3                   // xmm0 := M11*A M10*D M10*G M10*J
      mulps     xmm1, xmm6                   // xmm1 := M12*B M12*E M11*H M11*K
      mulps     xmm2, xmm4                   // xmm2 := M13*C M13*F M13*I M12*L

      subps     xmm0, xmm1                   // xmm0 := M11*A-M12*B M10*D-M12*E M10*G-M11*H M10*J-M11*K
      addps     xmm0, xmm2                   // xmm0 := M11*A-M12*B+M13*C M10*D-M12*E+M13*F M10*G-M11*H+M13*I M10*J-M11*K+M12*L

      movaps    xmm1, [eax]                  // xmm1 := M03 M02 M01 M00
      shufps    xmm1, xmm1, 00011011b        // xmm1 := M00 M01 M02 M03

      mulps     xmm0, xmm1                   // xmm0 := M00*(M11*A-M12*B+M13*C) M01*(M10*D-M12*E+M13*F) M02*(M10*G-M11*H+M13*I) M03*(M10*J-M11*K+M12*L)

      {$IFDEF SSE3_OPCODES}
        movss   xmm2, [signbit]
        shufps  xmm2, xmm2, 11001100b        // + - + -
        xorps   xmm0, xmm2                   // xmm0 :=  M -N  O   -P

        db $F2, $0F, $7C, $C0                // haddps xmm0, xmm0       xmm0 :=  ?  ?  M-N  O-P
        db $F2, $0F, $7C, $C0                // haddps xmm0, xmm0       xmm0 :=  ?  ?  ?    M-N+O-P

        movss     [Result], xmm0
      {$ELSE}
        movaps  xmm1, xmm0
        movaps  xmm2, xmm0
        movaps  xmm3, xmm0

        shufps  xmm1, xmm1, 01010101b        // xmm1 := ? ? ? O
        shufps  xmm2, xmm2, 10101010b        // xmm2 := ? ? ? N
        shufps  xmm3, xmm3, 11111111b        // xmm3 := ? ? ? M

        subss   xmm3, xmm2                   // xmm3 := ? ? ? M-N
        addss   xmm3, xmm1                   // xmm3 := ? ? ? M-N+O
        subss   xmm3, xmm0                   // xmm3 := ? ? ? M-N+O-P

        movss   [Result], xmm3
      {$ENDIF}
    end;
  {$ENDIF}
{$ELSE}
  function MatrixDeterminant(M: TMatrix4x4) : Single;
  begin
    Result := M[0,0] * MatrixDetInternal(M[1,1], M[2,1], M[3,1], M[1,2], M[2,2], M[3,2], M[1,3], M[2,3], M[3,3]) -
              M[0,1] * MatrixDetInternal(M[1,0], M[2,0], M[3,0], M[1,2], M[2,2], M[3,2], M[1,3], M[2,3], M[3,3]) +
              M[0,2] * MatrixDetInternal(M[1,0], M[2,0], M[3,0], M[1,1], M[2,1], M[3,1], M[1,3], M[2,3], M[3,3]) -
              M[0,3] * MatrixDetInternal(M[1,0], M[2,0], M[3,0], M[1,1], M[2,1], M[3,1], M[1,2], M[2,2], M[3,2]);
  end;
{$ENDIF}

// de 3x3 variant
function Matrix3x3Determinant(M: TMatrix4x4) : Single;
begin
  Result := (M[0,0]*M[1,1]*M[2,2] + M[0,1]*M[1,2]*M[2,0] + M[0,2]*M[1,0]*M[2,1]) -
            (M[0,2]*M[1,1]*M[2,0] + M[0,1]*M[1,0]*M[2,2] + M[0,0]*M[1,2]*M[2,1]);
end;
//------------------------------------------------------------------------------


function CofactorMatrix(M: TMatrix4x4) : TMatrix4x4;
var c,r, c2,r2, cd,rd: integer;
    f: Single;
    M2: TMatrix4x4;
begin
  for r:=0 to 3 do begin
    for c:=0 to 3 do begin
      f := Power(-1,r+c);
      // rij[r] & kolom[c] verwijderen
      rd := 0;
      for r2:=0 to 3 do begin
        if r2=r then continue;
        cd := 0;
        for c2:=0 to 3 do begin
          if c2=c then continue;
          M2[rd,cd] := M[r2,c2];
          Inc(cd);
        end;
        Inc(rd);
      end;
      //
      Result[r,c] := f * Matrix3x3Determinant(M2);
    end;
  end;
end;


function MatrixInverse(M: TMatrix4x4) : TMatrix4x4;
var M2: TMatrix4x4;
    det: Single;
    c,r: integer;
begin
  M2 := CofactorMatrix(M);
  // adjoint matrix volgt hieruit eenvoudig:
  TransposeMatrix(M2);
  // determinant
  det := Matrix3x3Determinant(M);
  //
  if det<>0 then begin
    //ScaleMatrix(M2, 1/det);
    //Result := M2;
    for r:=0 to 3 do begin
      for c:=0 to 3 do begin
        Result[r,c] := M2[r,c] / det;
      end;
    end;
  end else
    Result := IdentityMatrix4x4;
end;



procedure MatrixAdjoint(var M: TMatrix4x4);
var a1, a2, a3, a4,
    b1, b2, b3, b4,
    c1, c2, c3, c4,
    d1, d2, d3, d4: Single;
begin
  a1 := M[0,0];    b1 := M[0,1];  c1 := M[0,2];    d1 := M[0,3];
  a2 := M[1,0];    b2 := M[1,1];  c2 := M[1,2];    d2 := M[1,3];
  a3 := M[2,0];    b3 := M[2,1];  c3 := M[2,2];    d3 := M[2,3];
  a4 := M[3,0];    b4 := M[3,1];  c4 := M[3,2];    d4 := M[3,3];
{
  function MatrixDetInternal(a1, a2, a3, b1, b2, b3, c1, c2, c3: Single): Single;
  begin
    Result := a1 * (b2 * c3 - b3 * c2) -
              b1 * (a2 * c3 - a3 * c2) +
              c1 * (a2 * b3 - a3 * b2);
  end;

  R[0,0] := M11*(M22*M33-M32*M23)  -  M12*(M21*M33-M31*M23)  +  M13*(M21*M32-M31*M22);
  R[1,0] := M10*(*-*)  -  *(*-*)  +  *(*-*)
  R[2,0] := M10*(*-*)  -  *(*-*)  +  *(*-*)
  R[3,0] := M10*(*-*)  -  *(*-*)  +  *(*-*)

  R[0,1] := M01*(*-*)  -  *(*-*)  +  *(*-*)
  R[1,1] := M00*(*-*)  -  *(*-*)  +  *(*-*)
  R[2,1] := M00*(*-*)  -  *(*-*)  +  *(*-*)
  R[3,1] := M00*(*-*)  -  *(*-*)  +  *(*-*)

  R[0,2] := M01*(*-*)  -  *(*-*)  +  *(*-*)
  R[1,2] := M00*(*-*)  -  *(*-*)  +  *(*-*)
  R[2,2] := M00*(*-*)  -  *(*-*)  +  *(*-*)
  R[3,2] := M00*(*-*)  -  *(*-*)  +  *(*-*)

  R[0,3] := M01*(*-*)  -  *(*-*)  +  *(*-*)
  R[1,3] := M00*(*-*)  -  *(*-*)  +  *(*-*)
  R[2,3] := M00*(*-*)  -  *(*-*)  +  *(*-*)
  R[3,3] := M00*(*-*)  -  *(*-*)  +  *(*-*)
}
  // row column labeling reversed since we transpose rows & columns
  M[0,0] :=  MatrixDetInternal(b2, b3, b4, c2, c3, c4, d2, d3, d4);   // M11,M21,M31,M12,M22,M32,M13,M23,M33
  M[1,0] := -MatrixDetInternal(a2, a3, a4, c2, c3, c4, d2, d3, d4);   // M10,M20,M30,M12,M22,M32,M13,M23,M33
  M[2,0] :=  MatrixDetInternal(a2, a3, a4, b2, b3, b4, d2, d3, d4);   // M10,M20,M30,M11,M21,M31,M13,M23,M33
  M[3,0] := -MatrixDetInternal(a2, a3, a4, b2, b3, b4, c2, c3, c4);   // M10,M20,M30,M11,M21,M31,M12,M22,M32

  M[0,1] := -MatrixDetInternal(b1, b3, b4, c1, c3, c4, d1, d3, d4);   // M01,M21,M31,M02,M22,M32,M03,M23,M33
  M[1,1] :=  MatrixDetInternal(a1, a3, a4, c1, c3, c4, d1, d3, d4);   // M00,M20,M30,M02,M22,M32,M03,M23,M33
  M[2,1] := -MatrixDetInternal(a1, a3, a4, b1, b3, b4, d1, d3, d4);   // M00,M20,M30,M01,M21,M31,M03,M23,M33
  M[3,1] :=  MatrixDetInternal(a1, a3, a4, b1, b3, b4, c1, c3, c4);   // M00,M20,M30,M01,M21,M31,M02,M22,M32

  M[0,2] :=  MatrixDetInternal(b1, b2, b4, c1, c2, c4, d1, d2, d4);   // M01,M11,M31,M02,M12,M32,M03,M13,M33
  M[1,2] := -MatrixDetInternal(a1, a2, a4, c1, c2, c4, d1, d2, d4);   // M00,M10,M30,M02,M12,M32,M03,M13,M33
  M[2,2] :=  MatrixDetInternal(a1, a2, a4, b1, b2, b4, d1, d2, d4);   // M00,M10,M30,M01,M11,M31,M03,M13,M33
  M[3,2] := -MatrixDetInternal(a1, a2, a4, b1, b2, b4, c1, c2, c4);   // M00,M10,M30,M01,M11,M31,M02,M12,M32

  M[0,3] := -MatrixDetInternal(b1, b2, b3, c1, c2, c3, d1, d2, d3);   // M01,M11,M21,M02,M12,M22,M03,M13,M23
  M[1,3] :=  MatrixDetInternal(a1, a2, a3, c1, c2, c3, d1, d2, d3);   // M00,M10,M20,M02,M12,M22,M03,M13,M23
  M[2,3] := -MatrixDetInternal(a1, a2, a3, b1, b2, b3, d1, d2, d3);   // M00,M10,M20,M01,M11,M31,M03,M13,M23
  M[3,3] :=  MatrixDetInternal(a1, a2, a3, b1, b2, b3, c1, c2, c3);   // M00,M10,M20,M01,M11,M31,M02,M12,M22
end;

procedure InverseMatrix(var M: TMatrix4x4);
var Det: Single;
begin
  Det := MatrixDeterminant(M);
//Det := Matrix3x3Determinant(M);     //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  if Abs(Det) < EPSILON then
    M := IdentityMatrix4x4
  else begin
    MatrixAdjoint(M);
    ScaleMatrix(M, 1.0/Det);
  end;
end;



//=== quaternion berekeningen ==================================================
// een quaternion -> rotatiematrix
procedure QuaternionToMatrix(var Q:TQuaternion; var M:TMatrix4x4);
var xx,xy,xz,xw, yy,yz,yw, zz,zw: single;
begin
  xx := Q.X * Q.X;
  xy := Q.X * Q.Y;
  xz := Q.X * Q.Z;
  xw := Q.X * Q.W;

  yy := Q.Y * Q.Y;
  yz := Q.Y * Q.Z;
  yw := Q.Y * Q.W;

  zz := Q.Z * Q.Z;
  zw := Q.Z * Q.W;

  M[0,0] := 1.0 - 2.0*(yy+zz);
  M[0,1] := 2.0*(xy-zw);
  M[0,2] := 2.0*(xz+yw);
  M[0,3] := 0.0;

  M[1,0] := 2.0*(xy+zw);
  M[1,1] := 1.0 - 2.0*(xx+zz);
  M[1,2] := 2.0*(yz-xw);
  M[1,3] := 0.0;

  M[2,0] := 2.0*(xz-yw);
  M[2,1] := 2.0*(yz+xw);
  M[2,2] := 1.0 - 2.0*(xx+yy);
  M[2,3] := 0.0;

  M[3,0] := 0.0;
  M[3,1] := 0.0;
  M[3,2] := 0.0;
  M[3,3] := 1.0;
end;

// een rotatiematrix -> quaternion
procedure MatrixToQuaternion(var M:TMatrix4x4; var Q:TQuaternion);
var trace,s: single;
    largest: integer;
begin
  trace := M[0,0] + M[1,1] + M[2,2] + M[3,3];
  if trace > 0 then begin
    s := 0.5 * Sqrt(trace);
    Q.W := 0.25 / s;
    Q.X := (M[2,1] - M[1,2]) * s;
    Q.Y := (M[0,2] - M[2,0]) * s;
    Q.Z := (M[1,0] - M[0,1]) * s;
  end else begin
    largest := 0;
    if M[1,1]>M[0,0] then largest := 1;
    if M[2,2]>M[1,1] then largest := 2;
    case largest of
      0: begin
           s := Sqrt(1.0 + M[0,0] - M[1,1] - M[2,2]) * 2.0;
           Q.X := 0.5 / s;
           Q.Y := (M[0,1] + M[1,0]) / s;
           Q.Z := (M[0,2] + M[2,0]) / s;
           Q.W := (M[1,2] + M[2,1]) / s;
         end;
      1: begin
           s := Sqrt(1.0 + M[1,1] - M[0,0] - M[2,2]) * 2.0;
           Q.X := (M[0,1] + M[1,0]) / s;
           Q.Y := 0.5 / s;
           Q.Z := (M[1,2] + M[2,1]) / s;
           Q.W := (M[0,2] + M[2,0]) / s;
         end;
      2: begin
           s := Sqrt(1.0 + M[2,2] - M[0,0] - M[1,1]) * 2.0;
           Q.X := (M[0,2] + M[2,0]) / s;
           Q.Y := (M[1,2] + M[2,1]) / s;
           Q.Z := 0.5 / s;
           Q.W := (M[0,1] + M[1,0]) / s;
         end;
    end;
  end;
end;


// de lengte van een quaternion
function QuaternionMagnitude(Q:TQuaternion) : single;
begin
  Result := Sqrt(Q.W*Q.W + Q.X*Q.X + Q.Y*Q.Y + Q.Z*Q.Z);
end;

procedure QuaternionNormalize(var Q:TQuaternion);
var Len: single;
begin
  Len := QuaternionMagnitude(Q);
  if Len=0 then Exit;
  Q.X := Q.X / Len;
  Q.Y := Q.Y / Len;
  Q.Z := Q.Z / Len;
  Q.W := Q.W / Len;
end;

procedure QuaternionGetRotationAxisAndAngle(Q:TQuaternion; var Axis:TVector; var Angle:Single);
var QR: TQuaternion;
    C,S,SA: single;
begin
  QR := Q;
  QuaternionNormalize(QR);
  C := QR.W;
  Angle := ArcCos(C) * constRadToDeg;
  S := Sqrt(1.0 - C*C);
  if Abs(S)<0.0005 then S:=1;
  Axis.X := QR.X / S;
  Axis.Y := QR.Y / S;
  Axis.Z := QR.Z / S;
end;

procedure QuaternionRotationAxisAndAngleToQuaternion(Axis:TVector; Angle:Single; var Q:TQuaternion);
var C,S: single;
begin
  C := Cos(Angle*constDegToRad / 2);
  S := Sin(Angle*constDegToRad / 2);
  Q.X := Axis.X * S;
  Q.Y := Axis.Y * S;
  Q.Z := Axis.Z * S;
  Q.W := C;
  QuaternionNormalize(Q);
end;

//=== Planes berekeningen ======================================================

// Bereken de normaal op het vlak uit 3 opgegeven punten
function PlaneNormal(V1,V2,V3: TVector) : TVector;
var V,S1,S2: TVector;
begin
  S1 := SubVector(V1,V2);
  S2 := SubVector(V3,V2);
  // versie verschil in 3DS....
{ if (version3DS < 3) then V := CrossProduct(S1, S2) else}
                           V := CrossProduct(S2, S1);
  Result := UnitVector(V);
end;

// resulteer de afstand van het vlak tot de oorsprong
function PlaneDistance(Normal, PointOnPlane: TVector) : Single;
var Len: single;
begin
  // Ax + By + Cz + d = 0
  // d = -(Ax + By + Cz)
  Result := -DotProduct(Normal, PointOnPlane);
{  Len := VectorLength(Normal);
  if (Len<>0) and (Len<>1) then
    Result := Result / Len;}
end;

// resulteer de origin van een plane
function PlaneOrigin(Normal: TVector; DistanceToOrigin: Single) : TVector;
begin
  Result := ScaleVector(Normal, DistanceToOrigin);
end;

// een lijn snijden met een vlak, evt. snijpunt in S terug
{function LinePlaneIntersectionPoint(const Line: TLine; const Plane: TPlane; var S: TVector) : boolean;}
function LinePlaneIntersectionPoint(const L0,L1, P0,P1,P2: TVector; var S: TVector) : boolean;
var LineDir, PNormal, V: TVector;
    d, si: single;
begin
  Result := false;

  LineDir := UnitVector(SubVector(L1,L0));
  PNormal := PlaneNormal(P0,P1,P2);
  // evenwijdig aan elkaar??
  d := DotProduct(PNormal, LineDir);
  if d=0 then Exit;

  Result := true;
//  V := SubVector(L0,P0);                        // een punt op de lijn  -  een punt op het vlak
//  si := -DotProduct(PNormal,V) / d;             // -n.v/n.u
  V := SubVector(P0,L0);                          // een punt op het vlak  -  een punt op de lijn
  si := DotProduct(PNormal,V) / d;                // n.v/n.u
  S := AddVector(L0, ScaleVector(LineDir, si));   // het snijpunt
end;

function LinePlaneIntersectionPoint(const LineOrigin,LineDirection, PlaneNormal,PointOnPlane: TVector; var S: TVector) : boolean; overload;
var d, si: single;
    V: TVector;
begin
  Result := false;
  d := DotProduct(PlaneNormal, LineDirection);
  if d=0 then Exit;
  Result := true;
  V := SubVector(PointOnPlane,LineOrigin);
  si := DotProduct(PlaneNormal, V) / d;
  S := AddVector(LineOrigin, ScaleVector(LineDirection, si));
end;

// een lijn snijden met een box, evt. snijpunt in S terug
function LineBoxIntersectionPoint(const L0,L1: TVector; const BoundingBox: TBoundingBox; var S: TVector) : boolean;
var V1,V2,V3,V4,V5,V6,V7,V8: TVector;
  //--
  function OutOfBounds(const P: TVector) : boolean;
  begin
    Result := ((P.X<BoundingBox.Min.X) or (P.X>BoundingBox.Max.X) or
               (P.Y<BoundingBox.Min.Y) or (P.Y>BoundingBox.Max.Y) or
               (P.Z<BoundingBox.Min.Z) or (P.Z>BoundingBox.Max.Z));
  end;
  //--
begin
  // alle 8 punten van de (AA)boundingbox//       V8______V2
  V1 := BoundingBox.Min;                 //       /|    /|
  V2 := BoundingBox.Max;                 //    V5/_|___/ |
  V3 := Vector(V2.X,V1.Y,V1.Z);          //      | | V4| |
  V4 := Vector(V2.X,V2.Y,V1.Z);          //      | V6__|_|V7
  V5 := Vector(V1.X,V2.Y,V1.Z);          //      | /   | /
  V6 := Vector(V1.X,V1.Y,V2.Z);          //      |/____|/
  V7 := Vector(V2.X,V1.Y,V2.Z);          //     V1     V3
  V8 := Vector(V1.X,V2.Y,V2.Z);          //

  Result := true;
  // 3 vlakken aan de bb.min kant
  if LinePlaneIntersectionPoint(L0,L1, V5,V1,V3, S) then //er is een snijpunt
    if OutOfBounds(S) then
      if LinePlaneIntersectionPoint(L0,L1, V3,V1,V6, S) then
        if OutOfBounds(S) then
          if LinePlaneIntersectionPoint(L0,L1, V6,V1,V5, S) then
            if OutOfBounds(S) then
              // 3 vlakken aan de bb.max kant
              if LinePlaneIntersectionPoint(L0,L1, V8,V2,V7, S) then
                if OutOfBounds(S) then
                  if LinePlaneIntersectionPoint(L0,L1, V4,V2,V8, S) then
                    if OutOfBounds(S) then
                      if LinePlaneIntersectionPoint(L0,L1, V7,V2,V4, S) then
                        if OutOfBounds(S) then
                          Result := false;
end;

function LineBoxIntersectionPoint2(const LineOrigin,LineDirection: TVector; const BoundingBox: TBoundingBox; var S: TVector) : boolean;
var V1,V2,V3,V4,V5,V6,V7,V8: TVector;
  //--
  function OutOfBounds(const P: TVector) : boolean;
  begin
    Result := ((P.X<BoundingBox.Min.X) or (P.X>BoundingBox.Max.X) or
               (P.Y<BoundingBox.Min.Y) or (P.Y>BoundingBox.Max.Y) or
               (P.Z<BoundingBox.Min.Z) or (P.Z>BoundingBox.Max.Z));
  end;
  //--
begin
  // alle 8 punten van de (AA)boundingbox//       V8______V2
  V1 := BoundingBox.Min;                 //       /|    /|
  V2 := BoundingBox.Max;                 //    V5/_|___/ |
  V3 := Vector(V2.X,V1.Y,V1.Z);          //      | | V4| |
  V4 := Vector(V2.X,V2.Y,V1.Z);          //      | V6__|_|V7
  V5 := Vector(V1.X,V2.Y,V1.Z);          //      | /   | /
  V6 := Vector(V1.X,V1.Y,V2.Z);          //      |/____|/
  V7 := Vector(V2.X,V1.Y,V2.Z);          //     V1     V3
  V8 := Vector(V1.X,V2.Y,V2.Z);          //

  Result := true;
  // 3 vlakken aan de bb.min kant
  if LinePlaneIntersectionPoint(LineOrigin,LineDirection, NegativeZAxisVector,V1, S) then //er is een snijpunt
    if OutOfBounds(S) then
      if LinePlaneIntersectionPoint(LineOrigin,LineDirection, NegativeYAxisVector,V1, S) then
        if OutOfBounds(S) then
          if LinePlaneIntersectionPoint(LineOrigin,LineDirection, NegativeXAxisVector,V1, S) then
            if OutOfBounds(S) then
              // 3 vlakken aan de bb.max kant
              if LinePlaneIntersectionPoint(LineOrigin,LineDirection, ZAxisVector,V2, S) then
                if OutOfBounds(S) then
                  if LinePlaneIntersectionPoint(LineOrigin,LineDirection, YAxisVector,V2, S) then
                    if OutOfBounds(S) then
                      if LinePlaneIntersectionPoint(LineOrigin,LineDirection, XAxisVector,V2, S) then
                        if OutOfBounds(S) then
                          Result := false;
end;

// snijpunt van 3 planes bepalen    (de vector over de lijn van snijden)
function PlanesIntersectionPoint(P1,P2,P3: TPlane; var S: TVector) : boolean;
var Determinant: Double;
    M: TMatrix4x4;
begin
(*
  M[0,0] := P1.Normal.X;    M[0,1] := P1.Normal.Y;    M[0,2] := P1.Normal.Z;    M[0,3] := -P1.d;
  M[1,0] := P2.Normal.X;    M[1,1] := P2.Normal.Y;    M[1,2] := P2.Normal.Z;    M[1,3] := -P2.d;
  M[2,0] := P3.Normal.X;    M[2,1] := P3.Normal.Y;    M[2,2] := P3.Normal.Z;    M[2,3] := -P3.d;
  M[3,0] := 0.0;            M[3,1] := 0.0;            M[3,2] := 0.0;            M[3,3] := 1.0;
*)
  M := Matrix4x4(P1.Normal.X, P1.Normal.Y, P1.Normal.Z, -P1.d,
                 P2.Normal.X, P2.Normal.Y, P2.Normal.Z, -P2.d,
                 P3.Normal.X, P3.Normal.Y, P3.Normal.Z, -P3.d,
                 0.0,         0.0,         0.0,         1.0);

  Result := false;
  Determinant := MatrixDeterminant(M);
  if abs(Determinant) < EPSILON then Exit;

  Result := true;
  InverseMatrix(M);
  // de 4e kolom bevat het snijpunt.
  S.X := M[0,3];
  S.Y := M[1,3];
  S.Z := M[2,3];
end;

// Een punt V projecteren op het vlak gedefinieerd door een normaal & een punt op het vlak
function ProjectPointToPlane(V, PlaneNormal, PointOnPlane: TVector) : TVector;
var proj: TVector;
    D: Single;
begin
  D := DotProduct(SubVector(PointOnPlane,V), PlaneNormal);
  proj := ScaleVector(PlaneNormal, D);
  Result := AddVector(V, proj);
end;

function ReflectVectorOnPlane(const Direction, PlaneNormal: TVector): TVector;
var V,N,S: TVector;
    C: single;
begin
  //        PlaneNormal
  //        ·
  //      S |  N+S
  //   ·----+----·
  //    \   |   /
  //   V \ N|  / Result
  //      \ | /
  //   ____\|/__________
  //
  //
  // Een formule: Result = Direction - ( 2 * DotProduct(Direction,PlaneNormal) ) PlaneNormal
  //                       I – 2 * dot(N, I) * N
(*
  // methode 1:
  V := InverseVector(Direction);
  // de cosinus van de hoek tussen V & N berekenen (de lengte van N)
  C := DotProduct(PlaneNormal, V);
  // de PlaneNormal schalen
  N := ScaleVector(PlaneNormal, C);
  // bereken de vector S
  S := SubVector(N, V);
//  S := SubVector(V, N);
  // de reflectie-vector
  Result := AddVector(N, S);
*)

  // methode 2:
  C := 2.0 * DotProduct(Direction,PlaneNormal);
  N := ScaleVector(PlaneNormal, C);
  Result := SubVector(Direction, N);
end;



// Een billboard, altijd loodrecht op de LineOfSight van de camera.

// 3 punten erin, 3 punten als resultaat, maar dan naar de camera gericht
procedure BillBoard(const Position:TVector; var V1,V2,V3:TVector);
var Normal, Center, Vec,
    Vx,Vy: TVector;
begin
  Normal := PlaneNormal(V1,V2,V3);
  Center := AverageVector([V1,V2,V3]);
  // de lijn vlak-center naar camera-position
  Vec := UnitVector(SubVector(Position, Center));
  // de andere assen loodrecht op Vec
  Vx := UnitVector(CrossProduct(Vector(0,1,0), Vec));
  Vy := UnitVector(CrossProduct(Vx, Vec));
  // nu hebben we een basis (assenstelsel)
  // nu de 3 punten relatief aan dit nieuwe stelsel omrekenen..

  V1 := AddVector(AddVector( ScaleVector(Vx,DotProduct(Vx,V1)),
                             ScaleVector(Vy,DotProduct(Vy,V1)) ),
                             ScaleVector(Vec,DotProduct(Vec,V1)));
  V2 := AddVector(AddVector( ScaleVector(Vx,DotProduct(Vx,V2)),
                             ScaleVector(Vy,DotProduct(Vy,V2)) ),
                             ScaleVector(Vec,DotProduct(Vec,V2)));
  V3 := AddVector(AddVector( ScaleVector(Vx,DotProduct(Vx,V3)),
                             ScaleVector(Vy,DotProduct(Vy,V3)) ),
                             ScaleVector(Vec,DotProduct(Vec,V3)));
{
  V1 := AddVector(AddVector( ScaleVector(Vx,DotProduct(XAxisVector,V1)),
                             ScaleVector(Vy,DotProduct(YAxisVector,V1)) ),
                             ScaleVector(Vec,DotProduct(ZAxisVector,V1)));
  V2 := AddVector(AddVector( ScaleVector(Vx,DotProduct(XAxisVector,V2)),
                             ScaleVector(Vy,DotProduct(YAxisVector,V2)) ),
                             ScaleVector(Vec,DotProduct(ZAxisVector,V2)));
  V3 := AddVector(AddVector( ScaleVector(Vx,DotProduct(XAxisVector,V3)),
                             ScaleVector(Vy,DotProduct(YAxisVector,V3)) ),
                             ScaleVector(Vec,DotProduct(ZAxisVector,V3)));
}
end;

// "alleen" Size aanreiken, en 4 punten terug krijgen
procedure BillBoard(const Position,LineOfSight: TVector; const Size: Single; var V1,V2,V3,V4: TVector);
begin
  BillBoard(Position,LineOfSight,Size,Size,V1,V2,V3,V4);
end;

// "alleen" Size aanreiken, en 4 punten terug krijgen
procedure BillBoard(const Position,LineOfSight: TVector; const SizeX,SizeY: Single; var V1,V2,V3,V4: TVector); 
var Vx,Vy,nVx,nVy: TVector;
begin
  // de lijn loodrecht op de y-as en lineofsight..
  Vx := ScaleVector(UnitVector(CrossProduct(Vector(0,1,0), LineOfSight)), SizeX);
  // de lijn loodrecht op V en lineofsight..
  Vy := ScaleVector(UnitVector(CrossProduct(Vx, LineOfSight)), SizeY);
  //
  nVx := InverseVector(Vx);
  nVy := InverseVector(Vy);
  // de 4 punten van de face welke altijd naar de camera is gericht..
  V1 := AddVector(AddVector(Position, nVx), nVy);
  V2 := AddVector(AddVector(Position, Vx), nVy);
  V3 := AddVector(AddVector(Position, Vx), Vy);
  V4 := AddVector(AddVector(Position, nVx), Vy);
end;


//=== triangle berekeningen ====================================================
function TriangleIsCCW(const V1,V2,V3, Normal: TVector) : boolean;
var M: TMatrix4x4;
    P: TVector; // centrum van de triangle
begin
  // het punt bepalen van waaraf de triangle wordt bekeken
  P := AverageVector([V1,V2,V3]);
  P := AddVector(P, Normal);
  // matrix opstellen
  M := Matrix4x4(V1.X, V1.Y, V1.Z, 1,
                 V2.X, V2.Y, V2.Z, 1,
                 V3.X, V3.Y, V3.Z, 1,
                 P.X,  P.Y,  P.Z,  1);
  // determinant > 0  => CW
  // determinant < 0  => CCW
  // determinant == 0 => fout, normaal heeft lengte 0
  Result := (MatrixDeterminant(M) < 0);
end;


//=== circels en bollen berekeningen ===========================================

end.
