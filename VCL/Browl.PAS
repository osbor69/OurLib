unit Browl;

interface

{$I LIBTEST}
uses
  Windows,Messages,Classes,Controls,Forms,Grids,DBGrids,DB,Dbcgrids,SysUtils,Graphics,
  MyTypes,My_pr,KeyLb,KeyMenu,FPanel,Schem,RecVal,RecDB,LbSeek,PaintCtl,MulQry,BrQuery,RbMenu;

type
	TBrPanel = class(TPaintControl)
  protected
    procedure FPaint; override;
		procedure ParentFont; override;
  end;

  TBrDelBeforeUpdate = procedure(db: TRecDB; var tr,ii: longint) of object;
  TBrDelExcept = procedure(ost: longint; E: Exception; const Msg: string) of object;
  TBrNumCalc = function(Sender: TObject; const FldZn: string; ACol,ARow,X,Y: longint): string of object;
	TBrGrayCellEvent = function(Sender: TObject; const Rect: TRect;
	  DataCol: longint; Column: TColumn; State: TGridDrawState): boolean of object;
	TBrTransEvent = function(Sender: TObject; const Value: string; Size: longint; lQuery: boolean): string of object;
  TBrOrdFldNameEvent = procedure(Sender: TObject; ord: longint; var Name: string) of object;
  TBrGetUsPrmFldEvent = procedure(Sender: TObject; var af: TArrStr) of object;
  TBrCanDel = function(LsUsed: TStringList; const cod: string): boolean;
  TBrNewCod = procedure(LsUsed: TStringList; const oldcod,newcod: string; var result: boolean);
  TBrNewCodPrm = procedure(var aTable: TArrStr; var Options: TCngNumOptions);
  TBrSelNoUsed = procedure(fCod: TField; var LsUsed: TStringList; LsMDNew: PStringList);

	TBrowl = class(TCustomDBGrid)
  private
  { Private declarations }
   	GSeek: TLbSeek;
    FKeyDblClick: longint;
   	FNmProc: TKeyLbNmProc;
	 	BrowlKey: TKeyProc;
	 	FFieldSeek,FFieldLong: TField;
    FCloseOnSelect,lDrag: boolean;
    FOnAfterEnter,FOnAfterExit,FOnAfterPaint,FOnBeforePaint: TNotifyEvent;
    FOnTransSeek: TBrTransEvent;
    FOnBrMouseDown: TMouseEvent;
    FOnNumCalc: TBrNumCalc;
    FOnGrayCell: TBrGrayCellEvent;
    FOnOrdFldName: TBrOrdFldNameEvent;
    FOnShowHint: TShowHintEvent;
    FOnGetUsPrmFld: TBrGetUsPrmFldEvent;
    sCalc,UsPrmName: string;
    PnOrd: TBrPanel;
    MnOrd: TDefMenu;
    lsMemGk: PMemGkList;
   	procedure SetNmProc(Value: TKeyLbNmProc);
		procedure KeyEnter(key: longint; tw: TWinControl);
	 	procedure ProcKey(key: longint; tw: TWinControl);
	 	procedure BrSeek(Sender: TObject);
		procedure EnabledKeys(MainMn: TKeyMenu);
		procedure SchemPSeek;
    procedure OrdCapt;
		procedure SetOrder(ord: longint);
		function OrdFldName(ord: longint): string;
    procedure PnOrdMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
    procedure PaintCtlClick(Sender: TObject);
    procedure IncLeftCol(const d2: longint);
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
   	procedure WMRebuild(var msg: TWMRebuild); message WM_REBUILD;
    procedure WMSchem(var msg: TWMSchem); message WM_SCHEM;
		procedure WMCalc(var msg: TWMCalc); message WM_CALC;
		procedure WMNoSetRedraw(var Message: TMessage); message WM_NOSETREDRAW;
		procedure WMUsPrm(var msg: TWMUsPrm); message WM_USPRM;
		procedure WMLButtonDown(var msg: TWMLButtonDown); message WM_LBUTTONDOWN;
		procedure WMMButtonDown(var msg: TWMMButtonDown); message WM_MBUTTONDOWN;
		procedure WMRButtonDown(var msg: TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure WMGetDlgCode(var Msg: TWmGetDlgCode); message wm_GetDlgCode;
  	procedure WMApplHint(var Msg: TWMApplHint); message WM_APPLHINT;
  	procedure WMBrFind(var Msg: TWMBrFind); message WM_BRFIND;
  protected
  { Protected declarations }
  	FKeyPanel: TKeyLb;
   	procedure DblClick; override;
		procedure KeyDown(var Key: Word; Shift: TShiftState); override;
		procedure KeyPress(var Key: Char); override;
		//procedure KeyUp(var Key: Word; Shift: TShiftState); override;
		procedure TopLeftChanged; override;
		procedure DragOver(Source: TObject; X,Y: longint; State: TDragState; var Accept: Boolean); override;
		procedure DoEndDrag(Target: TObject; X,Y: longint); override;
		procedure LinkActive(Value: Boolean); override;
		procedure Paint; override;
    procedure DrawColumnCell(const Rect: TRect; DataCol: longint;
      Column: TColumn; State: TGridDrawState); override;
    procedure AssignTo(Dest: TPersistent); override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    //procedure LayoutChanged; override;
		function TransSeek(const Value: string; Size: longint; lQuery: boolean): string; dynamic;
    procedure BrMouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: longint); dynamic;
  public
		Qry: TFindQuery;
  	NoSetRedraw: boolean;
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
  	procedure DoEnter; override;
  	procedure DoExit; override;
	 	procedure Init;
		function SelRect(ALeft: longint = NegDef; ATop: longint = NegDef; ARight: longint = NegDef; ABottom: longint = NegDef): TRect;
    function UpdateCur: boolean;
	 	function BrUpdate(tr: longint = NegDef; ii: longint = NegDef): boolean; overload;
		function BrUpdate(tr: longint; const v: variant; const nmFld: string): boolean; overload;
    procedure GotoRec(ii: longint);
	 	function EditRec(const Capt: TCaption; db: TRecDB; fEdit: TObject;
      const nmfCode: string = ''; PrBeforeUpd: TNotifyEvent = nil;
      const dwValue: string = ''; const dwNameWnd: string = ''; const dwNameScr: string = '';
      PrBeforeShow: TNotifyEvent = nil): boolean; overload;
	 	function EditRec(const Capt: TCaption; const adb: array of TRecDB; fEdit: TObject;
      const nmfCode: string = ''; PrBeforeUpd: TNotifyEvent = nil;
      const dwValue: string = ''; const dwNameWnd: string = ''; const dwNameScr: string = '';
      PrBeforeShow: TNotifyEvent = nil): boolean; overload;
	 	function AppRec(const Capt: TCaption; db: TRecDB; fEdit: TObject;
    	Opt: TBrAppOpt = []; const glkey: string = ''; const nmfCode: string = '';
      PrBeforeUpd: TNotifyEvent = nil;
      const dwValue: string = ''; const dwNameWnd: string = ''; const dwNameScr: string = '';
      PrBeforeShow: TNotifyEvent = nil; pFindAfterUpd: PBoolean = nil): boolean;
		function DelAsk(db: TRecDB; CanDel: TProcValid = nil; const cMsg: string = '';
    	BeforeUpdate: TBrDelBeforeUpdate = nil; AskState: boolean = true;
      ProcDel: TNotifyEvent = nil; ProcExept: TBrDelExcept = nil): boolean;
    class procedure PrDelNone(Sender: TObject);
		function GridsWidth: longint;
		procedure FormShow(Sender: TObject);
		procedure FormHide(Sender: TObject);
		function SelPoint(ACol: longint = NegDef): TPoint;
    function CellRect(ACol,ARow: Longint): TRect;
    function GetXField(X: longint; var i: longint): TField; overload;
    function GetXField(X: longint; var i: longint; var f: TField): boolean; overload;
    procedure Assign(Source: TPersistent); override;
		procedure RefreshOrder;
    function FindQuery: boolean;
		function GrayCell(const Rect: TRect; DataCol: longint; Column: TColumn;
    	State: TGridDrawState): boolean; dynamic;
    procedure IncOptions(Incl: TDBGridOptions; Excl: TDBGridOptions = []);
    procedure FindMemo(lsm: PMemGkList);
    procedure SetKeyBut(const Key: array of TKeyBut);
    procedure PaintHead(lDown: boolean; c1,c2: ShortInt; const txt: string); overload;
    function PaintHead(var c: ShortInt): boolean; overload;
    function bmCheckPaint(const ARect: TRect; Column: TColumn; lSet: boolean = true): boolean; overload;
    function bmCheckPaint(const ARect: TRect; Column: TColumn; const Fields: array of TField;
      lSet: boolean = true): boolean; overload;
    function bmCheckPaint(const ARect: TRect; Column: TColumn; Field: TField; lSet: boolean = true): boolean; overload;
    function bmCheckPaint(const ARect: TRect; const Fields: array of string; Column: TColumn;
      lSet: boolean = true; bm: TBitMap = nil): boolean; overload;
    function bmCheckPaint(const ARect: TRect; Column: TColumn; Field,FieldCode: TField; lsCode: TIntegerList;
      lSet: boolean = true): boolean; overload;
    function QQs(lTrim: boolean = true): string; 
	  { Унаследованные }
    property Canvas;
  	property Col;
  	property Row;
    property LeftCol;
    property TopRow;
  	property ColCount;
  	property RowCount;
    property VisibleColCount;
    property VisibleRowCount;
    property ColWidths;
    property RowHeights;
  published
    property CloseOnSelect: boolean read FCloseOnSelect write FCloseOnSelect;
    property FieldLong: TField read FFieldLong write FFieldLong;
    property FieldSeek: TField read FFieldSeek write FFieldSeek;
  	property KeyDblClick: longint read FKeyDblClick write FKeyDblClick;
   	property NmProc: TKeyLbNmProc read FNmProc write SetNmProc;
	 	property OnAfterEnter: TNotifyEvent read FOnAfterEnter write FOnAfterEnter;
	 	property OnAfterExit: TNotifyEvent read FOnAfterExit write FOnAfterExit;
	 	property OnAfterPaint: TNotifyEvent read FOnAfterPaint write FOnAfterPaint;
	 	property OnBeforePaint: TNotifyEvent read FOnBeforePaint write FOnBeforePaint;
	 	property OnBrMouseDown: TMouseEvent read FOnBrMouseDown write FOnBrMouseDown;
	 	property OnBrowlKey: TKeyProc read BrowlKey write BrowlKey;
    property OnGetUsPrmFld: TBrGetUsPrmFldEvent read FOnGetUsPrmFld write FOnGetUsPrmFld;
	 	property OnGrayCell: TBrGrayCellEvent read FOnGrayCell write FOnGrayCell;
		property OnNumCalc: TBrNumCalc read FOnNumCalc write FOnNumCalc;
    property OnOrdFldName: TBrOrdFldNameEvent read FOnOrdFldName write FOnOrdFldName;
	 	property OnTransSeek: TBrTransEvent read FOnTransSeek write FOnTransSeek;
    property OnShowHint: TShowHintEvent read FOnShowHint write FOnShowHint;
  	{ Унаследованные }
   	property BorderStyle;
   	property Color;
    property Columns stored False; //StoreColumns;
   	property Ctl3D;
    property DataLink;
   	property DataSource;
   	property DefaultDrawing;
   	property DragCursor;
   	property DragMode;
   	property Enabled;
   	property FixedColor;
   	property Font;
   	property Options;
   	property ParentColor;
   	property ParentCtl3D;
   	property ParentFont;
   	property ParentShowHint;
   	property PopupMenu;
   	property ReadOnly;
   	property ShowHint;
   	property TabOrder;
   	property TabStop;
   	property TitleFont;
   	property Visible;
    property OnClick;
   	property OnColEnter;
   	property OnColExit;
    property OnDblClick;
   	property OnDrawColumnCell;
   	property OnDragDrop;
   	property OnDragOver;
   	property OnEndDrag;
   	property OnEnter;
   	property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    //property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

	TCtrlBrFindEvent = TStringEvent0;

  TCtrlBrowl = class(TDBCtrlGrid)
  private
  { Private declarations }
   	FKeyPanel: TKeyLb;
    FOnStrFind: TCtrlBrFindEvent;
		Qry: TFindQuery;
		procedure ProcKey(key: longint; tw: TWinControl);
    function FindQuery: boolean;
    procedure WMRebuild(var msg: TWMRebuild); message WM_REBUILD;
    procedure WMSchem(var msg: TWMSchem); message WM_SCHEM;
  	procedure WMBrFind(var Msg: TWMBrFind); message WM_BRFIND;
  protected
  { Protected declarations }
  	procedure DoExit; Override;
   	procedure DblClick; override;
    function StrFind: string; dynamic;
  public
  { Public declarations }
//    function DelAsk(db: TRecDB): boolean;
    procedure BrUpdate(tr,ii: longint);
    function Row: longint;
    procedure First;
    procedure Last;
    procedure Next;
    procedure Prior;
  	procedure DoEnter; Override;
    procedure Assign(Source: TPersistent); override;
 	published
  { Published declarations }
	 	property OnStrFind: TCtrlBrFindEvent read FOnStrFind write FOnStrFind;
 	end;

procedure Register;
procedure BrSetSize(f: TField; n: longint);
function IfThenBrGray(AValue: boolean; ATrue: TBrGrayCellEvent; AFalse: TBrGrayCellEvent = nil): TBrGrayCellEvent; overload;
function IfThenBrGray(Proc: TBrGrayCellEvent; Sender: TObject; const Rect: TRect;
  DataCol: longint; Column: TColumn; State: TGridDrawState): boolean; overload;
{function IfThenBrCanDel(Proc: TBrCanDel; LsUsed: TStringList; const cod: string): boolean;
procedure IfThenBrNewCod(Proc: TBrNewCod; LsUsed: TStringList; const oldcod,newcod: string; var result: boolean);
procedure IfThenBrNewCodPrm(Proc: TBrNewCodPrm; var aTable: TArrStr; var Options: TCngNumOptions);}
function BrowlVar(const v: variant): TBrowl;

implementation

uses ClipBrd,ExtCtrls,Math,StrUtils,Variants,
  FrmWnd,Saveini;

var oAfterScroll: TDataSetNotifyEvent;

type
  TUsPrmLogCompare = class(TDlmLogCompare)
  public
    class function ListCreate(pv: pointer; const Value: string; lNew: boolean): pointer; override;
    class function GetCount(pv,ls: pointer): longint; override;
    class procedure GetItem(var Prm: TLogTrnsValPrm; pv,lso,lsn: pointer; no,nn: longint; tp: TLogCompareItemList); override;
  end;

  TBrowlLogList = (blogBase,blogColumn);

  PBrowlLogRec = ^TBrowlLogRec;
  TBrowlLogRec = record
    br: TBrowl;
    op: TBrowlLogList;
  end;

const aUsPrmDlm: array[TBrowlLogList] of char = (';',',');
  K_OrdBeg = K_1;

procedure BrSetSize;
begin
	AddStack('Browl.BrSetSize');
	f.Size:=n; f.DisplayWidth:=n;
  DelStack;
end;

function IfThenBrGray(AValue: boolean; ATrue: TBrGrayCellEvent; AFalse: TBrGrayCellEvent = nil): TBrGrayCellEvent;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThenBrGray(Proc: TBrGrayCellEvent; Sender: TObject; const Rect: TRect;
  DataCol: longint; Column: TColumn; State: TGridDrawState): boolean;
begin
  if Assigned(Proc) then result:=Proc(Sender,Rect,DataCol,Column,State) else result:=false;
end;

{function IfThenBrCanDel;
begin
  if Assigned(Proc) then result:=Proc(LsUsed,cod) else result:=true;
end;

procedure IfThenBrNewCod;
begin
  if Assigned(Proc) then Proc(LsUsed,oldcod,newcod,result);
end;

procedure IfThenBrNewCodPrm;
begin
  if Assigned(Proc) then Proc(aTable,Options);
end;}

function BrowlVar;
begin
  result:=PointerVar(v);
end;

function GetQuery(Control: TControl; ds: TDataSource): TFindQuery;
begin
	AddStack('Browl.GetQuery');
	result:=nil;
	if Assigned(ds) then if Assigned(ds.DataSet) then begin
    result:=PointerOwner(ds.DataSet);
    if Assigned(result) then result.Control:=Control;
  end;
  DelStack;
end;

{ TBrPanel }
procedure TBrPanel.FPaint;
begin
	AddStack('TBrPanel.FPaint',Self);
  with Canvas do begin
  	Brush.Color:=TPanel(Owner).Color; FillRect(Bounds);
  end;
  DrawCaption(Bounds,taLeftJustify);
  DelStack;
end;

procedure TBrPanel.ParentFont;
begin
end;

{ TBrowl }
constructor TBrowl.Create;
begin
	AddStack('TBrowl.Create',Self);
	Inherited Create(AOwner);
  //Parent:=pointer(ao);
  ParentFont:=true; Options:=[dgTitles,dgColLines,dgRowLines,dgRowSelect,dgAlwaysShowSelection];
  ReadOnly:=true; FCloseOnSelect:=false; FNmProc:=TKeyLbNmProc.Create; 
  FKeyDblClick:=K_Enter;
  DelStack;
end;

destructor TBrowl.Destroy;
begin
	AddStack('TBrowl.Destroy',Self);
  FNmProc.Free; 
  inherited Destroy;
  DelStack;
end;

procedure TBrowl.WMGetDlgCode;
begin
	AddStack('TBrowl.WMGetDlgCode',Self);
	inherited;
  GetDlgCodeTab(Self,Msg);
  DelStack;
end;

procedure TBrowl.Assign;
begin
	AddStack('TBrowl.Assign',Self);
  if Source is TBrowl then with TBrowl(Source) do begin
  	Self.FieldSeek:=FieldSeek;
  	Self.onBrowlKey:=onBrowlKey;
  	Self.onTransSeek:=onTransSeek;
  	Self.NmProc.Assign(NmProc);
  end;
	inherited Assign(Source);
  DelStack;
end;

procedure TBrowl.FormShow;
var a: array[1..2] of string;
  af: TArrStr;
  i,j: longint;
  f: TField;
begin
	AddStack('TBrowl.FormShow',Self);
  if FindQuery then begin
    Qry.Active:=true;
    if Qry.Active then begin
      MsgSaveIni(ParentForm(Self),opsRest,UsPrmName);
      IncL(UsPrmName,'Browl.','.'+Qry.GetListArg(sTABLE));
      LsArrFill(GetUsPrm(UsPrmName),a,aUsPrmDlm[blogBase]);
      if dgColumnResize in Options then begin
        LsArrDynamic(a[1],af,aUsPrmDlm[blogColumn],lsaSetLen);
        if Assigned(FOnGetUsPrmFld) then FOnGetUsPrmFld(Self,af);
        if Length(af)>0 then begin
          j:=0;
          for i:=low(af) to high(af) do if Qry.FindField(af[i],f) then begin
            f.Index:=j; Inc(j);
          end;
        end;
      end;
      if (a[2]<>'') and (Qry is TBrQuery) and not FCloseOnSelect
      then TBrQuery(Qry).Order:=Int0(a[2]);
    end;
  end;
  Init;
  if Parent is TRbPanel then TRbPanel(Parent).RebuildControls;
  DoEnter;
  DelStack;
end;

procedure TBrowl.FormHide;
var s,s1: string;
  i: longint;
begin
	AddStack('TBrowl.FormHide',Self);
  if FindQuery then begin
    if Qry.Active then begin
      s:='';
      if dgColumnResize in Options then begin
        for i:=0 to Qry.FieldCount-1 do IncD(s,Qry.Fields[i].FieldName+aUsPrmDlm[blogColumn]);
        DecLen(s);
      end;
      MsgSaveIni(ParentForm(Self),opsSave,s1);
      if Qry is TBrQuery then with TBrQuery(Qry) do if Orders.Count>1 then begin
        if FCloseOnSelect
        then s1:=DlmCopy(GetUsPrm(UsPrmName),2,1,aUsPrmDlm[blogBase])
        else s1:=IntToStr(Order);
        IncD(s,aUsPrmDlm[blogBase]+s1);
      end;
      if s<>'' then SetUsPrm(Self,UsPrmName,s);
    end;
	  if not FCloseOnSelect then Qry.Active:=false;
    Qry.ClearFilter;
  end;
  DelStack;
end;

procedure TBrowl.WMLButtonDown;
begin
	AddStack('TBrowl.WMLButtonDown',Self);
	inherited;
  with msg do BrMouseDown(mbLeft,KeysToShiftState(Keys),XPos,YPos);
  DelStack;
end;

procedure TBrowl.WMMButtonDown;
begin
	AddStack('TBrowl.WMMButtonDown',Self);
	inherited;
  with msg do BrMouseDown(mbMiddle,KeysToShiftState(Keys),XPos,YPos);
  DelStack;
end;

procedure TBrowl.WMRButtonDown;
begin
	AddStack('TBrowl.WMRButtonDown',Self);
	inherited;
  with msg do BrMouseDown(mbRight,KeysToShiftState(Keys),XPos,YPos);
  DelStack;
end;

procedure TBrowl.BrMouseDown;
begin
	AddStack('TBrowl.BrMouseDown',Self);
	IfThenMouse(FOnBrMouseDown,Self,Button,Shift,X,Y);
  DelStack;
end;

{ Реакция на двойной щелчок }
procedure TBrowl.DblClick;
begin
	AddStack('TBrowl.DblClick',Self);
  inherited DblClick;
	Init;
	if Assigned(FKeyPanel) then FKeyPanel.ExecKey(FKeyDblClick);
  DelStack;
end;

procedure TBrowl.KeyDown;
var ok: longint;
  okd: TKeyEvent;
  fl: boolean;
begin
	AddStack('TBrowl.KeyDown',Self);
  fl:={Assigned(FKeyPanel) and} (dgRowSelect in Options) and (Key in [VK_LEFT,VK_RIGHT]) and (Shift=[]);
  ok:=Key; okd:=OnKeyDown;
	if fl then begin
    Key:=0; OnKeyDown:=nil;
  end;
  if Assigned(GSeek) then GSeek.KeyDown(Key,Shift);
	inherited KeyDown(Key,Shift);
	if fl then begin
    Key:=ok; OnKeyDown:=okd;
    if Assigned(okd) then okd(Self,Key,Shift);
  end;
  DelStack;
end;

{ Ввод значение для поиска по столбцу }
procedure TBrowl.KeyPress;
var fl: boolean;
	i,n,k: longint;
begin
	AddStack('TBrowl.KeyPress',Self);
  inherited KeyPress(Key);
	if Assigned(GSeek) then
    if FindQuery then
      if Qry.Active then
        if Qry.IsRecords then begin
          fl:=true;
          if Assigned(FKeyPanel) then begin
            n:=Ord(Key);
            with FKeyPanel do for i:=0 to KeyCount-1 do begin
              k:=Keys(i).Key;
              if (k in [K_SPACE,K_BS..KEY_CNT]) and (aKeyLab[k]=n) then begin
                fl:=false; break;
              end;
            end;
          end;
          if fl then GSeek.KeyPress(Key);
        end;
  DelStack;
end;

{procedure TBrowl.KeyUp;
begin
	AddStack('TBrowl.KeyUp',Self);
	if Assigned(FKeyPanel) and (dgRowSelect in Options) and (Key in [VK_LEFT,VK_RIGHT]) and (Shift=[])
  then Key:=0;
	inherited KeyUp(Key,Shift);
  DelStack;
end;}

procedure TBrowl.SetNmProc;
begin
	AddStack('TBrowl.SetNmProc',Self);
  NmProc.Assign(Value);
  DelStack;
end;

procedure TBrowl.WMNoSetRedraw;
begin
	AddStack('TBrowl.WMNoSetRedraw',Self);
	if NoSetRedraw then Message.Result:=1;
  DelStack;
end;

procedure TBrowl.WMUsPrm;
var r: TBrowlLogRec;
begin
  AddStack('TBrowl.WMUsPrm',Self);
  with Msg.Prm^ do
    if nmf=fNAME then begin
      val:='списки: '+GetParentForm(Self).Caption; lBreak:=true;
    end
    else if nmf=fUSPRM then begin
      r.br:=Self; r.op:=blogBase; TUsPrmLogCompare.Execute(Msg.Prm^,@r);
    end;
  DelStack;
end;

procedure TBrowl.CMVisibleChanged;
begin
  AddStack('TBrowl.CMVisibleChanged',Self);
  inherited;
  if Assigned(GSeek) then GSeek.Visible:=Visible;
  if Assigned(PnOrd) then PnOrd.Visible:=Visible;
  DelStack;
end;

procedure TBrowl.WMRebuild;
const iY=5;
var wm,hm,hs,hp,c1,l,t,w,h: longint;
begin
	AddStack('TBrowl.WMRebuild',Self);
  if Visible then begin
    with msg.RbPnl do begin
      wm:=CltWidth; hm:=CltHeight-HeaderHeight;
    end;
    // Поле быстрого поиска
    if Assigned(FFieldSeek) then begin
      if Assigned(GSeek) then GSeek.CharWidth:=FFieldSeek.DisplayWidth
      else begin
        GSeek:=TLbSeek.CreateParent(Parent,{Self,}FFieldSeek.DisplayWidth,BrSeek);
        GSeek.OnClick:=PaintCtlClick;
        if Parent is TRbPanel then GSeek.Canvas:=TRbPanel(Parent).Canvas;
      end;
      GSeek.Title:=FFieldSeek.DisplayLabel+':'; SchemPSeek;
    end
    else FreeAndNil(GSeek);
    // Изменерие ширины
    hs:=SysMetric.iScrollWidth;
    if Assigned(FFieldLong) then with FFieldLong do begin
      while (GridsWidth+hs<wm) and (DisplayWidth<=Size) do DisplayWidth:=DisplayWidth+1;
      while (GridsWidth+hs>wm) and (DisplayWidth>1) do DisplayWidth:=DisplayWidth-1;
    end;
    w:=min(GridsWidth+hs,wm);
    hs:=msg.RbPnl.HeaderHeight+iY; c1:=2;
    if Assigned(FFieldSeek) then begin
      GSeek.SetBounds((msg.RbPnl.Width-GSeek.Width) div 2,hs,0,0);
      Inc(hs,GSeek.Height+iY); Dec(hm,GSeek.Height); Inc(c1);
    end;
    if Assigned(PnOrd) then with PnOrd do begin
      Font.Assign(TitleFont); Canvas.Font.Assign(Font); hp:=CanvasMaxH(Canvas);
      SetBounds(msg.RbPnl.BevPanel,msg.RbPnl.Height-iY-hp,msg.RbPnl.CltWidth,hp);
      Dec(hm,Height);
    end;
    h:=hm; l:=Left; t:=Top; msg.RbPnl.SortObj := not(Assigned(FFieldSeek) or Assigned(PnOrd));
    if not msg.RbPnl.SortObj then begin
      l:=(msg.RbPnl.Width-Width) div 2; t:=hs; h:=hm-c1*iY;
    end;
    SetBounds(l,t,w,h);
  end;
  DelStack;
end;

procedure TBrowl.PaintCtlClick;
begin
  AddStack('TBrowl.PaintCtlClick');
  GetParentForm(Self).ActiveControl:=Self;
  DelStack;
end;

function TBrowl.GridsWidth;
const wDlm = 2;
var i: longint;
begin
	AddStack('TBrowl.GridsWidth',Self);
	result:=0;
	for i:=0 to ColCount-1 do Inc(result,ColWidths[i]+wDlm);
  if result>0 then Inc(result,wDlm);
  DelStack;
end;

{ Установка цветов и шрифтов }
procedure TBrowl.WMSchem;
begin
	AddStack('TBrowl.WMSchem',Self);
	with msg.Schem do begin
   	Color:=Color1; Font.Assign(Font1);
		FixedColor:=Color2; TitleFont.Assign(Font2);
    SchemPSeek;
    if Assigned(PnOrd) then PnOrd.Font.Assign(TitleFont);
  end;
  DelStack;
end;

procedure TBrowl.SchemPSeek;
begin
	AddStack('TBrowl.SchemPSeek',Self);
  if Assigned(GSeek) then begin
		GSeek.TitleFont.Assign(TitleFont); GSeek.Color:=Color; GSeek.Font.Assign(Font);
  end;
  DelStack;
end;

procedure TBrowl.Init;
begin
	AddStack('TBrowl.Init',Self);
	if Assigned(GSeek) then GSeek.Init;
  DelStack;
end;

procedure Tbrowl.DoEnter;
type TKeyList = (klF6,klSF6,klLeft,klRight,klF11,klCR,klCopy);
const
	a: array[TKeyList] of record
		Key: longint;
    txt,hint: string;
    norow: boolean;
	end =
  ((Key:K_F6      ; txt:'Поиск')
	,(Key:K_Shift_F6                  ; hint:'Продолжить поиск')
  ,(Key:K_Left                      ; hint:'Влево' ; norow:true)
  ,(Key:K_Right                     ; hint:'Вправо'; norow:true)
  ,(Key:K_F11     ; txt:'Сортировка'; hint:'Сменить вид сортировки')
  ,(Key:K_Ctrl_R                    ; hint:'Обновить')
  ,(Key:K_Ctrl_C                    ; hint:'Скопировать')
  );
var i,k: longint;
  MainMn: TKeyMenu;
  ais: set of TKeyList;
  j: TKeyList;
begin
	AddStack('TBrowl.DoEnter',Self);
	if not isCalculator then begin
    inherited DoEnter;
    if FormKeyLb(Self,FKeyPanel) then begin
      FKeyPanel.DelKey(K_All,'brsel'); ais:=[];
      if not(dgRowSelect in Options) then Include(ais,klLeft);
      RefreshOrder;
      if not Assigned(PnOrd) then Include(ais,klF11);
      for i:=0 to FNmProc.Count-1 do begin
      	k:=FKeyPanel.SetKeySt(FNmProc[i],BrowlKey,'browl');
        for j:=low(a) to high(a) do if k=a[j].Key then Include(ais,j);
      end;
      for j:=low(a) to high(a) do with a[j] do
      	if not(j in ais) and ((dgRowSelect in Options) or not norow) then
          if Key=K_F6 then FKeyPanel.SetKeyFind(ProcKey,'browl',kmList,false)
          else FKeyPanel.SetKey(Key,txt,hint,ProcKey,'browl',kmList);
      if FCloseOnSelect then begin
        FKeyPanel.SetKey(K_Enter,'Выбор','',KeyEnter,'brsel',kmFile);
        FKeyPanel.SetKey(K_Esc,'Отмена','',KeyEnter,'brsel',kmFile);
      end;
      if SeekKeyMenu(Self,MainMn) then begin
        MainMn.InsLine(kmList,K_F6); EnabledKeys(MainMn);
      end;
	    MsgMsOff(msoEnter,FKeyPanel);
    end;
    IfThenNotify(FOnAfterEnter,Self);
    if Assigned(FKeyPanel) then FKeyPanel.Redrw;
  end;
  DelStack;
end;

procedure Tbrowl.DoExit;
var fl: boolean;
  MainMn: TKeyMenu;
begin
  AddStack('TBrowl.DoExit',Self);
	if not isCalculator then
    if GetParentForm(Self).ActiveControl<>Parent then begin
      inherited DoExit;
      if SeekKeyMenu(Self,MainMn) then MainMn.DelLine(kmList,K_F6);
      if Assigned(GSeek) then GSeek.DelKey;
      fl:=Assigned(FKeyPanel);
      if fl then begin
        FKeyPanel.DelKeyNmPr(['brsel','browl']); MsgMsOff(msoExit,FKeyPanel);
      end;
      IfThenNotify(FOnAfterExit,Self);
      if fl then FKeyPanel.Redrw;
      Qry.ClearFilter(false);
    end;
  DelStack;
end;

procedure TBrowl.KeyEnter;
begin
	AddStack('TBrowl.KeyEnter',Self);
	TFormWnd(GetParentForm(Self)).SetModalResult(IfThen(Key=K_Enter,mrOk,mrCancel));
  DelStack;
end;

procedure TBrowl.ProcKey;
var i,j: longint;
  s: string;
begin
	AddStack('TBrowl.ProcKey',Self);
	if FindQuery then with TBrQuery(Qry) do
    // Вид сортировки
    if (Key=K_F11) and Assigned(PnOrd) then
      if Orders.Count>2 then PnOrdMouseUp(PnOrd,mbRight,[],0,-1) else SetOrder(IfThen(Order=1,2,1))
    else begin
      case Key of
        // Сдвиг влево или вправо
        K_LEFT: if LeftCol<>0	then IncLeftCol(-1);
        K_RIGHT: if LeftCol<ColCount-VisibleColCount then IncLeftCol(1);
        // Скопировать
        K_Ctrl_C: begin
          s:=''; j:=0;
          for i:=0 to Fields.Count-1 do with Fields[i] do if Visible then begin
            if (dgRowSelect in Options) or (j=Col) then IncD(s,TAB+DisplayText);
            Inc(j);
          end;
          Clipboard.AsText:=Copy(s,2,MaxInt);
        end;
        // Обновить
        K_Ctrl_R: UpdateCur;
      else // Поиск
        if Qry.IsRecords or PswdPrm.BrFindAll then WinFindKey(Key,Self,brfind,[fnoRegistr,fnoWord]
          +IfThen(not PswdPrm.BrFindAll,[fnoDirection,fnoAll])
          +IfThen(Assigned(lsMemGk),[fnoSave]),IfThen(Assigned(lsMemGk),'Поиск по содержимому'));
      end;
    end;
  DelStack;
end;

procedure TBrowl.FindMemo;
begin
  AddStack('TBrowl.FindMemo',Self);
  lsMemGk:=lsm;
  try
    ProcKey(aKeyFind[0],Self);
  finally
    lsMemGk:=nil;
  end;
  DelStack;
end;

procedure TBrowl.SetKeyBut;
begin
  AddStack('TBrowl.SetKeyBut',Self);
  TKeyLb.SetKeyBut(Key,FNmProc);
  DelStack;
end;

function TBrowl.UpdateCur;
var a: TArrStr;
  i: longint;
  ii: variant;
  af: TArrField;
  nmf: string;
begin
  AddStack('TBrowl.UpdateCur',Self);
  result := Qry is TBrQuery;
  if result then with TBrQuery(Qry) do
    if not empty(SeekKeys) then begin
      result:=false; nmf:=SeekKeys; i:=LsArrDynamic(nmf,a,','); SetLength(af,i);
      Dec(i); ii:=VarArrayCreate([0,i],varVariant);
      for i:=0 to i do
        if FindField(a[i],af[i]) then ii[i]:=af[i].Value
        else begin
          result:=true; break;
        end;
    end;
  if result then begin
    nmf:=fRECNO; ii:=Qry.FieldZN(nmf);
  end;
  result:=BrUpdate(NegDef,ii,nmf);
  DelStack;
end;

{ Поиск по столбцу }
procedure TBrowl.BrSeek;
var s,s1: string;
  lOrd: boolean;
begin
	AddStack('TBrowl.BrSeek',Self);
  if FindQuery then with Qry do begin
    s1:=TrimUpper(GetListArg(sO_LIST));
    if Pos('.',s1)=0 then s:=FFieldSeek.FieldName else s:=Origin(FFieldSeek);
    lOrd := TrimUpper(s)=s1;
	  s:=TransSeek(GSeek.GetCaption,FFieldSeek.DisplayWidth,false);
    DisableControls; First;
    while not Eof do begin
      s1:=TransSeek(FieldAsStr(FFieldSeek),FFieldSeek.DisplayWidth,true);
      if AnsiStartsStr(s,s1) then break;
      if lOrd and (s1>s) then begin
        Prior; break;
      end;
      Next;
    end;
    EnableControls;
  end;
  DelStack;
end;

{ Преобразование значения для поиска }
function TBrowl.TransSeek;
begin
	AddStack('TBrowl.TransSeek',Self);
  if Assigned(FOnTransSeek)
  then result:=FOnTransSeek(Self,Value,Size,lQuery)
  else result:=TransMask(Value,Size,msk9);
  TrimRightSelf(result);
  DelStack;
end;

procedure TBrowl.TopLeftChanged;
begin
	AddStack('TBrowl.TopLeftChanged',Self);
	inherited TopLeftChanged;
  EnabledKeys(SeekKeyMenu(Self));
  DelStack;
end;

procedure TBrowl.EnabledKeys;
var i: longint;
begin
	AddStack('TBrowl.EnabledKeys',Self);
	if Assigned(MainMn) then begin
    MainMn.EnabledItem(kmList,K_Left,LeftCol<>0);
    i:=VisibleColCount;
    MainMn.EnabledItem(kmList,K_Right,LeftCol<ColCount-i);
  end;
  DelStack;
end;

{ Обновление BROWL после изменений }
function TBrowl.BrUpdate(tr: longint = NegDef; ii: longint = NegDef): boolean;
begin
	result:=BrUpdate(tr,ii,fRECNO);
end;

function TBrowl.BrUpdate(tr: longint; const v: variant; const nmFld: string): boolean;
var i,ocol: longint;
  ii: variant;
  anmf: TArrStr;
  af: TArrField;
  fl: boolean;
begin
	AddStack('TBrowl.BrUpdate',Self);
	ocol:=LeftCol; result:=false;
	if FindQuery then with Qry do begin
		ReplNegSelf(tr,Row); ii:=v;
		if CompVar(ii,NegDef) then ii:=FindField(fRECNO).AsInteger;
    i:=LsArrDynamic(nmFld,anmf,','); SetLength(af,i); fl:=true;
    for i:=0 to i-1 do if not FindField(anmf[i],af[i]) then begin
      fl:=false; break;
    end;
    if fl then begin
      if CompVar(ii,null) then begin
        ii:=VarArrayCreate([low(af),high(af)],varVariant);
        for i:=low(af) to high(af) do with af[i] do case UnDataType(af[i]) of
          ftInteger: ii[i]:=AsInteger;
          ftBoolean: ii[i]:=AsBoolean;
          ftFloat: ii[i]:=AsFloat;
          ftDate: ii[i]:=AsDateTime;
        else ii[i]:=TrimRight(AsString);
        end;
      end
      else if MyVarType(ii)<>varArray then ii:=VarArrayOf([ii]);
      DisableControls; ReOpen;
      while not Eof do begin
        fl:=true;
        for i:=low(af) to high(af) do with af[i] do begin
          case MyVarType(ii[i]) of
            varInteger: fl := AsInteger=ii[i];
            varDouble: fl := AsFloat=ii[i];
            varDate: fl := AsDateTime=ii[i];
            varBoolean: fl := AsBoolean=ii[i];
            varString: fl := TrimRight(AsString)=TrimRight(ii[i]);
          end;
          if not fl then break;
        end;
        if fl then begin
          result:=true; break;
        end;
        Next;
      end;
      EnableControls;
      if Row<>tr then begin
        DisableControls; ii:=Row-tr;
        for i:=1 to ii do begin
          Next;
          if Eof then begin
            ii:=i-1; break;
          end;
        end;
        for i:=1 to ii do Prior;
        EnableControls;
      end;
    end;
  end;
  LeftCol:=ocol;
  DelStack;
end;

{ Встать на указанную RECNO }
procedure TBrowl.GotoRec;
var f: TField;
begin
	AddStack('TBrowl.GotoRec',Self);
	if FindQuery then with Qry do
    if FindField(fRECNO,f) then begin
      DisableControls; First;
      while not Eof and (f.AsInteger<>ii) do Next;
      EnableControls;
    end;
  DelStack;
end;

// Редактирование записи в БД
function BrEditProc(Sender: TObject; lApp: boolean; const Capt: TCaption;
  const glkey,nmfCode,dwValue,dwNameWnd,dwNameScr: string): boolean;
var i: longint;
begin
  AddStack('Browl.BrEditProc');
  result:=false;
  for i:=low(aBrEditProc) to high(aBrEditProc) do
    if aBrEditProc[i](Sender,lApp,Capt,glkey,nmfCode,dwValue,dwNameWnd,dwNameScr,result) then break;
  DelStack;
end;

function TBrowl.EditRec(const Capt: TCaption; db: TRecDB; fEdit: TObject;
  const nmfCode: string = ''; PrBeforeUpd: TNotifyEvent = nil;
  const dwValue: string = ''; const dwNameWnd: string = ''; const dwNameScr: string = '';
  PrBeforeShow: TNotifyEvent = nil): boolean;
begin
  result:=EditRec(Capt,[db],fEdit,nmfCode,PrBeforeUpd,dwValue,dwNameWnd,dwNameScr,PrBeforeShow);
end;

function TBrowl.EditRec(const Capt: TCaption; const adb: array of TRecDB; fEdit: TObject;
  const nmfCode: string = ''; PrBeforeUpd: TNotifyEvent = nil;
  const dwValue: string = ''; const dwNameWnd: string = ''; const dwNameScr: string = '';
  PrBeforeShow: TNotifyEvent = nil): boolean;
var i: longint;
begin
	AddStack('TBrowl.EditRec',Self);
  if Assigned(Self) then result:=FindQuery else result:=true;
	if result then begin
    if Assigned(Self) then for i:=low(adb) to high(adb) do
      if Assigned(adb[i]) then adb[i].GotoRec(Qry.FieldZN(Qry.FldDuplicate(fRECNO,i)));
    SetLogVid(logvEditRec);
    IfThenNotify(PrBeforeShow,fEdit);
    result:=BrEditProc(fEdit,false,Capt,'',nmfCode,dwValue,dwNameWnd,dwNameScr);
    if result then begin
      IfThenNotify(PrBeforeUpd);
      if Assigned(Self) then BrUpdate;
    end;
    SetLogVid;
  end;
  DelStack;
end;

// Добавление записи в БД
function TBrowl.AppRec;
var i: longint;
  rdb: TRecDBDef;
begin
	AddStack('TBrowl.AppRec',Self);
	if FindQuery then begin
    if Assigned(db) then begin
      i:=TBrQuery(Qry).FieldZn(fRECNO);
      if (db.Recno<>i) and (brappCopy in Opt) and not(brappNoGoRecCopy in Opt) then db.GotoRec(i);
      if IsClass(db,TRecDBDef,pointer(rdb)) and (brappDefFromSelf in Opt) then
        if brappCopy in Opt then rdb.InitFldDef(dwdefGotoRec)
        else begin
          rdb.SetFldDefText; rdb.NewRec;
        end;
      if not(brappNoDoNewRec in Opt)
      then db.NewRec(IfThen(brappCopy in Opt,newrCopy),TBrQuery(Qry).GlobKey);
    end;
    SetLogVid(logvAppRec);
    IfThenNotify(PrBeforeShow);
    result:=BrEditProc(fEdit,true,Capt,glkey,nmfCode,dwValue,dwNameWnd,dwNameScr);
    if result and Assigned(db) then begin
      db.AppRec(true);
      IfThenNotify(PrBeforeUpd);
      SetPBoolean(pFindAfterUpd,BrUpdate(Row,db.Recno));
    end;
    SetLogVid;
  end
  else result:=false;
  DelStack;
end;

// Удаление с запросом
function TBrowl.DelAsk;
var ost,ii,ir,tr: longint;
  Msg: string;
begin
	ost:=AddStack('TBrowl.DelAsk',Self);
	if FindQuery then begin
  	if cMsg='' then Msg:=ArrayAsList(amsDel,CRLF) else Msg:=cMsg;
    SetLogVid(logvDelRec); result:=Ask([Msg],AskState);
    if result then with TBrQuery(Qry) do begin
      ii:=FieldZn(fRECNO); ir:=db.Recno;
      if ir<>ii then db.GotoRec(ii);
      try
        if IfThenValid(CanDel,db) then begin
          tr:=Row; DisableControls; 
          if not IfThenNotify(ProcDel,db) then db.DelRec('',[delLog]);
          Next;
          if Eof then ii:=0 else ii:=FieldZn(fRECNO);
          if Assigned(BeforeUpdate) then BeforeUpdate(db,tr,ii);
          BrUpdate(tr,ii); EnableControls;
        end;
      except
        on E: Exception do if Assigned(ProcExept) then ProcExept(ost,E,E.Message) else raise;
      end;
      if db.Recno<>ir then db.GotoRec(ir);
    end;
    SetLogVid;
  end
  else result:=false;
	DelStack;
end;

class procedure TBrowl.PrDelNone;
begin
end;

{ Сменить вид сортировки }
procedure TBrowl.SetOrder;
var tr,ii: longint;
begin
	AddStack('TBrowl.SetOrder',Self);
	if FindQuery then with TBrQuery(Qry) do if Order<>ord then begin
    DisableControls; tr:=Row; ii:=FieldZn(fRECNO); Close; Order:=ord; BrUpdate(tr,ii);
    OrdCapt; EnableControls;
  end;
  DelStack;
end;

procedure TBrowl.OrdCapt;
begin
	AddStack('TBrowl.OrdCapt',Self);
	if Assigned(PnOrd) then
    if FindQuery then PnOrd.Caption:=' Сортировка: '+OrdFldName(TBrQuery(Qry).Order);
  DelStack;
end;

function TBrowl.OrdFldName;
var a: array[1..10] of string;
  i,l: longint;
  f: TField;
begin
	AddStack('TBrowl.OrdFldName',Self);
	result:='';
  if FindQuery then begin
    l:=ListAsArray(TBrQuery(Qry).Orders[ord-1],a,',');
    for i:=1 to l do begin
      a[i]:=StrDivDlm('.',{StrDivDlm(' ',DelTrim(a[i]))[1]}a[i],2)[2]; // {desc и} tbl.fld
      if Qry.FindField(a[i],f) then
        if f.DisplayLabel<>UnDelim then IncD(result,Trim(f.DisplayLabel)+',');
    end;
    DecLen(result);
    if Assigned(FOnOrdFldName) then FOnOrdFldName(Self,ord,result);
  end;
  DelStack;
end;

procedure TBrowl.LinkActive;
begin
	AddStack('TBrowl.LinkActive',Self);
	inherited LinkActive(Value);
  if Value then RefreshOrder;
  DelStack;
end;

procedure TBrowl.RefreshOrder;
var lOrd: boolean;
	i: longint;
begin
  AddStack('TBrowl.RefreshOrder',Self);
  if not(csDesigning in ComponentState) then begin
    if FindQuery then lOrd := TBrQuery(Qry).Orders.Count>1 else lOrd:=false;
    if lOrd then begin
      if not Assigned(PnOrd) then begin
        MnOrd:=TDefMenu.Create(Self);
        with MnOrd do begin
          FrmCaption:='Сортировка'; KeyBevel:=1; KeySpot:=2; KeyBetween:=2; FrmBorderStyle:=bsToolWindow;
        end;
        PnOrd:=TBrPanel.Create(Self.Parent);
        with PnOrd do begin
					if Parent is TRbPanel then Canvas:=TRbPanel(Parent).Canvas;
          onMouseUp:=PnOrdMouseUp; OnClick:=PaintCtlClick;
        end;
      end;
      with MnOrd,Keys do begin
        BeginUpdate; Clear;
        for i:=1 to TBrQuery(Qry).Orders.Count do InsertKey(K_OrdBeg+i-1,OrdFldName(i));
        EndUpdate; 
      end;
      OrdCapt;
    end
    else begin
      FreeAndNil(PnOrd); FreeAndNil(MnOrd);
    end;
    if Parent is TRbPanel then MsgRebuild(Self);
  end;
  DelStack;
end;

procedure TBrowl.PnOrdMouseUp;
var key: longint;
  p: TPoint;
  r: TDefMenuShow;
begin
	AddStack('TBrowl.PnOrdMouseUp',Self);
  key:=K_OrdBeg+TBrQuery(Qry).Order-1;
  r.lRect := Y<0; p:=PnOrd.ClientOrigin;
  if r.lRect
  then r.r:=Rect(p.X,p.Y,p.X+pnOrd.Width,p.Y+pnOrd.Height)
  else r.p:=Point(p.X+X,p.Y+Y);
  if MnOrd.Execute(@key,@r) then SetOrder(key-K_OrdBeg+1);
  DelStack;
end;

// Передать текст в калькулятор
procedure TBrowl.DragOver;
var i,j,h,ol,r1,p: longint;
  rw,rh: TRect;
begin
	AddStack('TBrowl.DragOver',Self);
	inherited DragOver(Source,X,Y,State,Accept);
  if Source=Self then begin
    if (State=dsDragEnter) and not lDrag then begin
    	lDrag:=true; sCalc:='';
      for i:=LeftCol to LeftCol+VisibleColCount do begin
      	if i>=FieldCount then break;
        rw:=CellRect(i,0);
      	if InRange(X,rw.Left,rw.Right) then begin
          if Y<RowHeights[0] then begin
	        	Canvas.Font.Assign(TitleFont);
	        	sCalc:=NumInStr(Fields[i].DisplayLabel,rw.Left,X,Canvas);
          end
          else begin
            Canvas.Font.Assign(Font); r1:=0;
            for j:=1 to VisibleRowCount do begin
			        rh:=CellRect(i,j);
            	if InRange(Y,rh.Top,rh.Bottom) then begin
              	ol:=0; h:=j-Row; 
              	if h<>0 then
                  if FindQuery then with Qry do begin
                  	ol:=LeftCol; DisableControls; MoveBy(h);
                  end;
                if UnDataType(Fields[i])=ftFloat then with TFloatField(Fields[i]) do begin
                  r1:=Length(DisplayFormat);
                  if IsPos(p,'.',DisplayFormat) then p:=r1-p;
                  sCalc:=MyFloatToStr(AsFloat,r1,p);
                end
                else sCalc:=TrimRight(Fields[i].AsString);
                r1:=Row+h;
                if (h<>0) and Assigned(Qry) then with Qry do begin
                	MoveBy(-h); EnableControls; LeftCol:=ol;
                end;
                h:=rw.Right-rw.Left-Canvas.TextWidth(sCalc);
                case Fields[i].Alignment of
                  taRightJustify: Inc(rw.Left,h);
                  taCenter: Inc(rw.Left,h div 2);
                end;
                break;
              end;
            end;
            if sCalc<>'' then
              if Assigned(FOnNumCalc)
              then sCalc:=FOnNumCalc(Self,sCalc,i,r1,X-rh.Left,Y-rh.Top)
              else sCalc:=NumInStr(sCalc,rw.Left,X,Canvas);
          end;
          Canvas.Font.Assign(Font); break;
        end;
      end;
    end;
    Accept := sCalc<>'';
  end;
  DelStack;
end;

procedure TBrowl.DoEndDrag;
begin
	AddStack('TBrowl.DoEndDrag',Self);
	inherited DoEndDrag(Target,X,Y);
  sCalc:=''; lDrag:=false;
  DelStack;
end;

procedure TBrowl.WMCalc;
begin
	AddStack('TBrowl.WMCalc',Self);
	inherited;
  case msg.Operation of
    clcBegin: if FindQuery then begin
      oAfterScroll:=Qry.AfterScroll; Qry.AfterScroll:=nil;
    end;
    clcEnd: if FindQuery then Qry.AfterScroll:=oAfterScroll;
    clcGet: if sCalc<>'' then begin
			msg.ps^:=Float0(sCalc); msg.result:=1;
    end;
  end;
  DelStack;
end;

function TBrowl.SelRect;
begin
	AddStack('TBrowl.SelRect',Self);
  ReplNegSelf(ALeft,Col); ReplNegSelf(ATop,Row);
  Result:=BoxRect(ALeft,ATop,ReplNeg(ARight,ALeft),ReplNeg(ABottom,ATop));
  DelStack;
end;

function TBrowl.SelPoint;
var h: longint;
	r: TRect;
  f: TField;
begin
	AddStack('TBrowl.SelPoint',Self);
	ReplNegSelf(ACol,Col); f:=GetColField(ACol); r:=CellRect(ACol,Row);
  Canvas.Font.Assign(Font); h:=r.Right-r.Left-5-CanvasMaxW(Canvas)*f.DisplayWidth;
  case f.Alignment of
    taRightJustify: Inc(r.Left,h);
    taCenter: Inc(r.Left,h div 2);
  end;
	result:=r.TopLeft; Inc(result.X); Inc(result.Y,2);
  DelStack;
end;

function TBrowl.CellRect;
begin
  AddStack('TBrowl.CellRect',Self);
  result := inherited CellRect(ACol,ARow);
  DelStack;
end;

function TBrowl.GetXField(X: longint; var i: longint): TField;
begin
  GetXField(X,i,result);
end;

function TBrowl.GetXField(X: longint; var i: longint; var f: TField): boolean;
var r: TRect;
begin
  AddStack('TBrowl.GetXField',Self);
  result:=false; i:=0;
  while i<ColCount do begin
    r:=CellRect(i,0);
    if InRange(X,r.Left,r.Right) then begin
      result:=true; f:=GetColField(i); break;
    end;
    Inc(i);
  end;
  DelStack;
end;

function TBrowl.GrayCell;
begin
	AddStack('TBrowl.GrayCell',Self);
	result:=IfThenBrGray(FOnGrayCell,Self,Rect,DataCol,Column,State);
  DelStack;
end;

procedure TBrowl.Paint;
begin
  AddStack('TBrowl.Paint',Self);
  IfThenNotify(FOnBeforePaint,Self);
  inherited Paint;
  IfThenNotify(FOnAfterPaint,Self);
  DelStack;
end;

procedure TBrowl.DrawColumnCell;
var bc,fc: TColor;
	fl: boolean;
begin
	AddStack('TBrowl.DrawColumnCell',Self);
	with Canvas do begin
    bc:=Brush.Color; fc:=Font.Color;
    fl := GrayCell(Rect,DataCol,Column,State) and ((State=[]) or (gdSelected in State));
    if fl then
      if (State=[]) or not(Focused or (dgAlwaysShowSelection in Options)) then Brush.Color:=FixedColor
      else Font.Color:=FixedColor;
    DefaultDrawColumnCell(Rect,DataCol,Column,State);
    inherited DrawColumnCell(Rect,DataCol,Column,State);
    if fl then begin
	    Brush.Color:=bc; Font.Color:=fc;
    end;
  end;
  DelStack;
end;

procedure TBrowl.AssignTo;
var b: TBrowl;
begin
	AddStack('TBrowl.AssignTo',Self);
  if IsClass(Dest,TBrowl,pointer(b)) then begin
  	b.BorderStyle:=BorderStyle; b.BorderWidth:=BorderWidth;
    b.CloseOnSelect:=CloseOnSelect; b.Color:=Color; b.DefaultDrawing:=DefaultDrawing;
    b.Enabled:=Enabled; b.FixedColor:=FixedColor; b.Font.Assign(Font); b.NmProc.Assign(NmProc);
    b.Options:=Options; b.TitleFont:=TitleFont;
    b.OnAfterEnter:=OnAfterEnter; b.OnAfterExit:=OnAfterExit; b.OnBeforePaint:=OnBeforePaint;
    b.OnBrMouseDown:=OnBrMouseDown; b.OnBrowlKey:=OnBrowlKey; b.OnClick:=OnClick;
    b.OnColEnter:=OnColEnter; b.OnColExit:=OnColExit; b.OnDblClick:=OnDblClick;
    b.OnDrawColumnCell:=OnDrawColumnCell; b.OnEnter:=OnEnter; b.OnExit:=OnExit;
    b.OnGrayCell:=OnGrayCell; b.OnKeyDown:=OnKeyDown;
    b.OnKeyPress:=OnKeyPress; b.OnKeyUp:=OnKeyUp; b.OnMouseMove:=OnMouseMove;
    b.OnMouseUp:=OnMouseUp; b.OnNumCalc:=OnNumCalc; b.OnShowHint:=OnShowHint;
    b.OnTransSeek:=OnTransSeek;
  end;
  DelStack;
end;

function TBrowl.DoMouseWheelDown;
begin
  AddStack('TBrowl.DoMouseWheelDown',Self);
  result:=inherited DoMouseWheelDown(Shift,MousePos);
  perform(WM_VSCROLL,SB_LINEDOWN,0);
  DelStack;
end;

function TBrowl.DoMouseWheelUp;
begin
  AddStack('TBrowl.DoMouseWheelUp',Self);
  result:=inherited DoMouseWheelUp(Shift,MousePos);
  perform(WM_VSCROLL,SB_LINEUP,0);
  DelStack;
end;

procedure TBrowl.WMApplHint;
begin
	AddStack('TBrowl.WMApplHint',Self);
	with Msg.Info^ do IfThenShowHint(FOnShowHint,HintStr,CanShow,HintInfo);
  DelStack;
end;

procedure TBrowl.WMBrFind;
var i: longint;
  s: string;
begin
  AddStack('TBrowl.WMBrFind',Self);
  with Msg do case Oper of
    brfindStr: with DataSource.DataSet do for i:=0 to FieldCount-1 do with Fields[i] do begin
      if Assigned(lsMemGk) and Assigned(lsMemGk^) then
        if AnsiStartsText(sMemo,FieldName) then s:=lsMemGk.GetValue(AsInteger) else continue
      else if Visible then s:=FieldAsStr(Fields[i]) else continue;
      if FindInStr(s,Str^) then begin
        result:=ByteTrue; break;
      end;
    end;
    brfindRow: result:=Row;
    brfindUpd: with Upd^ do BrUpdate(tr,v,f.FieldName);
  end;
  DelStack;
end;

function TBrowl.FindQuery;
begin
  AddStack('TBrowl.FindQuery',Self);
  Qry:=GetQuery(Self,DataSource); result:=Assigned(Qry);
  DelStack;
end;

procedure TBrowl.IncOptions;
begin
  Options:=Options+Incl-Excl;
end;

procedure TBrowl.IncLeftCol;
begin
  LeftCol:=LeftCol+d2;
end;

procedure TBrowl.PaintHead(lDown: boolean; c1,c2: ShortInt; const txt: string);
var h: longint;
  r1,r2: TRect;
begin
  AddStack('TBrowl.PaintHead',Self);
  while c1<=c2 do begin
    r1:=CellRect(c1,0);
    if r1.Right>r1.Left then break else Inc(c1);
  end;
  while c2>=c1 do begin
    r2:=CellRect(c2,0);
    if r2.Right>r2.Left then break else Dec(c2);
  end;
  if c2>=c1 then begin
    r1.Right:=r2.Right; h:=(r1.Bottom-r1.Top) div 2;
    if lDown then Inc(r1.Top,h) else Dec(r1.Bottom,h);
    Frame3D1(Canvas,r1,false); Canvas.TextRect(r1,r1.Left,r1.Top,txt);
  end;
  DelStack;
end;

function TBrowl.PaintHead(var c: ShortInt): boolean;
begin
  result:=InRange(c,0,ColCount-1);
  if result then begin
    PaintHead(true,c,c,Columns[c].Field.DisplayLabel); Inc(c);
  end;
end;

function TBrowl.bmCheckPaint(const ARect: TRect; Column: TColumn; lSet: boolean = true): boolean;
begin
  result := Column.Field is TBooleanField;
  if result then My_pr.bmCheckPaint(Canvas,ARect,Column.Field.AsBoolean=lSet);
end;

function TBrowl.bmCheckPaint(const ARect: TRect; Column: TColumn; const Fields: array of TField;
  lSet: boolean = true): boolean;
var i: longint;
begin
  result:=false;
  if Assigned(Column.Field) then for i:=low(Fields) to high(Fields) do if Column.Field=Fields[i] then begin
    result:=true; My_pr.bmCheckPaint(Canvas,ARect,StrToBoolean(Column)=lSet);
  end;
end;

function TBrowl.bmCheckPaint(const ARect: TRect; Column: TColumn; Field: TField; lSet: boolean = true): boolean;
begin
  result:=bmCheckPaint(ARect,Column,[Field],lSet);
end;

function TBrowl.bmCheckPaint(const ARect: TRect; const Fields: array of string; Column: TColumn;
  lSet: boolean = true; bm: TBitMap = nil): boolean;
begin
  if Assigned(Column.Field) then result:=AnsiMatchText(Column.FieldName,Fields) else result:=false;
  if result then My_pr.bmCheckPaint(Canvas,ARect,StrToBoolean(Column)=lSet,bm);
end;

{TCdrgLs.Browl1DrawColumnCell (TIntegerList) FieldSeek
TPfPerLs.Browl1DrawColumnCell (TIntegerList)
TDvPstLs.Browl1DrawColumnCell
TOdvChk.Browl1DrawColumnCell (TIntegerList)
TSprLs.Browl1DrawColumnCell (TIntegerList)}
function TBrowl.bmCheckPaint(const ARect: TRect; Column: TColumn; Field,FieldCode: TField; lsCode: TIntegerList;
  lSet: boolean = true): boolean;
begin
  result := Column.Field=Field;
  if result then My_pr.bmCheckPaint(Canvas,ARect,lsCode.IndexOf(Int0(FieldCode.AsString))>=0 = lSet);
end;

function TBrowl.QQs;
begin
  result:=My_pr.QQs(FieldSeek,lTrim);
end;

{function TBrowl.FieldRect;
var i: longint;
begin
  AddStack('TBrowl.FieldRect',Self);
  for i:=0 to Columns.Count-1 do
    if Columns[i].Field=f then begin
      result:=CellRect(i,ARow); break;
    end;
  DelStack;
end;

{ TCtrlBrowl }
procedure TCtrlBrowl.Assign;
begin
	AddStack('TCtrlBrowl.Assign',Self);
  if Source is TCtrlBrowl
  then onStrFind:=TCtrlBrowl(Source).onStrFind;
	inherited Assign(Source);
  DelStack;
end;

procedure TCtrlBrowl.WMRebuild;
var hm: longint;
	lr: longint;
begin
	AddStack('TCtrlBrowl.WMRebuild',Self);
  if FindQuery then begin
    hm:=msg.RbPnl.CltHeight;
    if Qry.Active then lr:=Qry.CntRec else lr:=0;
    RowCount:=1;
    while (Height<=hm-PanelHeight) and (RowCount<lr) do RowCount:=RowCount+1;
  end;
  DelStack;
end;

{ Установка цветов и шрифтов }
procedure TCtrlBrowl.WMSchem;
begin
	AddStack('TCtrlBrowl.WMSchem',Self);
	with msg.Schem do begin
   	Color:=ColorW; Font.Assign(Font1);
  end;
  DelStack;
end;

procedure TCtrlBrowl.WMBrFind;
begin
  AddStack('TCtrlBrowl.WMBrFind',Self);
  with Msg do case Oper of
    brfindStr: result:=byte(FindInStr(StrFind,Str^));
    brfindRow: result:=Row;
    brfindUpd: with Upd^ do BrUpdate(tr,v);
  end;
  DelStack;
end;

function TCtrlBrowl.Row;
var tp: TDBCtrlPanel;
begin
	AddStack('TCtrlBrowl.Row',Self);
  if ControlCount=0 then result:=1
  else begin
    tp:=pointer(Controls[0]); result:=nround(tp.Top/tp.Height)+1;
  end;
  DelStack;
end;

procedure TCtrlBrowl.DoEnter;
begin
	AddStack('TCtrlBrowl.DoEnter',Self);
	if not isCalculator then begin
    inherited DoEnter;
    if FormKeyLb(Self,FKeyPanel) then with FKeyPanel do begin
      SetKeyFind(ProcKey,'ctrlbrowl'); Redrw;
    end;
  end;
  DelStack;
end;

procedure TCtrlBrowl.DoExit;
begin
	AddStack('TCtrlBrowl.DoExit',Self);
	if not isCalculator then begin
    inherited DoExit;
    if Assigned(FKeyPanel) then begin
    //and Assigned(GetParentForm(Self).ActiveControl) then begin
      FKeyPanel.DelKey(K_ALL,'ctrlbrowl'); FKeyPanel.Redrw;
    end;
    Qry.ClearFilter(false);
  end;
  DelStack;
end;

{ Запрос на поиск }
procedure TCtrlBrowl.ProcKey;
begin
	AddStack('TCtrlBrowl.ProcKey',Self);
  WinFindKey(Key,Self,Qry.brfind,[fnoRegistr,fnoWord]+IfThen(not PswdPrm.BrFindAll,[fnoDirection,fnoAll]));
  DelStack;
end;

function TCtrlBrowl.StrFind;
begin
  AddStack('TCtrlBrowl.StrFind',Self);
	if Assigned(FOnStrFind) then result:=FOnStrFind else result:='';
  DelStack;
end;

{ Реакция на двойной щелчок }
procedure TCtrlBrowl.DblClick;
begin
	AddStack('TCtrlBrowl.DblClick',Self);
	inherited DblClick;
	if Assigned(FKeyPanel) then FKeyPanel.ExecKey(K_Enter);
  DelStack;
end;

{ Удаление с запросом
function TCtrlBrowl.DelAsk(db: TRecDB): boolean;
var ii,tr: longint;
begin
	result:=Ask(amsDel);
	if result then with TDataSet(DataSource.DataSet) do begin
    tr:=Row; DisableControls;
  	db.GotoRec(FieldByName(fRECNO)); db.DelRec;
    Next;
    if Eof then ii:=0
    else ii:=FieldByName(fRECNO).AsInteger;
    BrUpdate(tr,ii); EnableControls;
  end;
end;

{ Обновление CtrlBrowl после изменений }
procedure TCtrlBrowl.BrUpdate;
var i: longint;
  f: TField;
begin
	AddStack('TCtrlBrowl.BrUpdate',Self);
	if FindQuery then with Qry do begin
    SetRedraw(Self); ReOpen; 
    if ii=0 then Self.Last
    else begin
      f:=FindField(fRECNO);
      while not(Eof or (f.AsInteger=ii)) do Self.Next;
    end;
    if Row<>tr then begin
      ii:=Row-tr;
      for i:=1 to ii do begin
      	Self.Next;
        if Eof then begin
        	ii:=i-1; break;
        end;
      end;
      for i:=1 to ii do Self.Prior;
    end;
    SetRedraw(Self,rdrwSet);
  end;
  DelStack;
end;

procedure TCtrlBrowl.First;
begin
	AddStack('TCtrlBrowl.First',Self);
	if FindQuery then Qry.First;
  DelStack;
end;

procedure TCtrlBrowl.Last;
begin
	AddStack('TCtrlBrowl.Last',Self);
	if FindQuery then Qry.Last;
  DelStack;
end;

procedure TCtrlBrowl.Next;
begin
	AddStack('TCtrlBrowl.Next',Self);
	if FindQuery then Qry.Next;
  DelStack;
end;

procedure TCtrlBrowl.Prior;
begin
	AddStack('TCtrlBrowl.Prior',Self);
	if FindQuery then Qry.Prior;
  DelStack;
end;

function TCtrlBrowl.FindQuery;
begin
  AddStack('TCtrlBrowl.FindQuery',Self);
  Qry:=GetQuery(Self,DataSource); result:=Assigned(Qry);
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurLib',[TBrowl,TCtrlBrowl]);
end;

{ TUsPrmLogCompare }

class function TUsPrmLogCompare.ListCreate;
var a: PArrStr;
  l: longint;
  f: TField;
begin
  AddStack('TUsPrmLogCompare.ListCreate');
  with PBrowlLogRec(pv)^ do begin
    result:=ListCreateDlm(Value,aUsPrmDlm[op]); a:=result;
    case op of
      blogBase: begin
        l:=Length(a^);
        if l<2 then begin
          SetLength(a^,2); InitArr(a^,l);
        end;
      end;
      blogColumn: begin
        l:=0;
        while l<Length(a^) do begin
          if br.Qry.FindField(a^[l],f) then
            if f.Visible then begin
              Inc(l); continue;
            end;
          ArrDel(a^,l);
        end;
      end;
    end;
  end;
  DelStack;
end;

class function TUsPrmLogCompare.GetCount;
begin
  AddStack('TUsPrmLogCompare.GetCount');
  case PBrowlLogRec(pv).op of
    blogBase: result:=1;
    blogColumn: result:=inherited GetCount(pv,ls);
  else result:=0; // Return value of function might be undefined
  end;
  DelStack;
end;

function LogCompareStrOrder(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var ord: longint;
begin
  AddStack('Browl.LogCompareStrOrder');
  result:=PArrStr(p)^[1]; ord:=Int0(result);
  with PBrowlLogRec(pv).br do if Qry is TBrQuery then
    if InRange(ord,1,TBrQuery(Qry).Orders.Count) then result:=OrdFldName(ord);
  DelStack;
end;

class procedure TUsPrmLogCompare.GetItem;
var r: PBrowlLogRec;
  ao,an: PArrStr;
  f: TField;
begin
  AddStack('TUsPrmLogCompare.GetItem');
  r:=pv;
  case r.op of
    blogBase: if tp<>clogKey then begin
      an:=lsn;
      if tp=clogNoKey then Prm.val:=ArrayAsList(an^,aUsPrmDlm[blogBase])
      else begin
        ao:=lso;
        r.op:=blogColumn; AddRes(Prm,ao^[0],an^[0],r,'столбцы'); r.op:=blogBase;
        TStrLogCompare.AddRes(LogCompareStrOrder,Prm,ao,an,r,'сортировка');
      end;
    end;
    blogColumn: begin
      inherited GetItem(Prm,pv,lso,lsn,no,nn,tp);
      if (tp=clogPrn) and not empty(Prm.val) then
        if r.br.Qry.FindField(Prm.val,f) then Prm.val:=f.DisplayLabel;
    end;
  end;
  DelStack;
end;

end.
