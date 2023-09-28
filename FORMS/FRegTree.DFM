inherited RegTree: TRegTree
  Caption = #1056#1077#1077#1089#1090#1088
  Menu = KeyMenu1
  PixelsPerInch = 120
  TextHeight = 17
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      NmProc.Strings = (
        'Esc#'#1054#1090#1084#1077#1085#1072'##FILE##'
        'F10#####Enter'
        'Enter#'#1042#1099#1073#1086#1088'##FILE##')
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
      object pnTree: TRbPanel
        Left = 40
        Top = 16
        Width = 385
        Height = 217
        MinSized = False
        ParentSchem = False
        Schem = 'Tree'
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
        TabOrder = 1
        WMin = 0
        object Tree: TTreePrim
          Left = 0
          Top = 0
          Width = 385
          Height = 217
          Align = alClient
          Indent = 19
          ReadOnly = True
          TabOrder = 0
          OnChange = TreeChange
          OnExpanding = TreeExpanding
          FontPrim.Charset = DEFAULT_CHARSET
          FontPrim.Color = clWindowText
          FontPrim.Height = -13
          FontPrim.Name = 'MS Sans Serif'
          FontPrim.Style = []
          SeekLength = 0
          Options = [tpEnterExpand]
        end
      end
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 8
  end
end
