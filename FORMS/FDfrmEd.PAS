unit FDFrmEd;

interface

{$I LIBTEST}
uses
  Windows, Messages, Classes, Controls, Forms, Menus, ExtCtrls, ComCtrls,
  MyTypes, FDWPrm, RecDB, ModelGet, FrmEdt, KeyMenu, PnlEdit, Keylb, Fpanel, FFldedit, ButGet,
    RbPage, RbScroll, Inter;

type
  TDfrmEdOper = (dfeChange,dfeEdCreate,dfeFmlEdBefore,dfeFmlEdAfter,dfeEval);
  TDfrmEdProc = procedure(oper: TDfrmEdOper; const av: array of variant);

  TDfrmEvalType = (dfeCalc,dfeHelp);

  TDFrmEd = class(TFormEdt)
    FrmGet: TButFormGet;
    RbPage1: TRbPage;
    tsOsn: TTabSheet;
    tsDat: TTabSheet;
    pnDW: TRbPanel;
    pnscOsn: TRbPanel;
    scrlOsn: TRbScrollBox;
    pnOsn: TRbPanel;
    pnCod: TRbPanel;
    EName: TFldEdit;
    EModel: TFldEdit;
    RbPanel2: TRbPanel;
    ENf: TFldEdit;
    EKf: TFldEdit;
    pn2: TRbPanel;
    EFrm: TFldEdit;
    DWGet: TButGet;
    tsHelp: TTabSheet;
    pnHelp: TRbPanel;
    EHelp: TFldEdit;
    function EKfCheck(Sender: TObject): Boolean;
    procedure FrmGetBeforeClick(Sender: TObject);
    procedure FrmGetAfterClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function PanelEdit1Valid(Sender: TObject): Boolean;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function ENfCheck(Sender: TObject): Boolean;
    procedure ENfExit(Sender: TObject);
    procedure DWGetPaint(Sender: TObject; const ARect: TRect;
      const Text: String);
    function DWGetClick(Sender: TObject; lEval: Boolean): String;
  private
    { Private declarations }
    oDef: string;
    dw: TDataWin;
    procedure FrmGetEnter(Sender: TObject);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
		procedure WMHelpFill(var Message: TMessage); message WM_HELPFILL;
  public
    { Public declarations }
    lCopy: boolean;
    class procedure Init(DfrmDWCanDel: TDWCanDelEvent; DfrmDWCngName: TDWCngNameEvent;
      Proc: TDfrmEdProc = nil; DfrmLoadOnlyDat: boolean = false);
		class procedure AddProcMod(Proc: TProcNone);
		class procedure Modify;
    class function ArrToValueTypes(const av: variant): string;
    class procedure ClearCod(Destroying: boolean);
    class procedure PrmEd(dw: TDWWin);
  end;

const DfrmNameRec = 'Dfrm';
  aDfrmFld : array[TDfrmEvalType] of record
    f,nm: string;
  end =
    ((f:fFRM        ; nm:'формула вычисления')
    ,(f:sMemo+'HELP'; nm:'формула заполнения страницы помощи')
    );

var
  DFrmEd: TDFrmEd;
  Dfrm: TRecDBDef;
  lDfrmKF: byte;
  nPrmEd: longint;

procedure DfrmHelpEval(const cod: string; var pArr: PHelpArr; rDfrm: TRecDBDef = nil);
function c_dfrm(const ccod: string; const cav: array of variant; tp: TDfrmEvalType = dfeCalc; rDfrm: TRecDBDef = nil): variant; overload;
function c_dfrmprm(const ccod: string; const Prm: variant): variant; overload;

implementation

{$R *.DFM}

uses SysUtils,Variants,StrUtils,DB,
  My_pr,FDWVid,FDWFld,FrmPswd,RecVal,FHelpLs,FSchemDM;

type
  TNone = class
  private
    class procedure pnButResize(Sender: TObject);
    class procedure DfrmDWArrSeek(Sender: TObject; var result: TDWArrSeekRec);
    class function DfrmDWRdbSeek(Sender: TObject): TRecDBDef;
    class procedure DfrmDWTrans(Sender: TObject; var sTrans: String; lSave: Boolean);
    class procedure DfrmDWVarValid(Sender: TObject; Proc: TProcVarValid;
      const r: TDWVidRec; var result: Boolean);
    class function DfrmKodCheck(Sender: TRecDB; const NmFld,Flt: string;
      Opt: TKodCheckOptions = []): boolean;
    class procedure DfrmNewRec(Sender: TRecDB; lcopy: boolean; const gKey: string);
    class procedure mgHelp(Sender: TObject; var ht: THelpTbl);
    class procedure mgSave(Sender: TObject; FromEdit: Boolean);
    class procedure mgLoad(Sender: TObject; FromEdit: Boolean);
    class procedure mgInterDef(Sender: TObject; Oper: TModelInterDefOper;
      const av: array of Variant; var result: Variant);
    class procedure FrmMdProcKey(key: longint; tw: TWinControl);
  end;

var FProc: TDfrmEdProc;
  FDfrmLoadOnlyDat: boolean;
  aProcMod: TArrProcNone;
  lsDfrm,slCacheDfrm: TStringList;
  aInter: TArrInter;
  nInter: longint;
  Dfrm0: TRecDBDef;
  aCacheDfrm: array of record
    dfcInt: TInter;
    dfcIntSz: longint;
    dfcIntHash: longword;
  end;

const FuncDfrm = 'ФОРМУЛА';
  fFRMMD = sMemo+'FRMMD';

function DfrmKF(const cod: variant): string;
begin
  AddStack('FDfrmEd.DfrmKF');
  result:=TrimUpper(LeftStr(cod,lDfrmKF));
  DelStack;
end;

procedure Proc(oper: TDfrmEdOper; const av: array of variant);
begin
  AddStack('FDfrmEd.Proc');
  if Assigned(FProc) then FProc(oper,av);
  if oper=dfeChange then TDfrmEd.ClearCod(false);
  DelStack;
end;

procedure FProcMod;
begin
  AddStack('FDfrmEd.FProcMod');
  Proc(dfeChange,[]);
  DelStack;
end;

function lsDfrmFind(const ccod: variant; var cod: string; var i: longint): boolean;
var oDfrm: TRecDBDef;
	fKF,fMEM_D: TField;
  lsm: TMemGkList;
begin
  AddStack('FDfrmEd.lsDfrmFind');
  cod:=DfrmKF(ccod);
  if not Assigned(lsDfrm) then with ProgPswd.GetQuery do begin
    PartSelect(tDFRM,[]); lsm:=TMemGkList.Create(Dfrm,nil,nil,nil,true,mgdAll,tDFRM+'.'+DWMem); oDfrm:=Dfrm;
    try
      lsDfrm:=SortStrListCreate; fKF:=FindField(fDfrmKF); fMEM_D:=FindField(DWMem);
      while not Eof do begin
        if not IgnoreSlFindAdd(lsDfrm,TrimRight(fKF.AsString),i) then begin
          if empty(fMEM_D.AsInteger) and FDfrmLoadOnlyDat then Dfrm:=nil
          else begin
            Dfrm:=TRecDBDef.Create(Application.MainForm);
            with Dfrm do begin
              Connection:=DBMain; DWName:=oDfrm.DWName; DWPrefix:=oDfrm.DWPrefix;
              NameDB:=oDfrm.NameDB; OnDWTrans:=oDfrm.OnDWTrans; OnDWRdbSeek:=oDfrm.OnDWRdbSeek;
              OpenRec; lsm.FRdb:=Dfrm; lsm.GetFromQuery; Dfrm.InitFldDef; lsm.GetFromQuery;
            end;
          end;
          lsDfrm.Objects[i]:=Dfrm;
        end;
        Next;
      end;
    finally
      Dfrm:=oDfrm; ProgPswd.FreeQuery;
    end;
  end;
  result:=lsDfrm.Find(cod,i);
  DelStack;
end;

function c_dfrm(const ccod: string; const cav: array of variant; tp: TDfrmEvalType = dfeCalc; rDfrm: TRecDBDef = nil): variant;
var i: longint;
	oDfrm: TRecDBDef;
  a: TArrVarRec;
  EvalError: TInterError;
  cod: string;
  av: TArrVar;
begin
  AddStack('FDfrmEd.c_dfrm');
  result:=0;
  if lsDfrmFind(ccod,cod,i) then begin
    oDfrm:=Dfrm; EvalError:=E_NO;
    try
      if PointerObj(lsDfrm,i,pointer(Dfrm)) then begin
        TInter.GetVar(a,'$'+Dfrm.DWPrefix); TDWPrm.VarCreate(Dfrm);
      end;
      CopyFromVArr(av,cav); Proc(dfeEval,[longint(@result),cod,longint(@av),tp,longint(rDfrm),longint(@EvalError)]);
      if Assigned(Dfrm) then begin
        TDWPrm.VarFree(Dfrm);
        for i:=low(a) to high(a) do with a[i] do TInter.SetVar(name,hint,proc,index,types,ReadOnly);
      end;
    finally
      Dfrm:=oDfrm;
    end;
    if EvalError<>E_NO then raise EInterAnyError.Create;
  end
  else raise EInterAnyError.Create('Отсутствует дополнительная формула "'+cod+'"',FuncDfrm);
  DelStack;
end;

procedure DfrmHelpEval;
var ost: longint;
begin
  ost:=AddStack('FDfrmEd.DfrmHelpEval');
  try
    HelpVar2Arr(c_dfrm(cod,[],dfeHelp,rDfrm),pArr);
  except
    on EInterAnyError do SetStack(ost);
  end;
  DelStack;
end;

// ФОРМУЛА
function c_dfrm(var av: array of variant): variant; overload;
var ap: TArrVar;
begin
	AddStack('FDfrmEd.c_dfrm: '+av[1]);
  ShiftArg(ap,av,1); result:=c_dfrm(av[1],ap);
  DelStack;
end;

// ФОРМУЛА_ЕСТЬ
function c_is(var av: array of variant): variant;
var i: longint;
  cod: string;
begin
	AddStack('FDfrmEd.c_is');
  result:=lsDfrmFind(av[1],cod,i);
  DelStack;
end;

// ФОРМУЛА_РЕД
function c_ed(var av: array of variant): variant;
var s: string;
begin
	AddStack('FDfrmEd.c_ed');
  result:=null;
  if Dfrm.Seek(Dfrm.TblFldName(fDfrmKF)+'='+QQs(DfrmKF(av[1]))) then if LockEdConf then
    try
      TDWPrm.VarCreate(Dfrm); s:=Dfrm[fFRM];
      if EdTextExec('Дополнительная формула: '+Trim(Dfrm[fDfrmKF])+'. '+Trim(Dfrm[fNAME]),
      s,sMDKey,TNone.FrmMdProcKey,[],edtpInter) then begin
        Dfrm[fFRM]:=s; Dfrm.UpdateRec(true); Proc(dfeChange,[]);
      end;
      TDWPrm.VarFree(Dfrm);
    finally
      UnLockEdConf;
    end;
  DelStack;
end;

// ФОРМУЛА_ПРМРЕД
function c_prmed(var av: array of variant): variant;
var dw: TDWWin;
  svi: TRDBSaveInf;
begin
	AddStack('FDfrmEd.c_prmed');
  result:=null; TRecDBDef.SaveInf(Dfrm,svi); Inc(nPrmEd);
  try
    if Dfrm.Seek(Dfrm.TblFldName(fDfrmKF)+'='+QQs(DfrmKF(av[1]))) then begin
      dw:=TDWWin.Create;
      try
        TDfrmEd.PrmEd(dw);
      finally
        dw.Free;
      end;
    end;
  finally
    Dec(nPrmEd); TRecDB.RestInf(svi);
    if nPrmEd>0 then TDWPrm.VarCreate(Dfrm); 
  end;
  DelStack;
end;

// ФОРМУЛА_СТР
function c_str(var av: array of variant): variant;
  function NumBig(n: byte): boolean;
  begin
  	AddStack('FDfrmEd.c_str.NumBig');
    nInter:=av[n]-1;
    if nInter<0 then raise EInterAnyError.CreateFmt('Параметр %d должен быть больше 0',[n]);
    result := nInter>high(aInter);
    DelStack;
  end;
var ap: TArrVar;
begin
	AddStack('FDfrmEd.c_str');
  if MyVarType(av[1])=varString then
    if MyVarType(av[2])=varString then begin
      ShiftArg(ap,av,3);
      if not EvalStringsChk(result,ap,av[1],av[2],TDFrmEd.ArrToValueTypes(av[3]))
      then raise EInterAnyError.Create;
    end
    else begin
      if NumBig(2) then SetLength(aInter,nInter+1);
      if not Assigned(aInter[nInter]) then aInter[nInter]:=TInter.Create('');
      aInter[nInter].SetProg(av[1]);
    end
  else begin
    if NumBig(1) or not Assigned(aInter[nInter]) then raise EInterAnyError.CreateFmt(
      'Не определён элемент %d массива формул',[nInter+1]);
    if MyVarType(av[2])=varString then begin
      ShiftArg(ap,av,3);
      with aInter[nInter] do begin
        value_types:=TDFrmEd.ArrToValueTypes(av[3]); name:=av[2];
        if not EvalChk(result,ap) then raise EInterAnyError.Create;
      end;
    end
    else FreeAndNil(aInter[nInter]);
  end;
  DelStack;
end;

// ФОРМУЛА_ПАРАМ
function c_dfrmprm(const ccod: string; const Prm: variant): variant; 
var i,l,h: longint;
	oDfrm: TRecDBDef;
  cod: string;
  fl: boolean;
begin
  AddStack('FDfrmEd.c_dfrmprm');
  result:=null;
  if lsDfrmFind(ccod,cod,i) then begin
    if Assigned(Dfrm) then fl := Dfrm.NameRec=DfrmNameRec else fl:=true;
    oDfrm:=Dfrm;
    try
      if PointerObj(lsDfrm,i,pointer(Dfrm)) then TDWPrm.VarCreate(Dfrm);
      if MyVarType(Prm)=varArray then begin
        l:=VarArrayLowBound(Prm,1); h:=VarArrayHighBound(Prm,1); result:=VarArrayCreate([l,h],varVariant);
        for i:=l to h do result[i]:=TInter.GetVarValue(Prm[i]);
      end
      else result:=TInter.GetVarValue(Prm);
      if fl and Assigned(Dfrm) then TDWPrm.VarFree(Dfrm);
    finally
      Dfrm:=oDfrm;
    end;
    if not fl then TDWPrm.VarCreate(Dfrm);
  end;
  DelStack;
end;

function c_dfrmprm(var av: array of variant): variant; overload;
begin
  result:=c_dfrmprm(av[1],av[2]);
end;

procedure AddPrnHead;
begin
  AddStack('FDFrmEd.AddPrnHead');
  My_pr.AddPrnHead('Дополнительная формула '+Trim(Dfrm[fDfrmKF])+'. '+Dfrm[fNAME]);
  DelStack;
end;

function PrVal(i: longint): boolean;
begin
	AddStack('FDfrmEd.PrVal');
  result:=not Dfrm.IsFldFix(i);
  DelStack;
end;

function CngDat(const oDef: string): boolean;
var a: TArrFldVal;
begin
  AddStack('FDFrmEd.CngDat');
  if Dfrm.RecNo=0 then begin
    result:=true; Dfrm.GetAFieldValue(a); Dfrm.InitFldDef(dwdefGotoRec);
    if DFrmEd.lCopy then Dfrm.SetAFieldValue(a) else Dfrm.SetDefValues;
  end
  else begin
    Dfrm.GetAFieldValue(a,setDBReal,PrVal);
    result:=ChangeDat(Dfrm,oDef,Dfrm[DWMem],Dfrm.TblFldName(fDfrmKF)+'='+QQs(Dfrm[fDfrmKF]));
    Dfrm.SetAFieldValue(a);
  end;
  DelStack;
end;

{ TDFrmEd }
procedure TDFrmEd.FormCreate(Sender: TObject);
const aName: array[TDWPostList] of string = ('pnDat','pnWin');
  aprc: TDWPostPrc = (40,100);
var p: TDWPostList;
  pn: TRbPanel;
begin
	AddStack('TDFrmEd.FormCreate',Self);
  if not Dfrm.IsField(sMemo+'HELP') then FreeAndNil(tsHelp)
  else begin
    FrmGet.OnEnter:=FrmGetEnter; EHelp.HelpContext:=HelpFromHelp; FrmGet.OnHelp:=WMHelpFill;
  end;
  dw:=TDataWin.Create;
  for p:=low(aDWPost) to high(aDWPost) do begin
    pn:=TRbPanel.Create(Self);
    with pn do begin
      Parent:=pnDW; Name:=aName[p]; ProcentWnd:=aprc[p]; SortObj:=false; BevelOuter:=bvNone;
      with TFldEdit.Create(Self) do begin
        Parent:=pn; NameRec:=DfrmNameRec; NameRecFld:=DWMem(p); AssignGet(DWGet);
        Mask:=ButPrm2Mask(aDWPost[p].nm); IncOptions([],[ogAutoSize]);
      end;
      OnResize:=TNone.pnButResize;
    end;
  end;
  Proc(dfeEdCreate,[]);
  inherited;
  FrmGet.NmProc.Text:=sMDKey; FrmGet.OnProcKey:=TNone.FrmMdProcKey;
  DelStack;
end;

procedure TDFrmEd.FormDestroy(Sender: TObject);
begin
	AddStack('TDFrmEd.FormDestroy',Self);
  inherited;
	dw.Free;
  DelStack;
end;

procedure TDFrmEd.FormShow(Sender: TObject);
begin
	AddStack('TDFrmEd.FormShow',Self);
  EKf.SetReadOnly(Dfrm.RecNo<>0);
  inherited;
  oDef:=Dfrm[DWMem];
  DelStack;
end;

procedure TDFrmEd.ENfExit(Sender: TObject);
begin
	AddStack('TDFrmEd.ENfExit',Self);
  SpaceStrSelf(Sender);
  DelStack;
end;

function TDFrmEd.ENfCheck(Sender: TObject): Boolean;
begin
	AddStack('TDFrmEd.ENfCheck',Self);
	result:=KodCheck(Sender,'','Дополнительная формула с таким номером уже есть.');
  DelStack;
end;

function TDFrmEd.EKfCheck(Sender: TObject): Boolean;
begin
	AddStack('TDFrmEd.EKfCheck',Self);
	result:=KodCheck(Sender,'','',[chkNoEmpty]);
  DelStack;
end;

procedure TDFrmEd.FrmGetEnter;
begin
  AddStack('TDFrmEd.FrmGetEnter',Self);
  FrmGet.EditType:=iif(Sender=EHelp,edtpHelp,edtpInter);
  DelStack;
end;

procedure TDFrmEd.FrmGetBeforeClick(Sender: TObject);
begin
	AddStack('TDFrmEd.FrmGetBeforeClick',Self);
  TDWPrm.VarCreate(Dfrm); Proc(dfeFmlEdBefore,[]); AddPrnHead;
  DelStack;
end;

procedure TDFrmEd.FrmGetAfterClick(Sender: TObject);
begin
	AddStack('TDFrmEd.FrmGetAfterClick',Self);
	TDWPrm.VarFree(Dfrm); DelPrnHead; Proc(dfeFmlEdAfter,[]);
  DelStack;
end;

procedure TDFrmEd.DWGetPaint(Sender: TObject; const ARect: TRect;
  const Text: String);
var tf: TFldEdit;
begin
  AddStack('TDFrmEd.DWGetPaint',Self);
  tf:=pointer(Sender);
  if tf.NameRecFld=DWMem
  then TDWVid.ButGetPaint(Sender,ARect,Dfrm,[dwbPrefix,dwbShortType,dwbBrackets])
  else dw.ButGetPaint(Sender,ARect,tf.Value);
  DelStack;
end;

function TDFrmEd.DWGetClick(Sender: TObject; lEval: Boolean): String;
var tf: TFldEdit;
  s: string;
  fl: boolean;
begin
	AddStack('TDFrmEd.DWGetClick',Self);
	if lEval then begin
  	AddPrnHead; tf:=pointer(Sender);
    if tf.NameRecFld=DWMem then fl:=DWVidExec(Dfrm)
    else begin
      My_pr.AddPrnHead('Окно ввода данных'); TDWPrm.VarCreate(Dfrm); s:=tf.Value;
      if DWFldExec('Настройка редактирования данных по дополнительной формуле',s,[Dfrm])
      then tf.VarValue:=s;
      fl:=Dfrm.DWModified; TDWPrm.VarFree(Dfrm); DelPrnHead;
    end;
    DelPrnHead;
    if fl then begin
      ChildFldReadAll(pnDW); EFrm.Read;
    end;
  end;
	result:='';
  DelStack;
end;

function TDFrmEd.PanelEdit1Valid(Sender: TObject): Boolean;
begin
	AddStack('TDFrmEd.PanelEdit1Valid',Self);
  inherited;
  result:=CngDat(oDef);
  if result then result:=SchemDM.mgDfrm.EmpCodApp(Sender) else PanelEdit1.FldFocus:=PanelEdit1.Fields[DWMem];
  DelStack;
end;

class procedure TDFrmEd.AddProcMod;
begin
  AddStack('TDFrmEd.AddProcMod');
  AddFrom(aProcMod,Proc);
  DelStack;
end;

class procedure TDFrmEd.Modify;
begin
	AddStack('TDFrmEd.Modify');
  ArrProcNone(aProcMod);
  DelStack;
end;

procedure TDFrmEd.WMFormLimit;
begin
	AddStack('TDFrmEd.WMFormLimit',Self);
  inherited;
  FreeLimit(DFrmEd);
  DelStack;
end;

procedure TDFrmEd.WMHelpFill;
begin
  AddStack('TDFrmEd.WMHelpFill',Self);
  inherited;
  if Assigned(tsHelp) then if EFrm.Active then with TWMHelpFill(Message) do case Oper of
    hlpAdd: DfrmHelpEval(Dfrm[fDfrmKF],pArr);
    hlpFillType: ResFillType:=iif(Length(pFillType^)=0,hlpftBefore,hlpftDefault);
    hlpLinkObj: pLinkObj^:='описание дополнительной формулы';
  end;
  DelStack;
end;

class function TDFrmEd.ArrToValueTypes;
var v: variant;
  i,j,l,h: longint;
begin
  AddStack('TDFrmEd.ArrToValueTypes');
  if MyVarType(av,true)=varDouble then v:=VarArrayOf([av]) else v:=av;
  if MyVarType(v)=varArray then begin
    l:=VarArrayLowBound(v,1); h:=VarArrayHighBound(v,1); SetLength(result,h-l+1); j:=0;
    for i:=l to h do begin
      Inc(j);
      case longint(v[i]) of
        V_NULL       : result[j]:='U';
        V_INT,V_FLOAT: result[j]:='N';
        V_DATE       : result[j]:='D';
        V_BOOL       : result[j]:='L';
        V_STRING     : result[j]:='S';
        varArray     : result[j]:='A';
      else result:=' ';
      end;
    end;
  end
  else result:='';
  DelStack;
end;

class procedure TDFrmEd.ClearCod;
var k: longint;
begin
  AddStack('TDFrmEd.ClearCod');
  if Destroying then FreeAndNil(lsDfrm) else FreeObjects(lsDfrm);
  if Assigned(slCacheDfrm) then with slCacheDfrm do begin
    for k:=0 to Count-1 do aCacheDfrm[IntObj(slCacheDfrm,k)].dfcInt.Free;
    FreeAndNil(slCacheDfrm);
  end;
  DelStack;
end;

class procedure TDFrmEd.PrmEd;
var s: string;
begin
  AddStack('TDFrmEd.PrmEd');
  if LockEdConf then try
    Dfrm.InitFldDef(dwdefGotoRec); TDWPrm.VarCreate(Dfrm); s:=Trim(Dfrm[fDfrmKF]);
    if dw.Execute(Dfrm[DWMem(postWin)],'DfrmDat.'+s,[Dfrm],'Дополнительная формула: '+s,[0],
    'Данные по дополнительной формуле',desVisible).Saved then begin
      Dfrm.UpdateRec; TDFrmEd.Modify;
    end;
    TDWPrm.VarFree(Dfrm);
  finally
    UnLockEdConf;
  end;
  DelStack;
end;

procedure Cache_ExecDfrm(oper: TDfrmEdOper; const av: array of variant);
var cod,s: string;
  tp: TDfrmEvalType;
  EvalError: PInterError;
  n: longint;
  h: longword;
  i: TInter;
  b: boolean;
begin
  case oper of
    dfeChange: ProgPswd.SendUpd(updFormuls);
    dfeEval: begin
      cod:=av[1]; tp:=av[3]; EvalError:=PointerVar(av[5]);
      if slCacheDfrm=nil then begin
        slCacheDfrm:=SortStrListCreate; SetLength(aCacheDfrm,10);
      end;
      if not IntObjFindAdd(slCacheDfrm,TrimRight(cod),n) then begin
        if Length(aCacheDfrm)=n then SetLength(aCacheDfrm,n shl 1);
        with aCacheDfrm[n] do begin
          dfcInt:=TInter.Create('');
          dfcInt.showerror:=false;
          dfcIntSz:=-1;
        end;
      end;
      with aCacheDfrm[n] do begin
        s:=Dfrm[aDfrmFld[tp].f];
        i:=dfcInt;
        h:=HashStr(s);
        b:=true;
        if (dfcIntSz<>length(s))or(dfcIntHash<>h) then begin
          i.SetProg(s);
          b:=i.Compile;
          EvalError^:=i.error;
          if (not b) then dfcIntSz:=-1
          else begin
            dfcIntSz:=length(s);
            dfcIntHash:=h;
          end;
        end;
      end;
      if (b) then begin
        i.name:=Dfrm.GetPrim+' '+Trim(cod)+' ('+aDfrmFld[tp].nm+')';
        b:=i.EvalChk(VariantVar(av[0])^,ArrVarVar(av[2])^);
        EvalError^:=i.error;
      end;
      if (not b) then begin
        InterShowError(i,[ieEsc],nil,nil,'Дополнительная формула: '+Dfrm[fNAME]);
      end;
    end;
  end;
end;

class procedure TDFrmEd.Init;
begin
  AddStack('TDFrmEd.Init');
  if Assigned(Proc) then FProc:=Proc else FProc:=Cache_ExecDfrm;
  FDfrmLoadOnlyDat:=DfrmLoadOnlyDat;
  Dfrm:=TRecDBDef.Create(Application.MainForm); Dfrm0:=Dfrm;
  with TNone do begin
    with Dfrm do begin
      MsgCheck:='Дополнительная формула с таким кодом уже есть.'; NameDB:=tDFRM; NameRec:=DfrmNameRec;
      DWName:='Данные по дополнительным формулам'; DWPrefix:='ДФ';
      OnDWArrSeek:=DfrmDWArrSeek; OnDWRdbSeek:=DfrmDWRdbSeek; OnDWTrans:=DfrmDWTrans;
      OnDWVarValid:=DfrmDWVarValid; OnDWCanDel:=DfrmDWCanDel; OnDWCngName:=DfrmDWCngName;
      OnKodCheck:=DfrmKodCheck; OnNewRec:=DfrmNewRec;
      OpenRec; lDfrmKF:=Length(Value[fDfrmKF]);
    end;
    with SchemDM.mgDfrm do begin
      OnHelp:=mgHelp; OnSave:=mgSave; OnLoad:=mgLoad; OnInterDef:=mgInterDef;
    end;
  end;
  DelStack;
end;

{ TNone }
class procedure TNone.pnButResize;
begin
	AddStack('TNone.pnButResize');
  with TRbPanel(Sender) do Controls[0].SetBounds(2,2,Width-4,Height-4);
  DelStack;
end;

// Dfrm
class procedure TNone.DfrmDWArrSeek;
begin
  AddStack('TNone.DfrmDWArrSeek');
	with result do begin
  	RecDef:=tDFRM; FldDef:=DWMem; FldOrd:=fDfrmKF; Name:=fNAME;
  end;
  DelStack;
end;

class function TNone.DfrmDWRdbSeek;
begin
  result:=Dfrm;
end;

class procedure TNone.DfrmDWTrans;
begin
	AddStack('TNone.DfrmDWTrans');
	if lSave then Dfrm[DWMem]:=sTrans else sTrans:=Dfrm[DWMem];
  DelStack;
end;

class procedure TNone.DfrmDWVarValid;
begin
	AddStack('TNone.DfrmDWVarValid');
  Proc(r,result,Dfrm[DWMem(postWin)],'Окно ввода данных по дополнительной формуле');
  DelStack;
end;

class function TNone.DfrmKodCheck;
begin
  AddStack('TNone.DfrmKodCheck');
  result:=Sender.AbcKodCheck(nmFld,fDfrmKF,Opt);
  DelStack;
end;

class procedure TNone.DfrmNewRec;
begin
  AddStack('TNone.DfrmNewRec');
  Sender.KodNextSelf(fDfrmNF);
  DelStack;
end;

// mgDfrm
class procedure TNone.mgHelp;
var n: byte;
  p: TDWPostList;
begin
  AddStack('TNone.mgHelp');
  n:=high(ht.Dat); SetLength(ht.Dat,n+DWPostLen+3);
  with Dfrm do begin
    HelpTblAdd(ht,n,[fFRM]);
    for p:=low(aDWPost) to high(aDWPost) do HelpTblAdd(ht,n,[DWMem(p)]);
    HelpTblAdd(ht,n,[sMemo+'HELP']);
  end;
  DelStack;
end;

class procedure TNone.mgSave;
var p: TDWPostList;
begin
  AddStack('TNone.mgSave');
	with TModelGet(Sender) do begin
  	WriteStr(Dfrm[fFRM]);
    for p:=low(aDWPost) to high(aDWPost) do WriteStr(Dfrm[DWMem(p)]);
    WriteStr(Dfrm[sMemo+'HELP']);
		Dfrm[fMODEL]:=MDFile; Dfrm[fNMODEL]:=NSave; Dfrm[fFRMMD]:=Dfrm[fFRM];
  	if FromEdit then DFrmEd.EModel.Read else Dfrm.UpdateRec(true);
  end;
  DelStack;
end;

class procedure TNone.mgLoad;
var oName,oDef: string;
	fl: boolean;
	ons: longint;
  p: TDWPostList;
begin
  AddStack('TNone.mgLoad');
	with TModelGet(Sender) do begin
  	oDef:=Dfrm[DWMem]; oName:=Dfrm[fMODEL]; ons:=Dfrm[fNMODEL];
		if empty(Dfrm[fDfrmKF]) then Dfrm[fDfrmKF]:=MDFile;
    if empty(Dfrm[fNAME]) then Dfrm[fNAME]:=MDName;
    Dfrm[fNMODEL]:=NSave; Dfrm[fFRMMD]:=TrimRight(ReadStr);
    if StrToChar(MDName)<>'*' then Dfrm[fFRM]:=Dfrm[fFRMMD];
    for p:=low(aDWPost) to high(aDWPost) do Dfrm[DWMem(p)]:=ReadStr;
    if Vers>=1 then Dfrm[sMemo+'HELP']:=TrimRight(ReadStr);
    if FromEdit then begin
      // При вызове ПМ_ВЫД(вид=6) идёт поиск формулы помощи в основах, DFrmEd может не быть
      if Assigned(DFrmEd) then DFrmEd.PanelEdit1.FldReadAll;
    end
    else begin
      Dfrm[fMODEL]:=MDFile;
      if TrnsStart([tDFRM]) then try
        fl:=CngDat(oDef);
        if fl then begin
          Dfrm.UpdateRec(true);
          if CanUpdate then begin
            Dfrm.InitFldDef(dwdefGotoRec); TDWPrm.VarCreate(Dfrm);
            Update(oName,Dfrm[fMODEL],ons); TDWPrm.VarFree(Dfrm); Dfrm.UpdateRec;
          end;
        end;
        TrnsEnd(IfThen(fl,trnsCommit));
      except
        TrnsEnd; raise
      end;
    end;
  end;
  DelStack;
end;

class procedure TNone.mgInterDef;
begin
  AddStack('TNone.mgInterDef');
  case Oper of
    mdiVarName: result:='ФРМЛ';
    mdiAfterLoad: TDFrmEd.Modify;
  end;
  DelStack;
end;

class procedure TNone.FrmMdProcKey;
begin
  AddStack('TNone.FrmMdProcKey');
  EdTextView('Формула, загруженная из основы',Dfrm[fFRMMD],'',nil,[],edtpInter);
  DelStack;
end;

procedure DfrmClearCod;
begin
  AddStack('FDFrmEd.DfrmClearCod');
  TDFrmEd.ClearCod(false);
  DelStack;
end;

procedure HelpLinkProc(Vid: THelpLinkList; Oper: THelpLinkOper; const Ident: string; p: pointer);
var svi: TRDBSaveInf;
  oDfrm: TRecDBDef;
begin
  AddStack('FDFrmEd.HelpLinkProc');
  if Vid=hlnkDfrm then case Oper of
    hlpLinkTrns: PString(p)^:=Ident;
    {hlpLinkAdd: with ProgPswd.GetQuery do begin
      PartSelect(tDFRM,fDfrmKF,fMODEL+'='+QQs(Ident),fDfrmNF);
      if IsRecords then DfrmHelpEval(Fields[0].AsString,PHelpArr(p));
      ProgPswd.FreeQuery;
    end;}
    hlpLinkAdd: begin
      oDfrm:=Dfrm;
      try
        Dfrm:=Dfrm0;
        Dfrm.SaveInf(svi); Dfrm.NewRec;
        if SchemDM.mgDfrm.LoadFromFile(Ident,[mdldCheckSum,mdldFromEdit,mdldDoLoad]) then begin
          Dfrm[fDfrmKF]:=Ident; DfrmHelpEval(Ident,PHelpArr(p),Dfrm);
        end;
        TRecDB.RestInf(svi);
        if Assigned(DFrmEd) then DFrmEd.PanelEdit1.FldReadAll;
      finally
        Dfrm:=oDfrm;
      end;
    end;
  end;
  DelStack;
end;

procedure LogTrnsValProc(var Prm: TLogTrnsValPrm);
var p: TDWPostList;
begin
  AddStack('FDFrmEd.LogTrnsValProc');
  if LogEqual(Prm,tDFRM,[fFRM,fFRMMD]) then TCrlfLogCompare.Execute(Prm)
  else for p:=low(aDWPost) to high(aDWPost) do
    if LogEqual(Prm,tDFRM,DWMem(p)) then with Prm do begin
      case p of
        postDat: TDatLogCompare.Execute(Prm,Dfrm);
        postWin: TWinLogCompare.Execute(Prm);
      end;
      break;
    end;
  DelStack;
end;

procedure Init;
var a: TArrStr;
  i: longint;
begin
  AddStack('FDFrmEd.initialization');
  MyTypes.DfrmClearCod:=DfrmClearCod;
  SetPrim(tDFRM,'Дополнительные формулы');
  TDFrmEd.AddProcMod(FProcMod);
	with TInter do begin
    SetFunction('Дополнительные формулы',1600);
    SetFunction(FuncDfrm,'Выполнить дополнительную формулу',
      InterPrmMax(['Код: строка']),['C'],c_dfrm,null,1601,'*');
    a:=InterPrmMax(['Формула: строка~Формула: строка~Номер: целое~Номер: целое',
      'Название: строка~Номер: целое~Название: строка','[ТипРез: тип|массив]']);
    for i:=2 to high(a) do IncD(a[i],'~~'+a[i]);
    SetFunction('ФОРМУЛА_СТР','Выполнить формулу-строку',a,['CN','CNU','NAU'],c_str,null,1602,'*');
    SetFunction('ФОРМУЛА_ЕСТЬ','Признак наличия дополнительной формулы',
      ['Код: строка'],['C'],c_is,null,1603,'L');
    SetFunction('ФОРМУЛА_РЕД','Редактировать дополнительную формулу',
      ['Код: строка'],['C'],c_ed,null,1604);
    SetFunction('ФОРМУЛА_ПАРАМ','Значение параметра дополнительной формулы',
      ['Код: строка','Парам: строка|массив'],['C','CA'],c_dfrmprm,null,1605,'*');
    SetFunction('ФОРМУЛА_ПРМРЕД','Редактировать параметры дополнительной формулы',
      ['Код: строка'],['C'],c_prmed,null);
  end;
  AddFrom(HelpLinkProc);
  LogTrnsValProcAdd(LogTrnsValProc);
  DelStack;
end;

initialization
  Init;
finalization
  AddStack('FDFrmEd.finalization');
  nInter:=low(aInter);
  while nInter<=high(aInter) do begin
    FreeAndNil(aInter[nInter]); Inc(nInter);
  end;
  DelStack;
end.
