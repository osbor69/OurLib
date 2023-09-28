inherited EdoOrdLs: TEdoOrdLs
  Caption = ' '
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      inherited Browl1: TBrowl
        OnShowHint = Browl1ShowHint
        OnMouseMove = Browl1MouseMove
      end
    end
  end
  object de: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      #1054#1088#1075#1072#1085#1080#1079#1072#1094#1080#1103'#EDOORD#ORGNO####0#1#T#F#T#F#F####0#0#F#F#F#F'
      #1050#1086#1084#1080#1089#1089#1080#1103'#EdoOrLs#C#TMultiGet##2#0#1#T#F#T#F#F####-2#0#F#F#F#F'
      
        '#EDOORD#NC#TSpinGet##1,2147483647,1,F#0#1#T#F#T#F#F###EdoOrLs.C#' +
        '0#0#F#F#F#F'
      '#EDOORD#NMC#TSimpleGet###0#1#T#F#T#F#F###EdoOrLs.C#-1#0#F#F#F#F'
      
        #8470' '#1087'/'#1087'#EDOORD#ORD#TSpinGet##1,2147483647,1,F#0#1#T#F#T#F#F####0#0' +
        '#F#F#F#F'
      
        #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100'#EDOORD#USERNAME#TCodeGet#Users##0#1#T#F#T#F#F####-2' +
        '#0#F#F#F#T'
      
        #1044#1077#1081#1089#1090#1074#1080#1077':#EDOORD#ACT#TRadioGet#Customize##0#1#T#F#T#F#F####0#0#F' +
        '#F#F#F'
      '#EDOORD#KE#TCodeGet#EdoExe##0#1#T#F#T#T#F####0#0#F#F#F#F')
    HelpContext = 0
    NameWnd = 'EdoOrd'
    PnlAskByCancel = False
    PnlSortMode = smColumns
    OnFldChange = deFldChange
    Left = 120
  end
  object Rec: TRecVal
    NameRec = 'EdoOrLs'
    Fields.Strings = (
      'C=L@H'#1050#1086#1084#1080#1089#1089#1080#1103'@')
    Left = 152
  end
end
