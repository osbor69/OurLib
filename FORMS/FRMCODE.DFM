inherited FormCode: TFormCode
  Caption = 'FormCode'
  PixelsPerInch = 120
  TextHeight = 17
  inherited RbPanel1: TRbPanel
    inherited PanelEdit1: TPanelEdit
      object ECode: TFldEdit
        Left = 104
        Top = 16
        Width = 86
        Height = 26
        MinSized = False
        ParentSchem = True
        Schem = 'Edit'
        CharCase = ecNormal
        CharWidth = 0
        CharHeight = 0
        MaxLength = 0
        Vid = 'TSimpleGet'
        OnCheck = ECodeCheck
        SayCaption = #1053#1086#1084#1077#1088
        SayRight = False
        TabOrder = 0
        TabStop = True
        OnExit = ECodeExit
      end
    end
  end
end
