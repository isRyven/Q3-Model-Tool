unit Unit1;
interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  AppEvnts, Menus, ActnList, ZipForge, CheckLst,
  uMD3, uMDM,uMDX, uMDS, uCollapseMap, uMS3D, uMap, uASE,
  u3DTypes, uOpenGL, uFont, uQ3Shaders, Buttons, Spin, ImgList;

const
  MSG_MD3_LOADED = 'MD3 loaded';
  MSG_MDMMDX_LOADED = 'MDM/MDX loaded';
  MSG_MDM_LOADED = 'MDM loaded';
  MSG_MDX_LOADED = 'MDX loaded';
  MSG_MDX_BONES_LOADED = 'MDX bones loaded';
  MSG_MDX_FRAMES_LOADED = 'MDX frames loaded';
  MSG_MDX_TAGS_LOADED = 'MDX tags loaded';
  MSG_MDS_LOADED = 'MDS loaded and converted to MDM/MDX';
  MSG_MAP_LOADED = 'MAP loaded and converted to MD3';
  MSG_SKIN_LOADED = 'Skin loaded';
  MSG_MS3D_LOADED_MD3 = 'MS3D loaded and converted to MD3';
  MSG_MS3D_LOADED_MDMMDX = 'MS3D loaded and converted to MDM/MDX';
  MSG_ASE_LOADED = 'ASE loaded and converted to MD3';

type
  {TLoadedFrom = (lfNone, lfGame, lfPK3, lfFile);} // verplaatst naar unit uQ3Shaders
  TLoadedType = (ltNone,
                 ltMD3, ltMap, ltASE, ltMS3D_MD3,
                 ltMDMMDX, ltMDS, ltMS3D_MDMMDX,
                 ltMDC, ltASC, lt3DS, ltOBJ,
                 ltTag, ltSkin, ltShader);
{
  // tbv de PAKs combobox objecten
  TStrObject = class(TObject)
  public
    FullPath,
    ShortName,
    TmpDir: string;
    hasTextures,
    hasShaders,
    hasModels: boolean;
  end;
}
  TForm1 = class(TForm)
    gbModel: TGroupBox;
    OpenDialog: TOpenDialog;
    TagOpenDialog: TOpenDialog;
    StatusBar: TStatusBar;
    pcTabs: TPageControl;
    tabGeneral: TTabSheet;
    leName: TLabeledEdit;
    tabAnimation: TTabSheet;
    cbNamesFrames: TComboBox;
    leNumFrames: TLabeledEdit;
    gbCopyFrames: TGroupBox;
    leModelFilename: TLabeledEdit;
    bModelFilename: TButton;
    tabTags: TTabSheet;
    Label1: TLabel;
    leNumTags: TLabeledEdit;
    cbNamesTags: TComboBox;
    cbTagOrigins: TComboBox;
    gbInsertTags: TGroupBox;
    leTagFilename: TLabeledEdit;
    bTagFilename: TButton;
    tabSurfaces: TTabSheet;
    cbNamesSurfaces: TComboBox;
    leNumSurfaces: TLabeledEdit;
    cbNamesShaders: TComboBox;
    leNumShaders: TLabeledEdit;
    tabView: TTabSheet;
    gbOGL: TGroupBox;
    cbTagAxis: TComboBox;
    Label2: TLabel;
    gbTagManually: TGroupBox;
    leTagOriginX: TLabeledEdit;
    leTagOriginY: TLabeledEdit;
    leTagOriginZ: TLabeledEdit;
    bTagAddManually: TButton;
    leTagName: TLabeledEdit;
    cbBBMinFrames: TComboBox;
    cbBBMaxFrames: TComboBox;
    cbOriginFrames: TComboBox;
    cbRadiusFrames: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    leNumVerts: TLabeledEdit;
    leNumTriangles: TLabeledEdit;
    cbTagFrameNr: TComboBox;
    Label9: TLabel;
    SaveAsDialog: TSaveDialog;
    gbOGLtris: TGroupBox;
    ApplicationEvents: TApplicationEvents;
    TimerFPS: TTimer;
    Shape1: TShape;
    Shape4: TShape;
    shapeShaderFile: TShape;
    MainMenu: TMainMenu;
    menuFile: TMenuItem;
    menuFileLoad: TMenuItem;
    menuFileSave: TMenuItem;
    menuFileExit: TMenuItem;
    menuModel: TMenuItem;
    menuModelClear: TMenuItem;
    menuModelAnimation: TMenuItem;
    menuModelTags: TMenuItem;
    menuModelSurfaces: TMenuItem;
    menuModelSurfacesChangeshadername: TMenuItem;
    menuView: TMenuItem;
    menuViewLighting: TMenuItem;
    menuSettings: TMenuItem;
    N2: TMenuItem;
    menuModelSurfacesChangesurfacename: TMenuItem;
    menuSettingsGamedir: TMenuItem;
    gbSettings: TGroupBox;
    cbLightingEnabled: TCheckBox;
    gbShaderFile: TGroupBox;
    Label14: TLabel;
    cbShaderFile: TComboBox;
    menuFileLoadfrompk3: TMenuItem;
    gbTextures: TGroupBox;
    Label12: TLabel;
    lNumTextures: TLabel;
    cbShaderTextures: TComboBox;
    Zip: TZipForge;
    gbSkin: TGroupBox;
    leSkinFile: TLabeledEdit;
    SkinOpenDialog: TOpenDialog;
    N4: TMenuItem;
    menuFileSkin: TMenuItem;
    menuFileSkinLoad: TMenuItem;
    menuFileSkinLoadfrompk3: TMenuItem;
    menuModelSkinClear: TMenuItem;
    N5: TMenuItem;
    shapeShaderTexture: TShape;
    shapeSkinTexture: TShape;
    shapeSkinFile: TLabel;
    shapeShaderFileOut: TLabel;
    shapeShaderFileIn: TLabel;
    shapeTextureFile: TShape;
    shapeSkinShader: TShape;
    leSkin: TLabeledEdit;
    cbShowTags: TCheckBox;
    menuViewShowtags: TMenuItem;
    cbHasAlpha: TCheckBox;
    pShaderProps: TPanel;
    leCull: TLabeledEdit;
    cbAlphaFunc: TCheckBox;
    cbEnvironmentMap: TCheckBox;
    cbClamped: TCheckBox;
    Panel1: TPanel;
    Panel2: TPanel;
    gbAnimationControls: TGroupBox;
    Panel3: TPanel;
    gbViewOptions: TGroupBox;
    cbTagPivots: TComboBox;
    ShaderOpenDialog: TOpenDialog;
    N6: TMenuItem;
    menuFileShaderlist: TMenuItem;
    menuFileShaderlistAdd: TMenuItem;
    menuFileShaderlistClear: TMenuItem;
    menuHelp: TMenuItem;
    menuFileLoadfrommappk3: TMenuItem;
    tabHelp: TTabSheet;
    MemoHelp: TMemo;
    menuViewGammaSW: TMenuItem;
    menuViewGammaSW1: TMenuItem;
    menuViewGammaSW1_5: TMenuItem;
    menuViewGammaSW2: TMenuItem;
    menuViewGammaSW2_5: TMenuItem;
    menuViewGammaSW3: TMenuItem;
    menuViewGammaSW3_5: TMenuItem;
    menuViewGammaSW4: TMenuItem;
    menuViewGammaSW4_5: TMenuItem;
    menuViewGammaSW5: TMenuItem;
    gbShaderList: TGroupBox;
    Label7: TLabel;
    cbShaderList: TComboBox;
    Label10: TLabel;
    N9: TMenuItem;
    N3: TMenuItem;
    cbShaderNameFound: TComboBox;
    Label11: TLabel;
    shapeSkinShaderlist: TShape;
    shapeShaderlistIn: TLabel;
    shapeShaderlistOut: TLabel;
    shapeShaderlistShader: TShape;
    shapeShaderlistTexture: TShape;
    shapeShaderlist: TShape;
    img3DView: TImage;
    Label13: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    cbAnimMap: TCheckBox;
    Label20: TLabel;
    Label21: TLabel;
    cbVideoMap: TCheckBox;
    shapeSurfaceShader: TShape;
    leSurfaceFlags: TLabeledEdit;
    gbHeader: TGroupBox;
    leHeaderFlags: TLabeledEdit;
    leHeaderIdent: TLabeledEdit;
    leVersion: TLabeledEdit;
    leHeaderName: TLabeledEdit;
    menuModelAnimationAddframe: TMenuItem;
    cbCleanUp: TCheckBox;
    ActionList: TActionList;
    actionViewLighting: TAction;
    actionModelClear: TAction;
    actionFileLoadfrompk3: TAction;
    actionFileLoad: TAction;
    actionFileSaveAs: TAction;
    actionFileExit: TAction;
    actionSettingsGamedir: TAction;
    actionFileSelectSkin: TAction;
    actionFileClearSkin: TAction;
    actionFileSelectSkinfrompk3: TAction;
    actionViewShowtags: TAction;
    actionFileAddtoshaderlist: TAction;
    actionFileClearshaderlist: TAction;
    actionHelp: TAction;
    actionFileLoadfrommappk3: TAction;
    actionFileAddframe: TAction;
    actionModelDeleteframe: TAction;
    menuModelAnimationDelframe: TMenuItem;
    N7: TMenuItem;
    menuFileLoadfromgameMDMMDX: TMenuItem;
    TabBones: TTabSheet;
    tvBones: TTreeView;
    actionModelMDMMDXframesToMD3: TAction;
    menuFileExportFramesrangeToMD3: TMenuItem;
    cbShowSkeleton: TCheckBox;
    actionFileLoadfromgameMDMMDX: TAction;
    actionFileLoadMDMMDX: TAction;
    menuFileLoadMDMMDX: TMenuItem;
    MDMOpenDialog: TOpenDialog;
    MDXOpenDialog: TOpenDialog;
    MDSOpenDialog: TOpenDialog;
    actionFileLoadMDS: TAction;
    menuFileLoadMDS: TMenuItem;
    N11: TMenuItem;
    bSelectSkinfrompk3: TBitBtn;
    bSelectSkin: TBitBtn;
    bClearSkin: TBitBtn;
    bSelectShaderFile: TBitBtn;
    bClearShaderList: TBitBtn;
    bAddGamePAK: TBitBtn;
    Label22: TLabel;
    actionModelMDMMDXCalculateLOD: TAction;
    menuModelCalcLOD: TMenuItem;
    Panel4: TPanel;
    gbLOD: TGroupBox;
    cbLODEnabled: TCheckBox;
    tbLODMinimum: TTrackBar;
    Label23: TLabel;
    seLODSurfaceNr: TSpinEdit;
    Label24: TLabel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Label15: TLabel;
    Label16: TLabel;
    tbStartFrame: TTrackBar;
    tbCurrentFrame: TTrackBar;
    tbEndFrame: TTrackBar;
    lEndFrame: TLabel;
    lCurrentFrame: TLabel;
    lStartFrame: TLabel;
    cbPlay: TCheckBox;
    cbLoop: TCheckBox;
    Label17: TLabel;
    eFPS: TEdit;
    udFPS: TUpDown;
    tLODpresence: TLabel;
    N12: TMenuItem;
    menuModelAnimationAddframesSequence: TMenuItem;
    cbAnimName: TComboBox;
    tLODSurfacename: TLabel;
    actionModelMDMMDXScaleBones: TAction;
    menuModelScaleskeleton: TMenuItem;
    menuViewSkycolors: TMenuItem;
    menuViewShowskybox: TMenuItem;
    menuViewSkycolortop: TMenuItem;
    menuViewSkycolorbottom: TMenuItem;
    ImageList: TImageList;
    ColorDialog: TColorDialog;
    actionFileAddframesequence: TAction;
    OpenDialogMD3s: TOpenDialog;
    menuTexturing: TMenuItem;
    MDXSaveDialog: TSaveDialog;
    actionFileLoadMDX: TAction;
    menuFileLoadMDX: TMenuItem;
    actionModelMD3Scale: TAction;
    menuModelScalemd3: TMenuItem;
    actionFileLoadMDXbones: TAction;
    menuFileLoadMDXbones: TMenuItem;
    actionModelSkinpermanent: TAction;
    menuSkinToModel: TMenuItem;
    N1: TMenuItem;
    actionModelMDMMDXRenameBones: TAction;
    menuModelBones: TMenuItem;
    menuModelBonesDefaultNames: TMenuItem;
    actionFileLoadMDMtags: TAction;
    menuFileLoadMDMtags: TMenuItem;
    actionFileLoadMDXframes: TAction;
    menuFileLoadMDXframes: TMenuItem;
    MS3DOpenDialog: TOpenDialog;
    actionFileLoadMS3D: TAction;
    N8: TMenuItem;
    menuFileLoadMS3D: TMenuItem;
    N15: TMenuItem;
    actionFileAddframes: TAction;
    menuModelAnimationAddframes: TMenuItem;
    cbLockView: TCheckBox;
    bPrtScr: TButton;
    menuTools: TMenuItem;
    menuToolsColorconvert: TMenuItem;
    menuToolsColorconvertRadiant: TMenuItem;
    actionFileImportMapAsMD3: TAction;
    menuFileImportMapAsMD3: TMenuItem;
    MapOpenDialog: TOpenDialog;
    N14: TMenuItem;
    menuFileLoadAnyFromGame: TMenuItem;
    menuFileLoadAnyFromPK3: TMenuItem;
    menuFileLoadAnyFromFile: TMenuItem;
    OpenDialogAnyFromFile: TOpenDialog;
    actionFileLoadAnyFromFile: TAction;
    cbAlphaPreview: TCheckBox;
    leTextureDimensions: TLabeledEdit;
    actionViewShowalphapreview: TAction;
    menuViewShowAlphapreview: TMenuItem;
    actionViewShowskeleton: TAction;
    menuViewShowskeleton: TMenuItem;
    actionSettingsCleanup: TAction;
    menuSettingsCleanup: TMenuItem;
    menuModelTagsInvertX: TMenuItem;
    menuModelTagsInvertY: TMenuItem;
    menuModelTagsInvertZ: TMenuItem;
    menuModelTagsSwapXY: TMenuItem;
    menuModelTagsSwapXZ: TMenuItem;
    menuModelTagsSwapYZ: TMenuItem;
    cbCenterModel: TCheckBox;
    N16: TMenuItem;
    actionFileSaveMDX: TAction;
    actionFileSaveMDM: TAction;
    Label26: TLabel;
    N17: TMenuItem;
    menuModelMD3FlipZ: TMenuItem;
    N19: TMenuItem;
    actionModelMD3FlipZ: TAction;
    actionModelMD3FlipNormals: TAction;
    menuModelMD3FlipNormals: TMenuItem;
    actionModelMD3FlipX: TAction;
    actionModelMD3FlipY: TAction;
    menuModelMD3FlipX: TMenuItem;
    menuModelMD3FlipY: TMenuItem;
    cbShowNormals: TCheckBox;
    actionModelMD3FixCracksGaps: TAction;
    actionModelMD3SmoothSurface: TAction;
    N20: TMenuItem;
    menuModelMD3Fixcracksgaps: TMenuItem;
    menuModelSmoothSurface: TMenuItem;
    actionModelMD3TagAsOrigin: TAction;
    menuModelMD3TagAsOrigin: TMenuItem;
    actionViewCenterModel: TAction;
    menuViewCenterModel: TMenuItem;
    actionModelMD3RotateX: TAction;
    actionModelMD3RotateY: TAction;
    actionModelMD3RotateZ: TAction;
    menuModelRotateX: TMenuItem;
    menuModelRotateY: TMenuItem;
    menuModelRotateZ: TMenuItem;
    N22: TMenuItem;
    gbTagSave: TGroupBox;
    bSaveTags: TButton;
    actionModelMD3FlipWinding: TAction;
    menuModelMD3FlipWinding: TMenuItem;
    cbWireframe: TCheckBox;
    actionViewWireframe: TAction;
    cbTwoSided: TCheckBox;
    actionViewTwoSided: TAction;
    cbSmoothFlat: TCheckBox;
    actionViewSmoothFlat: TAction;
    actionFileLoadASE: TAction;
    menuFileLoadASE: TMenuItem;
    ASEOpenDialog: TOpenDialog;
    cbMouseControl: TCheckBox;
    actionViewMouseControl: TAction;
    menuViewWireFrame: TMenuItem;
    menuViewTwoSided: TMenuItem;
    menuViewFlatShading: TMenuItem;
    menuViewMouseControl: TMenuItem;
    N10: TMenuItem;
    TimerOGLFPS: TTimer;
    cbPAKsList: TComboBox;
    Label25: TLabel;
    PK3OpenDialog: TOpenDialog;
    bDelGamePAK: TBitBtn;
    actionModelCalculateNormals: TAction;
    menuModelCalcNormals: TMenuItem;
    actionModelMDMMDXSmoothSurface: TAction;
    Label27: TLabel;
    Label28: TLabel;
    eTagAxis0X: TEdit;
    eTagAxis0Z: TEdit;
    eTagAxis0Y: TEdit;
    eTagAxis1Z: TEdit;
    eTagAxis1Y: TEdit;
    eTagAxis1X: TEdit;
    eTagAxis2Z: TEdit;
    eTagAxis2Y: TEdit;
    eTagAxis2X: TEdit;
    cbShowGroundplane: TCheckBox;
    cbShowAxis: TCheckBox;
    menuViewShowNormals: TMenuItem;
    menuViewShowGroundplane: TMenuItem;
    menuViewShowAxis: TMenuItem;
    actionViewGroundplane: TAction;
    actionViewAxis: TAction;
    menuModelSurfacesSwapUVST: TMenuItem;
    N13: TMenuItem;
    actionModelMD3SwapUVST: TAction;
    actionModelMD3RemoveSurface: TAction;
    menumodelsurfaceRemove: TMenuItem;
    menuModelSurfacesCompact: TMenuItem;
    actionModelMD3SurfacesCompact: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure TimerFPSTimer(Sender: TObject);
    procedure cbNamesSurfacesChange(Sender: TObject);
    procedure bTagFilenameClick(Sender: TObject);
    procedure cbNamesTagsSelect(Sender: TObject);
    procedure cbTagOriginsSelect(Sender: TObject);
    procedure cbNamesShadersKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbTagAxisSelect(Sender: TObject);
    procedure bTagAddManuallyClick(Sender: TObject);
    procedure cbNamesFramesSelect(Sender: TObject);
    procedure cbBBMinFramesSelect(Sender: TObject);
    procedure cbBBMaxFramesSelect(Sender: TObject);
    procedure cbOriginFramesSelect(Sender: TObject);
    procedure cbRadiusFramesSelect(Sender: TObject);
    procedure cbTagFrameNrSelect(Sender: TObject);
    procedure gbOGLMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure tbStartFrameChange(Sender: TObject);
    procedure tbEndFrameChange(Sender: TObject);
    procedure eFPSChange(Sender: TObject);
    procedure tbCurrentFrameChange(Sender: TObject);
    procedure pcTabsChange(Sender: TObject);
    procedure actionViewLightingExecute(Sender: TObject);
    procedure actionModelClearExecute(Sender: TObject);
    procedure actionFileLoadExecute(Sender: TObject);
    procedure actionFileSaveAsExecute(Sender: TObject);
    procedure actionFileExitExecute(Sender: TObject);
    procedure actionSettingsGamedirExecute(Sender: TObject);
    procedure actionFileLoadfrompk3Execute(Sender: TObject);
    procedure actionFileSelectSkinExecute(Sender: TObject);
    procedure actionFileClearSkinExecute(Sender: TObject);
    procedure actionFileSelectSkinfrompk3Execute(Sender: TObject);
    procedure actionViewShowtagsExecute(Sender: TObject);
    procedure cbShaderTexturesChange(Sender: TObject);
    procedure gbOGLDblClick(Sender: TObject);
    procedure cbTagPivotsChange(Sender: TObject);
    procedure actionFileAddtoshaderlistExecute(Sender: TObject);
    procedure actionFileClearshaderlistExecute(Sender: TObject);
    procedure actionFileLoadfrommappk3Execute(Sender: TObject);
    procedure actionHelpExecute(Sender: TObject);
    procedure MemoHelpClick(Sender: TObject);
    procedure menuViewGammaSW1Click(Sender: TObject);
    procedure menuViewGammaSW1_5Click(Sender: TObject);
    procedure menuViewGammaSW2Click(Sender: TObject);
    procedure menuViewGammaSW2_5Click(Sender: TObject);
    procedure menuViewGammaSW3Click(Sender: TObject);
    procedure menuViewGammaSW3_5Click(Sender: TObject);
    procedure menuViewGammaSW4Click(Sender: TObject);
    procedure menuViewGammaSW4_5Click(Sender: TObject);
    procedure menuViewGammaSW5Click(Sender: TObject);
    procedure actionFileAddframeExecute(Sender: TObject);
    procedure actionModelDeleteframeExecute(Sender: TObject);
    procedure ApplicationEventsActivate(Sender: TObject);
    procedure actionFileLoadfromgameMDMMDXExecute(Sender: TObject);
    procedure actionModelMDMMDXframesToMD3Execute(Sender: TObject);
    procedure actionFileLoadMDMMDXExecute(Sender: TObject);
    procedure actionFileLoadMDSExecute(Sender: TObject);
    procedure tbLODMinimumChange(Sender: TObject);
    procedure actionModelMDMMDXCalculateLODExecute(Sender: TObject);
    procedure cbLODEnabledClick(Sender: TObject);
    procedure cbAnimNameChange(Sender: TObject);
    procedure seLODSurfaceNrChange(Sender: TObject);
    procedure actionModelMDMMDXScaleBonesExecute(Sender: TObject);
    procedure menuViewShowskyboxClick(Sender: TObject);
    procedure menuViewSkycolortopAdvancedDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
    procedure menuViewSkycolorbottomAdvancedDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
    procedure menuViewSkycolortopClick(Sender: TObject);
    procedure menuViewSkycolorbottomClick(Sender: TObject);
    procedure menuToolsColorconvertRadiantAdvancedDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
    procedure menuToolsColorconvertRadiantClick(Sender: TObject);
    procedure actionFileAddframesequenceExecute(Sender: TObject);
    procedure actionFileLoadMDXExecute(Sender: TObject);
    procedure actionModelMD3ScaleExecute(Sender: TObject);
    procedure actionFileLoadMDXbonesExecute(Sender: TObject);
    procedure actionModelSkinpermanentExecute(Sender: TObject);
    procedure actionModelMDMMDXRenameBonesExecute(Sender: TObject);
    procedure actionFileLoadMDMtagsExecute(Sender: TObject);
    procedure actionFileLoadMDXframesExecute(Sender: TObject);
    procedure actionFileLoadMS3DExecute(Sender: TObject);
    procedure actionFileAddframesExecute(Sender: TObject);
    procedure bPrtScrClick(Sender: TObject);
    procedure actionFileImportMapAsMD3Execute(Sender: TObject);
    procedure cbPlayClick(Sender: TObject);
    procedure actionFileLoadAnyFromFileExecute(Sender: TObject);
    procedure actionViewShowalphapreviewExecute(Sender: TObject);
    procedure actionViewShowskeletonExecute(Sender: TObject);
    procedure actionSettingsCleanupExecute(Sender: TObject);
    procedure menuModelTagsInvertXClick(Sender: TObject);
    procedure menuModelTagsInvertYClick(Sender: TObject);
    procedure menuModelTagsInvertZClick(Sender: TObject);
    procedure menuModelTagsSwapXYClick(Sender: TObject);
    procedure menuModelTagsSwapXZClick(Sender: TObject);
    procedure menuModelTagsSwapYZClick(Sender: TObject);
    procedure actionFileSaveMDXExecute(Sender: TObject);
    procedure actionFileSaveMDMExecute(Sender: TObject);
    procedure lStartFrameDblClick(Sender: TObject);
    procedure lEndFrameDblClick(Sender: TObject);
    procedure lCurrentFrameDblClick(Sender: TObject);
    procedure actionModelMD3FlipZExecute(Sender: TObject);
    procedure actionModelMD3FlipNormalsExecute(Sender: TObject);
    procedure actionModelMD3FlipXExecute(Sender: TObject);
    procedure actionModelMD3FlipYExecute(Sender: TObject);
    procedure actionModelMD3FixCracksGapsExecute(Sender: TObject);
    procedure actionModelMD3SmoothSurfaceExecute(Sender: TObject);
    procedure actionModelMD3TagAsOriginExecute(Sender: TObject);
    procedure actionViewCenterModelExecute(Sender: TObject);
    procedure actionModelMD3RotateXExecute(Sender: TObject);
    procedure actionModelMD3RotateYExecute(Sender: TObject);
    procedure actionModelMD3RotateZExecute(Sender: TObject);
    procedure bSaveTagsClick(Sender: TObject);
    procedure actionModelMD3FlipWindingExecute(Sender: TObject);
    procedure actionViewWireframeExecute(Sender: TObject);
    procedure actionViewTwoSidedExecute(Sender: TObject);
    procedure actionViewSmoothFlatExecute(Sender: TObject);
    procedure actionFileLoadASEExecute(Sender: TObject);
    procedure cbNamesSurfacesSelect(Sender: TObject);
    procedure cbNamesSurfacesKeyDown(Sender:TObject; var Key:Word; Shift:TShiftState);
    procedure actionViewMouseControlExecute(Sender: TObject);
    procedure TimerOGLFPSTimer(Sender: TObject);
    procedure bAddGamePAKClick(Sender: TObject);
    procedure cbPAKsListSelect(Sender: TObject);
    procedure bDelGamePAKClick(Sender: TObject);
    procedure actionModelCalculateNormalsExecute(Sender: TObject);
    procedure actionModelMDMMDXSmoothSurfaceExecute(Sender: TObject);
    procedure menuModelSmoothSurfaceClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure actionViewGroundplaneExecute(Sender: TObject);
    procedure actionViewAxisExecute(Sender: TObject);
    procedure actionModelMD3SwapUVSTExecute(Sender: TObject);
    procedure actionModelMD3RemoveSurfaceExecute(Sender: TObject);
    procedure actionModelMD3SurfacesCompactExecute(Sender: TObject);
(*
  protected
    procedure CreateParams(var Params: TCreateParams); override;
*)
  private
    TotalGameShaders,                 //totaal aantal shaders in alle shaderfiles in gamedir/etmain/scripts
    TotalGameShaderFiles: integer;    //totaal aantal shaderfiles in gamedir/etmain/scripts
    ShaderResource: TTextureResource;
    LastX, LastY: Integer;            //vorige muiscursor-positie
    DeltaX, DeltaY, DeltaZ: Single;   //laatste verschillen in cursor-positie.
    Model_Matrix: TMatrix4x4;
    Model_Rotation,                   //verdraaid goed..
    Model_Position,                   //op de plaats rust..
    Model_Offset: TVector;            //pivot-offset
    Current_Frame: integer;
    ZoomDistance: integer;
{    OGL: TOGL;   // tab view}
    MaxTU: integer;
    Gamma: Single;
    CenterX,CenterY,CenterZ: Single;
    SkyColorTop, SkyColorBottom, ConvertColor: TColor;
    ModelIsScaled: boolean;
    HeadModel: TMD3;
    TakingScreenshot,
    InterruptPlayback,
    IsDragDropped: boolean;
    tmpSurfaceIndex: integer;
    //
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    //
    procedure OGL_MDMMDX_RenderFrame;
    procedure OGL_MD3_RenderFrame;
    procedure OGL_RenderFrame;
    procedure OGL_CreateTextures;
    procedure InitLighting;
    procedure DeleteTextures;
    //
    function DelTree(DirName : string): Boolean;
    procedure SetHWGamma(Gamma: Single);
    //
    procedure SetupAnimation;
    procedure ResetModelTransform;
    procedure AutoZoom;
    //
    procedure ClearGameShaders;
    procedure LoadGameShaders;
    procedure ClearMapShaders;
    procedure LoadMapShaders;
    procedure ClearShaderListShaders;
    procedure LoadShaderListShaders;
    function FindShaders(const ShaderResource: TTextureResource; const sIndex: integer) : boolean;
    procedure LoadSkinFile(Filename:string; DoUpdateShaders:boolean=true);
    procedure UpdateShaders;
    procedure UpdateGamma;
    //
    procedure ClearMD3Info;
    procedure ShowMD3HeaderInfo;
    procedure ShowMD3FramesInfo;
    procedure ShowMD3TagsInfo;
    procedure ShowMD3SurfacesInfo;
    procedure ShowMD3Info;
    procedure TagPivotMD3;
    //
    procedure ClearMDMMDXInfo;
    procedure ShowMDMMDXBoneInfo;
    procedure ShowMDMMDXTagsInfo;
    procedure ShowMDMMDXSurfaceInfo;
    procedure ShowMDMMDXInfo;
    procedure TagPivotMDMMDX;
    //
    procedure SurfaceToForm(Index: integer); //Index in cbNamesSurfaces
    procedure TextureToForm(SurfaceIndex, TextureIndex: integer);
    procedure ShaderToTextureGraph(const Value: TTextureResource); //Value="Texture komt uit": shader-, texture- of skin-file
    procedure TextureToImg(SurfaceIndex, TextureIndex: integer);
    procedure Screenshot(TransparentBackground:boolean);
    procedure SetGameDir(const Path: string);
    procedure ReadINI;
    procedure WriteINI;
    procedure ShowHelp;
    procedure HideHelp;
    procedure ShowTabsNone;
    procedure ShowTabsMD3;
    procedure ShowTabsMDMMDX;
    procedure ShowMenuNone;
    procedure ShowMenuMD3;
    procedure ShowMenuMDMMDX;
    procedure ShowNone;
    //
    procedure LoadHeadModel;
    //
    function AddPAK(Filename:string) : integer;
    function DeletePAK(Index:integer) : boolean;
    procedure DeletePAKsList;
  public
    LoadedFrom: TLoadedFrom; //(lfGame, lfPK3, lfFile)
    LoadedType: TLoadedType; //(ltMD3, ltMDMMDX, ltMS3D, ltMDS, ltMDC, ltASE, ltASC, lt3DS, ltOBJ)
    AppPath,                          //pad naar App.exe
    GameDir,                          //pad naar game-directory
    TmpDir,                           //pad naar temp. dir.
    ModelDir: string;                 //pad naar laatst geladen model
    {PAKsList: array of TStrObject;}
    procedure AcceptFiles(var msg:TMessage); message WM_DROPFILES;
    function FileInUse(FileName: string): Boolean;
  end;

var
  Form1: TForm1;

(*
//test
procedure SaveData(SurfaceNr:integer; Filename:string);
*)

implementation
uses uConst, uCalc, OpenGL, uTexture,
     StrUtils, FileCtrl, ShellAPI, IniFiles, Math,
     Unit2;
{$R *.dfm}

(*
procedure TForm1.CreateParams(var Params: TCreateParams);
// CS_DROPSHADOW = $00020000;
var Mask: cardinal;
begin
  inherited;
  Mask := (CS_DROPSHADOW xor $FFFFFFFF);
  Params.WindowClass.Style := (Params.WindowClass.Style and Mask);
end;
*)

procedure TForm1.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;  //form achtergrond paint-event als "klaar" markeren..
end;


procedure TForm1.FormCreate(Sender: TObject);
var sa: SECURITY_ATTRIBUTES;
    s: PAnsiChar;
    gp: integer;
//hprocessID, processHandle: cardinal;
begin
//GetWindowThreadProcessID(Form1.Handle, @hprocessID);
//processHandle := OpenProcess({PROCESS_TERMINATE or PROCESS_QUERY_INFORMATION}PROCESS_SET_INFORMATION, false, hprocessID);
//SetProcessAffinityMask(processHandle, 2);

  // objecten
  HeadModel := TMD3.Create;
  //
  DecimalSeparator := '.';
  Application.ShowHint := true;
  AppPath := ExtractFilePath(Application.ExeName);
  // controleer of de app. wel is geïnstalleerd in zijn eigen directory
  if not DirectoryExists(AppPath+'textures') then begin
    ShowMessage('This application is not installed correctly.'#13#10'Copy the .exe and the subdirectory "textures" into its own directory');
    PostQuitMessage(1);
  end;
  //
  GameDir := '';
  ModelDir := '';

  // een tijdelijke dir. maken tbv. unzippen pk3's
  s := PChar(AppPath +'tmp\');
  if not DirectoryExists(s) then begin
    sa.nLength := SizeOf(SECURITY_ATTRIBUTES);
    sa.lpSecurityDescriptor := nil;
    sa.bInheritHandle := false;
    CreateDirectory(s,@sa);
  end;
  TmpDir := string(s);
  Zip.TempDir := TmpDir;
(*
  DelTree(TmpDir);
*)
  // een tijdelijke map maken tbv. unzippen map.pk3's
  s := PChar(AppPath +'tmp\tmpmap');
  if not DirectoryExists(s) then begin
    sa.nLength := SizeOf(SECURITY_ATTRIBUTES);
    sa.lpSecurityDescriptor := nil;
    sa.bInheritHandle := false;
    Createdirectory(s,@sa);
  end;


  Gamma := 1.0;   //[0.0 .. maxfloat]
  SkyColorTop := $00CB8B64; //clHotLight;
  SkyColorBottom := $00F0CAA6; //clSkyBlue;
  // INI lezen
  ReadINI;

  // controleer of de pak0.pk3 al in gebruik is, zoja: afbreken..
//  if GameDir<>'' then
    for gp:=0 to Length(PAKsList)-1 do
//      if FileInUse(GameDir+'etmain\pak0.pk3') then begin
      if FileInUse(PAKsList[gp].FullPath) then begin
        ShowMessage('The game-files are already in use by another application.'#13#10'This tool will halt..');
        {Assert(false);}
        Application.Terminate;
        PostQuitMessage(1);
        Exit;
      end;

  ConvertColor := $00000000;
{  gbOGLtris.Color := Form1.Color; //$00E3DFE0;}

  // een tijdelijke dir. maken tbv. unzippen game-pack's
  for gp:=0 to Length(PAKsList)-1 do begin
    s := PChar(PAKsList[gp].TmpDir);
    if not DirectoryExists(s) then begin
      sa.nLength := SizeOf(SECURITY_ATTRIBUTES);
      sa.lpSecurityDescriptor := nil;
      sa.bInheritHandle := false;
      CreateDirectory(s,@sa);
    end;
  end;


//  SendMessage(tbStartFrame.Handle, PBM_SETBARCOLOR, 0, clBlue);

  // tell Windows that you're accepting drag and drop files
  DragAcceptFiles(Handle, True);

  // tbv. tijdelijke onderbrekingen, zoals tijdens laden, afbeelden dialogs..
  InterruptPlayback := false;
  // de timer
  TimerFPS.Interval := Round(1/20*1000);
   //
  LoadedFrom := lfNone;
  LoadedType := ltNone;
  ModelIsScaled := false;
  // de shaderlist
  LoadShaderListShaders;
  //
  Current_Frame := 0;
  ZoomDistance := 500;
  Model_Matrix := IdentityMatrix4x4;
  Model_Rotation := NullVector;
  Model_Position := NullVector;
  Model_Offset := NullVector;
  //
  tabGeneral.TabVisible := false;
  tabAnimation.TabVisible := false;
  tabTags.TabVisible := false;
  tabSurfaces.TabVisible := false;
  gbCopyFrames.Visible := false;
{!!!!!DEBUG!!!!!
  gbInsertTags.Visible := false;}
  gbInsertTags.Visible := true;
//bTagFilename.Enabled := false; //vooralsnog geen tags toevoegen uit een .tag-bestand..
  tbCurrentFrame.SelEnd := tbEndFrame.Position;
  ShaderToTextureGraph(trNone);

  menuViewSkycolors.Enabled := not menuViewShowskybox.Checked;
  ShowNone;

  // OpenGL objects
{  OGL := TOGL.Create;   // tab view}

  OGL.Textures.AddSearchDir(AppPath +'textures\BG\');
  OGL.Textures.AddSearchDir(AppPath +'textures\');
  OGL.Textures.AddSearchDir(AppPath);
  OGL.Textures.AddSearchDir(TmpDir);
  // de standaard camera gebruiken
  OGL.Camera.Default;
  OGL.Camera.Floating := false;
  //OGL.Camera.SetPositionY(20.0);

{  // hoofd model laden..
  LoadHeadModel;}
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  // OpenGL objects
  if not OGL.Active then begin
    OGL.Enable(gbOGL.Handle);

    MaxTU := OGL.GetMaxTextureUnits;

    // de camera wat bewegen, anders kan de speler niet rondsturen..
    OGL.Camera.Position := Vector(0,0,ZoomDistance);
    OGL.Camera.Target := Vector(0,0,0);
    OGL.Camera.Move(0.00001);
    OGL.Camera.Target := Vector(0,0,0); //inzoom bugfix
    // Vertical retrace aan
//    OGL.SetVSync(true);
    // SkyBox
    {OGL.SkyBox.Active := OGL.SkyBox.InitTextures('Terra');}
    {OGL.SkyBox.Active := OGL.SkyBox.InitTextures('sky2');}
    OGL.SkyBox.Active := OGL.SkyBox.InitTextures('sky');
    OGL.SkyBox.Active := menuViewShowskybox.Checked;

    InitLighting;

    // form bijwerken
    if GameDir<>'' then begin
      SetGameDir(GameDir);
      HideHelp;
    end else begin
      actionSettingsGamedirExecute(nil);
      ShowHelp;
    end;
    actionFileLoadfrompk3.Enabled := (GameDir<>'');
    actionFileSelectSkinfrompk3.Enabled := (GameDir<>'');

    // een beeld tekenen
    OGL_RenderFrame;
  end;
end;

procedure TForm1.ApplicationEventsActivate(Sender: TObject);
begin
  if Application.Terminated then Exit;
  {if not cbPlay.Checked then} OGL_RenderFrame;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  // OpenGL projectie
  OGL.Resize(gbOGL.Width, gbOGL.Height);
  // frame renderen
  if OGL.Active then begin
    //InitLighting;
    OGL_RenderFrame;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  // INI schrijven
  WriteINI;

  // OpenGL uitschakelen
  if OGL.Active then OGL.Disable;
(*
  // wis de TmpDir
  if cbCleanUp.Checked then begin
    StatusBar.SimpleText := 'Cleaning-up... Please wait';
{    pcTabs.ActivePage := TabHelp;
    MemoHelp.Lines.Clear;
    MemoHelp.Lines.Add('Cleaning-up... Please wait');}
    if DelTree(TmpDir) then RemoveDir(TmpDir);
  end;
*)
  // objecten
  HeadModel.Free;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  // OpenGL objects
{  OGL.Free;}

  // shaders verwijderen
  ClearGameShaders;
  ClearMapShaders;
  ClearShaderListShaders;
  // GAME-PAK referenties verwijderen
  DeletePAKsList;
end;


procedure TForm1.FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if (MousePos.X>gbOGL.ClientOrigin.X) and (MousePos.X<gbOGL.ClientOrigin.X+gbOGL.Width) and
     (MousePos.Y>gbOGL.ClientOrigin.Y) and (MousePos.Y<gbOGL.ClientOrigin.Y+gbOGL.Height) then begin
    if pcTabs.ActivePage <> tabView then Exit;
    if cbLockView.Checked then Exit;
    if ZoomDistance>=5000 then Exit;
    Inc(ZoomDistance, 5);
    OGL.Camera.Position := Vector(0,0,ZoomDistance);
    OGL_RenderFrame;
    Handled := true;
  end;
end;

procedure TForm1.FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if (MousePos.X>gbOGL.ClientOrigin.X) and (MousePos.X<gbOGL.ClientOrigin.X+gbOGL.Width) and
     (MousePos.Y>gbOGL.ClientOrigin.Y) and (MousePos.Y<gbOGL.ClientOrigin.Y+gbOGL.Height) then begin
    if pcTabs.ActivePage <> tabView then Exit;
    if cbLockView.Checked then Exit;
    if ZoomDistance<=10 then Exit;
    Dec(ZoomDistance, 5);
    OGL.Camera.Position := Vector(0,0,ZoomDistance);
    OGL_RenderFrame;
    Handled := true;
  end;
end;

procedure TForm1.gbOGLMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
var vX,vY: TVector;
    M1,M2,M3: TMatrix4x4;
    Q1,Q2: TQuaternion;
    Axis: TVector;
    Angle: single;
begin
  if pcTabs.ActivePage <> tabView then Exit;
  if cbLockView.Checked then Exit;
  DeltaX := (X - LastX)*2;
  DeltaY := (Y - LastY)*2;
  // rekening houden met de bewegings-gevoeligheid
  DeltaX := DeltaX * OGL.Camera.SensitivityX;
  DeltaY := DeltaY * OGL.Camera.SensitivityY;

  // muisknoppen controleren
  if (ssLeft in Shift) then begin
    // transleren of roteren??
    if (ssShift in Shift) then begin
      // schuiven
      vX := SubVector(OGL.Camera.NextStrafe_Position(-DeltaX), OGL.Camera.Position);
      vY := SubVector(OGL.Camera.NextStrafeUpDown_Position(-DeltaY), OGL.Camera.Position);
      Model_Position :=  AddVector(Model_Position, vX);
      Model_Position :=  AddVector(Model_Position, vY);
    end else
      if (ssCtrl in Shift) then begin
        // roteer de camera rond om zijn target
        OGL.Camera.RotateAboutTarget(Vector(DeltaY, DeltaX, 0.0));
//      Model_Offset := AddVector(Model_Offset, Vector(DeltaX, DeltaY, 0.0));
      end else begin
        // roteer model
        // control type 2
        M1 := MultiplyMatrix(MultiplyMatrix(XRotationMatrix(-DeltaY),YRotationMatrix(-DeltaX)),ZRotationMatrix(0));
        Model_Matrix := MultiplyMatrix(Model_Matrix, M1);
        // control type 1
        Model_Rotation := AddVector(Model_Rotation, Vector(DeltaY, DeltaX, 0.0));
        //
        OGL.Camera.Target := Vector(0,0,0);
      end;
  end else
    if (ssRight in Shift) then begin
      // roteer model
      // control type 2
      M1 := MultiplyMatrix(MultiplyMatrix(XRotationMatrix(DeltaX),YRotationMatrix(0)),ZRotationMatrix(-DeltaY));
      Model_Matrix := MultiplyMatrix(M1,Model_Matrix);
      // control type 1
      Model_Rotation := AddVector(Model_Rotation, Vector(0.0, DeltaX, -DeltaY));
      //
      OGL.Camera.Target := Vector(0,0,0);
    end;

  // laatste cursor-positie onthouden..
  LastX := X;
  LastY := Y;
end;

procedure TForm1.AcceptFiles(var msg: TMessage);
const cMaxFilenameLen = 255;
var FileCount, i: integer;
    FileName: array[0..cMaxFilenameLen] of char;
    FileName2: array[0..cMaxFilenameLen] of char;
    Extension: string;
begin
  StatusBar.SimpleText := '';
  try
    // find out how many files we're accepting
    FileCount := DragQueryFile(msg.WParam, $FFFFFFFF, FileName, cMaxFilenameLen);
{
    // query Windows one at a time for the file name
    for i := 0 to FileCount-1 do begin
      DragQueryFile(msg.WParam, i, FileName, cMaxFilenameLen);
      // do your thing with the acFileName
      MessageBox( Handle, FileName, '', MB_OK );
    end;
}
    DragQueryFile(msg.WParam, 0, FileName, cMaxFilenameLen);

    IsDragDropped := true;
    Extension := UpperCase(ExtractFileExt(Filename));
    if Extension='.MD3' then begin
      OpenDialog.FileName := Filename;
      actionFileLoadExecute(nil);
    end else
    if Extension='.MAP' then begin
      MapOpenDialog.FileName := Filename;
      actionFileImportMapAsMD3Execute(nil);
    end else
    if Extension='.ASE' then begin
      ASEOpenDialog.FileName := Filename;
      actionFileLoadASEExecute(nil);
    end else
    if Extension='.MDS' then begin
      MDSOpenDialog.FileName := Filename;
      actionFileLoadMDSExecute(nil);
    end else
    if (Extension='.MDM') and (FileCount=2) then begin
      DragQueryFile(msg.WParam, 1, FileName2, cMaxFilenameLen);
      Extension := UpperCase(ExtractFileExt(Filename2));
      if Extension='.MDX' then begin
        MDMOpenDialog.FileName := Filename;
        MDXOpenDialog.FileName := Filename2;
        actionFileLoadMDMMDXExecute(nil);
      end;
    end else
    if (Extension='.MDX') and (FileCount=2) then begin
      DragQueryFile(msg.WParam, 1, FileName2, cMaxFilenameLen);
      Extension := UpperCase(ExtractFileExt(Filename2));
      if Extension='.MDM' then begin
        MDXOpenDialog.FileName := Filename;
        MDMOpenDialog.FileName := Filename2;
        actionFileLoadMDMMDXExecute(nil);
      end;
    end else
    if ((Extension='.MDM') or (Extension='.MDX')) and (FileCount=1) then begin
      StatusBar.SimpleText := 'MDM/MDX files must both be drag''n''dropped at the same time..'
    end else
    if Extension='.MS3D' then begin
      MS3DOpenDialog.FileName := Filename;
      actionFileLoadMS3DExecute(nil);
    end else
    if Extension='.SKIN' then begin
      SkinOpenDialog.FileName := Filename;
      actionFileSelectSkinExecute(nil);
    end else
      StatusBar.SimpleText := 'Invalid filetype to drag''n''drop: '+ Extension;
    //  
    IsDragDropped := false;
  finally
    // let Windows know that you're done
    DragFinish(msg.WParam);
  end;
end;

procedure TForm1.gbOGLDblClick(Sender: TObject);
begin
  ResetModelTransform;
end;


procedure TForm1.pcTabsChange(Sender: TObject);
begin
  StatusBar.SetFocus; //gbOGL.SetFocus;
  if pcTabs.ActivePage = tabView then begin
{    timerFPS.Enabled := cbPlay.Checked;}
    OGL_RenderFrame;
  end{ else
    timerFPS.Enabled := false};
  if pcTabs.ActivePage = tabSurfaces then TextureToForm(cbNamesSurfaces.ItemIndex, cbShaderTextures.ItemIndex);
end;


procedure TForm1.cbNamesSurfacesChange(Sender: TObject);
begin
(*
  // de bijhorende shaders afbeelden
  SurfaceToForm(cbNamesSurfaces.ItemIndex);
*)
  if cbNamesSurfaces.ItemIndex = -1 then Exit;
  tmpSurfaceIndex := cbNamesSurfaces.ItemIndex;
end;

procedure TForm1.cbNamesSurfacesSelect(Sender: TObject);
begin
  tmpSurfaceIndex := -1;
  // de bijhorende shaders afbeelden
  SurfaceToForm(cbNamesSurfaces.ItemIndex);
end;

procedure TForm1.cbNamesSurfacesKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  if tmpSurfaceIndex=-1 then Exit;
  if Key<>VK_RETURN then Exit;
  // de naam van dit surface is aangepast
  case LoadedType of
    ltMD3,ltMap,ltASE,ltMS3D_MD3: begin
        if tmpSurfaceIndex <= MD3.Header.Values.Num_Surfaces then
          MD3.Header.Surfaces[tmpSurfaceIndex].Values.Name := MD3.StringToQ3(cbNamesSurfaces.Text);
        ShowMD3Info;
      end;
    ltMDMMDX,ltMDS,ltMS3D_MDMMDX: begin
        if tmpSurfaceIndex <= MDM.Header.Num_Surfaces then
          MDM.Surfaces[tmpSurfaceIndex].Values.SurfaceName := MD3.StringToQ3(cbNamesSurfaces.Text);
        ShowMDMMDXInfo;  
      end;
  end;
  cbNamesSurfaces.ItemIndex := tmpSurfaceIndex;
  tmpSurfaceIndex := -1;
  SurfaceToForm(cbNamesSurfaces.ItemIndex);
end;



procedure TForm1.bTagFilenameClick(Sender: TObject);
var Msg: string;
begin
  StatusBar.SimpleText := '';
  try
    // alleen non-animated MD3's komen in aanmerking..vooralsnog
    if MD3.Header.Values.Num_Frames<>1 then begin
      Msg := 'Invalid action: It is not possible to add tags for animated MD3 models';
      Exit;
    end;

    // Tags importeren
    if not TagOpenDialog.Execute then Exit;
    leTagFilename.Text := ExtractFilename(TagOpenDialog.FileName);
    MD3.AddTags(TagOpenDialog.FileName);
    Msg := 'New tag(s) added from file: '+ leTagFilename.Text;
    //
    gbModel.Caption := gbModel.Caption +'*';
    ShowMD3Info;
  finally
    StatusBar.SimpleText := Msg;
  end;
end;

procedure TForm1.bTagAddManuallyClick(Sender: TObject);
var aTag: TTag;
    x,y,z,
    axis0x,axis0y,axis0z,
    axis1x,axis1y,axis1z,
    axis2x,axis2y,axis2z: single;
    Msg: string;
begin
  StatusBar.SimpleText := '';
  try
    // alleen non-animated MD3's komen in aanmerking..vooralsnog
    if MD3.Header.Values.Num_Frames<>1 then begin
      Msg := 'Invalid action: It is not possible to add tags for animated MD3 models';
      Exit;
    end;

    aTag.Name := MD3.StringToQ3(leTagName.Text);
    Msg := 'New tag added';
    if not (TryStrToFloat(leTagOriginX.Text, x) and
            TryStrToFloat(leTagOriginY.Text, y) and
            TryStrToFloat(leTagOriginZ.Text, z) and

            TryStrToFloat(eTagAxis0X.Text, axis0x) and
            TryStrToFloat(eTagAxis0Y.Text, axis0y) and
            TryStrToFloat(eTagAxis0Z.Text, axis0z) and

            TryStrToFloat(eTagAxis1X.Text, axis1x) and
            TryStrToFloat(eTagAxis1Y.Text, axis1y) and
            TryStrToFloat(eTagAxis1Z.Text, axis1z) and

            TryStrToFloat(eTagAxis2X.Text, axis2x) and
            TryStrToFloat(eTagAxis2Y.Text, axis2y) and
            TryStrToFloat(eTagAxis2Z.Text, axis2z)) then begin
      Msg := 'Error converting user-input data';
      Exit;
    end;

    aTag.Origin.X := x;
    aTag.Origin.Y := y;
    aTag.Origin.Z := z;

    aTag.Axis[0].X := axis0x; //1.0;
    aTag.Axis[0].Y := axis0y; //0.0;
    aTag.Axis[0].Z := axis0z; //0.0;
    aTag.Axis[1].X := axis1x; //0.0;
    aTag.Axis[1].Y := axis1y; //1.0;
    aTag.Axis[1].Z := axis1z; //0.0;
    aTag.Axis[2].X := axis2x; //0.0;
    aTag.Axis[2].Y := axis2y; //0.0;
    aTag.Axis[2].Z := axis2z; //1.0;
    //
    MD3.AddTag(aTag);
    //
    gbModel.Caption := gbModel.Caption +'*';
    leTagName.Text := 'tag_';
    leTagOriginX.Text := '';
    leTagOriginY.Text := '';
    leTagOriginZ.Text := '';
    eTagAxis0X.Text := '1.0';
    eTagAxis0Y.Text := '0.0';
    eTagAxis0Z.Text := '0.0';
    eTagAxis1X.Text := '0.0';
    eTagAxis1Y.Text := '1.0';
    eTagAxis1Z.Text := '0.0';
    eTagAxis2X.Text := '0.0';
    eTagAxis2Y.Text := '0.0';
    eTagAxis2Z.Text := '1.0';

    ShowMD3Info;

  finally
    StatusBar.SimpleText := Msg;
  end;
end;

procedure TForm1.cbNamesTagsSelect(Sender: TObject);
begin
  cbTagOrigins.ItemIndex := cbTagFrameNr.ItemIndex * MD3.Header.Values.Num_Tags + cbNamesTags.ItemIndex;
  cbTagAxis.ItemIndex := cbTagFrameNr.ItemIndex * MD3.Header.Values.Num_Tags + cbNamesTags.ItemIndex;
end;

procedure TForm1.cbTagFrameNrSelect(Sender: TObject);
begin
  cbTagOrigins.ItemIndex := cbTagFrameNr.ItemIndex * MD3.Header.Values.Num_Tags + cbNamesTags.ItemIndex;
  cbTagAxis.ItemIndex := cbTagFrameNr.ItemIndex * MD3.Header.Values.Num_Tags + cbNamesTags.ItemIndex;
end;

procedure TForm1.cbTagOriginsSelect(Sender: TObject);
var f,t: cardinal;
begin
  // bepaal het huidige frameNr
  f := cbTagOrigins.ItemIndex div MD3.Header.Values.Num_Tags;
  // bepaal de huidige tag
  t := cbTagOrigins.ItemIndex mod MD3.Header.Values.Num_Tags;
  //
  cbNamesTags.ItemIndex := t;
  cbTagFrameNr.ItemIndex := f;
  cbTagAxis.ItemIndex := cbTagOrigins.ItemIndex;
end;

procedure TForm1.cbTagAxisSelect(Sender: TObject);
var f,t: cardinal;
begin
  // bepaal het huidige frameNr
  f := cbTagAxis.ItemIndex div MD3.Header.Values.Num_Tags;
  // bepaal de huidige tag
  t := cbTagAxis.ItemIndex mod MD3.Header.Values.Num_Tags;
  //
  cbNamesTags.ItemIndex := t;
  cbTagFrameNr.ItemIndex := f;
  cbTagOrigins.ItemIndex := cbTagAxis.ItemIndex;
end;

procedure TForm1.cbNamesFramesSelect(Sender: TObject);
begin
  cbBBMinFrames.ItemIndex := cbNamesFrames.ItemIndex;
  cbBBMaxFrames.ItemIndex := cbNamesFrames.ItemIndex;
  cbOriginFrames.ItemIndex := cbNamesFrames.ItemIndex;
  cbRadiusFrames.ItemIndex := cbNamesFrames.ItemIndex;
end;

procedure TForm1.cbBBMinFramesSelect(Sender: TObject);
begin
  cbNamesFrames.ItemIndex := cbBBMinFrames.ItemIndex;
  cbBBMaxFrames.ItemIndex := cbBBMinFrames.ItemIndex;
  cbOriginFrames.ItemIndex := cbBBMinFrames.ItemIndex;
  cbRadiusFrames.ItemIndex := cbBBMinFrames.ItemIndex;
end;

procedure TForm1.cbBBMaxFramesSelect(Sender: TObject);
begin
  cbNamesFrames.ItemIndex := cbBBMaxFrames.ItemIndex;
  cbBBMinFrames.ItemIndex := cbBBMaxFrames.ItemIndex;
  cbOriginFrames.ItemIndex := cbBBMaxFrames.ItemIndex;
  cbRadiusFrames.ItemIndex := cbBBMaxFrames.ItemIndex;
end;

procedure TForm1.cbOriginFramesSelect(Sender: TObject);
begin
  cbNamesFrames.ItemIndex := cbOriginFrames.ItemIndex;
  cbBBMinFrames.ItemIndex := cbOriginFrames.ItemIndex;
  cbBBMaxFrames.ItemIndex := cbOriginFrames.ItemIndex;
  cbRadiusFrames.ItemIndex := cbOriginFrames.ItemIndex;
end;

procedure TForm1.cbRadiusFramesSelect(Sender: TObject);
begin
  cbNamesFrames.ItemIndex := cbRadiusFrames.ItemIndex;
  cbBBMinFrames.ItemIndex := cbRadiusFrames.ItemIndex;
  cbBBMaxFrames.ItemIndex := cbRadiusFrames.ItemIndex;
  cbOriginFrames.ItemIndex := cbRadiusFrames.ItemIndex;
end;

procedure TForm1.cbNamesShadersKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_RETURN then Exit;
  if cbNamesSurfaces.ItemIndex = -1 then Exit;
  case LoadedType of
    ltMD3,ltMap,ltASE,ltMS3D_MD3: begin
      MD3.ChangeShader(cbNamesSurfaces.ItemIndex, cbNamesShaders.Text);
      gbModel.Caption := gbModel.Caption +'*';
    end;
    ltMDMMDX,ltMDS,ltMS3D_MDMMDX: begin
      MDM.ChangeShader(cbNamesSurfaces.ItemIndex, cbNamesShaders.Text);
      gbModel.Caption := gbModel.Caption +'*';
    end;
  end;
  UpdateShaders;
end;

procedure TForm1.cbShaderTexturesChange(Sender: TObject);
begin
  if cbNamesSurfaces.ItemIndex = -1 then Exit;
  if cbShaderTextures.ItemIndex = -1 then Exit;
  TextureToForm(cbNamesSurfaces.ItemIndex, cbShaderTextures.ItemIndex);
end;

procedure TForm1.cbTagPivotsChange(Sender: TObject);
begin
  if cbLockView.Checked then Exit;
  Model_Matrix := IdentityMatrix4x4;
  Model_Rotation := NullVector;
  Model_Position := NullVector;
  case LoadedType of
    ltMD3,ltMap,ltASE,ltMS3D_MD3: begin
      if (cbTagPivots.ItemIndex=-1) or (cbTagPivots.ItemIndex>=Length(MD3.Header.Tags)) then
        Model_Offset := NullVector
      else
        with MD3.Header.Tags[cbTagPivots.ItemIndex] do
          Model_Offset := Vector(-Origin.X, -Origin.Y, -Origin.Z);
    end;
    ltMDMMDX,ltMDS,ltMS3D_MDMMDX: TagPivotMDMMDX;
  end;
  StatusBar.SetFocus;
  OGL_RenderFrame;
end;

procedure TForm1.tbStartFrameChange(Sender: TObject);
begin
  lStartFrame.Caption := IntToStr(tbStartFrame.Position);
  tbCurrentFrame.SelStart := tbStartFrame.Position;
  cbAnimName.ItemIndex := -1;
end;

procedure TForm1.tbEndFrameChange(Sender: TObject);
begin
  lEndFrame.Caption := IntToStr(tbEndFrame.Position);
  tbCurrentFrame.SelEnd := tbEndFrame.Position;
  cbAnimName.ItemIndex := -1;
end;

procedure TForm1.tbCurrentFrameChange(Sender: TObject);
begin
  if cbPlay.Checked then Exit;
  Current_Frame := tbCurrentFrame.Position;
  lCurrentFrame.Caption := IntToStr(Current_Frame);
  // tekenen
  OGL_RenderFrame;
end;

procedure TForm1.cbAnimNameChange(Sender: TObject);
var sfe, efe: TNotifyEvent;
begin
  if LoadedType<>ltMDMMDX then Exit;
  // stel het frame-bereik in voor de gekozen animatie
  if cbAnimName.Items.Count=0 then Exit;
  if cbAnimName.ItemIndex=-1 then Exit;
  // even geen onchange-events voor de 2 sliders
  sfe := tbStartFrame.OnChange;
  efe := tbEndFrame.OnChange;
  tbStartFrame.OnChange := nil;
  tbEndFrame.OnChange := nil;
  //
  tbStartFrame.Position := Aninc.Anims[cbAnimName.ItemIndex].FirstFrame;
  tbEndFrame.Position := tbStartFrame.Position + Aninc.Anims[cbAnimName.ItemIndex].Length-1;
  udFPS.Position := Aninc.Anims[cbAnimName.ItemIndex].FPS;
  Current_Frame := tbStartFrame.Position;
  tbCurrentFrame.Position := tbStartFrame.Position;
  lStartFrame.Caption := IntToStr(tbStartFrame.Position);
  tbCurrentFrame.SelStart := tbStartFrame.Position;
  lEndFrame.Caption := IntToStr(tbEndFrame.Position);
  tbCurrentFrame.SelEnd := tbEndFrame.Position;
  // weer onchange-events
  tbStartFrame.OnChange := sfe;
  tbEndFrame.OnChange := efe;
end;

procedure TForm1.tbLODMinimumChange(Sender: TObject);
var s: integer;
begin
  tbLODMinimum.Hint := '';
  if (LoadedType<>ltMDMMDX) and (LoadedType<>ltMDS) and (LoadedType<>ltMS3D_MDMMDX) then Exit;
  s := seLODSurfaceNr.Value;
  if s<0 then Exit;
  if s>=MDM.Header.Num_Surfaces then Exit;
  MDM.LOD_minimums[s].Value := tbLODMinimum.Position;
  tbLODMinimum.Hint := IntToStr(MDM.LOD_minimums[s].Value) +' of '+
                       IntToStr(MDM.LOD_minimums[s].Max) +' vertices';
  // meteen in de MDM zelf ook opslaan, zodat "save as" ook werkt..
  MDM.Surfaces[s].Values.LOD_minimum := MDM.LOD_minimums[s].Value;
end;

procedure TForm1.seLODSurfaceNrChange(Sender: TObject);
var s: integer;
    loc: TNotifyEvent;
begin
  tLODSurfacename.Caption := '';
  if (LoadedType<>ltMDMMDX) and (LoadedType<>ltMDS) and (LoadedType<>ltMS3D_MDMMDX) then Exit;
  s := seLODSurfaceNr.Value;
  if s<0 then Exit;
  if s>=MDM.Header.Num_Surfaces then Exit;
  tLODSurfacename.Caption := MDM.Surfaces[s].Values.SurfaceName;
  // events tijdelijk uitschakelen
  loc := tbLODMinimum.OnChange;
  tbLODMinimum.OnChange := nil;
  // instellingen veranderen
  tbLODMinimum.Max := MDM.LOD_minimums[s].Max;
  tbLODMinimum.Position := MDM.LOD_minimums[s].Value;
  tbLODMinimum.Hint := IntToStr(MDM.LOD_minimums[s].Value) +' of '+
                       IntToStr(MDM.LOD_minimums[s].Max) +' vertices';
  //events weer inschakelen
  tbLODMinimum.OnChange := loc;
end;

procedure TForm1.cbLODEnabledClick(Sender: TObject);
begin
  if (LoadedType<>ltMDMMDX) and (LoadedType<>ltMDS) and (LoadedType<>ltMS3D_MDMMDX) then Exit;
(*
  // belichting
  if not cbLODEnabled.Checked then Exit; //LOD uit??
  if cbLightingEnabled.Checked then Exit; //licht al aan??
  menuViewLighting.Checked := true;
  cbLightingEnabled.Checked := true;
  InitLighting;
*)
end;


procedure TForm1.lStartFrameDblClick(Sender: TObject);
var strFrameNr: string;
    FrameNr: integer;
begin
  if not InputQuery('Enter the Frame #','Start Frame', strFrameNr) then Exit;
  if not TryStrToInt(strFrameNr, FrameNr) then Exit;
  if (FrameNr<tbStartFrame.Min) or (FrameNr>tbStartFrame.Max) then Exit;
  tbStartFrame.Position := FrameNr;
end;

procedure TForm1.lEndFrameDblClick(Sender: TObject);
var strFrameNr: string;
    FrameNr: integer;
begin
  if not InputQuery('Enter the Frame #','End Frame', strFrameNr) then Exit;
  if not TryStrToInt(strFrameNr, FrameNr) then Exit;
  if (FrameNr<tbEndFrame.Min) or (FrameNr>tbEndFrame.Max) then Exit;
  tbEndFrame.Position := FrameNr;
end;

procedure TForm1.lCurrentFrameDblClick(Sender: TObject);
var strFrameNr: string;
    FrameNr: integer;
begin
  if not InputQuery('Enter the Frame #','Current Frame', strFrameNr) then Exit;
  if not TryStrToInt(strFrameNr, FrameNr) then Exit;
  if (FrameNr<tbCurrentFrame.Min) or (FrameNr>tbCurrentFrame.Max) then Exit;
  Current_Frame := FrameNr;
  tbCurrentFrame.Position := FrameNr;
end;


procedure TForm1.eFPSChange(Sender: TObject);
var v: integer;
begin
  v := StrToInt(eFPS.Text);
  TimerFPS.Interval := Round(1/v*1000);
end;

procedure TForm1.cbPlayClick(Sender: TObject);
begin
  pcTabsChange(nil);
end;

procedure TForm1.TimerFPSTimer(Sender: TObject);
begin
  if cbPlay.Checked and (pcTabs.ActivePage=tabView) then begin
    if Current_Frame < tbEndFrame.Position then
      Inc(Current_Frame)
    else
      if cbLoop.Checked then Current_Frame := tbStartFrame.Position;
    tbCurrentFrame.Position := Current_Frame;
    lCurrentFrame.Caption := IntToStr(Current_Frame);
  end;
  // tekenen
  if WindowState<>wsMinimized then OGL_RenderFrame;

  OGL.MeasureFPS;  
end;

procedure TForm1.TimerOGLFPSTimer(Sender: TObject);
begin
  // FPS tellen..
  OGL.FPSTimer;
end;


function TForm1.FileInUse(FileName: string): Boolean;
var hFileRes: HFILE;
begin
  Result := False;
  if not FileExists(FileName) then exit;
  hFileRes := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE, 0, nil,
                         OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  Result := (hFileRes=INVALID_HANDLE_VALUE);
  if not Result then CloseHandle(hFileRes);
end;

function TForm1.DelTree(DirName: string): Boolean;
var SHFileOpStruct : TSHFileOpStruct;
    DirBuf : array [0..255] of char;
begin
  try
   Fillchar(SHFileOpStruct,Sizeof(SHFileOpStruct),0) ;
   FillChar(DirBuf, Sizeof(DirBuf), 0 ) ;
   StrPCopy(DirBuf, DirName+'*.*') ;
   with SHFileOpStruct do begin
    Wnd := 0;
    pFrom := @DirBuf;
    wFunc := FO_DELETE;
    fFlags := FOF_ALLOWUNDO;
    fFlags := fFlags or FOF_NOCONFIRMATION;
    fFlags := fFlags or FOF_SILENT;
   end;
    Result := (SHFileOperation(SHFileOpStruct) = 0) ;
   except
    Result := False;
  end;
end;

procedure TForm1.SetHWGamma(Gamma: Single); // Value in [-1.0 .. 1.0]
var DesktopDC: HDC;
    GammaRamp: array[0..2,0..255] of word;
    Index, Value: Integer;
begin
  DesktopDC := GetDC(0);
  if DesktopDC = 0 then Exit;
  for Index:=0 to 255 do begin
    Value := Floor(((Gamma*0.5 + 0.5) * 255) + 128);
    if Value>65535 then Value := 65535;
    GammaRamp[0,Index] := Value;
    GammaRamp[1,Index] := Value;
    GammaRamp[2,Index] := Value;
  end;
  if SetDeviceGammaRamp(DesktopDC,GammaRamp) then
    StatusBar.SimpleText := 'Hardware Gamma set to '+ FloatToStr(Gamma)
  else
    StatusBar.SimpleText := 'Hardware Gamma setting failed';
  ReleaseDC(0,DesktopDC);
end;

procedure TForm1.ShowHelp;
begin
  tabGeneral.TabVisible := false;
  tabAnimation.TabVisible := false;
  tabTags.TabVisible := false;
  tabSurfaces.TabVisible := false;
  tabBones.TabVisible := false;
  tabView.TabVisible := false;
  tabHelp.TabVisible := true;
  pcTabs.ActivePage := tabHelp;
end;

procedure TForm1.HideHelp;
begin
  case LoadedType of
    ltNone: ShowTabsNone;
    ltMD3,ltMap,ltASE,ltMS3D_MD3: ShowTabsMD3;
    ltMDMMDX,ltMDS,ltMS3D_MDMMDX: ShowTabsMDMMDX;
  end;
  pcTabs.ActivePage := tabView;
end;

procedure TForm1.ShowTabsNone;
begin
  tabGeneral.TabVisible := false;
  tabAnimation.TabVisible := false;
  tabTags.TabVisible := false;
  tabSurfaces.TabVisible := false;
  tabBones.TabVisible := false;
  tabView.TabVisible := true;
  tabHelp.TabVisible := false;
  gbLOD.Enabled := false;
end;

procedure TForm1.ShowTabsMD3;
begin
  tabGeneral.TabVisible := true;
  tabAnimation.TabVisible := true;
  tabTags.TabVisible := true;
  tabSurfaces.TabVisible := true;
  tabBones.TabVisible := false;
  tabView.TabVisible := true;
  tabHelp.TabVisible := false;
//  pcTabs.ActivePage := tabGeneral;
  gbLOD.Enabled := false;
end;

procedure TForm1.ShowTabsMDMMDX;
begin
  tabGeneral.TabVisible := false;
  tabAnimation.TabVisible := false;
  tabTags.TabVisible := false;
  tabSurfaces.TabVisible := true;
  tabBones.TabVisible := true;
  tabView.TabVisible := true;
  tabHelp.TabVisible := false;
//  pcTabs.ActivePage := tabView;
  gbLOD.Enabled := true;
end;


procedure TForm1.ShowMenuNone;
begin
  menuFileLoadMDX.Enabled := false;
  menuFileLoadMDXbones.Enabled := false;
  menuFileLoadMDXframes.Enabled := false;
  menuFileLoadMDMtags.Enabled := false;
  menuFileExportFramesrangeToMD3.Enabled := false;
  {menuFileSaveMDM.Enabled := false;
  menuFileSaveMDX.Enabled := false;}
  menuModelClear.Enabled := false;
  menuModelAnimationAddframe.Enabled := false;
  menuModelAnimationAddframes.Enabled := false;
  menuModelAnimationAddframesSequence.Enabled := false;
  menuModelAnimationDelframe.Enabled := false;
  menuModelCalcLOD.Enabled := false;
  menuModelCalcNormals.Enabled := false;
  menuModelSmoothSurface.Enabled := false;
  menuModelScaleskeleton.Enabled := false;
  menuModelScalemd3.Enabled := false;
  menuModelTagsInvertX.Enabled := false;
  menuModelTagsInvertY.Enabled := false;
  menuModelTagsInvertZ.Enabled := false;
  menuModelTagsSwapXY.Enabled := false;
  menuModelTagsSwapXZ.Enabled := false;
  menuModelTagsSwapYZ.Enabled := false;
  menuModelMD3TagAsOrigin.Enabled := false;
  menuModelMD3FlipX.Enabled := false;
  menuModelMD3FlipY.Enabled := false;
  menuModelMD3FlipZ.Enabled := false;
  menuModelMD3FlipNormals.Enabled := false;
  menuModelMD3FlipWinding.Enabled := false;
  menuModelRotateX.Enabled := false;
  menuModelRotateY.Enabled := false;
  menuModelRotateZ.Enabled := false;
  menuSkinToModel.Enabled := false;
  menuModelMD3Fixcracksgaps.Enabled := false;
  menuModelSurfacesSwapUVST.Enabled := false;
  menumodelsurfaceRemove.Enabled := false;
  menuModelSurfacesCompact.Enabled := false;
  //
  gbInsertTags.Enabled := false;
end;

procedure TForm1.ShowMenuMD3;
begin
  menuModelClear.Enabled := true;
  menuModelAnimationAddframe.Enabled := true;
  menuModelAnimationAddframes.Enabled := true;
  menuModelAnimationAddframesSequence.Enabled := true;
  menuModelAnimationDelframe.Enabled := true;
  menuFileLoadMDX.Enabled := false;
  menuFileLoadMDXbones.Enabled := false;
  menuFileLoadMDXframes.Enabled := false;
  menuFileLoadMDMtags.Enabled := false;
  menuFileExportFramesrangeToMD3.Enabled := false;
  {menuFileSaveMDM.Enabled := false;
  menuFileSaveMDX.Enabled := false;}
  menuModelCalcLOD.Enabled := false;
  menuModelCalcNormals.Enabled := true;
  menuModelSmoothSurface.Enabled := true;
  menuModelScaleskeleton.Enabled := false;
  menuModelScalemd3.Enabled := true;
  menuModelBones.Enabled := false;
  menuModelTagsInvertX.Enabled := true;
  menuModelTagsInvertY.Enabled := true;
  menuModelTagsInvertZ.Enabled := true;
  menuModelTagsSwapXY.Enabled := true;
  menuModelTagsSwapXZ.Enabled := true;
  menuModelTagsSwapYZ.Enabled := true;
  menuModelMD3TagAsOrigin.Enabled := true;
  menuModelMD3FlipX.Enabled := true;
  menuModelMD3FlipY.Enabled := true;
  menuModelMD3FlipZ.Enabled := true;
  menuModelMD3FlipNormals.Enabled := true;
  menuModelMD3FlipWinding.Enabled := true;
  menuModelRotateX.Enabled := true;
  menuModelRotateY.Enabled := true;
  menuModelRotateZ.Enabled := true;
  menuModelMD3Fixcracksgaps.Enabled := true;
  menuModelSurfacesSwapUVST.Enabled := true;
  menumodelsurfaceRemove.Enabled := true;
  menuModelSurfacesCompact.Enabled := true;
  //
  gbInsertTags.Enabled := true;
end;

procedure TForm1.ShowMenuMDMMDX;
begin
  menuModelClear.Enabled := true;
  menuModelAnimationAddframe.Enabled := false;
  menuModelAnimationAddframes.Enabled := false;
  menuModelAnimationAddframesSequence.Enabled := false;
  menuModelAnimationDelframe.Enabled := false;
  menuFileLoadMDX.Enabled := true;
  menuFileLoadMDXbones.Enabled := true;
  menuFileLoadMDXframes.Enabled := true;
  menuFileLoadMDMtags.Enabled := true;
  menuFileExportFramesrangeToMD3.Enabled := true;
  {menuFileSaveMDM.Enabled := true;
  menuFileSaveMDX.Enabled := true;}
  menuModelCalcLOD.Enabled := true;
  menuModelCalcNormals.Enabled := true;
  menuModelSmoothSurface.Enabled := true;
  menuModelScaleskeleton.Enabled := true;
  menuModelScalemd3.Enabled := false;
  menuModelBones.Enabled := true;
  menuModelTagsInvertX.Enabled := false;
  menuModelTagsInvertY.Enabled := false;
  menuModelTagsInvertZ.Enabled := false;
  menuModelTagsSwapXY.Enabled := false;
  menuModelTagsSwapXZ.Enabled := false;
  menuModelTagsSwapYZ.Enabled := false;
  menuModelMD3TagAsOrigin.Enabled := false;
  menuModelMD3FlipX.Enabled := false;
  menuModelMD3FlipY.Enabled := false;
  menuModelMD3FlipZ.Enabled := false;
  menuModelMD3FlipNormals.Enabled := false;
  menuModelMD3FlipWinding.Enabled := false;
  menuModelRotateX.Enabled := false;
  menuModelRotateY.Enabled := false;
  menuModelRotateZ.Enabled := false;
  menuModelMD3Fixcracksgaps.Enabled := false;
  menuModelSurfacesSwapUVST.Enabled := false;
  menumodelsurfaceRemove.Enabled := true;
  menuModelSurfacesCompact.Enabled := false;
  //
  gbInsertTags.Enabled := false;
end;



procedure TForm1.ClearMD3Info;
begin
  // general tab
  leHeaderIdent.Text := '';
  leVersion.Text := '';
  leHeaderName.Text := '';
  leHeaderFlags.Text := '';
  leName.Text := '';
  // animation tab
  leNumFrames.Text := '0';
  cbNamesFrames.Clear;
  cbBBMinFrames.Clear;
  cbBBMaxFrames.Clear;
  cbOriginFrames.Clear;
  cbRadiusFrames.Clear;
  // tags tab
  leNumTags.Text := '0';
  cbNamesTags.Clear;
  cbTagFrameNr.Clear;
  cbTagOrigins.Clear;
  cbTagAxis.Clear;
  // surfaces tab
  leNumSurfaces.Text := '0';
  leNumShaders.Text := '0';
  leNumVerts.Text := '0';
  leNumTriangles.Text := '0';
  cbNamesSurfaces.Clear;
  cbNamesShaders.Clear;
  cbShaderTextures.Clear;
  leSurfaceFlags.Text := '';
  cbHasAlpha.Checked := false;
  cbAlphaFunc.Checked := false;
  cbEnvironmentMap.Checked := false;
  cbAnimMap.Checked := false;
  cbVideoMap.Checked := false;
  cbClamped.Checked := false;
  leCull.Text := '';
  // view tab
  cbTagPivots.Clear;
end;

procedure TForm1.ShowMD3HeaderInfo;
var b: Byte;
    i: integer;
    s: string;
begin
  // Ident
  b := (MD3.Header.Values.Ident and $FF000000) shr 24;
  s := chr(b);
  b := (MD3.Header.Values.Ident and $00FF0000) shr 16;
  s := chr(b) + s;
  b := (MD3.Header.Values.Ident and $0000FF00) shr 8;
  s := chr(b) + s;
  b := (MD3.Header.Values.Ident and $000000FF);
  s := chr(b) + s;
  leHeaderIdent.Text := s;
  // version
  leVersion.Text := IntToStr(MD3.Header.Values.Version);
  // name
  leHeaderName.Text := string(MD3.Header.Values.Name);
  // flags
  leHeaderFlags.Text := IntToHex(MD3.Header.Values.Flags,8)+'h';
  //
  leNumFrames.Text := IntToStr(MD3.Header.Values.Num_Frames);
  leNumTags.Text := IntToStr(MD3.Header.Values.Num_Tags);
  leNumSurfaces.Text := IntToStr(MD3.Header.Values.Num_Surfaces);
end;

procedure TForm1.ShowMD3FramesInfo;
var i: integer;
    strV, strX,strY,strZ: string;
begin
  for i:=0 to MD3.Header.Values.Num_Frames-1 do begin
    strV := IntToStr(i) +': '+ string(MD3.Header.Frames[i].Name);
    cbNamesFrames.Items.Add(strV);
    cbTagFrameNr.Items.Add(strV);
    // boundingbox min.
    strX := FloatToStr(MD3.Header.Frames[i].Min_Bounds.X);
    strY := FloatToStr(MD3.Header.Frames[i].Min_Bounds.Y);
    strZ := FloatToStr(MD3.Header.Frames[i].Min_Bounds.Z);
    cbBBMinFrames.Items.Add(strX +'  '+ strY +'  '+ strZ);
    // boundingbox max.
    strX := FloatToStr(MD3.Header.Frames[i].Max_Bounds.X);
    strY := FloatToStr(MD3.Header.Frames[i].Max_Bounds.Y);
    strZ := FloatToStr(MD3.Header.Frames[i].Max_Bounds.Z);
    cbBBMaxFrames.Items.Add(strX +'  '+ strY +'  '+ strZ);
    // local origin
    strX := FloatToStr(MD3.Header.Frames[i].Local_Origin.X);
    strY := FloatToStr(MD3.Header.Frames[i].Local_Origin.Y);
    strZ := FloatToStr(MD3.Header.Frames[i].Local_Origin.Z);
    cbOriginFrames.Items.Add(strX +'  '+ strY +'  '+ strZ);
    // radius
    strV := FloatToStr(MD3.Header.Frames[i].Radius);
    cbRadiusFrames.Items.Add(strV);
  end;
  cbNamesFrames.ItemIndex := 0;
  cbBBMinFrames.ItemIndex := 0;
  cbBBMaxFrames.ItemIndex := 0;
  cbOriginFrames.ItemIndex := 0;
  cbRadiusFrames.ItemIndex := 0;
  cbNamesTags.ItemIndex := 0;
  cbNamesTags.Enabled := (MD3.Header.Values.Num_Tags>0);
  cbTagFrameNr.Enabled := ((MD3.Header.Values.Num_Tags>0) and (MD3.Header.Values.Num_Frames>1));
end;

procedure TForm1.ShowMD3TagsInfo;
var f,i,j: integer;
    strV, strX,strY,strZ: string;
begin
  for f:=0 to MD3.Header.Values.Num_Frames-1 do begin
    j := f * MD3.Header.Values.Num_Tags;
    for i:=0 to MD3.Header.Values.Num_Tags-1 do begin
      //namen van de tags inlezen
      if f = 0 then begin
        cbNamesTags.Items.Add( string(MD3.Header.Tags[i].Name) );
        cbTagPivots.Items.Add( string(MD3.Header.Tags[i].Name) );
      end;
      // origins
      strX := FloatToStr(MD3.Header.Tags[j+i].Origin.X);
      strY := FloatToStr(MD3.Header.Tags[j+i].Origin.Y);
      strZ := FloatToStr(MD3.Header.Tags[j+i].Origin.Z);
      cbTagOrigins.Items.Add(strX +'  '+ strY +'  '+ strZ);

      // axis
      strX := FloatToStr(MD3.Header.Tags[j+i].Axis[0].X);
      strY := FloatToStr(MD3.Header.Tags[j+i].Axis[0].Y);
      strZ := FloatToStr(MD3.Header.Tags[j+i].Axis[0].Z);
      strV := '('+ strX +'  '+ strY +'  '+ strZ +')';
      //
      strX := FloatToStr(MD3.Header.Tags[j+i].Axis[1].X);
      strY := FloatToStr(MD3.Header.Tags[j+i].Axis[1].Y);
      strZ := FloatToStr(MD3.Header.Tags[j+i].Axis[1].Z);
      strV := strV +'    ('+ strX +'  '+ strY +'  '+ strZ +')';
      //
      strX := FloatToStr(MD3.Header.Tags[j+i].Axis[2].X);
      strY := FloatToStr(MD3.Header.Tags[j+i].Axis[2].Y);
      strZ := FloatToStr(MD3.Header.Tags[j+i].Axis[2].Z);
      strV := strV +'    ('+ strX +'  '+ strY +'  '+ strZ +')';
      cbTagAxis.Items.Add(strV);
    end;
  end;
  cbNamesTags.ItemIndex := 0;
  cbTagFrameNr.ItemIndex := 0;
  cbTagOrigins.ItemIndex := 0;
  cbTagAxis.ItemIndex := 0;
  cbTagPivots.ItemIndex := cbTagPivots.Items.Add('origin');
end;

procedure TForm1.ShowMD3SurfacesInfo;
var i,j: integer;
begin
  for i:=0 to MD3.Header.Values.Num_Surfaces-1 do begin
    cbNamesSurfaces.Items.Add( string(MD3.Header.Surfaces[i].Values.Name) );
    for j:=0 to MD3.Header.Surfaces[i].Values.Num_Shaders-1 do
      cbNamesShaders.Items.Add( string(MD3.Header.Surfaces[i].Shaders[j].Name) );
  end;
  cbNamesSurfaces.ItemIndex := 0;
  cbNamesShaders.ItemIndex := 0;
  SurfaceToForm(cbNamesSurfaces.ItemIndex);
end;

procedure TForm1.ShowMD3Info;
begin
  ClearMD3Info;
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  ShowMD3HeaderInfo;
  ShowMD3FramesInfo;
  ShowMD3TagsInfo;
  ShowMD3SurfacesInfo;
  tLODpresence.Caption := '';
end;


procedure TForm1.ClearMDMMDXInfo;
begin
  tvBones.Items.Clear;
end;

procedure TForm1.ShowMDMMDXBoneInfo;
var bi,pidx: integer;
    Name: string;
    Node, ParentNode: TTreeNode;
begin
  for bi:=0 to MDX.Header.Num_Bones-1 do begin
    Name := string(MDX.Bones[bi].Name);
    pidx := MDX.Bones[bi].ParentIndex;
    if pidx=-1 then begin
      Node := tvBones.Items.Add(nil, Name);
    end else begin
      ParentNode := tvBones.Items[pidx];
      Node := tvBones.Items.AddChild(ParentNode, Name);
    end;
  end;
end;

procedure TForm1.ShowMDMMDXTagsInfo;
var f,i,j: integer;
    strV, strX,strY,strZ: string;
begin
//!  for f:=0 to MDX.Header.Num_Frames-1 do begin
//!    MDM.CalcModel(MDX,f,0); //TRANSFORMEREN!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//!    j := f * MDM.Header.Num_Tags;
    for i:=0 to MDM.Header.Num_Tags-1 do begin
      //namen van de tags inlezen
//!      if f = 0 then begin
        {cbNamesTags.Items.Add( string(MDM.Tags[i].Name) );}
        cbTagPivots.Items.Add( string(MDM.Tags[i].Name) );
//!      end;
{      // origins
      strX := FloatToStr(MDM.TagOrigin[i].X);
      strY := FloatToStr(MDM.TagOrigin[i].Y);
      strZ := FloatToStr(MDM.TagOrigin[i].Z);
      cbTagOrigins.Items.Add(strX +'  '+ strY +'  '+ strZ);

      // axis
      strX := FloatToStr(MDM.TagAxis[i][0].X);
      strY := FloatToStr(MDM.TagAxis[i][0].Y);
      strZ := FloatToStr(MDM.TagAxis[i][0].Z);
      strV := '('+ strX +'  '+ strY +'  '+ strZ +')';
      //
      strX := FloatToStr(MDM.TagAxis[i][1].X);
      strY := FloatToStr(MDM.TagAxis[i][1].Y);
      strZ := FloatToStr(MDM.TagAxis[i][1].Z);
      strV := strV +'    ('+ strX +'  '+ strY +'  '+ strZ +')';
      //
      strX := FloatToStr(MDM.TagAxis[i][2].X);
      strY := FloatToStr(MDM.TagAxis[i][2].Y);
      strZ := FloatToStr(MDM.TagAxis[i][2].Z);
      strV := strV +'    ('+ strX +'  '+ strY +'  '+ strZ +')';
      cbTagAxis.Items.Add(strV);}
    end;
//!  end;
  cbNamesTags.ItemIndex := 0;
  cbTagFrameNr.ItemIndex := 0;
  cbTagOrigins.ItemIndex := 0;
  cbTagAxis.ItemIndex := 0;
  cbTagPivots.ItemIndex := cbTagPivots.Items.Add('origin');
end;

procedure TForm1.ShowMDMMDXSurfaceInfo;
var i,j: integer;
begin
  cbNamesSurfaces.Clear; 
  for i:=0 to MDM.Header.Num_Surfaces-1 do begin
    cbNamesSurfaces.Items.Add( string(MDM.Surfaces[i].Values.SurfaceName) );
    cbNamesShaders.Items.Add( string(MDM.Surfaces[i].Values.ShaderName) );
  end;
  cbNamesSurfaces.ItemIndex := 0;
  cbNamesShaders.ItemIndex := 0;
  SurfaceToForm(cbNamesSurfaces.ItemIndex);
end;

procedure TForm1.ShowMDMMDXInfo;
var b: boolean;
    s: integer;
begin
  ClearMDMMDXInfo;
  if (LoadedType<>ltMDMMDX) and (LoadedType<>ltMDS) and (LoadedType<>ltMS3D_MDMMDX) then Exit;
  ShowMDMMDXBoneInfo;
  ShowMDMMDXTagsInfo;
  ShowMDMMDXSurfaceInfo;
  // bereken de collapsemap voor alle surfaces (LOD), indien er geen collapsemap aanwezig is..
  b := MDM.HasLOD;
  if b then tLODpresence.Caption := 'present'
       else tLODpresence.Caption := 'absent';
  cbLODEnabled.Checked := false;
  if MDM.Header.Num_Surfaces>0 then begin
    seLODSurfaceNr.MinValue := 0;
    seLODSurfaceNr.MaxValue := MDM.Header.Num_Surfaces-1;
    seLODSurfaceNr.Value := 0;
  end;
  if b then
    for s:=0 to MDM.Header.Num_Surfaces-1 do begin
      MDM.LOD_minimums[s].Max := MDM.Surfaces[s].Values.Num_Verts;
      MDM.LOD_minimums[s].Value := MDM.Surfaces[s].Values.LOD_minimum;
    end;
  seLODSurfaceNrChange(nil);
end;

procedure TForm1.ShowNone;
var TU: integer;
begin
  LoadedFrom := lfNone;
  LoadedType := ltNone;
  ClearMapShaders;
  MD3.Clear;
  MDM.Clear;
  MDX.Clear;
  ClearMD3Info;
  ClearMDMMDXInfo;
  ShowMenuNone;
  ShowTabsNone;
  ModelDir := '';
  leName.Text := '';
  gbModel.Caption := '';
  tbStartFrame.Max := 0;
  tbCurrentFrame.Max := 0;
  tbEndFrame.Max := 0;
  lStartFrame.Caption := '0';
  lCurrentFrame.Caption := '0';
  lEndFrame.Caption := '0';
  tLODpresence.Caption := 'info';
  // reset Texture Units
  if not OGL.Active then Exit;
  for TU:=0 to MaxTU-1 do begin
    glActiveTextureARB(GL_TEXTURE0_ARB + TU);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_ALPHA_TEST);
    glAlphaFunc(GL_GREATER, 0);
    glDisable(GL_POLYGON_OFFSET_FILL);
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    glMatrixMode(GL_TEXTURE);
    glLoadIdentity;
    glMatrixMode(GL_MODELVIEW);
  end;
  glActiveTextureARB(GL_TEXTURE0_ARB);
  glMatrixMode(GL_TEXTURE);
  glLoadIdentity;
  glMatrixMode(GL_MODELVIEW);
end;


procedure TForm1.TagPivotMD3;
var nt: integer;
begin
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if cbCenterModel.Checked then Exit;
  if (cbTagPivots.ItemIndex=-1) or (cbTagPivots.ItemIndex>=Length(MD3.Header.Tags)) then
    Model_Offset := NullVector
  else
    if (cbTagPivots.ItemIndex > MD3.Header.Values.Num_Tags-1) or
       (Length(MD3.Header.Tags) < MD3.Header.Values.Num_Frames*MD3.Header.Values.Num_Tags) then
      Model_Offset := NullVector
    else begin
      nt := Current_Frame * MD3.Header.Values.Num_Tags;
      with MD3.Header.Tags[nt+cbTagPivots.ItemIndex] do
        Model_Offset := Vector(-Origin.X, -Origin.Y, -Origin.Z);
    end;
end;

procedure TForm1.TagPivotMDMMDX;
begin
  if (LoadedType<>ltMDMMDX) and (LoadedType<>ltMDS) and (LoadedType<>ltMS3D_MDMMDX) then Exit;
  if cbCenterModel.Checked then Exit;
  if (cbTagPivots.ItemIndex=-1) or (cbTagPivots.ItemIndex>=MDM.Header.Num_Tags) then
    Model_Offset := NullVector
  else
    with MDM.TagOrigin[cbTagPivots.ItemIndex] do Model_Offset := Vector(-X, -Y, -Z);
end;



procedure TForm1.TextureToImg(SurfaceIndex, TextureIndex: integer);
var TexWidth,TexHeight: glInt;
    PixelData: array of Byte;  //vooralsnog altijd RGBA
    tmp: Byte;
    x,y, BytesPerLine, BytesPerPixel, ShaderIndex: integer;
    TextureHandle: cardinal;
    UseAlpha: boolean;
    CR,CG,CB, R_,G_,B_,A_, R,G,B,A: byte;
//---
procedure LerpColor(const bgR,bgG,bgB, cR,cG,cB, Alpha: byte; var R,G,B: byte);
var A,A1: single;
begin
  A := Alpha / 255.0;
  A1 := 1.0 - A;
  R := Round((bgR*A1 + cR*A));
  G := Round((bgG*A1 + cG*A));
  B := Round((bgB*A1 + cB*A));
end;
//---
begin
  // een OpenGL opslaan als BMP.. nodig voor op het form
  case LoadedType of
    ltMD3,ltMap,ltASE,ltMS3D_MD3: ShaderIndex := MD3.Header.Surfaces[SurfaceIndex].Shaders[0].Shader_Index;
    ltMDMMDX,ltMDS,ltMS3D_MDMMDX: ShaderIndex := MDM.Surfaces[SurfaceIndex].Values.ShaderIndex;
  end;
  TextureHandle := Shaders.ShaderFile[ShaderIndex].Textures[TextureIndex].TextureHandle;
  if TextureHandle=0 then begin
    img3DView.Picture.Bitmap.Canvas.Brush.Color := gbOGLtris.Color; //$00E3DFE0;
    img3DView.Picture.Bitmap.Canvas.FillRect(img3DView.Picture.Bitmap.Canvas.ClipRect);
    Exit;
  end;
{  if ShaderFile[SurfaceIndex].Textures[TextureIndex].TextureHandle=0 then Exit;}
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, TextureHandle);
  glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH, @TexWidth);
  glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_HEIGHT, @TexHeight);
  UseAlpha := Shaders.ShaderFile[ShaderIndex].Textures[TextureIndex].HasAlphaData;
  UseAlpha := (UseAlpha and cbAlphaPreview.Checked);
  if UseAlpha then BytesPerPixel := 4
              else BytesPerPixel := 3;
  SetLength(PixelData, TexWidth*TexHeight*BytesPerPixel); //BGR of BGRA
  try
    if UseAlpha then glGetTexImage(GL_TEXTURE_2D, 0, GL_RGBA, GL_UNSIGNED_BYTE, PixelData)
                else glGetTexImage(GL_TEXTURE_2D, 0, GL_RGB, GL_UNSIGNED_BYTE, PixelData);
    if glGetError = GL_NO_ERROR then begin
      // pixeldata overnemen naar form-image
      if UseAlpha then img3DView.Picture.Bitmap.PixelFormat := pf32bit
                  else img3DView.Picture.Bitmap.PixelFormat := pf24bit;
      img3DView.Picture.Bitmap.TransparentMode := tmFixed; //tmAuto
      img3DView.Picture.Bitmap.Transparent := false{UseAlpha};
      img3DView.Picture.Bitmap.Width := TexWidth;
      img3DView.Picture.Bitmap.Height := TexHeight;
      BytesPerLine := TexWidth*BytesPerPixel;
      for y:=0 to TexHeight-1 do begin
        // swap RGB naar BGR
        for x:=0 to TexWidth-1 do begin
          if UseAlpha then begin
            R_ := PixelData[y*BytesPerLine+(x*BytesPerPixel)+0];
            G_ := PixelData[y*BytesPerLine+(x*BytesPerPixel)+1];
            B_ := PixelData[y*BytesPerLine+(x*BytesPerPixel)+2];
            A_ := PixelData[y*BytesPerLine+(x*BytesPerPixel)+3];
            // clBtnColor = $00E3DFE0
            LerpColor($E0,$DF,$E3, R_,G_,B_,A_, R,G,B);
{            CR := (gbOGLtris.Color and $000000FF);
            CG := (gbOGLtris.Color and $0000FF00) shr 8;
            CB := (gbOGLtris.Color and $00FF0000) shr 16;
            LerpColor(CR,CG,CB, R_,G_,B_,A_, R,G,B);}
            //
            PixelData[y*BytesPerLine+(x*BytesPerPixel)+0] := B;
            PixelData[y*BytesPerLine+(x*BytesPerPixel)+1] := G;
            PixelData[y*BytesPerLine+(x*BytesPerPixel)+2] := R;
            PixelData[y*BytesPerLine+(x*BytesPerPixel)+3] := 0; //A;
          end else begin
            tmp := PixelData[y*BytesPerLine+(x*BytesPerPixel)+2];
            PixelData[y*BytesPerLine+(x*BytesPerPixel)+2] := PixelData[y*BytesPerLine+(x*3)];
            PixelData[y*BytesPerLine+(x*BytesPerPixel)] := tmp;
          end;
        end;
{        CopyMemory(img3DView.Picture.Bitmap.ScanLine[y], @PixelData[y*BytesPerLine], BytesPerLine);}
        CopyMemory(img3DView.Picture.Bitmap.ScanLine[TexHeight-1-y], @PixelData[y*BytesPerLine], BytesPerLine);
      end;
      //img3DView.Transparent := (ShaderFile[SurfaceIndex].Textures[TextureIndex].AlphaFunc<>afNone);
    end;
  finally
    SetLength(PixelData, 0);
  end;
  glDisable(GL_TEXTURE_2D);
end;


procedure TForm1.bPrtScrClick(Sender: TObject);
begin
  Screenshot(true); //met alpha-kanaal
end;

procedure TForm1.Screenshot(TransparentBackground: boolean);
var AlphaData,PixelData,TGAData: array of Byte;
    b: boolean;
    Header: TTargaHeader;
    Fsave: TFilestream;
    p, DataSize: integer;
    s,s2: string;
    R: TRect;
    cR,cG,cB: single;
begin
  if pcTabs.ActivePage <> tabView then Exit;
  if not OGL.Active then Exit;
  b := menuViewLighting.Checked;
  //InterruptPlayback := true;

  try
    if TransparentBackground then begin

      // Alpha-channel
      SetLength(AlphaData, gbOGL.Width*gbOGL.Height);
      menuViewLighting.Checked := false;
      TakingScreenshot := true; // teken zwart/wit, geen textures
      //
      OGL.MakeCurrent;
//      glEnable(GL_DEPTH_TEST);
//      glDepthFunc(GL_LESS);
      glDisable(GL_DEPTH_TEST);
      glFrontFace(GL_CW);
      glCullFace(GL_BACK);
      glEnable(GL_CULL_FACE);
      glDisable(GL_TEXTURE_2D);
      glDisable(GL_ALPHA_TEST);
      glDisable(GL_LIGHTING);
      glClearColor(0,0,0,0);
      glClear(GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT);
      glLoadIdentity;
      with OGL.Camera^ do gluLookAt(Position.X,Position.Y,Position.Z, Target.X,Target.Y,Target.Z, UpY.X,UpY.Y,UpY.Z);
      OGL.Frustum.Calculate_glFrustumPlanes;
      glPushMatrix;
        glTranslatef(Model_Position.X,Model_Position.Y,Model_Position.Z);
        glRotatef(Model_Rotation.X, 1.0, 0.0, 0.0);
        glRotatef(Model_Rotation.Y, 0.0, 1.0, 0.0);
        glRotatef(Model_Rotation.Z, 0.0, 0.0, 1.0);
        glTranslatef(Model_Offset.X,Model_Offset.Y,Model_Offset.Z);

        // gebruik de stencilbuffer om een masker te maken van het alpha-kanaal
//        glColorMask(GL_FALSE,GL_FALSE,GL_FALSE,GL_FALSE); // geen kleuren-data in colorbuffer, ik wil alleen stencil-data
        glClearStencil(0);
        glEnable(GL_STENCIL_TEST);
        glClear(GL_STENCIL_BUFFER_BIT);
        glStencilFunc(GL_ALWAYS, 1, 1);
        glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);

        // teken het model
        case LoadedType of
          ltMD3,ltMap,ltASE,ltMS3D_MD3: OGL_MD3_RenderFrame;
          ltMDMMDX,ltMDS,ltMS3D_MDMMDX: OGL_MDMMDX_RenderFrame;
        end;

//        glColorMask(GL_TRUE,GL_TRUE,GL_TRUE,GL_TRUE); //kleuren-data weer schrijven
        // tekenen waar stencil waarde 1 heeft..
        glStencilFunc(GL_EQUAL, 1, 1);
        glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
        // ..puur wit
        R := Rect(0,0,OGL.Width,OGL.Height);
        OGL.ColoredRectangle2D(R, 1,1,1, 1,1,1);
        OGL.SetupProjection; //projectie herstellen na 2D-mode..
        // klaar met stencil..
        glDisable(GL_STENCIL_TEST);

      glPopMatrix;
      glFlush;
//      OGL.DoBufferSwap;
      TakingScreenshot := false;
      //
(*
{      glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
      glPixelStorei(GL_PACK_ALIGNMENT, 1);}
      glPixelTransferf(GL_RED_SCALE, 10000);     // ik wil zeker weten wit zien!
      glPixelTransferf(GL_GREEN_SCALE, 10000);
      glPixelTransferf(GL_BLUE_SCALE, 10000);*)
      glReadPixels(0,0,gbOGL.Width,gbOGL.Height, GL_LUMINANCE, GL_UNSIGNED_BYTE, AlphaData);
(*      glPixelTransferf(GL_RED_SCALE, 1);
      glPixelTransferf(GL_GREEN_SCALE, 1);
      glPixelTransferf(GL_BLUE_SCALE, 1);
//      if glGetError <> GL_NO_ERROR then Exit;*)
    end;


    // RGB
    SetLength(PixelData, gbOGL.Width*gbOGL.Height*3);
    menuViewLighting.Checked := b;
    //
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glFrontFace(GL_CW);
    glCullFace(GL_BACK);
    glEnable(GL_CULL_FACE);
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_ALPHA_TEST);
    // de achtergrond kleur uit het menu halen..
    TColorToRGB(ConvertColor, cR,cG,cB);
    glClearColor(cR,cG,cB,0);
    glClear(GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT);
    glClearColor(0,0,0,0); //herstellen
    //
    glLoadIdentity;
    with OGL.Camera^ do gluLookAt(Position.X,Position.Y,Position.Z, Target.X,Target.Y,Target.Z, UpY.X,UpY.Y,UpY.Z);
    OGL.Frustum.Calculate_glFrustumPlanes;
    glPushMatrix;
      glPushMatrix;
        glLoadIdentity;
        InitLighting;
      glPopMatrix;
      glTranslatef(Model_Position.X,Model_Position.Y,Model_Position.Z);
      glRotatef(Model_Rotation.X, 1.0, 0.0, 0.0);
      glRotatef(Model_Rotation.Y, 0.0, 1.0, 0.0);
      glRotatef(Model_Rotation.Z, 0.0, 0.0, 1.0);
      glTranslatef(Model_Offset.X,Model_Offset.Y,Model_Offset.Z);
      case LoadedType of
        ltMD3,ltmap,ltASE,ltMS3D_MD3: OGL_MD3_RenderFrame;
        ltMDMMDX,ltMDS,ltMS3D_MDMMDX: OGL_MDMMDX_RenderFrame;
      end;
    glPopMatrix;
    glFlush;
//    OGL.DoBufferSwap;
    //
    glReadPixels(0,0,gbOGL.Width,gbOGL.Height, GL_RGB, GL_UNSIGNED_BYTE, PixelData);
//    if glGetError <> GL_NO_ERROR then Exit;


    // opslaan als TGA
    with Header do begin
      bIDFieldSize := 0;
      bClrMapType := 0;
      bImageType := 2;
      lClrMapSpec.wFirstEntryIndex := 0;
      lClrMapSpec.wLength := 0;
      lClrMapSpec.bEntrySize := 0;
      wXOrigin := 0;
      wYOrigin := 0;
      wWidth := gbOGL.Width;
      wHeight := gbOGL.Height;
      if TransparentBackground then bBitsPixel := 32
                               else bBitsPixel := 24;
      bImageDescriptor := $03; { $23{00100011b};
    end;

    if TransparentBackground then begin
      DataSize := gbOGL.Width*gbOGL.Height*4;
      SetLength(TGAData, DataSize);
      for p:=0 to gbOGL.Width*gbOGL.Height-1 do begin
        // swap RGB -> BGR
        TGAData[p*4]   := PixelData[p*3+2];
        TGAData[p*4+1] := PixelData[p*3+1];
        TGAData[p*4+2] := PixelData[p*3];
        TGAData[p*4+3] := AlphaData[p];
      end;
    end else begin
      DataSize := gbOGL.Width*gbOGL.Height*3;
      SetLength(TGAData, DataSize);
      for p:=0 to gbOGL.Width*gbOGL.Height-1 do begin
        // swap RGB -> BGR
        TGAData[p*3]   := PixelData[p*3+2];
        TGAData[p*3+1] := PixelData[p*3+1];
        TGAData[p*3+2] := PixelData[p*3];
      end;
    end;

    // vind de naam voor het bestand
    s := AppPath+'screenshot';
    p := 0;
    while FileExists(s+IntToStr(p)+'.tga') do Inc(p);
    s := s + IntToStr(p) +'.tga';
    //
    Fsave := TFileStream.Create(s, fmCreate);
    try
      try
        Fsave.WriteBuffer(Header, SizeOf(TTargaHeader));
        Fsave.WriteBuffer(TGAData[0], DataSize);
      except
      end;
    finally
      Fsave.Free;
    end;

    StatusBar.SimpleText := 'Screenshot saved into file: screenshot'+ IntToStr(p) +'.tga';

  finally
    SetLength(AlphaData, 0);
    SetLength(PixelData, 0);
    SetLength(TGAData, 0);
    menuViewLighting.Checked := b;
    TakingScreenshot := false;
    //InterruptPlayback := false;
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
  end;
end;


procedure TForm1.ShaderToTextureGraph(const Value: TTextureResource);
begin
  shapeSurfaceShader.Visible := ((Value and trSurface)>0);
  shapeShaderFile.Visible := false;
  shapeShaderFileIn.Visible := false;
  shapeShaderFileOut.Visible := false;
  shapeShaderTexture.Visible := false;
  shapeSkinFile.Visible := false;
  shapeSkinTexture.Visible := false;
  shapeTextureFile.Visible := false;
  shapeSkinShader.Visible := false;
  shapeSkinShaderlist.Visible := false;
  shapeShaderlist.Visible := false;
  shapeShaderlistIn.Visible := false;
  shapeShaderlistOut.Visible := false;
  shapeShaderlistShader.Visible := false;
  shapeShaderlistTexture.Visible := false;
  if (Value and trSkinFile)>0 then begin
    // skin gebruikt
    shapeSkinFile.Visible := true;
    if (Value and trShaderList)>0 then begin
      // skin, shaderlist
      shapeSkinShaderlist.Visible := true;
      shapeShaderlistIn.Visible := true;
      shapeShaderlistOut.Visible := true;
      if (Value and trShader)>0 then begin
        // skin, shaderlist, shader
        shapeShaderlistShader.Visible := true;
        shapeShaderFileIn.Visible := true;
        shapeShaderFileOut.Visible := true;
        shapeShaderTexture.Visible := true;
      end else begin
        if (Value and trTexture)>0 then begin
          // skin, shaderlist, texture
          shapeShaderlistTexture.Visible := true;
        end;
      end;
    end else begin
      // skin, geen shaderlist
      if (Value and trShader)>0 then begin
        // skin, shader
        shapeSkinShader.Visible := true;
        shapeShaderFileIn.Visible := true;
        shapeShaderFileOut.Visible := true;
        shapeShaderTexture.Visible := true;
      end else begin
        if (Value and trTexture)>0 then begin
          // skin, texture
          shapeSkinTexture.Visible := true;
        end;
      end;
    end;
  end else begin
    // geen skin gebruikt
    if (Value and trShaderList)>0 then begin
      // geen skin, shaderlist
      shapeShaderlist.Visible := true;
      shapeShaderlistIn.Visible := true;
      shapeShaderlistOut.Visible := true;
      if (Value and trShader)>0 then begin
        // geen skin, shaderlist, shader
        shapeShaderlistShader.Visible := true;
        shapeShaderFileIn.Visible := true;
        shapeShaderFileOut.Visible := true;
        shapeShaderTexture.Visible := true;
      end else begin
        if (Value and trTexture)>0 then begin
          shapeShaderlistTexture.Visible := true;
        end;
      end;
    end else begin
      // geen skin, geen shaderlist
      if (Value and trShader)>0 then begin
        // geen skin, geen shaderlist, shader
        shapeShaderFile.Visible := true;
        shapeShaderFileIn.Visible := true;
        shapeShaderFileOut.Visible := true;
        shapeShaderTexture.Visible := true;
      end else begin
        if (Value and trTexture)>0 then begin
          // geen skin, geen shaderlist, texture
          shapeTextureFile.Visible := true;
        end;
      end;
    end;
  end;
end;

procedure TForm1.TextureToForm(SurfaceIndex, TextureIndex: integer);
var ShowtextureProps, ShowShaderProps, b: boolean;
    ShaderIndex: integer;
    TextureHandle: cardinal;
begin
  ShowTextureProps := false;
  ShowShaderProps := false;

  ShaderIndex := -1;
  case LoadedType of
    ltMD3,ltMap,ltASE,ltMS3D_MD3:
      if (SurfaceIndex>-1) and (SurfaceIndex<Length(MD3.Header.Surfaces)) then
        if Length(MD3.Header.Surfaces[SurfaceIndex].Shaders)>0 then
          ShaderIndex := MD3.Header.Surfaces[SurfaceIndex].Shaders[0].Shader_Index;
    ltMDMMDX,ltMDS,ltMS3D_MDMMDX:
      if (SurfaceIndex>-1) and (SurfaceIndex<Length(MDM.Surfaces)) then
        ShaderIndex := MDM.Surfaces[SurfaceIndex].Values.ShaderIndex;
  end;
  img3DView.Visible := (ShaderIndex>-1); //afbeelding texture
  if (ShaderIndex>-1) and (ShaderIndex<Length(Shaders.ShaderFile)) then begin
    // texture info
    b := ((TextureIndex>-1) and (TextureIndex<Length(Shaders.ShaderFile[ShaderIndex].Textures)));
    if b then begin
      ShowTextureProps := true;
      cbHasAlpha.Checked := Shaders.ShaderFile[ShaderIndex].Textures[TextureIndex].HasAlphaData;
      leTextureDimensions.Text := IntToStr(Shaders.ShaderFile[ShaderIndex].Textures[TextureIndex].Width) +'x'+
                                  IntToStr(Shaders.ShaderFile[ShaderIndex].Textures[TextureIndex].Height);
      //!!
      TextureToImg(SurfaceIndex, TextureIndex);
      //!!
    end;
    img3DView.Visible := b;  //afbeelding texture
    // shader info
    ShowShaderProps := false;
    if (Shaders.ShaderFile[ShaderIndex].TextureResource and trShader)>0 then begin
      ShowShaderProps := true;
      if b then begin
        with Shaders.ShaderFile[ShaderIndex].Textures[TextureIndex] do begin
          //cbHasAlpha.Checked := HasAlphaData;
          cbAlphaFunc.Checked := (AlphaFunc<>afNone);
          cbEnvironmentMap.Checked := EnvMap;
          cbClamped.Checked := clamped;
          case Cull of
            cNone, cDisable, cTwoSided: leCull.Text := 'none';
            cFront: leCull.Text := 'front';
            cBack: leCull.Text := 'back';
          end;
          cbAnimMap.Checked := animMap;
          cbVideoMap.Checked := videoMap;
        end;
      end;
    end;
    //
  end;
  cbHasAlpha.Visible := ShowTextureProps;
  leTextureDimensions.Visible := ShowTextureProps;
  pShaderProps.Visible := ShowShaderProps;
  img3DView.Invalidate; //hehe belangrijk..
end;

procedure TForm1.SurfaceToForm(Index: integer);
var i,t, Len: integer;
    s: string;
    ShaderIndex: integer;
begin
  // comboboxes vullen..
  cbNamesShaders.Clear;
  cbShaderTextures.Clear;
  try
    case LoadedType of
      ltMD3,ltMap,ltASE,ltMS3D_MD3: begin
        if MD3.Header.Values.Num_Surfaces <= 0 then Exit;
        if Index >= MD3.Header.Values.Num_Surfaces then Exit;
        if Length(MD3.Header.Surfaces[Index].Shaders)=0 then Exit;
        ShaderIndex := MD3.Header.Surfaces[Index].Shaders[0].Shader_Index;
        leSurfaceFlags.Text := IntToHex(MD3.Header.Surfaces[Index].Values.Flags,8)+'h';
        for i:=0 to MD3.Header.Surfaces[Index].Values.Num_Shaders-1 do begin
          s := string(MD3.Header.Surfaces[Index].Shaders[i].Name);
          cbNamesShaders.Items.Add(s);
          if (ShaderIndex>=0) and (Length(Shaders.ShaderFile)>0) and (ShaderIndex<Length(Shaders.ShaderFile)) and (Length(Shaders.ShaderFile[ShaderIndex].Textures)>0) then
            for t:=0 to Length(Shaders.ShaderFile[ShaderIndex].Textures)-1 do begin
              s := Shaders.ShaderFile[ShaderIndex].Textures[t].Map;
              cbShaderTextures.Items.Add(s);
            end;
        end;
      end;
      ltMDMMDX,ltMDS,ltMS3D_MDMMDX: begin
        if MDM.Header.Num_Surfaces <= 0 then Exit;
        if Index >= MDM.Header.Num_Surfaces then Exit;
        ShaderIndex := MDM.Surfaces[Index].Values.ShaderIndex;
        s := string(MDM.Surfaces[Index].Values.ShaderName);
        cbNamesShaders.Items.Add(s);
          if (ShaderIndex>=0) and (Length(Shaders.ShaderFile)>0) and (ShaderIndex<Length(Shaders.ShaderFile)) and (Length(Shaders.ShaderFile[ShaderIndex].Textures)>0) then
            for t:=0 to Length(Shaders.ShaderFile[ShaderIndex].Textures)-1 do begin
              s := Shaders.ShaderFile[ShaderIndex].Textures[t].Map;
              cbShaderTextures.Items.Add(s);
            end;
      end;
    end;
  finally
    cbNamesShaders.ItemIndex := 0;
    cbShaderTextures.ItemIndex := 0;
{cbNamesShaders.ItemIndex := -1;
cbShaderTextures.ItemIndex := -1;}

//TextureToForm(Index, cbShaderTextures.ItemIndex);
    TextureToForm(cbNamesSurfaces.ItemIndex, cbShaderTextures.ItemIndex);

    ShaderToTextureGraph(trNone);
    if (ShaderIndex>=0) and (Length(Shaders.ShaderFile)>0) and (ShaderIndex<Length(Shaders.ShaderFile)) then begin
      if Index < cbShaderNameFound.Items.Count then cbShaderNameFound.ItemIndex := Index;
      ShaderToTextureGraph(Shaders.ShaderFile[ShaderIndex].TextureResource);
    end;

    case LoadedType of
      ltMD3,ltMap,ltASE,ltMS3D_MD3: begin
        if (Index>-1) and (Index<Length(MD3.Header.Surfaces)) then begin
          leNumShaders.Text := IntToStr(MD3.Header.Surfaces[Index].Values.Num_Shaders);
          leNumVerts.Text := IntToStr(MD3.Header.Surfaces[Index].Values.Num_Verts);
          leNumTriangles.Text := IntToStr(MD3.Header.Surfaces[Index].Values.Num_Triangles);
        end else begin
          leNumShaders.Text := '0';
          leNumVerts.Text := '0';
          leNumTriangles.Text := '0';
        end;
      end;
      ltMDMMDX,ltMDS,ltMS3D_MDMMDX: begin
        leNumShaders.Text := IntToStr(1);
        if (Index>-1) and (Index<Length(MDM.Surfaces)) then begin
          leNumVerts.Text := IntToStr(MDM.Surfaces[Index].Values.Num_Verts);
          leNumTriangles.Text := IntToStr(MDM.Surfaces[Index].Values.Num_Triangles);
        end else begin
          leNumVerts.Text := '0';
          leNumTriangles.Text := '0';
        end;
      end;
    end;

    cbShaderFile.ItemIndex := cbNamesSurfaces.ItemIndex;
    lNumTextures.Caption := IntToStr(cbShaderTextures.Items.Count);
    leNumSurfaces.Text := IntToStr(cbNamesSurfaces.Items.Count);
    cbShaderTextures.ItemIndex := 0;

    // skin-shader of skin-texture afbeelden
    s := '';
    Len := Length(SkinShaders);
    if Len>0 then
      for i:=0 to Len-1 do
        case LoadedType of
          ltMD3,ltMap,ltASE,ltMS3D_MD3: begin
            if SkinShaders[i].SurfaceName = LowerCase(string(MD3.Header.Surfaces[Index].Values.Name)) then begin
              // skin gevonden
              s := SkinShaders[i].ShaderName; // is eigenlijk: Skin[i].ShaderName
              Break;
            end;
          end;
          ltMDMMDX,ltMDS,ltMS3D_MDMMDX: begin
            if SkinShaders[i].SurfaceName = LowerCase(string(MDM.Surfaces[Index].Values.SurfaceName)) then begin
              // skin gevonden
              s := SkinShaders[i].ShaderName; // is eigenlijk: Skin[i].ShaderName
              Break;
            end;
          end;
        end;
    leSkin.Text := s;
  end;  
end;


procedure TForm1.AutoZoom;
var MaxSizeX,MaxSizeY,MaxSizeZ,MaxSize,
    X,Y,Z, MinX,MaxX,MinY,MaxY,MinZ,MaxZ: Single;
//    CenterX,CenterY,CenterZ: Single;
    s,v: integer;
    NumFrames, NumSurfaces, NumVerts: cardinal;
begin
  case LoadedType of
    ltNone: Exit;
    ltMD3,ltMap,ltASE,ltMS3D_MD3: begin
      NumSurfaces := MD3.Header.Values.Num_Surfaces;
      NumFrames := MD3.Header.Values.Num_Frames;
    end;
    ltMDMMDX,ltMDS,ltMS3D_MDMMDX: begin
      NumSurfaces := MDM.Header.Num_Surfaces;
      NumFrames := MDX.Header.Num_Frames;
    end;
  end;

  // breng het model goed passend in beeld
  if NumFrames<1 then Exit;
  if NumSurfaces=0 then begin
    MaxSizeX := (MD3.Header.Frames[0].Max_Bounds.X - MD3.Header.Frames[0].Min_Bounds.X);
    MaxSizeY := (MD3.Header.Frames[0].Max_Bounds.Y - MD3.Header.Frames[0].Min_Bounds.Y);
    MaxSizeZ := (MD3.Header.Frames[0].Max_Bounds.Z - MD3.Header.Frames[0].Min_Bounds.Z);
    MaxSize := MaxSizeX;
    if MaxSizeY>MaxSize then MaxSize := MaxSizeY;
    if MaxSizeZ>MaxSize then MaxSize := MaxSizeZ;
    // sommige modellen hebben een boundingbox van [-1,1]
    //if MaxSize=2 then begin
  end else begin
    // zoek de min/max
    MinX := 3.4E38;
    MaxX := 1.5E-45;
    MinY := 3.4E38;
    MaxY := 1.5E-45;
    MinZ := 3.4E38;
    MaxZ := 1.5E-45;
    for s:=0 to NumSurfaces-1 do begin
      case LoadedType of
        ltMD3,ltMap,ltASE,ltMS3D_MD3: NumVerts := MD3.Header.Surfaces[s].Values.Num_Verts;
        ltMDMMDX,ltMDS,ltMS3D_MDMMDX: begin
          NumVerts := MDM.Surfaces[s].Values.Num_Verts;
          MDM.CalcModel(MDX,0,s);
        end;
      end;
      // alle vertex (van frame[0])
      for v:=0 to NumVerts-1 do begin
        case LoadedType of
          ltMD3,ltMap,ltASE,ltMS3D_MD3: begin
            X := MD3.Header.Surfaces[s].Vertex[v].X * MD3_XYZ_SCALE;
            Y := MD3.Header.Surfaces[s].Vertex[v].Y * MD3_XYZ_SCALE;
            Z := MD3.Header.Surfaces[s].Vertex[v].Z * MD3_XYZ_SCALE;
          end;
          ltMDMMDX,ltMDS,ltMS3D_MDMMDX: begin
            X := MDM.VertexPos[v].X {* MD3_XYZ_SCALE};
            Y := MDM.VertexPos[v].Y {* MD3_XYZ_SCALE};
            Z := MDM.VertexPos[v].Z {* MD3_XYZ_SCALE};
          end;
        end;
        if X<MinX then MinX:=X;
        if X>MaxX then MaxX:=X;
        if Y<MinY then MinY:=Y;
        if Y>MaxY then MaxY:=Y;
        if Z<MinZ then MinZ:=Z;
        if Z>MaxZ then MaxZ:=Z;
      end;
    end;
    MaxSizeX := (MaxX-MinX);
    MaxSizeY := (MaxY-MinY);
    MaxSizeZ := (MaxZ-MinZ);
    MaxSize := MaxSizeX;
    if MaxSizeY>MaxSize then MaxSize := MaxSizeY;
    if MaxSizeZ>MaxSize then MaxSize := MaxSizeZ;
  end;
  CenterX := MinX + (MaxSizeX/2);
  CenterY := MinY + (MaxSizeY/2);
  CenterZ := MinZ + (MaxSizeZ/2);
  Model_Offset := Vector(-CenterX,-CenterY,-CenterZ);
  Model_Matrix := IdentityMatrix4x4;
  Model_Rotation := NullVector;
  Model_Position := NullVector;
  // inzoomen naargelang de grootte van het model: FOV=60°
  ZoomDistance := Round(Tan(60.0*constDegToRad/2.0) * (MaxSize*2.0));
  OGL.Camera.Position := Vector(0,0,ZoomDistance);
  OGL_RenderFrame;
end;

procedure TForm1.ResetModelTransform;
begin
  if cbLockView.Checked then Exit;
  Model_Matrix := IdentityMatrix4x4;
  Model_Rotation := Vector(90,0,0); //NullVector;
  Model_Position := NullVector;
  Model_Offset := NullVector;
  if OGL.Active then OGL.Camera.Target := NullVector;
  AutoZoom;
end;

procedure TForm1.SetupAnimation;
var b: boolean;
    Nr: integer;
begin
  // animatie stoppen
  case LoadedType of
    ltMD3,ltMap,ltASE,ltMS3D_MD3: Nr := MD3.Header.Values.Num_Frames;
    ltMDMMDX,ltMDS,ltMS3D_MDMMDX: Nr := MDX.Header.Num_Frames;
  else
    Nr := 0;
  end;
  b := (Nr>1);
  gbAnimationControls.Enabled := b;
{  TimerFPS.Enabled := b;
  cbPlay.Checked := b;}
  if Nr=0 then begin
    tbStartFrame.Max := 0;
    tbEndFrame.Max := 0;
    tbCurrentFrame.Max := 0;
  end else begin
    tbStartFrame.Max := Nr-1;
    tbEndFrame.Max := Nr-1;
    tbCurrentFrame.Max := Nr-1;
  end;
  Current_Frame := 0;
  tbStartFrame.Position := 0;
  tbEndFrame.Position := tbEndFrame.Max;
  lStartFrame.Caption := IntToStr(tbStartFrame.Position);
  lEndFrame.Caption := IntToStr(tbEndFrame.Position);
  tbCurrentFrame.Position := Current_Frame;
  tbCurrentFrame.SelStart := tbStartFrame.Position;
  tbCurrentFrame.SelEnd := tbEndFrame.Position;
end;


procedure TForm1.InitLighting;
type Tf4 = array[0..3] of Single;
const Material_Specular: Tf4 = (0.2, 0.2, 0.2, 1.0);
      Material_Shininess: Single = 16.0;
      Material_Emission: Tf4 = (1.0, 1.0, 1.0, 1.0);
      Light0_Position: Tf4 = (0.0, 6000.0, 0.0, 1.0);
      Light1_Position: Tf4 = (-6000.0, -6000.0, 6000.0, 0.0);
      Light_Color: Tf4 = (1.0, 1.0, 1.0, 0.0);
      Light_Ambient: Tf4 = (0.2, 0.2, 0.2, 1.0);
      Model_Ambient: Tf4 = (0.2, 0.2, 0.2, 1.0);
begin
//  glShadeModel(GL_SMOOTH);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @Material_Specular);
  glMaterialfv(GL_FRONT, GL_SHININESS, @Material_Shininess);
//  glMaterialfv(GL_FRONT, GL_EMISSION, @Material_Emission);
  glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER, ord(GL_FALSE));
  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @Model_Ambient);
  glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL, GL_SEPARATE_SPECULAR_COLOR);

  glLightfv(GL_LIGHT0, GL_POSITION, @Light0_Position);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @Light_Color);
  glLightfv(GL_LIGHT0, GL_SPECULAR, @Light_Color);
  glLightfv(GL_LIGHT0, GL_AMBIENT, @Light_Ambient);

  glLightfv(GL_LIGHT1, GL_POSITION, @Light1_Position);
  glLightfv(GL_LIGHT1, GL_DIFFUSE, @Light_Color);
  glLightfv(GL_LIGHT1, GL_SPECULAR, @Light_Color);
  glLightfv(GL_LIGHT1, GL_AMBIENT, @Light_Ambient);

//  glLightf(GL_LIGHT0, GL_CONSTANT_ATTENUATION, 1.0);
  glEnable(GL_LIGHT0);
  glEnable(GL_LIGHT1);
  if menuViewLighting.Checked then
    glEnable(GL_LIGHTING)
  else
    glDisable(GL_LIGHTING);
end;



procedure TForm1.OGL_RenderFrame;
const Light1_Position: array[0..3] of single = (0.0, 0.0, 2000.0, 1.0);
var M: TMatrix4x4;
    x,y: integer;
begin
  if pcTabs.ActivePage <> tabView then Exit;
  if not OGL.Active then Exit;
  if InterruptPlayback then Exit;
  if TakingScreenshot then Exit;

  // RenderContext actief maken..
  OGL.MakeCurrent;

  glEnable(GL_DEPTH_TEST);
  glDepthFunc(GL_LESS);
  glFrontFace(GL_CW);
  glCullFace(GL_BACK);
  glEnable(GL_CULL_FACE);
  glDisable(GL_TEXTURE_2D);
  glDisable(GL_ALPHA_TEST);

  //--- scherm wissen ----------------------------------------------------------
  if OGL.SkyBox.Active and (not OGL.SkyBox.Paused) then
    glClear(GL_DEPTH_BUFFER_BIT)
  else begin
    glClear(GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT);
//OGL.PrintLine(0, '', laTop, 1,1,1); //DUMMY!!!!!DEBUG!!!!!
    OGL.ColoredRectangle2D(gbOGL.ClientRect, SkyColorTop, SkyColorBottom);
    OGL.SetupProjection; //projectie herstellen met de laatst gebruikte lokale instellingen..
  end;

  //--- MODELVIEW instellen
  glLoadIdentity;
  //--- camera plaatsen --------------------------------------------------------
  with OGL.Camera^ do gluLookAt(Position.X,Position.Y,Position.Z, Target.X,Target.Y,Target.Z, UpY.X,UpY.Y,UpY.Z);
  // de frustum clipping-planes berekenen
  OGL.Frustum.Calculate_glFrustumPlanes;

  //--- 3D tekenen vanaf hier... -----------------------------------------------
  glPushMatrix;
    // moving light 0
    glPushMatrix;
      glLoadIdentity;
      InitLighting;
    glPopMatrix;
    // stationary light 1
    glLightfv(GL_LIGHT1, GL_POSITION, @Light1_Position);
    //

    glTranslatef(Model_Position.X,Model_Position.Y,Model_Position.Z);
    if cbMouseControl.Checked then begin
//      glMatrixMode(GL_MODELVIEW);
      glMultMatrixf(@Model_Matrix);
      glTranslatef(Model_Offset.X,Model_Offset.Y,Model_Offset.Z);
    end else begin
      glRotatef(Model_Rotation.X, 1.0, 0.0, 0.0);
      glRotatef(Model_Rotation.Y, 0.0, 1.0, 0.0);
      glRotatef(Model_Rotation.Z, 0.0, 0.0, 1.0);
    end;
    case LoadedType of
      ltMD3,ltMap,ltASE,ltMS3D_MD3: TagPivotMD3;
      ltMDMMDX,ltMDS,ltMS3D_MDMMDX: TagPivotMDMMDX;
    end;
    if not cbMouseControl.Checked then
      glTranslatef(Model_Offset.X,Model_Offset.Y,Model_Offset.Z);

    // teken groundplane + axis
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_LIGHTING);
    // grond vlak
    if cbShowGroundplane.Checked then begin
      glColor3f(0.7,0.7,0.7);
      for x:=-30 to 30 do begin
        glBegin(GL_LINES);
          glVertex3f(x*10, -300, 0);
          glVertex3f(x*10, 300, 0);
        glEnd;
      end;
      for y:=-30 to 30 do begin
        glBegin(GL_LINES);
          glVertex3f(-300, y*10, 0);
          glVertex3f(300, y*10, 0);
        glEnd;
      end;
    end;
    glDisable(GL_DEPTH_TEST);
    // assenstelsel
    if cbShowAxis.Checked then begin
      // X
      glColor3f(1,0,0);
      glBegin(GL_LINES);
        glVertex3f(0,0,0);
        glVertex3f(300,0,0);
      glEnd;
      // Y
      glColor3f(0,1,0);
      glBegin(GL_LINES);
        glVertex3f(0,0,0);
        glVertex3f(0,300,0);
      glEnd;
      // Z
      glColor3f(0,0,1);
      glBegin(GL_LINES);
        glVertex3f(0,0,0);
        glVertex3f(0,0,300);
      glEnd;
    end;
    glEnable(GL_DEPTH_TEST);
    if cbLightingEnabled.Checked then glEnable(GL_LIGHTING)
                                 else glDisable(GL_LIGHTING);

    // Render model
    if cbSmoothFlat.Checked then glShadeModel(GL_FLAT)
                            else glShadeModel(GL_SMOOTH);
    if cbTwoSided.Checked then begin
      if cbWireframe.Checked then glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
                             else glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    end else begin
      if cbWireframe.Checked then glPolygonMode(GL_FRONT, GL_LINE)
                             else glPolygonMode(GL_FRONT, GL_FILL);
    end;
    // tekenen
    case LoadedType of
      ltMD3,ltMap,ltASE,ltMS3D_MD3: OGL_MD3_RenderFrame;
      ltMDMMDX,ltMDS,ltMS3D_MDMMDX: OGL_MDMMDX_RenderFrame;
    end;

  glPopMatrix;

  //--- de achtergrond ---------------------------------------------------------
  glShadeModel(GL_SMOOTH);  //anders wordt de achtergrond 1-kleurig..
  // altijd eerst de virtuele wereld tekenen, en daarna de skybox,
  // zodat de Z-buffer al is gevuld ten tijde tekenen skybox.
  if OGL.SkyBox.Active and (not OGL.SkyBox.Paused) then
    OGL.SkyBox.Render(OGL.Camera^);

  // Frame afhandelen ----------------------------------------------------------
  glFlush;
  // buffers wisselen
  OGL.DoBufferSwap;
end;


// test routine tbv MDM
procedure TForm1.OGL_MDMMDX_RenderFrame;
const TagAxisSize = 10.0;
      NormalSize = 3.0;
var s,t,tp: integer;
    i1,i2,i3,
    v1,v2,v3: integer;
    x1,y1,z1,        // vertex 1
    x2,y2,z2,        // vertex 2
    x3,y3,z3,        // vertex 3
    nx1,ny1,nz1,     // normal 1
    nx2,ny2,nz2,     // normal 2
    nx3,ny3,nz3,     // normal 3
    ts1,tt1,         // texcoord 1
    ts2,tt2,         // texcoord 2
    ts3,tt3: single; // texcoord 3
    N1,N2,N3,AvgNormal,
    Vec1,Vec2,Vec3, AvgVec: TVector;
    textured, DoTexturePass,
    DoEnvMap, DoClamp, DoAlpha,HasAlpha, DoPolyOffset: boolean;
    TexturePass: integer;
    TextureHandle, ShaderIndex,
    SrcBlend, DstBlend: cardinal;
    AlphaTest, multiAlphaTest: TAlphaFunc;
    ShaderCull: TCull;
    CountTextures, CountHasAlpha, CountLightmap: integer;
    pidx, bi: integer;
  //----------------------
  procedure DrawTriangles(SurfaceNr,TexturePasses: integer);
  var TU,tp, first: integer;
      t: integer;
      s: string;
  begin
    if (SurfaceNr<0) or (SurfaceNr>=MDM.Header.Num_Surfaces) then Exit;
    if MDX.Header.Num_Bones=0 then Exit;

    MDM.CalcModel(MDX, Current_Frame, SurfaceNr);

    // tekenen:
    // alphafunc
    case AlphaTest of
      afNone: begin
                glAlphaFunc(GL_GREATER, 0);
                glDisable(GL_ALPHA_TEST);
                glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
              end;
      afGT0:  begin
                glEnable(GL_ALPHA_TEST);
                glAlphaFunc(GL_GREATER, 0);
                glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
              end;
      afLT128: begin
                 glEnable(GL_ALPHA_TEST);
                 glAlphaFunc(GL_LESS, 0.5);
                 glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
               end;
      afGE128: begin
                 glEnable(GL_ALPHA_TEST);
                 glAlphaFunc(GL_GEQUAL, 0.5);
                 glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
               end;
      else begin
        // afNone
        glAlphaFunc(GL_GREATER, 0);
        glDisable(GL_ALPHA_TEST);
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
      end;
    end;


    // triangles afbeelden
    if cbLightingEnabled.Checked then glEnable(GL_LIGHTING)
                                 else glDisable(GL_LIGHTING);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glDepthMask(GL_TRUE);  //ook in de z-buffer schrijven..

    if cbTwoSided.Checked then begin
      glCullFace(GL_NONE);
      glDisable(GL_CULL_FACE);
    end;

//    glDisable(GL_TEXTURE_2D);
{    glFrontFace(GL_CW);
    glEnable(GL_CULL_FACE);}
    for t:=0 to MDM.Surfaces[SurfaceNr].Values.Num_Triangles-1 do begin
{      v1 := MDM.Surfaces[SurfaceNr].Triangles[t].VertexIndexes[0];
      v2 := MDM.Surfaces[SurfaceNr].Triangles[t].VertexIndexes[1];
      v3 := MDM.Surfaces[SurfaceNr].Triangles[t].VertexIndexes[2];}
      v1 := MDM.Surfaces[SurfaceNr].Triangles[t][0];
      v2 := MDM.Surfaces[SurfaceNr].Triangles[t][1];
      v3 := MDM.Surfaces[SurfaceNr].Triangles[t][2];
      // texcoords 1
      ts1 := MDM.Surfaces[SurfaceNr].Vertex[v1].TexCoordU;
      tt1 := 1.0 - MDM.Surfaces[SurfaceNr].Vertex[v1].TexCoordV;
      // texcoords 2
      ts2 := MDM.Surfaces[SurfaceNr].Vertex[v2].TexCoordU;
      tt2 := 1.0 - MDM.Surfaces[SurfaceNr].Vertex[v2].TexCoordV;
      // texcoords 3
      ts3 := MDM.Surfaces[SurfaceNr].Vertex[v3].TexCoordU;
      tt3 := 1.0 - MDM.Surfaces[SurfaceNr].Vertex[v3].TexCoordV;
      //
(*test
MDM.VertexNormal[v1] := InverseVector(MDM.VertexNormal[v1]);
MDM.VertexNormal[v2] := InverseVector(MDM.VertexNormal[v2]);
MDM.VertexNormal[v3] := InverseVector(MDM.VertexNormal[v3]);
*)
      glBegin(GL_TRIANGLES);
        glColor3f(1,1,1);

        // v1
        if not TakingScreenshot then begin
          with MDM.VertexNormal[v1] do glNormal3f(X, Y, Z);
//        with MDM.Surfaces[SurfaceNr].Vertex[v1] do glTexCoord2f(TexCoordU, TexCoordV);
          first := 0;
          if not DoAlpha then begin
            first := 1;
            glMultiTexCoord2f(GL_TEXTURE0, ts1,tt1);
          end;
          if TexturePasses > first then
            for TU:=0 to Length(Shaders.ShaderFile[ShaderIndex].Textures)-1 do
              if not Shaders.ShaderFile[ShaderIndex].Textures[TU].EnvMap then
                if Shaders.ShaderFile[ShaderIndex].Textures[TU].TextureHandle>0 then
                  glMultiTexCoord2f(GL_TEXTURE0+TU+first, ts1,tt1);
        end;
        with MDM.VertexPos[v1] do glVertex3f(X, Y, Z);

        // v2
        if not TakingScreenshot then begin
          with MDM.VertexNormal[v2] do glNormal3f(X, Y, Z);
//        with MDM.Surfaces[SurfaceNr].Vertex[v2] do glTexCoord2f(TexCoordU, TexCoordV);
          first := 0;
          if not DoAlpha then begin
            first := 1;
            glMultiTexCoord2f(GL_TEXTURE0, ts2,tt2);
          end;
          if TexturePasses > first then
            for TU:=0 to Length(Shaders.ShaderFile[ShaderIndex].Textures)-1 do
              if not Shaders.ShaderFile[ShaderIndex].Textures[TU].EnvMap then
                if Shaders.ShaderFile[ShaderIndex].Textures[TU].TextureHandle>0 then
                  glMultiTexCoord2f(GL_TEXTURE0+TU+first, ts2,tt2);
        end;
        with MDM.VertexPos[v2] do glVertex3f(X, Y, Z);

        // v3
        if not TakingScreenshot then begin
          with MDM.VertexNormal[v3] do glNormal3f(X, Y, Z);
//        with MDM.Surfaces[SurfaceNr].Vertex[v3] do glTexCoord2f(TexCoordU, TexCoordV);
          first := 0;
          if not DoAlpha then begin
            first := 1;
            glMultiTexCoord2f(GL_TEXTURE0, ts3,tt3);
          end;
          if TexturePasses > first then
            for TU:=0 to Length(Shaders.ShaderFile[ShaderIndex].Textures)-1 do
              if not Shaders.ShaderFile[ShaderIndex].Textures[TU].EnvMap then
                if Shaders.ShaderFile[ShaderIndex].Textures[TU].TextureHandle>0 then
                  glMultiTexCoord2f(GL_TEXTURE0+TU+first, ts3,tt3);
        end;
        with MDM.VertexPos[v3] do glVertex3f(X, Y, Z);
      glEnd;
    end;

    //Inc(TexturePass);
  end;
  //----------------------
  procedure ResetTUs;
  var TU: integer;
  begin
    for TU:=0 to MaxTU-1 do begin
      glActiveTextureARB(GL_TEXTURE0_ARB + TU);
      glEnable(GL_DEPTH_TEST);
      glDepthFunc(GL_LESS);
      glDisable(GL_BLEND);
      glDisable(GL_TEXTURE_2D);
      glDisable(GL_ALPHA_TEST);
      glAlphaFunc(GL_GREATER, 0);
      glDisable(GL_POLYGON_OFFSET_FILL);
      glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    end;
    glActiveTextureARB(GL_TEXTURE0_ARB);
  end;
  //----------------------
  procedure NextTexturePass(SurfaceNr: integer);
  begin
    Inc(TexturePass);
    if TexturePass = MaxTU then begin
      DrawTriangles(SurfaceNr,TexturePass-1);
      ResetTUs;
      TexturePass := 0;
    end;
  end;
  //----------------------
  procedure Brightness(Value: Single);   //test
  var rev: Single;
  begin
    if Value > 1.0 then begin
      rev := Value - 1.0;
      glBlendFunc(GL_DST_COLOR, GL_ONE);
      glColor3f(rev, rev, rev);
    end else begin
      glBlendFunc(GL_ZERO, GL_SRC_COLOR);
      glColor3f(Value, Value, Value);
    end;
    glEnable(GL_BLEND);
    glBegin(GL_QUADS);
      glVertex3f(-1000,-1000,1000);
      glVertex3f(1000,-1000,1000);
      glVertex3f(1000,1000,1000);
      glVertex3f(-1000,1000,1000);
    glEnd;
  end;  
  //----------------------
begin
  if pcTabs.ActivePage <> tabView then Exit;
  if not OGL.Active then Exit;
  if InterruptPlayback then Exit;

  // collapsemap afbeelden ipv normaal model -----------------------------------
  if cbLODEnabled.Checked then begin
    for s:=0 to MDM.Header.Num_Surfaces-1 do
      CM.DrawModelTrianglesMDM(Current_Frame, s, MDM.LOD_minimums[s].Value);
    Exit;
  end; //-----------------------------------------------------------------------


  //glEnable(GL_DEPTH_TEST);
  for s:=0 to MDM.Header.Num_Surfaces-1 do begin

    ShaderIndex := MDM.Surfaces[s].Values.ShaderIndex;

    // rgbidentity, vol wit renderen --------------------------
    textured := false;
    TexturePass := 0;
    tp := 0; //index in array surface[x].textures

    ResetTUs;

    // surfaces met een alphaFunc texture niet tekenen als rbgidentity
    DoAlpha := false;
    if (Length(Shaders.ShaderFile)>0) and (ShaderIndex<Length(Shaders.ShaderFile)) then begin
      for t:=0 to Length(Shaders.ShaderFile[ShaderIndex].Textures)-1 do begin
        // shader met AlphaFunc??
        if Shaders.ShaderFile[ShaderIndex].Textures[t].AlphaFunc<>afNone then
          if Shaders.ShaderFile[ShaderIndex].Textures[t].HasAlphaData then begin
            DoAlpha:=true;
            Break;
          end;
      end;
    end;
    if not DoAlpha then begin
      glActiveTextureARB(GL_TEXTURE0_ARB {+ TexturePass});
      glDisable(GL_BLEND);
      glDisable(GL_TEXTURE_2D);
      glDepthFunc(GL_LESS);
      glColor4f(1.0,1.0,1.0, 1.0);
{        if (Length(ShaderFile)>0) and
         (Length(ShaderFile[s].Textures)=1) and
         (ShaderFile[s].Textures[0].HasAlphaData) then begin
        //
      end else}
        NextTexturePass(s);
    end;
    //---------------------------------------------------------

    //
    {TexturePass := 0;}
    DoTexturePass := true;
    while DoTexturePass do begin
      glActiveTextureARB(GL_TEXTURE0_ARB + TexturePass);
      glDisable(GL_BLEND);
      glDisable(GL_TEXTURE_2D);
      glDisable(GL_ALPHA_TEST);
      glDisable(GL_TEXTURE_GEN_S);
      glDisable(GL_TEXTURE_GEN_T);
      glDisable(GL_POLYGON_OFFSET_FILL);

      // texture kiezen
      TextureHandle := 0;
      textured := (TextureHandle<>0);
      if (Length(Shaders.ShaderFile)>0) and (ShaderIndex<Length(Shaders.ShaderFile)) then begin
        if tp < Length(Shaders.ShaderFile[ShaderIndex].Textures) then begin
          TextureHandle := Shaders.ShaderFile[ShaderIndex].Textures[tp].TextureHandle;
          SrcBlend := Shaders.ShaderFile[ShaderIndex].Textures[tp].BlendFuncSrc;
          DstBlend := Shaders.ShaderFile[ShaderIndex].Textures[tp].BlendFuncDst;
          AlphaTest := Shaders.ShaderFile[ShaderIndex].Textures[tp].AlphaFunc;
          DoEnvMap := Shaders.ShaderFile[ShaderIndex].Textures[tp].EnvMap;
          DoClamp := Shaders.ShaderFile[ShaderIndex].Textures[tp].clamped;
          DoPolyOffset := Shaders.ShaderFile[ShaderIndex].Textures[tp].PolygonOffset;
          HasAlpha := Shaders.ShaderFile[ShaderIndex].Textures[tp].HasAlphaData;
          ShaderCull := Shaders.ShaderFile[ShaderIndex].Textures[tp].Cull;
          Shaders.ShaderFile[ShaderIndex].Textures[tp].TexturePass := tp;  //!!!!!!!!!!!!!!!!!!!
          textured := (TextureHandle<>0);
        end else
          Break; //klaar met tekenen
      end else
        Break; //klaar met tekenen
        //DoTexturePass := false; // er zijn geen shader-textures geladen..alleen colored-vertex tekenen

      if TexturePass=0 then begin
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
        glDepthFunc(GL_LESS);
      end else begin
        if HasAlpha then glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL)
                    else glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
        glDepthFunc(GL_LEQUAL);
      end;

      if cbTwoSided.Checked then begin
        glCullFace(GL_NONE);
        glDisable(GL_CULL_FACE);
      end else
        case ShaderCull of
          cFront: begin
              glCullFace(GL_FRONT);
              glEnable(GL_CULL_FACE);
            end;
          cBack: begin
              glCullFace(GL_BACK);
              glEnable(GL_CULL_FACE);
            end;
          else begin
            glCullFace(GL_NONE);
            glDisable(GL_CULL_FACE);
          end;
        end;

      if textured then begin
        // clampmap
        if DoClamp then begin
          glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
          glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        end else begin
          // map
          glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
          glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        end;

        // tcGen enviroment
        if DoEnvMap then begin
          glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
          glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
          glEnable(GL_TEXTURE_GEN_S);
          glEnable(GL_TEXTURE_GEN_T);
        end else begin
          glDisable(GL_TEXTURE_GEN_S);
          glDisable(GL_TEXTURE_GEN_T);
        end;

        // polygonOffset
        if DoPolyOffset then begin
          //glPolygonMode(GL_BACK, GL_FILL);
//            glPolygonOffset(1.0, 1.0);
//            glEnable(GL_POLYGON_OFFSET_FILL);
        end else begin
//            glDisable(GL_POLYGON_OFFSET_FILL);
        end;

        // blending & alpha
        glEnable(GL_BLEND);
        glBlendFunc(SrcBlend, DstBlend);

        // selecteer de texture
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, TextureHandle);

      end else begin
        // no textureHandle
        glDisable(GL_BLEND);
        glDisable(GL_TEXTURE_2D);
        //glDisable(GL_TEXTURE_GEN_S);
        //glDisable(GL_TEXTURE_GEN_T);
        //glBlendFunc(GL_ZERO,GL_ONE);  //!niet textured? dan niets tekenen
      end;

      // teken surface
      NextTexturePass(s);
      // volgende texture
      Inc(tp);

    end;
    // flush indien niet alle texturepasses zijn getekend
    if TexturePass>0 then DrawTriangles(s,TexturePass);
    ResetTUs;
  end;

  glActiveTextureARB(GL_TEXTURE0_ARB);
  ResetTUs;
  glDisable(GL_BLEND);
  glDisable(GL_TEXTURE_2D);
  glDisable(GL_ALPHA_TEST);
  glDepthFunc(GL_LESS);
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_CULL_FACE);
  glDisable(GL_POLYGON_OFFSET_FILL);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  glDisable(GL_TEXTURE_GEN_S);
  glDisable(GL_TEXTURE_GEN_T);
  glDisable(GL_LIGHTING);

//glDepthMask(GL_TRUE);

  //--- extra's afbeelden..
  glDisable(GL_LIGHTING);
  glDisable(GL_TEXTURE_2D);
  glEnable(GL_DEPTH_TEST);
  glDepthFunc(GL_ALWAYS);
  glFrontFace(GL_CW);
{    glCullFace(GL_BACK);
  glFrontFace(GL_FRONT);}
  glDisable(GL_CULL_FACE);
  glDisable(GL_BLEND);
//  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

  MDM.CalcModel(MDX, Current_Frame, 0);

  // teken skeleton
  if cbShowSkeleton.Checked then
    if MDX.Header.Num_Bones>0 then begin
      for bi:=0 to MDX.Header.Num_Bones-1 do begin
        // lijn tekenen naar parent-bone
        pidx := MDX.Bones[bi].ParentIndex;
        if pidx <> -1 then begin
          glBegin(GL_LINES);
            glColor3f(1,0.5,0);
            with MDM.BonePos[bi] do glVertex3f(X,Y,Z);
            with MDM.BonePos[pidx] do glVertex3f(X,Y,Z);
          glEnd;
          glPointSize(4.0);
        end else begin
          // de root-bone
          glPointSize(10.0);
        end;;
        // punt tekenen
        glBegin(GL_POINTS);
          glColor3f(1,0.9,0);
          with MDM.BonePos[bi] do glVertex3f(X,Y,Z);
        glEnd;
      end;
    end;

  // De tags afbeelden
  if cbShowTags.Checked then
    if MDM.Header.Num_Tags>0 then begin
      for t:=0 to MDM.Header.Num_Tags-1 do begin
        // tag-origin
        x1 := MDM.TagOrigin[t].X;
        y1 := MDM.TagOrigin[t].Y;
        z1 := MDM.TagOrigin[t].Z;
        //
        glBegin(GL_LINES);
          //
          x2 := MDM.TagAxis[t][0].X * TagAxisSize;
          y2 := MDM.TagAxis[t][0].Y * TagAxisSize;
          z2 := MDM.TagAxis[t][0].Z * TagAxisSize;
          glColor3f(1,0,0);
          glVertex3f(x1,y1,z1);
          glVertex3f(x1+x2,y1+y2,z1+z2);
          //
          x2 := MDM.TagAxis[t][1].X * TagAxisSize;
          y2 := MDM.TagAxis[t][1].Y * TagAxisSize;
          z2 := MDM.TagAxis[t][1].Z * TagAxisSize;
          glColor3f(0,1,0);
          glVertex3f(x1,y1,z1);
          glVertex3f(x1+x2,y1+y2,z1+z2);
          //
          x2 := MDM.TagAxis[t][2].X * TagAxisSize;
          y2 := MDM.TagAxis[t][2].Y * TagAxisSize;
          z2 := MDM.TagAxis[t][2].Z * TagAxisSize;
          glColor3f(0,0,1);
          glVertex3f(x1,y1,z1);
          glVertex3f(x1+x2,y1+y2,z1+z2);
        glEnd;
      end;
    end;

  // normalen afbeelden
  if cbShowNormals.Checked then
    for s:=0 to MDM.Header.Num_Surfaces-1 do begin
      MDM.CalcModel(MDX, Current_Frame, s); //----------------------------------
      if MDM.Surfaces[s].Values.Num_Triangles>0 then
        for t:=0 to MDM.Surfaces[s].Values.Num_Triangles-1 do begin
          // vertex index
          i1 := MDM.Surfaces[s].Triangles[t][0];
          i2 := MDM.Surfaces[s].Triangles[t][1];
          i3 := MDM.Surfaces[s].Triangles[t][2];
          // vertex normalen
          N1 := MDM.VertexNormal[i1];
          N2 := MDM.VertexNormal[i2];
          N3 := MDM.VertexNormal[i3];
          // vlak normaal
          AvgNormal := AverageVector([N1,N2,N3]);
          // vlak origin
          Vec1 := MDM.VertexPos[i1];
          Vec2 := MDM.VertexPos[i2];
          Vec3 := MDM.VertexPos[i3];
          AvgVec := AverageVector([Vec2,Vec1,Vec3]);
          // tekenen
          x2 := AvgNormal.X * NormalSize;
          y2 := AvgNormal.Y * NormalSize;
          z2 := AvgNormal.Z * NormalSize;
          glBegin(GL_LINES);
            glColor3f(0.3,0.7,0.1);
            glVertex3f(AvgVec.X,AvgVec.Y,AvgVec.Z);
            glVertex3f(AvgVec.X+x2,AvgVec.Y+y2,AvgVec.Z+z2);
          glEnd;
        end;
    end;
  //
  glEnable(GL_DEPTH_TEST);
  glDepthMask(GL_TRUE);
  glDepthFunc(GL_LESS);
  glEnable(GL_CULL_FACE);
  //---
end;


procedure TForm1.OGL_MD3_RenderFrame;
const TagAxisSize = 10.0;
      NormalSize = 3.0;
var s,t,v: integer;
    i1,i2,i3,
    v1,v2,v3: integer;
    x1,y1,z1,        // vertex 1
    x2,y2,z2,        // vertex 2
    x3,y3,z3,        // vertex 3
    nx1,ny1,nz1,     // normal 1
    nx2,ny2,nz2,     // normal 2
    nx3,ny3,nz3,     // normal 3
    ts1,tt1,         // texcoord 1
    ts2,tt2,         // texcoord 2
    ts3,tt3: single; // texcoord 3
    Vec1,Vec2,Vec3,Vec, Normal, Avg: TVector;
    textured, DoTexturePass,
    DoEnvMap, DoClamp, DoAlpha,HasAlpha, DoPolyOffset, DoLightmap, DoAutosprite,
    b: boolean;
    TexturePass,tp,Num_Passes: integer;
    TextureHandle, ShaderIndex,
    SrcBlend, DstBlend: cardinal;
    AlphaTest, multiAlphaTest: TAlphaFunc;
    ShaderCull: TCull;
    CountTextures, CountHasAlpha, CountLightmap: integer;
    tcModScrollX,tcModScrollY,tcModRotate: single;
{
    MultiTextures: array of TShaderTexture;
    Len: integer;
}
    FPS: integer;
  //----------------------
  procedure DrawTriangles(SurfaceNr: integer);
  var s,t,TU,tp, first: integer;
      nv,nt: integer;
      passes,pass: integer;
  begin
    if (SurfaceNr<0) or (SurfaceNr>=Length(MD3.Header.Surfaces)) then Exit;

    if DoAlpha{HasAlpha} then begin
      glEnable(GL_BLEND);
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
{      if Length(Shaders.ShaderFile[ShaderIndex].Textures)=1 then begin
        glEnable(GL_ALPHA_TEST);
        glAlphaFunc(GL_GREATER, 0);
      end;}
//      glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
//      glDepthMask(GL_FALSE);
    end else begin
//      glDepthMask(GL_TRUE);
    end;

    if DoAlpha then passes:=2 else passes:=1;

    for pass:=1 to passes do begin
      if DoAlpha then begin
        if pass=1 then begin
          glCullFace(GL_FRONT);
          glEnable(GL_CULL_FACE);
          glDepthMask(GL_FALSE);
        end else begin
{          glCullFace(GL_BACK);
          glEnable(GL_CULL_FACE);}
          glDepthMask(GL_TRUE);
//glDepthMask(GL_FALSE);
        end;
      end else begin
        glDepthMask(GL_TRUE);
      end; {else begin}
      if (not DoAlpha) or (pass=2) then begin
        if cbTwoSided.Checked then begin
          glCullFace(GL_NONE);
          glDisable(GL_CULL_FACE);
        end else
          case ShaderCull of
            cFront: begin
                glCullFace(GL_FRONT);
                glEnable(GL_CULL_FACE);
              end;
            cBack: begin
                glCullFace(GL_BACK);
                glEnable(GL_CULL_FACE);
              end;
            cNone,cDisable,cTwoSided: begin
                glCullFace(GL_NONE);
                glDisable(GL_CULL_FACE);
              end;
            else begin
              glCullFace(GL_BACK);
              glEnable(GL_CULL_FACE);
            end;
          end;
      end;

      for t:=0 to MD3.Header.Surfaces[SurfaceNr].Values.Num_Triangles-1 do begin
        // vertex index
        i1 := MD3.Header.Surfaces[SurfaceNr].Triangles[t].Index1;
        i2 := MD3.Header.Surfaces[SurfaceNr].Triangles[t].Index2;
        i3 := MD3.Header.Surfaces[SurfaceNr].Triangles[t].Index3;
        // animation frame
        v1 := i1 + (Current_Frame * MD3.Header.Surfaces[SurfaceNr].Values.Num_Verts);
        v2 := i2 + (Current_Frame * MD3.Header.Surfaces[SurfaceNr].Values.Num_Verts);
        v3 := i3 + (Current_Frame * MD3.Header.Surfaces[SurfaceNr].Values.Num_Verts);
        // vertex 1
        x1 := MD3.Header.Surfaces[SurfaceNr].Vertex[v1].X * MD3_XYZ_SCALE;
        y1 := MD3.Header.Surfaces[SurfaceNr].Vertex[v1].Y * MD3_XYZ_SCALE;
        z1 := MD3.Header.Surfaces[SurfaceNr].Vertex[v1].Z * MD3_XYZ_SCALE;
        // vertex 2
        x2 := MD3.Header.Surfaces[SurfaceNr].Vertex[v2].X * MD3_XYZ_SCALE;
        y2 := MD3.Header.Surfaces[SurfaceNr].Vertex[v2].Y * MD3_XYZ_SCALE;
        z2 := MD3.Header.Surfaces[SurfaceNr].Vertex[v2].Z * MD3_XYZ_SCALE;
        // vertex 3
        x3 := MD3.Header.Surfaces[SurfaceNr].Vertex[v3].X * MD3_XYZ_SCALE;
        y3 := MD3.Header.Surfaces[SurfaceNr].Vertex[v3].Y * MD3_XYZ_SCALE;
        z3 := MD3.Header.Surfaces[SurfaceNr].Vertex[v3].Z * MD3_XYZ_SCALE;
{
if DoAutosprite then begin
  Vec1 := Vector(x1,y1,z1);
  Vec2 := Vector(x2,y2,z2);
  Vec3 := Vector(x3,y3,z3);
//  BillBoard(OGL.Camera.Position, Vec1,Vec2,Vec3);
//  BillBoard(OGL.Camera.LineOfSight, Vec1,Vec2,Vec3);
BillBoard(OGL.Camera.Position, OGL.Camera.LineOfSight, VectorLength(SubVector(Vec2,Vec1)), VectorLength(SubVector(Vec2,Vec3)), Vec1,Vec2,Vec3,Vec);
Vec1 := AddVector(Vec1, AverageVector([Vec1,Vec2,Vec3]));
Vec2 := AddVector(Vec2, AverageVector([Vec1,Vec2,Vec3]));
Vec3 := AddVector(Vec3, AverageVector([Vec1,Vec2,Vec3]));
  x1:=Vec1.X;      x2:=Vec2.X;      x3:=Vec3.X;
  y1:=Vec1.Y;      y2:=Vec2.Y;      y3:=Vec3.Y;
  z1:=Vec1.Z;      z2:=Vec2.Z;      z3:=Vec3.Z;
  Normal := PlaneNormal(Vec1,Vec2,Vec3);
  nx1:=Normal.X;   nx2:=Normal.X;   nx3:=Normal.X;
  ny1:=Normal.Y;   ny2:=Normal.Y;   ny3:=Normal.Y;
  nz1:=normal.Z;   nz2:=normal.Z;   nz3:=normal.Z;
end else begin}
        // normal 1
        MD3.DecodeNormal(MD3.Header.Surfaces[SurfaceNr].Vertex[v1].Normal, nx1,ny1,nz1);
        // normal 2
        MD3.DecodeNormal(MD3.Header.Surfaces[SurfaceNr].Vertex[v2].Normal, nx2,ny2,nz2);
        // normal 3
        MD3.DecodeNormal(MD3.Header.Surfaces[SurfaceNr].Vertex[v3].Normal, nx3,ny3,nz3);
{end;}
        // texcoords 1
        ts1 := MD3.Header.Surfaces[SurfaceNr].TextureCoords[i1].S;
        tt1 := MD3.Header.Surfaces[SurfaceNr].TextureCoords[i1].T;
        // texcoords 2
        ts2 := MD3.Header.Surfaces[SurfaceNr].TextureCoords[i2].S;
        tt2 := MD3.Header.Surfaces[SurfaceNr].TextureCoords[i2].T;
        // texcoords 3
        ts3 := MD3.Header.Surfaces[SurfaceNr].TextureCoords[i3].S;
        tt3 := MD3.Header.Surfaces[SurfaceNr].TextureCoords[i3].T;

        // tekenen:
        glBegin(GL_TRIANGLES);
          // 1
          if not TakingScreenshot then begin
            glNormal3f(nx1,ny1,nz1);
            if textured then glTexCoord2f(ts1,tt1);
          end;
          glVertex3f(x1,y1,z1);
          // 2
          if not TakingScreenshot then begin
            glNormal3f(nx2,ny2,nz2);
            if textured then glTexCoord2f(ts2,tt2);
          end;
          glVertex3f(x2,y2,z2);
          // 3
          if not TakingScreenshot then begin
            glNormal3f(nx3,ny3,nz3);
            if textured then glTexCoord2f(ts3,tt3);
          end;
          glVertex3f(x3,y3,z3);
        glEnd;
      end;
    end; //passes
    Inc(TexturePass);
    // herstellen
    glDepthMask(GL_TRUE);
  end;
  //----------------------
  procedure ResetTUs;
  var TU: integer;
  begin
    for TU:=0 to MaxTU-1 do begin
      glActiveTextureARB(GL_TEXTURE0_ARB + TU);
      glEnable(GL_DEPTH_TEST);
      glDepthFunc(GL_LESS);
      glDisable(GL_BLEND);
      glDisable(GL_TEXTURE_2D);
      glDisable(GL_ALPHA_TEST);
      glAlphaFunc(GL_GREATER, 0);
      glDisable(GL_POLYGON_OFFSET_FILL);
      glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
      //
      glMatrixMode(GL_TEXTURE);
      glLoadIdentity;
      glMatrixMode(GL_MODELVIEW);
    end;
    glActiveTextureARB(GL_TEXTURE0_ARB);
  end;
  //----------------------
  procedure Brightness(Value: Single);   //test
  var rev: Single;
  begin
    if Value > 1.0 then begin
      rev := Value - 1.0;
      glBlendFunc(GL_DST_COLOR, GL_ONE);
      glColor3f(rev, rev, rev);
    end else begin
      glBlendFunc(GL_ZERO, GL_SRC_COLOR);
      glColor3f(Value, Value, Value);
    end;
    glEnable(GL_BLEND);
    glBegin(GL_QUADS);
      glVertex3f(-1000,-1000,1000);
      glVertex3f(1000,-1000,1000);
      glVertex3f(1000,1000,1000);
      glVertex3f(-1000,1000,1000);
    glEnd;
  end;
  //----------------------
begin
  if pcTabs.ActivePage <> tabView then Exit;
  if not OGL.Active then Exit;
  if InterruptPlayback then Exit;

  FPS := OGL.GetFPS;

  //glEnable(GL_DEPTH_TEST);
  for s:=0 to MD3.Header.Values.Num_Surfaces-1 do begin

    // rgbidentity, vol wit renderen --------------------------
    textured := false;
    TexturePass := 0;
    ResetTUs;

    if Length(MD3.Header.Surfaces[s].Shaders)>0 then
      ShaderIndex := MD3.Header.Surfaces[s].Shaders[0].Shader_Index
    else
      ShaderIndex := 0;

    if (Length(Shaders.ShaderFile)>0) and (ShaderIndex<Length(Shaders.ShaderFile)) then
      Num_Passes := Length(Shaders.ShaderFile[ShaderIndex].Textures)
    else begin
      Num_Passes := 0;

      glDisable(GL_BLEND);
      glDisable(GL_TEXTURE_2D);
      if TexturePass=0 then glDepthFunc(GL_LESS)
                       else glDepthFunc(GL_LEQUAL);
      glColor4f(1.0,1.0,1.0, 1.0);
      DrawTriangles(s);
      Continue; // klaar met tekenen
    end;

    //---------------------------------------------------------
    // surfaces met een alphaFunc texture niet tekenen als rbgidentity
    DoAlpha := false;
    for t:=0 to Num_Passes-1 do begin
      // shader met AlphaFunc??
      if Shaders.ShaderFile[ShaderIndex].Textures[t].AlphaFunc<>afNone then begin
        DoAlpha := true;
        Break;
      end;{ else
        if Shaders.ShaderFile[ShaderIndex].Textures[t].HasAlphaData then begin
          DoAlpha:=true;
          Break;
        end;}
    end;
    // alle textures een alphakanaal??
    if not DoAlpha then begin
      b := true;
      for t:=0 to Num_Passes-1 do begin
        if Shaders.ShaderFile[ShaderIndex].Textures[t].HasAlphaData and
           (not Shaders.ShaderFile[ShaderIndex].Textures[t].EnvMap) then Continue;
        b:=false;
        Break;
      end;
      if not b then
        if Num_Passes=1 then
          if Shaders.ShaderFile[ShaderIndex].Textures[t].HasAlphaData and
             Shaders.ShaderFile[ShaderIndex].Textures[t].EnvMap then b:=true;
      DoAlpha := b;
    end;
    if not DoAlpha then begin
//      glActiveTextureARB(GL_TEXTURE0_ARB {+ TexturePass});
      glDisable(GL_BLEND);
      glDisable(GL_TEXTURE_2D);
      if TexturePass=0 then glDepthFunc(GL_LESS)
                       else glDepthFunc(GL_LEQUAL);
      glColor4f(1.0,1.0,1.0, 1.0);
      DrawTriangles(s);
    end;

    //---------------------------------------------------------
    // een lightmap altijd tekenen als vol wit
    DoLightmap := false;
    for t:=0 to Num_Passes-1 do
      // shader met lightmap??
      if Shaders.ShaderFile[ShaderIndex].Textures[t].lightMap then begin
        DoLightmap:=true;
        Break;
      end;
    if DoLightmap then begin
//      glActiveTextureARB(GL_TEXTURE0_ARB);
      glDisable(GL_BLEND);
      glBlendFunc(GL_ONE,GL_ONE{GL_ZERO});
      glDisable(GL_TEXTURE_2D);
      if TexturePass=0 then glDepthFunc(GL_LESS)
                       else glDepthFunc(GL_LEQUAL);
      glColor4f(1.0,1.0,1.0, 1.0);
      DrawTriangles(s);
    end;
    //---------------------------------------------------------


//@    tp := 0;
//@    DoTexturePass := true;
//@    while DoTexturePass do begin
    for tp:=0 to Num_Passes-1 do begin

      ResetTUs;

//      glActiveTextureARB(GL_TEXTURE0_ARB);
      glDisable(GL_BLEND);
      glDisable(GL_TEXTURE_2D);
      glDisable(GL_ALPHA_TEST);
      glDisable(GL_TEXTURE_GEN_S);
      glDisable(GL_TEXTURE_GEN_T);
      glDisable(GL_POLYGON_OFFSET_FILL);

      // texture kiezen
      TextureHandle := 0;
      textured := (TextureHandle<>0);

      TextureHandle := Shaders.ShaderFile[ShaderIndex].Textures[tp].TextureHandle;
      SrcBlend := Shaders.ShaderFile[ShaderIndex].Textures[tp].BlendFuncSrc;
      DstBlend := Shaders.ShaderFile[ShaderIndex].Textures[tp].BlendFuncDst;
      AlphaTest := Shaders.ShaderFile[ShaderIndex].Textures[tp].AlphaFunc;
      DoEnvMap := Shaders.ShaderFile[ShaderIndex].Textures[tp].EnvMap;
      DoClamp := Shaders.ShaderFile[ShaderIndex].Textures[tp].clamped;
      DoPolyOffset := Shaders.ShaderFile[ShaderIndex].Textures[tp].PolygonOffset;
      HasAlpha := Shaders.ShaderFile[ShaderIndex].Textures[tp].HasAlphaData;
      ShaderCull := Shaders.ShaderFile[ShaderIndex].Textures[tp].Cull;
      tcModScrollX := Shaders.ShaderFile[ShaderIndex].Textures[tp].tcModScrollX;
      tcModScrollY := Shaders.ShaderFile[ShaderIndex].Textures[tp].tcModScrollY;
      tcModRotate := Shaders.ShaderFile[ShaderIndex].Textures[tp].tcModRotate;
      DoAutosprite := Shaders.ShaderFile[ShaderIndex].Textures[tp].autosprite;
      Shaders.ShaderFile[ShaderIndex].Textures[tp].TexturePass := TexturePass;  //!!!!!!!!!!!!!!!!!!!
      textured := (TextureHandle<>0);

      with Shaders.ShaderFile[ShaderIndex].Textures[tp] do begin
        CurrentTCMODscrollX := CurrentTCMODscrollX + (tcModScrollX/FPS);
        CurrentTCMODscrollY := CurrentTCMODscrollY + (tcModScrollY/FPS);
        CurrentTCMODrotate := CurrentTCMODrotate + (tcModRotate/FPS);
      end;


      if TexturePass=0 then begin
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
        glDepthFunc(GL_LESS);
      end else begin
        if HasAlpha then begin
          glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, {GL_BLEND}{GL_DECAL}GL_MODULATE);
        end else begin
          glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
        end;
        glDepthFunc(GL_LEQUAL);
      end;
(*
      if cbTwoSided.Checked then begin
        glCullFace(GL_NONE);
        glDisable(GL_CULL_FACE);
      end else
        case ShaderCull of
          cFront: begin
              glCullFace(GL_FRONT);
              glEnable(GL_CULL_FACE);
            end;
          cBack: begin
              glCullFace(GL_BACK);
              glEnable(GL_CULL_FACE);
            end;
          cNone,cDisable,cTwoSided: begin
              glCullFace(GL_NONE);
              glDisable(GL_CULL_FACE);
            end;
          else begin
            glCullFace(GL_BACK);
            glEnable(GL_CULL_FACE);
          end;
        end;
*)
      if textured then begin
        // clampmap
        if DoClamp then begin
          glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
          glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        end else begin
          // map
          glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
          glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        end;

        // tcGen enviroment
        if DoEnvMap then begin
          glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
          glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
          glEnable(GL_TEXTURE_GEN_S);
          glEnable(GL_TEXTURE_GEN_T);
{          // geen env.map op de eerste pass..
          if tp=0 then begin
            SrcBlend := GL_DST_COLOR;
            DstBlend := GL_ONE;
          end;}
//          glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
        end else begin
          glDisable(GL_TEXTURE_GEN_S);
          glDisable(GL_TEXTURE_GEN_T);
        end;

        // tcMod scroll
        if (tcModScrollX<>0) or (tcModScrollY<>0) then begin
          with Shaders.ShaderFile[ShaderIndex].Textures[tp] do begin
            glMatrixMode(GL_TEXTURE);
            glTranslatef(CurrentTCMODscrollX, CurrentTCMODscrollY , 0);
            glMatrixMode(GL_MODELVIEW);
          end;
        end;
        // tcMod rotate
        if (tcModRotate<>0) then begin
          with Shaders.ShaderFile[ShaderIndex].Textures[tp] do begin
            glMatrixMode(GL_TEXTURE);
            glRotatef(CurrentTCMODrotate, 0,0,1);
            glMatrixMode(GL_MODELVIEW);
          end;
        end;

        // alphafunc
        case AlphaTest of
          afNone: begin
                    glAlphaFunc(GL_GREATER, 0);
                    glDisable(GL_ALPHA_TEST);
                    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
                  end;
          afGT0:  begin
                    glEnable(GL_ALPHA_TEST);
                    glAlphaFunc(GL_GREATER, 0);
                    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
                  end;
          afLT128: begin
                     glEnable(GL_ALPHA_TEST);
                     glAlphaFunc(GL_LESS, 0.5);
                     glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
                   end;
          afGE128: begin
                     glEnable(GL_ALPHA_TEST);
                     glAlphaFunc(GL_GEQUAL, 0.5);
                     glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
                   end;
        end;

        // polygonOffset
        if DoPolyOffset then begin
{          glEnable(GL_POLYGON_OFFSET_FILL);
          glPolygonOffset(-10000.0, 1.0);
        end else begin
          glDisable(GL_POLYGON_OFFSET_FILL);}
          glDepthFunc(GL_LEQUAL);
          glDepthMask(GL_FALSE);
          glEnable(GL_ALPHA_TEST);
          glAlphaFunc(GL_GREATER, 0.5);
//          glEnable(GL_BLEND);
//          glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
//          glBlendFunc(GL_ONE,GL_ONE);
        end;

        if not DoLightmap then begin
          // blending & alpha
          glEnable(GL_BLEND);
          glBlendFunc(SrcBlend, DstBlend);
        end;

        // selecteer de texture
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, TextureHandle);

      end else begin
        // no textureHandle
        glDisable(GL_BLEND);
        glDisable(GL_TEXTURE_2D);
        //glDisable(GL_TEXTURE_GEN_S);
        //glDisable(GL_TEXTURE_GEN_T);
        //glBlendFunc(GL_ZERO,GL_ONE);  //!niet textured? dan niets tekenen
      end;

      // teken surface
      DrawTriangles(s);
//@      Inc(tp);

    end;
    ResetTUs;
  end;

  ResetTUs;
//  glActiveTextureARB(GL_TEXTURE0_ARB);
  glDisable(GL_LIGHTING);
  glDisable(GL_BLEND);
  glDisable(GL_TEXTURE_2D);
  glDisable(GL_ALPHA_TEST);
  glDisable(GL_TEXTURE_GEN_S);
  glDisable(GL_TEXTURE_GEN_T);
  glDisable(GL_POLYGON_OFFSET_FILL);
  glDepthFunc(GL_ALWAYS);
  glEnable(GL_DEPTH_TEST);
  glDisable(GL_CULL_FACE);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

  // De tags afbeelden
  if cbShowTags.Checked then
    if MD3.Header.Values.Num_Tags>0 then
      for t:=0 to MD3.Header.Values.Num_Tags-1 do begin
        // animation frame
        v1 := Current_Frame * MD3.Header.Values.Num_Tags + t;
        // tag-origin
        x1 := MD3.Header.Tags[v1].Origin.X;
        y1 := MD3.Header.Tags[v1].Origin.Y;
        z1 := MD3.Header.Tags[v1].Origin.Z;
        //
        glBegin(GL_LINES);
          //
          x2 := MD3.Header.Tags[v1].Axis[0].X * TagAxisSize;
          y2 := MD3.Header.Tags[v1].Axis[0].Y * TagAxisSize;
          z2 := MD3.Header.Tags[v1].Axis[0].Z * TagAxisSize;
          glColor3f(1,0,0);
          glVertex3f(x1,y1,z1);
          glVertex3f(x1+x2,y1+y2,z1+z2); //glVertex3f(x2,y2,z2);
          //
          x2 := MD3.Header.Tags[v1].Axis[1].X * TagAxisSize;
          y2 := MD3.Header.Tags[v1].Axis[1].Y * TagAxisSize;
          z2 := MD3.Header.Tags[v1].Axis[1].Z * TagAxisSize;
          glColor3f(0,1,0);
          glVertex3f(x1,y1,z1);
          glVertex3f(x1+x2,y1+y2,z1+z2); //glVertex3f(x2,y2,z2);
          //
          x2 := MD3.Header.Tags[v1].Axis[2].X * TagAxisSize;
          y2 := MD3.Header.Tags[v1].Axis[2].Y * TagAxisSize;
          z2 := MD3.Header.Tags[v1].Axis[2].Z * TagAxisSize;
          glColor3f(0,0,1);
          glVertex3f(x1,y1,z1);
          glVertex3f(x1+x2,y1+y2,z1+z2); //glVertex3f(x2,y2,z2);
        glEnd;
      end;

  // normalen afbeelden
  if cbShowNormals.Checked then
    for s:=0 to MD3.Header.Values.Num_Surfaces-1 do
      if MD3.Header.Surfaces[s].Values.Num_Triangles>0 then
        for t:=0 to MD3.Header.Surfaces[s].Values.Num_Triangles-1 do begin
          // vertex index
          i1 := MD3.Header.Surfaces[s].Triangles[t].Index1;
          i2 := MD3.Header.Surfaces[s].Triangles[t].Index2;
          i3 := MD3.Header.Surfaces[s].Triangles[t].Index3;
          // animation frame
          v1 := i1 + (Current_Frame * MD3.Header.Surfaces[s].Values.Num_Verts);
          v2 := i2 + (Current_Frame * MD3.Header.Surfaces[s].Values.Num_Verts);
          v3 := i3 + (Current_Frame * MD3.Header.Surfaces[s].Values.Num_Verts);
          // vertex 1
          x1 := MD3.Header.Surfaces[s].Vertex[v1].X * MD3_XYZ_SCALE;
          y1 := MD3.Header.Surfaces[s].Vertex[v1].Y * MD3_XYZ_SCALE;
          z1 := MD3.Header.Surfaces[s].Vertex[v1].Z * MD3_XYZ_SCALE;
          // vertex 2
          x2 := MD3.Header.Surfaces[s].Vertex[v2].X * MD3_XYZ_SCALE;
          y2 := MD3.Header.Surfaces[s].Vertex[v2].Y * MD3_XYZ_SCALE;
          z2 := MD3.Header.Surfaces[s].Vertex[v2].Z * MD3_XYZ_SCALE;
          // vertex 3
          x3 := MD3.Header.Surfaces[s].Vertex[v3].X * MD3_XYZ_SCALE;
          y3 := MD3.Header.Surfaces[s].Vertex[v3].Y * MD3_XYZ_SCALE;
          z3 := MD3.Header.Surfaces[s].Vertex[v3].Z * MD3_XYZ_SCALE;
          // normal 1
          MD3.DecodeNormal(MD3.Header.Surfaces[s].Vertex[v1].Normal, nx1,ny1,nz1);
          // normal 2
          MD3.DecodeNormal(MD3.Header.Surfaces[s].Vertex[v2].Normal, nx2,ny2,nz2);
          // normal 3
          MD3.DecodeNormal(MD3.Header.Surfaces[s].Vertex[v3].Normal, nx3,ny3,nz3);
          // vlak origin
          Vec1 := Vector(x1,y1,z1);
          Vec2 := Vector(x2,y2,z2);
          Vec3 := Vector(x3,y3,z3);
          Avg := AverageVector([Vec2,Vec1,Vec3]);
          Normal := AverageVector([Vector(nx1,ny1,nz1),Vector(nx2,ny2,nz2),Vector(nx3,ny3,nz3)]);
          // tekenen
          x2 := Normal.X * NormalSize;
          y2 := Normal.Y * NormalSize;
          z2 := Normal.Z * NormalSize;
          glBegin(GL_LINES);
            glColor3f(0.3,0.7,0.1);
            glVertex3f(Avg.X,Avg.Y,Avg.Z);
            glVertex3f(Avg.X+x2,Avg.Y+y2,Avg.Z+z2);
          glEnd;
        end;

  // Model-origin afbeelden
  if cbShowTags.Checked then begin
    glPointSize(4.0);
    glBegin(GL_POINTS);
      glColor3f(1,1,0);
      glVertex3f(0,0,0);
    glEnd;
  end;

  glActiveTextureARB(GL_TEXTURE0_ARB);
  ResetTUs;
  glDepthFunc(GL_LESS);
  glEnable(GL_CULL_FACE);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
{
  SetLength(MultiTextures, 0);
}  
end;




procedure TForm1.ClearGameShaders;
var i: integer;
begin
  TotalGameShaders := 0;
  TotalGameShaderFiles := 0;
  for i:=0 to Length(GameShaders)-1 do SetLength(GameShaders[i].Shaders, 0);
  SetLength(GameShaders, 0);
end;

procedure TForm1.LoadGameShaders;
var Dir, s,s2: string;
    searchRec: TSearchRec;
    i,r, Len, gp: integer;
    Found: boolean;
//-------------------------------
function GameShaderExists(ShaderFilename: string) : boolean;
var i: integer;
begin
  Result := false;
  for i:=0 to Length(GameShaders)-1 do
    if GameShaders[i].Filename = ShaderFilename then begin
      Result := true;
      Break;
    end;
end;
//-------------------------------
procedure AddGameShader(aFilename:string; aPAK_Index:integer; aInPK3:boolean);
var Len: integer;
begin
  Inc(TotalGameShaderFiles);
  Len := Length(GameShaders);
  SetLength(GameShaders, Len+1);
  with GameShaders[Len] do begin
    inPK3 := aInPK3;
    Filename := aFilename;
    PAK_Index := aPAK_Index;
    FindShaders(srGame, Len); // FromShaderList=false
  end;
end;
//-------------------------------
begin
  // controleer of er in de gamedir al een "scripts/"-dir bestaat
  if GameDir<>'' then begin
    StatusBar.SimpleText := 'Checking for shader-files in game-directory...';
    Dir := GameDir +'etmain\scripts\';
    if DirectoryExists(Dir) then begin
      // doorloop alle shader-files in de dir.
      s := Dir +'*.shader';
      if FindFirst(s, faAnyFile, searchRec)=0 then begin
        repeat
          // indien nog niet in GameShaders, dan toevoegen..
          Found := GameShaderExists(searchRec.Name);
          if not Found then AddGameShader(searchRec.Name, -1, false);
        until (FindNext(searchRec)<>0);
      end;
      FindClose(searchRec);
    end;
  end;

  // Lees de rest van de shader-files uit de pak-files (pak0.PK3)
  for gp:=0 to Length(PAKsList)-1 do begin
    StatusBar.SimpleText := 'Checking for shader-files in '+ PAKsList[gp].ShortName +'...';
    s := PAKsList[gp].FullPath; // GameDir +'etmain\pak0.pk3';
    Zip.FileName := s;
    Zip.OpenArchive(fmOpenRead);
    Zip.BaseDir := PAKsList[gp].TmpDir; // TmpDir;
    try
      s2 := 'scripts\*.shader';
      Zip.ExtractFiles(s2);
    finally
      Zip.CloseArchive;
    end;
    // doorloop alle shader-files in de tmp-dir. (pak0.pk3)
    s := PAKsList[gp].TmpDir +'scripts\*.shader';  //TmpDir
    if FindFirst(s, faAnyFile, searchRec)=0 then begin
      repeat
        // indien nog niet in GameShaders, dan toevoegen..
        Found := GameShaderExists(searchRec.Name);
        if not Found then AddGameShader(searchRec.Name, gp, true);
      until (FindNext(searchRec)<>0);
    end;
    FindClose(searchRec);
  end;

  StatusBar.SimpleText := 'Total shaderfiles/shaders found: '+ IntToStr(TotalGameShaderFiles) +' / '+ IntToStr(TotalGameShaders);
  UpdateShaders;
end;


procedure TForm1.ClearMapShaders;
var i: integer;
begin
  for i:=0 to Length(MapShaders)-1 do SetLength(MapShaders[i].Shaders, 0);
  SetLength(MapShaders, 0);
end;

procedure TForm1.LoadMapShaders;
var Dir, s,s2: string;
    searchRec: TSearchRec;
    i,r, Len: integer;
    Found: boolean;
//-------------------------------
function MapShaderExists(ShaderFilename: string) : boolean;
var i: integer;
begin
  Result := false;
  for i:=0 to Length(MapShaders)-1 do
    if MapShaders[i].Filename = ShaderFilename then begin
      Result := true;
      Break;
    end;
end;
//-------------------------------
procedure AddMapShader(aFilename: string; aInPK3: boolean);
var Len: integer;
begin
  Len := Length(MapShaders);
  SetLength(MapShaders, Len+1);
  with MapShaders[Len] do begin
    inPK3 := aInPK3;
    Filename := aFilename;
    FindShaders(srMap, Len); // FromShaderList=false
  end;
end;
//-------------------------------
begin
  // Lees de shader-files uit de Map.PK3
  StatusBar.SimpleText := 'Checking for shader-files in Map.pk3...';
  // doorloop alle shader-files in de tmpmap-dir. (map.pk3)
  s := TmpDir +'tmpmap\scripts\*.shader';
  if FindFirst(s, faAnyFile, searchRec)=0 then begin
    repeat
      // indien nog niet in MapShaders, dan toevoegen..
      Found := MapShaderExists(searchRec.Name);
      if not Found then AddMapShader(searchRec.Name, true);
    until (FindNext(searchRec)<>0);
  end;
  FindClose(searchRec);

  StatusBar.SimpleText := '';
end;

procedure TForm1.SetGameDir(const Path: string);
var Dir: string;
begin
  StatusBar.SimpleText := '';
  ClearGameShaders;

  Dir := Path;
  if Dir='' then Exit;
  if Dir[Length(Dir)]<>'\' then Dir := Dir + '\';
  if not DirectoryExists(Dir+'etmain') then Exit;
  if not FileExists(Dir +'etmain\pak0.pk3') then Exit;
  GameDir := Dir;

  LoadGameShaders;
end;


procedure TForm1.ClearShaderListShaders;
var i: integer;
begin
  for i:=0 to Length(ShaderListShaders)-1 do
    SetLength(ShaderListShaders[i].Shaders, 0);
  SetLength(ShaderListShaders, 0);
end;

procedure TForm1.LoadShaderListShaders;
var i: integer;
    Found: boolean;
//-------------------------------
function ShaderListShaderExists(ShaderFilename: string) : boolean;
var i: integer;
begin
  Result := false;
  for i:=0 to Length(ShaderListShaders)-1 do
    if ShaderListShaders[i].Filename = ShaderFilename then begin
      Result := true;
      Break;
    end;
end;
//-------------------------------
procedure AddShaderListShader(aFilename: string);
var Len: integer;
begin
  Len := Length(ShaderListShaders);
  SetLength(ShaderListShaders, Len+1);
  with ShaderListShaders[Len] do begin
    inPK3 := false;
    Filename := aFilename;
    FindShaders(srShaderList, Len); // FromShaderList=true
  end;
end;
//-------------------------------
begin
  StatusBar.SimpleText := '';
  ClearShaderListShaders;

  for i:=0 to cbShaderList.Items.Count-1 do begin
    if not FileExists(cbShaderList.Items[i]) then Continue;
    // indien nog niet in ShaderListShaders, dan toevoegen..
    Found := ShaderListShaderExists(cbShaderList.Items[i]);
    if not Found then AddShaderListShader(cbShaderList.Items[i]);
  end;

  cbShaderList.ItemIndex := cbShaderList.Items.Count-1;
  StatusBar.SimpleText := '';
  UpdateShaders;
end;


procedure TForm1.LoadSkinFile(Filename: string; DoUpdateShaders:boolean=true);
var s, Surface,Shader: string;
    List: TStringList;
    L, p, Len: integer;
begin
  SetLength(SkinShaders, 0);
  if Filename='' then Exit;
  if not FileExists(Filename) then Exit;
  s := ExtractFilename(Filename);
  leSkinFile.Text := s;
  leSkin.Text := '';
  List := TStringList.Create;
  try
    List.LoadFromFile(Filename);
    for L:=0 to List.Count-1 do begin
      s := List.Strings[L];
      if s='' then Continue;
      p := Pos(',', s);
      if p=0 then Continue;
      //
      Surface := Trim(Lowercase(Copy(s,1,p-1)));
      s := Trim(Lowercase(Copy(s,p+1,Length(s))));
      Shader := AnsiReplaceStr(s, '"','');
      if Shader<>'' then begin
        // toevoegen aan de Skin-array
        Len := Length(SkinShaders);
        SetLength(SkinShaders, Len+1);
        SkinShaders[Len].SurfaceName := Surface;
        SkinShaders[Len].ShaderName := Shader; // met relatief pad in PK3
      end;
    end;
  finally
    List.Free;
    menuSkinToModel.Enabled := ((Length(SkinShaders)>0) and (LoadedType<>ltNone));
    if DoUpdateShaders then UpdateShaders;
  end;
end;

// alle shader-namen zoeken in shader-files
function TForm1.FindShaders(const ShaderResource: TTextureResource; const sIndex: integer): boolean;
var List: TStringList;
    L,p,L2,Level,Len,gp: integer;
    s,Filename, SurfaceName: string;
    Found, fromSkin,fromShaderList,fromMap,fromGame: boolean;
begin
  Result := false;
  fromSkin := ((ShaderResource and trSkinFile)>0);
  fromShaderList := ((ShaderResource and trShaderList)>0);
  fromMap := (((ShaderResource and trPK3)>0) and ((ShaderResource and trGame)=0));
  fromGame := (((ShaderResource and trPK3)>0) and ((ShaderResource and trGame)>0));
  Filename := '';
  // Shaderlist
  if fromShaderList then begin
    Len := Length(ShaderListShaders);
    if (sIndex<0) or (sIndex>=Len) then Exit;
    Filename := ShaderListShaders[sIndex].Filename;
  end else
    // Map
    if fromMap then begin
      Len := Length(MapShaders);
      if (sIndex<0) or (sIndex>=Len) then Exit;
      Filename := TmpDir +'tmpmap\scripts\'+ MapShaders[sIndex].Filename;
    end else
      // Game
      if fromGame then begin
        Len := Length(GameShaders);
        if (sIndex<0) or (sIndex>=Len) then Exit;
        if GameShaders[sIndex].inPK3 then
          {Filename := TmpDir +'scripts\'+ GameShaders[sIndex].Filename}
          Filename := PAKsList[GameShaders[sIndex].PAK_Index].TmpDir +'scripts\'+ GameShaders[sIndex].Filename
        else // lokaal op HD aanwezig
          if GameDir<>'' then
            Filename := GameDir +'etmain\scripts\'+ GameShaders[sIndex].Filename;
      end;
  if Filename='' then Exit;
  if not FileExists(Filename) then Exit;

  if fromShaderList then SetLength(ShaderListShaders[sIndex].Shaders, 0)
  else
    if fromMap then SetLength(MapShaders[sIndex].Shaders, 0)
    else
      if fromGame then SetLength(GameShaders[sIndex].Shaders, 0);

  // bestand inlezen
  List := TStringList.Create;
  try
    List.LoadFromFile(Filename);

    // alle regels opschonen
    for L:=0 to List.Count-1 do begin
      s := List.Strings[L];
      // wis commentaar
      p := Pos('//',s);
      if p>0 then s := Copy(s,1,p-1);
      // trim
      s := Trim(s);
      //
      List.Strings[L] := s;
    end;

    // zoek alle shader-namen
    Found := false;
    Level := 0;
    for L:=0 to List.Count-1 do begin
      s := List.Strings[L];
      if s='' then Continue;
      if ((s='{') or (Pos('{',s)>0)) then begin
        Inc(Level);
        Continue;
      end else
        if ((s='}') or (Pos('}',s)>0)) then begin
          Dec(Level);
          Continue;
        end;
      if Level=0 then
        if fromShaderList then begin
          Len := Length(ShaderListShaders[sIndex].Shaders);
          SetLength(ShaderListShaders[sIndex].Shaders, Len+1);
          ShaderListShaders[sIndex].Shaders[Len] := s;
        end else
          if fromMap then begin
            Len := Length(MapShaders[sIndex].Shaders);
            SetLength(MapShaders[sIndex].Shaders, Len+1);
            MapShaders[sIndex].Shaders[Len] := s;
          end else
            if fromGame then begin
              Inc(TotalGameShaders);
              Len := Length(GameShaders[sIndex].Shaders);
              SetLength(GameShaders[sIndex].Shaders, Len+1);
              GameShaders[sIndex].Shaders[Len] := s;
            end;
    end;
  finally
    List.Free;
    Result := true;
  end;
end;

procedure TForm1.UpdateShaders;
var surface,surf,Len,LenS,LenM,sIndex,ssIndex,L,L2,p,p2,
    NumSurfaces: integer;
    SurfaceName,SurfaceName2,ShaderName,ShaderName2,Filename,path, FoundTexturename, s,s2,s3,sl, bfsrc,bfdst: string;
    Found, FoundTexturePass,
    isTextureName, TextureExists,ShaderExists,
    NeedsSkin, FromShaderList, b: boolean;
    List: TStringList;
    tmp: TShaderTexture;
    TextureResource: TTextureResource;
    tmpInt: SmallInt;
    tmpFloat: Single;
//-------------------------------
// zoek een shader in de ShaderList en/of de GameShaders
function ShaderNameFound(const Name:string; var TextureResource: TTextureResource; var sIndex, ssIndex: integer; const AddToCombobox: boolean) : boolean;
var gs,gss, Len,LenS: integer;
    Name2,Name3,s: string;
    Found: boolean;
begin
  // zoek de shaders erbij, voor de bestandsnaam.
  // Als er een shader bestaat met de naam van de Surface,..
  // ..krijgt die shader voorrang op een evt. aanwezige texture.
  Found := false;
  sIndex := -1;
  ssIndex := -1;
  Name2 := AnsiReplaceStr(Name, '\','/');   //tjonge jonge zeg.. consistent zijn ze niet..
  Name3 := AnsiReplaceStr(Name, '/','\');   //tjonge jonge zeg.. consistent zijn ze niet..
  // zoek eerst lokaal in de ModelDir
  if ModelDir<>'' then begin
    //todo??
  end;
  // Zoek vervolgens in de ShaderList shaders
  Len := Length(ShaderListShaders);
  for gs:=0 to Len-1 do begin
    LenS := Length(ShaderListShaders[gs].Shaders);
    for gss:=0 to LenS-1 do begin
      if (ShaderListShaders[gs].Shaders[gss] = Name) or
         (ShaderListShaders[gs].Shaders[gss] = Name2) then begin
        Found := true;
        TextureResource := (TextureResource or trShader);
        TextureResource := (TextureResource or trShaderList);
        sIndex := gs;
        ssIndex := gss;

        if AddToCombobox then
          if (ShaderListShaders[gs].Shaders[gss] = Name) then
            cbShaderNameFound.Items.Add(Name)
          else
            cbShaderNameFound.Items.Add(Name2);

        Break;
      end;
    end;
    if Found then Break;
  end;
  // Zoek vervolgens in de MapShaders (custom.pk3)
  if not Found then begin
    Len := Length(MapShaders);
    for gs:=0 to Len-1 do begin
      LenS := Length(MapShaders[gs].Shaders);
      for gss:=0 to LenS-1 do begin
        if (MapShaders[gs].Shaders[gss] = Name) or
           (MapShaders[gs].Shaders[gss] = Name2) then begin
          Found := true;
          TextureResource := (TextureResource or trShader);
          TextureResource := (TextureResource or trPK3);
          sIndex := gs;
          ssIndex := gss;

          if AddToCombobox then
            if (MapShaders[gs].Shaders[gss] = Name) then
              cbShaderNameFound.Items.Add(Name)
            else
              cbShaderNameFound.Items.Add(Name2);

          Break;
        end;
      end;
      if Found then Break;
    end;
  end;
  // Zoek als laatst in de GameShaders (pak0.pk3)
  if not Found then begin
    Len := Length(GameShaders);
    for gs:=0 to Len-1 do begin
      LenS := Length(GameShaders[gs].Shaders);
      for gss:=0 to LenS-1 do begin
        if (GameShaders[gs].Shaders[gss] = Name) or
           (GameShaders[gs].Shaders[gss] = Name2) then begin
          Found := true;
          TextureResource := (TextureResource or trShader);
          TextureResource := (TextureResource or trGame);
          TextureResource := (TextureResource or trPK3);
          sIndex := gs;
          ssIndex := gss;

          if AddToCombobox then
            if (GameShaders[gs].Shaders[gss] = Name) then
              cbShaderNameFound.Items.Add(Name)
            else
              cbShaderNameFound.Items.Add(Name2);

          Break;
        end;
      end;
      if Found then Break;
    end;
  end;
  //
  if not Found then
    if AddToCombobox then
      cbShaderNameFound.Items.Add('');

  Result := Found;
end;
//-------------------------------
function GetShaderFilename(const TextureResource: TTextureResource; const sIndex: integer; const AddToCombobox: boolean) : string;
var s,s2: string;
    fromShaderList,fromMap,fromGame: boolean;
begin
  s := '';
  fromShaderList := ((TextureResource and trShaderList)>0);
  fromMap := (((TextureResource and trPK3)>0) and ((TextureResource and trGame)=0));
  fromGame := (((TextureResource and trPK3)>0) and ((TextureResource and trGame)>0));
  if fromShaderList then begin
    s := 'SHADERLIST:\\'+ ExtractFilename(ShaderListShaders[sIndex].Filename);
    if AddToCombobox then cbShaderFile.Items.Add(s);
    s := ShaderListShaders[sIndex].Filename;
  end else
    if fromMap then begin
      s2 := AnsiReplaceStr(MapShaders[sIndex].Filename, '\','/');   //tjonge jonge zeg.. consistent zijn ze niet..
      s2 := ExtractFilename(s2);
      s := 'MAP:\\scripts\'+ s2;
      if AddToCombobox then cbShaderFile.Items.Add(s);
      s := TmpDir +'tmpmap\scripts\'+ MapShaders[sIndex].Filename;
    end else
      if fromGame then begin
        if not GameShaders[sIndex].inPK3 then begin // lokaal op HD aanwezig
          if GameDir<>'' then begin
            s := GameDir +'etmain\scripts\'+ GameShaders[sIndex].Filename;
            if AddToCombobox then cbShaderFile.Items.Add(s);
          end;
        end else begin
          s := 'GAME:\\scripts\'+ GameShaders[sIndex].Filename;
          if AddToCombobox then cbShaderFile.Items.Add(s);
          {s := TmpDir +'scripts\'+ GameShaders[sIndex].Filename;}
          s := PAKsList[GameShaders[sIndex].PAK_Index].TmpDir +'scripts\'+ GameShaders[sIndex].Filename;
        end;
      end else
        if AddToCombobox then cbShaderFile.Items.Add('');
  Result := s;
end;
//-------------------------------
function TextureNameFound(const Name:string; var TextureResource: TTextureResource; var FoundTexturename:string; var FoundFilename:string) : boolean;
var s,s2,s3,path: string;
    ai: TZFArchiveItem;
    gp: integer;
begin
  Result := false;
  FoundFilename := '';
  if Name='' then Exit;
  // zoek texture
  s := AnsiReplaceStr(Name, '/','\');
  path := ExtractFilePath(s);
  s := ExtractFilename(s);

  if LoadedFrom = lfFile then begin
    // zoek texture in ModelDir
    if ModelDir<>'' then begin
      if FileExists(ModelDir+s) then s2 := s else begin
        s3 := ExtractFileExt(s);
        if s3<>'' then s := Copy(s,1,Length(s)-Length(s3));
        if FileExists(ModelDir+s+'.tga') then s2 := s+'.tga' else
          if FileExists(ModelDir+s+'.jpg') then s2 := s+'.jpg' else
            if FileExists(ModelDir+s+'.bmp') then s2 := s+'.bmp';
      end;
    end;
    if s2<>'' then begin
      // texture gevonden in ModelDir
      Result := true;
      FoundTexturename := s2;
      FoundFilename := ModelDir+s2;
      TextureResource := (TextureResource or trTexture);
    end;
    if Result then Exit;
    // zoek evt. met relatief pad-info
    s2 := '';
    if path = ModelDir then
      if FileExists(ModelDir+s) then s2 := s else
        if FileExists(ModelDir+s+'.tga') then s2 := s+'.tga' else
          if FileExists(ModelDir+s+'.jpg') then s2 := s+'.jpg' else
            if FileExists(ModelDir+s+'.bmp') then s2 := s+'.bmp';
    if s2<>'' then begin
      // texture gevonden in ModelDir
      Result := true;
      FoundTexturename := s2;
      FoundFilename := ModelDir+s2;
      TextureResource := (TextureResource or trTexture);
    end;
  end;
  if Result then Exit;

  // Zoek in map.pk3
  if dlgPK3.MapPK3<>'' then begin
    Zip.FileName := dlgPK3.MapPK3;
    Zip.OpenArchive(fmOpenRead);
    Zip.BaseDir := TmpDir+'tmpmap\';
    try
      s2 := path + s;
      s3 := ExtractFileExt(s);
      Result := Zip.FindFirst(s2,ai,faAnyFile);
      if Result then
        FoundFilename := TmpDir+'tmpmap\' + s2 //ai.StoredPath + ai.FileName;
      else begin
        if s3<>'' then s := Copy(s,1,Length(s)-Length(s3));
        s2 := path + s +'.tga';
        Result := Zip.FindFirst(s2,ai,faAnyFile);
        if Result then
          FoundFilename := TmpDir+'tmpmap\' + s2
        else begin
          s2 := path + s +'.jpg';
          Result := Zip.FindFirst(s2,ai,faAnyFile);
          if Result then
            FoundFilename := TmpDir+'tmpmap\' + s2
          else begin
            s2 := path + s +'.bmp';
            Result := Zip.FindFirst(s2,ai,faAnyFile);
            if Result then
              FoundFilename := TmpDir+'tmpmap\' + s2
          end;
        end;
      end;
      // bestand uitpakken
      if Result then begin
        FoundTexturename := s2;
        FoundFilename := TmpDir+'tmpmap\' + s2;
        TextureResource := (TextureResource or trTexture);
        TextureResource := (TextureResource or trPK3);
//        Zip.ExtractFiles(FoundFilename);
      end;
    finally
      Zip.CloseArchive;
    end;
  end;
  if Result then Exit;

  // zoek eventueel texture in GAME-PAK files (pak0.pk3)
  for gp:=0 to Length(PAKsList)-1 do begin
    Zip.FileName := PAKsList[gp].FullPath; // GameDir +'etmain\pak0.pk3';
    Zip.OpenArchive(fmOpenRead);
    Zip.BaseDir := PAKsList[gp].TmpDir; // TmpDir;
    try
      s2 := path + s;
      Result := Zip.FindFirst(s2,ai,faAnyFile);
      if Result then
        {FoundFilename := TmpDir + s2 //ai.StoredPath + ai.FileName;}
        FoundFilename := PAKsList[gp].TmpDir + s2 //ai.StoredPath + ai.FileName;
      else begin
        s2 := ChangeFileExt(path+s, '.tga'); //path + s +'.tga';
        Result := Zip.FindFirst(s2,ai,faAnyFile);
        if Result then
          {FoundFilename := TmpDir + s2}
          FoundFilename := PAKsList[gp].TmpDir + s2 //ai.StoredPath + ai.FileName;
        else begin
          s2 := ChangeFileExt(path+s, '.jpg'); //path + s +'.jpg';
          Result := Zip.FindFirst(s2,ai,faAnyFile);
          if Result then
            {FoundFilename := TmpDir + s2}
            FoundFilename := PAKsList[gp].TmpDir + s2 //ai.StoredPath + ai.FileName;
          else begin
            s2 := ChangeFileExt(path+s, '.bmp'); //path + s +'.bmp';
            Result := Zip.FindFirst(s2,ai,faAnyFile);
            if Result then
              {FoundFilename := TmpDir + s2}
              FoundFilename := PAKsList[gp].TmpDir + s2 //ai.StoredPath + ai.FileName;
          end;
        end;
      end;
      // bestand uitpakken
      if Result then begin
        FoundTexturename := s2;
        FoundFilename := PAKsList[gp].TmpDir + s2;
        TextureResource := (TextureResource or trTexture);
        TextureResource := (TextureResource or trGame);
        TextureResource := (TextureResource or trPK3);
  //      Zip.ExtractFiles(FoundFilename);
        Break;
      end;
    finally
      Zip.CloseArchive;
    end;
  end;
end;
//-------------------------------
begin
  StatusBar.SimpleText := '';
  DeleteTextures; // bestaande OpenGL-textures verwijderen
  cbShaderFile.Clear;
  cbShaderNameFound.Clear;
  cbNamesSurfacesSelect(nil);  // scherm update nodig..
  
  // leeg de shaderfile array + textures
  for p:=0 to Length(Shaders.ShaderFile)-1 do
    for L:=0 to Length(Shaders.ShaderFile[p].Textures)-1 do
      SetLength(Shaders.ShaderFile[p].Textures, 0);
  SetLength(Shaders.ShaderFile, 0);
  //
  case LoadedType of
    ltNone: Exit;
    ltMD3,ltMap,ltASE,ltMS3D_MD3: NumSurfaces := MD3.Header.Values.Num_Surfaces;
    ltMDMMDX,ltMDS,ltMS3D_MDMMDX: NumSurfaces := MDM.Header.Num_Surfaces;
  end;
  //
{  SetLength(ShaderFile, NumSurfaces);
  SetLength(Shaders.ShaderFile, NumSurfaces);}
  if NumSurfaces=0 then Exit;
  Len := Length(GameShaders);
  if (Len=0) then Exit;
  LenS := Length(ShaderListShaders);
  LenM := Length(MapShaders);
  StatusBar.SimpleText := 'Updating skins, shaders & textures...';

  // Een shader->textures zoeken:
  // Zoekvolgorde = ShaderList, GameShaders, ModelDir
  //
  // MD3.Header.Surfaces[#].Shaders[#] kan een shadernaam bevatten (zoals "models/mapobjects/goldbox_sd/goldbox"),
  //   of het kan een texturenaam bevatten (zoals "models/multiplayer/gold/gold.tga").
  // Indien een shadernaam is opgegeven, en de shader is niet gevonden, dan zoeken naar een texture in de ModelDir..
  // Indien een texturenaam is opgegeven, en de texture niet gevonden, dan zoeken naar een shader (met hetzelfde pad als de opgegegven texture).
  // Indien er een lege shadernaam is opgegeven, dan heeft het surface een skin nodig (om aan een texture te komen).
  //
  for surface:=0 to NumSurfaces-1 do begin
//!    if MD3.Header.Surfaces[surface].Values.Num_Shaders = 1 then begin

      // ongeldige shaderindex..
      case LoadedType of
        ltMD3,ltMap,ltASE,ltMS3D_MD3:
          if Length(MD3.Header.Surfaces[surface].Shaders)>0 then
            MD3.Header.Surfaces[surface].Shaders[0].Shader_Index := -1;
        ltMDMMDX,ltMDS,ltMS3D_MDMMDX:
          MDM.Surfaces[surface].Values.ShaderIndex := -1;
      end;

      // surfacename
      case LoadedType of
        ltMD3,ltMap,ltASE,ltMS3D_MD3: SurfaceName := LowerCase(string(MD3.Header.Surfaces[surface].Values.Name));
        ltMDMMDX,ltMDS,ltMS3D_MDMMDX: SurfaceName := LowerCase(string(MDM.Surfaces[surface].Values.SurfaceName));
      end;
//!      if Pos('\',SurfaceName)>0 then SurfaceName2 := AnsiReplaceStr(SurfaceName, '\','/')   //tjonge jonge zeg..
//!                                else SurfaceName2 := AnsiReplaceStr(SurfaceName, '/','\');   //tjonge jonge zeg..
      //SurfaceName := LowerCase(string(MD3.Header.Surfaces[surface].Values.Name));
      SurfaceName := AnsiReplaceStr(SurfaceName, '"','');
      ShaderName := '';
      TextureResource := trNone;
(*
      // Test of er een shader bestaat met de naam van het SURFACE:
      // ..dan ModelPath als prefix gebruiken als relatieve pad voor SurfaceName
      if SurfaceName<>'' then begin
        case LoadedFrom of
          lfFile: s := ModelDir + SurfaceName;
          lfGame,lfPK3: s := dlgPK3.PathDir + SurfaceName;
        end;
        s := AnsiReplaceStr(s, '/','\');
        s2 := ExtractFileExt(s);
        if s2='' then begin
          // shadernaam opgegeven. Bestaat de shader??
          ShaderExists := ShaderNameFound(s{SurfaceName}, TextureResource, sIndex,ssIndex, false);
          if ShaderExists then begin
            // shader opgegeven, en shader gevonden..
            TextureResource := (TextureResource or trSurface);
            ShaderName := SurfaceName;
{
            // Als een surfacenaam-shader is gevonden, wordt deze anders op een model gemapt..
            //  ST <-> UV ???? misschien testen..
            //if not TexCoordsAdjusted then begin
              for L:=0 to MD3.Header.Surfaces[surface].Values.Num_Verts-1 do begin
//@                tmpInt := MD3.Header.Surfaces[surface].Vertex[L].Z;
//@                MD3.Header.Surfaces[surface].Vertex[L].Z := MD3.Header.Surfaces[surface].Vertex[L].Y;
//@                MD3.Header.Surfaces[surface].Vertex[L].Y := -tmpInt;
//!              tmpFloat := MD3.Header.Surfaces[surface].TextureCoords[L].S;
//!              MD3.Header.Surfaces[surface].TextureCoords[L].S := MD3.Header.Surfaces[surface].TextureCoords[L].T * 0.5;
//!              MD3.Header.Surfaces[surface].TextureCoords[L].T := tmpFloat;
                tmpFloat := MD3.Header.Surfaces[surface].TextureCoords[L].S;
                MD3.Header.Surfaces[surface].TextureCoords[L].S := MD3.Header.Surfaces[surface].TextureCoords[L].T;
                MD3.Header.Surfaces[surface].TextureCoords[L].T := tmpFloat;
              end;
              //TexCoordsAdjusted := true;
            //end;
}
          end;
        end;
      end;
*)
      //
      if TextureResource = trNone then begin
        case LoadedType of
          ltMD3,ltMap,ltASE,ltMS3D_MD3:
            if Length(MD3.Header.Surfaces[surface].Shaders)>0 then
              ShaderName := LowerCase(string(MD3.Header.Surfaces[surface].Shaders[0].Name))
            else
              ShaderName := '';
          ltMDMMDX,ltMDS,ltMS3D_MDMMDX:
            ShaderName := LowerCase(string(MDM.Surfaces[surface].Values.ShaderName));
        end;
        //ShaderName := LowerCase(string(MD3.Header.Surfaces[surface].Shaders[0].Name));
      end;
      ShaderName := AnsiReplaceStr(ShaderName, '"','');
      NeedsSkin := (ShaderName='');
      s := ShaderName;
      s := AnsiReplaceStr(s, '/','\');
      s := ExtractFilename(s);
      s2 := ExtractFileExt(s);
      isTextureName := (s2<>'');
      TextureExists := false;
      ShaderExists := false;
      // Bepaal het te laden bestand voor een shader:
      Filename := '';

      // skin nodig?? ----------------------------
//@      if NeedsSkin then begin
        Len := Length(SkinShaders);
//@   if Len>0 then begin
        for L:=0 to Len-1 do
          if SkinShaders[L].SurfaceName = SurfaceName {LowerCase(string(MD3.Header.Surfaces[surface].Values.Name))} then begin
            // skin gevonden
            TextureResource := (TextureResource or trSkinFile);
            s := SkinShaders[L].ShaderName;// SkinShaders[L].SurfaceName;
            s := AnsiReplaceStr(s, '/','\');
            path := ExtractFilePath(s);
            s2 := ExtractFileExt(s);
            s := ExtractFilename(s);
            // De skin kan een shader of texture bevatten
            ShaderName := SkinShaders[L].ShaderName;
            isTextureName := (s2<>'');
            {TextureExists := false;
            ShaderExists := false;}
            //
            Break;
          end;
//@      end else begin
//@        // geen skin nodig
//@      end;

      // shadernaam of texturenaam opgegeven?? ----
      if not isTextureName then begin
        // shadernaam opgegeven. Bestaat de shader??
        ShaderExists := ShaderNameFound(ShaderName, TextureResource, sIndex,ssIndex,true);
        if ShaderExists then begin
          // shader opgegeven, en shader gevonden..
          ShaderName2 := ShaderName;
          Filename := GetShaderFilename(TextureResource, sIndex, true); //AddToCombobox
          if (TextureResource and trSkinFile)>0 then SetSkinToModel(SurfaceName, ShaderName);
        end else begin
          // shader bestaat niet, zoek naar een gelijknamige texture
          TextureExists := TextureNameFound(ShaderName, TextureResource, FoundTexturename, s3);
          if TextureExists then begin
            // texture opgegeven, en texture gevonden.. s3 is ingevuld.
            case LoadedType of
              ltMD3,ltMap,ltASE,ltMS3D_MD3: MD3.Header.Surfaces[surface].Shaders[0].Shader_Index := Shaders.FetchTexture(FoundTexturename,s3, TextureResource);
              ltMDMMDX,ltMDS,ltMS3D_MDMMDX: MDM.Surfaces[surface].Values.ShaderIndex := Shaders.FetchTexture(FoundTexturename,s3, TextureResource);
            end;
            if (TextureResource and trSkinFile)>0 then SetSkinToModel(SurfaceName, ShaderName);
          end;
          cbShaderFile.Items.Add('');
        end;
      end else begin
        // texturenaam opgegeven. Bestaat er een shader voor de texture??
        // strip extensie
        Len := Length(s2);
        ShaderName2 := Copy(ShaderName, 1, Length(ShaderName)-Len);
        //
        ShaderExists := ShaderNameFound(Shadername2, TextureResource, sIndex,ssIndex, true);
        if ShaderExists then begin
          // texturenaam opgegeven, en shader gevonden..
{ShaderName2 := LowerCase( string(MD3.Header.Surfaces[surface].Shaders[0].Name));
ShaderName2 := Copy(ShaderName2, 1, Length(ShaderName2)-Len);}
//!          ShaderName := AnsiReplaceStr(ShaderName2, '\','/');
          Filename := GetShaderFilename(TextureResource, sIndex, true); //AddToCombobox
//!??          ShaderName := ShaderName2;
          if (TextureResource and trSkinFile)>0 then SetSkinToModel(SurfaceName, ShaderName2);
        end else begin
          TextureExists := TextureNameFound(ShaderName, TextureResource, FoundTexturename, s3);
          if TextureExists then begin
            // texture opgegeven, en texture gevonden.. Filename is ingevuld.
            case LoadedType of
              ltMD3,ltMap,ltASE,ltMS3D_MD3: MD3.Header.Surfaces[surface].Shaders[0].Shader_Index := Shaders.FetchTexture(FoundTexturename,s3, TextureResource);
              ltMDMMDX,ltMDS,ltMS3D_MDMMDX: MDM.Surfaces[surface].Values.ShaderIndex := Shaders.FetchTexture(FoundTexturename,s3, TextureResource);
            end;
            if (TextureResource and trSkinFile)>0 then SetSkinToModel(SurfaceName, ShaderName);
          end;
          cbShaderFile.Items.Add('');
        end;
      end;
      Found := ((Filename<>'') and FileExists(Filename));

      // shader-bestand laden en texture-maps zoeken..
      if Found then begin
(*
        // evt. oude textures wissen
        Len := Length(ShaderFile[surface].Textures);
        if Len>0 then begin
          for p:=0 to Len-1 do
            OGL.Textures.DeleteTexture(ShaderFile[surface].Textures[p].TextureHandle);
          SetLength(ShaderFile[surface].Textures, 0);
        end;
*)
        case LoadedType of
          ltMD3,ltMap,ltASE,ltMS3D_MD3:
            if Length(MD3.Header.Surfaces[surface].Shaders)>0 then
              MD3.Header.Surfaces[surface].Shaders[0].Shader_Index := Shaders.FetchShader(Filename, Shadername,Shadername2, TextureResource);
          ltMDMMDX,ltMDS,ltMS3D_MDMMDX:
            MDM.Surfaces[surface].Values.ShaderIndex := Shaders.FetchShader(Filename, Shadername,Shadername2, TextureResource);
        end;
      end; //if found
//!    end; //if Num_Shaders = 1
  end; //for surface

(*
  // shader-textures sorteren (environment-map als laatste)
  StatusBar.SimpleText := 'Sorting texture-stages...';
  for surf:=0 to MD3.Header.Values.Num_Surfaces-1 do begin
    if MD3.Header.Surfaces[surf].Values.Num_Shaders = 1 then begin
      Len := Length(ShaderFile[surf].Textures);
      for p:=0 to Len-1 do begin
        if ShaderFile[surf].Textures[p].EnvMap and (p<Len-1) then begin
          // swap deze texture met de laatste
          tmp := ShaderFile[surf].Textures[p];
          ShaderFile[surf].Textures[p] := ShaderFile[surf].Textures[Len-1];
          ShaderFile[surf].Textures[Len-1] := tmp;
          Break;
        end;
      end;
    end;
  end;
*)
  StatusBar.SimpleText := '';
  cbShaderFile.ItemIndex := 0;

  OGL_CreateTextures;

  cbShaderTextures.ItemIndex := 0;
//  cbLightingEnabled.Checked := false;
end;

procedure TForm1.DeleteTextures;
var surface, Len, t: integer;
begin
  // bestaande OpenGL-textures verwijderen
{  for surface:=0 to Length(ShaderFile)-1 do begin
    Len := Length(ShaderFile[surface].Textures);
    for t:=0 to Len-1 do begin
      OGL.Textures.DeleteTexture(ShaderFile[surface].Textures[t].TextureHandle);
      ShaderFile[surface].Textures[t].TextureHandle := 0;
    end;
  end;}
  Shaders.DeleteAllShaders;

  // shader-indexen in modellen verwijderen..
  case LoadedType of
    ltNone: Exit;
    ltMD3,ltMap,ltASE,ltMS3D_MD3:
      for surface:=0 to MD3.Header.Values.Num_Surfaces-1 do
        if Length(MD3.Header.Surfaces[surface].Shaders)>0 then
          MD3.Header.Surfaces[surface].Shaders[0].Shader_Index := -1;
    ltMDMMDX,ltMDS,ltMS3D_MDMMDX:
      for surface:=0 to MDM.Header.Num_Surfaces-1 do
        MDM.Surfaces[surface].Values.ShaderIndex := -1;
  end;
end;

procedure TForm1.OGL_CreateTextures;
var surface, Len, t: integer;
    s,s2,s3,s4,snew, path,ext, FoundFilename: string;
    TextureHandle: GLuint;
    Found: boolean;
    ai: TZFArchiveItem;
    TextureResource: TTextureResource;
    NumSurfaces: cardinal;
    W,H: integer;
    gp: integer;
begin
  // bestaande OpenGL-textures verwijderen
  {DeleteTextures;}

  case LoadedType of
    ltNone: Exit;
    ltMD3,ltMap,ltASE,ltMS3D_MD3: NumSurfaces := MD3.Header.Values.Num_Surfaces;
    ltMDMMDX,ltMDS,ltMS3D_MDMMDX: NumSurfaces := MDM.Header.Num_Surfaces;
  end;
  if Length(Shaders.ShaderFile)=0 then Exit;

  StatusBar.SimpleText := 'Creating textures...';
  // OpenGL-textures aanmaken en handles opslaan
  for surface:=0 to NumSurfaces-1 do begin
//!    if MD3.Header.Surfaces[surface].Values.Num_Shaders = 1 then begin
    if surface>=Length(Shaders.ShaderFile) then Break; //Exit
      Len := Length(Shaders.ShaderFile[surface].Textures);
      for t:=0 to Len-1 do begin
        TextureResource := Shaders.ShaderFile[surface].TextureResource;

        Shaders.ShaderFile[surface].Textures[t].TextureHandle := 0;
        Shaders.ShaderFile[surface].Textures[t].HasAlphaData := false;
        {ShaderFile[surface].Textures[t].BlendFuncSrc := GL_ZERO;
        ShaderFile[surface].Textures[t].BlendFuncDst := GL_ZERO;}

        // $lightmap en/of $whiteimage overslaan
        if Shaders.ShaderFile[surface].Textures[t].lightMap or Shaders.ShaderFile[surface].Textures[t].whiteImage then begin
          StatusBar.SimpleText := '';
          Continue;
        end;


        if (Shaders.ShaderFile[surface].Textures[t].FoundFilename='') or
          ((Shaders.ShaderFile[surface].Textures[t].FoundFilename<>'') and (not FileExists(Shaders.ShaderFile[surface].Textures[t].FoundFilename))) then begin
          s := Shaders.ShaderFile[surface].Textures[t].Map;
          s := AnsiReplaceStr(s, '/','\');
          s2 := s;
          s4 := s;
          s3 := ExtractFileExt(s);
          s := ExtractFilename(s);
          // zoek de texture-bestanden:
          Found := false;
          // zoek eerst in het pad van het geladen model
          case LoadedType of
            ltMD3: if OpenDialog.FileName<>'' then begin
                path := ExtractFilePath(OpenDialog.FileName);
                Found := FileExists(path+s);
              end;
            ltMap: if MapOpenDialog.FileName<>'' then begin
                path := ExtractFilePath(MapOpenDialog.FileName);
                Found := FileExists(path+s);
              end;
            ltASE: if ASEOpenDialog.FileName<>'' then begin
                path := ExtractFilePath(ASEOpenDialog.FileName);
                Found := FileExists(path+s);
              end;
            ltMS3D_MD3: if MS3DOpenDialog.FileName<>'' then begin
                path := ExtractFilePath(MS3DOpenDialog.FileName);
                Found := FileExists(path+s);
              end;
            ltMS3D_MDMMDX: if MS3DOpenDialog.FileName<>'' then begin
                path := ExtractFilePath(MS3DOpenDialog.FileName);
                Found := FileExists(path+s);
              end;
            ltMDMMDX: if MDMOpenDialog.FileName<>'' then begin
                path := ExtractFilePath(MDMOpenDialog.FileName);
                Found := FileExists(path+s);
              end;
            ltMDS: if MDSOpenDialog.FileName<>'' then begin
                path := ExtractFilePath(MDSOpenDialog.FileName);
                Found := FileExists(path+s);
              end;
          end;
        
          // zoek vervolgens in gamedir\etmain\ naar lokale bestanden
          if not Found then begin
            if GameDir<>'' then begin
              path := GameDir +'etmain\';
              Found := FileExists(path+s);
            end;
          end;

          // zoek in een evt. map-pk3
  //        fromMap := ((TextureResource and trPK3)>0) and ((TextureResource and trGame)=0);
          if (not Found) and (dlgPK3.MapPK3<>'') then begin
            path := TmpDir +'tmpmap\';
            Zip.FileName := dlgPK3.MapPK3;
            Zip.OpenArchive(fmOpenRead);
            Zip.BaseDir := path;
            try
              Found := Zip.FindFirst(s2,ai,faAnyFile);
              if Found then
                s := s2 //ai.StoredPath + ai.FileName;
              else begin
                snew := s2;
                if s3<>'' then snew := Copy(s2,1,Length(s2)-Length(s3)); //strip extensie
                s2 := snew +'.tga';
                Found := Zip.FindFirst(s2,ai,faAnyFile);
                if Found then
                  s := s2
                else begin
                  s2 := snew +'.jpg';
                  Found := Zip.FindFirst(s2,ai,faAnyFile);
                  if Found then
                    s := s2
                  else begin
                    s2 := snew +'.bmp';
                    Found := Zip.FindFirst(s2,ai,faAnyFile);
                    if Found then
                      s := s2
                  end;
                end;
              end;
              // bestand uitpakken
              if Found then Zip.ExtractFiles(s);
            finally
              Zip.CloseArchive;
            end;
          end;

          // zoek vervolgens in de GAME-PAKs (pak0.pk3)
          if not Found then begin
            for gp:=0 to Length(PAKsList)-1 do begin
              s2 := s4; // restore
              path := PAKsList[gp].TmpDir; // TmpDir
              Zip.FileName := PAKsList[gp].FullPath; // GameDir +'etmain\pak0.pk3';
              Zip.OpenArchive(fmOpenRead);
              Zip.BaseDir := PAKsList[gp].TmpDir; // TmpDir
              try
                s := s2;
                Found := Zip.FindFirst(s,ai,faAnyFile);
                if not Found then begin
                  // strip extensie
                  s2 := ChangeFileExt(s2,'');
                  //
                  s := s2 +'.tga';
                  Found := Zip.FindFirst(s,ai,faAnyFile);
                  if not Found then begin
                    s := s2 +'.jpg';
                    Found := Zip.FindFirst(s,ai,faAnyFile);
                    if not Found then begin
                      s := s2 +'.bmp';
                      Found := Zip.FindFirst(s,ai,faAnyFile);
                    end;
                  end;
                end;
                if Found then begin
                  Zip.ExtractFiles(s);
                  Break;
                end;
              finally
                Zip.CloseArchive;
              end;
            end;
          end;

          FoundFilename := path + s;
        end else begin
          FoundFilename := Shaders.ShaderFile[surface].Textures[t].FoundFilename;
          Found := true;
        end;

        if Found then begin
          OGL.Textures.GetTextureInfo(FoundFilename, ext, W,H);
          TextureHandle := OGL.Textures.LoadTexture(FoundFilename, Gamma);
          Shaders.ShaderFile[surface].Textures[t].Width := W;
          Shaders.ShaderFile[surface].Textures[t].Height := H;
          Shaders.ShaderFile[surface].Textures[t].FoundFilename := FoundFilename;
          Shaders.ShaderFile[surface].Textures[t].TextureHandle := TextureHandle;
          Shaders.ShaderFile[surface].Textures[t].HasAlphaData := OGL.Textures.HasAlpha(TextureHandle);
          // controleer blendfunc
          if ((Shaders.ShaderFile[surface].Textures[t].BlendFuncSrc = GL_ZERO) and
              (Shaders.ShaderFile[surface].Textures[t].BlendFuncDst = GL_ZERO)) then begin     //wel iets opgegeven??
            if Shaders.ShaderFile[surface].Textures[t].HasAlphaData then begin                 //overrule indien img-alpha aanwezig..
              Shaders.ShaderFile[surface].Textures[t].BlendFuncSrc := GL_SRC_ALPHA;            //blend
              Shaders.ShaderFile[surface].Textures[t].BlendFuncDst := GL_ONE_MINUS_SRC_ALPHA;  //blend
  //              ShaderFile[surface].Textures[t].BlendFuncSrc := GL_DST_COLOR;
  //              ShaderFile[surface].Textures[t].BlendFuncDst := GL_SRC_ALPHA;
            end else begin
              Shaders.ShaderFile[surface].Textures[t].BlendFuncSrc := GL_DST_COLOR;            //filter
              Shaders.ShaderFile[surface].Textures[t].BlendFuncDst := GL_ZERO;                 //filter
            end;
          end;
        end;

      end;
//!    end;
  end;
  // scherm bijwerken
  SurfaceToForm(cbNamesSurfaces.ItemIndex);
  if pcTabs.ActivePage = tabView then OGL_RenderFrame;
  StatusBar.SimpleText := '';
end;

procedure TForm1.UpdateGamma;
var Filename: string;
    LenS,LenT, s,t, TextureHandle: integer;
begin
  LenS := Length(Shaders.ShaderFile);
  for s:=0 to LenS-1 do begin
    LenT := Length(Shaders.ShaderFile[s].Textures);
    for t:=0 to lenT-1 do begin
      Filename := Shaders.ShaderFile[s].Textures[t].FoundFilename;
      if Filename='' then Continue;
      TextureHandle := Shaders.ShaderFile[s].Textures[t].TextureHandle;
      if TextureHandle=0 then Continue;
      OGL.Textures.DeleteTexture(TextureHandle);
      Shaders.ShaderFile[s].Textures[t].TextureHandle := OGL.Textures.LoadTexture(Filename, Gamma);
    end;
  end;
end;



//--- INI-file -----------------------------------------------------------------
procedure TForm1.ReadINI;
var INI: TIniFile;
    name,s: string;
    sl: TStringList;
    i: integer;
begin
  s := ExtractFilename(Application.ExeName);
  name := AppPath + ChangeFileExt(s,'.ini');
  INI := TIniFile.Create(name);
  try
    // gamedir
    cbPAKsList.Clear;  //!!
    GameDir := INI.ReadString('Game', 'GameDir', '');
    if not DirectoryExists(GameDir) then
      GameDir := '';
{    else
      // ET pak0 toevoegen aan game-pak list
      if FileExists(GameDir +'etmain\pak0.pk3') then AddPAK(GameDir +'etmain\pak0.pk3');}

    // settings
{    menuSettingsCleanup.Checked := INI.ReadBool('Settings', 'Cleanup', false);
    cbCleanUp.Checked := menuSettingsCleanup.Checked;}

    // shaderlist
    cbShaderList.Clear;
    if INI.SectionExists('ShaderList') then begin
      sl := TStringList.Create;
      try
        INI.ReadSection('ShaderList', sl);
        for i:=0 to sl.Count-1 do begin
          s := INI.ReadString('ShaderList', sl.Strings[i], '');
          if s<>'' then cbShaderList.Items.Add(s);
        end;
      finally
        sl.Free;
      end;
    end;

    // PAKsList
//    cbPAKsList.Clear;
    if INI.SectionExists('PAKsList') then begin
      sl := TStringList.Create;
      try
        INI.ReadSection('PAKsList', sl);
        for i:=0 to sl.Count-1 do begin
          s := INI.ReadString('PAKsList', sl.Strings[i], '');
          if s<>'' then AddPAK(s);
        end;
      finally
        sl.Free;
      end;
    end;

    // Gamma
    Gamma := INI.ReadFloat('Texturing', 'Gamma', 1.0);
    if Gamma=1.0 then menuViewGammaSW1.Checked := true;
    if Gamma=1.5 then menuViewGammaSW1_5.Checked := true;
    if Gamma=2.0 then menuViewGammaSW2.Checked := true;
    if Gamma=2.5 then menuViewGammaSW2_5.Checked := true;
    if Gamma=3.0 then menuViewGammaSW3.Checked := true;
    if Gamma=3.5 then menuViewGammaSW3_5.Checked := true;
    if Gamma=4.0 then menuViewGammaSW4.Checked := true;
    if Gamma=4.5 then menuViewGammaSW4_5.Checked := true;
    if Gamma=5.0 then menuViewGammaSW5.Checked := true;
    // alpha in texture-preview
    menuViewShowAlphapreview.Checked := INI.ReadBool('View', 'AlphaTexturePreview', true);
    cbAlphaPreview.Checked := menuViewShowAlphapreview.Checked;
    // skeleton
    menuViewShowskeleton.Checked := INI.ReadBool('View', 'ShowSkeleton', true);
    cbShowSkeleton.Checked := menuViewShowskeleton.Checked;
    // tags
    menuViewShowtags.Checked := INI.ReadBool('View', 'ShowTags', true);
    cbShowTags.Checked := menuViewShowtags.Checked;
    // lighting
    menuViewLighting.Checked := INI.ReadBool('View', 'Lighting', true);
    cbLightingEnabled.Checked := menuViewLighting.Checked;
    // center model
    menuViewCenterModel.Checked := INI.ReadBool('View', 'CenterModel', true);
    cbCenterModel.Checked := menuViewCenterModel.Checked;
    // wireframe
    menuViewWireframe.Checked := INI.ReadBool('View', 'WireFrame', false);
    cbWireFrame.Checked := menuViewWireframe.Checked;
    // twosided
    menuViewTwoSided.Checked := INI.ReadBool('View', 'TwoSided', false);
    cbTwoSided.Checked := menuViewTwoSided.Checked;
    // flat shading
    menuViewFlatShading.Checked := INI.ReadBool('View', 'FlatShading', false);
    cbSmoothFlat.Checked := menuViewFlatShading.Checked;
    // groundplane
    menuViewShowGroundplane.Checked := INI.ReadBool('View', 'Groundplane', false);
    cbShowGroundplane.Checked := menuViewShowGroundplane.Checked;
    // axis
    menuViewShowAxis.Checked := INI.ReadBool('View', 'Axis', false);
    cbShowAxis.Checked := menuViewShowAxis.Checked;
    // mouse control
    menuViewMouseControl.Checked := INI.ReadBool('View', 'MouseControl', false);
    cbMouseControl.Checked := menuViewMouseControl.Checked;
    // skybox colors
    menuViewShowskybox.Checked := INI.ReadBool('SkyBox','Enabled',true);
    menuViewSkycolors.Enabled := not menuViewShowskybox.Checked;
    SkyColorTop := INI.ReadInteger('SkyBox', 'ColorTop', SkyColorTop);
    SkyColorBottom := INI.ReadInteger('SkyBox', 'ColorBottom', SkyColorBottom);
  finally
    INI.Free;
  end;
end;

procedure TForm1.WriteINI;
var INI: TIniFile;
    name,s: string;
    i: integer;
begin
  s := ExtractFilename(Application.ExeName);
  name := AppPath + ChangeFileExt(s,'.ini');
  INI := TIniFile.Create(name);
  try
    // gamedir
    INI.WriteString('Game', 'GameDir', GameDir);
    // settings
    INI.WriteBool('Settings', 'Cleanup', menuSettingsCleanup.Checked);
    // shaderlist
    INI.EraseSection('ShaderList');
    for i:=0 to cbShaderList.Items.Count-1 do begin
      s := 'ShaderList'+ IntToStr(i);
      INI.WriteString('ShaderList', s, cbShaderList.Items.Strings[i]);
    end;
    // PAKsList
    INI.EraseSection('PAKsList');
    for i:=0 to Length(PAKsList)-1 do begin
      s := 'PAKsList'+ IntToStr(i);
      INI.WriteString('PAKsList', s, PAKsList[i].FullPath);
    end;
    // Gamma
    INI.WriteFloat('Texturing', 'Gamma', Gamma);
    // alpha in texture-preview
    INI.WriteBool('View', 'AlphaTexturePreview', menuViewShowAlphapreview.Checked);
    // skeleton
    INI.WriteBool('View', 'ShowSkeleton', menuViewShowskeleton.Checked);
    // tags
    INI.WriteBool('View', 'ShowTags', menuViewShowtags.Checked);
    // lighting
    INI.WriteBool('View', 'Lighting', menuViewLighting.Checked);
    // center model
    INI.WriteBool('View', 'CenterModel', menuViewCenterModel.Checked);
    // wireframe
    INI.WriteBool('View', 'WireFrame', menuViewWireframe.Checked);
    // twosided
    INI.WriteBool('View', 'TwoSided', menuViewTwoSided.Checked);
    // flat shading
    INI.WriteBool('View', 'FlatShading', menuViewFlatShading.Checked);
    // groundplane
    INI.WriteBool('View', 'Groundplane', menuViewShowGroundplane.Checked);
    // axis
    INI.WriteBool('View', 'Axis', menuViewShowAxis.Checked);
    // mouse control
    INI.WriteBool('View', 'MouseControl', menuViewMouseControl.Checked);
    // skybox colors
    INI.WriteBool('SkyBox','Enabled',menuViewShowskybox.Checked);
    INI.WriteInteger('SkyBox', 'ColorTop', SkyColorTop);
    INI.WriteInteger('SkyBox', 'ColorBottom', SkyColorBottom);
  finally
    INI.Free;
  end;
end;

//--- menu ---------------------------------------------------------------------
procedure TForm1.menuViewShowskyboxClick(Sender: TObject);
begin
  menuViewShowskybox.Checked := not menuViewShowskybox.Checked;
  OGL.SkyBox.Active := menuViewShowskybox.Checked;
  menuViewSkycolors.Enabled := not menuViewShowskybox.Checked;
end;

procedure TForm1.menuViewSkycolortopAdvancedDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
var r: TRect;
    mi: TMenuItem;
    eh: TAdvancedMenuDrawItemEvent;
begin
  mi := TMenuItem(Sender);
  eh := mi.OnAdvancedDrawItem;
  mi.OnAdvancedDrawItem := nil; // suppresses recursion
  DrawMenuItem(mi, aCanvas, aRect, State); // draws default menuitem
  mi.OnAdvancedDrawItem := eh; // restore event handler
  r.Top := aRect.Top+2;
  r.Bottom := aRect.Bottom-2;
  r.Left := aRect.Left+2;
  r.Right := r.Left + (r.Bottom - r.Top);
  ACanvas.Brush.Color := SkyColorTop;
  ACanvas.Pen.Color := clBlack;
  ACanvas.Rectangle(r);
end;


procedure TForm1.menuViewSkycolorbottomAdvancedDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
var r: TRect;
    mi: TMenuItem;
    eh: TAdvancedMenuDrawItemEvent;
begin
  mi := TMenuItem(Sender);
  eh := mi.OnAdvancedDrawItem;
  mi.OnAdvancedDrawItem := nil; // suppresses recursion
  DrawMenuItem(mi, aCanvas, aRect, State); // draws default menuitem
  mi.OnAdvancedDrawItem := eh; // restore event handler
  r.Top := aRect.Top+2;
  r.Bottom := aRect.Bottom-2;
  r.Left := aRect.Left+2;
  r.Right := r.Left + (r.Bottom - r.Top);
  ACanvas.Brush.Color := SkyColorBottom;
  ACanvas.Pen.Color := clBlack;
  ACanvas.Rectangle(r);
end;

procedure TForm1.menuViewSkycolortopClick(Sender: TObject);
begin
  ColorDialog.Color := SkyColorTop;
  if not ColorDialog.Execute then Exit;
  SkyColorTop := ColorDialog.Color;
end;

procedure TForm1.menuViewSkycolorbottomClick(Sender: TObject);
begin
  ColorDialog.Color := SkyColorBottom;
  if not ColorDialog.Execute then Exit;
  SkyColorBottom := ColorDialog.Color;
end;


procedure TForm1.menuToolsColorconvertRadiantAdvancedDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
var r: TRect;
    mi: TMenuItem;
    eh: TAdvancedMenuDrawItemEvent;
begin
  mi := TMenuItem(Sender);
  eh := mi.OnAdvancedDrawItem;
  mi.OnAdvancedDrawItem := nil; // suppresses recursion
  DrawMenuItem(mi, ACanvas, aRect, State); // draws default menuitem
  mi.OnAdvancedDrawItem := eh; // restore event handler
  r.Top := aRect.Top+2;
  r.Bottom := aRect.Bottom-2;
  r.Left := aRect.Left+2;
  r.Right := r.Left + (r.Bottom - r.Top);
  ACanvas.Brush.Color := ConvertColor;
  ACanvas.Pen.Color := clBlack;
  ACanvas.Rectangle(r);
end;

procedure TForm1.menuToolsColorconvertRadiantClick(Sender: TObject);
var s, sR,sG,sB: string;
    R,G,B: single;
    bR,bG,bB: byte;
begin
  ColorDialog.Color := ConvertColor;
  if not ColorDialog.Execute then Exit;
  ConvertColor := ColorDialog.Color;
  // -> single
  TColorToRGB(ConvertColor, R,G,B);
  // radiant
  sR := FloatToStrF(R, ffFixed, 7,3);
  sG := FloatToStrF(G, ffFixed, 7,3);
  sB := FloatToStrF(B, ffFixed, 7,3);
  s := 'Radiant: '+ sR +' '+ sG +' '+ sB;
  // web
  bR := Round(R * 255);
  bG := Round(G * 255);
  bB := Round(B * 255);
  s := s +'     Web: #'+ IntToHex(bR,2) + IntToHex(bG,2) + IntToHex(bB,2);
  //
  menuToolsColorconvertRadiant.Caption := s;
end;


procedure TForm1.menuViewGammaSW1Click(Sender: TObject);
begin
  Gamma := 1.0;
  menuViewGammaSW1.Checked := true;
  {UpdateShaders;}
  UpdateGamma;
  StatusBar.SimpleText := 'Software Gamma set to: '+ FloatToStr(Gamma);
end;

procedure TForm1.menuViewGammaSW1_5Click(Sender: TObject);
begin
  Gamma := 1.5;
  menuViewGammaSW1_5.Checked := true;
  {UpdateShaders;}
  UpdateGamma;
  StatusBar.SimpleText := 'Software Gamma set to: '+ FloatToStr(Gamma);
end;

procedure TForm1.menuViewGammaSW2Click(Sender: TObject);
begin
  Gamma := 2.0;
  menuViewGammaSW2.Checked := true;
  {UpdateShaders;}
  UpdateGamma;
  StatusBar.SimpleText := 'Software Gamma set to: '+ FloatToStr(Gamma);
end;

procedure TForm1.menuViewGammaSW2_5Click(Sender: TObject);
begin
  Gamma := 2.5;
  menuViewGammaSW2_5.Checked := true;
  {UpdateShaders;}
  UpdateGamma;
  StatusBar.SimpleText := 'Software Gamma set to: '+ FloatToStr(Gamma);
end;

procedure TForm1.menuViewGammaSW3Click(Sender: TObject);
begin
  Gamma := 3.0;
  menuViewGammaSW3.Checked := true;
  {UpdateShaders;}
  UpdateGamma;
  StatusBar.SimpleText := 'Software Gamma set to: '+ FloatToStr(Gamma);
end;

procedure TForm1.menuViewGammaSW3_5Click(Sender: TObject);
begin
  Gamma := 3.5;
  menuViewGammaSW3_5.Checked := true;
  {UpdateShaders;}
  UpdateGamma;
  StatusBar.SimpleText := 'Software Gamma set to: '+ FloatToStr(Gamma);
end;

procedure TForm1.menuViewGammaSW4Click(Sender: TObject);
begin
  Gamma := 4.0;
  menuViewGammaSW4.Checked := true;
  {UpdateShaders;}
  UpdateGamma;
  StatusBar.SimpleText := 'Software Gamma set to: '+ FloatToStr(Gamma);
end;

procedure TForm1.menuViewGammaSW4_5Click(Sender: TObject);
begin
  Gamma := 4.5;
  menuViewGammaSW4_5.Checked := true;
  {UpdateShaders;}
  UpdateGamma;
  StatusBar.SimpleText := 'Software Gamma set to: '+ FloatToStr(Gamma);
end;

procedure TForm1.menuViewGammaSW5Click(Sender: TObject);
begin
  Gamma := 5.0;
  menuViewGammaSW5.Checked := true;
  {UpdateShaders;}
  UpdateGamma;
  StatusBar.SimpleText := 'Software Gamma set to: '+ FloatToStr(Gamma);
end;


procedure TForm1.MemoHelpClick(Sender: TObject);
begin
  HideHelp;
end;

//--- actions ------------------------------------------------------------------
procedure TForm1.actionViewLightingExecute(Sender: TObject);
begin
  if Sender = cbLightingEnabled then
    menuViewLighting.Checked := cbLightingEnabled.Checked
  else begin
    menuViewLighting.Checked := not menuViewLighting.Checked;
    cbLightingEnabled.Checked := menuViewLighting.Checked;
  end;
  if pcTabs.ActivePage = tabView then OGL_RenderFrame;
end;

procedure TForm1.actionViewShowtagsExecute(Sender: TObject);
begin
  if Sender = cbShowTags then
    menuViewShowtags.Checked := cbShowTags.Checked
  else begin
    menuViewShowtags.Checked := not menuViewShowtags.Checked;
    cbShowTags.Checked := menuViewShowtags.Checked;
  end;
end;

procedure TForm1.actionViewShowskeletonExecute(Sender: TObject);
begin
  if Sender = cbShowSkeleton then
    menuViewShowskeleton.Checked := cbShowSkeleton.Checked
  else begin
    menuViewShowskeleton.Checked := not menuViewShowskeleton.Checked;
    cbShowSkeleton.Checked := menuViewShowskeleton.Checked;
  end;
end;

procedure TForm1.actionViewShowalphapreviewExecute(Sender: TObject);
begin
  if Sender = cbAlphaPreview then
    menuViewShowAlphapreview.Checked := cbAlphaPreview.Checked
  else begin
    menuViewShowAlphapreview.Checked := not menuViewShowAlphapreview.Checked;
    cbAlphaPreview.Checked := menuViewShowAlphapreview.Checked;
  end;
  TextureToForm(cbNamesSurfaces.ItemIndex, cbShaderTextures.ItemIndex);
end;

procedure TForm1.actionViewCenterModelExecute(Sender: TObject);
begin
  if Sender = cbCenterModel then
    menuViewCenterModel.Checked := cbCenterModel.Checked
  else begin
    menuViewCenterModel.Checked := not menuViewCenterModel.Checked;
    cbCenterModel.Checked := menuViewCenterModel.Checked;
  end;
  if cbCenterModel.Checked then ResetModelTransform;
end;

procedure TForm1.actionViewWireframeExecute(Sender: TObject);
begin
  if Sender = cbWireFrame then
    menuViewWireframe.Checked := cbWireFrame.Checked
  else begin
    menuViewWireframe.Checked := not menuViewWireframe.Checked;
    cbWireFrame.Checked := menuViewWireframe.Checked;
  end;
end;

procedure TForm1.actionViewTwoSidedExecute(Sender: TObject);
begin
  if Sender = cbTwoSided then
    menuViewTwoSided.Checked := cbTwoSided.Checked
  else begin
    menuViewTwoSided.Checked := not menuViewTwoSided.Checked;
    cbTwoSided.Checked := menuViewTwoSided.Checked;
  end;
end;

procedure TForm1.actionViewSmoothFlatExecute(Sender: TObject);
begin
  if Sender = cbSmoothFlat then
    menuViewFlatShading.Checked := cbSmoothFlat.Checked
  else begin
    menuViewFlatShading.Checked := not menuViewFlatShading.Checked;
    cbSmoothFlat.Checked := menuViewFlatShading.Checked;
  end;
end;

procedure TForm1.actionViewGroundplaneExecute(Sender: TObject);
begin
  if Sender = cbShowGroundplane then
    menuViewShowGroundplane.Checked := cbShowGroundplane.Checked
  else begin
    menuViewShowGroundplane.Checked := not menuViewShowGroundplane.Checked;
    cbShowGroundplane.Checked := menuViewShowGroundplane.Checked;
  end;
end;

procedure TForm1.actionViewAxisExecute(Sender: TObject);
begin
  if Sender = cbShowAxis then
    menuViewShowAxis.Checked := cbShowAxis.Checked
  else begin
    menuViewShowAxis.Checked := not menuViewShowAxis.Checked;
    cbShowAxis.Checked := menuViewShowAxis.Checked;
  end;
end;

procedure TForm1.actionViewMouseControlExecute(Sender: TObject);
begin
  // de manier hoe de muis het mnodel draait
  if Sender = cbMouseControl then
    menuViewMouseControl.Checked := cbMouseControl.Checked
  else begin
    menuViewMouseControl.Checked := not menuViewMouseControl.Checked;
    cbMouseControl.Checked := menuViewMouseControl.Checked;
  end;
  // caption
  if cbMouseControl.Checked then begin
    cbMouseControl.Caption := actionViewMouseControl.Caption + ' 2';
    menuViewMouseControl.Caption := actionViewMouseControl.Caption + ' 2';
  end else begin
    cbMouseControl.Caption := actionViewMouseControl.Caption + ' 1';
    menuViewMouseControl.Caption := actionViewMouseControl.Caption + ' 1';
  end;
end;

procedure TForm1.actionSettingsCleanupExecute(Sender: TObject);
begin
{
  if Sender = cbCleanUp then
    menuSettingsCleanup.Checked := cbCleanUp.Checked
  else begin
    menuSettingsCleanup.Checked := not menuSettingsCleanup.Checked;
    cbCleanUp.Checked := menuSettingsCleanup.Checked;
  end;
}
end;

procedure TForm1.actionModelClearExecute(Sender: TObject);
begin
  LoadedFrom := lfNone;
  LoadedType := ltNone;
  MD3.Clear;
  MDM.Clear;
  MDX.Clear;
  ClearMD3Info;
  ClearMDMMDXInfo;
  ShowMenuNone;
  ShowTabsNone;
  actionFileClearSkinExecute(nil); //skins verwijderen
//  gbTagManually.Visible := true;
  SetupAnimation;
  menuFileSave.Hint := '';
  actionFileSaveAs.Hint := '';
  StatusBar.SimpleText := 'Environment cleared..';
end;

procedure TForm1.actionFileLoadExecute(Sender: TObject);
var b: boolean;
begin
  StatusBar.SimpleText := '';
  InterruptPlayback := true;
  cbLODEnabled.Checked := false;
  seLODSurfaceNr.MinValue := -1;
  seLODSurfaceNr.MaxValue := -1;
  seLODSurfaceNr.Value := -1;
  cbAnimName.Clear;
  ModelIsScaled := false;
{  LoadedFrom := lfFile;
  LoadedType := ltNone;}
  try
    ShowNone;
    LoadedFrom := lfFile;
    LoadedType := ltMD3;
    // MD3 laden
    dlgPK3.MapPK3 := '';
if not IsDragDropped then begin
    OpenDialog.FileName := '';
    if not OpenDialog.Execute then Exit;
end;
    if not MD3.LoadFromFile(OpenDialog.FileName) then begin
      ShowNone;
      Exit;
    end;
    Screen.Cursor := crHourGlass;
    ShowTabsMD3;
    {Form1.}Refresh;
    ModelDir := ExtractFilePath(OpenDialog.FileName);
    ShowMD3Info;
    ShowMenuMD3;
    leName.Text := OpenDialog.FileName;
    {gbInsertTags.Enabled := true;
    gbTagManually.Visible := (MD3.Header.Values.Num_Frames=1); //alleen handmatig toevoegen als het een model betreft zonder animatie}
    gbModel.Caption := ExtractFilename(OpenDialog.FileName);
    // skin wissen
    actionFileClearSkinExecute(nil);
    // animatie
    SetupAnimation;
    ResetModelTransform;
    // shaders
    UpdateShaders;
    StatusBar.SimpleText := MSG_MD3_LOADED;
    menuFileSave.Hint := 'Save as MD3';
    actionFileSaveAs.Hint := 'Save as MD3';
  finally
    InterruptPlayback := false;
    OGL_RenderFrame;
    Screen.Cursor := crDefault;
  end;
end;

// MD3 laden uit de pak0.pk3
procedure TForm1.actionFileLoadfrompk3Execute(Sender: TObject);
var s: string;
    b: boolean;
    gp: integer;
begin
  StatusBar.SimpleText := '';
  InterruptPlayback := true;
  cbLODEnabled.Checked := false;
  seLODSurfaceNr.MinValue := -1;
  seLODSurfaceNr.MaxValue := -1;
  seLODSurfaceNr.Value := -1;
  cbAnimName.Clear;
  ModelIsScaled := false;
  try
    ShowNone;
//    if GameDir='' then Exit;
    if Length(PAKsList)=0 then Exit;
    {Form1.}Refresh;
    LoadedFrom := lfGame;
    LoadedType := ltMD3;
    OpenDialog.FileName := '';
    dlgPK3.Tag := 0; //MD3 laden..
    dlgPK3.MapPK3 := '';
    if dlgPK3.ShowModal <> mrOK then Exit;
    if dlgPK3.tvPK3.SelectionCount=0 then Exit;
    if dlgPK3.tvPK3.Selected.HasChildren then Exit;
    s := dlgPK3.tvPK3.Selected.Parent.Text + dlgPK3.tvPK3.Selected.Text;
    Screen.Cursor := crHourGlass;
    ModelDir := '';
    OpenDialog.FileName := '';

    // MD3 laden uit de GAME-PAK (pak0.pk3)
    for gp:=0 to Length(PAKsList)-1 do begin
      Zip.BaseDir := TmpDir;
      Zip.FileName := PAKsList[gp].FullPath; // GameDir +'etmain\pak0.pk3';
      Zip.OpenArchive(fmOpenRead);
      try
        Zip.ExtractFiles(s);
      finally
        Zip.CloseArchive;
      end;
    end;
    if not MD3.LoadFromFile(TmpDir+s) then begin
      ShowNone;
      Exit;
    end;
    ShowTabsMD3;
    ShowMenuMD3;
    ShowMD3Info;

    leName.Text := 'GAME:\\'+s;
    {gbInsertTags.Enabled := true;
    gbTagManually.Visible := (MD3.Header.Values.Num_Frames=1); //alleen handmatig toevoegen als het een model betreft zonder animatie}
    gbModel.Caption := ExtractFilename(s);
    // skin wissen
    actionFileClearSkinExecute(nil);
    // transformatie/animatie
    SetupAnimation;
    ResetModelTransform;
    // shaders
    UpdateShaders;
    StatusBar.SimpleText := MSG_MD3_LOADED;
    menuFileSave.Hint := 'Save as MD3';
    actionFileSaveAs.Hint := 'Save as MD3';
  finally
    InterruptPlayback := false;
    OGL_RenderFrame;
    Screen.Cursor := crDefault;
  end;
end;

// MD3 laden uit een map.pk3
procedure TForm1.actionFileLoadfrommappk3Execute(Sender: TObject);
var s: string;
    b: boolean;
begin
  StatusBar.SimpleText := '';
  InterruptPlayback := true;
  cbLODEnabled.Checked := false;
  seLODSurfaceNr.MinValue := -1;
  seLODSurfaceNr.MaxValue := -1;
  seLODSurfaceNr.Value := -1;
  cbAnimName.Clear;
  ModelIsScaled := false;
  try
    ShowNone;
//    if GameDir='' then Exit;
//    if Length(PAKsList)=0 then Exit;
    LoadedFrom := lfPK3;
    LoadedType := ltMD3;
    OpenDialog.FileName := '';
    dlgPK3.Tag := 3; //Map.pk3 laden..
    dlgPK3.MapPK3 := '';
    if dlgPK3.ShowModal <> mrOK then Exit;
    if dlgPK3.MapPK3='' then Exit;
    if dlgPK3.tvPK3.Selected=nil then Exit;
    if dlgPK3.tvPK3.Selected.Parent=nil then Exit;
    if dlgPK3.tvPK3.Selected.HasChildren then Exit;
    s := dlgPK3.tvPK3.Selected.Parent.Text + dlgPK3.tvPK3.Selected.Text;
    Screen.Cursor := crHourGlass;
    ModelDir := '';
    OpenDialog.FileName := '';
    //

    //Model + alle shaders in map.pk3\scripts uitpakken
    Zip.BaseDir := TmpDir +'tmpmap\';
    Zip.FileName := dlgPK3.MapPK3;
    Zip.OpenArchive(fmOpenRead);
    try
      Zip.ExtractFiles('scripts\*.shader');
      Zip.ExtractFiles(s);
    finally
      Zip.CloseArchive;
    end;
    //
    LoadMapShaders;
    //
    if not MD3.LoadFromFile(TmpDir +'tmpmap\'+s) then begin
      ShowNone;
      Exit;
    end;
    ShowTabsMD3;
    ShowMenuMD3;
    ShowMD3Info;
    {Form1.}Refresh;
    leName.Text := 'MAP:\\'+s;
    {gbInsertTags.Enabled := true;
    gbTagManually.Visible := (MD3.Header.Values.Num_Frames=1); //alleen handmatig toevoegen als het een model betreft zonder animatie}
    gbModel.Caption := ExtractFilename(s);
    // skin wissen
    actionFileClearSkinExecute(nil);
    // transformatie/animatie
    SetupAnimation;
    ResetModelTransform;
    // shaders
    UpdateShaders;
    StatusBar.SimpleText := MSG_MD3_LOADED;
    menuFileSave.Hint := 'Save as MD3';
    actionFileSaveAs.Hint := 'Save as MD3';
  finally
    InterruptPlayback := false;
    OGL_RenderFrame;
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.actionFileSaveAsExecute(Sender: TObject);
var b,pass1,pass2, r: boolean;
    strSavedAs: string;
    s: integer;
begin
{  b := cbPlay.Checked;
  cbPlay.Checked := false;}
  InterruptPlayback := true;
  strSavedAs := '';
  StatusBar.SimpleText := '';
  pass1 := true;  //tbv MDM/MDX
  pass2 := true;  //tbv MDM/MDX
  try
    case LoadedType of
      ltMD3,ltMap,ltASE,ltMS3D_MD3: begin
        // MD3 opslaan
        SaveAsDialog.DefaultExt := '.MD3';
        SaveAsDialog.Filter := 'Quake 3 model (.MD3)|*.MD3';
        SaveAsDialog.Title := 'Save a model';
        if not SaveAsDialog.Execute then Exit;
        if not MD3.SaveToFile(SaveAsDialog.FileName) then Exit;
        gbModel.Caption := ExtractFilename(SaveAsDialog.FileName);
        strSavedAs := 'Model saved to file: '+ ExtractFilename(SaveAsDialog.FileName);
      end;
      ltMDMMDX,ltMDS,ltMS3D_MDMMDX: begin
        strSavedAs := 'Model saved to file(s): ';
        // MDM opslaan
        pass1 := false;
        SaveAsDialog.FileName := '';
        SaveAsDialog.DefaultExt := '.MDM';
        SaveAsDialog.Filter := 'ET playermodel (.MDM)|*.MDM';
        SaveAsDialog.Title := 'Save a playermodel';
        if not SaveAsDialog.Execute then Exit;
        if not MDM.SaveToFile(SaveAsDialog.FileName) then Exit;
        gbModel.Caption := ExtractFilename(SaveAsDialog.FileName);
        strSavedAs := strSavedAs + ExtractFilename(SaveAsDialog.FileName);
        pass1 := true;
        // MDX opslaan
        pass2 := false;
        SaveAsDialog.FileName := '';
        SaveAsDialog.DefaultExt := '.MDX';
        SaveAsDialog.Filter := 'ET playermodel animation (.MDX)|*.MDX';
        SaveAsDialog.Title := 'Save a playermodel animation';
        if not SaveAsDialog.Execute then Exit;
        if not MDX.SaveToFile(SaveAsDialog.FileName) then Exit;
        if pass1 then strSavedAs := strSavedAs +' & '+ ExtractFilename(SaveAsDialog.FileName)
                 else strSavedAs := strSavedAs + ExtractFilename(SaveAsDialog.FileName);
        pass2 := true;
      end;
    end;
  finally
{    cbPlay.Checked := b;}
    InterruptPlayback := false;
    OGL_RenderFrame;
    if not (pass1 and pass2) then strSavedAs := '';
    StatusBar.SimpleText := strSavedAs;
  end;
end;

procedure TForm1.actionFileExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TForm1.actionSettingsGamedirExecute(Sender: TObject);
var Dir: string;
    p: integer;
begin
  // set game directory.
  // .. nodig om de gamefiles te lezen
  Dir := '';
  GameDir := Dir;
  SelectDirectory('Select path to "Wolfenstein - Enemy Territory"'#13#10'If You do not have ET installed, just cancel this operation..', '', Dir);
  if Dir='' then Exit;
  // test of ze misschien de etmain-dir hebben gekozen..
  p := Pos('etmain',Dir);
  if p>0 then Dir := Copy(Dir,1,Length(Dir)-p+1);
  //
  if Dir[Length(Dir)]<>'\' then Dir := Dir + '\';
  if not DirectoryExists(Dir+'etmain') then Exit;
  if not FileExists(Dir +'etmain\pak0.pk3') then Exit;
  GameDir := Dir;

  //toevoegen aan de lijst
  AddPAK(GameDir+'etmain\pak0.pk3');

  Screen.Cursor := crHourGlass;
  SetGameDir(GameDir);
  actionFileLoadfrompk3.Enabled := (GameDir<>'');
  actionFileLoadfromgameMDMMDX.Enabled := (GameDir<>'');
  actionFileSelectSkinfrompk3.Enabled := (GameDir<>'');
  Screen.Cursor := crDefault;
end;



procedure TForm1.actionFileSelectSkinExecute(Sender: TObject);
begin
  // Skins laden
if not IsDragDropped then
  if not SkinOpenDialog.Execute then Exit;
  Screen.Cursor := crHourGlass;
  {Form1.}Refresh;
  LoadSkinFile(SkinOpenDialog.FileName);
  Screen.Cursor := crDefault;
end;

procedure TForm1.actionFileSelectSkinfrompk3Execute(Sender: TObject);  //fromGame was een betere naam..:S
var s: string;
    gp: integer;
begin
  //if GameDir='' then Exit;
  if Length(PAKsList)=0 then Exit;
  dlgPK3.Tag := 1; //skin laden..
  if not (dlgPK3.ShowModal in [mrOK,mrYes]) then Exit;
  if dlgPK3.tvPK3.Selected.HasChildren then Exit;
  s := dlgPK3.tvPK3.Selected.Parent.Text + dlgPK3.tvPK3.Selected.Text;

  Screen.Cursor := crHourGlass;
  {Form1.}Refresh;

  // skin laden uit de gamepak (pak0.pk3)
  Zip.BaseDir := TmpDir;
//  Zip.FileName := GameDir +'etmain\pak0.pk3';
  Zip.FileName := dlgPK3.PAKfile; // GameDir +'etmain\pak0.pk3';
  Zip.OpenArchive(fmOpenRead);
  try
    Zip.ExtractFiles(s);
  finally
    Zip.CloseArchive;
    LoadSkinFile(TmpDir+s);
  end;

  Screen.Cursor := crDefault;
end;

procedure TForm1.actionFileClearSkinExecute(Sender: TObject);
var Len: integer;
begin
  leSkinFile.Text := '';
  leSkin.Text := '';
  menuSkinToModel.Enabled := false;
  Len := Length(SkinShaders);
  if Len=0 then Exit;
  SetLength(SkinShaders, 0);  //skins verwijderen
  //DeleteTextures;
  UpdateShaders;
end;

procedure TForm1.actionFileAddtoshaderlistExecute(Sender: TObject);
begin
  // Shader-file aan ShaderList toevoegen
  if not ShaderOpenDialog.Execute then Exit;
  if ShaderOpenDialog.FileName='' then Exit;
  cbShaderList.Items.Add(ShaderOpenDialog.FileName);
  cbShaderList.ItemIndex := cbShaderList.Items.Count-1;
  LoadShaderListShaders;
end;

procedure TForm1.actionFileClearshaderlistExecute(Sender: TObject);
begin
  cbShaderList.Clear;
  LoadShaderListShaders;
end;

procedure TForm1.actionHelpExecute(Sender: TObject);
begin
  if pcTabs.ActivePage <> tabHelp then
    ShowHelp
  else
    HideHelp;
end;

procedure TForm1.actionFileAddframeExecute(Sender: TObject);
var s,s2, ErrorString: string;
begin
  StatusBar.SimpleText := '';
  s := OpenDialog.FileName; //onthouden
  OpenDialog.FileName := '';
  if not OpenDialog.Execute then Exit;
  if not MD3.AddFrame(OpenDialog.FileName, ErrorString) then begin
    StatusBar.SimpleText := ErrorString;
    Exit;
  end;
  s2 := ExtractFilename(OpenDialog.FileName);
  OpenDialog.FileName := s; //herstellen
  ShowMD3Info;
  SetupAnimation;
  UpdateShaders;
  gbModel.Caption := gbModel.Caption +'*';
  StatusBar.SimpleText := 'Frame[0] (of '+ s2 +') was added to the current model';
end;

procedure TForm1.actionFileAddframesExecute(Sender: TObject);
var s,s2, ErrorString: string;
begin
  StatusBar.SimpleText := '';
  s := OpenDialog.FileName; //onthouden
  OpenDialog.FileName := '';
  if not OpenDialog.Execute then Exit;
  if not MD3.AddFrames(OpenDialog.FileName, ErrorString) then begin
    StatusBar.SimpleText := ErrorString;
    Exit;
  end;
  s2 := ExtractFilename(OpenDialog.FileName);
  OpenDialog.FileName := s; //herstellen
  ShowMD3Info;
  SetupAnimation;
  UpdateShaders;
  gbModel.Caption := gbModel.Caption +'*';
  StatusBar.SimpleText := 'All frames (of '+ s2 +') were added to the current model';
end;

procedure TForm1.actionFileAddframesequenceExecute(Sender: TObject);
var s, ErrorString: string;
    sl: TStringList;
    i: integer;
begin
  StatusBar.SimpleText := '';
  s := OpenDialogMD3s.FileName; //onthouden
  OpenDialogMD3s.FileName := '';
  if not OpenDialogMD3s.Execute then Exit;

  sl := TStringList.Create;
  try
    sl.Assign(OpenDialogMD3s.Files);
    sl.Sort;
    for i:=0 to sl.Count-1 do begin
      if not MD3.AddFrame(sl.Strings[i], ErrorString) then begin
        StatusBar.SimpleText := ErrorString;
        Exit;
      end;
    end;
    ShowMD3Info;
    SetupAnimation;
    UpdateShaders;
    gbModel.Caption := gbModel.Caption +'*';
    StatusBar.SimpleText := 'Frame[0] (of '+ IntToStr(sl.Count) +' files) were added to the current model';
  finally
    sl.Free;
    OpenDialogMD3s.FileName := s; //herstellen
  end;
end;


procedure TForm1.actionModelDeleteframeExecute(Sender: TObject);
var Result, f: integer;
begin
  StatusBar.SimpleText := '';
  if (LoadedType<>ltMD3) then Exit;
  if MD3.Header.Values.Num_Frames <= 1 then Exit; // altijd 1 frame laten bestaan
  if Current_Frame < 0 then Exit;
  Result := Application.MessageBox(PChar('Are You sure You want to remove the current frame?.. Frame['+IntToStr(Current_Frame)+'] ?'),
                                   PChar('Confirmation'),
                                   MB_YESNOCANCEL);
  if (Result=IDNO) or (Result=IDCANCEL) then Exit;
  f := Current_Frame;
  MD3.DeleteFrame(Current_Frame);
  SetupAnimation;
  // current frame herstellen op oude frame
  if f <= tbCurrentFrame.Max then begin
    Current_Frame := f;
    tbCurrentFrame.Position := f;
    lCurrentFrame.Caption := IntToStr(f);
  end;
  //
  ShowMD3Info;
  gbModel.Caption := gbModel.Caption +'*';
  StatusBar.SimpleText := 'Frame['+ IntToStr(f) +'] has been removed';
end;


procedure TForm1.actionModelMD3ScaleExecute(Sender: TObject);
var f,t,s,v,
    FCount,TCount,SCount,VCount: integer;
    scale: single;
    strScale: string;
begin
  StatusBar.SimpleText := '';
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if not InputQuery('Enter the scaling factor','Scaling Factor', strScale) then Exit;
  if not TryStrToFloat(strScale, scale) then Exit;
  if scale=1.0 then Exit;
  // Frames
  SCount := MDM.Header.Num_Surfaces;
  TCount := MD3.Header.Values.Num_Tags;
  FCount := MD3.Header.Values.Num_Frames;
  for f:=0 to FCount-1 do begin
    MD3.Header.Frames[f].Min_Bounds := ScaleVector(MD3.Header.Frames[f].Min_Bounds, scale);
    MD3.Header.Frames[f].Max_Bounds := ScaleVector(MD3.Header.Frames[f].Max_Bounds, scale);
    MD3.Header.Frames[f].Local_Origin := ScaleVector(MD3.Header.Frames[f].Local_Origin, scale);
    MD3.Header.Frames[f].Radius := scale * MD3.Header.Frames[f].Radius;
  end;
  // Tags
  for f:=0 to FCount-1 do
    for t:=0 to TCount-1 do begin
      // origin
      MD3.Header.Tags[f*TCount+t].Origin := ScaleVector(MD3.Header.Tags[f*TCount+t].Origin, scale);
{
      // axis
      MD3.Header.Tags[f*TCount+t].Axis[0] := ScaleVector(MD3.Header.Tags[f*TCount+t].Axis[0], scale);
      MD3.Header.Tags[f*TCount+t].Axis[1] := ScaleVector(MD3.Header.Tags[f*TCount+t].Axis[1], scale);
      MD3.Header.Tags[f*TCount+t].Axis[2] := ScaleVector(MD3.Header.Tags[f*TCount+t].Axis[2], scale);
}
    end;
  // Surfaces
  for s:=0 to SCount-1 do begin
    VCount := MD3.Header.Surfaces[s].Values.Num_Verts;
    // vertex
    for f:=0 to FCount-1 do
      for v:=0 to VCount-1 do begin
        MD3.Header.Surfaces[s].Vertex[f*VCount+v].X := Round(scale * MD3.Header.Surfaces[s].Vertex[f*VCount+v].X);
        MD3.Header.Surfaces[s].Vertex[f*VCount+v].Y := Round(scale * MD3.Header.Surfaces[s].Vertex[f*VCount+v].Y);
        MD3.Header.Surfaces[s].Vertex[f*VCount+v].Z := Round(scale * MD3.Header.Surfaces[s].Vertex[f*VCount+v].Z);
      end;
  end;

  ModelIsScaled := true;
  ShowMD3Info;
  StatusBar.SimpleText := 'Model scaled by factor '+ strScale;

  SetupAnimation;
  ResetModelTransform;
end;


//------------------------------
//--- MDM/MDX ------------------
//------------------------------
procedure TForm1.actionFileLoadfromgameMDMMDXExecute(Sender: TObject);
var s1,s2,s3: string;
    s,i,Len: integer;
    b: boolean;
begin
  StatusBar.SimpleText := '';
  InterruptPlayback := true;
  cbLODEnabled.Checked := false;
  seLODSurfaceNr.MinValue := -1;
  seLODSurfaceNr.MaxValue := -1;
  seLODSurfaceNr.Value := -1;
  cbAnimName.Clear;
  ModelIsScaled := false;
  try
    ShowNone;
//    if GameDir='' then Exit;
    if Length(PAKsList)=0 then Exit;
    OpenDialog.FileName := '';
    dlgPK3.Tag := 4; //MDM laden..
    dlgPK3.MapPK3 := '';
    if dlgPK3.ShowModal <> mrOK then Exit;
    if dlgPK3.tvPK3.SelectionCount=0 then Exit;
    if dlgPK3.tvPK3.Selected.HasChildren then Exit;
    s1 := dlgPK3.tvPK3.Selected.Parent.Text + dlgPK3.tvPK3.Selected.Text;
    Screen.Cursor := crHourGlass;
    ModelDir := '';
    OpenDialog.FileName := '';

    // MDM laden uit de pak0.pk3
    Zip.BaseDir := TmpDir;
//    Zip.FileName := GameDir +'etmain\pak0.pk3';
    Zip.FileName := dlgPK3.PAKfile; // GameDir +'etmain\pak0.pk3';
    Zip.OpenArchive(fmOpenRead);
    Zip.ExtractFiles(s1);
    Zip.CloseArchive;
    if not MDM.LoadFromFile(TmpDir+s1) then begin
      ShowNone;
      Exit;
    end;
    s3 := dlgPK3.PathDir;

    // MDX
    dlgPK3.Tag := 5; //MDX laden..
    dlgPK3.MapPK3 := '';
    if dlgPK3.ShowModal <> mrOK then Exit;
    if dlgPK3.tvPK3.SelectionCount=0 then Exit;
    if dlgPK3.tvPK3.Selected.HasChildren then Exit;
    s2 := dlgPK3.tvPK3.Selected.Parent.Text + dlgPK3.tvPK3.Selected.Text;
    // MDX laden uit de pak0.pk3
    Zip.BaseDir := TmpDir;
//    Zip.FileName := GameDir +'etmain\pak0.pk3';
    Zip.FileName := dlgPK3.PAKfile; // GameDir +'etmain\pak0.pk3';
    Zip.OpenArchive(fmOpenRead);
    Zip.ExtractFiles(s2);
    Zip.CloseArchive;
    if not MDX.LoadFromFile(TmpDir+s2) then begin
      ShowNone;
      Exit;
    end;

    // aninc laden uit de pak0.pk3
    s2 := ChangeFileExt(s2,'.aninc');
    Zip.BaseDir := TmpDir;
//    Zip.FileName := GameDir +'etmain\pak0.pk3';
    Zip.FileName := dlgPK3.PAKfile; // GameDir +'etmain\pak0.pk3';
    Zip.OpenArchive(fmOpenRead);
    Zip.ExtractFiles(s2);
    Zip.CloseArchive;
    cbAnimName.Clear;
    if Aninc.LoadFromFile(TmpDir+s2) then
      for i:=0 to Length(Aninc.Anims)-1 do cbAnimName.Items.Add(Aninc.Anims[i].Name);

    dlgPK3.PathDir := s3;

    LoadedFrom := lfGame;
    LoadedType := ltMDMMDX;
    ShowTabsMDMMDX;
    ShowMenuMDMMDX;
    ShowMDMMDXInfo;
    {Form1.}Refresh;

    leName.Text := 'GAME:\\'+s1;
    {gbInsertTags.Enabled := true;
    gbTagManually.Visible := (MD3.Header.Values.Num_Frames=1); //alleen handmatig toevoegen als het een model betreft zonder animatie}
    gbModel.Caption := ExtractFilename(s1);
    // skin wissen
    actionFileClearSkinExecute(nil);
    // transformatie/animatie
    SetupAnimation;
    ResetModelTransform;
    // shaders
    UpdateShaders;
    StatusBar.SimpleText := MSG_MDMMDX_LOADED;
    menuFileSave.Hint := 'Save as MDM/MDX';
    actionFileSaveAs.Hint := 'Save as MDM/MDX';
  finally
    InterruptPlayback := false;
    OGL_RenderFrame;
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.actionFileLoadMDMMDXExecute(Sender: TObject);
var s: string;
    i: integer;
    b: boolean;
begin
  StatusBar.SimpleText := '';
  InterruptPlayback := true;
  cbLODEnabled.Checked := false;
  seLODSurfaceNr.MinValue := -1;
  seLODSurfaceNr.MaxValue := -1;
  seLODSurfaceNr.Value := -1;
  cbAnimName.Clear;
  ModelIsScaled := false;
  try
    ShowNone;
    // MDM laden
    dlgPK3.MapPK3 := '';
if not IsDragDropped then begin
    MDMOpenDialog.FileName := '';
    if not MDMOpenDialog.Execute then Exit;
end;
    if not MDM.LoadFromFile(MDMOpenDialog.FileName) then begin
      ShowNone;
      Exit;
    end;
    // MDX laden
if not IsDragDropped then begin
    MDXOpenDialog.FileName := '';
    if not MDXOpenDialog.Execute then Exit;
end;
    if not MDX.LoadFromFile(MDXOpenDialog.FileName) then begin
      ShowNone;
      Exit;
    end;

    // aninc laden
    s := ChangeFileExt(MDXOpenDialog.FileName,'.aninc');
    cbAnimName.Clear;
    if Aninc.LoadFromFile(s) then
      for i:=0 to Length(Aninc.Anims)-1 do cbAnimName.Items.Add(Aninc.Anims[i].Name);

    Screen.Cursor := crHourGlass;
    ShowTabsMDMMDX;
    ShowMenuMDMMDX;
    {Form1.}Refresh;
    LoadedFrom := lfFile;
    LoadedType := ltMDMMDX;
    {ModelDir := '';}
    ModelDir := ExtractFilePath(MDMOpenDialog.FileName);
    OpenDialog.FileName := '';
    ShowMDMMDXInfo;
    leName.Text := ExtractFilename(MDMOpenDialog.FileName);
    gbModel.Caption := ExtractFilename(MDMOpenDialog.FileName);
    // skin wissen
    actionFileClearSkinExecute(nil);
    // transformatie/animatie
    SetupAnimation;
    ResetModelTransform;
    // shaders
    UpdateShaders;
    StatusBar.SimpleText := MSG_MDMMDX_LOADED;
    menuFileSave.Hint := 'Save as MDM/MDX';
    actionFileSaveAs.Hint := 'Save as MDM/MDX';
  finally
    InterruptPlayback := false;
    OGL_RenderFrame;
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.actionFileLoadMDXExecute(Sender: TObject);
var s: string;
    i: integer;
    b: boolean;
begin
  StatusBar.SimpleText := '';
  if (LoadedType<>ltMDMMDX) and (LoadedType<>ltMDS) then Exit;
  InterruptPlayback := true;
  cbLODEnabled.Checked := false;
  seLODSurfaceNr.MinValue := -1;
  seLODSurfaceNr.MaxValue := -1;
  seLODSurfaceNr.Value := -1;
  cbAnimName.Clear; 
  ModelIsScaled := false;
  try
    ClearMDMMDXInfo;
  //  ClearMapShaders;
    // MD3 laden
    dlgPK3.MapPK3 := '';
    MDXOpenDialog.FileName := '';
    if not MDXOpenDialog.Execute then Exit;
    if not MDX.LoadFromFile(MDXOpenDialog.FileName) then Exit;

    // aninc laden
    s := ChangeFileExt(MDXOpenDialog.FileName,'.aninc');
    cbAnimName.Clear; 
    if Aninc.LoadFromFile(s) then
      for i:=0 to Length(Aninc.Anims)-1 do cbAnimName.Items.Add(Aninc.Anims[i].Name);

    Screen.Cursor := crHourGlass;
    ShowTabsMDMMDX;
    ShowMenuMDMMDX;
    {Form1.}Refresh;
    LoadedFrom := lfFile;
    LoadedType := ltMDMMDX;
  {  ModelDir := ExtractFilePath(MDMOpenDialog.FileName);}
    OpenDialog.FileName := '';
    ShowMDMMDXInfo;
  {  leName.Text := ExtractFilename(MDMOpenDialog.FileName);
    gbModel.Caption := ExtractFilename(MDMOpenDialog.FileName);
    // skin wissen
    actionFileClearSkinExecute(nil);}
    // transformatie/animatie
    SetupAnimation;
    ResetModelTransform;
{    // shaders
    UpdateShaders;}
    StatusBar.SimpleText := MSG_MDX_LOADED;
  finally
    InterruptPlayback := false;
    OGL_RenderFrame;
    Screen.Cursor := crDefault;
  end;
end;


procedure TForm1.actionFileLoadMDXbonesExecute(Sender: TObject);
var s: string;
    i: integer;
    b: boolean;
begin
  StatusBar.SimpleText := '';
  // laad alleen de bones van een MDX, maar niet de animaties
  if (LoadedType<>ltMDMMDX) and (LoadedType<>ltMDS) then Exit;
{  b := cbPlay.Checked;
  cbPlay.Checked := false;}
  InterruptPlayback := true;
{  cbLODEnabled.Checked := false;
  seLODSurfaceNr.MinValue := -1;
  seLODSurfaceNr.MaxValue := -1;
  seLODSurfaceNr.Value := -1;
  cbAnimName.Clear;}
  ModelIsScaled := false;
  try
    ClearMDMMDXInfo;
  //  ClearMapShaders;
    // MDX laden
    dlgPK3.MapPK3 := '';
    MDXOpenDialog.FileName := '';
    if not MDXOpenDialog.Execute then Exit;
    if not MDX.LoadBonesFromFile(MDXOpenDialog.FileName) then Exit;

    Screen.Cursor := crHourGlass;
    ShowTabsMDMMDX;
    ShowMenuMDMMDX;
    {Form1.}Refresh;
    LoadedFrom := lfFile;
    LoadedType := ltMDMMDX;
  {  ModelDir := ExtractFilePath(MDMOpenDialog.FileName);}
    OpenDialog.FileName := '';
    ShowMDMMDXInfo;
  {  leName.Text := ExtractFilename(MDMOpenDialog.FileName);
    gbModel.Caption := ExtractFilename(MDMOpenDialog.FileName);
    // skin wissen
    actionFileClearSkinExecute(nil);}
    // transformatie/animatie
    SetupAnimation;
    ResetModelTransform;
{    // shaders
    UpdateShaders;}
    StatusBar.SimpleText := MSG_MDX_BONES_LOADED;
  finally
{    cbPlay.Checked := b;}
    InterruptPlayback := false;
{    OGL_MDMMDX_RenderFrame;}
    OGL_RenderFrame;
    Screen.Cursor := crDefault;
  end;
end;


procedure TForm1.actionFileLoadMDMtagsExecute(Sender: TObject);
var s: string;
    i: integer;
    b: boolean;
begin
  StatusBar.SimpleText := '';
  if (LoadedType<>ltMDMMDX) and (LoadedType<>ltMDS) then Exit;
{  b := cbPlay.Checked;
  cbPlay.Checked := false;}
  InterruptPlayback := true;
{  cbLODEnabled.Checked := false;
  seLODSurfaceNr.MinValue := -1;
  seLODSurfaceNr.MaxValue := -1;
  seLODSurfaceNr.Value := -1;
  cbAnimName.Clear;}
  try
    ClearMDMMDXInfo;
  //  ClearMapShaders;
    // MDX laden
    dlgPK3.MapPK3 := '';
    MDMOpenDialog.FileName := '';
    if not MDMOpenDialog.Execute then Exit;
    if not MDM.LoadTagsFromFile(MDMOpenDialog.FileName) then Exit;

    Screen.Cursor := crHourGlass;
    ShowTabsMDMMDX;
    ShowMenuMDMMDX;
    {Form1.}Refresh;
    LoadedFrom := lfFile;
    LoadedType := ltMDMMDX;
  {  ModelDir := ExtractFilePath(MDMOpenDialog.FileName);}
    OpenDialog.FileName := '';
    ShowMDMMDXInfo;
  {  leName.Text := ExtractFilename(MDMOpenDialog.FileName);
    gbModel.Caption := ExtractFilename(MDMOpenDialog.FileName);
    // skin wissen
    actionFileClearSkinExecute(nil);}
    // transformatie/animatie
    SetupAnimation;
//    ResetModelTransform;
    StatusBar.SimpleText := MSG_MDX_TAGS_LOADED;
  finally
{    cbPlay.Checked := b;}
    InterruptPlayback := false;
{    OGL_MDMMDX_RenderFrame;}
    OGL_RenderFrame;
    Screen.Cursor := crDefault;
  end;
end;


procedure TForm1.actionModelMDMMDXRenameBonesExecute(Sender: TObject);
var BCount,b: integer;
begin
  if (LoadedType<>ltMDMMDX) and (LoadedType<>ltMDS) and (LoadedType<>ltMS3D_MDMMDX) then Exit;
  BCount := MDX.Header.Num_Bones;
  if BCount<>53 then Exit;
  if TVBones.Items.Count<>53 then Exit;
  ClearMDMMDXInfo;
  for b:=0 to BCount-1 do
    MDX.Bones[b].Name := MD3.StringToQ3(DEFAULT_BONE_NAMES[b]);
  ShowMDMMDXBoneInfo;
end;


procedure TForm1.actionModelMDMMDXframesToMD3Execute(Sender: TObject);
const FrameName:array[0..15] of char = 'C MDMMDX Export'#0'';
var Result: integer;
    f,F0,F1, FCount,
    t, TCount,
    s, SCount,
    vi, VCount,
    tr, TrCount,
    tc: cardinal;
    N: word;
    strMsg: string;
    b, DoTagAsPivot: boolean;
    V: TVector;
    Vdiff: array of TVector;
begin
{  b := cbPlay.Checked;
  cbPlay.Checked := false;}
  InterruptPlayback := true;
  StatusBar.SimpleText := '';
  try
    F0 := tbStartFrame.Position;
    F1 := tbEndFrame.Position;
    FCount := F1-F0+1;
    if F1<F0 then Exit;
    strMsg := 'Frames:'+IntToStr(F0)+' to '+IntToStr(F1);
    Result := Application.MessageBox(PChar('Are You sure You want to export the selected frames-range to MD3?.. '+strMsg),
                                     PChar('Confirmation'),
                                     MB_YESNOCANCEL);
    if (Result=IDNO) or (Result=IDCANCEL) then Exit;

    // pivot-point als origin gebruiken
    SetLength(Vdiff, 0);
{    DoTagAsPivot := (cbPivotAsOrigin.Checked and (cbTagPivots.Items.Count>1) and (cbTagPivots.ItemIndex<cbTagPivots.Items.Count-1));}
    DoTagAsPivot := false;
    if DoTagAsPivot then begin
      SetLength(Vdiff, FCount);
      for f:=F0 to F1 do begin
        MDM.CalcModel(MDX,f,0{s}); //TRANSFORMEREN!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        Vdiff[f-F0] := MDM.TagOrigin[cbTagPivots.ItemIndex];
      end;
    end;


    MD3.Clear;
    // Header
    with MD3.Header.Values do begin
      Ident := IDP3;
      Version := 15;
      Name := MD3.StringToQ3(MDM.Header.Name);
      Flags := 0;
      Num_Frames := FCount;
      Num_Tags := MDM.Header.Num_Tags;
      Num_Surfaces := MDM.Header.Num_Surfaces;
      Num_Skins := 0;
    end;

    // Frames
    SetLength(MD3.Header.Frames, FCount);
    for f:=F0 to F1 do begin
      // pivot-point als origin gebruiken
      V := MDX.Frames[f].Min_Bounds;
      if DoTagAsPivot then V := SubVector(V, Vdiff[f-F0]);
      MD3.Header.Frames[f-F0].Min_Bounds   := V {MDX.Frames[f].Min_Bounds};

      V := MDX.Frames[f].Max_Bounds;
      if DoTagAsPivot then V := SubVector(V, Vdiff[f-F0]);
      MD3.Header.Frames[f-F0].Max_Bounds   := V {MDX.Frames[f].Max_Bounds};

      // pivot-point als origin gebruiken
      V := MDX.Frames[f].Local_Origin;
      if DoTagAsPivot then V := SubVector(V, Vdiff[f-F0]);
      MD3.Header.Frames[f-F0].Local_Origin := V {MDX.Frames[f].Local_Origin};

      MD3.Header.Frames[f-F0].Radius       := MDX.Frames[f].Radius;
      for vi:=0 to 15 do MD3.Header.Frames[f-F0].Name[vi] := FrameName[vi];
    end;

    // Tags
    TCount := MDM.Header.Num_Tags;
    SetLength(MD3.Header.Tags, TCount * FCount);
    for f:=F0 to F1 do begin
      MDM.CalcModel(MDX,f,0{s}); //TRANSFORMEREN!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      for t:=0 to TCount-1 do begin
        MD3.Header.Tags[(f-F0)*TCount+t].Name := MDM.Tags[t].Name;
        // origin
        // pivot-point als origin gebruiken
        V := MDM.TagOrigin[t];
        if DoTagAsPivot then V := SubVector(V, Vdiff[f-F0]);
        MD3.Header.Tags[(f-F0)*TCount+t].Origin := V {MDM.TagOrigin[t]};
        // axis
        MD3.Header.Tags[(f-F0)*TCount+t].Axis[0] := MDM.TagAxis[t][0];
        MD3.Header.Tags[(f-F0)*TCount+t].Axis[1] := MDM.TagAxis[t][1];
        MD3.Header.Tags[(f-F0)*TCount+t].Axis[2] := MDM.TagAxis[t][2];
{
        // assen corrigeren
        MD3.Header.Tags[(f-F0)*TCount+t].Axis[0] := InverseVector(MD3.Header.Tags[(f-F0)*TCount+t].Axis[0]);
        V := MD3.Header.Tags[(f-F0)*TCount+t].Axis[0];
        MD3.Header.Tags[(f-F0)*TCount+t].Axis[0] := MD3.Header.Tags[(f-F0)*TCount+t].Axis[1];
        MD3.Header.Tags[(f-F0)*TCount+t].Axis[1] := MD3.Header.Tags[(f-F0)*TCount+t].Axis[2];
        MD3.Header.Tags[(f-F0)*TCount+t].Axis[2] := V;
}
      end;
    end;

    // Surfaces
    SCount := MDM.Header.Num_Surfaces;
    SetLength(MD3.Header.Surfaces, SCount);
    for s:=0 to SCount-1 do begin
      VCount := MDM.Surfaces[s].Values.Num_Verts;
      TrCount := MDM.Surfaces[s].Values.Num_Triangles;
      // surface header
      MD3.Header.Surfaces[s].Values.Ident         := IDP3;
      MD3.Header.Surfaces[s].Values.Name          := MDM.Surfaces[s].Values.SurfaceName;
      MD3.Header.Surfaces[s].Values.Flags         := 0;
      MD3.Header.Surfaces[s].Values.Num_Frames    := FCount;
      MD3.Header.Surfaces[s].Values.Num_Shaders   := 1;
      MD3.Header.Surfaces[s].Values.Num_Verts     := VCount;
      MD3.Header.Surfaces[s].Values.Num_Triangles := TrCount;
      // arrays
      SetLength(MD3.Header.Surfaces[s].Shaders, 1);
      SetLength(MD3.Header.Surfaces[s].Triangles, TrCount);
      SetLength(MD3.Header.Surfaces[s].TextureCoords, VCount);
      SetLength(MD3.Header.Surfaces[s].Vertex, VCount * FCount);
      // shader
      MD3.Header.Surfaces[s].Shaders[0].Name := MDM.Surfaces[s].Values.ShaderName;
      // triangles
      for tr:=0 to TrCount-1 do begin
        MD3.Header.Surfaces[s].Triangles[tr].Index1 := MDM.Surfaces[s].Triangles[tr][0];
        MD3.Header.Surfaces[s].Triangles[tr].Index2 := MDM.Surfaces[s].Triangles[tr][1];
        MD3.Header.Surfaces[s].Triangles[tr].Index3 := MDM.Surfaces[s].Triangles[tr][2];
      end;
      // texcoords
      for tc:=0 to VCount-1 do begin
        MD3.Header.Surfaces[s].TextureCoords[tc].S := MDM.Surfaces[s].Vertex[tc].TexCoordU;
        MD3.Header.Surfaces[s].TextureCoords[tc].T := 1.0-MDM.Surfaces[s].Vertex[tc].TexCoordV;
      end;
      // vertex
      for f:=F0 to F1 do begin
        MDM.CalcModel(MDX,f,s); //TRANSFORMEREN!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        for vi:=0 to VCount-1 do begin
          // pivot-point als origin gebruiken
          V := MDM.VertexPos[vi];
          if DoTagAsPivot then V := SubVector(V, Vdiff[f-F0]);
          MD3.Header.Surfaces[s].Vertex[(f-F0)*VCount+vi].X := Round(V.X {MDM.VertexPos[vi].X} * MD3_XYZ_SCALE_1);
          MD3.Header.Surfaces[s].Vertex[(f-F0)*VCount+vi].Y := Round(V.Y {MDM.VertexPos[vi].Y} * MD3_XYZ_SCALE_1);
          MD3.Header.Surfaces[s].Vertex[(f-F0)*VCount+vi].Z := Round(V.Z {MDM.VertexPos[vi].Z} * MD3_XYZ_SCALE_1);
          // normaal
          MD3.EncodeNormal(MDM.VertexNormal[vi], N);
          MD3.Header.Surfaces[s].Vertex[(f-F0)*VCount+vi].Normal := N;
        end;
      end;
    end;
    // Offsets worden in SaveToFile gezet
    SaveAsDialog.DefaultExt := '.MD3';
    SaveAsDialog.Filter := 'Quake 3 model (.MD3)|*.MD3';
    SaveAsDialog.Title := 'Save a model';
    if not SaveAsDialog.Execute then Exit;
    if not MD3.SaveToFile(SaveAsDialog.FileName) then Exit;
    gbModel.Caption := ExtractFilename(SaveAsDialog.FileName);
    StatusBar.SimpleText := strMsg +' exported to file: '+ gbModel.Caption;
  finally
    SetLength(Vdiff, 0);
{    cbPlay.Checked := b;}
    InterruptPlayback := false;
    OGL_RenderFrame;
  end;
end;


procedure TForm1.actionModelMDMMDXCalculateLODExecute(Sender: TObject);
var s: integer;
begin
  case LoadedType of
    ltMDMMDX: CM.LOD(MDM,MDX, uMDM.LOD_FRAMENR);
    ltMDS: CM.LOD(MDM,MDX, uMDS.LOD_FRAMENR);
    ltMS3D_MDMMDX: CM.LOD(MDM,MDX, uMS3D.LOD_FRAMENR);
  else
    Exit;
  end;
  tLODpresence.Caption := 'calculated';
  seLODSurfaceNrChange(nil);
end;


procedure TForm1.actionModelMDMMDXScaleBonesExecute(Sender: TObject);
var b,s,v,w,f,t: integer;
    strScale: string;
    scale: single;
begin
  if (LoadedType<>ltMDMMDX) and (LoadedType<>ltMDS) and (LoadedType<>ltMS3D_MDMMDX) then Exit;
  if not InputQuery('Enter the scaling factor','Scaling Factor', strScale) then Exit;
  if not TryStrToFloat(strScale, scale) then Exit;
  if scale=1.0 then Exit;
(*
  // scale de bones
  for b:=0 to MDX.Header.Num_Bones-1 do
    MDX.Bones[b].ParentDistance := scale * MDX.Bones[b].ParentDistance;
*)
  // scale de vertex-weight-bonespaces
  for s:=0 to MDM.Header.Num_Surfaces-1 do
    for v:=0 to MDM.Surfaces[s].Values.Num_Verts-1 do
      for w:=0 to MDM.Surfaces[s].Vertex[v].Num_BoneWeights-1 do begin
        MDM.Surfaces[s].Vertex[v].Weights[w].Weight := scale * MDM.Surfaces[s].Vertex[v].Weights[w].Weight;
//        ScaleVector(MDM.Surfaces[s].Vertex[v].Weights[w].BoneSpace, scale);
      end;
(*
  // scale de frames
  for f:=0 to MDX.Header.Num_Frames-1 do begin
    Scalevector(MDX.Frames[f].Min_Bounds, scale);
    Scalevector(MDX.Frames[f].Max_Bounds, scale);
    Scalevector(MDX.Frames[f].Local_Origin, scale);
    MDX.Frames[f].Radius := scale * MDX.Frames[f].Radius;
    Scalevector(MDX.Frames[f].ParentOffset, scale);
  end;
  // scale tags
  for t:=0 to MDM.Header.Num_Tags-1 do
    ScaleVector(MDM.Tags[t].Offset, scale);
*)    
  ModelIsScaled := true;

  SetupAnimation;
  ResetModelTransform;
end;


//------------------------------
//--- MDS ----------------------
//------------------------------
procedure TForm1.actionFileLoadMDSExecute(Sender: TObject);
var b: boolean;
begin
  StatusBar.SimpleText := '';
  InterruptPlayback := true;
  cbLODEnabled.Checked := false;
  seLODSurfaceNr.MinValue := -1;
  seLODSurfaceNr.MaxValue := -1;
  seLODSurfaceNr.Value := -1;
  cbAnimName.Clear; 
  ModelIsScaled := false;
  try
    ShowNone;
    // MD3 laden
    dlgPK3.MapPK3 := '';
if not IsDragDropped then begin
    MDSOpenDialog.FileName := '';
    if not MDSOpenDialog.Execute then Exit;
end;
    if not MDS.LoadFromFile(MDSOpenDialog.FileName) then begin
      ShowNone;
      Exit;
    end;
    // copy data naar MDM/MDX
    MDS.ConvertToMDMMDX(MDM,MDX);

    Screen.Cursor := crHourGlass;
    ShowTabsMDMMDX;
    ShowMenuMDMMDX;
    {Form1.}Refresh;
    LoadedFrom := lfFile;
    LoadedType := ltMDS;
    ModelDir := ExtractFilePath(MDSOpenDialog.FileName);
    OpenDialog.FileName := '';
    ShowMDMMDXInfo;
    leName.Text := ExtractFilename(MDSOpenDialog.FileName);
    gbModel.Caption := ExtractFilename(MDSOpenDialog.FileName);
    // skin wissen
    actionFileClearSkinExecute(nil);
    // transformatie/animatie
    SetupAnimation;
    ResetModelTransform;
    // shaders
    UpdateShaders;
    StatusBar.SimpleText := MSG_MDS_LOADED;
    menuFileSave.Hint := 'Save as MDM/MDX';
    actionFileSaveAs.Hint := 'Save as MDM/MDX';
  finally
    InterruptPlayback := false;
    OGL_RenderFrame;
    Screen.Cursor := crDefault;
  end;
end;

(*
//test
procedure SaveData(SurfaceNr:integer; Filename:string);
var Fsave: TFileStream;
    v,t: integer;
    s: string;
begin
  Fsave := TFileStream.Create(Filename, fmCreate);
  try
    MDM.CalcModel(MDX,0,SurfaceNr);
    s := IntToStr(MDM.Surfaces[SurfaceNr].Values.Num_Verts) + chr(13)+chr(10);
    Fsave.WriteBuffer(s[1],Length(s));
    for v:=0 to MDM.Surfaces[SurfaceNr].Values.Num_Verts-1 do begin
      s := '{'+ FloatToStr(MDM.VertexPos[v].X) +','+
                FloatToStr(MDM.VertexPos[v].Y) +','+
                FloatToStr(MDM.VertexPos[v].Z) +'},'+ chr(13)+chr(10);
      Fsave.WriteBuffer(s[1],Length(s));
    end;
    s := IntToStr(MDM.Surfaces[SurfaceNr].Values.Num_Triangles) + chr(13)+chr(10);
    Fsave.WriteBuffer(s[1],Length(s));
    for t:=0 to MDM.Surfaces[SurfaceNr].Values.Num_Triangles-1 do begin
      s := '{'+ IntToStr(MDM.Surfaces[SurfaceNr].Triangles[t][2]) +','+
                IntToStr(MDM.Surfaces[SurfaceNr].Triangles[t][1]) +','+
                IntToStr(MDM.Surfaces[SurfaceNr].Triangles[t][0]) +'},'+ chr(13)+chr(10);
      Fsave.WriteBuffer(s[1],Length(s));
    end;
  finally
    Fsave.Free;
  end;
end;
*)



procedure TForm1.actionModelSkinpermanentExecute(Sender: TObject);
var r: integer;
    s: integer;
    str: string;
begin
  // is er een skin-file in gebruik??
  if Length(SkinShaders)=0 then Exit;
  r := Application.MessageBox(PChar('Copy the shaders/textures from the currently loaded skin-file?..'),
                              PChar('Confirmation'),
                              MB_YESNOCANCEL);
  if (r=IDYES) then begin
    case LoadedType of
      ltMD3,ltMap,ltASE,ltMS3D_MD3: begin
        // kopiëer de shaders/textures uit de skin-file..
        for s:=0 to MD3.Header.Values.Num_Surfaces-1 do
          if Length(MD3.Header.Surfaces[s].Shaders)>0 then begin
            str := SkinShaderForSurface(string(MD3.Header.Surfaces[s].Values.Name));
            if (str='') and (string(MD3.Header.Surfaces[s].Shaders[0].Name)<>'') then Continue;
            MD3.Header.Surfaces[s].Shaders[0].Name := MD3.StringToQ3(str);
          end;
        ShowMD3Info;
      end;
      ltMDMMDX,ltMDS,ltMS3D_MDMMDX: begin
        // kopiëer de shaders/textures uit de skin-file..
        for s:=0 to MDM.Header.Num_Surfaces-1 do begin
          str := SkinShaderForSurface(string(MDM.Surfaces[s].Values.SurfaceName));
          if (str='') and (string(MDM.Surfaces[s].Values.ShaderName)<>'') then Continue;
          MDM.Surfaces[s].Values.ShaderName := MD3.StringToQ3(str);
        end;
        ShowMDMMDXInfo;
      end;
    end;
  end;
end;

procedure TForm1.actionFileLoadMDXframesExecute(Sender: TObject);
var s: string;
    i: integer;
    b: boolean;
begin
  StatusBar.SimpleText := '';
  if (LoadedType<>ltMDMMDX) and (LoadedType<>ltMDS) and (LoadedType<>ltMS3D_MDMMDX) then Exit;
{  b := cbPlay.Checked;
  cbPlay.Checked := false;}
  InterruptPlayback := true;
  cbLODEnabled.Checked := false;
  seLODSurfaceNr.MinValue := -1;
  seLODSurfaceNr.MaxValue := -1;
  seLODSurfaceNr.Value := -1;
  cbAnimName.Clear; 
  try
    ClearMDMMDXInfo;
  //  ClearMapShaders;
    // MDX laden
    dlgPK3.MapPK3 := '';
    MDXOpenDialog.FileName := '';
    if not MDXOpenDialog.Execute then Exit;
    if not MDX.LoadFramesFromFile(MDXOpenDialog.FileName) then Exit;

    Screen.Cursor := crHourGlass;
    ShowTabsMDMMDX;
    ShowMenuMDMMDX;
    {Form1.}Refresh;
    LoadedFrom := lfFile;
    LoadedType := ltMDMMDX;
  {  ModelDir := ExtractFilePath(MDMOpenDialog.FileName);}
    OpenDialog.FileName := '';
    ShowMDMMDXInfo;
  {  leName.Text := ExtractFilename(MDMOpenDialog.FileName);
    gbModel.Caption := ExtractFilename(MDMOpenDialog.FileName);
    // skin wissen
    actionFileClearSkinExecute(nil);}
    // transformatie/animatie
    SetupAnimation;
//    ResetModelTransform;
    StatusBar.SimpleText := MSG_MDX_FRAMES_LOADED;
  finally
{    cbPlay.Checked := b;}
    InterruptPlayback := false;
{    OGL_MDMMDX_RenderFrame;}
    OGL_RenderFrame;
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.actionFileLoadMS3DExecute(Sender: TObject);
var b: boolean;
    msg: string;
begin
  StatusBar.SimpleText := '';
  InterruptPlayback := true;
  cbLODEnabled.Checked := false;
  seLODSurfaceNr.MinValue := -1;
  seLODSurfaceNr.MaxValue := -1;
  seLODSurfaceNr.Value := -1;
  cbAnimName.Clear;
  ModelIsScaled := false;
  LoadedFrom := lfFile;
  LoadedType := ltNone;
  try
    ShowNone;
    // MS3D laden
    dlgPK3.MapPK3 := '';
if not IsDragDropped then begin
    MS3DOpenDialog.FileName := '';
    if not MS3DOpenDialog.Execute then Exit;
    if not MS3D.LoadFromFile(MS3DOpenDialog.FileName) then begin
      ShowNone;
      Exit;
    end;
end;
    {Form1.}Refresh;
    Screen.Cursor := crHourGlass;
    StatusBar.SimpleText := 'Converting..';
    if MS3D.ConvertToMD3(MD3) then begin
      msg := MSG_MS3D_LOADED_MD3;
      menuFileSave.Hint := 'Save as MD3';
      actionFileSaveAs.Hint := 'Save as MD3';
      LoadedFrom := lfFile;
      LoadedType := ltMS3D_MD3; //ltMD3
      ModelDir := ExtractFilePath(MS3DOpenDialog.FileName);
      ShowMD3Info;
      ShowMenuMD3;
      ShowTabsMD3;
{    end else
    if MS3D.ConvertToMDMMDX(MDM,MDX, StatusBar,msg) then begin
      msg := MSG_MS3D_LOADED_MDMMDX;
      menuFileSave.Hint := 'Save as MDM/MDX';
      actionFileSaveAs.Hint := 'Save as MDM/MDX';
      LoadedFrom := lfFile;
      LoadedType := ltMS3D_MDMMDX;
      ModelDir := ExtractFilePath(MS3DOpenDialog.FileName);
      ShowMDMMDXInfo;
      ShowMenuMDMMDX;
      ShowTabsMDMMDX;}
    end else begin
      ShowNone;
      msg := 'The MS3D cannot be converted: '+ msg;
      menuFileSave.Hint := '';
      actionFileSaveAs.Hint := '';
      LoadedFrom := lfNone;
      LoadedType := ltNone;
      ModelDir := '';
      Exit;
    end;
    {Form1.}Refresh;
    leName.Text := MS3DOpenDialog.FileName;
    {gbInsertTags.Enabled := true;
    gbTagManually.Visible := (MD3.Header.Values.Num_Frames=1); //alleen handmatig toevoegen als het een model betreft zonder animatie}
    gbModel.Caption := ExtractFilename(MS3DOpenDialog.FileName);
    // skin wissen
    actionFileClearSkinExecute(nil);
    // animatie
    SetupAnimation;
    ResetModelTransform;
    // shaders
    UpdateShaders;
  finally
    StatusBar.SimpleText := msg;
    InterruptPlayback := false;
    OGL_RenderFrame;
    Screen.Cursor := crDefault;
  end;
end;


procedure TForm1.LoadHeadModel;
var s: string;
begin
  if GameDir='' then Exit;
  if TmpDir='' then Exit;
  s := 'models\players\hud\head.md3';
{
  // MD3 laden uit de pak0.pk3
  Zip.BaseDir := TmpDir;
  Zip.FileName := GameDir +'etmain\pak0.pk3';
  Zip.OpenArchive(fmOpenRead);
  Zip.ExtractFiles(s);
  Zip.CloseArchive;

  if not HeadModel.LoadFromFile(TmpDir+s) then Exit;
}
(*
//    first   length    fps   looping
//     /    ___/        /       /
//    /    /     ______/       /
//   /    /     /     ________/
//  /    /     /     /
// /   	/     /     /
///    /   	 /   	 /
//   	/   	/   	/

148	 40	   8	   40 // HD_IDLE1	(small eye movements, played all the time)
63	 5	   10	   0  // HD_IDLE2  (big blink)
68	 13	   10	   0  // HD_IDLE3	(look to his left)
5	   46	   10	   41 // HD_IDLE4	(large head movements)
80	 27	   10	   0  // HD_IDLE5  (look up)
107	 25	   10	   0  // HD_IDLE6  (look left and right with little head movements)
131	 18	   5	   0  // HD_IDLE7	(look right)
178	 2	   10	   0  // HD_IDLE8  (blink)
203	 50    10	   50 // HD_DAMAGED_IDLE1  (head idle in pain, played all the time)
253	 75    10	   0  // HD_DAMAGED_IDLE2	(not quite dead)
238	 37    10	   0  // HD_DAMAGED_IDLE3  (no hope left)
68	 13    10	   0  // HD_LEFT
131	 18    10	   0  // HD_RIGHT
51	 9     30	   2  // HD_ATTACK
59	 6     20	   0  // HD_ATTACK_END
191	 7     15	   0  // HD_PAIN 1
384	 10    15	   0  // HD_PAIN 2
364	 20    15	   0  // SMILE (looks shit)
*)
end;


procedure TForm1.actionFileImportMapAsMD3Execute(Sender: TObject);
var b: boolean;
begin
  StatusBar.SimpleText := '';
  InterruptPlayback := true;
  cbLODEnabled.Checked := false;
  seLODSurfaceNr.MinValue := -1;
  seLODSurfaceNr.MaxValue := -1;
  seLODSurfaceNr.Value := -1;
  cbAnimName.Clear;
  ModelIsScaled := false;
  LoadedFrom := lfFile;
  LoadedType := ltNone;
  try
    ShowNone;
    // MD3 laden
    dlgPK3.MapPK3 := '';
    dlgPK3.PathDir := '';
if not IsDragDropped then begin
    MapOpenDialog.FileName := '';
    if not MapOpenDialog.Execute then Exit;
end;
//    if not LevelMAP.LoadMAP(MapOpenDialog.FileName) then Exit;
//    if not LevelMAP.ConvertToMD3(MD3) then Exit;
    Screen.Cursor := crHourGlass;
    LoadedFrom := lfFile;
    LoadedType := ltMap; //ltMD3
    ModelDir := ExtractFilePath(MapOpenDialog.FileName);
    if not LevelMAP.LoadMAP(MapOpenDialog.FileName, StatusBar) then begin
      ShowNone;
      Exit;
    end;
    if not LevelMAP.ConvertToMD3(MD3) then begin
      ShowNone;
      Exit;
    end;
    {Form1.}Refresh;
    ShowTabsMD3;
    ShowMenuMD3;
    ShowMD3Info;
    leName.Text := MapOpenDialog.FileName;
    {gbInsertTags.Enabled := true;
    gbTagManually.Visible := (MD3.Header.Values.Num_Frames=1); //alleen handmatig toevoegen als het een model betreft zonder animatie}
    gbModel.Caption := ExtractFilename(MapOpenDialog.FileName);
    // skin wissen
    actionFileClearSkinExecute(nil);
    // animatie
    SetupAnimation;
    ResetModelTransform;
    // shaders
    UpdateShaders;
    StatusBar.SimpleText := MSG_MAP_LOADED;
    menuFileSave.Hint := 'Save as MD3';
    actionFileSaveAs.Hint := 'Save as MD3';
  finally
    InterruptPlayback := false;
    OGL_RenderFrame;
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.actionFileLoadAnyFromFileExecute(Sender: TObject);
var b: boolean;
    s, Extension, msg: string;
    i: integer;
begin
  StatusBar.SimpleText := '';
  InterruptPlayback := true;
  cbLODEnabled.Checked := false;
  seLODSurfaceNr.MinValue := -1;
  seLODSurfaceNr.MaxValue := -1;
  seLODSurfaceNr.Value := -1;
  cbAnimName.Clear;
  ModelIsScaled := false;
  try
    // MD3 laden
    dlgPK3.MapPK3 := '';
    OpenDialogAnyFromFile.FileName := '';
    OpenDialogAnyFromFile.FilterIndex := 1;
    if not OpenDialogAnyFromFile.Execute then Exit;
    Screen.Cursor := crHourGlass;
    // skin wissen
    actionFileClearSkinExecute(nil);
    //
    {Form1.}Refresh;
{    LoadedFrom := lfNone;
    LoadedType := ltNone;}
    if OpenDialogAnyFromFile.FilterIndex = 1 then begin
      Extension := UpperCase(ExtractFileExt(OpenDialogAnyFromFile.FileName));
      if Extension='.MD3' then OpenDialogAnyFromFile.FilterIndex := 2;
      if Extension='.MDM' then OpenDialogAnyFromFile.FilterIndex := 3;
      if Extension='.MDX' then OpenDialogAnyFromFile.FilterIndex := 4;
      if Extension='.MDS' then OpenDialogAnyFromFile.FilterIndex := 8;
      if Extension='.MAP' then OpenDialogAnyFromFile.FilterIndex := 9;
      if Extension='.MS3D' then OpenDialogAnyFromFile.FilterIndex := 10;
      if Extension='.ASE' then OpenDialogAnyFromFile.FilterIndex := 11;
    end;
    case OpenDialogAnyFromFile.FilterIndex of
      2: begin // MD3
           OpenDialog.FileName := OpenDialogAnyFromFile.FileName; //:S
           ClearMapShaders;
           if not MD3.LoadFromFile(OpenDialogAnyFromFile.FileName) then Exit;
           LoadedFrom := lfFile;
           LoadedType := ltMD3;
           ShowTabsMD3;
           ShowMenuMD3;
           ShowMD3Info;
           msg := MSG_MD3_LOADED;
         end;
      3: begin // MDM
           MDMOpenDialog.FileName := OpenDialogAnyFromFile.FileName; //:S
           ClearMapShaders;
           if not MDM.LoadFromFile(OpenDialogAnyFromFile.FileName) then Exit;
           LoadedFrom := lfFile;
           LoadedType := ltMDMMDX;
           ShowTabsMDMMDX;
           ShowMenuMDMMDX;
           ShowMDMMDXInfo;
           msg := MSG_MDM_LOADED;
         end;
      4: begin // MDX
           if (LoadedType<>ltMDMMDX) and (LoadedType<>ltMDS) then Exit; // al eerder een MDM geladen
           MDMOpenDialog.FileName := OpenDialogAnyFromFile.FileName; //:S
           if not MDX.LoadFromFile(OpenDialogAnyFromFile.FileName) then Exit;
           LoadedFrom := lfFile;
           LoadedType := ltMDMMDX;
           ShowTabsMDMMDX;
           ShowMenuMDMMDX;
           ShowMDMMDXInfo;
           msg := MSG_MDX_LOADED;
           // aninc laden
           s := ChangeFileExt(OpenDialogAnyFromFile.FileName,'.aninc');
           cbAnimName.Clear; 
           if Aninc.LoadFromFile(s) then
             for i:=0 to Length(Aninc.Anims)-1 do cbAnimName.Items.Add(Aninc.Anims[i].Name);
         end;
      5: begin // MDX bones
           if (LoadedType<>ltMDMMDX) and (LoadedType<>ltMDS) then Exit; // al eerder een MDM geladen
           if not MDX.LoadBonesFromFile(OpenDialogAnyFromFile.FileName) then Exit;
           LoadedFrom := lfFile;
           LoadedType := ltMDMMDX;
           ShowTabsMDMMDX;
           ShowMenuMDMMDX;
           ShowMDMMDXInfo;
           msg := MSG_MDX_BONES_LOADED;
         end;
      6: begin // MDX frames
           if (LoadedType<>ltMDMMDX) and (LoadedType<>ltMDS) then Exit; // al eerder een MDM geladen
           if not MDX.LoadFramesFromFile(OpenDialogAnyFromFile.FileName) then Exit;
           LoadedFrom := lfFile;
           LoadedType := ltMDMMDX;
           ShowTabsMDMMDX;
           ShowMenuMDMMDX;
           ShowMDMMDXInfo;
           msg := MSG_MDX_FRAMES_LOADED;
         end;
      7: begin // MDX tags
           if (LoadedType<>ltMDMMDX) and (LoadedType<>ltMDS) then Exit; // al eerder een MDM geladen
           if not MDM.LoadTagsFromFile(OpenDialogAnyFromFile.FileName) then Exit;
           LoadedFrom := lfFile;
           LoadedType := ltMDMMDX;
           ShowTabsMDMMDX;
           ShowMenuMDMMDX;
           ShowMDMMDXInfo;
           msg := MSG_MDX_TAGS_LOADED;
         end;
      8: begin // MDS
           MDSOpenDialog.FileName := OpenDialogAnyFromFile.FileName; //:S
           ClearMapShaders;
           if not MDS.LoadFromFile(OpenDialogAnyFromFile.FileName) then Exit;
           MDS.ConvertToMDMMDX(MDM,MDX);
           LoadedFrom := lfFile;
           LoadedType := ltMDS;
           ShowTabsMDMMDX;
           ShowMenuMDMMDX;
           ShowMDMMDXInfo;
           msg := MSG_MDS_LOADED;
         end;
      9: begin // MAP
           MapOpenDialog.FileName := OpenDialogAnyFromFile.FileName; //:S
           ClearMapShaders;
           if not LevelMAP.LoadMAP(OpenDialogAnyFromFile.FileName, StatusBar) then Exit;
           if not LevelMAP.ConvertToMD3(MD3) then Exit;
           LoadedFrom := lfFile;
           LoadedType := ltMap; //ltMD3;
           ShowTabsMD3;
           ShowMenuMD3;
           ShowMD3Info;
           msg := MSG_MAP_LOADED;
         end;
      10: begin // MS3D
           MS3DOpenDialog.FileName := OpenDialogAnyFromFile.FileName; //:S
           ClearMapShaders;
           if not MS3D.LoadFromFile(OpenDialogAnyFromFile.FileName) then Exit;
           if MS3D.ConvertToMD3(MD3) then begin
             LoadedFrom := lfFile;
             LoadedType := ltMS3D_MD3;  //ltMS3D
             ShowTabsMD3;
             ShowMenuMD3;
             ShowMD3Info;
             msg := MSG_MS3D_LOADED_MD3;
{           end else
           if MS3D.ConvertToMDMMDX(MDM,MDX, StatusBar,msg) then begin
             LoadedFrom := lfFile;
             LoadedType := ltMS3D_MDMMDX;  //ltMS3D
             ShowTabsMDMMDX;
             ShowMenuMDMMDX;
             ShowMDMMDXInfo;
             msg := MSG_MS3D_LOADED_MDMMDX;}
           end else begin
             LoadedFrom := lfNone;
             LoadedType := ltNone;
             ShowTabsNone;
             ShowMenuNone;
             //msg := 'MS3D playermodels cannot be converted yet';
           end;
         end;
      11: begin // .ASE
           ASEOpenDialog.FileName := OpenDialogAnyFromFile.FileName; //:S
           ClearMapShaders;
           if not ASE.LoadFromFile(OpenDialogAnyFromFile.FileName, msg) then Exit;
           if not ASE.ConvertToMD3(MD3, msg) then Exit;
           LoadedFrom := lfFile;
           LoadedType := ltASE; //ltMD3
           ShowTabsMD3;
           ShowMenuMD3;
           ShowMD3Info;
           msg := MSG_ASE_LOADED;
         end;
      12: begin // skin
           ClearMapShaders;
           Screen.Cursor := crHourGlass;
           {Form1.}Refresh;
           LoadSkinFile(OpenDialogAnyFromFile.FileName, false); //shaders niet updaten
           Screen.Cursor := crDefault;
           msg := MSG_SKIN_LOADED;
           {LoadedFrom := lfFile;
           LoadedType := ltSkin;}
         end;
      13: begin // tag
           msg := 'not yet supported..';
           Exit;
           LoadedType := ltTag;
         end;
      14: begin // shader
           msg := 'not yet supported..';
           Exit;
           LoadedType := ltShader;
         end;
    end;
    if LoadedType=ltNone then begin
      ModelDir := '';
      leName.Text := '';
      gbModel.Caption := '';
    end else begin
      ModelDir := ExtractFilePath(OpenDialogAnyFromFile.FileName);
      leName.Text := OpenDialogAnyFromFile.FileName;
      gbModel.Caption := ExtractFilename(OpenDialogAnyFromFile.FileName);
    end;
    {gbInsertTags.Enabled := true;
    gbTagManually.Visible := (MD3.Header.Values.Num_Frames=1); //alleen handmatig toevoegen als het een model betreft zonder animatie}
    // animatie
    SetupAnimation;
    ResetModelTransform;
    // shaders
    UpdateShaders;
  finally
    InterruptPlayback := false;
    case OpenDialogAnyFromFile.FilterIndex of
      1,8,9: OGL_RenderFrame;                                    // MD3
      2..7,10: OGL_MDMMDX_RenderFrame;                           // MDM MDX MDS
      12:   if (LoadedType=ltMD3) or (LoadedType=ltMap) or (LoadedType=ltASE) or (LoadedType=ltMS3D_MD3) then
              OGL_RenderFrame
            else if (LoadedType=ltMDMMDX) or (LoadedType=ltMDS) or (LoadedType=ltMS3D_MDMMDX) then
              OGL_MDMMDX_RenderFrame;
    end;
    Screen.Cursor := crDefault;
    StatusBar.SimpleText := msg;
  end;
end;



procedure TForm1.menuModelTagsInvertXClick(Sender: TObject);
begin
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if MD3.Header.Values.Num_Frames < 1 then Exit; // altijd 1 frame laten bestaan
  MD3.TagsInvertX;
end;

procedure TForm1.menuModelTagsInvertYClick(Sender: TObject);
begin
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if MD3.Header.Values.Num_Frames < 1 then Exit; // altijd 1 frame laten bestaan
  MD3.TagsInvertY;
end;

procedure TForm1.menuModelTagsInvertZClick(Sender: TObject);
begin
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if MD3.Header.Values.Num_Frames < 1 then Exit; // altijd 1 frame laten bestaan
  MD3.TagsInvertZ;
end;

procedure TForm1.menuModelTagsSwapXYClick(Sender: TObject);
begin
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if MD3.Header.Values.Num_Frames < 1 then Exit; // altijd 1 frame laten bestaan
  MD3.TagsSwapXY;
end;

procedure TForm1.menuModelTagsSwapXZClick(Sender: TObject);
begin
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if MD3.Header.Values.Num_Frames < 1 then Exit; // altijd 1 frame laten bestaan
  MD3.TagsSwapXZ;
end;

procedure TForm1.menuModelTagsSwapYZClick(Sender: TObject);
begin
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if MD3.Header.Values.Num_Frames < 1 then Exit; // altijd 1 frame laten bestaan
  MD3.TagsSwapYZ;
end;

procedure TForm1.actionFileSaveMDXExecute(Sender: TObject);
begin
  //
end;

procedure TForm1.actionFileSaveMDMExecute(Sender: TObject);
begin
  //
end;


procedure TForm1.actionModelMD3FlipXExecute(Sender: TObject);
begin
  Statusbar.SimpleText := '';
  // een MD3 X-coördinaten omdraaien
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if MD3.Header.Values.Num_Frames < 1 then Exit;
  if MD3.Header.Values.Num_Surfaces < 1 then Exit;
  MD3.FlipXcoords;
  ShowMD3Info;
  Statusbar.SimpleText := 'X-coordinates are flipped..';
end;

procedure TForm1.actionModelMD3FlipYExecute(Sender: TObject);
begin
  Statusbar.SimpleText := '';
  // een MD3 Z-coördinaten omdraaien
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if MD3.Header.Values.Num_Frames < 1 then Exit;
  if MD3.Header.Values.Num_Surfaces < 1 then Exit;
  MD3.FlipYcoords;
  ShowMD3Info;
  Statusbar.SimpleText := 'Y-coordinates are mirrored..';
end;

procedure TForm1.actionModelMD3FlipZExecute(Sender: TObject);
begin
  Statusbar.SimpleText := '';
  // een MD3 Z-coördinaten omdraaien
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if MD3.Header.Values.Num_Frames < 1 then Exit;
  if MD3.Header.Values.Num_Surfaces < 1 then Exit;
  MD3.FlipZcoords;
  ShowMD3Info;
  Statusbar.SimpleText := 'Z-coordinates are mirrored..';
end;

procedure TForm1.actionModelMD3FlipNormalsExecute(Sender: TObject);
begin
  Statusbar.SimpleText := '';
  // een MD3 Z-coördinaten omdraaien
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if MD3.Header.Values.Num_Frames < 1 then Exit;
  if MD3.Header.Values.Num_Surfaces < 1 then Exit;
  MD3.FlipNormals;
  ShowMD3Info;
  Statusbar.SimpleText := 'Normals are mirrored..';
end;

procedure TForm1.actionModelMD3FlipWindingExecute(Sender: TObject);
begin
  Statusbar.SimpleText := '';
  // een MD3 triangle windings omdraaien
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if MD3.Header.Values.Num_Frames < 1 then Exit;
  if MD3.Header.Values.Num_Surfaces < 1 then Exit;
  MD3.FlipWinding;
  ShowMD3Info;
  Statusbar.SimpleText := 'Triangle windings are reversed..';
end;

procedure TForm1.actionModelMD3FixCracksGapsExecute(Sender: TObject);
var strDistance: string;
    Distance: single;
begin
  Statusbar.SimpleText := '';
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if MD3.Header.Values.Num_Frames < 1 then Exit;
  if MD3.Header.Values.Num_Surfaces < 1 then Exit;
  if cbNamesSurfaces.ItemIndex < 0 then Exit;
  // user input
  strDistance := '0.15';
  if not InputQuery('Enter max. distance','The maximal distance over which vertices will be weld together', strDistance) then Exit;
  if not TryStrToFloat(strDistance, Distance) then Exit;
  Distance := Abs(Distance);
  // vertex weld
  MD3.WeldVertices(cbNamesSurfaces.ItemIndex, Distance);
  ShowMD3Info;
  Statusbar.SimpleText := 'Surface["'+ cbNamesSurfaces.Items[cbNamesSurfaces.ItemIndex] +'"] vertices "welded"..';
end;

procedure TForm1.actionModelMD3SmoothSurfaceExecute(Sender: TObject);
var s: string;
begin
  Statusbar.SimpleText := '';
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if MD3.Header.Values.Num_Frames < 1 then Exit;
  if MD3.Header.Values.Num_Surfaces < 1 then Exit;
  if cbNamesSurfaces.ItemIndex < 0 then Exit;
  s := cbNamesSurfaces.Items[cbNamesSurfaces.ItemIndex];
  // smoothen surface
  MD3.SmoothSurface(cbNamesSurfaces.ItemIndex);
  ShowMD3Info;
  Statusbar.SimpleText := 'Surface["'+ s +'"] smoothed..';
end;

procedure TForm1.actionModelMDMMDXSmoothSurfaceExecute(Sender: TObject);
var s: string;
begin
  Statusbar.SimpleText := '';
  if (LoadedType<>ltMDMMDX) and (LoadedType<>ltMDS) and (LoadedType<>ltMS3D_MDMMDX) then Exit;
  if MDX.Header.Num_Frames < 1 then Exit;
  if MDM.Header.Num_Surfaces < 1 then Exit;
  if cbNamesSurfaces.ItemIndex < 0 then Exit;
  s := cbNamesSurfaces.Items[cbNamesSurfaces.ItemIndex];
  // smoothen surface
  MDM.SmoothSurface(MDX, cbNamesSurfaces.ItemIndex);
  ShowMDMMDXInfo;
  Statusbar.SimpleText := 'Surface["'+ s +'"] smoothed..';
end;

procedure TForm1.actionModelMD3TagAsOriginExecute(Sender: TObject);
var nt,t,f,s,nv,v: integer;
    Offset, Center, Vec: TVector;
    bOriginTag: boolean;
    name: string;
begin
  Statusbar.SimpleText := '';
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if MD3.Header.Values.Num_Tags < 1 then Exit;
  if MD3.Header.Values.Num_Frames < 1 then Exit;
  if (cbTagPivots.ItemIndex=-1) or (cbTagPivots.ItemIndex>Length(MD3.Header.Tags)) then Exit;
  if (cbTagPivots.ItemIndex > MD3.Header.Values.Num_Tags) or
     (Length(MD3.Header.Tags) < MD3.Header.Values.Num_Frames*MD3.Header.Values.Num_Tags) then Exit;

  name := cbTagPivots.Items.Strings[cbTagPivots.ItemIndex];

  // als de tag"origin" is gekozen, dan de Local_Origin gebruiken.
  bOriginTag := (cbTagPivots.ItemIndex = cbTagPivots.Items.Count-1);
  //
  for f:=0 to MD3.Header.Values.Num_Frames-1 do begin
    nt := f * MD3.Header.Values.Num_Tags;
    if bOriginTag then Offset := MD3.Header.Frames[f].Local_Origin
                  else Offset := MD3.Header.Tags[nt+cbTagPivots.ItemIndex].Origin;
    // frames
    MD3.Header.Frames[f].Min_Bounds := SubVector(MD3.Header.Frames[f].Min_Bounds, Offset);
    MD3.Header.Frames[f].Max_Bounds := SubVector(MD3.Header.Frames[f].Max_Bounds, Offset);
    MD3.Header.Frames[f].Local_Origin  := SubVector(MD3.Header.Frames[f].Local_Origin, Offset);
    // tags
    for t:=0 to MD3.Header.Values.Num_Tags-1 do
      MD3.Header.Tags[nt+t].Origin := SubVector(MD3.Header.Tags[nt+t].Origin, Offset);
    // surface vertices
    for s:=0 to MD3.Header.Values.Num_Surfaces-1 do begin
      nv := f * MD3.Header.Surfaces[s].Values.Num_Verts;
      for v:=0 to MD3.Header.Surfaces[s].Values.Num_Verts-1 do begin
        with MD3.Header.Surfaces[s].Vertex[nv+v] do Vec := Vector(X*MD3_XYZ_SCALE, Y*MD3_XYZ_SCALE, Z*MD3_XYZ_SCALE);
        Vec := SubVector(Vec, Offset);
        MD3.Header.Surfaces[s].Vertex[nv+v].X := Round(Vec.X * MD3_XYZ_SCALE_1);
        MD3.Header.Surfaces[s].Vertex[nv+v].Y := Round(Vec.Y * MD3_XYZ_SCALE_1);
        MD3.Header.Surfaces[s].Vertex[nv+v].Z := Round(Vec.Z * MD3_XYZ_SCALE_1);
      end;
    end;
  end;
  //
  ShowMD3Info;
  Statusbar.SimpleText := 'The position of the tag["'+ name +'"] is now the new origin..';
end;


procedure TForm1.actionModelMD3RotateXExecute(Sender: TObject);
var strDegrees: string;
    Degrees: single;
begin
  Statusbar.SimpleText := '';
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  // aantal graden vragen aan user
  if not InputQuery('Enter the degrees of rotation','X Degrees', strDegrees) then Exit;
  if not TryStrToFloat(strDegrees, Degrees) then Exit;
  MD3.RotateModelX(Degrees);
  ShowMD3Info;
  Statusbar.SimpleText := 'The model is rotated around the X-axis..';
end;

procedure TForm1.actionModelMD3RotateYExecute(Sender: TObject);
var strDegrees: string;
    Degrees: single;
begin
  Statusbar.SimpleText := '';
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  // aantal graden vragen aan user
  if not InputQuery('Enter the degrees of rotation','Y Degrees', strDegrees) then Exit;
  if not TryStrToFloat(strDegrees, Degrees) then Exit;
  MD3.RotateModelY(Degrees);
  ShowMD3Info;
  Statusbar.SimpleText := 'The model is rotated around the Y-axis..';
end;

procedure TForm1.actionModelMD3RotateZExecute(Sender: TObject);
var strDegrees: string;
    Degrees: single;
begin
  Statusbar.SimpleText := '';
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  // aantal graden vragen aan user
  if not InputQuery('Enter the degrees of rotation','Z Degrees', strDegrees) then Exit;
  if not TryStrToFloat(strDegrees, Degrees) then Exit;
  MD3.RotateModelZ(Degrees);
  ShowMD3Info;
  Statusbar.SimpleText := 'The model is rotated around the Z-axis..';
end;

procedure TForm1.bSaveTagsClick(Sender: TObject);
begin
  Statusbar.SimpleText := '';
  InterruptPlayback := true;
  try
    case LoadedType of
      ltMD3,ltMap,ltASE,ltMS3D_MD3: begin
        // MD3 opslaan
        SaveAsDialog.DefaultExt := '.tag';
        SaveAsDialog.Filter := 'Model Tags File (.tag)|*.tag';
        SaveAsDialog.Title := 'Save model-tag(s)';
        if not SaveAsDialog.Execute then Exit;
        MD3.SaveTags(SaveAsDialog.FileName);
        Statusbar.SimpleText := 'Tag(s) saved to file: '+ ExtractFilename(SaveAsDialog.FileName);
      end;
      ltMDMMDX,ltMDS,ltMS3D_MDMMDX: begin
        Statusbar.SimpleText := 'Saving tags for playermodels is not yet possible..';
      end;
    end;
  finally
    InterruptPlayback := false;
  end;
end;

procedure TForm1.actionFileLoadASEExecute(Sender: TObject);
var b: boolean;
    msg: string;
begin
  StatusBar.SimpleText := '';
  InterruptPlayback := true;
  cbLODEnabled.Checked := false;
  seLODSurfaceNr.MinValue := -1;
  seLODSurfaceNr.MaxValue := -1;
  seLODSurfaceNr.Value := -1;
  cbAnimName.Clear;
  ModelIsScaled := false;
  LoadedFrom := lfFile;
  LoadedType := ltNone;
  try
    ShowNone;
    LoadedFrom := lfFile;
    LoadedType := ltASE; //ltMD3
    // MD3 laden
    dlgPK3.MapPK3 := '';
if not IsDragDropped then begin
    ASEOpenDialog.FileName := '';
    if not ASEOpenDialog.Execute then Exit;
end;
    Screen.Cursor := crHourGlass;
    ModelDir := ExtractFilePath(ASEOpenDialog.FileName);
    if not ASE.LoadFromFile(ASEOpenDialog.FileName, msg) then begin
      ShowNone;
      StatusBar.SimpleText := msg;
      Exit;
    end;
    if not ASE.ConvertToMD3(MD3, msg) then begin
      ShowNone;
      StatusBar.SimpleText := msg;
      Exit;
    end;
    {Form1.}Refresh;
    ShowMD3Info;
    ShowMenuMD3;
    ShowTabsMD3;
    leName.Text := ASEOpenDialog.FileName;
    {gbInsertTags.Enabled := true;
    gbTagManually.Visible := (MD3.Header.Values.Num_Frames=1); //alleen handmatig toevoegen als het een model betreft zonder animatie}
    gbModel.Caption := ExtractFilename(ASEOpenDialog.FileName);
    // skin wissen
    actionFileClearSkinExecute(nil);
    // animatie
    SetupAnimation;
    ResetModelTransform;
    // shaders
    UpdateShaders;
    StatusBar.SimpleText := MSG_ASE_LOADED;
    menuFileSave.Hint := 'Save as MD3';
    actionFileSaveAs.Hint := 'Save as MD3';
  finally
    InterruptPlayback := false;
    OGL_RenderFrame;
    Screen.Cursor := crDefault;
  end;
end;


//--- PAK-files ----------------------------------------------------------------
function TForm1.AddPAK(Filename: string): integer;
var Len,gp: integer;
    ShortName,s: string;
    Zip: TZipForge;
    ai: TZFArchiveItem;
    hasTextures, hasShaders, hasModels: boolean;
begin
  Result := -1;
  StatusBar.SimpleText := '';
  ShortName := ExtractFilename(Filename);

  // sanity checks
  if not FileExists(Filename) then begin
    StatusBar.SimpleText := 'PAK-file does not exist:'+ Filename;
    Exit;
  end;
  //
  if FileInUse(Filename) then begin
    StatusBar.SimpleText := 'PAK-file is in use:'+ Filename;
    Exit;
  end;
  //
  Len := Length(PAKsList);
  if Len<>cbPAKsList.Items.Count then Exit;
  for gp:=0 to Len-1 do
    if Filename = PAKsList[gp].FullPath then begin
      StatusBar.SimpleText := 'PAK-file '+ ShortName +' already in list';
      Exit;
    end;

  // check of er wel wat bruikbaars in de aangewezen PAK zit,.. anders niet toevoegen.
  StatusBar.SimpleText := 'Checking for relevant files in PAK-file: '+ ShortName;
  hasTextures := false;
  hasShaders := false;
  hasModels := false;
  Zip := TZipForge.Create(nil);
  try
    // textures..
    Zip.FileName := Filename;
    Zip.OpenArchive(fmOpenRead);
    Zip.BaseDir := TmpDir;
    try
      s := '*.tga';
      hasTextures := Zip.FindFirst(s,ai,faAnyFile);
      if not hasTextures then begin
        s := '*.jpg';
        hasTextures := Zip.FindFirst(s,ai,faAnyFile);
      end;
      if not hasTextures then begin
        s := '*.bmp';
        hasTextures := Zip.FindFirst(s,ai,faAnyFile);
      end;
    finally
      Zip.CloseArchive;
    end;

    // shaders
{    if not hasTextures then begin}
      Zip.FileName := Filename;
      Zip.OpenArchive(fmOpenRead);
      Zip.BaseDir := TmpDir;
      try
        s := '*.shader';
        hasShaders := Zip.FindFirst(s,ai,faAnyFile);
      finally
        Zip.CloseArchive;
      end;
{    end;}

    // models
{    if not (hasTextures or hasShaders) then begin}
      Zip.FileName := Filename;
      Zip.OpenArchive(fmOpenRead);
      Zip.BaseDir := TmpDir;
      try
        s := '*.md3';
        hasModels := Zip.FindFirst(s,ai,faAnyFile);
        if not hasModels then begin
          s := '*.mdm';
          hasModels := Zip.FindFirst(s,ai,faAnyFile);
        end;
        if not hasModels then begin
          s := '*.mdx';
          hasModels := Zip.FindFirst(s,ai,faAnyFile);
        end;
        if not hasModels then begin
          s := '*.mds';
          hasModels := Zip.FindFirst(s,ai,faAnyFile);
        end;
        if not hasModels then begin
          s := '*.ase';
          hasModels := Zip.FindFirst(s,ai,faAnyFile);
        end;
      finally
        Zip.CloseArchive;
      end;
{    end;}

  finally
    Zip.Free;
  end;

  // alleen bruikbare PAKs toevoegen..
  if hasTextures or hasShaders or hasModels then begin
    // een nieuwe PAK file toevoegen als GAME-PAK
    SetLength(PAKsList, Len+1);
    PAKsList[Len] := TStrObject.Create;
    PAKsList[Len].FullPath := Filename;
    PAKsList[Len].ShortName := ShortName;
    PAKsList[Len].TmpDir := TmpDir +'gp'+ IntToStr(Len) +'\';
    PAKsList[Len].hasTextures := hasTextures;
    PAKsList[Len].hasShaders := hasShaders;
    PAKsList[Len].hasModels := hasModels;
    Result := cbPAKsList.Items.AddObject(ShortName, PAKsList[Len]);
    cbPAKsList.ItemIndex := 0 {Len};
    StatusBar.SimpleText := 'PAK-file added to the list: '+ ShortName;
  end else
    StatusBar.SimpleText := 'PAK-file does not contain any relevant files: '+ ShortName;
end;

function TForm1.DeletePAK(Index: integer): boolean;
var Len,gp: integer;
begin
  Result := false;
  Len := Length(PAKsList);
  if Len<>cbPAKsList.Items.Count then Exit;
  if (Index<0) or (Index>=Len) then Exit;
  //
  cbPAKsList.Items.Delete(Index);
  PAKsList[Index].Free;
  PAKsList[Index] := nil;
  for gp:=Index to Len-1-1 do PAKsList[Index] := PAKsList[Index+1];
  SetLength(PAKsList, Len-1);
  Result := true;
end;

procedure TForm1.cbPAKsListSelect(Sender: TObject);
begin
  if cbPAKsList.ItemIndex = -1 then
    cbPAKsList.Hint := ''
  else
    cbPAKsList.Hint := PAKsList[cbPAKsList.ItemIndex].FullPath;
end;

procedure TForm1.DeletePAKsList;
var p: integer;
begin
  // alle referenties naar GAME-PAKs verwijderen..
  for p:=0 to Length(PAKsList)-1 do
    if PAKsList[p]<>nil then PAKsList[p].Free;
  SetLength(PAKsList, 0);
end;

procedure TForm1.bAddGamePAKClick(Sender: TObject);
begin
  StatusBar.SimpleText := '';
  if not PK3OpenDialog.Execute then Exit;
  if AddPAK(PK3OpenDialog.FileName)=-1 then Exit;
end;

procedure TForm1.bDelGamePAKClick(Sender: TObject);
var s: string;
begin
  StatusBar.SimpleText := '';
  if cbPAKsList.ItemIndex=-1 then Exit;
  s := PAKsList[cbPAKsList.ItemIndex].ShortName;
  if DeletePAK(cbPAKsList.ItemIndex) then
    StatusBar.SimpleText := 'PAK-file deleted from the list: '+ s;
  cbPAKsList.ItemIndex := 0;  
end;
//------------------------------------------------------------------------------


procedure TForm1.actionModelCalculateNormalsExecute(Sender: TObject);
var s: integer;
begin
  StatusBar.SimpleText := '';
  case LoadedType of
    ltMDMMDX,ltMDS,ltMS3D_MDMMDX:
      for s:=0 to MDM.Header.Num_Surfaces-1 do MDM.CalcSurfaceNormals(MDX, Current_Frame, s);
    ltMD3,ltMAP,ltASE,ltMS3D_MD3:
      for s:=0 to MD3.Header.Values.Num_Surfaces-1 do MD3.CalculateSurfaceNormals(s);
  end;
  StatusBar.SimpleText := 'Normals recalculated';
end;

procedure TForm1.menuModelSmoothSurfaceClick(Sender: TObject);
begin
  case LoadedType of
    ltMD3,ltMAP,ltASE,ltMS3D_MD3: actionModelMD3SmoothSurfaceExecute(nil);
    ltMDMMDX,ltMDS,ltMS3D_MDMMDX: actionModelMDMMDXSmoothSurfaceExecute(nil);
  end;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
//  OGL_RenderFrame;
end;

procedure TForm1.actionModelMD3SwapUVSTExecute(Sender: TObject);
var s: integer;
begin
  case LoadedType of
    ltMD3,ltMAP,ltASE,ltMS3D_MD3:
      for s:=0 to MD3.Header.Values.Num_Surfaces-1 do MD3.TexCoords_SwapST_UV(s);
  end;
end;

procedure TForm1.actionModelMD3RemoveSurfaceExecute(Sender: TObject);
var s: string;
begin
  StatusBar.SimpleText := '';
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if MD3.Header.Values.Num_Frames < 1 then Exit;
  if MD3.Header.Values.Num_Surfaces < 1 then Exit;
  if cbNamesSurfaces.ItemIndex < 0 then Exit;
  s := cbNamesSurfaces.Items[cbNamesSurfaces.ItemIndex];
  InterruptPlayback := true;
  case LoadedType of
    ltMD3,ltMAP,ltASE,ltMS3D_MD3: MD3.RemoveSurface(cbNamesSurfaces.ItemIndex);
  end;
  ShowMD3Info;
  InterruptPlayback := false;
  StatusBar.SimpleText := 'Surface "'+ s +'" removed..';
end;

procedure TForm1.actionModelMD3SurfacesCompactExecute(Sender: TObject);
var s,s2: integer;
begin
  StatusBar.SimpleText := '';
  if (LoadedType<>ltMD3) and (LoadedType<>ltMap) and (LoadedType<>ltASE) and (LoadedType<>ltMS3D_MD3) then Exit;
  if MD3.Header.Values.Num_Frames < 1 then Exit;
  if MD3.Header.Values.Num_Surfaces < 1 then Exit;
  s := MD3.Header.Values.Num_Surfaces;
  InterruptPlayback := true;
  MD3.CompactSurfaces;
  ShowMD3Info;
  InterruptPlayback := false;
  s2 := MD3.Header.Values.Num_Surfaces;
  StatusBar.SimpleText := 'Surfaces compacted: from '+ IntToStr(s) +' to '+ IntToStr(s2);
end;

end.

