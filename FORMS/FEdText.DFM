inherited EdText: TEdText
  Left = 388
  Width = 764
  Height = 555
  Caption = ''
  Menu = KeyMenu1
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      NmProc.Strings = (
        'Esc#'#1054#1090#1084#1077#1085#1072'##FILE'
        'F10#'#1042#1099#1093#1086#1076'##FILE')
    end
    inherited RbPanel2: TRbPanel
      BevelOuter = bvNone
      Place = rpBottom
      object RbStatus1: TRbStatus
        Tag = -1
        Left = 14
        Top = 198
        Width = 163
        Height = 36
        MinSized = False
        ParentSchem = False
        Schem = 'Status'
        Alignment = taLeftJustify
        BevelOuter = bvLowered
      end
      object PnMemo: TRbPanel
        Left = 7
        Top = 7
        Width = 417
        Height = 177
        MinSized = False
        ParentSchem = False
        Schem = 'EdTxt'
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
        OnResize = PnMemoResize
      end
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 72
    Top = 8
  end
end
