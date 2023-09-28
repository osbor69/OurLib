unit FrmNul;

interface

uses
  Windows, Classes, Controls, ExtCtrls,
  MyTypes, FrmWnd, Keylb, Fpanel;

type
  TFormNul = class(TFormWnd)
    RbPanel1: TRbPanel;
    KeyLb1: TKeyLb;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    aExecKey: TArrInt;
    procedure RunExecKey;
		procedure TimerExecKey(Sender: TObject);
  protected
    procedure AfterCreate; override;
  public
    { Public declarations }
		constructor CreateAll(AOwner: TComponent); override;
		procedure SetExecKey(const aKey: array of longint; lRun: boolean = false);
    class procedure ExecKeys(const aKey: array of longint);
		function PlaceToControl(Sender: TComponent; MinWidth: longint = 0; RestSize: boolean = false): boolean; overload;
		procedure PlaceToControl(const Rect: TRect; MinWidth: longint = 0; RestSize: boolean = false); overload;
		function RestIniForm: TWindowPlacement;
		procedure SaveIniForm;
  end;

var
  FormNul: TFormNul;

implementation

{$R *.DFM}

uses Forms,Math,
  My_pr,SaveIni,PaintCtl;

constructor TFormNul.CreateAll;
begin
  AddStack('TFormNul.CreateAll',Self);
  inherited CreateAll(AOwner);
  KeyPreview:=True; OnResize:=FormResize;
  RbPanel1:=TRbPanel.Create(Self);
  with RbPanel1 do begin
  	Parent:=Self; Schem:='Edit'; CanSize:=False; CanMove:=False; ProcentWnd:=100;
    SortMode:=smDefault; SortObj:=True; BevelOuter:=bvNone; Place:=rpBottom;
    KeyLb1:=TKeyLb.Create(Self);
	  with KeyLb1 do begin
	    Parent:=RbPanel1; Tag:=-1; CanMove:=True; BevelOuter:=bvLowered;
    end;
  end;
  DelStack;
end;

procedure TFormNul.FormCreate(Sender: TObject);
var ows: TWindowState;
begin
	AddStack('TFormNul.FormCreate',Self);
  inherited;
	SetSchemForm; ows:=WindowState; RbFormResize; WindowState:=ows;
  DelStack;
end;

procedure TFormNul.AfterCreate;
begin
  AddStack('TFormNul.AfterCreate',Self);
  RestIniForm;
  DelStack;
end;

procedure TFormNul.FormDestroy(Sender: TObject);
begin
	AddStack('TFormNul.FormDestroy',Self);
	SaveIniForm;
  inherited;
  DelStack;
end;

procedure TFormNul.FormResize(Sender: TObject);
begin
	AddStack('TFormNul.FormResize',Self);
  inherited;
  if not(csDestroying in ComponentState) then RbFormResize;
  DelStack;
end;

procedure TFormNul.FormShow(Sender: TObject);
begin
  AddStack('TFormNul.FormShow',Self);
  inherited;
  //RestIniForm(Self);
  DelStack;
end;

procedure TFormNul.FormActivate(Sender: TObject);
begin
	AddStack('TFormNul.FormActivate',Self);
  inherited;
  RunExecKey;
  DelStack;
end;

procedure TFormNul.RunExecKey;
begin
  AddStack('TFormNul.RunExecKey',Self);
  if Length(aExecKey)>0 then begin
    OnKeyDown:=nil; TTimerOne.CreateProc(TimerExecKey,Self);
  end;
  DelStack;
end;


procedure TFormNul.TimerExecKey;
var i: longint;
begin
	AddStack('TFormNul.TimerExecKey',Self);
  for i:=low(aExecKey) to high(aExecKey) do KeyLb1.ExecKey(aExecKey[i]);
  aExecKey:=nil; OnKeyDown:=KeyLb1.FormKeyDown; OnKeyUp:=KeyLb1.FormKeyUp;
  DelStack;
end;

procedure TFormNul.SetExecKey;
var i,j: longint;
begin
  AddStack('TFormNul.SetExecKey');
  SetLength(aExecKey,Length(aKey)); j:=low(aExecKey);
  for i:=low(aKey) to high(aKey) do begin
  	aExecKey[j]:=aKey[i]; Inc(j);
  end;
  if lRun then RunExecKey;
  DelStack;
end;

class procedure TFormNul.ExecKeys;
var i: longint;
begin
  AddStack('TFormNul.ExecKeys');
  for i:=low(aKey) to high(aKey) do TFormNul(LastForm).KeyLb1.ExecKey(aKey[i]);
  DelStack;
end;

function TFormNul.PlaceToControl(Sender: TComponent; MinWidth: longint = 0; RestSize: boolean = false): boolean;
var r: TRect;
  p: PComponent;
begin
  AddStack('TFormNul.PlaceToControl(o)',Self);
  if Sender is TControl then begin
    p:=@Sender; TControl(Sender).Perform(WM_PLACETOCTRL,0,longint(@p));
    if Assigned(p) then Sender:=p^ else Sender:=nil;
  end;
  result:=Assigned(Sender);
  if result then begin
    if Sender is TPaintControl
    then r.TopLeft:=TPaintControl(Sender).ClientOrigin
    else r.TopLeft:=     TControl(Sender).ClientOrigin;
    r.Bottom:=r.Top+TPaintControl.ObjHeight(Sender);
    r.Right:=r.Left+TPaintControl.ObjWidth(Sender);
    PlaceToControl(r,MinWidth,RestSize);
  end;
  DelStack;
end;

procedure TFormNul.PlaceToControl(const Rect: TRect; MinWidth: longint = 0; RestSize: boolean = false);
var kw,kh,h,ow,oh: longint;
	r,r1: TRect;
begin
  AddStack('TFormNul.PlaceToControl',Self);
  WindowState:=wsNormal; ow:=Width; oh:=Height; BoundsRect:=SysWorkArea;
  with KeyLb1 do begin
    ReDrw; kw:=WMin; kh:=HMin;
    if KeyLb1.GetPlace in [rpTop,rpBottom] then MaxSelf(kw,MinWidth) else Inc(kw,MinWidth);
  end;
  MaxSelf(kw,MinWidthForm(Self)); Inc(kw,Width-ClientWidth); Inc(kh,Height-ClientHeight);
  r1:=SysWorkArea; r:=r1; h:=Rect.Bottom-Rect.Top;
  if Rect.Top-r.Top>r.Bottom-Rect.Bottom then begin
    r.Bottom:=EnsureRange(Rect.Top,r.Top+kh,r1.Bottom);
    if RestSize then r.Top:=r.Bottom-oh;
  end
  else begin
    r.Top:=EnsureRange(Rect.Top+h,r1.Top,r.Bottom-kh);
    if RestSize then r.Bottom:=r.Top+oh;
  end;
  MaxSelf(r.Left,Rect.Left);
  r.Right:=EnsureRange(Rect.Right,kw,r1.Right);
  if r.Right-r.Left<kw then r.Left:=max(r1.Left,r.Right-kw);
  if RestSize then r.Right:=r.Left+ow;
  BoundsRect:=r;
  DelStack;
end;

function TFormNul.RestIniForm;
begin
  AddStack('TFormNul.RestIniForm',Self);
  result:=SaveIni.RestIniForm(Self);
  DelStack;
end;

procedure TFormNul.SaveIniForm;
begin
  AddStack('TFormNul.RestIniForm',Self);
  SaveIni.SaveIniForm(Self);
  DelStack;
end;

end.
