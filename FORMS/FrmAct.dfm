inherited FrmAction: TFrmAction
  Left = 284
  Top = 154
  Caption = ''
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      Font.Charset = RUSSIAN_CHARSET
      Font.Style = []
      NmProc.Strings = (
        'Esc#'#1042#1099#1093#1086#1076'##FILE##'
        'F10#####Esc'
        'Ctrl_E#'#1042#1099#1087#1086#1083#1085#1080#1090#1100'##LIST##'
        'Ctrl_P#'#1055#1088#1077#1076#1099#1076#1091#1097#1080#1081'##LIST##'
        'Ctrl_N#'#1057#1083#1077#1076#1091#1102#1097#1080#1081'##LIST##'
        'Ctrl_H#'#1048#1089#1090#1086#1088#1080#1103'##LIST##')
    end
    inherited RbPanel2: TRbPanel
      BevelOuter = bvNone
      Place = rpTop
      object pnText: TRbPanel
        Left = 8
        Top = 8
        Width = 543
        Height = 71
        MinSized = False
        ParentSchem = False
        Schem = 'EdTxt'
        CanSize = False
        CanMove = False
        MaxWidth = False
        ProcentWnd = 20
        SortMode = smDefault
        SortObj = True
        BevelOuter = bvNone
        HMin = 0
        Place = rpNone
        SayRight = False
        TabOrder = 0
        WMin = 0
      end
      object pnObj: TRbPanel
        Left = 8
        Top = 85
        Width = 543
        Height = 226
        MinSized = False
        ParentSchem = True
        Schem = 'Edit'
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
