unit FDWPrm;

interface

{$I LIBTEST}
uses
  Windows, Messages, Classes, Controls, Forms, Menus, ExtCtrls, DB, Grids, ComCtrls, StdCtrls,
  MyTypes, FrmEdt, KeyMenu, PnlEdit, Keylb, Fpanel, FFldedit, ButGet, RecVal, Recdb, ComboGet, DefEdit,
    Inter, MulQry, StrBrowl, ListF2;

type
  TDataWinSearchOpt = set of (dwsIdent,dwsClear);

	TDataWin = class(TObject)
  private
		function SearchIdentPrm(const s,sSubStr: string; var aInfo: TDWSearchAInfo;
    	Opt: TDataWinSearchOpt): boolean;
  public
  	Zgl,Fields,Pages,DcmDef: string;
    AskByCancel,DcmBased: boolean;
    SortMode: TSortMode;
    aForm: TDWFormStr;
    class function CreateOne(var Sender: TDataWin): TDataWin;
		procedure LoadFromStr(const s: string);
		function SaveToStr: string;
		procedure ButGetPaint(Sender: TObject; const ARect: TRect; const Value: string;
    	const cPref: string = '');
    function IsAllFldInDcm(var nmf: string): boolean;
		procedure Assign(Source: TDataWin);
		function Equals(dw: TDataWin): boolean;
		function ReplaceNameRec(const s,OldNmRec,NewNmRec: string): string;
		procedure ReplaceNameRecSelf(var s: string; const OldNmRec,NewNmRec: string);
    procedure DoSetting(var s: string);
		function SetSearchNode(tnParent: TTreeNode; const aInfo: TDWSearchAInfo): TTreeNode;
    class procedure FldDefault(const r: TDWVidRec; var ap: TDEPrmStr);
    class function aGet: TDataWin; overload;
    class function aGet(const s: string): TDataWin; overload;
    class function aGet(var Sender: TDataWin): TDataWin; overload;
    class function aGetClean: TDataWin;
    class function aCur: TDataWin;
    class procedure aFree;
    class function aGetFields(const s: string): string;
  end;

  TArrDataWin = array of TDataWin;

  TDWPrm = class(TFormEdt)
    Rec: TRecVal;
    FormGet: TButGet;
    PnPrm: TRbPanel;
    EZgl: TFldEdit;
    ESortMode: TFldEdit;
    PnForm: TRbPanel;
    EAskByCancel: TFldEdit;
    EForm: TFldEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    function PanelEdit1Valid(Sender: TObject): Boolean;
    function PanelEdit1AskCancel(Sender: TObject): Boolean;
    function FormGetClick(Sender: TObject; lEval: Boolean): String;
    procedure PnFormResize(Sender: TObject);
    procedure EAskByCancelChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    procedure ESortModeChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    odw: TDataWin;
    afEd: array[TDWForm] of TFldEdit;
    FormHelpFileProc: TDWFormHelpFileProc;
    FormHelpFilePrm: pointer;
    aInfo: TDWSearchAInfo;
    SearchInfo: TDWSearchInfo;
    tmSearch: TTimer;
		function prFind(Sender: TControl; const sf: string): boolean;
		procedure TimerSearch(Sender: TObject);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
    procedure FmlGetHelp(var Message: TMessage); message WM_HELPFILL;
  public
    { Public declarations }
    dw: TDataWin;
		class procedure Execute(DataWin: TDataWin; SrchInfo: TDWSearchInfo; aFormHelp: PDWFormHelp;
      aFormHelpFileProc: TDWFormHelpFileProc; aFormHelpFilePrm: pointer);
		class procedure VarCreate(rdb: TRecDBDef); overload;
		class procedure VarCreate(const ardb: array of TRecDBDef;
      PrAdd: TProcDopGetVarsAdd; PrIgnore: TProcDopGetVarIgnore); overload;
		class procedure VarFree(rdb: TRecDBDef);
		class function GFObjSearchNode(const TxtObj: string): string;
  end;

  TDWWin = class(TComponent)
  private
    aInt: array[TDWForm] of TInter;
    nfCur: TDWForm;
    FActive: boolean;
    procedure SetActive(Value: boolean);
		procedure SaveState;
    function HelpProc: variant;
		function IntEval(Sender: TObject; nf: TDWForm; const p3,p4,p5,Default: variant): variant; overload;
		function IntEval(var v: variant; Sender: TObject; nf: TDWForm; const p3,p4,p5,Default: variant): variant; overload;
    procedure IntGetAlgProc(Sender: TObject; var Txt: string);
    class procedure VarPartGetClick(Sender: TObject);
  public
		dw: TDataWin;
		de: TDefEdit;
    Params: TArrVar;
    UserData: pointer;
    lScroll: boolean;
    OnFrmShow,OnFrmHide,OnFldEnter,OnFldExit,OnPnlAfterEscape: TNotifyEvent;
    OnFldCheck,OnPnlValid,OnPnlAskCancel,OnPnlUpdateRecDB: TProcValid;
    OnFldChange: TFEChangeEvent;
    OnPnlCngKey: TPECngKeyEvent;
    OnPnlEscape: TCloseEvent;
    PrRedefParam: procedure(Sender: TObject; var av: TArrVar) of object;
    aRecEd: TArrRecDBDef;
    constructor Create(AOwner: TComponent = nil); override; 
    class function CreateOne(var Sender: TDWWin; AOwner: TComponent = nil): TDWWin;
    destructor Destroy; override;
    function Execute(const Value,NameWnd: string;
      const aRec: array of TRecDBDef; const NameScr: string; const aNoSeek: array of longint;
      const Capt: TCaption = ''; CanShow: TDECanShow = desAlways; lLog: boolean = true): TDEExitResult;
		procedure FldOnPanel(const Value: variant; const NameWnd,NameScr: string;
      Sender: TRbPanel; lBound: boolean = false);
		procedure FrmShow(Sender: TObject);
		procedure FrmHide(Sender: TObject);
    function PnlValid(Sender: TObject): Boolean;
		procedure PnlEscape(Sender: TObject; var Action: TCloseAction);
		procedure PnlAfterEscape(Sender: TObject);
		function PnlAskCancel(Sender: TObject): Boolean;
    procedure FldEnter(Sender: TObject);
    procedure FldExit(Sender: TObject);
    procedure FldChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    function FldCheck(Sender: TObject): Boolean;
    property Active: boolean read FActive write SetActive;
  end;

  TVarSelGet = class(TComboGet)
  protected
  	Parts: string;
    function Check(tf: TFldEdit): boolean; override;
    function AssignObj(tf: TFldEdit): boolean; override;
    procedure StdListDown(tf: TFldEdit; const RectList: TRect; PozList: TPozList); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

  TVarChkGetPrm = record
    Capt,Parts: string;
    lOrd: boolean;
  end;

  TVarChkGetClickRedefType = (vctBeg,vctAdd,vctEnd);
  TVarChkGetClickRedefEvent = procedure(Sender: TObject; tp: TVarChkGetClickRedefType;
    const aPart: TArrStr; ps: PString; pAdd: PBoolean; var av: TArrVar) of object;

  TVarChkGet = class(TButGet)
  private
    FOnClickRedef: TVarChkGetClickRedefEvent;
    tfOrd: TFldEdit;
    curInd,oldInd: longint;
		procedure ProcKey(key: longint; tw: TWinControl);
		procedure OrdProcKey(key: longint; tw: TWinControl);
    procedure OrdMove(ls: TFindListBox; oi,ni: longint);
    procedure OrdMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
    procedure OrdMouseMove(Sender: TObject; Shift: TShiftState; X,Y: longint);
    procedure OrdMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
  protected
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    class procedure FMaskView(var Mask: string); override;
    procedure DoPaint(tf: TFldEdit; const ARect: TRect; const Text: string); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
  public
    constructor Create(AOwner: TComponent); override;
		function Click(tf: TFldEdit; lEval: boolean): string; override;
    class function MaskTextReadOnly: boolean; override;
    class function Mask2Prm(const Mask: string): TVarChkGetPrm;
    class function Prm2Mask(const Capt,Parts: string; lOrd: boolean): string;
    property OnClickRedef: TVarChkGetClickRedefEvent read FOnClickRedef write FOnClickRedef;
  published
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  	procedure LogCompare(tf: TFldEdit; var Prm: TLogTrnsValPrm); override;
  end;

	TDWFldSeekProc = procedure(rdb: TRecDBDef; var a: TDWFldArrSeek; prAdd: TDWFldProcAdd) of object;
	TDWFldBrowlProc = procedure(rdb: TRecDBDef; const rv: TDWVidRec; var result: boolean) of object;

  TFldFillOptions = set of (fldfNoSeekPrimGet,fldfRDBSeek,fldfWithoutRelation,{fldfNilNotSupport,}fldfArray);
  TFldBrCreateOptions = set of (fldcRDBSeek,fldcNoAddCList,fldcNoInverted);
  TFldBrCalcOpt = set of (fldbrBoolRus,fldbrWithNoVisible);

  TFldList = class(TStringList)
  private
    aFld: array of TFldInf;
    nFld: longint;
    function StrBrInRange(var i: longint): boolean;
  public
    aField: TArrField;
    constructor Create;
    procedure Fill(DWFldSeekProc: TDWFldSeekProc = nil;
      Options: TFldFillOptions = []; rdbDef: TRecDBDef = nil);
    function GetInf(i: longint): PFldInf;
    class procedure BrDop(q: TMulQuery; const ardb: array of TRecDBDef; var adop: TFldArrDop;
      pNoRead: PArrInt = nil);
    procedure BrCreate(const ardb: array of TRecDBDef;
      q: TMulQuery; var adop: TFldArrDop; Opt: TFldBrCreateOptions = []; Proc: TDWFldBrowlProc = nil); overload;
    procedure BrCreate(q: TMulQuery; var adop: TFldArrDop; Opt: TFldBrCreateOptions = []); overload;
    function BrCreate(i: longint; q: TMulQuery): TField; overload;
    procedure BrCreate(q: TMulQuery); overload;
    procedure BrCreate(sb: TStringBrowl; FixFldCnt: longint = 0); overload;
    class procedure BrDopCalc(q: TMulQuery; const adop: TFldArrDop);
    function BrCalc(f: TField; const adop: TFldArrDop; i: longint; onlyResult: boolean=false): variant; overload;
    procedure BrCalc(const adop: TFldArrDop); overload;
    function BrCalc(ACol: longint; Opt: TFldBrCalcOpt = []): string; overload;
    class procedure BrFree(q: TMulQuery; var adop: TFldArrDop); overload;
    procedure BrFree; overload;
    procedure BrBool(sb: TStringBrowl; ACol,ARow: longint;
      const Rect: TRect; State: TGridDrawState; FixFldCnt: longint = 0);
  end;

const
	aDWFormSay: TDWFormStr =
  	('Перед просмотром окна','После просмотра окна','Перед входом на поле',
    'После выхода с поля','Изменение значения','Проверка значения',
    'Проверка всех значений','Отказ от сохранения','Отказ от сохранения после восстановления значений',
    'Запрос на сохранение','Настройка редактируемых полей','Заполнение страницы помощи');

var
  DWPrm: TDWPrm;
  CurDWFldRdb: TRecDBDef;
  sDWFldDef: string;
  LsDWWin: TList;
  DWFldBrowlProc: TDWFldBrowlProc;
  DWDatParamProc: procedure(const nmv: string; var r: TDWVidRec);

function c_dwparam(var av: array of variant): variant;
function c_gfobj(var av: array of variant): variant;
procedure DWGFFont(Sender: TObject; nFont: byte = 0);
function DWCurDefEdit: TDefEdit; overload;
function DWCurDefEdit(var de: TDefEdit): boolean; overload;
function IfThenDWFldBrowl(AValue: boolean; ATrue: TDWFldBrowlProc; AFalse: TDWFldBrowlProc = nil): TDWFldBrowlProc; overload;

implementation

{$R *.DFM}

uses SysUtils,Math,Variants,StrUtils,Graphics,
  My_pr,BufFile,ChkGets,FFind,FSrchTre,FDWPage,GenForm,RbPage,Shifr,
    FIntTree,FrmWnd,BtTxtGet;

var dwSet: TDataWin;
  LsFld: TFldList;
  piFld: PLongint;
  GF: TGenForm;
  FldChildCreated: boolean;
  FDWCurDefEdit: TDefEdit;
  FVarPartGet: TButTextGet;
  aDataWin: TArrDataWin;
  nDataWin: longint = -1;
  aState: array of record
    de: TDefEdit;
    rdb: TRecDBDef;
  end;
  nState: longint;
  LsQry,LsDop: TList;
	aEditToDe: array[TEditCharCase] of TDECharCase;

const
  WinLastVers = 9;

  GFPropCanSet = [vgfoAlignment,vgfoColor];

  aAlgm: array[TAlignment] of byte = (0,2,1);

	aDWSearchSay: array[TDWSearchType] of string = ('Имена полей','Наименования полей',
    'Параметры ввода полей','Заголовок','Формулы','Описание формы');

type
  TCFldList =
    (pfValue 	// ДАН_ЗНАЧЕНИЕ
    ,pfParam 	// ДАН_ПАРАМ
    ,pfPrim  	// ДАН_ПРИМЕЧ
    ,pfIs    	// ДАН_ЕСТЬ
    ,pfLabel 	// ДАН_ПОДСКАЗКА
    ,pfValStr	// ДАН_ЗНАЧСТР
    ,pfAligm 	// ДАН_РАЗМЕСТ
    ,pfSumm  	// ДАН_СУММ
    ,pfVName 	// ДАН_НАИМВВОД
    );

  TNone = class
  private
    class procedure qBeforeOpen(DataSet: TDataSet);
    class procedure PrimDWFldSeek(rdb: TRecDBDef; var a: TDWFldArrSeek; prAdd: TDWFldProcAdd);
  end;

  TVarChkLogCompare = class(TStrListLogCompare)
  public
    class function ListCreate(pv: pointer; const Value: string; lNew: boolean): pointer; override;
    class procedure GetItem(var Prm: TLogTrnsValPrm; pv,lso,lsn: pointer; no,nn: longint; tp: TLogCompareItemList); override;
  end;

function DWCurDefEdit: TDefEdit;
begin
	AddStack('FDWPrm.DWCurDefEdit');
	if Assigned(LsDWWin) then result:=TDWWin(LsDWWin[LsDWWin.Count-1]).de else result:=nil;
  DelStack;
end;

function DWCurDefEdit(var de: TDefEdit): boolean;
begin
  de:=DWCurDefEdit; result:=Assigned(de);
end;

function IfThenDWFldBrowl(AValue: boolean; ATrue: TDWFldBrowlProc; AFalse: TDWFldBrowlProc = nil): TDWFldBrowlProc;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function NameGet(var g: TCustomGet; const FldInf: TFldInf): boolean; overload;
begin
  with FldInf do result:=NameGet(g,Vid,VName);
end;

function tfSeek(const nf: variant; var tf: TFldEdit; nbeg: Plongint = nil): boolean;
var i,nb: longint;
  pe: TPanelEdit;
  isnbeg: boolean;
begin
  AddStack('FDWPrm.tfSeek');
  i:=MyVarType(nf); tf:=nil; result:=false;
  if (i<>V_INT) and (i<>V_STRING) then raise EInterAnyError.Create(
    'Параметр 1 должен быть числом или строкой');
	if Assigned(FDWCurDefEdit) then with FDWCurDefEdit do begin
    if i=V_INT then begin
      i:=nf;
      if InRange(i,1,FldCount) then tf:=FldEdit[i-1];
    end
    else if PanelEdit(pe) then begin
      isnbeg:=Assigned(nbeg);
      if not isnbeg then begin
        nb:=0; nbeg:=@nb;
      end;
      for i:=nbeg^ to pe.FieldCount-1 do begin
        tf:=pe.Fields[i];
        if tf.DWVarName=TrimUpper(nf) then begin
          if isnbeg then nbeg^:=i+1;
          break;
        end
        else tf:=nil;
      end;
    end;
    result:=Assigned(tf);
  end;
  DelStack;
end;

function GFOpen(const DcmDef: string): boolean;
begin
  AddStack('FDWPrm.GFOpen');
  result := DcmDef<>'';
  if result then begin
    if not Assigned(GF) then begin
      GF:=TGenForm.Create(Application.MainForm); GF.Parent:=Application.MainForm;
    end;
    GF.OpenDcmStr(DcmDef);
  end;
  DelStack;
end;

procedure VarPartGetMaskTrans(const av: variant; var result: variant);
const Prm: TButTextGetPrm = (Capt:'Допустимые разделы'; NoLimSize:true);
begin
  AddStack('FDWPrm.VarPartGetMaskTrans');
  if MyVarType(av)<>varArray then begin
    if not Assigned(FVarPartGet) then begin
      FVarPartGet:=TButTextGet.Create(Application.MainForm);
      with FVarPartGet do begin
        OnClick:=TDWWin.VarPartGetClick; VName:='VarPart';
      end;
    end;
    result[2]:=VarArrayOf([mpCustom,'',result[2][2],LongInt(FVarPartGet),TButTextGet.PrmToMask(Prm),true,true]);
  end;
  DelStack;
end;

function DataWinCreate: TObject;
begin
  AddStack('FDWPrm.DataWinCreate');
  result:=TDataWin.aGet;
  DelStack;
end;

procedure DataWinFree;
begin
  Dec(nDataWin);
end;

function FldBrCalc(const cv: variant; p: PFldInf; BoolRus: boolean): string;
var v: variant;
  g: TCustomGet;
begin
  AddStack('FDWPrm.FldBrCalc');
  v:=cv;
  if NameGet(g,p^) then g.DWFldValue(p.rdb,p.DWFldInfo.r.Name,v)
  else case p.DWFldInfo.r.AType of
    dwtFloat: Spacestr0Self(v,p.DWFldInfo.r.Len,p.DWFldInfo.r.Dec,false);
    dwtDate: dtocSelf(v);
  end;
  if MyVarType(v)=varBoolean then
    if BoolRus then result:=bRus2Str(v) else result:=Bool2Str(v)
  else result:=v;
  DelStack;
end;

// Устанавливает параметры вводимого поля
function c_dwparam; procedure Dummy; // Return value of function might be undefined
var res: variant;
  n1: byte;
  function tfSet(const ov: variant; n: longint): variant;
  begin
    AddStack('FDWPrm.c_dwparam.tfSet');
    res[n-n1]:=ov; result:=IsNilc(av[n],ov);
    DelStack;
  end;
var go: TGetOptions;
  procedure SetOpt(n: longint; opt: TGetOption; inv: boolean = false);
  var v: boolean;
  begin
    AddStack('FDWPrm.c_dwparam.SetOpt');
    v := opt in go;
    if inv then NotD(v);
    tfSet(v,n);
    if not IsNil(av[n]) then begin
      v:=av[n];
      if inv then NotD(v);
      SetSet(go,opt,v);
    end;
    DelStack;
  end;
var og,g: TCustomGet;
  lReAssign: boolean;
  function gSeek(const v,vn,ms: string): boolean;
  begin
    AddStack('FDWPrm.c_dwparam.gSeek');
    if NameGet(og,v,vn) then begin
      if lReAssign then g:=og;
      ReAssignGet(og,ms); tfSet(og.RVid,3); tfSet(og.RVName,4);
    end;
    result:=Assigned(g);
    DelStack;
  end;
  procedure MaskArr(const nmr,nmf: string);
  var v: variant;
    r: TRecDBDef;
  begin
    AddStack('FDWPrm.c_dwparam.MaskArr');
    if MyVarType(av[5])=varArray then if PointerDef(pointer(g),og) then begin
      r:=TRecDBDef(RecName(nmr)).DWRdbSeek; v:=g.DoMaskTrans('',r,nmf);
      if MyVarType(v)=varArray then av[5]:=g.DoMaskTrans(VAddEnd(av[5],VarLength(v)),r,nmf);
    end;
    DelStack;
  end;
var a: TDEPrmStr;
  procedure SetInt(p: TDEPrmList; n: longint);
  begin
    AddStack('FDWPrm.c_dwparam.SetInt');
    a[p]:=IntToStr(tfSet(Int0(a[p]),n));
    DelStack;
  end;
  procedure SetBool(p: TDEPrmList; n: longint);
  begin
    AddStack('FDWPrm.c_dwparam.SetBool');
    a[p]:=Bool2Str(tfSet(StrToBoolean(a[p]),n));
    DelStack;
  end;
  procedure aSet(p: TDEPrmList; n: longint);
  begin
    AddStack('FDWPrm.c_dwparam.aSet');
    a[p]:=tfSet(a[p],n);
    DelStack;
  end;
var avf: TVarNmRec;
  r: TRecDBDef;
  function rSeek(const VarName: variant): boolean;
  begin
    AddStack('FDWPrm.c_dwparam.rSeek');
    if IsNil(VarName) then result:=false
    else begin
      avf:=VarNmToRec(VarName); result:=TRecDBDef.SeekDWPrefix(avf[1],r);
      if result then begin
        DWRdbSeek(r); result:=Assigned(r);
      end;
    end;
    DelStack;
  end;
var i: longint;
  ls: TStringList;
  function vnmSeek(const VarName: variant; nbeg: longint = 0): boolean;
  var fl: boolean;
    a1: TDEPrmStr;
  begin
    AddStack('FDWPrm.c_dwparam.vnmSeek');
    fl := MyVarType(VarName)=V_INT;
    if fl then begin
      i:=av[1]-1; r:=nil;
    end
    else if rSeek(VarName) then begin
      i:=nbeg; avf[1]:=TrimUpper(r.NameRec); TrimUpperSelf(avf[2]);
      while i<ls.Count do begin
        a1:=DEGetArrParam(ls[i]);
        if (TrimUpper(a1[deNameRec])=avf[1]) and (TrimUpper(a1[deNameRecFld])=avf[2]) then begin
          a:=a1; break;
        end;
        Inc(i);
      end;
    end
    else i:=ls.Count;
    result:=InRange(i,0,ls.Count-1);
    if result and fl then begin
      a:=DEGetArrParam(ls[i]); RecName(a[deNameRec],TCustomRec(r),TRecDBDef);
    end;
    DelStack;
  end;
var lSeek: boolean;
  procedure SeekOther(const VarName: variant);
  var af: TDWFldArrSeek;
    dw: TDataWin;
    t: longint;
  begin
    AddStack('FDWPrm.c_dwparam.SeekOther');
    TRecDBDef(r).DWFldSeek(af); dw:=TDataWin.aGet;
    try
      for t:=low(af) to high(af) do with af[t] do if lWin then begin
        dw.LoadFromStr(defW); ls.Text:=dw.Fields;
        if vnmSeek(VarName) then begin
          gSeek(a[deVid],a[deVName],a[deMask]); MaskArr(a[deNameRec],a[deNameRecFld]);
          if MyVarType(av[5])=varString then a[deMask]:=av[5];
          if Assigned(og) then og.DePrmTrans(a);
          lSeek:=true; break;
        end;
      end;
    finally
      DataWinFree;
    end;
    DelStack;
  end;
var oi,t,nbeg: longint;
  sv,svn,otxt: string;
  apg: array[1..4] of string;
  pe: TPanelEdit;
  rv: TDWVidRec;
  dwpr: TDWParamFunc;
  tw: TWinControl;
  tf: TFldEdit;
  pg: TRbPage;
  pn: TRbPanel;
  oavf: TVarNmRec;
  ordb: TRecDBDef;
  p: PRDBArrDef;
  ad: TArrStr;
  lAll,fl: boolean;
begin
  dwpr:=av[0];
  AddStack('FDWPrm.c_dwparam: '+Int2Str(dwpr));
  if dwpr=dwprName then res:='';
  t:=MyVarType(av[1]); lReAssign:=false;
  // Параметры полей
  if ArrIntMatch(t,[V_INT,V_STRING,varArray]) or (dwpr=dwprName) then begin
    n1:=1; g:=nil;
    if dwpr in [dwprPrm,dwprOther] then begin
      i:=MyVarType(av[3]);
      if i<>V_NULL then
        if i=V_BOOL then lReAssign:=true
        else if Assigned(LsCustomGet) then begin
          sv:=TrimUpper(av[3]);
          if IsNil(av[4]) then svn:='' else svn:=TrimUpper(av[4]);
          for i:=0 to LsCustomGet.Count-1 do begin
            og:=PointerObj(LsCustomGet,i);
            if TrimUpper(og.RVid)=sv then if TrimUpper(og.RVName)=svn then begin
              g:=og; break;
            end;
          end;
        end;
      res:=VarArrayCreate([1,18],varVariant);
      if MyVarType(av[2])=varArray then begin
        sv:='';
        for i:=VarArrayLowBound(av[2],1) to VarArrayHighBound(av[2],1) do IncD(sv,UnDelim+av[2][i]);
        av[2]:=Copy(sv,lUnDelim1,MaxInt);
      end;
    end;
    // до ввода
    if Assigned(dwSet) or (dwpr=dwprOther) then begin
      ls:=TStringList.Create;
      try
        lSeek := dwpr<>dwprOther;
        if lSeek then ls.Text:=dwSet.Fields
        else if rSeek(av[1]) then SeekOther(av[1]);
        if lSeek then begin
          lAll:=false;
          if (dwpr=dwprPrm) and (t=varArray) then begin
            t:=VarArrayHighBound(av[1],1); sv:='';
            if t>=3 then
              if vnmSeek(av[1][3]) then sv:=a[deNameRec]+'.'+a[deNameRecFld];
            if t<2 then lSeek:=false else lSeek:=vnmSeek(av[1][2]);
            if not lSeek then i:=ls.Count;
            lSeek:=rSeek(av[1][1]);
            if lSeek then begin
              a:=DEGetArrParam(sDWFldDef);
              ordb:=r; oavf:=avf; otxt:=ls.Text; oi:=i; lSeek:=false; SeekOther(av[1][1]);
              r:=ordb; avf:=oavf; ls.Text:=otxt; i:=oi;
              if lSeek then begin
                a[deTag]:=''; a[deNewPage]:=''; a[deRelation]:='';
              end
              else begin
                lSeek:=true;
                with r do for t:=0 to FldDef.Count-1 do begin
                  rv:=DWSToRec(t);
                  if TrimUpper(rv.Name)=avf[2] then begin
                    TDataWin.FldDefault(rv,a); break;
                  end;
                end;
              end;
              a[deNameRec]:=r.NameRec; a[deNameRecFld]:=avf[2]; a[deRelation]:=sv;
              a[deAddDyn]:=bTrue; ls.Insert(i,DESetArrParam(a));
            end;
          end
          else if dwpr<>dwprOther then begin
            lAll:=IsNilc(av[20],false); lSeek:=vnmSeek(av[1]);
          end;
          while lSeek do begin
            if dwpr=dwprName then begin
              if Assigned(r) then res:=r.DWVarName(a[deNameRecFld]);
              if rSeek(av[2]) then begin
                a[deNameRec]:=r.NameRec; a[deNameRecFld]:=avf[2];
                ls[i]:=DESetArrParam(a); dwSet.Fields:=ls.Text;
              end;
            end
            else begin
              aSet(deCaption,2);
              if gSeek(a[deVid],a[deVName],a[deMask]) then g.AssignGet(a);
              MaskArr(a[deNameRec],a[deNameRecFld]); aSet(deMask,5);
              SetInt(deMaxLen,6); SetInt(deCharCase,7); SetBool(deAutoSel,8);
              SetBool(dePassword,9); SetBool(deNoReadOnly,10); SetBool(deReadOnlyNoVsbl,11);
              SetBool(deTag,12); aSet(deSayHint,13); aSet(deGetHint,14);
              SetInt(deWidth,15); SetInt(deHeight,16);
              SetBool(deNoVisible,17); SetBool(deSayRight,18); SetBool(deTrimLeft,19);
              if dwpr=dwprPrm then begin
                ls[i]:=DESetArrParam(a); dwSet.Fields:=ls.Text;
              end;
            end;
            if lAll then lSeek:=vnmSeek(av[1],i+1) else lSeek:=false;
          end;
        end;
      finally
        ls.Free;
      end;
    end
    // видимость столбцов массивов
    else if t=varArray then begin
      if not IsNil(av[17]) then if tfSeek(av[1][1],tf) then if rSeek(av[1][1]) then begin
        with r do for t:=0 to FldDef.Count-1 do begin
          rv:=DWSToRec(t);
          if TrimUpper(rv.Name)=avf[2] then if rSeek(av[1][2]) then begin
            if TRecDBDef.PGetArrDef(rv.AValue,p) then begin
              oi:=LsArrDynamic(p.Dat,ad,CRLF);
              for i:=0 to oi-1 do begin
                rv:=My_Pr.DWSToRec(ad[i]);
                if TrimUpper(rv.Name)=avf[2] then begin
                  lSeek:=av[17]; n1:=LsArrFill(rv.DopPrm,apg,',');
                  if StrToBoolean(apg[1])<>lSeek then begin
                    otxt:=tf.VarValue;
                    apg[1]:=bStr[lSeek]; rv.DopPrm:=ArrayAsList(apg,',',n1);
                    ad[i]:=DWRecToS(rv); p.Dat:=ArrayAsList(ad,CRLF,oi);
                    tf.CreateObj; SetSchemForm(tf); MainRebuild(tf); tf.VarValue:=otxt;
                  end;
                  break;
                end;
              end;
            end;
            break;
          end;
        end;
      end;
    end
    // во время ввода
    else begin
      nbeg:=0; lSeek:=tfSeek(av[1],tf,@nbeg);
      if dwpr=dwprName then begin
        if lSeek then
          if Assigned(tf.PNameRec) then begin
            if IsClass(tf.PNameRec,TRecDBDef,pointer(r)) then res:=r.DWVarName(tf.NameRecFld);
            if rSeek(av[2]) then
              if not((TrimUpper(tf.NameRec)=TrimUpper(r.NameRec))
              and (TrimUpper(tf.NameRecFld)=TrimUpper(avf[2]))) then begin
                tf.NameRec:=r.NameRec; tf.NameRecFld:=avf[2]; tf.Read([ferdSvOld,ferdFromShow]);
              end;
          end;
      end
      else if not tfSet(not lSeek,17) then begin
        lAll:=IsNilc(av[20],false);
        while lSeek do begin
          fl:=Assigned(tf.PaintSay); tf.SayCaption:=tfSet(tf.SayCaption,2);
          if Assigned(tf.PaintSay)<>fl then begin
            if ParentClass(tw,tf.Parent,TGenForm) then with TGFFldSayList.Create(pointer(tw)) do
              try
                AddFld(tf);
              finally
                Free;
              end;
          end;
          if gSeek(tf.Vid,tf.VName,tf.Mask) then begin
            tf.AssignGet(g,lReAssign); FDWCurDefEdit.FillFldList;
          end;
          MaskArr(tf.NameRec,tf.NameRecFld); tf.Mask:=tfSet(tf.Mask,5);
          tf.MaxLength:=tfSet(tf.MaxLength,6);
          tf.CharCase:=aDeToEdit[TDECharCase(tfSet(aEditToDe[tf.CharCase],7))];
          if not IsNil(av[17]) then IsNil(av[11],av[17]);
          go:=tf.Options; SetOpt(8,ogAutoSelect); SetOpt(9,ogPassword);
          SetOpt(10,ogReadOnly,true); SetOpt(11,ogReadOnlyNoVsbl); SetOpt(19,ogTrimLeft);
          tf.Options:=go;
          tf.Tag:=IfThen(tfSet(boolean(tf.Tag),12)<>0,1);
          if Assigned(tf.PaintSay) then sv:=tf.PaintSay.Hint else sv:='';
          sv:=tfSet(sv,13);
          if Assigned(tf.PaintSay) then with tf.PaintSay do begin
            Hint:=sv; ShowHint := not empty(Hint);
          end;
          tf.Hint:=tfSet(tf.Hint,14);
          tf.CharWidth:=tfSet(tf.CharWidth,15); tf.CharHeight:=tfSet(tf.CharHeight,16);
          tf.SayRight:=tfSet(tf.SayRight,18);
          if lAll then lSeek:=tfSeek(av[1],tf,@nbeg) else break;
        end;
      end;
    end;
  end
  // Общие параметры
  else begin
    n1:=2; res:=VarArrayCreate([1,3],varVariant);
    // для всех страниц
    if IsNil(av[2],0)=0 then begin
      if Assigned(dwSet) then begin
        dwSet.Zgl:=tfSet(dwSet.Zgl,3); dwSet.SortMode:=tfSet(dwSet.SortMode,4);
      end
      else if Assigned(FDWCurDefEdit) then
        if FDWCurDefEdit.PanelEdit(pe) then begin
          with GetParentForm(pe) do Caption:=tfSet(Caption,3);
          pe.SortMode:=tfSet(pe.SortMode,4);
        end
    end
    // для одной страницы
    else begin
      i:=av[2]-1; ls:=nil;
      if Assigned(dwSet) then ls:=TStringList.Create
      else if Assigned(FDWCurDefEdit) then ls:=pointer(FDWCurDefEdit.Pages);
      try
        if Assigned(ls) then begin
          if Assigned(dwSet) then ls.Text:=dwSet.Pages;
          if InRange(i,0,ls.Count-1) then begin
            LsArrFill(ls[i],apg,UnDelim);
            if apg[2]=bTrue then apg[2]:='2';
            apg[1]:=tfSet(apg[1],3); apg[2]:=IntToStr(tfSet(Int0(apg[2])-1,4)+1);
            apg[4]:=Bool2Str(tfSet(StrToBoolean(apg[4]),5));
            if Assigned(dwSet) then begin
              ls[i]:=ArrayAsList(apg,UnDelim); dwSet.Pages:=ls.Text;
            end
            else if Assigned(FDWCurDefEdit) then with FDWCurDefEdit do
              if Assigned(Panel) then
                if ControlsClass(Panel,TRbPage,pointer(pg)) then with pg,Pages[i] do begin
                  Caption:=tfSet(Caption,3);
                  if IsClass(Controls[0],TRbPanel,pointer(pn)) then pn.SortMode:=tfSet(pn.SortMode,4);
                  SetTabVisible(Pages[i],not tfSet(not TabVisible,5));
                end;
          end;
        end;
      finally
        if Assigned(dwSet) then ls.Free;
      end;
    end;
  end;
  result:=res;
  DelStack;
end; begin Dummy; end;

function c_rebuild(var av: array of variant): variant;
var pe: TPanelEdit;
begin
	AddStack('FDWPrm.c_rebuild');
  result:=null;
	if Assigned(FDWCurDefEdit) then
    if FDWCurDefEdit.PanelEdit(pe) then begin
    	MainRebuild(pe); pe.FillFldList;
    end;
  DelStack;
end;

function c_list(var av: array of variant): variant;
var i,j,npg: longint;
  ap: TDEPrmStr;
  r: TCustomRec;
  lpg,lFirst: boolean;
  a: TArrStr;
begin
	AddStack('FDWPrm.c_list');
  result:=false; i:=0;
  if Assigned(dwSet) then i:=LsArrDynamic(dwSet.Fields,a,CRLF)
  else if Assigned(FDWCurDefEdit) then begin
    CopyFrom(a,FDWCurDefEdit.Fields); i:=Length(a);
  end;
  if i>0 then begin
    npg:=IsNilc(av[1],0); lpg := npg>0; lFirst:=true; VarArrLenInit(result,j,i);
    for i:=0 to i-1 do begin
      ap:=DEGetArrParam(a[i]);
      if not StrToBoolean(ap[deNoVisible]) then
        if RecName(ap[deNameRec],r,TRecDBDef) then begin
          if lpg and (StrToBoolean(ap[deNewPage]) or lFirst) then begin
            if npg=0 then break;
            Dec(npg);
          end;
          lFirst:=false;
          if npg>0 then continue;
          Inc(j); result[j]:=TRecDBDef(r).DWVarName(ap[deNameRecFld]);
        end;
    end;
    VarArrLenSet(result,j);
  end;
  DelStack;
end;

function c_close(var av: array of variant): variant;
begin
	AddStack('FDWPrm.c_close');
  result:=null;
	if Assigned(FDWCurDefEdit)
  then TFormWnd(GetParentForm(FDWCurDefEdit.Panel)).SetModalResult(IfThen(empty(av[1]),mrCancel,mrOk));
  DelStack;
end;

function c_gfobj;
var j: longint;
  avr: array of record
    ir: longint;
    vo,vn: variant;
    lSet: boolean;
  end;
  v: variant;
  procedure Check(const nmv: string);
  var i: TGFPropObjList;
    tp: TGFPropLineType;
    pl: TGFPropLineList;
  label lend;
  begin
  	AddStack('FDWPrm.c_gfobj.Check');
    with avr[j] do begin
      lSet := not IsNil(v);
      if lSet then begin
        for i:=low(aGFPropObj) to high(aGFPropObj) do if i in GFPropCanSet then
          if nmv=aGFPropObj[i].v then goto lend;
        for tp:=low(aGFPropLineType) to high(aGFPropLineType) do
          for pl:=low(aGFPropLine) to high(aGFPropLine) do
            if nmv=aGFPropLineType[tp,1]+aGFPropLine[pl] then goto lend;
        raise EInterAnyError.Create('Недопустима установка значения свойства объекта "'+nmv+'"');
      end;
  lend:
      TInter.SeekVar(nmv,@ir); vo:=null; vn:=v; Inc(j);
    end;
    DelStack;
  end;
var PrComp: TProcStrComp;
  fl: boolean;
  procedure ObjSeek(pv: PGFObj);
  var j: longint;
  begin
  	AddStack('FDWPrm.c_gfobj.ObjSeek');
    CurGFObj:=pv;
    if PrComp(CurGFObj.Ident,av[1]) then
      for j:=low(avr) to high(avr) do with avr[j] do begin
        vo:=TInter.VarProc(ir,vn,lSet);
        if lSet then begin
          fl:=true; result:=false;
        end;
      end;
    DelStack;
  end;
var t,i,k,l: longint;
  oCurGFObj: PGFObj;
  PrProp: function(var v: variant; var GF: TGenForm): boolean;
  GF: TGenForm;
begin
	AddStack('FDWPrm.c_gfobj');
  result:=null; t:=MyVarType(av[2]); j:=0;
  if t=V_STRING then begin
    SetLength(avr,1); v:=av[3]; Check(av[2]);
  end
  else if t=varArray then begin
    i:=VarArrayLowBound(av[2],1); k:=VarArrayHighBound(av[2],1); SetLength(avr,k-i+1);
    if MyVarType(av[3])=varArray then l:=VarArrayHighBound(av[3],1) else l:=i-1;
    while i<=k do begin
      if i>l then v:=null else v:=av[3][i];
      Check(av[2][i]); Inc(i);
    end;
  end
  else result:=false;
  if MyVarType(result)<>V_BOOL then begin
    PrComp:=ProcStrComp(av[1]); oCurGFObj:=CurGFObj; PrProp:=PointerVar(av[0]); v:=null;
    while PrProp(v,GF) do begin
      for i:=0 to GF.PageCount-1 do with GF.Pages(i)^ do
        for k:=low(av) to high(av) do ObjSeek(@av[k]);
      fl:=false;
      for k:=0 to GF.ObjectCount-1 do ObjSeek(GF.PObjects[k]);
      if fl then GF.PaintAll;
    end;
    CurGFObj:=oCurGFObj;
    if t=varArray then begin
      result:=VarArrayCreate([1,Length(avr)],varVariant); i:=0;
      for j:=low(avr) to high(avr) do begin
        Inc(i); result[i]:=avr[j].vo;
      end;
    end
    else result:=avr[0].vo;
  end;
  DelStack;
end;

function c_gffont(var av: array of variant): variant;
begin
  AddStack('FDWPrm.c_gffont');
  result:=null;
  if Assigned(FDWCurDefEdit) then DWGFFont(GetParentForm(FDWCurDefEdit.Panel),IsNilc(av[1],0));
  DelStack;
end;

procedure DWGFFont;
var i: longint;
  gf: TGenForm;
begin
  AddStack('FDWPrm.DWGFFont');
  with TComponent(Sender) do for i:=0 to ComponentCount-1 do
    if IsClass(Components[i],TGenForm,pointer(gf)) then Include(gf.stFontSay,nFont);
  DelStack;
end;

function GFObjPropProc(var v: variant; var GF: TGenForm): boolean;
var f: TCustomForm;
begin
  AddStack('FDWPrm.GFObjPropProc');
  result := not IsNil(v);
  if not result then
    if Assigned(FDWCurDefEdit) then begin
      v:=VarArrayOf([longint(GetParentForm(FDWCurDefEdit.Panel)),0]); result:=true;
    end;
  if result then begin
    f:=PointerVar(v[0]); GF:=nil;
    while not Assigned(GF) and (v[1]<f.ComponentCount) do begin
      IsClass(f.Components[longint(v[1])],TGenForm,pointer(GF),false); IncD(v,1,variant(1));
    end;
    if v[1]=f.ComponentCount then result:=false;
  end;
  DelStack;
end;

function c_ChkEnabled(var av: array of variant): variant;
var tf: TFldEdit;
begin
	AddStack('FDWPrm.c_ChkEnabled');
  if tfSeek(av[1],tf) then begin
    result:=TCheckSpace.GetButEnabled(tf,av[2]);
    if MyVarType(av[3])=V_BOOL then TCheckSpace.SetButEnabled(tf,av[2],av[3]);
  end
  else result:=false;
  DelStack;
end;

function c_oldval(var av: array of variant): variant;
var tf: TFldEdit;
begin
	AddStack('FDWPrm.c_oldval');
  result:=null;
  if tfSeek(av[1],tf) then if Assigned(tf.PNameRecFld) then result:=tf.PNameRecFld.OldValue;
  DelStack;
end;

function c_help(var av: array of variant): variant;
var tf: TFldEdit;
begin
	AddStack('FDWPrm.c_help');
  result:=null;
  if tfSeek(av[1],tf) then tf.HelpContext:=av[2];
  DelStack;
end;

function c_fld(var av: array of variant): variant;
const
	avType     = 1;
	avCod      = 2;
	avLen      = 3;
	avDec      = 4;
	avValue    = 5;
	avDopPrm   = 6;
	avSvType   = 7;
	avDDatType = 8;
	avDDatD2   = 9;
	avPrim     = 10;
	avName     = 11;

	avCnt      = 11;

  aType: array[TDWFldType] of longint = (V_STRING,V_FLOAT,V_DATE,V_BOOL,V_NULL,V_NULL,V_STRING,V_NULL,V_NULL);

var r: TDWVidRec;
  tp: longint;
  function vParam(const name: string): variant;
  begin
  	AddStack('FDWPrm.c_fld.vParam');
    result:=ArrVarToVar([ReplVar(tp,MaxInt{т.к. его нет в aType и MyVarType},aType[r.AType]),
      r.dwCod,r.Len,r.Dec,r.AValue,r.DopPrm,r.SvType,r.DDatType,r.DDatD2,r.Prim,name]);
    DelStack;
  end;
var p: PFldInf;
	lsf: TFldList;
	ls: TStringList;
  fl,fl1: boolean;
  g: TCustomGet;
  v: varrec;
  i,j,l,ost: longint;
  rd: TRecDB;
  rdb: TRecDBDef;
  s: string;
  ta: TAlignment;
  pf: TCFldList;
  v1: variant;
begin
	ost:=AddStack('FDWPrm.c_fld');
  result:=null; pf:=av[0]; tp:=MaxInt; i:=MyVarType(av[1]);
  if (pf=pfParam) and (i<>V_STRING) then begin
    result:=false;
    if i=varArray then begin
      l:=0;
      for i:=VarArrayLowBound(av[1],1) to VarArrayHighBound(av[1],1) do begin
        if not TRecDBDef.SeekDWPrefix(StrDivDlm('_',av[1][i])[1],rdb)
        then raise EInterAnyError.Create('Не найдено описание вида данных "'+av[1][i]+'"');
        j:=rdb.FldDef.Count;
        if j>0 then begin
          if l=0 then result:=VarArrayCreate([1,j],varVariant) else VarArrayRedim(result,l+j);
          for j:=0 to j-1 do begin
            r:=rdb.DWSToRec(j);
            if r.Name<>'' then begin
              Inc(l); result[l]:=vParam(rdb.DWPrefix+'_'+r.Name);
            end;
          end;
        end;
      end;
      VarArrLenSet(result,l);
    end;
  end
  else begin
    if pf in [pfLabel,pfValStr,pfAligm,pfSumm,pfVName] then begin
      lsf:=TFldList.Create;
      try
        lsf.Text:=av[1]; lsf.Fill; fl := lsf.Count=0;
        if not fl then begin
          p:=lsf.GetInf(0);
          case pf of
            pfLabel: result:=p.DWFldInfo.DisplayLabel;
            pfValStr:
              if IsNil(av[2])
              then result:=lsf.BrCalc(0,[fldbrBoolRus])
              else result:=FldBrCalc(av[2],p,true);
            pfAligm: result:=aAlgm[p.DWFldInfo.Alignment];
            pfSumm: if NameGet(g,p^) then result:=g.DWFldCanSumm(p.rdb[lsf[0]])
              else result := p.DWFldInfo.r.AType=dwtFloat;
            pfVName: if NameGet(g,p^) then result:=g.VName else result:='';
          end;
        end;
      finally
        lsf.Free;
      end;
    end
    else fl:=true;
    if fl then begin
      if pf<>pfVName then begin
        fl:=false; fl1 := pf in [pfValStr,pfAligm,pfSumm];
        if not fl1 or IsNil(av[2]) then begin
          v:=TInter.SeekVar(av[1],@i);
          if v.name='' then fl:=true
          else if fl1 then av[2]:=TInter.VarProc(i,null,false);
        end;
        if not fl then case pf of
          pfValue: result:=TInter.VarProc(i,av[2],not IsNil(av[2]));
          pfParam: begin
            rd:=nil; fl1:=true;
            try
              if MyVarType(v.index)=varArray then begin
                v1:=v.index[VarArrayLowBound(v.index,1)];
                if MyVarType(v1)=varInteger then rd:=PointerVar(v1);
              end;
              if IsClass(rd,TRecDBDef,pointer(rdb)) then if AnsiStartsStr(rdb.DWPrefix+'_',av[1]) then begin
                ls:=TStringList.Create;
                try
                  ls.Text:=rdb.DWTrans;
                  try
                    i:=ls.IndexOfName(Copy(av[1],Length(rdb.DWPrefix)+2,MaxInt));
                    if i>=0 then begin
                      r:=DWSToRec(ls[i]); fl1:=false;
                    end;
                  except
                    on EVariantError do SetStack(ost);
                  end;
                finally
                  ls.Free;
                end;
              end;
            except
              SetStack(ost);
            end;
            if fl1 then begin
              v1:=TInter.VarProc(i,null,false); tp:=MyVarType(v1);
              r:=DWSToRec(''); r.AValue:=VarBlank(v1); r.SvType:=dwsFix; r.Prim:=v.hint;
              if Assigned(DWDatParamProc) then DWDatParamProc(av[1],r);
            end;
            result:=vParam(av[1]);
          end;
          pfPrim,pfLabel: result:=v.hint;
          pfValStr: begin
            fl1:=true; s:='';
            if Assigned(DWValStrTrans) then DWValStrTrans(av[2],s,fl1);
            if fl1 then case MyVarType(av[2]) of
              V_INT: s:=IntToStr(av[2]);
              V_FLOAT: s:=FloatToStr(av[2]);
              V_DATE: s:=dtoc(av[2]);
              V_BOOL: s:=Bool2Str(av[2]);
              V_STRING: s:=av[2];
            else s:='';
            end;
            result:=s;
          end;
          pfAligm: begin
            case MyVarType(av[2],true) of
              V_FLOAT: ta:=taRightJustify;
              V_DATE: ta:=taCenter;
            else ta:=taLeftJustify;
            end;
            result:=aAlgm[ta];
          end;
          pfSumm: result := MyVarType(av[2],true)=V_FLOAT;
        end;
      end;
      if pf=pfIs then result:=not fl
      else if fl then raise EInterAnyError.Create('Не найдено описание переменной "'+av[1]+'"');
    end;
  end;
  DelStack;
end;

// ДАН_ЗНАЧКОД
function c_cod(var av: array of variant): variant;
const afa: array[0..2] of string = (sFixMemo,sArray,sFixSel);
var rdb: TRecDBDef;
	i: longint;
  tp: byte;
begin
	AddStack('FDWPrm.c_cod');
  if not TRecDBDef.SeekDWPrefix(av[1],rdb) then raise EInterAnyError.Create(
    'Не найден вид данных с префиксом "'+av[1]+'"');
  DWRdbSeek(rdb); tp:=Bool2Int(av[4]);
  if tp=0 then i:=rdb.NumFromName(rdb.FixSt+av[2]) else i:=-1;
  if i<0 then i:=rdb.NumFromName(rdb.FixSt(afa[tp])+av[2]);
  if i<0 then result:=null
  else begin
  	result:=rdb.ValueNum[i];
	  if not IsNil(av[3])
    then rdb.ValueNum[i]:=av[3];
  end;
  DelStack;
end;

// ДАН_СПИСОК
function c_arr(var av: array of variant): variant;
var a: TArrVarRec;
  i,j,l: longint;
begin
  AddStack('FDWPrm.c_arr');
  result:=false; TInter.GetVar(a,'',[ivtVar]); l:=Length(a); j:=0;
  for i:=0 to l-1 do with a[i] do if AnsiStartsStr(av[1],name) then begin
    if MyVarType(result)=V_BOOL then result:=VarArrayCreate([1,l-i],varVariant);
    Inc(j); result[j]:=name;
  end;
  if j>0 then VarArrayRedim(result,j);
  DelStack;
end;

{ TDataWin }
const
  aFormOrd: array[TDWForm] of record
    n: TDWForm;
    v: byte;
  end =
  ((n:dwfShow)
  ,(n:dwfHide)
  ,(n:dwfEnter)
  ,(n:dwfExit)
  ,(n:dwfChange)
  ,(n:dwfCheck)
  ,(n:dwfValid)
  ,(n:dwfEscape)
  ,(n:dwfAskCancel  ; v:2)
  ,(n:dwfSetting    ; v:3)
  ,(n:dwfHelp       ; v:8)
  ,(n:dwfAfterEscape; v:9)
  );

class function TDataWin.CreateOne;
begin
  AddStack('TDataWin.CreateOne');
  if not Assigned(Sender) then Sender:=Create;
  result:=Sender;
  DelStack;
end;

procedure TDataWin.LoadFromStr;
  procedure Init;
  begin
  	AddStack('TDataWin.LoadFromStr.Init');
    Zgl:=''; SortMode:=smDefault; DcmBased:=false; DcmDef:=''; AskByCancel:=false; Fields:=''; Pages:='';
    InitArr(aForm);
    DelStack;
  end;
var i: TDWForm;
  ost: longint;
begin
	ost:=AddStack('TDataWin.LoadFromStr');
  Init;
  try
    with TStrBuf.CreateRead(s,WinLastVers,5) do try
      if Active then begin
        Zgl:=ReadStr;
        if Vers>=7 then begin
          DcmBased:=Read(stBoolean); DcmDef:=ReadStr;
        end;
        if not DcmBased then
          if Vers<6
          then SortMode:=iif(Read(stBoolean),smColumns,smDefault)
          else SortMode:=Read(stByte);
        if Vers>=2 then AskByCancel:=Read(stBoolean);
        for i:=low(aFormOrd) to high(aFormOrd) do with aFormOrd[i] do
          if Vers>=v then aForm[n]:=ReadStr;
        Fields:=TextCRLF(ReadStr);
        if Vers>=4 then Pages:=ReadStr;
        TextCRLFSelf(Pages);
      end;
    finally
      Free;
    end;
  except
    SetStack(ost); Init;
  end;
  DelStack;
end;

function TDataWin.SaveToStr;
var i: TDWForm;
begin
	AddStack('TDataWin.SaveToStr');
  with TStrBuf.CreateWrite(@result,WinLastVers) do
    try
      WriteStr(Zgl); Write(DcmBased,stBoolean); WriteStr(DcmDef);
      if not DcmBased then Write(SortMode,stByte);
      Write(AskByCancel,stBoolean);
      for i:=low(aFormOrd) to high(aFormOrd) do WriteStr(aForm[aFormOrd[i].n]);
      WriteStr(TextCRLF(Fields)); WriteStr(TextCRLF(Pages));
    finally
      Free;
    end;
  DelStack;
end;

function VarNamePref(const cPref,s: string; var a: TDEPrmStr): string;
begin
  AddStack('FDWPrm.VarNamePref');
  LsArrFill(s,a,UnDelim);
  if cPref='' then result:=TRecDBDef.DWVarName(a) else result:=cPref+'_'+a[deNameRecFld];
  DelStack;
end;

procedure TDataWin.ButGetPaint;
var s: string;
	i,l,t,b,lmax: longint;
	ap: TDEPrmStr;
  a1: array[1..2] of string;
	a: TArrStr;
  Canvas: TCanvas;
begin
  AddStack('TDataWin.ButGetPaint');
  Canvas:=TFldEdit(Sender).Canvas;
  with Canvas do begin
    FillRect(ARect); LoadFromStr(Value); l:=LsArrDynamic(Fields,a,CRLF)-1; lmax:=0; t:=ARect.Top;
    for i:=0 to l do begin
      s:=VarNamePref(cPref,a[i],ap); MaxSelf(lmax,Canvas,s);
      a[i]:=s+UnDelim+DelTrim(StrTran(ap[deCaption],sDEDlm,' '));
    end;
    Inc(lmax,TextWidth(' '));
    for i:=0 to l do begin
      LsArrFill(a[i],a1,UnDelim);
      b:=min(ARect.Bottom,t+max(TextHeight(a1[1]),TextHeight(a1[2])));
      TextRect(Rect(ARect.Left,t,ARect.Left+lmax,b),ARect.Left,t,a1[1]);
      TextRect(Rect(ARect.Left+lmax,t,ARect.Right,b),ARect.Left+lmax,t,a1[2]); t:=b;
      if t>ARect.Bottom then break;
    end;
  end;
  DelStack;
end;

function AddInfo(var aInfo: TDWSearchAInfo; var res: boolean; lIdent,usl: boolean;
	t: TDWSearchType; n: longint; npg: longint = 0; const txt: string = '';
  tgf: TGFSearchType = low(TGFSearchType)): boolean;
begin
  AddStack('FDWPrm.AddInfo');
  if usl then begin
    res:=true; SetLength(aInfo,Length(aInfo)+1);
    with aInfo[high(aInfo)] do begin
      TypeObj:=t; GFType:=tgf; NumObj:=n; NumPage:=npg; Text:=txt;
    end;
  end;
  result := res and lIdent;
  DelStack;
end;

function GFSeek(const DcmDef,SubStr: string; var aInfo: TDWSearchAInfo; var res: boolean;
	lIdent: boolean; npg: Word): boolean;
var aGF: TGFSearchAInfo;
  j: longint;
begin
  AddStack('FDWPrm.GFSeek');
  result:=false;
  if GFOpen(DcmDef) then begin
    GF.SearchIdent(SubStr,aGF,lIdent);
    for j:=low(aGF) to high(aGF) do
      if AddInfo(aInfo,res,lIdent,true,dwsGF,aGF[j].NumObj,npg,aGF[j].Text,aGF[j].TypeObj) then begin
        result:=true; break;
      end;
  end;
  DelStack;
end;

function TDataWin.SearchIdentPrm;
var SubStr: string;
	i: TDWForm;
label lend;
begin
  AddStack('TDataWin.SearchIdentPrm');
	result:=false; SubStr:=FindRegistrStr(sSubStr);
  if dwsClear in Opt then begin
	  LoadFromStr(s); aInfo:=nil;
  end;
  if StrCount(Pages)<2 then begin
    if not(dwsIdent in Opt) then
      if AddInfo(aInfo,result,dwsIdent in Opt,FindInStr(Zgl,SubStr),dwsZgl,0) then goto lend;
    if DcmBased then
      if GFSeek(DcmDef,SubStr,aInfo,result,dwsIdent in Opt,0) then goto lend;
  end;
  for i:=low(aForm) to high(aForm) do
    if AddInfo(aInfo,result,dwsIdent in Opt,FindInStr(aForm[i],SubStr),dwsForm,byte(i))
    then goto lend;
lend:
  DelStack;
end;

function TDataWin.IsAllFldInDcm;
var ls: TStringList;
  n1,n2: longint;
  aFld: TArrStr;
  procedure GFSeek(const DcmDef: string);
  var i,j: longint;
    v: TGFObj;
  label lend;
  begin
    AddStack('TDataWin.IsAllFldInDcm.GFSeek');
    if n2>n1 then
      if GFOpen(DcmDef) then begin
        ls.Sorted:=false; ls.BeginUpdate; ls.Clear;
        while n1<n2 do begin
          ls.Add(TRecDBDef.DWVarName(DEGetArrParam(aFld[n1]))); Inc(n1);
        end;
        ls.Sorted:=true; ls.EndUpdate;
        for i:=0 to GF.PageCount-1 do
          for j:=0 to GF.PgObjectCount(i)-1 do begin
            v:=GF.PgObjects(i,j)^;
            if v.TypeObj=toGet then
              if FindDel(ls,TrimRight(v.Text)) then
                if ls.Count=0 then goto lend;
          end;
        if ls.Count>0 then begin
          nmf:=ls[0]; result:=false;
        end;
      end;
  lend:
    DelStack;
  end;
var aPg: TArrStr;
  a: array[1..5] of string;
  i,lFld,lPg: longint;
	ap: TDEPrmStr;
begin
  AddStack('TDataWin.IsAllFldInDcm');
  result:=true; ls:=TStringList.Create;
  try
  	lFld:=LsArrDynamic(Fields,aFld,CRLF); lPg:=LsArrDynamic(Pages,aPg,CRLF); n1:=0;
    if lPg>1 then begin
      n2:=0;
      for i:=0 to lPg-1 do begin
        LsArrFill(aPg[i],a,UnDelim); Inc(n2);
        while n2<lFld do begin
          ap:=DEGetArrParam(aFld[n2]);
          if StrToBoolean(ap[deNewPage]) and not StrToBoolean(ap[deNoVisible]) then break else Inc(n2);
        end;
        if a[2]='0' then begin
          if Int0(a[5])>=1 then StrDeShifrSelf(a[3]);
          GFSeek(a[3]);
          if not result then break;
        end;
        n1:=n2;
      end;
    end
    else if DcmBased then begin
      n2:=lFld; GFSeek(DcmDef);
    end;
  finally
    ls.Free;
  end;
  DelStack;
end;

procedure TDataWin.Assign;
var i: TDWForm;
begin
  AddStack('TDataWin.Assign');
  Zgl:=Source.Zgl; SortMode:=Source.SortMode; DcmBased:=Source.DcmBased; DcmDef:=Source.DcmDef;
  AskByCancel:=Source.AskByCancel; Fields:=Source.Fields; Pages:=Source.Pages;
  for i:=low(aForm) to high(aForm) do aForm[i]:=Source.aForm[i];
  DelStack;
end;

function TDataWin.Equals;
var i: TDWForm;
begin
  AddStack('TDataWin.Equals');
  result := (Fields=dw.Fields) and (Pages=dw.Pages) and (Zgl=dw.Zgl) and (SortMode=dw.SortMode)
  	and (AskByCancel=dw.AskByCancel) and (DcmBased=dw.DcmBased) and (DcmDef=dw.DcmDef);
  if result then for i:=low(i) to high(i) do 
  	if aForm[i]<>dw.aForm[i] then begin
      result:=false; break;
    end;
  DelStack;
end;

function TDataWin.ReplaceNameRec;
var ls: TStringList;
begin
  AddStack('TDataWin.ReplaceNameRec');
  ls:=TStringList.Create;
  try
  	LoadFromStr(s); ls.Text:=Fields; My_pr.ReplaceNameRec(ls,OldNmRec,NewNmRec);
    Fields:=ls.Text; result:=SaveToStr;
  finally
    ls.Free;
  end;
  DelStack;
end;

procedure TDataWin.ReplaceNameRecSelf;
begin
  s:=ReplaceNameRec(s,OldNmRec,NewNmRec);
end;

procedure TDataWin.DoSetting;
var a: TArrStr;
  i: longint;
begin
  AddStack('TDataWin.DoSetting');
  LoadFromStr(s); dwSet:=Self;
  try
    i:=LsArrDynamic(Fields,a,CRLF); Fields:='';
    for i:=0 to i-1 do
      if not StrToBoolean(DEGetArrParam(a[i])[deAddDyn]) then IncD(Fields,a[i]+CRLF);
    EvalStrings(aForm[dwfSetting],'Формула настройки редактирумых полей');
    s:=SaveToStr;
  finally
    dwSet:=nil;
  end;
  DelStack;
end;

function TDataWin.SetSearchNode;
var tn,tn1,tn2: TTreeNode;
	tp: TDWSearchType;
  i,npg,tp1: longint;
  s,prim,hnt: string;
  a: PArrStr;
  ap: TDEPrmStr;
  r: TCustomRec;
begin
  AddStack('TDWFld.SetSearchNode');
  a:=nil; result:=nil;
  try
    with SearchTree,SearchTree.Tree do begin
      tp1:=-1; tn:=nil; tn2:=tnParent; npg:=0;
      for i:=low(aInfo) to high(aInfo) do begin
      	if aInfo[i].NumPage>npg then begin
        	npg:=aInfo[i].NumPage; tn2:=AddPrim(tnParent,StrNum('Страница ',npg)); tp1:=-1;
        end;
        tp:=aInfo[i].TypeObj;
        if tp1<>byte(tp) then begin
          tp1:=byte(tp); tn:=AddPrim(tn2,aDWSearchSay[tp]);
        end;
        if tp=dwsZgl then tn1:=tn
        else begin
          prim:=''; hnt:='';
          case tp of
          	dwsForm: s:=aDWFormSay[TDWForm(aInfo[i].NumObj)];
            dwsGF: begin
              hnt:=aInfo[i].Text; s:=TDWPrm.GFObjSearchNode(hnt);
            end;
          else
          	if not Assigned(a) then begin
              New(a); LsArrDynamic(Fields,a^,CRLF);
            end;
            ap:=DEGetArrParam(a^[aInfo[i].NumObj]);
            if RecName(ap[deNameRec],r,TRecDBDef) then s:=TRecDBDef(r).DWVarName(ap[deNameRecFld]) else s:='';
            prim:=aInfo[i].Text;
          end;
          tn1:=AddPrim(tn,s,prim,0,nil,hnt);
        end;
        PointerDef(pointer(result),tn1);
      end;
    end;
  finally
    DisposeNil(a);
  end;
  DelStack;
end;

class procedure TDataWin.FldDefault;
var i: longint;
  cg: TCustomGet;
begin
  AddStack('TDataWin.FldDefault');
  ap[deCaption]:=r.Prim; ap[deVid]:=''; TCustomGet.AssignGetClass(ap); ap[deWidth]:='';
  for i:=low(aDWFldDefaultProc) to high(aDWFldDefaultProc) do aDWFldDefaultProc[i](r,ap);
  if NameGet(cg,ap) then cg.FldDefault(r,ap);
  DelStack;
end;

class function TDataWin.aGet: TDataWin;
begin
  AddStack('TDataWin.aGet');
  Inc(nDataWin);
  if Length(aDataWin)=nDataWin then SetLength(aDataWin,nDataWin shl 1);
  result:=TDataWin.CreateOne(aDataWin[nDataWin]);
  DelStack;
end;

class function TDataWin.aGet(const s: string): TDataWin;
begin
  result:=aGet; result.LoadFromStr(s);
end;

class function TDataWin.aGet(var Sender: TDataWin): TDataWin;
begin
  if not Assigned(Sender) then Sender:=aGet;
  result:=Sender;
end;

class function TDataWin.aGetClean;
begin
  result:=aGet(#6#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#6#0#0#0);
end;

class function TDataWin.aCur;
begin
  AddStack('TDataWin.aCur');
  result:=aDataWin[nDataWin];
  DelStack;
end;

class procedure TDataWin.aFree;
begin
  Dec(nDataWin);
end;

class function TDataWin.aGetFields;
begin
  AddStack('TDataWin.aGetFields');
  result:=aGet(s).Fields; DataWinFree;
  DelStack;
end;

function DataWinFields(Sender: TObject; const Wnd: string): string;
begin
  AddStack('FDWPrm.DataWinFields');
  with TDataWin(Sender) do begin
    LoadFromStr(Wnd); result:=Fields;
  end;
  DelStack;
end;

function DataWinSearchIdent(Sender: TObject; const s,sSubStr: string; var aInfo: TDWSearchAInfo;
  lIdent: boolean = true): boolean;
var SubStr: string;
	i: longint;
  a: TArrStr;
  ap: TDEPrmStr;
  g: TCustomGet;
  a1: array[1..5] of string;
  oprop: TFindProperty;
  Opt: TDataWinSearchOpt;
label lend;
begin
  AddStack('FDWPrm.DataWinSearchIdent');
  with TDataWin(Sender) do begin
    result:=false; LoadFromStr(s); SubStr:=FindRegistrStr(sSubStr); aInfo:=nil;
    oprop:=SetFindPropertyIdent(lIdent);
    try
      for i:=0 to LsArrDynamic(Fields,a,CRLF)-1 do begin
        ap:=DEGetArrParam(a[i]);
        if AddInfo(aInfo,result,lIdent,FindInStr(TRecDBDef.DWVarName(ap),SubStr),dwsFldName,i,0,ap[deCaption]) then goto lend;
        if not lIdent then
          if AddInfo(aInfo,result,lIdent,FindInStr(ap[deCaption],SubStr),dwsFldCapt,i,0,ap[deCaption])
          then goto lend;
        if NameGet(g,ap) then
          if AddInfo(aInfo,result,lIdent,g.MaskSearch(ap[deMask],SubStr,lIdent),dwsFldMask,i,0,ap[deCaption])
          then goto lend;
      end;
      if lIdent then Opt:=[dwsIdent] else Opt:=[];
      if SearchIdentPrm(s,SubStr,aInfo,Opt) then result:=true;
      i:=LsArrDynamic(Pages,a,CRLF);
      if i>1 then for i:=0 to i-1 do begin
        LsArrFill(a[i],a1,UnDelim);
        if not lIdent then
          if AddInfo(aInfo,result,lIdent,FindInStr(a1[1],SubStr),dwsZgl,0,i+1) then goto lend;
        if a1[2]='0' then begin
          if Int0(a1[5])>=1 then StrDeShifrSelf(a1[3]);
          if GFSeek(a1[3],SubStr,aInfo,result,lIdent,i+1) then goto lend;
        end;
      end;
lend:
    finally
      FindProperty:=oprop;
    end;
  end;
  DelStack;
end;

function DataWinReplaceIdent(Sender: TObject; var s: string; const stSource,sRepl: string;
  Opt: TGFReplaceOpt = []; PrRepl: TReplaceProc = nil; pav: PVariant = nil): longint;
var sSource: string;
  pav1: PVariant;
	procedure GFRepl(var DcmDef: string; const av: array of variant);
  var aGF: TGFSearchCnt;
    nGF: TGFSearchType;
    cnt: longint;
  begin
    AddStack('FDWPrm.DataWinReplaceIdent.GFRepl');
    if GFOpen(DcmDef) then begin
      if Assigned(pav) then pav1^:=AddFrom(pav^,VarArrayOf(av));
      aGF:=GF.ReplaceIdent(sSource,sRepl,Opt,PrRepl,pav1); cnt:=result;
      for nGF:=low(aGF) to high(aGF) do
        if aGF[nGF]<0 then begin
          result:=aGF[nGF]; break;
        end
        else Inc(result,aGF[nGF]);
      if result>cnt then DcmDef:=GF.SaveDcmStr;
    end;
    DelStack;
  end;
var i,ores,cnt,lf,lp: longint;
  af,ap: TArrStr;
  a: TDEPrmStr;
  r: TRecDBDef;
  lFirst,lNm,lRel,lsh: boolean;
  vn,sf: string;
  g: TCustomGet;
  a1: TVarNmRec;
  a2: array[1..5] of string;
  oprop: TFindProperty;
  nf: TDWForm;
begin
  AddStack('FDWPrm.DataWinReplaceIdent');
  with TDataWin(Sender) do begin
    result:=0; oprop:=SetFindPropertyIdent(not(gfrNoIdent in Opt)); LoadFromStr(s); r:=nil; sf:=''; lFirst:=true;
    if Assigned(pav) then New(pav1) else pav1:=nil;
    try
      sSource:=FindRegistrStr(stSource); lf:=LsArrDynamic(Fields,af,CRLF); lp:=0; 
      for i:=0 to lf-1 do begin
        a:=DEGetArrParam(af[i]); ores:=result; vn:=TRecDBDef.DWVarName(a);
        if gfrNoIdent in Opt then begin
          if Assigned(pav) then pav1^:=AddFrom(pav^,VarArrayOf([dwsFldCapt,vn]));
          cnt:=ReplaceInStr(a[deCaption],sSource,sRepl,PrRepl,pav1);
          if cnt<0 then begin
            result:=cnt; break;
          end
          else Inc(result,cnt);
        end
        else begin
          lNm := FindRegistrStr(vn)=sSource; lRel := FindRegistrStr(TRecDBDef.DWVarNameRel(a))=sSource;
          if lNm or lRel then begin
            if lFirst then begin
              a1:=VarNmToRec(sRepl,false); lFirst:=false;
              if TRecDBDef.SeekDWPrefix(a1[1],r) then sf:=a1[2];
            end;
            if Assigned(r) then
              case ReplaceProc(PrRepl,pav,[dwsFldName,lRel],result) of
                mrCancel: break;
                mrYes: begin
                  if lNm then a[deNameRecFld]:=sf;
                  if lRel then a[deRelation]:=a[deNameRec]+'.'+sf;
                end;
              end;
          end;
        end;
        if NameGet(g,a) then begin
          if Assigned(pav) then pav1^:=AddFrom(pav^,VarArrayOf([dwsFldMask,vn,LongInt(g)]));
          cnt:=g.MaskReplace(a[deMask],sSource,sRepl,not(gfrNoIdent in Opt),PrRepl,pav1);
          if cnt<0 then begin
            result:=cnt; break;
          end;
          Inc(result,cnt);
        end;
        if result>ores then af[i]:=DESetArrParam(a);
      end;
      if (result>=0) and (gfrNoIdent in Opt) then begin
        if Assigned(pav) then pav1^:=AddFrom(pav^,VarArrayOf([dwsZgl]));
        cnt:=ReplaceInStr(Zgl,sSource,sRepl,PrRepl,pav1);
        if cnt<0 then result:=cnt else Inc(result,cnt);
      end;
      if result>=0 then for nf:=low(aForm) to high(aForm) do begin
        if Assigned(pav) then pav1^:=AddFrom(pav^,VarArrayOf([dwsForm,nf]));
        cnt:=ReplaceInStr(aForm[nf],sSource,sRepl,PrRepl,pav1);
        if cnt<0 then result:=cnt else Inc(result,cnt);
      end;
      if result>=0 then begin
        lp:=LsArrDynamic(Pages,ap,CRLF);
        if (lp<2) and DcmBased then GFRepl(DcmDef,[dwsGF,0])
        else if lp>1 then for i:=0 to lp-1 do begin
          LsArrFill(ap[i],a2,UnDelim);
          if a2[2]='0' then begin
            lsh := Int0(a2[5])>=1;
            if lsh then StrDeShifrSelf(a2[3]);
            cnt:=result; GFRepl(a2[3],[dwsGF,i+1]);
            if result<0 then break;
            if result>cnt then begin
              if lsh then StrShifrSelf(a2[3]);
              ap[i]:=ArrayAsList(a2,UnDelim);
            end;
          end;
        end;
      end;
      if result>0 then begin
        Fields:=ArrayAsList(af,CRLF,lf); Pages:=ArrayAsList(ap,CRLF,lp); s:=SaveToStr;
      end;
    finally
      FindProperty:=oprop; DisposeNil(pav1);
    end;
  end;
  DelStack;
end;

{ TDWPrm }
procedure TDWPrm.FormCreate(Sender: TObject);
var i: TDWForm;
begin
	AddStack('TDWPrm.FormCreate',Self);
  odw:=TDataWin.Create;
  for i:=low(afEd) to high(afEd) do begin
  	afEd[i]:=TFldEdit.Create(Self);
    with afEd[i] do begin
      Parent:=PnForm; AssignGet(FormGet);
      Mask:=ButPrm2Mask(aDWFormSay[i],Int2Str(i)); IncOptions([],[ogAutoSize]);
      HelpContext:=aDWHelp[i];
    end;
  end;
  SearchInfo.NumObj:=-1;
  inherited;
  DelStack;
end;

procedure TDWPrm.FormDestroy(Sender: TObject);
begin
	AddStack('TDWPrm.FormDestroy',Self);
  inherited;
  odw.Free;
  DelStack;
end;

class procedure TDWPrm.Execute;
var fl,nopg: boolean;
	i: TDWForm;
  j: longint;
begin
  AddStack('TDWPrm.Execute');
  CreateForm(TDWPrm,DWPrm);
  with DWPrm do begin
  	dw:=DataWin; odw.Assign(dw); Rec['Zgl']:=dw.Zgl;
    Rec['SortMode']:=IfThen(not dw.DcmBased,byte(dw.SortMode)+1);
    Rec['AskByCancel']:=dw.AskByCancel;
    SearchInfo:=SrchInfo; fl:=Assigned(aFormHelp);
    if fl then for i:=low(afEd) to high(afEd) do afEd[i].HelpContext:=aFormHelp[i];
    FormHelpFileProc:=aFormHelpFileProc; FormHelpFilePrm:=aFormHelpFilePrm;
    nopg := DWPage.LsPg.Count<2;
    if ESortMode.Visible<>nopg then begin
    	for j:=0 to PnPrm.ControlCount-1 do
      	if not((PnPrm.Controls[j]=EZgl) or (PnPrm.Controls[j]=EAskByCancel)) then PnPrm.Controls[j].Visible:=nopg;
      PanelEdit1.FillFldList; MainRebuild;
    end;
    if ShowModal<>mrOk then dw.Assign(odw);
    if fl then for i:=low(afEd) to high(afEd) do afEd[i].HelpContext:=aDWHelp[i];
  end;
  FormFree(DWPrm);
  DelStack;
end;

function FVar(const v,ind: variant; lSave: boolean): variant;
var cr: TRecDBDef;
  i,lf,vd: longint;
  s: string;
  pe: TPanelEdit;
  af: TArrFldEdit;
  NoAll: boolean;
begin
	AddStack('FDWPrm.FVar');
  result:=null;
  cr:=RecDBDefVar(ind[1]).DWRdbSeek;
  if not Assigned(cr) then EInterException.Create('Отсутствует вид данных');
  s:=ind[2];
  if (ind[3]=dwsDyn) and (cr.DynamicVid>0) then begin
    lf:=0; NoAll:=true;
    if Assigned(FDWCurDefEdit) and not cr.NoFldEdit then if FDWCurDefEdit.PanelEdit(pe) then with pe do begin
      i:=FieldCount; SetLength(af,i);
      for i:=0 to i-1 do with Fields[i] do if IsDynamic(vd,false) then if TrimUpper(NameRecFld)=TrimUpper(s) then
        if IsDynamic(vd) then begin
          af[lf]:=Fields[i]; Inc(lf);
        end
        else if NoAll then begin
          NoAll:=false; result:=PNameRecFld.Value;
          if lSave then VarValue:=v;
        end;
    end;
    if NoAll then begin
      result:=DDGetValue(cr.DynamicVid,s);
      if lSave then begin
        if not CompVar(result,v) then DDSetValue(cr.DynamicVid,s,v);
        for i:=0 to lf-1 do af[i].Read;
      end;
    end;
  end
  else if cr.NumFromName(s,i) then begin
    result:=cr.ValueNum[i];
    if lSave then begin
      {if MyVarType(v)=V_FLOAT then cr.ValueNum[i]:=mround(v,FloatMaxDec) else} cr.ValueNum[i]:=v;
      if Assigned(FDWCurDefEdit) and not cr.NoFldEdit then
        if FDWCurDefEdit.PanelEdit(pe) then with pe do
          for i:=0 to FieldCount-1 do
            if (TrimUpper(Fields[i].NameRec)=TrimUpper(cr.NameRec))
            and (TrimUpper(Fields[i].NameRecFld)=TrimUpper(s))
            then Fields[i].Read;
    end;
  end
  else if lSave then CurInter.ProcError('Переменная не определена в текущем виде данных',[]);
  if IsNil(result) then begin
    if not lSave and (MyVarType(v)=varString) then s:=v else s:=InterCurVar.types;
    if Length(s)=1 then case s[1] of
      'A','L': result:=false;
      'C','S': result:='';
      'D': result:=DateEmpty;
      'F','I','N': result:=0;
    end;
  end;
  DelStack;
end;

procedure FVarTrans(const s: string; const av: array of variant;
	lShapeFull: boolean; var result: varrec);
var i: longint;
	r: TDWVidRec;
begin
	AddStack('FDWPrm.FVarTrans');
  with result do begin
	  index:=ArrVarToVar([av[0],s,dwsFix]);
    if lShapeFull then with RecDBDefVar(av[0]).DWRdbSeek do
    	for i:=0 to FldDef.Count-1 do begin
      	r:=DWSToRec(i);
        if TrimUpper(r.Name)=TrimUpper(s) then begin
        	hint:=r.Prim; {types:=VarCreateTypes(r);} break;
        end;
      end;
	end;
  DelStack;
end;

class procedure TDWPrm.VarCreate(rdb: TRecDBDef);
var a: TArrStr;
  i: longint;
  r: TDWVidRec;
begin
	AddStack('TDWPrm.VarCreate');
  VarFree(rdb); i:=LsArrDynamic(rdb.DWTrans,a,CRLF);
  if i>0 then begin
    TInter.SetVar('$'+rdb.DWPrefix,rdb.DWVarName,rdb.DWName);
    for i:=0 to i-1 do begin
      r:=DWSToRec(a[i]);
      TInter.SetVar(rdb.DWVarName(r.Name),r.Prim,FVar,ArrVarToVar([LongInt(rdb),r.Name,r.SvType]),
        VarCreateTypes(r));
    end;
  end;
  DelStack;
end;

function DopGetVarEqual(const name: string; const av: array of variant): boolean;
var i: longint;
begin
  AddStack('FDWPrm.DopGetVarEqual');
  result := name='';
  if not result then for i:=low(av) to high(av) do
    if AnsiStartsStr(av[i],name) then begin
      result:=true; break;
    end;
  DelStack;
end;

class procedure TDWPrm.VarCreate(const ardb: array of TRecDBDef;
  PrAdd: TProcDopGetVarsAdd; PrIgnore: TProcDopGetVarIgnore);
var i: longint;
  av: TArrVar;
begin
  AddStack('TDWPrm.VarCreate(Shape)');
  SetLength(av,Length(ardb));
  for i:=low(ardb) to high(ardb) do begin
    TInter.SetVarShape(ardb[i].DWVarName,FVar,FVarTrans,[LongInt(ardb[i])]); av[i]:=ardb[i].DWVarName;
  end;
  Tinter.DopGetVarAdd(av,DopGetVarEqual,PrAdd,PrIgnore);
  DelStack;
end;

class procedure TDWPrm.VarFree;
begin
	AddStack('TDWPrm.VarFree');
{if rdb.DWPrefix='ДОК' then begin
rdb.DWPrefix:=rdb.DWPrefix;
end;}
	TInter.DelVar('$'+rdb.DWPrefix);
  DelStack;
end;

function TDWPrm.FormGetClick(Sender: TObject; lEval: Boolean): String;
const	aEdType: array[TDWForm] of TEdTextType =	(edtpInter,edtpInter,edtpInter,edtpInter,edtpInter,
  edtpInter,edtpInter,edtpInter,edtpInter,edtpInter,edtpInter,edtpHelp);
var n: TDWForm;
	ms: string;
  tf: TFldEdit;
begin
	AddStack('TDWPrm.FormGetClick',Self);
  inherited;
  if Assigned(dw) then begin
    tf:=pointer(Sender); ms:=ButMask2Prm(tf.Mask).Mask; n:=TDWForm(Int0(ms));
    if lEval then begin
      if SearchInfo.NumObj>=0 then EdTextInitFind:=true;
      AddPrnHead('Формула: "'+aDWFormSay[n]+'"');
      EdTextExec(aDWFormSay[n],dw.aForm[n],'',nil,[],aEdType[n],0,0,'',tf.HelpContext,
        nil,'',nil,nil,'',nil,nil,FmlGetHelp);
      DelPrnHead;
    end;
    result:=dw.aForm[n];
  end
  else result:='';
  DelStack;
end;

function TDWPrm.PanelEdit1Valid(Sender: TObject): Boolean;
begin
	AddStack('TDWPrm.PanelEdit1Valid',Self);
  inherited;
  dw.Zgl:=TrimRight(Rec['Zgl']); dw.DcmBased := Rec['SortMode']=0;
  if not dw.DcmBased then dw.SortMode:=Rec['SortMode']-1;
  dw.AskByCancel:=Rec['AskByCancel']; result:=true;
  DelStack;
end;

function TDWPrm.PanelEdit1AskCancel(Sender: TObject): Boolean;
begin
	AddStack('TDWPrm.PanelEdit1AskCancel',Self);
  inherited;
  result := not dw.Equals(odw);
  DelStack;
end;

procedure TDWPrm.PnFormResize(Sender: TObject);
begin
	AddStack('TDWPrm.PnFormResize',Self);
	RspColRow(Sender,3);
  DelStack;
end;

procedure TDWPrm.EAskByCancelChange(Sender: TObject;
  const OldVal: Variant; FromShow: boolean);
begin
	AddStack('TDWPrm.EAskByCancelChange',Self);
  afEd[dwfAskCancel].SetReadOnly(not Rec['AskByCancel']);
  DelStack;
end;

procedure TDWPrm.KeyLb1ProcKey(key: longint; tw: TWinControl);
var tn,tn1,tnSel: TTreeNode;
	i: longint;
  tp: TDWSearchType;
begin
	AddStack('TDWPrm.KeyLb1ProcKey',Self);
  inherited;
  if WinFindKey(key,PanelEdit1,prFind,[fnoRegistr,fnoWord]) then with SearchTree,SearchTree.Tree do begin
    ClearPrim; tp:=low(aDWSearchSay); tn:=nil; tnSel:=nil;
    for i:=low(aInfo) to high(aInfo) do begin
      if (i=low(aInfo)) or (tp<>aInfo[i].TypeObj) then begin
        tp:=aInfo[i].TypeObj; tn:=AddPrim(nil,aDWSearchSay[tp]);
      end;
      case tp of
        dwsForm: tn1:=AddPrim(tn,aDWFormSay[TDWForm(aInfo[i].NumObj)]);
        dwsGF: tn1:=AddPrim(tn,GFObjSearchNode(aInfo[i].Text),'',0,nil,aInfo[i].Text);
      else tn1:=tn;
      end;
      PointerDef(pointer(tnSel),tn1);
    end;
    if Execute(tnSel,i) then begin
      SearchInfo:=aInfo[i]; TimerSearch(nil);
    end;
  end;
  DelStack;
end;

class function TDWPrm.GFObjSearchNode;
var a: TArrStr;
	sf: string;
  j: longint;
begin
  AddStack('TDWPrm.GFObjSearchNode');
  sf:=TrimUpper(TFind.LastViewForm.RV['S']); result:='';
  for j:=0 to LsArrDynamic(TxtObj,a,CRLF)-1 do if Pos(sf,AnsiUpperCase(a[j]))>0 then begin
    result:=Trim(a[j]); break;
  end;
  DelStack;
end;

function TDWPrm.prFind;
begin
	AddStack('TDWPrm.prFind',Self);
  result:=dw.SearchIdentPrm(dw.SaveToStr,sf,aInfo,[dwsClear]);
  if result then TSearchTree.Init(sf);
  DelStack;
end;

procedure TDWPrm.FormShow(Sender: TObject);
begin
	AddStack('TDWPrm.FormShow',Self);
  inherited;
  if SearchInfo.NumObj>=0 then
    if Assigned(tmSearch) then tmSearch.Enabled:=true
    else begin
      tmSearch:=TTimer.Create(Self); tmSearch.Interval:=1; tmSearch.OnTimer:=TimerSearch;
    end;
  DelStack;
end;

procedure TDWPrm.TimerSearch;
begin
	AddStack('TDWPrm.TimerSearch',Self);
  if Assigned(tmSearch) then tmSearch.Enabled:=false;
  case SearchInfo.TypeObj of
  	dwsForm: begin
      afEd[TDWForm(SearchInfo.NumObj)].SetFocus; KeyLb1.ExecKey(K_F5);
    end;
    dwsGF: begin
    	EForm.SetFocus; DWPrmSearchGF(SearchInfo); KeyLb1.ExecKey(K_F5);
    end;
    else EZgl.SetFocus;
  end;
  SearchInfo.NumObj:=-1;
  DelStack;
end;

procedure TDWPrm.WMFormLimit;
begin
	AddStack('TDWPrm.WMFormLimit',Self);
  inherited;
  FreeLimit(DWPrm);
  DelStack;
end;

procedure TDWPrm.FmlGetHelp;
var tw: TWinControl;
  i: TDWForm;
begin
  AddStack('TDWPrm.FmlGetHelp',Self);
  if Assigned(FormHelpFileProc) then with TWMHelpFill(Message) do if Oper=hlpFile then
    if ParentClass(tw,ActiveControl,TFldEdit) then if tw.HelpContext=0 then
      for i:=low(afEd) to high(afEd) do if afEd[i]=tw then begin
        ResFile:=FormHelpFileProc(i,FormHelpFilePrm,pFile.f[hlpfBase]); break;
      end;
  DelStack;
end;

procedure TDWPrm.ESortModeChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TDWPrm.ESortModeChange',Self);
  EForm.SetReadOnly(Rec['SortMode']>0);
  DelStack;
end;

{ TDWWin }
constructor TDWWin.Create(AOwner: TComponent = nil);
const aType: array[boolean,TDWForm] of string =
  (('','','','','','L',''   ,'','','L','','A')
  ,('','','','','','L','LNC','','','L','','A')
  );
var i: TDWForm;
  fl: boolean;
begin
	AddStack('TDWWin.Create',Self);
	inherited Create(AOwner);
	dw:=TDataWin.Create; fl := GetUserGG>1;
  for i:=low(i) to high(i) do begin
	  aInt[i]:=TInter.Create('');
    with aInt[i] do begin
      value_types:=aType[fl,i]; showerror:=false; GetAlgProc:=IntGetAlgProc;
    end;
  end;
	de:=TDefEdit.Create(Self);
  de.OnFrmShow:=FrmShow; de.OnFrmHide:=FrmHide; de.OnFldEnter:=FldEnter;
  de.OnFldExit:=FldExit; de.OnFldChange:=FldChange; de.OnFldCheck:=FldCheck;
  de.OnPnlValid:=PnlValid; de.OnPnlEscape:=PnlEscape; de.OnPnlAfterEscape:=PnlAfterEscape;
  de.OnPnlAskCancel:=PnlAskCancel;
  FActive:=false; lScroll:=true;
  DelStack;
end;

class function TDWWin.CreateOne;
begin
  AddStack('TDWWin.CreateOne');
  if not Assigned(Sender) then Sender:=Create(AOwner);
  result:=Sender;
  DelStack;
end;

destructor TDWWin.Destroy;
var i: TDWForm;
begin
	AddStack('TDWWin.Destroy',Self);
	dw.Free;
  for i:=low(i) to high(i) do aInt[i].Free;
	inherited Destroy;
  DelStack;
end;

function TDWWin.Execute;
var i,j: longint;
	a: TArrBool;
  fl,flLog,lApp: boolean;
  sLog: TBoolSet;
begin
	AddStack('TDWWin.Execute',Self);
  flLog:=false; j:=Length(aRec); SetLength(a,j); SetLength(aRecEd,j); lApp:=false;
  if j>0 then ZeroMemory(@a[0],SizeOf(a[0])*j);
  if Length(aNoSeek)>0 then
    if aNoSeek[low(aNoSeek)]<>0 then
      for i:=low(aNoSeek) to high(aNoSeek) do a[aNoSeek[i]-1]:=true;
  if j>0 then begin
    sLog:=[]; j:=0;
    for i:=low(aRec) to high(aRec) do
      if Assigned(aRec[i]) then begin
        aRec[i].InitFldDef(IfThen(a[i],dwdefGotoRec));
        Include(sLog,aRec[i].Recno=0); aRecEd[j]:=aRec[i]; Inc(j);
        if aRec[i].Recno=0 then lApp:=true;
      end;
    if lLog then for fl:=false to true do if not(fl in sLog) then begin
      SetLogVid(aEdAppLog[not fl]); flLog:=true; break;
    end;
    SetLength(aRecEd,j);
  end;
  FldOnPanel(Value,NameWnd,NameScr,nil);
	Active:=true;
  try
    result:=de.Execute(Capt,CanShow,OnPnlUpdateRecDB);
    if result.Saved then
      if lApp then begin
        for j:=0 to de.FldCount-1 do de.FldEdit[j].UpdateRec(feuBeforeUpd);
        for j:=0 to de.FldCount-1 do de.FldEdit[j].UpdateRec(feuAfterUpd);
      end;
  finally
  	Active:=false;
    if flLog then SetLogVid;
    aRecEd:=nil;
  end;
  DelStack;
end;

procedure TDWWin.SaveState;
begin
  AddStack('TDWWin.SaveState');
  if Length(aState)=nState then SetLength(aState,nState+1);
  with aState[nState] do begin
    de:=FDWCurDefEdit; rdb:=CurRdbArr;
  end;
  Inc(nState); FDWCurDefEdit:=de;
  DelStack;
end;

procedure RestState;
begin
  AddStack('FDWPrm.RestState');
  Dec(nState);
  with aState[nState] do begin
    FDWCurDefEdit:=de; CurRdbArr:=rdb;
  end;
  DelStack;
end;

procedure TDWWin.FldOnPanel;
var i: TDWForm;
begin
	AddStack('TDWWin.FldOnPanel',Self);
  SaveState;
  try
    if MyVarType(Value)=varString then dw.LoadFromStr(Value);
    de.FrmCaption:=dw.Zgl; de.PnlSortMode:=dw.SortMode;
    de.PnlAskByCancel:=dw.AskByCancel; de.Fields.Text:=dw.Fields; de.Pages.Text:=dw.Pages;
    de.DcmBased:=dw.DcmBased; de.DcmDef:=dw.DcmDef; de.NameWnd:=NameWnd;
    de.OnPnlCngKey:=OnPnlCngKey; 
    for i:=low(i) to high(i) do with aInt[i] do begin
      Name:=NameScr+'('+aDWFormSay[i]+')'; SetProg(dw.aForm[i]);
    end;
    if Assigned(Sender)
    then de.FldOnPanel(Sender,IfThen(lBound,depnBound)+IfThen(not lScroll,depnNoScroll));
  finally
    RestState;
  end;
  DelStack;
end;

procedure TDWWin.SetActive;
var i: longint;
begin
	AddStack('TDWWin.SetActive',Self);
	if Value<>FActive then begin
    FActive:=Value;
    if Value then begin
      ListCreateObj(Self,LsDWWin);
      for i:=0 to de.FldCount-1 do with de.FldEdit[i] do
        if Assigned(curget) then curget.AfterActiveDefEdit(de.FldEdit[i]);
      SaveState;
    end
    else begin
      RestState; ListDestroyObj(Self,LsDWWin);
    end;
  end;
  DelStack;
end;

class procedure TDWWin.VarPartGetClick;
var av: TArrVarRec;
	a: TArrStr;
  ar: TITArr;
  i,lr,l: longint;
  tf: TFldEdit;
  s: string;
begin
	AddStack('TDWWin.VarPartGetClick');
  tf:=pointer(Sender); l:=LsArrDynamic(tf.Value,a,','); TrimSelf(a,l); QuickSort(a,l);
  Tinter.GetVar(av); i:=Length(av); SetLength(ar,i); lr:=0; s:='';
  for i:=0 to i-1 do if Length(av[i].name)>1 then
    if (av[i].name[1]='$') and not empty(av[i].hint) then begin
      av[i].name:=VarWithoutPrim(av[i].name);
      ar[lr].name:=av[i].name; ar[lr].hlp:=0; ar[lr].prim:=av[i].hint; Inc(lr);
      if QuickFind(Copy(av[i].name,2,MaxInt),a,l) then IncD(s,','+av[i].hint);
    end;
  l:=LsArrDynamic(TIntTree.Execute('Допустимые разделы','Var',Copy(s,2,MaxInt),ar,lr,[itreCanCheck,itreCanCheckNode]),
    a,',',lsaSort);
  s:='';
  for i:=0 to lr-1 do with ar[i] do if QuickFind(prim,a,l) then IncD(s,','+Copy(name,2,MaxInt));
  tf.Value:=Copy(s,2,MaxInt);
  DelStack;
end;

procedure TDWWin.FrmShow;
begin
	AddStack('TDWWin.FrmShow',Self);
  if FActive then begin
    IfThenNotify(OnFrmShow,Sender); IntEval(Sender,dwfShow,null,null,null,null);
  end;
  DelStack;
end;

procedure TDWWin.FrmHide;
begin
	AddStack('TDWWin.FrmHide',Self);
  if FActive then begin
    IfThenNotify(OnFrmHide,Sender); IntEval(Sender,dwfHide,null,null,null,null);
  end;
  DelStack;
end;

procedure TDWWin.FldEnter;
begin
	AddStack('TDWWin.FldEnter',Self);
  if FActive then begin
    IfThenNotify(OnFldEnter,Sender); IntEval(Sender,dwfEnter,null,null,null,null);
  end;
  DelStack;
end;

procedure TDWWin.FldExit;
begin
	AddStack('TDWWin.FldExit',Self);
  if FActive then begin
    IfThenNotify(OnFldExit,Sender); IntEval(Sender,dwfExit,null,null,null,null);
  end;
  DelStack;
end;

procedure TDWWin.FldChange;
begin
	AddStack('TDWWin.FldChange',Self);
  if FActive then begin
    IfThenCng(OnFldChange,Sender,OldVal,FromShow);
    IntEval(Sender,dwfChange,OldVal,FromShow,ArrVarToVar([FEChangeWhere]),null);
  end;
  DelStack;
end;

function TDWWin.FldCheck;
var v: variant;
begin
	AddStack('TDWWin.FldCheck',Self);
	result:=true;
  if FActive then begin
    result:=IfThenValid(OnFldCheck,Sender);
    if result then
      if IntEval(v,Sender,dwfCheck,null,null,null,true) then result:=v;
  end;
  DelStack;
end;

function TDWWin.PnlValid;
var v: variant;
  i: longint;
  a: TNamePrimStr;
begin
	AddStack('TDWWin.PnlValid',Self);
	result:=true;
  if FActive then begin
    v:=IntEval(Sender,dwfValid,null,null,null,true);
    case MyVarType(v) of
      V_BOOL: result:=v;
      V_INT: begin
        result := v<=0;
        if not result then TPanelEdit(Sender).FldFocus:=de.FldEdit[min(v,de.FldCount)-1];
      end;
      V_STRING: begin
        result := v='';
        if not result then with TPanelEdit(Sender) do begin
          FldFocus:=de.FldEdit[v];
          if not Assigned(FldFocus) then
            if StrDivDlm('_',v,a) then FldFocus:=de.FldEdit[a[2]];
        end;
      end;
    end;
    if result then begin
      result:=IfThenValid(OnPnlValid,Sender);
      if result then for i:=low(aRecEd) to high(aRecEd) do with aRecEd[i] do
        if Recno=0 then AppRec(true);
    end;
  end;
  DelStack;
end;

procedure TDWWin.PnlEscape;
begin
	AddStack('TDWWin.PnlEscape',Self);
  if FActive then begin
    IfThenClose(OnPnlEscape,Sender,Action); IntEval(Sender,dwfEscape,null,null,null,null);
  end;
  DelStack;
end;

procedure TDWWin.PnlAfterEscape;
begin
	AddStack('TDWWin.PnlAfterEscape',Self);
  if FActive then begin
    IfThenNotify(OnPnlAfterEscape,Sender); IntEval(Sender,dwfAfterEscape,null,null,null,null);
  end;
  DelStack;
end;

function TDWWin.PnlAskCancel;
var v: variant;
begin
	AddStack('TDWWin.PnlAskCancel',Self);
	result:=true;
  if FActive then begin
    result:=IfThenValid(OnPnlAskCancel,Sender);
    if result then
      if IntEval(v,Sender,dwfAskCancel,null,null,null,false) then result:=v;
  end;
  DelStack;
end;

function TDWWin.HelpProc;
begin
  AddStack('TDWWin.HelpProc',Self);
  if not IntEval(result,nil,dwfHelp,null,null,null,null) then result:=null;
  DelStack;
end;

function TDWWin.IntEval(Sender: TObject; nf: TDWForm; const p3,p4,p5,Default: variant): variant;
begin
  IntEval(result,Sender,nf,p3,p4,p5,Default);
end;

function TDWWin.IntEval(var v: variant; Sender: TObject; nf: TDWForm; const p3,p4,p5,Default: variant): variant;
var i: longint;
	av: TArrVar;
  oDWCurDefEdit: TDefEdit;
  onfCur: TDWForm;
begin
	AddStack('TDWWin.IntEval',Self);
  if FActive and not empty(dw.aForm[nf]) then begin
    oDWCurDefEdit:=FDWCurDefEdit; onfCur:=nfCur;
    try
      FDWCurDefEdit:=de; SetLength(av,5); av[1]:=null;
      if Sender is TFldEdit then begin
        av[0]:=TFldEdit(Sender).DWVarName;
        for i:=0 to de.FldCount-1 do if de.FldEdit[i]=Sender then begin
          av[1]:=i+1; break;
        end;
      end
      else av[0]:=null;
      av[2]:=p3; av[3]:=p4; av[4]:=p5; AddFromVArr(av,Params);
      if Assigned(PrRedefParam) then PrRedefParam(Sender,av);
      nfCur:=nf; result:=aInt[nf].EvalChk(v,av);
      if not(aInt[nf].error in [E_NO,E_ABORT]) then InterShowError(aInt[nf],[ieEnter]);
    finally
      FDWCurDefEdit:=oDWCurDefEdit; nfCur:=onfCur;
    end;
  end
  else begin
    v:=Default; result:=true;
  end;
  DelStack;
end;

procedure TDWWin.IntGetAlgProc;
begin
  AddStack('TDWWin.IntGetAlgProc',Self);
  Txt:=dw.aForm[nfCur];
  DelStack;
end;

{ TVarSelGet }
constructor TVarSelGet.Create;
begin
  AddStack('TVarSelGet.Create',Self);
  inherited Create(AOwner);
  RVid:='Имя вводимого данного'; LenName:=20;
  DelStack;
end;

procedure TVarSelGet.StdListDown;
var ar: TITArr;
  lr: longint;
  procedure arAdd(const vr: varrec);
  begin
  	AddStack('TVarSelGet.StdListDown.arAdd',Self);
    if Length(ar)=lr then SetLength(ar,lr+10);
    ar[lr].name:=vr.name; ar[lr].hlp:=0; ar[lr].prim:=vr.hint; Inc(lr);
    DelStack;
  end;
var s,czn: string;
	a: TArrStr;
  i,j,l,ocnt,ncnt: longint;
  av,av1: TArrVarRec;
  fl: boolean;
begin
	AddStack('TVarSelGet.StdListDown',Self);
  s:=tf.SayCaption; czn:='';
  Tinter.GetVar(av); l:=LsArrDynamic(CmbPrm(tf.Mask).Mask,a,',');
  for i:=0 to l-1 do a[i]:='$'+Trim(a[i]);
  QuickSort(a,l); fl := l=0; ocnt:=MaxInt; i:=Length(av); lr:=0; SetLength(ar,i);
  for i:=0 to i-1 do begin
    if l>0 then if StrToChar(av[i].name)='$' then begin
      ncnt:=0;
      for j:=1 to Length(av[i].name) do
        if av[i].name[j]='$' then Inc(ncnt) else break;
      if Length(av1)<ncnt then SetLength(av1,ncnt);
      av1[ncnt-1]:=av[i];
      if ncnt<=ocnt then begin
        fl:=QuickFind(av[i].name,a,l);
        if not fl then fl:=QuickFind(VarWithoutPrim(av[i].name),a,l);
        if fl then begin
          ocnt:=ncnt;
          for j:=low(av1) to ncnt-2 do
            if av1[j].name<>'' then begin
              arAdd(av1[j]); av1[j].name:='';
            end;
        end
        else ocnt:=MaxInt;
      end;
    end;
    if fl then begin
      arAdd(av[i]);
      if czn='' then if av[i].name=tf.Value then czn:=av[i].name;
    end;
  end;
  if (czn='') and Assigned(CurDWFldRdb) then for i:=low(av) to high(av) do
    if (StrTran(VarWithoutPrim(av[i].name),'$')=CurDWFldRdb.DWPrefix) and (i<high(av)) then begin
      czn:=av[i+1].name; break;
    end;
  s:=TIntTree.Execute(s,'Var',czn,ar,lr,[],@RectList);
  if s<>'' then tf.Value:=s;
  DelStack;
end;

function TVarSelGet.Check;
begin
  result:=true;
end;

function TVarSelGet.AssignObj;
begin
	AddStack('TVarSelGet.AssignObj',Self);
  result := inherited AssignObj(tf);
  if result then begin
  	Parts:=Prm.Mask; Prm.Mask:='';
  end;
  DelStack;
end;

function TVarSelGet.MaskTrans;
begin
	AddStack('TVarSelGet.MaskTrans',Self);
  result := inherited MaskTrans(av,r,nmf); VarPartGetMaskTrans(av,result);
  DelStack;
end;

procedure TVarSelGet.FMaskHelp;
begin
  AddStack('TVarSelGet.FMaskHelp',Self);
  inherited;
  CopyFrom(ht.Dat[high(ht.Dat)-1],HelpArrayAsList('«Допустимые разделы»','","')+'+"'+UnDelim+'"+;');
  DelStack;
end;

{ TVarChkGet }
constructor TVarChkGet.Create;
begin
  AddStack('TVarChkGet.Create',Self);
  inherited Create(AOwner);
  RVid:='Отметка выводимых данных';
  DelStack;
end;

function TVarChkGet.Click;
var aPart: TArrStr;
  lAdd: boolean;
  av1: TArrVar;
  function Redef(tp: TVarChkGetClickRedefType; ps: PString): boolean;
  begin
  	AddStack('TVarChkGet.Click.Redef',Self);
    result:=Assigned(FOnClickRedef);
    if result then FOnClickRedef(tf,tp,aPart,ps,@lAdd,av1);
    DelStack;
  end;
var av: TArrVarRec;
  ar: TITArr;
  s: string;
  lAddPart,lPart: boolean;
  i,l: longint;
  Prm: TVarChkGetPrm;
begin
	AddStack('TVarChkGet.Click',Self);
  if lEval then begin
    Prm:=TVarChkGet.Mask2Prm(tf.Mask); LsArrDynamic(Prm.Parts,aPart,',',[lsaSetLen,lsaSort]);
    Redef(vctBeg,nil);
    Tinter.GetVar(av); lAddPart:=false; l:=0; i:=Length(av); SetLength(ar,i);
    for i:=0 to i-1 do begin
      {if AnsiStartsStr('$$tnbo',av[i].name) then begin
        av:=av;
      end;}
      if Length(av[i].name)<2 then lPart:=false else lPart := (av[i].name[1]='$'){ and (av[i].name[2]<>'$')};
      if lPart then lAddPart:=QuickFind(Copy(VarWithoutPrim(av[i].name),2,MaxInt),aPart);
      if lAddPart then begin
        lAdd:=lPart;
        if not Redef(vctAdd,@av[i].name) then lAdd:=true;
        if lAdd then begin
          ar[l].name:=IfThen(not lPart,av[i].name); ar[l].hlp:=0; ar[l].prim:=av[i].hint; Inc(l);
        end
        else if lPart then lAddPart:=false;
      end;
    end;
    if IsCharLower(StrToChar(Prm.Capt)) then IncL(Prm.Capt,'Выводимые данные ');
    s:=TIntTree.Execute(Prm.Capt,'Var',TrimRight(tf.Value),ar,l,[itreCanCheck]+IfThen(Prm.lOrd,itreOrd));
    Redef(vctEnd,@s); tf.Value:=s;
  end;
  result:='';
  DelStack;
end;

procedure TVarChkGet.DoEnter;
var tl: TKeyLb;
begin
	AddStack('TCustomButGet.DoEnter',Self);
	inherited DoEnter(tf);
  if not(ogReadOnly in tf.Options) then if Mask2Prm(tf.Mask).lOrd then if FormKeyLb(tf,tl) then begin
    tl.SetKey(K_F3,'Порядок','Изменение порядка вывода',ProcKey,'varchkget',kmEdit); tl.ReDrw;
  end;
  DelStack;
end;

procedure TVarChkGet.DoExit;
var tl: TKeyLb;
begin
	AddStack('TCustomButGet.DoExit',Self);
  if FormKeyLb(tf,tl) then tl.DelKey(K_All,'varchkget');
	inherited DoExit(tf);
  DelStack;
end;

procedure TVarChkGet.ProcKey;
var Prm: TLogTrnsValPrm;
begin
	AddStack('TVarChkGet.ProcKey',Self);
  tfOrd:=pointer(tw); Prm.Opt:=[]; TVarChkLogCompare.ExecuteStr(Prm,'',tfOrd.Value); oldInd:=-1;
  ListF2Down(Prm.val,nil,nil,0,'Browl',ArrayAsList(
    [TKeyLb.GetKeySt(K_Ctrl_Up,'Выше','Переместить выше')
    ,TKeyLb.GetKeySt(K_Ctrl_Down,'Ниже','Переместить ниже')
    ],CRLF),OrdProcKey,0,nil,OrdMouseDown,OrdMouseMove,OrdMouseUp,nil,
    FRup(DlmBetween(ButMask2Prm(tfOrd.Mask).Capt,'порядок вывода',': ')),false);
  DelStack;
end;

procedure TVarChkGet.OrdProcKey;
var ls: TFindListBox;
	i,j: longint;
begin
  AddStack('TVarChkGet.OrdProcKey',Self);
  ls:=pointer(tw); ls.Filtered:=false; i:=ls.ItemIndex; j:=i;
  case Key of
    K_Ctrl_Up: Dec(i);
    K_Ctrl_Down: Inc(i);
  end;
  if InRange(i,0,ls.Items.Count-1) then begin
    ls.Items.Exchange(j,i); OrdMove(ls,j,i);
  end;
  DelStack;
end;

procedure TVarChkGet.OrdMove;
var a: TArrStr;
  l: longint;
  s: string;
begin
  AddStack('TVarChkGet.OrdMove',Self);
  l:=LsArrDynamic(tfOrd.Value,a,','); s:=a[oi]; a[oi]:=a[ni]; a[ni]:=s; tfOrd.VarValue:=ArrayAsList(a,',',l);
  ls.ItemIndex:=ni;
  DelStack;
end;

procedure TVarChkGet.OrdMouseDown;
var Ls: TFindListBox;
begin
  AddStack('TVarChkGet.OrdMouseDown',Self);
	if ssLeft in Shift then begin
    Ls:=pointer(Sender); Ls.Filtered:=false; curInd:=Ls.ItemAtPos(Point(X,Y),true); oldInd:=curInd;
    if oldInd>=0 then begin
      Ls.ItemIndex:=curInd; //Ls.Cursor:=crDrag;
    end;
  end;
  DelStack;
end;

procedure TVarChkGet.OrdMouseMove;
var Ls: TFindListBox;
	i,j: longint;
	step: TValueSign;
begin
  AddStack('TVarChkGet.OrdMouseMove',Self);
	if oldInd>=0 then begin
		Ls:=pointer(Sender); i:=Ls.ItemAtPos(Point(X,Y),true);
    if (i>0) and (curInd<>i) then begin
      j:=i; step:=aSign[curInd<i];
      while j<>curInd do begin
        Ls.Items.Exchange(j,curInd); Inc(j,step);
      end;
      curInd:=i; Ls.ItemIndex:=curInd;
    end;
  end;
  DelStack;
end;

procedure TVarChkGet.OrdMouseUp;
var Ls: TFindListBox;
	i: longint;
begin
  AddStack('TVarChkGet.OrdMouseUp',Self);
	if oldInd>=0 then begin
		Ls:=pointer(Sender);
    if Y<0 then i:=0
    else begin
      i:=Ls.ItemAtPos(Point(X,Y),true);
      if i=-1 then i:=Ls.Items.Count-1;
    end;
    if i<>oldInd then OrdMove(ls,oldInd,i);
		Ls.Cursor:=crDefault; oldInd:=-1;
  end;
  DelStack;
end;

class function TVarChkGet.MaskTextReadOnly;
begin
	result:=true;
end;

class procedure TVarChkGet.FMaskView;
begin
  AddStack('TVarChkGet.FMaskView');
  with Mask2Prm(Mask) do
    Mask:=DlmBetween([Capt,IfThen(not empty(Parts),'разделы:'+Parts),IfThen(lOrd,'порядок')],';');
  DelStack;
end;

class function TVarChkGet.Mask2Prm;
var Prm: TButGetPrm;
  a: array[1..2] of string;
begin
  AddStack('TVarChkGet.Mask2Prm');
  Prm:=ButMask2Prm(Mask);
  with result do begin
    Capt:=Prm.Capt; LsArrFill(Prm.Mask,a,UnDelim); Parts:=a[1]; lOrd:=StrToBoolean(a[2]);
  end;
  DelStack;
end;

class function TVarChkGet.Prm2Mask;
begin
  AddStack('TVarChkGet.Prm2Mask');
  result:=ButPrm2Mask(Capt,Parts+UnDelim+bStr[lOrd]);
  DelStack;
end;

procedure TVarChkGet.DoPaint;
const oX=2; oY=2; iX=2;
var Prm: TLogTrnsValPrm;
  a: TArrStr;
  i,l,t,h,w,w1: longint;
begin
	AddStack('TVarChkGet.DoPaint',Self);
  with tf.Canvas do begin
    FillRect(ARect); Pen.Color:=Font.Color;
    h:=CanvasMaxH(tf.Canvas); l:=ARect.Left+oX; t:=ARect.Top+oY; w:=0;
    Prm.Opt:=[]; TVarChkLogCompare.ExecuteStr(Prm,'',tf.Value);
    for i:=0 to LsArrDynamic(Prm.val,a,CRLF)-1 do begin
      w1:=TextWidth(a[i]);
      TextRect(Rect(l,t,min(l+w1,ARect.Right),min(t+h,ARect.Bottom)),l,t,a[i]);
      MaxSelf(w,w1); Inc(t,h);
      if t+h>ARect.Bottom then begin
        Inc(l,w+iX);
        if l>=ARect.Right then break;
        MoveTo(l,ARect.Top+oY); LineTo(l,ARect.Bottom-oY);
        Inc(l,iX); t:=ARect.Top+oY; w:=0;
      end;
    end;
  end;
  DelStack;
end;

function TVarChkGet.MaskTrans;
var la: boolean;
  v: variant;
begin
	AddStack('TVarChkGet.MaskTrans',Self);
  v:=av; la := MyVarType(av)=varArray;
  if la
  then result:=Prm2Mask(TrimRight(IsNilc(av[1],'')),TrimRight(IsNilc(av[2],'')),IsNilc(v[3],false))
  else result := inherited MaskTrans(v,r,nmf);
  VarPartGetMaskTrans(v,result);
  if not la then with Mask2Prm(v) do begin
    v:=result[2]; v[2]:=Parts; result[2]:=v;
    AddFromSelf(result,ArrVarToVar([VarArrayOf([mpBool,'Изменение порядка вывода',lOrd])]));
  end;
  DelStack;
end;

procedure TVarChkGet.FMaskHelp;
var n: byte;
begin
  AddStack('TVarChkGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+2);
  CopyFrom(ht.Dat[n],HelpArrayAsList('«Допустимые разделы»','","')+'+"'+UnDelim+'"+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpBool('«Изменение порядка вывода»'));
  DelStack;
end;

procedure TVarChkGet.LogCompare;
begin
  AddStack('TVarChkGet.LogCompare',Self);
  TVarChkLogCompare.Execute(Prm);
  inherited LogCompare(tf,Prm);
  DelStack;
end;

{ TFldList }
function ChildFldCreate(g: TCustomGet; const FldInfo: TDWFldInfo; const nmf: string): PFldInf; overload;
var lCrt: boolean;
begin
  AddStack('FDWPrm.ChildFldCreate');
  if Assigned(lsFld) then with lsFld do begin
    if Length(aFld)=nFld then SetLength(aFld,nFld shl 1);
    result:=@aFld[nFld];
    result.rdb:=FldLsCurRdb;
    if Assigned(g) then begin
      result.Vid:=g.ClassName; result.VName:=g.VName;
    end
    else begin
      result.Vid:=''; result.VName:='';
    end;
    result.DWFldInfo:=FldInfo; result.DWFldInfo.r:=FldLsCurVR; result.Dop:=nil;
    lCrt := nmf<>'';
    if lCrt then Insert(piFld^,nmf);
    lsFld.Objects[piFld^]:=pointer(nFld); Inc(nFld);
    if lCrt then Inc(piFld^);
    FldChildCreated:=true;
  end
  else result:=nil;
  DelStack;
end;

procedure ChildFldCreate(g: TCustomGet; const FldInfo: TDWFldInfo); overload;
begin
  ChildFldCreate(g,FldInfo,FldLsCurVR.Name);
end;

constructor TFldList.Create;
begin
  AddStack('TFldList.Create');
  SetLength(aFld,10);
  DelStack;
end;

procedure TFldList.Fill;
var i: longint;
	p: PFldInf;
  FldInfo: TDWFldInfo;
	af: TVarNmRec;
  procedure DatInfo(const defD: string);
  var j: longint;
    a: TArrStr;
  begin
    AddStack('TFldList.Fill.DatInfo');
    FldInfo.FieldClass:=nil;
    for j:=0 to LsArrDynamic(defD,a,CRLF)-1 do begin
      FldLsCurVR:=DWSToRec(a[j]); FldInfo.r:=FldLsCurVR;
      if TrimUpper(FldLsCurVR.Name)=af[2] then with FldInfo do begin
        FieldClass:=TStringField; Size:=FldLsCurVR.Len;
        Alignment:=taLeftJustify; DisplayLabel:=TransPrim(FldLsCurVR.Prim); Visible:=true;
        case FldLsCurVR.AType of
          dwtFloat: Alignment:=taRightJustify;
          dwtDate: begin
            Size:=10; Alignment:=taCenter;
          end;
          dwtBool: begin
          	FieldClass:=TBooleanField; Size:=0;
          end;
          dwtMemo,dwtSel: Size:=30;
          dwtArray: if not(fldfArray in Options) then FldInfo.FieldClass:=nil;
        end;
        break;
      end;
    end;
    DelStack;
  end;
  function SeekD(const defD: string): boolean;
  begin
    AddStack('TFldList.Fill.SeekD');
    DatInfo(defD); result:=Assigned(FldInfo.FieldClass);
    if result then p:=ChildFldCreate(nil,FldInfo,'');
    DelStack;
  end;
var nmRec: string;
	dw: TDataWin;
	lsRel: TStrStrList;
  lNever: boolean;
  function SeekW(const defD,defW: string): boolean;
  var i,n: longint;
  	ap: TDEPrmStr;
    g: TCustomGet;
    olb: string;
    a: TArrStr;
  begin
    AddStack('TFldList.Fill.SeekW');
    result:=false; lNever:=false; dw.LoadFromStr(defW);
    for i:=0 to LsArrDynamic(dw.Fields,a,CRLF)-1 do begin
    	ap:=DEGetArrParam(a[i]);
      if TrimUpper(ap[deNameRec])=nmRec then if TrimUpper(ap[deNameRecFld])=af[2] then if NameGet(g,ap) then begin
        DatInfo(defD);
        if Assigned(FldInfo.FieldClass) then begin
          olb:=FldInfo.DisplayLabel;
          if not empty(ap[deCaption]) then FldInfo.DisplayLabel:=ap[deCaption];
          FldChildCreated:=false; g.DWFldInfo(ap[deMask],FldInfo);
          if FldChildCreated then result:=true
          else begin
            if Assigned(FldInfo.FieldClass) or (fldfWithoutRelation in Options) then begin
              if (fldfNoSeekPrimGet in Options) then FldInfo.DisplayLabel:=olb
              else if lsRel.Find(ap[deRelation],n) then IncL(FldInfo.DisplayLabel,lsRel.Value[n]);
              p:=ChildFldCreate(g,FldInfo,''); p.DWFldInfo.r.Name:=ap[deMask]; result:=true;
            end
            else begin
              lsRel.IgnoreFindAdd(nmRec+'.'+af[2],FldInfo.DisplayLabel); lNever:=true;
            end;
          end;
          break;
        end;
      end;
    end;
    DelStack;
  end;
var a: TDWFldArrSeek;
	j: longint;
  fl: boolean;
  rdb1: TRecDBDef;
begin
  AddStack('TFldList.Fill');
	lsRel:=TStrStrList.Create(true,1); dw:=TDataWin.aGet;
  try
  	i:=0; LsFld:=Self; piFld:=@i; nFld:=0;
    while i<Count do begin
      Objects[i]:=ObjectNeg;
      if not empty(Strings[i]) then begin
        TrimUpperSelf(Self,i); af:=VarNmToRec(Strings[i]); p:=nil; rdb1:=rdbDef;
        if Assigned(rdb1) then fl:=true else fl:=TRecDBDef.SeekDWPrefix(af[1],rdb1);
        FldLsCurRdb:=rdb1;
        if fl then begin
        	DWRdbSeek(FldLsCurRdb);
          if fldfRDBSeek in Options then rdb1:=FldLsCurRdb;
        end;
        if Assigned(FldLsCurRdb) then begin
          nmRec:=TrimUpper(rdb1.NameRec); FldInfo.r:=FldLsCurVR; rdb1.DWFldSeek(a);
          if Assigned(DWFldSeekProc) then DWFldSeekProc(rdb1,a,DWFldAddProc);
          for j:=low(a) to high(a) do begin
          	if a[j].lWin then begin
            	fl:=SeekW(a[j].defD,a[j].defW);
              if lNever then break;
            end
            else fl:=SeekD(a[j].defD);
            if fl then begin
            	rdb1.DWFldInfo(FldLsCurVR,p.DWFldInfo); break;
            end;
          end;
          Strings[i]:=af[2];
        end;
      end;
      if (IntObj(Self,i)<0) {and not(fldfNilNotSupport in Options)} then Delete(i) else Inc(i);
    end;
  finally
  	lsRel.Free; DataWinFree;
  end;
  DelStack;
end;

function TFldList.GetInf;
begin
  AddStack('TFldList.GetInf');
  result:=@aFld[IntObj(Self,i)];
  DelStack;
end;

class procedure TFldList.BrDop;
var a: TArrArrStr;
	i,i1,j,lm: longint;
  am: variant;
begin
  AddStack('TFldList.BrDop');
  lm:=Length(ardb); SetLength(a,lm); SetLength(adop.ardb,lm); j:=low(ardb); lm:=0;
  for i:=low(ardb) to high(ardb) do Inc(lm,ardb[i].FieldCount);
  am:=VarArrayCreate([1,lm],varVariant); lm:=0;
  for i:=low(a) to high(a) do begin
    adop.ardb[i].rdb:=ardb[j]; adop.ardb[i].NoRead:=false; a[i]:=ardb[j].GetDopInfo;
    for i1:=low(a[i]) to high(a[i]) do q.AddArgList(sC_LIST,a[i][i1]);
    with ardb[j] do for i1:=0 to FieldCount-1 do
      if AnsiStartsStr(sDefMemo,FieldName[i1]) then begin
        q.AddArgList(sC_LIST,TblFldName(FieldName[i1])); Inc(lm); am[lm]:=FieldName[i1];
      end;
    Inc(j);
  end;
  q.SetPart; q.FieldDefs.Update;
  for i:=low(a) to high(a) do with adop.ardb[i] do begin
    SetLength(afdop,Length(a[i]));
    for i1:=low(a[i]) to high(a[i]) do afdop[i1]:=q.CreateField(a[i][i1]);
  end;
  if lm>0 then begin
    VarArrayReDim(am,lm); q.CreateField(am);
  end;
  adop.oclist:=q.Arg[sC_LIST]; adop.fdefcnt:=q.FieldDefs.Count;
  if Assigned(pNoRead) then
    for i:=low(pNoRead^) to high(pNoRead^) do adop.ardb[pNoRead^[i]].NoRead:=true;
  DelStack;
end;

procedure TFldList.BrCreate(const ardb: array of TRecDBDef;
  q: TMulQuery; var adop: TFldArrDop; Opt: TFldBrCreateOptions = []; Proc: TDWFldBrowlProc = nil);
var i: longint;
  rv: TDWVidRec;
  function IfThenDWFldBrowl(Proc: TDWFldBrowlProc): boolean;
  begin
    AddStack('TFldList.BrCreate(view).IfThenDWFldBrowl');
    result:=true;
    if Assigned(Proc) then Proc(ardb[i],rv,result);
    DelStack;
  end;
var j: longint;
  a: TArrStr;
begin
  AddStack('TFldList.BrCreate(view)');
  BeginUpdate; Clear;
  for i:=low(ardb) to high(ardb) do
    for j:=0 to LsArrDynamic(TrimRight(ardb[i].DWTrans),a,CRLF)-1 do begin
      rv:=DWSToRec(a[j]);
      if StrToBoolean(rv.DopPrm) = (fldcNoInverted in Opt) then
        if IfThenDWFldBrowl(DWFldBrowlProc) then if IfThenDWFldBrowl(Proc) then Add(ardb[i].DWVarName(rv.Name));
    end;
  EndUpdate; BrCreate(q,adop,Opt);
  DelStack;
end;

const aFixBeg: TDWFldTypeStr = (sFix,sFix,sFix,sFix,sFixMemo,sFix,sFix,sFixSel,sFixMemo);

procedure TFldList.BrCreate(q: TMulQuery; var adop: TFldArrDop; Opt: TFldBrCreateOptions = []);
var i,j,k,l,l1: longint;
	r: TDWVidRec;
	a: TArrStr;
  OptFill: TFldFillOptions;
  fl: boolean;
  nmf: string;
begin
  AddStack('TFldList.BrCreate');
  l:=adop.fdefcnt; BrFree(q,adop);
  if fldcRDBSeek in Opt then OptFill:=[fldfRDBSeek] else OptFill:=[];
  Fill(nil,OptFill);
  if fldcNoAddClist in Opt then q.Arg['c_list1']:='' else q.Arg[sC_LIST]:=adop.oclist;
  q.SetPart;
  with adop do begin
    for i:=low(ardb) to high(ardb) do with ardb[i] do begin
      SetLength(afix,rdb.FldDef.Count); l1:=0;
      for j:=0 to rdb.FldDef.Count-1 do begin
      	r:=rdb.DWSToRec(j);
        if (r.SvType=dwsFix) and (r.AType<>dwtArray) and (IndexOf(r.Name)>=0) then begin
          CodManyStr(a,r);
          for k:=low(a) to high(a) do begin
            nmf:=rdb.FixSt(aFixBeg[r.AType])+a[k];
            if rdb.IsField(nmf) then begin
              q.AddArgList(IfThen(fldcNoAddClist in Opt,'c_list1',sC_LIST),
                rdb.TblFldName(nmf,not(fldcNoAddClist in Opt)));
              if l1=Length(afix) then SetLength(afix,l1+10);
              afix[l1].r:=r; Inc(l1);
            end;
          end;
        end;
      end;
      SetLength(afix,l1);
    end;
    q.SetPart; q.FieldDefs.Update;
    if fldcNoAddClist in Opt then begin
    	l:=0; q.GetListArg('c_list1',a);
    end;
    for i:=low(ardb) to high(ardb) do with ardb[i] do
      for j:=low(afix) to high(afix) do begin
      	if not(fldcNoAddClist in Opt)
          then afix[j].Fld:=q.FieldDefs[l].CreateField(q.DataSet)
        else if not q.FindField(a[l],afix[j].Fld)
          then afix[j].Fld:=q.FieldDefs.Find(a[l]).CreateField(q.DataSet);
        afix[j].Fld.Visible:=false; Inc(l);
      end;
    if Assigned(LsQry) then fl := LsQry.IndexOf(q)<0 else fl:=true;
    if fl then begin
      ListCreateObj(q,LsQry); ListCreateObj(@adop,LsDop);
      if @q.BeforeOpen<>@TNone.qBeforeOpen then begin
        oBeforeOpen:=q.BeforeOpen; q.BeforeOpen:=TNone.qBeforeOpen;
      end;
    end;
  end;
  DelStack;
end;

function TFldList.BrCreate(i: longint; q: TMulQuery): TField;
var p: PFldInf;
begin
  AddStack('TFldList.BrCreate(f)');
  p:=GetInf(i);
  with p.DWFldInfo do begin
    result:=FieldClass.Create(q.DataSet); result.Size:=Size; result.Alignment:=Alignment;
    result.DisplayLabel:=DelTrim(StrTran(DisplayLabel,UnDelim,' '));
    result.Visible:=Visible;
  end;
  result.FieldName:=p.rdb.DWVarName(Strings[i]); result.Calculated:=true; result.DataSet:=q.DataSet;
  DelStack;
end;

procedure TFldList.BrCreate(q: TMulQuery);
var i: longint;
begin
  i:=Count; SetLength(aField,i);
  for i:=0 to i-1 do aField[i]:=BrCreate(i,q);
end;

procedure TFldList.BrCreate(sb: TStringBrowl; FixFldCnt: longint = 0);
var i,w: longint;
	p: PFldInf;
	inf: TStrBrInfZn;
begin
  AddStack('TFldList.BrCreate(sb)');
  inf:=sb.InfoCol[0]; inf.nmFld:=''; w:=sb.Width;
  with sb.ColZn do begin
    BeginUpdate;
    while Count>FixFldCnt+Self.Count do Delete(Count-1);
    for i:=0 to Self.Count-1 do begin
      p:=GetInf(i);
      if p.DWFldInfo.Visible then begin
        if empty(p.DWFldInfo.DisplayLabel) then begin
          SetLength(inf.aName,1); inf.aName[0]:=p.rdb.DWVarName(Self[i]);
        end
        else LsArrDynamic(p.DWFldInfo.DisplayLabel,inf.aName,UnDelim,lsaSetLen);
        inf.LenData:=p.DWFldInfo.Size;
        inf.Alignment:=p.DWFldInfo.Alignment;
        sb.InfoCol[FixFldCnt]:=inf; Inc(FixFldCnt);
      end;
    end;
    EndUpdate;
  end;
  if sb.Width<>w then MainRebuild(sb);
  DelStack;
end;

class procedure TFldList.BrDopCalc;
var i,j,n: longint;
	s: string;
  v: variant;
begin
  AddStack('TFldList.BrDopCalc');
  with adop do begin
    for i:=low(ardb) to high(ardb) do with ardb[i] do if not NoRead then begin
      s:='';
      rdb.NewRec([newrNoDoNewRec]);
      for j:=low(afdop) to high(afdop) do IncD(s,TrimRight(afdop[j].AsString));
      rdb.Dop_:=s;
      for j:=low(afix) to high(afix) do with afix[j] do if aFixBeg[r.AType]=sFix then
        if rdb.NumFromName(r.Name,n) then begin
          v:=Fld.Value;
          if r.AType=dwtManyStr then begin
            if not empty(v) then rdb.ValueNum[n]:=Trim(rdb.ValueNum[n])+v;
          end
          else begin
            case r.AType of
              dwtDate: IsNil(v,DateEmpty);
              dwtBool: StrToBoolSelf(v);
            end;
            rdb.ValueNum[n]:=v;
          end;
        end;
    end;
  end;
  DelStack;
end;

function TFldList.BrCalc(f: TField; const adop: TFldArrDop; i: longint; onlyResult: boolean=false): variant;
var j,k: longint;
  gk: longword;
  g: TCustomGet;
  p: PFldInf;
  fa: TFldMemoAttr;
begin
  AddStack('TFldList.BrCalc');
{if f.FieldName='МРД_СКР' then begin
f:=f;
end;}
  p:=GetInf(i);
  with p^,DWFldInfo do begin
    if (r.SvType=dwsDyn) and (rdb.DynamicVid>0)
      then result:=DDGetValue(rdb.DynamicVid,Strings[i])
    else if r.AType=dwtArray
      then result:=''
    else if IsDWFldMemo(r.AType,fa) then begin
      result:=''; gk:=0;
      with MulQueryOwner(f.DataSet) do case r.SvType of
        dwsFix: with adop do for j:=low(ardb) to high(ardb) do
          if ardb[j].rdb=rdb then with ardb[j] do begin
            for k:=low(afix) to high(afix) do
              if (afix[k].r.AType=r.AType) and (afix[k].r.dwCod=r.dwCod) then begin
                gk:=afix[k].Fld.AsInteger; break;
              end;
            break;
          end;
        dwsNoFix: if r.AType=dwtMemo then gk:=FieldZN(sDefMemo+r.dwCod);
      end;
      result:=adop.lsm.GetValue(gk,fa);
    end
    else result:=rdb[Strings[i]];
    if NameGet(g,p^) then begin
      FldLsCurVR:=r; g.DWFldValue(rdb,r.Name,result);
      if not onlyResult then f.AsVariant:=result;
    end
    else
      case r.AType of
        dwtFloat:
          if onlyResult then Spacestr0Self(result,r.Len,r.Dec)
          else f.AsString:=SpaceStr0(result,r.Len,r.Dec);
        dwtDate:
          if onlyResult then dtocSelf(result)
          else f.AsString:=dtoc(result);
        dwtBool: if not onlyResult then f.AsBoolean:=result;
      else if not onlyResult then f.AsString:=result;
      end;
  end;
  DelStack;
end;

procedure TFldList.BrCalc(const adop: TFldArrDop);
var i: longint;
begin
  for i:=0 to Count-1 do BrCalc(aField[i],adop,i);
end;

function TFldList.BrCalc(ACol: longint; Opt: TFldBrCalcOpt = []): string;
var p: PFldInf;
  v: variant;
begin
  AddStack('TFldList.BrCalc(sb,col)');
  result:='';
  if Assigned(Self) then begin
    if not(fldbrWithNoVisible in Opt) then if StrBrInRange(ACol) then Include(Opt,fldbrWithNoVisible);
    if fldbrWithNoVisible in Opt then begin
      p:=GetInf(ACol); FldLsCurVR:=p.DWFldInfo.r;
      if FldLsCurVR.SvType=dwsDyn
      then v:=DDGetValue(p.rdb.DynamicVid,Strings[ACol])
      else v:=p.rdb.DWRdbSeek[Strings[ACol]];
      result:=FldBrCalc(v,p,fldbrBoolRus in Opt);
    end;
  end;
  DelStack;
end;

class procedure TFldList.BrFree(q: TMulQuery; var adop: TFldArrDop);
var l: longint;
begin
	AddStack('TFldList.BrFree');
  l:=adop.fdefcnt;
  while q.FieldDefs.Count>l do begin
  	q.FindField(q.FieldDefs[l].Name).Free; q.FieldDefs.Delete(l);
  end;
  if @q.BeforeOpen=@TNone.qBeforeOpen
  then q.BeforeOpen:=adop.oBeforeOpen;
  FreeAndNil(adop.lsm); ListDestroyObj(q,LsQry); ListDestroyObj(@adop,LsDop);
  DelStack;
end;

procedure TFldList.BrFree;
var i: longint;
begin
  for i:=0 to Count-1 do aField[i].Free;
end;

function TFldList.StrBrInRange;
var j: longint;
begin
  AddStack('TFldList.StrBrInRange');
  result:=false;
  for j:=0 to Count-1 do if GetInf(j).DWFldInfo.Visible then
    if i=0 then begin
      i:=j; result:=true; break;
    end
    else Dec(i);
  DelStack;
end;

procedure TFldList.BrBool;
var i: longint;
begin
  AddStack('TFldList.BrBool');
  if not(gdFixed in State) and Assigned(Self) then begin
  	i:=ACol-FixFldCnt;
    if StrBrInRange(i) then
    	if GetInf(i).DWFldInfo.FieldClass=TBooleanField then sb.bmCheckPaint(ACol,ARow,bTrue);
  end;
  DelStack;
end;

{ TNone }
class procedure TNone.qBeforeOpen;
var q: TMulQuery;
  a: TArrRecDBDef;
  i: longint;
begin
  AddStack('TNone.qBeforeOpen');
  q:=MulQueryOwner(DataSet);
  with PFldArrDop(LsDop[LsQry.IndexOf(q)])^ do begin
    SetLength(a,Length(ardb));
    for i:=low(ardb) to high(ardb) do a[i]:=ardb[i].rdb;
    FreeAndNil(lsm); lsm:=TMemGkList.Create(a,q);
    IfThenDataSet(oBeforeOpen,DataSet);
  end;
  DelStack;
end;

class procedure TNone.PrimDWFldSeek;
begin
  AddStack('TNone.PrimDWFldSeek');
  prAdd(a,rdb.FldDef.Text);
  DelStack;
end;

{ TVarChkLogCompare }
class function TVarChkLogCompare.ListCreate;
var ls: TStrStrList;
  i,j: longint;
  vr: varrec;
  r: TVarNmRec;
  rdb: TRecDBDef;
  a: TArrStr;
begin
  AddStack('TVarChkLogCompare.ListCreate');
  ls:=TStrStrList.Create(false); result:=ls; ls.NoDelObj:=true; ls.Init(StrTran(TrimRight(Value),',',CRLF));
  i:=0;
  while i<ls.Count do begin
    vr.name:=''; r:=VarNmToRec(ls[i]);
    if TRecDBDef.SeekDWPrefix(r[1],rdb) then
      for j:=0 to LsArrDynamic(rdb.DWTrans,a,CRLF)-1 do with DWSToRec(a[j]) do if Name=r[2] then begin
        vr.name:=Name; vr.hint:=Prim; break;
      end;
    if vr.name='' then vr:=TInter.SeekVar(ls[i]);
    if vr.name='' then ls.Delete(i)
    else begin
      ls.Value[i]:=IfThen(vr.hint='',ls[i],vr.hint); Inc(i);
    end;
  end;
  DelStack;
end;

class procedure TVarChkLogCompare.GetItem;
begin
  AddStack('TVarChkLogCompare.GetItem');
  inherited GetItem(Prm,pv,lso,lsn,no,nn,tp);
  if tp=clogPrn then Prm.val:=TStrStrList(lsn).Value[nn];
  DelStack;
end;

procedure DWPnEdHelp(Sender: TObject; var Message: TMessage);
var i: longint;
begin
  AddStack('FDWPrm.DWPnEdHelp');
  with TWMHelpFill(Message) do if Oper=hlpVar then begin
    pVar^:=null;
    if Assigned(LsDWWin) then for i:=0 to LsDWWin.Count-1 do with TDWWin(LsDWWin[i]) do
      if Active and (de.PanelEdit=Sender) then AddFromSelf(pVar^,HelpProc);
    ResVar := MyVarType(pVar^)=varArray;
  end;
  DelStack;
end;

function PFldInfGet(const nmf: string): PFldInf;
var ls: TFldList;
begin
  AddStack('FDWPrm.PFldInfGet');
  result:=nil; ls:=TFldList.Create;
  try
    ls.Text:=nmf; ls.Fill;
    if ls.Count>0 then begin
      New(result); result^:=ls.GetInf(0)^;
    end;
  finally
    ls.Free;
  end;
  DelStack;
end;

function BrEditProc(Sender: TObject; lApp: boolean; const Capt: TCaption;
  const glkey,nmfCode,dwValue,dwNameWnd,dwNameScr: string; var Modified: boolean): boolean;
begin
  AddStack('FDWPrm.BrEditProc');
  result := Sender is TDWWin;
  if result then Modified:=TDWWin(Sender).Execute(dwValue,dwNameWnd,[],dwNameScr,[],Capt).Saved;
  DelStack;
end;

function RDBLogPrimOper(var ls: TStringList; Oper: TRDBLogPrimOper; const av: array of variant): string;
var j: longint;
  rdb: TRecDBDef;
begin
  AddStack('FDWPrm.RDBLogPrimOper');
  case Oper of
    rdblgCreate: begin
      rdb:=PointerVar(av[0]); ls:=TFldList.Create; ls.BeginUpdate;
      with rdb do begin
        j:=FldDef.Count; ls.Capacity:=j;
        for j:=0 to j-1 do ls.Add(DWVarName(DWSToRec(j).Name));
      end;
      TFldList(ls).Fill(TNone.PrimDWFldSeek,[],rdb); ls.Sorted:=true; ls.EndUpdate;
    end;
    rdblgGetName: StringVar(av[0])^:=TFldList(ls).GetInf(av[1]).DWFldInfo.DisplayLabel;
    rdblgGetVal: StringVar(av[0])^:=TFldList(ls).BrCalc(av[1],[fldbrBoolRus,fldbrWithNoVisible]);
  end;
  DelStack;
end;

procedure HelpTblProc(const Name: string; var result: variant);
  function sConst(const v,c: string): string;
  begin
    AddStack('FDWPrm.HelpTblProc.sConst');
    result:='"'+v+'"';
    if c=''
    then HelpBoldStrSelf(result)
    else HelpBoldStrSelf(result,c,hlnkVar);
    DelStack;
  end;
const avgfo: TGFPropObjStr =
  (svGF+'\'+svConst+'\'+svGFAlgm
  ,svGF+'\'+svConst+'\'+svGFPin
  ,svConst+'\Цвета'
  ,svGF+'\'+svConst+'\'+svGFVO
  ,''
  ,''
  ,''
  ,''
  ,''
  ,''
  ,svGF+'\'+svConst+'\'+svGFTypeObj
  ,''
  );
  aAlgmNm: TAlgmStr = ('слева','справа','в центре');
var i: TGFPropObjList;
  tp: TGFPropLineType;
  pl: TGFPropLineList;
  j: longint;
  sset: string;
  algm: TAlignment;
begin
  AddStack('FDWPrm.HelpTblProc');
  if Name=''
    then result:=VarArrayOf(
      [VarArrayOf(['ОБ','Свойства объекта формы'])
      ,VarArrayOf(['ДАНРАЗМ','Размещение определяемого данного'])
      ])
  else if Name='ОБ' then begin
    sset:=HelpBoldStr('*',SCE_OURLIB_HELP_PART); j:=0;
    result:=VarArrayCreate([j,Length(aGFPropObj)+Length(aGFPropLineType)*Length(aGFPropLine)+2],varVariant);
    result[j]:=ArrStrToVar([HelpBoldStr('Переменная',SCE_OURLIB_HELP_HEAD),HelpBoldStr('Тип',SCE_OURLIB_HELP_HEAD),'',HelpBoldStr('Описание',SCE_OURLIB_HELP_HEAD)]);
    for i:=low(aGFPropObj) to high(aGFPropObj) do with aGFPropObj[i] do begin
      Inc(j); result[j]:=ArrStrToVar([sConst(v,avgfo[i]),InterEdStrTypes(t),IfThen(i in GFPropCanSet,sset),nm]);
    end;
    for tp:=low(aGFPropLineType) to high(aGFPropLineType) do
      for pl:=low(aGFPropLine) to high(aGFPropLine) do begin
        Inc(j); result[j]:=ArrStrToVar([sConst(aGFPropLineType[tp,1]+aGFPropLine[pl],IfThen(tp=vgflnColor,avgfo[vgfoColor])),InterEdStrTypes('I'),sset,GFPropLineCapt(tp,pl)]);
      end;
    Inc(j); result[j]:=ArrStrToVar(['']);
    Inc(j); result[j]:=ArrStrToVar(['','',sset,'- доступно для присвоения']);
  end
  else if Name='ДАНРАЗМ' then begin
    result:=VarArrayCreate([byte(low(aAlgm)),byte(high(aAlgm))],varVariant);
    for algm:=low(aAlgm) to high(aAlgm) do result[aAlgm[algm]]:=aAlgmNm[algm];
  end
  ;DelStack;
end;

procedure Init;
var a: TDEPrmStr;
  c: TDECharCase;
begin
	AddStack('FDWPrm.initialization');
  MyTypes.DataWinCreate:=DataWinCreate; MyTypes.DataWinFree:=DataWinFree;
  MyTypes.DataWinSearchIdent:=DataWinSearchIdent; MyTypes.DataWinReplaceIdent:=DataWinReplaceIdent;
  MyTypes.DataWinFields:=DataWinFields;
  PnlEdit.DWPnEdHelp:=DWPnEdHelp;
  FFldEdit.ChildFldCreate:=ChildFldCreate;
  RecDB.PFldInfGet:=PFldInfGet; RecDB.FldBrCalc:=FldBrCalc; RecDB.RDBLogPrimOper:=RDBLogPrimOper;
  SetLength(aDataWin,1); InitArr(a);
  TSimpleGet.AssignGetClass(a); a[deCharCase]:=IntToStr(1+byte(ecNormal));
  a[deAutoSel]:=bTrue; a[deNoReadOnly]:=bTrue; sDWFldDef:=DESetArrParam(a);

	with TInter do begin
    SetFunction('Окна ввода',500);
    SetFunction('ВВОД_ПАРАМ','Устанавливает параметры вводимого поля',
      ['Поле: целое|строка|массив~НеИспольз: пусто','[Наименование: строка|массив]~[Страница: целое = 0]',
      '[ВидВвода: строка|логическое]~[Заголовок: строка]','[НаимВвода: строка]~[Сорт: целое]',
      '[ПарамВвода: строка|массив]~[Невидимая: логическое]','[МаксДлина: целое]','[ВидПреобр: целое]',
      '[Выдел: логическое]','[Пароль: логическое]','[Редакт: логическое]','[НевидНеред: логическое]',
      '[НовКол: логическое]','[ПодскНаим: строка]','[ПодскВвод: строка]','[Ширина: целое]',
      '[Высота: целое]','[Невидимое: логическое]','[НаимСправа: логическое]','[ПробСлева: логическое]',
      '[Все: логическое = '+vFalse+']'],
      ['NCAU','CANU','CLU','CNU','CALU','NU','NU','LU','LU','LU','LU','LU','CU','CU','NU','NU','LU','LU','LU','LU'],
      c_dwparam,dwprPrm,501,'A');
    SetFunction('ВВОД_ПЕРЕСТР','Перестроить окно ввода',c_rebuild,null,502);
    SetFunction('ВВОД_ИМЯ','Изменяет наименование данного для вводимого поля',
      ['Поле: целое|строка','[Имя: строка]'],['NC','CU'],c_dwparam,dwprName,503,'C');
    SetFunction('ВВОД_СПИСОК','Список полей окна ввода',['[Страница: целое = 0]'],['NU'],
      c_list,null,504,'A');
    SetFunction('ВВОД_ЗАКРЫТЬ','Закрыть окно ввода',['[Сохранить: логическое = '+vFalse+']'],['LU'],
      c_close,null,505);
    SetFunction('ВВОД_ОБЪЕКТ','Изменить свойства объекта формы в окне ввода',
      ['Идент: строка','Свойство: строка~Свойства: массив','[Значение: целое]~[Значения: массив]'],
      ['C','CA','IAU'],c_gfobj,longint(@GFObjPropProc),506,'ILCAU');
    SetFunction('ВВОД_ШРИФТ','Установить шрифт "подсказка" для указанного шрифта в окне ввода по форме',
      ['[Шрифт: целое = 0]'],['NU'],c_gffont,null);
    SetFunction('ВВОД_ПАРАМ_ДР','Параметры вводимого поля из описания доступных окон',
      ['Поле: строка'],['C'],c_dwparam,dwprOther,507,'A');
    SetFunction('ВВОД_ОТМ_АКТ','Активность пунктов полей для видов ввода "Отметка значений" и "Выбор значений"',
      ['Поле: целое|строка','НомерПункта: целое','[Актив: логическое]'],['NC','N','LU'],
      c_ChkEnabled,null,508,'L');
    SetFunction('ВВОД_ОКНО','Вывести дополнительное окно ввода',
      ['Код: строка','[Поля: массив]','[Знач: массив]','[ПодскСохр: строка]'],['C','AU','AU','CU'],c_dwnd,null,0,'AU');
    SetFunction('ВВОД_СТАРЗН','Значение вводимого поля до редактирования',['Поле: целое|строка'],['NC'],c_oldval,null);
    SetFunction('DWFldHelp','',['Поле: целое|строка','РаздПомощи: целое'],['NC','N'],c_help,null);

    SetFunction('Данные',900);
    SetFunction('ДАН_ЗНАЧЕНИЕ','Значение по наименованию данного',
      ['Наим: строка','[Знач: число|строка|дата|логическое]'],['C','NCDLU'],c_fld,pfValue,901,'FCDL');
    SetFunction('ДАН_ПАРАМ','Параметры определяемого данного',
      ['Наим: строка|массив'],['CA'],c_fld,pfParam,902,'A');
    SetFunction('ДАН_ПРИМЕЧ','Примечание по наименованию данного',
      ['Наим: строка'],['C'],c_fld,pfPrim,903,'C');
    SetFunction('ДАН_ПОДСКАЗКА','Подсказка определяемого данного',
      ['Наим: строка'],['C'],c_fld,pfLabel,904,'C');
    SetFunction('ДАН_ЗНАЧСТР','Строковое значение определяемого данного',
      ['Наим: строка','[Знач: число|строка|дата|логическое]'],['C','NCDLU'],c_fld,pfValStr,905,'C');
    SetFunction('ДАН_РАЗМЕСТ','Размещение определяемого данного(слева,справа,в центре)',
      ['Наим: строка','[Знач: число|строка|дата|логическое]'],['C','NCDLU'],c_fld,pfAligm,906,'I');
    SetFunction('ДАН_СУММ','Возможность суммирования значений определяемого данного',
      ['Наим: строка','[Знач: число|строка|дата|логическое]'],['C','NCDLU'],c_fld,pfSumm,907,'L');
    SetFunction('ДАН_НАИМВВОД','Наименование вида ввода определяемого данного',
      ['Наим: строка'],['C'],c_fld,pfVName,908,'C');
    SetFunction('ДАН_ЕСТЬ','Признак наличия определяемого данного',
      ['Наим: строка'],['C'],c_fld,pfIs,910,'L');
    SetFunction('ДАН_ЗНАЧКОД','Значение определяемого данного с указанным кодом',
      ['Префикс: строка','Код: строка','[Знач: число|строка|логическое|дата]',
      '[ТипДан: целое|логическое = 0]'],
      ['C','C','NCLDU','NLU'],c_cod,0,909,'FCDL');
    SetFunction('ДАН_СПИСОК','Список данных с указанным началом наименований',
      ['Начало: строка'],['C'],c_arr,0,0,'A');
  end;
  for c:=low(aDeToEdit) to high(aDeToEdit) do aEditToDe[aDeToEdit[c]]:=c;
  AddFrom(BrEditProc);
  AddFrom(HelpTblProc);
  DelStack;
end;

procedure Final;
var i: longint;
begin
  AddStack('FDWPrm.finalization');
  for i:=low(aDataWin) to high(aDataWin) do aDataWin[i].Free;
  DelStack;
end;

initialization
  Init;
finalization
  Final;
end.
