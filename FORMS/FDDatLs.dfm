inherited DDatLs: TDDatLs
  Caption = ''
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      inherited Browl1: TBrowl
        NmProc.Strings = (
          'F4#'#1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100'##LIST##'
          'F5#'#1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100'##LIST##'
          'F7#'#1044#1086#1073#1072#1074#1080#1090#1100'##LIST##'
          'F8#'#1059#1076#1072#1083#1080#1090#1100'##LIST##'
          'Enter#####F5')
        OnBrowlKey = Browl1BrowlKey
        OnDrawColumnCell = Browl1DrawColumnCell
      end
    end
  end
  object de: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      #1055#1077#1088#1080#1086#1076':#DDatLs#D#TMultiGet###0#1#T#F#T#F#F####0#0#F#F'
      #1085#1072#1095#1072#1083#1086'#DDatLs#D1#TDateGet###0#1#T#F#T#F#F###DDatLs.D#0#0#F#F'
      #1082#1086#1085#1077#1094'#DDat#D2#TDateGet###0#1#T#F#T#F#F###DDatLs.D#0#0#F#F'
      '#DDatLs#ZN####0#1#T#F#T#F#F####0#0#F#F#F#F')
    HelpContext = 0
    NameWnd = 'DDat'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFldCheck = deFldCheck
    OnFldExit = deFldExit
    OnFrmShow = deFrmShow
    OnPnlValid = dePnlValid
    Left = 144
  end
  object Rec: TRecVal
    Fields.Strings = (
      'D=L'
      'D1=D')
    Left = 112
  end
end
