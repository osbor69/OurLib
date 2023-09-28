inherited TabuLs: TTabuLs
  Caption = ''
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      NmProc.Strings = (
        'Esc#'#1042#1099#1093#1086#1076'##FILE##'
        'F10#####Esc'
        '')
    end
    inherited RbPanel2: TRbPanel
      ParentSchem = False
      Schem = 'Tree'
      object Tree: TTreePrim
        Left = 113
        Top = 28
        Width = 107
        Height = 86
        Indent = 19
        ReadOnly = True
        TabOrder = 0
        FontPrim.Charset = DEFAULT_CHARSET
        FontPrim.Color = clWindowText
        FontPrim.Height = -13
        FontPrim.Name = 'MS Sans Serif'
        FontPrim.Style = []
        SeekLength = 0
        Options = [tpCanCheck, tpNoDopDispose]
        OnCheckAll = TreeCheckAll
        OnChecking = TreeChecking
        OnChecked = TreeChecked
      end
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 24
    Top = 25
  end
  object dmUsers: TDefMenu
    BevelInner = bvNone
    BevelOuter = bvLowered
    BevelWidth = 1
    BorderStyle = bsNone
    KeyBevel = 3
    KeySpot = 5
    KeyBetween = 5
    FrmBorderIcons = [biSystemMenu, biMinimize]
    FrmBorderStyle = bsSingle
    FrmCaption = #1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1087#1088#1072#1074#1072' '#1089' '#1076#1088#1091#1075#1086#1075#1086' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
    Left = 64
    Top = 24
  end
end
