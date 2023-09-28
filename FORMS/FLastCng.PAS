unit FLastCng;

interface

{$I LIBTEST}
uses
  Messages, Classes, Controls, Menus, DB, Grids, DBGrids, ExtCtrls,
  MyTypes, FrmBrIBp, KeyMenu, Browl, Keylb, Fpanel, RecVal, Recdb, DefEdit, FEdText, FFldedit,
    ModelGet, CCodeGet;

type
  TLastCngMdLoadOper = (mdgoTrnsStart,mdgoBeg,mdgoGet,mdgoApp,mdgoEnd,mdgoTrnsEnd);
  TLastCngMdLoad = function(Oper: TLastCngMdLoadOper; const av: array of variant): variant of object;

  TLastCngLs = class(TFormBrIBPnl)
    de: TDefEdit;
    Rec: TRecVal;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure deFrmShow(Sender: TObject);
    function dePnlValid(Sender: TObject): Boolean;
    procedure Browl1BrowlKey(key: Integer; tw: TWinControl);
  private
    { Private declarations }
    BrQuery1RECNO,BrQuery1VERSCONF,BrQuery1VERSEXE: TIntegerField;
    BrQuery1CD: TStringField;
    BrQuery1D: TField;
    lsm: TMemGkList;
    TextMemo: TTextMemo;
    LastCng: TRecDB;
    procedure BrQuery1CalcFields(Sender: TDataSet);
    procedure BrQuery1AfterOpen(Sender: TDataSet);
    procedure BrQuery1AfterClose(Sender: TDataSet);
    procedure BrQuery1AfterScroll(Sender: TDataSet);
    class procedure LastCngNewRec(Sender: TRecDB; lcopy: boolean; const gKey: string);
    procedure mgHelp(Sender: TObject; var ht: THelpTbl);
    procedure mgLoad(Sender: TObject; FromEdit: Boolean);
    procedure mgModify(Sender: TObject);
    procedure mgSave(Sender: TObject; FromEdit: Boolean);
    function FMdLoad(Oper: TLastCngMdLoadOper; const av: array of variant): variant;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    PrMdLoad: TLastCngMdLoad;
    class function GetVers: longint;
    class procedure MDNameFill;
  end;

var
  LastCngLs: TLastCngLs;

implementation

{$R *.dfm}

uses SysUtils,StrUtils,Variants,
  FSchemDM,MulQry,
  My_pr,DateGet,FrmPswd,FStat;

const lVers = 6;
  fTXT = sMemo+'TXT';

procedure TLastCngLs.FormCreate(Sender: TObject);
var s: string;
begin
  AddStack('TLastCngLs.FormCreate',Self);
  TTimeCurGet.CreateOne;
  TextMemo:=TTextMemo.CreateParent(Self,RbPanel4);
  with TextMemo do begin
    Align:=alClient; BevelOuter:=bvNone; ReadOnly:=true; WordWrapBool:=true;
  end;
  inherited;
  if IsTable(tLASTCNG) then with BrQuery1 do begin
    BrQuery1RECNO:=Init(DBMain,[fLastcngVERS],[IfThen(CanPriv(PrivDesign),fLastcngVERS)],tLASTCNG,[]);
    BrQuery1VERSCONF:=CreateIntegerField(fLastcngVERS,'Версия',lVers);
    BrQuery1VERSEXE:=CreateIntegerField('VERSEXE','Сборка',lVers);
    BrQuery1CD:=CreateStringField('CD','Дата',Length(FormatDateTime(LastCngFmtD,Now)),taCenter);
    BrQuery1D:=CreateField('D');
    CreateField(fTXT);
    AfterOpen:=BrQuery1AfterOpen; AfterClose:=BrQuery1AfterClose; AfterScroll:=BrQuery1AfterScroll;
  end;
  LastCng:=TRecDB.Create(Self);
  with LastCng do begin
    NameRec:='LastCng'; NameDB:=tLASTCNG; OnNewRec:=LastCngNewRec; OpenRec;
  end;
  s:='1,'+StringOfChar('9',lVers); de.Param[fLastcngVERS,deMask]:=s; de.Param['VERSEXE',deMask]:=s;
  de.AssignGet('T',TTimeCurGet);
  with Browl1.NmProc do begin
    BeginUpdate;
    if CanPriv(PrivDesign) then begin
      Add(TKeyLb.GetKeySt(K_F4,'Скопировать','',kmList));
      Add(TKeyLb.GetKeySt(K_F5,'Редактировать','',kmList));
      Add(TKeyLb.GetKeySt(K_F7,'Добавить','',kmList));
      Add(TKeyLb.GetKeySt(K_F8,'Удалить','',kmList));
      Add(TKeyLb.GetKeySt(K_Enter,K_F5));
      Add(TKeyLb.GetKeySt(K_Alt_F3,'','Создать основу',kmServic));
    end;
    Add(TKeyLb.GetKeySt(K_Alt_F5,'','Загрузить из основы',kmServic,NotePrivModelLoad));
    Add(TKeyLb.GetKeySt(K_Alt_F6,'','Поиск по содержимому',kmList));
    EndUpdate;
  end;
  with SchemDM.mgLastCng do begin
    OnHelp:=mgHelp; OnLoad:=mgLoad; OnModify:=mgModify; OnSave:=mgSave;
  end;
  PrMdLoad:=FMdLoad;
  DelStack;
end;

procedure TLastCngLs.FormShow(Sender: TObject);
begin
  AddStack('TLastCngLs.FormShow',Self);
  inherited;
  Browl1.FormShow(Sender);
  DelStack;
end;

procedure TLastCngLs.BrQuery1CalcFields;
begin
  AddStack('TLastCngLs.BrQuery1CalcFields',Self);
  BrQuery1CD.AsString:=OurFormatDateTime(LastCngFmtD,BrQuery1D.AsFloat);
  DelStack;
end;

procedure TLastCngLs.WMFormLimit;
begin
	AddStack('TLastCngLs.WMFormLimit',Self);
  inherited;
  FreeLimit(LastCngLs);
  DelStack;
end;

class function TLastCngLs.GetVers;
begin
  AddStack('TLastCngLs.GetVers');
  result:=ProgPswd.PartMaxInt(tLASTCNG,fLastcngVERS);
  DelStack;
end;

type PCngVersRec = ^TCngVersRec;
  TCngVersRec = record
    oVers,oLogVid: longint;
    lCng: boolean;
  end;

procedure CngVersBeg(var r: TCngVersRec);
begin
  AddStack('FLastCng.CngVersBeg');
  r.oVers:=TLastCngLs.GetVers; r.oLogVid:=ProgPswd.CngLogVid(logvLastVers); r.lCng:=false;
  DelStack;
end;

procedure CngVersEnd(const r: TCngVersRec);
var nVers: longint;
begin
  AddStack('FLastCng.CngVersEnd');
  if r.lCng then begin
    nVers:=TLastCngLs.GetVers;
    if nVers<>r.oVers then LogWrite(tLASTCNG,Format('%d -> %d',[r.oVers,nVers]));
    MsgApplication(WM_LASTCNGMOD);
  end;
  ProgPswd.CngLogVid(r.oLogVid);
  DelStack;
end;

procedure TLastCngLs.Browl1BrowlKey(key: Integer; tw: TWinControl);
var r: TCngVersRec;
begin
  AddStack('TLastCngLs.Browl1BrowlKey',Self);
  inherited;
  if BrQuery1.CanEdit(Key,[K_Alt_F5]) then begin
    BrQuery1.AfterScroll:=nil;
    try
      CngVersBeg(r);
      case Key of
        K_F4,K_F7: r.lCng:=Browl1.AppRec('Добавить',LastCng,de,IfThen(Key));
        K_F5,K_Enter: r.lCng:=Browl1.EditRec('Редактировать',LastCng,de);
        K_F8: r.lCng:=Browl1.DelAsk(LastCng);
        K_Alt_F3: SchemDM.mgLastCng.Add;
        K_Alt_F5: SchemDM.mgLastCng.List;
        K_Alt_F6: Browl1.FindMemo(@lsm);
      end;
      CngVersEnd(r);
    finally
      BrQuery1.AfterScroll:=BrQuery1AfterScroll; BrQuery1AfterScroll(BrQuery1.DataSet);
    end;
  end;
  DelStack;
end;

class procedure TLastCngLs.LastCngNewRec;
begin
  AddStack('TLastCngLs.LastCngNewRec');
  Sender['D']:=Now; Sender[fLastcngVERS]:=Int0(Sender.KodNext(fLastcngVERS));
  Sender['VERSEXE']:=GetExeInfo.Build;
  DelStack;
end;

procedure TLastCngLs.deFrmShow(Sender: TObject);
var d: TDateTime;
begin
  AddStack('TLastCngLs.deFrmShow',Self);
  d:=LastCng['D']; Rec['D']:=trunc(d); Rec['T']:=FormatDateTime('hh:nn',d);
  DelStack;
end;

function TLastCngLs.dePnlValid(Sender: TObject): Boolean;
var t: string;
begin
  AddStack('TLastCngLs.dePnlValid',Self);
  result:=true; t:=Rec['T'];
  LastCng['D']:=Rec['D']+EncodeTimeTry(Int0(LeftStr(t,2)),Int0(Copy(t,4,MaxInt)),0,0);
  LogFields.AddRecFld(LastCng,'D');
  DelStack;
end;

procedure TLastCngLs.BrQuery1AfterOpen;
var oAfterScroll: TDataSetNotifyEvent;
begin
  AddStack('TLastCngLs.BrQuery1AfterOpen',Self);
  if not Assigned(lsm) then with BrQuery1 do begin
    OnCalcFields:=nil; oAfterScroll:=AfterScroll; AfterScroll:=nil;
    lsm:=TMemGkList.Create(LastCng,BrQuery1);
    OnCalcFields:=BrQuery1CalcFields; AfterScroll:=oAfterScroll;
    if CanPriv(PrivDesign) then First else Last;
  end;
  DelStack;
end;

procedure TLastCngLs.BrQuery1AfterClose;
begin
  AddStack('TLastCngLs.BrQuery1AfterClose',Self);
  lsm:=nil;
  DelStack;
end;

procedure TLastCngLs.BrQuery1AfterScroll;
begin
  AddStack('TLastCngLs.BrQuery1AfterScroll',Self);
  if Assigned(lsm) then begin
    lsm.GetFromQuery; TextMemo.Text:=TrimRight(LastCng[fTXT]);
  end;
  DelStack;
end;

procedure TLastCngLs.mgHelp;
var n: byte;
begin
  AddStack('TLastCngLs.mgHelp',Self);
  n:=high(ht.Dat); SetLength(ht.Dat,n+6);
  Inc(n); CopyFrom(ht.Dat[n],'Количество записей. Для каждой записи:');
  LastCng.HelpTblAdd(ht,n,[fLastcngVERS,'VERSEXE','D',fTXT],1);
  DelStack;
end;

procedure TLastCngLs.mgSave;
var tr,ii: longint;
begin
  AddStack('TLastCngLs.mgSave',Self);
	with TModelGet(Sender),ProgPswd,BrQuery1 do begin
    DisableControls; tr:=Browl1.Row; ii:=BrQuery1RECNO.AsInteger; ReOpen;
    WriteVal(RecordCount,stInteger);
    while not Eof do begin
      WriteVal(BrQuery1VERSCONF.AsInteger,stInteger);
      WriteVal(BrQuery1VERSEXE.AsInteger,stInteger);
      WriteVal(BrQuery1D.AsFloat,stDouble);
      lsm.GetFromQuery; WriteStr(TrimRight(LastCng[fTXT]));
      Next;
    end;
    RG[UsedFieldName]:=MDFile; RG[UsedFieldNSave]:=NSave;
    if RG.UpdateRec(true) then MsgApplication(WM_LASTCNGMOD);
    Browl1.BrUpdate(tr,ii); EnableControls;
  end;
  DelStack;
end;

procedure StMdLoad(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i,l: longint;
  rLastCng: TCustomRec;
begin
  AddStack('FLastCng.StMdLoad');
  l:=Params[0];
  for i:=1 to l do with ModelGetVar(Params[1]),LastCngLs do begin
    rLastCng:=PointerVar(PrMdLoad(mdgoGet,[]));
    rLastCng[fLastcngVERS]:=ReadVal(stInteger);
    if Sender.SayStat('',StrNum('Версия: ',rLastCng[fLastcngVERS]),i/l) then break;
    rLastCng['VERSEXE']:=ReadVal(stInteger);
    rLastCng['D']:=ReadVal(stDouble);
    rLastCng[fTXT]:=ReadStr;
    if PrMdLoad(mdgoApp,[]) then SetPBoolean(Params[2],true);
  end;
  DelStack;
end;

procedure TLastCngLs.mgLoad;
var tr,ii,i,l: longint;
  r: TCngVersRec;
begin
  AddStack('TLastCngLs.mgLoad',Self);
	with TModelGet(Sender),ProgPswd,BrQuery1 do if PrMdLoad(mdgoTrnsStart,[]) then try
    l:=ReadVal(stInteger);
    i:=PrMdLoad(mdgoBeg,[longint(@tr),longint(@ii),longint(@r),l]);
    PrMdLoad(mdgoTrnsEnd,
      [PrMdLoad(mdgoEnd,[longint(Sender),
      not ShowStat('Загрузка из основы',StMdLoad,[l,longint(Sender),longint(@r.lCng)],l,i),longint(@r),l,tr,ii])]);
  except
    PrMdLoad(mdgoTrnsEnd,[false]); raise
  end;
  DelStack;
end;

function TLastCngLs.FMdLoad;
var i,l: longint;
  r: PCngVersRec;
  a: TArrStr;
  oName: string;
  mg: TModelGet;
begin
  AddStack('TLastCngLs.FMdLoad',Self);
  result:=null;
  case Oper of
    mdgoTrnsStart: result:=TrnsStart([tLASTCNG,tGLOBSET]);
    mdgoBeg: with BrQuery1 do begin
      DisableControls; SetPLongInt(av[0],Browl1.Row); SetPLongInt(av[1],BrQuery1RECNO.AsInteger); ReOpen;
      CngVersBeg(PCngVersRec(longint(av[2]))^); result:=10;
    end;
    mdgoGet: begin
      if BrQuery1.Eof then LastCng.NewRec([newrNoDoNewRec]) else lsm.GetFromQuery;
      result:=longint(LastCng);
    end;
    mdgoApp: begin
      result:=LastCng.AppUpdRec; BrQuery1.Next;
    end;
    mdgoEnd: begin
      mg:=PointerVar(av[0]);
      with mg,ProgPswd,BrQuery1 do  begin
        result:=av[1]; r:=PointerVar(av[2]);
        if result then begin
          l:=RecordCount-av[3];
          if l>0 then begin
            r.lCng:=true; SetLength(a,l);
            for i:=low(a) to high(a) do begin
              a[i]:=Vtos(BrQuery1RECNO); Next;
            end;
            LastCng.DelRec(a);
          end;
          oName:=RG[UsedFieldName]; RG[UsedFieldName]:=MDFile; RG['MNMLASTCNG']:=MDName;
          i:=RG[UsedFieldNSave]; RG[UsedFieldNSave]:=NSave;
          if RG.UpdateRec then r.lCng:=true;
          if r.lCng then result:=mg.Update(oName,RG[UsedFieldName],i);
          if result then begin
            CngVersEnd(r^); LogWrite(tLASTCNG);
          end;
        end;
        Browl1.BrUpdate(av[4],av[5]); EnableControls;
      end;
    end;
    mdgoTrnsEnd: TrnsEnd(IfThen(av[0],trnsCommit));
  end;
  DelStack;
end;

class procedure TLastCngLs.MDNameFill;
var oLastCng,oRGAct: boolean;
  s: string;
begin
  AddStack('TLastCngLs.MDNameFill');
  oRGAct:=ProgPswd.RG.Active; ProgPswd.RG.OpenRec; s:=ProgPswd.RG['MLASTCNG'];
  if not empty(s) then begin
    oLastCng:=CreateForm(TLastCngLs,LastCngLs);
    if SchemDM.mgLastCng.LoadFromFile(s) then begin
      ProgPswd.RG['MNMLASTCNG']:=SchemDM.mgLastCng.MDName; ProgPswd.RG.UpdateRec;
    end;
    if oLastCng then FormFree(LastCngLs);
  end;
  ProgPswd.RG.Active:=oRGAct;
  DelStack;
end;

procedure TLastCngLs.mgModify;
begin
  AddStack('TLastCngLs.mgModify',Self);
  MsgApplication(WM_LASTCNGMOD);
  DelStack;
end;

procedure PswdKeyProc(Key: longint; tw: TWinControl; var lBreak: boolean);
begin
  AddStack('FLastCng.PswdKeyProc');
  if Key=K_Alt_C then begin
    lBreak:=true; CreateShow(TLastCngLs,LastCngLs,true);
  end;
  DelStack;
end;

procedure ModelGetProc(Before: boolean; var lCreate: boolean);
begin
  AddStack('FLastCng.ModelGetProc');
  if Before then lCreate:=CreateForm(TLastCngLs,LastCngLs)
  else if lCreate then FormFree(LastCngLs);
  DelStack;
end;

procedure LogTrnsValProc(var Prm: TLogTrnsValPrm);
begin
  AddStack('FLastCng.LogTrnsValProc');
  with Prm do
    if LogEqual(Prm,tLASTCNG,'D') then begin
      val:=OurFormatDateTime(LastCngFmtD,Float0(val)); lBreak:=true;
    end
    else if LogEqual(Prm,tLASTCNG,fTXT) then TCrlfLogCompare.Execute(Prm);
  DelStack;
end;

initialization
  AddStack('FLastCng.initialization');
  SetPrim(tLASTCNG,'Последние изменения');
  AddFrom(aPswdKeyProc,PswdKeyProc);
  AddFrom(ModelGetProc);
  LogTrnsValProcAdd(LogTrnsValProc);
  DelStack;
end.
