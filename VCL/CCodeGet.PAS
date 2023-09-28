unit CCodeGet;

interface

{$I LIBTEST}
uses Windows,Messages,Classes,Controls,
  MyTypes,FFldEdit,PaintCtl,ListF2,FldMask;

type
 	TCustomListGet = class(TCustomGet)
 	private
  { Private declarations }
  	FOnMouseMove: TMouseMoveEvent;
  	FOnRowMove: TRowMoveEvent;
    class procedure DownClick(Sender: TObject);
		procedure ProcKey(key: longint; tw: TWinControl);
  protected
  { Protected declarations }
    sD: TPaintButton;
    FOnListOwner: TListOwnerEvent;
    FOnAfterList: TNotifyEvent;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function AssignObj(tf: TFldEdit): boolean; override;
    class function CountBut(tf: TFldEdit): longint;
    procedure ListOwner(tf: TFldEdit); dynamic;
    procedure StdListDown(tf: TFldEdit; const RectList: TRect;
	    PozList: TPozList); virtual; abstract;
  public
  { Public declarations }
    procedure Assign(Source: TPersistent); override;
  	class function DDatSupport: boolean; override;
		procedure AfterList; dynamic;
  published
  { Published declarations }
	 	property OnAfterList: TNotifyEvent read FOnAfterList write FOnAfterList;
	 	property OnListOwner: TListOwnerEvent read FOnListOwner write FOnListOwner;
	 	property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
	 	property OnRowMove: TRowMoveEvent read FOnRowMove write FOnRowMove;
 	end;

  TSizeAutoEvent = procedure(Sender: TObject; tf: TFldEdit; Opt: TFESizeAutoOpt; var result: TSize) of object;
  TMinWidthCodeEvent = procedure(Sender: TObject; var result: longint) of object;

 	TCustomCodeGet = class(TCustomListGet)
 	private
  { Private declarations }
	 	FLenCode: longint;
	 	FLenName: longint;
    FOnAfterMinWidthCode: TMinWidthCodeEvent;
    FOnSizeAuto: TSizeAutoEvent;
   	procedure SetLenCode(v: longint);
   	procedure SetLenName(v: longint);
 	protected
  { Protected declarations }
    eC,eN: TFldMask;
	 	FDefLenCode: longint;
	 	FDefLenName: longint;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
		procedure Paint(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    function Check(tf: TFldEdit): boolean; override;
    function AssignObj(tf: TFldEdit): boolean; override;
    procedure SetDefLenCode; virtual;
    procedure SetDefLenName; virtual;
		function GetDefLenCode(const Mask: string): longint; virtual;
		function GetDefLenName(const Mask: string): longint; virtual;
		function DWFldUnAllowType(const Mask: string): TDWFldSetType; override;
		procedure HookProc(tf: TFldEdit; var Message: TMessage); override;
		function SelProcKey(tf: TFldEdit; Proc: TSelProcKey): boolean; override;
		function MinWidthCode(tf: TFldEdit): longint; virtual;
		function MinWidthName(tf: TFldEdit): longint; virtual;
		procedure AfterMinWidthCode(tf: TFldEdit; var result: longint); virtual;
    property LenCode: longint read FLenCode write SetLenCode;
    property LenName: longint read FLenName write SetLenName;
    property OnSizeAuto: TSizeAutoEvent read FOnSizeAuto write FOnSizeAuto;
 	public
  { Public declarations }
		procedure DWFldValid(const ap: TDEPrmStr; const dwInf: TDWVidRec;
    	var nFldFocus: TDEPrmList; var nVarFocus: TVarParam; var amsg: TArrStr); override;
	 	property DefLenName: longint read FDefLenName;
  published
  { Published declarations }
    property OnAfterMinWidthCode: TMinWidthCodeEvent read FOnAfterMinWidthCode write FOnAfterMinWidthCode;
  { Унаследованные }
   	property RVid;
   	property RVName;
   	property VName;
 	end;

implementation

uses Math,StrUtils,Graphics,Forms,
  My_pr,KeyLb,KeyMenu,Schem;

{ TCustomListGet }

// Создать объекты
procedure TCustomListGet.CreateObj;
begin
	AddStack('TCustomListGet.CreateObj',Self);
	DestroyObj(tf); tf.DynButCreate;
  sD:=TPaintButton.Create(tf);
  with sD do begin
    Canvas:=tf.Canvas; AllowAllUp:=true; Hint:='Список'; ShowHint:=true; BMByName(Glyph,bmDown);
    Tag:=1; onClick:=DownClick;
  end;
  DelStack;
end;

procedure TCustomListGet.ReCreateObj;
begin
	AddStack('TCustomListGet.ReCreateObj',Self);
	if AssignObj(tf) then begin
    sD.Visible := tf.Visible and not Assigned(bDyn) and (tf.Enabled or (tf.CharWidth=0));
  	inherited ReCreateObj(tf);
  end;
  DelStack;
end;

{ Поиск объектов }
function TCustomListGet.AssignObj;
var i: longint;
begin
	AddStack('TCustomListGet.AssignObj',Self);
	sD:=nil; result:=false;
  if inherited AssignObj(tf) then with tf do for i:=0 to ComponentCount-1 do
    if Components[i].Tag=1 then if IsClass(Components[i],TPaintButton,pointer(sD)) then begin
      result:=true; break;
    end;
  DelStack;
end;

{ Кол-во SpeedButton-ов }
class function TCustomListGet.CountBut;
var i: longint;
  pb: TPaintButton;
begin
	AddStack('TCustomListGet.CountBut');
	result:=0;
  for i:=0 to tf.ComponentCount-1 do if IsClass(tf.Components[i],TPaintButton,pointer(pb)) then
    if pb.Visible then Inc(result);
  DelStack;
end;

{ Вызов списка по SpeedButton }
class procedure TCustomListGet.DownClick;
var tf: TFldEdit;
	tl: TKeyLb;
begin
	AddStack('TCustomListGet.DownClick');
	tf:=pointer(TPaintButton(Sender).Owner);
  if not tf.Active then tf.SetFocus;
  if FormKeyLb(tf,tl) then tl.ExecKey(K_F2);
  DelStack;
end;

{ Действия при получении фокуса }
procedure TCustomListGet.DoEnter;
var tl: TKeyLb;
	MainMn: TKeyMenu;
begin
	AddStack('TCustomListGet.DoEnter',Self);
  inherited DoEnter(tf);
	if AssignObj(tf) then
    if FormKeyLb(tf,tl) and not((ogReadOnly in tf.Options) or Assigned(bDyn)) then begin
      tl.SetKeys(aKeyListDown,sD.Hint,'',ProcKey,'custlistget',kmEdit); 
      if SeekKeyMenu(tf,MainMn) then MainMn.InsLine(kmEdit,K_F2);
    end;
  DelStack;
end;

{ Действия при утере фокуса }
procedure TCustomListGet.DoExit;
var tl: TKeyLb;
	MainMn: TKeyMenu;
begin
	AddStack('TCustomListGet.DoExit',Self);
  if SeekKeyMenu(tf,MainMn) then MainMn.DelLine(kmEdit,K_F2);
  if FormKeyLb(tf,tl) then begin
  	tl.DelKey(K_All,'custlistget'); tl.ReDrw;
  end;
  inherited DoExit(tf);
  DelStack;
end;

procedure TCustomListGet.ProcKey;
var tf: TFldEdit;
begin
	AddStack('TCustomListGet.ProcKey',Self);
	tf:=GetOwnerFldEdit(tw);
	if AssignObj(tf) then begin
    if not(ogReadOnly in tf.Options) then begin
      sD.Down:=true; ListOwner(tf);
    end;
    if AssignObj(tf) then sD.Down:=false;
  end;
  DelStack;
end;

{ Вызов выпадающего списка }
procedure TCustomListGet.ListOwner;
var RectList: TRect;
	PozList: TPozList;
  p: TPoint;
  pr: TRect;
  own: boolean;
begin
	AddStack('TCustomListGet.ListOwner',Self);
	if AssignObj(tf) then begin
    p:=tf.ClientOrigin; pr:=SysWorkArea;
    if pr.Bottom-pr.Top-p.Y-tf.Height<p.Y then begin
      RectList:=Rect(p.X+BevelFld,pr.Top,p.X+tf.Width-BevelFld,p.Y+BevelFld);
      PozList:=plUp;
    end
    else begin
      RectList:=Rect(p.X+BevelFld,p.Y+tf.Height-BevelFld,p.X+tf.Width-BevelFld,pr.Bottom);
      PozList:=plDown;
    end;
    own:=Assigned(FOnListOwner);
    if own then own:=FOnListOwner(tf,sD,RectList,PozList);
    if not own then StdListDown(tf,RectList,PozList);
    AfterList;
  end;
  DelStack;
end;

procedure TCustomListGet.AfterList;
begin
  AddStack('TCustomListGet.AfterList',Self);
  IfThenNotify(FOnAfterList,Self);
  DelStack;
end;

procedure TCustomListGet.Assign;
begin
	AddStack('TCustomListGet.Assign',Self);
  if Source is TCustomListGet
  then OnListOwner:=TCustomListGet(Source).OnListOwner;
	inherited Assign(Source);
  DelStack;
end;

class function TCustomListGet.DDatSupport;
begin
  result:=true;
end;

{ TCustomCodeGet }
procedure TCustomCodeGet.SetLenCode;
var fl: boolean;
begin
	AddStack('TCustomCodeGet.SetLenCode',Self);
	fl := v<>FLenCode;
  if fl then FLenCode:=v;
  SetDefLenCode;
  if fl then UpdateAllFld(mgReCreate);
  DelStack;
end;

procedure TCustomCodeGet.SetLenName;
var fl: boolean;
begin
	AddStack('TCustomCodeGet.SetLenName',Self);
	fl := v<>FLenName;
  if fl then FLenName:=v;
  SetDefLenName;
  if fl then UpdateAllFld(mgReCreate);
  DelStack;
end;

{ Длина кода по умолчанию }
procedure TCustomCodeGet.SetDefLenCode;
begin
	AddStack('TCustomCodeGet.SetDefLenCode',Self);
  FDefLenCode:=FLenCode;
  DelStack;
end;

{ Длина наименования по умолчанию }
procedure TCustomCodeGet.SetDefLenName;
begin
	AddStack('TCustomCodeGet.SetDefLenName',Self);
  FDefLenName:=FLenName;
  DelStack;
end;

function TCustomCodeGet.GetDefLenCode;
begin
  AddStack('TCustomCodeGet.GetDefLenCode',Self);
	result:=FDefLenCode;
  DelStack;
end;

function TCustomCodeGet.GetDefLenName;
begin
	AddStack('TCustomCodeGet.GetDefLenName',Self);
	result:=FDefLenName;
  DelStack;
end;

procedure TCustomCodeGet.DWFldValid;
	procedure Chk1(l,l1: longint; const nm: string);
  begin
		AddStack('TCustomCodeGet.DWFldValid.Chk1',Self);
    if l>l1 then begin
    	AddFrom(amsg,[BracketInt('Длина поля, необходимая для ввода '+nm,l),
      	BracketInt('превышает длину '+IfThen(l1<>dwInf.Len,'целой части ')+'данного',l1)+'.']);
      nFldFocus:=deNameRecFld;
    end;
    DelStack;
  end;
var lc: longint;
begin
	AddStack('TCustomCodeGet.DWFldValid',Self);
  inherited DWFldValid(ap,dwInf,nFldFocus,nVarFocus,amsg);
  if (Length(amsg)=0) and not IsDWFldMemo(dwInf.AType) then begin
    lc:=GetDefLenCode(ap[deMask]);
  	if lc=0
    then Chk1(GetDefLenName(ap[deMask]),dwInf.Len,'наименования')
    else Chk1(lc,LenInt(dwInf.Len,dwInf.Dec),'кода');
  end;
  DelStack;
end;

function TCustomCodeGet.DWFldUnAllowType;
begin
	AddStack('TCustomCodeGet.DWFldUnAllowType',Self);
  result:=[dwtDate,dwtBool,dwtArray,dwtSel];
  if GetDefLenCode(Mask)=0 then Include(result,dwtFloat);
  DelStack;
end;

procedure TCustomCodeGet.HookProc;
  function eChr(e: TFldMask): boolean;
  begin
    AddStack('TCustomCodeGet.HookProc.eChr',Self);
    result := e.Visible and e.Enabled and not e.ReadOnly;
    if result then with TWMChar(Message) do
      Result:=e.Perform(WM_CHAR,CharCode,KeyData);
    DelStack;
  end;
begin
	AddStack('TCustomCodeGet.HookProc',Self);
  inherited HookProc(tf,Message);
  if Message.Msg=WM_CHAR then
    if AssignObj(tf) then
      if not Assigned(bDyn) then
        if not eChr(eC) then eChr(eN);
  DelStack;
end;

function TCustomCodeGet.SelProcKey;
begin
  AddStack('TCustomCodeGet.SelProcKey',Self);
	result := inherited SelProcKey(tf,Proc);
  if AssignObj(tf) then if not eC.Visible then result:=eN.SelProcKey(Proc);
  DelStack;
end;

{ Создать объекты }
procedure TCustomCodeGet.CreateObj;
begin
	AddStack('TCustomCodeGet.CreateObj',Self);
  inherited CreateObj(tf);
  if inherited AssignObj(tf) then begin
    sD.Canvas:=tf.Canvas;
    eC:=TFldMask.Create(tf); //tf.SetRdw(eC);
    with eC do begin
      Parent:=tf; AutoSize:=false; Color:=clWindow; TabStop:=false; BorderStyle:=bsNone;
      onClick:=tf.EdClick;
      onDblClick:=tf.EdDblClick;
      onKeyDown:=tf.EdKeyDown;
      onKeyPress:=tf.EdKeyPress;
      onKeyUp:=tf.EdKeyUp;
      onMouseDown:=tf.EdMouseDown;
      onMouseMove:=tf.EdMouseMove;
      onMouseUp:=tf.EdMouseUp;
    end;
    eN:=TFldMask.Create(tf); //tf.SetRdw(eN);
    with eN do begin
      Parent:=tf; AutoSize:=false; Color:=clWindow; TabStop:=false; BorderStyle:=bsNone;
      onClick:=tf.EdClick;
      onDblClick:=tf.EdDblClick;
      onKeyDown:=tf.EdKeyDown;
      onKeyPress:=tf.EdKeyPress;
      onKeyUp:=tf.EdKeyUp;
      onMouseDown:=tf.EdMouseDown;
      onMouseMove:=tf.EdMouseMove;
      onMouseUp:=tf.EdMouseUp;
    end;
    tf.ReCreateObj;
  end;
  DelStack;
end;

{ Переустановить свойства объектов }
procedure TCustomCodeGet.ReCreateObj;
begin
	AddStack('TCustomCodeGet.ReCreateObj',Self);
	if AssignObj(tf) then begin
    eC.CharCase:=tf.CharCase; eN.CharCase:=tf.CharCase;
    inherited ReCreateObj(tf);
    eC.SelStart:=0; eC.SelLength:=0; eN.SelStart:=0; eN.SelLength:=0;
  end;
  DelStack;
end;

{ Нарисовать объекты }
procedure TCustomCodeGet.PaintObj;
var t,h,r: longint;
  dsz: TSize;
	procedure sb1(sb: TPaintButton);
	var w: longint;
  begin
    AddStack('TCustomCodeGet.PaintObj.sb1',Self);
    if sb.Visible then begin
      w:=max(dsz.cX,sb.Glyph.Width+3);
      Dec(r,w); sb.SetBounds(r,t,w,h);
    end
    else sb.SetBounds(0,0,0,0);
    DelStack;
  end;
var i,l: longint;
	sb: TPaintButton;
	ts: TSchem;
  dcsz: TSize;
begin
	AddStack('TCustomCodeGet.PaintObj',Self);
	if AssignObj(tf) then with tf do begin
    if csDesigning in ComponentState then ts:=nil else SchemName(Schem,ts);
    eC.Color:=Color1(ts); eN.Color:=eC.Color;
    if Assigned(ts) then with ts do begin
      eN.Font.Assign(Font1); eC.Font.Assign(Font1);
    end;
    dsz:=DynButSize; Canvas.Font.Assign(eC.Font); h:=max(CanvasMaxH(Canvas)+4,dsz.cY);
    dcsz:=tf.DynCaptSize(h); MaxSelf(h,dcsz.cY);
    t:=Height-BevelFld-h; l:=BevelFld+dcsz.cX; r:=Width-BevelFld;
    if Assigned(bDyn) then sb1(bDyn)
    else begin
      dsz.cX:=SysMetric.iScrollWidth; sb1(sD);
    end;
    for i:=ComponentCount-1 downto 0 do if IsClass(Components[i],TPaintButton,pointer(sb)) then begin
      if sb=bDyn then continue;
      if sb=sD then continue;
      sb1(sb);
    end;
    if eC.Visible then begin
      Canvas.Font.Assign(eC.Font);
      eC.SetBounds(l+2,t+2,MinWidthCode(tf)+2,h-4); Inc(l,eC.Width+4);
      if eN.Visible then Dec(l,1);
    end
    else eC.SetBounds(0,0,0,0);
    if eN.Visible then eN.SetBounds(l+2,t+2,r-l-4,h-4) else eN.SetBounds(0,0,0,0);
  end;
  DelStack;
end;

procedure TCustomCodeGet.Paint;
begin
  AddStack('TCustomCodeGet.Paint',Self);
  if AssignObj(tf) then begin
    tf.FldMaskBorder(eC); tf.FldMaskBorder(eN);
  end;
  DelStack;
end;

{ Автоматическая установка размеров }
function TCustomCodeGet.SizeAuto;
var i,h,w,c,hC,hN: longint;
	ts: TSchem;
  dsz,dcsz: TSize;
  pb: TPaintButton;
begin
	AddStack('TCustomCodeGet.SizeAuto',Self);
  if tf.CharWidth<0 then Exclude(Opt,tfszWidth);
	result := inherited SizeAuto(tf,Opt);
	if AssignObj(tf) then with tf do begin
    if not(csDesigning in ComponentState) then
      if SchemName(Schem,ts) then with ts do begin
        eN.Font.Assign(Font1); eC.Font.Assign(Font1);
      end;
   	h:=0; hC:=0; hN:=0; w:=0;
    if eC.Visible then begin
    	Canvas.Font.Assign(eC.Font); hC:=CanvasMaxH(Canvas)+4; Inc(w,MinWidthCode(tf)+6);
      if eN.Visible then Dec(w,1);
    end;
    if eN.Visible then begin
      Canvas.Font.Assign(eN.Font); hN:=CanvasMaxH(Canvas)+4; Inc(w,MinWidthName(tf)+6);
    end;
    Canvas.Font.Assign(Font);
    if Opt<>[] then begin
      dsz:=DynButSize; h:=MaxIntValue([hC,hN,dsz.cY]); dcsz:=tf.DynCaptSize(h);
    end;
    if tfszHeight in Opt then begin
	    MaxSelf(h,dcsz.cY); result.cY:=IfThen(h=0,15,h);
    end;
    if tfszWidth in Opt then begin
      c:=SysMetric.iScrollWidth;
      for i:=0 to tf.ComponentCount-1 do
        if IsClass(tf.Components[i],TPaintButton,pointer(pb)) then if pb<>bDyn then
          if pb.Visible then Inc(w,max(c,pb.Glyph.Width+3));
      result.cX:=w+dsz.cX+dcsz.cX;
    end;
  end;
  if Assigned(FOnSizeAuto) then FOnSizeAuto(Self,tf,Opt,result);
  DelStack;
end;

function TCustomCodeGet.MinWidthCode;
begin
  AddStack('TCustomCodeGet.MinWidthCode',Self);
  result:=CanvasMaxW(tf.Canvas)*{max(2,}GetDefLenCode(tf.Mask){)};
  AfterMinWidthCode(tf,result);
  DelStack;
end;

procedure TCustomCodeGet.AfterMinWidthCode;
begin
  AddStack('TCustomCodeGet.AfterMinWidthCode',Self);
  if Assigned(FOnAfterMinWidthCode) then FOnAfterMinWidthCode(tf,result);
  DelStack;
end;

function TCustomCodeGet.MinWidthName;
begin
  AddStack('TCustomCodeGet.MinWidthName',Self);
  result:=CanvasMaxW(tf.Canvas)*{max(2,}GetDefLenName(tf.Mask){)};
  DelStack;
end;

function TCustomCodeGet.Check;
begin
	AddStack('TCustomCodeGet.Check',Self);
  result := inherited Check(tf);
  if result then
    if AssignObj(tf) then begin
      if eC.Visible then result:=eC.Check;
      if result and eN.Visible then result:=eN.Check;
    end;
  DelStack;
end;

{ Поиск объектов }
function TCustomCodeGet.AssignObj;
var n: byte;
begin
	AddStack('TCustomCodeGet.AssignObj',Self);
	eC:=nil; eN:=nil; result:=false;
  if inherited AssignObj(tf) then begin
    n:=IfThen(Assigned(bDyn),1);
    with tf do if ComponentCount>n+2 then
      result:=IsClass(Components[n+1],TFldMask,pointer(eC))
        and IsClass(Components[n+2],TFldMask,pointer(eN));
  end;
  DelStack;
end;

end.
