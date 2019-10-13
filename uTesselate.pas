unit uTesselate;
//
// De methode van deze webpagina is gebruikt:
// http://www.cs.toronto.edu/~heap/Courses/270F02/A4/chains/node2.html
//
interface
uses u3DTypes, uCalc;

type
  TPolygonObj = class(TObject)
  private
    Poly: TPolygon;                     // n vertices
    Cost: array of array of single;     // Cost[n][n]
    Minimum: array of array of integer; // Minimum[n][n] (index van vertex)
  public
    procedure Clear;                 // de interne polygon legen
    procedure AddVertex(V:TVector);  // een punt toevoegen aan de interne polygon
    // weight van een triangle bepalen. (Weight = de omtrek van 1 triangle)
    function GetWeight(V0,V1,V2:integer) : single; //V0,V1,2 zijn indexes in de Poly
    // de cost van een aantal triangles bepalen.
    // De 2 argumenten i & k zijn vertex-indexen in de poly.
    // Alle triangles die mogelijk zijn tussen vertex[i] t/m vertex[k] bepalen de cost.
    // k moet tenminste i+2 zijn om een triangle te kunnen vormen.
    // Het resultaat (de cost voor triangles mogelijk met vertex[i..k]) komt in Cost[i][k]
    procedure CalcCostForTriangles(i,k:integer);
    // de cost van de poly bepalen. (cost = de som van de weights van alle sub-triangles in de poly)
    procedure PolyCosts;
    // tesselate alles
    procedure SubDivide;             // tesselate in driehoeken
  end;

implementation

{ TPolygonObj }

procedure TPolygonObj.Clear;
var i: integer;
begin
  SetLength(Poly.Vertex, 0);
  // Cost
  for i:=0 to Length(Cost)-1 do SetLength(Cost[i], 0);
  SetLength(Cost, 0);
  // Minimum
  for i:=0 to Length(Minimum)-1 do SetLength(Minimum[i], 0);
  SetLength(Minimum, 0);
end;

procedure TPolygonObj.AddVertex(V: TVector);
var Len,i,j: integer;
begin
  // vertex toevoegen aan de poly
  Len := Length(Poly.Vertex);
  SetLength(Poly.Vertex, Len+1);
  Poly.Vertex[Len] := V;
  // Cost array uitbreiden
  SetLength(Cost, Len);
  for i:=0 to Len-1 do SetLength(Cost[i], Len);
  for i:=0 to Len-1 do
    for j:=0 to Len-1 do Cost[i][j] := 0;
  // Minimum array uitbreiden
  SetLength(Minimum, Len);
  for i:=0 to Len-1 do SetLength(Minimum[i], Len);
  for i:=0 to Len-1 do
    for j:=0 to Len-1 do Minimum[i][j] := 0;
end;

function TPolygonObj.GetWeight(V0, V1, V2: integer): single;
var Len: integer;
    L0,L1,L2: single;
begin
  Result := 0;
  Len := Length(Poly.Vertex);
  // controleer indexen
  if (V0<0) or (V0>=Len) then Exit;
  if (V1<0) or (V1>=Len) then Exit;
  if (V2<0) or (V2>=Len) then Exit;
  // de lengte van iedere zijde bepalen
  L0 := VectorLength(SubVector(Poly.Vertex[V0],Poly.Vertex[V1]));
  L1 := VectorLength(SubVector(Poly.Vertex[V1],Poly.Vertex[V2]));
  L2 := VectorLength(SubVector(Poly.Vertex[V2],Poly.Vertex[V0]));
  // de omtrek
  Result := L0 + L1 + L2;
end;

procedure TPolygonObj.CalcCostForTriangles(i, k: integer);
var MinJ,j: integer;
    MinCost,c: single;
//--
  // j is een waarde in het bereik: i<j<k dus [i+1..k-1]
  function GetCost(i,j,k:integer) : single;
  begin
    Result := 0;
    if k<i+2 then Exit; // tenminste 1 driehoek te maken??
    Result := Cost[i][j] + Cost[j][k] + GetWeight(i,j,k);
  end;
//--
begin
  // alle triangles met j=[i+1..k-1] doorlopen..
  MinCost := 3.3E38;  // 1e hit is altijd raak
  MinJ := -1;
  for j:=i to k do begin
    c := GetCost(i,j,k);
    if c<MinCost then begin
      MinJ := j;
      MinCost := c;
    end;
  end;
  Cost[i][k] := MinCost;
  Minimum[i][k] := MinJ;
end;

procedure TPolygonObj.PolyCosts;
var i,j,k, MinJ: integer;
begin
  i := 0;
  j := i+1;
  k := Length(Poly.Vertex)-1;
  // zoek de minste-cost combinatie
  CalcCostForTriangles(i, k);
//  if Cost[i][k]>0 then
//Cost[i][k]             //minste cost voor deze complete polygon..
  MinJ := Minimum[i][k]; //..met deze vertex[j]



end;

procedure TPolygonObj.SubDivide;
begin
  //
end;

end.
