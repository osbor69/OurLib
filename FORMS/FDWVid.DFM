inherited DWVid: TDWVid
  Left = 362
  Width = 813
  Height = 664
  Caption = ''
  Menu = KeyMenu1
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    Width = 679
    Height = 528
    inherited KeyLb1: TKeyLb
      Left = 30
      Top = 487
      NmProc.Strings = (
        'Esc#'#1054#1090#1084#1077#1085#1072'##FILE')
    end
    inherited RbPanel2: TRbPanel
      Top = 2
      Width = 664
      Height = 479
      BevelOuter = bvNone
      Place = rpBottom
      object pn1: TRbPanel
        Left = 14
        Top = 21
        Width = 643
        Height = 418
        MinSized = False
        ParentSchem = True
        Schem = 'Edit'
        CanSize = False
        CanMove = False
        MaxWidth = False
        ProcentWnd = 100
        SortMode = smDefault
        SortObj = True
        BevelOuter = bvNone
        HMin = 0
        Place = rpLeft
        SayRight = False
        TabOrder = 0
        WMin = 0
        object PnLs: TRbPanel
          Left = 7
          Top = -28
          Width = 297
          Height = 361
          MinSized = False
          ParentSchem = False
          Schem = 'Browl'
          CanSize = False
          CanMove = False
          MaxWidth = False
          ProcentWnd = 50
          SortMode = smDefault
          SortObj = True
          BevelOuter = bvLowered
          HMin = 0
          Place = rpNone
          SayRight = False
          TabOrder = 0
          WMin = 0
          object LsVar: TStringBrowl
            Left = 7
            Top = 49
            Width = 259
            Height = 106
            ColCount = 3
            FixedCols = 0
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSizing, goColSizing, goRowSelect]
            TabOrder = 0
            OnDrawCell = LsVarDrawCell
            OnEnter = LsVarEnter
            OnExit = LsVarExit
            OnSelectCell = LsVarSelectCell
            KeyDblClick = 13
            TitleFont.Charset = RUSSIAN_CHARSET
            TitleFont.Color = clBlack
            TitleFont.Height = -15
            TitleFont.Name = 'Courier New'
            TitleFont.Style = []
            ColZn.Strings = (
              #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077'##L'
              #1050#1086#1076'##L#-1'
              #1058#1080#1087'##L')
            SelectedOnlyFocused = False
            OnCalcZn = LsVarCalcZn
            ColWidths = (
              112
              133
              31)
            RowHeights = (
              21
              24
              24
              24
              24)
          end
        end
        object PnEd: TPanelEdit
          Left = 296
          Top = -35
          Width = 312
          Height = 445
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
          TabOrder = 1
          WMin = 0
          MasterControl = LsVar
          Options = [peCheckOnExit]
          OnEscape = PnEdEscape
          OnExitType = PnEdExitType
          OnValid = PnEdValid
          object EName: TFldEdit
            Left = 120
            Top = 42
            Width = 82
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecUpperCase
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'NAME'
            Options = [ogAutoSelect, ogAutoSize, ogTrimLeft]
            Vid = 'TSimpleGet'
            OnCheck = ENameCheck
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '
            SayRight = False
            TabOrder = 0
            TabStop = True
          end
          object ECod: TFldEdit
            Left = 120
            Top = 127
            Width = 86
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = -2
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'COD'
            Options = [ogAutoSelect, ogAutoSize, ogTrimLeft]
            Vid = 'TSimpleGet'
            OnCheck = ECodCheck
            OnChange = EChange
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1050#1086#1076' '
            SayRight = False
            TabOrder = 4
            TabStop = True
          end
          object EType: TFldEdit
            Left = 120
            Top = 99
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'TYPE'
            Vid = 'TMenuGet'
            OnChange = ETypeChange
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1058#1080#1087' '
            SayRight = False
            TabOrder = 2
            TabStop = True
            OnExit = ETypeExit
          end
          object EValue: TFldEdit
            Left = 127
            Top = 374
            Width = 86
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = -2
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'VALUE'
            Vid = 'TSimpleGet'
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 11
            TabStop = True
          end
          object EPrim: TFldEdit
            Left = 124
            Top = 395
            Width = 86
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = -2
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'PRIM'
            Vid = 'TSimpleGet'
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1055#1088#1080#1084#1077#1095#1072#1085#1080#1077' '
            SayRight = False
            TabOrder = 12
            TabStop = True
          end
          object EDop: TFldEdit
            Left = 124
            Top = 416
            Width = 86
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = -2
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'DOP'
            Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
            Vid = 'TSimpleGet'
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1055#1072#1088#1072#1084#1077#1090#1088#1099' '
            SayRight = False
            TabOrder = 13
            TabStop = True
          end
          object ESvType: TFldEdit
            Left = 155
            Top = 64
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'SVTYPE'
            Value = '1'
            Vid = 'TRadioGet'
            VName = 'Feed'
            OnChange = ESvTypeChange
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1057#1087#1086#1089#1086#1073' # '#1093#1088#1072#1085#1077#1085#1080#1103' '
            SayRight = False
            TabOrder = 1
            TabStop = True
            OnExit = ESvTypeExit
          end
          object pnFill: TRbPanel
            Left = 99
            Top = 205
            Width = 198
            Height = 57
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
            SayCaption = ' '
            SayRight = False
            TabOrder = 7
            WMin = 0
            object EFillType: TFldEdit
              Left = 21
              Top = 12
              Width = 86
              Height = 26
              MinSized = False
              ParentSchem = True
              Schem = 'Edit'
              CharCase = ecNormal
              CharWidth = 0
              CharHeight = 0
              MaxLength = 0
              NameRecFld = 'FILLTYPE'
              Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
              Value = '1'
              Vid = 'TRadioGet'
              ParentShowHint = False
              ShowHint = True
              SayRight = False
              TabOrder = 0
              TabStop = True
            end
            object EFillChr: TFldEdit
              Tag = 1
              Left = 176
              Top = 12
              Width = 82
              Height = 25
              MinSized = False
              ParentSchem = True
              Schem = 'Edit'
              CharCase = ecNormal
              CharWidth = 0
              CharHeight = 0
              MaxLength = 0
              NameRecFld = 'FILLCHR'
              Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
              Vid = 'TSimpleGet'
              ParentShowHint = False
              ShowHint = True
              SayCaption = ' '#1089#1080#1084#1074#1086#1083#1086#1084' '
              SayRight = False
              TabOrder = 1
              TabStop = True
              OnExit = ELenExit
            end
          end
          object ELen: TFldEdit
            Left = 120
            Top = 154
            Width = 81
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = '0,99999'
            MaxLength = 0
            NameRecFld = 'LEN'
            Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
            Value = '0'
            Vid = 'TSpinGet'
            OnCheck = ELenCheck
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1044#1083#1080#1085#1072' '
            SayRight = False
            TabOrder = 5
            TabStop = True
            OnExit = ELenExit
          end
          object EDec: TFldEdit
            Left = 120
            Top = 175
            Width = 81
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = '0,99999'
            MaxLength = 0
            NameRecFld = 'DEC'
            Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
            Value = '0'
            Vid = 'TSpinGet'
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1058#1086#1095#1085#1086#1089#1090#1100' '
            SayRight = False
            TabOrder = 6
            TabStop = True
            OnExit = ELenExit
          end
          object EDDatType: TFldEdit
            Left = 120
            Top = 268
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'DDATTYPE'
            Options = [ogAutoSelect, ogReadOnly, ogReadOnlyNoVsbl, ogAutoSize]
            Value = '1'
            Vid = 'TRadioGet'
            VName = 'Feed'
            OnChange = ESvTypeChange
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1055#1077#1088#1080#1086#1076' # '#1080#1079#1084#1077#1085#1077#1085#1080#1103' # '#1079#1085#1072#1095#1077#1085#1080#1103': '
            SayRight = False
            TabOrder = 8
            OnExit = ESvTypeExit
          end
          object EDDatD2: TFldEdit
            Left = 134
            Top = 296
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'DDATD2'
            Options = [ogAutoSelect, ogReadOnly, ogReadOnlyNoVsbl, ogAutoSize]
            Value = '1'
            Vid = 'TRadioGet'
            VName = 'Feed'
            OnCheck = EDDatD2Check
            OnChange = ESvTypeChange
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1042#1080#1076#1099' # '#1074#1074#1086#1076#1072' # '#1087#1077#1088#1080#1086#1076#1072': '
            SayRight = False
            TabOrder = 9
            OnExit = ESvTypeExit
          end
          object ESel: TFldEdit
            Left = 127
            Top = 353
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = -2
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'SEL'
            Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
            Vid = 'TSimpleGet'
            VName = 'Customize'
            OnChange = EChange
            ParentShowHint = False
            ShowHint = True
            SayCaption = ' '#1042#1080#1076' '#1076#1072#1085#1085#1099#1093' '
            SayRight = False
            TabOrder = 10
            TabStop = True
          end
          object ESelType: TFldEdit
            Left = 200
            Top = 100
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRecFld = 'SELTYPE'
            Options = [ogAutoSelect, ogReadOnly, ogReadOnlyNoVsbl, ogAutoSize]
            Value = '1'
            Vid = 'TRadioGet'
            VName = 'Feed'
            OnChange = ESvTypeChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 3
            OnExit = ESvTypeExit
          end
        end
      end
      object RbStatus1: TRbStatus
        Tag = -1
        Left = 14
        Top = 445
        Width = 163
        Height = 22
        MinSized = False
        ParentSchem = False
        Schem = 'Status'
        SimpleLine = False
        Alignment = taLeftJustify
        BevelOuter = bvLowered
      end
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 49
    Top = 11
  end
  object Rec: TRecVal
    Fields.Strings = (
      'SvType=N'
      'Type=N'
      'Cod=M'
      'Len=N'
      'Dec=N'
      'Value=M'
      'Prim=M'
      'Dop=M'
      'FillType=N'
      'FillChr=S1'
      'DDatType=N'
      'DDatD2=N'
      'SEL=N'
      'SelType=N')
    Left = 16
    Top = 9
  end
  object ArrGet: TButGet
    OnClick = ArrGetClick
    Left = 353
    Top = 435
  end
  object RecArr: TRecDBDef
    NameRec = 'DWVidArr'
    DateWithTime = False
    DDatIsCod = False
    DDatMaxLenCod = 0
    DynamicVid = 0
    OnDWTrans = RecArrDWTrans
    Left = 201
    Top = 11
  end
  object DopGet: TButGet
    Left = 353
    Top = 467
  end
  object FillGet: TRadioGet
    Left = 361
    Top = 243
  end
  object ManyGet: TButGet
    VName = 'DWMany'
    OnClick = ManyGetClick
    Left = 95
    Top = 10
  end
end
