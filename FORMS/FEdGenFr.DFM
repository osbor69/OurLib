inherited EdGenFr: TEdGenFr
  Left = 150
  Top = 1
  Width = 969
  Height = 727
  ActiveControl = GF
  Caption = #1057#1086#1079#1076#1072#1085#1080#1077' '#1087#1077#1095#1072#1090#1085#1086#1081' '#1092#1086#1088#1084#1099
  Menu = KeyMenu1
  WindowState = wsMaximized
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    Width = 728
    Height = 543
    Schem = 'GenFr'
    inherited KeyLb1: TKeyLb
      Top = 501
      Width = 168
      Font.Charset = RUSSIAN_CHARSET
      Font.Style = []
      NmProc.Strings = (
        'F10#'#1042#1099#1093#1086#1076'##FILE'
        'Esc#'#1054#1090#1084#1077#1085#1072'##FILE')
    end
    inherited RbPanel2: TRbPanel
      Left = 8
      Top = 2
      Width = 721
      Height = 488
      Schem = 'GenFr'
      BevelOuter = bvNone
      Place = rpBottom
      object PnGF1: TRbPanel
        Tag = 1
        Left = 14
        Top = 14
        Width = 537
        Height = 128
        MinSized = False
        ParentSchem = True
        Schem = 'GenFr'
        CanSize = False
        CanMove = False
        MaxWidth = False
        ProcentWnd = 100
        SortMode = smDefault
        SortObj = True
        BevelOuter = bvNone
        BevelWidth = 2
        HMin = 0
        Place = rpBottom
        SayRight = False
        TabOrder = 0
        WMin = 0
        object RbStatus1: TRbStatus
          Tag = -1
          Left = 7
          Top = 85
          Width = 163
          Height = 36
          MinSized = False
          ParentSchem = False
          Schem = 'Status'
          SimpleLine = True
          SectLeft.Strings = (
            ' ')
          Alignment = taLeftJustify
          BevelOuter = bvLowered
        end
        object PnGF: TRbPanel
          Left = 7
          Top = 7
          Width = 403
          Height = 72
          MinSized = False
          ParentSchem = True
          Schem = 'GenFr'
          CanSize = False
          CanMove = False
          MaxWidth = False
          ProcentWnd = 100
          SortMode = smDefault
          SortObj = False
          BevelOuter = bvLowered
          HMin = 0
          Place = rpNone
          SayRight = False
          TabOrder = 1
          WMin = 0
          OnResize = PnGFResize
          object PnGF2: TRbPanel
            Left = 7
            Top = 7
            Width = 361
            Height = 57
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CanSize = False
            CanMove = False
            MaxWidth = False
            ProcentWnd = 100
            SortMode = smDefault
            SortObj = True
            BevelOuter = bvNone
            HMin = 0
            Place = rpNone
            SayRight = False
            TabOrder = 0
            WMin = 0
            object ScrlGF: TRbScrollBox
              Left = 14
              Top = 7
              Width = 192
              Height = 57
              HorzScrollBar.Increment = 30
              VertScrollBar.Increment = 30
              BorderStyle = bsNone
              TabOrder = 0
              StopRebuild = True
              Options = []
              object GF: TGenForm
                Left = 0
                Top = 0
                Width = 88
                Height = 50
                State = gsDesign
                OnSelectGrid = GFSelectGrid
                PopupMenu = PopupMenu1
                TabOrder = 0
                OnEnter = GFEnter
                OnExit = GFExit
              end
            end
          end
        end
      end
      object PnEdit: TRbPanel
        Left = 14
        Top = 141
        Width = 707
        Height = 340
        MinSized = False
        ParentSchem = True
        Schem = 'GenFr'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Style = []
        ParentColor = True
        ParentFont = False
        CanSize = False
        CanMove = False
        MaxWidth = False
        ProcentWnd = 0
        SortMode = smDefault
        SortObj = True
        BevelOuter = bvLowered
        HMin = 0
        Place = rpTop
        SayRight = False
        TabOrder = 1
        WMin = 0
        object PnObj: TPanelEdit
          Left = 7
          Top = 42
          Width = 552
          Height = 255
          MinSized = False
          ParentSchem = True
          Schem = 'GenFr'
          CanSize = False
          CanMove = False
          MaxWidth = False
          Header = #1057#1074#1086#1081#1089#1090#1074#1072' '#1086#1073#1098#1077#1082#1090#1072
          ProcentWnd = 0
          SortMode = smColumns
          SortObj = True
          Enabled = False
          HMin = 0
          Place = rpNone
          SayRight = False
          TabOrder = 0
          WMin = 0
          OnEnter = PnObjEnter
          OnExit = PnObjExit
          MasterControl = GF
          Options = [peCheckOnExit]
          OnBeforeEnter = PnObjBeforeEnter
          OnBeforeExit = PnObjBeforeExit
          OnEscape = PnObjEscape
          OnValid = PnObjValid
          object SLeft: TFldEdit
            Left = 7
            Top = 64
            Width = 65
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1083#1077#1074#1091#1102' '#1075#1088#1072#1085#1080#1094#1091
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = ELeft
            Mask = #1057#1083#1077#1074#1072
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'Left'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 4
            TabStop = True
            OnExit = SLeftExit
          end
          object ELeft: TFldEdit
            Left = 141
            Top = 64
            Width = 53
            Height = 25
            Hint = #1051#1077#1074#1072#1103' '#1075#1088#1072#1085#1080#1094#1072
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = '0,9'
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'Left'
            Value = '0'
            Vid = 'TSpinGet'
            OnAfterExit = ELeftAfterExit
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 5
            TabStop = True
          end
          object STop: TFldEdit
            Left = 7
            Top = 21
            Width = 72
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1074#1077#1088#1093#1085#1102#1102' '#1075#1088#1072#1085#1080#1094#1091
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = ETop
            Mask = #1057#1074#1077#1088#1093#1091
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'Top'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 0
            TabStop = True
            OnExit = SLeftExit
          end
          object ETop: TFldEdit
            Left = 141
            Top = 21
            Width = 53
            Height = 25
            Hint = #1042#1077#1088#1093#1085#1103#1103' '#1075#1088#1072#1085#1080#1094#1072
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = '0,9'
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'Top'
            Value = '0'
            Vid = 'TSpinGet'
            OnAfterExit = ELeftAfterExit
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 1
            TabStop = True
          end
          object SRight: TFldEdit
            Left = 7
            Top = 85
            Width = 72
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1087#1088#1072#1074#1091#1102' '#1075#1088#1072#1085#1080#1094#1091
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = ERight
            Mask = #1057#1087#1088#1072#1074#1072
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'Right'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 6
            TabStop = True
            OnExit = SLeftExit
          end
          object ERight: TFldEdit
            Left = 141
            Top = 85
            Width = 53
            Height = 25
            Hint = #1055#1088#1072#1074#1072#1103' '#1075#1088#1072#1085#1080#1094#1072
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = '0,9'
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'Right'
            Value = '0'
            Vid = 'TSpinGet'
            OnAfterExit = ELeftAfterExit
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 7
            TabStop = True
          end
          object SBottom: TFldEdit
            Left = 7
            Top = 42
            Width = 65
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1085#1080#1078#1085#1102#1102' '#1075#1088#1072#1085#1080#1094#1091
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = EBottom
            Mask = #1057#1085#1080#1079#1091
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'Bottom'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 2
            TabStop = True
            OnExit = SLeftExit
          end
          object EBottom: TFldEdit
            Left = 141
            Top = 42
            Width = 53
            Height = 25
            Hint = #1053#1080#1078#1085#1103#1103' '#1075#1088#1072#1085#1080#1094#1072
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = '0,9'
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'Bottom'
            Value = '0'
            Vid = 'TSpinGet'
            OnAfterExit = ELeftAfterExit
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 3
            TabStop = True
          end
          object STypeObj: TFldEdit
            Left = 332
            Top = 21
            Width = 51
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1090#1080#1087' '#1086#1073#1098#1077#1082#1090#1072
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = ETypeObj
            Mask = #1058#1080#1087
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'TypeObj'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 18
            TabStop = True
            OnExit = SLeftExit
          end
          object ETypeObj: TFldEdit
            Tag = 1
            Left = 466
            Top = 21
            Width = 89
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'TypeObj'
            Value = '          0'
            Vid = 'TSimpleGet'
            OnChange = ETypeObjChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 19
            TabStop = True
          end
          object SText: TFldEdit
            Left = 332
            Top = 134
            Width = 100
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1090#1077#1082#1089#1090
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = EText
            Mask = #1057#1086#1076#1077#1088#1078#1080#1084#1086#1077
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'Text'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 28
            TabStop = True
            OnExit = SLeftExit
          end
          object EText: TFldEdit
            Left = 466
            Top = 134
            Width = 86
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = -2
            CharHeight = 0
            MaxLength = 0
            Vid = 'TSimpleGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 29
            TabStop = True
          end
          object SAlignment: TFldEdit
            Left = 7
            Top = 113
            Width = 100
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1088#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1077
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = EAlignment
            Mask = #1056#1072#1079#1084#1077#1089#1090#1080#1090#1100
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'Alignment'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 8
            TabStop = True
            OnExit = SLeftExit
          end
          object EAlignment: TFldEdit
            Tag = 1
            Left = 141
            Top = 113
            Width = 89
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'Alignment'
            Value = '          0'
            Vid = 'TSimpleGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 9
            TabStop = True
            OnMouseDown = EAlignmentMouseDown
            OnMouseUp = EAlignmentMouseUp
          end
          object SOColor: TFldEdit
            Left = 7
            Top = 197
            Width = 58
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1094#1074#1077#1090' '#1092#1086#1085#1072
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = EOColor
            Mask = #1062#1074#1077#1090
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'OColor'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 16
            TabStop = True
            OnExit = SLeftExit
          end
          object EOColor: TFldEdit
            Left = 141
            Top = 197
            Width = 86
            Height = 26
            Hint = #1062#1074#1077#1090' '#1092#1086#1085#1072
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = '@C'
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'OColor'
            Vid = 'TColorGet'
            VName = 'Color'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 17
            TabStop = True
          end
          object SFont: TFldEdit
            Left = 332
            Top = 106
            Width = 65
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1096#1088#1080#1092#1090
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = EFont
            Mask = #1064#1088#1080#1092#1090
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'Font'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 26
            TabStop = True
            OnExit = SLeftExit
          end
          object EFont: TFldEdit
            Tag = 1
            Left = 466
            Top = 106
            Width = 86
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = -2
            CharHeight = 0
            Mask = '@C'
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'Font'
            Value = '@ '
            Vid = 'TSimpleGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 27
            TabStop = True
          end
          object SMinWidth: TFldEdit
            Left = 332
            Top = 64
            Width = 72
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1084#1080#1085'.'#1096#1080#1088#1080#1085#1091
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = EMinWidth
            Mask = #1064#1080#1088#1080#1085#1072
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'MinWidth'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 22
            TabStop = True
            OnExit = SLeftExit
          end
          object EMinWidth: TFldEdit
            Left = 466
            Top = 64
            Width = 81
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = '0,60000'
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'MinWidth'
            Value = '0'
            Vid = 'TSpinGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 23
            TabStop = True
          end
          object SMinHeight: TFldEdit
            Left = 332
            Top = 85
            Width = 72
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1084#1080#1085'.'#1074#1099#1089#1086#1090#1091
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = EMinHeight
            Mask = #1042#1099#1089#1086#1090#1072
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'MinHeight'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 24
            TabStop = True
            OnExit = SLeftExit
          end
          object EMinHeight: TFldEdit
            Left = 466
            Top = 85
            Width = 81
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = '0,60000'
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'MinHeight'
            Value = '0'
            Vid = 'TSpinGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 25
            TabStop = True
          end
          object SPin: TFldEdit
            Left = 7
            Top = 134
            Width = 79
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1091#1075#1086#1083' '#1087#1088#1080#1078#1072#1090#1080#1103
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = EPin
            Mask = #1055#1088#1080#1078#1072#1090#1100
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'Pin'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 10
            TabStop = True
            OnExit = SLeftExit
          end
          object EPin: TFldEdit
            Left = 141
            Top = 134
            Width = 89
            Height = 25
            Hint = #1059#1075#1086#1083' '#1087#1088#1080#1078#1072#1090#1080#1103
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'Pin'
            Value = '          0'
            Vid = 'TSimpleGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 11
            TabStop = True
          end
          object SPart: TFldEdit
            Left = 332
            Top = 162
            Width = 72
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1088#1072#1079#1076#1077#1083
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = EPart
            Mask = #1056#1072#1079#1076#1077#1083
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'Part'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 30
            TabStop = True
            OnExit = SLeftExit
          end
          object EPart: TFldEdit
            Left = 466
            Top = 162
            Width = 86
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = -2
            CharHeight = 0
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'Part'
            Options = [ogAutoSelect, ogAutoSize, ogTrimLeft]
            Vid = 'TSimpleGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = False
            SayRight = False
            TabOrder = 31
            TabStop = True
          end
          object SMMetr: TFldEdit
            Left = 332
            Top = 42
            Width = 79
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1077#1076#1080#1085#1080#1094#1091' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = EMMetr
            Mask = #1045#1076'.'#1080#1079#1084'.'
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'MMetr'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 20
            TabStop = True
            OnExit = SLeftExit
          end
          object EMMetr: TFldEdit
            Left = 466
            Top = 42
            Width = 89
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'MMetr'
            Value = '          0'
            Vid = 'TSimpleGet'
            OnChange = ETypeObjChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 21
            TabStop = True
          end
          object SVOut: TFldEdit
            Left = 7
            Top = 155
            Width = 86
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1074#1099#1074#1086#1076' '#1085#1072' '#1083#1080#1089#1090#1072#1093' '#1086#1076#1085#1086#1081' '#1089#1090#1088#1072#1085#1080#1094#1099
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = EVOut
            Mask = #1042#1099#1074#1086#1076#1080#1090#1100
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'VOut'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 12
            TabStop = True
            OnExit = SLeftExit
          end
          object EVOut: TFldEdit
            Left = 141
            Top = 155
            Width = 89
            Height = 25
            Hint = #1042#1099#1074#1086#1076#1080#1090#1100' '#1085#1072' '#1083#1080#1089#1090#1072#1093' '#1086#1076#1085#1086#1081' '#1089#1090#1088#1072#1085#1080#1094#1099
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'VOut'
            Value = '          0'
            Vid = 'TSimpleGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 13
            TabStop = True
          end
          object SCol: TFldEdit
            Left = 325
            Top = 191
            Width = 79
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1082#1086#1083#1086#1085#1082#1091
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = ECol
            Mask = #1050#1086#1083#1086#1085#1082#1072
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'Col'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 32
            TabStop = True
            OnExit = SLeftExit
          end
          object ECol: TFldEdit
            Left = 419
            Top = 190
            Width = 86
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = -2
            CharHeight = 0
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'Col'
            Options = [ogAutoSelect, ogAutoSize, ogTrimLeft]
            Vid = 'TSimpleGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = False
            SayRight = False
            TabOrder = 33
            TabStop = True
          end
          object SIdent: TFldEdit
            Left = 325
            Top = 219
            Width = 93
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1080#1076#1077#1085#1090#1080#1092#1080#1082#1072#1090#1086#1088
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = EIdent
            Mask = #1048#1076#1077#1085#1090#1080#1092'-'#1088
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'IDENT'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 34
            TabStop = True
            OnExit = SLeftExit
          end
          object EIdent: TFldEdit
            Left = 419
            Top = 218
            Width = 86
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = -2
            CharHeight = 0
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'IDENT'
            Options = [ogAutoSelect, ogAutoSize, ogTrimLeft]
            Vid = 'TSimpleGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = False
            SayRight = False
            TabOrder = 35
            TabStop = True
          end
          object SOnly1: TFldEdit
            Left = 14
            Top = 176
            Width = 93
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1074#1099#1074#1086#1076' '#1090#1086#1083#1100#1082#1086' '#1085#1072' '#1087#1077#1088#1074#1086#1081' '#1095#1072#1089#1090#1080' '#1089#1090#1088#1072#1085#1080#1094#1099
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            FocusControl = EOnly1
            Mask = #1053#1072' 1 '#1089#1090#1088'.'
            MaxLength = 0
            NameRec = 'RGF1'
            NameRecFld = 'ONLY1'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 14
            TabStop = True
            OnExit = SLeftExit
          end
          object EOnly1: TFldEdit
            Left = 148
            Top = 176
            Width = 27
            Height = 23
            Hint = #1042#1099#1074#1086#1076#1080#1090#1100' '#1090#1086#1083#1100#1082#1086' '#1085#1072' '#1087#1077#1088#1074#1086#1081' '#1095#1072#1089#1090#1080' '#1089#1090#1088#1072#1085#1080#1094#1099
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
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
            NameRec = 'RGF'
            NameRecFld = 'ONLY1'
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = ELeftChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 15
            TabStop = True
          end
        end
        object PnFill: TPanelEdit
          Left = 558
          Top = 42
          Width = 142
          Height = 206
          MinSized = False
          ParentSchem = True
          Schem = 'GenFr'
          OnSetWHMin = PnFillSetWHMin
          CanSize = False
          CanMove = False
          MaxWidth = False
          ProcentWnd = 100
          SortMode = smDefault
          SortObj = True
          Enabled = False
          HMin = 0
          Place = rpNone
          SayRight = False
          TabOrder = 1
          WMin = 0
          OnEnter = PnFillEnter
          OnExit = PnFillExit
          MasterControl = GF
          Options = []
          OnBeforeEnter = PnFillBeforeEnter
          OnBeforeExit = PnFillBeforeExit
          object EVFill: TFldEdit
            Left = 21
            Top = 141
            Width = 89
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'VFill'
            Value = '          1'
            Vid = 'TSimpleGet'
            ParentShowHint = False
            ShowHint = True
            SayCaption = #1054#1073#1088#1072#1084#1083#1077#1085#1080#1077
            SayRight = False
            TabOrder = 2
            TabStop = True
          end
          object EColor: TFldEdit
            Left = 21
            Top = 42
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = '@C'
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'Color'
            Vid = 'TColorGet'
            VName = 'Color16'
            OnChange = EColorChange
            ParentShowHint = False
            ShowHint = True
            SayCaption = #1062#1074#1077#1090' '#1083#1080#1085#1080#1080
            SayRight = False
            TabOrder = 0
            TabStop = True
          end
          object ELnWidth: TFldEdit
            Left = 21
            Top = 92
            Width = 26
            Height = 25
            MinSized = False
            ParentSchem = True
            Schem = 'GenFr'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = '@C'
            MaxLength = 0
            NameRec = 'RGF'
            NameRecFld = 'LnWidth'
            Value = '@ '
            Vid = 'TSimpleGet'
            OnChange = EColorChange
            ParentShowHint = False
            ShowHint = True
            SayCaption = #1058#1086#1083#1097#1080#1085#1072' '#1083#1080#1085#1080#1080' (1/10 '#1084#1084')'
            SayRight = False
            TabOrder = 1
            TabStop = True
          end
        end
      end
    end
  end
  object RGF: TRecVal
    NameRec = 'RGF'
    Fields.Strings = (
      'Color=N'
      'LnWidth=N'
      'VFill=N#1'
      'Left=N'
      'Top=N'
      'Right=N'
      'Bottom=N'
      'TypeObj=N'
      'Alignment=N'
      'MinWidth=N'
      'MinHeight=N'
      'Pin=N'
      'OColor=N'
      'Font=N'
      'Part=M'
      'Col=M'
      'MMetr=N'
      'VOut=N'
      'Only1=L@H'#1042#1099#1074#1086#1076#1080#1090#1100' '#1090#1086#1083#1100#1082#1086' '#1085#1072' '#1087#1077#1088#1074#1086#1081' '#1095#1072#1089#1090#1080' '#1089#1090#1088#1072#1085#1080#1094#1099'@'
      'DivVid=N#1'
      'DivCopy=L'
      'NumFont=S3'
      'OnlyDig=L'
      'RowBetween=N'
      'WidthTextAll=L'
      'OnWidth=L'
      'ALine=L'
      'Angle=N'
      'PrmName=M'
      'AType=N'
      'MMetrSep=L'
      'WidthMM=N'
      'HeightMM=N'
      'Koef=N'
      'ECCLevel=S1@H'#1091#1088#1086#1074#1077#1085#1100' '#1082#1086#1088#1088#1077#1082#1094#1080#1080' '#1086#1096#1080#1073#1086#1082'@'
      'Module=N@H'#1088#1072#1079#1084#1077#1088' '#1084#1086#1076#1091#1083#1103' (1/10 '#1084#1084')@'
      'ModuleHeight=N@H'#1074#1099#1089#1086#1090#1072' '#1084#1086#1076#1091#1083#1103' (1/10 '#1084#1084')@'
      'RowHeight=N@H'#1086#1090#1085#1086#1096#1077#1085#1080#1077' '#1074#1099#1089#1086#1090#1099' '#1082' '#1096#1080#1088#1080#1085#1077'@'
      'PrcSpMin=N'
      'ChrFill=S1'
      'NewLine=S2#++'
      'Ident=M'
      'AutoSaveIntv=N'
      'Z=L'
      'Z1=L'
      'Z2=L'
      'FontNom=N@H'#1053#1086#1084#1077#1088' '#1096#1088#1080#1092#1090#1072' '#1076#1083#1103' '#1074#1099#1076#1077#1083#1077#1085#1080#1103'@'
      'FontAlgn=N@H'#1056#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1077' '#1090#1077#1082#1089#1090#1072', '#1074#1099#1076#1077#1083#1077#1085#1085#1086#1075#1086' '#1076#1088#1091#1075#1080#1084' '#1096#1088#1080#1092#1090#1086#1084'@')
    Top = 32
  end
  object FillGet: TSpdButGet
    KeyTxt = #1054#1073#1088#1072#1084#1080#1090#1100
    KeyHint = #1042#1099#1087#1086#1083#1085#1080#1090#1100' '#1086#1073#1088#1072#1084#1083#1077#1085#1080#1077
    OnClick = FillGetClick
    Left = 648
    Top = 376
  end
  object LnWidthGet: TMenuDrawGet
    UserItems = False
    LenCode = 0
    LenName = 0
    OnDrawItem = LnWidthGetDrawItem
    OnSizePaint = LnWidthGetSizePaint
    Left = 648
    Top = 328
  end
  object RGF1: TRecVal
    NameRec = 'RGF1'
    Fields.Strings = (
      'Left=L'
      'Top=L'
      'Right=L'
      'Bottom=L'
      'TypeObj=L'
      'Text=L'
      'Alignment=L'
      'MinWidth=L'
      'MinHeight=L'
      'Pin=L'
      'OColor=L'
      'Font=L'
      'Part=L'
      'Col=L'
      'MMetr=L'
      'VOut=L'
      'Only1=L@H'#1042#1099#1074#1086#1076#1080#1090#1100' '#1090#1086#1083#1100#1082#1086' '#1085#1072' '#1087#1077#1088#1074#1086#1081' '#1095#1072#1089#1090#1080' '#1089#1090#1088#1072#1085#1080#1094#1099'@'
      'Ident=L')
    Left = 16
    Top = 224
  end
  object TypeGet: TMenuGet
    UserItems = False
    LenCode = 0
    LenName = 0
    Left = 376
    Top = 240
  end
  object TextGet: TButGet
    OnClick = TextGetClick
    Left = 384
    Top = 368
  end
  object TextDlg: TOpenDialog
    DefaultExt = 'BMP'
    Filter = #1056#1080#1089#1091#1085#1082#1080' (*.bmp)|*.bmp|'#1044#1088#1091#1075#1080#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
    Options = [ofHideReadOnly, ofShowHelp, ofPathMustExist, ofFileMustExist]
    Title = #1048#1084#1103' '#1092#1072#1081#1083#1072' '#1088#1080#1089#1091#1085#1082#1072
    Left = 352
    Top = 368
  end
  object PinGet: TMenuDrawGet
    UserItems = False
    LenCode = 0
    LenName = 0
    OnDrawItem = PinGetDrawItem
    OnSizePaint = PinGetSizePaint
    Left = 16
    Top = 376
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Top = 96
    object N1: TMenuItem
      Tag = 25
      Caption = #1054#1090#1084#1077#1090#1082#1072
      Visible = False
    end
    object N2: TMenuItem
      Tag = 26
      Caption = #1054#1073#1098#1077#1082#1090#1099
      Visible = False
    end
  end
  object MMetrGet: TMenuGet
    UserItems = False
    LenCode = 0
    LenName = 0
    Left = 376
    Top = 272
  end
  object FontGet: TMenuGet
    OnListOwner = FontGetListOwner
    UserItems = False
    LenCode = 3
    LenName = 20
    Left = 376
    Top = 336
  end
  object PopupMenu1: TPopupMenu
    Top = 128
    object M_Shift_F2: TMenuItem
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074' '#1092#1072#1081#1083' <Shift+F2>'
      OnClick = APopupClick
    end
    object M_Shift_F3: TMenuItem
      Caption = #1057#1095#1080#1090#1072#1090#1100' '#1080#1079' '#1092#1072#1081#1083#1072' <Shift+F3>'
      OnClick = APopupClick
    end
    object M_Ctrl_F3: TMenuItem
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1089' '#1094#1077#1085#1090#1088#1072#1083#1100#1085#1086#1075#1086' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1072' <Ctrl+F3>'
      OnClick = APopupClick
    end
    object M_R1: TMenuItem
      Caption = '-'
    end
    object M_F4: TMenuItem
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1087#1072#1088#1072#1084#1077#1090#1088#1086#1074' '#1092#1086#1088#1084#1099' <F4>'
      OnClick = APopupClick
    end
    object M_Ctrl_F5: TMenuItem
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1072#1083#1075#1086#1088#1080#1090#1084#1072' '#1092#1086#1088#1084#1080#1088#1086#1074#1072#1085#1080#1103' <Ctrl+F5>'
      OnClick = APopupClick
    end
    object MDW: TMenuItem
      Caption = #1044#1072#1085#1085#1099#1077' '#1080' '#1086#1082#1085#1072' '#1074#1074#1086#1076#1072
      object M_Ctrl_F8: TMenuItem
        Caption = #1044#1072#1085#1085#1099#1077' <Ctrl+F8>'
        OnClick = APopupClick
      end
      object M_Ctrl_F6: TMenuItem
        Caption = #1054#1082#1085#1086' '#1074#1074#1086#1076#1072' '#1076#1072#1085#1085#1099#1093' <Ctrl+F6>'
        OnClick = APopupClick
      end
      object M_Shift_F8: TMenuItem
        Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' <Shift+F8>'
        OnClick = APopupClick
      end
      object M_Shift_F6: TMenuItem
        Caption = #1054#1082#1085#1086' '#1074#1074#1086#1076#1072' '#1087#1072#1088#1072#1084#1077#1090#1088#1086#1074' <Shift+F6>'
        OnClick = APopupClick
      end
    end
    object M_Space: TMenuItem
      Caption = #1053#1072#1095#1072#1090#1100' '#1091#1087#1088#1072#1074#1083#1077#1085#1080#1077' '#1089' '#1082#1083#1072#1074#1080#1072#1090#1091#1088#1099' <'#1055#1088#1086#1073#1077#1083'>'
      OnClick = APopupClick
    end
    object M_R2: TMenuItem
      Caption = '-'
      Visible = False
    end
    object M_Enter: TMenuItem
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1089#1086#1076#1077#1088#1078#1080#1084#1086#1075#1086' '#1086#1073#1098#1077#1082#1090#1072' <Enter>'
      Visible = False
      OnClick = APopupClick
    end
    object M_F2: TMenuItem
      Caption = #1054#1073#1088#1072#1084#1083#1077#1085#1080#1077' '#1086#1073#1098#1077#1082#1090#1086#1074' <F2>'
      Visible = False
      OnClick = APopupClick
    end
    object M_F5: TMenuItem
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1089#1074#1086#1081#1089#1090#1074' '#1086#1073#1098#1077#1082#1090#1086#1074' <F5>'
      Visible = False
      OnClick = APopupClick
    end
    object M_F7: TMenuItem
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1086#1073#1098#1077#1082#1090' <F7>'
      Visible = False
      OnClick = APopupClick
    end
    object M_F8: TMenuItem
      Caption = #1059#1076#1072#1083#1077#1085#1080#1077' '#1086#1073#1098#1077#1082#1090#1086#1074' <F8>'
      Visible = False
      OnClick = APopupClick
    end
    object M_Ctrl_F7: TMenuItem
      Caption = #1054#1073#1098#1077#1076#1080#1085#1077#1085#1080#1077' '#1086#1073#1098#1077#1082#1090#1086#1074' <Ctrl+F7>'
      Visible = False
      OnClick = APopupClick
    end
    object M_Shift_F7: TMenuItem
      Caption = #1053#1086#1074#1099#1077' '#1083#1080#1085#1080#1080' '#1075#1088#1072#1085#1080#1094' '#1086#1073#1098#1077#1082#1090#1086#1074' <Shift+F7>'
      Visible = False
      OnClick = APopupClick
    end
    object M_R3: TMenuItem
      Caption = '-'
    end
    object MDivObj: TMenuItem
      Caption = #1056#1072#1079#1076#1077#1083#1080#1090#1100' '#1086#1073#1098#1077#1082#1090#1099' ...'
      Visible = False
      object M_Ctrl_Left: TMenuItem
        Caption = #1089#1083#1077#1074#1072' <Ctrl+'#1042#1083#1077#1074#1086'>'
        OnClick = APopupClick
      end
      object M_Ctrl_Right: TMenuItem
        Caption = #1089#1087#1088#1072#1074#1072' <Ctrl+'#1042#1087#1088#1072#1074#1086'>'
        OnClick = APopupClick
      end
      object M_Ctrl_Up: TMenuItem
        Caption = #1089#1074#1077#1088#1093#1091' <Ctrl+'#1042#1074#1077#1088#1093'>'
        OnClick = APopupClick
      end
      object M_Ctrl_Down: TMenuItem
        Caption = #1089#1085#1080#1079#1091' <Ctrl+'#1042#1085#1080#1079'>'
        OnClick = APopupClick
      end
    end
    object MSelObj: TMenuItem
      Caption = #1054#1090#1084#1077#1090#1080#1090#1100' '#1086#1073#1098#1077#1082#1090#1099' ...'
      object M_Ctrl_1: TMenuItem
        Caption = #1087#1086' '#1090#1080#1087#1091' <Ctrl+1>'
        OnClick = APopupClick
      end
      object M_Ctrl_2: TMenuItem
        Caption = #1087#1086' '#1077#1076'.'#1080#1079#1084'. <Ctrl+2>'
        OnClick = APopupClick
      end
      object M_Ctrl_3: TMenuItem
        Caption = #1087#1086' '#1096#1088#1080#1092#1090#1091' <Ctrl+3>'
        OnClick = APopupClick
      end
      object M_Ctrl_4: TMenuItem
        Caption = #1087#1086' '#1088#1072#1079#1076#1077#1083#1091' <Ctrl+4>'
        OnClick = APopupClick
      end
      object M_Ctrl_5: TMenuItem
        Caption = #1087#1086' '#1082#1086#1083#1086#1085#1082#1077' <Ctrl+5>'
        OnClick = APopupClick
      end
      object M_Ctrl_6: TMenuItem
        Caption = #1087#1086' '#1090#1080#1087#1091' '#1074#1099#1074#1086#1076#1072' <Ctrl+6>'
        OnClick = APopupClick
      end
      object M_Ctrl_7: TMenuItem
        Caption = #1087#1086' '#1088#1072#1079#1084#1077#1097#1077#1085#1080#1102' <Ctrl+7>'
        OnClick = APopupClick
      end
      object M_Ctrl_8: TMenuItem
        Caption = #1087#1086' '#1087#1088#1080#1078#1072#1090#1080#1102' <Ctrl+8>'
        OnClick = APopupClick
      end
      object M_Ctrl_9: TMenuItem
        Caption = #1087#1086' '#1094#1074#1077#1090#1091' <Ctrl+9>'
        OnClick = APopupClick
      end
      object M_Ctrl_0: TMenuItem
        Caption = #1087#1086' '#1089#1086#1076#1077#1088#1078#1080#1084#1086#1084#1091' <Ctrl+0>'
        OnClick = APopupClick
      end
      object M_Ctrl_Zpt: TMenuItem
        Caption = #1087#1086' '#1096#1080#1088#1080#1085#1077' <Ctrl+",">'
        OnClick = APopupClick
      end
      object M_Ctrl_Point: TMenuItem
        Caption = #1087#1086' '#1074#1099#1089#1086#1090#1077' <Ctrl+".">'
        OnClick = APopupClick
      end
      object M_Ctrl_Plus: TMenuItem
        Caption = #1087#1086' '#1080#1076#1077#1085#1090#1080#1092#1080#1082#1072#1090#1086#1088#1091' <Ctrl+"+">'
        OnClick = APopupClick
      end
      object M_Ctrl_Minus: TMenuItem
        Caption = #1087#1086' '#1074#1099#1074#1086#1076#1091' '#1090#1086#1083#1100#1082#1086' '#1085#1072' 1 '#1089#1090#1088'. <Ctrl+"-">'
        OnClick = APopupClick
      end
    end
    object M_R4: TMenuItem
      Caption = '-'
    end
    object M_Ctrl_X: TMenuItem
      Caption = #1042#1099#1088#1077#1079#1072#1090#1100' <Ctrl+X>'
      Enabled = False
      OnClick = APopupClick
    end
    object M_Ctrl_C: TMenuItem
      Caption = #1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100' <Ctrl+C>'
      Enabled = False
      OnClick = APopupClick
    end
    object M_Ctrl_V: TMenuItem
      Caption = #1042#1089#1090#1072#1074#1080#1090#1100' <Ctrl+V>'
      Enabled = False
      OnClick = APopupClick
    end
  end
  object PartGet: TComboGet
    Duplicates = dupIgnore
    ItemHeight = 0
    Sorted = True
    LenName = 0
    Left = 376
    Top = 400
  end
  object ColGet: TComboGet
    Duplicates = dupIgnore
    ItemHeight = 0
    Sorted = True
    LenName = 0
    Left = 368
    Top = 432
  end
  object VOutGet: TMenuGet
    UserItems = False
    LenCode = 0
    LenName = 0
    Left = 16
    Top = 400
  end
  object deAdd: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1056#1072#1079#1076#1077#1083#1080#1090#1100' '#1086#1073#1098#1077#1082#1090#1099
    Fields.Strings = (
      '#RGF#DIVVID#TRadioGet###0#1#T#F#T#F#F####0#0#F#F'
      '#RGF#DIVCOPY#TBoolGet##'#1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1089#1086#1076#1077#1088#1078#1080#1084#1086#1077'#0#1#T#F#T')
    HelpContext = 0
    NameWnd = 'GFAdd'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFrmShow = deAddFrmShow
    OnPnlCngKey = deAddPnlCngKey
    OnPnlValid = deAddPnlValid
    Left = 592
    Top = 24
  end
  object DivVidGet: TRadioGet
    Items.Strings = (
      #1057#1087#1088#1072#1074#1072
      #1057#1085#1080#1079#1091
      #1057#1083#1077#1074#1072
      #1057#1074#1077#1088#1093#1091)
    Left = 632
    Top = 24
  end
  object deFont: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077'#RGF#PRIM#TSimpleGet###0#1#T#F#T#F#F####0#0#F#F#F#T'
      '###TButGet###0#1#T#F#T#F#F####-1#0#F#F#F#F'
      #1042#1080#1076'#RGF#ATYPE#TRadioGet##@NB0#0#1#T#F#T#F#F####0#0#F#F'
      
        #1059#1075#1086#1083' '#1087#1086#1074#1086#1088#1086#1090#1072' '#1087#1086' '#1095#1072#1089#1086#1074#1086#1081' '#1089#1090#1088#1077#1083#1082#1077'('#1075#1088#1072#1076#1091#1089#1099')#RGF#ANGLE#TSpinGet##0,' +
        '360,90#0#1#T#F#T#T#F####0#0#F#F#F#F'
      
        '#RGF#Z#TButGet##@H'#1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1099#1077' '#1087#1072#1088#1072#1084#1077#1090#1088#1099'@#0#1#T#F#T#T#F####-1#' +
        '5#F#F')
    HelpContext = 0
    NameWnd = 'GFFont'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFldChange = deFontFldChange
    OnFldExit = deFontFldExit
    Left = 592
    Top = 56
  end
  object FontLsGet: TButGet
    OnClick = FontLsGetClick
    OnPaint = FontLsGetPaint
    OnSize = FontLsGetSize
    Left = 664
    Top = 56
  end
  object deSel: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1054#1090#1084#1077#1090#1080#1090#1100' '#1086#1073#1098#1077#1082#1090#1099
    Fields.Strings = (
      '#RGF#SEL#TSimpleGet###0#1#T##T##')
    HelpContext = 0
    NameWnd = 'GFSel'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnPnlCngKey = deSelPnlCngKey
    Left = 592
    Top = 88
  end
  object RDocPrm: TRecDBDef
    NameRec = 'DocPrm'
    OnCalculate = RDocPrmCalculate
    DateWithTime = False
    NameDB = 'DOCPRM'
    DDatIsCod = False
    DDatMaxLenCod = 0
    DWName = #1044#1072#1085#1085#1099#1077' '#1087#1086' '#1076#1086#1082#1091#1084#1077#1085#1090#1091
    DWPrefix = #1044#1054#1050
    DynamicVid = 0
    OnDWArrCodName = RDocPrmDWArrCodName
    OnDWArrSeek = RDocPrmDWArrSeek
    OnDWCanDel = RDocPrmDWCanDel
    OnDWCngName = RDocPrmDWCngName
    OnDWFldSeek = RDocPrmDWFldSeek
    OnDWTrans = RDocPrmDWTrans
    OnDWVarValid = RDocPrmDWVarValid
    Left = 777
    Top = 3
  end
  object RDocpPrm: TRecDBDef
    NameRec = 'DocpPrm'
    OnCalculate = RDocPrmCalculate
    DateWithTime = False
    NameDB = 'DOCPRM'
    DDatIsCod = False
    DDatMaxLenCod = 0
    DWName = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1076#1086#1082#1091#1084#1077#1085#1090#1072
    DWPrefix = #1044#1050#1055
    DynamicVid = 0
    OnDWArrCodName = RDocPrmDWArrCodName
    OnDWArrSeek = RDocPrmDWArrSeek
    OnDWCanDel = RDocPrmDWCanDel
    OnDWCngName = RDocPrmDWCngName
    OnDWTrans = RDocPrmDWTrans
    OnDWVarValid = RDocPrmDWVarValid
    Left = 809
    Top = 3
  end
  object PrmGet: TButGet
    VName = 'GFViewPrm'
    Left = 48
    Top = 17
  end
  object dePrm: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      
        #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1092#1086#1088#1084#1072#1090#1072'#RGF#PRMNAME#TSimpleGet###0#1#T#F#T#F#F####-' +
        '1#0#F#F#F#T')
    HelpContext = 0
    NameWnd = 'GFPrmList'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFldCheck = dePrmFldCheck
    Left = 592
    Top = 120
  end
  object dePage: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      
        #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1083#1080#1089#1090#1072'#RGF#PRMNAME#TSimpleGet###0#1#T#F#T#F#F####-1#' +
        '0#F#F#F#T')
    HelpContext = 0
    NameWnd = 'GFPageList'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    Left = 592
    Top = 152
  end
  object deDopAlgName: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1050#1083#1072#1074#1080#1096#1072' '#1074#1099#1087#1086#1083#1085#1077#1085#1080#1103' '#1076#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1099#1093' '#1076#1077#1081#1089#1090#1074#1080#1081
    Fields.Strings = (
      #1053#1072#1079#1074#1072#1085#1080#1077'#RGF#PRMNAME#TSimpleGet###0#1#T#F#T#F#F####-1#0#F#F#F#T')
    HelpContext = 0
    NameWnd = 'GFDopAlgName'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    Left = 592
    Top = 184
  end
  object deFont0: TDefEdit
    DcmBased = False
    DcmDef = 
      'WA'#1050'CBAe'#1046'QIECBAe'#1046'QIECBAe'#1046'QIECBAe'#1046'QIECBAe'#1046'QIECBAe'#1046'QIECBAe'#1046'QIEAAAAA' +
      'AAAAAA'#1048'AAAAAAAABBe'#1046'QQEABAeAAAEAAAAKACIACXAeQFAAAAAAAB'#1070'EAAAAAAAGA' +
      'BeA'#1062'AMBwAAACmEAAHeAAG?'#1085#1095'1'#1070#1079#1080'1'#1050'f'#1102'1a'#1043'sHmCAEeB'#1062'AAAh'#1069#1079#1060#1052'pV'#1086#1046#1053'Z'#1060#1098'uAAA' +
      '05'#1080'O'#1089'D'#1073'6087'#1042#1082'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' +
      'AAAAQAIABeA'#1082'AAAAAB'#1047'uAAAw'#1049'vj'#1086#1040#1047#1050'k'#1050'xJe'#1090#1054'GAAAAAAaAAAAAAAAAAAAA'#1062'AQAE' +
      'ABeAAAAAAeAAAAGAAAAAAaAAAAAAAAAAAAAQAQACABeAAAAAB'#1052'AAAD'#1045'j'#1090#1063#1071'q'#1060#1069#1041#1077 +
      #1084'm'#1044#1045'Xe'#1040'KR'#1063'6O9?'#1073#1095#1102'a'#1081'gHl'#1081#1098#1098#1070#1078'CHd'#1079#1099#1103'3as'#1097'56'#1046'26'#1080'O1'#1057#1088#1046'24'#1043'sX?'#1073#1096'0Ilx1l'#1087#1098 +
      'Gg'#1074#1079'O'#1061'Q'#1046#1055'Z'#1058#1066#1065#1063'm'#1076#1069'KE'#1103'S'#1043'M'#1053'WJ'#1091#1102#1100#1079'Si'#1056'SE'#1100'm'#1066'U'#1046'Q'#1064#1040#1058'0P'#1042#1054'26'#1080'Cm'#1066'Vo'#1089#1065#1070#1079#1064'9Lv' +
      #1087#1100'Bu'#1072'd'#1043'g'#1091#1065#1076'Mkp'#1070#1054'RIE'#1048#1088'TXm'#1088#1098'FPPp'#1082#1055'Uh'#1047#1046'YAABAAB'#1098'AAAAAAAAAAAAAeA'#1082'AQAI' +
      'AAAAAACAAAAAYAAAAAB'#1098'AAAAAAAAAAAAAAA'#1098'AEAIAAAAAACAAAAAAAAAAAB'#1098'AAAA' +
      'AAAAAAAABAA'#1046'AMAEAAAAAAKMAAAFS'#1043'M'#1060#1054'Um'#1067#1040'f'#1040'n'#1053'B'#1046'AAAAAHeAAAAAAAAAAAACA' +
      'BAA'#1046'AQAAAAAAUiAAA'#1065'2'#1079'GXZj'#1088#1101'?a'#1055'D'#1085#1100'2D'#1047#1048'Wtj'#1087#1103'4'#1044'8lLf'#1100'8I'#1043'9H?h'#1087#1103'8'#1086'O'#1097'Uf'#1083 +
      '1!6'#1080#1055'D'#1097#1087'0I'#1043#1080'BI4c26'#1080'A'#1090#1057'Lv'#1087#1100'EFTVkk'#1068'ZL'#1052#1099#1046'sw'#1049'vi'#1100#1083#1043#1044's'#1057'w'#1054'j'#1048#1046's'#1055'GgiCG'#1049#1051's' +
      #1083#1101'jPPp'#1082#1055'Gg'#1075#1058'0'#1069'L'#1072#1061#1099'!'#1042#1080#1046#1040'K'#1089#1101#1074#1059'W?'#1047'm'#1091#1069'FCRAi'#1058#1084#1064'3M'#1096'Av'#1099'3aFSm'#1066'UDAAAQAA'#1044'A' +
      'AAAAAAAAAAAAYAEACAAeAAAAAAl'#1082'AABj'#1090#1100'3CCno'#1085#1049#1041'Mjx'#1070'u'#1053#1055'R'#1090#1084#1071#1062'st'#1053'V'#1091'U'#1048'vQ'#1053 +
      'Uh'#1047#1048'BDRw'#1089#1062'3'#1084'fIo'#1048'Uh'#1047#1058#1072'?'#1041'j'#1093'X2'#1079'O'#1061'QNFIi'#1046#1090#1054'GAAA'#1046'AAaAAAAAAAAAAAAAQAAAC' +
      'AAeAAAAAAk'#1046'AADR'#1095'3'#1071'cOXD'#1072#1046'0'#1071'a'#1096#1053'qf'#1099'3a'#1043#1096#1073'D'#1075#1090'Gge'#1062'AAAAAD'#1082'AAAAAAAAAAAAC' +
      'AAAAYAEAAAAAAU'#1042'AAAK'#1050'!Y'#1078'w'#1053'z'#1090#1050#1056'v'#1060'j'#1048'xeuAAAAAD'#1082'AAAAAAAAAAAADAAAA'#1046'AEA' +
      'AAAAAEQAAAF'#1101'Jef'#1094'0D'#1047#1046'YAAAAAB'#1098'AAAAAAAAAAAAAAAQAEADAAAAAAKQAAAFS'#1043'M'#1060 +
      #1057'w'#1054'j'#1048#1047#1054'j'#1058'VIU'#1084#1062'AAAAAAAaAAAAAAAAAAAAAAAMABAB'#1046'AAAAACg'#1082'AAB'#1050'l'#1049'Ln'#1102#1100#1079'Si' +
      #1056'SAAAAAAAD'#1082'AAAAAAAAAAAAAAB'#1046'AIAOAAAAAAUSAAAK'#1050'!Y'#1078'f'#1052'S'#1055#1086#1054'AAAAAAA2AAA' +
      'AAAAAAAAAAAAAACAAeAAAAAFFeAACnOkXT'#1091#1086#1084#1087'In'#1049'eAAAAAAHeAAAAAAAAAAADkA' +
      'AAAAAAAEACAA2AAAAAAQAAA'#1063'Oe'#1046'A'
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      '#RGF#ONLYDIG#TBoolGet##'#1058#1086#1083#1100#1082#1086' '#1094#1080#1092#1088#1099'#0#1#T#F#T#F#F####0#0#F#F'
      
        '#RGF#WIDTHTEXTALL#TBoolGet##'#1064#1080#1088#1080#1085#1072' '#1087#1086' '#1074#1089#1077#1084#1091' '#1090#1077#1082#1089#1090#1091'#0#1#T#F#T#F#F' +
        '####0#0#F#F'
      
        '#RGF#ONWIDTH#TBoolGet##'#1043#1088#1072#1085#1080#1094#1099' '#1087#1086' '#1096#1080#1088#1080#1085#1077'#0#1#T#F#T#F#F####0#0#F#' +
        'F'
      
        '#RGF#ALINE#TBoolGet##'#1056#1072#1079#1073#1080#1090#1100' '#1087#1086' '#1087#1086#1083#1091#1095#1077#1085#1085#1086#1081' '#1096#1080#1088#1080#1085#1077'#0#1#T#F#T#F#F#' +
        '###0#0#F#F'
      
        #1048#1085#1090#1077#1088#1074#1072#1083' '#1084#1077#1078#1076#1091' '#1089#1090#1088#1086#1082#1072#1084#1080'#RGF#Z#TMultiGet###0#1#T#F#T#F#T####0#0#F' +
        '#F#F#F'
      
        '/10 '#1084#1084'#RGF#ROWBETWEEN#TSpinGet###0#1#T#F#T#F#F###RGF.Z#0#0#F#F#T' +
        '#F'
      
        #1059#1074#1077#1083#1080#1095#1080#1074#1072#1090#1100' '#1087#1088#1086#1073#1077#1083#1099' '#1085#1077' '#1073#1086#1083#1077#1077' '#1095#1077#1084' '#1085#1072'#RGF#Z1#TMultiGet###0#1#T#F#T' +
        '#T#F####0#0#F#F#F#F'
      '%#RGF#PRCSPMIN#TSpinGet###0#1#T#F#T#T#F###RGF.Z1#0#0#F#F#T#F'
      
        #1047#1072#1087#1086#1083#1085#1080#1090#1100' '#1089#1087#1088#1072#1074#1072' '#1087#1086#1089#1083#1077#1076#1085#1102#1102' '#1089#1090#1088#1086#1082#1091' '#1089#1080#1084#1074#1086#1083#1086#1084'#RGF#CHRFILL#TSimpleGe' +
        't###0#1#T#F#T#T#F####0#0#F#F')
    HelpContext = 0
    NameWnd = 'GFFont0'
    PnlAskByCancel = False
    PnlSortMode = smColumns
    OnFldChange = deFont0FldChange
    Left = 728
    Top = 56
  end
  object FontDopGet: TButGet
    OnClick = FontDopGetClick
    OnPaint = FontDopGetPaint
    Left = 696
    Top = 56
  end
  object FontTypeGet: TRadioGet
    Left = 632
    Top = 56
  end
  object deFont1: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      '#RGF#ONLYDIG#TBoolGet##'#1058#1086#1083#1100#1082#1086' '#1094#1080#1092#1088#1099'#0#1#T#F#T#F#F####0#0#F#F'
      
        '#RGF#MMETRSEP#TBoolGet##'#1056#1072#1079#1084#1077#1088' '#1103#1095#1077#1081#1082#1080' '#1074' '#1084#1084'#0#1#T#F#T#F#F####0#0#' +
        'F#F'
      #1064#1080#1088#1080#1085#1072'#RGF#WIDTHMM#TSpinGet###0#1#T#F#T#T#T####0#0#F#F'
      #1042#1099#1089#1086#1090#1072'#RGF#HEIGHTMM#TSpinGet###0#1#T#F#T#T#F####0#0#F#F')
    HelpContext = 0
    NameWnd = 'GFFont1'
    PnlAskByCancel = False
    PnlSortMode = smColumns
    OnFldChange = deFont1FldChange
    Left = 760
    Top = 56
  end
  object deFont2: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      
        #1059#1074#1077#1083#1080#1095#1077#1085#1080#1077' '#1088#1072#1079#1084#1077#1088#1086#1074' '#1085#1072' (%)#RGF#KOEF#TSpinGet##-20,100,5#0#1#T#F#' +
        'T#F#F####0#0#F#F')
    HelpContext = 0
    NameWnd = 'GFFont2'
    PnlAskByCancel = False
    PnlSortMode = smColumns
    Left = 792
    Top = 56
  end
  object deNewLine: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1053#1086#1074#1099#1077' '#1083#1080#1085#1080#1080' '#1075#1088#1072#1085#1080#1094' '#1086#1073#1098#1077#1082#1090#1086#1074
    Fields.Strings = (
      
        '#RGF#NEWLINE#TBoolMultiGet#NoEmpty#'#1042#1077#1088#1090#1080#1082#1072#1083#1100#1085#1099#1077'^'#1043#1086#1088#1080#1079#1086#1085#1090#1072#1083#1100#1085#1099#1077'#0' +
        '#1#T#F#T#F#F####0#0#F#F#F#F')
    HelpContext = 0
    NameWnd = 'GFNewLine'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFrmShow = deNewLineFrmShow
    OnPnlCngKey = deNewLinePnlCngKey
    OnPnlValid = deNewLinePnlValid
    Left = 592
    Top = 216
  end
  object mnInsObj: TDefMenu
    BevelInner = bvNone
    BevelOuter = bvLowered
    BevelWidth = 1
    BorderStyle = bsNone
    KeyBevel = 1
    KeySpot = 3
    KeyBetween = 1
    Keys.Strings = (
      '1#'#1089#1085#1080#1079#1091'##F#F#F'
      '2#'#1089#1087#1088#1072#1074#1072'##F#F#F'
      '3#'#1089#1074#1077#1088#1093#1091'##F#F#F'
      '4#'#1089#1083#1077#1074#1072'##F#F#F')
    FrmBorderIcons = [biSystemMenu, biMinimize]
    FrmBorderStyle = bsSingle
    FrmCaption = #1042#1089#1090#1072#1074#1080#1090#1100' '#1089#1082#1086#1087#1080#1088#1086#1074#1072#1085#1085#1099#1077' '#1086#1073#1098#1077#1082#1090#1099
    Left = 737
    Top = 107
  end
  object deAutoSave: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1072#1074#1090#1086#1089#1086#1093#1088#1072#1085#1077#1085#1080#1103
    Fields.Strings = (
      
        #1048#1085#1090#1077#1088#1074#1072#1083'~(0-'#1086#1090#1082#1083#1102#1095#1080#1090#1100')#RGF#Z#TMultiGet###0#1#T#F#T#F#F####0#0#F#' +
        'F#F#F'
      
        #1089#1077#1082'.#RGF#AUTOSAVEINTV#TSpinGet##0,99999,1,F#0#1#T#F#T#F#F###RGF.' +
        'Z#0#0#F#F#T#F')
    HelpContext = 0
    NameWnd = 'GFAutoSave'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    Left = 593
    Top = 243
  end
  object deFont3: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      
        #1059#1088#1086#1074#1077#1085#1100' '#1082#1086#1088#1088#1077#1082#1094#1080#1080' '#1086#1096#1080#1073#1086#1082'#RGF#ECCLEVEL#TMenuGet#Customize##0#1#T#' +
        'F#T#F#F####0#0#F#F#F#F'
      
        #1052#1080#1085#1080#1084#1072#1083#1100#1085#1099#1081' '#1088#1072#1079#1084#1077#1088' '#1084#1086#1076#1091#1083#1103'#RGF#Z#TMultiGet###0#1#T#F#T#F#F####0#0' +
        '#F#F#F#F'
      
        '/10 '#1084#1084'#RGF#MODULE#TSpinGet##2,99,1,F#0#1#T#F#T#F#F###RGF.Z#0#0#F' +
        '#F#T#F')
    HelpContext = 0
    NameWnd = 'GFFont3'
    PnlAskByCancel = False
    PnlSortMode = smColumns
    Left = 824
    Top = 56
  end
  object deFont4: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      
        #1052#1072#1082#1089#1080#1084#1072#1083#1100#1085#1099#1081' '#1091#1088#1086#1074#1077#1085#1100' '#1082#1086#1088#1088#1077#1082#1094#1080#1080' '#1086#1096#1080#1073#1086#1082'#RGF#ECCLEVEL#TSpinGet###0#' +
        '1#T#F#T#F#F####0#0#F#F#F#F'
      
        #1054#1090#1085#1086#1096#1077#1085#1080#1077' '#1074#1099#1089#1086#1090#1099' '#1084#1086#1076#1091#1083#1103' '#1082' '#1096#1080#1088#1080#1085#1077'#RGF#ROWHEIGHT#TSpinGet###0#1#T#' +
        'F#T#F#F####0#0#F#F#F#F'
      
        #1052#1072#1082#1089#1080#1084#1072#1083#1100#1085#1099#1077' '#1088#1072#1079#1084#1077#1088#1099' '#1084#1086#1076#1091#1083#1103'~(1/10 '#1084#1084')#RGF#Z#TMultiGet###0#1#T#F#' +
        'T#F#F####0#0#F#F#F#F'
      
        #1096#1080#1088#1080#1085#1072'#RGF#MODULE#TSpinGet##1,99,1,F#0#1#T#F#T#F#F###RGF.Z#0#0#F' +
        '#F#F#F'
      
        #1074#1099#1089#1086#1090#1072'#RGF#MODULEHEIGHT#TSimpleGet###4#1#T#F#F#F#F###RGF.Z#0#0#F' +
        '#F#F#F')
    HelpContext = 0
    NameWnd = 'GFFont4'
    PnlAskByCancel = False
    PnlSortMode = smColumns
    OnFldChange = deFont4FldChange
    Left = 856
    Top = 56
  end
  object deFontSel: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      #1064#1088#1080#1092#1090'#RGF#FONTNOM###@C#0#1#T#F#T#F#F####0#0#F#F#F#F'
      
        #1056#1072#1079#1084#1077#1089#1090#1080#1090#1100'#RGF#FONTALGN#TRadioGet#Customize##0#1#T#F#T#F#F####0#' +
        '0#F#F#F#F')
    HelpContext = 0
    NameWnd = 'GFFontSel'
    PnlAskByCancel = False
    PnlSortMode = smColumns
    Left = 592
    Top = 272
  end
end
