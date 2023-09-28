unit FDFrmLs;

interface

{$I LIBTEST}
uses
  Windows, Messages, Classes, Controls, Menus, Db, Grids, DBGrids, ExtCtrls,
  MyTypes, FRMBRIB, KeyMenu, Browl, Keylb, Fpanel, FDWPrm, CodeGets;

type
  TDfrmLsOper = (dflCreate,dflShow,dflDelNoChk,dflCanDel,dflNewCodPrm,dflNewCod,dflProcKey);
  TDfrmLsProc = procedure(oper: TDfrmLsOper; const av: array of variant);

  TDFrmLs = class(TFormBrIB)
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function Browl1GrayCell(Sender: TObject; const Rect: TRect;
      DataCol: longint; Column: TColumn; State: TGridDrawState): Boolean;
    procedure FormDestroy(Sender: TObject);
    procedure Browl1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: longint; Column: TColumn; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure KeyLb1ProcKey(key: Integer; tw: TWinControl);
  private
    { Private declarations }
    BrQuery1NF: TStringField;
    BrQuery1RECNO: TIntegerField;
    BrQuery1CD: TBooleanField;
    BrQuery1MEM_D: TField;
    KeyShow: boolean;
    LsMDNew,LsUsed: TStringList;
    dw: TDWWin;
    procedure BrQuery1CalcFields(DataSet: TDataSet);
		procedure BrQuery1OrderChange(Sender: TObject);
		procedure NewCod(const oldnum: string; Options: TCngNumOptions; var result: boolean);
		procedure ProcKey(key: longint; tw: TWinControl);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
		procedure WMHelpFill(var Message: TWMHelpFill); message WM_HELPFILL;
  public
    BrQuery1KF: TStringField;
    class procedure Init(Proc: TDfrmLsProc = nil);
    procedure LsUsedClear;
  end;

const DfrmVName = 'Dfrm';

var
  DFrmLs: TDFrmLs;
  DfrmCodeGet: TCodeGet;

implementation

{$R *.DFM}

uses SysUtils,Forms,Variants,
  My_pr,FCngNum,FFldEdit,FrmPswd,FDFrmEd,MulQry,FHelpLs,FSchemDM;

type
 TNone = class
 private
    class function Browl1TransSeek(Sender: TObject; const Value: String;
      Size: longint; lQuery: boolean): String;
    class procedure DfrmGetAfterList(Sender: TObject);
    class function DfrmGetFormIBList(Sender: TFldEdit): TFormBrIB;
    class function DfrmGetTransSeek(Sender: TObject; tf: TFldEdit;
      const Value: String; Size: longint; lSQL: Boolean): String;
 end;

var FProc: TDfrmLsProc;

procedure Proc(oper: TDfrmLsOper; const av: array of variant);
begin
  AddStack('FDFrmLs.Proc');
  if Assigned(FProc) then FProc(oper,av);
  DelStack;
end;

{ TDFrmLs }
procedure TDFrmLs.FormCreate(Sender: TObject);
begin
	AddStack('TDFrmLs.FormCreate',Self);
  inherited;
  with BrQuery1 do begin
  	BrQuery1RECNO:=Init(DBMain,[fDfrmNF,fDfrmKF],[fDfrmKF],tDFRM,[],'','',BrQuery1CalcFields);
    BrQuery1NF:=CreateStringField(fDfrmNF,'Номер',0,taRightJustify); Browl1.FieldSeek:=BrQuery1NF;
    BrQuery1KF:=CreateStringField(fDfrmKF,'Код');
    CreateStringField(fNAME,'Наименование');
    BrQuery1CD:=CreateBooleanField('CD','Данные');
    CreateField(fFRM);
    ModelCreateFields;
    BrQuery1MEM_D:=CreateField(DWMem);
    OnOrderChange:=BrQuery1OrderChange;
  end;
  Proc(dflCreate,[longint(KeyLb1)]);
  DelStack;
end;

procedure TDFrmLs.FormDestroy(Sender: TObject);
begin
  AddStack('TDFrmLs.FormDestroy',Self);
  LsMDNew.Free; LsUsed.Free;
  inherited;
  DelStack;
end;

procedure TDFrmLs.FormShow(Sender: TObject);
var fl: boolean;
begin
	AddStack('TDFrmLs.FormShow',Self);
  inherited;
  with KeyLb1 do begin
    if Browl1.CloseOnSelect=KeyShow then begin
      NotD(KeyShow);
      if KeyShow then begin
        SetKey(K_F3,'Сменить','Сменить код',ProcKey,'dfrm',kmList);
        SetKey(K_F4,'Скопировать','',ProcKey,'dfrm',kmList);
        SetKeys([K_F5,K_Enter],'Редактировать','',ProcKey,'dfrm',kmList);
        SetKey(K_F7,'Добавить','',ProcKey,'dfrm',kmList);
        SetKey(K_F8,'Удалить','',ProcKey,'dfrm',kmList);
        fl:=false; Proc(dflDelNoChk,[longint(@fl)]);
        if fl then SetKey(K_Ctrl_F8,'','Удалить без проверки',ProcKey,'dfrm',kmList,PrivDesign);
        SetKey(K_Alt_F3,'','Создать основу',ProcKey,'dfrm',kmList);
        SetKey(K_Alt_F5,'','Загрузить из основы',ProcKey,'dfrm',kmList);
        SetKey(K_Alt_F8,'','Отметить устаревшие',ProcKey,'dfrm',kmList);
        SetKey(K_Ctrl_F5,'Данные','Редактирование данных по дополнительной формуле',ProcKey,'dfrm',kmList);
        KeyMenu1.InsLine(kmList,K_Alt_F3);
      end
      else begin
        KeyMenu1.DelLine(kmList,K_Alt_F3); DelKey(K_All,'dfrm');
      end;
    end;
    Proc(dflShow,[longint(KeyLb1),KeyShow]); ReDrw;
  end;
  DelStack;
end;

procedure TDFrmLs.FormHide(Sender: TObject);
begin
	AddStack('TDFrmLs.FormHide',Self);
  if Assigned(LsMDNew) then LsMDNew.Clear;
  FreeAndNil(LsUsed);
  inherited;
  DelStack;
end;

procedure TDFrmLs.KeyLb1ProcKey(key: Integer; tw: TWinControl);
begin
  AddStack('TDFrmLs.KeyLb1ProcKey',Self);
  inherited;
  Proc(dflProcKey,[key,longint(tw),longint(BrQuery1KF),longint(@LsUsed),longint(@LsMDNew)]);
  DelStack;
end;

procedure TDFrmLs.ProcKey;
var fl: boolean;
  atbl: TArrStr;
  opt: TCngNumOptions;
begin
	AddStack('TDFrmLs.ProcKey',Self);
  inherited;
  if BrQuery1.CanEdit(Key) then case Key of
  	K_F3: begin
      CopyFrom(atbl,tDFRM); opt:=[cngNoLockMono]; Proc(dflNewCodPrm,[longint(@atbl),longint(@opt)]);
      if TCngNum.GetNewNum('Новый код дополнительной формулы',Browl1,Dfrm,
      	fDfrmKF,atbl,[LsMDNew,LsUsed],'',NewCod,cteName,nil,nil,opt) then TDFrmEd.Modify;
    end;
  	K_F4,K_F7: if LockEdConf then
      try
        CreateForm(TDFrmEd,DFrmEd); DFrmEd.lCopy := Key=K_F4;
        if Browl1.AppRec('Добавить дополнительную формулу',DFrm,DFrmEd,
          IfThen(DFrmEd.lCopy,brappCopy)+[brappDefFromSelf]) then TDFrmEd.Modify;
      finally
        UnLockEdConf;
      end;
    K_F5,K_Enter: if LockEdConf then
      try
        CreateForm(TDFrmEd,DFrmEd);
        if Browl1.EditRec('Редактировать дополнительную формулу',DFrm,DFrmEd) then begin
          if SchemDM.mgDfrm.ModelUpdList(LsMDNew) then Browl1.Refresh;
          TDFrmEd.Modify;
        end;
      finally
        UnLockEdConf;
      end;
    K_F8,K_Ctrl_F8: if LockEdConf then
      try
        fl:=true;
        if not BrQuery1.IsCodEqual(fDfrmKF) then if Key=K_F8
          then Proc(dflCanDel,[longint(@fl),longint(LsUsed),FieldAsVariant(BrQuery1KF)]);
        if fl then if Browl1.DelAsk(Dfrm) then TDFrmEd.Modify;
      finally
        UnLockEdConf;
      end;
    K_Ctrl_F5: begin
      Dfrm.GotoRec(BrQuery1RECNO); TDfrmEd.PrmEd(TDWWin.CreateOne(dw,Self));
    end;
    K_Alt_F3: SchemDM.mgDfrm.Add(Browl1);
    K_Alt_F5: if LockEdConf then
      try
        if SchemDM.mgDfrm.List(LsMDNew,Browl1) then TDFrmEd.Modify;
      finally
        UnLockEdConf;
      end;
    K_Alt_F8: SchemDM.mgDfrm.ModelNew(Browl1,LsMDNew,BrQuery1KF,@LsUsed);
  end;
	FormFree(DFrmEd);
	DelStack;
end;

procedure TDFrmLs.NewCod;
begin
	AddStack('TDFrmLs.NewCod',Self);
  Proc(dflNewCod,[longint(@result),Longint(LsUsed),oldnum,Dfrm[fDfrmKF]]);
  DelStack;
end;

function TDFrmLs.Browl1GrayCell(Sender: TObject; const Rect: TRect;
  DataCol: longint; Column: TColumn; State: TGridDrawState): Boolean;
begin
  AddStack('TDFrmLs.Browl1GrayCell',Self);
  inherited;
  result:=CodGrayCell(State,LsMDNew,BrQuery1KF,LsUsed);
  DelStack;
end;

procedure TDFrmLs.BrQuery1CalcFields;
begin
	AddStack('TDFrmLs.BrQuery1CalcFields',Self);
  TMulQuery.ModelCalcFields(DataSet); BrQuery1CD.AsBoolean:=not empty(BrQuery1MEM_D.AsInteger);
  DelStack;
end;

procedure TDFrmLs.Browl1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: longint; Column: TColumn; State: TGridDrawState);
begin
	AddStack('TDFrmLs.Browl1DrawColumnCell',Self);
  Browl1.bmCheckPaint(Rect,Column);
  DelStack;
end;

procedure TDFrmLs.WMFormLimit;
begin
	AddStack('TDFrmLs.WMFormLimit',Self);
  inherited;
  FreeLimit(DFrmLs);
  DelStack;
end;

procedure TDFrmLs.WMHelpFill;
begin
  AddStack('TDFrmLs.WMHelpFill',Self);
  inherited;
  with Message do if Oper=hlpAdd then if Dfrm.IsField(sMemo+'HELP') then DfrmHelpEval(BrQuery1KF.AsString,pArr);
  DelStack;
end;

procedure TDFrmLs.LsUsedClear;
begin
  AddStack('TDFrmLs.LsUsedClear',Self);
  if Assigned(Self) then begin
    FreeAndNil(LsUsed); Browl1.Invalidate;
  end;
  DelStack;
end;

procedure TDFrmLs.BrQuery1OrderChange;
begin
  AddStack('TDFrmLs.BrQuery1OrderChange',Self);
  if BrQuery1.Order=2 then begin
  	Browl1.FieldSeek:=BrQuery1KF; Browl1.OnTransSeek:=TNone.Browl1TransSeek;
  end
  else begin
  	Browl1.FieldSeek:=BrQuery1NF; Browl1.OnTransSeek:=nil;
  end;
  MainRebuild;
  DelStack;
end;

class procedure TDFrmLs.Init;
begin
  AddStack('TDFrmLs.Init');
  FProc:=Proc;
  DfrmCodeGet:=TCodeGet.Create(Application.MainForm);
  with DfrmCodeGet,TNone do begin
    VName:=DfrmVName; FieldsCode:=fDfrmKF; OrderCode:=2;
    with MulPar do begin
      Values[sTABLE]:=tDFRM; Values[sC_LIST]:='*'; Values[sWHERE]:=fDfrmKF+qCod_C;
    end;
    Part:=sSELECT_WORDER; TrimLeft:=true;
    OnAfterList:=DfrmGetAfterList; OnFormIBList:=DfrmGetFormIBList; OnTransSeek:=DfrmGetTransSeek;
  end;
  DelStack;
end;

{ TNone }
class function TNone.Browl1TransSeek;
begin
	AddStack('TNone.Browl1TransSeek');
  result:=TrimUpper(Value);
  DelStack;
end;

class procedure TNone.DfrmGetAfterList;
begin
	AddStack('TNone.DfrmGetAfterList');
  FormFree(DfrmLs);
  DelStack;
end;

class function TNone.DfrmGetFormIBList;
begin
	AddStack('TNone.DfrmGetFormIBList');
	CreateForm(TDfrmLs,DfrmLs); result:=DfrmLs;
  DelStack;
end;

class function TNone.DfrmGetTransSeek;
begin
	AddStack('TNone.DfrmGetTransSeek');
	result:=Padr(Value,Size);
  DelStack;
end;

procedure FProcMod;
begin
  AddStack('FDFrmLs.FProcMod');
  DfrmCodeGet.ClearBuf;
  DelStack;
end;

initialization
  AddStack('FDFrmLs.initialization');
  TDFrmEd.AddProcMod(FProcMod);
  DelStack;
end.
