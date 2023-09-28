unit FEdoDM;

interface

// Надо вызвать из LoadForms Application.CreateForm(TEdoDM, EdoDM) до MainDM
// Поискать EDOVD
uses
  SysUtils, Classes, Messages, DB,
  MyTypes, RecVal, Recdb, FFldedit, CCodeGet, Codegets, FrmBrIB, DefEdit, ArrGet, ButGet, MulQry,
    ModelGet, ComboGet, BrQuery;

type
  TEdoPrmList = (edopPrim,edopKey,edopOrg,edopOrgEd,edopPril);

  TEdoAct = (edoaPodp,edoaSave,edoaLoad);
  TEdoActStr = array[TEdoAct] of string;

  TEdoDM = class(TDataModule)
    Exe: TRecDBDef;
    Us: TRecDB;
    Vd: TRecDBDef;
    Ord: TRecDB;
    Inn: TRecDB;
    Edo: TRecDB;
    VdGet: TCodeGet;
    VdArhGet: TArrGet;
    VdArhRec: TRecVal;
    VdArhWnd: TDefEdit;
    PrimGet: TButFormGet;
    ExeGet: TCodeGet;
    mgExe: TModelGet;
    App: TRecDB;
    procedure ExeNewRec(Sender: TRecDB; lcopy: Boolean;
      const gKey: String);
    procedure DataModuleCreate(Sender: TObject);
    procedure VdNewRec(Sender: TRecDB; lcopy: Boolean; const gKey: String);
    function VdGetFormIBList(Sender: TFldEdit): TFormBrIB;
    procedure VdGetAfterList(Sender: TObject);
    procedure PrimGetHelp(var Message: TMessage);
    function ExeGetFormIBList(Sender: TFldEdit): TFormBrIB;
    procedure ExeGetAfterList(Sender: TObject);
    procedure ExeGetBufCodCng(Sender: TObject; const cod: String;
      qApp: Tmulquery);
    function InnSeekMsg(Sender: TObject): String;
    procedure mgExeSave(Sender: TObject; FromEdit: Boolean);
    procedure mgExeLoad(Sender: TObject; FromEdit: Boolean);
    procedure PrimGetEnter(Sender: TObject);
    procedure PrimGetExit(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    function ExeGetStrDop(Sender: TObject; Qry: TBrQuery): String;
    function OrdTrnsCan(Sender: TRecDB; lmod: Boolean): Boolean;
    procedure OrdTrnsExec(Sender: TRecDB; Qry: Tmulquery; lmod: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AppAdd(un: longint; const name,fname: string);
    function ExeOrAct(fACT,fKE: TField): string;
  end;

  TEdoOperStd = (edoVdGetBefore,edoVdGetAfter);
  TEdoProcStd = procedure(Oper: TEdoOperStd; const av: array of variant; var result: variant;
    var lBreak: boolean);

  PEdoPrm = ^TEdoPrm;
  TEdoPrm = record
    vd,rsource: longint;
    cod,kv,nm: string;
    prm: array[TEdoPrmList] of variant;
  end;

const aEdoFile: TArrBoolStr = (sMemo+'RTF',sMemo+'SIG');
  aEdoFmt: TMSOFmtStr = ('','HTML','RTF','XLS');
  aEdoActAbr: TEdoActStr = ('','выгрузка','загрузка');

var
  EdoDM: TEdoDM;
  EdoNetSelProc: TProcNone;
  EdoInFdp: TRecDB;
  fEdoVdOrg,fEdoVdPath: string;

function EdoProcStd(Oper: TEdoOperStd; const av: array of variant; const Default: variant): variant; overload;
function EdoProcStd(Oper: TEdoOperStd; const av: array of variant): variant; overload;
procedure EdoExeFlt(var Mask: string; tp: TEdoExeType);
function EdoVdCanEdit(const kv: string): boolean;
procedure AddFrom(Proc: TEdoProcStd); overload;
function EdoPrmVar(const v: variant): PEdoPrm;
procedure EdoInOrd(un: longint; const kv,org: string; nc: longint); overload;
procedure EdoInOrd; overload;
function EdoTmpPath: TFileName;

implementation

{$R *.dfm}

uses Windows,Variants,StrUtils,Math,
  My_Pr,Inter,SpGet;

type
  TEdoExeLs = class(TFormBrIB)
    procedure FormCreate(Sender: TObject);
  end;

const FuncExeFlt = 'EdoExeFlt';

var EdoExeLs: TEdoExeLs;
  aExe: array[TEdoExeType] of record
    a: TArrInt;
    l: longint;
  end;
  lEDOEXE: byte;
  aEdoProcStd: array of TEdoProcStd;

function c_exeflt(var av: array of variant):variant;
var svi: TRDBSaveInf;
  i: longint;
  fe: TField;
  afin: array[TEdoExeType] of TFld;
  tp: TEdoExeType;
begin
  AddStack('FEdoOrLs.c_exeflt');
  if aExe[edoexePodp].l=NegDef then with EdoDM.Exe,GetQuery do begin
    SaveInf(svi); PartSelect(tEDOEXE,[]); fe:=FindField(fEDOEXE); lEDOEXE:=fe.Size; i:=RecordCount;
    for tp:=low(aExe) to high(aExe) do with aExe[tp] do begin
      l:=0; FldName(EdoExeFld(tp,edoexeIn),afin[tp]);
      if Length(a)<i then SetLength(a,i);
    end;
    for i:=1 to i do begin
      GetFromQuery;
      for tp:=low(aExe) to high(aExe) do if not empty(afin[tp].Value) then with aExe[tp] do begin
        a[l]:=Int0(fe.AsString); Inc(l);
      end;
      Next;
    end;
    for tp:=low(aExe) to high(aExe) do with aExe[tp] do QuickSort(a,l);
    RestInf(svi); FreeQuery;
  end;
  with aExe[TEdoExeType(av[1])] do if l=0 then result:=false
  else begin
    result:=VarArrayCreate([1,l],varVariant);
    for i:=1 to l do result[i]:=SpaceStr(a[i-1],lEDOEXE);
  end;
  DelStack;
end;

function c_primhelp(var av: array of variant):variant;
var n: TEdoPrmList;
begin
  AddStack('FEdoDM.c_primhelp');
  n:=av[1]-1;
  case n of
    edopPrim,edopKey: result:='""';
    edopOrg: result:='Организации из последовательности подписания';
    edopOrgEd: result:='Длина списка организаций больше 1';
    edopPril: result:='{}';
  end;
  result:=EdoProc(edoFmlPrm,[n],result);
  DelStack;
end;

procedure aExeClear;
begin
  AddStack('FEdoDM.aExeClear');
  aExe[edoexePodp].l:=NegDef;
  DelStack;
end;

function EdoProcStd(Oper: TEdoOperStd; const av: array of variant; const Default: variant): variant;
var i: longint;
  lBreak: boolean;
begin
  AddStack('FEdoDM.EdoProcStd');
  result:=Default; lBreak:=false;
  for i:=low(aEdoProcStd) to high(aEdoProcStd) do begin
    aEdoProcStd[i](Oper,av,result,lBreak);
    if lBreak then break;
  end;
  DelStack;
end;

function EdoProcStd(Oper: TEdoOperStd; const av: array of variant): variant;
begin
  result:=EdoProcStd(Oper,av,null);
end;

procedure EdoExeFlt;
var Prm: TCGParam;
begin
  AddStack('FEdoDM.EdoExeFlt');
  Prm:=TCodeGet.MaskToPrm(Mask); Prm.FmlFlt:=FuncExeFlt+Format('(%d)',[byte(tp)]);
  Mask:=TCodeGet.PrmToMask(Prm);
  DelStack;
end;

function EdoVdCanEdit;
begin
  AddStack('FEdoDM.EdoVdCanEdit');
  with GetQuery do result:=PartCount0(GetList([tEDOIN,tEDO]),tEDO+'.'+fEDOIN+'='+tEDOIN+'.'+fEDOIN
    +sAND+FldIsTrue(tEDOIN+'.INARH',false)+sAND+tEDOIN+'.'+fEDOVD+'='+QQs(kv));
  FreeQuery;
  DelStack;
end;

procedure AddFrom(Proc: TEdoProcStd);
var i: longint;
begin
  AddStack('FEdoDM.AddFrom(TEdoProcStd)');
  i:=Length(aEdoProcStd); SetLength(aEdoProcStd,i+1); aEdoProcStd[i]:=Proc;
  DelStack;
end;

function EdoPrmVar(const v: variant): PEdoPrm;
begin
  result:=PointerVar(v);
end;

procedure EdoInOrd(un: longint; const kv,org: string; nc: longint);
var qun: TMulQuery;
  af: TArrField;
  i,l,oLogVid: longint;
begin
  AddStack('FEdoDM.EdoInOrd');
  qun:=GetQuery;
  qun.PartSelect(tEDOORD,[],fEDOIN+'='+Vtos(un),fEDOORD);
  with GetQuery,EdoDM.Ord do begin
    PartSelect(tEDOORD,[],ArrayAsList([fEDOIN+'='+VToS,fEDOVD+'='+QQs(kv),
      fEdoORG+'='+QQs(org),fEdoNC+'='+Vtos(nc)],sAND),fEDOORD);
    l:=FieldCount; SetLength(af,l); Dec(l);
    for i:=0 to l do af[i]:=FindField(FieldName[i]);
    oLogVid:=GetLogVid;
    while not Eof do begin
      if qun.Eof then begin
        CngLogVid(logvAppRec); GetFromQuery; NewRec([newrCopy]);
      end
      else begin
        CngLogVid(logvEditRec); GetFromQuery(qun);
        for i:=0 to l do ValueNum[i]:=af[i].Value;
      end;
      Value[fEDOIN]:=un; AppUpdRec(true); Next; qun.Next;
    end;
    CngLogVid(logvDelRec);
    while not qun.Eof do begin
      GetFromQuery(qun); DelRec('',[delLog]); qun.Next;
    end;
    CngLogVid(oLogVid);
  end;
  FreeQuery; FreeQuery;
  DelStack;
end;

procedure EdoInOrd;
begin
  with EdoDM do EdoInOrd(Inn[fEDOIN],Inn[fEDOVD],Inn[fEdoORG],Inn[fEdoNC]);
end;

function EdoTmpPath;
begin
  AddStack('FEdoDM.EdoTmpPath');
  result:=ExeDir+'EDO_'+TmpFile+PathDelim;
  DelStack;
end;

{ TEdoDM }
procedure TEdoDM.DataModuleCreate(Sender: TObject);
var tp: TEdoExeType;
  io: TEdoExeIO;
  i: longint;
  a: TDEPrmStr;
  lOrg: boolean;
begin
  AddStack('TEdoDM.DataModuleCreate',Self);
  fEdoVdOrg:=EdoProc(edoVdOrg,[]);
  fEdoVdPath:=EdoProc(edoVdPath,[]);
  for tp:=low(aEdoExeType) to high(aEdoExeType) do
    for io:=low(aEdoExeIO) to high(aEdoExeIO) do with aEdoExeIO[io] do
      Exe.CreateFld(EdoExeFld(tp,io),Int2Str(tp)+'_'+Int2Str(io),
        iif(bool,ftBoolean,ftString),IfThen(not bool,MaxByte),0,iif(bool,false,''),
        aEdoExeType[tp]+': '+nm);
  Ord.OpenRec;
  VdArhWnd.GetArrParam(fEdoORG,i,a); a[deNameRecFld]:=fEdoVdOrg;
  lOrg:=EdoProc(edoOrgGet,[longint(@a),true],false);
  a[deNoVisible]:=bStr[not lOrg];
  VdArhWnd.SetArrParam(i,a);
  if lOrg then begin
    VdArhRec.Fields.Insert(0,fEdoVdOrg+'=');
    VdArhRec.CreateFld(fEdoVdOrg,ftString,Ord.FldName(fEdoORG).Info.Size,'','Организация (пусто-все)')
  end;
  AddFrom(aNetSelProc,EdoNetSelProc);
  for i:=0 to ComponentCount-1 do if Components[i] is TRecDB then TRecDB(Components[i]).OpenRec;
  DelStack;
end;

procedure TEdoDM.DataModuleDestroy(Sender: TObject);
begin
  AddStack('TEdoDM.DataModuleDestroy',Self);
  DelFrom(aNetSelProc,EdoNetSelProc);
  DelStack;
end;

procedure TEdoDM.ExeNewRec(Sender: TRecDB; lcopy: Boolean;
  const gKey: String);
begin
  AddStack('TEdoDM.ExeNewRec',Self);
  Sender.KodNextSelf(fEDOEXE);
  DelStack;
end;

procedure TEdoDM.VdNewRec(Sender: TRecDB; lcopy: Boolean;
  const gKey: String);
begin
  AddStack('TEdoDM.VdNewRec',Self);
  Sender.KodNextSelf(fEDOVD);
  if not lcopy then Sender['FMT']:=msoFmtRtf;
  DelStack;
end;

function TEdoDM.OrdTrnsCan(Sender: TRecDB; lmod: Boolean): Boolean;
begin
  AddStack('TEdoDM.OrdTrnsCan',Self);
  result := (Sender[fEdoNC]=0) and not lmod or Sender.FldName('NMC').Modified;
  DelStack;
end;

procedure TEdoDM.OrdTrnsExec(Sender: TRecDB; Qry: Tmulquery;
  lmod: Boolean);
var s: string;
begin
  AddStack('TEdoDM.OrdTrnsExec',Self);
  s:=QQs(Sender['NMC']);
  Qry.UpdateTable(tEDOORD,['NMC'],[s],
    DlmBetween([fEDOIN+'='+Vtos(Sender[fEDOIN]),fEDOVD+'='+QQs(Sender[fEDOVD]),
    fEdoORG+'='+QQs(Sender[fEdoORG]),fEdoNC+'='+Vtos(Sender[fEdoNC]),
    Sender.rRecNo(false),'NMC<>'+s],sAND));
  DelStack;
end;

function TEdoDM.InnSeekMsg(Sender: TObject): String;
begin
  AddStack('TEdoDM.InnSeekMsg',Self);
  result:=EdoInCapt(Inn['VD'],Inn['COD'],Inn[fNAME],Inn['PRIM'],Inn['D']);
  DelStack;
end;

function TEdoDM.ExeGetFormIBList(Sender: TFldEdit): TFormBrIB;
begin
  AddStack('TEdoDM.ExeGetFormIBList',Self);
  CreateForm(TEdoExeLs,EdoExeLs); result:=EdoExeLs;
  DelStack;
end;

procedure TEdoDM.ExeGetAfterList(Sender: TObject);
begin
  AddStack('TEdoDM.ExeGetAfterList',Self);
  FormFree(EdoExeLs);
  DelStack;
end;

procedure TEdoDM.ExeGetBufCodCng(Sender: TObject; const cod: String;
  qApp: Tmulquery);
begin
  aExeClear;
end;

function TEdoDM.ExeGetStrDop(Sender: TObject; Qry: TBrQuery): String;
var svi: TRDBSaveInf;
begin
  AddStack('TEdoDM.ExeGetStrDop',Self);
  Exe.SaveInf(svi); Exe.CopyDopFromQuery(Qry);
  result:=bStr[not empty(Exe[EdoExeFld(edoexePodp,edoexeIn)])]; TRecDB.RestInf(svi);
  DelStack;
end;

function TEdoDM.VdGetFormIBList(Sender: TFldEdit): TFormBrIB;
begin
  AddStack('TEdoDM.VdGetFormIBList',Self);
  result:=PointerVar(EdoProcStd(edoVdGetBefore,[]));
  DelStack;
end;

procedure TEdoDM.VdGetAfterList(Sender: TObject);
begin
  AddStack('TEdoDM.VdGetAfterList',Self);
  EdoProcStd(edoVdGetAfter,[]);
  DelStack;
end;

procedure TEdoDM.PrimGetEnter(Sender: TObject);
begin
  AddStack('TEdoDM.PrimGetEnter',Self);
  EdoProc(edoFmlEnter,[longint(Sender)]);
  DelStack;
end;

procedure TEdoDM.PrimGetExit(Sender: TObject);
begin
  AddStack('TEdoDM.PrimGetExit',Self);
  EdoProc(edoFmlExit,[]);
  DelStack;
end;

procedure TEdoDM.PrimGetHelp(var Message: TMessage);
begin
  AddStack('TEdoDM.FileGetHelp',Self);
  with TWMHelpFill(Message) do if Oper=hlpFile then begin
    rHelpFile(pFile.f[hlpfBase],HelpFileStd,'Prm.EdoPrim'); ResFile:=true;
  end;
  DelStack;
end;

procedure TEdoDM.mgExeSave(Sender: TObject; FromEdit: Boolean);
var tp: TEdoExeType;
  io: TEdoExeIO;
begin
  AddStack('TEdoDM.mgExeSave',Self);
  with TModelGet(Sender) do begin
    for tp:=low(aEdoExeType) to high(aEdoExeType) do
      for io:=low(aEdoExeIO) to high(aEdoExeIO) do WriteStr(Exe[EdoExeFld(tp,io)]);
    Exe[fMODEL]:=MDFile; Exe[fNMODEL]:=NSave; Exe.UpdateRec(true);
  end;
  DelStack;
end;

procedure TEdoDM.mgExeLoad(Sender: TObject; FromEdit: Boolean);
var tp: TEdoExeType;
  io: TEdoExeIO;
begin
  AddStack('TEdoDM.mgExeLoad',Self);
  with TModelGet(Sender) do begin
    if empty(Exe[fNAME]) then Exe[fNAME]:=MDName;
    ReadStr1(Vers=1); // PODPSEP
    for tp:=low(aEdoExeType) to high(aEdoExeType) do
      for io:=low(aEdoExeIO) to high(aEdoExeIO) do Exe[EdoExeFld(tp,io)]:=ReadStr;
    Exe[fMODEL]:=MDFile; Exe[fNMODEL]:=NSave; Exe.UpdateRec(true);
  end;
  DelStack;
end;

procedure TEdoDM.AppAdd;
var s: string;
begin
  AddStack('TEdoDM.AppAdd');
  if fname<>'' then begin
    s:=GetStrFile(fname);
    if s<>'' then begin
      App.NewRec; App[fEDOIN]:=un; App[sMemo+'FILE']:=s;
      s:=ExtractFileName(fname); App['FNAME']:=s; App[MyTypes.fNAME]:=ReplVar(name,FileWithoutExt(s));
      App.AppRec(true);
    end;
  end;
  DelStack;
end;

function TEdoDM.ExeOrAct;
var act: TEdoAct;
begin
  AddStack('TEdoDM.ExeOrAct',Self);
  act:=TEdoAct(fACT.AsInteger);
  if act=edoaPodp then result:=ExeGet.CodeName(fKE.AsString,[cdgBufAll]) else result:=aEdoActAbr[act];
  DelStack;
end;

procedure LogTrnsValProc(var Prm: TLogTrnsValPrm);
begin
  AddStack('FEdoDM.LogTrnsValProc');
  with Prm do
    if LogEqual(Prm,tEDOIN,sMemo+'DTG') or LogEqual(Prm,tEDOIN,aEdoFile) then begin
      val:=IfThen(val='','нет','есть'); lBreak:=true;
    end
    else if LogEqual(Prm,tEDOAPP,sMemo+'FILE') then begin
      lOut:=false; lBreak:=true;
    end
    else if LogEqual(Prm,[tEDOIN,tEDO],['D']) then begin
      val:=OurFormatDateTime(EdoFmtDate,Float0(val)); lBreak:=true;
    end
  ;DelStack;
end;

{ TEdoExeLs }
procedure TEdoExeLs.FormCreate(Sender: TObject);
begin
  AddStack('TEdoExeLs.FormCreate',Self);
  inherited;
  Caption:='Программы';
  with BrQuery1 do begin
    Init(DBMain,[fEDOEXE],[],tEDOEXE,[]);
    Browl1.FieldSeek:=CreateStringField(fEDOEXE);
    CreateStringField(fNAME);
    EdoDM.Exe.CreateFieldDop(BrQuery1);
  end;
  DelStack;
end;

procedure Init;
const aSpGk: array[0..0] of TSpGkTblDef =
  ((tbl:tEDO;nmf:'SKIPREASON';key:'EDOSK')
  );
begin
  AddStack('FEdoDM.initialization');
  aExeClear;
  TInter.SetFunction(FuncExeFlt,'',[''],['I'],c_exeflt,null);
  TInter.SetFunction('EdoPrimHelp','',[''],['I'],c_primhelp,null,0,'C');
  AddFrom(aSpGk);
  LogTrnsValProcAdd(LogTrnsValProc);
  DelStack;
end;

initialization
  Init;
finalization
  AddStack('FEdoDM.finalization');
  if ExeDir<>'' then XDel(EdoTmpPath);
  DelStack;
end.
