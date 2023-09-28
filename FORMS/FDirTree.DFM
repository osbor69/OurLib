inherited DirTree: TDirTree
  Caption = ''
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    Left = 7
    inherited KeyLb1: TKeyLb
      NmProc.Strings = (
        'Esc#'#1054#1090#1084#1077#1085#1072'##FILE##'
        'F10#####Esc')
      OnProcKey = KeyLb1ProcKey
    end
    object pnTree: TTreeDir
      Left = 42
      Top = 42
      Width = 467
      Height = 255
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
      HideExt = False
      Options = []
      IniOptions = [tpiExpanded]
      ProcSel = KeyLb1ProcKey
      SectIni = 'Dir'
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 16
    Top = 8
  end
end
