unit Recdb;

interface

{$I LIBTEST}

uses
  Classes,Controls,DB,
  MyTypes,My_pr,RecVal,MulQry;

type
  TRecDB = class;

  TRDBNewRec = procedure(Sender: TRecDB; lcopy: boolean; const gKey: string) of object;
  TRDBKodNext = function(Sender: TRecDB; const NmFld,Flt: string): string of object;
  TRDBKodCheck = function(Sender: TRecDB; const NmFld,Flt: string; Opt: TKodCheckOptions): boolean of object;

  TRDBTrnsCanEvent = function(Sender: TRecDB; lmod: boolean): boolean of object;
  TRDBTrnsTableEvent = function(Sender: TRecDB): variant of object;
  TRDBTrnsExecEvent = procedure(Sender: TRecDB; Qry: TMulQuery; lmod: boolean) of object;

  TRDBClistAdd = procedure(Sender: TRecDB; f: TFld; const nmFld: string;
  	const Prm: array of variant; var lDone: boolean);

  TRDBFldGetRec = array[TFldMemoAttr] of record
    af: TArrFld;
    agk: TArrCard;
    ares: TArrStr;
    Len: longint;
  end;

  TRDBRecno = record
  	r: TRecDB;
    recno: longint;
  	af: TArrFldVal;
    Def: string;
  end;

  PRDBSaveInf = ^TRDBSaveInf; TRDBSaveInf = array of TRDBRecno;

  TRDBRecnoList = class
  private
    a: TRDBSaveInf;
  end;

  TRecDBDef = class;

  TMemGkDef = record
    tbl,nmf,where,ka: string;
    fa: TFldMemoAttr;
    f: TField;
    rdb: TRecDBDef;
  end;
  TMemGkDefArr = array of TMemGkDef;

  TAddDefArr = procedure(Sender: TObject; var ad: TMemGkDefArr);

  PMemGkList = ^TMemGkList;
  TMemGkList = class(TObject)
  private
    SelFlt: TArrArrVar;
  public
    FRdb: TRecDB;
    FQuery: TMulQuery;
    als: array[TFldMemoAttr] of record
      ls: TIntegerList;
      amem: TArrField;
      ares: TArrStr;
    end;
    // Если q.Active, Free делается автоматом при закрытии q
  	constructor Create(const rdb: array of TRecDB; q: TMulQuery = nil; qDop: TMulQuery = nil;
      paNmFld: PArrStr = nil; lDeshifr: boolean = true; DefOption: TMemGkDefOption = mgdAll;
      const fDef: string = ''; lsmDef: TMemGkList = nil; ais: TFldMemoAttrSet = FldMemoAttrAll;
      PrAddDefArr: TAddDefArr = nil; DWTypeManyProc: pointer = nil; const gWhere: string = ''); overload;
  	constructor Create(const rdb: array of TRecDBDef; q: TMulQuery = nil; qDop: TMulQuery = nil;
      paNmFld: PArrStr = nil; lDeshifr: boolean = true; DefOption: TMemGkDefOption = mgdAll;
      const fDef: string = ''; lsmDef: TMemGkList = nil; ais: TFldMemoAttrSet = FldMemoAttrAll;
      PrAddDefArr: TAddDefArr = nil; DWTypeManyProc: pointer = nil; const gWhere: string = ''); overload;
    // Без rdb в q.Arg[sC_LIST] или в paNmFld д.б. только текстовые поля MEMO
  	constructor Create(q: TMulQuery = nil; qDop: TMulQuery = nil;
      paNmFld: PArrStr = nil; lDeshifr: boolean = true;
      const fDef: string = ''; lsmDef: TMemGkList = nil; ais: TFldMemoAttrSet = FldMemoAttrAll;
      PrAddDefArr: TAddDefArr = nil; DWTypeManyProc: pointer = nil; const gWhere: string = ''); overload;
    class function AddDef(const tbl,nmf: string; const where: string = ''; fa: TFldMemoAttr = famMemo;
      f: TField = nil; const ka: string = ''; rdb: TRecDBDef = nil): TMemGkDef;
  	constructor Create(const aDef: array of TMemGkDef; qDop: TMulQuery; lDeshifr: boolean = true;
      const fDef: string = ''; lsmDef: TMemGkList = nil;
      PrAddDefArr: TAddDefArr = nil; DWTypeManyProc: pointer = nil; const gWhere: string = ''); overload;
    destructor Destroy; override;
    procedure DestroyFromQuery;
    function GetValue(gk: longword; fa: TFldMemoAttr = famMemo): string;
    procedure GetFromQuery(const nmrecno: string = fRECNO; lsDupl: TStringList = nil;
      aisGet: TFldMemoAttrSet = []; ais: TFldMemoAttrSet = FldMemoAttrAll);
  end;

  TDelMemoProc = function(const nmf: string; fa: TFldMemoAttr): boolean of object;
  
  TRecDBGetOpt = set of (rgetNoDupl);
  TRDBSetMemOpt = set of (memNoDelPrior,memNoShifr,memClrGK);

	TRecDB = class(TCustomRec)
	private
   	FNameDB,FMsgCheck,FPrim: string;
    FOnDopEditProc: TButClickEvent;
    FOnNewRec: TRDBNewRec;
    FOnKodNext: TRDBKodNext;
    FOnKodCheck: TRDBKodCheck;
    FOnSeekMsg: TStringEvent;
    FOnTrnsCan: TRDBTrnsCanEvent;
    FOnTrnsTable: TRDBTrnsTableEvent;
    FOnTrnsExec: TRDBTrnsExecEvent;
    FOnTrnsEnd,FOnBeforeMemRead: TNotifyEvent;
		FFRecNo {Конфликтует с fRECNO}: LongInt;
    FDateWithTime,lUpdate: boolean;
		function GetConnection: TComponent;
		function GetMemGK(const nmf: string): longword;
		procedure SetConnection(Value: TComponent);
		procedure SetRecno(Value: longint);
		procedure SetMemGK(const nmf: string; gk: longword);
    procedure SetNameDB(const v: string); virtual;
    procedure FSetPrim(const v: string);
		procedure ClearSQL;
		procedure FldGetRec(q: TMulQuery; var i: longint; lMemo: boolean; lsDupl: TStringList); virtual;
		procedure FldAddList(i: longint; var a: TRDBFldGetRec); virtual;
    function FldUpdate(const PartSQL: string; lmod,lLog: boolean; MemGkSet: PMemGkSet;
      pRowsAffected: PLongInt; const where: string): boolean;
    function FFldUpdate(const PartSQL: string; lmod: boolean; MemGkSet: PMemGkSet;
      var af: TArrBool; const logp: string; pRowsAffected: PLongInt; const where: string): boolean; virtual;
    function AddCListProc(PrAdd: TRDBClistAdd; f: TFld; const nmFld: string; const Prm: array of variant): boolean;
		procedure FAddCList(q: TMulQuery; const Prm: array of variant;
    	PrAdd: TRDBClistAdd; f: TFld; const tbl,nmf: string);
		procedure FSetMem(f: TFld; const nmf: string; var a: TRDBFldGetRec;
    	fa: TFldMemoAttr; const faPrm: string); virtual;
		class procedure FDelMemValue(gk: longword; var a: TRDBFldGetRec;
      fa: TFldMemoAttr; const faPrm: string); virtual;
		function GetDelMemKA(fa: TFldMemoAttr; f: TField): string; virtual;
		class procedure FGetMemGK(f: TFld; var result: longword); virtual;
		class function FSetMemGKVal(f: TFld; gk: longword; const v: string): string;
  protected
    function FCreateFld(const AName: string; AType: TFieldType;
     	ASize: longint; const AValue: variant): TFld; override;
		function GetRec(q: TMulQuery; rec: longint; Opt: TRecDBGetOpt = []; const nmrecno: string = fRECNO;
      lsDupl: TStringList = nil; ais: TFldMemoAttrSet = FldMemoAttrAll): boolean; virtual;
		procedure MsgFld(nOper: TFldOper); override;
	 	procedure FCloseRec; override;
    function FldSetValue(Sender: TFld; var v: variant; Oper: TFldSetValueOper): boolean; override;
    procedure FLogPrim(var Prm: TLogTrnsValPrm; Oper: TLogPrimOper; const av: array of variant; var ap: TArrVar); override;
  public
   	FQuery: TMulQuery;
    FixRecnoMsg: string;
    NoMemo: boolean;
    OnGetMemPrm: procedure(Sender: TRecDB; i: longint; fa: TFldMemoAttr; var faPrm: string);
   	property MemGk[const nmf: string]: longword read GetMemGk write SetMemGk;
   	property RecNo: longint read FFRecNo write SetRecNo;
   	constructor Create(AOwner: TComponent = nil); override;
   	constructor CreateFrom(r: TRecDB); virtual;
    //procedure Assign(Source: TPersistent); override;
	 	function OpenRec: boolean; override;
	 	function GotoRec(rec: longint): boolean; overload;
	 	function GotoRec(f: TField): boolean; overload;
	 	function GotoRec(q: TMulQuery): boolean; overload;
	 	function GotoRec: boolean; overload;
		function UpdateRec(lLog: boolean = false; MemGkSet: PMemGkSet = nil;
      pRowsAffected: PLongInt = nil; const where: string = ''): boolean;
    function AppRec(lLog: boolean = false; nRec: longint = 0; const PartSQL: string = sI_TABLE;
      MemGkSet: PMemGkSet = nil): TMulQuery;
    function AppUpdRec(lLog: boolean = false): boolean;
    procedure AppRecConstraint(lLog: boolean = false);
    procedure GetFieldsModified(var af: TArrBool; lmod: boolean = true);
    function DelRec(const where: string = ''; Opt: TRDBDelOpt = []): boolean; overload; virtual;
    function DelRec(const azn: array of string; l: longint = NegDef;
      const nmf: string = fRECNO; Opt: TRDBDelOpt = []; const where: string = ''): boolean; overload;
    function DelRec(const azn: array of integer; l: longint = NegDef;
      const nmf: string = fRECNO; Opt: TRDBDelOpt = []; const where: string = ''): boolean; overload;
    function DelRec(ls: TIntegerList;
      const nmf: string = fRECNO; Opt: TRDBDelOpt = []; const where: string = ''): boolean; overload;
    function DelRecList(const awhere: array of string; Opt: TRDBDelOpt = []; const where: string = ''): boolean;
		function Seek(const where: string; const order: string = ''; Opt: TRDBSeekOpt = []): boolean;
		function SeekMsg(const where,msg: string): boolean;
    procedure UpdateTable(const c_list,v_list: array of variant;
      const where: string = ''; pRowsAffected: PLongInt = nil);
    procedure UpdateTableFldList(const c_list,v_list: array of variant;
      const azn: array of string; l: longint = NegDef; const nmf: string = fRECNO; Opt: TFldInListOpt = [];
      const where: string = ''); overload;
    procedure UpdateTableFldList(const c_list,v_list: array of variant;
      ls: TIntegerList; const nmf: string = fRECNO; const where: string = ''); overload;
    procedure UpdateTableList(const c_list,v_list: array of variant;
      const awhere: array of string; const where: string = '');
    procedure LogPrim(var a: TArrStr; q: TMulQuery = nil); overload;
    procedure LogPrim(var a: TArrStr; var h: longint; q: TMulQuery = nil; lMemo: boolean = true); overload;
    procedure LogWrite(const a: TArrStr; const sbeg: string = ''); overload;
    procedure LogWrite(const a: TArrStr; h: longint; const sbeg: string = ''); overload;
    procedure LogWrite(Opt: TLogPrimOptions = [logpKey]; af: PArrBool = nil); overload;
    procedure LogWrite(const prim: string); overload;
		procedure GetFromQuery(q: TMulQuery = nil; lMemo: boolean = true; const nmrecno: string = fRECNO;
      lsDupl: TStringList = nil);
		class procedure SetMemValue(gk: longword; const vv: string; q: TMulQuery;
    	Opt: TRDBSetMemOpt = []; fa: TFldMemoAttr = famMemo; const faPrm: string = '';
      const sTbl: string = ''; const sFld: string = ''); virtual;
		procedure AddCList(q: TMulQuery; const Prm: array of variant;
    	PrAdd: TRDBClistAdd = nil; Opt: TRDBAddCListOpt = []); overload; virtual;
		function AddDop(q: TMulQuery = nil): longint;
	 	procedure NewRec(Opt: TRDBNewOpt = []; const gKey: string = ''); overload;
	 	procedure NewRec(fa: TFormAction; const gKey: string = ''); overload;
		procedure DoNewRec(lCopy: boolean = false; const gKey: string = ''); overload; dynamic;
		procedure DoNewRec(Proc: TRDBNewRec; lCopy: boolean = false; const gKey: string = ''); overload;
    function KodNext(const NmFld: string; const Flt: string = ''; l: longint = 0;
      const ctbl: string = ''; BegNum: longint = 0): string; dynamic;
    procedure KodNextSelf(const NmFld: string; const Flt: string = ''; l: longint = 0;
      const ctbl: string = ''; BegNum: longint = 0);
    function KodCheck(const NmFld: string; const Flt: string = ''; const cMsg: string = '';
      Opt: TKodCheckOptions = []; ProcMsgEq: TNotifyEvent = nil; const ctbl: string = ''): boolean; dynamic;
		function DelMemo(const where: string; Proc: TDelMemoProc = nil): boolean;
		function GetMaxFld(const nmFld: string = fRECNO; const nmTbl: string = '';
    	pVal: PLongInt = nil; lSave: boolean = false; const where: string = ''): longint; virtual;
		procedure GetMaxFldSelf(const nmFld: string); virtual;
    procedure FixFldClear;
		function CompBegFixSt(const nmf: string; fa: TFldMemoAttr): boolean;
		function FixSt(const sBeg: string = sFix): string; virtual;
    function tRecno: string;
    function TblFldName(const nmf: string): string; overload;
    function TblFldName(const nmf: string; lAlias: boolean): string; overload;
		class procedure SetMemGKVal(f: TFld; gk: longword; const v: string);
		class function Init(var r,res: TRecDB; const NameDB: string;
      const MsgCheck: string = ''; PrCalculate: TRecCalcEvent = nil; PrNewRec: TRDBNewRec = nil): boolean;
		class procedure SaveInf(const a: array of TRecDB; var svi: TRDBSaveInf; lClr: boolean = true); overload;
    procedure SaveInf(var svi: TRDBSaveInf; lClr: boolean = true); overload;
		class procedure RestInf(const svi: array of TRDBRecno);
    class procedure DeleteTable(const nmr: string; const where: string = '*'; q: TMulQuery = nil); //overload;
    {class procedure DeleteTable(const nmr: string; const azn: array of string;
      l: longint = NegDef; const nmf: string = fRECNO; q: TMulQuery = nil); overload;}
    function GetPrim(lRaise: boolean = true): string; 
    function GetPrimFld(const nmf: string): string;
    function LogPrimMod: string;
    procedure LogWriteMod;
    function LogVidRecno: longint;
    procedure SetLogVidRecno;
    function rRecno(lEq: boolean = true): string;
    function GetFieldList(var ls: TMQFieldList): boolean; overload;
    function GetFieldList: TMQFieldList; overload;
    procedure HelpTblAdd(var ht: THelpTbl; var n: byte; const anmf: array of string; offs: byte = 0; const prim: string = '');
  published
    property Connection: TComponent read GetConnection write SetConnection;
    property DateWithTime: boolean read FDateWithTime write FDateWithTime;
   	property MsgCheck: string read FMsgCheck write FMsgCheck;
   	property NameDB: string read FNameDB write SetNameDB;
   	property Prim: string read FPrim write FSetPrim;
    property OnBeforeMemRead: TNotifyEvent read FOnBeforeMemRead write FOnBeforeMemRead;
    property OnDopEditProc: TButClickEvent read FOnDopEditProc write FOnDopEditProc;
    property OnNewRec: TRDBNewRec read FOnNewRec write FOnNewRec;
    property OnKodNext: TRDBKodNext read FOnKodNext write FOnKodNext;
    property OnKodCheck: TRDBKodCheck read FOnKodCheck write FOnKodCheck;
    property OnSeekMsg: TStringEvent read FOnSeekMsg write FOnSeekMsg;
    property OnTrnsCan: TRDBTrnsCanEvent read FOnTrnsCan write FOnTrnsCan;
    property OnTrnsTable: TRDBTrnsTableEvent read FOnTrnsTable write FOnTrnsTable;
    property OnTrnsExec: TRDBTrnsExecEvent read FOnTrnsExec write FOnTrnsExec;
    property OnTrnsEnd: TNotifyEvent read FOnTrnsEnd write FOnTrnsEnd;
  end;

  PArrRecDB = ^TArrRecDB; TArrRecDB = array of TRecDB;
  TArrBoolRecDB = array[boolean] of TRecDB;

  PFldDefInf = ^TFldDefInf;
	TFldDefInf = record
  	Inf: TDWVidRec;
    Fld: TFld;
    AValue: variant;
  end;

  TDWRdbSeekEvent = function(Sender: TObject): TRecDBDef of object;
  TDWArrCodNameEvent = procedure(Sender: TObject; Qry: TMulQuery; var Cod,Name: string) of object;
  TDWArrSeekFldDefProc = procedure(Sender: TObject; Qry: TMulQuery; var s: string; lSave: boolean) of object;
  TDWRdbFldInfoEvent = procedure(Sender: TObject; const r: TDWVidRec; var FldInfo: TDWFldInfo) of object;

  TDWArrSeekRec = record
    RecDef,FldDef,Name,RecDat,WhereDat,FldOrd,FldOrdDop,FldDop: string;
    PrFldDef: TDWArrSeekFldDefProc;
    NoDat: boolean;
  end;
  TDWArrSeekEvent = procedure(Sender: TObject; var result: TDWArrSeekRec) of object;

  TArrvSeekOper = (arrvQryBeg,arrvDefFindBeg,arrvDefFinded,arrvDefFindEnd,arrvQryEnd);
  TArrvSeekProc = procedure(Oper: TArrvSeekOper; Prm: pointer; rdb: TRecDBDef; Qry: TMulQuery;
    const Def: TDWArrSeekRec; var aDef: TArrStr; iDef: longint; var rDef: TDWVidRec;
    const ka,Cod,CodName: string; var Changed: boolean; var Aborted: boolean);

  PArrRecDBDef = ^TArrRecDBDef; TArrRecDBDef = array of TRecDBDef;

  TRecDBDef = class(TRecDB)
  private
    FDDatField,FDDatFieldCod,FArrValue,FDWPrefix,FDWName: string;
    FDDatIsCod,FLongModified,ArrCng: boolean;
    FDDatMaxLenCod: byte;
    FDynamicVid,FArrCount: longint;
    FFldDef: TStrings;
    FPart,FDef: TStringList;
    aDef: array of TFldDefInf;
    aPart: TArrPosLen;
    FFixArr: array[1..4] of string;
    FldLong: TFld;
    LsArr: PArrVar;
    aManyStr: array of TArrFld;
    aNmFixEqTbl: TArrRecDBDef;
    FOnDDatBeforeModify: TDDatBeforeModifyEvent;
    FDimDDatModify: array[1..2] of TDDatModifyEvent;
    FOnDWArrCodName: TDWArrCodNameEvent;
    FOnDWArrSeek: TDWArrSeekEvent;
    FOnDWCanDel: TDWCanDelEvent;
    FOnDWCngName: TDWCngNameEvent;
    FOnDWVarValid: TDWVarValidEvent;
    FOnDWSeek: TNotifyEvent;
    FOnDWTrans: TDWTransEvent;
    FOnDWFldInfo: TDWRdbFldInfoEvent;
    FOnDWFldSeek: TDWFldSeekEvent;
    FOnDWRdbSeek: TDWRdbSeekEvent;
		function GetArrValue: string;
    function GetDop_: string;
		function GetFixArr(Index: longint): string;
    procedure GetLongVal;
		function FGetLongVal: string;
    procedure SetArrCount(Value: longint);
		procedure SetArrValue(const cv: string);
    procedure SetDop_(const v: string);
		procedure SetFixArr(Index: longint; const v: string);
    procedure SetLongVal;
    procedure SetNameDB(const v: string); override;
	 	procedure SetFldDef(v: TStrings);
    procedure SetDynamicVid(Value: longint);
    procedure SetDDatMaxLenCod(Value: byte);
    procedure SetDDatIsCod(Value: boolean);
    procedure SetDDatBeforeModify(Value: TDDatBeforeModifyEvent);
    function GetDimDDatModify(Index: longint): TDDatModifyEvent;
    procedure SetDimDDatModify(Index: longint; Value: TDDatModifyEvent);
    procedure SetDDat;
    function DefAdd(const sBeg: string; const td: TFldDefInf): PFldDefInf;
    procedure ClearDef;
		procedure ClearLong;
    procedure ArrClear(lFree: boolean = false);
		procedure FldGetRec(q: TMulQuery; var i: longint; lMemo: boolean; lsDupl: TStringList); override;
		procedure FldAddList(i: longint; var a: TRDBFldGetRec); override;
    function FFldUpdate(const PartSQL: string; lmod: boolean; MemGkSet: PMemGkSet;
      var af: TArrBool; const logp: string; pRowsAffected: PLongInt; const where: string): boolean; override;
		procedure FSetLongVal(const cv: string; p,l: longint);
		function GetPart(i: longint): PPosLen;
		class procedure RDBArrvCalculate(Sender: TCustomRec; lApp: boolean);
		class procedure RDBArrDWTrans(Sender: TObject; var sTrans: String; lSave: Boolean);
		procedure FSetMem(f: TFld; const nmf: string; var a: TRDBFldGetRec;
    	fa: TFldMemoAttr; const cfaPrm: string); override;
		class procedure FDelMemValue(gk: longword; var a: TRDBFldGetRec;
      fa: TFldMemoAttr; const faPrm: string); override;
		function GetDelMemKA(fa: TFldMemoAttr; f: TField): string; override;
		class procedure FGetMemGK(f: TFld; var result: longword); override;
    procedure ClearDuplModified;
  protected
    function FCreateFld(const AName: string; AType: TFieldType;
     	ASize: longint; const AValue: variant): TFld; override;
	 	function FOpenRec: boolean; override;
    procedure SetValue(const Index: string; const v: variant); override;
	 	procedure FCloseRec; override;
    function FldGetValue(Sender: TFld; var v: variant): boolean; override;
    function FldSetValue(Sender: TFld; var v: variant; Oper: TFldSetValueOper): boolean; override;
    procedure FLogPrim(var Prm: TLogTrnsValPrm; Oper: TLogPrimOper; const av: array of variant; var ap: TArrVar); override;
		function GetRec(q: TMulQuery; rec: longint; Opt: TRecDBGetOpt = []; const nmrecno: string = fRECNO;
    	lsDupl: TStringList = nil; ais: TFldMemoAttrSet = FldMemoAttrAll): boolean; override;
  public
  	DWModified,AutoFillDop: boolean;
    ArrGK: longword;
   	property ArrValue: string read GetArrValue write SetArrValue;
   	property Dop_: string read GetDop_ write SetDop_;
   	constructor Create(AOwner: TComponent = nil); override;
   	constructor CreateFrom(r: TRecDB); override;
   	destructor Destroy; override;
	 	function OpenRec: boolean; override;
    procedure CreateFld(const AName,ACod: string; AType: TFieldType;
      ASize,ADec: longint; const cValue: variant; const APrim: string); overload;
    procedure CreateFld(const AName: string; AType: TFieldType;
      ASize,ADec: longint; const cValue: variant; const APrim: string); overload;
    procedure DWArrCodName(Qry: TMulQuery; var Cod,Name: string); dynamic;
    function DWArrSeek(var res: TDWArrSeekRec): boolean; dynamic;
    function DWCanDel(const VarName,MsgName: string): boolean; dynamic;
    procedure DWCngName(const OldName,NewName: string; var result: boolean); dynamic;
		procedure DWVarValid(Proc: TProcVarValid; const r: TDWVidRec; var result: boolean); dynamic;
    procedure DWSeek; dynamic;
    procedure DWTrans(var sTrans: string; lSave: boolean); overload; dynamic; 
    function DWTrans: string; overload;
		procedure CopyFromQuery(q: TMulQuery);
		procedure CopyDopFromQuery(q: TMulQuery);
		procedure CreateFieldDop(q: TMulQuery);
		function GetDopInfo: TArrStr;
		procedure AddCList(q: TMulQuery; const Prm: array of variant;
    	PrAdd: TRDBClistAdd = nil; Opt: TRDBAddCListOpt = []); overload; override;
		class procedure AddCList(const ardb: array of TRecDBDef; q: TMulQuery = nil;
      lSet: boolean = true); overload;
		class procedure PartSelect(const ardb: array of TRecDBDef; q: TMulQuery = nil;
      const where: string = ''; const o_list: string = ''; const g_list: string = '';
      lOpen: boolean = true);
		function DWVarName(const VarName: string = ''): string; overload;
    class function DWVarName(const nmRec,nmFld: string): string; overload;
    class function DWVarName(const a: TDEPrmStr): string; overload;
    class function DWVarNameRel(const a: TDEPrmStr): string;
    function DelRec(const where: string = ''; Opt: TRDBDelOpt = []): boolean; override;
    property ArrCount: longint read FArrCount write SetArrCount;
		procedure ArrExchange(Rec1,Rec2: longint);
		procedure DWFldInfo(const r: TDWVidRec; var FldInfo: TDWFldInfo); dynamic;
  	procedure DWFldSeek(var a: TDWFldArrSeek); dynamic;
  	function DWRdbSeek: TRecDBDef; dynamic;
		function GetMaxFld(const nmFld: string; const nmTbl: string = '';
    	pVal: PLongInt = nil; lSave: boolean = false; const where: string = ''): longint; override;
		procedure DoNewRec(lCopy: boolean = false; const gKey: string = ''); overload; override;
		procedure SetDefValues;
		function FixSt(const sBeg: string = sFix): string; override;
		function IsFldFix(const nmf: string): boolean; overload;
		function IsFldFix(Index: longint): boolean; overload;
		procedure GetAFieldValueNoFldFix(var a: TArrFldVal);
		procedure SetAFieldValueNoFldFix(const a: TArrFldVal);
    function SeekArrFld(const nmf: string; var f: TFld): boolean;
		function FldDefCount: longint;
		function FldDefInf(i: longint): PFldDefInf; overload;
		function FldDefInf(const nmf: string; var pd: PFldDefInf): boolean; overload;
		function FldDefInf(f: TFld; var pd: PFldDefInf): boolean; overload;
		function ConvertDateBig(const Capt: TCaption{; const where: string = ''; q: TMulQuery = nil}): boolean;
    function SetFldDefText(const s: string = ''): boolean;
		procedure InitFldDef(const s: string; Opt: TDWWinRdbDefOpt = dwdefSeek); overload;
		procedure InitFldDef(Opt: TDWWinRdbDefOpt = dwdefSeek); overload;
    function DWSToRec(i: longint): TDWVidRec;
    function DWVidForm: TDWVidForm;
    procedure SetNmFixEqTbl(const a: array of TRecDBDef);
		class function Init(var r,res: TRecDBDef; const NameDB,NameRec,DWPrefix,DWName: string; PrDWTrans: TDWTransEvent;
      const MsgCheck: string = ''; PrCalculate: TRecCalcEvent = nil; PrNewRec: TRDBNewRec = nil;
      lOpen: boolean = true): boolean;
		class function SeekDWPrefix(const pref: string; var rdb: TRecDBDef): boolean;
		class function GetFldInf(const s: string): TFldDefInf; overload;
		function GetFldInf(i: longint): TFldDefInf; overload;
		class function GetFldInfValue(t: TDWFldType; const v: string): variant;
		class function FillValue(const v: variant; const oDef,nDef: TDWVidRec): variant;
		class procedure ClearArrDef;
		class procedure ClearArrDefCod(const ka: string);
		class function GetArrDef(const ka: string): TRDBArrDef;
		class function PGetArrDef(const ka: string; var p: PRDBArrDef): boolean; overload;
		class function PGetArrDef(const ka: string): boolean; overload;
		class procedure SetMemValue(gk: longword; const vv: string; q: TMulQuery;
    	Opt: TRDBSetMemOpt = []; fa: TFldMemoAttr = famMemo; const faPrm: string = '';
      const sTbl: string = ''; const sFld: string = ''); override;
		class procedure SaveInf(const a: array of TRecDBDef; var svi: TRDBSaveInf; lClr: boolean = true); overload;
    class function ArrRdb(const a: array of TRecDBDef): TArrRecDB;
		class function ArrDWRdbSeek(Sender: TObject): TRecDBDef;
		function FldModified(i: longint): boolean; override;
  published
    property DDatField: string read FDDatField write FDDatField;
    property DDatFieldCod: string read FDDatFieldCod write FDDatFieldCod;
    property DDatIsCod: boolean read FDDatIsCod write SetDDatIsCod;
    property DDatMaxLenCod: byte read FDDatMaxLenCod write SetDDatMaxLenCod;
   	property DWName: string read FDWName write FDWName;
   	property DWPrefix: string read FDWPrefix write FDWPrefix;
    property DynamicVid: longint read FDynamicVid write SetDynamicVid;
   	property FldDef: TStrings read FFldDef write SetFldDef;
    property NmFix_: string index 1 read GetFixArr write SetFixArr;
    property NmMem_Fix: string index 2 read GetFixArr write SetFixArr;
    property NmArr_: string index 3 read GetFixArr write SetFixArr;
    property NmSel_Fix: string index 4 read GetFixArr write SetFixArr;
   	property OnDDatBeforeModify: TDDatBeforeModifyEvent read FOnDDatBeforeModify write SetDDatBeforeModify;
   	property OnDDatModify: TDDatModifyEvent index 1 read GetDimDDatModify write SetDimDDatModify;
   	property OnDDatAfterModify: TDDatModifyEvent index 2 read GetDimDDatModify write SetDimDDatModify;
   	property OnDWArrCodName: TDWArrCodNameEvent read FOnDWArrCodName write FOnDWArrCodName;
   	property OnDWArrSeek: TDWArrSeekEvent read FOnDWArrSeek write FOnDWArrSeek;
   	property OnDWCanDel: TDWCanDelEvent read FOnDWCanDel write FOnDWCanDel;
   	property OnDWCngName: TDWCngNameEvent read FOnDWCngName write FOnDWCngName;
	 	property OnDWFldInfo: TDWRdbFldInfoEvent read FOnDWFldInfo write FOnDWFldInfo;
   	property OnDWFldSeek: TDWFldSeekEvent read FOnDWFldSeek write FOnDWFldSeek;
   	property OnDWRdbSeek: TDWRdbSeekEvent read FOnDWRdbSeek write FOnDWRdbSeek;
   	property OnDWSeek: TNotifyEvent read FOnDWSeek write FOnDWSeek;
   	property OnDWTrans: TDWTransEvent read FOnDWTrans write FOnDWTrans;
   	property OnDWVarValid: TDWVarValidEvent read FOnDWVarValid write FOnDWVarValid;
  end;

  TArrBoolRecDBDef = array[boolean] of TRecDBDef;
  TArrArrBoolRecDBDef = array of TArrBoolRecDBDef;

  TRecDBApp = class(TComponent)
  private
  	qApp,qUpd: TMulQuery;
    rFrom: TRecDb;
    NameDB: string;
    CountRec,CurRec: longint;
		procedure InsToTbl(const where: string);
  public
  	constructor CreateFrom(AOwner: TComponent; RecFrom: TRecDB);
		procedure BeforeApp;
		procedure AfterApp;
	 	procedure NewRec;
  end;

  TTblConcat = class(TMulQuery)
  private
    a: array of record
      r: TRecDB;
      lsm: TMemGkList;
      lsDupl: TStringList;
      lGet: boolean;
      fDef: string;
      nDef: longint;
      DWTypeManyProc: pointer;
    end;
  protected
		procedure DoAfterOpen; override;
		procedure DoAfterClose; override;
  public
    PrAddDefArr: TAddDefArr;
    NoMemo: boolean;
		class function CreateConnection(var Qry: TTblConcat; AOwner: TComponent; AConnection: TComponent): boolean; overload;
		class function CreateNoActive(var Qry: TTblConcat; AOwner: TComponent; AConnection: TComponent = nil): boolean; overload;
		destructor Destroy; override;
    procedure RdbInit;
    procedure RdbAdd(rdb: TRecDB; Get: boolean = true; const Def: string = ''; nLsmDef: longint = NegDef;
      ADWTypeManyProc: pointer = nil);
    procedure RdbPartSelect(const where: string = ''; const o_list: string = '';
      const tbldop: string = ''; PrAdd: TRDBClistAdd = nil; PrmAdd: pointer = nil); overload;
    procedure RdbPartSelect(const aRdb: array of TRecDB;
      const aGetExclude: array of longint; const where: string = ''; const o_list: string = '';
      const tbldop: string = ''; PrAdd: TRDBClistAdd = nil; PrmAdd: pointer = nil); overload;
    procedure RdbGetFromQuery;
    procedure RdbGetFromQueryIndex(Index: longint);
    procedure RdbNewRec;
    function LsDupl(Index: longint): TStringList;
  end;

  PFixDatRec = ^TFixDatRec;
  TFixDatRec = record
    aRec: array of record
      r: TRecDBDef;
      af: TArrStr;
    end;
    where: string;
  end;

  TFixDatStrListProc = procedure(r: TRecDBDef; p: PFixDatRec; const sFixSt: string; Prm: pointer);

  TFixDatStrList = class(TStringList)
  private
    aDat: array of TFixDatRec;
  protected
    procedure InitAll; virtual;
  public
    constructor Create(const fld: string;
      const sBeg: string = sFix; Proc: TFixDatStrListProc = nil; Prm: pointer = nil); overload;
    constructor Create(const fld: string; const ar: array of TRecDBDef;
      const sBeg: string = sFix; Proc: TFixDatStrListProc = nil; Prm: pointer = nil); overload;
    function GetDat(i: longint): PFixDatRec;
    class function IsBeg(r: TCustomRec; const beg: string; var nf: longint): boolean;
  end;

  PFldInf = ^TFldInf;
	TFldInf = record
	  DWFldInfo: TDWFldInfo;
    Vid,VName: string;
    rdb: TRecDBDef;
    Dop: Pointer;
  end;

  PFldArrDop = ^TFldArrDop;
  TFldArrDop = record
    ardb: array of record
      rdb: TRecDBDef;
      afdop: TArrField;
      afix: array of record
      	r: TDWVidRec;
        Fld: TField;
      end;
      NoRead: boolean;
    end;
    lsm: TMemGkList;
    fdefcnt: longint;
    oclist: string;
    oBeforeOpen: TDataSetNotifyEvent;
  end;

  TSelCodeGetOper = (selSetMemValue,selModified,selMemGkInit,selMemGkIsSel,selMemGkGet,selMemGkReassign,
    selMemGkTrans,selValTrans);
  TDDRecDBOper = (ddrdbOpenRec,ddrdbSetDDat,ddrdbCloseRec);
  TRDBLogPrimOper = (rdblgCreate,rdblgGetName,rdblgGetVal);

  TDWFldOpt = set of (dwfCreateVar);

const
  RDBArrNameRec = 'RDBArr';
  RDBArrPrefix = 'МД';

	aMemoTbl: TFldMemoAttrStr = (tMEMO,tARR,tSEL);
  aMemo: array[TFldMemoAttr] of record
    attr: TFldAttr;
    zn,rod,beg: string;
  end =
    ((attr:faMemo    ; zn:fMZN ; rod:'текстовых значений'; beg:sMemo)
    ,(attr:faFixArray; zn:fARRV; rod:'значений-массивов')
    ,(attr:faSel     ; zn:'COD'; rod:'значений выбора'   ; beg:sSel)
    );

var
  FixArrFromDef: boolean = true;
  CheckDopSize: boolean = true;
  RecDBDWRdbSeek: procedure(var r: TCustomRec);
  CurRdbArr: TRecDBDef;
  CurDWFld: TDWVidForm;
  SpDb: function: TRecDB;
  DWVidExec: function(rdb: TRecDBDef; pStrWhere: PString = nil; nRow: longint = NegDef): boolean;
  DWFldExec: function(const Capt: TCaption; var Value: string;
    const acRec: array of TRecDBDef; DefaultRec: TRecDBDef = nil;
    FldAccess: TProcValid = nil; Opt: TDWFldOpt = [];
    ProcCreate: TNotifyEvent = nil; PSearchInfo: PDWSearchInfo = nil;
    PFormHelpArr: PDWFormHelp = nil; FldListProc: TDWFldListProc = nil;
    FormHelpFileProc: TDWFormHelpFileProc = nil; FormHelpFilePrm: pointer = nil): boolean;
  SelGetReassign: procedure(var faPrm: string; const r: TDWVidRec);
  PFldInfGet: function(const nmf: string): PFldInf;
  FldBrCalc: function(const cv: variant; p: PFldInf; BoolRus: boolean): string;
  ChangeDat: function(rdb: TRecDBDef; const oldDef,newDef,where: string;
    lTransaction: boolean = true; WhereProc: TChangeDatWhereProc = nil;
    const DDatFieldCodValue: string = ''): boolean;
  ArrLogCompare: procedure(var Prm: TLogTrnsValPrm; const so,sn: string);
  RDBArrDef: procedure(const ka: string; var p: PRDBArrDef; var a: TArrStr);
  SelCodeGetProc: procedure(Oper: TSelCodeGetOper; const av: array of variant);
  DDRecDBProc: procedure(Sender: TRecDBDef; Oper: TDDRecDBOper; const av: array of variant);
  RDBLogPrimOper: function(var ls: TStringList; Oper: TRDBLogPrimOper; const av: array of variant): string;
  RecDBRecFldZn: function(const nmRec,nmFld: string; var res: variant): boolean;
  DBGet: function(const av: array of variant; n: longint): TComponent;

procedure Register;
function OpenDB: boolean;
procedure CloseDB;
{procedure UpdateDB;
procedure UpdateNameDB(const namedb: string = '');
procedure GetRecDB;}
procedure GetRecNameDB(const namedb: string = '');
function FldValue(Sender: TObject; const nmf: string; const tbl: string = ''): variant; overload;
function FldValue(Sender: TObject; n: longint): variant; overload;
function GetRDBRecno(const aRecDB: array of TRecDB): TRDBRecnoList;
procedure SetRDBRecno(lsRecno: TRDBRecnoList);
function RDBArrv: TRecDB;
function RDBArr: TRecDBDef;
//function VarToStr(const v: variant): string;
procedure QueryCloseAll;
function DWRdbSeek(var r: TCustomRec): boolean; overload;
procedure DWRdbSeek(var r: TRecDBDef); overload;
function SelSeekMsg(Sender: TComponent; rCrt: boolean; const Capt,Msg,nmf,where: string): boolean;
function RecDBVar(const v: variant): TRecDB;
function RecDBDefVar(const v: variant): TRecDBDef;
function MemGkListVar(const v: variant): TMemGkList;
function RDBSaveInfVar(const v: variant): PRDBSaveInf;
function RdbDDVidSeek(Vid: longint; var rdb: TRecDBDef): boolean;
function LogEqual(const Prm: TLogTrnsValPrm; const at,af: array of string): boolean; overload;
function LogEqual(const Prm: TLogTrnsValPrm; const tbl: string; const af: array of string): boolean; overload;
function LogEqual(const Prm: TLogTrnsValPrm; const tbl,nmf: string): boolean; overload;
function LogEqual(const Prm: TLogTrnsValPrm; const tbl: string): boolean; overload;
procedure CopyFromRecDB(var Dest: TArrRecDB; const Source: array of TRecDB);
procedure AddFromRecDB(var Dest: TArrRecDB; const Source: array of TRecDB);
procedure CopyFromRecDBDef(var Dest: TArrRecDBDef; const Source: array of TRecDBDef);
procedure AddFromRecDBDef(var Dest: TArrRecDBDef; const Source: array of TRecDBDef);
function DDStr2Var(f: TField; lsm: TMemGKList; inf: PDDatKvInfo): variant; overload;
function DDStr2Var(q: TMulQuery; nfBeg: longint; lsm: TMemGKList; inf: PDDatKvInfo): variant; overload;
procedure ArrRdbInit(a: PArrStr);
function ArrRdbSeek(const Capt,ka,clist: string; Proc: TArrvSeekProc; Prm: pointer = nil;
  lRdbInit: boolean = true): boolean;
function ArrBoolRecDB(sFalse,sTrue: TRecDB; Inv: boolean = false): TArrBoolRecDB;
function d_VarGet(const rec,ind,nmf: variant; var r: TCustomRec; pi: PLongint = nil): variant;
function d_Var(const v,ind: variant; lSave: boolean): variant;
function d_Bool(const v,ind: variant; lSave: boolean): variant;

implementation

uses
  Windows,SysUtils,Forms,DBTables,Math,Variants,StrUtils,FIBQuery,
  Inter,Shifr,FStat{,FProfile};

type
  ERecDBError = class(Exception);
  ERecDBDefError = class(Exception);
  
const
  cDlm   = '~'; lDlm=Length(cDlm);
  cCRLF  = #31; lcCRLF=Length(cCRLF); lcCRLF1=lcCRLF+1;
  cManyStrCRLF = '^';
  MaxMemoCnt = 500;

  MaxQry = 10;

  anFixArr: array[TFldMemoAttr] of byte = (2,3,4);

var LsLsRecno: TList;
  LsArrDef: TStringList;
  aArrDef: array of TRDBArrDef;
  FRDBArr: TRecDBDef;
  FRDBArrv: TRecDB;
  aQry: array[1..MaxQry] of TMulQuery;
  nQry: 0..MaxQry = 0;
  lMsg: boolean;
  sAttrMem: TFldAttrs;
	aArrRdb: array of record
    rdb: TRecDBDef;
    Def: TDWArrSeekRec;
  end;

procedure ArrRdbInit;
var i,j: longint;
  rd: TRecDBDef;
  r: TDWArrSeekRec;
begin
  AddStack('RecDB.ArrRdbInit');
  j:=low(aArrRdb);
  if Assigned(LsCustomRec) then begin
  	i:=LsCustomRec.Count; SetLength(aArrRdb,i);
   	for i:=0 to i-1 do if IsClass(LsCustomRec.Objects[i],TRecDBDef,pointer(rd)) then
      if rd.DWArrSeek(r) then with aArrRdb[j] do begin
        rdb:=rd; Def:=r; Inc(j);
      end;
  end;
  SetLength(aArrRdb,j);
  if Assigned(a) then begin
    SetLength(a^,j);
    for j:=0 to j-1 do a^[j]:=aArrRdb[j].Def.RecDef;
  end;
  DelStack;
end;

procedure StArrSeek1(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var ocn: string;
  i,j,lr: longint;
	function NewStat: boolean;
  begin
    AddStack('RecDB.StArrSeek1.NewStat');
    result:=Sender.SayStat('',ocn,j/lr); Inc(j);
    DelStack;
  end;
var l,j1,ogk,nFld: longint;
	ka,s,ord,orddop,oname: string;
  q: TMulQuery;
	fOrd,fOrdDop,fqName: TField;
  fl: boolean;
  r: TDWVidRec;
  p: Pointer;
  Proc: TArrvSeekProc;
  a: TArrStr;
label lend;
begin
  AddStack('RecDB.StArrSeek1');
  ka:=Params[0]; p:=PointerVar(Params[1]); Proc:=TArrvSeekProc((@p)^); p:=PointerVar(Params[2]);
  i:=Params[3]; q:=PointerVar(Params[4]); lr:=Params[5]; nFld:=Params[6];
  j:=1; ord:=''; orddop:=''; oname:=''; ocn:=''; ogk:=0;
  with CurQuery,aArrRdb[i] do begin
    fqName:=FindField(Def.Name);
    if Def.FldOrd='' then fOrd:=nil else fOrd:=Fields[nFld];
    if Def.FldOrdDop='' then fOrdDop:=fOrd else fOrdDop:=Fields[nFld+1];
  	while not Eof do begin
      if Assigned(fOrd) then ord:=TrimRight(fOrd.AsString);
      Proc(arrvDefFindBeg,p,rdb,CurQuery,Def,a,0,r,ka,ord,'',fl,Aborted); if Aborted then goto lend;
      if Assigned(fqName) then oname:=TrimRight(fqName.AsString);
      ocn:=ord; rdb.DWArrCodName(CurQuery,ocn,oname); DlmBetwSelf(ocn,oname,' - ');
    	if Assigned(Def.PrFldDef) then
      	if NewStat then goto lend else Def.PrFldDef(rdb,CurQuery,s,false)
      else begin
        ogk:=Fields[0].AsInteger; s:='';
        if Assigned(fOrdDop) then orddop:=TrimRight(fOrdDop.AsString);
        while not Eof and (Fields[0].AsInteger=ogk) do begin
        	if NewStat then goto lend;
          if Assigned(fOrdDop) then fl := TrimRight(fOrdDop.AsString)=orddop else fl:=true;
          if fl then IncD(s,TrimRight(Fields[2].AsString));
          Next;
        end;
      end;
      if s<>'' then begin
      	if not Assigned(Def.PrFldDef) then StrDeShifrSelf(s);
        l:=LsArrDynamic(s,a,CRLF); fl:=false;
        for j1:=0 to l-1 do begin
          r:=DWSToRec(a[j1]);
          if (r.SvType=dwsFix) and (r.AType=dwtArray) and ((ka='') or (r.AValue=ka)) then begin
            Proc(arrvDefFinded,p,rdb,CurQuery,Def,a,j1,r,ka,ord,ocn,fl,Aborted); if Aborted then goto lend;
          end;
        end;
        if fl then begin
          s:=ArrayAsList(a,CRLF,l);
	        if Assigned(Def.PrFldDef)
          then Def.PrFldDef(rdb,CurQuery,s,true)
          else TRecDB.SetMemValue(ogk,s,q,[],famMemo,'',rdb.NameDB,Def.FldDef);
        end;
      end;
      Proc(arrvDefFindEnd,p,rdb,CurQuery,Def,a,0,r,ka,'','',fl,Aborted); if Aborted then goto lend;
      if Assigned(Def.PrFldDef) then Next;
    end;
  end;
lend:
  DelStack;
end;

procedure StArrSeek(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i,j,lr,nFld: longint;
  q: TMulQuery;
  p: Pointer;
  Proc: TArrvSeekProc;
  lDef,fl: boolean;
  r: TDWVidRec;
  a: TArrStr;
begin
  AddStack('RecDB.StArrSeek');
  lr:=Length(aArrRdb); q:=GetQuery;
  with GetQuery do for i:=low(aArrRdb) to high(aArrRdb) do with aArrRdb[i] do begin
    if Sender.SayStat('',rdb.DWName,(i+1)/lr) then break;
    lDef := not Assigned(Def.PrFldDef); Arg[sTABLE]:=Def.RecDef;
    if lDef then begin
      AddArgList(sTABLE,tMEMO);
      SetArrayList(sC_LIST,[tMEMO+'.'+fMGK,tMEMO+'.'+fMNPP,tMEMO+'.'+fMZN]); nFld:=3;
      Arg[sWHERE]:=Def.RecDef+'.'+Def.FldDef+'='+tMEMO+'.'+fMGK;
    end
    else begin
      nFld:=0; Arg[sWHERE]:=''; Arg[sC_LIST]:='';
    end;
    if Def.FldOrd='' then Arg[sO_LIST]:=''
    else begin
      AddArgList(sC_LIST,Def.FldOrd); Arg[sO_LIST]:=Def.FldOrd;
    end;
    if lDef then AddArrayList(sO_LIST,[tMEMO+'.'+fMGK,tMEMO+'.'+fMNPP]);
    if Def.FldOrdDop<>'' then begin
      AddArgList(sC_LIST,Def.FldOrdDop); AddArgList(sO_LIST,Def.FldOrdDop);
    end;
    if Def.FldDop<>'' then AddArgList(sC_LIST,Def.FldDop);
    if Def.Name<>'' then AddArgList(sC_LIST,Def.Name);
    if Params[3]<>'' then AddArgList(sC_LIST,Params[3]);
    PartSelect('','',Arg[sWHERE],Arg[sO_LIST],'',false);
    p:=PointerVar(Params[1]); Proc:=TArrvSeekProc((@p)^);
    p:=PointerVar(Params[2]);
    fl:=true; Proc(arrvQryBeg,p,rdb,CurQuery,Def,a,0,r,'','','',fl,Aborted);
    if Aborted then break;
    if fl then begin
      Open; j:=RecordCount;
      if ShowStat(rdb.DWName,StArrSeek1,[Params[0],Params[1],longint(p),i,LongInt(q),j,nFld],j) then begin
        Sender.Abort; break;
      end;
      Proc(arrvQryEnd,p,rdb,CurQuery,Def,a,0,r,'','','',fl,Aborted); if Aborted then break;
    end;
  end;
  FreeQuery; FreeQuery;
  DelStack;
end;

function ArrRdbSeek;
begin
  AddStack('RecDB.ArrRdbSeek');
  if lRdbInit then ArrRdbInit(nil);
  if Length(aArrRdb)=0 then result:=true else result:=not ShowStat(Capt,StArrSeek,[ka,LongInt(@Proc),Longint(Prm),clist]);
  DelStack;
end;

function ArrBoolRecDB;
begin
  result[Inv]:=sFalse; result[not Inv]:=sTrue;
end;

// Открытие всех БД
function OpenDB;
var i,ocnt: longint;
	tc: TCustomRec;
begin
	AddStack('RecDB.OpenDB');
	result:=true;
	if Assigned(LsCustomRec) then with LsCustomRec do begin
    i:=0;
   	while i<Count do begin
    	tc:=PointerObj(LsCustomRec,i);
      if not tc.Active then begin
        ocnt:=Count;
	    	if not tc.OpenRec then result:=false;
        if Count>ocnt then i:=IndexOf(tc.NameRec);
      end;
      Inc(i);
    end;
    CurRdbArr:=RDBArr;
  end;
  DelStack;
end;

// Закрытие всех БД
procedure CloseDB;
var i: longint;
begin
	AddStack('RecDB.CloseDB');
	if Assigned(LsCustomRec) then with LsCustomRec do
   	for i:=0 to Count-1 do if Objects[i] is TRecDB then TRecDB(Objects[i]).CloseRec;
  DelStack;
end;

// Обновление всех баз
{procedure UpdateDB;
var i: longint;
begin
	if Assigned(LsCustomRec) then with LsCustomRec do
   	for i:=0 to Count-1 do if Objects[i] is TRecDB then TRecDB(Objects[i]).UpdateRec;
end;

// Обновление таблицы nmdb
procedure UpdateNameDB;
var i: longint;
	nmdb: string;
begin
	AddStack('RecDB.UpdateNameDB');
	if Assigned(LsCustomRec) then begin
  	nmdb:=TrimUpper(namedb);
    with LsCustomRec do for i:=0 to Count-1 do
      if Objects[i] is TRecDB then with TRecDB(Objects[i]) do
      	if (nmdb='') or (Trim(NameDB)=nmdb) then UpdateRec;
  end;
  DelStack;
end;

// Считать все базы
procedure GetRecDB;
var i: longint;
begin
	if Assigned(LsCustomRec) then with LsCustomRec do
   	for i:=0 to Count-1 do
      if Objects[i] is TRecDB then with TRecDB(Objects[i]) do if Active then GotoRec;
end;}

// Считать таблицу nmdb
procedure GetRecNameDB;
var i: longint;
	nmdb: string;
begin
	AddStack('RecDB.GetRecNameDB');
	if Assigned(LsCustomRec) then begin
  	nmdb:=Trim(namedb);
    with LsCustomRec do for i:=0 to Count-1 do
      if Objects[i] is TRecDB then with TRecDB(Objects[i]) do
      	if ((nmdb='') or (Trim(NameDB)=nmdb)) and Active and (Recno<>0) then GotoRec;
  end;
  DelStack;
end;

procedure DataSetOwner(var Sender: TObject);
begin
	AddStack('RecDB.DataSetOwner');
  if Sender is TDataSet then IsClass(TDataSet(Sender).Owner,TMulQuery,pointer(Sender),false);
  DelStack;
end;

function FldValue(Sender: TObject; const nmf: string; const tbl: string = ''): variant;
begin
	AddStack('RecDB.FldValue');
  DataSetOwner(Sender);
	if Sender is TMulQuery
    then result:=TMulQuery(Sender).FieldZN(nmf,tbl)
  else if Sender is TUnQuery
    then result:=TUnQuery(Sender).ValueName(nmf)
  else result:=TCustomRec(Sender)[nmf];
  DelStack;
end;

function FldValue(Sender: TObject; n: longint): variant;
begin
	AddStack('RecDB.FldValue(n');
  DataSetOwner(Sender);
	if Sender is TMulQuery
    then result:=TMulQuery(Sender).FieldValueIndex(n)
  else if Sender is TUnQuery
    then result:=TUnQuery(Sender).ValueNum(n)
  else result:=TCustomRec(Sender).ValueNum[n];
  DelStack;
end;

function GetRDBRecno;
var l: longint;
	procedure lsAdd(cr: TRecDB);
  begin
    AddStack('RecDB.GetRDBRecno.lsAdd');
    with result.a[l] do begin
      r:=cr; recno:=r.Recno; r.GetAFieldValue(af);
      if r is TRecDBDef then Def:=TRecDBDef(r).FldDef.Text else Def:='';
    end;
    Inc(l);
    DelStack;
  end;
var i: longint;
  cr: TRecDB;
begin
  AddStack('RecDB.GetRDBRecno');
  result:=TRDBRecnoList.Create; l:=0;
  if Length(aRecDB)>0 then begin
    i:=Length(aRecDB); SetLength(result.a,i);
    for i:=0 to i do lsAdd(aRecDB[i]);
  end
  else begin
    i:=LsCustomRec.Count; SetLength(result.a,i);
    for i:=0 to i-1 do if IsClass(LsCustomRec.Objects[i],TRecDB,pointer(cr)) then lsAdd(cr);
    SetLength(result.a,l);
  end;
  ListCreateObj(result,LsLsRecno);
  DelStack;
end;

procedure SetRDBRecno;
var i: longint;
begin
  AddStack('RecDB.SetRDBRecno');
  try
    with lsRecno do for i:=low(a) to high(a) do with a[i] do if r.Active then begin
      if r.Recno<>recno then begin
        if r is TRecDBDef then TRecDBDef(r).SetFldDefText(Def);
        if recno=0 then r.NewRec([newrNoDoNewRec]) else r.GotoRec(recno);
      end;
      r.SetAFieldValue(af,false);
    end;
  finally
    ListDestroyObj(lsRecno,LsLsRecno); lsRecno.Free;
  end;
  DelStack;
end;

function RDBArrv;
begin
  AddStack('RecDB.RDBArrv');
  if TRecDB.Init(FRDBArrv,result,tARRV,'Вид массивов с таким кодом уже есть.',TRecDBDef.RDBArrvCalculate)
  then FRDBArrv.NameRec:='Arrv';
  DelStack;
end;

function RDBArr;
begin
  AddStack('RecDB.RDBArr');
  with TRecDBDef do if Init(FRDBArr,result,tARR,RDBArrNameRec,RDBArrPrefix,
  'Данные по текущему массиву',RDBArrDWTrans) then begin
    FRDBArr.OnDWRdbSeek:=ArrDWRdbSeek;
    //TDWVid.ArrRdbEvents(FRDBArr);
  end;
  DelStack;
end;

{function VarToStr; // Для просмотра значений variant в отладке
begin
  AddStack('RecDB.VarToStr');
  result:=v;
  DelStack;
end;}

function d_cur(const v,ind: variant; lSave: boolean): variant;
begin
  AddStack('RecDB.d_cur');
  result:=nQry;
  if lSave then begin
    nQry:=v;
    if not aQry[nQry].Active then nQry:=0;
  end;
  DelStack;
end;

function qGet(n: longint; var q: TMulQuery; ActiveOnly: boolean = true): boolean;
begin
  AddStack('RecDB.qGet');
  q:=nil; result:=false;
  if InRange(n,1,MaxQry) then
    if Assigned(aQry[n]) then
      if aQry[n].Active or not ActiveOnly then begin
        q:=aQry[n]; result:=true;
      end;
  DelStack;
end;

function DWRdbSeek(var r: TCustomRec): boolean;
begin
  result := not(r is TRecDBDef);
  if not result then DWRdbSeek(TRecDBDef(r));
end;

procedure DWRdbSeek(var r: TRecDBDef);
begin
  r:=r.DWRdbSeek;
end;

procedure PrimNoKey(var Prm: TLogTrnsValPrm);
begin
  AddStack('RecDB.PrimNoKey');
  with Prm do if nmf=ap[0] then lOut:=false;
  DelStack;
end;

function SelSeekMsg;
var r: TRecDB;
  q: TMulQuery;
  atf: array[1..2] of string;
  ls: TMQFieldList;
  i,l: longint;
  s: string;
  a: TArrStr;
  rc: boolean;
  svi: PRDBSaveInf;
begin
  AddStack('RecDB.SelSeekMsg');
  rc:=false; svi:=nil;
  try
    result:=false;
    if IsClass(Sender,TRecDB,pointer(r)) then begin
      atf[2]:=nmf;
      if r.GetFieldList(ls) then result:=ls.Find(atf[2],i);
    end
    else if IsTable(Sender,tSEL) then begin
      q:=GetQuery(Sender); q.PartSelect(tSEL,[fMGK,'FLD'],where);
      while not q.Eof do begin
        LsArrFill(q.Fields[1].AsString,atf,'.');
        if GetFieldList(Sender,atf[1],ls) then begin
          IncL(atf[2],sSel);
          if ls.Find(atf[2],i) then begin
            if rCrt then begin
              if not rc then begin
                rc:=true; r:=TRecDB.Create;
                if Assigned(Sender) then r.Connection:=Sender;
              end;
              if r.NameDB<>atf[1] then begin
                r.CloseRec; r.NameDB:=atf[1]; r.OpenRec;
              end;
            end
            else RecName(atf[1],TCustomRec(r),TRecDB);
            if Assigned(r) then begin
              if not rc then if not Assigned(svi) then begin
                New(svi); r.SaveInf(svi^);
              end;
              if r.Seek(atf[2]+'='+Vtos(q.Fields[0])) then
                if (r.NameDB<>tDOCPRM) or empty(r[fUSERNAME]) then begin
                  result:=true; break;
                end;
            end;
          end;
        end;
        q.Next;
      end;
      FreeQuery;
    end;
    if result then begin
      s:=GetPrimFld(r.NameDB,ls,i);
      LogTrnsValProcAdd(PrimNoKey,[atf[2]]);
      try
        l:=LsArrDynamic(r.LogPrim,a,LogDlm);
      finally
        LogTrnsValProcDel(PrimNoKey);
      end;
      for i:=0 to l-1 do FRupSelf(a[i]);
      if s<>'' then begin
        if Length(a)=l then SetLength(a,l+1);
        a[l]:='Поле:"'+s+'"';
      end;
      mess_ok([DlmBetween(Msg,'Вид данных: '+r.GetPrim,CRLF),ArrayAsList(a,CRLF,l)],Capt,taLeftJustify);
    end;
  finally
    if rc then r.Free
    else if Assigned(svi) then begin
      TRecDB.RestInf(svi^); Dispose(svi);
    end;
  end;
  DelStack;
end;

function RecDBVar;
begin
  result:=PointerVar(v);
end;

function RecDBDefVar;
begin
  result:=PointerVar(v);
end;

function MemGkListVar;
begin
  result:=PointerVar(v);
end;

function RDBSaveInfVar;
begin
  result:=PointerVar(v);
end;

function RdbDDVidSeek;
var i: longint;
begin
  AddStack('RecDB.RdbDDVidSeek');
  result:=false;
  with LsCustomRec do for i:=0 to Count-1 do
    if IsClass(Objects[i],TRecDBDef,pointer(rdb)) then if rdb.FDynamicVid=vid then begin
      result:=true; break;
    end;
  DelStack;
end;

function LogEqual(const Prm: TLogTrnsValPrm; const at,af: array of string): boolean;
begin
  {$IFDEF STACKALL}AddStack('RecDB.LogEqual');{$ENDIF}
  with Prm do if Sender is TRecDB then begin
    if Length(at)=0 then result:=true else result:=AnsiMatchText(TRecDB(Sender).NameDB,at);
    if result and (Length(af)>0) then result:=AnsiMatchText(nmf,af);
  end
  else result:=false;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function LogEqual(const Prm: TLogTrnsValPrm; const tbl: string; const af: array of string): boolean;
begin
  if tbl='' then result:=LogEqual(Prm,[],af) else result:=LogEqual(Prm,[tbl],af);
end;

function LogEqual(const Prm: TLogTrnsValPrm; const tbl,nmf: string): boolean;
begin
  result:=LogEqual(Prm,tbl,[nmf]);
end;

function LogEqual(const Prm: TLogTrnsValPrm; const tbl: string): boolean;
begin
  result:=LogEqual(Prm,tbl,[]);
end;

procedure CopyFromRecDB;
var i: longint;
begin
  AddStack('Recdb.CopyFromRecDB');
  i:=Length(Source); SetLength(Dest,i);
  for i:=0 to i-1 do Dest[i]:=Source[i];
  DelStack;
end;

procedure AddFromRecDB;
var i,j: longint;
begin
	AddStack('Recdb.AddFromRecDB');
  j:=Length(Dest); i:=Length(Source); SetLength(Dest,j+i);
  for i:=0 to i-1 do begin
    Dest[j]:=Source[i]; Inc(j);
  end;
  DelStack;
end;

procedure CopyFromRecDBDef;
var i: longint;
begin
  AddStack('Recdb.CopyFromRecDBDef');
  i:=Length(Source); SetLength(Dest,i);
  for i:=0 to i-1 do Dest[i]:=Source[i];
  DelStack;
end;

procedure AddFromRecDBDef;
var i,j: longint;
begin
	AddStack('Recdb.AddFromRecDBDef');
  j:=Length(Dest); i:=Length(Source); SetLength(Dest,j+i);
  for i:=0 to i-1 do begin
    Dest[j]:=Source[i]; Inc(j);
  end;
  DelStack;
end;

function DDStr2Var(f: TField; lsm: TMemGKList; inf: PDDatKvInfo): variant;
begin
  AddStack('Recdb.DDStr2Var');
  if inf.tzn=ddznSimple
  then result:=DDStr2Var(f.AsString,inf)
  else result:=lsm.GetValue(f.AsInteger,aDDatMemoAttr[inf.tzn]);
  DelStack;
end;

function DDStr2Var(q: TMulQuery; nfBeg: longint; lsm: TMemGKList; inf: PDDatKvInfo): variant;
begin
  result:=DDStr2Var(q.QryCur.Fields[nfBeg+byte(inf.tzn)],lsm,inf);
end;

function d_inf(const v,ind: variant; lSave: boolean): variant;
var q: TMulQuery;
  t: byte;
begin
  AddStack('RecDB.d_inf');
  result:=ind[0]; t:=ind[1];
  if qGet(nQry,q,t<>4) then case t of
    0: result:=q.RecordCount;
    1: result:=q.Bof;
    2: result:=q.Eof;
    3: result:=q.FieldCount;
    4: result:=TrimRight(q.Text);
  end;
  i_constSelf(result,lSave);
  DelStack;
end;

function d_msg(const v,ind: variant; lSave: boolean): variant;
begin
	AddStack('RecDB.d_msg');
  result:=lMsg;
  if lSave then lMsg:=v;
  DelStack;
end;

function d_VarGet;
var i,h: longint;
begin
	AddStack('RecDB.d_VarGet');
  if MyVarType(rec)=varString then r:=RecName(rec) else r:=PointerVar(rec);
  if MyVarType(ind)=varArray then h:=VarArrayHighBound(ind,1) else h:=-1;
  if h>1 then if ind[2] then DWRdbSeek(r);
  PointerDef(pointer(pi),@i);
  if MyVarType(nmf)=varString then pi^:=r.NumFromName(nmf) else pi^:=nmf;
  if pi^<0 then result:=null else result:=r.ValueNum[pi^];
  if h>2 then if ind[3] then TrimRightSelf(result);
  DelStack;
end;

function d_Var;
var r: TCustomRec;
begin
	AddStack('RecDB.d_Var');
  result:=i_const(d_VarGet(ind[0],ind,ind[1],r),lSave);
  DelStack;
end;

function d_Bool;
begin
	AddStack('FDM.d_Bool');
  result:=StrToBoolean(d_Var(v,ind,lSave));
  DelStack;
end;

function qNextNum: longint;
var q: TMulQuery;
  msg: string;
  n,i,j: longint;
  ls: TStringList;
begin
  AddStack('RecDB.qNextNum');
  result:=1;
  while result<=high(aQry) do
    if qGet(result,q) then Inc(result) else break;
  if result>high(aQry) then begin
    msg:=''; ls:=SortStrListCreate;
    try
      for n:=low(aQry) to high(aQry) do IgnoreSlAddInt(ls,aQry[n].Arg[sTABLE]);
      ls.Sorted:=false;
      for i:=0 to ls.Count-1 do begin
        j:=IntObj(ls,i);
        if j>1 then IncD(ls,i,Format('(%d)',[j]));
        IncD(msg,','+ls[i]);
      end;
    finally
      ls.Free;
    end;
    msg:='Слишком много открытых выборок из таблиц: '+CRLF+Copy(msg,2,MaxInt);
    OutStack(msg);
    raise EInterAnyError.Create(msg);
  end;
  if not Assigned(aQry[result]) then aQry[result]:=TMulQuery.Create(Application.MainForm);
  DelStack;
end;

function c_open(var av: array of variant): variant;
var i: longint;
  procedure Ls2(var a: TArrVar; n: byte; lVtos: boolean = false);
    function vZn(const v: variant): string;
    begin
      AddStack('RecDB.c_open.Ls2.vZn');
      if lVtos then result:=aQry[i].VarToS(v) else result:=v;
      DelStack;
    end;
  var j,j1,l,h: longint;
    s: string;
  begin
    AddStack('RecDB.c_open.Ls2');
    if MyVarType(IsNil(av[n],''))=varArray then begin
      l:=VarArrayLowBound(av[n],1); h:=VarArrayHighBound(av[n],1);
      j1:=Length(a); SetLength(a,j1+h-l+1);
      for j:=l to h do begin
        s:=vZn(av[n][j]);
        if not empty(s) then begin
          a[j1]:=s; Inc(j1);
        end;
      end;
      SetLength(a,j1);
    end
    else AddFromVArr(a,[vZn(av[n])]);
    DelStack;
  end;
  function Ls1(n: byte): string;
  var a: TArrVar;
    j: longint;
  begin
    AddStack('RecDB.c_open.Ls1');
    result:=''; Ls2(a,n);
    for j:=low(a) to high(a) do IncD(result,a[j]+',');
    DecLen(result);
    DelStack;
  end;
var ost: longint;
  acl,avl: TArrVar;
begin
	ost:=AddStack('RecDB.c_open');
  if IsNilc(av[6],true) then i:=qNextNum else i:=nQry;
  result:=0;
  try
  	with aQry[i] do begin
      Connection:=DBGet(av,7); acl:=nil; avl:=nil;
      if MyVarType(av[1],true)=varDouble then case byte(av[1]) of
        1: begin
          SQLText(av[2]);
          if IsNilc(av[3],true) then ExecSQL
          else begin
            Part:=''; Open;
          end;
        end;
        2: begin
          Ls2(acl,3); Ls2(avl,4,true); UpdateTable(av[2],acl,avl,IsNilc(av[5],''));
        end;
        3: DeleteTable(av[2],IsNilc(av[3],''));
        4: begin
        	Arg[sC_LIST]:=''; Arg[sV_LIST]:='';
          if IsNilc(av[5],false) then begin
            AddFromVArr(acl,[fRECNO]); AddFromVArr(avl,[GetMaxFld(fRECNO,av[2])]);
          end;
          Ls2(acl,3); Ls2(avl,4,true); InsertTable(av[2],acl,avl);
        end;
      end
      else begin
        IsNil(av[2],'*');
        PartSelect(Ls1(1),Ls1(2),IsNilc(av[3],''),Ls1(4),Ls1(5),IsNilc(av[8],true));
      end;
    end;
    nQry:=i; result:=i;
  except
    on E:EDatabaseError do begin
    	SetStack(ost);
      if lMsg then aQry[i].ShowErr(E);
    end;
    //raise EInterAnyError.Create('Ошибка выполнения SQL-запроса:'+CRLF+aQry[i].Text);
  end;
  DelStack;
end;

function c_close(var av: array of variant): variant;
var i: longint;
begin
  AddStack('RecDB.c_close');
  result:=null; i:=IsNilc(av[1],nQry);
  if InRange(i,low(aQry),high(aQry)) then
	  if Assigned(aQry[i]) then aQry[i].Close;
  DelStack;
end;

procedure QueryCloseAll;
var i: byte;
begin
  AddStack('RecDB.QueryCloseAll');
  for i:=low(aQry) to high(aQry) do if Assigned(aQry[i]) then aQry[i].Close;
  DelStack;
end;

function c_first(var av: array of variant): variant;
var q: TMulQuery;
begin
  AddStack('RecDB.c_first');
  result:=null; if qGet(nQry,q) then q.First;
  DelStack;
end;

function c_last(var av: array of variant): variant;
var q: TMulQuery;
begin
  AddStack('RecDB.c_last');
  result:=null; if qGet(nQry,q) then q.Last;
  DelStack;
end;

function c_next(var av: array of variant): variant;
var q: TMulQuery;
begin
  AddStack('RecDB.c_next');
  result:=null; if qGet(nQry,q) then q.Next;
  DelStack;
end;

function c_prior(var av: array of variant): variant;
var q: TMulQuery;
begin
  AddStack('RecDB.c_prior');
  result:=null; if qGet(nQry,q) then q.Prior;
  DelStack;
end;

function c_fldname(var av: array of variant): variant;
var q: TMulQuery;
	n: longint;
begin
  AddStack('RecDB.c_fldname');
  result:='';
  if qGet(nQry,q) then begin
  	n:=av[1];
  	if InRange(n,1,q.FieldCount) then result:=q.Fields[n-1].FieldName;
  end;
  DelStack;
end;

function c_fld(var av: array of variant): variant;
var q: TMulQuery;
begin
  AddStack('RecDB.c_fld');
  if qGet(nQry,q) then
    if MyVarType(av[1])=varString then result:=q.FieldZn(av[1])
    else result:=FieldAsVariant(q.Fields[av[1]-1])
  else result:=null;
  DelStack;
end;

function c_vartos(var av: array of variant): variant;
var i: longint;
begin
  AddStack('RecDB.c_vartos');
  i:=qNextNum;
  with aQry[i] do begin
  	Connection:=FirstDatabase; result:=VarTos(av[1],vsQQ); Close;
  end;
  DelStack;
end;

function c_fldinsel(var av: array of variant): variant;
var i: longint;
  a,az: TArrStr;
  av1: TArrVar;
  Opt: TFldInSelOpt;
begin
  AddStack('RecDB.c_fldinsel');
  i:=qNextNum; IsNil(av[3],false);
  with aQry[i] do begin
  	Connection:=FirstDatabase;
    CopyFromVar(av1,av[1]); av[1]:=ConCat(av1);
    if (MyVarType(av[2])=varArray) and not IsNil(av[4]) then begin
      CopyFromVar(av1,av[2]); av[2]:=GetList(av1);
    end;
    if MyVarType(av[2])=varString then begin
      CopyFromVar(av1,IsNilc(av[5],''));
      if av[3] then Opt:=[fselNot] else Opt:=[];
      FldInSel(av[1],av[2],IsNilc(av[4],''),ConCat(av1),Opt,@a);
    end
    else begin
      if MyVarType(av[2])=varArray then CopyFromVar(az,av[2]) else az:=nil;
      FldInList(a,av[1],az,NegDef,IfThen(av[3],flsNot));
    end;
    Close;
  end;
  result:=ArrStrToVar(a,1);
  DelStack;
end;

function c_trns(var av: array of variant): variant;
var a: TArrStr;
begin
  AddStack('RecDB.c_trns');
  if MyVarType(IsNil(av[1],false))=varBoolean then begin
    result:=true; TrnsEnd(IfThen(not av[1],trnsCommit));
  end
  else begin
    CopyFromVar(a,av[1]); result:=TrnsStart(a);
  end;
  DelStack;
end;

function PrQryFindComp(q: TMulQuery; const v: variant): TValueSign;
begin
  AddStack('RecDB.PrQryFindComp');
  result:=CompSign(InterProcStat(ArrVarVar(v[0])^),v[1]);
  DelStack;
end;

function c_find(var av: array of variant): variant;
var q: TMulQuery;
  v: variant;
  FirstKey: boolean;
  ap: TArrVar;
begin
  AddStack('RecDB.c_find');
  if qGet(nQry,q) then begin
    v:=av[1]; FirstKey:=IsNilc(av[2],true);
    if IsNil(av[3])
    then result:=QryFind(v,q,nil,FirstKey)
    else begin
      ShiftArg(ap,av,2); result:=QryFind(VarArrayOf([longint(@ap),v]),q,PrQryFindComp,FirstKey);
    end;
  end
  else result:=false;
  DelStack;
end;

// StrShifr()
function c_strshifr(var av: array of variant): variant;
begin
	AddStack('RecDB.c_strshifr');
  if empty(av[2]) then result:=StrDeShifr(av[1]) else result:=StrShifr(av[1]);
  DelStack;
end;

function c_getfromquery(var av: array of variant): variant;
var q: TMulQuery;
begin
  AddStack('RecDB.c_getfromquery');
  result:=null;
  if qGet(nQry,q) then TRecDB(RecName(av[1])).GetFromQuery(q);
  DelStack;
end;

function c_getmaxfld(var av: array of variant): variant;
begin
  AddStack('RecDB.c_getmaxfld');
  result:=GetQuery.GetMaxFld(av[1],av[2]); FreeQuery;
  DelStack;
end;

{function c_getprim(var av: array of variant): variant;
begin
  AddStack('RecDB.c_getprim');
  result:=GetPrim(av[1],false);
  DelStack;
end;}

function TransToLongVal(const r: TDWVidRec; ft: TFieldType; const v: variant): string;
begin
  AddStack('RecDB.TransToLongVal');
  case ft of
    ftFloat: result:=SpaceStr(v,r.Len,r.Dec);
    ftDateTime: result:=StrTran(dtoc(iif(MyVarType(v)=varDate,v,DateEmpty)),DateSeparator,'.');
    ftBoolean: result:=Bool2Str(v);
  else if MyVarType(v)=varString then result:=TrimRight(v) else result:='';
  end;
  DelStack;
end;

function TransFromLongVal({const r: TDWVidRec; }ft: TFieldType; const v: string): variant;
begin
  AddStack('RecDB.TransFromLongVal');
  case ft of
    ftFloat: result:=Float0(v);
    ftDateTime: result:=ctod(StrTran(v,'.',DateSeparator));
    ftBoolean: result:=StrToBoolean(v);
  else result:=v;
  end;
  DelStack;
end;

{function FFldInList(const agk: array of longword; var where: string): boolean;
var a: TArrStr;
	i,j: longint;
begin
  AddStack('RecDB.FFldInList');
  SetLength(a,Length(agk)); j:=0;
  for i:=low(agk) to high(agk) do
  	if agk[i]<>0 then begin
      a[j]:=VarTos(longint(agk[i])); Inc(j);
    end;
  where:=FldInList(fMGK,a,false,false,j); result := where<>'';
  DelStack;
end;}

function FAFldInList(const agk: array of longword; var a: TArrStr): boolean;
var i,j: longint;
begin
  AddStack('RecDB.FAFldInList');
  SetLength(a,Length(agk)); j:=0;
  for i:=low(agk) to high(agk) do
  	if agk[i]<>0 then begin
      a[j]:=IntToStr(agk[i]); Inc(j);
    end;
  SetLength(a,j); result := j>0;
  DelStack;
end;

function DelFldInList(const a: TRDBFldGetRec; q: TMulQuery): boolean;
var fa: TFldMemoAttr;
  ast: TArrStr;
begin
  AddStack('RecDB.DelFldInList');
  result:=true;
  for fa:=low(a) to high(a) do with a[fa] do begin
    SetLength(agk,Len);
    if FAFldInList(agk,ast) then
      if fa=famArray
      then result:=RDBArr.DelRec(ast,NegDef,fMGK,IfThen(lMsg,delMsg))
      else result:=q.DeleteTableFldList(ast,NegDef,fMGK,[],aMemoTbl[fa],true);
  end;
  DelStack;
end;

procedure StrDlmArr(const s: string; p,l: longint; Dlm: Char; var a: TArrPosLen);
var i,j: longint;
begin
  AddStack('RecDB.StrDlmArr');
  SetLength(a,l+1); j:=0; a[j].Pos:=p; a[j].Len:=l;
  for i:=p to p+l-1 do
    if s[i]=Dlm then begin
      a[j].Len:=i-a[j].Pos; Inc(j); a[j].Pos:=i+1;
    end;
  SetLength(a,j+1); a[j].Len:=p+l-a[j].Pos;
  DelStack;
end;

procedure AddGK(gk: longword; var a: TRDBFldGetRec; fa: TFldMemoAttr);
begin
  AddStack('RecDB.AddGK');
  if gk>0 then with a[fa] do begin
  	if Len>high(agk) then SetLength(agk,IfThen(Len=0,100,Len shl 1));
    agk[Len]:=gk; Inc(Len);
  end;
  DelStack;
end;

function IfThen(AValue: boolean; ATrue,AFalse: TFldMemoAttrSet): TFldMemoAttrSet; overload;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

{ TRecDB }
constructor TRecDB.Create;
begin
	AddStack('TRecDB.Create',Self);
	//addmsgfile('Create');
	Inherited Create(AOwner);
  FQuery:=TMulQuery.CreateConnection(Self); FFRecNo:=0; lUpdate:=false;
  DelStack;
end;

constructor TRecDB.CreateFrom;
begin
	AddStack('TRecDB.CreateFrom',Self);
  Create(r.Owner); Connection:=r.Connection; NameDB:=r.NameDB;
  DelStack;
end;

{procedure TRecDB.Assign(Source: TPersistent);
begin
	AddStack('TRecDB.Assign',Self);
	//addmsgfile('Assign');
  if Source is TRecDB then with TRecDB(Source) do begin
  	Self.NameDB:=NameDB;
  	Self.OnNewRec:=OnNewRec;
  	Self.OnKodNext:=OnKodNext;
  	Self.OnKodCheck:=OnKodCheck;
  end;
	inherited Assign(Source);
  DelStack;
end;}

function TRecDB.GetConnection;
begin
	AddStack('TRecDB.GetConnection',Self);
  result:=FQuery.Connection;
  DelStack;
end;

procedure TRecDB.SetConnection;
begin
  AddStack('TRecDB.SetConnection',Self);
  FQuery.Connection:=Value;
  DelStack;
end;

procedure TRecDB.SetNameDB;
var oPrim: string;
begin
	AddStack('TRecDB.SetNameDB',Self);
	//admsgfile('SetNameDB');
	if FNameDB<>v then begin
    oPrim:=Prim; Prim:=''; FNameDB:=v; Prim:=oPrim;
    if empty(NameRec) then NameRec:=FNameDB;
    AnsiUpperCaseSelf(FNameDB);
  end;
  DelStack;
end;

procedure TRecDB.FSetPrim;
begin
	AddStack('TRecDB.FSetPrim',Self);
	if FPrim<>v then begin
    FPrim:=v; SetPrim(FNameDB,FPrim);
  end;
  DelStack;
end;

function TRecDB.GetPrim;
begin
  result:=My_pr.GetPrim(NameDB,lRaise);
end;

function TRecDB.GetPrimFld;
begin
  result:=MulQry.GetPrimFld(NameDB,nmf);
end;

// Создать поле
function TRecDB.FCreateFld;
var fa: TFldMemoAttr;
begin
	AddStack('TRecDB.FCreateFld',Self);
	//addmsgfile('FCreateFld');
  result := inherited FCreateFld(AName,AType,ASize,AValue);
  for fa:=low(aMemo) to high(aMemo) do with aMemo[fa] do if beg<>'' then
    if AnsiStartsText(beg,AName) then with result do begin
      Info.Attr:=attr; Info.DataType:=ftString; MemGk:=0; Info.Value:=''; Info.Size:=0; break;
    end;
  DelStack;
end;

// Открытие базы
function TRecDB.OpenRec;
var i,sz: longint;
  tp: TFieldType;
  ls: TMQFieldList;
  fi: PMQFieldInfo;
  v: variant;
begin
	AddStack('TRecDB.OpenRec',Self);
	//admsgfile('OpenRec');
	result:=Active;
	if not result then if not empty(FNameDB) then begin
    FQuery.ConnectionDef;
    if GetFieldList(ls) then begin
      for i:=0 to ls.Count-1 do begin
        if UpperCase(ls[i])=fRECNO then continue;
        fi:=ls.Fields(i); sz:=0; v:=0; tp:=fi.DataType;
        case tp of
          ftString: begin
            sz:=fi.Size; v:='';
          end;
          ftBoolean: v:=false;
          ftDate: tp:=ftDateTime;
          ftBlob: continue;
        end;
        FCreateFld(ls[i],tp,sz,v);
      end;
      result := inherited OpenRec;
    end;
  end;
  DelStack;
end;

// Закрытие базы
procedure TRecDB.FCloseRec;
begin
	AddStack('TRecDB.FCloseRec',Self);
	//admsgfile('CloseRec');
	if Active then begin
    FFRecNo:=0;
    inherited FCloseRec;
  end;
  DelStack;
end;

function TRecDB.FldSetValue;
begin
  {$IFDEF STACKALL}AddStack('TRecDB.FldSetValue',Self);{$ENDIF}
  result:=inherited FldSetValue(Sender,v,Oper);
  if Oper=fsvOwner then if Sender.Info.Attr in sAttrMem then if MyVarType(v)=varString then begin
    //if (MemGk<>0) and (Sender.Info.Value='') and (v='') then Sender.OldValue:=null;
    // Убрал, т.к. в журнале действий не записывалось "..." -> ""
    Sender.Change(v); Sender.Info.Value:=v; result:=true;
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TRecDB.FLogPrim;
var lsf: TMQFieldList;
  i,j: longint;
  fi: PPMQFieldInfo;
  fj: PMQFieldInfo;
  fv,fov: PVariant;
  keyord: PByte;
  af: PArrBool;
  f,f1: TFld;
  fl: PBoolean;
  IsBool: boolean;
begin
  AddStack('TRecDB.FLogPrim',Self);
  case Oper of
    logpCreate: begin
      GetFieldList(lsf); CopyFromVArr(ap,[longint(lsf)]);
    end;
    logpIsFld: begin
      lsf:=PointerVar(ap[0]);
      i:=av[1]; fi:=PointerVar(av[2]); fv:=PointerVar(av[3]); fov:=PointerVar(av[4]); keyord:=PointerVar(av[5]);
      af:=PointerVar(av[6]);
      if Assigned(lsf) then begin
        if lsf.Fields(FieldName[i],fi^) then keyord^:=fi^.KeyOrd;
        f:=Field[i];
        if f.DuplFld(f1) then begin
          fov^:=f1.OldValue;
          if f.Info.DataType=ftBoolean then StrToBoolSelf(fov^);
          for j:=0 to FieldCount-1 do if Field[j]=f1 then begin
            if lsf.Fields(FieldName[j],fj) then keyord^:=fj.KeyOrd;
            break;
          end;
        end;
      end;
      if Assigned(fi^) then begin
        IsBool := mqfBool in fi^.Options;
        if IsBool then StrToBoolSelf(fv^);
      end
      else IsBool:=false;
      if Assigned(af) then begin
        Prm.lOut:=af^[i];
        if Assigned(lsf) and (logpMod in TLogPrimOptions(byte(av[7]))) then
          if IsBool then Prm.lOut := StrToBoolean(fov^)<>fv^;
      end
      else Prm.lOut:=true;
    end;
    logpNoEmpKey: begin
      fl:=PointerVar(av[0]);
      if not fl^ then fl^ := LogFieldsBound.IndexOf(TblFldName(FieldName[longint(av[1])]))>=0;
    end;
    logpGet: Prm.nm:=GetPrimFld(FieldName[longint(av[1])]);
  end;
  DelStack;
end;

// Выгрузить файл SQL-запросов
procedure TRecDB.ClearSQL;
begin
	AddStack('TRecDB.ClearSQL',Self);
	//admsgfile('ClearSQL');
	if csDesigning in ComponentState then TMulQuery.ClearSQL;
  DelStack;
end;

// Перейти на запись rec
function TRecDB.GotoRec(rec: longint): boolean;
begin
	AddStack('TRecDB.GotoRec',Self);
	//admsgfile('GotoRec');
	if not Active then raise ERecDBError.Create(
  	'Ошибка перехода на запись (GotoRec):'+CRLF+'база '+FNameDB+' закрыта');
  result:=GetRec(nil,rec);
  DelStack;
end;

function TRecDB.GotoRec(f: TField): boolean;
begin
  result:=GotoRec(f.AsInteger);
end;

function TRecDB.GotoRec(q: TMulQuery): boolean;
begin
  result:=GotoRec(q.FindField(fRECNO));
end;

function TRecDB.GotoRec: boolean;
begin
  result:=GotoRec(FFRecNo);
end;

// Обновление текущей записи с проверкой записи
function TRecDB.UpdateRec;
begin
	AddStack('TRecDB.UpdateRec',Self);
	//admsgfile('UpdateRec');
  if FFRecNo=0 then result:=false else result:=FldUpdate(sUW_TABLE,true,lLog,MemGkSet,pRowsAffected,where);
  DelStack;
end;

// Достать указанную запись
function TRecDB.GetRec;
var i,l: longint;
	noq: boolean;
  a: TRDBFldGetRec;
  fa: TFldMemoAttr;
begin
	AddStack('TRecDB.GetRec',Self);
  if FixRecnoMsg<>'' then raise ERecDBError.Create(FixRecnoMsg);
	//admsgfile('GetRec');
  if noMemo then ais:=[];
  noq := not Assigned(q);
  if noq then begin
  	q:=FQuery;
    if Self is TRecDBDef
    then TRecDBDef.PartSelect(TRecDBDef(Self),q,TblFldName(RecnoWhere(rec)))
    else q.PartSelect(NameDB,[],TblFldName(RecnoWhere(rec)));
    ClearSQL;
  end;
  result := not q.Eof;
  if result or not noq then begin
  	FFRecNo:=q.FieldZn(nmrecno); l:=FieldCount;
    for fa:=low(a) to high(a) do with a[fa] do begin
	    SetLength(af,l); Len:=0;
    end;
    i:=0;
    try
      FldChangeOn:=false;
      while i<FieldCount do begin
        FldGetRec(q,i,ais<>[],lsDupl); Inc(i);
      end;
      if ais<>[] then with TMemGkList.Create(Self,q,nil,nil,true,mgdAll,'',nil,ais) do try
        IfThenNotify(FOnBeforeMemRead,q); GetFromQuery('',nil,[],ais); DestroyFromQuery;
      finally
        Free;
      end;
      for i:=0 to FieldCount-1 do Field[i].Modified:=false;
    finally
      FldChangeOn:=true;
    end;
  end
  else FFRecNo:=0;
  if noq then FQuery.Close;
  DelStack;
end;

procedure TRecDB.MsgFld;
var i,j,j1: longint;
begin
  AddStack('TRecDB.MsgFld',Self);
  if nOper=foDestroy then if Assigned(LsLsRecno) then
    for i:=0 to LsLsRecno.Count-1 do begin
      j:=0;
      with TRDBRecnoList(LsLsRecno[i]) do while j<Length(a) do
        if a[j].r=Self then begin
          for j1:=j+1 to high(a) do a[j1-1]:=a[j1];
          SetLength(a,Length(a)-1);
        end
        else Inc(j);
    end;
  inherited MsgFld(nOper);
  DelStack;
end;

function FindFieldDupl(var tf: TField; q: TMulQuery; lsDupl: TStringList; const nmf: string): boolean;
var s: string;
  i: longint;
begin
  {$IFDEF STACKALL}AddStack('RecDb.FindFieldDupl');{$ENDIF}
  s:=nmf;
  if Assigned(lsDupl) then
    if lsDupl.Find(s,i)
    then s:=q.FldDuplicate(s,IntObj(lsDupl,i));
  result:=q.FindField(s,tf);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TRecDB.FldGetRec;
var f: TFld;
	tf: TField;
begin
	{$IFDEF STACKALL}AddStack('TRecDB.FldGetRec',Self){$ENDIF};
	//admsgfile('FldGetRec');
  if FindFieldDupl(tf,q,lsDupl,FieldName[i]) then begin
  	f:=Field[i];
    if f.Info.Attr in sAttrMem then begin
      if lMemo then f.MemGk:=tf.AsInteger else f.MemGk:=0;
      f.Value:='';
    end
    else case f.Info.DataType of
      ftInteger: f.Value:=tf.AsInteger;
      ftBoolean: f.Value:=tf.AsBoolean;
      ftFloat: f.Value:=tf.AsFloat;
      ftDateTime: f.Value:=max(DateEmpty,tf.AsDateTime);
    else f.Value:=TrimRight(tf.AsString);
    end;
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

// Строковое значение поля в формате SQL
// Добавить новую/скопировать текущую запись
procedure TRecDB.NewRec(Opt: TRDBNewOpt = []; const gKey: string = '');
var i: longint;
	f: TFld;
  lsf: TMQFieldList;
  v: variant;
begin
	AddStack('TRecDB.NewRec',Self);
	//admsgfile('NewRec');
	if not Active then raise ERecDBError.Create(
  	'Ошибка создания новой записи (NewRec):'+CRLF+'база '+FNameDB+' закрыта');
  FFRecNo:=0; GetFieldList(lsf);
  for i:=0 to FieldCount-1 do begin
  	f:=Field[i]; f.MemGk:=0;
    if not(newrCopy in Opt) then begin
      if f.Info.Attr in [faMemo,faSel,faFixSel] then begin
        if f.Info.Attr<>faFixSel then f.Info.Value:='';
      end
      else
        case f.Info.DataType of
          ftString,ftArray: begin
            v:='';
            if Assigned(lsf) then if lsf.IsFieldBool(FieldName[i]) then v:=bFalse;
            f.Value:=v;
          end;
          ftBoolean: f.Value:=false;
        else f.Value:=0;
        end;
      f.Modified:=false;
    end;
  end;
  if not(newrNoDoNewRec in Opt) then DoNewRec(newrCopy in Opt,gKey);
  DelStack;
end;

procedure TRecDB.NewRec(fa: TFormAction; const gKey: string = '');
begin
  NewRec(IfThen(fa=faCopy,newrCopy),gKey);
end;

procedure TRecDB.DoNewRec(lCopy: boolean = false; const gKey: string = '');
begin
	DoNewRec(FOnNewRec,lcopy,gKey);
end;

procedure TRecDB.DoNewRec(Proc: TRDBNewRec; lCopy: boolean = false; const gKey: string = '');
begin
	AddStack('TRecDB.DoNewRec',Self);
  if Assigned(Proc) then Proc(Self,lcopy,gKey);
  DelStack;
end;

// Добавить запись со значениями из списка полей
function TRecDB.AppRec;
begin
	AddStack('TRecDB.AppRec',Self);
	//admsgfile('AppRec');
	if not Active then raise ERecDBError.Create(
  	'Ошибка добавления записи (AppRec):'+CRLF+'база '+FNameDB+' закрыта');
	if FFRecNo=0 then begin
    if nRec=0 then nRec:=GetMaxFld;
    FFRecNo:=nRec; FldUpdate(PartSQL,false,lLog,MemGkSet,nil,'');
  end;
  result:=FQuery;
  DelStack;
end;

function TRecDB.AppUpdRec;
begin
  AddStack('TRecDB.AppUpdRec',Self);
  if Recno=0 then begin
    AppRec(lLog); result:=true;
  end
  else result:=UpdateRec(lLog);
  DelStack;
end;

procedure TRecDB.AppRecConstraint;
var ost,i,j: longint;
  av: TArrFldVal;
  af: TArrStr;
  ls: TMQIndexList;
  s,s1: string;
  fl: boolean;
begin
  ost:=AddStack('TRecDB.AppRecConstraint',Self);
  af:=nil; 
  try
    AppRec(lLog);
  except
    on EDatabaseError do begin
      fl:=false; GetAFieldValue(av); ls:=TMQIndexList.Create(Connection,NameDB,true);
      try
        for i:=0 to ls.Count-1 do begin
          s:=''; af:=ls.Indices(i);
          for j:=low(af) to high(af) do begin
            if af[j]=fRECNO then s1:=Vtos(FFRecNo) else s1:=FQuery.VarToS(Value[af[j]],vsQQ);
            IncAnd(s,TblFldName(af[j])+'='+s1);
          end;
          if Seek(Copy(s,lAND1,MaxInt)) then begin
            SetAFieldValue(av); UpdateRec; fl:=true; break;
          end;
        end;
      finally
        ls.Free;
      end;
      if fl then SetStack(ost) else raise
    end;
  end;
  DelStack;
end;

procedure TRecDB.GetFieldsModified;
var i: longint;
begin
  AddStack('TRecDB.GetFieldsModified',Self);
  i:=FieldCount; SetLength(af,i);
  for i:=0 to i-1 do af[i] := not lmod or FldModified(i);
  DelStack;
end;

function TRecDB.FldUpdate;
var af: TArrBool;
  logp: string;
  Opt: TLogPrimOptions;
begin
	AddStack('TRecDB.FldUpdate',Self);
  if lUpdate then result:=false
  else begin
    Calculate(not lMod); lUpdate:=true; GetFieldsModified(af,lmod);
    if lLog then begin
      Opt:=[logpKey,logpNoKey];
      if lmod then Include(Opt,logpMod);
      logp:=LogPrim(Opt,@af);
    end
    else logp:='';
    result:=FFldUpdate(PartSQL,lmod,MemGkSet,af,logp,pRowsAffected,where); lUpdate:=false;
  end;
  DelStack;
end;

function TRecDB.FFldUpdate;
var i,j,k: longint;
  atbl: TArrStr;
  fl: boolean;
  a: TRDBFldGetRec;
  fa: TFldMemoAttr;
  f: TFld;
begin
	AddStack('TRecDB.FFldUpdate',Self);
	result:=false;
  with FQuery do begin
  	Arg[sC_LIST]:=''; Arg[sV_LIST]:='';
    for fa:=low(a) to high(a) do with a[fa] do begin
    	SetLength(agk,Self.FieldCount); Len:=0;
    end;
    if Assigned(MemGkSet) then for i:=low(MemGkSet^) to high(MemGkSet^) do
      if FieldFind(MemGkSet^[i].nmf,j) then begin
        af[j]:=false;
        for k:=0 to Self.FieldCount-1 do if Field[k].DuplFld(f) then if f=Field[j] then begin
          af[k]:=false; break;
        end;
        with FQuery do begin
          AddArgList(sC_LIST,Self.FieldName[j]); AddArgList(sV_LIST,VToS(MemGkSet^[i].gk));
        end;
      end;
    for i:=0 to Self.FieldCount-1 do if af[i] then FldAddList(i,a);
    if not lmod or (Arg[sC_LIST]<>'') then begin
    	if not lmod then begin
	      AddArgList(sC_LIST,fRECNO); AddArgList(sV_LIST,FFRecNo);
      end;
      Arg[sWHERE]:=DlmBetween(rRecno,where,sAND);
      fl:=Assigned(FOnTrnsCan);
      if fl then begin
        fl:=FOnTrnsCan(Self,lmod);
        if fl then begin
          if Assigned(FOnTrnsTable) then CopyFromVar(atbl,FOnTrnsTable(Self)) else atbl:=nil;
          TrnsStart(atbl);
        end;
      end;
      PointerDef(pointer(pRowsAffected),@k); pRowsAffected^:=0;
      try
        Arg[sTABLE]:=FNameDB;
        if PartSQL<>'' then begin
          ExecPart(PartSQL); pRowsAffected^:=FQuery.RowsAffected;
        end;
        DelFldInList(a,FQuery);
        if fl then begin
          if Assigned(FOnTrnsExec) then FOnTrnsExec(Self,FQuery,lmod);
          TrnsEnd([trnsCommit]); IfThenNotify(FOnTrnsEnd,Self);
        end;
      except
        if fl then TrnsEnd;
        raise
      end;
      if (logp<>'') and (not lmod or (pRowsAffected^>0)) then LogWrite(logp);
      Self.ClearSQL; result:=true;
    end;
    for i:=0 to Self.FieldCount-1 do Field[i].Modified:=false;
  end;
  DelStack;
end;

function TRecDB.LogPrimMod;
var af: TArrBool;
begin
  AddStack('TRecDB.LogPrimMod',Self);
  GetFieldsModified(af); result:=LogPrim([logpMod,logpKey,logpNoKey],@af);
  DelStack;
end;

procedure TRecDB.LogWrite(Opt: TLogPrimOptions = [logpKey]; af: PArrBool = nil);
begin
  AddStack('TRecDB.LogWrite',Self);
  MyTypes.LogWrite(NameDB,LogPrim(Opt,af));
  DelStack;
end;

procedure TRecDB.LogWrite(const prim: string);
begin
  MyTypes.LogWrite(NameDB,prim);
end;

procedure TRecDB.LogWrite(const a: TArrStr; const sbeg: string = '');
begin
  LogWrite(a,high(a),sbeg);
end;

procedure TRecDB.LogWrite(const a: TArrStr; h: longint; const sbeg: string = '');
var i: longint;
begin
  for i:=0 to h do LogWrite(sbeg+a[i]);
end;

procedure TRecDB.LogWriteMod;
var af: TArrBool;
begin
  AddStack('TRecDB.LogWriteMod',Self);
  GetFieldsModified(af); LogWrite([logpMod,logpKey,logpNoKey],@af);
  DelStack;
end;

function TRecDB.LogVidRecno;
begin
  AddStack('TRecDB.LogVidRecno',Self);
  result:=aEdAppLog[RecNo=0];
  DelStack;
end;

procedure TRecDB.SetLogVidRecno;
begin
  AddStack('TRecDB.SetLogVidRecno',Self);
  SetLogVid(LogVidRecno);
  DelStack;
end;

function TRecDB.rRecno;
begin
  result:=TblFldName(RecnoWhere(FFRecNo,lEq));
end;

function TRecDB.GetFieldList(var ls: TMQFieldList): boolean;
begin
  AddStack('TRecDB.GetFieldList',Self);
  result:=MulQry.GetFieldList(Connection,FNameDB,ls);
  DelStack;
end;

function TRecDB.GetFieldList: TMQFieldList;
begin
  AddStack('TRecDB.GetFieldList',Self);
  result:=MulQry.GetFieldList(Connection,FNameDB);
  DelStack;
end;

procedure TRecDB.HelpTblAdd;
var i: byte;
begin
  AddStack('TRecDB.HelpTblAdd',Self);
  for i:=low(anmf) to high(anmf) do begin
    Inc(n); CopyFrom(ht.Dat[n],Space(offs)+FRup(GetPrimFld(anmf[i]))+prim);
  end;
  DelStack;
end;

procedure TRecDB.FldAddList;
var f: TFld;
  fa: TFldMemoAttr;
  fl: boolean;
  Opt: TVarToSOpt;
  faPrm: string;
begin
	AddStack('TRecDB.FldAddList',Self);
	//admsgfile('FldAddList');
  f:=Field[i]; fl:=true;
  for fa:=low(aMemo) to high(aMemo) do with aMemo[fa] do if beg<>'' then if f.Info.Attr=attr then begin
    faPrm:='';
    if Assigned(OnGetMemPrm) then OnGetMemPrm(Self,i,fa,faPrm);
    FSetMem(f,FieldName[i],a,fa,faPrm); fl:=false; break;
  end;
  if fl then with FQuery do begin
    AddArgList(sC_LIST,Self.FieldName[i]);
    Opt:=[vsQQ];
    if FDateWithTime then Include(Opt,vsDateWithTime);
    AddArgList(sV_LIST,VarToS(f.Value,Opt));
  end;
  DelStack;
end;

procedure TRecDB.FSetMem;
var oc,ov,v: string;
  nGkMem: longword;
begin
  AddStack('TRecDB.FSetMem',Self);
  with FQuery do begin
  	FDelMemValue(f.MemGk,a,fa,faPrm); v:=f.Value;
    if fa=famSel then TrimRightSelf(v);
    if v='' then begin
    	AddArgList(sC_LIST,nmf); AddArgList(sV_LIST,0); f.MemGk:=0;
    end
    else begin
      oc:=Arg[sC_LIST]; ov:=Arg[sV_LIST];
      repeat
        nGkMem:=GetMaxFld(fMGK,aMemoTbl[fa]);
      until nGkMem<>f.MemGk;
      SetMemValue(nGkMem,f.Value,FQuery,[memNoDelPrior],fa,faPrm,FNameDB,nmf);
      Arg[sC_LIST]:=oc; Arg[sV_LIST]:=ov;
      AddArgList(sC_LIST,nmf); AddArgList(sV_LIST,longint(nGkMem));
      f.MemGk:=nGkMem;
    end;
  end;
  DelStack;
end;

class procedure TRecDB.FDelMemValue;
begin
  AddStack('TRecDB.FDelMemValue');
  AddGK(gk,a,fa);
  DelStack;
end;

function TRecDB.GetMaxFld;
begin
	AddStack('TRecDB.GetMaxFld',Self);
  result:=FQuery.GetMaxFld(nmFld,IfThen(nmTbl='',NameDB,nmTbl),pVal,lSave,where);
  FQuery.Arg[sTABLE]:=NameDB;
  DelStack;
end;

procedure TRecDB.GetMaxFldSelf;
begin
  Value[nmFld]:=GetMaxFld(nmFld);
end;

procedure TRecDB.FixFldClear;
begin
  AddStack('TRecDB.FixFldClear',Self);
  LsDBClearTbl(Connection,FNameDB);
  DelStack;
end;

class function TRecDB.Init;
begin
  AddStack('TRecDB.Init');
  result := not Assigned(r);
  if result then begin
  	r:=TRecDB.Create(Application.MainForm); r.NameDB:=NameDB; r.MsgCheck:=MsgCheck;
    r.OnCalculate:=PrCalculate; r.OnNewRec:=PrNewRec; r.OpenRec;
  end;
  res:=r;
  DelStack;
end;

class procedure TRecDB.SaveInf(const a: array of TRecDB; var svi: TRDBSaveInf; lClr: boolean = true);
var i,j: longint;
begin
  AddStack('TRecDB.SaveInf');
  if lClr then svi:=nil;
  j:=Length(svi); i:=Length(a); SetLength(svi,j+i);
  for i:=0 to i-1 do with svi[j] do begin
  	r:=a[i];
    if Assigned(r) then begin
      recno:=a[i].Recno; r.GetAFieldValue(af);
      if r is TRecDBDef then Def:=TRecDBDef(r).FFldDef.Text;
    end;
    Inc(j);
  end;
  DelStack;
end;

procedure TRecDB.SaveInf(var svi: TRDBSaveInf; lClr: boolean = true);
begin
  SaveInf(Self,svi,lClr);
end;

class procedure TRecDB.RestInf;
var i: longint;
begin
	AddStack('TRecDB.RestInf');
  for i:=low(svi) to high(svi) do with svi[i] do if Assigned(r) then begin
    if r is TRecDBDef then with TRecDBDef(r) do
    	if not AutoFillDop then SetFldDefText(Def);
  	if r.RecNo<>recno then
	  	if recno=0 then r.NewRec([newrNoDoNewRec]) else r.FFRecNo:=recno; //r.GotoRec(recno);
    r.SetAFieldValue(af,false);
  end;
  DelStack;
end;

class procedure TRecDB.DeleteTable{(const nmr: string; const where: string = '*'; q: TMulQuery = nil)};
var r: TCustomRec;
	fl: boolean;
begin
	AddStack('TRecDB.DeleteTable');
  if RecName(nmr,r,TRecDB) then TRecDB(r).DelRec(where)
  else begin
  	fl:=not Assigned(q);
    if fl then q:=GetQuery;
    q.DeleteTable(nmr,IfThen(where<>'*',where));
    if fl then FreeQuery;
  end;
  DelStack;
end;

{class procedure TRecDB.DeleteTable(const nmr: string; const azn: array of string;
  l: longint = NegDef; const nmf: string = fRECNO; q: TMulQuery = nil);
var a: TArrStr;
  i: longint;
begin
  AddStack('TRecDB.DeleteTable(list)');
  FldInList(a,nmf,azn,l);
  for i:=low(a) to high(a) do DeleteTable(nmr,a[i],q);
  DelStack;
end;}

function TRecDB.DelRec(const where: string = ''; Opt: TRDBDelOpt = []): boolean;
var lCur: boolean;
	w: string;
begin
	AddStack('TRecDB.DelRec',Self);
	//admsgfile('DelRec');
	if not Active then raise ERecDBError.Create(
  	'Ошибка удаления записи (DelRec):'+CRLF+'база '+FNameDB+' закрыта');
  w:=where; lCur := w=''; result:=true;
  if not lCur or (FFRecNo<>0) then begin
    if not lCur then NewRec([newrNoDoNewRec]);
    with FQuery do begin
      if lCur then w:=rRecno
      else if w='*' then w:='';
      if not (delNoMemo in Opt) then DelMemo(w);
      result:=DeleteTable(FNameDB,w,delMsg in Opt);
      if lCur then begin
        if delLog in Opt then LogWrite;
        FFRecNo:=0;
      end;
    end;
  end;
  DelStack;
end;

function TRecDB.DelRec(const azn: array of string; l: longint = NegDef;
  const nmf: string = fRECNO; Opt: TRDBDelOpt = []; const where: string = ''): boolean;
var a: TArrStr;
begin
  AddStack('TRecDB.DelRec(list)',Self);
  FldInList(a,nmf,azn,l); result:=DelRecList(a,Opt,where);
  DelStack;
end;

function TRecDB.DelRec(const azn: array of integer; l: longint = NegDef;
  const nmf: string = fRECNO; Opt: TRDBDelOpt = []; const where: string = ''): boolean;
begin
  result:=DelRec(QQa(azn,l),NegDef,nmf,Opt,where);
end;

function TRecDB.DelRec(ls: TIntegerList;
  const nmf: string = fRECNO; Opt: TRDBDelOpt = []; const where: string = ''): boolean;
var a: TArrStr;
begin
  AddStack('TRecDB.DelRec(TIntegerList)',Self);
  ls.FldInListQQ(a,nmf); result:=DelRecList(a,Opt,where);
  DelStack;
end;

function TRecDB.DelRecList;
var i: longint;
begin
  AddStack('TRecDB.DelRecList',Self);
  result:=true;
  for i:=low(awhere) to high(awhere) do if not DelRec(awhere[i]+where,Opt) then begin
    result:=false; break;
  end;
  DelStack;
end;

function TRecDB.CompBegFixSt;
var s: string;
begin
	AddStack('TRecDB.CompBegFixSt',Self);
  s:=aBegMem[fa];
  if Assigned(Self) then s:=FixSt(s);
  result:=AnsiStartsText(s,nmf);
  DelStack;
end;

function TRecDB.FixSt;
begin
  result:=sBeg;
end;

function TRecDB.DelMemo;
var a: TRDBFldGetRec;
  afld: TFldMemoAttrArrInt;
  fa: TFldMemoAttr;
  s: string;
	i,n: longint;
  lsf: TMQFieldList;
begin
	AddStack('TRecDB.DelMemo');
  if not Assigned(Proc) then Proc:=CompBegFixSt;
  GetFieldList(lsf);
  for fa:=low(a) to high(a) do with a[fa] do begin
  	SetLength(afld[fa],lsf.Count); Len:=0;
  end;
  FQuery.Arg[sC_LIST]:=''; n:=0;
  for i:=0 to lsf.Count-1 do begin
  	s:=AnsiUpperCase(lsf[i]);
	  for fa:=low(a) to high(a) do if Proc(s,fa) then with a[fa] do begin
      FQuery.AddArgList(sC_LIST,lsf[i]); afld[fa,Len]:=n; Inc(n); Inc(Len);
    end;
  end;
  if n=0 then result:=true
  else begin
    for fa:=low(a) to high(a) do with a[fa] do begin
      SetLength(afld[fa],Len); agk:=nil; Len:=0;
    end;
    FQuery.PartSelect(NameDB,'',where);
    while not FQuery.Eof do begin
      for fa:=low(a) to high(a) do
        for i:=low(afld[fa]) to high(afld[fa]) do
          FDelMemValue(FQuery.Fields[afld[fa,i]].AsInteger,a,fa,GetDelMemKA(fa,FQuery.Fields[afld[fa,i]]));
      FQuery.Next;
    end;
    result:=DelFldInList(a,FQuery);
  end;
  DelStack;
end;

function TRecDB.GetDelMemKA;
begin
  result:='';
end;

// Следующий код при добавлении
function TRecDB.KodNext;
var fi: PMQFieldInfo;
  lStr: boolean;
  tbl: string;
  procedure pInit;
  begin
  	AddStack('TRecDB.KodNext.pInit',Self);
    if not Assigned(fi) then GetFieldInfo(Connection,tbl,NmFld,fi);
    lStr := fi.DataType=ftString;
    DelStack;
  end;
var ll,n: longint;
  v: variant;
  lHole: boolean;
  w: string;
begin
	AddStack('TRecDB.KodNext',Self);
	//admsgfile('KodNext');
  if Assigned(FOnKodNext) then result:=FOnKodNext(Self,NmFld,Flt)
  else with FQuery do begin
    tbl:=IfThen(ctbl='',NameDB,ctbl); fi:=nil;
    if l=0 then begin
      pInit; l:=fi.Size;
    end;
    if BegNum=0 then begin
      PartMax(tbl,NmFld,Flt);
      if Eof then n:=1 else n:=Int0(Fields[0].AsString)+1;
      result:=IntToStr(n); lHole := Length(result)>l; n:=1; w:='';
    end
    else begin
      lHole:=true; n:=BegNum; pInit;
      if lStr then w:=QQi(BegNum,l) else w:=Vtos(BegNum);
      IncL(w,sAND+NmFld+'>=');
    end;
   	if lHole and (l>0) then begin
    	ll:=Int0(StringOfChar('9',l)); pInit;
	    PartSelect(tbl,NmFld,DlmBetween(Flt,NmFld+'<>'+IfThen(lStr,QQs,VToS)+w,sAND),NmFld,NmFld);
      while not Eof do begin
        v:=FieldValueIndex(0);
        if lStr then Int0Self(v);
        if v<>n then break;
        Next; Inc(n);
      end;
	    result:=IfThen(n<=ll,IntToStr(n));
    end;
    if l>0 then My_pr.SpaceStrSelf(result,l);
    Close; Arg[sTABLE]:=NameDB;
  end;
  DelStack;
end;

procedure TRecDB.KodNextSelf;
begin
  Value[NmFld]:=KodNext(NmFld,Flt,l,ctbl,BegNum);
end;

// Проверка корректности кода
function TRecDB.KodCheck;
var f: TFld;
	Msg: string;
begin
	AddStack('TRecDB.KodCheck',Self);
	//admsgfile('KodCheck');
  if Assigned(FOnKodCheck) then result:=FOnKodCheck(Self,NmFld,Flt,Opt) else result:=true;
  if result then with FQuery do begin
		result:=false; FldName(NmFld,f);
		if not(chkNoEmpty in Opt) and Empty(f.Value)
      then meserr('Значение не должно быть пустым.')
    else if not(chkNoSpace in Opt) and (Pos(' ',Trim(f.Value))>0)
      then meserr('Значение не должно содержать пробелы.')
    else begin
      result:=PartCount0(IfThen(ctbl='',NameDB,ctbl),
        DlmBetween([NmFld+'='+VarToS(f.Value,vsQQ),rRecno(false),BrackNoEmp(Flt)],sAND));
      if not result then if not IfThenNotify(ProcMsgEq,Self) then begin
        Msg:=cMsg;
        if Msg='' then Msg:=FMsgCheck;
        if Msg='' then Msg:='Такой код уже есть в справочнике.';
        mess_ok([Msg]);
      end;
      Close;
    end;
  end;
  DelStack;
end;

function TRecDB.Seek;
begin
	AddStack('TRecDB.Seek',Self);
	with GetQuery(Connection) do begin
    PartSelect(NameDB,[],where,order);
    if seekDescending in Opt then Last;
    result:=IsRecords; GetRec(CurQuery,0,[],fRECNO,nil,IfThen(seekNoMemo in Opt,[],FldMemoAttrAll)); FreeQuery;
  end;
  DelStack;
end;

function TRecDB.SeekMsg;
var svi: TRDBSaveInf;
  a: TArrStr;
  i: longint;
begin
  AddStack('TRecDB.SeekMsg',Self);
  SaveInf(svi); result:=Seek(where);
  if result then begin
    if Assigned(FOnSeekMsg) then CopyFrom(a,FOnSeekMsg(Self))
    else for i:=0 to LsArrDynamic(LogPrim,a,LogDlm,lsaSetLen)-1 do FRupSelf(a[i]);
    InsFrom(a,msg); mess_ok(a);
  end;
  RestInf(svi);
  DelStack;
end;

procedure TRecDB.LogPrim(var a: TArrStr; q: TMulQuery = nil);
var h: longint;
begin
  a:=nil; LogPrim(a,h,q);
end;

procedure TRecDB.LogPrim(var a: TArrStr; var h: longint; q: TMulQuery = nil; lMemo: boolean = true);
var i: longint;
begin
  AddStack('TRecDB.LogPrim',Self);
  h:=TMulQuery.QryCur(q).RecordCount;
  if Length(a)<h then SetLength(a,h);
  Dec(h);
  for i:=0 to h do begin
    GetFromQuery(q,lMemo); a[i]:=LogPrim; q.Next;
  end;
  DelStack;
end;

procedure TRecDB.GetFromQuery;
begin
	AddStack('TRecDB.GetFromQuery',Self);
  GetRec(q.QryCur,0,[],nmrecno,LsDupl,IfThen(lMemo,FldMemoAttrAll,[]));
  DelStack;
end;

procedure TRecDB.SetMemGK;
var f: TFld;
  fa: TFldMemoAttr;
begin
	AddStack('TRecDB.SetMemGK',Self);
  if FldName(nmf,f) then begin
    FQuery.PartSelect(NameDB,nmf,TblFldName(nmf)+'='+Vtos(gk),'','',false);
    with TMemGKList.Create(Self,FQuery) do try
      for fa:=low(aBegMem) to high(aBegMem) do if CompBegFixSt(nmf,fa) then begin
        if FSetMemGKVal(f,gk,GetValue(gk,fa))='' then f.MemGk:=0;
        break;
      end;
    finally
      Free;
    end;
  end;
  DelStack;
end;

procedure TRecDB.SetRecno;
var i: longint;
begin
  AddStack('TRecDB.SetRecno',Self);
  FFRecNo:=Value;
  for i:=0 to FieldCount-1 do Field[i].Modified:=false;
  DelStack;
end;

class function TRecDB.FSetMemGKVal;
begin
	AddStack('TRecDB.FSetMemGKVal');
  f.MemGk:=gk; f.Info.Value:=v; result:=v;
  DelStack;
end;

class procedure TRecDB.SetMemGKVal;
//var fl: boolean;
begin
	AddStack('TRecDB.SetMemGKVal');
  //fl := f.MemGk<>0;
  f.OldValue:=FSetMemGKVal(f,gk,v);
  //if fl and (f.OldValue='') then f.OldValue:='~';
  DelStack;
end;

function GetLenMemoZn(q: TMulQuery): byte;
var fi: PMQFieldInfo;
begin
  AddStack('Recdb.GetLenMemoZn');
  if GetFieldInfo(q.Connection,tMEMO,fMZN,fi) then result:=fi.Size else result:=0;
  DelStack;
end;

class procedure TRecDB.SetMemValue;
var s1,v,plist,stf: string;
	j,j1,l: longint;
  lMany: boolean;
  LenMemoZn: byte;
begin
	AddStack('TRecDB.SetMemValue');
  with q,aMemo[fa] do begin
    Arg[sTABLE]:=aMemoTbl[fa];
    if not(memNoDelPrior in Opt) then begin
      s1:=fMGK+'='+VarTos(longint(gk));
      if fa=famArray then RDBArr.DelRec(s1) else DeleteTable('',s1);
    end;
    if beg<>'' then begin
      if (sTbl<>'') and MulQry.IsField(Connection,aMemoTbl[fa],'FLD')
      then stf:=QQs(TrimUpper(sTbl)+'.'+LeftStrDel(TrimUpper(sFld),beg))
      else stf:='';
      case fa of
        famMemo: begin
          if memNoShifr in Opt then v:=vv else v:=StrShifr(vv);
          l:=Length(v); j:=1; j1:=1; Arg[sV_LIST]:='';
          SetArrayList(sC_LIST,[fMGK,fMNPP,fMZN]);
          if stf<>'' then AddArgList(sC_LIST,'FLD');
          lMany:=not empty(SetPart('im_table')); plist:=IfThen(lMany,'tmp_list',sV_LIST);
          LenMemoZn:=GetLenMemoZn(q);
          while j<=l do begin
            s1:=Copy(v,j,LenMemoZn);
            //if Length(s1)<LenMemoZn then IncD(s1,cEOS);
            SetArrayList(plist,[longint(gk),j1,QQs(s1)]);
            if stf<>'' then AddArgList(plist,stf);
            if lMany then begin
              AddArgList(sV_LIST,BrackNoEmp(Arg[plist]));
              if Length(Arg[sV_LIST])>10000 then begin
                ExecPart('im_table'); Arg[sV_LIST]:='';
              end;
            end
            else ExecPart(sI_TABLE);
            Inc(j,LenMemoZn); Inc(j1);
          end;
          if lMany and (Arg[sV_LIST]<>'') then ExecPart('im_table');
        end;
        famSel: SelCodeGetProc(selSetMemValue,[faPrm,sTbl+'.'+sFld,longint(q),stf,vv,gk]);
      end;
    end;
    if (memClrGK in Opt) and (vv='') and (gk<>0) then UpdateTable(sTbl,[sFld],[0],sFld+'='+VTos(gk));
  end;
  DelStack;
end;

procedure TRecDB.UpdateTable;
begin
	AddStack('TRecDB.UpdateTable',Self);
	FQuery.UpdateTable(FNameDB,c_list,v_list,where);
  SetPLongInt(pRowsAffected,FQuery.RowsAffected);
  DelStack;
end;

procedure TRecDB.UpdateTableFldList(const c_list,v_list: array of variant;
  const azn: array of string; l: longint = NegDef; const nmf: string = fRECNO; Opt: TFldInListOpt = [];
  const where: string = '');
begin
	FQuery.UpdateTableFldList(c_list,v_list,azn,l,nmf,Opt,FNameDB,where);
end;

procedure TRecDB.UpdateTableFldList(const c_list,v_list: array of variant;
  ls: TIntegerList; const nmf: string = fRECNO; const where: string = '');
begin
	FQuery.UpdateTableFldList(c_list,v_list,ls,nmf,FNameDB,where);
end;

procedure TRecDB.UpdateTableList;
var i: longint;
begin
  AddStack('TRecDB.UpdateTableList',Self);
  for i:=low(awhere) to high(awhere) do UpdateTable(c_list,v_list,awhere[i]+where);
  DelStack;
end;

function TRecDB.GetMemGK;
var f: TFld;
begin
	AddStack('TRecDB.GetMemGK',Self);
  result:=0;
  if FldName(nmf,f) then FGetMemGK(f,result); 
  DelStack;
end;

class procedure TRecDB.FGetMemGK;
begin
  AddStack('TRecDB.FGetMemGK');
  if f.Info.Attr in [faMemo,faFixArray,faSel] then result:=f.MemGk;
  DelStack;
end;

function TRecDB.AddCListProc;
begin
  AddStack('TRecDB.AddCListProc',Self);
  result:=true;
  if Assigned(PrAdd) then PrAdd(Self,f,nmFld,Prm,result);
  DelStack;
end;

procedure TRecDB.FAddCList;
begin
	AddStack('TRecDB.FAddCList',Self);
  if AddCListProc(PrAdd,f,nmf,Prm) then q.AddArgList(sC_LIST,tbl+nmf);
	DelStack;
end;

procedure TRecDB.AddCList(q: TMulQuery; const Prm: array of variant;
  PrAdd: TRDBClistAdd = nil; Opt: TRDBAddCListOpt = []);
var i: longint;
  s: string;
begin
	AddStack('TRecDB.AddCList',Self);
  TMulQuery.QryCur(q);
  if addclSet in Opt then q.Arg[sC_LIST]:='';
  s:=IfThen(not(addclNoAlias in Opt),NameDB+'.');
  for i:=0 to FieldCount-1 do
		if Field[i].Info.Attr in setDBReal then FAddCList(q,Prm,PrAdd,Field[i],s,FieldName[i]);
  FAddCList(q,Prm,PrAdd,nil,s,fRECNO);
  DelStack;
end;

procedure PdAddDop(Sender: TRecDB; f: TFld; const nmFld: string; const Prm: array of variant;
  var lDone: boolean);
begin
  AddStack('RecDB.PdAddDop');
  if AnsiStartsText(sLong,nmFld) then Inc(LongIntVar(Prm[0])^) else lDone:=false;
  DelStack;
end;

function TRecDB.AddDop;
begin
  AddStack('TRecDB.AddDop',Self);
  result:=0; AddCList(q,[longint(@result)],PdAddDop);
  DelStack;
end;

function TRecDB.tRecno;
begin
  AddStack('TRecDB.tRecno',Self);
  result:=My_pr.tRecno(NameDB);
  DelStack;
end;

function TRecDB.TblFldName(const nmf: string): string;
begin
  AddStack('TRecDB.TblFldName',Self);
  result:=nmf;
  if (nmf<>'') and Assigned(Self) then IncL(result,NameDB+'.');
  DelStack;
end;

function TRecDB.TblFldName(const nmf: string; lAlias: boolean): string;
begin
  if lAlias then result:=TblFldName(nmf) else TblFldName:=nmf;
end;

{ TRecDBDef }
constructor TRecDBDef.Create;
begin
	AddStack('TRecDBDef.Create',Self);
	inherited Create(AOwner);
	FFldDef:=TStringList.Create; FPart:=SortStrListCreate; FDef:=SortStrListCreate; SetLength(aDef,10);
  FldLong:=nil; ArrCng:=true; NameDB:=NameDB;
  DelStack;
end;

constructor TRecDBDef.CreateFrom;
var rdb: TRecDBDef;
begin
	AddStack('TRecDBDef.CreateFrom',Self);
  inherited CreateFrom(r);
  if IsClass(r,TRecDBDef,pointer(rdb)) then begin
    FFixArr:=rdb.FFixArr; FldDef.Assign(rdb.FldDef);
  end;
  DelStack;
end;

destructor TRecDBDef.Destroy;
begin
	AddStack('TRecDBDef.Destroy',Self);
  inherited Destroy;
	ClearLong; FFldDef.Free; FreeAndNil(FPart); FreeAndNil(FDef); ArrClear(true);
  DelStack;
end;

procedure TRecDBDef.ArrClear;
begin
  AddStack('TRecDBDef.ArrClear',Self);
  ArrCng:=true;
  if Assigned(LsArr) then begin
    FArrCount:=0;
    if lFree then begin
      LsArr^:=nil; Dispose(LsArr); LsArr:=nil;
    end;
  end;
  DelStack;
end;

function TRecDBDef.OpenRec;
var td: TFldDefInf;
	sBeg: string;
  atr: TFldAttr;
	function Crt1: PFldDefInf;
  begin
    AddStack('TRecDBDef.OpenRec.Crt1',Self);
    with td,Inf do begin
      Fld:=FCreateFld(Name,aDWFld[AType].tp,Len,AValue);
      Fld.Info.Attr:=atr; result:=DefAdd(sBeg,td);
    end;
    DelStack;
  end;
const aAtr: array[TFldMemoAttr] of TFldAttr = (faFixMemo,faFixArray,faFixSel);
var i,j,l,l1: longint;
  f: TFld;
  fl: boolean;
  a: TArrStr;
  r: TDWVidRec;
  s: string;
  fa: TFldMemoAttr;
begin
	AddStack('TRecDBDef.OpenRec',Self);
  fl:=not Active; result := inherited OpenRec; AndD(fl,result or Assigned(LsArr)); l:=0;
  if fl then aManyStr:=nil;
  for i:=0 to FFldDef.Count-1 do begin
    td:=GetFldInf(i);
    if td.Inf.Name='' then continue;
    if (td.Inf.SvType=dwsDyn) and (FDynamicVid>0)
      then DDRecDBProc(Self,ddrdbOpenRec,[longint(@td)])
    else if fl then begin
      atr:=faDef;
      if Assigned(LsArr)
      then Crt1.Fld.Value:=VarBlank(aDWFld[td.Inf.AType].tp)
      else begin
        if (td.Inf.AType=dwtSel) and (td.Inf.SvType=dwsNoFix) then begin // для массивов
          td.Inf.SvType:=dwsFix; Delete(td.Inf.dwCod,1,1);
        end;
        if td.Inf.SvType=dwsFix then begin
          sBeg:=FixSt;
          case td.Inf.AType of
            dwtManyStr: begin
              atr:=faManyStr; SetLength(aManyStr,l+1);
              j:=LsArrDynamic(td.Inf.dwCod,a,','); SetLength(aManyStr[l],j); l1:=0;
              for j:=0 to j-1 do if FldName(sBeg+a[j],f) then begin
                aManyStr[l,l1]:=f; Inc(l1);
              end;
              SetLength(aManyStr[l],l1);
              //Crt1.Fld.Info.Value:=LongInt(@aManyStr[l]); Inc(l);
              Crt1.Fld.Info.Value:=l; Inc(l);
            end;
            dwtMany: begin
              atr:=faMany; Crt1;
            end;
          else
            if IsDWFldMemo(td.Inf.AType,fa,sBeg) then atr:=aAtr[fa] else atr:=faFix;
            if FldName(FixSt(sBeg)+td.Inf.dwCod,f) then with Crt1.Fld.Info do begin
              Value:=LongInt(f);
              if (td.Inf.AType=dwtSel) and (td.Inf.SelType=selInt) then DataType:=ftInteger;
            end;
          end;
        end;
      end;
    end;
  end;
  if fl then result := inherited FOpenRec;
  if Active and Assigned(FldLong) and CheckDopSize then begin
    l:=FldLong.Info.Size; fl:=true;
    for i:=0 to FFldDef.Count-1 do begin
      r:=DWSToRec(i);
      if r.SvType=dwsNoFix then begin
        if fl then begin
          fl:=false; Inc(l);
        end;
        Dec(l,Length(r.dwCod)+IfThen(r.AType=dwtBool,1,IfThen(r.AType=dwtDate,10,r.Len))+2);
      end;
    end;
    if l<0 then begin
      s:=Format('%s: необходимо увеличить размер %s на %d символов%s(добавить %d полей длиной %d символов)',
        [Name,sLong,-l,CRLF,Ceil(-l/MaxByte),MaxByte]);
      OutStack(s,[outstMsgOnly]);
      if IsUserGG then MsgDlg(s);
    end;
  end;
  ArrCng:=true;
  DelStack;
end;

function TRecDBDef.FOpenRec;
begin
  result:=true;
end;

class procedure TRecDBDef.RDBArrvCalculate;
begin
  AddStack('TRecDBDef.RDBArrvCalculate');
	with TRecDB(Sender) do Value[fUPNAME]:=AnsiUpperCase(Value[fNAME]);
  DelStack;
end;

class procedure TRecDBDef.RDBArrDWTrans;
begin
	AddStack('TRecDBDef.RDBArrDWTrans');
  if lSave then RDBArrv[DWMem]:=sTrans else sTrans:=RDBArrv[DWMem];
  DelStack;
end;

procedure TRecDBDef.ClearLong;
begin
	AddStack('TRecDBDef.ClearLong',Self);
	FPart.Clear; ClearDef; FldLong:=nil;
  DelStack;
end;

class function TRecDBDef.GetFldInf(const s: string): TFldDefInf;
begin
	AddStack('TRecDBDef.GetFldInf');
  with result do begin
    Inf:=My_pr.DWSToRec(s); AValue:=GetFldInfValue(Inf.AType,Inf.AValue);
  end;
  DelStack;
end;

function TRecDBDef.GetFldInf(i: longint): TFldDefInf;
begin
  result:=GetFldInf(FFldDef[i]);
end;

class function TRecDBDef.GetFldInfValue;
begin
  AddStack('TRecDBDef.GetFldInfValue');
  case t of
    dwtFloat: result:=Float0(v);
    dwtDate: result:=ctod(v);
    dwtBool: result:=AnsiStartsText(bTrue,v);
    dwtArray: result:='';
  else result:=TrimRight(StrDefQQ(v));
  end;
  DelStack;
end;

class function TRecDBDef.FillValue;
var ot: TDWFillList;
	oc: char;
	i,l: longint;
  s: string;
begin
  AddStack('TRecDBDef.FillValue');
  if nDef.AType in [dwtString,dwtManyStr] then begin
  	s:=TrimRight(v); l:=Length(s);
		with oDef do if AType in [dwtString,dwtManyStr] then begin
    	ot:=FillType; oc:=FillChr;
    end
    else begin
      ot:=dwftRight; oc:=' ';
    end;
    if ot=dwftLeft then begin
      i:=1;
      while (i<=l) and ((s[i]<=' ') or (s[i]=oc)) do Inc(i);
      Delete(s,1,i-1);
    end
    else begin
      i:=l;
      while (i>0) and ((s[i]<=' ') or (s[i]=oc)) do Dec(i);
      SetLength(s,i);
    end;
    with nDef do if FillType=dwftLeft then result:=Padl(s,Len,FillChr) else result:=Padr(s,Len,FillChr);
	end
  else result:=v;
  DelStack;
end;

class procedure TRecDBDef.ClearArrDef;
begin
  AddStack('TRecDBDef.ClearArrDef');
  FreeAndNil(LsArrDef);
  DelStack;
end;

procedure ArrDefDel(oi,ni: longint; p: pointer = nil);
begin
  AddStack('Recdb.ArrDefDel');
  aArrDef[ni]:=aArrDef[oi];
  DelStack;
end;

class procedure TRecDBDef.ClearArrDefCod;
var i: longint;
begin
	AddStack('TRecDBDef.ClearArrDefCod');
  if Assigned(LsArrDef) then if LsArrDef.Find(TrimRight(ka),i) then SLObjIndDel(LsArrDef,i,ArrDefDel);
  DelStack;
end;

class function TRecDBDef.GetArrDef;
var p: PRDBArrDef;
begin
  AddStack('TRecDBDef.GetArrDef');
  if PGetArrDef(ka,p) then result:=p^ else Finalize(result);
  DelStack;
end;

class function TRecDBDef.PGetArrDef(const ka: string; var p: PRDBArrDef): boolean;
var s: string;
	i,l: longint;
  a: TArrStr;
  r: TDWVidRec;
begin
	AddStack('TRecDBDef.PGetArrDef');
  s:=TrimRight(ka);
  if IntObjFind(LsArrDef,s,i) then p:=@aArrDef[i]
  else begin
    i:=IfThenCount(LsArrDef);
    if Length(aArrDef)=i then SetLength(aArrDef,i shl 1);
    p:=@aArrDef[i];
    if RDBArrv.Seek(RDBArrv.TblFldName(fARRV)+'='+QQs(s)) then begin
      p.Wnd:=RDBArrv[DWMem(postWin)]; l:=LsArrDynamic(RDBArrv[DWMem],a,CRLF);
    end
    else begin
      RDBArrDef(s,p,a); l:=Length(a);
    end;
    if Assigned(p) then begin
      SortStrListCreate(LsArrDef).AddObject(s,pointer(i)); SetLength(p.aDat,l);
      for i:=0 to l-1 do begin
        r:=My_pr.DWSToRec(a[i]); p.aDat[i]:=r;
        r.SvType:=dwsNoFix; IncL(r.dwCod,aDWFld[r.AType].c); a[i]:=DWRecTos(r);
      end;
      p.Dat:=ArrayAsList(a,CRLF,l); p.FDel:=RDBArrv[fArrvFDEL];
    end;
  end;
  result:=Assigned(p);
  DelStack;
end;

class function TRecDBDef.PGetArrDef(const ka: string): boolean;
var p: PRDBArrDef;
begin
  result:=PGetArrDef(ka,p);
end;

procedure TRecDBDef.FSetMem;
var cod,faPrm: string;
  i: longint;
begin
  AddStack('TRecDBDef.FSetMem',Self);
  faPrm:=cfaPrm;
  if fa=famSel then if Assigned(SelGetReassign) then begin
    cod:=Copy(nmf,Length(sFixSel)+1,MaxInt);
    for i:=0 to FFldDef.Count-1 do with GetFldInf(i),Inf do
      if SvType=dwsFix then if AType=dwtSel then if dwCod=cod then begin
        SelGetReassign(faPrm,Inf); break;
      end;
  end;
  inherited FSetMem(f,nmf,a,fa,faPrm);
  DelStack;
end;

class procedure TRecDBDef.FDelMemValue;
var acod: TArrVar;
	i,l: longint;
  r: PRDBArrDef;
  faa: TFldMemoAttr;
  afa: TFldMemoAttrArr;
  sBeg: string;
begin
	AddStack('TRecDBDef.FDelMemValue');
  inherited FDelMemValue(gk,a,fa,faPrm);
  if (fa=famArray) and (gk>0) then if PGetArrDef(faPrm,r) then begin
  	l:=Length(r.aDat); SetLength(acod,l); SetLength(afa,l); l:=0;
    for i:=low(r.aDat) to high(r.aDat) do with r.aDat[i] do
      if IsDWFldMemo(AType,faa,sBeg) then begin
      	acod[l]:=sBeg+dwCod; afa[l]:=faa; Inc(l);
      end;
    if l>0 then begin
    	SetLength(acod,l);
      with GetQuery do begin
        PartSelect(tARR,acod,fMGK+'='+VTos(gk));
        while not Eof do begin
        	for i:=0 to FieldCount-1 do AddGK(Fields[i].AsInteger,a,afa[i]);
        	Next;
        end;
        FreeQuery;
      end;
    end;
  end;
  DelStack;
end;

function TRecDBDef.GetDelMemKA;
var s: string;
	i: longint;
begin
	AddStack('TRecDBDef.GetDelMemKA',Self);
  result := inherited GetDelMemKA(fa,f);
  if fa=famArray then begin
  	s:=TrimUpper(Copy(f.FieldName,Length(FixSt(sArray))+1,MaxInt));
    for i:=0 to FDef.Count-1 do with FldDefInf(i).Inf do
    	if (SvType=dwsFix) and (AType=dwtArray) and (TrimUpper(dwCod)=s) then begin
      	result:=AValue; break;
      end;
  end;
  DelStack;
end;

class procedure TRecDBDef.SetMemValue;
var r: PRDBArrDef;
  t,t1: TDWFldType;
	sc,sz,sBeg: string;
	i,j,l,ir,iv: longint;
  c: char;
  a: TArrStr;
  ar,av: TArrPosLen;
begin
	AddStack('TRecDBDef.SetMemValue');
  inherited SetMemValue(gk,vv,q,Opt,fa,faPrm,sTbl,sFld);
  if fa=famArray then
    if not empty(vv) then begin
      StrDlmArr(vv,1,Length(vv),cCRLF,ar); PGetArrDef(faPrm,r);
      for ir:=low(ar) to high(ar) do with RDBArr do begin
        NewRec; StrDlmArr(vv,ar[ir].Pos,ar[ir].Len,cDlm,av); iv:=low(av);
        while iv<=high(av) do begin
          sc:=TrimRight(Copy(vv,av[iv].Pos,av[iv].Len)); c:=StrToChar(sc); t1:=dwtString;
          for t:=low(aDWFld) to high(aDWFld) do if aDWFld[t].c=c then begin
            t1:=t; break;
          end;
          Delete(sc,1,1); Inc(iv);
          if iv>high(av) then sz:='' else sz:=TrimRight(Copy(vv,av[iv].Pos,av[iv].Len));
          if Assigned(r) then for i:=low(r.aDat) to high(r.aDat) do with r.aDat[i] do begin
            t:=AType;
            if (t=t1) and (dwCod=sc) then begin
              {if t=dwtSel then Value[Name]:=sz
              else begin}
                if not IsDWFldMemo(t,sBeg) then case t of
                  dwtBool: t:=dwtString;
                  dwtManyStr: begin
                    StrTranSelf(sz,CRLF,cManyStrCRLF); l:=1;
                    for j:=0 to LsArrDynamic(sc,a,',')-1 do begin
                      Value[sBeg+a[j]]:=TransFromLongVal({r.aDat[i],}aDWFld[t].tp,Copy(sz,l,MaxInt));
                      Inc(l,FldName(sBeg+a[j]).Info.Size);
                    end;
                    continue;
                  end;
                end;
                Value[sBeg+sc]:=TransFromLongVal({r.aDat[i],}aDWFld[t].tp,sz);
              //end;
              break;
            end;
          end;
          Inc(iv);
        end;
        Value[fARRV]:=faPrm; Value[fMGK]:=longint(gk); Value[fMNPP]:=ir; AppRec;
      end;
    end;
  DelStack;
end;

class function TRecDBDef.ArrRdb;
var i: longint;
begin
  AddStack('TRecDBDef.ArrRdb');
  SetLength(result,Length(a));
  for i:=low(a) to high(a) do result[i]:=a[i];
  DelStack;
end;

class function TRecDBDef.ArrDWRdbSeek;
begin
	AddStack('TRecDBDef.ArrDWRdbSeek');
  {if Assigned(CurRdbArr) then }result:=CurRdbArr{ else result:=pointer(Sender)};
  DelStack;
end;

class procedure TRecDBDef.SaveInf(const a: array of TRecDBDef; var svi: TRDBSaveInf; lClr: boolean = true);
begin
  AddStack('TRecDBDef.SaveInf');
  SaveInf(ArrRdb(a),svi,lClr);
  DelStack;
end;

function TRecDBDef.DefAdd;
var n: longint;
begin
  AddStack('TRecDBDef.DefAdd',Self);
  if not IntObjFindAdd(FDef,sBeg+td.Inf.dwCod,n) then
    if Length(aDef)=n then SetLength(aDef,n shl 1);
  result:=@aDef[n]; result^:=td;
  DelStack;
end;

procedure TRecDBDef.ClearDef;
var pd: PFldDefInf;
	i,j: longint;
begin
	AddStack('TRecDBDef.ClearDef',Self);
	if Assigned(FDef) then begin
    for i:=0 to FDef.Count-1 do begin
      pd:=FldDefInf(i); pd.Fld.Free; FieldFind(pd.Inf.Name,j); FieldDel(j);
    end;
    FDef.Clear;
  end;
  DelStack;
end;

procedure TRecDBDef.SetNameDB;
begin
	AddStack('TRecDBDef.SetNameDB',Self);
  if v<>'' then ArrClear(true)
  else if not Assigned(LsArr) then begin
    New(LsArr); FArrCount:=0;
  end;
  inherited SetNameDB(v);
  DelStack;
end;

function TRecDBDef.GetRec;
var i,j: longint;
begin
	AddStack('TRecDBDef.GetRec',Self);
  if Assigned(LsArr) then begin
  	result:=InRange(rec,1,ArrCount);
    if result then begin
    	FFRecNo:=rec; j:=(rec-1)*FieldCount;
      for i:=0 to FieldCount-1 do with Field[i] do begin
        Modified:=false; Value:=LsArr^[j]; Inc(j);
      end;
    end
    else FFRecNo:=0;
  end
  else begin
    result := inherited GetRec(q,rec,Opt,nmrecno,lsDupl,ais);
    if not(rgetNoDupl in Opt) then ClearDuplModified;
  end;
  DelStack;
end;

procedure TRecDBDef.ClearDuplModified;
var i: longint;
  f: TFld;
begin
  AddStack('TRecDBDef.ClearDuplModified',Self);
  for i:=0 to FieldCount-1 do with Field[i] do if DuplFld(f) then Modified:=false;
  DelStack;
end;

function TRecDBDef.FFldUpdate;
  procedure DWMany(Oper: TDWTypeManyOper);
  var i: LongInt;
    pd: PFldDefInf;
  begin
  	AddStack('TRecDBDef.FFldUpdate.DWMany',Self);
    if Assigned(DWTypeManyProc) then for i:=0 to FDef.Count-1 do begin
      pd:=FldDefInf(i);
      if pd.Inf.AType=dwtMany
      then DWTypeManyProc(Oper,[longint(Self),longint(pd)]);
    end;
    DelStack;
  end;
var i,nRec: LongInt;
begin
	AddStack('TRecDBDef.FFldUpdate',Self);
  if Assigned(LsArr) then begin
  	result:=true;
    if lmod then nRec:=FFRecNo
    else begin
      ArrCount:=ArrCount+1; nRec:=ArrCount;
    end;
    nRec:=(nRec-1)*FieldCount;
    for i:=0 to FieldCount-1 do begin
      LsArr^[nRec]:=Field[i].Value; Inc(nRec);
    end;
    ArrCng:=true;
  end
  else begin
    DWMany(dwtoBeforeUpd);
    result := inherited FFldUpdate(PartSQL,lmod,MemGkSet,af,logp,pRowsAffected,where);
    DWMany(dwtoAfterUpd);
  end;
  DelStack;
end;

function TRecDBDef.GetMaxFld;
begin
	AddStack('TRecDBDef.GetMaxFld',Self);
  if Assigned(LsArr)
  then result:=ArrCount+1
  else result:=inherited GetMaxFld(nmFld,nmTbl,pVal,lSave,where);
  DelStack;
end;

procedure TRecDBDef.SetFldDef;
begin
	AddStack('TRecDBDef.SetFldDef',Self);
	FFldDef.Assign(v);
  DelStack;
end;

procedure TRecDBDef.SetDynamicVid;
begin
  AddStack('TRecDBDef.SetDynamicVid',Self);
  if FDynamicVid<>Value then begin
    FDynamicVid:=Value; SetDDat;
  end;
  DelStack;
end;

procedure TRecDBDef.SetDDatMaxLenCod;
begin
  AddStack('TRecDBDef.SetDDatMaxLenCod',Self);
  if FDDatMaxLenCod<>Value then begin
    FDDatMaxLenCod:=Value; SetDDat;
  end;
  DelStack;
end;

procedure TRecDBDef.SetDDatIsCod;
begin
  AddStack('TRecDBDef.SetDDatIsCod',Self);
  if FDDatIsCod<>Value then begin
    FDDatIsCod:=Value; SetDDat;
  end;
  DelStack;
end;

procedure TRecDBDef.SetDDatBeforeModify;
begin
  AddStack('TRecDBDef.SetDDatBeforeModify',Self);
  FOnDDatBeforeModify:=Value; SetDDat;
  DelStack;
end;

function TRecDBDef.GetDimDDatModify;
begin
  AddStack('TRecDBDef.GetDimDDatModify',Self);
  result:=FDimDDatModify[Index];
  DelStack;
end;

procedure TRecDBDef.SetDimDDatModify;
begin
  AddStack('TRecDBDef.SetDimDDatModify',Self);
  FDimDDatModify[Index]:=Value; SetDDat;
  DelStack;
end;

procedure TRecDBDef.SetDDat;
begin
  DDRecDBProc(Self,ddrdbSetDDat,[]);
end;

procedure TRecDBDef.GetLongVal;
begin
	AddStack('TRecDBDef.GetLongVal',Self);
	if Assigned(FldLong) then FldLong.Value:=FGetLongVal;
  FLongModified:=false;
  DelStack;
end;

function TRecDBDef.FGetLongVal;
var i: longint;
begin
  AddStack('TRecDBDef.FGetLongVal',Self);
  result:='';
  for i:=0 to FDef.Count-1 do with FldDefInf(i)^ do
    if Fld.Info.Attr=faDef
    then IncD(result,FDef[i]+cDlm+TransToLongVal(Inf,Fld.Info.DataType,Fld.Info.Value)+cDlm);
  DecLen(result,lDlm);
  DelStack;
end;

procedure TRecDBDef.SetLongVal;
begin
	AddStack('TRecDBDef.SetLongVal',Self);
	if Assigned(FldLong)
  then FSetLongVal(FldLong.Info.Value,1,Length(FldLong.Info.Value))
  else FSetLongVal('',1,0);
  FLongModified:=false;
  DelStack;
end;

procedure TRecDBDef.FSetLongVal;
var i: longint;
  pd: PFldDefInf;
  fl: boolean;
  a: TArrPosLen;
  f: TFld;
  vr: variant;
begin
  AddStack('TRecDBDef.FSetLongVal',Self);
  for i:=0 to FDef.Count-1 do begin
  	pd:=FldDefInf(i);
    if pd.Fld.Info.Attr=faDef then pd.Fld.Info.Value:=pd.AValue;
  end;
  StrDlmArr(cv,p,l,cDlm,a); i:=low(a);
  while i<=high(a) do begin
    fl:=FldDefInf(TrimRight(Copy(cv,a[i].Pos,a[i].Len)),pd); Inc(i);
    if fl then begin
    	f:=pd.Fld;
      if f.Info.Attr=faDef then begin
        if i>high(a) then vr:='' else vr:=TrimRight(Copy(cv,a[i].Pos,a[i].Len));
        vr:=TransFromLongVal(pd.Fld.Info.DataType,vr);
        if pd.Fld.Info.DataType=ftString then PadRSelf(vr,f.Info.Size);
        f.Info.Value:=vr;
      end;
    end;
    Inc(i);
  end;
  DelStack;
end;

procedure TRecDBDef.SetValue;
var f: TFld;
  fl: boolean;
  svi: TRDBSaveInf;
begin
  AddStack('TRecDBDef.SetValue',Self);
  if AutoFillDop then begin
    if FldName(Index,f) then
      if f.Info.Attr=faDef then fl := f.Info.Size<Length(v) else fl:=false
    else fl:=true;
    if fl then begin
      SaveInf(svi); CloseRec;
      CreateFld(Index,ftString,Length(v),0,v,'');
      OpenRec; RestInf(svi);
    end;
  end;
  inherited SetValue(Index,v);
  DelStack;
end;

procedure TRecDBDef.FCloseRec;
begin
	AddStack('TRecDBDef.FCloseRec',Self);
  ClearLong; ArrClear; DDRecDBProc(Self,ddrdbCloseRec,[]);
  inherited FCloseRec;
  DelStack;
end;

function TRecDBDef.FldGetValue;
var p: PArrFld;
  i: longint;
begin
  {$IFDEF STACKALL}AddStack('TRecDBDef.FldGetValue',Self);{$ENDIF}
  result:=inherited FldGetValue(Sender,v);
  case Sender.Info.Attr of
    faManyStr: begin
      result:=false; v:=''; p:=@aManyStr[longint(Sender.Info.Value)];
      for i:=low(p^) to high(p^) do IncD(v,p^[i].Info.Value);
      v:=Padr(StrTran(v,cManyStrCRLF,CRLF),Sender.Info.Size);
    end;
    faLong: GetLongVal;
    faMany: DWTypeMany(dwtoGetValue,[longint(Self),longint(Sender),longint(@result),longint(@v)]);
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TRecDBDef.FldSetValue;
var p: PArrFld;
  i: longint;
  f: TFld;
  pd: PFldDefInf;
begin
  {$IFDEF STACKALL}AddStack('TRecDBDef.FldSetValue',Self);{$ENDIF}
  result:=inherited FldSetValue(Sender,v,Oper);
  with Sender,Info do case Oper of
    fsvOwner: if not result then begin
      if Attr in setDBDupl then begin
        if DuplFld(f) then begin
          case Attr of
            faDefMemo: FLongModified:=true;
            faFix: if DataType=ftBoolean then v:=Bool2Str(iif(MyVarType(v)=varBoolean,v,false));
            faFixSel: if DataType=ftInteger then begin
              if CompVar(v,0) then v:='' else IntToStrSelf(v);
              for i:=0 to FDef.Count-1 do begin
                pd:=FldDefInf(i);
                if pd.Fld=Sender then begin
                  SelCodeGetProc(selValTrans,[longint(@v),longint(pd)]); break;
                end;
              end;
            end;
          end;
          f.Value:=v;
        end;
        result:=true;
      end
      else case Attr of
        faManyStr: begin
          if MyVarType(Value)=varInteger then begin
            p:=@aManyStr[longint(Value)]; StrTranSelf(v,CRLF,cManyStrCRLF);
            for i:=low(p^) to high(p^) do with p^[i] do begin
              Value:=LeftStr(v,Info.Size); DeleteVar(v,1,Info.Size);
            end;
          end;
          result:=true;
        end;
        faMany: DWTypeMany(dwtoSetValue,[longint(Self),longint(Sender),longint(@result),longint(@v)]);
      end;
    end;
    fsvBefore: case Attr of
      faDef: FLongModified:=true;
      faLong: if FLongModified then Value:=FGetLongVal;
    end;
    fsvAfter: if Attr=faLong then SetLongVal;
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TRecDBDef.FLogPrim;
var ls: {TFldList}TStringList;
  n: longint;
  f: TFld;
  procedure dws(nv: byte; lOld: boolean);
  var v: PString;
  begin
    AddStack('TRecDBDef.FLogPrim.dws',Self);
    v:=PointerVar(av[nv]); RDBLogPrimOper(ls,rdblgGetVal,[longint(v),n]);
    if UnDataType(f) in [ftInteger,ftFloat] then TrimSelf(v^) else TrimRightSelf(v^);
    LogTrnsVal(Prm,v^,lOld); TrimRightSelf(v^);
    DelStack;
  end;
var i: longint;
  fv: variant;
  q: string;
label lend;
begin
  AddStack('TRecDBDef.FLogPrim',Self);
  case Oper of
    logpIsFld: if IsFldFix(longint(av[1])) then begin
      SetPBoolean(av[0]); goto lend;
    end;
    logpGet: begin
      if Length(ap)>1 then ls:=PointerVar(ap[1])
      else begin
        RDBLogPrimOper(ls,rdblgCreate,[longint(Self)]); AddFromVArr(ap,[longint(ls)]);
      end;
      i:=av[1];
      if ls.Find(FieldName[i],n) then begin
        RDBLogPrimOper(ls,rdblgGetName,[longint(@Prm.nm),n]);
        if Prm.nm='' then Prm.nm:=GetPrimFld(FieldName[i]);
        f:=Field[i];
        if logpMod in TLogPrimOptions(byte(av[2])) then begin
          fv:=f.Value; f.Value:=av[3]; dws(4,true); f.Value:=fv;
        end;
        dws(5,false); SetPBoolean(av[0]); goto lend;
      end
    end;
    logpGet1: if Field[longint(av[1])].Info.Attr=faFixArray then begin
      Prm.val:=''; ArrLogCompare(Prm,av[2],av[3]); TrimRightSelf(Prm.val);
      q:=IfThen(Pos(CRLF,Prm.val)=0,'"',CRLF); IncD(Prm.nm,q+Prm.val+q);
      SetPBoolean(av[0]); goto lend;
    end;
    logpFree: if Length(ap)>1 then StringListVar(ap[1]).Free;
  end;
  inherited FLogPrim(Prm,Oper,av,ap);
lend:
  DelStack;
end;

procedure TRecDBDef.CreateFld(const AName,ACod: string; AType: TFieldType;
  ASize,ADec: longint; const cValue: variant; const APrim: string);
var AValue: variant;
begin
	AddStack('TRecDBDef.CreateFld',Self);
  case UnDataType(AType) of
    ftInteger,ftFloat:
    	AValue:=Format('N%d.%d',[ASize,ADec])+UnDelim+MyFloatToStr(cValue,FloatMaxLen,FloatMaxDec);
    ftBoolean:
    	AValue:='L'+UnDelim+Bool2Str(cValue);
    ftDate:
    	AValue:='D'+UnDelim+dtoc(cValue);
    ftArray:
    	AValue:='XA'+UnDelim+cValue;
  else AValue:=StrNum('S',ASize)+UnDelim+'"'+cValue+'"';
  end;
	FFldDef.Values[AName]:=ACod+UnDelim+AValue+UnDelim+APrim;
  DelStack;
end;

procedure TRecDBDef.CreateFld(const AName: string; AType: TFieldType;
  ASize,ADec: longint; const cValue: variant; const APrim: string);
begin
  CreateFld(AName,AName,AType,ASize,ADec,cValue,APrim);
end;

function TRecDBDef.FCreateFld;
var p: PPosLen;
	i,j,k: longint;
	td: TFldDefInf;
  f: TFld;
label lend;
begin
	AddStack('TRecDBDef.FCreateFld',Self);
	if AType=ftString then
  	if TrimUpper(AName)<>TrimUpper(sLong) then
      if AnsiStartsText(sLong,AName) then begin
        if not IntObjFindAdd(FPart,AName,i) then
          if Length(aPart)=i then SetLength(aPart,IfThen(i=0,10,i shl 1));
        p:=@aPart[i]; p.Len:=ASize;
        if not Assigned(FldLong) then begin
	        FldLong:=FCreateFld(sLong,ftString,p.Len,'');
	        FldLong.Info.Attr:=faLong; p.Pos:=1; ClearDef;
          for i:=0 to FFldDef.Count-1 do begin
            td:=GetFldInf(i);
            with td,Inf do begin
              if (Name='') or (SvType<>dwsNoFix) then continue;
              Fld := inherited FCreateFld(Name,aDWFld[AType].tp,Len,AValue);
              with Fld,Info do if AType in [dwtMemo,dwtArray] then begin
                Attr:=faDefMemo; Value:=dwCod;
                if FldName(sDefMemo+Value,f) then Value:=LongInt(f);
              end
              else Attr:=faDef;
              DefAdd(IfThen(AType in [dwtMemo,dwtArray],sDefMemo),td);
            end;
          end;
          SetLongVal;
        end
        else begin
          Inc(FldLong.Info.Size,p.Len);
          if i=0 then k:=1
          else with GetPart(i-1)^ do k:=Pos+Len;
          for j:=i to FPart.Count-1 do begin
          	p:=GetPart(j); p.Pos:=k; Inc(k,p.Len);
          end;
        end;
        result:=FldLong; goto lend;
      end;
  result := inherited FCreateFld(AName,AType,ASize,AValue);
  if result.Info.Attr=faMemo then
  	for i:=0 to FieldCount-1 do begin
    	f:=Field[i];
      if (f.Info.Attr=faDefMemo) and (MyVarType(f.Info.Value)=varString) then
      	if sDefMemo+f.Info.Value=AName then begin
        	f.Info.Value:=LongInt(result); goto lend;
	      end;
	  end;
lend:
	DelStack;
end;

procedure TRecDBDef.FldGetRec;
var s,sc,sv,onm: string;
	j: longint;
  f: TFld;
	tf: TField;
  svi: TRDBSaveInf;
  ad: TArrPosLen;
label lend;
begin
	{$IFDEF STACKALL}AddStack('TRecDBDef.FldGetRec',Self);{$ENDIF}
	f:=Field[i];
	case f.Info.Attr of
  	faLong: begin
    	s:='';
      for j:=0 to FPart.Count-1 do
        if FindFieldDupl(tf,q,lsDupl,FPart[j]) then IncD(s,Padr(tf.AsString,GetPart(j).Len)) else goto lend;
      StrTranSelf(s,cCRLF,CRLF);
      if AutoFillDop then begin
        onm:=FieldName[i];
        SaveInf(svi); CloseRec; FldDef.Clear; StrDlmArr(s,1,Length(s),cDlm,ad); j:=low(ad);
        while j<=high(ad) do begin
          sc:=Trim(Copy(s,ad[j].Pos,ad[j].Len)); Inc(j);
          if j>high(ad) then sv:='' else sv:=Copy(s,ad[j].Pos,ad[j].Len);
          if sc<>'' then CreateFld(sc,ftString,Length(sv),0,sv,'');
          Inc(j);
        end;
        OpenRec; RestInf(svi); FieldFind(onm,i);
      end;
      FldLong.Value:=s;
      for j:=0 to FDef.Count-1 do begin
      	f:=FldDefInf(j).Fld;
        if f.Info.Attr=faDef then f.OldValue:=f.Info.Value;
      end;
      goto lend;
    end;
  	faDef,faDefMemo,faManyStr: goto lend;
  	faFixArray: if not lMemo and (f.Info.Attr=aMemo[famArray].attr) then
      for j:=0 to FDef.Count-1 do with FldDefInf(j)^ do
        if Fld=f then begin
        	f.MemGk:=0; f.Info.Value:=''; goto lend;
        end;
  end;
  inherited FldGetRec(q,i,lMemo,lsDupl);
lend:
	{$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TRecDBDef.FldAddList;
var f: TFld;
	s: string;
  j: longint;
  p: PRDBArrDef;
  svi: TRDBSaveInf;
label lend;
begin
	AddStack('TRecDBDef.FldAddList',Self);
	f:=Field[i];
  if f.Info.Attr in setDBDupl+[faDef,faManyStr,faMany]-[faFixSel] then goto lend;
	case f.Info.Attr of
  	faLong: begin
      if FPart.Count=0 then raise ERecDBDefError.Create('В таблице '+FNameDB+' нет полей '+sLong);
      s:=StrTran(f.Value,CRLF,cCRLF);
    	for i:=0 to FPart.Count-1 do begin
        FQuery.AddArgList(sC_LIST,FPart[i]);
        with GetPart(i)^ do FQuery.AddArgList(sV_LIST,QQs(Copy(s,Pos,Len)));
      end;
      with GetPart(FPart.Count-1)^ do
  	    if Length(s)>Pos+Len then raise ERecDBDefError.Create(
        	'В таблице '+FNameDB+' необходимо увеличить количество полей '+sLong);
    end;
    faFixArray,faFixSel:
      for j:=0 to FDef.Count-1 do with FldDefInf(j)^ do
        if Fld=f then begin
        	case f.Info.Attr of
            faFixArray: if FixArrFromDef then if PGetArrDef(Inf.AValue,p) then begin
              RdbArr.SaveInf(svi); RdbArr.SetFldDefText(p.Dat);
              FSetMem(f,FixSt(sArray)+Inf.dwCod,a,famArray,Inf.AValue);
              RestInf(svi);
            end;
            faFixSel: if f.DuplFld(f)
              then FSetMem(f,FixSt(sFixSel)+Inf.dwCod,a,famSel,Inf.SelVid+'.'+Inf.SelVName);
          end;
          break;
        end;
  else
  	if f.Info.Attr in [faNormal,faSel] then
    	if FixArrFromDef and CompBegFixSt(FieldName[i],famArray) or CompBegFixSt(FieldName[i],famSel) then
      	if FDef.Find(FieldName[i],j) then goto lend;
  	inherited FldAddList(i,a);
  end;
lend:
	DelStack;
end;

function TRecDBDef.FldDefCount;
begin
  result:=FDef.Count;
end;

function TRecDBDef.FldDefInf(i: longint): PFldDefInf;
begin
  result:=@aDef[IntObj(FDef,i)];
end;

function TRecDBDef.FldDefInf(const nmf: string; var pd: PFldDefInf): boolean;
var i: longint;
begin
  AddStack('TRecDBDef.FldDefInf(nmf)',Self);
  result:=FDef.Find(nmf,i);
  if result then pd:=FldDefInf(i);
  DelStack;
end;

function TRecDBDef.FldDefInf(f: TFld; var pd: PFldDefInf): boolean;
var i: longint;
begin
  AddStack('TRecDBDef.FldDefInf(Fld)',Self);
  result:=false;
  for i:=0 to FDef.Count-1 do begin
    pd:=FldDefInf(i);
    if pd.Fld=f then begin
      result:=true; break;
    end;
  end;
  DelStack;
end;

function TRecDBDef.GetPart;
begin
  AddStack('TRecDBDef.GetPart',Self);
  result:=@aPart[IntObj(FPart,i)];
  DelStack;
end;

function TRecDBDef.FldModified(i: longint): boolean;
var j: longint;
  procedure SelMod(f: TFld);
  begin
  	AddStack('TRecDBDef.FldModified.SelMod',Self);
    SelCodeGetProc(selModified,[longint(FldDefInf(j)),TblFldName(FDef[j]),longint(f),longint(Connection),longint(@result)]);
    DelStack;
  end;
var f,ff: TFld;
  pd: PFldDefInf;
begin
	AddStack('TRecDBDef.FldModified',Self);
  result := inherited FldModified(i);
  if not result then begin
    f:=Field[i];
    case f.Info.Attr of
      faLong: for j:=0 to FDef.Count-1 do with FldDefInf(j).Fld do
        if not CompVar(Value,OldValue) then begin
          result:=true; break;
        end;
      faSel: if Length(f.SelFlt)>0 then if FDef.Find(FieldName[i],j) then SelMod(f);
      faFixSel: if MyVarType(f.Info.Value)<>varString then begin
        ff:=PointerVar(f.Info.Value); result:=ff.Modified;
        if not result then if Length(ff.SelFlt)>0 then for j:=0 to FDef.Count-1 do begin
          pd:=FldDefInf(j);
          if pd.Fld=f then begin
            SelMod(ff); break;
          end;
        end;
      end;
    end;
  end;
  DelStack;
end;

procedure TRecDBDef.DWSeek;
begin
	AddStack('TRecDBDef.DWSeek',Self);
	IfThenNotify(FOnDWSeek,Self);
  DelStack;
end;

procedure TRecDBDef.DWTrans(var sTrans: string; lSave: boolean);
begin
	AddStack('TRecDBDef.DWTrans',Self);
	if Assigned(FOnDWTrans) then begin
    FOnDWTrans(Self,sTrans,lSave);
    if not lSave then StrTranSelf(sTrans,[CRLF,#10],[#10,CRLF]);
  end;
  DelStack;
end;

function TRecDBDef.DWTrans: string;
begin
  DWTrans(result,false);
end;

procedure TRecDBDef.DWArrCodName;
begin
	AddStack('TRecDBDef.DWArrCodName',Self);
  if Assigned(FOnDWArrCodName) then FOnDWArrCodName(Self,Qry,Cod,Name);
  DelStack;
end;

function TRecDBDef.DWArrSeek;
  procedure RdbFld(var nmf: string);
  begin
    AddStack('TRecDBDef.DWArrSeek.RdbFld');
    if nmf<>'' then if Pos('.',nmf)=0 then IncL(nmf,res.RecDef+'.');
    DelStack;
  end;
begin
	AddStack('TRecDBDef.DWArrSeek',Self);
  with res do begin
    Finalize(res); ZeroMemory(@res,SizeOf(res));
    if Assigned(FOnDWArrSeek) then FOnDWArrSeek(Self,res);
    result := RecDef<>'';
    if result then begin
      RdbFld(FldOrd); RdbFld(FldOrdDop); RdbFld(FldDop); RdbFld(Name);
    end;
  end;
  DelStack;
end;

function TRecDBDef.DWCanDel;
var vn,mn: string;
begin
	AddStack('TRecDBDef.DWCanDel',Self);
  vn:=DWVarName(VarName); mn:=DWVarName(MsgName); result:=IfThenDWCanDel(FOnDWCanDel,Self,vn,mn);
  if result then result:=IfThenDWCanDel(DWCanDelProc,Self,vn,mn);
  DelStack;
end;

function TRecDBDef.DWVarName(const VarName: string = ''): string;
begin
  AddStack('TRecDBDef.DWVarName',Self);
  result:=IfThen(FDWPrefix<>'',FDWPrefix+'_'+VarName);
  DelStack;
end;

class function TRecDBDef.DWVarName(const nmRec,nmFld: string): string;
var cr: TCustomRec;
begin
	AddStack('TRecDBDef.DWVarName(r)');
  if RecName(nmRec,cr,TRecDBDef) then result:=TRecDBDef(cr).DWVarName(nmFld) else result:='';
  DelStack;
end;

class function TRecDBDef.DWVarName(const a: TDEPrmStr): string;
begin
  result:=DWVarName(a[deNameRec],a[deNameRecFld]);
end;

class function TRecDBDef.DWVarNameRel;
var a1: array[1..2] of string;
begin
  AddStack('TRecDBDef.DWVarNameRel');
  result:=a[deRelation];
  if not empty(result) then begin
    LsArrFill(result,a1,'.'); result:=DWVarName(a1[1],a1[2]);
  end;
  DelStack;
end;

procedure TRecDBDef.DWCngName;
begin
	AddStack('TRecDBDef.DWCngName',Self);
	IfThenDWCngName(FOnDWCngName,Self,OldName,NewName,result);
	IfThenDWCngName(DWCngNameProc,Self,OldName,NewName,result);
  DelStack;
end;

procedure TRecDBDef.DWVarValid;
begin
  AddStack('TRecDBDef.DWVarValid',Self);
	if Assigned(FOnDWVarValid) then FOnDWVarValid(Self,Proc,r,result);
  DelStack;
end;

function TRecDBDef.DelRec(const where: string = ''; Opt: TRDBDelOpt = []): boolean;
var i: longint;
begin
	AddStack('TRecDBDef.DelRec',Self);
	if Assigned(LsArr) then begin
    result:=true;
  	if FFRecNo<>0 then begin
      Dec(FArrCount);
      for i:=(FFRecNo-1)*FieldCount to (FArrCount*FieldCount)-1 do LsArr^[i]:=LsArr^[i+FieldCount];
      FFRecNo:=0; ArrCng:=true;
    end;
  end
  else result:=inherited DelRec(where,Opt);
  DelStack;
end;

procedure TRecDBDef.CopyFromQuery;
var i: longint;
begin
	AddStack('TRecDBDef.CopyFromQuery',Self);
	CopyDopFromQuery(q);
  for i:=0 to FieldCount-1 do
    if Field[i].Info.Attr in setDBReal then Value[FieldName[i]]:=q.FieldZN(FieldName[i]);
  DelStack;
end;

procedure TRecDBDef.CopyDopFromQuery;
var i,gk,l: longint;
	s: string;
  a: array of record
    gk: longword;
    f: TFld;
    fa: TFldMemoAttr;
  end;
  lsm: TMemGkList;
  afFix: array[0..1] of string;
  fa: TFldMemoAttr;
begin
	AddStack('TRecDBDef.CopyDopFromQuery',Self);
	if Assigned(FldLong) then begin
    s:='';
    for i:=0 to FPart.Count-1 do IncD(s,q.FieldZN(FPart[i]));
    FldLong.Value:=s;
  end;
  afFix[0]:=FixSt; afFix[1]:=FixSt(sArray); SetLength(a,q.FieldCount); l:=0;
  for i:=0 to q.FieldCount-1 do begin
  	s:=q.Fields[i].FieldName;
    if AnsiStartsArr(afFix,s) then Value[s]:=q.Fields[i].Value
    else for fa:=low(aBegMemFix) to high(aBegMemFix) do if AnsiStartsText(FixSt(aBegMemFix[fa]),s) then begin
      gk:=q.Fields[i].AsInteger;
      if gk=0 then Value[s]:=''
      else begin
        a[l].gk:=gk; FldName(s,a[l].f); a[l].fa:=fa; Inc(l);
      end;
      break;
    end;
  end;
  if l>0 then begin
    lsm:=TMemGkList.Create(Self,q);
    try
      for i:=0 to l-1 do with a[i] do begin
        f.Value:=lsm.GetValue(gk,fa); f.MemGk:=gk;
      end;
    finally
      lsm.DestroyFromQuery; lsm.Free;
    end;
  end;
  DelStack;
end;

procedure TRecDBDef.CreateFieldDop;
var i: longint;
begin
  AddStack('TRecDBDef.CreateFieldDop',Self);
	if Assigned(FldLong) then for i:=0 to FPart.Count-1 do q.CreateField(FPart[i]);
  DelStack;
end;

function TRecDBDef.GetDopInfo;
begin
  AddStack('TRecDBDef.GetDopInfo',Self);
	if Assigned(FldLong) then LsArrDynamic(FPart.Text,result,CRLF,lsaSetLen) else result:=nil;
  DelStack;
end;

procedure TRecDBDef.AddCList(q: TMulQuery; const Prm: array of variant;
  PrAdd: TRDBClistAdd = nil; Opt: TRDBAddCListOpt = []);
var i: longint;
  s: string;
begin
	AddStack('TRecDBDef.AddCList',Self);
	inherited AddCList(TMulQuery.QryCur(q),Prm,PrAdd,Opt);
	if Assigned(FldLong) then begin
    s:=IfThen(not(addclNoAlias in Opt),NameDB+'.');
	  for i:=0 to FPart.Count-1 do FAddCList(q,Prm,PrAdd,nil,s,FPart[i]);
  end;
  DelStack;
end;

procedure PrAddCListNoFixSt(Sender: TRecDB; f: TFld; const nmFld: string;
  const Prm: array of variant; var lDone: boolean);
begin
  AddStack('Recdb.PrAddCListNoFixSt');
  if AnsiStartsArr(ArrStrVar(Prm[0])^,nmFld) then lDone:=false;
  DelStack;
end;

class procedure TRecDBDef.AddCList(const ardb: array of TRecDBDef; q: TMulQuery = nil;
  lSet: boolean = true);
var i: longint;
  ls: TStringList;
  procedure fAdd(const nmf: string);
  var s: string;
  begin
    AddStack('TRecDBDef.AddCList(used).fAdd');
    if ardb[i].IsField(nmf) then begin
      s:=ardb[i].TblFldName(nmf);
      if not IgnoreSlFindAdd(ls,s) then q.AddArgList(sC_LIST,s);
    end;
    DelStack;
  end;
var j,l: longint;
  a: TArrStr;
  fa: TFldMemoAttr;
	sBeg: string;
  Opt: TRDBAddCListOpt;
  r: TDWVidRec;
begin
  AddStack('TRecDBDef.AddCList(used)');
{TMulQuery.QryCur(q);
if lSet then q.Arg[sC_LIST]:='*'
else begin}
  i:=Length(ardb);
  if i>0 then begin
    if lSet then Opt:=[addclSet] else Opt:=[];
    SetLength(a,i*(1+Length(aBegMemFix))); j:=low(a);
    for i:=low(ardb) to high(ardb) do with ardb[i] do begin
      a[j]:=FixSt; Inc(j);
      for fa:=low(aBegMemFix) to high(aBegMemFix) do begin
        a[j]:=FixSt(aBegMemFix[fa]); Inc(j);
      end;
    end;
    ardb[0].AddCList(TMulQuery.QryCur(q),[longint(@a)],PrAddCListNoFixSt,Opt);
    ls:=SortStrListCreate;
    try
      for i:=low(ardb) to high(ardb) do with ardb[i] do
        for j:=0 to FDef.Count-1 do begin
          r:=FldDefInf(j).Inf;
          if r.SvType=dwsFix then begin
            sBeg:=FixSt;
            case r.AType of
              dwtManyStr: for l:=0 to LsArrDynamic(r.dwCod,a,',')-1 do fAdd(sBeg+a[l]);
              dwtMany: begin
                a:=nil; DWTypeMany(dwtoUsed,[longint(@r),dwcMany,longint(@a),longint(ardb[i])]);
                for l:=low(a) to high(a) do fAdd(a[l]);
              end;
            else
              IsDWFldMemo(r.AType,fa,sBeg); fAdd(FixSt(sBeg)+r.dwCod);
            end;
          end;
        end;
    finally
      ls.Free;
    end;
  end;
//end;
  DelStack;
end;

class procedure TRecDBDef.PartSelect;
begin
  AddStack('TRecDBDef.PartSelect');
  AddCList(ardb,TMulQuery.QryCur(q)); q.PartSelect(ardb[0].NameDB,'',where,o_list,g_list,lOpen);
  DelStack;
end;

procedure TRecDBDef.DoNewRec(lCopy: boolean = false; const gKey: string = '');
var i: longint;
begin
	AddStack('TRecDBDef.DoNewRec',Self);
	for i:=0 to FDef.Count-1 do with FldDefInf(i)^ do begin
  	if not lCopy then Fld.Value:=FillValue(StrUtils.IfThen(Fld.Info.DataType<>ftArray,AValue),Inf,Inf);
    if Fld.Info.Attr=faFixArray then Fld.MemGk:=0;
  end;
	inherited DoNewRec(lCopy,gKey);
  DelStack;
end;

procedure TRecDBDef.SetDefValues;
var i: longint;
  f: TFld;
begin
  AddStack('TRecDBDef.SetDefValues',Self);
  for i:=0 to FFldDef.Count-1 do with DWSToRec(i) do
    if FldName(Name,f) then f.SetStrVal(AValue);
  DelStack;
end;

function TRecDBDef.GetFixArr;
begin
  AddStack('TRecDBDef.GetFixArr',Self);
  result:=FFixArr[Index];
  DelStack;
end;

procedure TRecDBDef.SetFixArr;
begin
  AddStack('TRecDBDef.SetFixArr',Self);
  FFixArr[Index]:=v;
  DelStack;
end;

function TRecDBDef.FixSt;
var fa: TFldMemoAttr;
begin
  AddStack('TRecDBDef.FixSt',Self);
  if sBeg=sFix then result:=NmFix_
  else begin
    result:='';
    for fa:=low(aBegMemFix) to high(aBegMemFix) do if sBeg=aBegMemFix[fa] then begin
      result:=FFixArr[anFixArr[fa]]; break;
    end;
  end;
  if empty(result) then result:=sBeg;
  DelStack;
end;

function TRecDBDef.IsFldFix(const nmf: string): boolean; 
var fa: TFldMemoAttr;
begin
  AddStack('TRecDBDef.IsFldFix',Self);
  result:=AnsiStartsText(FixSt,nmf);
  if not result then for fa:=low(aBegMemFix) to high(aBegMemFix) do
    if AnsiStartsText(FixSt(aBegMemFix[fa]),nmf) then begin
      result:=true; break;
    end;
  DelStack;
end;

function TRecDBDef.IsFldFix(Index: longint): boolean;
begin
  AddStack('TRecDBDef.IsFldFix(i)',Self);
  result:=IsFldFix(FieldName[Index]);
  DelStack;
end;

procedure TRecDBDef.GetAFieldValueNoFldFix;
var i: longint;
begin
  AddStack('TRecDBDef.GetAFieldValueNoFldFix',Self);
  GetAFieldValue(a,setDBReal);
  for i:=low(a) to high(a) do with a[i] do if IsFldFix(nm) then nm:='';
  DelStack;
end;

procedure TRecDBDef.SetAFieldValueNoFldFix;
var i: longint;
begin
  AddStack('TRecDBDef.SetAFieldValueNoFldFix',Self);
  SetAFieldValue(a);
  for i:=0 to FieldCount-1 do with Field[i] do
    if IsFldFix(i) or (Info.Attr in setDBDef) then Modified:=false;
  DelStack;
end;

function TRecDBDef.SeekArrFld;
var i: longint;
  p: PFldDefInf;
begin
  AddStack('TRecDBDef.SeekArrFld',Self);
  f:=nil; 
  for i:=0 to FDef.Count-1 do begin
    p:=FldDefInf(i);
    if (p.Inf.AType=dwtArray) and (AnsiUpperCase(FixSt(sArray)+p.Inf.dwCod)=nmf) then begin
      f:=p.Fld; break;
    end;
  end;
  result:=Assigned(f);
  DelStack;
end;

class procedure TRecDBDef.FGetMemGK;
begin
	AddStack('TRecDBDef.FGetMemGK');
  if f.Info.Attr=faDefMemo then f:=PointerVar(f.Info.Value);
	inherited FGetMemGk(f,result);
  DelStack;
end;

class function TRecDBDef.Init;
begin
  AddStack('TRecDBDef.Init');
  result := not Assigned(r);
  if result then begin
  	r:=TRecDBDef.Create(Application.MainForm); r.NameDB:=NameDB; r.NameRec:=NameRec;
    r.DWPrefix:=DWPrefix; r.DWName:=DWName; r.MsgCheck:=MsgCheck;
    r.OnDWTrans:=PrDWTrans;
    r.OnCalculate:=PrCalculate; r.OnNewRec:=PrNewRec;
    if lOpen then r.OpenRec;
  end;
  res:=r;
  DelStack;
end;

class function TRecDBDef.SeekDWPrefix;
var r: TRecDBDef;
	i: longint;
  DWPrefix: string;
begin
	AddStack('TRecDBDef.SeekDWPrefix');
	rdb:=nil; result:=false;
  if Assigned(LsCustomRec) and not empty(pref) then begin
    DWPrefix:=TrimUpper(pref);
    for i:=0 to LsCustomRec.Count-1 do
      if IsClass(LsCustomRec.Objects[i],TRecDBDef,pointer(r)) then if TrimUpper(r.DWPrefix)=DWPrefix then begin
        rdb:=r; result:=true; break;
      end;
  end;
  DelStack;
end;


function TRecDBDef.GetArrValue;
var i: longint;
begin
  AddStack('TRecDBDef.GetArrValue',Self);
  result:='';
  if Assigned(LsArr) then begin
    if ArrCng then begin
      for i:=1 to ArrCount do begin
        GotoRec(i); IncD(result,cCRLF+FGetLongVal);
      end;
      FArrValue:=Copy(result,lcCRLF1,MaxInt); ArrCng:=false;
    end;
    result:=FArrValue;
  end;
  DelStack;
end;

procedure TRecDBDef.SetArrValue;
var a: TArrPosLen;
  i: longint;
begin
  AddStack('TRecDBDef.SetArrValue',Self);
  if Assigned(LsArr) then begin
  	ArrClear;
    if not empty(cv) then begin
      StrDlmArr(cv,1,Length(cv),cCRLF,a); FFRecNo:=FArrCount; ArrCount:=FArrCount+Length(a);
      for i:=low(a) to high(a) do begin
        Inc(FFRecNo); FSetLongVal(cv,a[i].Pos,a[i].Len); UpdateRec;
      end;
    end;
  end;
  DelStack;
end;

procedure TRecDBDef.SetArrCount;
var l: longint;
begin
  AddStack('TRecDBDef.SetArrCount',Self);
  FArrCount:=Value; l:=Value*FieldCount;
  if Length(LsArr^)<l then SetLength(LsArr^,l);
  DelStack;
end;

procedure TRecDBDef.ArrExchange;
var i1,i2: longint;
  v: variant;
begin
  AddStack('TRecDBDef.ArrExchange',Self);
  if Assigned(LsArr) then
  	if InRange(Rec1,1,ArrCount) and InRange(Rec2,1,ArrCount) then begin
      i2:=(Rec2-1)*FieldCount;
      for i1:=(Rec1-1)*FieldCount to (Rec1*FieldCount)-1 do begin
        v:=LsArr^[i2]; LsArr^[i2]:=LsArr^[i1]; LsArr^[i1]:=v; Inc(i2);
      end;
      FFRecNo:=0; ArrCng:=true;
    end;
  DelStack;
end;

procedure TRecDBDef.DWFldInfo;
begin
	AddStack('TRecDBDef.DWFldInfo',Self);
	if Assigned(FOnDWFldInfo) then FOnDWFldInfo(Self,r,FldInfo);
  DelStack;
end;

procedure TRecDBDef.DWFldSeek;
begin
	AddStack('TRecDBDef.DWFldSeek',Self);
  a:=nil;
	if Assigned(FOnDWFldSeek) then FOnDWFldSeek(Self,a,DWFldAddProc);
  DelStack;
end;

function TRecDBDef.DWRdbSeek;
begin
	AddStack('TRecDBDef.DWRdbSeek',Self);
	if Assigned(FOnDWRdbSeek) then result:=FOnDWRdbSeek(Self) else result:=Self;
  DelStack;
end;

function TRecDBDef.GetDop_;
begin
  AddStack('TRecDBDef.GetDop_',Self);
  result:=Value[sLong];
  DelStack;
end;

procedure TRecDBDef.SetDop_;
begin
  AddStack('TRecDBDef.SetDop_',Self);
  if TrimRight(StrTran(Value[sLong],CRLF,cCRLF))<>TrimRight(v) then begin
    FldLong.Info.Value:=v; SetLongVal;
  end;
  DelStack;
end;

procedure StConvertDateBig(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i,lr,l,j: longint;
  n: byte;
  ad: PArrInt;
  fl: boolean;
  d: TDateTime;
  rdb: TRecDBDef;
  lsm: TMemGkList;
begin
  AddStack('Recdb.StConvertDateBig');
  rdb:=PointerVar(Params[0]); ad:=PointerVar(Params[1]); l:=Params[2]; lr:=Params[3];
  lsm:=TMemGkList.Create(rdb);
  for i:=1 to lr do begin
    if Sender.SayStat('',Format('Запись: %d из %d',[i,lr]),i/lr) then break;
    lsm.GetFromQuery; fl:=false;
    for j:=0 to l do begin
      d:=rdb.ValueNum[ad^[j]];
      for n:=low(DateBigOld) to high(DateBigOld) do
        if d=DateBigOld[n,false] then begin
          rdb.ValueNum[ad^[j]]:=DateBigOld[n,true]; fl:=true; break;
        end;
    end;
    if fl then rdb.UpdateRec;
    CurQuery.Next;
  end;
  DelStack;
end;

function TRecDBDef.ConvertDateBig;
var i,lr,l: longint;
  r: TDWVidRec;
  ad: TArrInt;
begin
  AddStack('TRecDBDef.ConvertDateBig',Self);
  OpenRec; SetLength(ad,FFldDef.Count); l:=0;
  for i:=0 to FFldDef.Count-1 do begin
    r:=DWSToRec(i);
    if (r.SvType=dwsNoFix) and (r.AType=dwtDate) then begin
      ad[l]:=NumFromName(r.Name); Inc(l);
    end;
  end;
  if l=0
  then result:=true
  else with GetQuery(Connection) do begin
    TRecDBDef.PartSelect(Self); lr:=RecordCount;
    result:=not ShowStat(Capt,StConvertDateBig,[Longint(Self),Longint(@ad),l,lr],lr);
    FreeQuery;
  end;
  DelStack;
end;

function TRecDBDef.SetFldDefText;
var oAct: boolean;
  v: string;
begin
  AddStack('TRecDBDef.SetFldDefText',Self);
  v:=TrimRight(s); result := TrimRight(FldDef.Text)<>v;
  if result then begin
    oAct:=Active; CloseRec; FldDef.Text:=v; Active:=oAct;
  end;
  DelStack;
end;

procedure TRecDBDef.InitFldDef(const s: string; Opt: TDWWinRdbDefOpt = dwdefSeek);
var lCng: boolean;
  ii: longint;
  a: TArrFldVal;
begin
  AddStack('TRecDBDef.InitFldDef',Self);
  ii:=Recno;
  if Active and (Opt<>dwdefSeek) then GetAFieldValue(a,setDBReal) else a:=nil;
  lCng:=SetFldDefText(s);
  if Active then
    if Opt=dwdefSeek then DWSeek
    else if lCng then
      if ii=0 then begin
        NewRec; SetAFieldValue(a);
      end
      else if Opt<>dwdefNone then begin
        if Recno<>ii then GotoRec(ii);
        if Opt=dwdefRestVal then SetAFieldValue(a);
      end;
  DelStack;
end;

procedure TRecDBDef.InitFldDef(Opt: TDWWinRdbDefOpt = dwdefSeek);
begin
  InitFldDef(DWTrans,Opt);
end;

function TRecDBDef.DWSToRec;
begin
  AddStack('TRecDBDef.DWSToRec',Self);
  result:=My_pr.DWSToRec(FFldDef[i]);
  DelStack;
end;

function TRecDBDef.DWVidForm;
begin
  AddStack('TRecDBDef.DWVidForm',Self);
  if CurDWFld=dwfFixArray then result:=CurDWFld
  else begin
    result:=dwfNormal;
    if Assigned(Self) then if NameDB='' then result:=dwfArray;
  end;
  DelStack;
end;

procedure TRecDBDef.SetNmFixEqTbl;
var i: longint;
begin
  AddStack('TRecDBDef.SetNmFixEqTbl',Self);
  SetLength(aNmFixEqTbl,Length(a));
  for i:=low(a) to high(a) do aNmFixEqTbl[i]:=a[i];
  DelStack;
end;

{ TRecDBApp }
constructor TRecDBApp.CreateFrom;
begin
	AddStack('TRecDBApp.CreateFrom',Self);
  inherited Create(AOwner);
  NameDB:=RecFrom.NameDB+DBInsPostfix; rFrom:=RecFrom;
  qApp:=TMulQuery.CreateConnection(Self,rFrom.Connection);
  with qApp do CountRec:=PartMaxInt(NameDB,fRECNO_I);
  rFrom.AddCList(qApp,[],nil,[addclSet,addclNoAlias]);
  DelStack;
end;

procedure TRecDBApp.BeforeApp;
begin
  CurRec:=1;
end;

procedure TRecDBApp.AfterApp;
begin
  AddStack('TRecDBApp.AfterApp',Self);
  if CurRec>1 then InsToTbl(fRECNO_I+'<'+Vtos(CurRec));
  DelStack;
end;

procedure TRecDBApp.NewRec;
var q: TMulQuery;
	a: TArrStr;
  i: longint;
  p: TObject;
begin
	AddStack('TRecDBApp.NewRec',Self);
  if CurRec>CountRec then begin
  	InsToTbl(''); CurRec:=1;
  end;
  q:=rFrom.AppRec(false,0,''); q.GetListArg(sV_LIST,a);
  if TMulQuery.CreateConnection(qUpd,Self,rFrom.Connection) then with qUpd do begin
    Arg[sTABLE]:=NameDB; Arg[sC_LIST]:=q.Arg[sC_LIST];
    Arg[sWHERE]:=fUSERNUM+'='+Vtos(PswdPrm.UserNum+1)+sAND+fRECNO_I+'=:R';
    for i:=low(a) to high(a) do AddArgList(sV_LIST,StrNum(':V',i));
    SetPart(sUW_TABLE); Prepare;
  end;
  for i:=low(a) to high(a) do
    qSetParamValue(qUpd.ParamByName(StrNum('V',i)),StrTran(a[i],'""','"'));
  p:=qUpd.ParamByName('R');
  if p is TParam then TParam(p).AsString:=Vtos(CurRec) else TFIBXSQLVAR(p).AsString:=Vtos(CurRec);
  qUpd.ExecSQL; Inc(CurRec);
  DelStack;
end;

procedure TRecDBApp.InsToTbl;
begin
  AddStack('TRecDBApp.InsToTbl',Self);
  with qApp do begin
  	Arg[sSELECT]:=PartSelect(NameDB,'',
    	DlmBetween(fUSERNUM+'='+Vtos(PswdPrm.UserNum+1),where,sAND),'','',false);
    Arg[sTABLE]:=rFrom.NameDB; ExecPart(sIS_TABLE);
  end;
  DelStack;
end;

{ TMemGkList }
constructor TMemGkList.Create(const rdb: array of TRecDB; q: TMulQuery = nil; qDop: TMulQuery = nil;
  paNmFld: PArrStr = nil; lDeshifr: boolean = true; DefOption: TMemGkDefOption = mgdAll;
  const fDef: string = ''; lsmDef: TMemGkList = nil; ais: TFldMemoAttrSet = FldMemoAttrAll;
  PrAddDefArr: TAddDefArr = nil; DWTypeManyProc: pointer = nil; const gWhere: string = '');
var fa: TFldMemoAttr;
  ad: TMemGkDefArr;
  ld: longint;
  procedure tfAdd(const nmf: string; f: TField; const ka: string = ''; rdb: TRecDBDef = nil);
  begin
    AddStack('TMemGkList.Create.tfAdd');
    ad[ld]:=AddDef(FQuery.Arg[sTABLE],nmf,FQuery.Arg[sWHERE],fa,f,ka,rdb); Inc(ld);
    DelStack;
  end;
var j: longint;
  function rfAdd(const nmf: string; f: TField): boolean;
  var rdbj: TRecDBDef;
    fl: boolean;
    i: longint;
    s,ka: string;
    rv: TDWVidRec;
  begin
    AddStack('TMemGkList.Create.rfAdd');
    result:=rdb[j].CompBegFixSt(nmf,fa);
    if result then begin
      fl:=true; ka:='';
      if IsClass(rdb[j],TRecDBDef,pointer(rdbj)) then begin
        s:=rdbj.FixSt(aBegMemFix[fa]);
        if DefOption<>mgdAll then
          if AnsiStartsText(s,nmf) then fl:=false
          else for i:=low(rdbj.aNmFixEqTbl) to high(rdbj.aNmFixEqTbl) do if rdbj.aNmFixEqTbl[i]<>rdbj then
            if AnsiStartsText(rdbj.aNmFixEqTbl[i].FixSt(aBegMemFix[fa]),nmf) then begin
              fl:=false; break;
            end;
        if fl and (fa=famArray) and not Assigned(PrAddDefArr) then for i:=0 to rdbj.FFldDef.Count-1 do begin
          rv:=rdbj.DWSToRec(i);
          if (rv.SvType=dwsFix) and (rv.AType=dwtArray) and (nmf=s+rv.dwCod) then begin
            ka:=rv.AValue; break;
          end;
        end;
      end;
      if fl then tfAdd(rdb[j].TblFldName(nmf),f,ka,rdbj);
    end;
    DelStack;
  end;
var i: longint;
  aff: TArrStr;
  atf: array[1..2] of string;
  s: string;
  f: TField;
  lrdb,noqDop: boolean;
begin
	AddStack('TMemGkList.Create(q)');
  lrdb := Length(rdb)>0;
  if lrdb then FRdb:=rdb[0];
  FQuery:=q.QryCur; noqDop:=not Assigned(qDop);
  if noqDop then qDop:=TMulQuery.CreateConnection(nil,FQuery.Connection);
  for fa:=low(aMemo) to high(aMemo) do
    if fa in ais then if not IsTable(qDop.Connection,aMemoTbl[fa]) then Exclude(ais,fa);
  with FQuery do begin
    if Active then AddFrom(aObjInActive,Self)
    else if not Assigned(paNmFld) then begin
      GetListArg(sC_LIST,aff); paNmFld:=@aff;
    end;
  	if Assigned(paNmFld) then i:=Length(paNmFld^) else i:=FieldCount;
    SetLength(ad,i); ld:=0;
    if Assigned(paNmFld) then
      for i:=low(paNmFld^) to high(paNmFld^) do begin
        if ListAsArray(paNmFld^[i],atf,'.',false)<2 then begin
          atf[2]:=atf[1]; atf[1]:='';
        end;
        for fa:=low(aMemo) to high(aMemo) do if fa in ais then
          if lrdb then begin
            for j:=low(rdb) to high(rdb) do
              if AnsiMatchText(atf[1],['',rdb[j].NameDB]) then begin
                if Active then f:=FindField(IfThen(atf[1]='',rdb[j].NameDB,atf[1]),atf[2]) else f:=nil;
                if rfAdd(atf[2],f) then break;
              end;
          end
          else if fa=famMemo then begin
            if Active then
              if atf[1]='' then f:=FindField(atf[2]) else f:=FindField(atf[1],atf[2])
            else f:=nil;
            tfAdd(paNmFld^[i],f);
          end;
      end
    else
      for i:=0 to FieldCount-1 do begin
        s:=Origin(Fields[i]);
        if ListAsArray(s,atf,'.',false)<2 then atf[2]:='';
        for fa:=low(aMemo) to high(aMemo) do if fa in ais then
          if lrdb then begin
            for j:=low(rdb) to high(rdb) do
              if AnsiStartsText(rdb[j].NameDB+'.',s) then
                if rfAdd(atf[2],Fields[i]) then break;
          end
          else if fa=famMemo then tfAdd(s,Fields[i]);
      end;
  end;
  qDop.MulPar.Assign(FQuery.MulPar); SetLength(ad,ld);
  Create(ad,qDop,lDeshifr,fDef,lsmDef,PrAddDefArr,DWTypeManyProc,gWhere);
  if noqDop then qDop.Free;
  DelStack;
end;

constructor TMemGkList.Create(const rdb: array of TRecDBDef; q: TMulQuery = nil; qDop: TMulQuery = nil;
  paNmFld: PArrStr = nil; lDeshifr: boolean = true; DefOption: TMemGkDefOption = mgdAll;
  const fDef: string = ''; lsmDef: TMemGkList = nil; ais: TFldMemoAttrSet = FldMemoAttrAll;
  PrAddDefArr: TAddDefArr = nil; DWTypeManyProc: pointer = nil; const gWhere: string = '');
begin
  Create(TRecDBDef.ArrRdb(rdb),q,qDop,paNmFld,lDeshifr,DefOption,fDef,lsmDef,ais,PrAddDefArr,DWTypeManyProc,gWhere);
end;

constructor TMemGkList.Create(q: TMulQuery = nil; qDop: TMulQuery = nil;
  paNmFld: PArrStr = nil; lDeshifr: boolean = true;
  const fDef: string = ''; lsmDef: TMemGkList = nil; ais: TFldMemoAttrSet = FldMemoAttrAll;
  PrAddDefArr: TAddDefArr = nil; DWTypeManyProc: pointer = nil; const gWhere: string = '');
begin
  Create(TRecDBDef.ArrRdb([]),q,qDop,paNmFld,lDeshifr,mgdAll,fDef,lsmDef,ais,PrAddDefArr,DWTypeManyProc,gWhere);
end;

class function TMemGkList.AddDef;
begin
  AddStack('TMemGkList.AddDef');
  result.tbl:=tbl; result.nmf:=nmf; result.where:=where; result.fa:=fa; result.f:=f; result.ka:=ka;
  result.rdb:=rdb;
  DelStack;
end;

const
  flGK =0;
  flNPP=1;

  flCnt=1;

procedure StMemoLoad(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var lsm,lsmDef: TMemGkList;
  fa,faa: TFldMemoAttr;
  gk{,npp},i,j,l,l1,p,n,lr,nf,gl: longint;
  k: PLongInt;
  bm: TBookMark;
  s,sf,sBeg,fDef: string;
  r: PRDBArrDef;
  f: TField;
  v,v1: variant;
  fl,lg: boolean;
  ft: TFieldType;
  a: TArrStr;
  g: TObject;
  afsn: PArrInt;
  lsa: TStrStrList;
  qDop: TMulQuery;
  DWTypeManyProc: pointer;
begin
  AddStack('Recdb.StMemoLoad');
  lsm:=PointerVar(Params[0]); fa:=Params[1]; qDop:=PointerVar(Params[2]); nf:=Params[3];
  n:=1; lr:=Params[4]; k:=PointerVar(Params[6]);
  g:=PointerVar(Params[8]); lg:=Assigned(g); gl:=IfThen(not lg,byte(Params[7])); afsn:=PointerVar(Params[9]);
  fDef:=Params[11]; sf:=Params[13]; lsmDef:=PointerVar(Params[14]); DWTypeManyProc:=PointerVar(Params[17]);
  lsa:=TStrStrList.CreateIf(fa=famArray);
{if fa=famSel then begin
  fa:=fa;
end;}

//RnmStack('Recdb.StMemoLoad:'+qDop.Text);
  try
    with lsm,als[fa],qDop do begin
      while not Eof do begin
        Sender.SayStat(n/lr);
        gk:=Fields[flGK].AsInteger; ls.Add(gk); l:=0; bm:=GetBookMark;
        while not Eof and (Fields[flGK].AsInteger=gk) do begin
          Inc(l);
          {npp:=Fields[flNPP].AsInteger;
          repeat // group by GK,NPP
            Inc(n); Next;
          until Eof or (Fields[flGK].AsInteger<>gk) or (Fields[flNPP].AsInteger<>npp);}
          Next;
        end;
        Inc(n,l); // group by GK,NPP
        GotoBookMark(bm); FreeBookMark(bm);
        if fa=famArray then TRecDBDef.PGetArrDef(ValueNum(nf),r);
        if k^=Length(ares) then SetLength(ares,k^ shl 1);
//RnmStack('Recdb.StMemoLoad:'+aMemoTbl[fa]+','+IntToStr(n));
{if (fa=famArray) and (n=17) then begin
n:=n;
end;}
        DWTypeMany(DWTypeManyProc,dwtoMemLoad,[Params[15],longint(qDop),Params[16],longint(@lg),longint(@g),
          longint(@gl),longint(lsm),sf,longint(lsmDef)]);
        if fa=famSel then begin
          SelCodeGetProc(selMemGkReassign,
            [longint(@lg),longint(@g),longint(@gl),fDef,longint(lsmDef),longint(qDop),Params[12],sf]);
          if k^=Length(SelFlt) then SetLength(SelFlt,k^ shl 1);
          SetLength(SelFlt[k^],Length(afsn^));
          for i:=low(afsn^) to high(afsn^) do begin
            SelFlt[k^,i]:=Fields[afsn^[i]].Value;
            if (FldDataType(afsn^[i])=ftDate) and empty(SelFlt[k^,i])
            then SelFlt[k^,i]:=DateEmpty;
          end;
        end;
        SetLength(ares[k^],l*gl); p:=0;
        for l:=1 to l do begin
          case fa of
            famMemo: s:=FieldValueIndex(nf);
            famArray: begin
              s:='';
              if Assigned(r) then begin
                lsa.Clear;
                for i:=low(r.aDat) to high(r.aDat) do with r.aDat[i] do
                  if IsDWFldMemo(AType,faa,sBeg) then begin
                    if FindField(sBeg+dwCod,f) then if not empty(f.Value)
                    then lsa.IgnoreFindAdd(aDWFld[AType].c+dwCod,lsm.GetValue(f.Value,faa));
                  end
                  else begin
                    fl:=false; ft:=ftString; v:='';
                    if AType=dwtManyStr then begin
                      CodManyStr(a,r.aDat[i]);
                      for j:=low(a) to high(a) do if FindField(sFix+a[j],f) then begin
                        v1:=f.Value;
                        if MyVarType(v1)<>varString then v1:='';
                        fl:=true; IncD(v,Padr(v1,f.Size));
                      end;
                      StrTranSelf(v,cManyStrCRLF,CRLF);
                      if fl then TrimRightSelf(v);
                    end
                    else if FindField(sFix+dwCod,f) then begin
                      fl:=true; ft:=f.DataType; v:=f.Value;
                    end;
                    if fl then lsa.IgnoreFindAdd(aDWFld[AType].c+dwCod,TransToLongVal(r.aDat[i],ft,v));
                  end;
                for j:=0 to lsa.Count-1 do IncD(s,lsa[j]+cDlm+lsa.Value[j]+cDlm);
                DecLen(s,lDlm);
              end;
              IncD(s,cCRLF);
            end;
            famSel: begin
              SelCodeGetProc(selMemGkTrans,[longint(@s),longint(g),Fields[nf].AsString,gl,longint(qDop),Params[10]]);
              IncD(s,',');
            end;
          end;
          l1:=Length(s);
          if l1>0 then begin
            i:=p; Inc(p,l1);
            if Length(ares[k^])<p then SetLength(ares[k^],p);
            CopyMemory(PointerStr(ares[k^],i),Pointer(s),l1);
          end;
          {npp:=Fields[flNPP].AsInteger;
          repeat // group by GK,NPP
            Next;
          until Eof or (Fields[flGK].AsInteger<>gk) or (Fields[flNPP].AsInteger<>npp);}
          Next;
        end;
        case fa of
          famMemo: if Params[5] then ares[k^]:=StrDeShifr(LeftStr(ares[k^],p));
          famArray: SetLength(ares[k^],p-lcCRLF);
          famSel: SetLength(ares[k^],p-1);
        end;
        ls.Objects[k^]:=Pointer(k^); Inc(k^);
      end;
    end;
  finally
    lsa.Free;
  end;
  DelStack;
end;

constructor TMemGkList.Create(const aDef: array of TMemGkDef; qDop: TMulQuery; lDeshifr: boolean = true;
  const fDef: string = ''; lsmDef: TMemGkList = nil;
  PrAddDefArr: TAddDefArr = nil; DWTypeManyProc: pointer = nil; const gWhere: string = '');
const afo: array[0..flCnt] of string = (fMGK,fMNPP);
  aord: array[TFldMemoAttr] of TFldMemoAttr = (famMemo,famSel,famArray);
var fa,fo: TFldMemoAttr;
  al,anf: TFldMemoAttrInt;
  ais: TFldMemoAttrSet;
  aarr: TArrInt;
  a: array[TFldMemoAttr] of TUnionDef;
  af: TFldMemoAttrStr;
  i,j,k,l,p,la,ltw,ld: longint;
  lsf: TMQFieldList;
  ls: TStringList;
  pa: PRdbArrDef;
  s,so,v,vn,t,tf,sf: string;
  ad: TMemGkDefArr;
  atw: array of record
    t,w: string;
  end;
  fl: boolean;
  LenMemoZn: byte;
  g: TObject;
  aa: TFldMemoAttrArrInt;
  afs: TArrStr;
  afsn: TArrInt;
  svi: TRDBSaveInf;
  at: TArrStr;
  r: TRecDBDef;
  pMem: pointer;
begin
  AddStack('TMemGkList.Create');
  PointerDef(DWTypeManyProc,@MyTypes.DWTypeManyProc); ld:=Length(aDef); SetLength(ad,ld);
  for i:=0 to ld-1 do ad[i]:=aDef[i];
  if Assigned(PrAddDefArr) then begin
    PrAddDefArr(Self,ad); ld:=Length(ad);
  end;
  SetLength(atw,ld); SetLength(aarr,ld); ltw:=0; la:=0; ais:=[];
  for i:=0 to ld-1 do with ad[i] do begin
    Include(ais,fa); where:=BrackNoEmp(DlmBetween(BrackNoEmp(where),BrackNoEmp(gWhere),sAND),sAND+'(');
    if not Assigned(PrAddDefArr) then begin
      if fa=famArray then begin
        aarr[la]:=i; Inc(la);
      end;
      fl:=true;
      for j:=0 to ltw-1 do with atw[j] do if (t=tbl) and (w=where) then begin
        fl:=false; break;
      end;
      if fl then with atw[ltw] do begin
        t:=tbl; w:=where; Inc(ltw);
      end;
    end;
  end;
  // Тестовые и выбор-поля в массивах
  if la>0 then begin
    lsf:=GetFieldList(qDop.Connection,tARR);
    for fa:=low(aBegMemFix) to high(aBegMemFix) do begin
      lsf.Find(aBegMemFix[fa],i); j:=i;
      while j<lsf.Count do if AnsiStartsText(aBegMemFix[fa],lsf[j]) then Inc(j) else break;
      if j>i then begin
        Include(ais,fa); SetLength(ad,ld+la*(j-i)*ltw); Dec(j);
        for k:=0 to la-1 do begin
          if empty(ad[aarr[k]].ka) then pa:=nil
          else if not TRecDBDef.PGetArrDef(ad[aarr[k]].ka,pa) then continue;
          for p:=i to j do begin
            fl:=not Assigned(pa);
            if not fl then for l:=low(pa.aDat) to high(pa.aDat) do with pa.aDat[l] do
              if AType=aMemoDwt[fa] then if aBegMemFix[fa]+dwCod=lsf[p] then begin
                fl:=true; break;
              end;
            if fl then for l:=0 to ltw-1 do begin
              ad[ld]:=AddDef(atw[l].t+','+tARR,tARR+'.'+lsf[p],
                sAND+ad[aarr[k]].nmf+'='+tARR+'.'+fMGK+atw[l].w,fa,nil,ad[aarr[k]].ka,RDBArr);
              Inc(ld);
            end;
          end;
        end;
        SetLength(ad,ld);
      end;
    end;
  end;
  ZeroMemory(@al,SizeOf(al));
  for fa:=low(a) to high(a) do with als[fa] do begin
    ls:=TIntegerList.Create; SetLength(amem,ld); SetLength(a[fa],ld);
  end;
  ls:=TStringList.Create;
  try
    for fa:=low(a) to high(a) do if fa in ais then begin
      GetFieldNames(qDop.Connection,aMemoTbl[fa],ls);
      for i:=0 to ls.Count-1 do
        if AnsiFindText(ls[i],afo,j) then ls.Exchange(j,i);
      for i:=0 to ls.Count-1 do begin
        if ls[i]=aMemo[fa].zn then anf[fa]:=i;
        IncL(ls,i,aMemoTbl[fa]+'.');
      end;
      af[fa]:=StrTran(TrimRight(ls.Text),CRLF,','); SetLength(aa[fa],ld);
    end;
  finally
    ls.Free;
  end;
  for i:=0 to ld-1 do with ad[i] do begin
    s:=af[fa];
    a[fa][al[fa]]:=UnionDef(tbl+','+aMemoTbl[fa],s,nmf+'='+aMemoTbl[fa]+'.'+fMGK+where,s);
    als[fa].amem[al[fa]]:=f; aa[fa,al[fa]]:=i; Inc(al[fa]);
  end;
  for fa:=low(a) to high(a) do SetLength(als[fa].amem,al[fa]);
  so:=qDop.GetList(ArrStrToArrVar(afo));
  LenMemoZn:=GetLenMemoZn(qDop);
  SelCodeGetProc(selMemGkInit,[longint(@SelFlt),longint(qDop.Connection),longint(@afs),longint(@afsn)]);
  for fo:=low(a) to high(a) do begin
    fa:=aord[fo];
    with als[fa] do begin
      if fa in ais then begin
        SetLength(ares,100); k:=0;
        for i:=0 to al[fa]-1 do with a[fa,i] do begin
          qDop.Close; qDop.BufferChunks:=0; l:=qDop.PartCount(table,where);
          if l=0 then continue;
          j:=LsArrDynamic(table,at,',');
          qDop.SetArrayList(sTABLE,ArrStrToArrVar(at,j)); t:=qDop.GetListArg(sTABLE);
          qDop.Arg[sC_LIST]:=fld;
          with ad[aa[fa,i]] do begin
            if Assigned(rdb) then r:=rdb.DWRdbSeek else r:=nil;
            pMem:=nil;
            DWTypeMany(DWTypeManyProc,dwtoMemPrepare,[longint(@pMem),longint(qDop),longint(r),nmf,fa,longint(lsmDef)]);
          end;
          try
            if fa=famSel then begin
              if t=tDDAT then qDop.AddArrayList(sC_LIST,[tDDAT+'.'+fDDVid,tDDAT+'.'+fDDKv]);
              if fDef<>'' then qDop.AddArgList(sC_LIST,fDef);
            end;
            qDop.PartSelect('','',where,so,qDop.Arg[sC_LIST],false);
//RnmStack('TMemGkList.Create: '+qDop.Text);
            qDop.BufferChunks:=l; qDop.Open;
            qDop.First; g:=nil;
            if fa=famSel then with ad[aa[fa,i]] do begin
              fl:=true; sf:=nmf; tf:=IfThen(Pos('.',sf)=0,tbl+'.')+sf; svi:=nil;
              SelCodeGetProc(selMemGkIsSel,[longint(@fl),tf,longint(@g),longint(r),ka,longint(@svi)]);
              if not fl then continue;
              if not Assigned(g) then begin
                fl:=true; v:='';
                if Assigned(r) then begin
                  s:=r.TblFldName(r.FixSt(aBegMemFix[fa]));
                  for j:=0 to r.FDef.Count-1 do with r.FldDefInf(j)^,Inf do
                    if (AType=dwtSel) and (s+dwCod=sf) then begin
                      SelCodeGetProc(selMemGkGet,[longint(@fl),tf,longint(@g),longint(@Inf)]); break;
                    end;
                end;
              end;
              if not fl then continue;
              TRecDB.RestInf(svi);
              for j:=low(afsn) to high(afsn) do qDop.NumFromName(afs[j],afsn[j]);
            end
            else begin
              s:=''; sf:='';
            end;
            DWTypeMany(DWTypeManyProc,dwtoMemOpen,[longint(pMem),longint(qDop),longint(r)]);
            ShowStat('Чтение '+aMemo[fa].rod,StMemoLoad,
              [longint(Self),fa,longint(qDop),anf[fa],l,lDeshifr,longint(@k),LenMemoZn,longint(g),longint(@afsn),
              t,fDef,s,sf,longint(IfThen(Assigned(lsmDef),lsmDef,Self)),longint(pMem),longint(r),
              longint(DWTypeManyProc)],
              l,25000,false);
          finally
            DWTypeMany(DWTypeManyProc,dwtoMemClose,[longint(pMem)]);
          end;
        end;
      end;
      ls.SetOption(ilsSorted,true);
    end;
  end;
  qDop.Close; qDop.BufferChunks:=0;
  DelStack;
end;

destructor TMemGkList.Destroy;
var fa: TFldMemoAttr;
begin
  AddStack('TMemGkList.Destroy');
  for fa:=low(als) to high(als) do als[fa].ls.Free;
  inherited Destroy;
  DelStack;
end;

procedure TMemGkList.DestroyFromQuery;
var i,j: longint;
begin
  AddStack('TMemGkList.DestroyFromQuery');
  with FQuery do for i:=low(aObjInActive) to high(aObjInActive) do if aObjInActive[i]=Self then begin
    for j:=i+1 to high(aObjInActive) do aObjInActive[j-1]:=aObjInActive[j];
    SetLength(aObjInActive,Length(aObjInActive)-1); break;
  end;
  DelStack;
end;

function TMemGkList.GetValue;
var n: longint;
begin
  AddStack('TMemGkList.GetValue');
  result:='';
  if gk>0 then with als[fa] do if ls.IntObjFind(gk,n) then result:=ares[n];
  DelStack;
end;

procedure TMemGkList.GetFromQuery;
var i,j,k,l: longint;
	gk: longword;
  fa: TFldMemoAttr;
  f: TFld;
  s,s1,s2: string;
  pSelFlt: PArrVar;
begin
	AddStack('TMemGkList.GetFromQuery');
  if nmrecno<>'' then FRdb.GetRec(FQuery,0,[rgetNoDupl],nmrecno,lsDupl,aisGet);
  for fa:=low(als) to high(als) do if fa in ais then with als[fa] do
    for i:=low(amem) to high(amem) do if Assigned(amem[i]) then with amem[i] do begin
      s:=AnsiUpperCase(FieldName); gk:=AsInteger; pSelFlt:=nil;
      if ls.Find(gk,j) then begin
        if Assigned(lsDupl) then
          if lsDupl.Count>0 then
            if FRdb.Connection is TIBDatabase then begin
              k:=Length(s);
              if IsDigit(s[k]) then begin
                s1:=s;
                while k>0 do begin
                  if not IsDigit(s[k]) then break;
                  Dec(k); SetLength(s1,k);
                  if IntObjFind(lsDupl,s1,l) then begin
                    s2:=Copy(s,k+1,MaxInt); k:=Int0(s2);
                    if IntToStr(k)=s2 then if l=k then s:=s1;
                    break;
                  end;
                end;
              end;
            end
            else begin
              k:=RPos('_',s);
              if k>0 then begin
                s1:=LeftStr(s,k-1); s2:=Copy(s,k+1,MaxInt); k:=Int0(s2);
                if IntToStr(k)=s2 then if IntObjFind(lsDupl,s1,l) then if l=k then s:=s1;
              end;
            end;
        ls.IntObjSelf(j); s1:=ares[j];
        if fa=famSel then pSelFlt:=@SelFlt[j];
      end
      else s1:='';
      if FRdb.FldName(s,f) then begin
        if (fa=famArray) and (FRdb is TRecDBDef) then TRecDBDef(FRdb).SeekArrFld(s,f);
        if Assigned(f) then FRdb.SetMemGKVal(f,gk,s1);
        if Assigned(pSelFlt) then f.SelFlt:=pSelFlt^;
      end;
    end;
  if nmrecno<>'' then if FRdb is TRecDBDef then TRecDBDef(FRdb).ClearDuplModified;
  DelStack;
end;

{ TTblConcat }
procedure PrAddConcat(Sender: TRecDB; f: TFld; const nmFld: string;
  const Prm: array of variant; var lDone: boolean);
var i,cnt: longint;
  ls: TStringList;
  q: TMulQuery;
begin
  AddStack('RecDB.PrAddConcat');
  if Sender.AddCListProc(PointerVar(Prm[3]),f,nmFld,[Prm[4]]) then begin
    lDone:=false; ls:=PointerVar(Prm[0]); q:=PointerVar(Prm[2]);
    if IgnoreSlFindAdd(ls,nmFld,i) then begin
      cnt:=IntObj(ls,i); ls.Objects[i]:=pointer(cnt+1);
      StringListVar(Prm[1]).AddObject(nmfld,pointer(cnt));
    end
    else ls.Objects[i]:=pointer(1);
    q.AddArgList(sC_LIST,Sender.TblFldName(nmfld));
  end;
  DelStack;
end;

function TblConcatRdb(r: TRecDB): TRecDB;
begin
  AddStack('RecDB.TblConcatRdb');
  if r is TRecDBDef then result:=TRecDBDef(r).DWRdbSeek else result:=r;
  DelStack;
end;

procedure TTblConcat.RdbInit;
begin
  AddStack('TTblConcat.RdbInit',Self);
  Arg[sTABLE]:=''; Arg[sC_LIST]:='';
  DelStack;
end;

procedure TTblConcat.RdbAdd;
var i: longint;
begin
  AddStack('TTblConcat.RdbAdd',Self);
  i:=Length(a); SetLength(a,i+1);
  with a[i] do begin
    r:=rdb; lGet:=Get; fDef:=Def; nDef:=nLsmDef; DWTypeManyProc:=ADWTypeManyProc;
  end;
  DelStack;
end;

procedure TTblConcat.RdbPartSelect(const where: string = ''; const o_list: string = '';
  const tbldop: string = ''; PrAdd: TRDBClistAdd = nil; PrmAdd: pointer = nil);
var i: longint;
  ls: TStringList;
begin
  AddStack('TTblConcat.RdbPartSelect',Self);
  ls:=SortStrListCreate;
  try
    for i:=low(a) to high(a) do with a[i] do begin
      AddArgList(sTABLE,r.NameDB); lsDupl:=SortStrListCreate;
      r.AddCList(Self,[LongInt(ls),LongInt(lsDupl),LongInt(Self),LongInt(@PrAdd),LongInt(PrmAdd)],PrAddConcat);
    end;
  finally
    ls.Free;
  end;
  PartSelect(GetList([Arg[sTABLE],tbldop]),'',where,o_list);
  DelStack;
end;

procedure TTblConcat.RdbPartSelect(const aRdb: array of TRecDB;
  const aGetExclude: array of longint; const where: string = ''; const o_list: string = '';
  const tbldop: string = ''; PrAdd: TRDBClistAdd = nil; PrmAdd: pointer = nil);
var i: longint;
  stGetExclude: TByteSet;
begin
  RdbInit; stGetExclude:=[];
  for i:=low(aGetExclude) to high(aGetExclude) do Include(stGetExclude,aGetExclude[i]);
  for i:=low(aRdb) to high(aRdb) do RdbAdd(aRdb[i],not(i in stGetExclude));
  RdbPartSelect(where,o_list,tbldop,PrAdd,PrmAdd);
end;

procedure TTblConcat.RdbGetFromQuery;
var i: longint;
begin
  AddStack('TTblConcat.RdbGetFromQuery',Self);
  for i:=low(a) to high(a) do RdbGetFromQueryIndex(i);
  DelStack;
end;

procedure TTblConcat.RdbGetFromQueryIndex;
begin
  AddStack('TTblConcat.RdbGetFromQueryIndex',Self);
  with a[Index] do if lGet then
    if NoMemo then r.GetFromQuery(Self,false,FldDuplicate(fRECNO,Index),lsDupl)
    else with lsm do begin
      FRdb:=TblConcatRdb(r); GetFromQuery(FldDuplicate(fRECNO,Index),lsDupl);
    end;
  DelStack;
end;

procedure TTblConcat.RdbNewRec;
var i: longint;
begin
  AddStack('TTblConcat.RdbNewRec',Self);
  for i:=low(a) to high(a) do TblConcatRdb(a[i].r).NewRec([newrNoDoNewRec]);
  DelStack;
end;

class function TTblConcat.CreateConnection(var Qry: TTblConcat; AOwner: TComponent; AConnection: TComponent): boolean;
begin
  AddStack('TTblConcat.CreateConnection');
  result:=CreateConnection(TMulQuery(Qry),AOwner,AConnection);
  DelStack;
end;

class function TTblConcat.CreateNoActive(var Qry: TTblConcat; AOwner: TComponent; AConnection: TComponent = nil): boolean;
begin
	AddStack('TTblConcat.CreateNoActive');
  result:=CreateNoActive(TMulQuery(Qry),AOwner,AConnection);
  DelStack;
end;

destructor TTblConcat.Destroy;
begin
  AddStack('TTblConcat.Destroy',Self);
  Close;
  inherited Destroy;
  DelStack;
end;

procedure TTblConcat.DoAfterOpen;
var i: longint;
begin
  AddStack('TTblConcat.DoAfterOpen',Self);
  if not NoMemo then for i:=low(a) to high(a) do with a[i] do
    lsm:=TMemGkList.Create(r,Self,nil,nil,true,mgdAll,fDef,a[ReplNeg(nDef,i)].lsm,
      FldMemoAttrAll,PrAddDefArr,DWTypeManyProc);
  inherited DoAfterOpen;
  DelStack;
end;

procedure TTblConcat.DoAfterClose;
var i: longint;
begin
  AddStack('TTblConcat.DoAfterClose',Self);
  inherited DoAfterClose;
  for i:=low(a) to high(a) do a[i].lsDupl.Free;
  a:=nil;
  DelStack;
end;

function TTblConcat.LsDupl;
begin
  AddStack('TTblConcat.LsDupl',Self);
  result:=a[Index].lsDupl;
  DelStack;
end;

{ TFixDatStrList }
constructor TFixDatStrList.Create(const fld: string;
  const sBeg: string = sFix; Proc: TFixDatStrListProc = nil; Prm: pointer = nil);
begin
  Create(fld,[],sBeg,Proc,Prm);
end;

constructor TFixDatStrList.Create(const fld: string; const ar: array of TRecDBDef;
  const sBeg: string = sFix; Proc: TFixDatStrListProc = nil; Prm: pointer = nil);
var a: TArrRecDBDef;
  i,j,k,l: longint;
  r: TRecDBDef;
  p: PFixDatRec;
  sFixSt,beg: string;
begin
  AddStack('TFixDatStrList.Create');
  Sorted:=true; SetLength(aDat,1);
  if Length(ar)=0 then with LsCustomRec do begin
    InitAll; l:=0; i:=Count; SetLength(a,i);
    for i:=0 to i-1 do if IsClass(Objects[i],TRecDBDef,pointer(a[l])) then Inc(l);
    SetLength(a,l);
  end
  else CopyFromRecDBDef(a,ar);
  for i:=low(a) to high(a) do begin
    r:=a[i];
    if not empty(r.DWName) then begin
      sFixSt:=r.FixSt(sBeg); beg:=sFixSt+fld; j:=-1;
      if IsBeg(r,beg,j) then begin
        if IntObjFindAdd(Self,r.NameDB,l) then p:=@aDat[l]
        else begin
          if Length(aDat)=l then SetLength(aDat,l shl 1);
          p:=@aDat[l]; Finalize(p^);
          if Assigned(Proc) then Proc(r,p,sFixSt,Prm);
        end;
        k:=0; l:=Length(p.aRec);
        while k<l do
          if p.aRec[k].r.FixSt(sBeg)=sFixSt then break else Inc(k);
        if k=l then begin
          SetLength(p.aRec,l+1); p.aRec[k].r:=r;
          SetLength(p.aRec[k].af,r.FieldCount-j); l:=0;
          while j<r.FieldCount do begin
            if not IsBeg(r,beg,j) then break;
            p.aRec[k].af[l]:=r.FieldName[j]; Inc(l); Inc(j);
          end;
          SetLength(p.aRec[k].af,l);
        end;
      end;
    end;
  end;
  DelStack;
end;

procedure TFixDatStrList.InitAll;
begin
  AddStack('TFixDatStrList.InitAll');
  RDBArr;
  DelStack;
end;

function TFixDatStrList.GetDat;
begin
  AddStack('TFixDatStrList.GetDat');
  result:=@aDat[IntObj(Self,i)];
  DelStack;
end;

class function TFixDatStrList.IsBeg;
begin
  AddStack('TFixDatStrList.IsBeg');
  if nf<0 then r.FieldFind(beg,nf);
  if nf<r.FieldCount then result:=AnsiStartsStr(beg,r.FieldName[nf]) else result:=false;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurLib',[TRecVal,TRecDB,TRecDBDef]);
end;

procedure Init;
const aMemPrim: TFldMemoAttrStr = ('Текстовые значения','Массивы','Выбор значений');
var fa: TFldMemoAttr;
begin
	AddStack('RecDB.initialization');
  ZeroMemory(@aQry,SizeOf(aQry));
  SetPrim(tARRV,'Виды массивов');
  SetPrim(tMAXFLD,'Максимальные значения уникальных полей');
  sAttrMem:=[];
  for fa:=low(aMemo) to high(aMemo) do begin
    SetPrim(aMemoTbl[fa],aMemPrim[fa]); Include(sAttrMem,aMemo[fa].attr);
  end;
  SetLength(aArrDef,10);
	with TInter do begin
    setvar('$mulqry','ТВБ_','Выборка из таблиц');
    setvar('ТВБ_НОМЕР','Номер текущей открытой выборки из таблиц',d_cur,0,'I');
    setvar('ТВБ_КОЛЗАП','Количество записей в выборке из таблиц',d_inf,VarArrayOf([0,0]),'I',true);
    setvar('ТВБ_ВНАЧАЛЕ','Признак начала выборки из таблиц',d_inf,VarArrayOf([true,1]),'L',true);
    setvar('ТВБ_ВКОНЦЕ','Признак конца выборки из таблиц',d_inf,VarArrayOf([true,2]),'L',true);
    setvar('ТВБ_КОЛПОЛЕЙ','Количество полей в выборке из таблиц',d_inf,VarArrayOf([0,3]),'I',true);
    setvar('ТВБ_ТЕКСТ','Текст выборки из таблиц',d_inf,VarArrayOf(['',4]),'I',true);
    setvar('ТВБ_СООБЩЕНИЯ','Выдавать сообщение при ошибке открытия таблицы',d_msg,null,'L');

    SetFunction('Выборка из таблиц',1200);
    SetFunction('ТВБ_ОТКРЫТЬ','Открыть выборку из таблиц',
      ['Табл: строка|массив~1: целое~2: целое~3: целое~4: целое',
      '[Поля: строка|массив]~Запрос: строка~Табл: строка~Табл: строка~Табл: строка',
      '[Фильтр: строка]~НеИспольз1: пусто~Поля: строка|массив~[Фильтр: строка]~Поля: строка|массив',
      '[Порядок: строка|массив]~НеИспольз2: пусто~Знач: строка|массив~НеИспольз1: пусто~Знач: строка|массив',
      '[Групп: строка|массив]~НеИспольз3: пусто~[Фильтр: строка]~НеИспольз2: пусто~[Уник: логическое = '+vFalse+']',
      '[Создать: логическое = '+vTrue+']~[Создать: логическое = '+vTrue+']~[Создать: логическое = '+vTrue+']~[Создать: логическое = '+vTrue+']~[Создать: логическое = '+vTrue+']',
      '[БД: целое]~[БД: целое]~[БД: целое]~[БД: целое]~[БД: целое]',
      '[Откр: логическое = '+vTrue+']'],
      ['CAN','CAU','CAU','CAU','CALU','LU','NU','LU'],c_open,null,1201,'I');
    SetFunction('ТВБ_ЗАКРЫТЬ','Закрыть выборку из таблиц',['[Номер: целое]'],['NU'],
      c_close,null,1202);
    SetFunction('ТВБ_НАЧАЛО','Встать на начало выборки из таблиц',c_first,null);
    SetFunction('ТВБ_КОНЕЦ','Встать на конец выборки из таблиц',c_last,null);
    SetFunction('ТВБ_СЛЕД','Встать на следующую запись выборки из таблиц',c_next,null);
    SetFunction('ТВБ_ПРЕД','Встать на предыдующую запись выборки из таблиц',c_prior,null);
    SetFunction('ТВБ_ЗНАЧЕНИЕ','Значение поля в выборке из таблиц',
      ['Поле: строка|целое'],['CN'],c_fld,null,1203,'FCD');
    SetFunction('ТВБ_СТРЗН','Строковое представление значения для выборки из таблиц',
      ['Знач: любое'],[],c_vartos,null,1204,'C');
    SetFunction('ТВБ_БДОТКРЫТЬ','Открыть базу данных для выборки',
      ['Наим: строка~НеИспольз: пусто','[Парам: массив]~Идент: строка',
      '[Пароль: строка]~[Создать: логическое = '+vTrue+']','[Создать: логическое = '+vTrue+']'],
      ['CU','ACU','CLU','LU'],c_dbopen,null,1205,'I');
    SetFunction('ТВБ_БДЗАКРЫТЬ','Закрыть базу данных для выборки',
      ['[Номер: целое]'],['NU'],c_dbclose,null,1206);
    SetFunction('ТВБ_ПОЛЕ','Наименование поля в выборке из таблиц',
      ['Номер: целое'],['N'],c_fldname,null,1207,'C');
    SetFunction('ТВБ_СОЗДАТЬ','Создать пустую таблицу по описанию',
      ['ОпрРазд: строка','[ТблСозд: строка = ОпрРазд]','[ТблОпрРег: логическое = '+vFalse+']','[БД: целое]'],
      ['C','CU','LU','NU'],c_createtable,null,1208,'L');
    SetFunction('ТВБ_ПОЛЕИЗТАБЛ','Массив строк фильтра по полю из таблицы',
      ['Поле: строка|массив','Табл: строка|массив','[Инверт: логическое = '+vFalse+']','[Фильтр: строка]',
      '[ПолеТабл: строка|массив = Поле]'],
      ['CA','CA','LU','CU','CAU'],c_fldinsel,null,1209,'A');
    SetFunction('ТВБ_ТРАНЗАКЦИЯ','Открыть/закрыть транзакцию',
      ['[Опер: массив|строка|логическое = '+vFalse+']'],['ACLU'],c_trns,null,1210,'L');
    SetFunction('ТВБ_ПОИСК','Поиск в выборке из таблиц',
      InterPrmMax(['Знач: любое','[Первый: логическое = '+vTrue+']','[Алг: любое]']),['','LU'],c_find,null,0,'L');
    SetFunction('StrShifr','',['Стр: строка','[Дешифр: логическое = '+vFalse+']'],['C','LU'],
      c_strshifr,null);
    SetFunction('GetFromQuery','',['Табл: строка'],['C'],c_getfromquery,null);
    SetFunction('GetMaxFld','',['Поле: строка','Табл: строка'],['C','C'],c_getmaxfld,null,0,'I');
    //SetFunction('GetPrim','',['Табл: строка'],['C'],c_getprim,null);
  end;
  //VarToStr('');
  DelStack;
end;

initialization
  Init;
finalization
	AddStack('RecDB.finalization');
  TRecDBDef.ClearArrDef;
  DelStack;
end.

