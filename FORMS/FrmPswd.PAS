unit FrmPswd;

interface

{$I LIBTEST}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs, ExtCtrls, DB, DBTables,
  MyTypes, My_pr, Askp, FStat, FRMEMPTY, FFldedit, RecVal, Recdb, PnlEdit, Keylb, Fpanel,
    mulqry, DefEdit, TreePrim, ButGet, FMsgLst, MenuGet, ComboGet, MultiGet, CCodeGet, PswdGet,
    PaintCtl, Codegets, BrQuery, FrmBrIB;

type
	TDBMainModify = (mdfBegin,mdfExec,mdfEnd);
  TInterbasePath = (ibppLocal,ibppRemoved,ibppNoStd);

  TSaveToServProc = procedure(q: TMulQuery; const fname: string; const av: array of variant);

  TLogVid = record
    v: longint;
    nm: string;
    ltbl: boolean;
  end;

  TLogKeys = record
    cod,nm,ms: string;
    g: TCustomGet;
  end;

  TLogPrm = record
    vid: longint;
    dbeg: TDateTime;
  end;

  TMemoDelUnusedProc = procedure(const v: variant);
  TMemoDelUnusedErr = procedure(const msg,tbl: string; Proc: TMemoDelUnusedProc; const v: variant; var Aborted: boolean) of object;

  TCopyDBDBFList = (dbdbfSetDbs,dbdbfNoCanEsc); TCopyDBDBFOpt = set of TCopyDBDBFList;
  TSaveToServerOpt = set of (srvCanDrop,srvCanEsc);
  TLockModeList = (lockmdMono,lockmdNoShow,lockmdNo); TLockModeOpt = set of TLockModeList;

  TInterbaseType = (ibtBDE,ibtFIB);

  TPackTblOper = (pcktTbl,pcktBefore,pcktAfter);
  TPackTblProc = procedure(Oper: TPackTblOper; const ap: array of variant; var av: TArrVar);

  TUserCng = record
    tbl,nmf: string;
    nodel: boolean;
  end;
  TArrUserCng = array of TUserCng;

  TUserCngAdd = procedure(var Dest: TArrUserCng; const Source: array of TUserCng);
  TUserCngProc = procedure(const UserCng: TUserCng; const av: array of variant; var result: boolean) of object;

  TFormPswd = class(TFormEmp)
    PnInfo: TRbPanel;
    PnPsw: TPanelEdit;
    Rec: TRecVal;
    EUser: TFldEdit;
    EPswd: TFldEdit;
    RG: TRecDB;
    dePswd: TDefEdit;
    RUsers: TRecDB;
    deUser: TDefEdit;
    deGlob: TDefEdit;
    dePrm: TDefEdit;
    IconGet: TButGet;
    dlgIco: TOpenDialog;
    deCopyData: TDefEdit;
    deDer: TDefEdit;
    DerTblGet: TComboGet;
    DerIPGet: TComboGet;
    RUsPrm: TRecDB;
    tmBlink: TTimer;
    deLogDel: TDefEdit;
    function PnPswValid(Sender: TObject): Boolean;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RGAfterOpen(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function deUserFldCheck(Sender: TObject): Boolean;
    function deUserPnlValid(Sender: TObject): Boolean;
    function deGlobPnlValid(Sender: TObject): Boolean;
    function dePrmPnlValid(Sender: TObject): Boolean;
    procedure IconGetPaint(Sender: TObject; const ARect: TRect; const Text: String);
    function IconGetClick(Sender: TObject; lEval: Boolean): String;
    procedure deGlobFldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure dePrmFldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    function dePrmFldCheck(Sender: TObject): Boolean;
    function deGlobPnlAskCancel(Sender: TObject): Boolean;
    procedure dePrmKpProcKey(key: longint; tw: TWinControl);
    function deCopyDataPnlValid(Sender: TObject): Boolean;
    procedure deCopyDataFrmShow(Sender: TObject);
    procedure EUserEnter(Sender: TObject);
    procedure EUserExit(Sender: TObject);
    procedure deUserFrmShow(Sender: TObject);
    procedure deGlobKpProcKey(key: Integer; tw: TWinControl);
    function deDerFldCheck(Sender: TObject): boolean;
    function deDerPnlValid(Sender: TObject): boolean;
    procedure deDerFldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    function EUserCheck(Sender: TObject): Boolean;
    procedure deCopyDataPnlCngKey(Sender: TObject; var tb: TKeyBut);
    procedure PnPswCngKey(Sender: TObject; var tb: TKeyBut);
    function deLogDelFldCheck(Sender: TObject): Boolean;
  private
    { Private declarations }
    PrivModified,PrivSelfModified,NoCngWState,oFdpFormOnView,igMod,IconMod,FirstUpdTimer,FCanUpd,WasUpd: boolean;
    msg,sIcon,oPsw,DerIP: string;
    FSUAbort: variant;
    aUpdZn: TArrInt;
    ls,LsTblTrns,LsWasUpd: TStringList;
    aPriv: TArrStr;
    lCrtInd: TIndFileTypes;
    BusyQuerys,nMono,nEdConf,lLog,LogUn,lPriv: longint;
    amq: array of record
    	q: TMulQuery;
      s: string;
    end;
    aKey: TArrInt;
    igIcon: TIcon;
    igss: TStringStream;
	  FDBDBF: TDatabase;
    QryRegs,QryUsers: Tmulquery;
    FDBTrns: TComponent;
    FTblSQLTimeOffs: PDouble;
    aLog: array of record
      Prm: array[boolean] of TLogPrm;
      lDop: longint;
      aDop: array of record
        Prm: TLogPrm;
        d: TDateTime;
        tbl,prim,KeyStack: string;
        LogKeys: TLogKeysSave;
      end;
    end;
    lLogKeystack,lLogPrim: byte;
    aConstraintChk: array of record
      tbl: string;
      af: TArrStr;
    end;
    function GetLogVid: longint;
    procedure SetLogVid(Value: longint);
    function GetPLogKeys: PLogKeysSave;
    procedure SetPLogKeys(Value: PLogKeysSave);
		procedure Timer(Sender: TObject);
    procedure ParamToKeys(const name: string);
    procedure TimerKeys(Sender: TObject);
    procedure SetPrmUser(const Index: string; const Value: variant);
		procedure WaitConnected(Sender: TAsk);
		function LockExit(Sender: TObject): boolean;
		procedure PrivFill(Sender: TObject);
		procedure PrivEd(Key: longint; tw: TWinControl);
    function PrivHeadX(const nmus: string): Word;
    function UserCngProc(Proc: TUserCngProc; const av: array of variant): boolean;
          procedure UserValid (const UserCng: TUserCng; const av: array of variant; var result: boolean);
    class procedure UserCanDel(const UserCng: TUserCng; const av: array of variant; var result: boolean);
    class procedure UserDel   (const UserCng: TUserCng; const av: array of variant; var result: boolean);
		function DoGetUpd(q: TMulQuery): boolean;
		class procedure TimerTerminate(Sender: TObject);
		procedure ProcKey(key: longint; tw: TWinControl);
    function IconCreate: TIcon;
		function igssLoad(Icon: TIcon; lLoad: boolean = true): boolean;
		procedure igssSave(const s: string);
		procedure UnZglErr(const Zgl: string; var afl: TArrInt; p: PBoolean; var aErr: TArrStr; var lErr: longint);
		function StMemoFldProc(Sender: TStat; lsf: TStringList; Proc: TStatEvent0; const av: array of variant): TStringList;
		procedure UserKeyProc(Key: longint; tw: TWinControl);
    procedure QryUsersAfterOpen(DataSet: TDataSet);
    procedure lsTblSQLFill;
    procedure lsTblSQLFree;
    procedure RegsCreate;
    function DerName: string;
    function IsDerName(tp: TProtocolFileList): boolean; overload;
    class function IsDerName(tp: TProtocolFileList; const DerName: string): boolean; overload;
    procedure SaveDer;
    function DbTrns: TComponent;
    procedure DBTrnsFree;
    procedure FDBTrnsFree(Sender: TObject);
    procedure CopLast(lCopDay: boolean);
    function IDUpd: longword;
    procedure Timer1Timer(Sender: TObject);
    class function UserGetFormIBList(Sender: TFldEdit = nil): TFormBrIB;
    class procedure UserGetAfterList(Sender: TObject);
    class function UserGetStrName(Sender: TObject; Qry: TBrQuery): String;
    class function UserGetTransSeek(Sender: TObject; tf: TFldEdit;
      const Value: String; Size: longint; lSQL: Boolean): String;
    procedure WMNoCngWState(var Message: TWMSize); message WM_NOCNGWSTATE;
    procedure WMTimeChange(var Message: TMessage); message WM_TIMECHANGE;
    procedure WMProtSave(var Message: TWMProtSave); message WM_PROTSAVE;
  	procedure WMCngPriv(var Msg: TMessage); message WM_CNGPRIV;
  protected
  	LsUpdNm: TStringList;
    aPrivFld: TArrStr;
    DateNow: TDateTime;
    KeyPrmLocal: longint;
    flClose,lCopLast,lRestart: boolean;
    UserCntEndReserv: Word;
    ProcIndex: function(Sender: TAsk; lCrt: boolean; tp: TIndFileType): boolean;
    procedure PrivDefault(lSuper: boolean); virtual;
    function GetPrmUser(const Index: string): variant; virtual;
		procedure SetCanUpd(Value: boolean); virtual;
		function CreateIndex(Sender: TAsk): boolean; virtual; abstract;
		function LoadForms(Sender: TAsk): boolean; virtual; abstract;
		procedure ExecProg; virtual; abstract;
		function RegModify(Sender: TAsk; const Vers,LastVers: string; fl: TDBMainModify): boolean; virtual;
		function DBMainModify(Sender: TAsk; const Vers: string; fl: TDBMainModify): boolean; virtual; abstract;
		function GetPswdInit: string; virtual;
    procedure SetPrivModified(const nmus: string); virtual;
		procedure CheckUnique(Sender: TStat);
    function SetMemoFld: boolean;
		function ConvertDateBig(const acRdb: array of TRecDBDef): boolean;
		function MsgGetUpd: boolean; virtual;
    function ProtDopInf: string; virtual;
		procedure FixKeyProc(Key: longint; tw: TWinControl); virtual;
    procedure DateRegSet; virtual;
    class procedure UserCngAdd(var Dest: TArrUserCng; PrAdd: TUserCngAdd); virtual;
		procedure LogInit(const aVid: array of TLogVid; const aKeys: array of TLogKeys; lKeys: longint);
		class function PrDelMemo(const nmf: string; fa: TFldMemoAttr): boolean;
		procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure ConstraintChkAdd(const cTbl: string; const caf: array of string);
    procedure UserCngName(const onm,nnm: string);
  public
    { Public declarations }
    PswdPrm: TPswdPrm;
    MsgLst: TMsgLst;
  	aModeFld: TArrStr;
    RecGlob: TRecDB;
    SDateReg,UserName,FileIdentProg: string;
    DateReg: TDateTime;
    NoLockSuper,LogDop: boolean;
    nSuper,lLogVid,lLogKeys: longint;
    QryMsg,QryLog: Tmulquery;
    Timer1: TTimerLock;
    LogKeys: TLogKeysSave;
    aLogVid: array of TLogVid;
    aLogKeys: array of TLogKeys;
    aLogVidOrd,aLogKeysOrd: TArrInt;
    UserGet: TCodeGet;
    function SUAbort: string;
		function CalcMode(DataSet: TMulQuery): string; virtual;
    procedure UserTabu(Tree: TTreePrim; const nmus: string); virtual;
    procedure SetPassword;
    procedure UserPrivEdit;
		procedure GetUpd(const nmMsg: string); virtual;
    procedure SendUpd(const nmMsg: string; lSelf: boolean = false); overload;
    procedure SendUpd(const aMsg: array of string; lSelf: boolean = false); overload;
		procedure SetInfoName(const s: string);
    function Registration(aCreateRegs: pboolean=nil): boolean;
    procedure UnRegistration;
		function Pack(Proc: TPackTblProc = nil; lLockSuper: boolean = true): boolean;
		procedure ReStart(const aKey: array of longint; lAsk: boolean = false;
    	Mode: TModalResult = mrNo; const UsName: string = '');
    function GetQuery(AConnection: TComponent = nil): TMulQuery; overload;
    function GetQuery(lIf: boolean): TMulQuery; overload;
    procedure FreeQuery; overload;
    procedure FreeQuery(q: TMulQuery); overload;
    procedure tryQuery(var QueryBefTry: longint);
    procedure exceptQuery(QueryBefTry: longint);
    function CurQuery: TMulQuery;
		function PrmLocal(const aDopName,aDopSection: array of string;
    	const Capt: TCaption = ''; lRestart: boolean = true): boolean; virtual;
		procedure PrmServer;
		function CopyDatFromServer(const cdir: TFileName = ''; lsExclude: TStringList = nil;
    	ValueProc: TCopyTableValueProc = nil): boolean;
		function CopyDBDBF(Sender: TAsk; const tbl: string; CanEsc: boolean = true): boolean; overload;
		function CopyDBDBF(Sender: TAsk; Opt: TCopyDBDBFOpt = []): boolean; overload;
		class function DBConnect(db: TComponent; const SectIni,MsgErr: string): boolean;
		class function SetDBPrm(db: TComponent; const SectIni,DirDefault: string;
    	BegSetup: boolean = true; pPath: PString = nil): boolean;
		class function CreateDatabase(const SectIni,DatabaseName: string;
      IBTypeDefault: boolean = true): TComponent; overload;
		class function CreateDatabase(DatType: TDBTypeList; const DatDriver,DatabaseName: string;
      IBType: TInterbaseType = ibtFIB): TComponent; overload;
		function DBDBF(const path: TFileName = ''): TDataBase;
		class procedure SaveToServer(Sender: TStat; const aFile: array of string;
    	q: TMulQuery; const Path: string; const av: array of variant;
      Proc: TSaveToServProc = nil; Opt: TSaveToServerOpt = []);
    class procedure LoadFromServer(Sender: TStat;	q: TMulQuery; const Path: string; const av: array of variant;
      Proc: TSaveToServProc = nil; CanEsc: boolean = false);
		class procedure StCopyDat(Sender: TStat);
    procedure ViewDerTbl;
    function MemoDelUnused(ProcErr: TMemoDelUnusedErr; AskErr: boolean): boolean;
    function PartCount(const table: string; const where: string = ''): longint;
    function PartCount0(const table: string; const where: string = ''): boolean;
    function VarToS(const vv: variant; Opt: TVarToSOpt = []): string; overload;
    function VarToS(const vv: variant; Opt: TVarToSList): string; overload;
    function VarToS(f: TField; Opt: TVarToSOpt = []): string; overload;
    procedure UpdateTable(const table: string; const c_list,v_list: array of variant;
    	const where: string = '');
		function DeleteTable(const table: string = ''; const where: string = ''; lMsg: boolean = false): boolean;
		function FldInSel(const nmf,tbl: string; const where: string = ''; const snmf: string = '';
    	Opt: TFldInSelOpt = []; ares: PArrStr = nil; const group: string = '';
      qs: TMulQuery = nil; ls: TStringList = nil): string;
		function GetList(const aa: array of variant; l: longint = NegDef): string;
		function Concat(const a: array of variant; l: longint = NegDef): string;
		function GetPart(const name: string; const argname: array of string;
    	const argval: array of variant): string;
    function PartMaxInt(const table,nmf: string; const where: string = ''): longint;
		function DropTable(const tbl: string; msgErr: pstring=nil): boolean;
		function QQDate(const nmf: string; const db,de: variant): string;
    procedure DBFlush(Opt: TDBFlushOpt = []);
    procedure MaxFldClear(const nmTbl: string);
    function CngLogVid(Value: longint; OnlyCng: boolean = false): longint; overload;
    function CngLogVid(rdb: TRecDB; OnlyCng: boolean = false): longint; overload;
    procedure LogWrite(const tbl: string = ''; const prim: string = '');
    function PLogKeysLen(Len: longint = 0): PLogKeysSave;
    property LogVid: longint read GetLogVid write SetLogVid;
    property PLogKeys: PLogKeysSave read GetPLogKeys write SetPLogKeys;
    property PrmUser[const Index: string]: variant read GetPrmUser write SetPrmUser;
    property CanUpd: boolean read FCanUpd write SetCanUpd;
  end;

  TServicesList = class(TStringList)
  private
    oText: string;
    aErr: TArrStr;
    nPortIB: longint;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetPortIB(const Capt: string);
    function ChkReboot: boolean;
  end;

  TSQLDM = class(TComponent)
  private
    { Private declarations }
    OpenDialog1: TOpenDialog;
    RPrm: TRecVal;
    deIntrbase: TDefEdit;
    deStandard: TDefEdit;
    StdDrvGet: TComboGet;
{ $IFDEF OLDCNF
    deMySQL: TDefEdit;
{$ENDIF}
    procedure deIntrbaseFrmShow(Sender: TObject);
    procedure deStandardFrmShow(Sender: TObject);
    procedure deIntrbaseFldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure deIntrbaseFldExit(Sender: TObject);
    function deIntrbaseFldCheck(Sender: TObject): Boolean;
    procedure deIntrbaseFldEnter(Sender: TObject);
		procedure UserKeyProc(Key: longint; tw: TWinControl);
  public
    { Public declarations }
    class procedure Load;
  end;

  TDBPrmPswdGet = class(TPswdGet)
  private
		procedure ProcKey(key: longint; tw: TWinControl);
  protected
    sC: TPaintButton;
		procedure CreateObj(tf: TFldEdit); override;
    function AssignObj(tf: TFldEdit): boolean; override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    procedure PlaceControls(tf: TFldEdit; Condens: boolean); override;
  end;

  TDBPrmGetInfo = record
{ $IFDEF OLDCNF
  	Cnf: TConfigStr;
{$ENDIF}
  	AType: TDBTypeList;
    Password,Prm: string;
    aName: TDBTypeStr;
  end;

  TDBPrmGet = class(TMultiGet)
  private
  	oDriver: string;
		LsStr: TStringList;
    lCon: boolean;
    oShow: TNotifyEvent;
		function ReadPrm: string;
		class procedure fChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
		procedure fTypeChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
		procedure fDrvEnter(Sender: TObject);
		procedure fDrvExit(Sender: TObject);
		procedure ProcKey(Key: longint; tw: TWinControl);
{ $IFDEF OLDCNF
		procedure BeforeDeExec(de: TDefEdit);
		procedure CorPrmPath(var Prm: string);
		function FValueToPrm(tf: TFldEdit; const Value: string): TDBPrmGetInfo;
{$ENDIF}
    function PrmGetClick(Sender: TObject; lEval: boolean): string;
    procedure ConPswGetClick(Sender: TObject);
    procedure ConPswShow(Sender: TObject);
		function MnName(tp: TDBTypeList): string;
		procedure SetRPrm(const Prm: string);
		function IsStandard: boolean;
		function deSeek: TDefEdit;
    procedure LsStrToRPrm(de: TDefEdit);
    class procedure UpdateRecSect(tf: TFldEdit; const Sect: string; lClr: boolean);
  protected
  	PrmMask: array[1..3] of string;
  	Rec: TRecVal;
  	{ $IFDEF OLDCNF fCnf,{$ENDIF}fType,fDrv,fPrm,fPsw: TFldEdit;
		procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function AssignObj(tf: TFldEdit): boolean; override;
		procedure ReadFirst(tf: TFldEdit); override;
		procedure UpdateRec(tf: TFldEdit; Oper: TFEUpdateOper); override;
    procedure HookProc(tf: TFldEdit; var Message: TMessage); override;
		procedure Paint(tf: TFldEdit); override;
    class procedure FMaskView(var Mask: string); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  	//class function DDatSupport: boolean; override;
		class function CreateDatabase(tf: TFldEdit): TComponent;
		class function Connect(db: TComponent; tf: TFldEdit): boolean;
    class procedure FBLocalCheck(db: TComponent; FBLocal: boolean = false; const Port: string = '');
{ $IFDEF OLDCNF
		class function CheckDSN(de: TDefEdit; db: TComponent; const Cnf: TConfigStr;
	    const cPath: TFileName): boolean;
		class function FldConfigMask: string;
		class function IsClientOnly(const Cnf: TConfigStr): boolean;
		class function ReadConfig(const Sect: string = stpReg): string;
		class procedure WriteConfig(const Sect,Value: string);
		class procedure WriteConfigFile(f: TIniFileCheck; const Sect,Value: string);
{$ENDIF}
		class function GetInfo(db: TComponent): string;
		class function ValueToPrm(const Value: string): TDBPrmGetInfo;
		class function PrmToValue(const Prm: TDBPrmGetInfo): string;
		class procedure DirDataToIni(const FileGdb: string; const Sect: string = stpReg; const Port: string = '');
		class procedure WriteParamToIni(const Sect: string; const p: TDBPrmGetInfo;
      lClr: boolean = false);
    class procedure CorrPrm(f: TIniFileData; const Sect: string; pFileIdentProg: PString = nil);
  published
		function MaskEdProc(const Capt: TCaption; var Mask: string;
    	r: TCustomRec; const nmf: string; lSearch: boolean): variant; override;
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

  PArrMulCreateTbl = ^TArrMulCreateTbl;
  TArrMulCreateTbl = array of record
	  FieldName: string;
    DataType: TFieldType;
    Size: longint;
    NotNull: boolean;
  end;

  TTableTrans = (ttNone,ttWinToDos,ttDosToWin);

  TCopyTableList = (cptNoCreate,cptCanEsc,cptNoTxtTo,cptNoDropTmpTbl,cptNoDbt,cptDbfTo);
  TCopyTableOpt = set of TCopyTableList;

  TCopyTableRecProc = procedure(Source,Dest: TObject; lAfter: boolean; var result: boolean);
  TModifyTableMsgProc = procedure(Prm: pointer; const tbl,msg: string);

  PUnionFrom = ^TUnionFrom;
  TUnionFrom = array of record
    where: string;
    lr: longint;
  end;

const
  aResProcServer: array[TResProcServerList] of TResProcessList = (resIntrbase,resFirebird);
  aInterbaseExt: array[TInterbaseExt] of string = ('GDB','FDB');

var
  FormPswd,ProgPswd: TFormPswd;
  SQLDM: TSQLDM;
  ProtocolActive: boolean = true;
  LsTabu: TStringList;
  InterbaseType: TInterbaseType;
  DerIPTrans: procedure(q: TMulQuery; var Value: string);
  TabuExec: function(const nmus: string): boolean;
  TabuClearList: procedure(ls: TStringList; lFree: boolean = true);
  TabuLoadList: procedure(var ls: TStringList; const nmus: string; Qry: TObject);

function LockMode(const NameMode,nmFld,where: string;
  flLock: longint; MaxCnt: longword = 3; Opt: TLockModeOpt = []; Interval: longword = 0): boolean;
procedure UnLockMode(const nmFld: string);
function LockSuper(const msg: string = ''): boolean; overload;
function LockSuper(usl: boolean; const msg: string = ''): boolean; overload;
procedure UnLockSuper;
function LockMono(const NameMode: string = 'Монопольный'): boolean;
procedure UnLockMono;
function LockEdConf: boolean; overload;
function LockEdConf(usl: boolean): boolean; overload;
procedure UnLockEdConf;
function FLockSuper(flLock: longint): boolean;
function FLockMono(flLock: longint): boolean;
function FLockEdConf(flLock: longint): boolean;
procedure TrnsEndWnd(Sender: TStat; ProcUnLock: TProcNone = nil); overload;
procedure TrnsEndWnd(Sender: TAsk; ProcUnLock: TProcNone = nil); overload;
procedure TrnsEndSuper(lRollBack: boolean = true);
procedure TrnsEndMono(lRollBack: boolean = true);
procedure TrnsEndEdConf(lRollBack: boolean = true);
procedure ViewUserInfo;
function NowDouble: Double;
function CopyTable(dbFrom,dbTo:TComponent; const table:string; flTrans: TTableTrans;
  Opt: TCopyTableOpt = []; p: Pointer = nil; const where: string = '';
  ValueProc: TCopyTableValueProc = nil; pa: PArrMulCreateTbl = nil;
  RecProc: TCopyTableRecProc = nil; const olist: string = ''): boolean;
function UnionFrom(qFrom: TMulQuery; const tableFrom,where: string; const ao: array of variant;
  var lr: longint; var auf: TUnionFrom; var lDone: boolean): boolean;
function DropTmpTblExt(db: TComponent): boolean;
procedure DropTmpFileExt;
procedure ModifyTable(Db: TComponent; lSetDbs: boolean; const ver: string;
  const tbl: string = ''; ProcMsg: TModifyTableMsgProc = nil; PrmMsg: pointer = nil); overload;
procedure ModifyTable(lSetDbs: boolean; const ver: string;
  const tbl: string = ''; ProcMsg: TModifyTableMsgProc = nil; PrmMsg: pointer = nil); overload;
function CreateTable(const tblDef: string; const tblCreate: string = '';
	lSetDbs: boolean = false; db: TComponent = nil): boolean; overload;
procedure DbInsCheck;
function IfThen(AValue: boolean; ATrue: TLockModeList): TLockModeOpt; overload;
function IfThen(AValue: boolean; ATrue: TCopyDBDBFList): TCopyDBDBFOpt; overload;
function IfThen(AValue: boolean; ATrue: TCopyTableList): TCopyTableOpt; overload;

implementation

{$R *.DFM}

uses Forms,ShellAPI,Math,ScktComp,RegStr,Variants,StrUtils,DateUtils,pFIBDatabase,pFIBProps,BDE,
  ChkGets,FPrivLst,SpinGet,Schem,FrmEdt,DirGet,FEdText,Shifr,ZLibEx,Inter,BtTxtGet,
    DBF,ER866,FldMask,DDProc,FGFBmp,FEdoUsLs;

const
	prvIs = '+';
	prvNo = ' ';

  trnsDlm  = ',';
	trnsDubl = '_';

  cDlmKey = ',';

  lDerNum = 6;

  pDerCapt  = 1;
  pDerDB    = 2;
  pDerFile  = 3;
  pDerTbl   = 4;
  pDerStr   = 5;
  pDerD1    = 6;
  pDerD2    = 7;
  pDerIP    = 8;
  pDerUN    = 9;
  pDerBuild = 10;
  pDerDo    = 11;

  pDerCnt   = 11;

  IBTypeDef = 'вводить для каждого';

  aSQLExecCapt: TSQLExecStr = ('Изменение','Добавление','Удаление');
  dlmSQLExec = ';';
  dlmSQLTbl = ','; ldlmSQLTbl = Length(dlmSQLTbl);

  cX = 5;
  cX2 = cX shl 1;
  cX8 = cX2 shl 2;
  cDlm = #31;

 	aDBType: array[TDBTypeList] of record
    f: string;
    g: TMenuGet;
  end = ((f:'Drv'),(f:'Als'));

	stType = 'Тип';
  stDrv  = 'Наименование';
  stPswd = '';

  bvPn  = 3;
  bvPn2 = bvPn shl 1;

  aIbpp: array[TInterbasePath] of string = ('локальное','удалённое','нестандартное');

  sectConnect = 'CONNECT';

  szBlock = 64*KByte;
  TmpTblExt = 'TMPTBL_';
  MaxUn = MByte;
  MaxDB = 10;

  fSQLTBL=sMemo+'SQLTBL';
  
  aIBType: array[TInterbaseType] of string = ('BDE','FIB-Plus');

var qTrns: TMulQuery;
	aUsSay,aUsGet: TArrStr;
  dbTo: TComponent;
  nCnt: longint = 0;
  oPrivProc: TPrivProc;
  lsProtFile: TStringList;
  afProtFile: array of record
    msg: string;
    cnt: byte;
  end;
  UsPrmControl: TControl;
  TypeGet: TRadioGet;
  DBPrmGet: TButGet;
  aDB: array[1..MaxDB] of TComponent;
  nDB: 0..MaxDB = 0;
  NoBDE: boolean;
{ $IFDEF OLDCNF
  CurConfig: TConfigStr;
{$ENDIF}

type
  TDerPrmList = 1..pDerCnt;

  TDerFile = record
    Name,Ext,Pref: TFileName;
    IsNum: boolean;
    Num: longint;
  end;

  TDerMemo = class(TTextMemo)
  protected
    class function AlwaysReadOnly: boolean; override;
  public
		constructor CreateParent(AOwner: TComponent; AParent: TWinControl); override;
  end;

  TServiceInfo = record
  	Name,Protocol: string;
    Port: longint;
  end;

  TSqlTblLogCompare = class(TStrListLogCompare)
  public
    class function ListCreate(pv: pointer; const Value: string; lNew: boolean): pointer; override;
    class procedure GetItem(var Prm: TLogTrnsValPrm; pv,lso,lsn: pointer; no,nn: longint; tp: TLogCompareItemList); override;
  end;

  ELoadFromServer = class(Exception);

  EModifyTableError = class(Exception);
  dbsrec = record
    vers,table_name,fld_name,fld_type,fld_align,fld_space,f_default:string;
    fld_size,fld_dec:longint;
    NotNull: boolean;
  end;
  TArrDbsRec = array of dbsrec;

  TCreateTableProc = procedure(var a: TArrDbsRec; Prm: pointer);

// Захват режима
function LockMode;
var s,w: string;
  i,ms: longword;
  fl: boolean;
  j: longint;
label lend;
begin
	AddStack('FrmPswd.LockMode');
  if lockmdNo in Opt then result:=true
  else with ProgPswd,PswdPrm,GetQuery do begin
    result := UserCnt<=1; if result then goto lend;
    result := nTrns>0; if result then goto lend;
  	s:=StrNum(nmFld+'=',flLock); w:=BrackNoEmp(where);
    if FSUAbort<>null then DlmBetwSelf(w,RegDt('DU')+'>'+SUAbort,sAND);
  	w:=IfThen(not empty(w),w+sAND)
    	+RegDt+'<>'+SDateReg
    	+IfThen(not empty(w) or (lockmdMono in Opt),sAND+'('
    	+IfThen(empty(w) and (lockmdMono in Opt),s,
      IfThen(not empty(w) and not(lockmdMono in Opt),w,
      s+sOR+'('+w+')'))+')');
    ms:=My_pr.GetTickCount;
    if MaxCnt<$FFFFFFFF then MaxCnt:=trunc(IntPower(10,MaxCnt));
    while not result do begin
      //Arg[sTABLE]:=tREGS;

      //s:=IntToStr(flLock)+'-'+IntToStr(trunc(DecExp(MaxCnt)))+'*('
      {s:=IntToStr(flLock)+'-'+IntToStr(trunc(IntPower(10,MaxCnt)))+'*('
        +GetPart(sSELECT_WHERE,[sTABLE,sC_LIST,sWHERE],
        [tREGS,sCOUNTZV,w])+')';
      PartSelect(tREGS,s);
      if Fields[0].AsInteger>0 then begin
        Arg[sV_LIST]:=Fields[0].AsInteger; Arg[sC_LIST]:=nmFld;}
      try
        i:=PartCount(tREGS,w);
      except
        on E: Exception do begin
          meserr(E.Message); raise
        end;
      end;
      if longword(flLock)>MaxCnt*i then begin
        UpdateTable('',[nmFld],[longint(longword(flLock)-MaxCnt*i)],RegDt+'='+SDateReg);
	      {PartSelect(tREGS,s);
        if Fields[0].AsInteger<=0 then begin}
        if longword(flLock)<=MaxCnt*longword(PartCount(tREGS,w))
        then UpdateTable('',[nmFld],[0],RegDt+'='+SDateReg);
      end;

      {Arg[sV_LIST]:=IntToStr(flLock)+'-'+IntToStr(trunc(DecExp(MaxCnt)))+'*('
        +GetPart(sSELECT_WHERE,[sC_LIST,sWHERE],[sCOUNTZV,w])+')';
      Arg[sC_LIST]:=nmFld; Arg[sWHERE]:=RegDt+'='+SDateReg;
      ExecPart(sUW_TABLE);}
      Arg[sWHERE]:=RegDt+'='+SDateReg; Arg[sC_LIST]:=nmFld;
      for j:=0 to LsUpdNm.Count-1 do if BoolObj(LsUpdNm,j) then AddArgList(sC_LIST,LsUpdNm[j]);
      SetPart(sSELECT_WHERE); Open;
      if not DoGetUpd(CurQuery) then goto lend;
      result := FieldZN(nmFld)<>0;
      if not result then begin
        if lockmdNoShow in Opt then break;
      	fl := Interval=0;
        if not fl then begin
        	Sleep(MSecsPerSec); fl := My_pr.GetTickCount-ms>Interval;
        end;
      	if fl then
          if not LockExec('Режим "'+NameMode+'" не установлен',ProgPswd,[lockReplF10],
          'Пользователи, не допускающие установку режима',w)
          then break;
      end;
    end;
lend:
    FreeQuery;
  end;
	DelStack;
end;

// Освобождение режима
procedure UnLockMode;
begin
	AddStack('FrmPswd.UnLockMode');
  with ProgPswd do if PswdPrm.nTrns=0 then UpdateTable(tREGS,[nmFld],[0],RegDt+'='+SDateReg);
  DelStack;
end;

// Захват режима администратора
function LockSuper(const msg: string = ''): boolean;
begin
	AddStack('FrmPswd.LockSuper');
	result:=not ProgPswd.NoLockSuper;
  if result then begin
    if ProgPswd.nSuper=0 then begin
      if Assigned(PswdPrm.DBMain) then
        if DBDrvCan('Transaction') then result:=ProgPswd.PswdPrm.SuperUser;
      if result then result:=LockMode('Администратор программы','FSUPER','',1,0)
      else meserr(IfThen(msg='','Эти действия может выполнить'+CRLF
        +'только администратор программы.',msg));
    end;
    if result then Inc(ProgPswd.nSuper);
  end
  else meserr('Запрещена установка режима администратора программы.');
  DelStack;
end;

function LockSuper(usl: boolean; const msg: string = ''): boolean;
begin
  if usl then result:=LockSuper(msg) else result:=true;
end;

// Освобождение режима администратора
procedure UnLockSuper;
begin
	AddStack('FrmPswd.UnLockSuper');
  Dec(ProgPswd.nSuper);
  if ProgPswd.nSuper=0 then UnLockMode('FSUPER');
  DelStack;
end;

// Захват монопольного режима
function LockMono;
var i: longint;
  ls: TMQFieldList;
  sWhereMono: string;
begin
	AddStack('FrmPswd.LockMono');
  ls:=GetFieldList(tREGS);
  if ls.IsField('FMONO') then begin
    if ProgPswd.nMono=0 then begin
      if sWhereMono='' then begin
        sWhereMono:=sOR+'FMONO>0';
        for i:=low(ProgPswd.aModeFld) to high(ProgPswd.aModeFld) do
          if ls.IsField(ProgPswd.aModeFld[i]) then IncD(sWhereMono,sOR+ProgPswd.aModeFld[i]+'>0');
      end;
      result:=LockMode(NameMode,'FMONO',Copy(sWhereMono,lOR1,MaxInt),1,0,[lockmdMono]);
    end
    else result:=true;
    if result then Inc(ProgPswd.nMono);
  end
  else result:=LockSuper;
	DelStack;
end;

// Освобождение монопольного режима
procedure UnLockMono;
begin
	AddStack('FrmPswd.UnLockMono');
	if IsField(tREGS,'FMONO') then begin
    Dec(ProgPswd.nMono);
    if ProgPswd.nMono=0
    then UnlockMode('FMONO');
  end
  else UnLockSuper;
  DelStack;
end;

function LockEdConf: boolean;
begin
	AddStack('FrmPswd.LockEdConf');
  result:=LockMode('Редактирование конфигурации','FEDCONF','FMONO>0'+sOR+'FEDCONF>0',1,0,
    IfThen(not((ProgPswd.nEdConf=0) and IsField(tREGS,'FEDCONF')),lockmdNo));
  if result then Inc(ProgPswd.nEdConf);
  DelStack;
end;

function LockEdConf(usl: boolean): boolean;
begin
  if usl then result:=LockEdConf else result:=true;
end;

procedure UnLockEdConf;
begin
	AddStack('FrmPswd.UnLockEdConf');
  if ProgPswd.nEdConf>0 then begin
    Dec(ProgPswd.nEdConf);
    if (ProgPswd.nEdConf=0) and IsField(tREGS,'FEDCONF') then UnlockMode('FEDCONF');
  end;
  DelStack;
end;

function FLockSuper;
begin
	AddStack('FrmPswd.FLockSuper');
	result:=LockSuper;
  DelStack;
end;

function FLockMono;
begin
	AddStack('FrmPswd.FLockMono');
	result:=LockMono;
  DelStack;
end;

function FLockEdConf;
begin
	AddStack('FrmPswd.FLockEdConf');
	result:=LockEdConf;
  DelStack;
end;

procedure ProtocolStrAdd(const FileName: variant; const s: string;
  Opt: TProtocolAddOpt = []; paTbl: PArrStr = nil); overload;
const MaxCntMsg = 10;
var ost,f,l,l1,p: longint;
  fn,s1,s2,sErr: string;
  a: TArrStr;
begin
  ost:=AddStack('FrmPswd.ProtocolStrAdd');
  if ProtocolActive then begin
    ProtocolActive:=false;
    try
      if s='' then s1:=''
      else begin
        try
          s1:=FormatDateTime('dd/mm/yyyy tt',NowDouble);
        except
          SetStack(ost);
          s1:='[ОШИБКА ОПРЕДЕЛЕНИЯ ВРЕМЕНИ]';
        end;
        IncL(s1,CRLF+'<<< ',' >>>'+CRLF);
        if Assigned(ProgPswd) then begin
          try
            s2:=Format('[%d]',[ProgPswd.PswdPrm.UserNum])
          except
            SetStack(ost);
            s2:='[ОШИБКА ОПРЕДЕЛЕНИЯ НОМЕРА ПОЛЬЗОВАТЕЛЯ]';
          end;
          if Assigned(paTbl) then IncD(s2,'['+ArrayAsList(paTbl^,',')+']');
          if protNoDo in Opt then IncD(s2,'[-]');
          IncD(s1,s2+CRLF);
        end;
        IncD(s1,s);
        if protStack in Opt then begin
          GetStack(a); s2:='';
          for l:=high(a)-1 downto low(a) do IncD(s2,','+StrTran(a[l],CRLF,' '));
          IncD(s1,CRLF+Copy(s2,2,MaxInt));
        end;
      end;
      if MyVarType(FileName)=varString then fn:=FileName else fn:=aProtFile[TProtocolFileList(FileName),1];
      FullNameExeSelf(fn,aProtFileExt[0]);
      if not Assigned(lsProtFile) then begin
        lsProtFile:=SortStrListCreate;
        if Length(afProtFile)=0 then SetLength(afProtFile,1);
      end;
      if not IntObjFindAdd(lsProtFile,fn,p) then begin
        if Length(afProtFile)=p then SetLength(afProtFile,p shl 1);
        afProtFile[p].msg:=''; afProtFile[p].cnt:=0;
      end;
      IncL(s1,afProtFile[p].msg);
      if s1<>'' then begin
        if FileExists(fn) then begin
          sErr:='Ошибка открытия файла протокола'; f:=FileBufOpen(fn,fmOpenWrite or fmShareDenyNone);
        end
        else begin
          sErr:='Ошибка создания файла протокола'; f:=FileBufCreate(fn);
        end;
        try
          if f=-1 then l:=0
          else begin
            l1:=Length(s1); l:=FileSeek(f,0,soFromEnd)+l1;
            sErr:=IfThen(FileWrite(f,pointer(s1)^,l1)<>l1,
              Format('Ошибка записи (%d байт) в файл протокола',[l1]));
          end;
        finally
          FileClose(f);
        end;
        if sErr='' then begin
          afProtFile[p].msg:=''; afProtFile[p].cnt:=0; MsgProtSave(l,fn);
        end
        else if (afProtFile[p].cnt<MaxCntMsg) or (s='') then begin
          Inc(afProtFile[p].cnt);
          if (afProtFile[p].cnt=MaxCntMsg) or (s='') then begin
            afProtFile[p].msg:=''; 
            try
              s1:=SysErrorMessage(GetLastError);
            except
              SetStack(ost);
              s1:='[ОШИБКА ОПРЕДЕЛЕНИЯ ТЕКСТА СИСТЕМНОГО СООБЩЕНИЯ ОБ ОШИБКЕ]';
            end;
            IncD(sErr,':'+CRLF+fn+CRLF+s1); OutStack(sErr); MsgDlg(sErr);
          end
          else afProtFile[p].msg:=s1;
        end;
      end;
    finally
      ProtocolActive:=true;
    end;
  end;
  DelStack;
end;

procedure ProtSQLStrAdd(const s: string; lStack: boolean = false);
begin
  ProtocolStrAdd(protSQL,s,IfThen(lStack,protStack));
end;

function IsUsPrm(const cName,Index: string; var nm: string; var lSeek: boolean): boolean;
begin
  AddStack('FrmPswd.IsUsPrm');
  with ProgPswd,RUsPrm do begin
    nm:=ReplVar(cName,UserName); result:=not(empty(nm) or empty(Index)) and Active;
    if result then lSeek:=Seek(TblFldName(fUSERNAME)+'='+QQs(nm)+sAND+TblFldName(fNAME)+'='+QQs(Index));
  end;
  DelStack;
end;

function GetUsPrm(const Index: string; const cName: string = ''): string;
var nm: string;
  lSeek: boolean;
begin
  AddStack('FrmPswd.GetUsPrm');
  result:='';
  if IsUsPrm(cName,Index,nm,lSeek) then if lSeek then result:=ProgPswd.RUsPrm[fUSPRM];
  DelStack;
end;

procedure SetUsPrm(Sender: TControl; const Index,Val: string; const cName: string = '');
var nm: string;
  lSeek: boolean;
begin
  AddStack('FrmPswd.SetUsPrm');
  if IsUsPrm(cName,Index,nm,lSeek) then with ProgPswd,RUsPrm do begin
    if not lSeek then begin
      NewRec; Value[fUSERNAME]:=nm; Value[fNAME]:=Index;
    end;
    Value[fUSPRM]:=Val; UsPrmControl:=Sender;
    try
      LogVid:=logvEditRec;
      if Recno>0 then
        if empty(Val) then begin
          CngLogVid(logvDelRec); DelRec('',[delLog]);
        end
        else UpdateRec(true)
      else if not empty(Val) then begin
        CngLogVid(logvAppRec); AppRec(true);
      end;
      LogVid:=logvNone;
    finally
      UsPrmControl:=nil;
    end;
  end;
  DelStack;
end;

function GetLogVid: longint;
begin
  AddStack('FrmPswd.GetLogVid');
  if Assigned(ProgPswd) then result:=ProgPswd.LogVid else result:=logvNone;
  DelStack;
end;

procedure SetLogVid(Value: longint);
begin
  AddStack('FrmPswd.SetLogVid');
  if Assigned(ProgPswd) then ProgPswd.LogVid:=Value;
  DelStack;
end;

function CngLogVid(Value: longint; OnlyCng: boolean = false): longint;
begin
  AddStack('FrmPswd.CngLogVid');
  if Assigned(ProgPswd) then result:=ProgPswd.CngLogVid(Value,OnlyCng) else result:=logvNone;
  DelStack;
end;

function PswdPrm: PPswdPrm;
begin
  if Assigned(ProgPswd) then result:=@ProgPswd.PswdPrm else result:=nil;
end;

function LogActive: boolean;
begin
  if Assigned(ProgPswd) then result := ProgPswd.LogVid<>logvNone else result:=false;
end;

procedure LogWrite(const tbl: string = ''; const prim: string = '');
begin
  if Assigned(ProgPswd) then ProgPswd.LogWrite(tbl,prim);
end;

function GetQuery(Connection: TComponent = nil): TMulQuery;
begin
  if Assigned(ProgPswd) then result:=ProgPswd.GetQuery(Connection) else result:=nil;
end;

function GetQueryIf(lIf: boolean): TMulQuery;
begin
  result:=ProgPswd.GetQuery(lIf);
end;

function CurQuery: TMulQuery;
begin
  result:=ProgPswd.CurQuery;
end;

procedure FreeQuery;
begin
  ProgPswd.FreeQuery;
end;

procedure FreeQueryIf(q: TMulQuery);
begin
  ProgPswd.FreeQuery(q);
end;

// Попытка начать транзакцию
procedure StTrnsStart(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i,lr: longint;
	aTable: PArrStr;
begin
	AddStack('FrmPswd.StTrnsStart');
  aTable:=PointerVar(Params[1]); lr:=Params[2];
  for i:=0 to lr-1 do begin
    Sender.SayStat('',aTable^[i],(i+1)/lr);
    CreateTable(aTable^[i],aTable^[i]+trnsDubl,Params[0]);
    InsFromTable(aTable^[i],aTable^[i]+trnsDubl);
  end;
  DelStack;
end;

function TrnsStart(const aTable: array of string; flLock: longint = 0;
	ProcLock: TProcLock = nil; lSetDBS: boolean = false): boolean;
var fl,CanTrns: boolean;
  at: TArrStr;
	j: longint;
	function Tbl1(const table: string): boolean;
  var tbl: string;
  begin
  	AddStack('FrmPswd.TrnsStart.Tbl1');
    tbl:=TrimUpper(table); result:=not IgnoreSlFindAdd(ProgPswd.lsTblTrns,tbl);
    if result then begin
      if not CanTrns then begin
      	at[j]:=tbl; Inc(j);
      end;
      fl:=true;
    end;
    DelStack;
  end;
var isTbl: boolean;
  isMemo: TFldMemoAttrSet;
  fa: TFldMemoAttr;
	i,k: longint;
  s: string;
  ls: TStringList;
  ibdb: TIBDatabase;
begin
	AddStack('FrmPswd.TrnsStart');
  result := not ProgPswd.PswdPrm.NoTrnsStart;
  if result then begin
    result := flLock=0; CanTrns:=DBDrvCan('Transaction'); isTbl := IfThen(aTable)<>'';
    if not result then begin
      if not CanTrns and isTbl then ProcLock:=FLockSuper;
      result := not Assigned(ProcLock);
      if not result then result:=ProcLock(flLock);
    end;
    if result then begin
      if ProgPswd.PswdPrm.nTrns=0 then ProgPswd.PswdPrm.aqTrns:=nil;
      Inc(ProgPswd.PswdPrm.nTrns);
      if CanTrns or isTbl then begin
        fl:=false; SetLength(at,Length(aTable)+1); j:=0; isMemo:=[];
        if isTbl then for i:=low(aTable) to high(aTable) do if Tbl1(aTable[i]) then begin
          ls:=GetFieldList(aTable[i]);
          for fa:=low(aMemo) to high(aMemo) do if not(fa in isMemo) then begin
            ls.Find(aBegMem[fa],k);
            if k<ls.Count then if AnsiStartsText(aBegMem[fa],ls[k]) then Include(isMemo,fa);
          end;
        end;
        for fa:=low(aMemo) to high(aMemo) do if fa in isMemo then Tbl1(aMemoTbl[fa]);
        ShowStat('Сохранение данных',StTrnsStart,[lSetDbs,LongInt(@at),j],j,false);
        if CanTrns then begin
          fl := ProgPswd.PswdPrm.nTrns=1;
          if fl then
            if IsClass(PswdPrm.DBMain,TIBDatabase,pointer(ibdb))
            then ibdb.DefaultTransaction.StartTransaction
            else TDatabase(PswdPrm.DBMain).StartTransaction;
        end
        else if fl then begin
          s:='';
          for i:=0 to ProgPswd.lsTblTrns.Count-1 do IncD(s,trnsDlm+ProgPswd.lsTblTrns[i]);
          with ProgPswd.RG do begin
            OpenRec; Value['TRNS']:=Copy(s,Length(trnsDlm)+1,MaxInt); UpdateRec; CloseRec;
          end;
          TMulQuery.CreateConnection(qTrns,Application.MainForm,nil); qTrns.DBFlush;
        end;
        if fl then ProtSQLStrAdd('START TRANSACTION',true);
      end;
    end;
  end
  else meserr('Запрещён режим транзакции.');
  DelStack;
end;

// Закончить транзакцию
procedure StTrnsEnd(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i,j: longint;
  lsi: TStringList;
  a: array[1..2] of string;
  fl,isind: boolean;
begin
	AddStack('FrmPswd.StTrnsEnd');
  fl:=false; isind:=false; lsi:=TStringList.Create;
  with ProgPswd,PswdPrm,GetQuery do
    try
      for i:=0 to ls.Count-1 do begin
        Sender.SayStat('',ls[i],(i+1)/ls.Count); lsi.Clear;
        with TMQIndexList.Create(DBMain,ls[i]) do
          try
            for j:=0 to Count-1 do begin
              if not isind then begin
                RG.OpenRec; RG['WASCOPY']:=bTrue; RG.UpdateRec; isind:=true;
              end;
              lsi.Add(Strings[j]+UnDelim+ArrayAsList(Indices(j),','));
            end;
          finally
            Free;
          end;
        DBFlush; CreateTable(ls[i],'',Params[0]); InsFromTable(ls[i]+trnsDubl,ls[i]);
        if lsi.Count>0 then begin
          Arg[sTABLE]:=ls[i];
          for j:=0 to lsi.Count-1 do begin
            ListAsArray(lsi[j],a,UnDelim); Arg['index']:=a[1]; Arg[sC_LIST]:=a[2];
            if not ExecPart('c_index',true) then begin
              fl:=true; break;
            end;
          end;
          if fl then break;
        end;
      end;
      if fl then begin
        if Ask(['Сортировка данных была прервана.','Необходима перезагрузка программы.',
          'Выполнить перезагрузку сейчас ?']) then Restart([]);
      end
      else if isind then begin
        RG['WASCOPY']:=bFalse; RG.UpdateRec;
      end;
    finally
      lsi.Free; FreeQuery;
    end;
  DelStack;
end;

procedure TrnsEnd(Opt: TTrnsEndOpt = []; ProcUnLock: TProcNone = nil); overload;
var i: longint;
  s: string;
  ibdb: TIBDatabase;
begin
	AddStack('FrmPswd.TrnsEnd');
  with ProgPswd.PswdPrm do if not NoTrnsStart then begin
    if nTrns>0 then begin
      Dec(nTrns);
      if nTrns=0 then begin
        ProgPswd.DBTrnsFree;
        if DBDrvCan('Transaction') then begin
          if IsClass(DBMain,TIBDatabase,pointer(ibdb)) then
            if trnsCommit in Opt then ibdb.CommitRetaining else ibdb.RollbackRetaining
          else with TDatabase(DBMain) do
            if trnsCommit in Opt then Commit else RollBack;
        end
        else with ProgPswd.GetQuery do begin
          ProgPswd.ls.Clear; Close; PartSelect(tGLOBSET,'TRNS'); s:=TrimRight(Fields[0].AsString);
          if not Empty(s) then begin
            LsArrList(s,ProgPswd.ls,trnsDlm);
            if not(trnsCommit in Opt) then ShowStat('Восстановление данных',
              StTrnsEnd,[trnsSetDBS in Opt],ProgPswd.ls.Count,false);
            UpdateTable(tGLOBSET,['TRNS'],[QQs]); DBFlush; Close;
          end;
          for i:=0 to ProgPswd.ls.Count-1 do DropTable(ProgPswd.ls[i]+trnsDubl);
          if ProgPswd.ls.Count>0 then ProcUnlock:=UnlockSuper;
          ProgPswd.FreeQuery;
        end;
        ProgPswd.LsTblTrns.Clear;
        if Length(aqTrns)>0 then begin
          if trnsCommit in Opt then with ProgPswd.GetQuery do begin
            for i:=low(aqTrns) to high(aqTrns) do begin
              MulPar.Text:=aqTrns[i,2]; ExecPart(aqTrns[i,1]);
            end;
            ProgPswd.FreeQuery;
          end;
          aqTrns:=nil;
        end;
        ProtSQLStrAdd(IfThen(trnsCommit in Opt,'END TRANSACTION','ROLLBACK'),true);
      end;
    end;
    if Assigned(ProcUnlock) then ProcUnlock;
  end;
  DelStack;
end;

procedure TrnsEndWnd(Sender: TStat; ProcUnLock: TProcNone = nil);
begin
  TrnsEnd(IfThen(not Sender.Aborted,trnsCommit));
end;

procedure TrnsEndWnd(Sender: TAsk; ProcUnLock: TProcNone = nil);
begin
  TrnsEnd(IfThen(not Sender.Aborted,trnsCommit));
end;

procedure TrnsEndSuper;
begin
  TrnsEnd(IfThen(not lRollBack,trnsCommit),UnLockSuper);
end;

procedure TrnsEndMono;
begin
  TrnsEnd(IfThen(not lRollBack,trnsCommit),UnLockMono);
end;

procedure TrnsEndEdConf;
begin
  TrnsEnd(IfThen(not lRollBack,trnsCommit),UnLockEdConf);
end;

procedure ViewUserInfo;
var j: longint;
  s,sn,DriverName: string;
  aSay,aGet: TArrStr;
  de: TDefEdit;
  lIB: boolean;
begin
  AddStack('FrmPswd.ViewUserInfo');
  if Length(aUsGet)=0 then begin
    AddFrom(aUsSay,['Рабочая папка','',UnDelim]);
    AddFrom(aUsGet,[ExeDir         ,'','ОСНОВНЫЕ ДАННЫЕ:']);
    DriverName:=GetDBDriverName(PswdPrm.DBMain);
    if DriverName='' then begin
      AddFrom(aUsSay,'Псевдоним');
      AddFrom(aUsGet,GetDBAliasName(PswdPrm.DBMain));
    end
    else begin
      AddFrom(aUsSay,'Драйвер');
      AddFrom(aUsGet,DriverName);
      lIB := PswdPrm.DBMain is TIBDatabase;
      if lIB then begin
        AddFrom(aUsSay,'База данных');
        AddFrom(aUsGet,[GetDBName]);
      end;
      TSQLDM.Load;
      if TDefEdit.Find(DriverName,de) then with GetDBParams,de do for j:=0 to Count-1 do begin
        if StrToBoolean(Param[j,deNewPage]) then break;
{ $IFDEF OLDCNF
        if de=SQLDM.deMySQL then
          if (Param[j,deNameRecFld]='IP_ADR')
          and not TDBPrmGet.IsClientOnly(TDBPrmGet.ReadConfig) then continue;
{$ENDIF}
        sn:=Names[j];
        if lIB then StrTranSelf(sn,'_',' ');
        s:=Param[sn,deCaption];
        if s<>'' then begin
          AddFrom(aUsSay,s);
          if lIB then
            if sn=ibpServerName then s:=GetDBName else s:=Values[Names[j]]
          else s:=Values[sn];
          AddFrom(aUsGet,s);
        end;
      end;
    end;
  end;
  CopyFrom(aSay,[UnDelim,'Имя'            ]); AddFrom(aSay,aUsSay);
  CopyFrom(aGet,[''     ,ProgPswd.UserName]); AddFrom(aGet,aUsGet);
  DefEditInfo('О пользователе','AboutUser',aSay,aGet);
  DelStack;
end;

function TblSQLTimeOffs: Double;
var ost: longint;
begin
  ost:=AddStack('FrmPswd.TblSQLTimeOffs');
  result:=0;
  if Assigned(ProgPswd) then with ProgPswd do begin
    if not Assigned(FTblSQLTimeOffs) and Connected then with GetQuery do begin
      Arg[sC_LIST]:=SQLDateTime(Now);
      if not empty(SetPart('getnow')) then begin
        try
          Open; New(FTblSQLTimeOffs); FTblSQLTimeOffs^:=Fields[0].AsFloat;
        except
          on EDatabaseError do SetStack(ost);
        end;
      end;
      FreeQuery;
    end;
    if Assigned(FTblSQLTimeOffs) then result:=-FTblSQLTimeOffs^;
  end;
  DelStack;
end;

function NowDouble;
begin
  AddStack('FrmPswd.NowDouble');
  result:=mround(Now+TblSQLTimeOffs,FloatMaxDec);
  DelStack;
end;

function sqltype(const dbs: dbsrec; mq: Tmulquery; BoolAsStr: boolean = true):string;
begin
	AddStack('FrmPswd.sqltype');
	mq.arg['len']:=dbs.fld_size;
	mq.arg['dec']:=dbs.fld_dec;
	case StrToChar(dbs.fld_type) of
		'S','C': result:=mq.setpart('CHAR');
		'V': result:=mq.setpart('VCHAR');
		'D': result:=mq.setpart('DATE');
		'B','L': if BoolAsStr then begin
    	mq.arg['len']:=1; result:=mq.setpart('CHAR');
    end
    else result:=mq.setpart('BOOL');
		'N': result:=mq.setpart('NUMERIC');
		'F': result:=mq.setpart('DOUBLE');
		'I': result:=mq.setpart('INT');
		'O': result:=mq.setpart('BLOB');
  else result:='';
	end;
  if (result<>'') and dbs.NotNull then DlmBetwSelf(result,mq.SetPart('notnull'),' ');
  DelStack;
end;

{копирование таблицы в таблицу SQL }
function DataFile(const a: array of TCustomDataFile): TCustomDataFile;
var i: byte;
begin
  {$IFDEF STACKALL}AddStack('FrmPswd.DataFile');{$ENDIF}
  result:=nil;
  for i:=low(a) to high(a) do
    if Assigned(a[i]) then begin
      result:=a[i]; break;
    end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure qFromOpen(qFrom: TMulQuery; const c_list: array of variant; const where,o_list: string;
  var lr: longint);
begin
  AddStack('FrmPswd.qFromOpen');
  qFrom.PartSelect('',c_list,where,o_list,'',false);
  //qFrom.UniDirectional:=true;
  try
    qFrom.Opentry;
  except
    on EDatabaseError do begin
      qFrom.PartSelect('',[],where,'','',false);
      try
        qFrom.Opentry;
      except
        on E:EDatabaseError do raise ECopyTableError.Create(
          'Исходная таблица '+qFrom.Arg[sTABLE]+' не существует'+CRLF+E.Message);
      end;
    end;
  end;
  if lr<0 then lr:=qFrom.RecordCount;
  qFrom.first;
  DelStack;
end;

procedure StUnionFrom(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var auf: PUnionFrom;
  luf: longint;
  procedure ufAdd(const where: string; lr: longint);
  begin
    AddStack('FrmPswd.StUnionFrom.ufAdd');
    if lr>0 then begin
      if Length(auf^)=luf then SetLength(auf^,luf shl 1);
      auf^[luf].where:=where; auf^[luf].lr:=lr; Inc(luf);
    end;
    DelStack;
  end;
var qFrom: TMulQuery;
  fuf,w,s: string;
  lr,lr0,l,r,r1,r2: longint;
label lend;
begin
  AddStack('FrmPswd.StUnionFrom');
  qFrom:=PointerVar(Params[0]); fuf:=Params[1]; w:=Params[2]; auf:=PointerVar(Params[3]); lr:=Params[4];
  lr0:=lr;
  if Sender.SayStat('','Определение количества уникальных номеров') then goto lend;
  r1:=0; r2:=qFrom.PartMaxInt('',fuf,w); SetLength(auf^,2); luf:=0;
  repeat
    r:=r2-r1; s:=Format('Распределено уникальных номеров: %d из %d',[lr0-lr,lr0]);
    repeat
      r := r shr 1;
      if Sender.SayStat('',s,(lr0-lr)/lr) then goto lend;
      l:=qFrom.PartCount('',DlmBetween([w,IfThen(luf>0,fuf+'>'+Vtos(r1)),
        fuf+'<='+Vtos(r1+r)],sAND));
    until l<=MaxUn;
    ufAdd(qFrom.Arg[sWHERE],l); Dec(lr,l); Inc(r1,r);
    if lr<=MaxUn then begin
      ufAdd(DlmBetween(w,fuf+'>'+Vtos(r1),sAND),lr); break;
    end;
  until false;
lend:
  SetLength(auf^,luf);
  DelStack;
end;

procedure StCopyTable(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var dFrom: TCustomDataFile;
  v: variant;
	FieldName: string;
  ValueProc: TCopyTableValueProc;
	procedure vSet(const cv: variant);
  begin
    {$IFDEF STACKALL}AddStack('FrmPswd.StCopyTable.vSet');{$ENDIF}
    v:=UnAssigned; // Для W'98
    CopyTableValueProc(ValueProc,dFrom,FieldName,cv,v);
    {$IFDEF STACKALL}DelStack;{$ENDIF}
  end;
var qTo: TMulQuery;
  lsTo: TMQFieldList;
  procedure qToSet;
  var i: longint;
  begin
    AddStack('FrmPswd.StCopyTable.qToSet');
    qTo.Arg[sC_LIST]:=''; qTo.Arg[sV_LIST]:='';
    for i:=0 to lsTo.Count-1 do begin
      qTo.AddArgList(sC_LIST,lsTo[i]); qTo.AddArgList(sV_LIST,StrNum(':V',i));
    end;
    qTo.SetPart(sI_TABLE); qTo.Prepare;
    DelStack;
  end;
var tTo: TDatabaseText;
  rTo: TDbf;
  dTo: TCustomDataFile;
  RecProc: TCopyTableRecProc;
  function RecPr(lAfter: boolean): boolean;
  begin
    {$IFDEF STACKALL}AddStack('FrmPswd.StCopyTable.RecPr');{$ENDIF}
    result:=true;
    if Assigned(RecProc) then RecProc(dFrom,dTo,lAfter,result);
    {$IFDEF STACKALL}DelStack;{$ENDIF}
  end;
var lRequestLive,lExtTo: boolean;
  lFrom: longint;
  af: array of record
  	fFrom,fTo: TField;
    nFrom,nTo: longint;
  end;
  a0: array of record
  	f: TField;
    nTo: longint;
    nmf: string;
    v: variant;
  end;
  procedure fSet;
  var i,j,nTo: longint;
  	fFrom,fTo: TField;
  begin
    AddStack('FrmPswd.StCopyTable.fSet');
    j:=0;
    for i:=0 to lFrom-1 do begin
      if dFrom is TMulQuery then fFrom:=TMulQuery(dFrom).fields[i] else fFrom:=nil;
      FieldName:=dFrom.FieldName(i); fTo:=nil; nTo:=-1;
      if TrimUpper(FieldName)='INDEX' then IncD(FieldName,'_');
      if Assigned(tTo) then nTo:=tTo.FieldIndex(FieldName)
      else if Assigned(rTo) then nTo:=rTo.FieldPos(FieldName)
      else if lExtTo or not lRequestLive then nTo:=lsTo.IndexOf(FieldName)
      else if lRequestLive then fTo:=qTo.FindField(FieldName);
      if (nTo>=0) or Assigned(fTo) then begin
        af[j].fFrom:=fFrom; af[j].fTo:=fTo; af[j].nFrom:=i; af[j].nTo:=nTo; Inc(j);
      end;
    end;
    SetLength(af,j); j:=0;
    if Assigned(qTo) and not lExtTo then begin
      SetLength(a0,lsTo.Count);
      for i:=0 to lsTo.Count-1 do begin
        FieldName:=lsTo[i];
        fTo:=qTo.FindField(lRequestLive,FieldName);
        if TrimUpper(FieldName)='INDEX_' then FieldName:='INDEX';
        if not dFrom.IsField(FieldName) then with a0[j] do begin
          f:=fTo; nmf:=lsTo[i]; nTo:=i;
          case lsTo.Fields(i).DataType of
            ftString: v:=' ';
            ftInteger,ftFloat: v:=0;
            ftBoolean: v:=false;
            ftDate: v:=DateEmpty;
          else continue;
          end;
          Inc(j);
        end;
      end;
    end;
    SetLength(a0,j);
    DelStack;
  end;
  procedure qDop(Sender: TCustomDataFile; var q: TMulQuery);
  begin
  	AddStack('FrmPswd.StCopyTable.qDop');
    if IsClass(Sender,TMulQuery,pointer(q))
    then q:=TMulQuery.CreateConnection(Application.Mainform,q.Connection);
    DelStack;
  end;
const MaxRequestLive = 500000;
var ost,i,j,l,l1,lr,onTrns,nuf,luf:longint;
  CanClrRequestLive: boolean;
  tp: TFieldType;
  fs: longint;
  s,s0,s1,ExtFile,sord: string;
  an: TArrInt;
  d: Double;
  DtBeg: TDateTime;
  flTrans: TTableTrans;
  ss: TStringStream;
  pnt: Pointer;
  blobTo: boolean;
  qFrom1,qTo1: TMulQuery;
  ibq: TIBQuery;
  lsm: TMemGkList;
  auf: PUnionFrom;
  ac: PArrVar;
begin
	ost:=AddStack('FrmPswd.StCopyTable');
  try
    lr:=Params[0];
    dFrom:=PointerVar(Params[1]);
    qTo:=PointerVar(Params[2]);
    tTo:=PointerVar(Params[3]);
    rTo:=PointerVar(Params[4]);
    ValueProc:=PointerVar(Params[5]);
    lExtTo:=Params[6];
    lsTo:=PointerVar(Params[7]);
    ExtFile:=Params[8];
    RecProc:=PointerVar(Params[9]);
    flTrans:=TTableTrans(Params[10]);
    pnt:=PointerVar(Params[11]);
    blobTo:=Params[12];
    auf:=PointerVar(Params[13]);
    ac:=PointerVar(Params[14]);
    sord:=Params[15];
    ss:=nil; lsm:=nil;
    try
      dTo:=DataFile([qTo,tTo,rTo]); qDop(dFrom,qFrom1); qDop(dTo,qTo1);
      lFrom:=dFrom.FieldCount; CanClrRequestLive:=true;
      for i:=0 to lFrom-1 do
        if dFrom.DataType(i) in [ftBlob,ftMemo] then begin
          CanClrRequestLive:=false; break;
        end;

      //lRequestLive:=not empty(qTo.SetPart('blob'));
      //lRequestLive:=true;
      lRequestLive:=not CanClrRequestLive;
      if not lRequestLive and Assigned(qTo) then lRequestLive:=not IsSQLBased(qTo.Connection);
      //lRequestLive:=not CanClrRequestLive or (lr<MaxRequestLive);
      //Sender.SayStat(bStr[lRequestLive],'',0);

      if Assigned(qTo) and not lExtTo then
        if lRequestLive then begin
          //if dFrom is TMulQuery then s:=TMulQuery(dFrom).Arg[sO_LIST] else
          s:='';
          qTo.PartSelect('',[],'',s,'',false);
          //qTo.PartSelect('',[],lsTo[0]+sISNULL,'','',false);
          qTo.RequestLive:=true;
          if not empty(s) then qTo.BufferChunks:=10000;
          qTo.Open;
        end
        else qToSet;
      SetLength(af,lFrom); fSet; fs:=-1; l:=0; DtBeg:=0;
      if lExtTo then begin
        DtBeg:=EncodeDate(1858,11,17); SetLength(an,lsTo.Count); j:=0;
        for i:=0 to lsTo.Count-1 do with lsTo.Fields(i)^ do begin
          if (DataType<>ftString) and (j>0) then begin
            Inc(l,Ceil(j/4)*4-j); j:=0;
          end;
          an[i]:=l;
          case DataType of
            ftInteger: l1:=SizeOfVar[stInteger];
            ftFloat,ftDate: l1:=SizeOfVar[stDouble];
          else
            l1:=Size; Inc(j,l1);
          end;
          Inc(l,l1);
        end;
        SetLength(s,l); SetLength(s0,l); ZeroMemory(pointer(s0),l);
        for i:=0 to lsTo.Count-1 do with lsTo.Fields(i)^ do
          if DataType=ftString then
            if not dFrom.IsField(lsTo[i]) then begin
              l1:=Size; s1:=Space(l1); CopyMemory(PointerStr(s0,an[i]),pointer(s1),l1);
            end;
        fs:=FileBufCreate(ExtFile);
      end;
      try
        nuf:=0; luf:=Length(auf^);
        repeat
          j:=1;
          if Assigned(qTo) and (qTo.DataSet is TIBQuery) and not lExtTo and not lRequestLive and not Assigned(RecProc) and (flTrans=ttNone) and (Length(a0)=0) and not Assigned(ValueProc) then begin
            if Assigned(ProgPswd) then with ProgPswd,PswdPrm do begin
              onTrns:=nTrns; Inc(nTrns);
            end
            else onTrns:=-1;
            try
              ibq:=pointer(qTo.DataSet);
              if onTrns=0 then ibq.Transaction.StartTransaction;
              try
                while not dFrom.Eof do begin
                  {if (qTo.Arg[sTABLE]='DDAT') and (j=544) then begin
                    j:=j;
                  end;}
                  if j mod 100=0 then
                    if Sender.SayStat(j/lr) then break;
                  for i:=low(af) to high(af) do with af[i] do begin
                    v:=dFrom.ValueNum(nFrom);
                    if dFrom.DataType(nFrom)=ftBoolean then bStrSelf(v);
                    ibq.Params[nTo].Value:=v;
                  end;
                  qTo.ExecSQL; dFrom.next; Inc(j);
                end;
                if onTrns=0 then ibq.Transaction.CommitRetaining;
              except
                {on EAccessViolation do begin
                  meserr(j);
                end;}
                on EDatabaseError do begin
                  if onTrns=0 then ibq.Transaction.RollbackRetaining;
                  raise
                end;
              end;
            finally
              if Assigned(ProgPswd) then ProgPswd.PswdPrm.nTrns:=onTrns;
            end;
          end
          else while not dFrom.Eof do begin
            if RecPr(false) then begin
              if Assigned(qTo) and not lExtTo and lRequestLive then begin
                {if j mod 100000 = 0 then begin
                  qTo.Post;
                  qTo.Close;
                  qTo.Open;
                  fSet;
                end;}
                if (j=MaxRequestLive) and CanClrRequestLive then begin
                  qTo.Post; qTo.Close; qTo.RequestLive:=false;
                  lRequestLive:=false; qToSet; fSet;
                end;
                if lRequestLive then begin
                  qTo.Append;
                  qTo.Edit;
                end;
              end;
              {if (tTo.TableName='DDAT') then if dFrom.ValueName('ZN')='ваыовыаовдыэа ждэваож дэыважо дэыважо дывэажо ывдэаож вдыаэож ываэож ывдаэожыв адэоывж дэыовжа дэывжа дываэож ываэж ывдаэож ывдаэо жывадо эывжад оыэважо дыэважо ыдвэажывдаэ жывадоэ ыжвадо эывжаод эыважо дыэваж одывэаж'+' оывдэа ожывдаэо жывдаэо жывад эоыжва доэыважо дэываждыэважодывэаожыдваэ1' then begin
                j:=j;
              end;}
              if j mod 100=0 then
                if Sender.SayStat(j/lr) then break;
              if Assigned(tTo) then tTo.Add
              else begin
                if Assigned(rTo) then rTo.Append;
                if lExtTo then CopyMemory(pointer(s),pointer(s0),l);
                for i:=low(af) to high(af) do with af[i] do begin
                  FieldName:=dFrom.FieldName(nFrom);
                  if lExtTo then tp:=lsTo.Fields(nTo).DataType else tp:=UnDataType(dFrom.DataType(nFrom));
                  case tp of
                    ftString: begin
                      s1:=TrimRight(IsNilc(dFrom.ValueNum(nFrom),''));
                      if lExtTo then
                        if UnDataType(fFrom)=ftBoolean then s1:=bStr[fFrom.AsBoolean];
                      if s1<>'' then case flTrans of
                        ttWinToDos: WinToDosSelf(s1);
                        ttDosToWin: DosToWinSelf(s1);
                      end;
                      vSet(s1);
                      if lExtTo then begin
                        l1:=lsTo.Fields(nTo).Size; s1:=Padr(v,l1);
                        CopyMemory(PointerStr(s,an[nTo]),pointer(s1),l1);
                      end
                      else if Assigned(rTo) then rTo[nTo]:=v
                      else if lRequestLive then fTo.AsString:=IfThen(v='',' ',v);
                    end;
                    ftInteger: begin
                      vSet(IsNilc(dFrom.ValueNum(nFrom),0));
                      if lExtTo then begin
                        l1:=v; CopyMemory(PointerStr(s,an[nTo]),@l1,SizeOfVar[stInteger]);
                      end
                      else if Assigned(rTo) then rTo[nTo]:=v
                      else if lRequestLive then
                        if fTo.DataType in [ftBlob,ftMemo] then begin
                          if not Assigned(lsm) then lsm:=TMemGkList.Create(TMulQuery(dFrom),qFrom1,nil,false);
                          StringStreamCreate(ss).WriteString(lsm.GetValue(v));
                          ss.Seek(0,soBeginning);
                          TBlobField(fTo).LoadFromStream(ss);
                          AddFrom(PArrStr(pnt)^,VTos(v));
                        end
                        else fTo.AsInteger:=v;
                    end;
                    ftBoolean: begin
                      vSet(IsNilc(dFrom.ValueNum(nFrom),false));
                      if lExtTo then begin
                        s1:=Bool2Str(v); CopyMemory(PointerStr(s,an[nTo]),pointer(s1),1);
                      end
                      else if Assigned(rTo) then rTo[nTo]:=v
                      else if lRequestLive then
                        //if UnDataType(fTo)=ftBoolean then
                        fTo.AsBoolean:=v
                        //else fTo.AsString:=Bool2Str(v);
                    end;
                    ftFloat: begin
                      vSet(IsNilc(dFrom.ValueNum(nFrom),0));
                      if lExtTo then begin
                        d:=v; CopyMemory(PointerStr(s,an[nTo]),@d,SizeOfVar[stDouble]);
                      end
                      else if Assigned(rTo) then rTo[nTo]:=v
                      else if lRequestLive then fTo.AsFloat:=v;
                    end;
                    {ftDate: begin
                      vSet(dFrom.IsNilc(ValueNum(nFrom),DateEmpty));
                      if lRequestLive then fTo.AsDateTime:=v;
                    end;}
                    ftBlob,ftMemo: if dFrom is TMulQuery then begin
                      TBlobField(fFrom).SaveToStream(StringStreamCreate(ss)); ss.Seek(0,soBeginning);
                      if blobTo then begin
                        try
                          TBlobField(fTo).LoadFromStream(ss);
                        except
                          SetStack(ost);
                          qTo.Close;
                          qTo.Open;
                          fSet;
                          {for l1:=low(af) to high(af) do with af[l1] do
                            fTo:=qTo.FindField(fFrom.FieldName+IfThen(TrimUpper(fFrom.FieldName)='INDEX','_'));}
                          qTo.Append;
                          qTo.Edit;
                          ss.Seek(0,soBeginning);
                          TBlobField(fTo).LoadFromStream(ss);
                        end;
                      end
                      else begin
                        Inc(PLongInt(pnt)^);
                        vSet(PLongInt(pnt)^);
                        if lRequestLive then fTo.AsInteger:=v;
                        TRecDB.SetMemValue(v,ss.DataString,qTo1,[memNoDelPrior,memNoShifr],famMemo);
                      end;
                      ss.Size:=0;
                    end
                    else TDatabaseText(dFrom).CopyToBlobField(fTo,nFrom);
                  else
                    vSet(dFrom.ValueNum(nFrom));
                    if lExtTo then begin
                      if tp<>ftDate then raise ECopyTableError.CreateFmt(
                        'Неизвестный тип для перекачки через внешний файл: %d%sТаблица: %s%sПоле: %s',
                        [longint(tp),CRLF,TMulQuery(dFrom).Arg[sTABLE],CRLF,FieldName])
                      else if not empty(v) then begin
                        l1:=trunc(TDateTime(IsNilc(v,0))-DtBeg);
                        CopyMemory(PointerStr(s,an[nTo]),@l1,SizeOfVar[stInteger]);
                      end
                    end
                    else if Assigned(rTo) then rTo[nTo]:=v
                    else if lRequestLive then fTo.Value:=v;
                  end;
                  if Assigned(qTo) and not lRequestLive then qTo.SetParamValue(nTo,qTo1.VarTos(v,vsQQ));
                end;
                for i:=low(a0) to high(a0) do begin
                  FieldName:=a0[i].nmf;
                  vSet(a0[i].v);
                  if lRequestLive then a0[i].f.Value:=v
                  else qTo.SetParamValue(a0[i].nTo,qTo1.VarTos(v,vsQQ));
                end;
                if lExtTo then FileWrite(fs,pointer(s)^,l)
                else if Assigned(qTo) and not lRequestLive then qTo.ExecSQL;
              end;
              RecPr(true);
            end;
            dFrom.next; Inc(j);
          end;
          if Sender.Aborted then break;
          Inc(nuf);
          if nuf>=luf then break;
          if Sender.SayStat(Format('Копирование таблицы %s (часть %d из %d)',
            [string(TMulQuery(dFrom).Arg[sTABLE]),nuf+1,luf]),' ') then break;
          Sender.ClearTime;
          lr:=auf^[nuf].lr; qFromOpen(pointer(dFrom),ac^,auf^[nuf].where,sord,lr);
        until false;
        if Assigned(qTo) and not lExtTo then
          if lRequestLive then begin
            if not Sender.Aborted and (j>1) then qTo.Post;
            qTo.RequestLive:=false;
          end
          else qTo.UnPrepare;
      finally
        if fs>=0 then FileClose(fs);
      end;
    finally
      qFrom1.Free; qTo1.Free; ss.Free;
    end;
  except
    OutStack('CopyTable'); raise
  end;
  DelStack;
end;

function CopyTable;
  function IsExt(db: TComponent): boolean;
  //var s: string;
  begin
    AddStack('FrmPswd.CopyTable.IsExt');
    result:=false; // без Extended-файлов
    {with GetDrvInfo(db) do result:=AnsiFindText не QuickFind('#ce_table',aSQL);
    if result then begin
      s:=GetDBName(db);
      if empty(ExtractFileDrive(s)) and (Pos(DriveDelim,s)>0) then result:=false;
    end;}
    DelStack;
  end;
  procedure IsExt1(var lExt: boolean; ls: TMQFieldList);
  var i: longint;
  begin
    AddStack('FrmPswd.CopyTable.IsExt1');
    if lExt then for i:=0 to ls.Count-1 do if ls.Fields(i).DataType=ftBlob then begin
      lExt:=false; break;
    end;
    DelStack;
  end;
var lExtFrom,lExtTo: boolean;
  ExtFile,TmpTbl: string;
  qFrom,qTo: TMulQuery;
  procedure DropTmpTbl;
  var fl: boolean;
  begin
    AddStack('FrmPswd.CopyTable.DropTmpTbl');
    if not(cptNoDropTmpTbl in Opt) then begin
      fl:=NoDBFLush; NoDBFLush:=false;
      if lExtFrom then
        if qFrom.DropTable(TmpTbl) then qFrom.DBFlush([flushConnect]);
      if lExtTo then
        if qTo.DropTable(TmpTbl) then qTo.DBFlush([flushConnect]);
      NoDBFLush:=fl;
      DelFileAtr(ExtFile);
    end;
    DelStack;
  end;
var tableTo: string;
  procedure InsFromTmp;
  var s: string;
  begin
    AddStack('FrmPswd.CopyTable.InsFromTmp');
    qTo.Arg[sTABLE]:=TmpTbl; qTo.Arg['file']:=ExtFile;
    qTo.ExecPart('ce_table');
    s:=qTo.SetPart(sSELECT_FLIST); qTo.Arg[sTABLE]:=tableTo; qTo.Arg[sSELECT]:=s;
    qTo.ExecInsFromSel;
    DelStack;
  end;
var DbfInf: PDbfInfCreate;
  procedure ListByCreateTable(Source: TObject);
  var lBlob: boolean;
    ls: TStringList;
    tbl: string;
    nDbfInf: longint;
    procedure Add1(const cFieldName: string; cDataType: TFieldType; Size: longint; cNotNull: boolean;
      Dec: Longint = FloatMaxDec);
    var p: string;
      dft: TDbfFieldType;
    begin
      AddStack('FrmPswd.CopyTable.ListByCreateTable.Add1');
      UnDataTypeSelf(cdatatype);
      if Assigned(qTo) then with qTo do begin
        SQLText(''); arg['len']:=Size;
        case cdatatype of
          ftString: setpart('char');
          ftInteger: begin
            p:='int';
            if lBlob then
              if ls.IndexOf(tbl+cFieldName)>=0 then p:='blob';
            setpart(p);
          end;
          ftBoolean: begin
            arg['len']:=1; setpart('char');
          end;
          ftFloat: setpart('double');
          ftDate: setpart('date');
          ftBlob,ftMemo: setpart('blob');
        end;
        p:=Text;
        if not empty(p) then begin
          if cNotNull then DlmBetwSelf(p,SetPart('notnull'),' ');
          AddArgList('typ_list',p); p:=cFieldname;
          if TrimUpper(p)='INDEX' then IncD(p,'_');
          AddArgList(sC_LIST,p);
        end;
      end
      else begin
        if Length(DbfInf^)=nDbfInf then SetLength(DbfInf^,nDbfInf shl 1);
        DbfInf^[nDbfInf].Name:=cFieldName;
        for dft:=low(aDbfToFt) to high(aDbfToFt) do
          if aDbfToFt[dft]=cDataType then begin
            DbfInf^[nDbfInf].FieldType:=dft; break;
          end;
        DbfInf^[nDbfInf].Len:=Size;
        DbfInf^[nDbfInf].Dec:=Dec;
        Inc(nDbfInf);
      end;
      DelStack;
    end;
  const aBlob: array[1..3,1..2] of string =
    ((tFILES  ,fTXT)
    ,(tGLOBSET,'ICON')
    ,(tMODEL  ,fTXT)
    );
  var i: longint;
    fls: TMQFieldList;
    dFrom: TCustomDataFile;
    q: TMulQuery;
  begin
    AddStack('FrmPswd.CopyTable.ListByCreateTable');
    IsClass(Source,TCustomDataFile,pointer(dFrom));
    IsClass(Source,TMQFieldList,pointer(fls));
    ls:=nil;
    if Assigned(qFrom) and Assigned(qTo) then begin
      qTo.Arg['typ_list']:=''; qTo.Arg[sC_LIST]:='';
      lBlob:=not qFrom.DrvCan('blob') and qTo.DrvCan('blob');
      if lBlob then begin
        ls:=SortStrListCreate; tbl:=qFrom.Arg[sTABLE]+'.';
      end;
    end
    else lBlob:=false;
    nDbfInf:=0;
    if cptDbfTo in Opt then begin
      New(DbfInf); SetLength(DbfInf^,100);
    end;
    try
      if lBlob then for i:=low(aBlob) to high(aBlob) do ls.Add(aBlob[i,1]+'.'+aBlob[i,2]);
      if Assigned(dFrom) then begin
        if IsClass(dFrom,TMulQuery,pointer(q))
        then fls:=MulQry.GetFieldList(q.Connection,q.Arg[sTABLE]);
        with dFrom do for i:=0 to FieldCount-1 do
          Add1(FieldName(i),DataType(i),FieldLen(i),NotNull(i,fls),FieldDec(i))
      end
      else if Assigned(fls) then for i:=0 to fls.Count-1 do with fls.Fields(i)^ do
        Add1(fls[i],DataType,Size,mqfNotNull in Options);
      if Assigned(pa) then
        for i:=low(pa^) to high(pa^) do with pa^[i] do Add1(FieldName,DataType,Size,NotNull);
    finally
      ls.Free;
    end;
    if cptDbfTo in Opt then SetLength(DbfInf^,nDbfInf);
    DelStack;
  end;
var auf: TUnionFrom;
  fl_is,lTxtFrom,lExtToExt,lDone,blobTo: boolean;
  i,lr,ost: longint;
  tableFrom,s,sw,sord,fnmtxt: string;
  ac,ao: TArrVar;
  lsFrom,lsTo: TMQFieldList;
  tFrom,tTo: TDatabaseText;
  rFrom,rTo: TDbf;
  pnt: Pointer;
  olsTblSQL: PSQLExecArrStr;
  pp: PPswdPrm;
begin
	ost:=AddStack('FrmPswd.CopyTable');
  tableFrom:=table; tableTo:=table; result:=AnsiStartsText(TmpTblExt,tableFrom){ or (tableFrom<>tLOG)};
{if table=tMEMO then begin
tableFrom:=tableFrom;
end;}
  if not result then begin
    lTxtFrom:=false; qFrom:=nil; qTo:=nil; tFrom:=nil; tTo:=nil; rFrom:=nil; rTo:=nil;
    if IsPswdPrm(pp) then with pp^ do begin
      olsTblSQL:=lsTblSQL; lsTblSQL:=nil;
    end
    else olsTblSQL:=nil; //Variable might not have been initialized
    try
      if not IsSQLBased(dbFrom) and (where='') then begin
        s:=CorrDir(TDatabase(dbFrom).Params.Values['PATH'])+tableFrom;
        if not(cptNoDbt in Opt) then begin
          fnmtxt:=s+DBTextExt; lTxtFrom:=FileExists(fnmtxt);
        end;
        if not lTxtFrom then begin
          fnmtxt:=s+'.DBF'; lTxtFrom:=FileExists(fnmtxt);
          if lTxtFrom then begin
            rFrom:=TDbf.CreatePrm(fnmtxt,[dbfDateEmptyAsNull]); rFrom.lDosToWin:=false; lTxtFrom:=rFrom.Active;
          end;
        end;
      end;
      if not lTxtFrom then SetConnected(dbFrom,true);
      if not(cptNoTxtTo in Opt) then if IsSQLBased(dbTo) then Include(Opt,cptNoTxtTo);
      if not(cptNoTxtTo in Opt) then Opt:=Opt-[cptNoCreate,cptDbfTo]
      else if IsSQLBased(dbTo) then begin
        Exclude(Opt,cptDbfTo); SetConnected(dbTo,true)
      end;
      result:=false;
      if lTxtFrom and not(cptNoTxtTo in Opt)
      then result:=CopyFileOpt(fnmtxt,
        CorrDir(TDatabase(dbTo).Params.Values['PATH'])+tableTo+ExtractFileExt(fnmtxt),
        [cfStat]+IfThen(not(cptCanEsc in Opt),cfNoEsc))
      else begin
        lExtToExt:=false; lsFrom:=nil; lsTo:=nil;
        if IsResProcess(resFirebird) then begin
          lExtFrom:=false; lExtTo:=false;
        end
        else begin
          lExtFrom:=IsExt(dbFrom); lExtTo:=IsExt(dbTo);
        end;
        if not lTxtFrom then qFrom:=TMulQuery.CreateConnection(Application.Mainform,dbFrom);
        blobTo:=false; sw:='';
        if cptNoTxtTo in Opt then begin
          if cptDbfTo in Opt then begin
            s:=CorrDir(TDatabase(dbTo).Params.Values['PATH'])+tableTo;
            // удаление предыдущей таблицы
            if not(cptNoCreate in Opt) then begin
              DelFileAtr(s+'.DBF'); DelFileAtr(s+'.DB'); DelFileAtr(s+'.MB'); DelFileAtr(s+DBTextExt);
            end;
            // проверка на существование таблицы
            fl_is:=FileExists(s+'.DBF');
          end
          else begin
            qTo:=TMulQuery.CreateConnection(Application.Mainform,dbTo);
            blobTo:=qTo.DrvCan('blob');
            if (TrimUpper(tableFrom)=tMEMO) and Assigned(p) and blobTo
            then sw:=FldInList(fMGK,PArrStr(p)^,NegDef,[flsNot]);
            qTo.arg[sTABLE]:=tableTo;
            // удаление предыдущей таблицы
            if not(cptNoCreate in Opt) then
              if qTo.DropTable(tableTo) then qTo.DBFlush;
            // проверка на существование таблицы
            fl_is:=IsTable(dbTo,tableTo);
            if cptNoCreate in Opt then begin
              lsTo:=GetFieldList(dbTo,tableTo); IsExt1(lExtTo,lsTo);
            end;
          end;
          if fl_is and not(cptNoCreate in Opt) then raise ECopyTableError.Create(
            'Не могу удалить таблицу '+tableTo);
          if not fl_is and (cptNoCreate in Opt) then raise ECopyTableError.Create(
            'Выходная таблица '+tableTo+' не существует !');
        end;
        lDone:=true;
        repeat
          auf:=nil; result:=true;
          if lTxtFrom then
            if rFrom.Active then lr:=rFrom.RecordCount
            else begin
              tFrom:=TDatabaseText.CreatePrm(TDatabase(dbFrom).Params.Values['PATH'],tableFrom,true);
              lr:=tFrom.RecordCount;
            end
          else begin
            if lDone then lsFrom:=GetFieldList(dbFrom,tableFrom);
            IsExt1(lExtFrom,lsFrom);
            lExtToExt := lExtFrom and lExtTo and not(cptNoCreate in Opt);
            CopyFrom(ac,lsFrom);
            if TrimUpper(tableFrom)=tREGS then s:=fREGS+sISNULL else s:=DlmBetween(sw,where,sAND);
            if lExtToExt then begin
              lr:=IfThen(TrimUpper(tableFrom)<>tREGS,1); qFrom.Arg[sWHERE]:=s;
            end
            else begin
              lr:=-1; ao:=nil;
              if olist<>''
                then sord:=olist
              else begin
                if TrimUpper(tableFrom)=tMEMO
                  then AddFromVArr(ao,[fMGK,fMNPP])
                else if TrimUpper(tableFrom)=tLOG
                  then AddFromVArr(ao,[fLogD])
                else if lsFrom.IsField(fRECNO)
                  then AddFromVArr(ao,[fRECNO]);
                sord:=qFrom.GetList(ao);
              end;
              if (sord<>'') and (qFrom.DataSet is TIBQuery) then begin
                if UnionFrom(qFrom,tableFrom,s,ao,lr,auf,result) then
                  if result then begin
                    s:=auf[0].where; lr:=auf[0].lr;
                  end
                  else lDone:=false;
              end
              else qFrom.Arg[sTABLE]:=tableFrom;
              qFromOpen(qFrom,ac,s,sord,lr);
            end;
          end;
          if lDone then
            if cptNoTxtTo in Opt then begin
              DbfInf:=nil;
              try
                if not(cptNoCreate in Opt) then
                  if lTxtFrom then ListByCreateTable(DataFile([tFrom,rFrom])) else ListByCreateTable(lsFrom);
                if cptDbfTo in Opt then begin
                  rTo:=TDbf.CreatePrm(CorrDir(TDatabase(dbTo).Params.Values['PATH'])+tableTo,
                    [dbfNoReadOnly],DbfInf);
                  rTo.lDosToWin:=false;
                  if cptNoCreate in Opt then rTo.DeleteAll;
                end
                else begin
                  qTo.ExecPart(IfThen(cptNoCreate in Opt,sD_TABLE,'c_table'));
                  qTo.commit;
                  if cptNoCreate in Opt then ListByCreateTable(lsTo)
                  else begin
                    qTo.DBFlush([flushBound]);
                    lsTo:=GetFieldList(dbTo,tableTo); IsExt1(lExtTo,lsTo);
                  end;
                end;
              finally
                if Assigned(DbfInf) then Dispose(DbfInf);
              end;
            end
            else begin
              try
                tTo:=TDatabaseText.CreatePrm(TDatabase(dbTo).Params.Values['PATH'],tableTo,false,qFrom);
              except
                raise ECopyTableError.Create('Ошибка создания файла '
                  +CorrDir(TDatabase(dbTo).Params.Values['PATH'])+tableTo+DBTextExt);
              end;
              tTo.ValueProc:=ValueProc;
            end;
          if result then begin
            pnt:=p;
            if lr=0 then lDone:=true
            else begin
              if lExtFrom or lExtTo then TmpTbl:=StrNum(TmpTblExt,
                CntMaskFiles(ExtractFilePath(Application.ExeName)+TmpTblExt+'*')+1,5);
              ExtFile:=ExtractFilePath(Application.ExeName)+TmpTbl+'.EXT';
              try
                if lExtToExt then begin
                  DropTmpTbl;
                  qFrom.Arg[sTABLE]:=tableFrom; qFrom.SetArrayList(sC_LIST,ac);
                  s:=qFrom.SetPart(aPartWOGH[s='',true,true,true]);
                  qFrom.Arg[sTABLE]:=TmpTbl; qFrom.Arg['file']:=ExtFile;
                  qFrom.Arg['typ_list']:=qTo.Arg['typ_list']; qFrom.Arg[sC_LIST]:=qTo.Arg[sC_LIST];
                  try
                    qFrom.ExecPart('ce_table');
                    qFrom.Arg[sSELECT]:=s; qFrom.ExecInsFromSel; InsFromTmp;
                  except
                    on EDatabaseError do
                      if lDone then begin
                        SetStack(ost);
                        result:=false; lDone:=false; lExtFrom:=false;
                      end
                      else raise
                  end;
                end
                // копирование по записям
                else begin

                  //lExtTo:=false;

                  lDone:=true;
                  result := not ShowStat('Копирование таблицы '+tableFrom
                    +IfThen(Length(auf)>0,Format(' (часть %d из %d)',[1,Length(auf)])),StCopyTable,
                    [lr,LongInt(DataFile([qFrom,tFrom,rFrom])),LongInt(qTo),LongInt(tTo),LongInt(rTo),
                    LongInt(@ValueProc),lExtTo,LongInt(lsTo),
                    ExtFile,LongInt(@RecProc),flTrans,LongInt(pnt),blobTo,
                    longint(@auf),longint(@ac),sord],lr,cptCanEsc in Opt);
                  if result and Assigned(qTo) and lExtTo then begin
                    CopyFrom(ac,lsTo); qTo.SetArrayList(sC_LIST,ac);
                    try
                      InsFromTmp;
                    except
                      on EDatabaseError do
                        if lDone then begin
                          SetStack(ost);
                          result:=false; lDone:=false; lExtTo:=false;
                          qTo.arg[sTABLE]:=tableTo;
                        end
                        else raise
                    end;
                  end;
                end;
                // обнуление пустых дат для interbase
                {if result and Assigned(qTo) then begin
                  // обнуление пустых дат для interbase
                  s:=IfThen(lExtTo,'u_empextdate','u_emptydate');
                  for i:=0 to lsTo.Count-1 do if lsTo.Fields(i).datatype=ftDate then begin
                    qTo.arg['col']:=lsTo[i]; qTo.ExecPart(s);
                  end;
                end;}
                if result and Assigned(qTo) and lExtTo then
                  for i:=0 to lsTo.Count-1 do if lsTo.Fields(i).datatype=ftDate then begin
                    qTo.arg['col']:=lsTo[i]; qTo.ExecPart('u_empextdate');
                  end;
              finally
                DropTmpTbl;
              end;
            end;
          end;
        until lDone;
        if cptNoTxtTo in Opt then LsDBClearTbl(dbTo,tableTo);
      end;
    finally
      qFrom.Free; qTo.Free; tFrom.Free; tTo.Free; rFrom.Free; rTo.Free;
      if Assigned(pp) then pp.lsTblSQL:=olsTblSQL;
    end;
  end;
  DelStack;
end;

function UnionFrom;
begin
  AddStack('FrmPswd.UnionFrom');
  lr:=qFrom.PartCount(tableFrom,where); result := (Length(ao)>0) and (lr>MaxUn);
  if result then if UnDataType(GetFieldList(qFrom.Connection,tableFrom).Fields(ao[0]).DataType) in [ftInteger,ftFloat,ftDate]
  then lDone:=not ShowStat('Разбивка таблицы '+tableFrom+' на части',StUnionFrom,
      [longint(qFrom),ao[0],where,longint(@auf),lr]);
  DelStack;
end;

function DropTmpTblExt;
var ls: TStringList;
  q: TMulQuery;
  i: longint;
  fl: boolean;
begin
  AddStack('FrmPswd.DropTmpTblExt');
  result:=false;
  if IsSQLBased(db) then begin
    fl:=Connected(db); q:=TMulQuery.CreateConnection(Application.MainForm,db);
    try
      SetConnected(db,true); ls:=GetTableList(db);
      for i:=0 to ls.Count-1 do
        if AnsiStartsText(TmpTblExt,ls[i]) then begin
          result:=true; q.DropTable(ls[i]);
        end;
    finally
      q.Free; SetConnected(db,fl);
    end;
  end;
  DelStack;
end;

procedure DropTmpFileExt;
begin
  AddStack('FrmPswd.DropTmpFileExt');
  DelMaskFiles(ExtractFilePath(Application.ExeName)+TmpTblExt+'*.EXT');
  DelStack;
end;

function ListDef(Qdbs: TMulQuery): dbsrec;
var f: TField;
begin
	AddStack('FrmPswd.ListDef');
  with result do begin
    table_name:=trim(QDbs.FindField(fDbsTABLE).AsString);
    fld_name:=trim(QDbs.FindField(fDbsFIELD).AsString);
    fld_align:=trim(QDbs.FindField('fld_align').AsString);
    fld_space:=trim(QDbs.FindField('fld_space').AsString);
    f_default:=TrimRight(QDbs.FindField('f_default').AsString);
    fld_type:=trim(QDbs.FindField('fld_type').AsString);
    fld_size:=QDbs.FindField('fld_size').AsInteger;
    fld_dec:=QDbs.FindField('fld_dec').AsInteger;
    NotNull:=StrToBoolean(FieldAsString(QDbs.FindField('NotNull')));
    if not QDbs.FindField(fDbsVERS,f) then f:=QDbs.Fields[0];
    vers:=f.AsString;
  end;
  DelStack;
end;

procedure DbInsChkCreate(var a: TArrDbsRec; Prm: pointer);
const af: array[1..2] of string = (fUSERNUM,fRECNO_I);
var i: longint;
  j: byte;
begin
  AddStack('FrmPswd.DbInsChkCreate');
  i:=Length(a); SetLength(a,i+Length(af));
  for j:=low(af) to high(af) do with a[i] do begin
    table_name:=PString(Prm)^; fld_name:=af[j]; fld_type:='I'; Inc(i);
  end;
  for i:=low(a) to high(a) do a[i].NotNull:=false;
  DelStack;
end;

function CreateTable(const tblDef,tblCreate: string; lSetDbs: boolean; db: TComponent;
  Proc: TCreateTableProc; Prm: pointer): boolean; overload;
var q,q1: TMulQuery;
  a: TArrDbsRec;
  s,so,tblCrt: string;
  i: longint;
  fqNAME,fqTYPE: TField;
begin
	AddStack('FrmPswd.CreateTable');
	tblCrt:=IfThen(tblCreate='',tblDef,tblCreate);
  if not Assigned(db) then db:=PswdPrm.DBMain;
  q :=TMulQuery.CreateConnection(Application.Mainform,db);
  q1:=TMulQuery.CreateConnection(Application.Mainform,db);
  try
  	with q do begin
  		q.DropTable(tblCrt);
      PartSelect(aDbsTbl[lSetDbs].dbs,[],fDbsTABLE+'='+QQs(AnsiLowerCase(tblDef)),GetList([fDbsFIELD,fDbsVERS]));
      SetLength(a,RecordCount); i:=low(a);
      Last; so:=''; fqNAME:=FindField(fDbsFIELD); fqTYPE:=FindField('FLD_TYPE');
      while not Bof do begin
      	s:=fqNAME.AsString;
      	if s<>so then begin
        	so:=s;
          if Trim(fqTYPE.AsString)<>'U' then begin
          	a[i]:=ListDef(q); Inc(i);
          end;
        end;
        Prior;
      end;
      SetLength(a,i);
      if Assigned(Proc) then Proc(a,Prm);
      with q do begin
        result:=false; Arg[sTABLE]:=tblCrt; Arg[sC_LIST]:=''; Arg['typ_list']:='';
        for i:=low(a) to high(a) do begin
          s:=sqltype(a[i],q1);
          if s<>'' then begin
            AddArgList(sC_LIST,a[i].fld_name); AddArgList('typ_list',s);
          end;
        end;
        if Arg[sC_LIST]<>'' then begin
          result:=ExecPart('c_table',true);
          if result then begin
            commit; LsDBClearDB(Connection);
          end;
        end;
      end;
    end;
  finally
    q.Free; q1.Free;
  end;
  DelStack;
end;

function CreateTable(const tblDef: string; const tblCreate: string = '';
	lSetDbs: boolean = false; db: TComponent = nil): boolean;
begin
  result:=CreateTable(tblDef,tblCreate,lSetDbs,db,nil,nil);
end;

procedure StDbInsChk(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var q,q1: TMulQuery;
	i,un,RecCnt,j,lr: longint;
  ac: TArrVar;
  tbl,s: string;
  fl: boolean;
  db: TComponent;
begin
	AddStack('FrmPswd.StDbInsChk');
  db:=PointerVar(Params[0]); tbl:=Params[1]; RecCnt:=Params[2];
  if not IsTable(db,tbl)
  then CreateTable(SubStr(tbl,1,-lDBInsPostfix),tbl,false,nil,DbInsChkCreate,@tbl);
  q :=TMulQuery.CreateConnection(Application.MainForm,db);
  q1:=TMulQuery.CreateConnection(Application.MainForm,db);
  try
    CopyFromVArr(ac,[fUSERNUM,fRECNO_I]); q.PartCount(tbl,ac);
    s:=fUSERNUM+'<1'+sOR+fUSERNUM+'>'+Vtos(ProgPswd.PswdPrm.UserCnt)+sOR+fRECNO_I+'<1';
    if RecCnt=0 then begin
    	un:=q.Fields[0].AsInteger;
      while not q.Eof and (q.Fields[0].AsInteger=un) do begin
      	Inc(RecCnt); q.Next;
      end;
      q.First; q1.DeleteTable(tbl,s);
    end
    else q1.DeleteTable(tbl,s+sOR+fRECNO_I+'>'+Vtos(RecCnt));
    j:=1; lr:=ProgPswd.PswdPrm.UserCnt*RecCnt;
    for un:=1 to ProgPswd.PswdPrm.UserCnt do begin
      for i:=1 to RecCnt do begin
      	Sender.SayStat('',Format('Пользователь: %d; запись: %d',[un,i]),j/lr); Inc(j); fl:=true;
      	if not q.Eof and (q.Fields[0].AsInteger=un) and (q.Fields[1].AsInteger=i) then begin
        	fl := q.Fields[2].AsInteger>1;
        	if fl then q1.DeleteTable(tbl,fUSERNUM+'='+Vtos(un)+sAND+fRECNO_I+'='+Vtos(i));
          q.Next;
      	end;
        if fl then q1.InsertTable(tbl,ac,[un,i]);
      end;
      while not q.Eof and (q.Fields[0].AsInteger=un) do q.Next;
    end;
  finally
  	q.Free; q1.Free;
  end;
  DelStack;
end;

procedure FDbInsCheck(const db: TComponent; const Capt,tbl: string; RecCnt: longint);
begin
  AddStack('FrmPswd.FDbInsCheck');
  ShowStat(Capt+' таблицы '+tbl,StDbInsChk,[LongInt(db),tbl,RecCnt],[stNoCanEsc]);
  DelStack;
end;

procedure DbInsCheck;
var ls: TStringlist;
  i: longint;
begin
  AddStack('FrmPswd.DbInsCheck');
  ls:=GetTableList;
  for i:=0 to ls.Count-1 do
    if UpperCase(RightStr(ls[i],lDBInsPostfix))=DBInsPostfix
    then FDbInsCheck(PswdPrm.DBMain,'Проверка',ls[i],0);
  DelStack;
end;

function IfThen(AValue: boolean; ATrue: TLockModeList): TLockModeOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TCopyDBDBFList): TCopyDBDBFOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TCopyTableList): TCopyTableOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

{перестройка таблиц}
const fDbIns = '@i';

procedure StModifyTable(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var Qdbs,Mqtmp:TMulQuery;
  adbs: ^TArrDbsRec;
  idbs: longint;
	function ac_table: boolean;
  begin
    AddStack('FrmPswd.StModifyTable.ac_table');
    Qdbs.arg['type']:=sqltype(adbs^[idbs],mqtmp); result := Qdbs.arg['type']<>'';
    if result then Qdbs.ExecPart('ac_table');
    DelStack;
  end;
var tn: string;
  Modified: boolean;
  ProcMsg: TModifyTableMsgProc;
  PrmMsg: pointer;
  procedure Msg(const msg: string);
  begin
    AddStack('FrmPswd.StModifyTable.Msg');
    Modified:=true;
    if Assigned(ProcMsg) then ProcMsg(PrmMsg,UpperCase(tn),msg);
    DelStack;
  end;
const TmpCol = 'tmpcol';
var fl_table,fl:boolean;
	ln,lo,ost,ldbs:longint;
	so,sn,stn,sto,fn,cfn,otn:string;
  c: Char;
	cur_mode:longint;
  drec:dbsrec;
  db: TComponent;
  ls: TStringList;
  fo: PMQFieldInfo;
begin
	ost:=AddStack('FrmPswd.StModifyTable');
  db:=PointerVar(Params[0]);
  Mqtmp:=TMulQuery.CreateConnection(Application.Mainform,db);
  Modified:=false; ls:=SortStrListCreate;
  try
  	QDbs:=PointerVar(Params[1]); adbs:=PointerVar(Params[2]); ldbs:=Params[3];
    ProcMsg:=PointerVar(Params[4]); PrmMsg:=PointerVar(Params[5]);
    idbs:=0;
    cur_mode:=0;
    otn:=''; ln:=0; lo:=0;
    while idbs<ldbs do with adbs^[idbs] do begin
      tn:=table_name; fn:=fld_name;
      Sender.SayStat('',tn+'.'+fn,(idbs+1)/ldbs);
      if fn=fDbIns then FDbInsCheck(db,'Создание',tn+DBInsPostfix,fld_size)
      else begin
        fl_table:=IsTable(db,tn);
        if tn<>otn then begin
          otn:=tn;
          if fl_table then begin
            GetFieldNames(db,tn,ls);
            if FindDel(ls,TmpCol) then begin
              Qdbs.arg[sTABLE]:=tn; Qdbs.arg['col']:=TmpCol;
              Msg('Удалено поле '+UpperCase(TmpCol)); Qdbs.execpart('dc_table'); 
            end;
          end
          else ls.Clear;
        end;
        {Qdbs.PartSelect(tn,[],'','','',false); fl_table:=false;
        try
          Qdbs.Open; fl_table:=true;
        except
          on EDatabaseError do SetStack(ost);
        end;
        {Удаление столбца}
        if (fld_type='U') and fl_table then begin
          if FindDel(ls,fn) then
            if ls.Count=0 then begin
              Msg('Удалена таблица'); Qdbs.DropTable(tn);
            end
            else begin
              Qdbs.arg[sTABLE]:=tn; Qdbs.arg['col']:=fn; Msg('Удалено поле '+UpperCase(fn));
              Qdbs.execpart('dc_table');
            end;
          cur_mode:=9;
        end;
        {если не существует таблица,то создать таблицу}
        if not fl_table then begin
          Qdbs.arg['typ_list']:=sqltype(adbs^[idbs],mqtmp);
          if Qdbs.arg['typ_list']<>'' then begin
            Qdbs.arg[sTABLE]:=tn;
            Qdbs.arg[sC_LIST]:=fn;
            Msg('Создана таблица'); Qdbs.ExecPart('c_table'); 
            Qdbs.commit;
            Qdbs.DBFlush([flushConnect]);
            cur_mode:=7;
          end;
        end;
        if cur_mode=0 then  begin
          fl:=true; sto:=''; fo:=nil;
          if fl_table then if GetFieldList(db,tn).Fields(fn,fo) then with fo^ do begin
            fl:=false;
            case DataType of
              ftInteger: sto:='I';
              ftBoolean: sto:='S    1';
              ftFloat: sto:='F';
              ftDate: sto:='D';
              ftBlob: sto:='O';
            else sto:='S'+spacestr(Size,5);
            end;
            if (mqfNotNull in Options) and not(DataType in [ftDate,ftBlob]) then begin
              so:=fn+sISNULL;
              if not QDbs.PartCount0(tn,so)
              then QDbs.UpdateTable('',[fn],[iif(DataType in [ftInteger,ftFloat],0,QQs)],so);
            end;
          end;
          if fl then begin
            cur_mode:=6;
          end else begin
            stn:=fld_type;
            if AnsiMatchText(stn,['V','C','С']) then stn:='S';
            if stn='S' then IncD(stn,spacestr(fld_size,5));
            if (stn='L') or (stn='B') then stn:='S    1';
            cur_mode:=9; //не модифицировать
            if not((stn=sto) and (StrToChar(stn)='O')) then
              if stn=sto then {если совпадают типы }
                if Assigned(fo) then begin
                  drec.NotNull := mqfNotNull in fo.Options; drec.fld_size:=fo.Size;
                  case fo.DataType of
                    ftInteger: drec.fld_type:='I';
                    ftFloat: drec.fld_type:='F';
                    ftDate: drec.fld_type:='D';
                    ftBlob: drec.fld_type:='O';
                  else drec.fld_type:='C';
                  end;
                  if sqltype(adbs^[idbs],mqtmp)<>sqltype(drec,mqtmp) then cur_mode:=1;
                end
                else cur_mode:=1
              else cur_mode:=1;
          end;
        end;
        if cur_mode=1 then begin {если надо изменить столбец}
          cur_mode:=2;
          if (stn<>sto) and ((stn='D') or (sto='D')) then begin {дату не переводим в другой тип}
            cur_mode:=5;
          end else begin
            cfn:=fn;
            if stn<>sto then begin
              sn:=LeftStr(stn,1);
              so:=LeftStr(sto,1);
              ln:=StrToIntDef(copy(stn,2,maxint),0);
              lo:=StrToIntDef(copy(sto,2,maxint),0);
              if sn=so then begin {если строки}
                Msg('Изменена длина поля '+UpperCase(fn)+Format(' с %d на %d',[lo,ln]));
                if ln>lo then begin
                  c:=StrToChar(fld_space);
                  if fld_align='R'
                  then Qdbs.SetArrayList(sC_LIST,[QQs(StringOfChar(c,ln-lo),false),fn])
                  else Qdbs.SetArrayList(sC_LIST,[fn,QQs(StringOfChar(c,ln-lo),false)]);
                  cfn:=Qdbs.setpart('s+s');
                end else begin
                  cur_mode:=3;  {Уменьшение строки}
                end;
              end else begin
                if ((sn='F') or (sn='I')) and (so='S') then begin {строка в число}
                  Qdbs.arg['col']:=fn; cfn:=Qdbs.setpart(IfThen(sn='F','ASNUM','ASINT'));
                  Msg('Поле '+UpperCase(fn)+' преобразовано из строки в число');
                end
                else if (sn='S')and ((so='F') or (so='I')) then begin {число в строку}
                  Qdbs.arg['col']:=fn; Qdbs.arg['len']:=ln; cfn:=Qdbs.setpart('ASCHAR()');
                  Msg('Поле '+UpperCase(fn)+' преобразовано из числа в строку');
                end
                else if (so='F')and (sn='I') then begin {число в целое}
                  Qdbs.arg['col']:=fn; cfn:=Qdbs.setpart('ASINT');
                  Msg('Поле '+UpperCase(fn)+' преобразовано из числа в целое');
                end
                else if (so='I')and (sn='F') then begin {целое в число}
                  Qdbs.arg['col']:=fn; cfn:=Qdbs.setpart('ASNUM');
                  Msg('Поле '+UpperCase(fn)+' преобразовано из целого в число');
                end
                else if (so='F')and (sn='N') or (so='N')and (sn='F') then begin {число в число}
                  Qdbs.arg['col']:=fn; cfn:=Qdbs.setpart('ASNUM');
                  Msg('Поле '+UpperCase(fn)+' преобразовано из числа в число');
                end
                else cur_mode:=5; // преобразование невозможно,отменить перемещение
              end;
            end;
          end;
        end;
        Qdbs.arg[sTABLE]:=tn;
        if (cur_mode=2) or (cur_mode=3) then begin
          Qdbs.arg['col']:=TmpCol;
          Qdbs.SetPart('dc_table');
          try
            Qdbs.ExecSQL;
          except
            on EDatabaseError do SetStack(ost);
          end;
          ac_table;
          if cur_mode=2 then begin
            Qdbs.UpdateTable('',[TmpCol],[cfn]);
            try
              Qdbs.ExecSQL;
            except
              on EDatabaseError do begin
                SetStack(ost);
                //meserr('Ошибка при конвертации поля - '+fn);
              end;
            end;
            cur_mode:=4;
          end;
          if cur_mode=3 then begin // Если строка уменьшается
            Mqtmp.arg[sTABLE]:=tn;
            Mqtmp.arg['col']:=fn;
            Mqtmp.setpart('sel_col_group');
            Mqtmp.opentry;
            Mqtmp.first;
            Qdbs.arg[sTABLE]:=tn;
            Qdbs.arg['col']:=TmpCol;
            Qdbs.arg['col2']:=fn;
            while not mqtmp.eof do begin
              Qdbs.arg['v2']:=Qq+TrimRight(mqtmp.fields[0].Asstring);
              if fld_align='R' then begin
                Qdbs.arg['v1']:=QQs(copy(mqtmp.fields[0].Asstring,lo-ln+1,ln),false);
              end else begin
                Qdbs.arg['v1']:=QQs(copy(mqtmp.fields[0].Asstring,1,ln),false);
              end;
              Qdbs.execpart('trim_col');
              mqtmp.next;
            end;
            mqtmp.close;
            cur_mode:=4;
          end;
        end;
        if (cur_mode=4) or (cur_mode=5)then begin
          Qdbs.arg['col']:=fn;
          fl:=MessagesHidden; MessagesHidden:=true;
          Qdbs.ExecPart('dc_table'); MessagesHidden:=fl;
          ac_table;
        end;
        if (cur_mode=4) then begin
          Qdbs.UpdateTable('',[fn],[TmpCol]);
          Qdbs.arg['col']:=TmpCol;
          Qdbs.ExecPart('dc_table');
          cur_mode:=9;
        end;
        if cur_mode=5 then  begin
          cur_mode:=7;
        end;
        if cur_mode=6 then begin {Добавить столбец}
          ls.Add(fn);
          Qdbs.arg[sTABLE]:=tn;
          Qdbs.arg['col']:=fn;
          if ac_table then Msg('Добавлено поле '+UpperCase(fn));
          cur_mode:=7;
        end;
        if cur_mode=7 then begin {значение по умолчанию}
          cfn:=TrimRight(f_default); stn:=fld_type; c:=StrToChar(stn);
          if empty(cfn) and (c in ['B','L']) then cfn:=bFalse;
          if empty(cfn) and NotNull and (c<>'D') then
            if c in ['F','I','N'] then cfn:=VToS else cfn:=QQ;
          if not empty(cfn) then begin
            if (c='D') and (cfn=cDtEnd)
              then cfn:=Qdbs.VarTos(DateBig)
            else if cfn[1]='@'
              then Delete(cfn,1,1)
            else if (c in ['S','C','V','D','B','L']) and (cfn<>QQ)
              then IncL(cfn,QQ);
            Qdbs.UpdateTable(tn,[fn],[cfn]);
          end;
        end;
        cur_mode:=0;
      end;
      inc(iDbs);
    end;
    mqtmp.active:=false;
    if Modified then Qdbs.DBFlush([flushConnect]);
  finally
    mqtmp.free; ls.Free;
  end;
  DelStack;
end;

procedure ModifyTable(Db: TComponent; lSetDbs: boolean; const ver: string;
  const tbl: string = ''; ProcMsg: TModifyTableMsgProc = nil; PrmMsg: pointer = nil);
var Qdbs: TMulQuery;
  so,sn,dbs: string;
  adbs: TArrDbsRec;
  lo,idbs,ldbs: longint;
  ft,ff: TField;
begin
	AddStack('FrmPswd.ModifyTable');
  Qdbs:=TMulQuery.CreateConnection(Application.Mainform,db);
  try
    dbs:=aDbsTbl[lSetDbs].dbs;
    try
  //		meserr(Qdbs.text);
      with Qdbs do PartSelect(dbs,[],DlmBetween(
        IfThen(ver<>'',fDbsVERS+'='+QQs(ver)),
        IfThen(tbl<>'',fDbsTABLE+'='+QQs(tbl)),
        sAND),GetList([fDbsTABLE,fDbsFIELD,fDbsVERS]));
    except
      on EDatabaseError do raise EModifyTableError.Create(
        'Не могу открыть таблицу '+dbs);
    end;
    lo:=QDbs.RecordCount; SetLength(adbs,lo shl 1); QDbs.first; ldbs:=low(adbs);
    if lo>0 then begin
      so:=''; ft:=QDbs.FindField(fDbsTABLE); ff:=QDbs.FindField(fDbsFIELD);
      while not QDbs.Eof do begin
        sn:=FieldAsVariant(ft)+FieldAsVariant(ff);
        if sn<>so then begin
          if so<>'' then begin
            Qdbs.Prior; adbs[ldbs]:=ListDef(Qdbs); Inc(ldbs); Qdbs.next;
          end;
          so:=sn;
        end;
        Qdbs.next;
      end;
      adbs[ldbs]:=ListDef(Qdbs); Inc(ldbs); lo:=ldbs;
    end;
    Qdbs.close;
    for idbs:=0 to lo-1 do with adbs[idbs] do
    	if fld_name<>fDbIns then
      	if IsTable(db,table_name+DBInsPostfix) then begin
        	adbs[ldbs]:=adbs[idbs]; adbs[ldbs].table_name:=table_name+DBInsPostfix;
          adbs[ldbs].NotNull:=false; Inc(ldbs);
	      end;
    SetLength(adbs,ldbs);
    ShowStat(IfThen(ver='','Корректировка структуры данных','Обновление структуры до версии '+ver),
      StModifyTable,[LongInt(Db),longint(Qdbs),longint(@adbs),ldbs,longint(@ProcMsg),longint(PrmMsg)],
      ldbs,false);
  finally
    Qdbs.Free;
  end;
  DelStack;
end;

procedure ModifyTable(lSetDbs: boolean; const ver: string;
  const tbl: string = ''; ProcMsg: TModifyTableMsgProc = nil; PrmMsg: pointer = nil);
begin
  ModifyTable(PswdPrm.DBMain,lSetDbs,ver,tbl,ProcMsg,PrmMsg);
end;

procedure LogKeysCopy(var Dest: TLogKeysSave; const Source: TLogKeysSave);
var i: longint;
begin
  AddStack('FrmPswd.LogKeysCopy');
  SetLength(Dest,Length(Source));
  for i:=low(Dest) to high(Dest) do Dest[i]:=Source[i];
  DelStack;
end;

procedure PrivProc(const Priv: string; var result: boolean);
begin
  AddStack('FrmPswd.PrivProc');
  if Assigned(ProgPswd) then with ProgPswd do begin
    QryUsers.Open; result:=QuickFind(Priv,aPriv,lPriv);
  end;
  DelStack;
end;

function StrToService(const s: string): TServiceInfo;
var a: array[1..2] of string;
begin
  AddStack('FrmPswd.StrToService');
  with result do begin
  	Name:=''; Port:=0; Protocol:='';
    if not empty(s) then
    	if s[1]<>'#' then begin
        LsArrFill(DelTrim(s),a,' '); Name:=AnsiLowerCase(a[1]);
        LsArrFill(a[2],a,'/'); Port:=Int0(a[1]); Protocol:=AnsiLowerCase(a[2]);
      end;
  end;
  DelStack;
end;

function DBGet(const vn: variant; var db: TComponent): boolean; overload;
var n: longint;
begin
  AddStack('FrmPswd.DBGet(b)');
  db:=nil; result:=false;
  if MyVarType(vn)=varInteger then begin
    n:=vn;
    if InRange(n,1,MaxDB) then
      if Connected(aDB[n]) then begin
        db:=aDB[n]; result:=true;
      end;
  end;
  DelStack;
end;

function DBGet(const av: array of variant; n: longint): TComponent; overload;
begin
  AddStack('FrmPswd.DBGet(db)');
  DBGet(av[n],result); FirstDataBaseSelf(result);
  DelStack;
end;

function FSetDBPrm(db: TComponent; DBType: TDBTypeList;
  const Alias,Driver,Password,FBLocal,Port,DirDefault: string;
  lsParams: TStrings; pPath: PString = nil): boolean;
var nmDrv,cdg,s,dirdef: string;
  t: TFileName;
	j: longint;
  ls: TStrings;
  de: TDefEdit;
  lIB,lFBLocal: boolean;
  a: array[1..3] of string;
begin
  AddStack('FrmPswd.FSetDBPrm');
  ls:=TStringList.Create;
  try
    result:=true; GetDBParams(db).Clear; lIB := db is TIBDatabase;
    if lIB then DBType:=dbtpDriver;
    if DBType=dbtpAlias then with TDatabase(db) do begin
      AliasName:=Alias; Session.GetAliasParams(AliasName,ls); lsParams:=ls;
      nmDrv:=Session.GetAliasDriverName(AliasName);
    end
    else if lIB
      then nmDrv:=drvINTRBASE
    else with TDatabase(db) do begin
      nmDrv:=Driver; DriverName:=nmDrv; Params.Assign(lsParams);
    end;
    TSQLDM.Load;
    if TDefEdit.Find(nmDrv,de) then with de do begin
      cdg:=TrimUpper(TDirGet.ClassName); dirdef:=CorrDir(DirDefault);
      for j:=0 to Fields.Count-1 do
        if StrToBoolean(Param[j,deNewPage]) then break
        else if TrimUpper(Param[j,deVid])=cdg then begin
          s:=Param[j,deNameRecFld]; t:=lsParams.Values[s];
          if not empty(t) then
            if (Pos(DriveDelim,t)=0)and(t[1]<>PathDelim) then begin
              IncL(t,dirdef);
              if DBType<>dbtpAlias then lsParams.Values[s]:=t;
            end;
          SetPString(pPath,t);
          if Assigned(TDirGet(NameGet(cdg,Param[j,deVName])).OpenDialog) then ExtractFilePathSelf(t);
          CorrDirSelf(t);
          if ListAsArray(t,a,DriveDelim)=3 then // Сетевой путь
            if IsSrvLocal(a[1]) then t:=ArrayAsList(a,DriveDelim,NegDef,false,1);
          if t=dirdef+DirDATAs then result:=false;
        end;
{ $IFDEF OLDCNF
      if result and (DBType<>dbtpAlias)
      then result:=TDBPrmGet.CheckDSN(de,db,TDBPrmGet.ReadConfig,ExeDir);
{$ENDIF}
    end;
    lFBLocal:=StrToBoolean(FBLocal);
    if lIB then with TIBDatabase(db),DBParams do begin
      DatabaseName:=lsParams.Values[ibpServerName];
      Values[GetDBUserName(db)]:=lsParams.Values[ibpUserName];
      if Int0(lsParams.Values[ibpFIBDll])=1 then begin
        s:=GetRegKey(HKEY_LOCAL_MACHINE,'Software\Firebird Project\Firebird Server\Instances','DefaultInstance');
        if s<>'' then begin
          s:=CorrDir(s)+'BIN\fbclient.dll';
          if FileExists(s) then begin
            lFBLocal:=false; LibraryName:=s;
          end;
        end;
      end;
    end;
    GetDBParams(db).Values[ibpPassword]:=Password;
    TDbPrmGet.FBLocalCheck(db,lFBLocal,Port);
    NoGarbageCollect(db,StrToBoolean(lsParams.Values[ibpFIBNoGC]));
  finally
    ls.Free;
  end;
  DelStack;
end;

function c_dbopen(var av: array of variant): variant;
var db: TComponent;
	ost,i,j: longint;
  DatabaseName,nmDrv,pswd: string;
  DBType: TDBTypeList;
  ls: TStringList;
begin
	ost:=AddStack('FrmPswd.c_dbopen');
  result:=0; i:=1;
  while i<=high(aDB) do
    if DBGet(i,db) then Inc(i) else break;
  if i>high(aDB) then raise EInterAnyError.CreateFmt(
    'Превышено предельно допустимое количество баз данных (%d)',[high(aDB)]);
  ls:=TStringList.Create;
  try
    DatabaseName:=StrNum('__DB',i);
    if IsNil(av[1]) then begin
      aDB[i]:=TFormPswd.CreateDatabase(av[2],DatabaseName,false);
      TFormPswd.SetDBPrm(aDB[i],av[2],CurrentDir,false);
    end
    else begin
      DBType:=TDBTypeList(IfThen(MyVarType(av[2])=varArray,byte(dbtpDriver),byte(dbtpAlias)));
      if DBType=dbtpDriver then
        for j:=VarArrayLowBound(av[2],1) to VarArrayHighBound(av[2],1) do
          ls.Values[av[2][j][1]]:=av[2][j][2];
      aDB[i]:=TFormPswd.CreateDatabase(DBType,av[1],DatabaseName);
      if DBType=dbtpAlias then nmDrv:=Session.GetAliasDriverName(av[1]) else nmDrv:=av[1];
      if MyVarType(av[3])=varString then pswd:=av[3] else pswd:='';
      FSetDBPrm(aDB[i],DBType,av[1],nmDrv,pswd,'','',CurrentDir,ls);
    end;
    try
      SetConnected(aDB[i],true); nDB:=i; result:=i;
    except
      SetStack(ost);
    end;
  finally
    ls.Free;
  end;
  DelStack;
end;

function c_dbclose(var av: array of variant): variant;
var i: longint;
begin
	AddStack('FrmPswd.c_dbclose');
  result:=null; i:=IsNilc(av[1],nDB);
  if InRange(i,low(aDB),high(aDB)) then FreeAndNil(aDB[i]);
  DelStack;
end;

function c_createtable(var av: array of variant): variant;
begin
	AddStack('FrmPswd.c_createtable');
  result:=CreateTable(av[1],IsNilc(av[2],''),IsNilc(av[3],false),DBGet(av,4));
  DelStack;
end;

{ TFormPswd }
procedure TFormPswd.FormCreate(Sender: TObject);
var dir: TFileName;
begin
	AddStack('TFormPswd.FormCreate',Self);
  inherited;
  PswdPrm.UserNum:=0; PswdPrm.UserCnt:=1; FirstUpdTimer:=true;
  lLogVid:=1; lLogKeys:=1; SetLength(aLog,1); lLog:=-1;
  CopyFrom(aModeFld,['FEDO','FEDOPRM']);
  CopyFrom(aPrivFld,['LMONO','LEDO','LEDOALL']);
  QryRegs:=Tmulquery.Create(Self); QryRegs.Arg[sTABLE]:=tREGS;
  QryUsers:=Tmulquery.Create(Self);
  with QryUsers do begin
    AfterOpen:=QryUsersAfterOpen; Arg[sTABLE]:=tUSERS; Arg[sC_LIST]:='*';
  end;
  QryMsg:=Tmulquery.Create(Self);
  with QryMsg do begin
  	Arg[sTABLE]:=tREGS; Arg[sC_LIST]:='*';
  end;
  BusyQuerys:=0; DelMaskFiles(ExeDir+'_QSQL*.*'); TSimpleGet.CreateOne;
  ProgPswd:=Self; FCanUpd:=true; WasUpd:=true; FSUAbort:=null; KeyPrmLocal:=0;
  ls:=SortStrListCreate; lsTblTrns:=SortStrListCreate;
  if nCnt=0 then begin
    oPrivProc:=MyTypes.PrivProc; MyTypes.PrivProc:=PrivProc;
  end;
  perform(WM_CNGPRIV,0,0);
  LsUpdNm:=TStringList.Create;
  LsWasUpd:=SortStrListCreate;
  DateNow:=Now; //TMulQuery.clearsql;
  Rec.CreateFld('DERTBL',ftString,DerTblGet.LenName,'');
  with TIniFileSave.Create do try
    // Последний входивший пользователь
    Rec['USER']:=ReadString(stpSection,stpLastUser);
  finally
    Free;
  end;
  if empty(Rec['USER']) then Rec['USER']:=sSYSDBA;
  EUser.Read([ferdSvOld]);
  //PnPsw.FldFocus:=EPswd;
  PnPsw.DoEnter; MainRebuild;
  dePrm.AssignGet(0,TDBPrmGet);
  dePrm.Param[0,deMask]:='Основные данные'+UnDelim+stpReg+UnDelim+ExeDir;
  if not lCopLast then TKeyLb.DelKeySt(dePrm.NmProc,[K_F7]);
  deCopyData.AssignGet('ALSFROM',TDBPrmGet);
  dePrm.AssignGet('Cop',TMultiGet);
  dir:=GetEnvironmentVariable('TEMP');
  with TIniFileData.Create do try
    if not empty(dir) then ForceDirectories(dir);
    Rec['CopDay']:=ReadInteger(stpSection,'CopDay');
    Rec['CopCnt']:=ReadInteger(stpSection,'CopCnt',1);
    Rec['CopDir']:=ReadString(stpSection,'CopDir','REZERV');
    FormLimit:=ReadInteger(stpSection,'FormLimit',FormLimit);
    FormLimTime:=ReadInteger(stpSection,'FormLimTime',FormLimTime);
    PswdPrm.NoSciLexer:=ReadBool(stpSection,'NoSciLexer');
    PswdPrm.BrFindAll:=ReadBool(stpSection,'BrFindAll',true);
  finally
    Free;
  end;
  Timer1:=TTimerLock.CreateProc(Timer1Timer,Self); ParamToKeys('PSWDKEYS');
  Inc(nCnt);
  DelStack;
end;

procedure TFormPswd.FormDestroy(Sender: TObject);
var s: string;
	ost,i: longint;
begin
	ost:=AddStack('TFormPswd.FormDestroy',Self);
  Dec(nCnt);
  if nCnt=0 then begin
    if NormalExit then begin
      if BusyQuerys<>0 then begin
        s:=Format('Осталось %d активных запросов (см. GetQuery):',[BusyQuerys]);
        for i:=0 to BusyQuerys-1 do IncD(s,CRLF+amq[i].s);
        OutStack(s);
      end;
      with PswdPrm do if nTrns>0 then begin
        OutStack(Format('Осталось %d активных транзакций',[nTrns]));
        NoTrnsStart:=false;
        while nTrns>0 do TrnsEnd([trnsCommit]);
      end;
    end;
    {for i:=low(amq) to high(amq) do with amq[i].q do begin
      Connection:=nil; Free;
    end;}
    CloseDB; MyTypes.PrivProc:=oPrivProc;
  end;
  if NormalExit and Assigned(PswdPrm.DBMain) then try
    GetQuery.commit; FreeQuery;
  except
    SetStack(ost);
  end;
	LsUpdNm.Free; LsWasUpd.Free;
  ls.Free; lsTblTrns.Free;
  if (nCnt=0) and Assigned(LsTabu) then begin
    TabuClearList(LsTabu); LsTabu:=nil;
  end;
  DBTrnsFree;
  SetConnected(PswdPrm.DBMain,false); FreeAndNil(PswdPrm.DBMain);
  FreeAndNil(MsgLst); DisposeNil(pointer(FTblSQLTimeOffs));
  igIcon.Free; igss.Free; FDBDBF.Free; lsTblSQLFree;
  inherited;
  if ProgPswd=Self then ProgPswd:=nil;
  DelStack;
end;

procedure TFormPswd.FormShow(Sender: TObject);
var r: TRect;
begin
	AddStack('TFormPswd.FormShow',Self);
  inherited;
  if WindowState=wsNormal then begin
    r:=SysWorkArea;
    SetBounds(r.Left+max(0,(r.Right-r.Left-Width) div 2),
      r.Top+max(0,(r.Bottom-r.Top-Height) div 2),Width,Height);
  end;
  if not MyFileExists(ExeDir+FileIdentProg) then SetStrFile(ExeDir+FileIdentProg,FileIdentProg);
  if KeyPrmLocal<>0 then begin
    KeyLb1.SetKey(KeyPrmLocal,'Параметры','Параметры рабочего места',
      ProcKey,'prmloc',kmEdit);
    KeyLb1.ReDrw;
  end;
  TTimerOne.CreateProc(Timer,Self);
  DelStack;
end;

procedure TFormPswd.Timer;
var usnm,pswd: string;
begin
	AddStack('TFormPswd.Timer',Self);
  if ParamByCode('GETUSER')='' then EPswd.SetFocus;
  usnm:=ParamByCode('USNM'); pswd:=GetPswdInit;
  if (usnm<>'') or (pswd<>'') then begin
    if usnm<>'' then EUser.VarValue:=usnm;
    if pswd<>'' then TPswdGet.GetFld(EPswd,pswdRead).VarValue:=pswd;
    KeyLb1.ExecKey(K_F10);
  end;
  DelStack;
end;

function TFormPswd.GetPswdInit;
begin
  AddStack('TFormPswd.GetPswdInit',Self);
  result:=ParamByCode('PSWD');
  DelStack;
end;

procedure TFormPswd.ProcKey;
begin
	AddStack('TFormPswd.ProcKey',Self);
  TSQLDM.Load; PrmLocal([''],[''],'',false);
  DelStack;
end;

procedure TFormPswd.EUserEnter(Sender: TObject);
begin
	AddStack('TFormPswd.EUserEnter',Self);
  KeyLb1.SetKey(K_Ctrl_F5,'','Установить имя пользователя по умолчанию ('+sSYSDBA+')',UserKeyProc,'userkey',kmNone);
  DelStack;
end;

procedure TFormPswd.EUserExit(Sender: TObject);
begin
	AddStack('TFormPswd.EUserExit',Self);
  KeyLb1.DelKey(K_All,'userkey');
  DelStack;
end;

procedure TFormPswd.UserKeyProc;
begin
  AddStack('TFormPswd.UserKeyProc',Self);
  EUser.Value:=sSYSDBA;
  DelStack;
end;

function TFormPswd.EUserCheck(Sender: TObject): Boolean;
begin
  AddStack('TFormPswd.EUserCheck',Self);
  result:=not empty(Rec['USER']);
  if not result then meserr('Введите имя пользователя.');
  DelStack;
end;

function TFormPswd.PnPswValid(Sender: TObject): Boolean;
var i: longint;
  f: TFld;
  wp: TWindowPlacement;
  fi: PMQFieldInfo;
begin
	AddStack('TFormPswd.PnPswValid',Self);
  inherited;
  FEChangeWhere:=fcwEdit;
  QryRegs.Connection:=PswdPrm.DBMain;
  QryUsers.Connection:=PswdPrm.DBMain; QryUsers.Part:=sSELECT_WHERE;
  QryMsg.Connection:=PswdPrm.DBMain;
  result:=mess_wait(['Поиск данных'],WaitConnected,true,'Загрузка программы');
  if result then begin
    if not StrToBoolean(PrmUser['NOSAVE']) then with TIniFileSave.Create do try
      WriteString(stpSection,stpLastUser,TrimRight(Rec['USER']));
    finally
      Free;
    end;
    wp.length:=SizeOf(wp); GetWindowPlacement(Handle,@wp);
    i:=Screen.Width+1-wp.rcNormalPosition.Left;
    Inc(wp.rcNormalPosition.Left,i); Inc(wp.rcNormalPosition.Right,i);
    wp.showCmd:=SW_HIDE; SetWindowPlacement(Handle,@wp); NoCngWState:=true;
    result:=true; ParamToKeys('KEYS'); DerIP:='';
    if Assigned(RecGlob) then if GetFieldInfo(tDER,fIP,fi) then DerIP:=Padr(GetIpAddress,fi.Size);
    SaveDer; ExecProg; SaveDer; DerIP:='';
    if RG.FldName(ibpType,f) then
      if f.Value>0 then with TIniFileData.Create do
        try
          WriteInteger(stpReg+'.'+drvINTRBASE,ibpType,RG[ibpType]-1);
        finally
          Free;
        end;
    UnRegistration;
    ProtSQLStrAdd(
      Format('РЕГИСТРАЦИЯ %d, завершение работы, пользователь ',[PswdPrm.UserNum])+Trim(UserName));
  end
  else begin
    PswdPrm.SuperUser:=false;
    if msg<>'' then mess_ok([msg]);
  end;
  if flClose then begin
    PnPsw.OnValid:=nil; Close;
  end;
  DelStack;
end;

procedure TFormPswd.WMProtSave;
var a: TArrStr;
  fo: PFileName;
  path,fn,ext: string;
  i,n: longint;
begin
  AddStack('TFormPswd.WMProtSave',Self);
  if (ProgPswd=Self) and (Message.Length>MByte) then
    if PswdPrm.nTrns=0 then SaveDer
    else begin
      fo:=Message.FileName; path:=ExtractFilePath(fo^); fn:=ExtractFileName(fo^); ext:=ExtractFileExt(fo^);
      FileWithOutExtSelf(fn); StuffStrSelf(fn,Length(fn),1,'_');
      GetMaskFiles(a,n,path+fn+StringOfChar('?',lDerNum)+ext,[],[msfSort]); 
      for i:=1 to n do if Int0(Substr(FileWithoutExt(a[i-1]),-lDerNum,lDerNum))<>i then begin
        n:=i; break;
      end;
      RnmFileAtr(fo^,path+fn+NumStr(n+1,lDerNum)+ext);
    end;
  DelStack;
end;

procedure ProtFileFree;
var i: longint;
begin
  AddStack('FrmPswd.ProtFileFree');
  if Assigned(lsProtFile) then begin
    for i:=0 to lsProtFile.Count-1 do ProtocolStrAdd(lsProtFile[i],'');
    FreeAndNil(lsProtFile);
  end;
  DelStack;
end;

function DerFile(const FileName: TFileName): TDerFile;
var s: string;
  l: longint;
begin
  AddStack('FrmPswd.DerFile');
  with result do begin
    s:=TrimRight(FileName); Ext:=ExtractFileExt(s); l:=Length(Ext);
    if l=0 then Name:=s else Name:=SubStr(s,1,-l);
    s:=RightStr(Name,lDerNum); Num:=Int0(s); IsNum := NumStr(Num,lDerNum)=s;
    Pref:=SubStr(Name,1,-IfThen(IsNum,lDerNum)-1);
  end;
  DelStack;
end;

procedure PrGetProtFiles(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
begin
  AddStack('FrmPswd.PrGetProtFiles');
  if GetFileSize(sr)<16*MByte
  then StringListVar(av[0]).AddObject(AnsiUpperCase(sr.Name),pointer(sr.Time))
  else DelFileAtr(ExeDir+sr.Name);
  DelStack;
end;

procedure StSaveDer(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var lsg: TStringList;
  r: TDerFile;
  procedure fTrns(const FileName: TFileName);
  var i,n: longint;
  begin
    AddStack('FrmPswd.StSaveDer.fTrns');
    r:=DerFile(FileName);
    if r.IsNum then
      if IntObjFindAdd(lsg,r.Pref,i,n)
      then lsg.Objects[i]:=pointer(max(r.Num,n))
      else lsg.Objects[i]:=pointer(r.Num);
    DelStack;
  end;
  procedure qfTrns;
  begin
    AddStack('FrmPswd.StSaveDer.qfTrns');
    fTrns(ProgPswd.CurQuery.Fields[0].AsString);
    DelStack;
  end;
var lsn: TStringList;
  lsd: TIntegerList;
  aapp: TArrBool;
  ip,s,fn: string;
  ost,i,j,lr,oNum: longint;
  bm: TBookMark;
  ss: TStringStream;
  t1,t2: Extended;
  a: TFloatChar;
  q: TMulQuery;
  oCon: boolean;
begin
  ost:=AddStack('FrmPswd.StSaveDer');
  with ProgPswd do begin
    ip:=DerIP; DerIP:='';
    if LockMode('Сохранение протоколов','FDER','FDER>0',1,0) then try
      lsn:=SortStrListCreate; lsd:=TIntegerList.Create([ilsSorted]); lsg:=SortStrListCreate;
      try
        q:=GetQuery(DbTrns);
        with GetQuery(q.Connection) do begin
          oCon:=Connected(Connection); SetConnected(Connection,true);
          for i:=1 to Length(aProtFileExt) do DelMaskFiles(ExeDir+'*.'+aProtFileExt[i]);
          if not CanPriv(PrivDesign,false) then begin
            t1 := Now-366 div 4;
            try
              DeleteTable(tDER,'TIMECNG<='+Vtos(t1));
            except
              on EDatabaseError do SetStack(ost);
            end;
          end;
          PartCount(tDER,[fFNAME,'TIMECNG'],fIP+'='+QQs(ip)); lr:=RecordCount;
          for j:=1 to lr do begin
            qfTrns;
            if Sender.SayStat('',r.Name,j/lr) then break;
            if Fields[2].AsInteger>1 then begin
              t1:=Fields[1].AsFloat;
              i:=FloatToText(a,t1,fvExtended,ffFixed,FloatMaxLen,FloatMaxDec); a[i]:=#0;
              a[i-1]:='0'; TextToFloat(a,t1,fvExtended);
              a[i-1]:='9'; TextToFloat(a,t2,fvExtended);
              q.DeleteTable(tDER,ArrayAsList([fIP+'='+QQs(ip),fFNAME+'='+QQs(Fields[0]),
                'TIMECNG>='+Vtos(t1),'TIMECNG<='+Vtos(t2)],sAND));
            end
            // Переименовать старый ненумерованный файл в нумерованный максимальным номером
            else if not r.IsNum then begin
              s:=r.Pref; bm:=GetBookMark;
              try
                First; oNum:=-1;
                while not Eof and (TrimRight(Fields[0].AsString)<s) do Next;
                while not Eof and AnsiStartsStr(s,TrimRight(Fields[0].AsString)) do begin
                  qfTrns;
                  if r.IsNum then oNum:=r.Num;
                  Next;
                end;
                GotoBookMark(bm);
              finally
                FreeBookMark(bm);
              end;
              qfTrns;
              q.UpdateTable(tDER,[fFNAME],
                [QQs(StrNum(s+'_',IfThen(oNum>=0,oNum+1),lDerNum)+r.Ext)],
                fIP+'='+QQs(ip)+sAND+fFNAME+'='+QQs(Fields[0]));
            end;
            Next;
          end;
          MaskFilesProc(ExeDir+'*.'+aProtFileExt[0],PrGetProtFiles,[LongInt(lsn)]); i:=lsn.Count;
          if i>0 then begin
            SetLength(aapp,i); TrueMemory(@aapp[0],i);
            for i:=0 to i-1 do lsd.Add(IntObj(lsn,i),i);
            First;
            for j:=1 to lr do begin
              if Fields[2].AsInteger=1 then
                if lsd.Find(DateTimeToFileDate(TDateTime(Fields[1].AsFloat)),i) then aapp[lsd.IntObj(i)]:=false;
              Next;
            end;
            PartSelect(tDER,[fIP,fFNAME,'TIMECNG',fTXT],fIP+'='+QQs(ip),fFNAME,'',false);
            RequestLive:=true; Open;
            if not Sender.SayStat('Сохранение протоколов (добавление)') then
              for i:=0 to lsn.Count-1 do begin
                if Sender.SayStat('',lsn[i],(i+1)/lsn.Count) then break;
                fn:=ExeDir+lsn[i];
                if aapp[i] then s:=GetStrFile(fn);
                if DelFileAtr(fn) then if aapp[i] then begin
                  Append; Fields[0].AsString:=ip;
                  fTrns(lsn[i]);
                  if IntObjFind(lsg,r.Pref,j) then oNum:=j+1 else oNum:=0;
                  Fields[1].AsString:=StrNum(r.Pref+'_',oNum,lDerNum)+r.Ext;
                  Fields[2].AsFloat:=FileDateToDateTime(IntObj(lsn,i));
                  ss:=TStringStream.Create(StrShifr(ZCompressStr(s)));
                  try
                    TBlobField(Fields[3]).LoadFromStream(ss);
                  finally
                    ss.Free;
                  end;
                  Post;
                end;
              end;
            RequestLive:=false;
          end;
          SetConnected(Connection,oCon);
        end;
        FreeQuery; FreeQuery;
      finally
        lsn.Free; lsd.Free; lsg.Free;
      end;
    finally
      UnLockMode('FDER');
    end;
    DerIP:=ip;
  end;
  DelStack;
end;

procedure TFormPswd.SaveDer;
begin
  AddStack('TFormPswd.SaveDer',Self);
  ProtFileFree;
  if DerIP<>'' then ShowStat('Сохранение протоколов (поиск)',StSaveDer);
  DelStack;
end;

function qDerIP(q: TMulQuery): string;
begin
  AddStack('FrmPswd.qDerIP');
  result:=Trim(q.Fields[0].AsString);
  if Assigned(DerIPTrans) then DerIPTrans(q,result);
  DelStack;
end;

function SortProt(List: TStringList; Index1, Index2: longint): longint;
  function sKey(Index: longint): string;
  var tp: TProtocolFileList0;
  begin
    AddStack('FrmPswd.SortProt.sKey');
    tp:=TProtocolFileList0(IntObj(List,Index));
    if tp=protUnDef then result:='1'+List[Index] else result:='0'+SpaceStr(tp,3);
    DelStack;
  end;
begin
  AddStack('FrmPswd.SortProt');
  result:=CompSign(sKey(Index1),sKey(Index2));
  DelStack;
end;

procedure TFormPswd.ViewDerTbl;
var s,s1: string;
  ls: TStringList;
  i,l: longint;
  tp: TProtocolFileList0;
begin
  AddStack('TFormPswd.ViewDerTbl',Self);
  if IsTable(tDER) then begin
    ls:=SortStrListCreate;
    with GetQuery do try
      PartSelect(tDER,fFNAME,'',fFNAME,fFNAME);
      if not Eof then begin
        while not Eof do begin
          ls.Add(DerFile(Fields[0].AsString).Pref+'_'); Next;
        end;
        l:=ls.Count-1;
        for i:=0 to l do begin
          tp:=high(aProtFile);
          while tp>protUnDef do if IsDerName(tp,ls[i]) then break else Dec(tp);
          ls.Objects[i]:=pointer(tp);
        end;
        ls.Sorted:=false; ls.CustomSort(SortProt); s:='';
        for i:=0 to l do begin
          tp:=TProtocolFileList0(IntObj(ls,i));
          if tp=protUnDef then s1:=ls[i] else s1:=aProtFile[tp,2];
          IncD(s,mniDlm+s1);
        end;
        deDer.Param['DERFILE',deMask]:=Copy(s,lmniDlm1,MaxInt);
        if DerTblGet.Items.Count=0 then GetTableNames(DerTblGet.Items);
        PartSelect(tDER,[fIP],'','',fIP); l:=0;
        DerIPGet.Items.BeginUpdate; DerIPGet.Items.Text:=CRLF;
        while not Eof do begin
          s:=qDerIP(CurQuery); MaxSelf(l,s); DerIPGet.Items.Add(s); Next;
        end;
        DerIPGet.Items.EndUpdate; DerIPGet.LenName:=l;
        deDer.Execute([Longint(ls)],'Просмотр протокола');
      end;
    finally
      FreeQuery; ls.Free;
    end;
  end;
  DelStack;
end;

procedure TFormPswd.deDerFldChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
var fl: boolean;
begin
  AddStack('TFormPswd.deDerFldChange',Self);
  fl:=IsDerName(protProg);
  deDer.SetReadOnly(['DERTBL','DERUSERNUM'],fl);
  deDer.SetReadOnly('DERBUILD',not fl);
  deDer.SetReadOnly('DERDO',not IsDerName(protProv));
  DelStack;
end;

function TFormPswd.deDerFldCheck(Sender: TObject): boolean;
begin
  AddStack('TFormPswd.deDerFldCheck',Self);
  F1GreatOrEqF2(Sender,'DERD2','DERD1',result);
  DelStack;
end;

procedure StDerEdit(Sender: TStat; const Params: array of variant; var Aborted: boolean);
const
  s1 = CRLF+'<<< '           ; l1 = Length(s1);
  s2 = ' >>>'+CRLF           ; l2 = Length(s2);
  sp = CRLF+'***************'; lp = Length(sp);
var sIs: set of TDerPrmList;
  ls: TStrStrList;
  odz: TDateTime;
  lf,IPMaxLen: longint;
  q: TMulQuery;
  av: TArrVar;
  function AddFile(fl: boolean): boolean;
  var p2: longint;
    od: TDateTime;
    s: string;
    procedure AddSect(p: longint);
    var ps: string;
      i,l: longint;
      function NextWord: string;
      var j: longint;
      begin
        AddStack('FrmPswd.StDerEdit.AddFile.AddSect.NextWord');
        while i<=l do
          if ps[i]>' ' then break else Inc(i);
        j:=i;
        while i<=l do
          if ps[i]>' ' then Inc(i) else break;
        result:=AnsiUpperCase(Copy(ps,j,i-j));
        DelStack;
      end;
    var j: TSQLExecType;
      n,n1: longint;
      fl,lcr,lTbl,lDo: boolean;
      sw,sun,stbl: string;
      a: TArrStr;
    label lend;
    begin
      AddStack('FrmPswd.StDerEdit.AddFile.AddSect');
      if p2>0 then
        if (od>=av[pDerD1]) and (od<av[pDerD2]) then begin
          ps:=Trim(Copy(s,p2,p-p2)); l:=Length(ps); lcr:=true; lTbl := pDerTbl in sIs;
          if l>0 then
            if ps[1]='[' then begin
              lcr:=false;
              if (pDerUN in sIs) or lTbl or (pDerDo in sIs) then begin
                i:=1; sun:=''; stbl:=''; lDo:=true;
                while i<=l do
                  if ps[i]='[' then begin
                    Inc(i); n:=i;
                    while i<=l do
                      if ps[i]=']' then begin
                        sw:=Copy(ps,n,i-n);
                        if sw='-' then lDo:=false
                        else if IsStrInt(sw) then sun:=sw
                        else stbl:=sw;
                        Inc(i); break;
                      end
                      else Inc(i);
                  end
                  else break;
                if pDerUN in sIs then if Trim(sun)<>av[pDerUN] then goto lend;
                if lTbl and (stbl<>'') then begin
                  lTbl:=false; LsArrDynamic(stbl,a,',',lsaSetLen);
                  if not AnsiMatchText(av[pDerTbl],a) then goto lend;
                end;
                if pDerDo in sIs then
                  if lDo<>av[pDerDo] then goto lend;
              end;
            end;
          if lTbl then begin
            i:=1; sw:=NextWord;
            if not lcr then sw:=NextWord;
            if AnsiFindText(sw,aSQLExec[1],n) then begin
              j:=TSQLExecType(n);
              if aSQLExec[2,j]<>'' then
                if NextWord<>aSQLExec[2,j] then goto lend;
              if NextWord<>av[pDerTbl] then goto lend;
            end;
          end;
          if pDerStr in sIs then
            if Pos(av[pDerStr],AnsiUpperCase(ps))=0 then goto lend;
          if pDerBuild in sIs then begin
            if IsPos(n,CRLF,ps) then Dec(n) else n:=Length(ps);
            fl:=true; n1:=0;
            for n:=n downto 1 do begin
              if fl then begin
                if ps[n]=')' then fl:=false;
              end
              else if n1=0 then begin
                if IsDigit(ps[n]) then n1:=n;
              end
              else if not IsDigit(ps[n]) then begin
                if Int0(Copy(ps,n+1,n1-n))<av[pDerBuild] then goto lend;
                break;
              end;
            end;
          end;
          if lcr then IncL(ps,CRLF);
          ls.IgnoreFindAdd(FormatDateTime('yyyymmddhhnnsszzz',od)+Padr(qDerIP(q),IPMaxLen),
            IfThenTrans(DerTrans,ps));
          Inc(lf,l);
    lend:
        end;
      DelStack;
    end;
  var oi,i,l: longint;
    function DateTimePart: Word;
    begin
      AddStack('FrmPswd.StDerEdit.AddFile.DateTimePart');
      while i<=l do
        if IsDigit(s[i]) then Inc(i) else break;
      result:=Int0(Copy(s,oi,i-oi)); Inc(i); oi:=i;
      DelStack;
    end;
  var ss: TStringStream;
    d: TDateTime;
    dy,dm,dd,dh,dn,ds,dz: Word;
    f1: boolean;
    ost,i1,i2,ip: longint;
  begin
    ost:=AddStack('FrmPswd.StDerEdit.AddFile');
    result:=true;
    if pDerIP in sIs then f1 := qDerIP(q)=av[pDerIP] else f1:=true;
    if f1 then begin
      ss:=TStringStream.Create('');
      try
        try
          TBlobField(q.Fields[2]).SaveToStream(ss); s:=CRLF+ZDecompressStr(StrDeshifr(ss.DataString));
        except
          if fl then raise;
          SetStack(ost); result:=false;
        end;
      finally
        ss.Free;
      end;
      if result then begin
        i:=1; l:=Length(s); i1:=1; i2:=1; ip:=1; p2:=0; od:=DateEmpty; dz:=0;
        while i<=l do begin
          if f1 then begin
            if s[i]<>s1[i1] then i1:=1;
            if s[i]=s1[i1] then
              if i1=l1 then begin
                Inc(i); i1:=i; oi:=i;
                dd:=DateTimePart; dm:=DateTimePart; dy:=DateTimePart;
                dh:=DateTimePart; dn:=DateTimePart; ds:=DateTimePart; Dec(i,2);
                if TryEncodeDateTime(dy,dm,dd,dh,dn,ds,0,d) then begin
                  if d=odz then begin
                    if dz<MSecsPerSec-1 then Inc(dz);
                    d:=EncodeDateTime(dy,dm,dd,dh,dn,ds,dz);
                  end
                  else begin
                    odz:=d; dz:=0;
                  end;
                  AddSect(i1-l1); od:=d; f1:=false;
                end;
                i1:=1;
              end
              else Inc(i1);
          end
          else begin
            if s[i]<>s2[i2] then i2:=1;
            if s[i]=s2[i2] then
              if i2=l2 then begin
                i2:=1; Inc(i); p2:=i; f1:=true;
              end
              else Inc(i2);
          end;
          if s[i]<>sp[ip] then ip:=1;
          if s[i]=sp[ip] then
            if ip=lp then begin
              ip:=i;
              while i<l do begin
                if s[i]+s[i+1]=CRLF then begin
                  Inc(i,lCRLF); break;
                end
                else Inc(i);
              end;
              if i<=l then begin
                oi:=i;
                dd:=DateTimePart; dm:=DateTimePart; dy:=DateTimePart;
                dh:=DateTimePart; dn:=DateTimePart; ds:=DateTimePart;
                if TryEncodeDateTime(dy,dm,dd,dh,dn,ds,0,d) then begin
                  if d=odz then begin
                    if dz<MSecsPerSec-1 then Inc(dz);
                    d:=EncodeDateTime(dy,dm,dd,dh,dn,ds,dz);
                  end
                  else begin
                    odz:=d; dz:=0;
                  end;
                  AddSect(ip-lp); od:=d; p2:=i;
                end;
                ip:=1;
              end;
            end
            else Inc(ip);
          Inc(i);
        end;
        AddSect(i);
      end;
    end;
    DelStack;
  end;
const ldt1=19;
var s,sd,si,w: string;
  fl: boolean;
  ldt: byte;
  i,j,ps,psd,pls,lr: longint;
  psd1: pointer;
  bm,bm1: TBookMark;
  res: PString;
begin
	AddStack('FrmPswd.StDerEdit');
  CopyFromVar(av,Params[0]); q:=PointerVar(Params[1]); IPMaxLen:=Params[2]; res:=PointerVar(Params[3]);
  lr:=Params[4];
  sIs:=[];
  for i:=1 to pDerCnt do if not IsNil(av[i]) then Include(sIs,i);
  if pDerTbl in sIs then TrimUpperSelf(av[pDerTbl]);
  if pDerStr in sIs then TrimUpperSelf(av[pDerStr]);
  if not(pDerD1 in sIs) then av[pDerD1]:=DateEmpty;
  if not(pDerD2 in sIs) then av[pDerD2]:=DateBig;
  if av[pDerD2]<DateBig then IncD(av[pDerD2],1);
  if pDerIP in sIs then TrimSelf(av[pDerIP]);
  if pDerUN in sIs then IntToStrSelf(av[pDerUN]);
  ls:=TStrStrList.Create(true,100);
  with q do
    try
      ls.Duplicates:=dupAccept; lf:=0; j:=0; w:=Arg[sWHERE]; First;
      while not(Eof or Sender.Aborted) do begin
        s:=Fields[0].AsString; bm:=nil; odz:=DateEmpty;
        try
          while not Eof and (Fields[0].AsString=s) do begin
            sd:=TrimRight(Fields[1].AsString);
            if Sender.SayStat('',s+': '+sd,(j+1)/lr) then break;
            if sd=aProtFile[protSQL,1]+'.'+aProtFileExt[0]
            then bm:=GetBookMark
            else for fl:=false to true do
              if AddFile(fl) then break
              else if not fl then begin
                sd:=Fields[3].AsString; Close; UnPrepare;
                PartSelect('','',w+sAND+Concat([fIP,fFNAME])+'>='+QQs(sd),Arg[sO_LIST]);
              end;
            Next; Inc(j);
          end;
          if Assigned(bm) then begin
            fl:=Eof; bm1:=GetBookMark;
            try
              GotoBookMark(bm); AddFile(false); GotoBookMark(bm1);
            finally
              FreeBookMark(bm1);
            end;
            if fl then Next;
          end;
        finally
          FreeBookMark(bm);
        end;
      end;
      if not Sender.Aborted then begin
        ldt:=l1+ldt1+l2+2+IPMaxLen-1;
        SetLength(res^,lf+ls.Count*(ldt+lCRLF)); ps:=PointerStr(res^); SetLength(sd,ldt); psd1:=pointer(sd);
        j:=0;
        for i:=1 to l1 do begin
          Inc(j); sd[j]:=s1[i];
        end;
        Inc(j,3); sd[j]:=DateSeparator;
        Inc(j,3); sd[j]:=DateSeparator;
        Inc(j,5); sd[j]:=' ';
        Inc(j,3); sd[j]:=TimeSeparator;
        Inc(j,3); sd[j]:=TimeSeparator;
        Inc(j,2);
        for i:=1 to l2-lCRLF do begin
          Inc(j); sd[j]:=s2[i];
        end;
        Inc(j); sd[j]:=' ';
        Inc(j); sd[j]:='[';
        Inc(j,IPMaxLen);
        Inc(j); sd[j]:=']';
        for i:=0 to ls.Count-1 do begin
          si:=ls.Value[i];
          psd:=longint(psd1)+l1; pls:=PointerStr(ls[i]);
          CopyMemory(pointer(psd),pointer(pls+6 ),2); Inc(psd,3);
          CopyMemory(pointer(psd),pointer(pls+4 ),2); Inc(psd,3);
          CopyMemory(pointer(psd),pointer(pls   ),4); Inc(psd,5);
          CopyMemory(pointer(psd),pointer(pls+8 ),2); Inc(psd,3);
          CopyMemory(pointer(psd),pointer(pls+10),2); Inc(psd,3);
          CopyMemory(pointer(psd),pointer(pls+12),2); Inc(psd,4+l2-lCRLF);
          CopyMemory(pointer(psd),pointer(pls+17),IPMaxLen);
          CopyMemory(pointer(ps),psd1,ldt); Inc(ps,ldt);
          lf:=Length(si); CopyMemory(pointer(ps),pointer(si),lf); Inc(ps,lf);
        end;
        SetLength(res^,ps-PointerStr(res^));
      end;
    finally
      ls.Free;
    end;
  DelStack;
end;

function c_deredit(var av: array of variant): variant;
var IPMaxLen,lr: longint;
  q: TMulQuery;
  s: string;
  fn: TFileName;
begin
	AddStack('FrmPswd.c_deredit');
  q:=TMulQuery.CreateConnection(Application.MainForm,DBGet(av,pDerDB));
  with q do
    try
      s:=fFNAME+sLIKE+QQs(av[pDerFile]+'%'); PartSelect(tDER,[fIP],s,'',fIP); IPMaxLen:=0;
      while not Eof do begin
        MaxSelf(IPMaxLen,qDerIP(q)); Next;
      end;
      PartSelect('',[fIP,fFNAME,fTXT,Concat([fIP,fFNAME])],s,GetList([fIP,fFNAME])); lr:=RecordCount;
      if ShowStat('Загрузка протоколов',StDerEdit,[VarArrayOf(av),longint(q),IPMaxLen,longint(@s),lr],lr,100)
      then result:=false
      else begin
        result:=not empty(s);
        if result then begin
          fn:=ExeDir+'PROTSQL.SUM'; SetStrFile(fn,s); AddPrnHead(av[pDerCapt]);
          TEdText.Execute(av[pDerCapt],s,'',nil,[edtxtReadOnly,edtxtWordWrap],TDerMemo,
            0,0,'',0,nil,'',nil,nil,fn);
          DelPrnHead;
        end;
      end;
    finally
      Free;
    end;
  DelStack;
end;

function TFormPswd.deDerPnlValid(Sender: TObject): boolean;
var av: array[0..pDerCnt] of variant;
  lDo: boolean;
begin
  AddStack('TFormPswd.deDerPnlValid',Self);
  result:=false; TPanelEdit(Sender).FldReadAll([ferdSvOld]);
  InitArr(av);
  av[pDerCapt]:='Протокол изменений';
  av[pDerFile]:=DerName;
  if not empty(Rec['DERTBL']) then begin
    av[pDerTbl]:=Rec['DERTBL']; IncD(av[pDerCapt],' в таблице '+Trim(av[pDerTbl]));
  end;
  if not empty(Rec['DERSTR']) then av[pDerStr]:=Rec['DERSTR'];
  av[pDerD1]:=Rec['DERD1']; av[pDerD2]:=Rec['DERD2'];
  if not empty(Rec['DERIP']) then av[pDerIP]:=Rec['DERIP'];
  if not empty(Rec['DERUSERNUM']) then av[pDerUN]:=Int0(Rec['DERUSERNUM']);
  av[pDerBuild]:=Rec['DERBUILD'];
  if IsDerName(protProv) then for lDo:=low(lDo) to high(lDo) do
    if not GetByte(Rec['DERDO'],byte(lDo)+1) then begin
      av[pDerDo]:=lDo; break;
    end;
  if not c_deredit(av) then meserr('Указанная информация не обнаружена.');
  DelStack;
end;

function TFormPswd.DerName;
begin
  AddStack('TFormPswd.DerName',Self);
  result:=StringListVar(deDer.Params[0])[Rec['DERFILE']-1];
  DelStack;
end;

function TFormPswd.IsDerName(tp: TProtocolFileList): boolean;
begin
  result:=IsDerName(tp,DerName);
end;

class function TFormPswd.IsDerName(tp: TProtocolFileList; const DerName: string): boolean;
begin
  AddStack('TFormPswd.IsDerName');
  result := DerName=StuffString(aProtFile[tp,1],Length(aProtFile[tp,1]),1,'_');
  DelStack;
end;

procedure PrDelMaskFiles(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
begin
	AddStack('FrmPswd.PrDelMaskFiles');
  if not DelFileAtr(av[0]+TrimUpper(sr.Name)) then begin
    mess_ok(['Ошибка удаления файла:',av[0]+TrimUpper(sr.Name)]); lDone:=false;
  end;
  DelStack;
end;

// Выполнение инициализационных клавиш
procedure TFormPswd.ParamToKeys;
var keys: string;
  a: TArrStr;
  i,j,k: longint;
begin
  AddStack('TFormPswd.ParamToKeys',Self);
  keys:=ParamByCode(name);
  if keys<>'' then begin
    i:=LsArrDynamic(keys,a,cDlmKey); SetLength(aKey,i); j:=0;
    for i:=i-1 downto 0 do begin
      k:=Int0(a[i]);
      if k>0 then begin
        aKey[j]:=k; Inc(j);
      end;
    end;
    if j>0 then begin
      SetLength(aKey,j); oFdpFormOnView:=FdpFormOnView; FdpFormOnView:=false;
      with TTimer.Create(Self) do begin
        Interval:=1; OnTimer:=TimerKeys;
      end;
    end;
  end;
  DelStack;
end;

procedure ProcControlsMsgKeys(Sender: TControl; const av: array of variant; var Done: boolean);
var l,k: longint;
begin
  AddStack('FrmPswd.ProcControlsMsgKeys');
  if Done then with TFormPswd(longint(av[0])) do begin
    l:=high(aKey);
    if l>=0 then begin
      k:=aKey[l];
      if Sender.Perform(WM_KEYINITPROG,k,ByteFalse)>0 then with TTimer(longint(av[1])) do begin
        Done:=false; SetLength(aKey,l); Enabled := l>0;
        if not Enabled then Free;
        Sender.Perform(WM_KEYINITPROG,k,ByteTrue);
        if Length(aKey)=0 then FdpFormOnView:=oFdpFormOnView;
      end;
    end;
  end;
  DelStack;
end;

procedure TFormPswd.TimerKeys;
var f: TForm;
begin
  AddStack('TFormPswd.TimerKeys',Self);
  if IsLastForm(f) then ProcControls(f,ProcControlsMsgKeys,[longint(Self),longint(Sender)]);
  DelStack;
end;

// Копирование программы на центральный компьютер
procedure StSave(Sender: TStat; const Params: array of variant; var Aborted: boolean);
begin
	AddStack('FrmPswd.StSave');
	CopyBufFile(Application.ExeName,ExeDir+NewExeName);
  with ProgPswd,GetQuery do begin
    Arg[sTABLE]:=tFILES; SetPart(sSELECT_ALL);
    SaveToServer(Sender,[NewExeName,'DB*.DBF','SETDBS.DBF','*.DCM','*.DFM','*.DPG','*.DLL','*.DIC',
      '*.HLP','*.CNT','*.SQ*','*.ICO'],CurQuery,ExeDir,[],nil,[srvCanDrop]);
    FreeQuery; DelFileAtr(ExeDir+NewExeName);
  end;
  DelStack;
end;

class procedure TFormPswd.SaveToServer;
var qs: TMulQuery;
	tbl: string;
  function pExec(const part: string): boolean;
  begin
    AddStack('TFormPswd.SaveToServer.pExec');
    result:=q.RequestLive;
    if not result then begin
      qs.Arg[sTABLE]:=tbl; qs.ExecPart(part);
    end;
    DelStack;
  end;
var i,j,lr: longint;
	a: TArrStr;
  memgk: longint;
  fqTXT: TField;
  lBreak: boolean;
  function CanRaise(ost: longint): boolean;
  begin
    result := not(srvCanDrop in Opt);
    if not result then begin
      SetStack(ost);
      lBreak:=false; q.Close; qs.DropTable(tbl); CreateTable(tbl,'',true); qs.DBFlush;
    end;
  end;
  function NewStat: boolean;
  var s,where: string;
  	ost: longint;
    ss: TStringStream;
  begin
  	ost:=AddStack('TFormPswd.SaveToServer.NewStat');
    result := Sender.SayStat('',a[i],j/lr) and (srvCanEsc in Opt);
    if not result then begin
      Inc(j); s:=GetStrFile(Path+a[i]);
      if q.RequestLive then begin
        ss:=TStringStream.Create(StrShifr(s));
        try
          try
            q.Edit; TBlobField(fqTXT).LoadFromStream(ss);
          except
            on EDatabaseError do if CanRaise(ost) then raise
          end;
        finally
          ss.Free;
        end;
      end
      else begin
        Inc(memgk); where:=qs.Arg[sWHERE]; TRecDB.SetMemValue(memgk,s,qs,[memNoDelPrior]);
        qs.Arg[sWHERE]:=where; qs.Arg[sC_LIST]:=fTXT; qs.Arg[sV_LIST]:=memgk;
      end;
      result:=not lBreak;
    end;
    DelStack;
  end;
var s: string;
  Obj: TMulQuery;
  ost: longint;
  fqNAME: TField;
label lend;
begin
	ost:=AddStack('TFormPswd.SaveToServer');
  qs:=TMulQuery.CreateConnection(Application.MainForm,q.Connection);
  try
  	lBreak:=true; tbl:=q.Arg[sTABLE]; lr:=0;
    for i:=low(aFile) to high(aFile) do GetMaskFiles(a,lr,Path+aFile[i],[],[msfAdd]);
    QuickSort(a,lr);
    repeat
      j:=1; lBreak:=true;
      with q do begin
        if DrvCan('blob') then begin
          RequestLive:=true; Obj:=q;
        end
        else begin
          with TRecDB.Create(Application.MainForm) do begin
            NameDB:=tbl; DelMemo(IfThen(Part<>sSELECT_ALL,string(Arg[sWHERE])),PrDelMemo); Free;
          end;
          memgk:=qs.PartMaxInt(tMEMO,fMGK); qs.MaxFldClear(tMEMO); Obj:=qs;
        end;
        if not IsTable(tbl) then begin
        	CreateTable(tbl,'',true); qs.DBFlush;
        end;
        if pExec(IfThen(Part=sSELECT_ALL,sD_TABLE,sDW_TABLE)) then begin
          Open; First; fqTXT:=FindField(fTXT); fqNAME:=FindField(fFNAME);
          while not Eof do begin
            s:=fqNAME.AsString;
            try
              Delete;
            except
              on EDatabaseError do begin
                SetStack(ost);
                try
                  qs.DeleteTable(tbl,fFNAME+'='+QQs(s));
                  while not Eof and (fqNAME.AsString=s) do Next;
                except
                  on EDatabaseError do if CanRaise(ost) then raise
                end;
              end;
            end;
            if not lBreak then goto lend;
          end;
        end;
        for i:=0 to lr-1 do begin
          if RequestLive then Append;
          if NewStat then goto lend;
          if RequestLive then FindField(fFNAME).AsString:=a[i]
          else begin
            qs.AddArgList(sC_LIST,fFNAME); qs.AddArgList(sV_LIST,QQs(a[i]));
          end;
          if Assigned(Proc) then Proc(Obj,a[i],av);
          if pExec(sI_TABLE) then Post;
        end;
        RequestLive:=false;
      end;
lend:
    until lBreak;
  finally
  	qs.Free;
  end;
  DelStack;
end;

// Загрузка программы с центрального компьютера
procedure StLoad(Sender: TStat; const Params: array of variant; var Aborted: boolean);
begin
	AddStack('FrmPswd.StLoad');
  with ProgPswd,GetQuery do begin
    Arg[sTABLE]:=tFILES; SetPart(sSELECT_ALL);
  	LoadFromServer(Sender,CurQuery,ExeDir,[]); FreeQuery; CopyFileOpt(ExeDir+NewExeName,ExeDir+New1ExeName);
  end;
  DelStack;
end;

class procedure TFormPswd.LoadFromServer;
var i,lr: longint;
	s: string;
  fqNAME,fqTXT: TField;
  ss: TStringStream;
  lsm: TMemGkList;
  a: TArrStr;
begin
	AddStack('TFormPswd.LoadFromServer');
  with q do begin
    Open; lr:=RecordCount;
    if DrvCan('blob') then lsm:=nil
    else begin
      CopyFrom(a,fTXT); lsm:=TMemGkList.Create(q,nil,@a);
    end;
    First; fqTXT:=FindField(fTXT); fqNAME:=FindField(fFNAME);
    for i:=1 to lr do begin
      s:=TrimRight(fqNAME.AsString);
      if Sender.SayStat('',s,i/lr) and CanEsc then break;
      if Assigned(lsm) then SetStrFile(Path+s,lsm.GetValue(fqTXT.AsInteger))
      else begin
        ss:=TStringStream.Create('');
        try
          TBlobField(fqTXT).SaveToStream(ss); ss.Seek(0,soFromBeginning);
          if not SetStrFile(Path+s,StrDeShifr(ss.ReadString(ss.Size)))
          then raise ELoadFromServer.Create(
            'Ошибка загрузки с центрального компьютера.'+CRLF
            +'Возможно, у Вас отсутствуют права на установку программ.');
        finally
          ss.Free;
        end;
      end;
      if Assigned(Proc) then Proc(q,s,av);
      Next;
    end;
  end;
  DelStack;
end;

// Проверка возможности доступа
procedure TFormPswd.WaitConnected;
  procedure SetIsUpd;
  var i: longint;
    ls: TMQFieldList;
  begin
    AddStack('TFormPswd.WaitConnected.SetIsUpd',Self);
    ls:=GetFieldList(tREGS);
    for i:=0 to lsUpdNm.Count-1 do lsUpdNm.Objects[i]:=pointer(ls.IsField(LsUpdNm[i]));
    DelStack;
  end;
var lReg: boolean;
  function Aborted(const ms: string = ''): boolean;
  begin
  	AddStack('TFormPswd.WaitConnected.Aborted',Self);
    if ms<>'' then Sender.SayCapt([ms]);
    if Application.Terminated then Sender.Abort;
    result:=Sender.Aborted;
    if result and lReg then begin
      SetConnected(true); UnRegistration;
    end;
    DelStack;
  end;
  function ConstraintChk(tp: TIndFileType): boolean;
  var res: boolean;
    function brk(usl: boolean): boolean;
    begin
    	AddStack('TFormPswd.WaitConnected.ConstraintChk.brk',Self);
      result:=not usl;
      if result then res:=true;
      DelStack;
    end;
  var i,j,n,l: longint;
    fl,lCrt: boolean;
    q: TMulQuery;
    ac,av,awv: TArrVar;
    s,w: string;
    a: TArrStr;
    atp: TArrFieldType;
    awf: TArrField;
  label lend;
  begin
  	AddStack('TFormPswd.WaitConnected.ConstraintChk',Self);
    res:=Sender.Aborted;
    if not res then if Assigned(ProcIndex) then begin
      n:=Length(aConstraintChk);
      if n>0 then MessagesHidden:=true;
      brk(ProcIndex(Sender,true,tp)); MessagesHidden:=false;
      if res then goto lend;
      if n>0 then begin
        lCrt:=true;
        for n:=0 to n-1 do with aConstraintChk[n] do begin
          fl:=true;
          with TMQIndexList.Create(DBMain,tbl,true) do try
            for i:=0 to Count-1 do if ArrStrComp(af,Indices(i)) then begin
              fl:=false; break;
            end;
          finally
            Free;
          end;
          if fl then begin
            if lCrt then begin
              if brk(ProcIndex(Sender,false,tp)) then goto lend;
              lCrt:=false;
            end;
            q:=GetQuery;
            with GetQuery do begin
              ac:=ArrStrToArrVar(af); s:=GetList(ac); j:=Length(ac); SetLength(awf,j); SetLength(awv,j);
              SetLength(ac,j shl 1); i:=high(ac);
              for j:=j-1 downto 0 do begin
                ac[i]:=QQs(','); Dec(i); ac[i]:=ac[j]; Dec(i);
              end;
              w:=q.Concat(ac); PartSelect(tbl,w,'','',s,true,sCountZv+'>1');
              if IsRecords then begin
                q.FldInSel(w,tbl,'','',[],@a,'',ProgPswd.CurQuery); ac:=nil;
                for i:=low(a) to high(a) do begin
                  PartSelect('',[],a[i],Arg[sC_LIST]); l:=FieldCount;
                  for j:=low(awf) to high(awf) do awf[j]:=FindField(af[j]);
                  if ac=nil then begin
                    SetLength(ac,l); SetLength(av,l); SetLength(atp,l);
                    for j:=0 to l-1 do begin
                      ac[j]:=Fields[j].FieldName; atp[j]:=UnDataType(Fields[j]);
                    end;
                  end;
                  while not Eof do begin
                    for j:=0 to l-1 do begin
                      av[j]:=Fields[j].Value;
                      if not IsNil(av[j]) then if atp[j]=ftString then QQsSelf(av[j]);
                    end;
                    w:='';
                    for j:=low(awf) to high(awf) do with awf[j] do begin
                      awv[j]:=Value; IncAnd(w,FieldName+IfThen(IsNil(awv[j]),sISNULL,'='+q.VarTos(awv[j],[vsQQ])));
                    end;
                    q.DeleteTable('',Copy(w,lAND1,MaxInt));
                    q.InsertTable('',ac,av); Next;
                    while not Eof do begin
                      fl:=true;
                      for j:=low(awf) to high(awf) do if awf[j].Value<>awv[j] then begin
                        fl:=false; break;
                      end;
                      if fl then Next else break;
                    end;
                  end;
                end;
              end;
            end;
            FreeQuery; FreeQuery;
          end;
        end;
        if not lCrt then if brk(ProcIndex(Sender,true,tp)) then goto lend;
      end;
  lend:
      if res then begin
        Sender.Abort; Aborted;
      end
      else Include(lCrtInd,tp);
    end;
    result:=res;
    DelStack;
  end;
var isReg: boolean;
  Vers: string;
  function RegMod(lLock: boolean): boolean;
	  procedure brk(usl: boolean);
    begin
    	AddStack('TFormPswd.WaitConnected.RegMod.brk',Self);
      result:=usl;
      if result and lLock then UnRegistration;
      DelStack;
    end;
  const aRegVers: array[1..11] of string = ('1.00 ','1.02 ','1.03 ','1.04 ','1.05 ','1.06 ','1.07 ','1.08 ','1.09 ','1.10 ','1.11 ');
  var i: longint;
  label lend;
  begin
  	AddStack('TFormPswd.WaitConnected.RegMod',Self);
  	result := lLock=isReg;
  	if result then begin
    	result := Vers<GetExeInfo.RegVers;
      if result then begin
        if lLock then begin
        	brk(not LockSuper('Версия регистрационных данных была изменена.'+CRLF
		      	+'Необходимо запустить программу администратору программы.'));
          if result then goto lend;
        end;
        if Aborted('Модификация регистрационных данных') then goto lend;
        RG.CloseRec; QryUsers.Close; SetConnected(false); SetConnected(true);
        if Aborted then goto lend;
        brk(not CopyDBDBF(Sender,[dbdbfSetDbs]));
        if Aborted then goto lend;
        aConstraintChk:=nil;
        brk(not RegModify(Sender,Vers,'',mdfBegin)); if result then goto lend;
        for i:=low(aRegVers) to high(aRegVers) do begin
          if Vers<aRegVers[i] then ModifyTable(true,aRegVers[i]);
          brk(not RegModify(Sender,Vers,aRegVers[i],mdfExec)); if result then goto lend;
        end;
        brk(not RegModify(Sender,Vers,'',mdfEnd)); if result then goto lend;
        brk(ConstraintChk(iftReg)); if result then goto lend;
				SetConnected(true);
        RG.OpenRec;
        if RG.Recno=0 then begin
          RG.NewRec; RG['UAbort']:=30; RG['UserCnt']:=1; RG['RepDeadLoc']:=10; RG.AppRec(false,1);
        end
        else RG['UAbort']:=max(10,longint(RG['UAbort']));
        RG['VERS']:=GetExeInfo.RegVers; RG.UpdateRec;
        // Добавление введённого пользователя по умолчанию
        if not isReg then with RUsers do begin
          OpenRec; NewRec; Value[fNAME]:=Rec['User']; Value['PASSW']:='!)@(#*$&%^';
          PrivDefault(true); AppRec; CloseRec; QryUsers.Close;
        end;
        if lLock then UnlockSuper;
      end;
      brk(Aborted); if result then goto lend;
    end;
    if RG.Active then begin
      PswdPrm.UserCnt:=max(longint(RG['UserCnt']),1); RG['UserCnt']:=PswdPrm.UserCnt; RG.UpdateRec;
    end;
    QryUsers.Open;
  lend:
  	DelStack;
  end;
  function MainMod(fl: TDBMainModify): boolean;
  begin
  	AddStack('TFormPswd.WaitConnected.MainMod',Self);
  	result := not DBMainModify(Sender,Vers,fl);
    if result then begin
    	Sender.Abort; Aborted;
    end;
    DelStack;
  end;
const aUpd: array[1..6] of string = (updCodeGet,updArrDef,updDDat,updTabu,updFormuls,updUserBmp);
  aTblKey: array[1..3] of record
    tbl: string;
    key: longint;
  end =
    ((tbl:tFAQ    ; key:K_Shift_F1)
    ,(tbl:tNOTE   ; key:K_Alt_N)
    ,(tbl:tLASTCNG; key:K_Alt_C)
    );
  acLogVid: array[1..logvCnt] of TLogVid =
    ((v:logvAppRec  ;nm:'добавление'                   ;ltbl:true)
    ,(v:logvEditRec ;nm:'редактирование'               ;ltbl:true)
    ,(v:logvDelRec  ;nm:'удаление'                     ;ltbl:true)
    ,(v:logvCngNum  ;nm:'смена кода'                   ;ltbl:true)
    ,(v:logvMDLoad  ;nm:'загрузка из основы'           ;ltbl:true)
    ,(v:logvLastVers;nm:'изменение установочной версии';ltbl:true)
    ,(v:logvDcmForm ;nm:'формирование документа')
    ,(v:logvInter   ;nm:'формулы')
    );
var ov,ct: longword;
  i: longint;
  s,s1,t: string;
  fl,oms{,lSetNewExeVers}: boolean;
  hnd: HMODULE;
  av: TDEPrmVar;
  lsf: TMQFieldList;
  f: TField;
label lend1,lend2;
begin
	AddStack('TFormPswd.WaitConnected',Self);
	RUsers.Connection:=PswdPrm.DBMain; RG.Connection:=PswdPrm.DBMain; RUsPrm.Connection:=PswdPrm.DBMain;
  RG.CloseRec;
	msg:=''; flClose:=true; lReg:=false;
  SetConnected(false);
  QryUsers.Arg[sWHERE]:=fNAME+'='+QQs(AnsiUpperCase(Rec['USER']));
  // Соединение с основной базой
  if Aborted('Подключение к основным данным') then goto lend1;
  if not DBConnect(PswdPrm.DBMain,'REG','Ошибка подключения к данным') then begin
  	Sender.Abort; goto lend1;
  end;
  if not IsTable(tUSERS) then begin
    msg:='Отсутствует таблица пользователей.'+CRLF
      +'Возможно, производится копирование из другого источника.';
  	Sender.Abort; goto lend1;
  end;
  // Перестройка базы регистрации
  RG.NoMemo:=true; RG.OpenRec;
  Vers:=IfThen(RG.Recno>0,string(RG['VERS']));
  if RG.Active then IsReg:=IsField(tREGS,fREGS) else isReg:=false;
  RegMod(false);
  try
    with GetQuery do begin
      if Aborted('Поиск пользователя "'+Trim(Rec['USER'])+'"') then goto lend2;
      ProtSQLStrAdd('"'+Caption+'" ('+StrExeVersion+')');
      // Поиск пользователя
      if QryUsers.Eof then begin
        msg:='Отсутствует пользователь с именем "'+Trim(Rec['USER'])+'"';
        PnPsw.FldFocus:=EUser; flClose:=false; Sender.Abort;
      end
      else begin
        PswdPrm.SuperUser:=CanPriv('SUPER');
        if (Trim(Rec['USER'])=sSYSDBA) and not PswdPrm.SuperUser then begin
          UpdateTable(tUSERS,['SUPER'],[true],fNAME+'='+QQs(sSYSDBA));
          QryUsers.Close; QryUsers.Open; PswdPrm.SuperUser:=CanPriv('SUPER');
        end;
        UserName:=PrmUser[fNAME];
        if TrimRight(Rec['PSWD'])<>DeShifrStr(TrimRight(PrmUser['PASSW'])) then begin
          msg:='Пароль неверный.'; PnPsw.FldFocus:=EPswd; flClose:=false; Sender.Abort;
        end
        else begin
          if Aborted('Удаление неработающих пользователей') then goto lend2;
          if DBDrvCan('DateTime')
          then FSUAbort:=StrNow+'-'+GetPart('minute',['count'],[RG['UAbort']])
          else FSUAbort:=RG['UAbort']/MinsPerDay;
          if not IsTable(tREGS) then RegsCreate;
          PartSelect(tREGS,[],RegDt('DU')+'<'+SUAbort);
          if IsRecords then begin
            OutStackQry('Удаление неработающих пользователей'); f:=FindField(RegDt);
            while not Eof do begin
              RegsDelProc(f); Next;
            end;
            oms:=MessagesHidden; MessagesHidden:=true;
            fl:=not ExecPart(sDW_TABLE,true); MessagesHidden:=oms;
            if fl then RegsCreate;
          end;
          if Aborted('Регистрация') then goto lend2;
          lReg:=Registration;
          if not lReg then Sender.Abort;
          SetIsUpd;
          if Aborted then goto lend2;
          // Версия EXE-файла
          s:=ParamByCode('oldexe',true);
          if empty(s) then DelFileAtr(ExeDir+NewExeName)
          else begin
            t:=ExeDir+New1ExeName;
            if not MyFileExists(t) then t:=ExeDir+NewExeName;
            ov:=My_pr.GetTickCount;
            while not CopyFileOpt(t,s) do begin
              ct:=My_pr.GetTickCount;
              // Больше 1 минуты не ждать
              if ct-ov>MSecsPerMin then raise ELoadFromServer.Create(
                'Ошибка загрузки с центрального компьютера.'+CRLF+
                'Возможно, у Вас отсутствуют права на установку программ.');
              while My_pr.GetTickCount-ct<MSecsPerSec do; // Подождать 1 секунду
            end;
            DelFileAtr(ExeDir+New1ExeName);
          end;
          LsUpdNm.Sorted:=true; MulQry.GetFieldNames(tREGS,ls);
          for i:=low(aUpd) to high(aUpd) do
            if ls.IndexOf(aUpd[i])<0 then FindDel(LsUpdNm,aUpd[i]) else LsUpdNm.Add(aUpd[i]);
          i:=LsUpdNm.Count; SetLength(aUpdZn,i);
          if i>0 then ZeroMemory(@aUpdZn[0],SizeOf(aUpdZn[0])*i);
          if Aborted('Проверка версии программы') then goto lend2;
          if Assigned(RecGlob) then begin
            ov:=RG['EXEVERS']; //lSetNewExeVers:=false;
            with GetExeInfo^ do if Build>ov then begin
              if LockSuper('Версия программы была изменена.'+CRLF
              +'Необходимо запустить программу администратору.') then
                try
                  if ShowStat('Копирование программы на центральный компьютер',StSave,false)
                  then Sender.Abort
                  else begin
                    RG['EXEVERS']:=Build; RG['EXENAME']:=ProductName; RG.UpdateRec;
                  end;
                  //lSetNewExeVers:=true;
                finally
                  UnlockSuper;
                end
              else Sender.Abort;
              if Aborted then goto lend2;
            end
            else if Build<ov then begin
              hnd:=GetModuleHandle('SciLexer.dpg');
              if hnd<>0 then FreeLibrary(hnd);
              ShowStat('Загрузка программы с центрального компьютера',StLoad,false);
              mess_ok(['Внимание!','Ранее было произведено обновление программы.',
                'Программа будет перезагружена.']);
              ShellExecute(0,nil,PChar(NewExeName),
                PChar('oldexe='+Application.ExeName+' '+ParamAllStr),
                PChar(ExeDir),SW_SHOW);
              Sender.Abort;
            end;
          end;
          Close;
          if Aborted then goto lend2;
          if RegMod(true) then Sender.Abort;
          lsf:=GetFieldList(tUSERS);
          i:=low(aPrivFld);
          while i<=high(aPrivFld) do
            if lsf.IndexOf(aPrivFld[i])<0 then ArrDel(aPrivFld,i) else Inc(i);
          RG.OpenRec;
          if Assigned(RecGlob) then begin
            s:=Trim(RG['EXENAME']); s1:=Trim(GetExeInfo.ProductName);
            if (s<>'') and (s1<>s) then begin
              mess_ok(['Программа "'+s1+'" не может быть соединена','с основными данными программы "'+s+'"']);
              Sender.Abort;
            end;
          end;
          if not empty(RG['PROG']) then Application.Title:=TrimRight(RG['PROG']);
          fl:=RG.IsField('REPDEADLOC');
          deGlob.Param['REPDEADLOC',deNoVisible]:=bStr[not fl];
          if fl then PswdPrm.RepDeadLock:=RG['REPDEADLOC'] else PswdPrm.RepDeadLock:=0;
          PartSelect(tGLOBSET,'ICON'); igssLoad(Application.Icon);
          SetIsUpd;
          Arg[sC_LIST]:=''; Arg[sV_LIST]:='';
          for i:=0 to LsUpdNm.Count-1 do if BoolObj(LsUpdNm,i) then begin
            AddArgList(sC_LIST,LsUpdNm[i]); AddArgList(sV_LIST,0);
          end;
          if Arg[sC_LIST]<>'' then UpdateTable(tREGS,RegDt+'='+SDateReg);
          TabuLoadList(LsTabu,UserName,CurQuery);
          // Соединение с основной базой
          if Aborted then goto lend2;
          if Assigned(RecGlob) then begin
            // Перестройка основной базы
            RecGlob.NoMemo:=true; RecGlob.OpenRec;
            Vers:=IfThen(RecGlob.Recno>0,string(RecGlob['VERS']));
            if Vers<GetExeInfo.MainVers then begin
              if not LockSuper('Версия основных данных была изменена.'+CRLF
                +'Необходимо запустить программу администратору.') then Sender.Abort;
              if Aborted then goto lend2;
              RecGlob.CloseRec; SetConnected(false);
              if Aborted('Модификация основных данных') then goto lend2;
              SetConnected(true);
              aConstraintChk:=nil;
              if MainMod(mdfBegin) then goto lend2;
              if Aborted then goto lend2;
              if not CopyDBDBF(Sender,[]) then goto lend2;
              if MainMod(mdfExec) then goto lend2;
              SetConnected(true); RecGlob.OpenRec;
              if RecGlob.Recno=0 then begin
                RecGlob.NewRec([newrCopy]); RecGlob.AppRec(false,1);
              end;
              RecGlob['VERS']:=GetExeInfo.MainVers; RecGlob.UpdateRec;
              if MainMod(mdfEnd) then goto lend2;
              if ConstraintChk(iftMain) then goto lend2;
              UnLockSuper;
            end;
            if Aborted then goto lend2;
          end;
          {if lSetNewExeVers then
            for i:=low(aSetNewExeVers) to high(aSetNewExeVers) do aSetNewExeVers[i];}
          // Восстановление после вылета
          if not DBDrvCan('Transaction') then begin
            PswdPrm.nTrns:=1; TrnsEnd;
          end;
          // Создание резервной копии
          if lCopLast and (Rec['CopDay']>0) then CopLast(true);
          if GetFieldList(tLOG,lsf) then begin
            if Tmulquery.CreateConnection(QryLog,Self,nil) then with QryLog do begin
              Arg[sTABLE]:=tLOG;
              SetArrayList(sC_LIST,[fLogD, 'KEYS',fLogNPRIM, 'PRIM', 'TBL', 'VID', 'DBEG',fLogUN, 'KEYSTACK','COMP'       ,'DREGS'        ,fIP                                            ,fUSERNUM        ,fUSERNAME    ]);
              SetArrayList(sV_LIST,[':D' ,':KEYS',':NPRIM' ,':PRIM',':TBL',':VID',':DBEG',':UN' ,':KEYSTACK',QQs(CompName),Double(DateReg),QQs(LeftStr(GetIpAddress,lsf.Fields(fIP).Size)),PswdPrm.UserNum ,QQs(UserName)]);
            end;
            with QryLog do begin
              SetPart(sI_TABLE); Prepare;
            end;
            lLogKeystack:=lsf.Fields('KEYSTACK').Size;
            lLogPrim:=lsf.Fields('PRIM').Size;
            TKeyLb.SetFixKey(K_Alt_L,'Журнал действий',FixKeyProc,kmHelp);
          end
          else FreeAndNil(QryLog);
          SetLength(aLogVid,logvCnt-lLogVid+1);
          SetLength(aLogKeys,logkCnt-lLogKeys+1);
          LogInit(acLogVid,[],0);
          if lRestart then begin
            Restart([]); Sender.Abort; goto lend2;
          end;
          RG.OpenRec;
          if (lCrtInd=[]) and StrToBoolean(RG['WASCOPY']) then
            if LockSuper('Данные были скопированы из другой базы.'+CRLF
            +'Необходимо запустить программу администратору программы.') then
              try
                if CreateIndex(Sender) then begin
                  RG['WASCOPY']:=bFalse; RG.UpdateRec;
                end
                else Sender.Abort;
              finally
                UnLockSuper;
              end
            else Sender.Abort;
          if Aborted then goto lend2;
          // Загрузка программы
          RG.NoMemo:=false; RG.AfterOpen;
          if RG.IsField(fSQLTBL) then lsTblSQLFill;
          if Assigned(RecGlob) then begin
            RecGlob.NoMemo:=false; RecGlob.AfterOpen;
          end;
          if Aborted('Загрузка данных') then goto lend2;
          if not LoadForms(Sender) then Sender.Abort;
          if Aborted then goto lend2;
          if MulQry.IsField(tUSERS,fFAMIL) then begin
            UserGet:=TCodeGet.Create(SQLDM);
            with UserGet do begin
              Connection:=DBMain; VName:='Users'; RVid:='Выбор пользователя';
              FieldsCode:=fNAME;
              with MulPar do begin
                Values[sCod_C]:=QQs('%'); Values[sTABLE]:=tUSERS; Values[sC_LIST]:='*';
                Values[sWHERE]:=fNAME+qCod_C;
              end;
              Part:=sSELECT_WORDER; OnFormIBList:=UserGetFormIBList; OnAfterList:=UserGetAfterList;
              OnStrName:=UserGetStrName; OnTransSeek:=UserGetTransSeek;
            end;
          end;
          DelFileAtr(ExeDir+'INF.DNF');
          if RG.IsField(fSQLTBL) then begin
            lsTblSQLFill; InitArr(av);
            av[deNameRec]:=Rec.NameRec;
            av[deNameRecFld]:='SQLTBL';
            TTblChkGet.AssignGetClass(av);
            GetTableNames(ls); ls.Sorted:=false;
            for i:=0 to ls.Count-1 do IncD(ls,i,'. '+GetPrim(ls[i],false));
            ls.Sorted:=true;
            av[deMask]:=UnDelim+ArrayAsList(aSQLExecCapt,mniDlm)+UnDelim
              +StrTran(Trim(ls.Text),CRLF,mniDlm);
            av[deNoReadOnly]:=true;
            av[deHeight]:=-1;
            av[deNewPage]:=true;
            deGlob.CreateFld(av);
            deGlob.Pages[0]:=StrNum('Общие'+UnDelim,byte(smColumns)+1);
            deGlob.Pages[1]:='Виды данных';
          end;
          deGlob.Param[ibpType,deMask]:=IBTypeDef+mniDlm+RadioMask(aIBType,0);
          deGlob.Param[ibpType,deNoVisible]:=bStr[not RG.IsField(ibpType)];
          ProtSQLStrAdd(
            Format('РЕГИСТРАЦИЯ %d, начало работы, пользователь ',[PswdPrm.UserNum])+Trim(UserName)+ProtDopInf);
          for i:=low(aTblKey) to high(aTblKey) do with aTblKey[i] do if IsTable(tbl) then begin
            s:=GetPrim(tbl,false);
            if s<>'' then TKeyLb.SetFixKey(key,s,FixKeyProc,kmHelp);
          end;
          TKeyLb.SetFixKey(K_Alt_Q,'Выполнить SQL-запрос',FixKeyProc,kmDesign);
          TKeyLb.SetFixKey(K_Alt_W,'Выполнить формулу',FixKeyProc,kmDesign);
          TKeyLb.SetFixKey(K_Alt_H,'Наименования таблиц и полей',FixKeyProc,kmDesign);
          perform(WM_CNGPRIV,0,0);
        end;
      end;
    end;
lend2:
    FreeQuery;
  except
    {on EDatabaseError do begin
      SetStack(ost);
      Mess_ok(['Основные данные отсутствуют']);
      ModalResult:=mrCancel; Close;
    end;}
    ModalResult:=mrCancel; raise
  end;
lend1:
  DelStack;
end;

class function TFormPswd.UserGetFormIBList;
begin
  AddStack('TFormPswd.UserGetFormIBList');
  CreateForm(TEdoUsLs,EdoUsLs); result:=EdoUsLs;
  DelStack;
end;

class procedure TFormPswd.UserGetAfterList;
begin
  AddStack('TFormPswd.UserGetFormIBList');
  FormFree(EdoUsLs);
  DelStack;
end;

class function TFormPswd.UserGetStrName;
var i: TFio;
  s: string;
begin
  AddStack('TFormPswd.UserGetStrName');
  result:='';
  for i:=low(aFio) to high(aFio) do IncD(result,Qry.FieldZN(aFio[i].f));
  s:=Qry.FieldZN('CEH');
  result:=Padr(DlmBetween(DelTrim(result),s,', '),Length(result)+2+Length(s));
  DelStack;
end;

class function TFormPswd.UserGetTransSeek;
begin
	AddStack('TFormPswd.UserGetTransSeek');
	result:=Padr(TrimLeft(Value),Size);
  DelStack;
end;

function TFormPswd.ProtDopInf;
begin
  result:='';
end;

procedure TFormPswd.Notification;
begin
  AddStack('TFormPswd.Notification',Self);
	inherited Notification(AComponent,Operation);
  if (AComponent=MsgLst) and (Operation=opRemove) then MsgLst:=nil;
  DelStack;
end;

procedure TFormPswd.ConstraintChkAdd;
var i: longint;
begin
  AddStack('TFormPswd.ConstraintChkAdd',Self);
  i:=Length(aConstraintChk); SetLength(aConstraintChk,i+1);
  with aConstraintChk[i] do begin
    tbl:=cTbl; CopyFrom(af,caf);
  end;
  DelStack;
end;

procedure TFormPswd.lsTblSQLFill;
var s: string;
  j: TSQLExecType;
  a: TSQLExecStr;
begin
  AddStack('TFormPswd.lsTblSQLFill',Self);
  s:=Trim(RG[fSQLTBL]);
  if empty(s) then lsTblSQLFree
  else with PswdPrm do begin
    LsArrFill(s,a,dlmSQLExec);
    if not Assigned(lsTblSQL) then New(lsTblSQL);
    for j:=low(lsTblSQL^) to high(lsTblSQL^) do LsArrDynamic(a[j],lsTblSQL[j],dlmSQLTbl,[lsaSetLen,lsaSort]);
  end;
  DelStack;
end;

procedure TFormPswd.lsTblSQLFree;
begin
  AddStack('TFormPswd.lsTblSQLFree',Self);
  with PswdPrm do if Assigned(lsTblSQL) then begin
    Dispose(lsTblSQL); lsTblSQL:=nil;
  end;
  DelStack;
end;

class function TFormPswd.DBConnect;
const NetTrans = REGSTR_PATH_CLASS+'\NetTrans';
var ost,i,j,NetResult: longint;
	nmDrv,nmUser,nmServ,nmpUser,s,s1,t,AliasName,DriverName: string;
  noAlias,noDrv,noTCP,lClient,fl: boolean;
  NetHandle: THandle;
  a: array[1..4] of string;
  ap: TArrSQLPath;
  ls: TStringList;
  lIB: boolean;
begin
  ost:=AddStack('TFormPswd.DBConnect');
  result:=true; TSQLDM.Load;
  if SectIni<>'' then SetConnected(db,false);
  while not Connected(db) and result do begin
  	if SectIni<>'' then SetDBPrm(db,SectIni,ExeDir);
    try
      SetConnected(db,true);
    except
      SetStack(ost);
      if MsgErr='' then result:=false
      else begin
        ls:=SortStrListCreate;
        try
          nmUser:=''; noAlias:=false; noDrv:=false; s1:='';
          lIB := db is TIBDatabase;
          AliasName:=GetDBAliasName(db); DriverName:=GetDBDriverName(db); nmpUser:=GetDBUserName(db);
          if NoBDE and not lIB then s:='необходима установка дополнительной программы BDE'
          else begin
            if empty(AliasName) then begin
              if not lIB then begin
                Session.GetDriverNames(ls); noDrv := ls.IndexOf(DriverName)<0;
              end;
              if not noDrv then begin
                nmDrv:=DriverName; nmUser:=GetDBParams(db).Values[nmpUser]; nmServ:=GetDBName(db);
              end;
            end
            else begin
              Session.GetAliasNames(ls); noAlias := ls.IndexOf(AliasName)<0;
              if not noAlias then begin
                nmDrv:=Session.GetAliasDriverName(AliasName);
                Session.GetAliasParams(AliasName,ls); nmUser:=ls.Values[nmpUser]; nmServ:=ls.Values[ibpServerName];
              end;
            end;
            TrimSelf(nmUser); lClient := not IsSQLLocalPath(nmServ,@ap);
            if noAlias
              then s:=IfThen(empty(AliasName),'не введено наименование псевдонима.',
                'отсутствует псевдоним "'+AliasName+'"')
            else if noDrv
              then s:=IfThen(empty(DriverName),'не введено наименование драйвера.',
              'отсутствует драйвер "'+DriverName+'"')
            else if (nmDrv<>drvSTANDARD) and (nmUser='')
              then s:='не введено имя пользователя'
            else begin
              s:=''; fl := (nmDrv<>drvINTRBASE) or lClient;
              if not fl then begin
                for j:=low(aResProcServer) to high(aResProcServer) do
                  if IsResProcess(aResProcServer[j]) then begin
                    fl:=true; break;
                  end;
                if not fl then begin
                  s:='не установлено или не запущено одно из следующих приложений:';
                  for j:=low(aResProcServer) to high(aResProcServer) do
                    IncD(s,CRLF+'- '+aResProcessName[aResProcServer[j]]);
                end;
              end;
              if fl then begin
                s1:=IfThen(nmDrv<>drvSTANDARD,'- отсутствует пользователь "'+nmUser+'"'+CRLF
                  +'- пароль для пользователя "'+nmUser+'" введён неверно'+CRLF)
                  +'- расположение данных введено неверно'+CRLF
                  +'- отсутствует связь с данными.';
                if (nmDrv<>drvSTANDARD) and lClient then begin
                  NetResult:=WNetOpenEnum(RESOURCE_GLOBALNET,RESOURCETYPE_DISK,0,nil,NetHandle);
                  case NetResult of
                    NO_ERROR: begin
                      WNetCloseEnum(NetHandle);
                      if Win32Platform=VER_PLATFORM_WIN32_NT then begin
                        t:=GetIpAddress; fl := t<>'';
                        if not fl then begin
                          s:='отсутствует сетевой протокол TCP/IP или IP-адрес'; s1:='';
                        end;
                      end
                      else with GRegistry do begin
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
                        fl:=false;
                        if noTCP then begin
                          s:='отсутствует сетевой протокол TCP/IP'; s1:='';
                        end
                        else if t='' then begin
                          s:='отсутствует IP-адрес'; s1:='';
                        end
                        else fl:=true;
                      end;
                      if fl then
                        if MyFileExists(FileServices) then with TClientSocket.Create(Application.MainForm) do
                          try
                            Host:=ap.IP; ClientType:=ctBlocking; Port:=IfThen(empty(ap.Port),139,Int0(ap.Port));
                            try
                              Open; Close;
                              with TServicesList.Create do
                                try
                                  if nPortIB>=0 then begin
                                    Port:=StrToService(Strings[nPortIB]).Port; noTCP := Port=0;
                                    try
                                      Open; Close;
                                    except
                                      on ESocketError do begin
                                        SetStack(ost);
                                        s1:=ArrayAsList(
                                          ['- на центральном компьютере "'+Host+'" не загружен Interbase'
                                          ,'- номер порта Interbase на центральном компьютере "'+Host+StrNum('" не равен ',Port)
                                          ,'  (редактирование номера порта Interbase - см. "Управление программами")'
                                          ],CRLF);
                                      end;
                                    end;
                                    if noTCP then begin
                                      s1:=''; SetPortIB('Отсутствует номер порта Interbase');
                                    end;
                                  end;
                                  if ChkReboot then result:=false;
                                finally
                                  Free;
                                end;
                            except
                              on ESocketError do begin
                                SetStack(ost);
                                s:='нет доступа к центральному компьютеру "'+Host+'"'
                                  +IfThen(ap.Port<>'',', порт '+ap.Port);
                                s1:='';
                              end;
                            end;
                          finally
                            Free;
                          end;
                    end;
                    ERROR_NO_NETWORK: begin
                      s:='сеть недоступна'; s1:='';
                    end;
                    ERROR_NOT_LOGGED_ON:
                      if Ask(['Ваш компьютер не зарегистрирован в сети.',
                      'Причина: отказ от ввода пароля при загрузке системы.','',
                      'Повторить ввод пароля ?']) then
                        if ReBoot(EWX_LOGOFF) then result:=false
                        else mess_ok(['Ошибка перезапуска системы для ввода пароля.',
                          'Произведите перезапуск системы для ввода пароля вручную.'])
                      else s1:='';
                  else
                    s:=StrNum('Код сетевой ошибки: ',NetResult); s1:='';
                  end;
                end;
              end;
            end;
          end;
          if result then begin
            MsgDlg(MsgErr+IfThen(s='','.',':'+CRLF+s)
              +IfThen(s1<>'',CRLF+CRLF+'Возможные причины:'+CRLF+s1));
            if Assigned(ProgPswd) then if db=ProgPswd.PswdPrm.DBMain then ProgPswd.flClose:=false;
            result:=false;
          end;
        finally
          ls.Free;
        end;
      end;
    end;
  end;
  DelStack;
end;

class function TFormPswd.SetDBPrm;
var sect,nmAls,nmDrv: string;
  ls: TStrings;
  DBType: TDBTypeList;
  f: TIniFileData;
begin
  AddStack('TFormPswd.SetDBPrm');
  ls:=TStringList.Create; f:=TIniFileData.Create;
  try
    sect:=IfThen(BegSetup,stpSection+'.')+SectIni; TDBPrmGet.CorrPrm(f,sect);
    DBType:=TDBTypeList(f.ReadInteger(sect,stpDatType,byte(dbtpDriver)));
    if DBType=dbtpAlias then begin
      nmAls:=f.ReadString(sect,stpDatAlias); nmDrv:=Session.GetAliasDriverName(nmAls);
    end
    else begin
      nmAls:=''; nmDrv:=f.ReadString(sect,stpDatDriver);
    end;
    f.ReadSectionValues(sect+'.'+nmDrv,ls);
    result:=FSetDBPrm(db,DBType,nmAls,nmDrv,DeShifrStr(f.ReadString(sect,stpDatPswd)),
      f.ReadString(sect+'.'+nmDrv,ibpFBLocal),f.ReadString(sect+'.'+nmDrv,ibpPort),DirDefault,ls,pPath);
  finally
    ls.Free; f.Free;
  end;
  DelStack;
end;

class function TFormPswd.CreateDatabase(const SectIni,DatabaseName: string;
  IBTypeDefault: boolean = true): TComponent;
var DatType: TDBTypeList;
  DatDriver,sect: string;
  IBType: TInterbaseType;
begin
  AddStack('TFormPswd.CreateDatabase(i)');
  IBType:=InterbaseType;
  if SectIni='' then begin
    DatType:=dbtpDriver; DatDriver:=drvINTRBASE;
  end
  else begin
    sect:=stpSection+'.'+SectIni;
    with TIniFileData.Create do
      try
        DatType:=TDBTypeList(ReadInteger(sect,stpDatType,byte(dbtpDriver)));
        DatDriver:=ReadString(sect,stpDatDriver);
        if not IBTypeDefault then IBType:=TInterbaseType(ReadInteger(sect+'.'+drvINTRBASE,ibpType));
      finally
        Free;
      end;
  end;
  result:=CreateDatabase(DatType,DatDriver,DatabaseName,IBType);
  DelStack;
end;

class function TFormPswd.CreateDatabase(DatType: TDBTypeList; const DatDriver,DatabaseName: string;
  IBType: TInterbaseType = ibtFIB): TComponent;
var IBTrns: TpFIBTransaction;
  fl: boolean;
begin
  AddStack('TFormPswd.CreateDatabase');
  fl:=false; 
  if DatType=dbtpDriver then
    if DatDriver=drvINTRBASE then fl := IBType=ibtFIB;
  if fl then begin
    result:=TIBDatabase.Create(Application.MainForm);
    IBTrns:=TpFIBTransaction.Create(Application.MainForm);
    IBTrns.DefaultDatabase:=pointer(result);
    IBTrns.TPBMode:=tpbDefault;
    IBTrns.TRParams.Text:=ArrayAsList(['write','nowait','rec_version','read_committed'],CRLF);
    TIBDatabase(result).DefaultTransaction:=IBTrns;
  end
  else begin
	  result:=TDatabase.Create(Application.MainForm);
    TDatabase(result).DatabaseName:=DatabaseName;
  end;
  if result is TCustomConnection then TCustomConnection(result).LoginPrompt:=false;
  DelStack;
end;

function TFormPswd.RegModify;
begin
	result:=true;
end;

function TFormPswd.SUAbort;
begin
	AddStack('TFormPswd.SUAbort',Self);
	if DBDrvCan('DateTime') then result:=FSUAbort
  else begin
    result:=GetQuery.SQLDateTime(Now-FSUAbort); FreeQuery;
  end;
  DelStack;
end;

class function TFormPswd.PrDelMemo;
begin
	AddStack('TFormPswd.PrDelMemo');
  result := (fa=famMemo) and (nmf=fTXT);
  DelStack;
end;

function TFormPswd.LockExit;
begin
	AddStack('TFormPswd.LockExit',Self);
	with CurQuery do begin
  	ReOpen; result := Fields[0].AsInteger<PswdPrm.UserCnt-UserCntEndReserv; Close;
  end;
  DelStack;
end;

procedure TFormPswd.Timer1Timer;
var ols: PSQLExecArrStr;
  oCon: boolean;
begin
	AddStack('TFormPswd.Timer1Timer',Self);
  inherited;
  Timer1.Enabled:=false;
  if (Now-DateNow)*SecsPerDay<Timer1.Interval/2 then begin
    QryRegs.Connection:=DBTrns; QryMsg.Connection:=QryRegs.Connection;
    oCon:=Connected(QryRegs.Connection); SetConnected(QryRegs.Connection,true);
    // Обновление времени
    ols:=PswdPrm.lsTblSQL;
    try
      PswdPrm.lsTblSQL:=nil;
      with QryRegs do begin
        if not DrvCan('DateTime') then begin
          Arg[sV_LIST]:=StrNow; ExecPart(Part);
        end
        else ExecSQL;
      end;
    finally
      PswdPrm.lsTblSQL:=ols;
    end;
    // Поиск сообщений об обновлении
    if MsgGetUpd
    // Поиск строковых сообщений
    then begin
      LogVid:=logvDelRec;
      if TMsgLst.Execute(SDateReg,MsgLst,QryRegs.Connection)
      then LogWrite(tMSGS,'получатель:"'+Trim(UserName)
        +FormatDateTime('(dd.mm.yyyy hh:nn:ss:zzz)',DateReg)+'"');
      LogVid:=logvNone;
    end;
    MsgApplication(WM_NETSEL,0,0,true); ArrProcNone(aNetSelProc);
    if FirstUpdTimer then begin
			FirstUpdTimer:=false;
      with GetQuery do
        if PartCount(tREGS,StrNum(fUSERNUM+'=',PswdPrm.UserNum+1))>1 then begin
        	MsgDlg(['Ошибка регистрации в сети:',
            'существуют пользователи с таким же регистрационным номером.',
            'Выполнение программы прервано.']);
          Application.Terminate;
        end;
      FreeQuery;
    end;
    if PswdPrm.nTrns>0 then QryRegs.Commit(false);
    SetConnected(QryRegs.Connection,oCon);
    QryRegs.Connection:=PswdPrm.DBMain; QryMsg.Connection:=PswdPrm.DBMain; DateNow:=Now;
  end;
  Timer1.Enabled:=true;
  DelStack;
end;

function TFormPswd.DbTrns;
begin
  AddStack('TFormPswd.DbTrns',Self);
  if PswdPrm.nTrns=0 then result:=PswdPrm.DBMain
  else begin
    if not Assigned(FDBTrns) then begin
      FDBTrns:=CreateDatabase('REG','TRNS',false);
      if not DBConnect(FDBTrns,'REG','Ошибка подключения к данным') then raise Exception.Create(
        'Ошибка подключения к данным'+CRLF+'для работы во время транзакции.');
    end;
    result:=FDBTrns;
  end;
  DelStack;
end;

procedure TFormPswd.DBTrnsFree;
begin
  AddStack('TFormPswd.DBTrnsFree',Self);
  if Assigned(FDBTrns) then begin
    SetConnected(FDBTrns,false); DataSetsProc(FDBTrns,FDBTrnsFree);
    FreeAndNil(FDBTrns);
  end;
  DelStack;
end;

procedure TFormPswd.FDBTrnsFree;
begin
  AddStack('TFormPswd.FDBTrnsFree',Self);
  if IsClass(Sender,TComponent,pointer(Sender)) then
    if IsClass(TComponent(Sender).Owner,TMulQuery,pointer(Sender))
    then TMulQuery(Sender).Connection:=PswdPrm.DBMain;
  DelStack;
end;

function TFormPswd.MsgGetUpd;
begin
	AddStack('TFormPswd.MsgGetUpd',Self);
  QryMsg.Open; result:=DoGetUpd(QryMsg); QryMsg.Close;
  DelStack;
end;

// Установка пароля
procedure TFormPswd.SetPassword;
var so,sn: string;
begin
	AddStack('TFormPswd.SetPassword',Self);
  LogVid:=logvEditRec; so:=TrimRight(PrmUser['PASSW']); oPsw:=DeShifrStr(so);
  if dePswd.Execute('Установка пароля для входа в программу').Saved then begin
    sn:=ShifrStr(TrimRight(Rec['PSWD']));
    if sn<>so then begin
      LogFields.Clear; PrmUser['PASSW']:=sn;
    end;
  end;
  LogVid:=logvNone;
  DelStack;
end;

// Значение параметра для пользователя
function TFormPswd.GetPrmUser;
begin
	AddStack('TFormPswd.GetPrmUser',Self);
	QryUsers.Open; result:=QryUsers.FieldZn(Index);
  DelStack;
end;

procedure TFormPswd.SetPrmUser;
begin
	AddStack('TFormPswd.SetPrmUser',Self);
	if PrmUser[Index]<>Value then begin
    RUsers.OpenRec;
    if RUsers.Seek(RUsers.TblFldName(fNAME)+'='+QQs(UserName)) then begin
      RUsers[Index]:=Value; RUsers.UpdateRec(true); QryUsers.Close;
    end;
    RUsers.CloseRec;
	end;
  DelStack;
end;

function TFormPswd.CalcMode;
var f: TField;
  i: longint;
begin
  AddStack('TFormPswd.CalcMode',Self);
  result:='';
  with DataSet do begin
    if not empty(FieldZN('FEDO')) then DlmBetwSelf(result,'подпись ЭДО',',');
    if FindField('FEDOPRM',f) then begin
      i:=f.AsInteger;
      if i>0 then DlmBetwSelf(result,'параметры ЭДО'+IfThen(i<MaxInt,Format(' (док.%d)',[i])),',');
    end;
  end;
  DelStack;
end;

procedure TFormPswd.PnPswCngKey(Sender: TObject; var tb: TKeyBut);
begin
	AddStack('TFormPswd.PnPswCngKey',Self);
  inherited;
	with tb do case Key of
    K_F10: Caption:='Продолжить';
    K_Alt_Z: Caption:='';
  end;
  DelStack;
end;

// Редактирование прав пользователей
procedure TFormPswd.UserPrivEdit;
var i: longint;
  lsf: TMQFieldList;
begin
	AddStack('TFormPswd.UserPrivEdit',Self);
  GetQuery;
  if CreateForm(TPrivLst,PrivLst) then with PrivLst do begin
    PrivHeadX(''); tbl.HeadY.Clear;
    lsf:=GetFieldList(tUSERS);
    for i:=low(aPrivFld) to high(aPrivFld) do
      tbl.HeadY.Add(FRup(GetPrimFld(tUSERS,lsf,lsf.IndexOf(aPrivFld[i]))));
    with KeyLb1 do begin
      SetKeys([K_Enter,K_Space,K_Ins],'Отметить','Отметить ячейку',PrivEd,'priv',kmEdit,'SUPER');
      SetKeys([K_Plus,K_F2],'Отметить всех','Отметить все ячейки столбца',PrivEd,'priv',kmEdit,'SUPER');
      SetKeys([K_Minus,K_F3],'Снять отм. со всех','Снять отметку со всех ячеек столбца',PrivEd,'priv',kmEdit,'SUPER');
      SetKeys([K_Shift_F2,K_Ctrl_Plus],'','Отметить все ячейки строки',PrivEd,'priv',kmEdit,'SUPER');
      SetKeys([K_Shift_F3,K_Ctrl_Minus],'','Снять отметку со всех ячеек строки',PrivEd,'priv',kmEdit,'SUPER');
      //SetKey(K_Ctrl_Enter,'Смен.пользователя','Перезагрузить программу с указанным пользователем',PrivEd,'priv',kmList);
      if Assigned(LsTabu) then SetKey(K_F4,'Доп.права','Дополнительные права пользователя',PrivEd,'priv',kmList,'SUPER');
      SetKey(K_F5,'Редактировать','Редактировать пользователя',PrivEd,'priv',kmList,'SUPER');
      SetKey(K_F7,'Добавить','Добавить пользователя',PrivEd,'priv',kmList,'SUPER');
      SetKey(K_F8,'Удалить','Удалить пользователя',PrivEd,'priv',kmList,'SUPER');
      if IsField(tDCMBMP,fUSERNAME)
      then SetKey(K_Shift_F8,'Рисунки','Рисунки пользователя',PrivEd,'priv',kmList,'SUPER');
    end;
    tbl.OnFill:=PrivFill; MainRebuild;
  end;
  PrivLst.tbl.Fill(PrivLst.PrivUserX); PrivModified:=false; PrivSelfModified:=false;
  if LockSuper then try
    PrivLst.ShowModal; QryUsers.Close;
  finally
    UnLockSuper;
  end;
  if PrivSelfModified then begin
    QryUsers.ReOpen; MsgApplication(WM_CNGPRIV); SendUpd(updTabu,true); MsgApplication(WM_CNGTABU); 
  end;
  if PrivModified then ArrProcNone(aCngPriv);
  FormFree(PrivLst); FreeQuery;
  DelStack;
end;

procedure TFormPswd.SetPrivModified;
begin
  AddStack('TFormPswd.SetPrivModified',Self);
  if not PrivSelfModified then PrivSelfModified := TrimRight(nmus)=TrimRight(UserName);
  PrivModified:=true; 
  DelStack;
end;

procedure TFormPswd.WMCngPriv;
const a: array[1..10{$IFDEF PROF}+1{$ENDIF}] of longint =
  (K_Alt_G,K_Alt_H,K_Alt_M,K_Alt_O,K_Alt_S,K_Alt_Plus,K_Alt_Minus,K_Alt_Q,K_Alt_W,K_Alt_T{$IFDEF PROF},K_Alt_P{$ENDIF});
var lDesign: boolean;
  i: longint;
begin
  AddStack('TFormPswd.WMCngPriv',Self);
  inherited;
  lDesign:=CanPriv(PrivDesign);
  for i:=low(a) to high(a) do TKeyLb.FixKeyShow(a[i],lDesign);
  if Assigned(UserGet) then UserGet.ClearBuf;
  ArrProcNone(aCngSelfPriv);
  DelStack;
end;

procedure TFormPswd.PrivFill;
var i,j: longint;
begin
	AddStack('TFormPswd.PrivFill',Self);
	with CurQuery do begin
  	PartSelect('',[],'',fNAME); i:=0;
    while not Eof do begin
      for j:=low(aPrivFld) to high(aPrivFld) do
        PrivLst.tbl.DatCells[i,j]:=IfThen(StrToBoolean(CurQuery.FieldZN(aPrivFld[j])),prvIs,prvNo);
      Inc(i); Next;
    end;
  end;
  DelStack;
end;

procedure TFormPswd.PrivEd;
const afl: TArrBoolStr = (prvNo,prvIs);
var nmus: string;
  X,Y: Word;
  procedure SelX(fl: boolean);
  const ams: TArrBoolStr = ('Снять отметку со всех прав ?','Отметить все права ?');
  var i: longint;
  begin
  	AddStack('TFormPswd.PrivEd.SelX',Self);
    LogVid:=logvEditRec;
		with PrivLst,tbl,CurQuery do
      if Ask(['Пользователь: '+Trim(HeadX[X]),ams[fl]]) then begin
        RUsers.OpenRec;
        if RUsers.Seek(RUsers.TblFldName(fNAME)+'='+QQs(nmus)) then begin
          for i:=low(aPrivFld) to high(aPrivFld) do RUsers[aPrivFld[i]]:=bStr[fl];
          RUsers.UpdateRec(true); SetPrivModified(nmus);
          for i:=low(aPrivFld) to high(aPrivFld) do DatCells[X,i]:=afl[fl];
        end;
        RUsers.CloseRec;
      end;
    LogVid:=logvNone;
    DelStack;
  end;
  procedure cvList(fl: boolean);
  begin
    AddStack('TFormPswd.PrivEd.cvList',Self);
    with CurQuery do begin
      Arg[sC_LIST]:=aPrivFld[Y]; Arg[sV_LIST]:=fl;
    end;
    DelStack;
  end;
  procedure SelY(fl: boolean);
  const ams: TArrBoolStr = ('Снять отметку со всех пользователей ?','Отметить всех пользователей ?');
  var i: longint;
    q: TMulQuery;
    nmf: string;
    a: TArrStr;
  begin
  	AddStack('TFormPswd.PrivEd.SelY',Self);
    LogVid:=logvEditRec;
		with PrivLst,PrivLst.tbl do if Ask(['Право: '+Trim(HeadY[Y]),ams[fl]]) then begin
      cvList(fl); q:=CurQuery; nmf:=q.Arg[sC_LIST]; RUsers.OpenRec;
      with GetQuery do begin
        PartSelect(tUSERS,[fNAME,nmf,fRECNO],FldIsTrue(nmf,not fl));
        if IsRecords then begin
          SetLength(a,RecordCount);
          for i:=low(a) to high(a) do begin
            SetPrivModified(Fields[0].AsString);
            RUsers.GetFromQuery; RUsers[nmf]:=bStr[fl]; a[i]:=RUsers.LogPrimMod; Next;
          end;
          q.UpdateTable('',Arg[sWHERE]); RUsers.LogWrite(a);
        end;
      end;
      FreeQuery; RUsers.CloseRec;
      for i:=0 to HeadX.Count-1 do DatCells[i,Y]:=afl[fl];
    end;
    LogVid:=logvNone;
    DelStack;
  end;
var fl: boolean;
  s: string;
  r: TRecDB;
begin
	AddStack('TFormPswd.PrivEd',Self);
  with PrivLst,PrivLst.tbl do begin
    ColRowToXY(X,Y); nmus:=Padr(HeadX[X],Length(UserName));
    case Key of
      K_F4: if TabuExec(nmus) then if nmus=UserName then begin
        TabuLoadList(LsTabu,UserName,CurQuery); MsgApplication(WM_CNGTABU);
      end;
      K_F5: with RUsers do begin
        LogVid:=logvEditRec; OpenRec;
        if Seek(TblFldName(fNAME)+'='+QQs(nmus)) then begin
          fl:=true; UserCngProc(UserCanDel,[nmus,longint(@fl)]);
          if fl then deUser.Execute('Редактирование пользователя');
        end;
        CloseRec;
        LogVid:=logvNone;
      end;
      K_F7: with RUsers do begin
        LogVid:=logvAppRec; OpenRec; NewRec;
        deUser.Execute('Добавление пользователя');
        CloseRec;
        LogVid:=logvNone;
      end;
      K_F8: begin
        LogVid:=logvDelRec;
        if nmus=UserName
          then mess_ok(['Нельзя удалять пользователя "'+Trim(nmus)+'":',
          'Вы вошли в программу под этим именем.'])
        else if Trim(nmus)=sSYSDBA
          then meserr('Нельзя удалять администратора "'+sSYSDBA+'".')
        else with CurQuery do begin
          s:=Arg[sTABLE];
          if IsTable(tEDO) then with CurQuery do begin
            PartSelect(GetList([tEDOIN,tEDO]),
              [tEDOIN+'.VD',tEDOIN+'.COD',tEDOIN+'.'+fNAME,tEDOIN+'.PRIM',tEDOIN+'.D'],
              tEDO+'.'+fEDOIN+'='+tEDOIN+'.'+fEDOIN
              +sAND+FldIsTrue(tEDOIN+'.INARH',false)+sAND+tEDO+'.'+fUSERNAME+'='+QQs(nmus));
            fl:=Eof;
            if not fl then mess_ok(['В электронном документообороте есть документ,',
              'подписанный пользователем "'+Trim(nmus)+'"',
              'и неподписанный другими пользователями (не ушедший в архив).',
              EdoInCapt(Fields[0].AsInteger,Fields[1].AsString,Fields[2].AsString,Fields[3].AsString,
              Fields[4].AsFloat)])
          end
          else fl:=true;
          if fl then if UserCngProc(UserCanDel,[nmus]) then if Ask(['Удалить пользователя "'+Trim(nmus)+'" ?']) then with RUsers do begin
            OpenRec;
            if Seek(TblFldName(fNAME)+'='+QQs(nmus)) then DelRec('',[delLog]);
            CloseRec;
            if X=HeadX.Count-1 then Dec(X) else Inc(X);
            Close; Fill(PrivHeadX(HeadX[EnsureRange(X,0,HeadX.Count-1)]));
            r:=nil;
            if IsTable(tDOCPRM) then if not Assigned(RecName(tDOCPRM)) then begin
              TRecDB.Init(r,r,tDOCPRM); r.NameRec:=tDOCPRM;
            end;
            try
              UserCngProc(UserDel,['='+QQs(nmus)]);
            finally
              r.Free;
            end;
          end;
          Arg[sTABLE]:=s;
        end;
        LogVid:=logvNone;
      end;
      K_Shift_F8: TGFBmp.Execute(nmus);
      {K_Ctrl_Enter: if Ask(['Внимание!','Будет произведена перезагрузка программы.',
      	'Войти в программу под именем пользователя "'+Trim(nmus)+'" ?']) then Restart([],false,mrNo,nmus);}
    else
      if Inverted then case Key of
        K_F2,K_F3: Inc(Key,KEY_CNT*kshShift);
        K_Plus,K_Minus: Inc(Key,KEY_CNT*kshCtrl);
        K_Ctrl_Plus,K_Ctrl_Minus: Dec(Key,KEY_CNT*kshCtrl);
        K_Shift_F2,K_Shift_F3: Dec(Key,KEY_CNT*kshShift);
      end;
      case Key of
        K_Enter,K_Space,K_Ins: begin
          SetPrivModified(nmus);
          fl := DatCells[X,Y]=prvNo; cvList(fl);
          RUsers.OpenRec;
          if RUsers.Seek(RUsers.TblFldName(fNAME)+'='+QQs(nmus)) then begin
            LogVid:=logvEditRec; RUsers[CurQuery.Arg[sC_LIST]]:=bStr[fl]; RUsers.UpdateRec(true);
            LogVid:=logvNone;
          end;
          RUsers.CloseRec; DatCells[X,Y]:=IfThen(fl,prvIs,prvNo);
          if (Key=K_Ins) and (Row<RowCount-1) then IncRow;
        end;
        K_F2,K_Plus: SelX(true);
        K_F3,K_Minus: SelX(false);
        K_Shift_F2,K_Ctrl_Plus: SelY(true);
        K_Shift_F3,K_Ctrl_Minus: SelY(false);
      end;
    end;
  end;
  DelStack;
end;

procedure TFormPswd.UserTabu;
begin
end;

procedure TFormPswd.deUserFrmShow(Sender: TObject);
begin
	AddStack('TFormPswd.deUserFrmShow',Self);
  deUser.SetReadOnly([fNAME,'SUPER'],Trim(RUsers[fNAME])=sSYSDBA);
  DelStack;
end;

function TFormPswd.deUserFldCheck(Sender: TObject): Boolean;
begin
	AddStack('TFormPswd.deUserFldCheck',Self);
  KodCheck(Sender,fNAME,result);
  DelStack;
end;

function TFormPswd.deUserPnlValid(Sender: TObject): Boolean;
var nnm: string;
  Opt: TStrTableFillOpt;
  X,Y: Word;
begin
  AddStack('TFormPswd.deUserPnlValid',Self);
  Opt:=IfThen(RUsers.Recno>0,tbfTopLeft); nnm:=RUsers[fNAME];
  if tbfTopLeft in Opt then UserCngName(deUser.OldValue[fNAME],nnm) else PrivDefault(false);
  RUsers.AppUpdRec(true); CurQuery.Close; PrivLst.tbl.ColRowToXY(X,Y);
  PrivLst.tbl.Fill(PrivHeadX(nnm),Y,Opt); SetPrivModified(nnm); result:=true;
  DelStack;
end;

procedure TFormPswd.UserCngName;
begin
  AddStack('TFormPswd.UserCngName',Self);
  if TrimRight(nnm)<>TrimRight(onm) then begin
    GetQuery; UserCngProc(UserValid,['='+QQs(onm),QQs(nnm)]); FreeQuery;
  end;
  DelStack;
end;

procedure FUserCngAdd(var Dest: TArrUserCng; const Source: array of TUserCng);
var i,j: longint;
begin
  AddStack('FrmPswd.FUserCngAdd');
  j:=Length(Dest); i:=Length(Source); SetLength(Dest,j+i);
  for i:=0 to i-1 do begin
    Dest[j]:=Source[i]; Inc(j);
  end;
  DelStack;
end;

function TFormPswd.UserCngProc;
var i: longint;
  Dest: TArrUserCng;
begin
  AddStack('TFormPswd.UserCngProc',Self);
  result:=true; Dest:=nil; UserCngAdd(Dest,FUserCngAdd);
  for i:=low(Dest) to high(Dest) do with Dest[i] do if IsTable(tbl) then begin
    ReplVarSelf(nmf,fUSERNAME); Proc(Dest[i],av,result);
    if not result then break;
  end;
  DelStack;
end;

class procedure TFormPswd.UserCngAdd;
const
  Source: array[0..7] of TUserCng =
    ((tbl:tTABU   ; nmf:fNAME)
    ,(tbl:tDOCPRM)
    ,(tbl:tNOTE)
    ,(tbl:tUSPRM)
    ,(tbl:tEDO)
    ,(tbl:tEDO   ; nmf:'SKIPUSER')
    ,(tbl:tEDOORD                ; nodel:true)
    ,(tbl:tEDOUS                 ; nodel:true)
    );
begin
  AddStack('TFormPswd.UserCngAdd');
  PrAdd(Dest,Source);
  DelStack;
end;

procedure TFormPswd.UserValid;
begin
  AddStack('TFormPswd.UserValid',Self);
  with UserCng do CurQuery.UpdateTable(tbl,[nmf],[av[1]],nmf+av[0]);
  DelStack;
end;

class procedure TFormPswd.UserCanDel;
var s,nmus: string;
begin
  AddStack('TFormPswd.UserCanDel');
  with UserCng do if nodel then with TRecDB(RecName(tbl)) do begin
    nmus:=TrimRight(av[0]);
    if Seek(nmf+'='+QQs(nmus)) then begin
      s:=ArrayAsList(['Пользователь '+nmus+' используется в других данных.','Вид данных: '+GetPrim,
        StrTran(LogPrim,LogDlm,CRLF)],CRLF);
      if high(av)<1
      then meserr(s)
      else SetPBoolean(av[1],Ask([s,'Редактировать пользователя '+nmus+'?']));
      result:=false;
    end;
  end;
  DelStack;
end;

class procedure TFormPswd.UserDel;
begin
  AddStack('TFormPswd.UserDel');
  with UserCng do if not nodel then TRecDB.DeleteTable(tbl,nmf+av[0]);
  DelStack;
end;

procedure TFormPswd.DateRegSet;
begin
end;

procedure TFormPswd.PrivDefault;
var i: longint;
begin
  AddStack('TFormPswd.PrivDefault',Self);
  if lSuper then RUsers['SUPER']:=bTrue;
  for i:=low(aPrivFld) to high(aPrivFld) do RUsers[aPrivFld[i]]:=bTrue;
  DelStack;
end;

function TFormPswd.PrivHeadX;
var s: string;
  f: TField;
begin
  AddStack('TFormPswd.PrivHeadX',Self);
  with PrivLst,CurQuery do begin
    result:=0; PrivUserX:=0; PartSelect(tUSERS,[],'',fNAME); f:=FindField(fNAME); tbl.HeadX.Clear;
    while not Eof do begin
      s:=FieldAsVariant(f); tbl.HeadX.Add(s);
      if s=nmus then result:=tbl.HeadX.Count-1;
      if s=UserName then PrivUserX:=tbl.HeadX.Count-1;
      Next;
    end;
  end;
  DelStack;
end;

// Отправить сообщение об обновлении
procedure PswdSendUpd(const nmMsg: string; lSelf: boolean = false);
begin
  AddStack('FrmPswd.PswdSendUpd');
  ProgPswd.SendUpd(nmMsg,lSelf);
  DelStack;
end;

procedure TFormPswd.SendUpd(const nmMsg: string; lSelf: boolean = false);
begin
	SendUpd([nmMsg],lSelf);
end;

procedure TFormPswd.SendUpd(const aMsg: array of string; lSelf: boolean = false);
var i: longint;
begin
	AddStack('TFormPswd.SendUpd',Self);
  with GetQuery do begin
   	Arg[sC_LIST]:=''; Arg[sV_LIST]:='';
    for i:=low(aMsg) to high(aMsg) do begin
    	AddArgList(sC_LIST,aMsg[i]); AddArgList(sV_LIST,aMsg[i]+'+1');
    end;
    UpdateTable(tREGS,RegDt+'<>'+SDateReg);
    if lSelf then for i:=low(aMsg) to high(aMsg) do
      if FCanUpd then GetUpd(aMsg[i]) else LsWasUpd.Add(aMsg[i]);
  end;
  FreeQuery;
  DelStack;
end;

// Принять сообщение об обновлении
function TFormPswd.DoGetUpd;
var i,zn: longint;
	tm: TTimer;
begin
	AddStack('TFormPswd.DoGetUpd',Self);
	if FCanUpd then begin
    for i:=0 to LsUpdNm.Count-1 do if BoolObj(LsUpdNm,i) then begin
      zn:=q.FieldZn(LsUpdNm[i]);
      if zn<>aUpdZn[i] then begin
        GetUpd(LsUpdNm[i]); aUpdZn[i]:=zn;
      end;
    end
  end
  else WasUpd:=true;
  result:=not q.Eof;
  if not result then begin
  	tm:=TTimer.Create(Self);
  	with tm do
    	try
      	Interval:=30000; OnTimer:=TimerTerminate;
        OutStack('Вы удалены из программы администратором.');
		    mess_ok(['Вы удалены из программы администратором.','Выполнение программы прервано.']);
		    if Enabled then TimerTerminate(tm);
      finally
      	Free;
      end;
  end;
  DelStack;
end;

class procedure TFormPswd.TimerTerminate;
begin
  AddStack('TFormPswd.TimerTerminate');
  TTimer(Sender).Enabled:=false; Application.Terminate;
  DelStack;
end;

procedure TFormPswd.GetUpd;
begin
	AddStack('TFormPswd.GetUpd',Self);
	if nmMsg=updCodeGet then TCodeGet.ClearBufAll
  else if nmMsg=updArrDef then TRecDBDef.ClearArrDef
  else if nmMsg=updDDat then DDBufClearAll
  else if nmMsg=updTabu then begin
    TabuLoadList(LsTabu,UserName,GetQuery); FreeQuery;
  end
  else if nmMsg=updFormuls then DfrmClearCod
  else if nmMsg=updUserBmp then UserBmpClear
  ;MsgApplGetUpd(nmMsg);
  DelStack;
end;

procedure TFormPswd.SetCanUpd;
var i: longint;
  a: TArrStr;
begin
	AddStack('TFormPswd.SetCanUpd',Self);
	if FCanUpd<>Value then begin
    FCanUpd:=Value;
    if FCanUpd then begin
      if WasUpd then begin
        WasUpd:=false; MsgGetUpd;
      end;
      if LsWasUpd.Count>0 then begin
        SetLength(a,LsWasUpd.Count);
        for i:=low(a) to high(a) do a[i]:=LsWasUpd[i];
        LsWasUpd.Clear;
        for i:=low(a) to high(a) do GetUpd(a[i]);
      end;
    end;
  end;
  DelStack;
end;

procedure TFormPswd.RGAfterOpen(Sender: TObject);
begin
	AddStack('TFormPswd.RGAfterOpen',Self);
  (Sender as TRecDB).GotoRec(1);
  DelStack;
end;

procedure TFormPswd.SetInfoName;
var l: longint;
begin
	AddStack('TFormPswd.SetInfoName',Self);
  with GetQuery do begin
    Close; PartSelect(tINFO,fNAME); l:=Fields[0].Size;
    part:=IfThen(Eof,sI_TABLE,sU_TABLE);
    Arg[sC_LIST]:=fNAME; Arg[sV_LIST]:=QQs(Padr(s,l)); ExecPart(part);
  end;
  FreeQuery;
  DelStack;
end;

function TFormPswd.DBDBF;
begin
	AddStack('TFormPswd.DBDBF',Self);
  if Assigned(FDBDBF) then SetConnected(FDBDBF,false)
  else begin
    FDBDBF:=TDatabase.Create(Application.MainForm);
    FDBDBF.DatabaseName:='FDBDBF';
    FDBDBF.DriverName:=drvSTANDARD;
  end;
  FDBDBF.Params.Values[stpPath]:=IfThen(path='',ExeDir,path); result:=FDBDBF;
  //FDBDBF.Params.Values[stpDefaultDriver]:='FOXPRO';
  DelStack;
end;

// Регистрация
function TFormPswd.Registration;
const CntTmpNum = 8-Length(cTmpFile);
var s: string;
	i,j,un,ost: longint;
  ls: TIntegerList;
  f: TField;
  fl: boolean;
  fi: PMQFieldInfo;
label lend;
begin
	ost:=AddStack('TFormPswd.Registration',Self);
	result:=false;
	with PswdPrm do begin
    with GetQuery do
      while not result do begin
        // Проверка наличия администратора
        s:='FSUPER>0';
        try
          if GetPBoolean(aCreateRegs) then begin
            aCreateRegs:=nil; RegsCreate;
          end;
          PartSelect(tREGS,'FSUPER',s);
        except
          on EDatabaseError do begin
            SetStack(ost);
            try
              RegsCreate; PartSelect(tREGS,'FSUPER',s);
            except
              on EDatabaseError do begin
                SetStack(ost);
                if not SetPBoolean(aCreateRegs,true) then raise;
              end;
            end;
          end;
        end;
        if aCreateRegs<>nil then
          if aCreateRegs^ then goto lend;
        while true do begin
          Open; First;
          if Eof then break
          else if not LockExec('С программой работает администатор',Self,[lockReplF10],'',s)
          then goto lend;
          Close;
        end;
        // Проверка количества пользователей
        DeleteTable(tREGS,fUSERNUM+sISNULL);
        while true do begin
          if PartCount('')<UserCnt-UserCntEndReserv then break
          else if not LockExec(
            BracketInt('Количество пользователей в сети равно максимальному',UserCnt-UserCntEndReserv),
            Self,[lockReplF10,lockCanDel],'','',LockExit)
            then goto lend;
          Close;
        end;
        // Регистрация пользователя
        un:=-RandomRange(1,MaxInt);
        SetArrayList(sC_LIST,[fNAME        ,fUSERNUM,RegDt ,RegDt('DU')]);
        SetArrayList(sV_LIST,[QQs(UserName),un      ,StrNow,StrNow]);
        with MulQry.GetFieldList(tREGS) do begin
          if Fields('COMP',fi) then begin
            AddArgList(sC_LIST,'COMP'); AddArgList(sV_LIST,QQs(LeftStr(CompName,fi.Size)));
          end;
          if Fields(fIP,fi) then begin
            AddArgList(sC_LIST,fIP); AddArgList(sV_LIST,QQs(LeftStr(GetIpAddress,fi.Size)));
          end;
          if IsField('IDUPD') then begin
            AddArgList(sC_LIST,'IDUPD'); AddArgList(sV_LIST,IDUpd);
          end;
        end;
        Arg[sTABLE]:=tREGS; ExecPart(sI_TABLE);
        PartSelect('',RegDt,fUSERNUM+'='+Vtos(un));
        if Eof then begin
          meserr('Не удалось произвести регистрацию.'); goto lend;
        end;
        DateReg:=FieldZn(RegDt); DateRegSet; SDateReg:=SQLDateTime(DateReg); i:=100;
        while not result do begin
          ls:=TIntegerList.Create([ilsSorted]);
          try
            PartSelect('',[]); f:=FindField(fUSERNUM);
            OutStackQry('Список зарегистрированных пользователей');
            while not Eof do begin
              j:=f.AsInteger;
              if j>0 then ls.Add(j);
              Next;
            end;
            UserNum:=1;
            for j:=0 to ls.Count-1 do
              if ls[j]=UserNum then Inc(UserNum) else break;
          finally
            ls.Free;
          end;
          try
            Arg[sC_LIST]:=fUSERNUM; Arg[sV_LIST]:=UserNum;
            // FB2.0 и выше записывает "now" с мсек, а BDE не читает мсек
            if (DBMain is TDatabase) and (RegDt=fREGS) then begin
              AddArgList(sC_LIST,fREGS); AddArgList(sV_LIST,SDateReg);
            end;
            UpdateTable('',fUSERNUM+'='+Vtos(un)); result:=true;
          except
            on EDatabaseError do begin
              if i=0 then raise;
              SetStack(ost);
              Dec(i);
            end;
          end;
          PartSelect('',[]); fl:=false;
          if result then begin
            f:=FindField(fUSERNUM); result:=false;
            while not Eof do begin
              if f.AsInteger=UserNum then begin
                NotD(result);
                if not result then break;
              end;
              Next;
            end;
            if not result then begin
              meserr('Не удалось произвести регистрацию.'); fl:=true;
            end;
          end;
          Dec(UserNum);
          OutStackQry(Format('Регистрация %d %s: %s.',[UserNum,SDateReg,IfThen(result,'успешно','ошибка')]));
          Inc(UserNum);
          if fl then goto lend;
        end;
        result := UserNum<=UserCnt-UserCntEndReserv;
        if result then result:=PartCount0('','FSUPER>0');
        if not result then UnRegistration;
      end;
    Dec(UserNum);
    if result then begin
      if UserNum=0 then begin
        DelMaskFiles(ExeDir+cTmpFile+'.*');
        DelMaskFiles(ExeDir+cTmpFile+StringOfChar('?',CntTmpNum)+'.*');
      end;
      TmpFile:=cTmpFile+IfThen(UserNum>0,NumStr(UserNum,CntTmpNum));
      // Запуск таймера обновления времени
      Timer1.Interval:=IDUpd*MSecsPerSec;
      with QryRegs do begin
        Connection:=DBMain; UpdateTable('',[RegDt('DU')],[StrNow],RegDt+'='+SDateReg);
      end;
      with QryMsg do begin
        Connection:=DBMain; Arg[sWHERE]:=RegDt+'='+SDateReg; SetPart(sSELECT_WHERE);
      end;
      Timer1.Enabled:=true;
    end;
  end;
lend:
  FreeQuery;
	DelStack;
end;

procedure TFormPswd.UnRegistration;
begin
	AddStack('TFormPswd.UnRegistration',Self);
  RegsDelProc(SDateReg);
	with GetQuery do begin
  	Arg[sWHERE]:=RegDt+'='+SDateReg;
    Arg[sTABLE]:=tMSGS; ExecPart(sDW_TABLE);
    Arg[sTABLE]:=tREGS; ExecPart(sDW_TABLE);
  end;
  FreeQuery; Timer1.Enabled:=false;
  DelStack;
end;

procedure TFormPswd.RegsCreate;
var ls: TMQIndexList;
  i: longint;
begin
  AddStack('TFormPswd.RegsCreate',Self);
  ls:=TMQIndexList.Create(PswdPrm.DBMain,tREGS,true);
  try
    with GetQuery do begin
      for i:=0 to ls.Count-1 do begin
        SQLText('alter table regs drop constraint '+ls[i]); ExecSQL;
      end;
      DropTable(tREGS); ModifyTable(true,'',AnsiLowerCase(tREGS));
      for i:=0 to ls.Count-1 do begin
        SQLText('alter table regs add constraint '+ls[i]+' unique ('+ArrayAsList(ls.Indices(i),',')+')');
        ExecSQL;
      end;
    end;
    FreeQuery;
  finally
    ls.Free;
  end;
  DelStack;
end;

function TFormPswd.CopyDBDBF(Sender: TAsk; const tbl: string; CanEsc: boolean = true): boolean;
begin
	AddStack('TFormPswd.CopyDBDBF',Self);
  result:=CopyTable(DBDBF,PswdPrm.DBMain,tbl,ttDosToWin,[cptNoDbt]+IfThen(CanEsc,cptCanEsc));
  if not result then Sender.Abort;
  DelStack;
end;

function TFormPswd.CopyDBDBF(Sender: TAsk; Opt: TCopyDBDBFOpt = []): boolean;
begin
  result:=CopyDBDBF(Sender,aDbsTbl[dbdbfSetDbs in Opt].dbs,not(dbdbfNoCanEsc in Opt));
  if result then LsDBClearDB;
end;

type
  TPackList = class(TStringList)
  private
    a: array of record
      rcnt,rmax: longint;
      lSetDbs: boolean;
    end;
  end;

function SortRecordCount(List: TStringList; Index1,Index2: longint): longint;
begin
  AddStack('FrmPswd.SortRecordCount');
  with TPackList(List) do result:=CompSign(a[IntObj(List,Index2)].rcnt,a[IntObj(List,Index1)].rcnt);
  DelStack;
end;

procedure StPackTbl(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var t,f,w: string;
  q,qu,qu1: TMulQuery;
  i,ov,nv,lr: longint;
  po,pn: TObject;
  lMemo,lSetDbs,lTrns: boolean;
  a: array[1..2] of string;
  fa: TFldMemoAttr;
  Proc: TPackTblProc;
  aTbl: TArrStr;
  av: TArrVar;
begin
	AddStack('FrmPswd.StPackTbl');
  t:=Params[0]; lSetDbs:=Params[1]; q:=PointerVar(Params[2]); qu:=PointerVar(Params[3]);
  qu1:=PointerVar(Params[4]); lr:=Params[5]; f:=Params[6]; lMemo:=Params[7];
  w:=Params[8]; Proc:=TPackTblProc(PointerVar(Params[9]));
  qu.Arg[sTABLE]:=t; qu.Arg[sC_LIST]:=f; qu.Arg[sV_LIST]:=':N'; qu.Arg[sWHERE]:=f+'=:O';
  qu.SetPart(sUW_TABLE); qu.Prepare; po:=qu.ParamByName('O'); pn:=qu.ParamByName('N');
  fa:=TFldMemoAttr(AnsiIndexText(t,aMemoTbl));
  if lMemo
  then CopyFrom(aTbl,'')
  else aTbl:=nil;
  if Assigned(Proc) then begin
    av:=nil; Proc(pcktTbl,[t,f,longint(@aTbl)],av);
  end;
  lTrns := Length(aTbl)>0;
  with ProgPswd.CurQuery do begin
  	Last; q.PartSelect(t,f,f+'>0'+w,f,f); nv:=0;
    for i:=1 to lr do begin
    	if Sender.SayStat(i/lr) then break;
      while not q.Eof do begin
        Inc(nv);
        if q.Fields[0].AsInteger>nv then break;
        q.Next;
      end;
      if lTrns then begin
        if lMemo then begin
          LsArrFill(Fields[1].AsString,a,'.'); aTbl[0]:=a[1];
        end;
        if not TrnsStart(aTbl,1,nil,lSetDbs) then begin
          Aborted:=true; break;
        end;
      end;
      try
        if lTrns then if Assigned(Proc) then Proc(pcktBefore,[t,longint(qu1)],av);
        ov:=Fields[0].AsInteger; w:=Vtos(ov); qSetParamValue(po,w); qSetParamValue(pn,Vtos(nv));
        qu.ExecTry;
        if lTrns then begin
          if lMemo then begin
            IncL(a[2],aBegMem[fa]); qu1.UpdateTable(a[1],[a[2]],[nv],a[2]+'='+w);
          end;
          if Assigned(Proc) then Proc(pcktAfter,[t,longint(qu1),ov,nv],av);
          TrnsEnd([trnsCommit]+IfThen(lSetDbs,trnsSetDBS));
        end;
      except
        if lTrns then TrnsEnd(IfThen(lSetDbs,trnsSetDBS));
        raise
      end;
      Prior;
    end;
  end;
  qu.UnPrepare;
  DelStack;
end;

procedure StPack(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var lst: TPackList;
  q,qu,qu1: TMulQuery;
  SetDbs,lMemo: boolean;
  i,j,p,lr: longint;
  f,w: string;
  af: array[0..1] of variant;
begin
  AddStack('FrmPswd.StPack');
  lst:=TPackList.Create;
  with ProgPswd do try
    lst.Sorted:=true; SetLength(lst.a,10); q:=GetQuery; qu:=GetQuery; qu1:=GetQuery;
    with GetQuery do begin
      for SetDbs:=false to true do with aDbsTbl[SetDbs] do begin
        if Sender.SayStat('Поиск таблиц ('+FLow(GetPrim(dbs))+')') then break;
        PartSelect(dbs,[fDbsTABLE,fDbsFIELD],fDbsTABLE+'<>'+QQs(AnsiLowerCase(glob)));
        lr:=RecordCount;
        for j:=1 to lr do begin
          if not IntObjFindAdd(lst,TrimUpper(Fields[0].AsString),i,p) then begin
            if Length(lst.a)=p then SetLength(lst.a,p shl 1);
            with lst.a[p] do begin
              rcnt:=-1; rmax:=-1; lSetDbs:=SetDbs;
            end;
          end;
          with lst.a[p] do if rcnt<0 then begin
            lMemo:=AnsiMatchText(lst[i],[tMEMO,tSEL]); f:=TrimUpper(Fields[1].AsString);
            if (f=fRECNO) or lMemo and (f='FLD') then
              if IsTable(lst[i]) then begin
                if Sender.SayStat('',lst[i],j/lr) then break;
                w:=IfThen(lMemo,QQNull('FLD','',true));
                q.PartSelect(lst[i],[iif(lMemo,0,sCOUNTZV),'max('+IfThen(lMemo,fMGK,fRECNO)+')'],w);
                rcnt:=q.Fields[0].AsInteger; rmax:=q.Fields[1].AsInteger;
                if lMemo then begin
                  q.PartSelect(lst[i],fMGK,w,'',fMGK); rcnt:=q.RecordCount;
                end;
              end;
          end;
          Next;
        end;
      end;
      if not Sender.SayStat('Дефрагментация номеров записей') then begin
        lst.Sorted:=false; lst.CustomSort(SortRecordCount); lr:=lst.Count;
//lst.Exchange(lst.IndexOf(tSEL),0);
        for i:=0 to lr-1 do with lst.a[IntObj(lst,i)] do begin
          if Sender.SayStat('',lst[i],(i+1)/lr) then break;
          if rmax>rcnt then begin
            lMemo:=AnsiMatchText(lst[i],[tMEMO,tSEL]);
            f:=IfThen(lMemo,fMGK,fRECNO);
            af[0]:=f; af[1]:=IfThen(lMemo,'FLD');
            w:=IfThen(lMemo,sAND+QQNull('FLD','',true));
            PartSelect(lst[i],af,f+'>'+Vtos(rcnt)+w,f,GetList(af)); j:=RecordCount;
            if ShowStat(lst[i],StPackTbl,[lst[i],lSetDbs,LongInt(q),LongInt(qu),LongInt(qu1),j,f,lMemo,w,Params[0]],j) then begin
              Sender.Abort; break;
            end;
          end;
          if not IsSQLBased then
            if TrnsStart([lst[i]],1,nil,lSetDbs) then TrnsEnd(IfThen(lSetDbs,trnsSetDBS));
        end;
        MaxFldClearAll;
      end;
    end;
    FreeQuery; FreeQuery; FreeQuery;
  finally
    lst.Free;
  end;
  DelStack;
end;

function TFormPswd.Pack;
begin
	AddStack('TFormPswd.Pack',Self);
  result:=LockSuper(lLockSuper);
  if result then begin
    try
      result:=not ShowStat('Поиск таблиц',StPack,[longint(@Proc)]);
    finally
      if lLockSuper then UnLockSuper;
    end;
    mess_ok(['Дефрагментация номеров записей окончена.','Рекомендуется произвести упаковку данных.']);
  end;
  DelStack;
end;

procedure TFormPswd.QryUsersAfterOpen;
	procedure lsAdd(const nmf: string);
  begin
    AddStack('TFormPswd.QryUsersAfterOpen',Self);
  	if StrToBoolean(IsNilc(PrmUser[nmf],bFalse)) then AddFrom(aPriv,lPriv,nmf);
    DelStack;
  end;
var i: longint;
begin
	AddStack('TFormPswd.QryUsersAfterOpen',Self);
  lPriv:=0; lsAdd('SUPER'); 
  for i:=low(aPrivFld) to high(aPrivFld) do lsAdd(aPrivFld[i]);
  QuickSort(aPriv,lPriv);
  DelStack;
end;

procedure TFormPswd.ReStart;
var a: TArrStr;
  procedure AddPrm(const nm,v: string);
  var i: longint;
    al: TNamePrimStr;
  begin
    AddStack('TFormPswd.ReStart.AddPrm',Self);
    i:=low(a);
    while i<=high(a) do begin
      if StrDivDlm('=',a[i],al) then if TrimUpper(al[1])=nm then break;
      Inc(i);
    end;
    if i>high(a) then SetLength(a,i+1);
    a[i]:=nm+'='+v;
    DelStack;
  end;
var i,j: longint;
  sk: string;
begin
  AddStack('TFormPswd.ReStart',Self);
  if lAsk and (UsName='') then Mode:=AskCancel(['Внимание!','Будет произведена перезагрузка программы.',
  	'Войти в программу под другим именем пользователя ?'],Mode);
  if Mode<>mrCancel then begin
    Application.Terminate; InitFIni.UpdateFiles; SetLength(a,ParamCount); j:=0;
	  for i:=1 to ParamCount do begin
      sk:=ParamStr(i);
      if not AnsiStartsStr('KEYS=',sk) then begin
        a[j]:=sk; Inc(j);
      end;
    end;
    SetLength(a,j); AddPrm('GETUSER',''); AddPrm('USNM',''); AddPrm('PSWD','');
    if Mode=mrYes then AddPrm('GETUSER','1')
    else begin
      AddPrm('USNM','"'+Trim(IfThen(UsName='',Rec['USER'],UsName))+'"');
      if UsName='' then AddPrm('PSWD','"'+Trim(Rec['PSWD'])+'"');
    end;
    sk:='';
	  for i:=low(aKey) to high(aKey) do sk:=StrNum(sk+cDlmKey,aKey[i]);
    if sk<>'' then AddPrm('KEYS',Copy(sk,Length(cDlmKey)+1,MaxInt));
    SetStrFile(ExeDir+FileRestart,'1');
    ShellExecute(0,nil,PChar(Application.ExeName),PChar(DlmBetween(a,' ')),PChar(ExeDir),SW_SHOW);
  end;
  DelStack;
end;

procedure TFormPswd.tryQuery;
begin
	QueryBefTry:=BusyQuerys;
end;

procedure TFormPswd.exceptQuery;
begin
  AddStack('TFormPswd.exceptQuery',Self);
	while BusyQuerys>QueryBefTry do FreeQuery;
  DelStack;
end;

function TFormPswd.GetQuery(AConnection: TComponent = nil): TMulQuery;
var s: string;
begin
  s:=GetStack(AddStack('TFormPswd.GetQuery',Self)-1);
  if length(amq)=BusyQuerys then begin
  	SetLength(amq,BusyQuerys+1); amq[BusyQuerys].q:=TMulQuery.Create(Self);
	end;
	result:=amq[BusyQuerys].q; amq[BusyQuerys].s:=s;
  with result do begin
    Close; MulPar.Clear; Connection:=IfThen(Assigned(AConnection),AConnection,PswdPrm.DBMain);
  end;
  Inc(BusyQuerys);
  DelStack;
end;

function TFormPswd.GetQuery(lIf: boolean): TMulQuery;
begin
  if lIf then result:=GetQuery else result:=nil;
end;

procedure TFormPswd.FreeQuery;
begin
  AddStack('TFormPswd.FreeQuery',Self);
	dec(BusyQuerys);
  with amq[BusyQuerys].q do begin
  	Close; MulPar.Clear; Connection:=PswdPrm.DBMain;
  end;
  DelStack;
end;

procedure TFormPswd.FreeQuery(q: TMulQuery);
begin
  if Assigned(q) then FreeQuery;
end;

function TFormPswd.CurQuery;
begin
  AddStack('TFormPswd.CurQuery',Self);
  result:=amq[BusyQuerys-1].q;
  DelStack;
end;

// Параметры рабочего места
function TFormPswd.PrmLocal;
const aCopLast: array[1..4] of string = ('Cop','CopDay','CopCnt','CopDir');
var a: TDEPrmVar;
	i,j: longint;
  af: TArrFldVal;
  c: char;
begin
  AddStack('TFormPswd.PrmLocal',Self);
  while true do
    if dePrm.GetArrParam(1)[deVid]=TDBPrmGet.ClassName then dePrm.Fields.Delete(1) else break;
  j:=high(aDopSection); Rec.GetAFieldValue(af);
  for i:=high(aDopName) downto low(aDopName) do begin
  	if not empty(aDopSection[j]) then begin
    	InitArr(a);
      a[deNameRec]:=Rec.NameRec;
      a[deNameRecFld]:=StrNum('DOP',i);
      TDBPrmGet.AssignGetClass(a);
      a[deMask]:=aDopName[i]+UnDelim+aDopSection[j];
      a[deWidth]:=wallDefault;
      dePrm.CreateFld(a,'COP');
    	Rec.CreateFld(a[deNameRecFld],ftMemo,0,'');
    end;
    Dec(j);
  end;
  Rec.SetAFieldValue(af); c:=bStr[not lCopLast];
  for i:=low(aCopLast) to high(aCopLast) do dePrm.Param[aCopLast[i],deNoVisible]:=c;
  Rec['IDUpd']:=IDUpd; Rec['FormLimit']:=FormLimit; Rec['FormLimTime']:=FormLimTime;
  Rec['NoSciLexer']:=PswdPrm.NoSciLexer; Rec['BrFindAll']:=PswdPrm.BrFindAll;
  dePrm.FrmCaption:=IfThen(Capt='','Параметры рабочего места',Capt);
  result:=dePrm.Execute([lRestart]).Saved;
  if result then begin
  	FormLimit:=Rec['FormLimit']; FormLimTime:=Rec['FormLimTime'];
  end;
  ReBootMsg([],false);
  DelStack;
end;

function TFormPswd.IDUpd;
var i: longword;
begin
  AddStack('TFormPswd.IDUpd',Self);
  with TIniFileData.Create do
    try
      result:=ReadInteger(stpSection,stpIDUpd,30);
      if RG.Active then begin
        i:=RG['UAbort']*SecsPerMin/5;
        if result>i then begin
          result:=i; WriteInteger(stpSection,stpIDUpd,i);
        end;
      end;
    finally
      Free;
    end;
  DelStack;
end;

procedure TFormPswd.dePrmFldChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TFormPswd.dePrmFldChange',Self);
  with TFldEdit(Sender) do if NameRecFld='COPDAY'
  then dePrm.SetReadOnly(['CopCnt','CopDir'],VarValue=0);
  DelStack;
end;

function TFormPswd.dePrmFldCheck(Sender: TObject): Boolean;
begin
	AddStack('TFormPswd.dePrmFldCheck',Self);
  NoEmpCheck(Sender,'COPDIR',result);
  DelStack;
end;

function TFormPswd.dePrmPnlValid(Sender: TObject): Boolean;
var lRestart: boolean;
  i: longword;
begin
	AddStack('TFormPswd.dePrmPnlValid',Self);
  result:=true;
  with dePrm.FldEdit['REG'] do lRestart := OldValue<>Value;
  with TIniFileData.Create do
    try
      WriteInteger(stpSection,'CopDay',Rec['CopDay']);
      WriteInteger(stpSection,'CopCnt',Rec['CopCnt']);
      WriteString(stpSection,'CopDir',Rec['CopDir']);
      WriteString(stpSection,stpIDUpd,Rec['IDUpd']);
      if PswdPrm.NoSciLexer<>Rec['NoSciLexer'] then begin
        PswdPrm.NoSciLexer:=Rec['NoSciLexer']; WriteBool(stpSection,'NoSciLexer',PswdPrm.NoSciLexer);
        lRestart:=true;
      end;
      PswdPrm.BrFindAll:=Rec['BrFindAll']; WriteBool(stpSection,'BrFindAll',PswdPrm.BrFindAll);
      WriteInteger(stpSection,'FormLimit',Rec['FormLimit']);
      WriteInteger(stpSection,'FormLimTime',Rec['FormLimTime']);
    finally
      Free;
    end;
  i:=IDUpd; Timer1.Interval:=i*MSecsPerSec;
  if RG.Active then if MulQry.GetFieldList(tREGS).IsField('IDUPD')
  then QryRegs.UpdateTable('',['IDUPD'],[i],RegDt+'='+SDateReg);
  if dePrm.Params[0] and lRestart and not MustReboot then
    if Ask(['Внимание!','Для корректной работы программы','необходим её перезапуск.','',
      'Произвести перезапуск программы сейчас ?']) then ReStart([]);
  DelStack;
end;

procedure TFormPswd.dePrmKpProcKey(key: longint; tw: TWinControl);
  function tfWrite(tf: TFldEdit): boolean;
  var i: longint;
    tf1: TFldEdit;
  begin
  	AddStack('TFormPswd.dePrmKpProcKey.tfWrite',Self);
    result:=true;
  	for i:=0 to tf.ComponentCount-1 do if IsClass(tf.Components[i],TFldEdit,pointer(tf1)) then
      if not tfWrite(tf1) then begin
        result:=false; break;
      end;
    if result then begin
      tf.Write; result:=tf.Check;
    end;
    DelStack;
  end;
var tf: TFldEdit;
begin
	AddStack('TFormPswd.dePrmKpProcKey',Self);
  case Key of
    K_F4: begin
      tf:=dePrm.FldEdit['REG'];
      if tfWrite(tf) then begin
        dbTo:=TDBPrmGet.CreateDatabase(tf);
        try
          if TDBPrmGet.Connect(dbTo,tf) then deCopyData.Execute;
        finally
          SetConnected(dbTo,false); dbTo.Free;
        end;
      end;
    end;
    K_F7: if Ask(['Создать резервную копию ?']) then CopLast(false);
  end;
  DelStack;
end;

procedure TFormPswd.CopLast;
var s,t: string;
  fl: boolean;
  a: TArrStr;
  i,l: longint;
  d: TDateTime;
	sr: TSearchRec;
begin
  AddStack('TFormPswd.CopLast',Self);
  s:=Rec['CopDir'];
  if empty(ExtractFileDrive(s)) then IncL(s,ExeDir);
  if ForceDirectories(s) then fl:=DirectoryExists(s) else fl:=false;
  if fl then begin
    CorrDirSelf(s); GetMaskFiles(a,l,s+'*.*',[fmDir],[msfSort]);
    for i:=0 to l-1 do
      if Numstr(Int0(a[i]),8)<>a[i] then begin
        mess_ok(['Внимание !','В папке для резервного копирования',s,
          'обнаружена некорректная папка: '+a[i],'','Удалите некорректную папку',
          'или выберите другую папку для резервного копирования.']);
        fl:=false; break;
      end;
    if fl then begin
      if lCopDay then begin
        d:=0;
        if l>0 then begin
          SysUtils.FindFirst(s+a[l-1],faDirectory,sr);
          d:=FileDateToDateTime(sr.Time); SysUtils.FindClose(sr);
        end;
        fl := trunc(Now)-trunc(d)>=Rec['CopDay'];
      end;
      if fl then begin
        if l=0 then i:=0 else i:=Int0(a[l-1]);
        t:=StrNum(s,i+1,8); DelDir(t);
        if CopyDatFromServer(t) then begin
          i:=0;
          while l>=Rec['CopCnt'] do begin
            DelDir(s+a[i]); Inc(i); Dec(l);
          end;
        end
        else DelDir(t);
      end;
    end;
  end
  else mess_ok(['Внимание !','Не удалось произвести резервное копирование в папку',s]);
  DelStack;
end;

procedure TFormPswd.deCopyDataFrmShow(Sender: TObject);
var Prm: TDBPrmGetInfo;
{ $IFDEF OLDCNF
	i: TConfigList;
  s: string;
{$ENDIF}
begin
	AddStack('TFormPswd.deCopyDataFrmShow',Self);
{ $IFDEF OLDCNF
  s:='';
  for i:=1 to cnfCnt do SetByte(s,i,true);
{$ENDIF}
  with Prm do begin
{ $IFDEF OLDCNF
  	Cnf:=s;
{$ENDIF}
    AType:=dbtpDriver; aName[AType]:=drvSTANDARD; Prm:=stpPath+'='+DirData;
  end;
  TDBPrmGet.WriteParamToIni('ALSFROM',Prm);
  DelStack;
end;

procedure TFormPswd.deCopyDataPnlCngKey(Sender: TObject; var tb: TKeyBut);
begin
	AddStack('TFormPswd.deCopyDataPnlCngKey',Self);
  with tb do if Key=K_F10 then Caption:='Скопировать';
  DelStack;
end;

function TFormPswd.deCopyDataPnlValid(Sender: TObject): Boolean;
var dbFrom: TComponent;
  fl: boolean;
  tf: TFldEdit;
begin
	AddStack('TFormPswd.deCopyDataPnlValid',Self);
	result:=false; tf:=deCopyData.FldEdit['ALSFROM']; dbFrom:=TDBPrmGet.CreateDatabase(tf);
  try
    if TDBPrmGet.Connect(dbFrom,tf) then begin
      SetConnected(false); SetConnected(true);
      fl:=Timer1.Enabled; Timer1.Enabled:=false;
      result:=not ShowStat('Копирование данных',StCopyDat,[LongInt(dbFrom),LongInt(dbTo),LongInt(ls)]);
      Timer1.Enabled:=fl;
    end;
  finally
    SetConnected(dbFrom,false); dbFrom.Free;
  end;
  DelStack;
end;

// Параметры доступа к данным
procedure TFormPswd.PrmServer;
var s: string;
  atp: TSQLExecStr;
  tp: TSQLExecType;
  a: TArrStr;
  i,j: longint;
begin
  AddStack('TFormPswd.PrmServer',Self);
  LogVid:=logvEditRec; LogFields.AddRecFld(RG,fSQLTBL);
  if LockSuper then try
    with GetQuery do begin
      PartSelect(tGLOBSET,['ICON',fRECNO],'','','',false); RequestLive:=DrvCan('blob'); Open;
      if RequestLive then begin
        {if DBMain is TIBDatabase then with TIBQuery(CurQuery.DataSet),AutoUpdateOptions do begin
          GenerateSQLText(UpdateTableName,KeyFields,skModify);
        end;}
        Edit;
      end;
      Rec['IconDefault']:=not igssLoad(IconCreate); igMod:=false; IconMod:=false;
      //LsArrList(DlmCopy(deGlob.Param['SQLTBL',deMask],3,1,UnDelim),ls,mniDlm);
      GetTableNames(ls);
      s:=''; LsArrFill(RG[fSQLTBL],atp,dlmSQLExec);
      for tp:=low(atp) to high(atp) do
        for i:=0 to LsArrDynamic(atp[tp],a,dlmSQLTbl)-1 do
          if ls.Find(a[i],j) then SetByte(s,byte(tp)+1,j+1,true);
      Rec['SQLTBL']:=s; deGlob.Execute; RequestLive:=false; FreeQuery;
    end;
  finally
    UnLockSuper;
  end;
  LogVid:=logvNone;
  DelStack;
end;

function TFormPswd.IconCreate;
begin
  AddStack('TFormPswd.IconCreate',Self);
  if not Assigned(igIcon) then igIcon:=TIcon.Create;
  result:=igIcon;
  DelStack;
end;

procedure TFormPswd.IconGetPaint(Sender: TObject; const ARect: TRect; const Text: String);
const iX=5; iY=5; iX2 = iX shl 1; iY2 = iY shl 1; offs=4;
var prc: Double;
	r: TRect;
  w,h: longint;
begin
	AddStack('TFormPswd.IconGetPaint',Self);
  IconCreate;
  with TFldEdit(Sender),Canvas do begin
  	FillRect(ARect); w:=ARect.Right-ARect.Left-offs-iX2; h:=ARect.Bottom-ARect.Top-offs-iY2;
    if (w>0) and (h>0) then
      if (igIcon.Width>w) or (igIcon.Height>h) then begin
        prc:=max(igIcon.Width/w,igIcon.Height/h);
        r.Right:=nround(igIcon.Width/prc); r.Bottom:=nround(igIcon.Height/prc);
        r.Left:=ARect.Left+iX+(w-r.Right) div 2; r.Top:=ARect.Top+iY+(h-r.Bottom) div 2;
        Inc(r.Right,r.Left); Inc(r.Bottom,r.Top); StretchDraw(r,igIcon);
      end
      else Draw(ARect.Left+(ARect.Right-ARect.Left-offs-igIcon.Width) div 2,
        ARect.Top+(ARect.Bottom-ARect.Top-offs-igIcon.Height) div 2,igIcon);
  end;
  DelStack;
end;

function TFormPswd.igssLoad;
var ost: longint;
begin
  ost:=AddStack('TFormPswd.igssLoad',Self);
  StringStreamCreate(igss);
  with CurQuery do if DrvCan('blob') then begin
  	TBlobField(Fields[0]).SaveToStream(igss); sIcon:=StrDeShifr(igss.DataString);
	  igss.Size:=0; igss.Seek(0,soBeginning);
  end
  else if lLoad then begin
    with GetQuery do begin
      PartSelect(tGLOBSET,'ICON');
      sIcon:=TMemGKList.Create.GetValue(Fields[0].AsInteger);
      FreeQuery;
    end;
  end;
  igss.WriteString(sIcon); igss.Seek(0,soBeginning); result:=false;
  try
    Icon.LoadFromStream(igss); result:=true;
  except
    on EInvalidGraphic do SetStack(ost);
    on EReadError do SetStack(ost);
  end;
  if not result then Icon.Handle:=LoadIcon(HInstance,'MAINICON');
  DelStack;
end;

procedure TFormPswd.igssSave;
var lBlob: boolean;
begin
  AddStack('TFormPswd.igssSave',Self);
  with CurQuery do begin
  	lBlob:=DrvCan('blob');
    if lBlob then sIcon:=StrShifr(s) else sIcon:=s;
    StringStreamCreate(igss).WriteString(sIcon); igss.Seek(0,soBeginning);
    if lBlob then TBlobField(Fields[0]).LoadFromStream(igss);
  end;
  igssLoad(IconCreate,false); igMod:=true; deGlob.FldEdit['ICON'].ValueRepeat;
  DelStack;
end;

function TFormPswd.IconGetClick(Sender: TObject; lEval: Boolean): String;
var tw: TComponent;
begin
	AddStack('TFormPswd.IconGetClick',Self);
  if lEval then begin
    ComponentsClass(pointer(Sender),TPaintButton,pointer(tw));
  	if FileExec('Icon',dlgIco,tw) then begin
    	igssSave(GetStrFile(dlgIco.FileName)); IconMod:=true;
    end;
  end;
  result:='';
  DelStack;
end;

procedure TFormPswd.deGlobFldChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TFormPswd.deGlobFldChange',Self);
  with TFldEdit(Sender) do if NameRecFld='ICONDEFAULT' then begin
  	deGlob.SetReadOnly('ICON',VarValue);
    if not FromShow and VarValue then igssSave('');
  end;
  DelStack;
end;

procedure StLoadDer(Sender: TStat; const Params: array of variant; var Aborted: boolean);
  function brk(usl: boolean): boolean;
  begin
    AddStack('FrmPswd.StLoadDer.brk');
    result:=not usl;
    if result then Sender.Abort;
    DelStack;
  end;
var path,fn: TFileName;
  ost,i,lr: longint;
  ss: TStringStream;
  fl: boolean;
  d: Double;
label lend;
begin
  ost:=AddStack('FrmPswd.StLoadDer');
  with ProgPswd,GetQuery do begin
    path:=Params[0];
    if brk(ForceDirMsg(path)) then goto lend;
    if brk(MaskFilesProc(path+'*.*',PrDelMaskFiles,[path])) then goto lend;
    PartSelect(tDER,[fIP,fFNAME,'TIMECNG',fTXT],'','TIMECNG'); lr:=RecordCount;
    for i:=1 to lr do begin
      d:=Fields[2].AsFloat;
      if Sender.SayStat('','Дата протокола: '+FormatDateTime('dd/mm/yyyy hh:nn:ss',d),i/lr) then break;
      fn:=path+TrimRight(Fields[1].AsString)+'.'+TrimRight(Fields[0].AsString);
      ss:=TStringStream.Create('');
      try
        for fl:=false to true do begin
          try
            TBlobField(Fields[3]).SaveToStream(ss);
            SetStrFile(fn,ZDecompressStr(StrDeshifr(ss.DataString)));
            break;
          except
            if fl then raise;
            SetStack(ost); Close; UnPrepare; PartSelect('','','TIMECNG>='+VTos(d),Arg[sO_LIST]);
          end;
        end;
      finally
        ss.Free;
      end;
      SetFileDateTime(fn,d); Next;
    end;
lend:
    FreeQuery;
  end;
  DelStack;
end;

procedure TFormPswd.deGlobKpProcKey(key: Integer; tw: TWinControl);
var path: TFileName;
begin
  AddStack('TFormPswd.deGlobKpProcKey',Self);
  case Key of
    K_F7: begin
      path:=ExeDir+'DER'+PathDelim;
      if Ask(['Выгрузить протоколы в папку',path+' ?'])
      then ShowStat('Выгрузка протоколов в папку',StLoadDer,[path]);
    end;
    K_F8: begin
      LogVid:=logvDelRec;
      if Ask(['Удалить протоколы на центральном компьютере ?']) then begin
        DeleteTable(tDER); LogWrite(tDER);
      end;
      LogVid:=logvNone;
    end;
    K_Ctrl_F8: if IsTable(tLOG) then begin
      LogVid:=logvDelRec;
      if deLogDel.Execute.Saved then begin
        DeleteTable(tLOG,fLogD+'<'+Vtos(Double(Rec['DLOGDEL']))); LogWrite(tLOG,'до '+dtoc(Rec['DLOGDEL']));
      end;
      LogVid:=logvNone;
    end;
  end;
  DelStack;
end;

function TFormPswd.deLogDelFldCheck(Sender: TObject): Boolean;
begin
  AddStack('TFormPswd.deLogDelFldCheck',Self);
  NoEmpCheck(Sender,'DLOGDEL',result);
  DelStack;
end;

function TFormPswd.deGlobPnlAskCancel(Sender: TObject): Boolean;
begin
	result:=IconMod;
end;

function TFormPswd.deGlobPnlValid(Sender: TObject): Boolean;
	function tfMod(const nmf: string): TFldEdit;
  begin
    AddStack('TFormPswd.deGlobPnlValid.tfMod',Self);
    result:=deGlob.FldEdit[nmf];
    if result.OldValue=result.Value then result:=nil else igMod:=true;
    DelStack;
  end;
var tf: TFldEdit;
	memgk,i: longint;
  st: string;
  atp: TSQLExecStr;
  tp: TSQLExecType;
  q: TMulQuery;
begin
	AddStack('TFormPswd.deGlobPnlValid',Self);
  result:=true;
  with TPanelEdit(Sender) do if Modified or IconMod then begin
    if deGlob.IsFldEdit('REPDEADLOC',tf) then PswdPrm.RepDeadLock:=tf.VarValue;
    tf:=tfMod('UserCnt');
    if Assigned(tf) then begin
      PswdPrm.UserCnt:=max(1,longint(tf.VarValue)); DbInsCheck;
    end;
    if result then begin
      //LsArrList(DlmCopy(deGlob.Param['SQLTBL',deMask],3,1,UnDelim),ls,mniDlm);
      GetTableNames(ls);
      st:=Rec['SQLTBL'];
      for tp:=low(atp) to high(atp) do begin
        atp[tp]:='';
        for i:=0 to ls.Count-1 do
          if GetByte(st,byte(tp)+1,i+1) then IncD(atp[tp],ls[i]+dlmSQLTbl);
        DecLen(atp[tp],ldlmSQLTbl);
      end;
      RG[fSQLTBL]:=ArrayAsList(atp,dlmSQLExec); lsTblSQLFill;
    	tfMod('UABORT'); tfMod('PROG');
      q:=CurQuery;
      if q.RequestLive then q.Post
      else with GetQuery do begin
        memgk:=PartMaxInt(tMEMO,fMGK)+1;
        TRecDB.SetMemValue(memgk,sIcon,CurQuery,[memNoDelPrior]);
        RG['ICON']:=memgk; RG.UpdateRec;
        RG.DelMemo('',PrDelMemo); MaxFldClear(tMEMO); FreeQuery;
      end;
      if igMod then begin
	      mess_ok(['Для корректной работы программы','будет произведён её перезапуск.']);
        Restart([]);
      end;
    end;
  end;
  DelStack;
end;

function TFormPswd.CopyDatFromServer;
var dir: TFileName;
begin
  AddStack('TFormPswd.CopyDatFromServer',Self);
  result := cdir<>'';
  if result then dir:=cdir
  else begin
    dir:=ExeDir+DirDATA; result:=Ask(['Скопировать данные в папку',dir+' ?']);
  end;
  if result then begin
  	result:=LockMono;
    if result then try
      result:=ForceDirMsg(dir);
      if result then result:=not ShowStat('Копирование данных',StCopyDat,
        [LongInt(PswdPrm.DBMain),LongInt(DBDBF(dir)),LongInt(ls),LongInt(lsExclude),LongInt(@ValueProc)]);
    finally
      UnLockMono;
    end;
  end;
  DelStack;
end;

procedure StCopyDatGlobset(dFrom: TCustomDataFile; const FieldName: string; var v: variant);
begin
  AddStack('FrmPswd.StCopyDatGlobset');
  if TrimUpper(FieldName)='WASCOPY' then v:=bTrue;
  DelStack;
end;

class procedure TFormPswd.StCopyDat;
var db1,db2: TComponent;
  q1,q2: TMulQuery;
  procedure DropTmp(lFlush: boolean = true);
  var fl,lExt: boolean;
  begin
    AddStack('TFormPswd.StCopyDat.DropTmp');
    fl:=NoDBFlush; NoDBFlush:=false;
    if lFlush then begin
      q1.DBFlush; q2.DBFlush;
    end;
    lExt:=false;
    if DropTmpTblExt(db1) then begin
      q1.DBFlush([flushConnect]); lExt:=true;
    end;
    if DropTmpTblExt(db2) then begin
      q2.DBFlush([flushConnect]); lExt:=true;
    end;
    if lExt then DropTmpFileExt;
    NoDBFlush:=fl;
    DelStack;
  end;
var i,k,ost: longint;
	memgk: longint;
  ls,lsExclude: TStringList;
  blob1,blob2,lSort,fl,ongc: boolean;
  p: Pointer;
  a: TArrStr;
  ValueProc: TCopyTableValueProc;
  dbt1,dbt2: TDatabaseText;
  s: string;
  aw: TArrStr;
  al: TNamePrimStr;
begin
	ost:=AddStack('TFormPswd.StCopyDat');
  db1:=PointerVar(Sender.Params[0]); q1:=TMulQuery.CreateConnection(Application.MainForm,db1);
  db2:=PointerVar(Sender.Params[1]); q2:=TMulQuery.CreateConnection(Application.MainForm,db2);
  try
    blob1:=q1.DrvCan('blob'); blob2:=q2.DrvCan('blob');
    DropTmp(false); ls:=PointerVar(Sender.Params[2]);
    lsExclude:=PointerVar(Sender.Params,3); ValueProc:=PointerVar(Sender.Params,4);
    p:=nil; fl:=true; lSort:=ls.Sorted; ongc:=NoGarbageCollect(db1,true);
    if IsSQLBased(db1) then SetConnected(db1,true)
    else begin
      GetMaskFiles(ls,CorrDir(TDatabase(db1).Params.Values['PATH'])+'*'+DBTextExt);
      if ls.Count>0 then begin
        fl:=false; ls.Sorted:=false;
        for i:=0 to ls.Count-1 do ls[i]:=SubStr(ls[i],1,-Length(DBTextExt));
      end;
    end;
    if fl then GetTableNames(db1,ls);
    if Assigned(lsExclude) then begin
      i:=0;
      while i<ls.Count do
        if lsExclude.IndexOf(ls[i])<0 then Inc(i) else ls.Delete(i);
    end;
    ls.Sorted:=true; aw:=nil;
    if (blob1<>blob2) and FindDel(ls,tMEMO) then begin
      ls.Sorted:=false; ls.Insert(IfThen(blob2,ls.Count),tMEMO);
      if blob2 then p:=@a
      else begin
        memgk:=q1.PartMaxInt(tMEMO,fMGK); q1.Close; p:=@memgk;
      end;
    end
    else begin
      ls.Sorted:=true; InitArrLen(aw,ls.Count);
      if Assigned(lsExclude) then for i:=0 to lsExclude.Count-1 do
        if StrDivDlm('(',lsExclude[i],al) then
          if ls.Find(al[1],k) then aw[k]:='('+al[2];
    end;
    for i:=0 to ls.Count-1 do begin
      try
        if Sender.SayStat('',ls[i],(i+1)/ls.Count) then break;
        if InRange(i,low(aw),high(aw)) then s:=aw[i] else s:='';
        if not CopyTable(db1,db2,ls[i],ttNone,[cptCanEsc,cptNoDropTmpTbl],p,s,ValueProc) then begin
          Sender.Abort; break;
        end;
      except
        on E: Exception do begin
          s:=E.ClassName+': ошибка копирования таблицы '+ls[i]+CRLF+E.Message; OutStack(s);
          SetStack(ost);
          q1.DBFlush([flushConnect]); q2.DBFlush([flushConnect]); DropTmp;
          if CanPriv('SUPER') then fl:=Ask([s,'Продолжить ?'],false)
          else begin
            fl:=false;
            mess_ok([s,'Данные не были скопированы.','Попробуйте перезагрузить центральный компьютер',
              'и повторить процесс копирования.','Если ошибка повторится, обратитесь к разработчикам.']);
          end;
          if not fl then begin
            Sender.Abort; break;
          end;
        end;
      end;
    end;
    if not Sender.Aborted then begin
      DropTmp;
      if IsSQLBased(db2) then fl:=false
      else begin
        s:=CorrDir(TDatabase(db2).Params.Values[stpPath]); fl:=FileExists(s+tGLOBSET+DBTextExt);
      end;
      if fl then begin
        dbt1:=TDatabaseText.CreatePrm(s,tGLOBSET);
        dbt2:=TDatabaseText.CreatePrm(s,tGLOBSET+'_',false,dbt1);
        try
          dbt2.ValueProc:=StCopyDatGlobset;
          while not dbt1.Eof do begin
            dbt2.Add; dbt1.Next;
          end;
        finally
          dbt2.Free; dbt1.Free;
        end;
        if not CopyFileOpt(s+tGLOBSET+'_'+DBTextExt,s+tGLOBSET+DBTextExt,[cfMsg]) then Sender.Abort
        else if not DelFileAtr(s+tGLOBSET+'_'+DBTextExt) then begin
          mess_ok(['Ошибка удаления файла:',s+tGLOBSET+'_'+DBTextExt]); Sender.Abort;
        end;
      end
      else if IsTable(db2,tGLOBSET) then q2.UpdateTable(tGLOBSET,['WASCOPY'],[true]);
    end;
    ls.Sorted:=lSort; NoGarbageCollect(db1,ongc);
  finally
    q1.Free; q2.Free;
  end;
  DelStack;
end;

procedure UnRecno(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var l,oldr,maxr: longint;
	a: TArrArrVar;
  afl: TArrInt;
  q: TMulQuery;
  p: PBoolean;
  fp: TFormPswd;
  t: string;
  aErr: PArrStr;
  lErr: PLongInt;
	procedure Check;
  var i: longint;
  	procedure LsErrAdd(const prim: string);
    var s: string;
    	j: longint;
    begin
	    AddStack('FrmPswd.UnRecno.Check.LsErrAdd');
      fp.UnZglErr(fRECNO,afl,p,aErr^,lErr^); s:='';
      for j:=low(afl) to high(afl) do IncD(s,Padr(StrTran(StMeserr(a[i,j]),CRLF,' '),afl[j])+'|');
      AddFrom(aErr^,lErr^,s+' Исправлено: '+prim);
      DelStack;
    end;
    procedure Where(lv: boolean);
    var j: longint;
      s,v: string;
    begin
	    AddStack('FrmPswd.UnRecno.Check.Where');
      s:='';
      with fp.CurQuery do for j:=low(a[i]) to high(a[i]) do begin
        v:=q.VarToS(a[i,j],vsQQ);
        IncAnd(s,Fields[j].FieldName+IfThen(IsNil(a[i,j]),sISNULL,'='+v));
        if lv then begin
	        q.AddArgList(sC_LIST,Fields[j].FieldName); q.AddArgList(sV_LIST,v);
        end;
      end;
      q.Arg[sTABLE]:=t; q.Arg[sWHERE]:=Copy(s,lAND1,MaxInt);
      DelStack;
    end;
  var i1,j: longint;
  	fl: boolean;
  begin
    AddStack('FrmPswd.UnRecno.Check');
    if l>1 then begin
    	// Удаление совпадающих по всем полям
    	for i:=low(a) to high(a) do
      	if Length(a[i])>0 then for i1:=i+1 to high(a) do
        	if (i1<>i) and (Length(a[i1])>0) then begin
          	fl:=true;
          	for j:=low(a[i]) to high(a[i]) do
            	if not CompVar(a[i],a[i1]) then begin
              	fl:=false; break;
              end;
            if fl then with fp.CurQuery do begin
            	q.Arg[sC_LIST]:=''; q.Arg[sV_LIST]:=''; Where(true);
              q.ExecPart(sDW_TABLE); q.ExecPart(sI_TABLE);
            	a[i1]:=nil; LsErrAdd('2 совпадающие записи объединены в одну')
            end;
          end;
      // Изменить RECNO у остальных
      i:=low(a); LsErrAdd(fRECNO+Format(': %d => %d',[oldr,oldr]));
      for i:=low(a)+1 to high(a) do
      	if Length(a[i])>0 then begin
        	if maxr=0 then maxr:=q.PartMaxInt(t,fRECNO);
        	Inc(maxr); Where(false); q.Arg[sC_LIST]:=fRECNO; q.Arg[sV_LIST]:=maxr;
          q.ExecPart(sUW_TABLE); LsErrAdd(fRECNO+Format(': %d => %d',[oldr,maxr]));
        end;
    end;
    DelStack;
  end;
var ost,i,j,lr,r: longint;
	f: TField;
begin
	ost:=AddStack('FrmPswd.UnRecno');
  t:=Params[0]; q:=PointerVar(Params[1]); p:=PointerVar(Params[2]);
  fp:=PointerVar(Params[3]); lr:=Params[4]; aErr:=PointerVar(Params[5]); lErr:=PointerVar(Params[6]);
  with fp.CurQuery do
  	try
      f:=FindField(fRECNO); oldr:=0; l:=0; maxr:=0;
      for i:=1 to lr do begin
      	r:=f.AsInteger;
		  	if Sender.SayStat('',IntToStr(r),i/lr) then break;
        if r<>oldr then begin
        	Check; oldr:=r; l:=0;
        end;
        SetLength(a,l+1); SetLength(a[l],FieldCount);
        for j:=low(a[l]) to high(a[l]) do a[l,j]:=Fields[j].Value;
        Inc(l); Next;
      end;
      Check;
	  except
	    on EDatabaseError do SetStack(ost);
    end;
  DelStack;
end;

procedure UnGk(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i,j,k,lr,gk,l,lzn: longint;
	azn,a,ares: TArrStr;
  s: string;
  afl: TArrInt;
  am: ^TFldMemoAttrBool;
  ls1: TStringList;
  f: TField;
  fa: TFldMemoAttr;
  aErr: PArrStr;
  lErr: PLongInt;
begin
	AddStack('FrmPswd.UnGk');
  fa:=Params[0]; am:=PointerVar(Params[1]); aErr:=PointerVar(Params[2]); lErr:=PointerVar(Params[3]);
  with ProgPswd,CurQuery do begin
  	PartCount(aMemoTbl[fa],[fMGK,fMNPP]); lr:=RecordCount; lzn:=0; SetLength(azn,lr);
    for i:=1 to lr do begin
    	gk:=Fields[0].AsInteger;
    	if Sender.SayStat('',IntToStr(gk),i/lr) then break;
      if Fields[2].AsInteger>1 then begin
        azn[lzn]:=VTos(gk); Inc(lzn);
      end;
    	Next;
    end;
    if lzn>0 then begin
      for i:=0 to ls.Count-1 do begin
        if Sender.SayStat('',ls[i],(i+1)/ls.Count) then break;
        ls1:=MulQry.GetFieldList(ls[i]); SetLength(a,ls1.Count); l:=0;
        for j:=0 to ls1.Count-1 do
          if AnsiStartsText(aBegMem[fa],ls1[j]) then begin
            a[l]:=ls1[j]; Inc(l);
          end;
        for j:=low(a) to l-1 do
          if FldInList(ares,a[j],azn,lzn) then for k:=low(ares) to high(ares) do begin
            PartSelect(ls[i],[],ares[k]); afl:=nil; f:=FindField(a[j]);
            while not Eof do begin
              UnZglErr(aMemoTbl[fa]+'.'+fMGK,afl,@am[fa],aErr^,lErr^); s:='';
              for l:=low(afl) to high(afl) do
                IncD(s,Padr(StrTran(StMeserr(Fields[l].Value),CRLF,' '),afl[l])+'|');
              AddFrom(aErr^,lErr^,StrNum(s+' Не исправлено: '+a[j]+'=',f.AsInteger)); Next;
            end;
          end;
      end;
    end;
  end;
  DelStack;
end;

procedure TFormPswd.CheckUnique;
var i,i1,lr,lr1,lErr: longint;
  FileErr,s: string;
  lRecno,lm: boolean;
	q,qs: TMulQuery;
  fa: TFldMemoAttr;
  am: TFldMemoAttrBool;
  aErr: TArrStr;
begin
  AddStack('TFormPswd.CheckUnique',Self);
  lRecno:=true; TrueMemory(@am,Length(am)); lErr:=0;
  GetTableNames(ls); q:=GetQuery; qs:=GetQuery; i1:=1; lr:=ls.Count+Length(aMemoTbl);
  for i:=0 to ls.Count-1 do begin
    if Sender.SayStat('',ls[i],i1/lr) then break;
    qs.PartSelect(ls[i],[],RecnoWhere(-1,false),fRECNO); lr1:=qs.RecordCount;
    if ShowStat(ls[i],UnRecno,[ls[i],LongInt(q),LongInt(@lRecno),longint(Self),lr1,LongInt(@aErr),LongInt(@lErr)],lr1) then begin
      Sender.Abort; break;
    end
    else Inc(i1);
  end;
  if not Sender.Aborted then for fa:=low(aMemo) to high(aMemo) do begin
    if Sender.SayStat('',aMemoTbl[fa],i1/lr) then break;
    if ShowStat(aMemoTbl[fa],UnGk,[fa,LongInt(@am),LongInt(@aErr),LongInt(@lErr)]) then begin
      Sender.Abort; break;
    end
    else Inc(i1);
  end;
  q.MaxFldClearAll; FreeQuery; FreeQuery; FileErr:=ExeDir+'Unique.'+aProtFileExt[0];
  if lErr=0 then meserr(IfThen(Sender.Aborted,'Проверка была прервана !',
    'Проверка прошла успешно !'))
  else begin
    s:=ArrayAsList(aErr,CRLF,lErr); SetStrFile(FileErr,s); lm:=true;
    for fa:=low(aMemo) to high(aMemo) do if not am[fa] then begin
      lm:=false; break;
    end;
    if Ask(['При проверке были найдены ошибки.',
    IfThen(lRecno,'Ни одна из них не была исправлена.',
    IfThen(lm,'Все ошибки были исправлены.','Некоторые из них были исправлены.')),'',
    'Просмотреть протокол ошибок ?']) then begin
      AddPrnHead('Протокол ошибок');
      EdTextView('Протокол ошибок',s,'',nil,[],edtpText,0,0,'',0,nil,'',nil,nil,FileErr);
      DelPrnHead;
    end;
  end;
  DelStack;
end;

procedure TFormPswd.UnZglErr;
var s,sr: string;
	j: longint;
begin
  AddStack('TFormPswd.UnZglErr',Self);
  if Length(afl)=0 then with CurQuery do begin
    if p^ then begin
    	AddFrom(aErr,lErr,''); AddFrom(aErr,lErr,'<<< '+Zgl+' >>>'); p^:=false;
    end;
    AddFrom(aErr,lErr,''); AddFrom(aErr,lErr,'Таблица: '+string(Arg[sTABLE])); SetLength(afl,FieldCount); s:='';
    for j:=low(afl) to high(afl) do begin
      afl[j]:=Fields[j].Size;
      if afl[j]=0 then afl[j]:=10
      else if afl[j]>20 then afl[j]:=20;
      MaxSelf(afl[j],Fields[j].FieldName);
      IncD(s,Padr(Fields[j].FieldName,afl[j])+'|');
    end;
    sr:=StringOfChar('-',Length(s)); AddFrom(aErr,lErr,sr); AddFrom(aErr,lErr,s); AddFrom(aErr,lErr,sr);
  end;
  DelStack;
end;

type
  PArrSetGk0NoCorKa = ^TArrSetGk0NoCorKa;
  TArrSetGk0NoCorKa = record
    ProcErr: TMemoDelUnusedErr;
    AskErr: boolean;
    af: array of record
      q: TMulQuery;
      ar: TArrStr;
      lr: longint;
    end;
    aka: TArrStr;
    lf,lka: longint;
    Cod: string;
  end;

procedure PrArrSetGk0NoCorKa(const v: variant);
begin
  AddStack('FrmPswd.PrArrSetGk0NoCorKa');
  with PArrSetGk0NoCorKa(longint(v[0])).af[longint(v[1])] do begin
    if Length(ar)=lr then SetLength(ar,lr shl 1);
    ar[lr]:=Vtos(v[2]); Inc(lr);
  end;
  DelStack;
end;

procedure ArrSetGk0NoCorKa(Oper: TArrvSeekOper; Prm: pointer; rdb: TRecDBDef; Qry: TMulQuery;
  const Def: TDWArrSeekRec; var aDef: TArrStr; iDef: longint; var rDef: TDWVidRec;
  const ka,Cod,CodName: string; var Changed: boolean; var Aborted: boolean);
var p: PArrSetGk0NoCorKa;
  j: longint;
  procedure SetGk0;
  var r: longint;
    v: variant;
  begin
    AddStack('FrmPswd.ArrSetGk0NoCorKa.SetGk0');
    with p.af[j],q do begin
      r:=Fields[0].AsInteger; rdb.GotoRec(r); v:=VarArrayOf([longint(p),j,r]);
      p.ProcErr(ArrayAsList(['Обнаружен массив, несоответствующий описанию.',
        'Вид данных: '+rdb.GetPrim+'.',FRup(rdb.LogPrim)+'.',
        'Код массива: '+Copy(Fields[1].FieldName,Length(rdb.FixSt(sArray))+1,MaxInt)+'.',
        'Код вида массива: '+TrimRight(Fields[2].AsString)+'.',
        IfThen(p.AskErr,'Удалить значение массива ?','Значение массива будет удалено.')],CRLF),
        rdb.NameDB,PrArrSetGk0NoCorKa,v,Aborted);
      if not p.AskErr then PrArrSetGk0NoCorKa(v);
    end;
    DelStack;
  end;
var i,l: longint;
  s,o: string;
  fl: boolean;
begin
  AddStack('FrmPswd.ArrSetGk0NoCorKa');
  p:=Prm;
  case Oper of
    arrvQryBeg: begin
      if Def.NoDat then p.lf:=0
      else begin
        s:=rdb.FixSt(sArray); rdb.FieldFind(s,i); l:=rdb.FieldCount; p.lf:=i;
        while p.lf<l do if AnsiStartsText(s,rdb.FieldName[p.lf]) then Inc(p.lf) else break;
        Dec(p.lf,i); l:=Length(p.af);
        if l<p.lf then begin
          SetLength(p.af,p.lf);
          for l:=l to p.lf-1 do with p.af[l] do begin
            q:=TMulQuery.CreateConnection; SetLength(ar,100);
          end;
        end;
        o:=StrTran(Def.FldOrd,Def.RecDef+'.',IfThen(Def.RecDat<>'',Def.RecDat+'.'));
        for j:=0 to p.lf-1 do with p.af[j],q do begin
          s:=rdb.TblFldName(rdb.FieldName[i]);
          PartSelect(GetList([rdb.NameDB,Def.RecDat,tARR]),[rdb.tRecno,s,tARR+'.'+fARR,o],
            DlmBetween(tARR+'.'+fMGK+'='+s,Def.WhereDat,sAND),o,
            GetList([rdb.tRecno,s,tARR+'.'+fARR,o]));
          lr:=0; Inc(i);
        end;
      end;
      if p.lf=0 then Changed:=false; //не проверять, если нет массивов в таблице
    end;
    arrvDefFindBeg: begin
      if Def.FldOrd<>'' then begin
        p.Cod:=Padr(Cod,p.af[0].q.Fields[3].Size);
        for j:=0 to p.lf-1 do with p.af[j].q do while not Eof and (FieldValueIndex(3)<p.Cod) do begin
          SetGk0; Next;
        end;
      end;
      p.lka:=0;
    end;
    arrvDefFinded: begin
      if Length(p.aka)=p.lka then SetLength(p.aka,p.lka+1);
      p.aka[p.lka]:=rDef.AValue; Inc(p.lka);
    end;
    arrvDefFindEnd: for j:=0 to p.lf-1 do with p.af[j].q do while not Eof do begin
      if Def.FldOrd<>'' then if FieldValueIndex(3)>p.Cod then break;
      s:=TrimRight(Fields[2].AsString); fl:=true;
      for i:=0 to p.lka-1 do if p.aka[i]=s then begin
        fl:=false; break;
      end;
      if fl
      then SetGk0;
      Next;
    end;
    arrvQryEnd: begin
      if Def.FldOrd<>'' then for j:=0 to p.lf-1 do with p.af[j].q do while not Eof do begin
        SetGk0; Next;
      end;
      for j:=0 to p.lf-1 do with p.af[j] do
        q.UpdateTableFldList([q.Fields[1].FieldName],[0],ar,lr,fRECNO,[],rdb.NameDB);
    end;
  end;
  DelStack;
end;

const
  mfTbl = 0;
  mfFld = 1;
  mfPrm = 2;

  aMemoFld: array[0..1] of TFldMemoAttr = (famMemo,famSel);

function TFormPswd.StMemoFldProc;
var i,j,k: longint;
  fl: boolean;
begin
  AddStack('TFormPswd.StMemoFldProc',Self);
  result:=GetTableList;
  for i:=0 to result.Count-1 do begin
    if Sender.SayStat('',result[i],(i+1)/result.Count) then break;
    GetFieldNames(result[i],lsf); j:=0;
    while j<lsf.Count do begin
      fl:=true;
      for k:=low(aMemoFld) to high(aMemoFld) do if AnsiStartsText(aBegMem[aMemoFld[k]],lsf[j]) then begin
        fl:=false; lsf.Objects[j]:=pointer(aMemoFld[k]); Inc(j); break;
      end;
      if fl then lsf.Delete(j);
    end;
    if ShowStat(result[i],Proc,[result[i],LongInt(lsf),ArrVarToVar(av,0)],lsf.Count) then begin
      Sender.Abort; break;
    end;
  end;
  DelStack;
end;

procedure StMemoFld(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i,lr: longint;
  ares: PArrStr;
  q: TMulQuery;
begin
  AddStack('FrmPswd.StMemoFld');
  ares:=PointerVar(Params[0]); lr:=Params[1]; q:=PointerVar(Params[2]);
  for i:=1 to lr do begin
  	if Sender.SayStat(i/lr) then break;
    q.UpdateTable('',BrackNoEmp('FLD<>'+q.Arg[sV_LIST]+sOR+'FLD'+sISNULL)+sAND+ares^[i-1]);
  end;
  DelStack;
end;

procedure StMemoGk(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i,lr,gk: longint;
  q,qm: TMulQuery;
  a: PArrStr;
  l: PLongint;
begin
  AddStack('FrmPswd.StMemoGk');
  lr:=Params[0]; q:=PointerVar(Params[1]); qm:=PointerVar(Params[2]);
  a:=PointerVar(Params[3]); l:=PointerVar(Params[4]);
  for i:=1 to lr do begin
  	if Sender.SayStat(i/lr) then break;
    gk:=q.Fields[0].AsInteger;
    while not qm.Eof and (qm.Fields[0].AsInteger<gk) do qm.Next;
    if qm.Eof or (qm.Fields[0].AsInteger<>gk) then begin
      a^[l^]:=Vtos(gk); Inc(l^);
    end;
    q.Next;
  end;
  DelStack;
end;

procedure StMemoFldGk1(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i,j,l: longint;
	lsf: TStringList;
  a,ares: TArrStr;
  q,qm: TMulQuery;
  tbl,tmem,fmem: string;
begin
  AddStack('FrmPswd.StMemoFldGk1');
  tbl:=Params[mfTbl];
  lsf:=PointerVar(Params[mfFld]);
  q:=PointerVar(Params[mfPrm][0]); qm:=PointerVar(Params[mfPrm][1]);
  for i:=0 to lsf.Count-1 do with q do begin
    if Sender.SayStat('',lsf[i],(i+1)/lsf.Count) then break;
    tmem:=aMemoTbl[TFldMemoAttr(lsf.Objects[i])];
    if IsTable(tmem) then begin
      FldInSel(fMGK,tbl,lsf[i]+'<>0',lsf[i],[fselList],@ares);
      Arg[sTABLE]:=tmem; Arg[sC_LIST]:='FLD';
      Arg[sV_LIST]:=QQs(tbl+'.'+TrimUpper(Copy(lsf[i],lMemo1,MaxInt)));
      j:=Length(ares);
      if ShowStat(lsf[i],StMemoFld,[LongInt(@ares),j,Longint(q)],j,10) then begin
        Sender.Abort; break;
      end;
      PartSelect(tbl,lsf[i],QQNull(lsf[i],0,true),lsf[i],lsf[i]);
      fmem:=tmem+'.'+fMGK;
      qm.PartSelect(qm.GetList([tbl,tmem]),fmem,tbl+'.'+lsf[i]+'='+fmem,fmem,fmem);
      j:=RecordCount; l:=qm.RecordCount;
      if j>l then begin
        SetLength(a,j-l); l:=0;
        if ShowStat(lsf[i],StMemoGk,[j,Longint(q),Longint(qm),Longint(@a),Longint(@l)],j,100) then begin
          Sender.Abort; break;
        end;
        UpdateTableFldList([lsf[i]],[0],a,l,lsf[i]);
      end;
    end;
  end;
  DelStack;
end;

procedure StMemoFldGk(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var lsf: TStringList;
begin
  AddStack('FrmPswd.StMemoFldGk');
  lsf:=SortStrListCreate;
  with ProgPswd do try
    StMemoFldProc(Sender,lsf,StMemoFldGk1,[longint(GetQuery),longint(GetQuery)]); FreeQuery; FreeQuery;
  finally
    lsf.Free;
  end;
  DelStack;
end;

function TFormPswd.SetMemoFld;
begin
  AddStack('TFormPswd.SetMemoFld',Self);
  result:=not ShowStat('Корректировка ссылок на текстовые поля',StMemoFldGk);
  DelStack;
end;

procedure StMemoDelUnused1(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var lsf,ls1: TStringList;
  q: TMulQuery;
  i,l: longint;
  tbl,tmem,gk: string;
  a: TArrStr;
begin
  AddStack('FrmPswd.StMemoDelUnused1');
  tbl:=AnsiUpperCase(Params[mfTbl]); lsf:=PointerVar(Params[mfFld]);
  ls1:=PointerVar(Params[mfPrm][0]); q:=PointerVar(Params[mfPrm][1]);
  for i:=0 to lsf.Count-1 do begin
    if Sender.SayStat('',lsf[i],(i+1)/lsf.Count) then break;
    tmem:=aMemoTbl[TFldMemoAttr(lsf.Objects[i])];
    if IsTable(tmem) then with q do begin
      FldInSel(fMGK,tbl,lsf[i]+'<>0',lsf[i],[fselNot,fselList],nil,lsf[i],nil,ls1);
      PartSelect(tmem,fMGK,'FLD='+QQs(tbl+'.'+AnsiUpperCase(Copy(lsf[i],lMemo1,MaxInt))),'',fMGK);
      SetLength(a,RecordCount); l:=0;
      while not Eof do begin
        gk:=Vtos(Fields[0]);
        if not FindDel(ls1,gk) then begin
          a[l]:=gk; Inc(l);
        end;
        Next;
      end;
      DeleteTableFldList(a,l,fMGK);
    end;
  end;
  DelStack;
end;

procedure StMemoDelUnused(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var lst: TStringList;
  at: TArrArrStr;
  agk0: array of record
    a: TArrStr;
    l: longint;
  end;
  i: longint;
  lsgk,lsmgk: TIntegerList;
  procedure Arr0(dw: longword);
  var n: longint;
  begin
    AddStack('FrmPswd.StMemoDelUnused.Arr0');
    if not lsmgk.IntObjFindAdd(dw,n) then begin
      if Length(agk0)=n then SetLength(agk0,n shl 1);
      with agk0[n] do begin
        SetLength(a,10); l:=0;
      end;
    end;
    with agk0[n] do begin
      if Length(a)=l then SetLength(a,l shl 1);
      a[l]:=Vtos(lsgk[i]); Inc(l);
    end;
    DelStack;
  end;
var lsf,ls1: TStringList;
  amgk: TArrArrInt;
  j,k,l,m,n,nm,gk,dw: longint;
  a: TArrStr;
  a1: array[1..2] of string;
  s: string;
  lt,lf: boolean;
  av: TArrVar;
  r: TRecDBDef;
begin
  AddStack('FrmPswd.StMemoDelUnused');
  with ProgPswd do begin
    GetQuery; lsf:=SortStrListCreate; ls1:=SortStrListCreate;
    try
      lst:=SortStrListCreate; lsgk:=TIntegerList.Create([ilsSorted]); lsmgk:=TIntegerList.Create([ilsSorted]);
      try
        with LsCustomRec do begin
          i:=Count; SetLength(at,i);
          for i:=0 to i-1 do
            if IsClass(Objects[i],TRecDBDef,pointer(r)) then if not empty(r.NameDB) then begin
              s:=r.FixSt(sArray);
              if not IntObjFindAdd(lst,r.NameDB,j) then CopyFrom(at[j],s)
              else if not AnsiMatchText(s,at[j]) then AddFrom(at[j],s);
            end;
        end;
        l:=lst.Count; SetLength(at,l); SetLength(amgk,10); 
        for i:=0 to l-1 do begin
          if Sender.SayStat('','Таблица: '+lst[i],(i+1)/l) then break;
          GetFieldNames(lst[i],lsf); j:=IntObj(lst,i); k:=0;
          while k<lsf.Count do
            if AnsiStartsArr(at[j],lsf[k]) then Inc(k) else lsf.Delete(k);
          if k>0 then with CurQuery do begin
            s:=''; SetLength(av,k); CopyFrom(at[j],lsf);
            for k:=0 to k-1 do begin
              av[k]:=lsf[k]; IncD(s,sOR+lsf[k]+'>0');
            end;
            PartSelect(lst[i],av,Copy(s,lOR1,MaxInt));
            while not Eof do begin
              for k:=low(av) to high(av) do begin
                gk:=Fields[k].AsInteger;
                if gk>0 then begin
                  dw:=MakeLong(k,i);
                  if lsgk.IntObjFindAdd(gk,j,n) then if n<>dw then begin
                    if not lsmgk.IntObjFindAdd(gk,m,nm) then begin
                      if Length(amgk)=nm then SetLength(amgk,nm shl 1);
                      CopyFromInt(amgk[nm],n);
                    end;
                    if not ArrIntMatch(dw,amgk[nm]) then AddFromInt(amgk[nm],dw);
                    dw:=-(nm+1);
                  end;
                  lsgk.Objects[j]:=pointer(dw);
                end
              end;
              Next;
            end;
          end;
        end;
        if not Sender.Aborted and IsTable(tARR) then
          if not Sender.SayStat('Поиск неиспользуемых массивов') then with CurQuery do begin
            PartSelect(tARR,fMGK,'','',fMGK); l:=RecordCount; SetLength(a,l); j:=0;
            for i:=1 to l do begin
              if Sender.SayStat(i/l) then break;
              gk:=Fields[0].AsInteger;
              if not lsgk.FindDel(gk) then begin
                a[j]:=Vtos(gk); Inc(j);
              end;
              Next;
            end;
            if not Sender.Aborted then RDBArr.DelRec(a,j,fMGK);
          end;
        if not Sender.Aborted then begin
          l:=lsgk.Count;
          if l>0 then if not Sender.SayStat('Обнуление ссылок на несуществующие массивы') then begin
            lsmgk.Clear; SetLength(agk0,10);
            for i:=0 to l-1 do begin
              j:=lsgk.IntObj(i);
              if j<0 then begin
                j:=-(j+1);
                for k:=low(amgk[j]) to high(amgk[j]) do Arr0(amgk[j,k]);
              end
              else Arr0(j);
            end;
            l:=lsmgk.Count;
            for i:=0 to l-1 do begin
              if Sender.SayStat((i+1)/l) then break;
              dw:=lsmgk[i]; j:=HiWord(dw); s:=at[IntObj(lst,j),Word(dw)];
              with agk0[lsmgk.IntObj(i)] do CurQuery.UpdateTableFldList([s],[0],a,l,s,[],lst[j]);
            end;
          end;
        end;
      finally
        at:=nil; lst.Free; lsgk.Free; lsmgk.Free;
      end;
      if not Sender.Aborted then
        if not Sender.SayStat('Поиск используемых текстовых значений') then begin
          lst:=StMemoFldProc(Sender,lsf,StMemoDelUnused1,[longint(ls1),longint(CurQuery)]);
          if not Sender.Aborted then
            if not Sender.SayStat('Поиск неиспользуемых текстовых значений') then with CurQuery do begin
              for k:=low(aMemoFld) to high(aMemoFld) do if IsTable(aMemoTbl[aMemoFld[k]]) then begin
                PartSelect(aMemoTbl[aMemoFld[k]],'FLD',QQNull('FLD','',true),'FLD','FLD');
                l:=RecordCount; SetLength(a,l); j:=0; s:=''; lt:=false;
                for i:=1 to l do begin
                  ListAsArray(TrimRight(Fields[0].AsString),a1,'.');
                  if a1[1]<>s then begin
                    s:=a1[1];
                    if Sender.SayStat('','Таблица: '+s,i/l) then break;
                    lt := lst.IndexOf(s)>=0;
                    if lt then MulQry.GetFieldNames(s,lsf);
                  end;
                  if lt then lf := lsf.IndexOf(aBegMem[aMemoFld[k]]+a1[2])>=0 else lf:=false;
                  if not lf then begin
                    a[j]:=QQs(Fields[0]); Inc(j);
                  end;
                  Next;
                end;
                if not Sender.Aborted then DeleteTableFldList(a,j,'FLD');
              end;
            end;
        end;
    finally
      lsf.Free; ls1.Free; FreeQuery;
    end;
  end;
  DelStack;
end;

function TFormPswd.MemoDelUnused;
var p: TArrSetGk0NoCorKa;
  i: longint;
label lend;
begin
  AddStack('TFormPswd.MemoDelUnused',Self);
  result:=false;
  try
    p.ProcErr:=ProcErr; p.AskErr:=AskErr;
    if not ArrRdbSeek('Проверка массивов на соответствие описанию','','',ArrSetGk0NoCorKa,@p) then goto lend;
    if not SetMemoFld then goto lend;
    if ShowStat('Поиск используемых массивов',StMemoDelUnused) then goto lend;
    result:=true;
lend:
  finally
    for i:=low(p.af) to high(p.af) do p.af[i].q.Free;
  end;
  DelStack;
end;

procedure ConvertDateBigTbl(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var lsf: TMQFieldList;
  ad: PArrInt;
  i,l: longint;
  j: byte;
  nmf: string;
begin
  AddStack('FrmPswd.ConvertDateBigTbl');
  lsf:=PointerVar(Params[0]); ad:=PointerVar(Params[1]); l:=Params[2];
  with MulQueryVar(Params[3]) do for i:=0 to l-1 do begin
    nmf:=lsf[ad^[i]];
    if Sender.SayStat('','Поле: '+nmf,(i+1)/l) then break;
    for j:=low(DateBigOld) to high(DateBigOld) do
      UpdateTable('',[nmf],[DateBigOld[j,true]],nmf+'='+VarToS(DateBigOld[j,false]));
  end;
  DelStack;
end;

procedure StConvertDateBig(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var lst: TStringList;
  lsf: TMQFieldList;
  i,j,l,n,lr: longint;
  ad: TArrInt;
  aRdb: PArrRecDBDef;
  Capt: TCaption;
begin
  AddStack('FrmPswd.StConvertDateBig');
  aRdb:=PointerVar(Params[0]);
  with ProgPswd,GetQuery do begin
    Arg[sC_LIST]:=sMemo; Arg[sV_LIST]:=DateBig;
    lst:=GetTableList; n:=0; lr:=lst.Count+Length(aRdb^);
    for i:=0 to lst.Count-1 do begin
      Capt:='Таблица: '+lst[i]; Inc(n);
      if Sender.SayStat('',Capt,n/lr) then break;
      lsf:=GetFieldList(lst[i]); l:=0;
      if Length(ad)<lsf.Count then SetLength(ad,lsf.Count);
      for j:=0 to lsf.Count-1 do
        if lsf.Fields(j).DataType=ftDate then begin
          ad[l]:=j; Inc(l);
        end;
      if l>0 then begin
        Arg[sTABLE]:=lst[i];
        if ShowStat(Capt,ConvertDateBigTbl,[Longint(lsf),Longint(@ad),l,longint(CurQuery)],l) then begin
          Sender.Abort; break;
        end;
      end;
    end;
    for i:=low(aRdb^) to high(aRdb^) do begin
      Capt:='Таблица: '+aRdb^[i].NameDB; Inc(n);
      if Sender.SayStat('',Capt,n/lr) then break;
      if not aRdb^[i].ConvertDateBig(Capt) then begin
        Sender.Abort; break;
      end;
    end;
    FreeQuery;
  end;
  DelStack;
end;

function TFormPswd.ConvertDateBig;
var aRdb: TArrRecDBDef;
  i: longint;
begin
  AddStack('TFormPswd.ConvertDateBig',Self);
  SetLength(aRdb,Length(acRdb));
  for i:=low(aRdb) to high(aRdb) do aRdb[i]:=acRdb[i];
  result:=not ShowStat('Преобразование максимальной даты',StConvertDateBig,[longint(@aRdb)]);
  DelStack;
end;

function TFormPswd.PartCount;
begin
  AddStack('TFormPswd.PartCount',Self);
  result:=GetQuery.PartCount(table,where); FreeQuery;
  DelStack;
end;

function TFormPswd.PartCount0;
begin
  AddStack('TFormPswd.PartCount0',Self);
  result:=GetQuery.PartCount0(table,where); FreeQuery;
  DelStack;
end;

function TFormPswd.VarToS(const vv: variant; Opt: TVarToSOpt = []): string;
begin
  AddStack('TFormPswd.VarToS',Self);
  result:=GetQuery.VarToS(vv,Opt); FreeQuery;
  DelStack;
end;

function TFormPswd.VarToS(const vv: variant; Opt: TVarToSList): string;
begin
  result:=VarTos(vv,[Opt]);
end;

function TFormPswd.VarToS(f: TField; Opt: TVarToSOpt = []): string;
begin
  result:=VarTos(f.Value,Opt);
end;

procedure TFormPswd.UpdateTable;
begin
  AddStack('TFormPswd.UpdateTable',Self);
  GetQuery.UpdateTable(table,c_list,v_list,where); FreeQuery;
  DelStack;
end;

function TFormPswd.DeleteTable;
begin
  AddStack('TFormPswd.DeleteTable',Self);
  result:=GetQuery.DeleteTable(table,where,lMsg); FreeQuery;
  DelStack;
end;

function TFormPswd.FldInSel;
begin
  AddStack('TFormPswd.FldInSel',Self);
  result:=GetQuery.FldInSel(nmf,tbl,where,snmf,Opt,ares,group,qs,ls); FreeQuery;
  DelStack;
end;

function TFormPswd.GetList;
begin
  AddStack('TFormPswd.GetList',Self);
  result:=GetQuery.GetList(aa,l); FreeQuery;
  DelStack;
end;

function TFormPswd.Concat;
begin
  AddStack('TFormPswd.Concat',Self);
  result:=GetQuery.Concat(a,l); FreeQuery;
  DelStack;
end;

function TFormPswd.GetPart;
begin
  AddStack('TFormPswd.GetPart',Self);
  result:=GetQuery.GetPart(name,argname,argval); FreeQuery;
  DelStack;
end;

function TFormPswd.PartMaxInt;
begin
  AddStack('TFormPswd.PartMaxInt',Self);
  result:=GetQuery.PartMaxInt(table,nmf,where); FreeQuery;
  DelStack;
end;

function TFormPswd.DropTable;
begin
  AddStack('TFormPswd.DropTable',Self);
  result:=GetQuery.DropTable(tbl,msgErr); FreeQuery;
  DelStack;
end;

function TFormPswd.QQDate;
begin
  AddStack('TFormPswd.QQDate',Self);
  result:=GetQuery.QQDate(nmf,db,de); FreeQuery;
  DelStack;
end;

procedure TFormPswd.DBFlush;
var i: longint;
  a: TArrBool;
begin
  AddStack('TFormPswd.DBFlush',Self);
  SetLength(a,BusyQuerys);
  for i:=0 to BusyQuerys-1 do a[i]:=amq[i].q.Active;
  GetQuery.DBFlush(Opt); FreeQuery;
  for i:=0 to BusyQuerys-1 do if a[i] then amq[i].q.Open;
  DelStack;
end;

procedure TFormPswd.MaxFldClear;
begin
  AddStack('TFormPswd.MaxFldClear',Self);
  QryMsg.MaxFldClear(nmTbl);
  DelStack;
end;

procedure TFormPswd.LogInit;
var i,lo,v: longint;
begin
  AddStack('TFormPswd.LogInit',Self);
  lo:=Length(aLogVidOrd); SetLength(aLogVidOrd,lo+Length(aVid));
  for i:=low(aVid) to high(aVid) do begin
    v:=aVid[i].v-lLogVid;
    aLogVid[v]:=aVid[i]; TransPrimSelf(aLogVid[v].nm);
    aLogVidOrd[lo]:=aVid[i].v; Inc(lo);
  end;
  Dec(lKeys,lLogKeys);
  for i:=low(aKeys) to high(aKeys) do begin
    aLogKeys[lKeys]:=aKeys[i]; TransPrimSelf(aLogKeys[lKeys].nm); Inc(lKeys);
  end;
  DelStack;
end;

function TFormPswd.GetLogVid;
begin
  AddStack('TFormPswd.GetLogVid',Self);
  result:=logvNone;
  if Assigned(Self) then if lLog>=0 then result:=aLog[lLog].Prm[LogDop].vid;
  DelStack;
end;

procedure TFormPswd.SetLogVid;
begin
  AddStack('TFormPswd.SetLogVid',Self);
  if Assigned(Self) then if Assigned(QryLog) then
    if Value=logvNone then begin
      if LogDop then aLog[lLog].Prm[true].vid:=logvNone
      else if lLog>=0 then Dec(lLog);
      LogFields.Clear;
    end
    else begin
      if not LogDop then begin
        Inc(lLog);
        if lLog=Length(aLog) then SetLength(aLog,lLog shl 1);
        aLog[lLog].Prm[true].vid:=logvNone;
        aLog[lLog].lDop:=-1;
        if Length(aLog[lLog].aDop)=0 then SetLength(aLog[lLog].aDop,1);
      end;
      aLog[lLog].Prm[LogDop].vid:=Value;
      aLog[lLog].Prm[LogDop].dbeg:=Now;
    end;
  DelStack;
end;

function TFormPswd.CngLogVid(Value: longint; OnlyCng: boolean = false): longint;
begin
  AddStack('TFormPswd.CngLogVid',Self);
  result:=LogVid;
  if ((result=logvNone) or (Value=logvNone)) and not(OnlyCng and (lLog>=0))
  then LogVid:=Value
  else aLog[lLog].Prm[LogDop].vid:=Value;
  DelStack;
end;

function TFormPswd.CngLogVid(rdb: TRecDB; OnlyCng: boolean = false): longint;
begin
  result:=CngLogVid(rdb.LogVidRecno,OnlyCng);
end;

function TFormPswd.GetPLogKeys;
begin
  AddStack('TFormPswd.GetPLogKeys',Self);
  New(result); LogKeysCopy(result^,LogKeys);
  DelStack;
end;

procedure TFormPswd.SetPLogKeys;
begin
  AddStack('TFormPswd.SetPLogKeys',Self);
  if Assigned(Value) then begin
    LogKeysCopy(LogKeys,Value^); Dispose(Value); 
  end;
  DelStack;
end;

function TFormPswd.PLogKeysLen;
begin
  AddStack('TFormPswd.PLogKeysLen',Self);
  result:=PLogKeys; SetLength(LogKeys,Len);
  DelStack;
end;

procedure TFormPswd.LogWrite;
  procedure Wr1(const Prm: TLogPrm; d: TDateTime; const tbl,prim,KeyStack: string; const LogKeys: TLogKeysSave);
  var s: string;
    i,j: longint;
    fl: boolean;
  begin
    AddStack('TFormPswd.LogWrite.Wr1',Self);
    with QryLog do begin
      SetParamValue(0,Vtos(Double(d)+TblSQLTimeOffs));
      s:='';
      for i:=low(LogKeys) to high(LogKeys) do with LogKeys[i] do begin
        fl:=true;
        for j:=low(LogKeys) to i-1 do if (LogKeys[j].key=key) and (LogKeys[j].val=val) then begin
          fl:=false; break;
        end;
        if fl then IncD(s,DlmBetween(aLogKeys[key-lLogKeys].cod,val,'=')+UnDelim);
      end;
      SetParamValue(1,QQs(s));
      SetParamValue(4,QQs(tbl));
      SetParamValue(5,Vtos(Prm.vid));
      SetParamValue(6,Vtos(Double(Prm.dbeg)+TblSQLTimeOffs));
      SetParamValue(7,Vtos(LogUn)); Inc(LogUn);
      SetParamValue(8,QQs(Str3t(KeyStack,lLogKeystack)));
      s:=StrTran(TrimRight(prim),CRLF,LogCRLF); i:=0;
      repeat
        SetParamValue(2,Vtos(i)); SetParamValue(3,QQs(LeftStr(s,lLogPrim))); ExecTry;
        CopySelf(s,lLogPrim+1); Inc(i);
      until s='';
    end;
    DelStack;
  end;
var i: longint;
begin
  AddStack('TFormPswd.LogWrite',Self);
  if LogVid<>logvNone then with QryLog,aLog[lLog] do
    if Prm[true].vid=logvNone then begin
      for i:=0 to lDop do with aDop[i],Prm do Wr1(Prm,d,tbl,prim,KeyStack,LogKeys);
      lDop:=-1; Wr1(Prm[false],Now,tbl,prim,GetKeyStack,LogKeys);
    end
    else begin
      Inc(lDop);
      if lDop=Length(aDop) then SetLength(aDop,lDop shl 1);
      aDop[lDop].d:=Now;
      aDop[lDop].Prm:=Prm[true];
      aDop[lDop].tbl:=tbl;
      aDop[lDop].prim:=prim;
      aDop[lDop].KeyStack:=GetKeyStack;
      LogKeysCopy(aDop[lDop].LogKeys,LogKeys);
    end;
  DelStack;
end;

procedure TFormPswd.FixKeyProc;
begin
  AddStack('TFormPswd.FixKeyProc',Self);
  TKeyLb.FixKeyShow(Key,false); KeyEvalProc(Key,tw,aPswdKeyProc); TKeyLb.FixKeyShow(Key,true);
  DelStack;
end;

procedure TFormPswd.WMNoCngWState;
begin
  AddStack('TFormPswd.WMNoCngWState',Self);
  if NoCngWState then Message.Result:=1;
  DelStack;
end;

procedure TFormPswd.WMTimeChange;
begin
  AddStack('TFormPswd.WMTimeChange',Self);
  inherited;
  DisposeNil(pointer(FTblSQLTimeOffs));
  DelStack;
end;

{ TServicesList }
const GDS_DB = 'gds_db';

constructor TServicesList.Create;
var i: longint;
  si: TServiceInfo;
  fl: boolean;
begin
  AddStack('TServicesList.Create');
  LoadFromFile(FileServices); oText:=Text; nPortIB:=-1; i:=0; fl:=false;
  while i<Count do begin
    si:=StrToService(Strings[i]);
    if (si.Name=GDS_DB) and (si.Protocol=TCP) then
      if nPortIB<0 then nPortIB:=i
      else begin
        Delete(i); fl:=true; continue;
      end;
    Inc(i);
  end;
  if fl then AddFrom(aErr,['Удалены дублирующие определения порта Interbase.',
    'Необходима перезагрузка системы.']);
  DelStack;
end;

destructor TServicesList.Destroy;
begin
  AddStack('TServicesList.Destroy');
  ChkReboot;
  inherited Destroy;
  DelStack;
end;

procedure TServicesList.SetPortIB;
var de: TDefEdit;
  r: TRecVal;
  si: TServiceInfo;
  s: string;
  av: TDEPrmVar;
begin
  AddStack('TServicesList.SetPortIB');
  de:=TDefEdit.Create(Application.MainForm); r:=TRecVal.Create(Application.MainForm);
  try
    de.NameWnd:='IBPort'; r.CreateFld('PORT',ftInteger,0,0); r.OpenRec;
    if nPortIB<0 then si.Port:=0
    else begin
      si:=StrToService(Strings[nPortIB]); r['PORT']:=si.Port;
    end;
    InitArr(av);
    av[deCaption]:='Введите номер порта Interbase';
    av[deNameRec]:=r.NameRec;
    av[deNameRecFld]:='PORT';
    TSpinGet.AssignGetClass(av);
    av[deMask]:='0,999999';
    av[deAutoSel]:=true;
    av[deNoReadOnly]:=true;
    de.CreateFld(av);
    if de.Execute(Capt).Saved then begin
      if r['PORT']=0 then begin
        if nPortIB>=0 then Delete(nPortIB);
      end
      else if r['PORT']<>si.Port then begin
        s:=Trim(AnsiLowerCase(GDS_DB))+Format(' %d/',[longint(r['PORT'])])+Trim(AnsiLowerCase(TCP));
        if nPortIB<0 then nPortIB:=Add(s) else Strings[nPortIB]:=s;
      end;
      aErr:=nil;
    end;
  finally
    de.Free; r.Free;
  end;
  DelStack;
end;

function TServicesList.ChkReboot;
begin
  AddStack('TServicesList.ChkReboot');
  if Text=oText then result:=false
  else begin
    oText:=Text; SaveToFile(FileServices); result:=RebootMsg(aErr);
  end;
  DelStack;
end;

{ TDerMemo }
constructor TDerMemo.CreateParent;
const SCE_OURLIB_WORD_KEY = SCE_OURLIB_WORD_OPERATOR; kwKey = SCE_OURLIB_WORD_KEY-SCE_OURLIB_WORD_FIRST;
var i: longint;
  fl: boolean;
begin
  AddStack('TDerMemo.CreateParent',Self);
  inherited CreateParent(AOwner,AParent);
  for fl:=false to true do with PropDef[fl].aFont[SCE_OURLIB_WORD_KEY] do begin
    FontStylesCng:=true; Include(FontStyles,fsBold);
  end;
  for i:=low(CngFont) to high(CngFont) do with CngFont[i] do
    if an[0]=SCE_OURLIB_WORD_KEY then begin
      Caption:='Клавиши'; break;
    end;
  KeywordBeginUpdate; KeywordN(kwKey).Clear;
  for i:=1 to KEY_USER do KeywordN(kwKey).Add(KeyToTxt(i,true));
  KeywordEndUpdate;
  DelStack;
end;

class function TDerMemo.AlwaysReadOnly;
begin
  result:=true;
end;

{ TSqlTblLogCompare }
class function TSqlTblLogCompare.ListCreate;
var a: TSQLExecStr;
  ls: TStringList;
  j: TSQLExecType;
  at: TArrStr;
  i,n: longint;
  st: TSQLExecTypes;
begin
  AddStack('TSqlTblLogCompare.ListCreate');
  result:=inherited ListCreate(pv,Value,lNew); ls:=result; ls.Sorted:=true; LsArrFill(Trim(Value),a,dlmSQLExec);
  for j:=low(a) to high(a) do
    for i:=0 to LsArrDynamic(a[j],at,dlmSQLTbl)-1 do begin
      n:=ls.Add(Trim(at[i])); st:=TSQLExecTypes(byte(ls.Objects[n])); Include(st,j);
      ls.Objects[n]:=pointer(byte(st));
    end;
  DelStack;
end;

function LogCompareStrSqlTbl(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var j: TSQLExecType;
  st: TSQLExecTypes;
begin
  AddStack('FrmPswd.LogCompareStrSqlTbl');
  st:=TSQLExecTypes(byte(p)); result:='';
  for j:=low(aSQLExecCapt) to high(aSQLExecCapt) do
    if j in st then IncD(result,FLow(aSQLExecCapt[j])+',');
  DecLen(result);
  DelStack;
end;

class procedure TSqlTblLogCompare.GetItem;
var sln: TStringList;
begin
  AddStack('TSqlTblLogCompare.GetItem');
  sln:=lsn;
  if tp=clogNoKey then Prm.val:=Int2Str(sln,nn)
  else begin
    inherited GetItem(Prm,pv,lso,lsn,no,nn,tp);
    if tp=clogPrn then begin
      DlmBetwSelf(Prm.val,GetPrim(Prm.val,false),'. '); IncD(Prm.val,CRLF);
      TStrLogCompare.AddRes(LogCompareStrSqlTbl,Prm,TStringList(lso).Objects[no],sln.Objects[nn]);
    end;
  end;
  DelStack;
end;

function FMnName(tp: TDBTypeList; n: longint): string;
begin
	AddStack('FrmPswd.FMnName');
  if n>0 then result:=aDBType[tp].g.MenuName(IntToStr(n)) else result:='';
  DelStack;
end;

function FdeSeek(n: longint): TDefEdit;
begin
	AddStack('FrmPswd.FdeSeek');
  result:=TDefEdit.Find(FMnName(dbtpDriver,n));
  DelStack;
end;

function IbPathToServName(path: TInterbasePath; const port,ip,drv,FileIdentProg: string; ext: TInterbaseExt): string;
begin
  AddStack('FrmPswd.IbPathToServName');
  if path=ibppRemoved then begin
    result:=Trim(port);
    result:=Trim(ip)+IfThen(result<>'','/'+result)+DriveDelim+Trim(drv)+DriveDelim
      +Copy(ExeDir,Length(ExtractFileDrive(ExeDir))+1,MaxInt)+DirDatas
  end
  else result:=DirDATAs;
  IncD(result,ChangeFileExt(FileIdentProg,'.'+aInterbaseExt[ext]));
  DelStack;
end;

{ TSQLDM }
class procedure TSQLDM.Load;
var a: TDEPrmVar;
  dg: TDirGet;
begin
  AddStack('TSQLDM.Load');
  if not Assigned(SQLDM) then begin
    SQLDM:=TSQLDM.Create(Application.MainForm);
    with SQLDM do begin
      RPrm:=TRecVal.Create(SQLDM); RPrm.CreateFld('Z',ftBoolean,0,false);
      OpenDialog1:=TOpenDialog.Create(SQLDM);
      StdDrvGet:=TComboGet.Create(SQLDM); StdDrvGet.VName:='StdDrv';
      dg:=TDirGet.Create(SQLDM); dg.VName:='Dir';
      InitArr(a);
      a[deNameRec]:=RPrm.NameRec;
      a[deNoReadOnly]:=true;
      deIntrbase:=TDefEdit.Create(SQLDM);
      with deIntrbase do begin
        FrmCaption:='Параметры (Interbase)'; NameWnd:='INTRBASE'; PnlSortMode:=smColumns;
        OnFrmShow:=deIntrbaseFrmShow;
        OnFldEnter:=deIntrbaseFldEnter; OnFldExit:=deIntrbaseFldExit;
        OnFldChange:=deIntrbaseFldChange; OnFldCheck:=deIntrbaseFldCheck;

        a[deCaption]:='Размещение:';
        a[deNameRecFld]:='Z';
        TMultiGet.AssignGetClass(a);
        a[deMask]:=Int2Str(smRows);
        CreateFld(a);

        a[deCaption]:='';
        a[deNameRecFld]:=ibpPath;
        TRadioGet.GetFirst.AssignGet(a);
        a[deMask]:=RadioMask(aIbpp,0);
        a[deRelation]:=RPrm.NameRec+'.Z';
        CreateFld(a);

        a[deCaption]:='Расширение';
        a[deNameRecFld]:=ibpExt;
        a[deMask]:=RadioMask(aInterbaseExt,0);
        CreateFld(a);

        a[deCaption]:='Порт';
        a[deNameRecFld]:=ibpPort;
        TSimpleGet.AssignGetClass(a);
        a[deMask]:='';
        a[deMaxLen]:=6;
        a[deAutoSel]:=true;
        a[deReadOnlyNoVsbl]:=true;
        a[deTrimLeft]:=true;
        CreateFld(a);

        a[deCaption]:='Компьютер'+UnDelim+'(IP-адрес)';
        a[deNameRecFld]:=ibpIP;
        a[deMaxLen]:=40;
        CreateFld(a);

        a[deCaption]:='Диск';
        a[deNameRecFld]:=ibpDrv;
        a[deMaxLen]:=2;
        CreateFld(a);

        with TDirGet.Create(SQLDM) do begin
          VName:='File'; OpenDialog:=OpenDialog1; Options:=[dgServerName];
          Items.Text:=ArrayAsList(
            [DirDatas+'BW.FDB'
            ,DirDatas+'ZPW.FDB'
            ,'mainb:C:'+PathDelim+'GG'+PathDelim+'BW'+PathDelim+DirDatas+'BW.FDB'
            ,'mainz:C:'+PathDelim+'GG'+PathDelim+'ZPW'+PathDelim+DirDatas+'ZPW.FDB'
            ],CRLF);
          a[deCaption]:='База данных';
          a[deNameRecFld]:=ibpServerName;
          AssignGet(a);
          a[deMaxLen]:=0;
          a[deReadOnlyNoVsbl]:=false;
          a[deRelation]:='';
          a[deWidth]:=wallNoSay;
          CreateFld(a);
        end;

        a[deCaption]:='Пользователь';
        a[deNameRecFld]:=ibpUserName;
        TSimpleGet.AssignGetClass(a);
        a[deMaxLen]:=12;
        a[deWidth]:=0;
        CreateFld(a);

        a[deCaption]:='Соединение:';
        a[deNameRecFld]:=ibpType;
        TRadioGet.GetFirst.AssignGet(a);
        a[deMask]:=RadioMask(aIBType,0);
        a[deMaxLen]:=0;
        CreateFld(a);

        a[deCaption]:='Библиотека:';
        a[deNameRecFld]:=ibpFIBDll;
        a[deMask]:=RadioMask(['GDS32 (стандартная)','Firebird'],0);
        a[deReadOnlyNoVsbl]:=true;
        CreateFld(a);

        a[deCaption]:='';
        a[deNameRecFld]:=ibpFBLocal;
        TBoolGet.CreateOne.AssignGet(a);
        a[deMask]:='Использовать встроенный Firebird';
        a[deReadOnlyNoVsbl]:=false;
        CreateFld(a);

        a[deNameRecFld]:=ibpFIBNoGC;
        a[deMask]:='Отключить сборку "мусора"';
        a[deReadOnlyNoVsbl]:=true;
        CreateFld(a);
      end;
      deStandard:=TDefEdit.Create(SQLDM);
      with deStandard do begin
        FrmCaption:='Параметры (Standard)'; NameWnd:='STANDARD'; PnlSortMode:=smColumns;
        OnFrmShow:=deStandardFrmShow;

        a[deCaption]:='Папка';
        a[deNameRecFld]:=stpPath;
        dg.AssignGet(a);
        a[deMask]:='';
        a[deReadOnlyNoVsbl]:=false;
        a[deWidth]:=wallDefault;
        CreateFld(a);

        a[deCaption]:='Драйвер';
        a[deNameRecFld]:=stpDefaultDriver;
        StdDrvGet.AssignGet(a);
        a[deMask]:=cOnlyList+'~0';
        a[deWidth]:=0;
        CreateFld(a);
      end;
{ $IFDEF OLDCNF
      deMySQL:=TDefEdit.Create(SQLDM);
      with deMySQL do begin
        FrmCaption:='Параметры (MySQL)'; NameWnd:='MYSQL'; PnlSortMode:=smColumns;

        a[deCaption]:='Папка с данными';
        a[deNameRecFld]:=stpPath;
        dg.AssignGet(a);
        a[deMask]:='Папка с данными';
        a[deWidth]:=wallNoSay;
        CreateFld(a);

        a[deCaption]:='Пользователь';
        a[deNameRecFld]:=ibpUserName;
        TSimpleGet.AssignGetClass(a);
        a[deMaxLen]:=12;
        a[deWidth]:=0;
        a[deTrimLeft]:=true;
        CreateFld(a);

        a[deCaption]:='IP-адрес центрального компьютера';
        a[deNameRecFld]:=ibpIP;
        a[deMask]:='999.999.999.999';
        a[deMaxLen]:=0;
        a[deReadOnlyNoVsbl]:=true;
        a[deWidth]:=0;
        a[deTrimLeft]:=false;
        CreateFld(a);
      end;
{$ENDIF}
      TDBPrmGet.Create(SQLDM);
    end;
  end;
  DelStack;
end;

var deCaption: string;

// deIntrbase
procedure TSQLDM.deIntrbaseFrmShow(Sender: TObject);
begin
	AddStack('TSQLDM.deIntrbaseFrmShow',Self);
  OpenDialog1.Title:=deCaption;
  if not Assigned(ProgPswd) then deIntrbase.SetReadOnly(ibpPath,true,ibppNoStd);
  DelStack;
end;

procedure TSQLDM.deIntrbaseFldChange(Sender: TObject;
  const OldVal: Variant; FromShow: Boolean);
var fl,lPath,lServerName,lType,lExt,IsFIB: boolean;
  ov: string;
  tf: TFldEdit;
  p: TInterbasePath;
  e: TInterbaseExt;
begin
  AddStack('TSQLDM.deIntrbaseFldChange',Self);
  with TFldEdit(Sender),deIntrbase do begin
    lPath := NameRecFld=ibpPath; lServerName := NameRecFld=ibpServerName; lType := NameRecFld=ibpType;
    lExt := NameRecFld=ibpExt;
    p:=TInterbasePath(Int0(RPrm[ibpPath])); e:=TInterbaseExt(Int0(RPrm[ibpExt]));
    if Assigned(ProgPswd) and (p<>ibppNoStd)
    and (lPath or lExt or AnsiMatchText(NameRecFld,[ibpPort,ibpIP,ibpDrv]))
    then FldValue[ibpServerName]:=IbPathToServName(p,RPrm[ibpPort],RPrm[ibpIP],RPrm[ibpDrv],
      ProgPswd.FileIdentProg,e);
    if lPath then begin
      SetReadOnly([ibpIP,ibpDrv],p<>ibppRemoved);
      fl := p<>ibppNoStd; SetReadOnly(ibpPort,not fl);
      tf:=FldEdit[ibpServerName]; tf.SetReadOnly(fl);
      if not(fl or FromShow) then tf.SetFocus;
    end;
    if lExt then with OpenDialog1 do begin
      DefaultExt:=aInterbaseExt[e]; Filter:='Базы данных (*.'+DefaultExt+')|*.'+DefaultExt;
    end;
    if lServerName or lType or (NameRecFld=ibpFIBDll) then with FldEdit[ibpFBLocal] do begin
      ov:=Value; IsFIB := TInterbaseType(Int0(RPrm[ibpType]))=ibtFIB;
      if IsSQLLocalPath(RPrm[ibpServerName]) then begin
        Vid:=TBoolGet.ClassName; Mask:='Использовать встроенный Firebird';
        fl := IsFIB and (Int0(RPrm[ibpFIBDll])=1);
        if fl then ov:=bFalse;
      end
      else begin
        Vid:=TBtMskGet.ClassName;
        Mask:=ButPrm2Mask('Проверка связи с центральным компьютером','SrvConnect()');
        fl:=false;
      end;
      Value:=ov; SetReadOnly(fl);
      if lType then deIntrbase.SetReadOnly([ibpFIBDll,ibpFIBNoGC],not IsFIB);
    end;
  end;
  DelStack;
end;

procedure TSQLDM.deIntrbaseFldEnter(Sender: TObject);
var tf: TFldEdit;
begin
  AddStack('TSQLDM.deIntrbaseFldEnter',Self);
  tf:=pointer(Sender);
  if tf.NameRecFld=ibpPath
    then FormKeyLb(tf).SetKey(K_F2,'','Установить размещение "'+aIbpp[ibppNoStd]+'"',UserKeyProc,'userkey',kmNone)
  else if tf.NameRecFld=ibpUserName
    then FormKeyLb(tf).SetKey(K_Ctrl_F5,'','Установить имя пользователя по умолчанию ('+sSYSDBA+')',UserKeyProc,'userkey',kmNone);
  DelStack;
end;

procedure TSQLDM.deIntrbaseFldExit(Sender: TObject);
var tf: TFldEdit;
begin
  AddStack('TSQLDM.deIntrbaseFldExit',Self);
  tf:=pointer(Sender);
  if AnsiMatchText(tf.NameRecFld,[ibpPath,ibpUserName]) then FormKeyLb(tf).DelKey(K_All,'userkey');
  DelStack;
end;

procedure TSQLDM.UserKeyProc;
begin
  AddStack('TSQLDM.UserKeyProc',Self);
  case Key of
    K_F2: with deIntrbase.FldEdit[ibpPath] do
      if VarValue=ibppNoStd then deIntrbase.SetFocus(ibpServerName) else VarValue:=ibppNoStd;
    K_Ctrl_F5: deIntrbase.FldValue[ibpUserName]:=sSYSDBA;
  end;
  DelStack;
end;

function TSQLDM.deIntrbaseFldCheck(Sender: TObject): Boolean;
var s: string;
begin
  AddStack('TSQLDM.deIntrbaseFldCheck',Self);
  NoEmpCheck(Sender,[ibpIP,ibpDrv],result);
  if result then with TFldEdit(Sender) do if NameRecFld=ibpDrv then begin
    s:=TrimUpper(VarValue); result := s[1] in ['A'..'Z'];
    if not result then meserr('Первый символ диска должен быть латинской буквой.')
    else if Length(s)>1 then begin
      result := s[2] in ['0'..'9','A'..'Z'];
      if not result then meserr('Второй символ диска должен быть цифрой или латинской буквой.')
    end;
  end;
  DelStack;
end;

function c_srvcon(var av: array of variant):variant;
var a: TArrSQLPath;
begin
  AddStack('FrmPswd.c_srvcon');
  result:=null; IsSQLLocalPath(SQLDM.RPrm[ibpServerName],@a);
  ShellExecute(0,nil,'PING',PChar(a.IP),nil,SW_SHOW);
  DelStack;
end;

function c_prmuser(var av: array of variant): variant;
begin
	AddStack('FrmPswd.c_prmuser');
  result:=ProgPswd.PrmUser[av[1]];
  DelStack;
end;

function d_usernum(const v,index:variant; lSave: boolean):variant;
begin
  AddStack('d_usernum');
  result:=ProgPswd.PswdPrm.UserNum;
  DelStack;
end;

// deStandard
procedure TSQLDM.deStandardFrmShow(Sender: TObject);
var w: longint;
	s: string;
  TmpCursor: hdbicur;
  Driver: DRVType;
begin
	AddStack('TSQLDM.deStandardFrmShow',Self);
	deStandard.Mask[stpPath]:=deCaption;
  if not StrToBoolean(deStandard.Param[stpDefaultDriver,deNoVisible]) and (SQLDM.StdDrvGet.Items.Count=0) then begin
    DbiInit(nil);
    try
      DbiOpenDriverList(TmpCursor); w:=0;
      repeat
        if DbiGetNextRecord(TmpCursor,dbiNOLOCK,@Driver,nil)<>DBIERR_NONE then break;
        if not((Driver.szType='INFORMIX') or (Driver.szType='ORACLE')) then
          if DbiGetDriverDesc(Driver.szType,Driver)=DBIERR_NONE then
            if (Driver.szDbType=drvSTANDARD) then begin
              s:=StrPas(Driver.szType); SQLDM.StdDrvGet.Items.Add(s); MaxSelf(w,s);
            end;
      until false;
      DbiCloseCursor(TmpCursor); StdDrvGet.LenName:=w;
      deStandard.FldEdit[stpDefaultDriver].MaxLength:=w;
      deStandard.Param[stpDefaultDriver,deMaxLen]:=IntToStr(w);
      deStandard.Visible[stpDefaultDriver] := w>0;
      deStandard.Param[stpDefaultDriver,deNoVisible]:=bStr[w=0];
    finally
      DbiExit;
    end;
  end;
  DelStack;
end;

{ TDBPrmPswdGet }
procedure TDBPrmPswdGet.CreateObj;
begin
  AddStack('TDBPrmPswdGet.CreateObj',Self);
  inherited CreateObj(tf);
  sC:=TPaintButton.Create(tf);
  with sC do begin
    Canvas:=tf.Canvas; ShowHint:=true; Hint:='Соединение'; AllowAllUp:=true; BMByName(Glyph,bmConnect);
    onClick:=TDBPrmGet(FldEditOwner(tf).curget).ConPswGetClick;
  end;
  Visible[tf]:=false; tf.ReCreateObj;
  DelStack;
end;

function TDBPrmPswdGet.AssignObj;
begin
	AddStack('TDBPrmPswdGet.AssignObj',Self);
  result:=inherited AssignObj(tf);
  if result then result:=IsClass(tf.Components[tf.ComponentCount-1],TPaintButton,pointer(sC)) else sC:=nil;
  DelStack;
end;

procedure TDBPrmPswdGet.PlaceControls;
begin
  AddStack('TDBPrmPswdGet.PlaceControls',Self);
  inherited PlaceControls(tf,Condens);
  if AssignObj(tf) then with sV do sC.SetBounds(Bounds.Right,Top,Width,Height);
  DelStack;
end;

procedure TDBPrmPswdGet.DoEnter;
var tfOwn: TFldEdit;
  tm: TFldMask;
  tl: TKeyLb;
  fl: boolean;
begin
  AddStack('TDBPrmPswdGet.DoEnter',Self);
  inherited DoEnter(tf);
  tfOwn:=FldEditOwner(tf); fl:=false;
  if tfOwn.AssignObj then if ComponentsClass(atf[pswdRead],TFldMask,pointer(tm)) then begin
    tm.ReadOnly:=TDBPrmGet(tfOwn.curget).IsStandard; fl:=not tm.ReadOnly;
  end;
	if FormKeyLb(tf,tl) then begin
    tl.SetKey(K_F5,'Соединение','',ProcKey,'dbprmgetpsw',kmServic);
    if fl then tl.SetKey(K_Ctrl_F5,'','Установить пароль по умолчанию ('+smasterkey+')',ProcKey,'dbprmgetpsw',kmNone);
  end;
  DelStack;
end;

procedure TDBPrmPswdGet.DoExit;
var tl: TKeyLb;
begin
  AddStack('TDBPrmPswdGet.DoExit',Self);
	if FormKeyLb(tf,tl) then tl.DelKey(K_All,'dbprmgetpsw');
  inherited DoExit(tf);
  DelStack;
end;

procedure TDBPrmPswdGet.ProcKey;
begin
  AddStack('TDBPrmPswdGet.ProcKey',Self);
  case Key of
    K_F5: if AssignObjOwner(FldEditOwner(tw)) then sC.Click;
    K_Ctrl_F5: FldEditOwner(tw).Value:=smasterkey;
  end;
  DelStack;
end;

{ TDBPrmGet }
procedure PrmRebuild(Sender: TObject);
begin
  AddStack('FrmPswd.PrmRebuild');
  with FldEditOwner(Sender) do SetBounds(Left,Top,Width,Height);
  MainRebuild(pointer(Sender));
  DelStack;
end;

constructor TDBPrmGet.Create;
var w: longint;
	procedure GetMenu(tp: TDBTypeList);
	var i: longint;
  begin
  	AddStack('TDBPrmGet.Create.GetMenu',Self);
    with aDBType[tp].g.Items do begin
      BeginUpdate; Text:='0'+UnDelim+'[нет]';
      for i:=0 to LsStr.Count-1 do begin
        Add(IntToStr(i+1)+UnDelim+LsStr[i]); MaxSelf(w,LsStr[i]);
      end;
      EndUpdate;
    end;
    DelStack;
  end;
const a: TDBTypeStr = ('драйвер','псевдоним');
var i,ost: longint;
	fl: TDBTypeList;
begin
	ost:=AddStack('TDBPrmGet.Create',Self);
  LsStr:=TStringList.Create;
  if not Assigned(TypeGet) then begin
  	TypeGet:=TRadioGet.Create(Owner); TypeGet.VName:='DatType';
    w:=0;
    for fl:=low(fl) to high(fl) do with aDBType[fl] do begin
    	TypeGet.Items.Add(a[fl]); g:=TMenuGet.Create(Owner); g.VName:='DB'+f;
    end;
  	DBPrmGet:=TButGet.Create(Owner); DBPrmGet.VName:='DBPrm'; DBPrmGet.Caption:='Параметры';
    DBPrmGet.OnClick:=PrmGetClick;
  	LsStr.Sorted:=true;
    try
      Session.GetAliasNames(LsStr); GetMenu(dbtpAlias);
      Session.GetDriverNames(LsStr); i:=0;
      while i<LsStr.Count do
        if Assigned(TDefEdit.Find(LsStr[i])) then Inc(i) else LsStr.Delete(i);
    except
      on EDatabaseError do begin
	      SetStack(ost); NoBDE:=true;
      end;
    end;
    LsStr.Add(drvINTRBASE); GetMenu(dbtpDriver); LsStr.Sorted:=false;
    for fl:=low(fl) to high(fl) do aDBType[fl].g.LenName:=w;
  end;
  inherited Create(AOwner);
  RVid:='База данных';
  DelStack;
end;

destructor TDBPrmGet.Destroy;
begin
	AddStack('TDBPrmGet.Destroy',Self);
  inherited Destroy;
  LsStr.Free;
  DelStack;
end;

procedure TDBPrmGet.CreateObj;
var r: TRecVal;
	function tfCrt(const nmf: string; g: TCustomGet = nil;
  	PrCng: TFEChangeEvent = nil; PrEnter: TNotifyEvent = nil; PrExit: TNotifyEvent = nil): TFldEdit;
  begin
    AddStack('TDBPrmGet.CreateObj.tfCrt',Self);
    result:=TFldEdit.Create(tf);
    with result do begin
      Parent:=tf; AssignGet(g); NameRec:=r.NameRec; NameRecFld:=nmf;
      onEnter:=PrEnter; onExit:=PrExit; onDblClick:=tf.EdDblClick;
      onKeyDown:=tf.EdKeyDown; onKeyPress:=tf.EdKeyPress; onKeyUp:=tf.EdKeyUp;
      onMouseDown:=tf.EdMouseDown; onMouseMove:=tf.EdMouseMove; onMouseUp:=tf.EdMouseUp;
      onChange:=IfThenCng(Assigned(PrCng),PrCng,fChange);
    end;
    DelStack;
  end;
var fl: TDBTypeList;
begin
	AddStack('TDBPrmGet.CreateObj',Self);
  DestroyObj(tf); tf.DynButCreate; r:=TRecVal.Create(tf);
{ $IFDEF OLDCNF
  r.CreateFld('Cnf',ftString,cnfCnt,'');
{$ENDIF}
  r.CreateFld('Type',ftInteger,0,dbtpDriver);
  r.CreateFld('Prm',ftMemo,0,'');
  r.CreateFld('RPrm',ftMemo,0,'');
  r.CreateFld('Psw',ftString,10,'');
  for fl:=low(fl) to high(fl) do r.CreateFld(aDBType[fl].f,ftInteger,0,0);
{ $IFDEF OLDCNF
  tfCrt('Cnf',SchemDM.BoolMultiGet1).Mask:=FldConfigMask;
{$ENDIF}
  tfCrt('Type',TypeGet,fTypeChange);
  tfCrt('',nil,fTypeChange,fDrvEnter,fDrvExit);
  tfCrt('Prm',DBPrmGet).IncOptions([],[ogAutoSize]);
  tfCrt('Psw',TDBPrmPswdGet.CreateOne);
  tf.Relation:=frMain; tf.ReCreateObj;
  DelStack;
end;

procedure TDBPrmGet.ReCreateObj;
var fl: boolean;
begin
	AddStack('TDBPrmGet.ReCreateObj',Self);
  if AssignObj(tf) then begin
    SetRPrm(Rec['Rprm']); fl:=Assigned(bDyn); fType.SetReadOnly(fl or NoBDE);
    if (ogReadOnly in fDrv.Options) <> fl then begin
      fDrv.SetReadOnly(fl); fTypeChange(fType,fType.VarValue,false);
    end;
  end;
  inherited RecreateObj(tf);
  DelStack;
end;

procedure TDBPrmGet.Paint;
var r: TRect;
	procedure TxtOut(tf1: TFldEdit; const s: string);
  var sz: TSize;
  begin
    AddStack('TDBPrmGet.Paint.TxtOut',Self);
    with tf.Canvas do begin
    	sz:=TextExtent(s); r.Right:=tf1.Left-cX; r.Left:=r.Right-sz.cx;
      r.Top:=tf1.Top+BevelFld; r.Bottom:=r.Top+sz.cy; TextRect(r,r.Left,r.Top,s);
    end;
    DelStack;
  end;
var ts: TSchem;
  wd,wc: longint;
begin
	AddStack('TDBPrmGet.Paint',Self);
  if AssignObj(tf) then with tf.Canvas do begin
    wc:=tf.DynCaptSize(tf.Height-BevelFld2).cX;
  	r:=Rect(BevelFld+wc,BevelFld,tf.Width-BevelFld,tf.Height-BevelFld);
    Frame3DF(tf.Canvas,r);
    if SchemName(tf.Schem,ts) then Font.Assign(ts.FontW);
    wd:=DynButSize.cX;
    r:=Rect(BevelFld+5+wc,BevelFld,BevelFld+5+min(TextWidth(PrmMask[1]),tf.Width-BevelFld2-wd-10),
    	BevelFld+CanvasMaxH(tf.Canvas));
    TextRect(r,r.Left,r.Top,PrmMask[1]);
    Pen.Width:=1; Pen.Style:=psSolid; Pen.Color:=clBlack;
    r.Left:=BevelFld+wc+bvPn; r.Right:=tf.Width-wd-r.Left-1;
    MoveTo(r.Left,r.Bottom); LineTo(r.Right,r.Bottom);
    Pen.Color:=clWhite; Inc(r.Bottom); MoveTo(r.Left,r.Bottom); LineTo(r.Right,r.Bottom);
    if Assigned(ts) then Font.Assign(ts.Font2);
    TxtOut(fType,stType); TxtOut(fDrv,stDrv); TxtOut(fPsw,stPswd);
  end;
  DelStack;
end;

procedure TDBPrmGet.PaintObj;
var iX,iY,h,hh,wd,wc,wPswd: longint;
	ts: TSchem;
  szType,szDrv: TSize;
begin
	AddStack('TDBPrmGet.PaintObj',Self);
	if AssignObj(tf) then begin
    if SchemName(tf.Schem,ts) then tf.Canvas.Font.Assign(ts.FontW);
    hh:=CanvasMaxH(tf.Canvas)+2;
    if Assigned(ts) then tf.Canvas.Font.Assign(ts.Font2);
    szType:=tf.Canvas.TextExtent(stType);
    szDrv:=tf.Canvas.TextExtent(stDrv);
    wPswd:=tf.Canvas.TextWidth(stPswd);
    wd:=DynButSize.cX; wc:=tf.DynCaptSize(tf.Height-BevelFld2).cX;
    iX:=nround((tf.Width-BevelFld2-wd-wc-bvPn2{ $IFDEF OLDCNF-fCnf.Width{$ENDIF}
      -szType.cx-fType.Width-szDrv.cx-fDrv.Width-cX8)/{ $IFDEF OLDCNF 4 {$ELSE}2{ $ENDIF});
    h:=MaxIntValue([{ $IFDEF OLDCNFfCnf.Height,{$ENDIF}szType.cy,fType.Height,szDrv.cy,fDrv.Height]);
    iY:=tf.Height-BevelFld2-bvPn2-hh-h-fPrm.Height;
{ $IFDEF OLDCNF
    fCnf.SetBounds(BevelFld+bvPn+wc+nround(iX/2)+cX,BevelFld+bvPn+hh+nround(iY/2),0,0);
    fType.SetBounds(fCnf.Left+fCnf.Width+wType+cX2,fCnf.Top,0,0);
{$ELSE}
    fType.SetBounds(BevelFld+bvPn+wc+nround(iX/2)+cX+szType.cx+cX2,BevelFld+bvPn+hh+nround(iY/2),0,0);
{ $ENDIF}
    fDrv.SetBounds(fType.Left+fType.Width+iX+szDrv.cx+cX2,fType.Top,0,0);
    fPrm.SetBounds(BevelFld+bvPn+wc+cX2,fType.Top+h,
    	tf.Width-BevelFld2-wd-wc-bvPn2-cX*5-wPswd-fPsw.Width,
    	fPrm.SizeAuto.cY+BevelFld2);
    fPsw.SetBounds(fPrm.Left+fPrm.Width+cX2+wPswd,fPrm.Top,0,0);
    if Assigned(bDyn) then bDyn.SetBounds(tf.Width-BevelFld-wd,BevelFld,wd,tf.Height-BevelFld2);
    tf.Invalidate;
  end;
  DelStack;
end;

function TDBPrmGet.SizeAuto;
var ts: TSchem;
  dsz,dcsz: TSize;
  h: longint;
  szType,szDrv: TSize;
begin
	AddStack('TDBPrmGet.SizeAuto',Self);
	result := inherited SizeAuto(tf,Opt);
	if AssignObj(tf) then begin
    if SchemName(tf.Schem,ts) then tf.Canvas.Font.Assign(ts.Font2);
    if Opt<>[] then begin
      dsz:=DynButSize;
      szType:=tf.Canvas.TextExtent(stType);
      szDrv:=tf.Canvas.TextExtent(stDrv);
      result.cY:=MaxIntValue([{ $IFDEF OLDCNFfCnf.Height,{$ENDIF}szType.cy,fType.Height,szDrv.cy,fDrv.Height])
        +fPrm.Height+bvPn2;
      if Assigned(ts) then tf.Canvas.Font.Assign(ts.FontW);
      h:=max(result.cY+CanvasMaxH(tf.Canvas)+2,dsz.cY);
      dcsz:=tf.DynCaptSize(h);
      if tfszWidth in Opt then result.cX:={ $IFDEF OLDCNFfCnf.Width+{$ENDIF}szType.cx+fType.Width
        +szDrv.cx+fDrv.Width+bvPn2+cX8+dsz.cX+dcsz.cX;
      if tfszHeight in Opt then result.cY:=max(h,dcsz.cY);
    end;
  end;
  DelStack;
end;

function TDBPrmGet.GetValue;
var fl: TDBTypeList;
begin
	AddStack('TDBPrmGet.GetValue',Self);
  result := inherited GetValue(tf);
  if AssignObj(tf) then begin
  	for fl:=low(fl) to high(fl) do result:=StrNum(result+cDlm,Rec[aDBType[fl].f]);
  	result:=ArrayAsList([{ $IFDEF OLDCNFTrimRight(Rec['Cnf']),{$ENDIF}
      IntToStr(Rec['Type']),''{SQL},TrimRight(Rec['Psw']),TrimSpRight(Rec['RPrm'])],
      cDlm)+result;
  end;
  DelStack;
end;

procedure TDBPrmGet.SetValue;
var fl: TDBTypeList;
	p: TDBPrmGetInfo;
begin
	AddStack('TDBPrmGet.SetValue',Self);
  if AssignObj(tf) then begin
  	p:=ValueToPrm(v); { $IFDEF OLDCNFfCnf.VarValue:=p.Cnf;{$ENDIF} fType.VarValue:=p.AType; 
    fPsw.VarValue:=p.Password; SetRPrm(p.Prm);
  	for fl:=low(fl) to high(fl) do with aDBType[fl] do Rec[f]:=Int0(g.CodFromName(p.aName[fl]));
    fDrv.Read;
  end;
  DelStack;
end;

procedure TDBPrmGet.DoEnter;
var tl: TKeyLb;
begin
	AddStack('TDBPrmGet.DoEnter',Self);
  if AssignObj(tf) then
    if Assigned(bDyn) then GetParentForm(tf).ActiveControl:=fType;
  if FormKeyLb(tf,tl) then tl.SetKey(K_F2,'','Перейти к параметрам',ProcKey,'dbprmget',kmNone);
  inherited DoEnter(tf);
  DelStack;
end;

procedure TDBPrmGet.DoExit;
var tl: TKeyLb;
begin
  AddStack('TDBPrmGet.DoExit',Self);
  if FormKeyLb(tf,tl) then tl.DelKey(K_All,'dbprmget');
  DelStack;
end;

class function TDBPrmGet.ValueToPrm;
var a: array[1..{ $IFDEF OLDCNF 7 {$ELSE}6 { $ENDIF}] of string;
	fl: TDBTypeList;
begin
  AddStack('TDBPrmGet.ValueToPrm');
  LsArrFill(Value,a,cDlm);
  with result do begin
{ $IFDEF OLDCNF
  	Cnf:=a[1]; AType:=Int0(a[2]); FileSQLName:=a[3]; Password:=a[4]; Prm:=a[5];
    for fl:=low(fl) to high(fl) do aName[fl]:=FMnName(fl,Int0(a[fl+5]));
{$ELSE}
  	AType:=TDBTypeList(Int0(a[1])); Password:=a[3]; Prm:=a[4];
    for fl:=low(fl) to high(fl) do aName[fl]:=FMnName(fl,Int0(a[byte(fl)+4]));
{ $ENDIF}
    if NoBDE then AType:=dbtpDriver;
  end;
  DelStack;
end;

{ $IFDEF OLDCNF
function TDBPrmGet.FValueToPrm;
begin
	AddStack('TDBPrmGet.FValueToPrm',Self);
  result:=ValueToPrm(Value);
  if AssignObj(tf) then CorPrmPath(result.Prm);
  DelStack;
end;

procedure TDBPrmGet.CorPrmPath;
begin
  AddStack('TDBPrmGet.CorPrmPath',Self);
  if (deSeek=SQLDM.deMySQL) and not empty(PrmMask[3]) then begin
    LsStr.Text:=Prm; LsStr.Values['PATH']:=Trim(PrmMask[3]); Prm:=LsStr.Text;
  end;
  DelStack;
end;
{$ENDIF}

class function TDBPrmGet.PrmToValue;
var fl: TDBTypeList;
begin
	AddStack('TDBPrmGet.PrmToValue');
  with Prm do begin
    result:=ArrayAsList([{ $IFDEF OLDCNF TrimRight(Cnf),{$ENDIF}Int2Str(AType),''{FileSQLName},Password,Prm],cDlm);
    for fl:=low(fl) to high(fl) do IncD(result,cDlm+aDBType[fl].g.CodFromName(aName[fl]));
  end;
  DelStack;
end;

procedure TDBPrmGet.ReadFirst;
var fl: TDBTypeList;
  p: TDBPrmGetInfo;
  f: TIniFileData;
begin
	AddStack('TDBPrmGet.ReadFirst',Self);
  if AssignObj(tf) then
 		if not empty(PrmMask[2]) then begin
      f:=TIniFileData.Create;
      with p,f do
        try
          CorrPrm(f,PrmMask[2]);
{ $IFDEF OLDCNF
          Cnf:=ReadConfig(PrmMask[2]);
{$ENDIF}
          AType:=TDBTypeList(ReadInteger(PrmMask[2],stpDatType,byte(dbtpDriver)));
          Password:=''; Prm:=ReadPrm;
          for fl:=low(fl) to high(fl) do aName[fl]:=ReadString(PrmMask[2],aStpDat[fl]);
          tf.VarValue:=PrmToValue(p);
        finally
          Free;
        end;
    end;
  DelStack;
end;

class procedure TDBPrmGet.CorrPrm;
var p: TInterbasePath;
  ibSect,s,fn: string;
  a: TArrSQLPath;
begin
  AddStack('TDBPrmGet.CorrPrm');
  if not Assigned(pFileIdentProg) and Assigned(ProgPswd) then pFileIdentProg:=@ProgPswd.FileIdentProg;
  if Assigned(pFileIdentProg) then begin
    ibSect:=Sect+'.'+drvINTRBASE; p:=TInterbasePath(f.ReadInteger(ibSect,ibpPath,byte(ibppNoStd)));
    if p=ibppNoStd then begin
      s:=TrimUpper(f.ReadString(ibSect,ibpServerName));
      if not IsSQLLocalPath(s,@a) and (a.IP='127.0.0.1') and (a.Port='') then s:=a.Drv+DriveDelim+a.Path;
      fn:=ChangeFileExt(pFileIdentProg^,'.'+aInterbaseExt[TInterbaseExt(f.ReadInteger(ibSect,ibpExt))]);
      if (s=DirDatas+fn) or (s=TrimUpper(ExeDir)+DirDatas+fn) then begin
        p:=ibppLocal; f.WriteString(ibSect,ibpServerName,DirDatas+fn);
      end
      else if not(IsSQLLocalPath(s,@a) or (a.IP='') or (a.Drv='')) then begin
        s:=TrimUpper(ExeDir)+DirDatas+fn;
        if a.Path=Copy(s,Length(ExtractFileDrive(s))+1,MaxInt) then begin
          p:=ibppRemoved; f.WriteString(ibSect,ibpIP,a.IP);
          f.WriteString(ibSect,ibpPort,a.Port); f.WriteString(ibSect,ibpDrv,a.Drv);
        end;
      end;
      f.WriteInteger(ibSect,ibpPath,byte(p));
    end
    else f.WriteString(ibSect,ibpServerName,IbPathToServName(p,f.ReadString(ibSect,ibpPort),
      f.ReadString(ibSect,ibpIP),f.ReadString(ibSect,ibpDrv),pFileIdentProg^,
      TInterbaseExt(f.ReadInteger(ibSect,ibpExt))));
  end;
  DelStack;
end;

procedure TDBPrmGet.UpdateRec;
begin
	AddStack('TDBPrmGet.UpdateRec',Self);
  inherited UpdateRec(tf,Oper);
  if Oper=feuAfterUpd then
    if AssignObj(tf) then UpdateRecSect(tf,PrmMask[2],false);
  DelStack;
end;

class procedure TDBPrmGet.UpdateRecSect;
begin
  AddStack('TDBPrmGet.UpdateRecSect');
  if not empty(Sect) then begin
    tf.Write;
    WriteParamToIni(Sect,{ $IFDEF OLDCNF FValueToPrm(tf,{$ELSE}ValueToPrm({ $ENDIF}tf.VarValue),lClr);
  end;
  DelStack;
end;

class procedure TDBPrmGet.DirDataToIni;
var Prm: TDBPrmGetInfo;
  f: TIniFileData;
  e: TInterbaseExt;
{ $IFDEF OLDCNF
  s1: string;
{$ENDIF}
begin
  AddStack('TDBPrmGet.DirDataToIni');
  TSQLDM.Load;
{ $IFDEF OLDCNF
  s1:=SetByte(cnfCnt); Prm.Cnf:=s1;
{$ENDIF}
  Prm.AType:=dbtpDriver;
  Prm.Password:=smasterkey; Prm.aName[dbtpDriver]:=drvINTRBASE;
  f:=TIniFileData.Create;
  try
    e:=TInterbaseExt(f.ReadInteger(stpReg+'.'+drvINTRBASE,ibpExt));
  finally
    f.Free;
  end;
  Prm.Prm:=DlmBetween([ibpServerName+'='+DirDatas+FileGdb+'.'+aInterbaseExt[e],ibpUserName+'='+sSYSDBA,
    ibpPath+StrNum('=',ibppLocal),ibpType+StrNum('=',ibtFib),ibpExt+StrNum('=',e),ibpPort+'='+Port],CRLF);
  TDBPrmGet.WriteParamToIni(Sect,Prm);
  DelStack;
end;

class procedure TDBPrmGet.WriteParamToIni;
var ls: TStringList;
	fl: TDBTypeList;
  i,n: longint;
  f: TIniFileData;
begin
  AddStack('TDBPrmGet.WriteParamToIni');
  f:=TIniFileData.Create;
  with f do
    try
      if lClr then EraseSection(Sect,true);
{ $IFDEF OLDCNF
      WriteConfig(Sect,p.Cnf);
{$ENDIF}
      WriteInteger(Sect,stpDatType,byte(p.AType));
      if not empty(p.Password) then WriteString(Sect,stpDatPswd,ShifrStr(p.Password));
      ls:=TStringList.Create;
      try
        ls.Text:=p.Prm; n:=Int0(aDBType[dbtpDriver].g.CodFromName(p.aName[dbtpDriver]));
        if (n<>0) and Assigned(FdeSeek(n)) then
          for i:=0 to ls.Count-1 do
            if not empty(ls.Names[i]) then WriteString(Sect+'.'+TrimSp(p.aName[dbtpDriver]),
              ls.Names[i],ls.Values[ls.Names[i]]);
      finally
        ls.Free;
      end;
      for fl:=low(fl) to high(fl) do WriteString(Sect,aStpDat[fl],p.aName[fl]);
      CorrPrm(f,Sect); UpdateFile;
    finally
      Free;
    end;
  DelStack;
end;

function TDBPrmGet.AssignObj;
var n: byte;
begin
	AddStack('TDBPrmGet.AssignObj',Self);
  Rec:=nil; fType:=nil; fDrv:=nil; fPrm:=nil; fPsw:=nil; result:=false;
  if inherited AssignObj(tf) then begin
    n:=IfThen(Assigned(bDyn),1); result := tf.ComponentCount=n+{ $IFDEF OLDCNF 7{$ELSE}5{ $ENDIF};
    if result then begin
      if IsClass(tf.Components[n],TRecVal,pointer(Rec))
{ $IFDEF OLDCNF
      and IsClass(tf.Components[n+1],TFldEdit,pointer(fCnf))
      and IsClass(tf.Components[n+2],TFldEdit,pointer(fType))
      and IsClass(tf.Components[n+3],TFldEdit,pointer(fDrv))
      and IsClass(tf.Components[n+4],TFldEdit,pointer(fSQL))
      and IsClass(tf.Components[n+5],TFldEdit,pointer(fPrm))
      and IsClass(tf.Components[n+6],TFldEdit,pointer(fPsw))
{$ELSE}
      and IsClass(tf.Components[n+1],TFldEdit,pointer(fType))
      and IsClass(tf.Components[n+2],TFldEdit,pointer(fDrv))
      and IsClass(tf.Components[n+3],TFldEdit,pointer(fPrm))
      and IsClass(tf.Components[n+4],TFldEdit,pointer(fPsw))
{ $ENDIF}
      then begin
        result:=true; LsArrFill(tf.Mask,PrmMask,UnDelim);
      end;
    end;
  end;
  DelStack;
end;

procedure TDBPrmGet.fTypeChange;
var lEmp: boolean;
	tp: TDBTypeList;
begin
	AddStack('TDBPrmGet.fTypeChange',Self);
  if AssignObjOwner(Sender) then begin
    tp:=TDBTypeList(EnsureRange(longint(Rec['Type']),byte(low(aDBType)),byte(high(aDBType))));
    SetRedraw(fDrv);
    with aDBType[tp] do begin
      fDrv.AssignGet(g); fDrv.NameRecFld:=f;
    end;
    fDrv.Read; SetRedraw(fDrv,rdrwSet); lEmp := (fDrv.VarValue=0) or Assigned(bDyn);
    fPrm.SetReadOnly((tp=dbtpAlias) or lEmp); fPsw.SetReadOnly(lEmp);
    fChange(Sender,OldVal,FromShow); PrmRebuild(Sender);
  end;
  DelStack;
end;

class procedure TDBPrmGet.fChange;
begin
	AddStack('TDBPrmGet.fChange');
  FldEditOwner(Sender).Change(OldVal,FromShow);
  DelStack;
end;

procedure TDBPrmGet.fDrvEnter;
begin
	AddStack('TDBPrmGet.fDrvEnter',Self);
  if AssignObjOwner(Sender) then oDriver:=Rec[aDBType[dbtpDriver].f];
  DelStack;
end;

procedure TDBPrmGet.fDrvExit;
begin
	AddStack('TDBPrmGet.fDrvExit',Self);
  if AssignObjOwner(Sender) then
		if not((Rec['Type']=dbtpAlias) or (oDriver=Rec[aDBType[dbtpDriver].f]) or (deSeek=nil))
    then SetRPrm(ReadPrm);
  DelStack;
end;

procedure TDBPrmGet.ProcKey;
var tf: TFldEdit;
begin
  AddStack('TDBPrmGet.ProcKey',Self);
  while Assigned(tw) do begin
    if IsClass(tw,TFldEdit,pointer(tf)) then if tf.curget=Self then begin
      if AssignObj(tf) then
        if not(ogReadOnly in fPrm.Options) then fPrm.SetFocus;
      break;
    end;
    ParentSelf(tw);
  end;
  DelStack;
end;

function TDBPrmGet.ReadPrm;
var de: TDefEdit;
	i,w: longint;
  nmf: string;
begin
	AddStack('TDBPrmGet.ReadPrm',Self);
  if empty(PrmMask[2]) then result:=''
  else begin
    LsStr.Clear; nmf:=PrmMask[2]+'.'+TrimSp(MnName(dbtpDriver));
    with TIniFileData.Create do
      try
        DeleteKey(nmf,'NOFIB'); ReadSectionValues(nmf,LsStr);
      finally
        Free;
      end;
    result:=LsStr.Text; de:=deSeek;
    if Assigned(de) then begin
      SQLDM.RPrm.CloseRec;
      for i:=0 to de.Fields.Count-1 do begin
      	if StrToBoolean(de.Param[i,deNewPage]) then break;
        w:=Int0(de.Param[i,deMaxLen]); nmf:=de.Param[i,deNameRecFld];
        SQLDM.RPrm.CreateFld(nmf,iif(w=0,ftMemo,ftString),w,'');
      end;
      SQLDM.RPrm.OpenRec;
    end;
  end;
  DelStack;
end;

procedure TDBPrmGet.SetRPrm;
{ $IFDEF OLDCNF
var s: string;
{$ENDIF}
begin
  AddStack('TDBPrmGet.SetRPrm',Self);
{ $IFDEF OLDCNF
  s:=Prm; CorPrmPath(s); Rec['RPrm']:=s; fPrm.VarValue:=DelTrim(StrTran(s,CRLF,' '));
{$ELSE}
  Rec['RPrm']:=Prm; fPrm.VarValue:=DelTrim(StrTran(Prm,CRLF,' '));
{ $ENDIF}
  DelStack;
end;

function TDBPrmGet.MnName;
begin
	AddStack('TDBPrmGet.MnName',Self);
  result:=FMnName(tp,Rec[aDBType[tp].f]);
  DelStack;
end;

function TDBPrmGet.deSeek;
begin
	AddStack('TDBPrmGet.deSeek',Self);
  result:=FdeSeek(Rec[aDBType[dbtpDriver].f]);
  DelStack;
end;

function TDBPrmGet.PrmGetClick;
var i: longint;
	de: TDefEdit;
  a: TArrStr;
  s,v: string;
  p: TInterbasePath;
  t: TInterbaseType;
begin
	AddStack('TDBPrmGet.PrmGetClick',Self);
  a:=nil;
  if AssignObjOwner(Sender) then begin
    de:=deSeek; LsStr.Text:=Rec['Rprm'];
    if lEval then begin
      deCaption:=PrmMask[1];
{ $IFDEF OLDCNF
      CurConfig:=Rec['Cnf'];
{$ENDIF}
      LsStrToRPrm(de);
{ $IFDEF OLDCNF
      BeforeDeExec(de);
{$ENDIF}
      if de.Execute(deCaption).Saved then begin
        AssignObjOwner(Sender); LsStr.Clear;
        for i:=0 to de.Fields.Count-1 do
          if StrToBoolean(de.Param[i,deNewPage]) then break
          else begin
            s:=de.Param[i,deNameRecFld]; v:=TrimSpRight(SQLDM.RPrm[s]);
            if v='' then LsStr.Add(s+LsStr.NameValueSeparator) else LsStr.Values[s]:=v;
          end;
        SetRPrm(LsStr.Text); PrmRebuild(Sender);
      end;
    end;
    if de=SQLDM.deIntrbase then begin
      p:=TInterbasePath(EnsureRange(Int0(LsStr.Values[ibpPath]),byte(low(aIbpp)),byte(high(aIbpp))));
      AddFrom(a,'Размещение: '+aIbpp[p]);
      if p=ibppRemoved then AddFrom(a,['Компьютер (IP-адрес): '+LsStr.Values[ibpIP],
        'Диск: '+LsStr.Values[ibpDrv]]);
      t:=TInterbaseType(EnsureRange(Int0(LsStr.Values[ibpType]),byte(low(aIBType)),byte(high(aIBType))));
      if t=ibtFIB
      then s:=BrackNoEmp(DlmBetween(IfThen(Int0(LsStr.Values[ibpFIBDll])=1,'Firebird'),
        IfThen(StrToBoolean(LsStr.Values[ibpFIBNoGC]),'без сборки "мусора"'),', '),' (')
      else s:='';
      AddFrom(a,['База данных: '+LsStr.Values[ibpServerName],
        'Пользователь: '+LsStr.Values[ibpUserName],'Соединение: '+aIBType[t]+s]);
      if empty(DlmCopy(LsStr.Values[ibpServerName],3,1))
      then AddFrom(a,'Использовать встроенный Firebird: '
        +AnsiLowerCase(bRus[StrToBoolean(LsStr.Values[ibpFBLocal])]));
    end
    else if de=SQLDM.deStandard then AddFrom(a,['Папка: '+LsStr.Values[stpPath],
      'Драйвер: '+LsStr.Values[stpDefaultDriver]]);
  end;
  result:=ArrayAsList(a,CRLF);
  DelStack;
end;

procedure TDBPrmGet.LsStrToRPrm;
var i: longint;
  s: string;
begin
  AddStack('TDBPrmGet.LsStrToRPrm',Self);
  for i:=0 to de.Fields.Count-1 do
    if StrToBoolean(de.Param[i,deNewPage]) then break
    else begin
      s:=de.Param[i,deNameRecFld]; SQLDM.RPrm[s]:=LsStr.Values[s];
    end;
  DelStack;
end;

{ $IFDEF OLDCNF
procedure TDBPrmGet.BeforeDeExec;
begin
  AddStack('TDBPrmGet.BeforeDeExec',Self);
  if de=SQLDM.deMySQL then begin
  	de.Param['IP_ADR',deNoVisible]:=bStr[not IsClientOnly(CurConfig)];
    de.Param['PATH',deNoReadOnly]:=bStr[empty(PrmMask[3])];
  end;
  DelStack;
end;

class function TDBPrmGet.IsClientOnly;
begin
  AddStack('TDBPrmGet.IsClientOnly');
  result:=GetByte(Cnf,cnfClient) and not GetByte(Cnf,cnfServer);
  DelStack;
end;

class function TDBPrmGet.CheckDSN;
	function NoOpen(const Key: string): boolean;
  begin
    AddStack('TDBPrmGet.CheckDSN.NoOpen');
    result:=not GRegistry.OpenKey(Key,true);
    if result then begin
    	GRegistry.CloseKey; meserr(Key,'Ошибка записи в реестр');
    end;
    DelStack;
  end;
const a: array[1..2] of char = ('\','/');
	regODBC = 'SOFTWARE\ODBC\ODBC.INI';
  regODBCSource = regODBC+'\ODBC Data Sources';
var i: byte;
	sym,Path,pData: string;
label lend;
begin
  AddStack('TDBPrmGet.CheckDSN');
  if de=SQLDM.deMySQL then with TDatabase(db).Params do begin
  	if cPath<>'' then Values['PATH']:=cPath;
    Path:=CorrDir(Values['PATH'],false);
    Values['IP_ADR']:=StrTran(Values['IP_ADR'],' ');
    sym:=Copy(Path,Length(ExtractFileDrive(Path))+2,MaxInt);
    for i:=low(a) to high(a) do StrTranSelf(sym,a[i],'~');
    with TIniFileCheck.Create(SystemRoot+'MY.INI') do
      try
        pData:=CorrDir(ReadString('mysqld','datadir'));
      finally
        Free;
      end;
    SetStrFile(pData+sym+'.SYM',Path+PathDelim+DirDATA); result:=false;
    with GRegistry do begin
      Access:=KEY_ALL_ACCESS; RootKey:=HKEY_CURRENT_USER; pData:='MSQ~'+sym;
      if NoOpen(regODBC+'\'+pData) then goto lend;
      WriteString('Database',sym);
      WriteString('Description','');
      WriteString('Driver',SystemRoot+'SYSTEM\myodbc.dll');
      WriteString('Option','3');
      WriteString('Password','');
      WriteString('Port','');
      WriteString('Server',IfThen(IsClientOnly(Cnf),Values['IP_ADR']));
      WriteString('Stmt','');
      WriteString('User','');
      CloseKey;
      if NoOpen(regODBCSource) then goto lend;
      WriteString(pData,'MySQL');
      CloseKey; Values['ODBC DSN']:=pData; result:=true;
    end;
  end
  else result:=true;
lend:
  DelStack;
end;

class function TDBPrmGet.ReadConfig;
begin
	AddStack('TDBPrmGet.ReadConfig');
  result:=SetByte(cnfCnt);
  with TIniFileData.Create do
    try
      result:=Copy(ReadString(Sect,stpConfig,'"'+result),2,MaxInt);
    finally
      Free;
    end;
  DelStack;
end;

class procedure TDBPrmGet.WriteConfig;
var f: TIniFileData;
begin
	AddStack('TDBPrmGet.WriteConfig');
  f:=TIniFileData.Create;
  try
    WriteConfigFile(f.fWrite,Sect,Value);
  finally
    f.Free;
  end;
  DelStack;
end;

class procedure TDBPrmGet.WriteConfigFile;
begin
	AddStack('TDBPrmGet.WriteConfigFile');
  f.WriteString(Sect,stpConfig,'"'+TrimRight(Value));
  DelStack;
end;

{$ENDIF}

// Соединение
procedure TDBPrmGet.ConPswGetClick;
var de: TDefEdit;
  db: TComponent;
  s: string;
  tf: TFldEdit;
  sC: TPaintButton;
begin
	AddStack('TDBPrmGet.ConPswGetClick',Self);
  sC:=pointer(Sender); sC.Down:=true;
  try
    if Rec['Type']=dbtpDriver then begin
      de:=deSeek; lCon:=Assigned(de);
      if lCon then begin
        LsStr.Text:=Rec['Rprm']; LsStrToRPrm(de);
  { $IFDEF OLDCNF
        BeforeDeExec(de);
  {$ENDIF}
        oShow:=de.OnFrmShow; de.OnFrmShow:=ConPswShow;
        de.Execute('',desVisible); de.OnFrmShow:=oShow;
      end;
    end
    else lCon:=true;
    if lCon then begin
      tf:=FldEditOwner(Sender); tf.Check; FldEditOwnerSelf(tf); db:=CreateDatabase(tf);
      try
        if Connect(db,tf) then begin
          s:=GetInfo(db); meserr(IfThen(s='','Тест на соединение выполнен.',s),deCaption);
        end;
      finally
        db.Free;
      end;
    end;
  finally
    sC.Down:=false;
  end;
  DelStack;
end;

function FConnect(tf: TFldEdit; var db: TComponent; lCreate: boolean): boolean;
	function MsgFoc(tf: TFldEdit; const msg: string; const usl: variant): boolean;
  begin
  	AddStack('FrmPswd.FConnect.MsgFoc');
    if MyVarType(usl)=varBoolean then result:=usl else result:=empty(tf.VarValue);
	  if result then begin
    	MsgDlg([AnsiUpperCase(deCaption)+':','необходимо указать '+msg+'.'],mtWarning);
      tf.SetFocus;
    end;
    DelStack;
	end;
const a: TDBTypeStr = ('драйвера','псевдонима');
var gd: TCustomGet;
  tp: TDBTypeList;
label lend;
begin
  AddStack('FrmPswd.FConnect');
  result:=false;
  if NameGet(gd,tf,TDBPrmGet) then with TDBPrmGet(gd) do
  	if AssignObj(tf) then begin
      UpdateRecSect(tf,stpSection+'.'+sectConnect,true);
      if lCreate then begin
        db:=TFormPswd.CreateDatabase(sectConnect,'CONNECT',false); result:=true;
      end
      else begin
        deCaption:=PrmMask[1]; tp:=Rec['Type'];
        if MsgFoc(fDrv,'наименование '+a[tp],null) then goto lend;
        if not IsStandard then
          if MsgFoc(fPsw,'пароль доступа',null) then goto lend;
        result:=TFormPswd.DBConnect(db,'CONNECT',AnsiUpperCase(deCaption)+': ошибка доступа');
lend:
      end;
    end;
  DelStack;
end;

class function TDBPrmGet.CreateDatabase;
begin
  AddStack('TDBPrmGet.CreateDatabase');
  FConnect(tf,result,true);
  DelStack;
end;

class function TDBPrmGet.Connect;
begin
  AddStack('TDBPrmGet.Connect');
  result:=FConnect(tf,db,false);
  DelStack;
end;

procedure PrCopyNoEqDate(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
var pExeDir: TFileName;
begin
  AddStack('FrmPswd.PrCopyNoEqDate');
  pExeDir:=av[1];
  if FileAge(pExeDir+sr.Name)<>sr.Time then lDone:=CopyFileOpt(av[0]+sr.Name,pExeDir+sr.Name,[cfMsg]);
  DelStack;
end;

class procedure TDBPrmGet.FBLocalCheck;
var fl: boolean;
  path,pExeDir: TFileName;
begin
  AddStack('TDBPrmGet.FBLocalCheck');
  if GetDBDriverName(db)=drvINTRBASE then begin
    fl:=FBLocal; pExeDir:=ExtractFilePath(Application.ExeName);
    if fl then begin
      if My_pr.SearchPath('FBLOCAL\',path)
      then fl:=MaskFilesProc(path+'*.*',PrCopyNoEqDate,[path,pExeDir]);
    end;
    if not fl then begin
      DelFileAtr(pExeDir+FILE_GDS32); path:=GetDBName(db);
      if IsSQLLocalPath(path) then begin
        if empty(ExtractFileDrive(path)) then IncL(path,ExeDir);
        SetDBName(db,'127.0.0.1'+IfThen(not empty(Port),'/'+Trim(Port))+DriveDelim+path);
      end;
    end;
  end;
  DelStack;
end;

class function TDBPrmGet.GetInfo;
var v: variant;
begin
  AddStack('TDBPrmGet.GetInfo');
  if DBFldValue(db,tINFO,fNAME,v) then result:=v else result:='';
  DelStack;
end;

procedure TDBPrmGet.ConPswShow;
var f: TFormEdt;
  i: longint;
begin
  AddStack('TDBPrmGet.ConPswShow',Self);
  IfThenNotify(oShow,Sender); f:=pointer(Sender);
  with f.PanelEdit1 do for i:=0 to FieldCount-1 do with Fields[i] do begin
    Change(VarValue,true);
    if lCon then
      if not Check then lCon:=false;
    Visible:=false;
  end;
  DelStack;
end;

function TDBPrmGet.IsStandard;
var nmDrv: string;
	tp: TDBTypeList;
begin
	AddStack('TDBPrmGet.IsStandard',Self);
	nmDrv:=''; tp:=Rec['Type'];
  if Rec[aDBType[tp].f]>0 then begin
  	nmDrv:=MnName(tp);
  	if tp=dbtpAlias then nmDrv:=Session.GetAliasDriverName(nmDrv);
  end;
  result := TrimUpper(nmDrv)=drvSTANDARD;
  DelStack;
end;

procedure TDBPrmGet.HookProc;
begin
	AddStack('TDBPrmGet.HookProc',Self);
  if not((Message.Msg=WM_PSORT) and (TWMPSort(Message).Oper=swmSortInfo))
  then inherited HookProc(tf,Message);
  DelStack;
end;

function TDBPrmGet.MaskEdProc;
begin
	result:=null;
end;

{ $IFDEF OLDCNF
class function TDBPrmGet.FldConfigMask;
const aConfig: TConfigArr = ('Центральный компьютер','Рабочее место');
begin
  AddStack('TDBPrmGet.FldConfigMask');
  result:=ArrayAsList(aConfig,mniDlm);
  DelStack;
end;
{$ENDIF}

function TDBPrmGet.MaskTrans;
var a: array[1..2] of string;
begin
	AddStack('TDBPrmGet.MaskTrans',Self);
	if MyVarType(av)=varArray then result:=IsNilc(av[1],'')+UnDelim+IsNilc(av[2],'')
  else begin
  	LsArrFill(av,a,UnDelim);
    result:=ArrVarToVar(
      [VarArrayOf([mpEdit,'Заголовок',a[1]])
      ,VarArrayOf([mpEdit,'Идентификатор',a[2]])
      ]);
  end;
  DelStack;
end;

class procedure TDBPrmGet.FMaskView;
var a: array[1..2] of string;
begin
	AddStack('TDBPrmGet.FMaskView');
  LsArrFill(Mask,a,UnDelim);
  Mask:=DlmBetween(IfThen(not empty(a[1]),'заголовок: '+Trim(a[1])),
  	IfThen(not empty(a[2]),'идент.: '+Trim(a[2])),'; ');
  DelStack;
end;

procedure TDBPrmGet.FMaskHelp;
var n: byte;
begin
  AddStack('TDBPrmGet.FMaskHelp',Self);
  inherited;
  n:=0; SetLength(ht.Dat,n+3);
  Inc(n); CopyFrom(ht.Dat[n],HelpStruct(['Заголовок','Идентификатор']));
  Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr('«Заголовок»')+'[+"'+UnDelim+'"+'+HelpBoldStr('«Идентификатор»')+']');
  DelStack;
end;

{class function TDBPrmGet.DDatSupport;
begin
  result:=true;
end;}

procedure biLogWrite(var stack: array of variant; n1: longint; var lStd: boolean);
var oLogKeys: PLogKeysSave;
  i,j,j1,l,h,n2: longint;
begin
  AddStack('FrmPswd.biLogWrite');
  with ProgPswd do begin
    oLogKeys:=PLogKeysLen;
    try
      n2:=n1+1;
      if MyVarType(stack[n2])=varArray then begin
        j:=0;
        for i:=VarArrayLowBound(stack[n2],1) to VarArrayHighBound(stack[n2],1) do
          if i>=Length(aLogKeys) then break
          else if MyVarType(stack[n2][i])=varArray then begin
            l:=VarArrayLowBound(stack[n2][i],1); h:=VarArrayHighBound(stack[n2][i],1);
            SetLength(LogKeys,j+h-l+1);
            for j1:=l to h do with LogKeys[j] do begin
              key:=-i; val:=stack[n2][i][j1]; Inc(j);
            end;
          end;
      end;
      LogVid:=logvInter; LogWrite('',stack[n1]); LogVid:=logvNone;
    finally
      PLogKeys:=oLogKeys;
    end;
  end;
  stack[n1]:=null;
  DelStack;
end;

procedure HelpTblProc(const Name: string; var result: variant);
var i,l: longint;
begin
  AddStack('FrmPswd.HelpTblProc');
  if Name=''
    then result:=VarArrayOf(
      [VarArrayOf(['ЖУРНКЛЮЧ','Типы ключевых значений в журнале действий'])
      ])
  else if Name='ЖУРНКЛЮЧ' then begin
    result:=false;
    if Assigned(ProgPswd) then with ProgPswd do begin
      l:=Length(aLogKeys);
      if l>1 then begin
        Dec(l); result:=VarArrayCreate([1,l],varVariant);
        for i:=1 to l do result[i]:=aLogKeys[l-i].nm;
      end;
    end;
  end
  ;DelStack;
end;

procedure LogTrnsValProc(var Prm: TLogTrnsValPrm);
label lend;
begin
  AddStack('FrmPswd.LogTrnsValProc');
  with Prm do begin
    if LogEqual(Prm,tGLOBSET) then
      if nmf=ibpType then begin
        if not LogEnumVal(Prm,aIBType,1) then begin
          val:=IBTypeDef; lBreak:=true; goto lend;
        end;
      end
      else if nmf=fSQLTBL then begin
        TSqlTblLogCompare.Execute(Prm); goto lend;
      end;
    if LogEqual(Prm,tUSERS,'PASSW') then begin
      val:=StringOfChar('*',Length(TrimRight(DeShifrStr(val)))); lBreak:=true; goto lend;
    end;
    if LogEqual(Prm,tUSPRM) then if Assigned(UsPrmControl) then begin
      UsPrmControl.Perform(WM_USPRM,0,longint(@Prm));
      if Prm.lBreak then goto lend;
    end;
  end;
lend:
  DelStack;
end;

procedure Init;
const aDbsName: TArrBoolStr = ('основных','регистрационных');
  aDerPrm: array[TDerPrmList] of TFuncPrimType =
    (('Загл: строка','C')
    ,('[БД: целое]','NU')
    ,('Файл: строка','C')
    ,('[Табл: строка]','CU')
    ,('[Стр: строка]','CU')
    ,('[Начало: дата = 0.0.0]','DU')
    ,('[Конец: дата = ДАТА_МАКС]','DU')
    ,('[IP: строка]','CU')
    ,('[НомРег: целое]','NU')
    ,('[Сборка: целое]','NU')
    ,('[Выполно: логическое]','LU')
    );
var lSetDbs: boolean;
begin
  AddStack('FrmPswd.initialization');
  MyTypes.ProtocolStrAdd:=ProtocolStrAdd; MyTypes.ProtSQLStrAdd:=ProtSQLStrAdd;
  MyTypes.GetUsPrm:=GetUsPrm; MyTypes.SetUsPrm:=SetUsPrm;
  MyTypes.GetLogVid:=GetLogVid; MyTypes.SetLogVid:=SetLogVid; MyTypes.CngLogVid:=CngLogVid;
  MyTypes.PswdSendUpd:=PswdSendUpd;
  MyTypes.PswdPrm:=PswdPrm; MyTypes.LogActive:=LogActive; MyTypes.LogWrite:=LogWrite;
  MyTypes.TrnsStart:=TrnsStart; MyTypes.TrnsEnd:=TrnsEnd;
  MyTypes.c_dbopen:=Tinter.ReSetFunction('ТВБ_БДОТКРЫТЬ',c_dbopen);
  MyTypes.c_dbclose:=Tinter.ReSetFunction('ТВБ_БДЗАКРЫТЬ',c_dbclose);
  MyTypes.c_createtable:=Tinter.ReSetFunction('ТВБ_СОЗДАТЬ',c_createtable);
  MulQry.GetQuery:=GetQuery; MulQry.GetQueryIf:=GetQueryIf; MulQry.CurQuery:=CurQuery;
  MulQry.FreeQuery:=FreeQuery; MulQry.FreeQueryIf:=FreeQueryIf;
  Recdb.DBGet:=DBGet;
  aBuiltInProc[MyTypes.biLogWrite].Proc:=biLogWrite;
  SetPrim(tDER  ,'Протоколы');
  SetPrim(tFILES,'Файлы программы');
  SetPrim(tINFO ,'Наименование программы');
  SetPrim(tLOG  ,'Журнал действий');
  for lSetDbs:=false to true do SetPrim(aDbsTbl[lSetDbs].dbs,'Структура таблиц '+aDbsName[lSetDbs]+' данных');
	TInter.SetFunction('DerEdit','',c_deredit,null,aDerPrm,0,'L');
  TInter.SetFunction('SrvConnect',c_srvcon);
  TInter.SetFunction('PrmUser','',['Парам: строка'],['C'],c_prmuser,null);
  TInter.SetVar('UserNum','',d_usernum,null,'I',true);
  AddFrom(HelpTblProc);
  LogTrnsValProcAdd(LogTrnsValProc);
  DelStack;
end;

initialization
  Init;
finalization
  AddStack('FrmPswd.finalization');
  ProtFileFree;
  DelStack;
end.

