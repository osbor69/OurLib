unit SpinGet;

interface

{$I LIBTEST}
uses
  Windows,Classes,Controls,
  MyTypes,KeyMenu,FldMask,RecVal,FFldedit,PaintCtl;

type
  TSpinGet = class(TCustomGet)
  private
    { Private declarations }
		MainMn: TKeyMenu;
	 	procedure tmKeyPress(Sender: TObject; var Key: Char);
    procedure ProcKey(key: longint; tw: TWinControl);
    procedure LRClick(Sender: TObject);
		procedure EnabledKeys(tf: TFldEdit);
  protected
    { Protected declarations }
   	tm: TFldMask;
    sL,sR: TPaintButton;
    Prm: TSpinGetPrm;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
		procedure Paint(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    function Check(tf: TFldEdit): boolean; override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function FromCalc(tf: TFldEdit; d: Double; X,Y: longint): boolean; override;
    function AssignObj(tf: TFldEdit): boolean; override;
    procedure SetMaxLen(l: longint); virtual;
		function GetText: longint; virtual;
		function SetText(n: longint): string; virtual;
		function DWFldUnAllowType(const Mask: string): TDWFldSetType; override;
  	class function MaskSortMode: TSortMode; override;
    class procedure FMaskView(var Mask: string); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
  public
    { Public declarations }
		constructor Create(AOwner: TComponent); override;
		procedure StdDWFldInfo(const Mask: string; var FldInfo: TDWFldInfo); override;
		procedure DWFldValid(const ap: TDEPrmStr; const dwInf: TDWVidRec;
    	var nFldFocus: TDEPrmList; var nVarFocus: TVarParam; var amsg: TArrStr); override;
		class function MaskTextReadOnly: boolean; override;
		function StdDWFldCanSumm(const Value: variant): boolean; override;
  	class function DDatSupport: boolean; override;
  published
    { Published declarations }
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

procedure Register;

implementation

uses SysUtils,Forms,MaskUtils,Variants,StrUtils,Math,
  My_pr,Schem,KeyLb;

constructor TSpinGet.Create;
begin
	AddStack('TSpinGet.Create',Self);
	Inherited Create(AOwner);
  RVid:='Целочисленный'; UpdateAllFld(mgCreate);
  DelStack;
end;

{ Создание объектов }
procedure TSpinGet.CreateObj;
begin
	AddStack('TSpinGet.CreateObj',Self);
	DestroyObj(tf); bDyn:=tf.DynButCreate; tm:=TFldMask.Create(tf);
  with tm do begin
   	Parent:=tf; AutoSize:=false; BorderStyle:=bsNone; TabStop:=false;
    onClick:=tf.EdClick;
    onDblClick:=tf.EdDblClick;
    onKeyDown:=tf.EdKeyDown;
    onKeyPress:=tmKeyPress;
    onKeyUp:=tf.EdKeyUp;
    onMouseDown:=tf.EdMouseDown;
    onMouseMove:=tf.EdMouseMove;
    onMouseUp:=tf.EdMouseUp;
  end;
  if not Assigned(bDyn) then begin
    sL:=TPaintButton.Create(tf);
    with sL do begin
      Canvas:=tf.Canvas; Hint:='Предыдущее значение'; ShowHint:=true;
      BMByName(Glyph,bmLeft);
      //BMSpeedButton(sL,OBM_LFARROWD);
      onClick:=LRClick;
    end;
    sR:=TPaintButton.Create(tf);
    with sR do begin
      Canvas:=tf.Canvas; Hint:='Следущее значение'; ShowHint:=true;
      BMByName(Glyph,bmRight);
      //BMSpeedButton(sR,OBM_RGARROWD);
      onClick:=LRClick;
    end;
  end;
  inherited CreateObj(tf);
  DelStack;
end;

{ Переустановить свойства объектов }
procedure TSpinGet.ReCreateObj;
begin
	AddStack('TSpinGet.ReCreateObj',Self);
	if AssignObj(tf) then with tf do begin
    tm.AutoSelect := (ogAutoSelect in Options);
    SetMaxLen(MaxIntValue([MaxLength,LenIntStr(Prm.MinValue),LenIntStr(Prm.MaxValue)]));
    tm.ReadOnly := (ogReadOnly in Options) or Prm.ReadOnly or Assigned(bDyn);
	  inherited ReCreateObj(tf);
    tm.SelStart:=0; tm.SelLength:=0;
  end;
  DelStack;
end;

procedure TSpinGet.tmKeyPress;
var tf: TFldEdit;
begin
  AddStack('TSpinGet.tmKeyPress',Self);
  tf:=FldEditOwner(Sender);
  if AssignObj(tf) then begin
    if not(IsDigit(Key) or (Prm.MinValue<0) and (Key='-') or (Key in [#3{K_Ctrl_C},#22{K_Ctrl_V},#24{K_Ctrl_X}])) then Key:=#0;
    tf.EdKeyPress(Sender,Key);
  end;
  DelStack;
end;

procedure TSpinGet.SetMaxLen;
begin
	AddStack('TSpinGet.SetMaxLen',Self);
  if tm.MaxLength<>l then begin
    tm.EditMask:=IfThen(Prm.MinValue<0,'#','9')
      +StringOfChar('9',l-1)+MaskFieldSeparator+'1'+MaskFieldSeparator+' ';
    tm.MaxLength:=l;
  end;
  DelStack;
end;

{ Нарисовать объект TFldMask }
procedure TSpinGet.PaintObj;
var w,wc,h: longint;
begin
	AddStack('TSpinGet.PaintObj',Self);
	if AssignObj(tf) then with tf do begin
    tm.Color:=Color1; h:=Height-BevelFld2;
    if Assigned(bDyn) then begin
      w:=DynButSize.cX; bDyn.SetBounds(Width-BevelFld-w,BevelFld,w,h);
    end
    else begin
      w:=SysMetric.iScrollWidth;
      sR.SetBounds(Width-BevelFld-w,BevelFld,w,h);
      sL.SetBounds(sR.Left-w,BevelFld,w,h);
      MultD(w,2);
    end;
    wc:=tf.DynCaptSize(h).cX;
    tm.SetBounds(BevelFld+2+wc,BevelFld+2,Width-BevelFld2-w-4-wc,h-4);
  end;
  DelStack;
end;

procedure TSpinGet.Paint;
begin
  AddStack('TSpinGet.Paint',Self);
  if AssignObj(tf) then tf.FldMaskBorder(tm);
  DelStack;
end;

{ Автоматическая установка размеров }
function TSpinGet.SizeAuto;
var ts: TSchem;
  dsz,dcsz: TSize;
  h: longint;
begin
	AddStack('TSpinGet.SizeAuto',Self);
	result := inherited SizeAuto(tf,Opt);
	if AssignObj(tf) then begin
    if not(csDesigning in ComponentState) then
      if SchemName(tf.Schem,ts) then tm.Font.Assign(ts.Font1);
    with tf.Canvas do begin
      Font.Assign(tm.Font);
      if Opt<>[] then begin
        dsz:=DynButSize; h:=max(CanvasMaxH(tf.Canvas)+4,dsz.cY); dcsz:=tf.DynCaptSize(h);
        if tfszHeight in Opt then result.cY:=max(h,dcsz.cY);
        if tfszWidth in Opt then begin
          result.cX:=TextWidth(StringOfChar('0',{max(2,}tm.MaxLength{)}))+6+dsz.cX+dcsz.cX;
          if not Assigned(bDyn) then Inc(result.cX,SysMetric.iScrollWidth*2);
        end;
      end;
    end;
  end;
  DelStack;
end;

{ Достать значение Value из объектов }
function TSpinGet.GetValue;
begin
	AddStack('TSpinGet.GetValue',Self);
	if AssignObj(tf) then result:=IntToStr(EnsureRange(GetText,Prm.MinValue,Prm.MaxValue)) else result:='';
  DelStack;
end;

function TSpinGet.GetText;
begin
  AddStack('TSpinGet.GetText',Self);
  result:=Int0(tm.Text);
  DelStack;
end;

{ Установить свойства объектов в соответствии с Value }
procedure TSpinGet.SetValue;
var n,ost: longint;
	fl: boolean;
begin
	ost:=AddStack('TSpinGet.SetValue',Self);
	if AssignObj(tf) then begin
    try
      n:=Int0(v); fl := not InRange(n,Prm.MinValue,Prm.MaxValue);
      if fl then EnsureSelf(n,Prm.MinValue,Prm.MaxValue);
      tm.Text:=SetText(n);
      if fl then tf.Write;
      tm.SelAll;
    except
    	SetStack(ost);
    end;
  end;
  DelStack;
end;

function TSpinGet.SetText;
begin
  AddStack('TSpinGet.SetText',Self);
  result:=IntToStr(n);
  DelStack;
end;

{ Действия при получении фокуса }
function TSpinGet.Check;
begin
	AddStack('TSpinGet.Check',Self);
  result := inherited Check(tf);
  if result then
	  if AssignObj(tf) then result:=tm.Check;
  DelStack;
end;

procedure TSpinGet.DoEnter;
var tl: TKeyLb;
begin
	AddStack('TSpinGet.DoEnter',Self);
  inherited DoEnter(tf);
	if AssignObj(tf) then GetParentForm(tf).ActiveControl:=tm;
  if FormKeyLb(tf,tl) and not((ogReadOnly in tf.Options) or Assigned(bDyn)) then begin
    tl.SetKey(K_Left,'','Предыдущее значение',ProcKey,'SpinGet',kmEdit);
    tl.SetKey(K_Right,'','Следующее значение',ProcKey,'SpinGet',kmEdit);
    if SeekKeyMenu(tf,MainMn) then MainMn.InsLine(kmEdit,K_Left);
    EnabledKeys(tf);
  end;
  DelStack;
end;

{ Действия при утере фокуса }
procedure TSpinGet.DoExit;
var tl: TKeyLb;
begin
	AddStack('TSpinGet.DoExit',Self);
  if SeekKeyMenu(tf,MainMn) then MainMn.DelLine(kmEdit,K_Left);
  if FormKeyLb(tf,tl)
  //and Assigned(GetParentForm(tf).ActiveControl)
  then tl.DelKey(K_All,'SpinGet');
  inherited DoExit(tf);
  DelStack;
end;

procedure TSpinGet.ProcKey;
begin
	AddStack('TSpinGet.ProcKey',Self);
	if AssignObjOwner(tw) then case Key of
  	K_Left: sL.Click;
  	K_Right: sR.Click;
  end;
  DelStack;
end;

{ Щелчок по кнопкам Left/Right }
procedure TSpinGet.LRClick;
var tf: TFldEdit;
	v,md: Longint;
begin
	AddStack('TSpinGet.LRClick',Self);
	tf:=pointer(TPaintButton(Sender).Owner);
  if not tf.Active then tf.SetFocus;
  if AssignObj(tf) and not(ogReadOnly in tf.Options) then begin
    v:=Int0(tf.Value);
    if (Sender=sL) and (v>Prm.MinValue) then begin
    	Dec(v,Prm.Increment); md := (v-Prm.MinValue) mod Prm.Increment;
      if md>0 then Inc(v,Prm.Increment-md)
      else if md<0 then v:=Prm.MinValue;
    	tf.Value:=IntToStr(v);
    end
    else if (Sender=sR) and (v<Prm.MaxValue) then begin
    	Inc(v,Prm.Increment); md := (v-Prm.MinValue) mod Prm.Increment;
      if md>0 then Dec(v,md);
    	tf.Value:=IntToStr(v);
    end;
    EnabledKeys(tf);
  end;
  DelStack;
end;

procedure TSpinGet.EnabledKeys;
var v: Longint;
begin
	AddStack('TSpinGet.EnabledKeys',Self);
	if Assigned(MainMn) then begin
    v:=Int0(tf.Value);
    MainMn.EnabledItem(kmEdit,K_Left,v>Prm.MinValue);
    MainMn.EnabledItem(kmEdit,K_Right,v<Prm.MaxValue);
  end;
  DelStack;
end;

// Взять число из калькулятора
function TSpinGet.FromCalc;
begin
	AddStack('TSpinGet.FromCalc',Self);
	tf.Value:=IntToStr(Trunc(d)); result:=true;
  DelStack;
end;

{ Поиск объектов }
function TSpinGet.AssignObj;
var n: byte;
begin
	AddStack('TSpinGet.AssignObj',Self);
	tm:=nil; sL:=nil; sR:=nil; result:=false;
  with Prm do begin
  	MinValue:=0; MaxValue:=0; Increment:=1;
  end;
  if inherited AssignObj(tf) then begin
    n:=IfThen(Assigned(bDyn),1);
		if tf.ComponentCount>n then
      if IsClass(tf.Components[n],TFldMask,pointer(tm)) then begin
        if Assigned(bDyn) then result:=true
        else if tf.ComponentCount>n+2
        then result:=IsClass(tf.Components[n+1],TPaintButton,pointer(sL))
          and IsClass(tf.Components[n+2],TPaintButton,pointer(sR));
        if result then Prm:=SpinGetPrm(tf.Mask);
      end;
  end;
  DelStack;
end;

function TSpinGet.MaskTrans;
var mm: TSpinGetPrm;
begin
	AddStack('TSpinGet.MaskTrans');
	if MyVarType(av)=varArray
  then result:=ArrayAsList([IntToStr(IsNilc(av[1],0)),IntToStr(IsNilc(av[2],0)),
    IntToStr(IsNilc(av[3],1)),Bool2Str(IsNilc(av[4],false))],',')
  else begin
  	mm:=SpinGetPrm(av);
    result:=ArrVarToVar(
      [VarArrayOf([mpSpin,'Минимальное значение',mm.MinValue,-MaxInt,MaxInt])
      ,VarArrayOf([mpSpin,'Максимальное значение',mm.MaxValue,-MaxInt,MaxInt])
      ,VarArrayOf([mpSpin,'Интервал',mm.Increment,1,MaxInt])
      ,VarArrayOf([mpBool,'Редактировать только с помощью стрелок',mm.ReadOnly])
      ]);
  end;
  DelStack;
end;

class function TSpinGet.MaskTextReadOnly;
begin
	result:=true;
end;

procedure TSpinGet.DWFldValid;
var mm: TSpinGetPrm;
	l,l1: longint;
begin
	AddStack('TSpinGet.DWFldValid',Self);
  inherited DWFldValid(ap,dwInf,nFldFocus,nVarFocus,amsg);
  if (Length(amsg)=0) and not IsDWFldMemo(dwInf.AType) then begin
	  mm:=SpinGetPrm(ap[deMask]); l:=MaxSelf([IntToStr(mm.MinValue),IntToStr(mm.MaxValue)]);
    l1:=LenInt(dwInf.Len,dwInf.Dec);
    if l>l1 then AddFrom(amsg,[
      BracketInt('Длина поля для указанных минимального и максимального значений',l),
      BracketInt('превышает длину целой части данного',l1)+'.']);
  end;
  DelStack;
end;

function TSpinGet.DWFldUnAllowType;
begin
  result:=[dwtDate,dwtBool,dwtArray,dwtSel];
end;

class function TSpinGet.MaskSortMode;
begin
	result:=smColumns;
end;

class procedure TSpinGet.FMaskView;
var mm: TSpinGetPrm;
begin
  AddStack('TSpinGet.FMaskView');
  mm:=SpinGetPrm(Mask);
  Mask:=DlmBetween([Format('от %d до %d',[mm.MinValue,mm.MaxValue]),
    IfThen(mm.Increment<>1,StrNum('интервал:',mm.Increment)),
    IfThen(mm.ReadOnly,'только стрелки')],',');
  DelStack;
end;

procedure TSpinGet.FMaskHelp;
const Dlm = '+","+;';
var n: byte;
begin
  AddStack('TSpinGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+6);
  Inc(n); CopyFrom(ht.Dat[n],HelpStruct(['Мин','Макс','Интервал','ТолькоСтрелки']));
  Inc(n); CopyFrom(ht.Dat[n],HelpNum('«Минимальное значение»')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpNum('«Максимальное значение»')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpNum('«Интервал»')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpBool('«Редактировать только с помощью стрелок»'));
  DelStack;
end;

procedure TSpinGet.StdDWFldInfo;
var mm: TSpinGetPrm;
begin
	AddStack('TSpinGet.StdDWFldInfo',Self);
  mm:=SpinGetPrm(Mask); FldInfo.Alignment:=taRightJustify;
  FldInfo.Size:=MaxSelf([IntToStr(mm.MinValue),IntToStr(mm.MaxValue)]);
  DelStack;
end;

function TSpinGet.StdDWFldCanSumm;
begin
  result:=true;
end;

class function TSpinGet.DDatSupport;
begin
  result:=true;
end;

procedure DWFldDefaultProc(const r: TDWVidRec; var ap: TDEPrmStr);
var s1,s2: string;
  l: longint;
begin
  AddStack('SpinGet.DWFldDefaultProc');
  if (r.AType=dwtFloat) and (r.Dec=0) then begin
    TSpinGet.AssignGetClass(ap); s2:=IntToStr(MaxInt); l:=max(r.Len,Length(s2));
    s1:=Padl(StringOfChar('9',r.Len),l); PadLSelf(s2,l);
    ap[deMask]:='0,'+Trim(IfThen(s1<s2,s1,s2));
  end;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TSpinGet]);
end;

initialization
  AddStack('SpinGet.initialization');
  AddFrom(DWFldDefaultProc);
  DelStack;
end.
