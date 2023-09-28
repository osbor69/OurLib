inherited GFView: TGFView
  Caption = ''
  Menu = KeyMenu1
  PixelsPerInch = 120
  TextHeight = 17
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      BevelOuter = bvNone
      Place = rpLeft
      object Fdp1: TFdp
        Left = 24
        Top = 16
        Width = 185
        Height = 41
        MinSized = False
        ParentSchem = False
        Schem = 'ViewGF'
        CanSize = False
        CanMove = False
        MaxWidth = False
        ProcentWnd = 100
        SortMode = smDefault
        SortObj = True
        BevelOuter = bvNone
        HMin = 0
        Place = rpTop
        SayRight = False
        TabOrder = 0
        WMin = 0
        Options = []
        State = fdpView
      end
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 16
    Top = 9
  end
end
