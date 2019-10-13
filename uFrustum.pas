unit uFrustum;
interface
uses u3DTypes;

const
  _planeLeft   = 0;
  _planeRight  = 1;
  _planeBottom = 2;
  _planeTop    = 3;
  _planeNear   = 4;
  _planeFar    = 5;


type
  // de 6 planes van het frustum: left/right/bottom/top/near/far
  TFrustumPlanes = array[_planeLeft.._planeFar] of TPlane;

  PFrustum = ^TFrustum;
  TFrustum = class(TObject)
  private
    Planes: TFrustumPlanes; // de box, opgemaakt uit de clip-planes van het frustum
  public
    // bereken de frustum-planes vanaf de huidige (OpenGL) camera-instellingen
    procedure Calculate_glFrustumPlanes;
    // bereken de frustum-planes vanaf de opgegeven camera-instellingen
    procedure Calculate_glFrustumPlanes_Lookat(CameraPosition,CameraTarget,CameraUpY: TVector);
    //
    function Get_glFrustumPlanes : TFrustumPlanes;
    function PointInside(const V: TVector) : boolean;
    function AABBInside(const BoundingBox: TBoundingBox): boolean; overload;  //Axis Aligned Bounding Box
    function AABBInside(const Origin: TVector; const BoundingBox: TBoundingBox): boolean; overload;
    function SphereInside(Sphere: TSphere): boolean;
  end;


implementation
uses OpenGL, uCalc;

procedure TFrustum.Calculate_glFrustumPlanes;
var M, P, CC: TMatrix4x4;
    C : array[0..15] of Single absolute CC;
    C0,C1,C2,C3: Single;
    Len, rLen: Single;
begin
  // OpenGL matrices opvragen              //     | 0  4  8  12 |
  glGetFloatv(GL_MODELVIEW_MATRIX, @M);    // M = | 1  5  9  13 |
  glGetFloatv(GL_PROJECTION_MATRIX, @P);   //     | 2  6  10 14 |
                                           //     | 3  7  11 15 |
  // in 1 matrix combineren
  CC := MultiplyMatrix(M,P);
(*
  // C.column0
  C[0]  := M[0]*P[0]  + M[1]*P[4]  + M[2]*P[8]   + M[3]*P[12];
  C[1]  := M[0]*P[1]  + M[1]*P[5]  + M[2]*P[9]   + M[3]*P[13];
  C[2]  := M[0]*P[2]  + M[1]*P[6]  + M[2]*P[10]  + M[3]*P[14];
  C[3]  := M[0]*P[3]  + M[1]*P[7]  + M[2]*P[11]  + M[3]*P[15];
  // C.column1
  C[4]  := M[4]*P[0]  + M[5]*P[4]  + M[6]*P[8]   + M[7]*P[12];
  C[5]  := M[4]*P[1]  + M[5]*P[5]  + M[6]*P[9]   + M[7]*P[13];
  C[6]  := M[4]*P[2]  + M[5]*P[6]  + M[6]*P[10]  + M[7]*P[14];
  C[7]  := M[4]*P[3]  + M[5]*P[7]  + M[6]*P[11]  + M[7]*P[15];
  // C.column2
  C[8]  := M[8]*P[0]  + M[9]*P[4]  + M[10]*P[8]  + M[11]*P[12];
  C[9]  := M[8]*P[1]  + M[9]*P[5]  + M[10]*P[9]  + M[11]*P[13];
  C[10] := M[8]*P[2]  + M[9]*P[6]  + M[10]*P[10] + M[11]*P[14];
  C[11] := M[8]*P[3]  + M[9]*P[7]  + M[10]*P[11] + M[11]*P[15];
  // C.column3
  C[12] := M[12]*P[0] + M[13]*P[4] + M[14]*P[8]  + M[15]*P[12];
  C[13] := M[12]*P[1] + M[13]*P[5] + M[14]*P[9]  + M[15]*P[13];
  C[14] := M[12]*P[2] + M[13]*P[6] + M[14]*P[10] + M[15]*P[14];
  C[15] := M[12]*P[3] + M[13]*P[7] + M[14]*P[11] + M[15]*P[15];
*)
  // left plane
  Planes[_planeLeft].Normal := Vector( C[3]+C[0], C[7]+C[4], C[11]+C[8] );
  Planes[_planeLeft].d := C[15]+C[12];

  // right plane
  Planes[_planeRight].Normal := Vector( C[3]-C[0], C[7]-C[4], C[11]-C[8] );
  Planes[_planeRight].d := C[15]-C[12];

  // bottom plane
  Planes[_planeBottom].Normal := Vector( C[3]+C[1], C[7]+C[5], C[11]+C[9] );
  Planes[_planeBottom].d := C[15]+C[13];

  // top plane
  Planes[_planeTop].Normal := Vector( C[3]-C[1], C[7]-C[5], C[11]-C[9] );
  Planes[_planeTop].d := C[15]-C[13];

  // near plane
  Planes[_planeNear].Normal := Vector( C[3]+C[2], C[7]+C[6], C[11]+C[10] );
  Planes[_planeNear].d := C[15]+C[14];

  // far plane
  Planes[_planeFar].Normal := Vector( C[3]-C[2], C[7]-C[6], C[11]-C[10] );
  Planes[_planeFar].d := C[15]-C[14];
end;


procedure TFrustum.Calculate_glFrustumPlanes_Lookat(CameraPosition, CameraTarget, CameraUpY: TVector);
begin
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix;
  glMatrixMode(GL_PROJECTION);
  glPushMatrix;

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  // plaats de camera
  gluLookAt(CameraPosition.X,CameraPosition.Y,CameraPosition.Z,
            CameraTarget.X,CameraTarget.Y,CameraTarget.Z,
            CameraUpY.X,CameraUpY.Y,CameraUpY.Z);
  // bereken de planes van het frustum (tbv. frustum culling)
  Calculate_glFrustumPlanes;

  glMatrixMode(GL_PROJECTION);
  glPopMatrix;
  glMatrixMode(GL_MODELVIEW);
  glPopMatrix;
end;


function TFrustum.Get_glFrustumPlanes : TFrustumPlanes;
begin
  Result := Planes;
end;



function TFrustum.PointInside(const V: TVector) : boolean;
var i: integer;
begin
  Result := false;
  for i:=_planeLeft to _planeFar do
    // als het punt achter een frustum-vlak ligt, dan zijn we al klaar..result==false
    if DotProduct(Planes[i].Normal, V) + Planes[i].d < 0 then Exit;
	Result := true;
end;

// gedeeltelijk inside?? dan resultaat = true
function TFrustum.AABBInside(const BoundingBox: TBoundingBox): boolean;
var bb: TBoundingBox;
    V1,V2,V3,V4,V5,V6,V7,V8: TVector;
    PlaneBB, Plane3: TPlane;
    S, S0,S1,SDir: TVector;
    i: integer;
begin
  // als er 1 punt van de boundingbox vóór een frustum-vlak ligt, dan zijn we al klaar..result==true
  Result := true;
  V1 := BoundingBox.Min;
  if PointInside(V1) then Exit;
  V2 := BoundingBox.Max;
  if PointInside(V2) then Exit;
  V3 := Vector(V2.X,V1.Y,V1.Z);
  if PointInside(V3) then Exit;
  V4 := Vector(V2.X,V2.Y,V1.Z);
  if PointInside(V4) then Exit;
  V5 := Vector(V1.X,V2.Y,V1.Z);
  if PointInside(V5) then Exit;
  V6 := Vector(V1.X,V1.Y,V2.Z);
  if PointInside(V6) then Exit;
  V7 := Vector(V2.X,V1.Y,V2.Z);
  if PointInside(V7) then Exit;
  V8 := Vector(V1.X,V2.Y,V2.Z);
  if PointInside(V8) then Exit;
  Result := false;
  // er is geen enkel hoekpunt van de box binnen het frustum,
  // controleer of een vlak van de box zichtbaar is in beeld (gedeeltelijk in frustum).
  //todo..
end;

function TFrustum.AABBInside(const Origin: TVector; const BoundingBox: TBoundingBox): boolean;
var bb: TBoundingBox;
    V1,V2,V3,V4,V5,V6,V7,V8: TVector;
begin
  bb.Min := AddVector(BoundingBox.Min, Origin);   //AABB op location van entity plaatsen
  bb.Max := AddVector(BoundingBox.Max, Origin);
  Result := AABBInside(bb);
end;


function TFrustum.SphereInside(Sphere: TSphere): boolean;
begin
(*
  Result := false;
  if Box[0][0]*Sphere.Origin.X + Box[0][1]*Sphere.Origin.Y + Box[0][2]*Sphere.Origin.Z + Box[0][3]  <= -Sphere.Radius then Exit;
  if Box[1][0]*Sphere.Origin.X + Box[1][1]*Sphere.Origin.Y + Box[1][2]*Sphere.Origin.Z + Box[1][3]  <= -Sphere.Radius then Exit;
  if Box[2][0]*Sphere.Origin.X + Box[2][1]*Sphere.Origin.Y + Box[2][2]*Sphere.Origin.Z + Box[2][3]  <= -Sphere.Radius then Exit;
  if Box[3][0]*Sphere.Origin.X + Box[3][1]*Sphere.Origin.Y + Box[3][2]*Sphere.Origin.Z + Box[3][3]  <= -Sphere.Radius then Exit;
  if Box[4][0]*Sphere.Origin.X + Box[4][1]*Sphere.Origin.Y + Box[4][2]*Sphere.Origin.Z + Box[4][3]  <= -Sphere.Radius then Exit;
  if Box[5][0]*Sphere.Origin.X + Box[5][1]*Sphere.Origin.Y + Box[5][2]*Sphere.Origin.Z + Box[5][3]  <= -Sphere.Radius then Exit;
  Result := true;
*)
end;



end.
