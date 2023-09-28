unit FFdp;

interface

{$I LIBTEST}
uses
  Windows,SysUtils,Classes,Controls,Forms,Menus,
  MyTypes,My_pr,Askp,FPanel,RbScroll,GenForm,Inter,FSumm,FStat,FDWPrm,KeyLb,FEdoDM,RecDB{,FProfile};

type
{$IFDEF ARRCONDTEST}
  TPrNValInf = function(nVal: longint): string;
{$ENDIF}

  TSDPartList = (sdpNoSayStat,sdpDpg); TSDPartOpt = set of TSDPartList;
  TArrCondMatrixOpt = set of (acmxEtcRow,acmxEtcCol,acmxChkSum);

  TFdp = class(TRbPanel)
  private
    { Private declarations }
    FCaption: TCaption;
    FState: TFdpState;
    FOptions: TFdpOptions;
    FOnProcExec,FOnBeforeDocForm: TProcValid;
    FOnAfterDocForm,FOnAfterKeyDocForm,FOnSetDcmModified,FOnOpenDcmError,FOnPrmEdit: TNotifyEvent;
    PnGF,PnGF1,PnGF2,PnInf: TRbPanel;
    pmnBase,pmnScale: TPopupMenu;
    ScrlGF: TRbScrollBox;
    stFrm,stPrn: TRbStatus;
    M_Edit,M_EdFont,M_R1,M_Enter,M_F2,M_F4,M_F5,M_F8,M_Shift_F2,M_Shift_F3,M_Shift_F5,M_F6,M_Shift_F6,M_R2,M_Scale,
    	M_Ctrl_U,M_Ctrl_F10,M_R3,M_ArhSave,M_ArhLoad,M_INet,M_EDO,M_Spot: TMenuItem;
    Inter: TInter;
    mLeaf,mPage,mScale,mLeft,mTop,CurLine: string;
    RateScr: double;
	  lLeaf,lPage,lScale,lLeft,lTop,KeyBreak: longint;
    FAborted,lProcForm,VertBreak,lDopAlg,FModified,FDcmModified: boolean;
    PartIni,FileDcm,FullName: TFileName;
    ObjEdit: PGFObj;
    ObjFont: byte;
    FindInfo: TGFFindInfo;
		aInf: TArrStr;
		inf: TRBSTMouseInfo;
		ppd: TPPDocRec;
    FormStat: TStat;
    FormWait: TAsk;
    DateTimeBeg: TDateTime;
    dw: TDWWin;
    lsExtend: TList;
    tl: TKeyLb;
    ls: TGFBitMapList;
    NoFitOnPage: variant;
    EdoPrm: TEdoPrm;
    EdoOrgs: TStringList;
    EdoNC: TIntStrList;
		procedure stFrmFill;
    procedure ProcKey(key: longint; tw: TWinControl);
    procedure APopupClick(Sender: TObject);
    procedure AScaleClick(Sender: TObject);
    procedure M_EditClick(Sender: TObject);
    procedure EdObjTextBeforeShow(Sender: TObject);
    procedure M_EdFontClick(Sender: TObject);
    procedure M_SpotClick(Sender: TObject);
    procedure ViewDate;
    procedure ViewGF;
    procedure ViewPage;
    procedure AfterView(Sender: TObject);
		procedure PnGF1Bounds;
		procedure SetScale(Scale: Single);
    procedure ClearFind;
    procedure PnGFEnter(Sender: TObject);
    //procedure ScrlGFExitRange(Sender: TObject; Mode: TRBScrlExitMode);
    procedure ScrlGFScroll(Sender: TObject; Kind: TRBScrlKind; Code,Pos: Smallint);
    procedure SetPage(Index: longint);
    procedure GFEnter(Sender: TObject);
		procedure GFBeforeCalculate(Sender: TObject);
    procedure GFNoFitOnPage(Sender: TObject);
    procedure GFAfterPaint(Sender: TObject);
    procedure GFMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
    procedure GFMouseMove(Sender: TObject; Shift: TShiftState; X,Y: longint);
    procedure GFMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
    procedure stFrmMouseMove(Sender: TObject; Shift: TShiftState; X,Y: longint);
    procedure stFrmMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
    class procedure FontFind(Prm: pointer; const ARect: TRect; X,Y: longint; nFont: byte; const Text: string);
    procedure stPrnClick(Sender: TObject);
    function PrmGetClick(Sender: TObject; lEval: Boolean): String;
    function PrmGetEval(twActive: TWinControl = nil): Boolean;
    procedure FontProc(lAfter: boolean; var StrList,KeyStr: string; var ProcKey: TKeyProc;
      var MouseDown,MouseUp: TMouseEvent; var MouseMove: TMouseMoveEvent; var Show: TNotifyEvent);
    procedure FontKeyProc(key: longint; tw: TWinControl);
		function FontStr(i: byte): string;
    procedure PrStat(Sender: TStat);
    procedure PrWait(Sender: TAsk);
		procedure PrObj;
    procedure SetProg(lDopAlg: boolean);
		function PrFind(Sender: TControl; const sf: string): boolean;
    procedure KeyExistFile;
    function GetEdoPrm: boolean;
    procedure SetNmExtend;
    procedure SetModified(Value: boolean);
		procedure SaveEditPrm;
    procedure SaveLeaf(nLeaf: longint); overload;
		function GetState: TFdpState;
		procedure SetEdText(pv: PGFObj; const txt: string);
		function OpenDcmFirst: boolean;
		procedure SetDcmModified(Value: boolean);
		procedure PnInfAfterPaint(Sender: TObject);
		procedure PrPrnChange;
    procedure EdoNCLoad(var ms: string);
    function EdoIsNC: boolean;
    procedure deEdoPrimFldChange(Sender: TObject; const OldVal: variant; FromShow: boolean);
	  function deEdoPrimFldCheck(Sender: TObject): boolean;
    property Modified: boolean read FModified write SetModified;
  protected
    { Protected declarations }
  public
    { Public declarations }
    stGF: TRbStatus;
    GF: TGenForm;
    RecPrim: TRecDB;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetFocus; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure AssignFdp(const av: array of string; lSetFocus: boolean = true);
    procedure SaveLeaf; overload;
    property Aborted: boolean read FAborted;
    property DcmModified: boolean read FDcmModified write SetDcmModified;
  published
    { Published declarations }
    property Caption: TCaption read FCaption write FCaption;
    property Options: TFdpOptions read FOptions write FOptions;
    property State: TFdpState read GetState write FState;
    property OnAfterDocForm: TNotifyEvent read FOnAfterDocForm write FOnAfterDocForm;
    property OnAfterKeyDocForm: TNotifyEvent read FOnAfterKeyDocForm write FOnAfterKeyDocForm;
    property OnBeforeDocForm: TProcValid read FOnBeforeDocForm write FOnBeforeDocForm;
    property OnOpenDcmError: TNotifyEvent read FOnOpenDcmError write FOnOpenDcmError;
    property OnPrmEdit: TNotifyEvent read FOnPrmEdit write FOnPrmEdit;
    property OnProcExec: TProcValid read FOnProcExec write FOnProcExec;
    property OnSetDcmModified: TNotifyEvent read FOnSetDcmModified write FOnSetDcmModified;
  end;

  TSummNum = class(TSumm)
  protected
    class procedure SummException(const Message: string); override;
  end;

  TArrCondRoundOpt = set of (acrndNoShow,acrndNoMsg);

  TSummProc = function: TSumm;

  TSDPartProc = procedure(Index: longint);

var CurFdp: TFdp;
  DcmPrivEdit: string;
  FdpOnlyView: boolean;
  SummReDef: TSumm;
  Summ: TSummProc;

procedure DcmForm(nLeaf: longint = 1; DynamicPart: boolean = true); overload;
procedure DcmAddCol(const Col: string); overload;
procedure DcmAddCol(const aCol: array of string; l: longint); overload;
procedure DcmAddCol(Summ: TSumm; const Col: string); overload;
procedure DcmDelCol(const Col: string); overload;
procedure DcmDelColGr(const Col: string); overload;
function DcmArrCol(const Col: string): variant; overload;
procedure DcmPart(const nmPart: variant; const PartPrim: string = ''); overload;
procedure DcmClose; overload;
procedure DcmAbort; overload;
function DcmAborted(fStat: TForm = nil): boolean;
procedure DcmNewPage(Opt: TDcmNewPageOpt = []); overload;
procedure DcmHFPage(Index: TGFHeadFoot; const Part: variant); overload;
procedure DcmHFPage(Index: TGFHeadFoot); overload;
procedure AddColHead(const Col: string); overload;
procedure AddColFoot(const Col: string); overload;
procedure AddPart(const Part: variant; n: TGFAddPartList); overload;
procedure DcmUpdateRec; overload;
function DcmStrPrm(const Value: variant; nParam: longint; const aNum,aDate: variant): variant; overload;
function DcmMsOff(const FileName: TFileName; Editor: TMSOEditorList0; Fmt: TMSOFmtList; Trn: TMSOTrnType;
  const Leaf: variant): boolean; overload;
function DcmDpg(const nmalg: variant; const av: array of variant): variant; overload;
procedure SummInit(tb: byte = 1; te: byte = 0); overload;
function SummSegmLine(nSegm: longint): string; overload;
function SDPart(const sBeg: string; const aShape,aPart,PgHead,PgFoot,aDocHead,aDocFoot: variant;
  Opt: TSDPartOpt = []; fStat: TForm = nil; pPgHeadFoot: PVariant = nil; pNoFitOnPage: PVariant = nil;
  Proc: TSDPartProc = nil): boolean; overload;
function DcmSayStat(const Capt: TCaption; const st: TCaption = ' '; prc: Double = 0; fStat: TForm = nil): boolean; overload;
function DcmSayStat(const Capt: TCaption; fStat: TForm): boolean; overload;
function DcmSayStat(prc: Double; fStat: TForm = nil): boolean; overload;
procedure DcmClearTime(fStat: TForm = nil);
function DcmGetWnd(CanShow: TDECanShow = desAlways; wType: TGFWinList = gfwDat;
	lDWSeek: boolean = true): boolean; overload;
function IfThenDcmGetWnd(usl: boolean; CanShow: TDECanShow = desAlways; wType: TGFWinList = gfwDat;
	lDWSeek: boolean = true): boolean;
function DcmPrmWnd(const FileDcm: string; const FileDtg: string = '';
	const Capt: string = ''; CanShow: TDECanShow = desAlways): boolean;
function DcmIdent(const id: string): variant; overload;
function VarCurGF(const v,ind: variant; lSave: boolean = true): variant;
function NumSumm(const v: variant; lSave: boolean = true): variant; overload;
function NumSumm: variant; overload;
// Округление с условиями: aVal-{значение,правильно округл.,ненулевые не переходят в 0,строка,столбец},
// aSum-суммы,aEqual-условно равны{номер1,номер2,с учётом знака/необязат.}
function ArrCondRoundSelf(var aVal: variant; const aSum,aEqual,UnUsed,aMatrix: variant;
  {$IFDEF ARRCONDTEST}PrNValInf: TPrNValInf = nil;{$ENDIF} FloatDec: byte = FloatMaxDec;
  Opt: TArrCondRoundOpt = []): boolean;
// Описание условий суммирования для ArrCondRound
function ArrCondMatrix(const aRow,aCol: variant; const sRow: string; const sCol: string = '';
  Opt: TArrCondMatrixOpt = []; FloatDec: byte = FloatMaxDec; Prior: byte = 0): variant; overload;
function IfThen(AValue: boolean; ATrue: TSDPartList): TSDPartOpt; overload;
procedure Register;

implementation

uses
  Dialogs,Printers,StdCtrls,Math,DB,Variants,StrUtils,Graphics,
  DefEdit,ListF2,FGFPrm,KeyMenu,FSchemDM,FEdGenFr,FGFPages,FEdText,ButGet,
    FGFPrn,FrmPswd,ComboGet,BufFile,bdfunc,FFldEdit,CodeGets,RecVal;

type EFdpBreak = class(Exception);

  TNone = class
  private
    class procedure EdObjTextAfterShow(Sender: TObject);
    class procedure PnGFExit(Sender: TObject);
    class procedure PrmGetPaint(Sender: TObject; const ARect: TRect; const Text: string);
    class procedure RDocPrmDWSeek(Sender: TObject);
    class procedure RDocpPrmDWSeek(Sender: TObject);
		class function gArhListResult(Sender: TObject; lr: TListF2Result): string;
		class function deArhFldCheck(Sender: TObject): boolean;
		class procedure ArhDelProc(key: longint; tw: TWinControl);
    class procedure SavePrmKeyProc(key: longint; tw: TWinControl);
    class procedure KeySummShow(key: longint; tw: TWinControl);
  end;

const
  stLeaf  = 'Лист:';
  stPage  = 'Страница:';
  stScale = 'Масштаб:';
  stLeft  = 'Слева:';
  stTop   = 'Сверху:';

	scStep  = 0.1;
  scRound = 100;
  scStepRnd = round(scStep*scRound);

  aWinExec: array[TGFWinList,1..3] of string =
    (('Doc' ,'Окно ввода данных'                     ,'')
    ,('Docp','Окно ввода параметров'                 ,'Параметры документа')
    ,('Docd','Окно ввода для дополнительных действий','')
    );

	iX = 5; iY = 5;

  aSpot: array[1..4] of string = ('сверху','слева','снизу','справа');

  FuncDcmDpg = 'ДОК_АЛГОРИТМ';
  FuncEdoOrgFlt = 'EdoOrgFlt';

  VarNSumm = 'ТБЛ_НОМЕР';

  aHFVarCurGF: array[TGFHeadFoot] of TVarCurGFList = (vgfHeadPage,vgfFootPage,vgfPrimBegPage,vgfPrimPage);

var aSumm: array[1..30] of TSummNum;
	nSumm: byte = 1;
  aInt: TArrInter;
  nInt: longint = -1;
  CurFileDtg,ArhPath,SavePrmKeyStr: string;
  deArh,deEdoPrim: TDefEdit;
  rArh,rEdoPrim: TRecVal;
  gArh: TComboGet;
  aDlg: array[boolean] of TOpenDialog;
  nVar: longint;

function FSumm: TSumm;
begin
  AddStack('FFdp.FSumm');
  if Assigned(SummReDef) then result:=SummReDef
  else begin
    if not Assigned(aSumm[nSumm]) then aSumm[nSumm]:=TSummNum.Create;
    result:=aSumm[nSumm];
  end;
  DelStack;
end;

// Начать формирование документа.
procedure DcmForm(nLeaf: longint = 1; DynamicPart: boolean = true);
var Opt: TDcmFormOpt;
begin
	AddStack('FFdp.DcmForm');
  if Assigned(CurFdp) then begin
    if DynamicPart then Opt:=[dcmfDynamicPart] else Opt:=[];
    with CurFdp do GF.DcmForm([FileDcm,GF.FileName,PartIni],EdGenFr.GF,nLeaf,Opt);
  end;
  DelStack;
end;

function DcmForm(var av: array of variant): variant; overload;
begin
  result:=null; DcmForm(IsNilc(av[1],1));
end;

// Добавить динамическую колонку
procedure DcmAddCol(const Col: string);
begin
	AddStack('FFdp.DcmAddCol');
	if Assigned(CurFdp) then CurFdp.GF.DcmAddCol(Col);
  DelStack;
end;

procedure DcmAddCol(const aCol: array of string; l: longint);
var i: longint;
begin
  AddStack('FFdp.DcmAddCol(a)');
  for i:=0 to l-1 do DcmAddCol(aCol[i]);
  DelStack;
end;

procedure DcmAddCol(Summ: TSumm; const Col: string);
var a: TArrStr;
  l: longint;
begin
  AddStack('FFdp.DcmAddCol(Summ)');
  l:=Summ.ArrName(s_col,a,Col); DcmAddCol(a,l);
  DelStack;
end;

function DcmAddCol(var av: array of variant): variant; overload;
var i: longint;
begin
	result:=null;
  case MyVarType(av[1]) of
    V_STRING: DcmAddCol(av[1]);
    varArray: for i:=VarArrayLowBound(av[1],1) to VarArrayHighBound(av[1],1) do DcmAddCol(av[1][i]);
  end;
end;

// Удалить колонку
procedure DcmDelCol(const Col: string);
begin
	AddStack('FFdp.DcmDelCol');
	if Assigned(CurFdp) then CurFdp.GF.DcmDelCol(Col);
  DelStack;
end;

function DcmDelCol(var av: array of variant): variant; overload;
begin
	result:=null; DcmDelCol(av[1]);
end;

// Удалить группу колонок
procedure DcmDelColGr(const Col: string);
begin
	AddStack('FFdp.DcmDelColGr');
	if Assigned(CurFdp) then CurFdp.GF.DcmDelColGr(Col);
  DelStack;
end;

function DcmDelColGr(var av: array of variant): variant; overload;
begin
	result:=null; DcmDelColGr(av[1]);
end;

// Список колонок
function DcmArrCol(const Col: string): variant;
begin
	AddStack('FFdp.DcmArrCol');
	if Assigned(CurFdp) then result:=CurFdp.GF.DcmArrCol(Col) else result:=false;
  DelStack;
end;

function DcmArrCol(var av: array of variant): variant; overload;
begin
	result:=DcmArrCol(IsNilc(av[1],''));
end;

// Вывести указанный раздел
procedure DcmPart(const nmPart: variant; const PartPrim: string = '');
begin
	AddStack('FFdp.DcmPart');
	if Assigned(CurFdp) then begin
  	if not CurFdp.GF.FileBufActive then DcmForm;
  	CurFdp.GF.DcmPart(nmPart,PartPrim);
  end;
  DelStack;
end;

function DcmPart(var av: array of variant): variant; overload;
begin
	result:=null; DcmPart(av[1],IsNilc(av[2],''));
end;

// Закончить формирование
procedure DcmClose;
begin
	AddStack('FFdp.DcmClose');
	if Assigned(CurFdp) then CurFdp.GF.DcmClose(true);
  DelStack;
end;

function DcmClose(var av: array of variant): variant; overload;
begin
	result:=null; DcmClose;
end;

// Прервать формирование
procedure DcmAbort;
begin
	AddStack('FFdp.DcmAbort');
	if Assigned(CurFdp) then with CurFdp do begin
    GF.DcmClose(false); FormStat.Abort; FormWait.Abort;
  end;
  DelStack;
end;

function DcmAbort(var av: array of variant): variant; overload;
begin
	result:=null; DcmAbort;
end;

// Следующая страница
procedure DcmNewPage(Opt: TDcmNewPageOpt = []);
begin
	AddStack('FFdp.DcmNewPage');
	if Assigned(CurFdp) then CurFdp.GF.DcmNewPage(Opt);
  DelStack;
end;

function DcmNewPage(var av: array of variant): variant; overload;
var Opt: TDcmNewPageOpt;
begin
	result:=null; Opt:=[];
  if IsNilc(av[1],false) then Include(Opt,newpgPartEnd);
  if IsNilc(av[2],false) then Include(Opt,newpgPrim);
  DcmNewPage(Opt);
end;

// Заголовок/подвал страницы
procedure DcmHFPage(Index: TGFHeadFoot; const Part: variant);
begin
	AddStack('FFdp.DcmHFPage');
  VarCurGF(Part,aHFVarCurGF[Index]);
  DelStack;
end;

procedure DcmHFPage(Index: TGFHeadFoot);
begin
  DcmHFPage(Index,'');
end;

// Добавить колонку, открывающую страницу
procedure AddColHead(const Col: string);
begin
	AddStack('FFdp.AddColHead');
	if Assigned(CurFdp) then CurFdp.GF.AddColHead(Col);
  DelStack;
end;

function AddColHead(var av: array of variant): variant; overload;
begin
	result:=null; AddColHead(av[1]);
end;

// Добавить колонку, открывающую страницу
procedure AddColFoot(const Col: string);
begin
	AddStack('FFdp.AddColFoot');
	if Assigned(CurFdp) then CurFdp.GF.AddColFoot(Col);
  DelStack;
end;

function AddColFoot(var av: array of variant): variant; overload;
begin
	result:=null; AddColFoot(av[1]);
end;

procedure AddPart(const Part: variant; n: TGFAddPartList);
var i: longint;
begin
	AddStack('FFdp.AddPart');
	if Assigned(CurFdp) and not empty(Part) then
    case MyVarType(Part) of
      varString: CurFdp.GF.AddPart(Part,n);
      varArray: for i:=VarArrayLowBound(Part,1) to VarArrayHighBound(Part,1) do
        AddPart(Part[i],n);
    end;
  DelStack;
end;

function AddPart(var av: array of variant): variant; overload;
begin
	result:=null; AddPart(av[1],av[0]);
end;

// Сохранить значения данных и параметров документа
procedure DcmUpdateRec;
begin
	AddStack('FFdp.DcmUpdateRec');
	TEdGenFr.LoadWait; EdGenFr.RDocPrm.AppUpdRec; EdGenFr.RDocpPrm.AppUpdRec;  
  DelStack;
end;

function DcmUpdateRec(var av: array of variant): variant; overload;
begin
  result:=null; DcmUpdateRec;
end;

// Преобразует значение в строку в соответствии с параметрами формы
function DcmStrPrm(const Value: variant; nParam: longint; const aNum,aDate: variant): variant;
var i,h: longint;
	a: variant;
  function IsArr(const av: variant): boolean;
  begin
    AddStack('FFdp.DcmStrPrm.IsArr');
    result := MyVarType(av)=varArray;
    if result then begin
      a:=av; i:=VarArrayLowBound(a,1); h:=VarArrayHighBound(a,1);
    end;
    DelStack;
  end;
	function Zn1(const Def: variant): variant;
  begin
    AddStack('FFdp.DcmStrPrm.Zn1');
    result:=Def;
    if i<=h then if not IsNil(a[i]) then result:=a[i];
    Inc(i);
    DelStack;
  end;
var p: TGFParams;
begin
	AddStack('FFdp.DcmStrPrm');
  result:=Value; Dec(nParam);
  if Assigned(CurFdp) then p:=GFCopyParams(CurFdp.GF.Params)
  else begin
    SetLength(p.Arr,1); p.Arr[0]:=TGenForm.PrmDef;
  end;
  with p.Arr[nParam] do begin
    FmtNum(PrmNum,aNum); FmtDate(PrmDate,aDate);
  end;
  GFFmtStr(result,p,nParam);
  DelStack;
end;

function DcmStrPrm(var av: array of variant): variant; overload;
var nParam: longint;
begin
  nParam:=IsNilc(av[2],CurGFObjParams);
  if nParam=NegDef then
    if Assigned(CurFdp) then nParam:=CurFdp.GF.CurParams else nParam:=0;
  result:=DcmStrPrm(av[1],nParam+1,av[3],av[4]);
end;

// Выполнить алгоритм формирования документа с указанными параметрами
function DcmDpg(const nmalg: variant; const av: array of variant): variant;
var int: TInter;
  i,j: longint;
  av1: TArrVar;
  fl: boolean;
begin
	AddStack('FFdp.DcmDpg');
  if Assigned(CurFdp) then begin
    Inc(nInt);
    if nInt=Length(aInt) then begin
      int:=TInter.Create(''); SetLength(aInt,nInt+1); aInt[nInt]:=int; int.Assign(CurFdp.Inter);
    end
    else int:=aInt[nInt];
    int.name:='Выполнение функции '+FuncDcmDpg+'('+Vtos(nmalg,true)+')';
    SetLength(av1,Length(av)+1); j:=low(av1); av1[j]:=nmalg;
    for i:=low(av) to high(av) do begin
    	Inc(j); av1[j]:=av[i];
    end;
    fl:=int.EvalChk(result,av1); Dec(nInt);
    if not fl then
      if InterShowError(int)=mrCancel then raise EInterAnyError.Create('',FuncDcmDpg);
  end
  else result:=null;
  DelStack;
end;

procedure aIntFree;
var i: longint;
begin
  AddStack('FFdp.aIntFree');
  for i:=0 to high(aInt) do aInt[i].Free;
  nInt:=-1; aInt:=nil;
  DelStack;
end;

function DcmDpg(var av: array of variant): variant; overload;
var i,j,h: longint;
	nmalg: variant;
begin
  nmalg:=av[1];
  if IsNil(nmalg)
  then raise EInterAnyError.Create('Первый параметр обязательный',FuncDcmDpg);
  j:=2; h:=high(av);
  for i:=low(av) to h do begin
  	if j>h then av[i]:=null else av[i]:=av[j];
    Inc(j);
	end;
  result:=DcmDpg(nmalg,av);
end;

function vDcmDpg(const v: variant): variant; overload;
var j,l,h: longint;
  av: TArrVar;
begin
  AddStack('FFdp.vDcmDpg');
  l:=VarArrayLowBound(v,1); h:=VarArrayHighBound(v,1); SetLength(av,h-l+2); j:=0;
  for l:=l to h do begin
    Inc(j); av[j]:=v[l];
  end;
  DcmDpg(av);
  DelStack;
end;

// Длина текста в миллиметрах
function DcmTextMm(var av: array of variant): variant;
var v: TGFObj;
  ap: variant;
begin
	AddStack('FFdp.DcmTextMm');
  if Assigned(CurFdp) then with CurFdp.GF,Canvas do begin
    if MyVarType(av[2])<>varArray then av[2]:=ArrVarToVar([av[2]]);
    GFObjDef(v); v.Text:=av[1]; ap:=VAddEnd(av[2],4);
    if IsNil(ap[1]) then ap[1]:=TInter.GetVarValue('ОБ_ШРИФТ');
    v.Font:=ap[1]; v.MMetr:=IsNilc(ap[2],false);
    v.MinWidth:=IsNilc(ap[3],0); v.MinHeight:=IsNilc(ap[4],0);
    if IsNilc(av[3],false)
    then result:=GetMinHeight(v,[mwhNoALine])
    else result:=GetMinWidth(v,[mwhNoALine]);
    MultD(result,MmInInch/Screen.PixelsPerInch);
    if IsNilc(av[4],false) then result:=Ceil(result);
  end
  else result:=0;
  DelStack;
end;

function DcmBoundMm(var av: array of variant): variant;
begin
	AddStack('FFdp.DcmBoundMm');
  if Assigned(CurFdp) then with CurFdp.GF do begin
  	AutoSize;
    result:=IfThen(IsNilc(av[1],false),GridX[ColCount],GridY[RowCount])/Screen.PixelsPerInch*MmInInch;
  end
  else result:=0;
  DelStack;
end;

// ДОК_ИДСПИС,ДОК_ИДЕСТЬ
type TDcmIdArr = (diaAllIdent,diaAllIndex,diaIs);

function DcmIdArr(tp: TDcmIdArr; const idbeg: string): variant; overload;
var l,i,la,lr: longint;
  a: TSegmStr;
  s: string;
begin
	AddStack('FFdp.DcmIdArr');
  result:=false;
  if Assigned(CurFdp) then with CurFdp.GF do
  	if LsIdent.Count>0 then begin
      if tp in [diaAllIdent,diaAllIndex] then VarArrLenInit(result,l,LsIdent.Count,@lr);
      if Pos(UnDelim,idbeg)=0 then begin
        LsIdent.Find(idbeg,i);
        for i:=i to LsIdent.Count-1 do begin
      	  if not AnsiStartsStr(idbeg,LsIdent[i]) then break;
          if tp=diaIs then begin
            result:=true; break;
          end
          else begin
            VarArrLenAdd(result,l,lr); result[l]:=LsIdent[i];
          end;
        end;
      end
      else begin
        la:=ListAsArray(idbeg,a,','); i:=1;
        while i<=la do if a[i]=UnDelim then break else Inc(i);
        s:=ArrayAsList(a,',',i-1,true); LsIdent.Find(s,i);
        for i:=i to LsIdent.Count-1 do
      	  if not AnsiStartsStr(s,LsIdent[i]) then break
          else if EqualShape(LsIdent[i],idbeg) then
            if tp=diaIs then begin
              result:=true; break;
            end
            else begin
              VarArrLenAdd(result,l,lr); result[l]:=iif(tp=diaAllIndex,i,LsIdent[i]);
            end;
      end;
      if tp in [diaAllIdent,diaAllIndex] then VarArrLenSet(result,l);
    end;
  DelStack;
end;

function DcmIdArr(var av: array of variant): variant; overload;
begin
	result:=DcmIdArr(av[0],av[1]);
end;

// ДОК_ИДЗНАЧ
function DcmIdent(const id: string; const cv: variant): variant; overload;
var v: variant;
	function Id1(i: longint): string;
  var pi: PGFIdent;
	  pv: PGFObj;
    j: longint;
  begin
    AddStack('FFdp.DcmIdent.Id1');
    CurFdp.GF.Calculate1(i); pi:=CurFdp.GF.Idents(i); result:=SubStr(TextCRLF(pi.Value),1,-lCRLF);
    if not IsNil(cv) then begin
      if CurFdp.GF.Leaf<>pi.Leaf then begin
        CurFdp.SaveLeaf; CurFdp.GF.RestPage(pi.Leaf);
      end;
      for j:=0 to CurFdp.GF.ObjectCount-1 do begin
        pv:=CurFdp.GF.PObjects[j];
        if pv.Ident=CurFdp.GF.LsIdent[i] then begin
          if not GFFmtStr(v,CurFdp.ppd.Params,CurFdp.GF.CurParams)
          then raise EInterAnyError.Create('Значение должно быть строкой, числом или датой');
		    	CurFdp.SetEdText(pv,v); break;
        end;
      end;
    end;
    DelStack;
  end;
var i: longint;
  pg: PPages;
begin
	AddStack('FFdp.DcmIdent');
  result:=''; DcmIdentParams:=nil;
  if Assigned(CurFdp) then
  	if Pos(UnDelim,id)>0 then begin
    	result:=DcmIdArr(diaAllIndex,id);
      if MyVarType(result)=varArray then begin
      	v:=null;
      	for i:=VarArrayLowBound(result,1) to VarArrayHighBound(result,1) do result[i]:=Id1(result[i]);
      end;
    end
    else with CurFdp.GF do if LsIdent.Find(id,i) then begin
      if EvalCalc then begin
        pg:=Pages(Idents(i).Leaf-1);
        if Assigned(pg) then DcmIdentParams:=@Params.Arr[pg.sv.CurParams];
      end;
      v:=cv; result:=Id1(i);
    end;
  DelStack;
end;

function DcmIdent(var av: array of variant): variant; overload;
begin
	result:=DcmIdent(av[1],av[2]);
end;

function DcmIdent(const id: string): variant;
begin
	result:=DcmIdent(id,null);
end;

function DcmPageName(var av: array of variant): variant;
begin
	AddStack('FFdp.DcmPageName');
  if Assigned(EdGenFr) then with EdGenFr.GF do result:=PageName[IsNilc(av[1],Leaf)] else result:='';
  DelStack;
end;

function DcmPageCnt(var av: array of variant): variant;
var i: longint;
begin
	AddStack('FFdp.DcmPageCnt');
  result:=0;
  if MyVarType(IsNil(av[1],true))=V_STRING then begin
    if Assigned(CurFdp) then with CurFdp.GF do
      if av[1]='' then result:=PageCount
      else if IntObjFind(LsBlockLeaf,av[1],i) then result:=i;
  end
  else if av[1] then begin
    if Assigned(EdGenFr) then result:=EdGenFr.GF.PageCount;
  end
  else if Assigned(CurFdp) then result:=CurFdp.GF.PageCount;
  DelStack;
end;

function DcmMsOff(const FileName: TFileName; Editor: TMSOEditorList0; Fmt: TMSOFmtList; Trn: TMSOTrnType;
  const Leaf: variant): boolean;
var r: TMSOExec;
begin
  AddStack('FFdp.DcmMsOff');
  if Assigned(CurFdp) then begin
    r.tw:=CurFdp.GF; r.FileName:=FileName; r.Editor:=Editor; r.Fmt:=Fmt; r.Trn:=Trn; r.Leaf:=Leaf;
    result:=MsgMsOff(MsOff,@r);
  end
  else result:=false;
  DelStack;
end;

function DcmMsOff(var av: array of variant): variant; overload;
  function ChkPrm(n,Def,LowLim,HighLim: byte): variant;
  begin
    AddStack('FFdp.DcmMsOff.ChkPrm');
    result:=IsNilc(av[n],Def);
    if not InRange(result,LowLim,HighLim)
    then raise EInterAnyError.CreateFmt('Параметр %d должен быть от %d до %d',[n,LowLim,HighLim]);
    DelStack;
  end;
begin
  AddStack('FFdp.DcmMsOff');
  if Assigned(CurFdp)
  then result:=DcmMsOff(av[1]
    ,ChkPrm(2,byte(msoEdExcel),byte(msoEdDefine),byte(high(TMSOEditorList)))
    ,ChkPrm(3,byte(msoFmtHtml),1,byte(high(TMSOFmtList)))
    ,ChkPrm(4,byte(msoTwTable),1,byte(high(TMSOTrnType)))
    ,av[5])
  else result:=false;
  DelStack;
end;

function DcmIdStr(var av: array of variant): variant;
var Opt: TGFIdStrAddOpt;
begin
	AddStack('FFdp.DcmIdStr');
  result:='';
  if Assigned(CurFdp) then begin
    Opt:=[];
    if IsNilc(av[4],false) then Include(Opt,gfidHMax);
    if IsNilc(av[6],false) then Include(Opt,gfidEmpNoFill);
    CurFdp.GF.IdStrAdd(av[1],av[2],av[3],Opt,IsNilc(av[5],0));
  end;
  DelStack;
end;

function c_EdoOrgFlt(var av: array of variant): variant;
begin
  AddStack('FFdp.c_EdoOrgFlt');
  result:=Ls2Var(CurFdp.EdoOrgs);
  DelStack;
end;

function c_edo(var av: array of variant): variant;
var wkey: string;
begin
  AddStack('FFdp.c_edo');
  result:=null;
  if Assigned(EdoDM) then if not IsNil(av[1]) then with ProgPswd.GetQuery do begin
    SetArrayList(sC_LIST,[tEDO+'.D',tEDO+'.SKIPUSER',tEDO+'.SKIPREASON',tEDO+'.'+fEDOEXE]);
    if Assigned(EdoInFdp)
    then PartSelect(tEDO,'',fEDOIN+'='+Vtos(EdoInFdp[fEDOIN])+sAND+fUSERNAME+'='+QQs(av[1]))
    else if Assigned(CurFdp) then with CurFdp do if GetEdoPrm then with EdoPrm do begin
      if IsNil(av[2]) then wkey:='' else wkey:=tEDOIN+'.KEY='+QQs(av[2]);
      PartSelect(GetList([tEDO,tEDOIN]),'',
        DlmBetween([tEDO+'.'+fEDOIN+'='+tEDOIN+'.'+fEDOIN,tEDOIN+'.VD='+Vtos(vd),
          tEDOIN+'.RSOURCE='+Vtos(rsource),wkey,tEDO+'.'+fUSERNAME+'='+QQs(av[1])],sAND));
    end;
    if IsRecords then result:=ArrVarToVar(
      [TDateTime(Fields[0].AsFloat)
      ,TrimRight(Fields[1].AsString)
      ,TrimRight(Fields[2].AsString)
      ,StrToBoolean(EdoDM.ExeGet.CodeDop(Fields[3].AsString,[cdgBufAll]))
      ]);
    ProgPswd.FreeQuery;
  end;
  DelStack;
end;

// Обнулить таблицу
procedure SummInit(tb: byte = 1; te: byte = 0);
var onSumm: byte;
begin
	AddStack('FFdp.SummInit');
  if tb=0 then tb:=nSumm;
  if te=0 then te:=tb;
  onSumm:=nSumm; nSumm:=tb;
  while nSumm<=te do begin
    Summ.Init; Inc(nSumm);
  end;
  nSumm:=onSumm;
  DelStack;
end;

function SummInit(var av: array of variant): variant; overload;
begin
	result:=null; SummInit(IsNilc(av[1],0),IsNilc(av[2],0));
end;

// Добавить значение в таблицу
function SummAdd(var av: array of variant): variant;
begin
	AddStack('FFdp.SummAdd');
  if not(empty(IsNil(av[3],1)) and IsNil(av[5],false)) then
    if MyVarType(av[3])=varString
    then result:=Summ.AddS(av[1],av[2],av[3])
    else result:=Summ.AddN(av[1],av[2],av[3],IsNilc(av[4],NegDef));
  DelStack;
end;

// Установить значение в таблице
function SummSet(var av: array of variant): variant;
begin
	AddStack('FFdp.SummSet');
  result:=Summ.SetV(av[1],av[2],IsNilc(av[3],0),IsNilc(av[4],NegDef));
  DelStack;
end;

// Добавить строку в таблицу
function SummAddLine(var av: array of variant): variant;
var i: longint;
begin
	AddStack('FFdp.SummAddLine');
  result:=null;
  if MyVarType(av[1])=varArray then
    for i:=1 to VarArrayHighBound(av[1],1) do Summ.AddLine(av[1][i])
  else Summ.AddLine(av[1]);
  DelStack;
end;

// Добавить столбец в таблицу
function SummAddCol(var av: array of variant): variant;
var t: TSumType;
  i: longint;
begin
	AddStack('FFdp.SummAddCol');
  result:=null; t:=TSumType(boolean(IsNilc(av[2],false)));
  if MyVarType(av[1])=varArray then
    for i:=1 to VarArrayHighBound(av[1],1) do Summ.AddCol(av[1][i],t)
  else Summ.AddCol(av[1],t);
  DelStack;
end;

// Значение ячейки таблицы
function SummValue(var av: array of variant): variant;
var sl: string;
begin
	AddStack('FFdp.SummValue');
  if IsNil(av[2]) then sl:=CurFdp.CurLine else sl:=av[2];
  if IsNil(av[3]) then result:=Summ.Value(av[1],sl) else Summ.Value(av[1],sl,result,av[3]);
  DelStack;
end;

// Список строк/столбцов таблицы с одинаковым началом или по шаблону
function SummArrName(lc: TSummLineCol; const s: string = ''; Vid: TSummArrVid = smaArr): variant; overload;
var a: TArrStr;
begin
	AddStack('FFdp.SummArrName');
  result:=Summ.ArrName(lc,a,s,Vid);
  if Vid<>smaCnt then
    if (result>0) and (Vid=smaFirst) then result:=a[0] else result:=ArrStrToVar(a,1,result);
  DelStack;
end;

function SummArrName(var av: array of variant): variant; overload;
begin
	result:=SummArrName(av[0],IsNilc(av[1],''),TSummArrVid(Bool2Int(av[2])));
end;

// Удалить строки/столбцы таблицы с одинаковым началом или по шаблону
function SummDelName(var av: array of variant): variant;
begin
	AddStack('FFdp.SummDelName');
  result:=null; Summ.DelName(TSummLineCol(av[0]),av[1],IsNilc(av[2],false));
  DelStack;
end;

// Суммирование значений ячеек строк
function SummSumOpt(const av: array of variant): TSummSumOpt;
const ao: array[TSummSumList] of byte = (6,7);
var o: TSummSumList;
begin
	AddStack('FFdp.SummSumOpt');
  result:=[];
  for o:=low(ao) to high(ao) do if IsNilc(av[ao[o]],false) then Include(result,o);
  DelStack;
end;

function SummSumLine(var av: array of variant): variant;
begin
	AddStack('FFdp.SummSumLine');
  result:=Summ.SumLine(av[1],av[2],IsNilc(av[3],''),IsNilc(av[4],NegDef),IsNilc(av[5],''),SummSumOpt(av));
  DelStack;
end;

// Суммирование значений ячеек столбцов
function SummSumCol(var av: array of variant): variant;
begin
	AddStack('FFdp.SummSumCol');
  result:=Summ.SumCol(av[1],av[2],IsNilc(av[3],''),IsNilc(av[4],NegDef),IsNilc(av[5],''),SummSumOpt(av));
  DelStack;
end;

// Сумма значений ячеек
function SummSumLineCol(var av: array of variant): variant;
begin
	AddStack('FFdp.SummSumLineCol');
	result:=Summ.SumLineCol(av[1],av[2],IsNilc(av[3],NegDef));
  DelStack;
end;

// Часть наименования текущей строки таблицы
function SummSegmLine(nSegm: longint): string;
var a: TSegmStr;
begin
	AddStack('FFdp.SummSegmLine');
  if Assigned(CurFdp) then begin
	  LsArrFill(CurFdp.CurLine,a,GFSegmDlm); result:=a[nSegm];
  end
  else result:='';
  DelStack;
end;

function SummSegmLine(var av: array of variant): variant; overload;
begin
	result:=SummSegmLine(av[1]);
end;

function SummSepLine(var av: array of variant): variant;
begin
	AddStack('FFdp.SummSepLine');
  result:=Summ.SepLine(av[1],av[2]);
  DelStack;
end;

function SummIsName(var av: array of variant): variant;
begin
	AddStack('FFdp.SummIsName');
	result:=Summ.IsName(TSummLineCol(av[0]),IsNilc(av[1],''));
  DelStack;
end;

function SummCntName(var av: array of variant): variant;
begin
	AddStack('FFdp.SummCntName');
	result:=Summ.CntName(TSummLineCol(av[0]),IsNilc(av[1],''));
  DelStack;
end;

function SummRnmName(var av: array of variant): variant;
const a: array[TSummLineCol,1..2] of string =
  (('строк'   ,'Строка')
  ,('столбцов','Столбец')
  );
  ao: array[TSummRenameList] of byte = (3,4);
var lc: TSummLineCol;
  Opt: TSummRenameOpt;
  o: TSummRenameList;
begin
	AddStack('FFdp.SummRnmName');
  Opt:=[];
  for o:=low(ao) to high(ao) do if IsNilc(av[ao[o]],false) then Include(Opt,o);
  lc:=TSummLineCol(av[0]); result:=Summ.Rename(lc,av[1],av[2],Opt);
  if result<>'' then raise EInterAnyError.Create(
    'Ошибка переименования '+a[lc,1]+':'+CRLF+a[lc,2]+' "'+result+'" уже существует');
  DelStack;
end;

// Вывести таблицу на экран
function SummShow(var av: array of variant): variant;
begin
	AddStack('FFdp.SummShow');
	result:=null;
  if not(av[0] and (true in MessagesOkHidden))
  then FormSummExec(IsNilc(av[1],''),IsNilc(av[2],''),MessagesDbgCaption(IsNilc(av[3],'')));
  DelStack;
end;

// Рапределить сумму по ячейкам таблицы
function SummRaspr(var av: array of variant): variant;
var a: TArrStr;
	i,l: longint;
  an: TArrDbl;
  sl: string;
  fl: boolean;
begin
	AddStack('FFdp.SummRaspr');
  l:=Summ.ArrName(s_line,a,av[1]);
  if MyVarType(av[5])=varArray then begin
    fl:=true; sl:='';
    if VarArrayHighBound(av[5],1)>1 then
      if not IsNil(av[5][2]) then begin
        fl:=false; sl:=av[5][2];
      end;
    if fl and Assigned(CurFdp) then sl:=CurFdp.CurLine;
    av[5]:=Summ.Value(av[5][1],sl);
  end;
  SetLength(an,l); Dec(l);
  for i:=0 to l do an[i]:=Summ.Value(av[2],a[i]);
  RasprOst(an,av[4],av[5],IfThen(not IsNilc(av[6],false),rspoNoOptim)); IsNil(av[3],av[2]);
  for i:=0 to l do Summ.SetN(a[i],av[3],an[i],av[4]);
  result := mround(Sum0(an),av[4])=mround(av[5],av[4]);
  DelStack;
end;

{$IFDEF ARRCONDTEST}
function PrNValInf(nVal: longint): string;
begin
  AddStack('FFdp.PrNValInf');
  result:=DcmDpg('ТБЛ_ОКРУГЛ',[nVal]);
  DelStack;
end;
{$ENDIF}

function ArrCondMatrix(var av: array of variant): variant; overload;
var Opt: TArrCondMatrixOpt;
begin
  Opt:=[];
  if IsNilc(av[5],false) then Include(Opt,acmxEtcRow);
  if IsNilc(av[6],false) then Include(Opt,acmxEtcCol);
  if IsNilc(av[7],false) then Include(Opt,acmxChkSum);
  result:=ArrCondMatrix(av[1],av[2],IsNilc(av[3],''),IsNilc(av[4],''),Opt,
    IsNilc(av[8],FloatMaxDec),IsNilc(av[9],0));
end;

function SummNsumsum(var av: array of variant): variant;
var sr: string;
begin
  AddStack('FFdp.SummNsumsum');
  Tsumm.nsumsum(av[1],av[2],av[3],sr); result:=sr;
  DelStack;
end;

function SummFile(var av: array of variant): variant;
var f: TFileBuf;
begin
  AddStack('FFdp.SummFile');
  result:=null; f:=TFileBuf.Create(string(av[1]),boolean(av[0]));
  try
    if not f.Active then raise EInterAnyError.Create(f.ErrorMessage);
    if av[0] then Summ.SaveTo(f) else Summ.LoadFrom(f);
  finally
    f.Free;
  end;
  DelStack;
end;

function SummCopyLine(var av: array of variant): variant;
var ac: TArrInt;
  i,il1,il2: longint;
  ic: TSummColInf;
begin
  AddStack('FFdp.SummCopyLine');
  result:=null;
  with Summ do begin
    il1:=AddLine(av[1]); il2:=AddLine(av[2]);
    for i:=0 to ArrName(s_col,ac,IsNilc(av[3],''))-1 do begin
      ic:=ColInf(ac[i]); SetV(il2,ic,Value(ic,il1));
    end;
  end;
  DelStack;
end;

function FrmStat(var fStat: TForm): boolean;
begin
  AddStack('FFdp.FrmStat');
  if not Assigned(fStat) and Assigned(CurFdp) then with CurFdp do
    if Assigned(FormStat) then fStat:=FormStat
    else if Assigned(FormWait) then fStat:=FormWait;
  result:=Assigned(fStat);
  DelStack;
end;

// Вывести таблицу в документ
function SDPart(const sBeg: string; const aShape,aPart,PgHead,PgFoot,aDocHead,aDocFoot: variant;
  Opt: TSDPartOpt = []; fStat: TForm = nil; pPgHeadFoot: PVariant = nil; pNoFitOnPage: PVariant = nil;
  Proc: TSDPartProc = nil): boolean;
  procedure avInit(paShape: PVariant; var isShape: boolean; var lows,highs: longint);
  begin
    AddStack('FFdp.SDPart.avInit');
    if Assigned(paShape) then begin
      isShape := MyVarType(paShape^)=varArray;
      if isShape then begin
        lows:=VarArrayLowBound(paShape^,1); highs:=VarArrayHighBound(paShape^,1);
      end
      else begin
        lows:=1; highs:=0;
      end;
    end
    else isShape:=false;
    DelStack;
  end;
  function LsArr(const s: string; var a: TSegmStr): longint;
  begin
    AddStack('FFdp.SDPart.LsArr');
    result:=LsArrFill(s,a,GFSegmDlm);
    if RightStr(TrimRight(s),1)<>GFSegmDlm then Inc(result);
    DelStack;
  end;
var ass,asl: TSegmStr;
	procedure DcmAPart(const a: variant; lMask: boolean = false);
  	procedure DcmPart1(const a: variant);
    var lsl,lss,j: longint;
    	fl: boolean;
      s: variant;
    begin
	  	AddStack('FFdp.SDPart.DcmAPart.DcmPart1');
      s:=a;
      if lMask then
      	if MyVarType(s)=varString then
          if Pos(UnDelim,s)>0 then begin
            lsl:=LsArr(CurFdp.CurLine,asl); lss:=LsArr(s,ass);
            if lss=lsl then begin
              // Замена '#' на значения в наименовании раздела
              for j:=low(ass) to high(ass) do
                if ass[j]=UnDelim then ass[j]:=asl[j];
              fl := RightStr(Trim(s),1)=GFSegmDlm;
              s:=ArrayAsList(ass,GFSegmDlm,lss);
              if not fl then SubStrSelf(s,1,-1);
            end;
          end;
      DcmPart(s);
      DelStack;
    end;
  var i,j: longint;
  begin
  	AddStack('FFdp.SDPart.DcmAPart');
    case MyVarType(a) of
      varNull: ;
      varArray: for i:=VarArrayLowBound(a,1) to VarArrayHighBound(a,1) do
        case MyVarType(a[i]) of
          varNull: ;
          varArray:
            if sdpDpg in Opt then vDcmDpg(a[i])
            else begin
              DcmPart(0);
              for j:=VarArrayLowBound(a[i],1) to VarArrayHighBound(a[i],1) do DcmPart1(a[i][j]);
              DcmPart(0);
            end;
        else DcmPart1(a[i]);
        end
    else DcmPart1(a);
    end;
    DelStack;
  end;
var a: TArrStr;
	lows,highs,lowsPg,highsPg,i,j,p,l,lsl: longint;
  fl,isShape,isPgHeadFoot: boolean;
  ph,pf: variant;
label lend;
begin
	AddStack('FFdp.SDPart');
  result:=false;
  if Assigned(CurFdp) then begin
  	if not CurFdp.GF.FileBufActive then DcmForm;
    avInit(@aShape,isShape,lows,highs);
    avInit(pPgHeadFoot,isPgHeadFoot,lowsPg,highsPg);
    if Assigned(pNoFitOnPage) then CurFdp.NoFitOnPage:=pNoFitOnPage^ else CurFdp.NoFitOnPage:=null;
    DcmHFPage(gfHead,PgHead); DcmHFPage(gfFoot,PgFoot);
    DcmAPart(aDocHead);
    l:=Summ.ArrName(s_line,a,sBeg)-1;
    FrmStat(fStat);
    for i:=0 to l do begin
      if not(sdpNoSayStat in Opt) then
        if DcmSayStat('',stLeaf+Format(' %d  Строка: %d из %d',[CurFdp.GF.Leaf,i+1,l+1]),(i+1)/(l+1),fStat)
        then goto lend;
      CurFdp.CurLine:=a[i];
      if Assigned(Proc) then Proc(i);
      p:=lows-1;
      if isShape then for j:=lows to highs do if EqualShape(CurFdp.CurLine,aShape[j]) then begin
        p:=j; break;
      end;
      fl:=not((i<l) and (p<lows));
      if not fl then begin
        lsl:=LsArrFill(CurFdp.CurLine,asl,GFSegmDlm); LsArrFill(a[i+1],ass,GFSegmDlm);
        for j:=1 to lsl do if asl[j]<>ass[j] then begin
          fl:=true; break;
        end;
      end;
      if fl then begin
        if IsPgHeadFoot then begin
          ph:=PgHead; pf:=PgFoot;
          for j:=lowsPg to highsPg do
            if EqualShape(CurFdp.CurLine,pPgHeadFoot^[j][1]) then begin
              if not IsNil(pPgHeadFoot^[j][2]) then ph:=pPgHeadFoot^[j][2];
              if not IsNil(pPgHeadFoot^[j][3]) then pf:=pPgHeadFoot^[j][3];
              break;
            end;
          DcmHFPage(gfHead,ph); DcmHFPage(gfFoot,pf);
        end;
        if p<lows then DcmPart(CurFdp.CurLine) else DcmAPart(aPart[p],true);
      end;
    end;
    CurFdp.CurLine:=''; DcmAPart(aDocFoot); result:=true;
  end;
lend:
  DelStack;
end;

function SDPart(var av: array of variant): variant; overload;
begin
  result:=SDPart(av[1],av[2],av[3],IsNilc(av[4],''),IsNilc(av[5],''),av[6],av[7],
    IfThen(not IsNilc(av[8],true),sdpNoSayStat)+IfThen(IsNilc(av[9],false),sdpDpg),nil,@av[10],@av[11]);
end;

// Вывести индикатор
function DcmSayStat(const Capt: TCaption; const st: TCaption = ' '; prc: Double = 0; fStat: TForm = nil): boolean;
begin
	AddStack('FFdp.DcmSayStat');
	result:=false;
  if FrmStat(fStat) then
    if fStat is TStat then result:=TStat(fStat).SayStat(Capt,st,prc)
    else if fStat is TAsk then result:=TAsk(fStat).SayCapt([st]);
  DelStack;
end;

function DcmSayStat(const Capt: TCaption; fStat: TForm): boolean;
begin
  result:=DcmSayStat(Capt,' ',0,fStat);
end;

function DcmSayStat(prc: Double; fStat: TForm = nil): boolean;
begin
  result:=DcmSayStat('','',prc,fStat);
end;

function DcmAborted;
begin
	AddStack('FFdp.DcmAborted');
	result:=false;
  if FrmStat(fStat) then
    if fStat is TStat then result:=TStat(fStat).Aborted
    else if fStat is TAsk then result:=TAsk(fStat).Aborted;
  DelStack;
end;

function DcmSayStat(var av: array of variant): variant; overload;
begin
	result:=DcmSayStat(IsNilc(av[1],''),IsNilc(av[2],''),IsNilc(av[3],0));
end;

procedure DcmClearTime;
begin
	AddStack('FFdp.DcmClearTime');
  if FrmStat(fStat) then
  	if fStat is TStat then TStat(fStat).ClearTime;
  DelStack;
end;

// Выводит окно ввода данных/параметров
function DcmGetWnd(CanShow: TDECanShow = desAlways; wType: TGFWinList = gfwDat;
	lDWSeek: boolean = true): boolean;
var r: TDEExitResult;
	rdb: TRecDBDef;
begin
	AddStack('FFdp.DcmGetWnd');
  if Assigned(CurFdp) then begin
    TEdGenFr.LoadWait; TDWWin.CreateOne(CurFdp.dw,CurFdp).dw.DoSetting(EdGenFr.GF.awWin[wType]);
    if wType=gfwPrm then begin
    	lDWSeek:=true; rdb:=EdGenFr.RDocpPrm;
    end
    else rdb:=EdGenFr.RDocPrm;
    r:=CurFdp.dw.Execute(EdGenFr.GF.awWin[wType],aWinExec[wType,1]+'.'+CurFdp.GF.FileName,
      rdb,aWinExec[wType,2],[IfThen(not lDWSeek,1)],aWinExec[wType,3],CanShow);
    if not FdpFormOnView and (wType=gfwDat) and not r.WasShow and (CanShow<>desNever)
    then result:=Ask(['Выполнить формирование документа ?'])
    else result:=not r.WasShow or r.Saved;
    CurFdp.DateTimeBeg:=Now;
    if Assigned(CurFdp.FormStat) then with CurFdp.FormStat do begin
      ClearTime; Refresh;
    end;
    if Assigned(CurFdp.FormWait) then CurFdp.FormWait.Refresh;
  end
  else result:=false;
  DelStack;
end;

function IfThenDcmGetWnd;
begin
  if usl then result:=DcmGetWnd(CanShow,wType,lDWSeek) else result:=true;
end;

function DcmGetWnd(var av: array of variant): variant; overload;
begin
	result:=DcmGetWnd(iif(IsNilc(av[1],true),desAlways,desNoReadOnly),
  	TGFWinList(EnsureRange(Bool2Int(av[2]),byte(low(aWinExec)),byte(high(aWinExec)))));
end;

function DcmPrmWnd;
var odws: TNotifyEvent;
	dw: TDWWin;
	r: TDEExitResult;
begin
  AddStack('FFdp.DcmPrmWnd');
  TEdGenFr.LoadWait;
  with EdGenFr,RDocpPrm do begin
    odws:=OnDWSeek; CurFileDtg:=IfThen(FileDtg='',FileDcm,FileDtg); OnDWSeek:=TNone.RDocpPrmDWSeek;
    GF.OpenDcm(FileDcm); dw:=TDWWin.Create(Application.MainForm);
    try
      TDWPrm.VarCreate(RDocpPrm);
      r:=dw.Execute(EdGenFr.GF.awWin[gfwPrm],aWinExec[gfwPrm,1]+'.'+CurFileDtg,EdGenFr.RDocpPrm,
      	aWinExec[gfwPrm,2],[0],IfThen(Capt='',aWinExec[gfwPrm,3],Capt),CanShow);
      TDWPrm.VarFree(RDocpPrm); result:=not r.WasShow or r.Saved;
    finally
      dw.Free;
    end;
    OnDWSeek:=odws;
  end;
  DelStack;
end;

function VarCurGF;
const ap: array[TVarCurGFList] of TByteSet = // 1-параметры формы,2-необязат.из док.
  ([]  //vgfNameCol
  ,[]  //vgfNamePart
  ,[]  //vgfCurPageName
  ,[]  //vgfLeaf
  ,[]  //vgfPage
  ,[]  //vgfFootPage
  ,[]  //vgfHeadPage
  ,[]  //vgfPrimBegPage
  ,[]  //vgfPrimPage
  ,[]  //vgfDateTimeBeg
  ,[]  //vgfDateTimeBegStr
  ,[]  //vgfCurLine
  ,[1] //vgfSpLeftMm
  ,[1] //vgfSpRightMm
  ,[1] //vgfSpTopMm
  ,[1] //vgfSpBottomMm
  ,[1] //vgfWidthMm
  ,[1] //vgfHeightMm
  ,[1] //vgfStdFormat
  ,[1] //vgfNFormat
  ,[1] //vgfOrientation
  ,[1] //vgfGridLineWidth
  ,[1] //vgfDateTime
  ,[1] //vgfNumFracDlm
  ,[1] //vgfNumAllCnt
  ,[1] //vgfNumFracCnt
  ,[1] //vgfNumFracEmp
  ,[1] //vgfNumDigIsDlm
  ,[1] //vgfNumDigDlm
  ,[1] //vgfNumZeroEmp
  ,[1] //vgfNumsZero
  ,[1] //vgfDateDlm
  ,[1] //vgfDateNYear
  ,[1] //vgfDateMMYY
  ,[1] //vgfDateZeroEmp
  ,[1] //vgfDatesZero
  ,[]  //vgfCurPagePart
  ,[]  //vgfCurPageFirst
  ,[]  //vgfCurParams
  ,[]  //vgfVArrPart
  ,[]  //vgfDcmLeaf
  ,[2] //vgfNSumm
  ,[1] //vgfGridLineMin
  ,[1] //vgfHorzBreak
  ,[1] //vgfVertBreak
  ,[1] //vgfHorzWidth
  ,[1] //vgfVertWidth
  ,[]  //vgfDynAnyLevel
  ,[]  //vgfBlockLeaf
  ,[]  //vgfAutoNewPageObjSpace
  ,[]  //vgfSpotPrn
  );
var p: TGFParams;
  i: TVarCurGFList;
	j: longint;
  av: array[1..1] of variant;
  GF: TGenForm;
  hf: TGFHeadFoot;
  a: TArrStr;
label lend;
begin
  i:=ind;
	AddStack('FFdp.VarCurGF');
  GF:=CurFdpGF;
  if Assigned(CurFdp) then PointerDef(pointer(GF),CurFdp.GF);
  if PointerDef(pointer(GF),CurDEGF) or (2 in ap[i]) then with GF do begin
    case i of
      vgfNameCol: result:=NameCol;
      vgfNamePart: result:=NamePart;
      vgfCurPageName: result:=CurPageName;
      vgfLeaf: result:=Leaf-BlockLeafBeg;
      vgfPage: result:=Page;
      vgfDateTimeBeg: result:=Double(CurFdp.DateTimeBeg);
      vgfDateTimeBegStr: if Params.DateTime
      	then result:=FormatDateTime('Дата формирования: dd/mm/yyyy (hh:nn)',CurFdp.DateTimeBeg)
        else result:='';
      vgfCurLine: result:=CurFdp.CurLine;
      vgfSpLeftMm: result:=Params.Arr[CurParams].SpotMm.Left;
      vgfSpRightMm: result:=Params.Arr[CurParams].SpotMm.Right;
      vgfSpTopMm: result:=Params.Arr[CurParams].SpotMm.Top;
      vgfSpBottomMm: result:=Params.Arr[CurParams].SpotMm.Bottom;
      vgfWidthMm: result:=Params.Arr[CurParams].SizeMm.cX;
      vgfHeightMm: result:=Params.Arr[CurParams].SizeMm.cY;
      vgfStdFormat: result:=Params.Arr[CurParams].StdFormat;
      vgfNFormat: result:=Params.Arr[CurParams].NFormat;
      vgfOrientation: result:=Params.Arr[CurParams].Orientation;
      vgfGridLineWidth: result:=Params.Arr[CurParams].GridLineWidth;
      vgfDateTime: result:=Params.DateTime;
      vgfNumFracDlm: result:=Params.Arr[CurParams].PrmNum.FracDlm;
      vgfNumAllCnt: result:=Params.Arr[CurParams].PrmNum.AllCnt;
      vgfNumFracCnt: result:=Params.Arr[CurParams].PrmNum.FracCnt;
      vgfNumFracEmp: result:=FracEmp2Bool(Params.Arr[CurParams].PrmNum.FracEmp);
      vgfNumDigIsDlm: result:=Params.Arr[CurParams].PrmNum.DigIsDlm;
      vgfNumDigDlm: result:=Params.Arr[CurParams].PrmNum.DigDlm;
      vgfNumZeroEmp: result:=Params.Arr[CurParams].PrmNum.ZeroEmp.l;
      vgfDateDlm: result:=Params.Arr[CurParams].PrmDate.Dlm;
      vgfDateNYear: result:=Params.Arr[CurParams].PrmDate.NYear;
      vgfCurPagePart: result:=CurPagePart;
      vgfCurPageFirst: result:=CurPageFirst;
      vgfCurParams: result:=CurParams+1;
      vgfVArrPart: result:=VArrPart;
      vgfDcmLeaf: result:=EdGenFr.GF.Leaf;
      vgfNSumm:
        if lSave and IsNil(v) then begin // Поиск первой пустой таблицы
          result:=ArrVarToVar([nSumm,null]); nSumm:=1;
          while (Summ.aName[s_line].Count>0) or (Summ.aName[s_col].Count>0) do Inc(nSumm);
          result[2]:=nSumm;
        end
        else result:=nSumm;
      vgfGridLineMin: result:=Params.Arr[CurParams].GridLineMin;
      vgfHorzBreak: result := false in Params.Arr[CurParams].aBreak;
      vgfVertBreak: result := true in Params.Arr[CurParams].aBreak;
      vgfHorzWidth: result := false in Params.Arr[CurParams].aWidth;
      vgfVertWidth: result := true in Params.Arr[CurParams].aWidth;
      vgfNumsZero: result:=Params.Arr[CurParams].PrmNum.ZeroEmp.s;
      vgfDateZeroEmp: result:=Params.Arr[CurParams].PrmDate.ZeroEmp.l;
      vgfDatesZero: result:=Params.Arr[CurParams].PrmDate.ZeroEmp.s;
      vgfDateMMYY: result:=Params.Arr[CurParams].PrmDate.MMYY;
      vgfDynAnyLevel: result:=DynAnyLevel;
      vgfBlockLeaf: result:=BlockLeaf;
      vgfAutoNewPageObjSpace: result:=AutoNewPageObjSpace;
      vgfSpotPrn: with Params.Arr[CurParams],GFCalcSpotPrn(NFormat,Orientation) do
        result:=ArrVarToVar([Left,Right,Top,Bottom]);
    else
      for hf:=low(aHFVarCurGF) to high(aHFVarCurGF) do if aHFVarCurGF[hf]=i then begin
        GetHFPage(hf,a);
        case Length(a) of
          0: result:='';
          1: result:=a[0];
        else result:=ArrStrToVar(a,1);
        end;
        if lSave then
          if CompVar(v,'') then SetHFPage(hf,[])
          else if ArrIntMatch(MyVarType(v),[varString,varArray]) then begin
            CopyFromVar(a,v); SetHFPage(hf,a);
          end;
        goto lend;
      end;
    end;
    if lSave then begin
      if 1 in ap[i] then p:=GFCopyParams(Params);
      if Assigned(GF) then j:=CurParams else j:=0;
      with p.Arr[j] do case i of
        vgfCurPageName: CurPageName:=v;
        vgfSpLeftMm: SpotMm.Left:=v;
        vgfSpRightMm: SpotMm.Right:=v;
        vgfSpTopMm: SpotMm.Top:=v;
        vgfSpBottomMm: SpotMm.Bottom:=v;
        vgfWidthMm: if not StdFormat then SizeMm.cX:=v;
        vgfHeightMm: if not StdFormat then SizeMm.cY:=v;
        vgfStdFormat,vgfNFormat,vgfOrientation: begin
          case i of
            vgfStdFormat: StdFormat:=v;
            vgfNFormat: NFormat:=v;
            vgfOrientation: Orientation:=v;
          end;
          if StdFormat then SizeMm:=TGenForm.GetStdSize(NFormat,Orientation);
        end;
        vgfGridLineWidth: GridLineWidth:=v;
        vgfDateTime: p.DateTime:=v;
        vgfNumFracDlm: PrmNum.FracDlm:=StrToChar(v);
        vgfNumAllCnt: PrmNum.AllCnt:=v;
        vgfNumFracCnt: PrmNum.FracCnt:=v;
        vgfNumFracEmp: PrmNum.FracEmp:=Bool2FracEmp(v);
        vgfNumDigIsDlm: PrmNum.DigIsDlm:=v;
        vgfNumDigDlm: PrmNum.DigDlm:=StrToChar(v);
        vgfNumZeroEmp: PrmNum.ZeroEmp.l:=v;
        vgfDateDlm: PrmDate.Dlm:=StrToChar(v);
        vgfDateNYear: PrmDate.NYear:=v;
        vgfCurPagePart: CurPagePart:=v;
        vgfCurPageFirst: CurPageFirst:=v;
      	vgfCurParams: CurParams:=v-1;
      	vgfDcmLeaf: DcmForm(av,nil,v,[dcmfOnlyCngLeaf,dcmfDynamicPart]);
        vgfNSumm:
          case MyVarType(v) of
            varNull:;
            varArray: begin // Освобождение первой найденной пустой таблицы
              nSumm:=v[2]; Summ.Init; nSumm:=v[1];
            end
          else
            if InRange(v,low(aSumm),high(aSumm)) then nSumm:=v
            else raise EInterAnyError.CreateFmt(
            'Номер текущей таблицы должен быть от %d до %d',[low(aSumm),high(aSumm)],VarNSumm);
          end;
        vgfGridLineMin: GridLineMin:=v;
        vgfHorzBreak: SetSet(aBreak,false,v);
        vgfVertBreak: SetSet(aBreak,true,v);
        vgfHorzWidth: SetSet(aWidth,false,v);
        vgfVertWidth: SetSet(aWidth,true,v);
        vgfNumsZero: PrmNum.ZeroEmp.s:=v;
        vgfDateZeroEmp: PrmDate.ZeroEmp.l:=v;
        vgfDatesZero: PrmDate.ZeroEmp.s:=v;
        vgfDateMMYY: PrmDate.MMYY:=v;
        vgfDynAnyLevel: DynAnyLevel:=v;
        vgfBlockLeaf: BlockLeaf:=v;
        vgfAutoNewPageObjSpace: AutoNewPageObjSpace:=v;
      else raise EInterConstException.Create;
      end;
      if 1 in ap[i] then Params:=GFCopyParams(p);
    end;
  end;
lend:
  DelStack;
end;

function NumSumm(const v: variant; lSave: boolean = true): variant;
begin
  result:=VarCurGF(v,vgfNSumm,lSave);
end;

function NumSumm: variant;
begin
  result:=NumSumm(null,false);
end;

function SegmentPart(var av: array of variant): variant; overload;
begin
	result:=SegmentPart(av[1]);
end;

function SegmentCol(var av: array of variant): variant; overload;
begin
	result:=SegmentCol(av[1]);
end;

procedure StArrCondRound(Sender: TStat; const Params: array of variant; var Aborted: boolean);
  procedure aSet(n: byte; var a: variant; var h: longint);
  begin
    AddStack('FFdp.StArrCondRound.aSet');
    a:=Params[n];
    if MyVarType(a)=varArray then h:=VarArrayHighBound(a,1) else h:=-1;
    DelStack;
  end;
  function aAdd(const aMatrix: variant; var a: variant; var ha,l,h: longint; lDop: byte = 0): longint;
  begin
    AddStack('FFdp.StArrCondRound.aAdd');
    l:=VarArrayLowBound(aMatrix,1); h:=VarArrayHighBound(aMatrix,1); result:=h-l+1+lDop;
    if ha=-1 then begin
      a:=VarArrayCreate([1,result],varVariant); ha:=0;
    end
    else VarArrayRedim(a,ha+result);
    DelStack;
  end;
  function aLen(const a: variant; var l,h: longint; const aInc: array of PLongint): boolean;
  var i,ll: longint;
  begin
    AddStack('FFdp.StArrCondRound.aLen');
    result := MyVarType(a)=varArray;
    if result then begin
      if h=-1 then h:=VarArrayHighBound(a,1);
      l:=VarArrayLowBound(a,1); ll:=h-l+1;
      for i:=low(aInc) to high(aInc) do Inc(aInc[i]^,ll);
    end
    else l:=0;
    DelStack;
  end;
  procedure aRedim(var a: variant; var h: longint);
  begin
    AddStack('FFdp.StArrCondRound.aRedim');
    if h>0 then VarArrayRedim(a,h)
    else begin
      a:=false; h:=-1;
    end;
    DelStack;
  end;
type
  TColOpt = (clRndCorr,clRndSet,clRndNoBound,clNot0,clCngSgn,clEqual);
  TColOpts = set of TColOpt;
  TCol = packed record
    v: Extended;
    vRnd: Int64; // на W'98 вылетает расчёт по ЕСН, надо использовать другую переменную longint;
    Opt: TColOpts;
    nVal,nl1,Prioritet: longint;
    a: array of Extended;
  end;
  TArrCol = array of TCol;
  TLine = record
    calc: boolean;
    Prioritet: longint;
  end;
var i,ll,nc: longint;
  ac0: TArrCol;
  procedure InitCol;
  begin
    AddStack('FFdp.StArrCondRound.InitCol');
    with ac0[nc] do begin
      Opt:=[]; nVal:=i; nl1:=-1; Prioritet:=0; SetLength(a,ll);
    end;
    DelStack;
  end;
  procedure ac0Opt(Incl: TColOpts; Excl: TColOpts = []);
  begin
    with ac0[nc] do Opt:=Opt+Incl-Excl;
  end;
var ac: TArrCol;
  function ValPrioritet(i: longint): byte;
  begin
    AddStack('FFdp.StArrCondRound.ValPrioritet');
    with ac[i] do result := IfThen((clRndCorr in Opt) and not(clRndNoBound in Opt)
      or empty(v) and not(clCngSgn in Opt), 3, IfThen(clNot0 in Opt,2,1));
    DelStack;
  end;
var c: TCol;
  procedure ValSort(l,r: longint);
  var p,pp: longint;
    function SCompare(i: longint): Extended;
    begin
      AddStack('FFdp.StArrCondRound.ValSort.SCompare');
      result:=ValPrioritet(i)-pp;
      if result=0 then case pp of
        1: result:=Abs(ac[p].v-nround(ac[p].v))-Abs(ac[i].v-nround(ac[i].v));
        2: result:=Abs(ac[p].v)-Abs(ac[i].v);
      end;
      DelStack;
    end;
  var i,j: longint;
  begin
    AddStack('FFdp.StArrCondRound.ValSort');
    repeat
      i:=l; j:=r; p := (l+r) shr 1; pp:=ValPrioritet(p);
      repeat
        while SCompare(i)<0 do Inc(i);
        while SCompare(j)>0 do Dec(j);
        if i<=j then begin
          if i<j then begin
            c:=ac[i]; ac[i]:=ac[j]; ac[j]:=c;
          end;
          if p=i then p:=j
          else if p=j then p:=i;
          Inc(i); Dec(j);
        end;
      until i>j;
      if l<j then ValSort(l,j);
      l:=i;
    until i>=r;
    DelStack;
  end;
  function acCor(nc: longint; vRnd: Int64): boolean;
  begin
    {$IFDEF STACKALL}AddStack('FFdp.StArrCondRound.acCor');{$ENDIF}
    result := clCngSgn in ac[nc].Opt;
    if not result then
      if empty(ac[nc].v) then result := vRnd=0
      else begin
        result:=IfThen(ac[nc].v<0,vRnd<=0,vRnd>=0);
        if result and (clNot0 in ac[nc].Opt) then result := vRnd<>0;
      end;
    {$IFDEF STACKALL}DelStack;{$ENDIF}
  end;
var offsMin: Extended;
  ncBasis,lVal,lc: longint;
  res: PVariant;
  resEq: TArrInt;
{$IFDEF ARRCONDTEST}
  fTest: TFileBuf;
  nSp: byte;
  PrNValInf: TPrNValInf;
  function ColInf(const c: TCol): string;
  const ao: array[TColOpt] of char = ('R','S','N','0','Z','E');
  var o: TColOpt;
    so: string;
  begin
    AddStack('FFdp.StArrCondRound.ColInf');
    result:=PrNValInf(c.nVal);
    if clEqual in c.Opt then result:=Padr(IntToStr(c.nVal),Length(result));
    SetLength(so,Length(ao));
    for o:=low(ao) to high(ao) do so[byte(o)+1]:=IfThenChar(o in c.Opt,ao[o]);
    IncL(result,Space(nsp),'('+so+')');
    DelStack;
  end;
{$ENDIF}
  function Calc(offs: Extended): boolean;
  var i,j: longint;
    offs1,v1: Extended;
{$IFDEF ARRCONDTEST}
    procedure Wr1(i: longint);
    begin
      {$IFDEF STACKALL}AddStack('FFdp.StArrCondRound.Calc.Wr1');{$ENDIF}
      with ac[i] do fTest.WriteString(Format('%s:(%g)%g -> %d',[ColInf(ac[i]),a[ac[j].nl1],v,vRnd]),[wrCrlf]);
      {$IFDEF STACKALL}DelStack;{$ENDIF}
    end;
{$ENDIF}
  begin
    {$IFDEF STACKALL}AddStack('FFdp.StArrCondRound.Calc');{$ENDIF}
    offs1:=0; result:=true;
    for j:=0 to ncBasis-1 do with ac[j] do begin
      v1:=0;
      for i:=ncBasis to lc-1 do
        if ac[i].vRnd<>0 then IncD(v1,ac[i].vRnd*ac[i].a[nl1]);
      vRnd:=-nRound(v1);
      if not acCor(j,vRnd) then begin
{$IFDEF ARRCONDTEST}
        Wr1(j); Inc(nSp);
        for i:=ncBasis to lc-1 do
          if not empty(ac[i].a[nl1]) then Wr1(i);
        Dec(nSp);
{$ENDIF}
        result:=false; break;
      end;
      IncD(offs1,IntPower(Abs(v-vRnd)*IfThen((clRndNoBound in Opt) and (nround(v)<>vRnd),10,1),2));
    end;
    if result then begin
      IncD(offs1,offs); result := offs1<offsMin;
      if result then begin
        offsMin:=offs1;
        for i:=0 to lc-1 do with ac[i] do
          if clEqual in Opt then resEq[nVal]:=vRnd
          else if nVal>=lVal then res^[nVal]:=vRnd;
      end;
    end;
    {$IFDEF STACKALL}DelStack;{$ENDIF}
  end;
var avsl: TValueSignBool;
  aCngBasis: array of record
    aCor: TBoolSet;
    avs: array[TValueSign] of record
      v: Int64;
      offs: Extended;
    end;
  end;
  procedure avsOffs(i: longint);
  var nc: longint;
    fl: boolean;
    vs: TValueSign;
  begin
    AddStack('FFdp.StArrCondRound.avsOffs');
    nc:=ncBasis+i;
    with aCngBasis[i] do for vs:=low(avs) to high(avs) do begin
      avs[vs].v:=ac[nc].vRnd+vs; fl:=avsl[vs]; SetSet(aCor,fl,acCor(nc,avs[vs].v));
      if fl in aCor then avs[vs].offs:=IntPower(Abs(ac[nc].v-avs[vs].v),2);
    end;
    DelStack;
  end;
//  {$IFDEF ARRCONDTEST}; PrNValInf: TPrNValInf = nil{$ENDIF}
const aSign: TArrBoolSign = (-1,1);
var aVal,aSum,aEqual,aMatrix,v,v1: variant;
  FloatDec: byte;
  result: PVariant;
  j,l,h,nl,hVal,lSum,hSum,lEq,hEq,ncCng,i1,i21,i22,ngl,ipr,lpr,lpr1,hpr,lc0{$IFDEF ARRCONDTEST},nstep{$ENDIF}: longint;
  d,offs0,offs2: Extended;
  vs,vs1,vs2,vs21,vs22: TValueSign;
  fl,fl1: boolean;
  sl,sc: string;
  ls: TStringList;
  lspr: TIntegerList;
  al: array of TLine;
  alpr: TArrInt;
  //p: Pointer;
label lend;
begin
  AddStack('FFdp.StArrCondRound');
  //ProfSwitch:=true; ProfOn;
  res:=PointerVar(Params[0]);
  aSet(1,aVal,hVal); aSet(2,aSum,hSum); aSet(3,aEqual,hEq);
  aMatrix:=Params[4];
  FloatDec:=Params[5];
{$IFDEF ARRCONDTEST}
  fTest:=TFileBuf.Create('C'+DriveDelim+PathDelim+'MyMsg.txt',true); nSp:=0;
  PrNValInf:=IfThen(PointerVar(Params[6]),@IntToStr);
{$ENDIF}
  if MyVarType(aMatrix)=varArray then begin
    ls:=SortStrListCreate;
    try
      if hVal>0 then for i:=VarArrayLowBound(aVal,1) to hVal do
        if MyVarType(aVal[i])=varArray then begin
          l:=VarArrayLowBound(aVal[i],1)+3;
          if l<VarArrayHighBound(aVal[i],1) then
            if (MyVarType(aVal[i][l])=varString) and (MyVarType(aVal[i][l+1])=varString)
            then ls.AddObject(aVal[i][l]+UnDelim+aVal[i][l+1],pointer(i));
        end;
      for i:=VarArrayLowBound(aMatrix,1) to VarArrayHighBound(aMatrix,1) do
        if MyVarType(aMatrix[i])=varArray then begin
          aAdd(aMatrix[i][1],aSum,hSum,l,h); aAdd(aMatrix[i][1],aEqual,hEq,l,h);
          for j:=l to h do begin
            ngl:=hVal+aAdd(aMatrix[i][1][j],aVal,hVal,lEq,i21,1); InitArrLen(v,1,ngl,null); offs0:=0;
            for i1:=lEq to i21 do begin
              v1:=aMatrix[i][1][j][i1][1]; sl:=aMatrix[i][1][j][i1][2]; sc:=aMatrix[i][1][j][i1][3];
              if not IgnoreSlFindAdd(ls,sl+UnDelim+sc,nc) then begin
                Inc(hVal); aVal[hVal]:=ArrVarToVar([v1,null,null,sl,sc,aMatrix[i][2]]);
                ls.Objects[nc]:=pointer(hVal);
              end;
              IntObjSelf(ls,nc); nl:=aMatrix[i][1][j][i1][4];
              if nl=0 then begin // В т.ч.
                Inc(hVal); aVal[hVal]:=ArrVarToVar([mround(offs0,FloatDec),null,null,null,null,aMatrix[i][2]]);
                v[hVal]:=-1;
                Inc(hEq);
                if hEq>VarArrayHighBound(aEqual,1) then VarArrayRedim(aEqual,hEq);
                aEqual[hEq]:=ArrVarToVar([hVal,nc]);
              end
              else begin
                IncD(offs0,v1); v[nc]:=nl;
              end;
            end;
            Inc(hSum); aSum[hSum]:=v;
          end;
        end;
      aRedim(aVal,hVal); aRedim(aEqual,hEq);
    finally
      ls.Free;
    end;
  end;
  res^:=aVal; lc0:=0; lspr:=TIntegerList.Create([ilsSorted]);
  try
    if aLen(aVal,lVal,hVal,[@lc0]) then begin
      ll:=0;
      aLen(aSum,lSum,hSum,[@ll]);
      aLen(aEqual,lEq,hEq,[@lc0,@ll]);
      if ll>0 then begin
        SetLength(al,ll); nl:=0; SetLength(ac0,lc0); nc:=0;
        // Заданные столбцы и значения
        for i:=lVal to hVal do begin
          InitCol;
          if MyVarType(aVal[i])=varArray then begin
            l:=VarArrayLowBound(aVal[i],1); h:=VarArrayHighBound(aVal[i],1);
            if IsNil(aVal[i][l]) then begin
              ac0[nc].v:=0;
              if l+3<h then
                if (MyVarType(aVal[i][l+3])=varString) and (MyVarType(aVal[i][l+4])=varString)
                then ac0[nc].v:=Summ.Value(aVal[i][l+4],aVal[i][l+3])
            end
            else ac0[nc].v:=aVal[i][l];
            if l<h then begin
              Inc(l);
              case MyVarType(aVal[i][l],true) of
                varDouble: begin
                  ac0Opt([clRndCorr,clRndSet]); ac0[nc].vRnd:=aVal[i][l];
                end;
                varString: case Int0(aVal[i][l]) of
                  1: ac0Opt([clRndCorr]);
                  2: ac0Opt([clRndCorr,clRndNoBound]);
                  3: ac0Opt([clCngSgn]);
                end;
              else if not empty(aVal[i][l]) then ac0Opt([clRndCorr]);
              end;
              if l<h then begin
                Inc(l);
                if not empty(aVal[i][l]) then ac0Opt([clNot0]);
                Inc(l,3);
                if l<=h then ac0[nc].Prioritet:=aVal[i][l];
              end;
            end;
          end
          else ac0[nc].v:=aVal[i];
          MroundSelf(ac0[nc].v,FloatDec); lspr.Add(ac0[nc].Prioritet); Inc(nc);
        end;
        // Строки из массива сумм
        for i:=lSum to hSum do begin
          al[nl].calc:=false; al[nl].Prioritet:=0; d:=0; v:=aSum[i]; h:=0;
          for l:=VarArrayLowBound(v,1) to VarArrayHighBound(v,1) do begin
            if h=lc0 then break;
            if not empty(v[l]) then
              if MyVarType(v[l],true)=varDouble then begin
                ac0[h].a[nl]:=v[l]; IncD(d,mround(ac0[h].v*ac0[h].a[nl],FloatDec));
                MaxSelf(al[nl].Prioritet,ac0[h].Prioritet);
              end;
            Inc(h);
          end;
          // Неокруглённые значения не соответствуют массиву сумм
          if mround(d,FloatDec)<>0 then begin
{$IFDEF ARRCONDTEST}
            fTest.WriteString(Format('%g',[d]),[wrCrlf]); h:=0;
            for l:=VarArrayLowBound(v,1) to VarArrayHighBound(v,1) do begin
              if h=lc0 then break;
              if not empty(v[l]) then
                if MyVarType(v[l],true)=varDouble then with ac0[h] do
                  fTest.WriteString(Format('%s:(%g)%g',[ColInf(ac0[h]),a[nl],v]),[wrCrlf]);
              Inc(h);
            end;
{$ENDIF}
            res^:=null; goto lend;
          end;
          Inc(nl);
        end;
        // Строки и столбцы из условно равных пар
        SetLength(resEq,hEq-lEq+1); i:=low(resEq);
        for j:=lEq to hEq do begin
          v:=aEqual[j]; l:=VarArrayLowBound(v,1); i21:=v[l]-lVal; i22:=v[l+1]-lVal;
          if mround(ac0[i21].v-ac0[i22].v,FloatDec)=0 then begin
            InitCol; ac0Opt([clEqual]); ac0[nc].v:=0;
            ac0[i21].a[nl]:=-1; ac0[i22].a[nl]:=1; ac0[nc].a[nl]:=1;
            if VarArrayHighBound(v,1)>l+1 then case byte(IsNilc(v[l+2],0)) of
              1: ac0Opt([clNot0]);
              2: ac0Opt([clCngSgn]);
            end;
            ac0[nc].Prioritet:=max(ac0[i21].Prioritet,ac0[i22].Prioritet);
            al[nl].calc:=false; al[nl].Prioritet:=ac0[nc].Prioritet;
            Inc(nc); Inc(nl); Inc(i);
          end;
        end;
        i:=Length(resEq)-i; Dec(ll,i); Dec(lc0,i);
        SetLength(c.a,ll); SetLength(alpr,ll);
        for fl:=false to true do avsl[aSign[fl]]:=fl;
        avsl[0]:=true;
        for ipr:=0 to lspr.Count-1 do begin
          if Sender.SayStat('',Format('Этап: %d из %d',[ipr+1,lspr.Count]),(ipr+1)/lspr.Count) then begin
            res^:=null; goto lend;
          end;
          // Строки с приоритетом lspr[ipr]
          hpr:=-1;
          for nl:=0 to ll-1 do if al[nl].Prioritet=lspr[ipr] then begin
            Inc(hpr); alpr[hpr]:=nl;
          end;
          // Столбцы с приоритетом <= lspr[ipr]
          SetLength(ac,lc0); lc:=0;
          for nc:=0 to lc0-1 do
            if ac0[nc].Prioritet<=lspr[ipr] then begin
              SetLength(ac[lc].a,ll); ac[lc]:=ac0[nc]; Inc(lc);
            end;
          SetLength(ac,lc);
          // Сортировка столбцов по приоритету
          ValSort(0,lc-1);
          // решить систему - найти базис и список зависимых значений
          for nc:=0 to lc-1 do
            for lpr:=0 to hpr do begin
              nl:=alpr[lpr];
              if not(al[nl].calc or empty(ac[nc].a[nl])) then begin
                d:=1/ac[nc].a[nl];
                for i:=0 to lc-1 do ac[i].a[nl]:=mround(ac[i].a[nl]*d,FloatDec);
                for lpr1:=0 to hpr do begin
                  j:=alpr[lpr1];
                  if j<>nl then begin
                    d:=ac[nc].a[j];
                    if not empty(d) then
                      for i:=0 to lc-1 do ac[i].a[j]:=mround(ac[i].a[j]-ac[i].a[nl]*d,FloatDec);
                  end;
                end;
                al[nl].calc:=true; ac[nc].nl1:=nl; break;
              end;
            end;
          // зависимые значения - слева, базис - справа
          ncBasis:=lc;
          for nc:=0 to lc-1 do if ac[nc].nl1<0 then begin
            i:=nc+1;
            while i<lc do
              if ac[i].nl1<0 then Inc(i) else break;
            if i=lc then begin
              ncBasis:=nc; break;
            end;
            c:=ac[i];
            for i:=i downto nc+1 do ac[i]:=ac[i-1];
            ac[nc]:=c;
          end;
          // Номер первого неизменного значения
          ncCng:=ncBasis;
          while ncCng<lc do
            if ValPrioritet(ncCng)=3 then break else Inc(ncCng);
{$IFDEF ARRCONDTEST}
          fTest.WriteString(Space(nsp)+StrNum('Приоритет ',ipr),[wrCrlf]); Inc(nSp);
          for nc:=0 to lc-1 do begin
            if nc=ncBasis then fTest.WriteString(Space(nsp)+'изменяемый базис:',[wrCrlf]);
            if nc=ncCng then fTest.WriteString(Space(nsp)+'неизменяемый базис:',[wrCrlf]);
            with ac[nc] do if not empty(v) then fTest.WriteString(ColInf(ac[nc])+Format(':%g',[v]),[wrCrlf]);
          end;
{$ENDIF}
          SetLength(aCngBasis,ncCng-ncBasis);
          // правильно округлить базис
          for nc:=ncBasis to lc-1 do with ac[nc] do if not (clRndSet in Opt) then vRnd:=nRound(v);
          vs1:=0; i22:=0; vs21:=0; vs22:=0;
          // погрешность для разных вариантов
          offs0:=0;
          for i:=low(aCngBasis) to high(aCngBasis) do begin
            avsOffs(i); IncD(offs0,aCngBasis[i].avs[0].offs);
          end;
          // расчитать зависимые значения без увеличения/уменьшения
          offsMin:=MaxExtended; Calc(offs0);
{$IFDEF ARRCONDTEST}
          nstep:=0;
{$ENDIF}
          while true do begin
{$IFDEF ARRCONDTEST}
            Inc(nstep);
            fTest.WriteString(Space(nsp)+StrNum('Шаг ',nstep),[wrCrlf]); Inc(nSp);
{$ENDIF}
            // расчитать зависимые значения с увеличением/уменьшением по 1 значению
            i1:=-1; i:=0;
            for nc:=ncBasis to ncCng-1 do with aCngBasis[i] do begin
              for fl:=false to true do if fl in aCor then begin
                vs:=aSign[fl]; ac[nc].vRnd:=avs[vs].v;
                if Calc(offs0-avs[0].offs+avs[vs].offs) then begin
                  i1:=i; vs1:=vs;
                end;
              end;
              ac[nc].vRnd:=avs[0].v; Inc(i);
            end;
            // расчитать зависимые значения с увеличением/уменьшением по 2 значениям
            i21:=-1; i:=0;
            for nc:=ncBasis to ncCng-1 do with aCngBasis[i] do begin
              for fl:=false to true do if fl in aCor then begin
                vs:=aSign[fl]; ac[nc].vRnd:=avs[vs].v; offs2:=offs0-avs[0].offs+avs[vs].offs; j:=i+1;
                for nl:=nc+1 to ncCng-1 do with aCngBasis[j] do begin
                  for fl1:=false to true do if fl1 in aCor then begin
                    vs2:=aSign[fl1]; ac[nl].vRnd:=avs[vs2].v;
                    if Calc(offs2-avs[0].offs+avs[vs2].offs) then begin
                      i21:=i; vs21:=vs; i22:=j; vs22:=vs2;
                    end;
                  end;
                  ac[nl].vRnd:=avs[0].v; Inc(j);
                end;
              end;
              ac[nc].vRnd:=avs[0].v; Inc(i);
            end;
{$IFDEF ARRCONDTEST}
            Dec(nSp);
{$ENDIF}
            if i21>=0 then begin
              with aCngBasis[i21] do begin
                ac[ncBasis+i21].vRnd:=avs[vs21].v; IncD(offs0,avs[vs21].offs-avs[0].offs);
              end;
              with aCngBasis[i22] do begin
                ac[ncBasis+i22].vRnd:=avs[vs22].v; IncD(offs0,avs[vs22].offs-avs[0].offs);
              end;
              avsOffs(i21); avsOffs(i22);
            end
            else if i1>=0 then with aCngBasis[i1] do begin
              ac[ncBasis+i1].vRnd:=avs[vs1].v; IncD(offs0,avs[vs1].offs-avs[0].offs);
              avsOffs(i1);
            end
            else break;
          end;
          if offsMin=MaxExtended then begin
            res^:=null; goto lend;
          end;
{$IFNDEF ARRCONDTEST}
          if ipr<lspr.Count-1 then
{$ENDIF}
            for nc:=0 to lc0-1 do with ac0[nc] do
              if Prioritet=lspr[ipr] then begin
                ac0Opt([clRndCorr,clRndSet],[clRndNoBound]);
                if clEqual in Opt then vRnd:=resEq[nVal] else vRnd:=res^[nVal];
              end;
{$IFDEF ARRCONDTEST}
          fTest.WriteString(Space(nsp)+'=',[wrCrlf]);
          for nc:=0 to lc0-1 do with ac0[nc] do
            if (Prioritet<=lspr[ipr]) and not empty(v)
            then fTest.WriteString(ColInf(ac0[nc])+Format(':%g -> %d',[v,vRnd]),[wrCrlf]);
          Dec(nSp);
{$ENDIF}
        end;
      end;
      for i:=lVal to hVal do if MyVarType(aVal[i])=varArray then begin
        l:=VarArrayLowBound(aVal[i],1)+3;
        if l<VarArrayHighBound(aVal[i],1) then
          if (MyVarType(aVal[i][l])=varString) and (MyVarType(aVal[i][l+1])=varString)
          then Summ.SetN(aVal[i][l],aVal[i][l+1],res^[i],FloatDec);
      end;
    end;
lend:
  finally
    lspr.Free;
  end;
{$IFDEF ARRCONDTEST}
  fTest.Update(true); fTest.Free;
{$ENDIF}
  //ProfOut;
  DelStack;
end;

function ArrCondRound(const aVal,aSum,aEqual,UnUsed,aMatrix: variant;
  {$IFDEF ARRCONDTEST}PrNValInf: TPrNValInf = nil;{$ENDIF} FloatDec: byte = FloatMaxDec;
  lShow: boolean = true): variant; overload;
begin
  AddStack('FFdp.ArrCondRound');
//ProfSwitch:=true; ProfOn;
  ShowStat('Округление',StArrCondRound,[LongInt(@result),
    aVal,aSum,aEqual,aMatrix,FloatDec{$IFDEF ARRCONDTEST},LongInt(@PrNValInf){$ENDIF}],
    IfThen(not lShow,stNoShow));
//ProfOut;
  DelStack;
end;

function ArrCondRound(var av: array of variant): variant; overload;
begin
  result:=ArrCondRound(av[1],av[2],av[3],av[4],av[5],{$IFDEF ARRCONDTEST}PrNValInf,{$ENDIF}IsNilc(av[6],FloatMaxDec));
end;

function ArrCondRoundSelf;
begin
  AddStack('FFdp.ArrCondRoundSelf');
  aVal:=ArrCondRound(aVal,aSum,aEqual,UnUsed,aMatrix,{$IFDEF ARRCONDTEST}PrNValInf,{$ENDIF}FloatDec,not(acrndNoShow in Opt));
  result := MyVarType(aVal)=varArray;
  if not(result or (acrndNoMsg in Opt))
  then mess_ok(['Некорректно заданы условия для округления.','Обратитесь к разработчикам.']);
  DelStack;
end;

function ArrCondMatrix(const aRow,aCol: variant; const sRow: string; const sCol: string = '';
  Opt: TArrCondMatrixOpt = []; FloatDec: byte = FloatMaxDec; Prior: byte = 0): variant;
type
  TLsRec = record
    a: TArrStr;
    l: longint;
  end;
const alc: array[boolean] of TSummLineCol = (s_line,s_col);
var lY,fl,IsSum: boolean;
  aY: array[boolean] of record
    ls: TStringList;
    als: array of TLsRec;
    srez: string;
    a: variant;
    etc: boolean;
    n1,n2,lrez: byte;
  end;
  i1,i2,k1,k2,l,n: longint;
  p1,p2: ^TLsRec;
  sr: string;
  s1: Rsumm;
  s2: TArrRsumm;
  v,v1: variant;
label lend;
begin
  AddStack('FFdp.ArrCondMatrix');
  result:=false;
  with aY[false] do begin
    srez:=sRow; a:=aRow; etc:=acmxEtcRow in Opt;
  end;
  with aY[true] do begin
    srez:=sCol; a:=aCol; etc:=acmxEtcCol in Opt;
  end;
  for lY:=low(aY) to high(aY) do with aY[lY] do begin
    ls:=SortStrListCreate; SetLength(als,10); n1:=2+Ord(lY); n2:=3-Ord(lY); lrez:=IfThen(srez<>'',1);
  end;
  try
    k2:=0;
    for lY:=low(aY) to high(aY) do with aY[lY] do
      if Pos(UnDelim,srez)=0 then begin
        if MyVarType(a)=varString then a:=SummArrName(alc[lY],a);
        if MyVarType(a)=varArray then begin
          n:=ls.Count;
          if Length(als)=n then SetLength(als,n shl 1);
          p1:=@als[n]; ls.AddObject(srez,pointer(n));
          i1:=VarArrayLowBound(a,1); i2:=VarArrayHighBound(a,1); SetLength(p1.a,i2-i1+1); p1.l:=0;
          for k1:=i1 to i2 do if a[k1]<>srez then begin
            p1.a[p1.l]:=a[k1]; Inc(p1.l);
          end;
          SetLength(p1.a,p1.l); MaxSelf(k2,p1.l);
        end;
      end
      else begin
        v:=SummArrName(alc[lY],'');
        if MyVarType(v)=varArray then begin
          l:=VarLength(v);
          for k1:=VarArrayLowBound(v,1) to VarArrayHighBound(v,1) do
            if TSumm.Nsumsum(v[k1],a,srez,sr) then begin
              if IntObjFindAdd(ls,sr,n) then p1:=@als[n]
              else begin
                if Length(als)=n then SetLength(als,n shl 1);
                p1:=@als[n]; p1.l:=0; SetLength(p1.a,l);
              end;
              p1.a[p1.l]:=v[k1]; Inc(p1.l);
            end;
          for i1:=0 to ls.Count-1 do begin
            p1:=@als[IntObj(ls,i1)]; SetLength(p1.a,p1.l); MaxSelf(k2,p1.l);
          end;
        end;
      end;
    l:=0;
    for lY:=low(aY) to high(aY) do with aY[lY] do
      if lrez>0 then for i2:=0 to aY[not lY].ls.Count-1 do
        Inc(l,ls.Count*(aY[not lY].als[IntObj(aY[not lY].ls,i2)].l+aY[not lY].lrez));
    if l>0 then begin
      SetLength(s2,k2); v1:=VarArrayCreate([1,4],varVariant); result:=VarArrayCreate([1,l],varVariant); n:=0;
      for lY:=low(aY) to high(aY) do with aY[lY] do
        if lrez>0 then
          for i1:=0 to ls.Count-1 do begin
            p1:=@als[IntObj(ls,i1)]; l:=p1.l+lrez;
            for i2:=0 to aY[not lY].ls.Count-1 do begin
              if p1.l>0 then ZeroMemory(@s2[0],p1.l*SizeOf(s2[0]));
              with aY[not lY] do p2:=@als[IntObj(ls,i2)];
              for k2:=1 to p2.l+aY[not lY].lrez do begin
                v:=VarArrayCreate([1,l],varVariant); s1:=0; IsSum:=false;
                for k1:=1 to l do begin
                  if k1>p1.l then v1[n1]:=           ls[i1] else v1[n1]:=p1.a[k1-1];
                  if k2>p2.l then v1[n2]:=aY[not lY].ls[i2] else v1[n2]:=p2.a[k2-1];
                  if k1>p1.l then begin
                    if etc then begin
                      v1[1]:=null; v1[4]:=0;
                    end
                    else begin
                      v1[1]:=s1;
                      if acmxChkSum in Opt then
                        if v1[1]<>mround(Summ.Value(v1[3],v1[2]),FloatDec) then begin
                          result:=ArrayAsList(['Ошибка контроля сумм.','Строка: '+v1[2],'Столбец: '+v1[3],
                            'Значение в таблице: '+Trim(SpaceStr0(mround(Summ.Value(v1[3],v1[2]),FloatDec),FloatMaxLen,FloatMaxDec)),
                            'Сумма исходных '+IfThen(lY,'столбцов','строк')+': '+Trim(SpaceStr0(s1,FloatMaxLen,FloatMaxDec))],CRLF);
                          goto lend;
                        end;
                      v1[4]:=-1;
                    end;
                  end
                  else begin
                    fl:=true;
                    if k2>p2.l then
                      if aY[not lY].etc then begin
                        v1[1]:=null; v1[4]:=0; fl:=false;
                      end
                      else v1[1]:=s2[k1-1]
                    else begin
                      v1[1]:=mround(Summ.Value(v1[3],v1[2]),FloatDec);
                      IncD(s2[k1-1],v1[1],FloatDec);
                    end;
                    if fl then begin
                      v1[4]:=1; IncD(s1,v1[1],FloatDec);
                    end;
                  end;
                  if v1[4]<>0 then IsSum:=true; // Если только в т.ч. - не добавлять
                  v[k1]:=v1;
                end;
                if IsSum then begin
                  Inc(n); result[n]:=v;
                end;
              end;
            end;
          end;
      VarArrayRedim(result,n); result:=ArrVarToVar([result,Prior]);
    end;
lend:
  finally
    for lY:=low(aY) to high(aY) do aY[lY].ls.Free;
  end;
  DelStack;
end;

function IfThen(AValue: boolean; ATrue: TSDPartList): TSDPartOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function GFObjPropProc(var v: variant; var GF: TGenForm): boolean;
begin
  AddStack('FFdp.GFObjPropProc');
  result:=IsNil(v);
  if result then begin
    v:=true; result:=Assigned(CurFdp);
    if result then GF:=CurFdp.GF;
  end;
  DelStack;
end;

{ TFdp }
constructor TFdp.Create;
  function MnCrt(const Capt: string; const Nm: string = ''; Clck: TNotifyEvent = nil;
  	Own: TMenuItem = nil; lAddKey: boolean = true): TMenuItem;
  var ACaption,AName: string;
  begin
    AddStack('TFdp.Create.MnCrt',Self);
    ACaption:=Capt;
    if Nm='' then AName:=''
    else begin
	    if lAddKey then ACaption:=Capt+' <'+StrTran(Nm,'_','+')+'>';
      AName:='M_'+Nm;
    end;
    result:=NewItem(ACaption,TextToShortCut(''),false,true,IfThenNotify(Clck,APopupClick),0,AName);
    TMenuItem(IfThen(Own,pmnBase.Items)).Add(result);
    DelStack;
  end;
  function LnCrt(Own: TMenuItem = nil; Vsbl: boolean = false): TMenuItem;
  begin
    AddStack('TFdp.Create.LnCrt',Self);
    PointerDef(pointer(Own),pmnBase.Items); result:=MenuNewLine(Own); Own.Add(result); result.Visible:=Vsbl;
    DelStack;
  end;
var pnStat: TRbPanel;
  mn: TMenuItem;
  i: longint;
  s: string;
begin
  AddStack('TFdp.Create',Self);
  inherited Create(AOwner);
  Place:=rpTop; Schem:='ViewGF';
  if not(csDesigning in ComponentState) then begin
    PnGF:=TRbPanel.Create(Self.Owner);
    with PnGF do begin
      Parent:=Self; ProcentWnd:=100; Place:=rpTop; BevelOuter:=bvNone; Schem:='Edit';
      OnEnter:=PnGFEnter; OnExit:=TNone.PnGFExit;
      stGF:=TRbStatus.Create(Self.Owner);
      with stGF do begin
        Parent:=PnGF; BevelOuter:=bvLowered; SectLeft.Add('');
      end;
      PnGF1:=TRbPanel.Create(Self.Owner);
      with PnGF1 do begin
        Parent:=PnGF; ProcentWnd:=100; SortObj:=False; BevelOuter:=bvLowered;
        pmnBase:=TPopupMenu.Create(Self);
        M_Edit:=MnCrt('Редактирование текста','',M_EditClick);
        M_EdFont:=MnCrt('Редактирование шрифта','',M_EdFontClick);
        M_R1:=LnCrt;
        M_Enter:=MnCrt('Формирование документа','Enter');
        M_F2:=MnCrt('Список листов','F2');
        MnCrt('Настройка принтера','F3');
        M_F4:=MnCrt('Редактирование параметров формы','F4');
        M_Spot:=MnCrt('Редактирование отступа '+aSpot[1],'',M_SpotClick);
        M_F5:=MnCrt('Печать','F5');
        M_Shift_F5:=MnCrt('Быстрая печать','Shift_F5');
        M_F6:=MnCrt('Поиск','F6');
        M_Shift_F6:=MnCrt('Продолжить поиск','Shift_F6');
        M_F8:=MnCrt('','F8');
        M_Ctrl_F10:=MnCrt('Перестроить документ','Ctrl_F10');
        M_R2:=LnCrt;
        M_Scale:=MnCrt('Масштаб','');
        i:=50;
        while i<=250 do begin
          s:=IntToStr(i); mn:=MnCrt(s+'%',s,AScaleClick,M_Scale,false);
          mn.GroupIndex:=1; mn.RadioItem:=True; Inc(i,50);
        end;
        LnCrt(M_Scale,true);
        M_Ctrl_U:=MnCrt('уменьшить','Ctrl_U',nil,M_Scale);
        MnCrt('увеличить','Ctrl_I',nil,M_Scale);
        MnCrt('исходный','Ctrl_Z',nil,M_Scale);
        M_R3:=LnCrt;
        M_ArhSave:=MnCrt('Сохранить документ в архив','Alt_F3');
        M_ArhLoad:=MnCrt('Загрузить документ из архива','Alt_F5');
        LnCrt;
        M_Shift_F2:=MnCrt('Сохранить документ в файл','Shift_F2');
        M_Shift_F3:=MnCrt('Загрузить документ из файла','Shift_F3');
        M_Inet:=MnCrt('Отправить по Интернету разработчикам','Alt_I');
        M_EDO:=MnCrt('Отправить на подпись','Alt_E');
        ScrlGF:=TRbScrollBox.Create(Self.Owner);
        with ScrlGF do begin
          Parent:=PnGF1; BorderStyle:=bsNone;
          HorzScrollBar.Increment:=30; VertScrollBar.Increment:=30;
          StopRebuild:=true;
          OnScroll:=ScrlGFScroll;
          PnGF2:=TRbPanel.Create(Self.Owner);
          with PnGF2 do begin
            Parent:=ScrlGF; Schem:='ViewGF'; BevelOuter:=bvNone;
            GF:=TGenForm.Create(Self.Owner);
            with GF do begin
              Parent:=PnGF2; State:=gsView; SetBounds(0,20,Width,Height);
              OnEnter:=GFEnter; OnBeforeCalculate:=GFBeforeCalculate; OnNoFitOnPage:=GFNoFitOnPage;
              OnAfterPaint:=GFAfterPaint; OnMouseDown:=GFMouseDown;
              OnMouseMove:=GFMouseMove; OnMouseUp:=GFMouseUp;
            end;
          end;
        end;
      end;
    end;
    pnStat:=TRbPanel.Create(Self.Owner);
    with pnStat do begin
      Parent:=Self; BevelOuter:=bvNone; Place:=rpBottom; Schem:='Status';
      stFrm:=TRbStatus.Create(Self.Owner);
      with stFrm do begin
        Parent:=pnStat; Alignment:=taLeftJustify; BevelOuter:=bvLowered;
        SectLeft.Text:=' '+CRLF+CRLF+CRLF+CRLF; SectRight.Text:=CRLF+CRLF;
        OnMouseMove:=stFrmMouseMove; OnMouseUp:=stFrmMouseUp;
      end;
      stPrn:=TRbStatus.Create(Self.Owner);
      with stPrn do begin
        Parent:=pnStat; Cursor:=crHandPoint; Alignment:=taLeftJustify; BevelOuter:=bvLowered;
        SectLeft.Text:=CRLF; OnClick:=stPrnClick;
      end
    end;
    Inter:=TInter.Create(''); Inter.ShowError:=false;
    RateScr:=Screen.PixelsPerInch/MmInInch;
    lLeaf:=Length(stLeaf)+10;
    lPage:=Length(stPage)+10;
    lScale:=Length(stScale)+5;
    lLeft:=Length(stLeft)+8;
    lTop:=Length(stTop)+8;
    Modified:=false; stFrmFill;
  end;
  ls:=TGFBitMapList.Create;
  DelStack;
end;

destructor TFdp.Destroy;
begin
  AddStack('TFdp.Destroy',Self);
  Inter.Free; ls.Free; EdoOrgs.Free; EdoNC.Free;
  inherited Destroy;
  DelStack;
end;

procedure TFdp.AssignFdp;
var l,i: longint;
	fl: boolean;
  fn: TFileName;
begin
  AddStack('TFdp.AssignFdp',Self);
  fl := lSetFocus and (CurFdp=Self);
  if fl then GetParentForm(Self).ActiveControl:=nil;
  i:=low(av); l:=high(av)-i; FileDcm:=av[i];
  if l<1 then GF.FileName:=FileDcm else GF.FileName:=av[i+1];
  if l<2 then PartIni:=GF.FileName else PartIni:=av[i+2];
  FullName:=FullNameExe(GF.FileName,'DTG'); fn:=FullName;
  if FileDcm='' then begin
    GF.FileName:='__SPDWIN.DTG'; FullName:=FullNameExe(GF.FileName,'DTG');
    GF.CopyWithAutosize(fn,FullName);
  end;
  ViewDate; KeyExistFile; TEdGenFr.LoadWait;
  if fl then GetParentForm(Self).ActiveControl:=Self;
  DelStack;
end;

procedure TFdp.DoEnter;
var fl: boolean;
  ost: longint;
begin
  ost:=AddStack('TFdp.DoEnter',Self);
  inherited DoEnter;
  if not IsCalculator and (CurFdp<>Self) then begin
    CurFdp:=Self; DcmModified:=false; TEdGenFr.LoadWait; EdGenFr.NoLimit:=true;
    EdGenFr.RDocPrm.OnDWSeek:=TNone.RDocPrmDWSeek; EdGenFr.RDocpPrm.OnDWSeek:=TNone.RDocPrmDWSeek;
    EdGenFr.PrmGet.OnClick:=PrmGetClick; EdGenFr.PrmGet.OnPaint:=TNone.PrmGetPaint;
    with PnGF2 do SetBounds(Left,Top,0,0);
    mLeaf:=''; mPage:=''; mScale:=''; mLeft:=''; mTop:=''; Modified:=false;
    stFrmFill; PrPrnChange;
    with GF do begin
      SetBounds(Left,Top,0,0); PnGF1Bounds; Show;
    end;
    if FormKeyLb(Self,tl) then with tl do begin
	    TEdGenFr.LoadWait;
      try
        OpenDcmFirst; fl:=true;
      except
        on EDcmFormError do begin
          SetStack(ost);
          IfThenNotify(FOnOpenDcmError,Self); fl:=false;
        end;
      end;
      M_Enter.Visible:=false;
      M_F2.Visible:=false;
      M_Edit.Visible:=false; M_EdFont.Visible:=false;
      M_Ctrl_F10.Visible:=false;
      M_R1.Visible:=false; M_R2.Visible:=false; M_Scale.Visible:=false;
      M_F6.Visible:=false; M_Shift_F6.Visible:=false;
      M_R3.Visible:=false; M_ArhSave.Visible:=false; M_ArhLoad.Visible:=false;
      M_Spot.Visible:=false;
      if fl then begin
        if not(fdoReadOnly in Options) then SetKey(K_Enter,'Формирование','Формирование документа',ProcKey,'fdp',kmGenForm);
        SetKey(K_F3,'Принтер','Настройка принтера',ProcKey,'fdp',kmServic);
        fl:=not empty(FileDcm); M_F4.Visible:=fl;
        if fl then begin
          SetKey(K_F4,'Параметры','Редактирование параметров формы',ProcKey,'fdp',kmEdit);
          SetKey(K_Shift_F4,'Отступы','Редактирование отступов документа',ProcKey,'fdp',kmEdit);
          SetKey(K_Ctrl_F4,'','Редактирование параметров документа',ProcKey,'fdp',kmEdit);
          SetKey(K_Alt_Home,'','Установка шрифтов по умолчанию',ProcKey,'fdp',kmEdit);
          SetKey(K_Ctrl_F5,'','Редактирование формы документа',ProcKey,'fdp',kmNone,DcmPrivEdit);
        end;
        SetKey(K_Alt_F3,'','Сохранить документ в архив',ProcKey,'fdp',kmArhiv);
        if not(fdoReadOnly in Options) then SetKey(K_Alt_F5,'','Загрузить документ из архива',ProcKey,'fdp',kmArhiv);
        MsgMsOff(msoEnter,tl);
        if (State=fdpView) or empty(FileDcm) then ViewGF
        else TTimerOne.CreateProc(AfterView,Self);
        KeyExistFile;
      end;
    end;
  end;
  DelStack;
end;

procedure TFdp.AfterView;
begin
  AddStack('TFdp.AfterView',Self);
  with FormKeyLb(Self) do begin
    ExecKey(K_Enter);
    if State=fdpPrint then ExecKey(K_Shift_F5);
  end;
  DelStack;
end;

function TFdp.OpenDcmFirst;
begin
  AddStack('TFdp.OpenDcmFirst',Self);
  EdGenFr.GF.OpenDcm(FileDcm); GF.MouseInit(EdGenFr.GF); result:=Assigned(tl);
  if result then with tl do
    if empty(EdGenFr.GF.DopAlg) then DelKey(K_Ctrl_Enter,'fdp')
    else begin
      TDWWin.CreateOne(dw,Self).dw.LoadFromStr(EdGenFr.GF.awWin[gfwDop]);
      SetKey(K_Ctrl_Enter,EdGenFr.GF.DopAlgName,IfThen(empty(dw.dw.Zgl),
        IfThen(not empty(EdGenFr.GF.DopAlgName),'Дополнительные действия'),dw.dw.Zgl),
        ProcKey,'fdp',kmGenForm);
    end;
  DelStack;
end;

procedure TFdp.KeyExistFile;
begin
  AddStack('TFdp.KeyExistFile',Self);
  if Assigned(tl) then with tl do begin
    M_EDO.Visible:=false;
    if MyFileExists(FullName) then begin
      SetKey(K_F5,'Печать','',ProcKey,'fdpview',kmGenForm); M_F5.Visible:=true;
      SetKey(K_Shift_F5,'','Быстрая печать',ProcKey,'fdpview',kmGenForm); M_Shift_F5.Visible:=true;
      SetKey(K_Shift_F2,'','Сохранить документ в файл',ProcKey,'fdpview',kmFile); M_Shift_F2.Visible:=true;
      M_INet.Visible := SftpPath<>'';
      if M_INet.Visible then SetKey(K_Alt_I,'','Отправить по Интернету разработчикам',ProcKey,'fdpview',kmFile);
      if not(fdoNoEdo in Options) then if Assigned(EdoDM) then if GetEdoPrm then begin
        M_EDO.Visible:=true; SetKey(K_Alt_E,'','Отправить на подпись',ProcKey,'fdpview',kmFile);
      end;
    	if Assigned(lsExtend) then lsExtend.Clear;
      SetNmExtend; M_F8.Visible:=true;
    end
    else begin
      M_F5.Visible:=false; M_Shift_F5.Visible:=false; M_Shift_F2.Visible:=false; M_F8.Visible:=false;
      M_INet.Visible:=false;
    end;
    M_Shift_F3.Visible:=not(fdoReadOnly in Options);
    if M_Shift_F3.Visible then SetKey(K_Shift_F3,'','Загрузить документ из файла',ProcKey,'fdp',kmFile);
    ReDrw;
  end;
  DelStack;
end;

procedure VarCreate;
begin
  AddStack('FFdp.VarCreate');
  if nVar=0 then begin
    TDWPrm.VarCreate(EdGenFr.RDocPrm); TDWPrm.VarCreate(EdGenFr.RDocpPrm);
  end;
  Inc(nVar);
  DelStack;
end;

procedure VarFree;
begin
  AddStack('FFdp.VarFree');
  Dec(nVar);
  if nVar=0 then begin
    TDWPrm.VarFree(EdGenFr.RDocPrm); TDWPrm.VarFree(EdGenFr.RDocpPrm);
  end;
  DelStack;
end;

function TFdp.GetEdoPrm;
begin
  AddStack('TFdp.GetEdoPrm',Self);
  with EdoPrm do begin
    EdGenFr.RDocPrm.InitFldDef; EdGenFr.RDocpPrm.InitFldDef;
    VarCreate;
    try
      Finalize(EdoPrm); ZeroMemory(@EdoPrm,SizeOf(EdoPrm)); prm[edopPrim]:=''; 
      result:=EdoProc(edoGetPrm,[GF.FileName,longint(@EdoPrm)],true);
      //ArrVarDef(prm[edopPril]);
    finally
      VarFree;
    end;
    AndD(result,not(empty(kv) or IsNil(prm[edopPrim])));
  end;
  DelStack;
end;

procedure TFdp.SetNmExtend;
const a: TArrBoolStr = ('Отметить текст объектов','Снять отметку с текста объектов');
var fl: boolean;
begin
  AddStack('TFdp.SetNmExtend',Self);
  if Assigned(lsExtend) then fl := lsExtend.Count>0 else fl:=false;
  M_F8.Caption:=a[fl]+' <F8>';
  if Assigned(tl) then tl.SetKey(K_F8,'',a[fl],ProcKey,'fdpview',kmGenForm);
  DelStack;
end;

procedure TFdp.DoExit;
begin
  AddStack('TFdp.DoExit',Self);
  if not IsCalculator and Assigned(CurFdp) then begin
    //if DcmModified and (fdoSaveDcm in FOptions) then UpdateDBDcm(FileDcm);
    SaveLeaf(0);
    if Assigned(tl) then begin
      tl.DelKeyNmPr(['fdp','fdppages','fdpview','fdpscale','fdpfind','fdppgsave','fdppgnext']);
	    MsgMsOff(msoExit,tl); tl.Redrw;
    end;
    ClearFind; GF.CloseDtg; CurFdp:=nil;
    if Assigned(EdGenFr) then EdGenFr.NoLimit:=false;
  end;
  inherited DoExit;
  DelStack;
end;

function PrSort(List: TStringList; Index1,Index2: longint): longint;
begin
	AddStack('FFdp.PrSort');
  result:=FileAge(ArhPath+List[Index1])-FileAge(ArhPath+List[Index2]);
  DelStack;
end;

function ArhTimeNm(const nm: string): string;
begin
  AddStack('FFdp.ArhTimeNm');
  result:=Copy(nm,Pos(')',nm)+2,MaxInt);
  DelStack;
end;

procedure TFdp.ProcKey;
  function Grid(i: longint): longint;
  begin
    AddStack('TFdp.ProcKey.Grid',Self);
    if VertBreak then result:=GF.GridY[i] else result:=GF.GridX[i];
    DelStack;
  end;
var pv: PGFObj;
  function vCrd(rb: boolean = false): longint;
  begin
    AddStack('TFdp.ProcKey.vCrd',Self);
    with pv^ do result:=IfThen(VertBreak,IfThen(rb,Bottom,Top),IfThen(rb,Right,Left));
    DelStack;
  end;
var j: longint;
  aObj: array of record
  	a: TArrPGFObj;
    l: longint;
    Calc: boolean;
  end;
  aChain: TArrPoint;
  sFont,sFontAll: TByteSet;
  aCrd: TArrInt;
  procedure ObjAdd(X: longint);
  var i,Y,r: longint;
  begin
    AddStack('TFdp.ProcKey.ObjAdd',Self);
    with aObj[X] do if not Calc then begin
      for Y:=low(a) to high(a) do begin
        pv:=aObj[X].a[Y]; r:=aCrd[vCrd(true)];
        with aObj[r] do if l=0 then begin
          if r=high(aObj) then begin
            for i:=0 to j-1 do with aChain[i] do Include(sFont,aObj[X].a[Y].Font);
            Include(sFont,pv.Font);
            if sFont=sFontAll then raise EFdpBreak.Create('');
          end;
        end
        else begin
          aChain[j].X:=X; aChain[j].Y:=Y; Inc(j); ObjAdd(r); Dec(j);
        end;
      end;
      Calc:=true;
    end;
    DelStack;
  end;
  procedure ArhLoad(ls: TStringList);
  var i: longint;
  begin
    AddStack('TFdp.ProcKey.ArhLoad',Self);
    ArhPath:=ExeDir+'ArhDoc'+PathDelim+GF.FileName+PathDelim;
    ls.BeginUpdate; GetMaskFiles(ls,ArhPath+'*.*',[],[msfNoUpper]); ls.CustomSort(PrSort);
    for i:=0 to ls.Count-1 do
	    IncL(ls,i,FormatDateTime('(dd/mm/yyyy hh:nn:ss) ',GetFileDateTime(ArhPath+ls[i])));
    ls.EndUpdate;
    DelStack;
  end;
  function ArhSave(const nmArh: string; lSave: boolean): boolean;
  var sVar,nm: string;
  	i: longint;
    f1,f2: TFileBuf;
  begin
    AddStack('TFdp.ProcKey.ArhSave',Self);
    result:=true; EdGenFr.RDocPrm.InitFldDef;
    if lSave then begin
      sVar:='';
      with EdGenFr.RDocPrm do begin
        for i:=0 to FldDef.Count-1 do begin
          nm:=DWSToRec(i).Name; IncD(sVar,nm+'~'+StrTran(FldName(nm).GetStrVal,'~','`')+'~');
        end;
        DecLen(sVar); ForceDirectories(ArhPath);
        f1:=TFileBuf.Create(FullName); f2:=TFileBuf.Create(ArhPath+nmArh,true);
        try
          f2.WriteStr(sVar); f2.CopyFrom(f1); result:=f2.Update(true);
        finally
          f1.Free; f2.Free;
        end;
      end;
    end;
    DelStack;
  end;
var oScale: Single;
  procedure DocHide(const Msg: string);
  begin
    AddStack('TFdp.ProcKey.DocHide',Self);
    with GF do begin
      GetParentForm(Self).ActiveControl:=PnGF2; Hide;
      if not lDopAlg then CloseDtg;
      mLeaf:=''; mPage:=''; mScale:=''; stFrmFill;
      stGF.SectLeft[0]:=Msg; oScale:=ScalePrc; ScalePrc:=1;
    end;
    DelStack;
  end;
  procedure DocShow;
  begin
    AddStack('TFdp.ProcKey.DocShow',Self);
    with GF do begin
      ScalePrc:=oScale; ViewGF; ViewDate; KeyExistFile; PrPrnChange;
    end;
    DelStack;
  end;
const DocLast = 'Последний сформированный документ';
var fl,lOut: boolean;
	r: TRect;
  ost,i,w,w1: longint;
  f: TGFPackFont;
  ls: TStringList;
  mr: TListF2Result;
  a: TPrnPrmVar;
  fld: TFld;
  f1,f2: TFileBuf;
  av: TDEPrmVar;
  p: TPrnPrmList;
  ap: TDEPrmStr;
  s: string;
  aw: TArrStr;
  cgp: TCGParam;
  v: variant;
begin
  ost:=AddStack('TFdp.ProcKey',Self);
	case Key of
  	K_F2: begin
      if TGFPages.Execute(GF) then SetPage(GFPages.sb.Row);
      FormFree(GFPages);
    end;
  	// Настройка принтера
  	K_F3: begin
    	PrnSetupExec; PrPrnChange;
    end;
		// Редактирование параметров формы
  	K_F4: PrmGetEval;
  	K_F5,K_Shift_F5: begin
    	SaveLeaf; fl := Key=K_F5;
      for p:=low(a) to high(a) do with InitFIni[fiPPDoc],aPrnPrmDef[p] do begin
        if p in sPrnPrmBool
        then a[p]:=ReadBool(PartIni,'Prn'+aPrnPrmFld[p],Def)
        else a[p]:=ReadInteger(PartIni,'Prn'+aPrnPrmFld[p],Def);
        if ReadBool(PartIni,'LPrn'+aPrnPrmFld[p],lSave) then
          if p in sPrnPrmBool
          then a[p]:=ReadBool(PartIni,'SPrn'+aPrnPrmFld[p],a[p])
          else a[p]:=ReadInteger(PartIni,'SPrn'+aPrnPrmFld[p],a[p]);
      end;
      if TGFPrn.Execute(GF,fl,a,'',GFEvenAll) and fl then begin
      	PrPrnChange;
	      for p:=low(a) to high(a) do with InitFIni[fiPPDoc],aPrnPrmDef[p] do
	        if ReadBool(PartIni,'LPrn'+aPrnPrmFld[p],lSave) then
            if p in sPrnPrmBool
            then WriteBool(PartIni,'SPrn'+aPrnPrmFld[p],a[p])
            else WriteInteger(PartIni,'SPrn'+aPrnPrmFld[p],a[p]);
      end;
    end;
    K_F8: begin
      GF.SelExtendObj(ListCreate(lsExtend)); SetNmExtend;
    end;
    // Формирование
  	K_Enter,K_Ctrl_Enter: if not(FdpOnlyView or lProcForm) then with GF do
    	if empty(FileDcm) then GF.AutoSize
      else begin
        ClearFind; lProcForm:=true; KeyBreak:=0; lDopAlg := Key=K_Ctrl_Enter;
        if IfThenValid(FOnBeforeDocForm,Self) then begin
          SetLogVid(logvDcmForm); 
          DateTimeBeg:=Now; i:=GF.Leaf; SaveLeaf;
          s:=IfThen(lDopAlg,'Выполнение дополнительных действий','Формирование документа');
          DocHide(s); FAborted:=true;
          if fdoSayStat in FOptions then ShowStat(s,PrStat) else mess_wait([s],PrWait);
          if not(lDopAlg or FAborted) then SetFileDateTime(FullName,DateTimeBeg);
          if KeyBreak in [0,K_Esc] then begin
            if GF.Leaf<>i then begin
              SaveLeaf; GF.RestPage(i);
            end;
            DocShow;
          end;
          FileCloseAll; DbfCloseAll; QueryCloseAll; IfThenNotify(FOnAfterDocForm,Self);
        end
        else begin
          DocHide(''); DocShow;
        end;
        lProcForm:=false; lDopAlg:=false;
        if not(KeyBreak in [0,K_Esc]) then begin
          GetPPDcm(FileDcm,PartIni,ppd);
          if KeyBreak=K_F2 then with ppd.Params.Arr[CurParams],SpotMm do begin
            r:=GFCalcSpotPrn(NFormat,Orientation);
            if VertBreak then begin
              MinSelf(Top,r.Top); MinSelf(Bottom,r.Bottom);
            end
            else begin
              MinSelf(Left,r.Left); MinSelf(Right,r.Right);
            end;
          end
          else begin
            f:=TGFPackFont.Create;
            try
              CalcRate; sFont:=[]; sFontAll:=[];
              for i:=0 to FontCount-1 do Include(sFontAll,i);
              j:=IfThen(VertBreak,RowCount,ColCount)+1;
              SetLength(aObj,j); SetLength(aCrd,j); j:=0; w:=Grid(0);
              for i:=low(aCrd) to high(aCrd) do begin
                w1:=Grid(i);
                if w1>w then begin
                  w:=w1; Inc(j);
                end;
                aCrd[i]:=j;
              end;
              SetLength(aObj,j+1); j:=0;
              for i:=low(aObj) to high(aObj) do with aObj[i] do begin
                a:=nil; l:=0; Calc:=false;
              end;
              for i:=0 to ObjectCount-1 do begin
                pv:=PObjects[i]; w:=Grid(vCrd(true))-Grid(vCrd);
                if w>0 then begin
                  if VertBreak
                  then w1:=SzGridWidth(true,GetMinHeight(pv^))
                  else w1:=SzGridWidth(false,GetMinWidth(pv^));
                  if w1>=w then with aObj[aCrd[vCrd]] do begin
                    if l=Length(a) then SetLength(a,l+30);
                    a[l]:=pv; Inc(l); Inc(j);
                  end;
                end;
              end;
              for i:=low(aObj) to high(aObj) do with aObj[i] do SetLength(a,l);
              SetLength(aChain,j); j:=0;
              try
                ObjAdd(0);
              except
                on EFdpBreak do SetStack(ost);
              end;
              j:=-1; w:=1;
              for i:=0 to FontCount-1 do if i in sFont then begin
                GetPPFont(ppd,i,f,EdGenFr.GF);
                if not TGenForm.ALine(f) and (f.Font.Size>w) then begin
                  w:=f.Font.Size; j:=i;
                end;
              end;
              if j>=0 then begin
                GetPPFont(ppd,j,f,EdGenFr.GF); f.Font.Size:=w-1; PutPPFont(ppd,j,f);
              end;
            finally
              f.Free;
            end;
          end;
          PutPPDcm(PartIni,ppd); ProcKey(Key,tw);
        end;
        IfThenNotify(FOnAfterKeyDocForm,Self);
        SetLogVid;
      end;
    K_PgUp,K_PgDn: begin
      SetRedraw(ScrlGF);
      if Key=K_PgUp then begin
        ScrlGF.VertScrollBar.Position:=ScrlGF.VertScrollBar.Range;
        SetPage(GF.Leaf-1);
      end
      else begin
        ScrlGF.VertScrollBar.Position:=0; SetPage(GF.Leaf+1);
      end;
      SetRedraw(ScrlGF,rdrwSet);
    end;
    K_Ctrl_F4: begin
      with EdGenFr do begin
        VarCreate;
        try
          SetProg(false);
          if not IfThenNotify(FOnPrmEdit,Self) then begin
            TDWWin.CreateOne(dw,Self).dw.DoSetting(GF.awWin[gfwPrm]);
            if dw.Execute(GF.awWin[gfwPrm],aWinExec[gfwPrm,1]+'.'+GF.FileName,RDocpPrm,aWinExec[gfwPrm,2],[0],
            aWinExec[gfwPrm,3],desVisible).Saved then KeyExistFile;
          end;
        finally
          VarFree;
        end;
      end;
    end;
    K_Ctrl_F5: begin
    	TEdGenFr.LoadWait;
      SetLogVid(logvEditRec);
      if EdGenFr.DcmDesign(FileDcm,FCaption,nil,tDOCPRM+'.'+fFDTG+'='+QQs(GF.FileName)) then begin
        if fdoSaveDcm in FOptions then UpdateDBDcm(FileDcm);
      	if OpenDcmFirst then tl.ReDrw;
        DcmModified:=true;
      end;
      SetLogVid;
    end;
    K_Ctrl_F10: SaveEditPrm;
    K_Ctrl_PgUp: SetPage(GF.Leaf-1);
    K_Ctrl_PgDn: SetPage(GF.Leaf+1);
    K_Ctrl_I: SetScale(GF.ScalePrc+scStep);
    K_Ctrl_U: SetScale(GF.ScalePrc-scStep);
    K_Ctrl_Z: SetScale(1);
    K_Alt_F3: begin
    	if not Assigned(deArh) then begin
        rArh:=TRecVal.Create(Application.MainForm);
        rArh.CreateFld('NAME',ftMemo,0,'');
        gArh:=TComboGet.Create(Application.MainForm); gArh.VName:='ArhDoc';
        gArh.OnListResult:=TNone.gArhListResult;
      	deArh:=TDefEdit.Create(Application.MainForm);
        with deArh do begin
        	NameWnd:='ArhDoc'; FrmCaption:='Сохранить документ в архив'; OnFldCheck:=TNone.deArhFldCheck;
          InitArr(av);
          av[deCaption]:='Наименование';
          av[deNameRec]:=rArh.NameRec;
          av[deNameRecFld]:='NAME';
          gArh.AssignGet(av);
          av[deAutoSel]:=true;
          av[deNoReadOnly]:=true;
          av[deWidth]:=wallDefault;
          av[deTrimLeft]:=true;
          CreateFld(av);
        end;
      end;
		  ArhLoad(gArh.Items);
      if deArh.Execute.Saved then begin
      	rArh['NAME']:=Trim(rArh['NAME']);
        if IfThenAsk(MyFileExists(ArhPath+rArh['NAME']),['Документ с наименованием',
        	'"'+rArh['NAME']+'"','уже есть в архиве.','','Заменить ?']) then begin
	      	SaveLeaf; ArhSave(rArh['NAME'],true);
        end;
      end;
    end;
    K_Alt_F5: begin
		  ls:=TStringList.Create; mr:=TListF2Result.Create;
      try
      	ArhLoad(ls);
        if ls.Count=0 then meserr('В архиве нет документов !')
        else with TKeyLb do if ListF2Down(ls.Text,mr,nil,0,'Browl',ArrayAsList(
        [GetKeySt(K_F8,'Удалить')
        ,GetKeySt(K_Ctrl_F8,'Удалить все')
        ],CRLF),TNone.ArhDelProc,0,nil,nil,nil,nil,nil,'Загрузить документ из архива')
        and (mr.SelectStr>=0) then begin
        	DocHide('Загрузка документа из архива');
        	s:=ArhPath+DocLast; SaveLeaf; GF.CloseDtg;
          if MyFileExists(s) then fl := FileAge(s)<FileAge(FullName) else fl:=true;
          if ArhSave(DocLast,fl) then begin
            f1:=TFileBuf.Create(ArhPath+ArhTimeNm(mr[mr.SelectStr])); f2:=TFileBuf.Create(FullName,true);
            try
              LsArrList(f1.ReadStr,ls,'~'); f2.CopyFrom(f1); fl:=f2.Update(true);
            finally
              f1.Free; f2.Free;
            end;
            if fl then begin
              i:=0;
              with EdGenFr.RDocPrm do begin
                while i<ls.Count-1 do begin
                  if FldName(ls[i],fld) then fld.SetStrVal(StrTran(ls[i+1],'`','~'));
                  Inc(i,2);
                end;
                AppUpdRec;
              end;
            end
            else DelFileAtr(FullName);
          end;
          DocShow;
        end;
      finally
        ls.Free; mr.Free;
      end;
    end;
    K_Alt_Home: if Ask(['Установить все шрифты по умолчанию ?']) then begin
	    TGenForm.GetPPDcm(FileDcm,PartIni,ppd); ppd.Fonts:='';
      TGenForm.PutPPDcm(PartIni,ppd);
    end;
    K_Alt_E: if GetEdoPrm then with EdoPrm do begin
      SetLogVid(logvEditRec);
    	if not Assigned(deEdoPrim) then begin
        rEdoPrim:=TRecVal.Create(Application.MainForm);
        with rEdoPrim do begin
          CreateFld('PRIM',ftMemo,0,'','Примечание');
          CreateFld(fEdoORG,ftString,EdoDM.Ord.FldName(fEdoORG).Info.Size,'','Организация');
          CreateFld(fEdoNC,ftInteger,0,0,'Комиссия');
          CreateFld('USERS',ftMemo,0,'','Члены комисии');
        end;
      	deEdoPrim:=TDefEdit.Create(Application.MainForm);
        with deEdoPrim do begin
        	NameWnd:='EdoPrim'; FrmCaption:='Отправить документ на подпись'; PnlSortMode:=smColumns;

          InitArr(av);
          av[deCaption]:='Примечание';
          av[deNameRec]:=rEdoPrim.NameRec;
          av[deNameRecFld]:='PRIM';
          TSimpleGet.AssignGetClass(av);
          av[deAutoSel]:=true;
          av[deNoReadOnly]:=true;
          av[deWidth]:=wallNoSay;
          CreateFld(av);

          av[deCaption]:='Организация';
          av[deNameRecFld]:=fEdoORG;
          av[deWidth]:=0;
          CreateFld(av);

          av[deCaption]:='Комиссия';
          av[deNameRecFld]:=fEdoNC;
          SchemDM.MenuGet1.AssignGet(av);
          av[deReadOnlyNoVsbl]:=true;
          av[deWidth]:=wallNoSay;
          CreateFld(av);

          av[deCaption]:='';
          av[deNameRecFld]:='USERS';
          SchemDM.MemoGet1.AssignGet(av);
          av[deMask]:=',,,,Члены комиссии';
          av[deNoReadOnly]:=false;
          av[deReadOnlyNoVsbl]:=false;
          av[deHeight]:=-1;
          CreateFld(av);
        end;
      end;
      SortStrListCreate(EdoOrgs).Clear;
      if IsNil(prm[edopOrg]) then EdoProc(edoOrgValid,[vd,longint(EdoOrgs)])
      else begin
        ArrVarDef(prm[edopOrg]);
        i:=VarArrayHighBound(prm[edopOrg],1); EdoOrgs.Capacity:=i;
        for i:=1 to i do EdoOrgs.Add(prm[edopOrg][i]);
      end;
      with ProgPswd.GetQuery do begin
        PartSelect(tEDOORD,fEdoORG,fEDOIN+'='+VToS+sAND+fEDOVD+'='+QQs(kv),fEdoORG,fEdoORG);
        while not Eof do begin
          if EdoOrgs.Find(Fields[0].AsString,i) then EdoOrgs.Objects[i]:=ObjectTrue;
          Next;
        end;
        BoolObjPack(EdoOrgs);
      end;
      ProgPswd.FreeQuery;
      rEdoPrim['PRIM']:=IsNilc(prm[edopPrim],'');
      deEdoPrim.GetArrParam(fEdoORG,i,ap);
      fl := EdoProc(edoOrgGet,[longint(@ap)],false)
        and IsNilc(prm[edopOrgEd],EdoOrgs.Count>1) and (EdoOrgs.Count>0);
      ap[deNoVisible]:=bStr[not fl];
      if fl then if NameGet(ap) is TCodeGet then begin
        cgp:=TCodeGet.MaskToPrm(ap[deMask]); cgp.FmlFlt:=FuncEdoOrgFlt+'()';
        ap[deMask]:=TCodeGet.PrmToMask(cgp);
      end;
      deEdoPrim.SetArrParam(i,ap); rEdoPrim[fEdoORG]:=IfThen(EdoOrgs);
      deEdoPrim.GetArrParam(fEdoNC,i,ap); EdoNCLoad(ap[deMask]);
      if not fl then
        if empty(rEdoPrim[fEdoORG]) then meserr('Не определена организация для выгрузки документа в ЭДО.')
        else if EdoIsNC then begin
          fl := EdoNC.Count=1; ap[deNoVisible]:=bStr[fl]; deEdoPrim.SetArrParam(i,ap);
          deEdoPrim.Param['USERS',deNoVisible]:=bStr[fl];
          if fl then rEdoPrim[fEdoNC]:=Int0(MenuMask2Prm(ap[deMask]).sItems);
          fl:=true;
        end;
      if fl then begin
        deEdoPrim.OnFldChange:=deEdoPrimFldChange; deEdoPrim.OnFldCheck:=deEdoPrimFldCheck;
        if deEdoPrim.Execute.Saved then with EdoDM.Inn do begin
          ProgPswd.CngLogVid(logvAppRec);
          SaveLeaf; IsNil(prm[edopKey],'');
          s:='RSOURCE='+Vtos(rsource)+sAND+tEDOIN+'.KEY='+QQs(prm[edopKey]);
          if Seek(ArrayAsList([tEDOIN+'.VD='+Vtos(vd),tEDOIN+'.COD='+QQs(cod),s],sAND)) then
            if StrToBoolean(Value['INARH']) then begin
              mess_ok(['Такой документ уже есть в архиве электронного документооборота.',
                'Он не может быть повторно отправлен на подписание.']);
              fl:=false;
            end
            else begin
              fl:=Ask(['Такой документ уже есть в электронном документообороте.',
                'При отправке его на подписание существующий документ будет заменён.','Продолжить ?']);
              if fl then begin
                ProgPswd.CngLogVid(logvEditRec);
                for lOut:=false to true do Value[aEdoFile[lOut]]:='';
                Value['SHIFRED']:=bFalse;
                with ProgPswd.GetQuery do begin
                  FldInSel(fEDOIN,tEDOIN,s,'',[],@aw); DeleteTableList(aw,tEDO);
                end;
              end;
            end
          else fl:=true;
          if fl then begin
            LogFields.Clear;
            if ProgPswd.LogVid=logvAppRec then begin
              NewRec; GetMaxFldSelf(fEDOIN);
              Value['VD']:=vd; Value['COD']:=cod; Value['RSOURCE']:=rsource; Value['KEY']:=prm[edopKey];
            end;
            Value['PRIM']:=rEdoPrim['PRIM'];
            Value[fEdoORG]:=rEdoPrim[fEdoORG]; Value[fEdoNC]:=rEdoPrim[fEdoNC];
            Value[fNAME]:=nm; Value[fEDOVD]:=kv; Value[sMemo+'DTG']:=GetStrFile(FullName);
            if MyVarType(prm[edopPril])=V_STRING then ArrVarDef(prm[edopPril]);
            if MyVarType(prm[edopPril])=varArray then begin
              w:=ProgPswd.CngLogVid(logvAppRec); w1:=Value[fEDOIN];
              for i:=VarArrayLowBound(prm[edopPril],1) to VarArrayHighBound(prm[edopPril],1) do begin
                v:=prm[edopPril][i]; ArrVarDef(v); VAddEndSelf(v,2);
                EdoDM.AppAdd(w1,IsNilc(v[2],''),IsNilc(v[1],''));
              end;
              ProgPswd.CngLogVid(w);
            end;
            Value['D']:=NowDouble; AppUpdRec(true); EdoInOrd; EdoProc(edoSend,[]);
          end;
        end;
        deEdoPrim.OnFldChange:=nil; deEdoPrim.OnFldCheck:=nil;
      end;
      SetLogVid;
    end;
    K_Alt_I: begin
      SaveLeaf; f1:=TFileBuf.Create(FullName);
      try
        SendToSftp(FullName,f1);
      finally
        f1.Free;
      end;
    end;
    K_Shift_F2,K_Shift_F3: begin
    	fl := Key=K_Shift_F3;
    	if not Assigned(aDlg[fl]) then begin
      	if fl
        then aDlg[fl]:=TOpenDialog.Create(Application.MainForm)
        else aDlg[fl]:=TSaveDialog.Create(Application.MainForm);
        aDlg[fl].DefaultExt:='DTG';
        aDlg[fl].Filter:='Файлы для печати (*.dtg)|*.DTG|Все файлы (*.*)|*.*';
      end;
      if FileExec('DtgSave',aDlg[fl]) then
      	if fl then begin
          AssignFdp(['',aDlg[fl].FileName],false);
          ViewGF; ViewDate; KeyExistFile; PrPrnChange;
        end
        else begin
          SaveLeaf; CopyFileOpt(FullName,aDlg[fl].FileName,[cfStat,cfMsg]);
        end;
    end;
  	K_Shift_F4: begin
	    CreateForm(TGFPrm,GFPrm);
      if GF.Params.Arr[GF.CurParams].Orientation=poLandscape
      then PrmGetEval(GFPrm.ESpRight)
      else PrmGetEval(GFPrm.ESpTop);
    end;
  else WinFindKey(Key,ScrlGF,PrFind,[fnoRegistr,fnoWord,fnoDirection,fnoAll])
	end;
  DelStack;
end;

procedure TFdp.EdoNCLoad;
var a: TArrNamePrimStr;
  i,ip,j: longint;
  ap: TArrStr;
  usnm: string;
begin
  AddStack('TFdp.EdoNCLoad',Self);
  if Assigned(EdoNC) then EdoNC.Clear else EdoNC:=TIntStrList.Create([ilsSorted]);
  with ProgPswd.GetQuery do begin
    PartSelect(tEDOORD,[fEdoNC,'NMC',fUSERNAME],
      ArrayAsList([fEDOIN+'='+VToS,fEDOVD+'='+QQs(EdoPrm.kv),fEdoORG+'='+QQs(rEdoPrim[fEdoORG])],sAND),
      GetList([fEdoNC,fEDOORD]));
    j:=RecordCount; EdoNC.Capacity:=j; InitArrLen(ap,j); ip:=NegDef;
    for j:=1 to j do begin
      if EdoNC.Add(Fields[0].AsInteger,Fields[1].AsString,i) then ip:=i;
      usnm:=Fields[2].AsString;
      IncD(ap[ip],CRLF+ReplVar(TrimRight(ProgPswd.UserGet.CodeName(usnm,[cdgBufAll])),TrimRight(usnm)));
      Next;
    end;
    i:=EdoNC.Count; SetLength(a,i);
    for i:=0 to i-1 do begin
      a[i,1]:=IntToStr(EdoNC[i]); a[i,2]:=EdoNC.Value[i]; EdoNC.Value[i]:=Copy(ap[i],lCRLF1,MaxInt);
    end;
    ms:=MenuACN2Mask(a,[mngCod,mngName,mngNum]);
  end;
  ProgPswd.FreeQuery;
  DelStack;
end;

function TFdp.EdoIsNC;
begin
  AddStack('TFdp.EdoIsNC',Self);
  result := EdoNC.Count>0;
  if not result then mess_ok(['Не определена последовательность подписания',
    'вида ЭДО "'+Trim(EdoPrm.kv)+'" для организации "'+Trim(rEdoPrim[fEdoORG])+'".']);
  DelStack;
end;

procedure TFdp.deEdoPrimFldChange;
var ms,nc: string;
  tf: TFldEdit;
  fl: boolean;
begin
  AddStack('TFdp.deEdoPrimFldChange',Self);
  with TFldEdit(Sender) do
    if NameRecFld=fEdoORG then begin
      if deEdoPrim.IsFldEdit(fEdoNC,tf,true) then begin
        EdoNCLoad(ms); nc:=tf.Value; fl := EdoNC.Count<=1; tf.SetReadOnly(fl); tf.Mask:=ms; tf.Value:=nc;
        deEdoPrim.SetReadOnly('USERS',fl,ogReadOnlyNoVsbl);
        if not fl then tf.Change(null,FromShow);
      end;
    end
    else if NameRecFld=fEdoNC then if Assigned(EdoNC)
      then deEdoPrim.FldValue['USERS']:=EdoNC.FindValue(VarValue);
  DelStack;
end;

function TFdp.deEdoPrimFldCheck;
var ms: string;
begin
  AddStack('TFdp.deEdoPrimFldCheck',Self);
  with TFldEdit(Sender) do if NameRecFld=fEdoORG then begin
    EdoNCLoad(ms); result:=EdoIsNC;
  end
  else result:=true;
  DelStack;
end;

procedure TFdp.APopupClick;
begin
  AddStack('TFdp.APopupClick',Self);
  if Assigned(tl) then tl.ExecKey(NmToKey(copy(TMenuItem(Sender).Name,3,MaxInt)));
  DelStack;
end;

procedure TFdp.AScaleClick;
begin
  AddStack('TFdp.AScaleClick',Self);
  SetScale(Int0(copy(TMenuItem(Sender).Name,3,MaxInt))/100);
  DelStack;
end;

procedure TFdp.M_EditClick;
var s: string;
  i: longint;
  pi: PGFIdent;
  mr: TModalResult;
begin
  AddStack('TFdp.M_EditClick',Self);
  if Assigned(ObjEdit) then begin
  	pi:=nil; mr:=mrYes;
  	if ObjEdit.TypeObj in [toCalc,toCalcBmp] then
    	if GF.LsIdent.Find(ObjEdit.Ident,i) then begin
      	pi:=GF.Idents(i);
        if pi.Edited then mr:=AskCancel(['Объект является вычисляемым,',
        	'его значение было отредактировано раньше.','Можно отредактировать значение ("Да")',
          'или снова сделать его вычисляемым ("Нет").','Редактировать значение объекта ?'])
        else mr:=IfThen(Ask(['Объект является вычисляемым.',
        	'После редактирования его значение не будет вычисляться.',
          'Редактировать значение объекта ?'],false),mrYes,mrCancel);
      end;
    case mr of
      mrYes: begin
        s:=ObjEdit.Text; AddPrnHead('Редактирование текста объекта');
        if EdTextExec('Редактирование текста',s,'',nil,[],edtpText,0,0,'',0,
        TNone.EdObjTextAfterShow,'',nil,nil,'',EdObjTextBeforeShow) then begin
          if Assigned(pi) then pi.Edited:=true;
          SetEdText(ObjEdit,s);
        end;
        DelPrnHead;
      end;
      mrNo: begin
      	pi.Edited:=false; Modified:=true; GF.Calculate; ObjEdit.Text:=pi.Value;
        GF.AutoSize; ClearFind;
      end;
    end;
  end;
  DelStack;
end;

procedure TFdp.EdObjTextBeforeShow;
var f: TEdText;
	p: TPoint;
  w,h,wc,hc: longint;
  wp: TWindowPlacement;
begin
  AddStack('TFdp.EdObjTextBeforeShow',Self);
  f:=pointer(Sender); f.SaveIniForm;
  with f do begin
    MemoEdit.BeforeEnter; MemoEdit.AfterEnter;
    p:=GF.ClientToScreen(Point(GF.GridX[ObjEdit.Left],GF.GridY[ObjEdit.Top]));
    h:=SysMetric.iScrollWidth+4+PnMemo.BevPanel2;
    wc:=Width-ClientWidth; hc:=Height-ClientHeight;
    w:=GF.GridX[ObjEdit.Right]-GF.GridX[ObjEdit.Left]+h+wc;
    Canvas.Font.Assign(MemoEdit.Font);
    Inc(h,max(CanvasMaxH(Canvas),GF.GridY[ObjEdit.Bottom]-GF.GridY[ObjEdit.Top])+RbStatus1.Height+hc);
    if KeyLb1.GetPlace in [rpTop,rpBottom]
    then Inc(h,KeyLb1.Height) else Inc(w,KeyLb1.Width);
    wp.length:=SizeOf(wp); GetWindowPlacement(Handle,@wp);
    p:=MemoEdit.Control.ScreenToClient(p); Inc(p.X,Left); Inc(p.Y,Top);
    wp.rcNormalPosition:=Rect(p.X,p.Y,
      p.X+MaxIntValue([w,KeyLb1.WMin+wc,MinWidthForm(f),400]),
      p.Y+max(h,KeyLb1.HMin+hc));
    wp.showCmd:=SW_HIDE; SetWindowPlacement(Handle,@wp); WindowState:=wsNormal;
  end;
  DelStack;
end;

procedure TFdp.SetEdText;
var i: longint;
begin
  AddStack('TFdp.SetEdText',Self);
  if txt<>pv.Text then begin
	  Modified:=true; pv.Text:=txt;
    if pv.Ident<>'' then
    	if GF.LsIdent.Find(pv.Ident,i) then	begin
      	GF.Idents(i).Value:=txt; GF.Calculate;
      end;
    GF.AutoSize; ClearFind;
  end;
  DelStack;
end;

procedure TFdp.M_EdFontClick;
var f: TGFPackFont;
begin
  AddStack('TFdp.M_EdFontClick',Self);
  if Assigned(ObjEdit) then with EdGenFr do begin
  	TGenForm.GetPPDcm(FileDcm,PartIni,ppd); f:=TGFPackFont.Create;
    try
      GF.GetPPFont(ppd,ObjFont,f);
      if GFEdFontProc(f,SavePrmKeyStr,TNone.SavePrmKeyProc) then begin
        GF.PutPPFont(ppd,ObjFont,f); TGenForm.PutPPDcm(PartIni,ppd); SaveEditPrm;
      end;
    finally
      f.Free;
    end;
  end;
  DelStack;
end;

procedure TFdp.SetModified;
begin
	AddStack('TFdp.SetModified',Self);
  if not Value then Value:=GF.PageInf(GF.Leaf).Modified;
	if Value<>FModified then begin
    FModified:=Value; stFrm.SectLeft[0]:=IfThen(Value,'*',' ');
  end;
  DelStack;
end;

// Вывод строки статуса
procedure TFdp.stFrmFill;
begin
	AddStack('TFdp.stFrmFill',Self);
  with stFrm do begin
  	SectLeft[1]:=Padr(mLeaf,lLeaf);
  	SectLeft[2]:=Padr(mPage,lPage);
    SectLeft[3]:=Padr(mScale,lScale);
    SectRight[0]:=Padr(mTop,lTop);
    SectRight[1]:=Padr(mLeft,lLeft);
  end;
  DelStack;
end;

procedure TFdp.PrPrnChange;
var r: TRect;
begin
	AddStack('TFdp.PrPrnChange',Self);
  with stPrn do begin
    if IsPrinters then begin
	  	with GF,Params.Arr[CurParams] do r:=GFCalcSpotPrn(NFormat,Orientation);
    	SectLeft[0]:='Принтер '+GGPrinter.Printers[GGPrinter.PrinterIndex];
      while SectRight.Count<7 do SectRight.Add('');
      SectRight[6]:='Параметры(мм):';
      SectRight[5]:=StrNum('ширина ',nround(GetDeviceCaps(GGPrinter.Handle,PHYSICALWIDTH)
        /(GetDeviceCaps(GGPrinter.Handle,LOGPIXELSX)/MmInInch)));
      SectRight[4]:=StrNum('высота ',nround(GetDeviceCaps(GGPrinter.Handle,PHYSICALHEIGHT)
        /(GetDeviceCaps(GGPrinter.Handle,LOGPIXELSY)/MmInInch)));
      SectRight[3]:=StrNum('сверху ',r.Top);
      SectRight[2]:=StrNum('снизу ',r.Bottom);
      SectRight[1]:=StrNum('слева ',r.Left);
      SectRight[0]:=StrNum('справа ',r.Right);
    end
    else begin
    	SectLeft[0]:='Принтер не установлен'; SectRight.Clear;
    end;
  end;
  DelStack;
end;

procedure TFdp.ViewDate;
begin
	AddStack('TFdp.ViewDate',Self);
	if MyFileExists(FullName)
  then stGF.SectLeft[0]:=' Дата формирования документа: '
	  +FormatDateTime('dd/mm/yyyy (hh:nn)',GetFileDateTime(FullName))
  else stGF.SectLeft[0]:=' Внимание! Необходимо формирование документа.';
  DelStack;
end;

procedure TFdp.ViewGF;
var isF2,mustF2,isF6: boolean;
  mn: TKeyMenu;
  ost: longint;
begin
	ost:=AddStack('TFdp.ViewGF',Self);
  if not lDopAlg then begin
    GF.CloseDtg;
    try
      GF.Open(GF.FileName,1);
    except
      on EDcmFormError do begin
        SetStack(ost); DelFileAtr(FullName); ViewDate;
      end;
    end;
  end;
  ViewPage; mustF2 := (GF.PageCount>1); SeekKeyMenu(Self,mn);
  if Assigned(tl) then with tl do begin
    isF2:=IsKeyBut(K_F2); isF6:=IsKeyBut(K_F6);
    if not isF6 then begin
      SetKeyFind(ProcKey,'fdpfind',kmGenForm); M_F6.Visible:=true; M_Shift_F6.Visible:=true;
    end;
    if mustF2 and not isF2 then begin
      SetKey(K_F2,'Листы','Список листов',ProcKey,'fdppages',kmGenForm);
      M_F2.Visible:=true;
      SetKey(K_Ctrl_PgUp,'','Предыдущий лист',ProcKey,'fdppages',kmGenForm);
      SetKey(K_Ctrl_PgDn,'','Следующий лист',ProcKey,'fdppages',kmGenForm);
      if Assigned(mn) then with mn do begin
        InsLine(kmGenForm,K_F2);
        EnabledItem(kmGenForm,K_Ctrl_PgUp,false);
        EnabledItem(kmGenForm,K_Ctrl_PgDn,true);
      end;
    end
    else if not mustF2 and isF2 then begin
      if Assigned(mn) then mn.DelLine(kmGenForm,K_F2);
      DelKey(K_ALL,'fdppages'); M_F2.Visible:=false;
    end;
    SetKey(K_Ctrl_U,'','Уменьшить масштаб',ProcKey,'fdpscale',kmEdit);
    SetKey(K_Ctrl_I,'','Увеличить масштаб',ProcKey,'fdpscale',kmEdit);
    SetKey(K_Ctrl_Z,'','Исходный масштаб',ProcKey,'fdpscale',kmEdit);
    if GF.VersInfo.Vers=DcmLastVers then begin
      M_Edit.Visible:=true; M_EdFont.Visible:=not empty(FileDcm);
      M_Edit.Enabled:=true; M_EdFont.Enabled:=true; M_R1.Visible:=true;
      SetKey(K_Ctrl_F10,'Перестр.','Перестроить документ',ProcKey,'fdpview',kmGenForm); M_Ctrl_F10.Visible:=true;
    end
    else DelKey(K_Ctrl_F10,'fdpview');
    M_Enter.Visible:=not(fdoReadOnly in Options);
    M_R2.Visible:=true; M_Scale.Visible:=true; SetScale(GF.ScalePrc);
    M_R3.Visible:=true; M_ArhSave.Visible:=true; M_ArhLoad.Visible:=not(fdoReadOnly in Options);
    if (mustF2 and not isF2) or (not mustF2 and isF2) or not isF6 then ReDrw;
  end;
  if not lDopAlg then Modified:=false;
  PnGF1Bounds; GF.Show; GetParentForm(Self).ActiveControl:=GF;
  DelStack;
end;

procedure TFdp.ViewPage;
var mn: TKeyMenu;
begin
	AddStack('TFdp.ViewPage',Self);
	if MyFileExists(FullName) then begin
  	mLeaf:=stLeaf+Format(' %d/%d',[GF.Leaf,GF.PageCount]);
  	mPage:=stPage+Format(' %d.%d',[GF.PageInf(GF.Leaf).PgLong,GF.PageInf(GF.Leaf).PgSmall]);
    mScale:=stScale+Format(' %d%%',[nround(GF.ScalePrc*100)]);
  end
  else begin
  	mLeaf:=''; mPage:=''; mScale:='';
  end;
  stFrmFill;
  if SeekKeyMenu(Self,mn) then with mn do begin
    EnabledItem(kmGenForm,K_Ctrl_PgUp,GF.Leaf>1);
    EnabledItem(kmGenForm,K_Ctrl_PgDn,GF.Leaf<GF.PageCount);
  end;
  if Assigned(lsExtend) then lsExtend.Clear;
  SetNmExtend;
  DelStack;
end;

procedure TFdp.PnGF1Bounds;
begin
	AddStack('TFdp.PnGF1Bounds',Self);
	with PnGF2 do SetBounds(Left,Top,GF.Width,IfThen(GF.Height<>0,GF.Height+40));
  DelStack;
end;

procedure TFdp.SetScale;
var n: longint;
  procedure Check(Own: TMenuItem);
  var i: longint;
	  mn: TMenuItem;
  begin
  	AddStack('TFdp.SetScale.Check',Self);
    for i:=0 to Own.Count-1 do begin
      mn:=Own.Items[i];
      mn.Checked := Int0(copy(mn.Name,3,MaxInt))=n;
      mn.Default:=mn.Checked;
    end;
    DelStack;
  end;
var kmn: TKeyMenu;
begin
	AddStack('TFdp.SetScale',Self);
	n:=nround(Scale*scRound);
	if n>=scStepRnd then begin
    GF.ScalePrc:=Scale; PnGF1Bounds;
    if SeekKeyMenu(Self,kmn) then kmn.EnabledItem(kmEdit,K_Ctrl_U,n<>scStepRnd);
    M_Ctrl_U.Enabled := n<>scStepRnd; Check(M_Scale);
    if Assigned(pmnScale) then Check(pmnScale.Items);
    mScale:=stScale+Format(' %d%%',[nround(GF.ScalePrc*100)]);
    stFrmFill; 
  end;
  DelStack;
end;

procedure TFdp.ClearFind;
begin
	AddStack('TFdp.ClearFind',Self);
  GF.FindTextOut(FindInfo); FindInfo.aObj:=nil; FindInfo.SelLength:=0;
  DelStack;
end;

procedure TFdp.PnGFEnter;
begin
	AddStack('TFdp.PnGFEnter',Self);
	TRbPanel(Sender).PopupMenu:=pmnBase;
  DelStack;
end;

{procedure TFdp.ScrlGFExitRange;
begin
	AddStack('TFdp.ScrlGFExitRange');
  if not(Mode in [emLeft,emRight]) then
    if not((Mode=emTop) and (GF.Leaf=1)
    or (Mode=emBottom) and (GF.Leaf=GF.PageCount)) then begin
      SetRedraw(ScrlGF);
      if Mode=emTop then begin
        ScrlGF.VertScrollBar.Position:=ScrlGF.VertScrollBar.Range;
        SetPage(GF.Leaf-1);
      end
      else begin
        ScrlGF.VertScrollBar.Position:=0; SetPage(GF.Leaf+1);
      end;
      SetRedraw(ScrlGF,rdrwSet); RepaintAll(ScrlGF);
    end;
  DelStack;
end;}

procedure TFdp.ScrlGFScroll;
var fl: boolean;
begin
	AddStack('TFdp.ScrlGFScroll',Self);
  if (Kind=skVert) and Assigned(tl) then with tl,ScrlGF.VertScrollBar do begin
    if Range>0 then fl := Position=0 else fl:=true;
    if fl and (GF.Leaf>1)
    then SetKey(K_PgUp,'Пред.лист','Предыдущий лист',ProcKey,'fdppgnext',kmGenForm)
    else DelKey(K_PgUp,'fdppgnext');
    if Range>0 then fl := Position+Range/PnGF2.Height*ScrlGF.ClientHeight>=Range else fl:=true;
    if fl and (GF.Leaf<GF.PageCount)
    then SetKey(K_PgDn,'След.лист','Следующий лист',ProcKey,'fdppgnext',kmGenForm)
    else DelKey(K_PgDn,'fdppgnext');
    ReDrw;
  end;
  DelStack;
end;

procedure TFdp.SetPage;
begin
	AddStack('TFdp.SetPage',Self);
	if InRange(Index,1,GF.PageCount) then begin
    ClearFind;
  	if FModified then SaveLeaf(Index) else GF.RestPage(Index);
    PnGF1Bounds; ViewPage; ScrlGFScroll(ScrlGF,skVert,0,0); Modified:=false;
  end;
  DelStack;
end;

procedure TFdp.SaveLeaf(nLeaf: longint);
begin
	AddStack('TFdp.SaveLeaf',Self);
	if FModified then begin
  	if GF.VersInfo.Vers=DcmLastVers then GF.SaveEditLeaf(nLeaf)
    else mess_ok([Format('Ошибка сохранения страницы %d:',[nLeaf]),
    	'необходимо переформировать документ.']);
    Modified:=false;
  end;
  DelStack;
end;

procedure TFdp.SaveLeaf;
begin
  SaveLeaf(GF.Leaf);
end;

procedure TFdp.GFEnter;
begin
  AddStack('TFdp.GFEnter',Self);
  ScrlGFScroll(ScrlGF,skVert,0,0);
  DelStack;
end;

procedure TFdp.GFBeforeCalculate;
begin
  AddStack('TFdp.GFBeforeCalculate',Self);
  if not empty(FileDcm) then begin
    TGenForm.GetPPDcm(FileDcm,PartIni,ppd); SetProg(true);
  end;
  DelStack;
end;

procedure TFdp.GFNoFitOnPage;
begin
  AddStack('TFdp.GFNoFitOnPage',Self);
  if MyVarType(NoFitOnPage)=varArray then vDcmDpg(NoFitOnPage);
  DelStack;
end;

procedure TFdp.GFAfterPaint;
begin
	AddStack('TFdp.GFAfterPaint',Self);
	GF.FindTextOut(FindInfo,[gffndSel]);
  DelStack;
end;

type
  TFontFind = record
    X,Y: longint;
    Font: byte;
  end;

class procedure TFdp.FontFind;
var p: ^TFontFind;
begin
  AddStack('TFdp.FontFind');
  p:=Prm;
  if InRange(p.X,ARect.Left,ARect.Right) and InRange(p.Y,ARect.Top,ARect.Bottom) then p.Font:=nFont;
  DelStack;
end;

procedure TFdp.GFMouseDown;
var h,w: longint;
	pv: PGFObj;
	i: byte;
  sz: TSize;
  p: TFontFind;
  a: TNamePrimStr;
begin
	AddStack('TFdp.GFMouseDown',Self);
  with M_Spot do begin
    if Y<=GF.Spot.Top then Tag:=1
    else if X<=GF.Spot.Left then Tag:=2
    else if Y>=GF.GridY[GF.RowCount] then Tag:=3
    else if X>=GF.GridX[GF.ColCount] then Tag:=4
    else Tag:=0;
    Visible := Tag>0;
    if Visible then begin
      if GF.Params.Arr[GF.CurParams].Orientation=poLandscape
      then Tag:=IfThen(Tag=low(aSpot),high(aSpot),Tag-1);
    	Caption:='Редактирование отступа '+aSpot[Tag];
    end;
  end;
  if M_Edit.Visible then begin
	  ObjEdit:=GF.ObjInPoint(X,Y);
	  M_Edit.Enabled:=Assigned(ObjEdit); M_EdFont.Enabled:=M_Edit.Enabled;
    if M_EdFont.Enabled then begin
      p.X:=nround(X/GF.ScalePrc); p.Y:=nround(Y/GF.ScalePrc); p.Font:=ObjEdit.Font;
      if GF.Fonts[p.Font].Prop.AType=fptNormal then GF.PaintObj1(ObjEdit,false,nil,0,FontFind,@p);
      ObjFont:=p.Font;
    end;
  end;
  if ssLeft in Shift then
    if ssCtrl in Shift then begin
      pv:=GF.ObjInPoint(X,Y);
      if Assigned(pv) then begin
        if not Assigned(PnInf) then begin
          PnInf:=TRbPanel.Create(Self.Owner);
          with PnInf do begin
            Parent:=ScrlGF; Schem:='Status'; SortObj:=False; BevelInner:=bvLowered;
            Visible:=False; OnAfterPaint:=PnInfAfterPaint; SetSchemForm(PnInf);
          end;
        end;
        PnInf.Canvas.Font.Assign(PnInf.Font); h:=iY; w:=0; aInf:=nil;
				if pv.TypeObj in [toBmp,toCalcBmp] then
          if StrDivDlm(cCalcBmp,pv.Text,a)
          then AddFrom(aInf,['Файл рисунка:',a[1],'Пользователь: '+a[2]])
          else AddFrom(aInf,['Файл рисунка:',Trim(pv.Text)])
        else begin
          SchemDM.aFont[dFont1].Assign(GF.Fonts[pv.Font].Font);
        	AddFrom(aInf,['Шрифт:',Format('%d - ',[pv.Font])+Trim(GF.Fonts[pv.Font].Prop.Prim),
          	Trim(FontInf(SchemDM.aFont[dFont1]))]);
        end;
        for i:=low(aInf) to high(aInf) do begin
          sz:=PnInf.Canvas.TextExtent(aInf[i]); Inc(h,sz.cy); MaxSelf(w,sz.cx);
        end;
        with PnInf,ScrlGF.ScreenToClient(GF.ClientToScreen(Point(X,Y))) do begin
          SetBounds(Left,Top,w+iX shl 1,h+iY);
          SetBounds(IfThen(X<Width,X,X-Width),IfThen(Y<Height,Y,Y-Height),Width,Height);
          Show;
        end;
        {with pv^ do
          addmsgfile(Format(
            'Left: %d'+CRLF+
            'Top: %d'+CRLF+
            'Right: %d'+CRLF+
            'Bottom: %d'+CRLF+
            'MinWidth: %d'+CRLF+
            'MinHeight: %d'+CRLF+
            'TypeObj: %d'+CRLF+
            'Alignment: %d'+CRLF+
            'Pin: %d'+CRLF+
            'Color: %d'+CRLF+
            'Font: %d'+CRLF+
            'VOut: %d'+CRLF+
            'Text: %s'+CRLF+
            'Part: %s'+CRLF+
            'Col: %s'+CRLF+
            'State: %d',[
            Left,
            Top,
            Right,
            Bottom,
            MinWidth,
            MinHeight,
            TypeObj,
            Alignment,
            Pin,
            Color,
            Font,
            VOut,
            Text,
            Part,
            Col,
            State]));}
      end;
    end
    else M_EditClick(GF);
  DelStack;
end;

procedure TFdp.PnInfAfterPaint;
var i: byte;
	l,t: longint;
begin
  AddStack('TFdp.PnInfAfterPaint',Self);
  with PnInf do begin
    l:=(Width-Canvas.TextWidth(aInf[0])) div 2; t:=iY;
    for i:=low(aInf) to high(aInf) do begin
      Canvas.TextOut(l,t,aInf[i]); Inc(t,Canvas.TextHeight(aInf[i])); l:=iX;
    end;
  end;
  DelStack;
end;

procedure TFdp.GFMouseMove;
var d: Double;
begin
	AddStack('TFdp.GFMouseMove',Self);
  inherited;
  d:=RateScr*GF.ScalePrc;
  mLeft:=stLeft+Format(' %d мм',[nround(X/d)]);
  mTop:=stTop+Format(' %d мм',[nround(Y/d)]);
  stFrmFill;
  DelStack;
end;

procedure TFdp.GFMouseUp;
begin
	AddStack('TFdp.GFMouseUp',Self);
  if Assigned(PnInf) then PnInf.Hide;
  DelStack;
end;

procedure TFdp.stFrmMouseMove;
var fl: boolean;
begin
	AddStack('TFdp.stFrmMouseMove',Self);
  inf:=stFrm.MouseInfo;
  if Assigned(tl) then fl:=tl.IsKeyBut(K_F2) else fl:=false;
  stFrm.Cursor:=IfThen((inf.SectType=mstLeft) and ((inf.SectNum in [1..2]) and fl or (inf.SectNum=3)),
    crHandPoint,crDefault);
  DelStack;
end;

procedure TFdp.stFrmMouseUp;
var i: longint;
	p: TPoint;
begin
	AddStack('TFdp.stFrmMouseUp',Self);
	if stFrm.Cursor=crHandPoint then
  	if inf.SectNum=3 then begin
      if not Assigned(pmnScale) then begin
        pmnScale:=TPopupMenu.Create(Self);
        for i:=0 to M_Scale.Count-1 do with M_Scale.Items[i] do
          pmnScale.Items.Add(NewItem(Caption,ShortCut,Checked,Enabled,OnClick,HelpContext,Name));
      end;
      p:=TRbStatus(Sender).ClientOrigin; pmnScale.Popup(p.X+X,p.Y+Y);
    end
    else if Assigned(tl) then tl.ExecKey(K_F2);
  DelStack;
end;

procedure TFdp.stPrnClick;
begin
	AddStack('TFdp.stPrnClick',Self);
  if Assigned(tl) then tl.ExecKey(K_F3);
  DelStack;
end;

function TFdp.PrmGetClick;
var ppd1: TPPDocRec;
  fl: boolean;
begin
  AddStack('TFdp.PrmGetClick',Self);
  fl:=true;
  if lEval then
    if PrmGetEval then begin
      ppd1.Params:=GFCopyParams(ppd.Params); ppd1.Fonts:=ppd.Fonts; fl:=false;
    end;
  if fl then TGenForm.GetPPDcm(FileDcm,PartIni,ppd1);
  with ppd1.Params,Arr[low(Arr)] do
    result:=DlmBetween([IfThen(StdFormat,aGFFrm[NFormat])+'('+aGFOrientSmall[Orientation]+')',
      IfThen(not TGenForm.SizeNoLimit(ppd1.Params,low(Arr)),Format('%dx%d мм',[SizeMm.cX,SizeMm.cY])),
      StrNum('отступы(мм): сверху-',SpotMm.Top),StrNum('снизу-',SpotMm.Bottom),
      StrNum('слева-',SpotMm.Left),StrNum('справа-',SpotMm.Right)],', ');
  DelStack;
end;

function PrmDef: TGFParams;
begin
	AddStack('FFdp.PrmDef');
  result:=EdGenFr.GF.Params;
  DelStack;
end;

function TFdp.PrmGetEval;
var ost: longint;
begin
	ost:=AddStack('TFdp.PrmGetEval',Self);
  result:=false;
  try
    TGenForm.GetPPDcm(FileDcm,PartIni,ppd); ls.LoadFromDB(EdGenFr.GF.lsBitMap,PartIni);
    result:=GFPrmExec(ppd,PrmDef,false,ls,
      EdGenFr.GF.lsBitMap,PartIni,FontProc,IfThen(M_Edit.Visible,SavePrmKeyStr),TNone.SavePrmKeyProc,
      nil,twActive,GF.CurParams);
    if result then begin
      TGenForm.PutPPDcm(PartIni,ppd); SaveEditPrm;
    end;
  except
  	on EDcmFormError do SetStack(ost);
  end;
  DelStack;
end;

procedure TFdp.SaveEditPrm;
var i: longint;
begin
  AddStack('TFdp.SaveEditPrm',Self);
  if LastKey=K_Ctrl_F10 then with GF do begin
  	GetPPDcm(FileDcm,PartIni,ppd); Params:=ppd.Params;
    for i:=0 to FontCount-1 do GetPPFont(ppd,i,Fonts[i],EdGenFr.GF);
    AutoSize; SaveEditPrm;
  end;
  DelStack;
end;

procedure TFdp.FontProc;
var i: longint;
begin
	AddStack('TFdp.FontProc',Self);
  if not lAfter then begin
    for i:=0 to EdGenFr.GF.FontCount-1 do IncD(StrList,FontStr(i)+CRLF);
    DecLen(StrList,lCRLF);
    with TKeyLb do KeyStr:=ArrayAsList(
      [GetKeySt(K_Esc,'Выход')
      ,GetKeySt(K_F5,'Редактировать')
      ,GetKeySt(K_Enter,K_F5)
      ,GetKeySt(K_Alt_Home,'По умолчанию')],CRLF);
    ProcKey:=FontKeyProc;
  end;
  DelStack;
end;

procedure TFdp.FontKeyProc;
var ls: TFindListBox;
	i,j: longint;
  f: TGFPackFont;
  fl: boolean;
begin
	AddStack('TFdp.FontKeyProc',Self);
	ls:=pointer(tw); ls.GetIndexFiltered(i,j); fl:=false;
  case Key of
	  // Редактирование шрифта
    K_F5,K_Enter: with EdGenFr do begin
      f:=TGFPackFont.Create;
      try
        GF.GetPPFont(ppd,j,f); fl:=GFEdFontProc(f);
        if fl then GF.PutPPFont(ppd,j,f);
      finally
        f.Free;
      end;
    end;
  	// Выход
    K_Esc: GetParentForm(ls).ModalResult:=mrCancel;
	  // Шрифт по умолчанию
    K_Alt_Home: begin
      TGenForm.PutPPFontDef(ppd,j); fl:=true;
    end;
  end;
  if fl then begin
    ls.ItemSet(i,FontStr(j)); ls.ItemIndex:=i;
  end;
	DelStack;
end;

function TFdp.FontStr;
var f: TGFPackFont;
begin
	AddStack('TFdp.FontStr',Self);
  f:=TGFPackFont.Create;
  try
    EdGenFr.GF.GetPPFont(ppd,i,f);
    SchemDM.aFont[dFont1].Assign(f.Font);
    result:=IfThen(TGenForm.IsPPFontDef(ppd,i),' ','*')+' '+SpaceStr0(i,EdGenFr.FontGet.LenCode,0)+' '
      +padr(f.Prop.Prim,EdGenFr.FontGet.LenName)+' '+FontInf(SchemDM.aFont[dFont1])+' '+f.DopInf;
  finally
    f.Free;
  end;
	DelStack;
end;

procedure TFdp.PrStat;
begin
  AddStack('TFdp.PrStat',Self);
	FormStat:=Sender; FormWait:=nil; PrObj; FormStat:=nil;
  DelStack;
end;

procedure TFdp.PrWait;
begin
  AddStack('TFdp.PrWait',Self);
	FormStat:=nil; FormWait:=Sender; PrObj; FormWait:=nil;
  DelStack;
end;

procedure TFdp.PrObj;
  procedure InterEr;
  begin
  	AddStack('TFdp.PrObj.InterEr',Self);
    InterShowError(Inter,[ieEsc]);
    DelStack;
  end;
var v: variant;
	ost: longint;
  lProc,fl: boolean;
  t,p: string;
  r: TRecDB;
begin
	ost:=AddStack('TFdp.PrObj',Self);
  try
    lProc := Assigned(FOnProcExec) and not lDopAlg;
    try
      OpenDcmFirst;
      if MyFileExists(FullNameExe(FileDcm,'DCM')) then begin
        TGenForm.GetPPDcm(FileDcm,PartIni,ppd);
        EdGenFr.RDocPrm.InitFldDef; EdGenFr.RDocpPrm.InitFldDef;
        VarCreate;
        try
          SetProg(lDopAlg);
          if lProc then FAborted := not FOnProcExec(Self)
          else with Inter do begin
            Name:=IfThen(lDopAlg,'Дополнительные действия по документу','Формирование документа')
              +': '+ExtractFileWithOutExt(FullName);
            fl:=EvalChk(v);
            if lDopAlg then v:=true;
            aIntFree;
            if not fl then begin
              DcmAbort; InterEr;
            end
            else if MyVarType(v)=varBoolean then FAborted := not v else FAborted:=false;
          end;
        finally
          VarFree;
        end;
        if FAborted or GF.FileBufActive then DcmAbort;
      end;
    except
      on E:EDcmBreakError do begin
        SetStack(ost);
        DcmAbort; VertBreak:=E.Vert; KeyBreak:=E.Key;
      end;
      on E:EDcmFormError do begin
        if not lProc then SetStack(ost);
        DcmAbort; ViewDate;
        if lProc then raise
        else begin
          Inter.sError:=E.Message+'.'; InterEr;
        end;
      end;
      on EDcmPartError do SetStack(ost);
    end;
  finally
    if Assigned(RecPrim) then begin
      r:=RecPrim; DWRdbSeek(TCustomRec(r)); t:=r.NameDB; p:=r.LogPrim;
    end
    else begin
      t:=''; p:='';
    end;
    LogWrite(t,
      DlmBetween([p,IfThen(lDopAlg,'Выполнение дополнительных действий'),EdGenFr.RDocpPrm.LogPrim,
      IfThen(FAborted,'выполнение прервано','выполнено успешно')],LogDlm));
  end;
  DelStack;
end;

procedure TFdp.SetProg;
begin
  AddStack('TFdp.SetProg',Self);
  aIntFree;
  with EdGenFr.GF do Inter.SetProg(IfThen(lDopAlg,DopAlg,StrAlg));
  DelStack;
end;

function TFdp.PrFind;
var n: longint;
begin
	AddStack('TFdp.PrFind',Self);
	n:=GF.Leaf; SaveLeaf; result:=GF.FindText(sf,FindInfo);
  if result then begin
    if n<>GF.Leaf then ViewPage;
    GF.FindTextOut(FindInfo,[gffndSel,gffndScrl]);
  end;
  DelStack;
end;

procedure TFdp.SetFocus;
begin
  AddStack('TFdp.SetFocus',Self);
  GF.SetFocus;
  DelStack;
end;

function TFdp.GetState;
begin
  AddStack('TFdp.GetState',Self);
  result:=IfThen(FdpFormOnView,fdpForm,FState);
  DelStack;
end;

procedure TFdp.SetDcmModified;
begin
  AddStack('TFdp.SetDcmModified',Self);
  if FDcmModified<>Value then begin
	  FDcmModified:=Value; IfThenNotify(FOnSetDcmModified,Self);
  end;
  DelStack;
end;

procedure TFdp.M_SpotClick;
var twActive: TWinControl;
begin
	AddStack('TFdp.M_SpotClick',Self);
  CreateForm(TGFPrm,GFPrm);
  with GFPrm do case M_Spot.Tag of
    1: twActive:=ESpTop;
    2: twActive:=ESpLeft;
    3: twActive:=ESpBottom;
  else twActive:=ESpRight;
  end;
  PrmGetEval(twActive);
  DelStack;
end;

{ TSummNum }
class procedure TSummNum.SummException;
begin
  inherited SummException(Format('Таблица %d: ',[nSumm])+Message);
end;

{ TNone }
class procedure TNone.EdObjTextAfterShow;
var f: TEdText;
  pl: TRbPanelPlace;
begin
  AddStack('TNone.EdObjTextAfterShow');
  f:=pointer(Sender); pl:=f.KeyLb1.GetPlace; f.RestIniForm; f.KeyLb1.SetPlace(pl);
  DelStack;
end;

class procedure TNone.PnGFExit;
begin
	AddStack('TNone.PnGFExit');
	TRbPanel(Sender).PopupMenu:=nil;
  DelStack;
end;

class procedure TNone.PrmGetPaint;
var tf: TFldEdit;
begin
  AddStack('TNone.PrmGetPaint');
  tf:=pointer(Sender); TButGet(tf.curget).DrawText(tf,astolin(tf.Canvas,Text,ARect.Right-ARect.Left));
  DelStack;
end;

class procedure TNone.RDocPrmDWSeek;
begin
	AddStack('TNone.RDocPrmDWSeek');
  if Assigned(CurFdp) then begin
  	CurFileDtg:=CurFdp.GF.FileName; RDocpPrmDWSeek(Sender);
  end;
  DelStack;
end;

class procedure TNone.RDocpPrmDWSeek;
var ost: longint;
  //Prm: pointer;
begin
	ost:=AddStack('TNone.RDocpPrmDWSeek');
  with TRecDBDef(Sender) do try
    {if Assigned(DocPrmDWSeek) then DocPrmDWSeek(Sender,Prm,false);
    try}
      if not Seek(TblFldName(fFDTG)+'='+QQs(CurFileDtg)
      +sAND+fUSERNAME+'='+QQs(IfThen(Sender=EdGenFr.RDocPrm,ProgPswd.UserName))) then begin
        NewRec; SetDefValues; Value[fFDTG]:=CurFileDtg;
        if Sender=EdGenFr.RDocPrm then Value[fUSERNAME]:=ProgPswd.UserName;
      end;
    {finally
      if Assigned(DocPrmDWSeek) then DocPrmDWSeek(Sender,Prm,true);
    end;}
  except
    on EDatabaseError do SetStack(ost);
  end;
  DelStack;
end;

class function TNone.gArhListResult;
begin
	AddStack('TNone.gArhListResult');
  if lr.SelectStr<0 then result:='' else result:=ArhTimeNm(gArh.Items[lr.SelectStr]);
  DelStack;
end;

class function TNone.deArhFldCheck;
var i: longint;
  s: string;
begin
  AddStack('TNone.deArhFldCheck');
  if not NoEmpCheck(Sender,'NAME',result) then if result then begin
    s:=TrimRight(TFldEdit(Sender).VarValue);
    for i:=1 to Length(s) do if AnsiMatchStr(s[i],InvalidFileName) then begin
      meserr('Некорректный символ: '+s[i]); result:=false; break;
    end;
  end;
  DelStack;
end;

class procedure TNone.ArhDelProc;
var i: longint;
begin
  AddStack('TNone.ArhDelProc');
  with TFindListBox(tw) do case Key of
    K_F8: begin
      i:=ItemIndex;
      if i>=0 then if Ask(amsDel) then begin
        DelFileAtr(ArhPath+ArhTimeNm(Items[i])); ItemDel(i);
        if Items.Count>0 then ItemIndex:=EnsureRange(i,0,Items.Count-1);
      end;
    end;
    K_Ctrl_F8: if Ask(['Удалить все документы из архива ?']) then begin
    	Filtered:=false; DelMaskFiles(ArhPath+'*.*'); Items.Clear;
    end;
  end;
  DelStack;
end;

class procedure TNone.SavePrmKeyProc;
begin
	AddStack('TNone.SavePrmKeyProc');
  GetParentForm(tw).ModalResult:=mrOk;
  DelStack;
end;

class procedure TNone.KeySummShow;
begin
  AddStack('TNone.KeySummShow');
  TKeyLb.FixKeyShow(Key,false); FormSummExec; TKeyLb.FixKeyShow(Key,true);
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurLib',[TFdp]);
end;

procedure DDGetTrans(inf: PDDatKvInfo; const v: variant; var s: string; var Default: boolean);
var Prm: TFmtNum;
begin
  AddStack('FFdp.DDGetTrans');
  if Assigned(CurFdp) then with CurFdp.GF,Params.Arr[CurParams] do case inf.ft of
    ftInteger,ftFloat: begin
      Default:=false; Prm:=PrmNum; Prm.FracCnt:=inf.Dec; s:=FmtNum(v,Prm);
    end;
    ftDate: begin
      Default:=false; s:=FmtDate(v,PrmDate);
    end;
  end;
  DelStack;
end;

procedure DWValStrTrans(const v: variant; var s: string; var Default: boolean);
begin
  AddStack('FFdp.DDGetTrans');
  if Assigned(CurFdp) then with CurFdp.GF,Params.Arr[CurParams] do case MyVarType(v) of
    V_FLOAT: begin
      Default:=false; s:=FmtNum(v,PrmNum);
    end;
    V_DATE: begin
      Default:=false; s:=FmtDate(v,PrmDate);
    end;
  end;
  DelStack;
end;


function GFSaveDcm: boolean;
begin
  AddStack('FFdp.GFSaveDcm');
  if Assigned(CurFdp) then result := fdoSaveDcm in CurFdp.FOptions else result:=false;
  DelStack;
end;

procedure NumGetDWFldValue(var Value: variant; l,t: longint; var lDone: boolean);
var Prm: TFmtNum;
begin
  AddStack('FFdp.NumGetDWFldValue');
  if Assigned(CurFdp) then begin
    lDone:=false;
    if MyVarType(Value)=varString then Float0Self(Value);
    with CurFdp.GF do Prm:=Params.Arr[CurParams].PrmNum;
    Prm.FracCnt:=t; FmtNumSelf(Value,Prm);
  end;
  DelStack;
end;

procedure HelpTblProc(const Name: string; var result: variant);
var w: TGFWinList;
begin
  AddStack('FFdp.HelpTblProc');
  if Name=''
    then result:=VarArrayOf([VarArrayOf(['ДОКВВОД','Вид окна ввода для документа'])])
  else if Name='ДОКВВОД' then begin
    result:=VarArrayCreate([byte(low(aWinExec)),byte(high(aWinExec))],varVariant);
    for w:=low(aWinExec) to high(aWinExec) do result[byte(w)]:=aWinExec[w,2];
  end;
  DelStack;
end;

procedure EvalEnclosingProc(beforeEval: boolean; var p: pointer);
begin
  AddStack('FFdp.EvalEnclosingProc');
  if nInterStack=0 then
    if beforeEval then p:=pointer(nSumm) else nSumm:=byte(p);
  DelStack;
end;

procedure Init;
  function sConst(const c: string): string;
  begin
  	AddStack('FFdp.initialization.sConst');
    result:=IfThen(c<>'',' (см. константы "'+c+'_...")');
    DelStack;
  end;
  procedure aVar(const Capt,pref: string; const av,anm: array of string; LowLim: byte = 0);
  var p: string;
    i: byte;
  begin
  	AddStack('FFdp.initialization.aVar');
    p:=pref+'_'; TInter.setvar('$$$gfobj1',p,Capt);
    for i:=low(av) to high(av) do TInter.setvar(p+av[i],Capt+' '+anm[i],i_Const,LowLim+i,'I',true);
    DelStack;
  end;
const
	avo: TGFVOStr = ('НАЧ','КОН','ВСЕ');
	apin: TGFPinStr = ('ВЕРХ_ЛЕВ','ВЕРХ_ПРАВ','НИЗ_ЛЕВ','НИЗ_ПРАВ');
	aalgm: TGFAlgmStr = ('ВЕРХ_ЛЕВ','ВЕРХ_ЦЕНТ','ВЕРХ_ПРАВ','ЦЕНТ_ЛЕВ','ЦЕНТР','ЦЕНТ_ПРАВ','НИЗ_ЛЕВ','НИЗ_ЦЕНТ','НИЗ_ПРАВ');
	afrm: TGFFrmStr = ('А3','А4','А5','А3А','А4А','А5А','НЕТ');
	aorn: TPrinterOrientationStr = ('КНИЖ','АЛЬБ');
  ato: TGFTypeObjStr = ('ТЕКСТ','ФМЛ','РИС','ВЫЧ','ВВОД','ПОДСК','ВЫЧРИС');
  avgfo: TGFPropObjStr =
    ('РАЗМ'
	  ,'ПРИЖ'
	  ,'ЦВЕТ'
	  ,'ВЫВОД'
	  ,''
	  ,''
	  ,''
	  ,''
	  ,''
	  ,''
	  ,'ТПОБ'
	  ,''
    );
  aHF: array[TGFHeadFoot] of TNamePrimStr =
    (('РАЗДЕЛ_НАЧ'    ,'начало')
    ,('РАЗДЕЛ_КОН'    ,'конец')
    ,('РАЗДЕЛ_ПРИМНАЧ','начало примечаний')
    ,('РАЗДЕЛ_ПРИМ'   ,'примечания')
    );
  aAddPart: array[TGFAddPartList] of record
    name,hint: string;
    help: longint;
  end =
    ((name:'ДОК_РАЗД_1'  ; hint:'Добавить разделы, выводимые только на первой части страницы'              ; help:624)
    ,(name:'ДОК_РАЗД_КОН'; hint:'Добавить разделы, после которых не выводится раздел, закрывающий страницу'; help:625)
    );
  aLineCol: array[TSummLineCol] of record
    nmArr,nmIs,nmCnt,nmRnm,nmDel,mRod,mVin,prm: string;
    hArr,hIs,hCnt,hRnm,hDel: longint;
  end =
    ((nmArr:'ТБЛ_СТРОКИ' ;nmIs:'ТБЛ_ЕСТЬ_СТР'  ;nmCnt:'ТБЛ_КОЛ_СТР'  ;nmRnm:'ТБЛ_СМЕН_СТР'  ;nmDel:'ТБЛ_УДАЛ_СТР'  ;mRod:'строк'   ;mVin:'строки' ;prm:'НаимСтр'  ;hArr:708;hIs:717;hCnt:725;hRnm:714;hDel:723)
    ,(nmArr:'ТБЛ_СТОЛБЦЫ';nmIs:'ТБЛ_ЕСТЬ_СТОЛБ';nmCnt:'ТБЛ_КОЛ_СТОЛБ';nmRnm:'ТБЛ_СМЕН_СТОЛБ';nmDel:'ТБЛ_УДАЛ_СТОЛБ';mRod:'столбцов';mVin:'столбцы';prm:'НаимСтолб';hArr:707;hIs:718;hCnt:726;hRnm:715;hDel:724)
    );
var i: TGFPropObjList;
  rf: TVarCurGFFill;
  hf: TGFHeadFoot;
  fl: boolean;
  lc: TSummLineCol;
  p: TGFAddPartList;
begin
	AddStack('FFdp.initialization');
  Summ:=FSumm;
  MyTypes.DDGetTrans:=DDGetTrans; MyTypes.DWValStrTrans:=DWValStrTrans;
  FFldedit.NumGetDWFldValue:=NumGetDWFldValue;
  FEdGenFr.GFSaveDcm:=GFSaveDcm;
  AddFrom(EvalEnclosingProc);
  SavePrmKeyStr:=TKeyLb.GetKeySt(K_Ctrl_F10,'Перестр.','Сохранить и перестроить документ',kmFile);
  TKeyLb.SetFixKey(K_Alt_G,'Просмотр таблицы суммирования',TNone.KeySummShow,kmDesign);

	with TInter do begin
    setvar('$gfsumm','ТБЛ_','Свойства таблицы');
    setvar('ТБЛ_ИМЯ_РАЗД','Наименование текущей строки таблицы',VarCurGF,vgfCurLine,'C',true);
    setvar(VarNSumm,'Номер текущей таблицы',VarCurGF,vgfNSumm,'I');

    setvar('$genform',svGF);
    setvar('ДОК_ИМЯ_КОЛ','Наименование текущей колонки',VarCurGF,vgfNameCol,'C',true);
    setvar('ДОК_ИМЯ_РАЗД','Наименование текущего раздела',VarCurGF,vgfNamePart,'C',true);
    SetVar('ИМЯ_СТРАНИЦЫ','Наименование текущей страницы',VarCurGF,vgfCurPageName,'C',false,3001);
    setvar('НОМЕР_ЛИСТА','Номер текущего листа формирующегося документа',VarCurGF,vgfLeaf,'I',true);
    setvar('НОМЕР_СТРАНИЦЫ','Номер текущей страницы формирующегося документа',VarCurGF,vgfPage,'I',true);
    for hf:=low(aHF) to high(aHF) do
      SetVar(aHF[hf,1],'Разделы - '+aHF[hf,2]+' страницы',VarCurGF,aHFVarCurGF[hf],'CA',false,0,HelpFileStd,'HFVarCurGF');
    setvar('ДОК_ФОРМ_НАЧ','Дата и время начала формирования документа',VarCurGF,vgfDateTimeBeg,'F',true);
    setvar('ДОК_ДАТА_ВРЕМЯ','Дата и время начала формирования документа (для вывода в документ)',VarCurGF,vgfDateTimeBegStr,'C',true);
    SetVar('ДОК_СТР_РАЗД','Текущий раздел для наименования страницы',VarCurGF,vgfCurPagePart,'C',false,3001);
    SetVar('ДОК_СТР_ПЕРВЫЙ','Выводить в наименовании страницы только первый раздел (или разделитель между разделами)',VarCurGF,vgfCurPageFirst,'LC',false,3001);
    setvar('ДОК_ФОРМАТ','Номер текущего формата',VarCurGF,vgfCurParams,'I');
    setvar('ДОК_СПРАЗД','Список выведенных разделов на текущей странице',VarCurGF,vgfVArrPart,'A',true);
    setvar('ДОК_ЛИСТ','Номер текущего листа описания документа',VarCurGF,vgfDcmLeaf,'I');
    setvar('ДОК_АВТВСЕУР','Автоматически порождаемые разделы/колонки любого уровня ('+vFalse+' - только предыдущего)',VarCurGF,vgfDynAnyLevel,'L');
    setvar('ДОК_ЛИСТБЛОК','Текущий блок листов документа',VarCurGF,vgfBlockLeaf,'C');
    setvar('ДОК_ЗАППУСТДРСТР','Заполнение пустот объектами перед определением необходимости перевода страницы',VarCurGF,vgfAutoNewPageObjSpace,'L');
    SetVar('ДОК_ПРИНТ_ОТСТУПЫ','Минимальные отступы принтера',VarCurGF,vgfSpotPrn,'A',true,0,HelpFileStd);

    setvar('$$gfprm','ДПРМ_','Параметры формы документа');

    setvar('$$$gfprm','ДПРМ_','Общие');
    setvar('ДПРМ_СТАНД','Стандартный формат',VarCurGF,vgfStdFormat,'L');
    setvar('ДПРМ_ФОРМАТ','Формат (см. константы "ДПРМ_ФРМ_...")',VarCurGF,vgfNFormat,'I');
    setvar('ДПРМ_ОРИЕНТ','Ориентация (см. константы "ДПРМ_ОРНТ_...")',VarCurGF,vgfOrientation,'I');
    setvar('ДПРМ_ММ_ШИРИНА','Ширина (мм)',VarCurGF,vgfWidthMm,'I');
    setvar('ДПРМ_ММ_ВЫСОТА','Высота (мм)',VarCurGF,vgfHeightMm,'I');
    setvar('ДПРМ_МИНЛИН','Минимальная толщина линии',VarCurGF,vgfGridLineMin,'I');
    setvar('ДПРМ_МАКСЛИН','Максимальная толщина линии',VarCurGF,vgfGridLineWidth,'I');
    setvar('ДПРМ_ДАТАДОК','Выводить дату формирования',VarCurGF,vgfDateTime,'L');
    setvar('ДПРМ_РЗБ_ШИР','Разбить страницу по ширине',VarCurGF,vgfHorzBreak,'L');
    setvar('ДПРМ_РЗБ_ВЫС','Разбить страницу по высоте',VarCurGF,vgfVertBreak,'L');
    setvar('ДПРМ_ВСЯ_ШИР','Растянуть по всей ширине листа',VarCurGF,vgfHorzWidth,'L');
    setvar('ДПРМ_ВСЯ_ВЫС','Растянуть по всей высоте листа',VarCurGF,vgfVertWidth,'L');

    setvar('$$$gfprm','ДПРМ_ММ_','Отступы (мм)');
    setvar('ДПРМ_ММ_СЛЕВА','Отступ слева (мм)',VarCurGF,vgfSpLeftMm,'I');
    setvar('ДПРМ_ММ_СПРАВА','Отступ справа (мм)',VarCurGF,vgfSpRightMm,'I');
    setvar('ДПРМ_ММ_СВЕРХУ','Отступ сверху (мм)',VarCurGF,vgfSpTopMm,'I');
    setvar('ДПРМ_ММ_СНИЗУ','Отступ снизу (мм)',VarCurGF,vgfSpBottomMm,'I');

    setvar('$$$gfprm','ДПРМ_ЧСЛ_','Числа');
    setvar('ДПРМ_ЧСЛ_РАЗД','Формат числа: разделитель целой и дробной части',VarCurGF,vgfNumFracDlm,'C');
    setvar('ДПРМ_ЧСЛ_ЗН','Формат числа: количество знаков',VarCurGF,vgfNumAllCnt,'I');
    setvar('ДПРМ_ЧСЛ_ДРБ','Формат числа: количество дробных знаков',VarCurGF,vgfNumFracCnt,'I');
    setvar('ДПРМ_ЧСЛ_ПУСТ','Формат числа: выводить пустую дробную часть',VarCurGF,vgfNumFracEmp,'L');
    setvar('ДПРМ_ЧСЛ_РЗР','Формат числа: разделять разряды',VarCurGF,vgfNumDigIsDlm,'L');
    setvar('ДПРМ_ЧСЛ_РЗР_РАЗД','Формат числа: разделитель разрядов',VarCurGF,vgfNumDigDlm,'C');
    setvar('ДПРМ_ЧСЛ_НЕТ_0','Формат числа: не выводить 0',VarCurGF,vgfNumZeroEmp,'L');
    setvar('ДПРМ_ЧСЛ_СТР_0','Формат числа: строка, заменяющая 0',VarCurGF,vgfNumsZero,'C');

    setvar('$$$gfprm','ДПРМ_ДАТ_','Даты');
    setvar('ДПРМ_ДАТ_РАЗД','Формат даты: разделитель',VarCurGF,vgfDateDlm,'C');
    setvar('ДПРМ_ДАТ_ГОДЗН','Формат даты: год, количество знаков',VarCurGF,vgfDateNYear,'I');
    setvar('ДПРМ_ДАТ_МЕСГОД','Формат даты: только месяц.год',VarCurGF,vgfDateMMYY,'L');
    setvar('ДПРМ_ДАТ_НЕТ_0','Формат даты: не выводить пустую дату',VarCurGF,vgfDateZeroEmp,'L');
    setvar('ДПРМ_ДАТ_СТР_0','Формат числа: строка, заменяющая пустую дату',VarCurGF,vgfDatesZero,'C');

    setvar('$$gfobj','ОБ_','Свойства объектов');
    for i:=low(avgfo) to high(avgfo) do with aGFPropObj[i] do
      setvar(v,nm+sConst(avgfo[i]),VarCurGFObj,i,t);

    rf.tp:=low(aGFPropLineType);
    while rf.tp<=high(aGFPropLineType) do begin
      setvar('$$$gfobj',aGFPropLineType[rf.tp,1],aGFPropLineType[rf.tp,2]+' линии');
      rf.pl:=low(aGFPropLine);
      while rf.pl<=high(aGFPropLine) do begin
        setvar(aGFPropLineType[rf.tp,1]+aGFPropLine[rf.pl],
          GFPropLineCapt(rf.tp,rf.pl)+IfThen(rf.tp=vgflnColor,sConst(avgfo[vgfoColor])),VarCurGFFill,rf.w,'I');
        Inc(rf.pl);
      end;
      Inc(rf.tp);
    end;

    setvar('$$gfobj1',svConst);
    aVar(svGFVO,avgfo[vgfoVOut],avo,aGFVOut);
    aVar(svGFPin,avgfo[vgfoPin],apin,aGFPin);
    aVar(svGFAlgm,avgfo[vgfoAlignment],aalgm,aGFAlgm);
    aVar('Формат','ДПРМ_ФРМ',afrm,aGFFrm,byte(low(afrm)));
    aVar('Направление печати','ДПРМ_ОРНТ',aorn,aGFOrient);
    aVar(svGFTypeObj,avgfo[vgfoTypeObj],ato,aGFTypeObj,byte(low(ato)));

    SetFunction('Генератор форм',600);
    SetFunction('ДОК_ВВОД_ОКНО','Выводит окно ввода параметров документа',
      ['[ВывВсегда: логическое = '+vTrue+']','[Вид: логическое|целое = 0]'],['LU','LNU'],DcmGetWnd,null,601,'L');
    SetFunction('ДОК_ДР_СТР','Создать новую страницу в документе',
      ['[ВывЗакрРазд: логическое = '+vFalse+']','[ВывПрим: логическое = '+vFalse+']'],['LU','LU'],DcmNewPage,null);
    SetFunction('ДОК_ЗАКРЫТЬ','Закончить формирование документа',DcmClose,null);
    SetFunction('ДОК_ИНДИКАТОР','Вывести индикатор формирования документа',
      ['[Заголовок: строка]','[Подсказка: строка]','[Процент: число]'],
      ['CU','CU','NU'],DcmSayStat,null,602,'L');
    SetFunction('ДОК_КОЛ_ДОБ','Добавить колонку',['НаимКол: строка|массив'],['CA'],DcmAddCol,null,603);
    SetFunction('ДОК_КОЛ_УДАЛ','Удалить колонку',['НаимКол: строка'],['C'],DcmDelCol,null,604);
    SetFunction('ДОК_КОЛ_УДАЛГР','Удалить группу колонок',['НаимКол: строка'],['C'],DcmDelColGr,null,605);
    SetFunction('ДОК_ПРЕРВАТЬ','Прервать формирование документа',DcmAbort,null);
    SetFunction('ДОК_РАЗДЕЛ','Вывести раздел в документ',['[НаимРазд: любое]','[РаздПрим: строка]'],
      ['','CU'],DcmPart,null,606);
    SetFunction('ДОК_ЧАСТЬ_КОЛ','Часть наименования текущей колонки',
      ['Номер: целое'],['N'],SegmentCol,null,607,'C');
    SetFunction('ДОК_ЧАСТЬ_РАЗД','Часть наименования текущего раздела',
      ['Номер: целое'],['N'],SegmentPart,null,608,'C');
    SetFunction('КОЛ_КОН_ДОБ','Добавить колонку, закрывающую страницу',
      ['НаимКол: строка'],['C'],AddColFoot,null,609);
    SetFunction('КОЛ_НАЧ_ДОБ','Добавить колонку, открывающую страницу',
      ['НаимКол: строка'],['C'],AddColHead,null,610);
    SetFunction('ДОК_СОХРАНИТЬ','Сохранить значения данных и параметров документа',DcmUpdateRec,null,611);
    SetFunction('ДОК_ЗНАЧЕНИЕ','Преобразует значение в строку в соответствии с параметрами формы',
      ['Знач: число|дата|строка','[Формат: целое = ДОК_ФОРМАТ]','[ФмтЧисл: массив]','[ФмтДат: массив]'],
      ['NDC','NU','AU','AU'],DcmStrPrm,null,612,'C');
    SetFunction(FuncDcmDpg,'Выполнить алгоритм формирования документа с параметрами',
      InterPrmMax(['Алг: строка|число|дата|логическое|массив']),['CNDLA'],DcmDpg,null,613,'*');
    SetFunction('ДОК_ТЕКСТ_ММ','Длина текста в миллиметрах',
      ['Текст: строка','[Свойства: целое|массив]','[Высота: логическое = '+vFalse+']','[Округл: логическое = '+vFalse+']'],
      ['C','NAU','LU','LU'],DcmTextMm,null,614,'F');
    SetFunction('ДОК_ОТКРЫТЬ','Открыть формирование документа',
      ['[Лист: целое = 1]'],['NU'],DcmForm,null,615);
    SetFunction('ДОК_ГРАННИЗ','Возвращает нижнюю или правую границу документа в миллиметрах',
      ['[Прав: логическое = '+vFalse+']'],['LU'],DcmBoundMm,null,616,'F');
    SetFunction('ДОК_ИДЗНАЧ','Значение объекта по идентификатору',
      ['Идент: строка','[Знач: число|дата|строка]'],['C','NDCU'],DcmIdent,null,617,'CA');
    SetFunction('ДОК_ИДСПИС','Список идентификаторов по началу или по шаблону',
      ['ИдНач: строка'],['C'],DcmIdArr,diaAllIdent,618,'A');
    SetFunction('ДОК_ИДЕСТЬ','Признак наличия идентификаторов по началу или по шаблону',
      ['ИдНач: строка'],['C'],DcmIdArr,diaIs,0,'L');
    SetFunction('ДОК_КОЛ_СПИС','Список колонок',
      ['[НаимКол: строка = ""]'],['CU'],DcmArrCol,null,619,'A');
    SetFunction('ДОК_ЛИСТНАИМ','Наименование указанного листа в описании документа',
      ['[Ном: целое = НОМЕР_ЛИСТА]'],['NU'],DcmPageName,null,620,'C');
    SetFunction('ДОК_ЛИСТКОЛ','Количество листов',
      ['[Описание: логическое = '+vTrue+']~[Блок: строка]'],['LCU'],DcmPageCnt,null,621,'I');
    SetFunction('ДОК_OFFICE','Преобразовать документ в документ Microsoft Office',
      ['Файл: строка','[Редактор: целое = 1]','[Формат: целое = 2]','[ВидПреобр: целое = 1]',
      '[Листы: целое|строка]'],
      ['C','NU','NU','NU','NCU'],DcmMsOff,null,622,'L');
    SetFunction('ДОК_СТРОКИ','Распределение содержимого строки по нескольким объектам',
      ['Стр: строка','Идент: строка','Номер: целое','[Макс: логическое = '+vFalse+']','[МинСтр: целое = 0]',
      '[ПустБезОбрамл: логическое = '+vFalse+']'],
      ['C','C','N','LU','NU','LU'],DcmIdStr,null,623,'C');
    for p:=low(aAddPart) to high(aAddPart) do with aAddPart[p] do
      SetFunction(name,hint,['Раздел: строка|массив'],['CA'],AddPart,p,help);
    SetFunction('ДОК_ОБЪЕКТ','Изменить свойства объекта документа',
      ['Идент: строка','Свойство: строка~Свойства: массив','[Значение: целое]~[Значения: массив]'],
      ['C','CA','IAU'],c_gfobj,longint(@GFObjPropProc),626,'ILCAU');
    SetFunction('ДОК_ЭДОПОДП','Параметры подписания документа пользователем',
      ['[Пользователь: строка]','[Ключ: строка]'],['CU','CU'],c_edo,null,0,'AU');
    SetFunction(FuncEdoOrgFlt,c_EdoOrgFlt);

    SetFunction('Таблица',700);
    SetFunction('ТБЛ_ВЫВЕСТИ','Вывести таблицу в документ',
      ['Начало: строка','[Шаблоны: массив]','[Разделы: массив]',
      '[СтрНач: строка|массив]','[СтрКон: строка|массив]',
      '[ДокНач: любое]','[ДокКон: любое]','[Индикатор: логическое = '+vTrue+']','[Алг: логическое = '+vFalse+']',
      '[ШаблСтрНачКон: массив]','[ОбНеВСтр: массив]'],
      ['C','AU','AU','CAU','CAU','','','LU','LU','AU','AU'],SDPart,null,701,'L');
    SetFunction('ТБЛ_ДОБ_СТОЛБ','Добавить столбец в таблицу',
      ['НаимСтолб: строка|массив','[Строковый: логическое = '+vFalse+']'],['CA','LU'],SummAddCol,null,702);
    SetFunction('ТБЛ_ДОБ_СТР','Добавить строку в таблицу',
      ['НаимСтр: строка|массив'],['CA'],SummAddLine,null,703);
    SetFunction('ТБЛ_ДОБАВИТЬ','Добавить значение в таблицу',
      ['НаимСтр: строка','НаимСтолб: строка','[Знач: число|строка|дата = 1]','[Точн: целое]',
      '[Не0: логическое = '+vFalse+']'],
      ['C','C','NCDU','NU','LU'],SummAdd,null,704,'FC');
    SetFunction('ТБЛ_ЗНАЧЕНИЕ','Значение ячейки таблицы',
      ['НаимСтолб: строка','[НаимСтр: строка = ТБЛ_ИМЯ_РАЗД]','[Умолч: число|строка|дата]'],
      ['C','CU','NCDU'],SummValue,null,705,'FC');
    SetFunction('ТБЛ_МАСК_СТР','Добавление строки в таблицу по маске',
      ['Маска: строка','Результат: строка'],['C','C'],SummSepLine,null,706,'L');
    for lc:=low(aLineCol) to high(aLineCol) do with aLineCol[lc] do begin
      SetFunction(nmArr,'Список '+mRod+' таблицы с одинаковым началом или по шаблону',
        ['['+prm+': строка = ""]','[Вид: целое|логическое = 0]'],['CU','NLU'],SummArrName,lc,hArr,'ACI');
      SetFunction(nmIs,'Признак наличия '+mRod+' в таблице',
        ['['+prm+': строка = ""]'],['CU'],SummIsName,lc,hIs,'L');
      SetFunction(nmCnt,'Количество '+mRod+' в таблице',
        ['['+prm+': строка = ""]'],['CU'],SummCntName,lc,hCnt,'I');
      SetFunction(nmRnm,'Изменить наименования '+mRod,
        ['Шабл1: строка','Шабл2: строка','[СумШабл: логическое = '+vFalse+']','[ТочнСовп: логическое = '+vFalse+']'],
        ['C','C','LU','LU'],SummRnmName,lc,hRnm);
      SetFunction(nmDel,'Удалить '+mVin+' таблицы с одинаковым началом или по шаблону',
        [prm+': строка','[ТочнСовп: логическое = '+vFalse+']'],['C','LU'],SummDelName,lc,hDel);
    end;
    SetFunction('ТБЛ_СУМ_СТОЛБ','Суммирование значений ячеек столбцов',
      ['НаимСтолб: строка','НаимРез: строка','[НаимСтр: строка]','[Точн: целое]',
      '[Кроме: строка]','[Выч: логическое = '+vFalse+']','[Более1: логическое = '+vFalse+']'],
      ['C','C','CU','NU','CU','LU','LU'],SummSumCol,null,709,'L');
    SetFunction('ТБЛ_СУМ_СТР','Суммирование значений ячеек строк',
      ['НаимСтр: строка','НаимРез: строка','[НаимСтолб: строка]','[Точн: целое]',
      '[Кроме: строка]','[Выч: логическое = '+vFalse+']','[Более1: логическое = '+vFalse+']'],
      ['C','C','CU','NU','CU','LU','LU'],SummSumLine,null,710,'L');
    SetFunction('ТБЛ_УСТАНОВИТЬ','Установить значение в таблице',
      ['НаимСтр: строка','НаимСтолб: строка','[Знач: число|строка|дата = 0]','[Точн: целое]'],
      ['C','C','NCDU','NU'],SummSet,null,711,'FC');
    SetFunction('ТБЛ_ЧАСТЬ_СТР','Часть наименования текущей строки таблицы',
      ['Номер: целое'],['N'],SummSegmLine,null,712,'C');
    SetFunction('ТБЛ_СУММА','Сумма значений ячеек',
      ['Стр: строка','Столб: строка','[Точн: целое]'],['C','C','NU'],SummSumLineCol,null,713,'FC');
    for fl:=false to true do SetFunction('ТБЛ_ПРОСМОТР'+IfThen(fl,'_ОТЛ'),
      'Вывести таблицу на экран'+IfThen(fl,' (отладка)'),
      ['[ШаблонСтр: строка]','[ШаблонСтолб: строка]','[Загл: строка = ""]'],
      ['CU','CU','CU'],SummShow,fl,716);
    SetFunction('ТБЛ_РАСПРЕД','Распределить сумму по ячейкам таблицы',
      ['Стр: строка','СтбОткуда: строка','[СтбКуда: строка = СтбОткуда]','Точн: целое',
      'Сумма: число|массив','[Оптим: логическое = '+vFalse+']'],
      ['C','C','CU','N','NA','LU'],SummRaspr,null,719,'L');
    SetFunction('ТБЛ_ОКРУГЛ','Округлить указанные значения с учётом условий',
      ['Знач: массив','[Сум: массив]','[Равно: массив]','[НеИспольз: пусто]','[УслСум: массив]',
      '[Точн: целое]'],
      ['A','AU','AU','U','AU','NU'],ArrCondRound,null,720,'AU');
    SetFunction('ТБЛ_ОБНУЛИТЬ','Обнулить таблицы',
      ['[Начало: целое = '+VarNSumm+']','[Конец: целое = Начало]'],['NU','NU'],SummInit,null,721);
    SetFunction('ТБЛ_УСЛСУМ','Описание условий суммирования для функции ТБЛ_ОКРУГЛ()',
      ['Стр: строка|массив','Столб: строка|массив','[РезСтр: строка]','[РезСтолб: строка]',
      '[ВтчСтр: логическое = '+vFalse+']','[ВтчСтолб: логическое = '+vFalse+']','[Пров: логическое = '+vFalse+']',
      '[Точн: целое]','[Приор: целое = 0]'],
      ['CA','CA','CU','CU','LU','LU','LU','NU','NU'],ArrCondMatrix,null,722,'AC');
    SetFunction('ТБЛ_ШАБЛОН','Преобразует строку в сооветствии с шаблоном',
      ['Стр: строка','ШаблСтр: строка','ШаблРез: строка'],['C','C','C'],SummNsumsum,null,0,'C');
    SetFunction('ТБЛ_ВФАЙЛ','Сохраняет таблицу в файл',['Файл: строка'],['C'],SummFile,true);
    SetFunction('ТБЛ_ИЗФАЙЛА','Загружает таблицу из файла',['Файл: строка'],['C'],SummFile,false);
    SetFunction('ТБЛ_КОП_СТР','Скопировать значения из одной строки таблицы в другую',
      ['Стр1: строка','Стр2: строка','[НаимСтолб: строка]'],['C','C','CU'],SummCopyLine,null);
  end;
  AddFrom(HelpTblProc);
  DelStack;
end;

procedure Final;
var i: longint;
begin
	AddStack('FFdp.Final');
  aIntFree;
  for i:=low(aSumm) to high(aSumm) do aSumm[i].Free;
  DelStack;
end;

initialization
  Init;
finalization
  Final;
end.
