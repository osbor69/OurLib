unit FArrvLs;

interface

{$I LIBTEST}
uses
  Windows, Messages, Classes, Controls, Menus, Db, Grids, DBGrids, ExtCtrls,
  MyTypes, FRMBRIB, KeyMenu, Browl, Keylb, Fpanel, FFldEdit, RecDB;

type
  TArrvLs = class(TFormBrIB)
    procedure FormCreate(Sender: TObject);
    procedure Browl1BrowlKey(key: longint; tw: TWinControl);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function Browl1GrayCell(Sender: TObject; const Rect: TRect;
      DataCol: longint; Column: TColumn; State: TGridDrawState): Boolean;
    function Browl1TransSeek(Sender: TObject; const Value: String;
      Size: longint; lQuery: Boolean): String;
    procedure KeyLb1ProcKey(key: Integer; tw: TWinControl);
  private
    { Private declarations }
    BrQuery1RECNO: TIntegerField;
    ao: TArrStr;
    lo: longint;
    LsMDNew: TStringList;
		procedure NewCod(const oldnum: string; Options: TCngNumOptions; var result: boolean);
		class function PrDel(Sender: TObject): boolean;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
		class function ArrvCodeGetFormIBList(Sender: TFldEdit): TFormBrIB;
		class procedure ArrvCodeGetAfterList(Sender: TObject);
  public
    { Public declarations }
  end;

  TArrvLsOper = (arlsCreate,arlsProcKey);

var
  ArrvLs: TArrvLs;
  ArrvLsProc: procedure(oper: TArrvLsOper; const av: array of variant);

implementation

{$R *.DFM}

uses SysUtils,StrUtils,
  My_pr,FCngNum,FrmPswd,mulqry,FArrvEd,ArrGet,DefEdit,Shifr,RecVal,FStat,CodeGets,FSchemDM;

procedure Proc(oper: TArrvLsOper; const av: array of variant);
begin
  AddStack('FArrvLs.Proc');
  if Assigned(ArrvLsProc) then ArrvLsProc(oper,av);
  DelStack;
end;

{ TArrvLs }
procedure TArrvLs.FormCreate(Sender: TObject);
begin
	AddStack('TArrvLs.FormCreate',Self);
  inherited;
  with BrQuery1 do begin
  	BrQuery1RECNO:=Init(FirstDatabase,[fARRV,fUPNAME],[fARRV],tARRV,[],'','',ModelCalcFields);
    Browl1.FieldSeek:=CreateStringField(fARRV,'Код');
    CreateField(fUPNAME).DisplayLabel:=CreateStringField(fNAME,'Наименование').DisplayLabel;
    ModelCreateFields;
  end;
  Proc(arlsCreate,[longint(KeyLb1)]);
  DelStack;
end;

procedure TArrvLs.FormDestroy(Sender: TObject);
begin
	AddStack('TArrvLs.FormDestroy',Self);
  inherited;
  LsMDNew.Free;
  DelStack;
end;

procedure TArrvLs.FormShow(Sender: TObject);
var bm: TBookMark;
  i: longint;
begin
	AddStack('TArrvLs.FormShow',Self);
  inherited;
  if Browl1.CloseOnSelect then with BrQuery1 do begin
    DisableControls; bm:=GetBookMark;
    try
      lo:=RecordCount; First;
      if Length(ao)<lo then SetLength(ao,lo);
      for i:=0 to lo-1 do begin
        ao[i]:=TrimRight(Browl1.FieldSeek.AsString); Next;
      end;
      GotoBookMark(bm);
    finally
      FreeBookMark(bm);
    end;
    EnableControls; QuickSort(ao,lo);
  end;
  if Assigned(LsMDNew) then LsMDNew.Clear;
  DelStack;
end;

procedure FSeek(Oper: TArrvSeekOper; Prm: pointer; rdb: TRecDBDef; Qry: TMulQuery;
  const Def: TDWArrSeekRec; var aDef: TArrStr; iDef: longint; var rDef: TDWVidRec;
  const ka,Cod,CodName: string; var Changed: boolean; var Aborted: boolean);
begin
  AddStack('FArrvLs.FSeek');
  if Oper=arrvDefFinded then begin
    with rdb do meserr(ArrayAsList([DWName,IfThen(CodName<>'',CRLF+CodName),
      'Данное: '+DWVarName(rDef.Name)],CRLF),
      'Массив "'+ka+'" используется в определении данных');
    Aborted:=true;
  end;
  DelStack;
end;

procedure FCng(Oper: TArrvSeekOper; Prm: pointer; rdb: TRecDBDef; Qry: TMulQuery;
  const Def: TDWArrSeekRec; var aDef: TArrStr; iDef: longint; var rDef: TDWVidRec;
  const ka,Cod,CodName: string; var Changed: boolean; var Aborted: boolean);
begin
  AddStack('FArrvLs.FCng');
  if Oper=arrvDefFinded then begin
    rDef.AValue:=TrimRight(RDBArrv[fARRV]); aDef[iDef]:=DWRecTos(rDef); Changed:=true;
  end;
  DelStack;
end;

procedure TArrvLs.Browl1BrowlKey(key: longint; tw: TWinControl);
  function CanCng(const amsg: array of string): boolean;
  begin
		AddStack('TArrvLs.Browl1BrowlKey.CanCng',Self);
    result:=true;
    if Browl1.CloseOnSelect then
      if QuickFind(TrimRight(Browl1.FieldSeek.AsString),ao,lo) then begin
        mess_ok(amsg); result:=false;
      end;
    DelStack;
  end;
var oka: string;
  a: TArrStr;
  si: TArrSaveIniList;
  lEd: boolean;
  oCurDWFld: TDWVidForm;
label lend;
begin
	AddStack('TArrvLs.Browl1BrowlKey',Self);
  inherited;
  if BrQuery1.CanEdit(Key) then begin
  	oka:=TrimRight(Browl1.FieldSeek.AsString);
    case Key of
      K_F3: if CanCng(['Нельзя изменять код','ранее добавленного вида массивов.']) then begin
        ArrRdbInit(@a); AddFrom(a,[tARRV,tARR]);
        if TCngNum.GetNewNum('Новый код массива',Browl1,RDBArrv,fARRV,a,[LsMDNew],'',NewCod,cteName)
        then TArrvEd.Modify(oka,[aredNoDef,aredCod]);
      end;
      K_F4,K_F5,K_F7,K_Enter: if LockEdConf then begin
        oCurDWFld:=CurDWFld; CurDWFld:=dwfFixArray;
        try
          CreateForm(TArrvEd,ArrvEd); lEd := Key in [K_F5,K_Enter]; ArrvEd.EKa.SetReadOnly(lEd);
          if lEd then begin
            if Browl1.EditRec('Редактирование вида массивов',RDBArrv,ArrvEd) then begin
              TCustomGet.UpdateAllGet(TArrGet,mgArrCng);
              if SchemDM.mgArrv.ModelUpdList(LsMDNew) then Browl1.Refresh;
              TArrvEd.Modify(oka);
            end;
          end
          else if Browl1.AppRec('Добавление вида массивов',RDBArrv,ArrvEd,IfThen(Key))
          then TArrvEd.Modify(RDBArrv[fARRV]);
        finally
          CurDWFld:=oCurDWFld; UnLockEdConf;
        end;
      end;
      K_F8: if CanCng(['Нельзя удалять','ранее добавленный вид массивов.']) then if LockEdConf then
        try
          oka:=TrimRight(Browl1.FieldSeek.AsString);
          if ArrRdbSeek('Поиск в определении данных массива "'+oka+'"',oka,'',FSeek) then
            if Browl1.DelAsk(RDBArrv,PrDel) then try
              RDBArr.DelRec(fARRV+'='+QQs(oka));
              for si:=low(si) to high(si) do TDefEdit.EraseSection(TArrGet.SectIni(si,oka));
              TCustomGet.UpdateAllGet(TArrGet,mgArrDel);
              TArrvEd.Modify(oka,[aredCod]);
              TrnsEndMono(false);
            except
              TrnsEndMono; raise
            end;
        finally
          UnLockEdConf;
        end;
      K_Alt_F3: begin
        CreateForm(TArrvEd,ArrvEd); SchemDM.mgArrv.Add(Browl1);
      end;
      K_Alt_F5: if LockEdConf then
        try
          CreateForm(TArrvEd,ArrvEd); SchemDM.mgArrv.List(LsMDNew,Browl1);
        finally
          UnLockEdConf;
        end;
      K_Alt_F8: begin
        CreateForm(TArrvEd,ArrvEd); SchemDM.mgArrv.ModelNew(Browl1,LsMDNew);
      end;
    end;
  end;
lend:
	FormFree(ArrvEd);
  DelStack;
end;

procedure TArrvLs.NewCod;
var si: TArrSaveIniList;
  ka: string;
begin
	AddStack('TArrvLs.NewCod',Self);
  ka:=TrimRight(Browl1.FieldSeek.AsString);
  result:=ArrRdbSeek('Замена в определении данных массива "'+ka+'" на "'+Trim(RDBArrv[fARRV])+'"',ka,'',FCng,nil,false);
  if result then begin
  	RDBArr.UpdateTable([fARRV],[QQs(RDBArrv[fARRV])],fARRV+'='+QQs(oldnum));
    for si:=low(si) to high(si) do
	    TDefEdit.RenameSection(TArrGet.SectIni(si,oldnum),TArrGet.SectIni(si,RDBArrv[fARRV]));
  end;
  DelStack;
end;

class function TArrvLs.PrDel;
begin
  AddStack('TArrvLs.PrDel');
  result:=TrnsStart([tARRV,tARR],1,FLockMono);
  DelStack;
end;

function TArrvLs.Browl1GrayCell(Sender: TObject; const Rect: TRect;
  DataCol: longint; Column: TColumn; State: TGridDrawState): Boolean;
begin
  AddStack('TArrvLs.Browl1GrayCell',Self);
  inherited;
  result:=CodGrayCell(State,LsMDNew,Browl1.FieldSeek);
  DelStack;
end;

procedure TArrvLs.WMFormLimit;
begin
	AddStack('TArrvLs.WMFormLimit',Self);
  inherited;
  FreeLimit(ArrvLs);
  DelStack;
end;

function TArrvLs.Browl1TransSeek(Sender: TObject; const Value: String;
  Size: longint; lQuery: Boolean): String;
begin
	AddStack('TArrvLs.Browl1TransSeek',Self);
  inherited;
  result:=TrimUpper(Value);
  DelStack;
end;

class function TArrvLs.ArrvCodeGetFormIBList;
begin
	AddStack('TArrvLs.ArrvCodeGetFormIBList');
	CreateForm(TArrvLs,ArrvLs); result:=ArrvLs;
  DelStack;
end;

class procedure TArrvLs.ArrvCodeGetAfterList;
begin
	AddStack('TArrvLs.ArrvCodeGetAfterList');
  FormFree(ArrvLs);
  DelStack;
end;

procedure TArrvLs.KeyLb1ProcKey(key: Integer; tw: TWinControl);
begin
  AddStack('TArrvLs.KeyLb1ProcKey',Self);
  inherited;
  Proc(arlsProcKey,[key,longint(tw)]);
  DelStack;
end;

initialization
  AddStack('FArrvLs.initialization');
  ArrvCodeGetFormIBList:=TArrvLs.ArrvCodeGetFormIBList;
  ArrvCodeGetAfterList:=TArrvLs.ArrvCodeGetAfterList;
  DelStack;
end.

