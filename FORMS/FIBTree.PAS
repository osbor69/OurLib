unit FIBTree;

interface

uses
  Classes, Controls, Forms, Dialogs, ComCtrls, ToolWin, StdCtrls, IniFiles, Menus;

type
  TIBLoadFileProc = procedure(const fn,s: string; Pos: longint);

  TIBTree = class(TForm)
    tb: TToolBar;
    bLoad: TToolButton;
    bFind: TToolButton;
    bClose: TToolButton;
    Stat: TStatusBar;
    tv: TTreeView;
    PopupMenu1: TPopupMenu;
    mClose: TMenuItem;
    mFind: TMenuItem;
    mLoad: TMenuItem;
    fd: TFindDialog;
    mRefresh: TMenuItem;
    bRefresh: TToolButton;
    gbPath: TGroupBox;
    rbProject: TRadioButton;
    rbOurlib: TRadioButton;
    rbDelphi: TRadioButton;
    mObj: TMenuItem;
    mUses: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure mCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tvEnter(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tvChange(Sender: TObject; Node: TTreeNode);
    procedure mFindClick(Sender: TObject);
    procedure gbPathEnter(Sender: TObject);
    procedure fdFind(Sender: TObject);
    procedure tvDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure gbExit(Sender: TObject);
    procedure mLoadClick(Sender: TObject);
    procedure mObjClick(Sender: TObject);
    procedure mUsesClick(Sender: TObject);
  private
    { Private declarations }
    fIni: TIniFile;
    IniReaded,Aborted: boolean;
    als: array[1..2,1..2] of TStringList;
    PrLoad: TIBLoadFileProc;
    aEnbl: array of boolean;
    fProject,pProject,pDelphi: string;
    lsPnt,lsDcu: TStringList;
    aStack: array of string;
    nStack: longint;
    procedure fIniOpen;
		procedure SetEnbl(Value: boolean);
		procedure LoadEnbl(Value: boolean);
		procedure rbSave(Sender: TObject);
		procedure tvClear;
    procedure lsfClear;
  public
    { Public declarations }
    class procedure Execute(const ProjectName,PathDelphi,LibSearchPath: string; ProcLoad: TIBLoadFileProc);
  end;

var
  IBTree: TIBTree;

implementation

uses Windows,SysUtils,Math,StrUtils,ShellApi,
  GGI;

{$R *.dfm}

type
  PIBLsfRec = ^TIBLsfRec;
  TIBLsfRec = record
  	lsc,lse: TStringList;
    opt: set of boolean;
    np: longint;
  end;

  PIBNodeInfo = ^TIBNodeInfo;
  TIBNodeInfo = record
    i: byte;
  	ilsf,cd: longint;
    Pos: Longint;
  end;

const Section = 'InfoBrowser';
  fPas = '.PAS'; lPas = Length(fPas);
  fDpr = '.DPR'; lDpr = Length(fDpr);
  CRLF=#13#10; lCRLF=Length(CRLF);


function CorrDir(const Dir: TFileName): TFileName;
begin
  result:=IncludeTrailingPathDelimiter(Trim(Dir));
end;

procedure lseFree(lse: TStringList);
var j: longint;
begin
	if Assigned(lse) then begin
    for j:=0 to lse.Count-1 do Dispose(PString(lse.Objects[j]));
    lse.Free;
  end;
end;

function IgnoreSlFindAdd(ignoreSL: TStringList; const s: string; var ixS: longint): boolean;
var j: longint;
begin
  j:=ignoreSL.Count; ixS:=ignoreSL.Add(s); result:=j=ignoreSL.Count;
end;

function SortStrListCreate: TStringList;
begin
  result:=TStringList.Create; result.Sorted:=true; 
end;

function GetStrFile(const fn: string): string;
var i,j: longint;
begin
  result:=''; i:=FileOpen(fn,fmShareDenyNone or fmOpenRead);
  if longword(i)<>INVALID_HANDLE_VALUE then begin
    j:=Windows.GetFileSize(i,nil); SetLength(result,j);
    if ReadFile(i,pointer(result)^,j,LongWord(j),nil) then SetLength(result,j) else result:='';
    FileClose(i);
  end;
end;

function SetStrFile(const FileName: TFileName; const Value: string): boolean;
var i,j: longint;
begin
  i:=FileCreate(FileName); result := longword(i)<>INVALID_HANDLE_VALUE;
  if result then begin
    j:=Length(Value); WriteFile(i,pointer(Value)^,j,LongWord(j),nil); FileClose(i);
	end;
end;

function IsAlpha(c: char): boolean;
begin
  result := c in ['0'..'9','A'..'Z','_','a'..'z'];
end;

{ TIBTree }
class procedure TIBTree.Execute;
var wp: TWindowPlacement;
  i: longint;
  s,s1,sd: string;
  fl: boolean;
begin
  fl:=Assigned(IBTree);
  with IBTree do begin
    if fl then begin
      if WindowState=wsMinimized then begin
        wp.length:=SizeOf(wp); GetWindowPlacement(Handle,@wp);
        wp.ShowCmd:=SW_RESTORE; SetWindowPlacement(Handle,@wp);
      end;
    end
    else IBTree:=TIBTree.Create(nil);
    PrLoad:=ProcLoad; fProject:=ProjectName; pProject:=ExtractFilePath(fProject); pDelphi:=PathDelphi;
    rbProject.Enabled := pProject<>'';
    if rbProject.Enabled then pProject:=CorrDir(pProject)
    else if rbProject.Checked then rbOurlib.Checked:=true;
    rbDelphi.Enabled := pDelphi<>'';
    if rbDelphi.Enabled then pDelphi:=CorrDir(pDelphi)
    else if rbDelphi.Checked then rbOurlib.Checked:=true;
    with gbPath do for i:=0 to ControlCount-1 do aEnbl[i]:=Controls[i].Enabled;
    als[2,1].Clear;
    with TIniFile.Create(ChangeFileExt(fProject,'.DOF')) do try
      s:=ReadString('Directories','SearchPath','');
    finally
      Free;
    end;
    s:=Trim(LibSearchPath)+IfThen(s<>'',';'+s); sd:=LeftStr(pDelphi,Length(pDelphi)-1); i:=1;
    while i>0 do begin
      i:=pos(';',s);
      if i>0 then begin
        s1:=LeftStr(s,i-1); Delete(s,1,i);
      end
      else s1:=s;
      s1:=StringReplace(Trim(s1),'$(DELPHI)',sd,[rfReplaceAll,rfIgnoreCase]);
      if s1<>'' then als[2,1].Add(CorrDir(s1));
    end;
    if rbProject.Enabled then als[2,1].Add(pProject);
    if fl then SetFocus else Show;
  end;
end;

procedure TIBTree.FormCreate(Sender: TObject);
var i,j: byte;
begin
  for i:=low(als) to high(als) do
    for j:=low(als[i]) to high(als[i]) do begin
      als[i,j]:=TStringList.Create;
      if j=2 then als[i,j].Sorted:=true;
    end;
  SetLength(aEnbl,gbPath.ControlCount); lsPnt:=SortStrListCreate; lsDcu:=SortStrListCreate;
  SetLength(aStack,10);
end;

procedure TIBTree.FormDestroy(Sender: TObject);
var i,j: byte;
begin
	lsfClear; lsPnt.Free; lsDcu.Free;
  for i:=low(als) to high(als) do
    for j:=low(als[i]) to high(als[i]) do als[i,j].Free;
end;

procedure TIBTree.fIniOpen;
begin
  fIni:=TIniFile.Create(GetIniFileName(pDelphi+'MYDELPHI.INI'));
end;

procedure TIBTree.lsfClear;
var i: longint;
  j: byte;
	p: PIBLsfRec;
begin
  for j:=low(als) to high(als) do
    for i:=0 to als[j,2].Count-1 do begin
      p:=pointer(als[j,2].Objects[i]); lseFree(p.lse); p.lsc.Free; Dispose(p);
    end;
end;

procedure TIBTree.mCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TIBTree.gbPathEnter(Sender: TObject);
begin
	SetEnbl(false);
end;

procedure TIBTree.gbExit(Sender: TObject);
begin
	fIniOpen;
  try
  	rbSave(Sender);
  finally
  	fIni.Free;
  end;
end;

procedure TIBTree.rbSave;
var i: longint;
begin
  with TGroupBox(Sender) do for i:=0 to ControlCount-1 do with TRadioButton(Controls[i]) do
    fIni.WriteBool(Section,Name,Checked);
end;

procedure TIBTree.SetEnbl;
begin
  LoadEnbl(Value); bFind.Enabled:=Value; mFind.Enabled:=Value;
  bRefresh.Enabled:=Value; mRefresh.Enabled:=Value;
end;

procedure TIBTree.LoadEnbl;
var fl: boolean;
begin
  if Value and Assigned(tv.Selected) then fl := PIBNodeInfo(tv.Selected.Data).ilsf>=0 else fl:=false;
  bLoad.Enabled:=fl; mLoad.Enabled:=fl;
end;

procedure TIBTree.FormClose(Sender: TObject; var Action: TCloseAction);
var wp: TWindowPlacement;
begin
	if gbPath.Enabled then begin
    fIniOpen;
    try
      wp.length:=SizeOf(wp); GetWindowPlacement(Handle,@wp);
      with fIni,wp.rcNormalPosition do begin
        WriteBool(Section,'Maximized',WindowState=wsMaximized);
        WriteInteger(Section,'Left',Left);
        WriteInteger(Section,'Top',Top);
        WriteInteger(Section,'Right',Right);
        WriteInteger(Section,'Bottom',Bottom);
        WriteString(Section,'FindText',fd.FindText);
        WriteBool(Section,'FindWholeWord',frWholeWord in fd.Options);
      end;
      rbSave(gbPath);
    finally
      fIni.Free;
    end;
    tvClear; IBTree.Free; IBTree:=nil;
  end
  else begin
  	Aborted:=true; Action:=caNone;
  end;
end;

function StrToChar(const s: string): Char;
begin
	result:=IfThen(s='',' ',s)[1];
end;

function NotSysDir(const sr: TSearchRec): boolean;
begin
  if (sr.Attr and faDirectory)=faDirectory
  then result:=not((StrToChar(sr.Name)='.') and (ExtractFileExt(sr.Name)='.'))
  else result:=true;
end;

procedure TIBTree.tvEnter(Sender: TObject);
  function NoLoadDir(const dir: string; rb: TRadioButton): boolean;
  var i: longint;
    sr: TSearchRec;
  begin
    result:=not rb.Checked;
    if not result then begin
      i:=FindFirst(dir+'*'+fPas,faAnyFile-faDirectory,sr);
      if i=0 then als[1,1].Add(dir);
      SysUtils.FindClose(sr);
      i:=FindFirst(dir+'*.*',faDirectory,sr);
      while i=0 do begin
        if NotSysDir(sr) then NoLoadDir(dir+sr.Name+PathDelim,rb);
        i:=FindNext(sr);
      end;
      SysUtils.FindClose(sr);
    end;
  end;
  procedure rbLoad(gb: TGroupBox);
  var i: longint;
  begin
    with gb do for i:=0 to ControlCount-1 do with TRadioButton(Controls[i]) do
      Checked:=fIni.ReadBool(Section,Name,Tag<>0);
  end;
  function lsFileAdd(const s: string; i,np: longint): longint;
  var p: PIBLsfRec;
  begin
    New(p); result:=als[i,2].AddObject(s,TObject(p));
    p.lsc:=SortStrListCreate; p.lse:=SortStrListCreate;
    p.opt:=[]; p.np:=np;
  end;
var ilsf: longint;
  fExt: string;
  function lsfFind(const fn: string; var ilsf1: longint; lPrivate: boolean = false;
    ilsfCor: boolean = true): boolean;
  var j: longint;
    tn: TTreeNode;
    pn: PIBNodeInfo;
  begin
    result:=als[IfThen(lPrivate,1,2),2].Find(fn,ilsf1);
    if not result and not lPrivate then
      for j:=als[2,1].Count-1 downto 0 do
        if FileExists(als[2,1][j]+fn+fExt) then begin
          result:=true; ilsf1:=lsFileAdd(fn,2,j);
          if ilsf1<als[2,2].Count-1 then begin
            tn:=tv.Items.GetFirstNode;
            while Assigned(tn) do begin
              pn:=PIBNodeInfo(tn.Data);
              if (pn.i=2) and (pn.ilsf>=ilsf1) then Inc(pn.ilsf);
              tn:=tn.GetNext;
            end;
            if ilsfCor and (ilsf>=ilsf1) then Inc(ilsf);
          end;
          break;
        end;
  end;
type TIBLoadFileOpt = set of (iblfPrivate,iblfOnlyPublic);
  function LoadFile(const fn: string; Opt: TIBLoadFileOpt = []): boolean;
  var s: string;
    lPublic,lQ: boolean;
    plsf: PIBLsfRec;
    i,l: longint;
    a: array of boolean;
    function IsWord(const nmw: string; IsImpl: boolean = false): boolean;
    var j,j1,ln,r: longint;
    begin
      result:=false;
      if not lQ then begin
        if not IsImpl then IsImpl := lPublic and not(false in plsf.opt)
          or not lPublic and not(true in plsf.opt);
        if IsImpl then begin
          ln:=Length(nmw); r:=i+ln-1;
          if r<=l then begin
            result:=true; j1:=i;
            for j:=1 to ln do
              if a[j1] and (UpCase(s[j1])<>nmw[j]) then begin
                result:=false; break;
              end
              else Inc(j1);
            if result and (i>1) then for j:=i-1 downto 1 do
              if a[j] then begin
                result:=not IsAlpha(s[j]); break;
              end;
            if result and (r<l) then for j:=r+1 to l do
              if a[j] then begin
                result:=not IsAlpha(s[j]); break;
              end;
            if result then i:=j1;
          end;
        end;
      end;
    end;
    function NextWord(lTrim: boolean = true): string;
    var p: longint;
    begin
      if lTrim then while i<=l do
        if s[i]>' ' then break else Inc(i);
      p:=i;
      while i<=l do
        if IsAlpha(s[i]) or (s[i]='.') then Inc(i) else break;
      result:=UpperCase(Copy(s,p,i-p));
    end;
    procedure CommDel(var n: longint);
    var j: longint;
    begin
      if n>0 then begin
        for j:=n to i-1 do a[j]:=false;
        n:=0;
      end;
    end;
    function sCopy(Index,Count: longint): string;
    var l1: longint;
    begin
      SetLength(result,Count); l1:=0;
      while (Index<=l) and (Count>0) do begin
        if a[Index] then begin
          Inc(l1); result[l1]:=s[Index];
        end;
        Dec(Count); Inc(Index);
      end;
      SetLength(result,l1);
    end;
    function IsIdent(i,l: longint; var idn: string): boolean;
    begin
      result := s[i] in ['A'..'Z','_','a'..'z'];
      if result then idn:=sCopy(i,l);
    end;
  var tn: TTreeNode;
    clp: string;
    function tnFind(ls: TStringList): boolean;
    var i: longint;
    begin
      result:=ls.Find(clp,i);
      if result then tn:=pointer(ls.Objects[i]);
    end;
  var fl: boolean;
    cls: string;
    function lseFind(ls: TStringList): boolean;
    var i: longint;
    begin
      result:=ls.Find(clp,i);
      if result then begin
        clp:=PString(ls.Objects[i])^; fl:=false;
      end;
    end;
  var ufn,dir,sttxt: string;
    ils,p,j,k,nCommDef,nCommMany,nCommMany1,nCommOne,PosOffs: longint;
    ls,lsu,lscPriv,lsePriv,lsDef: TStringList;
    pn: PIBNodeInfo;
    ps: PString;
    aDef: array[0..15] of longint;
    nDef: ShortInt;
    UsesPrivate: boolean;
const MsgFile = 'C'+DriveDelim+PathDelim+'T'+PathDelim+'MyMsg.txt';
  label lend,lend1;
  begin
    lsu:=nil; sttxt:=fn; result:=false; Inc(nStack);
    try
      ufn:=AnsiUpperCase(fn);
      for i:=0 to nStack-1 do if ufn=aStack[i] then begin
        result:=true; break;
      end;
      if not result then begin
        if Length(aStack)=nStack then SetLength(aStack,nStack shl 1);
        aStack[nStack]:=ufn;
  {ufn:=''; i:=FileOpen(MsgFile,fmShareDenyNone or fmOpenRead);
  if longword(i)<>INVALID_HANDLE_VALUE then begin
    j:=Windows.GetFileSize(i,nil); SetLength(ufn,j);
    if ReadFile(i,pointer(ufn)^,j,LongWord(j),nil) then SetLength(ufn,j) else ufn:='';
    FileClose(i);
  end;
  for i:=0 to nStack-1 do ufn:=ufn+aStack[i]+'>';
  ufn:=ufn+fn+CRLF;
  i:=FileCreate(MsgFile);
  if longword(i)<>INVALID_HANDLE_VALUE then begin
    j:=Length(ufn); WriteFile(i,pointer(ufn)^,j,LongWord(j),nil); FileClose(i);
	end;}
    {if ufn='VARIANTS' then begin
    lsu:=lsu;
    end;}
        try
          for i:=1 to Length(fn) do if not IsAlpha(fn[i]) then goto lend;
          result:=lsfFind(fn,ilsf,(iblfPrivate in Opt) or (iblfOnlyPublic in Opt),false);
          if not result then goto lend;
          if lsfFind(fn,i,not(iblfPrivate in Opt)) then begin
            plsf:=pointer(als[IfThen(iblfPrivate in Opt,2,1),2].Objects[i]);
            if (false in plsf.opt) and ((true in plsf.opt) or (iblfPrivate in Opt)) then goto lend;
          end;
          ils:=IfThen((iblfPrivate in Opt) or (iblfOnlyPublic in Opt),1,2);
          plsf:=pointer(als[ils,2].Objects[ilsf]);
          if (false in plsf.opt) and ((true in plsf.opt) or not(iblfPrivate in Opt)) then goto lend;
          dir:=als[ils,1][plsf.np]; sttxt:=dir+fn+fExt; Stat.SimpleText:=sttxt;
          Application.ProcessMessages;
          if Aborted then goto lend;
          UsesPrivate:=false; lscPriv:=nil; lsePriv:=nil; lsDef:=SortStrListCreate;
          try
{ufn:=GetStrFile(MsgFile);
SetStrFile(MsgFile,ufn+CRLF);}

            {if rbLinux.Checked then lsDef.Add('LINUX')
            else begin
              lsDef.Add('MSWINDOWS'); lsDef.Add('WINDOWS');
            end;}
      {$IFDEF MSWINDOWS}
            lsDef.Add('MSWINDOWS'); lsDef.Add('WINDOWS');
      {$ENDIF}
      {$IFDEF WINDOWS}
            lsDef.Add('WINDOWS');
      {$ENDIF}
      {$IFDEF LINUX}
            lsDef.Add('LINUX');
      {$ENDIF}
      {$IFDEF VER120}
            lsDef.Add('VER120');
      {$ENDIF}
      {$IFDEF VER125}
            lsDef.Add('VER125');
      {$ENDIF}
      {$IFDEF VER130}
            lsDef.Add('VER130');
      {$ENDIF}
      {$IFDEF VER140}
            lsDef.Add('VER140');
      {$ENDIF}
      {$IFDEF VER150}
            lsDef.Add('VER150');
      {$ENDIF}
            s:=GetStrFile(sttxt); PosOffs:=0; i:=1; l:=Length(s); lPublic:=true; lQ:=false;
            nCommDef:=0; nCommMany:=0; nCommMany1:=0; nCommOne:=0; nDef:=-1; SetLength(a,l+1);
            FillMemory(@a[0],(l+1)*SizeOf(a[0]),byte(true));
            // Убрать комментарии и усл.компил.
            while i<=l do case s[i] of
              #10,#13: begin
                lQ:=false; Inc(i); CommDel(nCommOne);
              end;
              '''': begin
                if (nCommMany=0) and (nCommMany1=0) and (nCommOne=0) and (nCommDef=0) then lQ:=not lQ;
                Inc(i);
              end;
              '(': begin
                Inc(i);
                if i<=l then
                  if (s[i]='*') and not lQ and (nCommMany=0) and (nCommOne=0) and (nCommDef=0) then begin
                    nCommMany1:=i-1; Inc(i);
                  end;
              end;
              '*': begin
                Inc(i);
                if i<=l then
                  if (s[i]=')') and not lQ and (nCommMany=0) and (nCommOne=0) and (nCommDef=0) then begin
                    CommDel(nCommMany1); Inc(i);
                  end;
              end;
              '/': begin
                Inc(i);
                if i<=l then
                  if (s[i]='/') and not lQ and (nCommMany=0) and (nCommMany1=0) and (nCommDef=0)
                  then begin
                    nCommOne:=i-1; Inc(i);
                  end;
              end;
              '{': begin
                fl:=false;
                if not(lQ or (nCommOne>0) or (nCommMany1>0)) then begin
                  fl := nCommMany=0;
                  if nCommDef=0 then nCommMany:=i;
                end;
                Inc(i);
                if fl and (i<=l) then begin
                  if s[i]='$' then begin
                    nCommMany:=0; p:=i-1; k:=p; Inc(i); clp:=NextWord(false); cls:='';
                    if AnsiMatchText(clp,['IF','IFOPT','IFDEF','IFNDEF']) then begin
                      Inc(nDef); aDef[nDef]:=nCommDef; nCommDef:=IfThen((lsDef.IndexOf(NextWord)<0)=(clp='IFDEF'),p);
                    end
                    else if clp='ENDIF'then begin
                      if nCommDef<>0 then k:=nCommDef;
                      nCommDef:=aDef[nDef]; Dec(nDef);
                    end
                    else if clp='ELSE' then begin
                      if aDef[nDef]=0 then
                        if nCommDef=0 then nCommDef:=i else CommDel(nCommDef);
                    end
                    else if nCommDef=0 then
                      if clp='I' then begin
                        clp:=NextWord;
                        if lsfFind(clp,j) then cls:=als[2,1][PIBLsfRec(als[2,2].Objects[j]).np]+clp+fPas
                        else if FileExists(dir+clp) then cls:=dir+clp;
                      end
                      else if clp='DEFINE' then lsDef.Add(NextWord)
                      else if clp='UNDEF' then begin
                        if lsDef.Find(NextWord,j) then lsDef.Delete(j);
                      end;
                    fl:=true;
                    while (i<=l) and fl do begin
                      fl := s[i]<>'}'; Inc(i);
                    end;
                    if cls<>'' then begin
                      s:=StuffString(s,p,i-p,GetStrFile(cls)); i:=Length(s); Inc(PosOffs,l-i);
                      if i>l then begin
                        SetLength(a,i+1); FillMemory(@a[l+1],(i-l)*SizeOf(a[0]),byte(true));
                      end;
                      l:=i; i:=p;
                    end;
                    CommDel(k);
                  end;
                end;
              end;
              '}': begin
                Inc(i);
                if not lQ and (nCommMany1=0) and (nCommOne=0) and (nCommDef=0) then CommDel(nCommMany);
              end;
            else Inc(i);
            end;
            // Поиск классов
            i:=1; lQ:=false; lsu:=TStringList.Create;
            while i<=l do if a[i] then case s[i] of
              #10,#13: begin
                lQ:=false; Inc(i);
              end;
              '''': begin
                lQ:=not lQ; Inc(i);
              end;
              else begin
                if IsWord('USES',true) then begin
                  if lPublic then
                    if LoadFile('System') then lsu.Add('System');
                  p:=i;
                  while i<=l do begin
                    if a[i] and (s[i] in [',',';']) then begin
                      ufn:=Trim(sCopy(p,i-p));
                      if ufn<>'' then begin
                        p:=Pos(' ',ufn);
                        if p>0 then Delete(ufn,p,MaxInt);
                        if LoadFile(ufn) then lsu.Add(ufn)
                        else if LoadFile(ufn,[iblfPrivate,iblfOnlyPublic]) then lsu.Add(ufn);
                      end;
                      if Aborted then goto lend1;
                      p:=i+1;
                      if s[i]=';' then begin
                        Inc(i); break;
                      end;
                    end;
                    Inc(i);
                  end;
                  Stat.SimpleText:=sttxt;
                  if UsesPrivate then goto lend1;
                end
                else if UsesPrivate and IsAlpha(s[i]) then goto lend1
                else if a[i] and (s[i]='=') and not lQ then begin
                  p:=i; Inc(i);
                  while (i<=l) and not((s[i]>' ') and a[i]) do Inc(i);
                  j:=i;
                  if i<=l then if s[i]='^' then begin
                    i:=p-1;
                    while (i>0) and not((s[i]>' ') and a[i]) do Dec(i);
                    k:=i;
                    while (i>0) and (not a[i] or IsAlpha(s[i])) do Dec(i);
                    lsPnt.Add(AnsiUpperCase(sCopy(i+1,k-i)));
                    Inc(j); i:=j;
                  end;
                  if IsWord('CLASS') then begin
                    while (i<=l) and not((s[i]>' ') and a[i]) do Inc(i);
                    clp:='';
                    if i<=l then begin
                      if a[i] then
                        if s[i]='(' then begin
                          Inc(i); p:=i;
                          while (i<=l) and not((s[i]=')') and a[i]) do Inc(i);
                          clp:=Trim(sCopy(p,i-p)); p:=Pos(',',clp);
                          if p>0 then clp:=Trim(LeftStr(clp,p-1));
                          Inc(i);
                          while (i<=l) and not((s[i]>' ') and a[i]) do Inc(i);
                        end
                        else if s[i]<>';' then
                          if not IsWord('OF') then clp:='TObject';
                      if clp<>'' then begin
                        p:=i+1; i:=j-1;
                        while (i>0) and not((s[i]>' ') and a[i]) do Dec(i);
                        if i>0 then
                          if s[i]='=' then begin
                            Dec(i);
                            while (i>0) and not((s[i]>' ') and a[i]) do Dec(i);
                            j:=i;
                            while (i>0) and (not a[i] or IsAlpha(s[i])) do Dec(i);
                            cls:=sCopy(i+1,j-i);
                            if AnsiUpperCase(cls)<>'TOBJECT' then begin
                              tn:=nil;
                              repeat
                                fl:=true;
                                if not lPublic then tnFind(lscPriv);
                                if not Assigned(tn) then
                                  if not tnFind(plsf.lsc) then begin
                                    j:=Pos('.',clp);
                                    if j>0 then begin
                                      ufn:=LeftStr(clp,j-1); Delete(clp,1,j);
                                      if lsfFind(ufn,k) then tnFind(PIBLsfRec(als[2,2].Objects[k]).lsc);
                                      {if not Assigned(tn) then
                                        if lsfFind(ufn,k,true) then tnFind(PIBLsfRec(als[1,2].Objects[k]).lsc);}
                                    end;
                                    if not Assigned(tn) then for j:=lsu.Count-1 downto 0 do begin
                                      if lsfFind(lsu[j],k) then
                                        if tnFind(PIBLsfRec(als[2,2].Objects[k]).lsc) then break;
                                      if lsfFind(lsu[j],k,true) then
                                        if tnFind(PIBLsfRec(als[1,2].Objects[k]).lsc) then break;
                                    end;
                                  end;
                                if not Assigned(tn) then begin
                                  if not lPublic then lseFind(lsePriv);
                                  if fl then
                                    if not lseFind(plsf.lse) then
                                      for j:=lsu.Count-1 downto 0 do begin
                                        if lsfFind(lsu[j],k) then
                                          if lseFind(PIBLsfRec(als[2,2].Objects[k]).lse) then break;
                                        {if lsfFind(lsu[j],k,true) then
                                          if lseFind(PIBLsfRec(als[1,2].Objects[k]).lse) then break;}
                                      end;
                                end;
                              until Assigned(tn) or fl;
                              if not Assigned(tn) then begin
                                ls:=PIBLsfRec(als[1,2].Objects[als[1,2].IndexOf('')]).lsc;
                                if not IgnoreSLFindAdd(ls,clp,j) then begin
                                  New(pn); pn.i:=1; pn.ilsf:=-1; pn.cd:=-1;
                                  ls.Objects[j]:=tv.Items.AddChildObject(nil,clp,pn);
                                end;
                                tn:=pointer(ls.Objects[j]);
                              end;
                              New(pn); pn.i:=ils; pn.ilsf:=als[ils,2].IndexOf(fn);
                              pn.Pos:=PosOffs+i; pn.cd:=-1;
                              tn:=tv.Items.AddChildObject(tn,cls,pn);
                              if lPublic then ls:=plsf.lsc else ls:=lscPriv;
                              ls.AddObject(cls,tn);
                            end;
                          end;
                        i:=p;
                      end;
                    end;
                  end
                  else begin
                    i:=p; p:=i+1; Dec(i);
                    while (i>0) and not((s[i]>' ') and a[i]) do Dec(i);
                    j:=i;
                    while (i>0) and (not a[i] or IsAlpha(s[i])) do Dec(i);
                    if i=0 then Dec(i);
                    k:=i; fl:=true;
                    while (i>0) and not((s[i]>' ') and a[i]) do Dec(i);
                    if i>0 then fl := s[i]<>':';
                    i:=p;
                    if fl then
                      if IsIdent(k+1,j-k,cls) then begin
                        while (i<=l) and not((s[i]>' ') and a[i]) do Inc(i);
                        j:=i;
                        while (i<=l) and (not a[i] or IsAlpha(s[i])) do Inc(i);
                        if IsIdent(j,i-j,clp) then
                          if AnsiUpperCase(clp)<>'CLASS' then begin
                            while (i<=l) and not((s[i]>' ') and a[i]) do Inc(i);
                            if i<=l then
                              if s[i]=';' then begin
                                if lPublic then ls:=plsf.lse else ls:=lsePriv;
                                if not IgnoreSLFindAdd(ls,cls,j) then begin
                                  New(ps); ls.Objects[j]:=Pointer(ps); ps^:=clp;
                                end;
                              end;
                          end;
                      end;
                  end;
                end
                else if IsWord('IMPLEMENTATION',true) then begin
    {if AnsiUpperCase(fn)='IDGLOBALPROTOCOLS' then begin
    lsu:=lsu;
    end;}
                  Include(plsf.opt,false);
                  if (iblfPrivate in Opt) and not(iblfOnlyPublic in Opt) then begin
                    lPublic:=false; lscPriv:=SortStrListCreate; lsePriv:=SortStrListCreate;
                  end
                  else UsesPrivate:=true;
                end
                else Inc(i);
              end;
            end
            else Inc(i);
            Include(plsf.opt,true);
        lend1:
          finally
            lseFree(lsePriv); lsu.Free; lscPriv.Free; lsDef.Free;
          end;
      lend:
        except
          on E:Exception do begin
            if MessageDlg(sttxt+CRLF+IfThen(Assigned(lsu),'Поиск классов','Удаление комментариев')
            +Format(' (символ: %d)',[i])+CRLF+Copy(s,i,50)+CRLF+E.ClassName+':'+CRLF+E.Message+CRLF+'Продолжить ?',
            mtError,[mbYes,mbNo],0)=mrNo
              then Aborted:=true;
          end;
        end;
      end;
    finally
      Dec(nStack);
    end;
  end;
const fDcu = '.DCU'; lDcu = Length(fDcu);
var i,j,ilsf1: longint;
	sr: TSearchRec;
	wp: TWindowPlacement;
  rb,bt: TControl;
  ocng: TTVChangedEvent;
  cur: TCursor;
  {s,s1: string;
  fl: boolean;}
label lend;
begin
	Caption:='Поиск'; cur:=Cursor; Cursor:=crHourGlass; fExt:=fPas; nStack:=-1;
  with gbPath do begin
    Enabled:=false;
    for i:=0 to ControlCount-1 do Controls[i].Enabled:=false;
  end;
	if not IniReaded then begin
  	IniReaded:=true; fIniOpen;
    try
      wp.length:=SizeOf(wp); GetWindowPlacement(Handle,@wp);
      SystemParametersInfo(SPI_GETWORKAREA,0,@wp.rcNormalPosition,0);
      rb:=gbPath.Controls[gbPath.ControlCount-1];
      bt:=tb.Controls[tb.ControlCount-1];
      with wp.rcNormalPosition do begin
        Left:=fIni.ReadInteger(Section,'Left',Left);
        Top:=fIni.ReadInteger(Section,'Top',Top);
        Right:=fIni.ReadInteger(Section,'Right',min(Right,
          max(rb.ClientOrigin.X+rb.Width,bt.ClientOrigin.X+bt.Width)
          +Left-Self.Left+10));
        Bottom:=fIni.ReadInteger(Section,'Bottom',Bottom);
      end;
      if fIni.ReadBool(Section,'Maximized',false) then wp.showCmd:=SW_MAXIMIZE;
      if fIni.ReadBool(Section,'FindWholeWord',true) then fd.Options:=fd.Options+[frWholeWord];
      fd.FindText:=fIni.ReadString(Section,'FindText','');
      SetWindowPlacement(Handle,@wp); rbLoad(gbPath);
    finally
      fIni.Free;
    end;
  end;
  lsfClear; als[1,2].Sorted:=false; als[1,1].Clear; als[1,2].Clear; als[2,2].Clear; lsDcu.Clear;
  Aborted:=false; SetEnbl(false); ocng:=tv.OnChange; tv.OnChange:=nil;
  tv.Items.BeginUpdate; tvClear; tv.Items.Clear; tv.SortType:=stNone; lsPnt.Clear;
  try
    if NoLoadDir(pProject,rbProject) then
      if NoLoadDir('C'+DriveDelim+PathDelim+'DPROG'+PathDelim+'OURLIB'+PathDelim,rbOurlib)
      then NoLoadDir(pDelphi,rbDelphi);
    lsFileAdd('',1,-1);
    for i:=0 to als[1,1].Count-1 do begin
      j:=FindFirst(als[1,1][i]+'*'+fPas,faAnyFile-faDirectory,sr);
      while j=0 do begin
        if sr.Name[1]<>'.' then lsFileAdd(Copy(sr.Name,1,Length(sr.Name)-lPas),1,i);
        j:=FindNext(sr);
      end;
      SysUtils.FindClose(sr);
    end;
    als[1,2].Sorted:=true;
    if fProject<>'' then begin
      {s:=AnsiUpperCase(GetStrFile(fProject)); s:=Copy(s,Pos('USES',s)+4,MaxInt); i:=1; fl:=false;
      repeat
        j:=PosEx(',',s,i);
        if j=0 then begin
          fl:=true; j:=PosEx(';',s,i);
        end;
        s1:=Trim(Copy(s,i,j-i)); ilsf1:=Pos(' ',s1);
        if ilsf1>0 then Delete(s1,ilsf1,MaxInt);
        //LoadFile(Trim(s1),[iblfPrivate]);
        lsfFind(Trim(s1),ilsf1,false,false);
        i:=j+1;
      until fl;}
      fExt:=fDpr;
      LoadFile(ExtractFileName(Copy(fProject,1,Length(fProject)-lDpr)));
      fExt:=fPas;
    end;
    for i:=0 to als[1,1].Count-1 do begin
      j:=FindFirst(als[1,1][i]+'*'+fPas,faAnyFile-faDirectory,sr);
      while j=0 do begin
        if sr.Name[1]<>'.' then begin
          LoadFile(Copy(sr.Name,1,Length(sr.Name)-lPas),[iblfPrivate]);
          if Aborted then break;
        end;
        j:=FindNext(sr);
      end;
      SysUtils.FindClose(sr);
      if Aborted then goto lend;
    end;
    for i:=0 to als[2,1].Count-1 do begin
      Stat.SimpleText:=als[2,1][i]; Application.ProcessMessages;
      if Aborted then goto lend;
      j:=FindFirst(als[2,1][i]+'*'+fPas,faAnyFile-faDirectory,sr);
      while j=0 do begin
        if sr.Name[1]<>'.' then lsfFind(Copy(sr.Name,1,Length(sr.Name)-lPas),ilsf1,false,false);
        j:=FindNext(sr);
      end;
      SysUtils.FindClose(sr);
{if AnsiUpperCase(als[2,1][i])='C:\PROGRAM FILES (X86)\BORLAND\DELPHI7\LIB\' then begin
  sr:=sr;
end;}
      j:=FindFirst(als[2,1][i]+'*'+fDcu,faAnyFile-faDirectory,sr);
      while j=0 do begin
        if sr.Name[1]<>'.' then lsDcu.Add(Copy(sr.Name,1,Length(sr.Name)-lDcu));
        j:=FindNext(sr);
      end;
      SysUtils.FindClose(sr);
    end;
lend:    
  finally
    tv.SortType:=stText; Stat.SimpleText:=''; SetEnbl(true); tv.OnChange:=ocng;
    ocng(tv,tv.Selected); tv.Items.EndUpdate;
    with gbPath do begin
      Enabled:=true;
      for i:=0 to ControlCount-1 do Controls[i].Enabled:=aEnbl[i];
    end;
    Caption:=Format('Классы OURLIB (всего %d)',[tv.Items.Count]); Cursor:=cur; 
  end;
end;

procedure TIBTree.tvClear;
var tn: TTreeNode;
begin
  tn:=tv.Items.GetFirstNode;
	while Assigned(tn) do begin
    Dispose(tn.Data); tn:=tn.GetNext;
  end;
end;

procedure TIBTree.tvChange(Sender: TObject; Node: TTreeNode);
var cd: longint;
	function cdGet(tn: TTreeNode): longint;
  var p: PIBNodeInfo;
  begin
  	p:=tn.Data;
  	if p.cd<=0 then begin
    	p.cd:=0; tn:=tn.getFirstChild;
      while Assigned(tn) do begin
        Inc(p.cd,cdGet(tn)+1); tn:=tn.getNextSibling;
      end;
    end;
  	result:=p.cd;
  end;
var p: PIBNodeInfo;
	a: array[0..2] of string;
  i: byte;
  tn: TTreeNode;
begin
	LoadEnbl(bFind.Enabled);
  for i:=low(a) to high(a) do a[i]:='';
  tn:=tv.Selected;
  if Assigned(tn) then begin
    p:=tn.Data; cd:=cdGet(tn);
    while Assigned(tn) do begin
	    a[0]:=tn.Text+PathDelim+a[0]; tn:=tn.Parent;
    end;
    SetLength(a[0],Length(a[0])-1);
    if cd<>0 then a[1]:=Format('Дочерних: %d',[cd]);
    if p.ilsf>=0 then a[2]:='Модуль: '+als[p.i,2][p.ilsf];
  end;
	with Stat do for i:=low(a) to high(a) do begin
  	if i<high(a) then begin
    	cd:=0;
      if a[i]<>'' then cd:=Canvas.TextWidth(a[i])+6;
      Panels[i].Width:=cd;
    end;
    Panels[i].Text:=a[i];
  end;
end;

procedure TIBTree.mFindClick(Sender: TObject);
begin
	fd.Execute;
end;

procedure TIBTree.fdFind(Sender: TObject);
var tn: TTreeNode;
	sf: string;
  fl: boolean;
	procedure FindDown;
  begin
	  while Assigned(tn) and (tn<>tv.Selected) do begin
    	if frWholeWord in fd.Options then fl := sf=AnsiUpperCase(tn.Text)
      else fl := Pos(sf,AnsiUpperCase(tn.Text))<>0;
      if fl then break;
      tn:=tn.GetNext;
    end;
  end;
begin
	sf:=AnsiUpperCase(fd.FindText); fl:=false; tn:=tv.Selected.GetNext; FindDown;
  if not fl then begin
    tn:=tv.Items.GetFirstNode; FindDown;
  end;
  if fl then tv.Selected:=tn;
end;

procedure TIBTree.tvDblClick(Sender: TObject);
begin
	if bLoad.Enabled then bLoad.Click;
end;

procedure TIBTree.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
	if Key=vk_Escape then Close;
end;

procedure TIBTree.mLoadClick(Sender: TObject);
var i: longint;
	fn: string;
  p: PIBNodeInfo;
begin
  if Assigned(PrLoad) then begin
    p:=PIBNodeInfo(tv.Selected.Data); i:=p.ilsf;
    fn:=als[p.i,1][PIBLsfRec(als[p.i,2].Objects[i]).np]+als[p.i,2][i]+fPas;
    PrLoad(fn,GetStrFile(fn),p.Pos);
  end;
end;

procedure TIBTree.mObjClick(Sender: TObject);
var s: string;
  i: longint;
  lsf: TStringList;
  function lsfFind(ls: TStringList): boolean;
  var j,p,p1: longint;
  begin
    result:=false;
    for j:=0 to ls.Count-1 do begin
      p:=1;
      repeat
        p1:=PosEx(ls[j]+'(',s,p);
        if p1=0 then break;
        if p1>1 then if IsAlpha(s[p1-1]) then begin
          p:=p1+1; continue;
        end;
        if not result then lsf[i]:=lsf[i]+': ';
        lsf[i]:=lsf[i]+ls[j]+'('; result:=true; break;
      until false;
    end;
  end;
const FileObj = 'C:\T\MYMSG.TXT';
var lst: TStringList;
  tn: TTreeNode;
  p: PIBNodeInfo;
begin
  lst:=SortStrListCreate; lsf:=SortStrListCreate;
  try
    tn:=tv.Items.GetFirstNode;
    while Assigned(tn) do begin
      lst.Add(AnsiUpperCase(tn.Text)); p:=PIBNodeInfo(tn.Data);
      if p.ilsf>=0 then begin
        i:=p.ilsf; lsf.Add(als[p.i,1][PIBLsfRec(als[p.i,2].Objects[i]).np]+als[p.i,2][i]);
      end;
      tn:=tn.GetNext;
    end;
    i:=0; lsf.Sorted:=false;
    while i<lsf.Count do begin
      s:=lsf[i]+fPas; Stat.SimpleText:=Format('[%d/%d]',[i,lsf.Count])+s;
      s:=AnsiUpperCase(GetStrFile(s));
      if lsfFind(lst) or lsfFind(lsPnt) then Inc(i) else lsf.Delete(i);
    end;
    Stat.SimpleText:=''; lsf.SaveToFile(FileObj);
    MessageDlg(mObj.Caption+':'+CRLF+'результаты в файле '+FileObj,mtInformation,[mbOK],0);
  finally
    lst.Free; lsf.Free;
  end;
end;

procedure TIBTree.mUsesClick(Sender: TObject);
var sErr: string;
  lErr,f: longint;
  a: array of record
    Calculated,Calculating: boolean;
  end;
  lsNoFile: TStringList;
  procedure Calc(i: longint);
  var s: string;
    p,ls: longint;
    procedure SpaceIgnore;
    begin
      while p<=ls do if s[p]>' ' then break else Inc(p);
    end;
  var c: char;
    function NoEof(lSpace: boolean = true): boolean;
    begin
      if lSpace then SpaceIgnore;
      result := p<=ls;
      if result then begin
        c:=s[p]; Inc(p);
      end;
    end;
    function NextWord: string;
    var p0: longint;
    begin
      SpaceIgnore; p0:=p;
      while NoEof(false) do if not IsAlpha(c) then begin
        Dec(p); break;
      end;
      result:=Copy(s,p0,p-p0);
      if result='' then Inc(p);
    end;
  const sUSES='USES'; lUSES=Length(sUSES);
  var l,j,nDef: longint;
    aDef: array of record
      id: string;
      lNo,oMSWindows: boolean;
    end;
    MSWindows,IsUses: boolean;
    fn: string;
  begin
    if not a[i].Calculated then begin
      Stat.SimpleText:=als[2,2][i]; s:=als[2,2][i]+','; l:=Length(s);
      if Length(sErr)<lErr+l then SetLength(sErr,lErr+l);
      CopyMemory(pointer(longint(pointer(sErr))+lErr),pointer(s),l); Inc(lErr,l);
      if a[i].Calculating then begin
        p:=Pos(AnsiUpperCase(als[2,2][i])+',',AnsiUpperCase(LeftStr(sErr,lErr)));
        if p>0 then Dec(p);
        FileWrite(f,pointer(longint(pointer(sErr))+p)^,lErr-p); FileWrite(f,CRLF,lCRLF);
      end
      else begin
        a[i].Calculating:=true;
        s:=AnsiUpperCase(GetStrFile(als[2,1][PIBLsfRec(als[2,2].Objects[i]).np]+als[2,2][i]+fPas));
        ls:=Length(s); p:=1; nDef:=0; MSWindows:=true; IsUses:=false;
        while NoEof do case c of
          '/': if NoEof(false) then if c='/' then while NoEof do if c=#13 then break;
          '''': while NoEof do if c='''' then break;
          '{': while NoEof do case c of
            '$': begin
              fn:=NextWord;
              if AnsiMatchText(fn,['IF','IFOPT','IFDEF','IFNDEF']) then begin
                if Length(aDef)=nDef then SetLength(aDef,nDef+1);
                with aDef[nDef] do begin
                  lNo := fn='IFNDEF'; oMSWindows:=MSWindows; id:=NextWord;
                  if not lNo and (id='LINUX') or lNo and (id='MSWINDOWS') then MSWindows:=false;
                end;
                Inc(nDef);
              end
              else if fn='ELSE' then with aDef[nDef-1] do begin
                if not lNo and (id='MSWINDOWS') or lNo and (id='LINUX')
                  then MSWindows:=false
                else if not lNo and (id='LINUX') or lNo and (id='MSWINDOWS') then
                  MSWindows:=oMSWindows;
              end
              else if AnsiMatchText(fn,['IFEND','ENDIF'])then begin
                Dec(nDef); MSWindows:=aDef[nDef].oMSWindows;
              end;
            end;
            '}': break;
          end;
          ';': if MSWindows then IsUses:=false;
        else
          if MSWindows then if IsAlpha(c) then begin
            Dec(p); fn:=NextWord;
            if IsUses then
              if als[2,2].Find(fn,j) then Calc(j)
              else lsNoFile.AddObject(fn,pointer(i))
            else if fn='USES' then IsUses:=true;
          end;
        end;
        a[i].Calculating:=false;
      end;
      a[i].Calculated:=true; Dec(lErr,l);
    end;
  end;
const FileUses = 'C:\T\MYMSG.TXT';
var i: longint;
begin
  i:=als[2,2].Count;
  if i>0 then begin
    lsNoFile:=SortStrListCreate;
    try
      SetLength(a,i); ZeroMemory(@a[0],i*SizeOf(a[0])); lErr:=0;
      f:=CreateFile(FileUses,GENERIC_READ or GENERIC_WRITE,0,nil,CREATE_ALWAYS,FILE_FLAG_SEQUENTIAL_SCAN,0);
      for i:=0 to i-1 do Calc(i);
      for i:=0 to lsNoFile.Count-1 do if lsDcu.IndexOf(lsNoFile[i])<0 then begin
        sErr:='Отсутствует файл: '+lsNoFile[i]+' ('+als[2,2][longint(lsNoFile.Objects[i])]+')'+CRLF;
        FileWrite(f,pointer(sErr)^,Length(sErr));
      end;
      Stat.SimpleText:=''; FileClose(f);
      ShellExecute(0,nil,PChar(FileUses),nil,PChar(ExtractFilePath(FileUses)),SW_SHOW);
    finally
      lsNoFile.Free;
    end;
  end;
end;

end.
