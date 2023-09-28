inherited Find: TFind
  Left = 239
  HorzScrollBar.Range = 0
  VertScrollBar.Range = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #1055#1086#1080#1089#1082
  ClientHeight = 397
  ClientWidth = 631
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      CanMove = False
    end
    inherited RbPanel2: TRbPanel
      BevelOuter = bvNone
      Place = rpBottom
      object PnMsg: TRbStatus
        Tag = -1
        Left = 14
        Top = 198
        Width = 439
        Height = 36
        MinSized = False
        ParentSchem = False
        Schem = 'Status'
        SimpleLine = False
        Alignment = taLeftJustify
        BevelOuter = bvLowered
      end
      object Pe: TPanelEdit
        Left = 14
        Top = 21
        Width = 439
        Height = 163
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
        Options = []
        OnCngKey = PeCngKey
        OnValid = PeValid
        object ES: TFldEdit
          Left = 14
          Top = 7
          Width = 86
          Height = 25
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CharCase = ecNormal
          CharWidth = -1
          CharHeight = 0
          MaxLength = 0
          Vid = 'TComboGet'
          VName = 'Find'
          OnCheck = ESCheck
          ParentShowHint = False
          ShowHint = True
          SayRight = False
          TabOrder = 0
          TabStop = True
        end
        object pn1: TRbPanel
          Left = 7
          Top = 42
          Width = 424
          Height = 72
          MinSized = True
          ParentSchem = True
          Schem = 'Edit'
          CanSize = False
          CanMove = False
          MaxWidth = False
          ProcentWnd = 0
          SortMode = smRows
          SortObj = True
          BevelOuter = bvNone
          HMin = 0
          Place = rpNone
          SayRight = False
          TabOrder = 1
          WMin = 0
          object ERegistr: TFldEdit
            Left = 0
            Top = 21
            Width = 149
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
            Mask = #1059#1095#1080#1090#1099#1074#1072#1090#1100' '#1088#1077#1075#1080#1089#1090#1088
            MaxLength = 0
            Value = 'F'
            Vid = 'TBoolGet'
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 0
            TabStop = True
          end
          object EWord: TFldEdit
            Left = 159
            Top = 21
            Width = 170
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
            Mask = #1058#1086#1083#1100#1082#1086' '#1089#1083#1086#1074#1086' '#1094#1077#1083#1080#1082#1086#1084
            MaxLength = 0
            Value = 'F'
            Vid = 'TBoolGet'
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 1
            TabStop = True
          end
          object EDirection: TFldEdit
            Left = 346
            Top = 19
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            MaxLength = 0
            Value = '1'
            Vid = 'TRadioGet'
            VName = 'Feed'
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 2
            TabStop = True
          end
          object EReplace: TFldEdit
            Tag = 1
            Left = 7
            Top = 47
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
            Mask = #1047#1072#1084#1077#1085#1080#1090#1100' '#1085#1072
            MaxLength = 0
            Value = 'F'
            Vid = 'TBoolGet'
            OnChange = EReplaceChange
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 3
            TabStop = True
          end
        end
        object ER: TFldEdit
          Left = 14
          Top = 127
          Width = 86
          Height = 25
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CharCase = ecNormal
          CharWidth = -1
          CharHeight = 0
          MaxLength = 0
          Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
          Vid = 'TComboGet'
          VName = 'FindR'
          ParentShowHint = False
          ShowHint = True
          SayRight = False
          TabOrder = 2
          TabStop = True
        end
      end
    end
  end
  object RV: TRecVal
    Fields.Strings = (
      'S=M@H'#1057#1090#1088#1086#1082#1072' '#1076#1083#1103' '#1087#1086#1080#1089#1082#1072'@'
      'Registr=L@H'#1059#1095#1080#1090#1099#1074#1072#1090#1100' '#1088#1077#1075#1080#1089#1090#1088'@'
      'Word=L@H'#1058#1086#1083#1100#1082#1086' '#1089#1083#1086#1074#1086' '#1094#1077#1083#1080#1082#1086#1084'@'
      'Direction=N@H'#1053#1072#1087#1088#1072#1074#1083#1077#1085#1080#1077'@'
      'Replace=L@H'#1047#1072#1084#1077#1085#1080#1090#1100'@'
      'R=M@H'#1057#1090#1088#1086#1082#1072' '#1076#1083#1103' '#1079#1072#1084#1077#1085#1099'@')
    Left = 48
    Top = 8
  end
end
