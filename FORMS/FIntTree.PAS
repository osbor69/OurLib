unit FIntTree;

interface

{$I LIBTEST}
uses
  Windows, Messages, Classes, Controls, ExtCtrls, ComCtrls, Menus,
  MyTypes, My_pr, FRMEMPTY, Keylb, Fpanel, TreePrim, KeyMenu;

type
  TITRec = record
    name,prim: string;
    hlp: THelpContext;
    vt: TInterVarType;
    i: longint;
  end;
  TITArr = array of TITRec;

	TITStatProc = procedure(Sender: TObject; const r: TITRec; Prm: Pointer);
  TITNodeCheckProc = procedure(ls: TStringList; tn: TTreeNode; pIndex: PLongint);

  TIntTreeList = (itreNoSubItems,itreCanCheck,itreCanCheckNode,itreOrd,itreNoSel);
  TIntTreeOpt = set of TIntTreeList;

  TIntTree = class(TFormEmp)
    KeyMenu1: TKeyMenu;
    RbStatus1: TRbStatus;
    pnTree: TRbPanel;
    TreePrim1: TTreePrim;
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    procedure TreePrim1Change(Sender: TObject; Node: TTreeNode);
    procedure TreePrim1CustomDrawPrim(Sender: TObject; Node: TTreeNode;
      Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    function TreePrim1SeekNode(Sender: TObject; Node: TTreeNode): Boolean;
  private
    { Private declarations }
    SubItems: boolean;
    ar: ^TITArr;
    stProc: TITStatProc;
    stPrm: Pointer;
    FNodeCheckProc: TITNodeCheckProc;
    FSect: string;
    procedure SetKeyABC;
    procedure ProcKey(key: longint; tw: TWinControl);
    function NodeCheckDefault(ls: TStringList; tn: TTreeNode; pIndex: PLongint): boolean;
    procedure Fill(const curzn: string; ls: TStringList);
		procedure WMHelpFill(var msg: TWMHelpFill); message WM_HELPFILL;
    procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    HelpFile: THelpFile;
		class function Execute(const Capt,Sect,CurVal: string; const aar: TITArr; lar: longint; Opt: TIntTreeOpt = [];
      pCrd: PRect = nil; PrStat: TITStatProc = nil; Prm: Pointer = nil; NodeCheckProc: TITNodeCheckProc = nil): string;
  end;

var aIntTreeFind: boolean;
  ITSeekNodeProc: procedure(const curzn: string; const atnsel: TArrTreeNode; var ntnsel: longint);

function IntTree: TIntTree;
function IfThen(AValue: boolean; ATrue: TIntTreeList): TIntTreeOpt; overload;

implementation

{$R *.DFM}

uses SysUtils,Graphics,Math,StrUtils;

var lABC: boolean;
  af: array of TIntTree;
  nf: longint = -1;

function IntTree: TIntTree;
begin
  AddStack('FIntTree.IntTree');
  result:=af[nf];
  DelStack;
end;

function IfThen(AValue: boolean; ATrue: TIntTreeList): TIntTreeOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

{ TIntTree }
class function TIntTree.Execute;
const DlmChk = ',';
var ols,als,ls: TStringList;
  curzn: string;
  wp: TWindowPlacement;
  fl: boolean;
  tn: TTreeNode;
  i,j: longint;
begin
	AddStack('TIntTree.Execute');
  Inc(nf);
  if Length(af)=nf then SetLength(af,nf+1);
	CreateForm(TIntTree,af[nf]); curzn:=AnsiUpperCase(CurVal);
  ols:=StrListCreate((itreCanCheck in Opt) and (itreOrd in Opt));
  ls:=SortStrListCreate(itreCanCheck in Opt);
  try
    if Assigned(ls) then begin
      als:=IfThen(itreOrd in Opt,ols,ls);
      while curzn<>'' do als.Add(ExtractLeftPart(curzn,PosEnd(DlmChk,curzn),DlmChk));
      if Assigned(ols) then ls.AddStrings(ols);
    end;
    with af[nf] do begin
      if aIntTreeFind then SetExecKey([K_Shift_F6]);
      Caption:=Capt; SubItems:=not(itreNoSubItems in Opt);
      FNodeCheckProc:=NodeCheckProc;
      if not SubItems then lABC:=true;
      if itreCanCheck in Opt then lABC:=false;
      ar:=@aar; SetLength(ar^,lar);
      if Assigned(pCrd) then begin
        SaveIniForm; wp.length:=SizeOf(wp); GetWindowPlacement(Handle,@wp);
        wp.rcNormalPosition.Top:=pCrd.Top; wp.rcNormalPosition.Bottom:=pCrd.Bottom;
        wp.showCmd:=SW_HIDE; SetWindowPlacement(Handle,@wp);
      end;
      with TreePrim1 do begin
        fl:=RbStatus1.Visible; RbStatus1.Visible:=Assigned(PrStat); stProc:=PrStat; stPrm:=Prm;
        SetOption([tpCanCheck],itreCanCheck in Opt); SetOption([tpCanCheckNode],itreCanCheckNode in Opt);
        SetKeyABC; FSect:=Sect; Fill(curzn,ls); aIntTreeFind:=false; result:='';
        if RbStatus1.Visible<>fl then MainRebuild;
        if itreNoSel in Opt
        then KeyLb1.DelKey(K_All,'itresel')
        else KeyLb1.SetKey(K_Enter,'Вставить','Вставить в текст',KeyLb1ProcKey,'itresel',kmList);
        ShowModal; SaveToIni(FSect); Filtered:=false;
        if Assigned(pCrd) then RestIniForm;
        if Assigned(ls) then begin
        	ls.Clear; IsFirst(tn);
        	while Assigned(tn) do begin
          	if Checked[tn] then if NodeCheckDefault(ls,tn,nil) then ls.Add(tn.Text);
            GetNextSelf(tn);
          end;
          if Assigned(ols) then begin
            for i:=0 to ls.Count-1 do begin
              j:=ols.IndexOf(ls[i]);
              if j<0 then ols.AddObject(ls[i],ObjectTrue) else ols.Objects[j]:=ObjectTrue;
            end;
            j:=0;
            while j<ols.Count do if Assigned(ols.Objects[j]) then Inc(j) else ols.Delete(j);
            result:=StrTran(TrimRight(ols.Text),CRLF,DlmChk);
          end
          else result:=StrTran(TrimRight(ls.Text),CRLF,DlmChk);
        end
        else if ModalResult=mrOk then if IsSelected(tn) then result:=tn.Text;
      end;
    end;
  finally
    ols.Free; ls.Free; FormFree(af[nf]); Dec(nf);
  end;
  DelStack;
end;

function TIntTree.NodeCheckDefault;
begin
  AddStack('TIntTree.NodeCheckDefault',Self);
  result:=not Assigned(FNodeCheckProc);
  if not result then FNodeCheckProc(ls,tn,pIndex);
  DelStack;
end;

procedure TIntTree.Fill;
  procedure tnExpand(tn: TTreeNode);
  var Recurse: boolean;
  begin
    AddStack('TIntTree.Fill.tnExpand',Self);
    Recurse:=true;
    while Assigned(tn) do begin
      if not tn.Expanded then tn.Expand(Recurse);
      ParentSelf(tn); Recurse:=false;
    end;
    DelStack;
  end;
var tn,tn1: TTreeNode;
  procedure tnChk;
  var j: longint;
  begin
    AddStack('TIntTree.Fill.tnChk',Self);
    if NodeCheckDefault(ls,tn1,@j) then j:=ls.IndexOf(tn1.Text);
    if j>=0 then begin
      TreePrim1.Checked[tn1]:=true; ls.Delete(j); tnExpand(tn);
    end;
    DelStack;
  end;
var i,j,l,cnt,lv,ntnsel,lHead: longint;
  atnsel,aHead: TArrTreeNode;
  lstn: TList;
  s: string;
  fl: boolean;
begin
  AddStack('TIntTree.Fill',Self);
  lstn:=TList.Create;
  try
    cnt:=0; lv:=0; lstn.Add(nil);
    with TreePrim1 do begin
    	l:=Length(ar^); SetLength(atnsel,l); SetLength(aHead,l); ntnsel:=0; lHead:=0; OnChange:=nil; BeginUpdate;
      try
        ClearPrim;
        for l:=0 to l-1 do with ar^[l] do begin
          s:=name;
          if s='' then s:='$';
          j:=CntCharBeg(s,'$');
          if j=0 then
            if lABC then AddPrim(nil,TrimRight(name),Trim(prim),hlp,Pointer(l))
            else begin
              while lstn.Count<lv+2 do lstn.Add(nil);
              tn1:=AddPrim(lstn[lv],TrimRight(name),Trim(prim),hlp,Pointer(l));
              lstn[lv+1]:=tn1;
              if tpCanCheck in Options then tnChk
              else if AnsiUpperCase(tn1.Text)=curzn then begin
                atnsel[ntnsel]:=tn1; Inc(ntnsel);
              end;
            end
          else if not lABC then begin
            while lstn.Count<j do lstn.Add(nil);
            lv:=j-1;
            if j=1 then begin
              tn:=nil; Inc(cnt);
            end
            else tn:=lstn[lv-1];
            tn1:=AddPrim(tn,TrimRight(prim),StrDivDlm(iChrPrim,name)[2],hlp,Pointer(l)); lstn[lv]:=tn1;
            aHead[lHead]:=tn1; Inc(lHead);
            if tpCanCheckNode in Options then tnChk;
          end;
        end;
        if SubItems and not lABC and not(tpCanCheckNode in Options) then for i:=0 to lHead-1 do begin
          tn:=aHead[i];
          if not tn.HasChildren then begin
            if not Assigned(tn.Parent) then Dec(cnt);
            for j:=0 to lstn.Count-1 do
              if lstn[j]=tn then lstn[j]:=nil;
            DeletePrim(tn);
          end;
        end;
        AlphaSort;
        if cnt=1 then tnExpand(pointer(lstn[lv]));
        if (ntnsel=0) and not empty(curzn) then begin
          IsFirst(tn);
          while Assigned(tn) do
            if AnsiStartsText(curzn,tn.Text) then begin
              atnsel[ntnsel]:=tn; Inc(ntnsel); break;
            end
            else GetNextSelf(tn);
        end;
      finally
        EndUpdate;
      end;
      SetLength(atnsel,ntnsel); ntnsel:=0;
      if Assigned(ITSeekNodeProc) then ITSeekNodeProc(curzn,atnsel,ntnsel);
      fl:=RestFromIni(FSect);
      if InRange(ntnsel,low(atnsel),high(atnsel)) then Selected:=atnsel[ntnsel]
      else if not fl or aIntTreeFind then FirstSelect;
      if RbStatus1.Visible then begin
        OnChange:=TreePrim1Change; OnChange(TreePrim1,Selected);
      end;
    end;
  finally
    lstn.Free;
  end;
  DelStack;
end;

procedure TIntTree.KeyLb1ProcKey(key: longint; tw: TWinControl);
	procedure tn1(tn: TTreeNode; var lv: longint; offs: longint; var a: TArrStr; var i: longint; lSel: boolean);
  	procedure tn11(tn: TTreeNode);
    var fl: boolean;
	  	s: string;
    begin
      AddStack('TIntTree.KeyLb1ProcKey.tn1.tn11',Self);
      with tn do begin
      	fl := not(HasChildren and SubItems);
        if i=NegDef then begin
          if fl then MaxSelf(lv,Length(Text)+Level-offs);
        end
        else begin
          s:=Space(Level-offs)+Text;
          if fl then s:=Padr(s,lv)+' '+TreePrim1.NodeInf(tn).Prim;
          a[i]:=s; Inc(i);
        end;
      end;
      DelStack;
    end;
  begin
    AddStack('TIntTree.KeyLb1ProcKey.tn1',Self);
    tn11(tn);
    if lSel then begin
      GetFirstChildSelf(tn);
      while Assigned(tn) do begin
        tn1(tn,lv,offs,a,i,lSel); GetNextSiblingSelf(tn);
      end;
    end;
    DelStack;
  end;
var a,aSel: TArrStr;
	lv,lvSel,i,iSel,l: longint;
  tn,tnSel: TTreeNode;
begin
	AddStack('TIntTree.KeyLb1ProcKey',Self);
	case Key of
  	K_F5: with TreePrim1 do begin
    	lv:=0; lvSel:=0; l:=Items.Count; SetLength(a,l);
      i:=NegDef; IsFirst(tn);
      while Assigned(tn) do begin
        tn1(tn,lv,0,a,i,false); GetNextSelf(tn);
      end;
      if IsSelected(tnSel) then begin
        if not tnSel.HasChildren and Assigned(tnSel.Parent) then ParentSelf(tnSel);
        SetLength(aSel,l); iSel:=NegDef; tn1(tnSel,lvSel,tnSel.Level,aSel,iSel,true);
      end;
      i:=0; IsFirst(tn);
      while Assigned(tn) do begin
        tn1(tn,lv,0,a,i,false); GetNextSelf(tn);
      end;
      iSel:=0;
      if Assigned(tnSel) then tn1(tnSel,lvSel,tnSel.Level,aSel,iSel,true);
      PrnTxtHeadExec([Caption],ArrayAsList(a,CRLF,i),ArrayAsList(aSel,CRLF,iSel));
    end;
  	K_F10: Key:=K_Esc;
    K_Enter: Key:=K_F10;
  end;
  inherited;
  DelStack;
end;

procedure TIntTree.ProcKey;
var s: string;
begin
	AddStack('TIntTree.ProcKey',Self);
  NotD(lABC); s:=TreePrim1.Selected.Text; TreePrim1.SaveToIni(FSect); Fill(s,nil); TreePrim1.Refresh; SetKeyABC;
  DelStack;
end;

procedure TIntTree.SetKeyABC;
begin
  AddStack('TIntTree.SetKeyABC',Self);
  with KeyLb1 do begin
    if tpCanCheck in TreePrim1.Options then DelKey(K_All,'abc')
    else SetKey(K_F3,IfThen(lABC,'По разделам','По алфавиту'),'',ProcKey,'abc',kmList);
    Redrw;
  end;
  DelStack;
end;

procedure TIntTree.WMHelpFill;
begin
  AddStack('TIntTree.WMHelpFill',Self);
  inherited;
  with Msg do if (Oper=hlpFile) and (HelpContext=0) then begin
    pFile.f[hlpfBase]:=HelpFile; ResFile := HelpFile.sFile<>'';
  end;
  DelStack;
end;

procedure TIntTree.WMFormLimit;
var i: longint;
begin
	AddStack('TIntTree.WMFormLimit',Self);
  inherited;
  for i:=low(af) to high(af) do if FreeLimit(af[i]) then break;
  DelStack;
end;

procedure TIntTree.TreePrim1Change(Sender: TObject; Node: TTreeNode);
begin
	AddStack('TIntTree.TreePrim1Change',Self);
  if Assigned(Node) then stProc(RbStatus1,ar^[longint(TreePrim1.NodeInf(Node).Dop)],stPrm);
  DelStack;
end;

procedure TIntTree.TreePrim1CustomDrawPrim(Sender: TObject;
  Node: TTreeNode; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
begin
	AddStack('TIntTree.TreePrim1CustomDrawPrim',Self);
  if (Stage=cdPrePaint) and Node.Selected then with TreePrim1.Canvas do begin
    Brush.Color:=clHighlight; Font.Color:=clHighlightText;
  end;
  DelStack;
end;

function TIntTree.TreePrim1SeekNode(Sender: TObject;
  Node: TTreeNode): Boolean;
begin
	AddStack('TIntTree.TreePrim1SeekNode',Self);
  result:=not Node.HasChildren;
  DelStack;
end;

end.
