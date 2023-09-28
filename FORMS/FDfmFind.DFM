inherited DfmFind: TDfmFind
  ActiveControl = EPath
  Caption = #1055#1086#1080#1089#1082' '#1090#1077#1082#1089#1090#1072' '#1074' .DFM'
  Menu = KeyMenu1
  PixelsPerInch = 120
  TextHeight = 17
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      Font.Charset = RUSSIAN_CHARSET
      Font.Height = -15
      Font.Style = []
    end
    inherited RbPanel2: TRbPanel
      BevelOuter = bvNone
      Place = rpTop
      object pnEd: TPanelEdit
        Left = 40
        Top = 16
        Width = 601
        Height = 81
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
          Left = 80
          Top = 16
          Width = 86
          Height = 27
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CharCase = ecNormal
          CharWidth = -2
          CharHeight = 0
          Mask = #1055#1072#1087#1082#1072' '#1076#1083#1103' '#1087#1086#1080#1089#1082#1072'#'
          MaxLength = 0
          NameRec = 'DfmFind'
          NameRecFld = 'PATH'
          Vid = 'TDirGet'
          VName = 'DfmFind'
          OnCheck = EPathCheck
          SayCaption = ' '#1055#1072#1087#1082#1072' '
          SayRight = False
          TabOrder = 0
          TabStop = True
        end
        object EStr: TFldEdit
          Left = 88
          Top = 48
          Width = 86
          Height = 27
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CharCase = ecNormal
          CharWidth = -2
          CharHeight = 0
          MaxLength = 0
          NameRec = 'DfmFind'
          NameRecFld = 'STR'
          Vid = 'TComboGet'
          VName = 'DfmFind'
          SayCaption = ' '#1053#1072#1081#1090#1080' '
          SayRight = False
          TabOrder = 1
          TabStop = True
        end
      end
      object pnLs: TRbPanel
        Left = 32
        Top = 112
        Width = 609
        Height = 233
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
          Left = 137
          Top = 41
          Width = 320
          Height = 120
          ColCount = 2
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
            #1060#1072#1081#1083'##L#20'
            #1055#1072#1087#1082#1072'##L#-1')
          SelectedOnlyFocused = False
          ColWidths = (
            184
            406)
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
    NameRec = 'DfmFind'
    Fields.Strings = (
      'Path=M'
      'Str=M')
    Left = 48
    Top = 8
  end
  object DirGet1: TDirGet
    VName = 'DfmFind'
    Options = [dgCreatePrompt]
    Left = 88
    Top = 9
  end
  object StrGet: TComboGet
    VName = 'DfmFind'
    Duplicates = dupIgnore
    ItemHeight = 0
    Sorted = False
    LenName = 0
    Left = 120
    Top = 9
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer1Timer
    Left = 152
    Top = 9
  end
end
