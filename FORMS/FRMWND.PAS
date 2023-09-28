unit FrmWnd;

interface

{$I LIBTEST}
uses
  Messages, SysUtils, Classes, Forms, Controls,
  MyTypes;

type
  TFormWnd = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FActiveForm{,NoDrawClipboard}: boolean;
    procedure SetActiveForm(Value: boolean);
		procedure SetButShow(lShow: boolean);
    procedure TimerClos(Sender: TObject);
    procedure LimUslTime(pTime: PDateTime);
		class function LastForm(var f: TFormWnd): boolean; overload;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMSizing(var Message: TMessage); message WM_SIZING;
		procedure WMMove(var Message: TWMMove); message WM_MOVE;
    procedure WMMoving(var Message: TMessage); message WM_MOVING;
{ $IFDEF NCACT}
    procedure WMNCActivate(var Message: TWMNCActivate); message WM_NCACTIVATE;
{ $ENDIF}
    procedure WMEnterMenuLoop(var Message: TWMEnterMenuLoop); message WM_ENTERMENULOOP;
    procedure WMExitMenuLoop(var Message: TWMExitMenuLoop); message WM_EXITMENULOOP;
    procedure WMClose(var Message: TWMClose); message WM_CLOSE;
		procedure WMRebuild(var Message: TMessage); message WM_REBUILD;
  	procedure WMCngPriv(var Msg: TMessage); message WM_CNGPRIV;
    {procedure WMChangeCBChain(var Message: TWMChangeCBChain); message WM_CHANGECBCHAIN;
    procedure WMDrawClipboard(var Message: TWMDrawClipboard); message WM_DRAWCLIPBOARD;}
    class procedure ApplRestore(Sender: TObject);
		class procedure ApplException(Sender: TObject; E: Exception);
{ $IFDEF NCACT}
    class procedure ApplActivate(Sender: TObject);
{ $ENDIF}
		//class procedure PrRunExe(Sender: TAsk);
  protected
    procedure DoCreate; override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure DoHide; override;
    procedure DoShow; override;
    procedure AfterCreate; virtual;
		function FreeLimit(var f): boolean; overload;
		procedure FreeLimit(ls: TList; var nForm: longint); overload;
    procedure WndProc(var Message: TMessage); override;
    function BrEditProc(lApp: boolean; const Capt: TCaption; const glkey: string): boolean; virtual;
    //procedure CreateParams(var Params: TCreateParams); override;
    //procedure SetName(const Value: TComponentName); override;
  public
    { Public declarations }
  	NoLimit: boolean;
    TimeLimit: TDateTime;
    OnMove: TNotifyEvent;
		constructor CreateAll(AOwner: TComponent); virtual;
		function ShowModal: longint; override;
    procedure SetBounds(ALeft,ATop,AWidth,AHeight: longint); override;
    procedure BeforeShow;
    procedure AfterShow;
    procedure TimerFormClose(mr: TModalResult);
		procedure SetModalResult(mr: TModalResult = mrCancel); virtual;
    procedure FormOnScreen;
    procedure MainRebuild(lSetRdw: boolean = true);
    procedure RbFormResize;
    procedure SetSchemForm;
    function VisibleNoNil: boolean;
		class procedure StdProcKey(key: longint; tw: TWinControl);
		class function LastForm: TFormWnd; overload;
    property ActiveForm: boolean read FActiveForm write SetActiveForm;
  end;

var
  FormWnd: TFormWnd;
  FormWndProc: procedure(f: TFormWnd; var Message: TMessage);
  ApplExceptionProc: procedure(var s: string; E: Exception) = nil;

{function RunExe(const Command,Dir,Capt: string;
	const aFull,aBreak: array of string): boolean;}

implementation

{$R *.DFM}

uses Windows,Dialogs,
  My_pr,KeyLb,FPanel;

var LsFormLimit: TList;
  nCreateForm: longint = 0;
  lFirstForm: boolean = true;
  afMin: array of record
  	f: TForm;
    ws: TWindowState;
  end;
  //FNextClipboardViewer: HWND;

function BeforeShowOther: TForm;
begin
  AddStack('FrmWnd.BeforeShowOther');
  if TFormWnd.LastForm(TFormWnd(result)) then TFormWnd(result).ActiveForm:=false;
  DelStack;
end;

procedure AfterShowOther(f: TForm);
begin
  AddStack('FrmWnd.AfterShowOther');
  if Assigned(f) then TFormWnd(f).ActiveForm:=true;
  DelStack;
end;

// Запуск другой программы
{function RunExe;
const MaxBuf = 10*KByte;
var si: TStartupInfo;
	pi: TProcessInformation;
	f: TFormWnd;
  Buf: PChar;
  Coord: TCoord;
  nChar: longword;
  lNT: boolean;
begin
	AddStack('FrmWnd.RunExe');
  f:=TFormWnd.BeforeShowOther; Buf:=StrAlloc(MaxBuf+1);
  try
  	lNT := Win32Platform=VER_PLATFORM_WIN32_NT;
    if not lNT then AllocConsole;
    try
      SetConsoleTitle(PChar(string(IfThen(lNT,WinToDos(Capt),Capt))));
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
      CreateProcess(nil,PChar(Command),nil,nil,false,IfThen(lNT,CREATE_NEW_CONSOLE),nil,PChar(Dir),si,pi);
      WaitForSingleObject(pi.HProcess,INFINITE); Coord.X:=0; Coord.Y:=0;
      ReadConsoleOutputCharacter(si.hStdOutput,Buf,MaxBuf,Coord,nChar);
      ScrConsole:=AnsiUpperCase(StrPas(Buf));
    finally
    	if not lNT then FreeConsole;
    end;
    TFormWnd.AfterShowOther(f); Application.BringToFront;
    result:=true; FindErr('FULL',aFull,result); FindErr('BREAK',aBreak,result);
  finally
  	StrDispose(Buf);
  end;
  DelStack;
end;

{ TFormWnd }
{procedure TFormWnd.SetName;
begin
  AddStack('TFormWnd.SetName',Self);
  IncD(Self,[],[csSetCaption]);
  inherited SetName(Value);
  DelStack;
end;}

constructor TFormWnd.CreateAll;
begin
  AddStack('TFormWnd.CreateAll',Self);
  CreateNew(AOwner);
  DefaultFont(Font); OnCreate:=FormCreate; OnDestroy:=FormDestroy;
  DelStack;
end;

procedure TFormWnd.DoCreate;
begin
	AddStack('TFormWnd.DoCreate',Self);
  NoLimit:=true;
  inherited DoCreate;
  NoLimit:=false; TimeLimit:=Now;
  DelStack;
end;

procedure TFormWnd.FormCreate(Sender: TObject);
  procedure Msg(usl: boolean; const ms: string);
  begin
    AddStack('TFormWnd.FormCreate.Msg',Self);
    if not Application.Terminated and usl then
      if MsgDlg([ms,'','Продолжить ?'],mtWarning,[mbYes,mbNo])<>mrYes then Application.Terminate;
    DelStack;
  end;
var DefaultLCID: Integer;
  procedure ChkLocale(LCType: LCTYPE; Val: Char; const nm: string);
  var Buffer: array[0..1] of Char;
  begin
    AddStack('TFormWnd.FormCreate.ChkLocale',Self);
    if not Application.Terminated then
      if GetLocaleInfo(DefaultLCID,LCType,Buffer,2)>0 then
        if Buffer[0]<>Val then begin
          case MsgDlg(['Внимание !','Значение параметра "'+nm+'" равно "'+Buffer[0]+'".',
          'Для корректной работы программы необходимо установить его равным "'+Val+'".',
          'Установить корректное значение параметра ?'],mtWarning,[mbYes,mbNo,mbCancel]) of
            mrYes: begin
              Buffer[0]:=Val;
              Msg(not SetLocaleInfo(DefaultLCID,LCType,Buffer),
                'Ошибка установки значение параметра'+CRLF+'"'+nm+'".'+CRLF
                +'Для корректной работы программы необходимо установить его равным "'+Val+'".'+CRLF
                +'(см. "Пуск" - "Настройка" - "Панель управления" - "Язык и региональные стандарты")');
            end;
            mrCancel: Application.Terminate;
          end;
          GetFormatSettings;
        end;
    DelStack;
  end;
var DC: HDC;
begin
	AddStack('TFormWnd.FormCreate',Self);
  ListCreateObj(Self,LsFormLimit); FActiveForm:=false;
  if nCreateForm=0 then begin
    Application.OnException:=ApplException; Application.OnRestore:=ApplRestore;
{ $IFDEF NCACT}
    Application.OnActivate:=ApplActivate;
{ $ENDIF}
    HelpLsLoad;
    TKeyLb.SetFixKey(K_F1,'Помощь',StdProcKey,kmHelp);
    TKeyLb.SetFixKey(K_Alt_F1,'Содержание',StdProcKey,kmHelp);
    TKeyLb.SetFixKey(K_Alt_B,'Редактировать раздел помощи',StdProcKey,kmDesign);
    TKeyLb.SetFixKey(K_Ctrl_F2,'Настройка',StdProcKey,kmHelp);
    TKeyLb.SetFixKeyVisible;
    if lFirstForm then begin
      if not(csDesigning in Application.ComponentState) then begin
        DC:=GetDC(0);
        try
          Msg(GetDeviceCaps(DC,NUMCOLORS)=16,'Для корректной работы программы необходимо не менее 256 цветов'+CRLF
            +'(см. "Пуск" - "Настройка" - "Панель управления" - "Экран")');
        finally
          ReleaseDC(0,DC);
        end;
        DefaultLCID:=GetThreadLocale;
        ChkLocale(LOCALE_SDECIMAL,',','разделитель целой и дробной части числа');
        ChkLocale(LOCALE_SDATE,'.','разделитель компонентов даты');
      end;
      lFirstForm:=false;
    end;
  end;
  AfterCreate; Inc(nCreateForm);
  DelStack;
end;

procedure TFormWnd.FormDestroy(Sender: TObject);
var i: longint;
	fl: boolean;
begin
	AddStack('TFormWnd.FormDestroy',Self);
  fl:=false;
  for i:=low(afMin) to high(afMin) do
  	if fl then afMin[i-1]:=afMin[i]
    else fl := afMin[i].f=Self;
  if fl then SetLength(afMin,Length(afMin)-1);
  Dec(nCreateForm);
  if nCreateForm=0 then begin
		Application.OnException:=nil; Application.OnRestore:=nil;
  end;
  ListDestroyObj(Self,LsFormLimit);
  DelStack;
end;

procedure TFormWnd.WMSize;
var oldws: TWindowState;
  r: TRect;
  i,j: longint;
  f: TForm;
  fw: TFormWnd;
begin
	AddStack('TFormWnd.WMSize',Self);
  oldws:=WindowState;
	inherited;
  if oldws<>WindowState then
    if (Win32Platform=VER_PLATFORM_WIN32_NT) and CheckWin32Version(6) then begin
      if WindowState=wsMinimized then begin
        SetLength(afMin,Screen.FormCount); j:=0;
        for i:=0 to Screen.FormCount-1 do begin
          f:=Screen.Forms[i];
          if f.Perform(WM_NOCNGWSTATE,0,0)=0 then begin
            if f=Self then afMin[j].ws:=oldws
            else begin
              afMin[j].ws:=f.WindowState; f.WindowState:=wsMinimized;
            end;
            afMin[j].f:=f; Inc(j);
          end;
        end;
        SetLength(afMin,j);
      end
      else if oldws=wsMinimized then begin
        for i:=high(afMin) downto low(afMin) do with afMin[i] do f.WindowState:=ws;
        afMin:=nil; 
        if LastForm(fw) then fw.BringToFront;
      end;
    end
    else if (WindowState=wsMinimized) and not ApplMinimizing then begin
      SetLength(afMin,1); afMin[0].f:=Self; afMin[0].ws:=oldws;
      FActiveForm:=false; ApplMinimizing:=true;
      ShowWindow(Application.Handle,SW_MINIMIZE); //ApplMinimizing:=false;
    end;
  if WindowState=wsMaximized then begin
    r:=SysWorkArea;
    if (Width<r.Right-r.Left) or (Height<r.Bottom-r.Top) then begin
      WindowState:=wsNormal; WindowState:=wsMaximized;
    end;
  end;
  DelStack;
end;

procedure TFormWnd.WndProc;
begin
	{$IFDEF STACKALL}AddStack('TFormWnd.WndProc',Self);{$ENDIF}
  inherited WndProc(Message);
  if Assigned(FormWndProc) then FormWndProc(Self,Message);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TFormWnd.WMMove;
begin
  AddStack('TFormWnd.WMMove',Self);
  inherited;
  IfThenNotify(OnMove,Self);
  DelStack;
end;

procedure TFormWnd.WMMoving;
begin
	AddStack('TFormWnd.WMMoving',Self);
  if WindowState<>wsMaximized then UserWorkArea(PRect(Message.LParam)^);
  inherited;
  DelStack;
end;

procedure TFormWnd.WMSizing;
begin
	AddStack('TFormWnd.WMSizing',Self);
  if WindowState<>wsMaximized then UserWorkArea(PRect(Message.LParam)^);
  inherited;
  DelStack;
end;

class procedure TFormWnd.ApplRestore;
var i: longint;
	f: TFormWnd;
begin
	AddStack('TFormWnd.ApplRestore');
  ShowWindow(Application.Handle,SW_RESTORE);
  for i:=low(afMin) to high(afMin) do with afMin[i] do f.WindowState:=ws;
  afMin:=nil;
  if LastForm(f) then f.FActiveForm:=true;
  ApplMinimizing:=false;
  DelStack;
end;

{procedure TFormWnd.CreateParams;
begin
  AddStack('TFormWnd.CreateParams',Self);
  inherited CreateParams(Params);
  //Or_D(Params.ExStyle,WS_EX_APPWINDOW);
  Params.WndParent:=GetDesktopWindow;
  DelStack;
end;}

function TFormWnd.ShowModal;
begin
	AddStack('TFormWnd.ShowModal',Self);
	BeforeShow;
  result := inherited ShowModal;
  AfterShow; TimeLimit:=Now;
  DelStack;
end;

procedure TFormWnd.BeforeShow;
var f: TFormWnd;
	i: longint;
begin
	AddStack('TFormWnd.BeforeShow',Self);
  if not Assigned(LsFormWnd) then begin
  	LsFormWnd:=TList.Create; LsFormWnd.Add(Application.MainForm);
    //if FNextClipboardViewer=0 then FNextClipboardViewer:=SetClipboardViewer(Application.MainForm.Handle);
  end;
  if IsClass(LsFormWnd[LsFormWnd.Count-1],TFormWnd,pointer(f)) then begin
    f.ActiveForm:=false;
	  if IsCalculator then FormKeyLb(f).ExecKey(K_Esc);
  end;
  LsFormWnd.Add(Self);
  i:=Length(afMin);
  if i>0 then begin
		SetLength(afMin,i+1); afMin[i].f:=Self; afMin[i].ws:=WindowState;
    WindowState:=wsMinimized;
  end;
  FormOnScreen;
  DelStack;
end;

procedure TFormWnd.AfterShow;
var f: TFormWnd;
	i: longint;
begin
	AddStack('TFormWnd.AfterShow',Self);
  ListDestroyObj(Self,LsFormWnd);
  if Assigned(LsFormWnd) then begin
    if IsClass(LsFormWnd[LsFormWnd.Count-1],TFormWnd,pointer(f)) then f.ActiveForm:=true;
  	if LsFormWnd.Count=1 then begin
      {if FNextClipboardViewer<>0 then begin
        ChangeClipboardChain(Application.MainForm.Handle,FNextClipboardViewer); FNextClipboardViewer:=0;
      end;}
      ListDestroyObj(Application.MainForm,LsFormWnd);
    end;
  end;
  i:=Length(afMin);
  if i>0 then begin
    Dec(i); WindowState:=afMin[i].ws; SetLength(afMin,i);
  end;
  DelStack;
end;

{ $IFDEF NCACT}
procedure TFormWnd.WMNCActivate;
var fgd: boolean;
begin
	AddStack('TFormWnd.WMNCActivate',Self);
  fgd := GetForegroundWindow=Handle;
	with Message do
  	if (Active or not FActiveForm or not fgd) then inherited else result:=0;
  DelStack;
end;
{ $ENDIF}

procedure TFormWnd.Activate;
begin
end;

procedure TFormWnd.Deactivate;
begin
end;

procedure TFormWnd.DoShow;
begin
  AddStack('TFormWnd.DoShow',Self);
	ActiveForm:=true;
  //if WindowState=wsMaximized then ShowWindow(Handle,SW_MAXIMIZE);
  inherited DoShow;
  inherited Activate;
  ProcControlsMsg(Self,WM_ACTFORM,Word(true));
  DelStack;
end;

procedure TFormWnd.DoHide;
begin
  AddStack('TFormWnd.DoHide',Self);
  ProcControlsMsg(Self,WM_ACTFORM,Word(false));
  inherited Deactivate;
  inherited DoHide;
	ActiveForm:=false;
  DelStack;
end;

procedure TFormWnd.SetBounds;
var r: TRect;
begin
	AddStack('TFormWnd.SetBounds',Self);
  if WindowState<>wsMaximized then begin
  	r:=Rect(ALeft,ATop,ALeft+AWidth,ATop+AHeight); UserWorkArea(r);
  	inherited SetBounds(r.Left,r.Top,r.Right-r.Left,r.Bottom-r.Top);
  end;
  DelStack;
end;

procedure TFormWnd.WMEnterMenuLoop;
begin
	AddStack('TFormWnd.WMEnterMenuLoop',Self);
	inherited;
  SetButShow(false);
  DelStack;
end;

procedure TFormWnd.WMExitMenuLoop;
begin
	AddStack('TFormWnd.WMExitMenuLoop',Self);
	inherited;
  if FActiveForm then SetButShow(true);
  DelStack;
end;

procedure TFormWnd.WMClose;
begin
  AddStack('TFormWnd.WMClose',Self);
  ProcControlsMsg(Self,WM_CLOSEFORM);
  inherited;
  DelStack;
end;

procedure TFormWnd.SetActiveForm;
begin
	AddStack('TFormWnd.SetActiveForm',Self);
	FActiveForm:=Value; SetButShow(Value);
  DelStack;
end;

procedure TFormWnd.SetButShow;
var tl: TKeyLb;
begin
	AddStack('TFormWnd.SetButShow',Self);
  if FormKeyLb(Self,tl) then tl.ButShowing:=lShow;
  DelStack;
end;

class procedure TFormWnd.ApplException;
var fl,oms: boolean;
    s: string;
begin
	E.Message:=E.ClassName+':'+CRLF+E.Message;
  fl := not(csDesigning in Application.ComponentState);
  if fl then begin
    s:='';
    if @ApplExceptionProc<>nil then ApplExceptionProc(s,E);
    OutStack(s+E.Message,[outstClear]);
  end;
  oms:=MessagesHidden; MessagesHidden:=false; MsgDlg(E.Message); MessagesHidden:=oms;
  if fl then Application.Terminate;
end;

{ $IFDEF NCACT}
class procedure TFormWnd.ApplActivate;
var f: TFormWnd;
begin
  AddStack('TFormWnd.ApplActivate');
  if LastForm(f) then if f.ActiveForm then f.BringToFront;
  DelStack;
end;
{ $ENDIF}

class procedure TFormWnd.StdProcKey;
begin
	AddStack('TFormWnd.StdProcKey');
  KeyEvalProc(Key,tw,aWndKeyProc);
  DelStack;
end;

class function TFormWnd.LastForm: TFormWnd;
begin
  AddStack('TFormWnd.LastForm');
  if Assigned(LsFormWnd)
  then result:=LsFormWnd[LsFormWnd.Count-1]
  else IsClass(Application.MainForm,TFormWnd,pointer(result));
  DelStack;
end;

class function TFormWnd.LastForm(var f: TFormWnd): boolean;
begin
  f:=LastForm; result:=Assigned(f);
end;

function LastForm: TForm;
begin
  result:=TFormWnd.LastForm;
end;

function IsLastForm(var f: TForm): boolean;
begin
  result:=TFormWnd.LastForm(TFormWnd(f));
end;

procedure TFormWnd.LimUslTime;
var fl: boolean;
begin
  AddStack('TFormWnd.LimUslTime',Self);
  if not(Visible or NoLimit) then begin
    if Assigned(pTime) then fl := TimeLimit<pTime^ else fl:=true;
    if fl then Perform(WM_FORMLIMIT,0,0);
  end;
  DelStack;
end;

procedure TFormWnd.FormOnScreen;
begin
  AddStack('TFormWnd.FormOnScreen',Self);
  My_pr.FormOnScreen(Self);
  DelStack;
end;

procedure TFormWnd.MainRebuild;
begin
  AddStack('TFormWnd.MainRebuild',Self);
  FPanel.MainRebuild(Self,lSetRdw);
  DelStack;
end;

procedure TFormWnd.RbFormResize;
begin
  AddStack('TFormWnd.RbFormResize',Self);
  FPanel.RbFormResize(Self);
  DelStack;
end;

procedure TFormWnd.SetSchemForm;
begin
  AddStack('TFormWnd.SetSchemForm',Self);
  FPanel.SetSchemForm(Self);
  DelStack;
end;

function TFormWnd.VisibleNoNil;
begin
  AddStack('TFormWnd.VisibleNoNil',Self);
  if Assigned(Self) then result:=Visible else result:=false;
  DelStack;
end;

procedure TFormWnd.WMRebuild;
var tl: TKeyLb;
begin
	AddStack('TFormWnd.WMRebuild',Self);
  if Message.WParam=1 then
    if FormKeyLb(Self,tl) then
    	if not tl.Visible then tl.Redrw;
  DelStack;
end;

procedure TFormWnd.WMCngPriv;
begin
  AddStack('TFormWnd.WMCngPriv',Self);
  if LsFormLimit[0]=Self then TKeyLb.FixKeyShow(K_Alt_B,CanPriv(PrivDesign));
  DelStack;
end;

{procedure TFormWnd.WMChangeCBChain;
begin
  AddStack('TFormWnd.WMChangeCBChain',Self);
  inherited;
  if Self=LsFormWnd[0] then begin
    Message.Result:=0;
    if Message.Remove=FNextClipboardViewer then FNextClipboardViewer:=Message.Next
    else SendMessage(FNextClipboardViewer,WM_CHANGECBCHAIN,Message.Remove,Message.Next);
  end;
  DelStack;
end;

procedure TFormWnd.WMDrawClipboard;
begin
  AddStack('TFormWnd.WMDrawClipboard',Self);
  inherited;
  if Self=LsFormWnd[0] then if not NoDrawClipboard then begin
    NoDrawClipboard:=true;
    try
      MsgApplication(WM_CNGCLPBRD);
    finally
      SendMessage(FNextClipboardViewer,WM_DRAWCLIPBOARD,0,0); NoDrawClipboard:=false;
    end;
  end;
  DelStack;
end;}

procedure TFormWnd.FormActivate(Sender: TObject);
begin
	AddStack('TFormWnd.FormActivate',Self);
  DelStack;
end;

procedure TFormWnd.FormDeactivate(Sender: TObject);
begin
	AddStack('TFormWnd.FormDeactivate',Self);
  DelStack;
end;

procedure TFormWnd.FormHide(Sender: TObject);
begin
	AddStack('TFormWnd.FormHide',Self);
  DelStack;
end;

procedure TFormWnd.FormShow(Sender: TObject);
begin
	AddStack('TFormWnd.FormShow',Self);
  DelStack;
end;

procedure TFormWnd.SetModalResult;
label lend;
begin
	AddStack('TFormWnd.SetModalResult',Self);
  ModalResult:=mr;
  if Assigned(LsFormWnd) then
  	if LsFormWnd.Count>0 then
			if Self<>LsFormWnd[0] then goto lend;
  Close; ModalResult:=mr;
lend:
  DelStack;
end;

procedure TFormWnd.TimerFormClose;
begin
  AddStack('TFormWnd.TimerFormClose',Self);
  TTimerOne.CreateProc(TimerClos,Self).Tag:=mr;
  DelStack;
end;

procedure TFormWnd.TimerClos;
begin
  AddStack('TFormWnd.TimerClos',Self);
  ModalResult:=TTimerOne(Sender).Tag;
  DelStack;
end;

procedure TFormWnd.AfterCreate;
begin
end;

function TFormWnd.FreeLimit(var f): boolean;
begin
  AddStack('TFormWnd.FreeLimit',Self);
  result := Self=pointer(f);
  if result then FreeAndNil(f);
  DelStack;
end;

procedure TFormWnd.FreeLimit(ls: TList; var nForm: longint);
var i: longint;
begin
  AddStack('TFormWnd.FreeLimit(ls)',Self);
  with ls do begin
    i:=IndexOf(Self);
    if i>=0 then begin
    	if i<=nForm then Dec(nForm);
	  	Delete(i);
    end;
  end;
  Free;
  DelStack;
end;

function CreateForm(ComponentClass: TComponentClass; var Reference;
  lNoLimit: boolean = true): boolean;
  procedure LimUslTime(pTime: PDateTime);
  var i,ocnt: longint;
  begin
    AddStack('FrmWnd.CreateForm.LimUslTime');
    i:=0;
    with LsFormLimit do while i<Count do begin
      oCnt:=Count; TFormWnd(Items[i]).LimUslTime(pTime);
      if oCnt=Count then Inc(i) else i:=0;
    end;
    DelStack;
  end;
var ost,i,ocnt: longint;
  ADay,AHour,AMinute: Word;
	t: TDateTime;
  lBreak: boolean;
  f: TFormWnd;
begin
  ost:=AddStack('FrmWnd.CreateForm: '+ComponentClass.ClassName);
	result := not Assigned(pointer(Reference));
	if result then begin
    if Assigned(LsFormLimit) then with LsFormLimit do begin
      if Count>=FormLimit then begin
        AHour:=FormLimTime div MinsPerHour;
        AMinute:=FormLimTime mod SecsPerMin;
        ADay:=AHour div HoursPerDay;
        ModD(AHour,HoursPerDay);
        t:=Now-ADay-EncodeTimeTry(AHour,AMinute,0,0);
        LimUslTime(@t);
        if Count>=FormLimit then LimUslTime(nil);
      end;
    end;
    lBreak:=true;
    repeat
      try
        Application.CreateForm(ComponentClass,Reference);
        if lNoLimit and IsClass(TObject(Reference),TFormWnd,pointer(f)) then f.NoLimit:=true;
        lBreak:=true;
      except
        on EOsError do begin
          SetStack(ost);
          FormWndDestroying:=true;
          TObject(Reference).Free;
          FormWndDestroying:=false;
          lBreak:=true;
          if Assigned(LsFormLimit) then with LsFormLimit do begin
            i:=0;
            while i<Count do begin
              oCnt:=Count; TFormWnd(Items[i]).LimUslTime(nil);
		          if oCnt=Count then Inc(i)
              else begin
              	lBreak:=false; i:=0;
              end;
            end;
          end;
          if not lBreak then lBreak:=MsgDlg(['Ошибка создания формы.',
            'Возможно, запущено слишком много программ.',
            'Закройте другие программы.','Продолжить ?'],mtConfirmation,
            [mbYes,mbNo],0)<>mrYes;
          if lBreak then Application.Terminate;
        end;
      end;
    until lBreak;
  end;
  DelStack;
end;

function FormFree(var f): boolean;
var frm: TForm;
begin
  AddStack('FrmWnd.FormFree');
  result:=FormsFree; frm:=pointer(f);
  if result and Assigned(frm) then result:=not frm.Visible;
  if result then FreeAndNil(f)
  else if frm is TFormWnd then TFormWnd(frm).NoLimit:=false;
  DelStack;
end;

procedure WndKeyProc(Key: longint; tw: TWinControl; var lBreak: boolean);
var wp: TWindowPlacement;
begin
  AddStack('FrmWnd.WndKeyProc');
  lBreak:=true;
  with ParentForm(tw) do case key of
    K_Ctrl_M: if biMinimize in BorderIcons then
      if Screen.ActiveForm=Application.MainForm then Application.Minimize
      else begin
        wp.length:=SizeOf(wp); GetWindowPlacement(Handle,@wp);
        wp.showCmd:=SW_MINIMIZE; SetWindowPlacement(Handle,@wp);
      end;
    K_Ctrl_N: if biMaximize in BorderIcons then WindowState:=iif(WindowState=wsNormal,wsMaximized,wsNormal);
  else lBreak:=false;
  end;
  DelStack;
end;

function TFormWnd.BrEditProc;
begin
  AddStack('TFormWnd.BrEditProc',Self);
  if Capt<>'' then Caption:=Capt;
  result := ShowModal=mrOk;
  DelStack;
end;

function BrEditProc(Sender: TObject; lApp: boolean; const Capt: TCaption;
  const glkey,nmfCode,dwValue,dwNameWnd,dwNameScr: string; var Modified: boolean): boolean;
begin
  AddStack('FrmWnd.BrEditProc');
  result := Sender is TFormWnd;
  if result then Modified:=TFormWnd(Sender).BrEditProc(lApp,Capt,glkey);
  DelStack;
end;

initialization
	AddStack('FrmWnd.initialization');
  MyTypes.CreateForm:=CreateForm; MyTypes.FormFree:=FormFree;
  MyTypes.BeforeShowOther:=BeforeShowOther; MyTypes.AfterShowOther:=AfterShowOther;
  MyTypes.LastForm:=LastForm; MyTypes.IsLastForm:=IsLastForm;
  AddFrom(aWndKeyProc,WndKeyProc);
  AddFrom(BrEditProc);
  TKeyLb.SetFixKey(K_F9,'Калькулятор',TFormWnd.StdProcKey,kmFile);
  TKeyLb.SetFixKey(K_Ctrl_M,'Свернуть',TFormWnd.StdProcKey,kmFile);
  TKeyLb.SetFixKey(K_Ctrl_N,'Развернуть/Восстановить',TFormWnd.StdProcKey,kmFile);
  DelStack;
end.
