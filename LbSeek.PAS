unit LbSeek;

interface

uses Windows,Classes,Controls,Graphics,
  MyTypes,KeyLb,PaintCtl;

type
	TLbSeek = class(TPaintControl)
  private
  	FKeyPanel: TKeyLb;
    FOnSeek: TNotifyEvent;
    FBevel: boolean;
    FTitleFont: TFont;
    FTitle: string;
	 	procedure PrSeek(key: longint; tw: TWinControl);
		procedure SetBevel(Value: boolean);
		procedure SetTitle(const Value: string);
  protected
		procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure FPaint; override;
		procedure FSetBounds(const Value: TRect); override;
		procedure ParentFont; override;
		procedure FontChange(Sender: TObject); override;
  public
  	CharWidth: longint;
    constructor CreateParent(AOwner: TComponent; ACharWidth: longint; AOnSeek: TNotifyEvent);
    destructor Destroy; override;
		procedure Init;
		procedure KeyDown(var Key: Word; Shift: TShiftState);
		procedure KeyPress(var Key: Char);
		function GetCaption: string;
		procedure DelKey;
    property Bevel: boolean read FBevel write SetBevel;
    property Title: string read FTitle write SetTitle;
    property TitleFont: TFont read FTitleFont write FTitleFont;
  published
    property OnSeek: TNotifyEvent read FOnSeek write FOnSeek;
  end;

implementation

uses StrUtils,ClipBrd,
  My_pr;

type TCharToKey = array[char] of longint;

const
	brCurs = '_';
	iX=5; iY=5;

var aCharToKey: ^TCharToKey;

constructor TLbSeek.CreateParent;
begin
	AddStack('TLbSeek.CreateParent',Self);
  inherited Create(AOwner);
  FTitleFont:=TFont.Create; FTitleFont.OnChange:=FontChange; FBevel:=true;
  CharWidth:=ACharWidth; OnSeek:=AOnSeek; Caption:=brCurs;
  if Owner is TControl then FKeyPanel:=FormKeyLb(TControl(Owner));
  DelStack;
end;

destructor TLbSeek.Destroy;
begin
	AddStack('TLbSeek.Destroy',Self);
  FTitleFont.Free;
  inherited Destroy;
  DelStack;
end;

procedure TLbSeek.Notification;
begin
  AddStack('TLbSeek.Notification',Self);
  if Owner is TControl then FormKeyLb(TControl(Owner),FKeyPanel,AComponent,Operation);
  DelStack;
end;

procedure TLbSeek.SetBevel;
begin
  AddStack('TLbSeek.SetBevel',Self);
  if Value<>FBevel then begin
  	FBevel:=Value; FontChange(Font);
  end;
  DelStack;
end;

procedure TLbSeek.SetTitle;
begin
  AddStack('TLbSeek.SetTitle',Self);
  if Value<>FTitle then begin
  	FTitle:=Value; FontChange(Font);
  end;
  DelStack;
end;

procedure TLbSeek.Init;
begin
  AddStack('TLbSeek.Init',Self);
  Caption:=brCurs; DelKey;
  DelStack;
end;

procedure TLbSeek.DelKey;
begin
  AddStack('TLbSeek.DelKey',Self);
  if Assigned(FKeyPanel) then begin
    FKeyPanel.DelKey(K_ALL,'lbseek'); FKeyPanel.ReDrw;
  end;
  DelStack;
end;

procedure TLbSeek.KeyDown;
var s: string;
  i: longint;
  c: Char;
begin
	AddStack('TLbSeek.KeyDown',Self);
  if (Shift=[]) and (Key=VK_BACK) then begin
	  s:=GetCaption;
    if s<>'' then begin
      Caption:=SubStr(s,1,-1)+brCurs;
      if GetCaption='' then DelKey;
      Key:=0;
    end;
  end;
  if (Shift=[ssCtrl]) and (Key=Word('V')) then begin
    {Caption:=GetCaption+ClipBoard.AsText+brCurs;
    if GetCaption='' then DelKey;}
    s:=ClipBoard.AsText;
    for i:=1 to Length(s) do begin
      c:=s[i]; KeyPress(c);
    end;
    Key:=0;
  end;
  DelStack;
end;

procedure CharToKeyInit;
const aKeyToChar: array[TKeyList] of char =
  (#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
  'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
  '0','1','2','3','4','5','6','7','8','9',',','.','+','-','*','/');
var i: longint;
begin
  AddStack('LbSeek.CharToKeyInit');
  New(aCharToKey); ZeroMemory(aCharToKey,SizeOf(aCharToKey^));
  for i:=low(aKeyToChar) to high(aKeyToChar) do
    if aKeyToChar[i]<>#0 then aCharToKey[aKeyToChar[i]]:=i;
  DelStack;
end;

procedure TLbSeek.KeyPress;
var fl,IsKey: boolean;
  nKey: longint;
begin
	AddStack('TLbSeek.KeyPress',Self);
	if not(Key in [#0..#31]) then begin
    if not Assigned(aCharToKey) then CharToKeyInit;
    nKey:=aCharToKey[Key]; IsKey:=Assigned(FKeyPanel);
    if (nKey<>0) and IsKey then fl:=not FKeyPanel.IsAllKeyBut(nKey) else fl:=true;
    if fl then begin
      fl := Caption=brCurs; Caption:=LeftStr(SubStr(Caption,1,-1)+Key+brCurs,CharWidth);
      if fl and IsKey then begin
        FKeyPanel.SetKey(K_Enter,'Найти','Быстрый поиск',PrSeek,'lbseek',kmList);
        FKeyPanel.Redrw;
      end;
      Key:=#0;
    end;
  end;
  DelStack;
end;

procedure TLbSeek.PrSeek;
begin
	AddStack('TLbSeek.PrSeek',Self);
  IfThenNotify(FOnSeek,Self); Init;
  DelStack;
end;

function TLbSeek.GetCaption;
begin
  AddStack('TLbSeek.GetCaption',Self);
  result:=RightStrDel(Caption,brCurs);
  DelStack;
end;

procedure TLbSeek.FPaint;
var r: TRect;
begin
	AddStack('TLbSeek.FPaint',Self);
  with Canvas do begin
  	if FBevel then begin
      r:=Bounds; Frame3DF(Canvas,r);
    end;
    r:=Rect(Bounds.Left+iX,Bounds.Top+iY,Bounds.Right-iX,Bounds.Bottom-iY);
    if not empty(FTitle) then begin
      DrawCaption(r,taLeftJustify,taCenter,TitleFont,@FTitle);
      Inc(r.Left,TextWidth(FTitle)+iX);
    end;
    r.Bottom:=CanvasMaxH(Canvas);
    r.Top:=Bounds.Top+(Bounds.Bottom-Bounds.Top-r.Bottom) div 2;
    Inc(r.Bottom,r.Top);
  	Brush.Color:=Color; FillRect(r); DrawCaption(r,taLeftJustify,taLeftJustify);
  end;
  DelStack;
end;

procedure TLbSeek.ParentFont;
begin
end;

procedure TLbSeek.FSetBounds;
var r: TRect;
  sz: TSize;
  w: longint;
begin
	AddStack('TLbSeek.FSetBounds',Self);
  r:=Value; Canvas.Font.Assign(Font);
  r.Right:=CanvasMaxW(Canvas)*CharWidth; r.Bottom:=CanvasMaxH(Canvas);
  if FTitle<>'' then begin
    Canvas.Font.Assign(TitleFont); sz:=Canvas.TextExtent(FTitle);
    Inc(r.Right,sz.cx+iX); MaxSelf(r.Bottom,sz.cy);
  end;
  Inc(r.Right,r.Left); Inc(r.Bottom,r.Top);
  if FBevel then begin
    Inc(r.Right,iX*2); Inc(r.Bottom,iY*2);
  end;
  w:=TCustomControl(Owner).Width;
  if r.Right-r.Left>w then begin
    r.Left:=0; r.Right:=w;
  end;
  inherited FSetBounds(r);
  DelStack;
end;

procedure TLbSeek.FontChange;
begin
	AddStack('TLbSeek.FontChange',Self);
  TCustomControl(Owner).Invalidate; Bounds:=Bounds;
  inherited FontChange(Sender);
  DelStack;
end;

initialization
finalization
  AddStack('LbSeek.finalization');
  DisposeNil(pointer(aCharToKey));
  DelStack;
end.
