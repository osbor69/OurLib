inherited EdoExUs: TEdoExUs
  Caption = #1055#1088#1086#1075#1088#1072#1084#1084#1099' '#1080' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080' '#1069#1044#1054
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      Font.Charset = RUSSIAN_CHARSET
      Font.Height = -12
      Font.Style = []
      NmProc.Strings = (
        'Esc#'#1042#1099#1093#1086#1076'##FILE##'
        'F10#####Esc'
        'F3#'#1057#1084#1077#1085#1080#1090#1100'#'#1057#1084#1077#1085#1080#1090#1100' '#1085#1086#1084#1077#1088' '#1087#1088#1086#1075#1088#1072#1084#1084#1099'#LIST##'
        'F4#'#1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100'#'#1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1087#1088#1086#1075#1088#1072#1084#1084#1091'#LIST##'
        'F5#'#1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100'#'#1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1087#1088#1086#1075#1088#1072#1084#1084#1091'#LIST##'
        'F7#'#1044#1086#1073#1072#1074#1080#1090#1100'#'#1044#1086#1073#1072#1074#1080#1090#1100' '#1087#1088#1086#1075#1088#1072#1084#1084#1091'#LIST##'
        'F8#'#1059#1076#1072#1083#1080#1090#1100'#'#1059#1076#1072#1083#1080#1090#1100' '#1087#1088#1086#1075#1088#1072#1084#1084#1091'#LIST##'
        
          'Enter#'#1048#1084#1103' '#1076#1083#1103' '#1074#1093#1086#1076#1072'#'#1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1080#1084#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103' '#1076#1083#1103' '#1074#1093#1086#1076#1072' '#1074' '#1087 +
          #1088#1086#1075#1088#1072#1084#1084#1091'#LIST##'
        'Ctrl_R#'#1054#1073#1085#1086#1074#1080#1090#1100'##LIST##'
        'Alt_F3##'#1057#1086#1079#1076#1072#1090#1100' '#1086#1089#1085#1086#1074#1091'#LIST##'
        'Alt_F5##'#1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1080#1079' '#1086#1089#1085#1086#1074#1099'#LIST##')
    end
    inherited RbPanel2: TRbPanel
      ParentSchem = False
      Schem = 'Browl'
      object tbl: TStrTable
        Left = 111
        Top = 94
        Width = 320
        Height = 120
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goRowSizing, goColSizing]
        TabOrder = 0
        KeyDblClick = 13
        TitleFont.Charset = RUSSIAN_CHARSET
        TitleFont.Color = clBlack
        TitleFont.Height = -12
        TitleFont.Name = 'Courier New'
        TitleFont.Style = []
        CaptX = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080
        CaptY = #1055#1088#1086#1075#1088#1072#1084#1084#1099
        MinColLength = 0
        InvertedIniDefault = False
        OnFill = tblFill
      end
    end
  end
  object deExe: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      #1053#1086#1084#1077#1088'#EDOEXE#KE#TSimpleGet###0#1#T#F#T#F#F####0#0#F#F#F#F'
      
        #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077'#EDOEXE#NAME#TSimpleGet###0#1#T#F#T#F#F####0#0#F#F#F' +
        '#T')
    HelpContext = 0
    NameWnd = 'EdoExe'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFldCheck = deExeFldCheck
    OnFldChange = deExeFldChange
    OnFldExit = deExeFldExit
    Left = 64
    Top = 8
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 32
    Top = 8
  end
  object InGet: TButTextGet
    Hint = #1042#1089#1090#1072#1074#1080#1090#1100' '#1089#1083#1091#1078#1077#1073#1085#1099#1081' '#1082#1086#1076
    Picture = 'Ourl_Plus'
    TextReadOnly = False
    OnClick = InGetClick
    VName = 'EdoExeIn'
    Left = 96
    Top = 8
  end
  object deUs: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      
        #1048#1084#1103' '#1076#1083#1103' '#1074#1093#1086#1076#1072'#EDOUS#LOGIN#TSimpleGet###0#1#T#F#T#F#F####0#0#F#F#' +
        'F#T'
      
        #1054#1090#1087#1077#1095#1072#1090#1086#1082' '#1089#1077#1088#1090#1080#1092#1080#1082#1072#1090#1072'#EDOUS#CERT#TSimpleGet###0#1#T#F#T#F#F####0' +
        '#0#F#F#F#T')
    HelpContext = 0
    NameWnd = 'EdoUs'
    PnlAskByCancel = False
    PnlSortMode = smColumns
    OnPnlUpdateRec = deUsPnlUpdateRec
    OnPnlValid = deUsPnlValid
    Left = 128
    Top = 8
  end
end
