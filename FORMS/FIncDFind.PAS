unit FIncDFind;

interface

uses
  Classes, Controls, ExtCtrls, Menus, Grids, IniFiles,
  MyTypes, FRMEMPTY, Keylb, Fpanel, FFldedit, MenuGet, DirGet, RecVal, KeyMenu, PnlEdit, ComboGet, StrBrowl,
    Askp, CCodeGet, ChkGets;

type
  TIncDFLoadFileProc = procedure(const fn: string; ARow,ACol: longint);

  TIncDComboList = (idcOFunc,idcUses);

  TIncDFind = class(TFormEmp)
    pnEd: TPanelEdit;
    pnLs: TRbPanel;
    KeyMenu1: TKeyMenu;
    Rec: TRecVal;
    EPath: TFldEdit;
    DirGet1: TDirGet;
    sb: TStringBrowl;
    Timer1: TTimer;
    FuncGet: TMenuGet;
    pnFunc: TRbPanel;
    EFunc: TFldEdit;
    EOnlyWord: TFldEdit;
    BoolGet1: TBoolGet;
    procedure FormCreate(Sender: TObject);
    function pnEdValid(Sender: TObject): Boolean;
    procedure pnEdEnter(Sender: TObject);
    procedure sbEnter(Sender: TObject);
    procedure sbExit(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure EFuncChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
  private
    { Private declarations }
    fIni: TIniFile;
    pDelphi,oFuncRow: string;
    PrLoad: TIncDFLoadFileProc;
    atfCombo: array[TIncDComboList] of TFldEdit;
    aFuncRow: TArrStr;
    procedure PrFind(Sender: TAsk);
    procedure ProcKey(Key: longint; tw: TWinControl);
    procedure fIniOpen;
  public
    { Public declarations }
    class procedure Execute(const PathDelphi: string; ProcLoad: TIncDFLoadFileProc);
  end;

var
  IncDFind: TIncDFind;

implementation

{$R *.dfm}

uses SysUtils,Forms,Math,StrUtils,DB,
  My_pr,GGI;

type TFuncList = (fncIncD,fncIncL,fncDelete,fncSelfFunc,fncSelfOper,fncSelfProp,fncStr,fncSign,
  fncIfThen,fncIfThenAssigned,fncNotAssigned,fncDecLen,fncSetLen0,fncOwner{,fncIfThenPnt});

const Section = 'IncDFind';

{ TIncDFind }
procedure TIncDFind.FormCreate(Sender: TObject);
const aFunc: array[TFuncList] of string = ('v:=v___...','v:=...+v','Delete','v:=___Self(v)','v:=___Self v','v:=v.___Self','''___''','aSign','IfThen','if Assigned(___) then ___()','if not Assigned(___) then ___:=','DecLen','SetLength(a,0)->a:=nil','Owner'{,'IfThen(@)'});
  aCombo: array[TIncDComboList] of record
    f,nm: string;
    l: byte
  end =
    ((f:'OFunc'; nm:'___'   ; l:30)
    ,(f:'Uses' ; nm:'модуль'; l:8)
    );
var f: TFuncList;
  c: TIncDComboList;
  g: TComboGet;
begin
  AddStack('TIncDFind.FormCreate',Self);
  with FuncGet.Items do begin
    BeginUpdate;
    for f:=low(aFunc) to high(aFunc) do Add(Int2Str(f)+UnDelim+aFunc[f]);
    EndUpdate;
  end;
  for c:=low(aCombo) to high(aCombo) do with aCombo[c] do begin
    Rec.CreateFld(f,ftString,l,'');
    g:=TComboGet.Create(Self); g.VName:='IncD'+f; g.LenName:=l;
    atfCombo[c]:=TFldEdit.Create(Self);
    with atfCombo[c] do begin
      Parent:=pnFunc; NameRec:=Rec.NameRec; NameRecFld:=f; IncOptions([ogReadOnlyNoVsbl]);
      SayCaption:=nm; AssignGet(g); TabOrder:=EOnlyWord.TabOrder;
    end;
  end;
  EPath.OnCheck:=TFldEdit.NoEmpValue;
  inherited;
  sb.Init; SetLength(aFuncRow,10);
  DelStack;
end;

class procedure TIncDFind.Execute;
var c: TIncDComboList;
  i: longint;
begin
  AddStack('TIncDFind.Execute');
  TInitFIni.Init(Application.MainForm); CreateForm(TIncDFind,IncDFind);
  with IncDFind do begin
    pDelphi:=CorrDir(PathDelphi); PrLoad:=ProcLoad;
    fIniOpen;
    try
      Rec['Path']:=fIni.ReadString(Section,'Path','');
      Rec['Func']:=fIni.ReadInteger(Section,'Func',0);
      for c:=low(atfCombo) to high(atfCombo) do with atfCombo[c],TComboGet(curget),Items do begin
        PNameRecFld.Value:=fIni.ReadString(Section,NameRecFld,'');
        BeginUpdate;
        fIni.ReadSection(VName,Items);
        for i:=0 to Count-1 do Items[i]:=fIni.ReadString(VName,Items[i],'');
        EndUpdate;
      end;
      pnEd.FldReadAll([ferdSvOld,ferdFromShow]);
    finally
      fIni.Free;
    end;
    ShowModal;
  end;
  DelStack;
end;

procedure TIncDFind.fIniOpen;
begin
  fIni:=TIniFile.Create(GetIniFileName(pDelphi+'MYDELPHI.INI'));
end;

procedure TIncDFind.EFuncChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
var f: TFuncList;
begin
  AddStack('TIncDFind.EFuncChange',Self);
  f:=EFunc.VarValue;
  atfCombo[idcOFunc].SetReadOnly(not(f in [fncIncD,fncSelfFunc,fncSelfOper,fncSelfProp,fncStr,fncIfThenAssigned,fncNotAssigned]));
  atfCombo[idcUses].SetReadOnly(f<>fncSelfFunc);
  EOnlyWord.SetReadOnly(f<>fncStr);
  DelStack;
end;

function TIncDFind.pnEdValid(Sender: TObject): Boolean;
var c: TIncDComboList;
  s: string;
  i: longint;
begin
  AddStack('TIncDFind.pnEdValid',Self);
  fIniOpen;
  try
    fIni.WriteString(Section,'Path',Rec['Path']);
    fIni.WriteInteger(Section,'Func',Rec['Func']);
    for c:=low(atfCombo) to high(atfCombo) do with atfCombo[c],TComboGet(curget) do begin
      s:=TrimRight(VarValue); fIni.WriteString(Section,NameRecFld,s); AddSzStrings(Items,s);
      for i:=0 to Items.Count-1 do fIni.WriteString(VName,NumStr(i,10),Items[i]);
    end;
  finally
    fIni.Free;
  end;
  sb.Init; SetRedraw(sb);
  result:=mess_wait([' '],PrFind,[CorrDir(Rec['Path'])],true,Caption);
  SetRedraw(sb,rdrwSet);
  DelStack;
end;

procedure TIncDFind.PrFind;
var f: TFuncList;
  aFunc: TArrStr;
  stVar,cVar: TCharSet;
  lsFunc: TStringList;
  procedure FindPath(const path: string);
  var r,c,l: longint;
    a: TArrStr;
    function AfterSpace: boolean;
    begin
      AddStack('TIncDFind.PrFind.FindPath.AfterSpace',Self);
      while c<=l do
        if a[r][c]<=' ' then Inc(c) else break;
      result := c<=l;
      DelStack;
    end;
    function NextChar(ac: TCharSet): boolean;
    begin
      AddStack('TIncDFind.PrFind.FindPath.NextChar',Self);
      result:=false;
      if c<=l then
        if UpCase(a[r][c]) in ac then begin
          result:=true; Inc(c);
        end;
      DelStack;
    end;
    function NextStr(const s: string): boolean;
    var i: longint;
    begin
      AddStack('TIncDFind.PrFind.FindPath.NextStr',Self);
      result:=true;
      for i:=1 to Length(s) do if not NextChar([s[i]]) then begin
        result:=false; break;
      end;
      DelStack;
    end;
    function NextVar: string;
    var i: longint;
    begin
      AddStack('TIncDFind.PrFind.FindPath.NextVar',Self);
      SetLength(result,l-c+1); i:=0;
      while c<=l do
        if a[r][c] in stVar then begin
          Inc(i); result[i]:=UpCase(a[r][c]); Inc(c);
        end
        else if i>0 then begin
          if AfterSpace then
            if a[r][c] in cVar then begin
              Inc(i); result[i]:=a[r][c]; Inc(c); AfterSpace;
            end
            else break;
        end
        else break;
      SetLength(result,i);
      if i=0 then Inc(c);
      DelStack;
    end;
  const sOwner='.OWNER'; lOwner=Length(sOwner);
  var af: TArrStr;
    i,j,n,oc{,ilv}: longint;
    s,txt,ifv,FuncRow: string;
    fl,fl1,lQ: boolean;
    op: byte;
    rc: TWord2DWord;
  begin
    AddStack('TIncDFind.PrFind.FindPath',Self);
    if not Sender.SayCapt([path]) then begin
      GetMaskFiles(af,j,Sender.Params[0]+path+'*.PAS',[],[msfNoUpper]);
      GetMaskFiles(af,j,Sender.Params[0]+path+'*.DPR',[],[msfAdd,msfNoUpper,msfSort]);
      for j:=0 to j-1 do begin
        op:=0;
        for r:=0 to LsArrDynamic(StrTran(StrTran(GetStrFile(Sender.Params[0]+path+af[j]),
        CRLF,#10),#13,#10),a,#10)-1 do begin
          c:=1; l:=Length(a[r]); rc.w1:=r; lQ:=false; //ilv:=-1;
          while AfterSpace do begin
            oc:=c; txt:=Copy(a[r],c,MaxInt); fl:=false; FuncRow:='';
            case f of
              fncIncD,fncIncL,fncDelete,fncSelfFunc,fncSelfOper,fncSelfProp: begin
                s:=NextVar;
                if s<>'' then
                if AfterSpace then
                if NextStr(':=') then
                if AfterSpace then begin
                  case f of
                    fncIncD:
                      if NextVar=s then
                      if AfterSpace then
                        fl:=NextStr(aFunc[0]);
                    fncIncL: while AfterSpace do begin
                      if NextStr(';') then break;
                      if NextStr('+') then
                        if NextVar=s then begin
                          fl:=true; break;
                        end
                        else Dec(c);
                      Inc(c);
                    end;
                    fncDelete,fncSelfFunc,fncSelfOper: begin
                      FuncRow:=NextVar;
                      if Assigned(lsFunc) or AnsiMatchText(FuncRow,aFunc) then
                      if AfterSpace then
                      if (f=fncSelfOper) or NextStr('(') then
                      if AfterSpace then
                      if NextVar=s then
                      if f=fncSelfOper then fl:=true else
                      if AfterSpace then
                      if NextChar([',',')']) then
                        fl:=true;
                    end;
                    fncSelfProp: begin
                      n:=Length(s);
                      if AnsiUpperCase(Copy(a[r],c,n))=s then begin
                        Inc(c,n);
                        if NextStr('.') then begin
                          FuncRow:=NextVar;
                          if Assigned(lsFunc)
                          then fl:=true
                          else fl:=AnsiMatchText(FuncRow,aFunc);
                        end;
                      end;
                    end;
                  end;
                  if fl and Assigned(lsFunc) then
                    if IgnoreSlFindAdd(lsFunc,FuncRow,i) then begin
                      n:=IntObj(lsFunc,i); fl := n=0; lsFunc.Objects[i]:=Pointer(n+1);
                    end
                    else fl:=false;
                end;
              end;
              fncStr:
                if NextStr('''')
                  then NotD(lQ)
                else if lQ then
                  if Rec['ONLYWORD'] then begin
                    if NextVar=aFunc[0] then fl:=true;
                  end
                  else if NextStr(aFunc[0]) then fl:=true else Inc(c)
                else Inc(c);
              fncSign:
                if not NextStr(',') then Inc(c)
                else if AfterSpace then
                  if NextStr('-') then begin
                    if AfterSpace then begin
                      s:=NextVar;
                      if s<>'' then
                      if AfterSpace then
                      if NextStr(',') then
                      if AfterSpace then
                      if NextVar=s then
                        fl:=true;
                    end;
                  end
                  else begin
                    s:=NextVar;
                    if s<>'' then
                    if AfterSpace then
                    if NextStr(',') then
                    if AfterSpace then
                    if NextStr('-') then
                    if AfterSpace then
                    if NextVar=s then
                      fl:=true;
                  end;
              fncIfThen: case op of
                0: if NextVar='IF' then op:=1;
                1: if NextVar='THEN' then begin
                  op:=0; ifv:='';
                  if AfterSpace then begin
                    s:=NextVar;
                    if s='IF' then c:=oc
                    else
                      if AfterSpace then
                      if NextStr(':=') then
                      begin
                        op:=2; ifv:=s;
                      end;
                  end;
                end;
                2: begin
                  s:=NextVar;
                  if s='IF' then begin
                    c:=oc; op:=0;
                  end
                  else if s='ELSE' then begin
                    op:=0;
                    if AfterSpace then begin
                      s:=NextVar;
                      if s='IF' then c:=oc
                      else
                        if s=ifv then
                        if AfterSpace then
                        if NextStr(':=') then
                          fl:=true;
                    end;
                  end;
                end;
              end;
              fncIfThenAssigned:
                if NextVar='IF' then
                if AfterSpace then
                if NextVar='ASSIGNED' then
                if AfterSpace then
                if NextStr('(') then
                if AfterSpace then begin
                  s:=NextVar;
                  if AfterSpace then
                  if NextStr(')') then
                  if AfterSpace then
                  if NextVar='THEN' then
                  if AfterSpace then begin
                    fl1 := NextVar=s;
                    if not fl1 then
                      if AfterSpace then
                      if NextStr(':=') then
                      if AfterSpace then
                      if NextVar=s then fl1:=true;
                    if fl1 then
                    if AfterSpace then
                    if NextStr('(') then
                      fl:=true;
                  end;
                end;
              fncNotAssigned:
                if NextVar='IF' then
                if AfterSpace then
                if NextVar='NOT' then
                if AfterSpace then
                if NextVar='ASSIGNED' then
                if AfterSpace then
                if NextStr('(') then
                if AfterSpace then begin
                  s:=NextVar;
                  if AfterSpace then
                  if NextStr(')') then
                  if AfterSpace then
                  if NextVar='THEN' then
                  if AfterSpace then
                  if NextVar=s then
                  if AfterSpace then
                  if NextStr(':=') then
                    fl:=true;
                end;
              fncDecLen,fncSetLen0:
                if NextVar='SETLENGTH' then
                if AfterSpace then
                if NextStr('(') then
                if AfterSpace then begin
                  s:=NextVar;
                  if AfterSpace then
                  if NextStr(',') then
                  if AfterSpace then case f of
                    fncDecLen:
                      if NextVar='LENGTH' then
                      if AfterSpace then
                      if NextStr('(') then
                      if AfterSpace then
                      if NextVar=s then
                        fl:=true;
                    fncSetLen0:
                      if NextVar='0' then
                        fl:=true;
                  end;
                end;
              fncOwner:
                if AnsiMatchText(NextVar,['POINTER','TFLDEDIT','TMULQUERY','TBRQUERY']) then
                if AfterSpace then
                if NextStr('(') then
                if AfterSpace then
                if RightStr(NextVar,lOwner)=sOwner then
                  fl:=true;
              {fncIfThenPnt:
                if ilv<0 then begin
                  if NextVar='IFTHEN' then ilv:=0;
                end
                else if NextChar(['(']) then Inc(ilv)
                else if NextChar([')']) then ilv:=ReplVar(ilv-1,-1)
                else if NextChar(['@']) then
                  fl:=true
                else Inc(c);}
            end;
            if fl then begin
              i:=sb.RowCount-IfThen(empty(sb.Cells[0,sb.FixedRows]),1);
              sb.RowCount:=i+1;
              sb.Cells[0,i]:=af[j];
              sb.Cells[1,i]:=path;
              sb.Cells[2,i]:=txt;
              rc.w2:=oc-1; sb.Objects[2,i]:=Pointer(rc.dw);
              Dec(i,sb.FixedRows-1);
              if Assigned(lsFunc) then begin
                if Length(aFuncRow)=i then SetLength(aFuncRow,i shl 1);
                aFuncRow[i-1]:=FuncRow;
              end;
            end;
          end;
        end;
      end;
      GetMaskFiles(af,j,Sender.Params[0]+path+'*.*',[fmDir],[msfNoUpper,msfSort]);
      for j:=0 to j-1 do begin
        FindPath(path+af[j]+PathDelim);
        if Sender.Aborted then break;
      end;
    end;
    DelStack;
  end;
var i: longint;
begin
  AddStack('TIncDFind.PrFind',Self);
  lsFunc:=nil;
  try
    f:=Rec['Func']; stVar:=['0'..'9','A'..'Z','_','a'..'z']; cVar:=['.','[',']','^']; aFunc:=nil;
    if f in [fncIncD,fncStr] then begin
      AddFrom(aFunc,TrimUpper(Rec['OFUNC']));
      if f=fncStr then for i:=1 to Length(aFunc[0]) do Include(stVar,aFunc[0][i]);
    end
    else begin
      Include(cVar,'''');
      case f of
        fncDelete: AddFrom(aFunc,['SYSTEM.COPY','COPY','STRUTILS.STUFFSTRING','STUFFSTRING']);
        fncSelfFunc,fncSelfOper,fncSelfProp,fncIfThenAssigned,fncNotAssigned:
          if empty(Rec['OFUNC'])
          then lsFunc:=SortStrListCreate
          else begin
            AddFrom(aFunc,TrimUpper(Rec['OFUNC']));
            if f=fncSelfFunc
            then AddFrom(aFunc,TrimUpper(Rec['USES'])+'.'+TrimUpper(Rec['OFUNC']));
          end;
      end;
    end;
    FindPath(''); sb.AdjustColsWidth;
    if Assigned(lsFunc) then if empty(Rec['OFUNC']) then if oFuncRow<>'' then begin
      for i:=0 to sb.RowCount-sb.FixedRows-1 do if aFuncRow[i]=oFuncRow then begin
        sb.Row:=sb.FixedRows+i; break;
      end;
      oFuncRow:='';
    end;
  finally
    lsFunc.Free;
  end;
  DelStack;
end;

procedure TIncDFind.pnEdEnter(Sender: TObject);
begin
  AddStack('TIncDFind.pnEdEnter',Self);
  inherited;
  pnEd.FillKeyLb;
  DelStack;
end;

procedure TIncDFind.sbEnter(Sender: TObject);
begin
  AddStack('TIncDFind.sbEnter',Self);
  inherited;
  with KeyLb1 do begin
    if not empty(sb.Cells[0,sb.FixedRows])
    then SetKey(K_Enter,'Загрузить','',ProcKey,'IncDFind',kmList);
    with atfCombo[idcOFunc] do if not(ogReadOnly in Options) then
      if empty(VarValue)
      then SetKey(K_F2,'Текущий','Поиск по текущему ___',ProcKey,'IncDFind',kmList)
      else SetKey(K_F2,'Все','Поиск по всем ___',ProcKey,'IncDFind',kmList);
    Redrw;
  end;
  DelStack;
end;

procedure TIncDFind.sbExit(Sender: TObject);
begin
  AddStack('TIncDFind.sbExit',Self);
  KeyLb1.DelKey(K_All,'IncDFind'); KeyLb1.Redrw;
  DelStack;
end;

procedure TIncDFind.ProcKey;
begin
  AddStack('TIncDFind.ProcKey',Self);
  case Key of
    K_F2: with atfCombo[idcOFunc] do begin
      pnFunc.SetFocus; oFuncRow:=TrimUpper(VarValue);
      if oFuncRow='' then VarValue:=aFuncRow[sb.Row-sb.FixedRows] else VarValue:='';
      KeyLb1.ExecKey(K_F10);
    end;
    K_Enter: begin
      SetModalResult(mrOk);
      if Assigned(PrLoad) then Timer1.Enabled:=true;
    end;
  end;
  DelStack;
end;

procedure TIncDFind.Timer1Timer(Sender: TObject);
var rc: TWord2DWord;
begin
  AddStack('TIncDFind.Timer1Timer',Self);
  Timer1.Enabled:=false;
  with sb,rc do begin
    dw:=LongWordObj(2,Row); PrLoad(CorrDir(Rec['Path'])+Cells[1,Row]+Cells[0,Row],w1,w2);
  end;
  DelStack;
end;

end.
