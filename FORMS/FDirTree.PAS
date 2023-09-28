unit FDirTree;

interface

uses
  Messages, Classes, Controls, Dialogs, ExtCtrls, Menus,
  MyTypes, FRMNUL, Keylb, Fpanel, KeyMenu, TreeDir;

type
  TDirTree = class(TFormNul)
    pnTree: TTreeDir;
    KeyMenu1: TKeyMenu;
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
  private
    { Private declarations }
    FProc: TDirExecProc;
    procedure ProcExec(Oper: TDirExecOper);
    procedure pnTreeEnter(Sender: TObject);
    procedure pnTreeExit(Sender: TObject);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses Forms,ComCtrls,StrUtils,
  My_pr;

var DirTree: TDirTree;

function DirExec(Sender: TComponent; const Capt,Root,Ident: string;
  var Directory: string; OpenDialog: TOpenDialog = nil; Options: TTreeDirOptions = [];
  Proc: TDirExecProc = nil): Boolean;
var tn: TTreeNode;
begin
  AddStack('FDirTree.DirExec');
  CreateForm(TDirTree,DirTree);
  with DirTree do begin
  	Caption:=Capt; pnTree.RootDir:=Root; pnTree.Ident:=Ident; pnTree.Directory:=Directory;
    pnTree.OpenDialog:=OpenDialog; pnTree.Options:=Options; pnTree.Modified:=true; FProc:=Proc;
    pnTree.OnEnter:=pnTreeEnter; pnTree.OnExit:=pnTreeExit;
    ProcExec(dirBeforeShow);
    pnTree.DoExit; pnTree.DoEnter; PlaceToControl(Sender);
    tn:=pnTree.Tree.Selected; pnTree.Tree.Selected:=nil; pnTree.Tree.Selected:=tn;
    result := ShowModal=mrOk; ProcExec(dirAfterShow);
    if DirTree=Application.MainForm then result := LastKey in [K_Enter,K_Ctrl_Enter];
    if result then Directory:=pnTree.Directory;
    pnTree.DoExit;
    if Assigned(Sender) then RestIniForm;
  	FormFree(DirTree);
  end;
  DelStack;
end;

function FileExec(const Ident: string; OpenDialog: TOpenDialog;
  Sender: TComponent = nil; Options: TTreeDirOptions = []; const Root: string = '';
  const Capt: string = ''; Proc: TDirExecProc = nil): boolean;
var s: string;
begin
  AddStack('FDirTree.FileExec');
  s:=OpenDialog.FileName;
  result:=DirExec(Sender,IfThen(Capt='',IfThen(OpenDialog.Title='',
  	IfThen(OpenDialog is TSaveDialog,'Сохранить как','Открыть'),OpenDialog.Title),Capt),
    Root,Ident,s,OpenDialog,Options,Proc);
  if result then OpenDialog.FileName:=s;
  DelStack;
end;

procedure TDirTree.ProcExec;
begin
  AddStack('TDirTree.ProcExec',Self);
  if Assigned(FProc) then FProc(DirTree,Oper);
  DelStack;
end;

procedure TDirTree.pnTreeEnter;
begin
  AddStack('TDirTree.pnTreeEnter',Self);
  ProcExec(dirAfterEnter);
  DelStack;
end;

procedure TDirTree.pnTreeExit;
begin
  AddStack('TDirTree.pnTreeExit',Self);
  ProcExec(dirAfterExit);
  DelStack;
end;

procedure TDirTree.KeyLb1ProcKey(key: longint; tw: TWinControl);
begin
	AddStack('TDirTree.KeyLb1ProcKey',Self);
  case Key of
    K_F10,K_Esc: SetModalResult;
   	K_Enter,K_Ctrl_Enter: SetModalResult(mrOk);
  else inherited;
  end;
  DelStack;
end;

procedure TDirTree.WMFormLimit;
begin
	AddStack('TDirTree.WMFormLimit',Self);
  inherited;
  FreeLimit(DirTree);
  DelStack;
end;

initialization
  AddStack('FDirTree.initialization');
  MyTypes.DirExec:=DirExec; MyTypes.FileExec:=FileExec;
  DelStack;
end.
