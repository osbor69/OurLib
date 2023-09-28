unit Calc;

interface

uses Windows,Messages,Forms,Classes,Controls,StdCtrls,ExtCtrls,
  MyTypes,PaintCtl,FPanel,Schem;

const CalcMemCnt = 9;

type
  TCalcMemList  = 1..CalcMemCnt;
  TCalcMemList0 = 0..CalcMemCnt;
  TCalcButList = 1..4;

	TPCalcPnl = class(TPanel)
	private
		FCpt:string;
    procedure PnlDraw(const t: string);
    procedure WMPaint(var msg: TWMPaint); message WM_PAINT;
		procedure WMCalc(var msg: TWMCalc); message WM_CALC;
  protected
		procedure DragOver(Source:TObject;x,y:longint; State:TDragState;var Accept:boolean);override;
  public
		procedure DragDrop(Source:TObject;x,y:longint);override;
    property Cpt:string read FCpt write PnlDraw;
	end;

	TPCalcLbx = class(TListBox)
	private
		procedure WMCalc(var msg: TWMCalc); message WM_CALC;
  	procedure WMGetDlgCode(var Msg: TWmGetDlgCode); message wm_GetDlgCode;
  protected
    procedure DblClick; override;
    procedure DoExit; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
		procedure DrawItem(Index:longint;Rect:TRect;State:TOwnerDrawState); override;
	end;

  TPCalcMemPnl = class(TPanel)
  private
    function GetCapt: string;
    procedure SetCapt(const Value: string);
		procedure WMCalc(var msg: TWMCalc); message WM_CALC;
  protected
		procedure DragOver(Source:TObject;x,y:longint; State:TDragState; var Accept:boolean);override;
  public
		procedure DragDrop(Source:TObject;x,y:longint);override;
    property Capt: string read GetCapt write SetCapt;
  end;

	TPCalc=class(TPanel)
	private
		Tmr: TTimer;
		Lst: TList;
		KfcX,KfcY: double;
    DrgX,DrgY,hbt,wdt: longint;
    wbt: array[TCalcButList] of longint;
    ActivePaint: TPaintControl;
    FCurMem: TCalcMemList0;
    IsCalcDragging: boolean;
    OldClose: TCloseEvent;
    TFrm: TForm;
    ActCon: TWinControl;
		d: double;
		function GetParentRect: TRect;
		procedure SetPosLeft(k: longint);
		procedure SetPosTop(k: longint);
		procedure Kproc(key: longint; tw: TWinControl);
		procedure Lbxfocus;
		procedure CalcClose(Sender: TObject; var Action: TCloseAction);
		procedure CTimer(Sender:TObject);
    procedure MemCreate(i: TCalcMemList);
    function MemHeight: longint;
    procedure MemBounds;
    procedure btMemClick(Sender: TObject);
    procedure StrToPnl(const s: string);
    procedure CalcKey(Key: longint);
    procedure addstr(z: char; null: boolean=false);
    procedure SetCurMem(Value: TCalcMemList0);
		procedure WMRebuild(var msg: TWMRebuild); message WM_REBUILD;
  	procedure WMApplHint(var Msg: TWMApplHint); message WM_APPLHINT;
    property CurMem: TCalcMemList0 read FCurMem write SetCurMem;
  protected
		procedure Paint; override;
		procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
		procedure MouseMove(Shift: TShiftState; X,Y: longint); override;
		procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
  public
		Lbx: TPCalcLbx;
		Pnl: TPCalcPnl;
    aMem: array[TCalcMemList] of record
      abt: array[TCalcButList] of TPaintButton;
      pn: TPCalcMemPnl;
    end;
		constructor Create(AOwner: TComponent); override;
    procedure Init(S: TSchem);
	end;

implementation

uses SysUtils,Math,ClipBrd,StrUtils,
  My_pr,FrmWnd,Keylb;

const delta = 5;
      vst = 10;
      frm = '###############0.';
      frc = 6; // кол-во знаков после запятой при делении
      frc2 = 2; // кол-во знаков после запятой при выч-ии процента
			KeyLbCalc ='calc';
      Signs = ['+','-','*','/','^','%','&','|','\'];
      CalcNumLen = 20;

var PCalc: TPCalc;
    klb: TKeyLb;

procedure SetDragMod(Sender: TControl; const av: array of variant; var Done: boolean);
begin
  AddStack('Calc.SetDragMod');
  if not(Sender is TKeyLb) then with TEdit(Sender) do
    if dragmode=dmManual then begin
      DragMode:=dmAutomatic; TList(longint(av[0])).Add(Sender);
    end;
  DelStack;
end;

{ TPCalcPnl }
procedure TPCalcPnl.PnlDraw;
begin
	AddStack('TPCalcPnl.PnlDraw',Self);
	FCpt:=t; Perform(WM_Paint,0,0);
  DelStack;
end;

procedure TPCalcPnl.WMPaint;
var PCalc: TPCalc;
begin
	AddStack('TPCalcPnl.WMPaint',Self);
	inherited;
  PCalc:=pointer(Parent);
	with Canvas do begin
		Brush.Color:=Color; FillRect(Rect(0,0,width-4,height-4));
		TextOut(max(0,PCalc.Lbx.ClientWidth-TextWidth(FCpt)-2*PCalc.wdt),0,FCpt);
	end;
  DelStack;
end;

procedure TPCalcPnl.WMCalc;
begin
	AddStack('TPCalcPnl.WMCalc',Self);
	inherited;
  if msg.Operation=clcGet then begin
    msg.ps^:=StrToFloatDef(Cpt,0); msg.result:=1;
  end;
  DelStack;
end;

procedure TPCalcPnl.DragOver;
begin
	AddStack('TPCalcPnl.DragOver',Self);
	Accept:=MsgCalc(pointer(Source),clcGet,@PCalc.d);
  DelStack;
end;

procedure TPCalcPnl.DragDrop;
var t: string;
begin
	AddStack('TPCalcPnl.DragDrop',Self);
	with PCalc do	begin
  	addstr(' '); Pnl.Cpt:=floattostr(d);
		with Lbx do if Items.Count<>0 then	begin
      t:=Items[Items.Count-1];
      if t[length(t)]<>' ' then CalcKey(K_ENTER);
    end;
		Lbxfocus;
	end;
  DelStack;
end;

{ TPCalcLbx }
procedure TPCalcLbx.WMCalc;
var t: string;
begin
	AddStack('TPCalcLbx.WMCalc',Self);
	inherited;
  if msg.Operation=clcGet then begin
    with PCalc.Lbx do t:=items[itemindex];
    msg.ps^:=StrToFloatDef(SubStr(t,1,-2),0); msg.result:=1;
  end;
  DelStack;
end;

procedure TPCalcLbx.WMGetDlgCode;
begin
	AddStack('TPCalcLbx.WMGetDlgCode',Self);
	inherited;
  Or_D(Msg.Result,dlgc_WantTab);
  DelStack;
end;

procedure TPCalcLbx.DblClick;
begin
	AddStack('TPCalcLbx.DblClick',Self);
	TPCalc(Parent).CalcKey(K_INS);
  DelStack;
end;

procedure TPCalcLbx.DoExit;
begin
	AddStack('TPCalcLbx.DoExit',Self);
	PCalc.Tmr.Enabled:=true;
  DelStack;
end;

procedure TPCalcLbx.KeyDown;
begin
	AddStack('TPCalcLbx.KeyDown',Self);
  if not Assigned(klb) then pcalc.kproc(GetKeyCod(Key,Shift),Self);
  inherited KeyDown(Key,Shift);
  DelStack;
end;

procedure TPCalcLbx.KeyPress;
var u: string;
  s: char;
  PCalc: TPCalc;
begin
	AddStack('TPCalcLbx.KeyPress',Self);
  PCalc:=pointer(Owner);
	if (Key in Signs) and (PCalc.Pnl.Cpt<>Key) then begin
    if PCalc.CurMem=0 then with PCalc.Lbx.items do
      if PCalc.Pnl.Cpt='' then begin
        if count=0 then PCalc.addstr(key,true)
        else begin
          u:=PCalc.Lbx.items[count-1];
          s:=u[length(u)];
          if not(s in Signs) then PCalc.addstr(key,true)
          else if(key<>s)then begin
            PCalc.Pnl.Cpt:='01'[1+ord(s in ['*','/','^'])];
            PCalc.CalcKey(K_ENTER);
            PCalc.addstr(key);
          end;
        end;
      end else begin
        if count<>0 then begin
          u:=PCalc.Lbx.items[count-1];
          if u[length(u)] in Signs then PCalc.CalcKey(K_ENTER);
        end;
        PCalc.addstr(key);
      end
    else PCalc.CalcKey(K_Esc);
	end;
	key:=#0;
  DelStack;
end;

procedure TPCalcLbx.DrawItem;
var s: string;
  c: char;
	k: longint;
  PCalc: TPCalc;
begin
	AddStack('TPCalcLbx.DrawItem',Self);
  PCalc:=pointer(Owner);
  with Canvas do begin
    FillRect(Rect);
    s:=items[Index];
    k:=length(s);
    c:=s[k];
    SetLength(s,k-2);
    k:=min(TextWidth(s),Rect.right-2*PCalc.wdt-Rect.left);
    Textout(Rect.right-k-2*PCalc.wdt,Rect.top,s);
    Rect.left:=Rect.right-2*PCalc.wdt;
    FillRect(Rect);
    TextOut(Rect.right-PCalc.wdt-2,Rect.top,c);
	end;
  DelStack;
end;

{ TPCalcMemPnl }
function TPCalcMemPnl.GetCapt;
begin
  AddStack('TPCalcMemPnl.GetCapt',Self);
  result:=SubStr(Caption,1,-2);
  DelStack;
end;

procedure TPCalcMemPnl.SetCapt;
begin
  AddStack('TPCalcMemPnl.SetCapt',Self);
  Caption:=Value+'  ';
  DelStack;
end;

procedure TPCalcMemPnl.WMCalc;
begin
	AddStack('TPCalcMemPnl.WMCalc',Self);
	inherited;
  if msg.Operation=clcGet then begin
    msg.ps^:=StrToFloatDef(Capt,0); msg.result:=1;
  end;
  DelStack;
end;

procedure TPCalcMemPnl.DragOver;
begin
	AddStack('TPCalcMemPnl.DragOver',Self);
	Accept:=MsgCalc(pointer(Source),clcGet,@PCalc.d);
  DelStack;
end;

procedure TPCalcMemPnl.DragDrop;
begin
	AddStack('TPCalcMemPnl.DragDrop',Self);
  Capt:=FloatToStr(PCalc.d);
  DelStack;
end;

{ TPCalc }
constructor TPCalc.Create;
begin
  AddStack('TPCalc.Create',Self);
	inherited;
	Cursor:=crDrag;
	Pnl:=TPCalcPnl.create(Self);
	Pnl.BorderStyle:=bsSingle;
	Pnl.Parent:=Self;
	Lbx:=TPCalcLbx.create(self);
	Lbx.Integralheight:=true;
	Lbx.Style:=lbOwnerDrawFixed;
	Lbx.Parent:=Self;
	Tmr:=TTimer.create(Self);
	Tmr.Interval:=10;
  Tmr.onTimer:=CTimer;
  MemCreate(1); 
  DelStack;
end;

procedure TPCalc.Init;
var i: longint;
  str: string;
  r: TRect;
  sz: TSize;
begin
  AddStack('TPCalc.Init',Self);
  if Assigned(S) then begin
    Color:=S.ColorW; Font:=S.FontW;
    Pnl.Font:=S.Font1;
    Pnl.Color:=S.Color1;
    Lbx.Font:=Pnl.Font;
    Lbx.Color:=Pnl.Color;
  end;
  Canvas.font:=font;
  Lbx.Canvas.font:=Pnl.font;
  str:=StringOfChar('9',CalcNumLen+2);
  sz:=Lbx.Canvas.TextExtent(str); Pnl.tag:=sz.cx; Lbx.tag:=sz.cy;
  wdt:=Lbx.Canvas.TextWidth('9');
  Lbx.ItemHeight:=Lbx.tag;
  Pnl.height:=Lbx.tag+4;
  for i:=low(aMem) to high(aMem) do with aMem[i] do
    if Assigned(pn) then begin
      pn.Color:=Color; pn.Font:=Pnl.Font;
    end;
  if (Lbx.items.count=0) then begin
    height:=Pnl.height+MemHeight+7*delta;
    Lbx.height:=0;
    Pnl.top:=6*delta;
  end else begin
    i:=min(vst,Lbx.Items.Count);
    Lbx.height:=(i+1)*Lbx.tag;
    height:=Lbx.height+Pnl.height+MemHeight+6*delta;
    Pnl.top:=Lbx.height+5*delta;
    Lbxfocus;
    Lbx.TopIndex:=Lbx.Items.Count-i+1;
  end;
  Lbx.ClientWidth:=Pnl.tag;
  Lbx.SetBounds(delta,4*delta,Lbx.width,Lbx.height);
  Pnl.SetBounds(delta,Pnl.top,Lbx.width,Pnl.height);
  r:=GetParentRect;
  Width:=Lbx.width+2*delta;
  if (KfcX=0)or(KfcY=0) then begin
    SetPosLeft(r.Left);
    SetPosTop(r.Bottom-Height);
  end else begin
    SetBounds(nround((r.right-r.left)/KfcX+r.left-width/2),
              nround((r.bottom-r.top)/KfcY+r.top-height/2),
              Width,Height);
  end;
  MemBounds;
  Tmr.Enabled:=true;
  DelStack;
end;

procedure TPCalc.Lbxfocus;
begin
	with Lbx do if items.count>0 then itemindex:=items.count-1;
end;

procedure TPCalc.MouseDown;
begin
	AddStack('TPCalc.MouseDown',Self);
  if Assigned(ActivePaint)
  then with ActivePaint do MouseDown(Button,Shift,X-Left,Y-Top)
  else if (Button=mbLeft) and (not IsCalcDragging) then begin
    IsCalcDragging:=true;
    DrgX:=X;
    DrgY:=Y;
    Tmr.Enabled:=false;
  end;
  DelStack;
end;

procedure TPCalc.MouseMove;
const adhereGap = 10;
var k,j: longint;
  r: TRect;
  p: TPaintControl;
begin
	AddStack('TPCalc.MouseMove',Self);
  ActivePaint:=nil;
  for j:=0 to ComponentCount-1 do
  	if IsClass(Components[j],TPaintControl,pointer(p)) then begin
      if not p.Visible then continue;
      with p.Bounds do if (X<Left) or (X>Right) or (Y<Top) or (Y>Bottom) then continue;
			ActivePaint:=p; break;
    end;
  ShowHint:=Assigned(ActivePaint);
  if Assigned(ActivePaint)
  then with ActivePaint do MouseMove(Shift,X-Left,Y-Top)
  else if IsCalcDragging then begin
    r:=GetParentRect;
    k:=Self.Left+X-DrgX;
    if abs(r.Left-k)<=adhereGap then k:=r.Left
    else begin
      j:=r.Right-Self.Width;
      if abs(j-k)<=adhereGap then k:=j;
    end;
    SetPosLeft(k);
    k:=Self.Top+Y-DrgY;
    if abs(r.Top-k)<=adhereGap then k:=r.Top
    else begin
      j:=r.Bottom-Self.Height;
      if abs(j-k)<=adhereGap then k:=j;
    end;
    SetPosTop(k);
  end;
  DelStack;
end;

procedure TPCalc.MouseUp;
begin
	AddStack('TPCalc.MouseUp',Self);
  if Assigned(ActivePaint) then with ActivePaint do begin
  	MouseUp(Button,Shift,X-Left,Y-Top);
	  if (Button=mbLeft) and (Shift=[]) then Click;
  end
  else begin
  	IsCalcDragging:=false; Tmr.Enabled:=true;
  end;
  DelStack;
end;

function TPCalc.GetParentRect;
begin
	AddStack('TPCalc.GetParentRect',Self);
	result:=Rect(0,0,Parent.width,Parent.height);
  if Assigned(klb) then begin
    case klb.GetPlace of
      rpBottom: dec(result.Bottom,klb.height);
      rpLeft: result.Left:=klb.width;
      rpRight: dec(result.Right,klb.width);
    else result.Top:=klb.height;
    end;
	end;
  DelStack;
end;

procedure TPCalc.SetPosLeft;
var r: TRect;
    d: double;
begin
	AddStack('TPCalc.SetPosLeft',Self);
	Self.Left:=k;
  r:=GetParentRect;
  d:=Self.Left+width/2-r.left;
  if (d=0)or(r.right=r.left) then KfcX:=1{any} else KfcX:=(r.right-r.left)/d;
  DelStack;
end;

procedure TPCalc.SetPosTop;
var r: TRect;
    d: double;
begin
	AddStack('TPCalc.SetPosTop',Self);
	Self.Top:=k;
  r:=GetParentRect;
  d:=Self.Top+Self.Height/2-r.Top;
  if (d=0)or(r.Bottom=r.Top) then KfcY:=1{any} else KfcY:=(r.Bottom-r.Top)/d;
  DelStack;
end;

procedure TPCalc.CalcClose;
begin
	AddStack('TPCalc.CalcClose',Self);
	CalcKey(K_ESC); Action:=caNone;
  DelStack;
end;

function znak(const s: string): longint;
begin
  AddStack('Calc.znak');
  if IsPos(result,DecimalSeparator,s) then result:=length(s)-result;
  DelStack;
end;

procedure TPCalc.KProc;
  procedure ravno;
  var s: string;
  begin
  	AddStack('TPCalc.KProc.ravno',Self);
    with Lbx do
      if Items.Count<>0 then	begin
        s:=Items[Items.Count-1];
        if (s<>'')and(s[length(s)]='=') then addstr(' ');
      end;
    DelStack;
  end;
var ost,k: longint;
    umen,vych: extended;
		sign: char;
    t: string;
label lend;
begin
	ost:=AddStack('TPCalc.KProc',Self);
  case Key of
    K_LEFT,K_CTRL_LEFT: begin
      SetPosLeft(Left-20);
      Tmr.Enabled:=true;
    end;
    K_RIGHT,K_CTRL_RIGHT: begin
      SetPosLeft(Left+20);
      Tmr.Enabled:=true;
    end;
    K_Ctrl_F1: TFormWnd.StdProcKey(K_F1,tw);
    K_CTRL_UP: begin
      SetPosTop(Top-20);
      Tmr.Enabled:=true;
    end;
    K_CTRL_DOWN: begin
      SetPosTop(Top+20);
      Tmr.Enabled:=true;
    end;
  else
    k:=Key-K_F1+1;
    if InRange(k,low(aMem),high(aMem)) then begin
      if CurMem>0 then aMem[CurMem].pn.Color:=Color;
      CurMem:=k;
      if not Assigned(aMem[CurMem].pn) then begin
        MemCreate(CurMem); MemHeight; k:=max(Pnl.height,hbt);
        SetBounds(Left,Top-k,Width,Height+k); MemBounds;
      end;
      aMem[CurMem].pn.Color:=Pnl.Color;
    end
    else if CurMem=0 then begin
      case key of
        K_ENTER: begin
          vych:=StrToFloatDef(Pnl.Cpt,0);
          if (Lbx.Items.Count<>0) then begin
            t:=Lbx.Items[Lbx.Items.Count-1];
            k:=length(t);
            sign:=t[k];
            SetLength(t,k-2);
            if(sign in Signs)then begin
              umen:=StrToFloatDef(t,0);
              k:=max(znak(t),znak(Pnl.Cpt));
              try
                case sign of
                  '+': IncD(umen,vych);
                  '-': IncD(umen,-vych);
                  '*': begin
                    k:=znak(t)+znak(Pnl.Cpt);
                    MultD(umen,vych);
                  end;
                  '/': begin
                    k:=max(frc,k);
                    DivD(umen,vych);
                  end;
                  '^': begin
                    k:=max(frc,k);
                    umen:=power(umen,vych);
                  end;
                  '%': begin
                    k:=max(frc2,k);
                    MultD(umen,vych/100);
                  end;
                  '&': umen:=Trunc(umen) and Trunc(vych);
                  '|': umen:=Trunc(umen) or Trunc(vych);
                  '\': begin
                    k:=max(frc,k);
                    umen:=vych/umen;
                  end;
                end;
              except
                SetStack(ost);
                umen:=0;
              end;
              addstr('=');
              t:=StringOfChar('#',k);
              Pnl.Cpt:=FormatFloat(frm+t,umen);
            end else
              addstr(' ');
          end	else
            addstr(' ');
        end;
        K_ESC: begin
          if Assigned(klb) then with klb do	begin
            DelKey(K_ALL,KeyLbCalc); SetButNoEval(false); MainRebuild(klb);
          end;
          hide;
          for k:=0 to Lst.count-1 do
            if not(TObject(Lst.items[k]) is TPCalcMemPnl)
            then TEdit(Lst.items[k]).dragmode:=dmManual;
          Lst.free; Tmr.enabled:=false; TFrm.OnClose:=OldClose;
          MsgCalc(TFrm,clcEnd);
          if Assigned(actcon) then actcon.setfocus;
          Parent:=nil; isCalculator:=false;
          goto lend;
        end;
        K_TAB: if MsgCalc(Pnl,clcGet,@d) then MsgCalc(actcon,clcSet,@d);
        K_SPACE,K_DEL: begin
          ravno;
          Pnl.Cpt:='';
        end;
        K_INS: if Lbx.Items.Count<>0 then	StrToPnl(Lbx.Items[Lbx.ItemIndex]);
        K_BS: with Pnl do Cpt:=SubStr(Cpt,1,-1);
        K_C: begin
          hide;
          try
            k:=Top+Height;
            Lbx.clear; Pnl.Cpt:='';
            Lbx.ClientWidth:=Pnl.tag;

            Width:=Lbx.width+2*delta;
            SetPosLeft(Left);
            Height:=Pnl.height+MemHeight+7*delta;
            SetPosTop(k-Height);
            Lbx.SetBounds(delta,4*delta,Lbx.width,0);
            Pnl.SetBounds(delta,6*delta,Lbx.width,Pnl.height);
            MemBounds;
          finally
            show;
          end;
        end;
        K_0..K_9:begin
          ravno;
          with Pnl do Cpt:=StrNum(Cpt,key-K_0);
        end;
        K_ZPT,K_POINT: begin
          ravno;
          with Pnl do if Pos(DecimalSeparator,Cpt)=0 then Cpt:=Cpt+DecimalSeparator;
        end;
        K_Minus: with Pnl do if Cpt='' then Cpt:='-';
        K_CTRL_C:
          ClipBoard.AsText:=Pnl.Cpt;
        K_CTRL_V:
          Pnl.Cpt:=FloatToStr(Float0(ClipBoard.AsText));
        K_Shift_TAB: if MsgCalc(actcon,clcGet,@d) then Pnl.DragDrop(actcon,0,0);
      end;
      Lbxfocus;
    end
    else with aMem[CurMem] do begin
      case key of
        K_Enter: pn.Capt:=Pnl.Cpt;
        K_Esc: begin
          if Assigned(pn) then pn.Color:=Color; CurMem:=0;
          goto lend;
        end;
        K_Tab: if MsgCalc(pn,clcGet,@d) then MsgCalc(actcon,clcSet,@d);
        K_Space,K_C: abt[4].Click;
        K_Ins: abt[1].Click;
        K_Del: begin
          for k:=low(abt) to high(abt) do abt[k].Free;
          k:=Lst.IndexOf(pn);
          if k>=0 then Lst.Delete(k);
          FreeAndNil(pn); k:=max(Pnl.height,hbt);
          SetBounds(Left,Top+k,Width,Height-k); MemBounds;
        end;
        K_Plus,K_Minus: begin
          abt[IfThen(key=K_Minus,3,2)].Click; goto lend;
        end;
        K_CTRL_C: ClipBoard.AsText:=pn.Capt;
        K_CTRL_V: pn.Capt:=FloatToStr(Float0(ClipBoard.AsText));
        K_Shift_Tab: if MsgCalc(actcon,clcGet,@d) then pn.DragDrop(actcon,0,0);
      end;
      CalcKey(K_Esc);
    end;
  end;
lend:
	DelStack;
end;

procedure TPCalc.WMRebuild;
begin
  AddStack('TPCalc.WMRebuild',Self);
	if visible then Tmr.enabled:=true;
  DelStack;
end;

procedure TPCalc.WMApplHint;
begin
	AddStack('TPCalc.WMApplHint',Self);
  with Msg.Info^ do begin
    if Assigned(ActivePaint) then with ActivePaint do begin
      HintStr:=Hint; CanShow:=ShowHint; HintInfo.HintStr:=Hint;
    end;
    HintInfo.ReshowTimeout:=100;
  end;
  DelStack;
end;

procedure TPCalc.CTimer;
var ix,h,h1,i: longint;
    r: TRect;
begin
	AddStack('TPCalc.CTimer',Self);
	Tmr.enabled:=false;
	for i:=1 to 2 do begin
    r:=GetParentRect;
    SetPosLeft(nround((r.right-r.left)/KfcX+r.left-width/2));
    SetPosTop(nround((r.bottom-r.top)/KfcY+r.top-height/2));
		if (left<r.left) then SetPosLeft(r.left)
		else if (left+width>r.right) then SetPosLeft(r.right-width);
		if (top<r.top) then SetPosTop(r.top)
		else if (top+height>r.bottom) then SetPosTop(max(r.top,r.bottom-height));
		if (top<r.top) then	begin
			hide;
      try
        height:=r.bottom-r.top;
        ix:=Lbx.topindex;
        h:=Lbx.height; h1:=Pnl.height+MemHeight+6*delta;
        Lbx.height:=height-h1;
        Lbx.TopIndex:=ix+nround((h-Lbx.height)/Lbx.tag);
        Height:=Lbx.height+h1;
        Lbx.ClientWidth:=Pnl.tag;
        SetPosTop(r.bottom-height);
        Width:=Lbx.width+2*delta;
        SetPosLeft(Left);
        Pnl.SetBounds(Pnl.left,height-Pnl.height-delta,Lbx.width,Pnl.height);
        MemBounds;
      finally
  			show;
      end;
		end;
    if Visible and Lbx.CanFocus then Lbx.SetFocus;
	end;
  DelStack;
end;

procedure TPCalc.MemCreate;
const a: array[TCalcButList] of TNamePrimStr =
  (('F','Вставить число из памяти')
  ,('+','Прибавить число к памяти')
  ,('-','Вычесть число из памяти')
  ,('C','Очистить память')
  );
var j: TCalcButList;
  s: string;
begin
  AddStack('TPCalc.MemCreate',Self);
  with aMem[i] do begin
    s:=IntToStr(i); pn:=TPCalcMemPnl.Create(Self);
    with pn do begin
      Parent:=Self; BevelOuter:=bvNone; BorderStyle:=bsSingle;
      Color:=Self.Color; Font:=Pnl.Font;
      ShowHint:=true; Hint:='Содержимое памяти '+s; Alignment:=taRightJustify;
      DragMode:=dmAutomatic;
    end;
    for j:=low(abt) to high(abt) do begin
      abt[j]:=TPaintButton.Create(Self);
      with abt[j] do begin
        Canvas:=Self.Canvas; ShowHint:=true; Hint:=a[j,2]+' '+s;
        Caption:=a[j,1]+IfThen(j=1,s); Tag:=(i-1)*(Length(abt)+1)+j; OnClick:=btMemClick;
      end;
    end;
  end;
  DelStack;
end;

function TPCalc.MemHeight;
var i: TCalcMemList;
  j: TCalcButList;
  sz: TSize;
begin
  AddStack('TPCalc.MemHeight',Self);
  hbt:=0; result:=0; ZeroMemory(@wbt,SizeOf(wbt));
  for i:=low(aMem) to high(aMem) do with aMem[i] do
    if Assigned(pn) then begin
      Inc(result);
      for j:=low(abt) to high(abt) do with abt[j] do begin
        sz:=Canvas.TextExtent(Caption); MaxSelf(wbt[j],sz.cx); MaxSelf(hbt,sz.cy);
      end;
    end;
  Inc(hbt,4);
  for j:=low(wbt) to high(wbt) do Inc(wbt[j],8);
  result:=result*(max(Pnl.height,hbt))+delta;
  DelStack;
end;

procedure TPCalc.MemBounds;
var i: TCalcMemList;
  j: TCalcButList;
  l,t: longint;
begin
  AddStack('TPCalc.MemBounds',Self);
  t:=Pnl.Top+Pnl.Height+delta;
  for i:=low(aMem) to high(aMem) do with aMem[i] do
    if Assigned(pn) then begin
      l:=delta;
      for j:=low(abt) to high(abt) do begin
        abt[j].SetBounds(l,t,wbt[j],hbt); Inc(l,wbt[j]);
      end;
      pn.SetBounds(l+delta,t,Width-delta*2-l,Pnl.Height); Inc(t,max(Pnl.height,hbt));
    end;
  DelStack;
end;

procedure TPCalc.btMemClick;
var i,j: longint;
  s: string;
  onCurMem: TCalcMemList0;
begin
  AddStack('TPCalc.btMemClick',Self);
  i:=TPaintButton(Sender).Tag; j:=ModDiv(i,Length(wbt)+1); Inc(i);
  with aMem[i].pn do case j of
    1: begin
      onCurMem:=CurMem; CurMem:=0; StrToPnl(Caption); CurMem:=onCurMem;
    end;
    4: Capt:='';
  else
    s:=Capt;
    Capt:=FormatFloat(frm+StringOfChar('#',max(znak(s),znak(Pnl.Cpt))),
      StrToFloatDef(s,0)+StrToFloatDef(Pnl.Cpt,0)*aSign[j=3]);
    Pnl.Cpt:='';
  end;
  DelStack;
end;

procedure TPCalc.StrToPnl;
var t: string;
begin
  AddStack('TPCalc.StrToPnl',Self);
  addstr(' '); Pnl.Cpt:=SubStr(s,1,-2);
  if Lbx.items.count>0 then begin
    t:=Lbx.Items[Lbx.items.count-1];
    if t[length(t)]<>' ' then CalcKey(K_ENTER);
  end;
  DelStack;
end;

procedure TPCalc.Paint;
begin
  AddStack('TPCalc.Paint',Self);
  inherited Paint;
  TPaintControl.PaintAll(Self);
  DelStack;
end;

procedure TPCalc.CalcKey;
begin
  AddStack('TPCalc.CalcKey',Self);
  if Assigned(klb) then klb.ExecKey(Key) else kproc(Key,Lbx);
  DelStack;
end;

procedure TPCalc.addstr;
var t: string;
    ost,k: longint;
    r: TRect;
begin
	ost:=AddStack('TPCalc.addstr',Self);
	if null then t:='0'
  else begin
  	t:=Pnl.Cpt;
    try
      strtofloat(t);
      Lbx.Items.Add(t+' '+z);
      r:=GetParentRect;
      if (top-r.top>Lbx.tag)and(nround(Lbx.ClientHeight/Lbx.tag)<vst) then begin
        hide;
        try
          Lbx.height:=Lbx.height+Lbx.tag;
          k:=height;
          height:=Lbx.height+Pnl.height+MemHeight+6*delta;
          SetPosTop(top+k-height);
          Pnl.top:=height-Pnl.height-MemHeight-delta;
          MemBounds;
        finally
          show;
        end;
      end	else begin
        hide;
        try
          Lbx.ClientWidth:=Pnl.tag;
          width:=Lbx.width+2*delta;
          SetPosLeft(Left);
          Pnl.width:=Lbx.width;
        finally
          show;
        end;
        Tmr.enabled:=true;
      end;
      Lbxfocus;
      Pnl.Cpt:='';
    except
    	SetStack(ost);
    end;
	end;
	DelStack;
end;

procedure TPCalc.SetCurMem;
begin
  AddStack('TPCalc.SetCurMem',Self);
  FCurMem:=Value;
  if Assigned(klb) then klb.SetKey(K_SPACE,'','',pcalc.kproc,KeyLbCalc,kmNone,'',IfThen(Value=0,K_Del,K_C));
  DelStack;
end;

procedure WndKeyProc(Key: longint; tw: TWinControl; var lBreak: boolean);
var i,j: longint;
  a: array[TCalcMemList] of longint;
  TF: TForm;
begin
  AddStack('Calc.WndKeyProc');
  if key=K_F9 then begin
    lBreak:=true;
    if not isCalculator then begin
      TF:=ParentForm(tw);
      for i:=0 to TF.ControlCount-1 do if (TF.controls[i] is TCustomRbPanel) then begin
        isCalculator:=true; MsgCalc(TF,clcBegin);
        with PCalc do	begin
          if not Assigned(PCalc) then PCalc:=TPCalc.Create(Application);
          TFrm:=TF; actcon:=TF.activecontrol;
          if FormKeyLb(TF,klb) then with klb do begin
            SetButNoEval(true);
            SetKey(K_Ctrl_F1,'','Помощь',pcalc.kproc,KeyLbCalc,kmHelp);
            SetKey(K_ESC,'Выход','',pcalc.kproc,KeyLbCalc,kmCalc);
            SetKeys([K_CTRL_LEFT,K_LEFT],'','Сместить калькулятор влево',pcalc.kproc,KeyLbCalc,kmCalc);
            SetKeys([K_CTRL_RIGHT,K_RIGHT],'','Сместить калькулятор вправо',pcalc.kproc,KeyLbCalc,kmCalc);
            SetKey(K_CTRL_UP,'','Сместить калькулятор вверх',pcalc.kproc,KeyLbCalc,kmCalc);
            SetKey(K_CTRL_DOWN,'','Сместить калькулятор вниз',pcalc.kproc,KeyLbCalc,kmCalc);
            SetKey(K_ENTER,'Равно','',pcalc.kproc,KeyLbCalc,kmCalc);
            SetKey(K_INS,'Вставить','Вставить число из списка',pcalc.kproc,KeyLbCalc,kmCalc);
            SetKey(K_DEL,'Удалить','Очистить поле ввода',pcalc.kproc,KeyLbCalc,kmCalc);
            SetKey(K_C,'Очистить','Очистить список',pcalc.kproc,KeyLbCalc,kmCalc);
            if Assigned(ActCon) then begin
              if MsgCalc(actcon,clcCanSet)
              then SetKey(K_TAB,'','Перенести в поле',pcalc.kproc,KeyLbCalc,kmCalc);
              if MsgCalc(actcon,clcGet,@d)
              then SetKey(K_Shift_TAB,'','Взять из поля',pcalc.kproc,KeyLbCalc,kmCalc);
            end;
            SetKeys([K_0,K_1,K_2,K_3,K_4,K_5,K_6,K_7,K_8,K_9,K_ZPT,K_POINT,K_Plus,K_Minus],'','Ввод значения',pcalc.kproc,KeyLbCalc,kmNone);
            SetKey(K_BS,'','Удалить правый символ',pcalc.kproc,KeyLbCalc,kmNone);
            SetKey(K_CTRL_C,'','Скопировать',pcalc.kproc,KeyLbCalc,kmNone);
            SetKey(K_CTRL_V,'','Вставить',pcalc.kproc,KeyLbCalc,kmNone);
            for j:=low(a) to high(a) do a[j]:=K_F1+j-1;
            SetKeys(a,'',Format('Память %d-%d',[low(a),high(a)]),pcalc.kproc,KeyLbCalc,kmNone);
            CurMem:=0; ReDrw;
          end;
          OldClose:=TFrm.onClose; TFrm.onClose:=CalcClose; Parent:=pointer(TF.controls[i]); Hide;
          Lst:=TList.Create;
          ProcControls(Parent,SetDragMod,[Longint(Lst)]);
          DragMode:=dmManual;
          Init(SchemName('Calc'));
          IsCalcDragging:=false;
          Show;
          BringToFront;
        end;
        Break;
      end;
    end;
  end;
  DelStack;
end;

initialization
  AddStack('Calc.initialization');
  AddFrom(aWndKeyProc,WndKeyProc);
  DelStack;
end.
