inherited DWPage: TDWPage
  Caption = #1057#1090#1088#1072#1085#1080#1094#1099
  Menu = KeyMenu1
  PixelsPerInch = 120
  TextHeight = 17
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      NmProc.Strings = (
        'Esc#'#1042#1099#1093#1086#1076'##FILE##'
        'F10#####Esc'
        'F5#'#1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100'##LIST##'
        'Enter#####F5'
        'Space#####F5')
    end
    inherited RbPanel2: TRbPanel
      object sb: TStringBrowl
        Left = 32
        Top = 72
        Width = 593
        Height = 120
        ColCount = 2
        FixedCols = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goDrawFocusSelected, goRowSizing, goColSizing, goRowSelect]
        TabOrder = 0
        OnKeyUp = sbKeyUp
        OnMouseUp = sbMouseUp
        KeyDblClick = 13
        TitleFont.Charset = RUSSIAN_CHARSET
        TitleFont.Color = clBlack
        TitleFont.Height = -15
        TitleFont.Name = 'Courier New'
        TitleFont.Style = []
        OnBeforeDrawCell = sbBeforeDrawCell
        ColZn.Strings = (
          #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077'##L#-1'
          #1057#1086#1088#1090#1080#1088#1086#1074#1082#1072'##')
        SelectedOnlyFocused = False
        OnCalcZn = sbCalcZn
        ColWidths = (
          534
          94)
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
    Top = 9
  end
  object Rec: TRecVal
    NameRec = 'DWPage'
    Fields.Strings = (
      'NAME=M'
      'SORTMODE=N'
      'NoVisible=L')
    Left = 48
    Top = 9
  end
  object de: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1089#1090#1088#1072#1085#1080#1094#1099' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1103
    Fields.Strings = (
      #1053#1072#1079#1074#1072#1085#1080#1077'#DWPage#NAME#TSimpleGet###0#1#T#F#T#F#F####-1#0#F#F#F#T'
      
        #1057#1086#1088#1090#1080#1088#1086#1074#1082#1072'#DWPage#SORTMODE#TRadioGet#DWPrmSort#@NB0#0#1#T#F#T#F#' +
        'F####0#0#F#F'
      
        '##FORM#TBtMskGet##@H'#1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1092#1086#1088#1084#1099'@EdFormEd()#0#1#T#F#T#T#' +
        'F####0#0#F#F'
      '#DWPage#NOVISIBLE#TBoolGet##'#1053#1077#1074#1080#1076#1080#1084#1072#1103'#0#1#T#F#T#F#F####0#0#F#F')
    HelpContext = 0
    NameWnd = 'DWPage'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFldChange = deFldChange
    OnPnlValid = dePnlValid
    Left = 80
    Top = 8
  end
end
