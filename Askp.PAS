unit Askp;

interface

uses
	Messages,SysUtils,Classes,Controls,Forms,StdCtrls,ExtCtrls,
  MyTypes,FrmWnd;

type
  TAsk = class;
	TWaitProc = procedure(Sender: TAsk) of object;

  TAskButton = class(TButton)
  private
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
  end;

  TAskPanel = class(TPanel)
  protected
  	procedure Paint; override;
  public
  	alb: TArrStr;
  end;

  TAsk = class(TFormWnd)
  private
    P: TAskPanel;
    bCancel: TAskButton;
    prw: TWaitProc;
    FCanEsc: boolean;
	  CurTime: longword;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmTimer(Sender: TObject);
		class procedure PrRunExe(Sender: TAsk);
  public
  	Params: TArrVar;
		function SayCapt(const a: array of variant): boolean;
		procedure Abort;
		function Aborted: boolean;
		procedure ClearCurTime;
  end;

  TRunExeProc = procedure(AfterExe: boolean; Prm: pointer; var lBreak: boolean);

function AskCancel(const a: array of string; State: longint = mrYes;
	const Capt: TCaption = ''; Algm: TAlignment = taCenter): longint;
function mess_wait(const a: array of string; PrWait: TWaitProc;
	CanEsc: boolean = true; const Capt: TCaption = ''; Algm: TAlignment = taCenter;
  PrTimer: TNotifyEvent = nil): boolean; overload;
function mess_wait(const a: array of string; PrWait: TWaitProc;
	const Prm: array of variant; CanEsc: boolean = true;
  const Capt: TCaption = ''; Algm: TAlignment = taCenter; PrTimer: TNotifyEvent = nil): boolean; overload;
{function mess_waitpos(a: array of string; PrWait: TWaitProc;
	CanEsc: boolean; X,Y: longint): boolean;}
function AskFormSave(Sender: TForm; var Action: TCloseAction): longint;
function RunExe(const Command,Dir,Capt: string; const aFull: array of string;
	const TrashFile: TFileName = ''; Opt: TRunExeOpt = []; wndParent: THandle=0;
  Proc: TRunExeProc = nil; Prm: pointer = nil): boolean;
function ConsoleExec(const CommandLine,WorkDir: string; var ScrConcole: string): boolean;

implementation

uses Windows,Variants,StrUtils,Math,
  My_Pr,Schem,KeyLb,ER866;

type
  TAskStyle = (asYes,asNo,asCancel);
  TAskStyles = set of TAskStyle;

procedure IfThenWait(Proc: TWaitProc; Sender: TAsk);
begin
  if Assigned(Proc) then Proc(Sender);
end;

function askmes(const Capt: TCaption; const a: array of string; State: longint;
	Style: TAskStyles; const Prm: array of variant; PrWait: TWaitProc = nil;
	Algm: TAlignment = taCenter; CanEsc: boolean = true; PrTimer: TNotifyEvent = nil;
  X: longint = -MaxInt; Y: longint = 0; lDbg: boolean = false): longint;
var Fask: TAsk;
  abt: array of TAskButton;
  j,l,hs1: longint;
  function btCrt(st: TAskStyle; mr: TModalResult; const Capt: TCaption): TAskButton;
  begin
    AddStack('Askp.askmes.btCrt');
    if st in Style then begin
      result:=TAskButton.Create(Fask); abt[l]:=result; Inc(l);
      with Fask,result do begin
        Parent:=P; Caption:=SpaceCapt(Capt); Font.Assign(Canvas.Font); ModalResult:=mr;
        MaxSelf(j,Canvas,Caption); Height:=hs1;
        if State=mr then ActiveControl:=result;
      end;
    end
    else result:=nil;
    DelStack;
  end;
var i,hs,tb,lb,w: longint;
  r: TRect;
  ts: TSchem;
  ls: TStringList;
  a1: TArrStr;
  s: string;
begin
  AddStack('Askp.askmes');
  if (MessagesHidden or (lDbg in MessagesOkHidden)) and not Assigned(PrWait) then begin
	  result:=State; IfThenWait(PrWait,nil);
  end
  else begin
    r:=SysWorkArea; SchemName('Ask',ts); Fask:=TAsk.CreateAll(Application);
    with Fask do begin
      if Length(Prm)=0 then Params:=nil else Params:=VarArrayOf(Prm);
      BorderStyle:=bsToolWindow; Caption:=Capt; KeyPreview:=true; onKeyDown:=FormKeyDown;
      if CanEsc then BorderIcons:=[biSystemMenu,biMinimize]
      else begin
        BorderIcons:=[biMinimize]; onClose:=FormClose;
      end;
      if Assigned(ts) then begin
        Font.Assign(ts.Font1); Color:=ts.ColorW;
      end
      else FontStyle(Font);
      Canvas.Font.Assign(Font);
      hs:=nround(Canvas.TextHeight('S'));
      if Assigned(ts) then Canvas.Font.Assign(ts.Font2);
      hs1:=nround(Canvas.TextHeight('S'))+AskiY;
      if Assigned(PrWait) then begin
        prw:=PrWait; FCanEsc:=CanEsc;
        if CanEsc then Style:=[asCancel] else Style:=[];
        TTimerOne.CreateProc(IfThenNotify(PrTimer,tmTimer),Fask);
      end;
      P:=TAskPanel.Create(Fask);
      with P do begin
        Parent:=Fask; Align:=alClient; Alignment:=Algm; BevelInner:=bvNone; BevelOuter:=bvLowered;
        Caption:=''; TabStop:=false; ParentFont:=true; ParentColor:=true;
      end;
      ActiveControl:=nil; j:=0; l:=0; SetLength(abt,byte(high(TAskStyle))-byte(low(TAskStyle))+1);
      btCrt(asYes,mrYes,IfThen(asNo in Style,' Да ','Продолжить'));
      btCrt(asNo,mrNo,' Нет ');
      bCancel:=btCrt(asCancel,mrCancel,'Отмена');
      SetLength(abt,l);
      for i:=low(abt) to high(abt) do abt[i].Width:=j;
      j := l*(j+AskiX)+AskiX; Canvas.Font.Assign(FAsk.Font);
      ls:=TStringList.Create;
      try
        with SysWorkArea do lb:=Right-Left-Width+ClientWidth;
        w:=lb-Canvas.TextWidth(Space(2)); ls.Text:=ArrayAsList(a,CRLF); i:=0;
        while i<ls.Count do begin
          s:=SpaceCapt(ls[i]); tb:=max(Canvas.TextWidth(s),Canvas.TextWidth(ls[i]));
          if tb>lb then begin
            ls.Delete(i);
            for tb:=LsArrDynamic(astolin(Canvas,s,w),a1,CRLF)-1 downto 0 do ls.Insert(i,a1[tb]);
          end
          else begin
            MaxSelf(j,tb); Inc(i);
          end;
        end;
        ClientWidth:=j+6; Width:=max(Width,MinWidthForm(FAsk)); j:=ClientWidth; SetLength(P.alb,ls.Count);
        for i:=0 to ls.Count-1 do P.alb[i]:=ls[i];
        tb:=AskiY+hs*ls.Count;
      finally
        ls.Free;
      end;
      if l=0 then ClientHeight:=tb+AskiY
      else begin
        abt[high(abt)].Cancel:=true;
        j:=nround((j-l*abt[0].Width)/(l+1)); lb:=j; Inc(j,abt[0].Width); Inc(tb,AskiY);
        for i:=low(abt) to high(abt) do begin
          with abt[i] do SetBounds(lb,tb,Width,Height);
          Inc(lb,j);
        end;
        ClientHeight:=tb+AskiY+hs1;
      end;
      if X=-MaxInt
      then SetBounds(r.Left+(r.Right-r.Left-Width) div 2,r.Top+(r.Bottom-r.Top-Height) div 2,Width,Height)
      else SetBounds(X-IfThen(X>=Width,Width),Y-IfThen(Y>=Height,Height),Width,Height);
      CurTime:=0;
      try
        result:=ShowModal;
      finally
        Free;
      end;
    end;
  end;
  if (@LogMsgProc<>nil) then LogMsgProc(a,result);
  DelStack;
end;

procedure mess_ok(const a: array of string; const Capt: TCaption = '';
	Algm: TAlignment = taCenter; lDbg: boolean = false);
begin
	AddStack('Askp.mess_ok');
  askmes(Capt,a,mrYes,[asYes],[0],nil,Algm,true,nil,-MaxInt,0,lDbg);
  DelStack;
end;

function ask(const a: array of string; State: boolean = true;
	const Capt: TCaption = ''; Algm: TAlignment = taCenter): boolean;
begin
	AddStack('Askp.ask(a)');
	result := askmes(Capt,a,IfThen(State,mrYes,mrNo),[asYes,asNo],[0],nil,Algm)=mrYes;
  DelStack;
end;

function AskCancel;
begin
	AddStack('Askp.AskCancel');
	result:=askmes(Capt,a,State,[asYes,asNo,asCancel],[0],nil,Algm);
  DelStack;
end;

function mess_wait(const a: array of string; PrWait: TWaitProc;
	CanEsc: boolean = true; const Capt: TCaption = ''; Algm: TAlignment = taCenter;
  PrTimer: TNotifyEvent = nil): boolean;
begin
	AddStack('Askp.mess_wait');
	result:=mess_wait(a,PrWait,[],CanEsc,Capt,Algm,PrTimer);
  DelStack;
end;

function mess_wait(const a: array of string; PrWait: TWaitProc;
	const Prm: array of variant; CanEsc: boolean = true;
  const Capt: TCaption = ''; Algm: TAlignment = taCenter; PrTimer: TNotifyEvent = nil): boolean; overload;
begin
	AddStack('Askp.mess_wait(p)');
  result := askmes(Capt,a,mrCancel,[],Prm,PrWait,Algm,CanEsc,PrTimer)=mrOk;
  DelStack;
end;

{function mess_waitpos(a: array of string; PrWait: TWaitProc;
	CanEsc: boolean; X,Y: longint): boolean;
begin
	result := askmes(Capt,a,mrCancel,[],PrWait,Algm,CanEsc,X,Y)=mrOk;
end;}

function AskFormSave;
begin
	AddStack('Askp.AskFormSave');
	if (Action<>caHide) or (Sender.ModalResult=mrOk) then result:=mrCancel
  else begin
    result:=AskCancel(amsSaveCng,mrYes);
    case result of
      mrCancel: Action:=caNone;
      mrYes: if Sender is TFormWnd then TFormWnd(Sender).SetModalResult(mrOk) else Sender.ModalResult:=mrOk;
    end;
  end;
  DelStack;
end;

function RunExe;
const MaxBuf = 10*KByte;
var si: TStartupInfo;
	pi: TProcessInformation;
	f: TForm;
  Buf: PChar;
  Coord: TCoord;
  nChar: longword;
  a: TArrStr;
begin
	AddStack('Askp.RunExe');
  if (Win32Platform=VER_PLATFORM_WIN32_NT) or (runWin in Opt) then begin
    CopyFrom(a,aFull);
    result:=mess_wait([' '],TAsk.PrRunExe,
      [Command,Dir,LongInt(@a),TrashFile,runVisible in Opt,wndParent,longint(@Proc),longint(Prm)],
      true,IfThen(empty(Capt),Command,Capt));
    Application.BringToFront;
  end
  else begin
    f:=BeforeShowOther; Buf:=StrAlloc(MaxBuf+1);
    try
    	if not(runNoConsole in Opt) then AllocConsole;
      try
      	if not(runNoConsole in Opt) then SetConsoleTitle(PChar(Capt));
        GetStartupInfo(si);
        with si do begin
          dwFlags:=STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
          //dwFlags:=STARTF_USESTDHANDLES;
          wShowWindow:=SW_SHOW;
          //wShowWindow:=SW_HIDE;
          hStdInput:=GetStdHandle(STD_INPUT_HANDLE);
          hStdOutput:=GetStdHandle(STD_OUTPUT_HANDLE);
          hStdError:=GetStdHandle(STD_ERROR_HANDLE);
          //hStdInput:=0; hStdOutput:=0; hStdError:=0;
        end;
        CreateProcess(nil,PChar(Command),nil,nil,false,0,nil,PChar(Dir),si,pi);
        WaitForSingleObject(pi.HProcess,INFINITE); Coord.X:=0; Coord.Y:=0;
        ReadConsoleOutputCharacter(si.hStdOutput,Buf,MaxBuf,Coord,nChar);
        ScrConsole:=AnsiUpperCase(StrPas(Buf));
      finally
        if not(runNoConsole in Opt) then FreeConsole;
      end;
      AfterShowOther(f); Application.BringToFront;
      result:=true; FindErr('FULL',aFull,result);
    finally
      StrDispose(Buf);
    end;
  end;
  DelStack;
end;

// Функция запуска консольного приложения и получения его вывода
function ConsoleExec;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array[0..255] of Char;
  BytesRead: Cardinal;
begin
  Application.ProcessMessages;
  with SA do begin
    nLength := SizeOf(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);
  try
    with SI do begin
      FillChar(SI, SizeOf(SI), 0);
      cb := SizeOf(SI);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE);
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;
    result := CreateProcess(nil, PChar(CommandLine), nil, nil, True, 0, nil, PChar(WorkDir), SI, PI);
    CloseHandle(StdOutPipeWrite);
    if result then try
      WaitForSingleObject(PI.hProcess, INFINITE);
      ScrConcole := '';
      repeat
        WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
        if BytesRead > 0 then begin
          Buffer[BytesRead] := #0;
          IncD(ScrConcole,Buffer);
        end;
      until not WasOK or (BytesRead <255);
    finally
      CloseHandle(PI.hThread);
      CloseHandle(PI.hProcess);
    end;
  finally
    DosToWinSelf(ScrConcole);
    CloseHandle(StdOutPipeRead);
  end;
end; { ConsoleExec }

{ TAskButton }
procedure TAskButton.CNKeyDown;
begin
	AddStack('TAskButton.CNKeyDown',Self);
  if not((Message.CharCode=vk_Return) and Assigned(TAsk(Owner).prw))
  then inherited;
  DelStack;
end;

{ TAskPanel }
procedure TAskPanel.Paint;
const w = 3;
var i,t,l: longint;
  sz: TSize;
begin
	AddStack('TAskPanel.Paint',Self);
  inherited Paint;
  Canvas.Font.Assign(Font); t:=AskiY;
  for i:=low(alb) to high(alb) do begin
    sz:=Canvas.TextExtent(alb[i]);
    if sz.cy=0 then sz.cy:=CanvasMaxH(Canvas);
  	case Alignment of
      taLeftJustify: l:=Canvas.TextWidth(' ');
      taRightJustify: l:=Width-Canvas.TextWidth(' ')-sz.cx;
    else l:=(Width-sz.cx) div 2;
    end;
    Inc(sz.cy,t); Canvas.TextRect(Rect(w,t,Width-w shl 1,sz.cy),l,t,alb[i]); t:=sz.cy;
  end;
  DelStack;
end;

{ TAsk }
procedure TAsk.FormKeyDown;
begin
	AddStack('TAsk.FormKeyDown',Self);
	if FCanEsc and (Shift=[]) and (Key=vk_F10) then Key:=0;
  TKeyLb.ExecFixKey(GetKeyCod(Key,Shift));
  DelStack;
end;

procedure TAsk.FormClose;
begin
	AddStack('TAsk.FormClose',Self);
	if not FCanEsc and (Action=caHide) and (ModalResult<>mrOk)
  then begin
  	ModalResult:=mrNone; Action:=caNone;
  end;
  DelStack;
end;

// Выполнить процесс
procedure TAsk.tmTimer;
begin
	AddStack('TAsk.tmTimer',Self);
  IfThenWait(prw,Self);
	if ModalResult<>mrCancel then ModalResult:=mrOk;
  DelStack;
end;

// Опрос на прерывание
function TAsk.Aborted;
begin
	AddStack('TAsk.Aborted');
  Application.ProcessMessages;
  if Assigned(Self) then result := ModalResult<>mrNone else result:=false;
  Or_D(result,Application.Terminated);
  DelStack;
end;

procedure TAsk.ClearCurTime;
begin
  CurTime:=0;
end;

// Прерывание из программы
procedure TAsk.Abort;
begin
	AddStack('TAsk.Abort',Self);
  if Assigned(Self) then
    if Assigned(bCancel) then bCancel.Click else ModalResult:=mrOk;
  DelStack;
end;

// Изменить подсказку
function TAsk.SayCapt;
var i,j,w: longint;
  t: longword;
begin
	AddStack('TAsk.SayCapt',Self);
  result:=Aborted; t:=My_pr.GetTickCount;
  if (CurTime=0) or (t-CurTime>MSecsPerSec) then begin
    CurTime:=t; j:=low(a); w:=0;
		Canvas.Font.Assign(P.Font);
    for i:=low(P.alb) to high(P.alb) do begin
      if j>high(a) then break;
      if MyVarType(a[j])=varString then P.alb[i]:=a[j];
      MaxSelf(w,Canvas,SpaceCapt(P.alb[i]),6); Inc(j);
    end;
    P.Invalidate;
    if w>ClientWidth then begin
      Inc(w,Width-ClientWidth);
      SetBounds(Left+(Width-w) div 2,Top,w,Height);
      if Assigned(bCancel) then bCancel.Left := (ClientWidth-bCancel.Width) div 2;
      Refresh;
    end;
  end;
  DelStack;
end;

class procedure TAsk.PrRunExe;
	function DelBS(const s: string): string;
  var i: longint;
  begin
    AddStack('TAsk.PrRunExe.DelBS');
    i:=1; result:=s;
    while i<=Length(result) do
    	if result[i]=#8 then begin
      	Dec(i); Delete(result,i,2);
      end
      else Inc(i);
    TrimRightSelf(result);
    DelStack;
  end;
const a: array[1..4] of char = ('-','\','|','/');
var si: TStartupInfo;
	pi: TProcessInformation;
  trash,h: THandle;
  s,s1,TrashFile,OutFile: string;
  dir: PChar;
  i: longint;
  n: byte;
  fl,lTrash,lBreak,lp: boolean;
  Proc: TRunExeProc;
  Prm: pointer;
begin
	AddStack('TAsk.PrRunExe');
  OutFile:=Sender.Params[3]; lTrash:=OutFile=''; TrashFile:=ExeDir+'_trash.txt'; n:=0;
  if lTrash then OutFile:=TrashFile;
  trash:=CreateFile(PChar(TrashFile),GENERIC_READ or GENERIC_WRITE,
    FILE_SHARE_READ,nil,CREATE_ALWAYS,0,0);
  GetStartupInfo(si);
	with si do begin
    dwFlags:=STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    wShowWindow:=IfThen(Sender.Params[4],SW_SHOW,SW_HIDE);
    hStdInput:=trash; hStdOutput:=trash; hStdError:=trash;
	end;
  h:=Sender.Params[5];
  if (h<>0) then SetForegroundWindow(h);
  Proc:=PointerVar(Sender.Params[6]); Prm:=PointerVar(Sender.Params[7]);
  if Sender.Params[1]='' then dir:=nil else dir:=PChar(string(Sender.Params[1]));
	if CreateProcess(nil,PChar(string(Sender.Params[0])),nil,nil,false,CREATE_NEW_PROCESS_GROUP,nil,dir,si,pi) then begin
    lp:=true;
    repeat
      if Win32Platform=VER_PLATFORM_WIN32_NT then begin
        Inc(n);
        if n>high(a) then n:=1;
        s:=a[n];
      end
      else begin
        if lTrash then FlushFileBuffers(trash);
        s:=GetStrFile(OutFile);
        if not lTrash then DosToWinSelf(s);
        i:=RPos(CRLF,s);
        if i>0 then begin
          s1:=Copy(s,i+lCRLF,MaxInt);
          if lTrash then begin
            SetLength(s,i-1); i:=RPos(CRLF,s);
            if i>0 then Delete(s,1,i+lCRLF-1);
            if s='' then s:=s1;
          end
          else s:=s1;
        end;
        s:=DelBS(s);
      end;
      Sender.CurTime:=0; lBreak:=Sender.SayCapt([s]);
      if not lBreak then if Assigned(Proc) then Proc(false,Prm,lBreak);
      if lBreak then begin
        if lp then TerminateProcess(pi.hProcess,0);
        break;
      end;
      if lp then begin
        lBreak := WaitForSingleObject(pi.HProcess,MSecsPerSec)=0;
        if lBreak then lp:=false;
      end
      else begin
        Sleep(MSecsPerSec); lBreak:=true;
      end;
      if lBreak then begin
        if Assigned(Proc) then Proc(true,Prm,lBreak);
        if lBreak then break;
      end;
    until false
  end
  else Sender.Abort;
  CloseHandle(trash);
  if not Sender.Aborted then begin
  	fl:=true; FindErr('FULL',ArrStrVar(Sender.Params[2])^,fl);
  	if fl then ScrConsole:=AnsiUpperCase(DelBS(GetStrFile(OutFile)));
  end;
  DelFileAtr(TrashFile);
  if not lTrash then DelFileAtr(OutFile);
  DelStack;
end;

initialization
  AddStack('Askp.initialization');
  MyTypes.mess_ok:=mess_ok; MyTypes.ask:=ask;
  DelStack;
end.
