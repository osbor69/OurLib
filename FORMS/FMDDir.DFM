inherited MDDir: TMDDir
  Caption = ''
  Menu = KeyMenu1
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      NmProc.Strings = (
        'Esc#'#1054#1090#1084#1077#1085#1072'##FILE##'
        'Enter#'#1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100'##LIST##'
        'Space#'#1054#1090#1084#1077#1090#1080#1090#1100'##LIST##'
        'Plus#'#1054#1090#1084#1077#1090#1080#1090#1100' '#1074#1089#1077'##LIST##'
        'Minus#'#1057#1085#1103#1090#1100' '#1089#1086' '#1074#1089#1077#1093'#'#1057#1085#1103#1090#1100' '#1086#1090#1084#1077#1090#1082#1091' '#1089#1086' '#1074#1089#1077#1093'#LIST##'
        'F10#'#1057#1082#1086#1087#1080#1088'.'#1086#1090#1084#1077#1095'.#'#1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1086#1090#1084#1077#1095#1077#1085#1085#1099#1077' '#1086#1089#1085#1086#1074#1099'#LIST##'
        'F5#'#1054#1087#1080#1089#1072#1085#1080#1077'##LIST##'
        'Ins#####Space'
        'F2#####Plus'
        'F3#####Minus'
        'F11#'#1057#1086#1088#1090#1080#1088#1086#1074#1082#1072'##LIST##')
    end
    inherited RbPanel2: TRbPanel
      ParentSchem = False
      Schem = 'Browl'
      object sb: TStringBrowl
        Left = 42
        Top = 42
        Width = 283
        Height = 106
        FixedCols = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSizing, goColSizing, goRowSelect]
        TabOrder = 0
        OnMouseUp = sbMouseUp
        KeyDblClick = 13
        TitleFont.Charset = RUSSIAN_CHARSET
        TitleFont.Color = clBlack
        TitleFont.Height = -15
        TitleFont.Name = 'Courier New'
        TitleFont.Style = []
        OnAfterPaint = sbAfterPaint
        ColZn.Strings = (
          '##'
          #1050#1086#1076'##L'
          #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077'##L'
          #1042#1077#1088#1089#1080#1103'##R'
          #1044#1072#1090#1072'###18')
        SelectedOnlyFocused = False
        OnCalcZn = sbCalcZn
        OnWidthCols = sbWidthCols
        ColWidths = (
          -1
          31
          112
          58
          130)
        RowHeights = (
          21
          24
          24
          24
          24)
      end
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 16
    Top = 8
  end
  object de: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      #1047#1072#1087#1080#1089#1072#1090#1100' '#1082#1072#1082'##COD#TSimpleGet###0#2#T#F#T#F#F####0#0#F#F#F#T')
    HelpContext = 0
    NmProc.Strings = (
      'Ctrl_Q#'#1055#1088#1077#1088#1074#1072#1090#1100'#'#1055#1088#1077#1088#1074#1072#1090#1100' '#1082#1086#1087#1080#1088#1086#1074#1072#1085#1080#1077'#FILE'
      'F2#'#1055#1077#1088#1077#1087#1080#1089#1072#1090#1100' '#1074#1089#1077'##FILE'
      'F3#'#1053#1077' '#1087#1077#1088#1077#1087#1080#1089#1099#1074#1072#1090#1100' '#1074#1089#1077'##FILE')
    NameWnd = 'ModelCopy'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnKpProcKey = deKpProcKey
    OnPnlCngKey = dePnlCngKey
    Left = 88
    Top = 9
  end
end
