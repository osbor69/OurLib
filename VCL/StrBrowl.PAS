unit StrBrowl;

interface

uses
  Windows,Messages,Classes,Graphics,Controls,Forms,Grids,
  MyTypes,KeyLb,KeyMenu,FPanel,Schem,My_pr;

type
  TSBNumCalc = function(Sender: TObject; ACol,ARow,X,Y: longint): string of object;
  TSBWidthColsEvent = procedure(Sender: TObject; ACol: longint) of object;

	TCustomStringBrowl = class(TStringGrid)
  private
    { Private declarations }
    FKeyPanel: TKeyLb;
    FKeyDblClick,NoSelCol,NoSelRow: longint;
    FOnNumCalc: TSBNumCalc;
    FOnBeforePaint,FOnAfterPaint: TNotifyEvent;
    FOnBeforeDrawCell: TDrawCellEvent;
    FOnShowHint: TShowHintEvent;
    sCalc: string;
    lDrag,FFiltered: boolean;
    FTitleFont: TFont;
		function GetTopLeft: TGridCoord;
		procedure SetTopLeft(const Value: TGridCoord);
    procedure MoveColRowCur;
    procedure SetFiltered(Value: boolean);
		function brfind(Sender: TControl; const sf: string): boolean;
		procedure EnabledKeys(MainMn: TKeyMenu);
		procedure DelKeys;
		procedure ProcKey(key: longint; tw: TWinControl);
		function InfCellRect(ACol,ARow: longint): TRect;
		procedure DrawFixedCol(ACol: longint);
		procedure BeforeDrawFixedCol(ACol: longint); virtual;
    procedure IncLeftCol(const d2: longint);
    procedure WMGetDlgCode(var Msg: TWmGetDlgCode); message wm_GetDlgCode;
		procedure WMWHMin(var Message: TWMWHMin); message WM_WHMIN;
   	procedure WMRebuild(var msg: TWMRebuild); message WM_REBUILD;
		procedure WMCalc(var msg: TWMCalc); message WM_CALC;
    procedure WMSchem(var msg: TWMSchem); message WM_SCHEM;
  	procedure WMApplHint(var Msg: TWMApplHint); message WM_APPLHINT;
  protected
    function OffsLeftAlign(ACol,ARow: longint; const r: TRect): longint;
		procedure DblClick; override;
		procedure DragOver(Source: TObject; X,Y: longint;
    	State: TDragState; var Accept: Boolean); override;
		procedure DoEndDrag(Target: TObject; X,Y: longint); override;
  	procedure Paint; override;
    procedure TopLeftChanged; override;
		procedure BeforeDrawCell(ACol,ARow: longint; const ARect: TRect; State: TGridDrawState); dynamic;
		procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
		procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
    function SelectCell(ACol,ARow: Longint): Boolean; override;
    function GetFindOptions: TFindOptions; virtual;
    procedure PrFindAll(ARow: longint); virtual;
    procedure FilteredChanged; virtual;
  public
    NoSel: boolean;
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
		procedure DoEnter; override;
		procedure DoExit; override;
    function BoxRect(ALeft, ATop, ARight, ABottom: Longint): TRect;
    function CellRect: TRect; overload;
    function AlignCell(ACol,ARow: longint): TAlignment; dynamic; abstract;
    function GridsWidth(ColEnd: longint = MaxInt): longint; virtual;
    function GridsHeight(RowEnd: longint = MaxInt): longint;
    procedure IncFixedRows(d2: longint = 1);
    procedure IncFixedCols(d2: longint = 1);
    procedure IncRowCount(d2: longint = 1);
    //procedure IncColCount(d2: longint = 1);
    procedure IncRow(d2: longint = 1);
    procedure IncOptions(Incl: TGridOptions; Excl: TGridOptions = []);
    procedure MaxRowHeights(Index: Longint; const d2: longint);
    procedure MaxColWidths(Index: Longint; const d2: longint);
    function IntObj(ACol,ARow: longint): longint; overload;
    function IntObj(ARow: longint): longint; overload;
    function LongWordObj(ACol,ARow: longint): longword;
    function BoolObj(ACol,ARow: longint): boolean; overload;
    function BoolObj(ARow: longint): boolean; overload;
    procedure bmCheckPaint(ACol,ARow: longint); overload;
    procedure bmCheckPaint(ACol,ARow: longint; cSet: char); overload;
  	property Filtered: boolean read FFiltered write SetFiltered;
		property TopLeft: TGridCoord read GetTopLeft write SetTopLeft;
  published
  	property KeyDblClick: longint read FKeyDblClick write FKeyDblClick;
		property TitleFont: TFont read FTitleFont write FTitleFont;
    property OnAfterPaint: TNotifyEvent read FOnAfterPaint write FOnAfterPaint;
    property OnBeforePaint: TNotifyEvent read FOnBeforePaint write FOnBeforePaint;
		property OnBeforeDrawCell: TDrawCellEvent read FOnBeforeDrawCell write FOnBeforeDrawCell;
		property OnNumCalc: TSBNumCalc read FOnNumCalc write FOnNumCalc;
    property OnShowHint: TShowHintEvent read FOnShowHint write FOnShowHint;
  end;

	TStrBrCalcZn = function(Sender: TObject; ACol: longint): string of object;
  //TStrBrBefEdit = function(lFirst: boolean): boolean of object;
	TStrBrUnKey = procedure(var UnKey: longint; lWrite: boolean) of object;

  PStringBrowl = ^TStringBrowl;
  TStringBrowl = class(TCustomStringBrowl)
  private
    { Private declarations }
    FColZn: TStringList;
    aColZn: array of TStrBrInfZn;
    lColZn: longint;
    FKeys: TIntegerList;
    FSelectedOnlyFocused: boolean;
    FOnCalcZn: TStrBrCalcZn;
    //FOnBeforeEdit: TStrBrBefEdit;
    FOnUnKey: TStrBrUnKey;
    FOnWidthCols: TSBWidthColsEvent;
    function GetInfoCol(Index: longint): TStrBrInfZn;
   	procedure SetColZn(Value: TStringList);
    procedure SetInfoCol(Index: longint; Value: TStrBrInfZn);
		function ZnOneCol(const nmFld: string; ACol: Longint): string;
		function FixZn(const nmFld: string): string;
		procedure tmTimer(Sender: TObject);
   	procedure WMRebuild(var msg: TWMRebuild); message WM_REBUILD;
  protected
    { Protected declarations }
    procedure Loaded; override;
		procedure DrawCell(ACol,ARow: longint; ARect: TRect; State: TGridDrawState); override;
    function SelectCell(ACol,ARow: Longint): Boolean; override;
    function CalcZn(ACol: longint): string; dynamic;
  public
    { Public declarations }
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
    procedure WidthCols;
    function GridsWidth(ColEnd: longint = MaxInt): longint; override;
		procedure ColZnChange(Sender: TObject = nil);
    procedure Init;
    //function BeforeEdit(lFirst: boolean): boolean; dynamic;
    function AlignCell(ACol,ARow: longint): TAlignment; override;
		procedure SetUnKey(var UnKey: longint; lWrite: boolean); dynamic;
    function CurUnKey: longint;
    procedure AddSt; overload;
    procedure AddSt(cnt: longint); overload;
    procedure DelSt;
    function DelLast: boolean;
    procedure CurStUpdate(ARow: longint = NegDef);
		//procedure CallRebuild(Sender: TRbPanel);
    procedure AdjustColsWidth;
    function GetRowRect(aLeft,aRight,aTop: longint; aBottom: longint = NegDef): TRect;
    procedure IncColWidths(ACol: longint; const d2: longint);
   	property InfoCol[Index: longint]: TStrBrInfZn read GetInfoCol write SetInfoCol;
  published
    { Published declarations }
   	property ColZn: TStringList read FColZn write SetColZn;
    property SelectedOnlyFocused: boolean read FSelectedOnlyFocused write FSelectedOnlyFocused;
		property OnCalcZn: TStrBrCalcZn read FOnCalcZn write FOnCalcZn;
		//property OnBeforeEdit: TStrBrBefEdit read FOnBeforeEdit write FOnBeforeEdit;
		property OnUnKey: TStrBrUnKey read FOnUnKey write FOnUnKey;
    property OnWidthCols: TSBWidthColsEvent read FOnWidthCols write FOnWidthCols;
  end;

  TStrTblGrayCellEvent = function(Sender: TObject; X,Y: Word; const ARect: TRect; State: TGridDrawState): boolean of object;
  TStrTblAlignCellEvent = procedure(Sender: TObject; ACol,ARow: longint; var Alignment: TAlignment) of object;

  TStrTable = class(TCustomStringBrowl)
  private
    { Private declarations }
    FAlignCells: TAlignment;
    FHead: array[1..2] of TStrings;
    FCapt: array[1..2] of string;
    FCanInvert,InvertedIniReaded,isFocus,FInvertedIniDefault,FInverted: boolean;
    FMinColLength,SelCol,SelRow: longint;
    FOnFill,FOnSetInverted,FOnHeadWHCalc: TNotifyEvent;
    FOnGrayCell: TStrTblGrayCellEvent;
    FOnAlignCell: TStrTblAlignCellEvent;
    LabelCol: TPaintSay;
    FInvertedIniSect: string;
		function GetCapt(Index: longint): string;
		function GetDatCells(X,Y: Word): string;
		function GetDatObjects(X,Y: Word): TObject;
		function GetHead(Index: longint): TStrings;
		function GetInverted: boolean;
		procedure SetCanInvert(Value: boolean);
		procedure SetCapt(Index: longint; const Value: string);
		procedure SetDatCells(X,Y: Word; const Value: string);
		procedure SetDatObjects(X,Y: Word; Value: TObject);
		procedure SetHead(Index: longint; Value: TStrings);
		procedure SetInverted(Value: boolean);
    procedure SetInvertedIniSect(const Value: string);
		function nCol: byte;
		function nRow: byte;
		procedure ProcInverted(key: longint; tw: TWinControl); 
		procedure SetTab(Value: boolean);
		procedure BeforeDrawFixedCol(ACol: longint); override;
    procedure WMSchem(var msg: TWMSchem); message WM_SCHEM;
   	procedure WMRebuild(var msg: TWMRebuild); message WM_REBUILD;
  protected
    { Protected declarations }
  	procedure Paint; override;
		procedure DrawCell(ACol,ARow: longint; ARect: TRect; State: TGridDrawState); override;
    function SelectCell(ACol,ARow: Longint): Boolean; override;
		procedure HeadWHCalc;
  public
    { Public declarations }
    NoColWidthsCorr: boolean;
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
		procedure DoEnter; override;
		procedure DoExit; override;
		procedure Fill(X: Word = 0; Y: Word = 0; Opt: TStrTableFillOpt = []); virtual;
		procedure ColRowToXY(aCol,aRow: longint; var X,Y: Word); overload;
		procedure ColRowToXY(var X,Y: Word); overload;
		procedure XYToColRow(var X,Y: Word); overload;
		procedure XYToColRow(X,Y: Word; var ACol,ARow: longint); overload;
    function AlignCell(ACol,ARow: longint): TAlignment; override;
    function GrayCell(X,Y: Word; const ARect: TRect; State: TGridDrawState): boolean; dynamic;
		//function DatCellRect(X,Y: Word): TRect;
    property Inverted: boolean read GetInverted write SetInverted;
    property DatCells[X,Y: Word]: string read GetDatCells write SetDatCells;
    property DatObjects[X,Y: Word]: TObject read GetDatObjects write SetDatObjects;
  published
    { Published declarations }
    property AlignCells: TAlignment read FAlignCells write FAlignCells default taCenter;
    property CanInvert: boolean read FCanInvert write SetCanInvert default true;
    property CaptX: string index 1 read GetCapt write SetCapt;
    property CaptY: string index 2 read GetCapt write SetCapt;
    property HeadX: TStrings index 1 read GetHead write SetHead;
    property HeadY: TStrings index 2 read GetHead write SetHead;
    property MinColLength: longint read FMinColLength write FMinColLength;
    property InvertedIniDefault: boolean read FInvertedIniDefault write FInvertedIniDefault;
    property InvertedIniSect: string read FInvertedIniSect write SetInvertedIniSect;
    property OnAlignCell: TStrTblAlignCellEvent read FOnAlignCell write FOnAlignCell;
    property OnFill: TNotifyEvent read FOnFill write FOnFill;
    property OnGrayCell: TStrTblGrayCellEvent read FOnGrayCell write FOnGrayCell;
    property OnHeadWHCalc: TNotifyEvent read FOnHeadWHCalc write FOnHeadWHCalc;
    property OnSetInverted: TNotifyEvent read FOnSetInverted write FOnSetInverted;
  end;

function IfThenStrTblGray(AValue: boolean; ATrue: TStrTblGrayCellEvent; AFalse: TStrTblGrayCellEvent = nil): TStrTblGrayCellEvent;
function StringBrowlVar(const v: variant): TStringBrowl;
procedure Register;

implementation

uses SysUtils,ClipBrd,ExtCtrls,StrUtils,Math,
  RecVal;

const cDlmName = '^';
	wDlm = 2;

var tm: TTimer;

{ TCustomStringBrowl }
constructor TCustomStringBrowl.Create;
begin
	AddStack('TCustomStringBrowl.Create',Self);
	Inherited Create(AOwner);
  FTitleFont:=TFont.Create; DefaultFont(FTitleFont);
  Parent:=pointer(AOwner);
  if csDesigning in ComponentState then begin
	  FixedRows:=1; FixedCols:=0;
  end;
  Options:=[goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goRowSizing,goColSizing];
  FKeyDblClick:=K_Enter;
  DelStack;
end;

destructor TCustomStringBrowl.Destroy;
begin
	AddStack('TCustomStringBrowl.Destroy',Self);
  DelKeys; FTitleFont.Free;
  inherited Destroy;
  DelStack;
end;

// Реакция на двойной щелчок
procedure TCustomStringBrowl.DblClick;
begin
	AddStack('TCustomStringBrowl.DblClick',Self);
	if FormKeyLb(Self,FKeyPanel) then FKeyPanel.ExecKey(FKeyDblClick);
  inherited DblClick;
  DelStack;
end;

procedure TCustomStringBrowl.DoEnter;
var MainMn: TKeyMenu;
begin
	AddStack('TCustomStringBrowl.DoEnter',Self);
  if not IsCalculator then begin
    if FormKeyLb(Self,FKeyPanel) then with FKeyPanel do begin
      SetKeyFind(ProcKey,'strbrowl');
      if goRowSelect in Options then begin
        SetKey(K_LEFT,'','Влево',ProcKey,'strbrowl',kmList);
        SetKey(K_RIGHT,'','Вправо',ProcKey,'strbrowl',kmList);
      end;
      SetKey(K_Ctrl_C,'','Скопировать',ProcKey,'strbrowl',kmList);
      Redrw;
      if SeekKeyMenu(Self,MainMn) then begin
        MainMn.InsLine(kmList,K_F6); EnabledKeys(MainMn);
      end;
    end;
    MsgMsOff(msoEnter,FKeyPanel);
    inherited DoEnter;
  end;
  DelStack;
end;

procedure TCustomStringBrowl.DoExit;
begin
	AddStack('TCustomStringBrowl.DoExit',Self);
  if not IsCalculator then begin
    inherited DoExit;
    DelKeys; MsgMsOff(msoExit,FKeyPanel);
  end;
  DelStack;
end;

procedure TCustomStringBrowl.DelKeys;
var MainMn: TKeyMenu;
begin
	AddStack('TCustomStringBrowl.DelKeys',Self);
  if SeekKeyMenu(Self,MainMn) then MainMn.DelLine(kmList,K_F6);
	if FormKeyLb(Self,FKeyPanel) then with FKeyPanel do begin
 		DelKey(K_ALL,'strbrowl'); Redrw;
	end;
  Filtered:=false;
  DelStack;
end;

procedure TCustomStringBrowl.ProcKey;
var i: longint;
  s: string;
begin
	AddStack('TCustomStringBrowl.ProcKey',Self);
	case Key of
    K_Esc: Filtered:=false;
		K_LEFT: if LeftCol<>0 then IncLeftCol(-1);
		K_RIGHT: if LeftCol<ColCount-VisibleColCount then IncLeftCol(1);
    K_Ctrl_C: begin
      s:='';
      for i:=0 to ColCount-1 do
        if (goRowSelect in Options) or (i=Col) then IncD(s,TAB+Cells[i,Row]);
      Clipboard.AsText:=Copy(s,2,MaxInt);
    end;
  else WinFindKey(Key,Self,brfind,GetFindOptions);
	end;
  DelStack;
end;

procedure TCustomStringBrowl.EnabledKeys;
begin
	AddStack('TCustomStringBrowl.EnabledKeys',Self);
	if Assigned(MainMn) then begin
    MainMn.EnabledItem(kmList,K_Left,LeftCol<>0);
    MainMn.EnabledItem(kmList,K_Right,LeftCol<ColCount-VisibleColCount);
  end;
  DelStack;
end;

function TCustomStringBrowl.GetTopLeft;
begin
  AddStack('TCustomStringBrowl.GetTopLeft',Self);
  result.X:=LeftCol; result.Y:=TopRow;
  DelStack;
end;

procedure TCustomStringBrowl.SetTopLeft;
begin
  AddStack('TCustomStringBrowl.SetTopLeft',Self);
  LeftCol:=EnsureRange(Value.X,FixedCols,ColCount-1);
  TopRow :=EnsureRange(Value.Y,FixedRows,RowCount-1);
  MoveColRowCur;
  DelStack;
end;

procedure TCustomStringBrowl.MoveColRowCur;
begin
  AddStack('TCustomStringBrowl.MoveColRowCur',Self);
  if InRange(Col,FixedCols,ColCount-1) then if InRange(Row,FixedRows,RowCount-1)
  then MoveColRow(Col,Row,true,true);
  DelStack;
end;

// Поиск
function TCustomStringBrowl.brfind;
var n,cnt: longint;
	res,lAll: boolean;
  step: TValueSign;
	function NextStat(n1,n2: longint): boolean;
  var j: longint;
  	s: string;
  begin
  	AddStack('TCustomStringBrowl.brfind.NextStat',Self);
    result:=true;
    while n1<>n2 do begin
    	if WinFindSayStat(n/cnt) then begin
      	result:=false; break;
      end;
      Inc(n); s:='';
      for j:=0 to ColCount-1 do IncD(s,Cells[j,n1]);
      if FindInStr(s,sf) then begin
      	res:=true;
        if lAll then PrFindAll(n1)
        else begin
          Row:=n1; result:=false; break;
        end;
      end;
      Inc(n1,step);
    end;
    DelStack;
  end;
begin
	AddStack('TCustomStringBrowl.brfind',Self);
	res:=false; cnt:=RowCount-FixedRows; n:=1;
  lAll := not(fnoDirection in GetFindOptions) and BrFindAll or (FindProperty.Direction=fndAll);
  if lAll then begin
    Filtered:=false; PrFindAll(0); step:=1; NextStat(FixedRows,RowCount); Filtered:=res;
  end
  else case FindProperty.Direction of
    fndForward: begin
      step:=1;
      if NextStat(Row+1,RowCount) then NextStat(FixedRows,Row);
    end;
    fndBack: begin
      step:=-1;
      if NextStat(Row-1,FixedRows-1) then NextStat(RowCount-1,Row);
    end;
  end;
  result:=res;
  DelStack;
end;

function TCustomStringBrowl.GetFindOptions;
begin
  result:=[fnoRegistr,fnoWord,fnoDirection];
end;

procedure TCustomStringBrowl.PrFindAll;
begin
end;

procedure TCustomStringBrowl.SetFiltered;
begin
  AddStack('TCustomStringBrowl.SetFiltered',Self);
  if Value<>FFiltered then begin
  	if FormKeyLb(Self,FKeyPanel) then with FKeyPanel do begin
      if Value
      then SetKey(K_Esc,'','Сбросить результаты поиска',ProcKey,'brfind',kmList)
      else DelKey(K_Esc,'brfind');
      ReDrw;
    end;
    FFiltered:=Value; FilteredChanged;
  end;
  DelStack;
end;

procedure TCustomStringBrowl.FilteredChanged;
begin
end;

function TCustomStringBrowl.OffsLeftAlign;
begin
  AddStack('TCustomStringBrowl.OffsLeftAlign',Self);
  result:=2;
  case AlignCell(ACol,ARow) of
    taRightJustify: result:=r.Right-r.Left-result-Canvas.TextWidth(Cells[ACol,ARow]);
    taCenter: MaxSelf(result,(r.Right-r.Left-Canvas.TextWidth(Cells[ACol,ARow])) div 2);
  end;
  DelStack;
end;

// Передать текст в калькулятор
procedure TCustomStringBrowl.DragOver;
var r,c: longint;
	tr: TRect;
label lend;
begin
	AddStack('TCustomStringBrowl.DragOver',Self);
	inherited DragOver(Source,X,Y,State,Accept);
  if Source=Self then begin
    if (State=dsDragEnter) and not lDrag then begin
      lDrag:=true; MouseToCell(X,Y,c,r);
      if not(InRange(c,0,ColCount-1) and InRange(r,0,RowCount-1)) then goto lend;
      tr:=CellRect(c,r); Inc(tr.Left,OffsLeftAlign(c,r,tr));
      if Assigned(FOnNumCalc)
      then sCalc:=FOnNumCalc(Self,c,r,X-tr.Left,Y-tr.Top)
      else sCalc:=NumInStr(Cells[c,r],tr.Left,X,Canvas);
    end;
    Accept := sCalc<>'';
  end;
lend:
	DelStack;
end;

procedure TCustomStringBrowl.DoEndDrag;
begin
	AddStack('TCustomStringBrowl.DoEndDrag',Self);
	inherited DoEndDrag(Target,X,Y);
  sCalc:=''; lDrag:=false;
  DelStack;
end;

procedure TCustomStringBrowl.WMCalc;
begin
	AddStack('TCustomStringBrowl.WMCalc',Self);
	inherited;
  if (msg.Operation=clcGet) and (sCalc<>'') then begin
		msg.ps^:=Float0(sCalc); msg.result:=1;
  end;
  DelStack;
end;

procedure TCustomStringBrowl.WMGetDlgCode;
begin
	AddStack('TCustomStringBrowl.WMGetDlgCode',Self);
	inherited;
  GetDlgCodeTab(Self,Msg);
  DelStack;
end;

procedure TCustomStringBrowl.WMWHMin;
begin
	AddStack('TCustomStringBrowl.WMWHMin',Self);
	if Parent is TCustomRbPanel then with TCustomRbPanel(Parent) do begin
	  WMin:=GridsWidth(FixedCols)+15; HMin:=GridsHeight(FixedRows)+15;
  end;
  DelStack;
end;

procedure TCustomStringBrowl.WMRebuild;
begin
	AddStack('TCustomStringBrowl.WMRebuild',Self);
	EnabledKeys(SeekKeyMenu(Self)); MoveColRowCur;
  DelStack;
end;

// Установка цветов и шрифтов
procedure TCustomStringBrowl.WMSchem;
begin
	AddStack('TCustomStringBrowl.WMSchem',Self);
	with msg.Schem do begin
		Color:=Color1; FixedColor:=Color2; FTitleFont.Assign(Font2); Font.Assign(Font1);
    Canvas.Font.Assign(Font); DefaultRowHeight:=CanvasMaxH(Canvas)+4;
 	end;
  DelStack;
end;

procedure TCustomStringBrowl.WMApplHint;
begin
	AddStack('TCustomStringBrowl.WMApplHint',Self);
	with Msg.Info^ do
    if not IfThenShowHint(FOnShowHint,HintStr,CanShow,HintInfo) then HintInfo.ReshowTimeout:=100;
  DelStack;
end;

function TCustomStringBrowl.BoxRect;
begin
  AddStack('TCustomStringBrowl.BoxRect',Self);
  result:=inherited BoxRect(ALeft,ATop,ARight,ABottom);
  DelStack;
end;

function TCustomStringBrowl.CellRect: TRect;
begin
  AddStack('TCustomStringBrowl.CellRect',Self);
  result:=CellRect(Col,Row);
  DelStack;
end;

function TCustomStringBrowl.GridsWidth;
var i: longint;
begin
	AddStack('TCustomStringBrowl.GridsWidth',Self);
	result:=0;
	for i:=0 to min(ColEnd,ColCount-1) do Inc(result,IfThen(ColWidths[i]>0,ColWidths[i]+wDlm));
  if result>0 then Inc(result,wDlm);
  DelStack;
end;

function TCustomStringBrowl.GridsHeight;
const wDlm = 1;
var i: longint;
begin
	AddStack('TCustomStringBrowl.GridsHeight',Self);
	result:=0;
	for i:=0 to min(RowEnd,RowCount-1) do Inc(result,IfThen(RowHeights[i]>0,RowHeights[i]+wDlm));
  if result>0 then Inc(result,wDlm+2);
  DelStack;
end;

procedure TCustomStringBrowl.IncFixedRows;
begin
  FixedRows:=FixedRows+d2;
end;

procedure TCustomStringBrowl.IncFixedCols;
begin
  FixedCols:=FixedCols+d2;
end;

procedure TCustomStringBrowl.IncRowCount;
begin
  RowCount:=RowCount+d2;
end;

{procedure TCustomStringBrowl.IncColCount;
begin
  ColCount:=ColCount+d2;
end;}

procedure TCustomStringBrowl.IncRow;
begin
  Row:=Row+d2;
end;

procedure TCustomStringBrowl.IncOptions;
begin
  Options:=Options+Incl-Excl;
end;

procedure TCustomStringBrowl.IncLeftCol;
begin
  LeftCol:=LeftCol+d2;
end;

procedure TCustomStringBrowl.MaxColWidths;
begin
  ColWidths[Index]:=max(ColWidths[Index],d2);
end;

procedure TCustomStringBrowl.MaxRowHeights;
begin
  RowHeights[Index]:=max(RowHeights[Index],d2);
end;

procedure TCustomStringBrowl.Paint;
var i: longint;
begin
	AddStack('TCustomStringBrowl.Paint',Self);
  IfThenNotify(FOnBeforePaint,Self);
	inherited Paint;
  if DefaultDrawing then begin
    Canvas.Pen.Color:=Canvas.Brush.Color;
    for i:=0 to min(ColCount-1,LeftCol+VisibleColCount) do
    	if (i<FixedCols) or (i>=LeftCol) then DrawFixedCol(i);
  end;
  IfThenNotify(FOnAfterPaint,Self);
  DelStack;
end;

procedure TCustomStringBrowl.DrawFixedCol;
var j: longint;
	r: TRect;
begin
  AddStack('TCustomStringBrowl.DrawFixedCol',Self);
  r:=BoxRect(ACol,0,ACol,FixedRows-1);
  // обработка ошибки - последний невидимый столбец возвращает всю ширину таблицы
  if not((r.Left=0) and (FixedCols>0) and (ACol>=FixedCols)) and (ColWidths[ACol]>0) then begin
  //if not((r.Left=0) and (r.Top=0)) or (FixedRows<=1) or (ACol<FixedCols) then begin
    BeforeDrawFixedCol(ACol); Canvas.FillRect(r); Frame3D1(Canvas,r,false);
    for j:=0 to FixedRows-1 do begin
      Canvas.Font.Assign(FTitleFont); DrawCell(ACol,j,InfCellRect(ACol,j),[gdFixed]);
    end;
  end;
  DelStack;
end;

procedure TCustomStringBrowl.BeforeDrawFixedCol;
begin
	AddStack('TCustomStringBrowl.BeforeDrawFixedCol',Self);
	Canvas.Brush.Color:=FixedColor;
  DelStack;
end;

function TCustomStringBrowl.InfCellRect;
begin
  AddStack('TCustomStringBrowl.InfCellRect',Self);
  result:=CellRect(ACol,ARow); InflateRect(result,-1,-1);
  DelStack;
end;

procedure TCustomStringBrowl.TopLeftChanged;
begin
	AddStack('TCustomStringBrowl.TopLeftChanged',Self);
	inherited TopLeftChanged;
  EnabledKeys(SeekKeyMenu(Self)); Repaint;
  DelStack;
end;

procedure TCustomStringBrowl.BeforeDrawCell;
begin
  AddStack('TCustomStringBrowl.BeforeDrawCell',Self);
  IfThenDrawCell(FOnBeforeDrawCell,Self,ACol,ARow,ARect,State);
  DelStack;
end;

procedure TCustomStringBrowl.MouseDown;
begin
  AddStack('TCustomStringBrowl.MouseDown',Self);
  NoSel:=true;
  inherited MouseDown(Button,Shift,X,Y);
  MouseToCell(X,Y,NoSelCol,NoSelRow);
  DelStack;
end;

procedure TCustomStringBrowl.MouseMove;
var crd: TGridCoord;
  hnt: string;
begin
  AddStack('TCustomStringBrowl.MouseMove',Self);
  hnt:=''; crd:=MouseCoord(X,Y);
  with crd do if InRange(X,0,ColCount-1) and InRange(Y,0,RowCount-1) then begin
    Canvas.Font.Assign(IfThen(InRange(X,0,FixedCols-1) or InRange(Y,0,FixedRows-1),TitleFont,Font));
    with Canvas.TextExtent(Cells[X,Y]) do
      if (ColWidths[X]<cx) or (RowHeights[Y]<cY) then hnt:=Cells[X,Y];
  end;
  Hint:=hnt; ShowHint := not empty(hnt);
  inherited MouseMove(Shift,X,Y);
  DelStack;
end;

procedure TCustomStringBrowl.MouseUp;
begin
  AddStack('TCustomStringBrowl.MouseUp',Self);
  inherited MouseUp(Button,Shift,X,Y);
  if NoSel then begin
    NoSel:=false;
//RnmStack(Format('TCustomStringBrowl.MouseUp:NoSelCol=%d,FixedCols=%d,ColCount=%d',[NoSelCol,FixedCols,ColCount]),Self);
    if not(goRowSelect in Options) and InRange(NoSelCol,FixedCols,ColCount-1) then Col:=NoSelCol;
//RnmStack(Format('TCustomStringBrowl.MouseUp:NoSelRow=%d,FixedRows=%d,RowCount=%d',[NoSelRow,FixedRows,RowCount]),Self);
    if InRange(NoSelRow,FixedRows,RowCount-1) then Row:=NoSelRow;
  end;
  DelStack;
end;

function TCustomStringBrowl.SelectCell;
begin
  AddStack('TCustomStringBrowl.SelectCell',Self);
  result:=not NoSel;
  if result then result := inherited SelectCell(ACol,ARow);
  DelStack;
end;

function TCustomStringBrowl.IntObj(ACol,ARow: longint): longint;
begin
  AddStack('TCustomStringBrowl.IntObj',Self);
  result:=longint(Objects[ACol,ARow]);
  DelStack;
end;

function TCustomStringBrowl.IntObj(ARow: longint): longint;
begin
  result:=IntObj(0,ARow);
end;

function TCustomStringBrowl.LongWordObj;
begin
  AddStack('TCustomStringBrowl.LongWordObj',Self);
  result:=longword(Objects[ACol,ARow]);
  DelStack;
end;

function TCustomStringBrowl.BoolObj(ACol,ARow: longint): boolean;
begin
  AddStack('TCustomStringBrowl.BoolObj',Self);
  result:=boolean(Objects[ACol,ARow]);
  DelStack;
end;

function TCustomStringBrowl.BoolObj(ARow: longint): boolean;
begin
  result:=BoolObj(0,ARow);
end;

procedure TCustomStringBrowl.bmCheckPaint(ACol,ARow: longint);
begin
  AddStack('TCustomStringBrowl.bmCheckPaint',Self);
  My_pr.bmCheckPaint(Canvas,CellRect(ACol,ARow),not empty(Cells[ACol,ARow]));
  DelStack;
end;

procedure TCustomStringBrowl.bmCheckPaint(ACol,ARow: longint; cSet: char);
begin
  AddStack('TCustomStringBrowl.bmCheckPaint',Self);
  My_pr.bmCheckPaint(Canvas,CellRect(ACol,ARow),Cells[ACol,ARow]=cSet);
  DelStack;
end;

{ TStringBrowl }
constructor TStringBrowl.Create;
begin
	AddStack('TStringBrowl.Create',Self);
	Inherited Create(AOwner);
  IncOptions([goRowSelect]);
	FColZn:=TStringList.Create; FColZn.onChange:=ColZnChange;
  FKeys:=TIntegerList.Create; SetLength(aColZn,10);
  DelStack;
end;

destructor TStringBrowl.Destroy;
begin
	AddStack('TStringBrowl.Destroy',Self);
  FColZn.Free; FKeys.Free;
  inherited Destroy;
  DelStack;
end;

procedure TStringBrowl.Loaded;
begin
	AddStack('TStringBrowl.Loaded',Self);
	inherited Loaded;
  WidthCols;
  DelStack;
end;

procedure TStringBrowl.WMRebuild;
var h: longint;
begin
	AddStack('TStringBrowl.WMRebuild',Self);
	h:=msg.RbPnl.CltHeight-msg.RbPnl.HeaderHeight-12;
  SetBounds(Left,Top,
  	min(GridsWidth+IfThen(GridsHeight>h,SysMetric.iScrollWidth),msg.RbPnl.CltWidth-10),h);
  inherited;
  DelStack;
end;

procedure TStringBrowl.SetColZn;
begin
	AddStack('TStringBrowl.SetColZn',Self);
	if not FColZn.Equals(Value) then begin
	  FColZn.Assign(Value); WidthCols;
  end;
  DelStack;
end;

procedure TStringBrowl.ColZnChange;
var i: longint;
begin
	AddStack('TStringBrowl.ColZnChange',Self);
  with FColZn do begin
    onChange:=nil;
    for i:=0 to Count-1 do Objects[i]:=Object0;
    onChange:=ColZnChange;
  end;
  lColZn:=0; WidthCols;
  DelStack;
end;

{procedure TStringBrowl.CallRebuild(Sender: TRbPanel);
var msg: TWMRebuild;
begin
	msg.RbPnl:=Sender; WMRebuild(msg);
end;}

{ Инициализация }
procedure TStringBrowl.Init;
var i,j: longint;
begin
	AddStack('TStringBrowl.Init',Self);
  for i:=0 to ColCount-1 do
	  for j:=FixedRows to RowCount-1 do Cells[i,j]:='';
  FKeys.Clear;
  if FixedRows>0 then RowCount:=FixedRows+1;
  for i:=0 to FixedRows-1 do FKeys.Add(0);
  ColZnChange;
  DelStack;
end;

{ Расчёт ширины столбцов }
procedure TStringBrowl.WidthCols;
var i,j,w,fc: longint;
  iz: TStrBrInfZn;
  a: TArrInt;
  pn: TCustomRbPanel;
begin
	AddStack('TStringBrowl.WidthCols',Self);
	Canvas.Font.Assign(Font); ColCount:=FColZn.Count; Cells[0,0]:='';
  fc:=1;
  for i:=0 to FColZn.Count-1 do MaxSelf(fc,Length(InfoCol[i].aName));
  Dec(fc,FixedRows);
  if fc<0 then begin
    j:=FixedRows+fc;
    for i:=FixedRows to RowCount-1 do begin
      Rows[j].Assign(Rows[i]);
      if InRange(i,0,FKeys.Count-1) and InRange(j,0,FKeys.Count-1)
      then FKeys[j]:=FKeys[i];
      Inc(j);
    end;
    while FKeys.Count>RowCount-FixedRows do FKeys.Delete(FKeys.Count-1);
    IncFixedRows(fc); IncRowCount(fc);
  end;
  if fc>0 then begin
    IncRowCount(fc); IncFixedRows(fc);
    while FKeys.Count<RowCount-FixedRows do FKeys.Add(0);
    j:=RowCount-1-fc;
    for i:=RowCount-1 downto FixedRows do begin
      Rows[i].Assign(Rows[j]);
      if InRange(i,0,FKeys.Count-1) and InRange(j,0,FKeys.Count-1) then FKeys[i]:=FKeys[j];
      Dec(j);
    end;
  end;
  SetLength(a,FColZn.Count); fc:=0;
  for i:=0 to FColZn.Count-1 do begin
    iz:=InfoCol[i];
    for j:=0 to FixedRows-1 do
      if j>high(iz.aName) then Cells[i,j]:='' else Cells[i,j]:=iz.aName[j];
    j:=0;
    Canvas.Font.Assign(Font); MaxSelf(j,Canvas,StringOfChar(cMaxW,iz.LenData));
    Canvas.Font.Assign(FTitleFont); MaxSelf(j,MaxSelf(Canvas,iz.aName));
    ColWidths[i] := IfThen(j>0,j + wDlm shl 1,-1);
    if iz.lMax then begin
      a[fc]:=i; Inc(fc);
    end;
  end;
  if (fc>0) and IsClass(Parent,TCustomRbPanel,pointer(pn)) then begin
    j:=0; SetLength(a,fc);
    if pn is TRbPanel then j:=TRbPanel(pn).HeaderHeight;
    w := inherited GridsWidth;
    for i:=low(a) to high(a) do Dec(w,IfThen(ColWidths[a[i]]>0,ColWidths[a[i]]+wDlm));
    j:=pn.CltWidth-11-w
      -IfThen(GridsHeight>pn.CltHeight-j-12,SysMetric.iScrollWidth);
    if j>0 then begin
      fc:=nround(j/fc);
      for i:=low(a) to high(a) do begin
        ColWidths[a[i]]:=IfThen(i=high(a),j,fc); Dec(j,fc);
      end;
    end;
  end;
  Canvas.Font.Assign(FTitleFont); j:=CanvasMaxH(Canvas)+4;
  for i:=0 to FixedRows-1 do RowHeights[i]:=j;
  if Assigned(FOnWidthCols) then for i:=0 to FColZn.Count-1 do FOnWidthCols(Self,i);
  DelStack;
end;

procedure TStringBrowl.DrawCell;
var fl: boolean;
begin
	AddStack('TStringBrowl.DrawCell',Self);
  BeforeDrawCell(ACol,ARow,ARect,State);
  fl:=DefaultDrawing; DefaultDrawing:=false;
  if fl then begin
    if FSelectedOnlyFocused and (not Focused) and (gdSelected in State) then begin
      Canvas.Brush.Color:=Color; Canvas.Font.Assign(Font);
    end;
    if gdFixed in State then Canvas.Font.Assign(FTitleFont);
    Canvas.FillRect(ARect);
    Canvas.TextRect(ARect,ARect.Left+OffsLeftAlign(ACol,ARow,ARect),ARect.Top+2,Cells[ACol,ARow]);
  end;
  inherited DrawCell(ACol,ARow,ARect,State);
  DefaultDrawing:=fl;
  DelStack;
end;

function TStringBrowl.AlignCell;
begin
  AddStack('TStringBrowl.AlignCell',Self);
  if (ARow<FixedRows) or (ACol<FixedCols)
  then result:=iif(ACol<LeftCol+VisibleColCount,taCenter,taLeftJustify)
  else result:=InfoCol[ACol].Alignment;
  DelStack;
end;

function TStringBrowl.SelectCell;
begin
	AddStack('TStringBrowl.SelectCell',Self);
  if (goRowSelect in Options) and (ARow<>Row) and (LeftCol>0) then begin
  	if not Assigned(tm) then begin
		  tm:=TTimer.Create(Application.MainForm); tm.Enabled:=false; tm.Interval:=1;
    end;
  	SetRedraw(Self); tm.OnTimer:=tmTimer; tm.Tag:=LeftCol; tm.Enabled:=true;
  end;
  result := inherited SelectCell(ACol,ARow);
  DelStack;
end;

procedure TStringBrowl.tmTimer;
begin
  AddStack('TStringBrowl.tmTimer',Self);
  with TTimer(Sender) do begin
    Enabled:=false; LeftCol:=Tag;
  end;
  SetRedraw(Self,rdrwSet);
  DelStack;
end;

function TStringBrowl.ZnOneCol;
begin
	AddStack('TStringBrowl.ZnOneCol',Self);
	result:=CalcZn(ACol);
  if result='' then result:=FixZn(nmFld);
  DelStack;
end;

{ Расчёт значения фиксированного столбца }
function TStringBrowl.FixZn;
var p: byte;
	tr: TCustomRec;
begin
	AddStack('TStringBrowl.FixZn',Self);
	result:=''; p:=Pos('.',nmFld);
  if p<>0 then
    if RecName(TrimRight(LeftStr(nmFld,p-1)),tr) then begin
      if not tr.Active then tr.OpenRec;
      result:=tr[Trim(Copy(NmFld,p+1,MaxInt))];
      if csDesigning in ComponentState then tr.CloseRec;
    end;
  DelStack;
end;

{ Расчёт значения вычисляемого столбца }
function TStringBrowl.CalcZn;
begin
	AddStack('TStringBrowl.CalcZn',Self);
	if Assigned(FOnCalcZn) then result:=FOnCalcZn(Self,ACol) else result:='';
  DelStack;
end;

// Действия после редактирования
{function TStringBrowl.BeforeEdit(lFirst: boolean): boolean;
begin
	if Assigned(FOnBeforeEdit) then result:=FOnBeforeEdit(lFirst) else result:=false;
end;}

{ Установить/вернуть уникальный ключ записи ARow }
procedure TStringBrowl.SetUnKey;
begin
	AddStack('TStringBrowl.SetUnKey',Self);
	if Assigned(FOnUnKey) then FOnUnKey(UnKey,lWrite);
  DelStack;
end;

{ Уникальный ключ для текущей строки }
function TStringBrowl.CurUnKey;
begin
	AddStack('TStringBrowl.CurUnKey',Self);
	if InRange(Row,0,FKeys.Count-1) then result:=FKeys[Row] else result:=0;
  DelStack;
end;

{ Добавить строку }
procedure TStringBrowl.AddSt;
var p: longint;
begin
	AddStack('TStringBrowl.AddSt',Self);
  CurStUpdate;
  IncRowCount;
  Row:=RowCount-1;
  p:=0; SetUnKey(p,true); FKeys.Add(p);
  DelStack;
end;

procedure TStringBrowl.AddSt(cnt: longint);
var i: longint;
begin
	AddStack('TStringBrowl.AddSt(cnt)',Self);
  Init;
  for i:=1 to cnt do AddSt;
  DelLast;
  DelStack;
end;

procedure TStringBrowl.DelSt;
var i: longint;
begin
  AddStack('TStringBrowl.DelSt',Self);
  for i:=Row+1 to RowCount-1 do Rows[i-1].Text:=Rows[i].Text;
  FKeys.Delete(Row); IncRowCount(-1);
  DelStack;
end;

{ Обновить тек. строку }
procedure TStringBrowl.CurStUpdate;
var i: longint;
begin
	AddStack('TStringBrowl.CurStUpdate',Self);
  ReplNegSelf(ARow,Row);
  for i:=0 to FColZn.Count-1 do Cells[i,ARow]:=ZnOneCol(InfoCol[i].nmFld,i);
  DelStack;
end;

{ Возвращает запись с информацией о столбце }
function TStringBrowl.GetInfoCol;
var a: array[1..4] of string;
  n,oRow: longint;
  oSelectCell: TSelectCellEvent;
begin
	AddStack('TStringBrowl.GetInfoCol',Self);
  Finalize(result); ZeroMemory(@result,SizeOf(result));
  if InRange(Index,0,FColZn.Count-1) then begin
    n:=My_pr.IntObj(FColZn,Index);
    if n=0 then begin
      if Length(aColZn)=lColZn then SetLength(aColZn,lColZn shl 1);
      with aColZn[lColZn] do begin
        LsArrFill(FColZn[Index],a,UnDelim); LsArrDynamic(a[1],aName,cDlmName,lsaSetLen); nmFld:=a[2];
        LenData:=Int0(a[4]); lMax := LenData=NegDef;
        if lMax then LenData:=0
        else if LenData=0 then begin
          SetRedraw(Self); oSelectCell:=OnSelectCell; oRow:=Row; 
          try
            OnSelectCell:=nil;
            for n:=FixedRows to RowCount-1 do begin
              Row:=n; MaxSelf(LenData,ZnOneCol(nmFld,Index));
            end;
          finally
            Row:=oRow; OnSelectCell:=oSelectCell; SetRedraw(Self,rdrwSet);
          end;
        end;
        TrimRightSelf(aName);
        case UpCase(StrToChar(a[3])) of
          'L': Alignment:=taLeftJustify;
          'R': Alignment:=taRightJustify;
        else Alignment:=taCenter;
        end;
      end;
      Inc(lColZn); n:=lColZn;
      FColZn.onChange:=nil; FColZn.Objects[Index]:=pointer(n); FColZn.onChange:=ColZnChange;
    end;
    result:=aColZn[n-1];
  end
  else with result do begin
    Alignment:=taCenter; CopyFrom(aName);
  end;
  DelStack;
end;

procedure TStringBrowl.SetInfoCol;
var s: string;
begin
	AddStack('TStringBrowl.SetInfoCol',Self);
  if Index>=0 then begin
    FColZn.BeginUpdate;
    while FColZn.Count<=Index do FColZn.Add('');
    with Value do begin
      case Alignment of
        taLeftJustify: s:='L';
        taRightJustify: s:='R';
      else s:='';
      end;
      if lMax then LenData:=NegDef;
      if LenData<>0 then s:=StrNum(s+UnDelim,LenData);
      FColZn[Index]:=ArrayAsList(aName,cDlmName)+UnDelim+nmFld+UnDelim+s;
    end;
    FColZn.EndUpdate;
  end;
  DelStack;
end;

function TStringBrowl.GridsWidth;
begin
	AddStack('TStringBrowl.GridsWidth',Self);
	WidthCols; result := inherited GridsWidth(ColEnd);
  DelStack;
end;

// Удалить последнюю строку
function TStringBrowl.DelLast;
begin
	AddStack('TStringBrowl.DelLast',Self);
  result:=false;
	if RowCount<>FixedRows+1 then if FKeys.Count>FixedRows then begin
    result:=true; IncRowCount(-1);
  end;
  DelStack;
end;

procedure TStringBrowl.AdjustColsWidth;
var k,j: longint;
    sbiz: TStrBrInfZn;
begin
  AddStack('TStringBrowl.AdjustColsWidth',Self);
  for k:=0 to ColCount-1 do begin
    sbiz:=InfoCol[k];
    if sbiz.lMax then continue;
    sbiz.LenData:=0;
    for j:=FixedRows to RowCount-1 do MaxSelf(sbiz.LenData,Cells[k,j]);
    InfoCol[k]:=sbiz;
  end;
  DelStack;
end;

function TStringBrowl.GetRowRect;
begin
  AddStack('TStringBrowl.GetRowRect',Self);
  result:=BoxRect(aLeft,aTop,aRight,ReplNeg(aBottom,aTop));
  DelStack;
end;

procedure TStringBrowl.IncColWidths;
begin
  AddStack('TStringBrowl.IncColWidths',Self);
  ColWidths[ACol]:=ColWidths[ACol]+d2;
  DelStack;
end;

{ TStrTable }
constructor TStrTable.Create;
var i: longint;
begin
	AddStack('TStrTable.Create',Self);
	Inherited Create(AOwner);
  IncOptions([goDrawFocusSelected]);
  FCanInvert:=true; FixedCols:=1; FAlignCells:=taCenter;
  for i:=low(FHead) to high(FHead) do FHead[i]:=TStringList.Create;
  DelStack;
end;

destructor TStrTable.Destroy;
var i: longint;
begin
	AddStack('TStrTable.Destroy',Self);
  if InvertedIniReaded and CanInvert and (FInvertedIniSect<>'') and not(csDesigning in ComponentState)
  then InitFIni[fiSave].WriteBool('TableInv',FInvertedIniSect,FInverted);
  DelKeys; SetTab(false);
  for i:=low(FHead) to high(FHead) do FHead[i].Free;
  inherited Destroy;
	LabelCol.Free;
  DelStack;
end;

function TStrTable.GetCapt;
begin
	AddStack('TStrTable.GetCapt',Self);
	result:=FCapt[Index];
  DelStack;
end;

procedure TStrTable.SetCapt;
begin
	AddStack('TStrTable.SetCapt',Self);
	FCapt[Index]:=Value;
  DelStack;
end;

function TStrTable.GetHead;
begin
	AddStack('TStrTable.GetHead',Self);
	result:=FHead[Index];
  DelStack;
end;

procedure TStrTable.SetHead;
begin
	AddStack('TStrTable.SetHead',Self);
	FHead[Index].Assign(Value);
  DelStack;
end;

function TStrTable.GetDatCells;
begin
	AddStack('TStrTable.GetDatCells',Self);
	XYToColRow(X,Y); result:=Cells[X,Y];
  DelStack;
end;

procedure TStrTable.SetDatCells;
begin
	AddStack('TStrTable.SetDatCells',Self);
	XYToColRow(X,Y); Cells[X,Y]:=Value;
  DelStack;
end;

function TStrTable.GetDatObjects;
begin
	AddStack('TStrTable.GetDatObjects',Self);
	XYToColRow(X,Y); result:=Objects[X,Y];
  DelStack;
end;

procedure TStrTable.SetDatObjects;
begin
	AddStack('TStrTable.SetDatObjects',Self);
	XYToColRow(X,Y); Objects[X,Y]:=Value;
  DelStack;
end;

procedure TStrTable.SetCanInvert;
begin
	AddStack('TStrTable.SetCanInvert',Self);
	if FCanInvert<>Value then begin
		FCanInvert:=Value;
    if isFocus then SetTab(FCanInvert);
  end;
  DelStack;
end;

procedure TStrTable.WMSchem;
begin
	AddStack('TStrTable.WMSchem',Self);
  inherited;
  if Assigned(LabelCol) then LabelCol.Font.Assign(msg.Schem.FontW);
  HeadWHCalc;
  DelStack;
end;

procedure TStrTable.WMRebuild;
const	iX=5; iY=5;
var t,w,w1,h: longint;
  pn: TCustomRbPanel;
begin
	AddStack('TStrTable.WMRebuild',Self);
	msg.RbPnl.SortObj:=false;
	if Assigned(LabelCol) then LabelCol.Caption:=FCapt[nCol]
  else begin
  	pn:=pointer(Parent); LabelCol:=TPaintSay.CreatePrm(FCapt[nCol],pn); LabelCol.Font.Assign(pn.Font);
  end;
  LabelCol.Visible := not empty(LabelCol.Caption);
  t:=IfThen(LabelCol.Visible,LabelCol.Height);
  h:=t;
  h:=msg.RbPnl.CltHeight-msg.RbPnl.HeaderHeight-iY shl 1-h-2;
  HeadWHCalc;
  w1:=GridsWidth+IfThen(GridsHeight>h,SysMetric.iScrollWidth); w:=min(w1,msg.RbPnl.CltWidth-iX shl 1);
  SetBounds((msg.RbPnl.Width-w) div 2,iY+t,w,h);
  if not NoColWidthsCorr then if ColCount>1 then  // ширина первой фиксированной колонки больше ширины таблицы
    if ColWidths[0]+ColWidths[1]>w then ColWidths[0]:=max(w div 2,w-w1+ColWidths[0]);
  with LabelCol do
	  if Visible then SetBounds(Self.Left+ColWidths[0]+iX,iY,Width,Height);
  inherited;
  DelStack;
end;

procedure TStrTable.DoEnter;
begin
	AddStack('TStrTable.DoEnter',Self);
  if not IsCalculator then begin
    if not isFocus then begin
      if FCanInvert then SetTab(true);
      isFocus:=true;
    end;
    inherited DoEnter;
  end;
  DelStack;
end;

procedure TStrTable.DoExit;
begin
	AddStack('TStrTable.DoExit',Self);
  if not IsCalculator then begin
    inherited DoExit;
    if isFocus then begin
      SetTab(false); isFocus:=false;
    end;
  end;
  DelStack;
end;

procedure TStrTable.SetTab;
begin
	AddStack('TStrTable.SetTab',Self);
	if FormKeyLb(Self,FKeyPanel) then with FKeyPanel do begin
  	if Value
    then SetKey(K_Tab,'Перевернуть','Перевернуть таблицу',ProcInverted,'strtable',kmList)
    else DelKey(K_ALL,'strtable');
  	ReDrw;
  end;
  DelStack;
end;

procedure TStrTable.ProcInverted;
begin
	AddStack('TStrTable.ProcInverted',Self);
  Inverted:=not Inverted;
  DelStack;
end;

function TStrTable.GetInverted;
begin
  AddStack('TStrTable.GetInverted',Self);
  if not InvertedIniReaded then begin
    if CanInvert and (FInvertedIniSect<>'') and not(csDesigning in ComponentState)
    then FInverted:=InitFIni[fiSave].ReadBool('TableInv',FInvertedIniSect,FInvertedIniDefault)
    else FInverted:=FInvertedIniDefault;
    InvertedIniReaded:=true;
  end;
  result:=FInverted;
  DelStack;
end;

procedure TStrTable.SetInverted;
var x,y: Word;
begin
  AddStack('TStrTable.SetInverted',Self);
  if FInverted<>Value then begin
	  Filtered:=false; ColRowToXY(x,y); FInverted:=Value; Fill(x,y); IfThenNotify(FOnSetInverted,Self);
  end;
  DelStack;
end;

procedure TStrTable.SetInvertedIniSect;
begin
  AddStack('TStrTable.SetInvertedIniSect',Self);
  if FInvertedIniSect<>Value then begin
    FInvertedIniSect:=Value; InvertedIniReaded:=false;
  end;
  DelStack;
end;

procedure TStrTable.Fill;
var ls: TStringList;
  curCol,LenX: longint;
	procedure StrWord(const st: string);
    function EmpLs: boolean;
    begin
    	AddStack('TStrTable.Fill.StrWord.EmpLs',Self);
      result := ls.Count>0;
      if result then result:=empty(ls[ls.Count-1]);
      DelStack;
    end;
  var a: array[1..20] of string;
	  i,j,l: longint;
    s: string;
  begin
  	AddStack('TStrTable.Fill.StrWord',Self);
  	s:=DelTrim(st); l:=ListAsArray(s,a,' ');
    if l>FixedRows then begin
      l:=FixedRows; j:=Length(s);
      if ModDiv(j,l)<>0 then Inc(j);
    end
    else j:=MaxSelf(a);
    astolin(s,ls,l,max(j,LenX));
    while EmpLs do ls.Delete(ls.Count-1);
    TrimSelf(ls); MaxSelf(LenX,MaxSelf(ls));
    for i:=0 to min(FixedRows,ls.Count)-1 do Cells[curCol,i]:=Trim(ls[i]);
    //ColWidths[curCol]:=CanvasMaxW(Canvas)*LenX+4;
    DelStack;
  end;
var i,j: longint;
	s: string;
  otl: TGridCoord;
begin
	AddStack('TStrTable.Fill',Self);
  ls:=TStringList.Create;
  try
    otl:=TopLeft;
    if not(tbfNoFill in Opt) then begin
      RowCount:=5; FixedRows:=RowCount-1; FixedCols:=1;
      ColCount:=FixedCols+max(1,FHead[nCol].Count);
      RowCount:=FixedRows+max(1,FHead[nRow].Count);
      for i:=0 to ColCount-1 do Cols[i].Clear;
      IfThenNotify(FOnFill,Self);
    end;
    LenX:=0;
    for i:=0 to FHead[nRow].Count-1 do begin
    	s:=TrimRight(FHead[nRow][i]); Cells[0,FixedRows+i]:=s; MaxSelf(LenX,s);
    end;
    curCol:=0; StrWord(FCapt[nRow]);
    for curCol:=FixedCols to ColCount-1 do begin
      LenX:=FMinColLength;
      for i:=FixedRows to RowCount-1 do MaxSelf(LenX,Cells[curCol,i]);
      if InRange(curCol-FixedCols,0,FHead[ncol].Count-1)
      then StrWord(FHead[ncol][curCol-FixedCols]);
    end;
    // Удаление пустых строк в заголовке
    j:=0;
    for i:=FixedRows-1 downto 1 do
      if empty(Trim(TStringList(Rows[i]).Text)) then Inc(j) else break;
    for i:=FixedRows to RowCount-1 do Rows[i-j].Assign(Rows[i]);
    IncFixedRows(-j); IncRowCount(-j);
    XYToColRow(X,Y);
    HeadWHCalc;
    if not(csDesigning in ComponentState) then MainRebuild(Self);
    Col:=EnsureRange(X,FixedCols,ColCount-1);
    Row:=EnsureRange(Y,FixedRows,RowCount-1);
    if tbfTopLeft in Opt then TopLeft:=otl;
    RecreateWnd;
	  //if Assigned(LabelCol) then LabelCol.Caption:=FCapt[nCol];
  finally
    ls.Free;
  end;
  DelStack;
end;

procedure TStrTable.HeadWHCalc;
var i,j,w: longint;
begin
  AddStack('TStrTable.HeadWHCalc',Self);
  with Canvas do begin
    Font.Assign(FTitleFont);
    for i:=0 to RowCount-1 do begin
      w:=CanvasMaxH(Canvas);
      if i>=FixedRows then begin
        Font.Assign(Self.Font); MaxSelf(w,Canvas,true); Font.Assign(FTitleFont);
      end;
      RowHeights[i]:=w+4;
    end;
    for i:=0 to ColCount-1 do begin
      w:=0;
      for j:=0 to FixedRows-1 do MaxSelf(w,Canvas,Cells[i,j]);
      if i>=FixedCols then Font.Assign(Self.Font);
      for j:=FixedRows to RowCount-1 do MaxSelf(w,Canvas,Cells[i,j]);
      Font.Assign(FTitleFont);
      ColWidths[i]:=w+wDlm;
    end;
  end;
  IfThenNotify(FOnHeadWHCalc,Self);
  DelStack;
end;

function TStrTable.nCol;
begin
	AddStack('TStrTable.nCol',Self);
	result:=IfThen(Inverted,2,1);
  DelStack;
end;

function TStrTable.nRow;
begin
	AddStack('TStrTable.nRow',Self);
	result:=IfThen(Inverted,1,2);
  DelStack;
end;

procedure TStrTable.Paint;
begin
	AddStack('TStrTable.Paint',Self);
  SelCol:=Col; SelRow:=Row;
  inherited Paint;
  DelStack;
end;

procedure TStrTable.DrawCell;
var fl,fl1: boolean;
  s: string;
  t: longint;
  bc: TColor;
  X,Y: Word;
begin
	AddStack('TStrTable.DrawCell',Self);
	fl := (Parent is TCustomRbPanel) and (ACol<FixedCols) and (ARow<FixedRows);
  if fl then Canvas.Font.Assign(TCustomRbPanel(Parent).Font)
  else if gdFixed in State then Canvas.Font.Assign(FTitleFont);
  BeforeDrawCell(ACol,ARow,ARect,State);
  bc:=Canvas.Brush.Color;
  if not fl and (gdFixed in State) then
  	if (ACol<FixedCols) and (ARow=SelRow) or (ARow<FixedRows) and (ACol=SelCol) then begin
    	Canvas.Brush.Color:=InvColor(FixedColor);
    	InvColorSelf(Canvas.Font);
    end;
  if (ACol<FixedCols) and not fl then inherited DrawCell(ACol,ARow,ARect,State)
  else with Canvas do begin
    ColRowToXY(ACol,ARow,X,Y);
    fl1 := GrayCell(X,Y,ARect,State) and ((State=[]) or (gdSelected in State));
    if fl1 then
      if State=[] then Brush.Color:=FixedColor else Font.Color:=FixedColor;
  	with ARect do begin
      s:=Cells[ACol,ARow]; t:=2;
      if fl1 then t := (Bottom-Top-Canvas.TextHeight(s)) div 2;
      if gdFixed in State then StrTranSelf(s,'^',' ');
      Canvas.TextRect(ARect,Left+OffsLeftAlign(ACol,ARow,ARect),Top+t,s);
    end;
    IfThenDrawCell(OnDrawCell,Self,ACol,ARow,ARect,State);
  end;
  Canvas.Font.Assign(Font); Canvas.Brush.Color:=bc;
  DelStack;
end;

function TStrTable.AlignCell;
begin
  AddStack('TStrTable.AlignCell',Self);
  if ACol<LeftCol+VisibleColCount then begin
    result:=FAlignCells;
    if Assigned(FOnAlignCell) then FOnAlignCell(Self,ACol,ARow,result);
  end
  else result:=taLeftJustify;
  DelStack;
end;

function TStrTable.GrayCell;
begin
	AddStack('TStrTable.GrayCell',Self);
	if Assigned(FOnGrayCell) then result:=FOnGrayCell(Self,X,Y,ARect,State) else result:=false;
  DelStack;
end;

function TStrTable.SelectCell;
var i: longint;
begin
	AddStack('TStrTable.SelectCell',Self);
  result := inherited SelectCell(ACol,ARow);
  if result then with Canvas do begin
  	SelCol:=ACol; SelRow:=ARow;
    if ACol<>Col then begin
	    DrawFixedCol(Col); DrawFixedCol(ACol);
    end;
    if ARow<>Row then for i:=0 to FixedCols-1 do begin
    	Brush.Color:=FixedColor; DrawCell(i,Row,InfCellRect(i,Row),[gdFixed]);
  		DrawCell(i,ARow,InfCellRect(i,ARow),[gdFixed]);
    end;
  end;
  DelStack;
end;

procedure TStrTable.BeforeDrawFixedCol;
begin
	AddStack('TStrTable.BeforeDrawFixedCol',Self);
  inherited BeforeDrawFixedCol(ACol);
  if (SelCol>0) and (ACol=SelCol) then InvColorSelf(Canvas.Brush);
  DelStack;
end;

{function TStrTable.DatCellRect(X,Y: Word): TRect;
var w: longint;
begin
	XYToColRow(X,Y); result:=CellRect(X,Y);
  Canvas.Font.Assign(Font); w:=Canvas.TextWidth(Cells[X,Y]);
  with result do begin
	  Inc(Left,(Right-Left-w) div 2); Right:=Left+w;
  end;
end;}

procedure TStrTable.XYToColRow(var X,Y: Word);
var z: Word;
begin
	AddStack('TStrTable.XYToColRow',Self);
	if Inverted then begin
  	z:=X; X:=Y; Y:=z;
  end;
  Inc(X,FixedCols); Inc(Y,FixedRows);
  DelStack;
end;

procedure TStrTable.XYToColRow(X,Y: Word; var ACol,ARow: longint);
begin
  XYToColRow(X,Y); ACol:=X; ARow:=Y; 
end;

procedure TStrTable.ColRowToXY(aCol,aRow: longint; var X,Y: Word);
var z: Word;
begin
	AddStack('TStrTable.ColRowToXY',Self);
  X:=max(0,ACol-FixedCols); Y:=max(0,ARow-FixedRows);
	if Inverted then begin
  	z:=X; X:=Y; Y:=z;
  end;
  DelStack;
end;

procedure TStrTable.ColRowToXY(var X,Y: Word);
begin
  AddStack('TStrTable.ColRowToXY(c)',Self);
  ColRowToXY(Col,Row,X,Y);
  DelStack;
end;

function IfThenStrTblGray;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function StringBrowlVar;
begin
  result:=PointerVar(v);
end;

procedure Register;
begin
  RegisterComponents('OurLib',[TStringBrowl,TStrTable]);
end;

end.
