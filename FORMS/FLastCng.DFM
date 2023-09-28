inherited LastCngLs: TLastCngLs
  Left = 305
  Width = 938
  Height = 717
  Caption = ''
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      inherited RbPanel3: TRbPanel
        inherited Browl1: TBrowl
          NmProc.Strings = ()
          OnBrowlKey = Browl1BrowlKey
        end
      end
      inherited RbPanel4: TRbPanel
        ParentSchem = False
        Schem = 'EdTxt'
        BevelOuter = bvNone
      end
    end
  end
  object de: TDefEdit
    DcmBased = False
    FrmBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FrmBorderStyle = bsSizeable
    Fields.Strings = (
      '#LastCngLs#Z#TMultiGet##2#0#1#T#F#T#F#F####0#0#F#F#F#F'
      
        #1042#1077#1088#1089#1080#1103'#LastCng#VERSCONF#TSpinGet###0#1#T#F#T#F#F###LastCngLs.Z#0' +
        '#0#F#F#F#F'
      
        #1057#1073#1086#1088#1082#1072'#LastCng#VERSEXE#TSpinGet###0#1#T#F#T#F#F###LastCngLs.Z#0#' +
        '0#F#F#F#F'
      
        #1044#1072#1090#1072'#LastCngLs#D#TDateGet##@WEEK#0#1#T#F#T#F#F###LastCngLs.Z#0#0' +
        '#F#F#F#F'
      '#LastCngLs#T####0#1#T#F#T#F#F###LastCngLs.Z#0#0#F#F#F#F'
      
        '#LastCng#MEM_TXT#TMemoGet##0,0,0,3,'#1058#1077#1082#1089#1090'#0#1#F#F#T#F#F####-1#-1#' +
        'F#F#F#F')
    HelpContext = 0
    NameWnd = 'LastCng'
    PnlAskByCancel = True
    PnlSortMode = smDefault
    OnFrmShow = deFrmShow
    OnPnlValid = dePnlValid
    Left = 112
  end
  object Rec: TRecVal
    NameRec = 'LastCngLs'
    Fields.Strings = (
      'Z=L'
      'D=D'
      'T=S5')
    Left = 48
    Top = 33
  end
end
