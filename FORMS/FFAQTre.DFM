inherited FAQTre: TFAQTre
  Left = 295
  Top = 160
  Width = 900
  Height = 739
  Caption = #1042#1086#1087#1088#1086#1089#1099'-'#1086#1090#1074#1077#1090#1099
  Menu = KeyMenu1
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    Width = 763
    Height = 613
    inherited KeyLb1: TKeyLb
      Top = 560
    end
    inherited RbPanel2: TRbPanel
      Width = 727
      Height = 513
      ParentSchem = False
      Schem = 'Tree'
      Place = rpTop
      object Tree: TTreePrim
        Left = 176
        Top = 56
        Width = 107
        Height = 86
        BorderStyle = bsNone
        Indent = 19
        ReadOnly = True
        TabOrder = 0
        FontPrim.Charset = DEFAULT_CHARSET
        FontPrim.Color = clWindowText
        FontPrim.Height = -13
        FontPrim.Name = 'MS Sans Serif'
        FontPrim.Style = []
        SeekLength = 0
        Options = [tpNoDopDispose]
      end
    end
  end
  object KeyMenu1: TKeyMenu
    AutoHotkeys = maManual
    OwnerDraw = True
    Left = 8
    Top = 8
  end
  object de: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      #1042#1086#1087#1088#1086#1089'#Main#Z1#TMultiGet###0#1#T#F#T#F#F####-1#0#F#F#F#F'
      
        '#FAQ#MEM_ANSW#TMemoGet##0,0,0,3,'#1054#1090#1074#1077#1090'#0#1#F#F#T#F#F####-1#-1#F#F' +
        '#F#F')
    HelpContext = 0
    NameWnd = 'FAQ'
    PnlAskByCancel = True
    PnlSortMode = smDefault
    OnFldCheck = deFldCheck
    OnFldChange = deFldChange
    Left = 48
    Top = 9
  end
  object Rec: TRecVal
    NameRec = 'FAQTre'
    Left = 120
    Top = 8
  end
end
