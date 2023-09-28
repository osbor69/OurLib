inherited GFBmp: TGFBmp
  Caption = ' '
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      BevelOuter = bvNone
      Place = rpLeft
      object pnLs: TRbPanel
        Left = 21
        Top = 28
        Width = 269
        Height = 262
        MinSized = False
        ParentSchem = True
        Schem = 'Edit'
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
        object sb: TStringBrowl
          Left = 14
          Top = 28
          Width = 241
          Height = 106
          ColCount = 1
          FixedCols = 0
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSizing, goColSizing, goRowSelect]
          TabOrder = 0
          OnDrawCell = sbDrawCell
          OnKeyUp = sbKeyUp
          OnMouseUp = sbMouseUp
          KeyDblClick = 13
          TitleFont.Charset = RUSSIAN_CHARSET
          TitleFont.Color = clBlack
          TitleFont.Height = -15
          TitleFont.Name = 'Courier New'
          TitleFont.Style = []
          SelectedOnlyFocused = False
          OnCalcZn = sbCalcZn
          ColWidths = (
            31)
          RowHeights = (
            21
            24
            24
            24
            24)
        end
      end
      object pnSamp: TRbPanel
        Left = 304
        Top = 28
        Width = 262
        Height = 262
        MinSized = False
        ParentSchem = True
        Schem = 'Edit'
        CanSize = False
        CanMove = False
        MaxWidth = False
        Header = #1054#1073#1088#1072#1079#1077#1094
        ProcentWnd = 100
        SortMode = smDefault
        SortObj = True
        OnAfterPaint = pnSampAfterPaint
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
    Left = 24
    Top = 8
  end
  object Rec: TRecVal
    NameRec = 'GFBmp'
    Fields.Strings = (
      'COD=S15'
      'NAME=M'
      'BMP=M')
    Left = 56
    Top = 8
  end
  object de: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      #1050#1086#1076'#GFBmp#COD#TSimpleGet###0#1#T#F#T#F#F####0#0#F#F#F#T'
      
        #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077'#GFBmp#NAME#TSimpleGet###0#1#T#F#T#F#F####-1#0#F#F#F' +
        '#T'
      
        '#GFBmp#BMP#TButGet#GFBmp#@H'#1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1088#1080#1089#1091#1085#1086#1082' '#1080#1079' '#1092#1072#1081#1083#1072'@#0#1#T#F#T' +
        '#F#F####-1#-1#F#F')
    HelpContext = 0
    NameWnd = 'GFBmp'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFldCheck = deFldCheck
    Left = 88
    Top = 8
  end
  object BmpGet: TButGet
    VName = 'GFBmp'
    OnClick = BmpGetClick
    OnPaint = BmpGetPaint
    Left = 120
    Top = 8
  end
  object dlgBmp: TOpenDialog
    DefaultExt = 'BMP'
    Filter = #1056#1080#1089#1091#1085#1082#1080' (*.bmp)|*.bmp|'#1042#1089#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
    Options = [ofHideReadOnly, ofShowHelp, ofPathMustExist, ofFileMustExist]
    Title = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1088#1080#1089#1091#1085#1086#1082' '#1080#1079' '#1092#1072#1081#1083#1072
    Left = 152
    Top = 8
  end
end
