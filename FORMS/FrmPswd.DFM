inherited FormPswd: TFormPswd
  Top = 181
  Width = 755
  Height = 547
  ActiveControl = EUser
  Caption = 'FormPswd'
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      NmProc.Strings = ()
      OnProcKey = nil
    end
    inherited RbPanel2: TRbPanel
      BevelOuter = bvNone
      Place = rpTop
      object PnInfo: TRbPanel
        Left = 14
        Top = 14
        Width = 425
        Height = 79
        MinSized = False
        ParentSchem = True
        Schem = 'Edit'
        CanSize = False
        CanMove = False
        MaxWidth = False
        ProcentWnd = 0
        SortMode = smDefault
        SortObj = True
        BevelOuter = bvLowered
        HMin = 0
        Place = rpNone
        SayRight = False
        TabOrder = 0
        WMin = 0
      end
      object PnPsw: TPanelEdit
        Left = 7
        Top = 106
        Width = 425
        Height = 114
        MinSized = False
        ParentSchem = True
        Schem = 'Edit'
        CanSize = False
        CanMove = False
        MaxWidth = False
        ProcentWnd = 100
        SortMode = smDefault
        SortObj = True
        BevelOuter = bvLowered
        HMin = 0
        Place = rpNone
        SayRight = False
        TabOrder = 1
        WMin = 0
        Options = [peNoCloseForm]
        OnCngKey = PnPswCngKey
        OnValid = PnPswValid
        object EUser: TFldEdit
          Left = 78
          Top = 35
          Width = 96
          Height = 25
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CharCase = ecUpperCase
          CharWidth = 0
          CharHeight = 0
          MaxLength = 0
          NameRec = 'Pswd'
          NameRecFld = 'User'
          Options = [ogAutoSelect, ogAutoSize, ogTrimLeft]
          Vid = 'TSimpleGet'
          OnCheck = EUserCheck
          ParentShowHint = False
          ShowHint = True
          SayCaption = #1048#1084#1103
          SayRight = False
          TabOrder = 0
          TabStop = True
          OnEnter = EUserEnter
          OnExit = EUserExit
        end
        object EPswd: TFldEdit
          Left = 78
          Top = 64
          Width = 152
          Height = 25
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CharCase = ecNormal
          CharWidth = 0
          CharHeight = 0
          MaxLength = 0
          NameRec = 'Pswd'
          NameRecFld = 'Pswd'
          Vid = 'TPswdGet'
          ParentShowHint = False
          ShowHint = True
          SayRight = False
          TabOrder = 1
        end
      end
    end
  end
  object Rec: TRecVal
    NameRec = 'Pswd'
    Fields.Strings = (
      'User=S12'
      'Pswd=S10'
      'IDUpd=N'
      'Reg=M'
      'IconDefault=L'
      'Cop=L'
      'CopDir=M'
      'CopCnt=N'
      'CopDay=N'
      'NoSciLexer=L@H'#1053#1077' '#1080#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1088#1077#1076#1072#1082#1090#1086#1088' SciLexer@'
      'BrFindAll=L'
      'AlsFrom=M'
      'FormLimit=N'
      'FormLimTime=N'
      'SQLTBL=M'
      'DERFILE=N#1'
      'DERSTR=M'
      'DERD1=D'
      'DERD2=D'
      'DERIP=S255'
      'DERUSERNUM=S3'
      'DERBUILD=N'
      'DERDO=S2#++@H'#1058#1086#1083#1100#1082#1086' '#1074#1099#1087#1086#1083#1085#1077#1085#1085#1099#1077'/'#1085#1077#1074#1099#1087#1086#1083#1085#1077#1085#1085#1099#1077'@'
      'Z1=L'
      'Z2=L'
      'DLogDel=D@H'#1044#1072#1090#1072', '#1076#1086' '#1082#1086#1090#1086#1088#1086#1081' '#1091#1076#1072#1083#1103#1102#1090#1089#1103' '#1079#1072#1087#1080#1089#1080' '#1074' '#1078#1091#1088#1085#1072#1083#1077' '#1076#1077#1081#1089#1090#1074#1080#1081'@')
    Left = 8
    Top = 8
  end
  object RG: TRecDB
    NameRec = 'GlobSet'
    OnAfterOpen = RGAfterOpen
    DateWithTime = False
    NameDB = 'GLOBSET'
    Prim = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1076#1086#1089#1090#1091#1087#1072' '#1082' '#1076#1072#1085#1085#1099#1084
    Left = 496
    Top = 64
  end
  object dePswd: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      '#Pswd#PSWD#TPswdGet##++~T~^^#0#1#T#F#T#F#F####0#0#F#F#F#T')
    HelpContext = 0
    NameWnd = 'SetPsw'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    Left = 496
    Top = 96
  end
  object RUsers: TRecDB
    NameRec = 'Users'
    DateWithTime = False
    MsgCheck = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100' '#1089' '#1090#1072#1082#1080#1084' '#1080#1084#1077#1085#1077#1084' '#1091#1078#1077' '#1077#1089#1090#1100'.'
    NameDB = 'USERS'
    Prim = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080
    Left = 528
    Top = 64
  end
  object deUser: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      
        #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077'#Users#NAME#TSimpleGet###0#2#T#F#T#F#F####0#0#F#F#F#' +
        'T'
      
        '#Users#SUPER#TBoolGet##'#1040#1076#1084#1080#1085#1080#1089#1090#1088#1072#1090#1086#1088'#0#1#T#F#T#F#F####0#0#F#F#F#' +
        'F'
      
        '#Users#NOSAVE#TBoolGet##'#1053#1077' '#1089#1086#1093#1088#1072#1085#1103#1090#1100' '#1080#1084#1103' '#1087#1088#1080' '#1074#1093#1086#1076#1077'#0#1#T#F#T#F#F' +
        '####0#0#F#F')
    HelpContext = 0
    NameWnd = 'User'
    PnlAskByCancel = False
    PnlSortMode = smColumns
    OnFldCheck = deUserFldCheck
    OnFrmShow = deUserFrmShow
    OnPnlValid = deUserPnlValid
    Left = 528
    Top = 96
  end
  object deGlob: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1076#1086#1089#1090#1091#1087#1072' '#1082' '#1076#1072#1085#1085#1099#1084
    Fields.Strings = (
      
        #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1087#1088#1086#1075#1088#1072#1084#1084#1099'#GlobSet#PROG#TSimpleGet###0#1#T#F#T#F#F##' +
        '##-1#0#F#F#F#T'
      
        #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1086#1076#1085#1086#1074#1088#1077#1084#1077#1085#1085#1086' '#1088#1072#1073#1086#1090#1072#1102#1097#1080#1093' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081'#GlobSet#USERCNT' +
        '#TSpinGet##1,1000#0#1#T#F#T#F#F####0#0#F#F#F#F'
      
        #1052#1072#1082#1089#1080#1084#1072#1083#1100#1085#1099#1081' '#1087#1077#1088#1080#1086#1076' '#1087#1086#1076#1090#1074#1077#1088#1078#1076#1077#1085#1080#1103' '#1088#1072#1073#1086#1090#1099' ('#1084#1080#1085'.)#GlobSet#UABORT#T' +
        'SpinGet##10,1000#0#1#T#F#T#F#F####0#0#F#F'
      
        #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1087#1086#1074#1090#1086#1088#1086#1074' '#1087#1086#1087#1099#1090#1082#1080' '#1080#1079#1084#1077#1085#1077#1085#1080#1103' '#1076#1072#1085#1085#1099#1093'~'#1087#1088#1080' '#1074#1079#1072#1080#1084#1085#1086#1081' '#1073#1083#1086#1082#1080#1088 +
        #1086#1074#1082#1077'#GlobSet#REPDEADLOC#TSpinGet##0,1000#0#1#T#F#T#F#F####0#0#F#' +
        'F#F'
      
        'C'#1086#1077#1076#1080#1085#1077#1085#1080#1077' '#1089' Interbase:#GlobSet#IBTYPE#TRadioGet#Feed##0#1#T#F#T' +
        '#F#F####0#0#F#F#F#F'
      '#Pswd#Z1#TMultiGet###0#1#T#F#T#F#F####-1#0#F#F'
      
        '#Pswd#ICONDEFAULT#TBoolGet##'#1048#1082#1086#1085#1082#1072' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102'#0#1#T#F#T#F#F###' +
        'Pswd.Z1#0#0#F#F'
      
        '##ICON#TButGet#GlobIcon#@H'#1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1080#1082#1086#1085#1082#1091' '#1080#1079' '#1092#1072#1081#1083#1072'@#0#1#T#F#T#F' +
        '#F####-1#-1#F#F')
    HelpContext = 0
    NmProc.Strings = (
      'F7##'#1042#1099#1075#1088#1091#1079#1080#1090#1100' '#1087#1088#1086#1090#1086#1082#1086#1083#1099' '#1074' '#1087#1072#1087#1082#1091'#SERVIC##'
      'F8##'#1059#1076#1072#1083#1080#1090#1100' '#1087#1088#1086#1090#1086#1082#1086#1083#1099' '#1085#1072' '#1094#1077#1085#1090#1088#1072#1083#1100#1085#1086#1084' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1077'#SERVIC##'
      'Ctrl_F8##'#1059#1076#1072#1083#1080#1090#1100' '#1079#1072#1087#1080#1089#1080' '#1074' '#1078#1091#1088#1085#1072#1083#1077' '#1076#1077#1081#1089#1090#1074#1080#1081'#SERVIC##')
    NameWnd = 'GlobSet'
    PnlAskByCancel = False
    PnlSortMode = smColumns
    OnFldChange = deGlobFldChange
    OnKpProcKey = deGlobKpProcKey
    OnPnlAskCancel = deGlobPnlAskCancel
    OnPnlValid = deGlobPnlValid
    Left = 496
    Top = 128
  end
  object dePrm: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      '#Pswd#REG####0#1#T#F#T#F#F####-1#0#F#F'
      #1056#1077#1079#1077#1088#1074#1085#1072#1103' '#1082#1086#1087#1080#1103':#Pswd#COP####0#1#T#F#T#F#F####-1#0#F#F'
      
        #1087#1077#1088#1080#1086#1076' ('#1076#1085#1080')#Pswd#COPDAY#TSpinGet##0,999#0#1#T#F#T#F#F###Pswd.CO' +
        'P#0#0#F#F'
      
        #1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1082#1086#1087#1080#1081'#Pswd#COPCNT#TSpinGet##1,99#0#1#T#F#T#F#F###Pswd' +
        '.COP#0#0#F#F'
      
        #1087#1072#1087#1082#1072'#Pswd#COPDIR#TDirGet##'#1055#1072#1087#1082#1072' '#1076#1083#1103' '#1088#1077#1079#1077#1088#1074#1085#1086#1081' '#1082#1086#1087#1080#1080'~#0#1#T#F#T#' +
        'F#T###Pswd.COP#-2#0#F#F'
      '#Pswd#Z1#TMultiGet###0#1#T#F#T#F#F####0#0#F#F'
      
        #1052#1080#1085#1080#1084#1072#1083#1100#1085#1099#1081' '#1087#1077#1088#1080#1086#1076' '#1087#1086#1076#1090#1074#1077#1088#1078#1076#1077#1085#1080#1103' '#1088#1072#1073#1086#1090#1099' ('#1089#1077#1082'.)#Pswd#IDUPD#TSpinG' +
        'et##1,999#0#1#T#F#T#F#F###Pswd.Z1#0#0#F#F'
      
        #1052#1072#1082#1089#1080#1084#1072#1083#1100#1085#1086#1077' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1092#1086#1088#1084'#Pswd#FORMLIMIT#TSpinGet##10,2147483' +
        '647,1,F#0#1#T#F#T#F#F###Pswd.Z1#0#0#F#F#F#F'
      
        #1052#1080#1085#1080#1084#1072#1083#1100#1085#1099#1081' '#1087#1077#1088#1080#1086#1076' '#1089#1091#1097#1077#1089#1090#1074#1086#1074#1072#1085#1080#1103' '#1092#1086#1088#1084#1099' ('#1084#1080#1085'.)#Pswd#FORMLIMTIME#T' +
        'SpinGet##0,9999#0#1#T#F#T#F#F###Pswd.Z1#0#0#F#F'
      '#Pswd#Z2#TMultiGet###0#1#T#F#T#F#F####0#0#F#F#F#F'
      
        '#Pswd#NOSCILEXER#TBoolGet##'#1053#1077' '#1080#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1088#1077#1076#1072#1082#1090#1086#1088' SciLexer#0#1' +
        '#T#F#T#F#F###Pswd.Z2#0#0#F#F#F#F'
      
        '#Pswd#BRFINDALL#TBoolGet##'#1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1074#1089#1077' '#1085#1072#1081#1076#1077#1085#1085#1099#1077' '#1079#1072#1087#1080#1089#1080' '#1087#1086#1089#1083#1077' ' +
        #1087#1086#1080#1089#1082#1072' '#1074' '#1089#1087#1080#1089#1082#1072#1093'#0#1#T#F#T#F#F###Pswd.Z2#0#0#F#F#F#F')
    HelpContext = 0
    NmProc.Strings = (
      'F4##'#1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1076#1072#1085#1085#1099#1077' '#1080#1079' '#1080#1089#1090#1086#1095#1085#1080#1082#1072'#SERVIC##'
      'F7##'#1057#1086#1079#1076#1072#1090#1100' '#1088#1077#1079#1077#1088#1074#1085#1091#1102' '#1082#1086#1087#1080#1102'#SERVIC##')
    NameWnd = 'PrmLocal'
    PnlAskByCancel = True
    PnlSortMode = smDefault
    OnFldCheck = dePrmFldCheck
    OnFldChange = dePrmFldChange
    OnKpProcKey = dePrmKpProcKey
    OnPnlValid = dePrmPnlValid
    Left = 497
    Top = 195
  end
  object IconGet: TButGet
    VName = 'GlobIcon'
    OnClick = IconGetClick
    OnPaint = IconGetPaint
    Left = 528
    Top = 128
  end
  object dlgIco: TOpenDialog
    DefaultExt = 'ICO'
    Filter = #1048#1082#1086#1085#1082#1080' (*.ico)|*.ico|'#1042#1089#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
    Options = [ofHideReadOnly, ofShowHelp, ofPathMustExist, ofFileMustExist]
    Title = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1080#1082#1086#1085#1082#1091' '#1080#1079' '#1092#1072#1081#1083#1072
    Left = 560
    Top = 128
  end
  object deCopyData: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1076#1072#1085#1085#1099#1077' '#1080#1079' '#1080#1089#1090#1086#1095#1085#1080#1082#1072
    Fields.Strings = (
      
        '#Pswd#ALSFROM###'#1048#1089#1090#1086#1095#1085#1080#1082' '#1076#1072#1085#1085#1099#1093'~ALSFROM#0#1#T#F#T#F#F####-1#0#F#' +
        'F')
    HelpContext = 0
    NameWnd = 'PrmLocalCopyData'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFrmShow = deCopyDataFrmShow
    OnPnlCngKey = deCopyDataPnlCngKey
    OnPnlValid = deCopyDataPnlValid
    Left = 536
    Top = 200
  end
  object deDer: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      
        #1042#1080#1076' '#1087#1088#1086#1090#1086#1082#1086#1083#1072'#Pswd#DERFILE#TRadioGet#Feed##0#1#T#F#T#F#F####0#0#' +
        'F#F#F#F'
      
        #1048#1084#1103' '#1090#1072#1073#1083#1080#1094#1099'#Pswd#DERTBL#TComboGet#ViewDerTbl##0#1#T#F#T#T#F####0' +
        '#0#F#F#F#T'
      
        #1057#1090#1088#1086#1082#1072' '#1076#1083#1103' '#1087#1086#1080#1089#1082#1072'#Pswd#DERSTR#TSimpleGet###0#1#T#F#T#F#F####-1#0' +
        '#F#F#F#T'
      
        #1053#1072#1095#1072#1083#1086' '#1087#1077#1088#1080#1086#1076#1072'#Pswd#DERD1#TDateGet###0#1#T#F#T#F#F####0#0#F#F#F#' +
        'F'
      
        #1050#1086#1085#1077#1094' '#1087#1077#1088#1080#1086#1076#1072'#Pswd#DERD2#TDateGet##@END#0#1#T#F#T#F#F####0#0#F#F' +
        '#F#F'
      
        'IP-'#1072#1076#1088#1077#1089' ('#1087#1091#1089#1090#1086'-'#1074#1089#1077')#Pswd#DERIP#TComboGet#ViewDerIP##0#1#T#F#T#F' +
        '#F####0#0#F#F#F#T'
      
        #1056#1077#1075#1080#1089#1090#1088#1072#1094#1080#1103' ('#1087#1091#1089#1090#1086'-'#1074#1089#1077')#Pswd#DERUSERNUM#TSimpleGet###0#1#T#F#T#T' +
        '#F####0#0#F#F#F#T'
      
        #1057#1073#1086#1088#1082#1072' '#1085#1077' '#1084#1077#1085#1100#1096#1077'#Pswd#DERBUILD#TSpinGet##0,9999,1,F#0#1#T#F#T#T#' +
        'F####0#0#F#F#F#F'
      
        #1042#1099#1087#1086#1083#1085#1077#1085#1086'#Pswd#DERDO#TBoolMultiGet#NoEmpty#'#1076#1072'^'#1085#1077#1090'#0#1#T#F#T#T#F#' +
        '###0#0#F#F#F#F')
    HelpContext = 0
    NameWnd = 'ViewDerTbl'
    PnlAskByCancel = False
    PnlSortMode = smColumns
    OnFldCheck = deDerFldCheck
    OnFldChange = deDerFldChange
    OnPnlValid = deDerPnlValid
    Left = 505
    Top = 243
  end
  object DerTblGet: TComboGet
    VName = 'ViewDerTbl'
    Duplicates = dupIgnore
    ItemHeight = 0
    Sorted = False
    LenName = 20
    Left = 441
    Top = 243
  end
  object DerIPGet: TComboGet
    VName = 'ViewDerIP'
    Duplicates = dupIgnore
    ItemHeight = 0
    Sorted = True
    LenName = 0
    Left = 473
    Top = 243
  end
  object RUsPrm: TRecDB
    NameRec = 'UsPrm'
    DateWithTime = False
    NameDB = 'USPRM'
    Prim = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081
    Left = 560
    Top = 64
  end
  object tmBlink: TTimer
    Enabled = False
    Interval = 400
    Left = 632
    Top = 8
  end
  object deLogDel: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1059#1076#1072#1083#1080#1090#1100' '#1079#1072#1087#1080#1089#1080' '#1074' '#1078#1091#1088#1085#1072#1083#1077' '#1076#1077#1081#1089#1090#1074#1080#1081
    Fields.Strings = (
      #1076#1086' '#1076#1072#1090#1099'#Pswd#DLOGDEL#TDateGet###0#1#T#F#T#F#F####0#0#F#F#F#F')
    HelpContext = 0
    NameWnd = 'LogDel'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFldCheck = deLogDelFldCheck
    Left = 592
    Top = 128
  end
end
