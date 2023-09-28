inherited FormBrIB: TFormBrIB
  ActiveControl = Browl1
  Caption = 'FormBrIB'
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      ParentSchem = False
      Schem = 'Browl'
      SortObj = False
      object Browl1: TBrowl
        Left = 23
        Top = 38
        Width = 300
        Height = 112
        CloseOnSelect = False
        KeyDblClick = 13
        DataSource = DataSource1
        Options = [dgTitles, dgColLines, dgRowLines, dgRowSelect, dgAlwaysShowSelection]
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Courier New'
        TitleFont.Style = []
      end
    end
  end
  object DataSource1: TDataSource
    Left = 48
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 80
  end
end
