unit FTabuLs;

interface

{$I LIBTEST}
uses
  Messages, Classes, Controls, ExtCtrls, ComCtrls, Menus,
  MyTypes, FRMEMPTY, Keylb, Fpanel, TreePrim, KeyMenu, mulqry, RbMenu;

type
  TTabuLsOper = (tabuCreate,tabuShow,tabuProcKey,tabuAllowed);

  TTabuLs = class(TFormEmp)
    Tree: TTreePrim;
    KeyMenu1: TKeyMenu;
    dmUsers: TDefMenu;
    procedure TreeChecked(Sender: TObject; Node: TTreeNode;
      Value: Boolean);
    function TreeCheckAll(Sender: TObject; Value: Boolean): Boolean;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure KeyLb1ProcKey(key: Integer; tw: TWinControl);
    procedure TreeChecking(Sender: TObject; Node: TTreeNode;
      Value: Boolean; var Allowed: Boolean; var StateIndex: Integer);
  private
    { Private declarations }
    nmUser: string;
    Modified: boolean;
    ls: TstringList;
    Qry: Tmulquery;
    aChk: TArrStr;
    lChk: longint;
    av: TArrVar;
    procedure Load;
    class function CheckList(const aName: array of string): TStringList; overload;
    procedure ProcKey(key: Integer; tw: TWinControl);
    procedure Proc(oper: TTabuLsOper; const ap: array of variant);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    procedure GetNodeText(var zn,log: string; Node: TTreeNode; lFull: boolean = true);
    class function Checked(const aName: array of string): boolean;
    class function CheckList(const Name: string): TStringList; overload;
    class function CheckList(const Name: string; var ls: TStringList): boolean; overload;
    class function CheckList(const aName: array of string; var ls: TStringList): boolean; overload;
    class function IsList(const Name: string): boolean;
    class procedure CngName(const aOldName,aNewName: array of string);
    class procedure DelName(const aName: array of string);
  end;

var
  TabuLs: TTabuLs;
  TabuNil: string = '';
  ProcTabuNodeText: procedure(Tree: TTreePrim; Node: TTreeNode; var Text: string);
  TabuLsProc: procedure(oper: TTabuLsOper; const ap: array of variant; var av: TArrVar);

implementation

{$R *.DFM}

uses SysUtils,Db,Graphics,Math,
  My_pr,FrmPswd;

const cDlm = #31;
  KeyUsersBeg = K_A;

function ArrToStr(const aName: array of string): string;
begin
  AddStack('FTabuLs.ArrToStr');
  result:=ArrayAsList(aName,cDlm);
  DelStack;
end;

function lsSeek(const aName: array of string; ls: TStringList;
  var ls1: TStringList): boolean; overload;
var i,j: longint;
  p: pointer;
begin
  AddStack('FTabuLs.lsSeek');
  result:=false; ls1:=nil;
  if Assigned(ls) then for i:=low(aName) to high(aName) do if aName[i]<>'' then begin
    if ls.Find(aName[i],j) then
      if i=high(aName) then begin
        ls1:=PointerObj(ls,j); result:=true;
      end
      else if PointerObj(ls,j,p) then begin
        ls:=p; continue;
      end;
    break;
  end;
  DelStack;
end;

function lsSeek(const aName: array of string; ls: TStringList): boolean; overload;
var ls1: TStringList;
begin
  result:=lsSeek(aName,ls,ls1); AndD(result,not Assigned(ls1));
end;

procedure TabuClearList(ls: TStringList; lFree: boolean = true);
var i: longint;
begin
  AddStack('FTabuLs.TabuClearList');
  if Assigned(ls) then begin
    for i:=0 to ls.Count-1 do TabuClearList(PointerObj(ls,i));
    if lFree then ls.Free else ls.Clear;
  end;
  DelStack;
end;

procedure TabuLoadList(var ls: TStringList; const nmus: string; Qry: TObject);
var ost,l,i,n: longint;
  ls1: TStringList;
  a: array[1..100] of string;
  q: TMulQuery;
begin
  ost:=AddStack('FTabuLs.TabuLoadList');
  try
    q:=pointer(Qry); q.PartSelect(tTABU,fTabuZN,fNAME+'='+QQs(nmus),fTabuZN,fTabuZN);
    if Assigned(ls) then TabuClearList(ls,false) else ls:=SortStrListCreate;
    while not q.Eof do begin
      l:=ListAsArray(TrimRight(q.Fields[0].AsString),a,cDlm); ls1:=ls;
      for i:=1 to l do begin
      	IgnoreSlFindAdd(ls1,a[i],n);
        if i<l then begin
          if not Assigned(ls1.Objects[n]) then ls1.Objects[n]:=SortStrListCreate;
          PointerObjSelf(ls1,n);
        end;
      end;
      q.Next;
    end;
  except
    on EDatabaseError do SetStack(ost);
  end;
  DelStack;
end;

procedure biTabu(var stack: array of variant; n1: longint; var lStd: boolean);
var n2: longint;
  aName: TArrStr;
  ls: TStringList;
begin
  AddStack('FTabuLs.biTabu');
  CopyFromVar(aName,stack[n1]); n2:=n1+1;
  if IsNil(stack[n2]) then begin
    TTabuLs.CheckList(aName,ls); stack[n1]:=Ls2Var(ls);
  end
  else begin
    AddFrom(aName,string(stack[n2])); stack[n1]:=TTabuLs.Checked(aName);
  end;
  DelStack;
end;

{ TTabuLs }
procedure TTabuLs.FormCreate(Sender: TObject);
var bm: TBitMap;
begin
  AddStack('TTabuLs.FormCreate',Self);
  inherited;
  Qry:=Tmulquery.CreateConnection(Self);
  with Tree.StateImages do begin
    InitBM.FindBM(bmNoAllowed,bm); AddMasked(bm,bm.TransparentColor);
    InitBM.FindBM(bmCheck_Emp,bm); AddMasked(bm,bm.TransparentColor);
  end;
  Proc(tabuCreate,[longint(KeyLb1)]);
  DelStack;
end;

procedure TTabuLs.FormDestroy(Sender: TObject);
begin
  AddStack('TTabuLs.FormDestroy',Self);
  ls.Free;
  inherited;
  DelStack;
end;

function TabuExec(const nmus: string): boolean;
var i,k: longint;
begin
  AddStack('FTabuLs.TabuExec');
  CreateForm(TTabuLs,TabuLs);
  with TabuLs,Tree do begin
    Proc(tabuShow,[nmus]); 
    BeginUpdate;
    try
      ClearPrim; ProgPswd.UserTabu(Tree,nmus);
      Caption:='ƒополнительные права пользовател€ "'+Trim(nmus)+'"'; nmUser:=nmus; Load;
    finally
      EndUpdate;
    end;
    with ProgPswd.GetQuery do begin
      PartSelect(tUSERS,fNAME,fNAME+'<>'+QQs(nmus),fNAME);
      if IsRecords then with dmUsers,Keys do begin
        BeginUpdate; Clear; i:=RecordCount; Capacity:=i; k:=KeyUsersBeg;
        for i:=1 to i do begin
          InsertKey(k,TrimRight(Fields[0].AsString)); Inc(k); Next;
        end;
        EndUpdate;
        KeyLb1.SetKey(K_Ctrl_F4,'—копировать','—копировать права с другого пользовател€',ProcKey,'copyuser',kmServic);
      end
      else KeyLb1.DelKey(K_All,'copyuser');
    end;
    ProgPswd.FreeQuery;
    Modified:=false; ShowModal; SaveToIni; result:=Modified; FormFree(TabuLs);
  end;
  DelStack;
end;

procedure TTabuLs.Load;
var i: longint;
  tn,tn1: TTreeNode;
  a: TArrStr;
  log: string;
begin
  AddStack('TTabuLs.Load',Self);
  with Tree do begin
    BeginUpdate;
    try
      TabuLoadList(ls,nmUser,Qry); IsFirst(tn);
      while Assigned(tn) do begin
        if not tn.HasChildren then begin
          i:=tn.Level+1; SetLength(a,i); tn1:=tn;
          repeat
            Dec(i); GetNodeText(a[i],log,tn1,false); ParentSelf(tn1);
          until i=0;
          if lsSeek(a,ls) then begin
            Checked[tn]:=true; tn1:=tn;
            while Assigned(tn1.Parent) do begin
              ParentSelf(tn1); tn1.Expand(false);
            end;
          end
          else if Self.Visible then Checked[tn]:=false;
        end;
        GetNextSelf(tn);
      end;
      RestFromIni;
    finally
      EndUpdate;
    end;
  end;
  DelStack;
end;

procedure TTabuLs.TreeChecking(Sender: TObject; Node: TTreeNode;
  Value: Boolean; var Allowed: Boolean; var StateIndex: Integer);
var zn,log: string;
  fl: boolean;
begin
  AddStack('TTabuLs.TreeChecking',Self);
  if Value then begin
    fl:=true; GetNodeText(zn,log,Node); lChk:=LsArrDynamic(zn,aChk,cDlm);
    Proc(tabuAllowed,[longint(@fl),longint(@aChk),lChk]); StateIndex:=IfThen(fl,4,3);
  end;
  DelStack;
end;

procedure TTabuLs.TreeChecked(Sender: TObject; Node: TTreeNode;
  Value: Boolean);
var zn,log: string;
begin
  AddStack('TTabuLs.TreeChecked',Self);
  if Visible and Tree.CanUpdate then begin
    GetNodeText(zn,log,Node);
    if Value then begin
      SetLogVid(logvAppRec); Qry.InsertTable('',[fNAME,fTabuZN],[QQs(nmUser),QQs(zn)]);
    end
    else begin
      SetLogVid(logvDelRec); Qry.DeleteTable('',fNAME+'='+QQs(nmUser)+sAND+fTabuZN+'='+QQs(zn));
    end;
    LogWrite(tTABU,'пользователь:"'+Trim(nmUser)+'"'+LogDlm+log);
    SetLogVid; Modified:=true;
  end;
  DelStack;
end;

function TTabuLs.TreeCheckAll(Sender: TObject; Value: Boolean): Boolean;
var tn: TTreeNode;
begin
  AddStack('TTabuLs.TreeCheckAll',Self);
  result:=false; tn:=Tree.Selected;
  if not tn.HasChildren then ParentSelf(tn);
  GetFirstChildSelf(tn);
  while Assigned(tn) do begin
    if not tn.HasChildren then Tree.Checked[tn]:=Value;
    GetNextSiblingSelf(tn);
  end;
  DelStack;
end;

class function TTabuLs.Checked;
begin
  AddStack('TTabuLs.Checked');
  result:=lsSeek(aName,LsTabu);
  DelStack;
end;

class function TTabuLs.CheckList(const aName: array of string): TStringList;
begin
  AddStack('TTabuLs.CheckList');
  lsSeek(aName,LsTabu,result);
  DelStack;
end;

class function TTabuLs.CheckList(const aName: array of string; var ls: TStringList): boolean;
begin
  ls:=CheckList(aName); result:=Assigned(ls);
end;

class function TTabuLs.CheckList(const Name: string): TStringList;
begin
  result:=CheckList([Name]);
end;

class function TTabuLs.CheckList(const Name: string; var ls: TStringList): boolean;
begin
  result:=CheckList([Name],ls);
end;

class function TTabuLs.IsList;
var ls: TStringList;
begin
  result:=CheckList(Name,ls);
end;

class procedure TTabuLs.CngName;
begin
  AddStack('TTabuLs.CngName');
  with ProgPswd,GetQuery do begin
    UpdateTable(tTABU,[fTabuZN],[QQs(ArrToStr(aNewName))],fTabuZN+'='+QQs(ArrToStr(aOldName)));
    TabuLoadList(LsTabu,UserName,CurQuery); SendUpd(updTabu); FreeQuery;
  end;
  DelStack;
end;

class procedure TTabuLs.DelName;
begin
  AddStack('TTabuLs.DelName');
  with ProgPswd,GetQuery do begin
    DeleteTable(tTABU,fTabuZN+'='+QQs(ArrToStr(aName)));
    TabuLoadList(LsTabu,UserName,CurQuery); SendUpd(updTabu); FreeQuery;
  end;
  DelStack;
end;

procedure TTabuLs.GetNodeText;
var s: string;
begin
  AddStack('TTabuLs.GetNodeText',Self);
  zn:=''; log:='';
  repeat
    s:=Node.Text; IncL(log,s+',');
    if Tree.NodeInf(Node).Dop=@TabuNil then s:=''
    else if Assigned(ProcTabuNodeText) then ProcTabuNodeText(Tree,Node,s);
    if s<>'' then IncL(zn,s+cDlm);
    ParentSelf(Node);
  until not(Assigned(Node) and lFull);
  DecLen(zn); DecLen(log);
  DelStack;
end;

procedure TTabuLs.WMFormLimit;
begin
	AddStack('TTabuLs.WMFormLimit',Self);
  inherited;
  FreeLimit(TabuLs);
  DelStack;
end;

procedure TTabuLs.KeyLb1ProcKey(key: Integer; tw: TWinControl);
begin
  AddStack('TTabuLs.KeyLb1ProcKey',Self);
  inherited;
  Proc(tabuProcKey,[key,longint(tw)]);
  DelStack;
end;

procedure TTabuLs.ProcKey;
var usFrom: string;
  lsf: TMQFIeldList;
  ac: TArrVar;
  i,nnm: longint;
begin
  AddStack('TTabuLs.ProcKey',Self);
  if key=K_Ctrl_F4 then begin
    key:=0;
    if dmUsers.Execute(@key) then begin
      usFrom:=dmUsers.GetKeyInfo(dmUsers.SeekIndex(key)).Capt;
      if Ask(['¬нимание !','¬се существующие дополнительные права пользовател€ '+Trim(nmUser),
      'будут удалены и затем скопированы','из дополнительных прав пользовател€ '+usFrom+'.','','ѕродолжить ?'])
      then with ProgPswd.GetQuery do begin
        DeleteTable(tTABU,fNAME+'='+QQs(nmUser));
        lsf:=GetFieldList(tTABU); i:=lsf.Count; SetLength(ac,i); nnm:=NegDef; //Variable might not have been initialized
        for i:=0 to i-1 do
          if lsf[i]=fNAME then begin
            nnm:=i; ac[i]:=QQs(nmUser);
          end
          else ac[i]:=lsf[i];
        Arg[sSELECT]:=PartSelect('',ac,fNAME+'='+QQs(usFrom),'','',false);
        ac[nnm]:=fNAME; Arg[sC_LIST]:=GetList(ac);
        ExecPart(sIS_TABLE); ProgPswd.FreeQuery;
        Tree.SaveToIni; Load; Modified:=true;
      end;
    end;
  end;
  DelStack;
end;

procedure TTabuLs.Proc;
begin
  AddStack('TTabuLs.Proc',Self);
  if Assigned(TabuLsProc) then TabuLsProc(oper,ap,av);
  DelStack;
end;

initialization
  AddStack('FTabuLs.initialization');
  FrmPswd.TabuExec:=TabuExec; FrmPswd.TabuClearList:=TabuClearList; FrmPswd.TabuLoadList:=TabuLoadList;
  aBuiltInProc[MyTypes.biTabu].Proc:=biTabu;
  SetPrim(tTABU,'ƒополнительные права пользователей');
  DelStack;
end.
