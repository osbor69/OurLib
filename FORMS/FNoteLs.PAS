unit FNoteLs;

interface

{$I LIBTEST}
uses
  Windows, Messages, Classes, Controls, Menus, DB, Grids, DBGrids, ExtCtrls,
  MyTypes, FrmBrIBp, KeyMenu, Browl, Keylb, Fpanel, RecVal, RecDB, FEdText, FFldedit, 
    ModelGet, DefEdit, CCodeGet;

type
  TNoteLs = class(TFormBrIBPnl)
    de: TDefEdit;
    Rec: TRecVal;
    deUser: TDefEdit;
    procedure FormCreate(Sender: TObject);
    procedure Browl1BrowlKey(key: Integer; tw: TWinControl);
    procedure deFrmShow(Sender: TObject);
    function dePnlValid(Sender: TObject): Boolean;
    procedure Browl1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure FormShow(Sender: TObject);
    function deUserFldCheck(Sender: TObject): Boolean;
  private
    { Private declarations }
    BrQuery1D,BrQuery1T,BrQuery1DEVAL,BrQuery1TXT,BrQuery1COM: TField;
    BrQuery1CDT,BrQuery1SEL,BrQuery1ZGL,BrQuery1USERNAME,BrQuery1CCOM: TStringField;
    BrQuery1RECNO,BrQuery1SYSNUM: TIntegerField;
    BrQuery1CDEVAL: TDateTimeField;
    lsm: TMemGkList;
    TextMemo: TTextMemo;
    procedure BrQuery1CalcFields(Sender: TDataSet);
    procedure BrQuery1AfterOpen(Sender: TDataSet);
    procedure BrQuery1AfterClose(Sender: TDataSet);
    procedure BrQuery1AfterScroll(Sender: TDataSet);
    function Browl1GrayCell(Sender: TObject; const Rect: TRect;
      DataCol: longint; Column: TColumn; State: TGridDrawState): Boolean;
    class procedure NoteNewRec(Sender: TRecDB; lcopy: boolean; const gKey: string);
    procedure NoteCalculate(Sender: TCustomRec; lApp: boolean);
    procedure deFldEnter(Sender: TObject);
    procedure deFldExit(Sender: TObject);
    function deFldCheck(Sender: TObject): Boolean;
    procedure SysNumNext(key: longint; tw: TWinControl);
    procedure ViewTypeWhere;
    procedure mgHelp(Sender: TObject; var ht: THelpTbl);
    procedure mgSave(Sender: TObject; FromEdit: Boolean);
    procedure mgLoad(Sender: TObject; FromEdit: Boolean);
		procedure WMRebuild(var Message: TWMRebuild); message WM_REBUILD;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    Note: TRecDB;
    class function TDbToView(const s: string): string;
  end;

var
  NoteLs: TNoteLs;

implementation

{$R *.dfm}

uses SysUtils,StrUtils,
  My_pr,FrmPswd,DateGet,SpGet,FStat,FSchemDM;

const
  FmtD = 'dd/mm/yyddd';
  FmtT = 'hhnn';
  FmtDEvalT = ' hh:nn';

  fTXT = sMemo+'TXT';
  fCOM = sMemo+'COM';

type TViewType = (nvtNoSys,nvtSys,nvtSysNoSel);

var ViewType: TViewType;
  sUser: string = '';

function CanEdSysNum: boolean;
begin
  AddStack('FNoteLs.CanEdSysNum');
  result := CanPriv(PrivDesign) and CanPriv(NotePrivModelLoad);
  DelStack;
end;

{ TNoteLs }
procedure TNoteLs.FormCreate(Sender: TObject);
var ld: byte;
begin
  AddStack('TNoteLs.FormCreate',Self);
  Note:=TRecDB.Create(Self);
  with Note do begin
    NameRec:='Note'; NameDB:=tNOTE; OnNewRec:=NoteNewRec; OnCalculate:=NoteCalculate; OpenRec;
  end;
  TTimeCurGet.CreateOne;
  TextMemo:=TTextMemo.CreateParent(Self,RbPanel4);
  with TextMemo do begin
    Align:=alClient; BevelOuter:=bvNone; ReadOnly:=true; WordWrapBool:=true;
  end;
  inherited;
  with BrQuery1 do begin 
    BrQuery1RECNO:=Init(DBMain,[fNoteD+','+fNoteT],[],tNOTE,[],QryNone);
    BrQuery1SEL:=CreateStringField('SEL',' ');
    ld:=Length(FormatDateTime(FmtD,Now));
    BrQuery1CDT:=CreateStringField('CDT','Дата',ld+6);
    BrQuery1USERNAME:=CreateStringField(fUSERNAME,'Пользователь');
    if FieldDefs.IndexOf(fNoteSYSNUM)>=0 then begin
      BrQuery1SYSNUM:=CreateIntegerField(fNoteSYSNUM,'Служ.N');
      Browl1.OnGrayCell:=Browl1GrayCell;
      KeyLb1.SetKey(K_Tab,'Вид','Сменить вид',Browl1BrowlKey,'notetab',kmList);
    end;
    BrQuery1ZGL:=CreateStringField('ZGL','Заголовок');
    if FieldDefs.IndexOf(fCOM)>=0 then begin
      BrQuery1COM:=CreateField(fCOM);
      BrQuery1CCOM:=CreateStringField('CCOM','Комментарий',100);
    end;
    if FieldDefs.IndexOf('DEVAL')>=0 then begin
      BrQuery1DEVAL:=CreateField('DEVAL');
      BrQuery1CDEVAL:=CreateDateField('CDEVAL','Дата выполнения',FmtD+FmtDEvalT,ld+Length(FmtDEvalT));
    end;
    BrQuery1D:=CreateField(fNoteD); BrQuery1T:=CreateField(fNoteT); BrQuery1TXT:=CreateField(fTXT);
    if Assigned(BrQuery1SYSNUM) then ViewTypeWhere;
    AfterOpen:=BrQuery1AfterOpen; AfterClose:=BrQuery1AfterClose;
  end;
  de.AssignGet(fNoteT,TTimeCurGet);
  if Assigned(BrQuery1SYSNUM) and CanEdSysNum then begin
    de.OnFldEnter:=deFldEnter; de.OnFldExit:=deFldExit; de.OnFldCheck:=deFldCheck;
    KeyLb1.SetKey(K_Alt_F3,'','Создать основу',Browl1BrowlKey,'mgnote',kmServic);
  end
  else de.DestroyFld(fNoteSYSNUM);
  if Assigned(BrQuery1SYSNUM)
  then KeyLb1.SetKey(K_Alt_F5,'','Загрузить из основы',Browl1BrowlKey,'mgnote',kmServic,NotePrivModelLoad);
  TSpGkLs.GetPrm(de,tNOTE,'ZGL');
  with SchemDM.mgNote do begin
    OnHelp:=mgHelp; OnLoad:=mgLoad; OnSave:=mgSave;
  end;
  DelStack;
end;

procedure TNoteLs.FormShow(Sender: TObject);
begin
  AddStack('TNoteLs.FormShow',Self);
  inherited;
  Browl1.FormShow(Sender); MainRebuild;
  DelStack;
end;

procedure TNoteLs.ViewTypeWhere;
const a: array[TViewType] of string = ('',' (служебные отметки)',' (невыполненные служебные отметки)');
var NoSys: boolean;
begin
  AddStack('TNoteLs.ViewTypeWhere',Self);
  NoSys := ViewType=nvtNoSys;
  with BrQuery1 do if NoSys then begin
    Arg[sWHERE]:=QQNull(Note.TblFldName(fNoteSYSNUM),0); SeekKeys:='';
  end
  else begin
    Arg[sWHERE]:=Note.TblFldName(fNoteSYSNUM)+'<>0'
      +IfThen(ViewType=nvtSysNoSel,sAND+FldIsTrue(Note.TblFldName('SEL'),false));
    SeekKeys:=fNoteD+','+fNoteT;
  end;
  Caption:=BrQuery1.GetPrim+a[ViewType];
  BrQuery1USERNAME.Visible:=NoSys; BrQuery1SYSNUM.Visible:=not NoSys;
  if Assigned(BrQuery1CDEVAL) then
    if NoSys then begin
      BrQuery1CDT.Index:=BrQuery1USERNAME.Index; BrQuery1CDEVAL.Index:=BrQuery1D.Index;
    end
    else begin
      BrQuery1CDEVAL.Index:=BrQuery1USERNAME.Index; BrQuery1CDT.Index:=BrQuery1D.Index;
    end;
  DelStack;
end;

procedure TNoteLs.BrQuery1CalcFields;
var deval: TDateTime;
begin
  AddStack('TNoteLs.BrQuery1CalcFields',Self);
  BrQuery1CDT.AsString:=OurFormatDateTime(FmtD,BrQuery1D.AsDateTime)+' '+TDbToView(BrQuery1T.AsString);
  if Assigned(BrQuery1COM) and Assigned(lsm)
  then BrQuery1CCOM.AsString:=DelTrim(StrTran(lsm.GetValue(BrQuery1COM.AsInteger),CRLF,' '));
  if Assigned(BrQuery1DEVAL) then begin
    deval:=BrQuery1DEVAL.AsFloat;
    if not empty(deval) then BrQuery1CDEVAL.AsDateTime:=deval;
  end;
  DelStack;
end;

procedure TNoteLs.WMRebuild;
begin
  AddStack('TNoteLs.WMRebuild',Self);
  if Message.Oper=rbBefore then if Assigned(BrQuery1SEL) then Browl1.ColWidths[0]:=bmCheckSize.cX+2;
  DelStack;
end;

procedure TNoteLs.WMFormLimit;
begin
	AddStack('TNoteLs.WMFormLimit',Self);
  inherited;
  FreeLimit(NoteLs);
  DelStack;
end;

procedure TNoteLs.Browl1BrowlKey(key: Integer; tw: TWinControl);
  function GetUser: boolean;
  var s,s1: string;
  begin
    AddStack('TNoteLs.Browl1BrowlKey.GetUser',Self);
    if (ViewType<>nvtNoSys) and (sUser='') then begin
      result:=deUser.Execute.Saved;
      if result then sUser:=TrimRight(Rec['USER']);
    end
    else result:=true;
    if result then begin
      Note.GotoRec(BrQuery1RECNO);
      if ViewType<>nvtNoSys then begin
        s:=Note[fCOM];
        if empty(s) then Note[fCOM]:=sUser+CRLF
        else begin
          s1:=TrimRight(s);
          if not AnsiEndsText(sUser,s1) then Note[fCOM]:=s1+CRLF+sUser;
        end;
      end;
    end;
    DelStack;
  end;
var s: string;
  fl,lSel: boolean;
  i,tr: longint;
begin
  AddStack('TNoteLs.Browl1BrowlKey',Self);
  inherited;
  BrQuery1.AfterScroll:=nil;
  try
    s:=Trim(BrQuery1USERNAME.AsString);
    fl := (s='') or (s=Trim(ProgPswd.UserName)) or PswdPrm.SuperUser;
    if Assigned(BrQuery1SYSNUM) then AndD(fl,(BrQuery1SYSNUM.AsInteger=0) or CanEdSysNum);
    if BrQuery1.CanEdit(Key,[K_Tab,K_Alt_F5]) then case Key of
      K_F4,K_F7: Browl1.AppRec('Добавить',Note,de,IfThen(Key));
      K_F5,K_Enter: if fl then Browl1.EditRec('Редактировать',Note,de);
      K_F8: if fl then Browl1.DelAsk(Note);
      K_Tab: begin
        i:=BrQuery1RECNO.AsInteger; tr:=Browl1.Row;
        if ViewType=high(ViewType) then ViewType:=low(ViewType) else Inc(ViewType);
        ViewTypeWhere; Browl1.BrUpdate(tr,i);
      end;
      K_Space,K_Ins: begin
        SetLogVid(logvEditRec);
        if Assigned(BrQuery1SYSNUM) then Or_D(fl,BrQuery1SYSNUM.AsInteger>0);
        if fl then begin
          lSel:=not StrToBoolean(BrQuery1SEL);
          if lSel then fl:=GetUser else Note.GotoRec(BrQuery1RECNO);
          if fl then begin
            Note['SEL']:=bStr[lSel];
            if lSel then Note['DEVAL']:=NowDouble;
            i:=Note.RecNo; Note.UpdateRec(true);
            if ViewType=nvtSysNoSel then with BrQuery1 do begin
              DisableControls; Next; i:=BrQuery1RECNO.AsInteger; EnableControls; Key:=K_Space;
            end;
            Browl1.BrUpdate(NegDef,i);
          end;
        end;
        if Key=K_Ins then BrQuery1.Next;
        SetLogVid;
      end;
      K_Ctrl_F5: begin
        SetLogVid(logvEditRec);
        if GetUser then begin
          s:=Note[fCOM];
          if EdTextExec('Комментарий',s) then begin
            Note[fCOM]:=s;
            if Note.UpdateRec(true) then Browl1.BrUpdate;
          end;
        end;
        SetLogVid;
      end;
      K_Ctrl_F6: begin
        if Assigned(BrQuery1SYSNUM) then i:=BrQuery1SYSNUM.AsInteger else i:=0;
        PrnTxtExec(DlmBetween(
          [IfThen(not empty(BrQuery1D.AsDateTime),dtoc(BrQuery1D.AsDateTime))+' '
          +IfThen(not empty(BrQuery1T.AsString),TDbToView(BrQuery1T.AsString))
          ,IfThen(not empty(i),StrNum('№ ',i))
          ,BrQuery1ZGL.AsString
          ,TextMemo.Text
          ],CRLF));
      end;
      K_Alt_F3: SchemDM.mgNote.Add;
      K_Alt_F5: SchemDM.mgNote.List;
      K_Alt_F6: Browl1.FindMemo(@lsm);
    end;
  finally
    BrQuery1.AfterScroll:=BrQuery1AfterScroll; BrQuery1AfterScroll(BrQuery1.DataSet);
  end;
  DelStack;
end;

class procedure TNoteLs.NoteNewRec;
begin
  AddStack('TNoteLs.NoteNewRec');
  Sender[fNoteD]:=Date; Sender[fNoteT]:=FormatDateTime(FmtT,Now);
  DelStack;
end;

procedure TNoteLs.NoteCalculate;
var fl: boolean;
begin
  AddStack('TNoteLs.NoteCalculate',Self);
  if lApp then begin
    if Assigned(BrQuery1SYSNUM) then fl := Note[fNoteSYSNUM]=0 else fl:=true;
    Note[fUSERNAME]:=IfThen(fl,ProgPswd.UserName);
  end;
  DelStack;
end;

procedure TNoteLs.deFrmShow(Sender: TObject);
begin
  AddStack('TNoteLs.deFrmShow',Self);
  Rec[fNoteT]:=TDbToView(Note[fNoteT]);
  DelStack;
end;

function TNoteLs.dePnlValid(Sender: TObject): Boolean;
begin
  AddStack('TNoteLs.dePnlValid',Self);
  LogFields.AddRecFld(Note,fNoteT); Note[fNoteT]:=LeftStr(Rec[fNoteT],2)+Copy(Rec[fNoteT],4,2); result:=true;
  DelStack;
end;

procedure TNoteLs.BrQuery1AfterOpen;
begin
  AddStack('TNoteLs.BrQuery1AfterOpen',Self);
  with BrQuery1 do begin
    if not Assigned(lsm) then begin
      OnCalcFields:=nil; AfterScroll:=nil; lsm:=TMemGkList.Create(Note,BrQuery1);
      OnCalcFields:=BrQuery1CalcFields; AfterScroll:=BrQuery1AfterScroll;
      First;
    end;
    if SeekKeys='' then Last;
  end;
  DelStack;
end;

procedure TNoteLs.BrQuery1AfterClose;
begin
  AddStack('TNoteLs.BrQuery1AfterClose',Self);
  lsm:=nil;
  DelStack;
end;

procedure TNoteLs.BrQuery1AfterScroll;
begin
  AddStack('TNoteLs.BrQuery1AfterScroll',Self);
  TextMemo.Text:=TrimRight(lsm.GetValue(BrQuery1TXT.AsInteger));
  DelStack;
end;

procedure TNoteLs.Browl1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  AddStack('TNoteLs.Browl1DrawColumnCell',Self);
  inherited;
  Browl1.bmCheckPaint(Rect,Column,BrQuery1SEL);
  DelStack;
end;

function TNoteLs.Browl1GrayCell;
begin
  AddStack('TNoteLs.Browl1GrayCell',Self);
  result := BrQuery1SYSNUM.AsInteger>0;
  DelStack;
end;

procedure TNoteLs.deFldEnter;
begin
  AddStack('TNoteLs.deFldEnter',Self);
  if TFldEdit(Sender).NameRecFld=fNoteSYSNUM then with FormKeyLb(de.Panel) do begin
    SetKey(K_F7,'Следующий','Следующий свободный служебный номер',SysNumNext,'sysnumnext',kmEdit);
    Redrw;
  end;
  DelStack;
end;

procedure TNoteLs.deFldExit;
begin
  AddStack('TNoteLs.deFldExit',Self);
  if TFldEdit(Sender).NameRecFld=fNoteSYSNUM then with FormKeyLb(de.Panel) do begin
    DelKey(K_All,'sysnumnext'); Redrw;
  end;
  DelStack;
end;

procedure TNoteLs.SysNumNext;
begin
  AddStack('TNoteLs.SysNumNext',Self);
  de.FldValue[fNoteSYSNUM]:=Note.KodNext(fNoteSYSNUM);
  DelStack;
end;

function TNoteLs.deFldCheck;
begin
  AddStack('TNoteLs.deFldCheck',Self);
  if empty(Note[fNoteSYSNUM])
  then result:=true
  else KodCheck(Sender,fNoteSYSNUM,result,'','Запись с таким служебным номером уже есть.',[chkNoEmpty]);
  DelStack;
end;

procedure TNoteLs.mgHelp;
var n: byte;
begin
  AddStack('TNoteLs.mgHelp',Self);
  n:=high(ht.Dat); SetLength(ht.Dat,n+6);
  Inc(n); CopyFrom(ht.Dat[n],'Количество записей. Для каждой записи:');
  Note.HelpTblAdd(ht,n,[fNoteSYSNUM,fNoteD,'ZGL',fTXT],1);
  DelStack;
end;

procedure TNoteLs.mgSave;
var lsm: TMemGkList;
  t: string;
begin
  AddStack('TNoteLs.mgSave',Self);
	with TModelGet(Sender),ProgPswd,GetQuery do begin
    PartSelect(tNOTE,[fNoteSYSNUM,fNoteD,fNoteT,'ZGL',fTXT,fRECNO],
      Note.TblFldName(fNoteSYSNUM)+'>0',fNoteSYSNUM);
    lsm:=TMemGkList.Create(Note);
    WriteVal(RecordCount,stInteger);
    while not Eof do begin
      WriteVal(Fields[0].AsInteger,stInteger);
      t:=Fields[2].AsString;
      WriteVal(Fields[1].AsDateTime+EncodeTimeTry(Int0(LeftStr(t,2)),Int0(Copy(t,3,2)),0,0),stDouble);
      WriteStr1(TrimRight(Fields[3].AsString));
      lsm.GetFromQuery;
      WriteStr(TrimRight(Note[fTXT]));
      Next;
    end;
    FreeQuery; RG[UsedFieldName]:=MDFile; RG[UsedFieldNSave]:=NSave; RG.UpdateRec(true);
  end;
  DelStack;
end;

procedure StMdLoad(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var j,l,n: longint;
  d: TDateTime;
  lsm1: TMemGkList;
  a: PArrStr;
  i: PLongInt;
begin
  AddStack('FNoteLs.StMdLoad');
  l:=Params[0]; lsm1:=PointerVar(Params[2]); a:=PointerVar(Params[3]); i:=PointerVar(Params[4]);
  for j:=1 to l do with ModelGetVar(Params[1]),NoteLs,ProgPswd.CurQuery do begin
    n:=ReadVal(stInteger);
    if Sender.SayStat('',StrNum('Служебный номер: ',n),j/l) then break;
    while not Eof and (Fields[0].AsInteger<n) do begin
      a^[i^]:=Vtos(Fields[5]); Inc(i^); Next;
    end;
    if not Eof and (Fields[0].AsInteger=n) then begin
      lsm1.GetFromQuery; Next;
    end
    else begin
      Note.NewRec([newrNoDoNewRec]); Note[fNoteSYSNUM]:=n;
    end;
    d:=ReadVal(stDouble); Note[fNoteD]:=trunc(d); Note[fNoteT]:=FormatDateTime(FmtT,d);
    Note['ZGL']:=ReadStr(1); Note[fTXT]:=ReadStr; Note.AppUpdRec;
  end;
  DelStack;
end;

procedure TNoteLs.mgLoad;
var lsm1: TMemGkList;
  l,i: longint;
  a: TArrStr;
  fl: boolean;
begin
  AddStack('TNoteLs.mgLoad',Self);
	with TModelGet(Sender),ProgPswd,GetQuery do begin
    if TrnsStart([tNOTE,tGLOBSET]) then try
      PartSelect(tNOTE,[fNoteSYSNUM,fNoteD,fNoteT,'ZGL',fTXT,fRECNO],fNoteSYSNUM+'>0',fNoteSYSNUM);
      lsm1:=TMemGkList.Create(Note); SetLength(a,RecordCount); i:=0; l:=ReadVal(stInteger);
      fl:=not ShowStat('Загрузка из основы',StMdLoad,[l,longint(Sender),longint(lsm1),longint(@a),longint(@i)],l,10);
      if fl then begin
        while not Eof do begin
          a[i]:=Vtos(Fields[5]); Inc(i); Next;
        end;
        Note.DelRec(a,i);
        RG[UsedFieldNSave]:=NSave; RG.UpdateRec; LogWrite(tNOTE); Browl1.BrUpdate;
      end;
      TrnsEnd(IfThen(fl,trnsCommit));
    except
      TrnsEnd; raise
    end;
    FreeQuery;
  end;
  DelStack;
end;

function TNoteLs.deUserFldCheck(Sender: TObject): Boolean;
begin
  AddStack('TNoteLs.deUserFldCheck',Self);
  NoEmpCheck(Sender,'USER',result);
  DelStack;
end;

class function TNoteLs.TDbToView;
begin
  AddStack('TNoteLs.TDbToView');
  result:=Padr(s,2)+':'+Copy(s,3,2);
  DelStack;
end;

procedure PswdKeyProc(Key: longint; tw: TWinControl; var lBreak: boolean);
begin
  AddStack('FNoteLs.PswdKeyProc');
  if Key=K_Alt_N then begin
    lBreak:=true; CreateShow(TNoteLs,NoteLs,true);
  end;
  DelStack;
end;

procedure ModelGetProc(Before: boolean; var lCreate: boolean);
begin
  AddStack('FNoteLs.ModelGetProc');
  if Before then lCreate:=CreateForm(TNoteLs,NoteLs)
  else if lCreate then FormFree(NoteLs);
  DelStack;
end;

procedure LogTrnsValProc(var Prm: TLogTrnsValPrm);
begin
  AddStack('FNoteLs.LogTrnsValProc');
  with Prm do
    if LogEqual(Prm,tNOTE,fNoteT) then begin
      val:=TNoteLs.TDbToView(val); lBreak:=true;
    end
    else if LogEqual(Prm,tNOTE,'DEVAL') then begin
      val:=FormatDateTime(FmtD+FmtDEvalT,Float0(val)); lBreak:=true;
    end
    else if LogEqual(Prm,tNOTE,[fCOM,fTXT]) then TCrlfLogCompare.Execute(Prm);
  DelStack;
end;

initialization
  AddStack('FNoteLs.initialization');
  SetPrim(tNOTE,'Записная книжка');
  AddFrom(aPswdKeyProc,PswdKeyProc);
  AddFrom(ModelGetProc);
  LogTrnsValProcAdd(LogTrnsValProc);
  DelStack;
end.
