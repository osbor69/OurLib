inherited EdSchem: TEdSchem
  Left = 286
  Top = 116
  Width = 842
  Height = 621
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072
  Menu = KeyMenu1
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    Width = 707
    Height = 500
    Schem = ''
    inherited KeyLb1: TKeyLb
      Top = 459
      NmProc.Strings = (
        'F10#'#1057#1086#1093#1088#1072#1085#1080#1090#1100'##FILE'
        'Esc#'#1054#1090#1084#1077#1085#1072'##FILE'
        'Alt_Home#'#1055#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102'#'#1059#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102'#EDIT'
        'F4#'#1048#1082#1086#1085#1082#1072'#'#1048#1079#1084#1077#1085#1080#1090#1100' '#1080#1082#1086#1085#1082#1091'#EDIT'
        'Ctrl_F4##'#1059#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1080#1082#1086#1085#1082#1091' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102'#EDIT'
        'Ctrl_F3##'#1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1085#1072#1089#1090#1088#1086#1081#1082#1080' '#1080#1079' '#1076#1088#1091#1075#1086#1081' '#1087#1072#1087#1082#1080'#FILE')
    end
    inherited RbPanel2: TRbPanel
      Top = 14
      Width = 685
      Height = 432
      Schem = ''
      BevelOuter = bvNone
      Place = rpTop
      object pnPg: TRbPanel
        Left = 21
        Top = 8
        Width = 658
        Height = 346
        MinSized = False
        ParentSchem = True
        CanSize = False
        CanMove = False
        MaxWidth = False
        ProcentWnd = 80
        SortMode = smDefault
        SortObj = True
        BevelOuter = bvLowered
        HMin = 0
        Place = rpNone
        SayRight = False
        TabOrder = 0
        WMin = 0
        object RbPage1: TRbPage
          Left = 8
          Top = 8
          Width = 642
          Height = 332
          ActivePage = tsSch
          TabOrder = 0
          CngByCtrl = True
          object tsSch: TTabSheet
            Caption = #1062#1074#1077#1090#1072' '#1080' '#1096#1088#1080#1092#1090#1099
            object pnSch: TRbPanel
              Left = 8
              Top = 8
              Width = 495
              Height = 219
              MinSized = False
              ParentSchem = True
              CanSize = False
              CanMove = False
              MaxWidth = False
              ProcentWnd = 100
              SortMode = smDefault
              SortObj = True
              BevelOuter = bvNone
              HMin = 0
              Place = rpLeft
              SayRight = False
              TabOrder = 0
              WMin = 0
              object PnList: TRbPanel
                Left = 8
                Top = 0
                Width = 169
                Height = 220
                MinSized = False
                ParentSchem = True
                CanSize = False
                CanMove = False
                MaxWidth = False
                ProcentWnd = 0
                SortMode = smDefault
                SortObj = True
                BevelOuter = bvLowered
                HMin = 0
                Place = rpLeft
                SayRight = False
                TabOrder = 0
                WMin = 0
                object PnList1: TRbPanel
                  Left = 0
                  Top = 8
                  Width = 168
                  Height = 198
                  MinSized = False
                  ParentSchem = True
                  CanSize = False
                  CanMove = False
                  MaxWidth = False
                  ProcentWnd = 100
                  SortMode = smDefault
                  SortObj = True
                  BevelOuter = bvNone
                  HMin = 200
                  Place = rpNone
                  SayRight = False
                  TabOrder = 0
                  WMin = 178
                  OnResize = PnList1Resize
                end
              end
              object PnEdit: TRbPanel
                Left = 184
                Top = -14
                Width = 332
                Height = 234
                MinSized = False
                ParentSchem = True
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -13
                Font.Name = 'Courier New'
                Font.Style = [fsBold]
                ParentFont = False
                CanSize = False
                CanMove = False
                MaxWidth = False
                ProcentWnd = 100
                SortMode = smDefault
                SortObj = True
                BevelOuter = bvNone
                HMin = 0
                Place = rpLeft
                SayRight = False
                TabOrder = 1
                WMin = 0
                object PnEdit1: TPanelEdit
                  Left = 8
                  Top = 8
                  Width = 318
                  Height = 212
                  MinSized = False
                  ParentSchem = True
                  CanSize = False
                  CanMove = False
                  MaxWidth = False
                  ProcentWnd = 100
                  SortMode = smDefault
                  SortObj = True
                  BevelOuter = bvNone
                  HMin = 419
                  Place = rpTop
                  SayRight = False
                  TabOrder = 0
                  WMin = 369
                  OnEnter = PnEdit1Enter
                  OnExit = PnEdit1Exit
                  Options = [peCheckOnExit]
                  OnEscape = PnEdit1Escape
                  OnValid = PnEdit1Valid
                  object PnColor: TRbPanel
                    Left = 0
                    Top = 14
                    Width = 269
                    Height = 93
                    MinSized = False
                    ParentSchem = True
                    OnSetWHMin = PnColorSetWHMin
                    CanSize = False
                    CanMove = False
                    MaxWidth = False
                    Header = #1062#1074#1077#1090#1072
                    ProcentWnd = 0
                    SortMode = smColumns
                    SortObj = True
                    BevelOuter = bvLowered
                    HMin = 0
                    Place = rpNone
                    SayRight = False
                    TabOrder = 0
                    WMin = 0
                    object EColW: TFldEdit
                      Left = 176
                      Top = 21
                      Width = 86
                      Height = 26
                      MinSized = False
                      ParentSchem = True
                      Font.Charset = DEFAULT_CHARSET
                      Font.Color = clBlack
                      Font.Height = -13
                      Font.Name = 'Courier New'
                      Font.Style = []
                      ParentFont = False
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'Schem'
                      NameRecFld = 'ColorW'
                      Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
                      Vid = 'TColorGet'
                      VName = 'Color'
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1086#1082#1085#1086' '
                      SayRight = False
                      TabOrder = 0
                      TabStop = True
                    end
                    object ECol1: TFldEdit
                      Left = 176
                      Top = 42
                      Width = 86
                      Height = 26
                      MinSized = False
                      ParentSchem = True
                      Font.Charset = DEFAULT_CHARSET
                      Font.Color = clBlack
                      Font.Height = -13
                      Font.Name = 'Courier New'
                      Font.Style = []
                      ParentFont = False
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'Schem'
                      NameRecFld = 'Color1'
                      Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
                      Vid = 'TColorGet'
                      VName = 'Color'
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1086#1089#1085#1086#1074#1085#1086#1081' '
                      SayRight = False
                      TabOrder = 1
                      TabStop = True
                    end
                    object ECol2: TFldEdit
                      Left = 176
                      Top = 64
                      Width = 86
                      Height = 26
                      MinSized = False
                      ParentSchem = True
                      Font.Charset = DEFAULT_CHARSET
                      Font.Color = clBlack
                      Font.Height = -13
                      Font.Name = 'Courier New'
                      Font.Style = []
                      ParentFont = False
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'Schem'
                      NameRecFld = 'Color2'
                      Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
                      Vid = 'TColorGet'
                      VName = 'Color'
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1076#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1099#1081' '
                      SayRight = False
                      TabOrder = 2
                      TabStop = True
                    end
                  end
                  object PnFont: TRbPanel
                    Left = 8
                    Top = 113
                    Width = 261
                    Height = 100
                    MinSized = False
                    ParentSchem = True
                    CanSize = False
                    CanMove = False
                    MaxWidth = False
                    Header = #1064#1088#1080#1092#1090#1099
                    ProcentWnd = 100
                    SortMode = smColumns
                    SortObj = True
                    BevelOuter = bvLowered
                    HMin = 0
                    Place = rpNone
                    SayRight = False
                    TabOrder = 1
                    WMin = 0
                    object EFontW: TFldEdit
                      Left = 148
                      Top = 20
                      Width = 86
                      Height = 26
                      MinSized = False
                      ParentSchem = True
                      Color = clWindow
                      Font.Charset = DEFAULT_CHARSET
                      Font.Color = clBlack
                      Font.Height = -13
                      Font.Name = 'Courier New'
                      Font.Style = []
                      ParentFont = False
                      CharCase = ecNormal
                      CharWidth = -1
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'Schem'
                      NameRecFld = 'FONTW'
                      Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
                      Vid = 'TButGet'
                      VName = 'SchFont'
                      ParentShowHint = False
                      ShowHint = True
                      SayRight = False
                      TabOrder = 0
                      TabStop = True
                    end
                    object EFont1: TFldEdit
                      Left = 162
                      Top = 49
                      Width = 86
                      Height = 26
                      MinSized = False
                      ParentSchem = True
                      Color = clWindow
                      Font.Charset = DEFAULT_CHARSET
                      Font.Color = clBlack
                      Font.Height = -13
                      Font.Name = 'Courier New'
                      Font.Style = []
                      ParentFont = False
                      CharCase = ecNormal
                      CharWidth = -1
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'Schem'
                      NameRecFld = 'FONT1'
                      Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
                      Vid = 'TButGet'
                      VName = 'SchFont'
                      ParentShowHint = False
                      ShowHint = True
                      SayRight = False
                      TabOrder = 1
                      TabStop = True
                    end
                    object EFont2: TFldEdit
                      Left = 169
                      Top = 70
                      Width = 86
                      Height = 26
                      MinSized = False
                      ParentSchem = True
                      Color = clWindow
                      Font.Charset = DEFAULT_CHARSET
                      Font.Color = clBlack
                      Font.Height = -13
                      Font.Name = 'Courier New'
                      Font.Style = []
                      ParentFont = False
                      CharCase = ecNormal
                      CharWidth = -1
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'Schem'
                      NameRecFld = 'FONT2'
                      Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
                      Vid = 'TButGet'
                      VName = 'SchFont'
                      ParentShowHint = False
                      ShowHint = True
                      SayRight = False
                      TabOrder = 2
                      TabStop = True
                    end
                  end
                end
              end
            end
          end
          object tsKey: TTabSheet
            Caption = #1050#1083#1072#1074#1080#1096#1080
            ImageIndex = 1
            object pnKey: TPanelEdit
              Left = 8
              Top = 8
              Width = 615
              Height = 296
              MinSized = False
              ParentSchem = True
              CanSize = False
              CanMove = False
              MaxWidth = False
              ProcentWnd = 100
              SortMode = smColumns
              SortObj = True
              BevelOuter = bvLowered
              HMin = 0
              Place = rpNone
              SayRight = False
              TabOrder = 0
              WMin = 0
              OnEnter = pnKeyEnter
              OnExit = pnKeyExit
              MasterControl = EKeyNul
              Options = [peCheckOnExit]
              OnEscape = pnKeyEscape
              OnValid = pnKeyValid
              object EType: TFldEdit
                Left = 35
                Top = 8
                Width = 63
                Height = 25
                MinSized = False
                ParentSchem = True
                CharCase = ecNormal
                CharWidth = 0
                CharHeight = 0
                MaxLength = 0
                NameRec = 'Schem'
                NameRecFld = 'TYPE'
                Value = '0'
                Vid = 'TMenuGet'
                VName = 'ButType'
                OnChange = ETypeChange
                ParentShowHint = False
                ShowHint = True
                SayCaption = ' '#1058#1080#1087' '
                SayRight = False
                TabOrder = 0
                TabStop = True
              end
              object EWidth: TFldEdit
                Left = 71
                Top = 56
                Width = 60
                Height = 25
                MinSized = False
                ParentSchem = True
                CharCase = ecNormal
                CharWidth = 0
                CharHeight = 0
                Mask = '0,10'
                MaxLength = 0
                NameRec = 'Schem'
                NameRecFld = 'WIDTH'
                Value = '0'
                Vid = 'TSpinGet'
                OnChange = EWidthChange
                ParentShowHint = False
                ShowHint = True
                SayCaption = ' '#1058#1086#1083#1097#1080#1085#1072' '#1075#1088#1072#1085#1080#1094#1099' '
                SayRight = False
                TabOrder = 1
                TabStop = True
              end
              object EInverted: TFldEdit
                Left = 184
                Top = 27
                Width = 261
                Height = 25
                MinSized = False
                ParentSchem = True
                CharCase = ecNormal
                CharWidth = 0
                CharHeight = 0
                Mask = #1055#1086#1084#1077#1085#1103#1090#1100' '#1090#1077#1082#1089#1090' '#1082#1083#1072#1074#1080#1096#1080' '#1080' '#1076#1077#1081#1089#1090#1074#1080#1103
                MaxLength = 0
                NameRec = 'Schem'
                NameRecFld = 'INVERTED'
                Value = 'F'
                Vid = 'TBoolGet'
                OnChange = EInvertedChange
                ParentShowHint = False
                ShowHint = True
                SayRight = False
                TabOrder = 2
                TabStop = True
              end
              object pnHotKey: TRbPanel
                Left = 14
                Top = 85
                Width = 395
                Height = 85
                MinSized = True
                ParentSchem = True
                CanSize = False
                CanMove = False
                MaxWidth = False
                Header = #1050#1083#1072#1074#1080#1096#1072
                ProcentWnd = 0
                SortMode = smColumns
                SortObj = True
                BevelInner = bvRaised
                BevelOuter = bvLowered
                HMin = 0
                Place = rpNone
                SayRight = False
                TabOrder = 3
                WMin = 0
                object EHotKeyFont: TFldEdit
                  Left = 78
                  Top = 14
                  Width = 29
                  Height = 25
                  MinSized = False
                  ParentSchem = True
                  CharCase = ecNormal
                  CharWidth = 0
                  CharHeight = 0
                  Mask = '4'
                  MaxLength = 0
                  NameRec = 'Schem'
                  NameRecFld = 'HOTKEYFONT'
                  Vid = 'TButGet'
                  VName = 'ButFont'
                  OnChange = EFontChange
                  ParentShowHint = False
                  ShowHint = True
                  SayCaption = ' '#1096#1088#1080#1092#1090' '
                  SayRight = False
                  TabOrder = 0
                  TabStop = True
                end
                object EHotKeyColor: TFldEdit
                  Left = 101
                  Top = 35
                  Width = 86
                  Height = 26
                  MinSized = False
                  ParentSchem = True
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clBlack
                  Font.Height = -13
                  Font.Name = 'Courier New'
                  Font.Style = []
                  ParentFont = False
                  CharCase = ecNormal
                  CharWidth = 0
                  CharHeight = 0
                  MaxLength = 0
                  NameRec = 'Schem'
                  NameRecFld = 'HOTKEYCOLOR'
                  Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
                  Vid = 'TColorGet'
                  VName = 'Color'
                  OnChange = EColorChange
                  ParentShowHint = False
                  ShowHint = True
                  SayCaption = ' '#1094#1074#1077#1090' '
                  SayRight = False
                  TabOrder = 1
                  TabStop = True
                end
                object EUnderBut: TFldEdit
                  Left = 9
                  Top = 49
                  Width = 86
                  Height = 25
                  MinSized = False
                  ParentSchem = True
                  CharCase = ecNormal
                  CharWidth = -1
                  CharHeight = 0
                  Mask = #1056#1072#1089#1087#1086#1083#1086#1078#1080#1090#1100' '#1087#1086#1076' '#1076#1077#1081#1089#1090#1074#1080#1077#1084
                  MaxLength = 0
                  NameRec = 'Schem'
                  NameRecFld = 'UNDERBUT'
                  Value = 'F'
                  Vid = 'TBoolGet'
                  OnChange = EUnderButChange
                  ParentShowHint = False
                  ShowHint = True
                  SayRight = False
                  TabOrder = 2
                  TabStop = True
                end
                object EAlignment: TFldEdit
                  Left = 304
                  Top = 21
                  Width = 88
                  Height = 55
                  MinSized = False
                  ParentSchem = True
                  CharCase = ecNormal
                  CharWidth = 0
                  CharHeight = 0
                  MaxLength = 0
                  NameRec = 'Schem'
                  NameRecFld = 'ALIGNMENT'
                  Value = '1'
                  Vid = 'TRadioGet'
                  VName = 'ButAlignment'
                  OnChange = EAlignmentChange
                  ParentShowHint = False
                  ShowHint = True
                  SayRight = False
                  TabOrder = 3
                  TabStop = True
                end
              end
              object pnAF: TRbPanel
                Left = 212
                Top = 148
                Width = 156
                Height = 65
                MinSized = True
                ParentSchem = True
                CanSize = False
                CanMove = False
                MaxWidth = False
                Header = #1054#1073#1099#1095#1085#1086#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
                ProcentWnd = 0
                SortMode = smColumns
                SortObj = True
                BevelInner = bvRaised
                BevelOuter = bvLowered
                HMin = 0
                Place = rpNone
                SayRight = False
                TabOrder = 4
                WMin = 0
                object EAFFont: TFldEdit
                  Left = 64
                  Top = 14
                  Width = 29
                  Height = 25
                  MinSized = False
                  ParentSchem = True
                  CharCase = ecNormal
                  CharWidth = 0
                  CharHeight = 0
                  Mask = '0'
                  MaxLength = 0
                  NameRec = 'Schem'
                  NameRecFld = 'AFFONT'
                  Vid = 'TButGet'
                  VName = 'ButFont'
                  OnChange = EFontChange
                  ParentShowHint = False
                  ShowHint = True
                  SayCaption = ' '#1096#1088#1080#1092#1090' '
                  SayRight = False
                  TabOrder = 0
                  TabStop = True
                end
                object EAFColor: TFldEdit
                  Left = 66
                  Top = 35
                  Width = 86
                  Height = 26
                  MinSized = False
                  ParentSchem = True
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clBlack
                  Font.Height = -13
                  Font.Name = 'Courier New'
                  Font.Style = []
                  ParentFont = False
                  CharCase = ecNormal
                  CharWidth = 0
                  CharHeight = 0
                  MaxLength = 0
                  NameRec = 'Schem'
                  NameRecFld = 'AFCOLOR'
                  Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
                  Vid = 'TColorGet'
                  VName = 'Color'
                  OnChange = EColorChange
                  ParentShowHint = False
                  ShowHint = True
                  SayCaption = ' '#1094#1074#1077#1090' '
                  SayRight = False
                  TabOrder = 1
                  TabStop = True
                end
              end
              object pnAP: TRbPanel
                Left = 395
                Top = 148
                Width = 156
                Height = 65
                MinSized = True
                ParentSchem = True
                CanSize = False
                CanMove = False
                MaxWidth = False
                Header = #1042#1099#1087#1086#1083#1085#1103#1077#1084#1086#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
                ProcentWnd = 0
                SortMode = smColumns
                SortObj = True
                BevelInner = bvRaised
                BevelOuter = bvLowered
                HMin = 0
                Place = rpNone
                SayRight = False
                TabOrder = 5
                WMin = 0
                object EAPFont: TFldEdit
                  Left = 64
                  Top = 14
                  Width = 29
                  Height = 25
                  MinSized = False
                  ParentSchem = True
                  CharCase = ecNormal
                  CharWidth = 0
                  CharHeight = 0
                  Mask = '1'
                  MaxLength = 0
                  NameRec = 'Schem'
                  NameRecFld = 'APFONT'
                  Vid = 'TButGet'
                  VName = 'ButFont'
                  OnChange = EFontChange
                  ParentShowHint = False
                  ShowHint = True
                  SayCaption = ' '#1096#1088#1080#1092#1090' '
                  SayRight = False
                  TabOrder = 0
                  TabStop = True
                end
                object EAPColor: TFldEdit
                  Left = 66
                  Top = 35
                  Width = 86
                  Height = 26
                  MinSized = False
                  ParentSchem = True
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clBlack
                  Font.Height = -13
                  Font.Name = 'Courier New'
                  Font.Style = []
                  ParentFont = False
                  CharCase = ecNormal
                  CharWidth = 0
                  CharHeight = 0
                  MaxLength = 0
                  NameRec = 'Schem'
                  NameRecFld = 'APCOLOR'
                  Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
                  Vid = 'TColorGet'
                  VName = 'Color'
                  OnChange = EColorChange
                  ParentShowHint = False
                  ShowHint = True
                  SayCaption = ' '#1094#1074#1077#1090' '
                  SayRight = False
                  TabOrder = 1
                  TabStop = True
                end
              end
              object EPrm: TFldEdit
                Left = 28
                Top = 248
                Width = 206
                Height = 26
                MinSized = False
                ParentSchem = True
                Font.Charset = RUSSIAN_CHARSET
                Font.Color = clBlack
                Font.Height = -13
                Font.Name = 'Courier New'
                Font.Style = []
                ParentFont = False
                CharCase = ecNormal
                CharWidth = -1
                CharHeight = -1
                Mask = '@H'#1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1099#1077' '#1087#1072#1088#1072#1084#1077#1090#1088#1099'@'
                MaxLength = 0
                Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
                Vid = 'TButGet'
                VName = 'ButPrm'
                OnChange = EPrmChange
                ParentShowHint = False
                ShowHint = True
                SayRight = False
                TabOrder = 6
                TabStop = True
              end
            end
            object EKeyNul: TEdit
              Left = 21
              Top = 0
              Width = 0
              Height = 25
              TabOrder = 1
              OnEnter = ENulEnter
            end
          end
          object tsDop: TTabSheet
            Caption = #1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1086
            ImageIndex = 2
            object pnDop: TPanelEdit
              Left = 8
              Top = 7
              Width = 614
              Height = 297
              MinSized = False
              ParentSchem = True
              CanSize = False
              CanMove = False
              MaxWidth = False
              ProcentWnd = 100
              SortMode = smColumns
              SortObj = True
              BevelOuter = bvLowered
              HMin = 0
              Place = rpNone
              SayRight = False
              TabOrder = 0
              WMin = 0
              OnEnter = pnDopEnter
              OnExit = pnKeyExit
              MasterControl = EDopNul
              Options = [peCheckOnExit]
              OnValid = pnDopValid
              object EChrCheck: TFldEdit
                Left = 353
                Top = 28
                Width = 19
                Height = 25
                MinSized = False
                ParentSchem = True
                CharCase = ecNormal
                CharWidth = 0
                CharHeight = 0
                MaxLength = 0
                NameRec = 'Schem'
                NameRecFld = 'CHRCHECK'
                Vid = 'TSimpleGet'
                ParentShowHint = False
                ShowHint = True
                SayCaption = ' '#1047#1072#1084#1077#1085#1080#1090#1100' '#1074' '#1089#1087#1080#1089#1082#1072#1093' "'#1075#1072#1083#1086#1095#1082#1091'" '#1085#1072' '#1089#1080#1084#1074#1086#1083' # ('#1087#1091#1089#1090#1086' - '#1085#1077' '#1079#1072#1084#1077#1085#1103#1090#1100') '
                SayRight = False
                TabOrder = 0
                TabStop = True
              end
            end
            object EDopNul: TEdit
              Left = 21
              Top = 0
              Width = 0
              Height = 25
              TabOrder = 1
              OnEnter = ENulEnter
            end
          end
        end
      end
      object pnSamp: TRbPanel
        Left = 21
        Top = 360
        Width = 347
        Height = 71
        MinSized = False
        ParentSchem = True
        CanSize = False
        CanMove = False
        MaxWidth = False
        Header = #1054#1073#1088#1072#1079#1077#1094
        ProcentWnd = 100
        SortMode = smDefault
        SortObj = False
        BevelOuter = bvLowered
        Enabled = False
        HMin = 0
        Place = rpNone
        SayRight = False
        TabOrder = 1
        WMin = 0
        OnResize = pnSampResize
        object pnSamp1: TRbPanel
          Left = 99
          Top = 28
          Width = 164
          Height = 36
          MinSized = False
          ParentSchem = False
          Schem = 'Sample'
          CanSize = False
          CanMove = False
          MaxWidth = False
          ProcentWnd = 0
          SortMode = smDefault
          SortObj = True
          BevelInner = bvRaised
          BevelOuter = bvLowered
          HMin = 0
          Place = rpNone
          SayRight = False
          TabOrder = 0
          WMin = 0
        end
      end
    end
  end
  object Rec: TRecVal
    NameRec = 'Schem'
    Fields.Strings = (
      'Color1=N'
      'Color2=N'
      'ColorW=N'
      'FontW=M'
      'Font1=M'
      'Font2=M'
      'Type=N'
      'HotKeyFont=M'
      'HotKeyColor=N'
      'Width=N'
      'Inverted=L'
      'AFFont=M'
      'AFColor=N'
      'APFont=M'
      'APColor=N'
      'NFFont=M'
      'NFColor=N'
      'NPFont=M'
      'NPColor=N'
      'UnderBut=L'
      'Alignment=N'
      'Dir=M'
      'ChrCheck=S1')
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 96
  end
  object schSample: TSchem
    CaptSmall = 'Sample'
    DefColor1 = clWindow
    DefColor2 = clBtnFace
    DefColorW = clBtnFace
    DefFont0800.Font1.Charset = RUSSIAN_CHARSET
    DefFont0800.Font1.Color = clBlack
    DefFont0800.Font1.Height = -12
    DefFont0800.Font1.Name = 'Courier New'
    DefFont0800.Font1.Style = []
    DefFont0800.Font2.Charset = RUSSIAN_CHARSET
    DefFont0800.Font2.Color = clBlack
    DefFont0800.Font2.Height = -12
    DefFont0800.Font2.Name = 'Courier New'
    DefFont0800.Font2.Style = []
    DefFont0800.FontW.Charset = RUSSIAN_CHARSET
    DefFont0800.FontW.Color = clBlack
    DefFont0800.FontW.Height = -12
    DefFont0800.FontW.Name = 'Courier New'
    DefFont0800.FontW.Style = [fsBold]
    DefFont1024.Font1.Charset = RUSSIAN_CHARSET
    DefFont1024.Font1.Color = clBlack
    DefFont1024.Font1.Height = -15
    DefFont1024.Font1.Name = 'Courier New'
    DefFont1024.Font1.Style = []
    DefFont1024.Font2.Charset = RUSSIAN_CHARSET
    DefFont1024.Font2.Color = clBlack
    DefFont1024.Font2.Height = -15
    DefFont1024.Font2.Name = 'Courier New'
    DefFont1024.Font2.Style = []
    DefFont1024.FontW.Charset = RUSSIAN_CHARSET
    DefFont1024.FontW.Color = clBlack
    DefFont1024.FontW.Height = -15
    DefFont1024.FontW.Name = 'Courier New'
    DefFont1024.FontW.Style = [fsBold]
    Left = 144
  end
  object ButTypeGet: TMenuGet
    VName = 'ButType'
    UserItems = False
    LenCode = 0
    LenName = 0
    Left = 184
  end
  object FontGet: TButGet
    VName = 'ButFont'
    OnClick = FontGetClick
    Left = 224
  end
  object PrmGet: TButGet
    VName = 'ButPrm'
    OnClick = PrmGetClick
    Left = 256
  end
  object AlignmentGet: TRadioGet
    Items.Strings = (
      #1089#1083#1077#1074#1072'#'
      #1089#1087#1088#1072#1074#1072'#'
      #1074' '#1094#1077#1085#1090#1088#1077'#')
    VName = 'ButAlignment'
    Left = 288
  end
  object dlgIcon: TOpenPictureDialog
    DefaultExt = 'ico'
    Filter = #1060#1072#1081#1083#1099' '#1080#1082#1086#1085#1086#1082' (*.ico)|*.ico|'#1042#1089#1077' '#1092#1072#1081#1083#1099'|*.*'
    Title = #1042#1099#1073#1088#1072#1090#1100' '#1080#1082#1086#1085#1082#1091
    Left = 336
  end
  object deDir: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1085#1072#1089#1090#1088#1086#1081#1082#1080' '#1080#1079' '#1076#1088#1091#1075#1086#1081' '#1087#1072#1087#1082#1080
    Fields.Strings = (
      
        '#Schem#DIR#TDirGet##'#1055#1072#1087#1082#1072' '#1089' '#1085#1072#1089#1090#1088#1086#1081#1082#1072#1084#1080'~#0#1#T#F#T#F#F####-1#0#F' +
        '#F#F#F')
    HelpContext = 0
    NameWnd = 'SchemDir'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnPnlCngKey = deDirPnlCngKey
    OnPnlValid = deDirPnlValid
    Left = 368
  end
end
