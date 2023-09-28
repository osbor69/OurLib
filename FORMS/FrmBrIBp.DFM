inherited FormBrIBPnl: TFormBrIBPnl
  Caption = 'FormBrIBPnl'
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      BevelOuter = bvNone
      Place = rpLeft
      object RbPanel3: TRbPanel
        Left = 0
        Top = 7
        Width = 290
        Height = 234
        MinSized = False
        ParentSchem = False
        Schem = 'Browl'
        CanSize = False
        CanMove = False
        MaxWidth = False
        ProcentWnd = 50
        SortMode = smDefault
        SortObj = True
        BevelOuter = bvLowered
        HMin = 0
        Place = rpNone
        SayRight = False
        TabOrder = 0
        WMin = 0
        object Browl1: TBrowl
          Left = 4
          Top = 24
          Width = 300
          Height = 112
          CloseOnSelect = False
          KeyDblClick = 13
          NmProc.Strings = (
            'F4#'#1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100'##LIST##'
            'F5#'#1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100'##LIST##'
            'F7#'#1044#1086#1073#1072#1074#1080#1090#1100'##LIST##'
            'F8#'#1059#1076#1072#1083#1080#1090#1100'##LIST##'
            'Enter#####F5')
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
      object RbPanel4: TRbPanel
        Left = 296
        Top = 7
        Width = 171
        Height = 234
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
  object DataSource1: TDataSource
    Left = 48
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 80
  end
end
