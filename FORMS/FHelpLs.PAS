unit FHelpLs;

interface

{$I LIBTEST}
uses
  Messages, Classes, Controls, ExtCtrls, StdCtrls, Math, Menus,
  MyTypes, My_pr, FRMEMPTY, Keylb, Fpanel, Schem, FEdText, KeyMenu, ListF2;

type
  THelpMemo = class(TTextMemo)
  private
    aStyle: array[THelpStyleList] of array of record
      p,l: longint;
    end;
    lsLink: TIntegerList;
    aLink: array of THelpFile;
    rf: array[boolean] of THelpFile;
    fMouse: boolean;
    KeyLb: TKeyLb;
    CurFile: longint;
    function FindLink(fMouse: boolean; var Vid: THelpLinkList; Pos: longint): boolean;
    function IsLink(fMouse: boolean; var Vid: THelpLinkList): boolean;
    procedure SetKeyLink;
    procedure ProcKey(key: longint; tw: TWinControl);
    function ReBoldStr(const st: string; FillLink: boolean): string;
  protected
		procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure doSciStyleNeeded(const position : Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoMoveCaret(const oldCaret,newCaret: TFMemoCaret); override;
    procedure AfterExit; override;
		procedure WMHelpFill(var msg: TWMHelpFill); override;
  public
		constructor CreateParent(AOwner: TComponent; AParent: TWinControl); override;
		destructor Destroy; override;
    procedure AfterEnter; override;
    procedure SetText(const v: string); override;
  end;

  THelpLs = class(TFormEmp)
    RbStatus1: TRbStatus;
    RbPanel3: TRbPanel;
    pnPart: TRbPanel;
    pnMemo: TRbPanel;
    KeyMenu1: TKeyMenu;
    procedure pnPartSetWHMin(Sender: TObject);
    procedure pnResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    lsPart: TFindListBox;
    Memo: THelpMemo;
    aLine: TArrInt;
    procedure lsPartKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lsPartMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    class procedure Edit(nFile,nPage: longint;
      crStart: longint = 0; crLen: longint = 0); overload;
    class procedure Edit(nFile: longint; const nmPage: string); overload;
    procedure ProcKey(key: longint; tw: TWinControl);
    class function PrFind(Sender: TControl; const sf: string): boolean;
		class procedure FindProcKey(key: longint; tw: TWinControl);
    class procedure FindPrShow(Sender: TObject);
    procedure FindTimerShow(Sender: TObject);
    procedure lsPartChange;
    procedure MemoMoveCaret(const oldCaret,newCaret: TFMemoCaret);
    function GetLine: longint;
    procedure SetLine(Value: longint);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
		procedure WMSchem(var msg: TWMSchem); message WM_SCHEM;
  public
    { Public declarations }
    property Line: longint read GetLine write SetLine;
    class procedure Edit(tw: TWinControl); overload;
    class procedure Edit(const nmPage,nmFile: string); overload;
    class procedure Execute(tw: TWinControl); overload;
    class procedure Execute(const nmPage: string; nFile: longint = NegDef; PrShow: TNotifyEvent = nil); overload;
    class procedure Execute(const nmPage,nmFile: string); overload;
    class procedure Execute(const a: THelpArr; nFile: longint = NegDef;
      tw: TWinControl = nil; PrShow: TNotifyEvent = nil; PrHide: TNotifyEvent = nil); overload;
    class procedure Content;
    class function FileFind(const nmFile: string; var nFile: longint): boolean;
    class function PageFind(const nmPage: string; var nFile: longint): boolean;
  end;

procedure HelpVar2Arr(const vf: variant; a: PHelpArr; nFile: longint = NegDef);
procedure HelpEval(nFile,nPage: longint; a: PHelpArr); overload;

implementation

{$R *.dfm}

uses
  Windows,SysUtils,Variants,Graphics,Forms,ScintillaLanguageManager,SciSupport,StrUtils,
    ComCtrls,DateUtils,
  Inter,BufFile,FFldEdit,TreePrim,Shifr,FFind;

type
  THelpEditMemo = class(TInterMemo)
  private
    class procedure ProcKey(key: longint; tw: TWinControl);
  public
    procedure AfterEnter; override;
    procedure AfterExit; override;
  end;

  TTreeHelp = class(TTreePrim)
  protected
		procedure ProcKey(key: longint; tw: TWinControl); override;
  end;

  THelpTree = class(TFormEmp)
    procedure FormCreate(Sender: TObject);
  private
    Tree: TTreeHelp;
    aTree: array of record
      nFile: longint;
      Vid: THelpLinkList;
      nmPage: string;
    end;
    lTree: longint;
    function nTree(tn: TTreeNode): longint;
    procedure TreeChange(Sender: TObject; Node: TTreeNode);
    procedure ProcKey(key: longint; tw: TWinControl);
    function PrFind(Sender: TControl; const sf: string): boolean;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  end;

  THelpComp = class(TFormEmp)
    procedure FormCreate(Sender: TObject);
  private
    lbCnt,lbFml: TListBox;
    class procedure pnRezise(Sender: TObject);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  end;

  THelpStyleInt = array[THelpStyleList] of longint;

  TFindOper = (fndCont,fndAlg);

  TGetList = class(TStringList)
  private
    constructor Create;
    function MaskHelp(Index: longint): TMaskHelp;
  end;

  TNone = class
  private
    class procedure DopGetVarAdd(ProcDopGetVarAdd: TProcDopGetVarAdd);
    class function DopGetVarIgnore(const aPath: TVarPathStr): boolean;
  end;

const
  MapExt = '.MAP.HLP';
  FmlExt = '.FML.HLP';

  DlmBeg = '[';
  DlmEnd = ']';

  VarBeg = 'helptbl';

var
  aFile: array of record
    nmf: TFileName;
    lsMap: TIntStrList;
    lsPage: TStrStrList;
  end;
  aHelpLs: array of THelpLs;
  nHelpLs: longint = -1;
  aHelpTree: array of THelpTree;
  nHelpTree: longint = -1;
  aHelpComp: array of THelpComp;
  nHelpComp: longint = -1;
  lsVarDop: TVarDopList;
  FindNextHelp: boolean;
  lsFind: TStringList;
  aFind: array of record
    nFile,nPage: longint;
  end;
  CurHelpFile: THelpFileArr;
  FindOper: TFindOper;

function InRange(const f: THelpFile; var Vid: THelpLinkList): boolean; overload;
var i: longint;
begin
  AddStack('FHelpLs.InRange');
  if f.sFile='' then result:=false
  else begin
    i:=Int0(f.sFile); result:=InRange(i,byte(low(THelpLinkList)),byte(high(THelpLinkList)));
    if result then Vid:=THelpLinkList(i);
  end;
  DelStack;
end;

procedure HelpVar2Arr;
  function PartDate(const a: THelpArr; n: longint): TDateTime;
  const Mask='99.99.9999 99:99'; lMask=Length(Mask);
  var i,j: longint;
    fl,fl1: boolean;
    AYear,AMonth,ADay,AHour,AMinute: Word;
  begin
    AddStack('FHelpLs.HelpVar2Arr.PartDate');
    result:=DateEmpty;
    with a[n] do begin
      for i:=1 to Length(part)-lMask+1 do begin
        fl:=true;
        for j:=1 to lMask do begin
          if Mask[j]='9' then fl1:=IsDigit(part[i+j-1]) else fl1 := part[i+j-1]=Mask[j];
          if not fl1 then begin
            fl:=false; break;
          end;
        end;
        if fl then begin
          aDay:=Int0(Copy(part,i,2)); aMonth:=Int0(Copy(part,i+3,2)); aYear:=Int0(Copy(part,i+6,4));
          aHour:=Int0(Copy(part,i+11,2)); aMinute:=Int0(Copy(part,i+14,2));
          if not TryEncodeDateTime(AYear,AMonth,ADay,AHour,AMinute,0,0,result) then result:=DateEmpty;
          break;
        end;
      end;
    end;
    DelStack;
  end;
var i,j,l,h,fi,pi: longint;
  v: variant;
  s: string;
  ai: THelpArr;
  db,d1,d2,di: TDateTime;
begin
  AddStack('FHelpLs.HelpVar2Arr');
  case MyVarType(vf) of
    varString: begin
      SetLength(a^,1); a^[0].part:=HelpBoldStr(vf,hlnkLink);
    end;
    varArray: begin
      l:=VarArrayLowBound(vf,1);
      if MyVarType(vf[l])=V_INT then begin
        SetLength(a^,1); a^[0].part:=HelpBoldStr(string(vf[l+1]),THelpLinkList(vf[l]));
      end
      else begin
        h:=VarArrayHighBound(vf,1); SetLength(a^,h-l+1); i:=0;
        fi:=-1; pi:=-1; db:=DateEmpty;
        for l:=l to h do begin
          v:=vf[l];
          if MyVarType(v)=varArray then with a^[i] do begin
            VAddEndSelf(v,4);
            case MyVarType(v[1],true) of
              V_FLOAT: begin
                if v[1]=1 then begin
                  if MyVarType(v[3])=V_STRING then THelpLs.FileFind(v[3],fi) else fi:=nFile;
                  if fi<>NegDef then pi:=aFile[fi].lsPage.IndexOf(v[2]);
                  if MyVarType(v[4])=V_DATE then db:=IncSecond(v[4],-1);
                end;
                continue;
              end;
              V_STRING: part:=v[1];
            else part:='';
            end;
            if IsNil(v[2]) then avk:=nil
            else begin
              CopyFromVar(avk,v[2]); j:=0;
              while j<=high(avk) do
                if ArrIntMatch(MyVarType(avk[j],true),[V_FLOAT,V_STRING]) then Inc(j) else ArrDel(avk,j);
            end;
            if MyVarType(v[3])=varArray then begin
              s:='';
              for j:=VarArrayLowBound(v[3],1) to VarArrayHighBound(v[3],1) do begin
                IncD(s,CRLF);
                if MyVarType(v[3][j])=V_STRING then IncD(s,v[3][j]);
              end;
              v[3]:=Copy(s,lCRLF1,MaxInt);
            end;
            if MyVarType(v[3])=V_STRING then txt:=v[3] else txt:='';
            Inc(i);
          end;
        end;
        SetLength(a^,i);
        if (i>0) and (pi>=0) then begin
          HelpEval(fi,pi,@ai); j:=high(a^); d1:=DateEmpty; d2:=PartDate(a^,j);
          for i:=high(ai) downto low(ai) do begin
            di:=PartDate(ai,i);
            while not InRange(di,d1,d2) and (j>low(a^)) do begin
              d1:=IncSecond(d2,-1); Dec(j); d2:=PartDate(a^,j);
            end;
            if InRange(di,max(db,d1),d2) then IncD(a^[j].txt,ai[i].txt);
          end;
        end;
      end;
    end;
  else a^:=nil;
  end;
  DelStack;
end;

procedure HelpEval(nFile,nPage: longint; a: PHelpArr; const Prm: variant); overload;
var s: string;
  result: variant;
begin
  AddStack('FHelpLs.HelpEval(Fml)');
  s:=aFile[nFile].lsPage.Value[nPage];
  if empty(s)
    then result:=null
  else if not EvalStringsChk(result,[Prm],s,'Формула заполнения страницы помощи','A')
    then result:=null;
  HelpVar2Arr(result,a,nFile);
  DelStack;
end;

procedure HelpEval(nFile,nPage: longint; a: PHelpArr);
begin
  HelpEval(nFile,nPage,a,null);
end;

function HelpReBoldStr(const st: string): string;
var hmNul: THelpMemo;
begin
  hmNul:=nil; result:=hmNul.ReBoldStr(st,false);
end;

function HelpMapFind(help: longint; var nFile: longint; var nmPage: string): boolean;
begin
  AddStack('FHelpLs.HelpMapFind');
  result:=false; nFile:=high(aFile);
  while nFile>=low(aFile) do
    if aFile[nFile].lsMap.FindValue(help,nmPage) then begin
      result:=true; break;
    end
    else Dec(nFile);
  DelStack;
end;

function HelpIsPage(const nmPage,nmFile: string): boolean;
var nFile,nPage: longint;
begin
  AddStack('FHelpLs.HelpIsPage');
  result:=false;
  if THelpLs.FileFind(ReplVar(nmFile,HelpBaseFile),nFile) then with aFile[nFile].lsPage do
    if Find(nmPage,nPage) then result := not empty(Value[nPage]);
  DelStack;
end;

function HelpLinkProc(Vid: THelpLinkList; Oper: THelpLinkOper; const name: string; p: pointer): boolean;
var i: longint;
  ps: PString;
  pArr: PHelpArr;
begin
  AddStack('FHelpLs.HelpLinkProc');
  ps:=nil; pArr:=nil;
  case Oper of
    hlpLinkTrns: begin
      ps:=p; ps^:='';
    end;
    hlpLinkAdd: pArr:=p;
  end;
  i:=Length(aHelpLinkProc); result := i>0;
  if result then begin
    for i:=0 to i-1 do aHelpLinkProc[i](Vid,Oper,name,p);
    if Assigned(ps) then if ps^='' then result:=false;
    if Assigned(pArr) then if Length(pArr^)=0 then result:=false;
  end;
  DelStack;
end;

function LinkAdd(Vid: THelpLinkList; const sPage: string; pArr: PHelpArr): boolean;
var iv,iv1,iv2,ip,hp: longint;
  ht: THelpTbl;
  ap: TArrStr;
  lsg: TGetList;
  ls: TStringList;
  lsi: TIntegerList;
  s: string;
  v: variant;
  af: PArrFunc;
  av: TArrVarRec;
  fl: boolean;
begin
  AddStack('FHelpLs.LinkAdd');
  result:=false;
  case Vid of
    hlnkVar,hlnkVarVal: begin
      hp:=LsArrDynamic(AnsiUpperCase(sPage),ap,'\')-1;
      while (hp>=low(ap)) and empty(ap[hp]) do Dec(hp);
      if hp>=low(ap) then begin
        ip:=low(ap); iv1:=0; iv2:=0; TInter.GetVar(av,'',[ivtVar]);
        for iv:=low(av) to high(av) do with av[iv] do
          if StrToChar(name)='$' then begin
            if AnsiUpperCase(hint)=ap[ip] then
              if ip=hp then begin
                iv1:=iv+1; iv2:=Length(av); result:=true;
              end
              else Inc(ip)
            else if result then begin
              iv2:=iv; break;
            end;
          end;
        if result then begin
          ht.Head:=av[iv1-1].hint; SetLength(ht.Dat,iv2-iv1);
          // Variable might not have been initialized
          ls:=nil; lsi:=nil;
          case Vid of
            hlnkVar: ls:=SortStrListCreate;
            hlnkVarVal: lsi:=TIntegerList.Create([ilsSorted]);
          end;
          try
            for iv:=iv1 to iv2-1 do with av[iv] do
              case Vid of
                hlnkVar: ls.AddObject(name,pointer(iv));
                hlnkVarVal: lsi.Add(longint(proc(null,index,false)),iv)
              end;
            for ip:=low(ht.Dat) to high(ht.Dat) do begin
              SetLength(ht.Dat[ip],2);
              case Vid of
                hlnkVar: begin
                  iv:=IntObj(ls,ip); fl := TInter.GetVarHelp(av[iv]).hlpfile='';
                  if fl then begin
                    TInter.HelpFile(av[iv]); // для шаблонов, например ПМТБЛ_...
                    fl := TInter.GetVarHelp(av[iv]).hlpfile='';
                  end;
                  if fl
                    then ht.Dat[ip,0]:=HelpBoldStr(ls[ip])
                  else with TInter.HelpFile(av[iv]) do begin
                    hp:=Int0(sFile);
                    if hp=0
                    then ht.Dat[ip,0]:=HelpBoldStr(ls[ip],sPage,sFile)
                    else ht.Dat[ip,0]:=HelpBoldStr(ls[ip],sPage,THelpLinkList(hp));
                  end;
                end;
                hlnkVarVal: begin
                  iv:=lsi.IntObj(ip); ht.Dat[ip,0]:=HelpBoldStr(IntToStr(lsi[ip]));
                end;
              end;
              ht.Dat[ip,1]:=av[iv].hint;
            end;
          finally
            ls.Free; lsi.Free;
          end;
        end;
      end;
    end;
    hlnkTbl: if HelpStr2Tbl(sPage,ht) then result:=true;
    hlnkGet: begin
      lsg:=TGetList.Create;
      try
        if lsg.Count>0 then
          if sPage='' then begin
            result:=true; ht.Head:='Параметры видов ввода'; SetLength(ht.Dat,lsg.Count);
            for iv:=low(ht.Dat) to high(ht.Dat) do
              CopyFrom(ht.Dat[iv],HelpBoldStr(lsg[iv],lsg.MaskHelp(iv).hf));
          end
          else if lsg.Find(sPage,iv) then with lsg.MaskHelp(iv) do
            if InRange(hf,Vid) then LinkAdd(Vid,hf.sPage,pArr);
      finally
        lsg.Free;
      end;
    end;
    hlnkTblFix: begin
      s:=sPage; ip:=Pos('\',s); ht.Head:=System.Copy(s,ip+1,MaxInt); SetLength(s,ip-1);
      v:=HelpTblArr(s);
      if MyVarType(v)=varArray then begin
        result:=true; iv2:=VarArrayLowBound(v,1); SetLength(ht.Dat,VarArrayHighBound(v,1)-iv2+1); ip:=0;
        for iv1:=low(ht.Dat) to high(ht.Dat) do begin
          iv:=MyVarType(v[iv2]);
          if iv=varString then begin
            CopyFrom(ht.Dat[ip],[HelpBoldStr(IntToStr(iv2)),v[iv2]]); Inc(ip);
          end
          else if iv=varArray then begin
            iv:=VarArrayLowBound(v[iv2],1);
            if MyVarType(v[iv2][iv])=varString then begin
              CopyFromVar(ht.Dat[ip],v[iv2]); Inc(ip);
            end
            else ht.Dat0:=v[iv2][iv+1];
          end;
          Inc(iv2);
        end;
        SetLength(ht.Dat,ip);
      end;
    end;
    hlnkLinkObj: begin
      TWinControl(Int0(sPage)).Perform(WM_HELPFILL,byte(hlpAdd),Longint(pArr));
      if Length(pArr^)>0 then result:=true;
    end;
    hlnkFuncPart: begin
      result:=true; hp:=TInter.GetFunction(af); iv:=Int0(sPage); ht.Head:=TransPrim(af[iv].hint);
      ls:=TStringList.Create;
      try
        for iv:=iv+1 to hp do with af[iv] do
          if name='' then break
          else if not FirstEngChar(name) then ls.AddObject(name,pointer(iv));
        ls.Sorted:=true; iv:=ls.Count; SetLength(ht.Dat,iv);
        for iv:=0 to iv-1 do begin
          hp:=IntObj(ls,iv);
          with af[hp] do begin
            THelpLs.FileFind(hlpfile,iv1);
            with aFile[iv1] do if help=0 then begin
              s:=TInter.HelpFile(af[hp]).sPage;
              with lsPage do if Find(s,iv2) then fl := not empty(Value[iv2]) else fl:=false;
              if fl then s:=HelpBoldStr(name,s,hlpfile) else s:=HelpBoldStr(name);
            end
            else s:=HelpBoldStr(name,lsMap.FindValue(help),hlpfile);
            CopyFrom(ht.Dat[iv],[s,TransPrim(hint)]);
          end;
        end;
      finally
        ls.Free;
      end;
    end;
  end;
  if HelpLinkProc(Vid,hlpLinkAdd,sPage,pArr) then result:=true;
  if result then result:=HelpTbl2Arr(ht,pArr);
  DelStack;
end;

function FindFml(tw: TWinControl; var nFile,nPage: longint; a: PHelpArr; hl: PHelpLinkList): boolean;
var f: THelpFileContext;
  i,h: longint;
  fl,lLink: boolean;
  v: variant;
  hi: THelpInfo;
  av: THelpArr;
  Vid: THelpLinkList;
  hf: THelpFileList;
begin
  AddStack('FHelpLs.FindFml');
  result:=false; lLink:=false; f.lEdit:=not Assigned(a);
  if not f.lEdit then a^:=nil;
  repeat
    ZeroMemory(@hi,SizeOf(hi)); hi.cbSize:=SizeOf(hi); hi.iContextType:=HELPINFO_WINDOW;
    tw.Perform(WM_HELP,0,longint(@hi));
    for hf:=low(f.f) to high(f.f) do rHelpFile(f.f[hf]);
    f.Prm:=null;
    fl:=boolean(tw.Perform(WM_HELPFILL,byte(hlpFile),Longint(@f)));
    if fl then begin
      AnsiUpperCaseSelf(f.f[hlpfBase].sFile); h:=0;
      if f.lEdit then CurHelpFile:=f.f;
    end
    else begin
      h:=tw.HelpContext; fl := h>0;
    end;
    if fl then begin
      nFile:=high(aFile);
      while nFile>=low(aFile) do with aFile[nFile] do begin
        if h>0
        then result:=lsMap.FindValue(h,f.f[hlpfBase].sPage)
        else result := f.f[hlpfBase].sFile=nmf;
        if result then begin
          lsPage.IgnoreFindAdd(f.f[hlpfBase].sPage,nPage);
          if not f.lEdit and not lLink then HelpEval(nFile,nPage,a,f.Prm);
          break;
        end;
        Dec(nFile);
      end;
      if not result then if Assigned(hl) then if InRange(f.f[hlpfBase],Vid) then begin
        result:=LinkAdd(Vid,f.f[hlpfBase].sPage,a); lLink:=true;
      end;
    end
    else nFile:=NegDef;
    if not f.lEdit then begin
      if boolean(tw.Perform(WM_HELPFILL,byte(hlpVar),Longint(@v))) then result:=true else v:=null;
      if result then begin
        HelpVar2Arr(v,@av); h:=Length(a^); SetLength(a^,h+Length(av));
        for i:=low(av) to high(av) do begin
          a^[h]:=av[i]; Inc(h);
        end;
      end;
      tw.Perform(WM_HELPFILL,byte(hlpTrns),Longint(a));
    end;
    ParentSelf(tw);
  until not Assigned(tw) or result;
  if not result then nFile:=NegDef;
  DelStack;
end;

const
  aFindKey: array[TFindOper] of record
    k: longint;
    c: string;
  end =
  ((k:K_Alt_6 ; c:'Поиск по содержимому')
  ,(k:K_Ctrl_6; c:'Поиск по формулам')
  );

procedure FindSetKey(KeyLb1: TKeyLb; ProcKey: TKeyProc);
var i: TFindOper;
begin
  AddStack('FHelpLs.FindSetKey');
  for i:=low(aFindKey) to high(aFindKey) do with aFindKey[i] do
    KeyLb1.SetKey(k,c,'',ProcKey,'findcont',kmFile,IfThen(i=fndAlg,PrivDesign));
  DelStack;
end;

function NoKeyFind(Key: longint; prf: TPrFind; opt: TFindOptions): boolean;
begin
  AddStack('FHelpLs.NoKeyFind');
  result:=true; FindOper:=low(aFindKey);
  while FindOper<=high(aFindKey) do with aFindKey[FindOper] do
    if k=Key then begin
      try
        if WinFind(nil,prf,opt,c) then if Length(aFind)>0
        then ListF2Down(lsFind.Text,nil,nil,0,'Browl',TKeyLb.GetKeySt(K_Enter,'Просмотр','',kmList)
          +IfThen(FindOper=fndAlg,CRLF+TKeyLb.GetKeySt(K_F5,'Редактировать','',kmList))
          ,THelpLs.FindProcKey,0,nil,nil,nil,nil,nil,'Найдено: "'+Trim(TFind.LastViewForm.ES.VarValue)+'"',false);
      finally
        FreeAndNil(lsFind); aFind:=nil;
      end;
      result:=false; break;
    end
    else Inc(FindOper);
  DelStack;
end;

function FindCont(const a: THelpArr; i: longint; const sf: string): boolean;
begin
  AddStack('FHelpLs.FindCont');
  if FindInStr(a[i].part,sf) then result:=true else result:=FindInStr(HelpReBoldStr(a[i].txt),sf);
  DelStack;
end;

function c_file(var av: array of variant):variant;
begin
  AddStack('FHelpLs.c_file');
  with CurHelpFile[THelpFileList(av[1])] do result:=ArrVarToVar([sFile,sPage]);
  DelStack;
end;

{ THelpMemo }
constructor THelpMemo.CreateParent;
var fl: boolean;
  i: THelpStyleList;
begin
  AddStack('THelpMemo.Create',Self);
  inherited CreateParent(AOwner,AParent);
  for fl:=false to true do with PropDef[fl] do begin
    with aFont[SCE_OURLIB_HELP_PART] do begin
      ForeColor:=clBlue; FontStylesCng:=true; Include(FontStyles,fsBold);
    end;
    with aFont[SCE_OURLIB_HELP_HEAD] do begin
      ForeColor:=clMaroon; FontStylesCng:=true; Include(FontStyles,fsBold);
    end;
    with aFont[SCE_OURLIB_HELP_BOLD] do begin
      FontStylesCng:=true; Include(FontStyles,fsBold);
    end;
    aFont[SCE_OURLIB_HELP_PRIM].ForeColor:=clGray;
    with aFont[SCE_OURLIB_HELP_LINK] do begin
      ForeColor:=clGreen; FontStylesCng:=true; Include(FontStyles,fsUnderline);
    end;
  end;
  CngFont:=nil;
  for i:=low(aHelpStyle) to high(aHelpStyle) do with aHelpStyle[i] do
    if nm<>'' then PropFontAdd(nm,i);
  if IsSci then Sci.LanguageManager.LanguageList[0].Lexer:=cContainerLexer;
  lsLink:=TIntegerList.Create; SetLength(aLink,10);
  KeyLb:=FormKeyLb(Control);
  DelStack;
end;

destructor THelpMemo.Destroy;
begin
  AddStack('THelpMemo.Destroy');
  lsLink.Free;
  inherited Destroy;
  DelStack;
end;

procedure THelpMemo.Notification;
begin
  AddStack('THelpMemo.Notification',Self);
  FormKeyLb(Control,KeyLb,AComponent,Operation);
  DelStack;
end;

procedure THelpMemo.SetText;
begin
  AddStack('THelpMemo.SetText',Self);
  inherited SetText(ReBoldStr(v,true));
  DelStack;
end;

function THelpMemo.ReBoldStr;
var s: string;
  j: longint;
  function GetStr(lDel: boolean = true): string;
  var oj,l: longint;
  begin
    AddStack('THelpMemo.SetText.GetStr',Self);
    oj:=j; j:=PosEx(cBoldDlm,s,j); l:=j-oj; result:=System.Copy(s,oj,l);
    if lDel then begin
      Delete(s,oj,l+1); j:=oj;
    end
    else Delete(s,j,1);
    DelStack;
  end;
var i,k,l: longint;
  al: THelpStyleInt;
  ph: ^THelpFile;
  s1,s2: string;
  Vid: THelpLinkList;
  f: THelpFile;
  lsf,lso: TStringList;
  af: PArrFunc;
  ao: TArrOper;
  vh: PVarHelp;
label lend;
begin
  AddStack('THelpMemo.ReBoldStr',Self);
  if FillLink then begin
    for i:=low(aStyle) to high(aStyle) do begin
      SetLength(aStyle[i],10); al[i]:=0;
    end;
    lsLink.SetOption(ilsSorted,false); lsLink.Clear; ph:=nil;
  end
  else New(ph);
  lsf:=nil; lso:=nil; 
  try
    s:=st; j:=1;
    while j<=Length(s) do begin
      i:=SCE_OURLIB_HELP_BEG+Ord(s[j])-1;
      if i in [SCE_OURLIB_HELP_BEG..SCE_OURLIB_HELP_END] then begin
        if FillLink then begin
          if Length(aStyle[i])=al[i] then SetLength(aStyle[i],al[i] shl 1);
          aStyle[i,al[i]].p:=j-1;
        end;
        Delete(s,j,1); s1:=GetStr(false);
        if FillLink then aStyle[i,al[i]].l:=Length(s1);
        if i=SCE_OURLIB_HELP_LINK then begin
          if FillLink then begin
            l:=lsLink.Count;
            if Length(aLink)=l then SetLength(aLink,l shl 1);
            lsLink.Add(aStyle[i,al[i]].p,l); ph:=@aLink[l];
          end;
          ph.sFile:=GetStr; ph.sPage:=GetStr;
          if InRange(ph^,Vid) then begin
            f.sFile:=''; l:=0;
            case Vid of
              hlnkInterMemo: begin
                s1:=ph.sPage;
                if TInterMemo.IdentInPos(s2,s1,0,' ',false,@k) then begin
                  TrimUpperSelf(s2);
                  if StrToChar(TrimLeft(System.Copy(s1,k,MaxInt)))='(' then begin
                    if not Assigned(lsf) then begin
                      lsf:=SortStrListCreate; k:=TInter.GetFunction(af); lsf.Capacity:=k;
                      for k:=1 to k do lsf.Objects[lsf.Add(af[k].name)]:=pointer(k);
                    end;
                    if IntObjFind(lsf,s2,k) then begin
                      l:=af[k].help; f:=TInter.HelpFile(af[k]); goto lend;
                    end;
                  end;
                  if not Assigned(lso) then begin
                    lso:=SortStrListCreate; Tinter.GetOperator(ao,k); lso.Capacity:=k;
                    for k:=1 to k do lso.Objects[lso.Add(ao[k].name)]:=pointer(k);
                  end;
                  if IntObjFind(lso,s2,k) then begin
                    l:=ao[k].help; f:=TInter.HelpFile(ao[k]); goto lend;
                  end;
                  if TInter.GetVarHelp(s2,vh) then begin
                    l:=vh.help; f:=TInter.HelpFile(s2); goto lend;
                  end;
                end;
              end;
              hlnkDfrm: s2:=ph.sPage;
            else s2:='';
            end;
            if HelpLinkProc(Vid,hlpLinkTrns,s2,@s1) then begin
              rHelpFile(f,Vid,s1); goto lend;
            end;
lend:
            k:=-1;
            if l=0 then begin
              if THelpLs.FileFind(f.sFile,k) then s2:=f.sPage
              else if InRange(f,Vid) then begin
                ph.sFile:=cBoldVid+f.sFile; ph.sPage:=f.sPage;
              end;
            end
            else HelpMapFind(l,k,s2);
            if k>=0 then begin
              ph.sFile:=aFile[k].nmf; ph.sPage:=s2;
            end;
          end;
        end;
        Inc(al[i]);
      end
      else Inc(j);
    end;
    if FillLink then begin
      lsLink.SetOption(ilsSorted,true);
      for i:=low(aStyle) to high(aStyle) do SetLength(aStyle[i],al[i]);
    end;
    result:=s;
  finally
    lsf.Free; lso.Free;
    if not FillLink then Dispose(ph);
  end;
  DelStack;
end;

procedure THelpMemo.doSciStyleNeeded;
var i: THelpStyleList;
  j: longint;
begin
  AddStack('THelpMemo.doSciStyleNeeded',Self);
  inherited doSciStyleNeeded(position);
  for i:=low(aStyle) to high(aStyle) do
    for j:=low(aStyle[i]) to high(aStyle[i]) do with Sci,aStyle[i,j] do begin
      StartStyling(p,31); SetStyling(l,i);
    end;
  DelStack;
end;

procedure THelpMemo.MouseMove;
var v: THelpLinkList;
begin
  AddStack('THelpMemo.MouseMove',Self);
  inherited MouseMove(Shift,X,Y);
  if FindLink(true,v,PositionFromPoint(X,Y)) then begin
    with rf[true] do Status.SectLeft[2]:=IfThen(v=hlnkLink,'Файл '+sFile+', страница '+sPage+': ')+'щелчок мыши - переход'
      +IfThen((v=hlnkLink) and CanPriv(PrivDesign),', <Alt>+щелчок мыши - редактирование');
    if IsSci then Sci.SetCursor(0) else NoSci.Cursor:=crHandPoint;
  end
  else begin
    Status.SectLeft[2]:='';
    if IsSci then Sci.SetCursor(SC_CURSORNORMAL) else NoSci.Cursor:=crDefault;
  end;
  DelStack;
end;

procedure THelpMemo.MouseUp;
var v: THelpLinkList;
begin
  AddStack('THelpMemo.MouseUp',Self);
  inherited MouseUp(Button,Shift,X,Y);
  if IsLink(true,v) then begin
    fMouse:=true;
    if CanPriv(PrivDesign) and (ssAlt in Shift) then begin
      if v=hlnkLink then THelpLs.Edit(Control);
    end
    else THelpLs.Execute(Control);
    fMouse:=false;
  end;
  DelStack;
end;

procedure THelpMemo.WMHelpFill;
var Vid: THelpLinkList;
label lend;
begin
  AddStack('THelpMemo.WMHelpFill',Self);
  if IsLink(fMouse,Vid) then with Msg do case Oper of
    hlpFile: if Vid=hlnkLink then begin
      pFile.f[hlpfBase]:=rf[fMouse]; ResFile:=true;
    end;
    hlpTrns: begin
      ResFile:=LinkAdd(Vid,rf[fMouse].sPage,pArr);
      goto lend;
    end;
  end;
  inherited;
lend:
  DelStack;
end;

procedure THelpMemo.DoMoveCaret;
begin
  AddStack('THelpMemo.DoMoveCaret',Self);
  inherited DoMoveCaret(oldCaret,newCaret);
  SetKeyLink;
  DelStack;
end;

procedure THelpMemo.SetKeyLink;
var v: THelpLinkList;
begin
  AddStack('THelpMemo.SetKeyLink',Self);
  if FindLink(false,v,GetCurrentPos) then begin
    if Focused then if Assigned(KeyLb) then KeyLb.SetKey(K_Enter,'','',ProcKey,'helplink',kmHelp,'',K_F1);
  end
  else if Assigned(KeyLb) then KeyLb.DelKey(K_All,'helplink');
  DelStack;
end;

function THelpMemo.FindLink;
var i: longint;
begin
  AddStack('THelpMemo.FindLink',Self);
  with rf[fMouse] do begin
    sFile:='';
    if not lsLink.Find(Pos,i) then Dec(i);
    if InRange(i,0,lsLink.Count-1) then
      if InRange(Pos,lsLink[i],lsLink[i]+aStyle[SCE_OURLIB_HELP_LINK,i].l{-1}) then begin
        rf[fMouse]:=aLink[lsLink.IntObj(i)];
        if sFile='' then
          if CurFile=NegDef then sFile:=HelpBaseFile else sFile:=aFile[CurFile].nmf;
      end;
  end;
  result:=IsLink(fMouse,Vid);
  DelStack;
end;

function THelpMemo.IsLink;
begin
  AddStack('THelpMemo.IsLink',Self);
  result:=false;
  with rf[fMouse] do if sFile<>'' then
    if StrToChar(sFile)=cBoldVid then result:=InRange(rf[fMouse],Vid)
    else begin
      result:=true; Vid:=hlnkLink;
    end;
  DelStack;
end;

procedure THelpMemo.AfterEnter;
begin
  AddStack('THelpMemo.AfterEnter',Self);
  inherited AfterEnter;
  SetKeyLink;
  DelStack;
end;

procedure THelpMemo.AfterExit;
begin
  AddStack('THelpMemo.AfterExit',Self);
  inherited AfterExit;
  if Assigned(KeyLb) then KeyLb.DelKey(K_All,'helplink');
  DelStack;
end;

procedure THelpMemo.ProcKey;
begin
  AddStack('THelpMemo.ProcKey',Self);
  if Assigned(KeyLb) then KeyLb.ExecKey(K_F1);
  DelStack;
end;

{ THelpLs }
procedure PrLoad(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
begin
  AddStack('FHelpLs.PrLoad');
  StringListVar(av[0]).Add(FileWithoutExt(FileWithoutExt(sr.Name)));
  DelStack;
end;

procedure HelpLsLoad;
var i,j: longint;
  ls: TStringList;
  f: TFileBuf;
  s: string;
  a: array[1..2] of string;
  NoComment: boolean;
begin
  AddStack('FHelpLs.HelpLsLoad');
  ls:=SortStrListCreate;
  try
    MaskFilesProc(ExeDir+'*'+MapExt,PrLoad,[longint(ls)]);
    MaskFilesProc(ExeDir+'*'+FmlExt,PrLoad,[longint(ls)]);
    SetLength(aFile,ls.Count);
    for i:=low(aFile) to high(aFile) do with aFile[i] do begin
      nmf:=AnsiUpperCase(ls[i]);
      lsMap:=TIntStrList.Create([ilsUnSigned]); f:=TFileBuf.Create(ExeDir+ls[i]+MapExt);
      try
        if f.Active then while not f.Eof and f.ReadString(s,rdtoChar) do begin
          LsArrFill(s,a,'='); lsMap.Add(Int0(a[2]),Trim(a[1]));
        end;
      finally
        f.Free;
      end;
      lsMap.SetOption(ilsSorted,true); j:=-1; NoComment:=true;
      lsPage:=TStrStrList.Create(false); f:=TFileBuf.Create(ExeDir+nmf+FmlExt);
      try
        if f.Active then while not f.Eof and f.ReadString(s,rdtoChar) do begin
          if (StrToChar(s)=DlmBeg) and NoComment
          then lsPage.IgnoreFindAdd(Trim(SubStr(Trim(s),2,-1)),j)
          else begin
            if j>=0 then lsPage.Value[j]:=lsPage.Value[j]+s+CRLF;
            if NoComment then begin
              if AnsiStartsStr('/*',TrimLeft(s)) then NoComment:=false;
            end
            else if AnsiEndsStr('*/',TrimRight(s)) then NoComment:=true;
          end;
        end;
      finally
        f.Free;
      end;
      lsPage.Sorted:=true;
    end;
    with lsFuncPart do if not Sorted then begin
      for i:=0 to Count-1 do Strings[i]:=GetName(Objects[i]);
      Sorted:=true;
    end;
  finally
    ls.Free;
  end;
  DelStack;
end;

class procedure THelpLs.Edit(tw: TWinControl);
var nFile,nPage: longint;
  hf: THelpFileArr;
begin
  AddStack('THelpLs.Edit(tw)');
  hf:=CurHelpFile;
  if FindFml(tw,nFile,nPage,nil,nil) then Edit(nFile,nPage);
  CurHelpFile:=hf;
  DelStack;
end;

class procedure THelpLs.Edit(const nmPage,nmFile: string);
var nFile: longint;
begin
  AddStack('THelpLs.Edit(nmPage,nmFile)');
  if FileFind(nmFile,nFile) then Edit(nFile,nmPage);
  DelStack;
end;

class procedure THelpLs.Edit(nFile: longint; const nmPage: string);
var nPage: longint;
begin
  AddStack('THelpLs.Edit(nFile,nmPage)');
  aFile[nFile].lsPage.IgnoreFindAdd(nmPage,nPage); Edit(nFile,nPage);
  DelStack;
end;

class procedure THelpLs.Edit(nFile,nPage: longint;
  crStart: longint = 0; crLen: longint = 0);
var f: TFileBuf;
  s,txt: string;
begin
  AddStack('THelpLs.Edit');
  with aFile[nFile] do begin
    s:=lsPage.Value[nPage];
    if EdTextExec('Файл: '+nmf+', страница: '+lsPage[nPage],s,
    '',nil,[],edtpHelp,crStart,crLen,'',HelpFromHelp) then begin
      lsPage.Value[nPage]:=s; f:=TFileBuf.Create(ExeDir+nmf+FmlExt,true);
      try
        txt:=f.ErrorMessage;
        if txt='' then for nPage:=0 to lsPage.Count-1 do begin
          s:=TrimRight(lsPage.Value[nPage]);
          if s<>'' then if not f.WriteString(DlmBeg+lsPage[nPage]+DlmEnd+CRLF+s,[wrCrlf]) then begin
            txt:='Ошибка записи в файл'; break;
          end;
        end;
      finally
        f.Free;
      end;
      if txt<>'' then mess_ok([txt,'Необходимо устранить причину ошибки,',
        'затем повторно вызвать редактирование формулы страницы помощи',
        'и выйти с сохранением из редактирования.']);
    end;
  end;
  DelStack;
end;

type
  TLinkArr = array of record
    s,sPart: string;
  end;

procedure ControlAdd(Sender: TControl; const av: array of variant; var Done: boolean);
var ls: TList;
  a: PHelpArr;
  alnk: ^TLinkArr;
  txt: string;
  i: longint;
begin
  AddStack('FHelpLs.ControlAdd');
  a:=PointerVar(av[2]);
  if Sender.Perform(WM_HELPFILL,byte(hlpFillType),Longint(a))=av[0] then begin
    ls:=PointerVar(av[1]);
    if ls.IndexOf(Sender)<0 then begin
      ls.Add(Sender); alnk:=PointerVar(av[3]); txt:='';
      if Length(a^)>0 then Sender.Perform(WM_HELPFILL,byte(hlpLinkObj),Longint(@txt));
      if txt='' then Sender.Perform(WM_HELPFILL,byte(hlpAdd),Longint(a))
      else begin
        i:=Length(alnk^); SetLength(alnk^,i+1);
        with alnk^[i] do begin
          s:=txt; sPart:=Int2Str(Sender);
        end;
      end;
    end;
  end;
  DelStack;
end;

class procedure THelpLs.Execute(tw: TWinControl);
var nFile,i,j: longint;
  ls: TList;
  a: THelpArr;
  alnk: TLinkArr;
  av: TArrVar;
  v: THelpLinkList;
  fl: boolean;
  tw1: TWinControl;
  f: TCustomForm;
  s: string;
  al: array[1..2] of string;
begin
  AddStack('THelpLs.Execute(tw)');
  if tw.Owner is THelpMemo then with THelpMemo(tw.Owner) do fl:=not IsLink(fMouse,v) else fl:=true;
  IntLastError:=E_NO; FindFml(tw,nFile,i,@a,@v);
  if fl then begin
    ls:=TList.Create;
    try
      tw1:=tw; alnk:=nil; CopyFromVArr(av,[hlpftBefore,longint(ls),longint(@a),longint(@alnk)]);
      f:=GetParentForm(tw); ProcControls(f,ControlAdd,av);
      av[0]:=hlpftDefault;
      while Assigned(tw1) do begin
        ControlAdd(tw1,av,fl); ParentSelf(tw1);
      end;
      av[0]:=hlpftAfter; ProcControls(f,ControlAdd,av);
    finally
      ls.Free;
    end;
    fl:=true;
    if Length(a)=1 then if StrToChar(a[0].part)=Chr(SCE_OURLIB_HELP_LINK-SCE_OURLIB_HELP_BEG+1) then begin
      LsArrFill(a[0].part,al,cBoldDlm); Delete(al[1],1,1);
      if StrToChar(al[2])=cBoldVid then begin
        i:=Int0(Copy(al[2],2,MaxInt));
        if InRange(i,byte(low(THelpLinkList)),byte(high(THelpLinkList))) then begin
          v:=THelpLinkList(i);
          if v=hlnkLink then begin
            Execute(al[1]); a:=nil; fl:=false;
          end
          else if HelpLinkProc(v,hlpLinkTrns,al[1],@s) then begin
            HelpLinkProc(v,hlpLinkAdd,s,@a); fl:=false;
          end;
        end;
      end;
    end;
    if fl then begin
      i:=Length(alnk);
      if i>0 then begin
        j:=Length(a);
        with a[j-1] do begin
          while Length(txt)>0 do
            if not RightSelfDel(txt,CRLF) then break;
          IncD(txt,DupeString(CRLF,2));
        end;
        SetLength(a,j+1);
        with a[j] do begin
          part:='См. также'; avk:=nil;
          if i=1
          then with alnk[0] do txt:=' '+HelpBoldStr(s,sPart,hlnkLinkObj)+'.'
          else begin
            txt:='';
            for i:=0 to i-1 do with alnk[i] do
              IncD(txt,CRLF+HelpBoldStr(FRup(s),sPart,hlnkLinkObj));
          end;
        end;
      end;
    end;
  end;
  Execute(a,nFile,tw);
  DelStack;
end;

class procedure THelpLs.Execute(const nmPage: string; nFile: longint = NegDef; PrShow: TNotifyEvent = nil);
var nPage: longint;
  a: THelpArr;
begin
  AddStack('THelpLs.Execute(page)');
  if ReplNegSelf(nFile,high(aFile))
  then while nFile>=0 do if aFile[nFile].lsPage.Find(nmPage,nPage) then break else Dec(nFile)
  else nPage:=aFile[nFile].lsPage.IndexOf(nmPage);
  if (nFile<>NegDef) and (nPage<>NegDef) then begin
    IntLastError:=E_NO; HelpEval(nFile,nPage,@a); Execute(a,nFile,nil,PrShow);
  end;
  DelStack;
end;

class procedure THelpLs.Execute(const nmPage,nmFile: string);
var nFile: longint;
begin
  AddStack('THelpLs.Execute(file)');
  if FileFind(nmFile,nFile) then Execute(nmPage,nFile);
  DelStack;
end;

class procedure THelpLs.Execute(const a: THelpArr; nFile: longint = NegDef;
  tw: TWinControl = nil; PrShow: TNotifyEvent = nil; PrHide: TNotifyEvent = nil);
var i,n,ss,sl: longint;
  txt,s: string;
  at: TArrStr;
begin
  AddStack('THelpLs.Execute');
  if (Length(a)>0) and (IntLastError=E_NO) then begin
    Inc(nHelpLs);
    if Length(aHelpLs)=nHelpLs then SetLength(aHelpLs,nHelpLs+1);
    CreateForm(THelpLs,aHelpLs[nHelpLs]);
    try
      with aHelpLs[nHelpLs] do begin
        lsPart.Items.BeginUpdate; lsPart.Items.Clear; txt:=''; ss:=0; i:=Length(a); SetLength(aLine,i);
        for i:=0 to i-1 do begin
          lsPart.Items.Add(a[i].part); aLine[i]:=ss;
          // Абзацы
          sl:=LsArrDynamic(a[i].txt,at,CRLF);
          for n:=1 to sl-1 do if at[n]<>'' then IncL(at[n],'  ');
          a[i].txt:=ArrayAsList(at,CRLF,sl,true);
          s:=TextCRLF(HelpBoldStr(a[i].part,SCE_OURLIB_HELP_PART)+a[i].txt);
          IncD(txt,s); Inc(ss,StrCount(CRLF,s));
        end;
        lsPart.Items.EndUpdate; QuickSort(aLine); Memo.SetText(txt);
        lsPart.ItemIndex:=0; ActiveControl:=Memo.Control; MainRebuild;
        Memo.ReadIdent; Memo.CurFile:=nFile; 
        IfThenNotify(PrShow,aHelpLs[nHelpLs]);
        ShowModal;
        IfThenNotify(PrHide,aHelpLs[nHelpLs]);
        lsPart.Filtered:=false; Memo.SaveIdent; Memo.Text:=TrimRight(Memo.Text);
      end;
    finally
      FormFree(aHelpLs[nHelpLs]); Dec(nHelpLs);
    end;
  end;
  DelStack;
end;

procedure THelpLs.FormCreate(Sender: TObject);
begin
  AddStack('THelpLs.FormCreate',Self);
  lsPart:=TFindListBox.Create(Self);
  with lsPart do begin
    Parent:=pnPart; BorderStyle:=bsNone; OnKeyUp:=lsPartKeyUp; OnMouseUp:=lsPartMouseUp;
  end;
  Memo:=THelpMemo.CreateParent(Self,pnMemo);
  with Memo do begin
    Status:=RbStatus1; ReadOnly:=true; WordWrapBool:=true; OnMoveCaret:=MemoMoveCaret;
  end;
  FindSetKey(KeyLb1,ProcKey);
  inherited;
  DelStack;
end;

procedure THelpLs.WMFormLimit;
var i: longint;
begin
  AddStack('THelpLs.WMFormLimit',Self);
  for i:=low(aHelpLs) to high(aHelpLs) do if FreeLimit(aHelpLs[i]) then break;
  DelStack;
end;

procedure THelpLs.WMSchem;
var ts: TSchem;
begin
  AddStack('THelpLs.WMSchem',Self);
  if msg.Oper=soAfter then
    if SchemName(pnPart.Schem,ts) then with lsPart do begin
      Color:=ts.Color1; Font.Assign(ts.Font1);
    end;
  DelStack;
end;

procedure THelpLs.pnPartSetWHMin(Sender: TObject);
var w: longint;
begin
  AddStack('THelpLs.pnPartSetWHMin',Self);
  with lsPart do begin
    Canvas.Font.Assign(Font); w:=MaxSelf(Canvas,GetTextFiltered);
  end;
  with pnPart do WMin:=w+SysMetric.iScrollWidth+2+BevPanel2;
  DelStack;
end;

procedure THelpLs.pnResize(Sender: TObject);
begin
  AddStack('THelpLs.pnResize',Self);
  with TRbPanel(Sender) do Controls[0].SetBounds(BevPanel,BevPanel,CltWidth,CltHeight);
  DelStack;
end;

procedure THelpLs.lsPartKeyUp;
begin
  AddStack('THelpLs.lsPartKeyUp',Self);
  lsPartChange;
  DelStack;
end;

procedure THelpLs.lsPartMouseUp;
begin
  AddStack('THelpLs.lsPartMouseUp',Self);
  lsPartChange;
  DelStack;
end;

procedure THelpLs.lsPartChange;
var lb: longint;
begin
  AddStack('THelpLs.lsPartChange',Self);
  with Memo do begin
    lb:=aLine[lsPart.IndexFiltered];
    CurrentLineNumber:=lb+LinesOnScreen-1;
    CurrentLineNumber:=lb;
  end;
  DelStack;
end;

procedure THelpLs.MemoMoveCaret;
var i: longint;
begin
  AddStack('THelpLs.MemoMoveCaret',Self);
  if not lsPart.Focused then begin
    if not QuickFind(i,newCaret.Line,aLine) then Dec(i);
    lsPart.IndexFiltered:=i;
  end;
  DelStack;
end;

procedure CntAdd(var result: THelpCntArr;
  clv: byte; const nm: string; const pg: string = ''; nf: longint = NegDef;
  AVid: THelpLinkList = low(THelpLinkList); const AHint: string = ''; Fix: boolean = false);
begin
  AddStack('FHelpLs.CntAdd');
  with result do begin
    if Length(a)=l then SetLength(a,l shl 1);
    with a[l] do begin
      lv:=lvbeg+clv; nFile:=nf; Vid:=AVid; anm:=NamePrimStr(TransPrim(nm),pg); hint:=TransPrim(AHint); FixPos:=Fix;
    end;
    Inc(l);
  end;
  DelStack;
end;

{function CntCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result:=AnsiCompareText(List[Index1],List[Index2]);
end;}

class procedure THelpLs.Content;
  function TreeAdd(const nmPage: string; nFile: longint; Vid: THelpLinkList): pointer;
  begin
    AddStack('THelpLs.Content.TreeAdd');
    with aHelpTree[nHelpTree] do begin
      if Length(aTree)=lTree then SetLength(aTree,lTree shl 1);
      aTree[lTree].nmPage:=nmPage; aTree[lTree].nFile:=nFile; aTree[lTree].Vid:=Vid;
      Inc(lTree); result:=pointer(lTree);
    end;
    DelStack;
  end;
var ls: TStringList;
  a: array of THelpCntArr;
  procedure Compile(i: longint);
    procedure aAdd(const a1: THelpCntArr);
    var l1: longint;
    begin
      AddStack('THelpLs.Content.Compile.aAdd');
      with a[i] do begin
        SetLength(a,Length(a)+a1.l);
        for l1:=0 to a1.l-1 do begin
          a[l]:=a1.a[l1]; Inc(l);
        end;
      end;
      DelStack;
    end;
var a1: THelpCntArr;
  procedure HelpCntSort;
  var
    ah: array of record
      h: THelpCnt;
      ls: TStringList;
    end;
    nbeg: longint;
    procedure Res(i: longint);
    var j: longint;
    begin
      AddStack('THelpLs.Content.Compile.HelpCntSort.Res');
      with ah[i] do begin
        if i>0 then begin
          a1.a[nbeg]:=h; Inc(nbeg);
        end;
        if Assigned(ls) then for j:=0 to ls.Count-1 do Res(IntObj(ls,j));
      end;
      DelStack;
    end;
  var i,l,lv,nend: longint;
    alv: TArrInt;
  begin
    AddStack('THelpLs.Content.Compile.HelpCntSort');
    nbeg:=0; nend:=a1.l; i:=nend+1; SetLength(ah,i); ZeroMemory(@ah[0],SizeOf(ah[0])*i);
    try
      SetLength(alv,1); alv[0]:=0;
      for i:=1 to nend do ah[i].h:=a1.a[nbeg+i-1];
      l:=a1.a[nbeg].lv-1;
      for i:=1 to nend do begin
        lv:=ah[i].h.lv-l;
        if Length(alv)<lv+1 then SetLength(alv,lv+1);
        alv[lv]:=i;
        StrListCreate(ah[alv[lv-1]].ls).AddObject(ah[i].h.anm[1],pointer(i));
      end;
      for i:=0 to nend do with ah[i] do if not h.FixPos and Assigned(ls) then ls.Sorted:=true;
        //ls.CustomSort(CntCompare);
      Res(0);
    finally
      for i:=0 to nend do ah[i].ls.Free;
    end;
    DelStack;
  end;
  var al: TArrStr;
    j,i1,nf: longint;
    s: string;
    ap: TNamePrimStr;
    ah: THelpArr;
  begin
    AddStack('THelpLs.Content.Compile');
    if BoolObj(ls,i) then begin
      j:=LsArrDynamic(GetStrFile(ExeDir+ls[i]),al,CRLF); SetLength(a[i].a,j); a[i].l:=0;
      if FileFind(FileWithoutExt(FileWithoutExt(ls[i])),nf) then
        for j:=0 to j-1 do begin
          s:=Trim(al[j]);
          if s<>'' then begin
            ap:=StrDivDlm(' ',s);
            if s[1]=':' then begin
              TrimUpperSelf(ap[1]);
              if ap[1]=':EXE' then begin
                if TrimUpper(ap[2])<>TrimUpper(FileWithOutExt(ExtractFileName(Application.ExeName))) then break;
              end
              else if ap[1]=':INCLUDE' then
                if ls.Find(ap[2],i1) then begin
                  Compile(i1); aAdd(a[i1]); a[i1].a:=nil; a[i1].l:=0;
                end;
            end
            else with a[i].a[a[i].l] do begin
              lv:=Int0(ap[1]); anm:=StrDivDlm('=',ap[2]);
              if StrDivDlm('.',anm[2],ap) and FileFind(ap[1],nFile) then anm[2]:=ap[2] else nFile:=nf;
              if TrimUpper(anm[1])=':INCLUDE' then begin
                a1.lvbeg:=lv;
                for i1:=low(aHelpCntProc) to high(aHelpCntProc) do begin
                  a1.l:=0; aHelpCntProc[i1](a1,anm[2],CntAdd);
                  if a1.l>0 then begin
                    HelpCntSort; aAdd(a1); break;
                  end;
                end;
              end
              else begin
                TransPrimSelf(anm[1]); hint:='';
                if StrDivDlm(':',anm[2],ap) then begin
                  if ap[2]='@HINT' then begin
                    if aFile[nFile].lsPage.Find(ap[1],i1) then begin
                      HelpEval(nFile,i1,@ah);
                      if Length(ah)>0 then hint:=HelpReBoldStr(ah[0].txt);
                    end;
                  end
                  else begin
                    Vid:=THelpLinkList(Int0(ap[2])); nFile:=NegDef;
                    if Vid=hlnkTblFix then ap[1]:=HelpTblVarName(ap[1]);
                  end;
                  anm[2]:=ap[1];
                end;
                Inc(a[i].l);
              end;
            end;
          end;
        end;
      with a[i] do SetLength(a,l);
      ls.Objects[i]:=ObjectFalse;
    end;
    DelStack;
  end;
var i,j,k,la: longint;
  atn: TArrTreeNode;
  p: pointer;
begin
  AddStack('THelpLs.Content');
  ls:=TStringList.Create;
  try
    GetMaskFiles(ls,ExeDir+'*.CNT.HLP'); ls.Sorted:=true; SetLength(a,ls.Count); InitObjects(ls,ObjectTrue);
    for i:=low(a) to high(a) do Compile(i);
    for i:=low(a) to high(a) do with a[i] do if l>0 then begin
      Inc(nHelpTree);
      if Length(aHelpTree)=nHelpTree then SetLength(aHelpTree,nHelpTree+1);
      CreateForm(THelpTree,aHelpTree[nHelpTree]);
      try
        with aHelpTree[nHelpTree] do begin
          la:=0; Tree.BeginUpdate; Tree.ClearPrim;
          for k:=0 to l-1 do with a[k] do begin
            if la<lv+1 then begin
              SetLength(atn,lv+1);
              for j:=la to lv-1 do atn[j]:=nil;
              la:=lv+1;
            end;
            if anm[2]='' then p:=nil else p:=TreeAdd(anm[2],nFile,Vid);
            atn[lv]:=Tree.AddPrim(atn[lv-1],TransPrim(anm[1]),hint,0,p);
          end;
          Tree.EndUpdate; Tree.RestFromIni('Help'); ShowModal; Tree.SaveToIni('Help');
        end;
      finally
        FormFree(aHelpTree[nHelpTree]); Dec(nHelpTree);
      end;
      break;
    end;
  finally
    ls.Free;
  end;
  DelStack;
end;

class function THelpLs.FileFind;
var s: string;
begin
  AddStack('THelpLs.FileFind');
  result:=false; s:=AnsiUpperCase(nmFile); nFile:=high(aFile);
  while nFile>=low(aFile) do
    if aFile[nFile].nmf=s then begin
      result:=true; break;
    end
    else Dec(nFile);
  DelStack;
end;

class function THelpLs.PageFind;
begin
  AddStack('THelpLs.PageFind');
  result:=false; nFile:=high(aFile);
  while nFile>=low(aFile) do
    if aFile[nFile].lsPage.IndexOf(nmPage)>=0 then begin
      result:=true; break;
    end
    else Dec(nFile);
  DelStack;
end;

procedure THelpLs.ProcKey;
begin
  AddStack('THelpLs.KeyLb1ProcKey',Self);
  NoKeyFind(Key,PrFind,[fnoRegistr,fnoWord,fnoSave]);
  DelStack;
end;

class function THelpLs.PrFind;
var nFile,nPage: longint;
  a: THelpArr;
  function aEval: boolean;
  begin
    AddStack('THelpLs.PrFind.aEval');
    IntLastError:=E_NO; HelpEval(nFile,nPage,@a); result := IntLastError=E_NO;
    DelStack;
  end;
var lf: longint;
  procedure lsAdd(j: longint);
  begin
    AddStack('THelpLs.PrFind.lsAdd');
    lsFind.AddObject(a[j].part,pointer(lf)); aFind[lf].nFile:=nFile; aFind[lf].nPage:=nPage; Inc(lf);
    DelStack;
  end;
var i,lr,j: longint;
label lend;
begin
  AddStack('THelpLs.PrFind');
  lsFind:=TStringList.Create; i:=0; lr:=0; lf:=0;
  for nFile:=low(aFile) to high(aFile) do Inc(lr,aFile[nFile].lsPage.Count);
  SetLength(aFind,lr); lsFind.Capacity:=lr;
  for nFile:=low(aFile) to high(aFile) do
    for nPage:=0 to aFile[nFile].lsPage.Count-1 do begin
      Inc(i);
      if WinFindSayStat(i/lr) then begin
        lsFind.Clear; goto lend;
      end;
      case FindOper of
        fndCont: if aEval then
          for j:=low(a) to high(a) do if FindCont(a,j,sf) then begin
            lsAdd(j); break;
          end;
        fndAlg: if FindInStr(aFile[nFile].lsPage.Value[nPage],sf) then if aEval then lsAdd(0);
      end;
    end;
lend:
  result := lsFind.Count>0;
  if result then begin
    SetLength(aFind,lf); lsFind.Duplicates:=dupAccept; lsFind.Sorted:=true;
  end;
  DelStack;
end;

class procedure THelpLs.FindProcKey;
var ss,sl: longint;
begin
  AddStack('THelpLs.FindProcKey');
  with aFind[IntObj(lsFind,TFindListBox(tw).IndexFiltered)] do case Key of
    K_F5: begin
      FindInStr(aFile[nFile].lsPage.Value[nPage],Trim(TFind.LastViewForm.RV['S']),@ss,@sl);
      THelpLs.Edit(nFile,nPage,ss-1,sl);
    end;
    K_Enter: THelpLs.Execute(aFile[nFile].lsPage[nPage],nFile,IfThenNotify(FindOper=fndCont,FindPrShow));
  end;
  DelStack;
end;

class procedure THelpLs.FindPrShow;
var f: THelpLs;
begin
  AddStack('THelpLs.FindPrShow');
  f:=pointer(Sender); TTimerOne.CreateProc(f.FindTimerShow,f);
  DelStack;
end;

procedure THelpLs.FindTimerShow;
begin
  AddStack('THelpLs.FindTimerShow',Self);
  Memo.Control.SetFocus; KeyLb1.ExecKey(K_Shift_F6);
  DelStack;
end;

function THelpLs.GetLine;
begin
  AddStack('THelpLs.GetLine',Self);
  result:=Memo.CurrentLineNumber;
  DelStack;
end;

procedure THelpLs.SetLine;
begin
  AddStack('THelpLs.SetLine',Self);
  Memo.CurrentLineNumber:=Value;
  DelStack;
end;

{ THelpEditMemo }
const aEdKey: THelpStyleInt = (0,K_Ctrl_G,K_Ctrl_B,K_Ctrl_I,0,K_Ctrl_U);

procedure THelpEditMemo.AfterEnter;
var tl: TKeyLb;
  i: THelpStyleList;
begin
  AddStack('THelpEditMemo.AfterEnter',Self);
  inherited AfterEnter;
  if FormKeyLb(Control,tl) then begin
    tl.SetKey(K_Shift_F5,'Дата','Вставить текущую дату и время',ProcKey,'helpeditmemo',kmEdit);
    for i:=low(aEdKey) to high(aEdKey) do if aEdKey[i]<>0 then
      tl.SetKey(aEdKey[i],'','Выделить шрифтом "'+aHelpStyle[i].nm+'"',ProcKey,'helpeditmemo',kmEdit);
    tl.ReDrw;
  end;
  DelStack;
end;

procedure THelpEditMemo.AfterExit;
var tl: TKeyLb;
begin
  AddStack('THelpEditMemo.AfterExit',Self);
  inherited AfterExit;
  if FormKeyLb(Control,tl) then begin
    tl.DelKey(K_All,'helpeditmemo'); tl.ReDrw;
  end;
  DelStack;
end;

class procedure THelpEditMemo.ProcKey;
var l,p: longint;
  im: TInterMemo;
  procedure SelWord;
  var p1,p2: longint;
  begin
    AddStack('THelpEditMemo.ProcKey.SelWord');
    with im do begin
      p1:=p; p2:=p1;
      while p1>=0 do
        if IsChrWord(Chr(GetCharAt(p1))) then Dec(p1) else break;
      while p2<l do
        if IsChrWord(Chr(GetCharAt(p2))) then Inc(p2) else break;
      Inc(p1);
      if p2>p1 then SetSelection(p1,p2-p1);
    end;
    DelStack;
  end;
var i: THelpStyleList;
begin
  AddStack('THelpEditMemo.ProcKey');
  im:=PointerOwner(tw);
  with im do
    if Key=K_Shift_F5 then InsText(FormatDateTime('dd.mm.yyyy hh:nn',Now))
    else for i:=low(aEdKey) to high(aEdKey) do if aEdKey[i]=Key then begin
      if SelLength=0 then begin
        l:=GetTextLength; p:=GetCurrentPos; SelWord;
        if (SelLength=0) and (p>0) then begin
          Dec(p); SelWord;
        end;
      end;
      if SelLength>0 then begin
        InsText('''+'+cHlpFunc+'('''+SelText+''''
          +IfThen(i<>SCE_OURLIB_HELP_DEF,','+IfThen(i=SCE_OURLIB_HELP_LINK,'''''',
          cHlpVarPref+aHelpStyle[i].v))+')+''');
        if i=SCE_OURLIB_HELP_LINK then SelStart:=GetCurrentPos-4;
      end;
      break;
    end;
  DelStack;
end;

{ TTreeHelp }
procedure TTreeHelp.ProcKey;
begin
  AddStack('TTreeHelp.ProcKey',Self);
  if (Key=K_Shift_F6) and FindNextHelp
  then WinFind(nil,aHelpTree[nHelpTree].PrFind,[fnoRegistr,fnoWord,fnoContinue],'Поиск по содержимому')
  else begin
    inherited ProcKey(Key,tw);
    if ArrIntMatch(key,aKeyFind) then
      if TFind.LastViewForm.ModalResult=mrOk then FindNextHelp:=false;
  end;
  DelStack;
end;

{ THelpTree }
procedure THelpTree.FormCreate;
begin
  AddStack('THelpTree.FormCreate',Self);
  Caption:='Помощь'; RbPanel2.BevelOuter:=bvNone; RbPanel2.Schem:='tree';
  Tree:=TTreeHelp.Create(Self);
  with Tree do begin
    Parent:=RbPanel2; OnChange:=TreeChange; Options:=[tpNoDopDispose];
  end;
  FindSetKey(KeyLb1,ProcKey);
  KeyLb1.SetKey(K_Ctrl_F3,'','Сравнить содержание с формулами',ProcKey,'findcont',kmFile,PrivDesign);
  inherited;
  SetLength(aTree,10);
  DelStack;
end;

procedure THelpTree.TreeChange;
var fl: boolean;
begin
  AddStack('THelpTree.TreeChange',Self);
  if Assigned(Node) then fl := nTree(Node)>=0 else fl:=false;
  if fl then begin
    KeyLb1.SetKey(K_Enter,'Просмотр','',ProcKey,'helptree',kmList);
    KeyLb1.SetKeys([K_F5,K_Alt_B],'Редактировать','',ProcKey,'helptree',kmList,PrivDesign);
  end
  else KeyLb1.DelKey(K_All,'helptree');
  KeyLb1.Redrw;
  DelStack;
end;

function THelpTree.nTree;
begin
  AddStack('THelpTree.nTree',Self);
  result:=longint(Tree.NodeInf(tn).Dop)-1;
  DelStack;
end;

procedure THelpTree.ProcKey;
  procedure lbAdd(lb: TListBox; const Cod,Name: string);
  begin
    AddStack('THelpTree.ProcKey.lbAdd',Self);
    lb.Items.Add(cod+' ('+name+')');
    DelStack;
  end;
var a: THelpArr;
  lsCnt: TStrStrList;
  tn: TTreeNode;
  i,nf,np: longint;
  sf,sp: string;
begin
  AddStack('THelpTree.ProcKey',Self);
  if NoKeyFind(Key,PrFind,[fnoRegistr,fnoWord,fnoDirection,fnoAll,fnoSave]) then with aTree[nTree(Tree.Selected)] do case Key of
    K_F5,K_Alt_B: if nFile<>NegDef then THelpLs.Edit(nFile,nmPage);
    K_Enter:
      if nFile=NegDef then begin
        LinkAdd(Vid,nmPage,@a); THelpLs.Execute(a);
      end
      else THelpLs.Execute(nmPage,nFile);
    K_Ctrl_F3: begin
      Inc(nHelpComp);
      if Length(aHelpComp)=nHelpComp then SetLength(aHelpComp,nHelpComp+1);
      lsCnt:=TStrStrList.Create(true,aHelpTree[nHelpTree].Tree.Items.Count);
      CreateForm(THelpComp,aHelpComp[nHelpTree]);
      try
        Tree.IsFirst(tn);
        while Assigned(tn) do begin
          i:=nTree(tn);
          if i>=0 then with aTree[i] do if nFile<>NegDef then lsCnt.IgnoreFindAdd(aFile[nFile].nmf+'.'+nmPage,tn.Text);
          GetNextSelf(tn);
        end;
        with aHelpComp[nHelpComp] do begin
          lbFml.Items.BeginUpdate;
          for nf:=low(aFile) to high(aFile) do begin
            sf:=aFile[nf].nmf+'.';
            with aFile[nf] do for np:=0 to lsPage.Count-1 do begin
              sp:=sf+lsPage[np];
              if not FindDel(lsCnt,sp) then begin
                HelpEval(nf,np,@a); lbAdd(lbFml,sp,a[0].part);
              end;
            end;
          end;
          lbFml.Items.EndUpdate;
          lbCnt.Items.BeginUpdate; i:=lsCnt.Count;
          while lbCnt.Items.Count<i do lbAdd(lbCnt,lsCnt[lbCnt.Items.Count],lsCnt.Value[lbCnt.Items.Count]);
          while lbCnt.Items.Count>i do lbCnt.Items.Delete(lbCnt.Items.Count-1);
          lbCnt.Items.EndUpdate;
          ShowModal;
        end;
      finally
        FormFree(aHelpComp[nHelpComp]); Dec(nHelpComp); lsCnt.Free;
      end;
    end;
  end;
  DelStack;
end;

function THelpTree.PrFind;
var tn: TTreeNode;
  i,lr: longint;
  lDown: boolean;
	procedure FindDown;
  var a: THelpArr;
    j: longint;
  label lend;
  begin
  	AddStack('THelpTree.PrFind.FindDown',Self);
    result:=true;
	  while Assigned(tn) and (tn<>Tree.Selected) do begin
      Inc(i);
      if WinFindSayStat(i/lr) then begin
        lDown:=false; break;
      end;
      j:=nTree(tn);
      if j>=0 then with aTree[j] do case FindOper of
        fndCont: begin
          IntLastError:=E_NO;
          if nFile=NegDef then LinkAdd(Vid,nmPage,@a) else HelpEval(nFile,aFile[nFile].lsPage.IndexOf(nmPage),@a);
          if IntLastError=E_NO then
            for j:=low(a) to high(a) do if FindCont(a,j,sf) then goto lend;
        end;
        fndAlg: if nFile<>NegDef then if FindInStr(aFile[nFile].lsPage.FindValue(nmPage),sf) then goto lend;
      end;
      TTreePrim.FindNext(tn);
    end;
    result:=false;
  lend:
    DelStack;
  end;
begin
  AddStack('THelpTree.PrFind',Self);
  Tree.Filtered:=false;
  if FindProperty.Direction=fndAll then result:=THelpLs.PrFind(Sender,sf)
  else begin
    result:=false; lDown:=true; i:=0; lr:=Tree.Items.Count; tn:=Tree.Selected;
    TTreePrim.FindNext(tn); FindDown;
    if lDown and not result then begin
      tn:=Tree.FindFirst(lr); FindDown;
    end;
    if result then begin
      Tree.Selected:=tn; FindNextHelp:=true;
    end;
  end;
  DelStack;
end;

procedure THelpTree.WMFormLimit;
var i: longint;
begin
  AddStack('THelpTree.WMFormLimit',Self);
  for i:=low(aHelpTree) to high(aHelpTree) do if FreeLimit(aHelpTree[i]) then break;
  DelStack;
end;

{ THelpComp }
procedure THelpComp.FormCreate;
var ts: TSchem;
  function lbCrt(const pnName,pnHead: string; prc: TProcent): TListBox;
  var pn: TRbPanel;
  begin
    AddStack('THelpComp.FormCreate.lbCrt',Self);
    pn:=TRbPanel.Create(aHelpComp[nHelpTree]);
    with pn do begin
      Parent:=aHelpComp[nHelpTree].RbPanel2; BevelOuter:=bvLowered; Name:=pnName; ProcentWnd:=prc; Header:=pnHead;
      SortObj:=false; OnResize:=pnRezise;
      result:=TListBox.Create(aHelpComp[nHelpTree]);
      with result do begin
        Parent:=pn; BorderStyle:=bsNone;
        if Assigned(ts) then begin
          Color:=ts.Color1; ParentFont:=false; Font.Assign(ts.Font1);
        end;
      end;
    end;
    DelStack;
  end;
begin
  AddStack('THelpComp.FormCreate',Self);
  Caption:='Сравнение';
  with RbPanel2 do begin
    BevelOuter:=bvNone; Place:=rpLeft; Schem:='Browl'; SchemName(Schem,ts);
    lbCnt:=lbCrt('pnCnt','Содержание',50);
    lbFml:=lbCrt('pnFml','Формулы',100);
  end;
  inherited;
  DelStack;
end;

class procedure THelpComp.pnRezise;
begin
  AddStack('THelpComp.pnRezise');
  with TRbPanel(Sender) do if ControlCount>0
  then Controls[0].SetBounds(BevPanel,BevPanel+HeaderHeight,CltWidth,CltHeight-HeaderHeight);
  DelStack;
end;

procedure THelpComp.WMFormLimit;
var i: longint;
begin
  AddStack('THelpComp.WMFormLimit',Self);
  for i:=low(aHelpComp) to high(aHelpComp) do if FreeLimit(aHelpComp[i]) then break;
  DelStack;
end;

{ TGetList }
constructor TGetList.Create;
var i,j,j1: longint;
  g: TCustomGet;
  s: string;
  mh: TMaskHelp;
begin
  AddStack('TGetList.Create');
  Duplicates:=dupAccept; Sorted:=true;
  for i:=0 to LsCustomGet.Count-1 do begin
    g:=PointerObj(LsCustomGet,i); g.MaskHelp(mh);
    if not((mh.RVid='') or (mh.hf.sPage='')) then begin
      s:=ArrayAsList([mh.RVid,mh.hf.sFile,mh.hf.sPage],UnDelim);
      if s<>'' then AddObject(s,g);
    end;
  end;
  Sorted:=false; i:=0;
  while i<Count do begin
    s:=DlmCopy(Strings[i],1,1,UnDelim); j:=i; Inc(i);
    while i<Count do
      if DlmCopy(Strings[i],1,1,UnDelim)=s then Inc(i) else break;
    if i=j+1 then Strings[j]:=s
    else while j<i do begin
      j1:=j+1;
      while j1<i do if Strings[j1]=Strings[j] then Inc(j1) else break;
      if j1=j+1 then Strings[j]:=DlmBetween(s,TCustomGet(Objects[j]).RVName,': ')
      else begin
        Strings[j]:=s;
        while j1>j+1 do begin
          Delete(j+1); Dec(j1); Dec(i);
        end;
      end;
      Inc(j);
    end;
  end;
  Sorted:=true;
  DelStack;
end;

function TGetList.MaskHelp;
begin
  AddStack('TGetList.MaskHelp');
  TCustomGet(Objects[Index]).MaskHelp(result);
  DelStack;
end;

procedure TblTrans(const s: string; const av: array of variant;
	lShapeFull: boolean; var result: varrec);
var i,j: longint;
  v: variant;
begin
	AddStack('FHelpLs.TblTrans');
  with result do begin
	  index:=s; 
    if lShapeFull then begin
      types:='A';
      for i:=low(aHelpTblProc) to high(aHelpTblProc) do begin
        aHelpTblProc[i]('',v);
        for j:=VarArrayLowBound(v,1) to VarArrayHighBound(v,1) do if v[j][0]=s then begin
          hint:=v[j][1]; break;
        end;
      end;
    end;
	end;
  DelStack;
end;

function DopGetVarEqual(const name: string; const av: array of variant): boolean;
begin
  AddStack('FHelpLs.DopGetVarEqual');
  result := (name='') or AnsiStartsStr(sHelpTblVar,name);
  DelStack;
end;

{ TNone }
class procedure TNone.DopGetVarAdd;
var i,j: longint;
  v: variant;
begin
  AddStack('TNone.DopGetVarAdd');
  if not Assigned(lsVarDop) then begin
    lsVarDop:=TVarDopList.Create;
    lsVarDop.AddDop('$'+VarBeg+iChrPrim+sHelpTblVar,'Таблицы для помощи');
    for i:=low(aHelpTblProc) to high(aHelpTblProc) do begin
      aHelpTblProc[i]('',v);
      for j:=VarArrayLowBound(v,1) to VarArrayHighBound(v,1) do lsVarDop.AddDop(sHelpTblVar+v[j][0],v[j][1],'A');
    end;
  end;
  lsVarDop.PrInterDopGetVar(ProcDopGetVarAdd);
  DelStack;
end;

class function TNone.DopGetVarIgnore;
begin
  result:=false;
end;

procedure HelpCntProc(var result: THelpCntArr; const Name: string; PrAdd: THelpCntAddProc);
  procedure InterAdd(const name,hint,pref,hlpfile: string; help: longint);
  var nFile: longint;
    a: TNamePrimStr;
    function PageFind(const pg: string): boolean;
    begin
      AddStack('FHelpLs.HelpCntProc.InterAdd');
      result := aFile[nFile].lsPage.IndexOf(pg)>=0;
      if result then a[2]:=pg;
      DelStack;
    end;
  var Vid: THelpLinkList;
    l: longint;
  begin
    AddStack('FHelpLs.HelpCntProc.InterAdd');
    if name<>'' then if not AnsiStartsStr('$',name) then begin
{if name='СТДФ_VDCF_R' then begin
a:=a;
end;}
      Vid:=low(THelpLinkList); a[1]:=hlpfile;
      if help=0 then begin
        if not StrDivDlm('.',a[1],a) then a[2]:=name;
        l:=Int0(a[1]);
        if IntToStr(l)=a[1] then begin
          nFile:=NegDef; Vid:=THelpLinkList(l);
        end
        else if a[1]<>'' then begin
          THelpLs.FileFind(a[1],nFile);
          if not PageFind(pref+'.'+a[2]) then if (Pos('.',a[2])=0) or not PageFind(a[2]) then a[1]:='';
        end;
      end
      else if HelpMapFind(help,nFile,a[2]) then a[1]:=aFile[nFile].nmf;
      if a[1]<>'' then PrAdd(result,1,name,a[2],nFile,Vid,hint);
    end;
    DelStack;
  end;
var i,nf: longint;
  lsg: TGetList;
  av: TArrVarRec;
  af: PArrFunc;
  Vid: THelpLinkList;
  v: variant;
begin
  AddStack('FHelpLs.HelpCntProc');
  with result do if Name='GETPRM' then begin
    lsg:=TGetList.Create;
    try
      i:=lsg.Count;
      if i>0 then begin
        SetLength(a,1+i); PrAdd(result,0,'Параметры видов ввода');
        for i:=0 to i-1 do with lsg.MaskHelp(i),hf do begin
          Vid:=hlnkLink;
          if not THelpLs.FileFind(sFile,nf) then InRange(hf,Vid);
          PrAdd(result,1,lsg[i],sPage,nf,Vid);
        end;
      end;
    finally
      lsg.Free;
    end;
  end
  else if Name='VAR' then begin
    TInter.GetVar(av,'',[ivtVar]); i:=Length(av);
    if i>0 then begin
      SetLength(a,1+i); PrAdd(result,0,'Переменные');
      for i:=0 to i-1 do
        with av[i],TInter.GetVarHelp(av[i])^ do InterAdd(name,hint,'Var',DlmBetween(hlpfile,hlpname,'.'),help);
    end;
  end
  else if Name='FUNC' then begin
    i:=TInter.GetFunction(af);
    if i>0 then begin
      SetLength(a,1+i); PrAdd(result,0,'Функции');
      for i:=1 to i do with af[i] do
        if not FirstEngChar(name) then InterAdd(name,hint,'Func',hlpfile,help);
    end;
  end
  else if Name='FUNCPART' then begin
    if Assigned(lsFuncPart) then begin
      i:=lsFuncPart.Count;
      if i>0 then begin
        TInter.GetFunction(af);
        SetLength(a,1+i); PrAdd(result,0,'Функции по категориям');
        for i:=0 to i-1 do begin
{if i=lsFuncPart.Count-1 then begin
lsFuncPart:=lsFuncPart;
end;}
          nf:=IntObj(lsFuncPart,i); PrAdd(result,1,af[nf].hint,IntToStr(nf),NegDef,hlnkFuncPart);
        end;
      end;
    end;
  end
  else if Name='TBLFIX' then begin
    i:=Length(aHelpTblProc);
    if i>0 then begin
      SetLength(a,1); PrAdd(result,0,'Служебные таблицы');
      for i:=0 to i-1 do begin
        aHelpTblProc[i]('',v); SetLength(a,Length(a)+VarLength(v));
        for nf:=VarArrayLowBound(v,1) to VarArrayHighBound(v,1) do
          PrAdd(result,1,v[nf][0],v[nf][0]+'\'+v[nf][1],NegDef,hlnkTblFix,v[nf][1]);
      end;
    end;
  end;
  DelStack;
end;

procedure WndKeyProc(Key: longint; tw: TWinControl; var lBreak: boolean);
begin
  AddStack('FHelpLs.WndKeyProc');
  lBreak:=true;
  case key of
    K_F1: THelpLs.Execute(tw);
    K_Alt_F1: THelpLs.Content;
    K_Alt_B: THelpLs.Edit(tw);
  else lBreak:=false;
  end;
  DelStack;
end;

procedure Init;
var av: TArrVar;
begin
  AddStack('FHelpLs.initialization');
  MyTypes.HelpLsLoad:=HelpLsLoad; MyTypes.HelpReBoldStr:=HelpReBoldStr;
  Inter.HelpMapFind:=HelpMapFind; Inter.HelpIsPage:=HelpIsPage; 
  aEdClass[edtpHelp]:=THelpEditMemo;
  TInter.SetFunction('HelpFile','',['Номер: целое'],['N'],c_file,null);
  TInter.SetVarShape(sHelpTblVar,HelpTblVar,TblTrans,[]);
  av:=nil;
  Tinter.DopGetVarAdd(av,DopGetVarEqual,TNone.DopGetVarAdd,TNone.DopGetVarIgnore);
  AddFrom(HelpCntProc);
  AddFrom(aWndKeyProc,WndKeyProc);
  DelStack;
end;

procedure Final;
var i: longint;
begin
  AddStack('FHelpLs.Final');
  for i:=low(aFile) to high(aFile) do with aFile[i] do begin
    lsMap.Free; lsPage.Free;
  end;
  aFile:=nil; lsFuncPart.Free;
  DelStack;
end;

initialization
  Init;
finalization
  Final;
end.
