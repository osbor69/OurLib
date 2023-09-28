inherited GFPrm: TGFPrm
  Left = 324
  Top = 141
  Width = 839
  Height = 750
  Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1092#1086#1088#1084#1099
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    Width = 707
    Height = 620
    inherited KeyLb1: TKeyLb
      Top = 586
      NmProc.Strings = (
        'F3#'#1054#1090#1089#1090#1091#1087#1099'#'#1059#1089#1090#1072#1085#1086#1074#1082#1072' '#1084#1080#1085#1080#1084'. '#1086#1090#1089#1090#1091#1087#1086#1074' '#1087#1088#1080#1085#1090#1077#1088#1072'#FILE'
        'F4#'#1064#1088#1080#1092#1090#1099'#'#1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1096#1088#1080#1092#1090#1086#1074'#FILE'
        'F7#'#1060#1086#1088#1084#1072#1090#1099'##FILE')
    end
    inherited RbPanel2: TRbPanel
      Width = 685
      Height = 553
      BevelOuter = bvNone
      Place = rpLeft
      object PanelEdit1: TPanelEdit
        Left = 0
        Top = 0
        Width = 566
        Height = 551
        MinSized = False
        ParentSchem = True
        Schem = 'Edit'
        CanSize = False
        CanMove = False
        MaxWidth = False
        ProcentWnd = 100
        SortMode = smDefault
        SortObj = True
        BevelOuter = bvLowered
        HMin = 0
        Place = rpNone
        SayRight = False
        TabOrder = 0
        WMin = 0
        Options = [peAskByCancel]
        OnAskCancel = PanelEdit1AskCancel
        object RbPage1: TRbPage
          Left = 7
          Top = 7
          Width = 552
          Height = 544
          ActivePage = tsPrm
          MultiLine = True
          TabOrder = 0
          CngByCtrl = True
          object tsPrm: TTabSheet
            Caption = #1054#1073#1097#1080#1077
            object pnscPrm: TRbPanel
              Left = 0
              Top = 0
              Width = 485
              Height = 460
              MinSized = False
              ParentSchem = True
              Schem = 'Edit'
              CanSize = False
              CanMove = False
              MaxWidth = False
              ProcentWnd = 100
              SortMode = smDefault
              SortObj = True
              BevelOuter = bvNone
              HMin = 0
              Place = rpNone
              SayRight = False
              TabOrder = 0
              WMin = 0
              object scrlPrm: TRbScrollBox
                Left = 0
                Top = 7
                Width = 502
                Height = 410
                BorderStyle = bsNone
                TabOrder = 0
                StopRebuild = False
                Options = [rsoNoKeys]
                object PnPrm: TRbPanel
                  Left = 0
                  Top = 0
                  Width = 481
                  Height = 347
                  MinSized = False
                  ParentSchem = False
                  Schem = 'Edit'
                  CanSize = False
                  CanMove = False
                  MaxWidth = False
                  ProcentWnd = 100
                  SortMode = smDefault
                  SortObj = True
                  BevelOuter = bvNone
                  HMin = 0
                  Place = rpTop
                  SayRight = False
                  TabOrder = 0
                  WMin = 0
                  object pnPrm1: TRbPanel
                    Left = 7
                    Top = 7
                    Width = 354
                    Height = 128
                    MinSized = False
                    ParentSchem = True
                    Schem = 'Edit'
                    CanSize = False
                    CanMove = False
                    MaxWidth = False
                    Header = #1056#1072#1079#1084#1077#1088' '#1073#1091#1084#1072#1075#1080
                    ProcentWnd = 0
                    SortMode = smColumns
                    SortObj = True
                    BevelOuter = bvLowered
                    HMin = 0
                    Place = rpNone
                    SayRight = False
                    TabOrder = 0
                    WMin = 0
                    object EStdFrm: TFldEdit
                      Left = 162
                      Top = 21
                      Width = 27
                      Height = 23
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      Font.Charset = RUSSIAN_CHARSET
                      Font.Color = clBlack
                      Font.Height = -12
                      Font.Name = 'Courier New'
                      Font.Style = []
                      ParentFont = False
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'STDFRM'
                      Vid = 'TBoolGet'
                      OnChange = EStdFrmChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1057#1090#1072#1085#1076#1072#1088#1090#1085#1099#1081' '#1092#1086#1088#1084#1072#1090' '
                      SayRight = False
                      TabOrder = 0
                      TabStop = True
                    end
                    object ENFrm: TFldEdit
                      Left = 162
                      Top = 42
                      Width = 63
                      Height = 25
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'NFrm'
                      Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
                      Value = '0'
                      Vid = 'TMenuGet'
                      VName = 'GFFrm'
                      OnChange = EStdFrmChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1060#1086#1088#1084#1072#1090' '
                      SayRight = False
                      TabOrder = 1
                      TabStop = True
                    end
                    object EWidth: TFldEdit
                      Left = 162
                      Top = 78
                      Width = 81
                      Height = 25
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      Mask = '0,60000'
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'Width'
                      Vid = 'TSpinGet'
                      OnChange = PBChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1064#1080#1088#1080#1085#1072'('#1084#1084') '
                      SayRight = False
                      TabOrder = 3
                      TabStop = True
                    end
                    object EHeight: TFldEdit
                      Left = 162
                      Top = 97
                      Width = 81
                      Height = 25
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      Mask = '0,60000'
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'Height'
                      Vid = 'TSpinGet'
                      OnChange = PBChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1042#1099#1089#1086#1090#1072'('#1084#1084') '
                      SayRight = False
                      TabOrder = 4
                      TabStop = True
                    end
                    object EOrient: TFldEdit
                      Left = 254
                      Top = 61
                      Width = 86
                      Height = 26
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      Font.Charset = RUSSIAN_CHARSET
                      Font.Color = clMaroon
                      Font.Height = -13
                      Font.Name = 'Verdana'
                      Font.Style = []
                      ParentFont = False
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'Orient'
                      Vid = 'TRadioGet'
                      VName = 'Feed'
                      OnChange = EOrientChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1053#1072#1087#1088#1072#1074#1083#1077#1085#1080#1077' '#1087#1077#1095#1072#1090#1080' '
                      SayRight = False
                      TabOrder = 2
                      TabStop = True
                    end
                  end
                  object pnPrm2: TRbPanel
                    Left = 7
                    Top = 141
                    Width = 446
                    Height = 206
                    MinSized = False
                    ParentSchem = True
                    Schem = 'Edit'
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
                    TabOrder = 1
                    WMin = 0
                    object EDateTime: TFldEdit
                      Left = 109
                      Top = 62
                      Width = 212
                      Height = 25
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      Font.Charset = RUSSIAN_CHARSET
                      Font.Color = clBlack
                      Font.Height = -12
                      Font.Name = 'Courier New'
                      Font.Style = []
                      ParentFont = False
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      Mask = #1042#1099#1074#1086#1076#1080#1090#1100' '#1076#1072#1090#1091' '#1092#1086#1088#1084#1080#1088#1086#1074#1072#1085#1080#1103
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'DATETIME'
                      Vid = 'TBoolGet'
                      ParentShowHint = False
                      ShowHint = True
                      SayRight = False
                      TabOrder = 1
                      TabStop = True
                    end
                    object EBreak: TFldEdit
                      Left = 250
                      Top = 90
                      Width = 90
                      Height = 30
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      Font.Charset = RUSSIAN_CHARSET
                      Font.Color = clMaroon
                      Font.Height = -13
                      Font.Name = 'Verdana'
                      Font.Style = []
                      ParentFont = False
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'BREAK'
                      Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
                      Vid = 'TBoolMultiGet'
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = #1056#1072#1079#1073#1080#1074#1072#1090#1100' '#1089#1090#1088#1072#1085#1080#1094#1091':'
                      SayRight = False
                      TabOrder = 2
                      TabStop = True
                    end
                    object pnGridLine: TRbPanel
                      Left = 176
                      Top = 7
                      Width = 255
                      Height = 50
                      MinSized = True
                      ParentSchem = True
                      Schem = 'Edit'
                      CanSize = False
                      CanMove = False
                      MaxWidth = False
                      ProcentWnd = 0
                      SortMode = smColumns
                      SortObj = True
                      BevelOuter = bvNone
                      HMin = 0
                      Place = rpNone
                      SayCaption = #1058#1086#1083#1097#1080#1085#1072' '#1083#1080#1085#1080#1081' (1/10 '#1084#1084'):'
                      SayRight = False
                      TabOrder = 0
                      WMin = 0
                      object EGridLineWidth: TFldEdit
                        Left = 116
                        Top = 26
                        Width = 116
                        Height = 25
                        MinSized = False
                        ParentSchem = True
                        Schem = 'Edit'
                        CharCase = ecNormal
                        CharWidth = 0
                        CharHeight = 0
                        MaxLength = 0
                        NameRec = 'GFPrm'
                        NameRecFld = 'GRIDLINEWIDTH'
                        Vid = 'TSpinGet'
                        OnCheck = EGridLineWidthCheck
                        OnChange = EGridLineWidthChange
                        ParentShowHint = False
                        ShowHint = True
                        SayCaption = ' '#1084#1072#1082#1089#1080#1084#1072#1083#1100#1085#1072#1103' '
                        SayRight = False
                        TabOrder = 1
                        TabStop = True
                      end
                      object EGridLineMin: TFldEdit
                        Left = 116
                        Top = 5
                        Width = 116
                        Height = 25
                        MinSized = False
                        ParentSchem = True
                        Schem = 'Edit'
                        CharCase = ecNormal
                        CharWidth = 0
                        CharHeight = 0
                        MaxLength = 0
                        NameRec = 'GFPrm'
                        NameRecFld = 'GRIDLINEMIN'
                        Vid = 'TSpinGet'
                        ParentShowHint = False
                        ShowHint = True
                        SayCaption = ' '#1084#1080#1085#1080#1084#1072#1083#1100#1085#1072#1103' '
                        SayRight = False
                        TabOrder = 0
                        TabStop = True
                      end
                    end
                    object EAWidth: TFldEdit
                      Left = 250
                      Top = 139
                      Width = 90
                      Height = 30
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      Font.Charset = RUSSIAN_CHARSET
                      Font.Color = clMaroon
                      Font.Height = -13
                      Font.Name = 'Verdana'
                      Font.Style = []
                      ParentFont = False
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'AWidth'
                      Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
                      Vid = 'TBoolMultiGet'
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = #1056#1072#1089#1090#1103#1085#1091#1090#1100' '#1085#1072' '#1083#1080#1089#1090#1077':'
                      SayRight = False
                      TabOrder = 3
                      TabStop = True
                    end
                  end
                end
              end
            end
          end
          object tsSpot: TTabSheet
            Caption = #1054#1090#1089#1090#1091#1087#1099'('#1084#1084')'
            ImageIndex = 1
            object PnSpot: TRbPanel
              Left = 7
              Top = 21
              Width = 403
              Height = 220
              MinSized = False
              ParentSchem = False
              Schem = 'Edit'
              OnSetWHMin = PnSpotSetWHMin
              CanSize = False
              CanMove = False
              MaxWidth = False
              ProcentWnd = 100
              SortMode = smColumns
              SortObj = False
              OnAfterPaint = pnSampAfterPaint
              BevelOuter = bvLowered
              HMin = 0
              Place = rpNone
              SayRight = False
              TabOrder = 0
              WMin = 0
              OnResize = PnSpotResize
              object ESpTop: TFldEdit
                Left = 212
                Top = 21
                Width = 81
                Height = 25
                MinSized = False
                ParentSchem = True
                Schem = 'Edit'
                CharCase = ecNormal
                CharWidth = 0
                CharHeight = 0
                Mask = '0,60000'
                MaxLength = 0
                NameRec = 'GFPrm'
                NameRecFld = 'SpTop'
                Vid = 'TSpinGet'
                OnChange = PBChange
                ParentShowHint = False
                ShowHint = True
                SayCaption = ' '#1089#1074#1077#1088#1093#1091' '
                SayRight = False
                TabOrder = 0
                TabStop = True
              end
              object ESpBottom: TFldEdit
                Left = 198
                Top = 155
                Width = 81
                Height = 25
                MinSized = False
                ParentSchem = True
                Schem = 'Edit'
                CharCase = ecNormal
                CharWidth = 0
                CharHeight = 0
                Mask = '0,60000'
                MaxLength = 0
                NameRec = 'GFPrm'
                NameRecFld = 'SpBottom'
                Vid = 'TSpinGet'
                OnChange = PBChange
                ParentShowHint = False
                ShowHint = True
                SayCaption = ' '#1089#1085#1080#1079#1091' '
                SayRight = False
                TabOrder = 2
                TabStop = True
              end
              object ESpLeft: TFldEdit
                Left = 85
                Top = 78
                Width = 81
                Height = 25
                MinSized = False
                ParentSchem = True
                Schem = 'Edit'
                CharCase = ecNormal
                CharWidth = 0
                CharHeight = 0
                Mask = '0,60000'
                MaxLength = 0
                NameRec = 'GFPrm'
                NameRecFld = 'SpLeft'
                Vid = 'TSpinGet'
                OnChange = PBChange
                ParentShowHint = False
                ShowHint = True
                SayCaption = ' '#1089#1083#1077#1074#1072' '
                SayRight = False
                TabOrder = 1
                TabStop = True
              end
              object ESpRight: TFldEdit
                Left = 268
                Top = 76
                Width = 81
                Height = 25
                MinSized = False
                ParentSchem = True
                Schem = 'Edit'
                CharCase = ecNormal
                CharWidth = 0
                CharHeight = 0
                Mask = '0,60000'
                MaxLength = 0
                NameRec = 'GFPrm'
                NameRecFld = 'SpRight'
                Vid = 'TSpinGet'
                OnChange = PBChange
                ParentShowHint = False
                ShowHint = True
                SayCaption = ' '#1089#1087#1088#1072#1074#1072' '
                SayRight = False
                TabOrder = 3
                TabStop = True
              end
            end
          end
          object tsNFmt: TTabSheet
            Caption = #1063#1080#1089#1083#1072
            ImageIndex = 2
            object pnscNFmt: TRbPanel
              Left = 0
              Top = 0
              Width = 474
              Height = 361
              MinSized = False
              ParentSchem = True
              Schem = 'Edit'
              CanSize = False
              CanMove = False
              MaxWidth = False
              ProcentWnd = 100
              SortMode = smDefault
              SortObj = True
              BevelOuter = bvNone
              HMin = 0
              Place = rpNone
              SayRight = False
              TabOrder = 0
              WMin = 0
              object scrlNFmt: TRbScrollBox
                Left = 7
                Top = 7
                Width = 453
                Height = 354
                BorderStyle = bsNone
                TabOrder = 0
                StopRebuild = False
                Options = [rsoNoKeys]
                object PnNFmt: TRbPanel
                  Left = 0
                  Top = 0
                  Width = 424
                  Height = 354
                  MinSized = False
                  ParentSchem = False
                  Schem = 'Edit'
                  CanSize = False
                  CanMove = False
                  MaxWidth = False
                  ProcentWnd = 100
                  SortMode = smDefault
                  SortObj = True
                  BevelOuter = bvLowered
                  HMin = 0
                  Place = rpTop
                  SayRight = False
                  TabOrder = 0
                  WMin = 0
                  object PnNSamp1: TRbPanel
                    Left = 14
                    Top = 7
                    Width = 340
                    Height = 79
                    MinSized = False
                    ParentSchem = True
                    Schem = 'Edit'
                    CanSize = False
                    CanMove = False
                    MaxWidth = False
                    ProcentWnd = 0
                    SortMode = smColumns
                    SortObj = True
                    BevelOuter = bvNone
                    HMin = 0
                    Place = rpNone
                    SayRight = False
                    TabOrder = 0
                    WMin = 0
                    object PnNSamp: TRbPanel
                      Left = 14
                      Top = 0
                      Width = 312
                      Height = 71
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      OnSetWHMin = PnFSampSetWHMin
                      CanSize = False
                      CanMove = False
                      MaxWidth = False
                      ProcentWnd = 0
                      SortMode = smDefault
                      SortObj = False
                      HMin = 0
                      Place = rpNone
                      SayRight = False
                      TabOrder = 0
                      WMin = 0
                      object ENSamp: TFldEdit
                        Left = 92
                        Top = 0
                        Width = 86
                        Height = 26
                        MinSized = False
                        ParentSchem = True
                        Schem = 'Edit'
                        CharCase = ecNormal
                        CharWidth = 0
                        CharHeight = 0
                        MaxLength = 0
                        NameRec = 'GFPrm'
                        NameRecFld = 'NSamp'
                        Options = [ogAutoSelect, ogReadOnly, ogAutoSize]
                        Vid = 'TSimpleGet'
                        ParentShowHint = False
                        ShowHint = True
                        Enabled = False
                        SayCaption = #1054#1073#1088#1072#1079#1094#1099':'
                        SayRight = False
                        TabOrder = 0
                        TabStop = True
                      end
                      object ENSamp1: TFldEdit
                        Left = 92
                        Top = 19
                        Width = 86
                        Height = 26
                        MinSized = False
                        ParentSchem = True
                        Schem = 'Edit'
                        CharCase = ecNormal
                        CharWidth = 0
                        CharHeight = 0
                        MaxLength = 0
                        NameRec = 'GFPrm'
                        NameRecFld = 'NSamp1'
                        Options = [ogAutoSelect, ogReadOnly, ogAutoSize]
                        Vid = 'TSimpleGet'
                        ParentShowHint = False
                        ShowHint = True
                        Enabled = False
                        SayRight = False
                        TabOrder = 1
                        TabStop = True
                      end
                      object ENSamp2: TFldEdit
                        Left = 92
                        Top = 41
                        Width = 86
                        Height = 26
                        MinSized = False
                        ParentSchem = True
                        Schem = 'Edit'
                        CharCase = ecNormal
                        CharWidth = 0
                        CharHeight = 0
                        MaxLength = 0
                        NameRec = 'GFPrm'
                        NameRecFld = 'NSamp2'
                        Options = [ogAutoSelect, ogReadOnly, ogAutoSize]
                        Vid = 'TSimpleGet'
                        ParentShowHint = False
                        ShowHint = True
                        Enabled = False
                        SayRight = False
                        TabOrder = 2
                        TabStop = True
                      end
                    end
                  end
                  object PnNEd: TRbPanel
                    Tag = 1
                    Left = 14
                    Top = 85
                    Width = 382
                    Height = 248
                    MinSized = False
                    ParentSchem = True
                    Schem = 'Edit'
                    CanSize = False
                    CanMove = False
                    MaxWidth = False
                    ProcentWnd = 100
                    SortMode = smColumns
                    SortObj = True
                    BevelOuter = bvNone
                    HMin = 0
                    Place = rpNone
                    SayRight = False
                    TabOrder = 1
                    WMin = 0
                    object ENFracDlm: TFldEdit
                      Left = 275
                      Top = 0
                      Width = 86
                      Height = 26
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'NFracDlm'
                      Vid = 'TSimpleGet'
                      OnCheck = EDlmCheck
                      OnChange = ENPrmChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1056#1072#1079#1076#1077#1083#1080#1090#1077#1083#1100' '#1094#1077#1083#1086#1081' '#1080' '#1076#1088#1086#1073#1085#1086#1081' '#1095#1072#1089#1090#1080' '
                      SayRight = False
                      TabOrder = 0
                      TabStop = True
                    end
                    object ENFracCnt: TFldEdit
                      Left = 275
                      Top = 49
                      Width = 53
                      Height = 25
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      Mask = '0,9'
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'NFracCnt'
                      Vid = 'TSpinGet'
                      OnChange = ENFracCntChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1076#1088#1086#1073#1085#1099#1093' '#1079#1085#1072#1082#1086#1074' '
                      SayRight = False
                      TabOrder = 2
                      TabStop = True
                    end
                    object ENFracEmp: TFldEdit
                      Left = 275
                      Top = 71
                      Width = 27
                      Height = 23
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      Font.Charset = RUSSIAN_CHARSET
                      Font.Color = clBlack
                      Font.Height = -12
                      Font.Name = 'Courier New'
                      Font.Style = []
                      ParentFont = False
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'NFracEmp'
                      Vid = 'TBoolGet'
                      OnChange = ENPrmChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1042#1099#1074#1086#1076#1080#1090#1100' '#1087#1091#1089#1090#1091#1102' '#1076#1088#1086#1073#1085#1091#1102' '#1095#1072#1089#1090#1100' '
                      SayRight = False
                      TabOrder = 3
                      TabStop = True
                    end
                    object ENDigIsDlm: TFldEdit
                      Left = 275
                      Top = 92
                      Width = 27
                      Height = 23
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      Font.Charset = RUSSIAN_CHARSET
                      Font.Color = clBlack
                      Font.Height = -12
                      Font.Name = 'Courier New'
                      Font.Style = []
                      ParentFont = False
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'NDigIsDlm'
                      Vid = 'TBoolGet'
                      OnChange = ENDigIsDlmChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1056#1072#1079#1076#1077#1083#1103#1090#1100' '#1088#1072#1079#1088#1103#1076#1099' '
                      SayRight = False
                      TabOrder = 4
                      TabStop = True
                    end
                    object ENDigDlm: TFldEdit
                      Left = 275
                      Top = 113
                      Width = 86
                      Height = 26
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'NDigDlm'
                      Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
                      Vid = 'TSimpleGet'
                      OnCheck = EDlmCheck
                      OnChange = ENPrmChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1056#1072#1079#1076#1077#1083#1080#1090#1077#1083#1100' '#1088#1072#1079#1088#1103#1076#1086#1074' '
                      SayRight = False
                      TabOrder = 5
                      TabStop = True
                    end
                    object ENZeroEmp: TFldEdit
                      Left = 275
                      Top = 134
                      Width = 27
                      Height = 23
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      Font.Charset = RUSSIAN_CHARSET
                      Font.Color = clBlack
                      Font.Height = -12
                      Font.Name = 'Courier New'
                      Font.Style = []
                      ParentFont = False
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'NZEROEMP'
                      Vid = 'TBoolGet'
                      OnChange = ENZeroEmpChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1053#1077' '#1074#1099#1074#1086#1076#1080#1090#1100' 0 '
                      SayRight = False
                      TabOrder = 6
                      TabStop = True
                    end
                    object ENAllCnt: TFldEdit
                      Left = 275
                      Top = 26
                      Width = 60
                      Height = 25
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      Mask = '0,99'
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'NALLCNT'
                      Vid = 'TSpinGet'
                      OnChange = ENPrmChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1079#1085#1072#1082#1086#1074' '
                      SayRight = False
                      TabOrder = 1
                      TabStop = True
                    end
                    object ENsZero: TFldEdit
                      Left = 276
                      Top = 155
                      Width = 86
                      Height = 26
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      CharCase = ecNormal
                      CharWidth = -2
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'NsZero'
                      Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
                      Vid = 'TSimpleGet'
                      OnChange = ENPrmChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1057#1090#1088#1086#1082#1072', '#1079#1072#1084#1077#1085#1103#1102#1097#1072#1103' 0 '
                      SayRight = False
                      TabOrder = 7
                      TabStop = True
                    end
                  end
                end
              end
            end
          end
          object tsDFmt: TTabSheet
            Caption = #1044#1072#1090#1099
            ImageIndex = 3
            object pnscDFmt: TRbPanel
              Left = 14
              Top = 21
              Width = 481
              Height = 446
              MinSized = False
              ParentSchem = True
              Schem = 'Edit'
              CanSize = False
              CanMove = False
              MaxWidth = False
              ProcentWnd = 100
              SortMode = smDefault
              SortObj = True
              BevelOuter = bvNone
              HMin = 0
              Place = rpNone
              SayRight = False
              TabOrder = 0
              WMin = 0
              object scrlDFmt: TRbScrollBox
                Left = 7
                Top = 7
                Width = 439
                Height = 382
                BorderStyle = bsNone
                TabOrder = 0
                StopRebuild = False
                Options = [rsoNoKeys]
                object PnDFmt: TRbPanel
                  Left = 14
                  Top = 28
                  Width = 410
                  Height = 248
                  MinSized = False
                  ParentSchem = False
                  Schem = 'Edit'
                  CanSize = False
                  CanMove = False
                  MaxWidth = False
                  ProcentWnd = 100
                  SortMode = smDefault
                  SortObj = True
                  BevelOuter = bvLowered
                  HMin = 0
                  Place = rpTop
                  SayRight = False
                  TabOrder = 0
                  WMin = 0
                  object PnDEd: TRbPanel
                    Tag = 1
                    Left = 7
                    Top = 99
                    Width = 368
                    Height = 135
                    MinSized = False
                    ParentSchem = True
                    Schem = 'Edit'
                    CanSize = False
                    CanMove = False
                    MaxWidth = False
                    ProcentWnd = 100
                    SortMode = smColumns
                    SortObj = True
                    BevelOuter = bvNone
                    HMin = 0
                    Place = rpNone
                    SayRight = False
                    TabOrder = 0
                    WMin = 0
                    object EDDlm: TFldEdit
                      Left = 212
                      Top = 7
                      Width = 86
                      Height = 26
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 1
                      NameRec = 'GFPrm'
                      NameRecFld = 'DDlm'
                      Vid = 'TSimpleGet'
                      OnChange = EDPrmChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1056#1072#1079#1076#1077#1083#1080#1090#1077#1083#1100' '
                      SayRight = False
                      TabOrder = 0
                      TabStop = True
                    end
                    object EDNYear: TFldEdit
                      Left = 212
                      Top = 28
                      Width = 53
                      Height = 25
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      Mask = '2,4,2,T'
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'DNYear'
                      Vid = 'TSpinGet'
                      OnChange = EDPrmChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1043#1086#1076': '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1079#1085#1072#1082#1086#1074' '
                      SayRight = False
                      TabOrder = 1
                      TabStop = True
                    end
                    object EDZeroEmp: TFldEdit
                      Left = 212
                      Top = 76
                      Width = 27
                      Height = 23
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      Font.Charset = RUSSIAN_CHARSET
                      Font.Color = clBlack
                      Font.Height = -12
                      Font.Name = 'Courier New'
                      Font.Style = []
                      ParentFont = False
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'DZEROEMP'
                      Vid = 'TBoolGet'
                      OnChange = EDZeroEmpChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1053#1077' '#1074#1099#1074#1086#1076#1080#1090#1100' '#1087#1091#1089#1090#1091#1102' '#1076#1072#1090#1091' '
                      SayRight = False
                      TabOrder = 3
                      TabStop = True
                    end
                    object EDsZero: TFldEdit
                      Left = 213
                      Top = 97
                      Width = 86
                      Height = 26
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      CharCase = ecNormal
                      CharWidth = -2
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'DsZero'
                      Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
                      Vid = 'TSimpleGet'
                      OnChange = EDPrmChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1057#1090#1088#1086#1082#1072', '#1079#1072#1084#1077#1085#1103#1102#1097#1072#1103' '#1087#1091#1089#1090#1091#1102' '#1076#1072#1090#1091' '
                      SayRight = False
                      TabOrder = 4
                      TabStop = True
                    end
                    object EDMMYY: TFldEdit
                      Left = 212
                      Top = 55
                      Width = 27
                      Height = 23
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      Font.Charset = RUSSIAN_CHARSET
                      Font.Color = clBlack
                      Font.Height = -12
                      Font.Name = 'Courier New'
                      Font.Style = []
                      ParentFont = False
                      CharCase = ecNormal
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'GFPrm'
                      NameRecFld = 'DMMYY'
                      Vid = 'TBoolGet'
                      OnChange = EDZeroEmpChange
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1058#1086#1083#1100#1082#1086' '#1084#1077#1089#1103#1094'.'#1075#1086#1076' '
                      SayRight = False
                      TabOrder = 2
                      TabStop = True
                    end
                  end
                  object pnDSamp1: TRbPanel
                    Left = 7
                    Top = 14
                    Width = 375
                    Height = 79
                    MinSized = False
                    ParentSchem = True
                    Schem = 'Edit'
                    CanSize = False
                    CanMove = False
                    MaxWidth = False
                    ProcentWnd = 0
                    SortMode = smColumns
                    SortObj = True
                    BevelOuter = bvNone
                    HMin = 0
                    Place = rpNone
                    SayRight = False
                    TabOrder = 1
                    WMin = 0
                    object PnDSamp: TRbPanel
                      Left = 7
                      Top = 7
                      Width = 283
                      Height = 57
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      OnSetWHMin = PnFSampSetWHMin
                      CanSize = False
                      CanMove = False
                      MaxWidth = False
                      ProcentWnd = 0
                      SortMode = smDefault
                      SortObj = False
                      HMin = 0
                      Place = rpNone
                      SayRight = False
                      TabOrder = 0
                      WMin = 0
                      object EDSamp: TFldEdit
                        Left = 92
                        Top = 7
                        Width = 86
                        Height = 26
                        MinSized = False
                        ParentSchem = True
                        Schem = 'Edit'
                        CharCase = ecNormal
                        CharWidth = 0
                        CharHeight = 0
                        MaxLength = 0
                        NameRec = 'GFPrm'
                        NameRecFld = 'DSamp'
                        Options = [ogAutoSelect, ogReadOnly, ogAutoSize]
                        Vid = 'TSimpleGet'
                        ParentShowHint = False
                        ShowHint = True
                        Enabled = False
                        SayCaption = #1054#1073#1088#1072#1079#1094#1099':'
                        SayRight = False
                        TabOrder = 0
                        TabStop = True
                      end
                      object EDSamp1: TFldEdit
                        Left = 92
                        Top = 28
                        Width = 86
                        Height = 26
                        MinSized = False
                        ParentSchem = True
                        Schem = 'Edit'
                        CharCase = ecNormal
                        CharWidth = 0
                        CharHeight = 0
                        MaxLength = 0
                        NameRec = 'GFPrm'
                        NameRecFld = 'DSamp1'
                        Options = [ogAutoSelect, ogReadOnly, ogAutoSize]
                        Vid = 'TSimpleGet'
                        ParentShowHint = False
                        ShowHint = True
                        Enabled = False
                        SayRight = False
                        TabOrder = 1
                        TabStop = True
                      end
                    end
                  end
                end
              end
            end
          end
          object tsPrn: TTabSheet
            Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1077#1095#1072#1090#1080
            ImageIndex = 5
            object pnPrn1: TRbPanel
              Left = 0
              Top = 7
              Width = 544
              Height = 509
              MinSized = False
              ParentSchem = True
              Schem = 'Edit'
              CanSize = False
              CanMove = False
              MaxWidth = False
              ProcentWnd = 100
              SortMode = smDefault
              SortObj = True
              BevelOuter = bvNone
              HMin = 0
              Place = rpNone
              SayRight = False
              TabOrder = 0
              WMin = 0
              object scrlPrn: TRbScrollBox
                Left = 0
                Top = 0
                Width = 537
                Height = 509
                BorderStyle = bsNone
                TabOrder = 0
                StopRebuild = False
                Options = []
                object pnPrn: TRbPanel
                  Left = 4
                  Top = -4
                  Width = 526
                  Height = 503
                  MinSized = False
                  ParentSchem = True
                  Schem = 'Edit'
                  OnSetWHMin = pnPrnSetWHMin
                  CanSize = False
                  CanMove = False
                  MaxWidth = False
                  ProcentWnd = 100
                  SortMode = smColumns
                  SortObj = True
                  OnAfterPaint = pnPrnAfterPaint
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
        end
      end
      object pnSamp: TRbPanel
        Left = 565
        Top = 0
        Width = 119
        Height = 290
        MinSized = False
        ParentSchem = True
        Schem = 'Edit'
        OnSetWHMin = pnSampSetWHMin
        CanSize = False
        CanMove = False
        MaxWidth = False
        Header = #1054#1073#1088#1072#1079#1077#1094
        ProcentWnd = 0
        SortMode = smDefault
        SortObj = True
        OnAfterPaint = pnSampAfterPaint
        BevelOuter = bvLowered
        HMin = 0
        Place = rpNone
        SayRight = False
        TabOrder = 1
        WMin = 0
      end
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 16
    Top = 8
  end
  object RV: TRecVal
    Fields.Strings = (
      'StdFrm=L'
      'NFrm=N'
      'Orient=N'
      'Width=N'
      'Height=N'
      'GridLineMin=N'
      'GridLineWidth=N'
      'DateTime=L'
      'Break=S2'
      'AWidth=S2'
      'SpLeft=N'
      'SpTop=N'
      'SpRight=N'
      'SpBottom=N'
      'NSamp=S21'
      'NSamp1=S21'
      'NSamp2=S21'
      'NFracDlm=S1'
      'NFracCnt=N'
      'NFracEmp=L'
      'NDigIsDlm=L'
      'NDigDlm=S1'
      'NZeroEmp=L'
      'NAllCnt=N'
      'NsZero=M'
      'DSamp=S10'
      'DSamp1=S10'
      'DDlm=S1'
      'DNYear=N'
      'DZeroEmp=L'
      'DsZero=M'
      'DMMYY=L')
    Left = 48
    Top = 8
  end
  object FrmGet: TMenuGet
    VName = 'GFFrm'
    UserItems = False
    LenCode = 0
    LenName = 0
    Left = 80
    Top = 8
  end
end
