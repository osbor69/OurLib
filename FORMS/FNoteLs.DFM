inherited NoteLs: TNoteLs
  Caption = ''
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      Place = rpTop
      inherited RbPanel3: TRbPanel
        inherited Browl1: TBrowl
          NmProc.Strings = (
            'F4#'#1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100'##LIST##'
            'F5#'#1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100'##LIST##'
            'F7#'#1044#1086#1073#1072#1074#1080#1090#1100'##LIST##'
            'F8#'#1059#1076#1072#1083#1080#1090#1100'##LIST##'
            'Enter#####F5'
            'Space#'#1054#1090#1084#1077#1090#1080#1090#1100'##LIST##'
            'Ins#####Space'
            'Ctrl_F5##'#1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1082#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081'#LIST##'
            'Ctrl_F6#'#1055#1077#1095#1072#1090#1100'#'#1055#1077#1095#1072#1090#1100' '#1090#1077#1082#1091#1097#1077#1081' '#1079#1072#1087#1080#1089#1080'#LIST##'
            'Alt_F6##'#1055#1086#1080#1089#1082' '#1087#1086' '#1089#1086#1076#1077#1088#1078#1080#1084#1086#1084#1091'#LIST##')
          OnBrowlKey = Browl1BrowlKey
          OnDrawColumnCell = Browl1DrawColumnCell
        end
      end
      inherited RbPanel4: TRbPanel
        ParentSchem = False
        Schem = 'EdTxt'
        BevelOuter = bvNone
      end
    end
  end
  object de: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      '#NoteLs#Z#TMultiGet##2#0#1#T#F#T#F#F####0#0#F#F#F#F'
      #1044#1072#1090#1072'#Note#D#TDateGet##@WEEK#0#1#T#F#T#F#F###NoteLs.Z#0#0#F#F#F#F'
      '#NoteLs#T####0#1#T#F#T#F#F###NoteLs.Z#0#0#F#F'
      
        #1057#1083#1091#1078#1077#1073#1085#1099#1081' '#1085#1086#1084#1077#1088'#Note#SYSNUM#TSpinGet###0#1#T#F#T#F#F###NoteLs.Z#' +
        '0#0#F#F#F#F'
      #1047#1072#1075#1086#1083#1086#1074#1086#1082'#Note#ZGL#TSimpleGet###0#1#T#F#T#F#F####0#0#F#F#F#T'
      
        '#Note#MEM_TXT#TMemoGet##0,0,0,3,'#1058#1077#1082#1089#1090'#0#1#F#F#T#F#F####-1#-1#F#F' +
        '#F#F')
    HelpContext = 0
    NameWnd = 'Note'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFrmShow = deFrmShow
    OnPnlValid = dePnlValid
    Left = 112
  end
  object Rec: TRecVal
    NameRec = 'NoteLs'
    Fields.Strings = (
      'Z=L'
      'T=S5'
      'USER=S10')
    Left = 48
    Top = 33
  end
  object deUser: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1048#1089#1087#1086#1083#1085#1080#1090#1077#1083#1100
    Fields.Strings = (
      '#NoteLs#USER#TSimpleGet###0#1#T#F#T#F#F####0#0#F#F#F#F')
    HelpContext = 0
    NameWnd = 'NoteUser'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFldCheck = deUserFldCheck
    Left = 184
  end
end
