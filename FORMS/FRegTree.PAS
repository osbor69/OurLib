unit FRegTree;

interface

uses
  Windows, Messages, Classes, Controls, ExtCtrls, ComCtrls, Menus,
  MyTypes, FRMEMPTY, Keylb, Fpanel, CCodeGet, FFldEdit, TreePrim, KeyMenu;

type
  TRegGet = class(TCustomCodeGet)
  protected
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
		procedure DoEnter(tf: TFldEdit); override;
    procedure StdListDown(tf: TFldEdit; const RectList: TRect; PozList: TPozList); override;
  end;

  TRegTree = class(TFormEmp)
    RbStatus1: TRbStatus;
    pnTree: TRbPanel;
    Tree: TTreePrim;
    KeyMenu1: TKeyMenu;
    procedure FormCreate(Sender: TObject);
    procedure TreeExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure TreeChange(Sender: TObject; Node: TTreeNode);
    procedure KeyLb1ProcKey(key: Integer; tw: TWinControl);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    ls: TStringList;
    procedure NodeAdd(Node: TTreeNode; const TextNode: string);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses SysUtils,Forms,
  My_pr;

var RegTree: TRegTree;

function NodePath(Node: TTreeNode): string;
begin
  AddStack('FRegTree.NodePath');
  result:='';
  while Assigned(Node) do begin
    IncL(result,Node.Text+'\'); ParentSelf(Node);
  end;
  DecLen(result);
  DelStack;
end;

{ TRegGet }
procedure TRegGet.CreateObj;
begin
	AddStack('TRegGet.CreateObj',Self);
	inherited CreateObj(tf);
  eN.TrimLeft:=true;
  if not Assigned(bDyn) then sD.Hint:='Реестр';
  tf.ReCreateObj;
  DelStack;
end;

procedure TRegGet.ReCreateObj;
begin
	AddStack('TRegGet.ReCreateObj',Self);
	if AssignObj(tf) then begin
  	eC.Visible:=false; eN.Visible:=true;
    eN.ReadOnly := (ogReadOnly in tf.Options) or Assigned(bDyn);
    eN.AutoSelect := ogAutoSelect in tf.Options;
	  inherited ReCreateObj(tf);
  end;
  DelStack;
end;

function TRegGet.GetValue;
begin
	AddStack('TRegGet.GetValue',Self);
	AssignObj(tf); result:=IfThenGetText(eN);
  DelStack;
end;

procedure TRegGet.SetValue;
begin
	AddStack('TRegGet.SetValue',Self);
	if AssignObj(tf) then begin
    eN.Text:=TrimRight(v); eN.SelStart:=0; eN.SelAll;
  end;
  DelStack;
end;

procedure TRegGet.DoEnter;
begin
	AddStack('TRegGet.DoEnter',Self);
	inherited DoEnter(tf);
  GetParentForm(tf).ActiveControl:=eN;
  DelStack;
end;

procedure TRegGet.StdListDown;
var a: TArrStr;
  i,l: longint;
  tn,tnParent: TTreeNode;
  lRootDef: boolean;
  key: HKEY;
  s: string;
begin
  AddStack('TRegGet.StdListDown',Self);
  s:=TrimRight(tf.Value); l:=LsArrDynamic(s,a,'\');
  if l>0 then s:=a[0];
  CreateForm(TRegTree,RegTree);
  with RegTree,Tree do begin
    IsFirst(tnParent); key:=GetRootKey(s,lRootDef); i:=low(aRegRootKey);
    while Assigned(tnParent) do begin
      if aRegRootKey[i].Key=key then break;
      GetNextSiblingSelf(tnParent); Inc(i);
    end;
    for i:=1-Ord(lRootDef) to l-1 do begin
      TrimUpperSelf(a[i]);
      tnParent.Expand(false); tn:=tnParent.GetFirstChild;
      while Assigned(tn) do
        if TrimUpper(tn.Text)=a[i] then break else GetNextSiblingSelf(tn);
      if not Assigned(tn) then break;
      tnParent:=tn;
    end;
    RestFromIni; SelectNoNil(tnParent); PlaceToControl(tf);
    if ShowModal=mrOk then tf.Value:=RbStatus1.Caption;
    SaveToIni;
  end;
  FormFree(RegTree);
  DelStack;
end;

{ TRegTree }
procedure TRegTree.FormCreate(Sender: TObject);
var i: byte;
begin
  AddStack('TRegTree.FormCreate',Self);
  ls:=TStringList.Create;
  inherited;
  for i:=low(aRegRootKey) to high(aRegRootKey) do with aRegRootKey[i] do NodeAdd(nil,Name);
  DelStack;
end;

procedure TRegTree.FormDestroy(Sender: TObject);
begin
  AddStack('TRegTree.FormDestroy',Self);
  inherited;
  ls.Free;
  DelStack;
end;

procedure TRegTree.WMFormLimit;
begin
	AddStack('TRegTree.WMFormLimit',Self);
  inherited;
  FreeLimit(RegTree);
  DelStack;
end;

procedure TRegTree.TreeExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
var a: TArrStr;
  fl: boolean;
  i: longint;
begin
  AddStack('TRegTree.TreeExpanding',Self);
  if AllowExpansion then
    if NodeNotFill(Node) then begin
      Tree.BeginUpdate; i:=LsArrDynamic(NodePath(Node),a,'\');
      with GRegistry do begin
        RootKey:=GetRootKey(a[0],fl);
        if OpenKeyReadOnly(ArrayAsList(a,'\',i,false,1)) then begin
          GetKeyNames(ls);
          for i:=0 to ls.Count-1 do NodeAdd(Node,ls[i]);
        end;
        CloseKey;
      end;
      Tree.DeletePrim(Node.getFirstChild); Tree.EndUpdate;
    end;
  DelStack;
end;

procedure TRegTree.NodeAdd;
begin
  AddStack('TRegTree.NodeAdd',Self);
  Tree.AddPrim(Tree.AddPrim(Node,TextNode));
  DelStack;
end;

procedure TRegTree.TreeChange(Sender: TObject; Node: TTreeNode);
begin
  AddStack('TRegTree.TreeChange',Self);
  RbStatus1.Caption:=NodePath(Tree.Selected);
  DelStack;
end;

procedure TRegTree.KeyLb1ProcKey(key: Integer; tw: TWinControl);
begin
  AddStack('TRegTree.KeyLb1ProcKey',Self);
  if Key=K_Enter then Key:=K_F10;
  inherited;
  DelStack;
end;

end.
