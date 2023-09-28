inherited LogLs: TLogLs
  Caption = #1046#1091#1088#1085#1072#1083' '#1076#1077#1081#1089#1090#1074#1080#1081
  PixelsPerInch = 120
  TextHeight = 17
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      Place = rpTop
      inherited RbPanel3: TRbPanel
        ProcentWnd = 80
        inherited Browl1: TBrowl
          NmProc.Strings = (
            'Enter#'#1055#1086#1076#1088#1086#1073#1085#1086'##LIST##')
          OnBrowlKey = Browl1BrowlKey
          Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgRowSelect, dgAlwaysShowSelection]
        end
      end
      inherited RbPanel4: TRbPanel
        ParentSchem = False
        Schem = 'EdTxt'
        SortObj = False
        OnResize = RbPanel4Resize
      end
    end
  end
  object RFlt: TRecVal
    NameRec = 'LogLs'
    Fields.Strings = (
      'D=L'
      'DB=D'
      'DE=D'
      'FLT=L'
      'KEYS=L'
      'NKEYS=N'
      'SKEYS=M')
    Left = 112
  end
  object de: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    FrmCaption = #1046#1091#1088#1085#1072#1083' '#1076#1077#1081#1089#1090#1074#1080#1081
    Fields.Strings = (
      #1044#1072#1090#1072':#LogLs#D#TMultiGet##2#0#1#T#F#T#F#F####0#0#F#F#F#F'
      #1089'#LogLs#DB#TDateGet###0#1#T#F#T#F#F###LogLs.D#0#0#F#F#F#F'
      #1087#1086'#LogLs#DE#TDateGet##@END#0#1#T#F#T#F#F###LogLs.D#0#0#F#F#F#F'
      '#LogLs#FLT#TMultiGet##2#0#1#T#F#T#F#T####-1#0#F#F#F#F'
      '#LogLs#KEYS#TMultiGet##2#0#1#T#F#T#F#T####-1#-1#F#F#F#F'
      
        #1050#1083#1102#1095#1077#1074#1086#1077'~'#1087#1086#1083#1077':#LogLs#NKEYS#TRadioGet#Feed##0#1#T#F#T#F#T###LogLs' +
        '.KEYS#0#0#F#F#F#F'
      '#LogLs#SKEYS####0#1#T#F#T#T#F###LogLs.KEYS#-1#0#F#F#F#F')
    HelpContext = 0
    NameWnd = 'Log'
    PnlAskByCancel = False
    PnlSortMode = smDefault
    OnFldChange = deFldChange
    OnPnlCngKey = dePnlCngKey
    OnPnlValid = dePnlValid
    Left = 144
  end
end
