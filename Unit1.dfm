object Form1: TForm1
  Left = 279
  Top = 181
  Width = 808
  Height = 661
  Caption = 'Q3 Model Tool v1.6.2'
  Color = clBtnFace
  Constraints.MinHeight = 612
  Constraints.MinWidth = 808
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010002002020100000000000E80200002600000010101000000000002801
    00000E0300002800000020000000400000000100040000000000800200000000
    0000000000000000000000000000000000000000800000800000008080008000
    0000800080008080000080808000C0C0C0000000FF0000FF000000FFFF00FF00
    0000FF00FF00FFFF0000FFFFFF00000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000088877778888000000000000000000877666666666667780000000000
    0087666666666777766666678000000007666666778800000000887667000008
    6666667800000000000000008778008666666780000000000000000000880066
    6666600000000000000000000000076666668000000000000000000000000666
    6668000000000000000000000000866666680000000000000000000000008666
    6668000000000000000000000000076666670000000000000000000000000866
    6666800000000000000000000000007666666000000000000000000000000007
    6666678000000000000000000088000076666678800000000000000087700000
    0876666677788800000888767800000000087666666666676666667800000000
    0000088776666666667788000000000000000000008888888000000000000000
    0000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF001FFFF80
    003FFC000007F800FF03E00FFFF0C01FFFFCC07FFFFF807FFFFF80FFFFFF00FF
    FFFF00FFFFFF80FFFFFF807FFFFFC07FFFFFE01FFFFCF007FFF1F8003E03FE00
    000FFF80003FFFFC07FFFFFFFFFF280000001000000020000000010004000000
    0000C00000000000000000000000000000000000000000000000000080000080
    00000080800080000000800080008080000080808000C0C0C0000000FF0000FF
    000000FFFF00FF000000FF00FF00FFFF0000FFFFFF0000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    8877777780000087666788877780086668000000088886668000000000007667
    0000000000008667000000000000066670000000000008666800000000880008
    66677777778000000887777880000000000000000000FFFF0000FFFF0000FFFF
    0000FFFF0000FFFF0000F0070000C001000083F8000007FF00000FFF00000FFF
    000087FF000083FC0000E0010000F8070000FFFF0000}
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseWheelDown = FormMouseWheelDown
  OnMouseWheelUp = FormMouseWheelUp
  OnPaint = FormPaint
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object gbModel: TGroupBox
    Left = 0
    Top = 73
    Width = 800
    Height = 515
    Align = alClient
    Caption = 'Model'
    TabOrder = 0
    object pcTabs: TPageControl
      Left = 2
      Top = 15
      Width = 796
      Height = 498
      ActivePage = tabSurfaces
      Align = alClient
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnChange = pcTabsChange
      object tabGeneral: TTabSheet
        Caption = 'General'
        object leName: TLabeledEdit
          Left = 72
          Top = 200
          Width = 697
          Height = 21
          TabStop = False
          BevelInner = bvNone
          BevelOuter = bvNone
          Color = clBtnFace
          Ctl3D = True
          EditLabel.Width = 38
          EditLabel.Height = 13
          EditLabel.Caption = 'FilePath'
          LabelPosition = lpLeft
          LabelSpacing = 10
          ParentCtl3D = False
          ParentShowHint = False
          ReadOnly = True
          ShowHint = False
          TabOrder = 0
        end
        object gbHeader: TGroupBox
          Left = 0
          Top = 8
          Width = 785
          Height = 177
          Align = alCustom
          Caption = 'Header'
          TabOrder = 1
          object leHeaderFlags: TLabeledEdit
            Left = 72
            Top = 96
            Width = 81
            Height = 21
            TabStop = False
            Color = clBtnFace
            EditLabel.Width = 25
            EditLabel.Height = 13
            EditLabel.Caption = 'Flags'
            LabelPosition = lpLeft
            LabelSpacing = 10
            ReadOnly = True
            TabOrder = 0
          end
          object leHeaderIdent: TLabeledEdit
            Left = 72
            Top = 24
            Width = 81
            Height = 21
            TabStop = False
            Color = clBtnFace
            EditLabel.Width = 24
            EditLabel.Height = 13
            EditLabel.Caption = 'Ident'
            LabelPosition = lpLeft
            LabelSpacing = 10
            ReadOnly = True
            TabOrder = 1
          end
          object leVersion: TLabeledEdit
            Left = 72
            Top = 48
            Width = 81
            Height = 21
            TabStop = False
            Color = clBtnFace
            EditLabel.Width = 35
            EditLabel.Height = 13
            EditLabel.Caption = 'Version'
            LabelPosition = lpLeft
            LabelSpacing = 10
            ReadOnly = True
            TabOrder = 2
          end
          object leHeaderName: TLabeledEdit
            Left = 72
            Top = 72
            Width = 697
            Height = 21
            TabStop = False
            Color = clBtnFace
            EditLabel.Width = 28
            EditLabel.Height = 13
            EditLabel.Caption = 'Name'
            LabelPosition = lpLeft
            LabelSpacing = 10
            ReadOnly = True
            TabOrder = 3
          end
        end
      end
      object tabAnimation: TTabSheet
        Caption = 'Animation'
        ImageIndex = 1
        object Label3: TLabel
          Left = 39
          Top = 43
          Width = 86
          Height = 13
          Caption = 'BoundingBox Min.'
        end
        object Label4: TLabel
          Left = 38
          Top = 68
          Width = 89
          Height = 13
          Caption = 'BoundingBox Max.'
        end
        object Label5: TLabel
          Left = 70
          Top = 92
          Width = 56
          Height = 13
          Caption = 'Local Origin'
        end
        object Label6: TLabel
          Left = 13
          Top = 115
          Width = 115
          Height = 13
          Caption = 'BoundingSphere Radius'
        end
        object cbNamesFrames: TComboBox
          Left = 136
          Top = 16
          Width = 281
          Height = 21
          Style = csDropDownList
          Color = clBtnFace
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = False
          TabOrder = 0
          TabStop = False
          OnSelect = cbNamesFramesSelect
        end
        object leNumFrames: TLabeledEdit
          Left = 72
          Top = 16
          Width = 57
          Height = 21
          TabStop = False
          Color = clBtnFace
          EditLabel.Width = 44
          EditLabel.Height = 13
          EditLabel.Caption = '# Frames'
          LabelPosition = lpLeft
          LabelSpacing = 10
          ParentShowHint = False
          ReadOnly = True
          ShowHint = False
          TabOrder = 1
        end
        object gbCopyFrames: TGroupBox
          Left = 0
          Top = 388
          Width = 785
          Height = 81
          Align = alCustom
          Anchors = [akLeft, akRight]
          Caption = 'Copy Frames'
          Color = clBtnFace
          Enabled = False
          ParentColor = False
          TabOrder = 2
          object leModelFilename: TLabeledEdit
            Left = 64
            Top = 40
            Width = 593
            Height = 21
            TabStop = False
            Color = clBtnFace
            EditLabel.Width = 107
            EditLabel.Height = 13
            EditLabel.Caption = 'From another .MD3 file'
            ParentShowHint = False
            ReadOnly = True
            ShowHint = False
            TabOrder = 1
          end
          object bModelFilename: TButton
            Left = 664
            Top = 40
            Width = 89
            Height = 21
            Caption = 'Select .MD3'
            ParentShowHint = False
            ShowHint = False
            TabOrder = 0
          end
        end
        object cbBBMinFrames: TComboBox
          Left = 136
          Top = 40
          Width = 641
          Height = 21
          Style = csSimple
          Color = clBtnFace
          ItemHeight = 13
          TabOrder = 3
          TabStop = False
          OnSelect = cbBBMinFramesSelect
        end
        object cbBBMaxFrames: TComboBox
          Left = 136
          Top = 64
          Width = 641
          Height = 21
          Style = csSimple
          Color = clBtnFace
          ItemHeight = 13
          TabOrder = 4
          TabStop = False
          OnSelect = cbBBMaxFramesSelect
        end
        object cbOriginFrames: TComboBox
          Left = 136
          Top = 88
          Width = 641
          Height = 21
          Style = csSimple
          Color = clBtnFace
          ItemHeight = 13
          TabOrder = 5
          TabStop = False
          OnSelect = cbOriginFramesSelect
        end
        object cbRadiusFrames: TComboBox
          Left = 136
          Top = 112
          Width = 281
          Height = 21
          Style = csSimple
          Color = clBtnFace
          ItemHeight = 13
          TabOrder = 6
          TabStop = False
          OnSelect = cbRadiusFramesSelect
        end
      end
      object tabTags: TTabSheet
        Caption = 'Tags'
        ImageIndex = 2
        object Label1: TLabel
          Left = 97
          Top = 68
          Width = 27
          Height = 13
          Caption = 'Origin'
        end
        object Label2: TLabel
          Left = 105
          Top = 91
          Width = 19
          Height = 13
          Caption = 'Axis'
        end
        object Label9: TLabel
          Left = 94
          Top = 43
          Width = 29
          Height = 13
          Caption = 'Frame'
        end
        object leNumTags: TLabeledEdit
          Left = 72
          Top = 16
          Width = 57
          Height = 21
          TabStop = False
          Color = clBtnFace
          EditLabel.Width = 34
          EditLabel.Height = 13
          EditLabel.Caption = '# Tags'
          LabelPosition = lpLeft
          LabelSpacing = 10
          ParentShowHint = False
          ReadOnly = True
          ShowHint = False
          TabOrder = 0
        end
        object cbNamesTags: TComboBox
          Left = 136
          Top = 16
          Width = 241
          Height = 21
          Style = csDropDownList
          Color = clBtnFace
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = False
          TabOrder = 1
          TabStop = False
          OnSelect = cbNamesTagsSelect
        end
        object cbTagOrigins: TComboBox
          Left = 136
          Top = 64
          Width = 641
          Height = 21
          AutoComplete = False
          Style = csSimple
          Color = clBtnFace
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = False
          TabOrder = 3
          TabStop = False
          OnSelect = cbTagOriginsSelect
        end
        object gbInsertTags: TGroupBox
          Left = 0
          Top = 118
          Width = 785
          Height = 257
          Align = alCustom
          Anchors = [akLeft, akRight]
          Caption = 'Adding Tags'
          TabOrder = 5
          object leTagFilename: TLabeledEdit
            Left = 64
            Top = 32
            Width = 545
            Height = 21
            TabStop = False
            Color = clBtnFace
            EditLabel.Width = 89
            EditLabel.Height = 13
            EditLabel.Caption = 'From .tag Filename'
            ParentShowHint = False
            ReadOnly = True
            ShowHint = False
            TabOrder = 1
          end
          object bTagFilename: TButton
            Left = 624
            Top = 32
            Width = 97
            Height = 21
            Caption = 'From .tag File...'
            ParentShowHint = False
            ShowHint = False
            TabOrder = 2
            OnClick = bTagFilenameClick
          end
          object gbTagManually: TGroupBox
            Left = 0
            Top = 64
            Width = 785
            Height = 193
            Align = alCustom
            Anchors = [akLeft, akRight]
            Caption = 'Manually'
            TabOrder = 0
            object Label27: TLabel
              Left = 24
              Top = 80
              Width = 27
              Height = 13
              Caption = 'Origin'
            end
            object Label28: TLabel
              Left = 32
              Top = 115
              Width = 19
              Height = 13
              Caption = 'Axis'
            end
            object leTagOriginX: TLabeledEdit
              Left = 64
              Top = 76
              Width = 177
              Height = 21
              EditLabel.Width = 7
              EditLabel.Height = 13
              EditLabel.Caption = 'X'
              TabOrder = 1
            end
            object leTagOriginY: TLabeledEdit
              Left = 248
              Top = 76
              Width = 177
              Height = 21
              EditLabel.Width = 7
              EditLabel.Height = 13
              EditLabel.Caption = 'Y'
              TabOrder = 2
            end
            object leTagOriginZ: TLabeledEdit
              Left = 432
              Top = 76
              Width = 177
              Height = 21
              EditLabel.Width = 7
              EditLabel.Height = 13
              EditLabel.Caption = 'Z'
              TabOrder = 3
            end
            object bTagAddManually: TButton
              Left = 626
              Top = 76
              Width = 95
              Height = 21
              Caption = 'Add'
              ParentShowHint = False
              ShowHint = False
              TabOrder = 4
              OnClick = bTagAddManuallyClick
            end
            object leTagName: TLabeledEdit
              Left = 64
              Top = 32
              Width = 361
              Height = 21
              EditLabel.Width = 48
              EditLabel.Height = 13
              EditLabel.Caption = 'Tag name'
              TabOrder = 0
              Text = 'tag_'
            end
            object eTagAxis0X: TEdit
              Left = 64
              Top = 112
              Width = 177
              Height = 21
              TabOrder = 5
              Text = '1.0'
            end
            object eTagAxis0Z: TEdit
              Left = 432
              Top = 112
              Width = 177
              Height = 21
              TabOrder = 7
              Text = '0.0'
            end
            object eTagAxis0Y: TEdit
              Left = 248
              Top = 112
              Width = 177
              Height = 21
              TabOrder = 6
              Text = '0.0'
            end
            object eTagAxis1Z: TEdit
              Left = 432
              Top = 136
              Width = 177
              Height = 21
              TabOrder = 10
              Text = '0.0'
            end
            object eTagAxis1Y: TEdit
              Left = 248
              Top = 136
              Width = 177
              Height = 21
              TabOrder = 9
              Text = '1.0'
            end
            object eTagAxis1X: TEdit
              Left = 64
              Top = 136
              Width = 177
              Height = 21
              TabOrder = 8
              Text = '0.0'
            end
            object eTagAxis2Z: TEdit
              Left = 432
              Top = 160
              Width = 177
              Height = 21
              TabOrder = 13
              Text = '1.0'
            end
            object eTagAxis2Y: TEdit
              Left = 248
              Top = 160
              Width = 177
              Height = 21
              TabOrder = 12
              Text = '0.0'
            end
            object eTagAxis2X: TEdit
              Left = 64
              Top = 160
              Width = 177
              Height = 21
              TabOrder = 11
              Text = '0.0'
            end
          end
        end
        object cbTagAxis: TComboBox
          Left = 136
          Top = 88
          Width = 641
          Height = 21
          Hint = 'Axis Vectors: (X,Y,Z)'
          AutoComplete = False
          Style = csSimple
          Color = clBtnFace
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
          TabStop = False
          OnSelect = cbTagAxisSelect
        end
        object cbTagFrameNr: TComboBox
          Left = 136
          Top = 40
          Width = 241
          Height = 21
          Style = csDropDownList
          Color = clBtnFace
          ItemHeight = 13
          TabOrder = 2
          TabStop = False
          OnSelect = cbTagFrameNrSelect
        end
        object gbTagSave: TGroupBox
          Left = 0
          Top = 412
          Width = 785
          Height = 57
          Align = alCustom
          Anchors = [akLeft, akRight]
          Caption = 'Saving Tags'
          TabOrder = 6
          object bSaveTags: TButton
            Left = 64
            Top = 21
            Width = 97
            Height = 25
            Caption = 'To .tag File...'
            TabOrder = 0
            OnClick = bSaveTagsClick
          end
        end
      end
      object tabSurfaces: TTabSheet
        Caption = 'Surfaces'
        ImageIndex = 3
        object Shape1: TShape
          Left = 96
          Top = 138
          Width = 1
          Height = 236
        end
        object Shape4: TShape
          Left = 96
          Top = 41
          Width = 1
          Height = 20
        end
        object shapeShaderFile: TShape
          Left = 147
          Top = 89
          Width = 1
          Height = 229
        end
        object shapeShaderTexture: TShape
          Left = 147
          Top = 328
          Width = 1
          Height = 45
        end
        object shapeSkinTexture: TShape
          Left = 147
          Top = 199
          Width = 1
          Height = 174
        end
        object shapeSkinFile: TLabel
          Left = 147
          Top = 187
          Width = 24
          Height = 13
          Caption = '____'
          Transparent = True
        end
        object shapeShaderFileOut: TLabel
          Left = 147
          Top = 316
          Width = 24
          Height = 13
          Caption = '____'
          Transparent = True
        end
        object shapeShaderFileIn: TLabel
          Left = 147
          Top = 305
          Width = 24
          Height = 13
          Caption = '____'
          Transparent = True
        end
        object shapeTextureFile: TShape
          Left = 147
          Top = 89
          Width = 1
          Height = 284
        end
        object shapeSkinShader: TShape
          Left = 147
          Top = 199
          Width = 1
          Height = 119
        end
        object Label10: TLabel
          Left = 108
          Top = 393
          Width = 24
          Height = 13
          Caption = '____'
        end
        object shapeSkinShaderlist: TShape
          Left = 147
          Top = 199
          Width = 1
          Height = 68
        end
        object shapeShaderlistIn: TLabel
          Left = 147
          Top = 254
          Width = 24
          Height = 13
          Caption = '____'
          Transparent = True
        end
        object shapeShaderlistOut: TLabel
          Left = 147
          Top = 265
          Width = 24
          Height = 13
          Caption = '____'
          Transparent = True
        end
        object shapeShaderlistShader: TShape
          Left = 147
          Top = 277
          Width = 1
          Height = 41
        end
        object shapeShaderlistTexture: TShape
          Left = 147
          Top = 277
          Width = 1
          Height = 96
        end
        object shapeShaderlist: TShape
          Left = 147
          Top = 89
          Width = 1
          Height = 178
        end
        object Label13: TLabel
          Left = 152
          Top = 152
          Width = 624
          Height = 13
          Caption = 
            '----------------------------------------------------------------' +
            '----------------------------------------------------------------' +
            '----------------------------------------------------------------' +
            '----------------'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clSilver
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object Label18: TLabel
          Left = 101
          Top = 152
          Width = 42
          Height = 13
          Caption = '--------------'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clSilver
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object Label19: TLabel
          Left = 10
          Top = 152
          Width = 81
          Height = 13
          Caption = '---------------------------'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clSilver
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object Label20: TLabel
          Left = 16
          Top = 179
          Width = 61
          Height = 13
          Caption = 'external data'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object Label21: TLabel
          Left = 16
          Top = 168
          Width = 29
          Height = 13
          Caption = 'Model'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object shapeSurfaceShader: TShape
          Left = 147
          Top = 41
          Width = 1
          Height = 20
        end
        object cbNamesSurfaces: TComboBox
          Left = 136
          Top = 16
          Width = 641
          Height = 21
          ItemHeight = 13
          TabOrder = 0
          OnChange = cbNamesSurfacesChange
          OnKeyDown = cbNamesSurfacesKeyDown
          OnSelect = cbNamesSurfacesSelect
        end
        object leNumSurfaces: TLabeledEdit
          Left = 72
          Top = 16
          Width = 57
          Height = 21
          TabStop = False
          Color = clBtnFace
          EditLabel.Width = 52
          EditLabel.Height = 13
          EditLabel.Caption = '# Surfaces'
          LabelPosition = lpLeft
          LabelSpacing = 10
          ReadOnly = True
          TabOrder = 2
        end
        object cbNamesShaders: TComboBox
          Left = 136
          Top = 64
          Width = 641
          Height = 21
          Style = csSimple
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = False
          TabOrder = 1
          OnKeyDown = cbNamesShadersKeyDown
        end
        object leNumShaders: TLabeledEdit
          Left = 72
          Top = 64
          Width = 57
          Height = 21
          TabStop = False
          Color = clBtnFace
          EditLabel.Width = 49
          EditLabel.Height = 13
          EditLabel.Caption = '# Shaders'
          LabelPosition = lpLeft
          LabelSpacing = 10
          ReadOnly = True
          TabOrder = 3
        end
        object leNumVerts: TLabeledEdit
          Left = 72
          Top = 88
          Width = 57
          Height = 21
          TabStop = False
          Color = clBtnFace
          EditLabel.Width = 34
          EditLabel.Height = 13
          EditLabel.Caption = '# Verts'
          LabelPosition = lpLeft
          LabelSpacing = 10
          ReadOnly = True
          TabOrder = 4
        end
        object leNumTriangles: TLabeledEdit
          Left = 72
          Top = 112
          Width = 57
          Height = 21
          TabStop = False
          Color = clBtnFace
          EditLabel.Width = 53
          EditLabel.Height = 13
          EditLabel.Caption = '# Triangles'
          LabelPosition = lpLeft
          LabelSpacing = 10
          ReadOnly = True
          TabOrder = 5
        end
        object gbOGLtris: TGroupBox
          Left = 8
          Top = 357
          Width = 97
          Height = 110
          Caption = 'Texture Preview'
          Color = 14933984
          ParentColor = False
          TabOrder = 6
          object img3DView: TImage
            Left = 2
            Top = 15
            Width = 93
            Height = 93
            Align = alClient
            AutoSize = True
            Center = True
            Picture.Data = {
              055449636F6E0000010002002020100000000000E80200002600000010101000
              00000000280100000E0300002800000020000000400000000100040000000000
              8002000000000000000000000000000000000000000000000000800000800000
              0080800080000000800080008080000080808000C0C0C0000000FF0000FF0000
              00FFFF00FF000000FF00FF00FFFF0000FFFFFF00000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000088877778888000000000000000000877666666666667
              7800000000000087666666666777766666678000000007666666778800000000
              8876670000086666667800000000000000008778008666666780000000000000
              0000008800666666600000000000000000000000076666668000000000000000
              0000000006666668000000000000000000000000866666680000000000000000
              0000000086666668000000000000000000000000076666670000000000000000
              0000000008666666800000000000000000000000007666666000000000000000
              0000000000076666678000000000000000000088000076666678800000000000
              0000877000000876666677788800000888767800000000087666666666676666
              6678000000000000088776666666667788000000000000000000008888888000
              0000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFF001FFFF80003FFC000007F800FF03E00FFFF0C01FFFFCC07FFFFF807FFFFF
              80FFFFFF00FFFFFF00FFFFFF80FFFFFF807FFFFFC07FFFFFE01FFFFCF007FFF1
              F8003E03FE00000FFF80003FFFFC07FFFFFFFFFF280000001000000020000000
              0100040000000000C00000000000000000000000000000000000000000000000
              00008000008000000080800080000000800080008080000080808000C0C0C000
              0000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF0000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000008877777780000087666788877780086668000000088886668000
              0000000076670000000000008667000000000000066670000000000008666800
              00000088000866677777778000000887777880000000000000000000FFFF0000
              FFFF0000FFFF0000FFFF0000FFFF0000F0070000C001000083F8000007FF0000
              0FFF00000FFF000087FF000083FC0000E0010000F8070000FFFF0000}
            Proportional = True
          end
        end
        object gbShaderFile: TGroupBox
          Left = 176
          Top = 296
          Width = 601
          Height = 81
          Caption = 'Shader File'
          TabOrder = 7
          object Label14: TLabel
            Left = 13
            Top = 25
            Width = 42
            Height = 13
            Caption = 'Filename'
          end
          object Label11: TLabel
            Left = 21
            Top = 52
            Width = 34
            Height = 13
            Alignment = taRightJustify
            Caption = 'Shader'
          end
          object cbShaderFile: TComboBox
            Left = 64
            Top = 20
            Width = 521
            Height = 21
            Style = csSimple
            Color = clBtnFace
            ItemHeight = 13
            TabOrder = 0
            TabStop = False
          end
          object cbShaderNameFound: TComboBox
            Left = 64
            Top = 48
            Width = 521
            Height = 21
            Style = csSimple
            Color = clBtnFace
            ItemHeight = 13
            TabOrder = 1
            TabStop = False
          end
        end
        object gbTextures: TGroupBox
          Left = 136
          Top = 376
          Width = 641
          Height = 89
          Caption = 'Textures'
          TabOrder = 8
          object Label12: TLabel
            Left = 48
            Top = 24
            Width = 47
            Height = 13
            Caption = 'Texture(s)'
          end
          object lNumTextures: TLabel
            Left = 24
            Top = 24
            Width = 20
            Height = 13
            Alignment = taRightJustify
            AutoSize = False
            Caption = '0'
          end
          object cbShaderTextures: TComboBox
            Left = 105
            Top = 20
            Width = 520
            Height = 21
            Style = csDropDownList
            Color = clBtnFace
            ItemHeight = 13
            TabOrder = 0
            OnChange = cbShaderTexturesChange
          end
          object cbHasAlpha: TCheckBox
            Left = 104
            Top = 42
            Width = 97
            Height = 17
            TabStop = False
            Caption = 'Alpha Channel'
            TabOrder = 1
          end
          object pShaderProps: TPanel
            Left = 352
            Top = 42
            Width = 273
            Height = 45
            BevelOuter = bvNone
            TabOrder = 2
            object leCull: TLabeledEdit
              Left = 214
              Top = 18
              Width = 58
              Height = 21
              TabStop = False
              BevelInner = bvNone
              BevelOuter = bvNone
              Color = clBtnFace
              Ctl3D = True
              EditLabel.Width = 17
              EditLabel.Height = 13
              EditLabel.Caption = 'Cull'
              EditLabel.Layout = tlCenter
              LabelPosition = lpLeft
              LabelSpacing = 6
              ParentCtl3D = False
              ReadOnly = True
              TabOrder = 0
            end
            object cbAlphaFunc: TCheckBox
              Left = 0
              Top = 0
              Width = 81
              Height = 17
              TabStop = False
              Caption = 'AlphaFunc'
              TabOrder = 1
            end
            object cbEnvironmentMap: TCheckBox
              Left = 0
              Top = 16
              Width = 81
              Height = 17
              TabStop = False
              Caption = 'Environment'
              TabOrder = 2
            end
            object cbClamped: TCheckBox
              Left = 192
              Top = 0
              Width = 65
              Height = 17
              TabStop = False
              Caption = 'Clamped'
              TabOrder = 3
            end
            object cbAnimMap: TCheckBox
              Left = 88
              Top = 0
              Width = 73
              Height = 17
              TabStop = False
              Caption = 'animMap'
              TabOrder = 4
            end
            object cbVideoMap: TCheckBox
              Left = 88
              Top = 16
              Width = 73
              Height = 17
              TabStop = False
              Caption = 'videoMap'
              TabOrder = 5
            end
          end
          object leTextureDimensions: TLabeledEdit
            Left = 164
            Top = 59
            Width = 77
            Height = 21
            TabStop = False
            BevelInner = bvNone
            BevelOuter = bvNone
            Color = clBtnFace
            EditLabel.Width = 54
            EditLabel.Height = 13
            EditLabel.Caption = 'Dimensions'
            LabelPosition = lpLeft
            LabelSpacing = 6
            TabOrder = 3
          end
        end
        object gbSkin: TGroupBox
          Left = 176
          Top = 168
          Width = 601
          Height = 78
          Caption = 'Skin File'
          TabOrder = 9
          object leSkinFile: TLabeledEdit
            Left = 64
            Top = 19
            Width = 281
            Height = 21
            TabStop = False
            Color = clBtnFace
            EditLabel.Width = 42
            EditLabel.Height = 13
            EditLabel.Caption = 'Filename'
            LabelPosition = lpLeft
            LabelSpacing = 10
            ReadOnly = True
            TabOrder = 0
          end
          object leSkin: TLabeledEdit
            Left = 64
            Top = 46
            Width = 521
            Height = 21
            TabStop = False
            Color = clBtnFace
            EditLabel.Width = 21
            EditLabel.Height = 13
            EditLabel.Caption = 'Skin'
            LabelPosition = lpLeft
            LabelSpacing = 10
            ReadOnly = True
            TabOrder = 1
          end
          object bSelectSkinfrompk3: TBitBtn
            Left = 352
            Top = 17
            Width = 75
            Height = 25
            Hint = 'Load From Game'
            Caption = 'Load...'
            TabOrder = 2
            OnClick = actionFileSelectSkinfrompk3Execute
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              04000000000000010000120B0000120B00001000000000000000000000000000
              800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
              3333333333333333333333300000003333333337777777333333307087707707
              7703377788888777777337877777707888733788888888888873377770877078
              88733788888888888873378777F7808788733788888888888873378770000007
              7873378888888888887337877887887778733788888888888873378887999978
              8873378888888888887337888797797788733788888888888873377177978971
              7773378888888888887336788998797777133788888888888873098988877888
              7770778888888888887778789998899987877888888888888887777770899817
              7777778888888888887730777707707777033777777777777773}
            NumGlyphs = 2
          end
          object bSelectSkin: TBitBtn
            Left = 432
            Top = 17
            Width = 75
            Height = 25
            Hint = 'Load From File'
            Caption = 'Load...'
            TabOrder = 3
            OnClick = actionFileSelectSkinExecute
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              04000000000000010000120B0000120B00001000000000000000000000000000
              800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
              3333333333333333333333333333333333333333333333333333333333333333
              33333FFFFFFFFFFFFFFF000000000000000077777777777777770F7777777777
              77707F3F3333333333370F988888888888707F733FFFFFFFF3370F8800000000
              88707F337777777733370F888888888888707F333FFFFFFFF3370F8800000000
              88707F337777777733370F888888888888707F333333333333370F8888888888
              88707F333333333333370FFFFFFFFFFFFFF07FFFFFFFFFFFFFF7000000000000
              0000777777777777777733333333333333333333333333333333333333333333
              3333333333333333333333333333333333333333333333333333}
            NumGlyphs = 2
          end
          object bClearSkin: TBitBtn
            Left = 510
            Top = 17
            Width = 75
            Height = 25
            Caption = 'Clear'
            TabOrder = 4
            OnClick = actionFileClearSkinExecute
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              04000000000000010000120B0000120B00001000000000000000000000000000
              800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333000000000
              3333333777777777F3333330F777777033333337F3F3F3F7F3333330F0808070
              33333337F7F7F7F7F3333330F080707033333337F7F7F7F7F3333330F0808070
              33333337F7F7F7F7F3333330F080707033333337F7F7F7F7F3333330F0808070
              333333F7F7F7F7F7F3F33030F080707030333737F7F7F7F7F7333300F0808070
              03333377F7F7F7F773333330F080707033333337F7F7F7F7F333333070707070
              33333337F7F7F7F7FF3333000000000003333377777777777F33330F88877777
              0333337FFFFFFFFF7F3333000000000003333377777777777333333330777033
              3333333337FFF7F3333333333000003333333333377777333333}
            NumGlyphs = 2
          end
        end
        object gbShaderList: TGroupBox
          Left = 176
          Top = 248
          Width = 601
          Height = 49
          Caption = 'ShaderList'
          TabOrder = 10
          object Label7: TLabel
            Left = 33
            Top = 24
            Width = 21
            Height = 13
            Caption = 'Files'
          end
          object cbShaderList: TComboBox
            Left = 64
            Top = 18
            Width = 363
            Height = 21
            Style = csDropDownList
            Color = clBtnFace
            ItemHeight = 13
            TabOrder = 0
            TabStop = False
          end
          object bSelectShaderFile: TBitBtn
            Left = 432
            Top = 16
            Width = 75
            Height = 25
            Hint = 'Add Shaderfile To List'
            Caption = 'Add...'
            TabOrder = 1
            OnClick = actionFileAddtoshaderlistExecute
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              04000000000000010000120B0000120B00001000000000000000000000000000
              800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555000000
              000055555F77777777775555000FFFFFFFF0555F777F5FFFF55755000F0F0000
              FFF05F777F7F77775557000F0F0FFFFFFFF0777F7F7F5FFFFFF70F0F0F0F0000
              00F07F7F7F7F777777570F0F0F0FFFFFFFF07F7F7F7F5FFFFFF70F0F0F0F0000
              00F07F7F7F7F777777570F0F0F0FFFFFFFF07F7F7F7F5FFF55570F0F0F0F000F
              FFF07F7F7F7F77755FF70F0F0F0FFFFF00007F7F7F7F5FF577770F0F0F0F00FF
              0F057F7F7F7F77557F750F0F0F0FFFFF00557F7F7F7FFFFF77550F0F0F000000
              05557F7F7F77777775550F0F0000000555557F7F7777777555550F0000000555
              55557F7777777555555500000005555555557777777555555555}
            NumGlyphs = 2
          end
          object bClearShaderList: TBitBtn
            Left = 510
            Top = 16
            Width = 75
            Height = 25
            Hint = 'Clear ShaderList'
            Caption = 'Clear'
            TabOrder = 2
            OnClick = actionFileClearshaderlistExecute
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              04000000000000010000120B0000120B00001000000000000000000000000000
              800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333000000000
              3333333777777777F3333330F777777033333337F3F3F3F7F3333330F0808070
              33333337F7F7F7F7F3333330F080707033333337F7F7F7F7F3333330F0808070
              33333337F7F7F7F7F3333330F080707033333337F7F7F7F7F3333330F0808070
              333333F7F7F7F7F7F3F33030F080707030333737F7F7F7F7F7333300F0808070
              03333377F7F7F7F773333330F080707033333337F7F7F7F7F333333070707070
              33333337F7F7F7F7FF3333000000000003333377777777777F33330F88877777
              0333337FFFFFFFFF7F3333000000000003333377777777777333333330777033
              3333333337FFF7F3333333333000003333333333377777333333}
            NumGlyphs = 2
          end
        end
        object leSurfaceFlags: TLabeledEdit
          Left = 696
          Top = 112
          Width = 81
          Height = 21
          TabStop = False
          Color = clBtnFace
          EditLabel.Width = 25
          EditLabel.Height = 13
          EditLabel.Caption = 'Flags'
          LabelPosition = lpLeft
          LabelSpacing = 10
          ReadOnly = True
          TabOrder = 11
        end
      end
      object TabBones: TTabSheet
        BorderWidth = 10
        Caption = 'Bones'
        ImageIndex = 6
        object tvBones: TTreeView
          Left = 0
          Top = 0
          Width = 425
          Height = 450
          Align = alLeft
          Indent = 19
          TabOrder = 0
        end
      end
      object tabView: TTabSheet
        Caption = 'View'
        ImageIndex = 4
        object gbOGL: TGroupBox
          Left = 0
          Top = 0
          Width = 788
          Height = 382
          Align = alClient
          TabOrder = 0
          OnDblClick = gbOGLDblClick
          OnMouseMove = gbOGLMouseMove
        end
        object Panel1: TPanel
          Left = 0
          Top = 382
          Width = 788
          Height = 88
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 1
          object Panel2: TPanel
            Left = 0
            Top = 0
            Width = 397
            Height = 88
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 0
            object gbAnimationControls: TGroupBox
              Left = 0
              Top = 0
              Width = 397
              Height = 88
              Align = alClient
              Caption = 'Animation'
              TabOrder = 0
              object Panel5: TPanel
                Left = 2
                Top = 15
                Width = 71
                Height = 71
                Align = alLeft
                Anchors = [akLeft]
                BevelOuter = bvNone
                TabOrder = 0
                object Label15: TLabel
                  Left = 16
                  Top = 26
                  Width = 54
                  Height = 13
                  Caption = 'Start Frame'
                end
                object Label16: TLabel
                  Left = 19
                  Top = 55
                  Width = 51
                  Height = 13
                  Caption = 'End Frame'
                end
                object Label26: TLabel
                  Left = 3
                  Top = 40
                  Width = 66
                  Height = 13
                  Caption = 'Current Frame'
                end
              end
              object Panel6: TPanel
                Left = 73
                Top = 15
                Width = 177
                Height = 71
                Align = alClient
                BevelOuter = bvNone
                TabOrder = 1
                object tbStartFrame: TTrackBar
                  Left = 0
                  Top = 27
                  Width = 175
                  Height = 14
                  Align = alCustom
                  Anchors = [akLeft, akRight]
                  PageSize = 1
                  TabOrder = 0
                  ThumbLength = 12
                  TickStyle = tsNone
                  OnChange = tbStartFrameChange
                end
                object tbCurrentFrame: TTrackBar
                  Left = 0
                  Top = 42
                  Width = 175
                  Height = 14
                  Align = alCustom
                  Anchors = [akLeft, akRight]
                  Ctl3D = False
                  ParentCtl3D = False
                  ParentShowHint = False
                  PageSize = 1
                  ShowHint = False
                  TabOrder = 1
                  ThumbLength = 12
                  TickStyle = tsNone
                  OnChange = tbCurrentFrameChange
                end
                object tbEndFrame: TTrackBar
                  Left = 0
                  Top = 56
                  Width = 175
                  Height = 14
                  Align = alCustom
                  Anchors = [akLeft, akRight]
                  PageSize = 1
                  TabOrder = 2
                  ThumbLength = 12
                  TickStyle = tsNone
                  OnChange = tbEndFrameChange
                end
                object cbAnimName: TComboBox
                  Left = 6
                  Top = 0
                  Width = 171
                  Height = 21
                  Style = csDropDownList
                  Color = clBtnFace
                  ItemHeight = 13
                  TabOrder = 3
                  OnChange = cbAnimNameChange
                end
              end
              object Panel7: TPanel
                Left = 250
                Top = 15
                Width = 145
                Height = 71
                Align = alRight
                BevelOuter = bvNone
                TabOrder = 2
                object lEndFrame: TLabel
                  Left = 1
                  Top = 57
                  Width = 48
                  Height = 13
                  Hint = 'Doubleclick to set End-Frame'
                  AutoSize = False
                  Caption = '0'
                  OnDblClick = lEndFrameDblClick
                end
                object lCurrentFrame: TLabel
                  Left = 1
                  Top = 42
                  Width = 48
                  Height = 13
                  Hint = 'Doubleclick to set Current Frame'
                  AutoSize = False
                  Caption = '0'
                  OnDblClick = lCurrentFrameDblClick
                end
                object lStartFrame: TLabel
                  Left = 1
                  Top = 27
                  Width = 48
                  Height = 13
                  Hint = 'Doubleclick to set Start-Frame'
                  AutoSize = False
                  Caption = '0'
                  OnDblClick = lStartFrameDblClick
                end
                object Label17: TLabel
                  Left = 56
                  Top = 46
                  Width = 20
                  Height = 13
                  Caption = 'FPS'
                end
                object cbPlay: TCheckBox
                  Left = 83
                  Top = 6
                  Width = 49
                  Height = 17
                  Caption = 'Play'
                  Checked = True
                  State = cbChecked
                  TabOrder = 2
                  OnClick = cbPlayClick
                end
                object cbLoop: TCheckBox
                  Left = 83
                  Top = 22
                  Width = 49
                  Height = 17
                  Caption = 'Loop'
                  Checked = True
                  State = cbChecked
                  TabOrder = 3
                end
                object eFPS: TEdit
                  Left = 83
                  Top = 43
                  Width = 25
                  Height = 21
                  ReadOnly = True
                  TabOrder = 0
                  Text = '20'
                  OnChange = eFPSChange
                end
                object udFPS: TUpDown
                  Left = 108
                  Top = 43
                  Width = 15
                  Height = 21
                  Associate = eFPS
                  Min = 1
                  Max = 125
                  Position = 20
                  TabOrder = 1
                  Thousands = False
                end
              end
            end
          end
          object Panel3: TPanel
            Left = 616
            Top = 0
            Width = 172
            Height = 88
            Align = alRight
            BevelOuter = bvNone
            TabOrder = 1
            object gbViewOptions: TGroupBox
              Left = -1
              Top = 0
              Width = 172
              Height = 88
              Caption = 'Options'
              TabOrder = 0
              DesignSize = (
                172
                88)
              object Label22: TLabel
                Left = 11
                Top = 15
                Width = 51
                Height = 13
                Caption = 'Pivot Point'
              end
              object cbTagPivots: TComboBox
                Left = 8
                Top = 28
                Width = 156
                Height = 21
                Style = csDropDownList
                Anchors = [akRight, akBottom]
                Color = clBtnFace
                ItemHeight = 13
                TabOrder = 0
                OnChange = cbTagPivotsChange
              end
              object cbLockView: TCheckBox
                Left = 8
                Top = 52
                Width = 97
                Height = 17
                Hint = 'Lock camera position in 3D-view'
                Caption = 'Lock View'
                TabOrder = 1
              end
              object bPrtScr: TButton
                Left = 112
                Top = 56
                Width = 51
                Height = 25
                Hint = 'Make a screenshot image of the 3D-view'
                Caption = 'PrtScr'
                TabOrder = 2
                OnClick = bPrtScrClick
              end
            end
          end
          object Panel4: TPanel
            Left = 397
            Top = 0
            Width = 219
            Height = 88
            Align = alRight
            BevelOuter = bvNone
            TabOrder = 2
            object gbLOD: TGroupBox
              Left = -2
              Top = 0
              Width = 222
              Height = 88
              Align = alCustom
              Anchors = [akLeft, akTop, akRight]
              Caption = 'LOD'
              TabOrder = 0
              object Label23: TLabel
                Left = 16
                Top = 62
                Width = 41
                Height = 13
                Caption = 'Minimum'
              end
              object Label24: TLabel
                Left = 8
                Top = 43
                Width = 47
                Height = 13
                Caption = 'Surface #'
              end
              object tLODpresence: TLabel
                Left = 189
                Top = 13
                Width = 17
                Height = 13
                Alignment = taRightJustify
                Caption = 'info'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = cl3DDkShadow
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                ParentFont = False
              end
              object tLODSurfacename: TLabel
                Left = 112
                Top = 43
                Width = 63
                Height = 13
                Caption = 'Surfacename'
              end
              object cbLODEnabled: TCheckBox
                Left = 8
                Top = 12
                Width = 65
                Height = 17
                Caption = 'Enabled'
                TabOrder = 0
                OnClick = cbLODEnabledClick
              end
              object tbLODMinimum: TTrackBar
                Left = 60
                Top = 65
                Width = 157
                Height = 14
                Max = 100
                Min = 1
                PageSize = 1
                Frequency = 25
                Position = 100
                TabOrder = 1
                ThumbLength = 12
                OnChange = tbLODMinimumChange
              end
              object seLODSurfaceNr: TSpinEdit
                Left = 64
                Top = 40
                Width = 41
                Height = 22
                EditorEnabled = False
                MaxValue = -1
                MinValue = -1
                TabOrder = 2
                Value = -1
                OnChange = seLODSurfaceNrChange
              end
            end
          end
        end
      end
      object tabHelp: TTabSheet
        BorderWidth = 10
        Caption = 'Help'
        ImageIndex = 5
        object MemoHelp: TMemo
          Left = 0
          Top = 0
          Width = 768
          Height = 450
          Align = alClient
          BevelInner = bvNone
          BevelOuter = bvNone
          BorderStyle = bsNone
          Color = clBtnFace
          Lines.Strings = (
            
              'For a fully illustrated help, see the link: http://www.et-only.c' +
              'om/downloads/tools/readme'
            ''
            
              'The 3D-view can be changed by clicking the left/right mouse-butt' +
              'ons while moving the mouse,..this will rotate the model around i' +
              'ts own local axis.'
            'Pressing the Ctrl-key will rotate the camera around the model.'
            
              'Pressing Shift on the keyboard, while dragging the mouse, will s' +
              'hift/strafe the camera..'
            
              'Zoom in & out by using the mousewheel when hovering over the 3D-' +
              'View..'
            'Doubleclicking the 3D-view resets the view..'
            
              'The model'#39's origin is represented as a tiny yellow dot. Axis are' +
              ' RedGreenBlue for XYZ.. '
            ''
            
              'When texturing the model, all needed textures have to be found. ' +
              'Like in the game, textures can also be replaced by shaders (if s' +
              'uch a shader should exist).. In '
            'this case, the replacement-shader has to be found first.'
            
              'Textures/Shaders can come from different locations: the game, an' +
              'y custom pk3, a local directory (Model-directory, a skin-file or' +
              ' from the "ShaderList").'
            
              'This Model-Tool searches for all needed files.. If it cannot fin' +
              'd what it needs, the surface will be drawn all white.'
            
              'Tip: If the model is drawn all white, You can check the "Lightin' +
              'g" checkbox for better recognition because the objects are then ' +
              'shaded..'
            
              'If a surface has no shadername assigned (model drawn all white),' +
              ' the surface needs a skin (with a shadername per surface)..'
            
              'The search-order for finding shaders is: Skin, ShaderList, PK3 (' +
              'if model was loaded from a PK3), local ModelDir on harddisk, the' +
              ' game (pak0.pk3)..'
            
              'You can overload original shaders/textures by loading a skin-fil' +
              'e or assigning (shader)files to the shaderlist.'
            ''
            
              'You can manually change the shader-entry of any surface by typin' +
              'g another path/shader_or_texture_name in the white textedit on t' +
              'he '#39'Surfaces'#39'-Tab..'
            
              '(After changing the shader-entry, be sure to press the '#39'ENTER'#39'-k' +
              'ey to confirm the changes You made)..'
            ''
            
              'It is possible to load a skin-file and embed it into the model. ' +
              'This way the seperate skin-file is no longer needed with the dis' +
              'tribution of the model.'
            ''
            
              'The model'#39's origin and any existing tag in the model can act as ' +
              'a pivot-point..'
            
              'You can also use this selected pivot-point as the new origin of ' +
              'the model in an export..'
            
              'To do this, select the tag from the '#39'Pivot-Point'#39' combobox on th' +
              'e '#39'View'#39'-Tab, check the '#39'Use Pivot As New Origin'#39'-checkbox, and ' +
              'then save the model..'
            ''
            
              'If You have loaded an MD3-file, and want to append frames (from ' +
              'other MD3-files), the other MD3-files need to contain the same m' +
              'odel..'
            
              'In essence, they must have the same number of surfaces (+surface' +
              'names), the same surface-vertexcount & the same number of tags (' +
              '+tagnames)..'
            
              'To add frames to the end of an MD3: First load the MD3 which con' +
              'tains the first frame(s), then use one of the 3 options from the' +
              ' menu to append new frames '
            'from other files..'
            
              'If You want to combine a sequence of files into 1 MD3-model, the' +
              ' sequnced files must be numbered (like: file0.md3, file1.md3, fi' +
              'le2.md3 ... file52.md3).'
            
              'Hint: You can select multiple files in the FileOpen-Dialog when ' +
              'selecting a sequence of files..'
            ''
            ''
            
              'There are some rules/restrictions for using the '#39'Map -> MD3'#39' con' +
              'version:'
            
              '* To use the ".MAP to .MD3" option, use only worldspawn brushes,' +
              ' do not use any other entity (like for example a func_group).'
            
              '   Furthermore, use only brushes with faces that have no more th' +
              'an 4 vertices..'
            
              '   Do not make models that extend over 512 units in either direc' +
              'tion.. Keep vertex-positions within the range -512 to 512 units ' +
              'in Radiant.'
            
              '* Design Your model around the origin in Radiant.. The origin is' +
              ' at XYZ: (0,0,0).. In fact, Your model can be designed at any se' +
              't of coordinates, but will rotate '
            'around the origin by default..'
            
              '* There is no need to make a hull (like in an ordinary map); Do ' +
              'not add any entities to Your model (they will be ignored anyway)' +
              '..'
            
              '* If Your .map is too big for conversion, You will get a warning' +
              '-message (and the model cannot be saved then)..'
            ''
            
              'In-game, ET playermodels are drawn with changing Levels-Of-Detai' +
              'l (LOD). This means that the greater the distance between the vi' +
              'ewer and a playermodel, '
            
              'the less detailed it is drawn. To be able to do this, ET playerm' +
              'odels need certain pre-calculated LOD-data (in the model)..'
            
              'In the '#39'LOD'#39'-panel on the '#39'View'#39'-Tab this model-tool shows if an' +
              'y such LOD-data is absent/present/calculated in a playermodel.'
            
              'Note there is a minimum value for LOD. The model will never be d' +
              'rawn with less vertices than the value of '#39'LOD-minimum'#39' is set t' +
              'o.'
            
              'If a playermodel does not have the needed LOD-data, surfaces can' +
              ' (and will) go invisible in-game..'
            
              'If You have created a playermodel (MDM), it probably does not co' +
              'ntain all the nessecary LOD-data (like a calculated collapsemap)' +
              '..'
            
              'To add the Level-Of-Detail (LOD) data to Your playermodel, perfo' +
              'rm the following steps:'
            '* Load Your playermodel, choose to calculate LOD from the menu, '
            
              '* check Your LOD-Minimum values for every surface, by examining ' +
              'if the model still looks correct, otherwise manually change the ' +
              'values,'
            '* then save the model.'
            
              'Hint: The checkbox '#39'Enabled'#39' (on the '#39'LOD'#39'-panel) does not inser' +
              't/remove the LOD-data, it mearly toggles the display of the lowe' +
              'st/highest LOD.. The highest '
            'possible LOD of course being the original playermodel..'
            
              'Keep in mind that the lowest LOD-model will look '#39'ugly'#39' inspecte' +
              'd on close-up; Normally the lowest LOD-model is only seen from g' +
              'reater distance, and people will '
            'then hardly notice the decrease in detail.'
            ''
            
              'To select a range of frames for export: Use the 2 sliders '#39'Start' +
              ' Frame'#39' & '#39'End Frame'#39'.. (The range includes the start- & end-fra' +
              'me, and everything in between).'
            
              'To Delete 1 frame: Stop playback animation, set the slider '#39'Curr' +
              'ent Frame'#39' to the frame You want to remove, then select the opti' +
              'on from the menu..'
            
              'Hint: You can doubleclick the frame#-text right next to sliders ' +
              'to manually enter a frame-number..'
            ''
            'General hints and tips:'
            
              '* The "Save As"-menu automaticly changes to appropiate filetypes' +
              '.'
            
              '   For example: After loading an MDS, You can save it as an MDM/' +
              'MDX pair.. After loading a MAP, You can save it as an MD3..'
            
              '* Loading only an .MDX-file has no effect, because it does not c' +
              'ontain a model. To see a playermodel, You have to load an .MDM (' +
              'or .MDS) first.'
            
              '* When drag'#39'n'#39'dropping files onto the tool-window: use only 1 fi' +
              'le for [md3, map, mds, skin], but use 2 files at once for [mdm/m' +
              'dx]'
            ''
            ''
            
              'This application has been coded in Delphi 7 by Ron Driessen aka ' +
              'C aka [UJE]C'
            
              'The poly-reduction method used in this program is created by Sta' +
              'n Melax. The method is slightly changed so it works better for o' +
              'pen meshes..'
            
              'Only the most basic shader-support is implemented.. Things like ' +
              'rgbGen, alphaGen, tcMod, deformVertexes are not supported by thi' +
              's application..'
            
              'As of version 1.1.1 of this tool, MDM/MDX & MDS files are suppor' +
              'ted (along with some conversion options).'
            'Since v1.2.0 it is also possible to convert .MAP to .MD3..'
            
              'In v1.4.0.4 it is possible to use any sized texture in a ".MAP t' +
              'o .MD3" model..'
            ''
            ''
            
              'Special thanks to eCo|ischbinz for his cooperation, testing, fee' +
              'dback, spawning ideas and delivering models..'
            'Thanks also go out to Berzerkr for his feedback..'
            ''
            ''
            ''
            'Known issues:'
            
              '* After loading an MDS, the tags are not quite correct.. Just lo' +
              'ad the tags of an original MDM..'
            
              '* Textures containing an alpha-channel can sometimes be rendered' +
              ' translucent (while they should not be)..'
            ''
            
              'Work-in-progress, take it as it is for now.. Make backups of You' +
              'r work before using this tool..'
            
              'Live long and prosper, but remember: The needs of the many outwe' +
              'igh the needs of the one..')
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 0
          OnClick = MemoHelpClick
        end
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 588
    Width = 800
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object gbSettings: TGroupBox
    Left = 0
    Top = 0
    Width = 800
    Height = 73
    Align = alTop
    Caption = 'View'
    TabOrder = 2
    object Label25: TLabel
      Left = 543
      Top = 17
      Width = 57
      Height = 13
      Caption = 'Game-PAKs'
    end
    object cbLightingEnabled: TCheckBox
      Left = 136
      Top = 16
      Width = 65
      Height = 17
      Hint = 'Use OpenGL lighting'
      Caption = 'Lighting'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = actionViewLightingExecute
    end
    object cbShowTags: TCheckBox
      Left = 24
      Top = 16
      Width = 81
      Height = 17
      Caption = 'Show Tags'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = actionViewShowtagsExecute
    end
    object cbCleanUp: TCheckBox
      Left = 536
      Top = 48
      Width = 65
      Height = 17
      Hint = 'Remove "tmp"-directory after use'
      Caption = 'Clean-up'
      Enabled = False
      TabOrder = 2
      Visible = False
    end
    object cbShowSkeleton: TCheckBox
      Left = 24
      Top = 48
      Width = 97
      Height = 17
      Caption = 'Show Skeleton'
      TabOrder = 3
      OnClick = actionViewShowskeletonExecute
    end
    object bAddGamePAK: TBitBtn
      Left = 608
      Top = 40
      Width = 89
      Height = 25
      Hint = 'Add a PAK-file from the game'
      Caption = 'Add PAK...'
      TabOrder = 4
      OnClick = bAddGamePAKClick
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333393333333333333939393333333333393939333333333339393933
        3333333339393933333333333939393333333339993939993333399999393999
        9933993333393333399399333339333339933993333933339933333333393333
        3333333333393333333333333339333333333333333333333333}
    end
    object cbAlphaPreview: TCheckBox
      Left = 136
      Top = 48
      Width = 137
      Height = 17
      Hint = 'Shows transparent/translucent images in the Texture-Preview'
      Caption = 'Show Alpha in Preview'
      Checked = True
      State = cbChecked
      TabOrder = 5
      OnClick = actionViewShowalphapreviewExecute
    end
    object cbCenterModel: TCheckBox
      Left = 136
      Top = 32
      Width = 97
      Height = 17
      Caption = 'Center Model'
      TabOrder = 6
      OnClick = actionViewCenterModelExecute
    end
    object cbShowNormals: TCheckBox
      Left = 24
      Top = 32
      Width = 97
      Height = 17
      Caption = 'Show Normals'
      TabOrder = 7
    end
    object cbWireframe: TCheckBox
      Left = 288
      Top = 16
      Width = 81
      Height = 17
      Caption = 'Wireframe'
      TabOrder = 8
      OnClick = actionViewWireframeExecute
    end
    object cbTwoSided: TCheckBox
      Left = 288
      Top = 32
      Width = 97
      Height = 17
      Caption = 'Two-Sided'
      TabOrder = 9
      OnClick = actionViewTwoSidedExecute
    end
    object cbSmoothFlat: TCheckBox
      Left = 288
      Top = 48
      Width = 97
      Height = 17
      Caption = 'Flat Shading'
      TabOrder = 10
      OnClick = actionViewSmoothFlatExecute
    end
    object cbMouseControl: TCheckBox
      Left = 392
      Top = 48
      Width = 137
      Height = 17
      Caption = 'Mouse Control Type 1'
      TabOrder = 11
      OnClick = actionViewMouseControlExecute
    end
    object cbPAKsList: TComboBox
      Left = 608
      Top = 13
      Width = 177
      Height = 21
      Style = csDropDownList
      Color = clBtnFace
      ItemHeight = 13
      TabOrder = 12
      OnSelect = cbPAKsListSelect
    end
    object bDelGamePAK: TBitBtn
      Left = 704
      Top = 40
      Width = 81
      Height = 25
      Caption = 'Del. PAK'
      TabOrder = 13
      OnClick = bDelGamePAKClick
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333000000000
        33333330F777777033333330F080807033333330F080707033333330F0808070
        33333330F080707033333330F080807033333030F080707030333300F0808070
        03333330F0807070333333307070707033333300000000000333330F88877777
        0333330000000000033333333077703333333333300000333333}
    end
    object cbShowGroundplane: TCheckBox
      Left = 392
      Top = 16
      Width = 121
      Height = 17
      Caption = 'Show Groundplane'
      TabOrder = 14
      OnClick = actionViewGroundplaneExecute
    end
    object cbShowAxis: TCheckBox
      Left = 392
      Top = 32
      Width = 97
      Height = 17
      Caption = 'Show Axis'
      TabOrder = 15
      OnClick = actionViewAxisExecute
    end
  end
  object OpenDialog: TOpenDialog
    DefaultExt = '.MD3'
    Filter = 'Quake 3 model  (.MD3)|*.MD3'
    Title = 'Select a model to load'
    Left = 296
    Top = 64
  end
  object TagOpenDialog: TOpenDialog
    DefaultExt = '.TAG'
    Filter = 'Model Tags  (*.tag)|*.tag'
    Title = 'Select model-tags to import'
    Left = 328
    Top = 64
  end
  object SaveAsDialog: TSaveDialog
    DefaultExt = '.MD3'
    Filter = 'Quake 3 model|*.MD3'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofNoLongNames, ofEnableSizing]
    Title = 'Select a model to save'
    Left = 681
    Top = 65
  end
  object ApplicationEvents: TApplicationEvents
    OnActivate = ApplicationEventsActivate
    Left = 10
    Top = 63
  end
  object TimerFPS: TTimer
    OnTimer = TimerFPSTimer
    Left = 42
    Top = 63
  end
  object MainMenu: TMainMenu
    Images = ImageList
    Left = 202
    Top = 64
    object menuFile: TMenuItem
      Caption = '&File'
      object menuFileLoadAnyFromGame: TMenuItem
        Caption = 'Load From Game'
        Enabled = False
        Visible = False
      end
      object menuFileLoadAnyFromPK3: TMenuItem
        Caption = 'Load From PK3'
        Enabled = False
        Visible = False
      end
      object menuFileLoadAnyFromFile: TMenuItem
        Action = actionFileLoadAnyFromFile
        ImageIndex = 11
        ShortCut = 49228
      end
      object N14: TMenuItem
        Caption = '-'
      end
      object menuFileLoadfrompk3: TMenuItem
        Caption = 'Load MD3 From &Game...'
        ImageIndex = 0
        ShortCut = 16435
        OnClick = actionFileLoadfrompk3Execute
      end
      object menuFileLoadfrommappk3: TMenuItem
        Caption = 'Load MD3 From &PK3...'
        ImageIndex = 8
        OnClick = actionFileLoadfrommappk3Execute
      end
      object menuFileLoad: TMenuItem
        Caption = '&Load MD3 From File...'
        ImageIndex = 11
        ShortCut = 49203
        OnClick = actionFileLoadExecute
      end
      object menuFileImportMapAsMD3: TMenuItem
        Action = actionFileImportMapAsMD3
        ImageIndex = 14
        ShortCut = 49229
      end
      object menuFileLoadASE: TMenuItem
        Action = actionFileLoadASE
        ImageIndex = 32
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object menuFileLoadfromgameMDMMDX: TMenuItem
        Caption = 'Load MDM/MDX From Game...'
        ImageIndex = 0
        ShortCut = 16472
        OnClick = actionFileLoadfromgameMDMMDXExecute
      end
      object menuFileLoadMDMMDX: TMenuItem
        Action = actionFileLoadMDMMDX
        ImageIndex = 11
        ShortCut = 49240
      end
      object menuFileLoadMDX: TMenuItem
        Action = actionFileLoadMDX
      end
      object menuFileLoadMDXbones: TMenuItem
        Action = actionFileLoadMDXbones
        ImageIndex = 7
      end
      object menuFileLoadMDXframes: TMenuItem
        Action = actionFileLoadMDXframes
        ImageIndex = 1
      end
      object menuFileLoadMDMtags: TMenuItem
        Action = actionFileLoadMDMtags
        ImageIndex = 15
      end
      object menuFileLoadMDS: TMenuItem
        Action = actionFileLoadMDS
        ImageIndex = 11
        ShortCut = 49235
      end
      object N11: TMenuItem
        Caption = '-'
      end
      object menuFileLoadMS3D: TMenuItem
        Action = actionFileLoadMS3D
        ImageIndex = 10
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object menuFileSave: TMenuItem
        Action = actionFileSaveAs
        ShortCut = 16467
      end
      object menuFileExportFramesrangeToMD3: TMenuItem
        Action = actionModelMDMMDXframesToMD3
        ImageIndex = 1
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object menuFileExit: TMenuItem
        Caption = 'E&xit'
        OnClick = actionFileExitExecute
      end
    end
    object menuTexturing: TMenuItem
      Caption = '&Texturing'
      object menuFileSkin: TMenuItem
        Caption = 'Skin'
        object menuFileSkinLoadfrompk3: TMenuItem
          Caption = 'From &Game...'
          ImageIndex = 0
          ShortCut = 16468
          OnClick = actionFileSelectSkinfrompk3Execute
        end
        object menuFileSkinLoad: TMenuItem
          Caption = 'From &File...'
          ImageIndex = 11
          ShortCut = 49236
          OnClick = actionFileSelectSkinExecute
        end
        object N5: TMenuItem
          Caption = '-'
        end
        object menuSkinToModel: TMenuItem
          Action = actionModelSkinpermanent
          ShortCut = 16453
        end
        object N1: TMenuItem
          Caption = '-'
        end
        object menuModelSkinClear: TMenuItem
          Caption = '&Clear'
          ImageIndex = 6
          OnClick = actionFileClearSkinExecute
        end
      end
      object menuFileShaderlist: TMenuItem
        Caption = 'Shaderlist'
        object menuFileShaderlistAdd: TMenuItem
          Caption = 'Add File...'
          OnClick = actionFileAddtoshaderlistExecute
        end
        object N15: TMenuItem
          Caption = '-'
        end
        object menuFileShaderlistClear: TMenuItem
          Caption = 'Clear'
          ImageIndex = 6
          OnClick = actionFileClearshaderlistExecute
        end
      end
    end
    object menuModel: TMenuItem
      Caption = '&Edit'
      object menuModelClear: TMenuItem
        Caption = 'Clear'
        ImageIndex = 6
        OnClick = actionModelClearExecute
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object menuModelAnimation: TMenuItem
        Caption = '&Animation'
        object menuModelAnimationAddframe: TMenuItem
          Action = actionFileAddframe
          ImageIndex = 12
          ShortCut = 49217
        end
        object menuModelAnimationAddframesSequence: TMenuItem
          Action = actionFileAddframesequence
          ImageIndex = 13
        end
        object menuModelAnimationAddframes: TMenuItem
          Action = actionFileAddframes
          ImageIndex = 31
        end
        object N12: TMenuItem
          Caption = '-'
        end
        object menuModelAnimationDelframe: TMenuItem
          Action = actionModelDeleteframe
          ImageIndex = 6
          ShortCut = 49220
        end
      end
      object menuModelTags: TMenuItem
        Caption = '&Tags'
        object menuModelTagsInvertX: TMenuItem
          Caption = 'Invert X Axis'
          ImageIndex = 21
          ShortCut = 116
          OnClick = menuModelTagsInvertXClick
        end
        object menuModelTagsInvertY: TMenuItem
          Caption = 'Invert Y Axis'
          ImageIndex = 16
          ShortCut = 117
          OnClick = menuModelTagsInvertYClick
        end
        object menuModelTagsInvertZ: TMenuItem
          Caption = 'Invert Z Axis'
          ImageIndex = 17
          ShortCut = 118
          OnClick = menuModelTagsInvertZClick
        end
        object menuModelTagsSwapXY: TMenuItem
          Caption = 'Swap XY Axis'
          ImageIndex = 18
          ShortCut = 16500
          OnClick = menuModelTagsSwapXYClick
        end
        object menuModelTagsSwapXZ: TMenuItem
          Caption = 'Swap XZ Axis'
          ImageIndex = 19
          ShortCut = 16501
          OnClick = menuModelTagsSwapXZClick
        end
        object menuModelTagsSwapYZ: TMenuItem
          Caption = 'Swap YZ Axis'
          ImageIndex = 20
          ShortCut = 16502
          OnClick = menuModelTagsSwapYZClick
        end
        object N16: TMenuItem
          Caption = '-'
        end
        object menuModelMD3TagAsOrigin: TMenuItem
          Action = actionModelMD3TagAsOrigin
        end
      end
      object menuModelSurfaces: TMenuItem
        Caption = '&Surfaces'
        object menuModelSurfacesSwapUVST: TMenuItem
          Action = actionModelMD3SwapUVST
        end
        object menumodelsurfaceRemove: TMenuItem
          Action = actionModelMD3RemoveSurface
        end
        object menuModelSurfacesCompact: TMenuItem
          Action = actionModelMD3SurfacesCompact
        end
        object N13: TMenuItem
          Caption = '-'
        end
        object menuModelSurfacesChangesurfacename: TMenuItem
          Caption = 'Change S&urface-name...'
          Enabled = False
        end
        object menuModelSurfacesChangeshadername: TMenuItem
          Caption = 'Change S&hader-name...'
          Enabled = False
        end
      end
      object menuModelBones: TMenuItem
        Caption = '&Bones'
        object menuModelBonesDefaultNames: TMenuItem
          Action = actionModelMDMMDXRenameBones
        end
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object menuModelCalcLOD: TMenuItem
        Action = actionModelMDMMDXCalculateLOD
        ImageIndex = 2
      end
      object menuModelCalcNormals: TMenuItem
        Action = actionModelCalculateNormals
      end
      object N17: TMenuItem
        Caption = '-'
      end
      object menuModelMD3Fixcracksgaps: TMenuItem
        Action = actionModelMD3FixCracksGaps
      end
      object menuModelSmoothSurface: TMenuItem
        Caption = 'Smooth Current Surface'
        ImageIndex = 30
        OnClick = menuModelSmoothSurfaceClick
      end
      object N19: TMenuItem
        Caption = '-'
      end
      object menuModelScaleskeleton: TMenuItem
        Action = actionModelMDMMDXScaleBones
        ImageIndex = 9
      end
      object menuModelScalemd3: TMenuItem
        Action = actionModelMD3Scale
        ImageIndex = 9
      end
      object N20: TMenuItem
        Caption = '-'
      end
      object menuModelRotateX: TMenuItem
        Action = actionModelMD3RotateX
        ImageIndex = 29
      end
      object menuModelRotateY: TMenuItem
        Action = actionModelMD3RotateY
        ImageIndex = 27
      end
      object menuModelRotateZ: TMenuItem
        Action = actionModelMD3RotateZ
        ImageIndex = 28
      end
      object N22: TMenuItem
        Caption = '-'
      end
      object menuModelMD3FlipX: TMenuItem
        Action = actionModelMD3FlipX
        ImageIndex = 26
      end
      object menuModelMD3FlipY: TMenuItem
        Action = actionModelMD3FlipY
        ImageIndex = 22
      end
      object menuModelMD3FlipZ: TMenuItem
        Action = actionModelMD3FlipZ
        ImageIndex = 23
      end
      object menuModelMD3FlipNormals: TMenuItem
        Action = actionModelMD3FlipNormals
        ImageIndex = 24
      end
      object menuModelMD3FlipWinding: TMenuItem
        Action = actionModelMD3FlipWinding
        ImageIndex = 25
      end
    end
    object menuView: TMenuItem
      Caption = '&View'
      object menuViewMouseControl: TMenuItem
        Caption = 'Mouse Control Type'
        Checked = True
        OnClick = actionViewMouseControlExecute
      end
      object N10: TMenuItem
        Caption = '-'
      end
      object menuViewLighting: TMenuItem
        Caption = '&Lighting'
        Checked = True
        OnClick = actionViewLightingExecute
      end
      object menuViewCenterModel: TMenuItem
        Caption = 'Center Model'
        Checked = True
        OnClick = actionViewCenterModelExecute
      end
      object menuViewShowtags: TMenuItem
        Caption = 'Show Tags'
        Checked = True
        OnClick = actionViewShowtagsExecute
      end
      object menuViewShowskeleton: TMenuItem
        Caption = 'Show Skeleton'
        Checked = True
        OnClick = actionViewShowskeletonExecute
      end
      object menuViewShowNormals: TMenuItem
        Caption = 'Show Normals'
        Checked = True
      end
      object menuViewShowGroundplane: TMenuItem
        Caption = 'Show Groundplane'
        Checked = True
      end
      object menuViewShowAxis: TMenuItem
        Caption = 'Show Axis'
        Checked = True
      end
      object menuViewWireFrame: TMenuItem
        Caption = 'Wireframe'
        Checked = True
        OnClick = actionViewWireframeExecute
      end
      object menuViewTwoSided: TMenuItem
        Caption = 'Two-Sided'
        Checked = True
        OnClick = actionViewTwoSidedExecute
      end
      object menuViewFlatShading: TMenuItem
        Caption = 'Flat Shading'
        Checked = True
        OnClick = actionViewSmoothFlatExecute
      end
      object menuViewShowAlphapreview: TMenuItem
        Caption = 'Show Alpha in Preview'
        Checked = True
        OnClick = actionViewShowalphapreviewExecute
      end
      object menuViewShowskybox: TMenuItem
        Caption = 'Show SkyBox'
        Checked = True
        OnClick = menuViewShowskyboxClick
      end
      object menuViewSkycolors: TMenuItem
        Caption = 'Sky Colors'
        object menuViewSkycolortop: TMenuItem
          Caption = 'Top'
          OnClick = menuViewSkycolortopClick
          OnAdvancedDrawItem = menuViewSkycolortopAdvancedDrawItem
        end
        object menuViewSkycolorbottom: TMenuItem
          Caption = 'Bottom'
          OnClick = menuViewSkycolorbottomClick
          OnAdvancedDrawItem = menuViewSkycolorbottomAdvancedDrawItem
        end
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object menuViewGammaSW: TMenuItem
        Caption = 'Gamma'
        object menuViewGammaSW1: TMenuItem
          Caption = '1.0 (default)'
          Checked = True
          GroupIndex = 1
          RadioItem = True
          OnClick = menuViewGammaSW1Click
        end
        object menuViewGammaSW1_5: TMenuItem
          Caption = '1.5'
          GroupIndex = 1
          RadioItem = True
          OnClick = menuViewGammaSW1_5Click
        end
        object menuViewGammaSW2: TMenuItem
          Caption = '2.0'
          GroupIndex = 1
          RadioItem = True
          OnClick = menuViewGammaSW2Click
        end
        object menuViewGammaSW2_5: TMenuItem
          Caption = '2.5'
          GroupIndex = 1
          RadioItem = True
          OnClick = menuViewGammaSW2_5Click
        end
        object menuViewGammaSW3: TMenuItem
          Caption = '3.0'
          GroupIndex = 1
          RadioItem = True
          OnClick = menuViewGammaSW3Click
        end
        object menuViewGammaSW3_5: TMenuItem
          Caption = '3.5'
          GroupIndex = 1
          RadioItem = True
          OnClick = menuViewGammaSW3_5Click
        end
        object menuViewGammaSW4: TMenuItem
          Caption = '4.0'
          GroupIndex = 1
          RadioItem = True
          OnClick = menuViewGammaSW4Click
        end
        object menuViewGammaSW4_5: TMenuItem
          Caption = '4.5'
          GroupIndex = 1
          RadioItem = True
          OnClick = menuViewGammaSW4_5Click
        end
        object menuViewGammaSW5: TMenuItem
          Caption = '5.0'
          GroupIndex = 1
          RadioItem = True
          OnClick = menuViewGammaSW5Click
        end
      end
    end
    object menuTools: TMenuItem
      Caption = 'Tools'
      object menuToolsColorconvert: TMenuItem
        Caption = 'Color Convert'
        object menuToolsColorconvertRadiant: TMenuItem
          Caption = 'Radiant: 0 0 0    Web: #000000'
          OnClick = menuToolsColorconvertRadiantClick
          OnAdvancedDrawItem = menuToolsColorconvertRadiantAdvancedDrawItem
        end
      end
    end
    object menuSettings: TMenuItem
      Caption = '&Settings'
      object menuSettingsGamedir: TMenuItem
        Caption = 'Select &Game Path...'
        ImageIndex = 0
        OnClick = actionSettingsGamedirExecute
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object menuSettingsCleanup: TMenuItem
        Caption = 'Clean-up'
        Checked = True
        Enabled = False
        OnClick = actionSettingsCleanupExecute
      end
    end
    object menuHelp: TMenuItem
      Caption = '&Help'
      ShortCut = 112
      OnClick = actionHelpExecute
    end
  end
  object Zip: TZipForge
    ExtractCorruptedFiles = False
    CompressionLevel = clFastest
    CompressionMode = 1
    CurrentVersion = '2.70 '
    SpanningMode = smNone
    SpanningOptions.AdvancedNaming = True
    SpanningOptions.VolumeSize = vsAutoDetect
    Options.FlushBuffers = True
    Options.OEMFileNames = True
    InMemory = False
    Zip64Mode = zmDisabled
    Left = 104
    Top = 64
  end
  object SkinOpenDialog: TOpenDialog
    DefaultExt = '.skin'
    Filter = 'Quake 3 model Skins  (*.skin)|*.skin'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Select a skin to load'
    Left = 360
    Top = 64
  end
  object ShaderOpenDialog: TOpenDialog
    DefaultExt = '.shader'
    Filter = 'Shader-file  (.shader)|*.shader'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Select a shader-file'
    Left = 392
    Top = 64
  end
  object ActionList: TActionList
    Images = ImageList
    Left = 170
    Top = 64
    object actionViewLighting: TAction
      Category = 'catView'
      Caption = '&Lighting'
      Checked = True
      OnExecute = actionViewLightingExecute
    end
    object actionModelClear: TAction
      Category = 'catModel'
      Caption = 'Clear'
      OnExecute = actionModelClearExecute
    end
    object actionModelMD3FlipX: TAction
      Category = 'catModel'
      Caption = 'Mirror X'
      OnExecute = actionModelMD3FlipXExecute
    end
    object actionModelMD3FlipY: TAction
      Category = 'catModel'
      Caption = 'Mirror Y'
      OnExecute = actionModelMD3FlipYExecute
    end
    object actionModelMD3FlipZ: TAction
      Category = 'catModel'
      Caption = 'Mirror Z'
      OnExecute = actionModelMD3FlipZExecute
    end
    object actionModelMD3FlipNormals: TAction
      Category = 'catModel'
      Caption = 'Mirror Normals'
      OnExecute = actionModelMD3FlipNormalsExecute
    end
    object actionFileLoadfrompk3: TAction
      Category = 'catFile'
      Caption = 'Load MD3 From &Game...'
      OnExecute = actionFileLoadfrompk3Execute
    end
    object actionFileLoad: TAction
      Category = 'catFile'
      Caption = '&Load MD3 From File...'
      OnExecute = actionFileLoadExecute
    end
    object actionModelMD3FlipWinding: TAction
      Category = 'catModel'
      Caption = 'Reverse Winding'
      OnExecute = actionModelMD3FlipWindingExecute
    end
    object actionFileSaveAs: TAction
      Category = 'catFile'
      Caption = '&Save As...'
      OnExecute = actionFileSaveAsExecute
    end
    object actionFileExit: TAction
      Category = 'catFile'
      Caption = 'E&xit'
      OnExecute = actionFileExitExecute
    end
    object actionSettingsGamedir: TAction
      Category = 'catSettings'
      Caption = 'Select &Game Path...'
      OnExecute = actionSettingsGamedirExecute
    end
    object actionFileSelectSkin: TAction
      Category = 'catFile'
      Caption = 'From &File...'
      OnExecute = actionFileSelectSkinExecute
    end
    object actionFileClearSkin: TAction
      Category = 'catFile'
      Caption = '&Clear'
      OnExecute = actionFileClearSkinExecute
    end
    object actionFileSelectSkinfrompk3: TAction
      Category = 'catFile'
      Caption = 'From &Game...'
      OnExecute = actionFileSelectSkinfrompk3Execute
    end
    object actionViewShowtags: TAction
      Category = 'catView'
      Caption = 'Show Tags'
      Checked = True
      OnExecute = actionViewShowtagsExecute
    end
    object actionFileAddtoshaderlist: TAction
      Category = 'catFile'
      Caption = 'Add File...'
      OnExecute = actionFileAddtoshaderlistExecute
    end
    object actionFileClearshaderlist: TAction
      Category = 'catFile'
      Caption = 'Clear'
      OnExecute = actionFileClearshaderlistExecute
    end
    object actionHelp: TAction
      Category = 'catHelp'
      Caption = '&Help'
      OnExecute = actionHelpExecute
    end
    object actionFileLoadfrommappk3: TAction
      Category = 'catFile'
      Caption = 'Load MD3 From &PK3...'
      OnExecute = actionFileLoadfrommappk3Execute
    end
    object actionFileAddframe: TAction
      Category = 'catFile'
      Caption = 'Add Frame[0] From...'
      OnExecute = actionFileAddframeExecute
    end
    object actionModelDeleteframe: TAction
      Category = 'catModel'
      Caption = 'Delete Current Frame...'
      OnExecute = actionModelDeleteframeExecute
    end
    object actionModelMDMMDXframesToMD3: TAction
      Category = 'catModel'
      Caption = 'Export Frames-range To MD3'
      OnExecute = actionModelMDMMDXframesToMD3Execute
    end
    object actionFileLoadfromgameMDMMDX: TAction
      Category = 'catFile'
      Caption = 'Load MDM/MDX From Game...'
      OnExecute = actionFileLoadfromgameMDMMDXExecute
    end
    object actionFileLoadMDMMDX: TAction
      Category = 'catFile'
      Caption = 'Load MDM/MDX From File...'
      OnExecute = actionFileLoadMDMMDXExecute
    end
    object actionFileLoadMDS: TAction
      Category = 'catFile'
      Caption = 'Load MDS From File...'
      OnExecute = actionFileLoadMDSExecute
    end
    object actionModelMDMMDXCalculateLOD: TAction
      Category = 'catModel'
      Caption = 'Calculate LOD'
      OnExecute = actionModelMDMMDXCalculateLODExecute
    end
    object actionModelMDMMDXScaleBones: TAction
      Category = 'catModel'
      Caption = 'Scale Weights...'
      OnExecute = actionModelMDMMDXScaleBonesExecute
    end
    object actionFileAddframesequence: TAction
      Category = 'catFile'
      Caption = 'Add frames[0] From Sequence...'
      OnExecute = actionFileAddframesequenceExecute
    end
    object actionFileLoadMDX: TAction
      Category = 'catFile'
      Caption = 'Load MDX From File...'
      OnExecute = actionFileLoadMDXExecute
    end
    object actionModelMD3Scale: TAction
      Category = 'catModel'
      Caption = 'Scale...'
      OnExecute = actionModelMD3ScaleExecute
    end
    object actionFileLoadMDXbones: TAction
      Category = 'catFile'
      Caption = 'Load MDX Bones From File...'
      OnExecute = actionFileLoadMDXbonesExecute
    end
    object actionModelSkinpermanent: TAction
      Category = 'catModel'
      Caption = 'Embed Skin Into Model'
      OnExecute = actionModelSkinpermanentExecute
    end
    object actionModelMDMMDXRenameBones: TAction
      Category = 'catModel'
      Caption = 'Default MDM/MDX Bone-names'
      OnExecute = actionModelMDMMDXRenameBonesExecute
    end
    object actionFileLoadMDMtags: TAction
      Category = 'catFile'
      Caption = 'Load MDM Tags From File...'
      OnExecute = actionFileLoadMDMtagsExecute
    end
    object actionFileLoadMDXframes: TAction
      Category = 'catFile'
      Caption = 'Load MDX Frames From File...'
      OnExecute = actionFileLoadMDXframesExecute
    end
    object actionFileLoadMS3D: TAction
      Category = 'catFile'
      Caption = 'Load MS3D From File...'
      OnExecute = actionFileLoadMS3DExecute
    end
    object actionFileAddframes: TAction
      Category = 'catFile'
      Caption = 'Add All Frames From...'
      OnExecute = actionFileAddframesExecute
    end
    object actionFileImportMapAsMD3: TAction
      Category = 'catFile'
      Caption = 'Load MAP From File...'
      OnExecute = actionFileImportMapAsMD3Execute
    end
    object actionFileLoadAnyFromFile: TAction
      Category = 'catFile'
      Caption = 'Load From File...'
      OnExecute = actionFileLoadAnyFromFileExecute
    end
    object actionViewShowalphapreview: TAction
      Category = 'catView'
      Caption = 'Show Alpha in Preview'
      OnExecute = actionViewShowalphapreviewExecute
    end
    object actionViewShowskeleton: TAction
      Category = 'catView'
      Caption = 'Show Skeleton'
      OnExecute = actionViewShowskeletonExecute
    end
    object actionSettingsCleanup: TAction
      Category = 'catSettings'
      Caption = 'Clean-up'
      Enabled = False
      OnExecute = actionSettingsCleanupExecute
    end
    object actionFileSaveMDX: TAction
      Category = 'catFile'
      Caption = 'Save MDX...'
      OnExecute = actionFileSaveMDXExecute
    end
    object actionFileSaveMDM: TAction
      Category = 'catFile'
      Caption = 'Save MDM...'
      OnExecute = actionFileSaveMDMExecute
    end
    object actionModelMD3FixCracksGaps: TAction
      Category = 'catModel'
      Caption = 'Fix Cracks && Gaps for Current Surface...'
      OnExecute = actionModelMD3FixCracksGapsExecute
    end
    object actionModelMD3SmoothSurface: TAction
      Category = 'catModel'
      Caption = 'Smooth Current Surface'
      OnExecute = actionModelMD3SmoothSurfaceExecute
    end
    object actionModelMD3TagAsOrigin: TAction
      Category = 'catModel'
      Caption = 'Use Pivot-Tag As Origin'
      OnExecute = actionModelMD3TagAsOriginExecute
    end
    object actionViewCenterModel: TAction
      Category = 'catView'
      Caption = 'Center Model'
      OnExecute = actionViewCenterModelExecute
    end
    object actionModelMD3RotateX: TAction
      Category = 'catModel'
      Caption = 'Rotate Model Around X-Axis...'
      OnExecute = actionModelMD3RotateXExecute
    end
    object actionModelMD3RotateY: TAction
      Category = 'catModel'
      Caption = 'Rotate Model Around Y-Axis...'
      OnExecute = actionModelMD3RotateYExecute
    end
    object actionModelMD3RotateZ: TAction
      Category = 'catModel'
      Caption = 'Rotate Model Around Z-Axis...'
      OnExecute = actionModelMD3RotateZExecute
    end
    object actionViewWireframe: TAction
      Category = 'catView'
      Caption = 'Wireframe'
      Checked = True
      OnExecute = actionViewWireframeExecute
    end
    object actionViewTwoSided: TAction
      Category = 'catView'
      Caption = 'TwoSided'
      Checked = True
      OnExecute = actionViewTwoSidedExecute
    end
    object actionViewSmoothFlat: TAction
      Category = 'catView'
      Caption = 'Smooth/Flat'
      Checked = True
      OnExecute = actionViewSmoothFlatExecute
    end
    object actionFileLoadASE: TAction
      Category = 'catFile'
      Caption = 'Load ASE From File...'
      OnExecute = actionFileLoadASEExecute
    end
    object actionViewMouseControl: TAction
      Category = 'catView'
      Caption = 'Mouse Control Type'
      OnExecute = actionViewMouseControlExecute
    end
    object actionModelCalculateNormals: TAction
      Category = 'catModel'
      Caption = 'Recalculate Normals'
      OnExecute = actionModelCalculateNormalsExecute
    end
    object actionModelMDMMDXSmoothSurface: TAction
      Category = 'catModel'
      Caption = 'Smooth Current Surface'
      OnExecute = actionModelMDMMDXSmoothSurfaceExecute
    end
    object actionViewGroundplane: TAction
      Category = 'catView'
      Caption = 'Show Groundplane'
      OnExecute = actionViewGroundplaneExecute
    end
    object actionViewAxis: TAction
      Category = 'catView'
      Caption = 'Show Axis'
      OnExecute = actionViewAxisExecute
    end
    object actionModelMD3SwapUVST: TAction
      Category = 'catModel'
      Caption = 'Swap Texturecoords UV-ST'
      OnExecute = actionModelMD3SwapUVSTExecute
    end
    object actionModelMD3RemoveSurface: TAction
      Category = 'catModel'
      Caption = 'Remove Current Surface'
      OnExecute = actionModelMD3RemoveSurfaceExecute
    end
    object actionModelMD3SurfacesCompact: TAction
      Category = 'catModel'
      Caption = 'Compact'
      OnExecute = actionModelMD3SurfacesCompactExecute
    end
  end
  object MDMOpenDialog: TOpenDialog
    DefaultExt = '.MDM'
    Filter = 'ET playermodel  (.MDM)|*.MDM'
    Title = 'Select a playermodel to load'
    Left = 456
    Top = 64
  end
  object MDXOpenDialog: TOpenDialog
    DefaultExt = '.MDX'
    Filter = 'ET playermodel  animation (.MDX)|*.MDX'
    Title = 'Select a playermodel-animation to load'
    Left = 488
    Top = 64
  end
  object MDSOpenDialog: TOpenDialog
    DefaultExt = '.MDS'
    Filter = 'ET model  (.MDS)|*.MDS'
    Title = 'Select a playermodel to load'
    Left = 520
    Top = 64
  end
  object ImageList: TImageList
    Left = 137
    Top = 64
    Bitmap = {
      494C010121002200040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000009000000001002000000000000090
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      0000808000008080000080808000808080008080800080808000808080008080
      0000808000008080000080800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      000080800000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000808080008080
      8000808000008080000080800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008080000080800000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000808080008080000080800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000C0C0C000C0C0
      C00080800000808000008080000080800000808000008080000080800000C0C0
      C000C0C0C0008080800080800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C000C0C0C0008080
      0000808000008080800080808000C0C0C0008080800080808000808000008080
      0000C0C0C000C0C0C00080800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C000C0C0C0008080
      000080808000C0C0C000FFFFFF00C0C0C00080808000FFFFFF00C0C0C0008080
      000080800000C0C0C000C0C0C000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00C0C0C0008080
      0000C0C0C000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0C0008080
      000080800000C0C0C000C0C0C000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C000C0C0C0008080
      0000C0C0C000FFFFFF0080800000808000008080000080800000808000008080
      0000C0C0C000C0C0C000C0C0C000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00C0C0C0008080
      0000C0C0C000FFFFFF0080808000808000008080000080800000808000008080
      0000C0C0C000C0C0C00080800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C000C0C0C0008080
      0000C0C0C000FFFFFF00C0C0C000808080008080800080808000C0C0C000C0C0
      C000C0C0C0008080000080800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00C0C0C0008080
      000080800000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000808000008080000080800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000C0C0C000C0C0
      C000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000808000008080000080800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      0000FFFFFF00C0C0C000FFFFFF00C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000808000008080000080800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000008000
      0000800000008000000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000000000
      0000000000000000000080000000000000000000000000000000000000000000
      0000000000008080000080808000808000008080800080800000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000000000008000000000000000000000000000000000000000000000008080
      8000808000008080800080000000808080008000000080808000808000008080
      8000808000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000000000000000000000000000000000000000000000808080008080
      0000808080008000000080808000800000008080800080000000808080008080
      0000808080008080000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000000000000000000000000000000000000000000000808000008080
      8000800000008080800080000000808080008000000080808000800000008080
      8000808000008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000008000
      0000800000008000000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000000000008000000000000000000000000000000080800000808080008000
      0000808080008080000080808000808000008080800080800000808080008080
      0000808080008080000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000000000
      00000000000000000000800000000000000000000000C0C0C000808000008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808080008080
      0000808080008080800080808000808080008080800080808000808080008080
      8000C0C0C0008080000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C000808080008080
      8000C0C0C000808080008080800080808000808080008080800080808000C0C0
      C00080808000C0C0C00080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000C0C0C0008080
      800080808000C0C0C00080808000C0C0C0008080800080808000C0C0C0008080
      8000C0C0C00080800000C0C0C000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C00080808000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C00080808000C0C0
      C00080808000C0C0C00080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000FFFF
      FF00C0C0C000FFFFFF00C0C0C000C0C0C000C0C0C000FFFFFF00C0C0C0008080
      8000C0C0C0008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0
      C00080808000C0C0C0000000000000000000000000000000FF00000000000000
      FF00000000000000FF0000000000FFFF00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C000C0C0C000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0C0008080
      8000C0C0C000000000000000000000000000000000000000FF00000000000000
      FF00000000000000FF0000000000FFFF00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0C0000000
      000000000000000000000000000000000000000000000000FF00000000000000
      FF00000000000000FF0000000000FFFF00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000800000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000800000008000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000000000000000080008080800000000000800000000000
      0000800000000000000000000000000000000000000080000000000000000000
      0000000000008000000000000000000080008080800000000000800000000000
      0000000000000000000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000008000000000000000000080008080800000000000800000000000
      0000000000008000000000000000000000000000000000000000800000000000
      0000800000000000000000000000000080008080800000000000000000008000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000000000
      0000000000000000000080000000000000000000000000000000800000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000008000000000000000000000000000000000000000000000008000
      0000000000008000000000000000000080008080800000000000800000000000
      0000000000000000000080000000000000000000000000000000000000008000
      0000000000000000000000000000000080008080800000000000000000000000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000000000
      0000000000000000000080000000000000000000000080000000800000008000
      0000800000008000000000000000000080008080800000000000800000008000
      0000800000008000000080000000000000000000000000000000800000000000
      0000000000008000000000000000000080008080800000000000800000000000
      0000000000008000000000000000000000000000000000000000000000008000
      0000000000000000000000000000000080008080800000000000000000000000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000008000000000000000000000000000000080000000000000000000
      0000000000008000000000000000000080008080800000000000800000000000
      0000800000000000000000000000000000000000000000000000800000000000
      0000800000000000000000000000000080008080800000000000000000008000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000800000000000
      0000000000008000000000000000000080008080800000000000800000008000
      0000000000000000000000000000000000000000000080000000000000000000
      0000000000008000000000000000000080008080800000000000800000000000
      0000000000000000000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000000000008000000000000000000080008080800000000000800000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000008000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      00000000000000FF000000FF0000000000000000000000000000000000000000
      00000000FF000000FF0000000000000000000000000000000000000000000000
      000000000000C0C0C000C0C0C000000000000000000000000000000000008000
      0000000000000000000000000000000080008080800000000000800000000000
      0000000000000000000080000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C0C0C000C0C0C0000000000000000000000000000000000000FF
      000000FF000000FF000000FF0000000000000000000000000000000000000000
      0000000000000000FF000000FF0000000000000000000000000000000000C0C0
      C000C0C0C000C0C0C000C0C0C000000000000000000000000000000000008000
      0000000000000000000000000000000080008080800000000000800000000000
      0000000000000000000080000000000000000000000080000000800000008000
      0000800000008000000000000000000080008080800000000000800000008000
      0000800000008000000080000000000000000000000000000000000000000000
      00000000000000000000C0C0C000C0C0C0000000000000FF000000FF000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF0000000000C0C0C000C0C0C000C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000008000
      0000000000000000000000000000000080008080800000000000000000008000
      0000000000008000000000000000000000000000000000000000800000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C00000FF000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF00C0C0C000C0C0C000C0C0C0000000
      0000000000000000000000000000000000000000000000000000800000000000
      0000800000000000000000000000000080008080800000000000000000000000
      0000800000000000000000000000000000000000000000000000000000008000
      0000000000000000000000000000000080008080800000000000000000000000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000080000000000000000000
      0000000000008000000000000000000080008080800000000000000000000000
      0000800000000000000000000000000000000000000000000000000000000000
      0000800000000000000000000000000080008080800000000000000000008000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000080000000000000000000
      0000000000008000000000000000000080008080800000000000000000000000
      0000800000000000000000000000000000000000000080000000800000008000
      0000800000008000000000000000000080008080800000000000800000008000
      0000800000008000000080000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      FF00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      00000000000000FF000000FF0000000000000000000000000000000000000000
      0000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      000000000000C0C0C000C0C0C000000000000000000000000000000000000000
      00000000FF000000FF0000000000000000000000000000000000000000000000
      00000000000000FF000000FF0000000000000000000000000000000000000000
      00000000FF000000FF0000000000000000000000000000000000000000000000
      000000000000C0C0C000C0C0C000000000000000000000000000000000000000
      000000000000C0C0C000C0C0C0000000000000000000000000000000000000FF
      000000FF000000FF000000FF0000000000000000000000000000000000000000
      000000000000C0C0C000C0C0C00000000000000000000000000000000000C0C0
      C000C0C0C000C0C0C000C0C0C000000000000000000000000000000000000000
      0000000000000000FF000000FF000000000000000000000000000000000000FF
      000000FF000000FF000000FF0000000000000000000000000000000000000000
      0000000000000000FF000000FF0000000000000000000000000000000000C0C0
      C000C0C0C000C0C0C000C0C0C000000000000000000000000000000000000000
      00000000000000000000C0C0C000C0C0C0000000000000FF000000FF000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      00000000000000000000C0C0C000C0C0C00000000000C0C0C000C0C0C000C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000000000FF000000FF000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF0000000000C0C0C000C0C0C000C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C00000FF000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C000C0C0C000C0C0C0000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF0000FF000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF00C0C0C000C0C0C000C0C0C0000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000808080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000808080008080800080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF0000000000000000000000000080808000808080008080
      8000808080000000000000000000808080008080800080808000000000000000
      00008080800080808000000000000000000000000000000000000000FF000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF000000000000000000000000008080800080808000C0C0
      C000808080008080800000000000808080008080800080808000000000008080
      8000808080008080800000000000000000000000000000000000000000000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF0000000000000000000000000000000000808080008080
      8000C0C0C000808080008080800080808000808080008080800080808000C0C0
      C000808080008080800000000000000000000000000000000000000000000000
      00000000FF000000FF0000000000000000000000000000000000000000000000
      00000000000000FF000000FF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      800080808000C0C0C00080808000C0C0C0008080800080808000C0C0C0008080
      8000808080008080800000000000000000000000000000000000000000000000
      0000000000000000FF000000FF000000000000000000000000000000000000FF
      000000FF000000FF000000FF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008080
      80008080800080808000C0C0C000C0C0C000C0C0C000C0C0C000808080008080
      8000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000000000FF000000FF000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000C0C0C0008080
      800080808000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008080
      8000808080008080800080808000808080000000000000000000000000000000
      00000000000000000000000000000000FF0000FF000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFF0000FFFF0000FFFF
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000808080008080
      800080808000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000808080008080
      8000C0C0C0008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFF0000FFFF0000FFFF
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00008080800080808000C0C0C000C0C0C000C0C0C000C0C0C000808080008080
      8000808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFF0000FFFF0000FFFF
      000000000000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008080
      800080808000C0C0C00080808000808080008080800080808000C0C0C0008080
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFF000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080808000C0C0
      C00080808000808080000000000080808000808080008080800080808000C0C0
      C000808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFF0000FFFF0000FFFF00000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF000000000000FFFF00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008080
      8000808080000000000080808000C0C0C0008080800000000000808080008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFF0000FFFF0000FFFF00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFF00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008080
      8000000000000000000080808000C0C0C0008080800000000000000000008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFF0000FFFF0000FFFF00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFF0000FFFF0000FFFF00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000808080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C0C0C000FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C0C0C000C0C0C000FFFFFF00FFFFFF00C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C000C0C0C000C0C0C000FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000008000000000000000
      0000000000000000000000008000000000000000000000008000000000000000
      0000000080000000800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00C0C0C000000000000000000000000000FFFFFF00808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000000000000000000000008000000000000000
      0000000000000000000000008000000000000000000000008000000000000000
      8000000000000000000000008000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000FFFFFF000000FF000000FF0000000000C0C0
      C000FFFFFF00C0C0C000C0C0C0000000000000000000FFFFFF000000FF00C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00080808000000000000000000000008000000000000000
      0000000000000000000000008000000000000000000000008000000000000000
      8000000000000000000000008000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000FFFFFF00FFFFFF000000FF00000000000000
      FF00C0C0C000C0C0C000C0C0C0000000000000000000FFFFFF00C0C0C000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C000C0C0C00080808000000000000000000000008000000000000000
      0000000000000000000000008000000000000000800000000000000000000000
      0000000000000000000000008000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0
      C000C0C0C00000000000C0C0C0000000000000000000FFFFFF00C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00080808000000000000000000000008000000080000000
      8000000000000000000000008000000000000000800000000000000000000000
      0000000000000000000000008000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00C0C0C0000000000000000000FFFFFF00C0C0C000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C000C0C0C00080808000000000000000000000008000000000000000
      0000000080000000000000008000000080000000000000000000000000000000
      0000000000000000800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00080808000000000000000000000008000000000000000
      0000000080000000000000008000000000000000800000000000000000000000
      0000000080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C000C0C0C000C0C0
      C000C0C0C000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00080808000000000000000000000008000000000000000
      0000000080000000000000008000000000000000800000000000000000000000
      0000000000000000800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C000C0C0C00000000000C0C0
      C000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000008000000000000000
      0000000080000000000000008000000000000000000000008000000000000000
      0000000000000000000000008000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000008000000080000000
      8000000000000000000000008000000000000000000000008000000000000000
      8000000080000000800000008000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000C0C0C000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C0C0C000C0C0C000FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080000000
      0000808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000000000000000000000000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C0000000
      0000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF008080800080808000808080008080800080808000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF00000000000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000C0C0C00000000000C0C0C00000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF00000000000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000C0C0C000000000008080800000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000C0C0C00000000000C0C0C00000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF00000000000000FF00000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000C0C0C000000000008080800000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF00000000000000FF00000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000C0C0C00000000000C0C0C00000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF00000000000000FF00000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000000000000C0C0C00000000000FF000000FF000000FF00
      00000000FF00FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000C0C0C000000000008080800000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF0000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000C0C0C00000000000C0C0C00000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF00000000000000FF00000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000FFFFFF0000000000FFFFFF00000000000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000C0C0C000000000008080800000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF0000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000808080000000000080808000000000008080800000000000808080000000
      00000000000000000000000000000000000000000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF0000000000
      0000000000000000000000000000FF0000000000000000000000000000000000
      0000FF000000FF000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF000000000000000000000000000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00C0C0C000C0C0C000C0C0C000808080008080800080808000808080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000C0C0
      C000FFFFFF0000000000FFFFFF00000000000000000000000000808080000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF0000000000000000000000FF0000000000000000000000FF0000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000FF000000FF000000FF000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080808000808080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF00000000000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      0000000000000000000000000000000000000000000000000000808080000000
      0000C0C0C0008080800080808000000000008080800080808000000000008080
      8000808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C00000000000C0C0C00000000000C0C0C0000000FF000000FF000000FF00C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      FF00000000000000000000000000000000000000000080808000C0C0C0008080
      800080808000808080008080800080808000808080000000000080808000C0C0
      C000C0C0C000C0C0C00080808000000000000000FF0000000000000000000000
      00000000FF00000000000000000000000000000000000000FF00000000000000
      000000000000000000008080800000000000000000000000000000000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000000000000000000000000000000080808000808080008080
      80008080800000000000C0C0C00080808000808080000000000080808000C0C0
      C000C0C0C000C0C0C0008080800000000000000000000000FF00000000000000
      00000000FF0000000000000000000000000000000000000000000000FF000000
      000000000000808080000000FF0000000000000000000000000000000000C0C0
      C00000000000C0C0C00000000000C0C0C00000000000C0C0C00000000000C0C0
      C0000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF0000000000000000000000000080808000C0C0C0008080
      80008080800080808000FFFFFF0080808000C0C0C00000000000C0C0C0008080
      8000C0C0C000C0C0C000808080000000000000000000808080000000FF008080
      80000000FF000000000000000000000000000000000000000000808080000000
      FF00808080000000FF000000000000000000000000000000000000000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C0000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000080808000C0C0C0008080
      8000808080000000000000000000000000000000000000000000000000008080
      800080808000C0C0C000808080000000000000000000000000000000FF000000
      FF00000000000000000000000000000000000000000000000000000000000000
      FF000000FF00000000000000000000000000000000000000000000000000C0C0
      C00000000000C0C0C00000000000C0C0C00000000000C0C0C00000000000C0C0
      C0000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF00000000000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF0000000000000000000000000080808000C0C0C0008080
      800080808000C0C0C000C0C0C00080808000C0C0C000C0C0C000808080008080
      800080808000C0C0C000808080000000000000000000000000000000FF000000
      FF00000000000000FF000000000000000000000000000000FF00000000000000
      FF000000FF00000000000000000000000000000000000000000000000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C0000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000000000000000000000000000000080808000C0C0C000C0C0
      C000C0C0C000808080000000FF000000FF000000FF000000FF0080808000C0C0
      C000C0C0C000C0C0C0008080800000000000000000000000FF000000FF000000
      FF000000FF0000000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF0000000000000000000000000000000000C0C0
      C00000000000C0C0C00000000000C0C0C00000000000C0C0C00000000000C0C0
      C0000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000FF000000
      FF00000000000000000000000000000000000000000080808000C0C0C000C0C0
      C000C0C0C000808080000000FF0080808000808080000000FF00808080008080
      8000C0C0C000C0C0C00080808000000000000000FF00000000000000FF000000
      FF00000000000000000000000000000000000000000000000000000000000000
      00000000FF00000000000000000000000000000000000000000000000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C0000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000FF000000
      0000000000000000000000000000000000000000000080808000808080000000
      800080808000808080000000FF0080808000C0C0C0000000FF00808080000000
      8000808080008080800080808000000000000000000000000000000000000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000000000000000000000000000000000000000C0C0
      C00000000000000000000000000000000000000000000000000000000000C0C0
      C0000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008080000080808000C0C0
      C000C0C0C0000000FF000000FF00C0C0C000808080000000FF00808080008080
      8000808080008080800000008000000000000000000000000000000000000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000000000000000000000000000000000000000C0C0
      C000000000000000000000000000FFFF000000000000FFFF000000000000C0C0
      C0000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF00C0C0C0000000
      FF00C0C0C000C0C0C000C0C0C0008080800080808000C0C0C000C0C0C000C0C0
      C000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C00000000000000000000000000000000000000000000000000000000000C0C0
      C0000000000000000000000000000000000000000000FFFFFF0000000000C0C0
      C000FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000080808000C0C0C00080808000C0C0
      C0000000FF000000FF000000FF00C0C0C000C0C0C0000000FF000000FF000000
      FF00C0C0C00080808000C0C0C000808080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C0000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000808080008080
      80008080800000000000C0C0C0000000FF000000FF00C0C0C000000080008080
      8000808080008080800080808000808080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008080
      8000808080008080800000000000808080008080800000000000808080008080
      8000808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000900000000100010000000000800400000000000000000000
      000000000000000000000000FFFFFF00FFFF0000000000008001000000000000
      8001000000000000800100000000000080010000000000008001000000000000
      8001000000000000800100000000000080010000000000008001000000000000
      8001000000000000800100000000000080010000000000008001000000000000
      8001000000000000FFFF000000000000FFFFFFFFFFFFFFFFFFC1FFDDF81FFFC1
      FFEFFFEBE007FFC1FFF7FFF7C003FFC1FFFBFFF7C003FFC1FFC1FFEB8001FFC1
      FFFFFFDD8001FFFFFFFFFFFF8001FFF7FFFFFFFF8001FFE3F81FF81F8001FFC1
      C7E3C7E38001FF80BFFDBFFDC0030063BFBDBFBDC0030063CF03CF03E0070063
      FFBFFFBFF81F0047FFFFFFFFFFFF007FFE7FFE7FFE7FFFFFFE7FFE7FFE7FFFF7
      FE7FFE5FFE7FFFF7FE7FFE4FFE7FFFF7FE7FFA57BA5DFFEBFE7FF25BD66BFFDD
      DE7BEA5DEE77FFDD8241DA5BEE77FFFFDE7BBA57D66BFFFFFE7FDA4FBA5DF81F
      FE7FEA5FFE7FC7E3FE7FF27FFE7FBFFDFE7FFA7FFE7FBFBDFE7FFE7FFE7FCF03
      FEFFFEFFFEFFFFBFFFFFFFFFFFFFFFFFFFFFFFFFFE7FFE7FFFFFFFFFFE7FFE7F
      CFFFCFFFFE7FFE7FE7FFE7FFFE7FFE7FF3F9F3F9EE5DFE7FF9E1F9E1EE5D8241
      FC87FC87EE6BDE7BFE1FFE1FD677EE77FE7FFE7FBA77F66FFE7FFE7FBA778241
      FE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7F
      FE7FFE7FFEFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      CFFFCFFFCFFFCFFFE7FFE7FFE7FFE7FFF3F9F3F9F3F9F3F9F9E1F9E1F9E1F9E1
      FC87FC87FC87FC87FE1FFE1FFE1FFE1FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7F
      FE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7FFE7F
      FE7FFE7FFE7FFE7FFFFFFFFFFFFFFFFFFFFFFFFFFE7FFFFFFFC1FFC1FE3FFFFF
      FFC1FFC18633CFFFFFC1FFC18223E7FFFFC1FFC1C003F3F9FFC1FFC1E003F9E1
      FFFFFFFFC00FFC87FFF707F78000FE1FFFE307E30001FE7FFFC101C1F003FE7F
      FF800180C007FE7FF0630063C203FE7FF063C063C441FE7FF063C063CC61FE7F
      F047F047FE7FFE7FF07FF07FFF7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFFFFFF
      FFFF8201F83FFFFFFFFFC703F00F0000BDB3EFCFC0030000BDADEFCFC0210000
      BDADC7CF80210000BD7DC787800500008D7DEF0380010000B4FBFF0380010000
      B577FF0380010000B57BFF0320010000B5BDFF87C00300008DA1FFCFC007FFFF
      FFFFFFFFF80FFFFFFFFFFFFFFFFFFFFFFF00FFFFE00FF93FFF00FFFFE00FFD7F
      FF00C007E00FFD7FFF00E7E7E00FFD7F0000F3F7E00FFD7F0000F9F7E00FFD7F
      0000FCFFE00FFD7F0000FE7FA00BFC7F0023FF3FC007FC7F0001FE7FE00FFEFF
      0000FCFFE00FBEFB0023F9F7C0079EF30063F3F7C007EEEF00C3E7E7C007F6DF
      0107C007F83FF83F03FFFFFFF83FFEFFFFFF8000C007FFDFE03F5555C007FFCF
      80010000C007FFC7800176BCC00700038001B6D8C0070001800186C2C0070000
      8001CEE6C00700018001CAA6C0070003800186C0C007000780014EF6C007000F
      8001E6F2C007001F8001E6F2C007007F0000FEFEC00700FF00000000C00701FF
      00005555C00703FF80010000C007FFFF00000000000000000000000000000000
      000000000000}
  end
  object ColorDialog: TColorDialog
    Left = 232
    Top = 64
  end
  object OpenDialogMD3s: TOpenDialog
    DefaultExt = '.MD3'
    Filter = 'Quake 3 models  (.MD3)|*.MD3'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Select multiple models sequence'
    Left = 552
    Top = 64
  end
  object MDXSaveDialog: TSaveDialog
    DefaultExt = '.MDX'
    Filter = 'ET playermodel  animation (.MDX)|*.MDX'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofNoLongNames, ofEnableSizing]
    Title = 'Select a playermodel-animation to save'
    Left = 713
    Top = 65
  end
  object MS3DOpenDialog: TOpenDialog
    DefaultExt = '.MS3D'
    Filter = 'MilkShape model  (.ms3d)|*.ms3d'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Select a MilkShape model to load'
    Left = 424
    Top = 64
  end
  object MapOpenDialog: TOpenDialog
    DefaultExt = '.MAP'
    Filter = 'Quake Map (.map)|*.map'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Select a map to load'
    Left = 584
    Top = 64
  end
  object OpenDialogAnyFromFile: TOpenDialog
    Filter = 
      'All Supported Models|*.MD3;*.MDM;*.MDX;*.MDS;*.MAP;*.MS3D;*.ASE|' +
      'Quake3 Model  (.MD3)|*.MD3|ET Player Model  (.MDM)|*.MDM|ET Play' +
      'er Animation  (.MDX)|*.MDX|ET Player Animation Bones  (.MDX)|*.M' +
      'DX|ET Player Animation Frames  (.MDX)|*.MDX|ET Player Animation ' +
      'Tags  (.MDX)|*.MDX|ET Model  (.MDS)|*.MDS|Quake Map  (.MAP)|*.MA' +
      'P|MilkShape Model  (.MS3D)|*.MS3D|3DSMax ASCII (.ASE)|*.ASE|Mode' +
      'l Skin  (*.skin)|*.skin|Model Tags  (*.tag)|*.tag|Shader-file  (' +
      '.shader)|*.shader'
    Left = 264
    Top = 64
  end
  object ASEOpenDialog: TOpenDialog
    DefaultExt = '.ASE'
    Filter = '3DSMax ASCII Model (.ase)|*.ase'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Select a model to load'
    Left = 616
    Top = 65
  end
  object TimerOGLFPS: TTimer
    OnTimer = TimerOGLFPSTimer
    Left = 72
    Top = 64
  end
  object PK3OpenDialog: TOpenDialog
    DefaultExt = '.PK3'
    Filter = 'Game PAK Files (.pk3)|*.pk3'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Select a game PAK file'
    Left = 648
    Top = 65
  end
end
