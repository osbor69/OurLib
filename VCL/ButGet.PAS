unit ButGet;

interface

{$I LIBTEST}
uses
  Windows,Messages,Classes,Controls,
  MyTypes,Schem,RecVal,FFldedit,PaintCtl;

type
  TButPaintEvent = procedure(Sender: TObject; const ARect: TRect;	const Text: string) of object;
  TButSizeEvent = procedure(Sender: TObject; const Text: string; var Size: TSize) of object;
  
  TButGetValue = class(TComponent)
  public
  	Value: string;
    PaintRect: TRect;
  end;

  TCustomButGet = class(TCustomGet)
  private
    { Private declarations }
    FCaption: TCaption;
    FOnClick: TButClickEvent;
    FOnPaint: TButPaintEvent;
    FOnSize: TButSizeEvent;
    procedure EvalClick(Sender: TObject);
		procedure ProcKey(key: longint; tw: TWinControl);
    procedure FDoPaint(tf: TFldEdit; const Text: string);
  protected
    { Protected declarations }
    sE: TPaintButton;
    MemValue: TButGetValue;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function AssignObj(tf: TFldEdit): boolean; override;
		procedure HookProc(tf: TFldEdit; var Message: TMessage); override;
		procedure Paint(tf: TFldEdit); override;
    function MinSize(tf: TFldEdit): TSize; override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
    procedure DoPaint(tf: TFldEdit; const ARect: TRect; const Text: string); dynamic;
  	procedure Size(tf: TFldEdit; const Text: string; var Size: TSize); dynamic;
    procedure GetKeySt(tf: TFldEdit; var a: TArrStr); virtual;
    function Concave(tf: TFldEdit): boolean; virtual;
		class function RestValType: TGetRestValType; override;
    property OnClick: TButClickEvent read FOnClick write FOnClick;
    property OnPaint: TButPaintEvent read FOnPaint write FOnPaint;
    property OnSize: TButSizeEvent read FOnSize write FOnSize;
  public
    { Public declarations }
		constructor Create(AOwner: TComponent = nil); override;
    procedure Assign(Source: TPersistent); override;
		function Click(tf: TFldEdit; lEval: boolean): string; dynamic;
    procedure DrawText(tf: TFldEdit; const Text: string);
		procedure StdDWFldInfo(const Mask: string; var FldInfo: TDWFldInfo); override;
		procedure MaskPrn(const Mask: string; LsPrn: TStringList); override;
  	class function DDatSupport: boolean; override;
    property Caption: TCaption read FCaption write FCaption;
  published
    { Published declarations }
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

  TButGet = class(TCustomButGet)
  published
	  { Унаследованные }
    property Caption;
   	property RVid;
   	property RVName;
   	property VName;
    property OnClick;
    property OnPaint;
    property OnSize;
  end;

  TBFGPrm = record
  	MaxWidth,MaxHeight,ReadOnly: boolean;
  	ColCount,RowCount: longint;
  end;

  TButFormGet = class(TCustomButGet)
  private
	 	FNmProc: TKeyLbNmProc;
	 	FProcKey: TKeyProc;
    FEditType: TEdTextType;
    FOnBeforeClick,FOnAfterClick: TNotifyEvent;
    FOnHelp: TWndMethod;
    procedure SetNmProc(Value: TKeyLbNmProc);
  protected
  	Prm: TBFGPrm;
		procedure Rebuild(tf: TFldEdit); override;
    function AssignObj(tf: TFldEdit): boolean; override;
		procedure HookProc(tf: TFldEdit; var Message: TMessage); override;
		function GetEditValue(tf: TFldEdit): string; virtual;
		procedure SetEditValue(tf: TFldEdit; const Value: string); virtual;
		function DWFldUnAllowType(const Mask: string): TDWFldSetType; override;
    class procedure MaskEdChange(Sender: TObject; const OldVal: variant; FromShow: boolean); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
  public
    { Public declarations }
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
    procedure ReCreateObj(tf: TFldEdit); override;
		function Click(tf: TFldEdit; lEval: boolean): string; override;
		procedure MaskPrn(const Mask: string; LsPrn: TStringList); override;
  published
    property EditType: TEdTextType read FEditType write FEditType;
    property NmProc: TKeyLbNmProc read FNmProc write SetNmProc;
    property OnAfterClick: TNotifyEvent read FOnAfterClick write FOnAfterClick;
    property OnBeforeClick: TNotifyEvent read FOnBeforeClick write FOnBeforeClick;
    property OnHelp: TWndMethod read FOnHelp write FOnHelp;
	 	property OnProcKey: TKeyProc read FProcKey write FProcKey;
	  { Унаследованные }
    property Caption;
   	property RVid;
   	property RVName;
   	property VName;
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

procedure Register;

implementation

uses SysUtils,Forms,Variants,StrUtils,Math,
  My_pr,KeyLb,FPanel,Inter,KeyMenu;

{ TCustomButGet }
constructor TCustomButGet.Create;
begin
	AddStack('TCustomButGet.Create',Self);
	Inherited Create(AOwner);
  UpdateAllFld(mgCreate);
  DelStack;
end;

{ Создание объектов }
procedure TCustomButGet.CreateObj;
begin
	AddStack('TCustomButGet.CreateObj',Self);
	DestroyObj(tf); bDyn:=tf.DynButCreate;
  sE:=TPaintButton.Create(tf);
  with sE do begin
    Canvas:=tf.Canvas; BMByName(Glyph,bmEval); onClick:=EvalClick;
    if not Assigned(bDyn) then begin
      AllowAllUp:=true; Hint:='Редактировать'; ShowHint:=true;
    end;
  end;
  MemValue:=TButGetValue.Create(tf);
  inherited CreateObj(tf);
  DelStack;
end;

procedure TCustomButGet.HookProc;
begin
	AddStack('TCustomButGet.HookProc',Self);
  inherited HookProc(tf,Message);
  if Message.Msg=WM_LBUTTONDBLCLK then
    if AssignObj(tf) then
      if not Assigned(bDyn) then sE.Click;
  DelStack;
end;

procedure TCustomButGet.ReCreateObj;
var capt: string;
begin
	AddStack('TCustomButGet.ReCreateObj',Self);
	if AssignObj(tf) then begin
    capt:=ButMask2Prm(tf.Mask).Capt;
    if empty(capt) then capt:=FCaption;
    if empty(capt) then begin
      if not empty(sE.Caption) then BMByName(sE.Glyph,bmEval);
      sE.Caption:='';
    end
    else begin
      sE.Caption:=capt; sE.Glyph:=nil;
    end;
    sE.Visible := not(Assigned(bDyn) and empty(capt));
    inherited ReCreateObj(tf);
    tf.Refresh;
  end;
  DelStack;
end;

{ Нарисовать объекты }
procedure TCustomButGet.PaintObj;
var w,wc: longint;
	ts: TSchem;
begin
	AddStack('TCustomButGet.PaintObj',Self);
	if AssignObj(tf) then begin
    w:=DynButSize.cX;
    if Assigned(bDyn) then bDyn.SetBounds(tf.Width-BevelFld-w,BevelFld,w,tf.Height-BevelFld2)
    else if empty(sE.Caption) then begin
      w:=SysMetric.iScrollWidth;
    	sE.SetBounds(tf.Width-BevelFld-w,BevelFld,w,tf.Height-BevelFld2);
    end;
    if not empty(sE.Caption) then begin
      wc:=tf.DynCaptSize(tf.Height-BevelFld2).cX;
      if SchemName(tf.Schem,ts) then
        if tf.Active then tf.Font.Assign(ts.FontW) else tf.Font.Assign(ts.Font2);
    	sE.SetBounds(BevelFld+wc,BevelFld,tf.Width-BevelFld2-w-wc,MemValue.PaintRect.Top-BevelFld);
    end;
  end;
  DelStack;
end;

{ Автоматическая установка размеров }
function TCustomButGet.SizeAuto;
var s: string;
	ts: TSchem;
  dsz,dcsz: TSize;
  h: longint;
  a: TArrStr;
begin
	AddStack('TCustomButGet.SizeAuto',Self);
	result := inherited SizeAuto(tf,Opt);
  if AssignObj(tf) then begin
    if csDesigning in ComponentState then ts:=nil else SchemName(tf.Schem,ts);
    if Assigned(ts) then tf.Canvas.Font.Assign(ts.Font1)
    else begin
      tf.Canvas.Font.Assign(tf.Font);
      //tf.Canvas.Brush.Color:=tf.Color;
    end;
    s:=Click(tf,false); h:=LsArrDynamic(s,a,CRLF);
    if tf.CharHeight<0 then Exclude(Opt,tfszHeight);
    if tfszHeight in Opt then result.cY:=max(1,h)*CanvasMaxH(tf.Canvas);
    if tfszWidth in Opt then begin
      if h=0 then result.cX:=0 else result.cX:=tf.Canvas.TextWidth(a[0]);
      Inc(result.cX,6);
    end;
    Size(tf,s,result); if tfszHeight in Opt then Inc(result.cY,4);
    if empty(sE.Caption) then begin
    	if (tfszWidth in Opt) and not Assigned(bDyn) then Inc(result.cX,SysMetric.iScrollWidth);
    end
    else begin
      if tfszWidth in Opt then MaxSelf(result.cX,tf.CaptWidth(ts,sE.Caption));
      if tfszHeight in Opt then Inc(result.cY,tf.CaptHeight(ts));
    end;
    if Opt<>[] then begin
      dsz:=DynButSize; h:=max(result.cY,dsz.cY); dcsz:=tf.DynCaptSize(h);
      if tfszWidth in Opt then Inc(result.cX,dsz.cX+dcsz.cX);
      if tfszHeight in Opt then result.cY:=max(h,dcsz.cY);
    end;
  end;
  DelStack;
end;

{ Достать значение Value из объектов }
function TCustomButGet.GetValue;
begin
	AddStack('TCustomButGet.GetValue',Self);
  if AssignObj(tf) then result:=MemValue.Value else result:='';
  DelStack;
end;

{ Установить свойства объектов в соответствии с Value }
procedure TCustomButGet.SetValue;
begin
	AddStack('TCustomButGet.SetValue',Self);
  if AssignObj(tf) then begin
  	MemValue.Value:=v; tf.Refresh;
  end;
  DelStack;
end;

{ Действия при получении фокуса }
procedure TCustomButGet.DoEnter;
var tl: TKeyLb;
	ts: TSchem;
  a: TArrStr;
  i: longint;
begin
	AddStack('TCustomButGet.DoEnter',Self);
	inherited DoEnter(tf);
	if AssignObj(tf) then if SchemName(tf.Schem,ts) then tf.Font.Assign(ts.FontW);
  if FormKeyLb(tf,tl) and not((ogReadOnly in tf.Options) or Assigned(bDyn)) then begin
    GetKeySt(tf,a);
    for i:=low(a) to high(a) do tl.SetKeySt(a[i],ProcKey,'butget');
    tl.ReDrw;
  end;
  DelStack;
end;

procedure TCustomButGet.GetKeySt;
var tl: TKeyLb;
  i: byte;
begin
  AddStack('TCustomButGet.GetKeySt',Self);
  CopyFrom(a,
    [TKeyLb.GetKeySt(K_Space,sE.Hint,'',kmEdit)
    ,TKeyLb.GetKeySt(K_Space,'','',kmEdit)
    ,TKeyLb.GetKeySt(K_F5,K_Space)]);
  FormKeyLb(tf,tl);
  for i:=low(aKeyListDown) to high(aKeyListDown) do
    if not tl.IsKeyBut(aKeyListDown[i]) then AddFrom(a,[TKeyLb.GetKeySt([aKeyListDown[i]],K_Space)]);
  DelStack;
end;

{ Действия при утере фокуса }
procedure TCustomButGet.DoExit;
var tl: TKeyLb;
	MainMn: TKeyMenu;
	ts: TSchem;
begin
	AddStack('TCustomButGet.DoExit',Self);
	if AssignObj(tf) and not(csDestroying in tf.ComponentState) then
    if SchemName(tf.Schem,ts) then tf.Font.Assign(ts.Font2);
  if FormKeyLb(tf,tl) then begin
    if SeekKeyMenu(tf,MainMn) then MainMn.DelLine(kmEdit,K_Space);
  	tl.DelKey(K_All,'butget'); tl.ReDrw;
  end;
	inherited DoExit(tf);
  DelStack;
end;

procedure TCustomButGet.ProcKey;
begin
	AddStack('TCustomButGet.ProcKey',Self);
	if AssignObj(pointer(tw)) then sE.Click;
  DelStack;
end;

{ Редактирование по SpeedButton }
procedure TCustomButGet.EvalClick;
var tf: TFldEdit;
begin
	AddStack('TCustomButGet.EvalClick',Self);
	tf:=pointer(TPaintButton(Sender).Owner);
	if not tf.Active then tf.SetFocus;
  if AssignObj(tf) then
    try
      if not(ogReadOnly in tf.Options) then
        if Assigned(bDyn) then bDyn.Click
        else begin
          sE.Down:=true; FDoPaint(tf,Click(tf,true));
        end;
    finally
      if AssignObj(tf) then sE.Down:=false;
    end;
  DelStack;
end;

{ Поиск объектов }
function TCustomButGet.AssignObj;
var n: byte;
  wc: longint;
begin
	AddStack('TCustomButGet.AssignObj',Self);
	sE:=nil; MemValue:=nil; result:=false;
  if inherited AssignObj(tf) then begin
    n:=IfThen(Assigned(bDyn),1);
		if tf.ComponentCount>n+1 then
      if IsClass(tf.Components[n],TPaintButton,pointer(sE))
      and IsClass(tf.Components[n+1],TButGetValue,pointer(MemValue)) then begin
        wc:=tf.DynCaptSize(tf.Height-BevelFld).cX;
        MemValue.PaintRect:=Rect(BevelFld+wc,BevelFld,tf.Width-BevelFld,tf.Height-BevelFld);
        if not empty(sE.Caption) then Inc(MemValue.PaintRect.Top,tf.CaptHeight(SchemName(tf.Schem)));
        if Assigned(bDyn) then Dec(MemValue.PaintRect.Right,DynButSize.cX)
        else if empty(sE.Caption) then Dec(MemValue.PaintRect.Right,SysMetric.iScrollWidth);
        result:=true;
      end;
  end;
  DelStack;
end;

function TCustomButGet.Click;
begin
	AddStack('TCustomButGet.Click',Self);
  if Assigned(FOnClick) then result:=FOnClick(tf,lEval) else result:='';
  DelStack;
end;

procedure TCustomButGet.Paint;
begin
	AddStack('TCustomButGet.Paint',Self);
  FDoPaint(tf,Click(tf,false));
  DelStack;
end;

procedure TCustomButGet.FDoPaint;
var r: TRect;
	ts: TSchem;
begin
	AddStack('TCustomButGet.FDoPaint',Self);
  if AssignObj(tf) then begin
    r:=MemValue.PaintRect; Frame3D2(tf.Canvas,r,Concave(tf));
    if SchemName(tf.Schem,ts) then tf.Canvas.Font.Assign(ts.Font1);
    tf.Canvas.Brush.Color:=tf.Color1(ts); DoPaint(tf,r,Text);
  end;
  DelStack;
end;

function TCustomButGet.Concave;
begin
  result:=true;
end;

procedure TCustomButGet.DoPaint;
begin
	AddStack('TCustomButGet.DoPaint',Self);
	if Assigned(FOnPaint) then FOnPaint(tf,ARect,Text) else DrawText(tf,Text);
  DelStack;
end;

function TCustomButGet.MinSize;
var ts: TSchem;
  dsz: TSize;
begin
  AddStack('TCustomButGet.MinSize',Self);
  result := inherited MinSize(tf);
  if AssignObj(tf) then begin
    if not empty(sE.Caption) then begin
      SchemName(tf.Schem,ts); WinSize(result,tf.CaptWidth(ts,sE.Caption),tf.CaptHeight(ts));
    end;
    if Assigned(bDyn) then begin
      dsz:=DynButSize; MaxSelf(result.cY,dsz.cY);
      Inc(result.cX,dsz.cX+tf.DynCaptSize(result.cY).cX);
    end;
  end;
  DelStack;
end;

procedure TCustomButGet.Size;
begin
	AddStack('TCustomButGet.Size',Self);
  if Assigned(FOnSize) then FOnSize(tf,Text,Size);
  DelStack;
end;

procedure TCustomButGet.DrawText;
var i,tb,h: longint;
	r: TRect;
  a: TArrStr;
begin
	AddStack('TCustomButGet.DrawText',Self);
  if AssignObj(tf) then begin
    r:=MemValue.PaintRect; InflateRect(r,-2,-2);
    with tf.Canvas do begin
      FillRect(r); tb:=r.Top; Inc(r.Left);
      for i:=0 to LsArrDynamic(Text,a,CRLF)-1 do begin
        h:=CanvasMaxH(tf.Canvas);
        TextRect(Rect(r.Left,tb,min(r.Left+TextWidth(a[i]),r.Right),min(tb+h,r.Bottom)),r.Left,tb-1,a[i]);
        Inc(tb,h);
        if tb>=r.Bottom then break;
      end;
    end;
  end;
  DelStack;
end;

class function TCustomButGet.RestValType;
begin
	result:=grvNone;
end;

procedure TCustomButGet.StdDWFldInfo;
var capt: string;
begin
	AddStack('TCustomButGet.StdDWFldInfo',Self);
  capt:=ButMask2Prm(Mask).Capt;
  if capt<>'' then FldInfo.DisplayLabel:=capt;
  DelStack;
end;

function TCustomButGet.MaskTrans;
var Prm: TButGetPrm;
begin
	AddStack('TCustomButGet.MaskTrans');
	if MyVarType(av)=varArray
  then result:=ButPrm2Mask(TrimRight(IsNilc(av[1],'')),TrimRight(IsNilc(av[2],'')))
  else begin
    Prm:=ButMask2Prm(av);
    result:=ArrVarToVar(
      [VarArrayOf([mpEdit,'Заголовок',Prm.Capt])
      ,VarArrayOf([mpEdit,'Доп.данные',Prm.Mask])
      ]);
  end;
  DelStack;
end;

procedure TCustomButGet.MaskPrn;
var Prm: TButGetPrm;
begin
	AddStack('TCustomButGet.MaskPrn',Self);
  Prm:=ButMask2Prm(Mask);
  if not empty(Prm.Capt) then LsPrn.Add('Заголовок: '+Prm.Capt);
  if not empty(Prm.Mask) then LsPrn.Add('Дополнительные данные: '+Prm.Mask);
  DelStack;
end;

procedure TCustomButGet.FMaskHelp;
var n: byte;
  s: string;
begin
  AddStack('TCustomButGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+3);
  s:=HelpBoldStr('«Заголовок»');
  Inc(n); CopyFrom(ht.Dat[n],HelpIfEmpty(s,'"'+cButCapt+'"+'+s+'+"'+cAtPartEnd+'"')+'+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr('«Дополнительные данные»'));
  DelStack;
end;

procedure TCustomButGet.Assign;
var cg: TCustomButGet;
begin
	AddStack('TCustomButGet.Assign',Self);
  if IsClass(Source,TCustomButGet,pointer(cg)) then begin
  	OnClick:=cg.OnClick;
  	OnPaint:=cg.OnPaint;
  	OnSize:=cg.OnSize;
  end;
	inherited Assign(Source);
  DelStack;
end;

class function TCustomButGet.DDatSupport;
begin
  result:=true;
end;

{ TButFormGet }
function BFGPrm(const ms: string): TBFGPrm;
var a: array[1..3] of string;
	m: string;
begin
  AddStack('ButGet.BFGPrm');
  with result do begin
    m:=ButMask2Prm(ms).Mask; ReadOnly := Pos(bfgReadOnly,AnsiUpperCase(m))>0;
    if ReadOnly then StrTranSelf(m,bfgReadOnly,'',[rfReplaceAll,rfIgnoreCase]);
    LsArrFill(m,a,','); RowCount:=Int0(a[1]); ColCount:=Int0(a[2]);
    if m=cButFormMax then begin
    	MaxWidth:=true; MaxHeight:=true;
    end
    else begin
      MaxWidth := ColCount=0; MaxHeight := RowCount=0;
    end;
  end;
  DelStack;
end;

constructor TButFormGet.Create;
begin
	AddStack('TButFormGet.Create',Self);
	FNmProc:=TKeyLbNmProc.Create; FEditType:=edtpInter;
  inherited Create(AOwner);
  DelStack;
end;

destructor TButFormGet.Destroy;
begin
	AddStack('TButFormGet.Destroy',Self);
  inherited Destroy;
  FNmProc.Free;
  DelStack;
end;

procedure TButFormGet.ReCreateObj;
begin
  AddStack('TButFormGet.ReCreateObj',Self);
  with BFGPrm(tf.Mask) do begin
    if ArrIntMatch(tf.CharWidth,[wallDefault,0]) then tf.CharWidth:=IfThen(MaxWidth,wallDefault);
    tf.CharHeight:=IfThen(MaxHeight,-1);
  end;
  inherited RecreateObj(tf);
  DelStack;
end;

procedure TButFormGet.Rebuild;
begin
	AddStack('TButFormGet.Rebuild',Self);
	ReCreateObj(tf);
  DelStack;
end;

function TButFormGet.Click;
var i,l,w,h,wp,hp: longint;
  fl: boolean;
  s,capt: string;
  ts: TSchem;
  tp: TWinControl;
  a: TArrStr;
begin
	AddStack('TButFormGet.Click',Self);
	result:='';
	if AssignObj(tf) then begin
    if lEval then begin
      IfThenNotify(FOnBeforeClick,tf);
      capt:=FCaption;
      if empty(capt) then capt:=ButMask2Prm(tf.Mask).Capt;
      if nPrnHead>0 then begin
      	s:=''; i:=nPrnHead;
        if aPrnHead[i]=capt then Dec(i);
        if i>0 then begin
          for i:=i downto 1 do IncD(s,';'+DelTrim(aPrnHead[i]));
          IncD(capt,'('+Copy(s,2,MaxInt)+')');
        end;
      end;
      s:=TextCRLF(GetEditValue(tf));
      AddPrnHead(sE.Caption);
      fl:=EdTextExec(capt,s,FNmProc.Text,FProcKey,
        IfThen(Prm.ReadOnly,edtxtReadonly),FEditType,0,0,'',tf.HelpContext,nil,'',nil,nil,'',nil,nil,FOnHelp);
      DelPrnHead;
      IfThenNotify(FOnAfterClick,tf);
      if fl then SetEditValue(tf,TextCRLF(s));
    end;
    l:=LsArrDynamic(GetEditValue(tf),a,CRLF);
    if not(Prm.MaxWidth and Prm.MaxHeight) then begin
      h:=Prm.RowCount; SchemName(tf.Schem,ts);
      w:=max(Prm.ColCount,tf.CaptWidth(ts,sE.Caption) div CanvasMaxW(tf.Canvas));
      tp:=tf.Parent; fl := tp is TRbPanel;
      if Assigned(ts) then tf.Canvas.Font.Assign(ts.Font1);
      if fl then with TRbPanel(tp) do begin
        wp:=CltWidth; hp:=CltHeight-HeaderHeight;
      end
      else begin
        wp:=tp.Width; hp:=tp.Height;
      end;
      if Prm.MaxHeight then h:=max(1,(hp-BevelFld2-10-IfThen(not empty(sE.Caption),
        tf.Canvas.TextHeight(sE.Caption)+6)) div CanvasMaxH(tf.Canvas));
      if Prm.MaxWidth then w:={max(2,}(wp-BevelFld2
        -IfThen(empty(sE.Caption),SysMetric.iScrollWidth)-14)
        div CanvasMaxW(tf.Canvas){)};
      ArrStrAlign(a,l,w,h,fl);
    end;
    result:=ArrayAsList(a,CRLF,l);
  end;
  DelStack;
end;

procedure TButFormGet.SetNmProc;
begin
	AddStack('TButFormGet.SetNmProc',Self);
	NmProc.Assign(Value);
  DelStack;
end;

function TButFormGet.GetEditValue;
begin
	AddStack('TButFormGet.GetEditValue',Self);
	result:=tf.Value;
  DelStack;
end;

procedure TButFormGet.SetEditValue;
begin
	AddStack('TButFormGet.SetEditValue',Self);
	tf.Value:=Value;
  DelStack;
end;

function TButFormGet.AssignObj;
begin
	AddStack('TButFormGet.AssignObj',Self);
	Prm:=BFGPrm(tf.Mask);
	result := inherited AssignObj(tf);
  DelStack;
end;

procedure TButFormGet.HookProc;
begin
	AddStack('TButFormGet.HookProc',Self);
  inherited HookProc(tf,Message);
  case Message.Msg of
    WM_PSORT: with TWMPSort(Message) do case Oper of
      swmColWidthAll: if BFGPrm(tf.Mask).MaxWidth then Result:=tf.CharWidth;
      swmColHeightAll: if BFGPrm(tf.Mask).MaxHeight then Result:=-1;
    end;
    WM_HELPFILL: if tf.Active then IfThenWndMethod(FOnHelp,Message);
  end;
  DelStack;
end;

function TButFormGet.MaskTrans;
var Prm: TBFGPrm;
  av1: variant;
begin
	AddStack('TButFormGet.MaskTrans');
	if MyVarType(av)=varArray then begin
    av1:=AddFrom(av,null);
	  av1[2]:=IfThen(IsNilc(av[2],true),cButFormMax,IntToStr(IsNilc(av[3],1)))
      +','+ IfThen(IsNilc(av[4],true),cButFormMax,IntToStr(IsNilc(av[5],1)))
      +IfThen(IsNilc(av[6],false),bfgReadOnly,'');
		result := inherited MaskTrans(av1,r,nmf);
  end
  else begin
		result := inherited MaskTrans(av,r,nmf);
		Prm:=BFGPrm(av); VarArrayReDim(result,6);
    result[2]:=VarArrayOf([mpBool,'Максимальная высота',Prm.MaxHeight]);
    result[3]:=VarArrayOf([mpSpin,'Количество строк',Prm.RowCount,1,999]);
    result[4]:=VarArrayOf([mpBool,'Максимальная ширина',Prm.MaxWidth]);
    result[5]:=VarArrayOf([mpSpin,'Количество символов в строке',Prm.ColCount,1,999]);
    result[6]:=VarArrayOf([mpBool,'Только для просмотра',Prm.ReadOnly]);
  end;
  DelStack;
end;

procedure TButFormGet.MaskPrn;
var Capt: string;
	Prm: TBFGPrm;
begin
	AddStack('TButFormGet.MaskPrn',Self);
  Capt:=ButMask2Prm(Mask).Capt; Prm:=BFGPrm(Mask);
  if not empty(Capt) then LsPrn.Add('Заголовок: '+Capt);
  with Prm do begin
	  LsPrn.Add('Высота: '+IfThen(MaxHeight,'максимум',Format('%d строк',[RowCount])));
	  LsPrn.Add('Ширина: '+IfThen(MaxWidth,'максимум',Format('%d символов',[ColCount])));
  end;
  DelStack;
end;

function TButFormGet.DWFldUnAllowType;
begin
  result:=[low(aDWFld)..high(aDWFld)]-[dwtString,dwtMemo,dwtManyStr];
end;

class procedure TButFormGet.MaskEdChange;
begin
	AddStack('TButFormGet.MaskEdChange');
	if Sender=EdMaskFld(2) then EdMaskFld(3).SetReadOnly(GetEdMaskVal(2));
	if Sender=EdMaskFld(4) then EdMaskFld(5).SetReadOnly(GetEdMaskVal(4));
  DelStack;
end;

procedure TButFormGet.FMaskHelp;
var n: byte;
begin
  AddStack('TButFormGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+3);
  CopyFrom(ht.Dat[n],HelpIf('«Максимальная высота»','"'+cButFormMax+'"',HelpNum('«Количество строк»'))+'+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpIf('«Максимальная ширина»','"'+cButFormMax+'"',HelpNum('«Количество символов в строке»'))+'+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpIf('«Только для просмотра»','"'+bfgReadOnly+'"','""'));
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TButGet,TButFormGet]);
end;

end.
