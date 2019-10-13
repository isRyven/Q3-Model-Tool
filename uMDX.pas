unit uMDX;
interface
uses uMD3, classes, SysUtils, u3DTypes;

// http://remont.ifrance.com/model_et/files/mdm&mdx.htm

const
  MDX_DEG = 360.0/65536.0;
  MDX_RAD = 2*Pi/65536.0;
  IDMDX = $5758444D; // 'MDXW' cardinal

  DEFAULT_BONE_NAMES: array[0..52] of string = ('Bip01 Pelvis','Bip01 Spine','Bip01 Spine1','Bip01 Spine2','Bip01 Spine3','Bip01 Neck','Bip01 Head','Bip01 L Clavicle','Bip01 L UpperArm','Bip01 L Forearm','Bip01 L Hand','Bip01 L Finger0','Bip01 L Finger01','Bip01 L Finger02','Bip01 L Finger1','Bip01 L Finger11','Bip01 L Finger12','Bip01 L Finger2','Bip01 L Finger21','Bip01 L Finger22','Bip01 L Finger3','Bip01 L Finger31','Bip01 L Finger32','Bip01 L Finger4','Bip01 L Finger41','Bip01 L Finger42','Bip01 R Clavicle','Bip01 R UpperArm','Bip01 R Forearm','Bip01 R Hand','Bip01 R Finger0','Bip01 R Finger01','Bip01 R Finger02','Bip01 R Finger1','Bip01 R Finger11','Bip01 R Finger12','Bip01 R Finger2','Bip01 R Finger21','Bip01 R Finger22','Bip01 R Finger3','Bip01 R Finger31','Bip01 R Finger32','Bip01 R Finger4','Bip01 R Finger41','Bip01 R Finger42','Bip01 L Thigh','Bip01 L Calf','Bip01 L Foot','Bip01 L Toe0','Bip01 R Thigh','Bip01 R Calf','Bip01 R Foot','Bip01 R Toe0');

type
  TMDXBone = packed record
    Name: q3string;
    ParentIndex: Integer;
    TorsoWeight: Single;
    ParentDistance: Single;
    Flags: cardinal;                 // If this bone is tag this value is 1, otherwise 0
  end;

  TMDXCompressedBoneFrame = packed record
    Angle_Pitch,                     // degrees = * 180.0/32767.0
    Angle_Yaw,
    Angle_Roll: SmallInt;
    unused: SmallInt;
    OffsetAngle_Pitch,
    OffsetAngle_Yaw: SmallInt;
  end;

  TMDXFrame = packed record
    Min_Bounds: TVector;
    Max_Bounds: TVector;
    Local_Origin: TVector;
    Radius: single;
    ParentOffset: TVector;
    CompressedBoneFrame: packed array of TMDXCompressedBoneFrame; // length = TMDXHeader.Num_Bones
  end;

  TMDXHeader = packed record
    Ident: cardinal;                 // "MDXW"
    Version: cardinal;               // should be 2
    Name: q3string;
    Num_Frames: cardinal;
    Num_Bones: cardinal;
    Ofs_Frames: cardinal;
    Ofs_Bones: cardinal;
    TorsoParent: cardinal;
    Ofs_EOF: cardinal;
  end;


  TMDX = class(TObject)
  private
    Fopen, Fsave: TFilestream;
    function IsMDX : boolean;
    function Size_Header : cardinal;
    function Size_Frame : cardinal;
    function Size_Frames : cardinal;
    function Size_Bones : cardinal;
  public
    Header: TMDXHeader;
    Frames: packed array of TMDXFrame;
    Bones: packed array of TMDXBone;
    //
    function LoadFromFile(Filename: string): boolean;
    function SaveToFile(Filename: string) : boolean;
    function LoadBonesFromFile(Filename: string): boolean;
    function LoadFramesFromFile(Filename: string): boolean;
    //
    procedure Clear;
  end;


  TANINCFrame = packed record
    // <animation name>	<first frame> <length> <looping> <fps> <move speed> <transition> <reversed>
    Name: string;
    FirstFrame,
    Length,
    Looping,
    FPS,
    MoveSpeed,
    Transition,
    Reversed: integer;
  end;

  TANINC = class(TObject)
  private
    Fopen: TFilestream;
  public
    Anims: array of TANINCFrame;
    function LoadFromFile(Filename: string): boolean;
    procedure Clear;
  end;


var MDX : TMDX;
    Aninc: TANINC;



implementation

function TMDX.IsMDX: boolean;
begin
  Result := (Header.Ident = IDMDX);
end;


procedure TMDX.Clear;
var i: integer;
begin
  for i:=0 to Header.Num_Frames-1 do SetLength(Frames[i].CompressedBoneFrame, 0);
  SetLength(Frames, 0);
  Header.Num_Frames := 0;
  SetLength(Bones, 0);
  Header.Num_Bones := 0;
end;


function TMDX.LoadFromFile(Filename: string): boolean;
var N, Size: cardinal;
    FP: Int64;
    f,b: integer;
begin
  Result := false;
  if not FileExists(Filename) then Exit;
  Fopen := TFileStream.Create(Filename, fmOpenRead);
  try
    try
      // Header
      N := Fopen.Read(Header, SizeOf(TMDXHeader));
      if N<>SizeOf(TMDXHeader) then Exit;
      Result := IsMDX;
      if not Result then Exit;
      // Frames
      FP := Header.Ofs_Frames;
      Fopen.Position := FP;
      SetLength(Frames, Header.Num_Frames);
      for f:=0 to Header.Num_Frames-1 do begin
        Size := 3*4 + 3*4 + 3*4 + 4 + 3*4;
        N := Fopen.Read(Frames[f].Min_Bounds, Size);
        Result := (N=Size);
        if not Result then Exit;
        // compressed bones
        SetLength(Frames[f].CompressedBoneFrame, Header.Num_Bones);
        Size := Header.Num_Bones * SizeOf(TMDXCompressedBoneFrame);
        N := Fopen.Read(Frames[f].CompressedBoneFrame[0], Size);
        Result := (N=Size);
        if not Result then Exit;
      end;
      // Bones
      FP := Header.Ofs_Bones;
      Fopen.Position := FP;
      SetLength(Bones, Header.Num_Bones);
      Size := Header.Num_Bones * SizeOf(TMDXBone);
      N := Fopen.Read(Bones[0], Size);
      Result := (N=Size);
      if not Result then Exit;
    except
      //
    end;
  finally
    Fopen.Free;
  end;
end;


function TMDX.SaveToFile(Filename: string): boolean;
var Size,f: cardinal;
begin
  // offsets
  Header.Ofs_Frames := Size_Header;
  Header.Ofs_Bones  := Header.Ofs_Frames + Size_Frames;
  Header.Ofs_EOF    := Header.Ofs_Bones + Size_Bones;

  // bestand opslaan
  Fsave := TFileStream.Create(Filename, fmCreate);
  try
    try
      // header
      Size := Size_Header;
      Fsave.WriteBuffer(Header, Size);
      // frames
      for f:=0 to Header.Num_Frames-1 do begin
        Size := 3*4 + 3*4 + 3*4 + 4 + 3*4;
        Fsave.WriteBuffer(Frames[f].Min_Bounds, Size);
        Size := Header.Num_Bones * SizeOf(TMDXCompressedBoneFrame);
        Fsave.WriteBuffer(Frames[f].CompressedBoneFrame[0], Size);
      end;
      // bones
      Size := Size_Bones;
      Fsave.WriteBuffer(Bones[0], Size);
    except
    end;
  finally
    Fsave.Free;
  end;
end;


function TMDX.LoadBonesFromFile(Filename: string): boolean;
var N, Size: cardinal;
    FP: Int64;
    f,b: integer;
    tmpHeader: TMDXHeader;
begin
  // alleen de bones laden..
  Result := false;
  Fopen := TFileStream.Create(Filename, fmOpenRead);
  try
    try
      // Header
      N := Fopen.Read(tmpHeader, SizeOf(TMDXHeader));
      if N<>SizeOf(TMDXHeader) then Exit;
      Result := (tmpHeader.Ident = IDMDX);
      if not Result then Exit;
      // Bones
      FP := tmpHeader.Ofs_Bones;
      Fopen.Position := FP;
      SetLength(Bones, tmpHeader.Num_Bones);
      Size := tmpHeader.Num_Bones * SizeOf(TMDXBone);
      N := Fopen.Read(Bones[0], Size);
      Result := (N=Size);
      if not Result then Exit;
    except
      //
    end;
  finally
    Fopen.Free;
  end;
end;


function TMDX.LoadFramesFromFile(Filename: string): boolean;
var N, Size: cardinal;
    FP: Int64;
    f,b: integer;
    tmpHeader: TMDXHeader;
begin
  Result := false;
  Fopen := TFileStream.Create(Filename, fmOpenRead);
  try
    try
      // Header
      N := Fopen.Read(tmpHeader, SizeOf(TMDXHeader));
      if N<>SizeOf(TMDXHeader) then Exit;
      Result := (tmpHeader.Ident = IDMDX);
      if not Result then Exit;
      // Frames
      FP := tmpHeader.Ofs_Frames;
      Fopen.Position := FP;
      SetLength(Frames, tmpHeader.Num_Frames);
      for f:=0 to tmpHeader.Num_Frames-1 do begin
        Size := 3*4 + 3*4 + 3*4 + 4 + 3*4;
        N := Fopen.Read(Frames[f].Min_Bounds, Size);
        Result := (N=Size);
        if not Result then Exit;
        // compressed bones
        SetLength(Frames[f].CompressedBoneFrame, tmpHeader.Num_Bones);
        Size := tmpHeader.Num_Bones * SizeOf(TMDXCompressedBoneFrame);
        N := Fopen.Read(Frames[f].CompressedBoneFrame[0], Size);
        Result := (N=Size);
        if not Result then Exit;
      end;
    except
      //
    end;
  finally
    Fopen.Free;
  end;
end;




function TMDX.Size_Header: cardinal;
begin
  Result := SizeOf(TMDXHeader);
end;

function TMDX.Size_Frame: cardinal;
var Size: cardinal;
begin
  Size := 4*3*4 + 4;
  Result := Size + (Header.Num_Bones * SizeOf(TMDXCompressedBoneFrame));
end;

function TMDX.Size_Frames: cardinal;
begin
  Result := Header.Num_Frames * Size_Frame;
end;

function TMDX.Size_Bones: cardinal;
begin
  Result := Header.Num_Bones * SizeOf(TMDXBone);
end;





{ TANINC }
procedure TANINC.Clear;
begin
  SetLength(Anims, 0);
end;

function TANINC.LoadFromFile(Filename: string): boolean;
var sl: TStringList;
    i,p,p2,w,Len: integer;
    s: string;
    words: array[0..7] of string;
begin
  Result := false;
  SetLength(Anims, 0);
  if not FileExists(Filename) then Exit;
  sl := TStringList.Create;
  try
    sl.LoadFromFile(Filename);
    for i:=0 to sl.Count-1 do begin
      s := Trim(sl.Strings[i]);
      p := Pos('//', s);
      if p>0 then s := Trim(Copy(s,1,p-1));
      if s<>'' then begin
        Len := Length(s);
        p := 1;
        for w:=0 to 7 do begin
          words[w] := '';
          // blank space negeren
          while ((s[p]=Chr(9)) or (s[p]=' ')) do begin
            if p<Len then Inc(p)
                     else Break;
          end;
          if p>Len then Break;
          // woord lezen
          while ((s[p]<>Chr(9)) and (s[p]<>' ')) do begin
            words[w] := words[w] + s[p];
            if p<Len then Inc(p)
                     else Break;
          end;
          if words[w]='' then begin
                    Break;
          end;
          if p>=Len then Break;
        end;
        if w=7 then begin
          // array element aanmaken
          Len := Length(Anims);
          SetLength(Anims, Len+1);
          Anims[Len].Name := words[0];
          Anims[Len].FirstFrame := StrToInt(words[1]);
          Anims[Len].Length := StrToInt(words[2]);
          Anims[Len].Looping := StrToInt(words[3]);
          Anims[Len].FPS := StrToInt(words[4]);
          Anims[Len].MoveSpeed := StrToInt(words[5]);
          Anims[Len].Transition := StrToInt(words[6]);
          Anims[Len].Reversed := StrToInt(words[7]);
        end;
      end;
    end;
    if i=sl.Count then Result := true;
  finally
    sl.Free;
  end;
end;

initialization
  MDX := TMDX.Create;
  Aninc := TANINC.Create;
finalization
  MDX.Free;
  Aninc.Free;


end.
