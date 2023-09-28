inherited StackEr: TStackEr
  ActiveControl = EPath
  Caption = #1054#1096#1080#1073#1082#1080' '#1089#1090#1077#1082#1072
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
          NameRec = 'StackEr'
          NameRecFld = 'PATH'
          Vid = 'TDirGet'
          VName = 'StackEr'
          OnCheck = EPathCheck
          SayCaption = ' '#1055#1072#1087#1082#1072' '
          SayRight = False
          TabOrder = 0
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
          Left = 8
          Top = 41
          Width = 601
          Height = 120
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
            #1054#1096#1080#1073#1082#1072'##L#-1')
          SelectedOnlyFocused = False
          ColWidths = (
            40
            49
            499)
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
    NameRec = 'StackEr'
    Fields.Strings = (
      'Path=M')
    Left = 48
    Top = 8
  end
  object DirGet1: TDirGet
    VName = 'StackEr'
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
end
