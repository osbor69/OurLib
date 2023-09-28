unit BtTxtGet;

interface

{$I LIBTEST}
uses Windows,Messages,Classes,Controls,
  MyTypes,MemoGet,PaintCtl,FFldEdit,RecVal;

type
  TButTextGetPrm = record
    Capt,Dop: string;
    NoLimSize: boolean;
    MinHeight: longint;
  end;

  TButTextGet = class(TSimpleMemoGet)
  private
  	FDimStr: array[1..2] of string;
    FTextReadOnly: boolean;
    FOnClick: TNotifyEvent;
    procedure sECapt;
    function GetDimStr(Index: longint): string;
    procedure SetDimStr(Index: longint; const Value: string);
		procedure SetTextReadOnly(Value: boolean);
    procedure EvalClick(Sender: TObject);
		procedure ProcKey(key: longint; tw: TWinControl);
		function GetHint: string;
  protected
    sE: TPaintButton;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function AssignObj(tf: TFldEdit): boolean; override;
		procedure Click(tf: TFldEdit); dynamic;
    class procedure FMaskView(var Mask: string); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
    procedure MaskFrmShow(Sender: TObject); override;
    class procedure MaskEdChange(Sender: TObject; const OldVal: variant; FromShow: boolean); override;
		procedure HookProc(tf: TFldEdit; var Message: TMessage); override;
  public
		constructor Create(AOwner: TComponent = nil); override;
    procedure Assign(Source: TPersistent); override;
		class function MaskTextReadOnly: boolean; override;
		procedure MaskPrn(const Mask: string; LsPrn: TStringList); override;
    class function MaskToPrm(const Mask: string): TButTextGetPrm; virtual;
    class function PrmToMask(const Prm: TButTextGetPrm): string;
    procedure InsText(tf: TFldEdit; const s: string);
  published
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
    property Hint: string index 1 read GetDimStr write SetDimStr;
    property Picture: string index 2 read GetDimStr write SetDimStr;
    property TextReadOnly: boolean read FTextReadOnly write SetTextReadOnly;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
	  { Унаследованные }
   	property RVid;
   	property RVName;
   	property VName;
    property OnMaskTrans;
    property OnMaskHelp;
  end;

  TButManyStrGet = class(TMemoGet)
  protected
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
  end;

  TBtMskCapt = (btmCapt,btmKey);
  TBtMskSizeEvent = procedure(Sender: TObject; Opt: TFESizeAutoOpt; var Size: TSize) of object;

	TBtMskGet = class(TCustomGet)
  private
    FOnPaint: TNotifyEvent;
    FOnSize: TBtMskSizeEvent;
		procedure tpClick(Sender: TObject);
		procedure ProcKey(key: longint; tw: TWinControl);
  protected
  	tp: TPaintButton;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
		function AssignObj(tf: TFldEdit): boolean; override;
    class procedure FMaskView(var Mask: string); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
    procedure Eval(tf: TFldEdit); virtual;
    function CaptDefault(tf: TFldEdit; Vid: TBtMskCapt): string; virtual;
  public
    constructor Create(AOwner: TComponent); override;
		procedure MaskPrn(const Mask: string; LsPrn: TStringList); override;
		procedure StdDWFldInfo(const Mask: string; var FldInfo: TDWFldInfo); override;
		class function MaskTextReadOnly: boolean; override;
  	function MaskSearch(const Mask,SubStr: string; lIdent: boolean): boolean; override;
		function MaskReplace(var Mask: string; const stSource,sRepl: string;
    	lIdent: boolean; PrRepl: TReplaceProc; pav: PVariant): longint; override;
  	class function DDatSupport: boolean; override;
  	class function DDatPaintPeriod: boolean; override;
  published
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnSize: TBtMskSizeEvent read FOnSize write FOnSize;
   	property VName;
  end;

  TButEvalGet = class(TButTextGet)
  protected
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
		procedure Click(tf: TFldEdit); override;
  public
    constructor Create(AOwner: TComponent); override;
  	function MaskSearch(const Mask,SubStr: string; lIdent: boolean): boolean; override;
		function MaskReplace(var Mask: string; const stSource,sRepl: string;
    	lIdent: boolean; PrRepl: TReplaceProc; pav: PVariant): longint; override;
  published
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

procedure Register;

implementation

uses SysUtils,Math,StrUtils,Variants,
  My_pr,Schem,KeyLb,KeyMenu,Inter,PnlEdit;

var nButTxt: byte;

{ TButTextGet }
constructor TButTextGet.Create;
begin
	AddStack('TButTextGet.Create',Self);
	TextReadOnly:=false;
	Inherited Create(AOwner);
  RVid:='';
  DelStack;
end;

procedure TButTextGet.SetTextReadOnly;
begin
	AddStack('TButTextGet.SetTextReadOnly',Self);
	if Value<>FTextReadOnly then begin
	  FTextReadOnly:=Value; UpdateAllFld(mgRecreate);
  end;
  DelStack;
end;

{ Создание объектов }
procedure TButTextGet.CreateObj;
begin
	AddStack('TButTextGet.CreateObj',Self);
  inherited CreateObj(tf);
  if inherited AssignObj(tf) then tm.NoInsDateTime:=true;
  if not Assigned(bDyn) then begin
    sE:=TPaintButton.Create(tf);
    with sE do begin
      Canvas:=tf.Canvas; ShowHint:=true; onClick:=EvalClick; sECapt;
    end;
  end;
  tf.ReCreateObj;
  DelStack;
end;

procedure TButTextGet.ReCreateObj;
var Prm: TButTextGetPrm;
  fl: boolean;
begin
	AddStack('TButTextGet.ReCreateObj',Self);
	if AssignObj(tf) then begin
    inherited ReCreateObj(tf);
    if FTextReadOnly then tm.ReadOnly:=true;
    Prm:=MaskToPrm(tf.Mask);
    if Assigned(sE) then with sE do begin
      if empty(Prm.Capt) then begin
        if not empty(Caption) then sECapt;
        Caption:='';
      end
      else begin
        Caption:=Prm.Capt; Glyph:=nil;
      end;
      Hint:=GetHint;
      fl:=not(ogReadOnly in tf.Options);
      if Enabled<>fl then begin
        Enabled:=fl; Paint;
      end;
    end;
    tm.WordWrapBool:=Prm.NoLimSize; tm.MinHeight:=Prm.MinHeight;
  end;
  DelStack;
end;

procedure TButTextGet.sECapt;
begin
  AddStack('TButTextGet.sECapt',Self);
  with sE do if Picture='' then BMByName(Glyph,bmEval) else BMByName(Glyph,Picture);
  DelStack;
end;

{ Нарисовать объекты }
procedure TButTextGet.PaintObj;
var w,wc: longint;
	ts: TSchem;
  b: TPaintButton;
begin
	AddStack('TButTextGet.PaintObj',Self);
	if AssignObj(tf) then begin
    if csDesigning in ComponentState then ts:=nil else SchemName(tf.Schem,ts);
    tm.Color:=tf.Color1(ts);
    if Assigned(ts) then tm.Font.Assign(ts.Font1);
    with tf do if Assigned(sE) and (sE.Caption<>'') then begin
      if SchemName(tf.Schem,ts) then
        if tf.Active then tf.Font.Assign(ts.FontW) else tf.Font.Assign(ts.Font2);
      sE.SetBounds(BevelFld,BevelFld,Width-BevelFld2,CaptHeight(ts));
      tm.SetBounds(BevelFld,sE.Top+sE.Height,sE.Width-2,Height-BevelFld2-sE.Height-2);
    end
    else begin
      if Assigned(bDyn) then begin
        w:=DynButSize.cX; b:=bDyn;
      end
      else begin
        w:=SysMetric.iScrollWidth; b:=sE;
      end;
      b.SetBounds(Width-BevelFld-w,BevelFld,w,Height-BevelFld2);
      wc:=tf.DynCaptSize(Height-BevelFld2).cX;
      tm.SetBounds(BevelFld+2+wc,BevelFld+2,Width-BevelFld2-w-4-wc,b.Height-4);
    end;
  end;
  DelStack;
end;

{ Автоматическая установка размеров }
function TButTextGet.SizeAuto;
var ts: TSchem;
  fl: boolean;
  h: longint;
begin
	AddStack('TButTextGet.SizeAuto',Self);
	result := inherited SizeAuto(tf,Opt);
  if AssignObj(tf) then if Opt<>[] then begin
    if csDesigning in ComponentState then ts:=nil else SchemName(tf.Schem,ts);
    if Assigned(sE) then fl := sE.Caption<>'' else fl:=false;
    if (tfszWidth in Opt) and Assigned(sE) then
      if fl
      then MaxSelf(result.cX,tf.CaptWidth(ts,sE.Caption))
      else Inc(result.cX,SysMetric.iScrollWidth);
    if tfszHeight in Opt then begin
      tf.Canvas.Font.Assign(tm.Font); h:=tm.MinHeight*CanvasMaxH(tf.Canvas)+2;
      if fl then result.cY:=tf.CaptHeight(ts)+h else MaxSelf(result.cY,h+2);
    end;
  end;
  DelStack;
end;

{ Действия при получении фокуса }
procedure TButTextGet.DoEnter;
var tl: TKeyLb;
	MainMn: TKeyMenu;
  i: byte;
  a: TArrInt;
	ts: TSchem;
begin
	AddStack('TButTextGet.DoEnter',Self);
	inherited DoEnter(tf);
	if AssignObj(tf) then if SchemName(tf.Schem,ts) then tf.Font.Assign(ts.FontW);
  if FormKeyLb(tf,tl) and not((ogReadOnly in tf.Options) or Assigned(bDyn)) then with tl do begin
    CopyFromInt(a,K_F5);
    if FTextReadOnly then AddFromInt(a,K_Space);
    for i:=low(aKeyListDown) to high(aKeyListDown) do
      if not IsKeyBut(aKeyListDown[i]) then AddFromInt(a,aKeyListDown[i]);
    DelKeys(a); SetKeys(a,GetHint,'',ProcKey,'buttextget',kmEdit); ReDrw;
    if SeekKeyMenu(tf,MainMn) then MainMn.InsLine(kmEdit,K_F5);
  end;
  DelStack;
end;

{ Действия при утере фокуса }
procedure TButTextGet.DoExit;
var tl: TKeyLb;
	MainMn: TKeyMenu;
	ts: TSchem;
begin
	AddStack('TButTextGet.DoExit',Self);
	if AssignObj(tf) and not(csDestroying in tf.ComponentState) then
    if SchemName(tf.Schem,ts) then tf.Font.Assign(ts.Font2);
  if SeekKeyMenu(tf,MainMn) then MainMn.DelLine(kmEdit,K_F5);
  if FormKeyLb(tf,tl) then begin
  //and Assigned(GetParentForm(tf).ActiveControl) then begin
  	tl.DelKey(K_All,'buttextget'); tl.ReDrw;
  end;
	inherited DoExit(tf);
  DelStack;
end;

procedure TButTextGet.ProcKey;
begin
	AddStack('TButTextGet.ProcKey',Self);
	if AssignObjOwner(tw) then sE.Click;
  DelStack;
end;

{ Поиск объектов }
function TButTextGet.AssignObj;
begin
	AddStack('TButTextGet.AssignObj',Self);
	sE:=nil; result:=false;
  if inherited AssignObj(tf) then
    if Assigned(bDyn) then result:=true
    else if tf.ComponentCount>1 then result:=IsClass(tf.Components[1],TPaintButton,pointer(sE));
  DelStack;
end;

{ Редактирование по SpeedButton }
procedure TButTextGet.EvalClick;
var tf: TFldEdit;
begin
	AddStack('TButTextGet.EvalClick',Self);
	tf:=pointer(TPaintButton(Sender).Owner);
	if not tf.Active then DoEnter(tf);
  if AssignObj(tf) then 
    try
      if not(ogReadOnly in tf.Options) then begin
        sE.Down:=true; Click(tf);
      end;
    finally
      if AssignObj(tf) then sE.Down:=false;
    end;
  DelStack;
end;

procedure TButTextGet.Click;
begin
  AddStack('TButTextGet.Click',Self);
  IfThenNotify(FOnClick,tf);
  DelStack;
end;

function TButTextGet.GetHint;
begin
	AddStack('TButTextGet.GetHint',Self);
	result:=IfThen(Hint='','Редактировать',Hint);
  DelStack;
end;

function TButTextGet.GetDimStr;
begin
  AddStack('TButTextGet.GetDimStr',Self);
  result:=FDimStr[Index];
  DelStack;
end;

procedure TButTextGet.SetDimStr;
begin
  AddStack('TButTextGet.SetDimStr',Self);
  FDimStr[Index]:=Value;
  DelStack;
end;

procedure TButTextGet.Assign;
begin
	AddStack('TButTextGet.Assign',Self);
  if Source is TButTextGet
  then OnClick:=TButTextGet(Source).OnClick;
	inherited Assign(Source);
  DelStack;
end;

function TButTextGet.MaskTrans;
var Prm: TButTextGetPrm;
begin
	AddStack('TButTextGet.MaskTrans',Self);
	if MyVarType(av)=varArray then begin
    Prm.Capt:=IsNilc(av[1],''); Prm.NoLimSize:=IsNilc(av[2],false); Prm.MinHeight:=IsNilc(av[3],1);
    Prm.Dop:=IsNilc(av[4],''); result:=PrmToMask(Prm);
  end
  else begin
    Prm:=MaskToPrm(av);
    result:=ArrVarToVar(
      [VarArrayOf([mpEdit,'Заголовок',Prm.Capt])
      ,VarArrayOf([mpBool,'Размеры не ограничены',Prm.NoLimSize])
      ,VarArrayOf([mpSpin,'Минимальное количество строк',Prm.MinHeight,0,99])
      ,VarArrayOf([mpCustom,'Доп.данные',Prm.Dop,IntNil])
      ]);
  end;
  DelStack;
end;

procedure TButTextGet.MaskFrmShow;
begin
	AddStack('TButTextGet.MaskFrmShow',Self);
  EdMaskFld(3).SetReadOnly(true,ogReadOnlyNoVsbl);
  with EdMaskFld(4) do SetReadOnly(not Assigned(curget),[ogReadOnly,ogReadOnlyNoVsbl]);
  DelStack;
end;

class procedure TButTextGet.MaskEdChange;
begin
  AddStack('TButTextGet.MaskEdChange');
  EdMaskFld(3).SetReadOnly(not GetEdMaskVal(2));
  DelStack;
end;

class function TButTextGet.MaskTextReadOnly;
begin
	result:=true;
end;

class procedure TButTextGet.FMaskView;
var Prm: TButTextGetPrm;
begin
  AddStack('TButTextGet.FMaskView');
  Prm:=MaskToPrm(Mask);
  Mask:=DlmBetween(IfThen(Prm.Capt<>'','заголовок:'+Prm.Capt),
    IfThen(Prm.NoLimSize,StrNum('мин.строк:',Prm.MinHeight)),',');
  DelStack;
end;

procedure TButTextGet.FMaskHelp;
var n: byte;
  s: string;
begin
  AddStack('TButTextGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+4);
  s:=HelpBoldStr('«Заголовок»');
  Inc(n); CopyFrom(ht.Dat[n],HelpIfEmpty(s,'"'+cButCapt+'"+'+s+'+"'+cAtPartEnd+'"')+'+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpBool('«Размеры не ограничены»')+'+"'+UnDelim+'"+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpNum('«Минимальное количество строк»'));
  DelStack;
end;

procedure TButTextGet.MaskPrn;
var Prm: TButTextGetPrm;
begin
	AddStack('TButTextGet.MaskPrn',Self);
  Prm:=MaskToPrm(Mask);
  if Prm.Capt<>'' then LsPrn.Add('Заголовок: '+Prm.Capt);
  if Prm.NoLimSize then LsPrn.Add(StrNum('Минимальное количество строк: ',Prm.MinHeight));
  DelStack;
end;

class function TButTextGet.MaskToPrm(const Mask: string): TButTextGetPrm;
//var a: array[1..3] of string;
var a: TNamePrimStr;
begin
  AddStack('TButTextGet.MaskToPrm');
  with result do begin
    //LsArrFill(StrToAtPart(Mask,Capt,cButCapt),a,UnDelim);
    //NoLimSize:=StrToBoolean(a[1]); MinHeight:=max(1,Int0(a[2])); Dop:=a[3];
    StrDivDlm(UnDelim,StrToAtPart(Mask,Capt,cButCapt),a); NoLimSize:=StrToBoolean(a[2]);
    StrDivDlm(UnDelim,a[2],a); MinHeight:=max(1,Int0(a[1])); Dop:=a[2];
  end;
  DelStack;
end;

class function TButTextGet.PrmToMask;
begin
  AddStack('TButTextGet.PrmToMask');
  with Prm do result:=AtPartToStr(Capt,cButCapt)+ArrayAsList([bStr[NoLimSize],IntToStr(MinHeight),Dop],UnDelim);
  DelStack;
end;

procedure TButTextGet.HookProc;
begin
	AddStack('TButTextGet.HookProc',Self);
  inherited HookProc(tf,Message);
  with TWMPlaceToCtrl(Message) do if Msg=WM_PLACETOCTRL then if AssignObj(tf) then
    if sE.Caption<>'' then Sender^:=@sE
    else if tf.CharHeight<0 then Sender^:=nil;
  DelStack;
end;

procedure TButTextGet.InsText;
begin
  AddStack('TButTextGet.InsText',Self);
  if AssignObj(tf) then tm.InsText(s);
  DelStack;
end;

{ TButManyStrGet }
function TButManyStrGet.GetValue;
begin
  AddStack('TButManyStrGet.GetValue',Self);
  result:=StrTran(RightStrDel(inherited GetValue(tf),CRLF),CRLF,UnDelim);
  DelStack;
end;

procedure TButManyStrGet.SetValue;
begin
  AddStack('TButManyStrGet.SetValue',Self);
  inherited SetValue(tf,StrTran(v,UnDelim,CRLF));
  DelStack;
end;

{ TBtMskGet }
const BtMskCapt = 'Формула клавиши выполнения';

constructor TBtMskGet.Create;
begin
	AddStack('TBtMskGet.Create',Self);
	inherited Create(AOwner);
  RVid:='Клавиша выполнения';
  DelStack;
end;

procedure TBtMskGet.CreateObj;
begin
	AddStack('TBtMskGet.CreateObj',Self);
	DestroyObj(tf);
  tp:=TPaintButton.Create(tf); tp.Canvas:=tf.Canvas; tp.onClick:=tpClick; tp.OnPaint:=FOnPaint;
  inherited CreateObj(tf);
  DelStack;
end;

procedure TBtMskGet.ReCreateObj;
var fl: boolean;
  s: string;
begin
	AddStack('TBtMskGet.ReCreateObj',Self);
  if AssignObj(tf) then begin
    s:=ButMask2Prm(tf.Mask).Capt;
    if s='' then s:=CaptDefault(tf,btmCapt);
    tp.Caption:=s; fl:=not(ogReadOnly in tf.Options);
    if tp.Enabled<>fl then begin
	    tp.Enabled:=fl; tp.Paint;
    end;
    tp.ShowHint:=tf.ShowHint; tp.Hint:=tf.Hint;
    inherited ReCreateObj(tf);
  end;
  DelStack;
end;

function TBtMskGet.CaptDefault;
begin
  result:='Выполнить';
end;

procedure TBtMskGet.PaintObj;
var ts: TSchem;
begin
	AddStack('TBtMskGet.PaintObj',Self);
  if AssignObj(tf) then with tf do begin
    if SchemName(Schem,ts) then
      if Active then Font.Assign(ts.FontW) else Font.Assign(ts.Font2);
  	tp.SetBounds(BevelFld,BevelFld,Width-BevelFld2,Height-BevelFld2);
  end;
  DelStack;
end;

function TBtMskGet.SizeAuto;
var ts: TSchem;
  sz: TSize;
begin
	AddStack('TBtMskGet.SizeAuto',Self);
  result := inherited SizeAuto(tf,Opt);
  if not((csDestroying in ComponentState) or (csDestroying in tf.ComponentState)) then
    if AssignObj(tf) and (Opt<>[]) then
      if Assigned(FOnSize) then FOnSize(tf,Opt,result)
      else with tf.Canvas do begin
        if SchemName(tf.Schem,ts) then Font.Assign(ts.Font2) else Font.Assign(tf.Font);
        result:=tp.MinSize;
        if Assigned(ts) then begin
          Font.Assign(ts.FontW); sz:=tp.MinSize;
          if tfszHeight in Opt then MaxSelf(result.cY,sz.cy);
          if tfszWidth in Opt then MaxSelf(result.cX,sz.cx);
        end;
        if tfszHeight in Opt then Inc(result.cY,4);
        if tfszWidth in Opt then Inc(result.cX,10);
      end;
  DelStack;
end;

procedure TBtMskGet.DoEnter;
var tl: TKeyLb;
	MainMn: TKeyMenu;
  ts: TSchem;
  a: TArrInt;
  hnt: string;
begin
	AddStack('TBtMskGet.DoEnter',Self);
  inherited DoEnter(tf);
  if SchemName(tf.Schem,ts) then tf.Font.Assign(ts.FontW);
  if FormKeyLb(tf,tl) and not(ogReadOnly in tf.Options) then with tl do begin
    CopyFromInt(a,[K_Space,K_F5]); AddFromInt(a,aKeyListDown);
    if AssignObj(tf) then hnt:=tp.Caption else hnt:='';
	  SetKeys(a,CaptDefault(tf,btmKey),hnt,ProcKey,'btmskget',kmEdit); ReDrw;
    if SeekKeyMenu(tf,MainMn) then MainMn.InsLine(kmEdit,K_Space);
  end;
  DelStack;
end;

procedure TBtMskGet.DoExit;
var tl: TKeyLb;
	MainMn: TKeyMenu;
  ts: TSchem;
begin
	AddStack('TBtMskGet.DoExit',Self);
  if not(csDestroying in tf.ComponentState) then
    if SchemName(tf.Schem,ts) then tf.Font.Assign(ts.Font2);
  if FormKeyLb(tf,tl) then begin
    if SeekKeyMenu(tf,MainMn) then MainMn.DelLine(kmEdit,K_Space);
  	tl.DelKey(K_All,'btmskget'); tl.ReDrw;
  end;
	inherited DoExit(tf);
  DelStack;
end;

procedure TBtMskGet.tpClick;
var tp1: TPaintButton;
  tf: TFldEdit;
  lMouse: boolean;
begin
  AddStack('TBtMskGet.tpClick',Self);
  lMouse:=Assigned(Sender); tp1:=IfThen(lMouse,Sender,tp); tp1.Down:=true;
  if lMouse then AddKeyStack(K_All,tp1.Caption);
  try
    tf:=FldEditOwner(tp1); Eval(tf); tf.Change(tf.VarValue,false);
  finally
    if lMouse then DelKeyStack;
    tp1.Down:=false;
  end;
  DelStack;
end;

procedure TBtMskGet.Eval;
var Fml: string;
begin
  AddStack('TBtMskGet.Eval',Self);
  Fml:=TrimRight(MaskToFml(tf.Mask)); EvalStrings([null],Fml,BtMskCapt+' ('+tf.NameRecFld+')','',Pos(CRLF,Fml)=0);
  DelStack;
end;

procedure TBtMskGet.ProcKey;
begin
	AddStack('TBtMskGet.ProcKey',Self);
  if AssignObj(pointer(tw)) then tpClick(nil);
  DelStack;
end;

function TBtMskGet.AssignObj;
begin
	AddStack('TBtMskGet.AssignObj',Self);
	tp:=nil; result:=false;
  if inherited AssignObj(tf) then
		if tf.ComponentCount>0 then result:=IsClass(tf.Components[0],TPaintButton,pointer(tp));
  DelStack;
end;

function TBtMskGet.MaskSearch;
begin
	AddStack('TBtMskGet.MaskSearch',Self);
  result:=FindInStr(MaskToFml(Mask),SubStr);
  DelStack;
end;

function TBtMskGet.MaskReplace;
var cnt: longint;
  Prm: TButGetPrm;
begin
	AddStack('TBtMskGet.MaskReplace',Self);
  result := inherited MaskReplace(Mask,stSource,sRepl,lIdent,PrRepl,pav);
  if result>=0 then begin
  	Prm:=ButMask2Prm(Mask); Prm.Mask:=MaskToFml(Prm.Mask);
    cnt:=ReplaceInStr(Prm.Mask,stSource,sRepl,PrRepl,pav);
    if cnt<0 then result:=cnt
    else begin
      Prm.Mask:=FmlToMask(Prm.Mask); Mask:=ButPrm2Mask(Prm); Inc(result,cnt);
    end;
  end;
  DelStack;
end;

function TBtMskGet.MaskTrans;
var Prm: TButGetPrm;
begin
  AddStack('TBtMskGet.MaskTrans',Self);
  if MyVarType(av)=varArray
  then result:=ButPrm2Mask(IsNilc(av[1],''),FmlToMask(IsNilc(av[2],'')))
  else begin
    Prm:=ButMask2Prm(av);
    result:=ArrVarToVar(
      [VarArrayOf([mpCustom,'',Prm.Capt,LongInt(TButManyStrGet.CreateOne),',,,2,Заголовок',true])
      ,VarArrayOf([mpButForm,ButPrm2Mask(BtMskCapt),MaskToFml(Prm.Mask)])
      ]);
  end;
  DelStack;
end;

procedure TBtMskGet.MaskPrn;
var Prm: TButGetPrm;
begin
	AddStack('TBtMskGet.MaskPrn',Self);
  Prm:=ButMask2Prm(Mask);
  if not empty(Prm.Capt) then LsPrn.Add('Заголовок: '+Prm.Capt);
  LsPrnAdd('Формула',MaskToFml(Prm.Mask),LsPrn);
  DelStack;
end;

procedure TBtMskGet.StdDWFldInfo;
begin
	AddStack('TMultiGet.StdDWFldInfo',Self);
  FldInfo.FieldClass:=nil;
  DelStack;
end;

class function TBtMskGet.MaskTextReadOnly;
begin
	result:=true;
end;

class procedure TBtMskGet.FMaskView;
begin
  AddStack('TBtMskGet.FMaskView');
  Mask:=DelTrim(StrTran(MaskToFml(Mask),CRLF,' '));
  DelStack;
end;

procedure TBtMskGet.FMaskHelp;
var n: byte;
  s: string;
begin
  AddStack('TBtMskGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+3);
  s:=HelpBoldStr('«Заголовок»');
  Inc(n); CopyFrom(ht.Dat[n],HelpIfEmpty(s,'"'+cButCapt+'"+'+HelpArrayAsList(s,'"'+UnDelim+'"',false)+'+"'+cAtPartEnd+'"')+'+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpStrTran('«Формула»','ПЕРЕВОД_СТРОКИ','"'+btCrlf+'"'));
  DelStack;
end;

class function TBtMskGet.DDatSupport;
begin
  result:=true;
end;

class function TBtMskGet.DDatPaintPeriod;
begin
  result:=false;
end;

{ TButEvalGet }
constructor TButEvalGet.Create;
begin
	AddStack('TButEvalGet.Create',Self);
	inherited Create(AOwner);
  RVid:='Клавиша выполнения'; RVName:='с редактированием значения';
  DelStack;
end;

function ButEvalGetHelp: THelpFile;
begin
  AddStack('BtTxtGet.ButEvalGetHelp');
  result.sFile:=HelpFileStd; result.sPage:='PrmButEval';
  DelStack;
end;

function TButEvalGet.MaskSearch;
begin
	AddStack('TButEvalGet.MaskSearch',Self);
  result:=FindInStr(MaskToFml(MaskToPrm(Mask).Dop),SubStr);
  DelStack;
end;

function TButEvalGet.MaskReplace;
var cnt: longint;
  Prm: TButTextGetPrm;
begin
	AddStack('TButEvalGet.MaskReplace',Self);
  result := inherited MaskReplace(Mask,stSource,sRepl,lIdent,PrRepl,pav);
  if result>=0 then begin
    Prm:=MaskToPrm(Mask); Prm.Dop:=MaskToFml(Prm.Dop);
    cnt:=ReplaceInStr(Prm.Dop,stSource,sRepl,PrRepl,pav);
    if cnt<0 then result:=cnt
    else begin
      Prm.Dop:=FmlToMask(Prm.Dop); Mask:=PrmToMask(Prm); Inc(result,cnt);
    end;
  end;
  DelStack;
end;

function TButEvalGet.MaskTrans;
var av1: variant;
begin
	AddStack('TButEvalGet.MaskTrans',Self);
  if MyVarType(av)=varArray then begin
    av1:=av; av1[nButTxt]:=FmlToMask(av1[nButTxt]);
    result:=inherited MaskTrans(av1,r,nmf);
  end
  else begin
    result:=inherited MaskTrans(av,r,nmf);
    nButTxt:=VarArrayHighBound(result,1);
    result[nButTxt]:=VarArrayOf([mpButForm,ButPrm2Mask(BtMskCapt),MaskToFml(MaskToPrm(av).Dop),0,Longint(@ButEvalGetHelp)])
  end;
  DelStack;
end;

procedure TButEvalGet.FMaskHelp;
var n: byte;
  hf: THelpFile;
begin
  AddStack('TButEvalGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+2);
  IncD(ht.Dat[n,0],'+"'+UnDelim+'"+;');
  hf:=ButEvalGetHelp;
  Inc(n); CopyFrom(ht.Dat[n],HelpStrTran(HelpBoldStr('«Формула»',hf.sPage,hf.sFile),'ПЕРЕВОД_СТРОКИ','"'+btCrlf+'"',false));
  DelStack;
end;

procedure TButEvalGet.Click;
var v: variant;
begin
	AddStack('TButEvalGet.Click',Self);
  v:=EvalStrings([tf.Value],MaskToFml(MaskToPrm(tf.Mask).Dop),BtMskCapt+' ('+tf.NameRecFld+')');
  if not IsNil(v) then tf.VarValue:=v;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TButTextGet,TBtMskGet]);
end;

end.
