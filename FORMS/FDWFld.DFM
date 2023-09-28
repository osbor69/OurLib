inherited DWFld: TDWFld
  Left = 366
  Top = 236
  Width = 943
  Height = 650
  ActiveControl = LsFld
  Caption = #1042#1074#1086#1076#1080#1084#1099#1077' '#1087#1086#1083#1103
  Menu = KeyMenu1
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    Width = 700
    Height = 479
    inherited KeyLb1: TKeyLb
      Left = 30
      Top = 445
      Width = 169
      Height = 29
      NmProc.Strings = (
        'Esc#'#1054#1090#1084#1077#1085#1072'##FILE'
        'F10#'#1057#1086#1093#1088#1072#1085#1080#1090#1100'##FILE')
    end
    inherited RbPanel2: TRbPanel
      Width = 685
      Height = 412
      BevelOuter = bvNone
      Place = rpLeft
      object PnLs: TRbPanel
        Left = 0
        Top = 0
        Width = 191
        Height = 382
        MinSized = False
        ParentSchem = False
        Schem = 'Browl'
        CanSize = False
        CanMove = False
        MaxWidth = False
        ProcentWnd = 40
        SortMode = smDefault
        SortObj = True
        BevelOuter = bvLowered
        HMin = 0
        Place = rpNone
        SayRight = False
        TabOrder = 0
        WMin = 0
        object LsFld: TStringBrowl
          Left = 7
          Top = 21
          Width = 166
          Height = 106
          ColCount = 2
          FixedCols = 0
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSizing, goColSizing, goRowSelect]
          TabOrder = 0
          OnEnter = LsFldEnter
          OnExit = LsFldExit
          OnMouseDown = LsFldMouseDown
          OnMouseMove = LsFldMouseMove
          OnMouseUp = LsFldMouseUp
          OnSelectCell = LsFldSelectCell
          KeyDblClick = 13
          TitleFont.Charset = RUSSIAN_CHARSET
          TitleFont.Color = clBlack
          TitleFont.Height = -15
          TitleFont.Name = 'Courier New'
          TitleFont.Style = []
          ColZn.Strings = (
            #1044#1072#1085#1085#1086#1077'##L'
            #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077'##L')
          SelectedOnlyFocused = False
          OnCalcZn = LsFldCalcZn
          ColWidths = (
            58
            112)
          RowHeights = (
            21
            24
            24
            24
            24)
        end
      end
      object PnEd: TPanelEdit
        Left = 198
        Top = 0
        Width = 476
        Height = 410
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
        OnEnter = PnEdEnter
        OnExit = PnEdExit
        MasterControl = LsFld
        Options = [peCheckOnExit]
        OnEscape = PnEdEscape
        OnExitType = PnEdExitType
        OnValid = PnEdValid
        object EMaxLen: TFldEdit
          Left = 120
          Top = 141
          Width = 67
          Height = 25
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CharCase = ecNormal
          CharWidth = 0
          CharHeight = 0
          Mask = '0,999'
          MaxLength = 0
          NameRecFld = 'MAXLEN'
          Value = '0'
          Vid = 'TSpinGet'
          ParentShowHint = False
          ShowHint = True
          SayCaption = #1052#1072#1082#1089'.'#1076#1083#1080#1085#1072
          SayRight = False
          TabOrder = 2
          TabStop = True
        end
        object ECharCase: TFldEdit
          Left = 205
          Top = 162
          Width = 63
          Height = 25
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CharCase = ecNormal
          CharWidth = 0
          CharHeight = 0
          MaxLength = 0
          NameRecFld = 'CHARCASE'
          Value = '0'
          Vid = 'TMenuGet'
          VName = 'DWFldCase'
          ParentShowHint = False
          ShowHint = True
          SayCaption = #1055#1088#1077#1086#1073#1088#1072#1079#1086#1074#1072#1085#1080#1077' '#1089#1080#1084#1074#1086#1083#1086#1074
          SayRight = False
          TabOrder = 3
          TabStop = True
        end
        object ERelation: TFldEdit
          Left = 184
          Top = 332
          Width = 29
          Height = 25
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CharCase = ecNormal
          CharWidth = 0
          CharHeight = 0
          Mask = '@L'
          MaxLength = 0
          NameRecFld = 'RELATION'
          Vid = 'TComboGet'
          VName = 'DWRelation'
          OnCheck = ERelationCheck
          ParentShowHint = False
          ShowHint = True
          SayCaption = #1055#1086#1076#1095#1080#1085#1077#1085#1086
          SayRight = False
          TabOrder = 6
          TabStop = True
        end
        object pnDat: TRbPanel
          Left = 21
          Top = 0
          Width = 444
          Height = 57
          MinSized = True
          ParentSchem = True
          Schem = 'Edit'
          CanSize = False
          CanMove = False
          MaxWidth = True
          ProcentWnd = 0
          SortMode = smColumns
          SortObj = True
          BevelOuter = bvNone
          HMin = 0
          Place = rpNone
          SayRight = False
          TabOrder = 0
          WMin = 0
          object ERec: TFldEdit
            Left = 120
            Top = 7
            Width = 63
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'REC'
            Value = '0'
            Vid = 'TMenuGet'
            OnChange = ERecChange
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1042#1080#1076' '#1076#1072#1085#1085#1099#1093' '
            SayRight = False
            TabOrder = 0
            TabStop = True
            OnExit = ERecExit
          end
          object ERecFld: TFldEdit
            Left = 120
            Top = 28
            Width = 63
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'RECFLD'
            Value = '0'
            Vid = 'TMenuGet'
            OnChange = ERecFldChange
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1044#1072#1085#1085#1086#1077' '
            SayRight = False
            TabOrder = 1
            TabStop = True
          end
          object ECaption: TFldEdit
            Tag = 1
            Left = 82
            Top = 32
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = -1
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'CAPTION'
            Vid = 'TSimpleGet'
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 2
            TabStop = True
          end
        end
        object pnVid: TRbPanel
          Left = 162
          Top = 71
          Width = 305
          Height = 71
          MinSized = True
          ParentSchem = True
          Schem = 'Edit'
          CanSize = False
          CanMove = False
          MaxWidth = True
          ProcentWnd = 0
          SortMode = smColumns
          SortObj = True
          BevelOuter = bvNone
          HMin = 0
          Place = rpNone
          SayCaption = #1042#1074#1086#1076':'
          SayRight = False
          TabOrder = 1
          WMin = 0
          object EVid: TFldEdit
            Left = 120
            Top = -1
            Width = 63
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'VID'
            Value = '0'
            Vid = 'TMenuGet'
            OnChange = EVidChange
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1074#1080#1076' '
            SayRight = False
            TabOrder = 0
            TabStop = True
          end
          object EVName: TFldEdit
            Left = 233
            Top = 27
            Width = 63
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'VNAME'
            Value = '0'
            Vid = 'TMenuGet'
            OnChange = EVidChange
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1085#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '
            SayRight = False
            TabOrder = 1
            TabStop = True
          end
          object EMask: TFldEdit
            Left = 148
            Top = 49
            Width = 86
            Height = 23
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = -2
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'MASKVIEW'
            Vid = 'TButTextGet'
            OnChange = EMaskChange
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '
            SayRight = False
            TabOrder = 2
            TabStop = True
            OnEnter = EMaskEnter
            OnExit = EMaskExit
          end
        end
        object pnBool: TRbPanel
          Left = 14
          Top = 184
          Width = 417
          Height = 127
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
          SayRight = False
          TabOrder = 4
          WMin = 0
          object EAutoSel: TFldEdit
            Left = 7
            Top = -2
            Width = 86
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
            Mask = #1042#1099#1076#1077#1083#1103#1090#1100
            MaxLength = 0
            NameRecFld = 'AUTOSEL'
            Value = 'F'
            Vid = 'TBoolGet'
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 0
            TabStop = True
          end
          object EPassword: TFldEdit
            Left = 7
            Top = 19
            Width = 107
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
            Mask = #1042#1074#1086#1076' '#1087#1072#1088#1086#1083#1103
            MaxLength = 0
            NameRecFld = 'PASSWORD'
            Value = 'F'
            Vid = 'TBoolGet'
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 1
            TabStop = True
          end
          object ENoReadOnly: TFldEdit
            Left = 7
            Top = 41
            Width = 121
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
            Mask = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
            MaxLength = 0
            NameRecFld = 'NORDONLY'
            Value = 'F'
            Vid = 'TBoolGet'
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 2
            TabStop = True
          end
          object ENoVsbl: TFldEdit
            Left = 7
            Top = 62
            Width = 205
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
            Mask = #1053#1077#1074#1080#1076#1080#1084#1086#1077', '#1077#1089#1083#1080' '#1085#1077#1088#1077#1076#1072#1082#1090'.'
            MaxLength = 0
            NameRecFld = 'NOVSBL'
            Value = 'F'
            Vid = 'TBoolGet'
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 3
            TabStop = True
          end
          object ETag: TFldEdit
            Left = 226
            Top = 26
            Width = 184
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
            Mask = #1042' '#1085#1086#1074#1086#1081' '#1082#1086#1083#1086#1085#1082#1077'/'#1089#1090#1088#1086#1082#1077
            MaxLength = 0
            NameRecFld = 'TAG'
            Value = 'F'
            Vid = 'TBoolGet'
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 5
            TabStop = True
          end
          object ENoVisible: TFldEdit
            Left = 228
            Top = 5
            Width = 93
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
            Mask = #1053#1077#1074#1080#1076#1080#1084#1086#1077
            MaxLength = 0
            NameRecFld = 'NOVISIBLE'
            Value = 'F'
            Vid = 'TBoolGet'
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 4
            TabStop = True
          end
          object ENewPage: TFldEdit
            Left = 233
            Top = 62
            Width = 142
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
            Mask = #1057' '#1085#1086#1074#1086#1081' '#1089#1090#1088#1072#1085#1080#1094#1099
            MaxLength = 0
            NameRecFld = 'NEWPAGE'
            Value = 'F'
            Vid = 'TBoolGet'
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 6
            TabStop = True
          end
          object ESayRight: TFldEdit
            Left = 7
            Top = 83
            Width = 163
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
            Mask = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1089#1087#1088#1072#1074#1072
            MaxLength = 0
            NameRecFld = 'SAYRIGHT'
            Value = 'F'
            Vid = 'TBoolGet'
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 7
            TabStop = True
          end
          object ETrimLeft: TFldEdit
            Left = 191
            Top = 83
            Width = 177
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
            Mask = #1059#1073#1080#1088#1072#1090#1100' '#1087#1088#1086#1073#1077#1083#1099' '#1089#1083#1077#1074#1072
            MaxLength = 0
            NameRecFld = 'TRIMLEFT'
            Value = 'F'
            Vid = 'TBoolGet'
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 8
            TabStop = True
          end
        end
        object pnHint: TRbPanel
          Left = 261
          Top = 289
          Width = 213
          Height = 44
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
          SayCaption = #1055#1086#1076#1089#1082#1072#1079#1082#1080':'
          SayRight = False
          TabOrder = 5
          WMin = 0
          object ESayHint: TFldEdit
            Left = 120
            Top = -1
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'SAYHINT'
            Vid = 'TSimpleGet'
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1076#1083#1103' '#1085#1072#1080#1084#1077#1085'. '
            SayRight = False
            TabOrder = 0
            TabStop = True
          end
          object EGetHint: TFldEdit
            Left = 127
            Top = 20
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'GETHINT'
            Vid = 'TSimpleGet'
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1076#1083#1103' '#1074#1074#1086#1076#1072' '
            SayRight = False
            TabOrder = 1
            TabStop = True
          end
        end
        object pnWH: TRbPanel
          Left = 21
          Top = 353
          Width = 340
          Height = 50
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
          SayRight = False
          TabOrder = 7
          WMin = 0
          object EWidth: TFldEdit
            Left = 120
            Top = -1
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'WIDTH'
            Vid = 'TSimpleGet'
            ParentShowHint = False
            ShowHint = True
            SayCaption = #1064#1080#1088#1080#1085#1072'('#1089#1080#1084#1074'.)'
            SayRight = False
            TabOrder = 0
            TabStop = True
          end
          object EHeight: TFldEdit
            Left = 120
            Top = 20
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = '-1,999'
            MaxLength = 0
            NameRecFld = 'HEIGHT'
            Vid = 'TSimpleGet'
            ParentShowHint = False
            ShowHint = True
            SayCaption = #1042#1099#1089#1086#1090#1072'('#1089#1080#1084#1074'.)'
            SayRight = False
            TabOrder = 1
            TabStop = True
          end
        end
      end
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 8
    Top = 9
  end
  object Rec: TRecVal
    Fields.Strings = (
      'Rec=N'
      'RecFld=N'
      'Caption=M'
      'Vid=N'
      'VName=N'
      'Mask=M'
      'MaskView=M'
      'MaxLen=N'
      'CharCase=N'
      'AutoSel=L'
      'Password=L'
      'NoRdOnly=L'
      'NoVsbl=L'
      'Tag=L'
      'SayHint=S50'
      'GetHint=S50'
      'Relation=S30'
      'Width=N'
      'Height=N'
      'NoVisible=L'
      'NewPage=L'
      'SayRight=L'
      'TrimLeft=L')
    Left = 40
    Top = 8
  end
  object RecGet: TMenuGet
    UserItems = False
    LenCode = 0
    LenName = 0
    Left = 225
    Top = 43
  end
  object VarGet: TMenuGet
    OnListOwner = VarGetListOwner
    UserItems = False
    LenCode = 0
    LenName = 0
    Left = 225
    Top = 67
  end
  object VidGet: TMenuGet
    UserItems = False
    LenCode = 0
    LenName = 0
    Left = 225
    Top = 123
  end
  object VNameGet: TMenuGet
    UserItems = False
    LenCode = 0
    LenName = 0
    Left = 225
    Top = 147
  end
  object CaseGet: TMenuGet
    VName = 'DWFldCase'
    UserItems = False
    LenCode = 0
    LenName = 0
    Left = 225
    Top = 227
  end
  object MaskGet: TButTextGet
    TextReadOnly = False
    OnClick = MaskGetClick
    Left = 225
    Top = 179
  end
  object RelationGet: TComboGet
    VName = 'DWRelation'
    Duplicates = dupIgnore
    ItemHeight = 0
    Sorted = False
    LenName = 0
    Left = 233
    Top = 419
  end
  object deFix: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1086#1087#1080#1089#1072#1085#1080#1077' '#1074' '#1092#1080#1082#1089#1080#1088#1086#1074#1072#1085#1085#1099#1081' '#1084#1072#1089#1089#1080#1074
    Fields.Strings = (
      #1050#1086#1076'##FIXKA###@C@X#0#1#T#F#T#F#F####0#0#F#F#F#F'
      #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077'##FIXNAME#TSimpleGet###0#1#T#F#T#F#F####0#0#F#F#F#F')
    HelpContext = 0
    NameWnd = 'ConvArrFix'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFldCheck = deFixFldCheck
    OnFldExit = deFixFldExit
    OnPnlCngKey = deFixPnlCngKey
    OnPnlValid = deFixPnlValid
    Left = 88
    Top = 9
  end
  object SortGet: TRadioGet
    Items.Strings = (
      #1087#1086' '#1092#1086#1088#1084#1077'#'
      #1086#1073#1099#1095#1085#1072#1103
      #1087#1086' '#1082#1086#1083#1086#1085#1082#1072#1084
      #1087#1086' '#1089#1090#1088#1086#1082#1072#1084)
    VName = 'DWPrmSort'
    Left = 120
    Top = 8
  end
end
