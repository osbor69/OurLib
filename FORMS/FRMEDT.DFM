inherited FormEdt: TFormEdt
  ActiveControl = PanelEdit1
  Caption = 'FormEdt'
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    object PanelEdit1: TPanelEdit
      Left = 15
      Top = 15
      Width = 579
      Height = 331
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
      Options = []
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 16
    Top = 8
  end
end
