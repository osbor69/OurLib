unit FCngNum;

interface

{$I LIBTEST}
uses
  Classes, Controls, Menus, ExtCtrls,
  MyTypes, RecVal, RecDB, Browl, FRMCODE, KeyMenu, Keylb, FFldedit, PnlEdit, Fpanel;

type
  TCngNum = class(TFormCode)
    function PanelEdit1Valid(Sender: TObject): Boolean;
    procedure PanelEdit1CngKey(Sender: TObject; var tb: TKeyBut);
  private
    { Private declarations }
		oldnum: string;
    oldv: variant;
    prc: TCngNumValid;
    rdb: TRecDB;
    atbl: TArrStr;
    Opt: TCngNumOptions;
  public
    { Public declarations }
    class function GetNewNum(const Say: string; Browl: TBrowl; rc: TCustomRec;
    	const nmFld: string; const aTable: array of string; const als: array of TStringList;
      const GlobKey: string = ''; Proc: TCngNumValid = nil; tpEdit: TCodeTypeEdit = cteCod;
      ProcCheck: TProcValid = nil; g: TCustomGet = nil; Options: TCngNumOptions = []): boolean;
  end;

var
  CngNum: TCngNum;

implementation

{$R *.DFM}

uses StrUtils,
  My_pr,FrmPswd;

class function TCngNum.GetNewNum;
var i: longint;
begin
	AddStack('TCngNum.GetNewNum');
  result:=LockEdConf(not(cngNoLockEdConf in Options));
  if result then
    try
      CreateForm(TCngNum,CngNum);
      with CngNum do begin
        Opt:=Options;
        if IsClass(rc,TRecDB,pointer(rdb)) and Assigned(Browl) then rdb.GotoRec(Browl.Qry);
        if cngSayCapt in Opt then begin
          Caption:=Say; ECode.SayCaption:='';
        end
        else begin
          Caption:=IfThen(cngFusion in Opt,'Слияние','Сменить номер');
          ECode.SayCaption:=IfThen(Say='',IfThen(cngFusion in Opt,'Итоговый(остающийся)','Новый')+' номер:',Say);
        end;
        ECode.NameRec:=rc.NameRec; ECode.NameRecFld:=nmFld;
        PanelEdit1.FldReadAll;
        GK:=GlobKey; oldnum:=ECode.Value; oldv:=ECode.VarValue; prc:=Proc;
        TypeEdit:=tpEdit; CopyFrom(atbl,aTable);
        CodCheck:=IfThenValid((cngFusion in Opt) and not Assigned(ProcCheck),TNoneProc.ValidTrue,ProcCheck);
        ECode.AssignGetDef(g);
        PanelEdit1.Sort; 
        SetLogVid(logvCngNum);
        result := (ShowModal=mrOk) and (ECode.Value<>oldnum);
        SetLogVid;
        CodCheck:=nil;
        if result then begin
          if Assigned(rdb) then begin
            if Assigned(Browl) then Browl.BrUpdate(Browl.Row,rdb.Recno);
          end
          else if Assigned(prc) then begin
            if cngNoLockMono in Opt then result:=TrnsStart(atbl) else result:=TrnsStart(atbl,1,FLockMono);
            if result then try
              prc(oldnum,Opt,result);
              if not result then begin
                ECode.Value:=oldnum; ECode.Write;
              end;
              if cngNoLockMono in Opt then TrnsEnd(IfThen(result,trnsCommit)) else TrnsEndMono(not result);
            except
              if cngNoLockMono in Opt then TrnsEnd else TrnsEndMono;
              raise
            end;
          end;
          for i:=low(als) to high(als) do lsCodCng(als[i],oldnum,ECode.Value);
        end;
        FormFree(CngNum);
      end;
    finally
      if not(cngNoLockEdConf in Options) then UnLockEdConf;
    end;
  DelStack;
end;

function TCngNum.PanelEdit1Valid(Sender: TObject): Boolean;
var prim: string;
label lend;
begin
	AddStack('TCngNum.PanelEdit1Valid',Self);
  inherited;
  result := ECode.Value=oldnum;
  if result then goto lend;
  result := not(Assigned(rdb) and Assigned(prc));
  if result then goto lend;
  if cngNoLockMono in Opt then result:=TrnsStart(atbl) else result:=TrnsStart(atbl,1,FLockMono);
  if not result then goto lend;
  try
    if cngFusion in Opt then prim:=rdb.LogPrimMod else rdb.UpdateRec(true);
    prc(oldnum,Opt,result);
    if result then begin
      if cngFusion in Opt then begin
        rdb.DelRec; rdb.LogWrite(prim); rdb.Seek(rdb.TblFldName(ECode.NameRecFld)+'='+QQs(ECode.Value));
      end;
    end
    else if Assigned(ECode.PNameRecFld) then begin
      ECode.PNameRecFld.Value:=oldv; ECode.PNameRecFld.Modified:=false;
    end;
    if cngNoLockMono in Opt then TrnsEnd(IfThen(result,trnsCommit)) else TrnsEndMono(not result);
  except
    if cngNoLockMono in Opt then TrnsEnd else TrnsEndMono;
    raise
  end;
lend:
	DelStack;
end;

procedure TCngNum.PanelEdit1CngKey(Sender: TObject; var tb: TKeyBut);
begin
	AddStack('TCngNum.PanelEdit1CngKey',Self);
  inherited;
	with tb do case Key of
    K_F10,K_Alt_Z: Caption:='';
    K_Enter: begin
    	Caption:='Сменить'; Part:=kmFile;
    end;
  end;
  DelStack;
end;

end.
