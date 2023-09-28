unit StrProp;

interface

{$I LIBTEST}

uses DesignEditors,DesignIntf,Classes,SysUtils,DBTables,Variants,Controls,
  MyTypes,MulQry;

type
	TMulQueryPartProperty = class(TStringProperty)
	public
		function GetAttributes: TPropertyAttributes; override;
		procedure GetValues(Proc: TGetStrProc); override;
		class procedure GetParts(q: TMulQuery; Proc: TGetStrProc);
	end;

	TCodeGetPartProperty = class(TMulqueryPartProperty)
	public
		procedure GetValues(Proc: TGetStrProc); override;
	end;

	TFldEditNameRecProperty = class(TStringProperty)
  public
   	function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

	TFldEditNameRecFldProperty = class(TStringProperty)
  public
  	function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

	TFldEditVidProperty = class(TStringProperty)
  public
   	function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

	TFldEditVNameProperty = class(TStringProperty)
  public
   	function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

	TFldEditMaskProperty = class(TStringProperty)
  public
   	function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

  TVBMProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

	TCustomRbPanelSchemProperty = class(TStringProperty)
  public
   	function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

	TModelGetPrefixProperty = class(TStringProperty)
  public
    procedure SetValue(const Value: string); override;
  end;

	TKeyCodProperty = class(TIntegerProperty)
	public
		function GetAttributes: TPropertyAttributes; override;
		procedure GetValues(Proc: TGetStrProc); override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
	end;

  TDefEditDcmDefProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
		procedure Edit; override;
  end;

procedure Register;

implementation

uses My_pr,CodeGets,RecVal,FFldEdit,ChkGets,Schem,FPanel,ModelGet,
	StrBrowl,Browl,KeyMenu,DefEdit,FSchemDM,ListF2,BtTxtGet,FEdGenFr;

{ TMulqueryPartProperty }
function TMulqueryPartProperty.GetAttributes;
begin
	AddStack('TMulqueryPartProperty.GetAttributes');
	result:=[paValueList,paSortList,paMultiSelect];
  DelStack;
end;

procedure TMulqueryPartProperty.GetValues;
begin
	AddStack('TMulqueryPartProperty.GetValues');
	GetParts(TMulQuery(GetComponent(0)),Proc);
  DelStack;
end;

class procedure TMulqueryPartProperty.GetParts;
var pd: PDriverInfo;
	i: longint;
  s: string;
begin
	AddStack('TMulqueryPartProperty.GetParts');
	pd:=CreateDrvInfo(q.FGetDriverName);
  for i:=low(pd.aSQL) to high(pd.aSQL) do begin
		s:=StrDivDlm(' ',trim(pd.aSQL[i]))[1];
		if copy(s,1,1)=UnDelim then Proc(copy(s,2,MaxInt));
  end;
  ClearDrvInfo(pd);
  DelStack;
end;

{ TCodeGetPartProperty }
procedure TCodeGetPartProperty.GetValues;
begin
	AddStack('TCodeGetPartProperty.GetValues');
	GetParts(TMulQuery(TCodeGet(GetComponent(0)).Components[0]),Proc);
  DelStack;
end;

{ TFldEditNameRecProperty }
function TFldEditNameRecProperty.GetAttributes;
begin
	AddStack('TFldEditNameRecProperty.GetAttributes');
	result:=[paValueList,paSortList,paMultiSelect];
  DelStack;
end;

procedure TFldEditNameRecProperty.GetValues;
var i: longint;
begin
	AddStack('TFldEditNameRecProperty.GetValues');
	if Assigned(LsCustomRec) then
		for i:=0 to LsCustomRec.Count-1 do Proc(LsCustomRec[i]);
  DelStack;
end;

{ TFldEditNameRecFldProperty }
function TFldEditNameRecFldProperty.GetAttributes;
begin
	AddStack('TFldEditNameRecFldProperty.GetAttributes');
	result:=[paValueList,paSortList,paMultiSelect];
  DelStack;
end;

procedure TFldEditNameRecFldProperty.GetValues;
var i: longint;
	tf: TFldEdit;
begin
	AddStack('TFldEditNameRecFldProperty.GetValues');
	tf:=TFldEdit(GetComponent(0)); //tf.NmAssign;
  tf.SeekFld;
	if Assigned(tf.PNameRec) then begin
    tf.PNameRec.OpenRec;
    for i:=0 to tf.PNameRec.FieldCount-1 do Proc(tf.PNameRec.FieldName[i]);
    tf.PNameRec.CloseRec;
  end;
  DelStack;
end;

{ TFldEditVidProperty }
function TFldEditVidProperty.GetAttributes;
begin
	AddStack('TFldEditVidProperty.GetAttributes');
	result:=[paValueList,paSortList,paMultiSelect];
  DelStack;
end;

procedure TFldEditVidProperty.GetValues;
var i: longint;
	ls: TStringList;
begin
	AddStack('TFldEditVidProperty.GetValues');
	ls:=TStringList.Create;
  try
  	TCustomGet.GetListVid(ls);
    for i:=0 to ls.Count-1 do Proc(ls[i]);
  finally
    ls.Free;
  end;
  DelStack;
end;

{ TFldEditVNameProperty }
function TFldEditVNameProperty.GetAttributes;
begin
	AddStack('TFldEditVNameProperty.GetAttributes');
	result:=[paValueList,paSortList,paMultiSelect];
  DelStack;
end;

procedure TFldEditVNameProperty.GetValues;
var i: longint;
	ls: TStringList;
begin
	AddStack('TFldEditVNameProperty.GetValues');
	ls:=TStringList.Create;
  try
  	TCustomGet.GetListVName(ls,TFldEdit(GetComponent(0)).Vid);
    for i:=0 to ls.Count-1 do Proc(ls[i]);
  finally
    ls.Free;
  end;
  DelStack;
end;

{ TFldEditMaskProperty }
function TFldEditMaskProperty.GetAttributes;
begin
	AddStack('TFldEditMaskProperty.GetAttributes');
  result:=[paDialog]; TFldEdit(GetComponent(0)).DsgnNameGet;
  DelStack;
end;

procedure TFldEditMaskProperty.Edit;
var tf: TFldEdit;
  s: string;
begin
	AddStack('TFldEditMaskProperty.Edit');
	tf:=TFldEdit(GetComponent(0)); tf.DsgnNameGet;
	if Assigned(tf.curget) then begin
    s:=Value;
    if tf.curget.MaskProp(tf.Owner.Name+'.'+tf.Name+'.'+GetName,s,RecName(tf.NameRec),tf.NameRecFld)
    then SetStrValue(s);
  end;
  DelStack;
end;

{ TVBMProperty }
function TVBMProperty.GetAttributes;
begin
	AddStack('TVBMProperty.GetAttributes');
  Result:=[paValueList,paSortList,paMultiSelect];
  DelStack;
end;

procedure TVBMProperty.GetValues;
var i: longint;
begin
	AddStack('TVBMProperty.GetValues');
	for i:=VarArrayLowBound(VBMName,1) to VarArrayHighBound(VBMName,1) do	Proc(VBMName[i]);
  DelStack;
end;

{ TCustomRbPanelSchemProperty }
function TCustomRbPanelSchemProperty.GetAttributes;
begin
	AddStack('TCustomRbPanelSchemProperty.GetAttributes');
	result:=[paValueList,paSortList,paMultiSelect];
  DelStack;
end;

procedure TCustomRbPanelSchemProperty.GetValues;
var i: longint;
begin
	AddStack('TCustomRbPanelSchemProperty.GetValues');
	if Assigned(LsSchem) then
		for i:=0 to LsSchem.Count-1 do Proc(LsSchem[i]);
  DelStack;
end;

{ TModelGetPrefixProperty }
procedure TModelGetPrefixProperty.SetValue;
var i: longint;
label lend;
begin
	AddStack('TModelGetPrefixProperty.SetValue');
	for i:=1 to Length(Value) do
    if not(Value[i] in ['0'..'9','A'..'Z','_','a'..'z']) then begin
    	MsgDlg('Некорректный символ: "'+Value[i]+'"'); Revert; goto lend;
    end;
  inherited SetValue(Value);
lend:
	DelStack;
end;

{ TKeyCodProperty }
function TKeyCodProperty.GetAttributes;
begin
	AddStack('TKeyCodProperty.GetAttributes');
	result:=[paValueList,paMultiSelect];
  DelStack;
end;

procedure TKeyCodProperty.GetValues;
var i: longint;
begin
	AddStack('TKeyCodProperty.GetValues');
  for i:=1 to KEY_USER do Proc(KeyToTxt(i));
  DelStack;
end;

function TKeyCodProperty.GetValue;
begin
	AddStack('TKeyCodProperty.GetValue');
  result:=KeyToTxt(Int0(inherited GetValue));
  DelStack;
end;

procedure TKeyCodProperty.SetValue;
begin
	AddStack('TKeyCodProperty.SetValue');
  inherited SetValue(IntToStr(TxtToKey(Value)));
  DelStack;
end;

{ TDefEditDcmDefProperty }
function TDefEditDcmDefProperty.GetAttributes;
begin
	AddStack('TDefEditDcmDefProperty.GetAttributes');
  result:=inherited GetAttributes+[paDialog,paReadOnly]-[paMultiSelect];
  DelStack;
end;

function TDefEditDcmDefProperty.GetValue;
begin
  result:='(редактирование формы)';
end;

procedure TDefEditDcmDefProperty.Edit;
var s: string;
begin
	AddStack('TDefEditDcmDefProperty.Edit');
  if TDefEdit(GetComponent(0)).DcmBased then begin
  	s:=inherited GetValue; CreateForm(TSchemDM,SchemDM);
    with TDefEdit(GetComponent(0)) do
    	if TEdGenFr.EdFormEd(@s,PrFldList,PrEdSay,[defrmCrt]) then SetStrValue(s);
  end;
  DelStack;
end;

procedure Register;
begin
	RegisterPropertyEditor(TypeInfo(string),TMulquery,'Part',TMulqueryPartProperty);
	RegisterPropertyEditor(TypeInfo(string),TCodeGet,'Part',TCodeGetPartProperty);
  RegisterPropertyEditor(TypeInfo(string),TFldEdit,'NameRec',TFldEditNameRecProperty);
  RegisterPropertyEditor(TypeInfo(string),TFldEdit,'NameRecFld',TFldEditNameRecFldProperty);
  RegisterPropertyEditor(TypeInfo(string),TFldEdit,'Vid',TFldEditVidProperty);
  RegisterPropertyEditor(TypeInfo(string),TFldEdit,'VName',TFldEditVNameProperty);
  RegisterPropertyEditor(TypeInfo(string),TFldEdit,'Mask',TFldEditMaskProperty);
  RegisterPropertyEditor(TypeInfo(string),TBoolDrwGet,'PictTrue',TVBMProperty);
  RegisterPropertyEditor(TypeInfo(string),TBoolDrwGet,'PictFalse',TVBMProperty);
  RegisterPropertyEditor(TypeInfo(string),TButTextGet,'Picture',TVBMProperty);
  RegisterPropertyEditor(TypeInfo(string),TCustomRbPanel,'Schem',TCustomRbPanelSchemProperty);
  RegisterPropertyEditor(TypeInfo(TModelFile),TModelGet,'Prefix',TModelGetPrefixProperty);
  RegisterPropertyEditor(TypeInfo(longint),TCustomStringBrowl,'KeyDblClick',TKeyCodProperty);
  RegisterPropertyEditor(TypeInfo(longint),TBrowl,'KeyDblClick',TKeyCodProperty);
	RegisterPropertyEditor(TypeInfo(string),TDefEdit,'DcmDef',TDefEditDcmDefProperty);
end;

end.
