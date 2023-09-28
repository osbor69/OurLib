inherited Struct: TStruct
  Caption = #1057#1090#1088#1091#1082#1090#1091#1088#1072' '#1090#1072#1073#1083#1080#1094
  PixelsPerInch = 120
  TextHeight = 17
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      Font.Charset = RUSSIAN_CHARSET
      Font.Height = -15
      Font.Style = []
    end
    inherited RbPanel2: TRbPanel
      BevelOuter = bvNone
      Place = rpBottom
      object RbStatus1: TRbStatus
        Tag = -1
        Left = 64
        Top = 304
        Width = 185
        Height = 41
        MinSized = False
        ParentSchem = False
        Schem = 'Status'
        Alignment = taLeftJustify
        BevelOuter = bvLowered
      end
      object pnsb: TRbPanel
        Left = 8
        Top = 8
        Width = 625
        Height = 273
        MinSized = False
        ParentSchem = False
        Schem = 'Browl'
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
        object sb: TStringBrowl
          Left = 169
          Top = 131
          Width = 320
          Height = 120
          FixedCols = 0
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSizing, goColSizing, goRowSelect]
          TabOrder = 0
          OnDrawCell = sbDrawCell
          KeyDblClick = 13
          TitleFont.Charset = RUSSIAN_CHARSET
          TitleFont.Color = clBlack
          TitleFont.Height = -15
          TitleFont.Name = 'Courier New'
          TitleFont.Style = []
          ColZn.Strings = (
            #1058#1072#1073#1083#1080#1094#1072'##L#15'
            #1055#1086#1083#1077'##L#20'
            #1058#1080#1087'##L#10'
            #1044#1083#1080#1085#1072'##R'
            #1053#1077' '#1087#1091#1089#1090#1086'##')
          SelectedOnlyFocused = False
          ColWidths = (
            139
            184
            94
            49
            76)
          RowHeights = (
            21
            24
            24
            24
            24)
        end
      end
    end
  end
end
