inherited LockLst: TLockLst
  Caption = ''
  OnClose = FormClose
  PixelsPerInch = 120
  TextHeight = 17
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      NmProc.Strings = (
        'Esc#'#1054#1090#1084#1077#1085#1072'##FILE')
    end
    inherited RbPanel2: TRbPanel
      inherited Browl1: TBrowl
        NmProc.Strings = (
          'Enter#'#1057#1086#1086#1073#1097#1077#1085#1080#1077'#'#1054#1090#1087#1088#1072#1074#1080#1090#1100' '#1089#1086#1086#1073#1097#1077#1085#1080#1077' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1102'#LIST##'
          'F2#'#1042#1089#1077#1084'#'#1054#1090#1087#1088#1072#1074#1080#1090#1100' '#1089#1086#1086#1073#1097#1077#1085#1080#1077' '#1074#1089#1077#1084'#LIST##'
          'F5#'#1055#1077#1088#1080#1086#1076'#'#1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1087#1077#1088#1080#1086#1076' '#1086#1073#1085#1086#1074#1083#1077#1085#1080#1103' '#1089#1087#1080#1089#1082#1072'#EDIT##')
        OnBeforePaint = Browl1BeforePaint
        OnBrowlKey = Browl1BrowlKey
        OnGrayCell = Browl1GrayCell
        OnShowHint = Browl1ShowHint
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgRowSelect, dgAlwaysShowSelection]
        OnDrawColumnCell = Browl1DrawColumnCell
        OnMouseMove = Browl1MouseMove
      end
    end
  end
  object de: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      #1058#1077#1082#1089#1090' '#1089#1086#1086#1073#1097#1077#1085#1080#1103'#RSendMsg#MSG####0#1#T#F#T#F#F####0#0#F#F#F#F')
    HelpContext = 0
    NameWnd = 'SendMsg'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnPnlCngKey = dePnlCngKey
    Left = 504
    Top = 48
  end
  object Rec: TRecVal
    NameRec = 'RSendMsg'
    Fields.Strings = (
      'Msg=S50'
      'BrUpd=N')
    Left = 536
    Top = 48
  end
  object deIntv: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1054#1073#1085#1086#1074#1083#1077#1085#1080#1077' '#1089#1087#1080#1089#1082#1072' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081
    Fields.Strings = (
      
        #1055#1077#1088#1080#1086#1076' ('#1089#1077#1082'.)#RSendMsg#BRUPD#TSpinGet###0#1#T#F#T#F#F####0#0#F#F' +
        '#F#F')
    HelpContext = 0
    PnlAskByCancel = False
    PnlSortMode = smDefault
    Left = 505
    Top = 83
  end
end
