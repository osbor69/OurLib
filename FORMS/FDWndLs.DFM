inherited DWndLs: TDWndLs
  Caption = ' '
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      inherited Browl1: TBrowl
        NmProc.Strings = (
          'F3#'#1057#1084#1077#1085#1080#1090#1100'#'#1057#1084#1077#1085#1080#1090#1100' '#1082#1086#1076'#LIST##'
          'F4#'#1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100'##LIST##'
          'F5#'#1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100'##LIST##'
          'F7#'#1044#1086#1073#1072#1074#1080#1090#1100'##LIST##'
          'F8#'#1059#1076#1072#1083#1080#1090#1100'##LIST##'
          'Alt_F3###LIST##'
          'Alt_F3#'#1057#1086#1079#1076#1072#1090#1100' '#1086#1089#1085#1086#1074#1091'##LIST##'
          'Alt_F5#'#1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1080#1079' '#1086#1089#1085#1086#1074#1099'##LIST##'
          'Alt_F8#'#1054#1090#1084#1077#1090#1080#1090#1100' '#1091#1089#1090#1072#1088#1077#1074#1096#1080#1077'##LIST##'
          'Enter#####F5')
        OnBrowlKey = Browl1BrowlKey
        OnGrayCell = Browl1GrayCell
        OnTransSeek = Browl1TransSeek
      end
    end
  end
  object de: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      '#NONE#OSN#TMultiGet##1#0#1#T#F#F#F#F####-1#0#F#F#F#F'
      #1050#1086#1076'#DWND#KW#TSimpleGet###0#2#T#F#T#F#F###NONE.OSN#0#0#F#F#F#T'
      
        #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077'#DWND#NAME#TSimpleGet###0#1#T#F#T#F#F###NONE.OSN#0#0' +
        '#F#F#F#T'
      '##DW#TMultiGet##1#0#1#T#F#T#F#F####-1#-1#F#F#F#F'
      #1054#1089#1085#1086#1074#1072'#DWND#MODEL###NMODEL#0#1#T#F#T#F#F###NONE.OSN#0#0#F#F#F#T')
    HelpContext = 0
    NameWnd = 'DWnd'
    PnlAskByCancel = True
    PnlSortMode = smDefault
    OnFldCheck = deFldCheck
    OnFrmHide = deFrmHide
    OnFrmShow = deFrmShow
    OnPnlValid = dePnlValid
    Left = 112
  end
  object DWGet: TButGet
    VName = 'DWnd'
    OnClick = DWGetClick
    OnPaint = DWGetPaint
    Left = 144
  end
end
