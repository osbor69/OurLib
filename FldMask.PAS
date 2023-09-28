unit FldMask;

interface

uses Messages,Classes,Mask,Controls,
  MyTypes,KeyMenu;

type
	TFMMoveCaret = procedure(Sender: TObject; oldPos,oldLen: longint) of object;

	TFldMask = class(TMaskEdit)
  private
    MainMn: TKeyMenu;
    oldPos,oldLen: longint;
		dCalc: double;
    FOnMoveCaret: TFMMoveCaret;
    FFocused: boolean;
    procedure CbCut(Sender: TObject);
    procedure CbCopy(Sender: TObject);
    procedure CbPaste(Sender: TObject);
    procedure DelLine(Sender: TObject);
    procedure FSelAll(Sender: TObject);
    procedure CreatingCaret;
    procedure SettingCaretPos;
    procedure EMSetReadOnly(var msg: TMessage); message EM_SETREADONLY;
    procedure WMInsModeCng(var Message: TMessage); message WM_INSMODECNG;
		procedure WMCalc(var msg: TWMCalc); message WM_CALC;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure EMSetSel(var Message: TMessage); message EM_SETSEL;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;
  protected
    procedure MoveCaret; dynamic;
    procedure CreateWnd; override;
		procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Click; override;
    procedure DoEnter; override;
    procedure DoExit; override;
		procedure DragOver(Source: TObject; x,y: longint;
    	State: TDragState; var Accept: boolean); override;
   	procedure KeyDown(var Key: Word; Shift: TShiftState); override;
		procedure KeyPress(var Key: Char); override;
   	procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure Change; override;
    procedure Resize; override;
  public
    TrimLeft: boolean;
    SelAllStart,SelAllLength: longint;
    constructor Create(AOwner: TComponent); override;
		procedure DragDrop(Source: TObject; x,y: longint); override;
    procedure ValidateEdit; override;
    procedure SelAll(lBound: boolean = false);
		function Check: boolean;
    procedure IncText(const d2: string);
		function SelProcKey(Proc: TSelProcKey): boolean;
    property OnMoveCaret: TFMMoveCaret read FOnMoveCaret write FOnMoveCaret;
  end;

implementation

uses Windows,Forms,SysUtils,Graphics,StrUtils,Math,ClipBrd,
  My_pr,KeyLb;

{ TFldMask }
constructor TFldMask.Create;
begin
  AddStack('TFldMask.Create',Self);
  inherited Create(AOwner);
  AutoSelect:=false;
  DelStack;
end;

procedure TFldMask.CreateWnd;
begin
	AddStack('TFldMask.CreateWnd',Self);
	inherited CreateWnd;
  SeekKeyMenu(Self,MainMn);
  DelStack;
end;

procedure TFldMask.Notification;
begin
  AddStack('TFldMask.Notification',Self);
  SeekKeyMenu(Self,MainMn,AComponent,Operation);
  DelStack;
end;

procedure TFldMask.WMInsModeCng;
begin
  AddStack('TFldMask.WMInsModeCng',Self);
	inherited;
  CreatingCaret;
  DelStack;
end;

procedure TFldMask.WMSetFocus;
begin
  AddStack('TFldMask.WMSetFocus',Self);
  inherited;
  CreatingCaret;
  DelStack;
end;

procedure TFldMask.CreatingCaret;
var cnv: TCanvas;
begin
  AddStack('TFldMask.CreatingCaret',Self);
  if FFocused then begin
    cnv:=GetParentForm(Self).Canvas; cnv.Font.Assign(Font);
    if InsModeOverride
    then CreateCaret(Handle,0,CanvasMaxW(cnv),0)
    else CreateCaret(Handle,0,0,CanvasMaxH(cnv));
    SettingCaretPos; ShowCaret(Handle);
  end;
  DelStack;
end;

procedure TFldMask.SettingCaretPos;
var p: TPoint;
begin
  AddStack('TFldMask.SettingCaretPos',Self);
  GetCaretPos(p);
  SetCaretPos(p.X,IfThen(InsModeOverride,min(-Font.Height,Height-1)));
  DelStack;
end;

procedure TFldMask.EMSetSel;
begin
  AddStack('TFldMask.EMSetSel',Self);
  inherited;
  SettingCaretPos;
  DelStack;
end;

procedure TFldMask.WMChar;
begin
  AddStack('TFldMask.WMChar',Self);
  inherited;
  SettingCaretPos;
  DelStack;
end;

procedure TFldMask.WMKeyDown;
begin
  AddStack('TFldMask.WMKeyDown',Self);
  inherited;
  SettingCaretPos;
  DelStack;
end;

procedure TFldMask.WMLButtonDown;
begin
  AddStack('TFldMask.WMLButtonDown',Self);
  inherited;
  SettingCaretPos;
  DelStack;
end;

procedure TFldMask.Resize;
begin
  AddStack('TFldMask.Resize',Self);
  inherited Resize;
  CreatingCaret;
  DelStack;
end;

procedure TFldMask.WMPaint;
begin
  AddStack('TFldMask.WMPaint',Self);
  inherited;
  SettingCaretPos;
  DelStack;
end;

procedure TFldMask.WMPaste;
var Data: THandle;
  p: pointer;
  s: string;
  l: longint;
begin
  AddStack('TFldMask.WMPaste',Self);
//meserr(1);
  with Clipboard do begin
//meserr(2);
    Open;
//meserr(3);
    Data:=GetClipboardData(CF_UNICODETEXT);
    try
//meserr(4);
      if Data<>0 then begin
//meserr(5);
        p:=GlobalLock(Data);
//meserr(6);
        l:=GlobalSize(Data);
//meserr(7);
        SetLength(s,l);
//meserr(8);
        CopyMemory(pointer(s),p,l);
//meserr(9);
        Clipboard.AsText:=Utf16ToWin(s);
      end;
    finally
//meserr(10);
      if Data<>0 then begin
//meserr(11);
        GlobalUnlock(Data);
      end;
//meserr(12);
      Close;
//meserr(13);
    end;
  end;
  inherited;
  DelStack;
end;

procedure TFldMask.EMSetReadOnly;
begin
	AddStack('TFldMask.EMSetReadOnly',Self);
	inherited;
  if FFocused and Assigned(MainMn) then with MainMn do begin
    EnabledItem(kmEdit,K_Ctrl_X,not ReadOnly);
    EnabledItem(kmEdit,K_Ctrl_V,not ReadOnly);
  end;
  DelStack;
end;

procedure TFldMask.Click;
begin
	AddStack('TFldMask.Click',Self);
	inherited Click;
  MoveCaret;
  DelStack;
end;

procedure TFldMask.KeyDown;
begin
	AddStack('TFldMask.KeyDown',Self);
  if Shift=[ssCtrl] then case Key of
    // Выделить всё
    Word('A'): begin
      SelAll(true); Key:=0;
    end;
    // Удаление до конца строки
    Word('Y'): if not ReadOnly then begin
      DelLine(Self); Key:=0;
    end;
  end;
	inherited KeyDown(Key,Shift);
  MoveCaret;
  DelStack;
end;

procedure TFldMask.KeyPress;
var i,j: longint;
begin
	AddStack('TFldMask.KeyPress',Self);
	if Ord(Key) in [vk_Return,14,vk_Escape] then Key:=#0;
  // Удаление слова <Ctrl+BackSpace>
  if Key=#127 then begin
	  i:=SelStart;
    if empty(LeftStr(Text,i)) then j:=0
    else begin
    	j:=i;
      while j>0 do
        if Text[j]=' ' then Dec(j) else break;
      while j>0 do
        if Text[j]=' ' then break else Dec(j);
    end;
    Text:=LeftStr(Text,j)+copy(Text,i+1,MaxInt); SelStart:=j; SelLength:=0; Key:=#0;
  end;
  // Замена
  if InsModeOverride and (Key<>#0) and (SelLength=0) then SelLength:=1;
  inherited KeyPress(Key);
  MoveCaret;
  DelStack;
end;

procedure TFldMask.KeyUp;
begin
	AddStack('TFldMask.KeyUp',Self);
	inherited KeyUp(Key,Shift);
  MoveCaret;
  DelStack;
end;

procedure TFldMask.DoEnter;
var tl: TKeyLb;
begin
	AddStack('TFldMask.DoEnter',Self);
  if not IsCalculator then begin
    FFocused:=true;
    inherited DoEnter;
    if FormKeyLb(Self,tl) then tl.DelKey(K_All,'rbscrollbox');
    if Assigned(MainMn) then with MainMn do begin
      CngProcItem(kmEdit,K_Ctrl_X,CbCut);
      CngProcItem(kmEdit,K_Ctrl_C,CbCopy);
      CngProcItem(kmEdit,K_Ctrl_V,CbPaste);
      AddItem(kmEdit,K_Ctrl_Y,'Удалить до конца строки',Self.DelLine);
      AddItem(kmEdit,K_Ctrl_A,'Выделить всё',FSelAll);
      EnabledItem(kmEdit,K_Ctrl_X,not ReadOnly);
      EnabledItem(kmEdit,K_Ctrl_V,not ReadOnly);
      EnabledItem(kmEdit,K_Ctrl_Y,not ReadOnly);
      EnabledItem(kmEdit,K_Ctrl_A,Text<>'');
    end;
    oldPos:=-1; oldLen:=0; MoveCaret;
  end;
  DelStack;
end;

procedure TFldMask.DoExit;
begin
	AddStack('TFldMask.DoExit',Self);
  if not IsCalculator then begin
    if Assigned(MainMn) then with MainMn do begin
      EnabledItem(kmEdit,K_Ctrl_X,false);
      EnabledItem(kmEdit,K_Ctrl_C,false);
      EnabledItem(kmEdit,K_Ctrl_V,false);
      EnabledItem(kmEdit,K_Ctrl_Y,false);
      EnabledItem(kmEdit,K_Ctrl_A,false);
    end;
    inherited DoExit;
    FFocused:=false;
  end;
  DelStack;
end;

procedure TFldMask.MoveCaret;
var newPos,newLen: longint;
begin
	AddStack('TFldMask.MoveCaret',Self);
  SettingCaretPos; newPos:=SelStart; newLen:=SelLength;
  if Assigned(MainMn)  and FFocused then with MainMn do begin
    if oldLen<>newLen then begin
      EnabledItem(kmEdit,K_Ctrl_X,(newLen<>0) and not ReadOnly);
      EnabledItem(kmEdit,K_Ctrl_C,newLen<>0);
    end;
    EnabledItem(kmEdit,K_Ctrl_A,Text<>'');
  end;
  if not((oldPos=newPos) and (oldLen=newLen)) and Assigned(FOnMoveCaret)
  then FOnMoveCaret(Self,oldPos,oldLen);
  oldPos:=newPos; oldLen:=newLen;
  DelStack;
end;

procedure TFldMask.CbCut;
begin
	AddStack('TFldMask.CbCut',Self);
	CutToClipboard; MoveCaret;
  DelStack;
end;

procedure TFldMask.CbCopy;
begin
	AddStack('TFldMask.CbCopy',Self);
	CopyToClipboard; MoveCaret;
  DelStack;
end;

procedure TFldMask.CbPaste;
begin
	AddStack('TFldMask.CbPaste',Self);
	PasteFromClipboard; MoveCaret;
  DelStack;
end;

procedure TFldMask.DelLine;
var i: longint;
begin
	AddStack('TFldMask.DelLine',Self);
  i:=SelStart; Text:=LeftStr(Text,i); SelStart:=i; SelLength:=0; MoveCaret;
  DelStack;
end;

procedure TFldMask.FSelAll;
begin
  AddStack('TFldMask.FSelAll',Self);
  SelAll(true);
  DelStack;
end;

// Передать текст в калькулятор
procedure TFldMask.WMCalc;
var c: char;
	s: string;
begin
	AddStack('TFldMask.WMCalc',Self);
	inherited;
  case msg.Operation of
  	clcGet: begin
    	s:=SysUtils.TrimLeft(Text);
      if s<>'' then begin
        c:=s[1];
        if IsDigit(c) or (c in ['.',',',DecimalSeparator,'+','-']) then begin
	        msg.ps^:=Float0(s); msg.result:=1;
        end;
      end;
    end;
  	clcSet: begin
    	dCalc:=msg.ps^; DragDrop(nil,0,0);
    end;
  	clcCanSet: if not ReadOnly then msg.result:=1;
  end;
  DelStack;
end;

// Взять текст из калькулятора
procedure TFldMask.DragOver;
begin
	AddStack('TFldMask.DragOver',Self);
	inherited DragOver(Source,X,Y,State,Accept);
  Accept := ((Source=Self) or not ReadOnly) and MsgCalc(pointer(Source),clcGet,@dCalc);
  DelStack;
end;

procedure TFldMask.DragDrop;
begin
	AddStack('TFldMask.DragDrop',Self);
	inherited DragDrop(Source,X,Y);
	if NoFromCalc(Owner,dCalc,x,y) then Text:=FloatToStr(dCalc);
  DelStack;
end;

procedure TFldMask.SelAll;
begin
  AddStack('TFldMask.SelAll',Self);
  if not(csDestroying in ComponentState) then
    if lBound or (AutoSelect and FFocused) then
      if SelAllLength=0 then begin
        SelStart:=0; SelLength:=Length(Text);
      end
      else begin
        SelStart:=SelAllStart; SelLength:=SelAllLength;
      end
    else SelStart:=0;
  DelStack;
end;

procedure TFldMask.ValidateEdit;
begin
end;

function TFldMask.Check;
var s: string;
  p: longint;
begin
  AddStack('TFldMask.Check',Self);
  if IsMasked then begin
  	s:=EditText; result:=Validate(s,p);
  end
  else result:=true;
  DelStack;
end;

procedure TFldMask.Change;
begin
  AddStack('TFldMask.Change',Self);
  inherited Change;
  if TrimLeft and (Text<>'') then
    if Text[1]<=' ' then Text:=SysUtils.TrimLeft(Text);
  DelStack;
end;

procedure TFldMask.IncText;
begin
  Text:=Text+d2;
end;

function TFldMask.SelProcKey;
var ss,sl: longint;
begin
  AddStack('TFldMask.SelProcKey',Self);
  result := Visible and Enabled and not ReadOnly;
  if result then if Assigned(Proc) then begin
    sl:=SelLength;
    if sl>0 then begin
    	ss:=SelStart; Text:=StuffString(Text,ss+1,sl,Proc(Copy(Text,ss+1,sl)));
      SelStart:=ss; SelLength:=sl; MoveCaret;
    end;
  end;
  DelStack;
end;

end.

