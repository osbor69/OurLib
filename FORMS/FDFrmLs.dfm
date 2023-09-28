inherited DFrmLs: TDFrmLs
  Left = 390
  Caption = ''
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      inherited Browl1: TBrowl
        OnGrayCell = Browl1GrayCell
        OnDrawColumnCell = Browl1DrawColumnCell
      end
    end
  end
end
