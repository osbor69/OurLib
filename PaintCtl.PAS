unit PaintCtl;

interface

{$I LIBTEST}
uses Windows,Classes,Controls,Graphics,
  MyTypes;

type
	TPaintControl = class(TComponent)
  private
  	FArrBool: TByteSet;
    FColor: TColor;
  	FBounds: TRect;
    FCaption,FHint: string;
    FFont: TFont;
    FOnClick: TNotifyEvent;
    FOnMouseDown,FOnMouseUp: TMouseEvent;
    FOnMouseMove: TMouseMoveEvent;
    FCanvas: TCanvas;
		function GetArrBool(Index: longint): boolean;
		procedure SetArrBool(Index: longint; Value: boolean);
		procedure SetCaption(const Value: string);
		procedure SetColor(Value: TColor);
  protected
		procedure CaptionChange; virtual;
		procedure FontChange(Sender: TObject); virtual;
    procedure FPaint; virtual; abstract;
		procedure FSetBounds(const Value: TRect); virtual;
		procedure ParentFont; virtual;
		procedure DrawCaption(const ARect: TRect; HorzAlignment: TAlignment = taCenter;
	    VertAlignment: TAlignment = taCenter; AFont: TFont = nil; pText: PString = nil);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
		procedure SetBounds(ALeft,ATop,AWidth,AHeight: longint);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: longint); dynamic;
    procedure MouseMove(Shift: TShiftState; X,Y: longint); dynamic;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: longint); dynamic;
		procedure Click;
		procedure DoClick; dynamic;
		function perform(Msg: longword; WParam,LParam: Longint): Longint; virtual;
    procedure Paint;
		function Left: longint;
		function Top: longint;
		function Width: longint;
		function Height: longint;
    function ClientOrigin: TPoint;
    function MinSize: TSize;
    function VisibleNoNil: boolean;
		class procedure PaintAll(Sender: TWinControl);
    class function ObjWidth(Sender: TComponent): longint;
    class function ObjHeight(Sender: TComponent): longint;
    class procedure ObjSetVisible(Sender: TComponent; Visible: boolean);
    class function ObjPerform(Sender: TComponent; Msg: longword; WParam,LParam: Longint): Longint;
    class function ObjBounds(Sender: TComponent): TRect;
    class procedure ObjSetBounds(Sender: TComponent; ALeft,ATop,AWidth,AHeight: longint);
    class function MsgPaint(Sender: TComponent): boolean;
    class function nActivePaint(Owner: TComponent; X,Y: longint): longint;
    property Bounds: TRect read FBounds write FSetBounds;
    property Canvas: TCanvas read FCanvas write FCanvas;
    property Caption: string read FCaption write SetCaption;
    property Color: TColor read FColor write SetColor;
  	property Enabled : boolean index 1 read GetArrBool write SetArrBool;
    property ShowHint: boolean index 2 read GetArrBool write SetArrBool;
    property Visible : boolean index 3 read GetArrBool write SetArrBool;
    property Font: TFont read FFont write FFont;
    property Hint: string read FHint write FHint;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
  end;

  TPaintButton = class(TPaintControl)
  private
  	FArrBool: TByteSet;
    FGlyph,bmDisable: TBitMap;
    abm: TArrStr;
		function GetArrBool(Index: longint): boolean;
		procedure SetArrBool(Index: longint; Value: boolean);
		procedure SetGlyph(Value: TBitMap);
		procedure GlyphChange(Sender: TObject);
		procedure bmDisableLoad;
  protected
    procedure FPaint; override;
  public
    OnPaint: TNotifyEvent;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
		procedure DoClick; override;
    property AllowAllUp: boolean index 1 read GetArrBool write SetArrBool;
  	property Down: boolean index 2 read GetArrBool write SetArrBool;
  	property DrawFrame: boolean index 3 read GetArrBool write SetArrBool;
    property Glyph: TBitMap read FGlyph write SetGlyph;
  end;

  TArrPaintButton = array of TPaintButton;

implementation

uses ExtCtrls,Math,
  My_pr;

var LsPaintButton: TList;

{ TPaintControl }
constructor TPaintControl.Create;
begin
	AddStack('TPaintControl.Create',Self);
  inherited Create(AOwner);
  FFont:=TFont.Create; FFont.OnChange:=FontChange;
  FBounds:=Rect(0,0,20,20); Visible:=true; Enabled:=true;
  DelStack;
end;

destructor TPaintControl.Destroy;
begin
	AddStack('TPaintControl.Destroy',Self);
  FFont.Free;
  inherited Destroy;
  DelStack;
end;

procedure TPaintControl.CaptionChange;
begin
	AddStack('TPaintControl.CaptionChange',Self);
	Paint;
  DelStack;
end;

procedure TPaintControl.FontChange;
begin
  AddStack('TPaintControl.FontChange',Self);
  Paint;
  DelStack;
end;

function TPaintControl.GetArrBool;
begin
  AddStack('TPaintControl.GetArrBool',Self);
  result := Index in FArrBool;
  DelStack;
end;

procedure TPaintControl.SetArrBool;
begin
  AddStack('TPaintControl.SetArrBool',Self);
  if Value<>GetArrBool(Index) then begin
  	SetSet(FArrBool,Index,Value); Paint;
  end;
  DelStack;
end;

procedure TPaintControl.SetCaption;
begin
  AddStack('TPaintControl.SetCaption',Self);
  if FCaption<>Value then begin
  	FCaption:=Value; CaptionChange;
  end;
  DelStack;
end;

procedure TPaintControl.SetColor;
begin
  AddStack('TPaintControl.SetColor',Self);
  if FColor<>Value then begin
  	FColor:=Value; Paint;
  end;
  DelStack;
end;

procedure TPaintControl.FSetBounds;
begin
	AddStack('TPaintControl.FSetBounds',Self);
  with FBounds do if not((Value.Left=Left) and (Value.Top=Top) and (Value.Right=Right) and (Value.Bottom=Bottom)) then begin
	  FBounds:=Value; //Paint;
    TCustomControl(Owner).Invalidate;
  end;
  DelStack;
end;

procedure TPaintControl.SetBounds;
begin
  AddStack('TPaintControl.SetBounds',Self);
  Bounds:=Rect(ALeft,ATop,ALeft+AWidth,ATop+AHeight);
  DelStack;
end;

function TPaintControl.Left;
begin
  result:=FBounds.Left;
end;

function TPaintControl.Top;
begin
  result:=FBounds.Top;
end;

function TPaintControl.Width;
begin
  with FBounds do result:=Right-Left;
end;

function TPaintControl.Height;
begin
  with FBounds do result:=Bottom-Top;
end;

function TPaintControl.ClientOrigin;
begin
  AddStack('TPaintControl.ClientOrigin',Self);
  result:=TWinControl(Owner).ClientToScreen(Bounds.TopLeft);
  DelStack;
end;

function TPaintControl.MinSize;
var a: TArrStr;
  i: longint;
  sz: TSize;
begin
  AddStack('TPaintControl.MinSize',Self);
  ZeroMemory(@result,SizeOf(result));
  for i:=0 to LsArrDynamic(FCaption,a,UnDelim)-1 do begin
    sz:=FCanvas.TextExtent(a[i]); MaxSelf(result.cx,sz.cx); Inc(result.cy,sz.cy);
  end;
  DelStack;
end;

function TPaintControl.VisibleNoNil;
begin
  AddStack('TPaintControl.VisibleNoNil',Self);
  if Assigned(Self) then result:=Visible else result:=false;
  DelStack;
end;

procedure TPaintControl.MouseDown;
begin
	AddStack('TPaintControl.MouseDown',Self);
  IfThenMouse(FOnMouseDown,Self,Button,Shift,X,Y);
  DelStack;
end;

procedure TPaintControl.MouseMove;
begin
	AddStack('TPaintControl.MouseMove',Self);
  IfThenMouseMove(FOnMouseMove,Self,Shift,X,Y);
  DelStack;
end;

procedure TPaintControl.MouseUp;
begin
	AddStack('TPaintControl.MouseUp',Self);
  IfThenMouse(FOnMouseUp,Self,Button,Shift,X,Y);
  DelStack;
end;

procedure TPaintControl.Click;
begin
  AddStack('TPaintControl.Click',Self);
  with TWinControl(Owner) do if CanFocus then SetFocus;
  DoClick;
  DelStack;
end;

procedure TPaintControl.DoClick;
begin
  AddStack('TPaintControl.DoClick',Self);
  IfThenNotify(FOnClick,Self);
  DelStack;
end;

function TPaintControl.perform;
begin
	result:=0;
end;

procedure TPaintControl.Paint;
var lBound: boolean;
begin
	AddStack('TPaintControl.Paint',Self);
  if Assigned(Owner) then if Assigned(TControl(Owner).Parent) then if Assigned(FCanvas) then begin
{if (Caption=SpaceCapt(['Код дополнительной','таблицы'])) and not Visible then begin
FCanvas:=FCanvas;
end;}
    lBound:=Visible;
    if lBound then lBound:=MsgPaint(Owner);
    if lBound then FPaint
    {else begin
      FCanvas.Brush.Color:=TCustomControl(Owner).Color; FCanvas.FillRect(FBounds);
    end;}
  end;
  DelStack;
end;

procedure TPaintControl.DrawCaption;
	function Algm(a: TAlignment; t,b,h: longint): longint;
  begin
    AddStack('TPaintControl.DrawCaption.Algm',Self);
    case a of
      taLeftJustify: result:=t;
      taRightJustify: result:=b-h;
    else result:=t+(b-t-h) div 2;
    end;
    DelStack;
  end;
var a: TArrStr;
  asz: TArrSize;
  i,la,l,t: longint;
begin
  AddStack('TPaintControl.DrawCaption',Self);
  if Assigned(FCanvas) then begin
    if not Assigned(AFont) then begin
      ParentFont; AFont:=Self.Font;
    end;
    PointerDef(pointer(pText),@FCaption);
    with FCanvas do begin
      Font.Assign(AFont); Brush.Style:=bsClear;
      la:=LsArrDynamic(pText^,a,UnDelim); SetLength(asz,la); Dec(la); t:=0;
      for i:=0 to la do begin
        asz[i]:=TextExtent(a[i]); Inc(t,asz[i].cy);
      end;
      with ARect do begin
        t:=Algm(VertAlignment,Top,Bottom,t);
        for i:=0 to la do begin
        	l:=Algm(HorzAlignment,Left,Right,asz[i].cx);
          if not Enabled then begin
            Inc(l); Inc(t); Font.Color:=aclBtn[true];
            TextRect(ARect,l,t,a[i]);
            Dec(l); Dec(t); Font.Color:=aclBtn[false];
          end;
          TextRect(ARect,l,t,a[i]); Inc(t,asz[i].cy);
        end;
      end;
    end;
  end;
  DelStack;
end;

procedure TPaintControl.ParentFont;
begin
	AddStack('TPaintControl.ParentFont',Self);
  Font.Assign(TPanel(Owner).Font);
  DelStack;
end;

class procedure TPaintControl.PaintAll;
var i: longint;
  p: TPaintControl;
  //tw: TWinControl;
begin
  AddStack('TPaintControl.PaintAll');
  with Sender do for i:=0 to ComponentCount-1 do
  	if IsClass(Components[i],TPaintControl,pointer(p)) then p.Paint
    {else if IsClass(Components[i],TWinControl,pointer(tw)) then PaintAll(tw)};
  DelStack;
end;

class function TPaintControl.ObjWidth;
begin
  AddStack('TPaintControl.ObjWidth');
  if Sender is TPaintControl
  then result:=TPaintControl(Sender).Width
  else result:=     TControl(Sender).Width;
  DelStack;
end;

class function TPaintControl.ObjHeight;
begin
  AddStack('TPaintControl.ObjHeight');
  if Sender is TPaintControl
  then result:=TPaintControl(Sender).Height
  else result:=     TControl(Sender).Height;
  DelStack;
end;

class procedure TPaintControl.ObjSetVisible;
begin
  AddStack('TPaintControl.ObjSetVisible');
       if Sender is TPaintControl then TPaintControl(Sender).Visible:=Visible
  else if Sender is TControl      then      TControl(Sender).Visible:=Visible;
  DelStack;
end;

class function TPaintControl.ObjPerform;
begin
	AddStack('TPaintControl.ObjPerform');
  if Sender is TPaintControl
  then result:=TPaintControl(Sender).perform(Msg,WParam,LParam)
  else result:=     TControl(Sender).perform(Msg,WParam,LParam);
  DelStack;
end;

class function TPaintControl.ObjBounds;
begin
  AddStack('TPaintControl.ObjBounds');
  if Sender is TPaintControl
  then result:=TPaintControl(Sender).Bounds
  else result:=     TControl(Sender).BoundsRect;
  DelStack;
end;

class procedure TPaintControl.ObjSetBounds;
begin
  AddStack('TPaintControl.ObjSetBounds');
  if Sender is TPaintControl
  then TPaintControl(Sender).SetBounds(ALeft,ATop,AWidth,AHeight)
  else      TControl(Sender).SetBounds(ALeft,ATop,AWidth,AHeight);
  DelStack;
end;

class function TPaintControl.MsgPaint;
begin
  AddStack('TPaintControl.MsgPaint');
  result := not boolean(ObjPerform(Sender,WM_PAINTCTL,byte(pcmNoPaint),0));
  DelStack;
end;

class function TPaintControl.nActivePaint;
var i: longint;
  p: TPaintControl;
begin
  AddStack('TPaintControl.nActivePaint');
  result:=-1;
  with Owner do for i:=0 to ComponentCount-1 do if IsClass(Components[i],TPaintControl,pointer(p)) then with p do begin
    if not Visible then continue;
    with Bounds do if (X<Left) or (X>Right) or (Y<Top) or (Y>Bottom) then continue;
    result:=i; break;
  end;
  DelStack;
end;

{ TPaintButton }
constructor TPaintButton.Create;
begin
	AddStack('TPaintButton.Create',Self);
  inherited Create(AOwner);
  ListCreateObj(Self,LsPaintButton);
  DrawFrame:=true; FGlyph:=TBitMap.Create; FGlyph.OnChange:=GlyphChange;
  DelStack;
end;

destructor TPaintButton.Destroy;
begin
	AddStack('TPaintButton.Destroy',Self);
  FGlyph.Free; bmDisable.Free;
  ListDestroyObj(Self,LsPaintButton);
  inherited Destroy;
  DelStack;
end;

function TPaintButton.GetArrBool;
begin
  result := Index in FArrBool;
end;

procedure TPaintButton.SetArrBool;
begin
  // При Down:=true TPaintButton м.б. уничтожен, затем при Down:=false AccessViolation
  if LsPaintButton.IndexOf(Self)>=0 then
    if Value<>GetArrBool(Index) then begin
      SetSet(FArrBool,Index,Value); Paint;
    end;
end;

procedure TPaintButton.FPaint;
var r: TRect;
	i: longint;
  bm: TBitMap;
begin
	AddStack('TPaintButton.FPaint',Self);
  if DrawFrame then begin
    r:=FBounds;
    //FCanvas.Brush.Color:=clBtnText; FCanvas.FrameRect(r); InflateRect(r,-1,-1);
    i := DFCS_BUTTONPUSH or DFCS_ADJUSTRECT;
    if Down then Or_D(i,DFCS_PUSHED);
    DrawFrameControl(FCanvas.Handle,r,DFC_BUTTON,i);
  end;
  ParentFont; FCanvas.Font.Assign(Font);
  if not empty(FCaption) then DrawCaption(FBounds,taCenter,taCenter)
  else if (FGlyph.Width>0) and (FGlyph.Height>0) then begin
    bm:=FGlyph;
    if not Enabled then begin
      if not Assigned(bmDisable) then begin
        bmDisable:=TBitMap.Create; bmDisableLoad;
      end;
      bm:=bmDisable;
    end;
    with FBounds,bm do FCanvas.Draw(Left+nround((Right-Left-Width)/2),
    	Top+nround((Bottom-Top-Height)/2),bm);
  end;
  IfThenNotify(OnPaint,Self);
  DelStack;
end;

procedure TPaintButton.GlyphChange;
var x,y: longint;
	cl: TColor;
begin
  AddStack('TPaintButton.GlyphChange',Self);
  with FGlyph do if (Width>0) and (Height>0) then begin
  	OnChange:=nil; cl:=Canvas.Pixels[Width-1,Height-1]; SetLength(abm,Width);
    for x:=Width-1 downto 0 do
      for y:=Height-1 downto 0 do
      	if Canvas.Pixels[x,y]=cl then Canvas.Pixels[x,y]:=clBtnFace
        else SetBit(abm[x],y+1,true);
  	if Assigned(bmDisable) then bmDisableLoad;
    OnChange:=GlyphChange;
  end;
  DelStack;
end;

procedure TPaintButton.SetGlyph;
begin
  AddStack('TPaintButton.SetGlyph',Self);
  if Assigned(Value) then FGlyph:=Value
  else with FGlyph do begin
  	Width:=0; Height:=0;
  end;
  DelStack;
end;

procedure TPaintButton.bmDisableLoad;
var x,y: longint;
begin
  AddStack('TPaintButton.bmDisableLoad',Self);
  with bmDisable do begin
    Width:=FGlyph.Width; Height:=FGlyph.Height;
    for x:=Width-2 downto 0 do
      for y:=Height-2 downto 0 do
        if GetBit(abm[x],y+1) then Canvas.Pixels[x+1,y+1]:=aclBtn[true];
    for x:=Width-1 downto 0 do
      for y:=Height-1 downto 0 do
        Canvas.Pixels[x,y]:=IfThen(GetBit(abm[x],y+1),aclBtn[false],FGlyph.Canvas.Pixels[x,y]);
  end;
  DelStack;
end;

procedure TPaintButton.DoClick;
begin
	AddStack('TPaintButton.DoClick',Self);
  if AllowAllUp then Down:=not Down;
  inherited DoClick;
  DelStack;
end;

procedure TPaintButton.MouseDown;
begin
	AddStack('TPaintButton.MouseDown',Self);
  if not AllowAllUp then Down:=true;
  inherited MouseDown(Button,Shift,X,Y);
  DelStack;
end;

procedure TPaintButton.MouseUp;
begin
	AddStack('TPaintButton.MouseUp',Self);
  if not AllowAllUp then Down:=false;
  inherited MouseUp(Button,Shift,X,Y);
  DelStack;
end;

end.
