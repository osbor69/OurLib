unit mulqry;

interface

{$I LIBTEST}
uses
	SysUtils,Classes,DB,pFIBDataSet,Math,
  MyTypes,My_pr,BufFile;

type
  TIBQuery = class(TpFIBDataSet)
  protected
		procedure InitFieldDefs; override;
  end;

  TMQFieldList = class(TStringList)
  private
    af: array of TMQFieldInfo;
    function AddObj(const nmf: string): PMQFieldInfo;
  public
    constructor Create;
		function Fields(const Index: variant): PMQFieldInfo; overload;
		function Fields(const Index: variant; var fi: PMQFieldInfo): boolean; overload;
		function IsField(const NmFld: string): boolean;
    function IsFieldBool(const nmf: string): boolean;
    procedure GetKeyOrd(var a: TArrInt);
    class function IBDataType(tp: longint): TFieldType;
  end;

  TMQIndexList = class(TStringList)
  private
    ai: TArrArrStr;
  public
    constructor Create(db: TComponent; const tbl: string; lConstraint: boolean = false);
		function Indices(const Index: variant): TArrStr;
  end;

  TMQSaveToOptions = set of (mqsvNoClr,mqsvQQ,mqsvNoTrimRight);
  TDBFlushOpt = set of (flushConnect,flushBound);
  TUnQuerySelOpt = set of (unqNot,unqNoOpen);

  Pmulquery = ^Tmulquery;
	Tmulquery = class(TCustomDataFile)
	private
		{ Private declarations }
    FConnection: TComponent;
		FMulPar: TMulQueryMulPar;
		Fpart:string;
		FActiveTry:boolean;
    FDataSource: TDataSource;
    FBeforeOpen,FAfterOpen,FBeforeClose,FAfterClose,oAfterScroll: TDataSetNotifyEvent;
    FDisableCount,FRowsAffected: longint;
    PrmEnabledControls: pointer;
    LsFld: TStringList;
  	procedure qAfterClose(DataSet: TDataSet);
  	procedure qAfterOpen(DataSet: TDataSet);
  	procedure qBeforeClose(DataSet: TDataSet);
  	procedure qBeforeOpen(DataSet: TDataSet);
		function GetActive: boolean;
		procedure SetActive(Value: boolean);
		procedure SetDataSource(Value: TDataSource);
    function GetBufferChunks: longint;
		procedure SetBufferChunks(Value: longint);
		function GetFiltered: boolean;
		procedure SetFiltered(Value: boolean);  
    function GetAfterScroll: TDataSetNotifyEvent;
    procedure SetAfterScroll(Value: TDataSetNotifyEvent);
    function GetOnCalcFields: TDataSetNotifyEvent;
    procedure SetOnCalcFields(Value: TDataSetNotifyEvent);
    function GetOnFilterRecord: TFilterRecordEvent;
    procedure SetOnFilterRecord(Value: TFilterRecordEvent);
		function GetFieldDefs: TFieldDefs;
		procedure SetFieldDefs(Value: TFieldDefs);
		function GetRequestLive: boolean;
		procedure SetRequestLive(Value: boolean);
		function GetUniDirectional: boolean;
		procedure SetUniDirectional(Value: boolean);
		procedure SetConnection(Value: TComponent);
		function SetCurrSQL(const nameSQL: string):string;
		procedure SetMulPar(Value: TMulQueryMulPar);
		function GetArg(const Index: string): variant;
		procedure SetArg(const Index: string; const v: variant);
		procedure SetFpart(const name:string);
		procedure FchangeArg(Sender: TObject);
		procedure FillSQL;
    function lsSQL: TStrings;
    function LsFldFind(const FieldName: string; var Index: longint): boolean;
    function FieldCreate(const FieldName,DisplayLabel: string;
      IB: TFieldClass; NoIB: TFieldClass = nil): TField;
    function PartGroup(const table: string; const c_list: array of variant;
      const where,nmf: string; lOpen: boolean = true): string;
	protected
		{ Protected declarations }
   	procedure DoBeforeClose; dynamic;
    procedure AssignTo(Dest: TPersistent); override;
		procedure DoAfterClose; dynamic;
		procedure DoAfterOpen; dynamic;
		procedure DoBeforeOpen; dynamic;
    procedure DoEnableControls(Value: boolean); dynamic;
		procedure Notification(AComponent: TComponent; Operation: TOperation); override;
	public
		{ Public declarations }
		DataSet: TDataset;
    aObjInActive: TArrObject;
    OnEnableControls: procedure(Value: boolean; var Prm: pointer) of object;
		property Active: boolean read GetActive write SetActive;
		property BufferChunks: longint read GetBufferChunks write SetBufferChunks;
		property DataSource: TDataSource read FDataSource write SetDataSource;
    property FieldDefs: TFieldDefs read GetFieldDefs write SetFieldDefs;
		property Filtered: boolean read GetFiltered write SetFiltered;
		property RequestLive: boolean read GetRequestLive write SetRequestLive;
    property UniDirectional: boolean read GetUniDirectional write SetUniDirectional; // не поддерживает order by
    property AfterClose: TDataSetNotifyEvent read FAfterClose write FAfterClose;
    property AfterOpen: TDataSetNotifyEvent read FAfterOpen write FAfterOpen;
    property AfterScroll: TDataSetNotifyEvent read GetAfterScroll write SetAfterScroll;
    property BeforeClose: TDataSetNotifyEvent read FBeforeClose write FBeforeClose;
    property BeforeOpen: TDataSetNotifyEvent read FBeforeOpen write FBeforeOpen;
    property OnCalcFields: TDataSetNotifyEvent read GetOnCalcFields write SetOnCalcFields;
    property OnFilterRecord: TFilterRecordEvent read GetOnFilterRecord write SetOnFilterRecord;
		constructor Create(AOwner: TComponent = nil); override;
		constructor CreateConnection(AOwner: TComponent = nil; AConnection: TComponent = nil); overload;
		class function CreateConnection(var Qry: TMulQuery; AOwner: TComponent; AConnection: TComponent): boolean; overload;
		class function CreateNoActive(var Qry: TMulQuery; AOwner: TComponent; AConnection: TComponent = nil): boolean; overload;
		destructor Destroy; override;
    procedure ConnectionDef;
		function SetPart(const name: string): string; overload;
		function SetPart(q: TMulQuery): string; overload;
		function SetPart: string; overload;
		function GetPart(const name: string; const argname: array of string;
    	const argval: array of variant): string;
		function ExecPart(const name:string; lMsg: boolean = false):boolean;
		function ExecMpart(const a: array of string; lMsg: boolean = false): boolean;
		function ExecInsFromSel:boolean;
		property Arg[const Index: string]: variant read GetArg write SetArg; default;
    procedure IncArgAnd(const d2: string; const Index: string = sWHERE);
		procedure AddArgList(const index: string; const v: variant);
		procedure AddArrayList(const Index: string; const aa:array of variant);
		procedure SetArrayList(const Index: string; const aa:array of variant);
		function ExecTry(lMsg: boolean = false):boolean;
    function OpenTry(lMsg: boolean = false): boolean;
		function FieldZN(const FieldName: string; const TableName: string = ''): variant;
    function VarToS(const vv: variant; Opt: TVarToSOpt = []): string; overload;
    function VarToS(const vv: variant; Opt: TVarToSList): string; overload;
    function VarToS(f: TField; Opt: TVarToSOpt = []): string; overload;
    function VarToS(f: TField; Opt: TVarToSList): string; overload;
    function QQHighLim(const nmf: string; const v: variant): string;
		function QQDate(const nmf: string; const v: variant): string; overload;
		function QQDate(const nmf: string; const db,de: variant): string; overload;
		function StrNow: string;
		function SQLDateTime(const d: variant; lQQ: boolean = true): string;
		function DrvCan(const Index: string): boolean;
    function PartSelect(const table: string; const c_list: string;
      const where: string = ''; const o_list: string = ''; const g_list: string = '';
      lOpen: boolean = true; const have: string = ''): string; overload;
    function PartSelect(const table: string; const c_list: array of variant;
      const where: string = ''; const o_list: string = ''; const g_list: string = '';
      lOpen: boolean = true; const have: string = ''): string; overload;
    function PartCount(const table: string; const where: string = ''): longint; overload;
    function PartCount(const table: string; const c_list: array of variant;
      const where: string = ''; lOpen: boolean = true): string; overload;
    function PartCount0(const table: string; const where: string = ''): boolean;
    function PartMaxInt(const table,nmf: string; const where: string = ''): longint;
    function PartMaxDate(const table,nmf: string; const where: string = ''): TDateTime;
    function PartMax(const table,nmf: string; const where: string = ''; lOpen: boolean = true): string; overload;
    function PartMax(const table,nmf: string; const c_list: array of variant;
      const where: string = ''; lOpen: boolean = true): string; overload;
    function PartMinDate(const table,nmf: string; const where: string = ''): TDateTime;
    function PartMin(const table,nmf: string; const where: string = ''; lOpen: boolean = true): string; overload;
    function PartMin(const table,nmf: string; const c_list: array of variant;
      const where: string = ''; lOpen: boolean = true): string; overload;
    procedure UpdateTable(const table: string; const c_list,v_list: array of variant;
    	const where: string = ''); overload;
    procedure UpdateTable(const table: string = ''; const where: string = ''); overload;
    procedure UpdateTableFldList(const c_list,v_list: array of variant;
      const azn: array of string; l: longint = NegDef; const nmf: string = fRECNO; Opt: TFldInListOpt = [];
      const table: string = ''; const where: string = ''); overload;
    procedure UpdateTableFldList(const c_list,v_list: array of variant;
      ls: TIntegerList; const nmf: string = fRECNO;
      const table: string = ''; const where: string = ''); overload;
    procedure UpdateTableList(const awhere: array of string; const table: string = ''; const where: string = ''); overload;
    procedure UpdateTableList(const awhere: array of string;
      const c_list,v_list: array of variant; const table: string = ''; const where: string = ''); overload;
		function DeleteTable(const table: string = ''; const where: string = ''; lMsg: boolean = false): boolean;
		function DeleteTableFldList(const azn: array of string;
      l: longint = NegDef; const nmf: string = fRECNO; Opt: TFldInListOpt = [];
      const table: string = ''; lMsg: boolean = false; const where: string = ''): boolean;
		function DeleteTableList(const awhere: array of string;
      const table: string = ''; lMsg: boolean = false; const where: string = ''): boolean;
		function InsertTable(const table: string; const c_list,v_list: array of variant): boolean;
		function FGetDriverName: string;
		function FldInSel(const nmf,tbl: string; const where: string = ''; const snmf: string = '';
    	Opt: TFldInSelOpt = []; ares: PArrStr = nil; const group: string = '';
      qs: TMulQuery = nil; ls: TStringList = nil): string;
		function GetList(const aa: array of variant; l: longint = NegDef): string;
		procedure GetListArg(const name: string; var a: TArrStr); overload;
		function GetListArg(const name: string): string; overload;
		function UnionOpen(const a: array of TUnionDefRec; l: longint = NegDef; lOpen: boolean = true; pOrd: PArrInt = nil): string;
		function DropTable(const tbl: string; msgErr: pstring=nil): boolean;
		function Concat(const a: array of variant; l: longint = NegDef): string;
		function GetArgParam(const Index: string): string;
    function FindField(const FieldName: string): TField; overload;
    function FindField(const TableName,FieldName: string): TField; overload;
    function FindField(const FieldName: string; var f: TField): boolean; overload;
    function FindField(const TableName,FieldName: string; var f: TField): boolean; overload;
    function FindField(usl: boolean; const FieldName: string): TField; overload;
    function IsField(const FieldName: string): boolean; override;
		function NumFromName(const nmf: string; var i: longint): boolean; override;
		function ActiveNoNil: boolean;
    function Origin(f: TField): string;
		function CreateField(const FieldName: variant; Visible: boolean = false): TField; overload;
		function CreateField(usl: boolean; const FieldName: variant; Visible: boolean = false): TField; overload;
		function CreateField(ls: TMQFieldList; const FieldName: variant; Visible: boolean = false): TField; overload;
		function CreateIntegerField(const FieldName: string; const DisplayLabel: string = '';
    	DisplayWidth: longint = 0): TIntegerField;
		function CreateFloatField(const FieldName: string; const DisplayLabel: string;
    	nLen,nDec: longint): TFloatField;
		function CreateStringField(const FieldName: string; const DisplayLabel: string = '';
    	Size: longint = 0; Alignment: TAlignment = taLeftJustify): TStringField;
		function CreateDateField(const FieldName: string; const DisplayLabel: string = '';
    	const DisplayFormat: string = 'dd/mm/yyyy'; DisplayWidth: longint = 10): TDateTimeField;
		function CreateMonthField(const FieldName: string; const DisplayLabel: string = ''): TDateTimeField;
		function CreateBooleanField(const FieldName: string; const DisplayLabel: string = ' '): TBooleanField;
		function FldDuplicate(const nmf: string; n: longint = 1): string;
		function GetMaxFld(const nmFld,nmTbl: string; pVal: PLongInt = nil;
    	lSave: boolean = false; const where: string = ''): longint;
		procedure ShowErr(E: Exception = nil);
		procedure SQLText(const Value: string);
    procedure Commit(ChkTrns: boolean = true);
    function IsRecords: boolean;
    function IsRecordsAsString: string; overload;
    function IsRecordsAsString(var Value: string): boolean; overload;
    function IsRecordsAsInteger: longint; overload;
    function IsRecordsAsInteger(f: TField): longint; overload;
    function IsRecordsAsInteger(f: TField; var Value: longint): boolean; overload;
    function RecordCountInRange(const MinValue: longint = 1; const MaxValue: longint = 1): boolean;
    procedure MaxFldClear(const nmTbl: string);
    procedure MaxFldClearAll;
    procedure DBFlush(Opt: TDBFlushOpt = []);
    procedure DBDeleteIndex;
		class procedure ClearSql;
		class procedure MessSql(fl:boolean);
    function FieldValueIndex(Index: longint): variant;
    function FieldAsString(const FieldName: string): string; 
		procedure DisableControls;
		procedure EnableControls;
		procedure First; override;
		procedure Last; override;
		procedure Next; override;
		procedure Prior;
    function MoveBy(Distance: longint): longint; //override;
		function Eof: boolean; override;
		function Bof: boolean;
		function RecordCount: longint; override;
		function RecordCountFiltered: longint;
		procedure Open;
		procedure Close; override;
		procedure ReOpen;
		function FieldCount: longint; override;
		procedure Append;
		procedure Edit;
		procedure Post;
		procedure Delete;
		function GetBookMark(usl: boolean = true): TBookMark; overload;
		function GetBookMark(var Sender: TBookMark): TBookMark; overload;
		procedure GotoBookMark(bm: TBookMark);
		procedure FreeBookMark(bm: TBookMark);
		procedure Prepare;
		procedure UnPrepare;
    function ParamByName(const Value: String): TObject;
		procedure ExecSQL;
		function Text: string;
		function Fields: TFields;
    function ValueNum(Index: longint): variant; override;
    function ValueName(const Name: string): variant; override;
		function FieldName(Index: longint): string; override;
		function DataType(Index: longint): TFieldType; override;
		function FieldLen(Index: longint): Word; override;
    function NotNull(Index: longint; p: pointer): boolean; override;
    function RowsAffected: longint;
    function qRecno(lEq: boolean = true): string;
    function GetContent(const Msg: string): string;
    procedure OutStackQry(const Msg: string);
    class procedure AddTablesFreeHandle(const aTables: array of string);
		procedure SetParamValue(Index: longint; const Value: string);
		procedure FindFirst;
		function FindEof: boolean;
		procedure FindNext;
    procedure SaveTo(var result: TArrStr; Opt: TMQSaveToOptions = []; Field: TField = nil; const sbeg: string = ''); overload;
    procedure SaveTo(var result: TArrInt; l: PLongInt = nil; Field: TField = nil); overload;
    procedure SaveTo(result: TStringList; lClr: boolean = true); overload;
    procedure SaveTo(result: TIntegerList; lClr: boolean = true); overload;
    procedure SaveTo(var result: variant); overload;
    function FldDataType(i: longint): TFieldType;
    function CntRec: longint;
    function QryCur: TMulQuery; overload;
    class function QryCur(var q: TMulQuery): TMulQuery; overload;
    class function QryCur(var q: TObject): TObject; overload;
    function ModelCreateFields: TStringField;
    class procedure ModelCalcFields(DataSet: TDataSet);
    function ReplDateBigEmpty(const nmf: string): TDateTime;
    function ReplDateNullEmpty(const nmf: string): TDateTime;
		procedure SetFilterProc(Value: boolean; Proc: TFilterRecordEvent); 
    procedure QryFio(const tbl: string = ''); overload;
    function QryFio(const clist: array of variant; const tbl: string = ''): string; overload;
	published
		{ Published declarations }
    property Connection: TComponent read FConnection write SetConnection;
		property MulPar: TMulQueryMulPar read FMulPar write SetMulPar;
		property Part:string read Fpart write SetFpart;
	end;

  TArrMulQuery = array of TMulQuery;

  TUnQuery = class(TCustomDataFile)
  private
    FFRecNo {Конфликтует с fRECNO},FirstActive: longint;
    FConnection: TComponent;
    procedure SetConnection(Value: TComponent);
    procedure SetRecno(cValue: longint);
    function OpenPart: boolean;
  protected
		procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
		aq: TArrMulQuery;
    PartIndex,PartCount: longint;
    BufferChunks,UniDirectional: boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PartSelect(const table: string; const c_list: array of variant;
      const nmf: string; const azn: array of string; Opt: TUnQuerySelOpt = [];
      const where: string = ''; const o_list: string = ''; const StatCapt: string = ''); overload;
    procedure PartSelect(const Def: TUnQueryDef;
      lOpen: boolean = true; const StatCapt: string = ''); overload;
		procedure Open(const StatCapt: string = '');
		procedure First; override;
		procedure Last; override;
		procedure Next; override;
		function Active: boolean;
		function Eof: boolean; override;
		procedure Close; override;
		function NumFromName(const nmf: string; var i: longint): boolean; override;
		property RecNo: longint read FFRecNo write SetRecNo;
    //function MoveBy(Distance: longint): longint; override;
		function Fields(i: longint): TField;
		property Connection: TComponent read FConnection write SetConnection;
		function FieldCount: longint; override;
		function FieldName(Index: longint): string; override;
    function RecordCount: longint; override;
		function ValueNum(i: longint): variant; override;
    function ValueName(const Name: string): variant; override;
    function IsField(const FieldName: string): boolean; override;
		function DataType(Index: longint): TFieldType; override;
		function FieldLen(Index: longint): Word; override;
    function NotNull(Index: longint; p: pointer): boolean; override;
		function GetBookMark: TUnBookMark;
		procedure GotoBookMark(const bm: TUnBookMark);
		procedure FreeBookMark(const bm: TUnBookMark);
  end;

  TCopyTableValueProc = procedure(dFrom: TCustomDataFile; const FieldName: string; var v: variant);
  TDBTextCreateStreamProc = function(const av: array of variant): TStream;

	TDBTextFields = array of record
    Name: string;
    DataType: TFieldType;
    Size: longint;
    Value: variant;
    BlobPos,BlobLen: longint;
    NotNull: boolean;
  end;

  TDatabaseText = class(TCustomDataFile)
  private
    FFields: TDBTextFields;
    lsFld: TStringList;
    qSource: TObject;
    SvSum,rc: longint;
  	FRecordCount: longint;
  	FileStream: TFileBufStream;
    Vers: byte;
    tpLen: TSaveType;
    FPosition,pzFirst: Int64;
    DateEmptyAsNull: boolean;
    procedure SetPosition(Value: Int64);
		procedure GetRec;
		procedure Write(const Value: variant; tp: TSaveType);
		procedure WriteStr(const Value: string; tpLen: TSaveType = stByte);
		function Read(tp: TSaveType): variant; overload;
		function Read(usl: boolean; tp: TSaveType; const Def: variant): variant; overload;
		function ReadStr(tpLen: TSaveType = stByte): string;
  public
    ValueProc: TCopyTableValueProc;
    TableName: string;
    constructor CreatePrm(const Path,Table: string; ADateEmptyAsNull: boolean = false;
      Source: TObject = nil);
    destructor Destroy; override;
		procedure Close; override;
		procedure Add;
		function RecordCount: longint; override;
    procedure First; override;
    procedure Last; override;
		function Eof: boolean; override;
		procedure Next; override;
    //function MoveBy(Distance: longint): longint; override;
		function NumFromName(const nmf: string; var i: longint): boolean; override;
    function ValueNum(Index: longint): variant; override;
    function ValueName(const Name: string): variant; override;
		function FieldIndex(const FieldName: string): longint;
    function IsField(const FieldName: string): boolean; override;
		function FieldCount: longint; override;
		function FieldName(Index: longint): string; override;
		function DataType(Index: longint): TFieldType; override;
		function FieldLen(Index: longint): Word; override;
    function NotNull(Index: longint; p: pointer): boolean; override;
		procedure CopyToBlobField(Field: TField; Index: longint);
    function BlobCopyToStream(Index: longint; CreateStreamProc: TDBTextCreateStreamProc;
      const av: array of variant): TStream;
    property Fields: TDBTextFields read FFields;
    property Position: Int64 read FPosition write SetPosition;
  end;

  TIniFileData = class(TObject)
  private
    IsData,IsGGI: boolean;
    function fRead(const Section: string; const Ident: string = ''; lInv: boolean = false): TIniFileCheck;
  public
    aIniFileCheck: array[boolean] of TIniFileCheck;
    constructor Create; overload;
    class function Create(var Sender: TIniFileData): TIniFileData; overload;
    destructor Destroy; override;
    function SectionExists(const Section: string): Boolean;
    function ReadString(const Section,Ident: string; const Default: string = ''): string;
    function ReadInteger(const Section,Ident: string; Default: Longint = 0): Longint;
    function ReadBool(const Section,Ident: string; Default: Boolean = false): Boolean;
    procedure WriteString(const Section,Ident,Value: String);
    procedure WriteInteger(const Section,Ident: string; Value: Longint);
    procedure WriteBool(const Section,Ident: string; Value: Boolean);
    procedure ReadSections(Strings: TStrings); overload;
    function ReadSections(var a: TArrStr): longint; overload;
    procedure ReadSectionValues(const Section: string; Strings: TStrings);
    procedure WriteSectionValues(const Section: string; Strings: TStrings);
    procedure EraseSection(const Section: string; CompBeg: boolean = false);
    procedure DeleteKey(const Section,Ident: String);
    procedure UpdateFile;
    function fWrite: TIniFileCheck;
    class procedure Init;
  end;

  TIniFileSave = class(TObject)
  private
    IsGGI: boolean;
    fd: TIniFileData;
  public
    constructor Create;
    destructor Destroy; override;
    function ReadString(const Section,Ident: string; const Default: string = ''): string;
    function ReadInteger(const Section,Ident: string; Default: Longint = 0): Longint;
    procedure WriteString(const Section,Ident,Value: String);
    procedure WriteInteger(const Section,Ident: string; Value: Longint);
  end;

  TArrBoolQry = array[boolean] of TMulQuery;

  TQryFindCompProc = function(q: TMulQuery; const v: variant): TValueSign;

  TQrySynchroProc = procedure(Sender: TMulQuery; i: longint) of object;

  TQrySynchro = class(TObject)
  private
    FKey: TArrStr;
    FItems: TArrMulQuery;
    aFld: TArrField;
    function GetItems(Index: longint): TMulQuery;
    procedure Synchro;
    class procedure qFree(Sender: TMulQuery; i: longint);
    procedure qFirst(Sender: TMulQuery; i: longint);
  protected
		function KeyValue(i: longint): variant; dynamic;
  public
  	//OnKeyValue: procedure(Sender: TMulQuery; Index: longint; var result: variant);
    property Items[Index: longint]: TMulQuery read GetItems; default;
    destructor Destroy; override;
    procedure SetKey(const aKey: array of string);
    procedure First;
    procedure Next;
    function Eof: boolean;
    function FieldZn(const nmf: string): variant;
    function RecordCount: longint;
    procedure QryProc(Proc: TQrySynchroProc);
    function Count: longint;
		function GetBookMark: TArrBookMark;
		procedure GotoBookMark(const bm: TArrBookMark);
		procedure FreeBookMark(const bm: TArrBookMark);
  end;

  TPrimFldProc = procedure(const tbl,nmf: string; var prim: string; var PrimSave: boolean);

  TDBTypeList0 = (dbtpNone,dbtpDriver,dbtpAlias); TDBTypeList = Succ(dbtpNone)..high(TDBTypeList0);
  TDBTypeStr = array[TDBTypeList] of string;

const
  aStpDat: TDBTypeStr = (stpDatDriver,stpDatAlias);

  aSQLExec: array[1..2,TSQLExecType] of string =
    (('UPDATE','INSERT','DELETE')
    ,(''      ,'INTO'  ,'FROM')
    );

var
  GetQuery: function(Connection: TComponent = nil): TMulQuery;
  GetQueryIf: function(lIf: boolean): TMulQuery;
  CurQuery: function: TMulQuery;
  FreeQuery: procedure;
  FreeQueryIf: procedure(q: TMulQuery);
  NoDBFlush: boolean;

procedure Register;

function GetDriverName(Connection: TComponent): string;
function FirstDataBase(Connection: TComponent = nil): TComponent; overload;
function FirstDataBase(Connection: TComponent; var db: TComponent): boolean; overload;
procedure FirstDataBaseSelf(var Connection: TComponent);
function DBDrvCan(const Index: string): boolean;
function CreateDrvInfo(const nm1: string): PDriverInfo;
function GetDrvInfo(Sender: TObject; const nmDrv: string = ''): PDriverInfo;
procedure ClearDrvInfo(pd: PDriverInfo);
//function CurQryOpen(n: longint): TMulQuery;
function IsTable(db: TComponent; const TableName: string): boolean; overload;
function IsTable(const TableName: string): boolean; overload;
function DBFldValue(db: TComponent; const TableName,cFieldName: string; var res: variant): boolean;
procedure GetTableNames(db: TComponent; ls: TStringList); overload;
procedure GetTableNames(ls: TStringList); overload;
procedure GetFieldNames(db: TComponent; const tbl: string; ls: TStringList); overload;
procedure GetFieldNames(const tbl: string; ls: TStringList); overload;
function GetTableList(db: TComponent = nil): TStringList;
function GetFieldList(db: TComponent; const tbl: string): TMQFieldList; overload;
function GetFieldList(const tbl: string): TMQFieldList; overload;
function GetFieldList(db: TComponent; const tbl: string; var ls: TMQFieldList): boolean; overload;
function GetFieldList(const tbl: string; var ls: TMQFieldList): boolean; overload;
function IsField(db: TComponent; const tbl,nmf: string): boolean; overload;
function IsField(const tbl,nmf: string): boolean; overload;
function GetFieldInfo(db: TComponent; const tbl,nmf: string; var fi: PMQFieldInfo): boolean; overload;
function GetFieldInfo(const tbl,nmf: string; var fi: PMQFieldInfo): boolean; overload;
function GetFieldInfo(const tbl,nmf: string): PMQFieldInfo; overload;
function IsSQLBased(db: TComponent = nil): boolean;
function Connected(db: TComponent): boolean; overload;
function Connected: boolean; overload;
procedure SetConnected(db: TComponent; Value: boolean); overload;
procedure SetConnected(Value: boolean); overload;
procedure LsDBClearDB(db: TComponent = nil);
procedure LsDBClearTbl(db: TComponent; const tbl: string; lDropTbl: boolean = false);
function QryFind(const nmf: string; const cv: variant; q: TMulQuery = nil;
  PrComp: TQryFindCompProc = nil; FirstKey: boolean = true): boolean; overload;
function QryFind(const cv: variant; q: TMulQuery = nil;
  PrComp: TQryFindCompProc = nil; FirstKey: boolean = true): boolean; overload;
function QryFind(f: TField; const cv: variant; q: TMulQuery = nil; FirstKey: boolean = true): boolean; overload;
function NoGarbageCollect(db: TComponent; Value: boolean): boolean;
function GetDBName(db: TComponent = nil): string;
procedure SetDBName(db: TComponent; const Value: string);
function GetDBAliasName(db: TComponent): string;
function GetDBDriverName(db: TComponent): string;
function GetDBParams(db: TComponent = nil): TStrings;
function GetDBUserName(db: TComponent = nil): string;
procedure AddFrom(Proc: TPrimFldProc); overload;
function GetPrimFld(const ctbl: string; lsf: TMQFieldList; nf: longint): string; overload;
function GetPrimFld(const ctbl,cnmf,prim: string; var PrimSave: boolean): string; overload;
function GetPrimFld(const ctbl,cnmf: string): string; overload;
procedure InsFromTable(const tblSource,tblDest: string; const where: string = '');
function ArrTblAll: TArrStr;
function RegDt(const nm: string = fREGS): string;
function MulQueryVar(const v: variant): TMulQuery;
function MulQueryOwner(Sender: TDataSet): TMulQuery;
procedure CopyTableValueProc(Proc: TCopyTableValueProc; dFrom: TCustomDataFile; const FieldName: string;
  const cv: variant; var v: variant);
function StrUn(q: TMulQuery; n: longint): string; overload;
procedure RegsDelProc(const SDateReg: string); overload;
procedure RegsDelProc(f: TField); overload;

implementation

uses Windows,Forms,DBTables,BDE,Variants,IBHeader,StrUtils,pFIBQuery,FIBDataSet,pFIBProps,
  FStat;

const
  DBTextLastVers = 3;
  cDlm=#30; lDlm=Length(cDlm);

type
	TMQQuery = class(TQuery)
  protected
		procedure InitFieldDefs; override;
  end;

  PTblInfo = ^TTblInfo;
  TTblInfo = record
    LsFld: TMQFieldList;
    LsMax: TStringList;
    qIns: TMulQuery;
  end;

  PDBInfo = ^TDBInfo;
  TDBInfo = record
    db: TComponent;
    LsTbl: TStringList;
    aTbl: array of TTblInfo;
    nTbl: longint;
  end;

var ListDrv,LsTablesFreeHandle: TStringList;
	CurrLine:smallint;
  fl_mess: boolean = false;
  LastExecSQL: string;
  MsgMaxFld: boolean = true;
  aPrimFldProc: array of TPrimFldProc;
  LsDB: TIntegerList;

{function CurQryOpen;
begin
  AddStack('MulQry.CurQryOpen');
  if InRange(n,low(aQry),high(aQry)) then result:=aQry[n] else result:=nil;
  DelStack;
end;}

function GetDriverName;
var db: TComponent;
	ost: longint;
begin
  ost:=AddStack('MulQry.GetDriverName');
  result:=drvINTRBASE;
  if FirstDataBase(Connection,db) then
    if db is TDatabase then with TDatabase(db) do 
      if empty(DriverName) then
        try
          result:=Session.GetAliasDriverName(IfThen(empty(AliasName),DatabaseName,AliasName));
        except
          on EDatabaseError do begin
            SetStack(ost);
          end;
        end
      else result:=DriverName;
  DelStack;
end;

// Находит DataBase по имени или первую
function FirstDataBase(Connection: TComponent = nil): TComponent;
var p: PPswdPrm;
begin
	AddStack('MulQry.FirstDataBase');
  result:=Connection;
  if not Assigned(result) then begin
    if IsPswdPrm(p) then result:=p.DBMain;
    if not Assigned(result) then if Session.DataBaseCount>0 then result:=Session.DataBases[0];
  end;
  DelStack;
end;

function FirstDataBase(Connection: TComponent; var db: TComponent): boolean;
begin
  db:=FirstDataBase(Connection); result:=Assigned(db);
end;

procedure FirstDataBaseSelf(var Connection: TComponent);
begin
  Connection:=FirstDataBase(Connection);
end;

procedure PrCreateDrvInfo(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
var result: PDriverInfo;
  path,nm: string;
  j,lSQL,lCan: longint;
  flCan: boolean;
  a: TArrStr;
begin
  AddStack('mulqry.PrCreateDrvInfo');
  result:=PointerVar(av[0]); path:=av[1]; BoolVar(av[2])^:=false;
  try
    j:=LsArrDynamic(GetStrFile(path+sr.Name),a,CRLF);
  except
    on E: Exception do begin
      E.Message:='Не могу загрузить файл SQL-запросов:'+CRLF+path+sr.Name;
      raise
    end;
  end;
  flCan:=false; lCan:=Length(result.aCan); SetLength(result.aCan,lCan+j);
  lSQL:=Length(result.aSQL); SetLength(result.aSQL,lSQL+j+1); result.aSQL[lSQL+j]:=UnDelim+'END_'+sr.Name;
  for j:=0 to j-1 do begin
    result.aSQL[lSQL]:=a[j]; Inc(lSQL); nm:=TrimUpper(a[j]);
    if nm=UnDelim+'CAPABILITIES' then flCan:=true
    else if AnsiStartsStr(UnDelim,nm) then flCan:=false
    else if flCan then begin
      result.aCan[lCan]:=nm; Inc(lCan);
    end;
  end;
  SetLength(result.aCan,lCan); QuickSort(result.aCan);
  DelStack;
end;

function CreateDrvInfo;
var nm: string;
  fl: boolean;
begin
	AddStack('MulQry.CreateDrvInfo');
  nm:=nm1+'.SQ*'; New(result); result.ListName:=SortStrListCreate;
  fl:=true; MaskFilesProc(nm,PrCreateDrvInfo,[longint(result),ExtractFilePath(nm1),longint(@fl)]);
  if fl then raise EDatabaseError.Create('Не найдены файлы SQL-запросов:'+CRLF+nm);
  DelStack;
end;

procedure ClearDrvInfo;
begin
	AddStack('MulQry.ClearDrvInfo');
  pd.ListName.Free; Dispose(pd);
  DelStack;
end;

function GetDrvInfo;
var k: longint;
	s,nm: string;
  db: TComponent;
begin
	AddStack('MulQry.GetDrvInfo');
	if Sender is TMulQuery then with TMulQuery(Sender) do begin
    db:=FirstDataBase(Connection); nm:=FGetDriverName;
  end
  else if IsClass(Sender,TComponent,pointer(db)) then nm:=GetDriverName(db) else nm:=nmDrv;
  if not PointerObjFindAdd(SortStrListCreate(ListDrv),nm,k,pointer(result)) then begin
    s:=ExeDir;
    if Assigned(db) then if csDesigning in db.ComponentState then s:='';
    result:=CreateDrvInfo(s+nm); ListDrv.Objects[k]:=Pointer(result);
  end;
  DelStack;
end;

function DBDrvCan;
begin
	AddStack('MulQry.DBDrvCan');
	result:=QuickFind(Index,GetDrvInfo(DBMain).aCan);
  DelStack;
end;

procedure LsDBTblInfoDispose(p: PDBInfo; j: longint);
var pt: PTblInfo;
begin
  AddStack('MulQry.LsDBTblInfoDispose');
  if IntObj(p.LsTbl,j,j) then begin
    pt:=@p.aTbl[j]; pt.LsFld.Free; pt.LsMax.Free; pt.qIns.Free;
  end;
  DelStack;
end;

procedure FLsDBClearDB(i: longint; lFree: boolean = true);
var p: PDBInfo;
  j: longint;
begin
  AddStack('MulQry.FLsDBClearDB');
  p:=LsDB.PointerObj(i);
  if Assigned(p.LsTbl) then begin
    for j:=0 to p.LsTbl.Count-1 do LsDBTblInfoDispose(p,j);
    FreeAndNil(p.LsTbl); p.nTbl:=0;
  end;
  if lFree then Dispose(p);
  DelStack;
end;

function LsDBFind(db: TComponent; var i: longint): boolean; overload;
begin
  AddStack('MulQry.LsDBFind');
  if Assigned(LsDB) and Assigned(db) then begin
    i:=LsDB.IndexOf(db.Tag);
    if (i<0) or (PDBInfo(LsDB.Objects[i]).db<>db) then begin
      i:=0;
      while i<LsDB.Count do
        if PDBInfo(LsDB.Objects[i]).db=db then break else Inc(i);
      if i=LsDB.Count then i:=-1;
    end;
    result := i>=0;
  end
  else result:=false;
  DelStack;
end;

function LsDBFind(db: TComponent; var p: PDBInfo): boolean; overload;
var i: longint;
begin
  result:=LsDBFind(db,i);
  if result then p:=LsDB.PointerObj(i);
end;

procedure LsDBClearDB;
var i: longint;
begin
  AddStack('MulQry.LsDBClearDB');
  if LsDBFind(FirstDataBase(db),i) then FLsDBClearDB(i,false);
  DelStack;
end;

procedure LsDBClearTbl;
var p: PDBInfo;
  i: longint;
begin
  AddStack('MulQry.LsDBClearTbl');
  if LsDBFind(db,p) then if Assigned(p.LsTbl) then if p.LsTbl.Find(tbl,i) then begin
    LsDBTblInfoDispose(p,i); p.LsTbl.Objects[i]:=nil;
  end;
  DelStack;
end;

procedure FGetTableNames(db: TComponent; ls: TStringList);
begin
  AddStack('MulQry.FGetTableNames');
  if db is TIBDatabase
  then TIBDatabase(db).GetTableNames(ls,false)
  else TDatabase(db).GetTableNames(ls);
  DelStack;
end;

function LsDBTblLoad(p: PDBInfo): boolean;
begin
  AddStack('MulQry.LsDBTblLoad');
  result := not Assigned(p.LsTbl);
  if result then begin
    p.LsTbl:=SortStrListCreate; SetLength(p.aTbl,10); p.nTbl:=0; FGetTableNames(p.db,p.LsTbl);
  end;
  DelStack;
end;

function IsTable(db: TComponent; const TableName: string): boolean;
var ls: TStringList;
  p: PDBInfo;
begin
	AddStack('MulQry.IsTable');
  FirstDataBaseSelf(db);
  if LsDBFind(db,p) then begin
    LsDBTblLoad(p); result := p.LsTbl.IndexOf(TableName)>=0;
  end
  else begin
    ls:=TStringList.Create;
    try
      if db is TIBDatabase then begin
        TIBDatabase(db).GetTableNames(ls,false); result := ls.IndexOf(TableName)>=0;
      end
      else begin
        Session.GetTableNames(TDatabase(db).DatabaseName,TableName,false,false,ls); result := ls.Count>0;
      end;
    finally
      ls.Free;
    end;
  end;
  DelStack;
end;

function IsTable(const TableName: string): boolean;
begin
  result:=IsTable(nil,TableName);
end;

function DBFldValue;
var f: TField;
	path: string;
  i: longint;
begin
  AddStack('MulQry.DBFldValue');
  result:=false;
  if not IsSQLBased(db) then begin
  	path:=CorrDir(TDatabase(db).Params.Values['PATH']);
  	if FileExists(path+TableName+DBTextExt)
    then with TDatabaseText.CreatePrm(path,TableName) do
      try
      	i:=FieldIndex(cFieldName); result := i>=0;
        if result then res:=Fields[i].Value;
      finally
        Free;
      end;
  end;
  if not result then
    if IsTable(db,TableName) then with TMulQuery.CreateConnection(Application.MainForm,db) do
      try
        PartSelect(TableName,[]); result:=FindField(cFieldName,f);
        if result then res:=f.Value;
        Close;
      finally
        Free;
      end;
  DelStack;
end;

function LsCopy(lsFrom,lsTo: TStringList): boolean;
var oSort: boolean;
begin
  AddStack('MulQry.LsCopy');
  result:=Assigned(lsFrom);
  if result then begin
    oSort:=lsTo.Sorted; lsTo.Sorted:=false; lsTo.Text:=lsFrom.Text; lsTo.Sorted:=oSort;
  end;
  DelStack;
end;

procedure GetTableNames(db: TComponent; ls: TStringList);
begin
  AddStack('MulQry.GetTableNames');
  FirstDataBaseSelf(db);
  if not LsCopy(GetTableList(db),ls) then FGetTableNames(db,ls);
  DelStack;
end;

procedure GetTableNames(ls: TStringList);
begin
  GetTableNames(nil,ls);
end;

function GetTableList;
var p: PDBInfo;
begin
  AddStack('MulQry.GetTableList');
  FirstDataBaseSelf(db);
  if LsDBFind(db,p) then begin
    LsDBTblLoad(p); result:=p.LsTbl;
  end
  else result:=nil;
  DelStack;
end;

procedure GetFieldNames(db: TComponent; const tbl: string; ls: TStringList);
begin
  AddStack('MulQry.GetFieldNames');
  FirstDataBaseSelf(db);
  if not LsCopy(GetFieldList(db,tbl),ls) then
    if db is TIBDatabase
    then TIBDatabase(db).GetFieldNames(tbl,ls)
    else TDatabase(db).GetFieldNames(tbl,ls);
  DelStack;
end;

procedure GetFieldNames(const tbl: string; ls: TStringList);
begin
  GetFieldNames(nil,tbl,ls);
end;

function TblInfo(p: PDBInfo; i: longint): PTblInfo;
var n: longint;
begin
  AddStack('MulQry.TblInfo');
  if IntObj(p.LsTbl,i,n) then result:=@p.aTbl[n]
  else begin
    if Length(p.aTbl)=p.nTbl then SetLength(p.aTbl,p.nTbl shl 1);
    result:=@p.aTbl[p.nTbl]; Inc(p.nTbl); p.LsTbl.Objects[i]:=pointer(p.nTbl); ZeroMemory(result,SizeOf(result^));
  end;
  DelStack;
end;

function TblInfoCreateFld(db: TComponent; const tbl: string; var pt: PTblInfo): boolean;
var j,j1,ost: longint;
  p: PDBInfo;
  fl,lSetDbs: boolean;
  Cursor: HDBICur;
  Desc: FLDDesc;
  s,t,f,tf: string;
  tp: char;
  fi: PMQFieldInfo;
begin
  ost:=AddStack('MulQry.TblInfoCreateFld');
  result:=false;
  if LsDBFind(db,p) then begin
    LsDBTblLoad(p);
    if p.LsTbl.Find(tbl,j) then begin
      result:=true; pt:=TblInfo(p,j);
      if not Assigned(pt.LsFld) then begin
        tp:=#0;
        if db is TIBDatabase then with TpFIBQuery.Create(nil) do begin
          fl:=false;
          try
            GoToFirstRecordOnExecute:=false; Database:=pointer(db); fl:=not Transaction.Active;
            if fl then Transaction.StartTransaction;
            SQL.Text:='select R.RDB$RELATION_NAME,R.RDB$FIELD_NAME,RDB$FIELD_TYPE,RDB$FIELD_LENGTH,R.RDB$NULL_FLAG'
              +' from RDB$RELATION_FIELDS R, RDB$FIELDS F'
              +' where R.RDB$SYSTEM_FLAG = 0'+sAND+'R.RDB$FIELD_SOURCE=F.RDB$FIELD_NAME'
              +' order by R.RDB$RELATION_NAME';
            Prepare; ExecQuery; j1:=0; pt:=TblInfo(p,j1); pt.LsFld:=TMQFieldList.Create;
            while (not EOF) and (Next<>nil) do begin
              if TrimUpper(p.LsTbl[j1])<>TrimUpper(Current[0].AsString) then begin
                Inc(j1); pt:=TblInfo(p,j1); pt.LsFld:=TMQFieldList.Create;
              end;
              fi:=pt.LsFld.AddObj(TrimRight(Current[1].AsString));
              fi.Prim:=''; fi.KeyOrd:=0;
              fi.DataType:=TMQFieldList.IBDataType(Current[2].AsInteger);
              fi.Size:=Word(Current[3].AsInteger);
              if empty(Current[4].Value) then fi.Options:=[] else fi.Options:=[mqfNotNull];
            end;
            for lSetDbs:=false to true do with aDbsTbl[lSetDbs] do
              if IsField(db,dbs,'PRIM') then begin
                Close;
                SQL.Text:='select '+fDbsTABLE+','+fDbsFIELD+',PRIM,FLD_TYPE,'
                  +IfThen(IsField(db,dbs,'KEYORD'),'KEYORD','0')+' from '+dbs
                  +' order by '+fDbsTABLE+','+fDbsFIELD+','+fDbsVERS;
                Prepare; ExecQuery; t:=''; tf:=''; fi:=nil;
                while (not EOF) and (Next<>nil) do begin
                  s:=TrimRight(Current[0].AsString);
                  if s<>t then begin
                    t:=s;
                    if p.LsTbl.Find(t,j1) then pt:=TblInfo(p,j1) else pt:=nil;
                  end;
                  f:=TrimRight(Current[1].AsString); IncD(s,'.'+f);
                  if s<>tf then begin
                    tf:=s;
                    if Assigned(fi) and (tp='L') then Include(fi.Options,mqfBool);
                  end;
                  if Assigned(pt) then fi:=pt.LsFld.Fields(f) else fi:=nil;
                  if Assigned(fi) then begin
                    s:=TrimRight(Current[2].AsString);
                    if s<>'' then fi.Prim:=s;
                    j1:=Current[4].AsInteger;
                    if j1<>0 then fi.KeyOrd:=j1;
                  end;
                  tp:=StrToChar(Current[3].AsString);
                end;
                if Assigned(fi) and (tp='L') then Include(fi.Options,mqfBool);
              end;
          finally
            if fl then Transaction.Commit;
            Free;
          end
        end
        else with TDatabase(db) do begin
          pt.LsFld:=TMQFieldList.Create;
          try
            Check(DbiOpenFieldList(Handle,PChar(tbl),'',False,Cursor)); fl:=true;
          except
            on EDatabaseError do begin
              SetStack(ost);
              fl:=false;
            end;
          end;
          if fl then begin
            try
              while DbiGetNextRecord(Cursor,dbiNOLOCK,@Desc,nil)=0 do with Desc do begin
                NativeToAnsi(Locale,szName,t); fi:=pt.LsFld.AddObj(t);
                case iFldType of
                  fldINT16,fldINT32,fldUINT16,fldUINT32,fldPDXSHORT,fldPDXLONG,fldPDXAUTOINC,
                  fldDBLONG,fldDBAUTOINC:
                    fi.DataType:=ftInteger;
                  fldBOOL,fldPDXBOOL,fldDBBOOL:
                    fi.DataType:=ftBoolean;
                  fldFLOAT,fldBCD,fldFLOATIEEE,fldPDXNUM,fldPDXMONEY,fldPDXBCD,
                  fldDBNUM,fldDBFLOAT,fldDBDOUBLE:
                    fi.DataType:=ftFloat;
                  fldDATE,fldTIME,fldTIMESTAMP,fldPDXDATE,fldPDXTIME,fldPDXDATETIME,
                  fldDBDATE,fldDBDATETIME:
                    fi.DataType:=ftDate;
                  fldBLOB,fldPDXMEMO,fldPDXBINARYBLOB,fldPDXFMTMEMO,fldPDXOLEBLOB,
                  fldPDXGRAPHIC,fldDBMEMO,fldDBOLEBLOB,fldDBBINARY:
                    fi.DataType:=ftBlob;
                else fi.DataType:=ftString;
                end;
                fi.Prim:=''; fi.KeyOrd:=0; fi.Size:=Word(iUnits1);
                if efldvVchk=fldvHASCHECKS then fi.Options:=[mqfNotNull] else fi.Options:=[];
              end;
            finally
              DbiCloseCursor(Cursor);
            end;
            t:=AnsiUpperCase(tbl);
            for lSetDbs:=false to true do if t=aDbsTbl[lSetDbs].dbs then begin
              fl:=false; break;
            end;
            if fl then for lSetDbs:=false to true do with aDbsTbl[lSetDbs] do
              if IsField(db,dbs,'PRIM') then with TMulQuery.CreateConnection(Application.MainForm,db) do
                try
                  PartSelect(dbs,[fDbsFIELD,'PRIM','FLD_TYPE',IfThen(MulQry.IsField(db,dbs,'KEYORD'),'KEYORD','0')],
                    fDbsTABLE+'='+QQs(AnsiLowerCase(tbl)),GetList([fDbsFIELD,fDbsVERS]));
                  while not Eof do begin
                    f:=TrimRight(Fields[0].AsString); fi:=pt.LsFld.Fields(f);
                    while not Eof and (TrimRight(Fields[0].AsString)=f) do begin
                      if Assigned(fi) then begin
                        s:=TrimRight(Fields[1].AsString);
                        if s<>'' then fi.Prim:=s;
                        j1:=Fields[3].AsInteger;
                        if j1<>0 then fi.KeyOrd:=j1;
                        tp:=StrToChar(Fields[2].AsString);
                      end;
                      Next;
                    end;
                    if Assigned(fi) and (tp='L') then Include(fi.Options,mqfBool);
                  end;
                finally
                  Free;
                end;
          end;
        end;
        pt:=TblInfo(p,j);
      end;
    end;
  end;
  DelStack;
end;

function GetFieldList(db: TComponent; const tbl: string): TMQFieldList;
begin
  if not GetFieldList(db,tbl,result) then result:=nil;
end;

function GetFieldList(const tbl: string): TMQFieldList;
begin
  result:=GetFieldList(nil,tbl);
end;

function GetFieldList(db: TComponent; const tbl: string; var ls: TMQFieldList): boolean;
var pt: PTblInfo;
begin
  AddStack('MulQry.GetFieldList');
  FirstDataBaseSelf(db); result:=TblInfoCreateFld(db,tbl,pt);
  if result then ls:=pt.LsFld;
  DelStack;
end;

function GetFieldList(const tbl: string; var ls: TMQFieldList): boolean;
begin
  result:=GetFieldList(nil,tbl,ls);
end;

function IsField(db: TComponent; const tbl,nmf: string): boolean;
var ls: TMQFieldList;
begin
  if GetFieldList(db,tbl,ls) then result:=ls.IsField(nmf) else result:=false;
end;

function IsField(const tbl,nmf: string): boolean;
begin
  result:=IsField(nil,tbl,nmf);
end;

function GetFieldInfo(db: TComponent; const tbl,nmf: string; var fi: PMQFieldInfo): boolean;
var ls: TMQFieldList;
begin
  AddStack('MulQry.GetFieldInfo');
  result:=GetFieldList(db,tbl,ls);
  if result then result:=ls.Fields(nmf,fi) else fi:=nil;
  DelStack;
end;

function GetFieldInfo(const tbl,nmf: string; var fi: PMQFieldInfo): boolean;
begin
  result:=GetFieldInfo(nil,tbl,nmf,fi);
end;

function GetFieldInfo(const tbl,nmf: string): PMQFieldInfo;
begin
  GetFieldInfo(tbl,nmf,result);
end;

procedure GetStoredProcNames(db: TComponent; ls: TStringList);
var fl: boolean;
begin
  AddStack('MulQry.GetStoredProcNames');
  if db is TIBDatabase then with TpFIBQuery.Create(nil) do begin
    fl:=false;
    try
      GoToFirstRecordOnExecute:=false; Database:=pointer(db); fl:=not Transaction.Active;
      if fl then Transaction.StartTransaction;
      SQL.Text:='select RDB$PROCEDURE_NAME from RDB$PROCEDURES';
      Prepare; ExecQuery;
      while (not EOF) and (Next<>nil) do ls.Add(TrimRight(Current[0].AsString));
    finally
      if fl then Transaction.Commit;
      Free;
    end
  end
  else Session.GetStoredProcNames(TDatabase(db).DatabaseName,ls);
  DelStack;
end;

function IsSQLBased;
begin
  AddStack('MulQry.IsSQLBased');
  FirstDataBaseSelf(db);
  if db is TDatabase then result:=TDatabase(db).IsSQLBased else result:=true;
  DelStack;
end;

function Connected(db: TComponent): boolean;
begin
  AddStack('MulQry.Connected');
  if Assigned(db) then
    if db is TIBDatabase
    then result:=TIBDatabase(db).Connected
    else result:=TCustomConnection(db).Connected
  else result:=false;
  DelStack;
end;

function Connected: boolean;
begin
  result:=Connected(FirstDataBase);
end;

procedure SetConnected(db: TComponent; Value: boolean);
var ost,i: longint;
  p: PDBInfo;
  path: string;
  a: TArrSQLPath;
begin
	ost:=AddStack('MulQry.SetConnected');
	if Assigned(db) then
		if Connected(db)<>Value then begin
      if not Value then CloseDataSets(db);
      //try
        try
          if db is TIBDatabase
          then TIBDatabase(db).Connected:=Value
          else TCustomConnection(db).Connected:=Value;
        except
          if Value then begin
            if GetDBDriverName(db)<>drvINTRBASE then raise;
            path:=GetDBName(db);
            if IsSQLLocalPath(path,@a) then raise;
            if not((a.IP='127.0.0.1') and (a.Port='')) then raise;
            SetStack(ost);
            SetDBName(db,a.Drv+DriveDelim+a.Path);
            if db is TIBDatabase
            then TIBDatabase(db).Connected:=true
            else TCustomConnection(db).Connected:=true;
          end
          else raise
        end;
      {except
        on E:Exception do begin
          if Value and (db is TDatabase) then E.Message:='Необходима установка дополнительной программы BDE';
          raise
        end;
        {if Value then begin
          MsgDlg('Необходима установка дополнительной программы BDE'); Application.Terminate;
        end
        else raise
      end;}
      if Value then begin
        if TIntegerList.Create(LsDB,[ilsSorted]).Count=0 then i:=0 else i:=LsDB[LsDB.Count-1];
        db.Tag:=i+1; New(p); LsDB.Add(db.Tag,pointer(p)); p.db:=db; p.LsTbl:=nil;
      end
      else if LsDBFind(db,i) then begin
        FLsDBClearDB(i); LsDB.Delete(i);
      end;
    end;
  DelStack;
end;

procedure SetConnected(Value: boolean);
begin
  SetConnected(FirstDataBase,Value);
end;

function QryFindComp(q: TMulQuery; const v: variant): TValueSign;
begin
  AddStack('MulQry.QryFindComp');
  result:=CompSign(FieldVar(v[0]).Value,v[1]);
  DelStack;
end;

function QryFind(const nmf: string; const cv: variant; q: TMulQuery = nil;
  PrComp: TQryFindCompProc = nil; FirstKey: boolean = true): boolean;
var f: TField;
  bm: TBookMark;
  v: variant;
  fl: TValueSign;
begin
  AddStack('MulQry.QryFind');
  if TMulQuery.QryCur(q).IsRecords then begin
    if Assigned(PrComp) then v:=cv
    else begin
      if (nmf='') or not q.FindField(nmf,f) then f:=q.Fields[0];
      v:=VarArrayOf([LongInt(f),cv]); PrComp:=QryFindComp;
    end;
    fl:=PrComp(q,v);
    if fl=0 then result:=true
    else begin
      if fl=-1 then begin
        FirstKey:=false; q.Next;
        while not q.Eof do
          if PrComp(q,v)=-1 then q.Next else break;
      end
      else if fl=1 then begin
        q.Prior;
        while not q.Bof do
          if PrComp(q,v)=1 then q.Prior else break;
        if PrComp(q,v)=-1 then q.Next;
      end;
      result := PrComp(q,v)=0;
    end;
    if result and FirstKey then
      while not q.Bof do
        if PrComp(q,v)=0 then q.Prior
        else begin
          q.Next; break;
        end;
    if result and (q.Eof or q.Bof) then begin
      bm:=q.GetBookMark;
      try
        q.GotoBookMark(bm);
      finally
        q.FreeBookMark(bm);
      end;
    end;
  end
  else result:=false;
  DelStack;
end;

function QryFind(const cv: variant; q: TMulQuery = nil;
  PrComp: TQryFindCompProc = nil; FirstKey: boolean = true): boolean;
begin
  result:=QryFind('',cv,q,PrComp,FirstKey);
end;

function QryFind(f: TField; const cv: variant; q: TMulQuery = nil; FirstKey: boolean = true): boolean;
begin
  result:=QryFind('',VarArrayOf([LongInt(f),cv]),q,QryFindComp,FirstKey);
end;

function NoGarbageCollect;
var oCon: boolean;
  s: string;
begin
  AddStack('MulQry.NoGarbageCollect');
  result:=false;
  if db is TIBDatabase then with TIBDatabase(db) do begin
    oCon:=MulQry.Connected(db); SetConnected(db,false);
    {s:=DBParamByDPB[isc_dpb_no_garbage_collect];
    if s<>'' then result:=StrToBool(s);}
    //DBParamByDPB[isc_dpb_no_garbage_collect]:=BoolToStr(Value,true);
    {if Value then begin
      DBParamByDPB[isc_dpb_garbage_collect]:='';
      //DBParamByDPB[isc_dpb_no_garbage_collect]:=BoolToStr(true,true);
    end
    else begin
      DBParamByDPB[isc_dpb_garbage_collect]:=BoolToStr(true,true);
      //DBParamByDPB[isc_dpb_no_garbage_collect]:='';
    end;}
    s:=DBParamByDPB[isc_dpb_garbage_collect];
    if s<>'' then result:=not StrToBool(s);
    //DBParamByDPB[isc_dpb_garbage_collect]:=IfThen(not Value,BoolToStr(true,true));
    DBParamByDPB[isc_dpb_garbage_collect]:=BoolToStr(not Value,true);
    SetConnected(db,oCon);
  end;
  DelStack;
end;

function GetDBDriverName;
begin
  AddStack('MulQry.GetDBDriverName');
  if db is TIBDatabase then result:=drvINTRBASE else result:=TDatabase(db).DriverName;
  DelStack;
end;

function GetDBName;
begin
  AddStack('MulQry.GetDBName');
  FirstDataBaseSelf(db);
  if db is TIBDatabase
  then result:=TIBDatabase(db).DatabaseName
  else result:=TDatabase(db).Params.Values[ibpServerName];
  DelStack;
end;

procedure SetDBName;
begin
  AddStack('MulQry.SetDBName');
  if db is TIBDatabase
  then TIBDatabase(db).DatabaseName:=Value
  else TDatabase(db).Params.Values[ibpServerName]:=Value;
  DelStack;
end;

function GetDBAliasName;
begin
  AddStack('MulQry.GetDBAliasName');
  if db is TIBDatabase then result:='' else result:=TDatabase(db).AliasName;
  DelStack;
end;

function GetDBParams;
begin
  AddStack('MulQry.GetDBParams');
  FirstDataBaseSelf(db);
  if db is TIBDatabase then result:=TIBDatabase(db).DBParams else result:=TDatabase(db).Params;
  DelStack;
end;

function GetDBUserName;
begin
  AddStack('MulQry.GetDBUserName');
  FirstDataBaseSelf(db);
  if db is TIBDatabase then result:=StrTran(ibpUserName,' ','_') else result:=ibpUserName;
  DelStack;
end;

procedure AddFrom(Proc: TPrimFldProc);
var l: longint;
begin
  AddStack('MulQry.AddFrom(TPrimFldProc)');
  l:=Length(aPrimFldProc); SetLength(aPrimFldProc,l+1); aPrimFldProc[l]:=Proc;
  DelStack;
end;

function GetPrimFld(const ctbl: string; lsf: TMQFieldList; nf: longint): string;
var oprim: string;
  PrimSave: boolean;
  fi: PMQFieldInfo;
begin
  AddStack('MulQry.GetPrimFld(ls)');
  if UpperCase(RightStr(ctbl,lDBInsPostfix))=DBInsPostfix then
    if lsf[nf]=fRECNO_I
    then result:='номер записи для пользователя'
    else result:=GetPrimFld(LeftStr(ctbl,Length(ctbl)-lDBInsPostfix),lsf[nf])
  else begin
    if lsf.Fields(nf,fi) then begin
      oprim:=fi.Prim; PrimSave:=true; result:=GetPrimFld(ctbl,lsf[nf],oprim,PrimSave);
      if (oprim='') and InRange(nf,0,lsf.Count-1) and PrimSave then fi.Prim:=result;
    end
    else result:='';
  end;
  DelStack;
end;

function GetPrimFld(const ctbl,cnmf,prim: string; var PrimSave: boolean): string;
var i: longint;
  tbl,nmf: string;
begin
  AddStack('MulQry.GetPrimFld(proc)');
  result:=prim;
  if result='' then begin
    nmf:=UpperCase(cnmf);
    if nmf=fRECNO then result:='номер записи'
    else begin
      tbl:=UpperCase(ctbl);
      for i:=high(aPrimFldProc) downto low(aPrimFldProc) do begin
        aPrimFldProc[i](tbl,nmf,result,PrimSave);
        if result<>'' then break;
      end;
    end;
  end;
  TransPrimSelf(result);
  DelStack;
end;

function GetPrimFld(const ctbl,cnmf: string): string;
var lsf: TMQFieldList;
  i: longint;
  PrimSave: boolean;
begin
  AddStack('MulQry.GetPrimFld(f)');
  lsf:=GetFieldList(ctbl);
  if Assigned(lsf) then
    if lsf.Find(cnmf,i) then result:=GetPrimFld(ctbl,lsf,i) else result:=GetPrimFld(ctbl,cnmf,'',PrimSave)
  else result:='';
  DelStack;
end;

procedure InsFromTable;
var a: TArrVar;
  ost: longint;
  ls: TStringList;
begin
	ost:=AddStack('MulQry.InsFromTable');
  with GetQuery do begin
    ls:=MulQry.GetFieldList(tblDest); CopyFrom(a,ls);
    Arg[sSELECT]:=PartSelect(tblSource,a,where,'','',false); Arg[sTABLE]:=tblDest;
    try
      ExecInsFromSel;
    except
      on EDatabaseError do SetStack(ost);
    end;
    FreeQuery;
  end;
  DelStack;
end;

function ArrTblAll;
begin
  AddStack('MulQry.ArrTblAll');
  LsArrDynamic(TrimRight(GetTableList.Text),result,CRLF,lsaSetLen);
  DelStack;
end;

function RegDt;
begin
	AddStack('MulQry.RegDt');
  result:=IfThen(not DBDrvCan('DateTime'),'C')+nm;
  DelStack;
end;

function MulQueryVar;
begin
  result:=PointerVar(v);
end;

function MulQueryOwner;
begin
  result:=PointerOwner(Sender);
end;

procedure CopyTableValueProc(Proc: TCopyTableValueProc; dFrom: TCustomDataFile; const FieldName: string;
  const cv: variant; var v: variant);
begin
  AddStack('mulqry.CopyTableValueProc');
  v:=cv;
  if Assigned(Proc) then Proc(dFrom,FieldName,v);
  DelStack;
end;

function StrUn(q: TMulQuery; n: longint): string;
begin
  AddStack('mulqry.StrUn');
  result:=StrUn(q.QryCur.Fields[n]);
  DelStack;
end;

procedure RegsDelProc(const SDateReg: string);
var i: longint;
begin
  AddStack('mulqry.RegsDelProc');
  for i:=low(aRegsDelProc) to high(aRegsDelProc) do aRegsDelProc[i](SDateReg);
  DelStack;
end;

procedure RegsDelProc(f: TField);
begin
  RegsDelProc(GetQuery.SQLDateTime(f.Value)); FreeQuery;
end;

{ TMQFieldList }
constructor TMQFieldList.Create;
begin
  AddStack('TMQFieldList.Create');
  Sorted:=true; SetLength(af,10);
  DelStack;
end;

function TMQFieldList.AddObj;
var n: longint;
begin
  AddStack('TMQFieldList.AddObj');
  if not IntObjFindAdd(Self,nmf,n) then if Length(af)=n then SetLength(af,n shl 1);
  result:=@af[n];
  DelStack;
end;

function TMQFieldList.Fields(const Index: variant): PMQFieldInfo;
var i: longint;
begin
  AddStack('TMQFieldList.Fields');
  if MyVarType(Index)=varString then i:=IndexOf(Index) else i:=Index;
  if InRange(i,0,Count-1) then result:=@af[IntObj(Self,i)] else result:=nil;
  DelStack;
end;

function TMQFieldList.Fields(const Index: variant; var fi: PMQFieldInfo): boolean;
begin
  fi:=Fields(Index); result:=Assigned(fi);
end;

function TMQFieldList.IsField;
begin
  result := IndexOf(NmFld)>=0;
end;

function TMQFieldList.IsFieldBool;
var fi: PMQFieldInfo;
begin
  AddStack('TMQFieldList.IsFieldBool');
  if Fields(nmf,fi) then result := mqfBool in fi.Options else result:=false;
  DelStack;
end;

procedure TMQFieldList.GetKeyOrd;
var i,j,k: longint;
begin
  AddStack('TMQFieldList.GetKeyOrd');
  SetLength(a,Count); SetMemory(@a[0],Length(a)*SizeOf(a[0])); j:=-1;
  for i:=0 to Count-1 do begin
    k:=Fields(i).KeyOrd-1;
    if InRange(k,low(a),high(a)) then begin
      a[k]:=i; MaxSelf(j,k);
    end;
  end;
  for i:=0 to j do if a[i]<0 then begin
    Dec(j);
    for k:=i to j do a[k]:=a[k+1];
  end;
  SetLength(a,j+1);
  DelStack;
end;

class function TMQFieldList.IBDataType;
begin
  AddStack('TMQFieldList.IBDataType');
  case tp of
    blr_short,blr_long,blr_int64: result:=ftInteger;
    blr_float,blr_double,blr_d_float: result:=ftFloat;
    blr_timestamp,blr_sql_date,blr_sql_time: result:=ftDate;
    blr_blob,blr_blob_id: result:=ftBlob;
  else result:=ftString;
  end;
  DelStack;
end;

{ TMQIndexList }
constructor TMQIndexList.Create;
var pa: PArrStr;
  procedure paNew(l: longint);
  begin
    AddStack('TMQIndexList.Create.paNew');
    if Length(ai)=Count then SetLength(ai,IfThen(Count=0,1,Count shl 1));
    pa:=@ai[Count]; SetLength(pa^,l);
    DelStack;
  end;
var l: longint;
	s: string;
	procedure IBAdd;
  begin
    AddStack('TMQIndexList.Create.IBAdd');
    if s<>'' then begin
    	SetLength(pa^,l); AddObject(s,pointer(Count));
    end;
    DelStack;
  end;
var fCursor: HDBICur;
  indexDesc: IDXDesc;
  i: longint;
  lsf: TStringList;
  sn: string;
  fl: boolean;
begin
	AddStack('TMQIndexList.Create');
  BeginUpdate;
  if db is TIBDatabase then with TpFIBQuery.Create(nil) do begin
    fl:=false;
    try
      GoToFirstRecordOnExecute:=false; Database:=pointer(db); fl:=not Transaction.Active;
		  if fl then Transaction.StartTransaction;
      SQL.Text:='select '+IfThen(lConstraint,'RDB$CONSTRAINT_NAME','RDB$INDEX_NAME')+',RDB$FIELD_NAME'
        +' from '+IfThen(lConstraint,'RDB$RELATION_CONSTRAINTS C,')+'RDB$INDICES I,RDB$INDEX_SEGMENTS S'
        +' where RDB$RELATION_NAME='+QQs(UpperCase(tbl))+sAND+'RDB$INDEX_NAME<>'+QQs
        +IfThen(lConstraint,
        sAND+'I.RDB$RELATION_NAME=C.RDB$RELATION_NAME'+sAND+'I.RDB$INDEX_NAME=C.RDB$INDEX_NAME')
        +sAND+'I.RDB$INDEX_NAME=S.RDB$INDEX_NAME order by RDB$INDEX_NAME,RDB$FIELD_POSITION';
      Prepare; ExecQuery; s:='';
      while (not EOF) and (Next<>nil) do begin
      	sn:=TrimRight(Current[0].AsString);
      	if sn<>s then begin
        	IBAdd; s:=sn; l:=0; paNew(100);
        end;
        pa^[l]:=TrimRight(Current[1].AsString); Inc(l);
      end;
      IBAdd;
    finally
    	if fl then Transaction.Commit;
      Free;
    end
  end
  else if not lConstraint then with TDatabase(db) do
    if DbiOpenIndexList(Handle,PChar(tbl),'',fCursor)=DBIERR_NONE then begin
    	lsf:=TStringList.Create;
      try
      	GetFieldNames(tbl,lsf);
        while DbiGetNextRecord(fCursor,dbiNoLock,@indexDesc,nil)=DBIERR_NONE do begin
        	paNew(indexDesc.iFldsInKey);
          for i:=0 to indexDesc.iFldsInKey-1 do pa^[i]:=lsf[indexDesc.aiKeyFld[i]-1];
          AddObject(string(indexDesc.szName),pointer(Count));
        end;
      finally
        DbiCloseCursor(fCursor); lsf.Free;
      end;
    end;
  Sorted:=true; EndUpdate;
  DelStack;
end;

function TMQIndexList.Indices;
var i: longint;
begin
  AddStack('TMQIndexList.Indices');
  if MyVarType(Index)=varString then i:=IndexOf(Index) else i:=Index;
  if InRange(i,0,Count-1) then result:=ai[IntObj(Self,i)] else result:=nil;
  DelStack;
end;

{ TMQQuery }
procedure TMQQuery.InitFieldDefs;
begin
	AddStack('TMQQuery.InitFieldDefs',Self);
  TMulQuery(Owner).FillSQL;
	inherited InitFieldDefs;
  DelStack;
end;

{ TIBQuery }
procedure TIBQuery.InitFieldDefs;
begin
	AddStack('TIBQuery.InitFieldDefs',Self);
  TMulQuery(Owner).FillSQL;
	inherited InitFieldDefs;
  DelStack;
end;

{ TMulQuery }
procedure TMulQuery.FchangeArg;
begin
	AddStack('TMulQuery.FchangeArg',Self);
	FActiveTry:=false;
	Active:=false;
  DelStack;
end;

constructor TMulQuery.Create;
begin
	AddStack('TMulQuery.Create',Self);
	inherited Create(AOwner);
	FMulPar:=TMulQueryMulPar.Create; FMulPar.OnChange:=FchangeArg; FRowsAffected:=-1;
  DelStack;
end;

constructor TMulQuery.CreateConnection(AOwner: TComponent = nil; AConnection: TComponent = nil);
begin
	AddStack('TMulQuery.CreateConnection',Self);
	Create(AOwner); Connection:=FirstDataBase(AConnection);
  DelStack;
end;

class function TMulQuery.CreateConnection(var Qry: TMulQuery; AOwner: TComponent; AConnection: TComponent): boolean;
begin
	AddStack('TMulQuery.CreateConnection(q)');
  result:=not Assigned(Qry);
  if result then Qry:=Create(AOwner);
  Qry.Connection:=FirstDataBase(AConnection);
  DelStack;
end;

class function TMulQuery.CreateNoActive(var Qry: TMulQuery; AOwner: TComponent; AConnection: TComponent = nil): boolean;
begin
	AddStack('TMulQuery.CreateNoActive');
  if CreateConnection(Qry,AOwner,AConnection) then result:=true else result:=not Qry.Active;
  DelStack;
end;

destructor TMulQuery.Destroy;
begin
	AddStack('TMulQuery.Destroy',Self);
  FMulPar.Free;
  if Active then DoAfterClose;
	inherited Destroy;
  DelStack;
end;

procedure TMulQuery.ConnectionDef;
begin
  AddStack('TMulQuery.ConnectionDef');
  if not Assigned(Connection) then Connection:=FirstDatabase;
  DelStack;
end;

class procedure TMulQuery.ClearSql;
var i: longint;
begin
	AddStack('TMulQuery.ClearSql');
	if Assigned(ListDrv) then begin
    for i:=0 to ListDrv.Count-1 do ClearDrvInfo(PointerObj(ListDrv,i));
    FreeAndNil(ListDrv);
  end;
  DelStack;
end;

procedure TMulQuery.SetMulPar;
begin
	AddStack('TMulQuery.SetMulPar',Self);
	if not MulPar.Equals(Value) then MulPar.Assign(Value);
  DelStack;
end;

procedure TMulQuery.SetConnection;
begin
  AddStack('TMulQuery.SetConnection',Self);
  if Value<>FConnection then begin
    if Assigned(Value) then begin
      if Assigned(DataSet) and ((Value is TIBDatabase) = (FConnection is TIBDatabase)) then DataSet.Close
      else begin
        FreeAndNil(DataSet);
        if Value is TIBDatabase then DataSet:=TIBQuery.Create(Self) else DataSet:=TMQQuery.Create(Self);
        Dataset.AfterClose:=qAfterClose; Dataset.AfterOpen:=qAfterOpen;
        Dataset.BeforeClose:=qBeforeClose; Dataset.BeforeOpen:=qBeforeOpen;
      end;
      if Value is TIBDatabase then with TIBQuery(DataSet) do begin
        Database:=pointer(Value);
        Options:=Options-[poRefreshAfterPost];
        Transaction:=Database.DefaultTransaction;
      end
      else TQuery(DataSet).Databasename:=TDatabase(Value).Databasename;
      //Value.FreeNotification(Self);
    end
    else FreeAndNil(DataSet);
    if Assigned(FDataSource) then FDataSource.DataSet:=DataSet;
    FConnection:=Value;
  end;
  DelStack;
end;

procedure TMulQuery.Notification;
begin
  AddStack('TMulQuery.Notification',Self);
	inherited Notification(AComponent,Operation);
  if (AComponent=FConnection) and (Operation=opRemove) then Connection:=nil;
  DelStack;
end;

function TMulQuery.GetArg;
begin
	AddStack('TMulQuery.GetArg',Self);
	result:=Mulpar.Values[Index];
  DelStack;
end;
procedure TMulQuery.SetArg;
var s:string;
begin
	AddStack('TMulQuery.SetArg',Self);
	s:=VarToS(v); Mulpar.Values[index]:=s;
  DelStack;
end;

procedure TMulQuery.IncArgAnd;
begin
  AddStack('TMulQuery.IncArgAnd',Self);
  Arg[Index]:=Arg[Index]+sAND+d2;
  DelStack;
end;

procedure TMulQuery.AddArgList;
var s:string;
begin
	AddStack('TMulQuery.AddArgList',Self);
	s:=MulPar.Values[Index];
	MulPar.Values[Index]:=IfThen(length(s)>0,s+cDlm)+VarToS(v);
  DelStack;
end;
procedure TMulQuery.AddArrayList;
begin
	AddStack('TMulQuery.AddArrayList',Self);
  DlmBetwSelf(MulPar,Index,GetList(aa),cDlm);
  DelStack;
end;
procedure TMulQuery.SetArrayList;
begin
	AddStack('TMulQuery.SetArrayList',Self);
	arg[index]:=''; AddArrayList(index,aa);
  DelStack;
end;

procedure TMulQuery.SetFpart;
begin
	AddStack('TMulQuery.SetFpart',Self);
	if name<>Fpart then begin
		FActiveTry:=false; Fpart:=name; Active:=false;
	end;
  DelStack;
end;

procedure TMulQuery.qAfterClose;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.qAfterClose',Self);{$ENDIF}
  DoAfterClose;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.qAfterOpen;
var bm: TBookMark;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.qAfterOpen',Self);{$ENDIF}
  if DataSet is TIBQuery then begin
    bm:=GetBookMark; Last; First; GotoBookMark(bm); FreeBookMark(bm);
  end;
  DoAfterOpen;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.qBeforeClose;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.qBeforeClose',Self);{$ENDIF}
  DoBeforeClose;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.qBeforeOpen;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.qBeforeOpen',Self);{$ENDIF}
  DoBeforeOpen;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.DoBeforeClose;
begin
	AddStack('TMulQuery.DoBeforeClose',Self);
  IfThenDataSet(FBeforeClose,DataSet);
  DelStack;
end;

function TMulQuery.GetActive;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.GetActive',Self);{$ENDIF}
  if Assigned(DataSet) then result:=DataSet.Active else result:=false;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.SetActive;
var a: TArrStr;
  i: longint;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.SetActive',Self);{$ENDIF}
  if Assigned(DataSet) then
    if Value<>DataSet.Active then begin
      if Value then begin
        FActiveTry:=false; FillSQL;
{if Pos('desc',Text)>0 then begin
  FActiveTry:=FActiveTry;
end;}
//addmsgfile(Trim(Text));
      end;
      DataSet.Active:=Value;
      if not Value and Assigned(LsTablesFreeHandle) then begin
        GetListArg(sTABLE,a);
        for i:=low(a) to high(a) do
          if LsTablesFreeHandle.IndexOf(a[i])>=0 then begin
            UnPrepare; break;
          end;
      end;
    end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.GetFiltered;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.GetFiltered',Self);{$ENDIF}
  result:=DataSet.Filtered;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.SetFiltered;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.SetFiltered',Self);{$ENDIF}
  DataSet.Filtered:=Value;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.SetFilterProc;
begin
  Filtered:=Value;
  if Value then OnFilterRecord:=Proc else OnFilterRecord:=nil;
end;

procedure TMulQuery.QryFio(const tbl: string = '');
var fio: TFio;
begin
  AddStack('TMulQuery.QryFio',Self);
  for fio:=low(aFio) to high(aFio) do AddArgList(sC_LIST,DlmBetween(tbl,aFio[fio].f,'.'));
  DelStack;
end;

function TMulQuery.QryFio(const clist: array of variant; const tbl: string = ''): string;
begin
  SetArrayList(sC_LIST,clist); QryFio(tbl); result:='';
end;

function TMulQuery.GetRequestLive;
begin
	AddStack('TMulQuery.GetRequestLive',Self);
  if DataSet is TIBQuery
    then result:=TIBQuery(DataSet).AutoUpdateOptions.AutoReWriteSqls
  else if DataSet is TQuery
    then result:=TQuery(DataSet).RequestLive
  else result:=true;
  DelStack;
end;

procedure TMulQuery.SetRequestLive;
begin
	AddStack('TMulQuery.SetRequestLive',Self);
  if RequestLive<>Value then
    if DataSet is TIBQuery then with TIBQuery(DataSet),AutoUpdateOptions do begin
      if Value then begin
        Options:=Options+[poProtectedEdit]; UpdateTableName:=Arg[sTABLE];
        InsertSQL.Clear; UpdateSQL.Clear; DeleteSQL.Clear; RefreshSQL.Clear;
      end
      else begin
        Commit; UpdateTableName:=''; Options:=Options-[poProtectedEdit];
      end;
      AutoReWriteSqls:=Value;
    end
    else if DataSet is TQuery then TQuery(DataSet).RequestLive:=Value;
  DelStack;
end;

// Для больших таблиц можно бежать только вперед
function TMulQuery.GetUniDirectional;
begin
  AddStack('TMulQuery.GetUniDirectional',Self);
  if DataSet is TIBQuery then result:=TIBQuery(DataSet).UniDirectional else result:=false;
  DelStack;
end;

procedure TMulQuery.SetUniDirectional;
begin
  AddStack('TMulQuery.SetUniDirectional',Self);
  if DataSet is TIBQuery then TIBQuery(DataSet).UniDirectional:=Value;
  DelStack;
end;

procedure TMulQuery.SetDataSource;
begin
	AddStack('TMulQuery.SetDataSource',Self);
  FDataSource:=Value; FDataSource.DataSet:=DataSet;
  DelStack;
end;

function TMulQuery.Fields;
begin
  {$IFDEF STACKALL}AddStack('TMulQuery.Fields',Self);{$ENDIF}
  result:=DataSet.Fields;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.ValueNum;
begin
  {$IFDEF STACKALL}AddStack('TMulQuery.ValueNum',Self);{$ENDIF}
  result:=DataSet.Fields[Index].Value;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.ValueName;
begin
  {$IFDEF STACKALL}AddStack('TMulQuery.ValueName',Self);{$ENDIF}
  result:=FindField(Name).Value;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.FieldName;
begin
  {$IFDEF STACKALL}AddStack('TMulQuery.FieldName',Self);{$ENDIF}
  result:=DataSet.Fields[Index].FieldName;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.DataType;
begin
  {$IFDEF STACKALL}AddStack('TMulQuery.DataType',Self);{$ENDIF}
  result:=DataSet.Fields[Index].DataType;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.FieldLen;
begin
  {$IFDEF STACKALL}AddStack('TMulQuery.FieldLen',Self);{$ENDIF}
  result:=DataSet.Fields[Index].Size;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.NotNull;
var fi: PMQFIeldInfo;
begin
  {$IFDEF STACKALL}AddStack('TMulQuery.NotNull',Self);{$ENDIF}
  if TMQFieldList(p).Fields(DataSet.Fields[Index].FieldName,fi)
  then result := mqfNotNull in fi.Options
  else result:=false;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.RowsAffected;
begin
  {$IFDEF STACKALL}AddStack('TMulQuery.RowsAffected',Self);{$ENDIF}
  if FRowsAffected<0 then
    if DataSet is TIBQuery
    then result:=TIBQuery(DataSet).QSelect.RowsAffected
    else result:=TQuery(DataSet).RowsAffected
  else result:=FRowsAffected;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.qRecno;
begin
  result:=RecnoWhere(FieldZN(fRECNO),lEq);
end;

function TMulQuery.GetAfterScroll;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.GetAfterScroll',Self);{$ENDIF}
  result:=DataSet.AfterScroll;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.SetAfterScroll;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.SetAfterScroll',Self);{$ENDIF}
  DataSet.AfterScroll:=Value;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.GetOnCalcFields;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.GetOnCalcFields',Self);{$ENDIF}
  result:=DataSet.OnCalcFields;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.SetOnCalcFields;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.SetOnCalcFields',Self);{$ENDIF}
  DataSet.OnCalcFields:=Value;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.GetOnFilterRecord;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.GetOnFilterRecord',Self);{$ENDIF}
  result:=DataSet.OnFilterRecord;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.SetOnFilterRecord;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.SetOnFilterRecord',Self);{$ENDIF}
  DataSet.OnFilterRecord:=Value;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.GetFieldDefs;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.GetFieldDefs',Self);{$ENDIF}
  result:=DataSet.FieldDefs;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.SetFieldDefs;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.SetFieldDefs',Self);{$ENDIF}
  DataSet.FieldDefs:=Value;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.DisableControls;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.DisableControls',Self);{$ENDIF}
  if FDisableCount=0 then begin
    oAfterScroll:=DataSet.AfterScroll; DataSet.AfterScroll:=nil; DoEnableControls(false);
  end;
  Inc(FDisableCount); DataSet.DisableControls;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.EnableControls;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.EnableControls',Self);{$ENDIF}
  Dec(FDisableCount);
  if FDisableCount=0 then begin
    DoEnableControls(true); DataSet.AfterScroll:=oAfterScroll; IfThenDataSet(oAfterScroll,DataSet);
  end;
  DataSet.EnableControls;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.DoEnableControls;
begin
  {$IFDEF STACKALL}AddStack('TMulQuery.DoEnableControls',Self);{$ENDIF}
  if Assigned(OnEnableControls) then OnEnableControls(Value,PrmEnabledControls);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.First;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.First',Self);{$ENDIF}
  DataSet.First;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.Last;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.Last',Self);{$ENDIF}
  DataSet.Last;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.Next;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.Next',Self);{$ENDIF}
  DataSet.Next;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.Prior;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.Prior',Self);{$ENDIF}
  DataSet.Prior;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.MoveBy;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.MoveBy',Self);{$ENDIF}
  result:=DataSet.MoveBy(Distance);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.Eof;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.Eof',Self);{$ENDIF}
  result:=DataSet.Eof;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.Bof;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.Bof',Self);{$ENDIF}
  result:=DataSet.Bof;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.RecordCount;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.RecordCount',Self);{$ENDIF}
  result:=DataSet.RecordCount;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.RecordCountFiltered;
var bm: TBookMark;
begin
	AddStack('TMulQuery.RecordCountFiltered',Self);
  if Filtered then begin
    result:=0; bm:=GetBookMark; First;
    while not Eof do begin
      Inc(result); Next;
    end;
    GotoBookMark(bm); FreeBookMark(bm);
  end
  else result:=RecordCount;
  DelStack;
end;

function TMulQuery.GetBufferChunks;
begin
  AddStack('TMulQuery.GetBufferChunks',Self);
  result:=0;
  if DataSet is TIBQuery then with TIBQuery(DataSet).CacheModelOptions do
    if CacheModelKind=cmkLimitedBufferSize then result:=BufferChunks;
  DelStack;
end;

procedure TMulQuery.SetBufferChunks;
begin
  AddStack('TMulQuery.SetBufferChunks',Self);
  if not InRange(Value,1000,100000) then Value:=0;
  if (Value<>BufferChunks) and (DataSet is TIBQuery) then begin
    Close;
    with TIBQuery(DataSet).CacheModelOptions do if Value>0 then begin
      CacheModelKind:=cmkLimitedBufferSize; BufferChunks:=Value;
    end
    else begin
      CacheModelKind:=cmkStandard; BufferChunks:=0;
    end;
  end;
  DelStack;
end;

procedure TMulQuery.Open;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.Open',Self);{$ENDIF}
  Active:=true;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.Close;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.Close',Self);{$ENDIF}
  Active:=false;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.ReOpen;
begin
  Close; Open; First;
end;

function TMulQuery.FieldCount;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.FieldCount',Self);{$ENDIF}
  result:=DataSet.FieldCount;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.Append;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.Append',Self);{$ENDIF}
  DataSet.Append;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.Edit;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.Edit',Self);{$ENDIF}
  DataSet.Edit;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.Post;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.Post',Self);{$ENDIF}
  DataSet.Post;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.Delete;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.Delete',Self);{$ENDIF}
  DataSet.Delete;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.ExecSQL;
var i: longint;
  txt: string;
	function NextWord: string;
  var j: longint;
  begin
    AddStack('TMulQuery.ExecSQL.NextWord',Self);
    while (i<=Length(txt)) and (txt[i]<=' ') do Inc(i);
    j:=i;
    while (i<=Length(txt)) and (txt[i]>' ') do Inc(i);
    result:=AnsiUpperCase(Copy(txt,j,i-j));
    DelStack;
	end;
var fl: boolean;
  s: string;
  a: TArrStr;
  j: TSQLExecType;
  n,ost: longint;
  oprop: TFindProperty;
begin
	ost:=AddStack('TMulQuery.ExecSQL',Self);
{if Pos('FLDVSM',AnsiUpperCase(Text))>0 then begin
  ost:=ost;
end;}
  FRowsAffected:=-1;
  with PswdPrm^ do begin
    if Assigned(lsTblSQL) then begin
      txt:=Text; i:=1;
      if AnsiFindText(NextWord,aSQLExec[1],n) then begin
        j:=TSQLExecType(n);
        if aSQLExec[2,j]='' then fl:=true else fl := NextWord=aSQLExec[2,j];
        if fl then
          if QuickFind(NextWord,lsTblSQL[j]) then begin
            GetStack(a); s:=''; i:=high(a)-1;
            while i>=low(a) do begin
              if  (Pos('TMulQuery.ExecTry',a[i])=0)
              and (Pos('TMulQuery.ExecPart',a[i])=0)
              and (Pos('TMulQuery.UpdateTable',a[i])=0)
              and (Pos('TMulQuery.InsertTable',a[i])=0)
              and (Pos('TMulQuery.DeleteTable',a[i])=0)
              then IncD(s,StrTran(a[i],CRLF,' ')+',');
              Dec(i);
            end;
            DecLen(s);
            if s=LastExecSQL then s:='' else LastExecSQL:=s;
            s:=CRLF+TrimRight(s);
            txt:=Trim(StrTran(txt,CRLF,' ')); oprop:=SetFindPropertyIdent;
            if DataSet is TIBQuery then begin
              with TIBQuery(DataSet) do if Prepared then
                for i:=Params.Count-1 downto 0 do
                  ReplaceInStr(txt,':'+Params[i].Name,'"'+Params[i].AsString+'"')
            end
            else
              with TQuery(DataSet) do if Prepared then
                for i:=Params.Count-1 downto 0 do
                  ReplaceInStr(txt,':'+Params[i].Name,'"'+Params[i].AsString+'"');
            FindProperty:=oprop; ProtSQLStrAdd(txt+s);
          end;
      end;
    end;
    i:=RepDeadLock;
    while true do
      try
        if DataSet is TIBQuery then with TIBQuery(DataSet) do begin
          fl := nTrns=0;
          if fl then Transaction.StartTransaction;
          try
            QSelect.ExecQuery;
            if fl then Transaction.CommitRetaining;
          except
            on EDatabaseError do begin
              if fl then Transaction.RollbackRetaining;
              raise
            end;
          end;
        end
        else TQuery(DataSet).ExecSQL;
        break;
      except
        on E:EDatabaseError do begin
          if (i=0) or (Pos('DEADLOCK',AnsiUpperCase(E.Message))=0) then raise;
          SetStack(ost);
          Sleep(100); Dec(i);
        end;
      end;
  end;
  DelStack;
end;

function TMulQuery.GetBookMark(usl: boolean = true): TBookMark;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.GetBookMark',Self);{$ENDIF}
  if usl then result:=DataSet.GetBookMark else result:=nil;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.GetBookMark(var Sender: TBookMark): TBookMark;
begin
  if not Assigned(Sender) then Sender:=GetBookMark;
  result:=Sender;
end;

procedure TMulQuery.GotoBookMark;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.GotoBookMark',Self);{$ENDIF}
  DataSet.GotoBookMark(bm);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.FreeBookMark;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.FreeBookMark',Self);{$ENDIF}
  DataSet.FreeBookMark(bm);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.Prepare;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.Prepare',Self);{$ENDIF}
  if DataSet is TIBQuery then TIBQuery(DataSet).Prepare else TQuery(DataSet).Prepare;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.UnPrepare;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.UnPrepare',Self);{$ENDIF}
  if DataSet is TIBQuery then TIBQuery(DataSet).UnPrepare else TQuery(DataSet).UnPrepare;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.ParamByName;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.ParamByName',Self);{$ENDIF}
  if DataSet is TIBQuery
  then result:=TIBQuery(DataSet).QSelect.ParamByName(Value)
  else result:=TQuery(DataSet).ParamByName(Value);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.Text;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.Text',Self);{$ENDIF}
  result:=lsSQL.Text;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.SQLText;
begin
	AddStack('TMulQuery.SQLText',Self);
  DataSet.Close; lsSQL.Text:=Value;
  DelStack;
end;

function TMulQuery.lsSQL;
begin
  AddStack('TMulQuery.lsSQL',Self);
  if DataSet is TIBQuery
  then result:=TIBQuery(DataSet).SQLs.SelectSQL
  else result:=TQuery(DataSet).SQL;
  DelStack;
end;

procedure TMulQuery.Commit;
var fl: boolean;
  p: PPswdPrm;
begin
  AddStack('TMulQuery.Commit',Self);
  if ChkTrns and IsPswdPrm(p) then fl := (p.nTrns=0) and not p.NoTrnsStart else fl:=true;
  if fl then
    if DataSet is TIBQuery then begin
      with TIBQuery(DataSet).Transaction do if Active then CommitRetaining;
    end
    else ExecPart('commit');
  DelStack;
end;

function TMulQuery.IsRecords;
begin
  AddStack('TMulQuery.IsRecords',Self);
  result := not(Eof and Bof);
  DelStack;
end;

function TMulQuery.IsRecordsAsString: string;
begin
  IsRecordsAsString(result);
end;

function TMulQuery.IsRecordsAsString(var Value: string): boolean;
begin
  AddStack('TMulQuery.IsRecordsAsString',Self);
  if Active then result:=IsRecords else result:=false;
  if result then Value:=TrimRight(Fields[0].AsString) else Value:='';
  DelStack;
end;

function TMulQuery.IsRecordsAsInteger: longint;
begin
  result:=IsRecordsAsInteger(Fields[0]);
end;

function TMulQuery.IsRecordsAsInteger(f: TField): longint;
begin
  IsRecordsAsInteger(f,result);
end;

function TMulQuery.IsRecordsAsInteger(f: TField; var Value: longint): boolean;
begin
  AddStack('TMulQuery.IsRecordsAsInteger',Self);
  if Active then result:=IsRecords else result:=false;
  if result then Value:=f.AsInteger else Value:=0;
  DelStack;
end;

function TMulQuery.RecordCountInRange;
var l: longint;
  bm: TBookMark;
begin
  AddStack('TMulQuery.RecordCountInRange',Self);
  result := MinValue=0; l:=0; bm:=GetBookMark; First;
  while not Eof do begin
    Inc(l);
    if l>=MinValue then begin
      result := l<=MaxValue;
      if not result or (MaxValue=MaxInt) then break;
    end;
    Next;
  end;
  GotoBookMark(bm); FreeBookMark(bm);
  DelStack;
end;

procedure TMulQuery.AssignTo;
var d: TMulQuery;
begin
	AddStack('TMulQuery.AssignTo',Self);
  if IsClass(Dest,TMulQuery,pointer(d)) then begin
    d.Connection:=Connection;
    d.DataSet.Filter:=DataSet.Filter;
    d.Filtered:=Filtered;
    d.DataSet.FilterOptions:=DataSet.FilterOptions;
    d.MulPar.Assign(MulPar);
    d.Part:=Part;
    d.RequestLive:=RequestLive;
    d.AfterOpen:=AfterOpen; d.AfterClose:=AfterClose; d.BeforeOpen:=BeforeOpen;
    d.BeforeClose:=BeforeClose; d.OnCalcFields:=OnCalcFields;
    d.OnFilterRecord:=OnFilterRecord;
  end;
  DelStack;
end;

procedure TMulQuery.DoAfterOpen;
begin
  AddStack('TMulQuery.DoAfterOpen',Self);
  IfThenDataSet(FAfterOpen,DataSet);
  DelStack;
end;

procedure TMulQuery.DoBeforeOpen;
begin
	AddStack('TMulQuery.DoBeforeOpen',Self);
  IfThenDataSet(FBeforeOpen,DataSet);
  DelStack;
end;

procedure TMulQuery.DoAfterClose;
var i: longint;
begin
  AddStack('TMulQuery.DoAfterClose',Self);
  IfThenDataSet(FAfterClose,DataSet);
  for i:=low(aObjInActive) to high(aObjInActive) do aObjInActive[i].Free;
  aObjInActive:=nil; FreeAndNil(LsFld);
  DelStack;
end;

procedure TMulQuery.FillSQL;
begin
	AddStack('TMulQuery.FillSQL',Self);
	if not(empty(FPart) or FActiveTry) then
    if (csDesigning in ComponentState)
    or (csReading in ComponentState)
    or (csLoading in ComponentState) then begin
      clearsql; setpart; clearsql;
    end else begin
      if ComponentState=[] then setpart;
    end;
  FreeAndNil(LsFld);
  DelStack;
end;

function TMulQuery.ExecTry;
	{procedure p1(eContext: longint; msg: string);
	var Ctxt: string;
  begin
    SetLength(Ctxt,DBIMAXMSGLEN);
    DbiGetErrorContext(eContext,PChar(Ctxt));
    SetLength(Ctxt,StrLen(PChar(Ctxt)));
    if (Ctxt>'') then
      meserr(msg+': '+Ctxt);
  end;}
var ost: longint;
begin
	ost:=AddStack('TMulQuery.ExecTry',Self);
	result:=true;
  if not empty(Text) then begin
    if fl_mess then ShowErr;
    try
      execSql;
    except
      on E: EDatabaseError do begin
        {p1(ecTOKEN,'ecTOKEN');
        p1(ecTABLENAME,'ecTABLENAME');
        p1(ecFIELDNAME,'ecFIELDNAME');
        p1(ecIMAGEROW,'ecIMAGEROW');
        p1(ecUSERNAME,'ecUSERNAME');
        p1(ecFILENAME,'ecFILENAME');
        p1(ecINDEXNAME,'ecINDEXNAME');
        p1(ecKEYNAME,'ecKEYNAME');
        p1(ecDIRNAME,'ecDIRNAME');
        p1(ecALIAS,'ecALIAS');
        p1(ecDRIVENAME,'ecDRIVENAME');
        p1(ecNATIVECODE,'ecNATIVECODE');
        p1(ecNATIVEMSG,'ecNATIVEMSG');
        p1(ecLINENUMBER,'ecLINENUMBER');
        p1(ecCAPABILITY,'ecCAPABILITY');}
        result:=false;
        if not lMsg then begin
      	  RnmStack('TMulQuery.ExecTry: '+TrimRight(Text),Self,ost);
          raise
        end;
		  	SetStack(ost);
        ShowErr(E);
      end;
    end;
  end;
  DelStack;
end;

function TMulQuery.OpenTry;
var ost: longint;
begin
	ost:=AddStack('TMulQuery.OpenTry',Self);
	result:=true;
	if fl_mess then ShowErr;
	try
		open;
	except
		on E:EDatabaseError do begin
    	result:=false;
      if not lMsg then begin
        RnmStack('TMulQuery.OpenTry: '+TrimRight(Text),Self,ost);
        raise
      end;
    	SetStack(ost);
    	ShowErr(E);
		end;
	end;
  DelStack;
end;

function TMulQuery.ExecMpart;
var i: longint;
begin
	AddStack('TMulQuery.ExecMpart',Self);
	result:=true;
	for i:=low(a) to high(a) do if not empty(a[i]) then
    if not execpart(a[i],lMsg) then begin
      result:=false; break;
    end;
  DelStack;
end;

function TMulQuery.ExecPart;
var pt: PTblInfo;
  i,j: longint;
  ac,av: TArrStr;
  a: TArrBool;
  p: PPswdPrm;
label lend;
begin
	AddStack('TMulQuery.ExecPart',Self);
	SQLtext(SetCurrSQL(name));
  if name=sI_TABLE then
    if TblInfoCreateFld(Connection,Arg[sTABLE],pt) then begin
      if not Assigned(pt.qIns) then begin
        pt.qIns:=TMulQuery.CreateConnection(nil,Connection); pt.qIns.Arg[sTABLE]:=Arg[sTABLE];
        pt.qIns.Arg[sC_LIST]:=StrTran(TrimRight(pt.LsFld.Text),CRLF,cDlm);
        for i:=0 to pt.LsFld.Count-1 do pt.qIns.AddArgList(sV_LIST,StrNum(':V',i));
        pt.qIns.SetPart(sI_TABLE); pt.qIns.Prepare;
      end;
      SetLength(a,pt.LsFld.Count); ZeroMemory(@a[0],pt.LsFld.Count*SizeOf(a[0]));
      GetListArg(sC_LIST,ac); GetListArg(sV_LIST,av);
      for j:=low(ac) to high(ac) do begin
        pt.LsFld.Find(ac[j],i); a[i]:=true; pt.qIns.SetParamValue(i,av[j]);
      end;
      for i:=low(a) to high(a) do if not a[i] then
        if pt.qIns.DataSet is TIBQuery
        then TIBQuery(pt.qIns.DataSet).Params[i].Value:=UnAssigned
        else with TQuery(pt.qIns.DataSet).Params[i] do begin
          DataType:=ftDateTime; Value:=UnAssigned;
        end;
      result:=pt.qIns.ExecTry(lMsg); FRowsAffected:=pt.qIns.RowsAffected; goto lend;
    end;
  if AnsiMatchStr(name,[sU_TABLE,sUW_TABLE]) and (TrimUpper(Arg[sTABLE])=tREGS) and IsPswdPrm(p) then
    if (p.nTrns>0) and (Connection=p.DBMain) then begin
      i:=Length(p.aqTrns); SetLength(p.aqTrns,i+1); p.aqTrns[i,1]:=Part; p.aqTrns[i,2]:=MulPar.Text;
      result:=true; goto lend;
    end;
  result:=ExecTry(lMsg);
lend:
  DelStack;
end;

procedure TMulQuery.SetParamValue;
var p: TObject;
begin
  {$IFDEF STACKALL}AddStack('TMulQuery.SetParamValue',Self);{$ENDIF}
  if DataSet is TIBQuery
  then p:=TIBQuery(DataSet).Params[Index]
  else p:=TQuery(DataSet).Params[Index];
  qSetParamValue(p,Value);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.FindFirst;
begin
  AddStack('TMulQuery.FindFirst',Self);
  if FindProperty.Direction=fndBack then Last else First;
  DelStack;
end;

function TMulQuery.FindEof;
begin
  AddStack('TMulQuery.FindEof',Self);
  if FindProperty.Direction=fndBack then result:=Bof else result:=Eof;
  DelStack;
end;

procedure TMulQuery.FindNext;
begin
  AddStack('TMulQuery.FindNext',Self);
  if FindProperty.Direction=fndBack then Prior else Next;
  DelStack;
end;

function TMulQuery.ExecInsFromSel;
begin
  AddStack('TMulQuery.ExecInsFromSel',Self);
  result:=ExecPart(sIS_TABLE); MaxFldClear(Arg[sTABLE]);
  DelStack;
end;

function TMulQuery.SetPart(const name: string): string;
begin
	AddStack('TMulQuery.SetPart',Self);
	SQLText(SetCurrSQL(name)); result:=TrimRight(Text);
  DelStack;
end;

function TMulQuery.SetPart(q: TMulQuery): string;
begin
  result:=SetPart(q.FPart);
end;

function TMulQuery.SetPart: string;
begin
  result:=SetPart(Self);
end;

function TMulQuery.GetPart;
var argold:array[0..200] of string;i:longint;
	opart: string;
begin
	AddStack('TMulQuery.GetPart',Self);
	i:=low(argname);
	while i<=high(argname) do begin
		 argold[i]:=arg[argname[i]];
		 arg[argname[i]]:=argval[i];
		 inc(i);
	end;
  opart:=FPart; result:=SetCurrSQL(name);
	i:=low(argname);
	while i<=high(argname) do begin
		 arg[argname[i]]:=argold[i];
		 inc(i);
	end;
  Part:=opart;
  DelStack;
end;
function TMulQuery.SetCurrSQL;
  // Вставить макроподстановки
  function ins_macro(const ss:string):string;
  var sost: string;
  	aost: TArrStr;
    lost: longint;
  	procedure sostSet(const s: string = '');
    begin
      AddStack('TMulQuery.SetCurrSQL.ins_macro.sostSet',Self);
      sost:=s; lost:=LsArrDynamic(sost,aost,cQQ);
      DelStack;
    end;
  var k: longint;
  	function sostPos(c: char): boolean;
    var i,j: longint;
    begin
      AddStack('TMulQuery.SetCurrSQL.ins_macro.sostPos',Self);
      i:=low(aost); result:=false; k:=0;
      while i<lost do begin
        if IsPos(j,c,aost[i]) then begin
        	Inc(k,j); result:=true; break;
        end;
      	Inc(k,Length(aost[i])+1); Inc(i);
        if i=lost then break;
      	Inc(k,Length(aost[i])+1); Inc(i);
      end;
      DelStack;
    end;
  var srez,spart,sallpar,smpar:string;
    cnt,cntmax,i,j:longint;
    buf:array[1..512] of string;
    sZpt: string;
    a: TNamePrimStr;
  begin
    AddStack('TMulQuery.SetCurrSQL.ins_macro',Self);
  // множенственные макроподстановки
    srez:=''; sostSet(ss);
    while length(sost)>0 do begin
      if sostPos('[') then begin
        IncD(srez,copy(sost,1,k-1));
        sostSet(copy(sost,k,maxint));
        if sostPos(']') then begin
        	sZpt:=',';
        	if Copy(sost,k+1,1)=cQQ then begin
          	sallpar:=Copy(sost,k+2,MaxInt);	j:=PosEnd(cQQ,sallpar);
            sZpt:=LeftStr(sallpar,j-1); sostSet(StuffString(sost,k+1,j+1,''));
          end;
          smpar:=copy(sost,1,k);
          sostSet(copy(sost,k+1,maxint));
          if (pos('{',smpar)>0) and (pos('}',smpar)>0) then begin
            SubStrSelf(smpar,2,-1);
            sallpar:='';
            i:=1;
            while true do begin
              spart:=smpar; cntmax:=0;
              for j:=0 to MulPar.count-1 do if StrDivDlm('=',mulpar[j],a) then begin
                IncL(a[1],'{','}');
                if pos(a[1],spart)>0 then begin
                  cnt:=listasarray(a[2],buf,cDlm);
                  StrTranSelf(spart,a[1],ins_macro(buf[IfThen(i>cnt,1,i)]));
                  MaxSelf(cntmax,cnt);
                end;
              end;
              inc(i);
              IncD(sallpar,IfThen(length(sallpar)>0,sZpt)+spart);
              if i>cntmax then break;
            end;
            IncD(srez,sallpar);
          end else begin
            IncD(srez,smpar);
          end;
        end else begin
          IncD(srez,sost); sostSet;
        end;
      end else begin
        IncD(srez,sost); sostSet;
      end;
    end;
    // простые макроподстановки
    for j:=0 to MulPar.count-1 do if StrDivDlm('=',mulpar[j],a) then begin
      IncL(a[1],'{','}');
      if pos(a[1],srez)>0 then StrTranSelf(srez,a[1],ins_macro(a[2]));
    end;
    result:=srez;
    DelStack;
  end;
var sall,name: string;
  k,l: longint;
  fl: boolean;
	pd: PDriverInfo;
begin
	AddStack('TMulQuery.SetCurrSQL',Self);
	Fpart:=nameSQL; FActiveTry:=true;
	name:=UnDelim+AnsiUpperCase(nameSQL); pd:=GetDrvInfo(Self); l:=Length(pd.aSQL);
  fl:=IntObjFind(pd.ListName,name,k);
	if fl then currline:=k
  else begin
    currline:=0;
    while currline<l do
      if AnsiUpperCase(StrDivDlm(' ',trim(pd.aSQL[Currline]))[1])=name then break else inc(currline);
  end;
	k:=currline;
	inc(currline);
	sall:='';
	while (currline<l) and (not AnsiStartsStr(UnDelim,pd.aSQL[currline])) do begin
		IncD(sall,ins_macro(pd.aSQL[Currline])); inc(currline);
	end;
	if not fl then pd.ListName.AddObject(name,pointer(k)); // добавить в список имён
	if k>currline then raise EDatabaseError.Create('Не найден SQL запрос: '+name);
	result:=sall;
  if Length(result)>MaxLenSQLText then begin
    OutStack('Длина SQL-запроса превышает допустимую:'+CRLF+result);
    if IsUserGG then MsgDlg(['Длина SQL-запроса превышает допустимую','(см. вид протокола "'+aProtFile[protProg,2]+'")']);
  end;
  DelStack;
end;

function Tmulquery.FGetDriverName;
begin
	AddStack('TMulQuery.FGetDriverName',Self);
  result:=GetDriverName(FConnection);
  DelStack;
end;

function Tmulquery.FldInSel;
var lqs,lls: boolean;
	azn: TArrStr;
  q: TMulQuery;
  f: TField;
  bm: TBookMark;
  ssnmf: string;
begin
  AddStack('Tmulquery.FldInSel',Self);
  lqs:=Assigned(qs);
  if lqs or not DrvCan('In_Select') or Assigned(ares) then Include(Opt,fselList);
  ssnmf:=IfThen(snmf='',nmf,snmf);
  result:=nmf+aInList[fselNot in Opt,2]+sIN
    +BrackNoEmp(PartSelect(tbl,ssnmf,where,'',group,(fselList in Opt) and not lqs));
  if fselList in Opt then begin
  	bm:=nil;
    try
      if lqs then begin
        if qs.Active then begin
          if qs.IsRecords then begin
            qs.DisableControls; bm:=qs.GetBookmark;
          end;
        end
        else qs.Open;
        if AnsiStartsStr(UnDelim,ssnmf)
        then f:=qs.Fields[Int0(Copy(ssnmf,lUnDelim1,MaxInt))]
        else if not qs.FindField(ssnmf,f) then f:=qs.Fields[0];
        if not(fselFromCur in Opt) then qs.First;
        q:=Self;
      end
      else begin
        qs:=Self; f:=Fields[0]; q:=TMulQuery.Create(Owner);
      end;
      lls:=not Assigned(ls);
      if lls then ls:=SortStrListCreate
      else if not(fselNoClr in Opt) then ls.Clear;
      try
        q.Connection:=Connection;
        with qs do begin
          while not Eof do begin
            ls.Add(q.VarTos(f,vsQQ)); Next;
          end;
          CopyFrom(azn,ls);
          if Assigned(bm) then begin
            GotoBookmark(bm); qs.EnableControls;
          end;
        end;
      finally
        if not lqs then q.Free;
        if lls then ls.Free;
      end;
    finally
      FreeBookmark(bm);
    end;
    if Assigned(ares)
    then FldInList(ares^,nmf,azn,NegDef,IfThen(fselNot in Opt,flsNot))
    else result:=FldInList(nmf,azn,NegDef,IfThen(fselNot in Opt,flsNot));
  end;
  DelStack;
end;

// Значение поля FieldName
function TMulQuery.FieldZn;
var f: TField;
begin
	AddStack('TMulQuery.FieldZn',Self);
  if TableName='' then f:=FindField(FieldName) else f:=FindField(TableName,FieldName);
	result:=FieldAsVariant(f);
  DelStack;
end;

function TMulQuery.FieldValueIndex;
begin
  AddStack('TMulQuery.FieldValueIndex',Self);
  result:=FieldAsVariant(Fields[Index]);
  DelStack;
end;

function TMulQuery.FieldAsString;
begin
  AddStack('TMulQuery.FieldAsString');
  result:=My_pr.FieldAsString(FindField(FieldName));
  DelStack;
end;

function TMulQuery.StrNow;
begin
	AddStack('TMulQuery.StrNow',Self);
  result:=SetPart('now');
  if empty(result) then result:=SQLDateTime(Now);
  DelStack;
end;

// Значение типа дата-время в формате SQL
function TMulQuery.SQLDateTime;
begin
	AddStack('TMulQuery.SQLDateTime',Self);
	if MyVarType(d)=varDate
  then result:=FormatDateTime(TrimRight(SetPart('fmtdatetime')),d)
  else result:=d;
  if lQQ then QQsSelf(result);
  DelStack;
end;

function TMulQuery.VarToS(const vv: variant; Opt: TVarToSOpt = []): string;
var v: variant;
  t: longint;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.VarToS',Self);{$ENDIF}
  t:=MyVarType(vv);
  if t in [varNull,varDate] then begin
    result:=sNULL;
    if t=varDate then begin
      v:=VarAsType(vv,varDouble);
      if v<>0 then result:=cQQ+FormatDateTime(TrimRight(GetPart(IfThen(vsDateWithTime in Opt,
        'fmtdatetime','fmtdate'),[''],[''])),v)+cQQ;
    end;
  end
  else result:=VToS(vv,vsQQ in Opt);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.VarToS(const vv: variant; Opt: TVarToSList): string;
begin
  result:=VarTos(vv,[Opt]);
end;

function TMulQuery.VarToS(f: TField; Opt: TVarToSOpt = []): string;
begin
  result:=VarTos(f.Value,Opt);
end;

function TMulQuery.VarToS(f: TField; Opt: TVarToSList): string;
begin
  result:=VarTos(f,[Opt]);
end;

function TMulQuery.QQHighLim;
begin
  {$IFDEF STACKALL}AddStack('TMulQuery.QQHighLim',Self);{$ENDIF}
  result:=BrackNoEmp(nmf+sISNULL+sOR+nmf+'<='+VarTos(v,vsQQ));
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.QQDate(const nmf: string; const v: variant): string;
begin
  {$IFDEF STACKALL}AddStack('TMulQuery.QQDate',Self);{$ENDIF}
  if (MyVarType(v)=varDate) and empty(v) then result:=nmf+sISNULL else result:=nmf+'='+VarTos(v,vsQQ);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.QQDate(const nmf: string; const db,de: variant): string;
var DeNoBig: boolean;
begin
  if MyVarType(de)=varDate then DeNoBig := de<DateBig else DeNoBig:=true;
  result:=DlmBetween(IfThen(not empty(db),nmf+'>='+VarTos(db)),IfThen(not empty(de) and DeNoBig,nmf+'<='+VarTos(de)),sAND);
end;

function TMulQuery.DrvCan;
begin
	AddStack('TMulQuery.DrvCan',Self);
	result:=QuickFind(Index,GetDrvInfo(Self).aCan);
  DelStack;
end;

function TMulQuery.PartSelect(const table: string; const c_list: string;
  const where: string = ''; const o_list: string = ''; const g_list: string = '';
  lOpen: boolean = true; const have: string = ''): string;
begin
  result:=PartSelect(table,[c_list],where,o_list,g_list,lOpen,have);
end;

function TMulQuery.PartSelect(const table: string; const c_list: array of variant;
  const where: string = ''; const o_list: string = ''; const g_list: string = '';
  lOpen: boolean = true; const have: string = ''): string;
var l: longint;
begin
  AddStack('TMulQuery.PartSelect',Self);
  if table<>'' then Arg[sTABLE]:=table;
  l:=Length(c_list);
  if l=0 then Arg[sC_LIST]:='*'
  else if not((l=1) and (c_list[0]='')) then SetArrayList(sC_LIST,c_list);
  Arg[sWHERE]:=where; Arg[sO_LIST]:=o_list; Arg[sG_LIST]:=g_list; Arg[sHAVE]:=have;
  result:=SetPart(aPartWOGH[where='',o_list='',g_list='',have='']); 
//RnmStack('TMulQuery.PartSelect:'+result,Self);
  if lOpen then Open;
  DelStack;
end;

function TMulQuery.PartCount(const table: string; const where: string = ''): longint;
begin
  AddStack('TMulQuery.PartCount(i)',Self);
  PartCount(table,[],where); result:=Fields[0].AsInteger;
  DelStack;
end;

function TMulQuery.PartCount(const table: string; const c_list: array of variant;
  const where: string = ''; lOpen: boolean = true): string;
begin
  AddStack('TMulQuery.PartCount',Self);
  result:=PartGroup(table,c_list,where,sCOUNTZV,lOpen);
  DelStack;
end;

function TMulQuery.PartCount0;
begin
  AddStack('TMulQuery.PartCount0',Self);
  result := PartCount(table,where)=0;
  DelStack;
end;

function TMulQuery.PartMaxInt;
begin
  AddStack('TMulQuery.PartMaxInt',Self);
  PartMax(table,nmf,where); result:=Fields[0].AsInteger;
  DelStack;
end;

function TMulQuery.PartMaxDate;
begin
  AddStack('TMulQuery.PartMaxInt',Self);
  PartMax(table,nmf,where); result:=Fields[0].AsDateTime;
  DelStack;
end;

function TMulQuery.PartMax(const table,nmf: string; const where: string = ''; lOpen: boolean = true): string;
begin
  result:=PartMax(table,nmf,[],where,lOpen);
end;

function TMulQuery.PartMax(const table,nmf: string; const c_list: array of variant;
  const where: string = ''; lOpen: boolean = true): string;
begin
  AddStack('TMulQuery.PartMax',Self);
  result:=PartGroup(table,c_list,where,'max('+nmf+')',lOpen);
  DelStack;
end;

function TMulQuery.PartMinDate;
begin
  AddStack('TMulQuery.PartMinDate',Self);
  PartMin(table,nmf,where); result:=Fields[0].AsDateTime;
  DelStack;
end;

function TMulQuery.PartMin(const table,nmf: string; const where: string = ''; lOpen: boolean = true): string;
begin
  result:=PartMin(table,nmf,[],where,lOpen);
end;

function TMulQuery.PartMin(const table,nmf: string; const c_list: array of variant;
  const where: string = ''; lOpen: boolean = true): string;
begin
  AddStack('TMulQuery.PartMin',Self);
  result:=PartGroup(table,c_list,where,'min('+nmf+')',lOpen);
  DelStack;
end;

function TMulQuery.PartGroup;
begin
  AddStack('TMulQuery.PartGroup',Self);
  result:=GetList(c_list); result:=PartSelect(table,[result,nmf],where,result,result,lOpen);
  DelStack;
end;

procedure TMulQuery.UpdateTable(const table: string; const c_list,v_list: array of variant;
  const where: string = '');
begin
	AddStack('TMulQuery.UpdateTable(list)',Self);
  SetArrayList(sC_LIST,c_list); SetArrayList(sV_LIST,v_list); UpdateTable(table,where);
  DelStack;
end;

procedure TMulQuery.UpdateTable(const table: string = ''; const where: string = '');
begin
	AddStack('TMulQuery.UpdateTable',Self);
  if table<>'' then Arg[sTABLE]:=table;
  if where='' then ExecPart(sU_TABLE)
  else begin
    Arg[sWHERE]:=where; ExecPart(sUW_TABLE);
  end;
  DelStack;
end;

procedure TMulQuery.UpdateTableFldList(const c_list,v_list: array of variant;
  const azn: array of string; l: longint = NegDef; const nmf: string = fRECNO; Opt: TFldInListOpt = [];
  const table: string = ''; const where: string = '');
var a: TArrStr;
begin
  AddStack('TMulQuery.UpdateTableFldList',Self);
  if table<>'' then Arg[sTABLE]:=table;
  FldInList(a,nmf,azn,l,Opt);
  for l:=low(a) to high(a) do UpdateTable('',c_list,v_list,a[l]+where);
  DelStack;
end;

procedure TMulQuery.UpdateTableFldList(const c_list,v_list: array of variant;
  ls: TIntegerList; const nmf: string = fRECNO;
  const table: string = ''; const where: string = '');
var a: TArrStr;
  i: longint;
begin
  AddStack('TMulQuery.UpdateTableFldList(TIntegerList)',Self);
  if table<>'' then Arg[sTABLE]:=table;
  ls.FldInListQQ(a,nmf);
  for i:=low(a) to high(a) do UpdateTable('',c_list,v_list,a[i]+where);
  DelStack;
end;

procedure TMulQuery.UpdateTableList(const awhere: array of string; const table: string = ''; const where: string = '');
var i: longint;
begin
  AddStack('TMulQuery.UpdateTableList',Self);
  if table<>'' then Arg[sTABLE]:=table;
  for i:=low(awhere) to high(awhere) do UpdateTable('',awhere[i]+where);
  DelStack;
end;

procedure TMulQuery.UpdateTableList(const awhere: array of string;
  const c_list,v_list: array of variant; const table: string = ''; const where: string = '');
begin
  SetArrayList(sC_LIST,c_list); SetArrayList(sV_LIST,v_list); UpdateTableList(awhere,table,where);
end;

function TMulQuery.DeleteTable;
begin
  AddStack('TMulQuery.DeleteTable',Self);
  if table<>'' then Arg[sTABLE]:=table;
  if where='' then result:=ExecPart(sD_TABLE,lMsg)
  else begin
    Arg[sWHERE]:=where; result:=ExecPart(sDW_TABLE,lMsg);
  end;
  DelStack;
end;

function TMulQuery.DeleteTableFldList;
var a: TArrStr;
begin
  AddStack('TMulQuery.DeleteTableFldList',Self);
  FldInList(a,nmf,azn,l,Opt); result:=DeleteTableList(a,table,lMsg,where);
  DelStack;
end;

function TMulQuery.DeleteTableList;
var i: longint;
begin
  AddStack('TMulQuery.DeleteTableList',Self);
  result:=true;
  if table<>'' then Arg[sTABLE]:=table;
  for i:=low(awhere) to high(awhere) do if not DeleteTable('',awhere[i]+where,lMsg) then begin
    result:=false; break;
  end;
  DelStack;
end;

function TMulQuery.InsertTable;
begin
  AddStack('TMulQuery.InsertTable',Self);
  if table<>'' then Arg[sTABLE]:=table;
  SetArrayList(sC_LIST,c_list); SetArrayList(sV_LIST,v_list); result:=ExecPart(sI_TABLE);
  DelStack;
end;

function TMulQuery.GetList;
var s: string;
begin
  AddStack('TMulQuery.GetList',Self);
	result:='';
	for l:=0 to ReplNegVar(l,aa)-1 do begin
  	s:=VarToS(aa[l]);
    if s<>'' then IncD(result,s+cDlm);
  end;
  DecLen(result,lDlm);
  DelStack;
end;

procedure TMulQuery.GetListArg(const name: string; var a: TArrStr);
begin
	AddStack('TMulQuery.GetListArg',Self);
  LsArrDynamic(Arg[name],a,cDlm,lsaSetLen);
  DelStack;
end;

function TMulQuery.GetListArg(const name: string): string;
var a: TArrStr;
begin
	AddStack('TMulQuery.GetListArg(0)',Self);
  GetListArg(name,a); result:=IfThen(a);
  DelStack;
end;

function TMulQuery.GetMaxFld;
var i,r,ro: longint;
  p: PDBInfo;
  pt: PTblInfo;
  aw: TArrBoolStr;
  wRec: string;
  lTbl,lRec,lRec1: boolean;
begin
	AddStack('TMulQuery.GetMaxFld',Self);
  LsDBFind(Connection,p); LsDBTblLoad(p); pt:=TblInfo(p,p.LsTbl.IndexOf(nmTbl)); 
  with PswdPrm^ do begin
    if IgnoreSlFindAdd(SortStrListCreate(pt.LsMax),nmFld,i) then r:=IntObj(pt.LsMax,i)
    else begin
      wRec:=StrNum(nmFld+'+',UserCnt-UserNum);
      aw[false]:=BrackNoEmp(GetPart('asint',['col'],[BrackNoEmp(wRec)+StrNum('/',UserCnt)]))+Format('*%d=',[UserCnt])+wRec;
      lTbl:=IsTable(tMAXFLD);
      if lTbl then begin
        wRec:=ArrayAsList([fDbsTABLE+'='+QQs(nmTbl),fDbsFIELD+'='+QQs(nmFld),
          fUSERNUM+'='+Vtos(UserNum+1)],sAND);
        PartSelect(tMAXFLD,['VAL'],wRec); lRec:=not Eof;
        if lRec then aw[true]:=aw[false]+sAND+nmFld+'>='+Vtos(Fields[0].AsInteger);
      end
      else lRec:=false;
      r:=0; // Variable might not have been initialized
      for lRec1:=lRec downto false do begin
        r:=PartMaxInt(nmTbl,nmFld,DlmBetween(where,aw[lRec1],sAND));
        if r>0 then break;
      end;
      if r>0 then begin
        if MsgMaxFld then if r > MaxInt div 4 * 3 then begin
          MsgMaxFld:=false;
          OutStack(Format('Переполнение уникальных номеров ('+nmTbl+'.'+nmFld+'=%d)',[r]));
          mess_ok(['Внимание !',Format('Возможно переполнение уникальных номеров ('+nmTbl+'.'+nmFld+'=%d).',[r]),
            'Рекомендуется выполнить дефрагментацию номеров записей.']);
        end;
        if (r mod UserCnt) <> UserNum then raise Exception.CreateFmt(
          'Ошибка определения максимального значения поля:%sнесоответствие номеру регистрации.%s'
          +'Таблица: %s%sПоле: %s%sМаксимальное значение: %d%sМаксимальное количество пользователей: %d%s'
          +'Номер регистрации: %d%sОбратитесь к разработчикам.',
          [CRLF,CRLF,nmTbl,CRLF,nmFld,CRLF,r,CRLF,UserCnt,CRLF,UserNum,CRLF]);
        if lTbl then
          if lRec
          then UpdateTable(tMAXFLD,['VAL'],[r],wRec+sAND+'VAL<>'+Vtos(r))
          else InsertTable(tMAXFLD,[fDbsTABLE,fDbsFIELD,fUSERNUM,'VAL'],
            [QQs(nmTbl),QQs(nmFld),UserNum+1,r]);
      end;
    end;
    if not lSave then SetPLongInt(pVal,r);
    if not Assigned(pVal) and lSave then begin
      ro:=r; pVal:=@ro;
    end;
    if r=0 then r:=IfThen(UserNum=0,UserCnt,UserNum) else Inc(r,UserCnt);
  end;
  result:=r;
  if lSave then GetPLongInt(pVal,r);
  pt.LsMax.Objects[i]:=Pointer(r);
  DelStack;
end;

procedure TMulQuery.MaxFldClear;
var p: PDBInfo;
  i: longint;
begin
  AddStack('TMulQuery.MaxFldClear',Self);
  if LsDBFind(Connection,p) then begin
    LsDBTblLoad(p);
    if p.LsTbl.Find(nmTbl,i) then FreeAndNil(TblInfo(p,i).LsMax);
  end;
  DelStack;
end;

procedure TMulQuery.MaxFldClearAll;
var p: PDBInfo;
  i: longint;
begin
  AddStack('TMulQuery.MaxFldClearAll',Self);
  if LsDBFind(Connection,p) then begin
    LsDBTblLoad(p);
    for i:=0 to p.LsTbl.Count-1 do FreeAndNil(TblInfo(p,i).LsMax);
  end;
  DelStack;
end;

procedure TMulQuery.DBFlush;
var db: TComponent;
begin
  AddStack('TMulQuery.DBFlush',Self);
  db:=Connection;
  if (not NoDBFlush or (flushBound in Opt)) and Connected(db) then begin
    if not(flushConnect in Opt) then
      if empty(SetPart('flush_tbl')) then Include(Opt,flushConnect);
    if flushConnect in Opt then begin
      SetConnected(db,false); SetConnected(db,true);
    end
    else ExecTry;
  end;
  LsDBClearDB(db);
  DelStack;
end;

procedure TMulQuery.DBDeleteIndex;
var ls,lst: TStringList;
  lIntb: boolean;
	q: TMulQuery;
  i,j: longint;
begin
  AddStack('TMulQuery.DBDeleteIndex',Self);
  if IsSQLBased(Connection) then begin
    q:=nil; ls:=TStringList.Create; CloseDataSets(Connection);
    try
      lIntb := GetDriverName(Connection)=drvINTRBASE;
      if lIntb then begin
        GetStoredProcNames(Connection,ls);
        for i:=0 to ls.Count-1 do begin
          SQLText('ALTER PROCEDURE '+ls[i]+' AS BEGIN EXIT; END'); ExecSQL;
          SQLText('DROP PROCEDURE '+ls[i]); ExecSQL;
        end;
        q:=TMulQuery.CreateConnection(nil,Connection);
        q.PartSelect('RDB$RELATION_CONSTRAINTS',['RDB$CONSTRAINT_NAME','RDB$RELATION_NAME'],'RDB$INDEX_NAME<>'+QQs);
        while not q.Eof do begin
          SQLText('ALTER TABLE '+q.Fields[1].AsString+' DROP CONSTRAINT '+q.Fields[0].AsString);
          ExecSQL; q.Next;
        end;
        q.PartSelect('RDB$TRIGGERS','RDB$TRIGGER_NAME','RDB$SYSTEM_FLAG<>1'+sOR+'RDB$SYSTEM_FLAG'+sISNULL);
        while not q.Eof do begin
          SQLText('DROP TRIGGER '+q.Fields[0].AsString); ExecSQL; q.Next;
        end;
        q.PartSelect('RDB$EXCEPTIONS','RDB$EXCEPTION_NAME');
        while not q.Eof do begin
          SQLText('DROP EXCEPTION '+q.Fields[0].AsString); ExecSQL; q.Next;
        end;
      end;
      lst:=GetTableList(Connection);
      for i:=0 to lst.Count-1 do with TMQIndexList.Create(Connection,lst[i]) do
        try
          for j:=0 to Count-1 do begin
            SQLText('drop index '+Strings[j]+IfThen(not lIntb,' on '+lst[i])); ExecSQL;
          end;
        finally
          Free;
        end;
    finally
      ls.Free; q.Free;
    end;
  end;
  DelStack;
end;

class procedure TMulQuery.MessSql;
begin
	fl_mess:=fl;
end;

function TMulQuery.UnionOpen;
var i: longint;
  sord: string;
begin
  AddStack('TMulQuery.UnionOpen',Self);
  ReplNegSelf(l,Length(a));
  if l>0 then begin
    sord:='';
    if Assigned(pOrd) then begin
      for i:=low(pOrd^) to high(pOrd^) do IncD(sord,IntToStr(pOrd^[i])+',');
      DecLen(sord);
    end;
  	with a[low(a)] do PartSelect(table,fld,where,IfThen(l=1,sord),group,lOpen and (l=1));
  	if l>1 then begin
      Dec(l);
      for i:=low(a)+1 to l do begin
        Arg['select1']:=Text;
        with a[i] do Arg['select2']:=PartSelect(table,fld,where,IfThen(i=l,sord),group,false);
        SetPart('union');
      end;
      if lOpen then begin
        Open; First;
      end;
    end;
    result:=Text; 
  end
  else begin
    Close; result:='';
  end;
  DelStack;
end;

function TMulQuery.DropTable;
var ost: longint;
begin
	ost:=AddStack('TMulQuery.DropTable',Self);
  result:=false; arg[sTABLE]:=tbl; SetPart('drop_table');
  try
    ExecSql; Commit; LsDBClearTbl(Connection,tbl,true); result:=true;
  except
    on E:EDatabaseError do begin
      SetStack(ost);
      SetPString(msgErr,E.Message);
    end;
  end;
  DelStack;
end;

function TMulQuery.Concat;
begin
  AddStack('TMulQuery.Concat',Self);
  result:=GetList(a,l);
  if result<>'' then result:=GetPart('s+s',[sC_LIST],[result]);
  DelStack;
end;

function TMulQuery.GetArgParam;
var a: TArrStr;
	i,p: longint;
begin
  AddStack('TMulQuery.GetArgParam',Self);
  i:=LsArrDynamic(GetArg(Index),a,'{'); result:=a[0];
  for i:=1 to i-1 do begin
  	p:=Pos('}',a[i]); IncD(result,StuffString(a[i],1,p,GetArg(LeftStr(a[i],p-1))));
  end;
  DelStack;
end;

function TMulQuery.LsFldFind;
var i: longint;
begin
  {$IFDEF STACKALL}AddStack('TMulQuery.LsFldFind',Self);{$ENDIF}
  if not Assigned(LsFld) then begin
    LsFld:=TStringList.Create;
    for i:=0 to Fields.Count-1 do LsFld.AddObject(Fields[i].FieldName,Fields[i]);
    LsFld.Sorted:=true;
  end;
  result:=LsFld.Find(FieldName,Index);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.FindField(const FieldName: string): TField;
var i: longint;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.FindField',Self);{$ENDIF}
  if LsFldFind(FieldName,i) then result:=PointerObj(LsFld,i) else result:=nil;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.FindField(const TableName,FieldName: string): TField;
var i: longint;
  f: TField;
  s: string;
begin
	{$IFDEF STACKALL}AddStack('TMulQuery.FindField(t)',Self);{$ENDIF}
  LsFldFind(FieldName,i); result:=nil; s:=TrimUpper(TableName)+'.'+TrimUpper(FieldName);
  while i<LsFld.Count do begin
    f:=PointerObj(LsFld,i);
    if TrimUpper(Origin(f))=s then begin
      result:=f; break;
    end;
    Inc(i);
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.FindField(const FieldName: string; var f: TField): boolean;
begin
  f:=FindField(FieldName); result:=Assigned(f);
end;

function TMulQuery.FindField(const TableName,FieldName: string; var f: TField): boolean;
begin
  f:=FindField(TableName,FieldName); result:=Assigned(f);
end;

function TMulQuery.FindField(usl: boolean; const FieldName: string): TField;
begin
  if usl then result:=FindField(FieldName) else result:=nil;
end;

function TMulQuery.IsField;
begin
  {$IFDEF STACKALL}AddStack('TMulQuery.IsField',Self);{$ENDIF}
  result:=Assigned(FindField(FieldName));
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.NumFromName;
var f: TField;
begin
  {$IFDEF STACKALL}AddStack('TMulQuery.NumFromName',Self);{$ENDIF}
  result:=FindField(nmf,f);
  if result then i:=f.Index else i:=-1;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMulQuery.ActiveNoNil;
begin
  AddStack('TMulQuery.ActiveNoNil',Self);
  if Assigned(Self) then result:=Active else result:=false;
  DelStack;
end;

function TMulQuery.Origin;
var a: TArrStr;
  i: longint;
begin
  AddStack('TMulQuery.Origin',Self);
  result:=f.Origin;
  if Pos('.',result)=0 then begin
    result:=f.FieldName; GetListArg(sTABLE,a);
    for i:=low(a) to high(a) do if MulQry.IsField(Connection,a[i],result) then begin
      IncL(result,a[i]+'.'); break;
    end;
  end;
  DelStack;
end;

function TMulQuery.CreateField(const FieldName: variant; Visible: boolean = false): TField;
var i: longint;
begin
  AddStack('TMulQuery.CreateField',Self);
  case MyVarType(FieldName) of
    varBoolean: i:=NegDef;
    varString: i:=FieldDefs.IndexOf(FieldName);
    varArray: begin
      for i:=VarArrayLowBound(FieldName,1) to VarArrayHighBound(FieldName,1) do CreateField(FieldName[i]);
      i:=NegDef;
    end;
  else i:=FieldName;
  end;
  if i<0 then result:=nil
  else begin
    FreeAndNil(lsFld); result:=FieldDefs[i].CreateField(DataSet); result.Visible:=Visible;
  end;
  DelStack;
end;

function TMulQuery.CreateField(usl: boolean; const FieldName: variant; Visible: boolean = false): TField;
begin
  if usl then result:=CreateField(FieldName,Visible) else result:=nil;
end;

function TMulQuery.CreateField(ls: TMQFieldList; const FieldName: variant; Visible: boolean = false): TField;
begin
  result:=CreateField(ls.IsField(FieldName),FieldName,Visible);
end;

function TMulQuery.FieldCreate;
var i: longint;
  a: array[1..2] of string;
begin
  AddStack('TMulQuery.FieldCreate',Self);
  i:=FieldDefs.IndexOf(FieldName);
  if i<0 then begin
    if not Assigned(NoIB) or (DataSet is TIBQuery) then NoIB:=IB;
    result:=NoIB.Create(Self); result.FieldName:=FieldName; result.Calculated:=true; result.DataSet:=DataSet;
  end
  else begin
    FreeAndNil(lsFld); result:=FieldDefs[i].CreateField(DataSet);
  end;
  if (DisplayLabel='') and not result.Calculated then begin
    LsArrFill(Origin(result),a,'.'); result.DisplayLabel:=FRup(GetPrimFld(a[1],a[2]));
  end
  else result.DisplayLabel:=DisplayLabel;
  DelStack;
end;

function TMulQuery.CreateIntegerField;
begin
  AddStack('TMulQuery.CreateIntegerField',Self);
  result:=pointer(FieldCreate(FieldName,DisplayLabel,TFIBIntegerField,TIntegerField));
  result.DisplayWidth:=DisplayWidth;
  DelStack;
end;

function TMulQuery.CreateFloatField;
begin
  AddStack('TMulQuery.CreateFloatField',Self);
  result:=pointer(FieldCreate(FieldName,DisplayLabel,TFIBFloatField,TFloatField));
  SetNumField(result,nLen,nDec);
  DelStack;
end;

function TMulQuery.CreateStringField;
begin
  AddStack('TMulQuery.CreateStringField',Self);
  result:=pointer(FieldCreate(FieldName,DisplayLabel,TFIBStringField,TStringField));
  if result.Calculated then result.Size:=Size
  else if Size>0 then result.DisplayWidth:=Size;
  result.Alignment:=Alignment;
  DelStack;
end;

function TMulQuery.CreateDateField;
begin
  AddStack('TMulQuery.CreateDateField',Self);
  result:=pointer(FieldCreate(FieldName,DisplayLabel,TDateTimeField));
  result.DisplayFormat:=DisplayFormat; result.DisplayWidth:=DisplayWidth; result.Alignment:=taCenter;
  DelStack;
end;

function TMulQuery.CreateMonthField;
begin
  AddStack('TMulQuery.CreateMonthField',Self);
  result:=CreateDateField(FieldName,DisplayLabel,'mm/yyyy',7);
  DelStack;
end;

function TMulQuery.CreateBooleanField;
begin
  AddStack('TMulQuery.CreateBooleanField',Self);
  result:=pointer(FieldCreate(FieldName,DisplayLabel,TBooleanField)); result.DisplayWidth:=1;
  DelStack;
end;

function TMulQuery.FldDuplicate;
begin
  {$IFDEF STACKALL}AddStack('TMulQuery.FldDuplicate',Self);{$ENDIF}
  result:=nmf+IfThen(n>0,StrNum(IfThen(not(Connection is TIBDatabase),'_'),n));
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TMulQuery.ShowErr;
var Capt,s: string;
begin
  AddStack('TMulQuery.ShowErr',Self);
  s:=Text; Capt:='';
  if Assigned(E) then begin
  	Capt:='Ошибка выполнения SQL-запроса'; IncD(s,CRLF+E.Message);
  end;
  EdTextView(Capt,s);
  DelStack;
end;

function TMulQuery.GetContent;
var nc: longint;
  ac: array of record
    f: TField;
    l: longint;
    ld: boolean;
  end;
  function fStr: string;
  begin
    AddStack('TMulQuery.GetContent.fStr',Self);
    with ac[nc],f do
      if ld then
        if MyVarType(Value)=varDate
        then result:=FormatDateTime('dd/mm/yyyy hh:nn:ss:zzz',Value)
        else result:=''
      else result:=TrimRight(AsString);
    DelStack;
  end;
var bm: TBookMark;
  al: TArrBool;
  nl,lv: longint;
  fl: boolean;
  s: string;
begin
  AddStack('TMulQuery.GetContent',Self);
  DisableControls; SetLength(ac,FieldCount); nc:=0;
  for nl:=0 to FieldCount-1 do if Fields[nl].Visible then with ac[nc] do begin
    f:=Fields[nl]; l:=0; ld := UnDataType(f)=ftDate; Inc(nc);
  end;
  SetLength(ac,nc); nl:=RecordCount; SetLength(al,nl);
  if nl>0 then ZeroMemory(@al[0],nl*SizeOf(al[0]));
  result:=Msg+CRLF+TrimRight(Text); fl:=false; bm:=GetBookMark;
  try
    First;
    for nl:=low(al) to high(al) do begin
      for nc:=low(ac) to high(ac) do with ac[nc] do begin
        lv:=Length(fStr);
        if lv>0 then begin
          al[nl]:=true; MaxSelf(l,lv);
        end;
      end;
      if al[nl] then fl:=true;
      Next;
    end;
    if fl then begin
      nc:=low(ac); lv:=Length(ac);
      while nc<lv do with ac[nc] do
        if l=0 then begin
          Dec(lv);
          for nl:=nc+1 to lv do ac[nl-1]:=ac[nl];
        end
        else begin
          MaxSelf(l,Trim(f.DisplayLabel)); Inc(nc);
        end;
      SetLength(ac,lv); s:='';
      for nc:=low(ac) to high(ac) do with ac[nc] do IncD(s,Padr(Trim(f.DisplayLabel),l)+'|');
      DecLen(s); IncD(result,CRLF+s+CRLF+StringOfChar('-',Length(s)));
      First;
      for nl:=low(al) to high(al) do begin
        s:='';
        for nc:=low(ac) to high(ac) do with ac[nc] do IncD(s,'|'+Padr(fStr,l));
        IncD(result,CRLF+Copy(s,2,MaxInt)); Next;
      end;
    end;
    GotoBookMark(bm);
  finally
    FreeBookMark(bm);
  end;
  EnableControls;
  DelStack;
end;

procedure TMulQuery.OutStackQry;
begin
  ProtSQLStrAdd(GetContent(Msg),true);
end;

class procedure TMulQuery.AddTablesFreeHandle;
var i: longint;
begin
  AddStack('TMulQuery.AddTablesFreeHandle');
  SortStrListCreate(LsTablesFreeHandle);
  for i:=low(aTables) to high(aTables) do LsTablesFreeHandle.Add(aTables[i]);
  DelStack;
end;

procedure TMulQuery.SaveTo(var result: TArrStr; Opt: TMQSaveToOptions = []; Field: TField = nil; const sbeg: string = '');
var l,i: longint;
  s: string;
begin
  AddStack('TMulQuery.SaveTo(as)');
  PointerDef(pointer(Field),Fields[0]); l:=RecordCount; i:=IfThen(mqsvNoClr in Opt,Length(result)); SetLength(result,i+l);
  for l:=1 to l do begin
    s:=sbeg;
    if mqsvNoTrimRight in Opt then IncD(s,FieldAsVariant(Field))
    else if mqsvQQ in Opt then
      if UnDataType(Field)=ftString then s:=QQs(s+Field.AsString) else s:=VarTos(Field,vsQQ)
    else IncD(s,TrimRight(Field.AsString));
    result[i]:=s; Next; Inc(i);
  end;
  DelStack;
end;

procedure TMulQuery.SaveTo(var result: TArrInt; l: PLongInt = nil; Field: TField = nil);
var i: longint;
  fl: boolean;
begin
  AddStack('TMulQuery.SaveTo(ai)');
  i:=RecordCount;
  if SetPLongInt(l,i) then fl := Length(result)<i else fl:=true;
  if fl then SetLength(result,i);
  PointerDef(pointer(Field),Fields[0]);
  for i:=0 to i-1 do begin
    result[i]:=Field.AsInteger; Next;
  end;
  DelStack;
end;

procedure TMulQuery.SaveTo(result: TStringList; lClr: boolean = true);
var l: longint;
begin
  AddStack('TMulQuery.SaveTo(sl)');
  l:=RecordCount; First; result.BeginUpdate;
  if lClr then result.Clear;
  result.Capacity:=result.Count+l;
  for l:=1 to l do begin
    result.Add(Fields[0].AsString); Next;
  end;
  result.EndUpdate;
  DelStack;
end;

procedure TMulQuery.SaveTo(result: TIntegerList; lClr: boolean = true);
var l: longint;
begin
  AddStack('TMulQuery.SaveTo(il)');
  l:=RecordCount; First;
  if lClr then result.Clear;
  result.Capacity:=result.Count+l;
  for l:=1 to l do begin
    result.Add(Fields[0].AsInteger); Next;
  end;
  DelStack;
end;

procedure TMulQuery.SaveTo(var result: variant);
var l: longint;
  f: TField;
begin
  AddStack('TMulQuery.SaveTo(v)');
  l:=RecordCount;
  if l=0 then result:=false
  else begin
    result:=VarArrayCreate([1,l],varVariant); f:=Fields[0];
    for l:=1 to l do begin
      if f is TIntegerField then result[l]:=f.AsInteger else result[l]:=f.AsString;
      Next;
    end;
  end;
  DelStack;
end;

function TMulQuery.FldDataType;
begin
  AddStack('TMulQuery.FldDataType',Self);
  result:=UnDataType(Fields[i]);
  DelStack;
end;

function TMulQuery.CntRec;
var bm: TBookMark;
begin
  AddStack('TMulQuery.CntRec',Self);
	if IsSQLBased(Connection) and not Filtered then result:=RecordCount
  else begin
    result:=0; bm:=GetBookMark;
    try
      First;
      while not Eof do begin
        Next; Inc(result);
      end;
      GotoBookMark(bm);
    finally
      FreeBookMark(bm);
    end;
  end;
  DelStack;
end;

function TMulQuery.QryCur: TMulQuery;
begin
  AddStack('TMulQuery.QryCur',Self);
  if Assigned(Self) then result:=Self else result:=CurQuery;
  DelStack;
end;

class function TMulQuery.QryCur(var q: TMulQuery): TMulQuery;
begin
  q:=q.QryCur; result:=q;
end;

class function TMulQuery.QryCur(var q: TObject): TObject;
begin
  if not Assigned(q) then q:=CurQuery;
  result:=q;
end;

function TMulQuery.ModelCreateFields;
begin
  AddStack('TMulQuery.ModelCreateFields');
  result:=CreateStringField('CMODEL','Основа',15);
  CreateField(fMODEL).DisplayLabel:=result.DisplayLabel; CreateField(fNMODEL);
  DelStack;
end;

class procedure TMulQuery.ModelCalcFields;
var s: string;
begin
  AddStack('TMulQuery.ModelCalcFields');
  with MulQueryOwner(DataSet) do begin
    s:=TrimRight(FindField(fMODEL).AsString);
    if s<>'' then BracketIntSelf(s,FindField(fNMODEL).AsInteger);
    FindField('CMODEL').AsString:=s;
  end;
  DelStack;
end;

function TMulQuery.ReplDateBigEmpty;
begin
  result:=My_pr.ReplDateBigEmpty(FindField(nmf));
end;

function TMulQuery.ReplDateNullEmpty;
begin
  result:=My_pr.ReplDateNullEmpty(FindField(nmf));
end;

{ TUnQuery }
constructor TUnQuery.Create;
begin
  AddStack('TUnQuery.Create');
  inherited Create(AOwner);
  FirstActive:=-1;
  DelStack;
end;

destructor TUnQuery.Destroy;
begin
	AddStack('TUnQuery.Destroy',Self);
	Close;
  inherited Destroy;
  DelStack;
end;

procedure TUnQuery.SetConnection;
var i: longint;
begin
	AddStack('TUnQuery.SetConnection',Self);
  if FConnection<>Value then begin
    FConnection:=Value;
    //if Assigned(Value) then Value.FreeNotification(Self);
    for i:=low(aq) to high(aq) do aq[i].Connection:=Value;
  end;
  DelStack;
end;

procedure TUnQuery.Notification;
begin
  AddStack('TUnQuery.Notification',Self);
	inherited Notification(AComponent,Operation);
  if (AComponent=FConnection) and (Operation=opRemove) then FConnection:=nil;
  DelStack;
end;

procedure TUnQuery.SetRecno;
var i: longint;
begin
	AddStack('TUnQuery.SetRecno',Self);
  FFRecNo:=cValue;
  for i:=low(aq) to high(aq) do with aq[i] do
    if Active then
      if cValue>RecordCount then Dec(cValue,RecordCount)
      else begin
        First; MoveBy(cValue-1); PartIndex:=i; break;
      end;
  DelStack;
end;

procedure TUnQuery.PartSelect(const table: string; const c_list: array of variant;
  const nmf: string; const azn: array of string; Opt: TUnQuerySelOpt = [];
  const where: string = ''; const o_list: string = ''; const StatCapt: string = '');
var awhere: TArrStr;
	j: longint;
  Def: TUnQueryDef;
begin
  AddStack('TUnQuery.PartSelect(list)',Self);
  Close;
  if nmf='' then
    if Length(azn)=0 then CopyFrom(awhere,'') else CopyFrom(awhere,azn)
  else FldInList(awhere,nmf,azn,NegDef,IfThen(unqNot in Opt,flsNot)+[flsUnique]);
  SetLength(Def,Length(awhere));
  for j:=low(Def) to high(Def) do begin
    Def[j].table:=table; CopyFromVArr(Def[j].c_list,c_list);
    Def[j].where:=DlmBetween(where,awhere[j],sAND);
    Def[j].o_list:=o_list; Def[j].g_list:='';
  end;
  PartSelect(Def,not(unqNoOpen in Opt),StatCapt);
  DelStack;
end;

procedure TUnQuery.PartSelect(const Def: TUnQueryDef;
  lOpen: boolean = true; const StatCapt: string = '');
var j: longint;
begin
  AddStack('TUnQuery.PartSelect',Self);
  Close; j:=Length(Def);
  if j>0 then begin
		PartCount:=j; j:=Length(aq);
		if PartCount>j then begin
    	SetLength(aq,PartCount);
      for j:=j to high(aq) do aq[j]:=TMulQuery.CreateConnection(Self,FConnection);
    end;
    for j:=low(Def) to high(Def) do with Def[j] do
      aq[j].PartSelect(table,c_list,where,o_list,g_list,false);
    if lOpen then Open(StatCapt);
  end;
  DelStack;
end;

procedure StUnQueryOpen(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var UnQuery: TUnQuery;
begin
  AddStack('mulqry.StUnQueryOpen');
  UnQuery:=PointerVar(Params[0]);
  with UnQuery do begin
    PartIndex:=0;
    while PartIndex<PartCount do begin
      Sender.SayStat((PartIndex+1)/PartCount);
      if OpenPart then if FirstActive<0 then begin
        FirstActive:=PartIndex;
        if UniDirectional then break;
      end;
      Inc(PartIndex);
    end;
  end;
  DelStack;
end;

procedure TUnQuery.Open; // Выполнять только 1 раз после PartSelect(...,lOpen=false)
begin
  AddStack('TUnQuery.Open',Self);
  ShowStat(StatCapt,StUnQueryOpen,[longint(Self)],
    IfThen(not((PartCount>50) and (StatCapt<>'')),stNoShow)+[stNoCanEsc]);
  First;
  DelStack;
end;

function TUnQuery.OpenPart;
var opart,otxt: string;
  rc: longint;
begin
  AddStack('TUnQuery.OpenPart',Self);
  with aq[PartIndex] do begin
    if Self.BufferChunks then begin
      opart:=Part; otxt:=MulPar.Text; BufferChunks:=0; rc:=PartCount('',string(Arg[sWHERE]));
      MulPar.Text:=otxt; SetPart(opart); BufferChunks:=rc;
    end;
    Open; result:=not Eof;
    if not result then Close;
  end;
  DelStack;
end;

procedure TUnQuery.First;
begin
	FFRecNo:=1; PartIndex:=0;
  if Active then begin
    PartIndex:=FirstActive; aq[PartIndex].First;
  end;
end;

procedure TUnQuery.Last;
var i: longint;
begin
  AddStack('TUnQuery.Last');
  if Active then for i:=high(aq) downto low(aq) do with aq[i] do if Active then begin
    Last; break;
  end;
  DelStack;
end;

procedure TUnQuery.Next;
begin
	if PartIndex<PartCount then begin
  	Inc(FFRecNo); aq[PartIndex].Next;
    if aq[PartIndex].Eof then repeat
      if UniDirectional then aq[PartIndex].Close;
      Inc(PartIndex);
      if PartIndex=PartCount then break;
      if UniDirectional then if OpenPart then FirstActive:=PartIndex;
      if aq[PartIndex].Active then begin
        aq[PartIndex].First; break;
      end;
    until false;
  end;
end;

function TUnQuery.Active;
begin
  result := FirstActive>=0;
end;

function TUnQuery.Eof;
begin
  result:=IfThen(Active,PartIndex>=PartCount,true);
end;

procedure TUnQuery.Close;
var i: longint;
begin
  AddStack('TUnQuery.Close',Self);
  if Active then begin
    for i:=low(aq) to high(aq) do aq[i].Close;
    FFRecNo:=0; PartCount:=0; FirstActive:=-1;
  end;
  DelStack;
end;

function TUnQuery.NumFromName;
begin
  AddStack('TUnQuery.NumFromName',Self);
  if Active then result:=aq[FirstActive].NumFromName(nmf,i)
  else begin
  	i:=-1; result:=false;
  end;
  DelStack;
end;

{function TUnQuery.MoveBy;
var l: longint;
  step: TValueSign;
  lNeg: boolean;
begin
  AddStack('TUnQuery.MoveBy');
  result:=Distance; lNeg := Distance<0; step:=aSign[lNeg]; l:=IfThen(lNeg,-1,PartCount);
  while not((PartIndex=l) or (Distance=0)) do begin
    with aq[PartIndex] do if Active then begin
      Dec(Distance,MoveBy(Distance));
      if (Bof or Eof) then Inc(PartIndex,step);
    end
    else Inc(PartIndex,step);
  end;
  Dec(result,Distance); MaxSelf(PartIndex);
  DelStack;
end;}

function TUnQuery.Fields;
begin
	AddStack('TUnQuery.Fields',Self);
  if Active then result:=aq[min(PartIndex,PartCount-1)].Fields[i] else result:=nil;
  DelStack;
end;

function TUnQuery.FieldCount;
begin
	AddStack('TUnQuery.FieldCount',Self);
  if Active then result:=aq[FirstActive].FieldCount else result:=0;
  DelStack;
end;

function TUnQuery.FieldName;
begin
  {$IFDEF STACKALL}AddStack('TUnQuery.FieldName',Self);{$ENDIF}
  if Active then result:=aq[FirstActive].FieldName(Index) else result:='';
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TUnQuery.ValueNum;
begin
	{$IFDEF STACKALL}AddStack('TUnQuery.ValueNum',Self);{$ENDIF}
  with aq[PartIndex].Fields[i] do begin
 		result:=Value;
    if (UnDataType(DataType)=ftDate) and empty(result) then result:=DateEmpty;
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TUnQuery.ValueName;
var i: longint;
begin
  AddStack('TUnQuery.ValueName',Self);
  if NumFromName(Name,i) then result:=ValueNum(i) else result:=null;
  DelStack;
end;

function TUnQuery.IsField;
var i: longint;
begin
  {$IFDEF STACKALL}AddStack('TUnQuery.IsField',Self);{$ENDIF}
  result:=NumFromName(Name,i);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TUnQuery.DataType;
begin
  {$IFDEF STACKALL}AddStack('TUnQuery.DataType',Self);{$ENDIF}
  if Active then result:=aq[FirstActive].DataType(Index) else result:=ftUnknown;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TUnQuery.FieldLen;
begin
  {$IFDEF STACKALL}AddStack('TUnQuery.FieldLen',Self);{$ENDIF}
  if Active then result:=aq[FirstActive].FieldLen(Index) else result:=0;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TUnQuery.NotNull;
begin
  {$IFDEF STACKALL}AddStack('TUnQuery.NotNull',Self);{$ENDIF}
  if Active then result:=aq[FirstActive].NotNull(Index,p) else result:=false;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TUnQuery.RecordCount;
var i: longint;
begin
  AddStack('TUnQuery.RecordCount',Self);
  result:=0;
	for i:=low(aq) to high(aq) do
    if aq[i].Active then Inc(result,aq[i].RecordCount);
  DelStack;
end;

function TUnQuery.GetBookMark;
begin
  AddStack('TUnQuery.GetBookMark',Self);
  result.pi:=PartIndex; result.ri:=FFRecno;
	if PartIndex<PartCount then result.bm:=aq[PartIndex].GetBookMark else result.bm:=nil;
  DelStack;
end;

procedure TUnQuery.GotoBookMark;
begin
  AddStack('TUnQuery.GotoBookMark',Self);
  PartIndex:=bm.pi; FFRecno:=bm.ri;
  if Assigned(bm.bm) then aq[PartIndex].GotoBookMark(bm.bm);
  DelStack;
end;

procedure TUnQuery.FreeBookMark;
begin
  AddStack('TUnQuery.FreeBookMark',Self);
  if Assigned(bm.bm) then aq[bm.pi].FreeBookMark(bm.bm);
  DelStack;
end;

{ TDatabaseText }
constructor TDatabaseText.CreatePrm;
const lBuf=KByte;
var i,l1: longint;
  l: Int64;
	fn,s: string;
  fl: boolean;
  DataFile: TCustomDataFile;
  fls: TMQFieldList;
  fi: PMQFieldInfo;
begin
	AddStack('TDatabaseText.CreatePrm',Self);
  inherited Create(nil);
  s:=CorrDir(Path)+Table; fn:=s+DBTextExt; qSource:=Source; SvSum:=0; FRecordCount:=0; rc:=0;
  TableName:=Table; DateEmptyAsNull:=ADateEmptyAsNull;
  if Assigned(Source) then begin
  	DelFileAtr(s+'.DBF'); DelFileAtr(s+'.DB'); DelFileAtr(s+'.MB');
    FileStream:=TFileBufStream.Create(fn,fmCreate); Write(DBTextLastVers,stByte);
    if IsClass(Source,TCustomDataFile,pointer(DataFile)) then begin
      if Source is TMulQuery then fls:=GetFieldList(TMulQuery(Source).Connection,Table) else fls:=nil;
      SetLength(FFields,DataFile.FieldCount);
    end
    else begin
      fls:=GetFieldList(TComponent(Source),Table); SetLength(FFields,fls.Count);
    end;
    Write(Length(FFields),stInteger); //l:=0;
    for i:=low(FFields) to high(FFields) do with FFields[i] do begin
      if Assigned(DataFile) then begin
        Name:=DataFile.FieldName(i); DataType:=UnDataType(DataFile.DataType(i));
        Size:=DataFile.FieldLen(i); NotNull:=DataFile.NotNull(i,fls);
      end
      else begin
        Name:=fls[i]; fi:=fls.Fields(i); DataType:=fi.DataType; Size:=fi.Size;
        NotNull := mqfNotNull in fi.Options;
      end;
      WriteStr(Name); Write(DataType,stByte);
      if DataType=ftString then Write(Size,stWord);
      Write(NotNull,stBoolean);
    end;
  end
  else begin
  	FileStream:=TFileBufStream.Create(fn,fmOpenRead or fmShareDenyNone);
    FileStream.Seek(-SizeOfVar[stInteger],soFromEnd); l:=FileStream.Size-SizeOfVar[stInteger]; fl:=true;
    if l>0 then begin
      FileStream.Seek(0,soFromBeginning); SetLength(s,lBuf);
      repeat
        l1:=FileStream.Read(pointer(s)^,min(l,lBuf));
        for i:=1 to l1 do Inc(SvSum,byte(s[i]));
        Dec(l,l1);
      until l=0;
      fl := SvSum<>Read(stInteger);
    end;
    if fl then raise EDBTextError.Create('Нарушено содержимое файла '+fn);
    FileStream.Seek(-(SizeOfVar[stInteger] shl 1),soFromEnd); FRecordCount:=Read(stInteger);
    FileStream.Seek(0,soFromBeginning); Vers:=Read(stByte); tpLen:=iif(Vers<3,stByte,stWord);
    if Vers>DBTextLastVers then raise EDBTextError.Create('Некорректная версия формата файла '+fn);
    SetLength(FFields,longint(Read(stInteger)));
    for i:=low(FFields) to high(FFields) do with FFields[i] do begin
    	Name:=ReadStr; DataType:=Read(stByte);
      Size:=Read(DataType=ftString,tpLen,0); NotNull:=Read(Vers>=1,stBoolean,false);
    end;
    pzFirst:=FileStream.Position; First;
  end;
  lsFld:=TStringList.Create;
  for i:=low(FFields) to high(FFields) do lsFld.AddObject(FFields[i].Name,pointer(i));
  lsFld.Sorted:=true;
  DelStack;
end;

destructor TDatabaseText.Destroy;
begin
	AddStack('TDatabaseText.Destroy',Self);
  Close;
  inherited Destroy;
  DelStack;
end;

procedure TDatabaseText.Close;
begin
  AddStack('TDatabaseText.Close',Self);
  if Assigned(qSource) then begin
  	Write(FRecordCount,stInteger); Write(SvSum,stInteger);
  end;
  FileStream.Update(true); FileStream.Free; lsFld.Free;
  DelStack;
end;

procedure TDatabaseText.Add;
var i: longint;
  v: variant;
  DataFile: TCustomDataFile;
begin
  AddStack('TDatabaseText.Add',Self);
  DataFile:=pointer(qSource);
  for i:=low(FFields) to high(FFields) do begin
    CopyTableValueProc(ValueProc,DataFile,FFields[i].Name,DataFile.ValueNum(i),v);
    case FFields[i].DataType of
      ftInteger: Write(IsNilc(v,0),stInteger);
      ftBoolean: Write(IsNilc(v,false),stBoolean);
      ftFloat,ftDate: Write(IsNilc(v,0),stDouble);
      ftBlob,ftMemo: WriteStr(IsNilc(v,''),stInteger);
    else WriteStr(IsNilc(v,''),stWord);
    end;
  end;
  Inc(FRecordCount);
  DelStack;
end;

function TDatabaseText.RecordCount;
begin
  result:=FRecordCount;
end;

procedure TDatabaseText.First;
begin
  AddStack('TDatabaseText.First',Self);
  FileStream.Position:=pzFirst; rc:=FRecordCount; GetRec;
  DelStack;
end;

procedure TDatabaseText.Last;
begin
  raise Exception.Create('Для класса TDatabaseText временно не поддерживается метод Last');
end;

function TDatabaseText.Eof;
begin
  {$IFDEF STACKALL}AddStack('TDatabaseText.Eof',Self);{$ENDIF}
  result := rc=0;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TDatabaseText.Next;
begin
  {$IFDEF STACKALL}AddStack('TDatabaseText.Next',Self);{$ENDIF}
  if not Eof then begin
	  Dec(rc); GetRec;
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

{function TDatabaseText.MoveBy;
begin
  raise Exception.Create('Для класса TDatabaseText временно не поддерживается метод MoveBy');
end;}

function TDatabaseText.NumFromName;
begin
  {$IFDEF STACKALL}AddStack('TDatabaseText.NumFromName',Self);{$ENDIF}
  result:=lsFld.Find(nmf,i);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDatabaseText.ValueNum;
begin
  {$IFDEF STACKALL}AddStack('TDatabaseText.ValueNum',Self);{$ENDIF}
  result:=FFields[Index].Value;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDatabaseText.ValueName;
begin
  {$IFDEF STACKALL}AddStack('TDatabaseText.ValueName',Self);{$ENDIF}
  result:=FFields[lsFld.IndexOf(Name)].Value;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDatabaseText.FieldName;
begin
  {$IFDEF STACKALL}AddStack('TDatabaseText.FieldName',Self);{$ENDIF}
  result:=FFields[Index].Name;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDatabaseText.DataType;
begin
  {$IFDEF STACKALL}AddStack('TDatabaseText.DataType',Self);{$ENDIF}
  result:=FFields[Index].DataType;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDatabaseText.FieldLen;
begin
  {$IFDEF STACKALL}AddStack('TDatabaseText.FieldLen',Self);{$ENDIF}
  result:=FFields[Index].Size;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDatabaseText.NotNull;
begin
  {$IFDEF STACKALL}AddStack('TDatabaseText.NotNull',Self);{$ENDIF}
  result:=FFields[Index].NotNull;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TDatabaseText.GetRec;
var i: longint;
begin
  {$IFDEF STACKALL}AddStack('TDatabaseText.GetRec',Self);{$ENDIF}
  FPosition:=FileStream.Position;
  for i:=low(FFields) to high(FFields) do with FFields[i] do
    if Eof then case DataType of
      ftInteger: Value:=0;
      ftFloat: Value:=0.0;
      ftDate: Value:=iif(DateEmptyAsNull,null,DateEmpty);
      ftBoolean: Value:=false;
    else Value:='';
    end
    else case DataType of
      ftInteger: Value:=Read(stInteger);
      ftFloat,ftDate: begin
        Value:=Read(iif(Vers<2,stReal,stDouble));
        if DataType=ftDate then
          if DateEmptyAsNull and (Value=0) then Value:=null else TDateTimeSelf(Value);
      end;
      ftBoolean: Value:=Read(stBoolean);
      ftMemo: Value:=ReadStr(stInteger);
      ftBlob: begin
        BlobLen:=Read(stInteger); BlobPos:=FileStream.Position; FileStream.IncPosition(BlobLen);
      end;
    else Value:=ReadStr(tpLen);
    end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TDatabaseText.SetPosition;
begin
  AddStack('TDatabaseText.SetPosition',Self);
  FileStream.Position:=Value; GetRec;
  DelStack;
end;

function FCopyToBlobField(const av: array of variant): TStream;
var Field: TField;
begin
  AddStack('MulQry.FCopyToBlobField');
  Field:=PointerVar(av[0]); result:=Field.DataSet.CreateBlobStream(Field,bmWrite);
  DelStack;
end;

procedure TDatabaseText.CopyToBlobField;
//var pz: Int64;
begin
  AddStack('TDatabaseText.CopyToBlobField',Self);
  {if FFields[Index].BlobLen>0 then begin
    pz:=FileStream.Position; FileStream.Position:=FFields[Index].BlobPos;
    with Field.DataSet.CreateBlobStream(Field,bmWrite) do
      try
        CopyFrom(FileStream,FFields[Index].BlobLen);
      finally
        Free; FileStream.Position:=pz;
      end;
  end;}
  BlobCopyToStream(Index,FCopyToBlobField,[LongInt(Field)]).Free;
  DelStack;
end;

function TDatabaseText.BlobCopyToStream;
var pz: Int64;
begin
  AddStack('TDatabaseText.BlobCopyToStream',Self);
  if FFields[Index].BlobLen>0 then begin
    pz:=FileStream.Position; FileStream.Position:=FFields[Index].BlobPos;
    result:=CreateStreamProc(av);
    try
      result.CopyFrom(FileStream,FFields[Index].BlobLen);
    finally
      FileStream.Position:=pz;
    end;
  end
  else result:=nil;
  DelStack;
end;

procedure TDatabaseText.Write;
var sr: TSaveRec;
	i,l: longint;
begin
  {$IFDEF STACKALL}AddStack('TDatabaseText.Write',Self);{$ENDIF}
  VarToSvRec(Value,tp,sr); l:=SizeOfVar[tp]; FileStream.Write(sr,l);
  for i:=1 to l do Inc(SvSum,Byte(sr.s[i]));
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TDatabaseText.WriteStr;
var i,l: longint;
begin
	AddStack('TDatabaseText.WriteStr',Self);
	l:=Length(Value); Write(l,tpLen);
  if l>0 then begin
  	FileStream.Write(pointer(Value)^,l);
	  for i:=1 to l do Inc(SvSum,Byte(Value[i]));
  end;
  DelStack;
end;

function TDatabaseText.Read(tp: TSaveType): variant;
var l: longint;
	s: string;
begin
	AddStack('TDatabaseText.Read',Self);
  l:=SizeOfVar[tp]; SetLength(s,l); FileStream.Read(pointer(s)^,l); result:=StrToVar(s,tp);
  DelStack;
end;

function TDatabaseText.Read(usl: boolean; tp: TSaveType; const Def: variant): variant;
begin
  if usl then result:=Read(tp) else result:=Def;
end;

function TDatabaseText.ReadStr;
var l: longint;
begin
	AddStack('TDatabaseText.ReadStr',Self);
  l:=Read(tpLen); SetLength(result,l);
  if l>0 then FileStream.Read(pointer(result)^,l);
  DelStack;
end;

function TDatabaseText.FieldIndex;
begin
  {$IFDEF STACKALL}AddStack('TDatabaseText.FieldIndex',Self);{$ENDIF}
  result:=lsFld.IndexOf(FieldName);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDatabaseText.IsField;
begin
  {$IFDEF STACKALL}AddStack('TDatabaseText.IsField',Self);{$ENDIF}
  result := lsFld.IndexOf(FieldName)>=0;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDatabaseText.FieldCount;
begin
  AddStack('TDatabaseText.FieldCount',Self);
  result:=Length(FFields);
  DelStack;
end;

{ TIniFileData }
function IsData: boolean;
begin
  AddStack('mulqry.IsData');
  result:=InitFIni[fiSave].ReadBool('IniFileData','Data');
  DelStack;
end;

class procedure TIniFileData.Init;
begin
  AddStack('TIniFileData.Init');
  InitFIni[fiSave].WriteBool('IniFileData','Data',true); InitFIni[fiSave].UpdateFile;
  DelStack;
end;

constructor TIniFileData.Create;
begin
  AddStack('TIniFileData.Create');
  aIniFileCheck[false]:=InitFIni[fiSave];
  aIniFileCheck[true]:=TIniFileCheck.Create(ExeDir+'DATA.INI');
  IsData:=mulqry.IsData;
  IsGGI:=My_pr.IsGGI(InitFIni[fiSave].FileName);
  DelStack;
end;

class function TIniFileData.Create(var Sender: TIniFileData): TIniFileData;
begin
  if not Assigned(Sender) then Sender:=Create;
  result:=Sender;
end;

destructor TIniFileData.Destroy;
begin
  AddStack('TIniFileData.Destroy');
  aIniFileCheck[true].Free;
  inherited Destroy;
  DelStack;
end;

function TIniFileData.fWrite;
begin
  AddStack('TIniFileData.fWrite');
  result:=aIniFileCheck[IsData];
  DelStack;
end;

function TIniFileData.fRead;
var lSection,lext,lData,lChk: boolean;
  ls: TStrStrList;
  i: longint;
  sErr: string;
begin
  AddStack('TIniFileData.fRead');
  lData:=IsData;
  with aIniFileCheck[lData] do begin
    lSection:=ReadSectionList(Section,ls);
    if Ident='' then lext:=lSection
    else begin
      lChk:=false;
      if lData then
        if AnsiMatchText(Ident,[stpDatType,stpDatPswd,
        ibpPassword,ibpPath,ibpExt,ibpServerName,ibpUserName,ibpType,ibpFIBDll])
          then lChk:=true
        else if AnsiFindText(Ident,aStpDat,byte(low(aStpDat)),i)
          then lChk := ReadInteger(Section,stpDatType,byte(dbtpDriver))=i;
      if lSection then lext:=ls.Find(Ident,i) else lext:=false;
      if lChk then begin
        sErr:='';
        if lext then begin
          if ls.Value[i]='' then sErr:='пустое значение';
        end
        else if FileExists(FileName) then begin
          if Count=0
            then sErr:='пустой файл'
          else if lSection
            then sErr:=IfThen(ls.Count=0,'пустая секция','отсутствует значение')
          else sErr:='отсутствует секция';
        end
        else sErr:='отсутствует файл';
        if sErr<>''
        then OutStack(ArrayAsList(['Ошибка чтения значения из файла: '+sErr+'.',
          'Файл: '+FileName,'Секция: '+Section,'Наименование значения: '+Ident],CRLF));
      end;
      with aIniFileCheck[false] do if not lext and lData and IsGGI and FindValueIndex(Section,Ident,ls,i) then begin
        aIniFileCheck[true].WriteString(Section,Ident,ls.Value[i]); aIniFileCheck[true].UpdateFile;
        ls.Delete(i); UpdateFile; lext:=true;
      end;
    end;
  end;
  if not lext then NotD(lData);
  if lInv then NotD(lData);
  result:=aIniFileCheck[lData];
  DelStack;
end;

function TIniFileData.ReadString;
begin
  AddStack('TIniFileData.ReadString');
  result:=fRead(Section,Ident).ReadString(Section,Ident,Default);
  DelStack;
end;

function TIniFileData.ReadInteger;
begin
  AddStack('TIniFileData.ReadInteger');
  result:=fRead(Section,Ident).ReadInteger(Section,Ident,Default);
  DelStack;
end;

function TIniFileData.ReadBool;
begin
  AddStack('TIniFileData.ReadBool');
  result:=fRead(Section,Ident).ReadBool(Section,Ident,Default);
  DelStack;
end;

procedure TIniFileData.WriteString;
begin
  AddStack('TIniFileData.WriteString');
  fWrite.WriteString(Section,Ident,Value);
  DelStack;
end;

procedure TIniFileData.WriteInteger;
begin
  AddStack('TIniFileData.WriteInteger');
  fWrite.WriteInteger(Section,Ident,Value);
  DelStack;
end;

procedure TIniFileData.WriteBool;
begin
  AddStack('TIniFileData.WriteBool');
  fWrite.WriteBool(Section,Ident,Value);
  DelStack;
end;

procedure TIniFileData.UpdateFile;
begin
  AddStack('TIniFileData.UpdateFile');
  fWrite.UpdateFile;
  DelStack;
end;

procedure TIniFileData.ReadSections(Strings: TStrings);
begin
  AddStack('TIniFileData.ReadSections');
  aIniFileCheck[IsData].ReadSections(Strings);
  DelStack;
end;

function TIniFileData.ReadSections(var a: TArrStr): longint;
begin
  AddStack('TIniFileData.ReadSections');
  result:=aIniFileCheck[IsData].ReadSections(a);
  DelStack;
end;

procedure TIniFileData.ReadSectionValues;
var f: TIniFileCheck;
  ls: TStringList;
  i: longint;
begin
  AddStack('TIniFileData.ReadSectionValues');
  fRead(Section).ReadSectionValues(Section,Strings); f:=fRead(Section,'',true);
  if f.SectionExists(Section) then begin
    ls:=TStringList.Create;
    try
      f.ReadSectionValues(Section,ls);
      for i:=0 to ls.Count-1 do
        if Strings.IndexOfName(ls.Names[i])<0 then Strings.Add(ls[i]);
    finally
      ls.Free;
    end;
  end;
  DelStack;
end;

procedure TIniFileData.WriteSectionValues;
begin
  AddStack('TIniFileData.WriteSectionValues');
  fWrite.WriteSectionValues(Section,Strings);
  DelStack;
end;

procedure TIniFileData.EraseSection;
begin
  AddStack('TIniFileData.EraseSection');
  fWrite.EraseSection(Section,CompBeg);
  DelStack;
end;

procedure TIniFileData.DeleteKey;
begin
  AddStack('TIniFileData.DeleteKey');
  fWrite.DeleteKey(Section,Ident);
  DelStack;
end;

function TIniFileData.SectionExists;
begin
  AddStack('TIniFileData.SectionExists');
  result:=fRead(Section).SectionExists(Section);
  if not result then result:=fRead(Section,'',true).SectionExists(Section);
  DelStack;
end;

{ TIniFileSave }
constructor TIniFileSave.Create;
begin
  AddStack('TIniFileSave.Create');
  IsGGI:=My_pr.IsGGI(InitFIni[fiSave].FileName);
  if not IsGGI then fd:=TIniFileData.Create;
  DelStack;
end;

destructor TIniFileSave.Destroy;
begin
  AddStack('TIniFileSave.Destroy');
  fd.Free;
  inherited Destroy;
  DelStack;
end;

function TIniFileSave.ReadString;
const pref='MoveFromDATA.';
var ls: TStrStrList;
  i: longint;
  f: TIniFileCheck;
{var ls,lsd: TStrStrList;
  i,id: longint;
  f: TIniFileCheck;
  lf,lfd: boolean;}
begin
  AddStack('TIniFileSave.ReadString');
  if IsGGI then begin
    result:=Default; f:=InitFIni[fiSave];
    if f.FindValueIndex(pref+Section,Ident,ls,i) then begin
      result:=ls.Value[i]; f.WriteString(Section,Ident,result); f.DeleteKey(pref+Section,Ident);
      if IsData then with TIniFileData.Create(fd) do begin
        aIniFileCheck[true].DeleteKey(Section,Ident); UpdateFile;
      end
    end
    else if IsData then begin
      with TIniFileData.Create(fd).aIniFileCheck[true] do if FindValueIndex(Section,Ident,ls,i) then begin
        result:=ls.Value[i];
        f.WriteString(pref+Section,Ident,result); f.UpdateFile;
        DeleteKey(Section,Ident); fd.UpdateFile;
      end
      else result:=f.ReadString(Section,Ident,Default);
    end
    else result:=f.ReadString(Section,Ident,Default);
    {lf:=f.FindValueIndex(Section,Ident,ls,i);
    if IsData then with TIniFileData.Create(fd).aIniFileCheck[true] do begin
      lfd:=FindValueIndex(Section,Ident,lsd,id);
      if lfd then begin
        result:=lsd.Value[id];
        if lf then f.DeleteKey(Section,Ident);
      end;
    end
    else lfd:=false;
    if not lfd and lf then result:=ls.Value[i];}
  end
  else result:=fd.ReadString(Section,Ident,Default);
  DelStack;
end;

function TIniFileSave.ReadInteger;
begin
  AddStack('TIniFileSave.ReadInteger');
  result:=TIniFileCheck.ReadInteger(ReadString(Section,Ident),Default);
  DelStack;
end;

procedure TIniFileSave.WriteString;
begin
  AddStack('TIniFileSave.WriteString');
  if IsGGI
  then InitFIni[fiSave].WriteString(Section,Ident,Value)
  else fd.WriteString(Section,Ident,Value);
  DelStack;
end;

procedure TIniFileSave.WriteInteger;
begin
  AddStack('TIniFileSave.WriteInteger');
  if IsGGI
  then InitFIni[fiSave].WriteInteger(Section,Ident,Value)
  else fd.WriteInteger(Section,Ident,Value);
  DelStack;
end;

{ TQrySynchro }
destructor TQrySynchro.Destroy;
begin
  AddStack('TQrySynchro.Destroy');
  QryProc(qFree);
  inherited Destroy;
  DelStack;
end;

class procedure TQrySynchro.qFree;
begin
  AddStack('TQrySynchro.qFree');
  Sender.Free;
  DelStack;
end;

procedure TQrySynchro.SetKey;
var i: longint;
begin
  AddStack('TQrySynchro.SetKey');
  QryProc(qFree); i:=Length(aKey); SetLength(FItems,i); SetLength(aFld,i);
  for i:=low(FItems) to high(FItems) do FItems[i]:=TMulQuery.CreateConnection;
  CopyFrom(FKey,aKey);
  DelStack;
end;

function TQrySynchro.GetItems;
begin
  AddStack('TQrySynchro.GetItems');
  result:=FItems[Index];
  DelStack;
end;

procedure TQrySynchro.qFirst;
begin
  AddStack('TQrySynchro.qFirst');
  Sender.First; 
  if not Sender.FindField(FKey[i],aFld[i]) then aFld[i]:=Sender.Fields[0];
  DelStack;
end;

procedure TQrySynchro.First;
begin
  AddStack('TQrySynchro.First');
  QryProc(qFirst); Synchro;
  DelStack;
end;

procedure TQrySynchro.Next;
var i: longint;
  bm: TBookMark;
  v: variant;
  fl: boolean;
begin
  AddStack('TQrySynchro.Next');
  if not Eof then begin
    v:=KeyValue(0); fl:=true;
    for i:=low(FItems) to high(FItems) do with FItems[i] do begin
      bm:=GetBookMark;
      try
        Next;
        if KeyValue(i)=v then fl:=false else GotoBookMark(bm);
      finally
        FreeBookMark(bm);
      end;
      if not fl then break;
    end;
    if fl then begin
      for i:=low(FItems) to high(FItems) do FItems[i].Next;
      Synchro;
    end;
  end;
  DelStack;
end;

function TQrySynchro.Eof;
var i: longint;
begin
  AddStack('TQrySynchro.Eof');
  result:=false;
  for i:=low(FItems) to high(FItems) do
    if FItems[i].Eof then begin
      result:=true; break;
    end;
  DelStack;
end;

procedure TQrySynchro.Synchro;
var i,j: longint;
  fl: boolean;
  v: variant;
begin
  AddStack('TQrySynchro.Synchro');
  while true do begin
    for i:=low(FItems) to high(FItems) do
      while not FItems[i].Eof do begin
        fl:=false; v:=KeyValue(i);
        for j:=low(FItems) to high(FItems) do
          if j<>i then
            if v<KeyValue(j) then begin
              fl:=true; break;
            end;
        if fl then FItems[i].Next else break;
      end;
    v:=KeyValue(0); fl:=true;
    for i:=low(FItems) to high(FItems) do begin
      if FItems[i].Eof then break;
      if KeyValue(i)<>v then begin
        fl:=false; break;
      end;
    end;
    if fl then break;
  end;
  DelStack;
end;

function TQrySynchro.KeyValue;
begin
  AddStack('TQrySynchro.KeyValue');
  result:=FieldAsVariant(aFld[i]);
  //if Assigned(OnKeyValue) then OnKeyValue(FItems[i],i,result);
  DelStack;
end;

function TQrySynchro.FieldZn;
var i: longint;
  f: TField;
begin
  AddStack('TQrySynchro.FieldZn');
  result:=null;
  for i:=low(FItems) to high(FItems) do
    if FItems[i].FindField(nmf,f) then begin
      result:=FieldAsVariant(f); break;
    end;
  DelStack;
end;

function TQrySynchro.RecordCount;
var abm: TArrBookMark;
begin
  AddStack('TQrySynchro.RecordCount');
  abm:=GetBookMark;
  try
    First; result:=0;
    while not Eof do begin
      Next; Inc(result);
    end;
    GotoBookMark(abm);
  finally
    FreeBookMark(abm);
  end;
  DelStack;
end;

function TQrySynchro.GetBookMark;
var i: longint;
begin
  AddStack('TQrySynchro.GetBookMark');
  SetLength(result,Length(FItems));
  for i:=low(FItems) to high(FItems) do result[i]:=FItems[i].GetBookMark;
  DelStack;
end;

procedure TQrySynchro.GotoBookMark;
var i: longint;
begin
  AddStack('TQrySynchro.GotoBookMark');
  for i:=low(FItems) to high(FItems) do FItems[i].GotoBookMark(bm[i]);
  DelStack;
end;

procedure TQrySynchro.FreeBookMark;
var i: longint;
begin
  AddStack('TQrySynchro.FreeBookMark');
  for i:=low(FItems) to high(FItems) do FItems[i].FreeBookMark(bm[i]);
  DelStack;
end;

procedure TQrySynchro.QryProc;
var i: longint;
begin
  AddStack('TQrySynchro.Close');
  for i:=low(FItems) to high(FItems) do Proc(FItems[i],i);
  DelStack;
end;

function TQrySynchro.Count;
begin
  AddStack('TQrySynchro.Count');
  result:=Length(FKey);
  DelStack;
end;

procedure PrimFldProc(const tbl,nmf: string; var prim: string; var PrimSave: boolean);
var lSetDbs: boolean;
  p: TDWPostList;
  fio: TFio;
label lend;
begin
  AddStack('mulqry.PrimFldProc');
  if PrimFld(prim,nmf,
    [fFNAME     ,fEDOEXE              ,fIP       ,fMODEL  ,fNAME         ,fNMODEL              ,fMDPrefix   ,fTXT        ,fUPNAME                          ,fUSERNAME         ,fUSERNUM           ],
    ['имя файла','номер программы ЭДО','IP-адрес','основа','наименование','номер версии основы','вид основы','содержимое','наименование в верхнем регистре','имя пользователя','номер регистрации']) then goto lend;
  if tbl=tFAQ then if PrimFldNum(prim,nmf,'Q','вопрос, %d уровень') then goto lend;
  for lSetDbs:=false to true do
    if (tbl=aDbsTbl[lSetDbs].dbs) then if PrimFld(prim,nmf,
      ['F_DEFAULT'            ,'FLD_ALIGN','FLD_DEC' ,fDbsFIELD,'FLD_SIZE','FLD_SPACE'         ,'FLD_TYPE','KEYORD'              ,'NOTNULL'                   ,'PRIM'      ,fDbsTABLE,fDbsVERS],
      ['значение по умолчанию','прижатие' ,'точность','поле'   ,'длина'   ,'символ-заполнитель','тип'     ,'номер ключевого поля','обязательно для заполнения','примечание','таблица','версия'])
      then goto lend;
  for p:=low(aDWPost) to high(aDWPost) do if PrimFld(prim,nmf,DWMem(p),aDWPost[p].nm) then goto lend;
  for fio:=low(aFio) to high(aFio) do with aFio[fio] do if PrimFld(prim,nmf,f,nm) then goto lend;
lend:
  DelStack;
end;

procedure Register;
begin
	RegisterComponents('OurLib',[Tmulquery]);
end;

procedure Final;
var i: longint;
begin
	AddStack('MulQry.Final');
  LsTablesFreeHandle.Free;
  if Assigned(LsDB) then begin
    for i:=0 to LsDB.Count-1 do FLsDBClearDB(i);
    LsDB.Destroy;
  end;
  DelStack;
end;

initialization
  AddStack('mulqry.initialization');
  MyTypes.GetFieldInfo:=GetFieldInfo;
  AddFrom(PrimFldProc);
  DelStack;
finalization
  Final;
end.
