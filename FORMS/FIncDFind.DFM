inherited IncDFind: TIncDFind
  Width = 946
  Height = 566
  ActiveControl = EPath
  Caption = #1055#1086#1080#1089#1082' '#1076#1083#1103' '#1080#1089#1087#1086#1083#1100#1079#1086#1074#1072#1085#1080#1103' '#1092#1091#1085#1082#1094#1080#1081
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    Width = 820
    inherited KeyLb1: TKeyLb
      Font.Charset = RUSSIAN_CHARSET
      Font.Style = []
    end
    inherited RbPanel2: TRbPanel
      Width = 784
      BevelOuter = bvNone
      Place = rpTop
      object pnEd: TPanelEdit
        Left = 35
        Top = 14
        Width = 735
        Height = 72
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
        OnEnter = pnEdEnter
        MasterControl = sb
        Options = [peCheckOnExit, peCloseOnEsc]
        OnValid = pnEdValid
        object EPath: TFldEdit
          Left = 71
          Top = 14
          Width = 86
          Height = 25
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CharCase = ecNormal
          CharWidth = -2
          CharHeight = 0
          Mask = #1055#1072#1087#1082#1072' '#1076#1083#1103' '#1087#1086#1080#1089#1082#1072'#'
          MaxLength = 0
          NameRec = 'IncDFind'
          NameRecFld = 'PATH'
          Vid = 'TDirGet'
          VName = 'IncDFind'
          ParentShowHint = False
          ShowHint = True
          SayCaption = ' '#1055#1072#1087#1082#1072' '
          SayRight = False
          TabOrder = 0
          TabStop = True
        end
        object pnFunc: TRbPanel
          Left = 71
          Top = 35
          Width = 664
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
          SayCaption = ' '#1060#1091#1085#1082#1094#1080#1103' '
          SayRight = False
          TabOrder = 1
          WMin = 0
          object EFunc: TFldEdit
            Left = 0
            Top = 5
            Width = 63
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRec = 'IncDFind'
            NameRecFld = 'FUNC'
            Value = '0'
            Vid = 'TMenuGet'
            VName = 'IncDFind'
            OnChange = EFuncChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 0
            TabStop = True
          end
          object EOnlyWord: TFldEdit
            Left = 136
            Top = 3
            Width = 190
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = #1058#1086#1083#1100#1082#1086' '#1089#1083#1086#1074#1086' '#1094#1077#1083#1080#1082#1086#1084
            MaxLength = 0
            NameRec = 'IncDFind'
            NameRecFld = 'ONLYWORD'
            Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = EFuncChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 1
            TabStop = True
          end
        end
      end
      object pnLs: TRbPanel
        Left = 28
        Top = 99
        Width = 538
        Height = 205
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
        TabOrder = 1
        WMin = 0
        object sb: TStringBrowl
          Left = 7
          Top = 36
          Width = 530
          Height = 106
          ColCount = 3
          FixedCols = 0
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSizing, goColSizing, goRowSelect]
          TabOrder = 0
          OnEnter = sbEnter
          OnExit = sbExit
          KeyDblClick = 13
          TitleFont.Charset = RUSSIAN_CHARSET
          TitleFont.Color = clBlack
          TitleFont.Height = -15
          TitleFont.Name = 'Courier New'
          TitleFont.Style = []
          ColZn.Strings = (
            #1060#1072#1081#1083'##L'
            #1055#1072#1087#1082#1072'##L'
            #1058#1077#1082#1089#1090'##L#-1')
          SelectedOnlyFocused = False
          ColWidths = (
            40
            49
            428)
          RowHeights = (
            21
            24
            24
            24
            24)
        end
      end
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 8
    Top = 8
  end
  object Rec: TRecVal
    NameRec = 'IncDFind'
    Fields.Strings = (
      'Path=M'
      'Func=N'
      'OFunc=S30'
      'Uses=S8'
      'OnlyWord=L@H'#1058#1086#1083#1100#1082#1086' '#1089#1083#1086#1074#1086' '#1094#1077#1083#1080#1082#1086#1084'@')
    Left = 48
    Top = 8
  end
  object DirGet1: TDirGet
    VName = 'IncDFind'
    Options = [dgCreatePrompt]
    Left = 88
    Top = 9
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer1Timer
    Left = 152
    Top = 9
  end
  object FuncGet: TMenuGet
    VName = 'IncDFind'
    UserItems = False
    LenCode = 0
    LenName = 0
    Left = 384
    Top = 17
  end
  object BoolGet1: TBoolGet
    Left = 192
    Top = 8
  end
end
