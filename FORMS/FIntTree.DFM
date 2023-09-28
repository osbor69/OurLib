inherited IntTree: TIntTree
  Caption = ''
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    Schem = 'Tree'
    inherited KeyLb1: TKeyLb
      NmProc.Strings = (
        'Esc#'#1042#1099#1093#1086#1076'##FILE##'
        'F10#####Esc'
        'F5#'#1055#1077#1095#1072#1090#1100'##FILE##')
    end
    inherited RbPanel2: TRbPanel
      Top = 23
      Schem = 'Tree'
      SortObj = False
      BevelOuter = bvNone
      Place = rpBottom
      object RbStatus1: TRbStatus
        Tag = -1
        Left = 28
        Top = 261
        Width = 516
        Height = 36
        MinSized = False
        ParentSchem = False
        Schem = 'Status'
        SimpleLine = False
        Alignment = taLeftJustify
        BevelOuter = bvLowered
        Visible = False
      end
      object pnTree: TRbPanel
        Left = 28
        Top = 21
        Width = 516
        Height = 227
        MinSized = False
        ParentSchem = True
        Schem = 'Tree'
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
        object TreePrim1: TTreePrim
          Left = 56
          Top = 42
          Width = 107
          Height = 86
          Indent = 19
          ReadOnly = True
          SortType = stText
          TabOrder = 0
          FontPrim.Charset = DEFAULT_CHARSET
          FontPrim.Color = clWindowText
          FontPrim.Height = -13
          FontPrim.Name = 'MS Sans Serif'
          FontPrim.Style = []
          SeekCaption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
          SeekLength = 20
          Options = [tpNoDopDispose]
          OnCustomDrawPrim = TreePrim1CustomDrawPrim
        end
      end
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 32
    Top = 9
  end
end
