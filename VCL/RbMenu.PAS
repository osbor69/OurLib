unit RbMenu;

interface

{$I LIBTEST}
uses
  Messages,Classes,Graphics,Controls,Forms,ExtCtrls,Buttons,
  MyTypes,Schem,FrmWnd,Fpanel;

type
	TRMPaintPrm = record
  	h,wBM,lBM,lCapt,lKey: longint;
    Calculated: boolean;
  end;

  TRbMenuKeys = class(TStringList);

  TRbMenuOptions = set of (rmoFixHeightKeys,rmoMinSize,rmoSheetAlign);

  TRbmKeyOption = (rmkDisabled,rmkVisible,rmkNoEval,rmkCngLanguage);
  TRbmKeyOptions = set of TRbmKeyOption;

	TRbmKeyInfo = record
  	bm: TBitMap;
    NumGlyphs: TNumGlyphs;
    Key,keyhelp: longint;
    Capt,sKey,Pict: string;
    Opt: TRbmKeyOptions;
  end;

  TRbMenu = class(TCustomRbPanel)
  private
    { Private declarations }
    FDimKey: array[1..3] of Word;
    FKeys: TRbMenuKeys;
    aKeys: array of TRbmKeyInfo;
    FKeyIndex: Word;
	 	FProcKey: TKeyProc;
    FPressed,PressedFix,lDown: boolean;
    Font1,Font2: TFont;
    Color1,Color2: TColor;
    tcInd: TControl;
    FOptions: TRbMenuOptions;
		function GetDimKey(Index: longint): Word;
		function GetKeyCaption(Key: longint): string;
		function GetKeyDisabled(Key: longint): boolean;
		function GetKeyVisible(Key: longint): boolean;
		function GetKeyNoEval(Key: longint): boolean;
		procedure SetDimKey(Index: longint; Value: Word);
		procedure SetKeyCaption(Key: longint; const Value: string);
		procedure SetKeyDisabled(Key: longint; Value: boolean);
		procedure SetKeyIndex(Value: Word);
		procedure SetKeys(Value: TRbMenuKeys);
		procedure SetKeyVisible(Key: longint; Value: boolean);
		procedure SetKeyNoEval(Key: longint; Value: boolean);
		procedure SetPressed(Value: boolean);
		procedure KeysChange(Sender: TObject);
		function nForward(Index: longint): longint;
		function nBackward(Index: longint): longint;
		function nDisabled(Index: longint; var res: longint): boolean;
		procedure GetSize(var wBM,wCapt,wKey,wSpTxt,h: longint; lCltHeight: boolean = true);
		procedure Press(Index: Word);
		procedure FPaint(Index: Word; var Prm: TRMPaintPrm);
		function nKeyXY(X,Y: longint): longint;
		function BevSpot: Word;
    function KeyCount: longint;
		function SeekIndexSelf(var Key: longint; OnlyEval: boolean = false): boolean;
  	procedure WMGetDlgCode(var Msg: TWmGetDlgCode); message wm_GetDlgCode;
    procedure WMSchem(var msg: TWMSchem); message WM_SCHEM;
		procedure WMKeyRbMenu(var Message: TMessage); message WM_KEYRBMENU;
  	procedure WMKeyInitProg(var Msg: TWMKeyInitProg); message WM_KEYINITPROG;
  	procedure WMHelpFill(var Msg: TWMHelpFill); message WM_HELPFILL;
  protected
    { Protected declarations }
		procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
    procedure MouseMove(Shift: TShiftState; X,Y: longint); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
		procedure KeyDown(var Key: Word; Shift: TShiftState); override;
		procedure Paint; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    { Public declarations }
    property Pressed: boolean read FPressed write SetPressed;
    //property KeyPressed[Key: longint]: boolean read GetKeyPressed write SetKeyPressed;
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
		function SetWHMin(tp: TCustomRbPanel; wm: longint): boolean; override;
    procedure ReBuild(wm,hm: longint); override;
		function SeekIndex(cKey: longint; OnlyEval: boolean = false): longint; overload;
		function SeekIndex(var Index: longint; cKey: longint; OnlyEval: boolean = false): boolean; overload;
		function SeekKey(cKey: longint; OnlyEval: boolean = false): boolean;
    procedure FindEvalKey(Key: longint);
		function ExecKey(Key: longint): boolean;
		procedure InsertKey(BeforeKey,Key: longint; const txt: string;
    	const pict: string = ''; Opt: TRbmKeyOptions = [rmkVisible]; keyhelp: longint = 0); overload;
		procedure InsertKey(Key: longint; const txt: string;
    	const pict: string = ''; Opt: TRbmKeyOptions = [rmkVisible]; keyhelp: longint = 0); overload;
		procedure DeleteKey(Key: longint);
		procedure DeleteKeys(const aKey: array of longint);
    class function GetKeyInfo(const s: string): TRbmKeyInfo; overload;
    function GetKeyInfo(i: longint): TRbmKeyInfo; overload;
    function GetKeyInfo: TRbmKeyInfo; overload;
    class function SetKeyInfo(const inf: TRbmKeyInfo): string;
		function IsVisible(Index: longint): boolean;
		procedure SetKeyPicture(Key: longint; const Value: string);
    property KeyCaption[Key: longint]: string read GetKeyCaption write SetKeyCaption;
    property KeyDisabled[Key: longint]: boolean read GetKeyDisabled write SetKeyDisabled;
    property KeyVisible[Key: longint]: boolean read GetKeyVisible write SetKeyVisible;
    property KeyNoEval[Key: longint]: boolean read GetKeyNoEval write SetKeyNoEval;
  published
    { Published declarations }
    property KeyBevel: Word index 1 read GetDimKey write SetDimKey;
    property KeySpot: Word index 2 read GetDimKey write SetDimKey;
    property KeyBetween: Word index 3 read GetDimKey write SetDimKey;
    property KeyIndex: Word read FKeyIndex write SetKeyIndex;
    property Keys: TRbMenuKeys read FKeys write SetKeys;
    property Options: TRbMenuOptions read FOptions write FOptions;
	 	property OnProcKey: TKeyProc read FProcKey write FProcKey;
  	{ Унаследованные }
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BorderStyle;
    property BorderWidth;
    property Enabled;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

  TDefMenu = class;

  TFormDefMn = class(TFormWnd)
  private
  	stKey: TByteSet;
    pShow: PDefMenuShow;
		procedure ProcKey(Key: longint; tw: TWinControl);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  protected
    procedure Activate; override;
    procedure Deactivate; override;
    procedure DoHide; override;
    procedure DoShow; override;
  public
	  dDefMenu: TDefMenu;
    dMenu: TRbMenu;
		constructor CreateAll(AOwner: TComponent); override;
  end;

  TDefMenu = class(TComponent)
  private
    { Private declarations }
    FBevelInner,FBevelOuter: TPanelBevel;
    FBevelWidth: TBevelWidth;
    FBorderStyle: TBorderStyle;
    FFrmBorderStyle: TFormBorderStyle;
    FFrmBorderIcons: TBorderIcons;
    FFrmCaption: TCaption;
    FDimKey: array[1..3] of Word;
    FKeys: TRbMenuKeys;
	 	FProcKey: TKeyProc;
    FOnFrmShow,FOnFrmHide,FOnFrmActivate,FOnFrmDeActivate: TNotifyEvent;
	  dForm: TFormDefMn;
		function GetDimKey(Index: longint): Word;
		procedure SetDimKey(Index: longint; Value: Word);
		procedure SetFrmBorderIcons(Value: TBorderIcons);
		procedure SetFrmBorderStyle(Value: TFormBorderStyle);
		procedure SetKeys(Value: TRbMenuKeys);
		procedure SelProcKey(Key: longint; tw: TWinControl);
  public
    { Public declarations }
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
		function Execute(pKeySel: PLongint = nil; pShow: PDefMenuShow = nil): boolean;
    function GetKeyInfo(i: longint): TRbmKeyInfo;
		function SeekIndex(Key: longint): longint; overload;
		function SeekIndex(var Index: longint; Key: longint): boolean; overload;
		function SeekKey(cKey: longint): boolean;
		procedure InsertKey(BeforeKey,Key: longint; const txt: string;
    	const pict: string = ''; Opt: TRbmKeyOptions = [rmkVisible]); overload;
		procedure InsertKey(Key: longint; const txt: string;
    	const pict: string = ''; Opt: TRbmKeyOptions = [rmkVisible]); overload;
		procedure DeleteKey(Key: longint);
		procedure DeleteKeys(const aKey: array of longint);
    procedure SetOpt(Key: longint; Value: boolean; Opt: TRbmKeyOption = rmkNoEval);
  published
    { Published declarations }
    property BevelInner: TPanelBevel read FBevelInner write FBevelInner;
    property BevelOuter: TPanelBevel read FBevelOuter write FBevelOuter;
    property BevelWidth: TBevelWidth read FBevelWidth write FBevelWidth;
    property BorderStyle: TBorderStyle read FBorderStyle write FBorderStyle;
    property KeyBevel: Word index 1 read GetDimKey write SetDimKey;
    property KeySpot: Word index 2 read GetDimKey write SetDimKey;
    property KeyBetween: Word index 3 read GetDimKey write SetDimKey;
    property Keys: TRbMenuKeys read FKeys write SetKeys;
    property FrmBorderIcons: TBorderIcons read FFrmBorderIcons write SetFrmBorderIcons;
    property FrmBorderStyle: TFormBorderStyle read FFrmBorderStyle write SetFrmBorderStyle;
    property FrmCaption: TCaption read FFrmCaption write FFrmCaption;
	 	property OnFrmActivate: TNotifyEvent read FOnFrmActivate write FOnFrmActivate;
	 	property OnFrmDeactivate: TNotifyEvent read FOnFrmDeactivate write FOnFrmDeactivate;
	 	property OnFrmHide: TNotifyEvent read FOnFrmHide write FOnFrmHide;
	 	property OnFrmShow: TNotifyEvent read FOnFrmShow write FOnFrmShow;
	 	property OnProcKey: TKeyProc read FProcKey write FProcKey;
  end;

function IfThen(AValue: boolean; ATrue: TRbmKeyOption): TRbmKeyOptions; overload;
procedure SetSet(var s: TRbmKeyOptions; Value: TRbmKeyOption; lSet: boolean); overload;
procedure Register;

implementation

uses Windows,SysUtils,ComCtrls,Math,
  My_pr,KeyLb;

var DefForm: TFormDefMn;
  ShowMain: boolean = false;

type
  TKeyDefList = (kdKey,kdCapt,kdPict,kdDisabled,kdNoVisible,kdNoEval,kdCngLanguage,kdHelp);
  TKeyDefStr = array[TKeyDefList] of string;

{ TRbMenu }
constructor TRbMenu.Create;
	function FontDef(cl: TColor): TFont;
  begin
    AddStack('TRbMenu.Create.FontDef',Self);
    result:=TFont.Create; DefaultFont(result,12); result.Color:=cl; FontStyle(result);
    DelStack;
  end;
begin
	AddStack('TRbMenu.Create',Self);
	Inherited Create(AOwner);
  BevelOuter:=bvLowered; TabStop:=true; FKeyIndex:=0;
  FDimKey[1]:=3; FDimKey[2]:=5; FDimKey[3]:=5;
  FKeys:=TRbMenuKeys.Create; FKeys.OnChange:=KeysChange;
  Font1:=FontDef(clWindowText); Font2:=FontDef(clHighlightText);
  Color1:=clBtnFace; Color2:=clHighlight;
  DelStack;
end;

destructor TRbMenu.Destroy;
begin
	AddStack('TRbMenu.Destroy',Self);
  FKeys.Free; Font1.Free; Font2.Free;
  inherited Destroy;
  DelStack;
end;

procedure TRbMenu.SetParent;
begin
	AddStack('TRbMenu.SetParent',Self);
  inherited SetParent(AParent);
  if AParent is TScrollingWinControl then begin
  	if not Assigned(tcInd) then begin
		  tcInd:=TControl.Create(Self); tcInd.SetBounds(0,0,0,0);
    end;
	  tcInd.Parent:=AParent;
  end
  else FreeAndNil(tcInd);
  DelStack;
end;

procedure TRbMenu.WMGetDlgCode;
begin
	AddStack('TRbMenu.WMGetDlgCode',Self);
	inherited;
  Msg.Result:=dlgc_WantArrows;
  DelStack;
end;

function TRbMenu.GetDimKey;
begin
  AddStack('TRbMenu.GetDimKey');
  result:=FDimKey[Index];
  DelStack;
end;

procedure TRbMenu.SetDimKey;
begin
  AddStack('TRbMenu.SetDimKey',Self);
  if Value<>FDimKey[Index] then begin
  	FDimKey[Index]:=Value; Invalidate;
  end;
  DelStack;
end;

function TRbMenu.KeyCount;
var i: longint;
begin
  AddStack('TRbMenu.KeyCount',Self);
  result:=0;
  for i:=0 to FKeys.Count-1 do if IsVisible(i) then Inc(result);
  DelStack;
end;

procedure TRbMenu.SetKeyIndex;
var oi: Word;
	prm: TRMPaintPrm;
begin
  AddStack('TRbMenu.SetKeyIndex',Self);
  if KeyCount=0 then FKeyIndex:=0
  else begin
    Value:=nForward(Value);
    if FKeyIndex<>Value then begin
    	oi:=FKeyIndex; FKeyIndex:=Value; prm.Calculated:=false;
      FPaint(oi,prm); FPaint(FKeyIndex,prm);
    end;
  end;
  DelStack;
end;

function TRbMenu.nDisabled;
begin
  AddStack('TRbMenu.nDisabled',Self);
  result := (rmkDisabled in GetKeyInfo(Index).Opt) or not IsVisible(Index);
  if not result then res:=Index;
  DelStack;
end;

function TRbMenu.IsVisible;
begin
  AddStack('TRbMenu.IsVisible',Self);
  with GetKeyInfo(Index) do result := (rmkVisible in Opt) and not (rmkNoEval in Opt);
  DelStack;
end;

function TRbMenu.nForward;
label lend;
begin
  AddStack('TRbMenu.nForward',Self);
  result:=min(FKeys.Count-1,Index);
  while Index<FKeys.Count do
  	if nDisabled(Index,result) then Inc(Index) else goto lend;
  Index:=0;
  while Index<result do
  	if nDisabled(Index,result) then Inc(Index) else goto lend;
lend:
  DelStack;
end;

function TRbMenu.nBackward;
label lend;
begin
  AddStack('TRbMenu.nBackward',Self);
  result:=min(FKeys.Count-1,Index);
  while Index>=0 do
  	if nDisabled(Index,result) then Dec(Index) else goto lend;
  Index:=FKeys.Count-1;
  while Index>result do
  	if nDisabled(Index,result) then Dec(Index) else goto lend;
lend:
  DelStack;
end;

procedure TRbMenu.SetKeys;
begin
  AddStack('TRbMenu.SetKeys',Self);
  if not FKeys.Equals(Value) then begin
	  FKeys.Assign(Value); KeysChange(nil); KeyIndex:=FKeyIndex;
  end;
  DelStack;
end;

procedure TRbMenu.SetPressed;
begin
	AddStack('TRbMenu.SetPressed',Self);
	if Value<>FPressed then begin
  	FPressed:=Value; Invalidate;
  end;
  PressedFix:=Value;
  DelStack;
end;

procedure TRbMenu.KeysChange;
var i: longint;
begin
  AddStack('TRbMenu.KeysChange',Self);
  i:=FKeys.Count; SetLength(aKeys,i);
  for i:=0 to i-1 do aKeys[i]:=GetKeyInfo(FKeys[i]);
  Invalidate;
  DelStack;
end;

class function TRbMenu.GetKeyInfo(const s: string): TRbmKeyInfo;
var a: TKeyDefStr;
  fl: boolean;
  w: longint;
begin
  AddStack('TRbMenu.GetKeyInfo');
  LsArrFill(s,a,UnDelim); TInitBM.Init(Application.MainForm);
  with result do begin
    Pict:=a[kdPict];
    if InitBM.FindBM(Pict,bm) then begin
      fl := (bm.Width>0) and (bm.Height>0);
      if fl then begin
        w:=bm.Width; fl := ModDiv(w,bm.Height)=0; NumGlyphs := min(high(NumGlyphs),w);
      end;
      if not fl then bm:=nil;
    end;
    NmToKey(a[kdKey],Key); sKey:=KeyToTxt(Key); Capt:=a[kdCapt];
    Opt:=IfThen(StrToBoolean(a[kdDisabled]),rmkDisabled)
      +IfThen(not StrToBoolean(a[kdNoVisible]),rmkVisible)
      +IfThen(StrToBoolean(a[kdNoEval]),rmkNoEval);
    if StrToBoolean(a[kdCngLanguage]) then begin
      Include(Opt,rmkCngLanguage); sKey:=CngLanguage(sKey);
    end;
    NmToKey(a[kdHelp],keyhelp);
  end;
  DelStack;
end;

function TRbMenu.GetKeyInfo(i: longint): TRbmKeyInfo;
begin
  AddStack('TRbMenu.GetKeyInfo(i)',Self);
  result:=aKeys[i];
  DelStack;
end;

function TRbMenu.GetKeyInfo: TRbmKeyInfo;
begin
  result:=GetKeyInfo(FKeyIndex);
end;

class function TRbMenu.SetKeyInfo;
var a: TKeyDefStr;
begin
  AddStack('TRbMenu.SetKeyInfo');
  with inf do begin
    a[kdKey]:=KeyToNm(Key);
    a[kdCapt]:=Capt;
    a[kdPict]:=Pict;
    a[kdDisabled]:=bStr[rmkDisabled in Opt];
    a[kdNoVisible]:=bStr[not(rmkVisible in Opt)];
    a[kdNoEval]:=bStr[rmkNoEval in Opt];
    a[kdCngLanguage]:=bStr[rmkCngLanguage in Opt];
    a[kdHelp]:=KeyToNm(keyhelp);
  end;
  result:=ArrayAsList(a,UnDelim);
  DelStack;
end;

procedure TRbMenu.Paint;
var i: longint;
	prm: TRMPaintPrm;
begin
  AddStack('TRbMenu.Paint',Self);
  inherited Paint;
  prm.Calculated:=false;
  for i:=0 to FKeys.Count-1 do FPaint(i,prm);
  DelStack;
end;

procedure TRbMenu.FPaint;
var p: TRbmKeyInfo;
  ng: byte;
  i,lb,rb,tb,bmh,bml,bmt,wCapt,wKey,wSpTxt: longint;
  r: TRect;
begin
  AddStack('TRbMenu.FPaint',Self);
  if InRange(Index,0,FKeys.Count-1) then
    if IsVisible(Index) then begin
      p:=GetKeyInfo(Index);
      lb:=BevSpot; rb:=Width-lb;
      if not prm.Calculated then begin
        GetSize(prm.wBM,wCapt,wKey,wSpTxt,prm.h);
        i:=2;
        if prm.wBM>0 then Inc(i);
        if wKey>0 then Inc(i);
        i := (rb - lb - KeyBevel shl 1 - prm.wBM - wCapt - wKey) div i;
        prm.lBM:=lb+KeyBevel+i+1; prm.lCapt:=prm.lBM;
        if prm.wBM>0 then Inc(prm.lCapt,prm.wBM+i);
        prm.lKey:=prm.lCapt+wCapt+i; prm.Calculated:=true;
      end;
      tb:=-1;
      for i:=0 to Index do
        if IsVisible(i) then Inc(tb);
      tb:=lb+tb*(prm.h+KeyBetween); r:=Rect(lb,tb,rb,tb+prm.h);
      Frame3D1(Canvas,r,(Index=FKeyIndex) and FPressed,KeyBevel);
      if (Index=FKeyIndex) and not FPressed then begin
        Canvas.Brush.Color:=Color2; Canvas.Font.Assign(Font2);
      end
      else begin
        Canvas.Brush.Color:=Color1; Canvas.Font.Assign(Font1);
        if rmkDisabled in p.Opt then Canvas.Font.Color:=clWhite;
      end;
      Canvas.FillRect(Rect(lb+KeyBevel+1,tb+KeyBevel+1,rb-KeyBevel-1,tb+prm.h-KeyBevel-1));
      if Assigned(p.bm) then begin
        ng:=IfThen(Index=FKeyIndex,IfThen(FPressed,3,2),IfThen(rmkDisabled in p.Opt,4,1));
        if ng>p.NumGlyphs then ng:=1;
        Dec(ng);
        bmh:=p.bm.Height; bml := prm.lBM + (prm.wBM-bmh) div 2;
        bmt := tb+1 + (prm.h-bmh) div 2;
        Dec(bmh);
        Canvas.BrushCopy(Rect(bml,bmt,bml+bmh,bmt+bmh),
          p.bm,Rect(ng*p.bm.Height,0,ng*p.bm.Height+bmh,bmh),p.bm.Canvas.Pixels[0,0]);
      end;
      bmt := tb + 1 + (prm.h-CanvasMaxH(Canvas)) div 2;
      if rmkDisabled in p.Opt then begin
        Inc(bmt); Inc(prm.lCapt); Inc(prm.lKey);
      end;
      Canvas.TextOut(prm.lCapt,bmt,p.Capt); Canvas.TextOut(prm.lKey,bmt,p.sKey);
      if rmkDisabled in p.Opt then begin
        Dec(bmt); Dec(prm.lCapt); Dec(prm.lKey);
        Canvas.Brush.Style:=bsClear; Canvas.Font.Color:=clGray;
        Canvas.TextOut(prm.lCapt,bmt,p.Capt); Canvas.TextOut(prm.lKey,bmt,p.sKey);
        Canvas.Brush.Style:=bsSolid;
      end;
      if (Index=FKeyIndex) and Assigned(tcInd) then begin
        tcInd.SetBounds(Left+r.Left,Top+r.Top,0,r.Bottom-r.Top);
        TScrollingWinControl(Parent).ScrollInView(tcInd);
      end;
    end;
  DelStack;
end;

procedure TRbMenu.GetSize;
	function WHFont(const txt: string; lWidth: boolean = true): longint;
  begin
    AddStack('TRbMenu.GetSize.WHFont',Self);
    result:=0;
  	Canvas.Font.Assign(Font1);
    if lWidth then MaxSelf(result,Canvas,txt) else MaxSelf(result,Canvas,true);
  	Canvas.Font.Assign(Font2);
    if lWidth then MaxSelf(result,Canvas,txt) else MaxSelf(result,Canvas,true);
    DelStack;
  end;
var i,htxt,hBM: longint;
	p: TRbmKeyInfo;
begin
  AddStack('TRbMenu.GetSize',Self);
  wBM:=0; wCapt:=0; wKey:=0; wSpTxt:=WHFont(cMaxW); htxt:=WHFont('',false); hBM:=0;
  for i:=0 to FKeys.Count-1 do
    if IsVisible(i) then begin
      p:=GetKeyInfo(i);
      if Assigned(p.bm) then begin
        MaxSelf(wBM,p.bm.Height); MaxSelf(hBM,p.bm.Height);
      end;
      MaxSelf(wCapt,WHFont(p.Capt));
      MaxSelf(wKey,WHFont(p.sKey));
    end;
  h:=max(htxt,hBM)+4;
  if rmoFixHeightKeys in FOptions
    then inc(h,KeyBevel*2+1)
  else if lCltHeight and (KeyCount<>0)
    then EnsureSelf(h,max(hBM,(Height-BevSpot shl 1-(KeyCount-1)*KeyBetween) div KeyCount),htxt*3);
  DelStack;
end;

procedure TRbMenu.Click;
begin
	AddStack('TRbMenu.Click',Self);
  try
  	SetFocus;
  except
    on EInvalidOperation do;
  end;
	inherited Click;
  DelStack;
end;

procedure TRbMenu.KeyDown;
var fl: boolean;
  k: longint;
  tw: TWinControl;
begin
  AddStack('TRbMenu.KeyDown',Self);
  fl := Shift<>[];
  if not fl then
  	case Key of
    	vk_Return,vk_Space: Press(FKeyIndex);
      vk_End: KeyIndex:=nBackward(FKeys.Count-1);
      vk_Home: KeyIndex:=nForward(0);
      vk_Up: KeyIndex:=nBackward(FKeyIndex-1);
      vk_Down: KeyIndex:=nForward(FKeyIndex+1);
    else fl:=true;
    end;
  if fl then
    if GetKeyCod(Key,Shift,k) then
      if ExecKey(k) then Key:=0
      else begin
        tw:=Parent;
        while Assigned(tw) do
          if tw.perform(WM_KEYRBMENU,k,LongInt(Self))=0 then ParentSelf(tw)
          else begin
            Key:=0; break;
          end;
        if Key<>0 then
          if TKeyLb.ExecFixKey(k) then Key:=0;
      end;
  DelStack;
end;

procedure TRbMenu.WMKeyRbMenu;
begin
  AddStack('TRbMenu.WMKeyRbMenu',Self);
  with Message do case LParam of
    0: if not TKeyLb.FixKeySeek(WParam) then
      if SeekKey(WParam,true) then result:=1;
    1: ExecKey(WParam);
  end;
  DelStack;
end;

procedure TRbMenu.WMKeyInitProg;
begin
	AddStack('TRbMenu.WMKeyInitProg',Self);
  with Msg do
    if lExec then ExecKey(Key)
    else if SeekKey(Key,true) then result:=1;
  DelStack;
end;

procedure HelpAdd(mn: TRbMenu; pArr: PHelpArr);
var i,j,l,lo,ln: longint;
  aun: TArrInt;
  fl: boolean;
begin
  AddStack('RbMenu.HelpAdd');
  with mn do begin
    lo:=Length(pArr^); ln:=0; SetLength(pArr^,lo+FKeys.Count); SetLength(aun,FKeys.Count);
    for i:=0 to FKeys.Count-1 do with GetKeyInfo(i) do
      if not((rmkNoEval in Opt) or HelpFindAvk(pArr^,Key,j)) then with pArr^[lo+ln] do begin
        part:=sKey; txt:=Capt; CopyFromVArr(avk,[Key]); aun[ln]:=keyhelp; Inc(ln);
      end;
    l:=lo;
    for j:=0 to ln-1 do begin
      fl:=false;
      if aun[j]<>0 then for i:=lo to lo+ln-1 do with pArr^[i] do if avk[0]=aun[j] then begin
        IncD(part,','+pArr^[l].part); AddFromVArr(avk,pArr^[l].avk); fl:=true; break;
      end;
      if fl then begin
        for i:=l+1 to lo+ln-1 do pArr^[i-1]:=pArr^[i];
        Dec(ln);
      end
      else Inc(l);
    end;
    SetLength(pArr^,l);
  end;
  DelStack;
end;

procedure HelpSeek(Sender: TControl; const av: array of variant; var Done: boolean);
begin
  AddStack('RbMenu.HelpSeek');
  if Sender is TRbMenu then HelpAdd(pointer(Sender),PointerVar(av[0]));
  DelStack;
end;

procedure TRbMenu.WMHelpFill;
var ts: TTabSheet;
  i,l,h,lp: longint;
begin
  AddStack('TRbMenu.WMHelpFill',Self);
  with Msg do case Oper of
    hlpAdd: begin
      l:=Length(pArr^);
      if SeekTabSheet(Self,ts)
      then ProcControls(ts.PageControl,HelpSeek,[longint(pArr)])
      else HelpAdd(Self,pArr);
      h:=high(pArr^); lp:=0;
      for i:=l to h do MaxSelf(lp,pArr^[i].part);
      Inc(lp);
      for i:=l to h do with pArr^[i] do txt:=Space(lp-Length(part))+txt;
    end;
    hlpFillType: ResFillType:=hlpftAfter;
    hlpLinkObj: pLinkObj^:='клавиши пунктов меню';
  end;
  DelStack;
end;

procedure TRbMenu.MouseDown;
begin
  AddStack('TRbMenu.MouseDown',Self);
  inherited MouseDown(Button,Shift,X,Y);
  if (Button=mbLeft) and (Cursor=crHandPoint) then lDown:=true;
  DelStack;
end;

procedure TRbMenu.MouseMove;
var i: longint;
	cr: TCursor;
begin
  AddStack('TRbMenu.MouseMove',Self);
  inherited MouseMove(Shift,X,Y);
  i:=nKeyXY(X,Y); cr:=crDefault;
  if InRange(i,0,FKeys.Count-1) then
  	if not(rmkDisabled in GetKeyInfo(i).Opt) then cr:=crHandPoint;
  Cursor:=cr;
  DelStack;
end;

procedure TRbMenu.MouseUp;
begin
  AddStack('TRbMenu.MouseUp',Self);
  inherited MouseUp(Button,Shift,X,Y);
  if lDown then begin
    lDown:=false; Press(nKeyXY(X,Y));
  end;
  DelStack;
end;

function TRbMenu.nKeyXY;
var wBM,wCapt,wKey,wSpTxt,h: longint;
begin
  AddStack('TRbMenu.nKeyXY',Self);
  if InRange(X,BevSpot,Width-BevSpot) then begin
	  GetSize(wBM,wCapt,wKey,wSpTxt,h); result:=Y-BevSpot;
    if ModDiv(result,h+KeyBetween)>h then result:=-1;
    if result>=0 then for h:=0 to FKeys.Count-1 do
      if IsVisible(h) then
        if result=0 then begin
          result:=h; break;
        end
        else Dec(result);
  end
  else result:=-1;
  DelStack;
end;

procedure TRbMenu.Press;
var prm: TRMPaintPrm;
begin
  AddStack('TRbMenu.Press',Self);
  if Index<FKeys.Count then with GetKeyInfo(Index) do
  	if not(rmkDisabled in Opt) then begin
      if IsVisible(Index) then KeyIndex:=Index;
      if Assigned(FProcKey) then begin
        FPressed:=true; PressedFix:=false; prm.Calculated:=false; FPaint(Index,prm);
        AddKeyStack(Key,Capt);
        try
          FProcKey(Key,Self);
        finally
          DelKeyStack;
        end;
        if not PressedFix then begin
	        FPressed:=false; FPaint(Index,prm);
        end;
      end;
    end;
  DelStack;
end;

function TRbMenu.SetWHMin;
var wBM,wCapt,wKey,wSpTxt,h: longint;
begin
	AddStack('TRbMenu.SetWHMin',Self);
  GetSize(wBM,wCapt,wKey,wSpTxt,h,false);
  WMin := wBM + wCapt + wKey + wSpTxt shl 1 + KeyBevel shl 1 + BevSpot shl 1 + 2;
  HMin := KeyCount*h + (KeyCount-1)*KeyBetween + BevSpot shl 1;
	result := inherited SetWHMin(tp,wm);
  DelStack;
end;

procedure TRbMenu.WMSchem;
begin
  AddStack('TRbMenu.WMSchem',Self);
	inherited;
  if Assigned(msg.Schem) then begin
    Font1.Assign(msg.Schem.Font1); Font2.Assign(msg.Schem.Font2);
    Color1:=msg.Schem.Color1; Color2:=msg.Schem.Color2; Invalidate;
  end;
  DelStack;
end;

procedure TRbMenu.ReBuild;
var l: longint;
  ts: TTabSheet;
begin
	AddStack('TRbMenu.ReBuild',Self);
  if rmoMinSize in FOptions then begin
    wm:=WMin; hm:=HMin;
  end;
  l:=0;
  if rmoSheetAlign in FOptions then
    if SeekTabSheet(Self,ts) then l:=EnsureRange(Self.Parent.Width-wm,0,ts.PageControl.TabRect(ts.TabIndex).Left);
  SetBounds(l,0,wm,hm);
  inherited ReBuild(wm,hm);
  DelStack;
end;

function TRbMenu.SeekIndex(cKey: longint; OnlyEval: boolean = false): longint;
begin
  if not SeekIndex(result,cKey,OnlyEval) then result:=-1;
end;

function TRbMenu.SeekIndex(var Index: longint; cKey: longint; OnlyEval: boolean = false): boolean;
begin
  AddStack('TRbMenu.SeekIndex',Self);
  result:=false;
  if cKey>0 then begin
    Index:=0;
    while Index<FKeys.Count do with GetKeyInfo(Index) do
      if (Key=cKey) and not(OnlyEval and (rmkNoEval in Opt)) then begin
        result:=true; break;
      end
      else Inc(Index);
  end;
  DelStack;
end;

function TRbMenu.SeekIndexSelf;
begin
  result:=SeekIndex(Key,Key,OnlyEval); 
end;

function TRbMenu.SeekKey;
var i: longint;
begin
  result:=SeekIndex(i,cKey,OnlyEval);
end;

procedure TRbMenu.FindEvalKey;
begin
  AddStack('TRbMenu.FindEvalKey',Self);
  if SeekIndexSelf(Key,true)
    then KeyIndex:=Key
  else if KeyCount>0
    then KeyIndex:=0;
  DelStack;
end;

function TRbMenu.ExecKey;
begin
  AddStack('TRbMenu.ExecKey',Self);
  result := SeekIndexSelf(Key,true);
  if result then Press(Key);
  DelStack;
end;

function TRbMenu.GetKeyCaption;
begin
  AddStack('TRbMenu.GetKeyCaption',Self);
  if SeekIndexSelf(Key) then result:=GetKeyInfo(Key).Capt else result:='';
  DelStack;
end;

procedure TRbMenu.SetKeyCaption;
var a: TKeyDefStr;
begin
  AddStack('TRbMenu.SetKeyCaption',Self);
  if SeekIndexSelf(Key) then
  	if GetKeyInfo(Key).Capt<>Value then begin
	  	LsArrFill(FKeys[Key],a,UnDelim); a[kdCapt]:=Value; FKeys[Key]:=ArrayAsList(a,UnDelim);
	  end;
  DelStack;
end;

procedure TRbMenu.SetKeyPicture;
var a: TKeyDefStr;
begin
  AddStack('TRbMenu.SetKeyPicture',Self);
  if SeekIndexSelf(Key) then begin
    LsArrFill(FKeys[Key],a,UnDelim); a[kdPict]:=Value; FKeys[Key]:=ArrayAsList(a,UnDelim);
  end;
  DelStack;
end;

function TRbMenu.GetKeyDisabled;
begin
  AddStack('TRbMenu.GetKeyDisabled',Self);
  if SeekIndexSelf(Key) then result := rmkDisabled in GetKeyInfo(Key).Opt else result:=true;
  DelStack;
end;

procedure TRbMenu.SetKeyDisabled;
var a: TKeyDefStr;
begin
  AddStack('TRbMenu.SetKeyDisabled',Self);
  if SeekIndexSelf(Key) then
  	if (rmkDisabled in GetKeyInfo(Key).Opt)<>Value then begin
	  	LsArrFill(FKeys[Key],a,UnDelim); a[kdDisabled]:=bStr[Value]; FKeys[Key]:=ArrayAsList(a,UnDelim);
	  end;
  DelStack;
end;

function TRbMenu.GetKeyNoEval;
begin
  AddStack('TRbMenu.GetKeyNoEval',Self);
  if SeekIndexSelf(Key) then result := rmkNoEval in GetKeyInfo(Key).Opt else result:=true;
  DelStack;
end;

procedure TRbMenu.SetKeyNoEval;
var a: TKeyDefStr;
begin
  AddStack('TRbMenu.SetKeyNoEval',Self);
  if SeekIndexSelf(Key) then
  	if (rmkNoEval in GetKeyInfo(Key).Opt)<>Value then begin
	  	LsArrFill(FKeys[Key],a,UnDelim); a[kdNoEval]:=bStr[Value]; FKeys[Key]:=ArrayAsList(a,UnDelim);
	  end;
  DelStack;
end;

function TRbMenu.GetKeyVisible;
begin
  AddStack('TRbMenu.GetKeyVisible',Self);
  if SeekIndexSelf(Key) then result := rmkVisible in GetKeyInfo(Key).Opt else result:=true;
  DelStack;
end;

procedure TRbMenu.SetKeyVisible;
var a: TKeyDefStr;
begin
  AddStack('TRbMenu.SetKeyVisible',Self);
  if SeekIndexSelf(Key) then
  	if (rmkVisible in GetKeyInfo(Key).Opt)<>Value then begin
	  	LsArrFill(FKeys[Key],a,UnDelim); a[kdNoVisible]:=bStr[not Value]; FKeys[Key]:=ArrayAsList(a,UnDelim);
	  end;
  DelStack;
end;

procedure TRbMenu.InsertKey(BeforeKey,Key: longint; const txt: string;
  const pict: string = ''; Opt: TRbmKeyOptions = [rmkVisible]; keyhelp: longint = 0);
var s: string;
	i: longint;
  r: TRbmKeyInfo;
begin
  AddStack('TRbMenu.InsertKey',Self);
  r.Key:=Key; r.Capt:=txt; r.Pict:=Pict; r.Opt:=Opt; r.keyhelp:=keyhelp; s:=SetKeyInfo(r);
  if SeekIndex(i,Key) then FKeys[i]:=s
  else if SeekIndex(i,BeforeKey) then FKeys.Insert(i,s) else FKeys.Add(s);
  DelStack;
end;

procedure TRbMenu.InsertKey(Key: longint; const txt: string;
  const pict: string = ''; Opt: TRbmKeyOptions = [rmkVisible]; keyhelp: longint = 0);
begin
  InsertKey(0,Key,txt,pict,Opt,keyhelp);
end;

procedure TRbMenu.DeleteKey;
var i: longint;
begin
  AddStack('TRbMenu.DeleteKey',Self);
  if SeekIndex(i,Key) then FKeys.Delete(i);
  DelStack;
end;

procedure TRbMenu.DeleteKeys;
var i: longint;
begin
	AddStack('TRbMenu.DeleteKeys',Self);
  for i:=low(aKey) to high(aKey) do DeleteKey(aKey[i]);
  DelStack;
end;

function TRbMenu.BevSpot;
begin
  AddStack('TRbMenu.BevSpot',Self);
  result:=BevPanel+KeySpot;
  DelStack;
end;

{ TFormDefMn }
constructor TFormDefMn.CreateAll;
begin
	AddStack('TFormDefMn.CreateAll',Self);
  inherited CreateAll(AOwner);
  dMenu:=TRbMenu.Create(Self);
  with dMenu do begin
    Parent:=Self; Schem:='Menu'; FProcKey:=Self.ProcKey;
  end;
  DelStack;
end;

procedure TFormDefMn.Activate;
begin
  AddStack('TFormDefMn.Activate',Self);
  inherited Activate;
  IfThenNotify(dDefMenu.FOnFrmActivate,Self);
  DelStack;
end;

procedure TFormDefMn.Deactivate;
begin
  AddStack('TFormDefMn.Deactivate',Self);
  IfThenNotify(dDefMenu.FOnFrmDeactivate,Self);
  inherited Deactivate;
  DelStack;
end;

procedure TFormDefMn.DoShow;
var X,Y: longint;
begin
  AddStack('TFormDefMn.DoShow',Self);
  inherited DoShow;
  if Assigned(pShow) then with pShow^ do begin
    if lRect then begin
      X:=r.Left;
      with SysWorkArea do Y:=IfThen(r.Bottom+Height>Bottom,max(Top,r.Top-Height),r.Bottom);
    end
    else begin
      X:=p.X; Y:=p.Y;
      with SysWorkArea do if Y+Height>Bottom then Y:=max(Top,Y-Height);
    end;
    SetBounds(X,Y,Width,Height); FormOnScreen;
  end;
  IfThenNotify(dDefMenu.FOnFrmShow,Self);
  DelStack;
end;

procedure TFormDefMn.DoHide;
begin
  AddStack('TFormDefMn.DoHide',Self);
  IfThenNotify(dDefMenu.FOnFrmHide,Self);
  inherited DoHide;
  DelStack;
end;

procedure TFormDefMn.ProcKey;
begin
  AddStack('TFormDefMn.ProcKey',Self);
  if Key in stKey then SetModalResult else IfThenKeyProc(dDefMenu.FProcKey,Key,tw);
  DelStack;
end;

procedure TFormDefMn.WMFormLimit;
begin
	AddStack('TFormDefMn.WMFormLimit',Self);
  inherited;
  FreeLimit(DefForm);
  DelStack;
end;

{ TDefMenu }
constructor TDefMenu.Create;
begin
	AddStack('TDefMenu.Create',Self);
	Inherited Create(AOwner);
  BevelInner:=bvNone; BevelOuter:=bvLowered; FBevelWidth:=1; FBorderStyle:=bsNone;
  FFrmBorderStyle:=bsSingle; FFrmBorderIcons:=[biSystemMenu,biMinimize];
  FDimKey[1]:=3; FDimKey[2]:=5; FDimKey[3]:=5;
  FKeys:=TRbMenuKeys.Create;
  DelStack;
end;

destructor TDefMenu.Destroy;
begin
	AddStack('TDefMenu.Destroy',Self);
  FKeys.Free;
  inherited Destroy;
  DelStack;
end;

function TDefMenu.GetDimKey;
begin
  AddStack('TDefMenu.GetDimKey');
  result:=FDimKey[Index];
  DelStack;
end;

procedure TDefMenu.SetDimKey;
begin
  AddStack('TDefMenu.SetDimKey',Self);
  FDimKey[Index]:=Value;
  DelStack;
end;

procedure TDefMenu.SetKeys;
begin
  AddStack('TDefMenu.SetKeys',Self);
  FKeys.Assign(Value);
  DelStack;
end;

procedure TDefMenu.SetFrmBorderIcons;
begin
  AddStack('TDefMenu.SetFrmBorderIcons',Self);
  Exclude(Value,biMaximize); FFrmBorderIcons:=Value;
  DelStack;
end;

procedure TDefMenu.SetFrmBorderStyle;
begin
  AddStack('TDefMenu.SetFrmBorderIcons',Self);
  case Value of
    bsSizeable: Value:=bsSingle;
    bsSizeToolWin: Value:=bsToolWindow;
  end;
  FFrmBorderStyle:=Value;
  DelStack;
end;

function TDefMenu.Execute;
	function AddKey(Key: byte; const txt: string; keyhelp: longint = 0): boolean;
  begin
    AddStack('TDefMenu.Execute.AddKey',Self);
    with dForm do begin
      result := not SeekKey(Key);
      if result then begin
      	dMenu.InsertKey(Key,txt,'',[],keyhelp); Include(stKey,Key);
      end;
    end;
    DelStack;
  end;
var w,h,wBM,wCapt,wKey,wSpTxt,hKey,n,i: longint;
	lMain: boolean;
  f: TFormWnd;
  omn: TRbMenu;
  p: TPoint;
  r: TRect;
begin
  AddStack('TDefMenu.Execute',Self);
  lMain := not(ShowMain or FormsFree);
  if lMain then begin
    if not Assigned(DefForm) then begin
      DefForm:=TFormDefMn.CreateAll(Application); DefForm.SetSchemForm;
    end;
    ShowMain:=true; dForm:=DefForm;
  end
  else begin
  	dForm:=TFormDefMn.CreateAll(Application); dForm.SetSchemForm;
  end;
  try
    dForm.pShow:=pShow;
  	with dForm do begin
      f:=TFormWnd.LastForm;
      if f.VisibleNoNil then IsClass(f.ActiveControl,TRbMenu,pointer(omn)) else omn:=nil;
      Caption:=FFrmCaption;
      if (FFrmCaption='') and Assigned(omn) then with omn do
        if IsVisible(FKeyIndex) then dForm.Caption:=GetKeyInfo.Capt;
      BorderIcons:=FFrmBorderIcons; BorderStyle:=FFrmBorderStyle;
      dDefMenu:=Self; dMenu.FOptions:=[rmoFixHeightKeys,rmoMinSize];
      dMenu.BevelInner:=FBevelInner; dMenu.BevelOuter:=FBevelOuter;
      dMenu.BevelWidth:=FBevelWidth; dMenu.BorderStyle:=FBorderStyle;
      dMenu.KeyBevel:=KeyBevel; dMenu.KeySpot:=KeySpot; dMenu.KeyBetween:=KeyBetween;
      dMenu.FKeys.Assign(FKeys); stKey:=[];
      if AddKey(K_Esc,'Выход')
      then AddKey(K_F10,'',K_Esc)
      else AddKey(K_F10,'Выход');
      if Assigned(pKeySel) then begin
        dMenu.KeyIndex:=dMenu.SeekIndex(pKeySel^,true); OnProcKey:=SelProcKey;
      end
      else dMenu.KeyIndex:=0;
      BoundsRect:=SysWorkArea; MainRebuild;
      w:=max(MinWidthForm(dForm),Width-ClientWidth+dMenu.WMin);
      h:=Height-ClientHeight+dMenu.HMin;
      if Assigned(omn) then with omn do begin
      	GetSize(wBM,wCapt,wKey,wSpTxt,hKey); p:=ClientOrigin; n:=-1;
        for i:=0 to FKeyIndex do
          if IsVisible(i) then Inc(n);
        wBM:=p.Y+BevSpot+n*(hKey+KeyBetween); r:=SysWorkArea;
        if wBM+hKey+h<=r.Bottom then Inc(wBM,hKey)
        else if wBM-h>=r.Top then Dec(wBM,h)
        else wBM:=(dForm.Height-h) div 2;
        dForm.SetBounds(min(p.X+BevSpot+hKey,r.Right-w),wBM,w,h);
      end
      else SetBounds((Width-w) div 2,(Height-h) div 2,w,h);
      dMenu.FOptions:=dMenu.FOptions-[rmoMinSize]; MainRebuild;
      result := ShowModal=mrOk;
    end;
    if result then SetPLongInt(pKeySel,Tag);
  finally
    if lMain then ShowMain:=false else dForm.Free;
  end;
  DelStack;
end;

procedure TDefMenu.SelProcKey;
begin
	AddStack('TDefMenu.SelProcKey',Self);
  Tag:=Key; GetParentForm(tw).ModalResult:=mrOk;
  DelStack;
end;

function TDefMenu.GetKeyInfo;
begin
  AddStack('TDefMenu.GetKeyInfo',Self);
  result:=TRbMenu.GetKeyInfo(FKeys[i]);
  DelStack;
end;

function TDefMenu.SeekIndex(Key: longint): longint;
begin
  if not SeekIndex(result,Key) then result:=-1;
end;

function TDefMenu.SeekIndex(var Index: longint; Key: longint): boolean;
var a: array[1..1] of string;
begin
  AddStack('TDefMenu.SeekIndex',Self);
  result:=false;
  if Key>0 then begin
    Index:=0;
    while Index<FKeys.Count do begin
      LsArrFill(FKeys[Index],a,UnDelim);
      if NmToKey(a[1])=Key then begin
        result:=true; break;
      end;
      Inc(Index);
    end;
  end;
  DelStack;
end;

function TDefMenu.SeekKey;
var i: longint;
begin
  result:=SeekIndex(i,cKey);
end;

procedure TDefMenu.InsertKey(BeforeKey,Key: longint; const txt: string;
  const pict: string = ''; Opt: TRbmKeyOptions = [rmkVisible]);
var s: string;
	i: longint;
  r: TRbmKeyInfo;
begin
  AddStack('TDefMenu.InsertKey',Self);
  r.Key:=Key; r.Capt:=txt; r.Pict:=Pict; r.Opt:=Opt; s:=TRbMenu.SetKeyInfo(r);
  if SeekIndex(i,Key) then FKeys[i]:=s
  else if SeekIndex(i,BeforeKey) then FKeys.Insert(i,s) else FKeys.Add(s);
  DelStack;
end;

procedure TDefMenu.InsertKey(Key: longint; const txt: string;
  const pict: string = ''; Opt: TRbmKeyOptions = [rmkVisible]);
begin
  InsertKey(0,Key,txt,pict,Opt);
end;

procedure TDefMenu.DeleteKey;
var i: longint;
begin
  AddStack('TDefMenu.DeleteKey',Self);
  if SeekIndex(i,Key) then FKeys.Delete(i);
  DelStack;
end;

procedure TDefMenu.DeleteKeys;
var i: longint;
begin
	AddStack('TDefMenu.DeleteKeys',Self);
  for i:=low(aKey) to high(aKey) do DeleteKey(aKey[i]);
  DelStack;
end;

procedure TDefMenu.SetOpt;
var r: TRbmKeyInfo;
  i: longint;
begin
  AddStack('TDefMenu.SetOpt',Self);
  if SeekIndex(i,Key) then begin
    r:=GetKeyInfo(i); SetSet(r.Opt,Opt,Value); Keys[i]:=TRbMenu.SetKeyInfo(r);
  end;
  DelStack;
end;

function IfThen(AValue: boolean; ATrue: TRbmKeyOption): TRbmKeyOptions;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

procedure SetSet(var s: TRbmKeyOptions; Value: TRbmKeyOption; lSet: boolean);
begin
  if lSet then Include(s,Value) else Exclude(s,Value);
end;

procedure Register;
begin
  RegisterComponents('OurLib',[TRbMenu,TDefMenu]);
end;

end.
