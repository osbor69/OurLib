unit CompProp;

interface

{$I LIBTEST}
uses DesignEditors,DesignIntf,Classes,Controls,Dialogs,Forms;

type
	TFldEditFocusControlProperty = class(TComponentProperty)
  public
    procedure GetValues(Proc: TGetStrProc); override;
  end;

	TCustomGetSelCodeGetProperty = class(TComponentProperty)
  public
    procedure GetValues(Proc: TGetStrProc); override;
  end;

procedure Register;

implementation

uses TypInfo,
  MyTypes,My_pr,FPanel,FFldEdit,CodeGets;

{ TFldEditFocusControlProperty }
procedure TFldEditFocusControlProperty.GetValues;
var i: longint;
	tc: TControl;
	tw: TWinControl;
begin
	AddStack('TFldEditFocusControlProperty.GetValues');
	tc:=TControl(GetComponent(0)); tw:=tc.Parent;
  if Assigned(tw) then with tw do
		for i:=0 to ControlCount-1 do
    	if (Controls[i] is TFldEdit) and (Controls[i]<>tc) then Proc(Controls[i].Name);
  DelStack;
end;

{ TCustomGetSelCodeGetProperty }
procedure TCustomGetSelCodeGetProperty.GetValues;
begin
	AddStack('TCustomGetSelCodeGetProperty.GetValues');
  Designer.GetComponentNames(GetTypeData(TypeInfo(TCodeGet)),Proc);
  DelStack;
end;

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(TWinControl),TFldEdit,'FocusControl',TFldEditFocusControlProperty);
  RegisterPropertyEditor(TypeInfo(TCustomGet),TCustomGet,'SelCodeGet',TCustomGetSelCodeGetProperty);
end;

end.
