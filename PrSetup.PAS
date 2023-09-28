unit PrSetup;

interface

uses Classes,
  DefEdit,MulQry;

type
  TProcSetup = class(TObject)
  public
    class function LoadProcFromServer(pe: TObject; de: TDefEdit; db: TComponent; q: TMulQuery;
      const nmf,dir: string): boolean;
    class procedure CorrStruct(db: TComponent);
  end;

implementation

uses SysUtils,
  MyTypes,My_pr,Askp,FStat,PnlEdit,FrmPswd;

type
  TNone = class
  private
		class procedure WaitCopyProg(Sender: TAsk);
  end;

{ TProcSetup }
procedure StCopyProg(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var path: TFileName;
  q: TMulQuery;
begin
	AddStack('PrSetup.StCopyProg');
  path:=CorrDir(Params[0]); q:=PointerVar(Params[1]);
  q.Arg[sTABLE]:=tFILES; q.SetPart(sSELECT_ALL); TFormPswd.LoadFromServer(Sender,q,path,[]);
	CopyBufFile(path+NewExeName,path+ExeMenu); DelFileAtr(path+NewExeName);
  DelStack;
end;

class function TProcSetup.LoadProcFromServer;
var inf,nm: string;
begin
  AddStack('TProcSetup.LoadProcFromServer');
  nm:=Trim(DlmCopy(de.Param[nmf,deMask],1,1,UnDelim));
  result:=mess_wait(['Подключение к базе данных "'+nm+'"'],
    TNone.WaitCopyProg,[LongInt(pe),LongInt(de),LongInt(db),nmf,LongInt(@inf),'"'+nm+'"']);
  if result then begin
    result:=Ask([inf+CRLF+CRLF+'Скопировать программу в папку'+CRLF+TrimRight(dir)],true,nm);
    if result then begin
      q.Connection:=db;
      result:=not ShowStat('Копирование программы',StCopyProg,[dir,LongInt(q)]);
    end;
  end;
  SetConnected(db,false);
  DelStack;
end;

class procedure TProcSetup.CorrStruct;
var q: TMulQuery;
  lSetDbs: boolean;
begin
  AddStack('TProcSetup.CorrStruct');
  q:=TMulQuery.CreateConnection(nil,db);
  try
    q.DBDeleteIndex; 
    for lSetDbs:=false to true do begin
      ProgPswd.CopyDBDBF(nil,[dbdbfNoCanEsc]+IfThen(lSetDbs,dbdbfSetDbs)); ModifyTable(db,lSetDbs,'');
    end;
    q.UpdateTable(tGLOBSET,['WASCOPY'],[true]);
  finally
    q.Free;
  end;
  DelStack;
end;

{ TNone }
class procedure TNone.WaitCopyProg;
  function brk(usl: boolean): boolean;
  begin
    AddStack('TNone.WaitCopyProg.brk');
    if not usl then Sender.Abort;
    result:=Sender.Aborted;
    DelStack;
  end;
var v: variant;
  de: TDefEdit;
  db: TComponent;
  nmf,nm: string;
  inf: PString;
label lend;
begin
  AddStack('TNone.WaitCopyProg');
  de:=PointerVar(Sender.Params[1]); db:=PointerVar(Sender.Params[2]); nmf:=Sender.Params[3];
  if brk(TDBPrmGet.Connect(db,de.FldEdit[nmf])) then goto lend;
  inf:=PointerVar(Sender.Params[4]); inf^:=TDBPrmGet.GetInfo(db);
  if brk(inf^<>'') then begin
    meserr('Нельзя копировать программу из пустой базы данных.');
    TPanelEdit(LongInt(Sender.Params[0])).FldFocus:=de.FldEdit[nmf]; goto lend;
  end;
  nm:=Sender.Params[5];
  if brk(DBFldValue(db,tGLOBSET,'EXEVERS',v)) then begin
    MsgDlg(['В базе данных '+nm+' отсутствует таблица','параметров доступа к данным ('+tGLOBSET+').']);
    goto lend;
  end;
  if brk(v>0) then MsgDlg('В базе данных '+nm+' отсутствует программа.');
lend:
  DelStack;
end;

end.
