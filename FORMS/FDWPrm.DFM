inherited DWPrm: TDWPrm
  Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1086#1082#1085#1072' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1103
  WindowState = wsMaximized
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      Font.Charset = RUSSIAN_CHARSET
      Font.Style = []
      NmProc.Strings = (
        'F6#'#1055#1086#1080#1089#1082'##FILE##'
        'Ctrl_F#####F6')
      OnProcKey = KeyLb1ProcKey
      OnRePlace = FormResize
    end
    inherited PanelEdit1: TPanelEdit
      BevelOuter = bvNone
      Place = rpTop
      Options = [peAskByCancel]
      OnAskCancel = PanelEdit1AskCancel
      OnValid = PanelEdit1Valid
      object PnPrm: TRbPanel
        Left = 8
        Top = 8
        Width = 572
        Height = 85
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
        object EZgl: TFldEdit
          Tag = 1
          Left = 346
          Top = 8
          Width = 86
          Height = 26
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CharCase = ecNormal
          CharWidth = 0
          CharHeight = 0
          MaxLength = 0
          NameRec = 'DWPrm'
          NameRecFld = 'ZGL'
          Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
          Vid = 'TSimpleGet'
          ParentShowHint = False
          ShowHint = True
          SayCaption = #1047#1072#1075#1086#1083#1086#1074#1086#1082
          SayRight = False
          TabOrder = 1
          TabStop = True
        end
        object ESortMode: TFldEdit
          Left = 120
          Top = 8
          Width = 86
          Height = 26
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CharCase = ecNormal
          CharWidth = 0
          CharHeight = 0
          Mask = '@NB0'
          MaxLength = 0
          NameRec = 'DWPrm'
          NameRecFld = 'SORTMODE'
          Vid = 'TRadioGet'
          VName = 'DWPrmSort'
          OnChange = ESortModeChange
          ParentShowHint = False
          ShowHint = True
          SayCaption = #1057#1086#1088#1090#1080#1088#1086#1074#1082#1072
          SayRight = False
          TabOrder = 0
          TabStop = True
          Visible = False
        end
        object EAskByCancel: TFldEdit
          Left = 261
          Top = 28
          Width = 170
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
          Mask = #1047#1072#1087#1088#1086#1089' '#1085#1072' '#1089#1086#1093#1088#1072#1085#1077#1085#1080#1077
          MaxLength = 0
          NameRec = 'DWPrm'
          NameRecFld = 'ASKBYCANCEL'
          Value = 'F'
          Vid = 'TBoolGet'
          OnChange = EAskByCancelChange
          ParentShowHint = False
          ShowHint = True
          SayRight = False
          TabOrder = 2
          TabStop = True
        end
        object EForm: TFldEdit
          Left = 289
          Top = 56
          Width = 156
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
          CharWidth = 0
          CharHeight = 0
          Mask = '@H'#1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1092#1086#1088#1084#1099'@EdFormEd('#1053#1045#1058')'
          MaxLength = 0
          Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
          Vid = 'TBtMskGet'
          ParentShowHint = False
          ShowHint = True
          SayRight = False
          TabOrder = 3
          TabStop = True
          Visible = False
        end
      end
      object PnForm: TRbPanel
        Left = 8
        Top = 92
        Width = 572
        Height = 227
        MinSized = False
        ParentSchem = True
        Schem = 'Edit'
        CanSize = False
        CanMove = False
        MaxWidth = False
        Header = #1060#1086#1088#1084#1091#1083#1099
        ProcentWnd = 100
        SortMode = smDefault
        SortObj = False
        BevelOuter = bvLowered
        HMin = 0
        Place = rpNone
        SayRight = False
        TabOrder = 1
        WMin = 0
        OnResize = PnFormResize
      end
    end
  end
  object Rec: TRecVal
    NameRec = 'DWPrm'
    Fields.Strings = (
      'Zgl=S60'
      'SortMode=N'
      'AskByCancel=L')
    Left = 48
    Top = 8
  end
  object FormGet: TButGet
    VName = 'DWForm'
    OnClick = FormGetClick
    Left = 321
    Top = 122
  end
end
