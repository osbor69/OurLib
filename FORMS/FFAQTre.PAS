unit FFAQTre;

interface

{$I LIBTEST}
uses
  Messages, Classes, Controls, ExtCtrls, ComCtrls, Menus, DB,
  MyTypes, FRMEMPTY, Keylb, Fpanel, TreePrim, KeyMenu, RecVal, RecDB, FFldedit, ComboGet, DefEdit,
    ModelGet, CCodeGet, MulQry;

type
  TFAQTre = class(TFormEmp)
    KeyMenu1: TKeyMenu;
    de: TDefEdit;
    Tree: TTreePrim;
    Rec: TRecVal;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure deFldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    function deFldCheck(Sender: TObject): Boolean;
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FAQ: TRecDB;
    qCnt: byte;
    Qry: TMulQuery;
    lsm: TMemGKList;
    aq: array of record
      g: TComboGet;
      tn: TTreeNode;
    end;
    ad: array of record
      rec,answ: longint;
    end;
    function qFldArg(const nmArg: string; q: TMulQuery = nil): string;
    function tnRec(tn: TTreeNode): longint;
    procedure TreeLoad(const qs: string);
    procedure QryAfterClose(Sender: TDataSet);
    function tnQuest(tn: TTreeNode = nil): string;
    procedure TreeLoadCurNode(tn: TTreeNode = nil);
    procedure ProcKey(Key: longint; tw: TWinControl);
    function PrFind(Sender: TControl; const sf: string): boolean;
    procedure mgHelp(Sender: TObject; var ht: THelpTbl);
    procedure mgSave(Sender: TObject; FromEdit: Boolean);
    procedure mgLoad(Sender: TObject; FromEdit: Boolean);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
  end;

var
  FAQTre: TFAQTre;

implementation

{$R *.dfm}

uses Windows,SysUtils,StrUtils,Math,
  My_pr,FrmPswd,FStat,FSchemDM;

const qDlm=#31; lqDlm=Length(qDlm);
  fANSW = sMemo+'ANSW';

function qFld(i: byte): string; overload;
begin
  AddStack('FFAQTre.qFld');
  result:=StrNum('Q',i,2);
  DelStack;
end;

function qFld(tn: TTreeNode): string; overload;
begin
  AddStack('FFAQTre.qFld(tn)');
  result:=qFld(tn.Level+1);
  DelStack;
end;

{ TFAQTre }
procedure TFAQTre.FormCreate(Sender: TObject);
var i: byte;
  f: string;
  av: TDEPrmVar;
begin
  AddStack('TFAQTre.FormCreate',Self);
  inherited;
  FAQ:=TRecDB.Create(Self);
  with FAQ do begin
    NameRec:=tFAQ; NameDB:=tFAQ; OpenRec; qCnt:=CntFldNm('Q',2);
  end;
  Qry:=TMulQuery.CreateConnection;
  with Qry do begin
    AfterClose:=QryAfterClose; qFldArg(sC_LIST,Qry);
    PartSelect(tFAQ,[fRECNO,Arg[sC_LIST],fANSW],'',Arg[sC_LIST],'',false);
  end;
  SetLength(aq,qCnt);
  InitArr(av);
  av[deAutoSel]:=true;
  av[deNoReadOnly]:=true;
  av[deReadOnlyNoVsbl]:=true;
  av[deRelation]:='Main.Z1';
  av[deWidth]:=wallNoSay;
  for i:=1 to qCnt do with aq[i-1] do begin
    f:=qFld(i); g:=TComboGet.Create(Self);
    g.VName:=StrNum('FAQ',i); g.Sorted:=true; g.LenName:=Length(FAQ[f]); Rec.CreateFld(f,ftString,g.LenName,'');
    av[deCaption]:=IntToStr(i)+' уровень';
    av[deNameRecFld]:=f;
    g.AssignGet(av);
    de.CreateFld(av,fANSW);
  end;
  with KeyLb1 do begin
    SetKey(K_Enter,'Ответ','Просмотр ответа',ProcKey,'faq',kmList);
    if CanPriv(PrivDesign) then begin
      SetKey(K_F4,'Скопировать','',ProcKey,'faq',kmList);
      SetKey(K_F5,'Редактировать','',ProcKey,'faq',kmList);
      SetKey(K_F7,'Добавить','',ProcKey,'faq',kmList);
      SetKey(K_F8,'Удалить','',ProcKey,'faq',kmList);
      SetKey(K_Ctrl_R,'','Обновить',ProcKey,'faq',kmList);
      SetKey(K_Alt_F3,'','Создать основу',ProcKey,'faq',kmServic);
    end;
    SetKey(K_Alt_F5,'','Загрузить из основы',ProcKey,'faq',kmServic,NotePrivModelLoad);
    SetKey(K_Alt_F6,'','Поиск по содержимому',ProcKey,'faq',kmList);
    SetKey(K_Ctrl_F6,'Печать','Печать вопроса и ответа',ProcKey,'faq',kmFile);
  end;
  with SchemDM.mgFAQ do begin
    OnHelp:=mgHelp; OnLoad:=mgLoad; OnSave:=mgSave;
  end;
  InitFIni[fiSave].EraseSection('FAQTre');
  DelStack;
end;

procedure TFAQTre.FormDestroy(Sender: TObject);
begin
  AddStack('TFAQTre.FormDestroy',Self);
  Qry.Free;
  inherited;
  DelStack;
end;

function TFAQTre.qFldArg;
var i: byte;
begin
  AddStack('TFAQTre.qFldArg',Self);
  with q.QryCur do begin
    Arg[nmArg]:='';
    for i:=1 to qCnt do AddArgList(nmArg,qFld(i));
    result:=Arg[nmArg];
  end;
  DelStack;
end;

function TFAQTre.tnQuest;
begin
  AddStack('TFAQTre.tnQuest',Self);
  result:=''; Tree.DefSelected(tn);
  while Assigned(tn) do begin
    IncL(result,tn.Text+qDlm); ParentSelf(tn);
  end;
  DecLen(result,lqDlm);
  DelStack;
end;

procedure TFAQTre.FormShow(Sender: TObject);
begin
  AddStack('TFAQTre.FormShow',Self);
  inherited;
  TreeLoad('');
  DelStack;
end;

procedure TFAQTre.FormHide(Sender: TObject);
begin
  AddStack('TFAQTre.FormHide',Self);
  Tree.Filtered:=false; Tree.SaveToIni; Qry.Close;
  inherited;
  DelStack;
end;

procedure TFAQTre.TreeLoad;
var i: byte;
  j: longint;
  atn: TArrTreeNode;
  fl: boolean;
  s,sf: string;
  tn,tnSel: TTreeNode;
  p: pointer;
begin
  AddStack('TFAQTre.TreeLoad',Self);
  if qs<>'' then Tree.SaveToIni;
  Tree.BeginUpdate; Tree.ClearPrim;
  aq[0].g.Items.BeginUpdate; aq[0].g.Items.Clear;
  SetLength(atn,qCnt); tnSel:=nil;
  with Qry do begin
    ReOpen; j:=RecordCount;
    if Length(ad)<j then SetLength(ad,j);
    for j:=0 to j-1 do begin
      ad[j].rec:=Fields[0].AsInteger; ad[j].answ:=Fields[qCnt+1].AsInteger;
      p:=pointer(j); sf:=''; aq[0].g.Items.Add(TrimRight(Fields[1].AsString));
      for i:=1 to qCnt do begin
        s:=TrimRight(Fields[i].AsString);
        if s='' then break;
        if Assigned(atn[i-1]) then begin
          fl := s<>atn[i-1].Text;
          if fl then ZeroMemory(pointer(longint(@atn[0])+(i-1)*SizeOf(atn[0])),(qCnt-i+1)*SizeOf(atn[0]));
        end
        else fl:=true;
        if fl then begin
          if i=1 then tn:=nil else tn:=atn[i-2];
          atn[i-1]:=Tree.AddPrim(tn,s,'',0,p);
        end;
        if not Assigned(tnSel) then begin
          sf:=IfThen(i>1,sf+qDlm)+s;
          if sf=qs then tnSel:=atn[i-1];
        end;
      end;
      Next;
    end;
  end;
  aq[0].g.Items.EndUpdate; Tree.RestFromIni;
  if qs<>'' then begin
    Tree.FirstIfNil(tnSel); Tree.Selected:=tnSel;
  end;
  Tree.EndUpdate;
  DelStack;
end;

procedure TFAQTre.QryAfterClose;
begin
  AddStack('TFAQTre.QryAfterClose',Self);
  lsm:=nil;
  DelStack;
end;

procedure TFAQTre.TreeLoadCurNode;
begin
  AddStack('TFAQTre.TreeLoadCurNode',Self);
  TreeLoad(tnQuest(tn));
  DelStack;
end;

procedure TFAQTre.ProcKey;
const aPart: TArrBoolStr = ('вопрос','раздел');
var tn,tn1,tn2: TTreeNode;
  lApp,lPart: boolean;
  i,lo,ln: longint;
  s,w,qs: string;
  r: TCustomRec;
  lsm: TMemGkList;
begin
  AddStack('TFAQTre.ProcKey',Self);
  if Key in [K_F4,K_F5,K_F7,K_Alt_F6] then Tree.Filtered:=false;
  if Tree.IsFirst or (Key in [K_F7,K_Ctrl_R,K_Alt_F5]) then begin
    if not Tree.IsSelected(tn) or (Key=K_F7) then lPart:=false else lPart:=tn.HasChildren;
    case Key of
      K_F4,K_F5,K_F7: begin
        SetLogVid(aEdAppLog[Key in [K_F4,K_F7]]);
        if lPart then begin
          tn2:=tn.getNextSibling; tn1:=tn.getFirstChild; lo:=0;
          while tn1<>tn2 do begin
            MaxSelf(lo,tn1.Level); GetNextSelf(tn1);
          end;
          lo:=tn.Level+qCnt-lo;
        end
        else lo:=qCnt;
        for i:=1 to qCnt do de.Param[qFld(i),deNoVisible]:=bStr[i>lo];
        if Key<>K_F7 then begin
          if lPart then begin
            tn1:=tn; w:='';
            while Assigned(tn1) do begin
              IncL(w,FAQ.TblFldName(qFld(tn1))+'='+QQs(tn1.Text)+sAND);
              Rec[qFld(tn1)]:=tn1.Text; ParentSelf(tn1);
            end;
            DecLen(w,lAND);
            for i:=tn.Level+2 to qCnt do Rec[qFld(i)]:='';
          end
          else FAQ.GotoRec(tnRec(tn));
        end;
        lApp := Key in [K_F4,K_F7];
        if lApp then FAQ.NewRec(IfThen(Key=K_F4,newrCopy));
        r:=IfThen(lPart,Rec,FAQ);
        for i:=1 to qCnt do de.Param[qFld(i),deNameRec]:=r.NameRec;
        de.Param[fANSW,deNoVisible]:=bStr[lPart];
        if de.Execute(IfThen(lApp,'Добавить','Редактировать')+' '+aPart[lPart]).Saved then begin
          qs:=''; ln:=1;
          while ln<=qCnt do begin
            s:=TrimRight(r[qFld(ln)]);
            if s='' then break;
            IncD(qs,qDlm+s); Inc(ln);
          end;
          if lPart then with ProgPswd.GetQuery do begin
            PartSelect(tFAQ,[],w); lsm:=TMemGkList.Create(FAQ); lo:=tn.Level+1; Dec(ln);
            while not Eof do begin
              lsm.GetFromQuery;
              if lApp then FAQ.NewRec([newrCopy]);
              if ln>lo then for i:=qCnt downto ln+1 do FAQ[qFld(i)]:=FAQ[qFld(i-ln+lo)];
              for i:=1 to ln do begin
                s:=qFld(i); FAQ[s]:=Rec[s];
              end;
              if ln<lo then for i:=ln+1 to qCnt do FAQ[qFld(i)]:=FAQ[qFld(i-ln+lo)];
              FAQ.AppUpdRec(true); Next;
            end;
            ProgPswd.FreeQuery;
          end
          else FAQ.AppUpdRec(true);
          TreeLoad(Copy(qs,lqDlm+1,MaxInt));
        end;
        SetLogVid;
      end;
      K_F8: begin
        SetLogVid(logvDelRec);
        if Ask(['Вы уверены,','что нужно удалить '+aPart[lPart]+' ?']) then begin
          if lPart then begin
            tn1:=tn; w:='';
            while Assigned(tn1) do begin
              IncL(w,qFld(tn1)+'='+QQs(tn1.Text)+sAND); ParentSelf(tn1);
            end;
            DecLen(w,lAND);
          end
          else w:=RecnoWhere(tnRec(tn));
          FAQ.DelRec(w,[delLog]); TreeLoadCurNode(IfThen(tn.getNextSibling,Tree.Selected.GetPrevSibling));
        end;
        SetLogVid;
      end;
      K_Enter: if not lPart then begin
        FAQ.GotoRec(tnRec(tn)); EdTextView(tn.Text,FAQ[fANSW],'',nil,[edtxtWordWrap]);
      end;
      K_Ctrl_F6: if not lPart then begin
        FAQ.GotoRec(tnRec(tn)); s:='';
        while Assigned(tn) do begin
          IncL(s,tn.Text+CRLF); ParentSelf(tn);
        end;
        PrnTxtExec(s+CRLF+FAQ[fANSW]);
      end;
      K_Ctrl_R: TreeLoadCurNode;
      K_Alt_F3: SchemDM.mgFAQ.Add;
      K_Alt_F5: if SchemDM.mgFAQ.List then TreeLoadCurNode;
      K_Alt_F6: WinFind(Tree,PrFind,[fnoRegistr,fnoWord,fnoDirection,fnoAll,fnoSave],'Поиск по содержимому');
    end;
  end;
  DelStack;
end;

procedure TFAQTre.deFldChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
var i: byte;
  fl: boolean;
  s: string;
  tn: TTreeNode;
  tfNext: TFldEdit;
begin
  AddStack('TFAQTre.deFldChange',Self);
  with TFldEdit(Sender) do begin
    i:=Int0(Copy(NameRecFld,2,2));
    if NameRecFld=qFld(i) then
      if de.IsFldEdit(qFld(i+1),tfNext) then begin
        s:=TrimRight(VarValue); fl := s=''; aq[i-1].tn:=nil;
        if not fl then begin
          if i=1
            then Tree.IsFirst(tn)
          else if Assigned(aq[i-2].tn)
            then tn:=aq[i-2].tn.GetFirstChild
          else tn:=nil;
          with aq[i].g.Items do begin
            BeginUpdate; Clear;
            while Assigned(tn) do
              if tn.Text=s then begin
                aq[i-1].tn:=tn; GetFirstChildSelf(tn);
                while Assigned(tn) do begin
                  Add(tn.Text); GetNextSiblingSelf(tn);
                end;
                break;
              end
              else GetNextSiblingSelf(tn);
            EndUpdate;
          end;
        end;
        tfNext.SetReadOnly(fl,'');
      end;
  end;
  DelStack;
end;

function TFAQTre.deFldCheck(Sender: TObject): Boolean;
var i,j: byte;
  w,f,v,s: string;
  svi: TRDBSaveInf;
begin
  AddStack('TFAQTre.deFldCheck',Self);
  result:=true;
  if TFldEdit(Sender).NameRecFld=fANSW then with ProgPswd.GetQuery do begin
    i:=qCnt;
    while i>0 do
      if ogReadOnly in de.Options[qFld(i)] then Dec(i)
      else begin
        Dec(i);
        while i>1 do begin
          Dec(i); w:=''; s:='';
          for j:=1 to qCnt do begin
            f:=qFld(j);
            if j>i then v:=''
            else begin
              v:=de.FldValue[f]; IncD(s,IntToStr(j)+' уровень: '+TrimRight(v)+CRLF);
            end;
            IncAnd(w,f+'='+QQs(v));
          end;
          PartSelect(tFAQ,[fRECNO,fANSW],Copy(w,lAND1,MaxInt));
          if IsRecords then begin
            if Fields[1].AsInteger>0
            then result:=Ask(['Существует вопрос предыдущего уровня с заполненным ответом.',s,
              'Удалить ответ в этом вопросе ?']);
            if result then begin
              FAQ.SaveInf(svi); FAQ.DelRec(RecnoWhere(Fields[0])); TRecDB.RestInf(svi);
            end;
            break;
          end;
        end;
        break;
      end;
    ProgPswd.FreeQuery;
  end;
  DelStack;
end;

procedure TFAQTre.WMFormLimit;
begin
	AddStack('TFAQTre.WMFormLimit',Self);
  inherited;
  FreeLimit(FAQTre);
  DelStack;
end;

procedure TFAQTre.mgHelp;
var n: byte;
begin
  AddStack('TFAQTre.mgHelp',Self);
  n:=high(ht.Dat); SetLength(ht.Dat,n+5);
  Inc(n); CopyFrom(ht.Dat[n],'Количество записей. Для каждой записи:');
  Inc(n); CopyFrom(ht.Dat[n],' Количество заполненных уровней вопроса. Для каждого уровня:');
  Inc(n); CopyFrom(ht.Dat[n],'  Вопрос');
  FAQ.HelpTblAdd(ht,n,[fANSW],1);
  DelStack;
end;

procedure TFAQTre.mgSave;
var lsm: TMemGkList;
  i,l: byte;
begin
  AddStack('TFAQTre.mgSave',Self);
	with TModelGet(Sender),ProgPswd.GetQuery do begin
    PartSelect(tFAQ,[],'',qFldArg(sO_LIST)); WriteVal(RecordCount,stInteger); lsm:=TMemGkList.Create(FAQ);
    while not Eof do begin
      lsm.GetFromQuery; l:=1;
      while l<=qCnt do
        if empty(FAQ[qFld(l)]) then break else Inc(l);
      Dec(l); WriteVal(l,stByte);
      for i:=1 to l do WriteStr1(TrimRight(FAQ[qFld(i)]));
      WriteStr(TrimRight(FAQ[fANSW])); Next;
    end;
    ProgPswd.FreeQuery;
    ProgPswd.RG[UsedFieldName]:=MDFile; ProgPswd.RG[UsedFieldNSave]:=NSave;
    ProgPswd.RG.UpdateRec(true);
  end;
  DelStack;
end;

procedure StMdLoad(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var j,n: longint;
  i,l: byte;
  s: string;
  lsm1: TMemGkList;
begin
  AddStack('FFAQTre.StMdLoad');
  n:=Params[0]; lsm1:=PointerVar(Params[2]);
  for j:=1 to n do with ModelGetVar(Params[1]),FAQTre,ProgPswd.CurQuery do begin
    if Eof then FAQ.NewRec([newrNoDoNewRec]) else lsm1.GetFromQuery;
    l:=ReadVal(stByte);
    for i:=1 to qCnt do begin
      if i>l then s:='' else s:=ReadStr1;
      FAQ[qFld(i)]:=s;
    end;
    FAQ[fANSW]:=ReadStr; FAQ.AppUpdRec; Next;
  end;
  DelStack;
end;

procedure TFAQTre.mgLoad;
var j,n: longint;
  p: string;
  lsm1: TMemGkList;
  fl: boolean;
  a: TArrStr;
  fqRECNO: TField;
begin
  AddStack('TFAQTre.mgLoad',Self);
	with TModelGet(Sender) do if TrnsStart([tFAQ,tGLOBSET]) then try
    if Vers<1 then begin
      fl:=true; FAQ.DelRec('*');
      while true do begin
        n:=ReadVal(stInteger);
        if n=0 then break;
        p:=ReadStr1;
        while n>0 do begin
          FAQ.NewRec; FAQ[qFld(1)]:=p; FAQ[qFld(2)]:=ReadStr1; FAQ[fANSW]:=ReadStr; FAQ.AppRec; Dec(n);
        end;
      end;
    end
    else with ProgPswd.GetQuery do begin
      PartSelect(tFAQ,[],'',qFldArg(sO_LIST)); lsm1:=TMemGkList.Create(FAQ);
      n:=ReadVal(stInteger);
      fl:=not ShowStat('Загрузка из основы',StMdLoad,[n,longint(Sender),longint(lsm1)],n,10);
      if fl then begin
        n:=RecordCount-n; fqRECNO:=FindField(fRECNO);
        if n>0 then begin
          SetLength(a,n);
          for j:=low(a) to high(a) do begin
            a[j]:=Vtos(fqRECNO); Next;
          end;
          FAQ.DelRec(a);
        end;
      end;
      ProgPswd.FreeQuery;
    end;
    if fl then begin
      ProgPswd.RG[UsedFieldNSave]:=NSave; ProgPswd.RG.UpdateRec; LogWrite(tFAQ);
    end;
    TrnsEnd(IfThen(fl,trnsCommit));
  except
    TrnsEnd; raise
  end;
  DelStack;
end;

function TFAQTre.tnRec(tn: TTreeNode): longint;
begin
  AddStack('TFAQTre.tnRec',Self);
  result:=ad[longint(Tree.NodeInf(tn).Dop)].rec;
  DelStack;
end;

function TFAQTre.PrFind;
var tnSel: TTreeNode;
  flt: TIntegerList;
  i,lr: longint;
  procedure tnFind(tn: TTreeNode);
  begin
    AddStack('TFAQTre.PrFind.tnFind',Self);
    while Assigned(tn) and (tn<>tnSel) do begin
      if WinFindSayStat(i/lr) then begin
        result:=false; break;
      end;
      Inc(i);
      if not tn.HasChildren then if FindInStr(lsm.GetValue(ad[longint(Tree.NodeInf(tn).Dop)].answ),sf) then begin
        result:=true;
        if FindProperty.Direction=fndAll then TTreePrim.AddListFiltered(flt,tn)
        else begin
          Tree.Selected:=tn; break;
        end;
      end;
      if FindProperty.Direction=fndBack then GetPrevSelf(tn) else GetNextSelf(tn);
    end;
    DelStack;
  end;
begin
  AddStack('TFAQTre.PrFind',Self);
  result:=false;
  if not Assigned(lsm) then lsm:=TMemGKList.Create(FAQ,Qry);
  with Tree do begin
    i:=1; lr:=Items.Count;
    case FindProperty.Direction of
      fndForward: begin
        tnSel:=Selected; tnFind(tnSel.GetNext);
        if not result then tnFind(Items.GetFirstNode);
      end;
      fndBack: begin
        tnSel:=Selected; tnFind(tnSel.GetPrev);
        if not result then tnFind(Items[Items.Count-1]);
      end;
      fndAll: begin
        flt:=TIntegerList.Create([ilsSorted]);
        try
          tnSel:=nil; tnFind(Items.GetFirstNode);
          if result then SetListFiltered(flt);
        finally
          flt.Free;
        end;
      end;
    end;
  end;
  DelStack;
end;

procedure PswdKeyProc(Key: longint; tw: TWinControl; var lBreak: boolean);
begin
  AddStack('FFAQTre.PswdKeyProc');
  if Key=K_Shift_F1 then begin
    lBreak:=true; CreateShow(TFAQTre,FAQTre,true);
  end;
  DelStack;
end;

procedure ModelGetProc(Before: boolean; var lCreate: boolean);
begin
  AddStack('FFAQTre.ModelGetProc');
  if Before then lCreate:=CreateForm(TFAQTre,FAQTre)
  else if lCreate then FormFree(FAQTre);
  DelStack;
end;

procedure LogTrnsValProc(var Prm: TLogTrnsValPrm);
begin
  AddStack('FFAQTre.LogTrnsValProc');
  if LogEqual(Prm,tFAQ,fANSW) then TCrlfLogCompare.Execute(Prm);
  DelStack;
end;

initialization
  AddStack('FFAQTre.initialization');
  SetPrim(tFAQ,'Вопросы-ответы');
  AddFrom(aPswdKeyProc,PswdKeyProc);
  AddFrom(ModelGetProc);
  LogTrnsValProcAdd(LogTrnsValProc);
  DelStack;
end.
