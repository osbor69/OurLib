object IBTree: TIBTree
  Left = 287
  Top = 117
  Width = 783
  Height = 540
  ActiveControl = tv
  Caption = #1050#1083#1072#1089#1089#1099' OURLIB'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 120
  TextHeight = 16
  object tb: TToolBar
    Left = 0
    Top = 465
    Width = 765
    Height = 28
    Align = alBottom
    AutoSize = True
    ButtonHeight = 24
    ButtonWidth = 124
    Caption = 'tb'
    ShowCaptions = True
    TabOrder = 1
    object bLoad: TToolButton
      Left = 0
      Top = 2
      Hint = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1092#1072#1081#1083' '#1074' '#1088#1077#1076#1072#1082#1090#1086#1088
      AutoSize = True
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' <Enter>'
      ImageIndex = 0
      ParentShowHint = False
      ShowHint = True
      Style = tbsCheck
      OnClick = mLoadClick
    end
    object bRefresh: TToolButton
      Left = 128
      Top = 2
      AutoSize = True
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100' <F5>'
      ImageIndex = 0
      OnClick = tvEnter
    end
    object bFind: TToolButton
      Left = 235
      Top = 2
      AutoSize = True
      Caption = #1055#1086#1080#1089#1082' <F6>'
      ImageIndex = 0
      OnClick = mFindClick
    end
    object bClose: TToolButton
      Left = 318
      Top = 2
      AutoSize = True
      Caption = #1042#1099#1093#1086#1076' <Esc>'
      OnClick = mCloseClick
    end
  end
  object Stat: TStatusBar
    Left = 0
    Top = 446
    Width = 765
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 50
      end
      item
        Width = 50
      end>
  end
  object tv: TTreeView
    Left = 0
    Top = 39
    Width = 765
    Height = 407
    Align = alClient
    HideSelection = False
    Indent = 22
    ReadOnly = True
    TabOrder = 0
    OnChange = tvChange
    OnDblClick = tvDblClick
    OnEnter = tvEnter
  end
  object gbPath: TGroupBox
    Left = 0
    Top = 0
    Width = 765
    Height = 39
    Align = alTop
    Caption = #1054#1073#1083#1072#1089#1090#1100' '#1087#1086#1080#1089#1082#1072
    TabOrder = 3
    OnEnter = gbPathEnter
    OnExit = gbExit
    object rbProject: TRadioButton
      Tag = 1
      Left = 8
      Top = 16
      Width = 73
      Height = 17
      Caption = #1055#1088#1086#1077#1082#1090
      TabOrder = 0
    end
    object rbOurlib: TRadioButton
      Left = 88
      Top = 16
      Width = 65
      Height = 17
      Caption = 'Ourlib'
      TabOrder = 1
    end
    object rbDelphi: TRadioButton
      Left = 160
      Top = 16
      Width = 65
      Height = 17
      Caption = 'Delphi'
      TabOrder = 2
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 416
    Top = 16
    object mLoad: TMenuItem
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1092#1072#1081#1083' '#1074' '#1088#1077#1076#1072#1082#1090#1086#1088
      ShortCut = 13
      OnClick = mLoadClick
    end
    object mRefresh: TMenuItem
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      ShortCut = 116
      OnClick = tvEnter
    end
    object mFind: TMenuItem
      Caption = #1055#1086#1080#1089#1082' '#1082#1083#1072#1089#1089#1072
      ShortCut = 117
      OnClick = mFindClick
    end
    object mObj: TMenuItem
      Caption = #1055#1086#1080#1089#1082' '#1076#1083#1103' '#1079#1072#1084#1077#1085#1099' "TObject(" -> "pointer("'
      ShortCut = 16501
      OnClick = mObjClick
    end
    object mUses: TMenuItem
      Caption = #1055#1086#1080#1089#1082' '#1087#1077#1088#1077#1082#1088#1077#1089#1090#1085#1099#1093' '#1089#1089#1099#1083#1086#1082' '#1085#1072' '#1084#1086#1076#1091#1083#1080
      ShortCut = 16469
      OnClick = mUsesClick
    end
    object mClose: TMenuItem
      Caption = #1042#1099#1093#1086#1076
      ShortCut = 27
      OnClick = mCloseClick
    end
  end
  object fd: TFindDialog
    Options = [frDown, frHideMatchCase, frHideUpDown]
    OnFind = fdFind
    Left = 448
    Top = 16
  end
end
