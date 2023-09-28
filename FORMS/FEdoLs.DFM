inherited EdoLs: TEdoLs
  Caption = ' '
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      inherited Browl1: TBrowl
        NmProc.Strings = (
          '')
        OnBrowlKey = Browl1BrowlKey
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgRowSelect, dgAlwaysShowSelection]
        OnDrawColumnCell = Browl1DrawColumnCell
      end
    end
  end
  object Rec: TRecVal
    NameRec = 'EdoLs'
    Fields.Strings = (
      'MODE=N@H'#1056#1077#1078#1080#1084' '#1087#1088#1086#1089#1084#1086#1090#1088#1072'@'
      'DB=D@H'#1053#1072#1095#1072#1083#1086' '#1087#1077#1088#1080#1086#1076#1072' '#1089#1086#1079#1076#1072#1085#1080#1103'@'
      'DE=D@H'#1050#1086#1085#1077#1094' '#1087#1077#1088#1080#1086#1076#1072' '#1089#1086#1079#1076#1072#1085#1080#1103'@'
      'D1B=D@H'#1053#1072#1095#1072#1083#1086' '#1087#1077#1088#1080#1086#1076#1072' '#1087#1086#1076#1087#1080#1089#1072#1085#1080#1103'@'
      'D1E=D@H'#1050#1086#1085#1077#1094' '#1087#1077#1088#1080#1086#1076#1072' '#1087#1086#1076#1087#1080#1089#1072#1085#1080#1103'@'
      'USERS=M@H'#1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080'@'
      'KVS=M@H'#1042#1080#1076#1099' '#1069#1044#1054'@'
      'ORGS=M@H'#1054#1088#1075#1072#1085#1080#1079#1072#1094#1080#1080'@'
      'PSWD=S20@H'#1055#1072#1088#1086#1083#1100'@'
      'FSAVE=M@H'#1048#1084#1103' '#1092#1072#1081#1083#1072' '#1076#1083#1103' '#1074#1099#1075#1088#1091#1079#1082#1080'@'
      'FOPEN=M@H'#1048#1084#1103' '#1092#1072#1081#1083#1072' '#1076#1083#1103' '#1079#1072#1075#1088#1091#1079#1082#1080'@'
      'PSAVE=M@H'#1048#1084#1103' '#1087#1072#1087#1082#1080' '#1076#1083#1103' '#1074#1099#1075#1088#1091#1079#1082#1080' '#1092#1072#1081#1083#1072' '#1076#1083#1103' '#1087#1086#1076#1087#1080#1089#1072#1085#1080#1103'@'
      'DELD=D@H'#1059#1076#1072#1083#1080#1090#1100' '#1076#1086' '#1076#1072#1090#1099'@'
      'POPEN=M@H'#1048#1084#1103' '#1079#1072#1075#1088#1091#1078#1072#1077#1084#1086#1075#1086' '#1087#1086#1076#1087#1080#1089#1072#1085#1085#1086#1075#1086' '#1092#1072#1081#1083#1072'@')
    Left = 120
  end
  object deFlt: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1060#1080#1083#1100#1090#1088
    Fields.Strings = (
      #1044#1072#1090#1072' '#1089#1086#1079#1076#1072#1085#1080#1103':#EdoLs#D#TMultiGet##2#0#1#T#F#T#F#F####0#0#F#F#F#F'
      #1089'#EdoLs#DB#TDateGet###0#1#T#F#T#F#F###EdoLs.D#0#0#F#F#F#F'
      #1087#1086'#EdoLs#DE#TDateGet###0#1#T#F#T#F#F###EdoLs.D#0#0#F#F#F#F'
      
        #1044#1072#1090#1072' '#1087#1086#1076#1087#1080#1089#1072#1085#1080#1103':#EdoLs#D1#TMultiGet##2#0#1#T#F#T#T#F####0#0#F#F#' +
        'F#F'
      #1089'#EdoLs#D1B#TDateGet###0#1#T#F#T#T#F###EdoLs.D1#0#0#F#F#F#F'
      #1087#1086'#EdoLs#D1E#TDateGet###0#1#T#F#T#T#F###EdoLs.D1#0#0#F#F#F#F'
      
        #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080'~('#1087#1091#1089#1090#1086' - '#1074#1089#1077')#EdoLs#USERS#TButTextGet#EdoUsers##0#1' +
        '#T#F#T#F#F####-2#0#F#F#F#T'
      
        #1042#1080#1076#1099' '#1069#1044#1054'~('#1087#1091#1089#1090#1086' - '#1074#1089#1077')#EdoLs#KVS#TButTextGet#EdoKvs##0#1#T#F#T#F' +
        '#F####-2#0#F#F#F#T'
      
        #1054#1088#1075#1072#1085#1080#1079#1072#1094#1080#1080'~('#1087#1091#1089#1090#1086' - '#1074#1089#1077')#EdoLs#ORGS####0#1#T#F#T#F#F####-2#0#F#' +
        'F#F#T')
    HelpContext = 0
    NameWnd = 'EdoFlt'
    PnlAskByCancel = False
    PnlSortMode = smColumns
    OnFldChange = deFltFldChange
    Left = 160
  end
  object de: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      #1055#1088#1086#1075#1088#1072#1084#1084#1072'#EdoLs#KE#TCodeGet#EdoExe##0#1#T#F#T#F#F####0#0#F#F#F#F'
      '#EdoLs#PSWD#TPswdGet###0#1#F#F#T#F#F####0#0#F#F#F#F')
    HelpContext = 0
    NameWnd = 'Edo'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    Left = 192
  end
  object FileGet: TDirGet
    VName = 'EdoFile'
    Options = []
    Left = 224
    Top = 32
  end
  object dlgFileOpen: TOpenDialog
    Left = 223
    Top = 94
  end
  object dlgFileSave: TSaveDialog
    Left = 223
    Top = 62
  end
  object deFile: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      '#EdoLs##TDirGet#EdoFile##0#1#T#F#T#F#F####-1#0#F#F#F#T')
    HelpContext = 0
    NameWnd = 'EdoFile'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFldCheck = deFileFldCheck
    Left = 224
  end
  object deSkip: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      #1055#1088#1080#1095#1080#1085#1072'#EDO#SKIPREASON####0#1#T#F#T#F#F####0#0#F#F#F#F')
    HelpContext = 0
    NameWnd = 'EdoSkip'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    Left = 256
  end
  object dmFmt: TDefMenu
    BevelInner = bvNone
    BevelOuter = bvLowered
    BevelWidth = 1
    BorderStyle = bsNone
    KeyBevel = 3
    KeySpot = 5
    KeyBetween = 5
    FrmBorderIcons = [biSystemMenu, biMinimize]
    FrmBorderStyle = bsSingle
    FrmCaption = #1048#1089#1093#1086#1076#1085#1099#1081' '#1092#1086#1088#1084#1072#1090
    Left = 288
  end
  object UsersGet: TButTextGet
    TextReadOnly = False
    OnClick = UsersGetClick
    VName = 'EdoUsers'
    Left = 160
    Top = 32
  end
  object KvsGet: TButTextGet
    TextReadOnly = False
    OnClick = KvsGetClick
    VName = 'EdoKvs'
    Left = 160
    Top = 64
  end
  object deDel: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1059#1076#1072#1083#1080#1090#1100' '#1076#1086#1082#1091#1084#1077#1085#1090#1099
    Fields.Strings = (
      #1044#1086' '#1076#1072#1090#1099'#EdoLs#DELD#TDateGet###0#1#T#F#T#F#F####0#0#F#F#F#F')
    HelpContext = 0
    NameWnd = 'EdoDel'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFldCheck = deDelFldCheck
    OnPnlValid = deDelPnlValid
    Left = 320
  end
end
