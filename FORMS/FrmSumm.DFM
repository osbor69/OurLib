inherited FormSumm: TFormSumm
  Left = 297
  Top = 149
  Width = 807
  Height = 589
  Caption = 'FormSumm'
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
        'F3#'#1057#1084#1077#1085#1080#1090#1100'#'#1057#1084#1077#1085#1080#1090#1100' '#1085#1086#1084#1077#1088' '#1090#1072#1073#1083#1080#1094#1099'#FILE##'
        'Alt_G#####F3')
    end
    inherited RbPanel2: TRbPanel
      ParentSchem = False
      Schem = 'Browl'
      Place = rpBottom
    end
  end
  object Rec: TRecVal
    NameRec = 'SummShow'
    Fields.Strings = (
      'NTBL=N')
    Left = 24
    Top = 17
  end
  object de: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1057#1084#1077#1085#1080#1090#1100' '#1085#1086#1084#1077#1088' '#1090#1072#1073#1083#1080#1094#1099
    Fields.Strings = (
      
        #1053#1086#1074#1099#1081' '#1085#1086#1084#1077#1088' '#1090#1072#1073#1083#1080#1094#1099'#SummShow#NTBL#TSpinGet###0#1#T#F#T#F#F####0#' +
        '0#F#F#F#F')
    HelpContext = 0
    NameWnd = 'SummShow'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    Left = 64
    Top = 17
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 96
    Top = 16
  end
end
