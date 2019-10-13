unit uCamera;
interface
uses u3DTypes;

const
  DefaultPosition : TVector = (X:0.0;Y:1.0;Z:0.0;);
  DefaultTarget   : TVector = (X:0.0;Y:1.0;Z:1.0;);
  DefaultUpY      : TVector = (X:0.0;Y:1.0;Z:0.0;);

  // minder gevoelig < 1 < gevoeliger
  DefaultSensitivityX = 0.1;
  DefaultSensitivityY = 0.5;

  // bewegings-snelheid van een zwevende camera
  DefaultCamSpeed = 100.0;
  // De standaard boudingbox afmetingen (van een game-character)
  DefaultBoundingBoxMin : TVector = (X:-12; Y:-56; Z:-12;);
  DefaultBoundingBoxMax : TVector = (X:12;  Y:8;   Z:12;);

  // BoundingBox
  bbMin     = 0;
  bbMax     = 1;

  DefaultSmoothAngle = 10.0; // graden per frame

type
  PCamera = ^TCamera;                  //Een pointer naar een TCamera
  TCamera = class(TObject)
            private
              Collide_: boolean;
              // interpolated cam movements
              Smooth: boolean; //interpoleren??
              SmoothPosition,
              SmoothTarget,
              SmoothUpY: TVector;
            public
              Position,              //het camera-oogpunt                  (de huidige camera-positie)
              Target,                //het punt waar de camera naar kijkt  (het huidige target)
              UpY: TVector;          //de vector voor de de richting om de bovenkant van de camera aan te duiden
              //
              SensitivityX,          //de gevoeligheid bij bewegingen
              SensitivityY: Single;
              // tbv collision detection
              SphereRadius: single;  //de bol-straal bij collision-detection
              BoundingBox: array[bbMin..bbMax] of TVector; // als VolumeType = ctBox  [Min,Max]
              //
              Speed: Single;        //de snelheid bij bewegingen van een zwevende camera
              //
              Floating: boolean;
              MouseControlled: boolean;  //true = camera besturen met de muis..
              // object
              constructor Create;
              destructor Destroy; override;

              //gebruik de opgegeven camera-instellingen
              procedure Use(aPosition,aTarget,aUpY: TVector); overload;
              procedure Use(aPosition,aTarget,aUpY: TVector; aSpeed: Single); overload;
              procedure Use(aPosition,aTarget,aUpY: TVector; aSpeed: Single; XSensitivity,YSensitivity: Single); overload;
              //gebruik de standaard camera-instellingen
              procedure Default;
              //de camera met de muis besturen
              procedure ToggleMouseControl;
              //botsingen
              procedure ToggleCollide;
              function GetCollide : boolean;
              procedure SetCollide(State: boolean);
              //
              procedure ToggleFloating;
              //de gevoeligheid bij bewegingen
              procedure SetSensitivity(XSensitivity,YSensitivity: Single);
              //de bol-straal bij botsingen
              procedure SetSphereRadius(Radius: Single);
              //snelheid bij bewegingen
              procedure SetSpeed(aSpeed: Single);
              //de positie (Eye)
              procedure SetPosition(P: TVector);
              procedure SetPositionY(Y: Single);
              // interpoleren van bewegingen
              procedure SetSmooth(Value: boolean);
              function GetSmooth: boolean;

              //de vector voor de richting waarin de camera kijkt
              function LineOfSight : TVector;

              //de camera draaien, camera-positie blijft gelijk
              procedure RotateLineOfSight(R: TVector);
              //de camera draaien, Center blijft gelijk
              procedure RotateAboutTarget(R: TVector);

              //de camera verplaatsen in een richting evenwijdig aan de kijkrichting
              procedure Move(Factor: Single);      //Factor<0 = achteruit, Factor>0 = vooruit
              //Herleid de positie van de camera na een Move.
              //(de verplaatsing wordt alleen uitgerekend, niet daadwerkelijk doorgevoerd)
              function NextMove_Position(Factor: Single) : TVector; overload;
              function NextMove_Position(FromPosition: TVector; Factor: Single) : TVector; overload;

              //de camera verplaatsen in een richting loodrecht op de kijkrichting
              procedure Strafe(Factor: Single);  //Factor<0 = links, Factor>0 = rechts
              //Herleid de positie van de camera na een Move.
              //(de verplaatsing wordt alleen uitgerekend, niet daadwerkelijk doorgevoerd)
              function NextStrafe_Position(Factor: Single) : TVector; overload;
              function NextStrafe_Position(FromPosition: TVector; Factor: Single) : TVector; overload;

              //de camera verplaatsen in een richting loodrecht op de kijkrichting
              procedure StrafeUpDown(Factor: Single);  //Factor<0 = links, Factor>0 = rechts
              //Herleid de positie van de camera na een Move.
              //(de verplaatsing wordt alleen uitgerekend, niet daadwerkelijk doorgevoerd)
              function NextStrafeUpDown_Position(Factor: Single) : TVector; overload;
              function NextStrafeUpDown_Position(FromPosition: TVector; Factor: Single) : TVector; overload;
            end;

{var Camera: TCamera;}

implementation
uses OpenGL, uCalc;


{ TCamera }
constructor TCamera.Create;
begin
  // Object initiëren
  inherited;
  // Data initialiseren
  Floating := true;
  MouseControlled := false;
  Collide_ := false;
  SphereRadius := 24.0;
  BoundingBox[bbMin] := DefaultBoundingBoxMin;
  BoundingBox[bbMax] := DefaultBoundingBoxMax;
  Default;
end;

destructor TCamera.Destroy;
begin
  // Data finaliseren

  // Object finaliseren
  inherited;
end;



procedure TCamera.Use(aPosition, aTarget, aUpY: TVector);
begin
  Position := aPosition;
  Target := aTarget;
  UpY := aUpY;
end;

procedure TCamera.Use(aPosition, aTarget, aUpY: TVector; aSpeed: Single);
begin
  Use(aPosition, aTarget, aUpY);
  Speed := aSpeed;
end;

procedure TCamera.Use(aPosition, aTarget, aUpY: TVector; aSpeed: Single; XSensitivity,YSensitivity: Single);
begin
  Use(aPosition, aTarget, aUpY, aSpeed);
  SensitivityX := XSensitivity;
  SensitivityY := YSensitivity;
end;

procedure TCamera.Default;
begin
  Use(DefaultPosition,DefaultTarget,DefaultUpY, DefaultCamSpeed, DefaultSensitivityX,DefaultSensitivityY);
end;

procedure TCamera.ToggleMouseControl;
begin
  MouseControlled := not MouseControlled;
end;

function TCamera.GetCollide: boolean;
begin
  Result := Collide_;
end;
procedure TCamera.SetCollide(State: boolean);
begin
  Collide_ := State;
end;
procedure TCamera.ToggleCollide;
begin
  Collide_ := not Collide_;
  Floating := (not Collide_);
end;

procedure TCamera.ToggleFloating;
begin
  Floating := not Floating;
end;


procedure TCamera.SetSensitivity(XSensitivity, YSensitivity: Single);
begin
  SensitivityX := XSensitivity;
  SensitivityY := YSensitivity;
end;

procedure TCamera.SetSphereRadius(Radius: Single);
begin
  SphereRadius := Radius;
end;

procedure TCamera.SetSpeed(aSpeed: Single);
begin
  Speed := aSpeed;
end;

procedure TCamera.SetPosition(P: TVector);
var LOS: TVector;
begin
  // met behoud van LineOfSight
  LOS := LineOfSight;
  Position := P;
  Target := AddVector(Position, LOS);
end;

procedure TCamera.SetPositionY(Y: Single);
var LOS: TVector;
begin
  // met behoud van LineOfSight
  LOS := LineOfSight;
  Position.Y := Y;
  Target := AddVector(Position, LOS);
end;


function TCamera.GetSmooth: boolean;
begin
  Result := Smooth;
end;

procedure TCamera.SetSmooth(Value: boolean);
begin
  Smooth := Value;
end;




function TCamera.LineOfSight : TVector;
begin
  Result := UnitVector(SubVector(Target, Position));
end;

procedure TCamera.RotateLineOfSight(R: TVector);
begin
  // transformatie: transleer -Position, roteer R, transleer Position
  Target := AddVector(Rotate(SubVector(Target,Position), Vector(0,0,0), R), Position);
end;

procedure TCamera.RotateAboutTarget(R: TVector);
begin
  // transformatie: transleer -LookAt, roteer R, transleer LookAt
  Position := AddVector(Rotate(SubVector(Position,Target), Vector(0,0,0), R), Target);
end;



procedure TCamera.Move(Factor: Single);
var V,LOS: TVector;
begin
  LOS := LineOfSight;
  if Floating then V := LOS                       // de camera zweeft..
              else V := Vector(LOS.X, 0, LOS.Z);  // de camera-positie kan niet in Y-richting omhoog worden gestuurd..
  V := ScaleVector(V, Factor);
  Position := AddVector(Position, V);
  Target := AddVector(Position, LOS);  //Target := AddVector(Target, V);
end;

function TCamera.NextMove_Position(Factor: Single): TVector;
var V,LOS: TVector;
begin
  LOS := LineOfSight;
  if Floating then V := LOS                       // de camera zweeft..
              else V := Vector(LOS.X, 0, LOS.Z);  // de camera-positie kan niet in Y-richting omhoog worden gestuurd..
  V := ScaleVector(V, Factor);
  Result := AddVector(Position, V);
end;

function TCamera.NextMove_Position(FromPosition: TVector; Factor: Single): TVector;
var V,LOS: TVector;
begin
  LOS := LineOfSight;
  if Floating then V := LOS                       // de camera zweeft..
              else V := Vector(LOS.X, 0, LOS.Z);  // de camera-positie kan niet in Y-richting omhoog worden gestuurd..
  V := ScaleVector(V, Factor);
  Result := AddVector(FromPosition, V);
end;



procedure TCamera.Strafe(Factor: Single);
var V: TVector;
begin
  V := CrossProduct(UpY, LineOfSight);
  V := ScaleVector(V, Factor);
  Position := AddVector(Position, V);
  Target := AddVector(Target, V);
end;

function TCamera.NextStrafe_Position(Factor: Single): TVector;
var V: TVector;
begin
  V := CrossProduct(UpY, LineOfSight);
  V := ScaleVector(V, Factor);
  Result := AddVector(Position, V);
end;

function TCamera.NextStrafe_Position(FromPosition: TVector; Factor: Single): TVector;
var V: TVector;
begin
  V := CrossProduct(UpY, LineOfSight);
  V := ScaleVector(V, Factor);
  Result := AddVector(FromPosition, V);
end;



procedure TCamera.StrafeUpDown(Factor: Single);
var V: TVector;
begin
  V := CrossProduct(UpY, LineOfSight);
  V := CrossProduct(LineOfSight, V);
  V := ScaleVector(V, Factor);
  Position := AddVector(Position, V);
  Target := AddVector(Target, V);
end;

function TCamera.NextStrafeUpDown_Position(Factor: Single): TVector;
var V: TVector;
begin
  V := CrossProduct(UpY, LineOfSight);
  V := CrossProduct(LineOfSight, V);
  V := ScaleVector(V, Factor);
  Result := AddVector(Position, V);
end;

function TCamera.NextStrafeUpDown_Position(FromPosition: TVector; Factor: Single): TVector;
var V: TVector;
begin
  V := CrossProduct(UpY, LineOfSight);
  V := CrossProduct(LineOfSight, V);
  V := ScaleVector(V, Factor);
  Result := AddVector(FromPosition, V);
end;







(*
initialization
  Camera := TCamera.Create;

finalization
  Camera.Free
*)



end.
