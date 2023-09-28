unit FDWndLs;

interface

{$I LIBTEST}
uses
  Windows, Messages, Classes, Controls, Menus, DB, Grids, DBGrids, ExtCtrls,
  MyTypes, FrmBrIB, KeyMenu, Browl, Keylb, Fpanel, DefEdit, FFldedit, ButGet, RecDB, FDWPrm;

type
  TDWndOper = (dwoCreate,dwoChange,dwoEdShow,dwoEdHide,dwoCanDel,dwoNewCodPrm,dwoNewCod,dwoProcKey);
  TDWndProc = procedure(oper: TDWndOper; const av: array of variant);

  TDWndLs = class(TFormBrIB)
    de: TDefEdit;
    DWGet: TButGet;
    procedure FormCreate(Sender: TObject);
    procedure Browl1BrowlKey(key: Integer; tw: TWinControl);
    procedure deFrmShow(Sender: TObject);
    procedure deFrmHide(Sender: TObject);
    function deFldCheck(Sender: TObject): Boolean;
    function DWGetClick(Sender: TObject; lEval: Boolean): String;
    procedure DWGetPaint(Sender: TObject; const ARect: TRect;
      const Text: String);
    procedure FormDestroy(Sender: TObject);
    function Browl1TransSeek(Sender: TObject; const Value: String;
      Size: Integer; lQuery: Boolean): String;
    function Browl1GrayCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState): Boolean;
    procedure FormHide(Sender: TObject);
    function dePnlValid(Sender: TObject): Boolean;
    procedure KeyLb1ProcKey(key: Integer; tw: TWinControl);
  private
    { Private declarations }
    dw: TDataWin;
    LsMDNew,LsUsed: TStringList;
    procedure DWResize(Sender: TObject);
		procedure NewCod(const oldnum: string; Options: TCngNumOptions; var result: boolean);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    class procedure Init(DWndDWCanDel: TDWCanDelEvent; DWndDWCngName: TDWCngNameEvent; Proc: TDWndProc);
    procedure LsUsedClear;
		class procedure VarCreate;
  end;

const DWndDatNameRec = 'DWndDat';

var DWnd: TRecDB;
  DWndLs: TDWndLs;

implementation

{$R *.dfm}

uses SysUtils,StrUtils,Variants,Forms,
  My_pr,FCngNum,FrmPswd,ModelGet,FDWVid,FDWFld,Inter,RecVal,FSchemDM;

type
  TNone = class
  private
    class function DWndKodCheck(Sender: TRecDB; const NmFld,Flt: string;
      Opt: TKodCheckOptions = []): boolean;
		class procedure DWndDatDWTrans(Sender: TObject; var sTrans: String; lSave: Boolean);
    class procedure DWndDatDWVarValid(Sender: TObject; Proc: TProcVarValid;
      const r: TDWVidRec; var result: Boolean);
    class procedure mgHelp(Sender: TObject; var ht: THelpTbl);
    class procedure mgSave(Sender: TObject; FromEdit: Boolean);
    class procedure mgLoad(Sender: TObject; FromEdit: Boolean);
    class procedure mgInterDef(Sender: TObject; Oper: TModelInterDefOper;
      const av: array of Variant; var result: Variant);
		class procedure PrInterDopGetVar(ProcDopGetVarAdd: TProcDopGetVarAdd);
    class function PrInterDopGetVarIgnore(const aPath: TVarPathStr): boolean;
    class procedure PnlCngKey(Sender: TObject; var tb: TKeyBut);
  end;

var DWndDat: TRecDBDef;
  FDWndProc: TDWndProc;
  lsVarDop: TVarDopList;

const VarBeg = 'dwndvar';

procedure Proc(oper: TDWndOper; const av: array of variant); overload;
begin
  AddStack('FDWndLs.Proc');
  if Assigned(FDWndProc) then FDWndProc(oper,av);
  if oper=dwoChange then TDWndLs.VarCreate;
  DelStack;
end;

procedure Proc; overload;
begin
  Proc(dwoChange,[]);
end;

class function SectIni(const kw: string): string;
begin
  AddStack('FDWndLs.SectIni');
  result:='DWnd.'+Trim(kw);
  DelStack;
end;

function c_dwnd(const kw: string; const caf: array of string; var cav: TArrVar; const MsgSave: string = ''): boolean; overload;
var i: longint;
  af: TArrStr;
begin
  AddStack('FDWndLs.c_dwnd');
  if DWnd.Seek(DWnd.TblFldName(fDWND)+'='+QQs(kw)) then with DWndDat,TDWWin.Create do
    try
      DWndDat.InitFldDef; NewRec; CopyFrom(af,caf);
      for i:=low(af) to high(af) do begin
        if AnsiStartsText(DWPrefix+'_',af[i]) then Delete(af[i],1,Length(DWPrefix)+1);
        if not IsNil(cav[i]) then Value[af[i]]:=cav[i];
      end;
      if MsgSave<>'' then begin
        UserData:=@MsgSave; OnPnlCngKey:=TNone.PnlCngKey;
      end;
      result:=Execute(DWnd[DWMem(postWin)],SectIni(kw),[],'Дополнительное окно ввода '+kw+'. '+Trim(DWnd[fNAME]),[]).Saved;
      if result then begin
        for i:=low(af) to high(af) do cav[i]:=Value[af[i]];
      end;
    finally
      Free;
    end
  else result:=false;
  DelStack;
end;

function c_dwnd(var av: array of variant): variant; overload;
var h: longint;
  caf: TArrStr;
  cav: TArrVar;
begin
  result:=null;
  if MyVarType(av[2])=varArray then begin
    CopyFromVar(caf,av[2]); h:=VarArrayHighBound(av[2],1); CopyFromVar(cav,VAddEnd(av[3],h));
    if c_dwnd(TrimRight(av[1]),caf,cav,IsNilc(av[4],'')) then result:=ArrVarToVar(cav);
  end;
end;

{ TDWndLs }
class procedure TDWndLs.Init;
begin
  AddStack('TDWndLs.Init');
  FDWndProc:=Proc;
  DWnd:=TRecDB.Create(Application.MainForm);
  with TNone do begin
    with DWnd do begin
      MsgCheck:='Дополнительное окно ввода с таким кодом уже есть.'; NameDB:=tDWND; NameRec:=tDWND;
      OnKodCheck:=DWndKodCheck; OpenRec;
    end;
  	DWndDat:=TRecDBDef.Create(Application.MainForm);
    with DWndDat do begin
      NameRec:=DWndDatNameRec; DWPrefix:='ДОВ'; DWName:='Данные по текущему дополнительному окну ввода';
      OnDWTrans:=DWndDatDWTrans; OnDWVarValid:=DWndDatDWVarValid;
      OnDWCanDel:=DWndDWCanDel; OnDWCngName:=DWndDWCngName; OpenRec;
    end;
    with SchemDM.mgDwnd do begin
      OnHelp:=mgHelp; OnSave:=mgSave; OnLoad:=mgLoad; OnInterDef:=mgInterDef;
    end;
    TDWPrm.VarCreate(DWndDat,PrInterDopGetVar,PrInterDopGetVarIgnore);
  end;
  DelStack;
end;

procedure TDWndLs.FormCreate(Sender: TObject);
var p: TDWPostList;
  a: TDEPrmVar;
begin
  AddStack('TDWndLs.FormCreate',Self);
  inherited;
  dw:=TDataWin.Create;
  Caption:=GetPrim(tDWND);
  with BrQuery1 do begin
    Init(DBMain,[fDWND],[fDWND],tDWND,[fDWND,fNAME,fMODEL,fNMODEL,fRECNO],'','',ModelCalcFields);
    Browl1.FieldSeek:=CreateStringField(fDWND);
    CreateStringField(fNAME);
    ModelCreateFields;
  end;
  InitArr(a);
  a[deNameRec]:=DWnd.NameRec;
  a[deNoReadOnly]:=true;
  a[deTag]:=true;
  a[deRelation]:='.DW';
  for p:=low(aDWPost) to high(aDWPost) do begin
    a[deNameRecFld]:=DWMem(p);
    DWGet.AssignGet(a);
    a[deMask]:=ButPrm2Mask(FRup(aDWPost[p].nm));
    de.CreateFld(a);
  end;
  de.AssignGet(fMODEL,SchemDM.mgDwnd);
  Proc(dwoCreate,[longint(KeyLb1)]);
  DelStack;
end;

procedure TDWndLs.FormDestroy(Sender: TObject);
begin
	AddStack('TDWndLs.FormDestroy',Self);
  LsMDNew.Free; LsUsed.Free; dw.Free;
  inherited;
  DelStack;
end;

procedure TDWndLs.WMFormLimit;
begin
	AddStack('TDWndLs.WMFormLimit',Self);
  inherited;
  FreeLimit(DWndLs);
  DelStack;
end;

procedure TDWndLs.FormHide(Sender: TObject);
begin
  AddStack('TDWndLs.FormHide');
  if Assigned(LsMDNew) then LsMDNew.Clear;
  FreeAndNil(LsUsed);
  inherited;
  DelStack;
end;

procedure TDWndLs.KeyLb1ProcKey(key: Integer; tw: TWinControl);
begin
  AddStack('TDWndLs.KeyLb1ProcKey',Self);
  inherited;
  Proc(dwoProcKey,[key,longint(tw),longint(Browl1.FieldSeek),longint(@LsUsed),longint(@LsMDNew)]);
  DelStack;
end;

procedure TDWndLs.Browl1BrowlKey(key: Integer; tw: TWinControl);
var okw: string;
  fl: boolean;
  atbl: TArrStr;
  opt: TCngNumOptions;
begin
  AddStack('TDWndLs.Browl1BrowlKey',Self);
  inherited;
  if BrQuery1.CanEdit(Key) then case Key of
  	K_F3: begin
      CopyFrom(atbl,tDWND); opt:=[cngNoLockMono]; Proc(dwoNewCodPrm,[longint(@atbl),longint(@opt)]);
      if TCngNum.GetNewNum('Новый код дополнительного окна ввода',Browl1,DWnd,
        fDWND,atbl,[LsMDNew,LsUsed],'',NewCod,cteName,nil,nil,opt) then Proc;
    end;
  	K_F4,K_F7: if LockEdConf then
      try
        if Browl1.AppRec('Добавить дополнительное окно ввода',DWnd,de,IfThen(Key),'',fDWND) then Proc;
      finally
        UnLockEdConf;
      end;
    K_F5,K_Enter: if LockEdConf then
      try
        if Browl1.EditRec('Редактировать дополнительное окно ввода',DWnd,de,fDWND) then begin
          if SchemDM.mgDwnd.ModelUpdList(LsMDNew) then Browl1.Refresh;
          Proc;
        end;
      finally
        UnLockEdConf;
      end;
    K_F8: if LockEdConf then
      try
        okw:=Browl1.FieldSeek.AsString; fl:=true;
        if not BrQuery1.IsCodEqual(fDWND) then
          if CodMaybeUsed(LsUsed,okw) then Proc(dwoCanDel,[longint(@fl),longint(LsUsed),okw]);
        if fl then if Browl1.DelAsk(DWnd) then begin
          TDefEdit.EraseSection(SectIni(okw)); Proc;
        end;
      finally
        UnLockEdConf;
      end;
    K_Alt_F3: SchemDM.mgDwnd.Add(Browl1);
    K_Alt_F5: if LockEdConf then
      try
        if SchemDM.mgDwnd.List(LsMDNew,Browl1) then Proc;
      finally
        UnLockEdConf;
      end;
    K_Alt_F8: SchemDM.mgDwnd.ModelNew(Browl1,LsMDNew,@LsUsed);
  end;
  DelStack;
end;

procedure TDWndLs.deFrmShow(Sender: TObject);
var p: TDWPostList;
begin
  AddStack('TDWndLs.deFrmShow',Self);
  de.FldEdit['DW'].OnResize:=DWResize;
  for p:=low(aDWPost) to high(aDWPost) do de.SetReadOnly(DWMem(p),false,ogAutoSize);
  Proc(dwoEdShow,[]);
  DelStack;
end;

procedure TDWndLs.deFrmHide(Sender: TObject);
begin
  AddStack('TDWndLs.deFrmHide',Self);
  Proc(dwoEdHide,[]);
  de.FldEdit['DW'].OnResize:=nil;
  DelStack;
end;

procedure TDWndLs.DWResize;
var a: array[TDWPostList] of longint;
  h: longint;
  p: TDWPostList;
begin
  AddStack('TDWndLs.DWResize',Self);
  with TFldEdit(Sender) do begin
    RasprOst(a,Width,[rspoEqual]); h:=Height;
  end;
  for p:=low(aDWPost) to high(aDWPost) do with de.FldEdit[DWMem(p)] do SetBounds(Left,Top,a[p],h);
  DelStack;
end;

function TDWndLs.DWGetClick(Sender: TObject; lEval: Boolean): String;
var tf: TFldEdit;
  s: string;
  fl: boolean;
begin
	AddStack('TDWndLs.DWGetClick',Self);
	if lEval then begin
    AddPrnHead('Дополнительное окно ввода '+Trim(DWnd[fDWND])+'. '+DWnd[fNAME]);
  	tf:=pointer(Sender);
    if tf.NameRecFld=DWMem then fl:=DWVidExec(DWndDat)
    else begin
      TDWPrm.VarCreate(DWndDat); s:=tf.Value;
      if DWFldExec('Настройка дополнительного окна ввода',s,[DWndDat]) then tf.VarValue:=s;
      fl:=DWndDat.DWModified; TDWPrm.VarFree(DWndDat);
    end;
    DelPrnHead;
    if fl then ChildFldReadAll(de.FldEdit['DW']);
  end;
	result:='';
  DelStack;
end;

procedure TDWndLs.DWGetPaint(Sender: TObject; const ARect: TRect;
  const Text: String);
var tf: TFldEdit;
begin
  AddStack('TDWndLs.DWGetPaint',Self);
  tf:=pointer(Sender);
  if tf.NameRecFld=DWMem
  then TDWVid.ButGetPaint(Sender,ARect,DWndDat,[dwbShortType,dwbBrackets])
  else dw.ButGetPaint(Sender,ARect,tf.Value);
  DelStack;
end;

function TDWndLs.Browl1TransSeek(Sender: TObject; const Value: String;
  Size: Integer; lQuery: Boolean): String;
begin
	AddStack('TDWndLs.Browl1TransSeek',Self);
  result:=TrimUpper(Value);
  DelStack;
end;

function TDWndLs.deFldCheck(Sender: TObject): Boolean;
begin
  AddStack('TDWndLs.deFldCheck',Self);
  KodCheck(Sender,fDWND,result,'','',[chkNoEmpty]);
  DelStack;
end;

function TDWndLs.dePnlValid(Sender: TObject): Boolean;
begin
  AddStack('TDWndLs.dePnlValid',Self);
  result:=SchemDM.mgDwnd.EmpCodApp(Sender);
  DelStack;
end;

procedure TDWndLs.NewCod;
var newnum: string;
begin
	AddStack('TDWndLs.NewCod',Self);
  newnum:=DWnd[fDWND];
  Proc(dwoNewCod,[longint(@result),Longint(LsUsed),oldnum,newnum]);
  TDefEdit.RenameSection(SectIni(oldnum),SectIni(newnum));
  DelStack;
end;

function TDWndLs.Browl1GrayCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState): Boolean;
begin
  AddStack('TDWndLs.Browl1GrayCell',Self);
  inherited;
  result:=CodGrayCell(State,LsMDNew,Browl1.FieldSeek,LsUsed);
  DelStack;
end;

procedure TDWndLs.LsUsedClear;
begin
  AddStack('TDWndLs.LsUsedClear');
  if Assigned(Self) then begin
    FreeAndNil(LsUsed); Browl1.Invalidate;
  end;
  DelStack;
end;

class procedure TDWndLs.VarCreate;
begin
  AddStack('TDWndLs.VarCreate');
  FreeAndNil(lsVarDop);
  DelStack;
end;

{ TNone }
class function TNone.DWndKodCheck;
begin
  AddStack('TNone.DWndKodCheck');
  result:=Sender.AbcKodCheck(nmFld,fDWND,Opt);
  DelStack;
end;

class procedure TNone.DWndDatDWTrans;
begin
	AddStack('TNone.DWndDatDWTrans');
  if lSave then DWnd[DWMem]:=sTrans else sTrans:=DWnd[DWMem];
  DelStack;
end;

class procedure TNone.DWndDatDWVarValid;
begin
	AddStack('TNone.DWndDatDWVarValid');
  Proc(r,result,DWnd[DWMem(postWin)],'Дополнительное окно ввода');
  DelStack;
end;

class procedure TNone.mgHelp;
var n: byte;
  p: TDWPostList;
begin
  AddStack('TNone.mgHelp');
  n:=high(ht.Dat); SetLength(ht.Dat,n+DWPostLen+1);
  for p:=low(aDWPost) to high(aDWPost) do DWnd.HelpTblAdd(ht,n,[DWMem(p)]);
  DelStack;
end;

class procedure TNone.mgSave;
var p: TDWPostList;
begin
  AddStack('TNone.mgSave');
	with TModelGet(Sender) do begin
    for p:=low(aDWPost) to high(aDWPost) do WriteStr(DWnd[DWMem(p)]);
		DWnd[fMODEL]:=MDFile; DWnd[fNMODEL]:=NSave;
  	if FromEdit then DWndLs.de.Read(fMODEL) else DWnd.UpdateRec(true);
  end;
  DelStack;
end;

class procedure TNone.mgLoad;
var p: TDWPostList;
begin
  AddStack('TNone.mgLoad');
	with TModelGet(Sender) do begin
		if empty(DWnd[fDWND]) then DWnd[fDWND]:=MDFile;
    if empty(DWnd[fNAME]) then DWnd[fNAME]:=MDName;
    DWnd[fNMODEL]:=NSave;
    for p:=low(aDWPost) to high(aDWPost) do DWnd[DWMem(p)]:=ReadStr;
    if FromEdit then DWndLs.de.PanelEdit.FldReadAll
    else begin
      DWnd[fMODEL]:=MDFile; DWnd.UpdateRec(true);
    end;
  end;
  DelStack;
end;

class procedure TNone.mgInterDef;
begin
  AddStack('TNone.mgInterDef');
  case Oper of
    mdiVarName: result:='ВВОД';
    mdiAfterLoad: Proc;
  end;
  DelStack;
end;

class procedure TNone.PrInterDopGetVar;
var i: longint;
  lsm: TMemGkList;
  a: TArrStr;
  r: TRecDB;
  rv: TDWVidRec;
begin
  AddStack('TNone.PrInterDopGetVar');
  if not Assigned(lsVarDop) then with ProgPswd.GetQuery do begin
    lsVarDop:=TVarDopList.Create;
    lsVarDop.AddDop('$'+VarBeg+iChrPrim+DWndDat.DWVarName,'Данные по дополнительным окнам ввода');
    PartSelect(tDWND,[fDWND,fNAME,DWMem,fRECNO],'',fDWND);
    r:=TRecDB.Create(Application.MainForm);
    try
      r.NameDB:=tDWND; r.OpenRec; lsm:=TMemGkList.Create(r);
      while not Eof do begin
        lsm.GetFromQuery;
        lsVarDop.AddDop('$$'+VarBeg+Trim(r[fDWND]),r[fDWND]+'. '+r[fNAME]);
        for i:=0 to LsArrDynamic(r[DWMem],a,CRLF)-1 do begin
          rv:=DWSToRec(a[i]); lsVarDop.AddDop(DWndDat.DWVarName(rv.Name),rv.Prim,VarCreateTypes(rv));
        end;
        Next;
      end;
    finally
      r.Free;
    end;
    ProgPswd.FreeQuery;
  end;
  lsVarDop.PrInterDopGetVar(ProcDopGetVarAdd);
  DelStack;
end;

class function TNone.PrInterDopGetVarIgnore;
begin
  AddStack('TNone.PrInterDopGetVarIgnore');
  result := aPath[1]=VarBeg;
  DelStack;
end;

class procedure TNone.PnlCngKey;
begin
  AddStack('TNone.PnlCngKey');
  if tb.Key=K_F10 then tb.Caption:=PString(TDWWin(LsDWWin[LsDWWin.Count-1]).UserData)^;
  DelStack;
end;

procedure LogTrnsValProc(var Prm: TLogTrnsValPrm);
var p: TDWPostList;
begin
  AddStack('FDWndLs.LogTrnsValProc');
  for p:=low(aDWPost) to high(aDWPost) do if LogEqual(Prm,tDWND,DWMem(p)) then with Prm do begin
    case p of
      postDat: TDatLogCompare.Execute(Prm,DWndDat);
      postWin: TWinLogCompare.Execute(Prm);
    end;
    break;
  end;
  DelStack;
end;

initialization
  AddStack('FDWndLs.initialization');
  MyTypes.c_dwnd:=Tinter.ReSetFunction('ВВОД_ОКНО',c_dwnd);
  SetPrim(tDWND,'Дополнительные окна ввода');
  LogTrnsValProcAdd(LogTrnsValProc);
  TDWndLs.VarCreate;
  DelStack;
end.
