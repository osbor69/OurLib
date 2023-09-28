inherited MsOffEd: TMsOffEd
  Caption = #1055#1088#1077#1086#1073#1088#1072#1079#1086#1074#1072#1090#1100' '#1074' '#1092#1072#1081#1083
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      Font.Charset = RUSSIAN_CHARSET
      Font.Style = []
    end
    inherited PanelEdit1: TPanelEdit
      OnCngKey = PanelEdit1CngKey
      OnValid = PanelEdit1Valid
      object GF: TGenForm
        Left = 304
        Top = 0
        Width = 794
        Height = 1123
        State = gsView
        TabOrder = 1
        Visible = False
      end
      object RbPage1: TRbPage
        Left = 7
        Top = 7
        Width = 552
        Height = 319
        ActivePage = tsOsn
        TabOrder = 0
        CngByCtrl = True
        object tsOsn: TTabSheet
          Caption = #1054#1073#1097#1080#1077
          object pnOsn: TRbPanel
            Left = 7
            Top = 0
            Width = 523
            Height = 283
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CanSize = False
            CanMove = False
            MaxWidth = False
            ProcentWnd = 100
            SortMode = smColumns
            SortObj = True
            BevelOuter = bvLowered
            HMin = 0
            Place = rpNone
            SayRight = False
            TabOrder = 0
            WMin = 0
            object EBrFld: TFldEdit
              Left = 210
              Top = 148
              Width = 86
              Height = 26
              MinSized = False
              ParentSchem = False
              Schem = 'Edit'
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = 'Courier New'
              Font.Style = []
              ParentFont = False
              CharCase = ecNormal
              CharWidth = -1
              CharHeight = -1
              MaxLength = 0
              NameRec = 'MsOff'
              NameRecFld = 'FLD'
              Vid = 'TBoolMultiGet'
              OnCheck = EBrFldCheck
              ParentShowHint = False
              ShowHint = True
              SayCaption = #1042#1099#1074#1086#1076#1080#1084#1099#1077' '#1089#1090#1086#1083#1073#1094#1099
              SayRight = False
              TabOrder = 7
              TabStop = True
              Visible = False
            end
            object EPages: TFldEdit
              Left = 346
              Top = 169
              Width = 86
              Height = 25
              MinSized = False
              ParentSchem = False
              Schem = 'Edit'
              CharCase = ecNormal
              CharWidth = -1
              CharHeight = 0
              MaxLength = 0
              NameRec = 'MsOff'
              NameRecFld = 'PAGES'
              Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
              Vid = 'TSimpleGet'
              OnCheck = EPagesCheck
              ParentShowHint = False
              ShowHint = True
              SayCaption = 
                #1042#1074#1077#1076#1080#1090#1077' '#1085#1086#1084#1077#1088#1072' '#1080'/'#1080#1083#1080' '#1076#1080#1072#1087#1072#1079#1086#1085#1099' '#1083#1080#1089#1090#1086#1074',#'#1088#1072#1079#1076#1077#1083#1105#1085#1085#1099#1077' '#1079#1072#1087#1103#1090#1099#1084#1080'. '#1053#1072#1087 +
                #1088#1080#1084#1077#1088': 1,3,5-12'
              SayRight = False
              TabOrder = 9
              TabStop = True
              Visible = False
            end
            object EVPage: TFldEdit
              Left = 205
              Top = 184
              Width = 86
              Height = 26
              MinSized = False
              ParentSchem = True
              Schem = 'Edit'
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = 'Courier New'
              Font.Style = []
              ParentFont = False
              CharCase = ecNormal
              CharWidth = 0
              CharHeight = 0
              MaxLength = 0
              NameRec = 'MsOff'
              NameRecFld = 'VPAGE'
              Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
              Value = '0'
              Vid = 'TRadioGet'
              VName = 'GFStr'
              OnChange = EVPageChange
              ParentShowHint = False
              ShowHint = True
              SayCaption = ' '#1042#1099#1074#1086#1076#1080#1084#1099#1077' # '#1083#1080#1089#1090#1099' '
              SayRight = False
              TabOrder = 8
              TabStop = True
              Visible = False
            end
            object EFile: TFldEdit
              Left = 205
              Top = 127
              Width = 86
              Height = 25
              MinSized = False
              ParentSchem = False
              Schem = 'Edit'
              CharCase = ecNormal
              CharWidth = -1
              CharHeight = 0
              MaxLength = 0
              NameRec = 'MsOff'
              NameRecFld = 'FILE'
              Vid = 'TDirGet'
              VName = 'MsOff'
              OnCheck = EFileCheck
              ParentShowHint = False
              ShowHint = True
              SayCaption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074' '#1092#1072#1081#1083
              SayRight = False
              TabOrder = 6
              TabStop = True
            end
            object EType: TFldEdit
              Left = 353
              Top = 14
              Width = 95
              Height = 90
              MinSized = False
              ParentSchem = False
              Schem = 'Edit'
              CharCase = ecNormal
              CharWidth = 0
              CharHeight = 0
              MaxLength = 0
              NameRec = 'MsOff'
              NameRecFld = 'TRNTYPE'
              Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
              Value = '1'
              Vid = 'TRadioGet'
              VName = 'MsOffOrient'
              OnChange = ETypeChange
              ParentShowHint = False
              ShowHint = True
              SayCaption = ' '#1055#1088#1077#1086#1073#1088#1072#1079#1086#1074#1072#1090#1100' '
              SayRight = False
              TabOrder = 2
              TabStop = True
              Visible = False
            end
            object EErr: TFldEdit
              Left = 233
              Top = 106
              Width = 86
              Height = 25
              MinSized = False
              ParentSchem = False
              Schem = 'Edit'
              CharCase = ecNormal
              CharWidth = -1
              CharHeight = 0
              MaxLength = 0
              NameRec = 'MsOff'
              NameRecFld = 'ERR'
              Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
              Vid = 'TSimpleGet'
              ParentShowHint = False
              ShowHint = True
              SayRight = False
              TabOrder = 3
              TabStop = True
              Visible = False
            end
            object EFmt: TFldEdit
              Left = 198
              Top = 28
              Width = 95
              Height = 90
              MinSized = False
              ParentSchem = False
              Schem = 'Edit'
              CharCase = ecNormal
              CharWidth = 0
              CharHeight = 0
              MaxLength = 0
              NameRec = 'MsOff'
              NameRecFld = 'FMT'
              Value = '1'
              Vid = 'TRadioGet'
              VName = 'MsOffOrient'
              OnChange = EFmtChange
              ParentShowHint = False
              ShowHint = True
              SayCaption = ' '#1060#1086#1088#1084#1072#1090' '
              SayRight = False
              TabOrder = 1
              TabStop = True
              OnExit = EFmtExit
            end
            object EEditor: TFldEdit
              Left = 191
              Top = 7
              Width = 89
              Height = 25
              MinSized = False
              ParentSchem = False
              Schem = 'Edit'
              CharCase = ecNormal
              CharWidth = 0
              CharHeight = 0
              MaxLength = 0
              NameRec = 'MsOff'
              NameRecFld = 'EDITOR'
              Vid = 'TSimpleGet'
              ParentShowHint = False
              ShowHint = True
              SayCaption = ' '#1056#1077#1076#1072#1082#1090#1086#1088' '
              SayRight = False
              TabOrder = 0
              TabStop = True
            end
            object EReadOnly: TFldEdit
              Left = 318
              Top = 106
              Width = 198
              Height = 25
              MinSized = False
              ParentSchem = True
              Schem = 'Edit'
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clBlack
              Font.Height = -12
              Font.Name = 'Courier New'
              Font.Style = []
              ParentFont = False
              CharCase = ecNormal
              CharWidth = 0
              CharHeight = 0
              Mask = #1047#1072#1087#1088#1077#1090#1080#1090#1100' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077
              MaxLength = 0
              NameRec = 'MsOff'
              NameRecFld = 'READONLY'
              Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
              Value = 'F'
              Vid = 'TBoolGet'
              ParentShowHint = False
              ShowHint = True
              SayRight = False
              TabOrder = 4
              TabStop = True
            end
            object ENoTrns: TFldEdit
              Left = 424
              Top = 128
              Width = 90
              Height = 30
              MinSized = False
              ParentSchem = True
              Schem = 'Edit'
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clBlack
              Font.Height = -12
              Font.Name = 'Courier New'
              Font.Style = []
              ParentFont = False
              CharCase = ecNormal
              CharWidth = 0
              CharHeight = 0
              MaxLength = 0
              NameRec = 'MsOff'
              NameRecFld = 'NOTRNS'
              Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
              Vid = 'TBoolMultiGet'
              ParentShowHint = False
              ShowHint = True
              SayCaption = #1054#1090#1084#1077#1085#1080#1090#1100'#'#1087#1088#1077#1086#1073#1088#1072#1079#1086#1074#1072#1085#1080#1077' '#1089#1090#1088#1086#1082':'
              SayRight = False
              TabOrder = 5
              TabStop = True
            end
          end
        end
        object tsPage: TTabSheet
          Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1089#1090#1088#1072#1085#1080#1094#1099
          ImageIndex = 1
          object pnPage: TRbPanel
            Left = 7
            Top = 14
            Width = 502
            Height = 262
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CanSize = False
            CanMove = False
            MaxWidth = False
            ProcentWnd = 100
            SortMode = smColumns
            SortObj = True
            BevelOuter = bvLowered
            HMin = 0
            Place = rpNone
            SayRight = False
            TabOrder = 0
            WMin = 0
            object EFormat: TFldEdit
              Left = 191
              Top = 21
              Width = 63
              Height = 25
              MinSized = False
              ParentSchem = False
              Schem = 'Edit'
              CharCase = ecNormal
              CharWidth = 0
              CharHeight = 0
              MaxLength = 0
              NameRec = 'MsOff'
              NameRecFld = 'FORMAT'
              Value = '0'
              Vid = 'TMenuGet'
              VName = 'MsOffFormat'
              OnChange = EFormatChange
              ParentShowHint = False
              ShowHint = True
              SayCaption = ' '#1060#1086#1088#1084#1072#1090' '
              SayRight = False
              TabOrder = 0
              TabStop = True
            end
            object EOrient: TFldEdit
              Left = 198
              Top = 64
              Width = 145
              Height = 60
              MinSized = False
              ParentSchem = False
              Schem = 'Edit'
              CharCase = ecNormal
              CharWidth = 0
              CharHeight = 0
              Mask = '@NB0@PL'
              MaxLength = 0
              NameRec = 'MsOff'
              NameRecFld = 'ORIENT'
              Value = '1'
              Vid = 'TRadioGet'
              VName = 'MsOffOrient'
              OnChange = EFormatChange
              ParentShowHint = False
              ShowHint = True
              SayCaption = ' '#1054#1088#1080#1077#1085#1090#1072#1094#1080#1103' '
              SayRight = False
              TabOrder = 1
              TabStop = True
            end
            object pnWH: TRbPanel
              Left = 64
              Top = 99
              Width = 149
              Height = 78
              MinSized = True
              ParentSchem = True
              Schem = 'Edit'
              CanSize = False
              CanMove = False
              MaxWidth = False
              ProcentWnd = 0
              SortMode = smColumns
              SortObj = True
              BevelOuter = bvNone
              HMin = 0
              Place = rpNone
              SayCaption = ' '#1056#1072#1079#1084#1077#1088#1099' # ('#1074' '#1084#1084') '
              SayRight = False
              TabOrder = 2
              WMin = 0
              object EWidth: TFldEdit
                Left = 59
                Top = 21
                Width = 81
                Height = 25
                MinSized = False
                ParentSchem = False
                Schem = 'Edit'
                CharCase = ecNormal
                CharWidth = 0
                CharHeight = 0
                Mask = '0,99999'
                MaxLength = 0
                NameRec = 'MsOff'
                NameRecFld = 'WIDTH'
                Value = '0'
                Vid = 'TSpinGet'
                ParentShowHint = False
                ShowHint = True
                SayCaption = ' '#1096#1080#1088#1080#1085#1072' '
                SayRight = False
                TabOrder = 0
                TabStop = True
              end
              object EHeight: TFldEdit
                Left = 59
                Top = 49
                Width = 81
                Height = 25
                MinSized = False
                ParentSchem = False
                Schem = 'Edit'
                CharCase = ecNormal
                CharWidth = 0
                CharHeight = 0
                Mask = '0,99999'
                MaxLength = 0
                NameRec = 'MsOff'
                NameRecFld = 'HEIGHT'
                Value = '0'
                Vid = 'TSpinGet'
                ParentShowHint = False
                ShowHint = True
                SayCaption = ' '#1074#1099#1089#1086#1090#1072' '
                SayRight = False
                TabOrder = 1
                TabStop = True
              end
            end
            object pnSpot: TRbPanel
              Left = 247
              Top = 92
              Width = 192
              Height = 149
              MinSized = True
              ParentSchem = True
              Schem = 'Edit'
              CanSize = False
              CanMove = False
              MaxWidth = False
              ProcentWnd = 0
              SortMode = smColumns
              SortObj = True
              BevelOuter = bvNone
              HMin = 0
              Place = rpNone
              SayCaption = ' '#1055#1086#1083#1103' # ('#1074' '#1084#1084') '
              SayRight = False
              TabOrder = 3
              WMin = 0
              object ETop: TFldEdit
                Left = 109
                Top = 21
                Width = 81
                Height = 25
                MinSized = False
                ParentSchem = False
                Schem = 'Edit'
                CharCase = ecNormal
                CharWidth = 0
                CharHeight = 0
                Mask = '0,99999'
                MaxLength = 0
                NameRec = 'MsOff'
                NameRecFld = 'TOP'
                Value = '0'
                Vid = 'TSpinGet'
                ParentShowHint = False
                ShowHint = True
                SayCaption = ' '#1074#1077#1088#1093#1085#1077#1077' '
                SayRight = False
                TabOrder = 0
                TabStop = True
              end
              object EBottom: TFldEdit
                Left = 109
                Top = 49
                Width = 81
                Height = 25
                MinSized = False
                ParentSchem = False
                Schem = 'Edit'
                CharCase = ecNormal
                CharWidth = 0
                CharHeight = 0
                Mask = '0,99999'
                MaxLength = 0
                NameRec = 'MsOff'
                NameRecFld = 'BOTTOM'
                Value = '0'
                Vid = 'TSpinGet'
                ParentShowHint = False
                ShowHint = True
                SayCaption = ' '#1085#1080#1078#1085#1077#1077' '
                SayRight = False
                TabOrder = 1
                TabStop = True
              end
              object ELfeft: TFldEdit
                Left = 109
                Top = 78
                Width = 81
                Height = 25
                MinSized = False
                ParentSchem = False
                Schem = 'Edit'
                CharCase = ecNormal
                CharWidth = 0
                CharHeight = 0
                Mask = '0,99999'
                MaxLength = 0
                NameRec = 'MsOff'
                NameRecFld = 'LEFT'
                Value = '0'
                Vid = 'TSpinGet'
                ParentShowHint = False
                ShowHint = True
                SayCaption = ' '#1083#1077#1074#1086#1077' '
                SayRight = False
                TabOrder = 2
                TabStop = True
              end
              object ERight: TFldEdit
                Left = 109
                Top = 106
                Width = 81
                Height = 25
                MinSized = False
                ParentSchem = False
                Schem = 'Edit'
                CharCase = ecNormal
                CharWidth = 0
                CharHeight = 0
                Mask = '0,99999'
                MaxLength = 0
                NameRec = 'MsOff'
                NameRecFld = 'RIGHT'
                Value = '0'
                Vid = 'TSpinGet'
                ParentShowHint = False
                ShowHint = True
                SayCaption = ' '#1087#1088#1072#1074#1086#1077' '
                SayRight = False
                TabOrder = 3
                TabStop = True
              end
            end
          end
        end
      end
    end
  end
  object Rec: TRecVal
    NameRec = 'MsOff'
    Fields.Strings = (
      'Editor=N#1'
      'FLD=M'
      'VPage=N'
      'PAGES=M'
      'FORMAT=N#1'
      'ORIENT=N#1'
      'Width=N'
      'Height=N'
      'Top=N#20'
      'Bottom=N#20'
      'Left=N#20'
      'Right=N#20'
      'FILE=M'
      'TrnType=N'
      'Err=M'
      'FMT=N#1'
      'EdName=S30'
      'EdType=N'
      'EdFname=M'
      'READONLY=L@H'#1047#1072#1087#1088#1077#1090#1080#1090#1100' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077'@')
    Left = 48
    Top = 8
  end
  object FormatGet: TMenuGet
    VName = 'MsOffFormat'
    UserItems = False
    LenCode = 0
    LenName = 0
    Left = 144
    Top = 8
  end
  object OrientGet: TRadioGet
    Items.Strings = (
      #1082#1085#1080#1078#1085#1072#1103'#Ourl_GF_OR_Portrait'
      #1072#1083#1100#1073#1086#1084#1085#1072#1103'#Ourl_GF_OR_Landscape')
    VName = 'MsOffOrient'
    Left = 176
    Top = 8
  end
  object DirGet1: TDirGet
    VName = 'MsOff'
    OpenDialog = SaveDialog1
    Options = [dgNoCheckDir]
    Left = 216
    Top = 8
  end
  object SaveDialog1: TSaveDialog
    Left = 248
    Top = 8
  end
  object deEditor: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      
        #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077'#MsOff#EDNAME#TSimpleGet###0#1#T#F#T#F#F####0#0#F#F#' +
        'F#T'
      
        #1058#1080#1087'#MsOff#EDTYPE#TRadioGet#MsOffOrient##0#1#T#F#T#F#F####0#0#F#F' +
        '#F'
      
        #1060#1072#1081#1083'#MsOff#EDFNAME#TDirGet#MsOffEditor#'#1060#1072#1081#1083' '#1088#1077#1076#1072#1082#1090#1086#1088#1072'~#0#1#T#F#T' +
        '#T#F####-1#0#F#F#F'
      
        #1055#1086#1076#1076#1077#1088#1078#1080#1074#1072#1077#1084#1099#1077' '#1092#1086#1088#1084#1072#1090#1099'#MsOff#EDFMT#TBoolMultiGet#NoEmpty##0#1#T#' +
        'F#T#F#F####0#0#F#F#F')
    HelpContext = 0
    NameWnd = 'MsOffEditor'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFldChange = deEditorFldChange
    OnFldExit = deEditorFldExit
    Left = 80
    Top = 9
  end
  object DirGet2: TDirGet
    VName = 'MsOffEditor'
    OpenDialog = OpenDialog1
    Options = []
    Left = 328
    Top = 9
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'EXE'
    Filter = #1055#1088#1080#1083#1086#1078#1077#1085#1080#1103'|*.exe;*.com'
    Left = 360
    Top = 9
  end
end
