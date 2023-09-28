unit FEdoVdLs;

interface

uses
  Windows, Messages, Classes, Controls, Menus, DB, Grids, DBGrids, ExtCtrls, SysUtils, Dialogs,
  MyTypes, FrmSel, KeyMenu, Browl, Keylb, Fpanel, RecDB, DefEdit,
  FFldedit, CCodeGet, DirGet, ArrGet;

type
  TEdoVdLs = class(TFormSel)
    de: TDefEdit;
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure Browl1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure deFldExit(Sender: TObject);
    function deFldCheck(Sender: TObject): Boolean;
  private
    { Private declarations }
    BrQuery1RECNO: TIntegerField;
    BrQuery1FMT: TField;
    BrQuery1CFMT,BrQuery1RTFFMT: TStringField;
    lsm: TMemGkList;
    oinf: TRDBSaveInf;
    aarh: TArrGetFld;
    procedure BrQuery1AfterOpen(DataSet: TDataSet);
    procedure BrQuery1AfterClose(DataSet: TDataSet);
    procedure ProcKey(key: Integer; tw: TWinControl);
    function DelStart(Sender: TObject): boolean;
    procedure DelExec(db: TRecDB; var tr,ii: longint);
    procedure DelExcept(ost: longint; E: Exception; const Msg: string);
  	procedure NewNum(const oldnum: string; Options: TCngNumOptions; var result: boolean);
    procedure WMFormLimit(var msg: TMessage); message WM_FORMLIMIT;
  protected
    procedure Init; override;
    procedure BrQuery1CalcFields(DataSet: TDataSet); override;
  public
    { Public declarations }
    Modified: boolean;
  end;

var
  EdoVdLs: TEdoVdLs;

implementation

{$R *.dfm}

uses StrUtils,
  My_Pr,FrmPswd,FCngNum,FEdoDM,FEdoOrLs;

procedure EdoProcStd(Oper: TEdoOperStd; const av: array of variant; var result: variant;
  var lBreak: boolean);
begin
  AddStack('FEdoVdLs.EdoProcStd');
  case Oper of
    edoVdGetBefore: begin
      CreateForm(TEdoVdLs,EdoVdLs); result:=longint(EdoVdLs); lBreak:=true;
    end;
    edoVdGetAfter: begin
      FormFree(EdoVdLs); lBreak:=true;
    end;
  end;
  DelStack;
end;

{ TEdoVdLs }
procedure TEdoVdLs.Init;
const	aFmt: TMSOFmtStr = ('Спрашивать при создании','HTML','RTF','XLS');
begin
  AddStack('TEdoVdLs.Init',Self);
  aarh:=TArrGetFld.CreateNum(EdoDM.Vd,'AARH');
  with BrQuery1 do begin
    BrQuery1RECNO:=Init(DBMain,[tEDOVD+'.'+fEDOVD],[tEDOVD+'.'+fEDOVD],tEDOVD,
      [tEDOVD+'.'+fEDOVD,tEDOVD+'.'+fNAME,tEDOVD+'.FMT',tEDOVD+'.RTFFMT',tEDOVD+'.'+sArray+'ARH',tRecno(tEDOVD)]);
    AfterOpen:=BrQuery1AfterOpen; AfterClose:=BrQuery1AfterClose;
    Browl1.FieldSeek:=CreateStringField(fEDOVD,'',0,taRightJustify);
    CreateStringField(fNAME);
    BrQuery1FMT:=CreateField('FMT');
    BrQuery1CFMT:=CreateStringField('CFMT','Исх.',MaxSelf(aEdoFmt));
    BrQuery1RTFFMT:=CreateStringField('RTFFMT','Конверт.');
    CreateField(sArray+'ARH');
    Browl1.FieldLong:=CreateStringField('AARH','Папки архивов',MaxByte);
  end;
  de.Param['FMT',deMask]:=RadioMask(aFmt,byte(low(aFmt)));
  DelStack;
end;

procedure TEdoVdLs.FormDestroy(Sender: TObject);
begin
  AddStack('TEdoVdLs.FormDestroy',Self);
  aarh.Free;
  inherited;
  DelStack;
end;

procedure TEdoVdLs.FormShow(Sender: TObject);
begin
  AddStack('TEdoVdLs.FormShow',Self);
  EdoDM.Vd.SaveInf(oinf);
  with KeyLb1 do if SelVisible then DelKey(K_All,'edovd')
  else begin
    SetKey(K_F2,'Порядок','Последовательность подписания',ProcKey,'edovd',kmList);
    SetKey(K_F3,'Сменить','Сменить номер',ProcKey,'edovd',kmList);
    SetKey(K_F4,'Скопировать','',ProcKey,'edovd',kmList);
    SetKeys([K_F5,K_Enter],'Редактировать','',ProcKey,'edovd',kmList);
    SetKey(K_F7,'Добавить','',ProcKey,'edovd',kmList);
    SetKey(K_F8,'Удалить','',ProcKey,'edovd',kmList);
  end;
  inherited;
  Modified:=false;
  DelStack;
end;

procedure TEdoVdLs.FormHide(Sender: TObject);
begin
  AddStack('TEdoVdLs.FormHide',Self);
  inherited;
  TRecDB.RestInf(oinf);
  DelStack;
end;

procedure TEdoVdLs.BrQuery1AfterOpen;
begin
  AddStack('TEdoVdLs.BrQuery1AfterOpen',Self);
  if not Assigned(lsm) then with BrQuery1 do begin
    OnCalcFields:=nil; lsm:=TMemGkList.Create(EdoDM.Vd,BrQuery1); OnCalcFields:=BrQuery1CalcFields; First;
  end;
  DelStack;
end;

procedure TEdoVdLs.BrQuery1AfterClose;
begin
  AddStack('TEdoVdLs.BrQuery1AfterClose',Self);
  lsm:=nil;
  DelStack;
end;

procedure TEdoVdLs.BrQuery1CalcFields;
var i: longint;
  s,so: string;
begin
  AddStack('TEdoVdLs.BrQuery1CalcFields',Self);
  inherited;
  if Assigned(lsm) then begin
    lsm.GetFromQuery; s:='';
    with aarh.rdb do begin
      ArrValue:=EdoDM.Vd['AARH'];
      for i:=1 to ArrCount do begin
        GotoRec(i); IncD(s,';'+Value[fEdoVdPath]); so:=Trim(Value[fEdoVdOrg]);
        if so<>'' then IncD(s,'('+so+')');
      end;
    end;
    Browl1.FieldLong.AsString:=Copy(s,2,MaxInt);
  end;
  BrQuery1CFMT.AsString:=aEdoFmt[TMSOFmtList(BrQuery1FMT.AsInteger)];
  DelStack;
end;

procedure TEdoVdLs.Browl1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  AddStack('TEdoVdLs.Browl1DrawColumnCell',Self);
  inherited;
  Browl1.bmCheckPaint(Rect,Column,BrQuery1RTFFMT);
  DelStack;
end;

function aTbl(const a: array of string): TArrStr;
begin
  AddStack('FEdoVdLs.aTbl');
  CopyFrom(result,a); EdoProc(edoVdTbl,[longint(@result)]);
  DelStack;
end;

function DelMsg: string;
begin
  AddStack('FEdoVdLs.DelMsg');
  with EdoDM do result:='Вид используется в подписываемых документах.'+CRLF
    +EdoInCapt(Inn['VD'],Inn['COD'],Inn[fNAME],Inn['PRIM'],Inn['D']);
  DelStack;
end;

procedure TEdoVdLs.ProcKey;
  procedure Modify;
  begin
    AddStack('TEdoVdLs.ProcKey.Modify',Self);
    EdoDM.VdGet.ClearBuf; ProgPswd.SendUpd(updCodeGet); Modified:=true;
    DelStack;
  end;
var kv: string;
  lEdit: boolean;
  i: longint;
  a: TDEPrmStr;
begin
  AddStack('TEdoVdLs.ProcKey',Self);
  if BrQuery1.CanEdit(Key) then case Key of
    K_F2: begin
      kv:=Browl1.FieldSeek.AsString;
      if TEdoOrdLs.Execute(0,kv,EdoProc(edoOrgDef,[],''),1,'вид '+Trim(kv)) then Modified:=true;
    end;
    K_F3: if TCngNum.GetNewNum('Новый номер вида',Browl1,EdoDM.Vd,fEDOVD,
      aTbl([tEDOVD,tEDOORD,tEDOIN]),[],'',NewNum) then Modify;
    K_F4,K_F7: if Browl1.AppRec('Добавление вида',EdoDM.Vd,de,IfThen(Key),'',fEDOVD) then Modify;
    K_F5,K_Enter: begin
      lEdit:=EdoVdCanEdit(Browl1.FieldSeek.AsString);
      for i:=1 to de.Fields.Count-1 do begin
        a:=de.GetArrParam(i);
        a[deNoReadOnly]:=bStr[lEdit or (a[deNameRecFld]='AARH')];
        de.SetArrParam(i,a);
      end;
      if Browl1.EditRec(IfThen(lEdit,'Редактирование','Просмотр')+' вида',EdoDM.Vd,de,fEDOVD) then Modify;
    end;
    K_F8: begin
      kv:=Browl1.FieldSeek.AsString;
      if not EdoDM.Inn.SeekMsg(tEDOIN+'.'+fEDOVD+'='+QQs(kv)+sAND+FldIsTrue('INARH',false),
      'Вид используется в подписываемых документах.') then
      if EdoProc(edoVdCanDel,[kv],true) then
      if Browl1.DelAsk(EdoDM.Vd,DelStart,'',DelExec,true,nil,DelExcept) then Modify;
    end;
  end;
  DelStack;
end;

procedure TEdoVdLs.deFldExit(Sender: TObject);
begin
  AddStack('TEdoVdLs.deFldExit',Self);
  SpaceStrSelf(Sender,fEDOVD);
  DelStack;
end;

function TEdoVdLs.deFldCheck(Sender: TObject): Boolean;
begin
  AddStack('TEdoVdLs.deFldCheck',Self);
  KodCheck(Sender,fEDOVD,result);
  DelStack;
end;

function TEdoVdLs.DelStart;
begin
  AddStack('TEdoVdLs.DelStart',Self);
  result:=TrnsStart(aTbl([tEDOVD,tEDOORD]));
  DelStack;
end;

procedure TEdoVdLs.DelExec;
begin
  AddStack('TEdoVdLs.DelExec',Self);
  ProgPswd.DeleteTable(tEDOORD,fEDOVD+'='+Browl1.QQs);
  TrnsEnd([trnsCommit]);
  DelStack;
end;

procedure TEdoVdLs.DelExcept;
begin
  TrnsEnd; raise E.Create(Msg);
end;

procedure TEdoVdLs.NewNum;
var newnum: string;
begin
  AddStack('TEdoVdLs.NewNum',Self);
  newnum:=EdoDM.Vd[fEDOVD]; result:=EdoProc(edoVdCngNum,[oldnum,newnum],true);
  if result then with ProgPswd.GetQuery do begin
    UpdateTable(tEDOORD,[fEDOVD],[QQs(newnum)],fEDOVD+'='+QQs(oldnum));
    UpdateTable(tEDOIN,Arg[sWHERE]);
  end;
  DelStack;
end;

procedure TEdoVdLs.WMFormLimit;
begin
  AddStack('TEdoVdLs.WMFormLimit');
  inherited;
  FreeLimit(EdoVdLs);
  DelStack;
end;

initialization
  AddStack('FEdoVdLs.initialization');
  AddFrom(EdoProcStd);
  DelStack;
end.
