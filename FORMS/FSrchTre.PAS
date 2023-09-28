unit FSrchTre;

interface

uses
  Messages, Classes, Controls, ExtCtrls, ComCtrls,
  MyTypes, FRMEMPTY, Keylb, Fpanel, TreePrim;

type
  TSearchTree = class(TFormEmp)
    Tree: TTreePrim;
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
  private
    { Private declarations }
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
		function Execute(tnSel: TTreeNode; var tnIndex: longint): boolean;
		class procedure Init(const sf: string);
  end;

var
  SearchTree: TSearchTree;

implementation

{$R *.DFM}

uses My_pr;

class procedure TSearchTree.Init;
begin
  AddStack('TSearchTree.Init');
  CreateForm(TSearchTree,SearchTree); SearchTree.Caption:='Строка "'+sf+'" найдена:';
  DelStack;
end;

function TSearchTree.Execute;
var tn: TTreeNode;
begin
  AddStack('TSearchTree.Execute',Self);
  with Tree do begin
    result:=false; BeginUpdate; FullExpand; EndUpdate;
    if not RestFromIni('',[tpiSelected]) then Selected:=tnSel;
    if ShowModal=mrOk then begin
    	tnIndex:=0; IsFirst(tn);
      while Assigned(tn) do begin
      	if not tn.HasChildren then
          if tn.Selected then begin
          	result:=true; break;
          end
        	else Inc(tnIndex);
        GetNextSelf(tn);
      end;
    end;
    SaveToIni('',[tpiSelected]);
  end;
  FormFree(SearchTree);
  DelStack;
end;

procedure TSearchTree.KeyLb1ProcKey(key: longint; tw: TWinControl);
begin
	AddStack('TSearchTree.KeyLb1ProcKey',Self);
	case Key of
    K_F10: Key:=K_Esc;
    K_Enter: Key:=K_F10;
  end;
  inherited;
  DelStack;
end;

procedure TSearchTree.WMFormLimit;
begin
	AddStack('TSearchTree.WMFormLimit',Self);
  inherited;
  FreeLimit(SearchTree);
  DelStack;
end;

end.
