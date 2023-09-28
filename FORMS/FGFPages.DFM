inherited GFPages: TGFPages
  Caption = #1057#1087#1080#1089#1086#1082' '#1083#1080#1089#1090#1086#1074
  PixelsPerInch = 120
  TextHeight = 17
  inherited RbPanel1: TRbPanel
    Schem = 'Browl'
    Place = rpRight
    inherited KeyLb1: TKeyLb
      NmProc.Strings = (
        'Esc#'#1054#1090#1084#1077#1085#1072'####'
        'F10#####Enter'
        'Enter#'#1042#1099#1073#1086#1088'####')
    end
    inherited RbPanel2: TRbPanel
      Schem = 'Browl'
      ParentColor = True
      object sb: TStringBrowl
        Left = 88
        Top = 32
        Width = 320
        Height = 120
        ColCount = 1
        FixedCols = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSizing, goColSizing, goRowSelect]
        TabOrder = 0
        OnKeyPress = sbKeyPress
        OnMouseDown = sbMouseDown
        OnMouseMove = sbMouseMove
        OnMouseUp = sbMouseUp
        KeyDblClick = 13
        TitleFont.Charset = RUSSIAN_CHARSET
        TitleFont.Color = clBlack
        TitleFont.Height = -15
        TitleFont.Name = 'Courier New'
        TitleFont.Style = []
        SelectedOnlyFocused = False
        OnCalcZn = sbCalcZn
        ColWidths = (
          40)
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
