unit ChkGets;

interface

{$I LIBTEST}
uses
  Windows,Messages,Classes,Graphics,Controls,Grids,
  MyTypes,RecVal,StrBrowl,FFldedit,PaintCtl;

type
	TCheckSpaceStyle = (csCheck,csRadio);

	TCheckSpace = class(TPaintControl)
  private
  	FAlignment: TAlignment;
  	FArrBool: TByteSet;
    FBevelOuter: TBevelCut;
    Style: TCheckSpaceStyle;
		function GetArrBool(Index: longint): boolean;
    procedure SetAlignment(Value: TAlignment);
		procedure SetArrBool(Index: longint; Value: boolean);
		procedure SetBevelOuter(Value: TBevelCut);
    function MinWidth: longint;
    function MinHeight: longint;
    property Alignment: TAlignment read FAlignment write SetAlignment;
  	property AsLabel: boolean index 1 read GetArrBool write SetArrBool;
  	property BevelOuter: TBevelCut read FBevelOuter write SetBevelOuter;
  	property Checked: boolean index 2 read GetArrBool write SetArrBool;
  	property Grayed: boolean index 3 read GetArrBool write SetArrBool;
  protected
		procedure FPaint; override;
  public
		constructor Create(AOwner: TComponent); override;
    procedure CheckedNot;
    class function GetButEnabled(tf: TFldEdit; Index: longint): boolean;
    class procedure SetButEnabled(tf: TFldEdit; Index: longint; Enabled: boolean); overload;
    class procedure SetButEnabled(tf: TFldEdit; const Index: array of longint; Enabled: boolean); overload;
  end;

	TChkPictPlace = (ppLeft,ppRight,ppTop,ppBottom);

  TBoolGetPrm = record
		lAlignLeft,lAsLabel: boolean;
		Caption: string;
  end;

	TBoolGet = class(TCustomGet)
	private
   	{ Private declarations }
 		procedure ProcKey(key: longint; tw: TWinControl);
		procedure tcClick(Sender: TObject);
    class function GetPrm(const Mask: string): TBoolGetPrm;
		class function tcCaption(const m: string): string; virtual;
	protected
   	{ Protected declarations }
   	tc: TCheckSpace;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    function GetValue(tf: TFldEdit): string ; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function AssignObj(tf: TFldEdit): boolean; override;
		function DWFldUnAllowType(const Mask: string): TDWFldSetType; override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
	public
   	{ Public declarations }
		constructor Create(AOwner: TComponent); override;
		procedure MaskPrn(const Mask: string; LsPrn: TStringList); override;
		procedure StdDWFldInfo(const Mask: string; var FldInfo: TDWFldInfo); override;
		procedure StdDWFldValue(r: TCustomRec; const Mask: string; var Value: variant); override;
  	class function DDatSupport: boolean; override;
  	procedure LogCompare(tf: TFldEdit; var Prm: TLogTrnsValPrm); override;
  published
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
	end;

	TBoolDrwGet = class(TBoolGet)
  private
  	DimBM: array[boolean] of TBitMap;
  	FDimPict: array[1..2] of string;
    function GetDimPict(Index: longint): string;
    procedure SetDimPict(Index: longint; const Value: string);
    function BMSize(fl: boolean): TSize;
		class function tcCaption(const m: string): string; override;
  protected
    PictPlace: TChkPictPlace;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    procedure Paint(tf: TFldEdit); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
	public
   	{ Public declarations }
		constructor Create(AOwner: TComponent); override;
		procedure Assign(Source: TPersistent); override;
	published
   	{ Published declarations }
    property PictFalse: string index 1 read GetDimPict write SetDimPict;
    property PictTrue: string index 2 read GetDimPict write SetDimPict;
		{ Унаследованные }
   	property RVid;
   	property RVName;
    property VName;
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

  TBoolMultiGetPrm = record
		lAlignLeft: boolean;
		aCaption: TArrStr;
  end;

  TBoolMultiGet = class(TCustomGet)
  private
    { Private declarations }
 		procedure ProcKey(key: longint; tw: TWinControl);
		procedure BoolNewCol(tf: TFldEdit; var a: TArrInt; lAllHeight: boolean);
		procedure tcClick(Sender: TObject);
  protected
    { Protected declarations }
		procedure CreateObj(tf: TFldEdit); override;
		procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function MayDoKey(tf: TFldEdit; Key: longint): boolean; override;
		procedure HookProc(tf: TFldEdit; var Message: TMessage); override;
    procedure Paint(tf: TFldEdit); override;
		function DWFldUnAllowType(const Mask: string): TDWFldSetType; override;
    class procedure FMaskView(var Mask: string); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
  public
    { Public declarations }
		constructor Create(AOwner: TComponent); override;
		procedure MaskPrn(const Mask: string; LsPrn: TStringList); override;
		procedure StdDWFldInfo(const Mask: string; var FldInfo: TDWFldInfo); override;
		procedure StdDWFldValue(r: TCustomRec; const Mask: string; var Value: variant); override;
		procedure DWFldValid(const ap: TDEPrmStr; const dwInf: TDWVidRec;
    	var nFldFocus: TDEPrmList; var nVarFocus: TVarParam; var amsg: TArrStr); override;
		class procedure ItemReadOnly(tf: TFldEdit; Index: longint; Value: boolean);
  	class function DDatSupport: boolean; override;
  	procedure LogCompare(tf: TFldEdit; var Prm: TLogTrnsValPrm); override;
    class function GetPrm(const Mask: string): TBoolMultiGetPrm; virtual;
  published
    { Published declarations }
   	property RVid;
    property RVName;
    property VName;
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

  TRGList = (rgName,rgPict);
	TRGStr = array[TRGList] of string;

  TRadioGetPrm = record
    PictPlace: TChkPictPlace;
    sItems: string;
    nBeg: longint;
    Arrange: TRGArrangeList;
  end;

  TRadioGet = class(TCustomGet)
  private
    { Private declarations }
    FItems,WorkItems: TStringList;
    flObj: boolean;
		procedure SetItems(Value: TStringList);
    procedure ItemsChange(Sender: TObject);
		procedure ProcKey(key: longint; tw: TWinControl);
		function GetRec(i: longint; ls: TStringList = nil): TRGStr;
		procedure SetPrm(const Mask: string);
		procedure tcClick(Sender: TObject);
		function ValToNum(const v: variant): longint;
		function NumToVal(n: longint): string;
    procedure RadioCheckWH(tf: TFldEdit; var w,h: longint);
  protected
    { Protected declarations }
    Prm: TRadioGetPrm;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
		procedure Paint(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function MayDoKey(tf: TFldEdit; Key: longint): boolean; override;
    function AssignObj(tf: TFldEdit): boolean; override;
		function DWFldUnAllowType(const Mask: string): TDWFldSetType; override;
		procedure HookProc(tf: TFldEdit; var Message: TMessage); override;
  	class function MaskSortMode: TSortMode; override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
  public
    { Public declarations }
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
		function RadioName(Index: longint; tf: TFldEdit = nil): string;
    procedure Assign(Source: TPersistent); override;
		procedure MaskPrn(const Mask: string; LsPrn: TStringList); override;
		procedure StdDWFldInfo(const Mask: string; var FldInfo: TDWFldInfo); override;
		procedure StdDWFldValue(r: TCustomRec; const Mask: string; var Value: variant); override;
		procedure DWFldValid(const ap: TDEPrmStr; const dwInf: TDWVidRec;
    	var nFldFocus: TDEPrmList; var nVarFocus: TVarParam; var amsg: TArrStr); override;
    procedure LogEnumVal(var Prm: TLogTrnsValPrm);
  	class function DDatSupport: boolean; override;
    class function RGPrm(const m: string): TRadioGetPrm;
//		class function MaskTextReadOnly: boolean; override;
  published
    { Published declarations }
    property Items: TStringList read FItems write SetItems;
	  { Унаследованные }
   	property RVid;
   	property RVName;
   	property VName;
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

  TTblChkGetArr = record
    a: TArrStr;
    l: longint;
  end;
  TTblChkGetPrm = record
    Capt: string;
    aCol,aRow: TTblChkGetArr;
    Col1: boolean;
  end;

  TTblChkGet = class(TCustomGet)
  private
    { Private declarations }
    noCng: boolean;
    class procedure tblHeadWHCalc(Sender: TObject);
  protected
    { Protected declarations }
    tbl: TStrTable;
		procedure CreateObj(tf: TFldEdit); override;
		procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function MayDoKey(tf: TFldEdit; Key: longint): boolean; override;
    function AssignObj(tf: TFldEdit): boolean; override;
    //procedure HookProc(tf: TFldEdit; var Message: TMessage); override;
    procedure Change(tf: TFldEdit; const OldVal: variant; FromShow: boolean); override;
		function DWFldUnAllowType(const Mask: string): TDWFldSetType; override;
    procedure MaskFrmShow(Sender: TObject); override;
    class procedure FMaskView(var Mask: string); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
    class procedure tblDrawCell(Sender: TObject; ACol,ARow: longint;
      Rect: TRect; State: TGridDrawState); virtual;
		class procedure ProcKey(key: longint; tw: TWinControl); virtual;
		class function GetCodY(n: longint): longint; virtual;
  public
    { Public declarations }
		constructor Create(AOwner: TComponent); override;
		procedure MaskPrn(const Mask: string; LsPrn: TStringList); override;
    class function MaskTextReadOnly: boolean; override;
  	class function DDatSupport: boolean; override;
		procedure StdDWFldValue(r: TCustomRec; const Mask: string; var Value: variant); override;
		procedure DWFldValid(const ap: TDEPrmStr; const dwInf: TDWVidRec;
    	var nFldFocus: TDEPrmList; var nVarFocus: TVarParam; var amsg: TArrStr); override;
    class function Mask2Prm(const Mask: string): TTblChkGetPrm;
  published
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

const TblChkDlmVal = '/'; lTblChkDlmVal = Length(TblChkDlmVal);

procedure Register;

implementation

uses SysUtils,Forms,ExtCtrls,DB,Math,Variants,StrUtils,
  My_pr,Schem,KeyLb,KeyMenu,ButGet,FPanel,MultiGet,MemoGet;

type TChkPictPlaceStr = array[TChkPictPlace] of string;

  TTblChkHeadMultiGet = class(TMultiGet)
  protected
    procedure PlaceControls(tf: TFldEdit; Condens: boolean); override;
  public
		constructor Create(AOwner: TComponent); override;
  end;

  TTblChkHeadGet = class(TMemoGet)
  protected
    function MayDoKey(tf: TFldEdit; Key: longint): boolean; override;
  public
		constructor Create(AOwner: TComponent); override;
  end;

  TNone = class
  private
    class procedure tblBeforeDrawCell(Sender: TObject; ACol,ARow: longint;
      Rect: TRect; State: TGridDrawState);
  end;

const
  iX = 3;
  iX2 = iX shl 1;

	amsi: array[TChkPictPlace] of byte = (1,2,3,4);
	aims: array[1..4] of TChkPictPlace = (ppLeft,ppRight,ppTop,ppBottom);
	ams: array[TChkPictPlace] of char = (cppLeft,cppRight,cppTop,cppBottom);
	aChkPictPlace: TChkPictPlaceStr = ('слева','справа','сверху','снизу');
  aArrangeNm: array[TRGArrangeList] of string = ('по колонкам','по строкам');

var BoolMultiDDat: boolean;

function MaskPlace(const m: string): TChkPictPlace;
var i: longint;
  a: TNamePrimStr;
begin
	AddStack('ChkGets.MaskPlace');
  result:=ppBottom;
  if StrDivDlm(cChkPictPlace,m,a,true) then
    if AnsiFindChar(a[2],ams,i) then result:=TChkPictPlace(i);
  DelStack;
end;

function GetChkActive(tf: TFldEdit): longint;
var i: longint;
  tc: TCheckSpace;
begin
  AddStack('ChkGets.GetChkActive');
  result:=0;
  for i:=0 to tf.ComponentCount-1 do if IsClass(tf.Components[i],TCheckSpace,pointer(tc)) then
    if tc.FBevelOuter<>bvNone then begin
      result:=i; break;
    end;
  DelStack;
end;

procedure SetChkActive(tf: TFldEdit; Value: longint = NegDef);
var i: longint;
  tc: TCheckSpace;
begin
	AddStack('ChkGets.SetChkActive');
  for i:=0 to tf.ComponentCount-1 do
    if IsClass(tf.Components[i],TCheckSpace,pointer(tc))
    then tc.BevelOuter:=IfThen((i=Value) and not Assigned(tf.curget.bDyn),bvRaised);
  DelStack;
end;

function ChkNext(tf: TFldEdit; Index: longint = NegDef): longint;
var i: longint;
  tc: TCheckSpace;
begin
	AddStack('ChkGets.ChkNext');
	result:=-1;
  for i:=max(0,Index+1) to tf.ComponentCount-1 do if IsClass(tf.Components[i],TCheckSpace,pointer(tc)) then
    if tc.Enabled and (not tc.Grayed or (ogReadOnly in tf.Options)) then begin
      result:=i; break;
    end;
  DelStack;
end;

function ChkActNext(tf: TFldEdit): longint;
begin
  result:=ChkNext(tf,GetChkActive(tf));
end;

// Поиск предыдущей кнопки
function ChkPrior(tf: TFldEdit; Index: longint): longint;
var i: longint;
  tc: TCheckSpace;
begin
	AddStack('ChkGets.ChkPrior');
	result:=-1;
  for i:=min(tf.ComponentCount,Index)-1 downto 0 do if IsClass(tf.Components[i],TCheckSpace,pointer(tc)) then
    if tc.Enabled and not tc.Grayed then begin
      result:=i; break;
    end;
  DelStack;
end;

function ChkActPrior(tf: TFldEdit): longint;
begin
  result:=ChkPrior(tf,GetChkActive(tf));
end;

// Поиск кнопок с указанным номером
type TArrTCheckSpace = array of TCheckSpace;

function SeekButs(tf: TFldEdit; Index: longint; var a: TArrTCheckSpace): longint;
var i,j: longint;
  g: TCustomGet;
begin
	AddStack('ChkGets.SeekButs');
	result:=0; NameGet(g,tf);
  if (g is TRadioGet) or (g is TBoolMultiGet) then with tf do begin
    j:=1; i:=ComponentCount; SetLength(a,i);
    for i:=0 to i-1 do if IsClass(Components[i],TCheckSpace,pointer(a[result])) then begin
      if (Index=0) or (Index=j) then Inc(result);
      Inc(j);
    end;
  end;
  DelStack;
end;

{ TCheckSpace }
constructor TCheckSpace.Create;
begin
	AddStack('TCheckSpace.Create',Self);
	inherited Create(AOwner);
  FAlignment:=taRightJustify; Style:=csCheck; FBevelOuter:=bvLowered;
  DelStack;
end;

procedure TCheckSpace.SetAlignment;
begin
	AddStack('TCheckSpace.SetAlignment',Self);
  if FAlignment<>Value then begin
  	FAlignment:=Value; Paint;
  end;
  DelStack;
end;

function TCheckSpace.GetArrBool;
begin
  AddStack('TCheckSpace.GetArrBool',Self);
  result := IfThen((Index=3) and not Enabled, true, Index in FArrBool);
  DelStack;
end;

procedure TCheckSpace.SetArrBool;
begin
  AddStack('TCheckSpace.SetArrBool',Self);
  if Value <> (Index in FArrBool) then begin
  	SetSet(FArrBool,Index,Value); Paint;
  end;
  DelStack;
end;

procedure TCheckSpace.SetBevelOuter;
begin
	AddStack('TCheckSpace.SetBevelOuter',Self);
  if FBevelOuter<>Value then begin
  	FBevelOuter:=Value; Paint;
  end;
  DelStack;
end;

procedure TCheckSpace.FPaint;
const aDrawState: array[TCheckSpaceStyle] of longint = (DFCS_BUTTONCHECK,DFCS_BUTTONRADIO);
var r: TRect;
begin
	AddStack('TCheckSpace.FPaint',Self);
  if AsLabel or (FBevelOuter=bvNone) then begin
  	Canvas.Brush.Color:=TPanel(Owner).Color; Canvas.FillRect(Bounds);
  end
  else begin
  	r:=Bounds; Frame3D1(Canvas,r,FBevelOuter=bvLowered);
  end;
  Canvas.Font.Assign(TPanel(Owner).Font);
  with Bounds do DrawCaption(Rect(Left+IfThen(FAlignment=taRightJustify,CheckSize.cX+iX2,iX),
  	Top,IfThen(FAlignment=taRightJustify,Right-iX,Left+iX+Canvas.TextWidth(Caption)),Bottom),
    taLeftJustify,taCenter,TPanel(Owner).Font);
  if not AsLabel then begin
    r.Top:=Bounds.Top+(Bounds.Bottom-Bounds.Top-CheckSize.cY) div 2;
    //r.Left:=IfThen(FAlignment=taRightJustify,Bounds.Left+iX,Bounds.Right-Bounds.Left-iX-CheckSize.cX);
    r.Left:=IfThen(FAlignment=taRightJustify,Bounds.Left+iX,Bounds.Right-iX-CheckSize.cX);
    r.Right:=r.Left+CheckSize.cX; r.Bottom:=r.Top+CheckSize.cY;
    DrawFrameControl(Canvas.Handle,r,DFC_BUTTON,
      aDrawState[Style] or IfThen(Grayed,DFCS_INACTIVE) or IfThen(Checked,DFCS_CHECKED));
  end;
  DelStack;
end;

function TCheckSpace.MinWidth;
begin
	AddStack('TCheckSpace.MinWidth',Self);
  result:=CheckSize.cX+iX2;
  if Assigned(Canvas) and (Caption<>'') then begin
    Canvas.Font.Assign(TPanel(Owner).Font); Inc(result,iX+MinSize.cx);
  end;
  DelStack;
end;

function TCheckSpace.MinHeight;
begin
	AddStack('TCheckSpace.MinHeight',Self);
  result:=CheckSize.cY;
  if Assigned(Canvas) then begin
	  Canvas.Font.Assign(TPanel(Owner).Font); MaxSelf(result,MinSize.cy);
  end;
  DelStack;
end;

procedure TCheckSpace.CheckedNot;
begin
  AddStack('TCheckSpace.CheckedNot');
  Checked:=not Checked;
  DelStack;
end;

class function TCheckSpace.GetButEnabled;
var a: TArrTCheckSpace;
begin
	AddStack('TCheckSpace.GetButEnabled');
  if SeekButs(tf,Index,a)=0 then result:=false else result:=a[0].Enabled;
  DelStack;
end;

class procedure TCheckSpace.SetButEnabled(tf: TFldEdit; Index: longint; Enabled: boolean);
begin
	SetButEnabled(tf,[Index],Enabled);
end;

class procedure TCheckSpace.SetButEnabled(tf: TFldEdit; const Index: array of longint; Enabled: boolean);
var a: TArrTCheckSpace;
  i,j: longint;
begin
	AddStack('TCheckSpace.SetButEnabled');
  for i:=low(Index) to high(Index) do
    for j:=0 to SeekButs(tf,Index[i],a)-1 do a[j].Enabled:=Enabled;
  tf.ValueRepeat; tf.PaintObj;
  DelStack;
end;

{ TBoolGet }
constructor TBoolGet.Create;
begin
	AddStack('TBoolGet.Create',Self);
	Inherited Create(AOwner);
  RVid:='Логический';
  UpdateAllFld(mgCreate);
  DelStack;
end;

{ Создание объектов }
procedure TBoolGet.CreateObj;
begin
	AddStack('TBoolGet.CreateObj',Self);
	DestroyObj(tf); tf.DynButCreate;
	tc:=TCheckSpace.Create(tf);
  with tc do begin
    Canvas:=tf.Canvas; onClick:=tcClick;
  end;
  inherited CreateObj(tf);
  DelStack;
end;

{ Переустановить свойства объектов }
procedure TBoolGet.ReCreateObj;
var p: TBoolGetPrm;
begin
	AddStack('TBoolGet.ReCreateObj',Self);
	if AssignObj(tf) then with tf do begin
    p:=GetPrm(Mask);
    tc.Visible := not tf.NoPaintObj;
    tc.Caption:=p.Caption;
   	tc.Alignment:=iif(p.lAlignLeft,taLeftJustify,taRightJustify); tc.AsLabel:=p.lAsLabel;
    tc.Grayed := ogReadOnly in tf.Options;
    inherited ReCreateObj(tf);
    tf.Refresh;
  end;
  DelStack;
end;

class function TBoolGet.GetPrm;
begin
  AddStack('TBoolGet.GetPrm');
  with result do begin
    lAlignLeft := (Pos(cBoolLeft,Mask)>0) or (Pos(AnsiLowerCase(cBoolLeft),Mask)>0);
    lAsLabel := (Pos(cBoolSay,Mask)>0) or (Pos(AnsiLowerCase(cBoolSay),Mask)>0);
    Caption:=tcCaption(Mask);
  end;
  DelStack;
end;

class function TBoolGet.tcCaption;
begin
	AddStack('TBoolGet.tcCaption');
  result:=StrTran(m,[cBoolLeft,cBoolSay],['',''],[rfReplaceAll,rfIgnoreCase]);
  DelStack;
end;

{ Нарисовать объекты }
procedure TBoolGet.PaintObj;
var ts: TSchem;
  w,wc,h: longint;
begin
	AddStack('TBoolGet.PaintObj',Self);
	if AssignObj(tf) then begin
    if csDesigning in ComponentState then ts:=nil else SchemName(tf.Schem,ts);
    if Assigned(ts) then tf.Font.Assign(ts.Font2);
    with tf do begin
      w:=DynButSize.cX; h:=Height-BevelFld2;
      if Assigned(bDyn) then bDyn.SetBounds(Width-BevelFld-w,BevelFld,w,h);
      wc:=tf.DynCaptSize(h).cX; tc.SetBounds(BevelFld+wc,BevelFld,Width-BevelFld2-w-wc,h);
    end;
  end;
  DelStack;
end;

{ Автоматическая установка размеров }
function TBoolGet.SizeAuto;
var dsz,dcsz: TSize;
  h: longint;
begin
	AddStack('TBoolGet.SizeAuto',Self);
	result := inherited SizeAuto(tf,Opt);
	if AssignObj(tf) then begin
    if Opt<>[] then begin
      dsz:=DynButSize; h:=max(tc.MinHeight+4,dsz.cY); dcsz:=tf.DynCaptSize(h);
      if tfszHeight in Opt then result.cY:=max(h,dcsz.cY);
      if tfszWidth in Opt then result.cX:=tc.MinWidth+2+dsz.cX+dcsz.cX;
    end;
  end;
  DelStack;
end;

function BGIsNum(tf: TFldEdit): boolean;
begin
  AddStack('ChkGets.BGIsNum');
  if Assigned(tf.PNameRecFld)
  then result := UnDataType(tf.PNameRecFld) in [ftInteger,ftFloat]
  else result:=false;
  DelStack;
end;

function BGBool2Str(tf: TFldEdit; Value: boolean): string;
begin
  AddStack('ChkGets.BGBool2Str');
  if BGIsNum(tf) then result:=IfThen(Value,'1') else result:=bStr[Value];
  DelStack;
end;

function BGStr2Bool(tf: TFldEdit; const Value: string): boolean;
begin
  AddStack('ChkGets.BGStr2Bool');
  if BGIsNum(tf) then result:=not empty(Int0(Value)) else result:=StrToBoolean(Value);
  DelStack;
end;

{ Достать значение Value из объектов }
function TBoolGet.GetValue;
var fl: boolean;
begin
	AddStack('TBoolGet.GetValue',Self);
	if AssignObj(tf) then fl:=tc.Checked else fl:=false;
	result:=BGBool2Str(tf,fl);
  DelStack;
end;

{ Установить свойства объектов в соответствии с Value }
procedure TBoolGet.SetValue;
begin
	AddStack('TBoolGet.SetValue',Self);
	if AssignObj(tf) then tc.Checked:=BGStr2Bool(tf,v);
  DelStack;
end;

{ Действия при получении фокуса }
procedure TBoolGet.DoEnter;
var tl: TKeyLb;
	MainMn: TKeyMenu;
begin
	AddStack('TBoolGet.DoEnter',Self);
  inherited DoEnter(tf);
  if FormKeyLb(tf,tl) and not((ogReadOnly in tf.Options) or Assigned(bDyn)) then with tl do begin
   	SetKeys([K_Space,K_Ins,K_Left,K_Right],'Отметка','',ProcKey,'boolget',kmEdit); ReDrw;
    if SeekKeyMenu(tf,MainMn) then MainMn.InsLine(kmEdit,K_Space);
  end;
  DelStack;
end;

{ Действия при утере фокуса }
procedure TBoolGet.DoExit;
var tl: TKeyLb;
	MainMn: TKeyMenu;
begin
	AddStack('TBoolGet.DoExit',Self);
  if SeekKeyMenu(tf,MainMn) then MainMn.DelLine(kmEdit,K_Space);
  if FormKeyLb(tf,tl) then begin
  //and Assigned(GetParentForm(tf).ActiveControl) then begin
   	tl.DelKey(K_All,'boolget'); tl.ReDrw;
  end;
  inherited DoExit(tf);
  DelStack;
end;

procedure TBoolGet.ProcKey;
var tl: TKeyLb;
begin
	AddStack('TBoolGet.ProcKey',Self);
  if AssignObj(pointer(tw)) then begin
    tc.Click;
    if Key=K_Ins then
      if FormKeyLb(tw,tl) then tl.ExecKey(K_Down);
  end;
  DelStack;
end;

procedure TBoolGet.tcClick;
var tf: TFldEdit;
begin
	AddStack('TBoolGet.tcClick',Self);
	tf:=pointer(TCheckSpace(Sender).Owner);
  if not tf.Active then tf.SetFocus;
  if not (ogReadOnly in tf.Options) then
	  if AssignObj(tf) then
      if not Assigned(bDyn) then begin
        tf.Value:=BGBool2Str(tf,not tc.Checked); tf.EdClick(tf);
      end;
  DelStack;
end;

{ Поиск объектов }
function TBoolGet.AssignObj;
var n: byte;
begin
	AddStack('TBoolGet.AssignObj',Self);
	tc:=nil; result:=false;
  if inherited AssignObj(tf) then begin
    n:=IfThen(Assigned(bDyn),1);
		if tf.ComponentCount>n then result:=IsClass(tf.Components[n],TCheckSpace,pointer(tc));
  end;
  DelStack;
end;

procedure TBoolGet.StdDWFldInfo;
var capt: string;
begin
	AddStack('TBoolGet.StdDWFldInfo',Self);
  if FldInfo.DisplayLabel='' then begin
    capt:=tcCaption(Mask);
    if capt<>'' then FldInfo.DisplayLabel:=capt;
  end;
  FldInfo.Size:=3; FldInfo.Alignment:=taCenter;
  DelStack;
end;

procedure TBoolGet.StdDWFldValue;
var fl: boolean;
begin
	AddStack('TBoolGet.StdDWFldValue',Self);
  if MyVarType(Value,true)=varDouble then fl:=not empty(Value) else fl:=StrToBoolean(Value);
  Value:=bRus[fl];
  DelStack;
end;

function TBoolGet.DWFldUnAllowType;
begin
  result:=[dwtArray,dwtSel];
end;

function TBoolGet.MaskTrans;
begin
	AddStack('TBoolGet.MaskTrans');
	if MyVarType(av)=varArray then result:=Trim(IsNilc(av[1],''))
    +IfThen(IsNilc(av[2],false),cBoolLeft)+IfThen(IsNilc(av[3],false),cBoolSay)
  else with GetPrm(av) do result:=ArrVarToVar([Caption,lAlignLeft,lAsLabel]);
  DelStack;
end;

procedure TBoolGet.MaskPrn;
var p: TBoolGetPrm;
begin
	AddStack('TBoolGet.MaskPrn',Self);
  p:=GetPrm(Mask);
  if not empty(p.Caption) then LsPrn.Add('Подсказка: '+p.Caption);
  if p.lAlignLeft then LsPrn.Add('Подсказка слева');
  if p.lAsLabel then LsPrn.Add('Без ввода');
  DelStack;
end;

procedure TBoolGet.FMaskHelp;
var n: byte;
begin
  AddStack('TBoolGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+4);
  Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr('«Подсказка»')+'+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpIf('«Подсказка слева»','"'+cBoolLeft+'"','""')+'+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpIf('«Без ввода»','"'+cBoolSay+'"','""'));
  DelStack;
end;

class function TBoolGet.DDatSupport;
begin
  result:=true;
end;

procedure TBoolGet.LogCompare;
var s: string;
begin
  AddStack('TBoolGet.LogCompare',Self);
  s:=GetPrm(tf.Mask).Caption;
  if not empty(s) then Prm.nm:=FLow(s);
  inherited LogCompare(tf,Prm);
  DelStack;
end;

{ TBoolDrwGet }
constructor TBoolDrwGet.Create;
begin
	AddStack('TBoolDrwGet.Create',Self);
	Inherited Create(AOwner);
  RVid:='';
  UpdateAllFld(mgCreate);
  DelStack;
end;

function TBoolDrwGet.GetDimPict;
begin
	AddStack('TBoolDrwGet.GetDimPict',Self);
	result:=FDimPict[Index];
  DelStack;
end;

procedure TBoolDrwGet.SetDimPict;
begin
	AddStack('TBoolDrwGet.SetDimPict',Self);
	if Value<>FDimPict[Index] then begin
    FDimPict[Index]:=Value; 
    TInitBM.Init(Application.MainForm); InitBM.FindBM(Value,DimBM[Index=2]);
    UpdateAllFld(mgReCreate);
  end;
  DelStack;
end;

{ Создание объектов }
procedure TBoolDrwGet.CreateObj;
begin
	AddStack('TBoolDrwGet.CreateObj',Self);
  inherited CreateObj(tf);
  if inherited AssignObj(tf) then begin
		tc.BevelOuter:=bvNone; tf.ReCreateObj;
  end;
  DelStack;
end;

{ Переустановить свойства объектов }
procedure TBoolDrwGet.ReCreateObj;
begin
	AddStack('TBoolDrwGet.ReCreateObj',Self);
	if AssignObj(tf) then begin
    PictPlace:=MaskPlace(tf.Mask);
    inherited ReCreateObj(tf);
  end;
  DelStack;
end;

class function TBoolDrwGet.tcCaption;
var i: TChkPictPlace;
  vs,vr: TChkPictPlaceStr;
begin
	AddStack('TBoolDrwGet.tcCaption');
	result := inherited tcCaption(m);
  for i:=low(ams) to high(ams) do begin
    vs[i]:=cChkPictPlace+ams[i]; vr[i]:='';
  end;
  StrTranSelf(result,vs,vr,[rfReplaceAll,rfIgnoreCase]);
  DelStack;
end;

{ Нарисовать объекты }
procedure TBoolDrwGet.PaintObj;
var ts: TSchem;
begin
	AddStack('TBoolDrwGet.PaintObj',Self);
	if AssignObj(tf) then with tf do begin
    tc.Grayed := ogReadOnly in tf.Options;
    if csDesigning in ComponentState then ts:=nil else SchemName(Schem,ts);
    if Assigned(ts) then tf.Font.Assign(ts.Font2);
  	Canvas.Font.Assign(Font);
    if tc.AsLabel and (tc.Caption='') then tc.SetBounds(0,0,0,0)
    else case PictPlace of
    	ppLeft: tc.SetBounds(tf.Width-BevelFld-2-tc.MinWidth,
      	(tf.Height-tc.MinHeight-2) div 2,tc.MinWidth,tc.MinHeight+2);
    	ppRight: tc.SetBounds(2+BevelFld,(tf.Height-tc.MinHeight-2) div 2,
      	tc.MinWidth,tc.MinHeight+2);
    	ppTop: tc.SetBounds((tf.Width-tc.MinWidth) div 2,
      	tf.Height-BevelFld-4-tc.MinHeight,tc.MinWidth,tc.MinHeight+2);
    	ppBottom: tc.SetBounds((tf.Width-tc.MinWidth) div 2,2+BevelFld,
      	tc.MinWidth,tc.MinHeight+2);
    end;
  end;
  DelStack;
end;

procedure TBoolDrwGet.Paint;
var r: TRect;
	l: boolean;
  sz: TSize;
begin
	AddStack('TBoolDrwGet.Paint',Self);
  if AssignObj(tf) then with tf do begin
    r:=Rect(BevelFld,BevelFld,Width-BevelFld,Height-BevelFld); l:=BGStr2Bool(tf,Value); sz:=BMSize(l);
    Frame3D1(Canvas,r);
    if tc.AsLabel and (tc.Caption='')
    then OffsetRect(r,(r.Right-r.Left-sz.cx) div 2,(r.Bottom-r.Top-sz.cx) div 2)
    else begin
      case PictPlace of
        ppLeft: r.TopLeft:=Point(2+(tc.Bounds.Left-2-sz.cX) div 2,(tf.Height-sz.cY) div 2);
        ppRight: with tc.Bounds do r.TopLeft:=Point(
          Right+(tf.Width-BevelFld-4-(Right-Left)-sz.cX) div 2,(tf.Height-sz.cY) div 2);
        ppTop: r.TopLeft:=Point((tf.Width-sz.cX) div 2,2+(tc.Bounds.Top-2-sz.cY) div 2);
        ppBottom: with tc.Bounds do r.TopLeft:=Point((tf.Width-sz.cX) div 2,
          Bottom+(tf.Height-BevelFld-4-(Bottom-Top)-sz.cY) div 2);
      end;
		end;
    r.Right:=r.Left+sz.cX; r.Bottom:=r.Top+sz.cY;
    if Assigned(DimBM[l]) then Canvas.BrushCopy(r,DimBM[l],
      Rect(0,0,sz.cX-1,sz.cY-1),DimBM[l].Canvas.Pixels[0,0]);
  end;
  DelStack;
end;

{ Автоматическая установка размеров }
function TBoolDrwGet.SizeAuto;
var l: boolean;
  sz: TSize;
begin
	AddStack('TBoolDrwGet.SizeAuto',Self);
	result := inherited SizeAuto(tf,Opt);
	if AssignObj(tf) then begin
    if tc.AsLabel and (tc.Caption='') then ZeroMemory(@result,SizeOf(result));
    sz:=result;
    if (PictPlace=ppTop) or (PictPlace=ppBottom) then sz.cY:=0 else sz.cX:=0;
    for l:=false to true do MaxSelf(sz,BMSize(l));
    if (PictPlace=ppTop) or (PictPlace=ppBottom) then begin
      if tfszWidth in Opt then result.cX:=sz.cX;
      if tfszHeight in Opt then Inc(result.cY,sz.cY);
    end
    else begin
      if tfszWidth in Opt then Inc(result.cX,sz.cX);
      if tfszHeight in Opt then result.cY:=sz.cY;
    end;
    if tfszWidth in Opt then Inc(result.cX,4);
    if tfszHeight in Opt then Inc(result.cY,4);
  end;
  DelStack;
end;

function TBoolDrwGet.BMSize;
begin
  AddStack('TBoolDrwGet.BMSize',Self);
  if Assigned(DimBM[fl])
  then with DimBM[fl] do WinSize(result,Width,Height)
  else ZeroMemory(@result,SizeOf(result));
  DelStack;
end;

{ Установить свойства объектов в соответствии с Value }
procedure TBoolDrwGet.SetValue;
begin
	AddStack('TBoolDrwGet.SetValue',Self);
	inherited SetValue(tf,v);
	tf.Refresh;
  DelStack;
end;

procedure TBoolDrwGet.Assign;
begin
	AddStack('TBoolDrwGet.Assign',Self);
  if Source is TBoolDrwGet then with TBoolDrwGet(Source) do begin
  	Self.PictFalse:=PictFalse; Self.PictTrue:=PictTrue;
  end;
	inherited Assign(Source);
  DelStack;
end;

function TBoolDrwGet.MaskTrans;
var pp: TChkPictPlace;
begin
	AddStack('TBoolDrwGet.MaskTrans',Self);
	result := inherited MaskTrans(av,r,nmf);
	if MyVarType(av)=varArray then begin
  	pp:=aims[byte(IsNilc(av[4],1))]; IncD(result,IfThen(pp<>ppBottom,cChkPictPlace+ams[pp]));
  end
  else begin
  	VarArrayRedim(result,4);
    result[4]:=VarArrayOf([mpRadio,'Расположение рисунка',amsi[MaskPlace(av)],Length(aChkPictPlace),longint(@aChkPictPlace)]);
  end;
  DelStack;
end;

procedure MaskHelpAdd(var ht: THelpTbl; var n: byte; const Capt,beg: string; const a: array of string; const ac: array of char;
  Def: byte);
var s,s1,s2: string;
  i: byte;
begin
  AddStack('ChkGets.MaskHelpAdd');
  s:=HelpBoldStr('«'+Capt+'»'); s1:=''; s2:='';
  for i:=low(a) to high(a) do begin
    IncD(s1,','+HelpBoldStr('«'+a[i]+'»')); IncD(s2,',"'+ac[i]+'"');
  end;
  Inc(n);
  CopyFrom(ht.Dat[n],HelpIf(s+'='+HelpBoldStr('«'+a[Def]+'»'),'""','"'+beg
    +'"+'+HelpBoldStr('МАС_ВЫБОР','(',hlnkInterMemo)+'('+s+',{'+Copy(s1,2,MaxInt)+'},{'+Copy(s2,2,MaxInt)+'})',
    false));
  DelStack;
end;

procedure TBoolDrwGet.FMaskHelp;
var n: byte;
begin
  AddStack('TBoolDrwGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); IncD(ht.Dat[n,0],'+;'); SetLength(ht.Dat,n+2);
  MaskHelpAdd(ht,n,'Расположение рисунка',cChkPictPlace,aChkPictPlace,ams,byte(ppBottom));
  DelStack;
end;

{ TBoolMultiGet }
const sNewCol = '@C';

constructor TBoolMultiGet.Create;
begin
	AddStack('TBoolMultiGet.Create',Self);
  inherited Create(AOwner);
  RVid:='Отметка значений'; UpdateAllFld(mgCreate);
  DelStack;
end;

procedure TBoolMultiGet.CreateObj;
begin
	AddStack('TBoolMultiGet.CreateObj',Self);
  DestroyObj(tf); tf.DynButCreate;
  inherited CreateObj(tf);
  DelStack;
end;

procedure TBoolMultiGet.ReCreateObj;
var i: longint;
  n: byte;
	tc: TCheckSpace;
  p: TBoolMultiGetPrm;
begin
  AddStack('TBoolMultiGet.ReCreateObj',Self);
  if AssignObj(tf) then begin
    p:=GetPrm(tf.Mask); n:=IfThen(Assigned(bDyn),1);
    for i:=low(p.aCaption) to high(p.aCaption) do begin
    	if tf.ComponentCount=n+i then begin
      	tc:=TCheckSpace.Create(tf);
        with tc do begin
        	Canvas:=tf.Canvas; BevelOuter:=bvNone; OnClick:=tcClick;
        end;
      end
      else tc:=pointer(tf.Components[n+i]);
      tc.Caption:=StrTran(p.aCaption[i],sNewCol); tc.Grayed := ogReadOnly in tf.Options;
      tc.Alignment:=iif(p.lAlignLeft,taLeftJustify,taRightJustify);
    end;
    Inc(n,Length(p.aCaption));
    with tf do while ComponentCount>n do Components[ComponentCount-1].Free;
    tf.Invalidate;
    inherited ReCreateObj(tf);
  end;
  DelStack;
end;

procedure TBoolMultiGet.BoolNewCol;
var i,j,t,h: longint;
  fl: boolean;
  p: TBoolMultiGetPrm;
begin
  AddStack('TBoolMultiGet.BoolNewCol',Self);
  p:=GetPrm(tf.Mask); j:=Length(p.aCaption); SetLength(a,j);
  if j>0 then a[0]:=0;
  j:=1; t:=0; h:=0;
  if lAllHeight then begin
    lAllHeight := tf.CharHeight<0;
    if lAllHeight and (tf.ComponentCount>0) then begin
      h:=TCheckSpace(tf.Components[0]).MinHeight+2; t:=h;
    end;
  end;
  for i:=1 to high(p.aCaption) do begin
    if lAllHeight then begin
      fl := t+h>tf.Height-BevelFld2-4;
      if fl then t:=0;
    end
    else fl:=AnsiStartsStr(sNewCol,p.aCaption[i]);
  	if fl then begin
    	a[j]:=i; Inc(j);
    end;
    Inc(t,h);
  end;
  SetLength(a,j);
  DelStack;
end;

procedure TBoolMultiGet.PaintObj;
var i,j,t,l,w,wd: longint;
  n: byte;
	a: TArrInt;
	ts: TSchem;
begin
	AddStack('TBoolMultiGet.PaintObj',Self);
  if AssignObj(tf) then begin
    if not(csDesigning in ComponentState) then
      if SchemName(tf.Schem,ts) then tf.Font.Assign(ts.Font2);
    n:=IfThen(Assigned(bDyn),1); BoolNewCol(tf,a,true); j:=0; t:=0;
    l:=BevelFld+2+tf.DynCaptSize(tf.Height-BevelFld2).cX; w:=0; wd:=DynButSize.cX;
    for i:=n to tf.ComponentCount-1 do with TCheckSpace(tf.Components[i]) do begin
      if i=n+a[j] then begin
        t:=BevelFld+2; Inc(l,w); Inc(j); w:=0;
      end;
      SetBounds(l,t,IfThen(j>high(a),tf.Width-BevelFld-2-l-wd,MinWidth),MinHeight+2);
      t:=Bounds.Bottom; MaxSelf(w,MinWidth);
    end;
    if Assigned(bDyn) then bDyn.SetBounds(tf.Width-BevelFld-wd,BevelFld,wd,tf.Height-BevelFld2);
  end;
  DelStack;
end;

function TBoolMultiGet.SizeAuto;
var i,j,w,h: longint;
	ts: TSchem;
	a: TArrInt;
  n: byte;
  dsz,dcsz: TSize;
begin
	AddStack('TBoolMultiGet.SizeAuto',Self);
  if csDesigning in ComponentState
  then result := inherited SizeAuto(tf,Opt)
  else ZeroMemory(@result,SizeOf(result));
  if AssignObj(tf) then begin
    if tf.CharHeight<0 then Exclude(Opt,tfszHeight);
    n:=IfThen(Assigned(bDyn),1); BoolNewCol(tf,a,false); j:=0; w:=0; h:=0;
    if not(csDesigning in ComponentState) then
      if SchemName(tf.Schem,ts) then tf.Font.Assign(ts.Font2);
    for i:=n to tf.ComponentCount-1 do with TCheckSpace(tf.Components[i]) do begin
      if i=n+a[j] then begin
        if tfszWidth in Opt then Inc(result.cX,w);
        if tfszHeight in Opt then MaxSelf(result.cY,h);
        Inc(j); w:=0; h:=0;
      end;
      if tfszWidth in Opt then MaxSelf(w,MinWidth);
      if tfszHeight in Opt then Inc(h,MinHeight+2);
    end;
    if Opt<>[] then begin
      dsz:=DynButSize; h:=max(max(result.cY,h)+4,dsz.cY); dcsz:=tf.DynCaptSize(h);
      if tfszWidth in Opt then Inc(result.cX,w+4+dsz.cX+dcsz.cX);
      if tfszHeight in Opt then result.cY:=max(h,dcsz.cY);
    end;
  end;
  DelStack;
end;

function TBoolMultiGet.GetValue;
var i: longint;
  n: byte;
begin
	AddStack('TBoolMultiGet.GetValue',Self);
	result:='';
  if AssignObj(tf) then begin
    n:=IfThen(Assigned(bDyn),1);
    for i:=n+1 to tf.ComponentCount do SetByte(result,i-n,TCheckSpace(tf.Components[i-1]).Checked);
  end;
  DelStack;
end;

procedure TBoolMultiGet.SetValue;
var i: longint;
  n: byte;
begin
	AddStack('TBoolMultiGet.SetValue',Self);
  if AssignObj(tf) then begin
    n:=IfThen(Assigned(bDyn),1);
    for i:=n+1 to tf.ComponentCount do TCheckSpace(tf.Components[i-1]).Checked:=GetByte(v,i-n);
  end;
  DelStack;
end;

procedure TBoolMultiGet.tcClick;
var tf: TFldEdit;
	tc: TCheckSpace;
begin
	AddStack('TBoolMultiGet.tcClick',Self);
	tc:=pointer(Sender); tf:=FldEditOwner(tc);
  if not tf.Active then tf.SetFocus;
  if not((ogReadOnly in tf.Options) or tf.IsDynamic or tc.Grayed) then begin
  	SetChkActive(tf,tc.ComponentIndex); tc.CheckedNot; tf.Value:=GetValue(tf);
  end;
  DelStack;
end;

procedure TBoolMultiGet.DoEnter;
var tl: TKeyLb;
	MainMn: TKeyMenu;
begin
	AddStack('TBoolMultiGet.DoEnter',Self);
  inherited DoEnter(tf);
  if FormKeyLb(tf,tl) and not((ogReadOnly in tf.Options) or Assigned(bDyn)) then with tl do begin
   	SetKeys([K_Space,K_Ins,K_Left,K_Right],'Отметка','',ProcKey,'boolmultiget',kmEdit);
   	SetKeySel([K_Plus,K_F2],[K_Minus,K_F3],ProcKey,'boolmultiget',kmEdit);
    ReDrw;
    if SeekKeyMenu(tf,MainMn) then MainMn.InsLine(kmEdit,K_Space);
  end;
  SetChkActive(tf,ChkNext(tf));
  DelStack;
end;

procedure TBoolMultiGet.DoExit;
var tl: TKeyLb;
	MainMn: TKeyMenu;
begin
	AddStack('TBoolMultiGet.DoExit',Self);
  if SeekKeyMenu(tf,MainMn) then MainMn.DelLine(kmEdit,K_Space);
  if FormKeyLb(tf,tl) then begin
   	tl.DelKey(K_All,'boolmultiget'); tl.ReDrw;
  end;
  if AssignObj(tf) and not(csDestroying in tf.ComponentState) then SetChkActive(tf);
  inherited DoExit(tf);
  DelStack;
end;

procedure TBoolMultiGet.ProcKey;
var fl: boolean;
  i: longint;
  tf: TFldEdit;
begin
  AddStack('TBoolMultiGet.ProcKey',Self);
  tf:=pointer(tw);
  if Key in [K_F2,K_F3,K_Plus,K_Minus] then begin
    fl := Key in [K_F2,K_Plus];
    if AskSel(fl) then
      for i:=0 to tf.ComponentCount-1 do with TCheckSpace(tf.Components[i]) do
        if not Grayed then begin
          Checked:=fl; tf.Value:=GetValue(tf);
        end;
  end
  else begin
  	i:=GetChkActive(tf);
    if InRange(i,0,tf.ComponentCount-1) then
    	with TCheckSpace(tf.Components[i]) do	if not Grayed then CheckedNot;
    if (Key=K_Ins) and (i<tf.ComponentCount-1) then SetChkActive(tf,i+1);
    tf.Value:=GetValue(tf);
  end;
  DelStack;
end;

function TBoolMultiGet.MayDoKey;
begin
	AddStack('TBoolMultiGet.MayDoKey',Self);
	result := inherited MayDoKey(tf,Key);
  if result then
	  if AssignObj(tf) then
      if not Assigned(bDyn) then
        if (Key=K_Up) and (ChkActPrior(tf)<>NegDef)
          then result:=false
        else if (Key=K_Down) and (ChkActNext(tf)<>NegDef)
          then result:=false;
  DelStack;
end;

procedure TBoolMultiGet.HookProc;
begin
	AddStack('TBoolMultiGet.HookProc',Self);
  inherited HookProc(tf,Message);
  if Message.Msg=WM_KEYDOWN then
    if not Assigned(bDyn) then with TWMKeyDown(Message) do
      if KeyDataToShiftState(KeyData)=[] then
        if tf.ComponentCount>0 then case CharCode of
          vk_Up: SetChkActive(tf,ChkActPrior(tf));
          vk_Down: SetChkActive(tf,ChkActNext(tf));
          vk_Home: SetChkActive(tf,ChkNext(tf));
          vk_End: SetChkActive(tf,ChkPrior(tf,tf.ComponentCount));
        end;
  DelStack;
end;

procedure TBoolMultiGet.Paint;
var r: TRect;
begin
	AddStack('TBoolMultiGet.Paint',Self);
  with tf do begin
    r:=Rect(BevelFld,BevelFld,Width-BevelFld,Height-BevelFld); Frame3D1(Canvas,r);
  end;
  DelStack;
end;

class function TBoolMultiGet.GetPrm;
begin
  AddStack('TBoolMultiGet.GetPrm');
  with result do begin
    lAlignLeft := (Pos(cBoolLeft,Mask)>0) or (Pos(AnsiLowerCase(cBoolLeft),Mask)>0);
    LsArrDynamic(StrTran(Mask,cBoolLeft,'',[rfReplaceAll,rfIgnoreCase]),aCaption,mniDlm,lsaSetLen);
  end;
  DelStack;
end;

function TBoolMultiGet.MaskTrans;
begin
	AddStack('TBoolMultiGet.MaskTrans');
	if MyVarType(av)=varArray then result:=Trim(StrTran(IsNilc(av[1],''),UnDelim,mniDlm))
    +IfThen(IsNilc(av[2],false),cBoolLeft)
  else with GetPrm(av) do result:=ArrVarToVar([ArrayAsList(aCaption,UnDelim),lAlignLeft]);
  DelStack;
end;

procedure TBoolMultiGet.MaskPrn;
var p: TBoolMultiGetPrm;
begin
	AddStack('TBoolMultiGet.MaskPrn',Self);
  p:=GetPrm(Mask);
  if Length(p.aCaption)>0 then LsPrn.Add('Значения: '+ArrayAsList(p.aCaption,','));
  if p.lAlignLeft then LsPrn.Add('Подсказка слева');
  DelStack;
end;

procedure TBoolMultiGet.FMaskHelp;
var n: byte;
begin
  AddStack('TBoolDrwGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+3);
  Inc(n); CopyFrom(ht.Dat[n],HelpArrayAsList('«Значения»','"'+mniDlm+'"')+'+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpIf('«Подсказка слева»','"'+cBoolLeft+'"','""'));
  DelStack;
end;

procedure TBoolMultiGet.StdDWFldInfo;
var i: longint;
  s,nmf: string;
  p: TBoolMultiGetPrm;
begin
	AddStack('TBoolMultiGet.StdDWFldInfo',Self);
  if BoolMultiDDat then begin
    FldInfo.Size:=-1;
    with GetPrm(Mask) do for i:=low(aCaption) to high(aCaption) do Inc(FldInfo.Size,Length(aCaption[i])+1);
    MaxSelf(FldInfo.Size);
  end
  else begin
    //FldInfo.Size:=Length(Trim(Mask));
    FldInfo.Visible:=false; ChildFldCreate(Self,FldInfo);
    FldInfo.Visible:=true; FldInfo.FieldClass:=TBooleanField;
    FldInfo.Size:=0; FldInfo.Alignment:=taCenter;
    p:=GetPrm(Mask);
    s:=RightStrDel(Trim(FldInfo.DisplayLabel),':'); nmf:=FldLsCurVR.Name+UnDelim;
    for i:=1 to Length(p.aCaption) do begin
      FldLsCurVR.Name:=StrNum(nmf,i);
      FldInfo.DisplayLabel:=DlmBetween(s,StrTran(p.aCaption[i-1],sNewCol),':'); s:='';
      ChildFldCreate(Self,FldInfo);
    end;
    FldInfo.FieldClass:=nil;
  end;
  DelStack;
end;

procedure TBoolMultiGet.StdDWFldValue;
var a: array[1..2] of string;
  p: TChkLogPrm;
  Prm: TLogTrnsValPrm;
begin
	AddStack('TBoolMultiGet.StdDWFldValue',Self);
  LsArrFill(Mask,a,UnDelim);
  if a[2]='' then begin
    CopyFrom(p.a,GetPrm(Mask).aCaption); p.Invert:=false;
    Prm.Opt:=[]; TChkLogCompare.ExecuteStr(Prm,'',Value,@p); Value:=Prm.val;
    if BoolMultiDDat then Value:=StrTran(TrimRight(Value),CRLF,'|');
  end
  else Value:=GetByte(r[a[1]],Int0(a[2]));
  DelStack;
end;

procedure TBoolMultiGet.LogCompare;
begin
  AddStack('TBoolMultiGet.LogCompare',Self);
  TChkLogCompare.Execute(Prm,GetPrm(tf.Mask).aCaption);
  inherited LogCompare(tf,Prm);
  DelStack;
end;

procedure TBoolMultiGet.DWFldValid;
var l: longint;
begin
	AddStack('TBoolMultiGet.DWFldValid',Self);
  inherited DWFldValid(ap,dwInf,nFldFocus,nVarFocus,amsg);
  if (Length(amsg)=0) and not IsDWFldMemo(dwInf.AType) then begin
  	l:=Length(GetPrm(ap[deMask]).aCaption);
    if l>dwInf.Len then begin
    	AddFrom(amsg,[BracketInt('Длина поля для указанного количества значений',l),
      	BracketInt('превышает длину данного',dwInf.Len)+'.']);
      nFldFocus:=deNameRecFld;
    end;
  end;
  DelStack;
end;

function TBoolMultiGet.DWFldUnAllowType;
begin
  result:=[low(aDWFld)..high(aDWFld)]-[dwtString,dwtMemo,dwtManyStr];
end;

class procedure TBoolMultiGet.FMaskView;
begin
  AddStack('TBoolMultiGet.FMaskView');
  Mask:=ArrayAsList(GetPrm(Mask).aCaption,',');
  DelStack;
end;

class procedure TBoolMultiGet.ItemReadOnly;
var tc: TCheckSpace;
begin
  AddStack('TBoolMultiGet.ItemReadOnly');
  if InRange(Index,0,tf.ComponentCount-1) then
  	if IsClass(tf.Components[Index],TCheckSpace,pointer(tc)) then tc.Grayed:=Value;
  DelStack;
end;

class function TBoolMultiGet.DDatSupport;
begin
  result:=true;
end;

{ TRadioGet }
class function TRadioGet.RGPrm;
var p,i: longint;
	ms,s: string;
begin
	AddStack('TRadioGet.RGPrm');
  result.PictPlace:=MaskPlace(m); ms:=StrDivDlm(cChkPictPlace,m)[1]; result.nBeg:=1;
  if IsPos(p,cRdBeg,ms) then begin
  	result.nBeg:=Int0(Copy(ms,p+Length(cRdBeg),MaxInt));
    Delete(ms,p,Length(cRdBeg)+LenIntStr(result.nBeg));
  end;
  result.Arrange:=rgaCol;
  if not IsPos(p,cRdArrange,ms) then p:=Pos(AnsiLowerCase(cRdArrange),ms);
  if p>0 then begin
    s:=AnsiUpperCase(Copy(ms,p+Length(cRdArrange),1));
    if AnsiFindChar(s,aRdArrange,i) then begin
      result.Arrange:=TRGArrangeList(i); Delete(ms,p,Length(cRdArrange)+Length(s));
    end;
  end;
  result.sItems:=StrTran(TrimRight(ms),mniDlm,CRLF);
  DelStack;
end;

constructor TRadioGet.Create;
begin
	AddStack('TRadioGet.Create',Self);
	Inherited Create(AOwner);
  flObj:=false;
  FItems:=TStringList.Create; FItems.OnChange:=ItemsChange;
  WorkItems:=TStringList.Create;
  DelStack;
end;

destructor TRadioGet.Destroy;
begin
	AddStack('TRadioGet.Destroy',Self);
	FItems.Clear; FItems.Free; WorkItems.Free;
	inherited Destroy;
  DelStack;
end;

procedure TRadioGet.SetItems;
begin
	AddStack('TRadioGet.SetItems',Self);
	FItems.Assign(Value);
  DelStack;
end;

procedure TRadioGet.ItemsChange;
var i: longint;
begin
	AddStack('TRadioGet.ItemsChange',Self);
  if not flObj then begin
    TInitBM.Init(Application.MainForm);
    for i:=0 to FItems.Count-1 do begin
      flObj:=true; FItems.Objects[i]:=InitBM.FindBM(Trim(GetRec(i,FItems)[rgPict])); flObj:=false;
    end;
    UpdateAllFld(mgCreate);
  end;
  DelStack;
end;

function TRadioGet.GetRec;
begin
	AddStack('TRadioGet.GetRec',Self);
	PointerDef(pointer(ls),WorkItems); ListAsArray(ls[i],result,UnDelim);
  DelStack;
end;

{ Создание объектов }
procedure TRadioGet.CreateObj;
begin
	AddStack('TRadioGet.CreateObj',Self);
	DestroyObj(tf); tf.DynButCreate;
  inherited CreateObj(tf);
  DelStack;
end;

procedure TRadioGet.ReCreateObj;
var i,j: longint;
	tc: TCheckSpace;
begin
	AddStack('TRadioGet.ReCreateObj',Self);
  if not tf.IsDynamic and AssignObj(tf) then begin
    while tf.ComponentCount<WorkItems.Count do begin
      tc:=TCheckSpace.Create(tf);
      with tc do begin
				Canvas:=tf.Canvas; Style:=csRadio; BevelOuter:=bvNone; onClick:=tcClick;
      end;
    end;
    while tf.ComponentCount>WorkItems.Count do tf.Components[tf.ComponentCount-1].Free;
    j:=0;
    for i:=0 to tf.ComponentCount-1 do if IsClass(tf.Components[i],TCheckSpace,pointer(tc)) then begin
      tc.Caption:=GetRec(j)[rgName]; Inc(j); tc.Visible := not tf.NoPaintObj;
    end;
    inherited ReCreateObj(tf);
    tf.Refresh;
  end;
  DelStack;
end;

procedure TRadioGet.RadioCheckWH;
var i: longint;
	tc: TCheckSpace;
begin
  AddStack('TRadioGet.RadioCheckWH',Self);
  w:=0; h:=0;
  for i:=0 to tf.ComponentCount-1 do if IsClass(tf.Components[i],TCheckSpace,pointer(tc)) then
    case Prm.Arrange of
      rgaCol: begin
        MaxSelf(w,tc.MinWidth); Inc(h,tc.MinHeight);
      end;
      rgaRow: begin
        MaxSelf(h,tc.MinHeight); Inc(w,tc.MinWidth);
      end;
    end;
  DelStack;
end;

{ Нарисовать объекты }
procedure TRadioGet.PaintObj;
var i,j,l,t,w,h,wd,wc: longint;
  n: byte;
	ts: TSchem;
  tc: TCheckSpace;
  a: TArrInt;
begin
	AddStack('TRadioGet.PaintObj',Self);
	if AssignObj(tf) then begin
    n:=IfThen(Assigned(bDyn),1);
    if not(csDesigning in ComponentState) then begin
      if SchemName(tf.Schem,ts) then tf.Font.Assign(ts.Font2);
      for i:=n to tf.ComponentCount-1 do
        if IsClass(tf.Components[i],TCheckSpace,pointer(tc))
        then tc.Grayed := (ogReadOnly in tf.Options) or not tc.Enabled;
    end;
    if ogAutoSize in tf.Options then RadioCheckWH(tf,w,h) else w:=tf.CltWidth-BevelFld2-4;
    l:=0;
    for i:=n to tf.ComponentCount-1 do
      if tf.Components[i] is TCheckSpace then Inc(l);
    SetLength(a,l); h:=tf.Height-BevelFld2-4; RasprOst(a,h,[rspoEqual]);
    wd:=DynButSize.cX; wc:=tf.DynCaptSize(h).cX;
    l:=4;
    t:=IfThen(Prm.PictPlace=ppBottom,BevelFld+2,tf.CltHeight-2-h-BevelFld);
    if empty(Prm.sItems) and (Prm.PictPlace in [ppLeft,ppRight]) then
      for i:=0 to FItems.Count-1 do if Assigned(FItems.Objects[i]) then begin
        l:=IfThen(Prm.PictPlace=ppRight,BevelFld+2,tf.CltWidth-2-w-wd-wc-BevelFld);
        t := 2 + (tf.CltHeight-4-h) div 2;
        break;
      end;
    j:=0; Inc(l,wc);
    for i:=n to tf.ComponentCount-1 do if IsClass(tf.Components[i],TCheckSpace,pointer(tc)) then begin
      case Prm.Arrange of
        rgaCol: begin
          {if ogAutoSize in tf.Options then h:=tc.MinHeight else} h:=a[j];
          tc.SetBounds(l,t,w,h); Inc(t,h);
        end;
        rgaRow: begin
          w:=tc.MinWidth; tc.SetBounds(l,t,w,h); Inc(l,w);
        end;
      end;
      Inc(j);
    end;
    if Assigned(bDyn) then bDyn.SetBounds(tf.Width-BevelFld-wd,BevelFld,wd,tf.Height-BevelFld2);
    tf.Refresh;
  end;
  DelStack;
end;

procedure TRadioGet.Paint;
var ts: TSchem;
  w,h,wc: longint;
  r,rbm: TRect;
  bm: TBitMap;
begin
  AddStack('TRadioGet.Paint',Self);
  inherited Paint(tf);
  if AssignObj(tf) then with tf do if Visible then begin
    w:=DynButSize.cX; wc:=DynCaptSize(Height-BevelFld2).cX;
    r:=Rect(BevelFld+wc,BevelFld,Width-BevelFld-w,Height-BevelFld); rbm:=r;
    Frame3D1(Canvas,rbm); SetPrm(Mask); rbm:=Rect(0,0,Width,Height);
    if empty(Prm.sItems) and (FItems.Count>0) then begin
      h:=ValToNum(tf.Value)-1;
      if (h<0) or (h>=FItems.Count) then h:=0;
      if IsClass(FItems.Objects[h],TBitMap,pointer(bm)) then if (bm.Width>0) and (bm.Height>0) then begin
        RadioCheckWH(tf,w,h);
        rbm.TopLeft:=IfThen(Prm.PictPlace in [ppTop,ppBottom],
          Point(2+(CltWidth-4-bm.Width) div 2,
          IfThen(Prm.PictPlace=ppBottom,h,2)+(CltHeight-2-h-bm.Height) div 2),
          Point(IfThen(Prm.PictPlace=ppRight,w+2,2)+(CltWidth-4-w-bm.Width) div 2,
          2+(CltHeight-4-bm.Height) div 2));
        rbm.BottomRight:=Point(rbm.Left+bm.Width,rbm.Top+bm.Height);
        Canvas.Brush.Color:=Color;
        Canvas.BrushCopy(rbm,bm,Rect(0,0,bm.Width-1,bm.Height-1),bm.Canvas.Pixels[0,0]);
      end;
    end;
    if IsDynamic then with Canvas do begin
      SchemName(Schem,ts); Brush.Color:=Color1(ts);
      if Assigned(ts) then Font.Assign(ts.Font1);
      r:=Rect(max(rbm.Left,r.Left),max(rbm.Top,r.Top),min(rbm.Right,r.Right),min(rbm.Bottom,r.Bottom));
      Frame3D2(Canvas,r); FillRect(r); Read; TextRect(r,r.Left,r.Top,RadioName(PNameRecFld.Value,tf));
      if Assigned(ts) then Brush.Color:=ts.ColorW;
    end;
  end;
  DelStack;
end;

{ Автоматическая установка размеров }
function TRadioGet.SizeAuto;
var i,w,h: longint;
	ts: TSchem;
  bm: TBitMap;
  sz: TSize;
begin
	AddStack('TRadioGet.SizeAuto',Self);
	result := inherited SizeAuto(tf,Opt);
  if AssignObj(tf) then begin
    if csDesigning in ComponentState then ts:=nil else SchemName(tf.Schem,ts);
    if Assigned(ts) then tf.Canvas.Font.Assign(ts.Font2) else tf.Canvas.Font.Assign(tf.Font);
    RadioCheckWH(tf,result.cX,result.cY);
    if Prm.PictPlace in [ppTop,ppBottom] then begin
      w:=result.cX; h:=0;
    end
    else begin
      h:=result.cY; w:=0;
    end;
    if empty(Prm.sItems) then
      for i:=0 to FItems.Count-1 do if PointerObj(FItems,i,pointer(bm)) then begin
        MaxSelf(w,bm.Width); MaxSelf(h,bm.Height);
      end;
    if Prm.PictPlace in [ppTop,ppBottom] then begin
      result.cX:=w; Inc(result.cY,h);
    end
    else begin
      result.cY:=h; Inc(result.cX,w);
    end;
    with DynButSize do begin
      Inc(result.cX,cX); MaxSelf(result.cY,cY);
    end;
    with tf.DynCaptSize(result.cY) do begin
      Inc(result.cX,cX); MaxSelf(result.cY,cY);
    end;
    if (csDesigning in ComponentState) and (result.cX=0) and (result.cY=0)
    then result := inherited SizeAuto(tf,Opt)
    else begin
      if tf.IsDynamic then begin
        ZeroMemory(@sz,SizeOf(sz));
        for i:=0 to WorkItems.Count-1 do MaxSelf(sz,tf.Canvas,WorkItems[i]);
        Inc(result.cX,sz.cX); MaxSelf(result.cY,sz.cY);
      end
      else Inc(result.cY,4);
      Inc(result.cX,4);
    end;
  end;
  DelStack;
end;

{ Достать значение Value из объектов }
function TRadioGet.GetValue;
var i,ost: longint;
  n: byte;
  tc: TCheckSpace;
begin
	ost:=AddStack('TRadioGet.GetValue',Self);
  try
  	result:=VarAsType(tf.VarValue,varString);
  except
    SetStack(ost);
    result:='1';
  end;
  if AssignObj(tf) then begin
    n:=IfThen(Assigned(bDyn),1);
    for i:=n to tf.ComponentCount-1 do if IsClass(tf.Components[i],TCheckSpace,pointer(tc)) then
      if tc.Checked then begin
        result:=NumToVal(i-n+1); break;
      end;
  end;
	DelStack;
end;

{ Установить свойства объектов в соответствии с Value }
procedure TRadioGet.SetValue;
var i,nv: longint;
  n: byte;
  tc: TCheckSpace;
begin
	AddStack('TRadioGet.SetValue',Self);
  if AssignObj(tf) then begin
    n:=IfThen(Assigned(bDyn),1);
	  if tf.ComponentCount>n then begin
      nv:=ValToNum(v);
      if not InRange(nv,1,WorkItems.Count) then nv:=1;
      nv:=ReplNeg(ChkNext(tf,nv-2+n),ChkNext(tf,0));
      if InRange(nv,n,tf.ComponentCount-1) then begin
        if IsClass(tf.Components[nv],TCheckSpace,pointer(tc)) then tc.Checked:=true;
        for i:=n to tf.ComponentCount-1 do
          if i<>nv then if IsClass(tf.Components[i],TCheckSpace,pointer(tc)) then tc.Checked:=false;
        tf.PaintObj;
      end;
    end;
  end;
  DelStack;
end;

function TRadioGet.ValToNum;
var vv: variant;
begin
  AddStack('TRadioGet.ValToNum',Self);
  vv:=v;
  if MyVarType(v)=varString then vv:=Int0(v);
  result:=vv-Prm.nBeg+1;
  DelStack;
end;

function TRadioGet.NumToVal;
begin
  AddStack('TRadioGet.NumToVal',Self);
  result:=IntToStr(Prm.nBeg-1+n);
  DelStack;
end;

{ Действия при получении фокуса }
procedure TRadioGet.DoEnter;
var tl: TKeyLb;
	MainMn: TKeyMenu;
	i: longint;
  n: byte;
  tc: TCheckSpace;
begin
	AddStack('TRadioGet.DoEnter',Self);
  if AssignObj(tf) then begin
    i:=ValToNum(tf.Value); n:=IfThen(Assigned(bDyn),1);
    if InRange(i,1,tf.ComponentCount-n) then
      if IsClass(tf.Components[i-1+n],TCheckSpace,pointer(tc)) then
        if tc.Enabled and not(ogReadOnly in tf.Options) then SetChkActive(tf,i-1+n);
    if FormKeyLb(tf,tl) and not((ogReadOnly in tf.Options) or Assigned(bDyn)) then begin
    	for i:=1 to min(9,tf.ComponentCount) do
        tl.SetKey(K_0+i,'','Установить значение "'+TCheckSpace(tf.Components[i-1]).Caption+'"',ProcKey,'boolget',kmNone);
      tl.SetKey(K_Space,'Отметка','',ProcKey,'boolget',kmEdit); tl.ReDrw;
      if SeekKeyMenu(tf,MainMn) then MainMn.InsLine(kmEdit,K_Space);
    end;
  end;
  inherited DoEnter(tf);
  DelStack;
end;

{ Действия при утере фокуса }
procedure TRadioGet.DoExit;
var tl: TKeyLb;
	MainMn: TKeyMenu;
begin
	AddStack('TRadioGet.DoExit',Self);
  if SeekKeyMenu(tf,MainMn) then MainMn.DelLine(kmEdit,K_Space);
  if FormKeyLb(tf,tl)
  {and Assigned(GetParentForm(tf).ActiveControl)} then begin
   	tl.DelKey(K_All,'boolget'); tl.ReDrw;
  end;
  if AssignObj(tf) and not(csDestroying in tf.ComponentState) then SetChkActive(tf);
  inherited DoExit(tf);
  DelStack;
end;

procedure TRadioGet.ProcKey;
var k: longint;
  tf: TFldEdit;
  tc: TCheckSpace;
begin
	AddStack('TRadioGet.ProcKey',Self);
	tf:=pointer(tw);
  if AssignObj(tf) then begin
    if Key=K_Space then k:=GetChkActive(tf) else k:=Key-K_0-1;
    if InRange(k,0,tf.ComponentCount-1) then
      if IsClass(tf.Components[k],TCheckSpace,pointer(tc)) then tc.Click;
  end;
  DelStack;
end;

{ Можно ли выполнить клавишу }
function TRadioGet.MayDoKey;
begin
	AddStack('TRadioGet.MayDoKey',Self);
	result := inherited MayDoKey(tf,Key);
  if result then
	  if AssignObj(tf) then
      if not Assigned(bDyn) then
        if (Key=K_Up) and (ChkActPrior(tf)<>NegDef)
          then result:=false
        else if (Key=K_Down) and (ChkActNext(tf)<>NegDef)
          then result:=false;
  DelStack;
end;

procedure TRadioGet.SetPrm;
begin
  AddStack('TRadioGet.SetPrm',Self);
  Prm:=RGPrm(Mask);
  if empty(Prm.sItems) then WorkItems.Assign(FItems) else WorkItems.Text:=Prm.sItems;
  DelStack;
end;

// Поиск объектов
function TRadioGet.AssignObj;
begin
	AddStack('TRadioGet.AssignObj',Self);
  Prm.PictPlace:=ppBottom; Prm.sItems:=''; result := inherited AssignObj(tf);
  if result then SetPrm(tf.Mask);
  DelStack;
end;

// Щелчок
procedure TRadioGet.tcClick;
var tf: TFldEdit;
	tc: TCheckSpace;
	i: longint;
begin
	AddStack('TRadioGet.tcClick',Self);
	tc:=pointer(Sender); tf:=FldEditOwner(tc); tf.EdClick(tf);
  if not tf.Active then tf.SetFocus;
  if not(ogReadOnly in tf.Options) then
    if AssignObj(tf) then
      if not Assigned(bDyn) then
        for i:=0 to tf.ComponentCount-1 do
          if tf.Components[i]=tc then begin
            tf.Value:=NumToVal(i+1-IfThen(Assigned(bDyn),1)); SetChkActive(tf,i); break;
          end;
  DelStack;
end;

procedure TRadioGet.HookProc;
begin
	AddStack('TRadioGet.HookProc',Self);
  inherited HookProc(tf,Message);
  if Message.Msg=WM_KEYDOWN then
    if not Assigned(bDyn) then with TWMKeyDown(Message) do
      if KeyDataToShiftState(KeyData)=[] then
        if tf.ComponentCount>0 then case CharCode of
          vk_Up: SetChkActive(tf,ChkActPrior(tf));
          vk_Down: SetChkActive(tf,ChkActNext(tf));
          vk_Home: SetChkActive(tf,ChkNext(tf));
          vk_End: SetChkActive(tf,ChkPrior(tf,tf.ComponentCount));
        end;
  DelStack;
end;

// Наименование по коду
function TRadioGet.RadioName;
var ls: TStringList;
label lend;
begin
	AddStack('TRadioGet.RadioName',Self);
	result:=''; ls:=FItems;
	if Assigned(tf) then begin
  	if AssignObj(tf) then ls:=WorkItems else goto lend;
	  Index:=ValToNum(Index);
  end;
  if InRange(Index,1,ls.Count) then result:=GetRec(Index-1,ls)[rgName];
lend:
	DelStack;
end;

procedure TRadioGet.Assign;
begin
	AddStack('TRadioGet.Assign',Self);
  if Source is TRadioGet
  then Items.Assign(TRadioGet(Source).Items);
	inherited Assign(Source);
  DelStack;
end;

procedure TRadioGet.StdDWFldInfo;
var i: longint;
begin
	AddStack('TRadioGet.StdDWFldInfo',Self);
  FldInfo.FieldClass:=TStringField; FldInfo.Alignment:=taLeftJustify; FldInfo.Size:=0; SetPrm(Mask);
  for i:=0 to WorkItems.Count-1 do MaxSelf(FldInfo.Size,WorkItems[i]);
  DelStack;
end;

procedure TRadioGet.StdDWFldValue;
var i: longint;
begin
	AddStack('TRadioGet.StdDWFldValue',Self);
  SetPrm(Mask);
  if WorkItems.Count>0 then begin
    i:=ValToNum(Value);
    if not InRange(i,1,WorkItems.Count) then i:=1;
    Value:=GetRec(i-1)[rgName];
  end
  else Value:='';
  DelStack;
end;

procedure TRadioGet.DWFldValid;
var l,l1: longint;
begin
	AddStack('TRadioGet.DWFldValid',Self);
  inherited DWFldValid(ap,dwInf,nFldFocus,nVarFocus,amsg);
  if (Length(amsg)=0) and not IsDWFldMemo(dwInf.AType) then begin
  	SetPrm(ap[deMask]); l:=LenIntStr(WorkItems.Count); l1:=LenInt(dwInf.Len,dwInf.Dec);
    if l>l1 then begin
    	AddFrom(amsg,[BracketInt('Длина поля для указанного количества значений',l),
      	BracketInt('превышает длину целой части данного',l1)+'.']);
      nFldFocus:=deNameRecFld;
    end;
  end;
  DelStack;
end;

function TRadioGet.DWFldUnAllowType;
begin
  result:=[dwtDate,dwtBool,dwtArray,dwtSel];
end;

function TRadioGet.MaskTrans;
var Prm: TRadioGetPrm;
begin
	AddStack('TRadioGet.MaskTrans');
	if MyVarType(av)=varArray then begin
    result:=StrTran(TrimRight(IsNilc(av[4],'')),CRLF,mniDlm);
    Prm.nBeg:=IsNilc(av[2],1);
    if Prm.nBeg<>1 then result:=StrNum(result+cRdBeg,Prm.nBeg);
    Prm.PictPlace:=aims[byte(IsNilc(av[1],1))];
    if Prm.PictPlace<>ppBottom then IncD(result,cChkPictPlace+ams[Prm.PictPlace]);
    Prm.Arrange:=IsNilc(av[3],1)-1;
    if Prm.Arrange<>rgaCol then IncD(result,cRdArrange+aRdArrange[Prm.Arrange]);
  end
  else begin
  	Prm:=RGPrm(av);
    result:=ArrVarToVar(
      [VarArrayOf([mpRadio,'Расположение'+UnDelim+'рисунка',amsi[Prm.PictPlace],Length(aChkPictPlace),longint(@aChkPictPlace)])
      ,VarArrayOf([mpSpin,'Начать с',Prm.nBeg,-MaxInt,MaxInt])
      ,VarArrayOf([mpRadio,'Расположение'+UnDelim+'значений',byte(Prm.Arrange)+1,Length(aArrangeNm),longint(@aArrangeNm)])
      ,VarArrayOf([mpMemo,'Значения',Prm.sItems])
      ]);
  end;
  DelStack;
end;

class function TRadioGet.MaskSortMode;
begin
  result:=smColumns;
end;

procedure TRadioGet.MaskPrn;
var Prm: TRadioGetPrm;
begin
	AddStack('TRadioGet.MaskPrn',Self);
  Prm:=RGPrm(Mask);
  if Prm.nBeg<>1 then LsPrn.Add(StrNum('Начать с ',Prm.nBeg));
  if not empty(Prm.sItems) then LsPrn.Add('Значения: '+StrTran(TrimRight(Prm.sItems),CRLF,','));
  DelStack;
end;

procedure TRadioGet.FMaskHelp;
var n: byte;
  s: string;
begin
  AddStack('TRadioGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+6);
  Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr('«Подсказка»')+'+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpArrayAsList('«Значения»','"'+mniDlm+'"')+'+;');
  s:=HelpBoldStr('«Начать с»');
  Inc(n); CopyFrom(ht.Dat[n],HelpIf(s+'=1','""','"'+cRdBeg+'"+'+HelpNum(s,false),false));
  MaskHelpAdd(ht,n,'Расположение рисунка',cChkPictPlace,aChkPictPlace,ams,byte(ppBottom));
  MaskHelpAdd(ht,n,'Расположение значений',cRdArrange,aArrangeNm,aRdArrange,byte(rgaCol));
  DelStack;
end;

class function TRadioGet.DDatSupport;
begin
  result:=true;
end;

procedure TRadioGet.LogEnumVal;
begin
  AddStack('TRadioGet.LogEnumVal',Self);
  with Prm do begin
    val:=RadioName(Int0(val)); lBreak:=true;
  end;
  DelStack;
end;

{ TTblChkGet }
constructor TTblChkGet.Create;
begin
	AddStack('TTblChkGet.Create',Self);
  inherited Create(AOwner);
  RVid:='Отметка значений в таблице'; UpdateAllFld(mgCreate);
  DelStack;
end;

procedure TTblChkGet.CreateObj;
begin
	AddStack('TTblChkGet.CreateObj',Self);
  DestroyObj(tf); tf.DynButCreate; tbl:=TStrTable.Create(tf);
  with tbl,TNone do begin
   	Parent:=tf; CanInvert:=false; KeyDblClick:=K_Space;
    onBeforeDrawCell:=tblBeforeDrawCell; onDrawCell:=tblDrawCell; OnHeadWHCalc:=tblHeadWHCalc;
    onClick:=tf.EdClick; onDblClick:=tf.EdDblClick; onKeyDown:=tf.EdKeyDown;
    onKeyPress:=tf.EdKeyPress; onKeyUp:=tf.EdKeyUp; onMouseDown:=tf.EdMouseDown;
    onMouseMove:=tf.EdMouseMove; onMouseUp:=tf.EdMouseUp;
    SetSchemForm(tf);
  end;
  inherited CreateObj(tf);
  DelStack;
end;

procedure TTblChkGet.ReCreateObj;
var fl: boolean;
	procedure SetLs(ls: TStrings; const a: TTblChkGetArr);
  var s: string;
  begin
    AddStack('TTblChkGet.ReCreateObj.SetLs',Self);
    s:=TrimRight(ArrayAsList(a.a,CRLF,a.l));
    if TrimRight(ls.Text)<>s then begin
    	ls.Text:=s; fl:=true;
    end;
    DelStack;
  end;
var Prm: TTblChkGetPrm;
begin
	AddStack('TTblChkGet.ReCreateObj',Self);
  if AssignObj(tf) then begin
    Prm:=Mask2Prm(tf.Mask);
    with tbl do begin
      CaptY:=Prm.Capt; fl:=false; SetLs(HeadX,Prm.aCol); SetLs(HeadY,Prm.aRow);
      if fl then Fill;
    end;
    inherited ReCreateObj(tf);
  end;
  DelStack;
end;

procedure TTblChkGet.PaintObj;
var w,wc,h: longint;
begin
  AddStack('TTblChkGet.PaintObj',Self);
  if AssignObj(tf) then begin
    w:=DynButSize.cX; h:=tf.Height-BevelFld2;
    if Assigned(bDyn) then bDyn.SetBounds(tf.Width-BevelFld-w,BevelFld,w,h);
  	wc:=tf.DynCaptSize(h).cX; tbl.SetBounds(BevelFld+wc,BevelFld,tf.Width-BevelFld2-w-wc,h);
    tbl.Color:=tf.Color1;
  end;
  DelStack;
end;

function TTblChkGet.SizeAuto;
var dsz,dcsz: TSize;
  h: longint;
begin
  AddStack('TTblChkGet.SizeAuto',Self);
  result := inherited SizeAuto(tf,Opt);
  if AssignObj(tf) then begin
    if tf.CharWidth<0 then Exclude(Opt,tfszWidth);
    if tf.CharHeight<0 then Exclude(Opt,tfszHeight);
    if Opt<>[] then begin
      dsz:=DynButSize; h:=max(tbl.GridsHeight,dsz.cY); dcsz:=tf.DynCaptSize(h);
      if tfszWidth in Opt then result.cX:=tbl.GridsWidth+SysMetric.iScrollWidth+dsz.cX+dcsz.cX;
      if tfszHeight in Opt then result.cY:=max(h,dcsz.cY);
    end;
  end;
  DelStack;
end;

function TTblChkGet.GetValue;
var i,j: longint;
  s: string;
begin
	AddStack('TTblChkGet.GetValue',Self);
	result:='';
  if AssignObj(tf) then begin
    for i:=0 to tbl.HeadX.Count-1 do begin
      s:='';
      for j:=0 to tbl.HeadY.Count-1 do
      	SetByte(s,GetCodY(j),StrToBoolean(tbl.DatCells[i,j]));
      IncD(result,s+TblChkDlmVal);
    end;
    DecLen(result,lTblChkDlmVal);
  end;
  DelStack;
end;

procedure TTblChkGet.SetValue;
var a: TArrStr;
  i,j: longint;
begin
	AddStack('TTblChkGet.SetValue',Self);
  if AssignObj(tf) then
    for i:=0 to min(LsArrDynamic(v,a,TblChkDlmVal)-1,tbl.HeadX.Count-1) do
      for j:=0 to tbl.HeadY.Count-1 do tbl.DatCells[i,j]:=bStr[GetByte(a[i],GetCodY(j))];
  DelStack;
end;

procedure TTblChkGet.DoEnter;
var tl: TKeyLb;
  mn: TKeyMenu;
begin
  AddStack('TTblChkGet.DoEnter',Self);
  inherited DoEnter(tf);
	if AssignObj(tf) then GetParentForm(tf).ActiveControl:=tbl;
  if not((ogReadOnly in tf.Options) or Assigned(bDyn)) and FormKeyLb(tf,tl) then with tl do begin
    SetKeys([K_Space,K_Ins],'Отметка','',ProcKey,'tblchkget',kmEdit);
    if not StrToBoolean(DlmCopy(tf.Mask,4,1,UnDelim))
    then SetKeySel([K_Plus,K_F2],[K_Minus,K_F3],ProcKey,'tblchkget',kmEdit);
    if SeekKeyMenu(tf,mn) then mn.InsLine(kmEdit,K_Space);
    Redrw;
  end;
  DelStack;
end;

procedure TTblChkGet.DoExit;
var tl: TKeyLb;
  mn: TKeyMenu;
begin
  AddStack('TTblChkGet.DoExit',Self);
  if SeekKeyMenu(tf,mn) then mn.DelLine(kmEdit,K_Space);
  if FormKeyLb(tf,tl) then begin
    tl.DelKey(K_All,'tblchkget'); tl.Redrw;
  end;
  inherited DoExit(tf);
  DelStack;
end;

class procedure TTblChkGet.ProcKey;
var X,Y: Word;
  lSel,fl: boolean;
  s,ov: string;
  tf: TFldEdit;
begin
  AddStack('TTblChkGet.ProcKey');
  with TStrTable(tw) do begin
    tf:=pointer(Owner); ov:=tf.Value; fl:=true;
    if Key in [K_Space,K_Ins] then begin
    	if StrToBoolean(DlmCopy(tf.Mask,4,1,UnDelim)) then fl:=not StrToBoolean(Cells[Col,Row]);
      if fl then Cells[Col,Row]:=bStr[not StrToBoolean(Cells[Col,Row])];
      if (Key=K_Ins) and (Row<RowCount-1) then IncRow;
    end
    else begin
      ColRowToXY(X,Y); lSel := Key in [K_F2,K_Plus];
      if Ask([HeadX[X]+':',amsSel[lSel]+' ?']) then begin
        s:=bStr[lSel];
        for Y:=0 to HeadY.Count-1 do DatCells[X,Y]:=s;
      end;
    end;
    if fl then tf.Change(ov,false);
  end;
  DelStack;
end;

function TTblChkGet.MayDoKey;
begin
  AddStack('TTblChkGet.MayDoKey',Self);
  result := inherited MayDoKey(tf,Key);
  if result then
    if AssignObj(tf) then
      if not Assigned(bDyn) then case Key of
        K_PgUp,K_Up: result := tbl.Row<=tbl.FixedRows;
        K_PgDn,K_Down: result := tbl.Row>=tbl.RowCount-1;
      end;
  DelStack;
end;

function TTblChkGet.AssignObj;
var n: byte;
begin
  AddStack('TTblChkGet.AssignObj',Self);
  result:=false; tbl:=nil;
  if inherited AssignObj(tf) then begin
    n:=IfThen(Assigned(bDyn),1);
    if tf.ComponentCount>n then result:=IsClass(tf.Components[n],TStrTable,pointer(tbl));
  end;
  DelStack;
end;

{procedure TTblChkGet.HookProc;
begin
	AddStack('TTblChkGet.HookProc',Self);
  inherited HookProc(tf,Message);
  if Message.Msg=WM_WHMIN then with tf do begin
  	if CharWidth<0 then WMin:=0;
  	if CharHeight<0 then HMin:=0;
  end;
  DelStack;
end;}

procedure TTblChkGet.Change;
var i,j,j1: longint;
	lSet,lDef: boolean;
  v,ov: string;
begin
	AddStack('TTblChkGet.Change',Self);
  if AssignObj(tf) and not noCng then
  	if StrToBoolean(DlmCopy(tf.Mask,4,1,UnDelim)) then begin
    	noCng:=true; v:=tf.Value; ov:=OldVal;
      for i:=1 to tbl.HeadX.Count do begin
      	lDef:=true;
        for j:=1 to tbl.HeadY.Count do begin
        	lSet:=GetByte(v,i,j);
          if lSet then lDef:=false;
          if lSet and not GetByte(ov,i,j) then begin
		        for j1:=1 to tbl.HeadY.Count do SetByte(v,i,j1,j=j1);
            break;
          end;
          SetByte(v,i,j,lSet);
        end;
        if lDef then for j:=1 to tbl.HeadY.Count do SetByte(v,i,j,j=1);
      end;
      tf.VarValue:=v; noCng:=false;
    end;
  inherited Change(tf,OldVal,FromShow);
  DelStack;
end;

procedure TTblChkGet.StdDWFldValue;
var Prm: TTblChkGetPrm;
  nc,nr: longint;
  s,sc: string;
begin
  AddStack('TTblChkGet.StdDWFldValue',Self);
  Prm:=Mask2Prm(Mask); s:='';
  for nc:=0 to Prm.aCol.l-1 do begin
    sc:='';
    for nr:=0 to Prm.aRow.l-1 do if GetByte(Value,nc+1,nr+1) then IncD(sc,','+Prm.aRow.a[nr]);
    if sc<>'' then IncD(s,'; '+Prm.aCol.a[nc]+':'+Copy(sc,2,MaxInt));
  end;
  Value:=Copy(s,3,MaxInt);
  DelStack;
end;

procedure TTblChkGet.DWFldValid;
var l: longint;
begin
	AddStack('TTblChkGet.DWFldValid',Self);
  inherited DWFldValid(ap,dwInf,nFldFocus,nVarFocus,amsg);
  if (Length(amsg)=0) and not IsDWFldMemo(dwInf.AType) then begin
  	with Mask2Prm(ap[deMask]) do l:=aCol.l*(aRow.l+lTblChkDlmVal)-lTblChkDlmVal;
    if l>dwInf.Len then begin
    	AddFrom(amsg,[BracketInt('Длина поля для указанного количества строчек и столбцов',l),
      	BracketInt('превышает длину данного',dwInf.Len)+'.']);
      nFldFocus:=deNameRecFld;
    end;
  end;
  DelStack;
end;

function TTblChkGet.DWFldUnAllowType;
begin
  result:=[low(aDWFld)..high(aDWFld)]-[dwtString,dwtMemo,dwtManyStr];
end;

class function TTblChkGet.Mask2Prm;
var ap: array[1..4] of string;
begin
  AddStack('TTblChkGet.Mask2Prm');
  LsArrFill(Mask,ap,UnDelim);
  with result do begin
    Capt:=ap[1]; Col1:=StrToBoolean(ap[4]);
    with aCol do l:=LsArrDynamic(ap[2],a,mniDlm);
    with aRow do l:=LsArrDynamic(ap[3],a,mniDlm);
  end;
  DelStack;
end;

function TTblChkGet.MaskTrans;
var gh: longint;
begin
	AddStack('TTblChkGet.MaskTrans');
	if MyVarType(av)=varArray
  then result:=ArrayAsList([av[2],StrTran(TrimRight(av[5]),CRLF,mniDlm),StrTran(TrimRight(av[6]),CRLF,mniDlm),
    Bool2Str(av[3])],UnDelim)
  else begin
  	gh:=longint(TTblChkHeadGet.CreateOne);
    with Mask2Prm(av) do result:=ArrVarToVar(
      [VarArrayOf([mpMulti,'',false,true])
      ,VarArrayOf([mpEdit,'Заголовок',Capt,wallNoSay])
      ,VarArrayOf([mpBool,'Отмечать только одно значение в столбце',Col1])
      ,VarArrayOf([mpMulti,'',false,true,true,longint(TTblChkHeadMultiGet.CreateOne)])
      ,VarArrayOf([mpCustom,'',ArrayAsList(aCol.a,CRLF,aCol.l),gh,',,,,Наименования столбцов'])
      ,VarArrayOf([mpCustom,'',ArrayAsList(aRow.a,CRLF,aRow.l),gh,',,,,Наименования строк'])
      ]);
  end;
  DelStack;
end;

procedure TTblChkGet.MaskPrn;
begin
	AddStack('TTblChkGet.MaskPrn',Self);
  with Mask2Prm(Mask) do begin
    if not empty(Capt) then LsPrn.Add('Заголовок: '+Capt);
    if Col1 then LsPrn.Add('Отмечать только одно значение в столбце');
    with aCol do if l>0 then LsPrn.Add('Столбцы: '+ArrayAsList(a,',',l));
    with aRow do if l>0 then LsPrn.Add('Строки: ' +ArrayAsList(a,',',l));
  end;
  DelStack;
end;

procedure TTblChkGet.MaskFrmShow;
begin
	AddStack('TTblChkGet.MaskFrmShow',Self);
  EdMaskFld(5).IncOptions([],[ogAutoSize]);
  EdMaskFld(6).IncOptions([],[ogAutoSize]);
  DelStack;
end;

class function TTblChkGet.MaskTextReadOnly;
begin
	result:=true;
end;

class function TTblChkGet.DDatSupport;
begin
  result:=true;
end;

class procedure TTblChkGet.FMaskView;
	function Str1(const s,zgl: string): string;
  begin
    AddStack('TTblChkGet.FMaskView.Str1');
    result:=IfThen(not empty(s),zgl+':')+s;
    DelStack;
  end;
begin
	AddStack('TTblChkGet.FMaskView');
  with Mask2Prm(Mask) do Mask:=DlmBetween([Str1(Capt,'Заголовок'),
  	Str1(ArrayAsList(aCol.a,',',aCol.l),'Столбцы'),
  	Str1(ArrayAsList(aRow.a,',',aRow.l),'Строки')],';');
  DelStack;
end;

procedure TTblChkGet.FMaskHelp;
const Dlm = '+"'+UnDelim+'"+;';
var n: byte;
begin
  AddStack('TTblChkGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+6);
  Inc(n); CopyFrom(ht.Dat[n],HelpStruct(['Загол','Столбцы','Строки','ОтмСтб1']));
  Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr('«Заголовок»')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpArrayAsList('«Наименования столбцов»','"'+mniDlm+'"')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpArrayAsList('«Наименования строк»','"'+mniDlm+'"')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpBool('«Отмечать только одно значение в столбце»')+Dlm);
  DelStack;
end;

class function TTblChkGet.GetCodY;
begin
  result:=n+1;
end;

class procedure TTblChkGet.tblDrawCell;
begin
	AddStack('TTblChkGet.tblDrawCell');
  if not(gdFixed in State) then TStrTable(Sender).bmCheckPaint(ACol,ARow,bTrue);
  DelStack;
end;

class procedure TTblChkGet.tblHeadWHCalc;
var i,w: longint;
begin
  AddStack('TTblChkGet.tblHeadWHCalc');
  w:=bmCheckSize.cx+2;
  with TStrTable(Sender) do for i:=FixedCols to ColCount-1 do MaxColWidths(i,w);
  DelStack;
end;

{ TTblChkHeadMultiGet }
constructor TTblChkHeadMultiGet.Create;
begin
	AddStack('TTblChkHeadMultiGet.Create',Self);
	Inherited Create(AOwner);
  RVid:='';
  DelStack;
end;

procedure TTblChkHeadMultiGet.PlaceControls;
begin
  AddStack('TTblChkHeadMultiGet.PlaceControls',Self);
	RspColRow(tf,2);
  DelStack;
end;

{ TTblChkHeadGet }
constructor TTblChkHeadGet.Create;
begin
	AddStack('TTblChkHeadGet.Create',Self);
	Inherited Create(AOwner);
  RVid:='';
  DelStack;
end;

function TTblChkHeadGet.MayDoKey;
var p: longint;
  s: string;
  i: byte;
begin
  AddStack('TTblChkHeadGet.MayDoKey',Self);
  if Key=K_Enter then begin // Можно только на последнем символе, если перед ним CRLF
    result:=false;
    if AssignObj(tf) then begin
      p:=tm.GetCurrentPos;
      if p=tm.GetTextLength then
        if p=0 then result:=true
        else if p>=lCRLF then begin
          s:=CRLF;
          for i:=1 to lCRLF do s[i]:=Chr(tm.GetCharAt(p-lCRLF-1+i));
          result := s=CRLF;
        end;
    end;
  end
  else result:=inherited MayDoKey(tf,Key);
  DelStack;
end;

{ TNone }
class procedure TNone.tblBeforeDrawCell;
var tf: TFldEdit;
begin
	AddStack('TNone.tblBeforeDrawCell');
  with TStrTable(Sender) do if gdSelected in State then begin
    tf:=pointer(Owner);
    if not tf.Active then begin
      Canvas.Brush.Color:=Color; Canvas.Font.Assign(Font);
    end;
  end;
  DelStack;
end;

procedure DWFldDefaultProc(const r: TDWVidRec; var ap: TDEPrmStr);
begin
  AddStack('ChkGets.DWFldDefaultProc');
  if r.AType=dwtBool then begin
    ap[deMask]:=ap[deCaption]; ap[deCaption]:=''; TBoolGet.AssignGetClass(ap);
  end;
  DelStack;
end;

procedure DDatLsProc(var result: boolean; Sender: TObject; op: TDDatLsOper; p: pointer = nil);
begin
  AddStack('ChkGets.DDatLsProc');
  case op of
    ddoBeforeShow: begin
      result:=true; BoolMultiDDat:=true;
    end;
    ddoHide: begin
      result:=true; BoolMultiDDat:=true;
    end;
  end;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TBoolGet,TBoolDrwGet,TBoolMultiGet,TRadioGet,TTblChkGet]);
end;

initialization
	AddStack('ChkGets.initialization');
  AddFrom(DWFldDefaultProc);
  AddFrom(DDatLsProc);
  DelStack;
end.
