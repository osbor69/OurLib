unit RbScroll;

interface

uses
  Windows,Messages,Classes,Controls,Forms,
  MyTypes,FPanel,Schem;

type
	TRBScrlKind = (skVert,skHorz);
  TRBScrlScrollEvent = procedure(Sender: TObject; Kind: TRBScrlKind; Code,Pos: SmallInt) of object;

	TRBScrlExitMode = (emLeft,emTop,emRight,emBottom);
	TRBScrlExit = procedure(Sender: TObject; Mode: TRBScrlExitMode) of object;

  TRbScrollOptions = set of (rsoNoKeys);

  TRbScrollBox = class(TScrollBox)
  private
    { Private declarations }
    Entered,FStopRebuild: boolean;
    FOptions: TRbScrollOptions;
    FOnExitRange: TRBScrlExit;
    FOnScroll: TRBScrlScrollEvent;
		procedure ProcKey(key: longint; tw: TWinControl);
   	procedure WMRebuild(var msg: TWMRebuild); message WM_REBUILD;
    procedure WMSchem(var msg: TWMSchem); message WM_SCHEM;
    procedure WMHScroll(var msg: TWMScroll); message WM_HSCROLL;
    procedure WMVScroll(var msg: TWMScroll); message WM_VSCROLL;
  protected
    { Protected declarations }
    procedure ExitRange(Mode: TRBScrlExitMode); dynamic;
    procedure Scroll(Kind: TRBScrlKind; Code,Pos: SmallInt); dynamic;
    procedure DoEnter; override;
    procedure DoExit; override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
  public
    { Public declarations }
    destructor Destroy; override;
  published
    { Published declarations }
    property StopRebuild: boolean read FStopRebuild write FStopRebuild;
    property Options: TRbScrollOptions read FOptions write FOptions;
    property OnExitRange: TRBScrlExit read FOnExitRange write FOnExitRange;
    property OnScroll: TRBScrlScrollEvent read FOnScroll write FOnScroll;
  end;

procedure Register;

implementation

uses Math,
  My_pr,KeyLb;

{ TRbScrollBox }
destructor TRbScrollBox.Destroy;
begin
	AddStack('TRbScrollBox.Destroy',Self);
  if Entered and not(csDestroying in Application.ComponentState) then DoExit;
  inherited Destroy;
  DelStack;
end;

procedure TRbScrollBox.WMHScroll;
begin
	AddStack('TRbScrollBox.WMHScroll',Self);
	inherited;
  Scroll(skHorz,msg.ScrollCode,msg.Pos);
  DelStack;
end;

procedure TRbScrollBox.WMVScroll;
begin
	AddStack('TRbScrollBox.WMVScroll',Self);
	inherited;
  Scroll(skVert,msg.ScrollCode,msg.Pos);
  DelStack;
end;

procedure TRbScrollBox.Scroll;
begin
	AddStack('TRbScrollBox.Scroll',Self);
	if Assigned(FOnScroll) then FOnScroll(Self,Kind,Code,Pos);
  DelStack;
end;

procedure TRbScrollBox.WMRebuild;
var i,j,r,b: longint;
  tc: TControl;
begin
	AddStack('TRbScrollBox.WMRebuild',Self);
 	with msg.RbPnl do begin
  	i:=HeaderHeight; Self.SetBounds(BevPanel,BevPanel+i,CltWidth,CltHeight-i);
  end;
  if not FStopRebuild then for i:=0 to ControlCount-1 do
    if Controls[i] is TCustomRbPanel then with TCustomRbPanel(Controls[i]) do begin
      SetWHMin(nil,Self.ClientWidth); ReBuild(Self.ClientWidth,Self.ClientHeight);
      if Self.Controls[i] is TRbPanel then with TRbPanel(Self.Controls[i]) do
        if ProcentWnd=100 then
          if SortMode=smDefault then begin
            r:=0; b:=0;
            for j:=0 to ControlCount-1 do begin
              tc:=Controls[j];
              if tc.Visible then begin
                MaxSelf(r,tc.Left+tc.Width); MaxSelf(b,tc.Top+tc.Height);
              end;
            end;
            if r+BevPanel<Self.ClientWidth then SetBounds(0,Top,Self.ClientWidth,Height)
            else SetBounds(0,Top,r+BevPanel,Height);
            if b+BevPanel-1<Self.ClientHeight then SetBounds(Left,0,Width,Self.ClientHeight)
            else SetBounds(Left,0,Width,b+BevPanel-1);
          end
          else begin
            if WMin+BevPanel2<Self.ClientWidth then SetBounds(0,Top,Self.ClientWidth,Height);
            if HMin+BevPanel2<Self.ClientHeight then SetBounds(Left,0,Width,Self.ClientHeight);
          end;
      break;
    end;
  DelStack;
end;

// Установка цветов и шрифтов
procedure TRbScrollBox.WMSchem;
begin
	AddStack('TRbScrollBox.WMSchem',Self);
 	Color:=msg.Schem.ColorW;
  DelStack;
end;

// Выход за границы
procedure TRbScrollBox.ExitRange;
begin
	AddStack('TRbScrollBox.ExitRange',Self);
	if Assigned(FOnExitRange) then FOnExitRange(Self,Mode);
  DelStack;
end;

procedure TRbScrollBox.DoEnter;
const
  a: array[1..12] of record
    key: longint;
    hnt: string;
  end =
  ((key:K_Up         ; hnt:'Вверх')
  ,(key:K_Down       ; hnt:'Вниз')
  ,(key:K_Left       ; hnt:'Влево')
  ,(key:K_Right      ; hnt:'Вправо')
  ,(key:K_PgUp       ; hnt:'На предыдущую вертикальную видимую область')
  ,(key:K_PgDn       ; hnt:'На следующую вертикальную видимую область')
  ,(key:K_Shift_Left ; hnt:'На предыдущую горизонтальную видимую область')
  ,(key:K_Shift_Right; hnt:'На следующую горизонтальную видимую область')
  ,(key:K_Ctrl_Home  ; hnt:'На первую вертикальную видимую область')
  ,(key:K_Ctrl_End   ; hnt:'На последнюю вертикальную видимую область')
  ,(key:K_Home       ; hnt:'На первую горизонтальную видимую область')
  ,(key:K_End        ; hnt:'На последнюю горизонтальную видимую область')
  );
var tl: TKeyLb;
	i: longint;
begin
	AddStack('TRbScrollBox.DoEnter',Self);
	if not isCalculator then begin
    inherited DoEnter;
    if not(rsoNoKeys in Self.Options) then
      if FormKeyLb(Self,tl) then for i:=low(a) to high(a) do with a[i] do
      	if not tl.IsAllKeyBut(key) then tl.SetKey(key,'',hnt,ProcKey,'rbscrollbox',kmNone);
    Entered:=true;
  end;
  DelStack;
end;

procedure TRbScrollBox.DoExit;
var tl: TKeyLb;
begin
	AddStack('TRbScrollBox.DoExit',Self);
	if not isCalculator then begin
    if not(rsoNoKeys in Self.Options) then
      if FormKeyLb(Self,tl)
      //and Assigned(GetParentForm(Self).ActiveControl)
      then tl.DelKey(K_All,'rbscrollbox');
    inherited DoExit;
    Entered:=false;
  end;
  DelStack;
end;

function TRbScrollBox.DoMouseWheelDown;
begin
  AddStack('TRbScrollBox.DoMouseWheelDown',Self);
  result:=inherited DoMouseWheelDown(Shift,MousePos);
  perform(WM_VSCROLL,SB_LINEDOWN,0);
  DelStack;
end;

function TRbScrollBox.DoMouseWheelUp;
begin
  AddStack('TRbScrollBox.DoMouseWheelUp',Self);
  result:=inherited DoMouseWheelUp(Shift,MousePos);
  perform(WM_VSCROLL,SB_LINEUP,0);
  DelStack;
end;

procedure TRbScrollBox.ProcKey;
var tl: TKeyLb;
  procedure SetPosition(Kind: TRBScrlKind; Pos: SmallInt);
  var sc: TControlScrollBar;
  	p: SmallInt;
  begin
    AddStack('TRbScrollBox.ProcKey.SetPosition',Self);
    sc:=IfThen(Kind=skVert,VertScrollBar,HorzScrollBar);
    if Pos<>sc.Position then begin
	    p:=sc.Position; sc.Position:=Pos; Scroll(Kind,-1,Pos);
      if sc.Position<>p then tl.NoEval:=false;
    end;
    DelStack;
  end;
var scb: TControlScrollBar;
	sk: TRBScrlKind;
	i,t,h,ch,p: longint;
begin
	AddStack('TRbScrollBox.ProcKey',Self);
  FormKeyLb(Self,tl); tl.NoEval:=true;
	case Key of
  	K_Home: SetPosition(skHorz,0);
  	K_End: SetPosition(skHorz,HorzScrollBar.Range);
  	K_Ctrl_Home: begin
    	SetPosition(skVert,0); SetPosition(skHorz,0);
    end;
  	K_Ctrl_End: begin
    	SetPosition(skVert,VertScrollBar.Range);
      SetPosition(skHorz,HorzScrollBar.Range);
    end;
  else
    if Key in [K_Left,K_Right,K_Shift_Left,K_Shift_Right] then begin
    	sk:=skHorz; scb:=HorzScrollBar;
    end
    else begin
    	sk:=skVert; scb:=VertScrollBar;
    end;
    if scb.Visible then begin
      p:=scb.Position;
      if Key in [K_Up,K_Down,K_Left,K_Right]
      then SetPosition(sk,scb.Position+scb.Increment*aSign[Key in [K_Up,K_Left]])
      else begin
        ch:=IfThen(Key in [K_PgUp,K_PgDn],ClientHeight,ClientWidth);
        if not((Key in [K_PgUp,K_Shift_Left]) and (p=0)
        or (Key in [K_PgDn,K_Shift_Right]) and (p>=scb.Range-ch))
        then begin
          SetRedraw(Self); SetPosition(sk,0); t:=MaxInt; h:=0;
          if Key in [K_PgUp,K_PgDn] then
            for i:=0 to ControlCount-1 do begin
              MinSelf(t,Controls[i].Top); MaxSelf(h,Controls[i].Height);
            end
          else
            for i:=0 to ControlCount-1 do begin
              MinSelf(t,Controls[i].Left); MaxSelf(h,Controls[i].Width);
            end;
          h:=nround(scb.Range*ch/(t+h))-5;
          if Key in [K_PgUp,K_Shift_Left] then h:=-h;
          SetPosition(sk,p+h); SetRedraw(Self,rdrwSet); 
        end;
      end;
      if scb.Position=p
      then ExitRange(iif(Key in [K_Left,K_Shift_Left],emLeft,
        iif(Key in [K_Right,K_Shift_Right],emRight,
        iif(Key in [K_Up,K_PgUp],emTop,emBottom))));
    end;
  end;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurLib',[TRbScrollBox]);
end;

end.
