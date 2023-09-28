unit Keylb;

interface

{$I LIBTEST}
uses
  Messages,Classes,Controls,Forms,Menus,
  MyTypes,FPanel,KeyMenu,Schem;

type
	TKeyLb = class(TCustomRbPanel)
	private
  { Private declarations }
	 	aBut: TArrKeyBut;
    aButNoEval: array of TArrKeyBut;
    nButNoEval,oL,oT,ActiveBut,CurIndex: longint;
		Moving,FCanMove,FirstReDrw,Modified,FButShowing: boolean;
	 	PopMn: TPopupMenu;
    MainMn: TKeyMenu;
	 	curf: TForm;
	 	FNmProc: TKeyLbNmProc;
	 	FOnRePlace: TNotifyEvent;
	 	FProcKey: TKeyProc;
		procedure SetButShowing(Value: boolean);
    procedure SetNmProc(Value: TKeyLbNmProc);
    procedure SetProcKey(Value: TKeyProc);
		procedure SetDefKey;
		procedure NmProcChange(Sender: TObject);
    procedure FSetPlace(Value: TRbPanelPlace; cng: boolean);
    procedure FReDrw(wm: longint; lMod: boolean);
		procedure MakeKey(Index: longint);
		procedure OpenHideKey(Part,Key: longint);
		procedure mnClick(Sender: TObject);
    procedure LbMove(Sender: TObject);
    class procedure LbVisible(Sender: TObject);
		class procedure PrFixKeyVisible(key: longint; tw: TWinControl);
		procedure FSetFixKey(tb: PKeyBut);
		procedure SetMod(i: longint; const oCapt: string = '');
		function FIsKeyBut(key: longint; all: boolean): boolean;
		procedure CreateFixKey;
		function SeekKey(Key: longint; var i: longint): boolean; overload;
		procedure aButClear(i: longint); overload;
		class procedure aButClear(var aBut: TArrKeyBut); overload;
		procedure SetFormKeyDown;
		procedure DelKeyIndex(i: longint);
    procedure WMSchem(var msg: TWMSchem); message WM_SCHEM;
  	procedure WMCngPriv(var Msg: TMessage); message WM_CNGPRIV;
  	procedure WMSaveIni(var Msg: TWMSaveIni); message WM_SAVEINI;
  	procedure WMKeyInitProg(var Msg: TWMKeyInitProg); message WM_KEYINITPROG;
  	procedure WMHelpFill(var Msg: TWMHelpFill); message WM_HELPFILL;
	protected
	 	procedure RePlace; dynamic;
		procedure CreateWnd; override;
		procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
    procedure MouseMove(Shift: TShiftState; X,Y: longint); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
	public
  { Public declarations }
    NoEval,FromMenu: boolean;
    PButton: ^TButtonRec;
    KeyCount: longint;
	  property ButShowing: boolean read FButShowing write SetButShowing;
    constructor Create(AOwner:TComponent);override;
    destructor Destroy;override;
    procedure SetPlace(Value: TRbPanelPlace);
    function SetKeySt(const st: string; proc: TKeyProc; const nmPr: string): longint;
    procedure SetKeysSt(const st: string; proc: TKeyProc; const nmPr: string);
    procedure SetKey(key: longint; const txt,hnt: string;
	    proc: TKeyProc; const nmPr: string; Part: longint; const Priv: string = ''; keyhelp: longint = 0);
    procedure SetKeys(const Keys: array of longint; const txt,hnt: string;
	    proc: TKeyProc; const nmPr: string; Part: longint; const Priv: string = '');
    procedure SetKeyBut(const Key: array of TKeyBut; proc: TKeyProc; const nmPr: string; lSet: boolean = true); overload;
    procedure SetKeyBut(const Key: array of TKeyBut); overload;
    class procedure SetKeyBut(const Key: array of TKeyBut; ls: TStrings); overload;
    procedure SetKeyFind(proc: TKeyProc; const nmPr: string; Part: longint = kmList;
      lCont: boolean = true);
    procedure SetKeySel(const keyPlus,keyMinus: array of longint;
	    proc: TKeyProc; const nmPr: string; Part: longint = kmList; const Priv: string = '');
    class function GetKeySt(key: longint; const txt: string = '';
      const hnt: string = ''; Part: longint = kmNone; const Priv: string = ''; keyhelp: longint = 0): string; overload;
    class function GetKeySt(key: longint; keyhelp: longint): string; overload;
    class function GetKeySt(const Keys: array of longint; keyhelp: longint): string; overload;
    class function GetKeySt(const Key: TKeyBut): string; overload;
    procedure DelKey(key: longint = K_All; const nmPr: string = '');
    class procedure DelKeySt(ls: TStrings; const key: array of longint); overload;
    procedure DelKeySt(const key: array of longint); overload;
		procedure DelKeys(const aKey: array of longint);
		procedure DelKeyNmPr(const aNmPr: array of string);
    procedure ReDrw(lMod: boolean = true);
    function ExecKey(Key: longint): boolean;
    function IsKeyBut(key: longint): boolean;
    function IsAllKeyBut(key: longint): boolean;
    procedure SetButNoEval(Value: boolean);
		function SetWHMin(tp: TCustomRbPanel; wm: longint): boolean; override;
  	procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  	procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Press(Key: longint; Value: boolean);
		function Keys(Index: longint): PKeyBut;
		function SeekKey(Key: longint; var tb: PKeyBut; all: boolean = true): boolean; overload;
		function SeekKey(Key: longint; all: boolean = true): PKeyBut; overload;
		procedure AddKeyItem(tb: PKeyBut);
    class procedure SetFixKey(Key: longint; const Hnt: string;
	    Proc: TKeyProc; Part: longint = kmNone);
		class function FixKeyShow(Key: longint; lShow: boolean): boolean;
		class function ExecFixKey(Key: longint): boolean;
    class function FixKeySeek(Key: longint): boolean; overload;
    class function FixKeySeek(Key: longint; var tb: PKeyBut): boolean; overload;
		class procedure SetFixKeyVisible;
    class procedure FixKeyProc(Key: longint; tw: TWinControl);
    class procedure ProcNone(Key: longint; tw: TWinControl);
  { Унаследованные }
    property PopupMenu;
  published
	 	property CanMove: boolean read FCanMove write FCanMove;
    property NmProc: TKeyLbNmProc read FNmProc write SetNmProc;
	 	property OnProcKey: TKeyProc read FProcKey write SetProcKey;
	 	property OnRePlace: TNotifyEvent read FOnRePlace write FOnRePlace;
  { Унаследованные }
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BorderStyle;
	 	property Visible;
	 	property OnClick;
	 	property OnDblClick;
	end;

  TWMMsOff = record
    Msg: longint;
    Oper: TMsOffOper;
    case TMsOffOper of
      msoInit: (NoUsed: longint; ResInit: boolean);
      msoEnter,msoExit: (KeyLb: TKeyLb);
      msoExec: (rExec: PMSOExec; NoResExec: boolean);
  end;

procedure Register;
function FormKeyLb(Sender: TControl): TKeyLb; overload;
function FormKeyLb(Sender: TControl; var tl: TKeyLb): boolean; overload;
procedure FormKeyLb(Sender: TControl; var tl: TKeyLb; AComponent: TComponent; Operation: TOperation); overload;
procedure GetDlgCodeTab(Sender: TControl; var Msg: TWmGetDlgCode);
function KeyLbVar(const v: variant): TKeyLb;

implementation

uses Windows,SysUtils,Graphics,StrUtils,Math,
  My_pr;

const
  KeyAllVisible = K_Alt_V;

  nmPrFixKey = 'fixkey';

var LsKeyLb: TList;
	LsFixKey: TIntegerList;
  aFixKey: TArrKeyBut;
	bm: TBitMap;
  tid: UINT;
  AllVisible: boolean = true;

// Возвращает панель клавиш для текущей формы
function FormKeyLb(Sender: TControl): TKeyLb;
begin
  FormKeyLb(Sender,result);
end;

function FormKeyLb(Sender: TControl; var tl: TKeyLb): boolean;
var f: TForm;
begin
	AddStack('KeyLb.FormKeyLb');
  if ParentForm(Sender,f) then result:=ComponentsClass(f,TKeyLb,pointer(tl))
  else begin
  	tl:=nil; result:=false;
  end;
  DelStack;
end;

procedure FormKeyLb(Sender: TControl; var tl: TKeyLb; AComponent: TComponent; Operation: TOperation);
begin
  case Operation of
    opInsert: if AComponent is TKeyLb then FormKeyLb(Sender,tl);
    opRemove: if AComponent=tl then tl:=nil;
  end;
end;

procedure GetDlgCodeTab;
var FKeyPanel: TKeyLb;
  Shift: TKeyShftList0;
  i,k: longint;
begin
  AddStack('KeyLb.GetDlgCodeTab');
  if FormKeyLb(Sender,FKeyPanel) then with FKeyPanel do
    for i:=0 to KeyCount-1 do with Keys(i)^ do if not NoEval then begin
      KeyToShift(Key,Shift,k);
      if k=K_Tab then begin
        Or_D(Msg.Result,dlgc_WantTab); break;
      end;
    end;
  DelStack;
end;

function KeyLbVar;
begin
  result:=PointerVar(v);
end;

procedure FixKeyUpdate(tb: PKeyBut);
var i: longint;
begin
	AddStack('KeyLb.FixKeyUpdate');
  if Assigned(LsKeyLb) then
    for i:=0 to LsKeyLb.Count-1 do TKeyLb(LsKeyLb[i]).FSetFixKey(tb);
  DelStack;
end;

procedure KeyButDispose(p: Pointer);
begin
  AddStack('KeyLb.KeyButDispose');
  with PKeyBut(p)^ do begin
    Caption:=''; Hint:=''; NmParent:=''; Priv:='';
  end;
  DelStack;
end;

function FFixKeySeek(Key: longint; var tb: PKeyBut): boolean;
var n: longint;
begin
  AddStack('KeyLb.FFixKeySeek');
  result:=LsFixKey.IntObjFind(Key,n);
  if result then tb:=@aFixKey[n];
  DelStack;
end;

{ TKeyLb }
constructor TKeyLb.Create;
const	aPopup: array[0..3] of string = ('Снизу','Справа','Сверху','Слева');
var i: longint;
	mn: TMenuItem;
begin
	AddStack('TKeyLb.Create',Self);
	Inherited Create(AOwner);
	ListCreateObj(Self,LsKeyLb);
	Parent:=pointer(Owner); ParentFont:=true; PButton:=@GlobButtonRec;
	curf:=ParentForm(Self);
	FCanMove:=true; Enabled:=true; Visible:=AllVisible;
  CurIndex:=-1; SetLength(aBut,10);
	FNmProc:=TKeyLbNmProc.Create;
  TStringList(FNmProc).OnChange:=NmProcChange;
	FirstReDrw:=true; Moving:=false; Tag:=-1;
  BevelInner:=bvNone; BevelOuter:=bvLowered;
	PopMn:=TPopupMenu.Create(Self);
  for i:=low(aPopup) to high(aPopup) do begin
  	mn:=TMenuItem.Create(PopMn); mn.Caption:=aPopup[i];
    mn.Tag:=i; mn.RadioItem:=true; mn.GroupIndex:=1;
    mn.OnClick:=LbMove; PopMn.Items.Add(mn);
	end;
  PopMn.Items.Add(MenuNewLine(PopMn));
  mn:=TMenuItem.Create(PopMn); mn.Caption:='Скрыть ('+KeyToTxt(KeyAllVisible)+')';
  mn.OnClick:=LbVisible; PopMn.Items.Add(mn);
  ShowHint:=true; SetFormKeyDown; //CreateFixKey;
  DelStack;
end;

procedure TKeyLb.CreateWnd;
begin
	AddStack('TKeyLb.CreateWnd',Self);
	inherited CreateWnd;
  SetFormKeyDown;
  DelStack;
end;

procedure TKeyLb.Notification;
begin
  AddStack('TKeyLb.Notification',Self);
  SeekKeyMenu(Self,MainMn,AComponent,Operation);
  DelStack;
end;

procedure TKeyLb.SetFormKeyDown;
begin
  AddStack('TKeyLb.SetFormKeyDown',Self);
  SeekKeyMenu(Self,MainMn); 
  if Assigned(curf) then
  	if FormKeyLb(curf)=Self then begin
      if not Assigned(curf.OnKeyDown) then curf.OnKeyDown:=FormKeyDown;
      if not Assigned(curf.OnKeyUp) then curf.OnKeyUp:=FormKeyUp;
      curf.KeyPreview:=true; CreateFixKey;
    end;
  DelStack;
end;

destructor TKeyLb.Destroy;
var i: longint;
begin
	AddStack('TKeyLb.Destroy',Self);
  FNmProc.Free; aButClear(aBut);
  for i:=low(aButNoEval) to high(aButNoEval) do aButClear(i);
  aButNoEval:=nil; ListDestroyObj(Self,LsKeyLb); PopMn:=nil;
	inherited Destroy;
  DelStack;
end;

procedure TKeyLb.aButClear(i: longint);
begin
  aButClear(aButNoEval[i]);
end;

class procedure TKeyLb.aButClear(var aBut: TArrKeyBut);
var j: longint;
begin
  AddStack('TKeyLb.aButClear');
  for j:=low(aBut) to high(aBut) do KeyButDispose(@aBut[j]);
  aBut:=nil;
  DelStack;
end;

procedure TKeyLb.SetNmProc;
begin
	AddStack('TKeyLb.SetNmProc',Self);
	NmProc.Assign(Value);
  DelStack;
end;

procedure TKeyLb.NmProcChange;
begin
	AddStack('TKeyLb.NmProcChange',Self);
	SetDefKey;
  DelStack;
end;

procedure TKeyLb.SetProcKey;
begin
	AddStack('TKeyLb.SetProcKey',Self);
	FProcKey:=Value; SetDefKey;
  DelStack;
end;

procedure TKeyLb.SetDefKey;
var i: longint;
begin
	AddStack('TKeyLb.SetDefKey',Self);
	if not(csDesigning in ComponentState) then begin
    SeekKeyMenu(Self,MainMn);
    for i:=0 to FNmProc.Count-1 do SetKeySt(FNmProc[i],FProcKey,'KeyLb');
  end;
  DelStack;
end;

procedure TKeyLb.SetPlace;
begin
	AddStack('TKeyLb.SetPlace',Self);
	FSetPlace(Value,false);
  DelStack;
end;

procedure TKeyLb.FSetPlace;
var op: TRbPanelPlace;
begin
	AddStack('TKeyLb.FSetPlace',Self);
	op:=GetPlace;
	if ((Value<>op) or cng) and (Parent is TCustomRbPanel) then begin
  	TCustomRbPanel(Parent).Place:=Value;
	  if Value<>op then RePlace;
    Modified := (op in [rpTop,rpBottom]) <> (Value in [rpTop,rpBottom]);
    MainRebuild(Self);
  end;
  DelStack;
end;

procedure TKeyLb.SetButNoEval;
var tb,tb1: PKeyBut;
	i,j: longint;
begin
	AddStack('TKeyLb.SetButNoEval',Self);
  if Value then begin
  	if Length(aButNoEval)=nButNoEval then SetLength(aButNoEval,nButNoEval+1);
  	aButClear(nButNoEval); i:=0; j:=0; SetLength(aButNoEval[nButNoEval],KeyCount);
    while i<KeyCount do begin
      tb1:=Keys(i);
      if FFixKeySeek(tb1.Key,tb) and (tb1.NmParent=nmPrFixKey) then Inc(i)
      else begin
        tb:=@aButNoEval[nButNoEval,j]; tb^:=tb1^;
        if Assigned(MainMn) then begin
          tb.Pressed:=MainMn.IsPriorLine(tb.Part,tb.Key);
          if tb.Pressed then MainMn.DelLine(tb.Part,tb.Key);
        end
        else tb.Pressed:=false;
        Inc(j); DelKeyIndex(i);
      end;
    end;
    Inc(nButNoEval);
  end
  else if nButNoEval>0 then begin
  	Dec(nButNoEval);
  	for i:=low(aButNoEval[nButNoEval]) to high(aButNoEval[nButNoEval]) do with aButNoEval[nButNoEval,i] do
    	SetKey(Key,Caption,Hint,kProc,NmParent,Part,Priv);
    if Assigned(MainMn) then
	  	for i:=low(aButNoEval[nButNoEval]) to high(aButNoEval[nButNoEval]) do with aButNoEval[nButNoEval,i] do
  	  	if Pressed then MainMn.InsLine(Part,Key);
  	aButClear(nButNoEval);
  end;
  DelStack;
end;

{ Добавление клавиши по информационной строке st вида
'клавиша: [наименование] [(подсказка)]'}
function TKeyLb.SetKeySt;
var a: array[0..5] of string;
	Part: longint;
begin
	AddStack('TKeyLb.SetKeySt',Self);
  LsArrFill(st,a,UnDelim);
  if NmToKey(a[0],result) then begin
  	Part:=TKeyMenu.LatToPart(a[3]);
    if Part=kmNone then Part:=Int0(a[3]);
    if Part=0 then Part:=kmNone;
    if Assigned(MainMn) and empty(a[1]) and empty(a[2]) and (Part<>kmNone)
    then MainMn.InsLine(Part,result)
  	else SetKey(result,Trim(a[1]),Trim(a[2]),proc,nmPr,Part,Trim(a[4]),NmToKey(a[5]));
  end;
  DelStack;
end;

class function TKeyLb.GetKeySt(key: longint; const txt: string = '';
  const hnt: string = ''; Part: longint = kmNone; const Priv: string = ''; keyhelp: longint = 0): string;
begin
  AddStack('TKeyLb.GetKeySt');
  result:=ArrayAsList([KeyToNm(Key),txt,hnt,TKeyMenu.PartToLat(Part),Priv,KeyToNm(KeyHelp)],UnDelim);
  DelStack;
end;

class function TKeyLb.GetKeySt(key,keyhelp: longint): string;
begin
  result:=GetKeySt(key,'','',kmNone,'',keyhelp);
end;

class function TKeyLb.GetKeySt(const Keys: array of longint; keyhelp: longint): string;
var i: longint;
begin
  AddStack('TKeyLb.GetKeySt(a)');
  result:='';
  for i:=low(Keys) to high(Keys) do IncD(result,GetKeySt(Keys[i],'','',kmNone,'',keyhelp)+CRLF);
  DecLen(result,lCRLF);
  DelStack;
end;

class function TKeyLb.GetKeySt(const Key: TKeyBut): string;
begin
  with Key do result:=GetKeySt(Key,Caption,Hint,Part,Priv,keyhelp);
end;

procedure TKeyLb.SetKeysSt;
var a: TArrStr;
  i: longint;
begin
  AddStack('TKeyLb.SetKeysSt',Self);
  for i:=0 to LsArrDynamic(st,a,CRLF)-1 do SetKeySt(a[i],proc,nmPr);
  DelStack;
end;

function tbNoEval(tb: PKeyBut): boolean;
begin
  AddStack('KeyLb.tbNoEval');
  result := tb.NoEval or not CanPriv(tb.Priv);
  DelStack;
end;

function tbKeyEval(tb: PKeyBut; Key: longint): boolean;
begin
  AddStack('KeyLb.tbKeyEval');
  result := (tb.Key=Key) and not tbNoEval(tb);
  DelStack;
end;

// Добавление/замена клавиши
procedure TKeyLb.SetKey;
var i,j: longint;
	tb: PKeyBut;
  oCapt: string;
begin
	AddStack('TKeyLb.SetKey',Self);
	if not(csDesigning in ComponentState) then begin
    j:=KeyCount; tb:=nil;
    // Поиск совпадающей клавиши
    for i:=KeyCount-1 downto 0 do begin
      tb:=Keys(i);
      if tbKeyEval(tb,key) and (tb.nmParent=nmPr) then begin
        j:=i; break;
      end;
    end;
    // Не найдена - добавить
    if j=KeyCount then begin
      oCapt:=''; j:=KeyCount;
      if Length(aBut)=j then SetLength(aBut,j shl 1);
      tb:=@aBut[j]; Inc(KeyCount);
      tb.Visible:=false; tb.Pressed:=false; tb.Key:=key; tb.NmParent:=nmPr; tb.NoEval:=false; tb.Priv:=Priv;
    end
    else oCapt:=tb.Caption;
    tb.Caption:=txt; tb.Hint:=hnt; tb.kProc:=proc; tb.Part:=Part; tb.keyhelp:=keyhelp;
    SetMod(j,oCapt);
    // Добавление пункта меню
    if not tbNoEval(tb) then AddKeyItem(tb);
  end;
  DelStack;
end;

procedure TKeyLb.SetKeyFind;
begin
  AddStack('TKeyLb.SetKeyFind',Self);
  SetKeys(aKeyFind,'Поиск','',proc,nmpr,Part);
  if lCont then SetKey(K_Shift_F6,'','Продолжить поиск',proc,nmpr,Part);
  DelStack;
end;

procedure TKeyLb.SetKeySel;
begin
  AddStack('TKeyLb.SetKeySel',Self);
  SetKeys(keyPlus,'Отметить все','',proc,nmPr,Part,Priv);
  SetKeys(keyMinus,'Снять отм.со всех','Снять отметку со всех',proc,nmPr,Part,Priv);
  DelStack;
end;

// Удаление клавиши
procedure TKeyLb.DelKey;
var i: longint;
	tb: PKeyBut;
begin
	AddStack('TKeyLb.DelKey',Self);
  if not (csDestroying in ComponentState) then begin
    i:=0;
    while i<KeyCount do begin
      tb:=Keys(i);
      if (Empty(nmPr) or (tb.nmParent=nmPr)) and ((key=K_ALL) or (key=tb.Key))
      then DelKeyIndex(i)
      else Inc(i);
    end;
  end;
  DelStack;
end;

procedure TKeyLb.DelKeyIndex;
var j,k,p: longint;
	tb: PKeyBut;
  oCapt: string;
begin
  AddStack('TKeyLb.DelKeyIndex',Self);
  if i=CurIndex then CurIndex:=-1;
  tb:=Keys(i); oCapt:=tb.Caption; tb.Caption:=''; SetMod(i,oCapt); p:=tb.Part; k:=tb.Key;
  for j:=i+1 to KeyCount-1 do aBut[j-1]:=aBut[j];
  Dec(KeyCount); OpenHideKey(p,k);
  DelStack;
end;

class procedure TKeyLb.DelKeySt(ls: TStrings; const key: array of longint);
var i,j,k,h: longint;
  a: TArrInt;
label lend;
begin
  AddStack('TKeyLb.DelKeySt');
  CopyFromInt(a,key); h:=high(a);
  for i:=ls.Count-1 downto 0 do begin
    k:=NmToKey(DlmCopy(ls[i],1,1,UnDelim));
    for j:=0 to h do if k=a[j] then begin
      ls.Delete(i);
      if h=0 then goto lend;
      for k:=j to h-1 do a[k]:=a[k+1];
      Dec(h); break;
    end;
  end;
lend:
  DelStack;
end;

procedure TKeyLb.DelKeySt(const key: array of longint);
begin
  DelKeySt(FNmProc,key);
end;

procedure TKeyLb.DelKeys;
var i: longint;
begin
  AddStack('TKeyLb.DelKeys',Self);
  for i:=low(aKey) to high(aKey) do DelKey(aKey[i]);
  DelStack;
end;

procedure TKeyLb.DelKeyNmPr;
var i: longint;
begin
  AddStack('TKeyLb.DelKeyNmPr',Self);
  for i:=low(aNmPr) to high(aNmPr) do DelKey(K_All,aNmPr[i]);
  DelStack;
end;

procedure TKeyLb.SetMod;
var tb,tb1: PKeyBut;
	j: longint;
  lEmp: boolean;
begin
	AddStack('TKeyLb.SetMod',Self);
  if not Modified then begin
    tb:=Keys(i); Modified := (oCapt<>tb.Caption) and not tbNoEval(tb);
    if not Modified then begin
    	lEmp:=empty(tb.Caption) or tbNoEval(tb);
      for j:=0 to KeyCount-1 do if j<>i then begin
        tb1:=Keys(j);
        if (tb1.Key=tb.Key) and (empty(tb1.Caption) or tbNoEval(tb) <> lEmp) then begin
          Modified:=true; break;
        end;
      end;
    end;
  end;
  DelStack;
end;

// Открыть скрытые клавиши
procedure TKeyLb.OpenHideKey;
var i: longint;
	tb: PKeyBut;
  fl: boolean;
begin
	AddStack('TKeyLb.OpenHideKey',Self);
  if Assigned(MainMn) then begin
    fl:=true;
    for i:=KeyCount-1 downto 0 do begin
      tb:=Keys(i);
      if tbKeyEval(tb,Key) then begin
        AddKeyItem(tb); SetMod(i); fl:=false; break;
      end;
    end;
    if fl then MainMn.DelItem(Part,Key);
  end;
  DelStack;
end;

// Добавить пункт в меню
procedure TKeyLb.AddKeyItem;
begin
	AddStack('TKeyLb.AddKeyItem',Self);
  if Assigned(MainMn) then with tb^ do
  	MainMn.AddItem(Part,Key,IfThen(empty(Hint),Caption,Hint),mnClick);
  DelStack;
end;

procedure TKeyLb.mnClick;
begin
	AddStack('TKeyLb.mnClick',Self);
  FromMenu:=true;
	ExecKey(TMenuItem(Sender).Tag);
  FromMenu:=false;
  DelStack;
end;

function TKeyLb.SetWHMin;
var p: TRbPanelPlace;
	wm1: longint;
begin
	AddStack('TKeyLb.SetWHMin',Self);
	if Parent is TCustomRbPanel then begin
  	p:=GetPlace;
    if Assigned(tp) and (p<>rpNone) then begin
      tp.SetWHMin(Self,wm);
      if p in [rpTop,rpBottom] then wm1:=max(wm,tp.WMin) else wm1:=0;
    end
    else wm1:=wm;
    FReDrw(wm1,false); Repaint;
    inherited SetWHMin(tp,wm);
    result:=false;
  end
  else result:=true;
  DelStack;
end;

// Перерисовать панель клавиш
procedure TKeyLb.ReDrw;
var h,w: longint;
begin
	AddStack('TKeyLb.ReDrw',Self);
	h:=Height; w:=Width; FReDrw(w,lMod);
  if Visible and (Height<=h) and (Width<=w) then SetBounds(Left,Top,w,h);
  if (Height<>h) or (Width<>w) then MainReBuild(Self)
  else Repaint;
  DelStack;
end;

procedure TKeyLb.FReDrw;
var i,h,ws,ks,maxw: longint;
	tb: PKeyBut;
  FAlgPos: TRbPanelPlace;
  svk: string;
  fl: boolean;
begin
	AddStack('TKeyLb.FReDrw',Self);
	// Добавление обязательных клавиш
  if FirstReDrw then begin
  	FirstReDrw:=false; SetSchemForm(Self); SetDefKey;
  end;
  if not lMod or Modified then begin
    Modified:=false; WMin:=5; HMin:=5; maxw:=0; h:=0; FAlgPos:=GetPlace;
    if KeyCount<>0 then begin
    	svk:='';
      for i:=KeyCount-1 downto 0 do begin
        tb:=Keys(i); fl := GetBit(svk,tb.Key) or tbNoEval(tb);
        tb.Visible := not(fl or (tb.Caption=''));
        if tb.Visible then begin
          GetButton(Canvas,Point(0,0),tb.Caption,KeyToTxt(tb.Key),[],tb.Size,PButton^);
          SetBit(Svk,tb.Key,true); MaxSelf(maxw,tb.Size.cX); h:=tb.Size.cY;
          IncWMin(tb.Size.cX+5); IncHMin(h+5);
        end
        else if not fl then SetBit(Svk,tb.Key,true);
      end;
    end;
    if FAlgPos in [rpLeft,rpRight] then begin
      WMin:=IfThen(KeyCount=0,20,maxw+10); SetBounds(Left,Top,WMin,HMin);
    end
    else begin
      Width:=wm; WMin:=min(WMin,wm);
    end;
    ws:=5; ks:=1;
    for i:=0 to KeyCount-1 do begin
      tb:=Keys(i);
      if tb.Visible then begin
        if FAlgPos in [rpLeft,rpRight] then tb.Size.cX:=maxw;
        if ws+tb.Size.cX+5>Width then begin
          Inc(ks); ws:=5;
        end;
        tb.p.X:=ws; tb.p.Y:=5*ks+h*(ks-1); Inc(ws,tb.Size.cX+5);
      end;
    end;
    if (FAlgPos<>rpLeft) and (FAlgPos<>rpRight) then begin
      HMin:=IfThen(KeyCount=0,20,5*(ks+1)+h*ks);
      SetBounds(Left,Top,wm,HMin);
    end;
    case FAlgPos of
      rpTop: i:=2;
      rpLeft: i:=3;
      rpRight: i:=1;
    else i:=0
    end;
    PopMn.Items[i].Checked:=true;
    PopMn.Items[i].Default:=true;
    PopupMenu:=IfThen(FCanMove,PopMn);
	  if not Visible then begin
    	SetBounds(0,0,0,0); HMin:=0; WMin:=0;
    end;
  end;
  DelStack;
end;

procedure TKeyLb.Paint;
var tb: PKeyBut;
	i: longint;
  Opt: TButtonOpt;
begin
	AddStack('TKeyLb.Paint',Self);
	inherited Paint;
  if not(csDesigning in ComponentState) and FButShowing then begin
    Opt:=[butWinActive];
    for i:=0 to KeyCount-1 do begin
      tb:=Keys(i);
      if tb.Visible then begin
        if tb.Pressed then Include(Opt,butDown) else Exclude(Opt,butDown);
        GetButton(Canvas,tb.p,tb.Caption,KeyToTxt(tb.Key),Opt,tb.Size,PButton^,bm);
      end;
    end;
  end;
  DelStack;
end;

// Погасить/показать панель инструментов
procedure TKeyLb.SetButShowing;
begin
	AddStack('TKeyLb.SetButShowing',Self);
	if FButShowing<>Value then begin
	  FButShowing:=Value; Refresh;
  end;
  DelStack;
end;

function TKeyLb.FIsKeyBut;
var tb: PKeyBut;
begin
	AddStack('TKeyLb.FIsKeyBut',Self);
  result:=SeekKey(Key,tb,all);
  DelStack;
end;

{ Есть ли видимая клавиша }
function TKeyLb.IsKeyBut;
begin
	AddStack('TKeyLb.IsKeyBut',Self);
	result:=FIsKeyBut(key,false);
  DelStack;
end;

{ Есть ли клавиша }
function TKeyLb.IsAllKeyBut;
begin
	AddStack('TKeyLb.IsAllKeyBut',Self);
	result:=FIsKeyBut(key,true);
  DelStack;
end;

// Выполнить действия по клавише Key (вызов извне)
function TKeyLb.ExecKey;
var i: longint;
begin
	AddStack('TKeyLb.ExecKey',Self);
  result:=SeekKey(Key,i);
  if result then MakeKey(i);
  DelStack;
end;

function TKeyLb.SeekKey(Key: longint; var i: longint): boolean;
begin
  AddStack('TKeyLb.SeekKey',Self);
	result:=false; i:=KeyCount-1;
  while i>=0 do
    if tbKeyEval(Keys(i),Key) then begin
      result:=true; break;
    end
    else Dec(i);
  DelStack;
end;

function TKeyLb.SeekKey(Key: longint; var tb: PKeyBut; all: boolean = true): boolean;
var i: longint;
begin
  AddStack('TKeyLb.SeekKey',Self);
	result:=false;
  for i:=KeyCount-1 downto 0 do begin
    tb:=Keys(i);
    if (tb.Key=key) and (all or tb.Visible) then begin
      result:=true; break;
    end;
  end;
  DelStack;
end;

function TKeyLb.SeekKey(Key: longint; all: boolean = true): PKeyBut;
begin
  SeekKey(Key,result,all);
end;

function ActCont(f: TCustomForm): TWinControl;
begin
  AddStack('KeyLb.ActCont');
  if Assigned(f) then result:=f.ActiveControl else result:=nil;
  PointerDef(pointer(result),f);
  DelStack;
end;

procedure tbAddKeyStack(tb: PKeyBut);
begin
  with tb^ do AddKeyStack(Key,IfThen(empty(Hint),Caption,Hint));
end;

// Назначение процедур выполнения
procedure TKeyLb.MakeKey;
var fl,oPressed: boolean;
	oi: longint;
  procedure FPress(Value: boolean);
	var lRefresh: boolean;
  	tb: PKeyBut;
  begin
    AddStack('TKeyLb.MakeKey.FPress',Self);
    lRefresh:=false;
    if InRange(CurIndex,0,KeyCount-1) then begin
      tb:=Keys(CurIndex); oPressed:=tb.Pressed;
      if tb.Pressed<>Value then begin
        tb.Pressed:=Value; lRefresh:=true;
      end;
    end;
  	if fl then begin
    	if not lRefresh then lRefresh:=not ButShowing;
      ButShowing:=true;
    end;
    if lRefresh then Refresh;
    if not Value then CurIndex:=oi;
    DelStack;
  end;
var tb: PKeyBut;
begin
	AddStack('TKeyLb.MakeKey',Self);
  tb:=Keys(Index);
  with tb^ do if Assigned(kProc) then begin
    oi:=CurIndex; CurIndex:=Index; fl:=false; oPressed:=false; tbAddKeyStack(tb);
    try
      FPress(true);
      fl:=Visible;
      Kproc(Key,ActCont(curf));
    finally
      DelKeyStack; FPress(oPressed);
    end;
  end;
  DelStack;
end;

procedure TKeyLb.FormKeyDown;
begin
	AddStack('TKeyLb.FormKeyDown',Self);
  if GetKeyCod(Key,Shift,KeyActive) then begin
    NoEval:=false;
    if ExecKey(KeyActive) and not NoEval then Key:=0;
  end;
  DelStack;
end;

procedure TKeyLb.FormKeyUp;
begin
  KeyActive:=0;
end;

{ Перемещение панели из меню }
procedure TKeyLb.LbMove;
begin
	AddStack('TKeyLb.LbMove',Self);
	case TMenuItem(Sender).Tag of
		1: SetPlace(rpRight);
		2: SetPlace(rpTop);
		3: SetPlace(rpLeft);
	else SetPlace(rpBottom)
	end;
  DelStack;
end;

{ Перемещение панели мышкой }
procedure TKeyLb.MouseDown;
begin
	AddStack('TKeyLb.MouseDown',Self);
	inherited MouseDown(Button,Shift,X,Y);
	if Button=mbLeft then
    if ActiveBut>=0 then MakeKey(ActiveBut)
    else if not Moving and FCanMove then begin
      Moving:=true; oL:=Left; oT:=Top; PopupMenu:=nil;
      RszMouseDown(Self,Button,Shift,X,Y,[rmRemove]);
    end;
  DelStack;
end;

procedure TKeyLb.MouseMove;
var i: longint;
	tb: PKeyBut;
label lend;
begin
	AddStack('TKeyLb.MouseMove',Self);
	inherited MouseMove(Shift,X,Y);
	if Moving then RszMouseMove(Self,Shift,X,Y,[rmRemove])
  else begin
    for i:=0 to KeyCount-1 do begin
			tb:=Keys(i);
      if not tb.Visible or tb.NoEval then continue;
      if (X<tb.p.X) or (X>tb.p.X+tb.Size.cX)
      or (Y<tb.p.Y) or (Y>tb.p.Y+tb.Size.cY)
      then continue;
      Cursor:=crHandPoint; ActiveBut:=i; Hint:=tb.Hint;
      ShowHint := not empty(Hint);
      goto lend;
    end;
    Cursor:=IfThen(FCanMove,crDrag,crDefault);
  	ActiveBut:=-1; Hint:=''; ShowHint:=false;
  end;
lend:
	DelStack;
end;

procedure TKeyLb.MouseUp;
begin
	AddStack('TKeyLb.MouseUp',Self);
	inherited MouseUp(Button,Shift,X,Y);
	if Button=mbLeft then begin
   	if Moving then begin
    	RszMouseUp(Self,Button,Shift,X,Y,[rmRemove]);
   		if (oL<>Left) or (oT<>Top) then FSetPlace(GetNewParentPlace(GetPlace,X,Y),true);
			Moving:=false;
    end;
   	if FCanMove and Assigned(PopMn) then PopupMenu:=PopMn;
	end;
  DelStack;
end;

procedure TKeyLb.WMSchem;
begin
  AddStack('TKeyLb.WMSchem',Self);
	inherited;
	Color:=PButton.aColor[btfHotKey]; bm.Canvas.Brush.Color:=Color;
  bm.Canvas.Pen.Color:=Color; Modified:=true;
  DelStack;
end;

procedure TKeyLb.WMCngPriv;
begin
	AddStack('TKeyLb.WMCngPriv',Self);
  SetButNoEval(true); SetButNoEval(false); ReDrw;
  DelStack;
end;

procedure TKeyLb.WMSaveIni;
var Section: string;
begin
	AddStack('TKeyLb.WMSaveIni',Self);
	Section:=Msg.pSection^;
  if Section<>'' then 
    if FormKeyLb(curf)=Self then with InitFIni[fiSave] do case Msg.Oper of
      opsSave: begin
        WriteInteger(Section,'KeyLbPlace',byte(GetPlace));
        if LsKeyLb[0]=Self then WriteBool('KeyLb','AllVisible',AllVisible);
      end;
      opsRest: begin
        SetPlace(TRbPanelPlace(EnsureRange(ReadInteger(Section,'KeyLbPlace',byte(GetPlace)),
          byte(low(TRbPanelPlace)),byte(high(TRbPanelPlace)))));
        if LsKeyLb[0]=Self then begin
          Visible:=ReadBool('KeyLb','AllVisible',true); AllVisible:=Visible;
        end;
      end;
    end;
  DelStack;
end;

procedure TKeyLb.WMKeyInitProg;
var i: longint;
begin
	AddStack('TKeyLb.WMKeyInitProg',Self);
  with Msg do
    if lExec then ExecKey(Key)
    else if SeekKey(Key,i) then result:=1;
  DelStack;
end;

procedure TKeyLb.WMHelpFill;
var i,j,l,lo,ln: longint;
	tb: PKeyBut;
  svk: string;
  an,aun: TArrInt;
  fl: boolean;
begin
  AddStack('TKeyLb.WMHelpFill',Self);
  if CanFocus then with Msg do case Oper of
    hlpAdd: begin
      lo:=Length(pArr^); ln:=0; svk:=''; SetLength(an,KeyCount);
      for i:=KeyCount-1 downto 0 do begin
        tb:=Keys(i);
        if not(tbNoEval(tb) or empty(tb.Caption) and empty(tb.Hint) and (tb.keyhelp=0) or GetBit(svk,tb.Key)) then begin
          SetBit(svk,tb.Key,true);
          if not HelpFindAvk(pArr^,tb.Key,j) then begin
            an[ln]:=i; Inc(ln);
          end;
        end;
      end;
      SetLength(pArr^,lo+ln); SetLength(aun,ln); j:=0;
      for i:=ln-1 downto 0 do begin
        tb:=Keys(an[i]); aun[j]:=tb.keyhelp;
        with pArr^[lo+j] do begin
          part:=KeyToTxt(tb.Key); txt:=IfThen(tb.Hint='',tb.Caption,tb.Hint); CopyFromVArr(avk,[tb.Key]);
        end;
        Inc(j);
      end;
      l:=lo;
      for j:=low(aun) to high(aun) do begin
        fl:=false;
        if aun[j]<>0 then for i:=lo to lo+ln-1 do with pArr^[i] do if avk[0]=aun[j] then begin
          IncD(part,','+pArr^[l].part); AddFromVArr(avk,pArr^[l].avk); fl:=true; break;
        end;
        if fl then begin
          for i:=l+1 to lo+ln-1 do pArr^[i-1]:=pArr^[i];
          Dec(ln);
        end
        else Inc(l);
      end;
      SetLength(pArr^,l);
      ln:=0;
      for i:=lo to l-1 do MaxSelf(ln,pArr^[i].part);
      Inc(ln);
      for i:=lo to l-1 do with pArr^[i] do PadRSelf(part,ln);
    end;
    hlpFillType: ResFillType:=hlpftAfter;
    hlpLinkObj: pLinkObj^:='прочие клавиши';
  end;
  DelStack;
end;

procedure TKeyLb.RePlace;
begin
	AddStack('TKeyLb.RePlace',Self);
	IfThenNotify(FOnRePlace,Self);
  DelStack;
end;

// Установка клавиш с пустой подсказкой
procedure TKeyLb.SetKeys;
var i,keyhelp: longint;
begin
  AddStack('TKeyLb.SetKeys');
  keyhelp:=Keys[0]; SetKey(keyhelp,txt,hnt,proc,nmPr,Part,Priv);
  if empty(txt) and empty(hnt) then keyhelp:=0;
  for i:=1 to high(Keys) do SetKey(Keys[i],'','',proc,nmPr,kmNone,Priv,keyhelp);
  DelStack;
end;

procedure TKeyLb.SetKeyBut(const Key: array of TKeyBut);
begin
  SetKeyBut(Key,FNmProc);
end;

procedure TKeyLb.SetKeyBut(const Key: array of TKeyBut; proc: TKeyProc; const nmPr: string; lSet: boolean = true);
var i: longint;
begin
  AddStack('TKeyLb.SetKeyBut',Self);
  for i:=low(Key) to high(Key) do with Key[i] do
    if lSet then SetKey(Key,Caption,Hint,proc,nmPr,Part,Priv,keyhelp) else DelKey(Key,nmPr);
  DelStack;
end;

class procedure TKeyLb.SetKeyBut(const Key: array of TKeyBut; ls: TStrings);
var i: longint;
begin
  AddStack('TKeyLb.SetKeyBut(ls)');
  for i:=low(Key) to high(Key) do with Key[i] do ls.Add(GetKeySt(Key,Caption,Hint,Part,Priv,keyhelp));
  DelStack;
end;

// Нажать/отпустить клавишу
procedure TKeyLb.Press;
var i: longint;
	tb: PKeyBut;
begin
	AddStack('TKeyLb.Press',Self);
  if SeekKey(Key,i) then begin
  	tb:=Keys(i);
    if tb.Pressed<>Value then begin
      tb.Pressed:=Value; Refresh;
    end;
  end;
  DelStack;
end;

// Добавить фиксированную клавишу
class procedure TKeyLb.SetFixKey;
var tb: PKeyBut;
	n: longint;
begin
	AddStack('TKeyLb.SetFixKey');
	if not Assigned(LsFixKey) then begin
    LsFixKey:=TIntegerList.Create([ilsSorted]); SetLength(aFixKey,10);
  end;
  if LsFixKey.IntObjFindAdd(Key,n) then tb:=@aFixKey[n]
  else begin
    if Length(aFixKey)=n then SetLength(aFixKey,n shl 1);
    tb:=@aFixKey[n]; tb.Key:=Key; tb.NoEval:=false;
  end;
  tb.Part:=Part; tb.Hint:=Hnt; tb.kProc:=Proc; FixKeyUpdate(tb);
  DelStack;
end;

class procedure TKeyLb.SetFixKeyVisible;
begin
  AddStack('TKeyLb.SetFixKeyVisible');
  SetFixKey(KeyAllVisible,IfThen(AllVisible,'Скрыть','Показать')+' панель клавиш',
  	PrFixKeyVisible,kmHelp);
  DelStack;
end;

class procedure TKeyLb.LbVisible;
begin
	AddStack('TKeyLb.LbVisible');
  PrFixKeyVisible(0,nil);
  DelStack;
end;

class procedure TKeyLb.PrFixKeyVisible;
var i: longint;
	tl: TKeyLb;
  f: TCustomForm;
begin
	AddStack('TKeyLb.PrFixKeyVisible');
  if IfThenAsk(AllVisible,['Скрыть панель клавиш ?']) then begin
    NotD(AllVisible);
    if Assigned(LsKeyLb) then for i:=0 to lsKeyLb.Count-1 do begin
      tl:=pointer(lsKeyLb[i]); tl.Modified:=true; tl.Visible:=AllVisible; f:=GetParentForm(tl);
      if Assigned(f) then begin
        f.Perform(WM_KEYLBVISIBLE,0,0); MainRebuild(f);
      end;
      SetFixKeyVisible;
    end;
  end;
  DelStack;
end;

procedure TKeyLb.FSetFixKey;
begin
	AddStack('TKeyLb.FSetFixKey',Self);
  with tb^ do
  	if tbNoEval(tb)
    then DelKey(Key,nmPrFixKey)
    else SetKey(Key,'',Hint,kProc,nmPrFixKey,Part);
  DelStack;
end;

procedure TKeyLb.CreateFixKey;
var i: longint;
begin
  AddStack('TKeyLb.CreateFixKey');
  if Assigned(LsFixKey) then
    for i:=0 to LsFixKey.Count-1 do FSetFixKey(@aFixKey[LsFixKey.IntObj(i)]);
  DelStack;
end;

// Скрыть фиксированную клавишу
class function TKeyLb.FixKeyShow;
var tb: PKeyBut;
begin
	AddStack('TKeyLb.FixKeyShow');
	result:=FFixKeySeek(Key,tb);
  if result then begin
    result := not tbNoEval(tb); tb.NoEval := not lShow;
    if tbNoEval(tb)=result then FixKeyUpdate(tb);
  end;
  DelStack;
end;

class function TKeyLb.ExecFixKey;
var tb: PKeyBut;
begin
  AddStack('TKeyLb.ExecFixKey');
	result:=false;
  if FixKeySeek(Key,tb) then begin
    tbAddKeyStack(tb);
    try
      tb.kProc(Key,ActCont(LastForm)); result:=true;
    finally
      DelKeyStack;
    end;
  end;
  DelStack;
end;

class function TKeyLb.FixKeySeek(Key: longint): boolean;
var tb: PKeyBut;
begin
  result:=FixKeySeek(Key,tb);
end;

class function TKeyLb.FixKeySeek(Key: longint; var tb: PKeyBut): boolean;
begin
  AddStack('TKeyLb.FixKeySeek');
  if FFixKeySeek(Key,tb) then result := not tbNoEval(tb) else result:=false;
  DelStack;
end;

function TKeyLb.Keys;
begin
  result:=@aBut[Index];
end;

function AllocMemStr: string;
begin
  result:=Format('AllocMemCount=%d  AllocMemSize=%d',[AllocMemCount,AllocMemSize]);
end;

procedure AllocMemTimer(h: HWND; uMsg: UINT; idEvent: UINT; dwTime: longword); stdcall;
var dc: HDC;
  hdw: HWND;
  s: string;
begin
  hdw:=GetDesktopWindow;
  dc:=GetWindowDC(0);
  try
    if dc<>0 then begin
      s:=AllocMemStr; TextOut(dc,0,0,PChar(s),length(s));
    end;
  finally
    ReleaseDC(hdw,dc);
  end;
end;

class procedure TKeyLb.FixKeyProc;
  procedure MsgHide(lDbg: boolean; const ms: string);
  var omsAll,oms: boolean;
  begin
    AddStack('TKeyLb.FixKeyProc.MsgHide');
    omsAll := false in MessagesOkHidden; oms := lDbg in MessagesOkHidden; Exclude(MessagesOkHidden,false);
    meserr('Вывод '+ms+'сообщений на экран '+IfThen(oms,'включён','выключен')+'.');
    SetSet(MessagesOkHidden,false,omsAll);
    SetSet(MessagesOkHidden,lDbg,not oms);
    DelStack;
  end;
var nGG: longint;
  fn,s: string;
begin
  AddStack('TKeyLb.FixKeyProc');
  FixKeyShow(Key,false);
  case Key of
    K_Alt_J,K_Alt_M: begin
      fn:=ExeDir+'ALLOCMEM.TXT';
      if tid=0 then tid:=SetTimer(0,0,500,@AllocMemTimer)
      else if Key=K_Alt_M then begin
        KillTimer(0,tid); tid:=0;
        if FileExists(fn) then begin
          EdTextView('Протокол используемой памяти',GetStrFile(fn),'',nil,[],edtpText,0,0,'',0,nil,'',nil,nil,fn);
          DelFileAtr(fn);
        end;
      end;
      if Key=K_Alt_J then begin
        if FileExists(fn) then s:=GetStrFile(fn)+CRLF else s:='';
        SetStrFile(fn,s+AllocMemStr);
      end;
    end;
    K_Alt_O: MsgHide(true,'отладочных ');
    K_Alt_S: MsgHide(false,'');
    K_Alt_Plus,K_Alt_Minus: if CanPriv(PrivDesign) then begin
      nGG:=GetUserGG+aSign[Key=K_Alt_Minus];
      if Ask([Format('Установить уровень разработки %d ?',[nGG])]) then SetUserGG(nGG);
    end;
  end;
  FixKeyShow(Key,true);
  DelStack;
end;

class procedure TKeyLb.ProcNone;
begin
end;

procedure Register;
begin
  RegisterComponents('OurLib',[TKeyLb]);
end;

initialization
	AddStack('KeyLb.initialization');
  bm:=TBitMap.Create;
  with TKeyLb do begin
    SetFixKey(K_Alt_M,'Используемая память',FixKeyProc,kmDesign);
    SetFixKey(K_Alt_J,'Сохранить информацию об используемой памяти в протокол',FixKeyProc,kmDesign);
    SetFixKey(K_Alt_S,'Включить/выключить вывод сообщений',FixKeyProc,kmDesign);
    SetFixKey(K_Alt_O,'Включить/выключить вывод отладочных сообщений',FixKeyProc,kmDesign);
    SetFixKey(K_Alt_Plus,'Увеличить уровень разработки',FixKeyProc,kmDesign);
    SetFixKey(K_Alt_Minus,'Уменьшить уровень разработки',FixKeyProc,kmDesign);
    sMDKey:=GetKeySt(K_F7,'Основа','Формула, загруженная из основы',kmFile);
  end;
  DelStack;
finalization
  AddStack('KeyLb.finalization');
  bm.Free; LsFixKey.Free;
  DelStack;
end.
