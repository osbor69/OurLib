inherited SearchTree: TSearchTree
  Caption = ''
  PixelsPerInch = 120
  TextHeight = 17
  inherited RbPanel1: TRbPanel
    Schem = 'Tree'
    inherited KeyLb1: TKeyLb
      NmProc.Strings = (
        'Esc#'#1054#1090#1084#1077#1085#1072'##FILE##'
        'F10#####Esc'
        'Enter#'#1042#1099#1073#1086#1088'##FILE##')
    end
    inherited RbPanel2: TRbPanel
      Schem = 'Tree'
      object Tree: TTreePrim
        Left = 152
        Top = 96
        Width = 121
        Height = 97
        Indent = 19
        ReadOnly = True
        TabOrder = 0
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
end
