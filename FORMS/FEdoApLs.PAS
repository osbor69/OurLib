unit FEdoApLs;

interface

uses
  Messages, Classes, Graphics, Controls, Forms, Menus, DB, Grids, DBGrids, ExtCtrls, Dialogs,
  MyTypes, FrmBrIB, KeyMenu, Browl, Keylb, Fpanel, DefEdit;

type
  TEdoApLs = class(TFormBrIB)
    de: TDefEdit;
    OpenDialog1: TOpenDialog;
    procedure Browl1BrowlKey(key: Integer; tw: TWinControl);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    BrQuery1RECNO: TIntegerField;
    LastPath: string;
    procedure WMFormLimit(var msg: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    class procedure Execute(un: longint; const Capt: string);
  end;

implementation

{$R *.dfm}

uses Windows,SysUtils,ShellApi,
  My_pr,FEdoDM;

var EdoApLs: TEdoApLs;

class procedure TEdoApLs.Execute;
begin
  AddStack('TEdoApLs.Execute');
  if CreateForm(TEdoApLs,EdoApLs) then with EdoApLs,BrQuery1 do begin
    Arg['un']:=0;
    BrQuery1RECNO:=Init(DBMain,[fNAME],[],tEDOAPP,[fNAME,fRECNO],fEDOIN+'={un}');
    Browl1.FieldLong:=CreateStringField(fNAME);
    with InitFIni[fiSave] do begin
      OpenDialog1.FileName:=ReadString('EdoApLs','File');
      LastPath:=ReadString('EdoApLs','Path');
    end;
  end;
  with EdoApLs do begin
    Caption:=Capt; BrQuery1.Arg['un']:=un; ShowModal;
  end;
  FormFree(EdoApLs);
  DelStack;
end;

procedure TEdoApLs.FormDestroy(Sender: TObject);
begin
  AddStack('TEdoApLs.FormDestroy',Self);
  with InitFIni[fiSave] do begin
    WriteString('EdoApLs','File',OpenDialog1.FileName);
    WriteString('EdoApLs','Path',LastPath);
  end;
  inherited;
  DelStack;
end;

procedure TEdoApLs.Browl1BrowlKey(key: Integer; tw: TWinControl);
var s: string;
  function fWrite(const path: string): boolean;
  begin
    AddStack('TEdoApLs.Browl1BrowlKey.fWrite',Self);
    with EdoDM do begin
      result:=false; App.GotoRec(BrQuery1RECNO); s:=path;
      if ForceDirMsg(s) then begin
        IncD(s,TrimRight(App['FNAME']));
        if SetStrFile(s,App[sMemo+'FILE']) then result:=true else MsgDlg(['Ошибка записи в файл:',s])
      end;
    end;
    DelStack;
  end;
begin
  AddStack('TEdoApLs.Browl1BrowlKey',Self);
  if BrQuery1.CanEdit(Key) then with EdoDM do case Key of
    K_F5: Browl1.EditRec('Редактирование',App,de);
    K_F7: begin
      SetLogVid(logvAppRec);
      if FileExec('EdoAppFile',OpenDialog1) then begin
        AppAdd(BrQuery1.Arg['un'],'',OpenDialog1.FileName);
        Browl1.BrUpdate(NegDef,App.RecNo);
      end;
      SetLogVid(logvNone);
    end;
    K_F8: Browl1.DelAsk(App);
    K_Enter: if fWrite(EdoTmpPath) then ShellExecute(0,nil,PChar(s),nil,PChar(ExtractFilePath(s)),SW_SHOW);
    K_Ctrl_Enter: if DirExec(nil,TrimRight(Browl1.FieldLong.AsString)+': выгрузить в папку','',
    'EdoAppPath',LastPath) then
      if fWrite(CorrDir(LastPath)) then ShellExecute(0,nil,'explorer.exe',PChar('/select,'+s),nil,SW_SHOW);
  end;
  DelStack;
end;

procedure TEdoApLs.WMFormLimit;
begin
  AddStack('TEdoApLs.WMFormLimit');
  inherited;
  FreeLimit(EdoApLs);
  DelStack;
end;

end.
