inherited FormSel: TFormSel
  Caption = 'FormSel'
  PixelsPerInch = 96
  TextHeight = 15
  inherited RbPanel1: TRbPanel
    inherited RbPanel2: TRbPanel
      inherited Browl1: TBrowl
        OnDrawColumnCell = Browl1DrawColumnCell
      end
    end
  end
end
