program MD3;

{%ToDo 'MD3.todo'}

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas',
  uQ3Shaders in 'uQ3Shaders.pas',
  uCollapseMap in 'uCollapseMap.pas',
  uMD3 in 'uMD3.pas',
  uMDM in 'uMDM.pas',
  uMDX in 'uMDX.pas',
  uMDS in 'uMDS.pas',
  uMS3D in 'uMS3D.pas',
  uMap in 'uMap.pas',
  uTesselate in 'uTesselate.pas',
  uASE in 'uASE.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Q3 Model Tool';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TdlgPK3, dlgPK3);
  Application.Run;
end.
