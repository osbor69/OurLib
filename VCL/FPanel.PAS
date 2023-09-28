unit Fpanel;

interface

uses
  Windows,Messages,Classes,Controls,Forms,ExtCtrls,
  MyTypes,Schem,PaintCtl;

type
  TCustomRbPanel = class;

	TWMWHMin = record
   	Msg: longint;
    WMin: Word;
		RbPnl: TCustomRbPanel;
    Result: LongInt;
	end;

  TPaintSay = class(TPaintControl)
  private
  	//FAlignment: TAlignment;
  	FFocusControl: TComponent;
		//procedure SetAlignment(Value: TAlignment);
		//procedure SetFocusControl(Value: TCustomRbPanel);
		function CaptArr(var a: array of string): longint;
		function BevFld: longint;
  protected
		procedure CaptionChange; override;
		procedure FontChange(Sender: TObject); override;
    procedure FPaint; override;
		procedure FSetBounds(const Value: TRect); override;
		procedure ParentFont; override;
  public
    NoPaint: boolean;
  	TabOrderControl: TCustomRbPanel;
		constructor CreatePrm(const ACaption: TCaption; AOwner: TCustomRbPanel;
    	ATabOrderControl: TCustomRbPanel = nil);
    destructor Destroy; override;
   	procedure DoClick; override;
		function perform(Msg: longword; WParam,LParam: Longint): Longint; override;
  	//property Alignment: TAlignment read FAlignment write SetAlignment;
  	property FocusControl: TComponent read FFocusControl write FFocusControl;
  end;

  TCustomRbPanel = class(TCustomPanel)
  private
  { Private declarations }
  	FPaintSay: TPaintSay;
    FWmin,FHmin: longint;
    FParentSchem,FMinSized,FSayRight,SelfShowHint,ShowHintCng: boolean;
    FPlace: TRbPanelPlace;
    FSchem: string;
    //FCanRedraw: boolean;
    FOnSetWHMin: TNotifyEvent;
    nActivePaint: longint;
    //procedure SetCanRedraw(Value: boolean);
    function GetSayCaption: string;
    procedure SetParentSchem(Value: boolean);
    procedure SetSayCaption(const Value: string);
    procedure SetSchem(const Value: string);
    //property CanRedraw: boolean read FCanRedraw write SetCanRedraw;
		procedure SetSchemSay(sch: TSchem);
    procedure WMSchem(var msg: TWMSchem); message WM_SCHEM;
		procedure WMSchemName(var Message: TWMSchemName); message WM_SCHEMNAME;
		procedure WMWHMin(var Message: TWMWHMin); message WM_WHMIN;
  	procedure WMApplHint(var Msg: TWMApplHint); message WM_APPLHINT;
    procedure WMPSort(var Message: TWMPSort); message WM_PSORT;
    procedure CMShowHintChanged(var Msg: TMessage); message CM_SHOWHINTCHANGED;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
  	procedure CMEnabledChanged(var Message: TMessage); message CM_EnabledChanged;
		//procedure WMNoSetRedraw(var Message: TMessage); message WM_NOSETREDRAW;
  protected
  { Protected declarations }
    procedure CreateWnd; override;
	 	procedure SetParent(AParent: TWinControl); override;
		procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: longint); Override;
    procedure MouseMove(Shift: TShiftState; X,Y: longint); Override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: longint); Override;
    procedure DoEnter; override;
    procedure DoExit; override;
		function GetCltRect: TRect; virtual;
		function GetPaintCtlActive(Sender: TObject): boolean; virtual;
    property SayRight: boolean read FSayRight write FSayRight;
  public
  { Public declarations }
  	//NoSetRedraw: boolean;
    property Canvas;
	 	function BevPanel: byte;
	 	function BevPanel2: byte;
    property WMin: longint read FWmin write FWmin;
    property HMin: longint read FHmin write FHmin;
  	property PaintSay: TPaintSay read FPaintSay;
    property Place: TRbPanelPlace read FPlace write FPlace;
    property SayCaption: string read GetSayCaption write SetSayCaption;
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
	 	procedure SetBounds(ALeft,ATop,AWidth,AHeight: longint); override;
    procedure ReBuild(wm,hm: longint); virtual;
    function SetWHMin(tp: TCustomRbPanel; wm: longint): boolean; dynamic;
	 	function CltWidth: longint;
	 	function CltHeight: longint;
    function GetNewParentPlace(OldPlace: TRbPanelPlace; X,Y: longint): TRbPanelPlace;
		function HeaderHeight: longint; virtual;
    procedure IncWMin(d2: longint);
    procedure IncHMin(d2: longint);
    procedure MaxWMin(d2: longint);
    procedure MaxHMin(d2: longint);
    procedure SeekChild(var tp1,tp2: TCustomRbPanel);
    function GetPlace: TRbPanelPlace;
  published
    property MinSized: boolean read FMinSized write FMinSized;
    property ParentSchem: boolean read FParentSchem write SetParentSchem;
    property Schem: string read FSchem write SetSchem;
    property OnSetWHMin: TNotifyEvent read FOnSetWHMin write FOnSetWHMin;
  { Унаследованные }
    property Color;
    property Ctl3D;
    property Font;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
  end;

  {TSvBevel = record
  	bvInner,bvOuter: TPanelBevel;
		bvWidth: TBevelWidth;
  end;}

  TRebuildOper = (rbEval,rbBefore,rbAfter);

  TRbPanel = class;
	TWMRebuild = record
   	Msg: longint;
    Oper: TRebuildOper;
		RbPnl: TRbPanel;
    Result: LongInt;
	end;

  TRbPanel = class(TCustomRbPanel)
  private
  { Private declarations }
    FSortObj: boolean;
    FSortMode: TSortMode;
    FCanSize,FCanMove,FMaxWidth: boolean;
    FProcentWnd: TProcent;
    FHeader: string;
    FOnAfterPaint: TNotifyEvent;
  	oRsz: TNotifyEvent;
    procedure SetHeader(const Value: string);
    procedure SetSortMode(Value: TSortMode);
    function HeaderRows(var a: TArrStr): longint; overload;
    function HeaderRows: longint; overload;
    function MouseOpt: TRszMouse;
  	procedure WMRebuild(var Message: TWMRebuild); message WM_REBUILD;
    procedure WMGetDlgCode(var Msg: TWmGetDlgCode); message wm_GetDlgCode;
  	procedure WMSaveIni(var Msg: TWMSaveIni); message WM_SAVEINI;
    procedure WMPSort(var Message: TWMPSort); message WM_PSORT;
  protected
  { Protected declarations }
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: longint); Override;
    procedure MouseMove(Shift: TShiftState; X,Y: longint); Override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: longint); Override;
    procedure Paint; override;
		function GetCltRect: TRect; override;
  public
  { Public declarations }
    constructor Create(AOwner:TComponent); override;
    procedure ReBuild(wm,hm: longint); override;
    {function GetBevels: TSvBevel;
		procedure SetBevels(const SvBevel: TSvBevel);}
    procedure Sort(Condens: boolean = false);
		function HeaderHeight: longint; override;
		function SetWHMin(tp: TCustomRbPanel; wm: longint): boolean; override;
		procedure PaintHeader; virtual;
    procedure RebuildControls;
  published
  { Published declarations }
    property CanSize: boolean read FCanSize write FCanSize;
    property CanMove: boolean read FCanMove write FCanMove;
    property MaxWidth: boolean read FMaxWidth write FMaxWidth;
    property Header: string read FHeader write SetHeader;
    property ProcentWnd: TProcent read FProcentWnd write FProcentWnd;
    property SortMode: TSortMode read FSortMode write SetSortMode;
    property SortObj: boolean read FSortObj write FSortObj;
    property OnAfterPaint: TNotifyEvent read FOnAfterPaint write FOnAfterPaint;
  { Унаследованные }
    property ParentShowHint;
    property ShowHint;
    property Alignment;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BorderStyle;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Caption;
    property HMin;
    property Locked;
    property Place;
    property PopupMenu;
    property SayCaption;
    property SayRight;
    property TabOrder;
    property TabStop;
    property Visible;
    property WMin;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

  TRBSTSectType = (mstLeft,mstRight);
  TRBSTMouseInfo = record
  	SectType: TRBSTSectType;
    SectNum: longint;
  end;

  TRBSTSectProc = procedure(SectType: TRBSTSectType; i,y: longint; const r: TRect; ts: TSchem;
  	const av: array of variant; var lAbort: boolean) of object;

  TRBSTStrings = class(TStringList)
  private
  protected
    function Get(Index: Integer): string; override;
    procedure Put(Index: longint; const S: string); override;
	end;

  TRbStatus = class(TCustomRbPanel)
  private
  	FSect: array[TRBSTSectType] of record
      ls: TRBSTStrings;
      atp: TArrInt;
    end;
    cX,cY: longint;
    FSimpleLine: boolean;
    function GetSect(tp: TRBSTSectType): TRBSTStrings;
    function GetSectType(tp: TRBSTSectType; Index: longint): longint;
    procedure SetSect(tp: TRBSTSectType; Value: TRBSTStrings);
    procedure SetSectType(tp: TRBSTSectType; Index,Value: longint);
		procedure SectChange(Sender: TObject);
		function ProcSect(Proc: TRBSTSectProc; const av: array of variant): TRBSTMouseInfo;
		procedure prPaint(SectType: TRBSTSectType; i,y: longint; const r: TRect; ts: TSchem;
    	const av: array of variant; var lAbort: boolean);
		procedure prMouseMove(SectType: TRBSTSectType; i,y: longint; const r: TRect; ts: TSchem;
    	const av: array of variant; var lAbort: boolean);
		procedure prMouseInfo(SectType: TRBSTSectType; i,y: longint; const r: TRect; ts: TSchem;
    	const av: array of variant; var lAbort: boolean);
		procedure prRect(SectType: TRBSTSectType; i,y: longint; const r: TRect; ts: TSchem;
    	const av: array of variant; var lAbort: boolean);
    function LineDlm: char;
  protected
    procedure MouseMove(Shift: TShiftState; X,Y: longint); Override;
    procedure Paint; override;
    procedure CanvasSectType(ts: TSchem; tp: TRBSTSectType; Index: longint); virtual;
  public
  { Public declarations }
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
		function SetWHMin(tp: TCustomRbPanel; wm: longint): boolean; override;
    procedure ReBuild(wm,hm: longint); override;
		function MouseInfo: TRBSTMouseInfo;
    function MinHeight: longint;
		function SectRect(const inf: TRBSTMouseInfo): TRect;
    property SectType[tp: TRBSTSectType; Index: longint]: longint read GetSectType write SetSectType;
  published
  { Published declarations }
  	property SimpleLine: boolean read FSimpleLine write FSimpleLine;
  	property SectLeft: TRBSTStrings index mstLeft read GetSect write SetSect;
  	property SectRight: TRBSTStrings index mstRight read GetSect write SetSect;
  { Унаследованные }
    property ParentShowHint;
    property ShowHint;
    property Alignment;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BorderStyle;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Caption;
    property Locked;
    property PopupMenu;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

const RbPanelProcentWnd = 'RbPanelProcentWnd.';

procedure Register;
procedure SetSchemAppl;
procedure SetSchemForm(Sender: TControl);
procedure MsgRebuild(Sender: TControl; Oper: TRebuildOper = rbEval);
procedure MainRebuild(Sender: TControl; lSetRdw: boolean = true);
procedure RbFormResize(Sender: TForm);
procedure RspColRow(Sender: TObject; cntCol: byte);

implementation

uses SysUtils,Graphics,Math,
  My_pr,PSort;

const wSpl = 3;

var
	oW: longint = 0;
	oH: longint = 0;
  oFr: TForm;
  pnPrcParent: TCustomRbPanel;
  pnSplit: TPanel;

{ TPaintSay }
constructor TPaintSay.CreatePrm;
var ts: TSchem;
begin
  AddStack('TPaintSay.CreatePrm',Self);
  inherited Create(AOwner);
  Canvas:=AOwner.Canvas;
  if SchemName(AOwner.Schem,ts) then Font.Assign(ts.Font2) else Font.Assign(AOwner.Font);
  Caption:=ACaption; TabOrderControl:=ATabOrderControl;
  DelStack;
end;

destructor TPaintSay.Destroy;
begin
	AddStack('TPaintSay.Destroy',Self);
  if FFocusControl is TCustomRbPanel then TCustomRbPanel(FFocusControl).FPaintSay:=nil;
  inherited Destroy;
  DelStack;
end;

procedure TPaintSay.FPaint;
var fl: boolean;
	i,{l,}t,ln,h: longint;
	a: array[1..10] of string;
  tw: TWinControl;
begin
	AddStack('TPaintSay.FPaint',Self);
  with Canvas do begin
  	if Owner is TCustomPanel
      then Brush.Color:=TPanel(Owner).Color
    else if ParentClass(tw,TCustomControl(Owner).Parent,TCustomPanel)
      then Brush.Color:=TPanel(tw).Color;
    FillRect(Bounds); fl:=not NoPaint;
    if fl and Assigned(FFocusControl) then fl:=TPaintControl.MsgPaint(FFocusControl);
    if fl then begin
      Font.Assign(Self.Font);
      {Pen.Color:=TCustomControl(Owner).Color; Brush.Color:=Pen.Color;
      Rectangle(0,0,Width-1,Height-1);}
      ln:=CaptArr(a); t:=Bounds.Top+BevFld; h:=CanvasMaxH(Canvas);
      for i:=1 to ln do begin
        {if Alignment=taLeftJustify then l:=0
        else begin
          l:=Width-TextWidth(a[i]);
          if Alignment=taCenter then DivD(l,2);
        end;}
        TextOut(Bounds.Left{+l},t,a[i]); Inc(t,h);
      end;
    end;
  end;
  DelStack;
end;

procedure TPaintSay.CaptionChange;
begin
	AddStack('TPaintSay.CaptionChange',Self);
  Bounds:=Bounds;
  inherited CaptionChange;
  DelStack;
end;

procedure TPaintSay.FontChange;
begin
	AddStack('TPaintSay.FontChange',Self);
  Bounds:=Bounds;
  inherited FontChange(Sender);
  DelStack;
end;

procedure TPaintSay.FSetBounds;
var h,l: longint;
	a: array[1..10] of string;
  r: TRect;
begin
	AddStack('TPaintSay.FSetBounds',Self);
  r:=Value; r.Right:=0; Dec(r.Bottom,r.Top); Canvas.Font.Assign(Font);
  l:=CaptArr(a); h:=BevFld+CanvasMaxH(Canvas)*l;
  while l>0 do begin
    MaxSelf(r.Right,Canvas,a[l]); Dec(l);
  end;
  MaxSelf(r.Bottom,h); Inc(r.Right,r.Left); Inc(r.Bottom,r.Top);
	inherited FSetBounds(r);
  DelStack;
end;

procedure TPaintSay.ParentFont;
begin
end;

function TPaintSay.BevFld;
begin
  AddStack('TPaintSay.BevFld',Self);
  result:=0;
  if Assigned(FFocusControl) then
    if not(FFocusControl is TPaintControl) then result:=BevelFld;
  DelStack;
end;

{procedure TPaintSay.SetFocusControl;
begin
  AddStack('TPaintSay.SetFocusControl',Self);
  if Value<>FFocusControl then begin
  	if Assigned(FFocusControl) then FFocusControl.FPaintSay:=nil;
  	FFocusControl:=Value;
  	if Assigned(FFocusControl) then FFocusControl.FPaintSay:=Self;
    //Owner:=FFocusControl.Parent; Canvas:=FFocusControl.Parent.Canvas;
    Paint;
  end;
  DelStack;
end;}

{procedure TPaintSay.SetAlignment;
begin
	AddStack('TPaintSay.SetAlignment',Self);
  if Value<>FAlignment then begin
  	FAlignment:=Value; Paint;
  end;
  DelStack;
end;}

function TPaintSay.CaptArr;
const cDlm = #31;
var i: longint;
begin
  AddStack('TPaintSay.CaptArr',Self);
  result:=ListAsArray(StrTran(Caption,'\'+UnDelim,cDlm),a,UnDelim);
  for i:=low(a) to low(a)+result do StrTranSelf(a[i],cDlm,UnDelim);
  DelStack;
end;

procedure TPaintSay.DoClick;
var p: TCustomRbPanel;
begin
	AddStack('TPaintSay.DoClick',Self);
  if IsClass(FFocusControl,TCustomRbPanel,pointer(p)) then
    if p.CanFocus then p.SetFocus;
  inherited DoClick;
  DelStack;
end;

function TPaintSay.perform;
begin
	AddStack('TPaintSay.perform',Self);
  result := inherited perform(Msg,WParam,LParam);
  if (Msg=WM_PSORT) and Assigned(FFocusControl) then
  	case TPSortOper(WParam) of
      swmFocusControl: result:=LongInt(FFocusControl);
	    swmColWidthAll,swmColHeightAll: result:=TPaintControl.ObjPerform(FFocusControl,Msg,WParam,LParam);
    end;
  if (Msg=WM_PAINTCTL) and (TPaintCtlOper(WParam)=pcmTabOrdCtl) then
    if Assigned(TabOrderControl) then result:=Longint(TabOrderControl);
  DelStack;
end;

{ TCustomRbPanel }
constructor TCustomRbPanel.Create;
begin
	AddStack('TCustomRbPanel.Create',Self);
	Inherited Create(AOwner);
  //FCanRedraw:=true;
  IncD(Self,[],[csSetCaption]);
  if not(csDesigning in ComponentState) then Parent:=pointer(Owner);
  ParentFont:=true; ParentSchem:=true; FPlace:=rpNone; nActivePaint:=-1;
  DelStack;
end;

destructor TCustomRbPanel.Destroy;
var ost: longint;
begin
	ost:=AddStack('TCustomRbPanel.Destroy',Self);
  try
	  FreeAndNil(FPaintSay);
  except
    SetStack(ost);
  end;
  inherited Destroy;
  DelStack;
end;

procedure TCustomRbPanel.CreateWnd;
begin
	AddStack('TCustomRbPanel.CreateWnd',Self);
  inherited CreateWnd;
  SetParentSchem(FParentSchem);
  DelStack;
end;

{procedure TCustomRbPanel.SetCanRedraw(Value: boolean);
begin
	if Value<>FCanRedraw then begin
	  FCanRedraw:=Value; //perform(WM_SETREDRAW,Ord(Value),0);
  	//if Value then Refresh;
  end;
end;}

procedure TCustomRbPanel.SetParent;
var fl: boolean;
	s: string;
begin
	AddStack('TCustomRbPanel.SetParent',Self);
  fl:=AParent<>Parent;
	inherited SetParent(AParent);
  if fl and Assigned(FPaintSay) then begin
  	s:=SayCaption; SayCaption:=''; SayCaption:=s;
  end;
  SetParentSchem(FParentSchem);
  DelStack;
end;

{procedure TCustomRbPanel.WMNoSetRedraw(var Message: TMessage);
begin
	AddStack('TCustomRbPanel.WMNoSetRedraw',Self);
	if NoSetRedraw then Message.Result:=1;
  DelStack;
end;}

procedure TCustomRbPanel.WMWHMin;
begin
	AddStack('TCustomRbPanel.WMWHMin',Self);
	SetWHMin(nil,Message.WMin);
  DelStack;
end;

function TCustomRbPanel.SetWHMin;
var tp1,tp2: TCustomRbPanel;
	i: longint;
begin
	AddStack('TCustomRbPanel.SetWHMin',Self);
	if FPlace=rpNone then
  	for i:=0 to ControlCount-1 do Controls[i].perform(WM_WHMIN,wm,LongInt(Self))
  else begin
    SeekChild(tp1,tp2);
    if Assigned(tp1) then
    	if tp1.SetWHMin(tp2,wm) and Assigned(tp2) then tp2.SetWHMin(tp1,wm);
    if Assigned(tp1) and Assigned(tp2) then
      if FPlace in [rpTop,rpBottom] then begin
        FWMin:=max(tp1.FWMin,tp2.FWMin);
        FHMin:=tp1.FHMin+tp2.FHMin;
      end
      else begin
        FWMin:=tp1.FWMin+tp2.FWMin;
        FHMin:=max(tp1.FHMin,tp2.FHMin);
      end
    else if Assigned(tp1) then begin
    	FWMin:=tp1.FWMin; FHMin:=tp1.FHMin;
    end
    else begin
      FWMin:=0; FHMin:=0;
    end;
    Inc(FHMin,HeaderHeight+BevPanel2); Inc(FWMin,BevPanel2);
  end;
  //if FMinSized then SetBounds(Left,Top,FWMin,FHMin);
	IfThenNotify(FOnSetWHMin,Self); result:=true;
  DelStack;
end;

function TCustomRbPanel.CltWidth;
begin
	AddStack('TCustomRbPanel.CltWidth',Self);
  result:=Width-BevPanel2;
  DelStack;
end;

function TCustomRbPanel.CltHeight;
begin
	AddStack('TCustomRbPanel.CltHeight',Self);
  result:=Height-BevPanel2;
  DelStack;
end;

function TCustomRbPanel.HeaderHeight;
begin
	result:=0;
end;

procedure TCustomRbPanel.IncWMin;
begin
  WMin:=WMin+d2;
end;

procedure TCustomRbPanel.IncHMin;
begin
  HMin:=HMin+d2;
end;

procedure TCustomRbPanel.MaxWMin;
begin
  MaxSelf(FWmin,d2);
end;

procedure TCustomRbPanel.MaxHMin;
begin
  MaxSelf(FHmin,d2);
end;

{ Возвращает толщину границ TCustomRbPanel }
function TCustomRbPanel.BevPanel;
begin
	AddStack('TCustomRbPanel.BevPanel',Self);
  result:=0;
	if (BevelInner<>bvNone) or (BevelOuter<>bvNone) then begin
    if BevelInner<>bvNone then Inc(result,BevelWidth);
    if BevelOuter<>bvNone then Inc(result,BevelWidth);
    Inc(result);
  end;
  DelStack;
end;

function TCustomRbPanel.BevPanel2;
begin
	result:=BevPanel shl 1;
end;

procedure TCustomRbPanel.SetParentSchem;
var tw: TWinControl;
	n: longint;
begin
	AddStack('TCustomRbPanel.SetParentSchem',Self);
	if Value then begin
  	tw:=Parent;
    while Assigned(tw) do begin
    	n:=tw.perform(WM_SCHEMNAME,byte(snGetSchem),0);
      if n<>0 then begin
      	Schem:=PString(n)^; break;
      end;
      ParentSelf(tw);
    end;
  end;
  FParentSchem:=Value;
  DelStack;
end;

function TCustomRbPanel.GetSayCaption;
begin
	AddStack('TCustomRbPanel.GetSayCaption',Self);
  if Assigned(FPaintSay) then result:=FPaintSay.Caption else result:='';
  DelStack;
end;

procedure TCustomRbPanel.SetSayCaption;
begin
	AddStack('TCustomRbPanel.SetSayCaption',Self);
  if Value<>GetSayCaption then
  	if Value='' then begin
    	FreeAndNil(FPaintSay); Parent.Invalidate;
    end
    else begin
    	if not Assigned(FPaintSay) then begin
      	FPaintSay:=TPaintSay.Create(Parent); FPaintSay.Visible:=Visible;
        if Parent is TCustomRbPanel
	        then FPaintSay.Canvas:=TCustomRbPanel(Parent).Canvas
        else if Parent is TCustomForm
  	      then FPaintSay.Canvas:=TCustomForm(Parent).Canvas
        else FPaintSay.Canvas:=pointer(Parent.Perform(WM_PAINTCTL,byte(pcmCanvas),0));
        FPaintSay.FFocusControl:=Self;
        SetSchemSay(SchemName(Schem));
      end;
    	FPaintSay.Caption:=Value; SetBounds(Left,Top,Width,Height);
    end;
  DelStack;
end;

procedure TCustomRbPanel.SetSchem;
var i: longint;
begin
	AddStack('TCustomRbPanel.SetSchem',Self);
	if Value<>FSchem then FParentSchem:=false;
	FSchem:=Value;
  for i:=0 to ControlCount-1 do
  	Controls[i].perform(WM_SCHEMNAME,byte(snSetSchem),LongInt(@FSchem));
  DelStack;
end;

procedure TCustomRbPanel.WMSchem;
begin
  AddStack('TCustomRbPanel.WMSchem',Self);
	if Assigned(msg.Schem) then begin
    Color:=msg.Schem.ColorW; Font.Assign(msg.Schem.FontW);
	end
  else begin
  	Color:=clBtnFace; DefaultFont(Font);
  end;
  SetSchemSay(msg.Schem);
  DelStack;
end;

procedure TCustomRbPanel.SetSchemSay;
begin
  AddStack('TCustomRbPanel.SetSchemSay',Self);
  if Assigned(FPaintSay) then
    if Assigned(sch) then FPaintSay.Font.Assign(sch.Font2)
    else DefaultFont(FPaintSay.Font);
  DelStack;
end;

procedure TCustomRbPanel.WMSchemName;
begin
	AddStack('TCustomRbPanel.WMSchemName',Self);
	with Message do case Oper of
    snGetSchem: result:=LongInt(@FSchem);
    snSetSchem: if FParentSchem then begin
      Schem:=SchemName^; FParentSchem:=true;
    end;
  end;
  DelStack;
end;

procedure TCustomRbPanel.SetBounds;
begin
	AddStack('TCustomRbPanel.SetBounds',Self);
  if (csDesigning in ComponentState) and Assigned(FPaintSay) then begin
    FPaintSay.SetBounds(ALeft-FPaintSay.Width,ATop,0,0); InvalidateAll(Parent);
  end;
  inherited SetBounds(ALeft,ATop,AWidth,AHeight);
  DelStack;
end;

procedure TCustomRbPanel.ReBuild;
var w,h{,hs}: longint;
  tp1,tp2: TCustomRbPanel;
  r: TRect;
begin
	AddStack('TCustomRbPanel.ReBuild',Self);
  //hs:=BevPanel;
  if FPlace<>rpNone then begin
  	SeekChild(tp1,tp2); r:=GetCltRect;
	  if Assigned(tp1) and Assigned(tp2) then begin
      if FPlace in[rpTop,rpBottom] then begin
      	w:=max(r.Right-r.Left,tp2.FWMin); h:=r.Bottom-r.Top-tp2.FHMin; tp1.ReBuild(w,h);
		    w:=r.Right-r.Left; h:=r.Bottom-r.Top-tp1.Height; tp2.ReBuild(w,h);
        w:=MaxIntValue([w,tp1.Width,tp2.Width]);
   	   	SetBounds(Left,Top,w+Width-r.Right+r.Left,
        	max(Height,tp1.Height+tp2.Height+Height-r.Bottom+r.Top));
        r:=GetCltRect;
        h := (r.Bottom-r.Top-tp1.Height-tp2.Height) div 3;
				if FPlace=rpTop then begin
	        tp1.SetBounds(r.Left,r.Top+h,w,tp1.Height);
	       	tp2.SetBounds(r.Left,r.Top+tp1.Height+2*h,w,tp2.Height);
	      end
        else begin
        	tp2.SetBounds(r.Left,r.Top+h,w,tp2.Height);
          tp1.SetBounds(r.Left,r.Top+tp2.Height+2*h,w,tp1.Height);
        end;
      end
      else begin
      	w:=r.Right-r.Left-tp2.FWMin; h:=max(r.Bottom-r.Top,tp2.FHMin); tp1.ReBuild(w,h);
        w:=r.Right-r.Left-tp1.Width; h:=r.Bottom-r.Top; tp2.ReBuild(w,h);
        w:=MaxIntValue([h,tp1.Height,tp2.Height]);
        SetBounds(Left,Top,
        	max(Width,tp1.Width+tp2.Width+Width-r.Right+r.Left),
          w+Height-r.Bottom+r.Top);
        r:=GetCltRect;
        h := (r.Right-r.Left-tp1.Width-tp2.Width) div 3;
				if FPlace=rpLeft then begin
        	tp1.SetBounds(r.Left+h,r.Top,tp1.Width,w);
          tp2.SetBounds(r.Left+tp1.Width+2*h,r.Top,tp2.Width,w);
        end
        else begin
        	tp2.SetBounds(r.Left+h,r.Top,tp2.Width,w);
          tp1.SetBounds(r.Left+tp2.Width+2*h,r.Top,tp1.Width,w);
        end;
      end;
    end
   	else if Assigned(tp1) then begin
      tp1.ReBuild(r.Right-r.Left,r.Bottom-r.Top);
      SetBounds(Left,Top,max(Width,tp1.Width+Width-r.Right+r.Left),
        max(Height,tp1.Height+Height-r.Bottom+r.Top));
      r:=GetCltRect;
      h := (r.Bottom-r.Top-tp1.Height) div 2;
      w := (r.Right-r.Left-tp1.Width) div 2;
      tp1.SetBounds(r.Left+w,r.Top+h,tp1.Width,tp1.Height);
    end;
  end;
  SetBounds(Left,Top,max(Width,FWMin),max(Height,FHmin));
  DelStack;
end;

function TCustomRbPanel.GetCltRect;
var bv: longint;
begin
  AddStack('TCustomRbPanel.GetCltRect',Self);
  bv:=BevPanel; result:=Rect(bv,bv,Width-bv,Height-bv);
  DelStack;
end;

procedure TCustomRbPanel.SeekChild;
var i: longint;
  tp: TCustomRbPanel;
begin
	AddStack('TCustomRbPanel.SeekChild',Self);
  tp1:=nil; tp2:=nil;
  if FPlace<>rpNone then begin
    for i:=0 to ControlCount-1 do if IsClass(Controls[i],TCustomRbPanel,pointer(tp)) then
      if tp.Visible then
        if Assigned(tp1) then tp2:=tp else tp1:=tp;
    if Assigned(tp1) and Assigned(tp2) then
      if tp1.Tag>tp2.Tag then begin
        tp:=tp1; tp1:=tp2; tp2:=tp;
      end;
  end;
	DelStack;
end;

function TCustomRbPanel.GetPlace;
begin
	AddStack('TCustomRbPanel.GetPlace',Self);
  if Parent is TCustomRbPanel then result:=TCustomRbPanel(Parent).Place else result:=rpNone;
  DelStack;
end;

procedure TCustomRbPanel.Paint;
begin
  AddStack('TCustomRbPanel.Paint',Self);
  inherited Paint;
  TPaintControl.PaintAll(Self);
  DelStack;
end;

function TCustomRbPanel.GetPaintCtlActive;
begin
	result:=true;
end;

procedure TCustomRbPanel.MouseDown;
begin
	AddStack('TCustomRbPanel.MouseDown',Self);
  if nActivePaint<0 then inherited MouseDown(Button,Shift,X,Y)
  else if GetPaintCtlActive(Components[nActivePaint]) then with TPaintControl(Components[nActivePaint]) do begin
  	MouseDown(Button,Shift,X-Left,Y-Top);
	  if Button=mbLeft then Click;
  end;
  DelStack;
end;

procedure TCustomRbPanel.MouseMove;
var fl: boolean;
begin
	AddStack('TCustomRbPanel.MouseMove',Self);
  nActivePaint:=TPaintControl.nActivePaint(Self,X,Y); fl:=SelfShowHint;
  if nActivePaint<0 then inherited MouseMove(Shift,X,Y)
  else if GetPaintCtlActive(Components[nActivePaint]) then with TPaintControl(Components[nActivePaint]) do begin
  	MouseMove(Shift,X-Left,Y-Top);
	  if not SelfShowHint then fl:=ShowHint;
  end;
  ShowHintCng:=true; ShowHint:=fl; ShowHintCng:=false;
  DelStack;
end;

procedure TCustomRbPanel.MouseUp;
begin
	AddStack('TCustomRbPanel.MouseUp',Self);
  if nActivePaint<0 then inherited MouseUp(Button,Shift,X,Y)
  else if GetPaintCtlActive(Components[nActivePaint]) then with TPaintControl(Components[nActivePaint]) do
  	MouseUp(Button,Shift,X-Left,Y-Top);
  DelStack;
end;

procedure TCustomRbPanel.DoEnter;
begin
	AddStack('TCustomRbPanel.DoEnter',Self);
  if not IsCalculator then inherited DoEnter;
  DelStack;
end;

procedure TCustomRbPanel.DoExit;
begin
	AddStack('TCustomRbPanel.DoExit',Self);
  if not IsCalculator then inherited DoExit;
  DelStack;
end;

procedure TCustomRbPanel.WMApplHint;
begin
	AddStack('TCustomRbPanel.WMApplHint',Self);
  with Msg.Info^ do begin
    if nActivePaint>=0 then with TPaintControl(Components[nActivePaint]) do begin
      HintStr:=Hint; CanShow:=ShowHint; HintInfo.HintStr:=Hint;
    end;
    HintInfo.ReshowTimeout:=100;
  end;
  DelStack;
end;

procedure TCustomRbPanel.WMPSort;
begin
	AddStack('TCustomRbPanel.WMPSort',Self);
  inherited;
	with Message do
    if Oper=swmSayRight then
      if FSayRight then Result:=1;
  DelStack;
end;

procedure TCustomRbPanel.CMShowHintChanged;
begin
	AddStack('TCustomRbPanel.CMShowHintChanged',Self);
  inherited;
  if not ShowHintCng then SelfShowHint:=ShowHint;
  DelStack;
end;

procedure TCustomRbPanel.CMVisibleChanged;
begin
  AddStack('TCustomRbPanel.CMVisibleChanged',Self);
  inherited;
  if Assigned(FPaintSay) then FPaintSay.Visible:=Visible;
  DelStack;
end;

procedure TCustomRbPanel.CMEnabledChanged;
begin
	AddStack('TCustomRbPanel.CMEnabledChanged',Self);
	inherited;
  if Assigned(FPaintSay) then FPaintSay.Enabled:=Enabled;
  DelStack;
end;

function TCustomRbPanel.GetNewParentPlace;
var lx,ly,cx,cy,hx,hy,w,h:longint;
begin
  AddStack('TCustomRbPanel.GetNewParentPlace',Self);
  if Parent is TCustomRbPanel then with TCustomRbPanel(Parent) do begin
    w:=CltWidth; h:=CltHeight;
  end
  else with Parent do begin
    w:=ClientWidth; h:=ClientHeight;
  end;
  lx := min(w div 2,50); ly := min(h div 2,50);
  cx:=Left+X; cy:=Top+Y; hx:=w-cx; hy:=h-cy;
  result:=iif((hy<ly) and (hy<cx) and (hy<hx),rpBottom,
    iif((hx<lx) and (hx<cy) and (hx<hy),rpRight,
    iif((cy<ly) and (cy<cx) and (cy<hx),rpTop,
    iif((cx<lx) and (cx<cy) and (cx<hy),rpLeft,OldPlace))));
  DelStack;
end;

{ TRbPanel }
constructor TRbPanel.Create;
begin
	AddStack('TRbPanel.Create',Self);
	Inherited Create(AOwner);
  //Parent:=pointer(Owner);
  FSortObj:=true; FSortMode:=smDefault;
  DelStack;
end;

procedure TRbPanel.WMRebuild;
begin
	AddStack('TRbPanel.WMRebuild',Self);
  if (Parent is TCustomRbPanel) and FMinSized and FMaxWidth then Width:=TCustomRbPanel(Parent).CltWidth;
  RebuildControls;
  DelStack;
end;

procedure TRbPanel.RebuildControls;
var i: longint;
begin
  AddStack('TRbPanel.RebuildControls',Self);
  for i:=0 to ControlCount-1 do MsgRebuild(Controls[i]);
  Sort;
  DelStack;
end;

procedure TRbPanel.WMGetDlgCode;
begin
	AddStack('TRbPanel.WMGetDlgCode',Self);
	inherited;
  Msg.Result:=dlgc_WantArrows;
  DelStack;
end;

procedure TRbPanel.WMSaveIni;
var Section,Ident: string;
begin
  AddStack('TRbPanel.WMSaveIni',Self);
	Section:=Msg.pSection^;
  if Section<>'' then begin
    Ident:=RbPanelProcentWnd+Name;
    case Msg.Oper of
      opsSave: if InRange(FProcentWnd,1,99)
        then InitFIni[fiSave].WriteInteger(Section,Ident,FProcentWnd);
      opsRest: if InitFIni[fiSave].ValueExists(Section,Ident) then
        if InRange(FProcentWnd,1,99)
        then FProcentWnd:=EnsureRange(InitFIni[fiSave].ReadInteger(Section,Ident,FProcentWnd),1,99);
    end;
  end;
  DelStack;
end;

procedure TRbPanel.WMPSort;
var tw: TWinControl;
	l,r,r1: longint;
begin
	AddStack('TRbPanel.WMPSort',Self);
  inherited;
	with Message do case Oper of
    swmColWidthAll: if FMaxWidth then Result:=wallDefault;
    swmSortInfo: with si^ do begin
      Mode:=SortMode; Height:=CltHeight-HeaderHeight; result:=1;
      if Mode=smDefault then begin
        r:=ClientOrigin.X; l:=r+BevPanel; Width:=l+CltWidth; Inc(r,Self.Width); tw:=Parent;
        while Assigned(tw) do begin
          if tw is TScrollingWinControl then begin
            r1:=tw.ClientOrigin.X+tw.ClientWidth;
            if r>r1 then Width:=min(Width,r1-SysMetric.iScrollWidth);
          end;
          ParentSelf(tw);
        end;
        Dec(Width,l);
      end
      else Width:=CltWidth-SysMetric.iScrollWidth;
    end;
  end;
  DelStack;
end;

function TRbPanel.HeaderRows(var a: TArrStr): longint;
begin
  AddStack('TRbPanel.HeaderRows');
  result:=LsArrDynamic(FHeader,a,UnDelim);
  DelStack;
end;

function TRbPanel.HeaderRows: longint;
var a: TArrStr;
begin
  result:=HeaderRows(a);
end;

procedure TRbPanel.SetHeader;
var l: longint;
begin
	AddStack('TRbPanel.SetHeader',Self);
	if FHeader<>Value then begin
	  l:=HeaderRows; FHeader:=Value;
    if not(csDesigning in ComponentState) and (HeaderRows<>l) then RebuildControls;
    Refresh;
  end;
  DelStack;
end;

procedure TRbPanel.SetSortMode;
begin
	AddStack('TRbPanel.SetSortMode',Self);
	if Value<>FSortMode then begin
    FSortMode:=Value;
    if not(csDesigning in ComponentState) then Sort;
  end;
  DelStack;
end;

function TRbPanel.SetWHMin;
var i,t,b,l,r: longint;
	tc: TControl;
	ps: TPaintSay;
  fl,lh,lw: boolean;
  a: TArrStr;
begin
	AddStack('TRbPanel.SetWHMin',Self);
  FHMin:=HeaderHeight+1;
  fl := (FPlace=rpNone) and FSortObj and (FSortMode<>smDefault) and (ControlCount>0);
	if fl then begin
  	result := inherited SetWHMin(tp,wm);
    Sort(true); t:=MaxInt; b:=-MaxInt; l:=MaxInt; r:=-MaxInt; lh:=false; lw:=false;
    for i:=0 to ControlCount-1 do begin
			tc:=Controls[i];
      if tc.Visible then begin
        //if MsgPSort(tc,swmColHeightAll)=0 then begin
	        MinSelf(t,tc.Top); MaxSelf(b,tc.Top+tc.Height); lh:=true;
        //end;
        if MsgPSort(tc,swmColWidthAll)=0 then begin
		      MinSelf(l,tc.Left); MaxSelf(r,tc.Left+tc.Width); lw:=true;
        end;
      end;
    end;
    for i:=0 to ComponentCount-1 do if IsClass(Components[i],TPaintSay,pointer(ps)) then
      if ps.Visible then begin
        //if MsgPSort(ps,swmColHeightAll)=0 then begin
          MinSelf(t,ps.Top); MaxSelf(b,ps.Bounds.Bottom); lh:=true;
        //end;
        if MsgPSort(ps,swmColWidthAll)<>wallDefault then begin
          MinSelf(l,ps.Left); MaxSelf(r,ps.Bounds.Right); lw:=true;
        end;
      end;
    Canvas.Font.Assign(Font); FWMin:=IfThen(lw,r-l+BevPanel2);
    for i:=0 to HeaderRows(a)-1 do MaxSelf(FWMin,Canvas.TextWidth(a[i])+10);
    FHMin:=IfThen(lh,b-t+BevPanel2,1)+HeaderHeight;
  end
  else result:=false;
  if FMinSized then SetBounds(Left,Top,FWMin,FHMin);
  if not fl then result := inherited SetWHMin(tp,wm);
  DelStack;
end;

procedure TRbPanel.Paint;
var b,l,r: longint;
begin
	AddStack('TRbPanel.Paint',Self);
	inherited Paint;
  if FHeader<>'' then with Canvas do begin
  	b:=HeaderHeight; PaintHeader;
    Pen.Width:=1; Pen.Style:=psSolid; Pen.Color:=clBlack;
    l:=BevPanel; r:=Width-l-1; MoveTo(l,b); LineTo(r,b);
    Pen.Color:=clWhite; Inc(b); MoveTo(l,b); LineTo(r,b);
  end;
  IfThenNotify(FOnAfterPaint,Self);
  DelStack;
end;

procedure TRbPanel.PaintHeader;
var r: TRect;
  a: TArrStr;
  i,h: longint;
begin
	AddStack('TRbPanel.PaintHeader',Self);
  with Canvas do begin
    r.Top:=BevPanel; r.Left:=r.Top; h:=CanvasMaxH(Canvas);
    for i:=0 to HeaderRows(a)-1 do begin
      r.Bottom:=r.Top+h-IfThen(i=high(a),1);
      r.Right:=r.Left+min(TextWidth(a[i])+2,Self.Width-BevPanel2);
      TextRect(r,r.Left+2,r.Top,a[i]); r.Top:=r.Bottom;
    end;
  end;
  DelStack;
end;

procedure TRbPanel.ReBuild;
var tp: TCustomRbPanel;
  p: real;
  w,h: double;
  rr: TRect;
begin
	AddStack('TRbPanel.ReBuild',Self);
  p:=FProcentWnd/100; w:=wm*p; h:=hm*p;
  if IsClass(Parent,TCustomRbPanel,pointer(tp)) then begin
    rr:=tp.GetCltRect;
    case tp.Place of
      rpTop,rpBottom: begin
        h:=hm-FHMin; MultD(h,p);
        SetBounds(0,0,rr.Right-rr.Left,FHMin+nround(h));
      end;
      rpLeft,rpRight: begin
        w:=wm-FWMin; MultD(w,p);
        SetBounds(0,0,FWMin+nround(w),rr.Bottom-rr.Top);
      end;
    else SetBounds(0,0,nround(w),nround(h));
    end;
  end
  else SetBounds(0,0,nround(w),nround(h));
  inherited ReBuild(wm,hm);
  RebuildControls;
  DelStack;
end;

function TRbPanel.GetCltRect;
var h: longint;
begin
  AddStack('TRbPanel.GetCltRect',Self);
  result := inherited GetCltRect;
  h:=HeaderHeight;
  if h>0 then Inc(result.Top,h-1);
  DelStack;
end;

procedure TRbPanel.MouseDown;
var p: TPoint;
begin
	AddStack('TRbPanel.MouseDown',Self);
	oRsz:=onResize; onResize:=nil;
  inherited MouseDown(Button,Shift,X,Y);
	RszMouseDown(Self,Button,Shift,X,Y,MouseOpt);
  if (Button=mbLeft) and ((Cursor=crHSplit) or (Cursor=crVSplit)) and Assigned(pnPrcParent) then begin
    p:=ClientToScreen(PnPrcParent.ScreenToClient(Point(X,Y)));
    PnSplit:=TPanel.Create(PnPrcParent);
    with PnSplit do begin
    	Parent:=PnPrcParent; Color:=InvColor(Color); BevelInner:=bvNone; BevelOuter:=bvNone;
      if PnPrcParent.FPlace in [rpTop,rpBottom]
      then SetBounds(0,p.Y,PnPrcParent.Width,wSpl)
      else SetBounds(p.X,0,wSpl,PnPrcParent.Height);
    end;
  end;
  DelStack;
end;

procedure TRbPanel.MouseMove;
const Lim = 5;
var tp1,tp2: TCustomRbPanel;
	tw: TWinControl;
	cr: TCursor;
  p,pSelf: TPoint;
begin
	AddStack('TRbPanel.MouseMove',Self);
	RszMouseMove(Self,Shift,X,Y,MouseOpt);
  pSelf:=ClientToScreen(Point(X,Y));
  if Assigned(PnSplit) then with PnSplit do begin
  	p:=PnPrcParent.ScreenToClient(pSelf);
    if PnPrcParent.FPlace in [rpTop,rpBottom]
    then SetBounds(0,p.Y,PnPrcParent.Width,wSpl)
    else SetBounds(p.X,0,wSpl,PnPrcParent.Height);
  end
  else begin
    cr:=IfThen(FCanSize or FCanMove,Cursor,crDefault); pnPrcParent:=nil; tw:=Self;
    while Assigned(tw) do begin
      if tw is TCustomRbPanel then with TCustomRbPanel(tw) do begin
        SeekChild(tp1,tp2);
        if Assigned(tp1) and Assigned(tp2) then
          if (tp1 is TRbPanel) and (tp2 is TRbPanel) then
            if InRange(TRbPanel(tp1).FProcentWnd,1,99) then begin
            	p:=ScreenToClient(pSelf);
              case FPlace of
                rpTop: if InRange(p.Y,tp1.Height-Lim,tp1.Height+Lim) then cr:=crVSplit;
                rpBottom: if InRange(p.Y,tp2.Height-Lim,tp2.Height+Lim) then cr:=crVSplit;
                rpLeft: if InRange(p.X,tp1.Width-Lim,tp1.Width+Lim) then cr:=crHSplit;
                rpRight: if InRange(p.X,tp2.Width-Lim,tp2.Width+Lim) then cr:=crHSplit;
              end;
              if cr<>crDefault then begin
	            	PnPrcParent:=pointer(tw); break;
              end;
            end;
      end;
      ParentSelf(tw);
    end;
    Cursor:=cr;
  end;
  inherited MouseMove(Shift,X,Y);
  DelStack;
end;

procedure TRbPanel.MouseUp;
var fl: boolean;
	nPrc: Double;
  n: longint;
  prc: TProcent;
	tp1,tp2: TCustomRbPanel;
  PnPrc: TRbPanel;
begin
	AddStack('TRbPanel.MouseUp',Self);
  onResize:=oRsz; IfThenNotify(oRsz,Self);
	if (FCanSize or FCanMove) and (Button=mbLeft)
  then fl := RszMouseUp(Self,Button,Shift,X,Y,MouseOpt)=[rmResize]
  else fl:=false;
  if Assigned(PnSplit) then begin
  	PnPrcParent.SeekChild(tp1,tp2);
    SetRedraw(PnPrcParent);
    tp1.SetWHMin(PnPrcParent,PnPrcParent.CltWidth);
    tp2.SetWHMin(PnPrcParent,PnPrcParent.CltWidth);
    SetRedraw(PnPrcParent,rdrwSet);
    PnPrc:=pointer(tp1);
    if PnPrcParent.FPlace in [rpTop,rpBottom] then begin
      n:=PnSplit.Top-tp1.FHMin; nPrc:=PnPrcParent.CltHeight-tp1.FHmin-tp2.FHmin;
    end
    else begin
      n:=PnSplit.Left-tp1.FWMin; nPrc:=PnPrcParent.CltWidth-tp1.FWmin-tp2.FWmin;
    end;
    if nPrc=0 then nPrc:=1
    else begin
      nPrc:=n/nPrc;
      if PnPrcParent.FPlace in [rpBottom,rpRight] then nPrc:=1-nPrc;
    end;
    prc:=EnsureRange(nround(nPrc*100),1,99); fl:=true; PnPrc.FProcentWnd:=prc;
    FreeAndNil(PnSplit);
  end;
  if fl then MainRebuild(Self);
  inherited MouseUp(Button,Shift,X,Y);
  DelStack;
end;

function TRbPanel.MouseOpt;
begin
  AddStack('TRbPanel.MouseOpt',Self);
  result:=[];
  if FCanSize then Include(result,rmResize);
  if FCanMove then Include(result,rmRemove);
  DelStack;
end;

procedure TRbPanel.Sort;
var h,h1: longint;
begin
	AddStack('TRbPanel.Sort',Self);
	if FSortObj and (FPlace=rpNone) then begin
  	h:=BevPanel; h1:=HeaderHeight;
    //if h=0 then Inc(h1);
 		PSortObj(Self,h,h+h1,CltWidth,CltHeight-h1,FSortMode,Condens);
  end;
  DelStack;
end;

function TRbPanel.HeaderHeight;
begin
	AddStack('TRbPanel.HeaderHeight',Self);
  result := inherited HeaderHeight;
  if FHeader<>'' then begin
    Canvas.Font:=Font; result:=CanvasMaxH(Canvas)*HeaderRows+2;
  end;
  DelStack;
end;

{function TRbPanel.GetBevels: TSvBevel;
begin
	AddStack('TRbPanel.GetBevels',Self);
	with result do begin
		BvInner:=BevelInner; BvOuter:=BevelOuter; BvWidth:=BevelWidth;
  end;
  DelStack;
end;

procedure TRbPanel.SetBevels;
begin
	AddStack('TRbPanel.SetBevels',Self);
	with SvBevel do begin
	  BevelInner:=BvInner;
    BevelOuter:=BvOuter;
    BevelWidth:=BvWidth;
  end;
  DelStack;
end;

{ TRBSTStrings }
function TRBSTStrings.Get;
begin
  AddStack('TRBSTStrings.Get');
  if InRange(Index,0,Count-1) then result:=inherited Get(Index) else result:='';
  DelStack;
end;

procedure TRBSTStrings.Put;
begin
	AddStack('TRBSTStrings.Put');
  while Index>=Count do Add('');
  inherited Put(Index,s);
  DelStack;
end;

{ TRbStatus }
const
	iW   = 3;
  iDlm = 1;

constructor TRbStatus.Create;
var tp: TRBSTSectType;
begin
	AddStack('TRbStatus.Create',Self);
	Inherited Create(AOwner);
  Alignment:=taLeftJustify; Tag:=-1; Schem:='Status';
  BevelInner:=bvNone; BevelOuter:=bvLowered;
  for tp:=low(FSect) to high(FSect) do with FSect[tp] do begin
    ls:=TRBSTStrings.Create; TStringList(ls).onChange:=SectChange;
  end;
  DelStack;
end;

destructor TRbStatus.Destroy;
var tp: TRBSTSectType;
begin
	AddStack('TRbStatus.Destroy',Self);
  for tp:=low(FSect) to high(FSect) do FSect[tp].ls.Free;
  inherited Destroy;
  DelStack;
end;

function TRbStatus.GetSect;
begin
	AddStack('TRbStatus.GetSect',Self);
  result:=FSect[tp].ls;
  DelStack;
end;

procedure TRbStatus.SetSect;
begin
	AddStack('TRbStatus.SetSect',Self);
  FSect[tp].ls.Assign(Value); Invalidate;
  DelStack;
end;

procedure TRbStatus.SectChange;
begin
	AddStack('TRbStatus.SectChange',Self);
	Invalidate;
  DelStack;
end;

procedure TRbStatus.Paint;
begin
	AddStack('TRbStatus.Paint',Self);
	inherited Paint;
  ProcSect(prPaint,[]);
  DelStack;
end;

procedure TRbStatus.CanvasSectType;
begin
  AddStack('TRbStatus.CanvasSectType',Self);
  if Assigned(ts) then with Canvas do
    if SectType[tp,Index]=1 then begin
      Brush.Color:=ts.Color1; Font.Assign(ts.Font1);
    end
    else begin
      Brush.Color:=ts.ColorW; Font.Assign(ts.FontW);
    end;
  DelStack;
end;

function TRbStatus.ProcSect;
var i,w: longint;
  ts: TSchem;
  procedure wCalc;
  var a: TArrStr;
    j: longint;
  begin
    AddStack('TRbStatus.ProcSect.wCalc',Self);
  	CanvasSectType(ts,result.SectType,i); w:=0;
    for j:=0 to LsArrDynamic(FSect[result.SectType].ls[i],a,LineDlm)-1 do
      MaxSelf(w,Canvas.TextWidth(a[j]));
    DelStack;
  end;
var y: longint;
	r: TRect;
  function brk(SectType: TRBSTSectType; i: longint): boolean;
  begin
    AddStack('TRbStatus.ProcSect.brk',Self);
    result:=false; Proc(SectType,i,y,r,ts,av,result);
    DelStack;
  end;
const
	iW2 = iW shl 1;
  iDlm2 = iDlm shl 1;
var y1,lb,rb: longint;
label lend;
begin
  AddStack('TRbStatus.ProcSect',Self);
  if not(csDesigning in ComponentState) and empty(Caption) then with Canvas do begin
    if not SchemName(Schem,ts) then begin
      Brush.Color:=Self.Color; Font.Assign(Self.Font);
    end;
    y:=BevPanel; y1:=y-iDlm-1; lb:=y1; rb:=Width-y1; r:=Rect(y1,y1,rb,Height-y1);
    result.SectType:=mstLeft;
    for i:=0 to FSect[result.SectType].ls.Count-2 do begin
      wCalc; r.Right:=min(Width-y1,r.Left+w+iDlm2+iW2);
      result.SectNum:=i;
      if brk(mstLeft,i) then goto lend;
      r.Left:=r.Right; lb:=r.Left;
    end;
    result.SectType:=mstRight;
    r.Right:=Width-y1;
    for i:=0 to FSect[result.SectType].ls.Count-1 do begin
      wCalc; rb:=max(y1,r.Right-w-iDlm2-iW2);
      if rb<=lb then break;
      r.Left:=rb; result.SectNum:=i;
      if brk(mstRight,i) then goto lend;
      r.Right:=r.Left;
    end;
    r.Left:=lb; r.Right:=rb;
    result.SectType:=mstLeft; result.SectNum:=FSect[result.SectType].ls.Count-1;
    CanvasSectType(ts,result.SectType,FSect[result.SectType].ls.Count-1);
    if brk(mstLeft,result.SectNum) then goto lend;
    result.SectNum:=0;
  end;
lend:
  DelStack;
end;

procedure TRbStatus.prPaint;
var j: longint;
  ls: TStrings;
  function StrHeight: longint;
  var i1: longint;
    a1: TArrStr;
  begin
  	AddStack('TRbStatus.prPaint.StrHeight',Self);
    result:=0;
    for i1:=0 to ls.Count-1 do begin
      CanvasSectType(ts,SectType,i1);
      if LsArrDynamic(ls[i1],a1,LineDlm)>j then MaxSelf(result,Canvas.TextHeight(a1[j]));
    end;
    CanvasSectType(ts,SectType,i);
    DelStack;
  end;
var r1,r2: TRect;
  a: TArrStr;
begin
	AddStack('TRbStatus.prPaint',Self);
	r1:=r; Frame3D1(Canvas,r1,true,iDlm); ls:=IfThen(SectType=mstLeft,SectLeft,SectRight);
  if InRange(i,0,ls.Count-1) then begin
    j:=LsArrDynamic(ls[i],a,LineDlm);
    if j>0 then begin
      r2:=r1; Inc(r2.Left,iW);
      if GetPlace=rpBottom then for j:=j-1 downto 0 do begin
        r2.Top:=max(r1.Top,r2.Bottom-Canvas.TextHeight(a[j]));
        Canvas.TextRect(r2,r2.Left,r2.Top,a[j]); Dec(r2.Bottom,StrHeight);
        if r2.Bottom<r1.Top then break;
      end
      else for j:=0 to j-1 do begin
        r2.Bottom:=r2.Top+StrHeight; r2.Top:=r2.Bottom-Canvas.TextHeight(a[j]);
        Canvas.TextRect(r2,r2.Left,r2.Top,a[j]); r2.Top:=r2.Bottom;
        if r2.Top>r1.Bottom then break;
      end;
    end;
  end;
  DelStack;
end;

procedure TRbStatus.ReBuild;
begin
	AddStack('TRbStatus.ReBuild',Self);
  SetBounds(0,0,wm,hm);
  if Parent is TCustomRbPanel
  then SetBounds(Left,Top,TCustomRbPanel(Parent).CltWidth,MinHeight);
  inherited ReBuild(wm,hm);
  DelStack;
end;

function TRbStatus.SetWHMin;
begin
	AddStack('TRbStatus.SetWHMin',Self);
  FHMin:=MinHeight;
  if not empty(Caption) then begin
    Canvas.Font.Assign(Font); FWMin:=Canvas.TextWidth(TrimRight(Caption))+BevPanel2;
  end;
	result := inherited SetWHMin(tp,wm);
  DelStack;
end;

function TRbStatus.MinHeight;
var i: longint;
  tp: TRBSTSectType;
  ts: TSchem;
begin
  AddStack('TRbStatus.MinHeight',Self);
  SchemName(Schem,ts); result:=0;
  for tp:=low(FSect) to high(FSect) do
    for i:=0 to FSect[tp].ls.Count-1 do begin
      CanvasSectType(ts,tp,i); MaxSelf(result,CanvasMaxH(Canvas)*(StrCount(LineDlm,FSect[tp].ls[i])+1));
    end;
  if result=0 then begin
    Canvas.Font.Assign(Font); MaxSelf(result,Canvas,true);
  end;
  Inc(result,BevPanel2);
  DelStack;
end;

function TRbStatus.LineDlm;
begin
  result:=IfThenChar(FSimpleLine,#0,UnDelim);
end;

procedure TRbStatus.MouseMove;
begin
	AddStack('TRbStatus.MouseMove',Self);
	cX:=X; cY:=Y; ProcSect(prMouseMove,[]);
	inherited MouseMove(Shift,X,Y);
  DelStack;
end;

procedure TRbStatus.prMouseMove;
begin
	AddStack('TRbStatus.prMouseMove',Self);
  prMouseInfo(SectType,i,y,r,ts,av,lAbort);
  if lAbort then begin
    Hint:=FSect[SectType].ls[i]; ShowHint := Canvas.TextWidth(Hint)>r.Right-r.Left;
  end;
  DelStack;
end;

function TRbStatus.MouseInfo;
begin
  AddStack('TRbStatus.MouseInfo',Self);
  result:=ProcSect(prMouseInfo,[]);
  DelStack;
end;

procedure TRbStatus.prMouseInfo;
begin
	AddStack('TRbStatus.prMouseInfo',Self);
	if InRange(cX,r.Left,r.Right) and InRange(cY,r.Top,r.Bottom) then lAbort:=true;
  DelStack;
end;

function TRbStatus.SectRect;
begin
  AddStack('TRbStatus.SectRect',Self);
  ZeroMemory(@result,SizeOf(result)); ProcSect(prRect,[LongInt(@inf),LongInt(@result)]);
  DelStack;
end;

procedure TRbStatus.prRect;
var inf: ^TRBSTMouseInfo;
begin
	AddStack('TRbStatus.prRect',Self);
  inf:=PointerVar(av[0]);
  if (SectType=inf.SectType) and (i=inf.SectNum) then begin
    PRect(LongInt(av[1]))^:=r; lAbort:=true;
  end;
  DelStack;
end;

function TRbStatus.GetSectType;
begin
  AddStack('TRbStatus.GetSectType',Self);
  with FSect[tp] do if InRange(Index,low(atp),high(atp)) then result:=atp[Index] else result:=0;
  DelStack;
end;

procedure TRbStatus.SetSectType;
var i: longint;
begin
  AddStack('TRbStatus.SetSectType',Self);
  if SectType[tp,Index]<>Value then with FSect[tp] do begin
    i:=Length(atp);
    if i<=Index then begin
      SetLength(atp,Index+1);
      while i<Length(atp) do begin
        atp[i]:=0; Inc(i);
      end;
    end;
    atp[Index]:=Value; Invalidate;
  end;
  DelStack;
end;

{ Установка цветов и шрифтов для всех форм приложения }
procedure SetSchemAppl;
var i: longint;
	tf: TForm;
begin
	AddStack('FPanel.SetSchemAppl');
	for i:=0 to LsSchem.Count-1 do TSchem(LsSchem.Objects[i]).SetToAppl;
	for i:=0 to Application.ComponentCount-1 do if IsClass(Application.Components[i],TForm,pointer(tf)) then begin
    SetSchemForm(tf); MainRebuild(tf);
  end;
  if not IconLoad(Application.Icon,IconFileName)
  then Application.Icon.Handle:=LoadIcon(HInstance,'MAINICON');
  DelStack;
end;

{ Установка цветов и шрифтов для формы Sender }
procedure FProcControlsMsgSchem(Sender: TControl; const av: array of variant; var Done: boolean);
var LParam: PLongint;
begin
  AddStack('Fpanel.FProcControlsMsgSchem');
  LParam:=PointerVar(av[0]);
  if Sender is TCustomRbPanel then LParam^:=LongInt(SchemName(TCustomRbPanel(Sender).Schem));
  if (Sender is TCustomRbPanel) or (Sender is TCustomForm) or Assigned(pointer(LParam^))
  then Sender.Perform(WM_SCHEM,byte(soBefore),LParam^);
  DelStack;
end;

procedure SetSchemForm;
var LParam: longint;
begin
	AddStack('FPanel.SetSchemForm');
  LParam:=0; ProcControls(Sender,FProcControlsMsgSchem,[Longint(@LParam)]);
  if Sender is TCustomForm then Sender.perform(WM_SCHEM,byte(soAfter),0);
  if GetParentForm(Sender)=oFr then oFr:=nil;
  DelStack;
end;

procedure MsgRebuild;
begin
  AddStack('FPanel.MsgRebuild');
  Sender.Perform(WM_REBUILD,byte(Oper),longint(IsClass(Sender.Parent,TRbPanel)));
  DelStack;
end;

{ Rebuild основной панели }
procedure MainRebuild;
var f: TForm;
	tw: TWinControl;
  sc: TSvScroll;
  tp: TCustomRbPanel;
begin
	AddStack('FPanel.MainRebuild');
  //ProfOn;
  if ParentForm(Sender,f) then with f do
    if ControlsClass(f,TCustomRbPanel,pointer(tp)) then begin
      tw:=ActiveControl; sc:=ClrScroll(Sender);
      if lSetRdw then SetRedraw(tp);
      MsgRebuild(f,rbBefore); tp.SetBounds(0,0,0,0);
      tp.SetWHMin(nil,ClientWidth); tp.ReBuild(ClientWidth,ClientHeight);
      MsgRebuild(f,rbAfter);
      if lSetRdw then SetRedraw(tp,rdrwSet);
      SetScroll(Sender,sc); ActiveControl:=tw;
    end;
  //ProfOut;
  DelStack;
end;

procedure RbFormResize;
begin
	AddStack('FPanel.RbFormResize');
  if (oFr<>Sender)
  or (oW<>Sender.Width) or (oH<>Sender.Height) then begin
    oW:=Sender.Width; oH:=Sender.Height; oFr:=Sender; MainRebuild(Sender);
  end;
  DelStack;
end;

procedure RspColRow;
var cntRow,i,j,n,cnt: byte;
	l,t,w,h: longint;
  ls: TList;
begin
  AddStack('FPanel.RspColRow');
  if Sender is TRbPanel then h:=TRbPanel(Sender).HeaderHeight else h:=0;
  ls:=TList.Create;
  try
    with TCustomRbPanel(Sender) do begin
      GetTabOrderList(ls); cnt:=ls.Count;
      if cnt>0 then begin
        cntRow:=Ceil(cnt/cntCol); n:=0; w:=CltWidth div cntCol; h:=(CltHeight-h) div cntRow; l:=BevPanel;
        for i:=1 to cntCol do begin
          t:=BevPanel+HeaderHeight;
          for j:=1 to cntRow do begin
            if n=cnt then break;
            TControl(ls[n]).SetBounds(l,t,IfThen(i=cntCol,Width-BevPanel-l,w),
              IfThen(j=cntRow,Height-BevPanel-t,h));
            Inc(n); Inc(t,h);
          end;
          Inc(l,w);
        end;
      end;
    end;
  finally
    ls.Free;
  end;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurLib',[TRbPanel,TRbStatus]);
end;

end.
