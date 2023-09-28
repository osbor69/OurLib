inherited SpList: TSpList
  ActiveControl = CtrlBrowl1
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = #1057#1087#1080#1089#1086#1082
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      NmProc.Strings = (
        'Esc#'#1054#1090#1084#1077#1085#1072'##FILE##'
        'F10#####Enter'
        'Enter#'#1042#1099#1073#1086#1088'##FILE##'
        'F4#'#1057#1082#1086#1087#1080#1088'.#'#1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100'#LIST##'
        'F5#'#1056#1077#1076#1072#1082#1090'.#'#1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100'#LIST##'
        'F7#'#1044#1086#1073#1072#1074#1080#1090#1100'##LIST##'
        'F8#'#1059#1076#1072#1083#1080#1090#1100'##LIST##')
    end
    inherited RbPanel2: TRbPanel
      ParentSchem = False
      Schem = 'Browl'
      object CtrlBrowl1: TCtrlBrowl
        Left = 128
        Top = 30
        Width = 204
        Height = 201
        AllowDelete = False
        AllowInsert = False
        DataSource = DataSource1
        PanelHeight = 67
        PanelWidth = 187
        TabOrder = 0
        SelectedColor = clHighlight
        OnStrFind = CtrlBrowl1StrFind
        object Panel1: TPanel
          Left = 8
          Top = 8
          Width = 173
          Height = 53
          BevelOuter = bvLowered
          Color = clWindow
          Enabled = False
          TabOrder = 0
          object DBText1: TDBText
            Left = 15
            Top = 8
            Width = 69
            Height = 38
            DataField = 'NAME'
            DataSource = DataSource1
          end
        end
      end
    end
  end
  object DataSource1: TDataSource
    Left = 56
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 88
  end
  object deSp: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      '#SpDB#NAME#TMemoGet###0#1#T##T######')
    HelpContext = 0
    NameWnd = 'SpEdit'
    PnlAskByCancel = False
    PnlSortMode = smColumns
    OnFrmShow = deSpFrmShow
    OnPnlValid = deSpPnlValid
    Left = 416
  end
end
