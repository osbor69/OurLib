inherited PrivLst: TPrivLst
  Caption = #1059#1089#1090#1072#1085#1086#1074#1082#1072' '#1087#1088#1072#1074' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      object tbl: TStrTable
        Left = 134
        Top = 85
        Width = 282
        Height = 106
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goRowSizing, goColSizing]
        TabOrder = 0
        OnDrawCell = tblDrawCell
        KeyDblClick = 13
        TitleFont.Charset = RUSSIAN_CHARSET
        TitleFont.Color = clBlack
        TitleFont.Height = -15
        TitleFont.Name = 'Courier New'
        TitleFont.Style = []
        CaptX = #1055#1054#1051#1068#1047#1054#1042#1040#1058#1045#1051#1048
        CaptY = #1055#1056#1040#1042#1040
        MinColLength = 0
        InvertedIniDefault = False
        InvertedIniSect = 'PrivLst'
      end
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 48
    Top = 25
  end
end
