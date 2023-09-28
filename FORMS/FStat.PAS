unit FStat;

interface

uses
  Messages, Classes, Controls, Forms, ExtCtrls, Gauges,
  MyTypes, Schem, FRMEMPTY, Keylb, Fpanel;

type
	TStat = class;
  TStatEvent = procedure(Sender: TStat) of object;
  TStatEvent0 = procedure(Sender: TStat; const Params: array of variant; var Aborted: boolean);

  TStatStatus = class(TRbStatus)
  {private
    procedure WMSchem(var msg: TWMSchem); message WM_SCHEM;}
  protected
    procedure CanvasSectType(ts: TSchem; tp: TRBSTSectType; Index: longint); override;
  end;

  TStatGauge = class(TGauge)
  private
    procedure WMSchem(var msg: TWMSchem); message WM_SCHEM;
  end;

  TStatPanel = class(TRbPanel)
  private
    prc: Double;
  	Proc: TStatEvent;
    CanEscape: boolean;
    st,DopSt: string;
    DopProc: TKeyProc;
	  TimeStart,CurTime: longword;
    procedure WMSchem(var msg: TWMSchem); message WM_SCHEM;
  public
  	pn: TStatStatus;
    gg: TStatGauge;
  	constructor Create(AOwner: TComponent); override;
		function MinWidth: longint;
  end;

  TStatCaptHead = TNamePrimStr;

  TStat = class(TFormEmp)
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    CanMove,Moved: boolean;
    pnCnt: longint;
    procedure IfThenProc(pn: TStatPanel);
    procedure Timer1Timer(Sender: TObject);
		procedure SetCanEscape(Value: boolean);
		procedure CalcWidth(const Capt,st: TCaption);
    function CaptHead(const ACapt: TCaption): TStatCaptHead;
    class procedure LastTimeMsg(key: longint; tw: TWinControl);
    class procedure Proc0(Sender: TStat);
    procedure WMMove(var Message: TWMMove); message WM_MOVE;
    procedure WMGetDlgCode(var Message: TWmGetDlgCode); message wm_GetDlgCode;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
    procedure WMKeyLbVisible(var Message: TMessage); message WM_KEYLBVISIBLE;
  protected
    procedure AfterCreate; override;
  public
    { Public declarations }
  	Params: TArrVar;
    FCanEsc: boolean;
  	function Aborted: boolean;
		function SayStat(const cCapt: TCaption; const st: TCaption = ''; prc: Double = 0): boolean; overload;
		function SayStat(prc: Double): boolean; overload;
    function Abort: boolean;
		procedure ClearTime;
		procedure ClearCurTime;
		function CurCapt: string;
		procedure SetModalResult(mr: TModalResult = mrCancel); override;
    class function LastStat: TStat;
  end;

  TShowStatList = (stNoShow,stNoCanEsc); TShowStatOpt = set of TShowStatList;

function ShowStat(const capt: TCaption; pr: TStatEvent;
  CanEsc: boolean = true; const DopKeySt: string = ''; DopKeyProc: TKeyProc = nil): boolean; overload;
function ShowStat(const capt: TCaption; pr: TStatEvent; const Prm: array of variant;
  CanEsc: boolean = true; const DopKeySt: string = ''; DopKeyProc: TKeyProc = nil): boolean; overload;
function ShowStat(const capt: TCaption; pr: TStatEvent0; const Prm: array of variant;
  Opt: TShowStatOpt = []; const DopKeySt: string = ''; DopKeyProc: TKeyProc = nil): boolean; overload;
function ShowStat(const capt: TCaption; pr: TStatEvent0; const Prm: array of variant; Cnt: Int64;
  CanEsc: boolean = true; const DopKeySt: string = ''; DopKeyProc: TKeyProc = nil): boolean; overload;
function ShowStat(const capt: TCaption; pr: TStatEvent0; const Prm: array of variant; Cnt,CntShow: Int64;
  CanEsc: boolean = true; const DopKeySt: string = ''; DopKeyProc: TKeyProc = nil): boolean; overload;
function ShowStat(const capt: TCaption; pr: TStatEvent0;
  CanEsc: boolean = true; const DopKeySt: string = ''; DopKeyProc: TKeyProc = nil): boolean; overload;
function IfThen(AValue: boolean; ATrue: TShowStatList): TShowStatOpt; overload;

implementation

{$R *.dfm}

uses Windows,StrUtils,SysUtils,Variants,Graphics,Math,
  My_pr;

var aStat: array of TStat;
  nStat: longint = -1;
  LastTime: longword;

function ShowStat(const capt: TCaption; pr: TStatEvent;
  CanEsc: boolean = true; const DopKeySt: string = ''; DopKeyProc: TKeyProc = nil): boolean;
begin
  result:=ShowStat(capt,pr,[0],CanEsc,DopKeySt,DopKeyProc);
end;

function ShowStat(const capt: TCaption; pr: TStatEvent; const Prm: array of variant;
  CanEsc: boolean = true; const DopKeySt: string = ''; DopKeyProc: TKeyProc = nil): boolean;
var pn: TStatPanel;
	procedure SetKeyDop(ce: boolean);
  begin
    AddStack('FStat.ShowStat.SetKeyDop');
    with aStat[nStat],KeyLb1,pn do begin
      DelKey(K_All,'dop'); SetKeysSt(DopSt,DopProc,'dop'); SetCanEscape(ce); Redrw;
    end;
    DelStack;
  end;
var oPrm: TArrVar;
	i: longint;
  pn0,fl,oCanEscape: boolean;
  ch: TStatCaptHead;
begin
	AddStack('FStat.ShowStat');
  fl := not(LastForm is TStat);
  if fl then begin
    Inc(nStat);
    if Length(aStat)=nStat then begin
      SetLength(aStat,nStat+1); Application.CreateForm(TStat,aStat[nStat]);
    end
    else if FormsFree then Application.CreateForm(TStat,aStat[nStat]);
    aStat[nStat].NoLimit:=true;
  end;
  with aStat[nStat] do begin
    pn0 := pnCnt<0;
    if not pn0 then with TStatPanel(RbPanel2.Controls[PnCnt]) do
      if prc>=0 then begin
        ClearCurTime; SayStat('',st,prc);
      end;
    // Сохранить предыдущее состояние
    CopyFromVArr(oPrm,Params);
    // Установить новое состояние
    if MyVarType(Prm[low(Prm)])=varArray then Params:=Prm[low(Prm)] else Params:=VarArrayOf(Prm);
    FCanEsc:=CanEsc;
    Inc(pnCnt); SetRedraw(aStat[nStat]); ch:=CaptHead(Capt);
    if pnCnt<RbPanel2.ControlCount then pn:=pointer(RbPanel2.Controls[pnCnt])
    else begin
      pn:=TStatPanel.Create(aStat[nStat]); pn.Visible:=false; pn.Parent:=RbPanel2;
      pn.Header:=IfThen(pn0,ch[2],' ');
      FPanel.SetSchemForm(pn);
    end;
    oCanEscape:=pn.CanEscape; pn.DopSt:=DopKeySt; pn.DopProc:=DopKeyProc; pn.Proc:=pr; SetKeyDop(CanEsc);
    pn.prc:=-1; i:=pn.pn.MinHeight+pn.gg.Height+pn.BevPanel2+pn.HeaderHeight;
    if pn0 then begin
      pn.SetBounds(0,0,pn.Width,i); ClientHeight:=i+KeyLb1.Height;
      CanMove:=false; Moved:=false;
    end
    else begin
      with RbPanel2.Controls[pnCnt-1] do pn.SetBounds(0,Top+Height,pn.Width,i);
      ClientHeight:=max(ClientHeight,pn.Top+i+KeyLb1.Height);
    end;
    CalcWidth(Capt,''); ClearTime; pn.gg.Progress:=0; pn.Visible:=true; SetRedraw(aStat[nStat],rdrwSet);
    try
      if pn0 then begin
        TTimerOne.CreateProc(Timer1Timer,aStat[nStat]); result := ShowModal<>mrOk;
      end
      else begin
        try
          aStat[nStat].IfThenProc(pn);
        finally
          result := pn.CanEscape and (ModalResult=mrCancel);
          ModalResult:=mrNone;
        end;
      end;
    finally
      pn.Visible:=false; pn.pn.SectLeft[0]:='';
      if pn0 then Caption:='' else pn.Header:=' ';
      LastTime:=My_pr.GetTickCount-pn.TimeStart; SetKeyDop(oCanEscape); Dec(pnCnt);
      // Восстановить предыдущее состояние
      CopyFromVArr(Params,oPrm);
      ClearCurTime;
    end;
  end;
  if fl then begin
    FormFree(aStat[nStat]); Dec(nStat);
  end;
  DelStack;
end;

function ShowStat(const capt: TCaption; pr: TStatEvent0; const Prm: array of variant;
  Opt: TShowStatOpt = []; const DopKeySt: string = ''; DopKeyProc: TKeyProc = nil): boolean;
var Params: TArrVar;
begin
	AddStack('FStat.ShowStat(0)');
  if stNoShow in Opt then begin
    result:=false;
    if Assigned(pr) then pr(nil,Prm,result);
  end
  else begin
    CopyFromVArr(Params,[longint(@pr)]); AddFromVArr(Params,Prm);
    result:=ShowStat(capt,TStat.Proc0,Params,not(stNoCanEsc in Opt),DopKeySt,DopKeyProc);
  end;
  DelStack;
end;

function ShowStat(const capt: TCaption; pr: TStatEvent0; const Prm: array of variant; Cnt: Int64;
  CanEsc: boolean = true; const DopKeySt: string = ''; DopKeyProc: TKeyProc = nil): boolean;
begin
  result:=ShowStat(capt,pr,Prm,Cnt,2,CanEsc,DopKeySt,DopKeyProc);
end;

function ShowStat(const capt: TCaption; pr: TStatEvent0; const Prm: array of variant; Cnt,CntShow: Int64;
  CanEsc: boolean = true; const DopKeySt: string = ''; DopKeyProc: TKeyProc = nil): boolean;
begin
  result:=ShowStat(capt,pr,Prm,IfThen(Cnt<CntShow,stNoShow)+IfThen(not CanEsc,stNoCanEsc),DopKeySt,DopKeyProc);
end;

function ShowStat(const capt: TCaption; pr: TStatEvent0;
  CanEsc: boolean = true; const DopKeySt: string = ''; DopKeyProc: TKeyProc = nil): boolean;
begin
  result:=ShowStat(capt,pr,[],IfThen(not CanEsc,stNoCanEsc),DopKeySt,DopKeyProc);
end;

function IfThen(AValue: boolean; ATrue: TShowStatList): TShowStatOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function CaptFromTime(rt: longword; const Zgl: string): string;
var Hour,Min,Sec,MSec: Word;
begin
  AddStack('FStat.CaptFromTime');
  DecodeMSec(trunc(rt),Hour,Min,Sec,MSec);
  result:=StrNum(Zgl+' ',Hour,2)+StrNum(':',Min,2)+StrNum(':',Sec,2);
  DelStack;
end;

{ TStatStatus }
{procedure TStatStatus.WMSchem;
begin
	AddStack('TStatPanel.WMSchem',Self);
  inherited;
	if Assigned(msg.Schem) then Font.Assign(msg.Schem.Font1);
  DelStack;
end;}

procedure TStatStatus.CanvasSectType;
begin
  AddStack('TStatStatus.CanvasSectType',Self);
  if Assigned(ts) then with Canvas do begin
    Brush.Color:=ts.ColorW; Font.Assign(ts.Font1);
  end;
  DelStack;
end;

{ TStatGauge }
procedure TStatGauge.WMSchem;
begin
  AddStack('TStatGauge.WMSchem',Self);
  inherited;
  with msg do if Assigned(Schem) then with Schem do begin
    BackColor:=Color1; ForeColor:=Color2; Font.Assign(Font2);
  end
  else begin
    ForeColor:=clHighLight;
    if Parent is TCustomRbPanel then Font.Size:=nround(TCustomRbPanel(Parent).Font.Size*0.8);
  end;
  DelStack;
end;

{ TStatPanel }
constructor TStatPanel.Create;
begin
	AddStack('TStatPanel.Create',Self);
  inherited Create(AOwner);
  BevelOuter:=bvLowered; CanEscape:=true;
  pn:=TStatStatus.Create(AOwner);
  with pn do begin
  	Parent:=Self; BevelInner:=bvLowered; BevelOuter:=bvRaised; ParentSchem:=true;
    SectLeft.Add(''); SectRight.Add('Осталось 00:00:00'); SectRight.Add('Прошло 00:00:00');
  end;
  gg:=TStatGauge.Create(AOwner); gg.Parent:=Self;
  DelStack;
end;

procedure TStatPanel.WMSchem;
var h: byte;
	w: longint;
begin
	AddStack('TStatPanel.WMSchem',Self);
  inherited;
  with msg do if Assigned(Schem) then with Schem do begin
    pn.Color:=ColorW; pn.Font.Assign(Font1);
  end;
  h:=BevPanel; w:=CltWidth;
  pn.SetBounds(h,h+HeaderHeight,w,pn.MinHeight);
  Canvas.Font.Assign(gg.Font); gg.SetBounds(h,pn.Top+pn.Height,w,CanvasMaxH(Canvas));
  DelStack;
end;

function TStatPanel.MinWidth;
begin
  AddStack('TStatPanel.MinWidth',Self);
  result:=pn.Canvas.TextWidth(pn.SectLeft[0])+pn.Canvas.TextWidth(pn.SectRight[0])
  	+pn.Canvas.TextWidth(pn.SectRight[1])+26+pn.BevPanel2+BevPanel2;
  DelStack;
end;

{ TStat }
procedure TStat.FormCreate(Sender: TObject);
begin
	AddStack('TStat.FormCreate',Self);
  inherited;
  pnCnt:=-1; SetCanEscape(true); 
  if Win32Platform=VER_PLATFORM_WIN32_NT then BorderStyle:=bsSingle;
  DelStack;
end;

function TStat.Abort;
begin
	AddStack('TStat.Abort',Self);
  result:=Assigned(Self);
  if result then begin
    if PnCnt>=0 then TStatPanel(RbPanel2.Controls[pnCnt]).CanEscape:=true;
    SetModalResult;
  end;
  DelStack;
end;

function TStat.Aborted;
begin
	AddStack('TStat.Aborted',Self);
  if Assigned(Self) then begin
    Application.ProcessMessages; CanMove:=true;
    if PnCnt<0 then result:=true else result:=TStatPanel(RbPanel2.Controls[pnCnt]).CanEscape;
    AndD(result,ModalResult<>mrNone);
  end
  else result:=false;
  Or_D(result,Application.Terminated);
  DelStack;
end;

// Следующий шаг
function TStat.SayStat(const cCapt: TCaption; const st: TCaption = ''; prc: Double = 0): boolean;
var pn: TStatPanel;
  t: longword;
	Capt: string;
begin
	AddStack('TStat.SayStat',Self);
  if Assigned(Self) then begin
    result:=Aborted;
    if not result then begin
      t:=My_pr.GetTickCount; pn:=pointer(RbPanel2.Controls[pnCnt]); pn.prc:=prc; pn.st:=st;
      if cCapt='' then Capt:=CurCapt else Capt:=cCapt;
      if (pn.CurTime=0) or (t-pn.CurTime>MSecsPerSec) or (Capt<>CurCapt) then begin
        pn.CurTime:=t; CalcWidth(Capt,st); Dec(t,pn.TimeStart);
        pn.pn.SectRight[1]:=CaptFromTime(t,'Прошло');
        //LastTime:=t;
        if prc>0 then pn.pn.SectRight[0]:=CaptFromTime(trunc(t*(1/prc-1)),'Осталось');
        if prc>=0 then pn.gg.Progress:=nround(prc*pn.gg.MaxValue);
        Refresh;
      end;
    end;
  end
  else result:=false;
  DelStack;
end;

function TStat.SayStat(prc: Double): boolean;
begin
  result:=SayStat('','',prc);
end;

function TStat.CurCapt;
begin
  AddStack('TStat.CurCapt',Self);
  result:=TStatPanel(RbPanel2.Controls[pnCnt]).Header;
  if pnCnt=0 then result:=DlmBetween(Caption,result,UnDelim);
  DelStack;
end;

procedure TStat.CalcWidth;
var w,l,t: longint;
	fl,ocm: boolean;
  pn: TStatPanel;
  r: TRect;
  ch: TStatCaptHead;
  a: TArrStr;
begin
	AddStack('TStat.CalcWidth',Self);
  ocm:=CanMove; CanMove:=false; w:=300;
  if Visible then MaxSelf(w,ClientWidth);
  MaxSelf(w,KeyLb1.WMin); pn:=pointer(RbPanel2.Controls[pnCnt]);
  if (Capt<>'') and (CurCapt<>Capt) then begin
    ch:=CaptHead(Capt);
	  if pnCnt=0 then begin
    	Caption:=ch[1]; MaxSelf(w,MinWidthForm(Self));
    end;
    with pn do begin
    	Header:=ch[2]; Canvas.Font.Assign(Font);
      for l:=0 to LsArrDynamic(Header,a,UnDelim)-1 do MaxSelf(w,Canvas,a[l],10);
    end;
  end;
  if (st<>'') and (st<>pn.pn.SectLeft[0]) then begin
    pn.pn.SectLeft[0]:=st; MaxSelf(w,pn.MinWidth);
  end;
  Canvas.Font.Assign(Font); Inc(w,Width-ClientWidth); fl := w<>Width;
  if Moved then begin
    l:=Left; t:=Top;
  end
  else begin
    r:=SysWorkArea; l:=r.Left+max(0,(r.Right-r.Left-w) div 2); t:=r.Top+(r.Bottom-r.Top-Height) div 2;
  end;
  SetBounds(l,t,w,Height);
  if fl or not pn.Visible then begin
  	w:=ClientWidth;
    with RbPanel2 do begin
      t:=w-TStatPanel(Controls[0]).BevPanel2;
      for l:=0 to pnCnt do with TStatPanel(Controls[l]) do begin
        Width:=w; pn.Width:=t; gg.Width:=t;
      end;
    end;
  	if fl then FormOnScreen;
  end;
  CanMove:=ocm;
  DelStack;
end;

procedure TStat.ClearTime;
begin
	AddStack('TStat.ClearTime',Self);
	if pnCnt>=0 then TStatPanel(RbPanel2.Controls[pnCnt]).TimeStart:=My_pr.GetTickCount;
  ClearCurTime;
  DelStack;
end;

procedure TStat.ClearCurTime;
begin
  AddStack('TStat.ClearCurTime',Self);
  if Assigned(Self) then if pnCnt>=0 then TStatPanel(RbPanel2.Controls[pnCnt]).CurTime:=0;
  DelStack;
end;

procedure TStat.WMMove;
begin
  AddStack('TStat.WMMove',Self);
  inherited;
  if CanMove then Moved:=true;
  DelStack;
end;

procedure TStat.WMGetDlgCode;
begin
	AddStack('TStat.WMGetDlgCode',Self);
	inherited;
  Or_D(Message.Result,dlgc_WantTab);
  DelStack;
end;

procedure TStat.KeyLb1ProcKey(key: longint; tw: TWinControl);
begin
	AddStack('TStat.KeyLb1ProcKey',Self);
	case Key of
    K_Esc: SetModalResult;
    K_Ctrl_M: StdProcKey(Key,tw);
  end;
  DelStack;
end;

procedure TStat.SetCanEscape;
var pn: TStatPanel;
begin
  AddStack('TStat.SetCanEscape',Self);
  if pnCnt>=0 then begin
    pn:=pointer(RbPanel2.Controls[pnCnt]);
    if Value<>pn.CanEscape then with KeyLb1 do begin
      if Value then SetKey(K_Esc,'Отмена','',KeyLb1ProcKey,'stat',kmNone) else DelKeys([K_Esc]);
      Redrw; pn.CanEscape:=Value;
    end;
  end;
  DelStack;
end;

procedure TStat.IfThenProc;
begin
  if Assigned(pn.Proc) then pn.Proc(Self);
end;

procedure TStat.Timer1Timer;
var pn: TStatPanel;
begin
	AddStack('TStat.Timer1Timer',Self);
  pn:=pointer(RbPanel2.Controls[pnCnt]); IfThenProc(pn);
  if not pn.CanEscape or (ModalResult=mrNone) then SetModalResult(mrOk);
  DelStack;
end;

procedure TStat.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	AddStack('TStat.FormClose',Self);
  inherited;
  if (Action=caHide) and (ModalResult=mrCancel)
  and (pnCnt>=0) and not TStatPanel(RbPanel2.Controls[pnCnt]).CanEscape then begin
  	Action:=caNone; SetModalResult(mrNone);
  end;
  DelStack;
end;

procedure TStat.SetModalResult;
begin
  AddStack('TStat.SetModalResult',Self);
  if IsCalculator then KeyLb1.ExecKey(K_Esc);
  inherited SetModalResult(mr);
  DelStack;
end;

procedure TStat.WMFormLimit;
var i,j: longint;
begin
	AddStack('TStat.WMFormLimit',Self);
  inherited;
  for i:=low(aStat) to high(aStat) do if FreeLimit(aStat[i]) then begin
    for j:=i+1 to high(aStat) do aStat[j-1]:=aStat[j];
    SetLength(aStat,Length(aStat)-1); break;
  end;
  DelStack;
end;

procedure TStat.WMKeyLbVisible;
var i,h: longint;
begin
	AddStack('TStat.WMKeyLbVisible',Self);
  inherited;
  KeyLb1.ReDrw; h:=0;
  with RbPanel2 do for i:=0 to ControlCount-1 do with Controls[i] do
  	if Visible then Inc(h,Height);
  ClientHeight:=h+KeyLb1.Height;
  DelStack;
end;

procedure TStat.AfterCreate;
begin
end;

function TStat.CaptHead;
begin
  AddStack('TStat.CaptHead',Self);
  if pnCnt=0 then result:=StrDivDlm(UnDelim,ACapt) else result:=NamePrimStr('',ACapt);
  DelStack;
end;

class procedure TStat.LastTimeMsg;
begin
  AddStack('TStat.LastTimeMsg');
  TKeyLb.FixKeyShow(Key,false); meserr(CaptFromTime(LastTime,'Прошло')); TKeyLb.FixKeyShow(Key,true);
  DelStack;
end;

class function TStat.LastStat;
begin
  AddStack('TStat.LastStat');
  if nStat<0 then result:=nil else result:=aStat[nStat];
  DelStack;
end;

class procedure TStat.Proc0;
var pr: TStatEvent0;
  Prm: TArrVar;
  i: longint;
  Aborted: boolean;
begin
  AddStack('TStat.Proc0');
  pr:=PointerVar(Sender.Params[0]); SetLength(Prm,Length(Sender.Params)-1);
  for i:=low(Prm) to high(Prm) do Prm[i]:=Sender.Params[i+1];
  Aborted:=false; pr(Sender,Prm,Aborted);
  if Aborted then Sender.Abort;
  DelStack;
end;

initialization
  AddStack('FStat.initialization');
  TKeyLb.SetFixKey(K_Alt_T,'Время выполнения последнего индикатора',TStat.LastTimeMsg,kmDesign);
  DelStack;
end.
