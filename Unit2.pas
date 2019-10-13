unit Unit2;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
     Buttons, ExtCtrls, ComCtrls, ZipForge, Dialogs;

type
  TdlgPK3 = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    tvPK3: TTreeView;
    Zip: TZipForge;
    OpenDialogPK3: TOpenDialog;
    procedure FormShow(Sender: TObject);
    procedure tvPK3DblClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure tvPK3Click(Sender: TObject);
  private
    fVisible: boolean;
  public
    MapPK3,
    PathDir,
    PAKfile: string;
  end;

var
  dlgPK3: TdlgPK3;

implementation
uses uMD3, Unit1, uQ3Shaders, StrUtils;
{$R *.dfm}

procedure TdlgPK3.FormShow(Sender: TObject);
var RootNode, ParentNode, Node: TTreeNode;
    s, LastPath, SearchFor: string;
    ai: TZFArchiveItem;
    p,p2: integer;
    gp, Num_PAKs: integer;
    Found: boolean;
begin
  fVisible := true;
  Found := false;
  tvPK3.Items.Clear;
  tvPK3.AutoExpand := true;


  // zoek in de GAME-PAKs (pak0.pk3)
  LastPath := '';
  MapPK3 := '';
  PathDir := '';
  PAKfile := '';
  Zip.TempDir := Form1.TmpDir;
  Zip.BaseDir := Form1.TmpDir;
  // map.pk3 apart behandelen.. (niet uit game-pak lezen)
  if Tag=3 then Num_PAKs := 1
           else Num_PAKs := Length({uQ3Shaders.}PAKsList);

  try
    for gp:=0 to Num_PAKs-1 do begin
      if Form1.FileInUse(PAKsList[gp].FullPath) then begin
        ShowMessage('File in use: '+ PAKsList[gp].FullPath +''#13#10#13#10''+
                    'The file will be skipped');
        Continue;            
      end;
      // de Tag-property geeft aan wat moet worden geladen:
      // 0=MD3, 1=skin, 3=MD3 in map.pk3, 4=MDM, 5=MDX
      case Tag of
        0: begin
          SearchFor := '*.MD3';
  //      Caption := 'Select an MD3-model from the game (pak0.PK3)';
          Caption := 'Select an MD3-model from the game-PAK ('+ {uQ3Shaders.}PAKsList[gp].ShortName +')';
  //      Zip.FileName := Form1.GameDir +'etmain\pak0.pk3';
          Zip.FileName := {uQ3Shaders.}PAKsList[gp].FullPath;
  //      RootNode := tvPK3.Items.Add(nil, 'pak0.pk3');
          RootNode := tvPK3.Items.Add(nil, {uQ3Shaders.}PAKsList[gp].ShortName);
          if not RootNode.IsVisible then RootNode.MakeVisible;
          RootNode.Expand(false);
        end;
        1: begin
          SearchFor := '*.skin';
  //      Caption := 'Select a skin from the game (pak0.PK3)';
          Caption := 'Select a skin from the game-PAK ('+ {uQ3Shaders.}PAKsList[gp].ShortName +')';
  //      Zip.FileName := Form1.GameDir +'etmain\pak0.pk3';
          Zip.FileName := {uQ3Shaders.}PAKsList[gp].FullPath;
  //      RootNode := tvPK3.Items.Add(nil, 'pak0.pk3');
          RootNode := tvPK3.Items.Add(nil, {uQ3Shaders.}PAKsList[gp].ShortName);
          if not RootNode.IsVisible then RootNode.MakeVisible;
          RootNode.Expand(false);
        end;
        3: begin
          SearchFor := '*.MD3';
          Caption := 'Select a .PK3';
          // vragen om de pk3 van een map..
          OpenDialogPK3.FileName := '';
          if Form1.GameDir<>'' then OpenDialogPK3.InitialDir := Form1.GameDir+'etmain\';
          if not OpenDialogPK3.Execute then begin
            //ModalResult := mrCancel;
            fVisible := false;
            Exit;
          end;
          if OpenDialogPK3.FileName='' then begin
            //ModalResult := mrCancel;
            fVisible := false;
            Exit;
          end;
          MapPK3 := OpenDialogPK3.FileName; //voor public access
          Zip.FileName := OpenDialogPK3.FileName;
          RootNode := tvPK3.Items.Add(nil, ExtractFilename(OpenDialogPK3.FileName));
          if not RootNode.IsVisible then RootNode.MakeVisible;
          RootNode.Expand(false);
        end;
        4: begin
          SearchFor := '*.MDM';
  //      Caption := 'Select an MDM-model from the game (pak0.PK3)';
          Caption := 'Select an MDM-model from the game-PAK ('+ {uQ3Shaders.}PAKsList[gp].ShortName +')';
  //      Zip.FileName := Form1.GameDir +'etmain\pak0.pk3';
          Zip.FileName := {uQ3Shaders.}PAKsList[gp].FullPath;
  //      RootNode := tvPK3.Items.Add(nil, 'pak0.pk3');
          RootNode := tvPK3.Items.Add(nil, {uQ3Shaders.}PAKsList[gp].ShortName);
          if not RootNode.IsVisible then RootNode.MakeVisible;
          RootNode.Expand(false);
        end;
        5: begin
          SearchFor := '*.MDX';
  //      Caption := 'Select an MDX-animation from the game (pak0.PK3)';
          Caption := 'Select an MDX-animation from the game-PAK ('+ {uQ3Shaders.}PAKsList[gp].ShortName +')';
  //      Zip.FileName := Form1.GameDir +'etmain\pak0.pk3';
          Zip.FileName := {uQ3Shaders.}PAKsList[gp].FullPath;
  //      RootNode := tvPK3.Items.Add(nil, 'pak0.pk3');
          RootNode := tvPK3.Items.Add(nil, {uQ3Shaders.}PAKsList[gp].ShortName);
          if not RootNode.IsVisible then RootNode.MakeVisible;
          RootNode.Expand(false);
        end;
        else Exit;
      end;

      Zip.OpenArchive(fmOpenRead);
      // zoeken
      if Zip.FindFirst(SearchFor,ai,faAnyFile) then begin
        repeat
          if ai.StoredPath <> LastPath then begin
            // nieuw child van root aanmaken
            ParentNode := tvPK3.Items.AddChild(RootNode, ai.StoredPath);
            ParentNode.Collapse(false);
          end;
          // node aan ParentNode toevoegen
          Node := tvPK3.Items.AddChild(ParentNode, ai.FileName);
          Node.Collapse(false);
          //
          LastPath := ai.StoredPath;
        until not Zip.FindNext(ai);
        Found := true;
      end{ else
        fVisible := false};
    end;
  finally
    Zip.CloseArchive;

    fVisible := Found;
    //tvPK3Models.FullExpand;
    tvPK3.Invalidate;
    //tvPK3Models.Refresh;
  end;
end;

procedure TdlgPK3.tvPK3Click(Sender: TObject);
var Node: TTreeNode;
    i,idx: integer;
begin
  if tvPK3.SelectionCount = 0 then Exit;
  if tvPK3.Selected.HasChildren then Exit;
  if tvPK3.Selected.Parent=nil then Exit;
  PathDir := tvPK3.Selected.Parent.Text;
  //
  if Tag<>3 then begin // <> map pk3
    idx := 0;
    Node := tvPK3.Selected.Parent.Parent;
    for i:=0 to tvPK3.Items.Count-1 do
      if tvPK3.Items[i].Parent=nil then
        if tvPK3.Items[i].AbsoluteIndex = Node.AbsoluteIndex then Break else Inc(idx);
    if idx<Length({uQ3Shaders.}PAKsList) then PAKfile := {uQ3Shaders.}PAKsList[idx].FullPath
                                         else PAKfile := '';
  end;
end;

procedure TdlgPK3.tvPK3DblClick(Sender: TObject);
var Node: TTreeNode;
    i,idx: integer;
begin
  if tvPK3.SelectionCount = 0 then Exit;
  if tvPK3.Selected.HasChildren then Exit;
  if tvPK3.Selected.Parent=nil then Exit;
  PathDir := tvPK3.Selected.Parent.Text;
  //
  if Tag<>3 then begin // <> map pk3
    idx := 0;
    Node := tvPK3.Selected.Parent.Parent;
    for i:=0 to tvPK3.Items.Count-1 do
      if tvPK3.Items[i].Parent=nil then
        if tvPK3.Items[i].AbsoluteIndex = Node.AbsoluteIndex then Break else Inc(idx);
    if idx<Length({uQ3Shaders.}PAKsList) then PAKfile := {uQ3Shaders.}PAKsList[idx].FullPath
                                         else PAKfile := '';
  end;                                
  OKBtn.Click;
end;

procedure TdlgPK3.FormPaint(Sender: TObject);
begin
  if not fVisible then CancelBtn.Click;
end;

end.
