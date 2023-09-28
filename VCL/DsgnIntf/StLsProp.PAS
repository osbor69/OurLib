unit StLsProp;

interface

{$I LIBTEST}
uses
  DesignEditors,DesignIntf,SysUtils,Classes,Forms,Graphics,
  	ExtCtrls,DbTables,Variants,Controls,Math,DB,StrUtils,
  MyTypes,My_pr,DlgStLs,ArrGet;

type
	TMulQueryMulParProperty = class(TDlgStLsProperty)
  protected
    function TransStr(const st: string; lGet: boolean): string; override;
    function EdCheck(Sender: TObject): boolean; override;
		function DefValue(Index: longint): string; override;
  public
  	procedure Activate; override;
  end;

	TMenuGetItemsProperty = class(TDlgStLsProperty)
  protected
		function NameFromArr(const a: array of string): string; override;
		function DefValue(Index: longint): string; override;
  public
  	procedure Activate; override;
  end;

	TRadioGetItemsProperty = class(TDlgStLsProperty)
  private
  	iBM: TInitBM;
  	procedure PbPaint(Sender: TObject);
  protected
    procedure EdChange(Sender: TObject; const OldVal: variant; FromShow: boolean); override;
    procedure RowMove(Sender: TObject; Index: longint); override;
  public
  	procedure Activate; override;
    procedure Edit; override;
  end;

	TSpdButGetButtonsProperty = class(TDlgStLsProperty)
  private
  	iBM: TInitBM;
  	procedure PbPaint(Sender: TObject);
  protected
    function TransStr(const st: string; lGet: boolean): string; override;
    procedure EdChange(Sender: TObject; const OldVal: variant; FromShow: boolean); override;
    procedure EdExit(Sender: TObject); override;
    procedure RowMove(Sender: TObject; Index: longint); override;
  public
  	procedure Activate; override;
    procedure Edit; override;
  end;

	TRecValFieldsProperty = class(TDlgStLsProperty)
  protected
    function TransStr(const st: string; lGet: boolean): string; override;
		procedure EdChange(Sender: TObject; const OldVal: variant; FromShow: boolean); override;
    procedure EdExit(Sender: TObject); override;
		function EdCheck(Sender: TObject): boolean; override;
		function DefValue(Index: longint): string; override;
  public
  	procedure Activate; override;
  end;

	TRecDBDefFldDefProperty = class(TDlgStLsProperty)
  private
    lAvailable,lNeed: longint;
    DefMemGet: TComponent;
  protected
    function TransStr(const st: string; lGet: boolean): string; override;
		procedure EdChange(Sender: TObject; const OldVal: variant; FromShow: boolean); override;
    procedure EdExit(Sender: TObject); override;
		function EdCheck(Sender: TObject): boolean; override;
    function Valid(Sender: TObject): boolean; override;
		function NameFromArr(const a: array of string): string; override;
		function DefValue(Index: longint): string; override;
		procedure StatusChange(Sender: TObject; Mode: TDlgStLsStatMode); override;
  public
  	procedure Activate; override;
  end;

	TStringBrowlColZnProperty = class(TDlgStLsProperty)
  protected
    function TransStr(const st: string; lGet: boolean): string; override;
		function DefValue(Index: longint): string; override;
  	function ListOwner(Sender: TObject): boolean; override;
  public
  	procedure Activate; override;
		procedure Edit; override;
  end;

	TDefEditFieldsProperty = class(TDlgStLsProperty)
  private
    function SeekArrGet(var g: TArrGet; WithData: boolean = true): boolean;
  protected
		function TransArr(const st: string; Index: longint; lGet: boolean): string; override;
    procedure FormShow(Sender: TObject); override;
    //procedure EdChange(Sender: TObject; const OldVal: variant; FromShow: boolean); override;
		function NameFromArr(const a: array of string): string; override;
		function DefValue(Index: longint): string; override;
  	function ListOwner(Sender: TObject): boolean; override;
		procedure ButTextGetClick(Sender: TObject); override;
    procedure PnEdEnter(Sender: TObject); override;
  public
  	procedure Activate; override;
    procedure Edit; override;
  end;

	TDefEditPagesProperty = class(TDlgStLsProperty)
  protected
    function TransStr(const st: string; lGet: boolean): string; override;
    procedure FormShow(Sender: TObject); override;
    procedure EdChange(Sender: TObject; const OldVal: variant; FromShow: boolean); override;
  	function ButGetClick(Sender: TObject; lEval: boolean): string; override;
		procedure StatusChange(Sender: TObject; Mode: TDlgStLsStatMode); override;
  public
  	procedure Activate; override;
  end;

	TRbMenuKeysProperty = class(TDlgStLsProperty)
  private
  	iBM: TInitBM;
  	procedure PbPaint(Sender: TObject);
  protected
    function TransStr(const st: string; lGet: boolean): string; override;
		function NameFromArr(const a: array of string): string; override;
    procedure EdChange(Sender: TObject; const OldVal: variant; FromShow: boolean); override;
    procedure RowMove(Sender: TObject; Index: longint); override;
		function DefValue(Index: longint): string; override;
    procedure BeforeRead(Index: longint); override;
  public
  	procedure Activate; override;
    procedure Edit; override;
  end;

	TKeyLbNmProcProperty = class(TDlgStLsProperty)
  protected
    function TransStr(const st: string; lGet: boolean): string; override;
		function NameFromArr(const a: array of string): string; override;
		function DefValue(Index: longint): string; override;
    procedure BeforeRead(Index: longint); override;
  public
  	procedure Activate; override;
  end;

procedure Register;

implementation

uses StdCtrls,
  MulQry,MenuGet,ChkGets,SpdBtGet,FFldEdit,RecVal,RecDB,ComboGet,PnlEdit,FPanel,
	StrBrowl,DefEdit,ButGet,KeyMenu,KeyLb,RBMenu,FSchemDM,PSort,FEdGenFr,Shifr;

{ TMulQueryMulParProperty }
procedure TMulQueryMulParProperty.Activate;
begin
	AddStack('TMulQueryMulParProperty.Activate');
	inherited Activate;
	vEd:=ArrVarToVar(
    [VarArrayOf([teEdit,'Параметр'])
    ,VarArrayOf([teEdit,'Значение'])
    ]);
  HeadList:='Параметры'; HeadEd:='Значения';
  DelStack;
end;

function TMulQueryMulParProperty.TransStr;
var a: TNamePrimStr;
begin
	AddStack('TMulQueryMulParProperty.TransStr');
	if lGet then
    if StrDivDlm('=',st,a) then result:=Trim(a[1])+UnDelim+a[2] else result:=''
  else begin
    LsArrFill(st,a,UnDelim); result:=Trim(a[1])+'='+a[2];
  end;
  DelStack;
end;

function TMulQueryMulParProperty.EdCheck;
begin
	AddStack('TMulQueryMulParProperty.EdCheck');
	if Sender=FindEdit(1) then result := not empty(Val[1]) else result:=true;
  DelStack;
end;

function TMulQueryMulParProperty.DefValue;
begin
	AddStack('TMulQueryMulParProperty.DefValue');
	if Index=1 then result:=NextName(1,'Prm') else result:='';
  DelStack;
end;

{ TMenuGetItemsProperty }
procedure TMenuGetItemsProperty.Activate;
begin
	AddStack('TMenuGetItemsProperty.Activate');
	inherited Activate;
	vEd:=ArrVarToVar(
    [VarArrayOf([teEdit,'Код'])
    ,VarArrayOf([teEdit,'Наименование'])
    ]);
  HeadList:='Наименование (код)';
  DelStack;
end;

function TMenuGetItemsProperty.NameFromArr;
var l: longint;
begin
	AddStack('TMenuGetItemsProperty.NameFromArr');
	l:=low(a); result:=Trim(a[l+1])+BrackNoEmp(a[l]);
  DelStack;
end;

function TMenuGetItemsProperty.DefValue;
begin
	AddStack('TMenuGetItemsProperty.DefValue');
	if Index=1 then result:=NextCod(1) else result:='';
  DelStack;
end;

{ TRadioGetItemsProperty }
procedure TRadioGetItemsProperty.Activate;
begin
	AddStack('TRadioGetItemsProperty.Activate');
	inherited Activate;
	vEd:=ArrVarToVar(
    [VarArrayOf([teEdit,'Наименование'])
    ,AddFrom(VarArrayOf([teCombo,'Картинка',false]),VSubArr(VBMName,2))
    ]);
	HeadList:='Наименование'; ProcPaint:=PbPaint;
  DelStack;
end;

procedure TRadioGetItemsProperty.Edit;
begin
	AddStack('TRadioGetItemsProperty.Edit');
	iBM:=TInitBM.Create(Application.MainForm);
  try
  	inherited Edit;
  finally
    iBM.Free;
  end;
  DelStack;
end;

procedure TRadioGetItemsProperty.EdChange;
begin
	AddStack('TRadioGetItemsProperty.EdChange');
	if Sender=FindEdit(2) then
  	if Assigned(Pb) then Pb.Invalidate;
  DelStack;
end;

procedure TRadioGetItemsProperty.RowMove;
var i: longint;
begin
	AddStack('TRadioGetItemsProperty.RowMove');
	if TComponent(Sender).Owner=Findedit(2) then
    if iBM.LsBM.Find(TrimUpper(VBMName[Index+2]),i) then Val[2]:=iBM.LsBM[i] else Val[2]:='';
  DelStack;
end;

procedure TRadioGetItemsProperty.PbPaint;
var l,t,w,h: longint;
  bm: TBitMap;
begin
	AddStack('TRadioGetItemsProperty.PbPaint');
	with TPaintBox(Sender) do begin
  	Canvas.Brush.Color:=Color;
  	Canvas.FillRect(Rect(0,0,Width-1,Height-1));
    if PointerObjFind(iBM.LsBM,TrimUpper(Val[2]),pointer(bm)) then begin
      w:=bm.Width; h:=bm.Height; l := (Width-w) div 2; t := (Height-h) div 2;
      Canvas.Brush.Color:=clWhite;
      Canvas.BrushCopy(Rect(l,t,l+w,t+h),bm,Rect(0,0,w,h),bm.Canvas.Pixels[0,h-1]);
    end;
  end;
  DelStack;
end;

{ TSpdButGetButtonsProperty }
procedure TSpdButGetButtonsProperty.Activate;
begin
	AddStack('TSpdButGetButtonsProperty.Activate');
	inherited Activate;
	vEd:=ArrVarToVar(
    [AddFrom(VarArrayOf([teCombo,'Картинка',false]),VSubArr(VBMName,2))
    ,VarArrayOf([teEdit,'Подсказка'])
    ,VarArrayOf([teSpin,'Группа кнопок',0,MaxInt])
    ,VarArrayOf([teBool,'Выключать повторным нажатием'])
    ]);
  HeadList:='Кнопки'; ProcPaint:=PbPaint;
  DelStack;
end;

procedure TSpdButGetButtonsProperty.Edit;
begin
	AddStack('TSpdButGetButtonsProperty.Edit');
	iBM:=TInitBM.Create(Application.MainForm);
  try
  	inherited Edit;
  finally
    iBM.Free;
  end;
  DelStack;
end;

function TSpdButGetButtonsProperty.TransStr;
var n: longint;
	a: array[1..4] of string;
begin
	AddStack('TSpdButGetButtonsProperty.TransStr');
	if lGet then result := inherited TransStr(st,lGet)
  else begin
		LsArrFill(st,a,UnDelim); n:=Int0(a[3]);
    result:=Trim(a[1])+UnDelim+Trim(a[2])
    	+IfThen(n<>0,StrNum(UnDelim,n)+IfThen(StrToBoolean(a[4]),UnDelim+Trim(a[4])));
  end;
  DelStack;
end;

procedure TSpdButGetButtonsProperty.EdChange;
begin
	AddStack('TSpdButGetButtonsProperty.EdChange');
	if Sender=FindEdit(1) then begin
  	if Assigned(Pb) then Pb.Invalidate;
  end
  else if Sender=FindEdit(3)
	  then TFldEdit(FindEdit(4)).SetReadOnly(Int0(Val[3])<=0);
  DelStack;
end;

procedure TSpdButGetButtonsProperty.EdExit;
begin
	AddStack('TSpdButGetButtonsProperty.EdExit');
  if Sender=FindEdit(3) then
	  if Int0(Val[3])=0 then Val[4]:='';
  DelStack;
end;

procedure TSpdButGetButtonsProperty.RowMove;
var i: longint;
begin
	AddStack('TSpdButGetButtonsProperty.RowMove');
	if TComponent(Sender).Owner=Findedit(1) then
    if iBM.LsBM.Find(TrimUpper(VBMName[Index+2]),i) then Val[1]:=iBM.LsBM[i] else Val[1]:='';
  DelStack;
end;

procedure TSpdButGetButtonsProperty.PbPaint;
var l,t,w,h: longint;
  bm: TBitMap;
begin
	AddStack('TSpdButGetButtonsProperty.PbPaint');
	with TPaintBox(Sender) do begin
  	Canvas.Brush.Color:=Color;
  	Canvas.FillRect(Rect(0,0,Width-1,Height-1));
    if PointerObjFind(iBM.LsBM,TrimUpper(Val[1]),pointer(bm)) then begin
      w:=bm.Width; h:=bm.Height; l := (Width-w) div 2; t := (Height-h) div 2;
      Canvas.Brush.Color:=clWhite;
      Canvas.BrushCopy(Rect(l,t,l+w,t+h),bm,Rect(0,0,w,h),bm.Canvas.Pixels[0,h-1]);
    end;
  end;
  DelStack;
end;

{ TRecValFieldsProperty }
procedure TRecValFieldsProperty.Activate;
begin
	AddStack('TRecValFieldsProperty.Activate');
	inherited Activate;
	vEd:=ArrVarToVar(
    [VarArrayOf([teEdit,'Наименование'])
    ,VarArrayOf([teMenu,'Тип','строка','целое','дробное','дата','логическое','текст'])
    ,VarArrayOf([teSpin,'Длина',0,MaxInt])
    ,VarArrayOf([teEdit,'Значение по умолчанию'])
    ,VarArrayOf([teEdit,'Примечание'])
    ]);
  DelStack;
end;

function TRecValFieldsProperty.TransStr;
var a: array[1..5] of string;
  s,prim: string;
  al: TNamePrimStr;
begin
	AddStack('TRecValFieldsProperty.TransStr');
	if lGet then
    if StrDivDlm('=',StrToAtPart(st,prim,cButCapt),al) then begin
      result:=Trim(al[1])+UnDelim; LsArrFill(al[2],a,UnDelim); TrimSelf(a[1]); s:=Copy(a[1],2,MaxInt);
      case UpCase(StrToChar(a[1])) of
        'B','L': a[1]:='5';
        'D': a[1]:='4';
        'F': a[1]:='3';
        'I','N': a[1]:='2';
        'M': a[1]:='6';
      else a[1]:='1';
      end;
      IncD(result,a[1]+UnDelim+s+UnDelim+a[2]+UnDelim+prim);
    end
    else result:=''
  else begin
    LsArrFill(st,a,UnDelim);
    result:=a[1]+'='+IfThen(a[2]='2','N',IfThen(a[2]='3','F',
    	IfThen(a[2]='4','D',IfThen(a[2]='5','L',IfThen(a[2]='6','M','S')))))
      +IfThen(Int0(a[3])<>0,a[3])+IfThen(a[4]<>'',UnDelim+a[4])+AtPartToStr(a[5],cButCapt);
  end;
  DelStack;
end;

procedure TRecValFieldsProperty.EdChange;
begin
	AddStack('TRecValFieldsProperty.EdChange');
  if Sender=FindEdit(2) then TFldEdit(FindEdit(3)).SetReadOnly(Trim(Val[2])<>'1');
  DelStack;
end;

procedure TRecValFieldsProperty.EdExit;
begin
	AddStack('TRecValFieldsProperty.EdExit');
  if Sender=FindEdit(2) then
	  if Trim(Val[2])<>'1' then Val[3]:='';
  DelStack;
end;

function TRecValFieldsProperty.EdCheck;
begin
	AddStack('TRecValFieldsProperty.EdCheck');
	if Sender=FindEdit(1)
  	then result := not empty(Val[1])
	else if (Sender=FindEdit(3)) and (Trim(Val[2])='1')
	  then result := Int0(Val[3])>0
  else result:=true;
  DelStack;
end;

function TRecValFieldsProperty.DefValue;
begin
	AddStack('TRecValFieldsProperty.DefValue');
	case Index of
    1: result:=NextName(1,'Val');
    2: result:='1';
    3: result:='10';
  else result:='';
  end;
  DelStack;
end;

{ TRecDBDefFldDefProperty }
procedure TRecDBDefFldDefProperty.Activate;
var fl: boolean;
	rdb: TRecDBDef;
  i: longint;
begin
	AddStack('TRecDBDefFldDefProperty.Activate');
	inherited Activate;
  if not Assigned(DefMemGet) then begin
  	rdb:=TRecDBDef(GetComponent(0)); DefMemGet:=TComboGet.Create(rdb);
    with TComboGet(DefMemGet) do begin
    	VName:=Self.ClassName; fl:=rdb.Active;
      if rdb.OpenRec then for i:=0 to rdb.FieldCount-1 do
        if AnsiStartsText(sDefMemo,rdb.FieldName[i])
        then Items.Add(Copy(rdb.FieldName[i],Length(sDefMemo)+1,MaxInt));
      rdb.Active:=fl;
    end;
  end;
	vEd:=ArrVarToVar(
    [VarArrayOf([teEdit,'Наименование'])
    ,AddFrom(VarArrayOf([teMenu,'Способ хранения']),ArrStrToVar(aDWSvTypeNm))
    ,VarArrayOf([teMenu,'Тип','строка','число','дата','логическое','текст','массив'])
    ,VarArrayOf([teEdit,'Код'])
    ,VarArrayOf([teSpin,'Длина',0,MaxInt])
    ,VarArrayOf([teSpin,'Точность',0,MaxInt])
    ,VarArrayOf([teEdit,'Значение по умолчанию'])
    ,VarArrayOf([teEdit,'Примечание'])
    ]);
  HeadList:='Переменная (код)'; IsStatus:=true;
  DelStack;
end;

function TRecDBDefFldDefProperty.TransStr;
const adwt: TDWFldTypeChr = ('1','2','3','4','5','6','1','1','1');
var a: array[1..8] of string;
  td: TFldDefInf;
begin
	AddStack('TRecDBDefFldDefProperty.TransStr');
	if lGet then begin
  	td:=TRecDBDef.GetFldInf(st);
    if td.Inf.Name='' then result:=''
    else result:=ArrayAsList([td.Inf.Name,IntToStr(byte(td.Inf.SvType)+1),adwt[td.Inf.AType],td.Inf.dwCod,
      IntToStr(td.Inf.Len),IntToStr(td.Inf.Dec),td.Inf.AValue,td.Inf.Prim],UnDelim);
  end
  else begin
    LsArrFill(st,a,UnDelim);
    result:=a[1]+'='+a[4]+UnDelim+aDWSvTypeChr[TDWSaveType(Int0(a[2])-1)]+IfThen(a[3]='2','N',
    	IfThen(a[3]='3','D',IfThen(a[3]='4','L',IfThen(a[3]='5','M',IfThen(a[3]='6','A','S')))))
      +IfThen(Int0(a[5])<>0,a[5])+IfThen(Int0(a[6])<>0,'.'+a[6])
      +UnDelim+a[7]+IfThen(a[8]<>'',UnDelim+a[8]);
  end;
  DelStack;
end;

procedure TRecDBDefFldDefProperty.EdChange;
var s: string;
begin
	AddStack('TRecDBDefFldDefProperty.EdChange');
  if Sender=FindEdit(3) then begin
    s:=Trim(Val[3]);
    TFldEdit(FindEdit(5)).SetReadOnly(not((s='1') or (s='2')));
    TFldEdit(FindEdit(6)).SetReadOnly(s<>'2');
  end;
  DelStack;
end;

procedure TRecDBDefFldDefProperty.EdExit;
var s: string;
	tf: TFldEdit;
begin
	AddStack('TRecDBDefFldDefProperty.EdExit');
  if Sender=FindEdit(3) then begin
    s:=Trim(Val[3]);
    if (s<>'1') and (s<>'2') then Val[5]:='';
    if s<>'2' then Val[6]:='';
    tf:=TFldEdit(FindEdit(4));
    if (s='5') and Assigned(DefMemGet)
    then tf.AssignGet(TComboGet(DefMemGet))
    else tf.AssignGetDef;
  end;
  DelStack;
end;

function TRecDBDefFldDefProperty.EdCheck;
var s: string;
begin
	AddStack('TRecDBDefFldDefProperty.EdCheck');
  result:=true;
	if Sender=FindEdit(1)
  	then result := not empty(Val[1])
	else if Sender=FindEdit(4)
  	then result := not empty(Val[4])
	else if Sender=FindEdit(5) then begin
		s:=Trim(Val[3]);
    if (s='1') or (s='2') then result := Int0(Val[5])>0;
  end;
  DelStack;
end;

function TRecDBDefFldDefProperty.Valid;
var l,d: longint;
begin
	AddStack('TRecDBDefFldDefProperty.Valid');
	l:=Int0(Val[5]); d:=Int0(Val[6]); result := (d=0) or (d<l-1);
  if not result then TPanelEdit(Sender).FldFocus:=TFldEdit(FindEdit(5));
  DelStack;
end;

function TRecDBDefFldDefProperty.DefValue;
begin
	AddStack('TRecDBDefFldDefProperty.DefValue');
	case Index of
    1: result:=NextName(1,'Val');
    2,3: result:='1';
    4: result:=NextCod(3);
    5: result:='10';
  else result:='';
  end;
  DelStack;
end;

function TRecDBDefFldDefProperty.NameFromArr;
var l: longint;
begin
	AddStack('TRecDBDefFldDefProperty.NameFromArr');
	l:=low(a); result:=Trim(a[l])+IfThen(a[l+3]<>'',' ('+a[l+3]+')');
  DelStack;
end;

procedure TRecDBDefFldDefProperty.StatusChange;
var i,ost: longint;
	rv: TDWVidRec;
  rdb: TRecDBDef;
  db: TComponent;
begin
	ost:=AddStack('TRecDBDefFldDefProperty.StatusChange');
	if Mode<>dsmMove then with TRbStatus(Sender) do begin
    if Mode=dsmShow then begin
    	lAvailable:=0; rdb:=TRecDBDef(GetComponent(0));
      if FirstDatabase(rdb.Connection,db) then begin
      	try
	        SetConnected(db,true); rdb.OpenRec;
        except
			    on EDatabaseError do SetStack(ost);
        end;
        if rdb.Active then begin
          lAvailable:=Length(rdb[sLong]); rdb.CloseRec;
          SectRight.Add(Format('Доступно: %d байт',[lAvailable]));
        end;
      end;
      SectRight.Add('');
    end;
		lNeed:=0;
    for i:=0 to ls.Count-1 do begin
      rv:=DWSToRec(TransStr(ls[i],false));
      Inc(lNeed,longint(Length(rv.dwCod)
        +IfThen(rv.AType=dwtDate,10,IfThen(rv.AType=dwtBool,1,rv.Len))+2));
    end;
    SectRight[SectRight.Count-1]:=Format('Требуется: %d байт',[lNeed]);
  end;
  DelStack;
end;

{ TStringBrowlColZnProperty }
procedure TStringBrowlColZnProperty.Activate;
begin
	AddStack('TStringBrowlColZnProperty.Activate');
	inherited Activate;
	vEd:=ArrVarToVar(
    [VarArrayOf([teEdit,'Заголовок'])
    ,null
    ,VarArrayOf([teCombo,'Имя поля',false])
    ,VarArrayOf([teMenu,'Разместить','в центре','слева','справа'])
    ,VarArrayOf([teSpin,'Минимальная длина',-1,MaxInt])
    ]);
  HeadList:='Колонки';
  DelStack;
end;

procedure TStringBrowlColZnProperty.Edit;
var v: variant;
	i: longint;
begin
	AddStack('TStringBrowlColZnProperty.Edit');
  if Assigned(LsCustomRec) then begin
    v:=VarArrayCreate([0,LsCustomRec.Count-1],varVariant);
    for i:=0 to LsCustomRec.Count-1 do v[i]:=LsCustomRec[i];
    vEd[2]:=AddFrom(VarArrayOf([teCombo,'Имя базы',false]),v);
  end
  else vEd[2]:=VarArrayOf([teCombo,'Имя базы',false]);
  inherited Edit;
  DelStack;
end;

function TStringBrowlColZnProperty.ListOwner;
var t: TObject;
	r: TCustomRec;
  i: longint;
begin
	AddStack('TStringBrowlColZnProperty.ListOwner');
	result := inherited ListOwner(Sender);
  if Sender=FindEdit(3) then begin
    t:=FindGet(3);
    if Assigned(t) then with TComboGet(t).Items do begin
      Clear;
      if RecName(Trim(Val[2]),r) then begin
        if not r.Active then r.OpenRec;
        for i:=0 to r.FieldCount-1 do Add(r.FieldName[i]);
        r.CloseRec;
      end;
    end;
  end;
  DelStack;
end;

function TStringBrowlColZnProperty.TransStr;
var i: longint;
	a: array[1..5] of string;
  al: TNamePrimStr;
begin
	AddStack('TStringBrowlColZnProperty.TransStr');
  LsArrFill(st,a,UnDelim);
	if lGet then begin
    if StrDivDlm('.',a[2],al) then TrimSelf(al) else InitArr(al);
    case StrToChar(TrimUpper(a[3])) of
    	'L': a[3]:='2';
    	'R': a[3]:='3';
    else a[3]:='1';
    end;
  	result:=TrimRight(a[1])+UnDelim+ArrayAsList(al,UnDelim,NegDef,true)+a[3]+UnDelim+Trim(a[4]);
  end
  else begin
    for i:=2 to 5 do TrimSelf(a[i]);
    result:=TrimRight(a[1])+UnDelim
    	+IfThen(not((a[2]='') or (a[3]='')),a[2]+'.'+a[3])
      +UnDelim+IfThen(a[4]<>'1',IfThen(a[4]='2','L','R'))
      +IfThen(Int0(a[5])<>0,UnDelim+a[5]);
  end;
  DelStack;
end;

function TStringBrowlColZnProperty.DefValue;
begin
	AddStack('TStringBrowlColZnProperty.DefValue');
	if Index=4 then result:='1' else result:='';
  DelStack;
end;

{ TDefEditFieldsProperty }
procedure TDefEditFieldsProperty.Activate;
begin
	AddStack('TDefEditFieldsProperty.Activate');
	inherited Activate;
	vEd:=VarArrayCreate([byte(low(TDEPrmList)),byte(deTrimLeft)],varVariant);
  vEd[byte(deCaption)]:=VarArrayOf([teEdit,'Наименование']);
  vEd[byte(deNameRecFld)]:=VarArrayOf([teCombo,'Имя поля',false]);
  vEd[byte(deVName)]:=VarArrayOf([teCombo,'Наименование вида ввода',false]);
  vEd[byte(deMask)]:=VarArrayOf([teButTxt,'Параметры ввода']);
  vEd[byte(deMaxLen)]:=VarArrayOf([teSpin,'Макс.длина',0,MaxInt]);
  vEd[byte(deCharCase)]:=AddFrom(VarArrayOf([teMenu,'Преобразование символов']),ArrStrToVar(aDECharCase));
  vEd[byte(deAutoSel)]:=VarArrayOf([teBool,'Выделять']);
  vEd[byte(dePassword)]:=VarArrayOf([teBool,'Ввод пароля']);
  vEd[byte(deNoReadOnly)]:=VarArrayOf([teBool,'Редактировать']);
  vEd[byte(deReadOnlyNoVsbl)]:=VarArrayOf([teBool,'Невидимое, если нередакт.']);
  vEd[byte(deTag)]:=VarArrayOf([teBool,'В новой колонке']);
  vEd[byte(deSayHint)]:=VarArrayOf([teEdit,'Подсказка для наимен.']);
  vEd[byte(deGetHint)]:=VarArrayOf([teEdit,'Подсказка для ввода']);
  vEd[byte(deRelation)]:=VarArrayOf([teCombo,'Подчинено',true]);
  vEd[byte(deWidth)]:=VarArrayOf([teSpin,'Ширина(симв.)',wallLow,999]);
  vEd[byte(deHeight)]:=VarArrayOf([teSpin,'Высота(симв.)',-1,999]);
  vEd[byte(deNoVisible)]:=VarArrayOf([teBool,'Невидимое']);
  vEd[byte(deNewPage)]:=VarArrayOf([teBool,'С новой страницы']);
  vEd[byte(deSayRight)]:=VarArrayOf([teBool,'Наименование справа']);
  vEd[byte(deTrimLeft)]:=VarArrayOf([teBool,'Убирать пробелы слева']);
  HeadList:='Вводимые поля'; PrcEdit:=75; PrcList:=20;
  DelStack;
end;

procedure PrDefEditFieldsArrGet(Sender: TCustomGet; const av: array of variant; var lBreak: boolean);
begin
  AddStack('StLsProp.PrDefEditFieldsArrGet');
  with TArrGet(Sender) do if Wnd=PointerVar(av[0]) then begin
    SetPBoolean(av[1],IfThen(av[2],Assigned(Data),true)); lBreak:=true;
  end;
  DelStack;
end;

function TDefEditFieldsProperty.SeekArrGet;
var obj: TPersistent;
begin
  AddStack('TDefEditFieldsProperty.SeekArrGet');
  result:=false; obj:=GetComponent(0);
  NameGet(TArrGet.ClassName,PrDefEditFieldsArrGet,[longint(obj),longint(@result),WithData]);
  DelStack;
end;

procedure TDefEditFieldsProperty.Edit;
var v: variant;
	i: longint;
	ls: TStringList;
  g: TArrGet;
begin
	AddStack('TDefEditFieldsProperty.Edit');
  vEd[byte(deNameRec)]:=VarArrayOf([teCombo,'Имя базы',false]); v:=null;
  if SeekArrGet(g,false) then begin
    if Assigned(g.Data) then v:=VarArrayOf([g.Data.NameRec]);
  end
  else if Assigned(LsCustomRec) then begin
    v:=VarArrayCreate([0,LsCustomRec.Count-1],varVariant);
    for i:=0 to LsCustomRec.Count-1 do v[i]:=LsCustomRec[i];
  end;
  if not IsNil(v) then AddFromSelf(vEd,byte(deNameRec),v);
  vEd[byte(deVid)]:=VarArrayOf([teCombo,'Вид ввода',false]);
  if Assigned(LsCustomGet) then begin
    ls:=TStringList.Create;
    try
      TCustomGet.GetListVid(ls);
      v:=VarArrayCreate([0,ls.Count-1],varVariant);
      for i:=0 to ls.Count-1 do v[i]:=ls[i];
      AddFromSelf(vEd,byte(deVid),v);
    finally
      ls.Free;
    end;
  end;
  inherited Edit;
  DelStack;
end;

function TDefEditFieldsProperty.TransArr;
begin
	AddStack('TDefEditFieldsProperty.TransArr');
	if TDEPrmList(Index) in setDEDlm then
    if lGet then result:=StrTran(st,UnDelim,sDEDlm) else result:=StrTran(st,sDEDlm,UnDelim)
  else result := inherited TransArr(st,Index,lGet);
  DelStack;
end;

procedure TDefEditFieldsProperty.FormShow;
var g: TArrGet;
begin
  AddStack('TDefEditFieldsProperty.FormShow');
  TFldEdit(FindEdit(byte(deNameRec))).SetReadOnly(SeekArrGet(g));
  DelStack;
end;

{procedure TDefEditFieldsProperty.EdChange;
var mg: TButTextGet;
  g: TCustomGet;
begin
	AddStack('TDefEditFieldsProperty.EdChange');
	if (Sender=TFldEdit(FindEdit(deVid))) or (Sender=TFldEdit(FindEdit(deVName))) then begin
  	tf:=TFldEdit(FindEdit(deMask)); mg:=TButTextGet(NameGet(tf));
    if NameGet(g,Val[deVid],Val[deVName]) then mg.TextReadOnly:=g.MaskTextReadOnly
    else mg.TextReadOnly:=false;
    tf.SetReadOnly(g.MaskReadOnly);
  end;
  DelStack;
end;}

function TDefEditFieldsProperty.NameFromArr;
var l: longint;
begin
	AddStack('TDefEditFieldsProperty.NameFromArr');
	l:=low(a)-1;
  if empty(a[l+byte(deNameRec)]) and empty(a[l+byte(deNameRecFld)])
  then result:=''
  else result:=Trim(a[l+byte(deNameRec)])+'.'+Trim(a[l+byte(deNameRecFld)]);
  DelStack;
end;

function TDefEditFieldsProperty.DefValue;
var g: TArrGet;
begin
	AddStack('TDefEditFieldsProperty.DefValue');
  result:='';
	case TDEPrmList(Index) of
  	deNameRec: if SeekArrGet(g) then result:=g.Data.NameRec;
  	deVid: result:='TSimpleGet';
  	deMaxLen: result:='0';
  	deCharCase: result:=IntToStr(1+byte(ecNormal));
  	deAutoSel: result:=bTrue;
  	deNoReadOnly: result:=bTrue;
  end;
  DelStack;
end;

function TDefEditFieldsProperty.ListOwner;
var t: TObject;
	r: TCustomRec;
  i: longint;
begin
	AddStack('TDefEditFieldsProperty.ListOwner');
	result := inherited ListOwner(Sender);
  if Sender=FindEdit(byte(deNameRecFld)) then begin
    t:=FindGet(byte(deNameRecFld));
    if Assigned(t) then with TComboGet(t).Items do begin
      Clear;
      if RecName(Trim(Val[byte(deNameRec)]),r) then begin
        if not r.Active then r.OpenRec;
        for i:=0 to r.FieldCount-1 do Add(r.FieldName[i]);
        r.CloseRec;
      end;
    end;
  end;
  if Sender=FindEdit(byte(deVName)) then begin
    t:=FindGet(byte(deVName));
    if Assigned(t) then TCustomGet.GetListVName(TComboGet(t).Items,Val[byte(deVid)]);
  end;
  DelStack;
end;

procedure TDefEditFieldsProperty.PnEdEnter;
var t: TObject;
  i: longint;
  cg: TComboGet;
  s,s1: string;
  a: TDEPrmStr;
begin
  AddStack('TDefEditFieldsProperty.PnEdEnter');
  t:=FindGet(byte(deRelation));
  if Assigned(t) then begin
    cg:=TComboGet(t); cg.Items.Clear; cg.Items.Add('');
    s:=AnsiUpperCase(Trim(Val[byte(deNameRec)])+'.'+Trim(Val[byte(deNameRecFld)]));
    for i:=0 to ls.Count-1 do begin
      LsArrFill(ls[i],a,UnDelim);
      if not empty(a[deNameRec]) then begin
        s1:=Trim(a[deNameRec])+'.'+Trim(a[deNameRecFld]);
        if AnsiUpperCase(s1)<>s then cg.Items.Add(s1);
      end;
    end;
  end;
  DelStack;
end;

procedure TDefEditFieldsProperty.ButTextGetClick;
var g: TCustomGet;
  r: TCustomRec;
  tf: TFldEdit;
  s: string;
begin
	AddStack('TDefEditFieldsProperty.ButTextGetClick');
	tf:=TFldEdit(Sender);
  if RecName(tf.NameRec,r) then
    if NameGet(g,Val[byte(deVid)],Val[byte(deVName)]) then begin
      tf.Write; s:=TrimRight(r[tf.NameRecFld]);
      if g.MaskProp('Параметры ввода',s,RecName(Val[byte(deNameRec)]),Val[byte(deNameRecFld)])
      then tf.VarValue:=s;
    end;
  DelStack;
end;

{ TDefEditPagesProperty }
procedure TDefEditPagesProperty.Activate;
var i: byte;
	a: variant;
begin
	AddStack('TDefEditPagesProperty.Activate');
	inherited Activate;
	a:=VarArrayCreate([0,byte(high(TSortMode))+1],varVariant);
  for i:=VarArrayLowBound(a,1) to VarArrayHighBound(a,1) do
  	a[i]:=IntToStr(i)+UnDelim+DEPgSortName(i=0,DEPgSortMode(IntToStr(i)));
	vEd:=ArrVarToVar(
    [VarArrayOf([teEdit,'Наименование'])
    ,AddFrom(VarArrayOf([teMenu,'Сортировка']),a)
    ,VarArrayOf([teBut])
    ,VarArrayOf([teBool,'Невидимая'])
    ,VarArrayOf([teEdit,'Версия'])
    ]);
  HeadList:='Страницы'; OnlyEdit:=true;
  DelStack;
end;

function TDefEditPagesProperty.TransStr;
var a: array[1..5] of string;
begin
  AddStack('TDefEditPagesProperty.TransStr');
  result := inherited TransStr(st,lGet);
	if lGet then begin
    LsArrFill(result,a,UnDelim);
    if Int0(a[5])<1 then begin
      StrShifrSelf(a[3]); a[5]:=LastVersDefEditPages; result:=ArrayAsList(a,UnDelim);
    end;
  end;
  DelStack;
end;

procedure TDefEditPagesProperty.FormShow;
begin
  AddStack('TDefEditPagesProperty.FormShow');
  TFldEdit(FindEdit(5)).SetReadOnly(true,[ogReadOnly,ogReadOnlyNoVsbl]);
  DelStack;
end;

procedure TDefEditPagesProperty.EdChange;
var tf: TFldEdit;
begin
	AddStack('TDefEditPagesProperty.EdChange');
  tf:=TFldEdit(FindEdit(2));
  if Sender=tf then TFldEdit(FindEdit(3)).SetReadOnly(Int0(tf.Value)>0);
  DelStack;
end;

function TDefEditPagesProperty.ButGetClick;
var s: string;
  tf: TFldEdit;
begin
	AddStack('TDefEditPagesProperty.ButGetClick');
  if lEval then begin
  	DWPageNumEdit:=CurLine; tf:=TFldEdit(FindEdit(3));
    s:=StrDeShifr(tf.VarValue);
    CreateForm(TSchemDM,SchemDM);
    with TDefEdit(GetComponent(0)) do
	    if TEdGenFr.EdFormEd(@s,PrFldList,PrEdSay,[defrmCrt]) then tf.VarValue:=StrShifr(s);
    DWPageNumEdit:=-1;
  end;
  result:='Редактирование формы';
  DelStack;
end;

procedure TDefEditPagesProperty.StatusChange;
begin
	AddStack('TDefEditPagesProperty.StatusChange');
  if Mode=dsmShow then TFldEdit(FindEdit(3)).IncOptions([ogReadOnlyNoVsbl]);
  DelStack;
end;

{ TRbMenuKeysProperty }
procedure TRbMenuKeysProperty.Activate;
begin
  AddStack('TRbMenuKeysProperty.Activate');
	inherited Activate;
	vEd:=ArrVarToVar(
    [AddFrom(VarArrayOf([teMenu,'Управляющая клавиша','[нет]']),VAShftKeys)
    ,AddFrom(VarArrayOf([teMenu,'Клавиша']),VAKeys)
    ,VarArrayOf([teEdit,'Наименование'])
    ,AddFrom(VarArrayOf([teCombo,'Картинка',false]),VSubArr(VBMName,2))
    ,VarArrayOf([teBool,'Неактивна'])
    ,VarArrayOf([teBool,'Невидимая'])
    ,VarArrayOf([teBool,'Невыполнимая'])
    ,VarArrayOf([teBool,'Сменить язык'])
    ,VarArrayOf([teMenu,'Помощь объединена с клавишей'])
    ]);
  HeadList:='Клавиши'; ProcPaint:=PbPaint;
  DelStack;
end;

procedure TRbMenuKeysProperty.Edit;
begin
	AddStack('TRbMenuKeysProperty.Edit');
	iBM:=TInitBM.Create(Application.MainForm);
  try
  	inherited Edit;
  finally
    iBM.Free;
  end;
  DelStack;
end;

function TRbMenuKeysProperty.TransStr;
var a: array[1..9] of string;
  al: TNamePrimStr;
  i: longint;
begin
	AddStack('TRbMenuKeysProperty.TransStr');
  LsArrFill(st,a,UnDelim);
	if lGet then begin
    if NmToKey(a[1],i) then a[1]:=KeyToTxt(i) else a[1]:='';
    al:=StrDivDlm('+',a[1],2);
    for i:=low(al) to high(al) do begin
      if al[i]<>'' then al[i]:=TMenuGet(FindGet(i)).CodFromName(al[i]);
      if al[i]='' then al[i]:='1';
    end;
    result:=ArrayAsList([al[1],al[2],a[2],a[3],a[4],a[5],a[6],a[7],
      IntToStr(NmToKey(a[8]))],UnDelim);
  end
  else begin
    if Trim(a[1])='1' then result:=''
    else result:=Trim(TMenuGet(FindGet(1)).MenuName(Trim(a[1])))+'_';
    result:=ArrayAsList([result+KeyToNm(Int0(a[2])),Trim(a[3]),Trim(a[4]),
      Trim(a[5]),Trim(a[6]),Trim(a[7]),Trim(a[8]),KeyToNm(Int0(Trim(a[9])))],UnDelim);
  end;
  DelStack;
end;

function TRbMenuKeysProperty.NameFromArr;
var l: longint;
	s: string;
begin
	AddStack('TRbMenuKeysProperty.NameFromArr');
	l:=low(a);
  if Trim(a[l])='1' then s:=''
  else s:=Trim(TMenuGet(FindGet(1)).MenuName(Trim(a[l])))+'+';
  result:=s+Trim(TMenuGet(FindGet(2)).MenuName(Trim(a[l+1])));
  DelStack;
end;

procedure TRbMenuKeysProperty.EdChange;
begin
	AddStack('TRadioGetItemsProperty.EdChange');
	if Sender=FindEdit(4) then
  	if Assigned(Pb) then Pb.Invalidate;
  DelStack;
end;

procedure TRbMenuKeysProperty.RowMove;
var i: longint;
begin
	AddStack('TRbMenuKeysProperty.RowMove');
	if TComponent(Sender).Owner=Findedit(4) then
    if iBM.LsBM.Find(TrimUpper(VBMName[Index+1]),i) then Val[4]:=iBM.LsBM[i] else Val[4]:='';
  DelStack;
end;

procedure TRbMenuKeysProperty.PbPaint;
var l,t,w,h: longint;
  bm: TBitMap;
begin
	AddStack('TRbMenuKeysProperty.PbPaint');
	with TPaintBox(Sender) do begin
  	Canvas.Brush.Color:=Color; Canvas.FillRect(Rect(0,0,Width-1,Height-1));
    if PointerObjFind(iBM.LsBM,TrimUpper(Val[4]),pointer(bm)) then begin
      w:=bm.Width; h:=bm.Height; l := (Width-w) div 2; t := (Height-h) div 2;
      Canvas.Brush.Color:=clWhite;
      Canvas.BrushCopy(Rect(l,t,l+w,t+h),bm,Rect(0,0,w,h),bm.Canvas.Pixels[0,h-1]);
    end;
  end;
  DelStack;
end;

function TRbMenuKeysProperty.DefValue;
begin
	AddStack('TRbMenuKeysProperty.DefValue');
	case Index of
  	1: result:='1';
  	2: result:=NextCod(2);
  else result:='';
  end;
  DelStack;
end;

procedure TRbMenuKeysProperty.BeforeRead;
var i,key: longint;
  a: array[1..8] of string;
begin
  AddStack('TRbMenuKeysProperty.BeforeRead');
  if Index=9 then with TMenuGet(FindGet(Index)).Items do begin
    BeginUpdate; Clear; Add('0'+UnDelim+'[нет]');
    for i:=0 to ls.Count-1 do if i<>CurLine then begin
      LsArrFill(TransStr(ls[i],false),a,UnDelim);
      if empty(a[8]) then begin
        NmToKey(a[1],key); Add(IntToStr(key)+UnDelim+KeyToTxt(key));
      end;
    end;
    EndUpdate;
  end;
  DelStack;
end;

{ TKeyLbNmProcProperty }
procedure TKeyLbNmProcProperty.Activate;
begin
	AddStack('TKeyLbNmProcProperty.Activate');
	inherited Activate;
	vEd:=ArrVarToVar(
    [AddFrom(VarArrayOf([teMenu,'Управляющая клавиша','[нет]']),VAShftKeys)
    ,AddFrom(VarArrayOf([teMenu,'Клавиша']),VAKeys)
    ,VarArrayOf([teEdit,'Наименование'])
    ,VarArrayOf([teEdit,'Подсказка'])
    ,AddFrom(VarArrayOf([teCombo,'Раздел меню',false]),VARusPart)
    ,VarArrayOf([teEdit,'Имеет право'])
    ,VarArrayOf([teMenu,'Помощь объединена с клавишей'])
    ]);
  HeadList:='Клавиши';
  DelStack;
end;

function TKeyLbNmProcProperty.TransStr;
var a: array[1..7] of string;
  al: TNamePrimStr;
  Shift: TKeyShftList0;
  i,key: longint;
  sp: string;
begin
	AddStack('TKeyLbNmProcProperty.TransStr');
  LsArrFill(st,a,UnDelim);
	if lGet then
    if NmToKey(a[1],i) then begin
      if InRange(i,1,KEY_USER) then begin
        KeyToShift(i,Shift,key); al[1]:=IntToStr(Shift+1); al[2]:=IntToStr(key);
      end
      else InitArr(al,0,MaxInt,'1');
      TrimSelf(a[4]);
      sp:=TKeyMenu.LatToRus(a[4]);
      if sp='' then sp:=a[4];
      result:=ArrayAsList([al[1],al[2],a[2],a[3],sp,a[5],IntToStr(NmToKey(a[6]))],UnDelim);
    end
    else result:=''
  else begin
    if Trim(a[1])='1' then result:=''
    else result:=Trim(TMenuGet(FindGet(1)).MenuName(Trim(a[1])))+'_';
    TrimSelf(a[5]); sp:=TKeyMenu.RusToLat(a[5]);
    if sp='' then sp:=a[5];
    result:=ArrayAsList([result+KeyToNm(Int0(a[2])),Trim(a[3]),Trim(a[4]),sp,Trim(a[6]),
      KeyToNm(Int0(Trim(a[7])))],UnDelim);
  end;
  DelStack;
end;

function TKeyLbNmProcProperty.NameFromArr;
var l: longint;
	s: string;
begin
	AddStack('TKeyLbNmProcProperty.NameFromArr');
	l:=low(a);
  if Trim(a[l])='1' then s:=''
  else s:=Trim(TMenuGet(FindGet(1)).MenuName(Trim(a[l])))+'+';
  result:=s+Trim(TMenuGet(FindGet(2)).MenuName(Trim(a[l+1])));
  DelStack;
end;

function TKeyLbNmProcProperty.DefValue;
begin
	AddStack('TKeyLbNmProcProperty.DefValue');
	case Index of
  	1: result:='1';
  	2: result:=NextCod(2);
  else result:='';
  end;
  DelStack;
end;

procedure TKeyLbNmProcProperty.BeforeRead;
var i,key: longint;
  a: array[1..6] of string;
begin
  AddStack('TKeyLbNmProcProperty.BeforeRead');
  if Index=7 then with TMenuGet(FindGet(Index)).Items do begin
    BeginUpdate; Clear; Add('0'+UnDelim+'[нет]');
    for i:=0 to ls.Count-1 do if i<>CurLine then begin
      LsArrFill(TransStr(ls[i],false),a,UnDelim);
      if not(empty(a[2]) and empty(a[3]) and not empty(a[4])) and empty(a[6]) then begin
        NmToKey(a[1],key); Add(IntToStr(key)+UnDelim+KeyToTxt(key));
      end;
    end;
    EndUpdate;
  end;
  DelStack;
end;

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(TMulQueryMulPar),nil,'',TMulQueryMulParProperty);
  RegisterPropertyEditor(TypeInfo(TStrings),TMenuGet,'Items',TMenuGetItemsProperty);
  RegisterPropertyEditor(TypeInfo(TStrings),TRadioGet,'Items',TRadioGetItemsProperty);
  RegisterPropertyEditor(TypeInfo(TStrings),TSpdButGet,'Buttons',TSpdButGetButtonsProperty);
  RegisterPropertyEditor(TypeInfo(TStrings),TRecVal,'Fields',TRecValFieldsProperty);
  RegisterPropertyEditor(TypeInfo(TStrings),TRecDBDef,'FldDef',TRecDBDefFldDefProperty);
  RegisterPropertyEditor(TypeInfo(TStrings),TStringBrowl,'ColZn',TStringBrowlColZnProperty);
  RegisterPropertyEditor(TypeInfo(TStrings),TDefEdit,'Fields',TDefEditFieldsProperty);
  RegisterPropertyEditor(TypeInfo(TStrings),TDefEdit,'Pages',TDefEditPagesProperty);
  RegisterPropertyEditor(TypeInfo(TRbMenuKeys),nil,'',TRbMenuKeysProperty);
  RegisterPropertyEditor(TypeInfo(TKeyLbNmProc),nil,'NmProc',TKeyLbNmProcProperty);
end;

end.
