unit MenuGet;

interface

{$I LIBTEST}
uses Windows,Classes,Controls,
  MyTypes,FFldEdit,CCodeGet,PaintCtl,RecVal;

type
	TMenuGetRec = record
   	Cod,Name: string;
  end;

  TMGStrByListEvent = function(Sender: TObject; tf: TFldEdit; const mr: TMenuGetRec): string of object;

	TMenuGet = class(TCustomCodeGet)
 	private
  { Private declarations }
	 	FItems: TStringList;
    FUserItems: boolean;
    FOnStrByList: TMGStrByListEvent;
    procedure SetItems(Value: TStringList);
    procedure ProcKey(key: longint; tw: TWinControl);
    procedure LeftClick(Sender: TObject);
    procedure RightClick(Sender: TObject);
    procedure Prior(tf: TFldEdit);
    procedure Next(tf: TFldEdit);
    procedure ItemsChange(Sender: TObject);
    function SpStr(const s: string): string;
		procedure SetPrm(const Mask: string);
    function SeekCod(const sC: string; var mr: TMenuGetRec; var nm: string): boolean; overload;
 	protected
  { Protected declarations }
    sL,sR: TPaintButton;
		Prm: TMenuGetPrm;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    function Check(tf: TFldEdit): boolean; override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function AssignObj(tf: TFldEdit): boolean; override;
    procedure SetDefLenCode; override;
    procedure SetDefLenName; override;
		function GetDefLenCode(const Mask: string): longint; override;
		function DWFldUnAllowType(const Mask: string): TDWFldSetType; override;
    procedure StdListDown(tf: TFldEdit; const RectList: TRect;
	    PozList: TPozList); override;
		function MinWidthCode(tf: TFldEdit): longint; override;
		function MinWidthName(tf: TFldEdit): longint; override;
		function TextToItems(const Text: string): string; virtual;
    class function ListKeyStr: string; virtual;
    procedure ListKeyProc(key: longint; tw: TWinControl); virtual;
  	class function MaskSortMode: TSortMode; override;
		class function MaskPnlValid(Sender: TObject): boolean; override;
    class procedure FMaskView(var Mask: string); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
  public
  { Public declarations }
		constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function SeekCod(const sC: string; var i: longint): boolean; overload;
    function SeekCod(const sC: string; var mr: TMenuGetRec): boolean; overload;
    function SeekCod(const sC: string): boolean; overload;
    function MenuName(const ACode: string): string;
    function Menus(const ACode: string): string;
    function Menust(const ACode: string): string;
    function CodFromName(const cName: string): string;
    function ACodName(i: longint): TMenuGetRec;
		function MaxSymb: longint;
    function SeekCurCod(tf: TFldEdit): longint;
		procedure StdDWFldInfo(const Mask: string; var FldInfo: TDWFldInfo); override;
		procedure StdDWFldValue(r: TCustomRec; const Mask: string; var Value: variant); override;
		class function MaskTextReadOnly: boolean; override;
    function LogEqual(var Prm: TLogTrnsValPrm; const tbl,nmf: string): boolean;
    function Arr2Mask(const a: array of string; LowLim: longint = 0): string;
  published
  { Published declarations }
  	property UserItems: boolean read FUserItems write FUserItems;
  	property Items: TStringList read FItems write SetItems;
  	property OnStrByList: TMGStrByListEvent read FOnStrByList write FOnStrByList;
  { Унаследованные }
   	property LenCode;
   	property LenName;
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

procedure Register;

implementation

uses SysUtils,StrUtils,Math,Variants,Forms,DB,Grids,
  My_pr,StrBrowl,DefEdit,KeyLb,ListF2,RecDB,FPanel;

type
	TMenuItemGet = class(TCustomGet)
  private
  	flMove: boolean;
    ARow: longint;
		class function sbCalcZn(Sender: TObject; ACol: longint): string;
    procedure sbMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
    procedure sbMouseMove(Sender: TObject; Shift: TShiftState; X,Y: longint);
    procedure sbMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
		procedure ProcKey(key: longint; tw: TWinControl);
		procedure Move(oi,ni: longint);
		procedure PrMove(oi,ni: longint; const av: array of variant);
		function deItemFldCheck(Sender: TObject): boolean;
  protected
  	sb: TStringBrowl;
    procedure CreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function MayDoKey(tf: TFldEdit; Key: longint): boolean; override;
    function AssignObj(tf: TFldEdit): boolean; override;
  end;

var MenuItemGet: TMenuItemGet;
  rItem: TRecVal;
  deItem: TDefEdit;
  iItem: longint;

const aOpt: TMenuGetStr = ('код видимый','наименование видимое','преобразовать в целое');

{ TMenuGet }
constructor TMenuGet.Create;
begin
	AddStack('TMenuGet.Create',Self);
	inherited Create(AOwner);
  FItems:=TStringList.Create; FItems.OnChange:=ItemsChange; UpdateAllFld(mgCreate);
  DelStack;
end;

destructor TMenuGet.Destroy;
begin
	AddStack('TMenuGet.Destroy',Self);
  FItems.Free;
	inherited Destroy;
  DelStack;
end;

procedure TMenuGet.SetItems;
begin
	AddStack('TMenuGet.SetItems',Self);
	if not FItems.Equals(Value) then begin
		FItems.Assign(Value); ItemsChange(FItems);
  end;
  DelStack;
end;

procedure TMenuGet.ItemsChange;
begin
	AddStack('TMenuGet.ItemsChange',Self);
  FDefLenCode:=0; FDefLenName:=0; SetDefLenCode; SetDefLenName;
  if not FUserItems then UpdateAllFld(mgReCreate);
  DelStack;
end;

{ Длина кода по умолчанию }
procedure TMenuGet.SetDefLenCode;
var i: longint;
	a: TNamePrimStr;
begin
	AddStack('TMenuGet.SetDefLenCode',Self);
	inherited SetDefLenCode;
  if FDefLenCode=0 then
   	for i:=0 to FItems.Count-1 do if StrDivDlm(UnDelim,FItems[i],a) then begin
      if not FUserItems or (mngNum in Prm.Opt) then TrimSelf(a[1]);
      MaxSelf(FDefLenCode,a[1]);
    end;
  DelStack;
end;

{ Длина наименования по умолчанию }
procedure TMenuGet.SetDefLenName;
begin
	AddStack('TMenuGet.SetDefLenName',Self);
	inherited SetDefLenName;
  if FDefLenName=0 then FDefLenName:=MaxSymb;
  DelStack;
end;

function TMenuGet.GetDefLenCode;
begin
  AddStack('TMenuGet.GetDefLenCode',Self);
  if FUserItems then begin
    FDefLenCode:=0; SetPrm(Mask);
  end;
	result:=inherited GetDefLenCode(Mask);
  DelStack;
end;

{ Создать объекты }
procedure TMenuGet.CreateObj;
begin
	AddStack('TMenuGet.CreateObj');
	inherited CreateObj(tf);
	if inherited AssignObj(tf) then begin
    //if not Assigned(bDyn) then begin
      sL:=TPaintButton.Create(tf);
      with sL do begin
        Canvas:=tf.Canvas; Hint:='Предыдущее значение'; ShowHint:=true;
        BMByName(Glyph,bmLeft);
        //BMSpeedButton(sL,OBM_LFARROWD);
        onClick:=LeftClick;
      end;
      sR:=TPaintButton.Create(tf);
      with sR do begin
        Canvas:=tf.Canvas; Hint:='Следущее значение'; ShowHint:=true;
        BMByName(Glyph,bmRight);
        //BMSpeedButton(sR,OBM_RGARROWD);
        onClick:=RightClick;
      end;
    //end;
    eC.ReadOnly:=true; //eC.CaretHidden:=true;
    eN.ReadOnly:=true; //eN.CaretHidden:=true;
    tf.ReCreateObj;
  end;
  DelStack;
end;

{ Переустановить свойства объектов }
procedure TMenuGet.ReCreateObj;
begin
	AddStack('TMenuGet.ReCreateObj',Self);
	if AssignObj(tf) then begin
    sL.Visible := tf.Visible and not Assigned(bDyn); sR.Visible:=sL.Visible;
    eC.Visible := mngCod in Prm.Opt; eN.Visible := mngName in Prm.Opt;
    inherited ReCreateObj(tf);
  end;
  DelStack;
end;

{ Достать значение Value из объектов }
function TMenuGet.GetValue;
begin
	AddStack('TMenuGet.GetValue',Self);
	if AssignObj(tf) then result:=eC.Text
  else begin
    result:=''; Exclude(Prm.Opt,mngNum);
  end;
  result:=SpStr(result);
  DelStack;
end;

function TMenuGet.SpStr;
begin
  AddStack('TMenuGet.SpStr',Self);
  if mngNum in Prm.Opt then result:=SpaceStr0(s,FDefLenCode) else result:=Padr(s,FDefLenCode);
  DelStack;
end;

{ Установить свойства объектов в соответствии с Value }
procedure TMenuGet.SetValue;
var s: string;
	mr: TMenuGetRec;
	i: longint;
  fl: boolean;
begin
	AddStack('TMenuGet.SetValue',Self);
	if AssignObj(tf) then begin
    s:=SpStr(v); fl:=true;
    for i:=0 to FItems.Count-1 do begin
      mr:=ACodName(i);
      if s=SpStr(mr.Cod) then begin
        fl:=false; break;
      end;
    end;
    if fl then mr:=ACodName(0);
    eC.Text:=mr.Cod; eN.Text:=mr.Name;
  end;
  DelStack;
end;

{ Проверка корректности значения }
function TMenuGet.Check;
begin
	AddStack('TMenuGet.Check',Self);
	result := inherited Check(tf);
  if result then result:=SeekCod(tf.Value);
  DelStack;
end;

{ Действия при получении фокуса }
procedure TMenuGet.DoEnter;
var tl: TKeyLb;
	i: longint;
  mr: TMenuGetRec;
begin
	AddStack('TMenuGet.DoEnter',Self);
	inherited DoEnter(tf);
	if AssignObj(tf) then
    if FormKeyLb(tf,tl) and not((ogReadOnly in tf.Options) or Assigned(bDyn)) then with tl do begin
      SetKey(K_Left,'','Предыдущее значение',ProcKey,'menuget',kmEdit);
      SetKeys([K_Right,K_Space],'','Следующее значение',ProcKey,'menuget',kmEdit);
      SetKey(K_Home,'','Первое значение',ProcKey,'menuget',kmEdit);
      SetKey(K_End,'','Последнее значение',ProcKey,'menuget',kmEdit);
      if eC.Visible then for i:=K_0 to K_9 do begin
        if SeekCod(KeyToTxt(i),mr) then with mr do
          SetKey(i,'','Установить значение "'+Cod+IfThen(eN.Visible,'.'+Name)+'"',ProcKey,'menuget',kmNone);
      end;
      ReDrw;
    end;
  DelStack;
end;

{ Действия при утере фокуса }
procedure TMenuGet.DoExit;
var tl: TKeyLb;
begin
	AddStack('TMenuGet.DoExit',Self);
  if FormKeyLb(tf,tl)
  //and Assigned(GetParentForm(tf).ActiveControl)
	then tl.DelKey(K_All,'menuget');
	inherited DoExit(tf);
  DelStack;
end;

{ Реакция на клавиши }
procedure TMenuGet.ProcKey;
var tf: TFldEdit;
	s: string;
begin
	AddStack('TMenuGet.ProcKey');
	tf:=GetOwnerFldEdit(tw);
  if AssignObj(tf) then case key of
   	K_Left: Prior(tf);
    K_Right,K_Space: Next(tf);
    K_Home: tf.Value:=ACodName(0).Cod;
    K_End: tf.Value:=ACodName(FItems.Count-1).Cod;
  else
   	s:=KeyToTxt(key);
    if SeekCod(s) then tf.Value:=s;
  end;
  DelStack;
end;

{ Щелчок по кнопке Left }
procedure TMenuGet.LeftClick;
var tf: TFldEdit;
begin
	AddStack('TMenuGet.LeftClick',Self);
	tf:=pointer(TPaintButton(Sender).Owner);
	if not tf.Active then tf.SetFocus;
  if not(ogReadOnly in tf.Options) then Prior(tf);
  DelStack;
end;

{ Щелчок по кнопке Right }
procedure TMenuGet.RightClick;
var tf: TFldEdit;
begin
	AddStack('TMenuGet.RightClick',Self);
	tf:=pointer(TPaintButton(Sender).Owner);
	if not tf.Active then tf.SetFocus;
  if not(ogReadOnly in tf.Options) then Next(tf);
  DelStack;
end;

{ Предыдущее значение }
procedure TMenuGet.Prior;
var i: longint;
begin
	AddStack('TMenuGet.Prior',Self);
  if AssignObj(tf) then begin
    i:=max(0,SeekCurCod(tf)); tf.Value:=ACodName(IfThen(i=0,FItems.Count,i)-1).Cod;
  end;
  DelStack;
end;

{ Следущее значение }
procedure TMenuGet.Next;
var i: longint;
begin
	AddStack('TMenuGet.Next',Self);
  if AssignObj(tf) then begin
    i:=max(0,SeekCurCod(tf)); tf.Value:=ACodName(IfThen(i<>FItems.Count-1,i+1)).Cod;
  end;
  DelStack;
end;

{ Найти строку с текущим кодом }
function TMenuGet.SeekCurCod;
var v: string;
begin
	AddStack('TMenuGet.SeekCurCod',Self);
	v:=GetValue(tf);
  if v='' then result:=-1
  else if not SeekCod(v,result) then result:=-1;
  DelStack;
end;

{ Найти строку с кодом sC }
function TMenuGet.SeekCod(const sC: string; var i: longint): boolean;
var s: string;
	mr: TMenuGetRec;
begin
	AddStack('TMenuGet.SeekCod',Self);
	s:=Trim(sC); result:=false; i:=0;
  while i<FItems.Count do begin
   	mr:=ACodName(i);
    if s=Trim(mr.Cod) then begin
      result:=true; break;
    end;
    Inc(i);
	end;
  DelStack;
end;

function TMenuGet.SeekCod(const sC: string; var mr: TMenuGetRec): boolean;
var i: longint;
begin
  result:=SeekCod(sC,i);
  if result then mr:=ACodName(i);
end;

function TMenuGet.SeekCod(const sC: string): boolean;
var i: longint;
begin
  result:=SeekCod(sC,i);
end;

function TMenuGet.SeekCod(const sC: string; var mr: TMenuGetRec; var nm: string): boolean;
begin
  result:=SeekCod(sC,mr);
  if not result then nm:='';
end;

{ Поиск объектов }
function TMenuGet.AssignObj;
var i: longint;
  p: TPaintButton;
begin
	AddStack('TMenuGet.AssignObj',Self);
	sL:=nil; sR:=nil; result:=false;
  if inherited AssignObj(tf) then with tf do begin
    {if Assigned(bDyn) then result:=true
    else begin}
      for i:=0 to ComponentCount-1 do
        if IsClass(Components[i],TPaintButton,pointer(p)) then if p.Tag=0 then if p<>bDyn then
          if Assigned(sL) then sR:=p else sL:=p;
      result := (Assigned(sL) and Assigned(sR));
    //end;
    if result then SetPrm(Mask);
  end;
  DelStack;
end;

function TMenuGet.DWFldUnAllowType;
begin
	AddStack('TMenuGet.DWFldUnAllowType',Self);
  result := inherited DWFldUnAllowType(Mask);
  if FUserItems then Exclude(result,dwtFloat);
  DelStack;
end;

procedure TMenuGet.SetPrm;
begin
  AddStack('TMenuGet.SetPrm',Self);
  Prm:=MenuMask2Prm(Mask);
  if FUserItems then FItems.Text:=TextToItems(Prm.sItems);
  DelStack;
end;

function TMenuGet.TextToItems;
begin
  AddStack('TMenuGet.TextToItems',Self);
  result:=StrTran(Text,mniDlm,CRLF);
  DelStack;
end;

// Вызов выпадающего списка
procedure TMenuGet.StdListDown;
var lr: TListF2Result;
	mr: TMenuGetRec;
  i: longint;
  s,s1: string;
begin
	AddStack('TMenuGet.StdListDown',Self);
  if AssignObj(tf) then begin
    lr:=TListF2Result.Create;
    try
      s:='';
      for i:=0 to FItems.Count-1 do if not Empty(FItems[i]) then begin
        mr:=ACodName(i);
        if Assigned(FOnStrByList) then s1:=FOnStrByList(Self,tf,mr)
        else s1:=IfThen(eC.Visible,mr.Cod+' ')+mr.Name;
        IncD(s,CRLF+s1); lr.Add(mr.Cod);
      end;
      lr.SelectStr:=SeekCurCod(tf);
      if ListF2Down(copy(s,lCRLF1,MaxInt),lr,IfThen(eC.Visible,eC,eN),RectList.Right-RectList.Left,
      tf.Schem,ListKeyStr,ListKeyProc,0,nil,nil,OnMouseMove,nil,OnRowMove) then begin
        SetPrm(tf.Mask); tf.Value:=ACodName(lr.SelectStr).Cod;
      end;
    finally
	    lr.Free;
    end;
  end;
  DelStack;
end;

class function TMenuGet.ListKeyStr;
begin
  result:='';
end;

procedure TMenuGet.ListKeyProc;
begin
end;

function TMenuGet.MinWidthCode;
var i: longint;
begin
	AddStack('TMenuGet.MinWidthCode',Self);
  result:=0;
  if AssignObj(tf) then begin
    for i:=0 to FItems.Count-1 do MaxSelf(result,tf.Canvas,ACodName(i).Cod);
    if result=0 then result := inherited MinWidthCode(tf) else AfterMinWidthCode(tf,result);
  end;
  DelStack;
end;

function TMenuGet.MinWidthName;
var i: longint;
begin
	AddStack('TMenuGet.MinWidthName',Self);
  result := inherited MinWidthName(tf);
  if AssignObj(tf) then for i:=0 to FItems.Count-1 do MaxSelf(result,tf.Canvas,ACodName(i).Name);
  //if result=0 then result := inherited MinWidthName(tf);
  DelStack;
end;

// Разбор строки на код и наименование
function TMenuGet.ACodName;
var a: TNamePrimStr;
begin
	AddStack('TMenuGet.ACodName',Self);
  if InRange(i,0,FItems.Count-1) then begin
    StrDivDlm(UnDelim,FItems[i],a); result.Cod:=SpStr(a[1]); result.Name:=a[2];
  end
  else Finalize(result);
  DelStack;
end;

// Наименование по коду
function TMenuGet.MenuName;
var mr: TMenuGetRec;
begin
	AddStack('TMenuGet.MenuName',Self);
  if SeekCod(ACode,mr,result) then result:=mr.Name;
  DelStack;
end;

// "Код - Наименование" по коду
function TMenuGet.Menus;
var mr: TMenuGetRec;
begin
	AddStack('TMenuGet.Menus',Self);
  if SeekCod(ACode,mr,result) then result:=mr.Cod+' - '+mr.Name;
  DelStack;
end;

// "Код. Наименование" по коду
function TMenuGet.Menust;
var mr: TMenuGetRec;
begin
	AddStack('TMenuGet.Menust',Self);
  if SeekCod(ACode,mr,result) then result:=mr.Cod+'. '+mr.Name;
  DelStack;
end;

// Код по наименованию
function TMenuGet.CodFromName;
var i: longint;
	tr: TMenuGetRec;
  AName: string;
begin
	AddStack('TMenuGet.CodFromName',Self);
	result:=''; AName:=TrimUpper(cName);
  for i:=0 to FItems.Count-1 do begin
    tr:=ACodName(i);
    if TrimUpper(tr.Name)=AName then begin
    	result:=tr.Cod; break;
    end;
  end;
  DelStack;
end;

// Максимальное кол-во символов
function TMenuGet.MaxSymb;
var i: longint;
begin
	AddStack('TMenuGet.MaxSymb',Self);
	result:=0;
  for i:=0 to FItems.Count-1 do MaxSelf(result,ACodName(i).Name);
  DelStack;
end;

procedure TMenuGet.Assign;
var cg: TMenuGet;
begin
	AddStack('TMenuGet.Assign',Self);
  if IsClass(Source,TMenuGet,pointer(cg)) then begin
   	LenCode:=cg.LenCode; LenName:=cg.LenName; Items.Assign(cg.Items);
  end;
	inherited Assign(Source);
  DelStack;
end;

procedure TMenuGet.StdDWFldInfo;
begin
	AddStack('TMenuGet.StdDWFldInfo',Self);
	SetPrm(Mask); FldInfo.Size:=0;
  if mngCod in Prm.Opt then begin
    Inc(FldInfo.Size,FDefLenCode);
    if mngName in Prm.Opt then Inc(FldInfo.Size,2);
  end;
  if mngName in Prm.Opt then Inc(FldInfo.Size,FDefLenName);
  FldInfo.Alignment:=taLeftJustify;
  DelStack;
end;

procedure TMenuGet.StdDWFldValue;
var ACode: string;
begin
	AddStack('TMenuGet.StdDWFldValue',Self);
  SetPrm(Mask);
  if SeekCod(Value) then ACode:=Value else ACode:=ACodName(0).Cod;
  if (mngCod in Prm.Opt) and (mngName in Prm.Opt) then Value:=Menust(ACode)
  else if mngCod in Prm.Opt then Value:=SpStr(ACode)
  else Value:=MenuName(ACode);
  if LogPrimCalc then TrimSelf(Value);
  DelStack;
end;

function TMenuGet.MaskTrans;
const lOpt = Length(aOpt);
var i: TMenuGetList;
begin
	AddStack('TMenuGet.MaskTrans');
	if MyVarType(av)=varArray then begin
    result:='';
    for i:=low(aOpt) to high(aOpt) do
      if IsNilc(av[1+byte(i)],i in MnOptInv) <> (i in MnOptInv) then IncD(result,aMnOpt[i]);
    if FUserItems then IncD(result,av[lOpt+1]);
  end
  else begin
  	SetPrm(av); result:=VarArrayCreate([1,lOpt],varVariant);
    for i:=low(aOpt) to high(aOpt) do
      result[1+byte(i)]:=VarArrayOf([mpBool,FRup(aOpt[i]),i in Prm.Opt]);
    if FUserItems then begin
    	VarArrayReDim(result,lOpt+1);
      TSimpleGet.CreateOne;
	    result[lOpt+1]:=VarArrayOf([mpCustom,'Значения',Prm.sItems,LongInt(TMenuItemGet.CreateOne(TCustomGet(MenuItemGet),Application.MainForm))]);
    end;
  end;
  DelStack;
end;

class function TMenuGet.MaskTextReadOnly;
begin
	result:=true;
end;

class procedure TMenuGet.FMaskView;
var Prm: TMenuGetPrm;
  a: TMenuGetStr;
  i: TMenuGetList;
begin
  AddStack('TMenuGet.FMaskView');
  Prm:=MenuMask2Prm(Mask);
  for i:=low(a) to high(a) do a[i]:=IfThen(i in Prm.Opt,aOpt[i]);
  Mask:=DlmBetween(a,', ');
  DelStack;
end;

procedure TMenuGet.FMaskHelp;
var n: byte;
  i: TMenuGetList;
  s: string;
begin
  AddStack('TMenuGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat);
  if FUserItems then ht.Head:=DlmBetween(RVid,RVName,': ');
  SetLength(ht.Dat,n+1+Length(aMnOpt)+IfThen(FUserItems,5));
  for i:=low(aMnOpt) to high(aMnOpt) do begin
    Inc(n);
    CopyFrom(ht.Dat[n],HelpIf('«'+FRup(aOpt[i])+'»',
      '"'+IfThen(not(i in mnOptInv),aMnOpt[i])+'"','"'+IfThen(i in mnOptInv,aMnOpt[i])+'"')
      +IfThen((i<high(aMnOpt)) or FUserItems,'+;'));
  end;
  if FUserItems then begin
    Inc(n); s:=HelpBoldStr('«Значения»');
    CopyFrom(ht.Dat[n],HelpArrayAsList(s,'"'+mniDlm+'"',false));
    Inc(n); ht.Dat[n]:=nil;
    Inc(n); CopyFrom(ht.Dat[n],s+' - массив, состоящий из элементов нижеследующей структуры:');
    Inc(n); CopyFrom(ht.Dat[n],HelpStruct(['Код','Наим']));
    Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr('«Код»')+'+"'+UnDelim+'"+'+HelpBoldStr('«Наименование»'));
  end;
  DelStack;
end;

class function TMenuGet.MaskSortMode;
begin
	result:=smColumns;
end;

class function TMenuGet.MaskPnlValid;
begin
	AddStack('TMenuGet.MaskPnlValid');
	result := StrToBoolean(EdMaskFld(1+byte(mngCod)).Value) or StrToBoolean(EdMaskFld(1+byte(mngName)).Value);
  DelStack;
end;

function TMenuGet.LogEqual;
begin
  AddStack('TMenuGet.LogEqual',Self);
  result:=RecDB.LogEqual(Prm,tbl,nmf);
  if result then with Prm do begin
    val:=MenuName(val); lBreak:=true;
  end;
  DelStack;
end;

function TMenuGet.Arr2Mask;
begin
  AddStack('TMenuGet.Arr2Mask');
  Items.Text:=Strtran(MenuArr2Mask(a,LowLim),mniDlm,CRLF);
  DelStack;
end;

{ TMenuItemGet }
function aMnItemVal(const v: variant; var a: TArrStr): longint;
begin
  AddStack('MenuGet.aMnItemVal');
  if empty(v) then result:=0 else result:=LsArrDynamic(v,a,mniDlm);
  DelStack;
end;

function MenuNum: boolean;
var tf: TFldEdit;
begin
  AddStack('MenuGet.MenuNum');
  tf:=EdMaskFld(1+byte(mngNum));
  if Assigned(tf) then result:=StrToBoolean(tf.Value) else result:=false;
  DelStack;
end;
        
procedure TMenuItemGet.CreateObj;
var si: TStrBrInfZn;
begin
	AddStack('TMenuItemGet.CreateObj',Self);
  DestroyObj(tf); tf.Schem:='Browl';
  sb:=TStringBrowl.Create(tf);
  with sb do begin
    Parent:=tf; si:=InfoCol[0];
    CopyFrom(si.aName,'Код'); si.Alignment:=taLeftJustify; si.LenData:=10; InfoCol[0]:=si;
    si.aName[0]:='Наименование'; si.lMax:=true; InfoCol[1]:=si;
    KeyDblClick:=K_F5; OnCalcZn:=sbCalcZn; OnMouseDown:=sbMouseDown; OnMouseMove:=sbMouseMove; OnMouseUp:=sbMouseUp;
  end;
  tf.CharWidth:=wallDefault; tf.CharHeight:=-1; SetSchemForm(tf);
  DelStack;
end;

procedure TMenuItemGet.PaintObj;
begin
	AddStack('TMenuItemGet.PaintObj',Self);
  if AssignObj(tf) then begin
  	sb.SetBounds(BevelFld,BevelFld,tf.Width-BevelFld2,tf.Height-BevelFld2); sb.WidthCols;
  end;
  DelStack;
end;

function TMenuItemGet.GetValue;
var i: longint;
begin
	AddStack('TMenuItemGet.GetValue',Self);
  result:='';
  if AssignObj(tf) then begin
  	for i:=1 to sb.RowCount-1 do
    	if empty(sb.Cells[IfThen(not MenuNum,1),i]) then break
      else IncD(result,sb.Cells[0,i]+UnDelim+sb.Cells[1,i]+mniDlm);
    DecLen(result,lmniDlm);
  end;
  DelStack;
end;

procedure TMenuItemGet.SetValue;
var a: TArrStr;
	a1: array[0..1] of string;
  orow,i,l: longint;
  otl: TGridCoord;
begin
	AddStack('TMenuItemGet.SetValue',Self);
  if AssignObj(tf) then begin
  	l:=aMnItemVal(v,a); orow:=sb.Row; otl:=sb.TopLeft; sb.Init;
    if l=0 then sb.DelLast
    else begin
    	sb.RowCount:=l+1;
      for i:=1 to l do begin
        LsArrFill(a[i-1],a1,UnDelim); sb.Cells[0,i]:=a1[0]; sb.Cells[1,i]:=a1[1];
      end;
    end;
    sb.Row:=EnsureRange(orow,1,sb.RowCount-1); sb.TopLeft:=otl;
  end;
  DelStack;
end;

procedure TMenuItemGet.DoEnter;
var tl: TKeyLb;
begin
	AddStack('TMenuItemGet.DoEnter',Self);
  inherited DoEnter(tf);
	if AssignObj(tf) then GetParentForm(tf).ActiveControl:=sb;
  if FormKeyLb(tf,tl) then with tl do begin
  	SetKey(K_F4,'Скопировать','',ProcKey,'menuitemget',kmList);
  	SetKey(K_F5,'Редактировать','',ProcKey,'menuitemget',kmList);
  	SetKey(K_F7,'Добавить','',ProcKey,'menuitemget',kmList);
  	SetKey(K_F8,'Удалить','',ProcKey,'menuitemget',kmList);
  	SetKey(K_Ctrl_Up,'Выше','Переместить выше',ProcKey,'menuitemget',kmList);
  	SetKey(K_Ctrl_Down,'Ниже','Переместить ниже',ProcKey,'menuitemget',kmList);
  	ReDrw;
  end;
  DelStack;
end;

procedure TMenuItemGet.DoExit;
var tl: TKeyLb;
begin
	AddStack('TMenuItemGet.DoExit',Self);
  inherited DoExit(tf);
  if FormKeyLb(tf,tl) then with tl do begin
  	DelKey(K_All,'menuitemget'); ReDrw;
  end;
  DelStack;
end;

procedure TMenuItemGet.ProcKey;
var a: TArrStr;
	function InitEd(const Capt: string; i: longint): boolean;
  var a1: array[0..1] of string;
    av: TDEPrmVar;
  begin
    AddStack('TMenuItemGet.ProcKey.InitEd',Self);
    if not Assigned(rItem) then begin
    	rItem:=TRecVal.Create(Application.MainForm);
      with rItem do begin
      	CreateFld('COD',ftString,sb.InfoCol[0].LenData,'');
      	CreateFld('NAME',ftMemo,0,'');
      end;
    	deItem:=TDefEdit.Create(Application.MainForm);
      with deItem do begin
      	NameWnd:='MenuItemGet'; InitArr(av);

        av[deCaption]:='Код';
        av[deNameRec]:=rItem.NameRec;
        av[deNameRecFld]:='COD';
        TSimpleGet.AssignGetClass(av);
        av[deAutoSel]:=true;
        av[deNoReadOnly]:=true;
        CreateFld(av);

        av[deCaption]:='Наименование';
        av[deNameRecFld]:='NAME';
        av[deWidth]:=wallDefault;
        CreateFld(av);
      end;
    end;
    if Key=K_F7 then a1[1]:='' else LsArrFill(a[sb.Row-sb.FixedRows],a1,UnDelim);
    if Key<>K_F5 then a1[0]:=IntToStr(Int0(sb.Cells[0,sb.RowCount-1])+1);
    rItem['COD']:=a1[0]; rItem['NAME']:=a1[1];
    iItem:=i; deItem.OnFldCheck:=deItemFldCheck; result:=deItem.Execute(Capt).Saved;
    DelStack;
  end;
var tf: TFldEdit;
  l: longint;
	procedure RecRead;
  begin
    AddStack('TMenuItemGet.ProcKey.RecRead',Self);
    a[iItem]:=Trim(rItem['COD'])+UnDelim+Trim(rItem['NAME']);
    tf.Value:=ArrayAsList(a,mniDlm,l);
    DelStack;
  end;
var i,n: longint;
begin
	AddStack('TMenuItemGet.ProcKey',Self);
  tf:=FldEditOwner(sb); l:=aMnItemVal(tf.Value,a);
  if (l>0) or (Key=K_F7) then case Key of
    K_F4,K_F7: if InitEd('Добавить значение',l) then begin
      i:=iItem+1; SetLength(a,max(l,i)); l:=i; RecRead; sb.Row:=i;
    end;
    K_F5: if InitEd('Редактировать значение',sb.Row-1) then RecRead;
    K_F8: if Ask(amsDel) then begin
    	i:=sb.Row; Dec(l);
      for n:=i to l do a[n-1]:=a[n];
      tf.Value:=ArrayAsList(a,mniDlm,l); sb.Row:=min(i,sb.RowCount-1);
    end;
    K_Ctrl_Up: Move(sb.Row,sb.Row-1);
    K_Ctrl_Down: Move(sb.Row,sb.Row+1);
  end;
  DelStack;
end;

function TMenuItemGet.deItemFldCheck;
var s: string;
	i: longint;
begin
  AddStack('TMenuItemGet.deItemFldCheck',Self);
  with TFldEdit(Sender) do begin
    NoEmpCheck(Sender,IfThen(MenuNum,'COD','NAME'),result);
    if result then if NameRecFld='COD' then begin
      s:=Trim(VarValue);
      for i:=1 to sb.RowCount-1 do if (i<>iItem+1) and (Trim(sb.Cells[0,i])=s) then begin
        meserr('Значение с таким кодом уже есть.'); result:=false; break;
      end;
    end;
  end;
  DelStack;
end;

procedure TMenuItemGet.Move;
begin
	AddStack('TMenuItemGet.Move',Self);
  if ListMoveItem(oi,ni,1,sb.RowCount-1,PrMove,[0]) then sb.Row:=ni;
  DelStack;
end;

procedure TMenuItemGet.PrMove;
var s: string;
	a: TArrStr;
  tf: TFldEdit;
  l: longint;
begin
	AddStack('TMenuItemGet.PrMove',Self);
  Dec(oi,sb.FixedRows); Dec(ni,sb.FixedRows); tf:=FldEditOwner(sb); l:=aMnItemVal(tf.Value,a);
  s:=a[ni]; a[ni]:=a[oi]; a[oi]:=s; tf.Value:=ArrayAsList(a,mniDlm,l);
  DelStack;
end;

class function TMenuItemGet.sbCalcZn;
var sb: TStringBrowl;
	a: TArrStr;
  a1: array[0..1] of string;
begin
	AddStack('TMenuItemGet.sbCalcZn');
  sb:=pointer(Sender);
  if InRange(sb.Row,1,aMnItemVal(FldEditOwner(sb).Value,a)) then begin
  	LsArrFill(a[sb.Row-1],a1,UnDelim); result:=a1[ACol];
  end
  else result:='';
  DelStack;
end;

procedure TMenuItemGet.sbMouseDown;
var ACol: longint;
begin
	AddStack('TMenuItemGet.sbMouseDown',Self);
	if not flMove and (Button=mbLeft) then begin
	  sb.MouseToCell(X,Y,ACol,ARow); flMove := ARow>0; sb.NoSel:=false;
  end;
  DelStack;
end;

procedure TMenuItemGet.sbMouseMove;
var ACol,nr: longint;
begin
	AddStack('TMenuItemGet.sbMouseMove',Self);
	if flMove then begin
	  sb.MouseToCell(X,Y,ACol,nr);
  	if (nr>0) and (nr<>ARow) then begin
		  Move(ARow,nr); ARow:=nr;
    end;
  end;
  DelStack;
end;

procedure TMenuItemGet.sbMouseUp;
begin
	flMove:=false;
end;

function TMenuItemGet.MayDoKey;
begin
	AddStack('TMenuItemGet.MayDoKey',Self);
  result := inherited MayDoKey(tf,Key);
  if AssignObj(tf) then  result:=not(((Key=K_Down) and (sb.Row<sb.RowCount-1))
  	or ((Key=K_Up) and (sb.Row>sb.FixedRows)));
  DelStack;
end;

function TMenuItemGet.AssignObj;
begin
	AddStack('TMenuItemGet.AssignObj',Self);
  if inherited AssignObj(tf) and (tf.ComponentCount=1)
  then result:=IsClass(tf.Components[0],TStringBrowl,pointer(sb))
  else begin
    sb:=nil; result:=false;
  end;
  DelStack;
end;

procedure Register;
begin
	RegisterComponents('OurGets',[TMenuGet]);
end;

end.
