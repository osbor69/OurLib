inherited Stat: TStat
  HorzScrollBar.Range = 0
  VertScrollBar.Range = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  Caption = ''
  OnClose = FormClose
  PixelsPerInch = 120
  TextHeight = 17
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      CanMove = False
      NmProc.Strings = (
        'Ctrl_M#'#1057#1074#1077#1088#1085#1091#1090#1100'####'
        'Esc#'#1054#1090#1084#1077#1085#1072'####')
    end
    inherited RbPanel2: TRbPanel
      ParentSchem = False
      Schem = 'SayStat'
      SortObj = False
      BevelOuter = bvNone
    end
  end
end
