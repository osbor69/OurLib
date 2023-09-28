inherited FormEmp: TFormEmp
  Caption = 'FormEmp'
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited KeyLb1: TKeyLb
      NmProc.Strings = (
        'Esc#'#1042#1099#1093#1086#1076'##FILE##'
        'F10#####Esc')
      OnProcKey = KeyLb1ProcKey
    end
    object RbPanel2: TRbPanel
      Left = 15
      Top = 30
      Width = 571
      Height = 316
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
