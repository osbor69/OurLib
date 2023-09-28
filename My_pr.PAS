unit My_pr;

{$WARN SYMBOL_PLATFORM OFF}

interface
{$I LIBTEST}
{ $DEFINE PROFPARENT}
{ $DEFINE MINMAX}

uses
	Windows,SysUtils,Classes,Graphics,Controls,Forms,Dialogs,ExtCtrls,DB,DBGrids,Registry,Math,ComCtrls,
    Messages,Printers,pFIBDatabase,Grids,Menus,Mask,
  MyTypes;

type
  TFSort = function(p: pointer; fi,si: longint; sortID: TSortID): boolean;
  TProcNetRes = function(const av: array of variant; var NetResource: TNetResource): boolean;
  TProcControls = procedure(Sender: TControl; const av: array of variant; var Done: boolean);
  TMaskFilesProc = procedure(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
  TFindDelProc = procedure(Sender: TObject; const av: array of variant);
  TCtodProtAdd = procedure(const s: string) of object;
  TQuickSortStrComp = function(const v1,v2: string): longint;
  TQuickSortIntComp = function(v1,v2: longint): longint;

  TRasprOstOption = (rspoEqual,rspoSign,rspoSignRest,rspoNoOptim); TRasprOstOptions = set of TRasprOstOption;
  TFileMaskType = set of (fmFiles,fmDir);
  TLsArrDynList = (lsaEnd,lsaSetLen,lsaSort); TLsArrDynOpt = set of TLsArrDynList;
  TAstolinList = (aslnAlign,aslnTrim); TAstolinOpt = set of TAstolinList;
  TOutStackOpt = set of (outstClear,outstMsgOnly,outstAll);
  TCorrDirkList = (crdrNoDlmEnd,crdrNoUpper); TCorrDirkOpt = set of TCorrDirkList;
  TGetMaskFilesOpt = set of (msfAdd,msfNoUpper,msfAge,msfSort);
  TSetRedrawList = (rdrwSet,rdrwNoPaint); TSetRedrawOpt = set of TSetRedrawList;
  TEdoInCaptOpt = set of (edoinNoVdCod,edoinNoCodTrns,edoinNoName,edoinNoPrim,edoinNoD);

  TDateBigOld = array[0..0] of TArrBoolDate;

  TStringListCase = class(TStringList)
  protected
    function CompareStrings(const S1,S2: string): longint; override;
  public
    UpCase: boolean;
    constructor CreateSort;
    class function CreateIf(usl: boolean; ASorted: boolean = false): TStringListCase;
  end;
  TArrStrListCase = array of TStringListCase;

  TStrCustomList = class(TStringList)
  private
    procedure ProcDel(oi,ni: longint);
  protected
    l: longint;
    function CompareStrings(const S1,S2: string): longint; override;
    procedure FSetValue(Index: longint; p: pointer);
    function pGet(Index: longint): pointer; virtual; abstract;
    procedure pSet(Index: longint; p: pointer); virtual; abstract;
    procedure DelValue(Index: longint);
    procedure ProcAdd; virtual; abstract;
    function nIndex(Index: longint; var n: longint): boolean;
  public
    NoDelObj: boolean;
    constructor Create(ASorted: boolean = true; ACapacity: longint = 10); overload; virtual;
    class function Create(var Sender: TStrCustomList; ASorted: boolean = true; ACapacity: longint = 10): TStrCustomList; overload;
    function IgnoreFindAdd(const s: string; var i: longint): boolean; overload;
    procedure Delete(Index: Integer); override;
    procedure Clear; override;
    procedure Init(const AText: string); virtual;
    procedure Assign(Source: TPersistent); override;
  end;

  TStrStrList = class(TStrCustomList)
  private
    a: TArrStr;
    function GetValue(Index: longint): string;
    procedure SetValue(Index: longint; const v: string);
  protected
    procedure SetCapacity(Value: longint); override;
    function pGet(Index: longint): pointer; override;
    procedure pSet(Index: longint; p: pointer); override;
    procedure ProcAdd; override;
  public
    class function CreateIf(usl: boolean; ASorted: boolean = true; ACapacity: longint = 10): TStrStrList;
    function IgnoreFindAdd(const s,v: string; var i: longint): boolean; overload;
    function IgnoreFindAdd(const s: string; const v: string = ''): boolean; overload;
    function FindValue(const s: string): string; overload;
    function FindValue(const s: string; var v: string): boolean; overload;
    procedure Init(const AText: string); override;
    property Value[Index: longint]: string read GetValue write SetValue;
  end;

  TStrDblList = class(TStrCustomList)
  private
    a: TArrDbl;
    function GetValue(Index: longint): Double;
    procedure SetValue(Index: longint; v: Double);
  protected
    procedure SetCapacity(Value: longint); override;
    function pGet(Index: longint): pointer; override;
    procedure pSet(Index: longint; p: pointer); override;
    procedure ProcAdd; override;
  public
    function IgnoreFindAdd(const s: string; v: Double; var i: longint): boolean; overload;
    function IgnoreFindAdd(const s: string; v: Double = 0): boolean; overload;
    function FindValue(const s: string): Double; overload;
    function FindValue(const s: string; var v: Double): boolean; overload;
    procedure Init(const AText: string); override;
    procedure IncValue(Index: longint; v: Double); overload;
    procedure IncValue(const s: string; v: Double); overload;
    property Value[Index: longint]: Double read GetValue write SetValue;
  end;

  TStrVarList = class(TStrCustomList)
  private
    a: TArrVar;
    function GetValue(Index: longint): variant;
    procedure SetValue(Index: longint; const v: variant);
  protected
    procedure SetCapacity(Value: longint); override;
    function pGet(Index: longint): pointer; override;
    procedure pSet(Index: longint; p: pointer); override;
    procedure ProcAdd; override;
  public
    function IgnoreFindAdd(const s: string; const v: variant; var i: longint): boolean; overload;
    function IgnoreFindAdd(const s: string; const v: variant): boolean; overload;
    function FindValue(const s: string): variant; overload;
    function FindValue(const s: string; var v: variant): boolean; overload;
    procedure Init(const AText: string); override;
    property Value[Index: longint]: variant read GetValue write SetValue;
  end;

{$IFDEF MINMAX}
	EOutOfRange = class(EListError);
{$ENDIF}

  TIntegerList = class;

  TIntegerListSortCompare = function(List: TIntegerList; Index1,Index2: longint): Int64;

  TIntegerListOption = (ilsSorted,ilsUnSigned);
  TIntegerListOptions = set of TIntegerListOption;

  TIntegerList = class(TPersistent)
  private
  	FList,FObjects: TList;
    FDuplicates: TDuplicates;
    FOptions: TIntegerListOptions;
{$IFDEF MINMAX}
    FMin,FMax: LongInt;
    procedure ReadMin(Reader: TReader);
    procedure WriteMin(Writer: TWriter);
    procedure ReadMax(Reader: TReader);
    procedure WriteMax(Writer: TWriter);
{$ENDIF}
    procedure ReadIntegers(Reader: TReader);
    procedure WriteIntegers(Writer: TWriter);
    procedure SetOptions(Value: TIntegerListOptions);
    procedure InitObjects(AObject: TObject);
  protected
  	procedure DefineProperties(Filer: TFiler); override;
    function GetCapacity: longint;
    procedure SetCapacity(Value: longint); virtual;
    function GetCount: longint;
    function GetItem(Index: longint): LongInt;
    function GetObject(Index: longint): TObject;
    procedure SetItem(Index: longint; Value: LongInt);
{$IFDEF MINMAX}
    procedure SetMin(Value: LongInt);
    procedure SetMax(Value: LongInt);
{$ENDIF}
    procedure SetObject(Index: longint; Value: TObject);
    procedure Sort; virtual;
  public
  	constructor Create(AOptions: TIntegerListOptions = []); overload;
  	class function Create(usl: boolean; AOptions: TIntegerListOptions = []): TIntegerList; overload;
  	class function Create(var Sender: TIntegerList; AOptions: TIntegerListOptions = []): TIntegerList; overload;
    destructor Destroy; override;
    function Add(Value: LongInt; AObject: TObject = nil): longint; overload;
    function Add(Value: LongInt; AObject: pointer): longint; overload;
    function Add(Value: LongInt; AObject: longint): longint; overload;
    function Add(const Value: string; AObject: TObject = nil): longint; overload;
    function Add(const Value: string; AObject: pointer): longint; overload;
    function Add(const Value: string; AObject: longint): longint; overload;
    function Add(Value: TDateTime; AObject: pointer = nil): longint; overload;
    procedure Add(List: TIntegerList); overload;
    procedure Add(const a: TArrInt; l: longint = NegDef); overload;
    procedure AddTo(var a: TArrInt; var l: longint);
    procedure Assign(Source: TPersistent); override;
    procedure Clear; virtual;
    procedure Delete(Index: longint); virtual;
    procedure ObjIndDel(i: longint; Proc: TSLObjIndProc1; p: pointer = nil; lDel: boolean = true; l: longint = NegDef);
    procedure BoolObjPack(DelTrue: boolean = false);
    function IntObj(i: longint): longint;
    procedure IntObjSelf(var i: longint);
    function IntObjFind(cN: longint): longint; overload;
    function IntObjFind(cN: longint; var n: longint): boolean; overload;
    function IntObjFind(cN: longint; var i,n: longint): boolean; overload;
    function IntObjFindAdd(cN: longint; var n: longint): boolean; overload;
    function IntObjFindAdd(cN: longint; var i,n: longint): boolean; overload;
    function IntObjFindAdd(cN: longint; var i,n,l: longint): boolean; overload;
    function BoolObj(i: longint): boolean;
    function BoolObjFind(cN: longint; var fl: boolean): boolean;
    function LongWordObj(i: longint): longword;
    function PointerObj(i: longint): pointer;
    function PointerObjFind(cN: longint): pointer; overload;
    function PointerObjFind(cN: longint; var p: pointer): boolean; overload;
    function PointerObjFindAdd(cN: longint; var ixS: longint; var p: pointer): boolean;
    procedure IncD(Index: longint; const d2: longint = 1);
    procedure IncObj(Index: longint; const d2: longint = 1);
    function Equals(List: TIntegerList): boolean;
    procedure Exchange(Index1,Index2: longint); virtual;
    function Find(cN: LongInt; var Index: longint): boolean; virtual;
    function IndexOf(N: LongInt): longint; virtual;
    function IndexOfObject(AObject: TObject): longint; virtual;
    procedure Insert(Index: longint; Value: LongInt; AObject: TObject = nil); virtual;
    procedure Move(CurIndex,NewIndex: longint); virtual;
    procedure CustomSort(Compare: TIntegerListSortCompare); virtual;
    function IgnoreFindAdd(Value: LongInt; var ixI: longint): boolean; overload;
    function IgnoreFindAdd(Value: LongInt): boolean; overload;
    function IgnoreFindAdd(Value: LongInt; var ixI: longint; var p: pointer): boolean; overload;
    procedure IgnoreAddDel(Value: LongInt);
    function FindDel(Value: LongInt; Proc: TFindDelProc = nil): boolean; overload;
    function FindDel(Value: LongInt; Proc: TFindDelProc; const av: array of variant): boolean; overload;
    function Text: string;
    procedure SetOption(Option: TIntegerListOption; Value: boolean);
    function QQa: TArrStr;
    function FldInListQQ(const nmf: string): string; overload;
    function FldInListQQ(var ares: TArrStr; const nmf: string): boolean; overload;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    property Capacity: longint read GetCapacity write SetCapacity;
    property Count: longint read GetCount;
    property Items[Index: longint]: LongInt read GetItem write SetItem; default;
{$IFDEF MINMAX}
    property Min: LongInt read FMin write SetMin;
    property Max: LongInt read FMax write SetMax;
{$ENDIF}
    property Objects[Index: longint]: TObject read GetObject write SetObject;
    property Options: TIntegerListOptions read FOptions write SetOptions;
  end;

  TArrBoolIntList = array[boolean] of TIntegerList;

  TIntCustomList = class(TIntegerList)
  protected
    l: longint;
    procedure FSetValue(Index: longint; p: pointer);
    function pGet(Index: longint): pointer; virtual; abstract;
    procedure pSet(Index: longint; p: pointer); virtual; abstract;
    procedure DelValue(Index: longint);
    procedure ProcAdd; virtual; abstract;
    function nIndex(Index: longint; var n: longint): boolean;
    function Add(n: LongInt; var i: longint): boolean; overload;
  public
    NoDelObj: boolean;
    constructor Create(AOptions: TIntegerListOptions = []; ACapacity: longint = 100); virtual;
    procedure Delete(Index: Integer); override;
    procedure Clear; override;
  end;

  TIntStrList = class(TIntCustomList)
  private
    a: TArrStr;
    function GetValue(Index: longint): string;
    procedure SetValue(Index: longint; const v: string);
  protected
    procedure SetCapacity(Value: longint); override;
    function pGet(Index: longint): pointer; override;
    procedure pSet(Index: longint; p: pointer); override;
    procedure ProcAdd; override;
  public
    function Add(n: LongInt; const v: string): boolean; overload;
    function Add(n: LongInt; const v: string; var i: longint): boolean; overload;
    function FindValue(n: LongInt): string; overload;
    function FindValue(n: LongInt; var v: string): boolean; overload;
    property Value[Index: longint]: string read GetValue write SetValue;
  end;

  TIntDblList = class(TIntCustomList)
  private
    a: TArrDbl;
    function GetValue(Index: longint): Double;
    procedure SetValue(Index: longint; v: Double);
  protected
    procedure SetCapacity(Value: longint); override;
    function pGet(Index: longint): pointer; override;
    procedure pSet(Index: longint; p: pointer); override;
    procedure ProcAdd; override;
  public
    function Add(n: LongInt; v: Double): boolean; overload;
    function Add(n: LongInt; v: Double; var i: longint): boolean; overload;
    function FindValue(n: LongInt): Double; overload;
    function FindValue(n: LongInt; var v: Double): boolean; overload;
    procedure IncValue(Index: longint; v: Double);
    property Value[Index: longint]: Double read GetValue write SetValue;
  end;

  TIntVarList = class(TIntCustomList)
  private
    a: TArrVar;
    function GetValue(Index: longint): variant;
    procedure SetValue(Index: longint; const v: variant);
  protected
    procedure SetCapacity(Value: longint); override;
    function pGet(Index: longint): pointer; override;
    procedure pSet(Index: longint; p: pointer); override;
    procedure ProcAdd; override;
  public
    function Add(n: LongInt; const v: variant): boolean; overload;
    function Add(n: LongInt; const v: variant; var i: longint): boolean; overload;
    function FindValue(n: LongInt): variant; overload;
    function FindValue(n: LongInt; var v: variant): boolean; overload;
    property Value[Index: longint]: variant read GetValue write SetValue;
  end;

  TFontIndexList = class(TIntegerList)
  public
    OnGetFont: function(Index: longint): TFont of object;
    function GetFont(Index: longint): TFont;
  end;

  TIniFileOpt = set of (finiNoCngExt,finiNoDelOld,finiNoSort);

  TIniFileReadProc = procedure(Sect,Ident: PString; Prm: pointer) of object;

  TIniFileCheck = class(TStringList)
  private
  	FModified: boolean;
    FFileName: TFileName;
    aSect: array of record
      nInit: longint;
      ls: TStrStrList;
    end;
    function SectAdd(i: longint; nSect: longint = NegDef; SectSorted: boolean = true): longint;
		procedure ClearSection(Index: longint);
		function FValue(ls: TStrStrList; Index: longint): string;
		procedure SectSort;
    procedure ProcDel(oi,ni: longint);
  public
    NoWriteFile: boolean;
    OnUpdate,OnAfterUpdate: TNotifyEvent;
    property FileName: TFileName read FFileName;
  	property Modified: boolean read FModified;
    constructor Create(const FileName: TFileName; OnCreate: TNotifyEvent = nil;
      Opt: TIniFileOpt = []; const ExeName: string = ''; Proc: TIniFileReadProc = nil; Prm: pointer = nil);
    destructor Destroy; override;
    function SectionExists(const Section: string): Boolean;
    function ReadString(const Section,Ident: string; const Default: string = ''): string;
    function ReadInteger(const Section,Ident: string; Default: Longint = 0): Longint; overload;
    class function ReadInteger(const Value: string; Default: Longint = 0): Longint; overload;
    function ReadBool(const Section,Ident: string; Default: Boolean = false): Boolean;
    function ReadDate(const Section,Name: string; Default: TDateTime = 0.0): TDateTime; virtual;
    function ReadDateTime(const Section,Name: string; Default: TDateTime = 0.0): TDateTime;
    procedure WriteString(const Section,Ident,Value: String);
    procedure WriteInteger(const Section,Ident: string; Value: Longint);
    procedure WriteBool(const Section,Ident: string; Value: Boolean);
    procedure WriteDate(const Section,Ident: string; Value: TDateTime);
    procedure WriteDateTime(const Section,Ident: string; Value: TDateTime);
    procedure ReadSection(const Section: string; Strings: TStrings);
    function ReadSectionList(const Section: string; var ls: TStrStrList): boolean;
    procedure ReadSections(Strings: TStrings); overload;
    function ReadSections(var a: TArrStr): longint; overload;
    procedure ReadSectionValues(const Section: string; Strings: TStrings); overload;
    function ReadSectionValues(const Section: string; var a: TArrStr): longint; overload;
    procedure WriteSectionValues(const Section: string; Strings: TStrings);
    procedure EraseSection(const Section: string; CompBeg: boolean = false);
    procedure EraseSections;
    procedure DeleteKey(const Section,Ident: String); overload;
    procedure DeleteKey(ls: TStrStrList; i: longint); overload;
    procedure UpdateFile;
    function ValueExists(const Section,Ident: string): Boolean;
		procedure RenameSection(const oldSect,newSect: string);
    function FindValueIndex(const Section,Ident: string; var ls: TStrStrList; var i: longint): boolean;
  end;

  TInitFIni = class(TComponent)
  private
  	FFiles: array[TFIniType] of TIniFileCheck;
    function GetFiles(Index: TFIniType): TIniFileCheck;
    procedure SchemCreate(Sender: TObject);
    procedure SchemUpdate(Sender: TObject);
  public
    property Files[Index: TFIniType]: TIniFileCheck read GetFiles; default;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateFiles;
    class procedure Init(AOwner: TComponent);
  end;

  TInitBM = class(TComponent)
  public
	  LsBM: TStringList;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
		procedure AddBM(const nm: string);
    function FindBM(const nm: string; var bm: TBitMap): boolean; overload;
    function FindBM(const nm: string): TBitMap; overload;
    function FindBM(const nm: TBMList; var bm: TBitMap): boolean; overload;
    function FindBM(const nm: TBMList): TBitMap; overload;
    class procedure Init(AOwner: TComponent);
  end;

  TIBDatabase = class(TpFIBDatabase)
  public
    destructor Destroy; override;
  end;

  TCustomDataFile = class(TComponent)
  public
		function RecordCount: longint; virtual; abstract;
		procedure First; virtual; abstract;
		procedure Last; virtual; abstract;
    function Eof: boolean; virtual; abstract;
		procedure Close; virtual; abstract;
		function NumFromName(const nmf: string; var i: longint): boolean; virtual; abstract;
    function ValueNum(Index: longint): variant; virtual; abstract;
    function ValueName(const Name: string): variant; virtual; abstract;
    procedure Next; virtual; abstract;
    //function MoveBy(Distance: longint): longint; virtual; abstract;
    function IsField(const FieldName: string): boolean; virtual; abstract;
		function FieldCount: longint; virtual; abstract;
		function FieldName(Index: longint): string; virtual; abstract;
		function DataType(Index: longint): TFieldType; virtual; abstract;
		function FieldLen(Index: longint): Word; virtual; abstract;
		function FieldDec(Index: longint): Byte; virtual;
    function NotNull(Index: longint; p: pointer): boolean; virtual; abstract;
  end;

  TTimerLock = class(TTimer)
  public
    constructor CreateProc(Proc: TNotifyEvent; AOwner: TComponent);
    procedure Timer; override;
  end;

  TTimerOne = class(TTimer)
  protected
    procedure Timer; override;
  public
    Params: TArrVar;
    constructor CreateProc(Proc: TNotifyEvent; AOwner: TComponent); overload;
    constructor CreateProc(Proc: TNotifyEvent; AOwner: TComponent; const AParams: array of variant); overload;
  end;

  TApplTitleProc = procedure(ReDef: boolean) of object;

  TApplTitle = class(TComponent)
  private
    ls: TStringList;
    tmBlink: TTimerLock;
    FReDef: boolean;
    nAct: longint;
    aProc: array of TApplTitleProc;
    procedure tmBlinkTimer(Sender: TObject);
    procedure SetReDef(Value: boolean);
    property ReDef: boolean read FReDef write SetReDef;
  public
    Default: string;
    destructor Destroy; override;
    procedure Add(Proc: TApplTitleProc);
    procedure Del(Proc: TApplTitleProc);
    function SetActive(const S: string; Value: boolean): boolean;
  end;

  TNoneProc = class
  public
		class function ValidFalse(Sender: TObject): boolean;
		class function ValidTrue(Sender: TObject): boolean;
  end;

  TSearchPathGGM = procedure(fIni: TIniFileCheck; const Sect: string; p: pointer; var path: TFileName);

const RadioMaskCntCalc = NegDef-1;

var
  InitFIni: TInitFIni;
  InitBM: TInitBM;

{ Числовые функции }

// Округлить число с указанной точностью
function mround(n: Extended; t: longint = 0): Extended;
procedure MroundSelf(var n: Double; t: longint = 0); overload;
procedure MroundSelf(var n: Extended; t: longint = 0); overload;
procedure MroundSelf(var n: variant; t: longint = 0); overload;
// Округлить число с точностью 0
function nround(n: Extended): Int64;
procedure nroundSelf(var n: variant);
// Преобразовать целое в дробное
function mdouble(n: Int64): Extended;
// Длина целой части числа длиной nLen с точностью nDec
function LenInt(nLen,nDec: longint): longint;
// Результат HexToStr в целое
function HexToInt(const s: string): Int64;
// Остаток от деления dividend на divisor
function ModDiv(var dividend: longint; divisor: longint): longint; overload;
function ModDiv(var dividend: longword; divisor: longword): longword; overload;
// Деление с проверкой делителя на 0
function DivChk(v1,v2: Extended): Extended;
// Sum с проверкой на массив нулевой длины
function Sum0(const Data: array of Double): Extended;
function SumInt0(const Data: array of longint): longint;
// 16-ричн.случайное число
function RandomHex(l: longint = 8): string;
// StrUn
function StrUn(un: longint): string; overload;
function StrUn(f: TField): string; overload;
procedure StrUnSelf(var v: variant);
// Inc
procedure IncD(var d: double; const d2: double); overload;
procedure IncD(var d: Extended; const d2: Extended); overload;
procedure IncD(var d: variant; const d2: variant); overload;
procedure IncD(var d: variant; i: longint; const d2: variant); overload;
//procedure IncD(var d: variant; i1,i2: longint; const d2: variant); overload;
procedure IncD(var d: double; const d2: double; ndec: longint); overload;
procedure IncD(var d: variant; const d2: variant; ndec: longint); overload;
procedure IncD(var d: string; const d2: string); overload;
procedure IncD(var d: TFileName; const d2: string); overload;
procedure IncD(d: PString; const d2: string); overload;
procedure IncD(ls: TStringList; i: longint; const d2: string); overload;
procedure IncD(var d: TDateTime; const d2: TDateTime = 1); overload;
procedure IncD(p: PLongInt; const d2: longint = 1); overload;
procedure IncD(Sender: TFontDialog; Incl: TFontDialogOptions; Excl: TFontDialogOptions = []); overload;
procedure IncD(Sender: TControl; Incl: TControlStyle; Excl: TControlStyle = []); overload;
procedure IncD(var Options: TGetOptions; Incl: TGetOptions; Excl: TGetOptions = []); overload;
procedure IncL(var d: string; const dLeft: string; const dRight: string = ''); overload;
procedure IncL(var d: TFileName; const dLeft: string; const dRight: string = ''); overload;
procedure IncL(var d: variant; const dLeft: string; const dRight: string = ''); overload;
procedure IncL(ls: TStringList; i: longint; const dLeft: string; const dRight: string = ''); overload;
procedure IncLeft(Sender: TControl; const d2: longint);
procedure IncWidth(Sender: TControl; const d2: longint);
// «*»
procedure MultD(var d: Int64; const d2: Int64); overload;
procedure MultD(var d: longint; const d2: longint); overload;
procedure MultD(var d: Word; const d2: Word); overload;
procedure MultD(var d: Extended; const d2: Extended); overload;
procedure MultD(var d: Double; const d2: Double); overload;
procedure MultD(var d: variant; const d2: variant); overload;
// div, «/»
procedure DivD(var d: longint; const d2: longint); overload;
procedure DivD(var d: longword; const d2: longword); overload;
procedure DivD(var d: Extended; const d2: Extended); overload;
procedure DivD(var d: Double; const d2: Double); overload;
procedure DivD(var d: Single; const d2: Single); overload;
procedure DivD(var d: variant; const d2: variant); overload;
// mod
procedure ModD(var d: longint; const d2: longint); overload;
procedure ModD(var d: longword; const d2: longword); overload;
procedure ModD(var d: word; const d2: word); overload;
// shl
procedure ShlD(var d: longint); overload;
procedure ShlD(var d: byte); overload;
procedure ShlD(var d: longword; offs: byte = 1); overload;
// and
procedure AndD(var d: longint; const d2: longint); overload;
procedure AndD(var d: longword; const d2: Int64); overload;
procedure AndD(var d: boolean; const d2: boolean); overload;
// or
procedure Or_D(var d: longint; const d2: longint); overload;
procedure Or_D(var d: longword; const d2: longword); overload;
procedure Or_D(var d: byte; const d2: byte); overload;
procedure Or_D(var d: Int64; const d2: Int64); overload;
procedure Or_D(var d: boolean; const d2: boolean); overload;
// not
procedure NotD(var d: boolean); overload;
procedure NotD(var d: longword); overload;
procedure NotD(var d: variant); overload;
procedure NotD(f: TField); overload;
// Max
procedure MaxSelf(var d: byte; const d2: byte = 0); overload;
procedure MaxSelf(var d: Word; const d2: Word = 0); overload;
procedure MaxSelf(var d: LongWord; const d2: LongWord = 0); overload;
procedure MaxSelf(var d: longint; const d2: longint = 0); overload;
procedure MaxSelf(var d: Int64; const d2: Int64 = 0); overload;
procedure MaxSelf(var d: Double; const d2: Double = 0); overload;
procedure MaxSelf(var d: Extended; const d2: Extended = 0); overload;
procedure MaxSelf(var d: longint; const d2: string); overload;
function MaxSelf(const a: array of string; l: longint = NegDef): longint; overload;
function MaxSelf(ls: TStrings): longint; overload;
procedure MaxSelf(var d: longint; Canvas: TCanvas; const d2: string; nInc: longint = 0; lHeight: boolean = false); overload;
function MaxSelf(Canvas: TCanvas; ls: TStrings; nInc: longint = 0; lHeight: boolean = false): longint; overload;
procedure MaxSelf(var d: longint; Canvas: TCanvas; lHeight: boolean = false); overload;
function MaxSelf(Canvas: TCanvas; const a: array of string; lHeight: boolean = false; l: longint = NegDef): longint; overload;
procedure MaxSelf(var d: TSize; const d2: TSize); overload;
procedure MaxSelf(var d: TSize; Canvas: TCanvas; const d2: string); overload;
procedure MaxSelf(var d: TDateTime; const d2: TDateTime); overload;
// Min
procedure MinSelf(var d: Word; const d2: Word = 0); overload;
procedure MinSelf(var d: longint; const d2: longint = 0); overload;
procedure MinSelf(var d: Int64; const d2: Int64 = 0); overload;
procedure MinSelf(var d: Double; const d2: Double = 0); overload;
procedure MinSelf(var d: TDateTime; const d2: TDateTime); overload;
// EnsureRange
procedure EnsureSelf(var AValue: byte; AMin, AMax: byte); overload;
procedure EnsureSelf(var AValue: Word; AMin, AMax: Word); overload;
procedure EnsureSelf(var AValue: longint; AMin, AMax: longint); overload;
procedure EnsureSelf(var AValue: Double; AMin, AMax: Double); overload;
procedure EnsureSelf(var AValue: Extended; AMin, AMax: Extended); overload;
procedure EnsureSelf(var AValue: TDateTime; AMin, AMax: TDateTime); overload;
// Sign
procedure SignSelf(var AValue: longint);
// Abs
procedure AbsSelf(var AValue: Double);
// IfThen
function IfThen(AValue,ATrue: Boolean; const AFalse: boolean = false): boolean; overload;
function IfThen(AValue: boolean; ATrue: pointer; AFalse: pointer = nil): pointer; overload;
function IfThen(ATrue: pointer; AFalse: pointer): pointer; overload;
//function IfThen(AValue: boolean; ATrue: TWindowState; AFalse: TWindowState = wsNormal): TWindowState; overload;
function IfThen(AValue: boolean; ATrue: TBevelCut; AFalse: TBevelCut = bvNone): TBevelCut; overload;
function IfThen(AValue: boolean; ATrue: TLsArrDynList): TLsArrDynOpt; overload;
function IfThen(AValue: boolean; ATrue: TSetRedrawList): TSetRedrawOpt; overload;
function IfThen(AValue: boolean; ATrue: TRunExeList): TRunExeOpt; overload;
function IfThen(AValue: boolean; ATrue,AFalse: TAdrList): TAdrList; overload;
function IfThen(AValue: boolean; ATrue: TFldInListList): TFldInListOpt; overload;
function IfThen(AValue: boolean; ATrue,AFalse: TDWActionList): TDWActionList; overload;
function IfThen(AValue: boolean; ATrue: TDWWinRdbDefOpt; AFalse: TDWWinRdbDefOpt = dwdefSeek): TDWWinRdbDefOpt; overload;
function IfThen(AValue: boolean; ATrue: TEdTextList): TEdTextOpt; overload;
function IfThen(AValue: boolean; ATrue: TTrnsEndList): TTrnsEndOpt; overload;
function IfThen(AValue: boolean; ATrue: TProtocolAddList): TProtocolAddOpt; overload;
function IfThen(AValue: boolean; ATrue: TBrAppList): TBrAppOpt; overload;
function IfThen(Key: longint): TBrAppOpt; overload;
function IfThen(AValue: boolean; ATrue: TDiskWaitList): TDiskWaitOpt; overload;
function IfThen(AValue: Boolean; const ATrue: TFdpState; const AFalse: TFdpState = fdpView): TFdpState; overload;
function IfThen(AValue: boolean; ATrue: TFEReadList): TFEReadOpt; overload;
function IfThen(AValue: Boolean; const ATrue,AFalse: TGFSearchType): TGFSearchType; overload;
function IfThen(AValue: boolean; const ATrue,AFalse: TPoint): TPoint; overload;
function IfThen(AValue: boolean; ATrue: TRDBDelList): TRDBDelOpt; overload;
function IfThen(AValue: boolean; ATrue: TRDBNewList): TRDBNewOpt; overload;
function IfThen(AValue: boolean; ATrue: TGetOption): TGetOptions; overload;
function IfThen(AValue: boolean; ATrue: TGetOptions; AFalse: TGetOptions = []): TGetOptions; overload;
function IfThen(AValue: boolean; ATrue: TGFReplaceList): TGFReplaceOpt; overload;
function IfThen(AValue: boolean; ATrue: TCopyFileOption): TCopyFileOptions; overload;
function IfThen(AValue: boolean; ATrue: TRasprOstOption): TRasprOstOptions; overload;
function IfThen(AValue: boolean; ATrue: TShiftState): TShiftState; overload;
function IfThen(AValue: boolean; ATrue: TStrTableFillList): TStrTableFillOpt; overload;
function IfThen(AValue: boolean; ATrue: TFindOptions; AFalse: TFindOptions = []): TFindOptions; overload;
function IfThen(AValue: boolean; ATrue: TFontStyles; AFalse: TFontStyles = []): TFontStyles; overload;
function IfThen(const AValue: variant; ATrue: TAstolinList): TAstolinOpt; overload;
function IfThen(const a: array of string): string; overload;
function IfThen(Sender: TStrings): string; overload;
function IfThen(const Cond,ACond,AVal,Def: variant): variant; overload;
function IfThenArr(const av: variant; i: longint; const Def: variant): variant; overload;
function IfThenArr(const av: array of variant; i: longint; const Def: variant): variant; overload;
function IfThenChar(AValue: boolean; ATrue: char; AFalse: char = ' '): char;
function IfThenCount(Sender: TStrings): longint;
function IfThenDataSet(AValue: boolean; ATrue: TDataSetNotifyEvent; AFalse: TDataSetNotifyEvent = nil): TDataSetNotifyEvent; overload;
procedure IfThenDataSet(Proc: TDataSetNotifyEvent; DataSet: TDataSet); overload;
function IfThenStr(Proc: TStringEvent; Sender: TObject = nil): string; overload;
function IfThenStr(var s: string; Proc: TStringEvent; Sender: TObject = nil): boolean; overload;
procedure IfThenMouse(Proc: TMouseEvent; Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure IfThenMouseMove(Proc: TMouseMoveEvent; Sender: TObject; Shift: TShiftState; X, Y: Integer);
function IfThenShowHint(Proc: TShowHintEvent; var HintStr: string; var CanShow: Boolean; var HintInfo: THintInfo): boolean;
procedure IfThenDWFldList(Proc: TDWFldListProc; var sDat,sWnd: string);
procedure IfThenClose(Proc: TCloseEvent; Sender: TObject; var Action: TCloseAction);
procedure IfThenWndMethod(Proc: TWndMethod; var Message: TMessage);
function IfThenTrans(Proc: TPrimTrans; const s: string): string;
procedure IfThenFilterRecord(Proc: TFilterRecordEvent; DataSet: TDataSet; var Accept: Boolean);
procedure IfThenKeyProc(Proc: TKeyProc; key: longint; tw: TWinControl);
function IfThenComp(AValue: boolean; ATrue: TProcStrComp; AFalse: TProcStrComp = nil): TProcStrComp;
function IfThenNotify(AValue: boolean; ATrue: TNotifyEvent; AFalse: TNotifyEvent = nil): TNotifyEvent; overload;
function IfThenNotify(ATrue: TNotifyEvent; AFalse: TNotifyEvent): TNotifyEvent; overload;
function IfThenNotify(Proc: TNotifyEvent; Sender: TObject = nil): boolean; overload;
function IfThenValid(AValue: boolean; ATrue: TProcValid; AFalse: TProcValid = nil): TProcValid; overload;
function IfThenValid(ATrue: TProcValid; AFalse: TProcValid): TProcValid; overload;
function IfThenValid(Proc: TProcValid; Sender: TObject; Def: boolean = true): boolean; overload;
function IfThenValid0(AValue: boolean; ATrue: TProcValid0; AFalse: TProcValid0 = nil): TProcValid0; overload;
function IfThenValid0(Proc: TProcValid0; Def: boolean = true): boolean; overload;
function IfThenFieldGetText(AValue: boolean; ATrue: TFieldGetTextEvent; AFalse: TFieldGetTextEvent = nil): TFieldGetTextEvent;
function IfThenDrawCell(AValue: boolean; ATrue: TDrawCellEvent; AFalse: TDrawCellEvent = nil): TDrawCellEvent; overload;
procedure IfThenDrawCell(Proc: TDrawCellEvent; Sender: TObject; ACol, ARow: Longint; const Rect: TRect; State: TGridDrawState); overload;
function IfThenCng(AValue: boolean; ATrue: TFEChangeEvent; AFalse: TFEChangeEvent = nil): TFEChangeEvent; overload;
procedure IfThenCng(Proc: TFEChangeEvent; Sender: TObject; const OldVal: variant; FromShow: boolean); overload;
function IfThenVarEvent(AValue: boolean; ATrue,AFalse: TVarEvent): TVarEvent;
function IfThenGetText(Sender: TMaskEdit): string; overload;
function IfThenAsk(usl: boolean; const a: array of string; State: boolean = true;
  const Capt: TCaption = ''; Algm: TAlignment = taCenter): boolean;
function IfThenTrnsStart(usl: boolean; const aTable: array of string; flLock: longint = 0;
  ProcLock: TProcLock = nil; lSetDBS: boolean = false): boolean;
procedure IfThenDDatSetVal(Proc: TDDatSetValProc; op: TDDatSetValOper; var result: boolean);
procedure IfThenPrivProc(Proc: TPrivProc; const Priv: string; var result: boolean);
function IfThenDWCanDel(Proc: TDWCanDelEvent; Sender: TObject; const VarName,MsgName: string): boolean;
procedure IfThenDWCngName(Proc: TDWCngNameEvent; Sender: TObject; const OldName,NewName: string; var result: boolean);

{ Функции работы со массивами }

// Сумма 2-х массивов
procedure AddFrom(var Dest: TArrStr; const Source: array of string); overload;
procedure AddFrom(var Dest: TArrStr; const Source: string); overload;
procedure AddFrom(var Dest: TArrStr; var lDest: longint; const Source: string); overload;
procedure AddFrom(var Dest: TArrInt; var lDest: longint; Source: longint); overload;
procedure AddFrom(Dest: TStringList; const Source: array of string; l: longint = NegDef); overload;
function AddFrom(const av1,av2: variant; low2: boolean = false): variant; overload;
procedure AddFrom(var Dest: TArrProcNone; Proc: TProcNone); overload;
procedure AddFrom(var Dest: TKeyEvalProcArr; Proc: TKeyEvalProc); overload;
procedure AddFrom(var Dest: TArrObject; Source: TObject); overload;
procedure AddFrom(Dest,Source: TList); overload;
procedure AddFrom(Proc: TBrEditProc); overload;
procedure AddFrom(Proc: TDWFldDefaultProc); overload;
procedure AddFrom(Proc: THelpTblProc); overload;
procedure AddFrom(Proc: THelpCntProc); overload;
procedure AddFrom(Proc: THelpLinkProc); overload;
procedure AddFrom(Proc: TMDInterVarCreate); overload;
procedure AddFrom(Proc: TEdoProc); overload;
procedure AddFrom(Proc: TRegsDelProc); overload;
procedure AddFrom(Proc: TDDatLsProc); overload;
procedure AddFromSelf(var av1: variant; const av2: variant; low2: boolean = false); overload;
procedure AddFromSelf(var av1: variant; i: longint; const av2: variant; low2: boolean = false); overload;
procedure AddFromInt(var Dest: TArrInt; const Source: array of longint); overload;
procedure AddFromInt(var Dest: TArrInt; Source: longint); overload;
procedure AddFromVArr(var Dest: TArrVar; const Source: array of variant);
procedure AddFromNamePrim(var Dest: TArrNamePrimStr; const Source: array of TNamePrimStr);
procedure InsFrom(var Dest: TArrStr; const Source: array of string);
// Скопировать массив
procedure CopyFrom(var Dest: TArrStr; const Source: array of string); overload;
procedure CopyFrom(var Dest: TArrStr; const Source: string = ''); overload;
procedure CopyFrom(var Dest: TArrStr; Source: TStrings); overload;
procedure CopyFrom(var Dest: TArrVar; Source: TStrings); overload;
procedure CopyFrom(var Dest: TDEPrmVar; const Source: TDEPrmStr); overload;
procedure CopyFrom(var Dest: TModelPrim; const Source: TModelPrim); overload;
function CopyFrom(const Source: array of string): TArrStr; overload;
function CopyFrom(const Source: string): TArrStr; overload;
function CopyFrom(Source: TStringList): TArrStr; overload;
procedure CopyFromInt(var Dest: TArrInt; const Source: array of longint); overload;
procedure CopyFromInt(var Dest: TArrInt; Source: longint); overload;
procedure CopyFromVArr(var Dest: TArrVar; const Source: array of variant); overload;
//function CopyFromVArr(const Source: array of variant): TArrVar; overload;
function CopyFromVar(var aDest: TArrStr; const aSource: variant): boolean; overload;
function CopyFromVar(var aDest: TArrInt; const aSource: variant): boolean; overload;
function CopyFromVar(var aDest: TArrVar; const aSource: variant): boolean; overload;
// Удалить из массива
procedure DelFrom(var Dest: TArrProcNone; Proc: TProcNone);
// Инициализация массива
procedure InitArr(var Dest: array of variant; nbeg: longint = 0; nend: longint = MaxInt); overload;
procedure InitArr(var Dest: array of variant; nbeg,nend: longint; const Value: variant); overload;
procedure InitArr(var Dest: array of string; nbeg: longint = 0; nend: longint = MaxInt; const Value: string = ''); overload;
//procedure InitArr(var Dest: variant); overload;
// Установка длины и инициализация массива
procedure InitArrLen(var Dest: TArrStr; l: longint); overload;
procedure InitArrLen(var Dest: variant; LowLim,HighLim: longint; const Value: variant); overload;
// Распределить сумму пропорционально элементам массива
procedure RasprOst(var av: array of double; tr: byte; sr: Double; l: longint; Options: TRasprOstOptions = []); overload;
procedure RasprOst(var av: array of double; tr: byte; sr: Double; Options: TRasprOstOptions = []); overload;
procedure RasprOst(var av: array of longint; sr: longint; Options: TRasprOstOptions = []); overload;
function RasprOst(const av: TArrArrVar; tr: byte; const sr: TArrDbl; const prior: TArrInt): TArrDbl; overload;
// Поиск числа в массиве
function ArrIntIndex(v: longint; const a: array of longint): longint;
function ArrIntMatch(v: longint; const a: array of longint): boolean;
function ArrIntFind(v: longint; const a: array of longint; LowLim: longint; var Index: longint): boolean; overload;
function ArrIntFind(v: longint; const a: array of longint; var Index: longint): boolean; overload;
// Сортировка массива
procedure QuickSort(proc: TFSort; p: pointer; l,h: longint); overload;
procedure QuickSort(proc: TQuickSortStrComp; var a: TArrStr; l: longint = NegDef); overload;
procedure QuickSort(proc: TQuickSortIntComp; var a: TArrInt; l: longint = NegDef); overload;
procedure QuickSort(var a: TArrStr; l: longint = NegDef; lCase: boolean = false); overload;
procedure QuickSort(var a: TArrInt; l: longint = NegDef); overload;
// Поиск в отсортированном массиве
function QuickFind(var Index: longint; const v: string; const a: TArrStr; la: longint = NegDef; lCase: boolean = false): boolean; overload;
function QuickFind(const v: string; const a: TArrStr; la: longint = NegDef; lCase: boolean = false): boolean; overload;
function QuickFind(var Index: longint; v: longint; const a: TArrInt; la: longint = NegDef): boolean; overload;
function QuickFind(v: longint; const a: TArrInt; la: longint = NegDef): boolean; overload;
function QuickIndexOf(const v: string; const a: TArrStr; la: longint = NegDef; lCase: boolean = false): longint;
// Массив строк - в TStringList
procedure ArrStr2Ls(const a: array of string; ls: TStrings; l: longint = NegDef);
// Удалить в массиве a элемент с номером n
procedure ArrDel(var a: TArrStr; n: longint); overload;
procedure ArrDel(var a: TArrVar; n: longint); overload;
procedure ArrProcNone(const a: TArrProcNone);

{ Функции работы со строками }
// n пробелов
function Space(n: longint): string;
procedure SpaceSelf(var s: string); overload;
procedure SpaceSelf(var s: variant); overload;
// Вместо FloatToStrF
function MyFloatToStr(Value: Extended; Precision,Digits: longint): string;
// Добавить слева пробелы до длины nlen с точностью ndec
function SpaceStr(const st: variant; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true): string;
procedure SpaceStrSelf(var st: string; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true); overload;
procedure SpaceStrSelf(var st: variant; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true); overload;
procedure SpaceStrSelf(var av: array of variant; i: longint; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true); overload;
procedure SpaceStrSelf(ls: TStrings; i: longint; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true); overload;
procedure SpaceStrSelf(var a: TArrStr; l: longint = NegDef; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true); overload;
procedure SpaceStrList(ls: TStrings; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true);
// Добавить слева пробелы до длины nlen с точностью ndec.
// Если пустая строка, то '0'
function SpaceStr0(const s: variant; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true): string;
procedure SpaceStr0Self(var st: string; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true); overload;
procedure SpaceStr0Self(var st: variant; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true); overload;
// Добавить слева нули до длины n
function NumStr(const s: variant; n: longint = NegDef): string;
procedure NumStrSelf(var s: string; n: longint = NegDef); overload;
procedure NumStrSelf(var s: variant; n: longint = NegDef); overload;
procedure NumStrSelf(ls: TStrings; i: longint; n: longint = NegDef); overload;
// Перевод строки в число без учёта завершающих нечисловых символов
function Int0(const ss: string): longint;
procedure Int0Self(var v: variant);
function Int064(const ss: string): Int64;
function StrInt(const ss: string): string;
function IsStrInt(const ss: string): boolean;
function Str2Int(const s: string): longint;
function Str2IntEq(var Dest: Int64; const s: string; Source: Int64): boolean; overload;
function Str2IntEq(const s: string; Source: Int64): boolean; overload;
function Str2IntNeg(var Dest: Int64; const s: string): boolean; overload;
//function Str2IntNeg(const s: string): boolean; overload;
// Перевод строки в число с плав.точкой без учёта
// завершающих нечисловых символов
function Float0(const s: string): Extended;
procedure Float0Self(var ss: variant);
// Добавить слева символ c до длины n
function PadL(const s: string; n: longint; c: Char = ' '): string;
procedure PadLSelf(var s: string; n: longint; c: Char = ' '); overload;
procedure PadLSelf(var s: variant; n: longint; c: Char = ' '); overload;
procedure PadLSelf(ls: TStrings; i: longint; n: longint; c: Char = ' '); overload;
// Добавить справа символ c до длины n
function PadR(const s: string; n: longint; c: Char = ' '): string;
procedure PadRSelf(var s: string; n: longint; c: Char = ' '); overload;
procedure PadRSelf(var s: variant; n: longint; c: Char = ' '); overload;
procedure PadRSelf(ls: TStrings; i: longint; n: longint; c: Char = ' '); overload;
// Отцентрировать строку по длине n с добавлением слева и справа символа c
function PadC(const s: string; n: longint; c: Char = ' '): string;
// Меняет в строке s все строки ss на строку sr
function StrTran(const s,ss: string; const sr: string = '';
  Flags: TReplaceFlags = [rfReplaceAll]; pCnt: PLongInt = nil): string; overload;
procedure StrTranSelf(var s: string; const ss: string; const sr: string = '';
  Flags: TReplaceFlags = [rfReplaceAll]; pCnt: PLongInt = nil); overload;
procedure StrTranSelf(var s: variant; const ss: string; const sr: string = '';
  Flags: TReplaceFlags = [rfReplaceAll]; pCnt: PLongInt = nil); overload;
procedure StrTranSelf(ls: TStrings; const ss: string; const sr: string = '';
  Flags: TReplaceFlags = [rfReplaceAll]; pCnt: PLongInt = nil); overload;
// Меняет в строке s все строки элементов sa на элементы ra
function StrTran(const s: string; const sa,ra: array of string;
  Flags: TReplaceFlags = [rfReplaceAll]; pCnt: PLongInt = nil): string; overload;
procedure StrTranSelf(var s: string; const sa,ra: array of string;
  Flags: TReplaceFlags = [rfReplaceAll]; pCnt: PLongInt = nil); overload;
procedure StrTranSelf(var s: variant; const sa,ra: array of string;
  Flags: TReplaceFlags = [rfReplaceAll]; pCnt: PLongInt = nil); overload;
// Убирает в строке s справа l символов
procedure DecLen(var s: string; l: longint = 1); overload;
procedure DecLen(var s: TFileName; l: longint = 1); overload;
procedure DecLen(var s: TArrStr; l: longint = 1); overload;
procedure DecLen(var s: string; const sr: string); overload;
// Copy
procedure CopySelf(var S: string; Index: longint; Count: longint = MaxInt); overload;
procedure CopySelf(var S: variant; Index: longint; Count: longint = MaxInt); overload;
// StuffString
procedure StuffStrSelf(var AText: string;
  AStart, ALength: longword; const ASubText: string); overload;
procedure StuffStrSelf(var AText: variant;
  AStart, ALength: longword; const ASubText: string); overload;
procedure StuffStrSelf(ls: TStrings; i: longint;
  AStart, ALength: longword; const ASubText: string); overload;
// LeftStr
procedure LeftSelf(ls: TStrings; i: longint; const ACount: longint);
// RightStr
procedure RightSelf(var AText: string; const ACount: longint);
// IntToStr
function Int2StrDef(i: longint; const Def: string = ''): string;
function IntToStrSelf(var v: variant): boolean;
function Int2Str(const Value: variant): string; overload;
function Int2Str(Value: pointer): string; overload;
function Int2Str(Sender: TStrings; Index: longint): string; overload;
function Int2Str(Sender: TStringGrid; ACol,ARow: longint): string; overload;
function Int2Str(Value: boolean): string; overload;
function Int2Str(Value: TSortMode; lPage: boolean = false): string; overload;
// AnsiUpperCase
procedure AnsiUpperCaseSelf(var s: string); overload;
procedure AnsiUpperCaseSelf(var s: TFileName); overload;
procedure AnsiUpperCaseSelf(var s: variant); overload;
// Trim
procedure TrimSelf(var s: string); overload;
procedure TrimSelf(var s: variant); overload;
procedure TrimSelf(ls: TStrings); overload;
procedure TrimSelf(ls: TStrings; i: longint); overload;
procedure TrimSelf(var a: array of string; l: longint = NegDef); overload;
// TrimLeft
procedure TrimLeftSelf(var s: string);
// TrimRight
procedure TrimRightSelf(var s: string); overload;
procedure TrimRightSelf(var s: variant); overload;
procedure TrimRightSelf(var a: TArrStr; l: longint = NegDef); overload;
// Перевод в верхний регистр без пробелов
function TrimUpper(const s: string): string;
procedure TrimUpperSelf(var s: string); overload;
procedure TrimUpperSelf(var s: variant); overload;
procedure TrimUpperSelf(var a: TArrStr); overload;
procedure TrimUpperSelf(ls: TStrings; i: longint); overload;
procedure TrimUpperSelf(var a: TDEPrmStr); overload;
function RTrimUpper(const s: string): string;
procedure RTrimUpperSelf(var s: string);
function RSpTrimUpper(const s: string): string;
// Символ в верхний регистр
procedure UpCaseSelf(var c: char);
// Символ в нижний регистр
function LowCase(c: char): char;
procedure LowCaseSelf(var c: char); 
// Является ли символ числовым
function IsDigit(c: Char): boolean;
// Является ли символ из слова
function IsChrWord(c: Char): boolean;
// Сжать строку за счёт повторяющихся пробелов
function DelTrim(const st: string; const chars: string = ''): string;
procedure DelTrimSelf(var st: string; const chars: string = ''); overload;
procedure DelTrimSelf(var st: variant; const chars: string = ''); overload;
// Строку - в логическое
function StrToBoolean(const v: variant): boolean; overload;
function StrToBoolean(Field: TField): boolean; overload;
function StrToBoolean(Column: TColumn): boolean; overload;
procedure StrToBoolSelf(var v: variant);
// Строку с разделителями - в массив строк
function listasarray(const s: string; var a:array of string;
	const sep: string; lend: boolean = true): longint;
procedure TokenStr(const str,d: string; var sa: TArrStr; trimItems: boolean=false);
function ExpDynArrSz(highIx: longint): longint;
// Строку с разделителями - в TStringList
procedure LsArrList(const s: string; lstr: TStringList; const sep: string; lClear: boolean = true);
// Строку с разделителями - в массив строк
// (без последнего пустого элемента)
function LsArrNoEnd(const s: string; var a: array of string;
	const sep: string): longint;
// Строку с разделителями - в массив строк (дополнить fill)
function LsArrFill(const s: string; var a: array of string; const sep: string): longint;
// Строку с разделителями - в динамический массив строк
function LsArrDynamic(const s: string; var a: TArrStr; const sep: string; Opt: TLsArrDynOpt = []): longint; overload;
function LsArrDynamic(const s: string; var a: TArrStr; const sep: string; Opt: TLsArrDynList): longint; overload;
// Массив строк - в строку с разделителями
function ArrayAsList(const a: array of string; const sep: string;
	cnt: longint = NegDef; SepEnd: boolean = false; beg: longint = 0): string;
// Установка/сброс байта poz в строке s.
// Если zn не boolean, возвращает значение байта.
function SetByte(var s: string; poz: longint; const zn: variant): boolean; overload;
function GetByte(const s: string; poz: longint): boolean; overload;
function GetByte(const s: string; var bset: TBoolSet): boolean; overload;
procedure GetByteSelf(var AValue: variant; poz: longint);
// Установка всех байтов
procedure SetByte(var s: string; const aPoz: array of longint); overload;
procedure SetByte(var s: string); overload;
function SetByte(const aPoz: array of longint): string; overload;
function SetByte(l: longint): string; overload;
function SetByteSet(bset: TBoolSet): string; 
// Установка/сброс байта poz в части part строки s.
function SetByte(var s: string; part,poz: longint; const zn: variant): boolean; overload;
function GetByte(const s: string; part,poz: longint): boolean; overload;
// Инверсия байтов
function NoBytes(const s: string): string;
// Установка/сброс бита poz в строке s.
// Если zn не boolean, возвращает значение бита.
function SetBit(var s: string; poz: longint; const zn: variant): boolean; overload;
function GetBit(const s: string; poz: longint): boolean;
// Установка всех битов
//procedure SetBit(var s: string; const aPoz: array of longint); overload;
function SetBit(l: longint; Value: boolean = true): string; overload;
// Маска для ввода числа длиной l с точностью t
function MaskNum(l: longint; t: longint = 0; Sign: boolean = true): string;
// Заменить пробелы символом c
function zpp(const s: string; const ln: variant; const c: Char = '_'): string;
// Дополняет строку слева символом c
function zppl(const s: string; const ln: variant; const c: Char = '_'): string;
// Дополняет строку справа символом c
function zppr(const s: string; const ln: variant; const c: Char = '_'): string;
// Центрирует строку и заменяет пробелы символом c
function zppc(const s: string; const ln: variant; const c: Char = '_'): string;
// Разбивает строку s на nk строк длиной ln.
// aslnAlign - выравнивание по ширине, aslnTrim - убрать пробелы справа в каждой строке
procedure astolin(const st: string; ls: TStringList; nk,ln: longint; Opt: TAstolinOpt = []); overload;
// Разбить текст по ширине в пикселах
function astolin(Canvas: TCanvas; const st: string; w: longint; h: longint = 0;
	PrcSpMin: Word = 0; pEnd: PLongInt = nil; RateX: Double = 1; RateY: Double = 1; lsFont: TFontIndexList = nil): string; overload;
// Возвращает строку из элементов массива
function astolin(const s: string; nk,ln: longint; Opt: TAstolinOpt = []): string; overload;
// Возвращает указанный элемент массива
function astolin(const s: string; nk,ln,n: longint; Opt: TAstolinOpt = []): string; overload;
// Поиск подстроки в строке справа
function RPos(const Substr,S: string): longint;
// Цена прописью
function cenaprop(c: double; kind: byte = 0): string;
// Первая буква - заглавная
function FRup(const s: string): string;
procedure FRupSelf(var s: string); overload;
procedure FRupSelf(var s: variant); overload;
// Первая буква - прописная
function FLow(const s: string): string;
// Возвращает первый символ в строке
function StrToChar(const s: string): Char;
// Соответствует ли строка Source шаблону Shape
function EqualShape(const cSource,cShape: string): boolean;
// Сравнение строк через CompBegStr или EqualShape
function ProcStrComp(const sl: string; pShape: PLongint = nil): TProcStrComp;
// Часть длинной строки, обрывается "..."
function Str3t(const s: string; l: longint; lTrim: boolean = false): string;
procedure Str3tSelf(var s: string; l: longint; lTrim: boolean = false);
// Корректировка строки с CRLF-ми
function TextCRLF(const s: string): string;
procedure TextCRLFSelf(var s: string);
// Выровнять текст
function ArrStrAlign(var a: TArrStr; var l: longint; w,h: longint; Bound: boolean = false): string;
// Разделитель между двумя строками
function DlmBetween(const ss1,ss2,Dlm: string; lTrim: boolean = true): string; overload;
procedure DlmBetwSelf(var s1: string; const s2,Dlm: string; lTrim: boolean = true); overload;
procedure DlmBetwSelf(var s1: variant; const s2,Dlm: string; lTrim: boolean = true); overload;
procedure DlmBetwSelf(ls: TStrings; const Name,s2,Dlm: string; lTrim: boolean = true); overload;
function DlmBetween(const a: array of string; const Dlm: string; lTrim: boolean = true): string; overload;
// Убрать слева и справа только пробелы
function TrimSp(const S: string): string;
// Убрать слева только пробелы
function TrimSpLeft(const S: string): string;
// Убрать справа только пробелы
function TrimSpRight(const S: string; c: TCharSet = [' ']): string;
// Добавление непустой строки s в ls до длины nlim
procedure AddSzStrings(ls: TStringList; const s: string; nlim: longint = 8);
// Преобразование строки s длиной l в соответствии с маской m
function TransMask(const s: string; l: longint; m: TMyMask; Proc: TTransEvent = nil; Sender: TObject = nil): string;
// Количество символов c в начале строки s
function CntCharBeg(const s: string; c: Char): longint;
// Строка из Count частей, разделённых Dlm, из строки s, начиная с части Index
function DlmCopy(const s: string; Index: longint = 1; Count: longint = MaxInt;
	const Dlm: string = ','; lNeg: boolean = false): string;
procedure DlmCopySelf(var s: string; Index: longint = 1; Count: longint = MaxInt;
	const Dlm: string = ','; lNeg: boolean = false); overload;
procedure DlmCopySelf(var s: variant; Index: longint = 1; Count: longint = MaxInt;
	const Dlm: string = ','; lNeg: boolean = false); overload;
// Вместо NewStr
function NewString(const S: string = ''): PString;
// Начинается ли строка s на строки массива a
function ACompStr(var st: string; const a: array of string): boolean;
// Перевод числа в строку с римскими цифрами
function DigRoman(n: longint): string;
// Memo-строки длиной ln высотой nk
function TrimMemoStr(const s: string; nk,ln: longint): string;
// UpCase для русских букв
function AnsiUpCase(c: char): char;
// Сменить язык введённого текста
function CngLanguage(const s: string): string;
// Транслитерация
function TransLiteration(const s: string; stRus: TBoolSet): string;
procedure TransLitSelf(var s: string; stRus: TBoolSet); overload;
procedure TransLitSelf(ls: TStrings; i: longint; stRus: TBoolSet); overload;
// Слева и справа по пробелу
function SpaceCapt(const s: string): string; overload;
function SpaceCapt(const a: array of string; l: longint = NegDef): string; overload;
procedure SpaceCaptSelf(var s: string); overload;
procedure SpaceCaptSelf(var s: variant); overload;
// Наименование с номером в конце
function StrNum(const Capt: string; const n: variant; l: byte = 0): string;
procedure StrNumSelf(var Capt: string; const n: variant; l: byte = 0);
// Length(IntToStr
function LenIntStr(Value: longint): byte;
// Наименование с номером в конце в скобках
function BracketInt(const Capt: string; n: longint; l: byte = 0): string;
procedure BracketIntSelf(var Capt: string; n: longint; l: byte = 0);
// UNICODE
function UnicodeSize(const s: string): TUnicodeSize;
function WinToUnicode(const s: string; Size: TUnicodeSize = 2): string;
function UnicodeToWin(const s: string): string; // Не стирать!!!
function Utf16ToWin(const s: string): string;
function WinToUtf8(const s: string): string;
function Utf8ToWin(const s: string; IsUtf8: PBoolean = nil): string;
procedure Utf8ToWinSelf(var s: string);
// Число,дату - в строку (формат из Prm)
function FmtNum(Value: Extended; const Prm: TFmtNum; psZero: PBoolean = nil): string; overload;
procedure FmtNumSelf(var Value: variant; const Prm: TFmtNum; psZero: PBoolean = nil);
function FmtDate(Value: TDateTime; const Prm: TFmtDate; psZero: PBoolean = nil): string; overload;
function GFFmtStr(var Value: variant; const Params: TGFParams; nParam: longint;
  psZero: PBoolean = nil): boolean;
// Число,дата по умолчанию
function FmtNum: TFmtNum; overload;
function FmtDate: TFmtDate; overload;
// Формат числа,даты из массива
procedure FmtNum(var Prm: TFmtNum; const av: variant); overload;
procedure FmtDate(var Prm: TFmtDate; const av: variant); overload;
// Переводит число n в строку по системе счисления, равной длине a
function IntToCharNum(n: longword; const a: array of char; l: longint = 0): string;
// Copy с отрицательным началом и длиной
function SubStr(const s: string; Index: longint = 1; Count: longint = MaxInt): string;
procedure SubStrSelf(var s: string; Index: longint = 1; Count: longint = MaxInt); overload;
procedure SubStrSelf(var s: variant; Index: longint = 1; Count: longint = MaxInt); overload;
procedure SubStrSelf(var s: TFileName; Index: longint = 1; Count: longint = MaxInt); overload;
// Удаляет sDel слева в строке s
function LeftStrDel(const s: string; const sDel: string): string;
function LeftSelfDel(var s: string; const sDel: string): boolean;
// Удаляет sDel справа в строке s
function RightStrDel(const s: string; const sDel: string): string;
function RightSelfDel(var s: string; const sDel: string): boolean;
// AnsiStartsStr для массива строк
function AnsiStartsArr(const ASubText: array of string; const AText: string): boolean; overload;
function AnsiStartsArr(const ASubText: array of string; const AText: string; var i: longint): boolean; overload;
// Поиск в ls строки, начинающейся на sbeg
function FindStartsStrList(ls: TStringList; const sbeg: string): boolean; overload;
function FindStartsStrList(ls: TStringList; const sbeg: string; var i: longint): boolean; overload;
// Есть ли s в ls
function InStrList(ls: TStrings; const s: string; IfLsNil: boolean = false): boolean;
// Обрамление строки @cPart и @
function AtPartToStr(const AtPart,cPart: string): string;
function StrToAtPart(const s: string; var AtPart: string; const cPart: string): string;
function StrToAtPartSelf(var s: string; var AtPart: string; const cPart: string): boolean;
// Поиск AText в AValues
function AnsiFindText(const AText: string; const AValues: array of string; LowLim: longint;
  var Index: longint): boolean; overload;
function AnsiFindText(const AText: string; const AValues: array of string; var Index: longint): boolean; overload;
function AnsiFindChar(const AText: string; const AValues: array of char; LowLim: longint;
  var Index: longint): boolean; overload;
function AnsiFindChar(const AText: string; const AValues: array of char; var Index: longint): boolean; overload;
function AnsiFindChar(const AText: string; const AValues: array of char): boolean; overload;
// Строка с заменой непечатных символов на <код>
function TrnsABC(const s: string): string;
// Количество вхождений SubStr в S
function StrCount(const SubStr,S: string): longint; overload;
function StrCount(SubStr: char; const S: string): longint; overload;
function StrCount(const S: string): longint; overload;
// bStr
procedure bStrSelf(var v: variant);
function Bool2Str(Value: boolean): string; overload;
function Bool2Str(Value: pointer): char; overload;
function Bool2Str(Sender: TStringGrid; ACol,ARow: longint): string; overload;
function bRus2Str(Value: boolean): string;
// Pos
function IsPos(var Index: longint; const Substr,S: string; Offset: longword = 1): boolean;
function PosEnd(const Substr,S: string; Offset: longword = 1): longint;
// Правая часть s, начиная с позиции p, в которой находится Dlm, остаётся в s (без Dlm),
// левая часть - в result
function ExtractLeftPart(var s: string; p: longint; const Dlm: string = ''): string;
// Делит s при наличии в ней Dlm, если нет Dlm, s записывается в result[n]
function StrDivDlm(const Substr,S: string; n: TNamePrimList = 1): TNamePrimStr; overload;
function StrDivDlm(const Substr,S: string; var a: TNamePrimStr; IgnoreCase: boolean = false): boolean; overload;
procedure StrDivDlm(const Substr: string; var a: TNamePrimStr); overload;
procedure LeftSubStrSelf(const Substr: string; var S: string);
// Сравнить массивы строк
function ArrStrComp(const a1,a2: array of string): boolean;
// InRange
function InRange(const AValue, AMin, AMax: string): Boolean; overload;
function InRange(const AValue: string; const AMinMax: TArrBoolStr): Boolean; overload;
function InRange(AValue: TDateTime; const AMinMax: TArrBoolDate): Boolean; overload;
// Обрамляет непустую строку s скобками dLeft и dRight
function BrackNoEmp(const s: string; const dLeft: string = '('; const dRight: string = ')'): string;
procedure BrackNoEmpSelf(var s: string; const dLeft: string = '('; const dRight: string = ')');
function BracketNot(const w: string; lnot: boolean = true): string;
// Установка TNamePrimStr
function NamePrimStr(const name,prim: string): TNamePrimStr;
function ArrBoolStr(const sFalse,sTrue: string; Inv: boolean = false): TArrBoolStr;
function ArrBoolInt(sFalse,sTrue: longint; Inv: boolean = false): TArrBoolInt;
function ArrBoolDbl(sFalse,sTrue: Double; Inv: boolean = false): TArrBoolDbl;
function ArrBoolDate(sFalse,sTrue: Double; Inv: boolean = false): TArrBoolDate;
function ArrBoolVar(const sFalse,sTrue: variant; Inv: boolean = false): TArrBoolVar;
function ArrBoolField(sFalse,sTrue: TField; Inv: boolean = false): TArrBoolField;
// Удалить символы справа
procedure DelTrailingChar(var s: string; c: char);
// Удалить символы слева
procedure DelLeadingChar(var s: string; c: char);
// Пол
function GetSex(const sex: string): TSexList;
// Выделить части из ФИО
procedure PartsFIO(const Value: string; var Famil,Name1,Name2: string);
// Падежи
function PadegFIO(const Famil,Name1,Name2: string; Pdg: TPdgList; Sex: TSexList0 = sexAll): string; overload;
function PadegFIO(const Value: string; Pdg: TPdgList; Sex: TSexList0 = sexAll): string; overload;
function PadegPodr(const Value: string; Pdg: TPdgList): string;
function PadegDolg(const Value: string; Pdg: TPdgList): string; 
function HashStr(const s: string): longword;

{ Функции работы с датами }

// Установка года начала эпохи
function SetEpoch(y: Word): Word;
// Начало эпохи
function DateSmall: TDateTime;
// Конец эпохи
function DateBigOld: TDateBigOld;
// Преобразование строки в дату
function ctod(const st: string; lEpoch: boolean = false; ProtAdd: TCtodProtAdd = nil): TDateTime;
procedure ctodSelf(var v: variant; lEpoch: boolean = false; ProtAdd: TCtodProtAdd = nil);
// Преобразование даты в строку
function dtoc(dt: TDateTime; const cDlm: string = ''; lFull: boolean = true): string;
procedure dtocSelf(var v: variant; const cDlm: string = ''; lFull: boolean = true);
// Год
function Year(dt: TDateTime): Word;
// Месяц
function Month(dt: TDateTime): Word;
// День
function Day(dt: TDateTime): Word;
// Установка наименований месяцев
function SetMonthName(n: longint): longint;
// Дата - в строку "Дата прописью"
function our_dtoc(dt: TDateTime; const Format: string = ''): string;
// FormatDateTime: 1.если в Format есть 'mmmm'; 2.для пустой даты
function OurFormatDateTime(const Format: string; DateTime: TDateTime): string;
// Дата - в строку "Месяц прописью"
function our_mtoc(d: variant; nName: longint = 1; OnlyMes: boolean = false): string;
// Период строкой
function perntomes(d1,d2: TDateTime): string;
// Строка "Дата прописью" - в дату
function our_ctod(const s: string): TDateTime;
// Строка "Месяц прописью" - в дату
function our_ctom(const s: string): TDateTime;
// Начало года
function boy(dt: TDateTime): TDateTime;
procedure boySelf(var dt: TDateTime); overload;
procedure boySelf(var dt: variant); overload;
// Конец года
function eoy(dt: TDateTime): TDateTime;
procedure eoySelf(var dt: TDateTime); overload;
procedure eoySelf(var dt: variant); overload;
// Начало квартала
function boq(dt: TDateTime; CntMonth: byte = 3): TDateTime;
// Конец квартала
function eoq(dt: TDateTime; CntMonth: byte = 3): TDateTime;
// Начало месяца
function bom(dt: TDateTime): TDateTime;
procedure bomSelf(var dt: TDateTime); overload;
procedure bomSelf(var dt: variant); overload;
procedure StartOfTheMonthSelf(var dt: TDateTime);
// Конец месяца
function eom(dt: TDateTime): TDateTime;
procedure eomSelf(var dt: TDateTime);
// Строка вида "YYYYMMDD" - в дату
function stod(const s: string): TDateTime;
procedure stodSelf(var s: variant);
// Дата - в строку вида "YYYYMMDD"
function dtos(const dt: variant): string;
procedure dtosSelf(var s: variant);
// Количество месяцев (d1 - d2)
function DToN(d1,d2: TDateTime): longint;
// Добавить n миллисекунд к d
function IncMilliSeconds(d: TDateTime; n: longint): TDateTime;
// Миллисекунды - в часы,минуты,секунды,миллисекунды
procedure DecodeMSec(ms: longword; var Hour,Min,Sec,MSec: Word);
// Миллисекунды - в TDateTime
function MSecToTime(ms: longword): TDateTime;
// Миллисекунды - в строку
function MSecToStr(ms: longword): string;
// Дата по дню, месяцу и году
function EncodeDateTry(Year,Month,Day: Word; Default: TDateTime = 0): TDateTime;
// DecodeDate
function DecodeDateTry(Date: TDateTime; var Year,Month,Day: Word): boolean;
// EncodeTime
function EncodeTimeTry(Hour,Min,Sec,MSec: Word): TDateTime;
// GetTickCount
function GetTickCount: Int64;
// IncMonth
procedure IncMonthSelf(var DateTime: TDateTime; NumberOfMonths: longint = 1); overload;
procedure IncMonthSelf(var DateTime: variant; NumberOfMonths: longint = 1); overload;
// IncYear
procedure IncYearSelf(var AValue: TDateTime; const ANumberOfYears: longint = 1);
// TDateTime
procedure TDateTimeSelf(var DateTime: variant);
// Преобразовать целое в дату
function mDateTime(const n: variant): TDateTime;

{ Функции работы с типом VARIANT }

// Признак пустого значение в зависимости от типа
function Empty(const v: variant): boolean;
// Пустое значение в зависимости от типа
function VarBlank(const v: variant): variant; overload;
function VarBlank(t: TFieldType): variant; overload;
procedure VarBlankSelf(var v: variant);
// Возвращает v1, если usl=true, и v2 в противном случае
function iif(AValue: boolean; const ATrue,AFalse: variant): variant;
function Bool2Int(const AValue: variant; const AFalse: Int64 = 0;
  const ATrue: Int64 = 1; const Default: Int64 = 0): longint;
procedure Bool2IntSelf(var AValue: variant; const AFalse: Int64 = 0;
  const ATrue: Int64 = 1; const Default: Int64 = 0);
// Сравнение 2-х переменных
function CompVar(const v1,v2: variant; pCompType: PBoolean = nil): boolean;
// Часть массива av начиная с Index длиной Count
function VSubArr(const av: variant; Index: longint; Count: longint = MaxInt; lNeg: boolean = false): variant;
// Добить массив av до длины Len заполнителем zp
function VAddEnd(const av: variant; Len: longint; const zp: variant): variant; overload;
function VAddEnd(const av: variant; Len: longint): variant; overload;
procedure VAddEndSelf(var av: variant; Len: longint; const zp: variant); overload;
procedure VAddEndSelf(var av: variant; Len: longint); overload;
procedure VAddEndSelf(var av: variant; i,Len: longint; const zp: variant); overload;
// Массив строк - в массив variant
function ArrStrToArrVar(const a: array of string; l: longint = NegDef): TArrVar;
// Массив строк - в variant
function ArrStrToVar(const a: array of string; offs: longint = 0; l: longint = NegDef): variant;
// Массив variant-ов - в variant
function ArrVarToVar(const a: array of variant; offs: longint = 1; l: longint = NegDef): variant;
procedure ArrVarToVarSelf(var a: variant; offs: longint = 1; l: longint = NegDef);
procedure ArrVarDef(var a: variant);
// TStringList - в variant
function Ls2Var(ls: TStringList; offs: longint = 1): variant;
// Поиск значения в массиве
function ascan(const a,zn: variant): boolean;
// Установить значение по умолчанию
function IsNil(var Value: variant; const Default: variant): variant; overload;
function IsNil(const Value: variant): boolean; overload;
function IsNilc(const Value,Default: variant; var NoNil: boolean): variant; overload;
function IsNilc(const Value,Default: variant): variant; overload;
// VarType
function MyVarType(const v: variant; lIntAsDbl: boolean = false): longint;
// Замена vFrom на vTo
function ReplVar(const v,vFrom,vTo: variant): variant; overload;
function ReplVar(const v,vTo: string): string; overload;
function ReplVar(v,vTo: longint): longint; overload;
function ReplVar(v,vTo: TDateTime): TDateTime; overload;
procedure ReplVarSelf(var v: string; const vTo: string);
function ReplDateEmptySmall(v: TDateTime): TDateTime;
procedure ReplDateEmptySmallSelf(var v: TDateTime);
function ReplDateSmallEmpty(v: TDateTime): TDateTime;
function ReplDateBigEmpty(const v: variant): TDateTime; overload;
function ReplDateBigEmpty(f: TField): TDateTime; overload;
procedure ReplDateBigEmptySelf(var v: TDateTime);
function ReplDateEmptyBig(v: TDateTime): TDateTime;
procedure ReplDateEmptyBigSelf(var v: TDateTime);
function ReplDateNullEmpty(const v: variant): TDateTime; overload;
function ReplDateNullEmpty(f: TField): TDateTime; overload;
function ReplNeg(l: longint; lDef: longint): longint; overload;
function ReplNeg(l: longint; const a: array of string): longint; overload;
function ReplNeg(l: longint; const a: array of longint): longint; overload;
function ReplNegVar(l: longint; const a: array of variant): longint;
function ReplNeg(l: longint; const s: string): longint; overload;
function ReplNegSelf(var l: longint; lDef: longint): boolean; overload;
function ReplNegSelf(var l: longint; const a: array of string): boolean; overload;
function ReplNegSelf(var l: longint; const a: array of longint): boolean; overload;
function ReplNegSelf(var l: longint; const s: string): boolean; overload;
// Delete для variant
procedure DeleteVar(var v: variant; Index: longint = 1; Count: longint = 1);
procedure DeleteArr(var v: variant; i: longint; Index: longint = 1; Count: longint = 1);
// Изменение нижнего предела массива
function VarArrayLowCng(const v: variant; low: longint): variant;
// Установка значения в массиве
procedure VarSet(var a: variant; i1,i2: longint; const v: variant); overload;
//procedure VarSet(var a: variant; i1,i2,i3: longint; const v: variant); overload;
// VarAsType
procedure VarAsTypeSelf(var V: Variant; AVarType: TVarType);
// VarArrayOf
procedure VarArrayOfSelf(var v: variant);
function VarLength(const v: variant): longint;
function CompSign(const v1,v2: variant): TValueSign;
function PointerDef(var Dest: pointer; Source: pointer): boolean;
function PointerVar(const v: variant): pointer; overload;
function PointerVar(const v: variant; var p: pointer): boolean; overload;
function PointerVar(const av: array of variant; i: longint): pointer; overload;
function PointerStr(const s: string): longint; overload;
function PointerStr(const s: string; offs: longint): pointer; overload;
function PointerInt0(const s: string): pointer;
function StringListVar(const v: variant): TStringList;
function IntegerListVar(const v: variant): TIntegerList;
function IntStrListVar(const v: variant): TIntStrList;
function LongIntVar(const v: variant): PLongInt;
function StringVar(const v: variant): PString;
function BoolVar(const v: variant): PBoolean;
function DoubleVar(const v: variant): PDouble;
function DateVar(const v: variant): PDateTime;
function VariantVar(const v: variant): PVariant;
function ArrStrVar(const v: variant): PArrStr;
function ArrIntVar(const v: variant): PArrInt;
function ArrVarVar(const v: variant): PArrVar;
function DEPrmStrVar(const v: variant): PDEPrmStr;
function FieldVar(const v: variant): TField;
function PointerDate(d: TDateTime): pointer;

{ Тестовые функции }

{$IFDEF LIBTEST}
// Вывод ActiveControl
function msrActCont(Sender: TControl): string;
// Очистить файл сообщений
procedure clrmsgfile;
// Добавить строку сообщения в файл
procedure addmsgfile(const ms: string);
// ComponentState
procedure MsgComponentState(tc: TComponent);
{$ENDIF}
// Наименование из стека с указанным номером
function GetStack(n: longint = 0): string; overload;
// Все наименования из стека
procedure GetStack(var a: TArrStr); overload;
// Добавить значение в стеке
function AddStack(const FncName: string; Sender: TComponent = nil): longint;
// Заменить значение в стеке
procedure RnmStack(const FncName: string; Sender: TComponent = nil; nst: longint = NegDef);
// Восстановить стек
procedure SetStack(nst: longint);
// Удалить последнее значение из стека
procedure DelStack;
// Вывести стек в файл
procedure OutStack(const Msg: string; Opt: TOutStackOpt = []);
procedure MsgProtSave(Length: longint; const FileName: TFileName);

{ Функции работы с базами }

// Закрыть все DataSets
procedure CloseDataSets(db: TComponent);
// Действия для всех DataSets
procedure DataSetsProc(db: TComponent; Proc: TNotifyEvent);

{ Функции работы с файлами }

// Только имя и расширение файла (Ext - расширение по умолчанию)
function FileNameExt(const fn,Ext: TFileName): TFileName;
procedure FileNameExtSelf(var fn: TFileName; const Ext: TFileName);
// Полное имя файла с расширением по умолчанию и каталогом EXE
function FullNameExe(const fn,Ext: TFileName; const Path: TFileName = ''): TFileName;
procedure FullNameExeSelf(var fn: string; const Ext: TFileName; const Path: TFileName = '');
// Убрать расширение
function FileWithOutExt(const FileName: TFileName): TFileName;
procedure FileWithOutExtSelf(var FileName: string);
function ExtractFileWithOutExt(const FileName: TFileName): TFileName;
// ChangeFileExt
procedure ChangeFileExtSelf(var FileName: TFileName; const Ext: TFileName);
// Дата и время создания файла
function GetFileDateTime(const FileName: TFileName): TDateTime;
procedure SetFileDateTime(const FileName: TFileName; d: TDateTime);
// Размер файла
function GetFileSize(const FileName: TFileName; IsFile: PBoolean = nil): Int64; overload;
function GetFileSize(Handle: THandle): Int64; overload;
function GetFileSize(const sr: TSearchRec): Int64; overload;
function GetFileSize(const Path: TFileName; const aFileName: array of string): Int64; overload;
// Размер перевести в строку
function GetStrSize(Size: Int64): string;
// Установка нового рабочего каталога
procedure SetExeDir(const d: string);
function CngDir(const d: TFileName): TFileName;
procedure CngDirSelf(var d: TFileName);
// Корректировка наименования каталога
function CorrDir(const Dir: TFileName; Opt: TCorrDirkOpt = []): TFileName; overload;
function CorrDir(const Dir: TFileName; Opt: TCorrDirkList): TFileName; overload;
procedure CorrDirSelf(var Dir: TFileName; Opt: TCorrDirkOpt = []); overload;
procedure CorrDirSelf(var Dir: string; Opt: TCorrDirkOpt = []); overload;
procedure CorrDirSelf(ls: TStrings; Opt: TCorrDirkOpt = []); overload;
// Процедура с файлами по маске
function MaskFilesProc(const Path: string; Proc: TMaskFilesProc; const av: array of variant;
  Attr: TFileMaskType = []): boolean;
// Для исключения системных папок
function NotSysDir(const sr: TSearchRec): boolean;
// Список файлов по маске Path (вместо FindFirst,FindNext,FindClose)
function GetMaskFiles(ls: TStringList; const Path: string;
	Attr: TFileMaskType = []; Opt: TGetMaskFilesOpt = []): boolean; overload;
function GetMaskFiles(var a: TArrStr; var l: longint; const Path: string;
	Attr: TFileMaskType = []; Opt: TGetMaskFilesOpt = []; pd: PArrDate = nil): boolean; overload;
procedure GetMaskFilesIni(ls: TStringList; const path: TFileName; const Mask: string = '*');
// Удаление файлов по маске Path
function DelMaskFiles(const PathMask: string): boolean;
procedure DelDir(const dir: TFileName);
// Есть ли файл, удовл. маске Path
function IsMaskFiles(const Path: string; Attr: TFileMaskType = []): boolean;
// Имя первого файла, удовл. маске Path
function FirstMaskFiles(var FileName: TFileName; const Path: string; Attr: TFileMaskType = []): boolean;
// Количество файлов, удовл. маске Path
function CntMaskFiles(const Path: string; Attr: TFileMaskType = []): longint;
// Размер файлов по маскам aPath
function SizeFiles(const aPath: array of string; const cDir: TFileName;
	lSubDir: boolean = false): Int64;
// Соответствие имени файла cF маске cM ('' = '*.*')
function FileMaskEquate(const cF, cM: string): boolean;
// Диск готов
function DiskReady(const dir: string): boolean;
// Свободное пространство на диске
function MyDiskFree(const cdrv: string; lTotal: boolean = false): Int64;
// Установить связь (за-MAP-ироваться)
function AddConnect(var cd: TFileName; var lpNetResource: TNetResource): boolean;
// Удалить связь (раз-MAP-ироваться)
procedure DelConnect(const lpNetResource: TNetResource);
// Удалить с подкаталогами
function DirXDel(const cdir: string): boolean;
//**************** Только если ОЧЕНЬ УВЕРЕН **********************
function XDel(const cd: string): boolean;
//****************************************************************
function DirRemove(const cdir: string): boolean;
// Флоппи-диск
function IsFlopDrive(const dir: TFileName): boolean;
// Сетевой диск
function IsNetDrive(const dir: TFileName): boolean;
// Проверка записи на дискету
function FileVerCopy(const FileName: TFileName): boolean;
// Снятие атрибутов файла
function FileClrAttr(const FileName: string; Attr: longword = 0): boolean;
// Удаление файла со снятием атрибутов
function DelFileAtr(const FileName: TFileName; lRecycle: boolean = false): boolean;
// Переименование файла со снятием атрибутов
function RnmFileAtr(const OldName,NewName: TFileName): boolean;
// FileExists
function MyFileExists(const FileName: string): Boolean;
// Поиск файла последней версии
function SearchPath(const f: TFileName; var path: TFileName;
  const PathDop: TFileName = ''; OnlyInGGM: boolean = false;
  SearchPathGGM: TSearchPathGGM = nil; pSearchPathGGM: pointer = nil): boolean;
// Путь к программе SFTP
function SftpPath: string;
// Сетевые ресурсы
procedure ProcNetRes(Proc: TProcNetRes; const av: array of variant;
	dwScope: longword = RESOURCE_GLOBALNET; NetResource: PNetResource = nil);
// Метка диска
function DrvLabel(const drv: string): string;
// Список локальных дисков
procedure GetDriveList(ls: TStringList; lClear: boolean = true);
// Строка папок через ';' в массив
procedure Path2Arr(const path: string; var a: TArrStr);
// Показать в окне папку path (если отсутствует - первую существующую родительскую папку)
procedure DirectoryView(const path: TFileName);
// ExtractFilePath
procedure ExtractFilePathSelf(var fn: TFileName);
// ExtractFileDrive
procedure ExtractFileDriveSelf(var fn: TFileName);
// ExtractFileName
procedure ExtractFileNameSelf(var fn: TFileName);

{ Функции работы с формами }

// Возвращает признак пересечения двух объектов
function win2comp(const tr1,tr2: TRect): boolean;
// Перемещение и изменение размеров окна мышкой
procedure RszMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: longint; Opt: TRszMouse);
procedure RszMouseMove(Sender: TObject; Shift: TShiftState;
  X,Y: longint; Opt: TRszMouse);
function RszMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: longint; Opt: TRszMouse): TRszMouse;
// Отмена скроллинга и сохранение его значения
function ClrScroll(Sender: TControl): TSvScroll;
// Установка значения скроллинга
procedure SetScroll(Sender: TControl; const Sc: TSvScroll);
// Установка возможности перерисовки
procedure SetRedraw(Sender: TWinControl; Opt: TSetRedrawOpt = []); overload;
procedure SetRedraw(Sender: TWinControl; Opt: TSetRedrawList); overload;
procedure SetRedrawOptCor(var Opt: TSetRedrawOpt);
// Перерисовка всех Controls
procedure InvalidateAll(Sender: TWinControl);
// Размещение формы в пределах экрана
function FormOnScreen(f: TCustomForm): TWindowPlacement;
// GetParentForm
function ParentForm(Control: TControl): TForm; overload;
function ParentForm(Control: TControl; var f: TForm): boolean; overload;
// Создать и показать динамическую форму
function CreateShow(FormClass: TFormClass; var Reference; lFree: boolean = false): longint;
// Минимальная ширина формы в зависимости от Caption
function MinWidthForm(f: TForm): longint;
// Определён и видим
function VisibleNoNil(Sender: TControl): boolean; overload;
function VisibleNoNil(Sender: TField): boolean; overload;
// Выполнить процедуру над Control и его Controls
procedure ProcControls(Sender: TControl; Proc: TProcControls; const av: array of variant);
procedure ProcControlsVisible(Sender: TControl; Visible: boolean);
procedure ProcControlsMsg(Sender: TControl; Msg: Word; WParam: Longint = 0; LParam: Longint = 0; Level1: boolean = false);
// Установка Visible для нескольких объектов
procedure SetVisibles(const Controls: array of TControl; Value: boolean);
// Мигающие тексты в панели задач
function ApplTitle: TApplTitle;

{ Функции системных установок }

// Параметры неклиентской области
function SysMetric: TNonClientMetrics;
// Рабочая область программы
function SysWorkArea: TRect;
// Переопределение рабочей области программы
function UserWorkArea(var r: TRect): boolean;
// Список переменных среды
//procedure EnviromentLsStr(ls: TStringList);
// Версия
function GetExeInfo(const cFileName: TFileName = ''): PExeInfo;
function StrExeVersion(const cFileName: TFileName = ''): string;
// Объект-TRegistry
function GRegistry: TRegistry;
// Значение из реестра
function GetRegKey(Root: HKEY; const Key,Name: string): string;
// Родительский узел реестра
function GetRootKey(const aKey: string; var isHkeyMissing: boolean): HKEY;
// IP-адрес
function GetIpAddress: string;
// Является ли локальным компьютером
function IsSrvLocal(const aSrv: string): boolean;
// Список IP-адресов из HOST
procedure GetIps(var ani: TANI);
function GetIpsStr: TArrStr;
// Имя HOST в IP-адрес
function Host2Ip(const HostName: string): string;
// Корректировка IP-адреса
function IPSpaceStr(const s: string): string;
// Имя компьютера (сетевая идентификация)
function CompName: string;
{$IFDEF MSWINDOWS}
function GetEnvironmentVariable(const Name: string): string;
{$ENDIF}
function GetUserGG: longint;
procedure SetUserGG(Value: longint);
function IsUserGG: boolean;
function CanPriv(const Priv: string; Default: boolean = true): boolean;
// Система 64-разрядная
function IsWow64Process: boolean;
function IsGGI(const FileName: string; const ExeName: string = ''): boolean;
function TimeZoneBias: string;

{ Функции работы с цветами }

// Поиск известных цветов
function SeekColor(cl: TColor; FullSeek: boolean = true): T16Colors; overload;
function SeekColor(cl: TColor; var cl16: T16Colors): boolean; overload;
// Инверсный цвет
function InvColor(cl: TColor): TColor;
procedure InvColorSelf(var cl: TColor); overload;
procedure InvColorSelf(Font: TFont); overload;
procedure InvColorSelf(Brush: TBrush); overload;

{ Функции работы с шрифтами }

// Краткая информация о шрифте
function FontInf(Font: TFont): string;
// Шрифт - в строку
function FontToStr(Font: TFont): string;
// TDefFont - в строку
function DefFontToStr(const DefFont: TDefFont): string;
// Строка - в TDefFont
function StrToDefFont(const s: string): TDefFont;
// Определение шрифта из файла регистров
//procedure GetRegFont(Font: TFont; Root: HKEY; Key,Name: string);
// Шрифт по умолчанию
procedure DefaultFont(Font: TFont; FontSize: longint = 0);
// Шрифт с кодировкой 866 по умолчанию
//procedure Font866(Font: TFont; FontSize: longint = 0);
// DefFont - в TFont
procedure DefFontToFont(const DefFont: TDefFont; Font: TFont);
// TFont - в DefFont
procedure FontToDefFont(Font: TFont; var DefFont: TDefFont);
// Изменить атрибуты шрифта
procedure FontStyle(Font: TFont; Incl: boolean = true; AStyle: TFontStyles = [fsBold]);
// Увеличить размер шрифта
procedure IncFontSize(Font: TFont; const d2: longint = 1);

{ Прочие функции }

// Добавляет(находит) в ignoreSL=SortStrListCreate строку s,
// ixS - индекс добавленной(найденной) строки, result = строка найдена
function IgnoreSlFindAdd(ignoreSL: TStringList; const s: string; var ixS: longint): boolean; overload;
function IgnoreSlFindAdd(ignoreSL: TStringList; const s: string): boolean; overload;
function IgnoreSlFindAdd(ignoreSL: TStringList; const s: string; var ixS: longint; var p: pointer): boolean; overload;
// Если находит s в ignoreSL - удаляет, иначе - добавляет
function IgnoreSlAddDel(ignoreSL: TStringList; const s: string): boolean;
// Добавляет offs к объекту-целому, добавленному(найденному) IgnoreSlFindAdd. Возвращает новое значение.
function IgnoreSlAddInt(ignoreSL: TStringList; const s: string; offs: longint = 1): longint;
// Создать отсортированный TStringList
function SortStrListCreate(Duplicates: TDuplicates = dupIgnore): TStringList; overload;
function SortStrListCreate(lCreate: boolean): TStringList; overload;
function SortStrListCreate(var ls: TStringList; Duplicates: TDuplicates = dupIgnore): TStringList; overload;
function StrListCreate(lCreate: boolean): TStringList; overload;
function StrListCreate(var ls: TStringList): TStringList; overload;
// Удаляет s из ls, если находит
function FindDel(ls: TStringList; const s: string; Proc: TFindDelProc = nil): boolean; overload;
function FindDel(ls: TStringList; const s: string; Proc: TFindDelProc; const av: array of variant): boolean; overload;
function FindDelFree(var ls: TStringList; const s: string): boolean; overload;
// Создание и уничтожение объекта в списке
function ListCreate(var ls: TList): TList;
function ListCreateObj(Sender: pointer; var ls: TList): longint;
function ListDestroyObj(Sender: pointer; var ls: TList): longint;
// Удаление в списке с объектами-индексами
procedure SLObjIndDel(ls: TStrings; i: longint; Proc: TSLObjIndProc; lDel: boolean = true; l: longint = NegDef); overload;
procedure SLObjIndDel(ls: TStrings; i: longint; Proc: TSLObjIndProc1; p: pointer = nil); overload;
// Объект-целое
function IntObj(ls: TStrings; i: longint): longint; overload;
function IntObj(ls: TStrings; i: longint; var n: longint): boolean; overload;
procedure IntObjSelf(ls: TStrings; var i: longint);
function IntObjFind(ls: TStringList; const s: string): longint; overload;
function IntObjFind(ls: TStringList; const s: string; var n: longint): boolean; overload;
function IntObjFind(ls: TStringList; const s: string; var i,n: longint): boolean; overload;
function IntObjFindAdd(ls: TStringList; const s: string): longint; overload;
function IntObjFindAdd(ls: TStringList; const s: string; var n: longint): boolean; overload;
function IntObjFindAdd(ls: TStringList; const s: string; var i,n: longint): boolean; overload;
function IntObjFindAdd(ls: TStringList; const s: string; var i,n,l: longint): boolean; overload;
function LongWordObj(ls: TStrings; i: longint): longword;
function LongWordObjFind(ls: TStringList; const s: string; var dw: longword): boolean; overload;
function LongWordObjFind(ls: TStringList; const s: string; var i: longint; var dw: longword): boolean; overload;
// Объект-логическое
function BoolObj(ls: TStrings; const iOrS: variant): boolean;
function BoolObjFind(ls: TStringList; const s: string; var i: longint; var fl: boolean): boolean; overload;
function BoolObjFind(ls: TStringList; const s: string; var fl: boolean): boolean; overload;
procedure BoolObjPack(ls: TStrings; DelTrue: boolean = false);
function BSet2Bool(eb: TBSetList; vNone: boolean = true): boolean;
// Объект-указатель
function PointerObj(ls: TStrings; i: longint): pointer; overload;
function PointerObj(ls: TStrings; i: longint; var p: pointer): boolean; overload;
procedure PointerObjSelf(var ls: TStringList; i: longint);
function PointerObjFind(ls: TStringList; const s: string): pointer; overload;
function PointerObjFind(ls: TStringList; const s: string; var i: longint): pointer; overload;
function PointerObjFind(ls: TStringList; const s: string; var p: pointer): boolean; overload;
function PointerObjFind(ls: TStringList; const s: string; var p: pointer; var i: longint): boolean; overload;
function PointerObjFindAdd(ignoreSL: TStringList; const s: string; var ixS: longint; var p: pointer): boolean;
// Уничтожение TStringList и его объектов
procedure FreeObjects(var ls: TStringList); overload; 
procedure ClearObjects(ls: TStrings);
// Присвоение значения o объектам ls
procedure InitObjects(ls: TStrings; o: TObject = nil);
// Есть ли код в списке
function CodMaybeUsed(ls: TStringList; const acod: array of string; lLike: boolean = false): boolean; overload;
function CodMaybeUsed(ls: TStringList; const cod: string; lLike: boolean = false): boolean; overload;
// Выделить цветом в списке коды fqCod, не содержащиеся в LsNoUsed или содержащиеся в LsUsed
function CodGrayCell(State: TGridDrawState; LsUsed: TStringList; fqCod: TField;
  LsNoUsed: TStringList = nil): boolean;
// Отправить сообщение Msg по всему приложению
procedure MsgApplication(Msg: Word; WParam: Word = 0; LParam: Longint = 0; Level1: boolean = false);
procedure MsgApplGetUpd(const nmMsg: string);
// Поиск параметра в командной строке
function ParamByCode(const NameCode: string; lUpper: boolean = false): string;
// Параметры командной строки
function ParamAllStr: string;
// Максимальная ширина символа
function CanvasMaxW(Canvas: TCanvas): longint;
// Максимальная высота символа
function CanvasMaxH(Canvas: TCanvas): longint;
// Картинка по наименованию
function BMByName(bm: TBitMap; const bmName: string): boolean; overload;
function BMByName(bm: TBitMap; bml: TBMList): boolean; overload;
function BitMapCreate(var Sender: TBitMap): TBitMap;
// Значок "Check"
procedure bmCheckPaint(Canvas: TCanvas; const ARect: TRect; usl: boolean; bm: TBitMap = nil); overload;
// Размер значка "Check"
function bmCheckSize: TSize;
// Видимая область объекта на TScrollingWinControl
function RectInScroll(Sender: TControl): TRect;
// Находит TScrollingWinControl, на котором находится объект
function ParentScroll(Sender: TControl; var sc: TScrollingWinControl): boolean;
// Удалить все Controls
procedure ControlsFree(Sender: TWinControl);
// TSize
procedure WinSize(var result: TSize; Width,Height: longint);
// Процедура замены
function ReplaceProc(pr: TReplaceProc; pav: PVariant; const av: array of variant;
  var cnt: longint): TModalResult;
// Загрузить иконку
function IconLoad(Icon: TIcon; const FileName: TFileName): boolean;
// Перемещение элементов списка
function ListMoveItem(oi,ni,LowLimit,HighLimit: longint;
	Proc: TListMoveItemProc; const av: array of variant): boolean;
// Перезагрузка системы
function ReBoot(uFlags: longword = EWX_REBOOT): boolean;
// Установка привелегии
function SetPrivilege(lpName: PChar): boolean;
// Frame3D объемный
procedure Frame3D1(Canvas: TCanvas; var Rect: TRect; lConcave: boolean = true; Width: byte = 1); overload;
procedure Frame3D2(Canvas: TCanvas; var Rect: TRect; lConcave: boolean = true; Width: byte = 1);
procedure Frame3DF(Canvas: TCanvas; var Rect: TRect; Width: byte = 1);
// Найти такое же приложание и переключиться на него
function NoApplDuplicate(const aTitle: array of string): boolean;
// Есть ли резидентный процесс
function IsResProcess(i: TResProcessList): boolean;
// Сменить код oCod на nCod в отсортированном TStringList
procedure lsCodCng(ls: TStringList; const oCod,nCod: string);
// Принтер
procedure PrnInit;
function GGPrinter: TPrinter;
function IsPrinters: boolean;
// Расчёт минимальных отступов принтера
function CalcSpotPrn: TRect;
// ИНН с корректныи контрольным числом
function INNCheck(const inn: string): string;
// Уст.или сброс set
procedure SetSet(var s: TBoolSet; Value,lSet: boolean); overload;
procedure SetSet(var s: TByteSet; Value: byte; lSet: boolean); overload;
procedure SetSet(var s: TGetOptions; Value: TGetOption; lSet: boolean); overload;
// ControlCount, Controls
function CtrlInfCount(Sender: TWinControl): longint;
function CtrlInfItem(Sender: TWinControl; Index: longint): TControl;
// Pointer - в строку
function PointerToStr(Pnt: Pointer; l: longint): string;
// Строка - в pointer
procedure StrToPointer(const s: string; l: longint; Pnt: Pointer);
// Если существует Pointer, освободить и обнулить
procedure DisposeNil(var p: pointer); overload;
procedure DisposeNil(var p: PVariant); overload;
procedure DisposeNil(var p: PArrStr); overload;
procedure DisposeNil(var p: PArrInt); overload;
procedure DisposeNil(var p: PString); overload;
// TStringStream
function StringStreamCreate(var Sender: TStringStream): TStringStream;
// Tree
function IsSelected(Source: TTreeView; var Dest: TTreeNode): boolean;
function IsNodeAt(Source: TTreeView; X,Y: longint; var Dest: TTreeNode): boolean;
function IsPrevSibling(Source: TTreeNode; var Dest: TTreeNode): boolean;
function IsNextSibling(Source: TTreeNode; var Dest: TTreeNode): boolean;
function IsFirst(Source: TTreeView; var Dest: TTreeNode): boolean;
// TTreeNode.GetFirstChild
function GetFirstChildSelf(var tn: TTreeNode): boolean;
// TTreeNode.GetNext
procedure GetNextSelf(var result: TTreeNode);
// TTreeNode.GetNextSibling
procedure GetNextSiblingSelf(var result: TTreeNode);
// TTreeNode.GetNextVisible
procedure GetNextVisibleSelf(var result: TTreeNode);
// TTreeNode.GetPrev
procedure GetPrevSelf(var result: TTreeNode);
// Узел не заполнен (есть 1 дочерний с пустым текстом)
function NodeNotFill(Node: TTreeNode): boolean;
// TWinControl.Parent
function ParentSelf(var Sender: TWinControl): boolean; overload;
// TTreeNode.Parent
function ParentSelf(var Sender: TTreeNode): boolean; overload;
// Поиск класса DestClass по Parent, начиная с Source
function ParentClass(var Dest: TWinControl; Source: TWinControl; DestClass: TWinControlClass): boolean; overload;
function ParentClass(var Dest: TWinControl; DestClass: TWinControlClass): boolean; overload;
// Если Sender является ToClass - Sender, иначе - nil
function IsClass(Sender: TObject; ToClass: TClass): pointer; overload;
function IsClass(Sender: TObject; ToClass: TClass; var Dest: pointer; lNil: boolean = true): boolean; overload;
function IsClass(Sender: pointer; ToClass: TClass; var Dest: pointer; lNil: boolean = true): boolean; overload;
// TComponent.Owner
function OwnerSelf(var Sender: TComponent): boolean;
function PointerOwner(Sender: TComponent): pointer;
// Если один из компонентов Sender является ToClass - присваивается в p
function ComponentsClass(Sender: TComponent; ToClass: TClass; var p: pointer): boolean;
function ControlsClass(Sender: TWinControl; ToClass: TClass; var p: pointer): boolean; overload;
function ControlsClass(Sender: TWinControl; ToClass: TClass): pointer; overload;
// FillMemory MaxByte
procedure SetMemory(Destination: Pointer; Length: longword);
// FillMemory true
procedure TrueMemory(Destination: Pointer; Length: longword);
// Поддержка старого формата TFracEmpList
function FracEmp2Bool(Value: TFracEmpList): boolean;
function Bool2FracEmp(const Value: variant): TFracEmpList;
// THelpFile
procedure rHelpFile(var result: THelpFile; const sFile: string = ''; const sPage: string = ''); overload;
procedure rHelpFile(var result: THelpFile; Vid: THelpLinkList; const sPage: string = ''); overload;
// Вернуть значение p, если p<>nil, или Default в противном случае
function GetPBoolean(p: PBoolean; Default: boolean = false): boolean;
function GetPString(p: PString; var Value: string): boolean;
function GetPLongInt(p: PLongInt; var Value: longint): boolean;
// Установить значение p=Value, если p<>nil
function SetPBoolean(p: PBoolean; Value: boolean = false): boolean; overload;
function SetPBoolean(const p: variant; Value: boolean = false): boolean; overload;
function SetPString(p: PString; const Value: string = ''): boolean; overload;
function SetPString(const p: variant; const Value: string = ''): boolean; overload;
function SetPLongInt(p: PLongInt; Value: longint = 0): boolean; overload;
function SetPLongInt(const p: variant; Value: longint = 0): boolean; overload;

// Системные кнопки
//procedure BMSpeedButton(sb: TSpeedButton; bmNum: Word);

// AdrGet
function StrToAdr(const Value: string): TAdrStr;
function AdrToStr(const Value: TAdrStr): string;
// Askp
procedure meserr(const s: variant; const Capt: TCaption = ''; Algm: TAlignment = taCenter;
  lDbg: boolean = false); overload;
procedure meserr(const FormatStr: string; const Args: array of const;
  const Capt: TCaption = ''; Algm: TAlignment = taCenter; lDbg: boolean = false); overload;
procedure msr;
function AskSel(Sel: boolean): boolean;
function StMeserr(const s: variant): string;
procedure FindErr(const err: string; const amsg: array of string; var result: boolean);
function ReBootMsg(const amsg: array of string; lBound: boolean = true): boolean;
function ForceDirMsg(const dir: string): boolean;
function MsgDlg(const Msg: string; DlgType: TMsgDlgType = mtError;
  Buttons: TMsgDlgButtons = [mbOk]; HelpCtx: Longint = 0): longint; overload;
function MsgDlg(const FormatStr: string; const Args: array of const; DlgType: TMsgDlgType = mtError;
  Buttons: TMsgDlgButtons = [mbOk]; HelpCtx: Longint = 0): longint; overload;
function MsgDlg(const a: array of string; DlgType: TMsgDlgType = mtError;
  Buttons: TMsgDlgButtons = [mbOk]; HelpCtx: Longint = 0): longint; overload;
// BufFile
function FileBufCreate(const FileName: string): longint;
function FileBufOpen(const FileName: string; Mode: LongWord): longint;
procedure VarToSvRec(const Value: variant; tp: TSaveType; var result: TSaveRec);
function SvRecToVar(const sr: TSaveRec; tp: TSaveType): variant;
function VarToStr(const Value: variant; tp: TSaveType): string;
function StrToVar(const Value: string; tp: TSaveType): variant;
function GetStrFile(const FileName: TFileName; Count: longint = MaxInt;
  Succed: PBoolean = nil; Handle: PHandle = nil): string;
function SetStrFile(const FileName: TFileName; const Value: string; Handle: PHandle = nil): boolean;
procedure CopyBufFile(const Source,Dest: TFileName);
function ClipBoardErrorMessage(ClipboardType: TClipboardType): string;
// Calc
function NumInStr(const s: string; p: longint): string; overload;
function NumInStr(const s: string; lb,X: longint; Canvas: TCanvas): string; overload;
function MsgCalc(Sender: TControl; Operation: TCalcOper; ps: PDouble = nil): boolean;
// GenForm
procedure aGFLinesLoad;
procedure GFObjDef(var result: TGFObj);
function GFTypeLine(LnWidth: TLineNulWidth; LnColor: T16Colors): Byte;
function GFCopyParams(const Source: TGFParams): TGFParams;
function PinRight(Pin: TGFPinList): boolean;
function PinBottom(Pin: TGFPinList): boolean;
function Mm10ToScr(mm10: byte): longint;
function NumToAlgm(v: TGFAlgmList): THVAlignment;
function AlgmToNum(const v: THVAlignment): TGFAlgmList;
// Inter
procedure VarInit(var v: varrec);
procedure ShiftArg(var ap: TArrVar; const av: array of variant; nShift: longint);
function InterPrmMax(const abeg: array of string): TArrStr;
function FirstEngChar(const name: string): boolean;
function VarWithoutPrim(const name: string): string;
function VarArrLenInit(var v: variant; var l: longint; lr0: longint; lr: PLongint = nil): boolean; overload;
function VarArrLenInit(var v: variant; var l: longint; lr: PLongint = nil): boolean; overload;
procedure VarArrLenAdd(var v: variant; var l: longint; var lr: longint);
procedure VarArrLenSet(var v: variant; l: longint);
function GetPrimTrans(var s: string): boolean;
// MulQry
function UnDataType(t: TFieldType): TFieldType; overload;
function UnDataType(f: TField): TFieldType; overload;
procedure UnDataTypeSelf(var t: TFieldType);
function UnionDef(const table,fld: string; const where: string = '';
  const group: string = ''): TUnionDefRec;
function qStrToDateTime(const s: string): TDateTime;
function FieldAsVariant(f: TField): variant;
function FieldAsString(f: TField): string;
procedure SetNumField(fld: TNumericField; nLen,nDec: longint; ZeroEmp: boolean = false);
function NumDisplayFormat(nLen,nDec: longint; ZeroEmp: boolean): string;
procedure qSetParamValue(p: TObject; const Value: string);
function QQs(const s: string = ''; lTrim: boolean = true): string; overload;
function QQs(f: TField; lTrim: boolean = true): string; overload;
procedure QQsSelf(var s: string; lTrim: boolean = true); overload;
procedure QQsSelf(var s: variant; lTrim: boolean = true); overload;
function QQi(i: longint): string; overload;
function QQi(const v: variant; nlen: longint): string; overload;
procedure QQiSelf(var s: string; nlen: longint); overload;
function QQa(const Source: array of string; l: longint = NegDef): TArrStr; overload;
function QQa(const Source: array of longint; l: longint = NegDef): TArrStr; overload;
function QQa(Source: TStrings): TArrStr; overload;
function QQNull(const nmf: string; const v: variant; lnot: boolean = false): string;
function VToS(const v: variant; lQQ: boolean = false): string; overload;
function VToS(f: TField; lQQ: boolean = false): string; overload;
function VToS: string; overload;
function FldIsTrue(const nmf: string; lEq: boolean = true): string;
function FldInList(var ares: TArrStr; const nmf: string; const azn: array of string;
  l: longint = NegDef; Opt: TFldInListOpt = []): boolean; overload;
function FldInList(const nmf: string; const azn: array of string;
  l: longint = NegDef; Opt: TFldInListOpt = []): string; overload;
function FldInListQQ(const nmf: string; const Source: array of string;
  l: longint = NegDef; Opt: TFldInListOpt = []): string; overload;
function FldInListQQ(const nmf: string; const Source: string): string; overload;
function FldInListQQ(const nmf: string; const Source: array of longint): string; overload;
function FldInListQQ(var ares: TArrStr; const nmf: string; const Source: array of string; l: longint = NegDef): boolean; overload;
function FldInListQQ(const nmf: string; Source: TStrings; lNot: boolean = false): string; overload;
function FldInListQQ(var ares: TArrStr; const nmf: string; Source: TStrings; lNot: boolean = false): boolean; overload;
function RecnoWhere(const rno: string; lEq: boolean = true): string; overload;
function RecnoWhere(rno: longint; lEq: boolean = true): string; overload;
function RecnoWhere(f: TField; lEq: boolean = true): string; overload;
function IsSQLLocalPath(const path: string; pa: PArrSQLPath = nil): boolean;
function QryNone(lAll: boolean = false): string; overload;
function QryNone(const s: string; lAll: boolean = false): string; overload;
function IncAnd(var d: string; const d2: string): boolean; overload;
procedure IncAnd(var d: string); overload;
function PrimFld(var prim: string; const nmf: string; const af,ap: array of string): boolean; overload;
function PrimFld(var prim: string; const nmf,sf,sp: string): boolean; overload;
function PrimFldNum(var n: longint; const nmf,nmfbeg: string): boolean; overload;
function PrimFldNum(var prim: string; const nmf,nmfbeg,Fmt: string): boolean; overload;
function PrimFldNum(var prim: string; const nmf,nmfbeg: string;
  const a: array of string; low: longint = 0; const Fmt: string = '%s'): boolean; overload;
function PrimFldNum(const nmf,nmfbeg: string): boolean; overload;
function TransPrim(const prim: string): string; overload;
function TransPrim(const prim: array of string): TArrStr; overload;
procedure TransPrimSelf(var prim: string);
function GetDataIniFileExisting(const path: TFileName; var fn: TFileName): boolean;
function FieldAsStr(f: TField): string;
// FDDatLs
function DDVar2Str(const v: variant; ft: TFieldType; Len: longint; Dec: Word): string; overload;
function DDVar2Str(const v: variant; inf: PDDatKvInfo): string; overload;
function DDStr2Var(const s: string; inf: PDDatKvInfo): variant; overload;
function DDZnType(const r: TDWVidRec): TDDatZnType;
function DDGetD2(d1,d2: TDateTime; inf: PDDatKvInfo): TDateTime;
function IncPer(d: TDateTime; tp: TDDatType; offs: TValueSign = 1): TDateTime; overload;
function IncPer(d: TDateTime; inf: PDDatKvInfo; offs: TValueSign = 1): TDateTime; overload;
procedure IncPerSelf(var d: TDateTime; tp: TDDatType; offs: TValueSign = 1); overload;
procedure IncPerSelf(var d: TDateTime; inf: PDDatKvInfo; offs: TValueSign = 1); overload;
function DDGetWhere(const Cod: string; vid: longint): string; overload;
function DDGetWhere(const Cod: string; vid: longint; const kv: string): string; overload;
function DDGetWhere(vid: longint; const kv: string): string; overload;
function DoDDatSetValProc(op: TDDatSetValOper): boolean;
function DDatLsProc(Sender: TObject; op: TDDatLsOper; p: pointer = nil): boolean;
// DefEdit
function DEGetArrParam(const s: string): TDEPrmStr;
function DESetArrParam(const ac: TDEPrmStr): string;
procedure DEPageSynchro(lsField,lsPage: TStrings; var DcmBased: boolean; var DcmDef: string);
function DEPgSortMode(const sm: string): TSortMode;
function DEPgSortName(DcmBased: boolean; SortMode: TSortMode): string;
function DEVArrToArrParam(const aPrm: array of variant): string;
function DEArr2CharCase(const a: TDEPrmStr): TDECharCase;
// FDWPrm
procedure ReplaceNameRec(ls: TStrings; const OldNmRec,NewNmRec: string); overload;
function VarNmToRec(const VarName: string; lUpFld: boolean = true): TVarNmRec;
function VarCreateTypes(const r: TDWVidRec): string;
procedure DWPrmSearchGF(const SearchInfo: TDWSearchInfo);
// FDWVid
procedure CodManyStr(var a: TArrStr; AType: TDWFldType; const Cod: string); overload;
procedure CodManyStr(var a: TArrStr; const rv: TDWVidRec); overload;
procedure DWTypeMany(Proc: TDWTypeManyProc; Oper: TDWTypeManyOper; const av: array of variant); overload;
procedure DWTypeMany(Oper: TDWTypeManyOper; const av: array of variant); overload;
// FEdText
function InterEdStrTypes(const types: string): string;
function EdTextView(const capt: string; const txt: string;
  const dname: string = ''; dfunc: TKeyProc = nil; Opt: TEdTextOpt = []; EdType: TEdTextType = edtpText;
  crStart: longint = 0; crLen: longint = 0; const InfStr: string = '';
  hc: THelpContext = 0; AfterShow: TNotifyEvent = nil; const MsgErrBig: string = '';
  PrEditIfError: TNotifyEvent = nil; pav: PArrVar = nil; const FileName: TFileName = '';
  BeforeShow: TNotifyEvent = nil; ChangeFileName: TNotifyEvent = nil; HelpProc: TWndMethod = nil;
  PrMaxLength: TMaxLengthEvent = nil): boolean;
// FFind
function BrFindAll: boolean;
function FindRegistrStr(const s: string; lTrim: boolean = true): string;
function FindInStr(const ss,sf: string; pSelStart: PLongInt = nil; pSelLength: PLongInt = nil): boolean; overload;
function FindInStr(const sf: string; const ss: array of string): boolean; overload;
function ReplaceInStr(var ss: string; const sf,sr: string;
  PrRepl: TReplaceProc = nil; pav: PVariant = nil): longint; overload;
function ReplaceInStr(const sf,sr: string; const ss: array of PString;
  PrRepl: TReplaceProc = nil; pav: PVariant = nil): longint; overload;
function SetFindPropertyIdent(lIdent: boolean = true): TFindProperty;
// FHelpLs
function HelpFindAvk(const a: THelpArr; const vk: variant; var i: longint): boolean;
function HelpTblVar(const v,ind: variant; lSave: boolean): variant;
function HelpTblVarName(const Name: string): string;
function HelpTblArr(const Name: string): variant;
function HelpBoldStr(const s: string; Style: THelpStyleList = SCE_OURLIB_HELP_BOLD): string; overload;
function HelpBoldStr(const s: string; const sPage: string; const sFile: string): string; overload;
function HelpBoldStr(const s: string; const hf: THelpFile): string; overload;
function HelpBoldStr(const s: string; const sPart: string; Vid: THelpLinkList): string; overload;
function HelpBoldStr(const s: string; Vid: THelpLinkList): string; overload;
function HelpBoldStr(const s: string; const Tbl: THelpTbl): string; overload;
function HelpBoldStr(const s: string; const Head: string;
  const Dat: array of string; DatLow: longint = 0): string; overload;
procedure HelpBoldStrSelf(var s: string; Style: THelpStyleList = SCE_OURLIB_HELP_BOLD); overload;
procedure HelpBoldStrSelf(var s: string; const sPart: string; Vid: THelpLinkList); overload;
procedure HelpBoldStrSelf(var s: string; const Head: string;
  const Dat: array of string; DatLow: longint = 0); overload;
function HelpTbl2Str(const Tbl: THelpTbl): string;
function HelpStr2Tbl(const s: string; var ht: THelpTbl): boolean;
function HelpTbl2Arr(const ht: THelpTbl; pArr: PHelpArr): boolean;
procedure HelpTblAddDcm(var ht: THelpTbl; var n: byte; const Capt: string = '');
function HelpBool(const Capt: string; lInvert: boolean = false): string;
procedure HelpBoolSelf(var Capt: string; lInvert: boolean = false);
function HelpNum(const Capt: string; lBold: boolean = true; d: byte = 0): string;
procedure HelpNumSelf(var Capt: string; lBold: boolean = true; d: byte = 0);
function HelpDate(const Capt: string): string;
procedure HelpDateSelf(var Capt: string);
function HelpStruct(const aStr: array of string; l: longint = NegDef): string;
function HelpIf(const AValue,ATrue,AFalse: string; lBold: boolean = true): string;
function HelpIfEmpty(const AValue,AFalse: string): string;
function HelpArrayAsList(const a,sep: string; lBold: boolean = true): string;
function HelpStrTran(const s,ss,sr: string; lBold: boolean = true): string;
// ButGet
function ButMask2Prm(const Mask: string): TButGetPrm;
function ButPrm2Mask(const Prm: TButGetPrm): string; overload;
function ButPrm2Mask(const Capt: string = ''; const Mask: string = ''): string; overload;
function FmlToMask(const Fml: string): string;
function MaskToFml(const Mask: string): string;
function FmlKeyLbMask(const Capt: string; key: longint): string;
// Codegets
function MenuMask2Prm(const Mask: string): TMenuGetPrm;
function MenuArr2Mask(const a: array of string; LowLim: longint = 0; Opt: TMenuGetOpt = mnOptInv): string; 
function MenuACN2Mask(const a: array of TNamePrimStr; Opt: TMenuGetOpt = mnOptInv): string; 
// ChkGets
function RadioMask(const a: array of string; LowLim: longint = 1; cnt: longint = NegDef; beg: longint = 0;
  Arrange: TRGArrangeList = rgaCol): string;
// FFldedit
procedure LsPrnAdd(const Head,Value: string; LsPrn: TStringList; offs: byte = 1);
procedure StdGetState(var v: variant; Opt: TStdGetStateOpt = []);
// KeyMenu
procedure KeyToShift(KeyShift: longint; var Shift: TKeyShftList0; var Key: longint);
function ShiftToKey(Shift: TKeyShftList0; Key: longint): longint;
function KeyToTxt(KeyShift: longint; lBrack: boolean = false): string;
function TxtToKey(const txt: string): longint;
function MenuNewLine(AOwner: TComponent): TMenuItem;
// KeyLb
function GetKeyCod(Key: Word; Shift: TShiftState): longint; overload;
function GetKeyCod(Key: Word; Shift: TShiftState; var KeyRes: longint): boolean; overload;
function NmToKey(const s: string): longint; overload;
function NmToKey(const s: string; var Key: longint): boolean; overload;
function KeyToNm(Key: longint): string;
procedure AddKeyStack(Key: longint; const txt: string);
procedure RenameKeyStack(const txt: string);
procedure DelKeyStack;
function GetKeyStack: string;
function KeyAction(key: longint): TFormAction;
function MsOff: TControl;
function MsgMsOff(Sender: TControl): boolean; overload;
procedure MsgMsOff(Oper: TMsOffOper; KeyLb: TObject); overload;
function MsgMsOff(Sender: TControl; av: PArrVar): boolean; overload;
// RbPage
function SeekTabSheet(tw: TWinControl): TTabSheet; overload;
function SeekTabSheet(tw: TWinControl; var ts: TTabSheet): boolean; overload;
// Recdb
function tRecno(const NameDB: string): string;
procedure SetPrim(const nmdb,prim: string);
function GetPrim(const nmdb: string; lRaise: boolean = true): string;
procedure GetPrimSelf(var nmdb: string; lRaise: boolean = true);
procedure DWVidRec0(var result: TDWVidRec);
function StrDefQQ(const s: string): string;
function DWSToRec(const s: string): TDWVidRec;
function DWRecToS(const r: TDWVidRec): string;
function DynNmDb(n: longint): string;
function DWMem(post: TDWPostList = postDat): string;
procedure DWFldAddProc(var a: TDWFldArrSeek; const defD: string;
	const defW: string = ''; lWin: boolean = false);
function IsDWFldMemo(t: TDWFldType; var fa: TFldMemoAttr): boolean; overload;
function IsDWFldMemo(t: TDWFldType): boolean; overload;
function IsDWFldMemo(t: TDWFldType; var fa: TFldMemoAttr; var sBeg: string): boolean; overload;
function IsDWFldMemo(t: TDWFldType; var sBeg: string): boolean; overload;
// SpinGet
function SpinGetPrm(const Mask: string): TSpinGetPrm;
// IntList
procedure FindDelFree(var ls: TIntegerList; Value: LongInt); overload;
procedure FreeObjects(var ls: TIntegerList; lFree: boolean = true); overload;
// FPrnTxt
procedure AddPrnHead(const Head: string); overload;
procedure AddPrnHead(const Head: array of string); overload;
procedure DelPrnHead(Cnt: byte = 1);
// FrmPswd
procedure SetLogVidAct(Value: TFormAction);
function KeyEvalProc(Key: longint; tw: TWinControl; const aProc: TKeyEvalProcArr): boolean;
function IsPswdPrm(var p: PPswdPrm): boolean;
function DBMain: TComponent;
// FldMask
function NoFromCalc(Owner: TComponent; d: Double; x,y: longint): boolean;
// EGoto
procedure ThrowGoto(const s: string='');
// MEM_1,...
function sMEMS(ix: longint): string;
// EDO
function EdoExeFld(tp: TEdoExeType; io: TEdoExeIO): string;
function EdoGetDokVdNames: PArrStr;
function EdoInCapt(vd: longint; const cod,name,prim: string; d: Double; Opt: TEdoInCaptOpt = []): string;
function EdoProc(Oper: TEdoOper; const av: array of variant; const Default: variant): variant; overload;
function EdoProc(Oper: TEdoOper; const av: array of variant): variant; overload;

implementation

{$R IMAGES.RES}
uses RegStr,Variants,DateUtils,WinSock,StrUtils,TlHelp32,PsAPI,ShellApi,FIBQuery,FIBDataSet,
  CopyData,ER866,GGMReg,GGI,Shifr {$IFDEF PROF} ,FProfile {$ENDIF};

type
  TNone = class
  private
    class procedure ApplShowHint(var HintStr: string; var CanShow: Boolean;
    	var HintInfo: THintInfo);
  	class procedure ApplIdle(Sender: TObject; var Done: Boolean);
		class function HookProc(var Message: TMessage): Boolean;
    class procedure dsClose(Sender: TObject);
		class procedure DWPrmSearchGF(Sender: TObject);
  end;

  TArrUnicode = array[char] of Word;

const
  StackSize = 300;

type
  TResProcessSet = set of TResProcessList;
  TTrnsLitCng = array[1..3,char] of string;

var
  BegEpoch: Word;
  EpchAge,EpchYear,curMonthName: Byte;
	GDefFont{,GFont866}: TDefFont;
  oShowHint: TShowHintEvent;
  oMinimize: TNotifyEvent;
  oIdle: TIdleEvent;
  lsExeInfo: TStringList;
  aExeInfo: array of TExeInfo;
  aStack,aStackName: array[1..StackSize] of string;
  nStack: longint;
  WndDebug: HWND;
  pcds: PCopyDataStruct;
  Reg: TRegistry;
  InsPressed,ProtErrWriting: boolean;
  paResProcess: ^TResProcessSet;
  NoPrnInit: boolean = true;
  PSftpPath: PString;
  aTrnsLitCng: ^TTrnsLitCng;
  pnUserGG: PLongint;
  aUnicode: ^TArrUnicode;
  lsUnicode: TIntegerList;
  FDateBigOld: ^TDateBigOld;
  pIsWow64Process: function(hProcess: THandle; Wow64Process: PBoolean): boolean; stdcall;
  aEdoProc: array of TEdoProc;
  FEdoGetDokVdNames: PArrStr;
  FApplTitle: TApplTitle;

function mround;
var a: TFloatChar;
	p,l: longint;
  d: char;
  pd: Extended;
begin
	{$IFDEF STACKALL}AddStack('My_pr.mround');{$ENDIF}
  l:=FloatToText(a,n,fvExtended,ffFixed,FloatMaxLen+1,FloatMaxDec+1); a[l]:=#0; p:=0;
  while (p<l) and (a[p]<>DecimalSeparator) do Inc(p);
  if p=l then result:=n
  else begin
    Inc(p,t); d:='0';
    if t<0 then begin
      if p>=0 then begin
        d:=a[p]; FillMemory(Pointer(LongInt(@a)+p),-t,Ord('0')); a[p-t]:=#0;
      end;
    end
    else begin
      Inc(p);
      if p<l then d:=a[p];
      a[p]:=#0;
    end;
    TextToFloat(a,result,fvExtended);
    if d>='5' then begin
      pd:=IntPower(10,-t);
      if n<0 then IncD(result,-pd) else IncD(result,pd);
    end;
    if result=-0 then result:=0;
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure MroundSelf(var n: Double; t: longint = 0);
begin
  n:=mround(n,t);
end;

procedure MroundSelf(var n: Extended; t: longint = 0);
begin
  n:=mround(n,t);
end;

procedure MroundSelf(var n: variant; t: longint = 0);
begin
  n:=mround(n,t);
end;

function nround;
begin
	{$IFDEF STACKALL}AddStack('My_pr.nround');{$ENDIF}
  result:=round(mround(n));
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure nroundSelf(var n: variant);
begin
  n:=nround(n);
end;

function mdouble;
begin
	result:=n;
end;

function LenInt;
begin
  AddStack('My_pr.LenInt');
  result:=nLen;
  if nDec>0 then Dec(result,nDec+1);
  DelStack;
end;

function HexToInt;
var i: longint;
  mult: Int64;
begin
  AddStack('My_pr.HexToInt');
  result:=0; mult:=1;
  for i:=Length(s) downto 1 do begin
    Inc(result,mult*(Ord(s[i])-IfThen(IsDigit(s[i]),Ord('0'),Ord('A')-10))); mult:=mult shl 4;
  end;
  DelStack;
end;

function ModDiv(var dividend: longint; divisor: longint): longint;
begin
  result:=dividend mod divisor; DivD(dividend,divisor);
end;

function ModDiv(var dividend: longword; divisor: longword): longword;
begin
  result:=dividend mod divisor; DivD(dividend,divisor);
end;

function DivChk;
begin
  result:=v1/v2;
  if IsInfinite(result) or IsNan(result) then raise EZeroDivide.Create('');
end;

function Sum0;
begin
  if Length(Data)=0 then result:=0 else result:=Sum(Data);
end;

function RandomHex;
var Digits: byte;
begin
  AddStack('My_pr.RandomHex');
  result:='';
  repeat
    Digits:=min(8,l);
    IncD(result,IntToHex(Random(HexToInt(StringOfChar('F',Digits))),Digits));
    Dec(l,8);
  until l<=0;
  DelStack;
end;

function StrUn(un: longint): string;
begin
  AddStack('My_pr.StrUn');
  result:=SpaceStr0(un,lUN);
  DelStack;
end;

function StrUn(f: TField): string;
begin
  AddStack('My_pr.StrUn(f)');
  result:=StrUn(f.AsInteger);
  DelStack;
end;

procedure StrUnSelf(var v: variant);
begin
  v:=StrUn(v);
end;

function SumInt0;
begin
  if Length(Data)=0 then result:=0 else result:=SumInt(Data);
end;

procedure IncD(var d: double; const d2: double);
begin
  d:=d+d2;
end;

procedure IncD(var d: Extended; const d2: Extended);
begin
  d:=d+d2;
end;

procedure IncD(var d: variant; const d2: variant);
begin
  d:=d+d2;
end;

procedure IncD(var d: variant; i: longint; const d2: variant);
begin
  d[i]:=d[i]+d2;
end;

{procedure IncD(var d: variant; i1,i2: longint; const d2: variant);
var d1: variant;
begin
  d1:=d[i1]; IncD(d1,i2,d2); d[i1]:=d1;
end;}

procedure IncD(var d: double; const d2: double; ndec: longint);
begin
  d:=mround(d+d2,ndec);
end;

procedure IncD(var d: variant; const d2: variant; ndec: longint);
begin
  d:=mround(d+d2,ndec);
end;

procedure IncD(var d: string; const d2: string);
begin
  d:=d+d2;
end;

procedure IncD(var d: TFileName; const d2: string);
begin
  d:=d+d2;
end;

procedure IncD(d: PString; const d2: string);
begin
  if Assigned(d) then d^:=d^+d2;
end;

procedure IncD(ls: TStringList; i: longint; const d2: string);
begin
  ls[i]:=ls[i]+d2;
end;

procedure IncD(var d: TDateTime; const d2: TDateTime = 1);
begin
  d:=d+d2;
end;

procedure IncD(p: PLongInt; const d2: longint = 1);
begin
  if Assigned(p) then Inc(p^,d2);
end;

procedure IncD(Sender: TFontDialog; Incl: TFontDialogOptions; Excl: TFontDialogOptions = []);
begin
  Sender.Options:=Sender.Options+Incl-Excl;
end;

procedure IncD(Sender: TControl; Incl: TControlStyle; Excl: TControlStyle = []);
begin
  Sender.ControlStyle:=Sender.ControlStyle+Incl-Excl;
end;

procedure IncD(var Options: TGetOptions; Incl: TGetOptions; Excl: TGetOptions = []);
begin
  Options:=Options+Incl-Excl;
end;

procedure IncL(var d: string; const dLeft: string; const dRight: string = '');
begin
  d:=dLeft+d+dRight;
end;

procedure IncL(var d: TFileName; const dLeft: string; const dRight: string = '');
begin
  d:=dLeft+d+dRight;
end;

procedure IncL(var d: variant; const dLeft: string; const dRight: string = '');
begin
  d:=dLeft+d+dRight;
end;

procedure IncL(ls: TStringList; i: longint; const dLeft: string; const dRight: string = '');
begin
  ls[i]:=dLeft+ls[i]+dRight;
end;

procedure IncLeft(Sender: TControl; const d2: longint);
begin
  Sender.Left:=Sender.Left+d2;
end;

procedure IncWidth(Sender: TControl; const d2: longint);
begin
  Sender.Width:=Sender.Width+d2;
end;

procedure MultD(var d: Int64; const d2: Int64);
begin
  d:=d*d2;
end;

procedure MultD(var d: longint; const d2: longint);
begin
  d:=d*d2;
end;

procedure MultD(var d: Word; const d2: Word);
begin
  d:=d*d2;
end;

procedure MultD(var d: Extended; const d2: Extended);
begin
  d:=d*d2;
end;

procedure MultD(var d: Double; const d2: Double);
begin
  d:=d*d2;
end;

procedure MultD(var d: variant; const d2: variant);
begin
  d:=d*d2;
end;

procedure DivD(var d: longint; const d2: longint);
begin
  d := d div d2;
end;

procedure DivD(var d: longword; const d2: longword);
begin
  d := d div d2;
end;

procedure DivD(var d: Extended; const d2: Extended);
begin
  d:=d/d2;
end;

procedure DivD(var d: Double; const d2: Double);
begin
  d:=d/d2;
end;

procedure DivD(var d: Single; const d2: Single);
begin
  d:=d/d2;
end;

procedure DivD(var d: variant; const d2: variant);
begin
  d:=d/d2;
end;

procedure ModD(var d: longint; const d2: longint);
begin
  d := d mod d2;
end;

procedure ModD(var d: longword; const d2: longword);
begin
  d := d mod d2;
end;

procedure ModD(var d: word; const d2: word);
begin
  d := d mod d2;
end;

procedure ShlD(var d: longint);
begin
  d := d shl 1;
end;

procedure ShlD(var d: byte);
begin
  d := d shl 1;
end;

procedure ShlD(var d: longword; offs: byte = 1);
begin
  d := d shl offs;
end;

procedure AndD(var d: longint; const d2: longint);
begin
  d := d and d2;
end;

procedure AndD(var d: longword; const d2: Int64);
begin
  d := d and d2;
end;

procedure AndD(var d: boolean; const d2: boolean);
begin
  d := d and d2;
end;

procedure Or_D(var d: longint; const d2: longint);
begin
  d := d or d2;
end;

procedure Or_D(var d: longword; const d2: longword); 
begin
  d := d or d2;
end;

procedure Or_D(var d: byte; const d2: byte);
begin
  d := d or d2;
end;

procedure Or_D(var d: Int64; const d2: Int64);
begin
  d := d or d2;
end;

procedure Or_D(var d: boolean; const d2: boolean);
begin
  d := d or d2;
end;

procedure NotD(var d: boolean);
begin
  d:=not d;
end;

procedure NotD(var d: longword);
begin
  d:=not d;
end;

procedure NotD(var d: variant);
begin
  d:=not d;
end;

procedure NotD(f: TField);
begin
  f.Visible:=not f.Visible;
end;

procedure MaxSelf(var d: byte; const d2: byte = 0);
begin
  d:=max(d,d2);
end;

procedure MaxSelf(var d: Word; const d2: Word = 0);
begin
  d:=max(d,d2);
end;

procedure MaxSelf(var d: LongWord; const d2: LongWord = 0);
begin
  d:=max(d,d2);
end;

procedure MaxSelf(var d: longint; const d2: longint = 0);
begin
  d:=max(d,d2);
end;

procedure MaxSelf(var d: Int64; const d2: Int64 = 0);
begin
  d:=max(d,d2);
end;

procedure MaxSelf(var d: Double; const d2: Double = 0);
begin
  d:=max(d,d2);
end;

procedure MaxSelf(var d: Extended; const d2: Extended = 0); 
begin
  d:=max(d,d2);
end;

procedure MaxSelf(var d: longint; const d2: string);
begin
  MaxSelf(d,Length(d2));
end;

function MaxSelf(const a: array of string; l: longint = NegDef): longint;
begin
  result:=0;
  for l:=0 to ReplNeg(l,a)-1 do MaxSelf(result,a[l]);
end;

function MaxSelf(ls: TStrings): longint;
var i: longint;
begin
  result:=0;
  for i:=0 to ls.Count-1 do MaxSelf(result,ls[i]);
end;

procedure MaxSelf(var d: longint; Canvas: TCanvas; const d2: string; nInc: longint = 0; lHeight: boolean = false);
begin
  with Canvas.TextExtent(d2) do MaxSelf(d,IfThen(lHeight,cy,cx)+nInc);
end;

function MaxSelf(Canvas: TCanvas; ls: TStrings; nInc: longint = 0; lHeight: boolean = false): longint;
var i: longint;
begin
  result:=0;
  for i:=0 to ls.Count-1 do MaxSelf(result,Canvas,ls[i],nInc,lHeight);
end;

procedure MaxSelf(var d: longint; Canvas: TCanvas; lHeight: boolean = false);
begin
  MaxSelf(d,Canvas,IfThen(lHeight,cMaxH,cMaxW),0,lHeight);
end;

function MaxSelf(Canvas: TCanvas; const a: array of string; lHeight: boolean = false; l: longint = NegDef): longint;
begin
  result:=0;
  for l:=0 to ReplNeg(l,a)-1 do MaxSelf(result,Canvas,a[l],0,lHeight);
end;

procedure MaxSelf(var d: TSize; const d2: TSize);
begin
  MaxSelf(d.cX,d2.cX); MaxSelf(d.cY,d2.cY);
end;

procedure MaxSelf(var d: TSize; Canvas: TCanvas; const d2: string);
begin
  MaxSelf(d,Canvas.TextExtent(d2));
end;

procedure MaxSelf(var d: TDateTime; const d2: TDateTime);
begin
  d:=max(d,d2);
end;

procedure MinSelf(var d: Word; const d2: Word = 0);
begin
  d:=min(d,d2);
end;

procedure MinSelf(var d: longint; const d2: longint = 0);
begin
  d:=min(d,d2);
end;

procedure MinSelf(var d: Int64; const d2: Int64 = 0); overload;
begin
  d:=min(d,d2);
end;

procedure MinSelf(var d: Double; const d2: Double = 0);
begin
  d:=min(d,d2);
end;

procedure MinSelf(var d: TDateTime; const d2: TDateTime);
begin
  d:=min(d,d2);
end;

procedure EnsureSelf(var AValue: byte; AMin, AMax: byte);
begin
  AValue:=EnsureRange(AValue,AMin,AMax);
end;

procedure EnsureSelf(var AValue: Word; AMin, AMax: Word); overload;
begin
  AValue:=EnsureRange(AValue,AMin,AMax);
end;

procedure EnsureSelf(var AValue: longint; AMin, AMax: longint);
begin
  AValue:=EnsureRange(AValue,AMin,AMax);
end;

procedure EnsureSelf(var AValue: Double; AMin, AMax: Double);
begin
  AValue:=EnsureRange(AValue,AMin,AMax);
end;

procedure EnsureSelf(var AValue: Extended; AMin, AMax: Extended);
begin
  AValue:=EnsureRange(AValue,AMin,AMax);
end;

procedure EnsureSelf(var AValue: TDateTime; AMin, AMax: TDateTime);
begin
  AValue:=EnsureRange(AValue,AMin,AMax);
end;

procedure SignSelf;
begin
  AValue:=Sign(AValue);
end;

procedure AbsSelf;
begin
  AValue:=Abs(AValue);
end;

function IfThen(AValue,ATrue: Boolean; const AFalse: boolean = false): boolean;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThen(AValue: boolean; ATrue: pointer; AFalse: pointer = nil): pointer;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThen(ATrue: pointer; AFalse: pointer): pointer;
begin
  result:=IfThen(Assigned(ATrue),ATrue,AFalse);
end;

{function IfThen(AValue: boolean; ATrue: TWindowState; AFalse: TWindowState = wsNormal): TWindowState;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;}

function IfThen(AValue: boolean; ATrue: TBevelCut; AFalse: TBevelCut = bvNone): TBevelCut;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThen(AValue: boolean; ATrue: TLsArrDynList): TLsArrDynOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TSetRedrawList): TSetRedrawOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TRunExeList): TRunExeOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TFldInListList): TFldInListOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue,AFalse: TDWActionList): TDWActionList;
begin
  if AValue then result:=ATrue else result:=AFalse;
end;

function IfThen(AValue: boolean; ATrue: TDWWinRdbDefOpt; AFalse: TDWWinRdbDefOpt = dwdefSeek): TDWWinRdbDefOpt;
begin
  if AValue then result:=ATrue else result:=AFalse;
end;

function IfThen(AValue: boolean; ATrue: TEdTextList): TEdTextOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TTrnsEndList): TTrnsEndOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TProtocolAddList): TProtocolAddOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TBrAppList): TBrAppOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(Key: longint): TBrAppOpt;
begin
  result:=IfThen(Key=K_F4,brappCopy);
end;

function IfThen(AValue: boolean; ATrue: TDiskWaitList): TDiskWaitOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: Boolean; const ATrue: TFdpState; const AFalse: TFdpState = fdpView): TFdpState;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThen(AValue: boolean; ATrue: TFEReadList): TFEReadOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: Boolean; const ATrue,AFalse: TGFSearchType): TGFSearchType;
begin
  if AValue then result:=ATrue else result:=AFalse;
end;

function IfThen(AValue: boolean; const ATrue,AFalse: TPoint): TPoint;
begin
  if AValue then result:=ATrue else result:=AFalse;
end;

function IfThen(AValue: boolean; ATrue: TRDBDelList): TRDBDelOpt; 
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TRDBNewList): TRDBNewOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TGFReplaceList): TGFReplaceOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TCopyFileOption): TCopyFileOptions;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TRasprOstOption): TRasprOstOptions;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TShiftState): TShiftState;
begin
  if AValue then Result:=ATrue else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TStrTableFillList): TStrTableFillOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TFindOptions; AFalse: TFindOptions = []): TFindOptions;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThen(AValue: boolean; ATrue: TFontStyles; AFalse: TFontStyles = []): TFontStyles;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThen(const AValue: variant; ATrue: TAstolinList): TAstolinOpt;
begin
  if IsNilc(AValue,false) then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TGetOption): TGetOptions;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TGetOptions; AFalse: TGetOptions = []): TGetOptions;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThen(AValue: boolean; ATrue,AFalse: TAdrList): TAdrList;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThen(const a: array of string): string;
begin
  if Length(a)=0 then result:='' else result:=a[0];
end;

function IfThen(Sender: TStrings): string;
begin
  if Sender.Count=0 then result:='' else result:=Sender[0];
end;

function IfThen(const Cond,ACond,AVal,Def: variant): variant;
var c: variant;
  ic,iv: longint;
begin
  AddStack('My_pr.IfThen(МАС_ВЫБОР)');
  c:=IsNilc(Cond,true); result:=Def; iv:=VarArrayLowBound(aVal,1);
  for ic:=VarArrayLowBound(ACond,1) to VarArrayHighBound(ACond,1) do begin
    if iv>VarArrayHighBound(aVal,1) then break;
    if CompVar(ACond[ic],c) then begin
      result:=AVal[iv]; break;
    end;
    Inc(iv);
  end;
  DelStack;
end;

function IfThenArr(const av: variant; i: longint; const Def: variant): variant;
begin
  if VarArrayHighBound(av,1)<i then result:=Def else result:=av[i];
end;

function IfThenArr(const av: array of variant; i: longint; const Def: variant): variant;
begin
  if high(av)<i then result:=Def else result:=av[i];
end;

function IfThenChar;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThenCount;
begin
  if Assigned(Sender) then result:=Sender.Count else result:=0;
end;

function IfThenDataSet(AValue: boolean; ATrue: TDataSetNotifyEvent; AFalse: TDataSetNotifyEvent = nil): TDataSetNotifyEvent;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

procedure IfThenDataSet(Proc: TDataSetNotifyEvent; DataSet: TDataSet);
begin
  if Assigned(Proc) then Proc(DataSet);
end;

function IfThenStr(Proc: TStringEvent; Sender: TObject = nil): string;
begin
  IfThenStr(result,Proc,Sender);
end;

function IfThenStr(var s: string; Proc: TStringEvent; Sender: TObject = nil): boolean;
begin
  result:=Assigned(Proc);
  if result then s:=Proc(Sender) else s:='';
end;

procedure IfThenMouse;
begin
  if Assigned(Proc) then Proc(Sender,Button,Shift,X,Y);
end;

procedure IfThenMouseMove;
begin
  if Assigned(Proc) then Proc(Sender,Shift,X,Y);
end;

function IfThenShowHint;
begin
  result:=Assigned(Proc);
  if result then Proc(HintStr,CanShow,HintInfo);
end;

procedure IfThenDWFldList;
begin
  if Assigned(Proc) then Proc(sDat,sWnd);
end;

procedure IfThenClose;
begin
  if Assigned(Proc) then Proc(Sender,Action);
end;

procedure IfThenWndMethod;
begin
  if Assigned(Proc) then Proc(Message);
end;

function IfThenTrans;
begin
  if Assigned(Proc) then result:=Proc(s) else result:=s;
end;

procedure IfThenFilterRecord;
begin
  if Assigned(Proc) then Proc(DataSet,Accept);
end;

procedure IfThenKeyProc;
begin
  if Assigned(Proc) then Proc(key,tw);
end;

function IfThenComp;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThenNotify(AValue: boolean; ATrue: TNotifyEvent; AFalse: TNotifyEvent = nil): TNotifyEvent;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThenNotify(ATrue: TNotifyEvent; AFalse: TNotifyEvent): TNotifyEvent;
begin
  Result:=IfThenNotify(Assigned(ATrue),ATrue,AFalse);
end;

function IfThenNotify(Proc: TNotifyEvent; Sender: TObject = nil): boolean;
begin
  result:=Assigned(Proc);
  if result then Proc(Sender);
end;

function IfThenValid(AValue: boolean; ATrue: TProcValid; AFalse: TProcValid = nil): TProcValid;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThenValid(ATrue: TProcValid; AFalse: TProcValid): TProcValid;
begin
  result:=IfThenValid(Assigned(ATrue),ATrue,AFalse);
end;

function IfThenValid(Proc: TProcValid; Sender: TObject; Def: boolean = true): boolean;
begin
  if Assigned(Proc) then result:=Proc(Sender) else result:=Def;
end;

function IfThenValid0(AValue: boolean; ATrue: TProcValid0; AFalse: TProcValid0 = nil): TProcValid0;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThenValid0(Proc: TProcValid0; Def: boolean = true): boolean;
begin
  if Assigned(Proc) then result:=Proc else result:=Def;
end;

function IfThenFieldGetText;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThenDrawCell(AValue: boolean; ATrue: TDrawCellEvent; AFalse: TDrawCellEvent = nil): TDrawCellEvent;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

procedure IfThenDrawCell(Proc: TDrawCellEvent; Sender: TObject; ACol, ARow: Longint; const Rect: TRect; State: TGridDrawState);
begin
  if Assigned(Proc) then Proc(Sender,ACol,ARow,Rect,State);
end;

function IfThenCng(AValue: boolean; ATrue: TFEChangeEvent; AFalse: TFEChangeEvent = nil): TFEChangeEvent;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

procedure IfThenCng(Proc: TFEChangeEvent; Sender: TObject; const OldVal: variant; FromShow: boolean);
begin
  if Assigned(Proc) then Proc(Sender,OldVal,FromShow);
end;

function IfThenVarEvent;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThenGetText(Sender: TMaskEdit): string;
begin
  AddStack('My_pr.IfThenGetText');
  if Assigned(Sender) then result:=Sender.Text else result:='';
  DelStack;
end;

function IfThenAsk;
begin
  if usl then result:=Ask(a,State,Capt,Algm) else result:=true;
end;

function IfThenTrnsStart;
begin
  if usl then result:=TrnsStart(aTable,flLock,ProcLock,lSetDBS) else result:=true;
end;

procedure IfThenDDatSetVal;
begin
  if Assigned(Proc) then Proc(op,result);
end;

procedure IfThenPrivProc;
begin
  if Assigned(Proc) then Proc(Priv,result);
end;

function IfThenDWCanDel;
begin
  if Assigned(Proc) then result:=Proc(Sender,VarName,MsgName) else result:=true;
end;

procedure IfThenDWCngName;
begin
  if Assigned(Proc) then Proc(Sender,OldName,NewName,result);
end;

procedure IfThenFindDel(Proc: TFindDelProc; Sender: TObject; const av: array of variant);
begin
  if Assigned(Proc) then Proc(Sender,av);
end;

procedure AddFrom(var Dest: TArrStr; const Source: array of string);
var i,j: longint;
begin
	AddStack('My_pr.AddFrom(as)');
  j:=Length(Dest); i:=Length(Source); SetLength(Dest,j+i);
  for i:=0 to i-1 do begin
    Dest[j]:=Source[i]; Inc(j);
  end;
  DelStack;
end;

procedure AddFrom(var Dest: TArrStr; const Source: string);
begin
  AddFrom(Dest,[Source]);
end;

procedure AddFrom(var Dest: TArrStr; var lDest: longint; const Source: string);
begin
	AddStack('My_pr.AddFrom(asl)');
  if Length(Dest)=lDest then SetLength(Dest,IfThen(lDest=0,10,lDest shl 1));
  Dest[lDest]:=Source; Inc(lDest);
  DelStack;
end;

procedure AddFrom(var Dest: TArrInt; var lDest: longint; Source: longint);
begin
	AddStack('My_pr.AddFrom(ail)');
  if Length(Dest)=lDest then SetLength(Dest,IfThen(lDest=0,10,lDest shl 1));
  Dest[lDest]:=Source; Inc(lDest);
  DelStack;
end;

procedure AddFrom(Dest: TStringList; const Source: array of string; l: longint = NegDef);
begin
	AddStack('My_pr.AddFrom(ls)');
  ReplNegSelf(l,Source); Dest.Capacity:=Dest.Count+l;
  for l:=0 to l-1 do Dest.Add(Source[l]);
  DelStack;
end;

function AddFrom(const av1,av2: variant; low2: boolean = false): variant;
var i,j,j2,l1,l2,h1,h2: longint;
begin
	AddStack('My_pr.AddFrom(v)');
  if MyVarType(av1)=varArray then begin
		l1:=VarArrayLowBound(av1,1); h1:=VarArrayHighBound(av1,1);
  end
  else begin
    l1:=1; h1:=0;
  end;
  if MyVarType(av2)=varArray then begin
		l2:=VarArrayLowBound(av2,1); h2:=VarArrayHighBound(av2,1);
  end
  else begin
    l2:=1; h2:=0;
  end;
  if low2 then begin
    j:=l2; j2:=l1;
  end
  else begin
    j:=l1; j2:=l2;
  end;
  i:=h1+h2-j2+1;
  if i<j then result:=false
  else begin
    result:=VarArrayCreate([j,i],varVariant);
    for i:=l1 to h1 do begin
      result[j]:=av1[i]; Inc(j);
    end;
    for i:=l2 to h2 do begin
      result[j]:=av2[i]; Inc(j);
    end;
  end;
  DelStack;
end;

procedure AddFrom(var Dest: TArrProcNone; Proc: TProcNone);
var i: longint;
begin
	AddStack('My_pr.AddFrom(TProcNone)');
  i:=Length(Dest); SetLength(Dest,i+1); Dest[i]:=Proc;
  DelStack;
end;

procedure AddFrom(var Dest: TKeyEvalProcArr; Proc: TKeyEvalProc);
var i: longint;
begin
  AddStack('My_pr.AddFrom(TKeyEvalProc)');
  i:=Length(Dest); SetLength(Dest,i+1); Dest[i]:=Proc;
  DelStack;
end;

procedure AddFrom(var Dest: TArrObject; Source: TObject);
var i: longint;
begin
  AddStack('My_pr.AddFrom(TArrObject)');
  i:=Length(Dest); SetLength(Dest,i+1); Dest[i]:=Source;
  DelStack;
end;

procedure AddFrom(Dest,Source: TList);
var i: longint;
begin
	AddStack('My_pr.AddFrom(TList)');
	for i:=0 to Source.Count-1 do Dest.Add(Source[i]);
  DelStack;
end;

procedure AddFrom(Proc: TBrEditProc);
var i: longint;
begin
  AddStack('My_pr.AddFrom(TBrEditProc)');
  i:=Length(aBrEditProc); SetLength(aBrEditProc,i+1); aBrEditProc[i]:=Proc;
  DelStack;
end;

procedure AddFrom(Proc: TDWFldDefaultProc);
var i: longint;
begin
  AddStack('My_pr.AddFrom(TDWFldDefaultProc)');
  i:=Length(aDWFldDefaultProc); SetLength(aDWFldDefaultProc,i+1); aDWFldDefaultProc[i]:=Proc;
  DelStack;
end;

procedure AddFrom(Proc: THelpTblProc);
var i: longint;
begin
  AddStack('My_pr.AddFrom(THelpTblProc)');
  i:=Length(aHelpTblProc); SetLength(aHelpTblProc,i+1); aHelpTblProc[i]:=Proc;
  DelStack;
end;

procedure AddFrom(Proc: THelpCntProc);
var i: longint;
begin
  AddStack('My_pr.AddFrom(THelpCntProc)');
  i:=Length(aHelpCntProc); SetLength(aHelpCntProc,i+1); aHelpCntProc[i]:=Proc;
  DelStack;
end;

procedure AddFrom(Proc: THelpLinkProc);
var i: longint;
begin
  AddStack('My_pr.AddFrom(THelpCntProc)');
  i:=Length(aHelpLinkProc); SetLength(aHelpLinkProc,i+1); aHelpLinkProc[i]:=Proc;
  DelStack;
end;

procedure AddFrom(Proc: TMDInterVarCreate);
var i: longint;
begin
  AddStack('My_pr.AddFrom(TMDInterVarCreate)');
  i:=Length(aModelGetCreate); SetLength(aModelGetCreate,i+1); aModelGetCreate[i]:=Proc;
  DelStack;
end;

procedure AddFrom(Proc: TEdoProc);
var i: longint;
begin
  AddStack('My_pr.AddFrom(TEdoProc)');
  i:=Length(aEdoProc); SetLength(aEdoProc,i+1); aEdoProc[i]:=Proc;
  DelStack;
end;

procedure AddFrom(Proc: TRegsDelProc);
var i: longint;
begin
  AddStack('My_pr.AddFrom(TRegsDelProc)');
  i:=Length(aRegsDelProc); SetLength(aRegsDelProc,i+1); aRegsDelProc[i]:=Proc;
  DelStack;
end;

procedure AddFrom(Proc: TDDatLsProc);
var i: longint;
begin
  AddStack('My_pr.AddFrom(TDDatLsProc)');
  i:=Length(aDDatLsProc); SetLength(aDDatLsProc,i+1); aDDatLsProc[i]:=Proc;
  DelStack;
end;

procedure AddFromSelf(var av1: variant; const av2: variant; low2: boolean = false);
begin
  av1:=AddFrom(av1,av2,low2);
end;

procedure AddFromSelf(var av1: variant; i: longint; const av2: variant; low2: boolean = false);
begin
  av1[i]:=AddFrom(av1[i],av2,low2);
end;

procedure AddFromInt(var Dest: TArrInt; const Source: array of longint);
var i,j: longint;
begin
	AddStack('My_pr.AddFromInt');
  j:=Length(Dest); i:=Length(Source); SetLength(Dest,j+i);
  for i:=0 to i-1 do begin
    Dest[j]:=Source[i]; Inc(j);
  end;
  DelStack;
end;

procedure AddFromInt(var Dest: TArrInt; Source: longint);
begin
  AddFromInt(Dest,[Source]);
end;

procedure AddFromVArr;
var i,j: longint;
begin
	AddStack('My_pr.AddFromVArr');
  j:=Length(Dest); i:=Length(Source); SetLength(Dest,j+i);
  for i:=0 to i-1 do begin
    Dest[j]:=Source[i]; Inc(j);
  end;
  DelStack;
end;

procedure AddFromNamePrim;
var i,j: longint;
begin
	AddStack('My_pr.AddFromNamePrim');
  j:=Length(Dest); i:=Length(Source); SetLength(Dest,j+i);
  for i:=0 to i-1 do begin
    Dest[j]:=Source[i]; Inc(j);
  end;
  DelStack;
end;

procedure InsFrom;
var i,j: longint;
begin
	AddStack('My_pr.InsFrom');
  j:=Length(Dest); i:=Length(Source)+j; SetLength(Dest,i);
  while j>0 do begin
    Dec(j); Dec(i); Dest[i]:=Dest[j];
  end;
  for i:=low(Source) to high(Source) do Dest[i]:=Source[i];
  DelStack;
end;

procedure CopyFrom(var Dest: TArrStr; const Source: array of string);
var i: longint;
begin
  AddStack('My_pr.CopyFrom(as)');
  i:=Length(Source); SetLength(Dest,i);
  for i:=0 to i-1 do Dest[i]:=Source[i];
  DelStack;
end;

procedure CopyFrom(var Dest: TArrStr; const Source: string = '');
begin
  CopyFrom(Dest,[Source]);
end;

procedure CopyFrom(var Dest: TArrStr; Source: TStrings);
var i: longint;
begin
  AddStack('My_pr.CopyFrom(s)');
  SetLength(Dest,Source.Count);
  for i:=0 to Source.Count-1 do Dest[i]:=Source[i];
  DelStack;
end;

procedure CopyFrom(var Dest: TArrVar; Source: TStrings);
var i: longint;
begin
  AddStack('My_pr.CopyFrom(v)');
  SetLength(Dest,Source.Count);
  for i:=0 to Source.Count-1 do Dest[i]:=Source[i];
  DelStack;
end;

procedure CopyFrom(var Dest: TDEPrmVar; const Source: TDEPrmStr);
var i: TDEPrmList;
begin
  AddStack('My_pr.CopyFrom(TDEPrmVar)');
  for i:=low(Dest) to high(Dest) do Dest[i]:=Source[i];
  DelStack;
end;

procedure CopyFrom(var Dest: TModelPrim; const Source: TModelPrim);
var i: longint;
begin
  AddStack('My_pr.CopyFrom(TModelPrim)');
  SetLength(Dest,Length(Source));
  for i:=low(Dest) to high(Dest) do Dest[i]:=Source[i];
  DelStack;
end;

function CopyFrom(const Source: array of string): TArrStr;
begin
  CopyFrom(result,Source);
end;

function CopyFrom(const Source: string): TArrStr;
begin
  CopyFrom(result,Source);
end;

function CopyFrom(Source: TStringList): TArrStr;
begin
  CopyFrom(result,Source);
end;

procedure CopyFromInt(var Dest: TArrInt; const Source: array of longint);
var i: longint;
begin
  AddStack('My_pr.CopyFromInt');
  i:=Length(Source); SetLength(Dest,i);
  for i:=0 to i-1 do Dest[i]:=Source[i];
  DelStack;
end;

procedure CopyFromInt(var Dest: TArrInt; Source: longint);
begin
  CopyFromInt(Dest,[Source]);
end;

procedure CopyFromVArr(var Dest: TArrVar; const Source: array of variant);
var i: longint;
begin
  AddStack('My_pr.CopyFromVArr');
  i:=Length(Source); SetLength(Dest,i);
  for i:=0 to i-1 do Dest[i]:=Source[i];
  DelStack;
end;

{function CopyFromVArr(const Source: array of variant): TArrVar;
begin
  CopyFromVArr(result,Source);
end;}

function CopyFromVar(var aDest: TArrStr; const aSource: variant): boolean;
var i,j: longint;
begin
	AddStack('My_pr.CopyFromVar(s)');
  result:=MyVarType(aSource)=varArray;
  if result then begin
    j:=VarArrayLowBound(aSource,1); SetLength(aDest,VarArrayHighBound(aSource,1)-j+1);
    for i:=low(aDest) to high(aDest) do begin
      aDest[i]:=IsNilc(aSource[j],''); Inc(j);
    end;
  end
  else begin
    SetLength(aDest,1); aDest[0]:=aSource;
  end;
  DelStack;
end;

function CopyFromVar(var aDest: TArrInt; const aSource: variant): boolean;
var t,i,j: longint;
begin
	AddStack('My_pr.CopyFromVar(i)');
  t:=MyVarType(aSource); result := t=varArray;
  if result then begin
    j:=VarArrayLowBound(aSource,1); SetLength(aDest,VarArrayHighBound(aSource,1)-j+1);
    for i:=low(aDest) to high(aDest) do begin
      aDest[i]:=aSource[j]; Inc(j);
    end;
  end
  else if t=varBoolean then aDest:=nil
  else begin
    SetLength(aDest,1); aDest[0]:=aSource;
  end;
  DelStack;
end;

function CopyFromVar(var aDest: TArrVar; const aSource: variant): boolean;
var i,j: longint;
begin
	AddStack('My_pr.CopyFromVar(v)');
  result:=MyVarType(aSource)=varArray;
  if result then begin
    j:=VarArrayLowBound(aSource,1); SetLength(aDest,VarArrayHighBound(aSource,1)-j+1);
    for i:=low(aDest) to high(aDest) do begin
      aDest[i]:=aSource[j]; Inc(j);
    end;
  end
  else begin
    SetLength(aDest,1); aDest[0]:=aSource;
  end;
  DelStack;
end;

procedure DelFrom(var Dest: TArrProcNone; Proc: TProcNone);
var i,l: longint;
begin
  AddStack('My_pr.DelFrom');
  i:=0; l:=Length(Dest);
  while i<l do 
    if @Dest[i]=@Proc then begin
      for i:=i+1 to l-1 do Dest[i-1]:=Dest[i];
      SetLength(Dest,l-1); break;
    end
    else Inc(i);
  DelStack;
end;

procedure InitArr(var Dest: array of variant; nbeg: longint = 0; nend: longint = MaxInt);
begin
  InitArr(Dest,nbeg,nend,null);
end;

procedure InitArr(var Dest: array of variant; nbeg,nend: longint; const Value: variant);
var i: longint;
begin
  AddStack('My_pr.InitArr(av)');
  for i:=nbeg to min(nend,high(Dest)) do Dest[i]:=Value;
  DelStack;
end;

procedure InitArr(var Dest: array of string; nbeg: longint = 0; nend: longint = MaxInt; const Value: string = '');
var i: longint;
begin
  AddStack('My_pr.InitArr(as)');
  for i:=nbeg to min(nend,high(Dest)) do Dest[i]:=Value;
  DelStack;
end;

{procedure InitArr(var Dest: variant);
begin
end;}

procedure InitArrLen(var Dest: TArrStr; l: longint);
begin
  AddStack('My_pr.InitArrLen(as)');
  SetLength(Dest,l); InitArr(Dest);
  DelStack;
end;

procedure InitArrLen(var Dest: variant; LowLim,HighLim: longint; const Value: variant);
var i: longint;
begin
  AddStack('My_pr.InitArrLen(v)');
  Dest:=VarArrayCreate([LowLim,HighLim],varVariant);
  for i:=LowLim to HighLim do Dest[i]:=Value;
  DelStack;
end;

type
  TRsp = record
    n: longint;
    p: Double;
  end;
  TArrRsp = array of TRsp;

function FSortRasprOst(p: pointer; fi,si: longint; sortID: TSortID): boolean;
var a: ^TArrRsp;
  v: TRsp;
begin
  AddStack('My_pr.FSortRasprOst');
  result:=false; a:=p;
  case sortID of
    sort1MORE2: result := a^[fi].p>a^[si].p;
    sortEXCHANGE: begin
      v:=a^[fi]; a^[fi]:=a^[si]; a^[si]:=v;
    end;
  end;
  DelStack;
end;

procedure RasprOst(var av: array of double; tr: byte; sr: Double; l: longint; Options: TRasprOstOptions = []);
var a: TArrRsp;
  n,nlast: longint;
  sv,sp,t,k,vkon: Double;
  fl: boolean;
  an: PArrDbl;
begin
  AddStack('My_pr.RasprOst');
  // массив {V1,V2,...,VN} AV
  // точность расчпределения TR
  // сумма к распределению SR
  if l>0 then begin
    MroundSelf(sr,tr); fl := sr<0;
    if rspoSignRest in Options then begin
      New(an); SetLength(an^,l); Include(Options,rspoSign);
    end
    else an:=nil;
    try
      sv:=0;
      for n:=0 to l-1 do begin
        if rspoEqual in Options then av[n]:=1;
        if rspoSign in Options then
          if (av[n]<0) <> fl then begin
            if Assigned(an) then begin
              an^[n]:=av[n]; IncD(sr,-av[n]);
            end;
            av[n]:=0;
          end
          else if Assigned(an) then an^[n]:=0;
        // S(VN) - сумма весов SV
        IncD(sv,av[n]);
      end;
      if empty(sv) then ZeroMemory(@av[0],l*SizeOf(av[0]))
      else begin
        if Assigned(an) then MroundSelf(sr,tr);
        // распределение с переносом погрешности суммирования на последний ненулевой элемент
        if rspoNoOptim in Options then begin
          k:=sr-sv; t:=0; nlast:=0;
          for n:=0 to l-1 do begin
            if not empty(av[n]) then nlast:=n;
            IncD(av[n],k*av[n]/sv,tr); IncD(t,av[n]);
          end;
          IncD(t,-sr);
          if not empty(t) then IncD(av[nlast],-t);
        end
        // оптимальное распределение (рекомендуется)
        else begin
          // мин.сумма с точностью T
          t:=IntPower(10,-tr);
          // коэффициент K
          k:=sr/sv;
          SetLength(a,l); sp:=0;
          for n:=0 to l-1 do begin
            // каждый элемент VN * K => VKN
            MultD(av[n],k);
            // округлить(VKN,TR)=> VKON
            // задача: S(VKON-VKN)^2 должна быть минимальной и S(VKON)=SR
            vkon:=mround(av[n],tr);
            // S(VKON) SP
            IncD(sp,vkon);
            // VKON-VKN=> PN (погрешность округления)
            a[n].p:=vkon-av[n]; av[n]:=vkon; a[n].n:=n;
          end;
          // общая погрешность SP
          IncD(sp,-sr,tr);
          if sp<>0 then begin
            // сортируем массив по возрастанию PN
            QuickSort(FSortRasprOst,@a,0,l-1);
            if sp<0 then
              // цикл сортированнному массиву для I от 1 до N
              for n:=0 to l-1 do begin
                IncD(av[a[n].n],t); IncD(sp,t);
                // если погрешность распределена полностью
                if mround(sp,tr)=0 then break;
              end
            else
              // цикл сортированнному массиву для I от N до 1
              for n:=l-1 downto 0 do begin
                IncD(av[a[n].n],-t); IncD(sp,-t);
                // если погрешность распределена полностью
                if mround(sp,tr)=0 then break;
              end;
          end
        end;
        if Assigned(an) then for n:=0 to l-1 do
          if an^[n]<>0 then av[n]:=an^[n];
      end;
    finally
      if Assigned(an) then Dispose(an);
    end;
  end;
  DelStack;
end;

procedure RasprOst(var av: array of double; tr: byte; sr: Double; Options: TRasprOstOptions = []);
begin
  RasprOst(av,tr,sr,Length(av),Options);
end;

procedure RasprOst(var av: array of longint; sr: longint; Options: TRasprOstOptions = []);
var ad: TArrDbl;
  n: longint;
begin
  AddStack('My_pr.RasprOst(i)');
  SetLength(ad,Length(av));
  for n:=low(av) to high(av) do ad[n]:=av[n];
  RasprOst(ad,0,sr,Options);
  for n:=low(av) to high(av) do av[n]:=nround(ad[n]);
  DelStack;
end;

function RasprOst(const av: TArrArrVar; tr: byte; const sr: TArrDbl; const prior: TArrInt): TArrDbl;
const MaxCnt = 10000;
var i,n,k,k1,k2,ls,lr,npr,cnt: longint;
  fl,fl2: boolean;
  sum,skoef,koef,smv: Double;
  alim,ares,aost,asum,akoef: TArrDbl;
  alimn,akoefk: TArrInt;
  afllim,aislim,aisres,aiskoef: TArrBool;
  lsPrior: TIntegerList;
begin
  AddStack('My_pr.RasprOst(a)');
  // av-массив условий
  // каждое условие - массив :
  // каждый элемент - вес переменной в этом условии
  // sr - массив сумм для распределения для каждого условия
  // prior - массив приоритетов
  ls:=Length(sr); lr:=Length(prior);
  SetLength(alim,lr); // массив ограничений по мере расч
  SetLength(aislim,lr); ZeroMemory(@aislim[0],lr*SizeOf(aislim[0]));
  SetLength(alimn,lr); SetLength(akoef,lr); SetLength(akoefk,lr); SetLength(aiskoef,lr);
  SetLength(afllim,lr); SetLength(ares,lr); SetLength(aisres,lr);
  lsPrior:=TIntegerList.Create([ilsSorted]); // массив всех приоритетов, отсортированный по возрастанию
  try
    for k:=0 to lr-1 do begin
      alimn[k]:=-1;
      if prior[k]>=0 then lsPrior.Add(prior[k]);
    end;
    SetLength(aost,ls); // первоначальные остатки
    for n:=0 to ls-1 do aost[n]:=mround(sr[n],tr);
    SetLength(asum,ls);
    SetLength(result,lr); ZeroMemory(@result[0],lr*SizeOf(result[0]));
    for i:=0 to lsPrior.Count-1 do begin
      CopyMemory(@asum[0],@aost[0],ls*SizeOf(aost[0])); // остаток от предыдущего приоритета
      npr:=lsPrior[i]; fl:=true; cnt:=0;
      while fl do begin
        // распределяем снова, берём остатки на начало распределения по текущему приоритету
        CopyMemory(@aost[0],@asum[0],ls*SizeOf(asum[0])); fl:=false;
        for n:=0 to ls-1 do begin
          sum:=asum[n]; // сумма
          for k:=0 to lr-1 do begin // массив весов
            aiskoef[k] := not IsNil(av[n,k]);
            if aiskoef[k] then akoef[k]:=mround(av[n,k],FloatMaxDec);
          end;
          ZeroMemory(@afllim[0],lr*SizeOf(afllim[0]));
          ZeroMemory(@aisres[0],lr*SizeOf(aisres[0]));
          fl2:=true;
          while fl2 do begin // распределение одного условия
            // подсчёт коэффициента распределения
            skoef:=0; k2:=-1;
            for k:=0 to lr-1 do
              if (prior[k]=npr) and aiskoef[k]  then
                if (akoef[k]>=0) and not afllim[k] then begin
                  Inc(k2); akoefk[k2]:=k; IncD(skoef,akoef[k],FloatMaxDec);
                end;
            fl2:=false;
            if k2>=0 then begin // если есть хот одна переменная в этом условии с текущим приоритером, то распределяем
              if skoef>0 then koef:=sum/skoef else koef:=0;
              //распределение суммы по весам
              smv:=sum;
              for k1:=0 to k2 do begin
                k:=akoefk[k1];
                //if k1=k2 // последний элемент,остаток на неё
                if akoef[k]=skoef // последний элемент,остаток на неё
                then ares[k]:=IfThen(akoef[k]>0,smv)
                else ares[k]:=mround(akoef[k]*koef,tr);
                aisres[k]:=true; IncD(skoef,-akoef[k],FloatMaxDec); IncD(smv,-ares[k],tr);
                if aislim[k] then // если есть ограничение на этот элемент
                  if alimn[k]<>n then // и ограничение поставлено не текущим условием
                    // проверка на ограничение
                    if ares[k]>alim[k] then begin
                      ares[k]:=alim[k]; IncD(sum,-ares[k],tr); akoef[k]:=0; afllim[k]:=true;
                      fl2:=true; // было ограничение, надо распределять снова
                    end;
              end;
            end;
          end;
          for k:=0 to lr-1 do
            if prior[k]=npr then // смотрим только с текущим приоритетом
              if aisres[k] then begin// если участвовало в условии
                if aislim[k] then // если для него было ограничение
                  if alimn[k]=n then begin // если ограничение было поставлено текущим условием
                    if ares[k]<>alim[k] then begin // поменялось ограничение по тек.условию
                      alim[k]:=ares[k]; fl:=true;
                    end;
                  end
                  else begin
                    // если меньше/больше ограничения,то ограничение надо поменять и запустить распределение снова
                    if ares[k]<alim[k] then begin
                      alim[k]:=ares[k]; alimn[k]:=n; fl:=true;
                    end;
                  end
                else begin // текущее значение становится ограничением для последущих условий
                  alim[k]:=ares[k]; aislim[k]:=true; alimn[k]:=n;
                end;
                result[k]:=ares[k]; IncD(aost[n],-ares[k],tr);
                if fl then break;
              end;
          if fl then break;
        end;
        Inc(cnt);
        if cnt=MaxCnt then begin
          if GetUserGG>1
          then MsgDlg('Внимание !%sКоличество циклов распределения по ограничениям превысило %d.%sОбратитесь к разработчикам',
            [CRLF,MaxCnt,CRLF]);
          OutStack('Количество циклов распределения по ограничениям превысило допустимый предел.');
          break;
        end;
      end;
      // расчёт с отр.весом
      for n:=0 to ls-1 do
        for k:=0 to lr-1 do
          if (prior[k]=npr) and not IsNil(av[n,k]) then
            if av[n,k]<0 then IncD(aost[n],result[k],FloatMaxDec);
    end;
  finally
    lsPrior.Free;
  end;
  DelStack;
end;

function ArrIntIndex;
var i: longint;
begin
  AddStack('My_pr.ArrIntIndex');
  result:=-1;
  for i:=low(a) to high(a) do if a[i]=v then begin
    result:=i; break;
  end;
  DelStack;
end;

function ArrIntMatch;
begin
  AddStack('My_pr.ArrIntMatch');
  result := ArrIntIndex(v,a)>=0;
  DelStack;
end;

function ArrIntFind(v: longint; const a: array of longint; LowLim: longint; var Index: longint): boolean;
begin
  AddStack('My_pr.ArrIntFind');
  Index:=ArrIntIndex(v,a); result := Index>=0; Inc(Index,LowLim);
  DelStack;
end;

function ArrIntFind(v: longint; const a: array of longint; var Index: longint): boolean;
begin
  result:=ArrIntFind(v,a,0,Index);
end;

procedure QuickSort(proc: TFSort; p: pointer; l,h: longint);
var i,j,k: longint;
begin
  if l<h then repeat
    i:=l;
    j:=h;
    k:=(l+h)div 2;
    repeat
      while proc(p,k,i,sort1MORE2) do Inc(i);
      while proc(p,j,k,sort1MORE2) do Dec(j);
      if (i<=j) then begin
        proc(p,i,j,sortEXCHANGE);
        if (k=i) then k:=j
        else
          if (k=j) then k:=i;
        Inc(i); Dec(j);
      end;
    until i>j;
    QuickSort(proc,p,l,j); l:=i;
  until i>=h;
end;

const aCompStrProc: array[boolean] of TQuickSortStrComp = (AnsiCompareText,AnsiCompareStr);

type
  TSortStrPrm = record
    proc: TQuickSortStrComp;
    a: PArrStr;
  end;
  TSortIntPrm = record
    proc: TQuickSortIntComp;
    a: PArrInt;
  end;

function FSortStr(p: pointer; fi,si: longint; sortID: TSortID): boolean;
var prm: ^TSortStrPrm;
  v: string;
begin
  result:=false; prm:=p;
  with prm^ do case sortID of
    sort1MORE2: result := proc(a^[fi],a^[si])>0;
    sortEXCHANGE: begin
      v:=a^[fi]; a^[fi]:=a^[si]; a^[si]:=v;
    end;
  end;
end;

function FSortInt(p: pointer; fi,si: longint; sortID: TSortID): boolean;
var prm: ^TSortIntPrm;
  v: longint;
begin
  result:=false; prm:=p;
  with prm^ do case sortID of
    sort1MORE2: result := proc(a^[fi],a^[si])>0;
    sortEXCHANGE: begin
      v:=a^[fi]; a^[fi]:=a^[si]; a^[si]:=v;
    end;
  end;
end;

procedure QuickSort(proc: TQuickSortStrComp; var a: TArrStr; l: longint = NegDef);
var prm: TSortStrPrm;
begin
  prm.proc:=proc; prm.a:=@a; QuickSort(FSortStr,@prm,0,ReplNeg(l,a)-1);
end;

procedure QuickSort(proc: TQuickSortIntComp; var a: TArrInt; l: longint = NegDef);
var prm: TSortIntPrm;
begin
  prm.proc:=proc; prm.a:=@a; QuickSort(FSortInt,@prm,0,ReplNeg(l,a)-1);
end;

procedure QuickSort(var a: TArrStr; l: longint = NegDef; lCase: boolean = false);
begin
  QuickSort(aCompStrProc[lCase],a,l);
end;

function FSortIntComp(v1,v2: longint): longint;
begin
  result:=CompSign(v1,v2);
end;

procedure QuickSort(var a: TArrInt; l: longint = NegDef);
begin
  QuickSort(FSortIntComp,a,l);
end;

function QuickFind(var Index: longint; const v: string; const a: TArrStr; la: longint = NegDef; lCase: boolean = false): boolean;
var L,H,i,c: longint;
begin
  //AddStack('My_pr.QuickFind');
	result:=false; L:=0; H:=ReplNeg(la,a)-1;
  while L<=H do begin
  	i := (L+H) shr 1; c:=aCompStrProc[lCase](a[i],v);
    if c<0 then L:=i+1
    else begin
    	H:=i-1;
	    if c=0 then begin
      	result:=true; L:=i;
      end;
    end;
  end;
  Index:=L;
  //DelStack;
end;

function QuickFind(const v: string; const a: TArrStr; la: longint = NegDef; lCase: boolean = false): boolean;
var Index: longint;
begin
  result:=QuickFind(Index,v,a,la,lCase);
end;

function QuickFind(var Index: longint; v: longint; const a: TArrInt; la: longint = NegDef): boolean; overload;
var L,H,i: longint;
begin
	result:=false; L:=0; H:=ReplNeg(la,a)-1;
  while L<=H do begin
  	i := (L+H) shr 1;
    if a[i]<v then L:=i+1
    else begin
    	H:=i-1;
	    if a[i]=v then begin
      	result:=true; L:=i;
      end;
    end;
  end;
  Index:=L;
end;

function QuickFind(v: longint; const a: TArrInt; la: longint = NegDef): boolean; overload;
var Index: longint;
begin
  result:=QuickFind(Index,v,a,la);
end;

function QuickIndexOf;
begin
  if not QuickFind(result,v,a,la,lCase) then result:=NegDef;
end;

procedure ArrStr2Ls;
begin
  AddStack('My_pr.ArrStr2Ls');
  ReplNegSelf(l,a); ls.BeginUpdate; ls.Clear; ls.Capacity:=l;
  for l:=0 to l-1 do ls.Add(a[l]);
  ls.EndUpdate;
  DelStack;
end;

procedure ArrDel(var a: TArrStr; n: longint);
var l: longint;
begin
  AddStack('My_pr.ArrDel');
  l:=Length(a)-1;
  for n:=n+1 to l do a[n-1]:=a[n];
  SetLength(a,l);
  DelStack;
end;

procedure ArrDel(var a: TArrVar; n: longint);
var l: longint;
begin
  AddStack('My_pr.ArrDel(v)');
  l:=Length(a)-1;
  for n:=n+1 to l do a[n-1]:=a[n];
  SetLength(a,l);
  DelStack;
end;

procedure ArrProcNone;
var i: longint;
begin
  AddStack('My_pr.ArrProcNone');
  for i:=low(a) to high(a) do a[i];
  DelStack;
end;

function Space;
begin
	result:=StringOfChar(' ',n);
end;

procedure SpaceSelf(var s: string);
begin
  s:=Space(Length(s));
end;

procedure SpaceSelf(var s: variant);
begin
  s:=Space(Length(s));
end;

function SpaceStr;
var s: variant;
	lemp: boolean;
  i,l: longint;
begin
	AddStack('My_pr.SpaceStr');
  s:=st;
  if MyVarType(s,true)=varDouble then MroundSelf(s,ndec) else IsNil(s,'');
  result:=VarAsType(s,varString); lemp:=ReplNegSelf(nlen,result);
  if ndec=0 then result:=IntToStr(Int064(result)) else result:=MyFloatToStr(Float0(result),nlen,ndec);
  l:=Length(result); i:=1;
  while i<=l do
    if (result[i]<=' ') or (result[i]='0') then Inc(i) else break;
  if l-i+1>nLen then
  	if not lemp and Limit then result:=StringOfChar('*',nLen) else Delete(result,1,i-1)
  else result:=PadL(Copy(result,i,MaxInt),nlen);
  DelStack;
end;

procedure SpaceStrSelf(var st: string; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true);
begin
  st:=SpaceStr(st,nlen,ndec,Limit);
end;

procedure SpaceStrSelf(var st: variant; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true);
begin
  st:=SpaceStr(st,nlen,ndec,Limit);
end;

procedure SpaceStrSelf(var av: array of variant; i: longint; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true);
begin
  av[i]:=SpaceStr(av[i],nlen,ndec,Limit);
end;

procedure SpaceStrSelf(ls: TStrings; i: longint; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true);
begin
  ls[i]:=SpaceStr(ls[i],nlen,ndec,Limit);
end;

procedure SpaceStrSelf(var a: TArrStr; l: longint = NegDef; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true);
var i: longint;
begin
  for i:=0 to ReplNeg(l,a)-1 do SpaceStrSelf(a[i],nlen,ndec,Limit);
end;

procedure SpaceStrList;
var i: longint;
begin
  AddStack('My_pr.SpaceStrList');
  for i:=0 to ls.Count-1 do SpaceStrSelf(ls,i,nlen,ndec,Limit);
  DelStack;
end;

function MyFloatToStr;
begin
  AddStack('My_pr.MyFloatToStr');
  result:=FloatToStrF(mround(Value,Digits),ffFixed,Precision,Digits);
  DelStack;
end;

function SpaceStr0;
var n: longint;
begin
	AddStack('My_pr.SpaceStr0');
	result:=SpaceStr(s,nlen,ndec,Limit);
  n:=ReplNeg(nlen,result)-ndec-IfThen(ndec<>0,1);
  if empty(LeftStr(result,n))
  then result:=IfThen(n>1,Space(n-2)+IfThen((StrToChar(TrimLeft(result))='-'),'-',' '))
    +'0'+Copy(result,n+1,MaxInt);
  DelStack;
end;

procedure SpaceStr0Self(var st: string; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true);
begin
  st:=SpaceStr0(st,nlen,ndec,Limit);
end;

procedure SpaceStr0Self(var st: variant; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true);
begin
  st:=SpaceStr0(st,nlen,ndec,Limit);
end;

function NumStr;
var i: Int64;
begin
	case MyVarType(s) of
    varNull: i:=0;
    varString: i:=Int064(s);
  else i:=s;
  end;
  if n=NegDef then n:=Length(s);
  result:=PadL(IntToStr(i),n,'0');
end;

procedure NumStrSelf(var s: string; n: longint = NegDef);
begin
  s:=NumStr(s,n);
end;

procedure NumStrSelf(var s: variant; n: longint = NegDef);
begin
  s:=NumStr(s,n);
end;

procedure NumStrSelf(ls: TStrings; i: longint; n: longint = NegDef);
begin
  ls[i]:=NumStr(ls[i],n);
end;

function FInt0(const ss: string): string;
var i,l: longint;
begin
	result:=TrimLeft(ss); l:=1;
  if length(result)>0 then
  	if result[1] in ['+','-'] then begin
      Inc(l); result:=result[1]+TrimLeft(Copy(result,2,MaxInt));
    end;
  for i:=l to length(result) do if not IsDigit(result[i]) then begin
    SetLength(result,i-1); break;
  end;
end;

function Int0;
begin
	AddStack('My_pr.Int0');
  result:=StrToIntDef(FInt0(ss),0);
  DelStack;
end;

procedure Int0Self;
begin
	AddStack('My_pr.Int0Self');
  if MyVarType(v)=varString then v:=Int0(v);
  DelStack;
end;

function Int064;
begin
  result:=StrToInt64Def(FInt0(ss),0);
end;

function StrInt;
begin
  AddStack('My_pr.StrInt');
  result:=IntToStr(Int0(ss));
  DelStack;
end;

function IsStrInt;
begin
  AddStack('My_pr.IsStrInt');
  result := StrInt(ss)=ss;
  DelStack;
end;

function Str2Int;
begin
  result:=StrToIntDef(Trim(s),0);
end;

function Str2IntEq(var Dest: Int64; const s: string; Source: Int64): boolean;
begin
  Dest:=StrToInt64Def(s,Source); result := Dest=Source;
end;

function Str2IntEq(const s: string; Source: Int64): boolean; overload;
var Dest: Int64;
begin
  result:=Str2IntEq(Dest,s,Source);
end;

function Str2IntNeg(var Dest: Int64; const s: string): boolean;
begin
  result:=Str2IntEq(Dest,s,NegDef);
end;

{function Str2IntNeg(const s: string): boolean;
var Dest: Int64;
begin
  result:=Str2IntNeg(Dest,s);
end;}

function Float0;
var i,j,lj,lj1: Int64;
	l: longint;
  a: TNamePrimStr;
begin
	AddStack('My_pr.Float0');
  a:=StrDivDlm('E',AnsiUpperCase(StrTran(s,['.',',',' ','"',''''],[DecimalSeparator,DecimalSeparator,'','',''])));
  lj1:=Int064(a[2]);
  if Abs(lj1)>4900 then result:=0
  else begin
    i:=Int064(a[1]); a:=StrDivDlm(DecimalSeparator,a[1]); l:=Length(a[2]); j:=Int064(a[2]); lj:=1;
    if j<>0 then begin
      while lj<=l do
        if a[2,lj] in [' ','0'] then Inc(lj) else break;
      while lj<=l do
        if IsDigit(a[2,lj]) then Inc(lj) else break;
      Dec(lj);
    end;
    if i<0 then j:=-j;
    result:=(i+j*IntPower(10,-lj))*IntPower(10,lj1);
    if (i=0) and (StrToChar(TrimLeft(s))='-') then result:=-result;
  end;
  DelStack;
end;

procedure Float0Self;
begin
  ss:=Float0(ss);
end;

function CompBegStr(const AText,ASubText: string): boolean;
begin
  result:=AnsiStartsStr(ASubText,AText);
end;

function PadL;
var l: longint;
begin
	l:=n-Length(s);
	if l<0 then result:=LeftStr(s,n) else result:=StringOfChar(c,l)+s;
end;

procedure PadLSelf(var s: string; n: longint; c: Char = ' ');
begin
  s:=PadL(s,n,c);
end;

procedure PadLSelf(var s: variant; n: longint; c: Char = ' ');
begin
  s:=PadL(s,n,c);
end;

procedure PadLSelf(ls: TStrings; i: longint; n: longint; c: Char = ' ');
begin
  ls[i]:=PadL(ls[i],n,c);
end;

function PadR;
var l: longint;
begin
	{$IFDEF STACKALL}AddStack('My_pr.PadR');{$ENDIF}
	l:=n-Length(s);
	if l<0 then result:=Copy(s,1,n) else result:=s+StringOfChar(c,l);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure PadRSelf(var s: string; n: longint; c: Char = ' ');
begin
  s:=PadR(s,n,c);
end;

procedure PadRSelf(var s: variant; n: longint; c: Char = ' ');
begin
  s:=PadR(s,n,c);
end;

procedure PadRSelf(ls: TStrings; i: longint; n: longint; c: Char = ' ');
begin
  ls[i]:=PadR(ls[i],n,c);
end;

function PadC;
var l,l2: longint;
begin
	AddStack('My_pr.PadC');
	l:=n-length(s);
	if l<0 then result:=LeftStr(s,n)
  else begin
		l2 := l shr 1; result:=StringOfChar(c,l2)+s+StringOfChar(c,l-l2);
  end;
  DelStack;
end;

function StrTran(const s,ss: string; const sr: string = '';
  Flags: TReplaceFlags = [rfReplaceAll]; pCnt: PLongInt = nil): string;
var l: longint;
  st: string;
  procedure ChkLen(ln: longint);
  begin
    {$IFDEF STACKALL}AddStack('My_pr.StrTran(s).ChkLen');{$ENDIF}
    if ln>l then begin
      while ln>l do ShlD(l);
      SetLength(result,l); SetLength(st,l);
    end;
    {$IFDEF STACKALL}DelStack;{$ENDIF}
  end;
var j,lMax,l1,l2,lst,sl,rl: longint;
  sss,su: string;
  psu: PString;
  fl,lSeek: boolean;
begin
	{$IFDEF STACKALL}AddStack('My_pr.StrTran(s)');{$ENDIF}
  sl:=Length(ss);
  if sl=0 then result:=s
  else begin
    if rfIgnoreCase in Flags then sss:=AnsiUpperCase(ss) else sss:=ss;
    l:=Length(s); lst:=l; lMax:=max(KByte,l); l1:=Length(sr)-sl;
    if l1>0 then begin
      if rfReplaceAll in Flags then MultD(l1,l div sl);
      Inc(l,l1);
      if l>lMax then l:=lMax;
    end;
    SetLength(result,l); SetLength(st,l); CopyMemory(pointer(result),pointer(s),lst);
    ChkLen(lst); CopyMemory(pointer(st),pointer(result),lst);
    if rfIgnoreCase in Flags then begin
      su:=AnsiUpperCase(result); psu:=@su;
    end
    else psu:=@st;
    l2:=0; l1:=0; lSeek:=true;
    while l1<lst do begin
      fl:=lSeek;
      if fl then begin
        ChkLen(l1+sl);
        for j:=1 to sl do
          if psu^[l1+j]<>sss[j] then begin
            fl:=false; break;
          end;
      end;
      if fl then begin
        rl:=Length(sr); ChkLen(l2+rl);
        CopyMemory(PointerStr(result,l2),pointer(sr),rl);
        Inc(l2,rl); Inc(l1,sl); IncD(pCnt);
        if not(rfReplaceAll in Flags) then lSeek:=false;
      end
      else begin
        Inc(l2); Inc(l1); ChkLen(l2); result[l2]:=st[l1];
      end;
    end;
    lst:=l2;
    SetLength(result,lst);
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure StrTranSelf(var s: string; const ss: string; const sr: string = '';
  Flags: TReplaceFlags = [rfReplaceAll]; pCnt: PLongInt = nil);
begin
  s:=StrTran(s,ss,sr,Flags,pCnt);
end;

procedure StrTranSelf(var s: variant; const ss: string; const sr: string = '';
  Flags: TReplaceFlags = [rfReplaceAll]; pCnt: PLongInt = nil);
begin
  s:=StrTran(s,ss,sr,Flags,pCnt);
end;

procedure StrTranSelf(ls: TStrings; const ss: string; const sr: string = '';
  Flags: TReplaceFlags = [rfReplaceAll]; pCnt: PLongInt = nil);
begin
  ls.Text:=StrTran(ls.Text,ss,sr,Flags,pCnt);
end;

function StrTran(const s: string; const sa,ra: array of string;
  Flags: TReplaceFlags = [rfReplaceAll]; pCnt: PLongInt = nil): string;
var l: longint;
  st: string;
  procedure ChkLen(ln: longint);
  begin
    {$IFDEF STACKALL}AddStack('My_pr.StrTran(a).ChkLen');{$ENDIF}
    if ln>l then begin
      while ln>l do ShlD(l);
      SetLength(result,l); SetLength(st,l);
    end;
    {$IFDEF STACKALL}DelStack;{$ENDIF}
  end;
var i,j,lMax,l1,l2,lst,h,sl,rl: longint;
  ssa,sra: TArrStr;
  su: string;
  psu: PString;
  fl,lSeek: boolean;
begin
	{$IFDEF STACKALL}AddStack('My_pr.StrTran(a)');{$ENDIF}
  SetPLongInt(pCnt); h:=min(high(sa),high(ra)); l:=Length(s); lst:=l; lMax:=max(KByte,l);
  SetLength(ssa,Length(sa)); SetLength(sra,Length(ra)); l2:=low(ssa); fl:=true;
  for i:=0 to h do begin
    j:=Length(sa[i]);
    if j>0 then begin
      if rfIgnoreCase in Flags then ssa[l2]:=AnsiUpperCase(sa[i]) else ssa[l2]:=sa[i];
      sra[l2]:=ra[i]; Inc(l2);
      if fl then begin
        l1:=Length(ra[i])-j;
        if l1>0 then begin
          if rfReplaceAll in Flags then MultD(l1,l div j);
          Inc(l,l1);
          if l>lMax then begin
            l:=lMax; fl:=false;
          end;
        end;
      end;
    end;
  end;
  h:=l2-1; SetLength(result,l); SetLength(st,l); CopyMemory(pointer(result),pointer(s),lst);
  for i:=0 to h do begin
    ChkLen(lst); CopyMemory(pointer(st),pointer(result),lst);
    if rfIgnoreCase in Flags then begin
      su:=AnsiUpperCase(result); psu:=@su;
    end
    else psu:=@st;
    l2:=0; l1:=0; lSeek:=true;
    while l1<lst do begin
      fl:=lSeek; sl:=Length(ssa[i]);
      if fl then begin
        ChkLen(l1+sl);
        for j:=1 to sl do
          if psu^[l1+j]<>ssa[i][j] then begin
            fl:=false; break;
          end;
      end;
      if fl then begin
        rl:=Length(sra[i]); ChkLen(l2+rl);
        CopyMemory(PointerStr(result,l2),pointer(sra[i]),rl);
        Inc(l2,rl); Inc(l1,sl); IncD(pCnt);
        if not(rfReplaceAll in Flags) then lSeek:=false;
      end
      else begin
        Inc(l2); Inc(l1); ChkLen(l2); result[l2]:=st[l1];
      end;
    end;
    lst:=l2;
  end;
  SetLength(result,lst);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure StrTranSelf(var s: string; const sa,ra: array of string;
  Flags: TReplaceFlags = [rfReplaceAll]; pCnt: PLongInt = nil);
begin
  s:=StrTran(s,sa,ra,Flags,pCnt);
end;

procedure StrTranSelf(var s: variant; const sa,ra: array of string;
  Flags: TReplaceFlags = [rfReplaceAll]; pCnt: PLongInt = nil);
begin
  s:=StrTran(s,sa,ra,Flags,pCnt);
end;

procedure DecLen(var s: string; l: longint = 1);
begin
  SetLength(s,Length(s)-l);
end;

procedure DecLen(var s: TFileName; l: longint = 1);
begin
  SetLength(s,Length(s)-l);
end;

procedure DecLen(var s: TArrStr; l: longint = 1);
begin
  SetLength(s,Length(s)-l);
end;

procedure DecLen(var s: string; const sr: string);
begin
  DecLen(s,Length(sr));
end;

procedure CopySelf(var S: string; Index: longint; Count: longint = MaxInt);
begin
  S:=Copy(S,Index,Count);
end;

procedure CopySelf(var S: variant; Index: longint; Count: longint = MaxInt);
begin
  S:=Copy(S,Index,Count);
end;

procedure StuffStrSelf(var AText: string;
  AStart, ALength: longword; const ASubText: string);
begin
  AText:=StuffString(AText,AStart,ALength,ASubText);
end;

procedure StuffStrSelf(var AText: variant;
  AStart, ALength: longword; const ASubText: string);
begin
  AText:=StuffString(AText,AStart,ALength,ASubText);
end;

procedure StuffStrSelf(ls: TStrings; i: longint;
  AStart, ALength: longword; const ASubText: string);
begin
  ls[i]:=StuffString(ls[i],AStart,ALength,ASubText);
end;

procedure LeftSelf;
begin
  ls[i]:=LeftStr(ls[i],ACount);
end;

procedure RightSelf;
begin
  AText:=RightStr(AText,ACount);
end;

function Int2StrDef;
begin
  AddStack('My_pr.Int2StrDef');
  if i=0 then result:=Def else result:=IntToStr(i);
  DelStack;
end;

function IntToStrSelf;
begin
  AddStack('My_pr.IntToStrSelf');
  result := MyVarType(v)=varString;
  if not result then v:=IntToStr(v);
  DelStack;
end;

function Int2Str(const Value: variant): string; overload;
begin
  result:=IntToStr(Value);
end;

function Int2Str(Value: pointer): string;
begin
  result:=IntToStr(longint(Value));
end;

function Int2Str(Sender: TStrings; Index: longint): string;
begin
  result:=Int2Str(Sender.Objects[Index]);
end;

function Int2Str(Sender: TStringGrid; ACol,ARow: longint): string;
begin
  result:=Int2Str(Sender.Objects[ACol,ARow]);
end;

function Int2Str(Value: boolean): string;
begin
  result:=IntToStr(byte(Value));
end;

function Int2Str(Value: TSortMode; lPage: boolean = false): string;
begin
  result:=IntToStr(byte(Value)+IfThen(lPage,1));
end;

procedure AnsiUpperCaseSelf(var s: string);
begin
  s:=AnsiUpperCase(s);
end;

procedure AnsiUpperCaseSelf(var s: TFileName);
begin
  s:=AnsiUpperCase(s);
end;

procedure AnsiUpperCaseSelf(var s: variant);
begin
  s:=AnsiUpperCase(s);
end;

procedure TrimSelf(var s: string);
begin
  s:=Trim(s);
end;

procedure TrimSelf(var s: variant);
begin
  s:=Trim(s);
end;

procedure TrimSelf(ls: TStrings);
var i: longint;
begin
  for i:=0 to ls.Count-1 do TrimSelf(ls,i);
end;

procedure TrimSelf(ls: TStrings; i: longint);
begin
  ls[i]:=Trim(ls[i]);
end;

procedure TrimSelf(var a: array of string; l: longint = NegDef);
var i: longint;
begin
  for i:=0 to ReplNeg(l,a)-1 do TrimSelf(a[i]);
end;

procedure TrimLeftSelf;
begin
  s:=TrimLeft(s);
end;

procedure TrimRightSelf(var s: string);
begin
  s:=TrimRight(s);
end;

procedure TrimRightSelf(var s: variant);
begin
  s:=TrimRight(s);
end;

procedure TrimRightSelf(var a: TArrStr; l: longint = NegDef);
var i: longint;
begin
  for i:=0 to ReplNeg(l,a)-1 do TrimRightSelf(a[i]);
end;

function TrimUpper;
begin
	result:=AnsiUpperCase(Trim(s));
end;

procedure TrimUpperSelf(var s: string);
begin
  s:=TrimUpper(s);
end;

procedure TrimUpperSelf(var s: variant);
begin
  s:=TrimUpper(s);
end;

procedure TrimUpperSelf(var a: TArrStr);
var i: longint;
begin
  for i:=low(a) to high(a) do TrimUpperSelf(a[i]);
end;

procedure TrimUpperSelf(ls: TStrings; i: longint);
begin
  ls[i]:=TrimUpper(ls[i]);
end;

procedure TrimUpperSelf(var a: TDEPrmStr);
begin
  TrimUpperSelf(a[deVid]); TrimUpperSelf(a[deVName]);
end;

function RTrimUpper;
begin
	result:=AnsiUpperCase(TrimRight(s));
end;

procedure RTrimUpperSelf;
begin
  s:=RTrimUpper(s);
end;

function RSpTrimUpper;
begin
	result:=AnsiUpperCase(TrimSpRight(s));
end;

function LowCase;
begin
  AddStack('FMain.LowCase');
  result:=AnsiLowerCase(c)[1];
  DelStack;
end;

procedure LowCaseSelf;
begin
  c:=LowCase(c);
end;

procedure UpCaseSelf;
begin
  c:=AnsiUpCase(c);
end;

function IsDigit;
begin
	result := c in ['0'..'9'];
end;

function IsChrWord;
begin
	result := c in ['0'..'9','A'..'Z','_','a'..'z','Ё','ё','А'..'я'];
end;

function DelTrim;
var i,j,l: longint;
	fl,state: boolean;
  s: string;
begin
	AddStack('My_pr.DelTrim');
  if chars='' then begin
    s:=Trim(st); fl:=false; l:=Length(s); SetLength(result,l); j:=0;
    for i:=1 to l do begin
      if s[i]>' ' then fl:=false
      else if fl then continue
      else begin
        s[i]:=' '; fl:=true;
      end;
      Inc(j); result[j]:=s[i];
    end;
  end
  else begin
    // state = false: read normally
    // state = true : blank chars interval
    state:=false; i:=1; j:=0; l:=Length(st);
    fl:=false; // do we wrote any normal chars
    SetLength(result,l);
    while i<=l do
      if Pos(st[i],chars)=0 then begin
        if state then begin
          if fl then begin // don't write blank char at the begining
            inc(j); result[j]:=st[i-1];
          end;
          state:=false; // switch no normal mode
        end
        else begin
          inc(j); result[j]:=st[i];
          inc(i); // step to next char
          fl:=true; // already wrote some normal chars
        end;
      end
      else begin // found blank char
        state:=true; // switch to blank mode
        inc(i); // step to next char
      end;
  end;
  SetLength(result,j);
  DelStack;
end;

procedure DelTrimSelf(var st: string; const chars: string = '');
begin
  st:=DelTrim(st,chars);
end;

procedure DelTrimSelf(var st: variant; const chars: string = '');
begin
  st:=DelTrim(st,chars);
end;

function StrToBoolean(const v: variant): boolean;
begin
	{$IFDEF STACKALL}AddStack('My_pr.StrToBoolean');{$ENDIF}
	case MyVarType(v) of
  	varBoolean: result:=v;
  	varString: result := TrimUpper(v)=bTrue;
  else result:=false;
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function StrToBoolean(Field: TField): boolean;
begin
  result:=StrToBoolean(Field.Value);
end;

function StrToBoolean(Column: TColumn): boolean;
begin
  result:=StrToBoolean(Column.Field);
end;

procedure StrToBoolSelf;
begin
  v:=StrToBoolean(v);
end;

function listasarray;
var i,j,ls,offs:longint;
begin
	AddStack('My_pr.listasarray');
  ls:=length(sep); i:=low(a); offs:=1;
	while true do begin
		if IsPos(j,sep,s,offs) then begin
			a[i]:=copy(s,offs,j-offs); offs:=j+ls;
			if i<high(a) then inc(i) else break;
		end
    else begin
      if (offs>Length(s)) and not lend then Dec(i) else a[i]:=copy(s,offs,MaxInt);
      break;
		end;
	end;
	result:=i-low(a)+1;
  DelStack;
end;

procedure TokenStr;
var s,t: string;
  k,h: longint;
begin
  (* thread safe !!!!!! *)
  SetLength(sa,19); h:=0; s:=str;
  repeat
    if IsPos(k,d,s) then t:=ExtractLeftPart(s,k,d) else t:=s;
    if trimItems then TrimSelf(t);
    if h>high(sa) then SetLength(sa,ExpDynArrSz(h));
    sa[h]:=t; inc(h);
  until k=0;
  SetLength(sa,h);
end;

function ExpDynArrSz;
begin
  result:=(3*(highIx+1))div 2;
end;

procedure LsArrList;
var j,ls,offs:longint;
begin
	AddStack('My_pr.LsArrList');
  if lClear then lstr.Clear;
  ls:=length(sep); offs:=1;
	while true do
		if IsPos(j,sep,s,offs) then begin
			lstr.Add(copy(s,offs,j-offs)); offs:=j+ls;
		end
    else begin
			lstr.Add(copy(s,offs,MaxInt)); break;
		end;
  DelStack;
end;

function LsArrNoEnd;
begin
	AddStack('My_pr.LsArrNoEnd');
  result:=ListAsArray(s,a,sep);
  if RightStr(TrimRight(s),Length(sep))=sep then Dec(result);
  DelStack;
end;

function LsArrFill;
begin
	AddStack('My_pr.LsArrFill');
	result:=ListAsArray(s,a,sep); InitArr(a,result);
  DelStack;
end;

function LsArrDynamic(const s: string; var a: TArrStr; const sep: string; Opt: TLsArrDynOpt = []): longint;
begin
  AddStack('My_pr.LsArrDynamic');
  SetLength(a,max(IfThen(not(lsaSetLen in Opt),Length(a)),StrCount(sep,s)+3));
  result:=ListAsArray(s,a,sep,lsaEnd in Opt);
  if lsaSetLen in Opt then SetLength(a,result);
  if lsaSort in Opt then QuickSort(a,result);
  DelStack;
end;

function LsArrDynamic(const s: string; var a: TArrStr; const sep: string; Opt: TLsArrDynList): longint;
begin
  result:=LsArrDynamic(s,a,sep,[Opt]);
end;

function ArrayAsList;
var i,j,l,l1,ls: longint;
begin
	AddStack('My_pr.ArrayAsList');
  ReplNegSelf(cnt,Length(a)-beg); Inc(beg,low(a)); j:=beg; ls:=Length(sep); l:=ls*cnt;
  for i:=1 to cnt do
  	if j>high(a) then break
    else begin
      Inc(l,Length(a[j])); Inc(j);
    end;
  SetLength(result,l); l:=0; j:=beg;
  for i:=1 to cnt do begin
  	if j<=high(a) then begin
      l1:=Length(a[j]); CopyMemory(PointerStr(result,l),pointer(a[j]),l1); Inc(l,l1); Inc(j);
    end;
    CopyMemory(PointerStr(result,l),pointer(sep),ls); Inc(l,ls);
  end;
  if not SepEnd then DecLen(result,ls);
  DelStack;
end;

const aCh: TArrBoolChr = (' ','+');

function SetByte(var s: string; poz: longint; const zn: variant): boolean;
var fl: boolean;
begin
	AddStack('My_pr.SetByte');
  result:=false;
	if poz>=1 then begin
    fl := Length(s)<poz;
    if not fl then result := s[poz]=aCh[true];
    if MyVarType(zn)=varBoolean then begin
      if fl then PadRSelf(s,poz,aCh[false]);
      s[poz]:=aCh[boolean(zn)];
    end;
  end;
  DelStack;
end;

function GetByte(const s: string; poz: longint): boolean;
var st: string;
begin
  st:=s; result:=SetByte(st,poz,null);
end;

function GetByte(const s: string; var bset: TBoolSet): boolean;
var i: boolean;
begin
  result:=false; bset:=[];
  for i:=low(i) to high(i) do if GetByte(s,byte(i)+1) then begin
    Include(bset,i); result:=true;
  end;
end;

procedure GetByteSelf;
begin
  AValue:=GetByte(AValue,poz);
end;

procedure SetByte(var s: string; const aPoz: array of longint);
var i: longint;
begin
	AddStack('My_pr.SetByte(aPoz)');
  for i:=low(aPoz) to high(aPoz) do SetByte(s,aPoz[i],true);
	DelStack;
end;

procedure SetByte(var s: string);
begin
  FillMemory(pointer(s),Length(s),Ord(aCh[true]));
end;

function SetByte(const aPoz: array of longint): string;
begin
  result:=''; SetByte(result,aPoz);
end;

function SetByte(l: longint): string;
begin
  SetLength(result,l); SetByte(result);
end;

function SetByteSet;
var fl: boolean;
begin
  AddStack('My_pr.SetByteSet');
  result:='';
  for fl:=false to true do SetByte(result,byte(fl)+1,fl in bset);
  DelStack;
end;

function SetByte(var s: string; part,poz: longint; const zn: variant): boolean;
const Dlm = '/';
var l: longint;
  a: array[1..100] of string;
begin
	AddStack('My_pr.SetByte(part)');
  l:=LsArrFill(s,a,Dlm); result:=SetByte(a[part],poz,zn);
  if not IsNil(zn) then s:=ArrayAsList(a,Dlm,max(l,part));
  DelStack;
end;

function GetByte(const s: string; part,poz: longint): boolean;
var st: string;
begin
  st:=s; result:=SetByte(st,part,poz,null);
end;

function NoBytes;
var i: longint;
begin
  AddStack('My_pr.NoBytes');
  result:=s;
  for i:=1 to Length(s) do SetByte(result,i,not GetByte(result,i));
  DelStack;
end;

function SetBit(var s: string; poz: longint; const zn: variant): boolean;
var fl: boolean;
	i: longint;
  b,ms: byte;
begin
	AddStack('My_pr.SetBit');
  result:=false;
	if poz>=1 then begin
  	i := ((poz-1) div 8)+1; fl := Length(s)<i;
    ms := poz mod 8;
    if ms=0 then ms:=1 else ms := 1 shl (8-ms);
    if not fl then result := (Ord(s[i]) and ms) > 0;
    if MyVarType(zn)=varBoolean then begin
      if fl then PadRSelf(s,i,Chr(0));
      b:=Ord(s[i]);
      if zn then Or_D(b,ms) else b := b and not ms;
      s[i]:=Chr(b);
    end;
  end;
  DelStack;
end;

function GetBit;
var st: string;
begin
  st:=s; result:=SetBit(st,poz,null);
end;

{procedure SetBit(var s: string; const aPoz: array of longint);
var i: longint;
begin
	AddStack('My_pr.SetBit');
	for i:=low(aPoz) to high(aPoz) do SetBit(s,aPoz[i],true);
  DelStack;
end;}

function SetBit(l: longint; Value: boolean = true): string;
begin
  AddStack('My_pr.SetBit(l)');
  result:=StringOfChar(IfThenChar(Value,MaxChr,#0),Ceil(l/8));
  DelStack;
end;

function MaskNum;
begin
	AddStack('My_pr.MaskNum');
	result:=StringOfChar(StrToChar(IfThen((l-t<3) or not Sign,'9','#')),l-t-1)
	 	+IfThen(t=0,'9',DecimalSeparator+StringOfChar('9',t));
  DelStack;
end;

function zpp;
var sl: string;
	dl,dr,dc,lsl: longint;
  l: variant;
begin
	AddStack('My_pr.zpp');
  l:=IsNilc(ln,Length(s)); sl:=TrimLeft(s); lsl:=length(sl); dl:=l-lsl;
  TrimRightSelf(sl); dr:=lsl-length(sl); dc:=length(sl);
  if dc=0 then result:=StringOfChar(c,longint(l))
  else begin
    if dc>l then result:=LeftStr(sl,l)
    else begin
      if dl>1 then begin
        IncL(sl,' '); Dec(dl);
      end;
      if dr>1 then begin
        IncD(sl,' '); Dec(dr);
      end;
      result:=LeftStr(StringOfChar(c,dl)+sl+StringOfChar(c,dr),l);
    end;
  end;
  DelStack;
end;

function zppl;
var l: variant;
begin
	AddStack('My_pr.zppl');
	l:=IsNilc(ln,Length(s)); result:=zpp(padl(Trim(s),l),l,c);
  DelStack;
end;

function zppr;
var l: variant;
begin
	AddStack('My_pr.zppr');
	l:=IsNilc(ln,Length(s)); result:=zpp(padr(Trim(s),l),l,c);
  DelStack;
end;

function zppc;
var l: variant;
begin
	AddStack('My_pr.zppc');
	l:=IsNilc(ln,Length(s)); result:=zpp(padc(Trim(s),l),l,c);
  DelStack;
end;

type
  TArrAsl = record
    a: array of record
      a: TArrPosLen;
      l: longint;
    end;
    l: longint;
  end;

function GetAslArr(const st: string; var s: string; var ao: TArrAsl; lsFont: TFontIndexList): boolean;
  function IsAlphaDig(i: longint): boolean;
  var c: char;
  begin
    AddStack('My_pr.GetAslArr.IsAlphaDig');
    c:=s[i]; result := (c in ['(',')','[',']','{','}','"','''','«','»']) or IsChrWord(c) and (c<>'_');
    DelStack;
  end;
var i: longint;
	function IsDateOrNum: boolean;
    function IsDig(i: longint): boolean;
    begin
      AddStack('My_pr.GetAslArr.IsDateOrNum.IsDig');
      result:=IsDigit(s[i]);
      DelStack;
    end;
  var p,j: longint;
  	st: string;
  begin
    AddStack('My_pr.GetAslArr.IsDateOrNum');
    st:=Copy(s,i,MaxInt); p:=PosEnd(' ',st)+i-1;
    result := IsDig(i) and IsDig(i+1) and not IsAlphaDig(i+2)
    	and IsDig(i+3) and IsDig(i+4) and not IsAlphaDig(i+5)
      and IsDig(i+6) and IsDig(i+7);
    if result then begin
    	j:=p-i;	result := (j=8) or (j=10) and IsDig(i+8) and IsDig(i+9);
    end;
    if not result then begin
    	j:=i; result:=true;
    	while (j<=p) and IsDig(j) do Inc(j);
      if j<=p then
      	if IsAlphaDig(j) then result:=false
        else begin
		    	while (j<=p) and IsDig(j) do Inc(j);
          if j<p then result:=false;
        end;
    end;
    if result then i:=p;
    DelStack;
  end;
var p: longint;
	procedure aAdd(cr: boolean = false);
    function gl(n: longint):boolean;
    begin
      AddStack('My_pr.GetAslArr.aAdd.gl');
      result := AnsiUpperCase(s[n])[1] in ['А','Е','Ё','И','О','У','Ы','Э','Ю','Я'];
      DelStack;
    end;
    procedure aAdd1(const pz,ln: longint);
    begin
      AddStack('My_pr.GetAslArr.aAdd.aAdd1');
      with ao,a[l],a[l] do begin
        Pos:=pz; Len:=ln; Inc(l);
      end;
      DelStack;
    end;
  var j,k,x,y: longint;
  	f: boolean;
  begin
    AddStack('My_pr.GetAslArr.aAdd');
    with ao do begin
      if Length(a)=l then SetLength(a,l+100);
      with a[l] do begin
        k:=max(1,i-p);
        if Length(a)<k then SetLength(a,max(k,Length(a)+100));
        l:=0; k:=0;
        for j:=p to i-1 do if gl(j) then Inc(k);
        if k=0 then aAdd1(p,i-p)
        else begin
          x:=p; y:=p-1;
          for j:=p to i-1 do begin
            f:=false;
            if k>=1 then
              if k=1 then begin
                y:=i-1; f:=true;
              end
              else if gl(j) then begin
                y:=j; f:=true;
                if not gl(j+1) then
                  if s[j+2] in ['ъ','ь'] then Inc(y,2)
                  else if not(gl(j+1) or gl(j+2)) then Inc(y);
              end;
            if f then begin
              aAdd1(x,y-x+1); Dec(k); x:=y+1;
            end;
          end;
        end;
        if l>1 then begin
          j:=0;
          while j<l do
            if a[j].Len>1 then Inc(j)
            else begin
              x:=MaxInt; y:=MaxInt; Dec(l);
              if j>0 then x:=a[j-1].Len;
              if j<l then y:=a[j+1].Len;
              if x>y then Inc(j);
              Inc(a[j-1].Len,a[j].Len);
              for x:=j+1 to l do a[x-1]:=a[x];
            end;
        end;
        Inc(i,IfThen(cr,lCRLF,1)); p:=i;
      end;
      Inc(l);
    end;
    DelStack;
  end;
var nb,ne,lst: longint;
  lSp: boolean;
begin
  AddStack('My_pr.GetAslArr');
  nb:=1; ne:=Length(st);
  while nb<=ne do begin
    if st[nb]>' ' then break;
    Inc(nb);
    if Assigned(lsFont) then lsFont.Delete(0);
  end;
  while ne>=nb do begin
    if st[ne]>' ' then break;
    Dec(ne);
    if Assigned(lsFont) then lsFont.Delete(lsFont.Count-1);
  end;
	lSp:=false; SetLength(s,ne-nb+1); lst:=0;
	for nb:=nb to ne do begin
  	if st[nb]=' ' then
    	if lSp then begin
        if Assigned(lsFont) then lsFont.Delete(lst);
        continue;
      end
      else lSp:=true
    else lSp:=false;
    Inc(lst); s[lst]:=st[nb];
  end;
  SetLength(s,lst); result := lst>0;
  if result then with ao do begin
    l:=0; p:=1; i:=1;
    while i<=lst do
      if s[i]=' ' then aAdd
      else if IsDateOrNum then continue
      else if not IsAlphaDig(i) then aAdd
      else if Copy(s,i,lCRLF)=CRLF then aAdd(true)
      else Inc(i);
    aAdd;
    for i:=0 to l-1 do with a[i] do if l>0 then with a[l-1] do begin
      p:=Pos+Len;
      if lst>=p then if s[p]<>' ' then Inc(Len);
    end;
  end;
  DelStack;
end;

procedure astolin(Canvas: TCanvas; ls: TStringList; const st: string; w: longint; h: longint = 0;
	PrcSpMin: Word = 0; pEnd: PLongInt = nil; RateX: Double = 1; RateY: Double = 1; lsFont: TFontIndexList = nil); overload;
var s: string;
	function wTxt(nb,ne: longint; const sOther: string = ''): longint;
  var fo,i,l: longint;
    procedure sInc;
    begin
      {$IFDEF STACKALL}AddStack('My_pr.astolin.wTxt.sInc');{$ENDIF}
      if fo>=0 then Inc(result,Canvas.TextWidth(Copy(s,i+1,l)));
      {$IFDEF STACKALL}DelStack;{$ENDIF}
    end;
    function IncRes(n: longint): boolean;
    var fn: longint;
    begin
      {$IFDEF STACKALL}AddStack('My_pr.astolin.wTxt.IncRes');{$ENDIF}
      Dec(n); fn:=lsFont[n]; result := fn<>fo;
      if result then begin
        sInc; fo:=fn; Canvas.Font.Assign(lsFont.GetFont(n)); i:=n; l:=0;
      end;
      Inc(l);
      {$IFDEF STACKALL}DelStack;{$ENDIF}
    end;
  begin
    {$IFDEF STACKALL}AddStack('My_pr.astolin.wTxt');{$ENDIF}
    if Assigned(Canvas) then begin
      if Assigned(lsFont) then begin
        fo:=-1; result:=0;
        while nb<=ne do begin
          IncRes(nb); Inc(nb);
        end;
        if sOther='' then sInc
        else begin
          if not IncRes(ne) then sInc;
          if fo>=0 then Inc(result,Canvas.TextWidth(sOther));
        end;
      end
      else result:=Canvas.TextWidth(Copy(s,nb,ne-nb+1)+sOther);
      result:=ceil(result*RateX);
    end
    else result:=ne-nb+1+Length(sOther);
    {$IFDEF STACKALL}DelStack;{$ENDIF}
  end;
	function wExit(nb,ne: longint; const sOther: string = ''): boolean;
  begin
    {$IFDEF STACKALL}AddStack('My_pr.astolin.wExit');{$ENDIF}
    result := wTxt(nb,ne,sOther)>w;
    {$IFDEF STACKALL}DelStack;{$ENDIF}
  end;
var
  al: array of record
    nb,ne,h: longint;
    lOther: boolean;
  end;
	function hExit: boolean;
  var i,h1: longint;
  begin
    AddStack('My_pr.astolin.hExit');
    h1:=ls.Count;
    if Assigned(Canvas) then
      if Assigned(lsFont) then begin
        h1:=0;
        for i:=0 to ls.Count-1 do Inc(h1,al[i].h);
      end
      else h1:=ceil(CanvasMaxH(Canvas)*RateY)*h1;
    result := h1>h;
    DelStack;
  end;
  function alAdd(nb,ne: longint; lOther: boolean = false): longint;
  begin
    AddStack('My_pr.astolin.alAdd');
    result:=ls.Add(Copy(s,nb,ne-nb+1)+IfThen(lOther,'-'));
    if Length(al)=result then SetLength(al,result shl 1);
    al[result].nb:=nb; al[result].ne:=ne; al[result].lOther:=lOther;
    DelStack;
  end;
type TAslType = (astWord,astCarry,astChar);
var i,p: longint;
	ao,a: TArrAsl;
	function aRest(tp: TAslType): boolean;
    procedure sWords(var nb,ne: longint; i: longint; j: longint = NegDef);
    begin
      AddStack('My_pr.astolin.aRest.sWords');
      with a do begin
        nb:=a[p].a[0].Pos; with a[i].a[ReplNeg(j,a[i].l-1)] do ne:=Pos+Len-1;
        while nb<=ne do if s[nb]>' ' then break else Inc(nb);
      end;
      DelStack;
    end;
    procedure lsAdd(tp: TAslType);
    var nb,ne: longint;
      sOther: string;
      procedure lsAdd1(np: longint);
      var i: longint;
        lOther: boolean;
      begin
        AddStack('My_pr.astolin.aRest.lsAdd.lsAdd1');
        lOther := sOther<>'';
        if (ne>=nb) or lOther then begin
          i:=alAdd(nb,ne,lOther);
          if Assigned(lsFont) then begin
            if lOther then begin
              Canvas.Font.Assign(lsFont.GetFont(ne-1)); al[i].h:=CanvasMaxH(Canvas);
            end
            else al[i].h:=0;
            while nb<=ne do begin
              Canvas.Font.Assign(lsFont.GetFont(nb-1)); MaxSelf(al[i].h,CanvasMaxH(Canvas)); Inc(nb);
            end;
            al[i].h:=ceil(al[i].h*RateY);
          end;
          if h>0 then
            if hExit then begin
              result:=true;
              if Assigned(pEnd) then ls.Delete(ls.Count-1);
            end;
          if not result then p:=np;
        end;
        DelStack;
      end;
      function aMove(i: longint): longint;
      var i1,i11,j1: longint;
      begin
        AddStack('My_pr.astolin.aRest.lsAdd.aMove');
        with a do begin
          if Length(a)=l then SetLength(a,l+100);
          Inc(l); i11:=l-1;
          for i1:=l-1 downto i+1 do begin
            Dec(i11); a[i1].l:=a[i11].l;
            with a[i1] do if Length(a)<l then SetLength(a,l);
            for j1:=0 to a[i1].l-1 do a[i1].a[j1]:=a[i11].a[j1];
          end;
        end;
        result:=i;
        DelStack;
      end;
      procedure CarryOrChar(i: longint);
      var ob,oe,j,i1,j1: longint;
      begin
        AddStack('My_pr.astolin.aRest.lsAdd.CarryOrChar');
        if wExit(nb,ne) then with a do begin
          ob:=nb; oe:=ne; j:=a[i].l-1; sOther:='-';
          while j>0 do begin
            Dec(j); sWords(nb,ne,i,j);
            if not wExit(nb,ne,sOther) then begin
              i1:=aMove(i+1); a[i1].l:=a[i].l-1-j;
              if Length(a[i1].a)<a[i1].l then SetLength(a[i1].a,max(a[i1].l,Length(a[i1].a)+100));
              for j1:=0 to a[i1].l-1 do a[i1].a[j1]:=a[i].a[j1+j+1];
              break;
            end;
          end;
          if j<0 then begin
            j:=oe-ob+1; nb:=ob; ne:=oe; sOther:='';
            while j>0 do begin
              if not wExit(nb,ne) then begin
                i1:=aMove(i+1); a[i1].l:=a[i].l;
                if Length(a[i1].a)<a[i1].l then SetLength(a[i1].a,max(a[i1].l,Length(a[i1].a)+100));
                for j1:=0 to a[i1].l-1 do a[i1].a[j1]:=a[i].a[j1];
                with a[i1].a[0] do begin
                  Inc(Pos,j); Dec(Len,j);
                end;
                break;
              end;
              Dec(ne); Dec(j);
            end;
          end;
        end;
        DelStack;
      end;
      procedure DecLen;
      begin
        AddStack('My_pr.astolin.aRest.lsAdd.DecLen');
        if sOther='' then Dec(ne) else sOther:='';
        DelStack;
      end;
    var i1,j,k,l1: longint;
    begin
      AddStack('My_pr.astolin.aRest.lsAdd');
      if not result then with a do if p<l then begin
        sOther:='';
        if i>p then begin
          sWords(nb,ne,i-1);
          if tp=astCarry then CarryOrChar(i-1)
          else if PrcSpMin>0 then begin
            i1:=0;
            for j:=nb to ne do if s[j]=' ' then Inc(i1);
            j:=0;
            while (j<a[i].l-1) and (w-wTxt(nb,ne,sOther)>PrcSpMin/100*i1*wTxt(ne+1,ne,' ')) do begin
              sWords(nb,ne,i,j); sOther:='-'; Inc(j);
            end;
            if wExit(nb,ne,sOther) then DecLen;
            if wExit(nb,ne,sOther) then begin
              if j=a[i].l then begin
                i1:=aMove(i)+1; l1:=0;
              end
              else begin
                i1:=i; l1:=j;
              end;
              k:=a[i].a[j-1].Len;
              while (k>0) and wExit(nb,ne,sOther) do begin
                DecLen;
                with a[i1].a[l1] do begin
                  Dec(Pos); Inc(Len);
                end;
                Dec(k);
              end;
            end;
            with a[i] do begin
              for k:=j to l-1 do a[k-j]:=a[k];
              Dec(l,j);
            end;
          end;
          lsAdd1(i);
        end
        else begin
          sWords(nb,ne,i); CarryOrChar(i); lsAdd1(i+1);
        end;
      end;
      DelStack;
    end;
  var nb,ne,i1,j: longint;
  begin
    AddStack('My_pr.astolin.aRest');
    result:=false;
    with a do begin
      l:=ao.l;
      if Length(a)<l then SetLength(a,max(l,Length(a)+100));
      for i1:=0 to l-1 do with a[i1] do begin
        l:=ao.a[i1].l;
        if Length(a)<l then SetLength(a,max(l,Length(a)+100));
        for j:=0 to l-1 do a[j]:=ao.a[i1].a[j];
      end;
      i:=0; p:=i; ls.Clear;
      while i<l do begin
        sWords(nb,ne,i);
        if wExit(nb,ne) then begin
          lsAdd(tp);
          if result then break;
        end;
        Inc(i);
      end;
      PrcSpMin:=0; lsAdd(tp);
      while i<l do begin
        lsAdd(tp); Inc(i);
      end;
    end;
    if Assigned(pEnd) then result:=false;
    if not result then for j:=0 to ls.Count-1 do with al[j] do if wExit(nb,ne) then begin
      result:=true; break;
    end;
    DelStack;
  end;
var als: TFontIndexSave;
  l: longint;
  procedure alsAdd(nls: longint);
  begin
  	AddStack('My_pr.astolin.alsAdd');
    if nls>0 then begin
      Dec(nls);
      with als[l] do begin
        n:=lsFont[nls]; o:=lsFont.Objects[nls]; Inc(l);
      end;
    end;
    DelStack;
  end;
var fl: boolean;
  aCRLF: TArrStr;
  ls1: TStringList;
  lsFont1: array of TFontIndexList;
  sz: TSize;
  j,l1: longint;
begin
	AddStack('My_pr.astolin');
  SetPLongInt(pEnd,Length(st)+1); ls.BeginUpdate; ls.Clear;
  if Pos(CRLF,st)=0 then begin
    // Защита от длинных строк
    if (h>0) and not Assigned(pEnd) then begin
      if Assigned(Canvas) then begin
        sz:=Canvas.TextExtent('.'); l:=trunc(w/RateX/sz.cx)*trunc(h/RateY/sz.cy);
      end
      else l:=w*h;
      if Assigned(lsFont) then with lsFont do while Count>l do Delete(Count-1);
      fl:=GetAslArr(LeftStr(st,l),s,ao,lsFont);
    end
    else fl:=GetAslArr(st,s,ao,lsFont);
    if fl then begin
      SetLength(al,1); 
      if aRest(astWord) then if aRest(astCarry) then begin
        ls.Clear; p:=1; l:=Length(s);
        for i:=1 to l do if wExit(p,i) then begin
          alAdd(p,i-1); p:=i;
        end;
        if p<=l then alAdd(p,l);
        if h>0 then while ls.Count>0 do
          if hExit then ls.Delete(ls.Count-1) else break;
        p:=ls.Count-1;
      end;
      with a do if InRange(p,0,l-1) then SetPLongInt(pEnd,a[p].a[0].Pos) else SetPLongInt(pEnd,Length(s)+1);
      if Assigned(lsFont) then begin
        l:=Length(ls.Text); p:=ls.Count-1;
        for i:=0 to p do if al[i].lOther then Inc(l);
        SetLength(als,l); l:=0;
        for i:=0 to p do with al[i] do begin
          for j:=nb to ne do alsAdd(j);
          if lOther then alsAdd(ne);
          if i<p then for j:=1 to lCRLF do alsAdd(ne);
        end;
        lsFont.Clear; lsFont.Capacity:=l;
        for l:=0 to l-1 do with als[l] do lsFont.Add(n,o);
      end;
    end;
  end
  else begin
    l:=LsArrDynamic(st,aCRLF,CRLF);
    if l>0 then begin
      ls1:=TStringList.Create;
      try
        SetLength(lsFont1,l);
        if Assigned(lsFont) then begin
          p:=0;
          for i:=0 to l-1 do begin
            lsFont1[i]:=TFontIndexList.Create; lsFont1[i].OnGetFont:=lsFont.OnGetFont;
            l1:=Length(aCRLF[i]);
            if i<l-1 then Inc(l1,lCRLF);
            lsFont1[i].Capacity:=l1;
            for j:=0 to l1-1 do begin
              lsFont1[i].Add(lsFont[p],lsFont.Objects[p]); Inc(p);
            end;
          end;
          lsFont.Clear;
        end
        else ZeroMemory(@lsFont1[0],l*SizeOf(lsFont1[0]));
        for i:=0 to l-1 do begin
          astolin(Canvas,ls1,aCRLF[i],w,h,PrcSpMin,pEnd,RateX,RateY,lsFont1[i]);
          while ls1.Count>0 do begin
            if ls1[ls1.Count-1]<>'' then break;
            ls1.Delete(ls1.Count-1);
            if Assigned(lsFont) then for j:=1 to lCRLF do lsFont1[i].Delete(lsFont1[i].Count-1);
          end;
          ls.AddStrings(ls1);
          if Assigned(lsFont) then begin
            lsFont.Add(lsFont1[i]);
            for j:=1 to lCRLF do lsFont.Add(0);
          end;
        end;
      finally
        ls1.Free;
        if Assigned(lsFont) then for i:=0 to l-1 do lsFont1[i].Free;
      end;
    end;
  end;
  ls.EndUpdate;
  DelStack;
end;

procedure astolin(const st: string; ls: TStringList; nk,ln: longint; Opt: TAstolinOpt = []);
var lvar: longint;
	av: TArrInt;
	avar: array[1..2] of record
  	ap: array[1..2] of record
	  	l,n: longint;
    end;
		an: TArrArrInt;
  end;
var l: longint;
  a: array[1..100] of string;
  ao: TArrAsl;
  s: string;
	procedure avarn(n: byte; i: longint; lls: boolean);
  var j,nb,no,no1,lo: longint;
  	s1: string;
  begin
    AddStack('My_pr.astolin.avarn');
    with avar[n] do begin
      l:=0; nb:=0; no:=0; no1:=0;
      for j:=low(an[i]) to high(an[i]) do begin
      	if n=2 then begin
        	s1:='';
        	for lo:=1 to an[i,j] do with ao.a[no].a[no1] do begin
          	IncD(s1,Copy(s,Pos,Len));
          	if no1=ao.a[no].l-1 then begin
            	IncD(s1,IfThen(Copy(s,Pos+Len,1)=' ',' ')); Inc(no); no1:=0;
            end
          	else Inc(no1);
          end;
          if no1=0 then begin
          	lo:=Length(s1)-1;
            if Copy(s1,lo,1)=' ' then SetLength(s1,lo);
          end
          else IncD(s1,'-');
        end
        else s1:=ArrayAsList(a,' ',an[i,j],false,nb);
        if lls then ls.Add(s1) else MaxSelf(l,s1);
        Inc(nb,an[i,j]);
      end;
    end;
    DelStack;
  end;
  function avarInit(n: byte; la: longint): boolean;
    procedure avar1(l,i: longint);
    var j,nlvar: longint;
    begin
      AddStack('My_pr.astolin.avarInit.avar1');
      with avar[n] do begin
        if i=nk-1 then begin
          if lvar=Length(an) then begin
            nlvar:=lvar+100; SetLength(an,nlvar);
            for j:=lvar to nlvar-1 do SetLength(an[j],nk);
          end;
          av[i]:=l;
          for j:=low(av) to high(av) do an[lvar,j]:=av[j];
          Inc(lvar);
        end
        else for j:=0 to l do begin
          av[i]:=j; avar1(l-j,i+1);
        end;
      end;
      DelStack;
    end;
  var i: longint;
  begin
    AddStack('My_pr.astolin.avarInit');
    with avar[n] do begin
    	lvar:=0; an:=nil; avar1(la,0); SetLength(an,lvar);
      ap[1].l:=-1; ap[2].l:=MaxInt; ap[1].n:=0; ap[2].n:=-1; result:=true;
      for i:=low(an) to high(an) do begin
      	avarn(n,i,false);
        if InRange(l,ap[1].l+1,ln) then begin
          ap[1].l:=l; ap[1].n:=i; result:=false;
        end
        else if InRange(l,ln+1,ap[2].l-1) then begin
          ap[2].l:=l; ap[2].n:=i;
        end;
      end;
      if not result then ap[2]:=ap[1];
    end;
    DelStack;
  end;
var la,n,n1,i,j: longint;
begin
	AddStack('My_pr.astolin');
  if ln>0 then begin
  	astolin(nil,ls,st,ln,nk);
    while ls.Count>nk do ls.Delete(ls.Count-1);
    l:=ls.Count-1;
    while ls.Count<nk do ls.Add('');
    for i:=0 to nk-1 do
      if i>l then begin
      	if aslnTrim in Opt then ls[i]:=space(ln);
      end
      else begin
        if aslnTrim in Opt then ls[i]:=DelTrim(ls[i]);
        if not(aslnAlign in Opt) or (i=l) then begin
          if not(aslnTrim in Opt) then PadRSelf(ls,i,ln);
        end
        else begin
          n:=ln-length(ls[i]); la:=listasarray(ls[i],a,' ');
          if la>1 then begin
            n1:=ModDiv(n,la-1);
            for j:=la downto 2 do begin
              IncL(a[j],space(n+IfThen(n1>0,2,1))); Dec(n1);
            end;
          end;
          ls[i]:='';
          for j:=1 to la do IncD(ls,i,a[j]);
        end;
      end;
  end
  else begin
    ls.BeginUpdate;
  	s:=DelTrim(StrTran(st,CRLF,' ')); SetLength(av,nk); ln:=-ln; ls.Clear;
    if avarInit(1,ListAsArray(s,a,' ',false)) then // по слогам
      if GetAslArr(s,s,ao,nil) then begin
        la:=0;
        with ao do for i:=0 to l-1 do Inc(la,a[i].l);
        with avar[2] do begin
          n:=IfThen(avarInit(2,la),2,1);
          if ap[n].l<avar[1].ap[2].l then begin
            avarn(2,ap[n].n,true); avar[1].ap[2].n:=-1;
          end;
        end;
      end;
    with avar[1].ap[2] do if n>=0 then avarn(1,n,true); // по словам
    ls.EndUpdate;
  end;
  DelStack;
end;

function astolin(Canvas: TCanvas; const st: string; w: longint; h: longint = 0;
	PrcSpMin: Word = 0; pEnd: PLongInt = nil; RateX: Double = 1; RateY: Double = 1; lsFont: TFontIndexList = nil): string;
var ls: TStringList;
begin
  if w>0 then begin
    ls:=TStringList.Create;
    try
      astolin(Canvas,ls,st,w,h,PrcSpMin,pEnd,RateX,RateY,lsFont); result:=TrimRight(ls.Text);
    finally
      ls.Free;
    end;
  end
  else begin
    result:=''; SetPLongInt(pEnd,Length(st)+1); 
  end;
end;

function astolin(const s: string; nk,ln: longint; Opt: TAstolinOpt = []): string;
var ls: TStringList;
begin
	ls:=TStringList.Create;
	try
	  astolin(s,ls,nk,ln,Opt); result:=ls.Text;
  finally
	  ls.Free;
  end;
end;

function astolin(const s: string; nk,ln,n: longint; Opt: TAstolinOpt = []): string;
var ls: TStringList;
begin
	AddStack('My_pr.astolin');
	ls:=TStringList.Create;
	try
	  astolin(s,ls,nk,ln,Opt);
    if InRange(n,1,ls.Count) then result:=ls[n-1] else result:='';
  finally
	  ls.Free;
  end;
  DelStack;
end;

function RPos;
var i,j,j1,l,l1: longint;
begin
	AddStack('My_pr.RPos');
	result:=0;
  if substr<>'' then begin
    l:=length(s); l1:=length(substr);
    for i:=l downto 1 do begin
      j:=i; j1:=1;
      while (j<=l) and (j1<=l1) do begin
        if s[j]<>substr[j1] then break;
        Inc(j); Inc(j1);
      end;
      if j1=l1+1 then begin
        result:=i; break;
      end;
    end;
  end;
  DelStack;
end;

function cenaprop;
  function chdo1000(n: longint; kind: byte): string;
  const
    chis: array[1..19] of string =
      ('один','два','три','четыре','пять','шесть','семь','восемь',
      'девять','десять','одиннадцать','двенадцать','тринадцать',
      'четырнадцать','пятнадцать','шестнадцать','семнадцать',
      'восемнадцать','девятнадцать');
    chis2: array[1..2] of string = ('одна','две');
    chis3: array[1..1] of string = ('одно');
    sot: array[1..9] of string =
      ('сто','двести','триста','четыреста','пятьсот','шестьсот',
      'семьсот','восемьсот','девятьсот');
    des: array[1..9] of string =
      ('десять','двадцать','тридцать','сорок','пятьдесят','шестьдесят',
      'семьдесят','восемьдесят','девяносто');
  var s1: string;
  begin
  	AddStack('My_pr.cenaprop.chdo1000');
  	result:=' '; ModD(n,1000);
   	if n>=100 then IncD(result,sot[n div 100]+' ');
   	ModD(n,100);
   	if n>=20 then begin
      IncD(result,des[n div 10]+' '); ModD(n,10);
    end;
   	if n>0 then begin
      s1:=chis[n];
      if (kind=2) and (n<3) then s1:=chis2[n]
      else if (kind=3) and (n<2) then s1:=chis3[n];
      IncD(result,s1+' ');
   	end;
    DelStack;
  end;
  function typokon(n: longint): longint;
  begin
  	AddStack('My_pr.cenaprop.typokon');
    if n>=20 then ModD(n,10);
    result:=IfThen((n>4) or (n=0),3,IfThen(n=1,1,2));
    DelStack;
  end;
const
	mlrd: array[1..3] of string = ('миллиард','миллиарда','миллиардов');
	mil: array[1..3] of string = ('миллион','миллиона','миллионов');
	tys: array[1..3] of string = ('тысяча','тысячи','тысяч');
	rub: array[1..3] of string = ('рубль','рубля','рублей');
	kop: array[1..3] of string = ('копейка','копейки','копеек');
var cc,n: Int64;
begin
	AddStack('My_pr.cenaprop');
  if c=0 then result:=''
  else begin
    MroundSelf(c,2); cc:=trunc(c); n := cc div 1000000000; result:=' ';
    if n>0 then IncD(result,chdo1000(n,1)+mlrd[typokon(n mod 100)]+' ');
    Dec(cc,n*1000000000); n := cc div 1000000;
    if n>0 then IncD(result,chdo1000(n,1)+mil[typokon(n mod 100)]+' ');
    Dec(cc,n*1000000); n := cc div 1000;
    if n>0 then IncD(result,chdo1000(n,2)+tys[typokon(n mod 100)]+' ');
    Dec(cc,n*1000); n:=cc;
    if n>0 then IncD(result,chdo1000(n,kind));
    if kind=0 then begin
      if n>0 then IncD(result,rub[typokon(n mod 100)]+' ')
      else if trunc(c)>0 then IncD(result,rub[3]+' ');
      cc:=trunc(c); n:=nround((c-cc)*100);
      result:=StrNum(result+IfThen(empty(result),'ноль рублей')+' ',n,2)+' '+kop[typokon(n)];
    end;
    result:=FRup(Trim(result));
  end;
  DelStack;
end;

function FRup;
begin
	AddStack('My_pr.FRup');
  result:=s;
  if s<>'' then UpCaseSelf(result[1]);
  DelStack;
end;

procedure FRupSelf(var s: string);
begin
  s:=FRup(s);
end;

procedure FRupSelf(var s: variant);
begin
  s:=FRup(s);
end;

function FLow;
var l: longint;
  fl: boolean;
begin
	AddStack('My_pr.FLow');
  result:=s; l:=Length(s);
  if l>0 then begin
    if l=1 then fl:=true else fl := (AnsiUpperCase(result[2])[1]<>result[2]) or empty(result[2]);
    if fl then LowCaseSelf(result[1]);
  end;
  DelStack;
end;

function StrToChar;
begin
	{$IFDEF STACKALL}AddStack('My_pr.StrToChar');{$ENDIF}
	result:=IfThen(s='',' ',s)[1];
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function EqualShape;
var ass,asl: TSegmStr;
	i,lss,lsl: longint;
  Source,Shape: string;
begin
	AddStack('My_pr.EqualShape');
  Source:=TrimRight(cSource); Shape:=TrimRight(cShape); result := (Shape=Source) or (Shape=UnDelim);
  if not result then begin
    lsl:=LsArrFill(Source,asl,',');
    lss:=LsArrFill(Shape,ass,',');
    result := lss=lsl;
    if result then
      for i:=low(asl) to lsl do
        if not((ass[i]=asl[i]) or (ass[i]=UnDelim)) then begin
          result:=false; break;
        end;
  end;
  DelStack;
end;

function ProcStrComp;
var p: longint;
begin
  AddStack('My_pr.ProcStrComp');
  PointerDef(pointer(pShape),@p);
  result:=IfThenComp(IsPos(pShape^,UnDelim,sl),EqualShape,CompBegStr);
  DelStack;
end;

function Str3t;
begin
	AddStack('My_pr.Str3t');
	result:=DelTrim(s);
	if Length(result)<l then PadRSelf(result,l);
  if empty(copy(result,l+1,MaxInt))
    then SetLength(result,l)
  else if Length(result)>lDots
    then result:=LeftStr(result,l-lDots)+IfThen(empty(copy(result,l-lDots+1,MaxInt)),Space(lDots),sDots);
  if lTrim then TrimRightSelf(result);
  DelStack;
end;

procedure Str3tSelf;
begin
  s:=Str3t(s,l,lTrim);
end;

function TextCRLF;
var l: longint;
  i: byte;
  fl: boolean;
begin
	AddStack('My_pr.TextCRLF');
  l:=Length(s); fl := l>=lCRLF;
  if fl then for i:=1 to lCRLF do
    if s[l-lCRLF+i]<>CRLF[i] then begin
      fl:=false; break;
    end;
  result:=s+IfThen(not fl,CRLF);
  if result=CRLF then result:='';
  DelStack;
end;

procedure TextCRLFSelf;
begin
  s:=TextCRLF(s);
end;

function ArrStrAlign;
var i: longint;
begin
	AddStack('My_pr.ArrStrAlign');
  if Bound or (h>0) then begin
    SetLength(a,h);
    for i:=l to h-1 do a[i]:='';
    l:=h;
  end;
  if Bound or (w>0) then for i:=0 to l-1 do PadRSelf(a[i],w);
  result:=ArrayAsList(a,CRLF,l);
  DelStack;
end;

function DlmTrim(const s: string; lTrim: boolean): string;
begin
  AddStack('My_pr.DlmTrim');
  if lTrim then result:=Trim(s) else result:=s;
  DelStack;
end;

function DlmBetween(const ss1,ss2,Dlm: string; lTrim: boolean = true): string;
var s1,s2: string;
begin
	AddStack('My_pr.DlmBetween(s)');
	s1:=DlmTrim(ss1,lTrim); s2:=DlmTrim(ss2,lTrim); result:=s1+IfThen((s1<>'') and (s2<>''),Dlm)+s2;
  DelStack;
end;

procedure DlmBetwSelf(var s1: string; const s2,Dlm: string; lTrim: boolean = true);
begin
  s1:=DlmBetween(s1,s2,Dlm,lTrim);
end;

procedure DlmBetwSelf(var s1: variant; const s2,Dlm: string; lTrim: boolean = true);
begin
  s1:=DlmBetween(s1,s2,Dlm,lTrim);
end;

procedure DlmBetwSelf(ls: TStrings; const Name,s2,Dlm: string; lTrim: boolean = true);
begin
  ls.Values[Name]:=DlmBetween(ls.Values[Name],s2,Dlm,lTrim);
end;

function DlmBetween(const a: array of string; const Dlm: string; lTrim: boolean = true): string;
var i: longint;
begin
	AddStack('My_pr.DlmBetween(a)');
  if Length(a)=0 then result:=''
  else begin
    i:=low(a); result:=DlmTrim(a[i],lTrim);
    while i<high(a) do begin
      Inc(i); DlmBetwSelf(result,a[i],Dlm,lTrim);
    end;
  end;
  DelStack;
end;

function TrimSp;
var I,L: longint;
begin
	AddStack('My_pr.TrimSp');
  L:=Length(S); I:=1;
  while (I<=L) and (S[I]=' ') do Inc(I);
  if I>L then Result:=''
  else begin
    while S[L]=' ' do Dec(L);
    Result:=Copy(S,I,L-I+1);
  end;
  DelStack;
end;

function TrimSpLeft;
var I,L: longint;
begin
	AddStack('My_pr.TrimSpLeft');
  L:=Length(S); I:=1;
  while (I<=L) and (S[I]=' ') do Inc(I);
  Result:=Copy(S,I,Maxint);
  DelStack;
end;

function TrimSpRight;
var I: longint;
begin
	AddStack('My_pr.TrimSpRight');
  I:=Length(S);
  while (I>0) and (S[I] in c) do Dec(I);
  Result:=Copy(S,1,I);
  DelStack;
end;

procedure AddSzStrings;
var i: longint;
begin
	AddStack('My_pr.AddSzStrings');
  if not empty(s) then with ls do begin
		for i:=0 to Count-1 do
 	  	if AnsiSameText(s,Strings[i]) then begin
        Delete(i); break;
      end;
  	Insert(0,s);
  	while Count>nlim do Delete(Count-1);
  end;
  DelStack;
end;

function TransMask;
var i,j: longint;
begin
	AddStack('My_pr.TransMask');
	case m of
  	mskNone: result:=PadR(s,l);
    mskX: result:=TrimRight(PadR(s,l));
    msk9: result:=SpaceStr(s,l);
    msk0: result:=numstr(s,l);
    msk9X,msk0X: begin
      if m=msk9X then result:=SpaceStr(s,l-1) else result:=numstr(s,l-1);
      j:=0;
      for i:=1 to length(s) do
        if not IsDigit(s[i]) then begin
          j:=i; break;
        end;
      if j=0 then IncD(result,' ') else IncD(result,s[i]);
    end;
    mskUser: if Assigned(Proc) then result:=Proc(Sender,s,l) else result:=s;
  end;
  DelStack;
end;

// Переводит строку '_<null>_<null>_...<null><null>' в TStringList
procedure PCharLsStr(p: PChar; ls: TStringList; lClear: boolean = true);
var i,j: longint;
begin
	AddStack('My_pr.PCharLsStr');
  if lClear then ls.Clear;
  i:=0; j:=0;
  while true do
  	if (p+i+j)^=#0 then begin
    	ls.Add(StrPas(p+i)); Inc(i,j+1); j:=0;
      if (p+i)^=#0 then break;
    end
    else Inc(j);
  DelStack;
end;

function CntCharBeg;
var l: longint;
begin
  AddStack('My_pr.CntCharBeg');
  result:=1; l:=Length(s);
  while result<=l do
    if s[result]=c then Inc(result) else break;
  Dec(result);
  DelStack;
end;

function SubPrmNeg(var Index,Count: longint; Length: longint; lNeg: boolean): boolean;
begin
  AddStack('My_pr.SubPrmNeg');
  if lNeg then begin
    if Index<0 then Inc(Index,Length+1);
    if Count<0 then Inc(Count,Length+1-Index);
    result := Count>0;
  end
  else begin
    MaxSelf(Index,1); MaxSelf(Count,0); result:=true;
  end;
  DelStack;
end;

function DlmCopy;
var a: TArrStr;
  l: longint;
begin
  AddStack('My_pr.DlmCopy');
  l:=LsArrDynamic(s,a,Dlm,IfThen(lNeg and (Index<0),lsaEnd));
  if SubPrmNeg(Index,Count,l,lNeg)
  then result:=ArrayAsList(a,Dlm,IfThen(Count=MaxInt,l-Index+1,Count),
    (Count=MaxInt) and (RightStr(s,Length(Dlm))=Dlm),Index-1)
  else result:='';
  DelStack;
end;

procedure DlmCopySelf(var s: string; Index: longint = 1; Count: longint = MaxInt;
	const Dlm: string = ','; lNeg: boolean = false);
begin
  s:=DlmCopy(s,Index,Count,Dlm,lNeg);
end;

procedure DlmCopySelf(var s: variant; Index: longint = 1; Count: longint = MaxInt;
	const Dlm: string = ','; lNeg: boolean = false);
begin
  s:=DlmCopy(s,Index,Count,Dlm,lNeg);
end;

function NewString;
begin
	AddStack('My_pr.NewString');
	New(Result); Result^:=S;
  DelStack;
end;

function ACompStr;
var i: longint;
	s: string;
begin
  AddStack('My_pr.ACompStr');
  result:=true; s:=st;
  for i:=low(a) to high(a) do
    if AnsiStartsStr(a[i],s) then s:=TrimLeft(Copy(s,Length(a[i])+1,MaxInt))
    else begin
      result:=false; break;
    end;
  if result then st:=s;
  DelStack;
end;

function DigRoman;
const
	a: array[1..13] of record
    w: Word;
    s: string;
  end =
    ((w:1   ; s:'I')
    ,(w:4   ; s:'IV')
    ,(w:5   ; s:'V')
    ,(w:9   ; s:'IX')
    ,(w:10  ; s:'X')
    ,(w:40  ; s:'XL')
    ,(w:50  ; s:'L')
    ,(w:90  ; s:'XC')
    ,(w:100 ; s:'C')
    ,(w:400 ; s:'CD')
    ,(w:500 ; s:'D')
    ,(w:900 ; s:'CM')
    ,(w:1000; s:'M')
    );
var i: byte;
begin
	AddStack('My_pr.DigRoman');
  result:='';
  if InRange(n,1,3999) then for i:=high(a) downto low(a) do with a[i] do while n>=w do begin
    Dec(n,w); IncD(result,s);
  end;
  DelStack;
end;

function TrimMemoStr;
var i,l: longint;
	a: TArrStr;
begin
  AddStack('My_pr.TrimMemoStr');
  if nk=0 then result:=''
  else begin
    SetLength(a,nk); l:=ListAsArray(s,a,CRLF);
    for i:=0 to l-1 do
      if Length(a[i])<ln then IncD(a[i],' ');
    result:=DelTrim(ArrayAsList(a,'',l));
  end;
  DelStack;
end;

function AnsiUpCase;
begin
  AddStack('My_pr.AnsiUpCase');
  case c of
    'а'..'я': result:=Chr(Ord(c)-32);
    'ё': result:='Ё';
  else result:=UpCase(c);
  end;
  DelStack;
end;

function CngLanguage;
const a: array[boolean,1..67] of char =
  (('`','~','#','Q','W','E','R','T','Y','U','I','O','P','{','}','q','w','e','r','t','y','u','i','o','p','[',']','A','S','D','F','G','H','J','K','L',':','"','a','s','d','f','g','h','j','k','l',';','Z','X','C','V','B','N','M','<','>','z','x','c','v','b','n','m',',','.','''')
  ,('ё','Ё','№','Й','Ц','У','К','Е','Н','Г','Ш','Щ','З','Х','Ъ','й','ц','у','к','е','н','г','ш','щ','з','х','ъ','Ф','Ы','В','А','П','Р','О','Л','Д','Ж','Э','ф','ы','в','а','п','р','о','л','д','ж','Я','Ч','С','М','И','Т','Ь','Б','Ю','я','ч','с','м','и','т','ь','б','ю','э')
  );
var i,j,k,l: longint;
  fl: boolean;
  ac: array[char] of char;
  c: char;
label lend;
begin
  AddStack('My_pr.CngLanguage');
  result:=s; l:=Length(s);
  for i:=1 to l do
    for j:=low(a[false]) to high(a[false]) do
      for fl:=false to true do
        if a[fl,j]=s[i] then begin
          ZeroMemory(@ac,SizeOf(ac));
          for k:=low(a[false]) to high(a[false]) do ac[a[fl,k]]:=a[not fl,k];
          for k:=1 to l do begin
            c:=ac[result[k]];
            if c<>#0 then result[k]:=c;
          end;
          goto lend;
        end;
lend:
  DelStack;
end;

procedure TrnsLitCngInit;
type TArrTrns = array[1..2] of string;
  procedure aTrnsLit(const a: array of TArrTrns; n: byte);
  var i: longint;
  begin
    AddStack('My_pr.aTrnsLit');
    for i:=low(a) to high(a) do begin
      aTrnsLitCng[n,a[i,1][1]]:=a[i,2]; aTrnsLitCng[n,LowCase(a[i,1][1])]:=AnsiLowerCase(a[i,2]);
    end;
    DelStack;
  end;
const
  aTrnsLitLR: array[1..26] of TArrTrns =
    (('A','А')
    ,('B','Б')
    ,('C','')
    ,('D','Д')
    ,('E','Е')
    ,('F','Ф')
    ,('G','Г')
    ,('H','Х')
    ,('I','И')
    ,('J','Й')
    ,('K','К')
    ,('L','Л')
    ,('M','М')
    ,('N','Н')
    ,('O','О')
    ,('P','П')
    ,('Q','')
    ,('R','Р')
    ,('S','')
    ,('T','Т')
    ,('U','У')
    ,('V','В')
    ,('W','В')
    ,('X','')
    ,('Y','')
    ,('Z','')
    );
  aTrnsLitRL: array[1..33] of TArrTrns =
    (('А','A')
    ,('Б','B')
    ,('В','V')
    ,('Г','G')
    ,('Д','D')
    ,('Е','E')
    ,('Ё','E')
    ,('Ж','ZH')
    ,('З','Z')
    ,('И','I')
    ,('Й','Y')
    ,('К','K')
    ,('Л','L')
    ,('М','M')
    ,('Н','N')
    ,('О','O')
    ,('П','P')
    ,('Р','R')
    ,('С','S')
    ,('Т','T')
    ,('У','U')
    ,('Ф','F')
    ,('Х','H')
    ,('Ц','C')
    ,('Ч','CH')
    ,('Ш','SH')
    ,('Щ','SH')
    ,('Ъ','')
    ,('Ы','Y')
    ,('Ь','')
    ,('Э','E')
    ,('Ю','YU')
    ,('Я','YA')
    );
var i: longint;
  c: char;
begin
  AddStack('My_pr.TrnsLitCngInit');
  New(aTrnsLitCng);
  for i:=low(aTrnsLitCng^) to high(aTrnsLitCng^) do
	  for c:=low(aTrnsLitCng[i]) to high(aTrnsLitCng[i]) do aTrnsLitCng[i,c]:=c;
  aTrnsLit(aTrnsLitRL,1); aTrnsLit(aTrnsLitLR,2); aTrnsLit(aTrnsLitRL,3); aTrnsLit(aTrnsLitLR,3);
  DelStack;
end;

function TransLiteration;
var j,l: longint;
	procedure cAdd(const s: string);
  var l1,l2: byte;
  begin
    AddStack('My_pr.TransLiteration.cAdd');
    l1:=Length(s); l2:=j+l1;
    if l2>l then begin
    	l:=l2; SetLength(result,l);
    end;
    for l2:=1 to l1 do begin
    	Inc(j); result[j]:=s[l2];
    end;
    DelStack;
  end;
var c,cnext: char;
	k: longint;
  function cNo(cu,cdef: char; const a1,a2: array of char): boolean;
  var cl: char;
  	i: byte;
  begin
    AddStack('My_pr.TransLiteration.cNo');
    cl:=LowCase(cu); result:=not(c in [cu,cl]);
    if not result then begin
    	for i:=low(a1) to high(a1) do
      	if cnext in [a1[i],LowCase(a1[i])] then begin
        	cdef:=a2[i]; Inc(k); break;
        end;
      if c=cl then LowCaseSelf(cdef);
      cAdd(cdef);
    end;
    DelStack;
  end;
var n: byte;
  l1: longint;
  s1: string;
begin
  AddStack('My_pr.TransLiteration');
  n:=IfThen(true in stRus,1)+IfThen(false in stRus,2);
  if n=0 then result:=s
  else begin
    l:=Length(s); SetLength(result,l); j:=0; l1:=l; k:=1;
    if not Assigned(aTrnsLitCng) then TrnsLitCngInit;
    while k<=l1 do begin
      c:=s[k]; s1:=aTrnsLitCng[n,c]; cnext:=' ';
      if k<l then cnext:=s[k+1];
      if s1<>'' then cAdd(s1)
      else begin
        if cNo('C','Ц',['H','Z'],['Ч','Ч']) then
        if cNo('S','С',['H'],['Ш']) then
        if cNo('Y','Ы',['A','U'],['Я','Ю']) then
        if cNo('Z','З',['H'],['Ж']) then
      end;
      Inc(k);
    end;
    SetLength(result,j);
  end;
  DelStack;
end;

procedure TransLitSelf(var s: string; stRus: TBoolSet);
begin
  s:=TransLiteration(s,stRus);
end;

procedure TransLitSelf(ls: TStrings; i: longint; stRus: TBoolSet);
begin
  ls[i]:=TransLiteration(ls[i],stRus);
end;

function SpaceCapt(const s: string): string;
begin
  AddStack('My_pr.SpaceCapt');
  result:=Trim(s); result:=IfThen(result<>'',' '+result+' ');
  DelStack;
end;

function SpaceCapt(const a: array of string; l: longint = NegDef): string;
begin
  AddStack('My_pr.SpaceCapt(a)');
  result:='';
  for l:=0 to ReplNeg(l,a)-1 do IncD(result,SpaceCapt(a[l])+UnDelim);
  DecLen(result,lUnDelim);
  DelStack;
end;

procedure SpaceCaptSelf(var s: string);
begin
  s:=SpaceCapt(s);
end;

procedure SpaceCaptSelf(var s: variant);
begin
  s:=SpaceCapt(s);
end;

function StrNum;
var i: Int64;
begin
  if l=0 then begin
    i:=n; result:=IntToStr(i);
  end
  else result:=NumStr(n,l);
  IncL(result,Capt);
end;

procedure StrNumSelf;
begin
  Capt:=StrNum(Capt,n,l);
end;

function LenIntStr;
begin
  result:=Length(IntToStr(Value));
end;

function BracketInt;
begin
  AddStack('My_pr.BracketInt');
  result:=Capt+StrNum(' (',n,l)+')';
  DelStack;
end;

procedure BracketIntSelf;
begin
  Capt:=BracketInt(Capt,n,l);
end;

procedure UnicodeInit;
var i: byte;
  procedure Set1(w: Word);
  begin
    AddStack('My_pr.UnicodeInit.Set1');
    aUnicode[Chr(i)]:=w; lsUnicode.Add(w,i);
    DelStack;
  end;
const a: array[128..191] of Word =
  ($0402,$0403,$201A,$0453,$201E,$2026,$2020,$2021
  ,$20AC,$2030,$0409,$2039,$040A,$040C,$040B,$040F
  ,$0452,$2018,$2019,$201C,$201D,$2022,$2013,$2014
  ,$0098,$2122,$0459,$203A,$045A,$045C,$045B,$045F
  ,$00A0,$040E,$045E,$0408,$00A4,$0490,$00A6,$00A7
  ,$0401,$00A9,$0404,$00AB,$00AC,$00AD,$00AE,$0407
  ,$00B0,$00B1,$0406,$0456,$0491,$00B5,$00B6,$00B7
  ,$0451,$2116,$0454,$00BB,$0458,$0405,$0455,$0457
  );
begin
  AddStack('My_pr.UnicodeInit');
  if not Assigned(aUnicode) then begin
    New(aUnicode); lsUnicode:=TIntegerList.Create([ilsUnSigned]);
    for i:=0 to 127 do Set1(i);
    for i:=low(a) to high(a) do Set1(a[i]);
    for i:=192 to 255 do Set1($0350+i); // А-я
    lsUnicode.SetOption(ilsSorted,true);
  end;
  DelStack;
end;

function UnicodeSize;
var i,l: longint;
begin
  AddStack('My_pr.UnicodeSize');
  UnicodeInit; l:=Length(s); result:=1;
  for i:=1 to l do
    if HiByte(aUnicode[s[i]])<>0 then begin
      result:=2; break;
    end;
  DelStack;
end;

type
  TUCRec = record
    case boolean of
      false: (w: Word);
      true: (s: array[1..2] of char);
  end;

function WinToUnicode;
var i,l,n: longint;
  j: TUnicodeSize;
  sr: TUCRec;
begin
  AddStack('My_pr.WinToUnicode');
  UnicodeInit; l:=Length(s); SetLength(result,l*Size); n:=0;
  for i:=1 to l do begin
    sr.w:=aUnicode[s[i]];
    for j:=1 to Size do begin
      Inc(n); result[n]:=sr.s[j];
    end;
  end;
  DelStack;
end;

function UnicodeToWin;
var i,j,l,n: longint;
  sr: TUCRec;
begin
  AddStack('My_pr.UnicodeToWin');
  UnicodeInit; l := Length(s) div 2; SetLength(result,l); n:=0;
  for i:=1 to l do begin
    for j:=1 to 2 do begin
      Inc(n); sr.s[j]:=s[n];
    end;
    if lsUnicode.IntObjFind(sr.w,j) then result[i]:=Chr(j) else result[i]:=sr.s[1];
  end;
  DelStack;
end;

function Utf16ToWin;
var i,j,l,n: longint;
  sr: TUCRec;
begin
  AddStack('My_pr.Utf16ToWin');
  UnicodeInit; l := Length(s) div 2; SetLength(result,l); n:=0;
  for i:=1 to l do begin
    for j:=1 to 2 do begin
      Inc(n); sr.s[j]:=s[n];
    end;
    if lsUnicode.IntObjFind(sr.w,j) then result[i]:=Chr(j) else result[i]:=sr.s[1];
  end;
  DelStack;
end;

const cNumWin='№'; cNumUtf8=#$E2#$84#$96; lUtf8=3;

function WinToUtf8;
var i,l,lr: longint;
  n: byte;
begin
  AddStack('My_pr.WinToUtf8');
  UnicodeInit; l:=Length(s); SetLength(result,l*lUtf8); lr:=0;
  for i:=1 to l do begin
    if s[i]=cNumWin then for n:=1 to lUtf8 do begin
      Inc(lr); result[lr]:=cNumUtf8[n];
    end
    else begin
      Inc(lr);
      if s[i]<#$80 then result[lr]:=s[i]
      else begin
        result[lr] := Chr($C0 or (aUnicode[s[i]] shr 6)); Inc(lr);
        result[lr] := Chr($80 or (aUnicode[s[i]] and $3F));
      end;
    end;
  end;
  SetLength(result,lr);
  DelStack;
end;

function Utf8ToWin;
var i,j,l,lr: longint;
begin
  AddStack('My_pr.Utf8ToWin');
  SetPBoolean(IsUtf8,false); UnicodeInit; l:=Length(s); SetLength(result,l); lr:=0; i:=0;
  while i<l do begin
    Inc(i); Inc(lr);
    if Copy(s,i,lUtf8)=cNumUtf8 then begin
      SetPBoolean(IsUtf8,true); result[lr]:=cNumWin; Inc(i,lUtf8-1);
    end
    else if s[i]<#$80 then result[lr]:=s[i]
    else begin
      j := Ord(s[i]) and $1F; Inc(i);
      if lsUnicode.IntObjFind((j shl 6) or (Ord(s[i]) and $3F),j) then begin
        SetPBoolean(IsUtf8,true); result[lr]:=Chr(j);
      end
      else result[lr]:=#0;
    end;
  end;
  SetLength(result,lr);
  DelStack;
end;

procedure Utf8ToWinSelf;
begin
  s:=Utf8ToWin(s);
end;

function NoZero(const Value: variant; const ZeroEmp: TFmtZeroEmp; psZero: PBoolean; var res: string): boolean;
begin
  AddStack('My_pr.NoZero');
  SetPBoolean(psZero); result:=not(empty(Value) and ZeroEmp.l);
	if not result then begin
    res:=Trim(ZeroEmp.s);
    if res='' then res:=' ' else SetPBoolean(psZero,true);
  end;
  DelStack;
end;

function FmtNum(Value: Extended; const Prm: TFmtNum; psZero: PBoolean = nil): string;
var ost,p,i,j: longint;
	fl: boolean;
  s: string;
begin
	ost:=AddStack('My_pr.FmtNum');
  try
    if NoZero(mround(Value,Prm.FracCnt),Prm.ZeroEmp,psZero,result) then begin
      result:=StrTran(FormatFloat('#0.'+StringOfChar('0',Prm.FracCnt),mround(Value,Prm.FracCnt)),DecimalSeparator,Prm.FracDlm);
      p:=PosEnd(Prm.FracDlm,result);
      if Prm.FracEmp<>frempYes then begin
        fl:=true;
        for i:=Length(result) downto p+1 do
          if result[i]<>'0' then begin
            case Prm.FracEmp of
              frempNo: fl:=false;
              frempNoRight0: p:=i+1;
            end;
            break;
          end;
        if fl then FillMemory(PointerStr(result,p-1),Length(result)-p+1,Ord(' '));
      end;
      if Prm.DigIsDlm then begin
        s:=Copy(result,p,MaxInt); j:=0;
        for i:=p-1 downto 1 do begin
          if j=3 then begin
            IncL(s,Prm.DigDlm); j:=0;
          end;
          IncL(s,result[i]); Inc(j);
        end;
        result:=s;
      end;
    end;
    if Prm.AllCnt<>0 then begin
      TrimLeftSelf(result);
      i:=Prm.AllCnt; //+IfThen(Prm.DigIsDlm,(Prm.AllCnt-IfThen(Prm.FracCnt>0,Prm.FracCnt+1)-1) div 3);
      if Length(result)>i then result:=StringOfChar('*',i) else PadLSelf(result,i);
    end;
  except
    SetStack(ost);
    result:='';
  end;
  DelStack;
end;

procedure FmtNumSelf;
begin
  Value:=FmtNum(Value,Prm,psZero);
end;

function FmtDate(Value: TDateTime; const Prm: TFmtDate; psZero: PBoolean = nil): string;
begin
	AddStack('My_pr.FmtDate');
  ReplDateBigEmptySelf(Value);
	if NoZero(Value,Prm.ZeroEmp,psZero,result) then begin
    result:=StrTran(dtoc(Value,'',Prm.NYear=4),DateSeparator,Prm.Dlm);
    if Prm.MMYY then Delete(result,1,3);
  end;
  DelStack;
end;

function FmtNum: TFmtNum;
begin
  AddStack('My_pr.FmtNum(def)');
  Finalize(result); ZeroMemory(@result,SizeOf(result));
  with result do begin
    FracDlm:='.'; FracCnt:=2; DigDlm:=ThousandSeparator;
  end;
  DelStack;
end;

function FmtDate: TFmtDate;
begin
  AddStack('My_pr.FmtDate(def)');
  Finalize(result); ZeroMemory(@result,SizeOf(result));
  with result do begin
    Dlm:=DateSeparator; NYear:=2;
  end;
  DelStack;
end;

function GFFmtStr;
begin
  AddStack('My_pr.GFFmtStr');
  result:=true; EnsureSelf(nParam,low(Params.Arr),high(Params.Arr));
  case MyVarType(Value,true) of
    V_FLOAT: FmtNumSelf(Value,Params.Arr[nParam].PrmNum,psZero);
    V_DATE: Value:=FmtDate(Value,Params.Arr[nParam].PrmDate,psZero);
    V_STRING:
  else result:=false;
  end;
  DelStack;
end;

function IsArr(const av: variant; var i,h: longint): boolean;
begin
  AddStack('My_pr.IsArr');
  result := MyVarType(av)=varArray;
  if result then begin
    i:=VarArrayLowBound(av,1); h:=VarArrayHighBound(av,1);
  end;
  DelStack;
end;

function Zn1(const av: variant; var i: longint; h: longint; const Def: variant): variant;
begin
  AddStack('My_pr.Zn1');
  result:=Def;
  if i<=h then if not IsNil(av[i]) then result:=av[i];
  Inc(i);
  DelStack;
end;

procedure FmtNum(var Prm: TFmtNum; const av: variant);
var i,h: longint;
begin
  AddStack('My_pr.FmtNum(var)');
  if IsArr(av,i,h) then with Prm do begin
    FracDlm:=StrToChar(Zn1(av,i,h,FracDlm));    // 1
    AllCnt:=Zn1(av,i,h,AllCnt);                 // 2
    FracCnt:=Zn1(av,i,h,FracCnt);               // 3
    FracEmp:=Bool2FracEmp(Zn1(av,i,h,FracEmp)); // 4
    DigIsDlm:=Zn1(av,i,h,DigIsDlm);             // 5
    DigDlm:=StrToChar(Zn1(av,i,h,DigDlm));      // 6
    ZeroEmp.l:=Zn1(av,i,h,ZeroEmp.l);           // 7
    ZeroEmp.s:=Zn1(av,i,h,ZeroEmp.s);           // 8
  end;
  DelStack;
end;

procedure FmtDate(var Prm: TFmtDate; const av: variant);
var i,h: longint;
begin
  AddStack('My_pr.FmtDate(var)');
  if IsArr(av,i,h) then with Prm do begin
    Dlm:=StrToChar(Zn1(av,i,h,Dlm));         // 1
    NYear:=Zn1(av,i,h,NYear);                // 2
    ZeroEmp.l:=Zn1(av,i,h,ZeroEmp.l);        // 3
    ZeroEmp.s:=Zn1(av,i,h,ZeroEmp.s);        // 4
    MMYY:=Zn1(av,i,h,MMYY);                  // 5
  end;
  DelStack;
end;

function IntToCharNum;
var la: longword;
begin
  AddStack('My_pr.IntToCharNum');
  la:=Length(a); result:='';
  while n>0 do IncL(result,a[ModDiv(n,la)]);
  if l>0 then PadLSelf(result,l,a[low(a)]);
  DelStack;
end;

function SubStr;
begin
  AddStack('My_pr.SubStr');
  if SubPrmNeg(Index,Count,Length(s),true) then result:=Copy(s,Index,Count) else result:='';
  DelStack;
end;

procedure SubStrSelf(var s: string; Index: longint = 1; Count: longint = MaxInt);
begin
  s:=SubStr(s,Index,Count);
end;

procedure SubStrSelf(var s: variant; Index: longint = 1; Count: longint = MaxInt);
begin
  s:=SubStr(s,Index,Count);
end;

procedure SubStrSelf(var s: TFileName; Index: longint = 1; Count: longint = MaxInt);
begin
  s:=SubStr(s,Index,Count);
end;

function LeftStrDel;
begin
  AddStack('My_pr.LeftStrDel');
  result:=s; LeftSelfDel(result,sDel);
  DelStack;
end;

function LeftSelfDel;
var l: longint;
begin
  AddStack('My_pr.LeftSelfDel');
  l:=Length(sDel); result := LeftStr(s,l)=sDel;
  if result then Delete(s,1,l);
  DelStack;
end;

function RightStrDel;
begin
  AddStack('My_pr.RightStrDel');
  result:=s; RightSelfDel(result,sDel);
  DelStack;
end;

function RightSelfDel;
var l: longint;
begin
  AddStack('My_pr.RightSelfDel');
  l:=Length(sDel); result := RightStr(s,l)=sDel;
  if result then DecLen(s,l);
  DelStack;
end;

function AnsiStartsArr(const ASubText: array of string; const AText: string): boolean;
var i: longint;
begin
  result:=AnsiStartsArr(ASubText,AText,i);
end;

function AnsiStartsArr(const ASubText: array of string; const AText: string; var i: longint): boolean;
var h: longint;
begin
  AddStack('My_pr.AnsiStartsArr');
  result:=false; i:=low(ASubText); h:=high(ASubText);
  while i<=h do if AnsiStartsStr(ASubText[i],AText) then begin
    result:=true; break;
  end
  else Inc(i);
  DelStack;
end;

function FindStartsStrList(ls: TStringList; const sbeg: string): boolean;
var i: longint;
begin
  result:=FindStartsStrList(ls,sbeg,i);
end;

function FindStartsStrList(ls: TStringList; const sbeg: string; var i: longint): boolean;
begin
  AddStack('My_pr.FindStartsStrList');
  ls.Find(sbeg,i);
  if i<ls.Count then result:=AnsiStartsText(sbeg,ls[i]) else result:=false;
  DelStack;
end;

function InStrList;
begin
  AddStack('My_pr.InStrList');
  if Assigned(ls) then result := ls.IndexOf(s)>=0 else result:=IfLsNil;
  DelStack;
end;

function AtPartToStr;
begin
  AddStack('My_pr.AtPartToStr');
  result:=AtPart;
  if result<>'' then IncL(result,cPart,cAtPartEnd);
  DelStack;
end;

function StrToAtPart;
begin
  AddStack('My_pr.StrToAtPart');
  result:=s; StrToAtPartSelf(result,AtPart,cPart);
  DelStack;
end;

function StrToAtPartSelf;
var i,j,l: longint;
begin
  AddStack('My_pr.StrToAtPartSelf');
  result:=IsPos(i,cPart,s);
  if result then begin
    l:=Length(cPart); AtPart:=Copy(s,i+l,MaxInt);
    if IsPos(j,cAtPartEnd,AtPart) then SetLength(AtPart,j-1);
    StuffStrSelf(s,i,Length(AtPart)+l+IfThen(j>0,1),'');
  end
  else AtPart:='';
  DelStack;
end;

function AnsiFindText(const AText: string; const AValues: array of string; LowLim: longint;
  var Index: longint): boolean;
begin
  AddStack('My_pr.AnsiFindText');
  Index:=AnsiIndexText(AText,AValues); result := Index>=0; Inc(Index,LowLim);
  DelStack;
end;

function AnsiFindText(const AText: string; const AValues: array of string; var Index: longint): boolean;
begin
  result:=AnsiFindText(AText,AValues,0,Index);
end;

function AnsiFindChar(const AText: string; const AValues: array of char; LowLim: longint;
  var Index: longint): boolean;
var h: longint;
begin
  AddStack('My_pr.AnsiFindChar');
  Index:=low(AValues); h:=high(AValues); result:=false;
  while Index<=h do
    if AValues[Index]=AText then begin
      Inc(Index,LowLim); result:=true; break;
    end
    else Inc(Index);
  DelStack;
end;

function AnsiFindChar(const AText: string; const AValues: array of char; var Index: longint): boolean;
begin
  result:=AnsiFindChar(AText,AValues,0,Index);
end;

function AnsiFindChar(const AText: string; const AValues: array of char): boolean; overload;
var Index: longint;
begin
  result:=AnsiFindChar(AText,AValues,Index);
end;

function TrnsABC;
var k: longint;
  sk: string;
begin
  AddStack('My_pr.TrnsABC');
  result:=s; k:=1;
  while k<=Length(result) do
    case result[k] of
      ' '..'}','Ё','«','ё','№','»','А'..'я': Inc(k);
      #160: result[k]:=' ';
    else
      sk:=Format('<%d>',[Ord(result[k])]); StuffStrSelf(result,k,1,sk); Inc(k,Length(sk));
    end;
  DelStack;
end;

function StrCount(const SubStr,S: string): longint;
var p,l: longint;
begin
  AddStack('My_pr.StrCount');
  result:=0; p:=1; l:=Length(SubStr);
  repeat
    if not IsPos(p,SubStr,S,p) then break;
    Inc(result); Inc(p,l);
  until false;
  DelStack;
end;

function StrCount(SubStr: char; const S: string): longint;
var i: longint;
begin
  AddStack('My_pr.StrCount(char)');
  result:=0;
  for i:=1 to Length(S) do if S[i]=SubStr then Inc(result);
  DelStack;
end;

function StrCount(const S: string): longint;
begin
  if S='' then result:=0 else result:=StrCount(CRLF,S)+1;
end;

procedure bStrSelf;
begin
  v:=Bool2Str(v);
end;

function Bool2Str(Value: boolean): string;
begin
  result:=bStr[Value];
end;

function Bool2Str(Value: pointer): char;
begin
  result:=bStr[boolean(Value)];
end;

function Bool2Str(Sender: TStringGrid; ACol,ARow: longint): string;
begin
  result:=Bool2Str(Sender.Objects[ACol,ARow]);
end;

function bRus2Str;
begin
  result:=bRus[Value];
end;

function IsPos;
begin
  Index:=PosEx(Substr,S,Offset); result := Index>0;
end;

function PosEnd;
begin
  if not IsPos(result,Substr,S,Offset) then result:=Length(S)+1;
end;

function ExtractLeftPart;
begin
  AddStack('My_pr.ExtractLeftPart');
  Dec(p); result:=LeftStr(s,p); Delete(s,1,p+Length(Dlm));
  DelStack;
end;

function StrDivDlm(const Substr,S: string; n: TNamePrimList = 1): TNamePrimStr;
begin
  AddStack('My_pr.StrDivDlm(def)');
  if not StrDivDlm(Substr,S,result) then begin
    result[n]:=s; result[3-n]:='';
  end;
  DelStack;
end;

function StrDivDlm(const Substr,S: string; var a: TNamePrimStr; IgnoreCase: boolean = false): boolean;
var p: longint;
begin
  AddStack('My_pr.StrDivDlm');
  result:=IsPos(p,Substr,S);
  if not result and IgnoreCase then result:=IsPos(p,AnsiUpperCase(Substr),AnsiUpperCase(S));
  if result then a:=NamePrimStr(LeftStr(s,p-1),Copy(s,p+Length(Substr),MaxInt));
  DelStack;
end;

procedure StrDivDlm(const Substr: string; var a: TNamePrimStr);
begin
  a:=StrDivDlm(Substr,a[2]);
end;

procedure LeftSubStrSelf;
begin
  S:=StrDivDlm(Substr,S)[1];
end;

function ArrStrComp;
var i: longint;
begin
  AddStack('My_pr.ArrStrComp');
  i:=Length(a1); result := i=Length(a2);
  if result then for i:=0 to i-1 do if a1[i]<>a2[i] then begin
    result:=false; break;
  end;
  DelStack;
end;

function InRange(const AValue, AMin, AMax: string): Boolean; 
begin
  Result := (AValue >= AMin) and (AValue <= AMax);
end;

function InRange(const AValue: string; const AMinMax: TArrBoolStr): Boolean;
begin
  Result := InRange(AValue,AMinMax[false],AMinMax[true]);
end;

function InRange(AValue: TDateTime; const AMinMax: TArrBoolDate): Boolean;
begin
  Result := InRange(AValue,AMinMax[false],AMinMax[true]);
end;

function BrackNoEmp;
begin
  AddStack('My_pr.BrackNoEmp');
  result:=IfThen(s<>'',dLeft+s+dRight);
  DelStack;
end;

procedure BrackNoEmpSelf;
begin
  s:=BrackNoEmp(s,dLeft,dRight);
end;

function BracketNot;
begin
  AddStack('My_pr.BracketNot');
  result:=BrackNoEmp(w,IfThen(lnot,sNOT)+'(');
  DelStack;
end;

function NamePrimStr;
begin
  result[1]:=name; result[2]:=prim;
end;

function ArrBoolStr;
begin
  result[Inv]:=sFalse; result[not Inv]:=sTrue;
end;

function ArrBoolInt;
begin
  result[Inv]:=sFalse; result[not Inv]:=sTrue;
end;

function ArrBoolDbl;
begin
  result[Inv]:=sFalse; result[not Inv]:=sTrue;
end;

function ArrBoolDate;
begin
  result[Inv]:=sFalse; result[not Inv]:=sTrue;
end;

function ArrBoolVar;
begin
  result[Inv]:=sFalse; result[not Inv]:=sTrue;
end;

function ArrBoolField;
begin
  result[Inv]:=sFalse; result[not Inv]:=sTrue;
end;

procedure DelTrailingChar;
var k: longint;
begin
  k:=length(s);
  while (k>0)and(s[k]=c) do dec(k);
  SetLength(s,k);
end;

procedure DelLeadingChar;
var k,j: longint;
begin
  j:=1; k:=length(s);
  while (j<=k)and(s[j]=c) do inc(j);
  Delete(s,1,j-1);
end;

function GetSex(const sex: string): TSexList;
begin
  AddStack('My_pr.GetSex');
  result:=TSexList(max(AnsiIndexText(sex,aSex),0)+1);
  DelStack;
end;

type
  PPartsFIO = ^TPartsFIO;
  TPartsFIO = record
    pLastName, pFirstName, pMiddleName : PChar;
    nLastName, nFirstName, nMiddleName : LongInt;
  end;

  TPadegProc = function(pLastName,pFirstName,pMiddleName: PChar; bSex: Boolean;
    nPadeg: LongInt; pResult: PChar; var nLen: LongInt): LongInt;

var PadegDllHandle : HMODULE;
  GetFIOPadeg: function(pLastName,pFirstName,pMiddleName: PChar; bSex: Boolean;
    nPadeg: LongInt; pResult: PChar; var nLen: LongInt): LongInt; stdcall;
  GetFIOPadegAS: function(pLastName,pFirstName,pMiddleName: PChar;
    nPadeg: LongInt; pResult: PChar; var nLen: LongInt): LongInt; stdcall;
  GetFIOPadegFS: function(pFIO: PChar; bSex: Boolean;
    nPadeg: LongInt; pResult: PChar; var nLen: LongInt): LongInt; stdcall;
  GetFIOPadegFSAS: function(pFIO: PChar;
    nPadeg: LongInt; pResult: PChar; var nLen: LongInt): LongInt; stdcall;
  GetOfficePadeg: function(pOffice: PChar;
    nPadeg: LongInt; pResult: PChar; var nLen: LongInt): LongInt; stdcall;
  GetAppointmentPadeg: function(pAppointment: PChar;
    nPadeg: LongInt; pResult: PChar; var nLen: LongInt): LongInt; stdcall;
  GetFIOParts: function(pFIO: PChar; Parts: PPartsFIO): LongInt; stdcall;

procedure LoadPadeg;
begin
  AddStack('My_pr.LoadPadeg');
  if PadegDllHandle=0 then begin
    PadegDllHandle:=LoadLibrary('Padeg.dll');
    if PadegDllHandle=0 then raise Exception.Create(
      'Не найдена динамическая библиотека Padeg.dll.'+CRLF+'Функции склонения недоступны.');
    @GetFIOPadeg        :=GetProcAddress(PadegDllHandle,'GetFIOPadeg');
    @GetFIOPadegAS      :=GetProcAddress(PadegDllHandle,'GetFIOPadegAS');
    @GetFIOPadegFS      :=GetProcAddress(PadegDllHandle,'GetFIOPadegFS');
    @GetFIOPadegFSAS    :=GetProcAddress(PadegDllHandle,'GetFIOPadegFSAS');
    @GetOfficePadeg     :=GetProcAddress(PadegDllHandle,'GetOfficePadeg');
    @GetAppointmentPadeg:=GetProcAddress(PadegDllHandle,'GetAppointmentPadeg');
    @GetFIOParts        :=GetProcAddress(PadegDllHandle,'GetFIOParts');
  end;
  DelStack;
end;

procedure PartsFIO;
var lmax: longint;
  Parts: TPartsFIO;
begin
  AddStack('My_pr.PartsFIO');
  LoadPadeg; lmax:=Length(Value);
  with Parts do begin
    pLastName:=StrAlloc(lmax); pFirstName:=StrAlloc(lmax); pMiddleName:=StrAlloc(lmax);
    try
      nLastName:=lmax; nFirstName:=lmax; nMiddleName:=lmax;
      if GetFIOParts(PChar(Value),@Parts)=0 then begin
        Famil:=LeftStr(pLastName  ,nLastName  );
        Name1:=LeftStr(pFirstName ,nFirstName );
        Name2:=LeftStr(pMiddleName,nMiddleName);
      end;
    finally
      StrDispose(pLastName); StrDispose(pFirstName); StrDispose(pMiddleName);
    end;
  end;
  DelStack;
end;

function MakePadeg(Proc: TPadegProc; const Famil: string; Pdg: TPdgList; Sex: TSexList0 = sexAll; const Name1: string = ''; const Name2: string = ''): string;
var lmax,l,nLen: longint;
  pResult: PChar;
begin
  AddStack('My_pr.MakePadeg');
  LoadPadeg; result:=''; l:=Length(Famil)+Length(Name1)+Length(Name2)+2; lmax:=l shl 1;
  repeat
    Inc(l,10); pResult:=StrAlloc(l);
    try
      nLen:=l;
      case ShortInt(Proc(PChar(Famil),PChar(Name1),PChar(Name2),Sex=sexMan,Pdg,pResult,nLen)) of
        -3: continue;
        0: result:=LeftStr(pResult,nLen);
      end;
      break;
    finally
      StrDispose(pResult);
    end;
  until l>=lmax;
  DelStack;
end;

function IfThenPadeg(AValue: boolean; ATrue,AFalse: TPadegProc): TPadegProc;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function FFIOPadeg(pLastName,pFirstName,pMiddleName: PChar; bSex: Boolean;
  nPadeg: LongInt; pResult: PChar; var nLen: LongInt): LongInt;
begin
  result:=GetFIOPadeg(pLastName,pFirstName,pMiddleName,bSex,nPadeg,pResult,nLen);
end;

function FFIOPadegAS(pLastName,pFirstName,pMiddleName: PChar; bSex: Boolean;
  nPadeg: LongInt; pResult: PChar; var nLen: LongInt): LongInt;
begin
  result:=GetFIOPadegAS(pLastName,pFirstName,pMiddleName,nPadeg,pResult,nLen);
end;

function PadegFIO(const Famil,Name1,Name2: string; Pdg: TPdgList; Sex: TSexList0 = sexAll): string;
begin
  AddStack('My_pr.PadegFIO(f,i,o)');
  result:=MakePadeg(IfThenPadeg(Sex=sexAll,FFIOPadegAS,FFIOPadeg),Famil,Pdg,Sex,Name1,Name2);
  DelStack;
end;

function FFIOPadegFS(pLastName,pFirstName,pMiddleName: PChar; bSex: Boolean;
  nPadeg: LongInt; pResult: PChar; var nLen: LongInt): LongInt;
begin
  result:=GetFIOPadegFS(pLastName,bSex,nPadeg,pResult,nLen);
end;

function FFIOPadegFSAS(pLastName,pFirstName,pMiddleName: PChar; bSex: Boolean;
  nPadeg: LongInt; pResult: PChar; var nLen: LongInt): LongInt;
begin
  result:=GetFIOPadegFSAS(pLastName,nPadeg,pResult,nLen);
end;

function PadegFIO(const Value: string; Pdg: TPdgList; Sex: TSexList0 = sexAll): string;
begin
  AddStack('My_pr.PadegFIO');
  result:=MakePadeg(IfThenPadeg(Sex=sexAll,FFIOPadegFSAS,FFIOPadegFS),Value,Pdg,Sex);
  DelStack;
end;

function FOfficePadeg(pLastName,pFirstName,pMiddleName: PChar; bSex: Boolean;
  nPadeg: LongInt; pResult: PChar; var nLen: LongInt): LongInt;
begin
  result:=GetOfficePadeg(pLastName,nPadeg,pResult,nLen);
end;

function PadegPodr;
begin
  AddStack('My_pr.PadegPodr');
  result:=MakePadeg(FOfficePadeg,Value,Pdg);
  DelStack;
end;

function FAppointmentPadeg(pLastName,pFirstName,pMiddleName: PChar; bSex: Boolean;
  nPadeg: LongInt; pResult: PChar; var nLen: LongInt): LongInt;
begin
  result:=GetAppointmentPadeg(pLastName,nPadeg,pResult,nLen);
end;

function PadegDolg;
begin
  AddStack('My_pr.PadegDolg');
  result:=MakePadeg(FAppointmentPadeg,Value,Pdg);
  DelStack;
end;

function HashStr;
var k: longint;
begin
  result:=0;
  for k:=1 to length(s) do begin
    result:=((result shl 2) or (result shr (SizeOf(result)*8 - 2))) xor ord(s[k]);
  end;
end;

function SetEpoch;
begin
	AddStack('My_pr.SetEpoch');
	result:=BegEpoch;
  if y<10000 then begin
  	BegEpoch:=y; EpchAge := y div 100; EpchYear:=y-EpchAge*100;
  end;
  DelStack;
end;

function DateSmall;
begin
	AddStack('My_pr.DateSmall');
	result:=EncodeDateTry(BegEpoch,1,1);
  DelStack;
end;

function DateBigOld;
var y: Word;
begin
	AddStack('My_pr.DateBigOld');
  if not Assigned(FDateBigOld) then begin
    if EpchYear=0 then y:=EpchAge*100+99 else y:=(EpchAge+1)*100+EpchYear-1;
    New(FDateBigOld);
    FDateBigOld[0]:=ArrBoolDate(EncodeDateTry(y,MonthsPerYear,31),DateBig);
    {
    FDateBigOld[1]:=ArrBoolDate(bom(FDateBigOld[0,false])        ,bom(FDateBigOld[0,true]));
    FDateBigOld[2]:=ArrBoolDate(boy(FDateBigOld[0,false])        ,boy(FDateBigOld[0,true]));
    }
  end;
  result:=FDateBigOld^;
  DelStack;
end;

function ctod;
var a: array[0..2] of string;
  s,se: string;
  fl: boolean;
begin
	AddStack('My_pr.ctod');
  s:=st; listasarray(s,a,DateSeparator); TrimSelf(a[2]);
  fl:=true;
  if InRange(length(a[2]),1,2) then begin
    if lEpoch then begin
      se:=NumStr(EpchAge+IfThen(Int0(a[2])<EpchYear,1),2); ProtAdd('СТРОКА_ДАТА("'+st+'")');
    end
    else se:='20';
    IncL(a[2],se);
  end
  else if Int0(a[2])=0 then a[2]:=''
  else fl:=false;
  if fl then s:=ArrayAsList(a,DateSeparator);
  result:=StrToDateDef(s,DateEmpty);
  DelStack;
end;

procedure ctodSelf;
begin
  v:=ctod(v,lEpoch,ProtAdd);
end;

function dtoc;
begin
	AddStack('My_pr.dtoc');
	result:=IfThen(cDlm='','/',cDlm);
	result:=OurFormatDateTime('dd'+result+'mm'+result+IfThen(lFull,'yyyy','yy'),dt);
  DelStack;
end;

procedure dtocSelf;
begin
  v:=dtoc(v,cDlm,lFull);
end;

function Year;
var n: Word;
begin
	AddStack('My_pr.Year');
  DecodeDateTry(dt,result,n,n); 
  DelStack;
end;

function Month;
var n: Word;
begin
	AddStack('My_pr.Month');
	DecodeDateTry(dt,n,result,n);
  DelStack;
end;

function Day;
var n: Word;
begin
	AddStack('My_pr.Day');
	DecodeDateTry(dt,n,n,result);
  DelStack;
end;

function SetMonthName;
const MonthNames: array[1..6,TMonth] of string[15] =
  (('январь' ,'февраль' ,'март'  ,'апрель' ,'май' ,'июнь' ,'июль' ,'август'  ,'сентябрь' ,'октябрь' ,'ноябрь' ,'декабрь')
  ,('января' ,'февраля' ,'марта' ,'апреля' ,'мая' ,'июня' ,'июля' ,'августа' ,'сентября' ,'октября' ,'ноября' ,'декабря')
  ,('январю' ,'февралю' ,'марту' ,'апрелю' ,'маю' ,'июню' ,'июлю' ,'августу' ,'сентябрю' ,'октябрю' ,'ноябрю' ,'декабрю')
  ,('январь' ,'февраль' ,'март'  ,'апрель' ,'май' ,'июнь' ,'июль' ,'август'  ,'сентябрь' ,'октябрь' ,'ноябрь' ,'декабрь')
  ,('январем','февралем','мартом','апрелем','маем','июнем','июлем','августом','сентябрем','октябрем','ноябрем','декабрем')
  ,('январе' ,'феврале' ,'марте' ,'апреле' ,'мае' ,'июне' ,'июле' ,'августе' ,'сентябре' ,'октябре' ,'ноябре' ,'декабре')
  );
var i: byte;
begin
	AddStack('My_pr.SetMonthName');
	result:=curMonthName;
  if n in [low(MonthNames)..high(MonthNames)] then begin
    MaxMonth:='';
    for i:=low(LongMonthNames) to high(LongMonthNames) do begin
      LongMonthNames[i]:=MonthNames[n,i];
      if Length(MaxMonth)<Length(LongMonthNames[i]) then MaxMonth:=LongMonthNames[i];
    end;
    curMonthName:=n;
  end;
  DelStack;
end;

function our_dtoc;
begin
	AddStack('My_pr.our_dtoc');
	if dt=DateEmpty then result:=''
  else result:=OurFormatDateTime(IfThen(Format='','d mmmm yyyy"г."',Format),dt);
  DelStack;
end;

function OurFormatDateTime;
const sM='mmmm'; lM=Length(sM);
var Fmt,s: string;
  i,n: longint;
  m: byte;
begin
  AddStack('My_pr.OurFormatDateTime');
  Fmt:=Format; m:=curMonthName; i:=1;
  repeat
    if not IsPos(i,sM,Fmt,i) then break;
    Inc(i,lM);
    if i>Length(Fmt) then break;
    if IsDigit(Fmt[i]) then begin
      n:=Int0(Copy(Fmt,i,MaxInt)); SetMonthName(n); Dec(i,lM); s:=FormatDateTime(sM,DateTime);
      StuffStrSelf(Fmt,i,lM+LenIntStr(n),s); Inc(i,Length(s));
    end;
  until false;
  i:=trunc(DateTime);
  if i=DateEmpty then StrTranSelf(Fmt,['dddd','ddd',sM,'mmm','d','m','y'],
    [Space(Length(LongDayNames[low(LongDayNames)]))
    ,Space(Length(ShortDayNames[low(ShortDayNames)]))
    ,Space(Length(LongMonthNames[low(LongMonthNames)]))
    ,Space(Length(ShortMonthNames[low(ShortMonthNames)]))
    ,' ',' ',' ']);
  if i=DateTime then StrTranSelf(Fmt,['h','n','s','z'],[' ',' ',' ',' ']);
  SetMonthName(m); result:=FormatDateTime(Fmt,DateTime);
  DelStack;
end;

function our_mtoc;
var m: longint;
  dt: TDateTime;
begin
	AddStack('My_pr.our_mtoc');
	m:=SetMonthName(nName);
  case MyVarType(d) of
    varInteger: begin
      dt:=Stod(StrNum('2000',d,2)+'01'); OnlyMes:=true;
    end;
    varDate: dt:=d;
  else dt:=DateEmpty;
  end;
	if dt=DateEmpty then result:=''
	else result:=FormatDateTime('mmmm'+IfThen(not OnlyMes,' yyyy"г."'),dt);
	SetMonthName(m);
  DelStack;
end;

function perntomes;
var d,m1,m2,y1,y2: Word;
begin
	AddStack('My_pr.perntomes');
  ReplDateBigEmptySelf(d2);
  if empty(d1) and empty(d2) then result:=''
  else begin
    DecodeDateTry(d1,y1,m1,d); DecodeDateTry(d2,y2,m2,d);
    if (m1=m2) and (y1=y2) then result:=our_mtoc(d1)
    else result:= 'период '+DlmBetween(
      IfThen(not empty(d1),'с '+OurFormatDateTime('mmmm'+IfThen((y1<>y2) or empty(d2),' yyyy"г."'),d1)),
      IfThen(not empty(d2),'по '+our_mtoc(d2)),' ');
    IncL(result,'за ');
  end;
  DelStack;
end;

// Строка "Дата прописью"/"Месяц прописью" - в дату
function our_ctodm(const s: string; fl: boolean): TDateTime;
var d: Word;
  m,sm: longint;
  a: TNamePrimStr;
label lend;
begin
	AddStack('My_pr.our_ctodm');
	result:=DateEmpty;
  if fl then begin
   	a[2]:=s; sm:=SetMonthName(1); d:=1;
  end
  else begin
   	if not StrDivDlm(' ',s,a) then goto lend;
   	sm:=0; d:=Int0(s);
  end;
  if not StrDivDlm(' ',a[2],a) then goto lend;
  if not AnsiFindText(a[1],LongMonthNames,low(LongMonthNames),m) then goto lend;
  result:=EncodeDateTry(Int0(Trim(a[2])),m,d);
  if fl then SetMonthName(sm);
lend:
	DelStack;
end;

function our_ctod;
begin
	AddStack('My_pr.our_ctod');
	result:=our_ctodm(s,false);
  DelStack;
end;

function our_ctom;
begin
	AddStack('My_pr.our_ctom');
	result:=our_ctodm(s,true);
  DelStack;
end;

function boy;
begin
	AddStack('My_pr.boy');
	result:=EncodeDateTry(Year(dt),1,1);
  DelStack;
end;

procedure boySelf(var dt: TDateTime);
begin
  dt:=boy(dt);
end;

procedure boySelf(var dt: variant);
begin
  dt:=boy(dt);
end;

function eoy;
begin
	AddStack('My_pr.eoy');
  result:=EncodeDateTry(Year(dt),12,31);
  DelStack;
end;

procedure eoySelf(var dt: TDateTime);
begin
  dt:=eoy(dt);
end;

procedure eoySelf(var dt: variant);
begin
  dt:=eoy(dt);
end;

function boq;
var y,m,d: Word;
begin
  AddStack('My_pr.boq');
  if empty(dt) or (dt=DateBig) then result:=dt
  else begin
    DecodeDateTry(dt,y,m,d);
    while ((m-1) mod CntMonth) > 0 do Dec(m);
    result:=EncodeDateTry(y,m,1);
  end;
  DelStack;
end;

function eoq;
var y,m,d: Word;
begin
  AddStack('My_pr.eoq');
  if empty(dt) or (dt=DateBig) then result:=dt
  else begin
    DecodeDateTry(dt,y,m,d);
    while (m mod CntMonth) > 0 do Inc(m);
    result:=EncodeDateTry(y,m,1);
  end;
  DelStack;
end;

function bom;
var y,m,d: Word;
begin
  AddStack('My_pr.bom');
	DecodeDateTry(dt,y,m,d); result:=EncodeDateTry(y,m,1);
  DelStack;
end;

procedure bomSelf(var dt: TDateTime);
begin
  dt:=bom(dt);
end;

procedure bomSelf(var dt: variant);
begin
  dt:=bom(dt);
end;

procedure StartOfTheMonthSelf;
begin
  dt:=StartOfTheMonth(dt);
end;

function eom;
var LYear, LMonth, LDay: Word;
begin
  AddStack('My_pr.eom');
  if DecodeDateTry(dt, LYear, LMonth, LDay)
  then Result:=EncodeDateTry(LYear, LMonth, DaysInAMonth(LYear, LMonth))
  else Result:=DateEmpty;
  DelStack;
end;

procedure eomSelf;
begin
  dt:=eom(dt);
end;

function stod;
var i,l: longint;
  function sGet(n: longint): Word;
  begin
  	{$IFDEF STACKALL}AddStack('My_pr.stod.sGet');{$ENDIF}
    result:=0;
    while (i<l) and (n>0) do begin
      Inc(i);
      if not IsDigit(s[i]) then break;
      Dec(n);
      result:=result*10+Ord(s[i])-Ord('0');
    end;
  	{$IFDEF STACKALL}DelStack;{$ENDIF}
  end;
var y,m,d: Word;
begin
	{$IFDEF STACKALL}AddStack('My_pr.stod');{$ENDIF}
  i:=0; l:=Length(s); y:=sGet(4); m:=sGet(2); d:=sGet(2); result:=EncodeDateTry(y,m,D);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure stodSelf;
begin
  s:=stod(s);
end;

function dtos;
begin
	AddStack('My_pr.dtos');
  if empty(dt) then result:=StringOfChar('0',8) else result:=FormatDateTime('yyyymmdd',dt);
  DelStack;
end;

procedure dtosSelf;
begin
  s:=dtos(s);
end;

function DToN;
var y1,y2,m1,m2,d: Word;
begin
	AddStack('My_pr.DToN');
	DecodeDateTry(d1,y1,m1,d); DecodeDateTry(d2,y2,m2,d); result:=(y1-y2)*MonthsPerYear+m1-m2;
  DelStack;
end;

function IncMilliSeconds;
const a: array[1..4] of Word = (HoursPerDay,MinsPerHour,SecsPerMin,MSecsPerSec);
var t: TSystemTime;
	i,j: longint;
	procedure Inc1(var v: Word);
  begin
  	AddStack('My_pr.IncMilliSeconds.Inc1');
	  DivD(j,a[i]); Inc(v, n div j); ModD(n,j); Inc(i);
    DelStack;
  end;
var nd: longint;
begin
	AddStack('My_pr.IncMilliSeconds');
	DateTimeToSystemTime(d,t); j:=1;
  for i:=low(a) to high(a) do MultD(j,a[i]);
  nd := n div j; ModD(n,j); i:=1;
	Inc1(t.wHour); Inc1(t.wMinute); Inc1(t.wSecond); Inc1(t.wMilliSeconds);
  result:=SystemTimeToDateTime(t)+nd;
  DelStack;
end;

procedure DecodeMSec;
begin
  AddStack('My_pr.DecodeMSec');
	MSec:=ModDiv(ms,MSecsPerSec);
  Sec :=ModDiv(ms,SecsPerMin );
  Min :=ModDiv(ms,MinsPerHour);
  Hour:=ms mod HoursPerDay;
  DelStack;
end;

function MSecToTime;
var Hour,Min,Sec,MSec: Word;
begin
  AddStack('My_pr.MSecToTime');
  DecodeMSec(ms,Hour,Min,Sec,MSec); result:=EncodeTimeTry(Hour,Min,Sec,MSec);
  DelStack;
end;

function MSecToStr;
var Hour,Min,Sec,MSec: Word;
begin
  AddStack('My_pr.MSecToStr');
  DecodeMSec(ms,Hour,Min,Sec,MSec);
  result:=Numstr(Hour,2)+StrNum(':',Min,2)+StrNum(':',Sec,2)+StrNum(':',MSec,3);
  DelStack;
end;

function EncodeDateTry;
begin
	{$IFDEF STACKALL}AddStack('My_pr.EncodeDateTry');{$ENDIF}
  if not TryEncodeDate(Year,Month,Day,result) then result:=Default;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function DecodeDateTry;
var ost: longint;
begin
  ost:=AddStack('My_pr.DecodeDateTry');
  try
    result := trunc(Date)<>0;
  except
    SetStack(ost);
    result:=true;
  end;
  if result then DecodeDate(Date,Year,Month,Day)
  else begin
    Year:=0; Month:=0; Day:=0;
  end;
  DelStack;
end;

function EncodeTimeTry;
begin
	AddStack('My_pr.EncodeTimeTry');
  if not TryEncodeTime(Hour,Min,Sec,MSec,result) then result:=DateEmpty;
  DelStack;
end;

function GetTickCount;
begin
  Result:=trunc(TimeStampToMSecs(DateTimeToTimeStamp(Now)));
end;

procedure IncMonthSelf(var DateTime: TDateTime; NumberOfMonths: longint = 1);
begin
  DateTime:=IncMonth(DateTime,NumberOfMonths);
end;

procedure IncMonthSelf(var DateTime: variant; NumberOfMonths: longint = 1);
begin
  DateTime:=IncMonth(DateTime,NumberOfMonths);
end;

procedure IncYearSelf;
begin
  AValue:=IncYear(AValue,ANumberOfYears);
end;

procedure TDateTimeSelf;
begin
  DateTime:=TDateTime(DateTime);
end;

function mDateTime;
begin
  result:=n;
end;

function Empty;
var d: Extended;
  Year,Month,Day: Word;
  i: longint;
  s: string;
begin
	{$IFDEF STACKALL}AddStack('My_pr.Empty');{$ENDIF}
  case MyVarType(v,true) of
		varDouble: begin
    	d:=v;
      if d<0 then d:=-d;
      result:=d<NulFloat;
    end;
		varDate:  begin
      DecodeDateTry(v,Year,Month,Day); result := EncodeDateTry(Year,Month,Day)=DateEmpty;
    end;
		varBoolean: result := not v;
		varString: begin
      result:=true; s:=v;
      for i:=1 to Length(s) do if s[i]>' ' then begin
        result:=false; break;
      end;
    end;
    varArray: result:=false;
  else result:=true;
	end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function VarBlank(const v: variant): variant;
begin
	{$IFDEF STACKALL}AddStack('My_pr.VarBlank');{$ENDIF}
  case MyVarType(v,true) of
		varDouble: result:=0;
		varDate: result:=DateEmpty;
		varBoolean: result:=false;
  else result:='';
	end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function VarBlank(t: TFieldType): variant;
begin
  {$IFDEF STACKALL}AddStack('My_pr.VarBlank');{$ENDIF}
  case UnDataType(t) of
    ftInteger,ftFloat: result:=0;
    ftBoolean: result:=false;
    ftDate: result:=DateEmpty;
  else result:='';
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure VarBlankSelf;
begin
  v:=VarBlank(v);
end;

function iif;
begin
	if AValue then result:=ATrue else result:=AFalse;
end;

function Bool2Int;
begin
  AddStack('My_pr.Bool2Int');
  case MyVarType(AValue,true) of
    varDouble: result:=AValue;
    varBoolean: result:=IfThen(AValue,ATrue,AFalse);
  else result:=Default;
  end;
  DelStack;
end;

procedure Bool2IntSelf;
begin
  AValue:=Bool2Int(AValue,AFalse,ATrue,Default);
end;

function CompVar;
const stComp = [varDouble,varDate,varBoolean];
var t1,t2,l1,h1,l2,h2: longint;
  d1,d2: Extended;
begin
	{$IFDEF STACKALL}AddStack('My_pr.CompVar');{$ENDIF}
  result:=false; t1:=MyVarType(v1,true); t2:=MyVarType(v2,true); SetPBoolean(pCompType,true);
	if t1=t2 then case t1 of
    varNull: result:=true;
  	varDouble:  begin
      d1:=v1; d2:=v2;
      if d1>d2 then IncD(d1,-d2) else d1:=d2-d1;
      result:=d1<NulFloat;
    end;
  	varString: result := string(v1)=string(v2);
  	varArray: begin
    	l1:=VarArrayLowBound(v1,1); h1:=VarArrayHighBound(v1,1);
    	l2:=VarArrayLowBound(v2,1); h2:=VarArrayHighBound(v2,1);
    	result := h1-l1 = h2-l2;
      if result then while l1<=h1 do begin
      	if not CompVar(v1[l1],v2[l2]) then begin
        	result:=false; break;
        end;
      	Inc(l1); Inc(l2);
      end;
    end;
    else result := v1=v2;
    end
  else if (t1 in stComp) and (t2 in stComp) then result := v1=v2
  else SetPBoolean(pCompType,
    (t1=varNull) or (t2=varNull)
    or (t1=varBoolean) and (t2=varArray)
    or (t2=varBoolean) and (t1=varArray));
	{$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function VSubArr;
var i,j: longint;
begin
	AddStack('My_pr.VSubArr');
  result:=false;
  if MyVarType(av)=varArray then begin
    j:=VarArrayLowBound(av,1); i:=VarArrayHighBound(av,1);
    if SubPrmNeg(Index,Count,i-j+1,lNeg) then begin
      Inc(j,Index-1); MinSelf(Count,i-j+1);
      if Count>0 then begin
        result:=VarArrayCreate([1,Count],varVariant);
        for i:=1 to Count do begin
          result[i]:=av[j]; Inc(j);
        end;
      end;
    end;
  end;
  DelStack;
end;

function VAddEnd(const av: variant; Len: longint; const zp: variant): variant;
var i,l,h,h1: longint;
begin
  AddStack('My_pr.VAddEnd');
  if Len>0 then begin
  	if MyVarType(av)=varArray then begin
    	l:=VarArrayLowBound(av,1); h:=VarArrayHighBound(av,1);
    end
    else begin
    	l:=1; h:=0;
    end;
    h1:=Len-l+1; result:=VarArrayCreate([l,h1],varVariant);
    for i:=l to min(h,h1) do result[i]:=av[i];
    for i:=h+1 to h1 do result[i]:=zp;
  end
  else result:=false;
  DelStack;
end;

function VAddEnd(const av: variant; Len: longint): variant;
begin
  result:=VAddEnd(av,Len,null);
end;

procedure VAddEndSelf(var av: variant; Len: longint; const zp: variant);
begin
  av:=VAddEnd(av,Len,zp);
end;

procedure VAddEndSelf(var av: variant; Len: longint);
begin
  av:=VAddEnd(av,Len);
end;

procedure VAddEndSelf(var av: variant; i,Len: longint; const zp: variant);
begin
  av[i]:=VAddEnd(av[i],Len,zp);
end;

function ArrStrToArrVar;
begin
  AddStack('My_pr.ArrStrToArrVar');
  ReplNegSelf(l,a); SetLength(result,l);
  for l:=0 to l-1 do result[l]:=a[l];
  DelStack;
end;

function ArrStrToVar;
var nl,nh: longint;
begin
	AddStack('My_pr.ArrStrToVar');
  nl:=low(a); nh:=ReplNeg(l,a)-1;
  if nh<nl then result:=false
  else begin
    result:=VarArrayCreate([offs+nl,offs+nh],varVariant);
    for l:=nl to min(high(a),nh) do result[offs+l]:=a[l];
  end;
  DelStack;
end;

function ArrVarToVar;
var nl,nh: longint;
begin
	AddStack('My_pr.ArrVarToVar');
  nl:=low(a); nh:=ReplNegVar(l,a)-1;
  if nh<nl then result:=false
  else begin
    result:=VarArrayCreate([offs+nl,offs+nh],varVariant);
    for l:=nl to min(high(a),nh) do result[offs+l]:=a[l];
  end;
  DelStack;
end;

procedure ArrVarToVarSelf;
begin
  a:=ArrVarToVar(a,offs,l);
end;

procedure ArrVarDef;
begin
  AddStack('My_pr.ArrVarDef');
  if MyVarType(a)<>varArray then ArrVarToVarSelf(a);
  DelStack;
end;

function Ls2Var;
var i,l: longint;
begin
  AddStack('My_pr.Ls2Var');
  l:=IfThenCount(ls);
  if l=0 then result:=false
  else begin
    Dec(l); result:=VarArrayCreate([offs,offs+l],varVariant);
    for i:=0 to l do result[offs+i]:=ls[i];
  end;
  DelStack;
end;

function ascan;
var i:longint;
begin
	AddStack('My_pr.ascan');
	result:=false;
	for i:=VarArrayLowBound(a,1) to VarArrayHighBound(a,1) do if CompVar(a[i],zn) then begin
    result:=true; break;
  end;
  DelStack;
end;

function IsNil(var Value: variant; const Default: variant): variant;
begin
	if IsNil(Value) then Value:=Default;
  result:=Value;
end;

function IsNil(const Value: variant): boolean;
begin
  result := MyVarType(Value)=varNull;
end;

function IsNilc(const Value,Default: variant; var NoNil: boolean): variant;
begin
	NoNil:=not IsNil(Value); result:=iif(NoNil,Value,Default);
end;

function IsNilc(const Value,Default: variant): variant;
var NoNil: boolean;
begin
	result:=IsNilc(Value,Default,NoNil);
end;

function MyVarType;
begin
  {$IFDEF STACKALL}AddStack('My_pr.MyVarType');{$ENDIF}
  result:=TVarData(v).VType;
  if (result and varArray) = 0 then begin
    case result of
      varEmpty:			result:=varNull;
      varSmallInt:	result:=varInteger;
      varSingle:		result:=varDouble;
      varCurrency:	result:=varDouble;
      varOleStr:		result:=varString;
      varShortInt:	result:=varInteger;
      varByte:			result:=varInteger;
      varWord:			result:=varInteger;
      varLongWord:	result:=varInteger;
      varInt64:			result:=varInteger;
    end;
    if lIntAsDbl and (result=varInteger) then result:=varDouble;
  end
  else result:=varArray;
	{$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function ReplVar(const v,vFrom,vTo: variant): variant;
begin
  result:=iif(v=vFrom,vTo,v);
end;

function ReplVar(const v,vTo: string): string;
begin
  result:=ReplVar(v,'',vTo);
end;

function ReplVar(v,vTo: longint): longint;
begin
  result:=ReplVar(v,0,vTo);
end;

function ReplVar(v,vTo: TDateTime): TDateTime;
begin
  result:=ReplVar(v,DateEmpty,vTo);
end;

procedure ReplVarSelf;
begin
  v:=ReplVar(v,vTo);
end;

function ReplDateEmptySmall;
begin
  AddStack('My_pr.ReplDateEmptySmall');
  result:=ReplVar(v,DateSmall);
  DelStack;
end;

procedure ReplDateEmptySmallSelf;
begin
  v:=ReplDateEmptySmall(v);
end;

function ReplDateSmallEmpty;
begin
  AddStack('My_pr.ReplDateSmallEmpty');
  result:=IfThen(v>DateSmall,v,DateEmpty);
  DelStack;
end;

function ReplDateBigEmpty(const v: variant): TDateTime;
begin
  AddStack('My_pr.ReplDateBigEmpty');
  result:=ReplDateNullEmpty(ReplVar(v,DateBig,DateEmpty));
  DelStack;
end;

function ReplDateBigEmpty(f: TField): TDateTime;
begin
  result:=ReplDateBigEmpty(f.Value);
end;

procedure ReplDateBigEmptySelf;
begin
  v:=ReplDateBigEmpty(v);
end;

function ReplDateEmptyBig;
begin
  AddStack('My_pr.ReplDateEmptyBig');
  result:=ReplVar(v,DateBig);
  DelStack;
end;

procedure ReplDateEmptyBigSelf(var v: TDateTime);
begin
  v:=ReplDateEmptyBig(v);
end;

function ReplDateNullEmpty(const v: variant): TDateTime; overload;
begin
  AddStack('My_pr.ReplDateNullEmpty');
  result:=ReplVar(v,null,DateEmpty);
  DelStack;
end;

function ReplDateNullEmpty(f: TField): TDateTime;
begin
  result:=ReplDateNullEmpty(f.Value);
end;

function ReplNeg(l: longint; lDef: longint): longint;
begin
  result:=ReplVar(l,NegDef,lDef);
end;

function ReplNeg(l: longint; const a: array of string): longint;
begin
  result:=ReplNeg(l,Length(a));
end;

function ReplNeg(l: longint; const a: array of longint): longint;
begin
  result:=ReplNeg(l,Length(a));
end;

function ReplNegVar;
begin
  result:=ReplNeg(l,Length(a));
end;

function ReplNeg(l: longint; const s: string): longint;
begin
  result:=ReplNeg(l,Length(s));
end;

function ReplNegSelf(var l: longint; lDef: longint): boolean;
begin
  result := l=NegDef;
  if result then l:=lDef;
end;

function ReplNegSelf(var l: longint; const a: array of string): boolean;
begin
  result:=ReplNegSelf(l,Length(a));
end;

function ReplNegSelf(var l: longint; const a: array of longint): boolean; 
begin
  result:=ReplNegSelf(l,Length(a));
end;

function ReplNegSelf(var l: longint; const s: string): boolean;
begin
  result:=ReplNegSelf(l,Length(s));
end;

procedure DeleteVar;
var s: string;
begin
  AddStack('My_pr.DeleteVar');
  s:=v; Delete(s,Index,Count); v:=s;
  DelStack;
end;

procedure DeleteArr;
var s: string;
begin
  AddStack('My_pr.DeleteArr');
  s:=v[i]; Delete(s,Index,Count); v[i]:=s;
  DelStack;
end;

function VarArrayLowCng;
var l,h: longint;
begin
  AddStack('My_pr.VarArrayLowCng');
  l:=VarArrayLowBound(v,1); h:=VarArrayHighBound(v,1); result:=VarArrayCreate([low,low+h-l],varVariant);
  for l:=l to h do begin
    result[low]:=v[l]; Inc(low);
  end;
  DelStack;
end;

procedure VarSet(var a: variant; i1,i2: longint; const v: variant); overload;
var a1: variant;
begin
  a1:=a[i1]; a1[i2]:=v; a[i1]:=a1;
end;

{procedure VarSet(var a: variant; i1,i2,i3: longint; const v: variant); overload;
var a1: variant;
begin
  a1:=a[i1]; VarSet(a1,i2,i3,v); a[i1]:=a1;
end;}

procedure VarAsTypeSelf;
begin
  V:=VarAsType(V,AVarType);
end;

procedure VarArrayOfSelf;
begin
  if MyVarType(v)<>varArray then v:=VarArrayOf([v]);
end;

function VarLength;
begin
  try
    result:=1+VarArrayHighBound(v,1)-VarArrayLowBound(v,1);
  except
    result:=0;
  end;
end;

function CompSign;
begin
  result:=IfThen(v1<>v2,aSign[v1<v2]);
end;

function PointerDef;
begin
  if not Assigned(Dest) then Dest:=Source;
  result:=Assigned(Dest);
end;

function PointerVar(const v: variant): pointer;
begin
  result:=pointer(longint(v));
end;

function PointerVar(const v: variant; var p: pointer): boolean;
begin
  p:=PointerVar(v); result:=Assigned(p);
end;

function PointerVar(const av: array of variant; i: longint): pointer;
begin
  if InRange(i,low(av),high(av)) then result:=PointerVar(av[i]) else result:=nil;
end;

function PointerStr(const s: string): longint;
begin
  result:=LongInt(pointer(s));
end;

function PointerStr(const s: string; offs: longint): pointer;
begin
  result:=pointer(PointerStr(s)+offs);
end;

function PointerInt0;
begin
  result:=pointer(Int0(s));
end;

function StringListVar;
begin
  result:=PointerVar(v);
end;

function IntegerListVar;
begin
  result:=PointerVar(v);
end;

function IntStrListVar;
begin
  result:=PointerVar(v);
end;

function LongIntVar;
begin
  result:=PointerVar(v);
end;

function StringVar;
begin
  result:=PointerVar(v);
end;

function BoolVar;
begin
  result:=PointerVar(v);
end;

function DoubleVar;
begin
  result:=PointerVar(v);
end;

function DateVar;
begin
  result:=PointerVar(v);
end;

function VariantVar;
begin
  result:=PointerVar(v);
end;

function ArrStrVar;
begin
  result:=PointerVar(v);
end;

function ArrIntVar;
begin
  result:=PointerVar(v);
end;

function ArrVarVar;
begin
  result:=PointerVar(v);
end;

function DEPrmStrVar;
begin
  result:=PointerVar(v);
end;

function FieldVar;
begin
  result:=PointerVar(v);
end;

function PointerDate;
begin
  result:=pointer(trunc(d));
end;

{$IFDEF LIBTEST}
function msrActCont;
var tw: TWinControl;
begin
	AddStack('My_pr.msrActCont');
	tw:=GetParentForm(Sender).ActiveControl;
  if Assigned(tw)
  then result:=tw.Name+'<'+tw.ClassName+'>'
  else result:='NIL';
  DelStack;
end;

const MsgFile = 'C'+DriveDelim+PathDelim+'T'+PathDelim+'MyMsg.txt';

procedure clrmsgfile;
begin
	DeleteFile(PChar(MsgFile));
end;

procedure addmsgfile;
var ls: TStringList;
begin
	ls:=TStringList.Create;
  try
    if FileExists(MsgFile) then ls.LoadFromFile(MsgFile);
    ls.Add(ms); ls.SaveToFile(MsgFile);
  finally
	  ls.Free;
  end;
end;

procedure MsgComponentState;
begin
	AddStack('My_pr.MsgComponentState');
	clrmsgfile; addmsgfile('ComponentState:');
	if csLoading in tc.ComponentState then addmsgfile('csLoading');
	if csReading in tc.ComponentState then addmsgfile('csReading');
	if csWriting in tc.ComponentState then addmsgfile('csWriting');
	if csDestroying in tc.ComponentState then addmsgfile('csDestroying');
	if csDesigning in tc.ComponentState then addmsgfile('csDesigning');
	if csAncestor in tc.ComponentState then addmsgfile('csAncestor');
	if csUpdating in tc.ComponentState then addmsgfile('csUpdating');
	if csFixups in tc.ComponentState then addmsgfile('csFixups');
  DelStack;
end;

{$ENDIF}

function SetWndDebug(Handle: HWND): boolean;
var off: boolean;
	fl: boolean;
begin
	off := Handle=0; result := (WndDebug=0) <> off;
	if result then
    if off then begin
      WndDebug:=0; DisposeNil(pointer(pcds)); 
    end
    else begin
      WndDebug:=Handle; New(pcds);
      with pcds^ do begin
      	dwData:=idProgDir; cbData:=length(ExeDir); GetMem(lpData,cbData);
      	try
          CopyMemory(lpData,pointer(ExeDir),cbData);
          fl:=SendMessage(WndDebug,WM_COPYDATA,Application.Handle,longint(pcds))=idProgDir;
        finally
	        FreeMem(lpData);
        end;
        if not fl then SetWndDebug(0);
      end;
    end;
end;

function DelFStack: boolean;
begin
  if WndDebug=0 then result:=true
  else with pcds^ do begin
    dwData:=idProgData; cbData:=0; lpData:=nil;
    result:=SendMessage(WndDebug,WM_COPYDATA,Application.Handle,longint(pcds))=idProgData;
    if not result then SetWndDebug(0);
  end;
end;

function GetStack(n: longint = 0): string;
begin
  if n=0 then n:=nStack;
	result:=aStack[n];
  if aStackName[n]<>'' then IncL(result,'('+aStackName[n]+')');
end;

{$IFDEF PROF}
procedure ProfAddTime(FuncName: PString; const FuncAdd: string; oTime: longword; lIncCnt: boolean);
begin
  if Assigned(MyTypes.ProfAddTime) then MyTypes.ProfAddTime(FuncName,FuncAdd,oTime,lIncCnt);
end;
{$ENDIF}

function AddStack;
const cFill = Ord('+');
var fl: boolean;
{$IFDEF PROFPAS}
	oTime: longword;
  pFuncName: PString;
{$IFDEF PROFPARENT}
  FuncName,FuncAdd: string;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF PROFPAS}
	oTime:=My_pr.GetTickCount;
{$ENDIF}
	if not(csDesigning in Application.ComponentState) and (nStack>=0) then begin
    Inc(nStack);
    if nStack>StackSize then begin
      OutStack('Переполнение стека',[outstAll]); nStack:=-1;
    end;
    if nStack>0 then begin
      aStack[nStack]:=FncName;
      if Assigned(Sender) then aStackName[nStack]:=Sender.Name else aStackName[nStack]:='';
      if (WndDebug<>0) then with pcds^ do begin
      	dwData:=idProgData; cbData:=nStack+length(GetStack(nStack)); GetMem(lpData,cbData);
      	try
          FillMemory(lpData,nStack-1,cFill);
          FillMemory(Pointer(Longint(lpData)+nStack-1),1,Ord('>'));
          CopyMemory(pointer(longint(lpData)+nStack),pointer(GetStack(nStack)),cbData-longword(nStack));
          fl:=SendMessage(WndDebug,WM_COPYDATA,Application.Handle,longint(pcds))=idProgData;
        finally
	        FreeMem(lpData);
        end;
        if not fl then SetWndDebug(0);
      end;
{$IFDEF PROFPAS}
      pFuncName:=nil;
{$IFDEF PROFPARENT}
      FuncAdd:=aStack[nStack];
      if nStack>1 then begin
      	FuncName:=aStack[nStack-1]; IncD(FuncAdd,': '+FuncName);
	      if nStack>2 then IncD(FuncName,': '+aStack[nStack-2]);
        pFuncName:=@FuncName;
      end;
      ProfAddTime(pFuncName,FuncAdd,oTime,false);
{$ELSE}
      if nStack>1 then pFuncName:=@aStack[nStack-1];
      ProfAddTime(pFuncName,aStack[nStack],oTime,false);
{$ENDIF}
{$ENDIF}
    end;
  end;
  result:=nStack;
end;

procedure RnmStack;
const cFill = Ord('+');
var fl: boolean;
{$IFDEF PROFPAS}
	oTime: longword;
  FuncName: string;
{$ENDIF}
begin
  ReplNegSelf(nst,nStack);
{$IFDEF PROFPAS}
	oTime:=My_pr.GetTickCount;
{$ENDIF}
	if not(csDesigning in Application.ComponentState) and (nst>=0) then begin
    if nst>0 then begin
{$IFDEF PROFPAS}
{$IFNDEF PROFPARENT}
      FuncName:=aStack[nst]; ProfAddTime(@FuncName,FuncName,oTime,true); oTime:=My_pr.GetTickCount;
{$ENDIF}
{$ENDIF}
      aStack[nst]:=FncName;
      if Assigned(Sender) then aStackName[nst]:=Sender.Name else aStackName[nst]:='';
      if DelFStack and (WndDebug<>0) then with pcds^ do begin
      	dwData:=idProgData; cbData:=nst+length(aStack[nst]); GetMem(lpData,cbData);
      	try
          FillMemory(lpData,nst-1,cFill);
          FillMemory(Pointer(Longint(lpData)+nst-1),1,Ord('>'));
          CopyMemory(pointer(longint(lpData)+nst),pointer(aStack[nst]),cbData-longword(nst));
          fl:=SendMessage(WndDebug,WM_COPYDATA,Application.Handle,longint(pcds))=idProgData;
        finally
	        FreeMem(lpData);
        end;
        if not fl then SetWndDebug(0);
      end;
{$IFDEF PROFPAS}
{$IFDEF PROFPARENT}
      FuncName:=aStack[nst];
      if nst>1 then IncD(FuncName,': '+aStack[nst-1]);
      ProfAddTime(@FuncName,'',oTime,false);
{$ELSE}
      ProfAddTime(@FuncName,aStack[nst],oTime,false);
{$ENDIF}
{$ENDIF}
    end;
  end;
end;

procedure SetStack;
begin
  // AddStack('') (комментарий не убирать, для эксперта TEStackEr "Ошибки стека")
	while nStack>nst do DelStack;
end;

procedure DelStack;
{$IFDEF PROFPAS}
var oTime: longword;
{$IFDEF PROFPARENT}
  FuncName: string;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF PROFPAS}
	oTime:=My_pr.GetTickCount;
{$ENDIF}
	if nStack>0 then begin
  	Dec(nStack); DelFStack;
{$IFDEF PROFPAS}
{$IFDEF PROFPARENT}
    FuncName:=aStack[nStack+1];
    if nStack>0 then IncD(FuncName,': '+aStack[nStack]);
    ProfAddTime(@FuncName,FuncName,oTime,true);
{$ELSE}
    ProfAddTime(@aStack[nStack+1],aStack[nStack+1],oTime,true);
{$ENDIF}
{$ENDIF}
  end;
end;

procedure OutStack;
var f,l: longint;
	Buf: array[1..1] of char;
  procedure WrStr(s: string);
	var i,l1: longint;
  begin
  	IncD(s,CRLF); l1:=Length(s); Inc(l,l1);
  	for i:=1 to l1 do begin
	  	Buf[1]:=s[i]; FileWrite(f,Buf,1);
    end;
  end;
var ost,i: longint;
  fn: TFileName;
	s,s1: string;
begin
	if nStack<=0 then Exit;
  if ProtErrWriting then Exit;
  if aProtFileExt[0]='' then Exit; // Запись в протокол после My_pr.finalization
  ost:=nStack; fn:=ExtractFilePath(Application.ExeName)+aProtFile[protProg,1]+'.'+aProtFileExt[0];
  if FileExists(fn) then f:=FileBufOpen(fn,fmOpenWrite or fmShareDenyNone) else f:=FileBufCreate(fn);
  if f=-1 then Exit;
  try
    ProtErrWriting:=true;
    l:=FileSeek(f,0,soFromEnd);
    WrStr('');
    WrStr('*********************************');
    try
      s:=FormatDateTime('dd/mm/yyyy tt',Now);
    except
      SetStack(ost);
      s:='[ОШИБКА ОПРЕДЕЛЕНИЯ ВРЕМЕНИ]';
    end;
    try
      s1:=StrExeVersion;
    except
      SetStack(ost);
      s1:='[ОШИБКА ОПРЕДЕЛЕНИЯ НОМЕРА СБОРКИ]';
    end;
    WrStr(s+' ('+s1+')');
    if not(outstMsgOnly in Opt) then
      for i:=IfThen(outstAll in Opt,StackSize,min(nStack,StackSize)) downto 1 do WrStr('  '+GetStack(i));
    WrStr(Msg);
  finally
    FileClose(f); ProtErrWriting:=false;
  end;
  if outstClear in Opt then begin
    nStack:=-1; NormalExit:=false;
  end;
  MsgProtSave(l,fn);
end;

procedure MsgProtSave;
begin
  if Assigned(Application.MainForm) then Application.MainForm.Perform(WM_PROTSAVE,Length,longint(@FileName));
end;

procedure GetStack(var a: TArrStr);
var i: longint;
begin
  SetLength(a,max(0,nStack));
  for i:=1 to nStack do a[i-1]:=GetStack(i);
end;

procedure CloseDataSets;
begin
  AddStack('My_pr.CloseDataSets');
  //clrmsgfile;
  DataSetsProc(db,TNone.dsClose);
  DelStack;
end;

procedure DataSetsProc;
var i,ocnt: longint;
begin
  AddStack('My_pr.DataSetsProc');
  i:=0;
  if db is TIBDatabase then with TIBDatabase(db) do begin
    while i<FIBDataSetsCount do begin
      ocnt:=FIBDataSetsCount; Proc(FIBDataSets[i]);
      if FIBDataSetsCount=ocnt then Inc(i);
    end;
    i:=0;
    while i<FIBQueryCount do begin
      ocnt:=FIBQueryCount; Proc(FIBQueries[i]);
      if FIBQueryCount=ocnt then Inc(i);
    end;
  end
  else with TCustomConnection(db) do while i<DataSetCount do begin
    ocnt:=DataSetCount; Proc(DataSets[i]);
    if DataSetCount=ocnt then Inc(i);
  end;
  DelStack;
end;

function FileNameExt;
begin
	AddStack('My_pr.FileNameExt');
	result:=fn;
	if not Empty(result) then begin
    if ExtractFileExt(result)='' then IncD(result,'.'+Ext);
    ExtractFileNameSelf(result);
  end;
  DelStack;
end;

procedure FileNameExtSelf;
begin
  fn:=FileNameExt(fn,Ext);
end;

function FullNameExe;
begin
	AddStack('My_pr.FullNameExe');
	result:=fn;
	if not Empty(result) then begin
    if ExtractFileExt(result)='' then IncD(result,IfThen(StrToChar(Ext)<>'.','.')+Ext);
    if empty(ExtractFileDrive(result)) then IncL(result,IfThen(Path='',ExeDir,Path));
  end;
  DelStack;
end;

procedure FullNameExeSelf;
begin
  fn:=FullNameExe(fn,Ext,Path);
end;

function FileWithOutExt;
begin
  result:=ChangeFileExt(FileName,'');
end;

procedure FileWithOutExtSelf;
begin
  FileName:=FileWithOutExt(FileName);
end;

function ExtractFileWithOutExt;
begin
  result:=ExtractFileName(FileWithoutExt(FileName));
end;

procedure ChangeFileExtSelf;
begin
  FileName:=ChangeFileExt(FileName,Ext);
end;

function GetFileDateTime;
var d: longint;
begin
	AddStack('My_pr.GetFileDateTime');
  d:=FileAge(FileName);
  if d=-1 then result:=DateEmpty else result:=FileDateToDateTime(d);
  DelStack;
end;

procedure SetFileDateTime;
var f: longint;
begin
	AddStack('My_pr.SetFileDateTime');
  f:=FileBufOpen(FileName,fmOpenWrite or fmShareDenyNone);
  FileSetDate(f,DateTimeToFileDate(d)); FileClose(f);
  DelStack;
end;

function FileClrAttr;
begin
	AddStack('My_pr.FileClrAttr');
{$IFDEF MSWINDOWS}
	result:=SetFileAttributes(PChar(FileName),Attr);
{$ELSE}
  result:=true;
{$ENDIF}
  DelStack;
end;

function GetFileSize(const FileName: TFileName; IsFile: PBoolean = nil): Int64;
var ost: longint;
  i: THandle;
  fl: boolean;
begin
	ost:=AddStack('My_pr.GetFileSize(f)');
  result:=0; SetPBoolean(IsFile,false);
	if MyFileExists(FileName) then for fl:=false to true do begin
  	if fl then try
    	FileClrAttr(FileName);
    except
      SetStack(ost);
    end;
    i:=FileBufOpen(FileName,fmShareDenyNone or fmOpenRead);
    if longword(i)<>INVALID_HANDLE_VALUE then begin
      result:=GetFileSize(i); FileClose(i); SetPBoolean(IsFile,true); break;
    end;
  end;
  DelStack;
end;

function GetFileSize(Handle: THandle): Int64;
var h: longword;
begin
  AddStack('My_pr.GetFileSize(h)');
  result:=Windows.GetFileSize(Handle,@h); Inc(result,h*(Int64(MaxDWord)+1));
  DelStack;
end;

function GetFileSize(const sr: TSearchRec): Int64;
begin
  AddStack('My_pr.GetFileSize(sr)');
  result:={$IFDEF MSWINDOWS}sr.FindData.nFileSizeHigh*(Int64(MaxDWord)+1) + sr.FindData.nFileSizeLow{$ELSE}sr.Size{$ENDIF};
  DelStack;
end;

function GetFileSize(const Path: TFileName; const aFileName: array of string): Int64;
var i: longint;
begin
  AddStack('My_pr.GetFileSize(path)');
  result:=0;
  for i:=low(aFileName) to high(aFileName) do Inc(result,GetFileSize(Path+aFileName[i]));
  DelStack;
end;

function GetStrSize;
const a: array[0..4] of string = ('байт','Кб','Мб','Гб','Тб');
  KByte2 = KByte div 2;
var i,n: byte;
begin
  AddStack('My_pr.GetStrSize');
  n:=high(a);
  for i:=low(a) to n do
    if Size>KByte then Size := Size div KByte + IfThen(Size mod KByte >= KByte2, 1)
    else begin
      n:=i+IfThen((Size=KByte) and (i<n),1); break;
    end;
  result:=IntToStr(Size)+' '+a[n];
  DelStack;
end;

procedure SetExeDir;
begin
	AddStack('My_pr.SetExeDir');
  if d=''
  then ExeDir:=ExtractFilePath(Application.ExeName)
  else ExeDir:=IncludeTrailingPathDelimiter(d);
  DelStack;
end;

function CngDir;
var AOwner: TComponent;
begin
  AddStack('FMain.CngDir');
  result:=ExeDir;	AOwner:=InitFIni.Owner; InitFIni[fiSave].UpdateFile; InitFIni.Free;
  SetExeDir(d); InitFIni:=TInitFIni.Create(AOwner);
  DelStack;
end;

procedure CngDirSelf;
begin
  d:=CngDir(d);
end;

function CorrDir(const Dir: TFileName; Opt: TCorrDirkOpt = []): TFileName;
begin
	AddStack('My_pr.CorrDir');
  result:=Trim(Dir);
  if result<>'' then begin
    if not(crdrNoUpper in Opt) then AnsiUpperCaseSelf(result);
    if crdrNoDlmEnd in Opt
    then result:=ExcludeTrailingPathDelimiter(result)
    else result:=IncludeTrailingPathDelimiter(result);
  end;
  DelStack;
end;

function CorrDir(const Dir: TFileName; Opt: TCorrDirkList): TFileName;
begin
  result:=CorrDir(Dir,[Opt]);
end;

procedure CorrDirSelf(var Dir: TFileName; Opt: TCorrDirkOpt = []);
begin
  Dir:=CorrDir(Dir,Opt);
end;

procedure CorrDirSelf(var Dir: string; Opt: TCorrDirkOpt = []);
begin
  Dir:=CorrDir(Dir,Opt);
end;

procedure CorrDirSelf(ls: TStrings; Opt: TCorrDirkOpt = []);
var i: longint;
begin
  for i:=0 to ls.Count-1 do ls[i]:=CorrDir(ls[i],Opt);
end;

function MaskFilesProc;
var i: longint;
	sr: TSearchRec;
begin
  AddStack('My_pr.MaskFilesProc');
  if Attr=[] then Attr:=[fmFiles];
  result:=true; i:=FindFirst(Path,faAnyFile-IfThen(not(fmDir in Attr),faDirectory),sr);
  while i=0 do begin
    if NotSysDir(sr)
    and ((fmFiles in Attr) or ((sr.Attr and faDirectory)=faDirectory)) then begin
      Proc(av,sr,result);
    	if not result then break;
    end;
    i:=FindNext(sr);
  end;
  SysUtils.FindClose(sr);
  DelStack;
end;

function NotSysDir;
begin
  AddStack('My_pr.NotSysDir');
  if (sr.Attr and faDirectory)=faDirectory
  then result:=not((StrToChar(sr.Name)='.') and (ExtractFileExt(sr.Name)='.'))
  else result:=true;
  DelStack;
end;

procedure PrGetMaskFilesLs(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
var s: string;
  Opt: TGetMaskFilesOpt;
begin
	AddStack('My_pr.PrGetMaskFilesLs');
  Opt:=TGetMaskFilesOpt(byte(av[0])); s:=sr.Name;
  if not(msfNoUpper in Opt) then AnsiUpperCaseSelf(s);
  with StringListVar(av[1]) do
  	if msfAge in Opt
    then AddObject(s,Pointer(sr.Time))
    else AddObject(s,Pointer((sr.Attr and faDirectory) <> 0));
  DelStack;
end;

function GetMaskFiles(ls: TStringList; const Path: string;
	Attr: TFileMaskType = []; Opt: TGetMaskFilesOpt = []): boolean;
begin
	AddStack('My_pr.GetMaskFiles(ls)');
	if not(msfAdd in Opt) then begin
    if msfSort in Opt then ls.Sorted:=false;
    ls.Clear;
  end;
  MaskFilesProc(Path,PrGetMaskFilesLs,[byte(Opt),LongInt(ls)],Attr);
  if msfSort in Opt then ls.Sorted:=true;
  result:=ls.Count>0;
  DelStack;
end;

procedure PrGetMaskFilesA(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
var a: PArrStr;
  l: PLongInt;
  pd: PArrDate;
begin
	AddStack('My_pr.PrGetMaskFilesA');
  a:=PointerVar(av[1]); l:=PointerVar(av[2]); pd:=PointerVar(av[3]);
  if Length(a^)=l^ then SetLength(a^,l^ shl 1);
  a^[l^]:=sr.Name;
  if not(msfNoUpper in TGetMaskFilesOpt(byte(av[0]))) then AnsiUpperCaseSelf(a^[l^]);
  if Assigned(pd) then begin
    if Length(pd^)=l^ then SetLength(pd^,l^ shl 1);
    pd^[l^]:=FileDateToDateTime(sr.Time);
  end;
  Inc(l^);
  DelStack;
end;

function GetMaskFiles(var a: TArrStr; var l: longint; const Path: string;
	Attr: TFileMaskType = []; Opt: TGetMaskFilesOpt = []; pd: PArrDate = nil): boolean;
begin
	AddStack('My_pr.GetMaskFiles(a)');
	if not(msfAdd in Opt) then l:=0;
  if Length(a)=0 then SetLength(a,10);
  if Assigned(pd) then if Length(pd^)=0 then SetLength(pd^,10);
  MaskFilesProc(Path,PrGetMaskFilesA,[byte(Opt),LongInt(@a),LongInt(@l),LongInt(pd)],Attr);
  if msfSort in Opt then QuickSort(a,l);
  result := l>0;
  DelStack;
end;

procedure GetMaskFilesIni;
var n: longint;
begin
  AddStack('FMain.GetMaskFilesIni');
  GetMaskFiles(ls,path+Mask+'.INI');
  for n:=0 to ls.Count-1 do GetIniFileName(path+ls[n]);
  GetMaskFiles(ls,path+Mask+IniExt);
  DelStack;
end;

procedure PrDelMaskFiles(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
begin
	AddStack('My_pr.PrDelMaskFiles');
  if not DelFileAtr(av[0]+TrimUpper(sr.Name)) then lDone:=false;
  DelStack;
end;

function DelMaskFiles;
begin
	AddStack('My_pr.DelMaskFiles');
  result:=MaskFilesProc(PathMask,PrDelMaskFiles,[ExtractFilePath(PathMask)]);
  DelStack;
end;

procedure DelDir;
begin
  AddStack('My_pr.DelDir');
  DelMaskFiles(CorrDir(dir)+'*.*'); DirRemove(CorrDir(dir,crdrNoDlmEnd));
  DelStack;
end;

procedure PrIsMaskFiles(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
begin
	AddStack('My_pr.PrIsMaskFiles');
  lDone:=false; BoolVar(av[0])^:=true;
  DelStack;
end;

function IsMaskFiles;
begin
	AddStack('My_pr.IsMaskFiles');
  result:=false; MaskFilesProc(Path,PrIsMaskFiles,[LongInt(@result)],Attr);
  DelStack;
end;

procedure PrFirstMaskFiles(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
begin
	AddStack('My_pr.PrFirstMaskFiles');
  lDone:=false; BoolVar(av[0])^:=true; PFileName(LongInt(av[1]))^:=TrimUpper(sr.Name);
  DelStack;
end;

function FirstMaskFiles;
begin
	AddStack('My_pr.FirstMaskFiles');
	result:=false; FileName:='';
  MaskFilesProc(Path,PrFirstMaskFiles,[LongInt(@result),LongInt(@FileName)],Attr);
  DelStack;
end;

procedure PrCntMaskFiles(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
begin
  AddStack('My_pr.PrCntMaskFiles');
  Inc(LongIntVar(av[0])^);
  DelStack;
end;

function CntMaskFiles;
begin
  AddStack('My_pr.CntMaskFiles');
  result:=0; MaskFilesProc(Path,PrCntMaskFiles,[longint(@result)]);
  DelStack;
end;

function SizeFiles;
var i,j: longint;
	sr: TSearchRec;
  s,Dir: TFileName;
begin
	AddStack('My_pr.SizeFiles');
  result:=0; Dir:=CorrDir(cDir);
  if lSubDir then begin
  	i:=FindFirst(Dir+'*.*',faDirectory,sr);
    while i=0 do begin
    	if NotSysDir(sr) then Inc(result,SizeFiles(aPath,Dir+sr.Name,true));
      i:=FindNext(sr);
    end;
    SysUtils.FindClose(sr);
  end;
  for j:=low(aPath) to high(aPath) do begin
  	s:=Dir+aPath[j]; i:=FindFirst(s,faAnyFile-faDirectory,sr); ExtractFilePathSelf(s);
    while i=0 do begin
      Inc(result,GetFileSize(sr)); i:=FindNext(sr);
    end;
    SysUtils.FindClose(sr);
  end;
  DelStack;
end;

function FileMaskEquate;
var
  Fl, Ml: byte; // length of file name and mask
  Fp, Mp: byte; // pointers
  F,M: string;
begin
  F := UpperCase(cF);
  M := UpperCase(cM);
  result := true;
  Fl := length(F);
  Ml := length(M);
  Fp := 1;
  Mp := 1;
  while Mp <= Ml do
  begin // wildcard
    case M[Mp] of //
      '?':
        begin // if one any char
          inc(Mp); // next char of mask
          inc(Fp); // next char of file name
        end; //
      '*':
        begin // if any chars
          if Mp = Ml then
            break; // if last char in mask then exit
          if M[Mp + 1] = F[Fp] then
          begin // if next char in mask equate char in
            Inc(Mp); // file name then next char in mask and
          end
          else
          begin // else
            if Fp = Fl then
            begin // if last char in file name then
              result := false; // function return false
              break; //
            end; // else, if not previous, then
            inc(Fp); // next char in file name
          end; //
        end; //
    else
      begin // other char in mask
        if M[Mp] <> F[Fp] then
        begin // if char in mask not equate char in
          result := false; // file name then function return
          break; // false
        end; // else
        inc(Fp); // next char of mask
        inc(Mp); // next char of file name
      end //
    end;
  end;
end;

function DiskReady;
const MaxBuf = 100;
var lpVolumeNameBuffer,lpFileSystemNameBuffer: array[0..MaxBuf] of char;
  lpVolumeSerialNumber: longword;
  lpMaximumComponentLength,lpFileSystemFlags: longword;
  cd: string;
begin
  AddStack('My_pr.DiskReady');
  result:=true; cd:=ExtractFileDrive(dir);
  if empty(cd) then cd:=ExtractFileDrive(ExeDir);
  if UpCase(StrToChar(cd))<'C' then result:=GetVolumeInformation(PChar(cd),lpVolumeNameBuffer,MaxBuf,
    @lpVolumeSerialNumber,lpMaximumComponentLength,lpFileSystemFlags,lpFileSystemNameBuffer,MaxBuf);
  DelStack;
end;

function MyDiskFree;
var cd: TFileName;
  FreeAvailable,TotalSpace: Int64;
  procedure Inf1;
  var RootPath: TArrChar;
    RootPtr: PChar;
    i: longint;
  begin
    AddStack('My_pr.MyDiskFree.Inf1');
    SetLength(RootPath,Length(cd)+1);
    for i:=1 to Length(cd) do RootPath[i-1]:=cd[i];
    RootPath[high(RootPath)]:=#0; RootPtr:=@RootPath[0];
    // Наличие дискеты в дисководе
    if DiskReady(cd) then SysUtils.GetDiskFreeSpaceEx(RootPtr,FreeAvailable,TotalSpace,nil)
    else if lTotal then TotalSpace:=0 else FreeAvailable:=0;
    DelStack;
  end;
var lNet: boolean;
  lpNetResource: TNetResource;
  i: longint;
begin
	AddStack('My_pr.MyDiskFree');
  cd:=TrimUpper(cdrv); lNet:=IsNetDrive(cd);
  if not lNet and (Pos(':',cd)=0) then IncD(cd,':');
  ExtractFileDriveSelf(cd); Inf1;
  if FreeAvailable=0 then
    if lNet then begin
      lNet:=AddConnect(cd,lpNetResource);
      if lNet then Inf1;
    end
    else begin
      i:=Ord(StrToChar(cd))-Ord('A')+1;
      if lTotal then TotalSpace:=DiskSize(i) else FreeAvailable:=DiskFree(i);
    end
  else lNet:=false;
  result:=IfThen(lTotal,TotalSpace,FreeAvailable);
  if lNet then DelConnect(lpNetResource);
  DelStack;
end;

function AddConnect;
var lpBuffer: PChar;
  i: longint;
  s: string;
begin
  AddStack('My_pr.AddConnect');
  lpBuffer:=StrAlloc(MaxByte+1);
  try
    with lpNetResource do begin
      dwScope:=RESOURCE_CONNECTED; dwType:=RESOURCETYPE_DISK;
      dwDisplayType:=RESOURCEDISPLAYTYPE_GENERIC;
		  lpLocalName:=StrAlloc(MaxByte); lpRemoteName:=StrAlloc(MaxByte);
      s:=ExtractFileDrive(cd); StrCopy(lpRemoteName,PChar(s));
      s:=Copy(cd,Length(s)+1,MaxInt); lpComment:=nil; lpProvider:=nil;
      i:=GetLogicalDriveStrings(MaxByte,lpBuffer)-1;
      while i>0 do
        if lpBuffer[i-1]=#0 then break else Dec(i);
      cd:=LeftStr(StrPas(lpBuffer+i),2);
      cd[1]:=Chr(Ord(cd[1])+1); StrCopy(lpLocalName,PChar(cd)); IncD(cd,s);
    end;
  finally
    StrDispose(lpBuffer);
  end;
  result := WNetAddConnection2(lpNetResource,nil,nil,CONNECT_UPDATE_PROFILE)=NO_ERROR;
  DelStack;
end;

procedure DelConnect;
begin
	AddStack('My_pr.DelConnect');
  with lpNetResource do begin
    WNetCancelConnection2(lpLocalName,CONNECT_UPDATE_PROFILE,false);
    StrDispose(lpLocalName); StrDispose(lpRemoteName);
  end;
  DelStack;
end;

function DirXDel;
var cd: char;
begin
	AddStack('My_pr.DirXDel');
	cd:=StrToChar(TrimUpper(cdir));
  if cd in ['A','B'] then result:=XDel(cd+DriveDelim+PathDelim) else result:=true;
  DelStack;
end;

function XDel;
var i: longint;
  sr: TSearchRec;
  d,odir,ndir: string;
begin
  AddStack('My_pr.XDel');
  d:=CorrDir(cd); result:=DelMaskFiles(d+'*.*');
  if result then begin
    odir:='';
    while true do begin
      i:=FindFirst(d+'*.*',faDirectory,sr);
      while (i=0) and not NotSysDir(sr) do i:=FindNext(sr);
      SysUtils.FindClose(sr);
      if i=0 then begin
        ndir:=d+sr.Name+PathDelim;
        if ndir=odir then result:=false
        else begin
          odir:=ndir; result:=XDel(ndir);
        end;
        if not result then break;
      end
      else break;
    end;
    if result then
      if (CorrDir(ExtractFileDrive(d))<>d) and DirectoryExists(d) then result:=DirRemove(d);
  end;
  DelStack;
end;

function DirRemove;
begin
  AddStack('My_pr.DirRemove');
  FileClrAttr(cdir); result:=RemoveDir(cdir);
  DelStack;
end;

function IsFlopDrive;
var drv: string;
begin
	AddStack('My_pr.IsFlopDrive');
  drv:=ExtractFileDrive(dir); result := GetDriveType(PChar(drv))=DRIVE_REMOVABLE;
  if result then result:=InRange(MyDiskFree(drv,true),0,2000000);
  DelStack;
end;

function IsNetDrive;
begin
	AddStack('My_pr.IsNetDrive');
	result:=AnsiStartsStr('\\',dir);
  DelStack;
end;

function FileVerCopy;
const MaxBuf = 61440;
var buf: array[1..MaxBuf] of char;
  f: longint;
begin
  AddStack('My_pr.FileVerCopy');
  f:=FileBufOpen(FileName,fmShareDenyNone or fmOpenRead);
  if f<0 then result:=false
  else begin
    SetLastError(0);
    while FileRead(f,Buf,MaxBuf)>0 do;
    result := GetLastError=0;
  end;
  FileClose(f);
  DelStack;
end;

function DelFileAtr;
var FileOp: TSHFileOpStruct;
  fl: boolean;
  odir: string;
begin
  AddStack('My_pr.DelFileAtr');
  if lRecycle then begin
    odir:=GetCurrentDir; SetCurrentDir(ExtractFilePath(FileName));
    with FileOp do begin
      FillChar(FileOp,SizeOf(FileOp),0);
      Wnd:=Application.Handle; wFunc:=FO_DELETE; pFrom:=PChar(ExtractShortPathName(FileName));
      fFlags := FOF_ALLOWUNDO or FOF_NOERRORUI or FOF_SILENT or FOF_NOCONFIRMATION;
    end;
  end;
  for fl:=false to true do begin
    if fl then FileClrAttr(FileName);
    if lRecycle
    then result := (SHFileOperation(FileOp)=0) and (not FileOp.fAnyOperationsAborted)
    else result:=SysUtils.DeleteFile(FileName);
    if result then break;
  end;
  if lRecycle then SetCurrentDir(odir);
  DelStack;
end;

function RnmFileAtr;
begin
  AddStack('My_pr.RnmFileAtr');
  result:=RenameFile(OldName,NewName);
  if not result then begin
    DelFileAtr(NewName); result:=RenameFile(OldName,NewName);
    if not result then begin
      FileClrAttr(OldName); result:=RenameFile(OldName,NewName);
    end;
  end;
  DelStack;
end;

function MyFileExists;
begin
  AddStack('My_pr.MyFileExists');
  if DiskReady(FileName) then result:=FileExists(FileName) else result:=false;
  DelStack;
end;

procedure FSearchPath(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
begin
	AddStack('My_pr.FSearchPath');
  if (sr.Attr and faDirectory) = faDirectory
  then MaskFilesProc(av[0]+sr.Name+PathDelim+'*.*',
  	FSearchPath,[av[0]+sr.Name+PathDelim,av[1],av[2]],[fmFiles,fmDir])
  else MaxSelf(DateVar(av[2])^,FileDateToDateTime(sr.Time));
  DelStack;
end;

function SearchPath;
var d: TDateTime;
	ldir: boolean;
  procedure Srch(const cdir: TFileName);
  var fn: TFileName;
    d1: TDateTime;
  begin
    AddStack('My_pr.SearchPath.Srch');
    fn:=CorrDir(cdir)+f; d1:=0;
    if ldir then begin
    	if DirectoryExists(fn)
      then MaskFilesProc(fn+'*.*',FSearchPath,[fn,fn,LongInt(@d1)],[fmFiles,fmDir]);
    end
    else if MyFileExists(fn) then d1:=GetFileDateTime(fn);
    if d1>d then begin
      path:=fn; d:=d1;
    end;
    DelStack;
  end;
  procedure aSrch(const adir: TFileName);
  var i,l: longint;
    a: array[1..100] of string;
  begin
    AddStack('My_pr.SearchPath.aSrch');
    if not empty(adir) then begin
      l:=ListAsArray(adir,a,';');
      for i:=1 to l do Srch(a[i]);
    end;
    DelStack;
  end;
var fIni: TIniFileCheck;
  cod: string;
  function FSearchPathGGM(const pathDef: TFileName): boolean;
  begin
    AddStack('My_pr.SearchPath.FSearchPathGGM');
    path:=pathDef;
    if Assigned(SearchPathGGM) then SearchPathGGM(fIni,GGMUtilSectBeg+cod,pSearchPathGGM,path);
    result := path<>'';
    DelStack;
  end;
const aDrv: array[0..1] of char = ('C','D');
var dirggm: string;
  dir,f1,f2: TFileName;
  ls: TStringList;
  i,lReg: longint;
  j: byte;
  lRootDef: boolean;
  aReg: TArrStr;
  hk: HKEY;
begin
	AddStack('My_pr.SearchPath');
  if f<>'' then begin
    ldir := f[Length(f)]=PathDelim;
    dirggm:=GetRegKey(HKEY_LOCAL_MACHINE,REGSTR_PATH_GGMASTER,REGSTR_KEY_GGMASTER);
    if dirggm<>'' then begin
      CorrDirSelf(dirggm); fIni:=TIniFileCheck.Create(dirggm+GGMasterIniFile,nil,[finiNoDelOld],GGMasterExeFile);
      ls:=TStringList.Create;
      try
        fIni.ReadSectionValues(GGMUtilSect,ls); f1:=TrimUpper(f);
        if lDir then DecLen(f1) else ExtractFileNameSelf(f1);
        for i:=0 to ls.Count-1 do begin
          cod:=ls.ValueFromIndex[i];
          if ldir then begin
            f2:=fIni.ReadString(GGMUtilSectBeg+cod,GGMUtilDir);
            if f2<>'' then
              if TrimUpper(f2)=f1 then begin
                f2:=fIni.ReadString(GGMUtilSectBeg+cod,GGMUtilUserDir,f2);
                if empty(ExtractFileDrive(f2)) then IncL(f2,dirggm);
                if DirectoryExists(f2) then if FSearchPathGGM(f2+PathDelim) then break;
              end;
          end
          else begin
            if fIni.ValueExists(GGMUtilSectBeg+cod,GGMUtilRegDir)
            then lReg:=LsArrDynamic(CorrDir(StrTran(fIni.ReadString(GGMUtilSectBeg+cod,
              GGMUtilRegDir),'/',PathDelim,[rfReplaceAll,rfIgnoreCase]),crdrNoDlmEnd),aReg,PathDelim)
            else lReg:=0;
            if lReg>1 then begin
              hk:=GetRootKey(aReg[0],lRootDef); j:=1-Ord(lRootDef);
              dir:=GetRegKey(hk,ArrayAsList(aReg,PathDelim,lReg-j-1,false,j),aReg[lReg-1]);
              if fIni.ValueExists(GGMUtilSectBeg+cod,GGMUtilRegExe)
              then f2:=fIni.ReadString(GGMUtilSectBeg+cod,GGMUtilRegExe)
              else begin
                f2:=ExtractFileName(dir); ExtractFilePathSelf(dir);
              end;
            end
            else begin
              f2:=fIni.ReadString(GGMUtilSectBeg+cod,GGMUtilExeFile,cod+'.EXE');
              dir:=fIni.ReadString(GGMUtilSectBeg+cod,GGMUtilUserDir,
                fIni.ReadString(GGMUtilSectBeg+cod,GGMUtilDir));
            end;
            if TrimUpper(ExtractFileName(f2))=f1 then begin
              if empty(ExtractFileDrive(dir)) then IncL(dir,dirggm);
              IncL(f2,CorrDir(ExtractFilePath(CorrDir(dir))));
              if FileExists(f2) then if FSearchPathGGM(f2) then break;
            end;
          end;
        end;
      finally
        fIni.Free; ls.Free;
      end;
    end;
    if not OnlyInGGM and (path='') then begin
      d:=0; Srch(CurrentDir); Srch(ExeDir); aSrch(PathDop);
      aSrch(GetEnvironmentVariable('PATH'));
      for i:=low(aDrv) to high(aDrv) do Srch(aDrv[i]+DriveDelim+PathDelim+'GG'+PathDelim);
    end;
  end;
  result:=path<>'';
  DelStack;
end;

function SftpPath;
var dirggm,cod: string;
  fIni: TIniFileCheck;
  ls: TStringList;
  i: longint;
begin
  AddStack('My_pr.SftpPath');
  if not Assigned(PSftpPath) then begin
    PSftpPath:=NewString;
    dirggm:=GetRegKey(HKEY_LOCAL_MACHINE,REGSTR_PATH_GGMASTER,REGSTR_KEY_GGMASTER);
    if dirggm<>'' then begin
      CorrDirSelf(dirggm);
      fIni:=TIniFileCheck.Create(dirggm+GGMasterIniFile,nil,[finiNoDelOld],GGMasterExeFile); ls:=nil;
      try
        if fIni.ReadBool(GGMParamsSect,GGMParamsSmail) then
          if fIni.ReadBool(GGMParamsSect,GGMParamsSmRmt)
          then PSftpPath^:=fIni.ReadString(GGMParamsSect,GGMParamsSmRmtFold)
          else begin
            ls:=TStringList.Create; fIni.ReadSectionValues(GGMUtilSect,ls);
            for i:=0 to ls.Count-1 do begin
              cod:=ls.ValueFromIndex[i];
              if TrimUpper(cod)='SFTP' then begin
                PSftpPath^:=fIni.ReadString(GGMUtilSectBeg+cod,GGMUtilUserDir,
                  fIni.ReadString(GGMUtilSectBeg+cod,GGMUtilDir));
                if not empty(PSftpPath^) and empty(ExtractFileDrive(PSftpPath^))
                then IncL(PSftpPath^,dirggm);
                break;
              end;
            end;
          end;
        if empty(PSftpPath^) then PSftpPath^:=''
        else PSftpPath^:=CorrDir(PSftpPath^)+SmailDirClientSide+PathDelim;
      finally
        fIni.Free; ls.Free;
      end;
    end;
  end;
  result:=PSftpPath^;
  DelStack;
end;

procedure ProcNetRes;
const aLevel: array[RESOURCEDISPLAYTYPE_GENERIC..RESOURCEDISPLAYTYPE_NDSCONTAINER] of byte =
  (MaxByte,2,3,4,MaxByte,MaxByte,1,MaxByte,MaxByte,MaxByte,MaxByte,MaxByte);
//var lv: longint;
  function NetRes(lpnr: PNetResource): boolean;
  type
    TNetResourceArray = array[0..MaxInt div SizeOf(TNetResource) - 1] of TNetResource;
  var BufSize,NetResult: longint;
    NetHandle: THandle;
    Count,Size: LongWord;
    NetResources: ^TNetResourceArray;
    i: longint;
    Level: byte;
    //s: string;
  begin
  	AddStack('My_pr.ProcNetRes.NetRes');
    result:=true; NetResult:=WNetOpenEnum(dwScope,RESOURCETYPE_DISK,0,lpnr,NetHandle);
    if NetResult=NO_ERROR then
      try
        BufSize:=50*SizeOf(TNetResource); GetMem(NetResources,BufSize);
        try
          while True do
          begin
            Count:=$FFFFFFFF;
            Size:=BufSize;
            NetResult:=WNetEnumResource(NetHandle,Count,NetResources,Size);
            if NetResult=ERROR_MORE_DATA then begin
              BufSize:=Size;
              ReallocMem(NetResources,BufSize);
              Continue;
            end;
            if NetResult<>NO_ERROR then break;
            //s:=Space(lv); Inc(lv);
            Level:=0;
            if Assigned(lpnr) then Level:=aLevel[EnsureRange(lpnr.dwDisplayType,low(aLevel),high(aLevel))];
            for i:=0 to Count-1 do with NetResources[i] do begin
              {addmsgfile(s+ArrayAsList([StrPas(lpRemoteName),
                IfThen(dwScope=RESOURCE_CONNECTED,'RESOURCE_CONNECTED',
                IfThen(dwScope=RESOURCE_GLOBALNET,'RESOURCE_GLOBALNET',
                IfThen(dwScope=RESOURCE_REMEMBERED,'RESOURCE_REMEMBERED',
                IfThen(dwScope=RESOURCE_RECENT,'RESOURCE_RECENT',
                IfThen(dwScope=RESOURCE_CONTEXT,'RESOURCE_CONTEXT',
                IntToStr(dwScope)))))),
                IfThen(dwType=RESOURCETYPE_ANY,'RESOURCETYPE_ANY',
                IfThen(dwType=RESOURCETYPE_DISK,'RESOURCETYPE_DISK',
                IfThen(dwType=RESOURCETYPE_PRINT,'RESOURCETYPE_PRINT',
                IntToStr(dwType)))),
                IfThen(dwDisplayType=RESOURCEDISPLAYTYPE_DOMAIN,'RESOURCEDISPLAYTYPE_DOMAIN',
                IfThen(dwDisplayType=RESOURCEDISPLAYTYPE_GENERIC,'RESOURCEDISPLAYTYPE_GENERIC',
                IfThen(dwDisplayType=RESOURCEDISPLAYTYPE_SERVER,'RESOURCEDISPLAYTYPE_SERVER',
                IfThen(dwDisplayType=RESOURCEDISPLAYTYPE_SHARE,'RESOURCEDISPLAYTYPE_SHARE',
                IfThen(dwDisplayType=RESOURCEDISPLAYTYPE_FILE,'RESOURCEDISPLAYTYPE_FILE',
                IfThen(dwDisplayType=RESOURCEDISPLAYTYPE_GROUP,'RESOURCEDISPLAYTYPE_GROUP',
                IfThen(dwDisplayType=RESOURCEDISPLAYTYPE_NETWORK,'RESOURCEDISPLAYTYPE_NETWORK',
                IfThen(dwDisplayType=RESOURCEDISPLAYTYPE_ROOT,'RESOURCEDISPLAYTYPE_ROOT',
                IfThen(dwDisplayType=RESOURCEDISPLAYTYPE_SHAREADMIN,'RESOURCEDISPLAYTYPE_SHAREADMIN',
                IfThen(dwDisplayType=RESOURCEDISPLAYTYPE_DIRECTORY,'RESOURCEDISPLAYTYPE_DIRECTORY',
                IfThen(dwDisplayType=RESOURCEDISPLAYTYPE_TREE,'RESOURCEDISPLAYTYPE_TREE',
                IfThen(dwDisplayType=RESOURCEDISPLAYTYPE_NDSCONTAINER,'RESOURCEDISPLAYTYPE_NDSCONTAINER',
                IntToStr(dwDisplayType))))))))))))),
                IfThen(dwUsage=RESOURCEUSAGE_CONNECTABLE,'RESOURCEUSAGE_CONNECTABLE',
                IfThen(dwUsage=RESOURCEUSAGE_CONTAINER,'RESOURCEUSAGE_CONTAINER',
                IntToStr(dwUsage))),StrPas(lpComment),StrPas(lpProvider)],','));}
              if Level>=aLevel[EnsureRange(dwDisplayType,low(aLevel),high(aLevel))] then continue;
              if not Proc(av,NetResources[i]) then begin
              	result:=false; break;
              end;
              if RESOURCEUSAGE_CONTAINER=(dwUsage and RESOURCEUSAGE_CONTAINER) then
              	if not NetRes(@NetResources[i]) then begin
                  result:=false; break;
                end;
            end;
            //Dec(lv);
          end;
        finally
          FreeMem(NetResources,BufSize);
        end;
      finally
        WNetCloseEnum(NetHandle);
      end;
    DelStack;
  end;
begin
  AddStack('My_pr.ProcNetRes');
  //clrmsgfile; lv:=0;
  NetRes(NetResource);
  DelStack;
end;

function DrvLabel;
const MaxBuf = 12;
var lpVolumeNameBuffer,lpFileSystemNameBuffer: array[0..MaxBuf] of char;
  lpVolumeSerialNumber: longword;
  lpMaximumComponentLength,lpFileSystemFlags: longword;
begin
  AddStack('My_pr.DrvLabel');
  if GetVolumeInformation(PChar(ExtractFileDrive(drv)+PathDelim),lpVolumeNameBuffer,MaxBuf,@lpVolumeSerialNumber,
  lpMaximumComponentLength,lpFileSystemFlags,lpFileSystemNameBuffer,MaxBuf)
    then result:=lpVolumeNameBuffer else result:='';
  DelStack;
end;

procedure GetDriveList;
const MaxBuf = 1000;
var Buf: PChar;
begin
  AddStack('My_pr.GetDriveList');
  Buf:=StrAlloc(MaxBuf+1);
  try
    GetLogicalDriveStrings(MaxBuf,Buf); PCharLsStr(Buf,ls,lClear);
  finally
    StrDispose(Buf);
  end;
  DelStack;
end;

procedure Path2Arr;
var i: longint;
begin
  AddStack('My_pr.Path2Arr');
  for i:=0 to LsArrDynamic(path,a,PathSep,lsaSetLen)-1 do CorrDirSelf(a[i]);
  DelStack;
end;

procedure DirectoryView;
var p: TFileName;
begin
  AddStack('My_pr.DirectoryView');
  p:=CorrDir(path,crdrNoDlmEnd);
  if p='' then mess_ok(['Не указано имя папки для просмотра.'])
  else begin
    if not DirectoryExists(p) then
      if Pos(PathDelim,p)=0 then mess_ok(['Отсутствует папка:',path])
      else if Ask(['Отсутствует папка:',path,'Перейти к первой существующей родительской папке ?']) then
        repeat
          SetLength(p,RPos(PathDelim,p)-1);
        until (p='') or DirectoryExists(p)
      else p:='';
    if p<>'' then ShellExecute(0,nil,PChar(p),nil,nil,SW_SHOW);
  end;
  DelStack;
end;

procedure ExtractFilePathSelf;
begin
  fn:=ExtractFilePath(fn);
end;

procedure ExtractFileDriveSelf;
begin
  fn:=ExtractFileDrive(fn);
end;

procedure ExtractFileNameSelf;
begin
  fn:=ExtractFileName(fn);
end;

function win2comp;
var	l1,t1,r1,b1,l2,t2,r2,b2: boolean;
begin
	AddStack('My_pr.win2comp');
  l1 := ((tr1.Left  >=tr2.Left) and (tr1.Left  <=tr2.Right));
  t1 := ((tr1.Top   >=tr2.Top)  and (tr1.Top   <=tr2.Bottom));
  r1 := ((tr1.Right >=tr2.Left) and (tr1.Right <=tr2.Right));
  b1 := ((tr1.Bottom>=tr2.Top)  and (tr1.Bottom<=tr2.Bottom));
  l2 := ((tr2.Left  >=tr1.Left) and (tr2.Left  <=tr1.Right));
  t2 := ((tr2.Top   >=tr1.Top)  and (tr2.Top   <=tr1.Bottom));
  r2 := ((tr2.Right >=tr1.Left) and (tr2.Right <=tr1.Right));
  b2 := ((tr2.Bottom>=tr1.Top)  and (tr2.Bottom<=tr1.Bottom));
  result := ((l1 and t1) or (l1 and b1) or (r1 and t1) or (r1 and b1)
  	or (l2 and t2) or (l2 and b2) or (r2 and t2) or (r2 and b2)
    or (l1 and r1 and t2 and b2) or (l2 and r2 and t1 and b1));
  DelStack;
end;

type TNpozList = (npozNone,npozNW,npozN,npozNE,npozE,npozSE,npozS,npozSW,npozW);

function IfThen(AValue: boolean; ATrue,AFalse: TNpozList): TNpozList; overload;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

var
	MDown: boolean;
  npoz: TNpozList;
  oX,oY,oW,oH: longint;
  bev: TPanel;
const
	dmax = 15;
  dmin = 5;

procedure RszMouseDown;
var tc: TControl;
begin
	AddStack('My_pr.RszMouseDown');
  tc:=pointer(Sender);
	if (not MDown) and (Button=mbLeft)
  and (((rmResize in Opt) and ((X<dmin) or (tc.Width-X<dmin)
  or (Y<dmin) or (tc.Height-Y<dmin))) or (rmRemove in Opt)) then begin
   	MDown:=true; oX:=X;	oY:=Y;
    tc.Visible:=false; oW:=tc.Width; oH:=tc.Height;
    bev:=TPanel.Create(tc.Owner);
    with bev do begin
    	Hide; Parent:=tc.Parent; BevelWidth:=2; BevelInner:=bvLowered; BevelOuter:=bvRaised;
      SetBounds(Left,Top,Width,Height);
    end;
  end;
  DelStack;
end;

procedure RszMouseMove;
const a: array[TNpozList] of TCursor =
  (crDefault,crSizeNWSE,crSizeNS,crSizeNESW,crSizeWE,crSizeNWSE,crSizeNS,crSizeNESW,crSizeWE);
begin
	AddStack('My_pr.RszMouseMove');
  if Opt<>[] then with TControl(Sender) do
		if MDown then begin
      case npoz of
        npozNone: if rmRemove in Opt then
                SetBounds(Left+X-oX,Top+Y-oY,Width     ,Height);
        npozNW: SetBounds(Left+X-oX,Top+Y-oY,Width-X+oX,Height-Y+oY);
        npozN : SetBounds(Left     ,Top+Y-oY,Width     ,Height-Y+oY);
        npozNE: SetBounds(Left     ,Top+Y-oY,oW+X-oX   ,Height-Y+oY);
        npozE : Width:=                      oW+X-oX;
        npozSE: SetBounds(Left     ,Top     ,oW+X-oX   ,oH+Y-oY);
        npozS : Height:=                                oH+Y-oY;
        npozSW: SetBounds(Left+X-oX,Top     ,Width-X+oX,oH+Y-oY);
        npozW : SetBounds(Left+X-oX,Top     ,Width-X+oX,Height);
      end;
      bev.SetBounds(Left,Top,Width,Height); bev.Show; bev.BringToFront;
    end
   	else begin
      npoz:=npozNone;
      if rmResize in Opt then begin
        if X<dmin then npoz:=IfThen(Y<dmax,npozNW,IfThen(Height-Y<dmax,npozSW,npozW));
        if Width-X<dmin then npoz:=IfThen(Y<dmax,npozNE,IfThen(Height-Y<dmax,npozSE,npozE));
        if Y<dmin then npoz:=IfThen(X<dmax,npozNW,IfThen(Width-X<dmax,npozNE,npozN));
        if Height-Y<dmin then npoz:=IfThen(X<dmax,npozSW,IfThen(Width-X<dmax,npozSE,npozS));
      end;
      Cursor:=IfThen((rmRemove in Opt) and (npoz=npozNone),crDrag,a[npoz]);
    end;
  DelStack;
end;

function RszMouseUp;
begin
	AddStack('My_pr.RszMouseUp');
	if MDown and (Button=mbLeft) and (Opt<>[]) then begin
  	bev.Free; TControl(Sender).Visible:=true;	MDown:=false;
    if npoz=npozNone then result:=[rmRemove] else result:=[rmResize];
  end
  else result:=[];
  DelStack;
end;

function ClrScroll;
  procedure Add(Sender: TComponent);
  var i: longint;
  begin
    AddStack('My_pr.ClrScroll.Add');
    if Sender is TScrollingWinControl then with TScrollingWinControl(Sender),result do begin
      i:=Length(aobj); SetLength(aobj,i+1); aobj[i].obj:=pointer(Sender);
      aobj[i].HorzVisible:=HorzScrollBar.Visible; aobj[i].HorzPos:=HorzScrollBar.Position;
      aobj[i].VertVisible:=VertScrollBar.Visible; aobj[i].VertPos:=VertScrollBar.Position;
      ShowScrollBar(aobj[i].obj.Handle,SB_BOTH,false);
      aobj[i].obj.HorzScrollBar.Visible:=false; aobj[i].obj.VertScrollBar.Visible:=false;
    end;
    DelStack;
  end;
var f: TForm;
  i: longint;
begin
	AddStack('My_pr.ClrScroll');
	result.aobj:=nil;
  if ParentForm(Sender,f) then with f do begin
    result.WindowState:=WindowState; result.Autoscroll:=Autoscroll; Autoscroll:=false; Add(f);
    for i:=0 to ComponentCount-1 do Add(Components[i]);
  end;
  DelStack;
end;

procedure SetScroll;
var f: TForm;
  i: longint;
begin
	AddStack('My_pr.SetScroll');
  if ParentForm(Sender,f) then with f do begin
    Autoscroll:=Sc.Autoscroll; 
    for i:=low(Sc.aobj) to high(Sc.aobj) do with Sc.aobj[i] do begin
      obj.HorzScrollBar.Visible:=HorzVisible; obj.HorzScrollBar.Position:=HorzPos;
      obj.VertScrollBar.Visible:=VertVisible; obj.VertScrollBar.Position:=VertPos;
    end;
    if not Visible then WindowState:=Sc.WindowState;
  end;
  DelStack;
end;

procedure SetRedraw(Sender: TWinControl; Opt: TSetRedrawOpt = []);
	function Set1(tc: TControl): boolean;
  begin
  	AddStack('My_pr.SetRedraw.Set1');
    result:=tc.Visible;
    if result then result := tc.perform(WM_NOSETREDRAW,0,0)=0;
    if result then begin
      tc.perform(WM_SETREDRAW,Ord(rdrwSet in Opt),0);
      if not(rdrwNoPaint in Opt) then tc.Invalidate;
    end;
    DelStack;
  end;
var i: longint;
  tc: TControl;
begin
	AddStack('My_pr.SetRedraw');
  SetRedrawOptCor(Opt);
  if Set1(Sender) then for i:=0 to CtrlInfCount(Sender)-1 do begin
    tc:=CtrlInfItem(Sender,i);
    if tc is TWinControl then SetRedraw(TWinControl(tc),Opt) else Set1(tc);
  end;
  DelStack;
end;

procedure SetRedraw(Sender: TWinControl; Opt: TSetRedrawList);
begin
  SetRedraw(Sender,[Opt]);
end;

procedure SetRedrawOptCor(var Opt: TSetRedrawOpt);
begin
  if rdrwNoPaint in Opt then Include(Opt,rdrwSet);
end;

procedure InvalidateAll;
	function Pnt1(tc: TControl): boolean;
  begin
  	AddStack('My_pr.InvalidateAll.Pnt1');
    result:=tc.Visible;
    if result then tc.Invalidate;
  	{with tc do begin
      Repaint; Refresh; Update;
      tc.Invalidate;
    end;}
    DelStack;
  end;
var i: longint;
  tc: TControl;
begin
	AddStack('My_pr.InvalidateAll');
  if Pnt1(Sender) then for i:=0 to CtrlInfCount(Sender)-1 do begin
    tc:=CtrlInfItem(Sender,i);
    if tc is TWinControl
    then InvalidateAll(pointer(tc))
    else Pnt1(tc);
  end;
  DelStack;
end;

function FormOnScreen;
var r: TRect;
  w: longint;
begin
	AddStack('My_pr.FormOnScreen');
  r:=SysWorkArea;
	{with f do begin
    SetBounds(Left,Top,min(Width,r.Right-r.Left),min(Height,r.Bottom-r.Top));
    SetBounds(min(Left,r.Right-Width),min(Top,r.Bottom-Height),Width,Height);
    SetBounds(max(Left,r.Left),max(Top,r.Top),Width,Height);
  end;}
  result.length:=SizeOf(result); GetWindowPlacement(f.Handle,@result);
  if not f.Visible then result.showCmd:=SW_HIDE;
  with result.rcNormalPosition do begin
  	MaxSelf(Right,Left); w:=max(0,Right-r.Right); Dec(Right,w); Left:=max(r.Left,Left-w);
  	MaxSelf(Bottom,Top); w:=max(0,Bottom-r.Bottom); Dec(Bottom,w); Top:=max(r.Top,Top-w);
  end;
  SetWindowPlacement(f.Handle,@result);
  DelStack;
end;

function ParentForm(Control: TControl): TForm;
var f: TCustomForm;
begin
	AddStack('My_pr.ParentForm');
	result:=nil; f:=GetParentForm(Control);
  if Assigned(f) then if f is TForm then result:=pointer(f);
  DelStack;
end;

function ParentForm(Control: TControl; var f: TForm): boolean;
begin
  f:=ParentForm(Control); result:=Assigned(f);
end;

function CreateShow;
begin
	AddStack('My_pr.CreateShow');
	CreateForm(FormClass,Reference,false); result:=TForm(Reference).ShowModal;
  if lFree then FormFree(Reference);
  DelStack;
end;

function MinWidthForm;
  procedure LogFontToFont(const LogFont: TLogFont);
  var Style: TFontStyles;
  begin
    AddStack('My_pr.MinWidthForm.LogFontToFont');
    with LogFont,f.Canvas do begin
      Font.Name:=lfFaceName;
      Font.Height:=lfHeight;
      Font.Charset:=TFontCharset(lfCharSet);
      Style:=[];
      if lfWeight>FW_REGULAR then Include(Style,fsBold);
      if lfItalic<>0 then Include(Style,fsItalic);
      if lfUnderline<>0 then Include(Style,fsUnderline);
      if lfStrikeOut<>0 then Include(Style,fsStrikeOut);
      Font.Style:=Style;
    end;
    DelStack;
  end;
var w: longint;
begin
	AddStack('My_pr.MinWidthForm');
  if f.BorderStyle=bsNone then result:=0
  else begin
    if f.BorderStyle in [bsSizeToolWin,bsToolWindow]
    then LogFontToFont(SysMetric.lfSmCaptionFont)
    else LogFontToFont(SysMetric.lfCaptionFont);
    result:=f.Canvas.TextWidth(f.Caption)+15;
    if biSystemMenu in f.BorderIcons then begin
    	w:=GetSystemMetrics(IfThen(f.BorderStyle in [bsSizeToolWin,bsToolWindow],
      	SM_CXSMSIZE,SM_CXSIZE));
      Inc(result,w);
      if (f.BorderStyle=bsDialog) and (biHelp in f.BorderIcons) then Inc(result,w);
      if f.BorderStyle in [bsSingle,bsSizeable] then begin
        Inc(result,GetSystemMetrics(SM_CXSMICON)+4);
        if (biMinimize in f.BorderIcons) or (biMaximize in f.BorderIcons) then Inc(result,w*2);
      end;
    end;
  end;
  DelStack;
end;

function VisibleNoNil(Sender: TControl): boolean;
begin
  AddStack('My_pr.VisibleNoNil(TControl)');
  if Assigned(Sender) then result:=Sender.Visible else result:=false;
  DelStack;
end;

function VisibleNoNil(Sender: TField): boolean;
begin
  AddStack('My_pr.VisibleNoNil(TField)');
  if Assigned(Sender) then result:=Sender.Visible else result:=false;
  DelStack;
end;

procedure ProcControls;
var i: longint;
  Done: boolean;
  tw: TWinControl;
begin
  AddStack('My_pr.ProcControls');
  Done:=true; Proc(Sender,av,Done);
  if Done and IsClass(Sender,TWinControl,pointer(tw)) then
    for i:=0 to CtrlInfCount(tw)-1 do ProcControls(CtrlInfItem(tw,i),Proc,av);
  DelStack;
end;

procedure FProcControlsVisible(Sender: TControl; const av: array of variant; var Done: boolean);
begin
  AddStack('My_pr.FProcControlsVisible');
  if Sender is TTabSheet then TTabSheet(Sender).TabVisible:=av[0] else Sender.Visible:=av[0];
  DelStack;
end;

procedure ProcControlsVisible;
begin
  AddStack('My_pr.ProcControlsVisible');
  ProcControls(Sender,FProcControlsVisible,[Visible]);
  DelStack;
end;

procedure FProcControlsMsg(Sender: TControl; const av: array of variant; var Done: boolean);
begin
  AddStack('My_pr.FProcControlsMsg');
  Sender.Perform(av[0],av[1],av[2]);
  if av[3] then Done:=false;
  DelStack;
end;

procedure ProcControlsMsg;
begin
  AddStack('My_pr.ProcControlsMsg');
  ProcControls(Sender,FProcControlsMsg,[Msg,WParam,LParam,Level1]);
  DelStack;
end;

procedure SetVisibles;
var i: longint;
begin
  AddStack('My_pr.SetVisibles');
  for i:=low(Controls) to high(Controls) do Controls[i].Visible:=Value;
  DelStack;
end;

function SysMetric;
begin
	AddStack('My_pr.SysMetric');
  result.cbSize:=SizeOf(result);
  SystemParametersInfo(SPI_GETNONCLIENTMETRICS,result.cbSize,@result,0);
  DelStack;
end;

function SysWorkArea;
begin
	AddStack('My_pr.SysWorkArea');
	SystemParametersInfo(SPI_GETWORKAREA,0,@result,0); UserWorkArea(result);
  DelStack;
end;

function UserWorkArea;
begin
  AddStack('My_pr.UserWorkArea');
  result:=Assigned(PUserWorkArea);
  if result then with PUserWorkArea^ do begin
  	MaxSelf(r.Top,Top); MinSelf(r.Bottom,Bottom);
    MaxSelf(r.Left,Left); MinSelf(r.Right,Right);
  end;
  DelStack;
end;

{procedure EnviromentLsStr(ls: TStringList);
begin
	AddStack('My_pr.EnviromentLsStr');
	PCharLsStr(GetEnvironmentStrings,ls);
  DelStack;
end;}

function GetExeInfo;
var VerBuf,Buf: Pointer;
  VerSize: longword;
  function StrPrm(const nm: string): boolean;
  begin
  	AddStack('My_pr.GetExeInfo.StrPrm');
  	result:=VerQueryValue(VerBuf,PChar('\StringFileInfo\041904E3\'+nm),Buf,VerSize);
    DelStack;
  end;
var s,FileName: string;
  n: longint;
  InfoSize,Wnd: longword;
  FI: PVSFixedFileInfo;
  lSelf: boolean;
begin
	AddStack('My_pr.GetExeInfo');
  lSelf := cFileName='';
  if lSelf then begin
    s:=''; FileName:=Application.ExeName;
  end
  else begin
    s:=cFileName; FileName:=s;
    if MyFileExists(s) then IncD(s,'*'+FormatDateTime('yyyymmddhhnnsszzz',GetFileDateTime(s)));
  end;
  if not Assigned(lsExeInfo) then begin
    lsExeInfo:=SortStrListCreate; SetLength(aExeInfo,1);
  end;
  if IntObjFindAdd(lsExeInfo,s,n) then result:=@aExeInfo[n]
  else begin
    if Length(aExeInfo)=n then SetLength(aExeInfo,n shl 1);
    result:=@aExeInfo[n]; Finalize(result^); ZeroMemory(result,SizeOf(result^)); 
    with result^ do begin
      IsGGI:=true; InfoSize:=GetFileVersionInfoSize(PChar(FileName),Wnd);
      if InfoSize<>0 then begin
        GetMem(VerBuf,InfoSize);
        try
          if GetFileVersionInfo(PChar(FileName),Wnd,InfoSize,VerBuf) then
            if VerQueryValue(VerBuf,'\',Pointer(FI),VerSize) then begin
              Major:=HiWord(FI.dwFileVersionMS);
              Minor:=FI.dwFileVersionMS;
              Release:=HiWord(FI.dwFileVersionLS);
              Build:=FI.dwFileVersionLS;
            end;
          VerSize:=100;
          if StrPrm('ProductName') then ProductName:=StrPas(Buf);
          if StrPrm('GGRegVers') then RegVers:=StrPas(Buf);
          if StrPrm('GGMainVers') then MainVers:=StrPas(Buf);
          if not lSelf then
            if StrPrm('GGI') then IsGGI:=not empty(StrPas(Buf)) else IsGGI:=false;
        finally
          FreeMem(VerBuf);
        end;
      end;
    end;
  end;
  DelStack;
end;

function StrExeVersion;
begin
	AddStack('My_pr.StrExeVersion');
	with GetExeInfo(cFileName)^ do result:=Format('%d.%d.%d.%d',[Major,Minor,Release,Build]);
  DelStack;
end;

function GRegistry;
begin
  AddStack('My_pr.GRegistry');
  if not Assigned(Reg) then Reg:=TRegistry.Create;
  result:=Reg;
  DelStack;
end;

function GetRegKey;
begin
  AddStack('My_pr.GetRegKey');
  with GRegistry do begin
    RootKey:=Root;
    if OpenKeyReadOnly(Key) then result:=ReadString(Name) else result:='';
    CloseKey;
  end;
  DelStack;
end;

function GetRootKey;
var i: longint;
  nm: string;
begin
  nm:=AnsiUpperCase(aKey); isHkeyMissing:=true; result:=HKEY_LOCAL_MACHINE;
  for i:=low(aRegRootKey) to high(aRegRootKey) do with aRegRootKey[i] do
    if Name=nm then begin
      isHkeyMissing:=false; result:=Key; break;
    end;
end;

type
  TGetIpAddrTable = function (pIpAddrTable: Pointer; pdwSize: PULONG; bOrder: BOOL): longword; stdcall;

//function GetIpAddrTable(pIpAddrTable: Pointer; pdwSize: PULONG; bOrder: BOOL): longword; stdcall; external 'iphlpapi.dll' name 'GetIpAddrTable';
//function GetTcpTable(pTcpTable: Pointer; pdwSize: PULONG; bOrder: BOOL): longword; stdcall; external 'iphlpapi.dll' name 'GetTcpTable';

function GetIpAddress;
	{function ntoa(addr: longword): string;
  begin
    AddStack('My_pr.GetIpAddress.ntoa');
    result:=inet_ntoa(TInAddr(addr));
    DelStack;
  end;}
var pdwSize: ULONG;
	pa: PIPTbl;
  i: longint;
  s: string;
  m: HMODULE;
  giat: TGetIpAddrTable;
begin
  AddStack('My_pr.GetIpAddress');
  result:=''; m:=LoadLibrary('iphlpapi.dll');
  if m<>0 then begin
    try
      giat:=GetProcAddress(m,'GetIpAddrTable');
      if Assigned(giat) then begin
        pdwSize:=0;
        if giat(nil,@pdwSize,false)=ERROR_INSUFFICIENT_BUFFER then begin
          GetMem(pa,pdwSize);
          try
            if giat(pa,@pdwSize,false)=NO_ERROR then
              for i:=0 to pa.dwNumEntries-1 do begin
                s:=inet_ntoa(TInAddr(pa.a[i].dwAddr));
                if (s<>'127.0.0.1') and (s<>'0.0.0.0') then begin
                  result:=s; break;
                end;
              end;
          finally
            FreeMem(pa);
          end;
        end;
      end;
    finally
      FreeLibrary(m);
    end;
  end;
  {i:=GetTcpTable(nil,@pdwSize,false);
  if i=ERROR_INSUFFICIENT_BUFFER then begin
    GetMem(pa,pdwSize);
    try
    	i:=GetTcpTable(pa,@pdwSize,false);
      if i=NO_ERROR then
        for i:=0 to pa.dwNumEntries-1 do begin
          result:=ntoa(pa.a[i].dwLocalAddr);
        end;
    finally
      FreeMem(pa);
    end;
  end;}
  { Для Windows'95 (возможно)
  with GRegistry do begin
    RootKey:=HKEY_LOCAL_MACHINE; noTCP:=true; t:='';
    if OpenKeyReadOnly(NetTrans) then begin
      GetKeyNames(ls); CloseKey;
      for i:=0 to ls.Count-1 do
        if OpenKeyReadOnly(NetTrans+'\'+ls[i]) then begin
          if TrimUpper(ReadString('DriverDesc'))='TCP/IP' then begin
            noTCP:=false; LsArrFill(ReadString('IPAddress'),a,'.');
            for j:=low(a) to high(a) do
              if Int0(a[j])>0 then begin
                t:=StrTran(ArrayAsList(a,'.'),' '); break;
              end;
          end;
          CloseKey;
          if t<>'' then break;
        end;
    end;
  end;}
  DelStack;
end;

function IsSrvLocal;
  function ip2card(const aIp: string; out riz: longword): boolean;
  var sa: TArrStr;
      a,b,c,d: longint;
  begin
    result:=false;
    if LsArrDynamic(aIp,sa,'.')=4 then begin
      TrimSelf(sa);
      a:=StrToIntDef(sa[0],NegDef);
      b:=StrToIntDef(sa[1],NegDef);
      c:=StrToIntDef(sa[2],NegDef);
      d:=StrToIntDef(sa[3],NegDef);
      if ((a in [0..MaxByte])and(b in [0..MaxByte])and(c in [0..MaxByte])and(d in [0..MaxByte])) then begin
        result:=true;
        riz:=(a shl 24) or (b shl 16) or (c shl 8) or d;
      end;
    end;
  end;
var s: string;
    b: boolean;
    sa: TArrStr;
    x,y: longword;
    k: longint;
begin
  s:=StrDivDlm('/',TrimUpper(aSrv))[1]; result := s='LOCALHOST';
  if (not result) then begin
    b:=(ip2card(s,x));
    if (not b) then begin
      if (ip2card(Host2Ip(s),x)) then b:=true;
    end;
    if (b) then begin
      sa:=GetIpsStr;
      k:=length(sa);
      SetLength(sa,k+1);
      sa[k]:='127.0.0.1';
      for k:=0 to high(sa) do begin
        if (not ip2card(sa[k],y)) then continue;
        if (x<>y) then continue;
        result:=true;
        break;
      end;(* for k *)
    end;
  end;
end;

procedure GetIps;
var giat: TGetIpAddrTable;
  m: HMODULE;
  s: string;
  pa: PIPTbl;
  pdwSize: ULONG;
  k,j: longint;
  sl: TIntegerList;
begin
  ani:=nil;
  m:=LoadLibrary('iphlpapi.dll');
  if (m<>0) then begin
    try
      giat:=GetProcAddress(m,'GetIpAddrTable');
      if (Assigned(giat)) then begin
        pdwSize:=0;
        if (giat(nil,@pdwSize,false)=ERROR_INSUFFICIENT_BUFFER) then begin
          GetMem(pa,pdwSize);
          try
            if (giat(pa,@pdwSize,false)=NO_ERROR) then begin
              sl:=TIntegerList.Create([ilsSorted,ilsUnSigned]);
              try
                for k:=0 to pa.dwNumEntries-1 do begin
                  s:=inet_ntoa(TInAddr(pa.a[k].dwAddr));
                  if (s='127.0.0.1')or(s='0.0.0.0') then continue;
                  if sl.IgnoreFindAdd(pa.a[k].dwIndex) then continue;
                  j:=length(ani);
                  SetLength(ani,j+1);
                  ani[j].niAddr:=pa.a[k].dwAddr;
                  ani[j].niMask:=pa.a[k].dwMask;
                  ani[j].niAddrStr:=s;
                  ani[j].niBroadcast:=inet_ntoa(TInAddr(pa.a[k].dwAddr or (not pa.a[k].dwMask)));
                end;(* for k *)
              finally
                sl.Free;
              end;
            end;
          finally
            FreeMem(pa);
          end;
        end;
      end;
    finally
      FreeLibrary(m);
    end;
  end;
end;

function GetIpsStr;
var ani: TANI;
    k: longint;
begin
  GetIps(ani);
  k:=length(ani);
  SetLength(result,k);
  for k:=0 to k-1 do begin
    result[k]:=ani[k].niAddrStr;
  end;(* for k *)
end;

function Host2Ip;
var
  R: longint;
  WSAData: TWSAData;
  HostEnt: PHostEnt;
  Host: string;
  SockAddr: TSockAddrIn;
begin
  Result:=''; R:=WSAStartup(MakeWord(1,1),WSAData);
  if R=0 then
    try
      Host:=HostName;
      if Host='' then begin
        SetLength(Host,MAX_PATH); GetHostName(PChar(Host),MAX_PATH);
      end;
      HostEnt:=GetHostByName(PChar(Host));
      if HostEnt<>nil then begin
        SockAddr.sin_addr.S_addr:=Longint(PLongint(HostEnt^.h_addr_list^)^);
        Result:=inet_ntoa(SockAddr.sin_addr);
      end;
    finally
      WSACleanup;
    end;
end;

function IPSpaceStr(const s: string): string;
var i: longint;
  a: array[1..4] of string;
begin
  AddStack('My_pr.IPSpaceStr');
  LsArrFill(s,a,'.');
  for i:=low(a) to high(a) do Spacestr0Self(a[i],3);
  result:=ArrayAsList(a,'.');
  DelStack;
end;

function CompName;
begin
  AddStack('My_pr.CompName');
  result:=DosToWin(GetRegKey(HKEY_LOCAL_MACHINE,REGSTR_PATH_COMPUTRNAME,REGSTR_VAL_COMPUTRNAME));
  DelStack;
end;

{$IFDEF MSWINDOWS}
function GetEnvironmentVariable;
var
  Len: longint;
begin
  Len:=Windows.GetEnvironmentVariable(PChar(Name),nil,0);
  if Len>1 then begin
    SetLength(Result,Len-1); Windows.GetEnvironmentVariable(PChar(Name),PChar(Result),Len);
  end
  else Result:='';
end;
{$ENDIF}

function GetUserGG;
begin
  AddStack('My_pr.GetUserGG');
  if not Assigned(pnUserGG) then begin
    New(pnUserGG); pnUserGG^:=Int0(GetEnvironmentVariable('GG'));
  end;
  if pnUserGG^<>0 then
    if not CanPriv(PrivDesign) then pnUserGG^:=0;
  if Assigned(nUserGGProc) then nUserGGProc(pnUserGG^);
  result:=pnUserGG^;
  DelStack;
end;

procedure SetUserGG;
begin
  AddStack('My_pr.SetUserGG');
  if not Assigned(pnUserGG) then New(pnUserGG);
  pnUserGG^:=Value;
  DelStack;
end;

function IsUserGG;
begin
  AddStack('My_pr.IsUserGG');
  result := GetUserGG>0;
  DelStack;
end;

function CanPriv;
begin
  AddStack('My_pr.CanPriv');
  result:=Default;
  if Priv<>'' then IfThenPrivProc(PrivProc,Priv,result);
  DelStack;
end;

function IsWow64Process;
begin
  AddStack('My_pr.IsWow64Process');
  result:=false;
  if Assigned(pIsWow64Process) then result:=pIsWow64Process(GetCurrentProcess,@result) and result;
  DelStack;
end;

function IsGGI;
var path: string;
begin
  AddStack('My_pr.IsGGI');
  path:=ExtractFilePath(FileName);
  if (ExeName='') and (AnsiUpperCase(path)=AnsiUpperCase(ExtractFilePath(Application.ExeName)))
  then result:=true
  else begin
    if ExeName='' then IncD(path,ExeMenu)
    else if ExtractFilePath(ExeName)='' then IncD(path,ExeName)
    else path:=ExeName;
    result:=GetExeInfo(path).IsGGI;
  end;
  DelStack;
end;

function TimeZoneBias;
const aSign: TArrBoolChr = ('+','-');
var TimeZone: TTimeZoneInformation;
  d: Double;
  h: longint;
begin
  AddStack('My_pr.TimeZoneBias');
  GetTimeZoneInformation(TimeZone); d:=TimeZone.Bias/-MinsPerHour; h:=trunc(d);
  result:=aSign[h<0]+NumStr(h,2)+':'+NumStr((d-h)*MinsPerHour,2);
  DelStack;
end;

function SeekColor(cl: TColor; FullSeek: boolean = true): T16Colors;
var i: T16Colors;
	l,l1: LongInt;
  fl: boolean;
begin
	AddStack('My_pr.SeekColor');
  result:=0;
  if FullSeek then fl:=not SeekColor(cl,result) else fl:=true;
  if fl then begin
    cl:=ColorToRGB(cl); l:=MaxLongInt;
    for i:=low(AColor) to 15 do begin
      l1:=Abs(AColor[i]-cl);
      if l1<l then begin
        l:=l1; result:=i;
      end;
    end;
  end;
  DelStack;
end;

function SeekColor(cl: TColor; var cl16: T16Colors): boolean;
var i: T16Colors;
begin
  AddStack('My_pr.SeekColor');
  result:=false;
  for i:=low(AColor) to high(AColor) do
  	if AColor[i]=cl then begin
    	cl16:=i; result:=true; break;
    end;
  DelStack;
end;

function InvColor;
begin
	AddStack('My_pr.InvColor');
	result:=AColor[15-SeekColor(cl,false)];
  DelStack;
end;

procedure InvColorSelf(var cl: TColor);
begin
  cl:=InvColor(cl);
end;

procedure InvColorSelf(Font: TFont);
begin
  Font.Color:=InvColor(Font.Color);
end;

procedure InvColorSelf(Brush: TBrush);
begin
  Brush.Color:=InvColor(Brush.Color);
end;

function FontInf;
var ost: longint;
begin
	ost:=AddStack('My_pr.FontInf');
	try
  	if Assigned(Font) then with Font do result:=StrNum(Trim(Name)+' (',Size)
      +IfThen(fsBold in Style,',Ж')+IfThen(fsItalic in Style,',К')+')'
    else result:='';
  except
  	on EAccessViolation do SetStack(ost);
  end;
  PadRSelf(result,LF_FACESIZE+8);
  DelStack;
end;

function FontToStr;
var f: TDefFont;
begin
  AddStack('My_pr.FontToStr');
  FontToDefFont(Font,f); result:=DefFontToStr(f);
  DelStack;
end;

function DefFontToStr;
begin
	AddStack('My_pr.DefFontToStr');
  result:=PointerToStr(@DefFont,lDefFont);
  DelStack;
end;

function StrToDefFont;
begin
	AddStack('My_pr.StrToDefFont');
  StrToPointer(s,lDefFont,@result);
  DelStack;
end;

{procedure GetRegFont(Font: TFont; Root: HKEY; Key,Name: string);
var st: TFontStyles;
  reg: TRegistry;
  buf: array[0..$32] of Char;
  i: longint;
  s: string;
begin
  reg:=TRegistry.Create; reg.RootKey:=Root;
  if reg.OpenKey(Key,false) then begin
    reg.ReadBinaryData(Name,buf,SizeOf(buf));
    with Font do begin
      s:='';
      for i:=$12 to high(buf) do
        if buf[i]=#0 then break
        else IncD(s,buf[i]);
      Name:=s; Size:=Ord(buf[0]); st:=[];
      if Ord(buf[$08])=$BC then Include(st,fsBold);
      if Ord(buf[$0A])=$01 then Include(st,fsItalic);
      Style:=st;
    end;
  end
  else DefaultFont(Font);
  reg.Free;
end;}

procedure FGetFont(Font: TFont; const DefFont: TDefFont; FontSize: longint);
begin
	AddStack('My_pr.FGetFont');
	with DefFont do begin
  	Font.Name:=Name; Font.Color:=Color; Font.Size:=IfThen(FontSize=0,Size,FontSize);
  	Font.Style:=Style; Font.CharSet:=CharSet;
  end;
  DelStack;
end;

procedure DefaultFont;
begin
	AddStack('My_pr.DefaultFont');
	FGetFont(Font,GDefFont,FontSize);
  DelStack;
end;

{procedure Font866;
begin
	FGetFont(Font,GFont866,FontSize);
end;}

procedure DefFontToFont;
begin
	AddStack('My_pr.DefFontToFont');
  with DefFont do begin
    Font.Name:=Name; Font.Color:=Color; Font.Size:=Size; Font.Style:=Style; Font.Charset:=CharSet;
  end;
  DelStack;
end;

procedure FontToDefFont;
begin
	AddStack('My_pr.FontToDefFont');
  ZeroMemory(@DefFont,lDefFont);
  with DefFont do begin
    Name:=Font.Name; Color:=Font.Color; Size:=Font.Size; Style:=Font.Style; Charset:=Font.CharSet;
  end;
  DelStack;
end;

procedure FontStyle;
begin
  AddStack('My_pr.FontStyle');
  with Font do if Incl
  then Style:=Style+AStyle
  else Style:=Style-AStyle;
  DelStack;
end;

procedure IncFontSize;
begin
  AddStack('My_pr.IncFontSize');
  Font.Size:=Font.Size+d2;
  DelStack;
end;

{procedure FontToDefFont;
begin
	AddStack('My_pr.FontToDefFont');
  with DefFont do begin
    StrPCopy(lfFaceName,Font.Name);
    lfHeight:=Font.Height;
    lfWeight:=iif(fsBold in Font.Style,FW_BOLD,FW_NORMAL);
    lfItalic:=Byte(fsItalic in Font.Style);
    lfUnderline:=Byte(fsUnderline in Font.Style);
    lfStrikeOut:=Byte(fsStrikeOut in Font.Style);
    lfCharSet:=Byte(Font.Charset);
  end;
  DelStack;
end;}

function ListCreate;
begin
  if not Assigned(ls) then ls:=TList.Create;
  result:=ls;
end;

function ListCreateObj;
begin
	AddStack('My_pr.ListCreateObj');
  result:=ListCreate(ls).Add(Sender);
  DelStack;
end;

function ListDestroyObj;
begin
	AddStack('My_pr.ListDestroyObj');
  if Assigned(ls) then begin
    result:=ls.Remove(Sender);
    if result>=0 then if ls.Count=0 then FreeAndNil(ls);
  end
  else result:=-1;
  DelStack;
end;

procedure SLObjIndDel(ls: TStrings; i: longint; Proc: TSLObjIndProc; lDel: boolean = true; l: longint = NegDef);
var i1,n,n1: longint;
begin
  AddStack('My_pr.SLObjIndDel');
  n:=IntObj(ls,i);
  for n1:=n+1 to ReplNeg(l,ls.Count)-1 do Proc(n1,n1-1);
  for i1:=0 to ls.Count-1 do begin
    n1:=IntObj(ls,i1);
    if n1>n then ls.Objects[i1]:=Pointer(n1-1);
  end;
  if lDel then ls.Delete(i);
  DelStack;
end;

procedure SLObjIndDel(ls: TStrings; i: longint; Proc: TSLObjIndProc1; p: pointer = nil);
var i1,n,n1: longint;
begin
  AddStack('My_pr.SLObjIndDel(p)');
  n:=IntObj(ls,i);
  for n1:=n+1 to ls.Count-1 do Proc(n1,n1-1,p);
  for i1:=0 to ls.Count-1 do begin
    n1:=IntObj(ls,i1);
    if n1>n then ls.Objects[i1]:=Pointer(n1-1);
  end;
  ls.Delete(i);
  DelStack;
end;

function IgnoreSlFindAdd(ignoreSL: TStringList; const s: string; var ixS: longint): boolean;
var j: longint;
begin
  j:=ignoreSL.Count; ixS:=ignoreSL.Add(s); result:=j=ignoreSL.Count;
end;

function IgnoreSlFindAdd(ignoreSL: TStringList; const s: string): boolean;
var ixS: longint;
begin
  result:=IgnoreSlFindAdd(ignoreSL,s,ixS);
end;

function IgnoreSlFindAdd(ignoreSL: TStringList; const s: string; var ixS: longint; var p: pointer): boolean;
begin
  result:=IgnoreSlFindAdd(ignoreSL,s,ixS);
  if result then p:=PointerObj(ignoreSL,ixS);
end;

function IgnoreSlAddDel;
var ixS: longint;
begin
  AddStack('My_pr.IgnoreSlAddDel');
  result:=not IgnoreSlFindAdd(ignoreSL,s,ixS);
  if not result then ignoreSL.Delete(ixS);
  DelStack;
end;

function IgnoreSlAddInt;
var ixS: longint;
begin
  AddStack('My_pr.IgnoreSlAddInt');
  IgnoreSlFindAdd(ignoreSL,s,ixS); result:=IntObj(ignoreSL,ixS)+offs;
  ignoreSL.Objects[ixS]:=Pointer(result);
  DelStack;
end;

function SortStrListCreate(Duplicates: TDuplicates = dupIgnore): TStringList;
begin
  result:=TStringList.Create; result.Duplicates:=Duplicates; result.Sorted:=true;
end;

function SortStrListCreate(lCreate: boolean): TStringList;
begin
  if lCreate then result:=SortStrListCreate else result:=nil;
end;

function SortStrListCreate(var ls: TStringList; Duplicates: TDuplicates = dupIgnore): TStringList;
begin
  if not Assigned(ls) then ls:=SortStrListCreate(Duplicates);
  result:=ls;
end;

function StrListCreate(lCreate: boolean): TStringList;
begin
  if lCreate then result:=TStringList.Create else result:=nil;
end;

function StrListCreate(var ls: TStringList): TStringList;
begin
  if not Assigned(ls) then ls:=TStringList.Create;
  result:=ls;
end;

function FindDel(ls: TStringList; const s: string; Proc: TFindDelProc = nil): boolean;
begin
  result:=FindDel(ls,s,Proc,[]);
end;

function FindDel(ls: TStringList; const s: string; Proc: TFindDelProc; const av: array of variant): boolean;
var i: longint;
begin
  result:=false;
  if Assigned(ls) then begin
    i:=ls.IndexOf(s);
    if i>=0 then begin
      IfThenFindDel(Proc,ls.Objects[i],av); result:=true; ls.Delete(i);
    end;
  end;
end;

function FindDelFree(var ls: TStringList; const s: string): boolean;
begin
  AddStack('My_pr.FindDelFree');
  result:=false;
  if FindDel(ls,s) then if ls.Count=0 then begin
    result:=true; FreeAndNil(ls);
  end;
  DelStack;
end;

function IntObj(ls: TStrings; i: longint): longint;
begin
  result:=longint(ls.Objects[i]);
end;

function IntObj(ls: TStrings; i: longint; var n: longint): boolean;
begin
  n:=IntObj(ls,i); result:=n<>0;
  if result then Dec(n); 
end;

procedure IntObjSelf;
begin
  i:=IntObj(ls,i);
end;

function IntObjFind(ls: TStringList; const s: string): longint;
begin
  IntObjFind(ls,s,result);
end;

function IntObjFind(ls: TStringList; const s: string; var n: longint): boolean;
var i: longint;
begin
  result:=IntObjFind(ls,s,i,n);
end;

function IntObjFind(ls: TStringList; const s: string; var i,n: longint): boolean;
begin
  AddStack('My_pr.IntObjFind');
  result:=Assigned(ls);
  if result then begin
    i:=ls.IndexOf(s); result := i>=0;
    if result then n:=IntObj(ls,i);
  end;
  if not result then begin
    i:=-1; n:=-1;
  end;
  DelStack;
end;

function IntObjFindAdd(ls: TStringList; const s: string): longint;
begin
  IntObjFindAdd(ls,s,result);
end;

function IntObjFindAdd(ls: TStringList; const s: string; var n: longint): boolean;
var i: longint;
begin
  result:=IntObjFindAdd(ls,s,i,n);
end;

function IntObjFindAdd(ls: TStringList; const s: string; var i,n: longint): boolean;
var l: longint;
begin
  l:=ls.Count; result:=IntObjFindAdd(ls,s,i,n,l);
end;

function IntObjFindAdd(ls: TStringList; const s: string; var i,n,l: longint): boolean;
begin
  result:=IgnoreSlFindAdd(ls,s,i);
  if result then n:=IntObj(ls,i)
  else begin
    n:=l; Inc(l); ls.Objects[i]:=Pointer(n);
  end;
end;

function LongWordObj;
begin
  AddStack('My_pr.LongWordObj');
  result:=longword(ls.Objects[i]);
  DelStack;
end;

function LongWordObjFind(ls: TStringList; const s: string; var dw: longword): boolean;
var i: longint;
begin
  result:=LongWordObjFind(ls,s,i,dw);
end;

function LongWordObjFind(ls: TStringList; const s: string; var i: longint; var dw: longword): boolean;
begin
  AddStack('My_pr.LongWordObjFind');
  result:=ls.Find(s,i);
  if result then dw:=LongWordObj(ls,i);
  DelStack;
end;

function BoolObj;
var i: longint;
begin
  AddStack('My_pr.BoolObj');
  if MyVarType(iOrS)=varString then i:=ls.IndexOf(iOrS) else i:=iOrS;
  result:=boolean(ls.Objects[i]);
  DelStack;
end;

function BoolObjFind(ls: TStringList; const s: string; var i: longint; var fl: boolean): boolean;
begin
  AddStack('My_pr.BoolObjFind');
  result:=ls.Find(s,i);
  if result then fl:=BoolObj(ls,i);
  DelStack;
end;

function BoolObjFind(ls: TStringList; const s: string; var fl: boolean): boolean;
var i: longint;
begin
  result:=BoolObjFind(ls,s,i,fl);
end;

procedure BoolObjPack;
var i: longint;
begin
  AddStack('My_pr.BoolObjPack');
  i:=0;
  while i<ls.Count do
    if BoolObj(ls,i)=DelTrue then ls.Delete(i) else Inc(i);
  DelStack;
end;

function BSet2Bool;
begin
  case eb of
    bsetNone: result:=vNone;
    bsetFalse: result:=false;
    bsetTrue: result:=true;
    (*STUPIDwarning*)else result:=false;
  end;
end;

function PointerObj(ls: TStrings; i: longint): pointer;
begin
  result:=ls.Objects[i];
end;

function PointerObj(ls: TStrings; i: longint; var p: pointer): boolean;
begin
  p:=PointerObj(ls,i); result:=Assigned(p);
end;

procedure PointerObjSelf;
begin
  ls:=PointerObj(ls,i);
end;

function PointerObjFind(ls: TStringList; const s: string): pointer;
var i: longint;
begin
  PointerObjFind(ls,s,result,i);
end;

function PointerObjFind(ls: TStringList; const s: string; var i: longint): pointer;
begin
  PointerObjFind(ls,s,result,i);
end;

function PointerObjFind(ls: TStringList; const s: string; var p: pointer): boolean;
var i: longint;
begin
  result:=PointerObjFind(ls,s,p,i);
end;

function PointerObjFind(ls: TStringList; const s: string; var p: pointer; var i: longint): boolean;
begin
	AddStack('My_pr.PointerObjFind');
	p:=nil;
	if Assigned(ls) then if ls.Find(s,i) then p:=PointerObj(ls,i);
  result:=Assigned(p);
  if not result then i:=-1;
  DelStack;
end;

function PointerObjFindAdd;
begin
  AddStack('My_pr.PointerObjFindAdd');
  result:=IgnoreSlFindAdd(ignoreSL,s,ixS);
  if result then p:=PointerObj(ignoreSL,ixS);
  DelStack;
end;

procedure FreeObjects(var ls: TStringList);
var i: longint;
begin
  AddStack('My_pr.FreeObjects(TStringList)');
  if Assigned(ls) then begin
    for i:=0 to ls.Count-1 do ls.Objects[i].Free;
    FreeAndNil(ls);
  end;
  DelStack;
end;

procedure ClearObjects;
var i: longint;
begin
  AddStack('My_pr.ClearObjects');
  for i:=0 to ls.Count-1 do ls.Objects[i].Free;
  ls.Clear;
  DelStack;
end;

procedure InitObjects;
var i: longint;
begin
  AddStack('My_pr.InitObjects');
  for i:=0 to ls.Count-1 do ls.Objects[i]:=o;
  DelStack;
end;

function CodMaybeUsed(ls: TStringList; const acod: array of string; lLike: boolean = false): boolean;
var i: longint;
begin
  AddStack('My_pr.CodMaybeUsed');
  result:=not Assigned(ls);
  if not result then for i:=low(acod) to high(acod) do begin
    if lLike
    then result:=FindStartsStrList(ls,TrimRight(acod[i]))
    else result := ls.IndexOf(TrimRight(acod[i]))>=0;
    if result then break;
  end;
  DelStack;
end;

function CodMaybeUsed(ls: TStringList; const cod: string; lLike: boolean = false): boolean;
begin
  result:=CodMaybeUsed(ls,[cod],lLike);
end;

function CodGrayCell;
var s: string;
  fl: boolean;
  procedure lsFind(ls: TStringList; NoUsed: boolean);
  begin
  	AddStack('My_pr.CodGrayCell.lsFind');
    if Assigned(ls) then begin
      result := (ls.IndexOf(s)<0)=NoUsed; fl:=false;
    end;
    DelStack;
  end;
begin
	AddStack('My_pr.CodGrayCell');
  result:=false;
  if not(gdFixed in State) then begin
    s:=TrimRight(fqCod.AsString); fl:=true; lsFind(LsNoUsed,true);
    if fl then lsFind(LsUsed,false);
  end;
  DelStack;
end;

procedure MsgApplication;
var i: longint;
  tc: TControl;
begin
	AddStack('My_pr.MsgApplication');
	for i:=0 to Application.ComponentCount-1 do
		if IsClass(Application.Components[i],TControl,pointer(tc))
    then ProcControlsMsg(tc,Msg,WParam,LParam,Level1);
  DelStack;
end;

procedure MsgApplGetUpd;
begin
  AddStack('My_pr.MsgApplGetUpd');
  MsgApplication(WM_GETUPD,0,LongInt(@nmMsg));
  DelStack;
end;

function ParamByCode;
var i: longint;
	s,Code: string;
begin
	AddStack('My_pr.ParamByCode');
	result:=''; Code:=NameCode+'=';
	for i:=1 to ParamCount do begin
  	s:=ParamStr(i);
    if AnsiStartsText(Code,s) then begin
      if lUpper then AnsiUpperCaseSelf(s);
    	result:=copy(s,Length(Code)+1,MaxInt); break;
    end;
  end;
  DelStack;
end;

function ParamAllStr;
var i: longint;
begin
	AddStack('My_pr.ParamAllStr');
  result:='';
  for i:=1 to ParamCount do IncD(result,ParamStr(i)+' ');
  DecLen(result);
  DelStack;
end;

function CanvasMaxW;
begin
  result:=Canvas.TextWidth(cMaxW);
end;

function CanvasMaxH;
begin
  result:=Canvas.TextHeight(cMaxH);
end;

procedure bmCheckPaint(Canvas: TCanvas; const ARect: TRect; usl: boolean; bm: TBitMap = nil);
var l,t,w,h,w1,h1: longint;
	fl: boolean;
  cl: TColor;
  sz: TSize;
begin
	AddStack('My_pr.bmCheckPaint');
  Canvas.FillRect(ARect);
  if usl then with ARect do
    if ChrCheck=' ' then begin
      if not Assigned(bm) then InitBM.FindBM(bmCheck,bm);
      w:=bm.Width-1; h:=bm.Height-1; w1:=Right-Left; h1:=Bottom-Top;
      fl := (w1<w) or (h1<h);
      if fl then begin
        w:=min(w1,h1); h:=w;
      end;
      l:=Left+(w1-w) div 2; t:=Top+(h1-h) div 2;
      if fl then begin
        Canvas.StretchDraw(Rect(l,t,l+w,t+h),bm);
        //Canvas.FloodFill(l,t,bm.TransparentColor,fsSurface);
        cl:=bm.Canvas.Pixels[0,0];
        for w1:=l to l+w do
          for h1:=t to t+h do
            if Canvas.Pixels[w1,h1]=cl
            then Canvas.Pixels[w1,h1]:=Canvas.Brush.Color;
      end
      else begin
        cl:=bm.Canvas.Pixels[0,0];
        for w1:=0 to w do
          for h1:=0 to h do
            if bm.Canvas.Pixels[w1,h1]<>cl
            then Canvas.Pixels[w1+l,h1+t]:=bm.Canvas.Pixels[w1,h1];
        //Canvas.BrushCopy(Rect(l,t,l+w,t+h),bm,Rect(0,0,w,h),bm.TransparentColor);
      end;
    end
    else begin
      sz:=Canvas.TextExtent(ChrCheck);
      Canvas.TextRect(ARect,Left+max(0,(Right-Left-sz.cx) div 2),
        Top+max(0,(Bottom-Top-sz.cy) div 2),ChrCheck);
    end;
  DelStack;
end;

function bmCheckSize;
var bm: TBitMap;
begin
	AddStack('My_pr.bmCheckSize');
  InitBM.FindBM(bmCheck,bm); result.cX:=bm.Width; result.cY:=bm.Height;
  DelStack;
end;

function RectInScroll;
var sc: TScrollingWinControl;
  p: TPoint;
begin
	AddStack('My_pr.RectInScroll');
  if ParentScroll(Sender,sc) then begin
    p:=Sender.ScreenToClient(sc.ClientOrigin);
    result:=Rect(max(0,p.X),max(0,p.Y),
      min(Sender.Left+Sender.Width,p.X+sc.ClientWidth),
      min(Sender.Top+Sender.Height,p.Y+sc.ClientHeight));
  end;
  DelStack;
end;

function ParentScroll;
begin
	AddStack('My_pr.ParentScroll');
  result:=ParentClass(TWinControl(sc),Sender.Parent,TScrollingWinControl);
  DelStack;
end;

procedure ControlsFree;
begin
	AddStack('My_pr.ControlsFree');
  while Sender.ControlCount>0 do Sender.Controls[0].Free;
  DelStack;
end;

procedure WinSize;
begin
  AddStack('My_pr.WinSize');
  result.cX:=Width; result.cY:=Height;
  DelStack;
end;

function ReplaceProc;
var a: TArrVar;
  i,j,l,h: longint;
begin
  AddStack('My_pr.ReplaceProc');
  result:=mrYes;
  if Assigned(pr) then begin
    if Assigned(pav) then
      if MyVarType(pav^)=varArray then begin
        l:=VarArrayLowBound(pav^,1); h:=VarArrayHighBound(pav^,1); SetLength(a,h-l+1);
        j:=low(a);
        for i:=l to h do begin
          a[j]:=pav^[i]; Inc(j);
        end;
      end
      else begin
        SetLength(a,1); a[0]:=pav^;
      end;
    AddFromVArr(a,av); result:=pr(a);
  end;
  case result of
    mrCancel: cnt:=-1;
    mrYes: Inc(cnt);
  end;
  DelStack;
end;

function IconLoad;
var ost: longint;
begin
  ost:=AddStack('My_pr.IconLoad');
  result:=false;
  if not empty(FileName) then
	  if MyFileExists(FileName) then begin
    	try
	    	Icon.LoadFromFile(FileName); result:=true;
      except
      	on EInvalidGraphic do SetStack(ost);
      end;
    end;
  DelStack;
end;

function ListMoveItem;
var i: longint;
	step: TValueSign;
begin
  AddStack('My_pr.ListMoveItem');
  result := InRange(oi,LowLimit,HighLimit) and InRange(ni,LowLimit,HighLimit)	and (oi<>ni);
  if result then begin
    i:=ni; step:=aSign[oi<ni];
    while i<>oi do begin
      Proc(i,oi,av); Inc(i,step);
    end;
  end;
  DelStack;
end;

function MyPriv(TokenHandle: THandle; DisableAllPrivileges: BOOL;
  const NewState: TTokenPrivileges; BufferLength: longword;
  PreviousState: PTokenPrivileges; var ReturnLength: longword): BOOL; stdcall; external advapi32 name 'AdjustTokenPrivileges';

function ReBoot;
begin
  AddStack('My_pr.ReBoot');
  result:=SetPrivilege('SeShutdownPrivilege');
  if result then begin
	  Application.Terminate; ExitWindowsEx(uFlags,0);
  end;
  DelStack;
end;

function SetPrivilege;
var priv: TTokenPrivileges;
  rl: longword;
  hToken: THandle;
begin
  AddStack('My_pr.SetPrivilege');
  result:=true;
  if Win32Platform=VER_PLATFORM_WIN32_NT then
    if OpenProcessToken(GetCurrentProcess,TOKEN_ADJUST_PRIVILEGES,hToken) then begin
      priv.PrivilegeCount:=1;
      if LookupPrivilegeValue(nil,lpName,priv.Privileges[0].Luid) then begin
        priv.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED;
        result:=MyPriv(hToken,false,priv,SizeOf(priv),PTokenPrivileges(nil),rl);
      end;
      CloseHandle(hToken);
    end;
  DelStack;
end;

procedure Frame3D1(Canvas: TCanvas; var Rect: TRect; lConcave: boolean; const aColor: TArrBoolColor; Width: byte); overload;
begin
  AddStack('My_pr.Frame3D1');
  Frame3D(Canvas,Rect,aColor[not lConcave],aColor[lConcave],Width);
  DelStack;
end;

procedure Frame3D1(Canvas: TCanvas; var Rect: TRect; lConcave: boolean = true; Width: byte = 1);
begin
  Frame3D1(Canvas,Rect,lConcave,aclBtn,Width);
end;

procedure Frame3D2;
const acl3D: TArrBoolColor = (cl3DDkShadow,cl3DLight);
begin
  AddStack('My_pr.Frame3D2');
  if lConcave then begin
    Frame3D1(Canvas,Rect,lConcave,Width);
    Frame3D1(Canvas,Rect,lConcave,acl3D,Width);
  end
  else begin
    Frame3D1(Canvas,Rect,lConcave,acl3D,Width);
    Frame3D1(Canvas,Rect,lConcave,Width);
  end;
  DelStack;
end;

procedure Frame3DF;
var lConcave: boolean;
begin
  AddStack('My_pr.Frame3DF');
  for lConcave:=high(lConcave) downto low(lConcave) do Frame3D1(Canvas,Rect,lConcave,Width);
  DelStack;
end;

function NoApplDuplicate;
var h: HWND;
begin
  AddStack('My_pr.NoApplDuplicate');
  h:=GetTopWindow(0); result:=true;
  while h<>0 do begin
    if h<>Application.Handle then
      if HandleClassName(h)='TAPPLICATION' then begin
        if AnsiMatchText(HandleWindowText(h),aTitle) then begin
          result:=false; SetForegroundWindow(h); Application.Terminate; break;
        end;
      end;
    GetNextWindowSelf(h);
  end;
  DelStack;
end;

function IsResProcess;
  procedure FindProc(const s: array of char);
  const ap: TResProcessStr = ('IBSERVER','FBSERVER,FB_INET_SERVER');
  var sf: string;
    j: TResProcessList;
    a: array[1..2] of string;
    i: byte;
  begin
    AddStack('My_pr.IsResProcess.FindProc');
    sf:=AnsiUpperCase(ExtractFileWithOutExt(string(s)));
    for j:=low(ap) to high(ap) do if not(j in paResProcess^) then begin
      i:=ListAsArray(ap[j],a,',');
      while i>0 do begin
        if sf=a[i] then begin
          Include(paResProcess^,j); break;
        end;
        Dec(i);
      end;
      if j in paResProcess^ then break;
    end;
    DelStack;
  end;
var pe: TProcessEntry32;
  ph,snap: THandle; //дескрипторы процесса и снимка
  mh: hmodule; //дескриптор модуля
  procs: array[0..$FFF] of longword; //массив для хранения дескрипторов процессов
  count,cm: longword; //количество процессов
  i1: longint;
  ModName: array[0..max_path] of char; //имя модуля
begin
  AddStack('My_pr.IsResProcess');
  if not Assigned(paResProcess) then begin
    New(paResProcess); paResProcess^:=[];
    snap:=CreateToolhelp32Snapshot(th32cs_snapprocess,0);
    if longint(snap)<>-1 then begin
      pe.dwSize:=sizeof(pe);
      if Process32First(snap,pe) then
        repeat
          FindProc(pe.szExeFile);
        until not Process32Next(snap,pe);
    end;
    if Win32Platform=VER_PLATFORM_WIN32_NT then
      if EnumProcesses(@procs,sizeof(procs),count) then
        for i1:=0 to count div 4 - 1 do begin
          ph:=OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,false,procs[i1]);
          if ph>0 then begin
            EnumProcessModules(ph,@mh,4,cm);
            GetModuleFileNameEx(ph,mh,ModName,sizeof(ModName));
            FindProc(ModName);
            CloseHandle(ph);
          end;
        end;
  end;
  result := i in paResProcess^;
  DelStack;
end;

procedure lsCodCng;
var i: longint;
begin
  AddStack('My_pr.lsCodCng');
  if Assigned(ls) then
    if ls.Find(TrimRight(oCod),i) then begin
      ls.Sorted:=false; ls[i]:=TrimRight(nCod); ls.Sorted:=true;
    end;
  DelStack;
end;

procedure PrnInit;
var ost: longint;
begin
  ost:=AddStack('My_pr.PrnInit');
  //if not(csDesigning in Printer.ComponentState) then
  if Printer.Printers.Count>0 then
    try
      GetDeviceCaps(Printer.Handle,LOGPIXELSX);
      Printer.Canvas.Font.PixelsPerInch:=GetDeviceCaps(Printer.Handle,LOGPIXELSY);
    except
      SetStack(ost);
    end;
  DelStack;
end;

function GGPrinter;
begin
  AddStack('My_pr.GGPrinter');
  if NoPrnInit then begin
    NoPrnInit:=false; PrnInit;
  end;
  result:=Printer;
  DelStack;
end;

function IsPrinters;
begin
  AddStack('My_pr.IsPrinters');
	result := GGPrinter.Printers.Count>0;
	if not result then meserr('Необходимо установить принтер.');
  DelStack;
end;

function CalcSpotPrn: TRect;
var OffsetX,OffsetY: longint;
	MmPxlX,MmPxlY: Double;
begin
	AddStack('My_pr.CalcSpotPrn');
	if IsPrinters then begin
    OffsetX:=GetDeviceCaps(GGPrinter.Handle,PHYSICALOFFSETX);
    OffsetY:=GetDeviceCaps(GGPrinter.Handle,PHYSICALOFFSETY);
    MmPxlX:=GetDeviceCaps(GGPrinter.Handle,LOGPIXELSX)/MmInInch;
    MmPxlY:=GetDeviceCaps(GGPrinter.Handle,LOGPIXELSY)/MmInInch;
    result:=Rect(Ceil(OffsetX/MmPxlX),Ceil(OffsetY/MmPxlY),
      Ceil((GetDeviceCaps(GGPrinter.Handle,PHYSICALWIDTH)-OffsetX-GGPrinter.PageWidth)/MmPxlX),
      Ceil((GetDeviceCaps(GGPrinter.Handle,PHYSICALHEIGHT)-OffsetY-GGPrinter.PageHeight)/MmPxlY));
  end
  else ZeroMemory(@result,SizeOf(result));
  DelStack;
end;

function INNCheck;
  procedure SumCtrl(nbeg: byte);
  const a: array[1..11] of byte = (3,7,2,4,10,3,5,9,4,6,8);
  var i,j,v: byte;
    c: longint;
  begin
    AddStack('My_pr.INNCheck.SumCtrl');
    c:=0; j:=1;
    for i:=nbeg to high(a) do begin
      v:=Int0(result[j]); Inc(c,v*a[i]); result[j]:=IntToStr(v)[1]; Inc(j);
    end;
    result[j]:=IntToStr((c mod 11) mod 10)[1];
    DelStack;
  end;
begin
  AddStack('My_pr.INNCheck');
  result:=Trim(inn);
  if Length(result)<11 then begin
    PadRSelf(result,10,'0'); SumCtrl(3);
  end
  else begin
    PadRSelf(result,12,'0'); SumCtrl(2); SumCtrl(1);
  end;
  DelStack;
end;

procedure SetSet(var s: TBoolSet; Value,lSet: boolean);
begin
  if lSet then Include(s,Value) else Exclude(s,Value);
end;

procedure SetSet(var s: TByteSet; Value: byte; lSet: boolean);
begin
  if lSet then Include(s,Value) else Exclude(s,Value);
end;

procedure SetSet(var s: TGetOptions; Value: TGetOption; lSet: boolean);
begin
  if lSet then Include(s,Value) else Exclude(s,Value);
end;

function CtrlInfCount;
begin
  AddStack('My_pr.CtrlInfCount');
  result:=Sender.ControlCount; Sender.perform(WM_CTRLINF,byte(ctiCount),LongInt(@result));
  DelStack;
end;

function CtrlInfItem;
var tc: longint;
begin
  AddStack('My_pr.CtrlInfItem');
  tc:=Sender.perform(WM_CTRLINF,byte(ctiItem),Index);
  if tc=0 then result:=Sender.Controls[Index] else result:=pointer(tc);
  DelStack;
end;

function PointerToStr;
var p: PChar;
  i: longint;
begin
	AddStack('My_pr.PointerToStr');
  p:=PChar(Pnt); SetLength(result,l);
  for i:=1 to l do begin
  	result[i]:=p^; Inc(p);
  end;
  DelStack;
end;

procedure StrToPointer;
var p: PChar;
  i: longint;
begin
	AddStack('My_pr.StrToPointer');
  p:=PChar(Pnt);
  for i:=1 to l do begin
  	p^:=s[i]; Inc(p);
  end;
  DelStack;
end;

procedure DisposeNil(var p: pointer);
begin
  AddStack('My_pr.DisposeNil');
  if Assigned(p) then begin
    Dispose(p); p:=nil;
  end;
  DelStack;
end;

procedure DisposeNil(var p: PVariant);
begin
  AddStack('My_pr.DisposeNil(PVariant)');
  if Assigned(p) then begin
    Dispose(p); p:=nil;
  end;
  DelStack;
end;

procedure DisposeNil(var p: PArrStr);
begin
  AddStack('My_pr.DisposeNil(PArrStr)');
  if Assigned(p) then begin
    Dispose(p); p:=nil;
  end;
  DelStack;
end;

procedure DisposeNil(var p: PArrInt);
begin
  AddStack('My_pr.DisposeNil(PArrInt)');
  if Assigned(p) then begin
    Dispose(p); p:=nil;
  end;
  DelStack;
end;

procedure DisposeNil(var p: PString);
begin
  AddStack('My_pr.DisposeNil(PString)');
  if Assigned(p) then begin
    Dispose(p); p:=nil;
  end;
  DelStack;
end;

function StringStreamCreate;
begin
  AddStack('My_pr.StringStreamCreate');
  if Assigned(Sender) then begin
    Sender.Size:=0; Sender.Seek(0,soBeginning);
  end
  else Sender:=TStringStream.Create('');
  result:=Sender;
  DelStack;
end;

function IsSelected;
var ost: longint;
begin
  ost:=AddStack('My_pr.IsSelected');
  try
    Dest:=Source.Selected;
  except
    SetStack(ost);
    Dest:=nil;
  end;
  result:=Assigned(Dest);
  DelStack;
end;

function IsNodeAt;
begin
  AddStack('My_pr.IsNodeAt');
  Dest:=Source.GetNodeAt(X,Y); result:=Assigned(Dest);
  DelStack;
end;

function IsPrevSibling;
begin
  AddStack('My_pr.IsPrevSibling');
  Dest:=Source.getPrevSibling; result:=Assigned(Dest);
  DelStack;
end;

function IsNextSibling;
begin
  AddStack('My_pr.IsNextSibling');
  Dest:=Source.getNextSibling; result:=Assigned(Dest);
  DelStack;
end;

function IsFirst;
begin
  AddStack('My_pr.IsFirst');
  Dest:=Source.Items.GetFirstNode; result:=Assigned(Dest);
  DelStack;
end;

function GetFirstChildSelf;
begin
  tn:=tn.GetFirstChild; result:=Assigned(tn);
end;

procedure GetNextSelf;
begin
  result:=result.GetNext;
end;

procedure GetNextSiblingSelf;
begin
  result:=result.GetNextSibling;
end;

procedure GetNextVisibleSelf;
begin
  result:=result.GetNextVisible;
end;

procedure GetPrevSelf;
begin
  result:=result.GetPrev;
end;

function NodeNotFill;
var tn: TTreeNode;
begin
  AddStack('My_pr.NodeNotFill');
  result:=false; tn:=Node.getFirstChild;
  if Assigned(tn) then
    if tn.getNextSibling=nil then result := tn.Text='';
  DelStack;
end;

function ParentSelf(var Sender: TWinControl): boolean;
begin
  Sender:=Sender.Parent; result:=Assigned(Sender);
end;

function ParentSelf(var Sender: TTreeNode): boolean;
begin
  Sender:=Sender.Parent; result:=Assigned(Sender);
end;

function ParentClass(var Dest: TWinControl; Source: TWinControl; DestClass: TWinControlClass): boolean;
begin
  AddStack('My_pr.ParentClass');
  Dest:=Source; result:=false;
  while Assigned(Dest) do
    if Dest is DestClass then begin
      result:=true; break;
    end
    else ParentSelf(Dest);
  DelStack;
end;

function ParentClass(var Dest: TWinControl; DestClass: TWinControlClass): boolean;
begin
  result:=ParentClass(Dest,Dest,DestClass);
end;

function IsClass(Sender: TObject; ToClass: TClass): pointer;
begin
  IsClass(Sender,ToClass,result);
end;

function IsClass(Sender: TObject; ToClass: TClass; var Dest: pointer; lNil: boolean = true): boolean;
begin
  {$IFDEF STACKALL}AddStack('My_pr.IsClass');{$ENDIF}
  result := Sender is ToClass;
  if result then Dest:=Sender else if lNil then Dest:=nil;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function IsClass(Sender: pointer; ToClass: TClass; var Dest: pointer; lNil: boolean = true): boolean;
begin
  result:=IsClass(TObject(Sender),ToClass,Dest,lNil);
end;

function OwnerSelf;
begin
  Sender:=Sender.Owner; result:=Assigned(Sender);
end;

function PointerOwner;
begin
  result:=Sender.Owner;
end;

function ComponentsClass;
var i: longint;
begin
  AddStack('My_pr.ComponentsClass');
  result:=false; p:=nil;
  with Sender do for i:=0 to ComponentCount-1 do if IsClass(Components[i],ToClass,p,false) then begin
    result:=true; break;
  end;
  DelStack;
end;

function ControlsClass(Sender: TWinControl; ToClass: TClass; var p: pointer): boolean;
var i: longint;
begin
  AddStack('My_pr.ControlsClass');
  result:=false; p:=nil;
  with Sender do for i:=0 to ControlCount-1 do if IsClass(Controls[i],ToClass,p,false) then begin
    result:=true; break;
  end;
  DelStack;
end;

function ControlsClass(Sender: TWinControl; ToClass: TClass): pointer;
begin
  ControlsClass(Sender,ToClass,pointer(result));
end;

procedure SetMemory;
begin
  FillMemory(Destination,Length,MaxByte);
end;

procedure TrueMemory;
begin
  FillMemory(Destination,Length*SizeOf(boolean),ByteTrue);
end;

function FracEmp2Bool;
begin
  result := Value=frempYes;
end;

function Bool2FracEmp;
begin
  AddStack('My_pr.Bool2FracEmp');
  if MyVarType(Value)=varBoolean then result:=iif(Value,frempYes,frempNo) else result:=Value;
  DelStack;
end;

procedure rHelpFile(var result: THelpFile; const sFile: string = ''; const sPage: string = '');
begin
  AddStack('My_pr.rHelpFile');
  result.sFile:=sFile; result.sPage:=sPage;
  DelStack;
end;

procedure rHelpFile(var result: THelpFile; Vid: THelpLinkList; const sPage: string = '');
begin
  rHelpFile(result,Int2Str(Vid),sPage);
end;

function GetPBoolean;
begin
  AddStack('My_pr.GetPBoolean');
  if Assigned(p) then result:=p^ else result:=Default;
  DelStack;
end;

function GetPString;
begin
  AddStack('My_pr.GetPString');
  result:=Assigned(p);
  if result then Value:=p^;
  DelStack;
end;

function GetPLongInt;
begin
  AddStack('My_pr.GetPLongInt');
  result:=Assigned(p);
  if result then Value:=p^;
  DelStack;
end;

function SetPBoolean(p: PBoolean; Value: boolean = false): boolean;
begin
  AddStack('My_pr.SetPBoolean');
  result:=Assigned(p);
  if result then p^:=Value;
  DelStack;
end;

function SetPBoolean(const p: variant; Value: boolean = false): boolean;
begin
  result:=SetPBoolean(PointerVar(p),Value);
end;

function SetPString(p: PString; const Value: string = ''): boolean;
begin
  AddStack('My_pr.SetPString');
  result:=Assigned(p);
  if result then p^:=Value;
  DelStack;
end;

function SetPString(const p: variant; const Value: string = ''): boolean;
begin
  result:=SetPString(PointerVar(p),Value);
end;

function SetPLongInt(p: PLongInt; Value: longint = 0): boolean;
begin
  AddStack('My_pr.SetPLongInt');
  result:=Assigned(p);
  if result then p^:=Value;
  DelStack;
end;

function SetPLongInt(const p: variant; Value: longint = 0): boolean;
begin
  result:=SetPLongInt(PointerVar(p),Value);
end;

{procedure BMSpeedButton(sb: TSpeedButton; bmNum: Word);
const cl = clBtnFace;
	procedure Lim(var n: longint; lowlim,highlim: longint; step: TValueSign);
  var fl: boolean;
  	i: longint;
  begin
    AddStack('My_pr.BMSpeedButton.Lim');
    n:=lowlim+step*2; fl:=false;
	  with sb.Glyph do while n <> highlim do begin
    	for i:=0 to Height-1 do
      	if Canvas.Pixels[n,i] <> cl then begin
		    	Dec(n,step); fl:=true; break;
        end;
      if fl then break else Inc(n,step);
    end;
    DelStack;
  end;
var r: TRect;
begin
  AddStack('My_pr.BMSpeedButton');
  with sb.Glyph do begin
    Handle:=LoadBitMap(0,PChar(bmNum)); //cl:=Canvas.Pixels[0,0];
    Lim(r.Left,0,Width,1); Lim(r.Right,Width-1,-1,-1);
    Lim(r.Top,0,Height,1); Lim(r.Bottom,Height-1,-1,-1);
    Canvas.BrushCopy(Rect(0,0,r.Right-r.Left,r.Bottom-r.Top),sb.Glyph,r,TransparentColor);
  end;
  DelStack;
end;}

const cDlmAdr=',';

function StrToAdr;
var i: TAdrList;
begin
  AddStack('My_pr.StrToAdr');
  LsArrFill(Value,result,cDlmAdr);
  for i:=low(result) to high(result) do TrimRightSelf(result[i]);
  DelStack;
end;

function AdrToStr;
begin
  AddStack('My_pr.AdrToStr');
  result:=ArrayAsList(Value,cDlmAdr);
  DelStack;
end;

procedure meserr(const s: variant; const Capt: TCaption = ''; Algm: TAlignment = taCenter;
  lDbg: boolean = false);
begin
	AddStack('My_pr.meserr');
	mess_ok([StMeserr(s)],Capt,Algm,lDbg);
  DelStack;
end;

procedure meserr(const FormatStr: string; const Args: array of const;
  const Capt: TCaption = ''; Algm: TAlignment = taCenter; lDbg: boolean = false);
begin
	AddStack('My_pr.meserr(f)');
	meserr(Format(FormatStr,Args),Capt,Algm,lDbg);
  DelStack;
end;

procedure msr;
begin
	AddStack('My_pr.msr');
	mess_ok(['']);
  DelStack;
end;

function AskSel;
begin
  AddStack('My_pr.AskSel');
  result:=Ask([amsSel[Sel]+' ?']);
  DelStack;
end;

function StMeserr;
var i: longint;
begin
  AddStack('My_pr.StMeserr');
  case MyVarType(s) of
    varNull: result:='null';
    varDate: result:=OurFormatDateTime('dd/mm/yyyy hh:nn:ss:zzz',s);
		varBoolean: result:=IfThen(s,'True','False');
    varArray: begin
      result:='';
      for i:=VarArrayLowBound(s,1) to VarArrayHighBound(s,1) do IncD(result,StMeserr(s[i])+CRLF);
      DecLen(result,lCRLF);
    end;
  else result:=VarAsType(s,varString);
  end;
  if result='' then result:=' ';
  DelStack;
end;

// Ошибка запуска другой программы
procedure FindErr;
begin
	AddStack('My_pr.FindErr');
  if result then begin
    result := Pos(err,ScrConsole)=0;
    if not result then mess_ok(amsg);
  end;
  DelStack;
end;

function ReBootMsg;
var a: TArrStr;
begin
  AddStack('My_pr.ReBootMsg');
  result:=false;
  if MustReboot or lBound then begin
  	MustReboot:=false;
    if Length(amsg)=0
    then CopyFrom(a,['Изменены параметры системы.','Необходима её перезагрузка.'])
    else CopyFrom(a,amsg);
    AddFrom(a,['','Произвести перезагрузку сейчас ?']);
    if Ask(a) then
      if ReBoot then result:=true
      else mess_ok(['Ошибка перезагрузки системы.','Произведите перезагрузку системы вручную.']);
  end;
  DelStack;
end;

function ForceDirMsg;
begin
  AddStack('My_pr.ForceDirMsg');
  result:=ForceDirectories(dir);
  if not result then mess_ok(['Ошибка создания папки:',dir]);
  DelStack;
end;

function MsgDlg(const Msg: string; DlgType: TMsgDlgType = mtError;
  Buttons: TMsgDlgButtons = [mbOk]; HelpCtx: Longint = 0): longint;
const amr: array[TMsgDlgBtn] of TModalResult =
  (mrYes,mrNo,mrOK,mrCancel,mrAbort,mrRetry,mrIgnore,mrAll,mrNoToAll,mrYesToAll,mrNone);
var b: TMsgDlgBtn;
  f: TForm;
begin
	AddStack('My_pr.MsgDlg');
  if MessagesHidden or (false in MessagesOkHidden) then begin
    result:=amr[low(amr)];
    for b:=low(amr) to high(amr) do if b in Buttons then begin
      result:=amr[b]; break;
    end;
  end
  else begin
    f:=BeforeShowOther;
    if HelpCtx<>0 then Include(Buttons,mbHelp);
    result:=MessageDlg(Msg,DlgType,Buttons,HelpCtx); AfterShowOther(f);
  end;
  if (@LogMsgProc<>nil) then LogMsgProc([Msg],result);
  DelStack;
end;

function MsgDlg(const FormatStr: string; const Args: array of const; DlgType: TMsgDlgType = mtError;
  Buttons: TMsgDlgButtons = [mbOk]; HelpCtx: Longint = 0): longint;
begin
	AddStack('My_pr.MsgDlg(f)');
  result:=MsgDlg(Format(FormatStr,Args),DlgType,Buttons,HelpCtx);
  DelStack;
end;

function MsgDlg(const a: array of string; DlgType: TMsgDlgType = mtError;
  Buttons: TMsgDlgButtons = [mbOk]; HelpCtx: Longint = 0): longint; overload;
begin
	AddStack('My_pr.MsgDlg(a)');
  result:=MsgDlg(ArrayAsList(a,CRLF),DlgType,Buttons,HelpCtx);
  DelStack;
end;

function FileBufCreate;
begin
{$IFDEF MSWINDOWS}
  Result:=longint(CreateFile(PChar(FileName),GENERIC_READ or GENERIC_WRITE,
    0,nil,CREATE_ALWAYS,FILE_FLAG_SEQUENTIAL_SCAN,0));
{$ELSE}
  Result:=FileCreate(FileName);
{$ENDIF}
end;

function FileBufOpen;
{$IFDEF MSWINDOWS}
const
  AccessMode: array[0..2] of LongWord = (
    GENERIC_READ,
    GENERIC_WRITE,
    GENERIC_READ or GENERIC_WRITE);
  ShareMode: array[0..4] of LongWord = (
    0,
    0,
    FILE_SHARE_READ,
    FILE_SHARE_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE);
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  Result:=-1;
  if ((Mode and 3) <= fmOpenReadWrite) and
    ((Mode and $F0) <= fmShareDenyNone) then
    Result:=longint(CreateFile(PChar(FileName),AccessMode[Mode and 3],
      ShareMode[(Mode and $F0) shr 4],nil,OPEN_EXISTING,
      FILE_FLAG_SEQUENTIAL_SCAN,0));
{$ELSE}
  result:=FileOpen(FileName,Mode);
{$ENDIF}
end;

procedure VarToSvRec;
begin
	{$IFDEF STACKALL}AddStack('My_pr.VarToSvRec');{$ENDIF}
	case tp of
  	stShortInt: result.sh:=Value;
    stSmallInt: result.sm:=Value;
    stInteger: result.i:=Value;
    stByte: result.b:=Value;
    stWord: result.w:=Value;
  	stBoolean: result.l:=Value;
  	stLongWord: result.crd:=Value;
  	stReal: result.real:=Value;
  	stDouble: result.dbl:=Value;
	end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function SvRecToVar;
begin
	{$IFDEF STACKALL}AddStack('My_pr.SvRecToVar');{$ENDIF}
	case tp of
  	stShortInt: result:=sr.sh;
    stSmallInt: result:=sr.sm;
    stInteger: result:=sr.i;
    stByte: result:=sr.b;
    stWord: result:=sr.w;
  	stBoolean: result:=sr.l;
  	stLongWord: result:=sr.crd;
    stReal: result:=sr.real;
    stDouble: result:=sr.dbl;
  	stChar: result:=sr.s[1];
	else result:=null;
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function VarToStr;
var sr: TSaveRec;
begin
	{$IFDEF STACKALL}AddStack('My_pr.VarToStr');{$ENDIF}
  VarToSvRec(Value,tp,sr); SetLength(result,SizeOfVar[tp]); CopyMemory(pointer(result),@sr,SizeOfVar[tp]);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function StrToVar;
var sr: TSaveRec;
	i,l,lv: byte;
begin
	AddStack('My_pr.StrToVar');
	l:=SizeOfVar[tp]; lv:=Length(Value);
	for i:=1 to l do
    if i>lv then sr.s[i]:=' ' else sr.s[i]:=Value[i];
	result:=SvRecToVar(sr,tp);
  DelStack;
end;

function GetStrFile;
var i: THandle;
  j: longint;
  fl,NoHandle: boolean;
begin
	AddStack('My_pr.GetStrFile');
  NoHandle:=not Assigned(Handle);
  if NoHandle then Handle:=@i;
  Handle^:=FileBufOpen(FileName,fmShareDenyNone or fmOpenRead); fl := Handle^<>INVALID_HANDLE_VALUE;
  SetPBoolean(Succed,fl);
  if fl then begin
    j:=min(Count,Windows.GetFileSize(Handle^,nil)); SetLength(result,j);
    if ReadFile(Handle^,pointer(result)^,j,LongWord(j),nil)
    then SetLength(result,j) else result:='';
    if NoHandle then FileClose(Handle^);
	end
  else result:='';
  DelStack;
end;

function SetStrFile;
var i: THandle;
  j: longint;
  NoHandle: boolean;
begin
	AddStack('My_pr.SetStrFile');
  NoHandle:=not Assigned(Handle);
  if NoHandle then Handle:=@i;
  Handle^:=FileBufCreate(FileName); result := Handle^<>INVALID_HANDLE_VALUE;
  if not result then begin
    FileClrAttr(FileName); Handle^:=FileBufCreate(FileName); result := Handle^<>INVALID_HANDLE_VALUE;
  end;
  if result then begin
    j:=Length(Value); WriteFile(Handle^,pointer(Value)^,j,LongWord(j),nil);
    if NoHandle then FileClose(Handle^);
	end;
  DelStack;
end;

// Копирование файлов общего доступа
procedure CopyBufFile;
begin
	AddStack('My_pr.CopyBufFile');
  SetStrFile(Dest,GetStrFile(Source));
  DelStack;
end;

function ClipBoardErrorMessage;
const a: array[TClipboardType] of string = ('форма документа: объекты','описание переменной','описание вводимого поля');
begin
  AddStack('My_pr.ClipBoardErrorMessage');
  result:='Некорректный формат буфера обмена ('+a[ClipboardType]+')';
  DelStack;
end;

// Если в строке s в позиции p цифры - вернуть их (симв.)
function NumInStr(const s: string; p: longint): string;
var k: longint;
  function IsDig(c: Char): boolean;
  begin
  	result := IsDigit(c) or (c in ['.',',','-']);
  end;
begin
	AddStack('My_pr.NumInStr');
  result:=copy(s,p,1);
  if result<>'' then
    if IsDig(result[1]) then begin
      for k:=p-1 downto 1 do
        if IsDig(s[k]) then IncL(result,s[k]) else break;
      for k:=p+1 to Length(s) do
        if IsDig(s[k]) then IncD(result,s[k]) else break;
    end
    else result:='';
  DelStack;
end;

// Если в строке s в позиции X цифры - вернуть их (граф.)
function NumInStr(const s: string; lb,X: longint; Canvas: TCanvas): string;
var j,w,h: longint;
begin
	AddStack('My_pr.NumInStr(X)');
  h:=lb; result:='';
  for j:=1 to Length(s) do begin
    w:=Canvas.TextWidth(LeftStr(s,j));
    if InRange(X,h,lb+w-1) then begin
    	result:=NumInStr(s,j); break;
    end;
    h:=lb+w;
  end;
  DelStack;
end;

function MsgCalc;
begin
  AddStack('My_pr.MsgCalc');
  if Operation in [clcBegin,clcEnd] then begin
    ProcControlsMsg(Sender,WM_CALC,byte(Operation)); result:=true;
  end
  else result := Sender.perform(WM_CALC,byte(Operation),LongInt(ps))<>0;
  DelStack;
end;

procedure aGFLinesLoad;
var i,j: SmallInt;
	k: Byte;
begin
  AddStack('My_pr.aGFLinesLoad');
  if not Assigned(aGFLines) then begin
    New(aGFLines); k:=0;
    while k<2 do with aGFLines[k] do begin
      Width:=1; Color:=clBlack; Inc(k);
    end;
    for i:=low(AColor) to 15 do
      for j:=1 to MaxLineWidth do begin
        aGFLines[k].Width:=j; aGFLines[k].Color:=AColor[i]; Inc(k);
      end;
  end;
  DelStack;
end;

procedure GFObjDef;
begin
	AddStack('My_pr.GFObjDef');
  Finalize(result); ZeroMemory(@result,SizeOf(result));
	with result do begin
    TypeObj:=toText; Alignment:=algmCenter; Color:=SeekColor(clWhite);
  end;
  DelStack;
end;

function GFTypeLine;
begin
	AddStack('My_pr.GFTypeLine');
  result:=LnWidth;
	if LnWidth>1 then Inc(result,LnColor*MaxLineWidth);
  DelStack;
end;

function GFCopyParams;
var i: longint;
begin
  AddStack('My_pr.GFCopyParams');
  with Source do begin
    result.DateTime:=DateTime; SetLength(result.Arr,Length(Arr));
    for i:=low(Arr) to high(Arr) do result.Arr[i]:=Arr[i];
  end;
  DelStack;
end;

function PinRight;
begin
	result := Pin in [pinTopRight,pinBottomRight];
end;

function PinBottom;
begin
	result := Pin in [pinBottomLeft,pinBottomRight];
end;

function Mm10ToScr;
begin
  AddStack('My_pr.Mm10ToScr');
  result:=max(1,nRound(mm10/10/MmInInch*Screen.PixelsPerInch));
  DelStack;
end;

function NumToAlgm;
var av: Byte;
begin
	AddStack('My_pr.NumToAlgm');
	av := byte(v) div 3;
  result.VertAlignment:=PosToAlgm[av];
  result.HorzAlignment:=PosToAlgm[byte(v)-av*3];
  DelStack;
end;

function AlgmToNum;
begin
	AddStack('My_pr.AlgmToNum');
	result:=TGFAlgmList(AlgmToPos[v.VertAlignment]*3+AlgmToPos[v.HorzAlignment]);
  DelStack;
end;

procedure VarInit;
begin
  AddStack('My_pr.VarInit');
  Finalize(v); ZeroMemory(@v,SizeOf(v)); v.Enabled:=true;
  DelStack;
end;

procedure ShiftArg;
var i,j: longint;
begin
  AddStack('My_pr.ShiftArg');
  SetLength(ap,MAX_PRM-nShift); j:=nShift+1;
  for i:=low(ap) to high(ap) do begin
    ap[i]:=av[j]; Inc(j);
  end;
  DelStack;
end;

function InterPrmMax;
var i,j: ShortInt;
begin
  AddStack('My_pr.InterPrmMax');
  SetLength(result,MAX_PRM); i:=0;
  for j:=low(abeg) to high(abeg) do begin
    result[i]:=abeg[j]; Inc(i);
  end;
  j:=0;
  while i<MAX_PRM do begin
    Inc(j); result[i]:=Format('[Пар%d: любое]',[j]); Inc(i);
  end;
  DelStack;
end;

function FirstEngChar;
begin
  result := StrToChar(name) in ['A'..'Z','a'..'z'];
end;

function VarWithoutPrim;
begin
  AddStack('My_pr.VarWithoutPrim');
  result:=StrDivDlm(iChrPrim,name)[1];
  DelStack;
end;

function VarArrLenInit(var v: variant; var l: longint; lr0: longint; lr: PLongint = nil): boolean;
begin
  AddStack('My_pr.VarArrLenInit');
  if Assigned(lr) then begin
    MinSelf(lr0,KByte); lr^:=lr0;
  end;
  result := lr0>0;
  if result then v:=VarArrayCreate([1,lr0],varVariant) else result:=false;
  l:=0;
  DelStack;
end;

function VarArrLenInit(var v: variant; var l: longint; lr: PLongint = nil): boolean;
begin
  result:=VarArrLenInit(v,l,l,lr);
end;

procedure VarArrLenAdd;
begin
  AddStack('My_pr.VarArrLenAdd');
  Inc(l);
  if l>lr then begin
    ShlD(lr); VarArrayReDim(v,lr);
  end;
  DelStack;
end;

procedure VarArrLenSet;
begin
  AddStack('My_pr.VarArrLenSet');
  if l=0 then v:=false else VarArrayReDim(v,l);
  DelStack;
end;

function GetPrimTrans;
var i: longint;
  a: TArrStr;
begin
  AddStack('My_pr.GetPrimTrans');
  result := Pos(cGetPrim,s)>0;
  if result then begin
    i:=LsArrDynamic(s,a,cGetPrim); s:='';
    for i:=0 to i-1 do begin
      if i mod 2 <> 0 then GetPrimSelf(a[i]);
      if s<>'' then a[i]:=FLow(a[i]);
      IncD(s,a[i]);
    end;
  end;
  DelStack;
end;

function UnDataType(t: TFieldType): TFieldType;
begin
  {$IFDEF STACKALL}AddStack('My_pr.UnDataType');{$ENDIF}
  case t of
  	ftString,ftWideString: result:=ftString;
  	ftSmallint,ftInteger,ftWord,ftAutoInc,ftLargeint: result:=ftInteger;
    ftFloat,ftCurrency,ftBCD,ftFMTBcd: result:=ftFloat;
    ftDate,ftTime,ftDateTime,ftTimeStamp: result:=ftDate;
  else result:=t;
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function UnDataType(f: TField): TFieldType;
begin
  result:=UnDataType(f.DataType);
end;

procedure UnDataTypeSelf;
begin
  t:=UnDataType(t);
end;

function UnionDef;
begin
  AddStack('My_pr.UnionDef');
  result.table:=table; result.fld:=fld; result.where:=where; result.group:=group;
  DelStack;
end;

function qStrToDateTime;
	function Part(pos: longint; len: longint = 2): Word;
  begin
  	AddStack('My_pr.qStrToDateTime.Part');
  	result:=Int0(Copy(s,pos,len));
    DelStack;
  end;
begin
	AddStack('My_pr.qStrToDateTime');
	result:=EncodeDateTry(Part(1,4),Part(5),Part(7))
  	+EncodeTimeTry(Part(9),Part(11),Part(13),Part(15,MaxInt));
  DelStack;
end;

function FieldAsVariant;
begin
  AddStack('My_pr.FieldAsVariant');
	result:=null;
	if Assigned(f) then case UnDataType(f) of
    ftString: result:=PadR(f.AsString,f.Size);
  	ftInteger: result:=f.AsInteger;
    ftBoolean: result:=f.AsBoolean;
  	ftFloat: result:=f.AsFloat;
  	ftDate: result:=f.AsDateTime;
    ftMemo: result:=TrimSpRight(f.AsString);
  end;
  DelStack;
end;

function FieldAsString;
begin
  AddStack('My_pr.FieldAsString');
  if Assigned(f) then result:=TrimRight(f.AsString) else result:='';
  DelStack;
end;

procedure SetNumField;
begin
	AddStack('My_pr.SetNumField');
  fld.DisplayWidth:=nLen; fld.DisplayFormat:=NumDisplayFormat(nLen,nDec,ZeroEmp);
  DelStack;
end;

function NumDisplayFormat;
begin
  AddStack('My_pr.NumDisplayFormat');
  if nDec=0
  then result:=StringOfChar('#',nLen-1)+'0'
  else result:=StringOfChar('#',nLen-nDec-2)+'0.'+StringOfChar('0',nDec);
  if ZeroEmp then IncD(result,';;#');
  DelStack;
end;

procedure qSetParamValue(p: TObject; const Value: string);
var v: string;
begin
  {$IFDEF STACKALL}AddStack('My_pr.qSetParamValue');{$ENDIF}
  if StrToChar(Value)='"' then v:=StrTran(SubStr(Value,2,-1),'""','"') else v:=Value;
  if p is TParam then with TParam(p) do
    if v=sNULL then begin
      DataType:=ftDateTime; Value:=UnAssigned;
    end
    else AsString:=v
  else with TFIBXSQLVAR(p) do
    if v=sNULL then Value:=UnAssigned else AsString:=v;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function QQs(const s: string = ''; lTrim: boolean = true): string;
begin
	AddStack('My_pr.QQs');
  result:=StrTran(s,cQQ,cQQ+cQQ);
  if lTrim then TrimRightSelf(result);
	IncL(result,cQQ,cQQ);
  DelStack;
end;

function QQs(f: TField; lTrim: boolean = true): string;
begin
  result:=QQs(f.AsString,lTrim);
end;

procedure QQsSelf(var s: string; lTrim: boolean = true);
begin
  s:=QQs(s,lTrim);
end;

procedure QQsSelf(var s: variant; lTrim: boolean = true);
begin
  s:=QQs(s,lTrim);
end;

function QQi(i: longint): string;
begin
  result:=QQs(IntToStr(i));
end;

function QQi(const v: variant; nlen: longint): string;
begin
  result:=QQs(SpaceStr(v,nlen));
end;

procedure QQiSelf(var s: string; nlen: longint);
begin
  s:=QQi(s,nlen);
end;

function QQa(const Source: array of string; l: longint = NegDef): TArrStr;
begin
  AddStack('My_pr.QQa(as)');
  ReplNegSelf(l,Source); SetLength(result,l);
  for l:=0 to l-1 do result[l]:=QQs(Source[l]);
  DelStack;
end;

function QQa(const Source: array of longint; l: longint = NegDef): TArrStr;
begin
  AddStack('My_pr.QQa(ai)');
  ReplNegSelf(l,Source); SetLength(result,l);
  for l:=0 to l-1 do result[l]:=Vtos(Source[l]);
  DelStack;
end;

function QQa(Source: TStrings): TArrStr;
var i: longint;
begin
  AddStack('My_pr.QQa(ls)');
  SetLength(result,Source.Count);
  for i:=low(result) to high(result) do result[i]:=QQs(Source[i]);
  DelStack;
end;

function QQNull;
begin
  {$IFDEF STACKALL}AddStack('My_pr.QQNull');{$ENDIF}
  result:=BracketNot(nmf+sISNULL+sOR+nmf+'='+VToS(v,true),lnot);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function VToS(const v: variant; lQQ: boolean = false): string;
begin
	{$IFDEF STACKALL}AddStack('My_pr.VToS');{$ENDIF}
	case MyVarType(v) of
		varInteger:result:=IntToStr(v);
		varString: begin
    	result:=v;
			if lQQ then QQsSelf(result)
			else if copy(result,1,1)=QQ then result:=QQs(copy(result,2,MaxInt));
		end;
		varBoolean: result:=cQQ+Bool2Str(v)+cQQ;
		varDouble: result:=StrTran(Trim(VarAsType(v,varString)),DecimalSeparator,'.');
	else
  	result:='';
		if lQQ then QQsSelf(result);
	end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function VToS(f: TField; lQQ: boolean = false): string;
begin
  result:=VToS(f.Value,lQQ);
end;

function VToS: string;
begin
  result:=VToS(0);
end;

function FldIsTrue;
begin
  AddStack('My_pr.FldIsTrue');
  result:=nmf+aqEq[lEq]+Vtos(true);
  DelStack;
end;

function FldInList(var ares: TArrStr; const nmf: string; const azn: array of string;
  l: longint = NegDef; Opt: TFldInListOpt = []): boolean;
const CntFldInList = 500;
var i,cnt,lr,ln,ln1: longint;
	s: string;
  a: TArrStr;
  ls: TStringList;
  lnot: boolean;
begin
	AddStack('My_pr.FldInList(a)');
  ReplNegSelf(l,azn); result := l>0;
  if result then begin
    if flsUnique in Opt then begin
      ls:=SortStrListCreate;
      try
        ls.Capacity:=l;
        for i:=0 to l-1 do ls.Add(azn[i]);
        if ls.Count=l then Exclude(Opt,flsUnique)
        else begin
          l:=ls.Count; CopyFrom(a,ls);
        end;
      finally
        ls.Free;
      end;
    end;
    SetLength(ares,1); ares[0]:=''; lr:=0; ln:=0; i:=0; lnot:=flsNot in Opt;
    while i<l do begin
      cnt:=min(CntFldInList,l-i);
      if flsUnique in Opt then s:=ArrayAsList(a,',',cnt,false,i) else s:=ArrayAsList(azn,',',cnt,false,i);
      s:=IfThen(ln<>0,aInList[lnot,1])
        +nmf+IfThen(cnt=1,aqEq[not lnot]+s,aInList[lnot,2]+sIN+'('+s+')');
      ln1:=ln+Length(s);
      if i>0{ln1>32768} then begin
        Inc(lr); SetLength(ares,lr+1); ares[lr]:='';
        if ln>0 then Delete(s,1,Length(aInList[lnot,1]));
        ln:=Length(s);
      end
      else ln:=ln1;
      IncD(ares[lr],s); Inc(i,CntFldInList);
    end;
  end
  else ares:=nil;
  DelStack;
end;

function FldInList(const nmf: string; const azn: array of string;
  l: longint = NegDef; Opt: TFldInListOpt = []): string;
var a: TArrStr;
begin
  AddStack('My_pr.FldInList');
  FldInList(a,nmf,azn,l,Opt); result:=BrackNoEmp(ArrayAsList(a,aInList[flsNot in Opt,1]));
  DelStack;
end;

function FldInListQQ(const nmf: string; const Source: array of string;
  l: longint = NegDef; Opt: TFldInListOpt = []): string;
begin
  AddStack('My_pr.FldInListQQ(as)');
  result:=FldInList(nmf,QQa(Source,l),NegDef,Opt);
  DelStack;
end;

function FldInListQQ(const nmf: string; const Source: string): string;
var a: TArrStr;
  l: longint;
begin
  AddStack('My_pr.FldInListQQ(s)');
  l:=LsArrDynamic(Source,a,','); result:=FldInListQQ(nmf,a,l);
  DelStack;
end;

function FldInListQQ(const nmf: string; const Source: array of longint): string;
begin
  AddStack('My_pr.FldInListQQ(ai)');
  result:=FldInList(nmf,QQa(Source));
  DelStack;
end;

function FldInListQQ(var ares: TArrStr; const nmf: string; const Source: array of string; l: longint = NegDef): boolean;
begin
  AddStack('My_pr.FldInListQQ(a,a)');
  result:=FldInList(ares,nmf,QQa(Source,l));
  DelStack;
end;

function FldInListQQ(const nmf: string; Source: TStrings; lNot: boolean = false): string;
begin
  AddStack('My_pr.FldInListQQ(ls)');
  result:=FldInList(nmf,QQa(Source),NegDef,IfThen(lNot,flsNot));
  DelStack;
end;

function FldInListQQ(var ares: TArrStr; const nmf: string; Source: TStrings; lNot: boolean = false): boolean;
begin
  AddStack('My_pr.FldInListQQ(a,ls)');
  result:=FldInList(ares,nmf,QQa(Source),NegDef,IfThen(lNot,flsNot));
  DelStack;
end;

function RecnoWhere(const rno: string; lEq: boolean = true): string;
begin
  AddStack('My_pr.RecnoWhere');
  result := IfThen((Int0(rno)>0) or lEq, fRECNO+aqEq[lEq]+rno);
  DelStack;
end;

function RecnoWhere(rno: longint; lEq: boolean = true): string;
begin
  result:=RecnoWhere(Vtos(rno),lEq);
end;

function RecnoWhere(f: TField; lEq: boolean = true): string;
begin
  result:=RecnoWhere(f.AsInteger,lEq);
end;

function IsSQLLocalPath;
var a: TArrSQLPath;
  ap: array[1..3] of string;
begin
  AddStack('My_pr.IsSQLLocalPath');
  PointerDef(pointer(pa),@a); result := ListAsArray(path,ap,DriveDelim)<3; pa.IP:=ap[1]; pa.Drv:=Trim(ap[2]); pa.Path:=Trim(ap[3]);
  LsArrFill(pa.IP,ap,'/'); pa.IP:=Trim(ap[1]); pa.Port:=Trim(ap[2]);
  if pa.Port<>'' then result:=false;
  DelStack;
end;

function QryNone(lAll: boolean = false): string;
begin
  result:=BrackNoEmp('0'+aqEq[lAll]+'0');
end;

function QryNone(const s: string; lAll: boolean = false): string;
begin
  result:=IfThen(s='',QryNone(lAll),s);
end;

function IncAnd(var d: string; const d2: string): boolean;
begin
  result := d2<>'';
  if result then IncD(d,sAND+d2);
end;

procedure IncAnd(var d: string);
begin
  if d<>'' then IncL(d,sAND);
end;

function PrimFld(var prim: string; const nmf: string; const af,ap: array of string): boolean;
var i: longint;
begin
  AddStack('My_pr.PrimFld');
  result:=AnsiFindText(nmf,af,i);
  if result then prim:=ap[i];
  DelStack;
end;

function PrimFld(var prim: string; const nmf,sf,sp: string): boolean;
begin
  result:=PrimFld(prim,nmf,[sf],[sp]);
end;

function PrimFldNum(var prim: string; const nmf,nmfbeg,Fmt: string): boolean;
var n: longint;
begin
  result:=PrimFldNum(n,nmf,nmfbeg);
  if result then prim:=Format(Fmt,[n]);
end;

function PrimFldNum(var prim: string; const nmf,nmfbeg: string;
  const a: array of string; low: longint = 0; const Fmt: string = '%s'): boolean;
var n: longint;
begin
  result:=PrimFldNum(n,nmf,nmfbeg);
  if result then prim:=Format(Fmt,[a[n-low]]);
end;

function PrimFldNum(const nmf,nmfbeg: string): boolean; overload;
var n: longint;
begin
  result:=PrimFldNum(n,nmf,nmfbeg);
end;

function PrimFldNum(var n: longint; const nmf,nmfbeg: string): boolean; overload;
var i,l,lb: byte;
  lNum: boolean;
begin
  AddStack('My_pr.PrimFldNum');
  l:=Length(nmf); lb:=Length(nmfbeg); result:=l>lb;
  if result then begin
    lNum:=false;
    for i:=1 to l do
      if lNum then begin
        if not IsDigit(nmf[i]) then begin
          result:=false; break;
        end
      end
      else if nmf[i]<>nmfbeg[i] then begin
        result:=false; break;
      end
      else if i=lb then lNum:=true;
    if result then n:=Int0(Copy(nmf,lb+1,MaxInt));
  end;
  DelStack;
end;

function TransPrim(const prim: string): string;
begin
  AddStack('My_pr.TransPrim');
  result:=IfThenTrans(PrimTrans,prim);
  DelStack;
end;

function TransPrim(const prim: array of string): TArrStr;
var i: longint;
begin
  AddStack('My_pr.TransPrim(a)');
  CopyFrom(result,prim);
  for i:=low(result) to high(result) do TransPrimSelf(result[i]);
  DelStack;
end;

procedure TransPrimSelf;
begin
  prim:=TransPrim(prim);
end;

function GetDataIniFileExisting;
  procedure fIni(const f: TFileName);
  begin
    AddStack('My_pr.GetDataIniFileExisting.fIni');
    fn:=path+f+'.INI';
    if IsGGI(fn) then GetIniFileNameSelf(fn);
    result:=MyFileExists(fn);
    DelStack;
  end;
begin
  AddStack('My_pr.GetDataIniFileExisting');
  fIni('DATA');
  if not result then fIni('SAVE');
  DelStack;
end;

function FieldAsStr;
var ost: longint;
begin
  ost:=AddStack('My_pr.FieldAsStr');
  try
    result:=TrimRight(f.DisplayText);
  except
    SetStack(ost);
    result:='';
  end;
  DelStack;
end;

function DDVar2Str(const v: variant; ft: TFieldType; Len: longint; Dec: Word): string;
begin
  AddStack('My_pr.DDVar2Str');
  case ft of
    ftString: result:=Padr(v,Len);
    ftInteger,ftFloat: result:=SpaceStr0(v,Len,Dec);
    ftBoolean: result:=Bool2Str(v);
    ftDate: result:=dtoc(v);
  else result:=v;
  end;
  DelStack;
end;

function DDVar2Str(const v: variant; inf: PDDatKvInfo): string;
begin
  result:=DDVar2Str(v,inf.ft,inf.Len,inf.Dec);
end;

function DDStr2Var(const s: string; inf: PDDatKvInfo): variant;
begin
  AddStack('My_pr.DDStr2Var');
  case inf.ft of
    ftString: result:=Padr(s,inf.Len);
    ftInteger,ftFloat: result:=Float0(s);
    ftBoolean: result:=StrToBoolean(s);
    ftDate: result:=ctod(s);
  else result:=s;
  end;
  DelStack;
end;

function DDZnType;
begin
  result:=iif(r.AType=dwtSel,ddznSel,ddznSimple);
end;

function DDGetD2;
begin
  AddStack('My_pr.DDGetD2');
  if inf.td2=dd2Period then
    case inf.tp of
      ddtQuart: result:=IncMonth(d1,2);
      ddtYear: result:=IncMonth(d1,11);
    else result:=d1;
    end
  else result:=IfThen((d2=DateEmpty) or (inf.td2 in [dd2Big,dd2All]),DateBig,d2);
  DelStack;
end;

function IncPer(d: TDateTime; tp: TDDatType; offs: TValueSign = 1): TDateTime;
begin
  AddStack('My_pr.IncPer');
  case tp of
    ddtMonth: result:=StartOfTheMonth(IncMonth(d,offs));
    ddtQuart: result:=boq(IncMonth(d,high(TQuartMonth)*offs));
    ddtYear: result:=StartOfTheYear(IncYear(d,offs));
  else result:=d+offs;
  end;
  DelStack;
end;

function IncPer(d: TDateTime; inf: PDDatKvInfo; offs: TValueSign = 1): TDateTime; 
begin
  result:=IncPer(d,inf.tp,offs);
end;

procedure IncPerSelf(var d: TDateTime; tp: TDDatType; offs: TValueSign = 1);
begin
  d:=IncPer(d,tp,offs);
end;

procedure IncPerSelf(var d: TDateTime; inf: PDDatKvInfo; offs: TValueSign = 1);
begin
  d:=IncPer(d,inf,offs);
end;

function DDGetWhere(const Cod: string; vid: longint): string;
begin
  AddStack('My_pr.DDGetWhere');
  result:=tDDAT+'.'+fDDCod+IfThen(RightStr(Cod,1)='%',sLIKE,'=')+QQs(Cod)+sAND+tDDAT+'.'+fDDVid+'='+Vtos(vid);
  DelStack;
end;

function DDGetWhere(const Cod: string; vid: longint; const kv: string): string;
begin
  AddStack('My_pr.DDGetWhere(kv)');
  result:=DDGetWhere(Cod,vid)+sAND+tDDAT+'.'+fDDKv+'='+QQs(kv);
  DelStack;
end;

function DDGetWhere(vid: longint; const kv: string): string;
begin
  result:=ArrayAsList([tDDAT+'.'+fDDVid+'='+Vtos(vid),tDDAT+'.'+fDDKv+'='+QQs(kv)],sAND);
end;

function DoDDatSetValProc;
begin
  AddStack('My_pr.DoDDatSetValProc');
  result:=true; IfThenDDatSetVal(DDatSetValProc,op,result);
  DelStack;
end;

function DDatLsProc;
var i: longint;
begin
  AddStack('My_pr.DDatLsProc');
  result:=false;
  for i:=low(aDDatLsProc) to high(aDDatLsProc) do aDDatLsProc[i](result,Sender,op,p);
  DelStack;
end;

const aDEDlm: array[1..4] of TDEPrmList = (deCaption,deMask,deSayHint,deGetHint);

function DEGetArrParam;
var i: byte;
begin
  AddStack('My_pr.DEGetArrParam');
  LsArrFill(s,result,UnDelim);
  for i:=low(aDEDlm) to high(aDEDlm) do StrTranSelf(result[aDEDlm[i]],sDEDlm,UnDelim);
  DelStack;
end;

function DESetArrParam;
var a: TDEPrmStr;
	i: byte;
begin
  AddStack('My_pr.DESetArrParam');
  a:=ac;
  for i:=low(aDEDlm) to high(aDEDlm) do a[aDEDlm[i]]:=StrTran(ac[aDEDlm[i]],UnDelim,sDEDlm);
  result:=ArrayAsList(a,UnDelim,NegDef,true);
  DelStack;
end;

procedure DEPageSynchro;
	procedure pAdd(j: longint);
  begin
    AddStack('My_pr.DEPageSynchro.pAdd');
    lsPage.Add(StrNum('Страница ',j+1)+UnDelim+'1');
    DelStack;
  end;
var i,j: longint;
	a: TDEPrmStr;
  op: boolean;
  a1: array[1..4] of string;
begin
  AddStack('My_pr.DEPageSynchro');
  j:=0; lsPage.BeginUpdate; op := lsPage.Count>0;
  if op then LsArrFill(lsPage[0],a1,UnDelim);
	for i:=1 to lsField.Count-1 do begin
  	a:=DEGetArrParam(lsField[i]);
    if StrToBoolean(a[deNewPage]) and not StrToBoolean(a[deNoVisible]) then begin
    	if lsPage.Count=j then begin
      	pAdd(j);
        if j=0 then pAdd(1);
      end;
      Inc(j);
      if j=1 then Inc(j);
    end;
  end;
  while lsPage.Count>j do lsPage.Delete(j);
  if op<>(lsPage.Count>0) then
    if op then begin
      if (a1[2]='0') and not DcmBased then begin
        DcmBased:=true; DcmDef:=a1[3];
      end;
    end
    else if DcmBased then begin
      LsArrFill(lsPage[0],a1,UnDelim);
      if a1[2]<>'0' then begin
        a1[2]:='0'; a1[3]:=DcmDef; lsPage[0]:=ArrayAsList(a1,UnDelim);
      end;
    end;
  lsPage.EndUpdate;
  DelStack;
end;

function DEPgSortMode;
begin
  AddStack('My_pr.DEPgSortMode');
  result:=iif(AnsiMatchStr(sm,[bTrue,'2']),smColumns,iif(sm='3',smRows,smDefault));
  DelStack;
end;

function DEPgSortName;
const a: array[TSortMode] of string =
	('обычная    '
  ,'по колонкам'
  ,'по строкам ');
begin
  AddStack('My_pr.DEPgSortName');
  result:=IfThen(DcmBased
  ,'по форме   '
  ,a[SortMode]);
  DelStack;
end;

function DEVArrToArrParam;
var a: TDEPrmStr;
  i: TDEPrmList;
	n2,j: longint;
begin
  AddStack('My_pr.DEVArrToArrParam');
  j:=low(aPrm); n2:=high(aPrm);
  for i:=low(a) to high(a) do begin
    a[i]:='';
    if j<=n2 then begin
      case MyVarType(aPrm[j]) of
        varInteger: a[i]:=IntToStr(aPrm[j]);
        varBoolean: a[i]:=Bool2Str(aPrm[j]);
        varString: a[i]:=aPrm[j];
      end;
      Inc(j);
    end;
  end;
  result:=DESetArrParam(a);
  DelStack;
end;

function DEArr2CharCase;
begin
  AddStack('My_pr.DEArr2CharCase');
  result:=TDECharCase(EnsureRange(Int0(a[deCharCase]),byte(low(aDECharCase)),byte(high(aDECharCase))));
  DelStack;
end;

procedure ReplaceNameRec(ls: TStrings; const OldNmRec,NewNmRec: string);
var i: longint;
  a: TDEPrmStr;
  onm: string;
  fl: boolean;
  aRel: array[1..2] of string;
begin
	AddStack('My_pr.ReplaceNameRec');
  onm:=TrimUpper(OldNmRec);
  if onm<>TrimUpper(NewNmRec) then for i:=0 to ls.Count-1 do begin
    a:=DEGetArrParam(ls[i]); fl:=false;
    if (onm='') or (TrimUpper(a[deNameRec])=onm) then begin
      a[deNameRec]:=NewNmRec; fl:=true;
    end;
    if not empty(a[deRelation]) then begin
      LsArrFill(a[deRelation],aRel,'.');
      if (onm='') or (TrimUpper(aRel[1])=onm) then begin
        a[deRelation]:=NewNmRec+'.'+aRel[2]; fl:=true;
      end;
    end;
    if fl then ls[i]:=DESetArrParam(a);
  end;
  DelStack;
end;

function VarNmToRec;
begin
  AddStack('My_pr.VarNmToRec');
  result:=StrDivDlm('_',VarName); TrimUpperSelf(result[1]);
  if lUpFld then TrimUpperSelf(result[2]);
  DelStack;
end;

function VarCreateTypes;
const atypes: array[TDWFldType] of char = ('C','F','D','L','C','C','C','C','C');
begin
  AddStack('My_pr.VarCreateTypes');
  result:=IfThen((r.AType=dwtFloat) and (r.Dec=0) or (r.AType=dwtSel) and (r.SelType=selInt),'I',atypes[r.AType]);
  DelStack;
end;

procedure DWPrmSearchGF;
begin
	AddStack('My_pr.DWPrmSearchGF');
  TTimerOne.CreateProc(TNone.DWPrmSearchGF,nil,[SearchInfo.GFType,SearchInfo.NumObj]);
  DelStack;
end;

class procedure TNone.DWPrmSearchGF;
begin
	AddStack('TNone.DWPrmSearchGF');
  with TTimerOne(Sender) do Enabled := LastForm.Perform(WM_GFSEEKOBJ,Params[0],Params[1])=0;
  DelStack;
end;

procedure CodManyStr(var a: TArrStr; AType: TDWFldType; const Cod: string);
begin
  AddStack('My_pr.CodManyStr');
  if AType=dwtManyStr then LsArrDynamic(Cod,a,',',lsaSetLen)
  else begin
    SetLength(a,1); a[0]:=TrimRight(Cod);
  end;
  DelStack;
end;

procedure CodManyStr(var a: TArrStr; const rv: TDWVidRec);
begin
  AddStack('My_pr.CodManyStr(rv)');
  CodManyStr(a,rv.AType,rv.dwCod);
  DelStack;
end;

procedure DWTypeMany(Proc: TDWTypeManyProc; Oper: TDWTypeManyOper; const av: array of variant);
begin
  AddStack('My_pr.DWTypeMany');
  if Assigned(Proc) then Proc(Oper,av);
  DelStack;
end;

procedure DWTypeMany(Oper: TDWTypeManyOper; const av: array of variant);
begin
  DWTypeMany(DWTypeManyProc,Oper,av);
end;

function InterEdStrTypes;
var j: byte;
  a: TArrStr;
begin
  AddStack('My_pr.InterEdStrTypes');
  if types='' then result:=''
  else begin
    SetLength(a,Length(types));
    for j:=low(a) to high(a) do case types[j+1] of
      '*': a[j]:='любое';
      'A': a[j]:='массив';
      'C','S': a[j]:='строка';
      'D': a[j]:='дата';
      'F','N': a[j]:='число';
      'I': a[j]:='целое';
      'L': a[j]:='логическое';
      'U': a[j]:='пусто';
    end;
    result:=DlmBetween(ArrayAsList(a,',',Length(a)-1),a[high(a)],' или ');
  end;
  DelStack;
end;

function EdTextView;
var vtxt: string;
begin
  vtxt:=txt;
  result:=EdTextExec(capt,vtxt,dname,dfunc,Opt+[edtxtReadOnly],EdType,crStart,crLen,InfStr,hc,
    AfterShow,MsgErrBig,PrEditIfError,pav,FileName,BeforeShow,ChangeFileName,HelpProc,PrMaxLength);
end;

function BrFindAll;
var p: PPswdPrm;
begin
  AddStack('My_pr.BrFindAll');
  if IsPswdPrm(p) then result:=p.BrFindAll else result:=false;
  DelStack;
end;

function FindRegistrStr;
begin
  AddStack('My_pr.FindRegistrStr');
  if lTrim then result:=Trim(s) else result:=s;
  if not FindProperty.Registr then AnsiUpperCaseSelf(result);
  DelStack;
end;

function ProcInStr(lRepl: boolean; var ss: string; const sf,sr: string; pSelStart,pSelLength: PLongInt;
  PrRepl: TReplaceProc; pav: PVariant): variant;
var i,l,lf: longint;
	s,f: string;
  lForward: boolean;
  function PosNext: boolean;
    function IsWord(i: longint): boolean;
    begin
      AddStack('My_pr.ProcInStr.PosNext.NoWord');
      if InRange(i,1,l) then result:=IsChrWord(s[i]) else result:=false;
      DelStack;
    end;
  var j: longint;
  begin
  	AddStack('My_pr.ProcInStr.PosNext');
    repeat
      if lForward then i:=PosEx(f,s,i)
      else begin
        Dec(i); j:=lf;
        while i>0 do begin
          if s[i]=f[j] then
            if j=1 then break else Dec(j)
          else j:=lf;
          Dec(i);
        end;
      end;
      result := i>0;
      if result and FindProperty.Word then
        if IsWord(i-1) or IsWord(i+lf) then begin
          result:=false;
          if lForward then Inc(i,lf);
        end;
    until result or not InRange(i,1,l);
    DelStack;
  end;
var cnt,lr: longint;
begin
  AddStack('My_pr.ProcInStr');
  s:=FindRegistrStr(ss,false); f:=FindRegistrStr(sf,false); cnt:=0;
  if GetPLongInt(pSelStart,i) then lForward := FindProperty.Direction<>fndBack
  else begin
    lForward:=true; i:=1;
  end;
  l:=Length(s); lf:=Length(f); lr:=Length(sr);
  if lForward and Assigned(pSelLength) then Inc(i,pSelLength^);
  if lRepl then begin
    while PosNext do begin
      case ReplaceProc(PrRepl,pav,[ss,i],cnt) of
        mrCancel: break;
        mrYes: begin
          StuffStrSelf(ss,i,lf,sr); StuffStrSelf(s,i,lf,sr); Inc(i,lr);
        end;
      else Inc(i,lf);
      end;
    end;
    result:=cnt;
  end
  else begin
    result:=PosNext;
    if result then begin
      SetPLongInt(pSelStart,i); SetPLongInt(pSelLength,lf);
    end;
  end;
  DelStack;
end;

function FindInStr(const ss,sf: string; pSelStart: PLongInt = nil; pSelLength: PLongInt = nil): boolean;
var s: string;
begin
  AddStack('My_pr.FindInStr');
  s:=ss; result:=ProcInStr(false,s,sf,'',pSelStart,pSelLength,nil,nil);
  DelStack;
end;

function FindInStr(const sf: string; const ss: array of string): boolean;
var i: longint;
begin
  AddStack('My_pr.FindInStr(a)');
  result:=false;
  for i:=low(ss) to high(ss) do if FindInStr(ss[i],sf) then begin
    result:=true; break;
  end;
  DelStack;
end;

function ReplaceInStr(var ss: string; const sf,sr: string;
  PrRepl: TReplaceProc = nil; pav: PVariant = nil): longint;
begin
  AddStack('My_pr.ReplaceInStr');
  result:=ProcInStr(true,ss,sf,sr,nil,nil,PrRepl,pav);
  DelStack;
end;

function ReplaceInStr(const sf,sr: string; const ss: array of PString;
  PrRepl: TReplaceProc = nil; pav: PVariant = nil): longint;
var i,cnt: longint;
begin
  AddStack('My_pr.ReplaceInStr(a)');
  result:=0;
  for i:=low(ss) to high(ss) do begin
    cnt:=ReplaceInStr(ss[i]^,sf,sr,PrRepl,pav);
    if cnt<0 then begin
      result:=cnt; break;
    end;
    Inc(result,cnt);
  end;
  DelStack;
end;

function SetFindPropertyIdent;
begin
  AddStack('My_pr.SetFindPropertyIdent');
  result:=FindProperty;
  if lIdent then begin
    FindProperty.Word:=true; FindProperty.Registr:=false;
  end;
  DelStack;
end;

function HelpFindAvk;
var j,l: longint;
label lend;
begin
  AddStack('My_pr.HelpFindAvk');
  result:=false; i:=0; l:=Length(a);
  while i<l do with a[i] do begin
    for j:=low(avk) to high(avk) do if CompVar(avk[j],vk) then begin
      result:=true; goto lend;
    end;
    Inc(i);
  end;
lend:
  DelStack;
end;

function HelpTblVar(const v,ind: variant; lSave: boolean): variant;
var i,j: longint;
  vr: variant;
label lend;
begin
  AddStack('My_pr.HelpTblVar');
  result:=null;
  for i:=low(aHelpTblProc) to high(aHelpTblProc) do begin
    aHelpTblProc[i]('',vr);
    for j:=VarArrayLowBound(vr,1) to VarArrayHighBound(vr,1) do if vr[j][0]=ind then begin
      result:=vr[j]; goto lend;
    end;
  end;
lend:
  DelStack;
end;

function HelpTblVarName(const Name: string): string;
var va: variant;
begin
  AddStack('My_pr.HelpTblVarName');
  va:=HelpTblVar(null,Name,false); result:=va[0]+'\'+va[1];
  DelStack;
end;

function HelpTblArr;
var i: longint;
begin
  AddStack('My_pr.HelpTblArr');
  result:=null;
  for i:=low(aHelpTblProc) to high(aHelpTblProc) do begin
    aHelpTblProc[i](Name,result);
    if MyVarType(result)=varArray then break;
  end;
  DelStack;
end;

function HelpBoldStr(const s: string; Style: THelpStyleList = SCE_OURLIB_HELP_BOLD): string;
begin
  result:=Chr(Style-SCE_OURLIB_HELP_BEG+1)+s+cBoldDlm;
end;

function HelpBoldStr(const s: string; lBold: boolean): string; overload;
begin
  if lBold then result:=HelpBoldStr(s) else result:=s;
end;

function HelpBoldStr(const s: string; const sPage: string; const sFile: string): string;
begin
  result:=HelpBoldStr(s+cBoldDlm+sFile+cBoldDlm+sPage,SCE_OURLIB_HELP_LINK);
end;

function HelpBoldStr(const s: string; const hf: THelpFile): string;
begin
  result:=HelpBoldStr(s,hf.sPage,hf.sFile);
end;

function HelpBoldStr(const s: string; const sPart: string; Vid: THelpLinkList): string;
var sp: string;
begin
  sp:=sPart;
  if Vid=hlnkInterMemo then
    if sp='' then sp:=s
    else if sp[1]='(' then sp:=s+'()';
  result:=HelpBoldStr(s,sp,StrNum(cBoldVid,Vid));
end;

function HelpBoldStr(const s: string; Vid: THelpLinkList): string;
begin
  result:=HelpBoldStr(s,'',Vid);
end;

function HelpBoldStr(const s: string; const Tbl: THelpTbl): string;
begin
  AddStack('My_pr.HelpBoldStr(tbl)');
  result:=HelpBoldStr(s,HelpTbl2Str(Tbl),hlnkTbl);
  DelStack;
end;

function HelpBoldStr(const s: string; const Head: string;
  const Dat: array of string; DatLow: longint = 0): string;
var Tbl: THelpTbl;
  i: longint;
begin
  AddStack('My_pr.HelpBoldStr(a)');
  Tbl.Head:=Head; SetLength(Tbl.Dat,Length(Dat));
  for i:=low(Dat) to high(Dat) do CopyFrom(Tbl.Dat[i],[HelpBoldStr(IntToStr(DatLow+i)),Dat[i]]);
  result:=HelpBoldStr(s,Tbl);
  DelStack;
end;

procedure HelpBoldStrSelf(var s: string; Style: THelpStyleList = SCE_OURLIB_HELP_BOLD);
begin
  s:=HelpBoldStr(s,Style);
end;

procedure HelpBoldStrSelf(var s: string; const sPart: string; Vid: THelpLinkList);
begin
  s:=HelpBoldStr(s,sPart,Vid);
end;

procedure HelpBoldStrSelf(var s: string; const Head: string;
  const Dat: array of string; DatLow: longint = 0);
begin
  s:=HelpBoldStr(s,Head,Dat,DatLow);
end;

function HelpTbl2Str;
var sr: string;
  i,j: longint;
begin
  AddStack('My_pr.HelpTbl2Str');
  with Tbl do begin
    result:=Head+IfThen(Dat0<>'',cBoldCol+Dat0);
    for i:=low(Dat) to high(Dat) do begin
      sr:='';
      for j:=low(Dat[i]) to high(Dat[i]) do IncD(sr,cBoldCol+Dat[i,j]);
      IncD(result,cBoldRow+StrShifr(System.Copy(sr,2,MaxInt)));
    end;
  end;
  DelStack;
end;

function HelpStr2Tbl;
var i,l: longint;
  a: TArrStr;
  ah: TNamePrimStr;
begin
  AddStack('My_pr.HelpStr2Tbl');
  l:=LsArrDynamic(s,a,cBoldRow); result := l>0;
  if result then with ht do begin
    ah:=StrDivDlm(cBoldCol,a[0]); Head:=TransPrim(ah[1]); Dat0:=TransPrim(ah[2]); SetLength(Dat,l-1);
    for i:=0 to l-2 do 
      for l:=0 to LsArrDynamic(StrDeShifr(a[i+1]),Dat[i],cBoldCol,lsaSetLen)-1 do TransPrimSelf(Dat[i,l]);
  end;
  DelStack;
end;

function HelpTbl2Arr;
var j,k: longint;
  function ReBold: string;
  begin
    AddStack('FHelpLs.LinkAdd.ReBold');
    result:=HelpReBoldStr(ht.Dat[j,k]);
    DelStack;
  end;
var lnm,i: longint;
  ac: TArrInt;
begin
  AddStack('My_pr.HelpTbl2Arr');
  lnm:=0;
  for j:=low(ht.Dat) to high(ht.Dat) do MaxSelf(lnm,Length(ht.Dat[j]));
  result := lnm>0;
  if result then begin
    SetLength(ac,lnm-1);
    if lnm>1 then ZeroMemory(@ac[0],SizeOf(ac[0])*(lnm-1));
    for j:=low(ht.Dat) to high(ht.Dat) do begin
      k:=Length(ht.Dat[j]); SetLength(ht.Dat[j],lnm); InitArr(ht.Dat[j],k,lnm-1);
      for k:=0 to lnm-2 do MaxSelf(ac[k],ReBold);
    end;
    for k:=0 to lnm-2 do Inc(ac[k]);
    i:=Length(pArr^); SetLength(pArr^,i+1);
    with pArr^[i] do begin
      part:=ht.Head; txt:=ht.Dat0;
      for j:=low(ht.Dat) to high(ht.Dat) do begin
        IncD(txt,CRLF);
        for k:=0 to lnm-2 do IncD(txt,ht.Dat[j,k]+Space(ac[k]-Length(ReBold)));
        IncD(txt,ht.Dat[j,lnm-1]);
      end;
    end;
  end;
  DelStack;
end;

procedure HelpTblAddDcm;
begin
  AddStack('My_pr.HelpTblAddDcm');
  Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr(ReplVar(Capt,'Форма документа'),'ContDcm',HelpFileStd));
  DelStack;
end;

function HelpBool;
begin
  AddStack('My_pr.HelpBool');
  result:=HelpIf(Capt,'"'+bStr[not lInvert]+'"','"'+bStr[lInvert]+'"');
  DelStack;
end;

procedure HelpBoolSelf;
begin
  Capt:=HelpBool(Capt,lInvert);
end;

function HelpNum;
begin
  AddStack('My_pr.HelpNum');
  result:=HelpBoldStr('СТРОКА','(',hlnkInterMemo)+'('+HelpBoldStr(Capt,lBold)+Format(IfThen(d>0,',,%d'),[d])+')';
  DelStack;
end;

procedure HelpNumSelf;
begin
  Capt:=HelpNum(Capt,lBold,d);
end;

function HelpDate;
begin
  AddStack('My_pr.HelpDate');
  result:=HelpBoldStr('ДАТА_СТРОКА','(',hlnkInterMemo)+'('+HelpBoldStr(Capt)+')';
  DelStack;
end;

procedure HelpDateSelf;
begin
  Capt:=HelpDate(Capt);
end;

function HelpStruct;
begin
  AddStack('My_pr.HelpStruct');
  ReplNegSelf(l,aStr); result:=HelpBoldStr('СТРУКТУРА',hlnkInterMemo)+' '+ArrayAsList(aStr,','+IfThen(l>10,' '),l);
  DelStack;
end;

function HelpIf;
begin
  AddStack('My_pr.HelpIf');
  result:=HelpBoldStr('ВЫБОР','(',hlnkInterMemo)+'('+HelpBoldStr(AValue,lBold)+','+ATrue+','+AFalse+')';
  DelStack;
end;

function HelpIfEmpty(const AValue,AFalse: string): string;
begin
  AddStack('My_pr.HelpIfEmpty');
  result:=HelpIf(HelpBoldStr('ПУСТО','(',hlnkInterMemo)+'('+AValue+')','""',AFalse,false);
  DelStack;
end;

function HelpArrayAsList;
begin
  AddStack('My_pr.HelpArrayAsList');
  result:=HelpBoldStr('МАССИВ_СТРОКА','(',hlnkInterMemo)+'('+HelpBoldStr(a,lBold)+','+sep+','+vFalse+')';
  DelStack;
end;

function HelpStrTran;
begin
  AddStack('My_pr.HelpStrTran');
  result:=HelpBoldStr('СТРОКА_ПОИСК','(',hlnkInterMemo)+'('+HelpBoldStr(s,lBold)+','+ss+','+sr+')';
  DelStack;
end;

function ButMask2Prm;
begin
	AddStack('My_pr.ButMask2Prm');
  result.Mask:=StrToAtPart(Mask,result.Capt,cButCapt);
  DelStack;
end;

function ButPrm2Mask(const Prm: TButGetPrm): string;
begin
  with Prm do result:=ButPrm2Mask(Capt,Mask);
end;

function ButPrm2Mask(const Capt: string = ''; const Mask: string = ''): string;
begin
  result:=AtPartToStr(Capt,cButCapt)+TrimRight(Mask);
end;

const
	btZgl = '@'#31'H';

function FmlToMask;
begin
  AddStack('My_pr.FmlToMask');
  result:=ButPrm2Mask('',StrTran(Fml,[CRLF,cButCapt],[btCrlf,btZgl],[rfReplaceAll,rfIgnoreCase]));
  DelStack;
end;

function MaskToFml;
begin
	AddStack('My_pr.MaskToFml');
  result:=StrTran(ButMask2Prm(TrimRight(Mask)).Mask,[btCrlf,btZgl],[CRLF,cButCapt],[rfReplaceAll,rfIgnoreCase]);
  DelStack;
end;

function FmlKeyLbMask;
begin
  AddStack('My_pr.FmlKeyLbMask');
  result:=ButPrm2Mask(Capt,FmlToMask(cKeyLbFunc+Format('(%d)',[key])));
  DelStack;
end;

function MenuMask2Prm;
var asr: TMenuGetStr;
  i: TMenuGetList;
begin
  AddStack('My_pr.MenuMask2Prm');
  with result do begin
  	sItems:=AnsiUpperCase(Mask); Opt:=[];
    for i:=low(aMnOpt) to high(aMnOpt) do
      if (Pos(aMnOpt[i],sItems)=0) = (i in MnOptInv) then Include(Opt,i);
    InitArr(asr); sItems:=StrTran(Mask,aMnOpt,asr,[rfReplaceAll,rfIgnoreCase]);
  end;
  DelStack;
end;

function MenuArr2Mask;
var i: longint;
  acn: TArrNamePrimStr;
begin
  AddStack('My_pr.MenuArr2Mask');
  i:=Length(a); SetLength(acn,i);
  for i:=0 to i-1 do begin
    acn[i,1]:=IntToStr(LowLim+i); acn[i,2]:=a[i];
  end;
  result:=MenuACN2Mask(acn,Opt);
  DelStack;
end;

function MenuACN2Mask;
var i: longint;
  j: TMenuGetList;
begin
  AddStack('My_pr.MenuACN2Mask');
  result:='';
  for i:=low(a) to high(a) do IncD(result,ArrayAsList(a[i],UnDelim)+mniDlm);
  DecLen(result,lmniDlm);
  for j:=low(aMnOpt) to high(aMnOpt) do
    if (j in Opt) <> (j in mnOptInv) then IncD(result,aMnOpt[j]);
  DelStack;
end;

function RadioMask;
begin
  AddStack('My_pr.RadioMask');
  if cnt=RadioMaskCntCalc then begin
    cnt:=high(a);
    while cnt>=0 do if a[cnt]='' then Dec(cnt) else break;
    Inc(cnt);
  end;
  result:=TransPrim(ArrayAsList(a,mniDlm,cnt,false,beg));
  if LowLim<>1 then IncD(result,StrNum(cRdBeg,LowLim));
  if Arrange<>rgaCol then IncD(result,cRdArrange+aRdArrange[Arrange]);
  DelStack;
end;

procedure LsPrnAdd;
var a: TArrStr;
  i,l: longint;
  soffs: string;
begin
  AddStack('My_pr.LsPrnAdd');
  if not empty(Value) then begin
  	if Head<>'' then LsPrn.Add(Head+':');
    soffs:=Space(offs); l:=LsArrDynamic(TrimRight(Value),a,CRLF);
    for i:=0 to l-1 do IncL(a[i],soffs);
    AddFrom(LsPrn,a,l);
  end;
  DelStack;
end;

procedure StdGetState;
begin
  AddStack('My_pr.StdGetState');
  if Assigned(PrStdGetState) then PrStdGetState(v,Opt);
  DelStack;
end;

procedure KeyToShift;
begin
  AddStack('My_pr.KeyToShift');
  Dec(KeyShift); Key:=ModDiv(KeyShift,KEY_CNT)+1; Shift:=KeyShift;
  DelStack;
end;

function ShiftToKey;
begin
  AddStack('My_pr.ShiftToKey');
  result:=KEY_CNT*Shift+Key;
  DelStack;
end;

const aTxtLab: TKeyStr =
  ('F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12',
  'Enter','Esc','Tab','Пробел','Home','End','Ins','Del','PgUp','PgDn',
  'Вверх','Вниз','Влево','Вправо','Backspace',
  'A','B','C','D','E','F','G','H','I','J','K','L','M',
  'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
  '0','1','2','3','4','5','6','7','8','9',
  '<,>','<.>','<+>','<->','<*>','</>');

	aKeyShft: array[TKeyShftList] of string = ('Ctrl','Alt','Shift');
  
function KeyToTxt;
var Shift: TKeyShftList0;
  key: longint;
begin
  if InRange(KeyShift,1,KEY_USER) then begin
    KeyToShift(KeyShift,Shift,key); result:=aTxtLab[key];
    if Shift>0 then IncL(result,aKeyShft[Shift]+'+');
    if lBrack then IncL(result,'«','»');
  end
  else result:='';
end;

function TxtToKey;
var i: TKeyShftList;
  j: longint;
	s: string;
begin
	AddStack('My_pr.TxtToKey');
  result:=0; s:=TrimUpper(txt);
  for i:=low(aKeyShft) to high(aKeyShft) do
  	if LeftSelfDel(s,AnsiUpperCase(aKeyShft[i])+'+') then begin
    	result:=KEY_CNT*i; break;
    end;
  if AnsiFindText(s,aTxtLab,low(aTxtLab),j) then Inc(result,j);
  DelStack;
end;

function MenuNewLine;
begin
	AddStack('My_pr.MenuNewLine');
  Result:=TMenuItem.Create(AOwner); Result.Caption:=cLineCaption;
  DelStack;
end;

function GetKeyCod(Key: Word; Shift: TShiftState): longint;
begin
  if not GetKeyCod(Key,Shift,result) then result:=0;
end;

function GetKeyCod(Key: Word; Shift: TShiftState; var KeyRes: longint): boolean;
const aKeyLab1: TKeyInt =
  (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  96,97,98,99,100,101,102,103,104,105,0,110,107,109,106,111);
var lCtrl,lAlt,lShift: boolean;
begin
  AddStack('My_pr.GetKeyCod');
	result:=false; KeyRes:=low(aKeyLab);
	while KeyRes<=high(aKeyLab) do
   	if (aKeyLab[KeyRes]=Key) or (aKeyLab1[KeyRes]=Key) then begin
      lCtrl := ssCtrl in Shift; lAlt := ssAlt in Shift; lShift := ssShift in Shift;
      if not((KeyRes=K_F12) and lCtrl and not lAlt and lShift) then
        if lCtrl and not lAlt then Inc(KeyRes,KEY_CNT*kshCtrl)
        else if lAlt and not lCtrl then Inc(KeyRes,KEY_CNT*kshAlt)
        else if lShift{ <> (lCtrl and lAlt)} then Inc(KeyRes,KEY_CNT*kshShift);
    	result:=true; break;
    end
    else Inc(KeyRes);
  DelStack;
end;

const
  DlmShift = '_';
  aKeySt: TKeyStr =
    ('F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12',
    'Enter','Esc','Tab','Space','Home','End','Ins','Del','PgUp','PgDn',
    'Up','Down','Left','Right','BS',
    'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
    '0','1','2','3','4','5','6','7','8','9',
    'Zpt','Point','Plus','Minus','Mult','Div');

function NmToKey(const s: string): longint;
begin
  NmToKey(s,result);
end;

function NmToKey(const s: string; var Key: longint): boolean;
var a: TNamePrimStr;
	i: longint;
label lend;
begin
	AddStack('My_pr.NmToKey');
	result:=false; Key:=0; a:=StrDivDlm(DlmShift,TrimUpper(s),2);
  if a[1]<>'' then begin
    if not AnsiFindText(a[1],aKeyShft,low(aKeyShft),i) then goto lend;
    Key:=KEY_CNT*i;
  end;
  if AnsiFindText(a[2],aKeySt,low(aKeySt),i) then begin
    Inc(Key,i); result:=true;
  end
  else Key:=0;
lend:
	DelStack;
end;

function KeyToNm;
var Shift: TKeyShftList0;
  k: longint;
begin
	AddStack('My_pr.KeyToNm');
  result:='';
  if InRange(Key,1,KEY_USER) then begin
    KeyToShift(Key,Shift,k);
    if Shift>0 then result:=AnsiUpperCase(aKeyShft[Shift])+DlmShift;
    IncD(result,aKeySt[k]);
  end;
  DelStack;
end;

var aKeyStack: TArrByteStr;
  lKeyStack: longint;

procedure AddKeyStack(Key: longint; const txt: string);
var s: string;
begin
  LastKey:=Key; s:=DlmBetween(KeyToTxt(Key,true),txt,'-'); RnmStack(GetStack+': '+s);
  if lKeyStack<Length(aKeyStack) then aKeyStack[lKeyStack]:=s;
  if Assigned(AddKeyStackProc) then AddKeyStackProc(s);
  Inc(lKeyStack);
end;

procedure RenameKeyStack(const txt: string);
begin
  RnmStack(GetStack+': '+txt);
  if lKeyStack<=Length(aKeyStack) then aKeyStack[lKeyStack-1]:=txt;
end;

procedure DelKeyStack;
begin
  Dec(lKeyStack);
end;

function GetKeyStack;
var i: longint;
begin
  result:='';
  for i:=low(aKeyStack) to min(high(aKeyStack),lKeyStack-1) do IncD(result,aKeyStack[i]+',');
  DecLen(result);
end;

function KeyAction;
begin
  AddStack('My_pr.KeyAction');
  result:=iif(key=K_F4,faCopy,faEdit);
  DelStack;
end;

var
  FMsOff: TControl;
  NotMsOff: boolean = true;

procedure FProcControlsMsOff(Sender: TControl; const av: array of variant; var Done: boolean);
begin
  AddStack('My_pr.FProcControlsMsOff');
  if not Assigned(FMsOff) then
    if MsgMsOff(Sender) then begin
      FMsOff:=Sender; Done:=false;
    end;
  DelStack;
end;

function MsOff;
var i: longint;
  tc: TControl;
begin
  AddStack('My_pr.MsOff');
  if NotMsOff then begin
  	NotMsOff:=true;
    for i:=0 to Application.ComponentCount-1 do
      if IsClass(Application.Components[i],TControl,pointer(tc)) then begin
        ProcControls(tc,FProcControlsMsOff,[]);
        if Assigned(FMsOff) then break;
      end;
  end;
  result:=FMsOff;
  DelStack;
end;

function MsgMsOff(Sender: TControl): boolean;
begin
  AddStack('My_pr.MsgMsOff(Init)');
  result:=boolean(Sender.Perform(WM_MSOFF,byte(msoInit),0));
  DelStack;
end;

procedure MsgMsOff(Oper: TMsOffOper; KeyLb: TObject);
begin
  AddStack('My_pr.MsgMsOff(KeyLb)');
  MsOff.Perform(WM_MSOFF,byte(Oper),longint(KeyLb));
  DelStack;
end;

function MsgMsOff(Sender: TControl; av: PArrVar): boolean;
begin
  AddStack('My_pr.MsgMsOff(Exec)');
  result:=not boolean(Sender.Perform(WM_MSOFF,byte(msoExec),longint(av)));
  DelStack;
end;

function SeekTabSheet(tw: TWinControl): TTabSheet;
begin
  SeekTabSheet(tw,result);
end;

function SeekTabSheet(tw: TWinControl; var ts: TTabSheet): boolean;
begin
  AddStack('My_pr.SeekTabSheet');
  result:=ParentClass(tw,TTabSheet); ts:=IfThen(result,tw);
  DelStack;
end;

function tRecno;
begin
  result:=DlmBetween(NameDB,fRECNO,'.');
end;

var lsPrim: TStrStrList;

procedure SetPrim;
var i: longint;
begin
	AddStack('My_pr.SetPrim');
  if nmdb<>'' then begin
    TStrStrList.Create(TStrCustomList(lsPrim));
    if prim='' then FindDel(lsPrim,nmdb)
    else if lsPrim.IgnoreFindAdd(nmdb,prim,i) then lsPrim.Value[i]:=prim;
  end;
  DelStack;
end;

function GetPrim;
begin
  AddStack('My_pr.GetPrim');
  if StrToChar(nmdb) in ['A'..'z'] then begin
    result:='';
    if Assigned(lsPrim) then if lsPrim.FindValue(nmdb,result) then TransPrimSelf(result);
    if result='' then
      if lRaise then raise Exception.CreateFmt('Не найдено наименование таблицы %s',[nmdb]);
  end
  else result:=nmdb;
  DelStack;
end;

procedure GetPrimSelf;
begin
  nmdb:=GetPrim(nmdb,lRaise);
end;

procedure DWVidRec0;
begin
  AddStack('My_pr.DWVidRec0');
  Finalize(result); ZeroMemory(@result,SizeOf(result));
	with result do begin
    AType:=dwtString; Len:=10; FillType:=dwftRight; FillChr:=' ';
  end;
  DelStack;
end;

function StrDefQQ(const s: string): string;
var p: longint;
begin
  AddStack('My_pr.StrDefQQ');
  result:=s;
  if Length(result)>0 then begin
    if result[1] in ['''','"'] then Delete(result,1,1);
    p:=Length(result);
    if p>0 then
      if result[p] in ['''','"'] then SetLength(result,p-1);
  end;
  DelStack;
end;

const acDDatType: array[TDDatType] of char = ('D','M','Q','Y');
  acDDatD2: array[TDDatD2] of char = ('D','E','P','G');
	aDWFill: array[TDWFillList] of char = ('R','L');

function DWSToRec;
var db: longint;
	procedure ChrType(const s: string);
  var c: char;
  begin
    AddStack('My_pr.DWSToRec.ChrType');
    c:=UpCase(StrToChar(s));
    with result do case c of
      'A': AType:=dwtArray;
      'B','L': AType:=dwtBool;
      'C': AType:=dwtSel;
      'D': AType:=dwtDate;
      'F','I','N': AType:=dwtFloat;
      'H','X','Z': begin
      	ChrType(Copy(s,2,MaxInt)); Inc(db);
        case c of
          'H': SelType:=selInt;
          'X': SvType:=dwsFix;
          'Z': SvType:=dwsDyn;
        end;
      end;
      'M': AType:=dwtMemo;
      'T': AType:=dwtManyStr;
      'U': AType:=dwtMany;
    else AType:=dwtString;
    end;
    DelStack;
  end;
var ad: array[1..2] of string;
  function aSeek(n: byte; const a: array of char): byte;
  var i: longint;
    c: char;
  begin
    AddStack('My_pr.DWSToRec.aSeek');
    result:=low(a);
    if Length(ad[1])>=n then begin
      c:=UpCase(ad[1][n]);
      for i:=result+1 to high(a) do
        if c=a[i] then begin
          result:=i; break;
        end;
    end;
    DelStack;
  end;
var a: array[1..8] of string;
	i: longint;
  al: TNamePrimStr;
begin
	AddStack('My_pr.DWSToRec');
  DWVidRec0(result);
	with result do if StrDivDlm('=',s,al) then begin
    Name:=al[1]; LsArrFill(al[2],a,UnDelim); dwCod:=a[1];
    db:=1; ChrType(a[2]);
    if SvType=dwsDyn then begin
      LsArrFill(dwCod,ad,','); dwCod:=ad[2];
      DDatType:=TDDatType(aSeek(1,acDDatType)); DDatD2:=TDDatD2(aSeek(2,acDDatD2));
    end;
    Delete(a[2],1,db);
    if AnsiFindChar(StrToChar(a[2]),aDWFill,byte(low(aDWFill)),i) then begin
      FillType:=TDWFillList(i); FillChr:=StrToChar(Copy(a[2],2,MaxInt)); Delete(a[2],1,2);
    end;
    Len:=Int0(a[2]);
    if (SvType=dwsDyn) and (AType=dwtMemo) then begin
      AType:=dwtString; Len:=GetFieldInfo(tDDAT,fDDZN).Size;
    end;
    case AType of
      dwtString,dwtManyStr: a[3]:=StrDefQQ(a[3]);
      dwtFloat: if StrDivDlm('.',a[2],al) then Dec:=Int0(al[2]);
    end;
    AValue:=a[3]; Prim:=a[4]; DopPrm:=a[5];
    SelVid:=TrimUpper(a[6]); SelVName:=TrimUpper(a[7]); SelPrm:=TrimRight(a[8]);
  end
  else Name:=s;
  DelStack;
end;

function DWRecToS;
var st,scod: string;
begin
	AddStack('My_pr.DWRecToS');
	with r do begin
  	st:=aDWSvTypeChr[SvType]+IfThen((AType=dwtSel) and (SelType=selInt),'H')+aDWFld[AType].c;
    if AType in DWsetLen then begin
	    if AType in [dwtString,dwtManyStr] then IncD(st,aDWFill[FillType]+FillChr);
	    StrNumSelf(st,Len);
      if (AType=dwtFloat) and (Dec>0) then IncD(st,StrNum('.',Dec));
    end;
    if SvType=dwsDyn then scod:=acDDatType[DDatType]+acDDatD2[DDatD2]+',';
    result:=ArrayAsList([Name+'='+scod+dwCod,st,TrimRight(AValue),TrimRight(Prim),TrimRight(DopPrm),
      TrimRight(SelVid),TrimRight(SelVName),TrimRight(SelPrm)],UnDelim);
  end;
  DelStack;
end;

function DynNmDb;
begin
  AddStack('My_pr.DynNmDb');
  result:=StrNum(sDyn,n);
  DelStack;
end;

function DWMem;
begin
  AddStack('My_pr.DWMem');
  result:=sMemo+aDWPost[post].post;
  DelStack;
end;

procedure DWFldAddProc;
var n: longint;
begin
  AddStack('My_pr.DWFldAddProc');
  n:=Length(a); SetLength(a,n+1); a[n].defD:=defD; a[n].defW:=defW; a[n].lWin:=lWin;
  DelStack;
end;

function IsDWFldMemo(t: TDWFldType; var fa: TFldMemoAttr): boolean;
begin
  AddStack('My_pr.IsDWFldMemo');
  result:=false; fa:=low(aMemoDwt);
  while fa<=high(aMemoDwt) do
    if t=aMemoDwt[fa] then begin
      result:=true; break;
    end
    else Inc(fa);
  DelStack;
end;

function IsDWFldMemo(t: TDWFldType): boolean;
var fa: TFldMemoAttr;
begin
  result:=IsDWFldMemo(t,fa);
end;

function IsDWFldMemo(t: TDWFldType; var fa: TFldMemoAttr; var sBeg: string): boolean;
begin
  AddStack('My_pr.IsDWFldMemo(sBeg)');
  result:=IsDWFldMemo(t,fa);
  if result then sBeg:=aBegMemFix[fa] else sBeg:=sFix;
  DelStack;
end;

function IsDWFldMemo(t: TDWFldType; var sBeg: string): boolean;
var fa: TFldMemoAttr;
begin
  result:=IsDWFldMemo(t,fa,sBeg);
end;

function SpinGetPrm;
var a: array[1..4] of string;
	l: longint;
begin
	AddStack('My_pr.SpinGetPrm');
	with result do begin
  	l:=ListAsArray(Mask,a,',');
    MinValue:=-MaxInt; MaxValue:=MaxInt; Increment:=0; ReadOnly:=false;
    if l>3 then ReadOnly:=StrToBoolean(a[4]);
    if l>2 then Increment:=Int0(a[3]);
    if l>1 then MaxValue:=Int0(a[2]);
    if l>0 then MinValue:=Int0(a[1]);
    MaxValue:=max(MinValue,MaxValue);
    if Increment=0 then Increment:=1;
  end;
  DelStack;
end;

procedure FindDelFree(var ls: TIntegerList; Value: LongInt);
begin
  AddStack('My_pr.FindDelFree');
  if ls.FindDel(Value) then if ls.Count=0 then FreeAndNil(ls);
  DelStack;
end;

procedure FreeObjects(var ls: TIntegerList; lFree: boolean = true);
var i: longint;
begin
  AddStack('My_pr.FreeObjects');
  if Assigned(ls) then begin
    for i:=0 to ls.Count-1 do ls.Objects[i].Free;
    if lFree then FreeAndNil(ls);
  end;
  DelStack;
end;

procedure AddPrnHead(const Head: string);
begin
  AddPrnHead([Head]);
end;

procedure AddPrnHead(const Head: array of string);
var i: ShortInt;
begin
  AddStack('My_pr.AddPrnHead');
  for i:=low(Head) to high(Head) do begin
    Inc(nPrnHead); aPrnHead[nPrnHead]:=Head[i];
  end;
  DelStack;
end;

procedure DelPrnHead;
begin
	AddStack('My_pr.DelPrnHead');
  nPrnHead:=max(0,nPrnHead-cnt);
  DelStack;
end;

procedure SetLogVidAct;
begin
  SetLogVid(aActionLogVid[Value]);
end;

function KeyEvalProc;
var i: longint;
begin
  AddStack('My_pr.KeyEvalProc');
  result:=false;
  for i:=low(aProc) to high(aProc) do begin
    aProc[i](Key,tw,result);
    if result then break;
  end;
  DelStack;
end;

function IsPswdPrm;
begin
  AddStack('My_pr.IsPswdPrm');
  p:=PswdPrm; result:=Assigned(p);
  DelStack;
end;

function DBMain;
var p: PPswdPrm;
begin
  AddStack('My_pr.DBMain');
  if IsPswdPrm(p) then result:=p.DBMain else result:=nil;
  DelStack;
end;

function NoFromCalc;
var Prm: TFromCalcPrm;
begin
  AddStack('My_pr.NoFromCalc');
  if Owner is TControl then begin
    Prm.d:=d; Prm.x:=x; Prm.y:=y;
    result := TControl(Owner).Perform(WM_FROMCALC,0,longint(@Prm))=0;
  end
  else result:=true;
  DelStack;
end;

procedure ThrowGoto;
begin
  raise EGoto.Create(s);
end;

function sMEMS;
begin
  result:=StrNum(sMemo,ix);
end;

function EdoExeFld;
const aType: TEdoExeTypeStr = ('PODP','CHK','SHIFR');
  aIO: array[TEdoExeIO] of string = ('I','OT','O','M');
begin
  result:=aType[tp]+'_'+aIO[io];
end;

function EdoGetDokVdNames: PArrStr;
begin
  AddStack('My_pr.EdoGetDokVdNames');
  if not Assigned(FEdoGetDokVdNames) then begin
    New(FEdoGetDokVdNames); EdoProc(edoDokVdNames,[longint(FEdoGetDokVdNames)]);
  end;
  result:=FEdoGetDokVdNames;
  DelStack;
end;

function EdoInCapt;
begin
  AddStack('My_pr.EdoInCapt');
  if edoinNoVdCod in Opt then result:=''
  else begin
    result:=cod;
    if not(edoinNoCodTrns in Opt) then EdoProc(edoCod,[vd,longint(@result)]);
    result:=FRup(DelTrim(EdoGetDokVdNames^[vd]+' '+Trim(result)));
  end;
  if not(edoinNoName in Opt) then DlmBetwSelf(result,DelTrim(name),'.');
  if not(edoinNoPrim in Opt) then DlmBetwSelf(result,BrackNoEmp(DelTrim(prim)),' ');
  if not(edoinNoD in Opt) then IncD(result,' ['+FormatDateTime(EdoFmtDate,d)+']');
  DelStack;
end;

function EdoProc(Oper: TEdoOper; const av: array of variant; const Default: variant): variant;
var i: longint;
  lBreak: boolean;
begin
  AddStack('My_pr.EdoProc');
  result:=Default; lBreak:=false;
  for i:=low(aEdoProc) to high(aEdoProc) do begin
    aEdoProc[i](Oper,av,result,lBreak);
    if lBreak then break;
  end;
  DelStack;
end;

function EdoProc(Oper: TEdoOper; const av: array of variant): variant;
begin
  result:=EdoProc(Oper,av,null);
end;

{ TStringListCase }
function CompUpSign(const v1,v2: variant): TValueSign;
var s1,s2: string;
begin
  s1:=AnsiUpperCase(v1); s2:=AnsiUpperCase(v2);
  result:=IfThen(s1<>s2,aSign[s1<s2]);
end;

const aStrListCaseProc: array[boolean] of function(const v1,v2: variant): TValueSign = (CompSign,CompUpSign);

constructor TStringListCase.CreateSort;
begin
  AddStack('TStringListCase.CreateSort');
  Create; Sorted:=true;
  DelStack;
end;

class function TStringListCase.CreateIf;
begin
  AddStack('TStringListCase.CreateIf');
  if usl then begin
    result:=Create; result.Sorted:=ASorted;
  end
  else result:=nil;
  DelStack;
end;

function TStringListCase.CompareStrings;
begin
  {$IFDEF STACKALL}AddStack('TStringListCase.CompareStrings');{$ENDIF}
  Result:=aStrListCaseProc[UpCase](S1,S2);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

{ TStrCustomList }
constructor TStrCustomList.Create(ASorted: boolean = true; ACapacity: longint = 10);
begin
  AddStack('TStrCustomList.Create');
  Sorted:=ASorted; Capacity:=ACapacity;
  DelStack;
end;

class function TStrCustomList.Create(var Sender: TStrCustomList; ASorted: boolean = true; ACapacity: longint = 10): TStrCustomList;
begin
  if not Assigned(Sender) then Sender:=Create(ASorted,ACapacity);
  result:=Sender;
end;

procedure TStrCustomList.ProcDel;
begin
  AddStack('TStrCustomList.ProcDel');
  pSet(ni,pGet(oi));
  DelStack;
end;

procedure TStrCustomList.DelValue;
begin
  AddStack('TStrCustomList.DelValue');
  if not NoDelObj then begin
    SLObjIndDel(Self,Index,ProcDel,false,l); Dec(l);
  end;
  DelStack;
end;

procedure TStrCustomList.Delete;
begin
  AddStack('TStrCustomList.Delete');
  if IntObj(Self,Index)>=0 then DelValue(Index);
  inherited Delete(Index);
  DelStack;
end;

procedure TStrCustomList.Clear;
begin
  AddStack('TStrCustomList.Clear');
  inherited Clear;
  l:=0;
  DelStack;
end;

function TStrCustomList.nIndex;
begin
  AddStack('TStrCustomList.nIndex');
  n:=IntObj(Self,Index); result := n>=0;
  DelStack;
end;

function TStrCustomList.IgnoreFindAdd(const s: string; var i: longint): boolean;
begin
  AddStack('TStrCustomList.IgnoreFindAdd');
  result:=IgnoreSlFindAdd(Self,s,i);
  if not result then Objects[i]:=ObjectNeg;
  DelStack;
end;

procedure TStrCustomList.Init;
begin
  AddStack('TStrCustomList.Init');
  Text:=AText; Capacity:=Count; InitObjects(Self,ObjectNeg);
  DelStack;
end;

function TStrCustomList.CompareStrings;
begin
  {$IFDEF STACKALL}AddStack('TStrCustomList.CompareStrings');{$ENDIF}
  if CaseSensitive
  then Result:=CompSign(S1,S2)
  else Result:=inherited CompareStrings(S1,S2);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TStrCustomList.FSetValue;
var n: longint;
  ov,nv: boolean;
begin
  AddStack('TStrCustomList.SetValue');
  ov:=nIndex(Index,n); nv:=Assigned(p);
  if nv<>ov then
    if nv then begin
      ProcAdd; Objects[Index]:=Pointer(l); n:=l; Inc(l);
    end
    else begin
      DelValue(Index); Objects[Index]:=ObjectNeg;
    end;
  if nv then pSet(n,p);
  DelStack;
end;

procedure TStrCustomList.Assign;
var i: longint;
  lsSource: TStrCustomList;
begin
  AddStack('TStrCustomList.Assign');
  inherited Assign(Source);
  if IsClass(Source,TStrCustomList,pointer(lsSource)) then begin
    Sorted:=lsSource.Sorted; i:=Count; Capacity:=i;
    for i:=0 to i-1 do pSet(i,lsSource.pGet(i));
  end;
  DelStack;
end;

{ TStrStrList }
class function TStrStrList.CreateIf;
begin
  if usl then result:=Create(ASorted,ACapacity) else result:=nil;
end;

procedure TStrStrList.SetCapacity;
begin
  AddStack('TStrStrList.SetCapacity');
  inherited SetCapacity(Value);
  if Length(a)<Value then SetLength(a,Value);
  DelStack;
end;

function TStrStrList.IgnoreFindAdd(const s,v: string; var i: longint): boolean;
begin
  AddStack('TStrStrList.IgnoreFindAdd');
  result:=TStrCustomList(Self).IgnoreFindAdd(s,i);
  if not result then Value[i]:=v;
  DelStack;
end;

function TStrStrList.IgnoreFindAdd(const s: string; const v: string = ''): boolean;
var i: longint;
begin
  result:=IgnoreFindAdd(s,v,i);
end;

function TStrStrList.pGet;
begin
  AddStack('TStrStrList.pGet');
  result:=@a[Index];
  DelStack;
end;

procedure TStrStrList.pSet;
begin
  AddStack('TStrStrList.pSet');
  a[Index]:=PString(p)^;
  DelStack;
end;

procedure TStrStrList.ProcAdd;
begin
  AddStack('TStrStrList.ProcAdd');
  if Length(a)=l then SetLength(a,l shl 1);
  DelStack;
end;

function TStrStrList.GetValue;
var n: longint;
begin
  AddStack('TStrStrList.GetValue');
  if nIndex(Index,n) then result:=a[n] else result:='';
  DelStack;
end;

procedure TStrStrList.SetValue;
begin
  AddStack('TStrStrList.SetValue');
  FSetValue(Index,IfThen(v<>'',@v));
  DelStack;
end;

function TStrStrList.FindValue(const s: string): string;
begin
  if not FindValue(s,result) then result:='';
end;

function TStrStrList.FindValue(const s: string; var v: string): boolean;
var i: longint;
begin
  AddStack('TStrStrList.FindValue');
  result:=Find(s,i);
  if result then v:=Value[i];
  DelStack;
end;

procedure TStrStrList.Init;
begin
  AddStack('TStrStrList.Init');
  inherited Init(AText);
  if Length(a)<Count then SetLength(a,Count);
  DelStack;
end;

{ TStrDblList }
procedure TStrDblList.SetCapacity;
begin
  AddStack('TStrDblList.SetCapacity');
  inherited SetCapacity(Value);
  if Length(a)<Value then SetLength(a,Value);
  DelStack;
end;

function TStrDblList.IgnoreFindAdd(const s: string; v: Double; var i: longint): boolean;
begin
  AddStack('TStrDblList.IgnoreFindAdd');
  result:=TStrCustomList(Self).IgnoreFindAdd(s,i);
  if not result then Value[i]:=v;
  DelStack;
end;

function TStrDblList.IgnoreFindAdd(const s: string; v: Double = 0): boolean;
var i: longint;
begin
  result:=IgnoreFindAdd(s,v,i);
end;

function TStrDblList.pGet;
begin
  AddStack('TStrDblList.pGet');
  result:=@a[Index];
  DelStack;
end;

procedure TStrDblList.pSet;
begin
  AddStack('TStrDblList.pSet');
  a[Index]:=PDouble(p)^;
  DelStack;
end;

procedure TStrDblList.ProcAdd;
begin
  AddStack('TStrDblList.ProcAdd');
  if Length(a)=l then SetLength(a,l shl 1);
  DelStack;
end;

function TStrDblList.GetValue;
var n: longint;
begin
  AddStack('TStrDblList.GetValue');
  if nIndex(Index,n) then result:=a[n] else result:=0;
  DelStack;
end;

procedure TStrDblList.SetValue;
begin
  AddStack('TStrDblList.SetValue');
  FSetValue(Index,IfThen(v<>0,@v));
  DelStack;
end;

function TStrDblList.FindValue(const s: string): Double;
begin
  if not FindValue(s,result) then result:=0;
end;

function TStrDblList.FindValue(const s: string; var v: Double): boolean;
var i: longint;
begin
  AddStack('TStrDblList.FindValue');
  result:=Find(s,i);
  if result then v:=Value[i];
  DelStack;
end;

procedure TStrDblList.IncValue(Index: longint; v: Double);
begin
  AddStack('TStrDblList.IncValue');
  Value[Index]:=Value[Index]+v;
  DelStack;
end;

procedure TStrDblList.IncValue(const s: string; v: Double);
var i: longint;
begin
  AddStack('TStrDblList.IncValue(s)');
  TStrCustomList(Self).IgnoreFindAdd(s,i); IncValue(i,v);
  DelStack;
end;

procedure TStrDblList.Init;
begin
  AddStack('TStrDblList.Init');
  inherited Init(AText);
  if Length(a)<Count then SetLength(a,Count);
  DelStack;
end;

{ TStrVarList }
procedure TStrVarList.SetCapacity;
begin
  AddStack('TStrVarList.SetCapacity');
  inherited SetCapacity(Value);
  if Length(a)<Value then SetLength(a,Value);
  DelStack;
end;

function TStrVarList.IgnoreFindAdd(const s: string; const v: variant; var i: longint): boolean;
begin
  AddStack('TStrVarList.IgnoreFindAdd');
  result:=TStrCustomList(Self).IgnoreFindAdd(s,i);
  if not result then Value[i]:=v;
  DelStack;
end;

function TStrVarList.IgnoreFindAdd(const s: string; const v: variant): boolean;
var i: longint;
begin
  result:=IgnoreFindAdd(s,v,i);
end;

function TStrVarList.pGet;
begin
  AddStack('TStrVarList.pGet');
  result:=@a[Index];
  DelStack;
end;

procedure TStrVarList.pSet;
begin
  AddStack('TStrVarList.pSet');
  a[Index]:=PVariant(p)^;
  DelStack;
end;

procedure TStrVarList.ProcAdd;
begin
  AddStack('TStrVarList.ProcAdd');
  if Length(a)=l then SetLength(a,l shl 1);
  DelStack;
end;

function TStrVarList.GetValue;
var n: longint;
begin
  AddStack('TStrVarList.GetValue');
  if nIndex(Index,n) then result:=a[n] else result:=null;
  DelStack;
end;

procedure TStrVarList.SetValue;
begin
  AddStack('TStrVarList.SetValue');
  FSetValue(Index,IfThen(not IsNil(v),@v));
  DelStack;
end;

function TStrVarList.FindValue(const s: string): variant;
begin
  if not FindValue(s,result) then result:=null;
end;

function TStrVarList.FindValue(const s: string; var v: variant): boolean;
var i: longint;
begin
  AddStack('TStrVarList.FindValue');
  result:=Find(s,i);
  if result then v:=Value[i];
  DelStack;
end;

procedure TStrVarList.Init;
begin
  AddStack('TStrVarList.Init');
  inherited Init(AText);
  if Length(a)<Count then SetLength(a,Count);
  DelStack;
end;

{ TIntegerList }
constructor TIntegerList.Create(AOptions: TIntegerListOptions = []);
begin
	AddStack('TIntegerList.Create');
	inherited Create;
  FList:=TList.Create; Options:=AOptions;
  DelStack;
end;

class function TIntegerList.Create(usl: boolean; AOptions: TIntegerListOptions = []): TIntegerList;
begin
  if usl then result:=Create(AOptions) else result:=nil;
end;

class function TIntegerList.Create(var Sender: TIntegerList; AOptions: TIntegerListOptions = []): TIntegerList;
begin
  if not Assigned(Sender) then Sender:=Create(AOptions);
  result:=Sender;
end;

destructor TIntegerList.Destroy;
begin
	AddStack('TIntegerList.Destroy');
	FList.Free; FObjects.Free;
	inherited Destroy;
  DelStack;
end;

procedure TIntegerList.Assign;
begin
	AddStack('TIntegerList.Assign');
  if Assigned(Source) then
    if Source is TIntegerList then begin
      Clear; Add(TIntegerList(Source));
    end
    else inherited Assign(Source)
  else Clear;
  DelStack;
end;

procedure TIntegerList.DefineProperties;
begin
	AddStack('TIntegerList.DefineProperties');
{$IFDEF MINMAX}
	Filer.DefineProperty('Min',ReadMin,WriteMin,FMin<>0);
	Filer.DefineProperty('Max',ReadMax,WriteMax,FMax<>0);
{$ENDIF}
	Filer.DefineProperty('Integers',ReadIntegers,WriteIntegers,Count>0);
  DelStack;
end;

{$IFDEF MINMAX}
procedure TIntegerList.ReadMin;
begin
	AddStack('TIntegerList.ReadMin');
	FMin:=Reader.ReadInteger;
  DelStack;
end;

procedure TIntegerList.WriteMin;
begin
	AddStack('TIntegerList.WriteMin');
	Writer.WriteInteger(FMin);
  DelStack;
end;

procedure TIntegerList.ReadMax;
begin
	AddStack('TIntegerList.ReadMax');
	FMax:=Reader.ReadInteger;
  DelStack;
end;

procedure TIntegerList.WriteMax;
begin
	AddStack('TIntegerList.WriteMax');
	Writer.WriteInteger(FMax);
  DelStack;
end;
{$ENDIF}

procedure TIntegerList.ReadIntegers;
begin
	AddStack('TIntegerList.ReadIntegers');
	Reader.ReadListBegin; Clear;
  while not Reader.EndOfList do Add(Reader.ReadInteger);
	Reader.ReadListEnd;
  DelStack;
end;

procedure TIntegerList.WriteIntegers;
var i: longint;
begin
	AddStack('TIntegerList.WriteIntegers');
	Writer.WriteListBegin;
  for i:=0 to Count-1 do Writer.WriteInteger(GetItem(i));
	Writer.WriteListEnd;
  DelStack;
end;

procedure TIntegerList.SetOptions;
var fl: boolean;
begin
	AddStack('TIntegerList.SetOptions');
	if FOptions<>Value then begin
    fl := not(ilsSorted in FOptions) and (ilsSorted in Value); FOptions:=Value;
  	if fl then Sort;
  end;
  DelStack;
end;

procedure TIntegerList.SetOption;
begin
  AddStack('TIntegerList.SetOption');
  if Value then Options:=FOptions+[Option] else Options:=FOptions-[Option];
  DelStack;
end;

function TIntegerList.QQa;
var i: longint;
begin
  AddStack('TIntegerList.QQa');
  SetLength(result,Count);
  for i:=low(result) to high(result) do result[i]:=Vtos(Items[i]);
  DelStack;
end;

function TIntegerList.FldInListQQ(const nmf: string): string;
begin
  AddStack('TIntegerList.FldInListQQ');
  result:=FldInList(nmf,QQa);
  DelStack;
end;

function TIntegerList.FldInListQQ(var ares: TArrStr; const nmf: string): boolean;
begin
  AddStack('TIntegerList.FldInListQQ(a)');
  result:=FldInList(ares,nmf,QQa);
  DelStack;
end;

function TIntegerList.GetCapacity;
begin
	AddStack('TIntegerList.GetCapacity');
	result:=FList.Capacity;
  DelStack;
end;

procedure TIntegerList.SetCapacity;
begin
	AddStack('TIntegerList.SetCapacity');
	FList.Capacity:=Value;
  if Assigned(FObjects) then FObjects.Capacity:=Value;
  DelStack;
end;

function TIntegerList.GetCount;
begin
	AddStack('TIntegerList.GetCount');
	result:=FList.Count;
  DelStack;
end;

function TIntegerList.GetItem;
begin
	{$IFDEF STACKALL}AddStack('TIntegerList.GetItem');{$ENDIF}
	result:=LongInt(FList[Index]);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TIntegerList.SetItem;
begin
	AddStack('TIntegerList.SetItem');
{$IFDEF MINMAX}
	if (FMin<>FMax) and ((Value<FMin) and (Value>FMax))
  then raise EOutOfRange.CreateFmt('TIntegerList: Значение должно быть от %d до %d',[FMin,FMax]);
{$ENDIF}
  FList[Index]:=pointer(Value);
  DelStack;
end;

{$IFDEF MINMAX}
procedure TIntegerList.SetMin;
var i: longint;
begin
	AddStack('TIntegerList.SetMin');
	if Value<>FMin then begin
  	for i:=0 to Count-1 do begin
    	if GetItem(i)<Value
      then raise EOutOfRange.CreateFmt(
      	'TIntegerList: Ошибка установки нового мин.значения.'
        +#13+'В списке содержится значение меньше %d',[Value]);
    end;
    FMin:=Value;
    if FMin>FMax then FMax:=FMin;
  end;
  DelStack;
end;

procedure TIntegerList.SetMax;
var i: longint;
begin
	AddStack('TIntegerList.SetMax');
	if Value<>FMax then begin
  	for i:=0 to Count-1 do begin
    	if GetItem(i)>Value
      then raise EOutOfRange.CreateFmt(
      	'TIntegerList: Ошибка установки нового макс.значения.'
        +#13+ 'В списке содержится значение больше %d',[Value]);
    end;
    FMax:=Value;
    if FMax<FMin then FMin:=FMax;
  end;
  DelStack;
end;
{$ENDIF}

function TIntegerList.GetObject;
begin
	AddStack('TIntegerList.GetObject');
  if Assigned(FObjects) then result:=FObjects[Index] else result:=nil;
  DelStack;
end;

procedure TIntegerList.SetObject;
begin
	AddStack('TIntegerList.SetObject');
  InitObjects(Value);
  if Assigned(FObjects) then FObjects[Index]:=Value;
  DelStack;
end;

procedure TIntegerList.InitObjects;
var i: longint;
begin
  AddStack('TIntegerList.InitObjects');
  if Assigned(AObject) and not Assigned(FObjects) then begin
    FObjects:=TList.Create;
    for i:=0 to FList.Count-1 do FObjects.Add(nil);
  end;
  DelStack;
end;

function TIntegerList.Add(Value: LongInt; AObject: TObject = nil): longint;
var fl: boolean;
begin
	AddStack('TIntegerList.Add');
  if ilsSorted in FOptions then fl := not Find(Value,result) or (FDuplicates=dupAccept)
  else begin
    fl:=true; result:=Count;
  end;
  if fl then Insert(result,Value,AObject);
  DelStack;
end;

function TIntegerList.Add(const Value: string; AObject: TObject = nil): longint;
begin
  result:=Add(Int0(Value),AObject);
end;

function TIntegerList.Add(Value: LongInt; AObject: pointer): longint;
begin
  result:=Add(Value,TObject(AObject));
end;

function TIntegerList.Add(Value: LongInt; AObject: longint): longint;
begin
  result:=Add(Value,pointer(AObject));
end;

function TIntegerList.Add(const Value: string; AObject: pointer): longint;
begin
  result:=Add(Int0(Value),AObject);
end;

function TIntegerList.Add(const Value: string; AObject: longint): longint;
begin
  result:=Add(Int0(Value),AObject);
end;

function TIntegerList.Add(Value: TDateTime; AObject: pointer = nil): longint;
begin
  result:=Add(longint(trunc(Value)),AObject);
end;

procedure TIntegerList.Add(List: TIntegerList);
var i: longint;
begin
  AddStack('TIntegerList.Add(TIntegerList)');
  i:=List.Count; Capacity:=Count+i;
	for i:=0 to i-1 do Add(List[i],List.Objects[i]);
  DelStack;
end;

procedure TIntegerList.Add(const a: TArrInt; l: longint = NegDef);
begin
  AddStack('TIntegerList.Add(TArrInt)');
  ReplNegSelf(l,a); Capacity:=Count+l;
  for l:=0 to l-1 do Add(a[l]);
  DelStack;
end;

procedure TIntegerList.AddTo;
var i: longint;
begin
  AddStack('TIntegerList.AddTo');
  i:=l+Count;
  if Length(a)<i then SetLength(a,i);
  for i:=0 to Count-1 do begin
    a[l]:=Items[i]; Inc(l);
  end;
  DelStack;
end;

procedure TIntegerList.Clear;
begin
	AddStack('TIntegerList.Clear');
	FList.Clear; FreeAndNil(FObjects);
  DelStack;
end;

procedure TIntegerList.Delete;
begin
	AddStack('TIntegerList.Delete');
	FList.Delete(Index);
  if Assigned(FObjects) then FObjects.Delete(Index);
  DelStack;
end;

procedure TIntegerList.ObjIndDel;
var i1,n,n1: longint;
begin
  AddStack('TIntegerList.ObjIndDel');
  n:=IntObj(i);
  for n1:=n+1 to ReplNeg(l,Count)-1 do Proc(n1,n1-1,p);
  for i1:=0 to Count-1 do begin
    n1:=IntObj(i1);
    if n1>n then Objects[i1]:=Pointer(n1-1);
  end;
  if lDel then Delete(i);
  DelStack;
end;

procedure TIntegerList.BoolObjPack;
var i: longint;
begin
  AddStack('TIntegerList.BoolObjPack');
  i:=0;
  while i<Count do
    if BoolObj(i)=DelTrue then Delete(i) else Inc(i);
  DelStack;
end;

function TIntegerList.IntObj;
begin
  AddStack('TIntegerList.IntObj');
  result:=longint(Objects[i]);
  DelStack;
end;

procedure TIntegerList.IntObjSelf;
begin
  i:=IntObj(i);
end;

function TIntegerList.IntObjFind(cN: longint): longint;
begin
  IntObjFind(cN,result);
end;

function TIntegerList.IntObjFind(cN: longint; var n: longint): boolean;
var i: longint;
begin
  result:=IntObjFind(cN,i,n);
end;

function TIntegerList.IntObjFind(cN: longint; var i,n: longint): boolean;
begin
  AddStack('TIntegerList.IntObjFind');
  result:=Assigned(Self);
  if result then begin
    result:=Find(cN,i);
    if result then n:=IntObj(i);
  end;
  if not result then begin
    i:=-1; n:=-1;
  end;
  DelStack;
end;

function TIntegerList.IntObjFindAdd(cN: longint; var n: longint): boolean;
var i: longint;
begin
  result:=IntObjFindAdd(cN,i,n);
end;

function TIntegerList.IntObjFindAdd(cN: longint; var i,n: longint): boolean;
var l: longint;
begin
  l:=Count; result:=IntObjFindAdd(cN,i,n,l);
end;

function TIntegerList.IntObjFindAdd(cN: longint; var i,n,l: longint): boolean;
begin
  AddStack('TIntegerList.IntObjFindAdd');
  result:=IgnoreFindAdd(cN,i);
  if result then n:=IntObj(i)
  else begin
    n:=l; Inc(l); Objects[i]:=Pointer(n);
  end;
  DelStack;
end;

function TIntegerList.BoolObj;
begin
  AddStack('TIntegerList.BoolObj');
  result:=boolean(Objects[i]);
  DelStack;
end;

function TIntegerList.BoolObjFind;
var i: longint;
begin
  AddStack('TIntegerList.BoolObjFind');
  result:=Find(cN,i);
  if result then fl:=BoolObj(i);
  DelStack;
end;

function TIntegerList.LongWordObj;
begin
  AddStack('TIntegerList.LongWordObj');
  result:=longword(Objects[i]);
  DelStack;
end;

function TIntegerList.PointerObj;
begin
  AddStack('TIntegerList.PointerObj');
  result:=Objects[i];
  DelStack;
end;

function TIntegerList.PointerObjFind(cN: longint): pointer;
var i: longint;
begin
	AddStack('TIntegerList.PointerObjFind');
	result:=nil;
	if Assigned(Self) then if Find(cN,i) then result:=PointerObj(i);
  DelStack;
end;

function TIntegerList.PointerObjFind(cN: longint; var p: pointer): boolean;
begin
  p:=PointerObjFind(cN); result:=Assigned(p);
end;

function TIntegerList.PointerObjFindAdd;
begin
  AddStack('TIntegerList.PointerObjFindAdd');
  result:=IgnoreFindAdd(cN,ixS);
  if result then p:=PointerObj(ixS);
  DelStack;
end;

procedure TIntegerList.IncD;
begin
  AddStack('TIntegerList.IncD');
  Items[Index]:=Items[Index]+d2;
  DelStack;
end;

procedure TIntegerList.IncObj;
begin
  AddStack('TIntegerList.IncObj');
  Objects[Index]:=pointer(IntObj(Index)+d2);
  DelStack;
end;

function TIntegerList.Equals;
var i,Count: longint;
begin
	AddStack('TIntegerList.Equals');
	Count:=GetCount;
  if Count=List.GetCount then begin
  	i:=0;
    while (i<Count) and (GetItem(i)=List.GetItem(i)) do Inc(i);
    result := i=Count;
  end
  else result:=false;
  DelStack;
end;

procedure TIntegerList.Exchange;
begin
	AddStack('TIntegerList.Exchange');
	FList.Exchange(Index1,Index2);
  if Assigned(FObjects) then FObjects.Exchange(Index1,Index2);
  DelStack;
end;

{= Find - реализует двоичный поиск, вызываемый IndexOf =}
{= только если список отсортирован                     =}

function FFind(p: pointer; i: longint; const v: variant): TValueSign;
var vi: Int64;
begin
  //AddStack('My_pr.FFind');
  with TIntegerList(p) do
    if ilsUnSigned in FOptions then vi:=longword(FList[i]) else vi:=LongInt(FList[i]);
  result:=CompSign(vi,v);
  //DelStack;
end;

function TIntegerList.Find;
var L,H,i: longint;
  N,N1: Int64;
begin
	AddStack('TIntegerList.Find');
	result:=false; L:=0; H:=Count-1;
  if ilsUnSigned in FOptions then N:=longword(cN) else N:=cN;
  while L<=H do begin
  	i := (L+H) shr 1;
    if ilsUnSigned in FOptions then N1:=longword(FList[i]) else N1:=LongInt(FList[i]);
    if N1<N then L:=i+1
    else begin
    	H:=i-1;
	    if N1=N then begin
      	result:=true;
        if FDuplicates<>dupAccept then L:=i;
      end;
    end;
  end;
  Index:=L;
  //result:=QuickFind(FFind,Self,iif(ilsUnSigned in FOptions,longword(cN),cN),0,Count-1,Index,FDuplicates=dupAccept);
  DelStack;
end;

function TIntegerList.IndexOf;
var i: longint;
begin
	AddStack('TIntegerList.IndexOf');
	result:=-1;
  if not(ilsSorted in FOptions) then begin
		for i:=0 to GetCount-1 do
    	if GetItem(i)=N then result:=i;
  end
  else if Find(N,i) then result:=i;
  DelStack;
end;

function TIntegerList.IndexOfObject;
var i: longint;
begin
  AddStack('TIntegerList.IndexOfObject');
  Result:=-1;
  for i:=0 to GetCount-1 do if GetObject(i)=AObject then begin
    result:=i; break;
  end;
  DelStack;
end;

procedure TIntegerList.Insert;
begin
	AddStack('TIntegerList.Insert');
{$IFDEF MINMAX}
	if (FMin<>FMax) and ((Value<FMin) and (Value>FMax))
  then raise EOutOfRange.CreateFmt('TIntegerList: Значение должно быть от %d до %d',[FMin,FMax]);
{$ENDIF}  
  InitObjects(AObject); FList.Insert(Index,pointer(Value));
  if Assigned(FObjects) then FObjects.Insert(Index,AObject);
  DelStack;
end;

procedure TIntegerList.Move;
begin
	AddStack('TIntegerList.Move');
	FList.Move(CurIndex,NewIndex);
  if Assigned(FObjects) then FObjects.Move(CurIndex,NewIndex);
  DelStack;
end;

function CompSigned(List: TIntegerList; Index1,Index2: longint): Int64;
begin
  {$IFDEF STACKALL}AddStack('My_pr.CompSigned');{$ENDIF}
  result:=LongInt(List.FList[Index1])-LongInt(List.FList[Index2]);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function CompUnSigned(List: TIntegerList; Index1,Index2: longint): Int64;
begin
  AddStack('My_pr.CompUnSigned');
  result:=Int64(longword(List.FList[Index1]))-Int64(longword(List.FList[Index2]));
  DelStack;
end;

procedure TIntegerList.Sort;
begin
	AddStack('TIntegerList.Sort');
  if ilsUnSigned in FOptions then CustomSort(CompUnSigned) else CustomSort(CompSigned);
  DelStack;
end;

type
  PSortRec = ^TSortRec;
  TSortRec = record
    ls: TIntegerList;
    Compare: TIntegerListSortCompare;
  end;

function SortInt(p: pointer; fi,si: longint; sortID: TSortID): boolean;
begin
  {$IFDEF STACKALL}AddStack('My_pr.SortInt');{$ENDIF}
  result:=false;
  with PSortRec(p)^ do case sortID of
    sort1MORE2: result := Compare(ls,fi,si)>0;
    sortEXCHANGE: ls.Exchange(fi,si);
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TIntegerList.CustomSort;
var p: TSortRec;
begin
  AddStack('TIntegerList.CustomSort');
  if FList.Count>1 then begin
    p.ls:=Self; p.Compare:=Compare; QuickSort(SortInt,@p,0,FList.Count-1);
  end;
  DelStack;
end;

function TIntegerList.IgnoreFindAdd(Value: LongInt; var ixI: longint): boolean;
var j: longint;
begin
  j:=Count; ixI:=Add(Value); result := j=Count;
end;

function TIntegerList.IgnoreFindAdd(Value: LongInt): boolean;
var ixI: longint;
begin
  result:=IgnoreFindAdd(Value,ixI);
end;

function TIntegerList.IgnoreFindAdd(Value: LongInt; var ixI: longint; var p: pointer): boolean;
begin
  result:=IgnoreFindAdd(Value,ixI);
  if result then p:=PointerObj(ixI);
end;

procedure TIntegerList.IgnoreAddDel;
var ixI: longint;
begin
  AddStack('TIntegerList.IgnoreAddDel');
  if IgnoreFindAdd(Value,ixI) then Delete(ixI);
  DelStack;
end;

function TIntegerList.FindDel(Value: LongInt; Proc: TFindDelProc = nil): boolean;
begin
  result:=FindDel(Value,Proc,[]);
end;

function TIntegerList.FindDel(Value: LongInt; Proc: TFindDelProc; const av: array of variant): boolean;
var i: longint;
begin
  AddStack('TIntegerList.FindDel');
  result:=Find(Value,i);
  if result then begin
    IfThenFindDel(Proc,Objects[i],av); Delete(i);
  end;
  DelStack;
end;

function TIntegerList.Text;
var i: longint;
begin
  AddStack('TIntegerList.Text');
  result:='';
  for i:=0 to Count-1 do My_pr.IncD(result,IntToStr(Items[i])+CRLF);
  DelStack;
end;

{ TIntStrList }
constructor TIntCustomList.Create;
begin
  AddStack('TIntCustomList.Create');
  inherited Create(AOptions);
  Capacity:=ACapacity;
  DelStack;
end;

procedure CustomDel(oi,ni: longint; p: pointer = nil);
begin
  AddStack('My_pr.CustomDel');
  with TIntCustomList(p) do pSet(ni,pGet(oi));
  DelStack;
end;

procedure TIntCustomList.DelValue;
begin
  AddStack('TIntCustomList.DelValue');
  if not NoDelObj then begin
    ObjIndDel(Index,CustomDel,Self,false,l); Dec(l);
  end;
  DelStack;
end;

procedure TIntCustomList.Delete;
begin
  AddStack('TIntCustomList.Delete');
  if IntObj(Index)>=0 then DelValue(Index);
  inherited Delete(Index);
  DelStack;
end;

procedure TIntCustomList.Clear;
begin
  AddStack('TIntCustomList.Clear');
  inherited Clear;
  l:=0;
  DelStack;
end;

function TIntCustomList.nIndex;
begin
  AddStack('TIntCustomList.nIndex');
  n:=IntObj(Index); result := n>=0;
  DelStack;
end;

function TIntCustomList.Add(n: LongInt; var i: longint): boolean;
begin
  AddStack('TIntCustomList.Add');
  result:=not IgnoreFindAdd(n,i);
  if result then Objects[i]:=ObjectNeg;
  DelStack;
end;

procedure TIntCustomList.FSetValue;
var n: longint;
  ov,nv: boolean;
begin
  AddStack('TIntCustomList.SetValue');
  ov:=nIndex(Index,n); nv:=Assigned(p);
  if nv<>ov then
    if nv then begin
      ProcAdd; Objects[Index]:=Pointer(l); n:=l; Inc(l);
    end
    else begin
      DelValue(Index); Objects[Index]:=ObjectNeg;
    end;
  if nv then pSet(n,p);
  DelStack;
end;

{ TIntStrList }
procedure TIntStrList.SetCapacity;
begin
  AddStack('TIntStrList.SetCapacity');
  inherited SetCapacity(Value);
  if Length(a)<Value then SetLength(a,Value);
  DelStack;
end;

function TIntStrList.Add(n: LongInt; const v: string): boolean;
var i: longint;
begin
  result:=Add(n,v,i);
end;

function TIntStrList.Add(n: LongInt; const v: string; var i: longint): boolean;
begin
  AddStack('TIntStrList.Add');
  result:=TIntCustomList(Self).Add(n,i);
  if result then Value[i]:=v;
  DelStack;
end;

function TIntStrList.pGet;
begin
  AddStack('TIntStrList.pGet');
  result:=@a[Index];
  DelStack;
end;

procedure TIntStrList.pSet;
begin
  AddStack('TIntStrList.pSet');
  a[Index]:=PString(p)^;
  DelStack;
end;

procedure TIntStrList.ProcAdd;
begin
  AddStack('TIntStrList.ProcAdd');
  if Length(a)=l then SetLength(a,l shl 1);
  DelStack;
end;

function TIntStrList.GetValue;
var n: longint;
begin
  AddStack('TIntStrList.GetValue');
  if nIndex(Index,n) then result:=a[n] else result:='';
  DelStack;
end;

procedure TIntStrList.SetValue;
begin
  AddStack('TIntStrList.SetValue');
  FSetValue(Index,IfThen(v<>'',@v));
  DelStack;
end;

function TIntStrList.FindValue(n: LongInt): string;
begin
  if not FindValue(n,result) then result:='';
end;

function TIntStrList.FindValue(n: LongInt; var v: string): boolean;
var i: longint;
begin
  AddStack('TIntStrList.FindValue');
  result:=Find(n,i);
  if result then v:=Value[i];
  DelStack;
end;

{ TIntDblList }
procedure TIntDblList.SetCapacity;
begin
  AddStack('TIntDblList.SetCapacity');
  inherited SetCapacity(Value);
  if Length(a)<Value then SetLength(a,Value);
  DelStack;
end;

function TIntDblList.Add(n: LongInt; v: Double): boolean;
var i: longint;
begin
  result:=Add(n,v,i);
end;

function TIntDblList.Add(n: LongInt; v: Double; var i: longint): boolean;
begin
  AddStack('TIntDblList.Add');
  result:=TIntCustomList(Self).Add(n,i);
  if result then Value[i]:=v;
  DelStack;
end;

function TIntDblList.pGet;
begin
  AddStack('TIntDblList.pGet');
  result:=@a[Index];
  DelStack;
end;

procedure TIntDblList.pSet;
begin
  AddStack('TIntDblList.pSet');
  a[Index]:=PDouble(p)^;
  DelStack;
end;

procedure TIntDblList.ProcAdd;
begin
  AddStack('TIntDblList.ProcAdd');
  if Length(a)=l then SetLength(a,l shl 1);
  DelStack;
end;

function TIntDblList.GetValue;
var n: longint;
begin
  AddStack('TIntDblList.GetValue');
  if nIndex(Index,n) then result:=a[n] else result:=0;
  DelStack;
end;

procedure TIntDblList.SetValue;
begin
  AddStack('TIntDblList.SetValue');
  FSetValue(Index,IfThen(v<>0,@v));
  DelStack;
end;

function TIntDblList.FindValue(n: LongInt): Double;
begin
  if not FindValue(n,result) then result:=0;
end;

function TIntDblList.FindValue(n: LongInt; var v: Double): boolean;
var i: longint;
begin
  AddStack('TIntDblList.FindValue');
  result:=Find(n,i);
  if result then v:=Value[i];
  DelStack;
end;

procedure TIntDblList.IncValue;
begin
  AddStack('TIntDblList.IncValue');
  Value[Index]:=Value[Index]+v;
  DelStack;
end;

{ TIntVarList }
procedure TIntVarList.SetCapacity;
begin
  AddStack('TIntVarList.SetCapacity');
  inherited SetCapacity(Value);
  if Length(a)<Value then SetLength(a,Value);
  DelStack;
end;

function TIntVarList.Add(n: LongInt; const v: variant): boolean;
var i: longint;
begin
  result:=Add(n,v,i);
end;

function TIntVarList.Add(n: LongInt; const v: variant; var i: longint): boolean;
begin
  AddStack('TIntVarList.Add');
  result:=TIntCustomList(Self).Add(n,i);
  if result then Value[i]:=v;
  DelStack;
end;

function TIntVarList.pGet;
begin
  AddStack('TIntVarList.pGet');
  result:=@a[Index];
  DelStack;
end;

procedure TIntVarList.pSet;
begin
  AddStack('TIntVarList.pSet');
  a[Index]:=PVariant(p)^;
  DelStack;
end;

procedure TIntVarList.ProcAdd;
begin
  AddStack('TIntVarList.ProcAdd');
  if Length(a)=l then SetLength(a,l shl 1);
  DelStack;
end;

function TIntVarList.GetValue;
var n: longint;
begin
  AddStack('TIntVarList.GetValue');
  if nIndex(Index,n) then result:=a[n] else result:=null;
  DelStack;
end;

procedure TIntVarList.SetValue;
begin
  AddStack('TIntVarList.SetValue');
  FSetValue(Index,IfThen(not IsNil(v),@v));
  DelStack;
end;

function TIntVarList.FindValue(n: LongInt): variant;
begin
  if not FindValue(n,result) then result:=null;
end;

function TIntVarList.FindValue(n: LongInt; var v: variant): boolean;
var i: longint;
begin
  AddStack('TIntVarList.FindValue');
  result:=Find(n,i);
  if result then v:=Value[i];
  DelStack;
end;

{ TFontIndexList }
function TFontIndexList.GetFont;
begin
  {$IFDEF STACKALL}AddStack('TFontIndexList.GetFont');{$ENDIF}
  result:=OnGetFont(Items[Index]);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

{ TIniFileCheck }
constructor TIniFileCheck.Create;
var i,p,f,l,pi: longint;
	Sect,s,st: string;
  a: TNamePrimStr;
  pSect,pIdent: PString;
begin
	AddStack('TIniFileCheck.Create');
  IfThenNotify(OnCreate,Self);
  if Length(aSect)=0 then SetLength(aSect,10);
  FFileName:=FileName;
  if not(finiNoCngExt in Opt) and IsGGI(FFileName,ExeName)
  then GetIniFileNameSelf(FFileName,not(finiNoDelOld in Opt));
  if MyFileExists(FFileName) then begin
    f:=FileBufOpen(FFileName,fmOpenRead or fmShareDenyWrite);
    if f<>-1 then
      try
        i:=Windows.GetFileSize(f,nil);
        if i>0 then begin
          SetLength(st,i);
          if ReadFile(f,pointer(st)^,i,LongWord(i),nil) then begin
            i:=1; l:=Length(st); pi:=-1;
            while i<=l do begin
              p:=PosEnd(CRLF,st,i); s:=TrimRight(Copy(st,i,p-i)); i:=p+lCRLF; pSect:=nil; pIdent:=nil;
              if s<>'' then begin
                if s[1]='[' then begin
                  SubStrSelf(s,2,-1);
                  if IndexOf(s)<0 then begin
                    pi:=SectAdd(Add(s),NegDef,not(finiNoSort in Opt));
                    if Assigned(Proc) then begin
                      Sect:=s; pSect:=@Sect;
                    end;
                  end
                  else pi:=-1
                end
                else if pi>=0 then begin
                  a:=StrDivDlm('=',s); s:=Trim(a[1]); aSect[pi].ls.IgnoreFindAdd(s,Trim(a[2]));
                  pSect:=@Sect; pIdent:=@s;
                end;
              end;
              if Assigned(Proc) then Proc(pSect,pIdent,Prm);
            end;
          end;
        end;
      finally
        FileClose(f);
      end;
  end;
  for i:=0 to Count-1 do aSect[IntObj(Self,i)].nInit:=i;
  if not(finiNoSort in Opt) then Sorted:=true;
  DelStack;
end;

destructor TIniFileCheck.Destroy;
begin
	AddStack('TIniFileCheck.Destroy');
  UpdateFile; EraseSections; FModified:=false;
  inherited Destroy;
  DelStack;
end;

function TIniFileCheck.SectAdd;
begin
  AddStack('TIniFileCheck.SectAdd');
  result:=ReplVar(nSect,NegDef,Count-1);
  if Length(aSect)=result then SetLength(aSect,result shl 1);
  aSect[result].ls:=TStrStrList.Create(SectSorted); Objects[i]:=Pointer(result);
  DelStack;
end;

function TIniFileCheck.SectionExists;
begin
	AddStack('TIniFileCheck.SectionExists');
  result := IndexOf(Section)>=0;
  DelStack;
end;

function TIniFileCheck.FindValueIndex;
begin
  AddStack('TIniFileCheck.FindValueIndex');
  result:=false;
  if ReadSectionList(Section,ls) then
	  if ls.Find(Ident,i) then result:=true;
  DelStack;
end;

function TIniFileCheck.ReadString;
var ls: TStrStrList;
  i: longint;
begin
	AddStack('TIniFileCheck.ReadString');
  if FindValueIndex(Section,Ident,ls,i) then result:=ls.Value[i] else result:=Default;
  DelStack;
end;

function TIniFileCheck.ReadInteger(const Section,Ident: string; Default: Longint = 0): Longint;
begin
  result:=ReadInteger(ReadString(Section,Ident),Default);
end;

class function TIniFileCheck.ReadInteger(const Value: string; Default: Longint = 0): Longint;
var s: string;
begin
	AddStack('TIniFileCheck.ReadInteger');
  s:=Value;
  if Length(s)>2 then
    if (s[1]='0') and (s[2] in ['X','x']) then s:='$'+Copy(s,3,Maxint);
  Result:=StrToIntDef(s,Default);
  DelStack;
end;
 
function TIniFileCheck.ReadBool;
begin
	AddStack('TIniFileCheck.ReadBool');
  Result := ReadInteger(Section,Ident,Ord(Default))<>0;
  DelStack;
end;

function TIniFileCheck.ReadDate;
begin
	AddStack('TIniFileCheck.ReadDate');
  Result:=StrToDateDef(ReadString(Section,Name),Default);
  DelStack;
end;

function TIniFileCheck.ReadDateTime;
begin
	AddStack('TIniFileCheck.ReadDateTime');
  Result:=StrToDateTimeDef(ReadString(Section,Name),Default);
  DelStack;
end;

procedure TIniFileCheck.WriteString;
var i: longint;
	ls: TStrStrList;
  v: string;
  fl: boolean;
begin
	AddStack('TIniFileCheck.WriteString');
  if Assigned(Self) then begin
    if IgnoreSlFindAdd(Self,Section,i) then IntObjSelf(Self,i)
    else begin
    	i:=SectAdd(i); aSect[i].nInit:=Count-1; FModified:=true;
    end;
    ls:=aSect[i].ls; v:=Trim(Value);
    if ls.IgnoreFindAdd(Ident,v,i) then begin
      fl := ls.Value[i]<>v;
      if fl then ls.Value[i]:=v;
    end
    else fl:=true;
    if fl then FModified:=true;
  end;
  DelStack;
end;

procedure TIniFileCheck.WriteInteger;
begin
	AddStack('TIniFileCheck.WriteInteger');
  WriteString(Section,Ident,IntToStr(Value));
	DelStack;
end;

procedure TIniFileCheck.WriteBool;
const Values: TArrBoolChr = ('0','1');
begin
	AddStack('TIniFileCheck.WriteBool');
  WriteString(Section,Ident,Values[Value]);
  DelStack;
end;

procedure TIniFileCheck.WriteDate;
begin
	AddStack('TIniFileCheck.WriteDate');
  WriteString(Section,Ident,DateToStr(Value));
  DelStack;
end;

procedure TIniFileCheck.WriteDateTime;
begin
	AddStack('TIniFileCheck.WriteDateTime');
  WriteString(Section,Ident,DateTimeToStr(Value));
  DelStack;
end;

procedure TIniFileCheck.EraseSection;
var i: longint;
  function Seek1: boolean;
  begin
  	AddStack('TIniFileCheck.EraseSection.Seek1');
    result:=Find(Section,i);
    if CompBeg and not result and InRange(i,0,Count-1)
    then result:=AnsiStartsStr(Section,Strings[i]);
    DelStack;
  end;
var j,n: longint;
begin
	AddStack('TIniFileCheck.EraseSection');
  while Seek1 do begin
  	n:=aSect[IntObj(Self,i)].nInit;
  	for j:=0 to Count-1 do with aSect[IntObj(Self,j)] do
      if nInit>n then Dec(nInit);
    ClearSection(i); SLObjIndDel(Self,i,ProcDel); FModified:=true;
  end;
  DelStack;
end;

procedure TIniFileCheck.ProcDel;
begin
  AddStack('TIniFileCheck.ProcDel');
  aSect[ni]:=aSect[oi];
  DelStack;
end;

procedure TIniFileCheck.EraseSections;
var i: longint;
begin
	AddStack('TIniFileCheck.EraseSections');
  for i:=0 to Count-1 do ClearSection(i);
  Clear; FModified:=true;
  DelStack;
end;

procedure TIniFileCheck.ClearSection;
begin
  AddStack('TIniFileCheck.ClearSection');
  aSect[IntObj(Self,Index)].ls.Free;
  DelStack;
end;

procedure TIniFileCheck.DeleteKey(const Section,Ident: String);
var ls: TStrStrList;
  i: longint;
begin
  if FindValueIndex(Section,Ident,ls,i) then DeleteKey(ls,i);
end;

procedure TIniFileCheck.DeleteKey(ls: TStrStrList; i: longint);
begin
	AddStack('TIniFileCheck.DeleteKey');
  ls.Delete(i); FModified:=true;
  DelStack;
end;

procedure TIniFileCheck.UpdateFile;
var i,j,f: longint;
	ls: TStrStrList;
  s: string;
begin
 	AddStack('TIniFileCheck.UpdateFile');
  if FModified and not NoWriteFile then
    if not IfThenNotify(OnUpdate,Self) then repeat
      f:=FileBufCreate(FFileName);
      if f=-1 then begin
        if Ask(['Ошибка записи в файл',FFileName,
        'Возможно, отсутствуют права на запись,','или файл занят другим приложением.',
        'Повторить попытку записи ?']) then continue;
      end
      else begin
        SectSort;
        try
          for i:=0 to Count-1 do begin
            s:='['+Strings[i]+']'+CRLF; FileWrite(f,pointer(s)^,Length(s));
            ls:=aSect[IntObj(Self,i)].ls;
            for j:=0 to ls.Count-1 do begin
              s:=FValue(ls,j)+CRLF; FileWrite(f,pointer(s)^,Length(s));
            end;
          end;
          FModified:=false;
        finally
          FileClose(f);
        end;
        Sorted:=true;
      end;
      break;
    until false;
  IfThenNotify(OnAfterUpdate,Self);
  DelStack;
end;

function FSectSort(List: TStringList; Index1,Index2: longint): longint;
begin
	AddStack('My_pr.FSectSort');
  with TIniFileCheck(List) do
    result:=aSect[IntObj(List,Index1)].nInit-aSect[IntObj(List,Index2)].nInit;
  DelStack;
end;

procedure TIniFileCheck.SectSort;
begin
  AddStack('TIniFileCheck.SectSort');
  Sorted:=false; CustomSort(FSectSort);
  DelStack;
end;

function TIniFileCheck.FValue;
begin
  AddStack('TIniFileCheck.FValue');
  result:=ls.Value[Index];
  if result<>'' then IncL(result,ls.NameValueSeparator);
  IncL(result,ls[Index]);
  DelStack;
end;

function TIniFileCheck.ValueExists;
var ls: TStrStrList;
  i: longint;
begin
	AddStack('TIniFileCheck.ValueExists');
  result:=FindValueIndex(Section,Ident,ls,i);
  DelStack;
end;

procedure TIniFileCheck.ReadSection;
var ls: TStrStrList;
begin
	AddStack('TIniFileCheck.ReadSection');
  if ReadSectionList(Section,ls) then Strings.Assign(ls) else Strings.Clear;
  DelStack;
end;

function TIniFileCheck.ReadSectionList;
var n: longint;
begin
  AddStack('TIniFileCheck.ReadSectionList');
  result:=IntObjFind(Self,Section,n);
  if result then ls:=aSect[n].ls else ls:=nil;
  DelStack;
end;

procedure TIniFileCheck.ReadSections(Strings: TStrings);
begin
	AddStack('TIniFileCheck.ReadSections(ls)');
  SectSort; Strings.Assign(Self); Sorted:=true;
  DelStack;
end;

function TIniFileCheck.ReadSections(var a: TArrStr): longint;
begin
	AddStack('TIniFileCheck.ReadSections(a)');
  SectSort; result:=LsArrDynamic(Text,a,CRLF); Sorted:=true;
  DelStack;
end;

procedure TIniFileCheck.ReadSectionValues(const Section: string; Strings: TStrings);
var i: longint;
	ls: TStrStrList;
begin
	AddStack('TIniFileCheck.ReadSectionValues(ls)');
  Strings.Clear;
  if ReadSectionList(Section,ls) then
    for i:=0 to ls.Count-1 do Strings.Add(ls[i]+ls.NameValueSeparator+ls.Value[i]);
  DelStack;
end;

function TIniFileCheck.ReadSectionValues(const Section: string; var a: TArrStr): longint;
var i: longint;
	ls: TStrStrList;
begin
	AddStack('TIniFileCheck.ReadSectionValues(a)');
  if ReadSectionList(Section,ls) then begin
    result:=ls.Count;
    if Length(a)<result then SetLength(a,result);
    for i:=0 to result-1 do a[i]:=ls[i]+ls.NameValueSeparator+ls.Value[i];
  end
  else result:=0;
  DelStack;
end;

procedure TIniFileCheck.WriteSectionValues;
var i: longint;
begin
  AddStack('TIniFileCheck.WriteSectionValues');
  with Strings do for i:=0 to Count-1 do WriteString(Section,Names[i],ValueFromIndex[i]);
  DelStack;
end;

procedure TIniFileCheck.RenameSection;
var i: longint;
begin
  AddStack('TIniFileCheck.RenameSection');
  if newSect<>oldSect then
  	if Find(oldSect,i) then begin
    	Sorted:=false; Strings[i]:=newSect; Sorted:=true; FModified:=true;
    end;
  DelStack;
end;

{ TInitFIni }
const REGSTR_PATH_GGSCHEM = 'Software\GGSchem';

class procedure TInitFIni.Init;
begin
	AddStack('TInitFIni.Init');
	if not Assigned(InitFIni) then InitFIni:=Create(AOwner);
  DelStack;
end;

constructor TInitFIni.Create;
const a: array[TFIniType] of string = ('SAVE','SCHEM','PPDOC');
var i: TFIniType;
	t,t1: longword;
  fn: TFileName;
  PrCreate,PrUpdate: TNotifyEvent;
begin
	AddStack('TInitFIni.Create',Self);
  inherited Create(AOwner);
  t:=My_pr.GetTickCount; fn:=ExeDir+FileRestart;
  while FileExists(fn) do begin
    t1:=My_pr.GetTickCount; // Обязательно присваивать в переменную, иначе не ждёт 30 сек.
    if t1-t>30*MSecsPerSec then break;
  end;
  DelFileAtr(PChar(fn));
  for i:=low(a) to high(a) do begin
    if (i=fiSchem) and (Int0(GetEnvironmentVariable('GGSchem'))>0) then begin
      PrCreate:=SchemCreate; PrUpdate:=SchemUpdate;
    end
    else begin
      PrCreate:=nil; PrUpdate:=nil;
    end;
    FFiles[i]:=TIniFileCheck.Create(ExeDir+a[i]+'.INI',PrCreate); FFiles[i].OnUpdate:=PrUpdate;
  end;
  DelStack;
end;

destructor TInitFIni.Destroy;
var i: TFIniType;
begin
	AddStack('TInitFIni.Destroy',Self);
  for i:=low(i) to high(i) do with FFiles[i] do begin
		UpdateFile; FreeAndNil(FFiles[i]);
  end;
  inherited Destroy;
  DelFileAtr(PChar(ExeDir+FileRestart));
  DelStack;
end;

procedure TInitFIni.UpdateFiles;
var i: TFIniType;
begin
  AddStack('TInitFIni.UpdateFiles',Self);
  for i:=low(FFiles) to high(FFiles) do if Assigned(FFiles[i]) then FFiles[i].UpdateFile;
  DelStack;
end;

function TInitFIni.GetFiles;
begin
	AddStack('TInitFIni.GetFiles',Self);
  result:=FFiles[Index];
  DelStack;
end;

procedure TInitFIni.SchemCreate;
var f: TIniFileCheck;
  i,j,l,n: longint;
  ls: TStringList;
label lend;
begin
  AddStack('TInitFIni.SchemCreate',Self);
  with GRegistry do begin
    RootKey:=HKEY_LOCAL_MACHINE;
    if KeyExists(REGSTR_PATH_GGSCHEM) then begin
      f:=pointer(Sender); ls:=TStringList.Create;
      try
        if not OpenKeyReadOnly(REGSTR_PATH_GGSCHEM) then goto lend;
        GetKeyNames(f); l:=f.Count; CloseKey; SetLength(f.aSect,l); Dec(l);
        for i:=0 to l do f.SectAdd(i,i);
        for i:=0 to l do begin
          if not OpenKeyReadOnly(REGSTR_PATH_GGSCHEM+'\'+f[i]) then goto lend;
          GetValueNames(ls); n:=IntObj(f,i);
          for j:=0 to ls.Count-1 do f.aSect[n].ls.IgnoreFindAdd(Trim(ls[j]),Trim(ReadString(ls[j])));
          CloseKey;
      end;
lend:
        f.Sorted:=true;
      finally
        ls.Free;
      end;
    end;
  end;
  DelStack;
end;

procedure TInitFIni.SchemUpdate;
var f: TIniFileCheck;
  i,j: longint;
  ls: TStrStrList;
  ls1: TStringList;
label lend;
begin
  AddStack('TInitFIni.SchemUpdate',Self);
  with GRegistry do begin
    f:=pointer(Sender); RootKey:=HKEY_LOCAL_MACHINE; Access:=KEY_ALL_ACCESS; ls1:=TStringList.Create;
    try
      for i:=0 to f.Count-1 do begin
        if not OpenKey(REGSTR_PATH_GGSCHEM+'\'+f[i],true) then goto lend;
        GetValueNames(ls1);
        for j:=0 to ls1.Count-1 do
          if not DeleteValue(ls1[j]) then goto lend;
        ls:=f.aSect[IntObj(f,i)].ls;
        for j:=0 to ls.Count-1 do begin
          WriteString(ls[j],ls.Value[j]);
          if not ValueExists(ls[j]) then goto lend;
        end;
        CloseKey;
      end;
lend:
    finally
      ls1.Free;
    end;
  end;
  DelStack;
end;

{ TInitBM }
class procedure TInitBM.Init;
begin
	AddStack('TInitBM.Init');
	if not Assigned(InitBM) then InitBM:=TInitBM.Create(AOwner);
  DelStack;
end;

constructor TInitBM.Create;
var i: TBMList;
begin
	AddStack('TInitBM.Create',Self);
	LsBM:=SortStrListCreate;
  {if not(csDesigning in ComponentState)
  then VBMName:=VarArrayCreate([1,1],varVariant);}
  for i:=low(aBMName) to high(aBMName) do AddBM(BMPref+aBMName[i]);
  DelStack;
end;

destructor TInitBM.Destroy;
begin
	AddStack('TInitBM.Destroy',Self);
  FreeObjects(LsBM);
  inherited Destroy;
  DelStack;
end;

procedure TInitBM.AddBM;
var bm: TBitMap;
  i: longint;
begin
	AddStack('TInitBM.AddBM',Self);
	{bm:=TBitMap.Create; bm.Handle:=LoadBitMap(HInstance,PChar(nm));
  LsBM.AddObject(TrimUpper(nm),bm);
  {if not(csDesigning in ComponentState) then begin
  	VarArrayRedim(VBMName,LsBM.Count); VBMName[LsBM.Count]:=nm;
  end;}
  if not IgnoreSlFindAdd(LsBM,TrimUpper(nm),i) then begin
    bm:=TBitMap.Create; LsBM.Objects[i]:=bm; bm.Handle:=LoadBitMap(HInstance,PChar(nm));
  end;
  DelStack;
end;

function TInitBM.FindBM(const nm: string; var bm: TBitMap): boolean;
var bmName: string;
begin
  AddStack('TInitBM.FindBM',Self);
  bmName:=TrimUpper(nm);
  result := PointerObjFind(LsBM,bmName,pointer(bm)) or PointerObjFind(LsBM,BMPref+bmName,pointer(bm));
  DelStack;
end;

function TInitBM.FindBM(const nm: string): TBitMap;
begin
  if not FindBM(nm,result) then result:=nil;
end;

function TInitBM.FindBM(const nm: TBMList; var bm: TBitMap): boolean;
begin
  result:=FindBM(aBMName[nm],bm);
end;

function TInitBM.FindBM(const nm: TBMList): TBitMap;
begin
  if not FindBM(nm,result) then result:=nil;
end;

{ TCustomDataFile }
function TCustomDataFile.FieldDec;
begin
	result:=FloatMaxDec;
end;

{ TIBDatabase }
destructor TIBDatabase.Destroy;
begin
  AddStack('TIBDatabase.Destroy',Self);
  DefaultTransaction.Free;
  inherited Destroy;
  DelStack;
end;

{ TTimerLock }
constructor TTimerLock.CreateProc;
begin
  AddStack('TTimerLock.CreateProc',Self);
  inherited Create(AOwner);
  Enabled:=false; OnTimer:=Proc;
  DelStack;
end;

procedure TTimerLock.Timer;
var oEnabled: boolean;
begin
  AddStack('TTimerLock.Timer',Self);
  oEnabled:=Enabled; Enabled:=false;
  inherited Timer;
  Enabled:=oEnabled;
  DelStack;
end;

{ TTimerOne }
constructor TTimerOne.CreateProc(Proc: TNotifyEvent; AOwner: TComponent);
begin
  AddStack('TTimerOne.CreateProc',Self);
  CreateProc(Proc,AOwner,[]);
  DelStack;
end;

constructor TTimerOne.CreateProc(Proc: TNotifyEvent; AOwner: TComponent; const AParams: array of variant);
begin
  AddStack('TTimerOne.CreateProc',Self);
  inherited Create(AOwner);
  Interval:=1; OnTimer:=Proc; CopyFromVArr(Params,AParams);
  DelStack;
end;

procedure TTimerOne.Timer;
begin
  AddStack('TTimerOne.Timer',Self);
  Enabled:=false;
  inherited Timer;
  if not Enabled then Free;
  DelStack;
end;

{ TApplTitle }
function ApplTitle;
begin
  AddStack('My_pr.ApplTitle');
  if not Assigned(FApplTitle) then begin
    FApplTitle:=TApplTitle.Create(Application.MainForm);
    with FApplTitle do begin
      Default:=Application.Title;
      ls:=SortStrListCreate; ls.CaseSensitive:=true;
      tmBlink:=TTimerLock.CreateProc(tmBlinkTimer,nil); tmBlink.Interval:=400;
    end;
  end;
  result:=FApplTitle;
  DelStack;
end;

destructor TApplTitle.Destroy;
begin
  AddStack('TApplTitle.Destroy',Self);
  tmBlink.Free; ls.Free;
  inherited;
  DelStack;
end;

function TApplTitle.SetActive;
begin
  AddStack('TApplTitle.SetActive',Self);
  result:=Value;
  if Value then begin
    ls.Add(S); tmBlink.Enabled:=true;
  end
  else if FindDel(ls,S) then if ls.Count=0 then begin
    tmBlink.Enabled:=false; ReDef:=false;
  end;
  DelStack;
end;

procedure TApplTitle.tmBlinkTimer;
begin
  AddStack('TApplTitle.tmBlinkTimer');
  ReDef:=not ReDef;
  DelStack;
end;

procedure TApplTitle.Add;
var i: longint;
begin
  AddStack('TApplTitle.Add',Self);
  i:=Length(aProc); SetLength(aProc,i+1); aProc[i]:=Proc;
  DelStack;
end;

procedure TApplTitle.Del;
var i,j,h: longint;
begin
  AddStack('TApplTitle.Del',Self);
  h:=high(aProc);
  for i:=0 to h do if @aProc[i]=@Proc then begin
    for j:=i+1 to h do aProc[i-1]:=aProc[i];
    SetLength(aProc,h); break;
  end;
  DelStack;
end;

procedure TApplTitle.SetReDef;
var i: longint;
begin
  AddStack('TApplTitle.SetReDef',Self);
  FReDef:=Value;
  if Value then begin
    if nAct>=ls.Count then nAct:=0;
    Application.Title:=ls[nAct]; Inc(nAct);
  end
  else Application.Title:=Default;
  for i:=low(aProc) to high(aProc) do aProc[i](FReDef);
  DelStack;
end;

{ TNoneProc }
class function TNoneProc.ValidFalse;
begin
  result:=false;
end;

class function TNoneProc.ValidTrue;
begin
  result:=true;
end;

{ TNone }
class procedure TNone.ApplShowHint;
var hi: TApplHintInfo;
begin
	AddStack('TNone.ApplShowHint');
  IfThenShowHint(oShowHint,HintStr,CanShow,HintInfo);
	hi.HintStr:=HintStr; hi.CanShow:=CanShow; hi.HintInfo:=HintInfo;
  HintInfo.HintControl.perform(WM_APPLHINT,0,LongInt(@hi));
	HintStr:=hi.HintStr; CanShow:=hi.CanShow; HintInfo:=hi.HintInfo;
  DelStack;
end;

class procedure TNone.ApplIdle;
var fl: boolean;
  KeyState: TKeyboardState;
begin
	AddStack('TNone.ApplIdle');
  if Assigned(oIdle) then oIdle(Sender,Done);
  if Done and Application.Active then begin
    fl := GetAsyncKeyState(vk_Insert)<>0;
    if fl<>InsPressed then begin
      InsPressed:=fl;
      if fl then if KeyActive<>K_Ins then
        if GetKeyboardState(KeyState) then
          if (ShortInt(KeyState[vk_Shift])>=0) and (ShortInt(KeyState[vk_Control])>=0)
          and (ShortInt(KeyState[vk_Menu])>=0) then begin
            NotD(InsModeOverride); MsgApplication(WM_INSMODECNG);
          end;
        end;
    end;
  DelStack;
end;

class function TNone.HookProc;
var msg: TWMCopyData;
begin
	Result:=False;
  {if  (Message.Msg<>70)
  and (Message.Msg<>71)
  and (Message.Msg<>28)
  and (Message.Msg<>45056)
  and (Message.Msg<>45057)
  then begin}
    if not(csDesigning in Application.ComponentState) then case Message.Msg of
      {WM_WINDOWPOSCHANGED: begin
        //if ((TWMWindowPosChanging(Message).WindowPos.flags and SWP_NOACTIVATE)=SWP_NOACTIVATE)
        if not ApplMinimizing then begin
          //addmsgfile(IntToHex(Int64(TWMWindowPosChanged(Message).WindowPos.flags),4)+' '+FormatDateTime('nn:ss',Now));
        end;
      end;}
      WM_COPYDATA: begin
        msg:=TWMCopyData(Message);
        if msg.CopyDataStruct.dwData=idDbgOnOff then begin
          SetWndDebug(IfThen(boolean(msg.CopyDataStruct.lpData^),msg.From));
          Message.result:=idDbgOnOff; Result:=True;
        end;
      end;
    //else addmsgfile(IntToHex(Int64(Message.Msg),4)+' '+FormatDateTime('nn:ss',Now));
    end;
    //if not result and Assigned(MainHookProc) then result:=MainHookProc(Message);
  //end;
end;

class procedure TNone.dsClose;
var q: TFIBQuery;
  ds: TFIBDataSet;
begin
  AddStack('TNone.dsClose');
  if IsClass(Sender,TFIBQuery,pointer(q)) then begin
    //if q.Open then addmsgfile('Query: '+q.SQL.Text);
    q.Close; q.FreeHandle;
  end
  else begin
    {if IsClass(Sender,TFIBDataSet,pointer(ds)) then if ds.Active then begin
      addmsgfile('QDelete: '+ds.QDelete.SQL.Text);
      addmsgfile('QInsert: '+ds.QInsert.SQL.Text);
      addmsgfile('QRefresh: '+ds.QRefresh.SQL.Text);
      addmsgfile('QSelect: '+ds.QSelect.SQL.Text);
      addmsgfile('QUpdate: '+ds.QUpdate.SQL.Text);
    end;}
    TDataSet(Sender).Close;
    if IsClass(Sender,TFIBDataSet,pointer(ds)) then ds.UnPrepare;
  end;
  DelStack;
end;

function BMByName(bm: TBitMap; const bmName: string): boolean;
var isnil: boolean;
  bm1: TBitMap;
begin
	AddStack('My_pr.BMByName');
  result:=true;
  if csDesigning in Screen.ComponentState
  then bm.Handle:=LoadBitMap(HInstance,PChar(bmName))
  else begin
    isnil := not Assigned(InitBM);
    if isnil then InitBM:=TInitBM.Create(Application.MainForm);
    if not InitBM.FindBM(bmName,bm1) then InitBM.FindBM(aBMName[low(aBMName)],bm1);
    if Assigned(bm1) then bm.Assign(bm1);
    if isnil then FreeAndNil(InitBM);
  end;
  DelStack;
end;

function BMByName(bm: TBitMap; bml: TBMList): boolean;
begin
  result:=BMByName(bm,aBMName[bml]);
end;

function BitMapCreate;
begin
  AddStack('My_pr.BitMapCreate');
  if not Assigned(Sender) then Sender:=TBitMap.Create;
  result:=Sender;
  DelStack;
end;

function GetDefFont(const cFontName: string;
	FontCharSet: TFontCharSet = RUSSIAN_CHARSET): TDefFont;
var i: longint;
	FontName: string;
begin
	AddStack('My_pr.GetDefFont');
	FontName:=TrimUpper(cFontName);
	with result do begin
    Color:=clBlack; Size:=9; Style:=[]; Charset:=FontCharSet;
  	if Screen.Fonts.Count>0 then Name:=Screen.Fonts[0] else Name:='';
    for i:=0 to Screen.Fonts.Count-1 do
      if TrimUpper(Screen.Fonts[i])=FontName then begin
        Name:=Screen.Fonts[i]; break;
      end;
  end;
  DelStack;
end;

procedure HelpTblProc(const Name: string; var result: variant);
const aOrigin: array[TSeekOrigin] of string = ('начала','текущей позиции','конца');
  aDWActionNm: array[TDWActionList] of string = ('добавление','копирование','редактирование');
  aFEChangeWhere: array[TFEChangeWhere] of string =
    ('перед просмотром','во время редактирования','сохранение значений','отказ от сохранения значений');
  aSummArrVid: array[TSummArrVid,1..2] of string =
    (('список'              ,'массив')
    ,('первый элемент'      ,'строка')
    ,('количество элементов','целое')
    );
var act: TDWActionList;
  sm: TSortMode;
  tp: TProtocolFileList;
  sma: TSummArrVid;
  sx: TSexList;
begin
  AddStack('My_pr.HelpTblProc');
  if Name=''
    then result:=VarArrayOf(
      [VarArrayOf(['ВВОДДЕЙСТ','Действия с окном ввода'])
      ,VarArrayOf(['ВВОДИЗМ','События, вызывающие изменения значений полей ввода'])
      ,VarArrayOf(['ДДАНВИД','Виды ввода периода динамических данных'])
      ,VarArrayOf(['ДДАНПЕР','Период изменения значения динамических данных'])
      ,VarArrayOf(['ДАНХРАН','Способ хранения данных'])
      ,VarArrayOf(['КЛАВ','Клавиши'])
      ,VarArrayOf(['ОКНОСОРТ','Виды сортировки объектов в окне'])
      ,VarArrayOf(['ПОЛ','Пол'])
      ,VarArrayOf(['ПРОТОКОЛ','Виды файлов протокола'])
      ,VarArrayOf(['ТБЛСПИС','Виды списка строк или столбцов таблицы'])
      ,VarArrayOf(['УПРКЛАВ','Управляющие клавиши'])
      ,VarArrayOf(['ФАЙЛОТНОС','Переход в файле относительно'])
      ])
  else if Name='ВВОДДЕЙСТ' then begin
    result:=VarArrayCreate([byte(low(aDWActionPrm)),byte(high(aDWActionPrm))],varVariant);
    for act:=low(aDWActionPrm) to high(aDWActionPrm) do
      result[byte(act)]:=ArrStrToVar([HelpBoldStr('"'+aDWActionPrm[act]+'"'),aDWActionNm[act]]);
  end
  else if Name='ВВОДИЗМ'
    then result:=ArrStrToVar(aFEChangeWhere)
  else if Name='ДДАНВИД' then result:=ArrStrToVar(aDWDDatD2)
  else if Name='ДДАНПЕР' then result:=ArrStrToVar(aDWDDatType)
  else if Name='ДАНХРАН' then result:=ArrStrToVar(aDWSvTypeNm)
  else if Name='КЛАВ'
    then result:=VarArrayLowCng(VAKeys,1)
  else if Name='ОКНОСОРТ' then begin
    result:=VarArrayCreate([byte(low(TSortMode)),byte(high(TSortMode))],varVariant);
    for sm:=low(TSortMode) to high(TSortMode) do result[byte(sm)]:=DEPgSortName(false,sm);
  end
  else if Name='ПОЛ' then begin
    result:=VarArrayCreate([byte(low(aSex)),byte(high(aSex))],varVariant);
    for sx:=low(aSex) to high(aSex) do result[byte(sx)]:=ArrStrToVar([HelpBoldStr('"'+aSex[sx]+'"'),aSexName[sx]]);
  end
  else if Name='ПРОТОКОЛ' then begin
    result:=VarArrayCreate([byte(low(aProtFile)),byte(high(aProtFile))],varVariant);
    for tp:=low(aProtFile) to high(aProtFile) do result[byte(tp)]:=aProtFile[tp,2];
  end
  else if Name='ТБЛСПИС' then begin
    result:=VarArrayCreate([byte(low(aSummArrVid)),byte(high(aSummArrVid))],varVariant);
    for sma:=low(aSummArrVid) to high(aSummArrVid) do
      result[byte(sma)]:= ArrStrToVar([HelpBoldStr(Int2Str(sma)),aSummArrVid[sma,1],aSummArrVid[sma,2]]);
  end
  else if Name='УПРКЛАВ'
    then result:=AddFrom(ArrVarToVar(['[нет]'],0),VAShftKeys)
  else if Name='ФАЙЛОТНОС'
    then result:=ArrStrToVar(aOrigin)
  ;DelStack;
end;

procedure Init;
var i: longint;
	cds: TCopyDataStruct;
  h: HMODULE;
  //d: Extended;
  w: TGFWinList;
  fl: boolean;
  prn: TPrnPrmList;
  tm: TDDatZnType;
const
	aCRName: array[1..crOurCount] of string =
    ('Left','Right','Up','Down','WLeft','WRight','WUp','WDown','LLine','RLine','ULine','DLine');
begin
	AddStack('My_pr.initialization');
  {SysOSR2 := (Win32Platform=VER_PLATFORM_WIN32_WINDOWS)
    and (Win32MinorVersion>100);}
	SetExeDir(ParamByCode('D',true)); CurrentDir:=CorrDir(GetCurrentDir);
  SetEpoch(1920); SetMonthName(2);
  // Шрифт по умолчанию
  GDefFont:=GetDefFont('Courier New');
  //GFont866:=GetDefFont(aEr866FontName[false],DEFAULT_CHARSET);
	// Установка имеющихся курсоров
	for i:=low(aCRName) to high(aCRName) do
		Screen.Cursors[i]:=LoadCursor(HInstance,PChar('Ourl_Cr'+aCRName[i]));
  with Application do begin
    oShowHint:=OnShowHint; OnShowHint:=TNone.ApplShowHint;
    oMinimize:=OnMinimize; OnMinimize:=nil;
    oIdle:=OnIdle; OnIdle:=TNone.ApplIdle;
  end;
  VBMName:=ArrStrToVar(aBMName);
  for i:=VarArrayLowBound(VBMName,1) to VarArrayHighBound(VBMName,1) do VBMName[i]:=BMPref+VBMName[i];
	VAKeys:=ArrStrToVar(aTxtLab);
	VAShftKeys:=ArrStrToVar(aKeyShft);
  Application.HookMainWindow(TNone.HookProc);
  ZeroMemory(@cds,SizeOf(cds)); cds.dwData:=idProgOn; CopyDataAllWnd(Application.Handle,cds);
  SystemRoot:=CorrDir(GetRegKey(HKEY_LOCAL_MACHINE,IfThen(Win32Platform=VER_PLATFORM_WIN32_NT,
  	'Software\Microsoft\Windows NT\CurrentVersion',REGSTR_PATH_SETUP),REGSTR_VAL_SYSTEMROOT));
  if Win32Platform=VER_PLATFORM_WIN32_NT
  then FileHosts:=CorrDir(StrTran(GetRegKey(HKEY_LOCAL_MACHINE,
  	REGSTR_PATH_SERVICES+'\Tcpip\Parameters','DatabasePath'),'%SYSTEMROOT%',
    CorrDir(SystemRoot,crdrNoDlmEnd),[rfReplaceAll,rfIgnoreCase]))
  else FileHosts:=SystemRoot;
  FileServices:=FileHosts+'services';
  IncD(FileHosts,'hosts');
  if Win32Platform=VER_PLATFORM_WIN32_NT then begin
    h:=GetModuleHandle('kernel32');
    if h<>0 then pIsWow64Process:=GetProcAddress(h,'IsWow64Process')
  end;
  RandSeed:=My_pr.GetTickCount;
  aGFLinesLoad;
  for w:=low(aGFWtoS) to high(aGFWtoS) do begin
  	aGFStoW[aGFWtoS[w]]:=w; fl := w=gfwPrm; i:=Length(aGFLtoW[fl]);
    SetLength(aGFLtoW[fl],i+1); aGFLtoW[fl][i]:=w;
  end;
  for i:=low(aDEDlm) to high(aDEDlm) do Include(setDEDlm,aDEDlm[i]);
  for i:=low(PosToAlgm) to high(PosToAlgm) do AlgmToPos[PosToAlgm[i]]:=i;
  sPrnPrmBool:=[];
  for prn:=low(aPrnPrmDef) to high(aPrnPrmDef) do with aPrnPrmDef[prn] do begin
  	lSave := prn in [pprmSortCop,pprmEcon,pprmVIntv,pprmHIntv,pprmFeed,pprmNoNewPg,pprmMirror];
    if MyVarType(Def)=varBoolean then Include(sPrnPrmBool,prn);
  end;
  with TBitmap.Create do try
    Handle:=LoadBitmap(0,PChar(OBM_CHECKBOXES)); WinSize(CheckSize,Width div 4,Height div 3);
  finally
    Free;
  end;
  for tm:=low(aDDatZnFld) to high(aDDatZnFld) do
    aDDatZnFld[tm]:=IfThen(tm<>ddznSimple,aBegMem[aDDatMemoAttr[tm]])+fDDZN;
  AddFrom(HelpTblProc);
  DelStack;
end;

initialization
  Init;
finalization
  with Application do begin
	  OnShowHint:=oShowHint; OnMinimize:=oMinimize;
  end;
  DisposeNil(pointer(pcds)); DisposeNil(pointer(pnUserGG));
  DisposeNil(pointer(PUserWorkArea)); Reg.Free; DisposeNil(pointer(paResProcess));
  DisposeNil(PSftpPath); DisposeNil(pointer(aUnicode)); lsUnicode.Free;
  DisposeNil(pointer(FDateBigOld)); DisposeNil(pointer(aGFLines));
  DisposeNil(FEdoGetDokVdNames);
  lsPrim.Free;
  if PadegDllHandle<>0 then FreeLibrary(PadegDllHandle);
  Application.UnhookMainWindow(TNone.HookProc);
  if NormalExit then DelMaskFiles(ExeDir+'*.BDC');
	OutStack('Ошибка при выходе из программы: стек не пустой');
end.

