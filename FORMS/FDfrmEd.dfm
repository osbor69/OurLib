inherited DFrmEd: TDFrmEd
  Top = 163
  Height = 643
  Caption = ''
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    Width = 636
    Height = 521
    inherited KeyLb1: TKeyLb
      Left = 16
      Top = 466
    end
    inherited PanelEdit1: TPanelEdit
      Height = 436
      BevelOuter = bvNone
      Options = [peAskByCancel]
      OnValid = PanelEdit1Valid
      object RbPage1: TRbPage
        Left = 7
        Top = 14
        Width = 573
        Height = 410
        ActivePage = tsOsn
        TabOrder = 0
        CngByCtrl = True
        object tsOsn: TTabSheet
          Caption = #1054#1073#1097#1080#1077
          object pnscOsn: TRbPanel
            Left = 14
            Top = 21
            Width = 545
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
            object scrlOsn: TRbScrollBox
              Left = 0
              Top = 0
              Width = 537
              Height = 347
              BorderStyle = bsNone
              TabOrder = 0
              StopRebuild = False
              Options = [rsoNoKeys]
              object pnOsn: TRbPanel
                Left = 0
                Top = 0
                Width = 485
                Height = 309
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
                Place = rpTop
                SayRight = False
                TabOrder = 0
                WMin = 0
                object pnCod: TRbPanel
                  Left = 7
                  Top = 21
                  Width = 477
                  Height = 128
                  MinSized = False
                  ParentSchem = True
                  Schem = 'Edit'
                  CanSize = False
                  CanMove = False
                  MaxWidth = False
                  ProcentWnd = 0
                  SortMode = smColumns
                  SortObj = True
                  BevelOuter = bvLowered
                  HMin = 0
                  Place = rpNone
                  SayRight = False
                  TabOrder = 0
                  WMin = 0
                  object EName: TFldEdit
                    Left = 127
                    Top = 56
                    Width = 86
                    Height = 26
                    MinSized = False
                    ParentSchem = True
                    Schem = 'Edit'
                    CharCase = ecNormal
                    CharWidth = 0
                    CharHeight = 0
                    MaxLength = 0
                    NameRec = 'DFrm'
                    NameRecFld = 'NAME'
                    Options = [ogAutoSelect, ogAutoSize, ogTrimLeft]
                    Vid = 'TSimpleGet'
                    ParentShowHint = False
                    ShowHint = True
                    SayCaption = ' '#1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '
                    SayRight = False
                    TabOrder = 2
                    TabStop = True
                  end
                  object EModel: TFldEdit
                    Left = 113
                    Top = 34
                    Width = 86
                    Height = 26
                    MinSized = False
                    ParentSchem = True
                    Schem = 'Edit'
                    CharCase = ecNormal
                    CharWidth = 0
                    CharHeight = 0
                    Mask = 'NMODEL'
                    MaxLength = 0
                    NameRec = 'DFrm'
                    NameRecFld = 'MODEL'
                    Options = [ogAutoSelect, ogReadOnly, ogAutoSize]
                    Vid = 'TModelGet'
                    VName = 'Dfrm'
                    ParentShowHint = False
                    ShowHint = True
                    SayCaption = ' '#1054#1089#1085#1086#1074#1072' '
                    SayRight = False
                    TabOrder = 1
                  end
                  object RbPanel2: TRbPanel
                    Left = 134
                    Top = 0
                    Width = 283
                    Height = 29
                    MinSized = True
                    ParentSchem = True
                    Schem = 'Edit'
                    CanSize = False
                    CanMove = False
                    MaxWidth = False
                    ProcentWnd = 0
                    SortMode = smRows
                    SortObj = True
                    BevelOuter = bvNone
                    HMin = 0
                    Place = rpNone
                    SayCaption = ' '#1053#1086#1084#1077#1088' '
                    SayRight = False
                    TabOrder = 0
                    WMin = 0
                    object ENf: TFldEdit
                      Left = 10
                      Top = 6
                      Width = 86
                      Height = 26
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      CharCase = ecUpperCase
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'DFrm'
                      NameRecFld = 'NF'
                      Vid = 'TSimpleGet'
                      OnCheck = ENfCheck
                      ParentShowHint = False
                      ShowHint = True
                      SayRight = False
                      TabOrder = 0
                      TabStop = True
                      OnExit = ENfExit
                    end
                    object EKf: TFldEdit
                      Left = 137
                      Top = 6
                      Width = 86
                      Height = 26
                      MinSized = False
                      ParentSchem = True
                      Schem = 'Edit'
                      CharCase = ecUpperCase
                      CharWidth = 0
                      CharHeight = 0
                      MaxLength = 0
                      NameRec = 'DFrm'
                      NameRecFld = 'KF'
                      Options = [ogAutoSelect, ogAutoSize, ogTrimLeft]
                      Vid = 'TSimpleGet'
                      OnCheck = EKfCheck
                      ParentShowHint = False
                      ShowHint = True
                      SayCaption = ' '#1050#1086#1076' '
                      SayRight = False
                      TabOrder = 1
                      TabStop = True
                    end
                  end
                end
                object pn2: TRbPanel
                  Left = 7
                  Top = 162
                  Width = 477
                  Height = 121
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
                  object EFrm: TFldEdit
                    Left = 56
                    Top = 35
                    Width = 140
                    Height = 26
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
                    CharWidth = -1
                    CharHeight = -1
                    Mask = '@H'#1060#1086#1088#1084#1091#1083#1072' '#1074#1099#1095#1080#1089#1083#1077#1085#1080#1103'@@,@'
                    MaxLength = 0
                    NameRec = 'DFrm'
                    NameRecFld = 'MEM_FRM'
                    Vid = 'TButFormGet'
                    VName = 'DFrm'
                    ParentShowHint = False
                    ShowHint = True
                    SayRight = False
                    TabOrder = 0
                    TabStop = True
                  end
                end
              end
            end
          end
        end
        object tsDat: TTabSheet
          Caption = #1054#1087#1088#1077#1076#1077#1083#1077#1085#1080#1077' '#1076#1072#1085#1085#1099#1093
          ImageIndex = 1
          object pnDW: TRbPanel
            Left = 21
            Top = 21
            Width = 502
            Height = 340
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CanSize = False
            CanMove = False
            MaxWidth = False
            ProcentWnd = 100
            SortMode = smDefault
            SortObj = False
            BevelOuter = bvLowered
            HMin = 0
            Place = rpLeft
            SayRight = False
            TabOrder = 0
            WMin = 0
          end
        end
        object tsHelp: TTabSheet
          Caption = #1055#1086#1084#1086#1097#1100
          ImageIndex = 2
          object pnHelp: TRbPanel
            Left = 21
            Top = 21
            Width = 502
            Height = 340
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CanSize = False
            CanMove = False
            MaxWidth = False
            ProcentWnd = 100
            SortMode = smDefault
            SortObj = False
            BevelOuter = bvLowered
            HMin = 0
            Place = rpLeft
            SayRight = False
            TabOrder = 0
            WMin = 0
            object EHelp: TFldEdit
              Left = 56
              Top = 35
              Width = 252
              Height = 26
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
              CharWidth = -1
              CharHeight = -1
              Mask = '@H'#1060#1086#1088#1084#1091#1083#1072' '#1079#1072#1087#1086#1083#1085#1077#1085#1080#1103' '#1089#1090#1088#1072#1085#1080#1094#1099' '#1087#1086#1084#1086#1097#1080'@@,@'
              MaxLength = 0
              NameRec = 'DFrm'
              NameRecFld = 'MEM_HELP'
              Vid = 'TButFormGet'
              VName = 'DFrm'
              ParentShowHint = False
              ShowHint = True
              SayRight = False
              TabOrder = 0
              TabStop = True
            end
          end
        end
      end
    end
  end
  object FrmGet: TButFormGet
    EditType = edtpInter
    OnAfterClick = FrmGetAfterClick
    OnBeforeClick = FrmGetBeforeClick
    VName = 'DFrm'
    Left = 49
    Top = 10
  end
  object DWGet: TButGet
    VName = 'Dfrm'
    OnClick = DWGetClick
    OnPaint = DWGetPaint
    Left = 104
    Top = 9
  end
end
