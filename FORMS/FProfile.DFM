inherited Profile: TProfile
  Left = 245
  Top = 158
  Caption = #1055#1088#1086#1092#1072#1081#1083#1077#1088
  Menu = KeyMenu1
  WindowState = wsMaximized
  PixelsPerInch = 120
  TextHeight = 17
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      Left = 25
      Top = 18
      ParentSchem = False
      Schem = 'Browl'
      object sb: TStringBrowl
        Left = 48
        Top = 48
        Width = 513
        Height = 137
        ColCount = 6
        FixedCols = 0
        RowCount = 6
        FixedRows = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSizing, goColSizing, goRowSelect]
        TabOrder = 0
        KeyDblClick = 13
        TitleFont.Charset = RUSSIAN_CHARSET
        TitleFont.Color = clBlack
        TitleFont.Height = -15
        TitleFont.Name = 'Courier New'
        TitleFont.Style = []
        ColZn.Strings = (
          #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077'##L'
          #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086'^'#1074#1099#1079#1086#1074#1086#1074'##R'
          #1063#1080#1089#1090#1086#1077' '#1074#1088#1077#1084#1103':##'
          #1063#1080#1089#1090#1086#1077' '#1074#1088#1077#1084#1103'^'#1085#1072' 1 '#1074#1099#1079#1086#1074'##'
          #1054#1073#1097#1077#1077' '#1074#1088#1077#1084#1103'##'
          #1054#1073#1097#1077#1077' '#1074#1088#1077#1084#1103'^'#1085#1072' 1 '#1074#1099#1079#1086#1074'##')
        SelectedOnlyFocused = False
        ColWidths = (
          112
          94
          121
          112
          103
          103)
        RowHeights = (
          21
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
    Top = 1
  end
  object de: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074' '#1092#1072#1081#1083
    Fields.Strings = (
      '#Profile#FILE#TDirGet#Profile##0#1#T#F#T#F#F####-1#0#F#F')
    HelpContext = 0
    NameWnd = 'Profile'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    Left = 64
  end
  object Rec: TRecVal
    NameRec = 'Profile'
    Fields.Strings = (
      'FILE=M')
    Left = 32
  end
  object DirGet1: TDirGet
    VName = 'Profile'
    OpenDialog = SaveDialog1
    Options = [dgNoCheckDir]
    Left = 104
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'PRF'
    Filter = #1060#1072#1081#1083#1099' '#1087#1088#1086#1092#1072#1081#1083#1077#1088#1072' (*.pfd)|*.PFD|'#1042#1089#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
    Left = 136
  end
end
