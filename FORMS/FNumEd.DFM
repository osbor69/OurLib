inherited NumEd: TNumEd
  Caption = ''
  Menu = KeyMenu1
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      Font.Charset = RUSSIAN_CHARSET
      Font.Style = []
      NmProc.Strings = (
        'Esc#'#1054#1090#1084#1077#1085#1072'##FILE'
        'F10#'#1057#1086#1093#1088#1072#1085#1080#1090#1100'##FILE')
    end
    inherited RbPanel2: TRbPanel
      object tbl: TStrTable
        Left = 155
        Top = 64
        Width = 283
        Height = 105
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goRowSizing, goColSizing]
        TabOrder = 0
        OnKeyPress = tblKeyPress
        KeyDblClick = 13
        TitleFont.Charset = RUSSIAN_CHARSET
        TitleFont.Color = clBlack
        TitleFont.Height = -15
        TitleFont.Name = 'Courier New'
        TitleFont.Style = []
        MinColLength = 0
        InvertedIniDefault = False
        OnFill = tblFill
      end
      object pnEd: TPanelEdit
        Left = 318
        Top = 21
        Width = 163
        Height = 36
        MinSized = False
        ParentSchem = False
        Schem = 'Edit'
        CanSize = False
        CanMove = False
        MaxWidth = False
        ProcentWnd = 0
        SortMode = smDefault
        SortObj = False
        BevelOuter = bvNone
        HMin = 0
        Place = rpNone
        SayRight = False
        TabOrder = 1
        Visible = False
        WMin = 0
        MasterControl = tbl
        Options = [peCheckOnExit]
        OnBeforeSimpleEdit = pnEdBeforeSimpleEdit
        OnEscape = pnEdEscape
        OnValid = pnEdValid
        object Ed: TFldEdit
          Left = 0
          Top = 0
          Width = 82
          Height = 25
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CharCase = ecNormal
          CharWidth = 0
          CharHeight = 0
          MaxLength = 0
          NameRec = 'NumEd'
          Vid = 'TSimpleGet'
          ParentShowHint = False
          ShowHint = True
          SayRight = False
          TabOrder = 0
          TabStop = True
        end
      end
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 16
    Top = 8
  end
  object Rec: TRecVal
    NameRec = 'NumEd'
    Fields.Strings = (
      'N=F')
    Left = 48
    Top = 8
  end
end
