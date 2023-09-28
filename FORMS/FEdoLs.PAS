unit FEdoLs;

interface

uses
  Windows, Messages, Classes, Controls, Menus, DB, Grids, DBGrids, ExtCtrls, Math, SysUtils, Dialogs,
  MyTypes, My_Pr, FrmBrIB, KeyMenu, Browl, Keylb, Fpanel, RecDB, DefEdit, RecVal, FFldedit, ArrGet,
    CCodeGet, DirGet, MulQry, RbMenu, MemoGet, BtTxtGet;

type
  TEdoMode = (edomdAll,edomdArh); TEdoModes = set of TEdoMode;

  TEdoEqual = set of (edoeqFirst,edoeqLast);

  PEdoInf = ^TEdoInf;
  TEdoInf = record
    d: TDateTime;
    status: TValueSign;
    equal: TEdoEqual;
    nSkip: longint;
    skipuser,skipreason: string;
  end;
  TArrEdoInf = array of TEdoInf;

  TEdoLs = class(TFormBrIB)
    Rec: TRecVal;
    deFlt: TDefEdit;
    de: TDefEdit;
    FileGet: TDirGet;
    dlgFileOpen: TOpenDialog;
    dlgFileSave: TSaveDialog;
    deFile: TDefEdit;
    deSkip: TDefEdit;
    dmFmt: TDefMenu;
    UsersGet: TButTextGet;
    KvsGet: TButTextGet;
    deDel: TDefEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Browl1BrowlKey(key: Integer; tw: TWinControl);
    procedure deFltFldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure Browl1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    function deFileFldCheck(Sender: TObject): Boolean;
    procedure UsersGetClick(Sender: TObject);
    procedure KvsGetClick(Sender: TObject);
    function deDelPnlValid(Sender: TObject): Boolean;
    function deDelFldCheck(Sender: TObject): Boolean;
  private
    { Private declarations }
    BrQuery1STATUS,BrQuery1UN: TIntegerField;
    BrQuery1D,BrQuery1D1,BrQuery1VD,BrQuery1COD,BrQuery1USERNAME,BrQuery1RECNO,BrQuery1RECNO1,
      BrQuery1ORD,BrQuery1RTF,BrQuery1SKIPUSER,BrQuery1SKIPREASON,BrQuery1KV,BrQuery1ORG,BrQuery1NC,
      BrQuery1ACT,BrQuery1KE: TField;
    BrQuery1CD,BrQuery1CD1,BrQuery1CKE,BrQuery1CVD,BrQuery1CCOD,BrQuery1NAME,BrQuery1PRIM,BrQuery1CUSERNAME,
      BrQuery1CSTATUS,BrQuery1SHIFRED,BrQuery1CSKIPUSER,BrQuery1CSKIPREASON: TStringField;
    BrQuery1CRTF: TBooleanField;
    Mode: TEdoModes;
    stStatus: TValueSignBool;
    d1b,d1e: TDateTime;
    FltStatus,FltD1: boolean;
    ChkSuccess: PBoolean;
    lsInf: TStringList;
    aInf: TArrEdoInf;
    qInInf,qInf: TMulQuery;
    aFltDef: TArrFldVal;
    FltVD,FltRSOURCE: longint;
    function IsMain: boolean;
    procedure SetQry; overload;
    procedure SetQry(q: TMulQuery; Mode: TEdoModes; lcnt: boolean); overload;
    function Inf: PEdoInf;
    procedure BrQuery1BeforeOpen(DataSet: TDataSet);
    procedure BrQuery1FilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure BrQuery1CalcFields(DataSet: TDataSet);
    procedure BrQuery1AfterScroll(DataSet: TDataSet);
    function Browl1GrayCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState): Boolean;
    function InCapt(Opt: TEdoInCaptOpt = []): string;
    class procedure ApplTitleBlink(ReDef: boolean);
    function FltBefore: variant;
    procedure FltAfter(tr: longint; const ii: variant);
    function GetLog: string;
    procedure WMFormLimit(var msg: TMessage); message WM_FORMLIMIT;
  	procedure WMSaveIni(var Msg: TWMSaveIni); message WM_SAVEINI;
		procedure WMCngPriv(var msg: TMessage); message WM_CNGPRIV;
		procedure WMCngTabu(var msg: TMessage); message WM_CNGTABU;
  public
    { Public declarations }
    class procedure Execute(AMode: TEdoModes; vd,rsource: longint; const Head: string);
  end;

var
  EdoLs: TEdoLs;

implementation

{$R *.dfm}

uses StrUtils,Variants,ShellApi,Forms,
  FEdoDM,FEdoExUs,FEdoVdLs,FEdoUsLs,FEdoOrLs,FEdoApLs,
  FrmPswd,FSchemDM,FGFView,FFdp,Askp,DDProc,SpGet,FTabuLs,FStat;

type
  TCalcProc = procedure(const av: array of variant; un,ord: longint; const nmus,skipuser,skipreason: string;
    d: TDateTime; status: TValueSign; equal: TEdoEqual; var lBreak: boolean);

const
  aStatus: array[TValueSign] of string = ('не готов к подписи','готов к подписи','подписан');
  StatusSkip = 'пропущен';
  offsStatus = 2;

  cKeyPodp = 'Подписать';

  aExeKey: array[TEdoExeType] of record
    k: longint;
    txt,nm: string;
    logv: longint;
  end =
    ((k:K_F3; txt:cKeyPodp   ; logv:logvEditRec)
    ,(k:K_F4; txt:'Проверить')
    ,(k:K_F5; txt:'Шифровать'; logv:logvAppRec)
    );

  FmtKeyBeg = K_1;
  FmtBeg = Succ(msoFmtDefault);

var EdoLs2: TEdoLs;
  qInBlink,qBlink: TMulQuery;
  Blinked: boolean;
  FmtKey: longint = FmtKeyBeg+byte(msoFmtRtf)-byte(FmtBeg);

procedure qPrepare(var tbl,where: string); overload;
begin
  AddStack('FEdoLs.qPrepare(tbl,where)');
  tbl:=ProgPswd.GetList([tEDOIN,tEDOORD]);
  where:=ArrayAsList([tEDOORD+'.'+fEDOIN+'='+tEDOIN+'.'+fEDOIN,tEDOORD+'.'+fEDOVD+'='+tEDOIN+'.'+fEDOVD,
    tEDOORD+'.'+fEdoORG+'='+tEDOIN+'.'+fEdoORG,tEDOORD+'.'+fEdoNC+'='+tEDOIN+'.'+fEdoNC],sAND);
  DelStack;
end;

procedure qPrepare(qIn,q: TMulQuery); overload;
var t,w,o: string;
begin
  AddStack('FEdoLs.qPrepare(q)');
  qPrepare(t,w); IncAnd(w,FldIsTrue(tEDOIN+'.INARH',false));
  o:=q.GetList([tEDOIN+'.'+fEDOIN,tEDOORD+'.'+fEDOORD]);
  qIn.PartSelect(t,[tEDOIN+'.'+fEDOIN,tEDOORD+'.'+fEDOORD,tEDOORD+'.'+fUSERNAME],w,o,'',false);
  q.PartSelect(q.GetList([t,tEDO]),
    [tEDOIN+'.'+fEDOIN,tEDO+'.'+fEDOORD,tEDO+'.'+fUSERNAME,tEDO+'.D',tEDO+'.SKIPUSER',tEDO+'.SKIPREASON'],
    w+sAND+tEDO+'.'+fEDOIN+'='+tEDOIN+'.'+fEDOIN+sAND+tEDO+'.'+fEDOORD+'='+tEDOORD+'.'+fEDOORD,
    q.GetList([o,tEDO+'.'+fUSERNAME]),'',false);
  DelStack;
end;

function qCalcBreak(qIn,q: TMulQuery; Proc: TCalcProc; const av: array of variant): boolean;
  function sUn(un,ord: longint; const nmus: string): string; overload;
  begin
    result:=StrUn(un)+StrUn(ord)+TrimRight(nmus);
  end;
  function sUn: string; overload;
  begin
    result:=sUn(q.Fields[0].AsInteger,q.Fields[1].AsInteger,q.Fields[2].AsString);
  end;
var un,i,NextORD,l,cntNoPodp: longint;
  lFirst: boolean;
  a: array of record
    ord: longint;
    nmus,skipuser,skipreason: string;
    d: TDateTime;
    equal: TEdoEqual;
  end;
  bm: TBookMark;
  s: string;
label lend;
begin
  AddStack('FEdoLs.qCalcBreak');
  result:=false;
  while not qIn.Eof do begin
    // для каждого EDOIN находим первый не полностью подписанный порядок (NextORD)
    un:=qIn.Fields[0].AsInteger;
    while not q.Eof and (q.Fields[0].AsInteger<un) do q.Next;
    bm:=q.GetBookMark; l:=0; cntNoPodp:=0; NextORD:=MaxInt; lFirst:=true;
    while not qIn.Eof and (qIn.Fields[0].AsInteger=un) do begin
      i:=qIn.Fields[1].AsInteger;
      while not qIn.Eof and (qIn.Fields[0].AsInteger=un) and (qIn.Fields[1].AsInteger=i) do begin
        if Length(a)=l then SetLength(a,l+1);
        a[l].ord:=i; a[l].nmus:=qIn.Fields[2].AsString; a[l].equal:=[]; q.GotoBookMark(bm);
        s:=sUn(un,i,a[l].nmus);
        while not q.Eof and (sUn<s) do q.Next;
        if not q.Eof and (sUn=s) then begin
          a[l].d:=q.Fields[3].AsFloat; a[l].skipuser:=q.Fields[4].AsString; a[l].skipreason:=q.Fields[5].AsString;
          lFirst:=false;
        end
        else begin
          a[l].d:=DateEmpty; a[l].skipuser:=''; a[l].skipreason:=''; Inc(cntNoPodp);
          if NextORD=MaxInt then NextORD:=i;
        end;
        qIn.Next; Inc(l);
      end;
    end;
    q.FreeBookMark(bm);
    Dec(l);
    if cntNoPodp=1 then Include(a[l].equal,edoeqLast);
    for l:=0 to l do with a[l] do begin
      i:=CompSign(NextORD,ord);
      if lFirst then begin
        Include(a[l].equal,edoeqFirst); lFirst:=false;
      end;
      if i=0 then if not empty(d) then i:=1;
      Proc(av,un,ord,TrimRight(nmus),skipuser,skipreason,d,i,equal,result);
      if result then goto lend;
    end;
  end;
lend:
  DelStack;
end;

procedure BlinkCalc(const av: array of variant; un,ord: longint; const nmus,skipuser,skipreason: string;
  d: TDateTime; status: TValueSign; equal: TEdoEqual; var lBreak: boolean);
begin
  AddStack('FEdoLs.BlinkCalc');
  lBreak := (nmus=TrimRight(ProgPswd.UserName)) and (status=0);
  DelStack;
end;

procedure NetSelProc;
begin
  AddStack('FEdoLs.NetSelProc');
  if not Assigned(qBlink) then begin
    ApplTitle.Add(TEdoLs.ApplTitleBlink);
    qInBlink:=TMulQuery.CreateConnection(Application.MainForm);
    qBlink:=TMulQuery.CreateConnection(Application.MainForm);
    qPrepare(qInBlink,qBlink);
  end;
  qInBlink.Open; qBlink.Open;
  Blinked:=ApplTitle.SetActive('На подпись',qCalcBreak(qInBlink,qBlink,BlinkCalc,[]));
  qInBlink.Close; qBlink.Close;
  DelStack;
end;

{ TEdoLs }
procedure TEdoLs.FormCreate(Sender: TObject);
var fl: boolean;
  s: string;
  l: longint;
  a: TDEPrmVar;
  ap: TDEPrmStr;
  fmt: TMSOFmtList;
begin
  AddStack('TEdoLs.FormCreate',Self);
  if Self<>EdoLs then FreeAndNil(Rec);
  inherited;
  with BrQuery1 do Init(DBMain,[],[fRECNO,FldDuplicate(fRECNO)],tEDOIN,[],QryNone,'',BrQuery1CalcFields);
  if IsMain then with KeyLb1 do begin
    l:=Length(aStatus);
    InitArr(a);
    a[deCaption]:='Статус';
    a[deNameRec]:=Rec.NameRec;
    SchemDM.BoolMultiGetBound.AssignGet(a);
    a[deMask]:=ArrayAsList(aStatus,mniDlm);
    a[deNoReadOnly]:=true;
    for fl:=false to true do begin
      a[deNameRecFld]:='STATUS'+bStr[fl];
      if fl then s:=SetByte(l) else s:=SetByte([offsStatus+0]);
      Rec.CreateFld(a[deNameRecFld],ftString,l,s);
      deFlt.CreateFld(a,'D1');
    end;
    Rec.CreateFld(fEDOEXE,ftString,EdoDM.Exe.FldName(fEDOEXE).Info.Size,'','Программа');
    Rec.GetAFieldValue(aFltDef); Rec.RestFromIni; Mode:=TEdoModes(byte(Rec['MODE']));
    SetKey(K_Ctrl_F5,'','Программы и пользователи',Browl1BrowlKey,'edo',kmServic,'LEDO');
    SetKey(K_Ctrl_F6,'','Виды ЭДО',Browl1BrowlKey,'edo',kmServic,'LEDO');
    SetKey(K_F12,'Фильтр','',Browl1BrowlKey,'edo',kmList);
    deFlt.GetArrParam('ORGS',l,ap);
    fl:=not EdoProc(edoOrgsGet,[longint(@ap)],false); ap[deNoVisible]:=bStr[fl];
    if fl then Rec['ORGS']:='';
    deFlt.SetArrParam(l,ap);
  end
  else begin
    Mode:=EdoLs.Mode+[edomdAll]; deFlt.Free;
  end;
  SetQry; lsInf:=TStringList.Create;
  qInInf:=TMulQuery.CreateConnection(Self); qInf:=TMulQuery.CreateConnection(Self); qPrepare(qInInf,qInf);
  TSpGkLs.GetPrm(deSkip,tEDO,'SKIPREASON');
  l:=FmtKeyBeg;
  for fmt:=FmtBeg to high(aEdoFmt) do begin
    dmFmt.InsertKey(l,aEdoFmt[fmt]); Inc(l);
  end;
  DelStack;
end;

procedure TEdoLs.FormDestroy(Sender: TObject);
begin
  AddStack('TEdoLs.FormDestroy',Self);
  if IsMain then begin
    Rec['MODE']:=byte(Mode); Rec.SaveToIni;
  end;
  lsInf.Free;
  inherited;
  DelStack;
end;

class procedure TEdoLs.Execute;
var ao: TArrFldVal;
  oMode: TEdoModes;
begin
  AddStack('TEdoLs.Execute');
	CreateForm(TEdoLs,EdoLs,false);
  with EdoLs do begin
    oMode:=Mode; Rec.GetAFieldValue(ao);
    Mode:=AMode; Rec.SetAFieldValue(aFltDef); FltVD:=vd; FltRSOURCE:=rsource;
    RbPanel2.Header:=Head;
    SetQry; ShowModal;
    if not FormFree(EdoLs) then begin
      Mode:=oMode; Rec.SetAFieldValue(ao); FltVD:=0; SetQry; RbPanel2.Header:='';
    end;
  end;
  DelStack;
end;

function TEdoLs.IsMain;
begin
  AddStack('TEdoLs.IsMain',Self);
  result:=Assigned(Rec);
  DelStack;
end;

procedure TEdoLs.WMFormLimit;
begin
  AddStack('TEdoLs.WMFormLimit');
  inherited;
  if not FreeLimit(EdoLs) then FreeLimit(EdoLs2);
  DelStack;
end;

procedure TEdoLs.WMSaveIni;
begin
  AddStack('TEdoLs.WMSaveIni',Self);
  if not IsMain then Msg.pSection^:='EdoLs2';
  DelStack;
end;

procedure TEdoLs.WMCngPriv;
var tr: longint;
  ii: variant;
begin
  AddStack('TEdoLs.WMCngPriv',Self);
  tr:=Browl1.Row; ii:=FltBefore; SetQry; FltAfter(tr,ii);
  DelStack;
end;

procedure TEdoLs.WMCngTabu;
begin
  WMCngPriv(msg);
end;

function TEdoLs.FltBefore;
begin
  AddStack('TEdoLs.FltBefore',Self);
  result:=VarArrayOf([BrQuery1RECNO.AsInteger,BrQuery1RECNO1.AsInteger]);
  DelStack;
end;

procedure TEdoLs.FltAfter;
begin
  AddStack('TEdoLs.FltAfter',Self);
  Browl1.BrUpdate(tr,ii,BrQuery1.SeekKeys); MainRebuild;
  DelStack;
end;

function TEdoLs.GetLog;
  function sCapt(const Capt: string; nf: byte): string;
  begin
    AddStack('TEdoLs.GetLog',Self);
    result:=TrimRight(ProgPswd.CurQuery.Fields[nf].AsString);
    if result<>'' then IncL(result,Capt+': ');
    DelStack;
  end;
var usnm: string;
begin
  AddStack('TEdoLs.GetLog',Self);
  result:=InCapt;
  with ProgPswd.GetQuery do begin
    PartSelect(tEDO,['D','ACT',fEDOEXE,fUSERNAME,'SKIPUSER','SKIPREASON'],
      fEDOIN+'='+Vtos(BrQuery1UN),'D');
    while not Eof do begin
      usnm:=Fields[3].AsString;
      IncD(result,CRLF+CRLF+DlmBetween(
        [OurFormatDateTime(EdoFmtDate,Fields[0].AsFloat)+': '+FRup(EdoDM.ExeOrAct(Fields[1],Fields[2]))
        ,'Пользователь: '+DlmBetween(usnm,ProgPswd.UserGet.CodeName(usnm,[cdgBufAll]),' - ')
        ,sCapt('Пропущен',4)
        ,sCapt('Причина пропуска',5)
        ],CRLF));
      Next;
    end;
  end;
  ProgPswd.FreeQuery;
  DelStack;
end;

procedure TEdoLs.SetQry;
var w: string;
  procedure wDate(const t,fDB,fDE: string);
  var d: TDateTime;
    f: string;
  begin
    AddStack('TEdoLs.SetQry.wDate',Self);
    f:=t+'.D';
    d:=Rec[fDB];
    if not empty(d) then IncAnd(w,f+'>='+Vtos(trunc(d)));
    d:=Rec[fDE];
    if not empty(d) then IncAnd(w,f+'<'+Vtos(trunc(d)+1));
    DelStack;
  end;
const
  aAll: TArrBoolNamePrimStr =
    (('Текущие','Документы текущего пользователя')
    ,('Все'    ,'Документы всех пользователей')
    );
  aArh: TArrBoolStr = ('Без архива','Архив');
var s: string;
  status: TValueSign;
  tp: TEdoExeType;
  lsf: TMQFieldList;
  q: TMulQuery;
  l: longint;
begin
  AddStack('TEdoLs.SetQry',Self);
  if IsMain then if not CanPriv('LEDOALL') then Exclude(Mode,edomdAll);
  with BrQuery1 do begin
    ClearFilter; SetQry(BrQuery1,Mode,false);
    Orders.Text:=Arg[sO_LIST];
    while FieldCount>0 do Fields[0].Free;
    FieldDefs.Update;
    BrQuery1RECNO:=CreateField(fRECNO);
    BrQuery1RECNO1:=CreateField(FldDuplicate(fRECNO));
    BrQuery1ORD:=CreateField(fEDOORD);
    if IsMain then begin
      BrQuery1D:=CreateField('D');
      BrQuery1CD:=CreateStringField('CD','Дата создания',Length(EdoFmtDate),taCenter);
      BrQuery1VD:=CreateField('VD');
      BrQuery1COD:=CreateField('COD');
      BrQuery1CVD:=CreateStringField('CVD','Вид',MaxSelf(EdoGetDokVdNames^));
      BrQuery1CCOD:=CreateStringField('CCOD','Код',BrQuery1COD.Size);
      BrQuery1NAME:=CreateStringField(fNAME,'',30);
      BrQuery1CVD.Visible := FltVD=0;
      BrQuery1CCOD.Visible := FltVD=0;
      BrQuery1NAME.Visible := FltVD=0;
      BrQuery1PRIM:=CreateStringField('PRIM','',30);
      BrQuery1UN:=CreateIntegerField(fEDOIN);
      BrQuery1ORG:=CreateStringField(fEdoORG,'Орг.',0,taRightJustify);
      BrQuery1ORG.Visible:=EdoProc(edoOrgGet,[],false);
      BrQuery1RTF:=CreateField(aEdoFile[false]);
      BrQuery1CRTF:=CreateBooleanField('CRTF','Файл');
      BrQuery1SHIFRED:=CreateStringField('SHIFRED');
      BrQuery1KV:=CreateField(fEDOVD);
      BrQuery1NC:=CreateField(fEdoNC);
    end
    else begin
      BrQuery1D:=nil; BrQuery1VD:=nil; BrQuery1CRTF:=nil; BrQuery1SHIFRED:=nil;
      BrQuery1UN:=pointer(CreateField(fEDOIN));
    end;
    BrQuery1USERNAME:=CreateField(fUSERNAME);
    if edomdAll in Mode
    then BrQuery1CUSERNAME:=CreateStringField('CUSERNAME','Пользователь',BrQuery1USERNAME.Size)
    else BrQuery1CUSERNAME:=nil;
    FltStatus:=false; FltD1:=false; AfterScroll:=nil;
    if edomdArh in Mode then begin
      BrQuery1STATUS:=nil; BeforeOpen:=nil; Browl1.OnGrayCell:=nil;
      BrQuery1D1:=CreateField(FldDuplicate('D',IfThen(IsMain,1)));
      BrQuery1SKIPUSER:=CreateField('SKIPUSER');
      BrQuery1SKIPREASON:=CreateField('SKIPREASON');
    end
    else begin
      BrQuery1STATUS:=CreateIntegerField('STATUS'); BrQuery1STATUS.Visible:=false;
      BrQuery1CSTATUS:=CreateStringField('CSTATUS','Статус',Max(Length(StatusSkip),MaxSelf(aStatus)));
      BeforeOpen:=BrQuery1BeforeOpen; Browl1.OnGrayCell:=Browl1GrayCell;
      if IsMain then begin
        d1b:=Rec['D1B']; d1e:=Rec['D1E'];
        FltD1:=GetByte(Rec['STATUS'+bStr[edomdAll in Mode]],offsStatus+1) and not(empty(d1b) and empty(d1e));
        ReplDateEmptyBigSelf(d1e);
        s:=Rec['STATUS'+bStr[edomdAll in Mode]];
        for status:=low(stStatus) to high(stStatus) do begin
          stStatus[status]:=GetByte(s,offsStatus+status);
          if not stStatus[status] then FltStatus:=true;
        end;
      end;
      BrQuery1D1:=nil;
    end;
    SetFilterProc(FltStatus or FltD1,BrQuery1FilterRecord);
    BrQuery1CD1:=CreateStringField('CD1','Дата подписания',Length(EdoFmtDate),taCenter);
    BrQuery1ACT:=CreateField('ACT');
    BrQuery1KE:=CreateField(fEDOEXE);
    BrQuery1CKE:=CreateStringField('CKE','Программа/действие',max(GetFieldList(tEDOEXE).Fields(fNAME).Size,MaxSelf(aEdoActAbr)));
    lsf:=GetFieldList(tEDO);
    BrQuery1CSKIPUSER:=CreateStringField('CSKIPUSER','Кем пропущен',lsf.Fields('SKIPUSER').Size);
    BrQuery1CSKIPREASON:=CreateStringField('CSKIPREASON','Причина пропуска',lsf.Fields('SKIPREASON').Size);
  end;
  if IsMain then begin
    if edomdArh in Mode then s:='архив'
    else begin
      q:=ProgPswd.GetQuery; SetQry(q,Mode+[edomdArh],true); q.Open; l:=q.Fields[0].AsInteger; ProgPswd.FreeQuery;
      if l=0 then s:=''
      else begin
        s:=Format('без архива, в архиве %d ',[l]); ModD(l,10);
        IncD(s,IfThen(l=1,'документ',IfThen(l in [2,3,4],'документа','документов')));
      end;
    end;
    Caption:=DlmBetween(aAll[edomdAll in Mode,2],BrackNoEmp(s),' ');
    with KeyLb1 do begin
      SetKey(K_Ctrl_Tab,aAll[not(edomdAll in Mode),1],aAll[not(edomdAll in Mode),2],Browl1BrowlKey,'edo',kmList,'LEDOALL');
      SetKey(K_Tab,aArh[not(edomdArh in Mode)],'',Browl1BrowlKey,'edo',kmList);
      if edomdAll in Mode
      then DelKey(K_F2,'edo')
      else SetKey(K_F2,'Подписывающие','Пользователи, подписывающие документ',Browl1BrowlKey,'edo',kmList);
      if edomdArh in Mode
      then DelKey(K_Shift_F2,'edo')
      else SetKey(K_Shift_F2,'Порядок','Последовательность подписания документа',Browl1BrowlKey,'edo',kmList);
      if (edomdAll in Mode) and not(edomdArh in Mode) and CanPriv('LEDO')
      then SetKey(K_Ctrl_F3,'Пропустить','',Browl1BrowlKey,'edo',kmList)
      else DelKey(K_Ctrl_F3,'edo');
      for tp:=low(aExeKey) to high(aExeKey) do with aExeKey[tp] do
        if (tp=edoexePodp) and ((edomdArh in Mode) or (edomdAll in Mode))
        then DelKey(k,'edo')
        else begin
          SetKey(k,txt,'',Browl1BrowlKey,'edo',kmList);
          if tp=edoexePodp then BrQuery1.AfterScroll:=BrQuery1AfterScroll;
        end;
      if edomdArh in Mode
      then DelKey(K_All,'edortf')
      else begin
        SetKey(K_F7,'','Выгрузить в файл исходного формата для преобразования в конечный',Browl1BrowlKey,'edortf',kmList);
        SetKey(K_Ctrl_F7,'','Загрузить файл, преобразованный в конечный формат',Browl1BrowlKey,'edortf',kmList);
      end;
      SetKey(K_F8,'Удалить','',Browl1BrowlKey,'edo',kmList,'LEDO');
      SetKey(K_Ctrl_F8,'Переподписать','',Browl1BrowlKey,'edo',kmList,'LEDO');
      SetKey(K_Enter,'Документ','Просмотр документа',Browl1BrowlKey,'edo',kmList);
      SetKey(K_Shift_Enter,'Исх.файл','Просмотр исходного файла',Browl1BrowlKey,'edo',kmList);
      SetKey(K_Ctrl_Enter,'Файл','Просмотр файла',Browl1BrowlKey,'edo',kmList);
      SetKey(K_Shift_F5,'Протокол','Протокол подписания документа',Browl1BrowlKey,'edo',kmList);
      SetKey(K_Shift_F7,'Приложения','',Browl1BrowlKey,'edo',kmList);
      SetKey(K_Shift_F8,'','Удалить документы до указанной даты',Browl1BrowlKey,'edo',kmList,'LEDO');
    end;
  end
  else Caption:=EdoLs.InCapt;
  DelStack;
end;

procedure TEdoLs.SetQry(q: TMulQuery; Mode: TEdoModes; lcnt: boolean);
var w: string;
  procedure wDate(const t,fDB,fDE: string);
  var d: TDateTime;
    f: string;
  begin
    AddStack('TEdoLs.SetQry(q).wDate');
    f:=t+'.D';
    d:=Rec[fDB];
    if not empty(d) then IncAnd(w,f+'>='+Vtos(trunc(d)));
    d:=Rec[fDE];
    if not empty(d) then IncAnd(w,f+'<'+Vtos(trunc(d)+1));
    DelStack;
  end;
var tu,t,o,s: string;
  ls: TStringList;
  l: longint;
  a: TArrStr;
begin
  AddStack('TEdoLs.SetQry(q)');
  tu:=IfThen(edomdArh in Mode,tEDO,tEDOORD);
  if lcnt then begin
    q.Arg[sC_LIST]:=sCOUNTZV; o:='';
  end
  else begin
    q.SetArrayList(sC_LIST,[tRecno(tEDOIN),tRecno(tu),tEDOIN+'.'+fEDOIN,tu+'.'+fEDOORD,tEDOIN+'.SHIFRED',
      tEDOIN+'.'+aEdoFile[false]]);
    if IsMain then q.AddArrayList(sC_LIST,[tEDOIN+'.D',tEDOIN+'.VD',tEDOIN+'.COD',tEDOIN+'.'+fNAME,
      tEDOIN+'.PRIM',tEDOIN+'.'+fEdoORG,tEDOIN+'.'+fEDOVD,tEDOIN+'.'+fEdoNC]);
    o:=tEDOIN+'.D,'+tEDOIN+'.'+fEDOIN;
  end;
  if edomdArh in Mode then begin
    t:=q.GetList([tEDOIN,tEDO]);
    w:=tEDO+'.'+fEDOIN+'='+tEDOIN+'.'+fEDOIN;
    if IsMain then
      if GetByte(Rec['STATUS'+bStr[edomdAll in Mode]],offsStatus+1) then wDate(tEDO,'D1B','D1E');
    if not lcnt then begin
      q.AddArrayList(sC_LIST,[tEDO+'.'+fUSERNAME,tEDO+'.D',tEDO+'.ACT',tEDO+'.'+fEDOEXE,tEDO+'.SKIPUSER',tEDO+'.SKIPREASON']);
      IncD(o,','+tEDO+'.D');
    end;
  end
  else begin
    qPrepare(t,w);
    if not lcnt then begin
      q.AddArrayList(sC_LIST,[tEDOORD+'.'+fUSERNAME,tEDOORD+'.ACT',tEDOORD+'.'+fEDOEXE]);
      if edomdAll in Mode then IncD(o,','+tEDOORD+'.'+fEDOORD);
    end;
  end;
  IncAnd(w,FldIsTrue(tEDOIN+'.INARH',edomdArh in Mode));
  if not(edomdAll in Mode) then IncAnd(w,tu+'.'+fUSERNAME+'='+QQs(ProgPswd.UserName));
  if IsMain then begin
    wDate(tEDOIN,'DB','DE');
    s:=Rec['USERS'];
    if not Empty(s) then IncAnd(w,FldInListQQ(tu+'.'+fUSERNAME,s));
    s:=Rec['KVS'];
    if not Empty(s) then begin
      l:=LsArrDynamic(s,a,','); SpaceStrSelf(a,l,GetFieldList(tEDOIN).Fields(fEDOVD).Size);
      IncAnd(w,FldInListQQ(tEDOIN+'.'+fEDOVD,a,l));
    end;
    s:=Rec['ORGS'];
    if not empty(s) then begin
      ls:=TStringList.Create;
      try
        EdoProc(edoOrgLs,[s,longint(ls)]); IncAnd(w,FldInListQQ(tEDOIN+'.'+fEdoORG,ls));
      finally
        ls.Free;
      end;
    end;
    if EdoProc(edoOrgTabu,[longint(@s)]) then if TTabuLs.CheckList([s],ls)
    then IncAnd(w,FldInListQQ(tEDOIN+'.'+fEdoORG,ls,true));
  end
  else IncAnd(w,tEDOIN+'.'+fEDOIN+'='+Vtos(EdoLs.BrQuery1UN));
  if FltVD>0 then IncAnd(w,'VD='+Vtos(FltVD)+sAND+'RSOURCE='+Vtos(FltRSOURCE));
  q.PartSelect(t,'',w,o,'',false);
  DelStack;
end;

function TEdoLs.InCapt;
begin
  AddStack('TEdoLs.InCapt',Self);
  result:=EdoInCapt(BrQuery1VD.AsInteger,BrQuery1CCOD.AsString,BrQuery1NAME.AsString,BrQuery1PRIM.AsString,
    BrQuery1D.AsFloat,Opt+[edoinNoCodTrns]);
  DelStack;
end;

procedure lsStatCalc(const av: array of variant; un,ord: longint; const nmus,skipuser,skipreason: string;
  d: TDateTime; status: TValueSign; equal: TEdoEqual; var lBreak: boolean);
var lsInf: TStringList;
  aInf: ^TArrEdoInf;
  i: longint;
begin
  AddStack('FEdoLs.lsStatCalc');
  lsInf:=PointerVar(av[0]); aInf:=PointerVar(av[1]);
  i:=lsInf.Count; lsInf.AddObject(StrUn(un)+StrUn(ord)+nmus,pointer(i));
  aInf^[i].d:=d; aInf^[i].skipuser:=skipuser; aInf^[i].skipreason:=skipreason;
  aInf^[i].status:=status; aInf^[i].equal:=equal;
  DelStack;
end;

procedure TEdoLs.BrQuery1BeforeOpen;
var l: longint;
begin
  AddStack('TEdoLs.BrQuery1BeforeOpen',Self);
  qInInf.Open; qInf.Open; l:=qInInf.RecordCount;
  lsInf.Sorted:=false; lsInf.Clear; lsInf.Capacity:=l; SetLength(aInf,l);
  qCalcBreak(qInInf,qInf,lsStatCalc,[longint(lsInf),longint(@aInf)]);
  lsInf.Sorted:=true; qInInf.Close; qInf.Close;
  DelStack;
end;

procedure TEdoLs.BrQuery1CalcFields;
var vd: longint;
  cod: string;
begin
  AddStack('TEdoLs.BrQuery1CalcFields',Self);
  if Assigned(BrQuery1D) then BrQuery1CD.AsString:=OurFormatDateTime(EdoFmtDate,BrQuery1D.AsFloat);
  if Assigned(BrQuery1VD) then begin
    vd:=BrQuery1VD.AsInteger; BrQuery1CVD.AsString:=EdoGetDokVdNames^[vd];
    if Assigned(BrQuery1COD) then begin
      cod:=BrQuery1COD.AsString; EdoProc(edoCod,[vd,longint(@cod)]); BrQuery1CCOD.AsString:=cod;
    end;
  end;
  if Assigned(BrQuery1CUSERNAME) then BrQuery1CUSERNAME.AsString:=BrQuery1USERNAME.AsString;
  if Assigned(BrQuery1D1) then begin
    BrQuery1CD1.AsString:=OurFormatDateTime(EdoFmtDate,BrQuery1D1.AsFloat);
    BrQuery1CSKIPUSER.AsString:=BrQuery1SKIPUSER.AsString;
    BrQuery1CSKIPREASON.AsString:=BrQuery1SKIPREASON.AsString;
  end;
  if Assigned(BrQuery1STATUS) then with Inf^ do begin
    if not Assigned(BrQuery1D1) then begin
      if not empty(d) then BrQuery1CD1.AsString:=OurFormatDateTime(EdoFmtDate,d);
      BrQuery1CSKIPUSER.AsString:=skipuser;
      BrQuery1CSKIPREASON.AsString:=skipreason;
    end;
    BrQuery1STATUS.AsInteger:=status;
    BrQuery1CSTATUS.AsString:=IfThen(skipuser='',aStatus[status],StatusSkip);
  end;
  if Assigned(BrQuery1CRTF) then BrQuery1CRTF.AsBoolean := BrQuery1RTF.AsInteger>0;
  if Assigned(BrQuery1CKE) then BrQuery1CKE.AsString:=EdoDM.ExeOrAct(BrQuery1ACT,BrQuery1KE);
  DelStack;
end;

procedure TEdoLs.BrQuery1AfterScroll;
const aAct: TEdoActStr = (cKeyPodp,'Выгрузить','Загрузить');
var tb: PKeyBut;
begin
  AddStack('TEdoLs.BrQuery1AfterScroll',Self);
  if KeyLb1.SeekKey(K_F3,tb) then begin
    tb.Caption:=aAct[TEdoAct(BrQuery1ACT.AsInteger)]; KeyLb1.ReDrw;
  end;
  DelStack;
end;

function TEdoLs.Inf;
begin
  AddStack('TEdoLs.Inf',Self);
  result:=@aInf[IntObjFind(lsInf,StrUn(BrQuery1UN.AsInteger)+StrUn(BrQuery1ORD.AsInteger)+TrimRight(BrQuery1USERNAME.AsString))];
  DelStack;
end;

procedure TEdoLs.BrQuery1FilterRecord;
begin
  AddStack('TEdoLs.BrQuery1FilterRecord',Self);
  with Inf^ do begin
    if FltStatus then Accept:=stStatus[status];
    if Accept then if FltD1 then Accept:=InRange(d,d1b,d1e);
  end;
  DelStack;
end;

procedure TEdoLs.Browl1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  AddStack('TEdoLs.Browl1DrawColumnCell',Self);
  Browl1.bmCheckPaint(Rect,Column,[BrQuery1SHIFRED,BrQuery1CRTF]);
  DelStack;
end;

procedure DelTbl(r: TRecDB; const where: string; q: TMulQuery = nil);
var i,j,oLogVid: longint;
  a: TArrStr;
  noq: boolean;
begin
  AddStack('FEdoLs.DelTbl');
  oLogVid:=CngLogVid(logvDelRec); noq:=not Assigned(q);
  if noq then begin
    q:=ProgPswd.GetQuery; q.PartSelect(r.NameDB,[],where);
  end;
  j:=q.RecordCount; SetLength(a,j); Dec(j);
  for i:=0 to j do begin
    r.GetFromQuery(q); a[i]:=r.LogPrim; q.Next;
  end;
  r.DelRec(q.Arg[sWHERE]);
  for i:=0 to j do r.LogWrite(a[j]);
  if noq then ProgPswd.FreeQuery;
  CngLogVid(oLogVid);
  DelStack;
end;

procedure TEdoLs.Browl1BrowlKey(key: Integer; tw: TWinControl);
  function brk(usl: boolean; const amsg: array of string): boolean;
  begin
    AddStack('TEdoLs.Browl1BrowlKey.brk',Self);
    result:=not usl;
    if result then MsgDlg(amsg);
    DelStack;
  end;
  procedure SetMode(md: TEdoMode);
  begin
    AddStack('TEdoLs.Browl1BrowlKey.SetMode',Self);
    if md in Mode then Exclude(Mode,md) else Include(Mode,md);
    DelStack;
  end;
  function IsIn: boolean;
  begin
    AddStack('TEdoLs.Browl1BrowlKey.IsIn',Self);
    result:=Browl1.UpdateCur;
    if not result then mess_ok(['Указанный документ отсутствует',
      '(возможно, был удалён другим пользователем).',InCapt,'Список был обновлён.']);
    DelStack;
  end;
  function fDel(const FileName: string): boolean;
  begin
    AddStack('TEdoLs.Browl1BrowlKey.fDel',Self);
    if FileExists(FileName) then begin
      result:=DelFileAtr(FileName);
      if not result then MsgDlg(['Ошибка удаления файла:',FileName]);
    end
    else result:=true;
    DelStack;
  end;
  function fRead(const FileName: string; lOut: boolean = false): boolean;
  begin
    AddStack('TEdoLs.Browl1BrowlKey.fRead',Self);
    EdoDM.Inn[aEdoFile[lOut]]:=GetStrFile(FileName,MaxInt,@result);
    if result then
      if lOut
      then EdoDM.Inn[sMemo+'FSIG']:=ExtractFileName(FileName)
      else EdoDM.Inn['EXT']:=ExtractFileExt(FileName)
    else MsgDlg(['Ошибка чтения файла:',FileName]);
    DelStack;
  end;
var dFile: PDateTime;
  function fWrite(const FileName,txt: string; lRtf: boolean = true): boolean; overload;
  begin
    AddStack('TEdoLs.Browl1BrowlKey.fWrite',Self);
    result:=ForceDirMsg(ExtractFilePath(FileName));
    if result then begin
      result:=SetStrFile(FileName,txt);
      if not result then MsgDlg(['Ошибка записи в файл:',FileName])
      else if lRtf then begin
        if not Assigned(dFile) then with ProgPswd.GetQuery do begin
          PartMax(tEDO,'D',fEDOIN+'='+Vtos(EdoDM.Inn[fEDOIN])); New(dFile); dFile^:=Fields[0].AsFloat;
          ProgPswd.FreeQuery;
        end;
        if dFile^<>0 then SetFileDateTime(FileName,dFile^);
      end;
    end;
    DelStack;
  end;
  function fWrite(const FileName: string; lRtf: boolean = true; lOut: boolean = false): boolean; overload;
  begin
    result:=fWrite(FileName,string(EdoDM.Inn[IfThen(lRtf,aEdoFile[lOut],sMemo+'DTG')]),lRtf);
  end;
  function CallFdp(lShow: boolean): boolean;
  var fdcm,fdtg: string;
  begin
    AddStack('TEdoLs.Browl1BrowlKey.CallFdp',Self);
    fdtg:='';
    result:=EdoProc(edoFdpPrepare,[BrQuery1VD.AsInteger,BrQuery1COD.AsString,longint(@fdcm),longint(@fdtg)],true);
    if result then begin
      ReplVarSelf(fdtg,fdcm); result:=fWrite(FullNameExe(fdtg,'DTG'),false);
      if result
      then Fdp(InCapt,nil,[fdcm,fdtg],fdpView,[fdoReadOnly,fdoNoEdo],'',nil,nil,nil,nil,nil,nil,nil,nil,lShow);
    end
    else MsgDlg(['Документ отсутствует в базе данных.',InCapt([edoinNoName,edoinNoPrim,edoinNoD])]);
    DelStack;
  end;
  function deFileExec(dlg: TOpenDialog; const nmf,Title: string; ChkDir: boolean = true): boolean;
  var a: TDEPrmStr;
    i: longint;
  begin
    AddStack('TEdoLs.Browl1BrowlKey.deFileExec',Self);
    if Assigned(dlg) then dlg.Title:=Title;
    with FileGet do begin
      OpenDialog:=dlg;
      if ChkDir
      then IncOptions([],[dgNoCheckDir])
      else IncOptions([dgNoCheckDir]);
    end;
    with deFile do begin
      GetArrParam(0,i,a); a[deNameRecFld]:=nmf; SetArrParam(i,a);
      result:=Execute(Title+': '+InCapt).Saved;
    end;
    DelStack;
  end;
var fmt: TMSOFmtList;
  function GetFmt: boolean;
  begin
    AddStack('TEdoLs.Browl1BrowlKey.GetFmt',Self);
    if fmt=msoFmtDefault then begin
      result:=dmFmt.Execute(@FmtKey);
      if result then fmt:=TMSOFmtList(byte(FmtBeg)+FmtKey-FmtKeyBeg);
    end
    else result:=true;
    DelStack;
  end;
  function Dtg2Rtf(const fRtf: TFileName): boolean;
  begin
    AddStack('TEdoLs.Browl1BrowlKey.Dtg2Rtf',Self);
    result:=false;
    try
      EdoInFdp:=EdoDM.Inn;
      if CallFdp(false) then begin
        if fDel(fRtf) then if ForceDirMsg(ExtractFilePath(fRtf))
        then result:=DcmMsOff(fRtf,msoEdDefine,fmt,msoTwTable,null);
        FdpClose;
      end;
    finally
      EdoInFdp:=nil;
    end;
    DelStack;
  end;
var RtfFmt: boolean;
  procedure SeekVd;
  begin
    AddStack('TEdoLs.Browl1BrowlKey.SeekVd',Self);
    EdoDM.Vd.Seek(tEDOVD+'.'+fEDOVD+'='+QQs(BrQuery1KV));
    fmt:=EdoDM.Vd['FMT']; RtfFmt:=StrToBoolean(EdoDM.Vd['RTFFMT']);
    DelStack;
  end;
var FInnSeek: boolean;
  procedure InnSeek;
  begin
    AddStack('TEdoLs.Browl1BrowlKey.InnSeek',Self);
    if FInnSeek then begin
      FInnSeek:=false; EdoDM.Inn.GotoRec(BrQuery1RECNO);
    end;
    DelStack;
  end;
  function GetFile(FromInn: boolean = true; WithExt: boolean = true): string;
  var ValidFileName: TInvalidFileName;
  begin
    AddStack('TEdoLs.Browl1BrowlKey.GetFile',Self);
    InnSeek;
    InitArr(ValidFileName,low(ValidFileName),high(ValidFileName),'_');
    result:=StrTran(StrTran(InCapt([edoinNoVdCod,edoinNoD]),InvalidFileName,ValidFileName),['(',')'],['[',']'])
      +Format('[%d]',[BrQuery1UN.AsInteger])
      +IfThen(WithExt,IfThen(RtfFmt or FromInn,Trim(EdoDM.Inn['EXT']),'.'+aEdoFmt[fmt]));
    DelStack;
  end;
  function IsEdo: boolean;
  begin
    AddStack('TEdoLs.Browl1BrowlKey.IsEdo',Self);
    if edomdArh in Mode
    then result:=true
    else begin
      result := not(edoeqFirst in Inf.equal);
      if not result then MsgDlg('Данный документ ещё никем не подписан.');
    end;
    DelStack;
  end;
  function IsRtf: boolean;
  begin
    AddStack('TEdoLs.Browl1BrowlKey.IsRtf',Self);
    result:=BrQuery1CRTF.AsBoolean;
    if not result then MsgDlg('Данный документ необходимо преобразовать из исходного формата в конечный.');
    DelStack;
  end;
  procedure DelTbl(r: TRecDB);
  begin
    FEdoLs.DelTbl(r,fEDOIN+'='+Vtos(BrQuery1UN));
  end;
const aExeCtrlIO: array[boolean] of TEdoExeCtrl = (edoctlIn,edoctlOut);
var tr,i: longint;
  ii: variant;
  fl,io,lEval,lSkip: boolean;
  a: TArrStr;
  ap: TDEPrmStr;
  s,s1,s2,sc,ke: string;
  af: TArrGetFld;
  fmt0: TMSOFmtList;
  equal: TEdoEqual;
  rde: TDEExitResult;
  act: TEdoAct;
  tp: TEdoExeType;
  aExeCtrl: TEdoExeCtrlStr;
label lend,lend1;
begin
  AddStack('TEdoLs.Browl1BrowlKey',Self);
  if BrQuery1.CanEdit(Key,[K_F12,K_Tab,K_Ctrl_F5,K_Ctrl_F6,K_Ctrl_Tab],false) then begin
    FInnSeek:=true; dFile:=nil;
    try
      case Key of
        K_F2: if IsIn then CreateShow(TEdoLs,EdoLs2,true);
        K_F7,K_Ctrl_F7: begin
          if Key=K_Ctrl_F7 then SetLogVid(logvEditRec);
          fmt0:=low(fmt0); // Variable might not have been initialized
          for lEval:=false to true do begin
            if IsIn then
              if edoeqFirst in Inf.equal then begin
                SeekVd;
                if RtfFmt then
                  if lEval then begin
                    InnSeek;
                    case Key of
                      K_F7: begin
                        fmt:=fmt0; Dtg2Rtf(Trim(Rec['FSAVE']));
                      end;
                      K_Ctrl_F7: begin
                        s:=Trim(Rec['FOPEN']);
                        if fRead(s) then begin
                          LogFields.Clear; EdoDM.Inn.UpdateRec(true); mess_ok(['Файл '+s,'загружен успешно.']);
                        end;
                      end;
                    end;
                  end
                  else case Key of
                    K_F7: begin
                      if not GetFmt then break;
                      fmt0:=fmt;
                      dlgFileSave.Filter:='Файлы '+aEdoFmt[fmt]+'|*.'+aEdoFmt[fmt]+'|Все файлы|*.*';
                      s:=Trim(Rec['FSAVE']);
                      if s<>'' then Rec['FSAVE']:=FileWithOutExt(s)+'.'+aEdoFmt[fmt];
                      if deFileExec(dlgFileSave,'FSAVE',
                      'Выгрузить в файл исходного формата для преобразования в конечный',false)
                        then continue;
                    end;
                    K_Ctrl_F7: if deFileExec(dlgFileOpen,'FOPEN',
                      'Загрузить файл, преобразованный в конечный формат') then continue;
                  end
                else MsgDlg(['Вид ЭДО «'+Trim(EdoDM.Vd[fNAME])+'»',
                  'не использует конвертацию исходного формата в конечный.'])
              end
              else MsgDlg('Данный документ уже подписан некоторыми пользователями.');
            break;
          end;
          if Key=K_Ctrl_F7 then SetLogVid;
        end;
        K_F8,K_Ctrl_F8: begin
          SetLogVid(logvDelRec);
          for lEval:=false to true do begin
            if IsIn then begin
              if Key=K_Ctrl_F8 then begin
                fl:=IsEdo;
                if fl then SeekVd;
              end
              else fl:=true;
              if fl then
                if lEval then begin
                  if TrnsStart([tEDOIN,tEDOORD,tEDOAPP,tEDO]) then try
                    ProgPswd.GetQuery; DelTbl(EdoDM.Edo); InnSeek;
                    case Key of
                      K_F8: with BrQuery1 do begin
                        DelTbl(EdoDM.Ord); DelTbl(EdoDM.App); 
                        tr:=Browl1.Row; DisableControls; EdoDM.Inn.DelRec('',[delLog]); Next;
                        FltAfter(tr,FltBefore);
                        EnableControls;
                      end;
                      K_Ctrl_F8: begin
                        EdoInOrd;
                        ProgPswd.CngLogVid(logvEditRec);
                        EdoDM.Inn[aEdoFile[true]]:='';
                        EdoDM.Inn[sMemo+'FSIG']:='';
                        EdoDM.Inn['INARH']:=bFalse; EdoDM.Inn['SHIFRED']:=bFalse;
                        EdoDM.Inn.UpdateRec(true);
                        Browl1.UpdateCur;
                      end;
                    end;
                    ProgPswd.FreeQuery; TrnsEnd([trnsCommit]);
                  except
                    TrnsEnd; raise;
                  end;
                end
                else begin
                  case Key of
                    K_F8: CopyFrom(a,amsDel);
                    K_Ctrl_F8: CopyFrom(a,[InCapt,'Удалить всю информацию о подписании ?']);
                  end;
                  if Ask(a) then continue;
                end;
            end;
            break;
          end;
          SetLogVid;
        end;
        K_F12,K_Tab,K_Ctrl_Tab: begin
          tr:=Browl1.Row; ii:=FltBefore; fl:=true;
          case Key of
            K_F12: begin
              for fl:=false to true do
                deFlt.Param['STATUS'+bStr[fl],deNoVisible]:=bStr[((edomdAll in Mode)<>fl) or (edomdArh in Mode)];
              fl:=deFlt.Execute.Saved;
            end;
            K_Tab: SetMode(edomdArh);
            K_Ctrl_Tab: SetMode(edomdAll);
          end;
          if fl then begin
            SetQry; FltAfter(tr,ii);
          end;
        end;
        K_Enter: if IsIn then try
          EdoInFdp:=EdoDM.Inn; EdoInFdp.GotoRec(BrQuery1RECNO); CallFdp(true);
        finally
          EdoInFdp:=nil;
        end;
        K_Ctrl_F5,K_Ctrl_F6:
          if LockMode('Редактирование парамеров ЭДО','FEDOPRM','FEDOPRM>'+VToS,MaxInt,$FFFFFFFF) then try
            case Key of
              K_Ctrl_F5: begin
                CreateShow(TEdoExUs,EdoExUs); fl:=EdoExUs.Modified; FormFree(EdoExUs);
              end;
              K_Ctrl_F6: begin
                CreateShow(TEdoVdLs,EdoVdLs); fl:=EdoVdLs.Modified; FormFree(EdoVdLs);
              end;
            else fl:=false; //Variable might not have been initialized
            end;
            if fl then Browl1.UpdateCur;
          finally
            UnLockMode('FEDOPRM');
          end;
        K_Ctrl_Enter,K_Shift_Enter: if IsIn then begin
          SeekVd;
          if edomdArh in Mode then equal:=[] else equal:=Inf.equal;
          if edoeqFirst in equal then begin
            if RtfFmt then fl:=IsRtf else fl:=GetFmt;
            if fl then begin
              s:=EdoTmpPath+GetFile(false);
              if RtfFmt then fl:=fWrite(s) else fl:=Dtg2Rtf(s);
            end;
          end
          else begin
            aExeCtrl[edoctlIn]:=GetFile;
            aExeCtrl[edoctlOut]:=EdoDM.Inn[sMemo+'FSIG'];
            fl:=true;
            for io:=false to Key=K_Ctrl_Enter do begin
              s1:=aExeCtrl[aExeCtrlIO[io]];
              if s1<>'' then begin
                s:=EdoTmpPath+s1;
                if not fWrite(s,true,io) then begin
                  fl:=false; break;
                end;
              end;
            end;
          end;
          if fl then ShellExecute(0,nil,PChar(s),nil,PChar(ExtractFilePath(s)),SW_SHOW);
        end;
        K_Shift_F2: begin
          i:=BrQuery1UN.AsInteger; s:=BrQuery1KV.AsString; sc:=BrQuery1ORG.AsString; tr:=BrQuery1NC.AsInteger;
          if CanPriv('LEDO')
          then fl:=true
          else fl:=not ProgPswd.PartCount0(tEDOORD,ArrayAsList([fEDOIN+'='+VToS,fEDOVD+'='+QQs(s),
            fEdoORG+'='+QQs(sc),fEdoNC+'='+Vtos(tr),fUSERNAME+'='+QQs(ProgPswd.UserName)],sAND));
          if fl then begin
            if LockMode('Редактирование парамеров документа ЭДО','FEDOPRM',
            FldInList('FEDOPRM',[Vtos(i),Vtos(MaxInt)]),i,$FFFFFFFF) then try
              if TEdoOrdLs.Execute(i,s,sc,tr,InCapt) then Browl1.UpdateCur;
            finally
              UnLockMode('FEDOPRM');
            end;
          end
          else MsgDlg(['Текущий пользователь ('+Trim(ProgPswd.UserName)+') не является администратором ЭДО',
            'и не участвует в подписании данного документа.']);
        end;
        K_Shift_F5: EdTextView('Протокол: '+InCapt,GetLog,'',nil,[edtxtWordWrap]);
        K_Shift_F7: TEdoApLs.Execute(BrQuery1UN.AsInteger,'Приложения: '+InCapt);
        K_Shift_F8: deDel.Execute;
      else
        lSkip := Key=K_Ctrl_F3;
        if lSkip then Key:=aExeKey[edoexePodp].k;
        for tp:=low(aExeKey) to high(aExeKey) do with aExeKey[tp] do if Key=k then begin
          ProgPswd.LogVid:=logv;
          for lEval:=false to true do begin
            if IsIn then begin
              if tp=edoexePodp then EdoDM.Ord.GotoRec(BrQuery1RECNO1);
              SeekVd;
              if tp=edoexePodp then begin
                if brk(BrQuery1STATUS.AsInteger=0,
                ['Подписывать можно только документы','со статусом «'+aStatus[0]+'».'])
                  then goto lend;
                if RtfFmt then if not IsRtf then goto lend;
                act:=EdoDM.Ord['ACT'];
              end
              else begin
                if not IsEdo then goto lend;
                act:=edoaPodp;
              end;
              ke:=TCustomRec(IfThen((tp=edoexePodp) or Assigned(ChkSuccess),EdoDM.Ord,Rec))[fEDOEXE];
              if (act=edoaPodp) and not lSkip then begin
                s:='.'+fEDOEXE+'='+QQs(ke);
                EdoDM.Exe.Seek(tEDOEXE+s); sc:=Trim(EdoDM.Exe[EdoExeFld(tp,edoexeIn)]);
                if EdoDM.Us.Seek(tEDOUS+'.'+fUSERNAME+'='+QQs(ProgPswd.UserName)+sAND+tEDOUS+s) then begin
                  aExeCtrl[edoctlLogin]:=TrimRight(EdoDM.Us['LOGIN']);
                  aExeCtrl[edoctlCert]:=TrimRight(EdoDM.Us['CERT']);
                end
                else begin
                  aExeCtrl[edoctlLogin]:=''; aExeCtrl[edoctlCert]:='';
                end;
              end
              else sc:='';
              if lEval then begin
                if sc<>'' then
                  if brk(aExeCtrl[edoctlLogin]<>'',
                  ['У пользователя '+Trim(ProgPswd.UserName)+' не указано имя',
                  'для запуска программы «'+Trim(EdoDM.Exe[fNAME])+'».'
                  +IfThen(not CanPriv('LEDO'),CRLF+'Обратитесь к администратору ЭДО.')])
                    then goto lend;
                if edomdArh in Mode then equal:=[] else equal:=Inf.equal;
                if not RtfFmt and (edoeqFirst in equal) then if not GetFmt then goto lend;
                aExeCtrl[edoctlIn]:=EdoTmpPath+GetFile(not(edoeqFirst in equal));
                s:=EdoDM.Inn[sMemo+'FSIG'];
                if s='' then
                  if sc=''
                  then aExeCtrl[edoctlOut]:=aExeCtrl[edoctlIn]
                  else aExeCtrl[edoctlOut]:=ReplVar(StrTran(Trim(EdoDM.Exe[EdoExeFld(tp,edoexeOut)]),
                    aEdoExeCtrl,aExeCtrl,[rfReplaceAll,rfIgnoreCase]),aExeCtrl[edoctlIn])
                else aExeCtrl[edoctlOut]:=EdoTmpPath+s;
                if not lSkip then if act=edoaPodp then
                  if not RtfFmt and (edoeqFirst in equal) then begin
                    if not Dtg2Rtf(aExeCtrl[edoctlIn]) then goto lend;
                  end
                  else for io:=false to not(Assigned(ChkSuccess) or (edoeqFirst in equal) or (sc='')) do
                    if not fWrite(aExeCtrl[aExeCtrlIO[io]],true,io) then goto lend;
                if tp=edoexePodp then begin
                  i:=EdoDM.Inn[fEDOIN];
                  if not LockMode('Подписание документа ЭДО','FEDO',
                    'FEDO='+Vtos(i)+sOR+FldInList('FEDOPRM',[Vtos(i),Vtos(MaxInt)]),i,$FFFFFFFF) then goto lend;
                end;
                try
                  if not lSkip then case act of
                    edoaPodp: begin
                      if tp=edoexePodp then if sc<>'' then
                      if edoeqFirst in equal then
                      if not fDel(aExeCtrl[edoctlOut]) then goto lend1;
                      aExeCtrl[edoctlPswd]:=TrimRight(Rec['PSWD']);
                      if sc<>'' then begin
                        if brk(ConsoleExec(StrTran(sc,aEdoExeCtrl,aExeCtrl,[rfReplaceAll,rfIgnoreCase]),ExeDir,s),
                        ['Ошибка запуска программы:',Trim(EdoDM.Exe[fNAME])])
                          then goto lend1;
                        sc:=IfThen(EdoDM.Exe[EdoExeFld(tp,edoexeOutMsg)],TrimRight(CRLF+s));
                        if brk(Pos(Trim(EdoDM.Exe[EdoExeFld(tp,edoexeOutTrue)]),s)>0,
                        ['Ошибка выполнения программы:',Trim(EdoDM.Exe[fNAME])+sc]) then goto lend1;
                        MsgDlg(aEdoExeType[tp]+': выполнено успешно.'+sc,mtInformation);
                      end;
                    end;
                    edoaSave: begin
                      sc:=CorrDir(Rec['PSAVE']);
                      for io:=false to EdoDM.Inn[sMemo+'FSIG']<>'' do
                        if not fWrite(sc+ExtractFileName(aExeCtrl[aExeCtrlIO[io]]),true,io) then goto lend1;
                    end;
                    edoaLoad: begin
                      if not ForceDirMsg(EdoTmpPath) then goto lend1;
                      s:=Rec['POPEN']; aExeCtrl[edoctlOut]:=EdoTmpPath+ExtractFileName(s);
                      if not CopyFileOpt(s,aExeCtrl[edoctlOut],[cfStat,cfMsg]) then goto lend1;
                      try
                        ChkSuccess:=@fl; fl:=false; KeyLb1.ExecKey(aExeKey[edoexeChk].k);
                      finally
                        ChkSuccess:=nil;
                      end;
                      if not fl then goto lend1;
                      if not fRead(aExeCtrl[edoctlOut],true) then goto lend1;
                    end;
                  end;
                  if tp in [edoexePodp,edoexeShifr] then begin
                    if not lSkip then if act=edoaPodp then begin
                      if not FileExists(aExeCtrl[edoctlOut]) then aExeCtrl[edoctlOut]:=aExeCtrl[edoctlIn];
                      for io:=false to sc<>'' do if not fRead(aExeCtrl[aExeCtrlIO[io]],io) then goto lend1;
                    end;
                    case tp of
                      edoexePodp: begin
                        if not TrnsStart([tEDOIN,tEDO,tEDOORD]) then goto lend1;
                        if edoeqLast in equal then EdoDM.Inn['INARH']:=bTrue;
                      end;
                      edoexeShifr: EdoDM.Inn['SHIFRED']:=bTrue;
                    end;
                    try
                      EdoDM.Inn.UpdateRec(true);
                      if tp=edoexePodp then with EdoDM.Edo do begin
                        if not lSkip then NewRec;
                        Value[fEDOIN]:=EdoDM.Inn[fEDOIN];
                        if lSkip then begin
                          Value[fUSERNAME]:=BrQuery1USERNAME.AsString;
                          Value['SKIPUSER']:=ProgPswd.UserName;
                        end
                        else Value[fUSERNAME]:=ProgPswd.UserName;
                        Value['ACT']:=act; Value[fEDOEXE]:=ke; Value['D']:=NowDouble;
                        Value[fEDOORD]:=EdoDM.Ord[fEDOORD]; AppRec(true);
                        DisposeNil(pointer(dFile));
                        if act=edoaSave then fWrite(sc+GetFile+'.log',GetLog);
                        if edoeqLast in equal then begin
                          af:=TArrGetFld.CreateNum(EdoDM.Vd,'AARH');
                          try
                            with af.rdb do begin
                              ArrValue:=EdoDM.Vd['AARH']; i:=ArrCount;
                              if i=0
                              then fl:=false
                              else fl:=Ask(['Документ полностью подписан и перенесён в архив.',
                                'Скопировать файл в архивные папки ?']);
                              s2:=EdoDM.Ord[fEdoORG];
                              ProgPswd.GetQuery; DelTbl(EdoDM.Ord); ProgPswd.FreeQuery;
                              if fl then begin
                                sc:=ExtractFileName(aExeCtrl[edoctlIn]);
                                s1:=EdoDM.Inn[sMemo+'FSIG'];
                                s:=GetLog;
                                for i:=0 to i-1 do begin
                                  GotoRec(i); ke:=Value[fEdoVdOrg];
                                  if empty(ke) or (ke=s2) then begin
                                    ke:=CorrDir(Value[fEdoVdPath]);
                                    aExeCtrl[edoctlIn]:=ke+sc;
                                    aExeCtrl[edoctlOut]:=ke+s1;
                                    for io:=false to s1<>'' do fWrite(aExeCtrl[aExeCtrlIO[io]],true,io);
                                    fWrite(aExeCtrl[edoctlIn]+'.log',s);
                                  end;
                                end;
                              end;
                            end;
                          finally
                            af.Free;
                          end;
                        end;
                        TrnsEnd([trnsCommit]);
                      end;
                      Browl1.UpdateCur;
                    except
                      if tp=edoexePodp then TrnsEnd;
                      raise
                    end;
                  end;
                  SetPBoolean(ChkSuccess,true);
lend1:
                finally
                  if tp=edoexePodp then UnLockMode('FEDO');
                end;
              end
              else if lSkip then begin
                EdoDM.Edo.NewRec;
                if deSkip.Execute('Пропустить '+BrQuery1USERNAME.AsString+': '+InCapt).Saved then continue;
              end
              else case act of
                edoaPodp: begin
                  de.GetArrParam(fEDOEXE,i,ap);
                  EdoExeFlt(ap[deMask],tp); ap[deNoVisible]:=bStr[(tp=edoexePodp) or Assigned(ChkSuccess)];
                  de.SetArrParam(i,ap);
                  de.Param['PSWD',deNoVisible]:=
                    bStr[Pos(AnsiUpperCase(aEdoExeCtrl[edoctlPswd]),AnsiUpperCase(sc))=0];
                  Rec['PSWD']:=''; rde:=de.Execute(txt+': '+InCapt,desVisible);
                  if not rde.WasShow then rde.Saved:=Ask([InCapt,txt+' ?']);
                  if rde.Saved then continue;
                end;
                edoaSave: if deFileExec(nil,'PSAVE','Выгрузить файл для подписания в папку') then continue;
                edoaLoad: begin
                  dlgFileOpen.Filter:='|'+ReplVar(EdoDM.Inn[sMemo+'FSIG'],GetFile(true,false)+'.*');
                  fl:=deFileExec(dlgFileOpen,'POPEN','Загрузить подписанный файл');
                  dlgFileOpen.Filter:='';
                  if fl then continue;
                end;
              end;
            end;
            break;
          end;
lend:
          ProgPswd.LogVid:=logvNone; break;
        end;
      end;
    finally
      DisposeNil(pointer(dFile)); 
    end;
  end;
  DelStack;
end;

function TEdoLs.Browl1GrayCell;
begin
  AddStack('TEdoLs.Browl1GrayCell',Self);
  result := BrQuery1STATUS.AsInteger<>0;
  DelStack;
end;

procedure TEdoLs.deFltFldChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
  AddStack('TEdoLs.deFltFldChange',Self);
  with TFldEdit(Sender) do if NameRecFld='STATUS'+bStr[edomdAll in Mode]
  then deFlt.SetReadOnly(['D1','D1B','D1E'],not GetByte(VarValue,offsStatus+1));
  DelStack;
end;

procedure TEdoLs.UsersGetClick(Sender: TObject);
begin
  AddStack('TEdoLs.UsersGetClick',Self);
  TEdoUsLs.Execute(Sender,TEdoUsLs,EdoUsLs);
  DelStack;
end;

procedure TEdoLs.KvsGetClick(Sender: TObject);
begin
  AddStack('TEdoLs.KvsGetClick',Self);
  TEdoVdLs.Execute(Sender,TEdoVdLs,EdoVdLs);
  DelStack;
end;

function TEdoLs.deFileFldCheck(Sender: TObject): Boolean;
begin
  AddStack('TEdoLs.deFileFldCheck',Self);
  result:=TFldEdit.NoEmpValue(Sender);
  DelStack;
end;

class procedure TEdoLs.ApplTitleBlink;
begin
  AddStack('TEdoLs.ApplTitleBlink');
  MsgApplication(WM_EDOAPPLTITLE,Word(Blinked),Word(ReDef),true);
  DelStack;
end;

function TEdoLs.deDelFldCheck(Sender: TObject): Boolean;
begin
  AddStack('TEdoLs.deDelFldCheck',Self);
  NoEmpCheck(Sender,'DELD',result);
  DelStack;
end;

procedure StDel(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i,l: longint;
  a: PArrStr;
begin
  AddStack('FEdoLs.StDel');
  l:=Params[0]; a:=PointerVar(Params[1]);
  for i:=1 to l do begin
    if Sender.SayStat('','',i/l) then break;
    DelTbl(EdoDM.Edo,a^[i-1]);
    DelTbl(EdoDM.Ord,a^[i-1]);
    DelTbl(EdoDM.App,a^[i-1]);
  end;
  DelStack;
end;

function TEdoLs.deDelPnlValid(Sender: TObject): Boolean;
var deld: TDateTime;
  l: longint;
  a: TArrStr;
  q: TMulQuery;
begin
  AddStack('TEdoLs.deDelPnlValid',Self);
  result:=false;
  deld:=Rec['DELD'];
  q:=ProgPswd.GetQuery; q.PartSelect(tEDOIN,[],'D<'+q.VarTos(Double(deld))); l:=q.RecordCount;
  if l>0 then begin
    if Ask(['Внимание !','Будут удалены документы до '+dtoc(deld),Format('(количество: %d)',[l]),
    'Продолжить ?'],false) then begin
      ProgPswd.GetQuery.FldInSel(fEDOIN,tEDOIN,'','',[],@a,'',q); ProgPswd.FreeQuery; l:=Length(a);
      if TrnsStart([tEDOIN,tEDOORD,tEDOAPP,tEDO]) then try
        if not ShowStat('Удаление документов',StDel,[l,longint(@a)],l,10) then begin
          DelTbl(EdoDM.Inn,'',q);
          TrnsEnd([trnsCommit]); Browl1.BrUpdate; result:=true;
        end;
      except
        TrnsEnd; raise;
      end;
    end;
  end
  else meserr('Документы до '+dtoc(deld)+' отсутствуют.');
  ProgPswd.FreeQuery;
  DelStack;
end;

initialization
  AddStack('FEdoLs.initialization');
  EdoNetSelProc:=NetSelProc;
  DelStack;
end.
