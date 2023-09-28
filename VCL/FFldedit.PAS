unit FFldedit;

interface

{$I LIBTEST}
uses
  Windows,Messages,Classes,Graphics,Controls,StdCtrls,PaintCtl,
  MyTypes,FldMask,FPanel,RecVal,RecDB,Schem,DDProc;

type
	TFldEdit = class;

  TMaskTransEvent = procedure(const av: variant; r: TCustomRec; const nmf: string;
  	var result: variant) of object;

  TLogCompareEvent = procedure(tf: TFldEdit; var Prm: TLogTrnsValPrm) of object;

  TDWFldValueEvent = procedure(Sender: TObject; r: TCustomRec; const Mask: string; var Value: variant) of object;
  TDWFldInfoEvent = procedure(Sender: TObject; const Mask: string; var FldInfo: TDWFldInfo) of object;
  TDWFldCanSummEvent = function(Sender: TObject; const Value: variant): boolean of object;
	TDWFldUnAllowTypeEvent = procedure(Sender: TObject; const Mask: string; const dwInf: TDWVidRec;
    var UnAllowType: TDWFldSetType; var aMsgErr: TArrStr) of object;

  TMaskHelpEvent = procedure(Sender: TObject; var mh: TMaskHelp; var ht: THelpTbl) of object;

	TCustomGetClass = class of TCustomGet;

  PCustomGet = ^TCustomGet;
	TCustomGet = class(TComponent)
  private
  	FVName: string;
    FRVid: TRVid;
    FRVName: TRVName;
    FSelCodeGet: TCustomGet;
    FOnChange: TFEChangeEvent;
    FOnCheck: TProcValid;
    FOnDWFldInfo: TDWFldInfoEvent;
    FOnDWFldValue: TDWFldValueEvent;
    FOnDWFldCanSumm: TDWFldCanSummEvent;
    FOnDWFldUnAllowType: TDWFldUnAllowTypeEvent;
    FOnExit,FOnEnter,FOnReCreateObj: TNotifyEvent;
    FOnMaskTrans: TMaskTransEvent;
    FOnMaskHelp: TMaskHelpEvent;
    FOnLogCompare: TLogCompareEvent;
    procedure SetVName(const Value: string);
    procedure PaintObjCheck(tf: TFldEdit);
    procedure LsAdd(const msg: string);
    procedure LsDel(const msg: string);
   	procedure ProcKey(Key: longint; tw: TWinControl);
  protected
    procedure CreateObj(tf: TFldEdit); virtual;
    class procedure DestroyObj(tf: TFldEdit);
    procedure ReCreateObj(tf: TFldEdit); virtual;
    procedure PaintObj(tf: TFldEdit); virtual; abstract;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; virtual;
    class procedure DefSize(var result: TSize);
    function GetValue(tf: TFldEdit): string; virtual;
    procedure SetValue(tf: TFldEdit; const v: string); virtual;
    function Check(tf: TFldEdit): boolean; virtual;
    procedure DoEnter(tf: TFldEdit); virtual;
    procedure DoExit(tf: TFldEdit); virtual;
    function MayDoKey(tf: TFldEdit; Key: longint): boolean; virtual;
    function FromCalc(tf: TFldEdit; d: Double; X,Y: longint): boolean; virtual;
		procedure Rebuild(tf: TFldEdit); virtual;
    function AssignObj(tf: TFldEdit): boolean; virtual;
    function AssignObjOwner(Sender: TObject): boolean;
		procedure DispValue(tf: TFldEdit); virtual;
    function ReAssign(const Mask: string): TCustomGet; virtual;
    procedure HookProc(tf: TFldEdit; var Message: TMessage); virtual;
    procedure Change(tf: TFldEdit; const OldVal: variant; FromShow: boolean); virtual;
		procedure ReadFirst(tf: TFldEdit); virtual;
		procedure UpdateRec(tf: TFldEdit; Oper: TFEUpdateOper); virtual;
    procedure UpdateAllFld(nOper: TUpdateFldList);
    procedure Write(tf: TFldEdit); virtual;
    procedure MaskFrmShow(Sender: TObject); virtual;
		function SelProcKey(tf: TFldEdit; Proc: TSelProcKey): boolean; virtual;
		function DWFldUnAllowType(const Mask: string): TDWFldSetType; virtual;
		procedure Paint(tf: TFldEdit); virtual;
    function MinSize(tf: TFldEdit): TSize; virtual;
    procedure MouseDown(tf: TFldEdit; Button: TMouseButton; Shift: TShiftState; X,Y: longint); virtual;
    class procedure MaskEdExit(Sender: TObject); virtual;
    class procedure MaskEdChange(Sender: TObject; const OldVal: variant; FromShow: boolean); virtual;
    class function MaskEdCheck(Sender: TObject): boolean; virtual;
    class function MaskPnlValid(Sender: TObject): boolean; virtual;
  	class function MaskSortMode: TSortMode; virtual;
    class procedure FMaskView(var Mask: string); virtual;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); virtual;
  	class function RestValType: TGetRestValType; virtual;
    function GetSelCodeGet: TCustomGet; virtual;
		function DWFldSelCodeGetValid(Sender: TCustomGet; const dwInf: TDWVidRec;
    	var nFldFocus: TDEPrmList; var nVarFocus: TVarParam; var amsg: TArrStr): boolean; virtual;
		procedure GetPaintCtlActive(Sender: TObject; tf: TFldEdit; var result: boolean); virtual;
    property OnMaskTrans: TMaskTransEvent read FOnMaskTrans write FOnMaskTrans;
    property OnMaskHelp: TMaskHelpEvent read FOnMaskHelp write FOnMaskHelp;
	public
    bDyn: TPaintButton;
  	property VName: string read FVName write SetVName;
   	property RVid: TRVid read FRVid write FRVid;
   	property RVName: TRVName read FRVName write FRVName;
		constructor Create(AOwner: TComponent = nil); override;
    destructor Destroy; override;
		function MaskProp(const Capt: TCaption; var Mask: string;
    	r: TCustomRec; const nmf: string; Opt: TMaskPropOpt = []): boolean; virtual;
		function DoMaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; dynamic;
		procedure MaskPrn(const Mask: string; LsPrn: TStringList); virtual;
		procedure DWFldInfo(const Mask: string; var FldInfo: TDWFldInfo); dynamic;
		procedure StdDWFldInfo(const Mask: string; var FldInfo: TDWFldInfo); virtual;
		procedure DWFldValue(r: TCustomRec; const Mask: string; var Value: variant); dynamic;
		procedure StdDWFldValue(r: TCustomRec; const Mask: string; var Value: variant); virtual;
		procedure DWFldValid(const ap: TDEPrmStr; const dwInf: TDWVidRec;
    	var nFldFocus: TDEPrmList; var nVarFocus: TVarParam; var amsg: TArrStr); virtual;
		function DWFldCanSumm(const Value: variant): boolean; dynamic;
		function StdDWFldCanSumm(const Value: variant): boolean; virtual;
		procedure AfterActiveDefEdit(tf: TFldEdit); virtual;
    function DynButSize: TSize;
		class function DefRelation: TFldRelation; virtual;
		function MaskEdProc(const Capt: TCaption; var Mask: string;
    	r: TCustomRec; const nmf: string; lSearch: boolean): variant; virtual;
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; virtual;
    class function MaskTextReadOnly: boolean; virtual;
    class function MaskCngClear: boolean; virtual;
    class procedure MaskView(var Mask: string);
  	function MaskSearch(const Mask,SubStr: string; lIdent: boolean): boolean; virtual;
		function MaskReplace(var Mask: string; const stSource,sRepl: string;
    	lIdent: boolean; PrRepl: TReplaceProc; pav: PVariant): longint; virtual;
    function MaskHelp(var mh: TMaskHelp): boolean;
    function MaskReadOnly: boolean; virtual;
    function DDGetHint(const kv: string; inf: PDDatKvInfo; r: TCustomRec; dd: TDynamicDat;
      const Mask: string): string;
  	class function DDatSupport: boolean; virtual;
  	class function DDatPaintPeriod: boolean; virtual;
    class procedure FldDefault(const r: TDWVidRec; var a: TDEPrmStr); virtual;
    procedure Assign(Source: TPersistent); override;
    class procedure UpdateAllGet(GetClass: TCustomGetClass; nOper: TUpdateFldList);
    class procedure GetListVid(ls: TStringList);
    class procedure GetListVName(ls: TStringList; const NameClass: string);
    class function CreateOne: TCustomGet; overload;
    class function CreateOne(var Sender: TCustomGet; AOwner: TComponent): TCustomGet; overload;
    class function GetFirst: TCustomGet;
    procedure AssignGet(var aPrm: TDEPrmStr); overload;
    procedure AssignGet(var aPrm: TDEPrmVar); overload;
    class procedure AssignGetClass(var aPrm: TDEPrmStr; const VName: string = ''); overload;
    class procedure AssignGetClass(var aPrm: TDEPrmVar; const VName: string = ''); overload;
  	procedure LogCompare(tf: TFldEdit; var Prm: TLogTrnsValPrm); virtual;
		procedure UpdateArr(r: TRecDBDef; const ap: TDEPrmStr; Oper: TFEUpdateOper); virtual;
    function SelCodeGetMask(const Mask: string): TCustomGet; virtual;
    class procedure DePrmTrans(var a: TDEPrmStr); virtual;
  published
    property SelCodeGet: TCustomGet read GetSelCodeGet write FSelCodeGet;
   	property OnChange: TFEChangeEvent read FOnChange write FOnChange;
	 	property OnCheck: TProcValid read FOnCheck write FOnCheck;
	 	property OnDWFldInfo: TDWFldInfoEvent read FOnDWFldInfo write FOnDWFldInfo;
	 	property OnDWFldValue: TDWFldValueEvent read FOnDWFldValue write FOnDWFldValue;
	 	property OnDWFldCanSumm: TDWFldCanSummEvent read FOnDWFldCanSumm write FOnDWFldCanSumm;
	 	property OnDWFldUnAllowType: TDWFldUnAllowTypeEvent read FOnDWFldUnAllowType write FOnDWFldUnAllowType;
	 	property OnEnter: TNotifyEvent read FOnEnter write FOnEnter;
	 	property OnExit: TNotifyEvent read FOnExit write FOnExit;
    property OnLogCompare: TLogCompareEvent read FOnLogCompare write FOnLogCompare;
	 	property OnReCreateObj: TNotifyEvent read FOnReCreateObj write FOnReCreateObj;
  end;

  PArrOfGet = ^TArrOfGet; TArrOfGet = array of TCustomGet;

	TSimpleGet = class(TCustomGet)
  private
		procedure ProcKey(key: longint; tw: TWinControl);
	 	function LenFld(tf: TFldEdit): longint;
  protected
   	tm: TFldMask;
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
		procedure DispValue(tf: TFldEdit); override;
		procedure HookProc(tf: TFldEdit; var Message: TMessage); override;
		function SelProcKey(tf: TFldEdit; Proc: TSelProcKey): boolean; override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
  public
		constructor Create(AOwner: TComponent); override;
  	class function DDatSupport: boolean; override;
  published
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

	TNumGet = class(TSimpleGet)
  private
	 	procedure tmKeyPress(Sender: TObject; var Key: Char);
  protected
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
		function DWFldUnAllowType(const Mask: string): TDWFldSetType; override;
		class function MaskEdCheck(Sender: TObject): boolean; override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
  public
		constructor Create(AOwner: TComponent); override;
		procedure MaskPrn(const Mask: string; LsPrn: TStringList); override;
		procedure StdDWFldInfo(const Mask: string; var FldInfo: TDWFldInfo); override;
		procedure StdDWFldValue(r: TCustomRec; const Mask: string; var Value: variant); override;
		procedure DWFldValid(const ap: TDEPrmStr; const dwInf: TDWVidRec;
    	var nFldFocus: TDEPrmList; var nVarFocus: TVarParam; var amsg: TArrStr); override;
		function StdDWFldCanSumm(const Value: variant): boolean; override;
    class procedure DePrmTrans(var a: TDEPrmStr); override;
  published
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

	TWMGetChanged = record
   	Msg: longint;
    nOper: TUpdateFldList;
		Get: TCustomGet;
    Result: LongInt;
	end;

  TChangeObjProc = procedure(const av: array of variant) of object;

	TFldEdit = class(TCustomRbPanel)
  private
	{ Private declarations }
	 	FCharCase: TEditCharCase;
	 	FDimNm: array[1..2] of string;
    FMask,FValue,FVid,FVName,FOldValue: string;
    FMaxLength,FCharWidth,FCharHeight: longint;
    FOptions: TGetOptions;
    FFocusControl: TWinControl;
    FOnAfterExit: TNotifyEvent;
	 	FOnCheck: TProcValid;
    FOnChange: TFEChangeEvent;
    Fcurget: TCustomGet;
    FRelation: TFldRelation;
    FSelected,FActive,FWasChanged,CanRedraw,lFromShow,NoCanWrite: boolean;
		procedure SetCurGet(v: TCustomGet);
	 	//procedure DsgnNmAssign;
	 	//procedure NmAssign;
    function GetDimNm(Index: longint): string;
    function GetValue: string;
		function GetVarValue: variant;
    procedure SetActive(v: boolean);
    procedure SetCharCase(v: TEditCharCase);
    procedure SetDimNm(Index: longint; const v: string);
    procedure SetMask(const v: string);
    procedure SetMaxLength(v: longint);
    procedure SetOptions(v: TGetOptions);
    procedure SetRelation(v: TFldRelation);
		procedure SetSelected(v: boolean);
	 	procedure SetValue(const v: string);
		procedure SetVarValue(const v: variant);
    procedure SetVid(const v: string);
    procedure SetVName(const v: string);
    procedure FNameGet;
	 	procedure DispValue;
		procedure FSetFocus;
		procedure ChangeObj(Proc: TChangeObjProc; const av: array of variant);
		procedure FAssignGet(const av: array of variant);
		procedure FWMGetChanged(const av: array of variant);
    procedure SetTabStop;
    procedure FldActive(After: boolean);
		procedure FCurGetExit;
    class function IsDynamic(const NameRec: string; var vid: longint): boolean; overload;
    class procedure DynClick(Sender: TObject);
		//procedure G1ProcKey(Key: longint; tw: TWinControl);
    //procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
		procedure WMGetChanged(var msg: TWMGetChanged); message WM_GETCHANGED;
		procedure WMFld(var msg: TWMFld); message WM_FLD;
  	procedure WMRebuild(var Message: TWMRebuild); message WM_REBUILD;
		procedure WMChar(var Message: TMessage); message WM_CHAR;
		procedure WMSetFocus(var Message: TMessage); message WM_SETFOCUS;
		procedure WMKeyDown(var Message: TMessage); message WM_KEYDOWN;
    procedure WMLButtonDblClk(var Message: TMessage); message WM_LBUTTONDBLCLK;
		procedure WMSetRedraw(var Message: TWMSetRedraw); message WM_SETREDRAW;
    procedure WMSchem(var msg: TMessage); message WM_SCHEM;
  	procedure WMApplHint(var Msg: TWMApplHint); message WM_APPLHINT;
    procedure WMPSort(var Message: TWMPSort); message WM_PSORT;
  	procedure WMGetDlgCode(var Msg: TWmGetDlgCode);	message wm_GetDlgCode;
    procedure WMPaintCtl(var Message: TWMPaintCtl); message WM_PAINTCTL;
    //procedure WMActForm(var Msg: TWMActForm); message WM_ACTFORM;
    procedure WMFromCalc(var Message: TWMFromCalc); message WM_FROMCALC;
    procedure WMPlaceToCtrl(var Message: TMessage); message WM_PLACETOCTRL;
		procedure WMHelpFill(var Message: TMessage); message WM_HELPFILL;
    property Selected: boolean read FSelected write SetSelected;
  protected
	{ Protected declarations }
		//procedure CreateWnd; override;
    procedure Loaded; override;
		procedure Notification(AComponent: TComponent; Operation: TOperation); override;
		procedure SetParent(AParent: TWinControl); override;
		procedure Paint; override;
		procedure Click; override;
    procedure DblClick; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: longint); Override;
		function GetPaintCtlActive(Sender: TObject): boolean; override;
    procedure DoChange(const oldv: variant; FromShow: boolean); dynamic;
  public
	{ Public declarations }
	 	PNameRec: TCustomRec;
	 	PNameRecFld: TFld;
    NameRecDynRdb: string;
    property Canvas;
    property curget: TCustomGet read FCurGet write SetCurGet;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BorderStyle;
  	property Active: boolean read FActive write SetActive;
    property OldValue: string read FOldValue write FOldValue;
    property Relation: TFldRelation read FRelation write SetRelation;
    property WasChanged: boolean read FWasChanged;
	 	constructor Create(AOwner: TComponent); override;
	 	destructor Destroy; override;
	 	procedure DoEnter; override;
	 	procedure DoExit; override;
	 	procedure SetBounds(ALeft,ATop,AWidth,AHeight: longint); override;
		//procedure Invalidate; override;
		procedure SetFocus; override;
    function SetWHMin(tp: TCustomRbPanel; wm: longint): boolean; override;
    procedure CreateObj;
    procedure ReCreateObj;
    function DestroyObj: boolean;
    procedure Read(Opt: TFEReadOpt = []); overload;
    class procedure Read(Opt: TFEReadOpt; const a: array of TFldEdit); overload;
    procedure Write;
    function ReadStr: string;
		procedure WriteStr(const v: string; AlwaysWrite: boolean = false);
		procedure UpdateRec(Oper: TFEUpdateOper);
    procedure RestOldVal;
    procedure PaintObj;
    procedure FldMaskBorder(Sender: TControl);
    function MayDoKey(Key: longint): boolean;
	 	function Check: boolean; dynamic;
    function Color1(ts: TSchem): TColor; overload;
    function Color1: TColor; overload;
	 	function LenFld(Def: longint; UserMask: boolean = false;
    	const msk: string = ''): longint;
	 	function DecFld: longint;
    procedure AssignGet(cg: TCustomGet; lBound: boolean = false); overload;
		function AssignGet(const v: string = ''; const vn: string = ''; lBound: boolean = false): TCustomGet; overload;
		function AssignGet(g: TCustomGetClass): TCustomGet; overload;
    procedure AssignGetDef(cg: TCustomGet = nil);
		//procedure Get1Fld(p: TPoint; tc: TControl);
		function SetReadOnly(Value: boolean; opt: TGetOptions = [ogReadOnly]): boolean; overload;
    function SetReadOnly(Value: boolean; opt: TGetOption): boolean; overload;
		class procedure SetReadOnly(const atf: array of TFldEdit; Value: boolean; opt: TGetOptions = [ogReadOnly]); overload;
		class procedure SetReadOnly(const atf: array of TFldEdit; Value: boolean; opt: TGetOption); overload;
		function SetReadOnly(ro: boolean; const Value: variant; opt: TGetOptions = [ogReadOnly]): boolean; overload;
		procedure SetReadOnlyNoVsbl(opt1,opt2: TGetOptions);
    procedure IncOptions(Incl: TGetOptions; Excl: TGetOptions = []);
		function NoPaintObj: boolean; overload;
		class function NoPaintObj(Options: TGetOptions): boolean; overload;
		procedure SetActiveControl;
		function DefRelation: TFldRelation;
		procedure CurGetEnter;
		procedure CurGetExit(OnlySelf: boolean = false);
    procedure Change(const oldv,newv: variant; FromShow: boolean); overload;
    procedure Change(const oldv: variant; FromShow: boolean); overload;
    function SizeAuto: TSize;
    function SeekFld: boolean;
    function PrMaxLength(Sender: TObject): longint;
    procedure DsgnNameGet;
    procedure PNameRecClr;
    class function IsDynamic(const NameRec: string): boolean; overload;
    function IsDynamic(OnlyEdited: boolean = true): boolean; overload;
    function IsDynamic(var vid: longint; OnlyEdited: boolean = true): boolean; overload;
  	function RestValType: TGetRestValType;
    function DynButCreate: TPaintButton;
    function AssignObj: boolean;
    function DynCaptSize(h: longint): TSize;
    procedure VarBlankSelf;
    procedure VarMinSelf(const d2: TDateTime);
    procedure VarMaxSelf(const d2: TDateTime);
    function DWVarName(var nmVar: string; lMsg: boolean = false): boolean; overload;
    function DWVarName: string; overload;
    procedure ValueRepeat;
    class function GetStrValue(Sender: TObject): string;
    class procedure SetStrValue(Sender: TObject; const Value: string);
    class function NoEmpValue(Sender: TObject): boolean;
		function CaptWidth(ts: TSchem; const Caption: TCaption): longint;
    function CaptHeight(ts: TSchem): longint;
    function CharCheck(cInvalid: char = ','): boolean;
    //procedure SetRdw(tw: TWinControl);
	 	procedure EdClick(Sender: TObject);
	 	procedure EdDblClick(Sender: TObject);
	 	procedure EdKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
	 	procedure EdKeyPress(Sender: TObject; var Key: Char);
	 	procedure EdKeyUp(Sender: TObject; var Key: Word;
    	Shift: TShiftState);
    procedure EdMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
    procedure EdMouseMove(Sender: TObject; Shift: TShiftState; X,Y: longint);
    procedure EdMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
   	property VarValue: variant read GetVarValue write SetVarValue;
  published
	{ Published declarations }
	 	property CharCase: TEditCharCase read FCharCase write SetCharCase;
	 	property CharWidth: longint read FCharWidth write FCharWidth;
	 	property CharHeight: longint read FCharHeight write FCharHeight;
	 	property FocusControl: TWinControl read FFocusControl write FFocusControl;
	 	property Mask: string read FMask write SetMask;
	 	property MaxLength: longint read FMaxLength write SetMaxLength;
	 	property NameRec: string index 1 read GetDimNm write SetDimNm;
	 	property NameRecFld: string index 2 read GetDimNm write SetDimNm;
	 	property Options: TGetOptions read FOptions write SetOptions
			default [ogAutoSelect,ogAutoSize];
   	property Value: string read GetValue write SetValue;
   	property Vid: string read FVid write SetVid;
   	property VName: string read FVName write SetVName;
	 	property OnAfterExit: TNotifyEvent read FOnAfterExit write FOnAfterExit;
	 	property OnCheck: TProcValid read FOnCheck write FOnCheck;
   	property OnChange: TFEChangeEvent read FOnChange write FOnChange;
    { Унаследованные }
    property ParentShowHint;
    property ShowHint;
	 	property DragCursor;
	 	property DragMode;
	 	property Enabled;
	 	property PopupMenu;
    property SayCaption;
    property SayRight;
	 	property TabOrder;
	 	property TabStop;
   	property Visible;
	 	property OnClick;
   	property OnDblClick;
	 	property OnDragDrop;
	 	property OnDragOver;
   	property OnEndDrag;
   	property OnEnter;
   	property OnExit;
   	property OnKeyDown;
   	property OnKeyPress;
   	property OnKeyUp;
	 	property OnMouseDown;
	 	property OnMouseMove;
	 	property OnMouseUp;
    property OnResize;
	end;

  PArrFldEdit = ^TArrFldEdit; TArrFldEdit = array of TFldEdit;
  TArrArrFldEdit = array of TArrFldEdit;
  TArrBoolFldEdit = array[boolean] of TFldEdit;

	TWMFldVar = record
   	Msg: longint;
    Fld: TFldEdit;	{ mgCreate,mgDestroy,mgReCreate }
		nmVar: PString;
    result: LongInt;
	end;

	TChildFldProc = procedure(Sender: TFldEdit; const av: array of variant);

  TNameGetProc = procedure(Sender: TCustomGet; const av: array of variant; var lBreak: boolean);

var
  LsCustomGet: TStringList;
  ActiveFldEdit: TFldEdit;
  FldLsCurRdb: TRecDBDef;
  ChildFldCreate: procedure(g: TCustomGet; const FldInfo: TDWFldInfo);
  EdMaskProp: function(const Capt: TCaption; const NameWnd: string; vSort: TSortMode; var av: variant;
    lFormWnd: boolean; EdExit: TNotifyEvent; EdChange: TFEChangeEvent;
    EdCheck,PnlValid: TProcValid; FrmShow: TNotifyEvent): boolean;
  EdMaskFld: function(Index: longint): TFldEdit;
  GetEdMaskVal: function(Index: longint): variant;
  SetEdMaskVal: procedure(Index: longint; const Value: variant);
  NumGetDWFldValue: procedure(var Value: variant; l,t: longint; var lDone: boolean);
  MaskTransProc: procedure(Sender: TObject; var av: variant);

procedure Register;
function NameGet(var g: TCustomGet; const v: string; const vn: string = ''; cg: TCustomGetClass = nil): boolean; overload;
function NameGet(var g: TCustomGet; const a: TDEPrmStr; cg: TCustomGetClass = nil): boolean; overload;
function NameGet(var g: TCustomGet; tf: TFldEdit; cg: TCustomGetClass = nil): boolean; overload;
function NameGet(var g: TCustomGet; cg: TCustomGetClass; const vn: string = ''): boolean; overload;
function NameGet(const v: string; const vn: string = ''; cg: TCustomGetClass = nil): TCustomGet; overload;
function NameGet(const a: TDEPrmStr): TCustomGet; overload;
function NameGet(tf: TFldEdit): TCustomGet; overload;
function NameGet(cg: TCustomGetClass; const vn: string = ''): TCustomGet; overload;
procedure NameGet(const v: string; Proc: TNameGetProc; const av: array of variant); overload;
function SpaceStrSelf(Sender: TObject; const nmf: string): boolean; overload;
procedure SpaceStrSelf(Sender: TObject); overload;
function KodCheck(Sender: TObject; const NmFld: string; var Chk: boolean;
  const Flt: string = ''; const cMsg: string = ''; Opt: TKodCheckOptions = [];
  ProcMsgEq: TNotifyEvent = nil; const ctbl: string = ''): boolean; overload;
function KodCheck(Sender: TObject;
  const Flt: string = ''; const cMsg: string = ''; Opt: TKodCheckOptions = [];
  ProcMsgEq: TNotifyEvent = nil; const ctbl: string = ''): boolean; overload;
function NoEmpCheck(Sender: TObject; const NmFld: string; var Chk: boolean): boolean; overload;
function NoEmpCheck(Sender: TObject; const aNmFld: array of string; var Chk: boolean): boolean; overload;
function CharCheck(Sender: TObject; const NmFld: string; var Chk: boolean; cInvalid: char = ','): boolean;
function F1GreatOrEqF2(Sender: TObject; const F1,F2: string; var Chk: boolean): boolean; overload;
function F1GreatOrEqF2(Sender: TObject; const af: TArrBoolStr; var Chk: boolean): boolean; overload;
procedure AnsiUpperCaseSelf(Sender: TObject); overload;
procedure ReAssignGet(var g: TCustomGet; const Mask: string);
function FldEditOwner(Sender: TObject): TFldEdit;
procedure FldEditOwnerSelf(var Sender: TFldEdit);
procedure ChildFldAll(Sender: TWinControl; Proc: TChildFldProc; const av: array of variant;
	OnlyVisible: boolean = true);
procedure ChildFldReadAll(Sender: TWinControl; Opt: TFEReadOpt = []);
procedure ChildFldWriteAll(Sender: TWinControl);
function GetOwnerFldEdit(tc: TComponent; NoSelf: boolean = false): TFldEdit;
procedure CopyFromArrGet(var Dest: TArrOfGet; const Source: array of TCustomGet);
procedure AddFrom(var Dest: TArrOfGet; Source: TCustomGet); overload;
procedure AddFrom(var Dest: TArrFldEdit; Source: TFldEdit); overload;
function StrToBoolean(tf: TFldEdit): boolean; overload;

implementation

uses SysUtils,Forms,ExtCtrls,DB,Variants,MaskUtils,Math,StrUtils,
  My_pr,PSort,KeyLb,FrmWnd,MulQry,Inter;

type TDynCaptStr = array[1..2] of string;

  TMaskProcList = 1..2;

var DDHintKv,DDHintCod,DDHint: string;

const aMaskProcName: array[TMaskProcList] of string = ('MaskTrans','MaskEdProc');

{ TCustomGet }
constructor TCustomGet.Create;
begin
	AddStack('TCustomGet.Create',Self);
	Inherited Create(AOwner);
  LsAdd('Create');
  DelStack;
end;

destructor TCustomGet.Destroy;
begin
	AddStack('TCustomGet.Destroy',Self);
  LsDel('Destroy');
	inherited Destroy;
  DelStack;
end;

procedure TCustomGet.LsAdd;
begin
  AddStack('TCustomGet.LsAdd',Self);
  SortStrListCreate(LsCustomGet,dupAccept).AddObject(ClassName+UnDelim+Trim(VName),Self);
  DelStack;
end;

procedure TCustomGet.LsDel;
var i: longint;
begin
  AddStack('TCustomGet.LsDel',Self);
  if Assigned(LsCustomGet) then begin
    i:=LsCustomGet.IndexOfObject(Self);
    if i>=0 then begin
	    LsCustomGet.Delete(i);
      if LsCustomGet.Count=0 then FreeAndNil(LsCustomGet);
    end;
  end;
  UpdateAllFld(mgDestroy);
  DelStack;
end;

{ Создание объектов }
procedure TCustomGet.CreateObj;
begin
	AddStack('TCustomGet.CreateObj',Self);
  tf.ReCreateObj;
  DelStack;
end;

{ Уничтожение объектов }
class procedure TCustomGet.DestroyObj;
begin
	AddStack('TCustomGet.DestroyObj');
	tf.DestroyComponents;
  DelStack;
end;

{ Переустановить свойства объектов }
procedure TCustomGet.ReCreateObj;
begin
	AddStack('TCustomGet.ReCreateObj',Self);
  IfThenNotify(FOnReCreateObj,tf);
  with tf do SetBounds(Left,Top,Width,Height);
  DelStack;
end;

function TCustomGet.SizeAuto;
begin
  DefSize(result);
end;

class procedure TCustomGet.DefSize;
begin
  WinSize(result,80,20);
end;

function TCustomGet.GetValue;
begin
  result:='';
end;

procedure TCustomGet.SetValue;
begin
end;

{ Нарисовать объекты }
procedure TCustomGet.PaintObjCheck;
  procedure HideControls(Sender: TComponent);
  var i: longint;
    tc: TControl;
  begin
    AddStack('TCustomGet.PaintObjCheck.HideControls',Self);
    with Sender do for i:=0 to ComponentCount-1 do
      if IsClass(Components[i],TControl,pointer(tc)) then tc.SetBounds(0,0,0,0) else HideControls(Components[i]);
    DelStack;
  end;
begin
	AddStack('TCustomGet.PaintObjCheck',Self);
  if tf.NoPaintObj then HideControls(tf) else PaintObj(tf);
  if Assigned(tf.PaintSay) then
  	if tf.PaintSay.Visible then {tf.Parent.Invalidate;} tf.PaintSay.Paint;
  tf.Invalidate;
  DelStack;
end;

{ Проверка корректности значения }
function TCustomGet.Check;
begin
	result:=true;
end;

procedure TCustomGet.DoEnter;
var tl: TKeyLb;
  a: TArrInt;
begin
	AddStack('TCustomGet.DoEnter',Self);
  AssignObj(tf); IfThenNotify(FOnEnter,tf);
  if FormKeyLb(tf,tl) then with tl do begin
    if Assigned(bDyn) then begin
      CopyFromInt(a,[K_F5,K_Space]); AddFromInt(a,aKeyListDown);
      SetKeys(a,'Данные','Редактировать данные',ProcKey,'customget',kmEdit);
      SetKey(K_Alt_Z,'','',nil,'customget',kmNone);
    end
    else begin
      if tf.RestValType=grvNone then SetKey(K_Alt_Z,'','',nil,'customget',kmNone);
      if (MyVarType(tf.VarValue)=varString) and SelProcKey(tf,nil) then begin
        SetKey(K_Ctrl_Up,'','Преобразовать в верхний регистр',ProcKey,'customget',kmEdit);
        SetKey(K_Ctrl_Down,'','Преобразовать в нижний регистр',ProcKey,'customget',kmEdit);
        SetKey(K_Ctrl_L,'','Сменить язык введённого текста',ProcKey,'customget',kmEdit);
      end;
    end;
    ReDrw;
  end;
  DelStack;
end;

procedure TCustomGet.DoExit;
var tl: TKeyLb;
begin
	AddStack('TCustomGet.DoExit',Self);
  if Assigned(FOnExit) and not(csDestroying in tf.ComponentState) then FOnExit(tf);
  if FormKeyLb(tf,tl) then begin
    tl.DelKey(K_All,'customget'); tl.ReDrw;
  end;
  DelStack;
end;

procedure TCustomGet.ProcKey;
var tf: TFldEdit;
begin
	AddStack('TCustomGet.ProcKey',Self);
  if ParentClass(tw,TFldEdit) then begin
    tf:=pointer(tw);
    if not(ogReadOnly in tf.Options) then case Key of
      K_Ctrl_Up: SelProcKey(tf,AnsiUpperCase);
      K_Ctrl_Down: SelProcKey(tf,AnsiLowerCase);
      K_Ctrl_L: SelProcKey(tf,CngLanguage);
    else
      if (Key in [K_F5,K_Space]) or ArrIntMatch(Key,aKeyListDown) then begin
        AssignObj(tf);
        if Assigned(bDyn) then bDyn.Click;
      end;
    end;
  end;
  DelStack;
end;

{ Можно ли выполнить клавишу }
function TCustomGet.MayDoKey;
begin
	result:=true;
end;

// Взять число из калькулятора
function TCustomGet.FromCalc;
begin
	result:=false;
end;

procedure TCustomGet.Rebuild;
begin
end;

procedure TCustomGet.UpdateAllFld;
var i: longint;
begin
	AddStack('TCustomGet.UpdateAllFld',Self);
  if Assigned(LsFldEdit) then for i:=0 to LsFldEdit.Count-1 do
  	TControl(LsFldEdit[i]).Perform(WM_GETCHANGED,byte(nOper),LongInt(Self));
  DelStack;
end;

procedure TCustomGet.Write;
begin
end;

class function TCustomGet.RestValType;
begin
	result:=grvNoAsk;
end;

procedure TCustomGet.AssignGet(var aPrm: TDEPrmStr);
begin
  AssignGetClass(aPrm,VName);
end;

procedure TCustomGet.AssignGet(var aPrm: TDEPrmVar);
begin
  AssignGetClass(aPrm,VName);
end;

class procedure TCustomGet.AssignGetClass(var aPrm: TDEPrmStr; const VName: string = '');
begin
  aPrm[deVid]:=ClassName; aPrm[deVName]:=VName;
end;

class procedure TCustomGet.AssignGetClass(var aPrm: TDEPrmVar; const VName: string = '');
begin
  aPrm[deVid]:=ClassName; aPrm[deVName]:=VName;
end;

procedure TCustomGet.LogCompare;
var s: string;
begin
  AddStack('TCustomGet.LogCompare',Self);
  if Assigned(tf) then begin
    s:=DelTrim(StrTran(tf.SayCaption,UnDelim,' '));
    if s<>'' then Prm.nm:=FLow(s);
  end;
  if Assigned(FOnLogCompare) then FOnLogCompare(tf,Prm);
  DelStack;
end;

function TCustomGet.DDGetHint;
var fD1,fD2,fZN: TField;
  ov,v: variant;
  s: string;
  q: TMulQuery;
  lsm: TMemGkList;
begin
  AddStack('TCustomGet.DDGetHint');
  with dd do if not((DDHintVid=vid) and (DDHintKv=kv) and (DDHintCod=CurCod)) then begin
    DDHintVid:=vid; DDHintKv:=kv; DDHintCod:=CurCod; DDHint:=''; SetFldLsCurVR(kv,r);
    q:=TMulQuery.CreateConnection;
    try
      q.PartSelect(tDDAT,[],GetWhere(kv),tDDAT+'.'+fDDD1);
      if q.IsRecords then begin
        fD1:=q.FindField(fDDD1); fD2:=q.FindField('D2');
        fZN:=q.FindField(aDDatZnFld[inf.tzn]); lsm:=TDynamicDat.MemCreate(q);
        StdGetState(ov,[stdgStd]);
        while not q.Eof do begin
          v:=DDStr2Var(fZN,lsm,inf); DWFldValue(r,Mask,v);
          if not DDatLsProc(q,ddoDop,@s) then s:='';
          DlmBetwSelf(DDHint,DlmBetween([TDynamicDat.Period(fD1.AsDateTime,fD2.AsDateTime,inf,false),
            VarAsType(v,varString),s],' '),CRLF);
          q.Next;
        end;
        StdGetState(ov,[stdgAfter]);
      end;
    finally
      q.Free;
    end;
  end;
  result:=DDHint;
  DelStack;
end;

class function TCustomGet.DDatSupport;
begin
  result:=false;
end;

class function TCustomGet.DDatPaintPeriod;
begin
  result:=true;
end;

class procedure TCustomGet.FldDefault;
begin
end;

procedure TCustomGet.Assign;
begin
	AddStack('TCustomGet.Assign',Self);
  if Source is TCustomGet then VName:=TCustomGet(Source).VName
	else inherited Assign(Source);
  DelStack;
end;

class procedure TCustomGet.UpdateAllGet;
var i: longint;
  g: TCustomGet;
begin
	AddStack('TCustomGet.UpdateAllGet');
  for i:=0 to LsCustomGet.Count-1 do
  	if IsClass(LsCustomGet.Objects[i],GetClass,pointer(g)) then g.UpdateAllFld(nOper);
  DelStack;
end;

class procedure TCustomGet.GetListVid;
var i,l: longint;
  s: string;
begin
	AddStack('TCustomGet.GetListVid');
	ls.Clear;
	if Assigned(LsCustomGet) then with LsCustomGet do begin
    i:=0; l:=Count;
    while i<l do begin
      s:=Objects[i].ClassName; ls.Add(s); IncD(s,UnDelim);
      repeat
        Inc(i);
        if i=l then break;
      until not AnsiStartsText(s,Strings[i]);
    end;
  end;
  DelStack;
end;

procedure PrGetListVName(Sender: TCustomGet; const av: array of variant; var lBreak: boolean);
begin
  AddStack('FFldedit.PrGetListVName');
  StringListVar(av[0]).Add(Sender.VName);
  DelStack;
end;

class procedure TCustomGet.GetListVName;
begin
	AddStack('TCustomGet.GetListVName');
	ls.Clear; NameGet(NameClass,PrGetListVName,[longint(ls)]);
  DelStack;
end;

procedure TCustomGet.SetVName;
begin
	AddStack('TCustomGet.SetVName',Self);
	if FVName<>Value then begin
  	LsDel('SetVName'); FVName:=Value; LsAdd('SetVName'); UpdateAllFld(mgCreate);
  end;
  DelStack;
end;

function TCustomGet.GetSelCodeGet;
begin
  result:=FSelCodeGet;
end;

function TCustomGet.SelCodeGetMask;
begin
  result:=GetSelCodeGet;
end;

class function TCustomGet.CreateOne: TCustomGet;
begin
  AddStack('TCustomGet.CreateOne');
  if not NameGet(result,ClassName) then result:=Create(Application.MainForm);
  DelStack;
end;

class function TCustomGet.CreateOne(var Sender: TCustomGet; AOwner: TComponent): TCustomGet;
begin
  if not Assigned(Sender) then Sender:=Create(AOwner);
  result:=Sender;
end;

procedure PrGet1(Sender: TCustomGet; const av: array of variant; var lBreak: boolean);
begin
  AddStack('FFldedit.PrGet1');
  PCustomGet(longint(av[0]))^:=Sender; lBreak:=true;
  DelStack;
end;

class function TCustomGet.GetFirst;
begin
  AddStack('TCustomGet.GetFirst');
	result:=nil; NameGet(ClassName,PrGet1,[longint(@result)]);
  DelStack;
end;

class function TCustomGet.DefRelation;
begin
	result:=frNormal;
end;

procedure TCustomGet.DWFldInfo;
begin
  AddStack('TCustomGet.DWFldInfo',Self);
  if Assigned(FOnDWFldInfo) then FOnDWFldInfo(Self,Mask,FldInfo) else StdDWFldInfo(Mask,FldInfo);
  DelStack;
end;

procedure TCustomGet.StdDWFldInfo;
begin
end;

procedure TCustomGet.DWFldValue;
begin
  AddStack('TCustomGet.DWFldValue',Self);
  if Assigned(FOnDWFldValue) then FOnDWFldValue(Self,r,Mask,Value) else StdDWFldValue(r,Mask,Value);
  DelStack;
end;

procedure TCustomGet.StdDWFldValue;
begin
end;

function TCustomGet.DWFldCanSumm;
begin
	AddStack('TCustomGet.DWFldCanSumm',Self);
  if Assigned(FOnDWFldCanSumm) then result:=FOnDWFldCanSumm(Self,Value) else result:=StdDWFldCanSumm(Value);
  DelStack;
end;

function TCustomGet.StdDWFldCanSumm;
begin
  result:=false;
end;

procedure TCustomGet.DWFldValid;
var i: TDWFldType;
  a: array[boolean] of record
    a: TDWFldTypeStr;
    l: byte;
  end;
  st: TDWFldSetType;
  fl: boolean;
  aMsgErr: TArrStr;
  g: TCustomGet;
begin
	AddStack('TCustomGet.DWFldValid',Self);
  if (Length(amsg)=0) and not StrToBoolean(ap[deAddDyn]) then
    if (dwInf.SvType=dwsDyn) and not DDatSupport then begin
      AddFrom(amsg,['Вид ввода "'+RVid+'"','недопустим для динамических данных.']);
      nFldFocus:=deNameRecFld; nVarFocus:=dwvSvType;
    end
    else begin
      fl:=true;
      if dwInf.AType=dwtSel then begin
        g:=SelCodeGetMask(ap[deMask]);
        if Assigned(g) then fl:=g.DWFldSelCodeGetValid(Self,dwInf,nFldFocus,nVarFocus,amsg);
      end;
      if fl then begin
        st:=DWFldUnAllowType(ap[deMask]); aMsgErr:=nil;
        if Assigned(FOnDWFldUnAllowType) then FOnDWFldUnAllowType(Self,ap[deMask],dwInf,st,aMsgErr);
        if (Length(aMsgErr)=0) and (dwInf.AType in st) then begin
          Finalize(a); ZeroMemory(@a,SizeOf(a));
          for i:=low(aDWFld) to high(aDWFld) do with a[i in st] do begin
            Inc(l); a[TDWFldType(l)]:='"'+aDWFld[i].nm+'"';
          end;
          fl := a[true].l<=a[false].l;
          with a[fl] do AddFrom(aMsgErr,['Вид ввода "'+DlmBetween(RVid,RVName,': ')+'" '
            +IfThen(fl,'недопустим','допустим только')+' для данных',
            'типа '+DlmBetween(ArrayAsList(a,', ',l-1),a[TDWFldType(l)],' или ')+'.']);
        end;
        if Length(aMsgErr)>0 then begin
          AddFrom(amsg,aMsgErr); nFldFocus:=deNameRecFld; nVarFocus:=dwvType;
        end;
      end;
    end;
  DelStack;
end;

function TCustomGet.DWFldSelCodeGetValid;
begin
  result:=true;
end;

function TCustomGet.DWFldUnAllowType;
begin
  result:=[];
end;

procedure TCustomGet.GetPaintCtlActive;
begin
end;

procedure TCustomGet.Paint;
begin
end;

function TCustomGet.MinSize;
begin
  ZeroMemory(@result,SizeOf(result));
end;

procedure TCustomGet.MouseDown;
begin
end;

function TCustomGet.SelProcKey;
begin
	result:=false;
end;

procedure TCustomGet.AfterActiveDefEdit;
begin
end;

function TCustomGet.MaskEdProc;
begin
	result:=null;
end;

function TCustomGet.DoMaskTrans;
begin
  AddStack('TCustomGet.DoMaskTrans',Self);
	result:=MaskTrans(av,r,nmf);
  if Assigned(FOnMaskTrans) then FOnMaskTrans(av,r,nmf,result);
  if MyVarType(result)=varArray then
    if MyVarType(result[VarArrayLowBound(result,1)])<>varArray then MaskTransProc(Self,result);
  DelStack;
end;

function TCustomGet.MaskTrans;
begin
	result:=null;
end;

procedure TCustomGet.MaskPrn;
var ms: string;
begin
	AddStack('TCustomGet.MaskPrn',Self);
  ms:=Mask; MaskView(ms);
  if not empty(ms) then LsPrn.Add(ms);
  DelStack;
end;

class procedure TCustomGet.MaskEdExit;
begin
end;

class procedure TCustomGet.MaskEdChange;
begin
end;

class function TCustomGet.MaskEdCheck;
begin
	result:=true;
end;

class function TCustomGet.MaskPnlValid;
begin
	result:=true;
end;

procedure TCustomGet.MaskFrmShow;
begin
end;

class function TCustomGet.MaskSortMode;
begin
	result:=smDefault;
end;

function TCustomGet.MaskSearch;
begin
	result:=false;
end;

function TCustomGet.MaskReplace;
begin
	result:=0;
end;

class function TCustomGet.MaskTextReadOnly;
begin
	result:=false;
end;

{class function TCustomGet.MaskReadOnly;
begin
  result:=[];
end;}

class function TCustomGet.MaskCngClear;
begin
	result:=false;
end;

class procedure TCustomGet.MaskView;
begin
  AddStack('TCustomGet.MaskView');
  if not(csDesigning in Application.ComponentState) and MaskTextReadOnly then FMaskView(Mask);
  DelStack;
end;

class procedure TCustomGet.FMaskView;
begin
end;

function TCustomGet.MaskHelp;
var ht: THelpTbl;
begin
  AddStack('TCustomGet.MaskHelp',Self);
  mh.RVid:=RVid;
  with mh do begin
    rHelpFile(hf,hlnkTbl);
    ht.Head:=RVid; ht.Dat0:=' - формат строки параметров ввода:'; SetLength(ht.Dat,1); ht.Dat[0]:=nil;
    FMaskHelp(mh,ht);
    if Assigned(FOnMaskHelp) then FOnMaskHelp(Self,mh,ht);
    if hf.sFile=Int2Str(hlnkTbl) then if Length(ht.Dat)>1 then hf.sPage:=HelpTbl2Str(ht);
    result := hf.sPage<>'';
  end;
  DelStack;
end;

function TCustomGet.MaskReadOnly;
var i: TMaskProcList;
begin
  AddStack('TCustomGet.MaskReadOnly',Self);
  if Assigned(Self) then begin
    result:=MaskTextReadOnly;
    if result then for i:=low(aMaskProcName) to high(aMaskProcName) do if Assigned(MethodAddress(aMaskProcName[i])) then begin
      result:=false; break;
    end;
  end
  else result:=true;
  DelStack;
end;

procedure TCustomGet.FMaskHelp;
begin
end;

function TCustomGet.MaskProp;
var v: variant;
begin
	AddStack('TCustomGet.MaskProp',Self);
	v:=MaskEdProc(Capt,Mask,r,nmf,mskSearch in Opt);
  if MyVarType(v)=varBoolean then result:=v
  else begin
    v:=DoMaskTrans(Mask,r,nmf);
    if MyVarType(v)=varArray then begin
      result:=EdMaskProp(Capt,ClassName+'.'+VName,MaskSortMode,v,mskFormWnd in Opt,
        MaskEdExit,MaskEdChange,MaskEdCheck,MaskPnlValid,MaskFrmShow);
      if result then Mask:=DoMaskTrans(v,r,nmf);
    end
    else result:=false;
  end;
  DelStack;
end;

function TCustomGet.DynButSize;
begin
  AddStack('TCustomGet.DynButSize',Self);
  if Assigned(bDyn) then WinSize(result,
    max(SysMetric.iScrollWidth,bDyn.Glyph.Width+4),
    max(SysMetric.iScrollHeight,bDyn.Glyph.Height+4))
  else ZeroMemory(@result,SizeOf(result));
  DelStack;
end;

{ Поиск объектов }
function TCustomGet.AssignObj;
begin
  AddStack('TCustomGet.AssignObj',Self);
	bDyn:=nil; result:=Assigned(tf);
  if result then if tf.IsDynamic then bDyn:=IsClass(tf.Components[0],TPaintButton);
  DelStack;
end;

function TCustomGet.AssignObjOwner;
begin
  AddStack('TCustomGet.AssignObjOwner',Self);
  result:=AssignObj(FldEditOwner(Sender));
  DelStack;
end;

procedure TCustomGet.DispValue;
begin
end;

function TCustomGet.ReAssign;
begin
  result:=Self;
end;

procedure TCustomGet.HookProc;
var i: longint;
begin
	AddStack('TCustomGet.HookProc',Self);
  if Message.Msg=CM_VISIBLECHANGED then begin
  	for i:=0 to tf.ComponentCount-1 do TPaintControl.ObjSetVisible(tf.Components[i],tf.Visible);
    if tf.Visible then tf.RecreateObj;
  end;
  DelStack;
end;

procedure TCustomGet.Change;
begin
  IfThenCng(FOnChange,tf,OldVal,FromShow);
end;

procedure TCustomGet.ReadFirst;
begin
end;

procedure TCustomGet.UpdateRec;
begin
end;

procedure TCustomGet.UpdateArr;
begin
end;

class procedure TCustomGet.DePrmTrans;
begin
end;

{ TSimpleGet }
constructor TSimpleGet.Create;
begin
	AddStack('TSimpleGet.Create',Self);
	Inherited Create(AOwner);
  RVid:='Обычный'; UpdateAllFld(mgCreate);
  DelStack;
end;

{ Создание объекта TFldMask }
procedure TSimpleGet.CreateObj;
begin
	AddStack('TSimpleGet.CreateObj',Self);
	DestroyObj(tf); tf.DynButCreate;
	tm:=TFldMask.Create(tf);
  with tm do begin
   	Parent:=tf; AutoSize:=false; TabStop:=false; MaxLength:=10; BorderStyle:=bsNone;
    onClick:=tf.EdClick;
    onDblClick:=tf.EdDblClick;
    onKeyDown:=tf.EdKeyDown;
    onKeyPress:=tf.EdKeyPress;
    onKeyUp:=tf.EdKeyUp;
    onMouseDown:=tf.EdMouseDown;
    onMouseMove:=tf.EdMouseMove;
    onMouseUp:=tf.EdMouseUp;
  end;
  inherited CreateObj(tf);
  DelStack;
end;

{ Переустановить свойства объекта TFldMask }
procedure TSimpleGet.ReCreateObj;
var oldv,Mask: string;
  ss,sl: longint;
begin
	AddStack('TSimpleGet.ReCreateObj',Self);
	if AssignObj(tf) then begin
    ss:=tm.SelStart; sl:=tm.SelLength;
    tm.CharCase:=tf.CharCase;
    tm.PasswordChar:=IfThenChar(ogPassword in tf.Options,'*',#0);
    tm.AutoSelect := ogAutoSelect in tf.Options; tm.TrimLeft := ogTrimLeft in tf.Options;
    Mask:=tf.Mask;
    if tm.EditMask<>Mask then begin
      oldv:=tf.FValue;
      tm.EditMask:=Mask+IfThen((Mask<>'') and (Pos(MaskFieldSeparator,Mask)=0),
        MaskFieldSeparator+'1'+MaskFieldSeparator+' ');
      tf.FValue:=oldv;
    end;
    tm.MaxLength:=LenFld(tf); tm.ReadOnly := (ogReadOnly in tf.Options) or Assigned(bDyn);
	  inherited ReCreateObj(tf);
    tm.SelStart:=ss; tm.SelLength:=sl;
  end;
  DelStack;
end;

function TSimpleGet.LenFld;
begin
  AddStack('TSimpleGet.LenFld',Self);
  result:=tf.LenFld(tm.MaxLength,true,tf.Mask);
  DelStack;
end;

{ Нарисовать объект TFldMask }
procedure TSimpleGet.PaintObj;
var ts: TSchem;
  w,wc: longint;
begin
	AddStack('TSimpleGet.PaintObj',Self);
	if AssignObj(tf) then with tf do begin
    if csDesigning in ComponentState then ts:=nil else SchemName(Schem,ts);
    tm.Color:=tf.Color1(ts); w:=DynButSize.cX; wc:=tf.DynCaptSize(tf.Height-BevelFld2).cX;
    if Assigned(ts) then tm.Font.Assign(ts.Font1);
    if Assigned(bDyn) then bDyn.SetBounds(Width-BevelFld-w,BevelFld,w,Height-BevelFld2);
    tm.SetBounds(BevelFld+2+wc,BevelFld+2,Width-BevelFld2-w-4-wc,Height-BevelFld2-4);
    if not(ogAutoSize in Options) then begin
	    tm.SelStart:=0; tm.SelLength:=0;
    end;
  end;
  DelStack;
end;

procedure TSimpleGet.Paint;
begin
  AddStack('TSimpleGet.Paint',Self);
  if AssignObj(tf) then tf.FldMaskBorder(tm);
  DelStack;
end;

{ Автоматическая установка размеров }
function TSimpleGet.SizeAuto;
var ts: TSchem;
	s: string;
  i,h: longint;
  fl: boolean;
  dsz,dcsz: TSize;
begin
	AddStack('TSimpleGet.SizeAuto',Self);
	result := inherited SizeAuto(tf,Opt);
  if not((csDestroying in ComponentState) or (csDestroying in tf.ComponentState)) then
    if AssignObj(tf) then with tf.Canvas do begin
      if not(csDesigning in ComponentState) then
        if SchemName(tf.Schem,ts) then tm.Font.Assign(ts.Font1);
      Font.Assign(tm.Font);
      if Opt<>[] then begin
        dsz:=DynButSize; h:=max(CanvasMaxH(tf.Canvas)+4,dsz.cY); dcsz:=tf.DynCaptSize(h);
        if tfszHeight in Opt then result.cY:=max(h,dcsz.cY);
        if tfszWidth in Opt then begin
          s:=tm.EditMask;
          if empty(s) then result.cX:=CanvasMaxW(tf.Canvas)*{max(2,}LenFld(tf){)}
          else begin
            fl:=false; i:=1;
            while i<=Length(s) do begin
              if fl then fl:=false
              else case s[i] of
                '0','9','#': s[i]:='0';
                '/': s[i]:=DateSeparator;
                '\': begin
                  fl:=true; Delete(s,i,1); continue;
                end;
                ':': s[i]:=TimeSeparator;
                ',': s[i]:=DecimalSeparator;
                ';': begin
                  SetLength(s,i-1); break;
                end;
                'A','a','C','c','L': s[i]:=cMaxW;
                //else s[i]:=cMaxW;
              end;
              Inc(i);
            end;
            result.cX:=TextWidth(s);
          end;
          Inc(result.cX,6+dsz.cX+dcsz.cX);
        end;
      end;
    end;
  DelStack;
end;

{ Достать значение Value из объектов }
function TSimpleGet.GetValue;
begin
	AddStack('TSimpleGet.GetValue',Self);
	AssignObj(tf); result:=IfThenGetText(tm);
  DelStack;
end;

{ Установить свойства объектов в соответствии с Value }
procedure TSimpleGet.SetValue;
var ost: longint;
	vv: string;
begin
	ost:=AddStack('TSimpleGet.SetValue',Self);
	if AssignObj(tf) then begin
    try
    	vv:=v;
      if tf.SeekFld then 
        if tf.PNameRecFld.Info.DataType in [ftInteger,ftFloat]
        then vv:=SpaceStr0(v,LenFld(tf),tf.DecFld);
      tm.Text:=TrimRight(vv); tm.SelAll;
    except
    	SetStack(ost);
    end;
  end;
  DelStack;
end;

function TSimpleGet.Check;
begin
	AddStack('TSimpleGet.Check',Self);
  result := inherited Check(tf);
  if result then
	  if AssignObj(tf) then result:=tm.Check;
  DelStack;
end;

{ Действия при получении фокуса }
procedure TSimpleGet.DoEnter;
var tl: TKeyLb;
begin
  AddStack('TSimpleGet.DoEnter',Self);
  inherited DoEnter(tf);
	if AssignObj(tf) then begin
    GetParentForm(tf).ActiveControl:=tm; tm.SelAll;
    if FormKeyLb(tf,tl) and not(ogReadOnly in tf.Options) and (Pos(DecimalSeparator,tm.EditMask)>0)
    then tl.SetKeys([K_ZPT,K_POINT],'','Перейти к дробной части',ProcKey,'defaultget',kmNone);
  end;
  DelStack;
end;

{ Действия при утере фокуса }
procedure TSimpleGet.DoExit;
var tl: TKeyLb;
begin
	AddStack('TSimpleGet.DoExit',Self);
  if FormKeyLb(tf,tl) then tl.DelKey(K_All,'defaultget');
  inherited DoExit(tf);
  DelStack;
end;

procedure TSimpleGet.ProcKey;
var p: longint;
  s: string;
begin
	AddStack('TSimpleGet.ProcKey',Self);
	if AssignObjOwner(tw) then with tm do
    if IsPos(p,DecimalSeparator,EditMask) then if SelStart<p then begin
      s:=SpaceStr0(IfThen((SelStart=0) and (SelLength=Length(Text)),'0',LeftStr(Text,p-1)),p-1);
      if AnsiStartsStr('-',SysUtils.TrimLeft(Text)) and not AnsiStartsStr('-',SysUtils.TrimLeft(s))
      then s:=Padl('-'+Trim(s),Length(s));
      Text:=s+Copy(Text,p,MaxInt); SelStart:=p; SelLength:=1;
    end;
  DelStack;
end;

// Взять число из калькулятора
function TSimpleGet.FromCalc;
begin
	AddStack('TSimpleGet.FromCalc',Self);
	tf.Value:=FloatToStr(d); result:=true;
  DelStack;
end;

{ Поиск объектов }
function TSimpleGet.AssignObj;
var n: byte;
begin
	AddStack('TSimpleGet.AssignObj',Self);
	tm:=nil; result:=false;
  if inherited AssignObj(tf) then begin
    n:=IfThen(Assigned(bDyn),1);
		if tf.ComponentCount>n then result:=IsClass(tf.Components[n],TFldMask,pointer(tm));
  end;
  DelStack;
end;

procedure TSimpleGet.DispValue;
begin
	AddStack('TSimpleGet.DispValue',Self);
  if tf.SeekFld then
    if tf.PNameRecFld.Info.DataType in [ftInteger,ftFloat]
    then tf.Value:=SpaceStr0(tf.Value,LenFld(tf),tf.DecFld);
  DelStack;
end;

procedure TSimpleGet.HookProc;
begin
	AddStack('TSimpleGet.HookProc',Self);
  inherited HookProc(tf,Message);
  case Message.Msg of
    WM_CHAR: if AssignObj(tf) then with TWMChar(Message) do
      result:=tm.Perform(WM_CHAR,CharCode,KeyData);
    WM_FLD: if TWMFld(Message).Oper in [foOpenRec,foCloseRec] then tf.RecreateObj;
  end;
  DelStack;
end;

function TSimpleGet.SelProcKey;
begin
  AddStack('TSimpleGet.SelProcKey',Self);
  result:=inherited SelProcKey(tf,Proc);
  if AssignObj(tf) then result:=tm.SelProcKey(Proc);
  DelStack;
end;

function TSimpleGet.MaskTrans;
begin
  result:=inherited MaskTrans(av,r,nmf);
end;

procedure TSimpleGet.FMaskHelp;
var n: byte;
begin
  AddStack('TSimpleGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+19);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr('!' ),'в тексте подавляются начальные пробелы; если символ '+HelpBoldStr('!')+' отсутствует, то подавляются конечные пробелы']);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr('>' ),'символы, следующие за этим символом, до появления символа '+HelpBoldStr('<')+' переводятся в верхний регистр']);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr('<' ),'символы, следующие за этим символом, до появления символа '+HelpBoldStr('>')+' переводятся в нижний регистр']);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr('<>'),'проверка регистра символов не производится']);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr('\' ),'символ, следующий за этим символом, является литеральным']);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr('L' ),'в позиции должен быть введён алфавитный символ']);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr('l' ),HelpBoldStr('(строчная латинская буква l)',SCE_OURLIB_HELP_PRIM)+' в позиции может быть введён алфавитный символ']);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr('A' ),'в позиции должен быть введён алфавитно-цифровой символ']);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr('а' ),'в позиции может быть введён алфавитно-цифровой символ']);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr('C' ),'в позиции должен быть введён символ']);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr('с' ),'в позиции может быть введён символ']);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr('0' ),'в позиции должен быть введён цифровой символ']);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr('9' ),'в позиции может быть введён цифровой символ']);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr('#' ),'в позиции может быть введён цифровой символ или знаки '+HelpBoldStr('+')+' и '+HelpBoldStr('—')]);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr(':' ),'используется для разделения часов, минут и секунд в показаниях времени']);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr('/' ),'используется для разделения дней, месяцев и лет в датах']);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr(';' ),'разделяет поля маски']);
  Inc(n); CopyFrom(ht.Dat[n],[HelpBoldStr('_' ),'оставляет в окне редактирования пустое пространство, являющееся автоматически пропускаемым разделителем, в которое нельзя ввести информацию']);
  DelStack;
end;

class function TSimpleGet.DDatSupport;
begin
  result:=true;
end;

{ TNumGet }
constructor TNumGet.Create;
begin
	AddStack('TNumGet.Create',Self);
	Inherited Create(AOwner);
  RVid:='Числовой';
  DelStack;
end;

procedure MaskPrm(const Mask: string; var l,t: longint);
var i: longint;
	s,s1: string;
begin
  AddStack('FFldEdit.MaskPrm');
  s:=Mask; i:=1; s1:=Copy(s,i,1);
  while (s1<>'9') and (s1<>'#') and (s1<>DecimalSeparator) and (i<=Length(s)) do begin
    Inc(i); s1:=Copy(s,i,1);
  end;
  Delete(s,1,i-1); i:=Length(s); s1:=Copy(s,i,1);
  while (s1<>'9') and (s1<>DecimalSeparator) and (i>0) do begin
    Dec(i); s1:=Copy(s,i,1);
  end;
  SetLength(s,i); l:=max(1,i);
  if IsPos(i,DecimalSeparator,s) then t:=l-i else t:=0;
  DelStack;
end;

function MaskFld(r: TCustomRec; const Mask,nmf: string; var l,t: longint): boolean;
var a: TArrStr;
  i: longint;
  inf: PDDatKvInfo;
begin
  AddStack('FFldEdit.MaskFld');
  result:=false;
  if empty(Mask) then
    if r is TRecDBDef then begin
      for i:=0 to LsArrDynamic(TRecDBDef(r).DWTrans,a,CRLF)-1 do with DWSToRec(a[i]) do if TrimUpper(Name)=TrimUpper(nmf) then begin
        l:=Len; t:=Dec; result:=true; break;
      end;
    end
    else if Assigned(r) then if TFldEdit.IsDynamic(r.NameRec,i) then if aDDat[i].GetKvInfo(nmf,inf) then begin
      l:=inf.Len; t:=inf.Dec; result:=true;
    end;
  DelStack;
end;

procedure TNumGet.CreateObj;
begin
	AddStack('TNumGet.CreateObj',Self);
  inherited CreateObj(tf);
  tm.onKeyPress:=tmKeyPress;
  DelStack;
end;

procedure TNumGet.ReCreateObj;
var l,t: longint;
begin
	AddStack('TNumGet.ReCreateObj',Self);
  if tf.SeekFld then
    if MaskFld(tf.PNameRec,tf.Mask,tf.NameRecFld,l,t) then tf.Mask:=MaskNum(l,t);
  inherited ReCreateObj(tf);
  DelStack;
end;

procedure TNumGet.tmKeyPress;
var tf: TFldEdit;
  l,t: longint;
begin
  AddStack('TNumGet.tmKeyPress',Self);
  tf:=FldEditOwner(Sender);
  if AssignObj(tf) then begin
    if not(IsDigit(Key) or (Key='-')
    or MaskFld(tf.PNameRec,tf.Mask,tf.NameRecFld,l,t) and (t>0) and (Key in ['.',DecimalSeparator]))
      then Key:=#0;
    tf.EdKeyPress(Sender,Key);
  end;
  DelStack;
end;

procedure TNumGet.StdDWFldInfo;
var t: longint;
  ms: string;
begin
	AddStack('TNumGet.StdDWFldInfo',Self);
  if empty(Mask) then ms:=MaskNum(FldInfo.r.Len,FldInfo.r.Dec) else ms:=Mask;
  MaskPrm(ms,FldInfo.Size,t); FldInfo.Alignment:=taRightJustify;
  DelStack;
end;

procedure TNumGet.StdDWFldValue;
var l,t: longint;
  lDone: boolean;
begin
	AddStack('TNumGet.StdDWFldValue',Self);
  if empty(Mask) then begin
    l:=FldLsCurVR.Len; t:=FldLsCurVR.Dec;
  end
  else MaskPrm(Mask,l,t);
  lDone:=true;
  if Assigned(NumGetDWFldValue) then NumGetDWFldValue(Value,l,t,lDone);
  if lDone then Spacestr0Self(Value,l,t,false);
  if LogPrimCalc then TrimSelf(Value);
  DelStack;
end;

function TNumGet.StdDWFldCanSumm;
begin
  result:=true;
end;

procedure TNumGet.DWFldValid;
var l,t: longint;
begin
	AddStack('TNumGet.DWFldValid',Self);
  inherited DWFldValid(ap,dwInf,nFldFocus,nVarFocus,amsg);
  with dwInf do if (Length(amsg)=0) and not IsDWFldMemo(dwInf.AType) then begin
    MaskPrm(ap[deMask],l,t);
    if l>Len
    then AddFrom(amsg,[BracketInt('Длина',l)+BracketInt(' превышает длину данного',Len)+'.'])
    else if (AType=dwtFloat) and (t>Dec) then begin
      AddFrom(amsg,[BracketInt('Точность',t)+BracketInt(' превышает точность данного',Dec)+'.']);
      nVarFocus:=dwvDec;
    end;
  end;
  DelStack;
end;

function TNumGet.DWFldUnAllowType;
begin
  result:=[dwtDate,dwtBool,dwtArray,dwtSel];
end;

function TNumGet.MaskTrans;
var l,t: longint;
begin
	AddStack('TNumGet.MaskTrans',Self);
	if MyVarType(av)=varArray then
  	if empty(av[1]) then result:='' else result:=MaskNum(IsNilc(av[1],0),IsNilc(av[2],0))
  else begin
  	if not MaskFld(r,av,nmf,l,t) then MaskPrm(av,l,t);
    result:=ArrVarToVar(
      [VarArrayOf([mpSpin,'Длина',l,0,99])
      ,VarArrayOf([mpSpin,'Точность',t,0,99])
      ]);
  end;
  DelStack;
end;

procedure TNumGet.MaskPrn;
var l,t: longint;
begin
	AddStack('TNumGet.MaskPrn',Self);
  MaskPrm(Mask,l,t); //LsPrn[LsPrn.Count-1]:=LsPrn[LsPrn.Count-1]+Format(' (%d.%d)',[l,t]);
  LsPrn.Add(Format('Длина: %d, точность: %d',[l,t]));
  DelStack;
end;

class function TNumGet.MaskEdCheck;
var t: longint;
begin
	AddStack('TNumGet.MaskEdCheck');
	if Sender=EdMaskFld(2) then begin
    t:=GetEdMaskVal(2); result := (t=0) or (GetEdMaskVal(1)>t+1);
  end
  else result:=true;
  DelStack;
end;

procedure TNumGet.FMaskHelp;
var n: byte;
  l,t: string;
begin
  AddStack('TNumGet.FMaskHelp',Self);
  inherited;
  n:=0; SetLength(ht.Dat,n+3); l:=HelpBoldStr('«Длина»'); t:=HelpBoldStr('«Точность»');
  Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr('ПОВТОРИТЬ','(',hlnkInterMemo)+'('+HelpIf(l+'-'+t+'<3','"9"','"#"',false)+','+l+'-'+t+'-1)+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpIf(t+'=0','"9"','","+'+HelpBoldStr('ПОВТОРИТЬ','(',hlnkInterMemo)+'("9",'+t+')',false));
  DelStack;
end;

class procedure TNumGet.DePrmTrans;
var l,t: longint;
begin
  AddStack('TNumGet.DePrmTrans');
  if MaskFld(RecName(a[deNameRec]),a[deMask],a[deNameRecFld],l,t) then a[deMask]:=MaskNum(l,t);
  DelStack;
end;

{ TFldEdit }
constructor TFldEdit.Create;
begin
	AddStack('TFldEdit.Create',Self);
	//clrmsgfile;
	//addmsgfile('Create');
	Inherited Create(AOwner);
  ListCreateObj(Self,LsFldEdit); CanRedraw:=true; ShowHint:=true; curget:=nil;
  if not(csDesigning in ComponentState) then Parent:=pointer(Owner);
  Active:=false; BevelInner:=bvNone;
  if not(csDesigning in ComponentState) then BevelOuter:=bvNone;
  BevelWidth:=BevelFld-1; BorderStyle:=bsNone; TabStop:=true;
  FOptions:=[ogAutoSelect,ogAutoSize]; FFocusControl:=nil;
  if csDesigning in ComponentState then FVid:='TSimpleGet';
  //NmAssign;
  FNameGet; 
  DelStack;
end;

destructor TFldEdit.Destroy;
begin
  AddStack('TFldEdit.Destroy',Self);
  DestroyObj;
  inherited Destroy;
  ListDestroyObj(Self,LsFldEdit);
  DelStack;
end;

procedure TFldEdit.SetParent;
var fl: boolean;
begin
  AddStack('TFldEdit.SetParent',Self);
  fl := Parent<>AParent;
  inherited SetParent(AParent);
  if Assigned(Parent) and fl then
  	if csDesigning in ComponentState then CreateObj else CurGetExit;
  DelStack;
end;

procedure TFldEdit.Notification;
var tr: TCustomRec;
begin
	AddStack('TFldEdit.Notification',Self);
	//addmsgfile('Notification');
	inherited Notification(AComponent,Operation);
  if (AComponent=FFocusControl) and (Operation=opRemove) then FFocusControl:=nil;
  if IsClass(AComponent,TCustomRec,pointer(tr)) then
  	if AnsiUpperCase(tr.NameRec)=AnsiUpperCase(NameRec) then
	  	if Operation=opRemove then PNameRecClr;
  DelStack;
end;

procedure TFldEdit.PNameRecClr;
begin
  AddStack('TFldEdit.PNameRecClr',Self);
  PNameRec:=nil; PNameRecFld:=nil; //FMaxLength:=0;
  DelStack;
end;

function TFldEdit.IsDynamic(OnlyEdited: boolean = true): boolean;
var vid: longint;
begin
  result:=IsDynamic(vid,OnlyEdited);
end;

function TFldEdit.IsDynamic(var vid: longint; OnlyEdited: boolean = true): boolean;
var inf: PDDatKvInfo;
begin
  result:=IsDynamic(NameRec,vid);
  if result and OnlyEdited then
    if aDDat[vid].GetKvInfo(NameRecFld,inf) then result := inf.td2<>dd2All;
end;

class function TFldEdit.IsDynamic(const NameRec: string): boolean;
begin
  result:=AnsiStartsText(sDyn,NameRec);
end;

class function TFldEdit.IsDynamic(const NameRec: string; var vid: longint): boolean;
begin
  AddStack('TFldEdit.IsDynamic');
  result:=IsDynamic(NameRec);
  if result then vid:=Int0(Copy(NameRec,lDyn1,MaxInt));
  DelStack;
end;

function TFldEdit.RestValType;
begin
  AddStack('TFldEdit.RestValType',Self);
	if IsDynamic then result:=grvNone else result:=curget.RestValType;
  DelStack;
end;

{procedure TFldEdit.CMFontChanged;
begin
	AddStack('TFldEdit.CMFontChanged',Self);
	//addmsgfile('CMFontChange');
	//inherited;
	SetBounds(Left,Top,Width,Height);
  DelStack;
end;}

procedure TFldEdit.CMVisibleChanged;
begin
  AddStack('TFldEdit.CMVisibleChanged',Self);
  inherited;
  if Assigned(curget) then curget.HookProc(Self,Message);
  DelStack;
end;

procedure TFldEdit.WMGetChanged;
var fl: boolean;
	oldv: string;
  ov: variant;
label lend;
begin
	AddStack('TFldEdit.WMGetChanged',Self);
	//addmsgfile('WMGetChanged');
  if Assigned(curget) then begin
    curget.HookProc(Self,TMessage(msg));
    if msg.Result<>0 then goto lend;
  	fl := curget=msg.Get;
  	if (msg.nOper=mgReCreate) and fl then begin
    	ReCreateObj; goto lend;
    end;
  end
  else fl:=true;
  if fl and (msg.nOper=mgDestroy) then curget:=NameGet(Self)
  else if (fl or (msg.nOper=mgCreate))
  and (TrimUpper(msg.Get.ClassName)=TrimUpper(Vid))
  and (TrimUpper(msg.Get.VName)=TrimUpper(VName)) then begin
  	oldv:=FValue; ov:=VarValue;
    ChangeObj(FWMGetChanged,[LongInt(msg.Get)]);
    FValue:=oldv;
    if SeekFld then PNameRecFld.Value:=ov;
  end;
lend:
	DelStack;
end;

procedure TFldEdit.FWMGetChanged;
var fl: boolean;
	g: TCustomGet;
begin
  AddStack('TFldEdit.FWMGetChanged',Self);
  g:=PointerVar(av[0]); fl := not Assigned(curget);
  if not fl then fl := curget=g;
  if fl then FNameGet else curget:=g;
  DelStack;
end;

procedure TFldEdit.WMFld;
begin
  AddStack('TFldEdit.WMFld',Self);
  if TrimUpper(NameRec)=TrimUpper(msg.Rec.NameRec) then begin
  	case msg.Oper of
       foOpenRec,foCloseRec: PNameRecFld:=nil;
       foDestroy: PNameRecClr;
    end;
    if Assigned(curget) then curget.HookProc(Self,TMessage(msg));
  end;
	DelStack;
end;

function TFldEdit.SeekFld;
begin
  AddStack('TFldEdit.SeekFld',Self);
  if not Assigned(PNameRec) and not empty(NameRec) then PNameRec:=RecName(NameRec);
  if not Assigned(PNameRecFld) and not empty(NameRecFld) and Assigned(PNameRec)
  then PNameRecFld:=PNameRec.FldName(NameRecFld);
  result:=Assigned(PNameRecFld);
  DelStack;
end;

function TFldEdit.PrMaxLength;
begin
  AddStack('TFldEdit.PrMaxLength',Self);
  result:=PNameRecFld.Info.Size;
  DelStack;
end;

procedure TFldEdit.WMRebuild;
begin
	AddStack('TFldEdit.WMRebuild',Self);
	if Assigned(curget) then curget.Rebuild(Self);
	//inherited;
  DelStack;
end;

procedure TFldEdit.WMChar;
begin
	AddStack('TFldEdit.WMChar',Self);
  inherited;
  if Assigned(curget) then curget.HookProc(Self,Message);
  DelStack;
end;

procedure TFldEdit.WMSetFocus;
begin
	AddStack('TFldEdit.WMSetFocus',Self);
  inherited;
  if Assigned(curget) then curget.HookProc(Self,Message);
  DelStack;
end;

procedure TFldEdit.WMKeyDown;
var ost: longint;
begin
	ost:=AddStack('TFldEdit.WMKeyDown',Self);
  inherited;
  try
    if Assigned(curget) then curget.HookProc(Self,Message);
  except
    SetStack(ost);
  end;
  DelStack;
end;

procedure TFldEdit.WMLButtonDblClk;
begin
	AddStack('TFldEdit.WMLButtonDblClk',Self);
  inherited;
  if Assigned(curget) then curget.HookProc(Self,Message);
  DelStack;
end;

procedure TFldEdit.WMSetRedraw;
var nrdw: boolean;
begin
  AddStack('TFldEdit.WMSetRedraw',Self);
	inherited;
  nrdw:=Boolean(Message.Redraw);
  if CanRedraw<>nrdw then begin
    CanRedraw:=nrdw;
    if CanRedraw then PaintObj;
  end;
  DelStack;
end;

{procedure TFldEdit.WMActForm;
begin
	if not msg.Visible then ClrBevTimer;
end;}

procedure TFldEdit.Loaded;
begin
	AddStack('TFldEdit.Loaded',Self);
	//addmsgfile('Loaded');
	inherited Loaded;
  //DsgnNmAssign;
  SeekFld;
  if Assigned(PNameRec) then
  	if not PNameRec.Active then PNameRec.OpenRec;
  SetBounds(Left,Top,Width,Height); Read([ferdSvOld]);
  if Assigned(PNameRec) and (csDesigning in ComponentState) then PNameRec.CloseRec;
  DelStack;
end;

procedure TFldEdit.CreateObj;
begin
	AddStack('TFldEdit.CreateObj',Self);
	//addmsgfile('CreateObj');
	//FNameGet;
	DsgnNameGet; Relation:=frNormal;
	if Assigned(curget)
  or ((ogReadOnlyNoVsbl in FOptions) and not(csDesigning in ComponentState)) then begin
  	BevelInner:=bvNone; Caption:='';
    if Assigned(curget) then curget.CreateObj(Self);
  end
  else begin
  	BevelInner:=iif(csDesigning in ComponentState,bvLowered,bvNone); Caption:=Name;
  end;
  DelStack;
end;

procedure TFldEdit.ReCreateObj;
begin
	AddStack('TFldEdit.ReCreateObj',Self);
	//addmsgfile('ReCreateObj');
	//FNameGet;
  DsgnNameGet;
  if Assigned(curget) then curget.ReCreateObj(Self);
  DelStack;
end;

function TFldEdit.DestroyObj;
begin
	AddStack('TFldEdit.DestroyObj',Self);
	//addmsgfile('DestroyObj');
  result:=Active;
  if result then FCurGetExit;
	TCustomGet.DestroyObj(Self);
  DelStack;
end;

function TFldEdit.SizeAuto;
var si: TPSortInfo;
  ps: TBoolPPSortObj;
	ols: TArrInt;
  pb,pb1: PPSortObj;
  procedure pbAsgn(i: longint);
  begin
    AddStack('TFldEdit.SizeAuto.pbAsgn');
    pb:=ps[false,i];
    if ols[i]<0 then pb1:=nil else pb1:=ps[true,ols[i]];
    DelStack;
  end;
	function hObj(n1,n2: longint): longint;
  var i,l,t,w,h: longint;
  begin
    AddStack('TFldEdit.SizeAuto.hObj',Self);
    l:=0; t:=0; h:=0;
    for i:=n1 to n2 do begin
    	pbAsgn(i);
      if si.Mode=smDefault then begin
      	w:=pb.Width;
        if Assigned(pb1) then Inc(w,pb1.Width);
        if (l+w>si.Width) or (pb.Obj.Tag<>0) then begin
          Inc(t,h); h:=0; l:=0;
        end;
        if w>si.Width then begin
          Inc(t,pb.Height);
          if Assigned(pb1) then Inc(t,pb1.Height+7);
        end
        else begin
          MaxSelf(h,pb.Height);
          if Assigned(pb1) then MaxSelf(h,pb1.Height);
          Inc(l,w);
        end;
      end
      else begin
      	w:=pb.Height;
        if Assigned(pb1) then
        	if MsgPSort(pb.Obj,swmColWidthAll)=wallDefault then Inc(w,pb1.Height) else MaxSelf(w,pb1.Height);
        Inc(t,w);
      end;
    end;
    result:=t+h;
    DelStack;
  end;
	function wObj(n1,n2: longint): longint;
  var i,ws,wf: longint;
  begin
    AddStack('TFldEdit.SizeAuto.wObj',Self);
    result:=0; ws:=0; wf:=0;
    for i:=n1 to n2 do begin
    	pbAsgn(i);
      if pb.Obj.Tag>0 then begin
      	Inc(result,ws+wf); ws:=0; wf:=0;
      end;
      MaxSelf(wf,pb.Width);
      if Assigned(pb1) then MaxSelf(ws,pb1.Width);
    end;
    Inc(result,ws+wf);
    DelStack;
  end;
var n,nbeg,nend: longint;
  ao: TArrPSortObj;
  flps: boolean;
  function lsCrt: boolean;
  var i: longint;
	  tc: TComponent;
  begin
    AddStack('TFldEdit.SizeAuto.lsCrt');
    if not flps then if PSortList(Parent,si.Mode,ps,ols,ao) then begin
      n:=-1; nbeg:=0; nend:=high(ps[false]);
      for i:=0 to nend do begin
        tc:=ps[false,i].Obj;
        if n<0 then begin
          if (si.Mode<>smDefault) and (tc.Tag>0) then nbeg:=i;
          if tc=Self then begin
            n:=i; flps:=true;
            if si.Mode<>smColumns then break;
          end;
        end
        else if tc.Tag>0 then begin
          nend:=i-1; break;
        end;
      end;
    end;
    result:=flps;
    DelStack;
  end;
var sch: TSchem;
  i,l,h: longint;
  r: TSize;
  Opt: TFESizeAutoOpt;
  aw: array of array[1..3] of longint;
  fl: boolean;
begin
	AddStack('TFldEdit.SizeAuto',Self);
	//addmsgfile('SizeAuto');
	//FNameGet;
{if AnsiUpperCase(Vid)='TARRGET' then begin
PNameRecFld:=PNameRecFld;
end;}
  if Visible or (csDesigning in ComponentState) then begin
    TCustomGet.DefSize(result); DsgnNameGet;
    if Assigned(curget) then begin
      Opt:=[tfszHeight]; //(FCharHeight=0) or (FCharHeight<0) and PSortCondens;
      if (FCharWidth=0) or (FCharWidth<0) and PSortCondens then Include(Opt,tfszWidth);
      if Opt<>[] then result:=curget.SizeAuto(Self,Opt);
    end;
    r:=result;
    if not(csDesigning in ComponentState) then
      if SchemName(Schem,sch) then Canvas.Font.Assign(sch.Font1);
    if FCharWidth>0 then result.cX:=CanvasMaxW(Canvas)*FCharWidth+6;
    if FCharHeight>0 then result.cY:=CanvasMaxH(Canvas)*FCharHeight+6;
    if Assigned(Parent) and not(csDesigning in ComponentState)
    and ((FCharWidth<0) or (FCharHeight<0)) then begin
      h:=MsgPSort(Parent,swmSortInfo,@si);
      if h<>0 then begin
        flps:=false;
        if FCharWidth<0 then begin
          result.cX:=si.Width-BevelFld2{-SysMetric.iScrollWidth};
          if si.Mode<>smDefault then if lsCrt then case si.Mode of
            smColumns: begin
              Dec(result.cX,wObj(0,nbeg-1)+wObj(nend+1,high(ps[false])));
              if FCharWidth=wallNoSay then begin
                h:=0;
                for i:=nbeg to nend do begin
                  pbAsgn(i);
                  if Assigned(pb1) and (MsgPSort(pb.Obj,swmColWidthAll)<>wallDefault) then MaxSelf(h,pb1.Width);
                end;
                Dec(result.cX,h);
              end;
            end;
            smRows: begin
              h:=0; l:=Length(ps[false]); SetLength(aw,l);
              if l>0 then ZeroMemory(@aw[0],l*SizeOf(aw[0]));
              Dec(l);
              for i:=0 to l do begin
                pbAsgn(i);
                if (i>0) and (pb.Obj.Tag>0) then h:=0;
                if h<>n-nbeg then MaxSelf(aw[h,2],pb.Width);
                if Assigned(pb1) then MaxSelf(aw[h,IfThen(MsgPSort(pb.Obj,swmSayRight)=0,1,3)],pb1.Width);
                Inc(h);
              end;
              for i:=0 to l do Dec(result.cX,SumInt(aw[i]));
            end;
          end;
        end;
        if FCharHeight<0 then
          if lsCrt then begin
            if si.Mode=smRows then begin
              h:=0; l:=0; fl := nbeg<>0;
              for i:=0 to high(ps[false]) do begin
                if ps[false,i].Obj.Tag>0 then begin
                  Inc(h,l); l:=0; fl := nbeg<>i;
                end;
                if fl then MaxSelf(l,hObj(i,i));
              end;
              Inc(h,l);
            end
            else h:=hObj(nbeg,n-1)+hObj(n+1,nend);
            if (ols[n]>=0) and ((si.Mode=smDefault) or (FCharWidth=wallDefault))
            then Inc(h,ps[true,ols[n]].Height+IfThen(si.Mode=smDefault,SysMetric.iScrollHeight));
            result.cY:=si.Height-BevelFld2-h;
          end;
      end;
    end;
    if PSortCondens then begin
      if FCharWidth<0 then result.cX:=r.cX;
      if FCharHeight<0 then result.cY:=r.cY;
    end;
    if Assigned(curget) then MaxSelf(result,curget.MinSize(Self));
  end
  else ZeroMemory(@result,SizeOf(result));
  DelStack;
end;

function TFldEdit.AssignObj;
begin
  AddStack('TFldEdit.AssignObj',Self);
  if Assigned(curget) then result:=curget.AssignObj(Self) else result:=false;
  DelStack;
end;

{procedure TFldEdit.SetRdw;
begin
  if not CanRedraw then SetRedraw(tw);
end;}

{ Проверка корректности значения }
function TFldEdit.Check;
begin
	AddStack('TFldEdit.Check',Self);
	//addmsgfile('Check');
	//FNameGet;
	DsgnNameGet;
	result := not Visible or (ogReadOnly in Options) or IsDynamic or not Assigned(curget);
  if not result then begin
    result:=curget.Check(Self);
    if result and Assigned(curget.FOnCheck) then result:=curget.FOnCheck(Self);
    if result and Assigned(FOnCheck) then result:=FOnCheck(Self);
  end;
  DelStack;
end;

// Изменение значения
procedure TFldEdit.Change(const oldv,newv: variant; FromShow: boolean);
	function Cng1(const v: variant): variant;
  begin
  	AddStack('TFldEdit.Change.Cng1',Self);
    if MyVarType(v)=varString then result:=TrimSpRight(v) else result:=v;
    DelStack;
  end;
begin
	AddStack('TFldEdit.Change',Self);
	//addmsgfile('Change');
  if not CompVar(Cng1(oldv),Cng1(newv)) then Change(oldv,FromShow);
  DelStack;
end;

procedure TFldEdit.Change(const oldv: variant; FromShow: boolean);
const acw: array[boolean] of TFEChangeWhere = (fcwEdit,fcwShow);
var fl: boolean;
begin
	AddStack('TFldEdit.Change',Self);
  Write;
  for fl:=false to true do if FEChangeWhere=acw[fl] then begin
    FEChangeWhere:=acw[FromShow]; break;
  end;
  if Assigned(curget) then curget.Change(Self,oldv,FromShow);
  DoChange(oldv,FromShow); FWasChanged:=true;
  DelStack;
end;

procedure TFldEdit.DoChange;
begin
	AddStack('TFldEdit.DoChange',Self);
  IfThenCng(FOnChange,Self,oldv,FromShow);
  DelStack;
end;

{ Действия при получении фокуса }
procedure TFldEdit.DoEnter;
begin
	AddStack('TFldEdit.DoEnter',Self);
	//addmsgfile('DoEnter');
	if not isCalculator then begin
    if Relation<>frMain then ActiveFldEdit:=Self;
    inherited DoEnter;
    FSetFocus;
  end;
  DelStack;
end;

procedure TFldEdit.SetFocus;
var fl: boolean;
begin
	AddStack('TFldEdit.SetFocus',Self);
  fl:=not Active;
  if fl then FldActive(false);
  if fl or IsCalculator then inherited SetFocus;
  if {fl}not Active then FSetFocus;
  DelStack;
end;

procedure TFldEdit.FSetFocus;
begin
	AddStack('TFldEdit.FSetFocus',Self);
	if not FActive or (GetParentForm(Self).ActiveControl=Self) then begin
  	Active:=true; TabStop:=false; FldActive(true); CurGetEnter;
  end;
  DelStack;
end;

procedure TFldEdit.FldActive;
var tw: TWinControl;
  WParam: Word;
  LParam: longint;
begin
  AddStack('TFldEdit.FldActive',Self);
  tw:=Parent; WParam:=Word(After); LParam:=LongInt(Self);
  while Assigned(tw) do
    if tw.Perform(WM_FLDACTIVE,WParam,LParam)=0 then ParentSelf(tw) else break;
  DelStack;
end;

procedure TFldEdit.CurGetEnter;
begin
	AddStack('TFldEdit.CurGetEnter',Self);
  if Assigned(curget) then curget.DoEnter(Self);
  DelStack;
end;

procedure TFldEdit.FCurGetExit;
begin
	AddStack('TFldEdit.FCurGetExit',Self);
  if Assigned(curget) then curget.DoExit(Self);
  DelStack;
end;

procedure TFldEdit.CurGetExit;
var tw: TWinControl;
begin
	AddStack('TFldEdit.CurGetExit',Self);
  if Active then begin
    tw:=Self;
    while Assigned(tw) do begin
      if tw is TFldEdit then TFldEdit(tw).FCurGetExit;
      if OnlySelf then break;
      ParentSelf(tw);
    end;
  end;
  DelStack;
end;

{ Действия при утере фокуса }
procedure TFldEdit.DoExit;
var oldv: variant;
begin
	AddStack('TFldEdit.DoExit',Self);
	//addmsgfile('DoExit');
	if not isCalculator then begin
    oldv:=VarValue; Write; Change(oldv,VarValue,false);
    inherited DoExit;
    Read; FCurGetExit; Active:=false; SetTabStop; DispValue; PaintObj; IfThenNotify(FOnAfterExit,Self);
  end;
  DelStack;
end;

function TFldEdit.SetWHMin;
var msg: TWMWHMin;
begin
	AddStack('TFldEdit.SetWHMin',Self);
  result := inherited SetWHMin(tp,wm);
  if Assigned(curget) then begin
  	msg.Msg:=WM_WHMIN; msg.WMin:=wm; msg.RbPnl:=tp; curget.HookProc(Self,TMessage(msg));
  end;
  DelStack;
end;

function TFldEdit.NoPaintObj: boolean;
begin
	result:=NoPaintObj(Options);
end;

class function TFldEdit.NoPaintObj(Options: TGetOptions): boolean;
begin
	result := (ogReadOnly in Options) and (ogReadOnlyNoVsbl in Options);
end;

procedure TFldEdit.PaintObj;
begin
	AddStack('TFldEdit.PaintObj',Self);
	//addmsgfile('PaintObj');
  if CanRedraw then begin
    DsgnNameGet;
    if Assigned(curget) then curget.PaintObjCheck(Self);
  end;
  DelStack;
end;

procedure TFldEdit.FldMaskBorder;
var r: TRect;
begin
  AddStack('TFldEdit.FldMaskBorder',Self);
  if Visible then begin
    r:=Sender.BoundsRect;
    if (r.Right>r.Left) and (r.Bottom>r.Top) then begin
      InflateRect(r,2,2); Frame3D2(Canvas,r);
    end;
  end;
  DelStack;
end;

function TFldEdit.MayDoKey;
begin
	AddStack('TFldEdit.MayDoKey',Self);
	//addmsgfile('MayDoKey');
	if Assigned(curget) then result:=curget.MayDoKey(Self,Key) else result:=true;
  DelStack;
end;

procedure TFldEdit.SetBounds;
var wh: TSize;
begin
	AddStack('TFldEdit.SetBounds',Self);
	//addmsgfile('SetBounds');
	FNameGet;
	if not((csDesigning in ComponentState) and (csLoading in ComponentState)) and (ogAutoSize in Options) then begin
		wh:=SizeAuto;
		inherited SetBounds(ALeft,ATop,wh.cX+BevelFld2,wh.cY+BevelFld2)
  end
  else inherited SetBounds(ALeft,ATop,AWidth,AHeight);
  PaintObj;
  DelStack;
end;

procedure TFldEdit.WMSchem;
begin
  AddStack('TFldEdit.WMSchem',Self);
	inherited;
  ParentColor:=true; FNameGet; SetBounds(Left,Top,Width,Height);
  if Assigned(curget) then curget.HookProc(Self,msg);
  DelStack;
end;

procedure TFldEdit.WMApplHint;
var vid: longint;
  inf: PDDatKvInfo;
begin
  AddStack('TFldEdit.WMApplHint',Self);
  inherited;
  if IsDynamic(vid) then with aDDat[vid] do if GetKvInfo(NameRecFld,inf) then with Msg.Info^ do begin
    if AssignObj then if Assigned(curget.bDyn) then with curget.bDyn do begin
      ShowHint:=not(ogReadOnly in FOptions); Hint:=IfThen(ShowHint,'Редактировать');
    end;
    DlmBetwSelf(HintStr,curget.DDGetHint(NameRecFld,inf,PNameRec,aDDat[vid],Mask),CRLF);
    CanShow := HintStr<>''; HintInfo.HintStr:=HintStr;
  end;
  DelStack;
end;

procedure TFldEdit.WMPSort;
begin
	AddStack('TFldEdit.WMPSort',Self);
  inherited;
	with Message do begin
    case Oper of
      swmFocusControl: Result:=LongInt(FocusControl);
      swmColWidthAll: if FCharWidth<0 then Result:=FCharWidth;
      swmColHeightAll: if FCharHeight<0 then Result:=-1;
    end;
    if (Oper in [swmColWidthAll,swmColHeightAll,swmSortInfo]) and Assigned(curget)
    then curget.HookProc(Self,TMessage(Message));
  end;
  DelStack;
end;

procedure TFldEdit.WMGetDlgCode;
begin
	AddStack('TFldEdit.WMGetDlgCode',Self);
	inherited;
  Msg.Result:=dlgc_WantArrows;
  DelStack;
end;

procedure TFldEdit.WMPaintCtl;
begin
	AddStack('TFldEdit.WMPaintCtl',Self);
  if Message.Oper=pcmNoPaint then Message.NoPaint:=NoPaintObj;
  DelStack;
end;

// Взять число из калькулятора
procedure TFldEdit.WMFromCalc;
begin
  AddStack('TFldEdit.WMFromCalc',Self);
  with Message,Prm^ do begin
    Result:=1;
    if Assigned(curget) then if curget.FromCalc(Self,d,X,Y) then Write;
  end;
  DelStack;
end;

procedure TFldEdit.WMPlaceToCtrl;
begin
  AddStack('TFldEdit.WMPlaceToCtrl',Self);
  inherited;
  if Assigned(curget) then curget.HookProc(Self,Message);
  DelStack;
end;

procedure TFldEdit.WMHelpFill;
begin
  AddStack('TFldEdit.WMHelpFill',Self);
  inherited;
  if Assigned(curget) then curget.HookProc(Self,Message);
  DelStack;
end;

procedure TFldEdit.Click;
begin
	AddStack('TFldEdit.Click',Self);
  if CanFocus and not FActive then SetFocus;
	inherited Click;
  DelStack;
end;

procedure TFldEdit.DblClick;
begin
  AddStack('TFldEdit.DblClick',Self);
  if AssignObj then
    if Assigned(curget.bDyn) then curget.bDyn.Click;
  inherited DblClick;
  DelStack;
end;

procedure TFldEdit.MouseDown;
begin
  AddStack('TFldEdit.MouseDown',Self);
  if CanFocus and not FActive then SetFocus;
  inherited MouseDown(Button,Shift,X,Y);
  if Assigned(curget) then curget.MouseDown(Self,Button,Shift,X,Y);
  DelStack;
end;

function TFldEdit.GetPaintCtlActive;
begin
  AddStack('TFldEdit.GetPaintCtlActive',Self);
	result := not(ogReadOnly in FOptions);
  if Assigned(curget) then curget.GetPaintCtlActive(Sender,Self,result);
  DelStack;
end;

procedure TFldEdit.SetActive;
begin
	AddStack('TFldEdit.SetActive',Self);
  FActive:=v; Selected := FActive and (Relation<>frMain);
  DelStack;
end;

procedure TFldEdit.SetSelected;
begin
  AddStack('TFldEdit.SetSelected',Self);
  if v<>Selected then begin
  	FSelected:=v; Invalidate;
  end;
  DelStack;
end;

procedure DynCapt(tf: TFldEdit; inf: PDDatKvInfo; h: longint; var result: TDynCaptStr;
  r: PDDatLastInfo = nil);
var d: TDateTime;
  function sd(ld2: boolean): string;
  begin
    AddStack('FFldEdit.DynCapt.sd');
    result:=TDynamicDat.StrDate(d,inf,IfThen(ld2,ddstrD2)+[ddstrPref]);
    DelStack;
  end;
var ts: TSchem;
  s: string;
begin
  AddStack('FFldEdit.DynCapt');
  if SchemName(tf.Schem,ts) then tf.Canvas.Font.Assign(ts.Font1) else DefaultFont(tf.Canvas.Font);
  if Assigned(r) then d:=r.d1 else d:=DateSmall+1;
  result[1]:=sd(false); result[2]:='';
  if inf.td2 in sDDatD2 then begin
    if Assigned(r) then d:=r.d2;
    s:=sd(true);
    if tf.Canvas.TextHeight(result[1])+tf.Canvas.TextHeight(s)>h
    then DlmBetwSelf(result[1],s,' ')
    else result[2]:=s;
  end;
  DelStack;
end;

procedure TFldEdit.Paint;
var r: TRect;
  inf: PDDatKvInfo;
  rlast: TDDatLastInfo;
  a: TDynCaptStr;
  sz: TSize;
  vid: longint;
begin
  AddStack('TFldEdit.Paint',Self);
  inherited Paint;
  if Visible then begin
    if FSelected then begin
      r:=Rect(0,0,Width-1,Height-1); Frame3D(Canvas,r,clHighlight,clHighlight,BevelFld-1);
    end;
    if not NoPaintObj and Assigned(curget) then begin
      curget.Paint(Self);
      if IsDynamic(vid) and curget.DDatPaintPeriod then with aDDat[vid] do
        if GetKvInfo(NameRecFld,inf) then begin
          GetValue(NameRecFld,inf); DynCapt(Self,inf,Height-BevelFld2,a);
          r:=Rect(BevelFld,BevelFld,BevelFld+max(Canvas.TextWidth(a[1]),Canvas.TextWidth(a[2]))+4,Height-BevelFld);
          Frame3D2(Canvas,r); rlast:=GetLastInfo(NameRecFld,inf);
          DynCapt(Self,inf,Height-BevelFld2,a,@rlast);
          if (rlast.d1>DateSmall) or (a[2]='') and (rlast.d2<DateBig) then begin
            sz:=Canvas.TextExtent(a[1]);
            Canvas.TextRect(r,r.Right-sz.cx,r.Top,a[1]); Inc(r.Top,sz.cy);
          end;
          if rlast.d2<DateBig then Canvas.TextRect(r,r.Right-Canvas.TextWidth(a[2]),r.Top,a[2]);
        end;
    end;
  end;
  DelStack;
end;

procedure TFldEdit.SetCharCase;
begin
	AddStack('TFldEdit.SetCharCase',Self);
	//addmsgfile('SetCharCase');
	if FCharCase<>v then begin
   	FCharCase:=v; ReCreateObj;
  end;
  DelStack;
end;

function TFldEdit.GetDimNm;
begin
	{$IFDEF STACKALL}AddStack('TFldEdit.GetDimNm',Self);{$ENDIF}
	//addmsgfile('GetDimNm');
	result:=FDimNm[Index];
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TFldEdit.SetDimNm;
var od: boolean;
begin
	AddStack('TFldEdit.SetDimNm',Self);
	//addmsgfile('SetDimNm');
	if v<>FDimNm[Index] then begin
    od:=IsDynamic; FDimNm[Index]:=v; //NmAssign;
    PNameRecClr; DynButCreate;
    if (Index=1) and (IsDynamic<>od) then CreateObj else ReCreateObj;
    if Showing then Read else NoCanWrite:=true;
    //if SeekFld then PNameRecFld.Modified:=true;
  end;
  DelStack;
end;

procedure TFldEdit.SetMask;
var oldv: string;
begin
	AddStack('TFldEdit.SetMask',Self);
	//addmsgfile('SetMask');
	if FMask<>v then begin
   	oldv:=Value; FMask:=v; ReCreateObj; Value:=oldv;
  end;
  DelStack;
end;

procedure TFldEdit.SetMaxLength;
begin
	AddStack('TFldEdit.SetMaxLength',Self);
	//addmsgfile('SetMaxLength');
	if FMaxLength<>v then begin
   	FMaxLength:=v; ReCreateObj;
  end;
  DelStack;
end;

procedure TFldEdit.SetOptions;
begin
	AddStack('TFldEdit.SetOptions',Self);
	//addmsgfile('SetOptions');
  if FOptions<>v then begin
{if (ogAutoSize in FOptions) and not(ogAutoSize in v) then begin
FOptions:=FOptions;
end;}
    FOptions:=v; SetTabStop; ReCreateObj;
  end;
  DelStack;
end;

function TFldEdit.GetValue;
begin
	AddStack('TFldEdit.GetValue',Self);
	//addmsgfile('GetValue');
	//FNameGet;
  if Assigned(Self) then begin
    DsgnNameGet;
    if Assigned(curget) then FValue:=curget.GetValue(Self) else FValue:='';
    result:=FValue;
  end
  else result:='';
  DelStack;
end;

procedure TFldEdit.SetValue;
var oldv,newv: variant;
begin
	AddStack('TFldEdit.SetValue',Self);
	//addmsgfile('SetValue');
  DsgnNameGet;
  if SeekFld then oldv:=PNameRecFld.StrToVar(FValue) else oldv:=null;
  if Assigned(curget) then curget.SetValue(Self,v);
  GetValue;
  if Assigned(PNameRecFld) then newv:=PNameRecFld.StrToVar(FValue) else newv:=null;
  Change(oldv,newv,lFromShow);
  DelStack;
end;

function TFldEdit.GetVarValue;
begin
	AddStack('TFldEdit.GetVarValue',Self);
	if SeekFld then result:=PNameRecFld.Value else result:=null;
  DelStack;
end;

procedure TFldEdit.SetVarValue;
begin
	AddStack('TFldEdit.SetVarValue',Self);
	if SeekFld then begin
  	PNameRecFld.Value:=v; Read;
  end;
  DelStack;
end;

procedure TFldEdit.SetVid;
begin
	AddStack('TFldEdit.SetVid',Self);
	//addmsgfile('SetVid');
  AssignGet(v,FVName);
  DelStack;
end;

procedure TFldEdit.SetVName;
begin
	AddStack('TFldEdit.SetVName',Self);
	//addmsgfile('SetVName');
  AssignGet(FVid,v);
  DelStack;
end;

procedure TFldEdit.FAssignGet;
begin
  AddStack('TFldEdit.FAssignGet',Self);
  FVid:=av[0]; FVName:=av[1]; FNameGet;
  DelStack;
end;

procedure TFldEdit.ChangeObj;
var oAct: boolean;
begin
  AddStack('TFldEdit.ChangeObj',Self);
  oAct:=DestroyObj; Proc(av); CreateObj;
  if oAct and CanFocus then GetParentForm(Self).ActiveControl:=Self;
  DelStack;
end;


procedure TFldEdit.RestOldVal;
begin
	AddStack('TFldEdit.RestOldVal',Self);
	//addmsgfile('RestOldVal');
	Value:=FOldValue;
  DelStack;
end;

{procedure TFldEdit.DsgnNmAssign;
begin
	AddStack('TFldEdit.DsgnNmAssign',Self);
	//addmsgfile('DsgnNmAssign');
	if (csDesigning in ComponentState) or not Assigned(PNameRecFld)
  then NmAssign;
  DelStack;
end;

procedure TFldEdit.NmAssign;
begin
	AddStack('TFldEdit.NmAssign',Self);
	//addmsgfile('NmAssign');
	PNameRec:=RecName(NameRec);
	if Assigned(PNameRec)
  then PNameRecFld:=PNameRec.FldName(NameRecFld)
  else PNameRecFld:=nil;
  DelStack;
end;}

procedure TFldEdit.Read(Opt: TFEReadOpt = []);
var oShow: boolean;
  inf: PDDatKvInfo;
  vid: longint;
begin
	AddStack('TFldEdit.Read',Self);
	//addmsgfile('Read');
  if IsDynamic(vid,false) then
    if SeekFld then with aDDat[vid] do begin
      GetValue(NameRecFld);
      if GetKvInfo(NameRecFld,inf) then begin
        if (inf.td2<>dd2All) or (ferdFromShow in Opt) then PNameRecFld.Value:=GetLastInfo(NameRecFld,inf).val
      end
      else PNameRecFld.Value:=VarBlank(PNameRecFld.Value);
    end;
  if (ferdFromShow in Opt) and (ferdSvOld in Opt) and Assigned(curget) then curget.ReadFirst(Self);
  oShow:=lFromShow; lFromShow := ferdFromShow in Opt;
  if ferdSvOld in Opt then FWasChanged:=false;
  Value:=ReadStr; DispValue;
  if ferdSvOld in Opt then FOldValue:=FValue;
  lFromShow:=oShow; NoCanWrite:=false;
  DelStack;
end;

class procedure TFldEdit.Read(Opt: TFEReadOpt; const a: array of TFldEdit);
var i: longint;
begin
  for i:=low(a) to high(a) do a[i].Read(Opt);
end;

procedure TFldEdit.Write;
begin
	AddStack('TFldEdit.Write',Self);
	//addmsgfile('Write');
  if not NoCanWrite then begin
    if Assigned(curget) then curget.Write(Self);
    WriteStr(Value);
  end;
  DelStack;
end;

function TFldEdit.ReadStr;
begin
	AddStack('TFldEdit.ReadStr',Self);
	//addmsgfile('ReadStr');
  //DsgnNmAssign;
	if SeekFld then result:=PNameRecFld.GetStrVal else result:='';
  DelStack;
end;

procedure TFldEdit.WriteStr;
begin
	AddStack('TFldEdit.WriteStr',Self);
	//addmsgfile('WriteStr');
  //if AlwaysWrite or not(ogReadOnly in Options) then begin
    //DsgnNmAssign;
    if SeekFld then PNameRecFld.SetStrVal(v);
  //end;
  DelStack;
end;

procedure TFldEdit.UpdateRec;
var inf: PDDatKvInfo;
  vid: longint;
begin
  AddStack('TFldEdit.UpdateRec',Self);
  if Oper=feuAfterUpd then if IsDynamic(vid,false) then if SeekFld then with aDDat[vid] do
    if GetKvInfo(NameRecFld,inf) then if inf.td2=dd2All then begin
      Write;
      LogFields.AddRecFld(DDat,fDDZN);
      SetValue(NameRecFld,PNameRecFld.Value,DateSmall,DateEmpty,[ddLog]);
    end;
  if Assigned(curget) then curget.UpdateRec(Self,Oper);
  DelStack;
end;

{ Установка Value для показа на экране }
procedure TFldEdit.DispValue;
begin
	AddStack('TFldEdit.DispValue',Self);
	//addmsgfile('DispValue');
  if Assigned(curget) then curget.DispValue(Self);
  DelStack;
end;

{ Длина поля ввода }
function TFldEdit.LenFld;
var a: TNamePrimStr;
  err: byte;
	s,ms: string;
begin
	AddStack('TFldEdit.LenFld',Self);
	//addmsgfile('LenFld');
	result:=Def; ms:=msk; err:=0;
	if FMaxLength=0 then begin
  	if not UserMask then ms:=FMask;
   	if Empty(ms) then begin
		  //DsgnNmAssign;
    	if SeekFld then begin
      	result:=PNameRecFld.Info.Size; err:=1;
      end;
    end
    else begin
      s:=LeftStr(ms,PosEnd(MaskFieldSeparator,ms)-1); result:=length(ms); err:=2;
      while StrDivDlm('\',s,a) do begin
        s:=a[2]; Dec(result); err:=3;
      end;
    end
  end
  else begin
  	result:=FMaxLength; err:=4;
  end;
  if result>1000000 then raise Exception.CreateFmt(
  	'Слишком большая длина поля %s.%s(%d).%sКод ошибки %d',[NameRec,NameRecFld,result,CRLF,err]);
  DelStack;
end;

{ Точность поля ввода типа Float }
function TFldEdit.DecFld;
var p: longint;
begin
	AddStack('TFldEdit.DecFld',Self);
	//addmsgfile('DecFld');
	result:=0; //DsgnNmAssign;
  if SeekFld then
    if (PNameRecFld.Info.DataType=ftFloat) and not empty(FMask) then
      if IsPos(p,DecimalSeparator,FMask) then result:=Length(FMask)-p;
  DelStack;
end;

// Основной цвет
function TFldEdit.Color1(ts: TSchem): TColor;
begin
	AddStack('TFldEdit.Color1',Self);
	//addmsgfile('Color1');
  result:=IfThen(ogReadOnly in Options,ts.IfThenColor(dColor2,clBtnFace),ts.IfThenColor(dColor1,clWindow));
  DelStack;
end;

function TFldEdit.Color1: TColor;
begin
  result:=Color1(SchemName(Schem));
end;

procedure TFldEdit.AssignGet(cg: TCustomGet; lBound: boolean = false);
begin
  if Assigned(cg) then AssignGet(cg.ClassName,cg.VName,lBound) else AssignGet('','',lBound);
end;

function TFldEdit.AssignGet(const v: string = ''; const vn: string = ''; lBound: boolean = false): TCustomGet;
var oldv: string;
	fl{,fl1}: boolean;
begin
	AddStack('TFldEdit.AssignGet',Self);
	//addmsgfile('SetVid');
	if (v<>FVid) or (vn<>FVName) or lBound then begin
    oldv:=FValue; fl:=Assigned(curget); {fl1:=FActive;
    if fl and fl1 then curget.DoExit(Self);}
    ChangeObj(FAssignGet,[v,vn]);
    if TFormWnd(GetParentForm(Self)).ActiveForm and fl then FValue:=oldv
    else if not(csDesigning in ComponentState) then Read;
    //if Assigned(curget) and fl1 then curget.DoEnter(Self);
  end;
  result:=curget;
  DelStack;
end;

function TFldEdit.AssignGet(g: TCustomGetClass): TCustomGet;
begin
  result:=AssignGet(g.ClassName);
end;

procedure TFldEdit.AssignGetDef;
begin
  AddStack('TFldEdit.AssignGetDef',Self);
  if Assigned(cg) then AssignGet(cg) else AssignGet(TSimpleGet);
  DelStack;
end;

procedure TFldEdit.EdClick;
begin
	AddStack('TFldEdit.EdClick',Self);
	//addmsgfile('EdClick');
	if not FActive and CanFocus then SetFocus;
  Click;
  DelStack;
end;

procedure TFldEdit.EdDblClick;
begin
	AddStack('TFldEdit.EdDblClick',Self);
	//addmsgfile('EdDblClick');
	DblClick;
  DelStack;
end;

procedure TFldEdit.EdKeyDown;
begin
	AddStack('TFldEdit.EdKeyDown',Self);
	//addmsgfile('EdKeyDown');
	KeyDown(Key,Shift);
  DelStack;
end;

procedure TFldEdit.EdKeyPress;
begin
	AddStack('TFldEdit.EdKeyPress',Self);
	//addmsgfile('EdKeyPress');
	KeyPress(Key);
  DelStack;
end;

procedure TFldEdit.EdKeyUp;
begin
	AddStack('TFldEdit.EdKeyUp',Self);
	//addmsgfile('EdKeyUp');
	KeyUp(Key,Shift);
  DelStack;
end;

procedure TFldEdit.EdMouseDown;
begin
	AddStack('TFldEdit.EdMouseDown',Self);
	//addmsgfile('EdMouseDown');
	MouseDown(Button,Shift,X,Y);
  DelStack;
end;

procedure TFldEdit.EdMouseMove;
begin
	AddStack('TFldEdit.EdMouseMove',Self);
	//addmsgfile('EdMouseMove');
	MouseMove(Shift,X,Y);
  DelStack;
end;

procedure TFldEdit.EdMouseUp;
begin
	AddStack('TFldEdit.EdMouseUp',Self);
	//addmsgfile('EdMouseUp');
	MouseUp(Button,Shift,X,Y);
  DelStack;
end;

procedure TFldEdit.FNameGet;
begin
	AddStack('TFldEdit.FNameGet',Self);
	//addmsgfile('FNameGet');
  if (FVid='') and (FVname='') then curget:=nil else curget:=NameGet(Self);
  DelStack;
end;

procedure TFldEdit.SetCurGet;
var fl: boolean;
	ost: longint;
begin
	ost:=AddStack('TFldEdit.SetCurGet',Self);
  ReAssignGet(v,FMask);
	if FCurGet<>v then begin
    fl:=FActive;
    try
      if fl then FCurGetExit;
    except
      on EAccessViolation do SetStack(ost);
    end;
    FCurGet:=v;
    try
      if fl then CurGetEnter;
    except
      on EAccessViolation do SetStack(ost);
    end;
  end;
  DelStack;
end;

procedure TFldEdit.DsgnNameGet;
begin
	AddStack('TFldEdit.DsgnNameGet',Self);
	//addmsgfile('DsgnNameGet');
  if csDesigning in ComponentState then FNameGet;
  DelStack;
end;

procedure TFldEdit.SetActiveControl;
begin
	AddStack('TFldEdit.SetActiveControl',Self);
	GetParentForm(Self).ActiveControl:=Self; DoEnter;
  DelStack;
end;

function TFldEdit.DefRelation;
begin
	AddStack('TFldEdit.DefRelation',Self);
	if Assigned(curget) then result:=curget.DefRelation else result:=frNormal;
  DelStack;
end;

procedure TFldEdit.SetRelation;
begin
	AddStack('TFldEdit.SetRelation',Self);
	if FRelation<>v then begin
  	FRelation:=v; SetTabStop; CurGetExit; Active:=false;
  end;
  DelStack;
end;

procedure TFldEdit.SetTabStop;
begin
  AddStack('TFldEdit.SetTabStop',Self);
  TabStop := (FRelation=frNormal) and not(ogReadOnly in FOptions);
  DelStack;
end;

function TFldEdit.SetReadOnly(Value: boolean; opt: TGetOptions = [ogReadOnly]): boolean;
begin
	AddStack('TFldEdit.SetReadOnly',Self);
  result:=Assigned(Self);
  {if NameRecFld='EFSTDRLSED' then begin
  FRelation:=FRelation;
  end;}
  if result then
	  if Value then IncOptions(opt) else IncOptions([],opt);
  DelStack;
end;

function TFldEdit.SetReadOnly(Value: boolean; opt: TGetOption): boolean;
begin
  result:=SetReadOnly(Value,[opt]);
end;

class procedure TFldEdit.SetReadOnly(const atf: array of TFldEdit; Value: boolean; opt: TGetOptions = [ogReadOnly]);
var i: longint;
begin
  for i:=low(atf) to high(atf) do atf[i].SetReadOnly(Value,opt);
end;

class procedure TFldEdit.SetReadOnly(const atf: array of TFldEdit; Value: boolean; opt: TGetOption);
begin
  SetReadOnly(atf,Value,[opt]);
end;

function TFldEdit.SetReadOnly(ro: boolean; const Value: variant; opt: TGetOptions = [ogReadOnly]): boolean;
begin
	AddStack('TFldEdit.SetReadOnly(Value)',Self);
  result:=SetReadOnly(ro,opt);
  if ro and result then VarValue:=Value;
  DelStack;
end;

procedure TFldEdit.SetReadOnlyNoVsbl;
type TRO = (roNoReadOnly,roReadOnly,roNoVsbl);
  function RO(opt: TGetOptions): TRO;
  begin
    AddStack('TFldEdit.SetReadOnlyNoVsbl.RO',Self);
    result:=iif(ogReadOnly in opt,iif(ogReadOnlyNoVsbl in opt,roNoVsbl,roReadOnly),roNoReadOnly);
    DelStack;
  end;
const a: array[TRO,TRO] of TRO =
  ((roNoReadOnly,roReadOnly,roNoVsbl)
  ,(roReadOnly  ,roReadOnly,roNoVsbl)
  ,(roNoVsbl    ,roNoVsbl  ,roNoVsbl)
  );
var r: TRO;
begin
  AddStack('TFldEdit.SetReadOnlyNoVsbl',Self);
  r:=a[RO(opt1),RO(opt2)]; SetSet(opt1,ogReadOnly,r<>roNoReadOnly);
  if r=roNoVsbl then Include(opt1,ogReadOnlyNoVsbl);
  Options:=opt1;
  DelStack;
end;

procedure TFldEdit.IncOptions;
begin
  Options:=Options+Incl-Excl;
end;

function TFldEdit.DynButCreate;
const bDynName = 'DynamicData';
begin
  AddStack('TFldEdit.DynButCreate',Self);
  result:=nil;
  if ComponentCount>0 then
    if IsClass(Components[0],TPaintButton,pointer(result)) then
      if result.Name<>bDynName then result:=nil;
  if IsDynamic<>Assigned(result) then
    if Assigned(result) then FreeAndNil(result)
    else begin
      result:=TPaintButton.Create(Self);
      with result do begin
        Name:=bDynName; Canvas:=Self.Canvas; ComponentIndex:=0;
        BMByName(Glyph,bmDDat); onClick:=DynClick;
      end;
    end;
  DelStack;
end;

class procedure TFldEdit.DynClick;
var tf: TFldEdit;
  bDyn: TPaintButton;
begin
  AddStack('TFldEdit.DynClick');
  bDyn:=pointer(Sender); tf:=FldEditOwner(bDyn);
  if not(ogReadOnly in tf.Options) then begin
    bDyn.Down:=true;
    try
      DDatLsExec(tf);
    finally
      bDyn.Down:=false;
    end;
  end;
  DelStack;
end;

function TFldEdit.DynCaptSize;
var a: TDynCaptStr;
  inf: PDDatKvInfo;
  vid: longint;
begin
  AddStack('TFldEdit.DynCaptSize',Self);
  ZeroMemory(@result,SizeOf(result));
  if IsDynamic(vid) then
    if aDDat[vid].GetKvInfo(NameRecFld,inf) then begin
      DynCapt(Self,inf,h,a); result:=Canvas.TextExtent(a[1]);
      MaxSelf(result.cX,Canvas,a[2]); Inc(result.cX,4); Inc(result.cY,4);
    end;
  DelStack;
end;

procedure TFldEdit.VarBlankSelf;
begin
  AddStack('TFldEdit.VarBlankSelf',Self);
  VarValue:=VarBlank(VarValue);
  DelStack;
end;

procedure TFldEdit.VarMinSelf;
begin
  AddStack('TFldEdit.VarMinSelf',Self);
  if d2<VarValue then VarValue:=d2;
  DelStack;
end;

procedure TFldEdit.VarMaxSelf;
begin
  AddStack('TFldEdit.VarMaxSelf',Self);
  if d2>VarValue then VarValue:=d2;
  DelStack;
end;

function TFldEdit.DWVarName(var nmVar: string; lMsg: boolean = false): boolean;
begin
  AddStack('TFldEdit.DWVarName',Self);
  nmVar:=DWVarName; result := nmVar<>'';
  if not result and lMsg
  then result := GetParentForm(Self).Perform(WM_FLDVAR,longint(Self),Longint(@nmVar))>0;
  DelStack;
end;

function TFldEdit.DWVarName: string;
begin
  AddStack('TFldEdit.DWVarName');
  result:=TrimUpper(TRecDBDef.DWVarName(IfThen(IsDynamic(false),NameRecDynRdb,NameRec),NameRecFld));
  DelStack;
end;

procedure TFldEdit.ValueRepeat;
begin
  Value:=Value;
end;

class function TFldEdit.GetStrValue;
begin
  AddStack('TFldEdit.GetStrValue');
  if Sender is TFldEdit then result:=TFldEdit(Sender).Value else result:=TFldValue(Sender).Value;
  DelStack;
end;

class procedure TFldEdit.SetStrValue;
begin
  AddStack('TFldEdit.GetStrValue');
  if Sender is TFldEdit then TFldEdit(Sender).Value:=Value else TFldValue(Sender).Value:=Value;
  DelStack;
end;

class function TFldEdit.NoEmpValue;
begin
  result:=not empty(TFldEdit(Sender).VarValue);
end;

function TFldEdit.CaptWidth;
begin
	AddStack('TFldEdit.CaptWidth',Self);
  if Assigned(ts) then begin
    Canvas.Font.Assign(ts.FontW);
    result:=Canvas.TextWidth(Caption);
    Canvas.Font.Assign(ts.Font1);
  end
  else begin
  	result:=0; Canvas.Font.Assign(Font);
  end;
  MaxSelf(result,Canvas,Caption); Inc(result,8);
  DelStack;
end;

function TFldEdit.CaptHeight;
begin
	AddStack('TFldEdit.CaptHeight');
  result:=0;
  if not(csDestroying in ComponentState) then with Canvas do
    if Assigned(ts) then begin
      Font.Assign(ts.Font2); MaxSelf(result,Canvas,true);
      Font.Assign(ts.FontW); MaxSelf(result,Canvas,true);
      Font.Assign(ts.Font1);
    end
    else MaxSelf(result,Canvas,true);
  Inc(result,4);
  DelStack;
end;

function TFldEdit.CharCheck;
begin
  AddStack('TFldEdit.CharCheck',Self);
  result := Pos(cInvalid,Value)=0;
  if not result then meserr('Недопустимый символ - "'+cInvalid+'"');
  DelStack;
end;

function NameGet(var g: TCustomGet; const v: string; const vn: string = ''; cg: TCustomGetClass = nil): boolean;
begin
	AddStack('FFldEdit.NameGet');
	//addmsgfile('NameGet');
	g:=nil; result:=false;
  if Assigned(LsCustomGet) then if PointerObjFind(LsCustomGet,Trim(v)+UnDelim+Trim(vn),pointer(g)) then
    if not Assigned(cg) or (g is cg) then result:=true else g:=nil;
  DelStack;
end;

function NameGet(var g: TCustomGet; const a: TDEPrmStr; cg: TCustomGetClass = nil): boolean;
begin
  result:=NameGet(g,a[deVid],a[deVName],cg);
end;

function NameGet(var g: TCustomGet; tf: TFldEdit; cg: TCustomGetClass = nil): boolean;
begin
  result:=NameGet(g,tf.Vid,tf.VName,cg);
end;

function NameGet(var g: TCustomGet; cg: TCustomGetClass; const vn: string = ''): boolean;
begin
  if Assigned(cg) then result:=NameGet(g,cg.ClassName,vn) else result:=false;
end;

function NameGet(const v: string; const vn: string = ''; cg: TCustomGetClass = nil): TCustomGet;
begin
	NameGet(result,v,vn,cg);
end;

function NameGet(const a: TDEPrmStr): TCustomGet;
begin
	NameGet(result,a);
end;

function NameGet(tf: TFldEdit): TCustomGet;
begin
	NameGet(result,tf);
end;

function NameGet(cg: TCustomGetClass; const vn: string = ''): TCustomGet;
begin
	NameGet(result,cg,vn);
end;

procedure NameGet(const v: string; Proc: TNameGetProc; const av: array of variant);
var s: string;
  i,l: longint;
  lBreak: boolean;
begin
	AddStack('FFldEdit.NameGet(Proc)');
  if Assigned(LsCustomGet) then begin
    s:=Trim(v)+UnDelim; LsCustomGet.Find(s,i); l:=LsCustomGet.Count; lBreak:=false;
    while i<l do begin
      if not AnsiStartsText(s,LsCustomGet[i]) then break;
      Proc(PointerObj(LsCustomGet,i),av,lBreak);
      if lBreak then break else Inc(i);
    end;
  end;
  DelStack;
end;

function SpaceStrSelf(Sender: TObject; const nmf: string): boolean;
begin
  result := TFldEdit(Sender).NameRecFld<>nmf;
  if not result then SpaceStrSelf(Sender);
end;

procedure SpaceStrSelf(Sender: TObject);
begin
  AddStack('FFldedit.SpaceStrSelf');
  with TFldEdit(Sender) do VarValue:=SpaceStr(VarValue);
  DelStack;
end;

function KodCheck(Sender: TObject; const NmFld: string; var Chk: boolean;
  const Flt: string = ''; const cMsg: string = ''; Opt: TKodCheckOptions = [];
  ProcMsgEq: TNotifyEvent = nil; const ctbl: string = ''): boolean;
begin
  AddStack('FFldedit.KodCheck(eq)');
  result := TFldEdit(Sender).NameRecFld<>NmFld;
  if result then Chk:=true else Chk:=KodCheck(Sender,Flt,cMsg,Opt,ProcMsgEq,ctbl);
  DelStack;
end;

function KodCheck(Sender: TObject;
  const Flt: string = ''; const cMsg: string = ''; Opt: TKodCheckOptions = [];
  ProcMsgEq: TNotifyEvent = nil; const ctbl: string = ''): boolean;
begin
  AddStack('FFldedit.KodCheck');
  with TFldEdit(Sender) do
    if PNameRec is TRecDB
    then result:=TRecDB(PNameRec).KodCheck(NameRecFld,Flt,cMsg,Opt,ProcMsgEq,ctbl)
    else result:=true;
  DelStack;
end;

function NoEmpCheck(Sender: TObject; const NmFld: string; var Chk: boolean): boolean;
begin
  result:=NoEmpCheck(Sender,[NmFld],Chk);
end;

function NoEmpCheck(Sender: TObject; const aNmFld: array of string; var Chk: boolean): boolean;
begin
  AddStack('FFldedit.NoEmpCheck');
  result := not AnsiMatchText(TFldEdit(Sender).NameRecFld,aNmFld);
  if result then Chk:=true else Chk:=TFldEdit.NoEmpValue(Sender);
  DelStack;
end;

function CharCheck;
begin
  AddStack('FFldedit.CharCheck');
  with TFldEdit(Sender) do begin
    result := NameRecFld<>NmFld;
    if result then Chk:=true else Chk:=CharCheck(cInvalid);
  end;
  DelStack;
end;

function F1GreatOrEqF2(Sender: TObject; const F1,F2: string; var Chk: boolean): boolean;
begin
  AddStack('FFldedit.F1GreatOrEqF2');
  with TFldEdit(Sender) do begin
    result := NameRecFld<>F1;
    if result then Chk:=true else Chk := VarValue>=PNameRec[F2];
  end;
  DelStack;
end;

function F1GreatOrEqF2(Sender: TObject; const af: TArrBoolStr; var Chk: boolean): boolean;
begin
  result:=F1GreatOrEqF2(Sender,af[true],af[false],Chk);
end;

procedure AnsiUpperCaseSelf(Sender: TObject);
begin
  AddStack('FFldedit.AnsiUpperCaseSelf');
  with TFldEdit(Sender) do VarValue:=AnsiUpperCase(VarValue);
  DelStack;
end;

procedure ReAssignGet;
var og: TCustomGet;
begin
  AddStack('FFldedit.ReAssignGet');
  og:=nil;
  while Assigned(g) and (og<>g) do begin
    og:=g; g:=g.ReAssign(Mask);
  end;
  DelStack;
end;

function FldEditOwner;
begin
  AddStack('FFldEdit.FldEditOwner');
  result:=GetOwnerFldEdit(pointer(Sender),true);
  DelStack;
end;

procedure FldEditOwnerSelf;
begin
  Sender:=FldEditOwner(Sender);
end;

procedure ChildFldAll;
var i: longint;
	tw: TWinControl;
begin
  AddStack('FFldEdit.ChildFldAll');
  for i:=0 to CtrlInfCount(Sender)-1 do
    if IsClass(CtrlInfItem(Sender,i),TWinControl,pointer(tw)) then begin
      if (tw is TFldEdit) and (tw.Visible or not OnlyVisible) then Proc(pointer(tw),av);
      ChildFldAll(tw,Proc,av,OnlyVisible);
    end;
  DelStack;
end;

procedure FChildFldReadAll(Sender: TFldEdit; const av: array of variant);
var Opt: TFEReadOpt;
begin
	AddStack('FFldEdit.FChildFldReadAll');
  Opt:=TFEReadOpt(byte(av[0]));
  with Sender do begin
    Read(Opt);
    if not WasChanged then Change(VarValue,ferdFromShow in Opt);
  end;
  DelStack;
end;

procedure ChildFldReadAll;
begin
	AddStack('FFldEdit.ChildFldReadAll');
  ChildFldAll(Sender,FChildFldReadAll,[byte(Opt)]);
  DelStack;
end;

procedure FChildFldWriteAll(Sender: TFldEdit; const av: array of variant);
begin
	AddStack('FFldEdit.FChildFldWriteAll');
  Sender.Write;
  DelStack;
end;

procedure ChildFldWriteAll;
begin
	AddStack('FFldEdit.ChildFldWriteAll');
  ChildFldAll(Sender,FChildFldWriteAll,[0]);
  DelStack;
end;

function GetOwnerFldEdit;
begin
  AddStack('FFldedit.GetOwnerFldEdit');
  if NoSelf then OwnerSelf(tc);
  result:=nil;
  while Assigned(tc) do
    if IsClass(tc,TFldEdit,pointer(result),false) then break else OwnerSelf(tc);
  DelStack;
end;

procedure CopyFromArrGet;
var i: longint;
begin
  AddStack('FFldedit.CopyFromArrGet');
  SetLength(Dest,Length(Source));
  for i:=low(Dest) to high(Dest) do Dest[i]:=Source[i];
  DelStack;
end;

procedure AddFrom(var Dest: TArrOfGet; Source: TCustomGet);
var j: longint;
begin
	AddStack('FFldedit.AddFrom(TCustomGet)');
  j:=Length(Dest); SetLength(Dest,j+1); Dest[j]:=Source;
  DelStack;
end;

procedure AddFrom(var Dest: TArrFldEdit; Source: TFldEdit);
var j: longint;
begin
	AddStack('FFldedit.AddFrom(TFldEdit)');
  j:=Length(Dest); SetLength(Dest,j+1); Dest[j]:=Source;
  DelStack;
end;

function StrToBoolean(tf: TFldEdit): boolean;
begin
  result:=StrToBoolean(tf.Value);
end;

function avRecName(const av: array of variant; var r: TCustomRec): boolean;
begin
	AddStack('FFldedit.avRecName');
  result:=RecName(av[1],r);
  if result then
    if DWRdbSeek(r) then
      if Assigned(RecDBDWRdbSeek) then RecDBDWRdbSeek(r);
  DelStack;
end;

// RecFldZn()
procedure FRecFldZnRead(Sender: TFldEdit; const av: array of variant);
const Opt: TFEReadOpt = [];
begin
	AddStack('FFldEdit.FRecFldZnRead');
  with Sender do if (TrimUpper(NameRec)=av[0]) and (TrimUpper(NameRecFld)=av[1])
  then FChildFldReadAll(Sender,[byte(Opt)]);
  DelStack;
end;

function c_recfldzn(var av: array of variant):variant;
var r: TCustomRec;
  fl: boolean;
  i: longint;
  nmr,nmf: string;
begin
	AddStack('FFldedit.c_recfldzn');
  if Assigned(RecDBRecFldZn) then fl:=RecDBRecFldZn(av[1],av[2],result) else fl:=true;
  if fl then begin
    result:='';
    if avRecName(av,r) then begin
      nmf:=TrimUpper(av[2]);
      if r.NumFromName(nmf,i) then begin
        result:=r.ValueNum[i];
        if not IsNil(av[3]) then begin
          r.ValueNum[i]:=av[3];
          if IsNilc(av[5],false) then begin
            nmr:=TrimUpper(r.NameRec);
            for i:=0 to LsFormWnd.Count-1 do ChildFldAll(LsFormWnd[i],FRecFldZnRead,[nmr,nmf]);
          end;
          if (r is TRecDB) and IsNilc(av[4],true) then result:=TRecDB(r).UpdateRec;
        end;
      end;
    end;
  end;
  DelStack;
end;

// RecApp
{function c_recapp(var av: array of variant):variant;
var r: TCustomRec;
  i: longint;
begin
  AddStack('RecDB.c_recapp');
  result:=null;
  if avRecName(av,r) then
    if r is TRecDB then with TRecDB(r) do begin
      NewRec;
      if MyVarType(av[2])=varArray then
        for i:=VarArrayLowBound(av[2],1) to VarArrayHighBound(av[2],1) do Value[av[2][i]]:=av[3][i];
      AppRec;
    end;
  DelStack;
end;}

procedure DWFldDefaultProc(const r: TDWVidRec; var ap: TDEPrmStr);
begin
  AddStack('FFldedit.DWFldDefaultProc');
  if (r.AType=dwtFloat) and (r.Dec>0) then TNumGet.AssignGetClass(ap);
  DelStack;
end;

procedure LogTrnsValProc(var Prm: TLogTrnsValPrm);
var i: longint;
  tf: TFldEdit;
  v: variant;
  fl: boolean;
  tw: TWinControl;
  ls: TIntegerList;
  f: TCustomForm;
begin
  AddStack('FFldedit.LogTrnsValProc');
  with Prm do if Assigned(LsFldEdit) then begin
    ls:=nil;
    try
      for i:=0 to LsFldEdit.Count-1 do begin
        tf:=LsFldEdit[i];
        if tf.PNameRec=Sender then if TrimUpper(tf.NameRecFld)=nmf then
        if not tf.NoPaintObj then if Assigned(tf.curget) then if tf.SeekFld then begin
          f:=GetParentForm(tf);
          if VisibleNoNil(f) then TIntegerList.Create(ls).Add(LsFormWnd.IndexOf(f),tf);
        end;
      end;
      if Assigned(ls) then begin
        tf:=ls.PointerObj(ls.Count-1); fl := not(ogReadOnly in tf.Options);
        if fl then begin
          tw:=tf;
          while Assigned(tw) do
            if tw.Visible and tw.Enabled then ParentSelf(tw)
            else begin
              fl:=false; break;
            end;
        end;
        if fl then tf.Write;
        tf.curget.LogCompare(tf,Prm);
        if not Prm.lBreak then begin
          v:=tf.PNameRecFld.StrToVar(val); tf.curget.DWFldValue(Sender,tf.Mask,v);
          if MyVarType(v)=varString then if v<>val then begin
            val:=v; lBreak:=true;
          end;
        end;
      end;
    finally
      ls.Free;
    end;
  end;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TSimpleGet,TNumGet,TFldEdit]);
end;

initialization
  AddStack('FFldedit.initialization');
  with TInter do begin
    SetFunction('RecFldZn','',['Табл: строка','Поле: строка','[Знач: любое]',
      '[Сохр: логическое = '+vTrue+']','[ОбнПоля: логическое = '+vFalse+']'],
      ['C','C','','LU','LU'],c_recfldzn,null);
    {SetFunction('RecApp','',['Табл: строка','[Поля: массив]','[Знач: массив]'],['C','AU','AU'],
      c_recapp,null);}
  end;
  AddFrom(DWFldDefaultProc);
  LogTrnsValProcAdd(LogTrnsValProc);
  DelStack;
end.
