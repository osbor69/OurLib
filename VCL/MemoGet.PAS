unit MemoGet;

interface

{$I LIBTEST}
uses
  Windows,Messages,Classes,Controls,Forms,
  MyTypes,RecVal,FFldedit,PaintCtl,FEdText;

type
	TFldSimpleMemo = class(TCustomEdMemo)
  private
    FOnShowHint: TShowHintEvent;
    function VkEndFromText: boolean;
  protected
		procedure CorrText; virtual;
   	procedure BeforeKeyDown(var Key: Word; Shift: TShiftState); override;
   	procedure AfterKeyDown(var Key: Word; Shift: TShiftState); override;
   	procedure AfterKeyPress(var Key: Char); override;
   	procedure AfterKeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MnProcCut(Sender: TObject); override;
    procedure MnProcPaste(Sender: TObject); override;
    {procedure doSciModified(const position: LongInt; const modificationType: LongInt; text: PChar;
      const len,linesAdded,line,foldLevelNow,foldLevelPrev: LongInt); override;}
    procedure GetFromSchem; override;
    procedure HelpPart(const Head: string); override;
  	procedure WMApplHint(var Message: TWMApplHint); override;
  public
    TrimLeft: boolean;
    MinHeight: longint;
		constructor CreateParent(AOwner: TComponent; AParent: TWinControl); override;
    procedure SetText(const v: string); override;
    procedure SelAll;
    procedure PropFromFld(tf: TFldEdit; bDyn: TPaintButton);
    property OnShowHint: TShowHintEvent read FOnShowHint write FOnShowHint;
  end;

	TFldMemo = class(TFldSimpleMemo)
  private
    ls: TStringList;
    FCountLine,FCountChar: longint;
    lCorrText: boolean;
  protected
		procedure CorrText; override;
   	procedure BeforeKeyDown(var Key: Word; Shift: TShiftState); override;
		procedure BeforeKeyPress(var Key: Char); override;
    procedure BeforeExit; override;
  public
		constructor CreateParent(AOwner: TComponent; AParent: TWinControl); override;
    destructor Destroy; override;
    function MayDoKey(Key: longint): boolean;
    procedure TrimText;
    function NoLimSize: boolean;
  published
    Property CountChar: longint read FCountChar write FCountChar;
    Property CountLine: longint read FCountLine write FCountLine;
  end;

  TFldSimpleMemoClass = class of TFldSimpleMemo;

  TSimpleMemoGet = class(TCustomGet)
  private
    procedure ProcKey(key: longint; tw: TWinControl);
  protected
   	{ Protected declarations }
    tm: TFldSimpleMemo;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
		procedure Paint(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function FromCalc(tf: TFldEdit; d: Double; X,Y: longint): boolean; override;
    function AssignObj(tf: TFldEdit): boolean; override;
		function SelProcKey(tf: TFldEdit; Proc: TSelProcKey): boolean; override;
    class function tmClass: TFldSimpleMemoClass; virtual;
 	public
   	{ Public declarations }
		constructor Create(AOwner: TComponent); override;
  	class function DDatSupport: boolean; override;
  end;

  TMemoGet = class(TSimpleMemoGet)
  private
    procedure PrClick(Sender: TObject);
  protected
   	{ Protected declarations }
    sW: TPaintButton;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    procedure Write(tf: TFldEdit); override;
    function MayDoKey(tf: TFldEdit; Key: longint): boolean; override;
    function AssignObj(tf: TFldEdit): boolean; override;
		function DWFldUnAllowType(const Mask: string): TDWFldSetType; override;
  	class function MaskSortMode: TSortMode; override;
    class procedure FMaskView(var Mask: string); override;
    class function tmClass: TFldSimpleMemoClass; override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
		procedure GetPaintCtlActive(Sender: TObject; tf: TFldEdit; var result: boolean); override;
    function KeyDop: string; virtual;
    procedure ProcKey(key: longint; tw: TWinControl); virtual;
 	public
   	{ Public declarations }
		constructor Create(AOwner: TComponent); override;
		procedure StdDWFldInfo(const Mask: string; var FldInfo: TDWFldInfo); override;
		procedure StdDWFldValue(r: TCustomRec; const Mask: string; var Value: variant); override;
		procedure DWFldValid(const ap: TDEPrmStr; const dwInf: TDWVidRec;
    	var nFldFocus: TDEPrmList; var nVarFocus: TVarParam; var amsg: TArrStr); override;
    procedure MaskFrmShow(Sender: TObject); override;
    class procedure MaskEdChange(Sender: TObject; const OldVal: variant; FromShow: boolean); override;
		class function MaskTextReadOnly: boolean; override;
		class function LenFull(const h,w: string): longint;
 	published
   	{ Published declarations }
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

procedure Register;

implementation

uses
  SysUtils,Variants,StrUtils,Math,Graphics,StdCtrls,SciSupport,
  My_pr,Schem,KeyLb;

const dlmZpt = '^';

{ TFldSimpleMemo }
constructor TFldSimpleMemo.CreateParent;
var tf: TFldEdit;
begin
  AddStack('TFldSimpleMemo.CreateParent',Self);
  inherited CreateParent(AOwner,AParent);
  tf:=pointer(AParent); Color:=clWindow; Control.TabStop:=false; WantTabs:=false; BorderStyle:=bsNone;
  if IsSci then with Sci do begin
    SetVScrollBar(false); SetHScrollBar(false);
    onClick:=tf.EdClick;
    onDblClick:=tf.EdDblClick;
    onKeyDown:=tf.EdKeyDown;
    onKeyPress:=tf.EdKeyPress;
    onKeyUp:=tf.EdKeyUp;
    onMouseDown:=tf.EdMouseDown;
    onMouseMove:=tf.EdMouseMove;
    onMouseUp:=tf.EdMouseUp;
  end
  else with NoSci do begin
    ScrollBars:=ssNone;
    onClick:=tf.EdClick;
    onDblClick:=tf.EdDblClick;
    onKeyDown:=tf.EdKeyDown;
    onKeyPress:=tf.EdKeyPress;
    onKeyUp:=tf.EdKeyUp;
    onMouseDown:=tf.EdMouseDown;
    onMouseMove:=tf.EdMouseMove;
    onMouseUp:=tf.EdMouseUp;
  end;
  HideSelection(true);
  DelStack;
end;

procedure TFldSimpleMemo.CorrText;
var ss,sl: longint;
  ov,nv: string;
begin
  AddStack('TFldSimpleMemo.CorrText',Self);
  if TrimLeft then if Lines.Count>0 then if Length(Lines[0])>0 then if Lines[0][1]<=' ' then begin
    ov:=Text; nv:=SysUtils.TrimLeft(ov); ss:=SelStart; sl:=SelLength;
    Text:=nv; SetSelection(ss-Length(ov)+Length(nv),sl);
  end;
  DelStack;
end;

procedure TFldSimpleMemo.BeforeKeyDown;
begin
	AddStack('TFldSimpleMemo.BeforeKeyDown',Self);
  if not AutoCActive then if Shift=[] then case Key of
    // На конец строки или текста
    vk_End: if VkEndFromText then begin
      SetSelection(GetTextLength); Key:=0;
    end;
    // На начало текста
    vk_Home: if CurrentCol=0 then begin
      SetSelection(0); Key:=0;
    end;
  end;
  inherited BeforeKeyDown(Key,Shift);
	DelStack;
end;

procedure TFldSimpleMemo.AfterKeyDown;
begin
  AddStack('TFldSimpleMemo.AfterKeyDown',Self);
  inherited AfterKeyDown(Key,Shift);
  if not AutoCActive then CorrText;
  DelStack;
end;

procedure TFldSimpleMemo.AfterKeyPress;
begin
  AddStack('TFldSimpleMemo.AfterKeyPress',Self);
  inherited AfterKeyPress(Key);
  if not AutoCActive then CorrText;
  DelStack;
end;

procedure TFldSimpleMemo.AfterKeyUp;
begin
	AddStack('TFldSimpleMemo.AfterKeyUp',Self);
  inherited AfterKeyUp(Key,Shift);
  if not AutoCActive then CorrText;
  DelStack;
end;

procedure TFldSimpleMemo.MnProcCut;
begin
	AddStack('TFldSimpleMemo.MnProcCut',Self);
  inherited MnProcCut(Sender);
  CorrText;
  DelStack;
end;

procedure TFldSimpleMemo.MnProcPaste;
begin
	AddStack('TFldSimpleMemo.MnProcPaste',Self);
  inherited MnProcPaste(Sender);
  CorrText;
  DelStack;
end;

procedure TFldSimpleMemo.SetText;
begin
  AddStack('TFldSimpleMemo.SetText',Self);
  inherited SetText(TrimRight(v));
  CorrText;
  DelStack;
end;

procedure TFldSimpleMemo.HelpPart;
begin
  AddStack('TFldSimpleMemo.HelpPart',Self);
  inherited HelpPart(Head);
  if Head=EdMemoHelpPartCurs then begin
    if CurrentCol=0 then HelpKey(K_Home,IfThen(CurrentLineNumber>0,'На начало текста'),true);
    if VkEndFromText then HelpKey(K_End,IfThen(GetCurrentPos<GetTextLength,'На конец текста'),true);
  end;
  DelStack;
end;

function TFldSimpleMemo.VkEndFromText;
var i,cr: longint;
begin
  AddStack('TFldSimpleMemo.VkEndFromText',Self);
  if Lines.Count<CurrentLineNumber+1 then result:=false
  else begin
    i:=Length(Lines.Strings[CurrentLineNumber]); cr:=CurLineStartPos+i;
    if GetTextLength>cr then
      if Text[cr+1]<>#13 then Dec(i);
    result := CurrentCol=i;
  end;
  DelStack;
end;

{procedure TFldSimpleMemo.doSciModified;
begin
  AddStack('TFldSimpleMemo.doSciModified',Self);
  inherited doSciModified(position,modificationType,text,len,linesAdded,line,foldLevelNow,foldLevelPrev);
  if TrimLeft and (modificationType and SC_MOD_INSERTTEXT > 0) and (Lines.Count>0) then
    if Length(Lines[0])>0 then
      if Lines[0][1]<=' ' then Self.Text:=SysUtils.TrimLeft(Self.Text);
  DelStack;
end;}

procedure TFldSimpleMemo.GetFromSchem;
var tf: TFldEdit;
begin
  AddStack('TFldSimpleMemo.GetFromSchem',Self);
  tf:=pointer(Owner);
  if ogReadOnly in tf.Options then begin
    Color:=tf.Color1(CurSchem);
    if Assigned(CurSchem) then Font.Assign(CurSchem.Font1);
  end
  else inherited GetFromSchem;
  DelStack;
end;

procedure TFldSimpleMemo.SelAll;
begin
  AddStack('TFldSimpleMemo.SelAll',Self);
  if (ogAutoSelect in TFldEdit(Owner).Options) and not(csDestroying in ComponentState) then begin
    SelStart:=0; SelLength:=Length(Text);
  end;
  DelStack;
end;

procedure TFldSimpleMemo.PropFromFld;
begin
  AddStack('TFldSimpleMemo.PropFromFld',Self);
  Control.Visible:=tf.Visible;
  ReadOnly := (ogReadOnly in tf.Options) or Assigned(bDyn);
  TrimLeft := ogTrimLeft in tf.Options;
  if not(csDesigning in ComponentState) then Control.Perform(WM_SCHEM,byte(soBefore),LongInt(SchemName(tf.Schem)));
  DelStack;
end;

procedure TFldSimpleMemo.WMApplHint;
begin
  AddStack('TFldSimpleMemo.WMApplHint',Self);
  inherited;
	with Message.Info^ do IfThenShowHint(FOnShowHint,HintStr,CanShow,HintInfo);
  DelStack;
end;

{ TFldMemo }
constructor TFldMemo.CreateParent;
begin
  AddStack('TFldMemo.CreateParent',Self);
  inherited CreateParent(AOwner,AParent);
  ls:=TStringList.Create;
  DelStack;
end;

destructor TFldMemo.Destroy;
begin
  AddStack('TFldMemo.Destroy',Self);
  ls.Free;
  inherited Destroy;
  DelStack;
end;

procedure TFldMemo.BeforeKeyDown;
begin
	AddStack('TFldMemo.BeforeKeyDown',Self);
	if not AutoCActive then if Shift=[] then case Key of
    // Выход из нижней строчки
    vk_Return,vk_Down: begin
      // Не переносить строку, если курсор в начале
      if (Key=vk_Return) and (CurrentCol=0) then Key:=vk_Down;
      if (FCountLine>0) and (CurrentLineNumber+1>=FCountLine) or (SelLength=GetTextLength)
      then Key:=0;
    end;
    // Выход из верхней строчки
    vk_Up: if CurLineStartPos=0 then Key:=0;
  end;
	inherited BeforeKeyDown(Key,Shift);
	DelStack;
end;

procedure TFldMemo.BeforeKeyPress;
var l,p,r: longint;
  s: string;
begin
	AddStack('TFldMemo.BeforeKeyPress',Self);
  if not AutoCActive then begin
    if Ord(Key)=vk_Return then
      if GetParentForm(Control).ActiveControl<>Control
        then Key:=#0
      else if (CurrentCol=0) and (FCountLine>0) and (CurrentLineNumber<=FCountLine) then begin
        SetSelection(CurLineStartPos); Key:=#0;
      end;
    if (Key>=' ') and (FCountLine<>0) and (SelStart<>0) and (CurrentCol<>0) then
      if ((CurrentCol mod FCountChar)=0) and (CurrentLineNumber>=FCountLine-1)
      then Key:=#0;
    if (Key>=' ') and (SelLength=0) and (FCountChar>0) then begin
      l:=CurrentLineNumber;
      if l<Lines.Count then
        if Length(Lines[l])>=FCountChar then begin
          ls.Text:=Text;
          if CurrentCol<FCountChar then p:=SelStart
          else begin
            if l=ls.Count-1 then ls.Add('');
            p:=GetLineEndPosition(l)+lCRLF; Inc(l);
          end;
          r:=FCountChar-1;
          while l<ls.Count do begin
            if Length(ls[l])<=r then break;
            s:=System.Copy(ls[l],r+1,MaxInt);
            if l=ls.Count-1 then ls.Add(s) else IncL(ls,l+1,s);
            LeftSelf(ls,l,r); Inc(l); r:=FCountChar;
          end;
          Text:=ls.Text; SetSelection(p);
        end;
    end;
  end;
  inherited BeforeKeyPress(Key);
  DelStack;
end;

procedure TFldMemo.CorrText;
var s,ss,sl,i,i1,l: longint;
	s1: string;
  Upd: TEdMemoUpd;
begin
  AddStack('TFldMemo.CorrText',Self);
  inherited;
  if not lCorrText then if FCountLine>0 then begin
    ss:=SelStart; sl:=SelLength; i:=0; s:=0; Upd.lMod:=false;
    try
      lCorrText:=true;
      while i<min(FCountLine,Lines.Count) do begin
        l:=Length(Lines[i]); Inc(s,min(l,FCountChar)+lCRLF);
        if l>FCountChar then begin
          LinesBeginUpdate(Upd);
          i1:=i+1; s1:=System.Copy(Lines[i],FCountChar+1,MaxInt);
          if i=Lines.Count-1 then InsertText(PositionFromLine(i)+FCountChar,CRLF)
          else Lines[i1]:=s1+Lines[i1];
          Lines[i]:=LeftStr(Lines[i],FCountChar);
          if ss>=s-lCRLF then Inc(ss,lCRLF);
        end;
        Inc(i);
      end;
    finally
      if LinesEndUpdate(Upd) then begin
        SetSelection(0,0,false); SetSelection(ss,sl);
      end;
      lCorrText:=false;
    end;
  end;
  DelStack;
end;

procedure TFldMemo.TrimText;
var i: longint;
  Upd: TEdMemoUpd;
begin
  AddStack('TFldMemo.TrimText',Self);
  if FCountLine>0 then with Lines do begin
    Upd.lMod:=false;
    try
      if Count>FCountLine then begin
        LinesBeginUpdate(Upd);
        while Count>FCountLine do Delete(Count-1);
      end;
      for i:=0 to Count-1 do if Length(Lines[i])>FCountChar then begin
        LinesBeginUpdate(Upd);
        Lines[i]:=LeftStr(Lines[i],FCountChar);
      end;
    finally
      LinesEndUpdate(Upd);
    end;
  end;
  DelStack;
end;

function TFldMemo.NoLimSize;
begin
  AddStack('TFldMemo.NoLimSize',Self);
  result := FCountLine=0;
  DelStack;
end;

procedure TFldMemo.BeforeExit;
begin
	AddStack('TFldMemo.BeforeExit',Self);
  TrimText;
  inherited BeforeExit;
  DelStack;
end;

function TFldMemo.MayDoKey;
begin
  AddStack('TFldMemo.MayDoKey',Self);
  result:=not AutoCActive;
  if result then case Key of
    K_Up:
      if FCountLine=0 then begin
        if CurrentLineNumber>0 then result:=false;
      end
      else if (FCountLine>1) and (Pos(CRLF,LeftStr(Text,SelStart))>0)
        then result:=false;
    K_Down:
      if (LineFromPosition(SelStart)+1<min(ReplVar(FCountLine,MaxInt),Lines.Count))
      and (SelLength<>GetTextLength)
        then result:=false;
    K_Enter: if not((FCountLine=0) and (TFldEdit(Owner).CharHeight=0) and (MinHeight<2)) then
      if GetColumn(SelStart)=0 then begin
        if LineFromPosition(SelStart+SelLength)+1<min(FCountLine,Lines.Count)
          then result:=false;
      end
      else if (LineFromPosition(SelStart)+1<FCountLine) or (FCountLine=0)
        then result:=false;
  end;
  DelStack;
end;

{ TSimpleMemoGet }
constructor TSimpleMemoGet.Create;
begin
	AddStack('TSimpleMemoGet.Create',Self);
	Inherited Create(AOwner);
  {RVid:='Обычный (большая длина)';} UpdateAllFld(mgCreate);
  DelStack;
end;

procedure TSimpleMemoGet.CreateObj;
begin
	AddStack('TSimpleMemoGet.CreateObj',Self);
	DestroyObj(tf); tf.DynButCreate; tm:=tmClass.CreateParent(tf,tf);
  inherited CreateObj(tf);
  DelStack;
end;

class function TSimpleMemoGet.tmClass;
begin
  result:=TFldSimpleMemo;
end;

procedure TSimpleMemoGet.ReCreateObj;
begin
	AddStack('TSimpleMemoGet.ReCreateObj',Self);
	if AssignObj(tf) then tm.PropFromFld(tf,bDyn);
  inherited ReCreateObj(tf);
  DelStack;
end;

procedure TSimpleMemoGet.PaintObj;
var w,wc,h: longint;
begin
	AddStack('TSimpleMemoGet.PaintObj',Self);
	if AssignObj(tf) then begin
    w:=DynButSize.cX; h:=tf.Height-BevelFld2; wc:=tf.DynCaptSize(h).cX;
    if Assigned(bDyn) then bDyn.SetBounds(tf.Width-BevelFld-w,BevelFld,w,h);
    tm.SetBounds(BevelFld+2+wc,BevelFld+2,tf.Width-BevelFld2-w-4-wc,h-4);
  end;
  DelStack;
end;

procedure TSimpleMemoGet.Paint;
begin
  AddStack('TSimpleMemoGet.Paint',Self);
  if AssignObj(tf) then tf.FldMaskBorder(tm.Control);
  DelStack;
end;

function TSimpleMemoGet.SizeAuto;
var ts: TSchem;
  h: longint;
  dsz,dcsz: TSize;
begin
	AddStack('TSimpleMemoGet.SizeAuto',Self);
	result := inherited SizeAuto(tf,Opt);
  if not((csDestroying in ComponentState) or (csDestroying in tf.ComponentState)) then
    if AssignObj(tf) then with tf.Canvas do begin
      if not(csDesigning in ComponentState) then
        if SchemName(tf.Schem,ts) then tm.Font.Assign(ts.Font1);
      Font.Assign(tm.Font);
      if Opt<>[] then begin
        dsz:=DynButSize; h:=max(CanvasMaxH(tf.Canvas)+4,dsz.cY); dcsz:=tf.DynCaptSize(h);
        if tfszHeight in Opt then result.cY:=max(h,dcsz.cY);
        if tfszWidth in Opt then result.cX:=CanvasMaxW(tf.Canvas)*tf.LenFld(0)+6+dsz.cX+dcsz.cX;
      end;
    end;
  DelStack;
end;

function TSimpleMemoGet.GetValue;
begin
	AddStack('TSimpleMemoGet.GetValue',Self);
	AssignObj(tf); result:=tm.GetText;
  DelStack;
end;

procedure TSimpleMemoGet.SetValue;
begin
	AddStack('TSimpleMemoGet.SetValue',Self);
	if AssignObj(tf) then begin
    tm.SetText(v); tm.SelAll;
  end;
  DelStack;
end;

procedure TSimpleMemoGet.DoEnter;
var tl: TKeyLb;
begin
	AddStack('TSimpleMemoGet.DoEnter',Self);
  inherited DoEnter(tf);
	if AssignObj(tf) then begin
    GetParentForm(tf).ActiveControl:=tm.Control; tm.HideSelection(false); tm.SelAll;
    if FormKeyLb(tf,tl) then begin
      tl.SetKeyFind(ProcKey,'simplememoget',kmEdit); tl.ReDrw;
    end
  end;
  DelStack;
end;

procedure TSimpleMemoGet.DoExit;
var tl: TKeyLb;
begin
	AddStack('TSimpleMemoGet.DoExit',Self);
  if FormKeyLb(tf,tl) then tl.DelKey(K_All,'simplememoget');
  inherited;
  if not(csDestroying in tf.ComponentState) then if AssignObj(tf) then tm.HideSelection(true);
  DelStack;
end;

procedure TSimpleMemoGet.ProcKey;
begin
  AddStack('TSimpleMemoGet.ProcKey',Self);
  tm.ExecFind(Key);
  DelStack;
end;

function TSimpleMemoGet.FromCalc;
var ss,sl: longint;
begin
	AddStack('TSimpleMemoGet.FromCalc',Self);
	result:=AssignObj(tf);
	if result then with tm do begin
	  ss:=SelStart; sl:=SelLength; InsTextPos(FloatToStr(d),X,Y); tf.Value:=Text; SetSelection(ss,sl);
  end;
  DelStack;
end;

function TSimpleMemoGet.AssignObj;
var n: byte;
begin
	AddStack('TSimpleMemoGet.AssignObj',Self);
	tm:=nil; result:=false;
  if inherited AssignObj(tf) then begin
    n:=IfThen(Assigned(bDyn),1);
		if tf.ComponentCount>n then result:=IsClass(tf.Components[n],tmClass,pointer(tm));
  end;
	DelStack;
end;

function TSimpleMemoGet.SelProcKey;
begin
  AddStack('TSimpleMemoGet.SelProcKey',Self);
  result:=inherited SelProcKey(tf,Proc);
  if AssignObj(tf) then result:=tm.SelProcKey(Proc);
  DelStack;
end;

class function TSimpleMemoGet.DDatSupport;
begin
  result:=true;
end;

{ TMemoGet }
constructor TMemoGet.Create;
begin
	AddStack('TMemoGet.Create',Self);
	Inherited Create(AOwner);
  RVid:='Текстовый';
  DelStack;
end;

{ Создать объекты }
class function TMemoGet.tmClass;
begin
  result:=TFldMemo;
end;

procedure TMemoGet.CreateObj;
begin
	AddStack('TMemoGet.CreateObj',Self);
  inherited CreateObj(tf);
  if inherited AssignObj(tf) then begin
    if not Assigned(bDyn) then begin
      sW:=TPaintButton.Create(tf);
      with sW do begin
        Canvas:=tf.Canvas; Hint:='Редактировать в отдельном окне'; ShowHint:=true; onClick:=PrClick;
      end;
      tf.ReCreateObj;
    end;
  end;
  DelStack;
end;

procedure TMemoGet.ReCreateObj;
var fl: boolean;
begin
	AddStack('TMemoGet.ReCreateObj',Self);
	if AssignObj(tf) then begin
    fl:=TFldMemo(tm).NoLimSize; tm.WordWrapBool:=fl;
    if fl then tm.OnMaxLength:=FldMaxLength(tf) else tm.OnMaxLength:=nil;
    if Assigned(sW) then begin
      sW.Visible:=fl;
      if fl then
        if sW.Caption='' then BMByName(sW.Glyph,bmEval) else sW.Glyph:=nil;
    end;
    inherited ReCreateObj(tf);
  end;
  DelStack;
end;

procedure TMemoGet.PaintObj;
var w: longint;
	ts: TSchem;
begin
  AddStack('TMemoGet.PaintObj',Self);
  if AssignObj(tf) then
    if sW.VisibleNoNil then
      if empty(sW.Caption) then begin
        w:=SysMetric.iScrollWidth;
        sW.SetBounds(tf.Width-BevelFld-w,BevelFld,w,tf.Height-BevelFld2);
        tm.SetBounds(BevelFld+2,BevelFld+2,sW.Left-BevelFld-2,sW.Height-4);
      end
      else begin
        if SchemName(tf.Schem,ts) then
          if tf.Active then tf.Font.Assign(ts.FontW) else tf.Font.Assign(ts.Font2);
        sW.SetBounds(BevelFld,BevelFld,tf.Width-BevelFld2,BevelFld+tf.CaptHeight(SchemName(tf.Schem)));
        with sW.Bounds do tm.SetBounds(BevelFld+2,Bottom,Right-Left-4,tf.Height-BevelFld-2-Bottom);
      end
    else inherited PaintObj(tf);
  DelStack;
end;

procedure TMemoGet.PrClick;
var pb: TPaintButton;
  tf: TFldEdit;
  s: string;
begin
  AddStack('TMemoGet.PrClick',Self);
	pb:=pointer(Sender); tf:=PointerOwner(pb);
  if AssignObj(tf) then begin
    if not tf.Active then DoEnter(tf);
    pb.Down:=true; s:=tm.Text; tm.SaveIdent;
    if EdTextExec(IfThen(ogReadOnly in tf.Options,'Просмотр','Редактирование'),s,KeyDop,ProcKey,
    IfThen(ogReadOnly in tf.Options,edtxtReadOnly)+[edtxtWordWrap],
    edtpText,0,0,'',0,nil,'',nil,nil,'',nil,nil,nil,FldMaxLength(tf)) then begin
      tf.VarValue:=s;
      if AssignObj(tf) then tm.ReadIdent;
    end;
    pb.Down:=false;
  end;
  DelStack;
end;

function TMemoGet.KeyDop;
begin
  result:='';
end;

function TMemoGet.SizeAuto;
var dsz,dcsz: TSize;
  h: longint;
  m: TFldMemo;
begin
	AddStack('TMemoGet.SizeAuto',Self);
	result := inherited SizeAuto(tf,Opt);
	if AssignObj(tf) then with tf do begin
    m:=pointer(tm);
    if Opt<>[] then begin
      Canvas.Font.Assign(m.Font);
      dsz:=DynButSize;
      h:=max(max(IfThen(m.NoLimSize,m.MinHeight,1),m.FCountLine)*CanvasMaxH(Canvas)+IfThen(m.FCountLine>1,6,4),dsz.cY);
      if sW.VisibleNoNil then if not empty(sW.Caption) then Inc(h,tf.CaptHeight(SchemName(tf.Schem)));
      dcsz:=tf.DynCaptSize(h);
      if tfszHeight in Opt then result.cY:=max(h,dcsz.cY);
      if tfszWidth in Opt then result.cX:=CanvasMaxW(Canvas)*ReplVar(m.FCountChar,10)+10+dsz.cX+dcsz.cX;
      Canvas.Font.Assign(Font);
    end;
  end;
  DelStack;
end;

procedure TMemoGet.DoEnter;
var tl: TKeyLb;
	ts: TSchem;
  a: TArrInt;
begin
	AddStack('TMemoGet.DoEnter',Self);
	inherited DoEnter(tf);
	if AssignObj(tf) then
    if SchemName(tf.Schem,ts) then tf.Font.Assign(ts.FontW);
  if AssignObj(tf) then if sW.VisibleNoNil then if FormKeyLb(tf,tl) then begin
    CopyFromInt(a,K_Ctrl_F4);
    if ogReadOnly in tf.Options then AddFromInt(a,K_Space);
    tl.SetKeys(a,'В окне','Редактировать в отдельном окне',ProcKey,'memoget',kmEdit);
    tl.SetKeysSt(KeyDop,ProcKey,'memoget');
    tl.ReDrw;
  end;
  DelStack;
end;

procedure TMemoGet.DoExit;
var tl: TKeyLb;
	ts: TSchem;
begin
	AddStack('TMemoGet.DoExit',Self);
	if AssignObj(tf) and not(csDestroying in tf.ComponentState) then
    if SchemName(tf.Schem,ts) then tf.Font.Assign(ts.Font2);
  if FormKeyLb(tf,tl) then tl.DelKey(K_All,'memoget');
	inherited DoExit(tf);
  DelStack;
end;

procedure TMemoGet.ProcKey;
begin
	AddStack('TMemoGet.ProcKey',Self);
	if AssignObjOwner(tw) then sW.Click;
  DelStack;
end;

procedure TMemoGet.Write;
begin
  AddStack('TMemoGet.Write',Self);
  if AssignObj(tf) then TFldMemo(tm).TrimText;
  DelStack;
end;

{ Можно ли выполнить клавишу }
function TMemoGet.MayDoKey;
begin
	AddStack('TMemoGet.MayDoKey',Self);
	result := inherited MayDoKey(tf,Key);
  if result then
	  if AssignObj(tf) then result:=TFldMemo(tm).MayDoKey(Key);
  DelStack;
end;

{ Поиск объектов }
function TMemoGet.AssignObj;
var a: array[1..5] of string;
  m: TFldMemo;
begin
	AddStack('TMemoGet.AssignObj',Self);
  sW:=nil;
	result:=inherited AssignObj(tf);
  if result then begin
    if not Assigned(bDyn) then
  		if tf.ComponentCount>1 then result:=IsClass(tf.Components[1],TPaintButton,pointer(sW));
    if result then begin
      LsArrFill(tf.Mask,a,','); m:=pointer(tm);
      m.FCountLine:=Int0(a[1]); m.FCountChar:=Int0(a[2]);
      {if m.FCountLine=0 then m.FCountLine:=1;
      if m.FCountChar=0 then m.FCountChar:=MaxByte;}
      tm.MinHeight:=max(1,Int0(a[4]));
      if Assigned(sW) then sW.Caption:=StrTran(a[5],dlmZpt,',');
    end;
  end;
	DelStack;
end;

procedure TMemoGet.DWFldValid;
var l: longint;
	a: array[1..2] of string;
begin
	AddStack('TMemoGet.DWFldValid',Self);
  inherited DWFldValid(ap,dwInf,nFldFocus,nVarFocus,amsg);
  if (Length(amsg)=0) and not IsDWFldMemo(dwInf.AType) then begin
  	LsArrFill(ap[deMask],a,','); l:=LenFull(a[1],a[2]);
    if l>dwInf.Len then begin
    	AddFrom(amsg,[BracketInt('Длина поля для указанного количества строк и символов',l),
      	BracketInt('превышает длину данного',dwInf.Len)+'.']);
      nFldFocus:=deNameRecFld;
    end;
  end;
  DelStack;
end;

function TMemoGet.DWFldUnAllowType;
begin
  result:=[low(aDWFld)..high(aDWFld)]-[dwtString,dwtMemo,dwtManyStr];
end;

function TMemoGet.MaskTrans;
var a: array[1..5] of string;
  function Spin1(n,l: byte; const s: string): variant;
  begin
  	AddStack('TMemoGet.MaskTrans.Spin1',Self);
    result:=VarArrayOf([mpSpin,s,max(l,longint(Int0(a[n]))),l,999]);
    DelStack;
  end;
var l,c: longint;
begin
	AddStack('TMemoGet.MaskTrans',Self);
  if MyVarType(av)=varArray then begin
    if IsNilc(av[1],false) then begin
      l:=0; c:=0;
    end
    else begin
      l:=IsNilc(av[2],1); c:=IsNilc(av[3],3);
    end;
    result:=ArrayAsList([IntToStr(l),IntToStr(c),IntToStr(IsNilc(av[4],0)),
      IntToStr(IsNilc(av[5],0)),StrTran(IsNilc(av[6],''),',',dlmZpt)],',')
  end
  else begin
  	LsArrFill(av,a,',');
    result:=ArrVarToVar(
      [VarArrayOf([mpBool,'Размеры не ограничены',Int0(a[1])=0])
      ,Spin1(1,1,'Количество строк')
      ,Spin1(2,1,'Количество символов в строке')
      ,Spin1(3,0,'Длина поля для вывода в таблицу')
      ,Spin1(4,1,'Минимальное количество строк')
      ,VarArrayOf([mpEdit,'Заголовок',StrTran(a[5],dlmZpt,','),wallNoSay])
      ]);
  end;
  DelStack;
end;

class function TMemoGet.MaskSortMode;
begin
	result:=smColumns;
end;

procedure TMemoGet.MaskFrmShow;
begin
	AddStack('TMemoGet.MaskFrmShow',Self);
  TFldEdit.SetReadOnly([EdMaskFld(2),EdMaskFld(3),EdMaskFld(5),EdMaskFld(6)],true,ogReadOnlyNoVsbl);
  DelStack;
end;

class procedure TMemoGet.MaskEdChange;
var lsz: boolean;
begin
  AddStack('TMemoGet.MaskEdChange');
  lsz:=GetEdMaskVal(1);
  TFldEdit.SetReadOnly([EdMaskFld(2),EdMaskFld(3)],lsz);
  TFldEdit.SetReadOnly([EdMaskFld(5),EdMaskFld(6)],not lsz);
  DelStack;
end;

class function TMemoGet.MaskTextReadOnly;
begin
	result:=true;
end;

class procedure TMemoGet.FMaskView;
var a: array[1..5] of string;
  l,c,lv: longint;
begin
  AddStack('TMemoGet.FMaskView');
  LsArrFill(Mask,a,','); l:=Int0(a[1]); c:=Int0(a[2]); lv:=Int0(a[3]); a[5]:=Trim(StrTran(a[5],dlmZpt,','));
  Mask:=DlmBetween([IfThen(l>0,StrNum('строк:',Int0(a[1]))),IfThen(c>0,StrNum('символов в строке:',Int0(a[2]))),
    IfThen(lv<>0,StrNum('длина в таблице:',lv)),
    IfThen(l=0,StrNum('мин.строк:',max(1,Int0(a[4])))),IfThen((l=0) and (a[5]<>''),'заголовок:'+a[5])],',');
  DelStack;
end;

procedure TMemoGet.FMaskHelp;
const Dlm = '+","+';
var n: byte;
begin
  AddStack('TMemoGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+8);
  Inc(n); CopyFrom(ht.Dat[n],HelpStruct(['Строк','Символов','Длина','Заголовок','МинСтр']));
  Inc(n); CopyFrom(ht.Dat[n],HelpNum('«Количество строк»')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpNum('«Количество символов в строке»')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpNum('«Длина поля для вывода в таблицу»')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpNum('«Минимальное количество строк»'));
  Inc(n); CopyFrom(ht.Dat[n],HelpStrTran('«Заголовок»','","','"'+dlmZpt+'"')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],'Если размеры не ограничены, '+HelpBoldStr('«Количество строк»')+' и '+HelpBoldStr('«Количество символов в строке»')+' равны '+HelpBoldStr('0')+'.');
  DelStack;
end;

function DWSize(const Mask: string): longint;
var a: array[1..3] of string;
begin
  AddStack('SpGet.DWSize');
  LsArrFill(Mask,a,','); result:=Int0(a[3]);
  if result=0 then result:=Int0(a[2]);
  DelStack;
end;

procedure TMemoGet.StdDWFldInfo;
begin
  AddStack('TMemoGet.StdDWFldInfo',Self);
  FldInfo.Size:=DWSize(Mask);
  DelStack;
end;

procedure TMemoGet.StdDWFldValue;
var l: longint;
begin
  AddStack('TMemoGet.StdDWFldValue',Self);
  Value:=DelTrim(StrTran(Value,CRLF,' ')); l:=DWSize(Mask);
  if l>0 then PadrSelf(Value,l);
  DelStack;
end;

class function TMemoGet.LenFull;
begin
  AddStack('TMemoGet.LenFull');
  result:=Int0(h)*(Int0(w)+lCRLF)-lCRLF;
  DelStack;
end;

procedure TMemoGet.GetPaintCtlActive;
begin
  AddStack('TMemoGet.GetPaintCtlActive',Self);
  if AssignObj(tf) then if Sender=sW then result:=true;
  DelStack;
end;

procedure Register;
begin
	RegisterComponents('OurGets',[TMemoGet]);
end;

end.
