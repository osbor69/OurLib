inherited ArrvEd: TArrvEd
  Left = 436
  Top = 246
  Caption = ''
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited PanelEdit1: TPanelEdit
      BevelOuter = bvNone
      Place = rpTop
      Options = [peAskByCancel]
      OnValid = PanelEdit1Valid
      object pn1: TRbPanel
        Left = 14
        Top = 21
        Width = 552
        Height = 79
        MinSized = False
        ParentSchem = True
        Schem = 'Edit'
        CanSize = False
        CanMove = False
        MaxWidth = False
        ProcentWnd = 0
        SortMode = smColumns
        SortObj = True
        BevelOuter = bvLowered
        HMin = 0
        Place = rpNone
        SayRight = False
        TabOrder = 0
        WMin = 0
        object EKa: TFldEdit
          Left = 64
          Top = 14
          Width = 82
          Height = 25
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CharCase = ecUpperCase
          CharWidth = 0
          CharHeight = 0
          MaxLength = 0
          NameRecFld = 'KA'
          Options = [ogAutoSelect, ogAutoSize, ogTrimLeft]
          Vid = 'TSimpleGet'
          OnCheck = EKaCheck
          ParentShowHint = False
          ShowHint = True
          SayCaption = ' '#1050#1086#1076' '
          SayRight = False
          TabOrder = 0
          TabStop = True
        end
        object EModel: TFldEdit
          Left = 109
          Top = 34
          Width = 531
          Height = 25
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CharCase = ecNormal
          CharWidth = 0
          CharHeight = 0
          Mask = 'NMODEL'
          MaxLength = 0
          NameRecFld = 'MODEL'
          Options = [ogAutoSelect, ogReadOnly, ogAutoSize]
          Value = '        '
          Vid = 'TModelGet'
          VName = 'Arrv'
          ParentShowHint = False
          ShowHint = True
          SayCaption = ' '#1054#1089#1085#1086#1074#1072' '
          SayRight = False
          TabOrder = 1
        end
        object EName: TFldEdit
          Left = 134
          Top = 56
          Width = 82
          Height = 25
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CharCase = ecNormal
          CharWidth = 0
          CharHeight = 0
          MaxLength = 0
          NameRecFld = 'NAME'
          Options = [ogAutoSelect, ogAutoSize, ogTrimLeft]
          Vid = 'TSimpleGet'
          ParentShowHint = False
          ShowHint = True
          SayCaption = ' '#1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '
          SayRight = False
          TabOrder = 2
          TabStop = True
        end
      end
      object pn2: TRbPanel
        Left = 7
        Top = 120
        Width = 573
        Height = 184
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
        TabOrder = 1
        WMin = 0
        object pnDW: TRbPanel
          Left = 21
          Top = 7
          Width = 283
          Height = 163
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CanSize = False
          CanMove = False
          MaxWidth = False
          ProcentWnd = 66
          SortMode = smDefault
          SortObj = True
          BevelOuter = bvNone
          HMin = 0
          Place = rpLeft
          SayRight = False
          TabOrder = 0
          WMin = 0
        end
        object pnFdel: TRbPanel
          Left = 374
          Top = 14
          Width = 121
          Height = 142
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
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
          OnResize = pnButResize
          object EFdel: TFldEdit
            Left = 7
            Top = 28
            Width = 76
            Height = 23
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
            CharWidth = -1
            CharHeight = -1
            Mask = '@H'#1044#1077#1081#1089#1090#1074#1080#1103' '#1087#1088#1080' '#1091#1076#1072#1083#1077#1085#1080#1080'@@,@'
            MaxLength = 0
            NameRecFld = 'MEM_FDEL'
            Options = [ogAutoSelect]
            Vid = 'TButFormGet'
            VName = 'ArrvFml'
            ParentShowHint = False
            ShowHint = True
            SayRight = False
            TabOrder = 0
            TabStop = True
          end
        end
      end
    end
  end
  object FmlGet: TButFormGet
    EditType = edtpInter
    OnAfterClick = FmlGetAfterClick
    OnBeforeClick = FmlGetBeforeClick
    VName = 'ArrvFml'
    Left = 456
    Top = 152
  end
  object DWGet: TButGet
    VName = 'Arrv'
    OnClick = DWGetClick
    OnPaint = DWGetPaint
    Left = 72
    Top = 153
  end
end
