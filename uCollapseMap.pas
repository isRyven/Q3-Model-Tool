unit uCollapseMap;
interface
uses classes, u3DTypes, uCalc, Math, uMDM,uMDX, OpenGL,dialogs;

// polygon-reduction method by Stan Melax

type
  TTriData = record
    v: array[0..2] of integer; // indices to vertex list
  end;

  TVectorArray = array of TVector;
  TTriDataArray = array of TTriData;
  TIntArray = array of integer;

  PcmVertex = ^TcmVertex;
  PcmTriangle = ^TcmTriangle;

  TcmVertex = class(TObject)
  private
    this: PcmVertex;
    fSurfaceNr: integer;
  public
    ID: integer;
    Position: TVector;
    Neighbour: TList;  //PcmVertex
    Face: TList;       //PcmTriangle
    objDist: single;
    collapse: PcmVertex;
    constructor Create(_this:PcmVertex; v:TVector; index:integer; SurfaceNr:integer);
    destructor Destroy; override;
    procedure RemoveIfNonNeighbour(var n: PcmVertex);
  end;

  TcmTriangle = class(TObject)
  private
    this: PcmTriangle;
    fSurfaceNr: integer;
  public
    Vertex: array[0..2] of PcmVertex;
    Normal: TVector;
    constructor Create(_this:PcmTriangle; var v0,v1,v2:PcmVertex; SurfaceNr:integer);
    destructor Destroy; override;
    procedure ComputeNormal;
    procedure ReplaceVertex(var vold:PcmVertex; var vnew:PcmVertex);
    function HasVertex(var v: PcmVertex) : boolean;
  end;

  TCollapseMap = class(TObject)
  public
    vertices: array of TList;  //PcmVertex      // length = num_surfaces
    triangles: array of TList; //PcmTriangle    // length = num_surfaces
    permutation: array of TIntArray;            // length = num_surfaces
    collapse_map: array of TIntArray;           // length = num_surfaces
    vert: array of TVectorArray;                // length = num_surfaces
    tri: array of TTriDataArray;                // length = num_surfaces
    LODminimum: array of integer;               // length = num_surfaces
    rendervertexcount, renderpolycount: integer;  // surfaces[s].lod_minimum is op vertexcount
    constructor Create;
    destructor Destroy; override;
    function CountTrisOnEdge(var u:PcmVertex; var v:PcmVertex) : integer;
    function TriHasSilhouetteEdge(var tri:PcmTriangle; var u:PcmVertex) : boolean;
    function HasSilhouetteEdge(var u:PcmVertex) : boolean;
    function ComputeEdgeCollapseCost(var u:PcmVertex; var v:PcmVertex) : single;
    procedure ComputeEdgeCostAtVertex(var v:PcmVertex);
    procedure ComputeAllEdgeCollapseCosts(SurfaceNr:integer);
    procedure Collapse(var u:PcmVertex; var v:PcmVertex; SurfaceNr:integer);
    procedure Addvertex(var vert: TVectorArray; SurfaceNr:integer);
    procedure AddFaces(var tri: TTriDataArray; SurfaceNr:integer);
    function MinimumCostEdge(SurfaceNr:integer) : PcmVertex;
    procedure ProgressiveMesh(var vert: TVectorArray; var tri: TTriDataArray; var map: TIntArray; var permutation: TIntArray; SurfaceNr:integer);
    function CMap(SurfaceNr, a,mx:integer) : integer;
    procedure PermuteVertices(var vert: TVectorArray; var tri: TTriDataArray; var permutation: TIntArray);
    procedure PermuteVerticesMDM(SurfaceNr:integer);
    procedure LOD(MDM:TMDM; MDX:TMDX; FrameNr:integer); //framenr = een frame waar manneke (zoveel mogelijk) in feutis-houding zit
    procedure DrawModelTrianglesMDM(FrameNr:integer; SurfaceNr:integer; LOD_Minimum:integer);
  end;

  function ListContains(var List:TList; ptr:Pointer) : integer;
  
var CM: TCollapseMap;


implementation

function ListContains(var List:TList; ptr:Pointer): integer;
var i: integer;
begin
  Result := 0;
  for i:=0 to List.Count-1 do
    if List[i] = ptr then Inc(Result);
end;

{ TcmTriangle }
constructor TcmTriangle.Create(_this:PcmTriangle; var v0,v1,v2: PcmVertex; SurfaceNr:integer);
var i,j: integer;
begin
  inherited Create;
  if (v0=v1) or (v1=v2) or (v2=v0) then Exit;
  this := _this;
  fSurfaceNr := SurfaceNr;
  Vertex[0] := v0;
  Vertex[1] := v1;
  Vertex[2] := v2;
  ComputeNormal;
  CM.triangles[SurfaceNr].Add(this);
  for i:=0 to 2 do begin
    Vertex[i]^.Face.Add(this);
    for j:=0 to 2 do
      if i<>j then
        if ListContains(Vertex[i]^.Neighbour, Vertex[j])=0 then
          Vertex[i]^.Neighbour.Add(Vertex[j]);
  end;
end;

destructor TcmTriangle.Destroy;
var i,i2: integer;
begin
  CM.triangles[fSurfaceNr].Remove(this);
  for i:=0 to 2 do
    if Vertex[i]<>nil then Vertex[i]^.Face.Remove(this);
  for i:=0 to 2 do begin
    i2 := (i+1) mod 3;
    if (Vertex[i]=nil) or (Vertex[i2]=nil) then Continue;
    Vertex[i]^.RemoveIfNonNeighbour(Vertex[i2]);
    Vertex[i2]^.RemoveIfNonNeighbour(Vertex[i]);
  end;
  inherited Destroy;
end;

function TcmTriangle.HasVertex(var v: PcmVertex): boolean;
begin
  Result := ((v=Vertex[0]) or (v=Vertex[1]) or (v=Vertex[2]));
end;

procedure TcmTriangle.ComputeNormal;
begin
  Normal := PlaneNormal(Vertex[0]^.Position, Vertex[1]^.Position, Vertex[2]^.Position);
end;

procedure TcmTriangle.ReplaceVertex(var vold:PcmVertex; var vnew:PcmVertex);
var i,j: integer;
begin
  if (vold=nil) or (vnew=nil) then Exit;
  if (vold<>Vertex[0]) and (vold<>Vertex[1]) and (vold<>Vertex[2]) then Exit;
  if (vnew=Vertex[0]) or (vnew=Vertex[1]) or (vnew=Vertex[2]) then Exit;
  if vold=Vertex[0] then
    Vertex[0] := vnew
  else
    if vold=Vertex[1] then
      Vertex[1] := vnew
    else
      if vold=Vertex[2] then
        Vertex[2] := vnew
      else
        Exit;
  vold^.Face.Remove(this);
  if vnew^.Face.IndexOf(this)<>-1 then Exit;
  vnew^.Face.Add(this);
  for i:=0 to 2 do begin
    vold^.RemoveIfNonNeighbour(Vertex[i]);
    Vertex[i]^.RemoveIfNonNeighbour(vold);
  end;
  for i:=0 to 2 do begin
    if ListContains(Vertex[i]^.Face, this) <> 1 then Exit;
    for j:=0 to 2 do
      if i<>j then
        if ListContains(Vertex[i]^.Neighbour, Vertex[j])=0 then
          Vertex[i]^.Neighbour.Add(Vertex[j]);
  end;
  ComputeNormal;
end;



{ TcmVertex }
constructor TcmVertex.Create(_this:PcmVertex; v: TVector; index:integer; SurfaceNr:integer);
begin
  inherited Create;
  this := _this;
  fSurfaceNr := SurfaceNr;
  Neighbour := TList.Create;
  Face := TList.Create;
  Position := v;
  ID := index;
  collapse := nil;
  CM.vertices[SurfaceNr].Add(this);
end;

destructor TcmVertex.Destroy;
var v: PcmVertex;
begin
  // geheugen dealloceren
  if Face.Count<>0 then Exit;
  while Neighbour.Count>0 do begin
    v := Neighbour[0];
    v^.Neighbour.Remove(this);
    Neighbour.Remove(v);
  end;
  // lists vrijgeven
  Neighbour.Free; //.Destroy
  Face.Free; //.Destroy
  CM.vertices[fSurfaceNr].Remove(this);
  inherited Destroy;
end;

procedure TcmVertex.RemoveIfNonNeighbour(var n: PcmVertex);
var i: integer;
    F: PcmTriangle;
begin
	// removes n from neighbor list if n isn't a neighbor.
  if Neighbour.IndexOf(n)=-1 then Exit;
  for i:=0 to Face.Count-1 do begin
    F := Face[i];
    if F^.HasVertex(n) then Exit;
  end;
  Neighbour.Remove(n);
end;



{ TCollapseMap }
constructor TCollapseMap.Create;
var i:integer;
begin
  SetLength(vertices, 32);  //max_surfaces
  SetLength(triangles, 32);
  SetLength(LODminimum, 32);
  for i:=0 to 31 do begin
    vertices[i] := TList.Create;
    triangles[i] := TList.Create;
  end;
  SetLength(permutation, 0);
  SetLength(collapse_map, 0);
  SetLength(vert, 0);
  SetLength(tri, 0);
end;

destructor TCollapseMap.Destroy;
var i:integer;
begin
  // lists vrijgeven
  for i:=0 to 31 do begin
    vertices[i].Free; //.Destroy
    triangles[i].Free; //.Destroy
  end;
  SetLength(LODminimum, 0);
  SetLength(permutation, 0);
  SetLength(collapse_map, 0);
  SetLength(vert, 0);
  SetLength(tri, 0);
end;

function TCollapseMap.CountTrisOnEdge(var u, v: PcmVertex): integer;
var i: integer;
    F: PcmTriangle;
begin
  Result := 0;
  for i:=0 to u^.Face.Count-1 do begin
    F := u^.Face[i];
    if F^.HasVertex(v) then Inc(Result);
  end;
end;

function TCollapseMap.TriHasSilhouetteEdge(var tri: PcmTriangle;  var u: PcmVertex): boolean;
var i: integer;
begin
  Result := false;
  for i:=0 to 2 do
    if (tri^.Vertex[i]<>u) and (CountTrisOnEdge(u, tri^.Vertex[i])=1) then begin
      Result := true;
      Exit;
    end;
end;

function TCollapseMap.HasSilhouetteEdge(var u: PcmVertex): boolean;
var i: integer;
    F: PcmTriangle;
begin
  Result := false;
  {if u=nil then Exit;
  if not Assigned(u^.Face) then Exit;}
  for i:=0 to u^.Face.Count-1 do begin
    F := u^.Face[i];
    if TriHasSilhouetteEdge(F, u) then begin
      Result := true;
      Exit;
    end;
  end;
end;


function TCollapseMap.ComputeEdgeCollapseCost(var u:PcmVertex; var v:PcmVertex): single;
var i,j: integer;
    edgelength: single;
    curvature: single;
    sides: TList; //PcmTriangle
    F,S: PcmTriangle;
    mincurv: single;
    dotprod: single;
begin
(*
	// if we collapse edge uv by moving u to v then how
	// much different will the model change, i.e. how much "error".
	// Texture, vertex normal, and border vertex code was removed
	// to keep this demo as simple as possible.
	// The method of determining cost was designed in order
	// to exploit small and coplanar regions for
	// effective polygon reduction.
	// Is is possible to add some checks here to see if "folds"
	// would be generated.  i.e. normal of a remaining face gets
	// flipped.  I never seemed to run into this problem and
	// therefore never added code to detect this case.
*)
  edgelength := VectorLength(SubVector(v^.Position, u^.Position));
  curvature := 0;
	// find the "sides" triangles that are on the edge uv
  sides := TList.Create;
  try
    for i:=0 to u^.Face.Count-1 do begin
      F := u^.Face[i];
      if F^.HasVertex(v) then sides.Add(F);
    end;
	  // use the triangle facing most away from the sides
  	// to determine our curvature term
    for i:=0 to u^.Face.Count-1 do begin
      F := u^.Face[i];
      mincurv := 1; // curve for face i and closer side to it
      for j:=0 to sides.Count-1 do begin
        S := sides[j];
        // use dot product of face normals.
        dotprod := DotProduct(F^.Normal, S^.Normal);
        mincurv := Min(mincurv, (1.0-dotprod)/2.0);
      end;
      curvature := Max(curvature, mincurv);
    end;
    // the more coplanar the lower the curvature term
    Result := edgelength * curvature;
    if HasSilhouetteEdge(u) and (not HasSilhouetteEdge(v)) then Result := Result + 100000; //!!!!
    if HasSilhouetteEdge(u) and HasSilhouetteEdge(v) then Result := Result + 10000; //!!!!
//Result := Abs(Result);
  finally
    sides.Free;
  end;
end;

procedure TCollapseMap.ComputeEdgeCostAtVertex(var v:PcmVertex);
var i: integer;
    dist: single;
    n: PcmVertex;
begin
(*
	// compute the edge collapse cost for all edges that start
	// from vertex v.  Since we are only interested in reducing
	// the object by selecting the min cost edge at each step, we
	// only cache the cost of the least cost edge at this vertex
	// (in member variable collapse) as well as the value of the
	// cost (in member variable objdist).
*)
  if v^.Neighbour.Count=0 then begin
		// v doesn't have neighbors so it costs nothing to collapse
    v^.collapse := nil;
    v^.objDist := -0.01;
    Exit;
  end;
  v^.collapse := nil;
  v^.objDist := 1000000;
	// search all neighboring edges for "least cost" edge
  for i:=0 to v^.Neighbour.Count-1 do begin
    n := v^.Neighbour[i];
    dist := ComputeEdgeCollapseCost(v, n);
    if dist < v^.objDist then begin
      v^.collapse := n {v^.Neighbour[i]};  // candidate for edge collapse
      v^.objDist := dist;             // cost of the collapse
    end;
  end;
end;

procedure TCollapseMap.ComputeAllEdgeCollapseCosts(SurfaceNr:integer);
var i:integer;
    v: PcmVertex;
begin
(*
	// For all the edges, compute the difference it would make
	// to the model if it was collapsed.  The least of these
	// per vertex is cached in each vertex object.
*)
  for i:=0 to vertices[SurfaceNr].Count-1 do begin
    v := vertices[SurfaceNr][i];
    ComputeEdgeCostAtVertex(v);
  end;
end;

procedure TCollapseMap.Collapse(var u:PcmVertex; var v:PcmVertex; SurfaceNr:integer);
var i,k: integer;
    tmp: TList; //PcmVertex
    F: PcmTriangle;
    n: PcmVertex;
    //
//!!    un,vn,en: integer;
begin
(*
	// Collapse the edge uv by moving vertex u onto v
	// Actually remove tris on uv, then update tris that
	// have u to have v, and then remove u.
*)
  if v=nil then begin
//vertices[SurfaceNr].Remove(u);
    u^.Free; //.Destroy
    Dispose(u);
{    u := nil;} //!!
    Exit;
  end;
  tmp := TList.Create;
  try
//!!un:=u^.Face.Count;
//!!vn:=v^.Face.Count;
//!!en:=(un-2)+(vn-2);
    // make tmp a list of all the neighbors of u
    for i:=0 to u^.Neighbour.Count-1 do tmp.Add(u^.Neighbour[i]);
    // delete triangles on edge uv:
    for i:=u^.Face.Count-1 downto 0 do begin
      F := u^.Face[i];
      if F^.HasVertex(v) then begin
//triangles[SurfaceNr].Remove(F);
        F^.Free; //.Destroy
        Dispose(F);
{PcmTriangle(u^.Face[i])^.Free;
Dispose(F);}
//F := nil;
//        u^.Face.Delete(i);
{        u^.Face[i] := nil;  //F error: list out of bounds}  //!!
//        F := nil;  //F error: list out of bounds
      end;
    end;
{if un<>u^.Neighbour.Count+2 then begin
showmessage('un<>u^.Neighbour.Count+2');
end;}
{if un<>u^.Face.Count+2 then begin
//showmessage('un<>u^.Face.Count+2');
end;}
    // update remaining triangles to have v instead of u
    for i:=u^.Face.Count-1 downto 0 do begin
      F := u^.Face[i];
      F^.ReplaceVertex(u,v);
    end;
{if en<>v^.Face.Count then begin
//showmessage('after: en<>v^.Face.Count');
end;
if v^.Neighbour.Count<>v^.Face.Count then begin
//showmessage('after: v^.Neighbour.Count<>v^.Face.Count');
end;}
//vertices[SurfaceNr].Remove(u);
    u^.Free; //.Destroy
    Dispose(u);
{    u := nil;} //!!
    // recompute the edge collapse costs for neighboring vertices
    for i:=0 to tmp.Count-1 do begin
      n := tmp[i];
      ComputeEdgeCostAtVertex(n);
    end;
  finally
    tmp.Free;
  end;
end;

procedure TCollapseMap.AddVertex(var vert: TVectorArray; SurfaceNr:integer);
var i: integer;
    v: PcmVertex;
begin
  for i:=0 to Length(vert)-1 do begin
    New(v);
    v^ := TcmVertex.Create(v, vert[i],i, SurfaceNr);
  end;
end;

procedure TCollapseMap.AddFaces(var tri: TTriDataArray; SurfaceNr:integer);
var i: integer;
    t: PcmTriangle;
    v0,v1,v2: PcmVertex;
begin
  for i:=0 to Length(tri)-1 do begin
    New(t);
    v0 := vertices[SurfaceNr][tri[i].v[0]];
    v1 := vertices[SurfaceNr][tri[i].v[1]];
    v2 := vertices[SurfaceNr][tri[i].v[2]];
    t^ := TcmTriangle.Create(t, v0,v1,v2, SurfaceNr);
  end;
end;

function TCollapseMap.MinimumCostEdge(SurfaceNr:integer): PcmVertex;
var mn, v: PcmVertex;
    i: integer;
begin
(*
	// Find the edge that when collapsed will affect model the least.
	// This funtion actually returns a Vertex, the second vertex
	// of the edge (collapse candidate) is stored in the vertex data.
	// Serious optimization opportunity here: this function currently
	// does a sequential search through an unsorted list :-(
	// Our algorithm could be O(n*lg(n)) instead of O(n*n)
*)
  mn := nil;
  for i:=0 to vertices[SurfaceNr].Count-1 do begin
    v := vertices[SurfaceNr][i];
    if v^.collapse=nil then begin
      Result := v;
      Exit;
    end;
  end;
  for i:=0 to vertices[SurfaceNr].Count-1 do begin
    v := vertices[SurfaceNr][i];
    if (mn=nil) or (v^.objDist<mn^.objDist) then begin
      if HasSilhouetteEdge(v) then Continue;
      mn := v;
    end;
  end;
  if mn<>nil then begin
    Result := mn;
    Exit;
  end;

  if LODminimum[SurfaceNr]=-1 then LODminimum[SurfaceNr] := vertices[SurfaceNr].Count;

  mn := vertices[SurfaceNr][0];
  for i:=0 to vertices[SurfaceNr].Count-1 do begin
    v := vertices[SurfaceNr][i];
    if v^.objDist < mn^.objDist then mn := v;
  end;
  Result := mn;
end;

procedure TCollapseMap.ProgressiveMesh(var vert: TVectorArray; var tri: TTriDataArray; var map, permutation: TIntArray; SurfaceNr:integer);
var mn: PcmVertex;
    i: integer;
begin
  AddVertex(vert, SurfaceNr);  // put input data into our data structures
  AddFaces(tri, SurfaceNr);
	ComputeAllEdgeCollapseCosts(SurfaceNr); // cache all edge collapse costs
  SetLength(permutation, vertices[SurfaceNr].Count);
  SetLength(map, vertices[SurfaceNr].Count);
  // LOD
  LODminimum[SurfaceNr] := -1;
	// reduce the object down to nothing:
  while vertices[SurfaceNr].Count>0 do begin
  {for i:=0 to vertices[SurfaceNr].Count-1 do begin}
    // get the next vertex to collapse
    mn := MinimumCostEdge(SurfaceNr);
    // keep track of this vertex, i.e. the collapse ordering
    permutation[mn^.ID] := vertices[SurfaceNr].Count-1;
		// keep track of vertex to which we collapse to
    if mn^.collapse<>nil then map[vertices[SurfaceNr].Count-1] := mn^.collapse^.ID
                         else map[vertices[SurfaceNr].Count-1] := -1;
		// Collapse this edge
    Collapse(mn, mn^.collapse, SurfaceNr);
  end;

	// reorder the map list based on the collapse ordering
  for i:=0 to Length(map)-1 do
    if map[i]=-1 then map[i] := 0
                 else map[i] := permutation[map[i]];
	// The caller of this function should reorder their vertices
	// according to the returned "permutation".

  // LOD
  if LODminimum[SurfaceNr]=-1 then LODminimum[SurfaceNr] := 0;
end;

function TCollapseMap.CMap(SurfaceNr, a, mx: integer): integer;
begin
(*
// Note that the use of the Map() function and the collapse_map
// list isn't part of the polygon reduction algorithm.
// We just set up this system here in this module
// so that we could retrieve the model at any desired vertex count.
// Therefore if this part of the program confuses you, then
// dont worry about it.  It might help to look over the progmesh.cpp
// module first.

//       Map()
//
// When the model is rendered using a maximum of mx vertices
// then it is vertices 0 through mx-1 that are used.
// We are able to do this because the vertex list
// gets sorted according to the collapse order.
// The Map() routine takes a vertex number 'a' and the
// maximum number of vertices 'mx' and returns the
// appropriate vertex in the range 0 to mx-1.
// When 'a' is greater than 'mx' the Map() routine
// follows the chain of edge collapses until a vertex
// within the limit is reached.
//   An example to make this clear: assume there is
//   a triangle with vertices 1, 3 and 12.  But when
//   rendering the model we limit ourselves to 10 vertices.
//   In that case we find out how vertex 12 was removed
//   by the polygon reduction algorithm.  i.e. which
//   edge was collapsed.  Lets say that vertex 12 was collapsed
//   to vertex number 7.  This number would have been stored
//   in the collapse_map array (i.e. collapse_map[12]==7).
//   Since vertex 7 is in range (less than max of 10) we
//   will want to render the triangle 1,3,7.
//   Pretend now that we want to limit ourselves to 5 vertices.
//   and vertex 7 was collapsed to vertex 3
//   (i.e. collapse_map[7]==3).  Then triangle 1,3,12 would now be
//   triangle 1,3,3.  i.e. this polygon was removed by the
//   progressive mesh polygon reduction algorithm by the time
//   it had gotten down to 5 vertices.
//   No need to draw a one dimensional polygon. :-)
*)
  Result := 0;
  if mx<=0 then Exit;
{  while a>=mx do a := collapse_map[SurfaceNr][a];}
  while a>=mx do a := MDM.Surfaces[SurfaceNr].CollapseMap[a];
  Result := a;
end;

procedure TCollapseMap.PermuteVertices(var vert: TVectorArray; var tri: TTriDataArray; var permutation: TIntArray);
var i,j: integer;
    temp_list: TVectorArray;
begin
	// rearrange the vertex list
  if Length(permutation)<>Length(vert) then Exit;
  SetLength(temp_list, Length(vert));
  for i:=0 to Length(vert)-1 do temp_list[i] := vert[i];
  for i:=0 to Length(vert)-1 do vert[permutation[i]] := temp_list[i];
	// update the changes in the entries in the triangle list
  for i:=0 to Length(tri)-1 do
    for j:=0 to 2 do
      tri[i].v[j] := permutation[tri[i].v[j]];
  SetLength(temp_list, 0);
end;

procedure TCollapseMap.PermuteVerticesMDM(SurfaceNr: integer);
var V: TMDMVertex;
    W: TMDMWeight;
    i,j,p, LenV,LenW,LenT :integer;
    VertexCopy: packed array of TMDMVertex;       // length = TMDMSurfaceHeader.Num_Verts
begin
  if (SurfaceNr<0) or (SurfaceNr>=MDM.Header.Num_Surfaces) then Exit;
  // copy maken vann vertices
  LenV := MDM.Surfaces[SurfaceNr].Values.Num_Verts;
  SetLength(VertexCopy, LenV);
  for i:=0 to LenV-1 do begin
    VertexCopy[i].Normal := MDM.Surfaces[SurfaceNr].Vertex[i].Normal;
    VertexCopy[i].TexCoordU := MDM.Surfaces[SurfaceNr].Vertex[i].TexCoordU;
    VertexCopy[i].TexCoordV := MDM.Surfaces[SurfaceNr].Vertex[i].TexCoordV;
    LenW := MDM.Surfaces[SurfaceNr].Vertex[i].Num_BoneWeights;
    VertexCopy[i].Num_BoneWeights := LenW;
    SetLength(VertexCopy[i].Weights, LenW);
    for j:=0 to LenW-1 do begin
      VertexCopy[i].Weights[j].BoneIndex := MDM.Surfaces[SurfaceNr].Vertex[i].Weights[j].BoneIndex;
      VertexCopy[i].Weights[j].Weight := MDM.Surfaces[SurfaceNr].Vertex[i].Weights[j].Weight;
      VertexCopy[i].Weights[j].BoneSpace := MDM.Surfaces[SurfaceNr].Vertex[i].Weights[j].BoneSpace;
    end;
  end;
  // vertices sorteren
  for i:=0 to LenV-1 do begin
    p := permutation[SurfaceNr][i];
    MDM.Surfaces[SurfaceNr].Vertex[p].Normal := VertexCopy[i].Normal;
    MDM.Surfaces[SurfaceNr].Vertex[p].TexCoordU := VertexCopy[i].TexCoordU;
    MDM.Surfaces[SurfaceNr].Vertex[p].TexCoordV := VertexCopy[i].TexCoordV;
    LenW := VertexCopy[i].Num_BoneWeights;
    MDM.Surfaces[SurfaceNr].Vertex[p].Num_BoneWeights := LenW;
    SetLength(MDM.Surfaces[SurfaceNr].Vertex[p].Weights, LenW);
    for j:=0 to LenW-1 do begin
      MDM.Surfaces[SurfaceNr].Vertex[p].Weights[j].BoneIndex := VertexCopy[i].Weights[j].BoneIndex;
      MDM.Surfaces[SurfaceNr].Vertex[p].Weights[j].Weight := VertexCopy[i].Weights[j].Weight;
      MDM.Surfaces[SurfaceNr].Vertex[p].Weights[j].BoneSpace := VertexCopy[i].Weights[j].BoneSpace;
    end;
  end;
  // triangles sorteren
  LenT := MDM.Surfaces[SurfaceNr].Values.Num_Triangles;
  for i:=0 to LenT-1 do
    for j:=0 to 2 do
      MDM.Surfaces[SurfaceNr].Triangles[i][j] := permutation[SurfaceNr][MDM.Surfaces[SurfaceNr].Triangles[i][j]];
  //
  for i:=0 to LenV-1 do SetLength(VertexCopy[i].Weights, 0);
  SetLength(VertexCopy, 0);
end;



procedure TCollapseMap.LOD(MDM:TMDM; MDX:TMDX; FrameNr:integer);
var SurfaceNr,i,Frame: integer;
begin
  // Frame op geldige waarde
  Frame := FrameNr;
  if FrameNr>=MDX.Header.Num_Frames then Frame:=0;
  //
  SetLength(vert, MDM.Header.Num_Surfaces);
  SetLength(tri, MDM.Header.Num_Surfaces);
  SetLength(collapse_map, MDM.Header.Num_Surfaces);
  SetLength(permutation, MDM.Header.Num_Surfaces);
  for SurfaceNr:=0 to MDM.Header.Num_Surfaces-1 do begin
    // evt bestaande LOD-minimums overnemen
{    if MDM.HasLOD then LODminimum[SurfaceNr] := MDM.Surfaces[SurfaceNr].Values.LOD_minimum
                  else LODminimum[SurfaceNr] := MDM.Surfaces[SurfaceNr].Values.Num_Verts;   // 100%}
    // arrays
    SetLength(vert[SurfaceNr], MDM.Surfaces[SurfaceNr].Values.Num_Verts);
    SetLength(tri[SurfaceNr], MDM.Surfaces[SurfaceNr].Values.Num_Triangles);
    SetLength(collapse_map[SurfaceNr], MDM.Surfaces[SurfaceNr].Values.Num_Verts);
    // neem de faces over
    for i:=0 to MDM.Surfaces[SurfaceNr].Values.Num_Triangles-1 do begin
      tri[SurfaceNr][i].v[0] := MDM.Surfaces[SurfaceNr].Triangles[i][0];
      tri[SurfaceNr][i].v[1] := MDM.Surfaces[SurfaceNr].Triangles[i][1];
      tri[SurfaceNr][i].v[2] := MDM.Surfaces[SurfaceNr].Triangles[i][2];
    end;
    // bereken de vertices van de MDM/MDX
    MDM.CalcModel(MDX, Frame, SurfaceNr);
    // neem de vertex over
    for i:=0 to MDM.Surfaces[SurfaceNr].Values.Num_Verts-1 do
      vert[SurfaceNr][i] := MDM.VertexPos[i];
    // LOD berekenen
    ProgressiveMesh(vert[SurfaceNr], tri[SurfaceNr], collapse_map[SurfaceNr], permutation[SurfaceNr], SurfaceNr);
    // collapsemap overnemen
    for i:=0 to MDM.Surfaces[SurfaceNr].Values.Num_Verts-1 do
      MDM.Surfaces[SurfaceNr].CollapseMap[i] := collapse_map[SurfaceNr][i];
    // LOD_minimum overnemen
    MDM.Surfaces[SurfaceNr].Values.LOD_minimum := LODminimum[SurfaceNr];
    MDM.LOD_minimums[SurfaceNr].Max := MDM.Surfaces[SurfaceNr].Values.Num_Verts;
    MDM.LOD_minimums[SurfaceNr].Value := LODminimum[SurfaceNr];
    //PermuteVertices(vert[SurfaceNr], tri[SurfaceNr], permutation[SurfaceNr]);
    PermuteVerticesMDM(SurfaceNr);
  end;
  // resterende LOD instellen
  MDM.Header.LOD_bias := 1;
  MDM.Header.LOD_scale := 0;
end;

procedure TCollapseMap.DrawModelTrianglesMDM(FrameNr:integer; SurfaceNr:integer; LOD_Minimum:integer);
var t, LenT,
    p0,p1,p2: integer;
    v0,v1,v2,
    Normal: TVector;
    v: PcmVertex;
begin
  glFrontFace(GL_CCW);
  glCullFace(GL_NONE);
//    glDisable(GL_CULL_FACE);
  glEnable(GL_DEPTH_TEST);
  glDepthMask(GL_TRUE);
  glDepthFunc(GL_LESS);

  //if Length(collapse_map)=0 then Exit;
  renderpolycount := 0;

  MDM.CalcModel(MDX, FrameNr, SurfaceNr);

  LenT := MDM.Surfaces[SurfaceNr].Values.Num_Triangles;
//  LenT := Length(tri[SurfaceNr]);
  for t:=0 to LenT-1 do begin
    p0 := CMap(SurfaceNr, MDM.Surfaces[SurfaceNr].Triangles[t][0], LOD_Minimum);
    p1 := CMap(SurfaceNr, MDM.Surfaces[SurfaceNr].Triangles[t][1], LOD_Minimum);
    p2 := CMap(SurfaceNr, MDM.Surfaces[SurfaceNr].Triangles[t][2], LOD_Minimum);

    // note:  serious optimization opportunity here,
    //  by sorting the triangles the following "continue"
    //  could have been made into a "break" statement.
		if (p0=p1) or (p1=p2) or (p2=p0) then Continue;
		Inc(renderpolycount);
(*
		// if we are not currenly morphing between 2 levels of detail
		// (i.e. if morph=1.0) then q0,q1, and q2 are not necessary.
		int q0= Map(p0,(int)(render_num*lodbase));
		int q1= Map(p1,(int)(render_num*lodbase));
		int q2= Map(p2,(int)(render_num*lodbase));
		Vector v0,v1,v2;
		v0 = vert[p0]*morph + vert[q0]*(1-morph);
		v1 = vert[p1]*morph + vert[q1]*(1-morph);
		v2 = vert[p2]*morph + vert[q2]*(1-morph);
*)
{v0 := vert[SurfaceNr][p0];
v1 := vert[SurfaceNr][p1];
v2 := vert[SurfaceNr][p2];}
		v2 := MDM.VertexPos[p0];
		v1 := MDM.VertexPos[p1];
		v0 := MDM.VertexPos[p2];

    glColor3f(1,1,1);
//		glBegin(GL_POLYGON);
		glBegin(GL_TRIANGLES);
			// the purpose of the demo is to show polygons
			// therefore just use 1 face normal (flat shading)
      Normal := PlaneNormal(v0,v1,v2);
      if VectorLength(Normal)>0 then glNormal3fv(@Normal);
      glVertex3fv(@v0);
      glVertex3fv(@v1);
      glVertex3fv(@v2);
		glEnd();
  end;
end;


initialization
  CM := TCollapseMap.Create;
finalization
  CM.Free;
end.
