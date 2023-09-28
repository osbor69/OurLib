unit FEdoOrLs;

interface

uses
  Windows, Messages, Forms, Classes, Controls, Menus, DB, Grids, DBGrids, ExtCtrls,
  MyTypes, My_Pr, FrmBrIB, KeyMenu, Browl, Keylb, Fpanel, RecDB, DefEdit, FFldedit, CCodeGet, ComboGet,
    Codegets, MulQry, RecVal;

type
  TEdoOrdLs = class(TFormBrIB)
    de: TDefEdit;
    Rec: TRecVal;
    procedure FormDestroy(Sender: TObject);
    procedure deFldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure Browl1ShowHint(var HintStr: String; var CanShow: Boolean;
      var HintInfo: THintInfo);
    procedure Browl1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
    BrQuery1ORG,BrQuery1CEDOEXE,BrQuery1USERNAME: TStringField;
    BrQuery1ORD,BrQuery1NC,BrQuery1EDOEXE,BrQuery1ACT,BrQuery1NMC: TField;
    lEdit: boolean;
    FOrg: string;
    FNC: longint;
    lsUn: TIntegerList;
    procedure BrQuery1CalcFields(DataSet: TDataSet);
    procedure BrQuery1BeforeOpen(DataSet: TDataSet);
    function Browl1GrayCell(Sender: TObject; const Rect: TRect;
  	  DataCol: longint; Column: TColumn; State: TGridDrawState): boolean;
    procedure ProcKey(key: Integer; tw: TWinControl);
    procedure OrdNewRec(Sender: TRecDB; lcopy: Boolean; const gKey: String);
    function FUn: longint;
    function FKv: string;
    procedure WMFormLimit(var msg: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    Modified: boolean;
    class function Execute(un: longint; const kv,org: string; nc: longint; const Capt: string): boolean;
  end;

implementation

{$R *.dfm}

uses SysUtils,Variants,StrUtils,Math,
  FEdoDM,FrmPswd;

const
  aAct: TEdoActStr = ('подписание','выгрузка файла для подписания','загрузка подписанного файла');

var EdoOrdLs: TEdoOrdLs;

{ TEdoOrdLs }
class function TEdoOrdLs.Execute;
var i: longint;
  s: string;
  a: TDEPrmStr;
begin
  AddStack('TEdoOrdLs.Execute');
  if CreateForm(TEdoOrdLs,EdoOrdLs) then with EdoOrdLs do begin
    lsUn:=TIntegerList.Create;
    with BrQuery1 do begin
      Arg['un']:=0;
      Init(DBMain,[fEdoORG+','+fEdoNC+','+fEDOORD],[],tEDOORD,
        [fEdoORG,fEdoNC,'NMC',fEDOORD,fUSERNAME,'ACT',fEDOEXE,fRECNO],
        fEDOIN+'={un}'+sAND+fEDOVD+'='+QQs(qGlobKey),'',BrQuery1CalcFields);
      BrQuery1ORG:=CreateStringField(fEdoORG,'',0,taRightJustify);
      BrQuery1NC:=CreateIntegerField(fEdoNC);
      BrQuery1NMC:=CreateField('NMC');
      BrQuery1ORD:=CreateIntegerField(fEDOORD);
      BrQuery1USERNAME:=CreateStringField(fUSERNAME);
      BrQuery1ACT:=CreateField('ACT');
      BrQuery1EDOEXE:=CreateField(fEDOEXE);
      EdoDM.ExeGet.DefLen;
      BrQuery1CEDOEXE:=CreateStringField('CEDOEXE','Программа/действие',max(EdoDM.ExeGet.DefLenName,MaxSelf(aEdoActAbr)));
    end;
    de.Param['ACT',deMask]:=RadioMask(aAct,0);
  end;
  with EdoOrdLs do begin
    BrQuery1.Arg['un']:=un; BrQuery1.GlobKey:=kv; FOrg:=org; FNC:=nc;
    Caption:='Последовательность подписания: '+Capt;
    Modified:=false;
    if un=0 then lEdit:=EdoVdCanEdit(kv) else lEdit:=true;
    with KeyLb1 do begin
      SetKeys([K_F5,K_Enter],IfThen(lEdit,'Редактировать','Просмотр'),'',ProcKey,'edoord',kmList);
      if lEdit then begin
        SetKey(K_F4,'Скопировать','',ProcKey,'edoorded',kmList);
        SetKey(K_F7,'Добавить','',ProcKey,'edoorded',kmList);
        SetKey(K_F8,'Удалить','',ProcKey,'edoorded',kmList);
      end
      else DelKey(K_All,'edoorded');
      if un=0
      then DelKey(K_All,'edoinord')
      else SetKey(K_Alt_Home,'','По умолчанию',ProcKey,'edoinord',kmList);
    end;
    de.GetArrParam(fEdoORG,i,a);
    BrQuery1ORG.Visible := EdoProc(edoOrgGet,[longint(@a)],false) and (un=0);
    a[deNoVisible]:=bStr[not BrQuery1ORG.Visible];
    de.SetArrParam(i,a);
    BrQuery1NC.Visible := un=0; de.SetParams(['C',fEdoNC,'NMC'],deNoVisible,bStr[not BrQuery1NC.Visible]);
    s:=bStr[lEdit];
    for i:=0 to de.Fields.Count-1 do begin
      a:=de.GetArrParam(i); a[deNoReadOnly]:=s;
      if a[deNameRecFld]=fEDOEXE then a[deReadOnlyNoVsbl]:=s;
      de.SetArrParam(i,a);
    end;
    EdoDM.Ord.OnNewRec:=OrdNewRec;
    if un=0 then begin
      BrQuery1.BeforeOpen:=nil; Browl1.OnGrayCell:=nil;
    end
    else begin
      BrQuery1.BeforeOpen:=BrQuery1BeforeOpen; Browl1.OnGrayCell:=Browl1GrayCell;
    end;
    ShowModal; EdoDM.Ord.OnNewRec:=nil; result:=Modified;
  end;
  FormFree(EdoOrdLs);
  DelStack;
end;

procedure TEdoOrdLs.FormDestroy(Sender: TObject);
begin
  AddStack('TEdoOrdLs.FormDestroy',Self);
  lsUn.Free;
  inherited;
  DelStack;
end;

procedure TEdoOrdLs.BrQuery1CalcFields;
begin
  AddStack('TEdoOrdLs.BrQuery1CalcFields',Self);
  BrQuery1CEDOEXE.AsString:=EdoDM.ExeOrAct(BrQuery1ACT,BrQuery1EDOEXE);
  DelStack;
end;

procedure TEdoOrdLs.BrQuery1BeforeOpen;
begin
  AddStack('TEdoOrdLs.BrQuery1BeforeOpen',Self);
  with ProgPswd.GetQuery do begin
    PartSelect(tEDO,fEDOORD,fEDOIN+'='+Vtos(FUn),fEDOORD);
    lsUn.SetOption(ilsSorted,false); SaveTo(lsUn); lsUn.SetOption(ilsSorted,true); 
  end;
  ProgPswd.FreeQuery;
  DelStack;
end;

function TEdoOrdLs.Browl1GrayCell;
begin
  AddStack('TEdoOrdLs.Browl1GrayCell',Self);
  result := lsUn.IndexOf(BrQuery1ORD.AsInteger)>=0;
  DelStack;
end;

procedure TEdoOrdLs.ProcKey;
var fl: boolean;
begin
  AddStack('TEdoOrdLs.ProcKey',Self);
  if BrQuery1.CanEdit(Key) then case Key of
    K_F4,K_F7: if Browl1.AppRec('Добавление',EdoDM.Ord,de,IfThen(Key)) then Modified:=true;
    K_F5,K_F8,K_Enter: begin
      fl:=true;
      if FUn>0 then if lsUn.IndexOf(BrQuery1ORD.AsInteger)>=0 then begin
        fl:=false; meserr('Пользователь '+Trim(BrQuery1USERNAME.AsString)+' уже подписал данный документ.');
      end;
      if fl then case Key of
        K_F5,K_Enter: if Browl1.EditRec(IfThen(lEdit,'Редактирование','Просмотр'),EdoDM.Ord,de) then Modified:=true;
        K_F8:
          if BrQuery1.RecordCountInRange(1,1) then meserr('Нельзя удалять последнюю существующую запись.')
          else if Browl1.DelAsk(EdoDM.Ord) then Modified:=true;
      end
    end;
    K_Alt_Home:
      if lsUn.Count>0 then meserr('Данный документ уже подписан некоторыми пользователями.')
      else if Ask(['Установить последовательность подписания по умолчанию ?']) then begin
        EdoInOrd(FUn,FKv,FOrg,FNC); Browl1.BrUpdate;
      end;
  end;
  DelStack;
end;

procedure TEdoOrdLs.deFldChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
var tf: TFldEdit;
  oCapt: string;
  act: TEdoAct;
begin
  AddStack('TEdoOrdLs.deFldChange',Self);
  with TFldEdit(Sender) do if NameRecFld='ACT' then begin
    act:=VarValue; tf:=de.FldEdit[fEDOEXE]; oCapt:=tf.SayCaption;
    tf.SayCaption:='Программа'+IfThen(act=edoaLoad,UnDelim+'для проверки');
    tf.SetReadOnly(not(act in [edoaPodp,edoaLoad]),IfThen(lEdit,[ogReadOnly],[ogReadOnlyNoVsbl]));
    if tf.SayCaption<>oCapt then de.MainRebuild;
  end;
  DelStack;
end;

procedure TEdoOrdLs.OrdNewRec;
begin
  AddStack('TEdoOrdLs.OrdNewRec',Self);
  if not lcopy then begin
    Sender[fEDOIN]:=FUn; Sender[fEDOVD]:=gKey; Sender[fEdoORG]:=FOrg; Sender[fEdoNC]:=FNC;
    if FUn>0 then Sender.KodNextSelf(fEDOORD,ArrayAsList([fEDOIN+'='+Vtos(FUn),fEDOVD+'='+QQs(gKey),
      fEdoORG+'='+QQs(FOrg),fEdoNC+'='+Vtos(FNC)],sAND));
  end;
  DelStack;
end;

function TEdoOrdLs.FUn;
begin
  AddStack('TEdoOrdLs.FUn',Self);
  result:=Int0(BrQuery1.Arg['un']);
  DelStack;
end;

function TEdoOrdLs.FKv;
begin
  AddStack('TEdoOrdLs.FKv',Self);
  result:=BrQuery1.GlobKey;
  DelStack;
end;

procedure TEdoOrdLs.WMFormLimit;
begin
  AddStack('TEdoOrdLs.WMFormLimit');
  inherited;
  FreeLimit(EdoOrdLs);
  DelStack;
end;

procedure TEdoOrdLs.Browl1ShowHint(var HintStr: String;
  var CanShow: Boolean; var HintInfo: THintInfo);
begin
  AddStack('TEdoOrdLs.Browl1ShowHint',Self);
  inherited;
	HintInfo.ReshowTimeout:=100;
  DelStack;
end;

procedure TEdoOrdLs.Browl1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var f: TField;
  i,j: longint;
  hnt: string;
  r: TRect;
begin
  AddStack('TEdoOrdLs.Browl1MouseMove',Self);
  inherited;
  with Browl1 do begin
    hnt:='';
    if GetXField(X,i,f) then if f=BrQuery1NC then
      for j:=1 to Browl1.RowCount-1 do begin
        r:=SelRect(i,j);
        if InRange(Y,r.Top,r.Bottom) then begin
          i:=Browl1.DataLink.ActiveRecord;
          try
            Browl1.DataLink.ActiveRecord:=j-1; hnt:=TrimRight(BrQuery1NMC.AsString);
          finally
            Browl1.DataLink.ActiveRecord:=i;
          end;
          break;
        end;
      end;
    Hint:=hnt; ShowHint := hnt<>'';
  end;
  DelStack;
end;

procedure LogTrnsValProc(var Prm: TLogTrnsValPrm);
begin
  AddStack('FEdoOrLs.LogTrnsValProc');
  if LogEqual(Prm,tEDOORD,'ACT')
    then LogEnumVal(Prm,aAct)
  ;DelStack;
end;

initialization
  AddStack('FEdoOrLs.initialization');
  LogTrnsValProcAdd(LogTrnsValProc);
  DelStack;
end.
