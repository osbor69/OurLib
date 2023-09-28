inherited PrnTxt: TPrnTxt
  Width = 782
  Caption = 'Печать'
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      NmProc.Strings = (
        'F3#Принтер#Настройка принтера#SERVIC'
        'Ctrl_F3#Отступы#Установить мин.отступы принтера#SERVIC')
    end
    inherited RbPanel2: TRbPanel
      BevelOuter = bvNone
      Place = rpBottom
      object RbStatus1: TRbStatus
        Tag = -1
        Left = 7
        Top = 282
        Width = 347
        Height = 29
        MinSized = False
        ParentSchem = False
        Schem = 'Status'
        SimpleLine = False
        Alignment = taLeftJustify
        BevelOuter = bvLowered
      end
      object PnEd: TPanelEdit
        Left = 0
        Top = 0
        Width = 566
        Height = 276
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
        Place = rpBottom
        SayRight = False
        TabOrder = 1
        WMin = 0
        OnEnter = PnEdEnter
        Options = []
        OnEscape = PnEdEscape
        OnCngKey = PnEdCngKey
        OnValid = PnEdValid
        object PnSpot: TRbPanel
          Left = 14
          Top = 212
          Width = 537
          Height = 57
          MinSized = False
          ParentSchem = True
          Schem = 'Edit'
          CanSize = False
          CanMove = False
          MaxWidth = False
          Header = 'Отступы (мм)'
          ProcentWnd = 20
          SortMode = smDefault
          SortObj = True
          BevelOuter = bvLowered
          HMin = 0
          Place = rpNone
          SayRight = False
          TabOrder = 1
          WMin = 0
          object EPTop: TFldEdit
            Left = 71
            Top = 28
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = '0,999'
            MaxLength = 0
            NameRec = 'PrnTxt'
            NameRecFld = 'PTop'
            Vid = 'TSpinGet'
            ParentShowHint = False
            ShowHint = True
            SayCaption = 'сверху'
            SayRight = False
            TabOrder = 0
            TabStop = True
          end
          object EPBottom: TFldEdit
            Left = 184
            Top = 28
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = '0,999'
            MaxLength = 0
            NameRec = 'PrnTxt'
            NameRecFld = 'PBottom'
            Vid = 'TSpinGet'
            ParentShowHint = False
            ShowHint = True
            SayCaption = 'снизу'
            SayRight = False
            TabOrder = 1
            TabStop = True
          end
          object EPLeft: TFldEdit
            Left = 282
            Top = 28
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = '0,999'
            MaxLength = 0
            NameRec = 'PrnTxt'
            NameRecFld = 'PLeft'
            Vid = 'TSpinGet'
            ParentShowHint = False
            ShowHint = True
            SayCaption = 'слева'
            SayRight = False
            TabOrder = 2
            TabStop = True
          end
          object EPRight: TFldEdit
            Left = 424
            Top = 28
            Width = 86
            Height = 26
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            CharCase = ecNormal
            CharWidth = 0
            CharHeight = 0
            Mask = '0,999'
            MaxLength = 0
            NameRec = 'PrnTxt'
            NameRecFld = 'PRight'
            Vid = 'TSpinGet'
            ParentShowHint = False
            ShowHint = True
            SayCaption = 'справа'
            SayRight = False
            TabOrder = 3
            TabStop = True
          end
        end
        object Pn1: TRbPanel
          Left = 7
          Top = 0
          Width = 544
          Height = 206
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
          object PnPrm: TRbPanel
            Left = 7
            Top = 7
            Width = 248
            Height = 192
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            OnSetWHMin = PnPrmSetWHMin
            CanSize = False
            CanMove = False
            MaxWidth = False
            Header = 'Параметры'
            ProcentWnd = 50
            SortMode = smDefault
            SortObj = True
            BevelOuter = bvLowered
            HMin = 0
            Place = rpNone
            SayRight = False
            TabOrder = 0
            WMin = 0
            object EVPrn: TFldEdit
              Left = 64
              Top = 126
              Width = 165
              Height = 40
              MinSized = False
              ParentSchem = False
              Schem = 'Edit'
              CharCase = ecNormal
              CharWidth = 0
              CharHeight = 0
              MaxLength = 0
              NameRec = 'PrnTxt'
              NameRecFld = 'VPRN'
              Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
              Value = '1'
              Vid = 'TRadioGet'
              VName = 'VPrnTxt'
              ParentShowHint = False
              ShowHint = True
              SayCaption = 'Печатать'
              SayRight = False
              TabOrder = 3
              TabStop = True
            end
            object EFeed: TFldEdit
              Left = 162
              Top = 63
              Width = 86
              Height = 26
              MinSized = False
              ParentSchem = False
              Schem = 'Edit'
              CharCase = ecNormal
              CharWidth = 0
              CharHeight = 0
              MaxLength = 0
              NameRec = 'PrnPrm'
              NameRecFld = 'Feed'
              Vid = 'TRadioGet'
              VName = 'Feed'
              ParentShowHint = False
              ShowHint = True
              SayCaption = 'Подача бумаги'
              SayRight = False
              TabOrder = 1
              TabStop = True
            end
            object EFont: TFldEdit
              Left = 64
              Top = 78
              Width = 86
              Height = 26
              MinSized = False
              ParentSchem = True
              Schem = 'Edit'
              CharCase = ecNormal
              CharWidth = 0
              CharHeight = 0
              Mask = '1'
              MaxLength = 0
              Vid = 'TButGet'
              VName = 'SchFont'
              ParentShowHint = False
              ShowHint = True
              SayCaption = 'Шрифт'
              SayRight = False
              TabOrder = 2
              TabStop = True
            end
            object EFile: TFldEdit
              Left = 125
              Top = 13
              Width = 86
              Height = 25
              MinSized = False
              ParentSchem = False
              Schem = 'Edit'
              CharCase = ecNormal
              CharWidth = -1
              CharHeight = 0
              MaxLength = 0
              NameRec = 'PrnTxt'
              NameRecFld = 'FILE'
              Options = [ogAutoSelect, ogReadOnlyNoVsbl, ogAutoSize]
              Vid = 'TDirGet'
              VName = 'PrnTxt'
              OnChange = EFileChange
              ParentShowHint = False
              ShowHint = True
              SayCaption = 'Печать в файл'
              SayRight = False
              TabOrder = 0
              TabStop = True
            end
          end
          object PnCop: TRbPanel
            Left = 261
            Top = 7
            Width = 283
            Height = 192
            MinSized = False
            ParentSchem = True
            Schem = 'Edit'
            OnSetWHMin = PnCopSetWHMin
            CanSize = False
            CanMove = False
            MaxWidth = False
            Header = 'Копии'
            ProcentWnd = 100
            SortMode = smDefault
            SortObj = True
            BevelOuter = bvLowered
            HMin = 0
            Place = rpNone
            SayRight = False
            TabOrder = 1
            WMin = 0
            object ECnt: TFldEdit
              Left = 113
              Top = 19
              Width = 86
              Height = 26
              MinSized = False
              ParentSchem = False
              Schem = 'Edit'
              CharCase = ecNormal
              CharWidth = 0
              CharHeight = 0
              Mask = '1,10'
              MaxLength = 0
              NameRec = 'PrnPrm'
              NameRecFld = 'Cnt'
              Vid = 'TSpinGet'
              OnChange = ECntChange
              ParentShowHint = False
              ShowHint = True
              SayCaption = 'Число копий'
              SayRight = False
              TabOrder = 0
              TabStop = True
            end
            object ESortCop: TFldEdit
              Left = 14
              Top = 49
              Width = 86
              Height = 26
              MinSized = False
              ParentSchem = False
              Schem = 'Edit'
              CharCase = ecNormal
              CharWidth = 0
              CharHeight = 0
              Mask = 'Разобрать по копиям @PL'
              MaxLength = 0
              NameRec = 'PrnPrm'
              NameRecFld = 'SortCop'
              Vid = 'TBoolDrwGet'
              VName = 'SortCop'
              ParentShowHint = False
              ShowHint = True
              SayRight = False
              TabOrder = 1
              TabStop = True
            end
          end
        end
      end
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 8
    Top = 8
  end
  object Rec: TRecVal
    NameRec = 'PrnTxt'
    Fields.Strings = (
      'VPrn=N'
      'PTop=N#3'
      'PBottom=N#3'
      'PLeft=N#3'
      'PRight=N#3'
      'FILE=M')
    Left = 48
    Top = 9
  end
  object VPrnGet: TRadioGet
    Items.Strings = (
      'Всё'
      'Выделенный фрагмент')
    VName = 'VPrnTxt'
    Left = 25
    Top = 91
  end
  object DirGet1: TDirGet
    VName = 'PrnTxt'
    OpenDialog = SaveDialog1
    Options = [dgNoCheckDir]
    Left = 96
    Top = 8
  end
  object SaveDialog1: TSaveDialog
    Title = 'Печать в файл'
    Left = 128
    Top = 8
  end
end
