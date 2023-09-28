unit inter;

interface
{$I LIBTEST}

uses
	Windows,SysUtils,Controls,Classes,Forms,
  MyTypes,My_pr;

const
// Максимальное количество функций
	MAXFUNC=700;
// Максимальное количество определяемых операторов
	MAXOPER=40;
// Максимальное количество фиксированных операторов
	MAXOPERFIX=63;

type
	EInterAnyError = class(Exception)
  private
    mode: TInterCurMode;
    CurName: string;
  public
    constructor Create; overload;
    constructor Create(const Text: string); overload;
    constructor Create(const Text,Name: string); overload;
    constructor CreateFmt(const Msg: string; const Args: array of const); overload;
    constructor CreateFmt(const Msg: string; const Args: array of const; const Name: string); overload;
  end;

	EInterConstException = class(Exception)
  private
    curn: longint;
  public
    constructor Create;
  end;

  TInterPrimTrans = function(var s: string): boolean;
  TVarShapeTrans = procedure(const s: string; const av: array of variant;
  	lShapeFull: boolean; var result: varrec);
  TInterCompileVarProc = procedure(Sender: TObject; const VarName: string; var Pos: TInterVarPos) of object;

  TInterCompileEvalOpt = set of (iceOnlyComp,iceNoShape);

  TInterVarOpt = set of (ivWithEng,ivNoDop);
  
	PArrFunc = ^TArrFunc; TArrFunc = array[1..MAXFUNC] of funcrec;
  TArrOper = array[1..MAXOPER+MAXOPERFIX] of operrec;

  PInter = ^TInter;
	Tinter = class(Tobject)
	private
		fl_compile,FEvalRaise:boolean;
    nvp: SmallInt;
		function EncCompileEval(Opt: TInterCompileEvalOpt; const ap:array of variant;
      ProcVar: TInterCompileVarProc = nil):variant;
		function CompileEval(Opt: TInterCompileEvalOpt; const ap:array of variant;
      ProcVar: TInterCompileVarProc = nil):variant;
		class function GetVarHelp(const name: string; var n: longint): boolean; overload;
		class procedure FormatStr(const a: TArrStr; l: longint); overload;
	public
		error:TInterError;
		lerror:word;
		serror,name,value_types,GetAlgPrm: string;
		showerror,lDebug:boolean;
    GetAlgProc: procedure(Sender: TObject; var Txt: string) of object;
    CheckResultProc: TInterCheckResultProc;
    ast: TArrVar;
    lsStruct: TStringListCase;
    IntStatVar: TInter;
    listcom: TArrStr;
		procedure SetProg(const s: string);
		function Eval: variant; overload;
		function Eval(const ap:array of variant): variant; overload;
		function EvalChk: boolean; overload;
		function EvalChk(var v: variant): boolean; overload;
		function EvalChk(var v: variant; const ap:array of variant): boolean; overload;
		function Compile(ProcVar: TInterCompileVarProc = nil; lShape: boolean = true): boolean;
    procedure ProcError(const FormatStr: string; const Args: array of const; nGG: byte = 2);
    procedure Assign(Source: TInter);
		class procedure GetVar(var a: TArrVarRec; const name: string = '';
      VarTypes: TInterVarTypes = [low(TInterVarType)..high(TInterVarType)];
      Opt: TInterVarOpt = []); overload;
		class function GetVar(var a: PArrVarRec): longint; overload;
		class procedure DelVar(const name:string);
		class function GetFunction(var a: PArrFunc): longint; overload;
		class function GetFunction: PArrFunc; overload;
		class procedure GetOperator(var a: TArrOper; var l: longint);
		class function SetVar(const name,chint: string; pr: TVarevent; const ind: variant;
    	const types: string = ''; ReadOnly: boolean = false): longint; overload;
		class procedure SetVar(const name,chint:string); overload;
		class procedure SetVar(const name,prim,chint:string); overload;
		class procedure SetVar(const name,chint: string; pr: TVarevent; const ind: variant;
    	const types: string; ReadOnly: boolean; help: THelpContext;
      const hlpfile: string = ''; const hlpname: string = ''); overload;
		class procedure SetVar(const name: string; help: THelpContext;
      const hlpfile: string = ''; const hlpname: string = ''); overload;
		class procedure SetVar(const name: string; hl: THelpLinkList; const hlpname: string); overload;
		class procedure SetVarPrim(const name,nmdb:string); overload;
		class procedure SetVarPrim(const name,prim,nmdb:string); overload;
		class procedure SetVarShape(const name: string; prVar: TVarevent;
    	prTrans: TVarShapeTrans; const av: array of variant);
		class function GetVarHelp(const vr: varrec): PVarHelp; overload;
		class function GetVarHelp(const name: string; var vh: PVarHelp): boolean; overload;
    class procedure DopGetVarAdd(const av: TArrVar; PrEqual: TProcDopGetVarEqual;
      PrAdd: TProcDopGetVarsAdd; PrIgnore: TProcDopGetVarIgnore);
    class function MemoVarIgnore(const aPath: TVarPathStr): boolean;
		class procedure SetFunction(const name,hint:string;
      const aPrmPrim,aPrmType: array of string;
      pr:TFuncevent; const index: variant; help: longint = 0; const types: string = '';
      nBuiltIn: longint = 0); overload;
		class procedure SetFunction(const name,hint:string;
      pr:TFuncevent; const index: variant; const aPrm: array of TFuncPrimType;
      help: longint = 0; const types: string = ''); overload;
		class procedure SetFunction(const hint: string; help: longint = 0); overload;
		class procedure SetPrimAll(PrTrans: TInterPrimTrans = nil);
		class procedure SetFunction(const name,hint:string;
      pr:TFuncevent; const index: variant; help: longint = 0; const types: string = ''); overload;
		class procedure SetFunction(const name: string; pr:TFuncevent); overload;
		class procedure ReSetFunction(const name:string; const hint:variant; aPrmPrim,aPrmType: PArrStr;
      pr:TFuncevent; const index,help: variant; const types: string = ''); overload;
		class procedure ReSetFunction(const name:string; const hint:variant; aPrmPrim,aPrmType: PArrStr;
      bi: TBuiltInList; Proc: TBuiltInProc; const index,help: variant; const types: string = ''); overload;
		class function ReSetFunction(const name:string; pr:TFuncevent): TFuncevent; overload;
		class procedure DelFunction(i: longint);
		class procedure SetOperator(const name,hint,optext: string; oplev: longint;
      help: longint = 0; const nmhelp: string = '');
		class function FormatStr(const s: string): string; overload;
		class function SearchIdent(const formula,sr:string; lIdent: boolean = true):boolean;
		class function ReplaceIdent(var formula:string; const sr,srep:string;
    	lIdent: boolean = true; PrRepl: TReplaceProc = nil; pav: PVariant = nil): longint;
		class function SeekVar(const name: string; pi: PLongInt = nil): varrec; overload;
		class function SeekVar(const name: string; var i: LongInt): boolean; overload;
		class function SetVarValue(const name: string; const v: variant; lSave: boolean = true): variant;
		class function GetVarValue(const name: string): variant; overload;
		class function GetVarValue(const name: string; vType: longint; var v: variant): boolean; overload;
    class function VarProc(i: longint; const v:variant; lSave: boolean): variant;
		class function SeekFunction(const cname: string): funcrec;
    class procedure ProtDebStrAdd(const s: string);
		//class function SeekOperator(const cname: string): operrec;
    class function HelpFile(const v: varrec): THelpFile; overload;
    class function HelpFile(const name: string): THelpFile; overload;
    class function HelpFile(const f: funcrec): THelpFile; overload;
    class function HelpFile(const o: operrec): THelpFile; overload;
		constructor Create(const AName: string);
		destructor Destroy; override;
	end;

  TArrInter = array of TInter;

  TEvalEncProc = procedure (beforeEval: boolean; var p: pointer);

  TVarDopList = class(TObject)
  private
    avi: array of record
      name,hint,types: string;
    end;
    lvi: longint;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddDop(const name,hint: string; const types: string = '');
		procedure PrInterDopGetVar(ProcDopGetVarAdd: TProcDopGetVarAdd);
  end;

  TFuncPartList = class(TStringList)
  public
    function GetName(AObject: TObject): string;
    function AddObject(const S: string; AObject: TObject): Integer; override;
  end;

const
  idShapeHint = '__SHAPE';

  aHelpStyle: array[THelpStyleList] of record
    v,nm: string;
  end =
    ((v:'РАЗД'    ; nm:'Разделы')
    ,(v:'ЗАГЛ'    ; nm:'Заголовки')
    ,(v:cHlpVarDef; nm:'Выделенный')
    ,(v:'ПРИМ'    ; nm:'Примечания')
    ,()
    ,(              nm:'Ссылки')
    );

var CurInter,InterErr,InterDebug: TInter;
  aInterStack: array[1..300] of TInter;
  InterShowError: function(Inter: TInter; AKeys: TIEKeys = [low(TIEKey)..high(TIEKey)];
    Sender: TControl = nil; PrmBeforeShowError: pointer = nil;
    const Capt: TCaption = 'Ошибка выполнения формулы'): TModalResult;
  lsFuncPart: TFuncPartList;
  aoperv:array[1..MAXOPER] of operrec;
  HelpBaseFile: string = 'STD';
  InterStopOn,InterAnyDebug,CtodEpoch: boolean;
  nInterDopGetVar: byte = 1;
  lErrorDebug,nInterStack: longint;
  IntLastError: TInterError;
  HelpMapFind: function(help: longint; var nFile: longint; var nmPage: string): boolean;
  HelpIsPage: function(const nmPage,nmFile: string): boolean;
  aInterVarCreate: TArrProcNone;

function InterCurVar: Pvarrec;
procedure AddFrom(encProc: TEvalEncProc); overload;
function EvalStrings(const s,capt:string; const ResultType: string = ''; EvalRaise: boolean = false): variant; overload;
function EvalStrings(const ap:array of variant; const s,capt:string; const ResultType: string = ''; EvalRaise: boolean = false): variant; overload;
function EvalStringsChk(const ap:array of variant; const s,capt:string; const ResultType: string = ''; EvalRaise: boolean = false): boolean; overload;
function EvalStringsChk(var v: variant; const s,capt:string; const ResultType: string = ''; EvalRaise: boolean = false): boolean; overload;
function EvalStringsChk(var v: variant; const ap:array of variant; const s,capt:string; const ResultType: string = ''; EvalRaise: boolean = false): boolean; overload;
function FmtPrm(n: longint; const v: variant): variant; overload;
function FmtPrm(n: longint): variant; overload;
function i_const(const v,ind: variant; lSave: boolean): variant; overload;
function i_const(const ind: variant; lSave: boolean): variant; overload;
procedure i_constSelf(var ind: variant; lSave: boolean);
function InterProcStat(const av: array of variant; const AName: string = ''; f: TForm = nil): variant;
function i_itogo(var av: array of variant): variant;
function MessagesDbgCaption(const Caption: string): string;
function InterTmpVarPrefNoCor(const nmv: string): boolean;
{$IFDEF PROF}
procedure InterProfBeg(const nEvalName: string; var oEvalName: string);
procedure InterProfEnd(const oEvalName: string);
{$ENDIF}

implementation

uses Math,Variants,ShellApi,DateUtils,StrUtils,
  Askp,FStat,ER866,KeyLb{$IFDEF PROF},KeyMenu{$ENDIF},
    FPDF417;

const
	O_PLUS     = 1;
	O_SUB      = 2;
	O_MUL      = 3;
	O_DIV      = 4;
	O_DIV0     = 5;
	O_S        = 6;
	O_SE       = 7;
	O_L        = 8;
	O_LE       = 9;
	O_E        = 10;
	O_NE       = 11;
	O_EP       = 12;
	O_AND      = 13;
	O_OR       = 14;
{унарные}
	O_MIN      = 15;
	O_NO       = 16;
	O_UPLUS    = 17;
{присвоение}
	O_PLUSPLUS = 18;
	O_MINMIN   = 19;
	O_TR       = 20;
	O_TRPLUS   = 21;
	O_TRMIN    = 22;
	O_TRMUL    = 23;
	O_TRDIV    = 24;
	O_TRDIV0   = 25;
{присвоение элемента массива}
	O_CNTTR=8; {Количество операторов присваивания}
	O_PLUSPLUSA = O_CNTTR+O_PLUSPLUS;
	O_MINMINA   = O_CNTTR+O_MINMIN;
	O_TRA       = O_CNTTR+O_TR;
	O_TRPLUSA   = O_CNTTR+O_TRPLUS;
	O_TRMINA    = O_CNTTR+O_TRMIN;
	O_TRMULA    = O_CNTTR+O_TRMUL;
	O_TRDIVA    = O_CNTTR+O_TRDIV;
	O_TRDIVA0   = O_CNTTR+O_TRDIV0;
{кол-во операторов с приоритетом}
	O_MAX = 25+O_CNTTR;
	O_BACK    = O_MAX+1;
{операторы работы с константами}
	O_NULL    = O_MAX+2;
	O_INT     = O_MAX+3;
	O_FLOAT   = O_MAX+4;
	O_DATE    = O_MAX+5;
	O_BOOL    = O_MAX+6;
	O_STRING  = O_MAX+7;
{достать значение переменной}
	O_GETVAR  = O_MAX+8;
	O_DOWN    = O_MAX+9;
	O_FUNC    = O_MAX+10;
	O_GOTO    = O_MAX+11;
	O_IGOTO   = O_MAX+12;
	O_RETURN  = O_MAX+13;
{достать значение элемента массива}
	O_GETVARA = O_MAX+14;
{определение массива}
	O_ARRAY   = O_MAX+15;
// Встроенные ф-и
	O_FUNCBI  = O_MAX+16;
// Остановить алгоритм
	O_STOP    = O_MAX+17;
  //O_CNT=O_MAX+17;
{Максимальное количество локальных переменных}
	MAXLVAR1=72;
{Максимальное количество хранимых переменных}
  MAXLVAR=MAXLVAR1+28;

  sCommBeg  = '/*';
  sCommEnd  = '*/'; lCommEnd=Length(sCommEnd);
  sUslComp  = '$';
  sIF       = 'ЕСЛИ';
  sELSE     = 'ИНАЧЕ';
  sENDIF    = 'КОНЕЦ_ЕСЛИ';
  sWHILE    = 'ПОКА';
  sCONT     = 'ПРОДОЛЖИТЬ';
  sEXIT     = 'ВЫЙТИ';
  sENDWHILE = 'КОНЕЦ_ПОКА';
  sEND      = 'КОНЕЦ';
  sCASES    = 'ВАРИАНТЫ';
  sCASE     = 'ВАРИАНТ';

  FuncProfRename = 'ProfRename';

  MaxNline = MaxInt-1;

type
  TNone = class(TObject)
  private
  	class procedure PrStat(Sender: TStat);
  	class procedure PrWait(Sender: TAsk);
{$IFDEF PROF}
    class procedure Prof(Key: longint; tw: TWinControl);
{$ENDIF}
  end;

  THSLList = class(TStringList)
  private
    a: array of record
      varb,parb: boolean;(* может быть: оба true, т.е. наим-е переменной совпадает с наим-м раздела *)
      name,hint,types,hlpfile: string;
      ReadOnly: boolean;
      proc:TVarevent;
      index: variant;
      sl: THSLList;
      help: THelpContext;
    end;
    constructor Create;
    function IgnoreFindAdd(const s: string; var i: longint): boolean;
  end;

  TStack = array[0..255] of variant;

  TSortComp = function(const v1,v2: variant; aprm: PInterPrmArrVar): longint;

	transf = record
		case byte of
			0: (i,i1:longint);
			1: (f:double);
			2: (b:boolean;sb:array[1..7] of char);
			3: (s:array[1..8] of char);
			4: (d:Tdatetime);
			5: (i2:smallint);
		end;

var cur_vf,nvar,lafunc,loperv,nline,iGetVar,nAAdd: longint;
  lPrimAll: boolean;
  CurMode: TInterCurMode;
  avar: TArrVarRec;
  afunc: TArrFunc;
  avp: array[byte,1..2,1..MAXLVAR1] of variant;
  IntUcomp: TInter;
  sfmt: TArrVar;
  fPrStat: TForm;
  aGetVar: PArrVarRec;
  anvp: array[boolean] of smallint = (-1,-1);
{$IFDEF PROF}
  CurEvalName: string;
  CntEvalName: longint;
{$ENDIF}
  aDopGetVar: array of record
    av: TArrVar;
    PrEqual: TProcDopGetVarEqual;
	  PrAdd: TProcDopGetVarsAdd;
    PrIgnore: TProcDopGetVarIgnore;
  end;
  aprior:array[1..100] of byte;
  lsVarHelp: TStringList;
  aVarHelp: array of TVarHelp;

const sParSep = '‡';

var
  asParent: array of record namep,hintp: string; end;
  szParent: longint = 0;
  sParHash: string;
  slFL: TStringList = nil;
  aFL: array of record
    flEnabled: boolean;
    flHint: string;
    slVars: TStringList;
  end;
  crrFL: longint = -1;
  lsShape,lsPref: TStringList;
  aShape: array of record
  	prVar: TVarevent;
    prTrans: TVarShapeTrans;
    av: TArrVar;
  end;
  AEvalEncProcs: array of TEvalEncProc;

function InterCurVar;
begin
  {$IFDEF STACKALL}AddStack('inter.InterCurVar');{$ENDIF}
  result:=@avar[cur_vf-1];
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure AddFrom(encProc: TEvalEncProc);
var k: longint;
begin
  k:=length(AEvalEncProcs); SetLength(AEValEncProcs,k+1); AEValEncProcs[k]:=encProc;
end;

procedure LsVarInit;
var i: longint;
begin
  AddStack('Inter.LsVarInit');
  if nvar=0 then begin
    SetLength(avar,MAXLVAR); nvar:=MAXLVAR;
    for i:=low(avar) to high(avar) do VarInit(avar[i]);
  end;
  if slFL=nil then begin
    slFL:=SortStrListCreate; SetLength(aFL,10);
  end;
  DelStack;
end;

procedure FWriteRiz(const Aname,Ahint: string; const Atypes: string = ''; const AReadOnly: boolean = false);
begin
  if iGetVar>high(aGetVar^) then SetLength(aGetVar^,2*length(aGetVar^));
  with aGetVar^[iGetVar] do begin
    name:=Aname; hint:=Ahint; types:=Atypes; ReadOnly:=AReadOnly;
  end;
  Inc(iGetVar);
end;

procedure DopGetVar(const name: string);
var i: longint;
begin
  AddStack('Inter.DopGetVar');
  for i:=low(aDopGetVar) to high(aDopGetVar) do with aDopGetVar[i] do
    if PrEqual(name,av) then PrAdd(FWriteRiz);
  DelStack;
end;

function SetCurVF(mode: TInterCurMode; n: longint): TInterCurVF; overload;
begin
  result.mode:=CurMode; result.n:=cur_vf; CurMode:=mode; cur_vf:=n;
end;

procedure SetCurVF(const Value: TInterCurVF); overload;
begin
  with Value do SetCurVF(mode,n);
end;

type TFindVarOpt = set of (fvNoShape,fvShapeFull,fvShapeCheck);

function FindVar(const s: string; var i: longint; Opt: TFindVarOpt = []): boolean;
var j,k,oi: longint;
  vr: varrec;
begin
	AddStack('Inter.FindVar');
  result:=false;
  for k:=0 to MAXLVAR-1 do if avar[k].name=s then begin
    i:=k+1; result:=true; break;
  end;
  if not result then begin
    ArrProcNone(aInterVarCreate);
    for k:=0 to slFL.Count-1 do with aFL[IntObj(slFL,k)] do if flEnabled then if IntObjFind(slVars,s,i) then begin
      if i<=nvar then result:=avar[i-1].Enabled;
      break;
    end;
  end;
  if not result then if not(fvNoShape in Opt) then if Assigned(lsShape) then
    for k:=0 to lsShape.Count-1 do if AnsiStartsStr(lsShape[k],s) then begin
      result := not((fvShapeCheck in Opt) and (Length(aDopGetVar)>0));
      if not result then begin
        oi:=nInterDopGetVar;
        try
          while not result and (nInterDopGetVar>0) do begin
            if (iGetVar<0) or (nInterDopGetVar<oi) then begin
              if Length(aGetVar^)=0 then SetLength(aGetVar^,1000);
              iGetVar:=0; DopGetVar(s);
            end;
            for j:=low(aGetVar^) to iGetVar-1 do
              if aGetVar^[j].name=s then begin
                result:=true; break;
              end;
            Dec(nInterDopGetVar);
          end;
        finally
          nInterDopGetVar:=oi;
        end;
      end;
      if result then with aShape[IntObj(lsShape,k)] do begin
        VarInit(vr);
        prTrans(Copy(s,Length(lsShape[k])+1,MaxInt),av,fvShapeFull in Opt,vr);
        TInter.setvar('$shapes','');
        i:=TInter.SetVar(s,idShapeHint+vr.hint,prVar,vr.index,vr.types,vr.ReadOnly);
      end;
      break;
    end;
  DelStack;
end;

{$IFDEF PROF}
procedure InterProfBeg;
var oTime: longword;
begin
	oTime:=My_pr.GetTickCount; oEvalName:=CurEvalName; CurEvalName:=nEvalName;
  // Поиск пустых наименований
  {if Trim(nEvalName)='' then begin
    CntEvalName:=CntEvalName;
  end;}
  Inc(CntEvalName); ProfAddTime(IfThen(CntEvalName<>1,@oEvalName),nEvalName,oTime,false);
end;

procedure InterProfEnd;
var oTime: longword;
  nEvalName: string;
begin
  oTime:=My_pr.GetTickCount; nEvalName:=CurEvalName; CurEvalName:=oEvalName; Dec(CntEvalName);
  ProfAddTime(@nEvalName,nEvalName,oTime,true);
end;
{$ENDIF}

function TypesChk(const types: string; const v: variant): boolean;
var t,i: longint;
label lend;
begin
  AddStack('Inter.TypesChk');
  result:=true;
  if types<>'' then begin
    t:=MyVarType(v,true);
    for i:=1 to Length(types) do case types[i] of
      'A': if (t=V_BOOL) or (t=varArray) then goto lend;
      'C','S': if t=V_STRING then goto lend;
      'D': if t=V_DATE then goto lend;
      'F','I','N': if t=V_FLOAT then goto lend;
      'L': if t=V_BOOL then goto lend;
      'U': if t=V_NULL then goto lend;
    end;
    result:=false;
  end;
lend:
  DelStack;
end;

function TypesMsg(const types: string): string;
var i,l: longint;
  s: string;
begin
  AddStack('Inter.TypesMsg');
  l:=Length(types); result:=' быть ';
  for i:=1 to l do begin
    case types[i] of
      'A': s:='массивом';
      'C','S': s:='строкой';
      'D': s:='датой';
      'F','I','N': s:='числом';
      'L': s:='логическим';
      'U': s:='пусто';
    else s:='не понятно чем';
    end;
    IncD(result,IfThen(i>1,IfThen(i=l,' или ',', '))+s);
  end;
  IncD(result,'.');
  DelStack;
end;

{ EInterConstException }
constructor EInterConstException.Create;
begin
  curn:=cur_vf;
  inherited Create('');
end;

{ EInterAnyError }
constructor EInterAnyError.Create;
begin
  Create('');
end;

constructor EInterAnyError.Create(const Text: string);
begin
  case CurMode of
    modeVar: Create(Text,avar[cur_vf-1].name);
    modeFunc: Create(Text,afunc[cur_vf].name);
    modeBuiltIn: Create(Text,aBuiltIn[TBuiltInList(cur_vf)].name);
  else Create(Text,'');
  end;
end;

constructor EInterAnyError.Create(const Text,Name: string);
begin
  mode:=CurMode; CurName:=Name;
  inherited Create(Text);
end;

constructor EInterAnyError.CreateFmt(const Msg: string; const Args: array of const);
begin
  Create(Format(Msg,Args));
end;

constructor EInterAnyError.CreateFmt(const Msg: string; const Args: array of const; const Name: string);
begin
  Create(Format(Msg,Args),Name);
end;

{ Tinter }
constructor Tinter.Create;
begin
	AddStack('TInter.Create');
  IntStatVar:=Self; name:=AName; listcom:=nil; showerror:=true; 
  lsStruct:=TStringListCase.CreateSort;
  DelStack;
end;

destructor Tinter.Destroy;
begin
  AddStack('Tinter.Destroy');
  lsStruct.Free;
  inherited Destroy;
  DelStack;
end;

procedure Tinter.SetProg;
var ls: TStringList;
  i: longint;
begin
	AddStack('TInter.SetProg');
	fl_compile:=true; ls:=TStringList.Create;
  try
    ls.Text:=s; // нельзя LsArrDynamic(s,listcom,CRLF) т.к. могут быть CR/LF вместо CRLF
    SetLength(listcom,ls.Count);
    for i:=0 to ls.Count-1 do listcom[i]:=ls[i];
  finally
    ls.Free;
  end;
  if not Assigned(GetAlgProc) then GetAlgPrm:=s;
  DelStack;
end;

procedure i_stabort; overload;
begin
	AddStack('Inter.i_stabort');
  if fPrStat is TStat then TStat(fPrStat).Abort
  else if fPrStat is TAsk then TAsk(fPrStat).Abort;
  DelStack;
end;

function i_stabort(var av: array of variant): variant; overload;
begin
  result:=null; i_stabort;
end;

{ eval  }
function Tinter.Compile;
var Opt: TInterCompileEvalOpt;
begin
	AddStack('TInter.Compile');
  if lShape then Opt:=[] else Opt:=[iceNoShape];
  EncCompileEval([iceOnlyComp]+Opt,[],ProcVar); result := error=E_NO;
  DelStack;
end;

function Tinter.Eval: variant;
begin
	AddStack('TInter.Eval');
	result:=EncCompileEval([],[null]);
  DelStack;
end;

function Tinter.Eval(const ap:array of variant): variant;
begin
	AddStack('TInter.Eval');
	result:=EncCompileEval([],ap);
  DelStack;
end;

function Tinter.EvalChk: boolean;
begin
  Eval; result := error=E_NO;
end;

function Tinter.EvalChk(var v: variant): boolean;
begin
  v:=Eval; result := error=E_NO;
end;

function Tinter.EvalChk(var v: variant; const ap:array of variant): boolean;
begin
  v:=Eval(ap); result := error=E_NO;
end;

function TInter.EncCompileEval;
var oInter: TInter;
  execEncProc: boolean;
  ape: TArrPointer;
  k,l: longint;
{$IFDEF PROFINTER}
  oEvalName: string;
{$ENDIF}
begin
{$IFDEF PROFINTER}
  if not(iceOnlyComp in Opt) then InterProfBeg(name,oEvalName);
  try
{$ENDIF}
    AddStack('TInter.EncCompileEval');
    iGetVar:=-1; oInter:=CurInter; CurInter:=IfThen(lDebug,InterErr,Self);
    l:=Length(AEvalEncProcs); execEncProc := not(iceOnlyComp in Opt) and (l>0); SetLength(ape,l); Dec(l);
    try
      if execEncProc then for k:=0 to l do AEvalEncProcs[k](true,ape[k]);
      result:=CompileEval(Opt,ap,ProcVar);
    finally
      if execEncProc then for k:=l downto 0 do AEvalEncProcs[k](false,ape[k]);
      CurInter:=oInter;
    end;
    DelStack;
{$IFDEF PROFINTER}
  finally
    if not(iceOnlyComp in Opt) then InterProfEnd(oEvalName);
  end;
{$ENDIF}
end;

function SortProc(p: pointer; fi,si: longint; sortID: TSortID): boolean;
var v: PVariant;
  v1: variant;
  stack: ^TStack;
  n1: longint;
  pr: pointer;
  proc: TSortComp;
begin
  AddStack('Inter.SortProc');
  result:=false; v:=PVariant(p); stack:=PointerVar(v^[1]); n1:=v^[2];
  case sortID of
    sort1MORE2: begin
      pr:=PointerVar(v^[0]); proc:=TSortComp(pr);
      result := proc(stack^[n1][fi],stack^[n1][si],PointerVar(v^[3]))>0;
    end;
    sortEXCHANGE: begin
      v1:=stack^[n1][fi]; stack^[n1][fi]:=stack^[n1][si]; stack^[n1][si]:=v1;
    end;
  end;
  DelStack;
end;

function SortAscending(const v1,v2: variant; aprm: PInterPrmArrVar): longint;
begin
	AddStack('Inter.SortAscending');
  if CompVar(v1,v2) then result:=0 else result:=aSign[v1<v2];
  DelStack;
end;

function SortDescending(const v1,v2: variant; aprm: PInterPrmArrVar): longint;
begin
	AddStack('Inter.SortDescending');
  if CompVar(v1,v2) then result:=0 else result:=aSign[v1>v2];
  DelStack;
end;

function SortAAscending(const v1,v2: variant; aprm: PInterPrmArrVar): longint;
begin
	AddStack('Inter.SortAAscending');
  if CompVar(v1[1],v2[1]) then result:=0 else result:=aSign[v1[1]<v2[1]];
  DelStack;
end;

function SortADescending(const v1,v2: variant; aprm: PInterPrmArrVar): longint;
begin
	AddStack('Inter.SortADescending');
  if CompVar(v1[1],v2[1]) then result:=0 else result:=aSign[v1[1]>v2[1]];
  DelStack;
end;

function SortEval(const v1,v2: variant; aprm: PInterPrmArrVar): longint;
var v: variant;
begin
	AddStack('Inter.SortEval');
  aprm[1]:=v1; aprm[2]:=v2;
  if CurInter.EvalChk(v,aprm^) then result:=v
  else begin
    result:=0; i_stabort;
  end;
  DelStack;
end;

procedure Stop;
begin
  AddStack('Inter.Stop');
  InterErr:=CurInter; anvp[true]:=anvp[false];
  if InterShowError(CurInter,[low(TIEKey)..high(TIEKey)],nil,nil,
    'Остановка выполнения формулы')<>mrOk then nline:=MaxNline;
  DelStack;
end;

function InterProcStat;
var ofPrStat: TForm;
  oInter: TInter;
begin
  AddStack('Inter.InterProcStat');
  ofPrStat:=fPrStat; oInter:=CurInter; CurInter:=TInter.Create('');
  try
    with CurInter do begin
      Assign(oInter);
      if AName='' then name:='Выполнение функции '+afunc[cur_vf].name+'()' else name:=AName;
      showerror:=true; value_types:='';
      if Assigned(f) then fPrStat:=f;
      if not EvalChk(result,av) then i_stabort;
    end;
  finally
    CurInter.Free; CurInter:=oInter; fPrStat:=ofPrStat;
  end;
  DelStack;
end;

{$IFDEF PROF}
procedure FProf(Capt: TCaption);
begin
  if not ProfSwitch then begin
    ProfSwitch:=true; ProfOn;
  end;
  ProfOut(Capt); ProfOn;
end;
{$ENDIF}

function Tinter.CompileEval; procedure Dummy; // Return value of function might be undefined
  procedure Err(e: TInterError; const msg: string = ''); overload;
  begin
    error:=e;
    raise EInterException.create(msg);
  end;
  procedure Err; overload;
  begin
    Err(error);
  end;
var ind:longint;
	com,formula:string;
  fvo: TFindVarOpt;
  dwStruct: TWord2DWord;
  procedure Fcompile;
    procedure FProcVar(const VarName: string; var Pos: TInterVarPos);
    begin
      {$IFDEF STACKALL}AddStack('TInter.CompileEval.Fcompile.FProcVar');{$ENDIF}
      if Assigned(ProcVar) then ProcVar(Self,VarName,Pos);
      {$IFDEF STACKALL}DelStack;{$ENDIF}
    end;
    function curliter:char;
    var i:longint;
    begin
      {$IFDEF STACKALL}AddStack('TInter.CompileEval.Fcompile.curliter');{$ENDIF}
      result:=#0;
      for i:=ind to length(formula) do if formula[i]<>' ' then begin
        result:=formula[i]; break;
      end;
      {$IFDEF STACKALL}DelStack;{$ENDIF}
    end;
  const
    sGOTO  = '__1';
    sIGOTO = '__2';
  var lc: longint;
    lsTmpVar: TStringListCase;
    procedure compblok;
      function curchar:char;
      begin
        {$IFDEF STACKALL}AddStack('TInter.CompileEval.Fcompile.compblok.curchar');{$ENDIF}
        if ind>length(formula) then result:=#0 else result:=formula[ind];
        {$IFDEF STACKALL}DelStack;{$ENDIF}
      end;
      function getchar:char;
      begin
        {$IFDEF STACKALL}AddStack('TInter.CompileEval.Fcompile.compblok.getchar');{$ENDIF}
        result:=curchar; Inc(ind);
        {$IFDEF STACKALL}DelStack;{$ENDIF}
      end;
      function getliter:char;
      begin
        {$IFDEF STACKALL}AddStack('TInter.CompileEval.Fcompile.compblok.getliter');{$ENDIF}
        result:=#0;
        while ind<=length(formula) do
          if formula[ind]=' ' then Inc(ind)
          else begin
            result:=formula[ind]; break;
          end;
        Inc(ind);
        {$IFDEF STACKALL}DelStack;{$ENDIF}
      end;
      procedure put_oper(oper: byte);
      begin
        {$IFDEF STACKALL}AddStack('TInter.CompileEval.Fcompile.compblok.put_oper');{$ENDIF}
        Inc(lc); com[lc]:=chr(oper);
        {$IFDEF STACKALL}DelStack;{$ENDIF}
      end;
      procedure put_data(const v: variant);
      var vt:longint;
        tr:transf;
        s: string;
      begin
        {$IFDEF STACKALL}AddStack('TInter.CompileEval.Fcompile.compblok.put_data');{$ENDIF}
        vt:=MyVarType(v);
        case vt of
          V_INT: begin
            tr.i:=v; put_oper(O_INT);
            Inc(lc); com[lc]:=tr.s[1];
            Inc(lc); com[lc]:=tr.s[2];
            Inc(lc); com[lc]:=tr.s[3];
            Inc(lc); com[lc]:=tr.s[4];
          end;
          V_FLOAT: begin
            tr.f:=v; put_oper(O_FLOAT);
            Inc(lc); com[lc]:=tr.s[1];
            Inc(lc); com[lc]:=tr.s[2];
            Inc(lc); com[lc]:=tr.s[3];
            Inc(lc); com[lc]:=tr.s[4];
            Inc(lc); com[lc]:=tr.s[5];
            Inc(lc); com[lc]:=tr.s[6];
            Inc(lc); com[lc]:=tr.s[7];
            Inc(lc); com[lc]:=tr.s[8];
          end;
          V_DATE: begin
            tr.f:=v; put_oper(O_DATE);
            Inc(lc); com[lc]:=tr.s[1];
            Inc(lc); com[lc]:=tr.s[2];
            Inc(lc); com[lc]:=tr.s[3];
            Inc(lc); com[lc]:=tr.s[4];
            Inc(lc); com[lc]:=tr.s[5];
            Inc(lc); com[lc]:=tr.s[6];
            Inc(lc); com[lc]:=tr.s[7];
            Inc(lc); com[lc]:=tr.s[8];
          end;
          V_BOOL:begin
            tr.f:=v; put_oper(O_BOOL);
            Inc(lc); com[lc]:=tr.s[1];
          end;
          V_STRING:begin
            s:=v; tr.i:=length(s); put_oper(O_STRING);
            Inc(lc); com[lc]:=tr.s[1];
            Inc(lc); com[lc]:=tr.s[2];
            Inc(lc); com[lc]:=tr.s[3];
            Inc(lc); com[lc]:=tr.s[4];
            for vt:=1 to tr.i do begin
              Inc(lc); com[lc]:=s[vt];
            end;
          end;
        else put_oper(O_NULL);
        end;
        {$IFDEF STACKALL}DelStack;{$ENDIF}
      end;
    var aoper :array[1..100] of byte;
      aoperind :longint;
      procedure putoper(upr:byte);
      begin
        AddStack('TInter.CompileEval.Fcompile.compblok.putoper');
        while aoperind>0 do
          if (aprior[aoper[aoperind]]<=upr) and (upr>0) then begin
            put_oper(aoper[aoperind]); dec(aoperind);
          end
          else break;
        DelStack;
      end;
    var p: longint;
      function Struct: boolean;
      begin
        AddStack('TInter.CompileEval.Fcompile.compblok.Struct');
        result:=IntObjFind(CurInter.lsStruct,Copy(formula,p,ind-p),p);
        if result then dwStruct.dw:=p else Err(E_STRUCT);
        DelStack;
      end;
    const atr: array[0..7] of longint = (O_TR,O_PLUSPLUS,O_MINMIN,O_TRPLUS,O_TRMIN,O_TRMUL,O_TRDIV,O_TRDIV0);
    var c,cl:char;i,j:longint;
      isoper,addv,ltr:boolean;
      oper,oper2 :byte;
      s:string;
      v:variant;
      Pos: TInterVarPos;
      ovf: TInterCurVF;
    label lend;
    begin
      AddStack('TInter.CompileEval.Fcompile.compblok');
      isoper:=false; ltr:=false;
      aoperind:=0;
      error:=E_NO;
      j:=0;
      while true do begin
        if isoper then begin
          c:=curliter; oper:=0;
          {if Assigned(ProcInterCompOper) then begin
            ProcInterCompOper(c,oper);
            if oper<>0 then getliter;
          end;}
          if oper=0 then case c of
            #0,')',',',']','}':begin
              putoper(100); goto lend;
            end;
            '!':begin
              getliter;
              if curchar='=' then begin
                oper:=O_NE; getchar;
              end
              else Err(E_OPER);
            end;
            '*':begin
              oper:=O_MUL;getliter;
              if curchar='=' then begin
                oper:=O_TRMUL;ltr:=true;getchar;
                if curchar='>' then begin
                  getchar;
                end;
              end;
            end;
            '+':begin
              oper:=O_PLUS;getliter;
              if curchar='=' then begin
                oper:=O_TRPLUS;ltr:=true;getchar;
                if curchar='>' then begin
                  getchar;
                end;
              end;
            end;
            '-':begin
              oper:=O_SUB;getliter;
              if curchar='=' then begin
                oper:=O_TRMIN;ltr:=true;getchar;
                if curchar='>' then begin
                  getchar;
                end;
              end;
            end;
            '/',':':begin
              oper:=IfThen(c=':',O_DIV0,O_DIV); getliter;
              if curchar='=' then begin
                oper:=IfThen(c=':',O_TRDIV0,O_TRDIV);ltr:=true;getchar;
                if curchar='>' then begin
                  getchar;
                end;
              end;
            end;
            '<':begin
              oper:=O_S;
              getliter;	cl:=curchar;
              if cl='=' then begin
                oper:=O_SE;
                getchar;
              end else if cl='>' then begin
                oper:=O_NE;
                getchar;
              end;
            end;
            '=':begin
              oper:=O_E;
              getliter;cl:=curchar;
              if cl='=' then begin
                oper:=O_EP;
                getchar;
              end else if cl='>' then begin
                oper:=O_TR; ltr:=true;
                getchar;
              end;
            end;
            '>':begin
              oper:=O_L;
              getliter;
              if curchar='=' then begin
                oper:=O_LE;
                getchar;
              end;
            end;
            'И','и':begin
              oper:=O_AND;
              getliter;cl:=curchar;
              if ((cl='л') or (cl='Л')) then begin
                getchar;cl:=curchar;
                if ((cl='и')or (cl='И')) then begin
                  oper:=O_OR; getchar;
                end
                else Err(E_OPER);
              end;
            end;
          end;
          if oper=0 then Err(E_OPER);
          putoper(aprior[oper]);
          Inc(aoperind);
          aoper[aoperind]:=oper;
          isoper:=false;
        end	else begin { домен}
          c:=curliter; oper:=0; s:=''; addv:=true;
          case c of
            '!':begin oper:=O_NO;getliter;end;
            // #структура
            '#': begin
              getliter; p:=ind;
              while IsChrWord(curchar) do getchar;
              if Struct then v:=dwStruct.w2 else Err(E_STRUCT);
            end;
            '"','''':begin
              getliter;
              cl:=curchar;
              while (cl<>#0) and (cl<>c) do begin
                IncD(s,getchar); cl:=curchar;
              end;
              if cl=c then getchar else Err(E_SCONST);
              v:=s;
              if aoperind>0 then if ArrIntMatch(aoper[aoperind],atr) then raise EInterAnyError.Create(
                'Нельзя присваивать значение константе "'+s+'"');
            end;
            '(':begin
              getliter; compblok;
              while curliter=',' do begin
                getliter; compblok; put_oper(O_BACK);
              end;
              if curliter=')' then getliter else Err(E_CLOSE);
              addv:=false;
            end; {Унарные операции}
            ')',',','}':begin
              v:=null;
            end;
            '+':begin
              oper:=O_UPLUS;getliter;
              if curchar='+' then begin
                oper:=O_PLUSPLUS;ltr:=true;getchar;
              end;
            end;
            '-':begin
              oper:=O_MIN;getliter;
              if curchar='-' then begin
                oper:=O_MINMIN;ltr:=true;getchar;
              end;
            end;
            //константа (число|дата)
            '.','0'..'9':begin
              i:=0;
              if c<>'.' then begin
                IncD(s,getliter); cl:=curchar;
                while cl in ['0'..'9'] do begin
                  IncD(s,getchar); cl:=curchar;
                end;
              end else begin
                s:= '0';
              end;
              if curliter='.' then begin
                getliter;
                IncD(s,',');
                j:=length(s);
                cl:=curchar;
                while cl in ['0'..'9'] do begin
                  IncD(s,getchar); cl:=curchar;
                end;
                inc(i);
              end;
              if curchar='.' then begin
                s[j]:=dateseparator;
                IncD(s,dateseparator);
                getchar;cl:=curchar;
                while cl in ['0'..'9'] do begin
                  IncD(s,getchar); cl:=curchar;
                end;
                inc(i);
              end;
              case i of
                0: v:=strtoint(s);
                1: v:=strtofloat(s);
                2: begin
                  v:=DateEmpty;
                  for p:=1 to Length(s) do
                    if (s[p]>' ') and not(s[p] in ['0',dateseparator]) then begin
                      v:=StrToDate(s); break;
                    end;
                end;
              end;
              if aoperind>0 then if ArrIntMatch(aoper[aoperind],atr) then raise EInterAnyError.Create(
                'Нельзя присваивать значение константе '+s);
            end;
            'A'..'Z','_','a'..'z','Ё','ё','А'..'я': begin
              addv:=false;
              IncD(s,getliter); cl:=curchar;
              while IsChrWord(cl) do begin
                IncD(s,getchar); cl:=curchar;
              end;
              cl:=curliter;
              if cl='(' then begin  {функция}
                getliter;
                i:=1;
                if s=sGOTO then begin
                  i:=-1;j:=1;
                end;
                if s=sIGOTO then begin
                  i:=-2;j:=2;
                end;
                if s='ИТОГО' then begin
                  i:=-3;j:=1;
                end;
                if i>0 then
                  while i<=lafunc do begin
                    if afunc[i].name=s then begin
                      j:=Length(afunc[i].aPrm); break;
                    end;
                    inc(i);
                  end;
                if i<=lafunc then begin
                  p:=1; compblok;
                  while curliter=',' do begin
                    getliter; inc(p); compblok;
                  end;
                  if curliter=')' then begin
                    getliter;
                    while p>j do begin
                      dec(p); put_oper(O_DOWN);
                    end;
                    while p<j do begin
                      inc(p); put_oper(O_NULL);
                    end;
                    if i>0 then begin
                      if afunc[i].nBuiltIn>0 then begin
                        oper2:=O_FUNCBI; i:=afunc[i].nBuiltIn;
                      end
                      else oper2:=O_FUNC;
                      put_data(i); put_oper(oper2);
                    end
                    else if i=-1 then put_oper(O_GOTO)
                    else if i=-2 then put_oper(O_IGOTO)
                    else if i=-3 then put_oper(O_RETURN);
                  end
                  else Err(E_CLOSE);
                end
                else Err(E_FUNC,s);
              end
              else if FindVar(s,i,fvo) then begin
                ovf:=SetCurVF(modeVar,i);
                try
                  if ltr then
                    if avar[i-1].ReadOnly then raise EInterConstException.Create;
                  Pos:=ivpText; FProcVar(avar[i-1].name,Pos); ltr:=false; put_data(i);
                  if curchar in ['.','[']  then begin {Массив}
      //                put_oper(O_GETVAR);
                    j:=0;
                    if i<=MAXLVAR then begin
                      p:=1;
                      while (curchar in ['.','[']) or ((curchar=',') and (p=0)) do begin
                        if curchar='.' then begin
                          p:=ind+1;
                          repeat
                            getchar;
                          until not IsChrWord(curchar);
                          if Struct then put_data(dwStruct.w2);
                          p:=1;
                        end
                        else begin
                          getchar; compblok;
                          case curchar of
                            ',': p:=0;
                            ']': begin
                              p:=1;  // должна быть откр.скобка
                              getchar;
                            end;
                          else Err(E_CLOSE); // Ошибка
                          end;
                        end;
                        inc(j);
                      end;
                      if j>5 then Err(E_ARRDIM);
                      put_data(j);
                      if aoperind =0 then put_oper(O_GETVARA)
                      else begin
                        oper2:=aoper[aoperind];
                        if ArrIntMatch(oper2,atr)
                        then Inc(aoper[aoperind],O_CNTTR)
                        else put_oper(O_GETVARA);
                      end;
                    end
                    else Err(E_ARRLOC); // Ошибка
                  end else begin
                    if aoperind =0 then put_oper(O_GETVAR)
                    else begin
                      oper2:=aoper[aoperind];
                      if not ArrIntMatch(oper2,atr) then put_oper(O_GETVAR);
                    end;
                  end;
                finally
                  SetCurVF(ovf);
                end;
              end
              else if s='СТОП'
                then put_oper(O_STOP)
              else Err(E_VAR,s);
            end;
            '{':begin  {массив}
              getliter;
              if curliter='}' then begin
                addv:=false; getliter; FindVar(vFalse,j); put_data(j);
                if aoperind=0 then put_oper(O_GETVAR)
                else begin
                  oper2:=aoper[aoperind];
                  if not ArrIntMatch(oper2,atr) then put_oper(O_GETVAR);
                end;
              end
              else begin
                compblok;
                j:=1;
                while curliter=',' do begin
                  getliter;
                  compblok;
                  inc(j);
                end;
                if curliter='}' then getliter else Err(E_CLOSE);
                put_data(j); put_oper(O_ARRAY); addv:=false;
              end;
            end;
          else
            Err(E_NAME);
          end; {endcase}
          if oper=0 then begin
            isoper:=true;
            if addv then begin
              put_data(v);
            end;
          end else begin
            putoper(aprior[oper]);
            Inc(aoperind);
            aoper[aoperind]:=oper;
          end;
        end;
      end;
    lend:
      DelStack;
    end;
  var ucusl,ucom: boolean;
    ucle,uclv,uclIF: longint;
    ucs,fmls: string;
    procedure UslComp;
    var v: variant;
    begin
      AddStack('Tinter.CompileEval.Fcompile.UslComp');
      ucusl := RightStr(fmls,lCommEnd)<>sCommEnd;
      if ucusl then IncD(fmls,CRLF)
      else begin
        if not Assigned(IntUcomp) then begin
          IntUcomp:=TInter.Create('Условная компиляция');
          IntUcomp.showerror:=false; IntUcomp.value_types:='L';
        end;
        DecLen(fmls,2); IntUcomp.SetProg(fmls);
        if not IntUcomp.EvalChk(v) then begin
          lerror:=EnsureRange(ucle+IntUcomp.lerror-1,ucle,lerror);
          raise EInterAnyError.create(IntUcomp.serror);
        end;
        fmls:=''; SetLength(ucs,uclv); ucs[uclv]:=Bool2Str(v)[1]; ucom:=not v;
      end;
      DelStack;
    end;
  var lv: TArrBoolInt;
    fl,lStruct:boolean;
    lsVar: TStringListCase;
    ckey: string;
    procedure AddTmpVar;
    const alv: array[boolean] of record
      l: longint;
      e: TInterError
    end =
      ((l:MAXLVAR1; e:E_MANYLV)
      ,(l:MAXLVAR ; e:E_MANYST)
      );
    var i: longint;
      Pos: TInterVarPos;
    begin
      AddStack('Tinter.CompileEval.Fcompile.AddTmpVar');
      TrimSelf(ckey);
      if length(ckey)>0 then begin
        if not lStruct then with alv[fl] do begin
          if lv[fl]=l then Err(e);
          avar[lv[fl]].name:=ckey;
        end;
        Pos:=ivpDefine;
        if Assigned(lsVar) then
          if IgnoreSlFindAdd(lsVar,ckey,i)
          then Pos:=ivpRepeat
          else if lStruct then lsVar.Objects[i]:=Pointer(dwStruct.dw);
        FProcVar(ckey,Pos);
        if Pos=ivpRepeat then ProcError('%s "%s" определена несколько раз',
          [IfThen(lStruct,'Структура','Временная переменная'),ckey],IfThen(lStruct,1,2));
        if Pos<>ipvPrefNoCor then
          if InterTmpVarPrefNoCor(ckey) then ProcError('Некорректный префикс %s %s',
            [IfThen(lStruct,'структуры','временной переменной'),ckey],2);
        if not lStruct then inc(lv[fl]);
        ckey:='';
      end;
      if lStruct then Inc(dwStruct.w2);
      DelStack;
    end;
	const MAXLINE=4096;
  type
    TMaxLine=1..MAXLINE;
    TMaxLineInt=array[TMaxLine] of smallint;
  var i,ic,il,ilc,ilall:longint;
    anline: TMaxLineInt;
    procedure icInc;
    begin
      AddStack('Tinter.CompileEval.Fcompile.icInc');
      inc(ic);
      if ic>MAXLINE then raise EInterAnyError.CreateFmt(
        'Количество строк превышает максимально допустимое (%d)',[MAXLINE]);
      if(il>0) then begin
        anline[ic]:=ilc;
      end else begin
        anline[ic]:=i-ilall;
      end;
      DelStack;
    end;
  var listtmp: TArrStr;
    ntmp,ltmp:longint;
    procedure listtmpAdd(const s: string);
    begin
      AddStack('Tinter.CompileEval.Fcompile.listtmpAdd');
      if ntmp=ltmp then begin
        Inc(ltmp,1000); SetLength(listtmp,ltmp);
      end;
      listtmp[ntmp]:=s; Inc(ntmp);
      DelStack;
    end;
  type TOperList = (opNone,opIf,opWhile,opCases);
  const asOper: array[TOperList] of string = ('',sIF,sWHILE,sCASES);
  var liwa: array of TMaxLineInt;
    stiwa: array[1..100] of smallint;
    nstiwa:smallint;
    aop: array[TMaxLine] of record
      op: TOperList;
      lliwa: smallint;
    end;
  var j,k,k2:longint;
    c:char;
    comm:boolean;
    nliwa,onvp:smallint;
    oform: string;
    anst,alab: TMaxLineInt;
    tr:transf;
    oavar: array[1..MAXLVAR] of varrec;
    a: TArrStr;
    al: TNamePrimStr;
  begin
    AddStack('TInter.CompileEval.Fcompile');
    SetLength(liwa,2); i:=MAXLINE*SizeOf(smallint);
    ZeroMemory(@liwa[0],i*Length(liwa)); ZeroMemory(@aop,i); ZeroMemory(@anst,i); ZeroMemory(@alab,i);
    LsVarInit;
    for i:=1 to MAXLVAR do begin
      oavar[i]:=avar[i-1];
      if not lDebug then avar[i-1].name:='';
    end;
    Inc(anvp[false]); onvp:=nvp; nvp:=anvp[lDebug];
    oform:=formula; i:=0; ic:=0; lv:=ArrBoolInt(0,MAXLVAR1); ntmp:=0; ltmp:=0;
    lsTmpVar:=TStringListCase.CreateIf(IsUserGG,true);
    try
      if not lDebug then lsStruct.Clear;
      formula:=''; nstiwa:=0; nliwa:=0; error:=E_END; comm:=false;
      ucom:=false; ucusl:=false; uclv:=0; ucs:=''; uclIF:=0; ilc:=0; il:=0; ilall:=0; dwStruct.w1:=0;
      while i<=high(Listcom) do begin
        fmls:=trim(Listcom[i]); inc(i); lerror:=i-ilall;
        if il>0 then begin
          dec(il); lerror:=ilc;
        end;
        if ucusl then begin
          UslComp; continue;
        end;
        if ACompStr(fmls,[sCommBeg+sUslComp]) then begin
          if ACompStr(fmls,[sIF]) then begin
            Inc(uclv);
            if not ucom then begin
              ucle:=lerror;
              if uclv=1 then uclIF:=ucle;
              UslComp;
            end;
          end
          else if ACompStr(fmls,[sELSE]) then begin
            if uclv=0 then raise EInterAnyError.Create(
              'Лишний оператор '+sCommBeg+sUslComp+sELSE+sCommEnd);
            fmls:=''; 
            if Length(ucs)>=uclv then begin
              ucom:=StrToBoolean(ucs[uclv]); ucs[uclv]:=bStr[not ucom];
            end;
          end
          else if ACompStr(fmls,[sENDIF]) then begin
            if uclv=0 then raise EInterAnyError.Create(
              'Лишний оператор '+sCommBeg+sUslComp+sENDIF+sCommEnd);
            fmls:=''; Dec(uclv); SetLength(ucs,uclv);
            if uclv=0 then ucom:=false else ucom:=not StrToBoolean(ucs[uclv]);
          end;
          continue;
        end;
        if ucom then begin
          fmls:=''; continue;
        end;
        if AnsiStartsStr(sCommBeg,fmls) then comm:=true;
        if comm and (RightStr(fmls,lCommEnd)=sCommEnd) then begin
          comm:=false; fmls:=''; continue;
        end;
        if comm then begin
          fmls:=''; continue;
        end;
        if (length(fmls)>0) and (fmls[1]='*') then begin
          fmls:=''; continue;
        end;
        if StrDivDlm('&&',fmls,al) then fmls:=trim(al[1]);
        if Length(fmls)=0 then continue;
        IncD(formula,fmls); j:=length(formula); c:=formula[j];
        if (c=';') or (c='\') then begin
          //formula:=trim(copy(formula,1,j-1));
          formula[j]:=' ';
          if i<=high(Listcom) then continue;
        end;
        ckey:=''; j:=1;
        while j<=length(formula) do begin
          c:=formula[j];
          if IsChrWord(c) then IncD(ckey,c) else break;
          inc(j);
        end;
        if empty(Copy(formula,Length(ckey)+1,1)) then begin
          j:=1;
          while j<=loperv do begin
            if (aoperv[j].name=ckey) then break;
            inc(j);
          end;
        end
        else j:=loperv+1;
        if j<=loperv then begin
          il:=LsArrDynamic(aoperv[j].optext,a,CRLF); k2:=i-1;
          case il of
            0: listcom[k2]:='';
            1: listcom[k2]:=a[0];
          else
            DecLen(listcom,1-il);
            MoveMemory(@listcom[k2+il],@listcom[k2+1],
              SizeOf(Pstring)*(Length(listcom)-k2-il));
            ZeroMemory(@listcom[k2+1],SizeOf(Pstring)*(il-1));
            for k:=0 to il-1 do begin
              listcom[k2]:=a[k]; inc(k2);
            end;
          end;
          ilc:=i-ilall; formula:=''; Inc(ilall,il-1); dec(i); continue;
        end;
        fl := ckey='ХРАНИМЫЕ'; lStruct := ckey='СТРУКТУРА';
        if (AnsiMatchStr(ckey,['ПЕРЕМЕННАЯ','ПЕРЕМЕННЫЕ','ПАРАМЕТР']) or fl or lStruct)
        and empty(Copy(formula,Length(ckey)+1,1)) then begin
          if lStruct then begin
            lsVar:=CurInter.lsStruct; Inc(dwStruct.w1);
          end
          else lsVar:=lsTmpVar;
          j:=Length(ckey)+2; ckey:=''; dwStruct.w2:=1;
          while j<=length(formula) do begin
            c:=formula[j];
            if IsChrWord(c) then IncD(ckey,c)
            else if (c=',') or not lStruct and (c=' ') then AddTmpVar;
            inc(j);
          end;
          AddTmpVar; formula:=''; continue;
        end;
        icInc;
        if ckey<>'' then if AnsiFindText(ckey,asOper,k) then begin
          inc(nliwa);
          with aop[nliwa] do begin
            op:=TOperList(k);
            case op of
              opIf: begin
                liwa[0,nliwa]:=0; liwa[1,nliwa]:=0;
              end;
              opWhile: begin
                liwa[0,nliwa]:=0; liwa[1,nliwa]:=ic-1;
              end;
              opCases: begin
                lliwa:=0; alab[ic]:=1;
              end;
            end;
            anst[ic]:=nliwa;
            inc(nstiwa);stiwa[nstiwa]:=nliwa;
            CopySelf(formula,Length(ckey)+1);
            if empty(formula) then formula:=vFalse;
            formula:='('+formula+')';
          end;
        end;
        if ckey=sCASE then
          if (nstiwa>0)and(aop[stiwa[nstiwa]].op=opCases) then begin
            k:=stiwa[nstiwa];
            with aop[k] do begin
              anst[ic]:=k;
              Inc(lliwa);
              if Length(liwa)=lliwa+1 then begin
                SetLength(liwa,lliwa+2); ZeroMemory(@liwa[lliwa+1],SizeOf(liwa[lliwa]));
              end;
              liwa[lliwa,k]:=ic;
              listtmpAdd(''); icInc;
              anst[ic]:=k; alab[ic]:=lliwa+1;
              formula:='('+Copy(formula,Length(ckey)+1,MaxInt)+')';
            end;
          end
          else Err;
        if ckey=sELSE then
          if (nstiwa>0)and(aop[stiwa[nstiwa]].op in [opIf,opCases]) then begin
            k:=stiwa[nstiwa]; anst[ic]:=k;
            with aop[k] do begin
              case op of
                opIf: begin
                  liwa[0,k]:=ic; alab[ic]:=1;
                end;
                opCases: liwa[lliwa+1,k]:=ic;
              end;
              formula:='';
            end;
          end
          else Err;
        if ckey=sEXIT then begin
          k:= nstiwa;
          while (k>0)and (aop[stiwa[k]].op<>opWhile) do begin
            dec(k);
          end;
          if k>0 then begin
            anst[ic]:=stiwa[k];
          end
          else Err;
          formula:='';
        end;
        if ckey=sCONT then begin
          k:=nstiwa;
          while (k>0)and (aop[stiwa[k]].op<>opWhile) do begin
            dec(k);
          end;
          if k>0 then begin
            anst[ic]:=stiwa[k];alab[ic]:=1;
          end
          else Err;
          formula:='';
        end;
        if ckey=sEND then
          if nstiwa>0 then begin
            k:=stiwa[nstiwa];
            with aop[k] do case op of
              opIf: ckey:=sENDIF;
              opWhile: ckey:=sENDWHILE;
              opCases: begin
                liwa[0,k]:=ic;
                if liwa[lliwa+1,k]=0 then liwa[lliwa+1,k]:=ic;
                dec(nstiwa); formula:='';
              end;
            end;
          end
          else Err;
        if ckey=sENDIF then
          if (nstiwa>0)and(aop[stiwa[nstiwa]].op=opIf) then begin
            k:=stiwa[nstiwa];
            liwa[1,k]:=ic;
            if liwa[0,k]=0 then liwa[0,k]:=ic;
            dec(nstiwa);
            formula:='';
          end
          else Err;
        if ckey=sENDWHILE then
          if (nstiwa>0)and(aop[stiwa[nstiwa]].op=opWhile) then begin
            k:=stiwa[nstiwa];
            liwa[0,k]:=ic;
            dec(nstiwa);
            formula:='';
            anst[ic]:=k;alab[ic]:=1;
          end
          else Err;
        listtmpAdd(formula);
        formula:='';
      end;
      if uclv>0 then begin
        lerror:=uclIF;
        raise EInterAnyError.Create('Для оператора '+sCommBeg+sUslComp+sIF+sCommEnd
          +' нет соответствующего '+sCommBeg+sUslComp+sENDIF+sCommEnd);
      end;
      if nstiwa>0 then begin
        ckey:=asOper[aop[stiwa[nstiwa]].op];
        raise EInterAnyError.Create('Для оператора '+ckey+' нет соответствующего '+sEND
          +IfThen(aop[stiwa[nstiwa]].op<>opCases,'_'+ckey));
      end;
      error:=E_NO;
      if comm then Err(E_COMMENT);
      i:=0;
      while i<ntmp do begin
        k:=anst[i+1];
        if k=0 then formula :='('+ Listtmp[i]+')'
        else begin
          formula :=Listtmp[i];
          if length(formula)=0
          then formula:=sGOTO+Format('(%d)',[liwa[alab[i+1],k]])
          else IncL(formula,sIGOTO+'(',Format(',%d)',[liwa[alab[i+1],k]]));
        end;
        ind:=1; SetLength(com,Length(formula) shl 2); lc:=0;
        lerror:=anline[i+1];
        compblok;
        if curliter<>#0 then Err(E_CLOSE);
        tr.i2:=lerror; SetLength(com,lc); Listtmp[i] :=tr.s[1]+tr.s[2]+com; inc(i);
      end;
      SetLength(listcom,ntmp);
      for i:=low(listcom) to high(listcom) do listcom[i]:=listtmp[i];
      Listtmp:=nil;
      if not lDebug then begin
        SetLength(IntStatVar.ast,lv[true]-MAXLVAR1);
        for i:=low(IntStatVar.ast) to high(IntStatVar.ast) do IntStatVar.ast[i]:=null;
      end;
      fl_compile:=false;
    finally
      lsTmpVar.Free;
      if not(iceOnlyComp in Opt) then for i:=1 to MAXLVAR do avar[i-1]:=oavar[i];
      Dec(anvp[false]); nvp:=onvp; formula:=oform;
    end;
    DelStack;
  end;
var stack: TStack;
  procedure Evalcom;
  var ist: longint;
    class procedure VarProcSelf(const v:variant; lSave: boolean);
    begin
      stack[ist]:=VarProc(stack[ist],v,lSave);
    end;
    function arread: variant;
    var i,j,cntind:longint;
    begin
      {$IFDEF STACKALL}AddStack('TInter.CompileEval.Evalcom.arread');{$ENDIF}
      cntind:=stack[ist]; //кол-во индексов
      j:=ist-cntind; i:=stack[j-1];
      if i>MAXLVAR1 then begin
        Dec(i,MAXLVAR1+1);
        case cntind of
          1: result:=CurInter.IntStatVar.ast[i][stack[j]];
          2: result:=CurInter.IntStatVar.ast[i][stack[j]][stack[j+1]];
          3: result:=CurInter.IntStatVar.ast[i][stack[j]][stack[j+1]][stack[j+2]];
          4: result:=CurInter.IntStatVar.ast[i][stack[j]][stack[j+1]][stack[j+2]][stack[j+3]];
          5: result:=CurInter.IntStatVar.ast[i][stack[j]][stack[j+1]][stack[j+2]][stack[j+3]][stack[j+4]];
        end;
      end
      else
        case cntind of
          1: result:=avp[CurInter.nvp,1,i][stack[j]];
          2: result:=avp[CurInter.nvp,1,i][stack[j]][stack[j+1]];
          3: result:=avp[CurInter.nvp,1,i][stack[j]][stack[j+1]][stack[j+2]];
          4: result:=avp[CurInter.nvp,1,i][stack[j]][stack[j+1]][stack[j+2]][stack[j+3]];
          5: result:=avp[CurInter.nvp,1,i][stack[j]][stack[j+1]][stack[j+2]][stack[j+3]][stack[j+4]];
        end;
      {$IFDEF STACKALL}DelStack;{$ENDIF}
    end;
    function arwrite(const z: variant): variant;
    var cntind,j:longint; v1,v2,v3,v4:variant;
    begin
      {$IFDEF STACKALL}AddStack('TInter.CompileEval.Evalcom.arwrite');{$ENDIF}
      cntind:=stack[ist]; //кол-во индексов
      j:=stack[ist-1-cntind];
      if j>MAXLVAR1 then begin
        Dec(j,MAXLVAR1+1);
        case cntind of
          1:begin
            CurInter.IntStatVar.ast[j][longint(stack[ist-1])]:=z;
          end;
          2:begin
            v1:=CurInter.IntStatVar.ast[j][longint(stack[ist-2])];
            v1[longint(stack[ist-1])]:=z;
            CurInter.IntStatVar.ast[j][longint(stack[ist-2])]:=v1;
          end;
          3:begin
            v1:=CurInter.IntStatVar.ast[j][longint(stack[ist-3])];
            v2:=v1[longint(stack[ist-2])];
            v2[longint(stack[ist-1])]:=z;
            v1[longint(stack[ist-2])]:=v2;
            CurInter.IntStatVar.ast[j][longint(stack[ist-3])]:=v1;
          end;
          4:begin
            v1:=CurInter.IntStatVar.ast[j][longint(stack[ist-4])];
            v2:=v1[longint(stack[ist-3])];
            v3:=v2[longint(stack[ist-2])];
            v3[longint(stack[ist-1])]:=z;
            v2[longint(stack[ist-2])]:=v3;
            v1[longint(stack[ist-3])]:=v2;
            CurInter.IntStatVar.ast[j][longint(stack[ist-4])]:=v1;
          end;
          5:begin
            v1:=CurInter.IntStatVar.ast[j][longint(stack[ist-5])];
            v2:=v1[longint(stack[ist-4])];
            v3:=v2[longint(stack[ist-3])];
            v4:=v3[longint(stack[ist-2])];
            v4[longint(stack[ist-1])]:=z;
            v3[longint(stack[ist-2])]:=v4;
            v2[longint(stack[ist-3])]:=v3;
            v1[longint(stack[ist-4])]:=v2;
            CurInter.IntStatVar.ast[j][longint(stack[ist-5])]:=v1;
          end;
        end;
      end
      else
        case cntind of
          1:begin
            avp[CurInter.nvp,1,j][longint(stack[ist-1])]:=z;
          end;
          2:begin
            v1:=avp[CurInter.nvp,1,j][longint(stack[ist-2])];
            v1[longint(stack[ist-1])]:=z;
            avp[CurInter.nvp,1,j][longint(stack[ist-2])]:=v1;
          end;
          3:begin
            v1:=avp[CurInter.nvp,1,j][longint(stack[ist-3])];
            v2:=v1[longint(stack[ist-2])];
            v2[longint(stack[ist-1])]:=z;
            v1[longint(stack[ist-2])]:=v2;
            avp[CurInter.nvp,1,j][longint(stack[ist-3])]:=v1;
          end;
          4:begin
            v1:=avp[CurInter.nvp,1,j][longint(stack[ist-4])];
            v2:=v1[longint(stack[ist-3])];
            v3:=v2[longint(stack[ist-2])];
            v3[longint(stack[ist-1])]:=z;
            v2[longint(stack[ist-2])]:=v3;
            v1[longint(stack[ist-3])]:=v2;
            avp[CurInter.nvp,1,j][longint(stack[ist-4])]:=v1;
          end;
          5:begin
            v1:=avp[CurInter.nvp,1,j][longint(stack[ist-5])];
            v2:=v1[longint(stack[ist-4])];
            v3:=v2[longint(stack[ist-3])];
            v4:=v3[longint(stack[ist-2])];
            v4[longint(stack[ist-1])]:=z;
            v3[longint(stack[ist-2])]:=v4;
            v2[longint(stack[ist-3])]:=v3;
            v1[longint(stack[ist-4])]:=v2;
            avp[CurInter.nvp,1,j][longint(stack[ist-5])]:=v1;
          end;
        end;
      {$IFDEF STACKALL}DelStack;{$ENDIF}
    end;
    function IncCorDate(const v1,v2: variant): variant;
    var t1,t2: longint;
    begin
      {$IFDEF STACKALL}AddStack('TInter.CompileEval.Evalcom.IncCorDate');{$ENDIF}
      t1:=MyVarType(v1,true); t2:=MyVarType(v2,true);
      if IsUserGG then
      	if not((t1=varString) and (t2=varString) or (t1=varArray) and (t2=varArray)
        or (t1 in [varDouble,varDate]) and (t2 in [varDouble,varDate]))
        then raise EInterAnyError.Create(
        	'Оператор "+" используется только между числами|датами, строками или между массивами');
        if (t1=varDate) and (t2=varDate) then raise EInterAnyError.Create(
        	'Оператор "+" нельзя использовать между двумя датами');
      result:=v1+v2;
      if (t1=varDate) or (t2=varDate) then TDateTimeSelf(result);
      {$IFDEF STACKALL}DelStack;{$ENDIF}
    end;
    function DecCorDate(const v1,v2: variant): variant;
    var t1,t2: longint;
    begin
      {$IFDEF STACKALL}AddStack('TInter.CompileEval.Evalcom.DecCorDate');{$ENDIF}
      t1:=MyVarType(v1,true); t2:=MyVarType(v2,true);
      if IsUserGG then
      	if not((t1 in [varDouble,varDate]) and (t2 in [varDouble,varDate]))
        then raise EInterAnyError.Create('Оператор "-" используется только между числами|датами');
      if (t1=varDate) and (t2=varDate) then result:=TDateTime(v1)-TDateTime(v2)
      else begin
        result:=v1-v2;
        if (t1=varDate) or (t2=varDate) then TDateTimeSelf(result);
      end;
      {$IFDEF STACKALL}DelStack;{$ENDIF}
    end;
    function Arr1(n: longint): variant;
    var i: longint;
    begin
      {$IFDEF STACKALL}AddStack('TInter.CompileEval.Evalcom.Arr1');{$ENDIF}
      if empty(stack[n]) then result:=false
      else begin
        result:=varArrayCreate([1,stack[n]],varVariant);
        for i:=1 to stack[n] do
          if stack[n+1]=null then result[i]:=null else result[i]:=Arr1(n+1);
      end;
      {$IFDEF STACKALL}DelStack;{$ENDIF}
    end;
  var n1: longint;
    function sChr(n: byte): PChar;
    begin
      AddStack('TInter.CompileEval.Evalcom.sChr');
      if IsNil(stack[n1+n]) then result:=nil else result:=PChar(string(stack[n1+n]));
      DelStack;
    end;
    function Algm(const v: variant): TAlignment;
    begin
      {$IFDEF STACKALL}AddStack('TInter.CompileEval.Evalcom.Algm');{$ENDIF}
      if MyVarType(v)=V_BOOL then result:=iif(v,taRightJustify,taLeftJustify) else result:=taCenter;
      {$IFDEF STACKALL}DelStack;{$ENDIF}
    end;
    procedure CompVarChk;
    var fl: boolean;
    begin
      {$IFDEF STACKALL}AddStack('TInter.CompileEval.Evalcom.CompVarChk');{$ENDIF}
      stack[ist]:=CompVar(stack[ist],stack[ist+1],@fl);
      if not fl then ProcError('Проверка равенства недопустима между значениями разных типов',[]);
      {$IFDEF STACKALL}DelStack;{$ENDIF}
    end;
  var n2,n3,t1,t2,l: longint;
    bi: TBuiltInList;
    procedure AScan;
    var i,j,h: longint;
      v: variant;
      fl,fl1: boolean;
    begin
      {$IFDEF STACKALL}AddStack('TInter.CompileEval.Evalcom.AScan');{$ENDIF}
      j:=1; h:=VarArrayHighBound(stack[n1],1);
      if t1=V_STRING then begin
        while j<=h do begin
          v:=InterProcStat([stack[n3],stack[n1][j],stack[n2]],'Выполнение функции '+aBuiltIn[bi].name+'()');
          if MyVarType(v)=V_BOOL then
            if v then begin
              stack[n1]:=j; break;
            end;
          Inc(j);
        end;
      end
      else begin
        Bool2IntSelf(stack[n3],1,2);
        if stack[n3]=3 then begin
          t1:=0; t2:=h-1; j:=h+1;
          if MyVarType(stack[n1][1])=varArray then begin
            v:=stack[n2];
            if MyVarType(v)=varArray then v:=v[1]; // Для МАС_ДОБАВИТЬ поиск 1-го элемента
            while t1<=t2 do begin
              i := (t1+t2) shr 1;
              if stack[n1][i+1][1]<v then t1:=i+1
              else if stack[n1][i+1][1]>v then t2:=i-1
              else begin
                j:=i+1; stack[n1]:=j; break;
              end;
            end;
          end
          else while t1<=t2 do begin
            i := (t1+t2) shr 1;
            if stack[n1][i+1]<stack[n2] then t1:=i+1
            else if stack[n1][i+1]>stack[n2] then t2:=i-1
            else begin
              j:=i+1; stack[n1]:=j; break;
            end;
          end;
        end
        else begin
          fl1 := (stack[n3]>0) and (MyVarType(stack[n2])=varString);
          while j<=h do begin
            fl:=CompVar(stack[n1][j],stack[n2]);
            if not fl and fl1 and (MyVarType(stack[n1][j])=varString) then
              if stack[n3]=2
              then fl:=AnsiStartsStr(stack[n1][j],stack[n2])
              else fl:=AnsiStartsStr(stack[n2],stack[n1][j]);
            if fl then begin
              stack[n1]:=j; break;
            end;
            Inc(j);
          end;
        end;
      end;
      if j>h then stack[n1]:=0;
      {$IFDEF STACKALL}DelStack;{$ENDIF}
    end;
  var b: byte;
    function MulDiv(const ope: string; O_MUL,O_DIV,O_DIV0: byte; v1,v2: Extended): Extended;
    begin
      {$IFDEF STACKALL}AddStack('TInter.CompileEval.Evalcom.MulDiv');{$ENDIF}
      if IsUserGG then
        if not((MyVarType(v1,true)=varDouble) and (MyVarType(v2,true)=varDouble))
        then raise EInterAnyError.Create('Оператор "'+IfThen(b=O_MUL,'*',IfThen(b=O_DIV,'/',':'))
          +ope+'" используется только между числами');
      if b=O_MUL
        then result:=v1*v2
      else if empty(v1) or (b=O_DIV0) and empty(v2)
        then result:=0
      else result:=DivChk(v1,v2);
      {$IFDEF STACKALL}DelStack;{$ENDIF}
    end;
    procedure Rnd(t,nv: longint);
    var t2: longint;
    begin
      {$IFDEF STACKALL}AddStack('TInter.CompileEval.Evalcom.Rnd');{$ENDIF}
      if IsNilc(stack[nv],false) then begin
        t2:=trunc(IntPower(10,t)); stack[n1]:=mround(Ceil(mround(stack[n1]*t2,FloatMaxDec))/t2,t);
      end
      else MroundSelf(stack[n1],t);
      {$IFDEF STACKALL}DelStack;{$ENDIF}
    end;
  const aAsk: array[1..3] of longint = (mrYes,mrNo,mrCancel);

    encdtY   = 1;
    encdtM   = 2;
    encdtD   = 3;
    encdtH   = 4;
    encdtN   = 5;
    encdtS   = 6;
    encdtZ   = 7;

    encdtCnt = 7;
    encdtPer: array[encdtH..encdtCnt] of Word = (HoursPerDay,MinsPerHour,SecsPerMin,MSecsPerSec);
  var i,j,j1,h,n4,lcom:longint;
    v: variant;
    i64: Int64;
    a1,a2: TArrStr;
    av: TArrVar;
  	fl,fl1: boolean;
    fr:funcrec;
    s,s1,s2,s3: string;
  	tr:transf;
    dy,dm,dd,dh,dn,ds,dz: Word;
    alg: TAlignment;
    stRus: TBoolSet;
    PrmNum: TFmtNum;
    arsp: TArrArrVar;
    ares,asum: TArrDbl;
    prior: TArrInt;
    oInter: TInter;
    prcmp: TSortComp;
    aprm: TInterPrmArrVar;
    hl: THelpLinkList;
    ht: THelpTbl;
    tl: TKeyLb;
    doswin: TDosWinOpt;
{$IFDEF PROFINTER}
    oEvalName: string;
{$ENDIF}
    ovf: TInterCurVF;
    sx: TSexList0;
    dt: TDateTime;
  begin
    {$IFDEF STACKALL}AddStack('TInter.CompileEval.Evalcom');{$ENDIF}
    ist:=0; ind:=3; lcom:=length(com);
    while ind<=lcom do begin
{if ind=9714 then begin
ind:=ind;
end;}
      b:=ord(com[ind]); inc(ind); //fl:=true;
      //if Assigned(ProcInterEvalOper) then ProcInterEvalOper(b,{com,ind,}stack,ist,fl);
      {if fl then} case b of
        O_PLUS:begin
          dec(ist); stack[ist]:=IncCorDate(stack[ist],stack[ist+1]);
        end;
        O_SUB:begin
          dec(ist); stack[ist]:=DecCorDate(stack[ist],stack[ist+1]);
        end;
        O_MUL,O_DIV,O_DIV0:begin
          dec(ist); stack[ist]:=MulDiv('',O_MUL,O_DIV,O_DIV0,stack[ist],stack[ist+1]);
        end;
        O_S,O_SE,O_L,O_LE:begin
          dec(ist); t1:=MyVarType(stack[ist],true); t2:=MyVarType(stack[ist+1],true);
          if IsUserGG then begin
            if not((t1=varString) and (t2=varString)
            or (t1 in [varDouble,varDate]) and (t2 in [varDouble,varDate]))
            then raise EInterAnyError.Create(
              'Оператор "'+IfThen(b=O_S,'<',IfThen(b=O_SE,'<=',IfThen(b=O_L,'>','>=')))
              +'" используется только между числами|датами или между строками');
          end;
          if t1=varDouble then MroundSelf(stack[ist],FloatMaxDec);
          if t2=varDouble then MroundSelf(stack[ist+1],FloatMaxDec);
          case b of
            O_S:  stack[ist] := stack[ist]<stack[ist+1];
            O_SE: stack[ist] := stack[ist]<=stack[ist+1];
            O_L:  stack[ist] := stack[ist]>stack[ist+1];
            O_LE: stack[ist] := stack[ist]>=stack[ist+1];
          end;
        end;
        O_E:begin
          dec(ist);
          if (MyVarType(stack[ist])=varString) and (MyVarType(stack[ist+1])=varString)
          then stack[ist]:=AnsiStartsStr(stack[ist+1],stack[ist])
          else CompVarChk;
        end;
        O_NE:begin
          dec(ist); CompVarChk; NotD(stack[ist]);
        end;
        O_EP:begin
          dec(ist); CompVarChk;
        end;
        O_AND,O_OR:begin
          dec(ist);
          if IsUserGG then begin
	          t1:=MyVarType(stack[ist],true); t2:=MyVarType(stack[ist+1],true);
            if not((t1=varBoolean) and (t2=varBoolean) or (t1=varDouble) and (t2=varDouble))
            then raise EInterAnyError.Create('Оператор "'+IfThen(b=O_AND,'И','ИЛИ')
              +'" используется только между числами|датами или между логическими');
          end;
          if b=O_AND
          then stack[ist] := (stack[ist] and stack[ist+1])
          else stack[ist] := (stack[ist] or  stack[ist+1]);
        end;
        O_MIN,O_UPLUS:begin
          if IsUserGG then
            if MyVarType(stack[ist],true)<>varDouble
            then raise EInterAnyError.Create('Оператор "'+IfThen(b=O_MIN,'-','+')
              +'" используется только перед числами');
          if b=O_MIN then stack[ist]:=-stack[ist];
        end;
        O_NO:begin
          if IsUserGG then
            if MyVarType(stack[ist])<>varBoolean
            then raise EInterAnyError.Create('Оператор "!" используется только перед логическими');
          NotD(stack[ist]);
        end;
        O_PLUSPLUS: VarProcSelf(IncCorDate(VarProc(stack[ist],null,false),1),true);
        O_MINMIN: VarProcSelf(DecCorDate(VarProc(stack[ist],null,false),1),true);
        O_TR:begin
          i:=stack[ist]; Dec(ist); stack[ist]:=VarProc(i,stack[ist],true);
        end;
        O_TRPLUS:begin
          i:=stack[ist]; Dec(ist);
          stack[ist]:=VarProc(i,IncCorDate(VarProc(i,null,false),stack[ist]),true);
        end;
        O_TRMIN:begin
          i:=stack[ist]; Dec(ist);
          stack[ist]:=VarProc(i,DecCorDate(VarProc(i,null,false),stack[ist]),true);
        end;
        O_TRMUL,O_TRDIV,O_TRDIV0:begin
          i:=stack[ist]; Dec(ist);
          stack[ist]:=VarProc(i,MulDiv('=>',O_TRMUL,O_TRDIV,O_TRDIV0,VarProc(i,null,false),stack[ist]),true)
        end;
        O_PLUSPLUSA:begin
          v:=IncCorDate(arread,1); arwrite(v); Dec(ist,longint(stack[ist])+1); stack[ist]:=v;
        end;
        O_MINMINA:begin
          v:=DecCorDate(arread,1); arwrite(v); Dec(ist,longint(stack[ist])+1); stack[ist]:=v; 
        end;
        O_TRA:begin
          i:=ist-stack[ist]-2; arwrite(stack[i]); ist:=i;
        end;
        O_TRPLUSA:begin
          i:=ist-stack[ist]-2; arwrite(IncCorDate(arread,stack[i])); ist:=i; 
        end;
        O_TRMINA:begin
          i:=ist-stack[ist]-2; arwrite(DecCorDate(arread,stack[i])); ist:=i;
        end;
        O_TRMULA,O_TRDIVA,O_TRDIVA0:begin
          i:=ist-stack[ist]-2;
          v:=MulDiv('=>',O_TRMULA,O_TRDIVA,O_TRDIVA0,arread,stack[i]);
          arwrite(v); stack[i]:=v; ist:=i;
        end;
        O_BACK: begin
          dec(ist); stack[ist]:=stack[ist+1];
        end;
        O_NULL: begin
          inc(ist); stack[ist]:=null;
        end;
        O_INT: begin
          inc(ist);
          for i:=1 to 4 do tr.s[i]:=com[ind+i-1];
          stack[ist]:=tr.i; Inc(ind,4);
        end;
        O_FLOAT: begin
          inc(ist);
          for i:=1 to 8 do tr.s[i]:=com[ind+i-1];
          stack[ist]:=tr.f; Inc(ind,8);
        end;
        O_DATE: begin
          inc(ist);
          for i:=1 to 8 do tr.s[i]:=com[ind+i-1];
          stack[ist]:=Tdatetime(tr.f); Inc(ind,8);
        end;
        O_BOOL:begin
          inc(ist);
          tr.s[1]:=com[ind]; stack[ist]:=tr.b; Inc(ind);
        end;
        O_STRING:begin
          inc(ist);
          for i:=1 to 4 do tr.s[i]:=com[ind+i-1];
          Inc(ind,4); stack[ist]:=copy(com,ind,tr.i); Inc(ind,tr.i);
        end;
        O_GETVAR: VarProcSelf(null,false);
        O_DOWN: dec(ist);
        O_FUNC:begin
          ovf:=SetCurVF(modeFunc,stack[ist]);
          try
            fr:=afunc[cur_vf]; Dec(ist,Length(fr.aPrm));
            if fr.name=FuncProfRename then begin
{$IFDEF PROFINTER}
              i64:=My_pr.GetTickCount; oEvalName:=CurEvalName; ProfAddTime(@oEvalName,oEvalName,i64,true);
              i64:=My_pr.GetTickCount; CurEvalName:=stack[ist]; ProfAddTime(@oEvalName,CurEvalName,i64,false);
{$ENDIF}
              stack[ist]:=null;
            end
            else begin
              aprm[0]:=fr.index;
              for l:=1 to Length(fr.aPrm) do aprm[l]:=stack[ist+l-1];
{$IFDEF PROFINTER}
              InterProfBeg(fr.name+'()',oEvalName);
              try
{$ENDIF}
                if IsUserGG then
                  for l:=1 to Length(fr.aPrm) do
                    if not TypesChk(fr.aPrm[l-1,2],aprm[l]) then ProcError(
                      'Параметр %d должен%s',[l,TypesMsg(fr.aPrm[l-1,2])]);
                stack[ist]:=fr.proc(aprm);
{$IFDEF PROFINTER}
              finally
                InterProfEnd(oEvalName);
              end;
{$ENDIF}
            end;
          finally
            SetCurVF(ovf);
          end;
        end;
        O_GOTO: if nline<MaxNline then nline:=stack[ist];
        O_IGOTO:begin
          dec(ist);
          if IsUserGG then
            if MyVarType(stack[ist])<>V_BOOL
            then raise EInterAnyError.Create(
              'Условие для операторов '+sIF+' и '+sWHILE+' должно возвращать логическое значение');
          if not stack[ist] and (nline<MaxNline) then nline:=stack[ist+1];
          stack[ist]:=Unassigned;
        end;
        O_RETURN:begin
          stack[1]:=stack[ist]; nline:=MaxNline; break;
        end;
        O_GETVARA:begin
          i:=ist-stack[ist]-1; stack[i]:=arread; ist:=i;
        end;
        O_ARRAY:begin
          l:=stack[ist]; Dec(ist,l); v:=stack[ist]; stack[ist]:=VarArrayCreate([1,l],VarVariant);
          for i:=l downto 2 do stack[ist][i]:=stack[ist+i-1];
          stack[ist][1]:=v;
        end;
        O_FUNCBI:begin
          bi:=stack[ist]; ovf:=SetCurVF(modeBuiltIn,longint(bi));
          try
            with aBuiltIn[bi],aBuiltInProc[bi] do begin
              n1:=ist-Length(aPrmPrim);
              if IsUserGG then
                for j:=low(aPrmType) to high(aPrmType) do
                  if not TypesChk(aPrmType[j],stack[n1+j])
                  then ProcError('Параметр %d должен%s',[j+1,TypesMsg(aPrmType[j])]);
{$IFDEF PROFINTER}
              InterProfBeg(name+'()',oEvalName);
{$ENDIF}
{$IFDEF PROFINTER}
              try
{$ENDIF}
                fl:=not Assigned(Proc);
                if not fl then Proc(stack,n1,fl);
                if fl then case bi of
                  biReplicate: if Length(stack[n1])=1
                    then stack[n1]:=StringOfChar(StrToChar(stack[n1]),longint(stack[n1+1]))
                    else stack[n1]:=DupeString(stack[n1],stack[n1+1]);
                  biEmpty: stack[n1]:=empty(stack[n1]);
                  biMRound: Rnd(IsNilc(stack[n1+1],0),n1+2);
                  biPrc: begin
                    stack[n1]:=stack[n1]*stack[n1+1]/100; n3:=n1+2;
                    if not IsNil(stack[n3]) then Rnd(stack[n3],n1+3);
                  end;
                  biVarType:
                    case MyVarType(stack[n1],IsNilc(stack[n1+1],false)) of
                      varInteger: stack[n1]:=V_INT;
                      varDouble: stack[n1]:=V_FLOAT;
                      varDate: stack[n1]:=V_DATE;
                      varBoolean: stack[n1]:=V_BOOL;
                      varString: stack[n1]:=V_STRING;
                      varArray: stack[n1]:=varArray;
                    else stack[n1]:=V_NULL;
                    end;
                  biSetByte: begin
                    n3:=n1+2;
                    if MyVarType(stack[n1])=V_STRING then begin
                      s1:=stack[n1]; stack[n1]:=SetByte(s1,IsNilc(stack[n1+3],1),stack[n1+1],stack[n3]);
                      if not IsNil(stack[n3]) then stack[n1]:=s1;
                    end
                    else begin
                      n2:=(1 shl (stack[n1+1]-1));
                      if IsNil(stack[n3])
                      then stack[n1] := (longword(stack[n1]) and longword(n2)) > 0
                      else stack[n1] := longword(stack[n1]) or longword(n2);
                    end;
                  end;
                  biGetByteArr: begin
                    s:=stack[n1]; n2:=n1+1; n3:=n1+2;
                    if MyVarType(stack[n3],true)=V_FLOAT then begin
                      stack[n1]:=VarArrayCreate([1,stack[n2]],varVariant);
                      v:=VarArrayCreate([1,stack[n3]],varVariant);
                      for i:=1 to stack[n2] do begin
                        for j:=1 to stack[n3] do v[j]:=GetByte(s,i,j);
                        stack[n1][i]:=v;
                      end;
                    end
                    else if MyVarType(stack[n2],true)=V_FLOAT then begin
                      TrimRightSelf(s); i:=Length(s); n2:=stack[n2]-1;
                      VarArrLenInit(stack[n1],j,i);
                      for i:=1 to i do if GetByte(s,i) then begin
                        Inc(j); stack[n1][j]:=n2+i;
                      end;
                      VarArrLenSet(stack[n1],j);
                    end
                    else begin
                      i:=Length(s);
                      if i=0 then stack[n1]:=false
                      else begin
                        stack[n1]:=VarArrayCreate([1,i],varVariant);
                        for i:=1 to i do stack[n1][i]:=GetByte(s,i);
                      end;
                    end;
                  end;
                  biTrimLeft: stack[n1]:=TrimLeft(stack[n1]);
                  biTrimRight: TrimRightSelf(stack[n1]);
                  biTrim: TrimSelf(stack[n1]);
                  biStrFind: begin
                    n2:=n1+1; t1:=MyVarType(stack[n2]);
                    n3:=n2+1; t2:=MyVarType(stack[n3]);
                    if (t2=V_NULL) and (t1<>varArray) then stack[n1]:=Pos(stack[n2],stack[n1])
                    else if not((t1=varBoolean) or (t2=varBoolean)) then
                      if t1=varString then StrTranSelf(stack[n1],stack[n2],stack[n3])
                      else begin
                        l:=VarArrayLowBound(stack[n2],1);
                        if MyVarType(stack[n2][l])=varArray then begin
                          h:=VarArrayHighBound(stack[n2],1);
                          SetLength(a1,h-l+1); SetLength(a2,Length(a1));
                          j:=low(a1);
                          for j1:=l to h do begin
                            a1[j]:=stack[n2][j1][1]; a2[j]:=stack[n2][j1][2]; Inc(j);
                          end;
                        end
                        else begin
                          CopyFromVar(a1,stack[n2]); CopyFromVar(a2,stack[n3]);
                        end;
                        StrTranSelf(stack[n1],a1,a2);
                      end;
                  end;
                  biFloat0: Float0Self(stack[n1]);
                  biIif: stack[n1]:=iif(stack[n1],stack[n1+1],stack[n1+2]);
                  biStrMask: begin
                    s1:=stack[n1]; s2:=stack[n1+1];
                    if not IsNil(stack[n1+2]) then begin
                      s3:=stack[n1+2];
                      t1:=LsArrDynamic(s1,a1,s3)-1;
                      t2:=LsArrDynamic(s2,a2,s3)-1;
                      for j:=0 to t2 do begin
                        s:=Trim(a2[j]);
                        if StrToChar(s) in ['*',UnDelim] then begin
                          Delete(s,1,1);
                          if empty(s) then s:=IntToStr(j+1);
                          l:=Int0(s)-1;
                          if InRange(l,0,t1) then a2[j]:=a1[l];
                        end;
                      end;
                      s2:=ArrayAsList(a2,s3,t2+1);
                    end;
                    l:=min(Length(s1),Length(s2));
                    for j:=1 to l do
                      if s2[j]='?' then s2[j]:=s1[j];
                    stack[n1]:=s2;
                  end;
                  biLen: case MyVarType(stack[n1]) of
                    varString: stack[n1]:=Length(stack[n1]);
                    varArray: stack[n1]:=VarArrayHighBound(stack[n1],1);
                  else stack[n1]:=0;
                  end;
                  biArray: stack[n1]:=Arr1(n1);
                  biAIns,biAAdd: begin
                    n2:=n1+1; n3:=n2+1;
                    if bi=biAIns then
                      if empty(stack[n2]) then begin
                        stack[n2]:=stack[n3]; stack[n3]:=null; bi:=biAAdd;
                      end;
                    if bi=biAIns then begin
                      l:=VarArrayHighBound(stack[n1],1); VarArrayRedim(stack[n1],l+1); j:=stack[n2];
                      while l>=j do begin
                        stack[n1][l+1]:=stack[n1][l]; dec(l);
                      end;
                      stack[n1][j]:=stack[n3];
                    end
                    else if MyVarType(stack[n1])=varArray then begin
                      t1:=MyVarType(stack[n3]); t2:=-2; l:=VarArrayHighBound(stack[n1],1); nAAdd:=l+1;
                      if t1=V_NULL then fl:=true
                      else begin
                        v:=stack[n1]; AScan; fl := stack[n1]=0;
                        if not fl then nAAdd:=stack[n1];
                        stack[n1]:=v;
                      end;
                      if fl then begin
                        VarArrayRedim(stack[n1],l+1);
                        if (t2=-2) or (t1=l) then stack[n1][l+1]:=stack[n2]
                        else begin
                          nAAdd:=t1+1;
                          while l>=nAAdd do begin
                            stack[n1][l+1]:=stack[n1][l]; dec(l);
                          end;
                          stack[n1][nAAdd]:=stack[n2];
                        end;
                      end
                      else stack[n1][nAAdd]:=stack[n2];
                    end
                    else stack[n1]:=ArrVarToVar([stack[n2]]);
                  end;
                  biADel: begin
                    l:=VarArrayHighBound(stack[n1],1);
                    for j:=stack[n1+1] to l-1 do stack[n1][j]:=stack[n1][j+1];
                    if l>VarArrayLowBound(stack[n1],1) then VarArrayRedim(stack[n1],l-1) else stack[n1]:=false;
                  end;
                  biAScan:
                    if MyVarType(stack[n1])=varArray then begin
                      n2:=n1+1; n3:=n2+1; t1:=MyVarType(IsNil(stack[n3],0)); AScan;
                    end
                    else stack[n1]:=0;
                  biAddArr: begin
                    h:=0;
                    for j:=n1 to ist-1 do if MyVarType(stack[j])=varArray then Inc(h,VarLength(stack[j]));
                    if h=0 then stack[n1]:=false
                    else begin
                      if MyVarType(stack[n1])=varArray then begin
                        l:=VarArrayHighBound(stack[n1],1); VarArrayRedim(stack[n1],h);
                      end
                      else begin
                        l:=0; stack[n1]:=VarArrayCreate([1,h],varVariant);
                      end;
                      for j:=n1+1 to ist-1 do if MyVarType(stack[j])=varArray then
                        for j1:=VarArrayLowBound(stack[j],1) to VarArrayHighBound(stack[j],1) do begin
                          Inc(l); stack[n1][l]:=stack[j][j1];
                        end;
                    end;
                  end;
                  biAddEnd: VAddEndSelf(stack[n1],stack[n1+1],
                    IsNilc(stack[n1+2],iif(IsNilc(stack[n1+3],true),'',null)));
                  biAFill: begin
                    if MyVarType(stack[n1],true)=varDouble
                    then stack[n1]:=VarArrayCreate([1,stack[n1]],varVariant);
                    if MyVarType(stack[n1])=varArray then begin
                      n2:=n1+1;
                      l:=IsNilc(stack[n1+2],VarArrayLowBound(stack[n1],1));
                      h:=l+IsNilc(stack[n1+3],VarArrayHighBound(stack[n1],1)-l+1)-1;
                      for j:=l to h do stack[n1][j]:=stack[n2];
                    end;
                  end;
                  biARaspr: if MyVarType(stack[n1])=varArray then begin
                    l:=VarArrayLowBound(stack[n1],1); h:=VarArrayHighBound(stack[n1],1);
                    n3:=n1+2; i:=MyVarType(stack[n3],true);
                    if i=V_FLOAT then begin
                      SetLength(ares,h-l+1); j:=low(ares);
                      for j1:=l to h do begin
                        ares[j]:=stack[n1][j1]; Inc(j);
                      end;
                      RasprOst(ares,stack[n1+1],stack[n3],
                        IfThen(not IsNilc(stack[n1+3],false),rspoNoOptim)
                        +IfThen(IsNilc(stack[n1+4],false),rspoSign));
                      j:=low(ares); stack[n1]:=VarArrayCreate([l,h],varVariant);
                      for j1:=l to h do begin
                        stack[n1][j1]:=ares[j]; Inc(j);
                      end;
                    end
                    else if i=varArray then
                      if MyVarType(stack[n1][l])=varArray then begin
                        i:=h-l+1; SetLength(arsp,i); SetLength(asum,i);
                        t1:=VarArrayLowBound(stack[n1][l],1); t2:=VarArrayHighBound(stack[n1][l],1);
                        i:=t2-t1+1; SetLength(prior,i); ZeroMemory(@prior[0],i*SizeOf(prior[0]));
                        j:=low(asum);
                        for n2:=l to h do begin
                          SetLength(arsp[j],i); j1:=low(prior);
                          for n4:=t1 to t2 do begin
                            arsp[j,j1]:=stack[n1][n2][n4]; Inc(j1);
                          end;
                          asum[j]:=stack[n3][n2]; Inc(j);
                        end;
                        n4:=n1+3;
                        if MyVarType(stack[n4])=varArray then begin
                          j:=low(prior);
                          for n2:=t1 to t2 do begin
                            if not IsNil(stack[n4][n2]) then prior[j]:=stack[n4][n2];
                            Inc(j);
                          end;
                        end;
                        ares:=RasprOst(arsp,stack[n1+1],asum,prior);
                        stack[n1]:=VarArrayCreate([t1,t2],varVariant); j:=low(prior);
                        for n2:=t1 to t2 do begin
                          stack[n1][n2]:=ares[j]; Inc(j);
                        end;
                      end
                      else stack[n1]:=false;
                  end;
                  biAIf: stack[n1]:=IfThen(stack[n1],stack[n1+1],stack[n1+2],stack[n1+3]);
                  biASort: if MyVarType(stack[n1])=varArray then begin
                    h:=VarArrayHighBound(stack[n1],1);
                    if h>1 then begin
                      oInter:=CurInter; n2:=n1+1;
                      if MyVarType(IsNil(stack[n2],true))=varBoolean then begin
                        CurInter:=nil;
                        if MyVarType(stack[n1][1])=varArray
                        then if stack[n2] then prcmp:=SortAAscending else prcmp:=SortADescending
                        else if stack[n2] then prcmp:=SortAscending else prcmp:=SortDescending;
                      end
                      else CurInter:=TInter.Create('');
                      try
                        if Assigned(CurInter) then with CurInter do begin
                          Assign(oInter); name:='Формула выполнения процесса функцией МАС_СОРТ()';
                          showerror:=true; value_types:='N';
                          aprm[0]:=stack[n2];
                          for j:=3 to high(aprm) do aprm[j]:=stack[n1+j-1];
                          prcmp:=SortEval; AddFromSelf(v,VarArrayOf([longint(@aprm)]));
                        end;
                        v:=VarArrayOf([longint(@prcmp),longint(@stack),n1,longint(@aprm)]);
                        QuickSort(SortProc,@v,1,h);
                      finally
                        CurInter.Free; CurInter:=oInter;
                      end;
                    end;
                  end;
                  biASub: stack[n1]:=VSubArr(stack[n1],IsNilc(stack[n1+1],1),IsNilc(stack[n1+2],MaxInt),IsNilc(stack[n1+3],false));
                  biAVal: stack[n1]:=stack[n1][stack[n1+1]];
                  biADef: ArrVarDef(stack[n1]);
                  biListAsArray: begin
                    j:=LsArrDynamic(stack[n1],a1,IsNilc(stack[n1+1],','),IfThen(IsNilc(stack[n1+2],true),lsaEnd));
                    if j>0 then begin
                      stack[n1]:=VarArrayCreate([1,j],varVariant); n4:=n1+3; IsNil(stack[n4],false);
                      for j:=1 to j do if stack[n4] then stack[n1][j]:=Float0(a1[j-1]) else stack[n1][j]:=a1[j-1];
                    end
                    else stack[n1]:=false;
                  end;
                  biArrayAsList: begin
                    if MyVarType(stack[n1])=varArray then CopyFromVar(a1,stack[n1]) else a1:=nil;
                    stack[n1]:=ArrayAsList(a1,IsNilc(stack[n1+1],','),NegDef,IsNilc(stack[n1+2],true));
                  end;
                  biCopy: begin
                    j:=IsNilc(stack[n1+1],1); l:=IsNilc(stack[n1+2],MaxInt);
                    if IsNilc(stack[n1+3],false)
                      then SubStrSelf(stack[n1],j,l)
                    else if l>0
                      then CopySelf(stack[n1],j,l)
                    else stack[n1]:='';
                  end;
                  biZpp: stack[n1]:=zpp(stack[n1],stack[n1+1]);
                  biZppl: stack[n1]:=zppl(stack[n1],stack[n1+1]);
                  biZppr: stack[n1]:=zppr(stack[n1],stack[n1+1]);
                  biZppc: stack[n1]:=zppc(stack[n1],stack[n1+1]);
                  biUpper: AnsiUpperCaseSelf(stack[n1]);
                  biFrup: FRupSelf(stack[n1]);
                  biLower: stack[n1]:=AnsiLowerCase(stack[n1]);
                  biDelTrim: DelTrimSelf(stack[n1],IsNilc(stack[n1+1],''));
                  biPadl: PadLSelf(stack[n1],stack[n1+1],StrToChar(IsNilc(stack[n1+2],' ')));
                  biPadr: PadRSelf(stack[n1],stack[n1+1],StrToChar(IsNilc(stack[n1+2],' ')));
                  biPadc: stack[n1]:=PadC(stack[n1],stack[n1+1],StrToChar(IsNilc(stack[n1+2],' ')));
                  biStr: begin
                    n2:=n1+1; t2:=MyVarType(stack[n2]);
                    if t2=varArray then begin
                      if MyVarType(stack[n1])=V_STRING then Float0Self(stack[n1]);
                      PrmNum:=FmtNum; FmtNum(PrmNum,stack[n2]); FmtNumSelf(stack[n1],PrmNum);
                    end
                    else begin
                      n3:=n2+1;
                      if (IsNil(stack[n3],0)=0) and (t2=varNull) then begin
                        i64:=IsNilc(stack[n1],0); stack[n1]:=IntToStr(i64);
                      end
                      else begin
                        n4:=IsNilc(stack[n3+1],0);
                        if n4=0 then begin
                          Spacestr0Self(stack[n1],IsNilc(stack[n2],NegDef),stack[n3]); n4:=n3+2;
                          if not IsNil(stack[n4]) then StrTranSelf(stack[n1],DecimalSeparator,stack[n4]);
                        end
                        else begin
                          PrmNum:=FmtNum;
                          PrmNum.AllCnt:=IsNilc(stack[n2],0);
                          PrmNum.FracCnt:=IsNilc(stack[n3],0);
                          PrmNum.FracEmp:=iif(n4 in [1,2],frempNo,frempNoRight0);
                          PrmNum.FracDlm:=StrToChar(IsNilc(stack[n3+2],DecimalSeparator));
                          FmtNumSelf(stack[n1],PrmNum);
                          if n4 in [2,4] then TrimRightSelf(stack[n1]);
                        end;
                      end;
                    end;
                  end;
                  biNumStr: NumStrSelf(stack[n1],IsNilc(stack[n1+1],NegDef));
                  biSastolin: stack[n1]:=astolin(string(stack[n1]),longint(stack[n1+1]),
                    longint(IsNilc(stack[n1+2],0)),
                    IfThen(stack[n1+3],aslnAlign)+IfThen(stack[n1+4],aslnTrim));
                  biSnastolin: stack[n1]:=astolin(string(stack[n1]),longint(stack[n1+1]),
                    longint(IsNilc(stack[n1+2],0)),longint(stack[n1+3]),IfThen(stack[n1+4],aslnAlign));
                  biCenaProp: stack[n1]:=cenaprop(stack[n1],isnilc(stack[n1+1],0));
                  biWinToDos,biDosToWin: begin
                    if IsNilc(stack[n1+1],false) then doswin:=[doswinAbcOnly] else doswin:=[];
                    case bi of
                      biWinToDos: stack[n1]:=WinToDos(stack[n1],doswin);
                      biDosToWin: stack[n1]:=DosToWin(stack[n1],doswin);
                    end;
                  end;
                  biStuff: StuffStrSelf(stack[n1],stack[n1+1],stack[n1+2],stack[n1+3]);
                  biOrd: stack[n1]:=Ord(StrToChar(stack[n1]));
                  biChr: begin
                    if not InRange(stack[n1],low(byte),high(byte)) then raise EInterAnyError.CreateFmt(
                      'Параметр должен быть в пределах от %d до %d',[low(byte),high(byte)]);
                    stack[n1]:=Chr(byte(stack[n1]));
                  end;
                  biEqualShape: stack[n1]:=EqualShape(stack[n1],stack[n1+1]);
                  biFmtPrm: stack[n1]:=FmtPrm(stack[n1],stack[n1+1]);
                  biFmtStr: begin
                    j:=LsArrDynamic(stack[n1],a1,'$');
                    if j=0 then stack[n1]:=''
                    else begin
                      stack[n1]:=a1[0];
                      for j:=1 to j-1 do begin
                        l:=Int0(a1[j]); s1:=FmtPrm(l); l:=LenIntStr(l);
                        IncD(stack[n1],s1+Copy(StuffString(a1[j],1,l,Space(l)),Length(s1),MaxInt));
                      end;
                    end;
                  end;
                  biDlmBetween:
                    if MyVarType(stack[n1])=varArray then begin
                      h:=VarArrayHighBound(stack[n1],1); SetLength(a1,h); j:=low(a1);
                      for j1:=VarArrayLowBound(stack[n1],1) to h do begin
                        a1[j]:=IsNilc(stack[n1][j1],''); Inc(j);
                      end;
                      stack[n1]:=DlmBetween(a1,stack[n1+1],IsNilc(stack[n1+2],true));
                    end
                    else stack[n1]:=DlmBetween(IsNilc(stack[n1],''),IsNilc(stack[n1+1],''),stack[n1+2],
                      IsNilc(stack[n1+3],true));
                  biDlmCopy: begin
                    i:=IsNilc(stack[n1+1],1); fl:=IsNilc(stack[n1+4],false);
                    if not fl and (i<=0) then raise EInterAnyError.Create(
                      '2-й параметр должен быть больше 0');
                    DlmCopySelf(stack[n1],i,IsNilc(stack[n1+2],MaxInt),IsNilc(stack[n1+3],','),fl);
                  end;
                  biDigRoman: stack[n1]:=DigRoman(stack[n1]);
                  biTrimMemoStr: stack[n1]:=TrimMemoStr(stack[n1],stack[n1+1],stack[n1+2]);
                  biIntToHex: begin
                    n2:=stack[n1+1];
                    case MyVarType(stack[n1]) of
                      varDouble: stack[n1]:=IntToHex(Int64(trunc(stack[n1])),n2);
                      varString: stack[n1]:=IntToHex(Int064(stack[n1]),n2);
                    else
                      i64:=stack[n1]; stack[n1]:=IntToHex(i64,n2);
                    end;
                  end;
                  biTrunc: begin
                    i64:=trunc(mround(stack[n1],FloatMaxDec));
                    if InRange(i64,-MaxInt,MaxInt) then stack[n1]:=longint(i64) else stack[n1]:=i64;
                  end;
                  biMax: begin
                    t1:=MyVarType(stack[n1]);
                    case t1 of
                      varBoolean: stack[n1]:=0;
                      varArray: begin
                        v:=VarArrayLowBound(stack[n1],1);
                        for t1:=v+1 to VarArrayHighBound(stack[n1],1) do
                          if stack[n1][t1]>stack[n1][v] then v:=t1;
                        stack[n1]:=v;
                      end
                      else
                        n2:=n1+1; t2:=MyVarType(stack[n2]);
                        if (t1=varDate) or (t2=varDate)
                          then stack[n1]:=TDateTime(max(TDateTime(stack[n1]),TDateTime(stack[n2])))
                        else if (t1=varDouble) or (t2=varDouble)
                          then stack[n1]:=max(Extended(stack[n1]),Extended(stack[n2]))
                        else stack[n1]:=max(longint(stack[n1]),longint(stack[n2]));
                    end;
                  end;
                  biMin: begin
                    t1:=MyVarType(stack[n1]);
                    case t1 of
                      varBoolean: stack[n1]:=0;
                      varArray: begin
                        v:=VarArrayLowBound(stack[n1],1);
                        for t1:=v+1 to VarArrayHighBound(stack[n1],1) do
                          if stack[n1][t1]<stack[n1][v] then v:=t1;
                        stack[n1]:=v;
                      end
                      else
                        n2:=n1+1; t2:=MyVarType(stack[n2]);
                        if (t1=varDate) or (t2=varDate)
                          then stack[n1]:=TDateTime(min(TDateTime(stack[n1]),TDateTime(stack[n2])))
                        else if (t1=varDouble) or (t2=varDouble)
                          then stack[n1]:=min(Extended(stack[n1]),Extended(stack[n2]))
                        else stack[n1]:=min(longint(stack[n1]),longint(stack[n2]));
                    end;
                  end;
                  biAbs: stack[n1]:=Abs(stack[n1]);
                  biDiv: stack[n1] := stack[n1] div stack[n1+1];
                  biMod: stack[n1] := stack[n1] mod stack[n1+1];
                  biRandom: stack[n1]:=RandomRange(stack[n1],stack[n1+1]);
                  biEoy: eoySelf(stack[n1]);
                  biBoy: boySelf(stack[n1]);
                  biYear: stack[n1]:=year(stack[n1]);
                  biDay: stack[n1]:=Day(stack[n1]);
                  biMonth: stack[n1]:=month(stack[n1]);
                  biOurDtoc: stack[n1]:=our_dtoc(ReplDateBigEmpty(stack[n1]),IsNilc(stack[n1+1],''));
                  biDtoc: stack[n1]:=dtoc(ReplDateBigEmpty(stack[n1]),IsNilc(stack[n1+2],''),
                    IsNilc(stack[n1+1],false));
                  biEom: stack[n1]:=eom(stack[n1]);
                  biBom: bomSelf(stack[n1]);
                  biOurMtoc: if MyVarType(stack[n1+1])=V_BOOL
                    then stack[n1]:=our_mtoc(ReplDateBigEmpty(stack[n1]),IfThen(stack[n1+1],2,1),true)
                    else stack[n1]:=our_mtoc(ReplDateBigEmpty(stack[n1]));
                  biPerNToMes: stack[n1]:=perntomes(stack[n1],stack[n1+1]);
                  biIncMonth:
                    try
                      IncMonthSelf(stack[n1],IsNilc(stack[n1+1],1));
                    except
                      on EConvertError do stack[n1]:=DateEmpty;
                    end;
                  biCtod: case MyVarType(stack[n1],true) of
                    V_FLOAT: TDateTimeSelf(stack[n1]);
                    varArray: begin
                      VAddEndSelf(stack[n1],encdtCnt);
                      for i:=1 to encdtCnt do IsNil(stack[n1],0);
                      for i:=high(encdtPer) downto low(encdtPer) do begin
                        IncD(stack[n1],i-1,stack[n1][i] div encdtPer[i]);
                        stack[n1][i] := stack[n1][i] mod encdtPer[i];
                      end;
                      dt:=EncodeDateTry(stack[n1][encdtY],stack[n1][encdtM],stack[n1][encdtD],stack[n1][encdtD])
                        +EncodeTime(stack[n1][encdtH],stack[n1][encdtN],stack[n1][encdtS],stack[n1][encdtZ]);
                      stack[n1]:=dt;
                    end;
                    else
                      if Pos(DateSeparator,stack[n1])=0
                      then stodSelf(stack[n1])
                      else ctodSelf(stack[n1],CtodEpoch,ProtDebStrAdd);
                  end;
                  biDton: stack[n1]:=Dton(stack[n1],stack[n1+1]);
                  biDtos: dtosSelf(stack[n1]);
                  biDecodeDateTime: begin
                    DecodeDateTry(stack[n1],dy,dm,dd);
                    if stack[n1]=DateEmpty then begin
                      dh:=0; dn:=0; ds:=0; dz:=0;
                    end
                    else DecodeTime(stack[n1],dh,dn,ds,dz);
                    stack[n1]:=ArrVarToVar([dy,dm,dd,dh,dn,ds,dz]);
                  end;
                  biDayOfWeek: stack[n1]:=DayOfTheWeek(stack[n1]);
                  biRun: begin
                    s1:=stack[n1]; stack[n1]:=null;
                    if MyVarType(stack[n1+3])=varBoolean
                    then RunExe(DlmBetween(s1,IsNilc(stack[n1+1],''),' '),IsNilc(stack[n1+2],''),
                      '',[''],'',IfThen(stack[n1+3],runWin))
                    else ShellExecute(0,nil,PChar(s1),sChr(1),sChr(2),SW_SHOW);
                  end;
                  biPrm: stack[n1]:=avp[CurInter.nvp,2,longint(stack[n1])];
                  biSaveIni: with InitFIni[fiSave] do begin
                    s1:=stack[n1]; n2:=n1+1; n4:=n1+3;
                    stack[n1]:=ReadString(s1,stack[n2],IsNilc(stack[n1+2],''));
                    if MyVarType(stack[n4])=varString then WriteString(s1,stack[n2],stack[n4]);
                  end;
                  biMessOk,biDbgMessOk: begin
                    if IsNil(stack[n1])
                    then meserr(StMeserr(stack[n1+1]),MessagesDbgCaption(IsNilc(stack[n1+2],'')),
                      Algm(stack[n1+3]),bi=biDbgMessOk)
                    else begin
                      j:=n1+MAX_PRM-1; s1:='';
                      while (j>=n1) and IsNil(stack[j]) do Dec(j);
                      while j>=n1 do begin
                        IncL(s1,CRLF+StMeserr(stack[j])); Dec(j);
                      end;
                      mess_ok([copy(s1,lCRLF1,MaxInt)],MessagesDbgCaption(''),
                        taCenter,bi=biDbgMessOk);
                    end;
                    stack[n1]:='';
                  end;
                  biAsk: begin
                    s1:=StMeserr(stack[n1]); n2:=n1+1; n3:=n2+1; IsNil(stack[n3],'');
                    alg:=Algm(stack[n1+3]);
                    case MyVarType(IsNil(stack[n2],true),true) of
                      varDouble: begin
                        j:=nround(stack[n2]);
                        if not InRange(j,low(aAsk),high(aAsk)) then raise EInterAnyError.CreateFmt(
                          '2 параметр должен быть от %d до %d',[low(aAsk),high(aAsk)]);
                        stack[n1]:=AskCancel([s1],aAsk[j],stack[n3],alg);
                        for j:=low(aAsk) to high(aAsk) do
                          if aAsk[j]=stack[n1] then begin
                            stack[n1]:=j; break;
                          end;
                      end;
                      varBoolean: stack[n1]:=Ask([s1],stack[n2],stack[n3],alg);
                    else raise EInterAnyError.Create('2 параметр должен быть целым или логическим');
                    end;
                  end;
                  biStProc:
                    if fPrStat is TStat
                      then stack[n1]:=not TStat(fPrStat).SayStat(IsNilc(stack[n1+2],''),
                        IsNilc(stack[n1],''),IsNilc(stack[n1+1],0))
                    else if fPrStat is TAsk then begin
                      if MyVarType(stack[n1])=varArray then begin
                        l:=VarArrayLowBound(stack[n1],1); h:=VarArrayHighBound(stack[n1],1);
                        SetLength(av,h-l+1);
                        for j:=low(av) to high(av) do begin
                          av[j]:=stack[n1][l]; Inc(l);
                        end;
                      end
                      else CopyFromVArr(av,stack[n1]);
                      stack[n1]:=not TAsk(fPrStat).SayCapt(av);
                    end
                    else stack[n1]:=true;
                  biProfile: begin
{$IFDEF PROF}
                    FProf(IsNilc(stack[n1],''));
{$ENDIF}
                    stack[n1]:=null;
                  end;
                  biFmtClr: begin
                    stack[n1]:=null; InitArr(sfmt,0,MaxInt,'');
                  end;
                  biTransLit: begin
                    stRus:=[];
                    if IsNilc(stack[n1+1],false) then Include(stRus,false);
                    if IsNilc(stack[n1+2],false) then Include(stRus,true);
                    stack[n1]:=TransLiteration(stack[n1],stRus);
                  end;
                  biHelpStr:
                    if MyVarType(stack[n1])=varArray then stack[n1]:=HelpTblArr(stack[n1][0])
                    else begin
                      n2:=n1+1; n3:=n1+2;
                      if MyVarType(stack[n2])=V_STRING then
                        if lsFuncPart.Find(stack[n2],i) then begin
                          stack[n2]:=VarArrayOf([IntToStr(IntObj(lsFuncPart,i))]);
                          stack[n3]:=hlnkFuncPart;
                        end;
                      if MyVarType(IsNil(stack[n3],''),true)=V_FLOAT then begin
                        hl:=stack[n3];
                        if hl=hlnkTbl then begin
                          ht.Dat:=nil;
                          if MyVarType(stack[n2])=varArray then begin
                            ht.Head:=stack[n2][1];
                            if MyVarType(stack[n2][2])=varArray then begin
                              j:=VarArrayLowBound(stack[n2][2],1);
                              SetLength(ht.Dat,VarArrayHighBound(stack[n2][2],1)-j+1);
                              for i:=low(ht.Dat) to high(ht.Dat) do begin
                                CopyFromVar(ht.Dat[i],stack[n2][2][j]); Inc(j);
                              end;
                            end;
                          end
                          else ht.Head:='';
                          stack[n1]:=HelpBoldStr(stack[n1],ht);
                        end
                        else begin
                          if hl=hlnkInterMemo then
                            if MyVarType(stack[n2])=V_BOOL
                            then s:=stack[n1]+IfThen(stack[n2],'()')
                            else s:=IsNilc(stack[n2],stack[n1])
                          else begin
                            s:='';
                            case MyVarType(stack[n2]) of
                              V_NULL: if hl=hlnkDfrm then s:=stack[n1];
                              V_STRING: if hl in [hlnkGet,hlnkDfrm] then s:=stack[n2];
                              varArray: begin
                                for i:=VarArrayLowBound(stack[n2],1) to VarArrayHighBound(stack[n2],1) do
                                  IncD(s,stack[n2][i]+'\');
                                DecLen(s);
                              end;
                            end;
                          end;
                          stack[n1]:=HelpBoldStr(stack[n1],s,hl);
                        end;
                      end
                      else if MyVarType(stack[n2])=V_STRING then
                        if IsNil(stack[n1])
                        then stack[n1]:=HelpIsPage(stack[n2],stack[n3])
                        else stack[n1]:=HelpBoldStr(stack[n1],string(stack[n2]),string(stack[n3]))
                      else stack[n1]:=HelpBoldStr(stack[n1],THelpStyleList(IsNilc(stack[n2],SCE_OURLIB_HELP_DEF)));
                    end;
                  biKeyLb: if FormKeyLb(LastForm,tl) then tl.ExecKey(stack[n1]);
                  biWinToUtf8: stack[n1]:=WinToUtf8(stack[n1]);
                  biUtf8ToWin: stack[n1]:=Utf8ToWin(stack[n1]);
                  biPDF417:
                    if IsNil(stack[n1])
                    then stack[n1]:=Pdf417Init
                    else stack[n1]:=Pdf417PreviewFile(stack[n1],IsNilc(stack[n1+1],''));
                  biArrDebug:
                    for i:=VarArrayLowBound(stack[n1],1) to VarArrayHighBound(stack[n1],1) do
                      stack[n1][i]:=ArrVarToVar([stack[n1][i]]);
                  biPriv: stack[n1]:=CanPriv(stack[n1]);
                  biStruct:
                    if IntObjFind(lsStruct,stack[n1],i) then begin
                      dwStruct.dw:=i; n2:=dwStruct.w1; i:=lsStruct.Count; InitArrLen(stack[n1],1,i,''); j:=0;
                      for i:=0 to i-1 do begin
                        dwStruct.dw:=LongWordObj(lsStruct,i);
                        if dwStruct.w1=n2 then begin
                          stack[n1][dwStruct.w2]:=lsStruct[i]; MaxSelf(j,dwStruct.w2);
                        end;
                      end;
                      VarArrayRedim(stack[n1],j);
                    end
                    else raise EInterAnyError.Create('Отсутствует структура "'+stack[n1]+'"');
                  biInRange: begin
                    n2:=n1+1; n3:=n2+1; n4:=n3+1;
                    if IsNil(stack[n4])
                    then stack[n1] := (stack[n1]>=stack[n2]) and (stack[n1]<=stack[n3])
                    else stack[n1] := (stack[n1]<=stack[n4]) and (stack[n2]>=stack[n3]);
                  end;
                  biEnsureRange: begin
                    n2:=n1+1; n3:=n2+1; assert(stack[n2] <= stack[n3]);
                    if stack[n1]<stack[n2] then stack[n1]:=stack[n2];
                    if stack[n1]>stack[n3] then stack[n1]:=stack[n3];
                  end;
                  biReplVar: if CompVar(stack[n1],stack[n1+1]) then stack[n1]:=stack[n1+2];
                  biPadegFIO,biPadegPodr,biPadegDolg: begin
                    n2:=stack[n1+1];
                    if not InRange(n2,low(aPdgName),high(aPdgName)) then raise EInterAnyError.CreateFmt(
                      'Некорректное значение падежа: %d',[n2]);
                    case bi of
                      biPadegFIO: begin
                        n3:=n1+2;
                        if IsNil(stack[n3]) then sx:=sexAll else sx:=GetSex(stack[n3]);
                        if MyVarType(stack[n1])=varArray then begin
                          VAddEndSelf(stack[n1],3,'');
                          stack[n1]:=PadegFIO(stack[n1][1],stack[n1][2],stack[n1][3],n2,sx);
                        end
                        else stack[n1]:=PadegFIO(stack[n1],n2,sx);
                      end;
                      biPadegPodr: stack[n1]:=PadegPodr(stack[n1],n2);
                      biPadegDolg: stack[n1]:=PadegDolg(stack[n1],n2);
                    end;
                  end;
                  biPartsFIO: begin
                    PartsFIO(stack[n1],s1,s2,s3); stack[n1]:=ArrVarToVar([s1,s2,s3]);
                  end;
                end;
{$IFDEF PROFINTER}
              finally
                InterProfEnd(oEvalName);
              end;
{$ENDIF}
            end;
            ist:=n1;
          finally
            SetCurVF(ovf);
          end;
        end;
        O_STOP: if not(true in MessagesOkHidden) then Stop;
      end;
      {if not CompVar(stack[ist],v) then begin
        meserr(stack[ist]);
        meserr(v);
      end;}
    end;
    {$IFDEF STACKALL}DelStack;{$ENDIF}
  end;
var nlineold,i,ost:longint;
  ExcMsg:string;
	tr:transf;
  onvp:smallint;
begin
	ost:=AddStack('TInter.CompileEval');
  Inc(nInterStack);
  if nInterStack>high(aInterStack) then raise Exception.Create('Переполнение стека выполнения формул');
  aInterStack[nInterStack]:=Self; Inc(anvp[false]); nlineold:=nline; onvp:=nvp;
  try
    result:=''; error:=E_NO; serror:=''; nvp:=anvp[lDebug];
    if iceNoShape in Opt then fvo:=[fvNoShape] else fvo:=[];
    if iceOnlyComp in Opt then Include(fvo,fvShapeFull);
    if not lDebug then for i:=1 to min(MAXLVAR,Length(ap)) do begin
      avp[nvp,1,i]:=ap[i-1]; avp[nvp,2,i]:=ap[i-1];
    end;
    try
      if fl_compile then Fcompile;
      if not(iceOnlyComp in Opt) then begin
        nline:=1;
        while nline<=high(Listcom)+1 do begin
          com:=Listcom[nline-1];
          tr.s[1]:= com[1];
          tr.s[2]:= com[2];
          lerror:= tr.i2;
          if InterStopOn then
            if (Assigned(InterDebug) and (IntStatVar=InterDebug) or InterAnyDebug)
            and ((lerror=lErrorDebug) or (lErrorDebug=0)) then begin
              InterStopOn:=false; Stop;
              if nline=MaxNline then break;
            end;
          evalcom;
          inc(nline);
        end;
        result:=stack[1];
        if not TypesChk(value_types,result) then begin
          if nline<=Maxnline then lerror:=0;
          Err(E_RETURN);
        end;
        if Assigned(CheckResultProc) then CheckResultProc(result);
      end;
    except
      on E:Exception do begin
        if FEvalRaise then raise;
//raise;
        ExcMsg:=E.Message;
        if not lDebug then begin
          InterErr:=Self; anvp[true]:=nvp;
        end;
        if E is EInterException then begin
          SetStack(ost);
          case error of
            E_OPER:
              serror:='Неправильный оператор.';
            E_SCONST:
              serror:='Отсутствует закрывающая кавычка.';
            E_CLOSE:
              serror:='Неправильное количество закрывающих скобок <)>.';
            E_NAME:
              serror:='Синтаксическая ошибка.';
            E_VAR:
              serror:='Некорректное имя переменной: '+E.Message+'.';
            E_FUNC:
              serror:='Некорректное имя функции: '+E.Message+'.';
            E_END:
              serror:='Неправильная вложенность операторов.';
            E_MANYLV:
              serror:=StrNum('Количество временных переменных не должно превышать ',MAXLVAR1);
            E_CONST:
              serror:='Нельзя присваивать значение константе "'+avar[cur_vf-1].name+'".';
            E_COMMENT:
              serror:='Не закрыт комментарий '+sCommBeg+'...'+sCommEnd;
            E_RETURN:
              serror:='Возвращаемое значение должно'+TypesMsg(value_types);
            E_ARRDIM:
              serror:='Размерность массива не должна превышать 5-и';
            E_ARRLOC:
              serror:='Массив может быть присвоен только временной переменной';
            E_MANYST:
              serror:=StrNum('Количество хранимых переменных не должно превышать ',MAXLVAR-MAXLVAR1);
            E_STRUCT:
              serror:='Ошибка структуры';
          end;
        end
        else if E is EInterConstException then begin
          SetStack(ost);
          error:=E_CONST;
          serror:= 'Нельзя присваивать значение константе "'+avar[EInterConstException(E).curn-1].name+'".';
        end
        else if (E is EZeroDivide) or (E is EDivByZero) then begin
          SetStack(ost);
          error:=E_DIV0;
          serror:= 'Деление на 0.';
        end
        else if E is EInvalidOp then begin
          SetStack(ost);
          error:=E_INV_OP;
          serror:='Неправильная математическая операция.';
        end
        else if E is Eoverflow then begin
          SetStack(ost);
          error:=E_OVER_FL;
          serror:='Слишком большое число.';
        end
        else if E is EUnderflow then begin
          SetStack(ost);
          error:=E_UNDER_FL;
          serror:='Слишком маленькое число.';
        end
        else if E is EVariantError then begin
          SetStack(ost);
          error:=E_VARIANT;
          serror:='Неправильное преобразование типов.';
        end
        else if E is EConvertError then begin
          SetStack(ost);
          error:=E_CONVERT;
          serror:='Ошибка преобразования строки в число.';
        end
        else if E is ESummException then begin
          SetStack(ost);
          error:=E_SUMM;
          serror:=e.message;
        end
        else if E is EInterAnyError then begin
          SetStack(ost);
          error:=E_ANY;
          serror:=e.message;
          with EInterAnyError(E) do case mode of
            modeVar:
              if serror=''
              then serror:='Ошибка вычисления значения '+CurName
              else IncL(serror,CurName+': ');
            modeFunc,modeBuiltIn:
              if serror=''
              then serror:='Ошибка выполнения функции '+CurName+'()'
              else IncL(serror,CurName+'(): ');
          end;
        end
        else if E is EInterAbortError then begin
          SetStack(ost);
          error:=E_ABORT;
        end
        else begin
          error:=E_ANY;
          serror:='Ошибка:'+e.message+CRLF+'Тип ошибки: ('+e.classname+')';
          if ShowError then SetStack(ost) else raise
        end;
      end;
    end;
    if (error<>E_NO) and Assigned(InterMsgErrorProc) then InterMsgErrorProc(ExcMsg,error,serror);
    if not(iceOnlyComp in Opt) and not(error in [E_NO,E_ABORT]) then begin
      ExcMsg:=IfThen(lerror<>0,StrNum('Строка: ',lerror));
      ProtDebStrAdd('ОШИБКА ПРИ ВЫПОЛНЕНИИ ФОРМУЛЫ. '+DlmBetween(ExcMsg,serror,': '));
      if showerror then
        if InterShowError(Self)=mrOk then error:=E_NO;
    end;
  finally
    Dec(anvp[false]);
    if error=E_NO then nvp:=onvp{anvp[false]};
    nline:=nlineold; Dec(nInterStack);
    if nInterStack=0 then begin
      InterDebug:=nil; InterAnyDebug:=false;
    end;
  end;
	DelStack;
end; begin Dummy; end;

procedure Tinter.ProcError;
var Msg: string;
begin
  AddStack('Tinter.ProcError');
  Msg:=Format(FormatStr,Args);
  if GetUserGG>=nGG then raise EInterAnyError.Create(Msg);
  ProtDebStrAdd(Format('ОШИБКА ПРИ ВЫПОЛНЕНИИ ФОРМУЛЫ. Строка: %d: ',[lerror])+Msg+'.');
  DelStack;
end;

class procedure Tinter.ProtDebStrAdd;
var ss: string;
  i: longint;
begin
  AddStack('Tinter.ProtDebStrAdd');
  ss:='';
  for i:=nInterStack downto 1 do IncD(ss,IfThen(i=nInterStack,CRLF,'; ')+aInterStack[i].name);
  ProtocolStrAdd(protDebug,s+ss,[protStack]);
  DelStack;
end;

procedure slFLFree;
var k: longint;
begin
	AddStack('inter.slFLFree');
  if slFL<>nil then begin
    for k:=0 to slFL.Count-1 do aFL[k].slVars.Free;
    crrFL:=-1; aFL:=nil; FreeAndNil(slFL);
  end;
  DelStack;
end;

class function Tinter.SetVar(const name,chint:string;pr:TVarevent; const ind: variant;
  const types: string = ''; ReadOnly: boolean = false): longint;
var p: Pvarrec;
  h,j,k: longint;
  sl: TStringList;
  hint: string;
  a: TNamePrimStr;
  ap: TArrStr;
begin
	AddStack('Tinter.SetVar');
  result:=0;
  if not(csDesigning in Application.ComponentState) then begin
    LsVarInit; hint:=chint;
    if (@pr=@i_const) and CanPriv(PrivDesign) then begin
      h:=MyVarType(ind);
      if h<>varArray then begin
        if h=V_STRING then hint:='"'+TrnsABC(ind)+'"' else hint:=StMeserr(ind);
        IncL(hint,chint+' =');
      end;
    end;
    k:=CntCharBeg(name,'$');
    if k>0 then begin
      szParent:=k-1;
      if length(asParent)<szParent then SetLength(asParent,szParent);
      sParHash:='';
      if szParent>0 then begin
        j:=szParent-1;
        asParent[j].namep:=name;
        asParent[j].hintp:=hint;
        for h:=0 to j do IncD(sParHash,asParent[h].hintp+sParSep);
      end else begin
        if not IntObjFindAdd(slFL,name,crrFL) then begin
          if Length(aFL)=crrFL then SetLength(aFL,crrFL shl 1);
          aFL[crrFL].slVars:=SortStrListCreate;
        end;
        aFL[crrFL].flEnabled:=true;
        aFL[crrFL].flHint:=hint;
      end;
      if StrDivDlm(iChrPrim,name,a) then for j:=0 to LsArrDynamic(a[2],ap,',')-1 do lsPref.Add(Trim(ap[j]));
    end else begin
      if crrFL>=0 then if aFL[crrFL].flEnabled then begin
        sl:=aFL[crrFL].slVars;
        if IgnoreSlFindAdd(sl,name,h) then begin
          j:=IntObj(sl,h);
          if j<=nvar then begin
          	p:=@avar[j-1]; result:=1+j;
          end
          else p:=nil;
        end else begin
          if nvar=Length(avar) then SetLength(avar,nvar shl 1);
          p:=@avar[nvar]; p.name:=name; p.slPars:=SortStrListCreate; SetLength(p.aPars,1);
          Inc(nvar); result:=nvar; sl.Objects[h]:=pointer(result);
        end;
        if p<>nil then begin
          sl:=p^.slPars;
          if not IntObjFindAdd(sl,sParHash,k) then begin
            if Length(p.aPars)=k then SetLength(p.aPars,k shl 1);
            with p.aPars[k] do begin
              SetLength(vriBP,szParent);
              for j:=0 to high(vriBP) do vriBP[j]:=asParent[j].namep;
            end;
          end;
          with p.aPars[k] do begin
            vriHint:=hint;
            vriEnabled:=true;
            vriProc:=pr;
            vriIndex:=ind;
            vriTypes:=types;
            vriReadOnly:=ReadOnly;
          end;
          p.hint:=hint;(* SeekVar'у нужен hint *)
          p.proc:=pr;
          p.index:=ind;
          p.types:=types;
          p.ReadOnly:=ReadOnly;
          p.Enabled:=true;
        end;
      end;
    end;
  end;
  DelStack;
end;

class procedure Tinter.SetVar(const name,chint:string);
begin
  SetVar(name,chint,nil,null);
end;

class procedure Tinter.SetVar(const name,prim,chint:string);
begin
  SetVar(name+iChrPrim+prim,chint);
end;

class procedure TInter.SetVar(const name,chint: string; pr: TVarevent; const ind: variant;
  const types: string; ReadOnly: boolean; help: THelpContext;
  const hlpfile: string = ''; const hlpname: string = '');
begin
  SetVar(name,chint,pr,ind,types,ReadOnly); SetVar(name,help,hlpfile,hlpname);
end;

class procedure TInter.SetVar(const name: string; help: THelpContext;
  const hlpfile: string = ''; const hlpname: string = '');
var n: longint;
begin
  AddStack('TInter.SetVar(help)');
  if not((help=0) and (hlpfile='') and (hlpname='')) then begin
    if not IntObjFindAdd(lsVarHelp,name,n) then
      if Length(aVarHelp)=n then SetLength(aVarHelp,n shl 1);
    aVarHelp[n].help:=help; aVarHelp[n].hlpfile:=hlpfile; aVarHelp[n].hlpname:=hlpname;
  end;
  DelStack;
end;

class procedure TInter.SetVar(const name: string; hl: THelpLinkList; const hlpname: string);
begin
  SetVar(name,0,Int2Str(hl),hlpname);
end;

function GetPrimName(const nmdb:string): string;
begin
  AddStack('Inter.GetPrimName');
  if lPrimAll then result:=GetPrim(nmdb) else result:=cGetPrim+nmdb+cGetPrim;
  DelStack;
end;

class procedure Tinter.SetVarPrim(const name,nmdb:string);
begin
  SetVar(name,GetPrimName(nmdb));
end;

class procedure Tinter.SetVarPrim(const name,prim,nmdb:string);
begin
  SetVarPrim(name+iChrPrim+prim,nmdb);
end;

class procedure Tinter.SetVarShape;
var n: longint;
begin
	AddStack('Tinter.SetVarShape');
  if not Assigned(lsShape) then begin
    lsShape:=SortStrListCreate; SetLength(aShape,10);
  end;
  if not IntObjFindAdd(lsShape,name,n) then if Length(aShape)=n then SetLength(aShape,n shl 1);
  aShape[n].prVar:=prVar; aShape[n].prTrans:=prTrans; CopyFromVArr(aShape[n].av,av);
  DelStack;
end;

class function TInter.GetVarHelp(const name: string; var n: longint): boolean;
begin
  AddStack('TInter.GetVarHelp');
  result:=IntObjFind(lsVarHelp,name,n);
  if not result then n:=0; // Пустой по умолчанию
  DelStack;
end;

class function TInter.GetVarHelp(const vr: varrec): PVarHelp;
begin
  GetVarHelp(vr.name,result);
end;

class function TInter.GetVarHelp(const name: string; var vh: PVarHelp): boolean;
var n: longint;
begin
  result:=GetVarHelp(name,n); vh:=@aVarHelp[n];
end;

class procedure Tinter.DopGetVarAdd;
var i: longint;
begin
  AddStack('Tinter.DopGetVarAdd');
  i:=Length(aDopGetVar); SetLength(aDopGetVar,i+1);
  CopyFromVArr(aDopGetVar[i].av,av);
  aDopGetVar[i].PrEqual:=PrEqual;
  aDopGetVar[i].PrAdd:=PrAdd;
  aDopGetVar[i].PrIgnore:=PrIgnore;
  DelStack;
end;

class function TInter.MemoVarIgnore;
var i: longint;
begin
  AddStack('TInter.MemoVarIgnore');
  result:=false;
  for i:=low(aDopGetVar) to high(aDopGetVar) do if aDopGetVar[i].PrIgnore(aPath) then begin
    result:=true; break;
  end;
  DelStack;
end;

class procedure Tinter.DelVar;
var i,j: longint;
begin
	AddStack('Tinter.DelVar');
  if not(csDesigning in Application.ComponentState) then begin
    LsVarInit; j:=slFL.IndexOf(name);
    if j<0 then begin
    	j:=slFL.Count-1;
      while j>=0 do
        if VarWithoutPrim(slFL[j])=name then break else Dec(j);
  	end;
    if j>=0 then with aFL[IntObj(slFL,j)] do begin
      flEnabled:=false;
      for j:=0 to slVars.Count-1 do begin
        i:=IntObj(slVars,j);
        if i<=nvar then with avar[i-1] do begin
          Enabled:=false;
          for i:=0 to slPars.Count-1 do aPars[IntObj(slPars,i)].vriEnabled:=false;
        end;
      end;
    end;
  end;
  DelStack;
end;

class procedure Tinter.SetOperator;
var op:operrec;
begin
	AddStack('Tinter.SetOperator');
  if loperv=MAXOPER then mess_ok(['Ошибка создания оператора "'+name+'":',
    BracketInt('Количество операторов превышает максимально допустимое',MAXOPER)+'.'])
  else begin
    inc(loperv);
    op.name:=name;
    op.hint:=hint;
    op.optext:=optext;
    op.oplev:=oplev;
    op.help:=help;
    op.hlpfile:=InterCurHelpFile;
    op.nmhelp:=nmhelp;
    aoperv[loperv]:=op;
  end;
  DelStack;
end;

class procedure Tinter.SetFunction(const name,hint:string;
  const aPrmPrim,aPrmType: array of string;
  pr:TFuncevent; const index: variant; help: longint = 0; const types: string = '';
  nBuiltIn: longint = 0);
var fr:funcrec;
  i,h: longint;
begin
  AddStack('Tinter.SetFunction');
  if lafunc=MAXFUNC then mess_ok(['Ошибка создания функции "'+name+'":',
    BracketInt('Количество функций превышает максимально допустимое',MAXFUNC)+'.'])
  else begin
    inc(lafunc);
    fr.name:=name;
    fr.hint:=hint;
    fr.proc:=pr;
    SetLength(fr.aPrm,Length(aPrmPrim)); h:=high(aPrmType);
    for i:=low(aPrmPrim) to high(aPrmPrim) do begin
      fr.aPrm[i,1]:=aPrmPrim[i];
      if i>h then fr.aPrm[i,2]:='' else fr.aPrm[i,2]:=aPrmType[i];
    end;
    fr.index:=index;
    fr.help:=help;
    fr.hlpfile:=InterCurHelpFile;
    fr.types:=types;
    fr.nBuiltIn:=nBuiltIn;
    afunc[lafunc]:=fr;
    if name='' then begin
      if not Assigned(lsFuncPart) then lsFuncPart:=TFuncPartList.Create;
      lsFuncPart.AddObject('',pointer(lafunc));
    end;
  end;
  DelStack;
end;

class procedure Tinter.SetFunction(const name,hint:string;
  pr:TFuncevent; const index: variant; const aPrm: array of TFuncPrimType;
  help: longint = 0; const types: string = '');
var aPrmPrim,aPrmType: TArrStr;
  i: longint;
begin
  i:=Length(aPrm); SetLength(aPrmPrim,i); SetLength(aPrmType,i);
  for i:=low(aPrm) to high(aPrm) do begin
    aPrmPrim[i]:=aPrm[i,1]; aPrmType[i]:=aPrm[i,2];
  end;
  SetFunction(name,hint,aPrmPrim,aPrmType,pr,index,help,types);
end;

class procedure Tinter.SetFunction(const hint: string; help: longint = 0);
begin
  SetFunction('',hint,nil,null,help);
end;

class procedure Tinter.SetPrimAll;
var i,j,k,l: longint;
  oname,nname: string;
  a: TArrStr;
  fl: boolean;
begin
  AddStack('Tinter.SetPrimAll');
  if not lPrimAll then begin
    PointerDef(pointer(@PrTrans),@GetPrimTrans);
    for i:=1 to lafunc do with afunc[i] do if name='' then begin
      nname:=hint;
      if PrTrans(nname) then with lsFuncPart do begin
        oname:=GetName(pointer(i)); hint:=nname; nname:=GetName(pointer(i));
        if nname<>oname then begin
          Find(oname,j); Sorted:=false; Strings[j]:=nname; Sorted:=true;
        end;
      end;
    end
    else PrTrans(hint);
    for i:=0 to slFL.Count-1 do PrTrans(aFL[IntObj(slFL,i)].flHint);
    for i:=0 to nvar-1 do with avar[i] do begin
      PrTrans(hint);
      for j:=low(aPars) to high(aPars) do PrTrans(aPars[j].vriHint);
      if Assigned(slPars) then with slPars do begin
        for j:=0 to Count-1 do begin
          fl:=false; l:=LsArrDynamic(Strings[j],a,sParSep);
          for k:=0 to l do if PrTrans(a[k]) then fl:=true;
          if fl then begin
            Sorted:=false; Strings[j]:=ArrayAsList(a,sParSep,l);
          end;
        end;
        Sorted:=true;
      end;
    end;
    lPrimAll:=true;
  end;
  DelStack;
end;

class procedure Tinter.SetFunction(const name,hint:string;
  pr:TFuncevent; const index: variant; help: longint = 0; const types: string = '');
begin
  SetFunction(name,hint,[],[],pr,index,help,types);
end;

class procedure Tinter.SetFunction(const name: string; pr:TFuncevent);
begin
  SetFunction(name,'',pr,null);
end;

procedure SetFuncBuiltIn(nBuiltIn: TBuiltInList; const hint:string;
  help: longint; const types: string = ''); overload;
begin
  AddStack('inter.SetFuncBuiltIn');
  with aBuiltIn[nBuiltIn],aBuiltInProc[nBuiltIn] do
    TInter.SetFunction(name,hint,aPrmPrim,aPrmType,nil,null,help,types,byte(nBuiltIn));
  DelStack;
end;

procedure SetFuncBuiltIn(nBuiltIn: TBuiltInList; const hint:string = '';
  const types: string = ''); overload;
begin
  SetFuncBuiltIn(nBuiltIn,hint,0,types);
end;

class function ReSetFunction(const name:string; const hint:variant; aPrmPrim,aPrmType: PArrStr;
  const index,help: variant; const types: string): longint;
var j: longint;
begin
  AddStack('inter.ReSetFunction');
  result:=1;
  while result<=lafunc do if afunc[result].name=name then begin
    if MyVarType(hint)=varString then afunc[result].hint:=hint;
    if Assigned(aPrmPrim) then begin
      SetLength(afunc[result].aPrm,Length(aPrmPrim^));
      for j:=low(aPrmPrim^) to high(aPrmPrim^) do afunc[result].aPrm[j,1]:=aPrmPrim^[j];
    end;
    if Assigned(aPrmType) then for j:=low(aPrmType^) to min(high(aPrmType^),high(afunc[result].aPrm)) do
      afunc[result].aPrm[j,2]:=aPrmType^[j];
    afunc[result].index:=index;
    if MyVarType(help)=varInteger then afunc[result].help:=help;
    afunc[result].hlpfile:=InterCurHelpFile; afunc[result].types:=types;
    break;
  end
  else Inc(result);
  DelStack;
end;

class procedure Tinter.ReSetFunction(const name:string; const hint:variant; aPrmPrim,aPrmType: PArrStr;
  pr:TFuncevent; const index,help: variant; const types: string = '');
var i: longint;
begin
  i:=inter.ReSetFunction(name,hint,aPrmPrim,aPrmType,index,help,types);
  afunc[i].proc:=pr; afunc[i].nBuiltIn:=0;
end;

class procedure Tinter.ReSetFunction(const name:string; const hint:variant; aPrmPrim,aPrmType: PArrStr;
  bi: TBuiltInList; Proc: TBuiltInProc; const index,help: variant; const types: string = '');
begin
  inter.ReSetFunction(name,hint,aPrmPrim,aPrmType,index,help,types);
  aBuiltInProc[bi].Proc:=Proc;
  CopyFrom(aBuiltInProc[bi].aPrmPrim,aPrmPrim^);
  CopyFrom(aBuiltInProc[bi].aPrmType,aPrmType^);
end;

class function Tinter.ReSetFunction(const name:string; pr:TFuncevent): TFuncevent;
var i: longint;
begin
  AddStack('Tinter.ReSetFunction(pr)');
  result:=pr;
  for i:=1 to lafunc do if afunc[i].name=name then begin
    afunc[i].proc:=pr; break;
  end;
  DelStack;
end;

class procedure Tinter.DelFunction;
var j,n: longint;
begin
  AddStack('Tinter.DelFunction');
  Dec(lafunc);
  for j:=i to lafunc do afunc[j]:=afunc[j+1];
  for j:=0 to lsFuncPart.Count-1 do begin
    n:=IntObj(lsFuncPart,j);
    if n>i then lsFuncPart.Objects[j]:=Pointer(n-1);
  end;
  DelStack;
end;

constructor THSLList.Create;
begin
  {$IFDEF STACKALL}AddStack('THSLList.Create');{$ENDIF}
  Sorted:=true; SetLength(a,10);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function THSLList.IgnoreFindAdd;
begin
  {$IFDEF STACKALL}AddStack('THSLList.IgnoreFindAdd');{$ENDIF}
  result:=IntObjFindAdd(Self,s,i);
  if not result then begin
    if Length(a)=i then SetLength(a,i shl 1);
    a[i].parb:=false; 
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

class procedure Tinter.GetVar(var a: TArrVarRec; const name: string = '';
  VarTypes: TInterVarTypes = [low(TInterVarType)..high(TInterVarType)];
  Opt: TInterVarOpt = []);
  procedure Arr2Sls(var sa: array of string; i,sz: longint; sl: THSLList;
    pvr: PVarrec; vri: longint);
  var p: longint;
    ph: PVarHelp;
  begin
    {$IFDEF STACKALL}AddStack('Tinter.GetVar.Arr2Sls');{$ENDIF}
    if i>=sz then begin (* т.е. родители кончились, дошли до переменной *)
      sl.IgnoreFindAdd(pvr.name,p);
      with sl.a[p],pvr.aPars[vri] do begin
        varb:=true; hint:=vriHint; proc:=vriProc; index:=vriIndex;
        types:=vriTypes; ReadOnly:=vriReadOnly;
        ph:=GetVarHelp(pvr^); help:=ph.help; hlpfile:=DlmBetween(ph.hlpfile,ph.hlpname,'.');
      end;
    end
    else begin
      if not sl.IgnoreFindAdd(sa[i],p) then sl.a[p].varb:=false;
      with sl.a[p] do begin
        if not parb then begin
          parb:=true; name:=pvr.aPars[vri].vriBP[i]; sl:=THSLList.Create;
        end;
        Arr2Sls(sa,i+1,sz,sl,pvr,vri);
      end;
    end;
    {$IFDEF STACKALL}DelStack;{$ENDIF}
  end;
  procedure WriteRiz(const Aname,Ahint: string; const Aindex: variant; Aproc:TVarevent=nil;
  	const Atypes: string = ''; const AReadOnly: boolean = false; AHelp: THelpContext = 0; const AHlpFile: string='');
  begin
  	if not AnsiStartsStr(idShapeHint,Ahint) then begin
    	FWriteRiz(Aname,Ahint,Atypes,AReadOnly);
      {if Name<>'' then} with aGetVar^[iGetVar-1] do begin
        proc:=Aproc; index:=Aindex;
      end;
    end;
  end;
  procedure FillRiz(sl: THSLList);
  var k: longint;
  begin
    {$IFDEF STACKALL}AddStack('Tinter.GetVar.FillRiz');{$ENDIF}
    (* в начале просто переменные *)
    with sl do begin
      for k:=0 to Count-1 do with a[IntObj(sl,k)] do
        if varb then WriteRiz(Strings[k],hint,index,proc,types,ReadOnly,help,hlpfile);
      (* потом разделы *)
      for k:=0 to Count-1 do with a[IntObj(sl,k)] do if parb then begin
        WriteRiz(name,Strings[k],null);(* долл. parent *)
        FillRiz(sl);
      end;
    end;
    {$IFDEF STACKALL}DelStack;{$ENDIF}
  end;
  procedure ClearSLR(sl: THSLList);
  var k: longint;
  begin
    {$IFDEF STACKALL}AddStack('Tinter.GetVar.ClearSLR');{$ENDIF}
    for k:=0 to sl.Count-1 do with sl.a[IntObj(sl,k)] do if parb then begin
      ClearSLR(sl); sl.Destroy;
    end;
    sl.Clear;
    {$IFDEF STACKALL}DelStack;{$ENDIF}
  end;
var j:longint;
	slr: THSLList;
  procedure Add1;
  var slp: TStringList;
    k,h,m,vri: longint;
    p: Pvarrec;
    b: boolean;
    pararr: array[1..20] of string;
  begin
    {$IFDEF STACKALL}AddStack('Tinter.GetVar.Add1');{$ENDIF}
    with aFL[IntObj(slFL,j)] do if flEnabled then begin
      WriteRiz(slFL[j],flHint,null);
      for k:=0 to slVars.Count-1 do begin
        h:=IntObj(slVars,k);
        if h<=nvar then begin
          p:=@avar[h-1];
          if p^.Enabled and ((ivWithEng in Opt) or not FirstEngChar(p.name)) then begin
            b:=not empty(p^.name);
            slp:=p^.slPars;
            for h:=0 to slp.Count-1 do begin
              vri:=IntObj(slp,h);
              if p.aPars[vri].vriEnabled and (b or (not empty(p.aPars[vri].vriHint))) then begin
                m:=listasarray(slp[h],pararr,sParSep,false);
                Arr2Sls(pararr,0,m,slr,p,vri);
              end;
            end;
          end;
        end;
      end;
      FillRiz(slr); ClearSLR(slr);
    end;
    {$IFDEF STACKALL}DelStack;{$ENDIF}
  end;
var p: Pvarrec;
	oaGetVar: PArrVarRec;
  oiGetVar: longint;
begin
	AddStack('Tinter.GetVar');
  if nvar>0 then begin
    oiGetVar:=iGetVar; iGetVar:=0; SetLength(a,1000); oaGetVar:=aGetVar; aGetVar:=@a;
    if (name='') and (ivtTmpVar in VarTypes) then begin
      WriteRiz('$','Временные переменные',null);
      for j:=0 to MAXLVAR-1 do begin
        p:=@avar[j];
        if empty(p^.name) and empty(p^.hint) then continue;
        WriteRiz(p.name,p.hint,p.index,p.proc,p.types,p.ReadOnly);
      end;
    end;
    if ivtVar in VarTypes then begin
      if slFL<>nil then begin
        slr:=THSLList.Create;
        if name='' then for j:=0 to slFL.Count-1 do Add1
        else begin
          slFL.Find(name,j);
          if j<slFL.Count then
            if VarWithoutPrim(slFL[j])=name then Add1;
        end;
        slr.Destroy;
      end;
      if not(ivNoDop in Opt) then DopGetVar(name);
    end;
    SetLength(a,iGetVar); aGetVar:=oaGetVar; iGetVar:=oiGetVar;
  end;
  DelStack;
end;

class function Tinter.GetVar(var a: PArrVarRec): longint;
begin
  a:=@avar; result:=nvar;
end;

class function Tinter.GetFunction(var a: PArrFunc): longint;
begin
  AddStack('Tinter.GetFunction');
  a:=@afunc; result:=lafunc;
  DelStack;
end;

class function Tinter.GetFunction: PArrFunc;
begin
  GetFunction(result);
end;

class procedure Tinter.GetOperator;
const ac: array[1..MAXOPERFIX] of operrec =
	((                                     hint: 'Условные операторы и операторы цикла')
	,(help:5001;oplev: 1;name:sIF         ;hint: 'Выполнить блок операторов, если условие истинно')
	,(help:5001;oplev: 3;name:sELSE       ;hint: 'Выполнить блок операторов, если условие '+sIF+' ложно')
	,(help:5001;oplev: 2;name:sENDIF      ;hint: 'Конец блока операторов '+sIF)
	,(help:5002;oplev: 1;name:sWHILE      ;hint: 'Выполнять блок операторов, пока условие истинно')
	,(help:5002;         name:sCONT       ;hint: 'Выполнить блок операторов '+sWHILE+' с начала')
	,(help:5002;         name:sEXIT       ;hint: 'Выход из блока операторов '+sWHILE)
	,(help:5002;oplev: 2;name:sENDWHILE   ;hint: 'Конец блока операторов '+sWHILE)
	,(help:5003;oplev: 2;name:sEND        ;hint: 'Конец блока операторов '+sWHILE+', '+sIF+' или '+sCASES)
	,(help:5016;oplev: 1;name:sCASES      ;hint: 'Выбор из нескольких вариантов')
	,(help:5016;oplev: 3;name:sCASE       ;hint: 'Проверить один вариант из оператора '+sCASES)
	,(help:5015;                           hint: 'Оператор условной компиляции')
	,(help:5015;oplev: 1;name:sCommBeg+sUslComp+sIF+' '+sCommEnd; hint: 'Компилировать блок операторов, если условие истинно')
	,(help:5015;oplev: 3;name:sCommBeg+sUslComp+sELSE+sCommEnd; hint: 'Компилировать блок операторов, если условие '+sCommBeg+sUslComp+sIF+sCommEnd+' ложно')
	,(help:5015;oplev: 2;name:sCommBeg+sUslComp+sENDIF+sCommEnd; hint: 'Конец блока операторов '+sCommBeg+sUslComp+sIF+sCommEnd)
	,(help:5004;                           hint: 'Операторы присваивания')
	,(help:5004;         name:'=>'        ;hint: 'Оператор присвоения значения выражения к переменной (<Ctrl+"=">)')
	,(help:5004;         name:'+=>'       ;hint: 'Прибавить значение выражения к существующему значению переменной')
	,(help:5004;         name:'-=>'       ;hint: 'Вычесть значение выражения из существующего значения переменной')
	,(help:5004;         name:'*=>'       ;hint: 'Умножить существующее значение переменной на значение выражения')
	,(help:5004;         name:'/=>'       ;hint: 'Разделить существующее значение переменной на значение выражения')
	,(help:5005;                           hint: 'Операторы вычислений')
	,(help:5007;         name:'+'         ;hint: 'Сложение двух выражений')
	,(help:5007;         name:'-'         ;hint: 'Вычесть второе выражение из первого')
	,(help:5007;         name:'*'         ;hint: 'Умножение двух выражений')
	,(help:5007;         name:'/'         ;hint: 'Разделить первое выражение на второе (контроль деления на 0)')
	,(help:5007;         name:':'         ;hint: 'Разделить первое выражение на второе (без контроля деления на 0)')
	,(help:5006;         name:'++'        ;hint: 'Прибавить 1 к существующему значению переменной')
	,(help:5006;         name:'--'        ;hint: 'Вычесть 1 из существующего значения переменной')
	,(help:5008;                           hint: 'Логические операторы')
	,(help:5010;         name:'<'         ;hint: 'Меньше (<Ctrl+"<">)')
	,(help:5010;         name:'<='        ;hint: 'Меньше или равно')
	,(help:5010;         name:'>'         ;hint: 'Больше (<Ctrl+">">)')
	,(help:5010;         name:'>='        ;hint: 'Больше или равно')
	,(help:5010;         name:'=='        ;hint: 'Равно')
	,(help:5010;         name:'!='        ;hint: 'Не равно')
	,(help:5010;         name:'='         ;hint: 'Для строк: равны,если начало первой совпадает со второй')
	,(help:5010;         name:'И'         ;hint: 'Истинно, если оба условия истинны')
	,(help:5010;         name:'ИЛИ'       ;hint: 'Истинно, если одно из условий истинно')
	,(help:5009;         name:'!'         ;hint: 'Истинно, если условие ложно (и наоборот)')
	,(help:5011;                           hint: 'Операторы комментария')
	,(help:5011;oplev:-1;name:'*'         ;hint: 'Если в начале строки, то это строка комментария')
	,(help:5011;oplev:-1;name:'&&'        ;hint: 'Конец строки после && комментарий (<Ctrl+"&">)')
	,(help:5011;oplev:-1;name:sCommBeg    ;hint: 'В начале строки-последующие строки комментарий')
	,(help:5011;oplev:-1;name:sCommEnd    ;hint: 'В конце строки закрывает комментарий после '+sCommBeg)
	,(                                     hint: 'Прочие операторы')
	,(help:5012;         name:'ПАРАМЕТР'  ;hint: 'Задаёт список параметров')
	,(help:5013;         name:'ПЕРЕМЕННЫЕ';hint: 'Задаёт список временных переменных')
	,(help:5017;         name:'ХРАНИМЫЕ'  ;hint: 'Задаёт список хранимых переменных')
	,(                   name:'СТОП'      ;hint: 'Остановить выполнение и вывести текст текущего алгоритма')
	,(help:5018;         name:'СТРУКТУРА' ;hint: 'Задаёт описание структуры, заменяющей номера элементов массивов')
	,(help:5014;oplev:-1;name:'"'         ;hint: 'Открывающий и закрывающий оператор для строки')
	,(help:5014;oplev:-1;name:''''        ;hint: 'Открывающий и закрывающий оператор для строки')
	,(          oplev:-1;name:'('         ;hint: 'Открывающая круглая скобка')
	,(          oplev:-1;name:')'         ;hint: 'Закрывающая круглая скобка')
	,(          oplev:-1;name:','         ;hint: 'Запятая')
	,(          oplev:-1;name:'['         ;hint: 'Открывающая квадратная скобка (<Ctrl+"Х(рус)">')
	,(          oplev:-1;name:']'         ;hint: 'Закрывающая квадратная скобка (<Ctrl+"Ъ(рус)">')
	,(          oplev:-1;name:'{'         ;hint: 'Открывающая фигурная скобка (<Alt+"Х(рус)">')
	,(          oplev:-1;name:'}'         ;hint: 'Закрывающая фигурная скобка (<Alt+"Ъ(рус)">')
	,(          oplev:-1;name:'?'         ;hint: 'Вопросительный знак')
	,(          oplev:-1;name:'|'         ;hint: 'Вертикальный разделитель (<Ctrl+"|">)')
	,(                                     hint: 'Дополнительные операторы')
  );
var i: longint;
begin
	AddStack('Tinter.GetOperator');
  for i:=low(ac) to high(ac) do a[i]:=ac[i];
  for i:=1 to loperv do a[MAXOPERFIX+i]:=aoperv[i];
  l:=MAXOPERFIX+loperv;
  DelStack;
end;
function ident(const formula: string; var j: longint): string;
var c:char;first:boolean;
begin
	AddStack('inter.ident');
	result:='';
	first:=true;
	while j<=length(formula) do begin
		c:=formula[j];
		if IsChrWord(c) then begin
			if first and IsDigit(c) then break;
			first:=false; inc(j); IncD(result,c);
		end else begin
			break;
		end;
	end;
  DelStack;
end;
class function Tinter.SearchIdent;
var sid,sr1,frm:string;j,k:longint;
begin
	AddStack('Tinter.SearchIdent');
  sr1:=AnsiUpperCase(sr); result := Pos(sr1,AnsiUpperCase(formula))>0;
  if lIdent and result then begin
    result:=false; j:=1; frm:=formula;
    while j<=length(frm) do begin
      k:=j; sid:=ident(frm,k);
      if empty(sid) then inc(j)
      else if AnsiUpperCase(sid)=sr1 then begin
        result:=true; break;
      end
      else inc(j,length(sid));
    end;
  end;
  DelStack;
end;
class function Tinter.ReplaceIdent;
var sid,sr1,sfml:string;j,k:longint;
  mr: TModalResult;
begin
	AddStack('Tinter.ReplaceIdent');
	result:=0; j:=1; sr1:=AnsiUpperCase(sr); sfml:=AnsiUpperCase(formula);
  if IsPos(k,sr1,sfml) then
    if lIdent then
      while j<=length(formula) do begin
        k:=j; sid:=ident(formula,k);
        if empty(sid) then inc(j)
        else begin
          if AnsiUpperCase(sid)=sr1
          then mr:=ReplaceProc(PrRepl,pav,[formula,j],result)
          else mr:=mrNo;
          case mr of
            mrCancel: break;
            mrYes: begin
              StuffStrSelf(formula,j,length(sr1),srep); inc(j,length(srep));
            end;
          else inc(j,length(sid));
          end;
        end;
      end
    else
      while k>0 do begin
        mr:=ReplaceProc(PrRepl,pav,[formula,j+k-1],result);
        if mr=mrCancel then break
        else begin
          if mr=mrYes then begin
            StuffStrSelf(formula,j+k-1,length(sr1),srep);
            sfml:=AnsiUpperCase(formula); Inc(j,k+length(srep)-1);
          end
          else Inc(j,k);
          k:=Pos(sr1,Copy(sfml,j,MaxInt));
        end;
      end;
  DelStack;
end;

class procedure Tinter.FormatStr(const a: TArrStr; l: longint);
var i,j,k,l1:longint;
  nstiwa,sm:smallint;
  formula,ckey :string;
  a1: TArrStr;
begin
	AddStack('Tinter.FormatStr');
  i:=0; nstiwa:=0; a1:=nil;
  while i<l do begin
    sm:=nstiwa; formula:=trim(a[i]);
    if (length(formula)=0) or (formula[1]='*') or AnsiStartsStr(sCommBeg+sUslComp,formula) then begin
      a[i]:=formula;
      if ACompStr(formula,[sCommBeg+sUslComp,sIF]) then begin
        if Length(a1)=0 then SetLength(a1,l);
        l1:=0;
        a1[l1]:=formula; inc(i); Inc(l1); k:=i;
        while (i<l) and (RightStr(formula,lCommEnd)<>sCommEnd) do begin
          formula:=trim(a[i]); a1[l1]:=formula; inc(i); Inc(l1);
        end;
        FormatStr(a1,l1);
        for l1:=1 to l1-1 do begin
          a[k]:=a1[l1]; Inc(k);
        end;
      end
      else inc(i);
      continue;
    end;
    j:=1;
    ckey:=ident(formula,j);
    j:=1;
    while j<=loperv do begin
      if (aoperv[j].name=ckey) then begin
         break;
      end;
      inc(j);
    end;
    if j<=loperv then begin
      j:=aoperv[j].oplev;
      if j=1 then begin
        inc(nstiwa);
      end;
      if j=2 then begin
        dec(nstiwa);
        sm:=nstiwa;
      end;
      if j=3 then begin
        sm:=nstiwa-1;
      end;
      ckey:='';
    end;
    if AnsiMatchStr(ckey,[sIF,sWHILE,sCASES])
      then inc(nstiwa)
    else if AnsiMatchStr(ckey,[sELSE,sCASE])
      then sm:=nstiwa-1
    else if AnsiMatchStr(ckey,[sEND,sENDIF,sENDWHILE]) then begin
      dec(nstiwa); sm:=nstiwa;
    end;
    a[i]:=space(I_TAB*max(0,sm))+formula;
    inc(i);
  end;
  DelStack;
end;

class function Tinter.FormatStr(const s: string): string;
var a: TArrStr;
  l: longint;
begin
  l:=LsArrDynamic(s,a,CRLF); FormatStr(a,l); result:=ArrayAsList(a,CRLF,l);
end;

class function Tinter.SeekVar(const name: string; pi: PLongInt = nil): varrec;
var i: longint;
begin
  AddStack('Tinter.SeekVar');
  PointerDef(pointer(pi),@i);
  if SeekVar(name,pi^) then begin
  	result:=avar[pi^-1]; LeftSelfDel(result.hint,idShapeHint);
  end
  else result.name:='';
  DelStack;
end;

class function Tinter.SeekVar(const name: string; var i: LongInt): boolean;
begin
  result:=FindVar(name,i,[fvShapeFull,fvShapeCheck]);
end;

class function Tinter.SetVarValue;
var i: longint;
begin
  AddStack('Tinter.SetVarValue');
  if SeekVar(name,i) then result:=VarProc(i,v,lSave) else result:=null;
  DelStack;
end;

class function TInter.GetVarValue(const name: string): variant;
begin
  result:=SetVarValue(name,null,false);
end;

class function TInter.GetVarValue(const name: string; vType: longint; var v: variant): boolean;
begin
  v:=GetVarValue(name); result := MyVarType(v)=vType;
end;

class function TInter.VarProc;
var ovf: TInterCurVF;
{$IFDEF PROFINTER}
  oEvalName: string;
  fl: boolean;
{$ENDIF}
begin
  ovf:=SetCurVF(modeVar,i);
  try
{$IFDEF PROFINTER}
    with avar[i-1] do begin
      fl := Length(name)>0;
      if fl then InterProfBeg(name,oEvalName);
      try
{$ENDIF}
        if i>MAXLVAR then with avar[i-1] do result:=proc(v,index,lSave)
        else if i>MAXLVAR1 then begin
          Dec(i,MAXLVAR1+1);
          if lSave then CurInter.IntStatVar.ast[i]:=v;
          result:=CurInter.IntStatVar.ast[i];
        end
        else begin
          if lSave then avp[CurInter.nvp,1,i]:=v;
          result:=avp[CurInter.nvp,1,i];
        end;
{$IFDEF PROFINTER}
      finally
        if fl then InterProfEnd(oEvalName);
      end;
    end;
{$ENDIF}
  finally
    SetCurVF(ovf);
  end;
end;

procedure Tinter.Assign;
var i: longint;
begin
  AddStack('Tinter.Assign');
  showerror:=Source.showerror; name:=Source.name; value_types:=Source.value_types;
  fl_compile:=Source.fl_compile; GetAlgProc:=Source.GetAlgProc; GetAlgPrm:=Source.GetAlgPrm;
  IntStatVar:=Source.IntStatVar; lsStruct.Assign(Source.lsStruct);
  SetLength(listcom,Length(Source.listcom));
  for i:=low(listcom) to high(listcom) do listcom[i]:=Source.listcom[i];
  DelStack;
end;

class function Tinter.SeekFunction;
var i: longint;
  name: string;
begin
  AddStack('Tinter.SeekFunction');
	result.name:=''; name:=TrimUpper(cname);
  for i:=1 to lafunc do if TrimUpper(afunc[i].name)=name then begin
    result:=afunc[i]; break;
  end;
  DelStack;
end;

{class function Tinter.SeekOperator;
var i: longint;
  name: string;
begin
	result.name:=''; name:=TrimUpper(cname);
  for i:=1 to loperv do
		if TrimUpper(aoper[i].name)=name then begin
    	result:=aoper[i]; break;
    end;
end;}

class function TInter.HelpFile(const v: varrec): THelpFile;
begin
  result:=HelpFile(v.name);
end;

class function TInter.HelpFile(const name: string): THelpFile;
var a: TNamePrimStr;
  i,n: longint;
  hlpfile: string;
begin
  AddStack('TInter.HelpFile(var)');
  GetVarHelp(name,n);
  with aVarHelp[n] do a:=StrDivDlm('.',DlmBetween(hlpfile,hlpname,'.'));
  if AnsiStartsText(sHelpTblVar,name) then if FindVar(name,i) then begin
    a:=NamePrimStr(Int2Str(hlnkTblFix),HelpTblVarName(Copy(name,Length(sHelpTblVar)+1,MaxInt)));
    hlpfile:=ArrayAsList(a,'.');
    if n=0 then SetVar(name,0,hlpfile) else aVarHelp[n].hlpfile:=hlpfile;
  end;
  rHelpFile(result,a[1],IfThen((Int0(a[1])=0) and (Pos('.',a[2])=0),'Var.')+IfThen(a[2]='',name,a[2]));
  DelStack;
end;

class function TInter.HelpFile(const f: funcrec): THelpFile;
begin
  AddStack('TInter.HelpFile(func)');
  rHelpFile(result,f.hlpfile,'Func.'+IfThen(f.name='',f.hint,f.name));
  DelStack;
end;

class function TInter.HelpFile(const o: operrec): THelpFile;
begin
  AddStack('TInter.HelpFile(oper)');
  rHelpFile(result,o.hlpfile,'Oper.'+ReplVar(o.nmhelp,o.name));
  DelStack;
end;

{ TVarDopList }
constructor TVarDopList.Create;
begin
  AddStack('TVarDopList.Create');
  SetLength(avi,100); lvi:=0;
  DelStack;
end;

destructor TVarDopList.Destroy;
var i: longint;
begin
  AddStack('TVarDopList.Destroy');
  for i:=0 to lvi-1 do with avi[i] do begin
    name:=''; hint:=''; types:=''; 
  end;
  inherited Destroy;
  DelStack;
end;

procedure TVarDopList.AddDop;
begin
  AddStack('TVarDopList.AddDop');
  avi[lvi].name:=Name; avi[lvi].hint:=hint; avi[lvi].types:=types; Inc(lvi);
  if lvi=Length(avi) then SetLength(avi,lvi shl 1);
  DelStack;
end;

procedure TVarDopList.PrInterDopGetVar;
var i: longint;
begin
  AddStack('TVarDopList.PrInterDopGetVar');
  for i:=0 to lvi-1 do with avi[i] do ProcDopGetVarAdd(name,hint,types);
  DelStack;
end;

{ TFuncPartList }
function TFuncPartList.AddObject;
var sf: string;
begin
  AddStack('TFuncPartList.AddObject');
  if Sorted then sf:=GetName(AObject) else sf:='';
  result:=inherited AddObject(sf,AObject);
  DelStack;
end;

function TFuncPartList.GetName;
var nFile: longint;
  fr: funcrec;
begin
  AddStack('TFuncPartList.GetName');
  fr:=TInter.GetFunction[longint(AObject)];
  with fr do
    if help=0
    then result:=TInter.HelpFile(fr).sPage
    else HelpMapFind(help,nFile,result);
  DelStack;
end;

function EvalStrings(const s,capt:string; const ResultType: string = ''; EvalRaise: boolean = false): variant;
begin
  result:=EvalStrings([0],s,capt,ResultType,EvalRaise);
end;

function EvalStrings(const ap:array of variant; const s,capt:string; const ResultType: string = ''; EvalRaise: boolean = false): variant;
begin
	AddStack('Inter.EvalStrings');
  with Tinter.create(capt) do
    try
      value_types:=ResultType; FEvalRaise:=EvalRaise; SetProg(s); result:=eval(ap); IntLastError:=error; 
    finally
      Free;
    end;
  DelStack;
end;

function EvalStringsChk(const ap:array of variant; const s,capt:string; const ResultType: string = ''; EvalRaise: boolean = false): boolean;
begin
  EvalStrings(ap,s,capt,ResultType); result := IntLastError=E_NO;
end;

function EvalStringsChk(var v: variant; const s,capt:string; const ResultType: string = ''; EvalRaise: boolean = false): boolean;
begin
  v:=EvalStrings(s,capt,ResultType,EvalRaise); result := IntLastError=E_NO;
end;

function EvalStringsChk(var v: variant; const ap:array of variant; const s,capt:string; const ResultType: string = ''; EvalRaise: boolean = false): boolean;
begin
  v:=EvalStrings(ap,s,capt,ResultType,EvalRaise); result := IntLastError=E_NO;
end;

// Константы
function i_const(const v,ind: variant; lSave: boolean): variant;
begin
	AddStack('Inter.i_const');
	result:=ind;
	if lSave then raise EInterConstException.create;
  DelStack;
end;

function i_const(const ind: variant; lSave: boolean): variant;
begin
  result:=i_const(null,ind,lSave);
end;

procedure i_constSelf;
begin
  ind:=i_const(ind,lSave);
end;

function i_hlpfile(const v,ind: variant; lSave: boolean): variant;
begin
  AddStack('Inter.i_hlpfile');
  result:=i_const(HelpBaseFile,lSave);
  DelStack;
end;

function i_naadd(const v,ind: variant; lSave: boolean): variant;
begin
  AddStack('Inter.i_naadd');
  result:=i_const(nAAdd,lSave);
  DelStack;
end;

// ТЕК_ДАТА
function d_Now(const v,ind: variant; lSave: boolean): variant;
begin
	AddStack('Inter.d_Now');
  result:=i_const(Now,lSave);
  DelStack;
end;

// ТЕК_ВРЕМЯ
function d_Time(const v,ind: variant; lSave: boolean): variant;
begin
	AddStack('Inter.d_Time');
  result:=i_const(FormatDateTime('hh:nn:ss:zzz',Now),lSave);
  DelStack;
end;

function FmtPrm(n: longint; const v: variant): variant;
var l: longint;
begin
  AddStack('Inter.FmtPrm');
  if n>0 then begin
    l:=Length(sfmt);
    if l<n then begin
      SetLength(sfmt,n); InitArr(sfmt,l,n-1,'');
    end;
    Dec(n); result:=sfmt[n]; l:=MyVarType(v);
    if l<>V_NULL then case l of
      varInteger: sfmt[n]:=Spacestr0(v,15);
      varDouble: sfmt[n]:=Spacestr0(v,15,2);
      varDate: sfmt[n]:=dtoc(v);
      varBoolean: sfmt[n]:=bRus2Str(v);
    else sfmt[n]:=v;
    end;
  end
  else result:='';
  DelStack;
end;

function FmtPrm(n: longint): variant;
begin
  result:=FmtPrm(n,null);
end;

function i_itogo;
begin
	AddStack('Inter.i_itogo');
	nline:=MaxNline; result:=av[1];
  DelStack;
end;

function i_stat(var av: array of variant): variant;
var i,l,h: longint;
	ap: TArrVar;
  a: TArrStr;
  v: variant;
begin
	AddStack('Inter.i_stat');
  SetLength(ap,Length(av)-4);
  for i:=low(ap) to high(ap) do ap[i]:=av[i+4];
  v:=av[2]; i:=MyVarType(v);
  if IsNil(av[1]) and (i=V_NULL) then result:=InterProcStat(ap)
  else begin
    IsNil(av[1],''); IsNil(av[3],true);
    if i=V_NULL then result:=not ShowStat(av[1],TNone.PrStat,ap,av[3])
    else begin
      if i=varArray then begin
        l:=VarArrayLowBound(v,1); h:=VarArrayHighBound(v,1); SetLength(a,h-l+1); i:=low(a);
        while l<=h do begin
          a[i]:=v[l]; Inc(l); Inc(i);
        end;
      end
      else begin
        SetLength(a,1); a[low(a)]:=v;
      end;
      result:=mess_wait(a,TNone.PrWait,ap,av[3],av[1]);
    end;
  end;
  DelStack;
end;

class procedure TNone.PrStat;
begin
  AddStack('TNone.PrStat');
  InterProcStat(Sender.Params,'',Sender);
  DelStack;
end;

class procedure TNone.PrWait;
begin
  AddStack('TNone.PrWait');
  InterProcStat(Sender.Params,'',Sender);
  DelStack;
end;

function i_sleep(var av: array of variant): variant;
begin
  Sleep(av[1]);
end;

{$IFDEF PROF}
class procedure TNone.Prof;
begin
  TKeyLb.FixKeyShow(Key,false); FProf(''); TKeyLb.FixKeyShow(Key,true);
end;
{$ENDIF}

function MessagesDbgCaption;
begin
  AddStack('Inter.MessagesDbgCaption');
  if true in MessagesOkHidden then result:=Caption else result:=DlmBetween(Caption,'('+CurInter.name+')',' ');
  DelStack;
end;

function InterTmpVarPrefNoCor;
var a: TNamePrimStr;
begin
  AddStack('Inter.InterTmpVarPrefNoCor');
  if StrDivDlm('_',nmv,a) then result := lsPref.IndexOf(a[1]+'_')>=0 else result:=false;
  DelStack;
end;

procedure Init;
const
  acl: array[T16Colors] of string =
    ('ЧЕРНЫЙ','','','','','','','','','','','','','','','',
    'ПРОКРУТ','РАБ_СТОЛ','ОКНО_АКТ_ФОН','ОКНО_НЕАКТ_ФОН','МЕНЮ_ФОН','ОКНО_ФОН','ОКНО_РАМКИ',
    'МЕНЮ_ТЕКСТ','ОКНО_ТЕКСТ','ОКНО_АКТ_ТЕКСТ','ОКНО_АКТ_ГРАН','ОКНО_НЕАКТ_ГРАН',
    'РАБ_ОБЛАСТЬ','ВЫДЕЛ_ФОН','ВЫДЕЛ_ТЕКСТ','КНОПКА_ФОН','КНОПКА_ТЕНЬ','ТЕКСТ_НЕАКТ',
    'КНОПКА_ТЕКСТ','ОКНО_НЕАКТ_ТЕКСТ','КНОПКА_ЯРК','ОСН_ФОН','ИНФ_ТЕКСТ','ИНФ_ФОН');
  aadr: array[TAdr1List] of TNamePrimStr =
    (('АДР_РЕГКОД' ,'Код региона')
    ,('АДР_СПРНП'  ,'Справочник населённых пунктов')
    ,('АДР_СПРУЛ'  ,'Справочник улиц')
    ,('АДР_СТРАНА' ,'Код страны')
    ,('АДР_ИНДЕКС' ,'Индекс')
    ,('АДР_РЕГНАИМ','Регион')
    ,('АДР_РАЙОН'  ,'Район')
    ,('АДР_ГОРОД'  ,'Город')
    ,('АДР_НП'     ,'Населённый пункт')
    ,('АДР_УЛИЦА'  ,'Улица')
    ,('АДР_ДОМ'    ,'Дом')
    ,('АДР_КОРПУС' ,'Корпус')
    ,('АДР_КВ'     ,'Квартира')
    ,('АДР_ФИАСДОМ','Код ФИАС (учёт дома)')
    ,('АДР_ФИАС'   ,'Код ФИАС')
    );
  aCharCase: array[TDECharCase] of TNamePrimStr =
    (('СИМВ_НЕТ'    ,'Не преобразовывать символы')
    ,('СИМВ_БОЛЬШИЕ','Преобразовывать символы в большие')
    ,('СИМВ_МАЛЫЕ'  ,'Преобразовывать символы в малые')
    );
  aVarCapt: TArrBoolStr = ('ложное','истиное');
  aHelpLinkVar: array[THelpLinkList] of record
    v,nm: string
  end =
    (()
    ,(v:'ПЕРЕМ'; nm:'Раздел переменных')
    ,(v:'МАС'  ; nm:'Таблица, определённая массивом')
    ,(v:'ВВОД' ; nm:'Параметры видов ввода')
    ,(v:'ТБЛ'  ; nm:'Таблица, определённая переменной ПМТБЛ_...')
    ,(v:'АЛГ'  ; nm:'Элементы алгоритмов')
    ,(v:'ФРМЛ' ; nm:'Дополнительные формулы')
    {для ПМ_ВЫД(,,Вид) добавлять сюда}
    ,()
    ,()
    ,()
    );
  asPdg: TPdgStr = ('Кто? Что?','Кого? Чего?','Кому? Чему?','Кого? Что?','Кем? Чем?','О ком? О чем?');
type TAltList = 1..4;
var i: T16Colors;
	s: string;
  j,k,p1,p2: longint;
  n,l: TAltList;
  n1: TAdr1List;
  a,af: array[TAltList] of string;
  an: array[TAltList] of byte;
  bi: TBuiltInList;
  cc: TDECharCase;
  fl: boolean;
  hl: THelpLinkList;
begin
	AddStack('Inter.initialization');
	aprior[O_MUL     ]:=2;
	aprior[O_DIV     ]:=2;
	aprior[O_DIV0    ]:=2;
	aprior[O_PLUS    ]:=4;
	aprior[O_SUB     ]:=4;
	aprior[O_S       ]:=6;
	aprior[O_SE      ]:=6;
	aprior[O_L       ]:=6;
	aprior[O_LE      ]:=6;
	aprior[O_NE      ]:=8;
	aprior[O_E       ]:=8;
	aprior[O_EP      ]:=8;
	aprior[O_AND     ]:=10;
	aprior[O_OR      ]:=12;
{унарные}
	aprior[O_MIN     ]:=0;
	aprior[O_NO      ]:=0;
	aprior[O_UPLUS   ]:=0;
	aprior[O_PLUSPLUS]:=0;
	aprior[O_MINMIN  ]:=0;
	aprior[O_TR      ]:=20;
	aprior[O_TRPLUS  ]:=20;
	aprior[O_TRMIN   ]:=20;
	aprior[O_TRMUL   ]:=20;
	aprior[O_TRDIV   ]:=20;
	aprior[O_TRDIV0  ]:=20;

  lsVarHelp:=SortStrListCreate; SetLength(aVarHelp,10); lsVarHelp.Add(''); Finalize(aVarHelp[0]);
  lsPref:=SortStrListCreate; New(aGetVar);
  for bi:=low(aBuiltIn) to high(aBuiltIn) do with aBuiltIn[bi],aBuiltInProc[bi] do begin
    InitArr(af);
    LsArrDynamic(PrmType,aPrmType,'^',lsaSetLen);
    LsArrDynamic(PrmPrim,aPrmPrim,'^',lsaSetLen); k:=low(aPrmPrim);
    while k<=high(aPrmPrim) do begin
      l:=ListAsArray(aPrmPrim[k],a,'~');
      for n:=1 to l do if IsPos(p1,'%d',a[n]) then begin
        SetLength(aPrmPrim,MAX_PRM); Inc(p1,2); p2:=p1;
        while p2<=Length(a[n]) do
          if IsDigit(a[n][p2]) then Inc(p2) else break;
        Dec(p2,p1);
        an[n]:=Int0(Copy(a[n],p1,p2)); af[n]:=StuffString(a[n],p1,p2,''); p1:=Length(aPrmType);
        if p1<MAX_PRM then begin
          SetLength(aPrmType,MAX_PRM);
          if p1=0 then s:='' else s:=aPrmType[p1-1];
          while p1<MAX_PRM do begin
            aPrmType[p1]:=s; Inc(p1);
          end;
        end;
      end;
      for n:=low(af) to high(af) do
        if af[n]<>'' then begin
          Inc(an[n]); a[n]:=Format(af[n],[an[n]]); l:=max(l,n);
        end;
      aPrmPrim[k]:=ArrayAslist(a,'~',l); Inc(k);
    end;
  end;

	with TInter do begin
    setvar('$const',svConst);
    for fl:=false to true do setvar(bVar[fl],'Абсолютное '+aVarCapt[fl]+' значение',i_const,fl,'L',true);
    setvar('NIL','',i_const,null,'',true);
    setvar('DateBig','',i_const,DateBig,'D',true);
    setvar('TimeZoneBias','',i_const,TimeZoneBias,'C',true);
    setvar('ДАТА_МАКС','Наибольшая дата',i_const,DateBig,'D',true);
    setvar('ПЕРЕВОД_СТРОКИ','',i_const,CRLF,'C',true);
    setvar('$$case','СИМВ_','Преобразование символов');
    for cc:=low(aCharCase) to high(aCharCase) do
      setvar(aCharCase[cc,1],aCharCase[cc,2],i_const,cc,'I',true);
    setvar('$$vartype','ТИП_','Типы данных');
    setvar('ТИП_ДАТА','Тип даты',i_const,V_DATE,'I',true);
    setvar('ТИП_ДРОБНОЕ','Числовой дробный тип',i_const,V_FLOAT,'I',true);
    setvar('ТИП_ПУСТО','Неопределённый тип',i_const,V_NULL,'I',true);
    setvar('ТИП_ЛОГ','Логический тип',i_const,V_BOOL,'I',true);
    setvar('ТИП_МАССИВ','Тип массива',i_const,varArray,'I',true);
    setvar('ТИП_СТР','Строковый тип',i_const,V_STRING,'I',true);
    setvar('ТИП_ЦЕЛОЕ','Числовой целый тип',i_const,V_INT,'I',true);
    setvar('$$color','ЦВЕТ_','Цвета');
    for i:=low(ANmColor) to high(ANmColor) do begin
      s:=acl[i];
      if s='' then s:=StrTran(AnsiUpperCase(ANmColor[i]),'-','_');
      setvar('ЦВЕТ_'+s,ANmColor[i],i_Const,i,'I',true);
    end;
    SetVar('$$adr','АДР_','Части адреса');
    for n1:=low(aadr) to high(aadr) do SetVar(aadr[n1,1],aadr[n1,2]
      +IfThen((aFld1CDAdr[n1]<>acdNone) or (aAbr1Beg[false,n1]<>''),
      ' (префикс '+IfThen(aAbr1Beg[false,n1]='','соотв. справочнику','"'+aAbr1Beg[false,n1]+'"')+')'),
      i_const,n1,'I',true);
    SetVar('$$help',cHlpVarPref,'Помощь');
    SetVar('ПМ_ОСНФАЙЛ','Имя основного файла помощи',i_hlpfile,null,'С',true,0,HelpFileStd);
    SetVar('$$$helpword','Шрифты');
    for j:=low(aHelpStyle) to high(aHelpStyle) do with aHelpStyle[j] do
      if v<>'' then SetVar(cHlpVarPref+v,nm,i_const,j,'I',true);
    SetVar('$$$helplink','Виды ссылок');
    for hl:=low(aHelpLinkVar) to high(aHelpLinkVar) do with aHelpLinkVar[hl] do
      if v<>'' then SetVar(cHlpVarPref+v,nm,i_const,hl,'I',true);
    SetVar('$$pdg','ПАДЕЖ_',svPdg);
    for i:=low(aPdgName) to high(aPdgName) do
      SetVar(aPdgVar[i],FRup(aPdgName[i])+' ('+asPdg[i]+')',i_const,i,'I',true);

    setvar('$varr','Массивы');
    SetVar('МАС_ДОБНОМЕР','Номер элемента массива, добавленного функцией МАС_ДОБАВИТЬ()',i_naadd,null,'I',true,0,HelpFileStd);

    setvar('$vglob','Переменные');
    SetVar('ТЕК_ДАТА','Текущая дата',d_Now,0,'D',true);
    SetVar('ТЕК_ВРЕМЯ','Текущее время: строка в виде "ЧЧ:ММ:СС:ТТТ"(Ч-часы,М-мин.,С-сек.,Т-миллисек.)',d_Time,0,'C',true);

    SetFunction('Строки',100);
    SetFuncBuiltIn(biReplicate,'Повторить строку указанное количество раз',101,'C');
    SetFuncBuiltIn(biCopy,'Часть строки',102,'C');
    SetFuncBuiltIn(biZpp,'Заменить пробелы символом "_"',103,'C');
    SetFuncBuiltIn(biZppl,'Дополняет строку слева символом "_"',104,'C');
    SetFuncBuiltIn(biZppr,'Дополняет строку справа символом "_"',105,'C');
    SetFuncBuiltIn(biZppc,'Центрирует строку и заменяет пробелы символом "_"',106,'C');
    SetFuncBuiltIn(biUpper,'Преобразование символов строки в большие',107,'C');
    SetFuncBuiltIn(biFrup,'Преобразование первого символа строки в большой',108,'C');
    SetFuncBuiltIn(biLower,'Преобразование символов строки в малые',109,'C');
    SetFuncBuiltIn(biDelTrim,'Сжимает строку за счёт повторяющихся пробелов',110,'C');
    SetFuncBuiltIn(biTrimLeft,'Убирает в строке левые пробелы',111,'C');
    SetFuncBuiltIn(biTrimRight,'Убирает в строке правые пробелы',112,'C');
    SetFuncBuiltIn(biTrim,'Убирает в строке левые и правые пробелы',113,'C');
    SetFuncBuiltIn(biPadl,'Дополняет строку слева символом',114,'C');
    SetFuncBuiltIn(biPadr,'Дополняет строку справа символом',115,'C');
    SetFuncBuiltIn(biPadc,'Центрирует строку и дополняет её слева и справа символом',116,'C');
    SetFuncBuiltIn(biStr,'Переводит число в строку',117,'C');
    SetFuncBuiltIn(biNumStr,'Переводит число в строку с нулями',118,'C');
    SetFuncBuiltIn(biListAsArray,'Преобразует строку с разделителями в массив',119,'A');
    SetFuncBuiltIn(biStrFind,'Поиск/замена в строке',120,'IC');
    SetFuncBuiltIn(biSastolin,'Разбить строку на указанное количество строк указанной длины',121,'C');
    SetFuncBuiltIn(biSnastolin,'Часть разбитой строки с указанным номером',122,'C');
    SetFuncBuiltIn(biCenaProp,'Сумма или количество прописью',123,'C');
    SetFuncBuiltIn(biWinToDos,'Переводит строку из кодировки WINDOWS в кодировку DOS',124,'C');
    SetFuncBuiltIn(biDosToWin,'Переводит строку из кодировки DOS в кодировку WINDOWS',125,'C');
    SetFuncBuiltIn(biStuff,'Замена указанного места в строке на другую строку',126,'C');
    SetFuncBuiltIn(biSetByte,'Отметка позиции в строке или числе',127,'LCI');
    SetFuncBuiltIn(biGetByteArr,'Возвращает массив с номерами отмеченных позиций в строке','A');
    SetFuncBuiltIn(biOrd,'Возвращает числовой код символа',128,'I');
    SetFuncBuiltIn(biChr,'Возвращает символ, соответствующий числовому коду',129,'C');
    SetFuncBuiltIn(biEqualShape,'Возвращает признак соответствия строки шаблону',130,'L');
    SetFuncBuiltIn(biFmtPrm,'Параметр форматированной строки',131,'C');
    SetFuncBuiltIn(biFmtStr,'Возвращает форматированную строку',132,'C');
    SetFuncBuiltIn(biFmtClr,'Устанавливает все параметры форматированной строки равными пустой строке');
    SetFuncBuiltIn(biArrayAsList,'Преобразует массив в строку с разделителями',133,'C');
    SetFuncBuiltIn(biDlmBetween,'Возвращает строки с разделителем между ними',134,'C');
    SetFuncBuiltIn(biDlmCopy,'Подстрока из строки с разделителями',135,'C');
    SetFuncBuiltIn(biDigRoman,'Перевод числа в строку с римскими цифрами',136,'C');
    SetFuncBuiltIn(biTrimMemoStr,'Убирает в строке символы перевода строки',137,'C');
    SetFuncBuiltIn(biStrMask,'Заменяет управляющие символы в маске на символы источника',138,'C');
    SetFuncBuiltIn(biIntToHex,'Переводит целое в 16-ричную строку',139,'C');
    SetFuncBuiltIn(biTransLit,'Преобразование символов одного языка в другой',140,'C');
    SetFuncBuiltIn(biWinToUtf8,'Переводит строку из кодировки WINDOWS в кодировку UTF-8','C');
    SetFuncBuiltIn(biUtf8ToWin,'Переводит строку из кодировки UTF-8 в кодировку WINDOWS','C');
    SetFuncBuiltIn(biPadegFIO,'Склонение фамилии, имени, отчества','C');
    SetFuncBuiltIn(biPadegPodr,'Склонение подразделения','C');
    SetFuncBuiltIn(biPadegDolg,'Склонение должности','C');
    SetFuncBuiltIn(biPartsFIO,'Преобразование строки в фамилию, имя, отчество','A');

    SetFunction('Числа',200);
    SetFuncBuiltIn(biMRound,'Округлить число с указанной точностью',201,'F');
    SetFuncBuiltIn(biPrc,'Процент от суммы','F');
    SetFuncBuiltIn(biTrunc,'Выделяет целую часть числа',202,'I');
    SetFuncBuiltIn(biFloat0,'Переводит строку в число',203,'F');
    SetFuncBuiltIn(biMax,'Максимум из двух чисел или дат или номер максимального элемента массива',204,'FD');
    SetFuncBuiltIn(biMin,'Минимум из двух чисел или дат или номер минимального элемента массива',205,'FD');
    SetFuncBuiltIn(biAbs,'Абсолютная величина числа',206,'F');
    SetFuncBuiltIn(biDiv,'Целочисленное деление',207,'I');
    SetFuncBuiltIn(biMod,'Остаток от целочисленного деления',208,'I');
    SetFuncBuiltIn(biRandom,'Случайное число в указанных пределах',209,'I');

    SetFunction('Даты',300);
    SetFuncBuiltIn(biEoy,'Возвращает 31 декабря года указанной даты',301,'D');
    SetFuncBuiltIn(biBoy,'Возвращает 1 января года указанной даты',302,'D');
    SetFuncBuiltIn(biYear,'Возвращает год даты',303,'I');
    SetFuncBuiltIn(biDay,'Возвращает день даты',304,'I');
    SetFuncBuiltIn(biMonth,'Возвращает месяц даты',305,'I');
    SetFuncBuiltIn(biOurDtoc,'Дата в виде "1 февраля 1995г."',306,'C');
    SetFuncBuiltIn(biDtoc,'Дата цифрами',307,'C');
    SetFuncBuiltIn(biEom,'Возвращает конец месяца указанной даты',308,'D');
    SetFuncBuiltIn(biBom,'Возвращает начало месяца указанной даты',309,'D');
    SetFuncBuiltIn(biOurMtoc,'Дата в виде "февраль 1995г." или "февраль"',310,'C');
    SetFuncBuiltIn(biPerNToMes,'Период в месяцах для документов','C');
    SetFuncBuiltIn(biIncMonth,'Добавляет к дате указанное количество месяцев',311,'D');
    SetFuncBuiltIn(biCtod,'Переводит значение в дату',312,'D');
    SetFuncBuiltIn(biDton,'Разность в месяцах между датами',313,'I');
    SetFuncBuiltIn(biDtos,'Дата в виде "19950201"',314,'C');
    SetFuncBuiltIn(biDecodeDateTime,'Переводит дату/время в массив {год,мес,день,час,мин,сек,мсек}',315,'C');
    SetFuncBuiltIn(biDayOfWeek,'Номер дня недели (1-пн, 2-вт и т.д.)',316,'I');

    SetFunction('Массивы',400);
    SetFuncBuiltIn(biArray,'Возвращает массив указанной размерности',401,'A');
    SetFuncBuiltIn(biAIns,'Вставляет в массив один элемент',402,'A');
    SetFuncBuiltIn(biAAdd,'Добавляет в конец массива один элемент',403,'A');
    SetFuncBuiltIn(biADel,'Удаляет из массива один элемент',404,'A');
    SetFuncBuiltIn(biAScan,'Поиск выражения в массиве',405,'I');
    SetFuncBuiltIn(biAddArr,'Сложение нескольких массивов',406,'A');
    SetFuncBuiltIn(biAddEnd,'Дополнить массив выражением до указанной длины',407,'A');
    SetFuncBuiltIn(biAFill,'Заполнить массив выражением',408,'A');
    SetFuncBuiltIn(biARaspr,'Распределить сумму пропорционально элементам массива',409,'A');
    SetFuncBuiltIn(biAIf,'Выбор значения из массива',410,'*');
    SetFuncBuiltIn(biASort,'Сортировка массива',411,'A');
    SetFuncBuiltIn(biASub,'Часть массива с указанного элемента указанной длины',412,'A');
    SetFuncBuiltIn(biAVal,'Элемент массива с указанным номером',413,'*');
    SetFuncBuiltIn(biADef,'Преобразует значение в массив, если оно не является массивом','A');

    SetFunction('Прочие',800);
    SetFuncBuiltIn(biIif,'Значение одного из двух выражений по условию',801,'*');
    SetFuncBuiltIn(biLen,'Длина строки или массива',802,'I');
    SetFunction('ИТОГО','Возвращает значение и прерывает выполнение',['[Результат: любое]'],[''],
      i_itogo,null,803);
    SetFuncBuiltIn(biEmpty,'Определяет, пустое ли выражение',804,'L');
    SetFuncBuiltIn(biRun,'Запуск на выполнение другой программы',805);
    SetFuncBuiltIn(biVarType,'Тип выражения (см. константы "ТИП_...")',806,'I');
    SetFuncBuiltIn(biPrm,'Возвращает значение параметра с указанным номером',807,'*');
    SetFuncBuiltIn(biMDLoad,'Добавить запись в справочник из основы',808,'L');
    SetFuncBuiltIn(biHelpStr,'Выделить строку на странице помощи','CAL');
    SetFuncBuiltIn(biSaveIni);
    SetFuncBuiltIn(biKeyLb);
    SetFunction(FuncProfRename,'',['Наим: строка'],['C'],nil,null);
    SetFunction('Sleep','',['МиллиСекунд: целое'],['N'],i_sleep,null);
    SetFuncBuiltIn(biPDF417,'Вызов модуля печати машиночитаемых форм','L');
    SetFuncBuiltIn(biLogWrite,'Записать информацию в журнал действий');
    SetFuncBuiltIn(biSpCopy,'Скопировать значения в списках из одного ключа в другой');
    SetFuncBuiltIn(biArrDebug,'Преобразовать одномерный массив в двумерный для просмотра при отладке','A');
    SetFuncBuiltIn(biPriv,'Права пользователей','L');
    SetFuncBuiltIn(biTabu,'Дополнительные права пользователей','AL');
    SetFuncBuiltIn(biStruct,'Массив наименований структуры','A');
    SetFuncBuiltIn(biInRange,'Признак вхождения значения в указанные границы или пересечения диапазонов значений','L');
    SetFuncBuiltIn(biEnsureRange,'Приведение значения к вхождению в указанные границы','NCD');
    SetFuncBuiltIn(biReplVar,'Замена значения, равного указанному, на другое указанное');

    SetFunction('Вывод на экран',1300);
    SetFuncBuiltIn(biMessOk,'Выдать сообщение на экран',1301);
    SetFuncBuiltIn(biDbgMessOk,'Выдать сообщение на экран (отладка)',1301);
    SetFuncBuiltIn(biAsk,'Выдать запрос на экран',1302,'LI');
    SetFunction('ИНДИКАТОР','Выдать индикатор процесса на экран',
      InterPrmMax(['[Загл: строка]','[Сообщ: массив|строка]','[Прерв: логическое]']),['CU','ACU','LU'],
      i_stat,null,1303,'L*');
    SetFunction('ИНД_ПРЕРВАТЬ','Прервать процесс, созданный функцией ИНДИКАТОР()',i_stabort,null);
    SetFuncBuiltIn(biStProc,'Изменить процент выполнения процесса',1304,'L');
  	SetFuncBuiltIn(biProfile);
{$IFDEF PROF}
    TKeyLb.SetFixKey(K_Alt_P,'Профайлер',TNone.Prof,kmDesign);
{$ENDIF}
  end;
  DelStack;
end;

procedure Final;
var j: longint;
begin
	AddStack('Inter.Final');
  for j:=0 to nvar-1 do begin
    avar[j].slPars.Free; VarInit(avar[j]);
  end;
  slFLFree; IntUcomp.Free; lsShape.Free; lsPref.Free; lsVarHelp.Free;
  DelStack;
end;

initialization
  Init;
finalization
  Final;
end.
