inherited TblFld: TTblFld
  Caption = ' '
  Menu = KeyMenu1
  PixelsPerInch = 120
  TextHeight = 17
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      ParentSchem = False
      Schem = 'Tree'
      BevelOuter = bvNone
      object Tree: TTreePrim
        Left = 160
        Top = 73
        Width = 121
        Height = 96
        Indent = 19
        ReadOnly = True
        TabOrder = 0
        OnExpanding = TreeExpanding
        FontPrim.Charset = DEFAULT_CHARSET
        FontPrim.Color = clWindowText
        FontPrim.Height = -13
        FontPrim.Name = 'MS Sans Serif'
        FontPrim.Style = []
        SeekLength = 0
        Options = []
      end
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 16
  end
end
