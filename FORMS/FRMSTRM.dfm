inherited FormStrm: TFormStrm
  Left = 336
  Top = 127
  Width = 700
  Height = 496
  ActiveControl = PnEdit
  Caption = 'FormStrm'
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    Width = 580
    Height = 381
    inherited KeyLb1: TKeyLb
      Top = 339
    end
    inherited RbPanel2: TRbPanel
      Width = 559
      BevelOuter = bvNone
      Place = rpTop
      object PnList: TRbPanel
        Left = 14
        Top = 14
        Width = 523
        Height = 121
        MinSized = False
        ParentSchem = False
        Schem = 'Browl'
        CanSize = False
        CanMove = False
        MaxWidth = False
        ProcentWnd = 50
        SortMode = smDefault
        SortObj = True
        BevelOuter = bvLowered
        HMin = 0
        Place = rpNone
        SayRight = False
        TabOrder = 0
        WMin = 0
        object sb: TStringBrowl
          Left = 120
          Top = 7
          Width = 282
          Height = 106
          ColCount = 1
          Enabled = False
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
          OnBeforeDrawCell = sbBeforeDrawCell
          SelectedOnlyFocused = False
          RowHeights = (
            21
            24
            24
            24
            24)
        end
      end
      object PnEdit: TPanelEdit
        Left = 14
        Top = 155
        Width = 523
        Height = 149
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
        OnEnter = PnEditEnter
        MasterControl = sb
        Options = [peCloseOnEsc]
        OnBeforeEnter = PnEditBeforeEnter
        OnBeforeExit = PnEditBeforeExit
        OnBeforeMasterFocus = PnEditBeforeMasterFocus
        OnValid = PnEditValid
      end
    end
  end
  object tmClose: TTimer
    Enabled = False
    Interval = 1
    OnTimer = tmCloseTimer
    Left = 8
    Top = 8
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 40
    Top = 8
  end
end
