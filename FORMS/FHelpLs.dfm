inherited HelpLs: THelpLs
  Caption = #1055#1086#1084#1086#1097#1100
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      BevelOuter = bvNone
      Place = rpBottom
      object RbStatus1: TRbStatus
        Tag = -1
        Left = 64
        Top = 268
        Width = 163
        Height = 36
        MinSized = False
        ParentSchem = False
        Schem = 'Status'
        SimpleLine = False
        Alignment = taLeftJustify
        BevelOuter = bvLowered
      end
      object RbPanel3: TRbPanel
        Left = 42
        Top = 28
        Width = 524
        Height = 234
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
        object pnPart: TRbPanel
          Left = 49
          Top = 14
          Width = 164
          Height = 220
          MinSized = False
          ParentSchem = False
          Schem = 'Browl'
          OnSetWHMin = pnPartSetWHMin
          CanSize = False
          CanMove = False
          MaxWidth = False
          ProcentWnd = 0
          SortMode = smDefault
          SortObj = False
          BevelOuter = bvLowered
          HMin = 0
          Place = rpNone
          SayRight = False
          TabOrder = 0
          WMin = 0
          OnResize = pnResize
        end
        object pnMemo: TRbPanel
          Left = 247
          Top = 0
          Width = 276
          Height = 234
          MinSized = False
          ParentSchem = False
          Schem = 'EdTxt'
          CanSize = False
          CanMove = False
          MaxWidth = False
          ProcentWnd = 100
          SortMode = smDefault
          SortObj = False
          BevelOuter = bvNone
          HMin = 0
          Place = rpNone
          SayRight = False
          TabOrder = 1
          WMin = 0
          OnResize = pnResize
        end
      end
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 16
    Top = 8
  end
end
