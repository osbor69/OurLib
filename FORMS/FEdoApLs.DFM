inherited EdoApLs: TEdoApLs
  Caption = ' '
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      inherited Browl1: TBrowl
        NmProc.Strings = (
          'F5#'#1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100'##LIST##'
          'F7#'#1044#1086#1073#1072#1074#1080#1090#1100'##LIST##'
          'F8#'#1059#1076#1072#1083#1080#1090#1100'##LIST##'
          'Enter#'#1055#1088#1086#1089#1084#1086#1090#1088'##LIST##'
          'Ctrl_Enter#'#1042#1099#1075#1088#1091#1079#1080#1090#1100'##LIST##')
        OnBrowlKey = Browl1BrowlKey
      end
    end
  end
  object de: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      
        #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077'#EDOAPP#NAME#TSimpleGet###0#1#T#F#T#F#F####-1#0#F#F#' +
        'F#F')
    HelpContext = 0
    NameWnd = 'EdoApp'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    Left = 144
  end
  object OpenDialog1: TOpenDialog
    Title = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1092#1072#1081#1083' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1103
    Left = 112
  end
end
