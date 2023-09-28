unit FEdSchem;

interface

{$I LIBTEST}
uses
  Messages, SysUtils, Classes, Controls, Forms, Dialogs, ExtCtrls, StdCtrls, Menus, ComCtrls, ExtDlgs,
  MyTypes, Schem, FRMEMPTY, FFldedit, ButGet, Keylb, Fpanel, PnlEdit, MenuGet, RecVal, KeyMenu, RbPage,
    ChkGets, DefEdit, CCodeGet, ListF2;

type
  TEdSchem = class(TFormEmp)
    Rec: TRecVal;
    KeyMenu1: TKeyMenu;
    pnPg: TRbPanel;
    pnSamp: TRbPanel;
    RbPage1: TRbPage;
    tsSch: TTabSheet;
    pnSch: TRbPanel;
    PnList: TRbPanel;
    PnList1: TRbPanel;
    PnEdit: TRbPanel;
    PnEdit1: TPanelEdit;
    PnColor: TRbPanel;
    EColW: TFldEdit;
    ECol1: TFldEdit;
    ECol2: TFldEdit;
    PnFont: TRbPanel;
    EFontW: TFldEdit;
    EFont1: TFldEdit;
    EFont2: TFldEdit;
    tsKey: TTabSheet;
    schSample: TSchem;
    pnSamp1: TRbPanel;
    pnKey: TPanelEdit;
    ButTypeGet: TMenuGet;
    EKeyNul: TEdit;
    FontGet: TButGet;
    PrmGet: TButGet;
    AlignmentGet: TRadioGet;
    dlgIcon: TOpenPictureDialog;
    deDir: TDefEdit;
    EType: TFldEdit;
    EWidth: TFldEdit;
    EInverted: TFldEdit;
    pnHotKey: TRbPanel;
    EHotKeyFont: TFldEdit;
    EHotKeyColor: TFldEdit;
    EUnderBut: TFldEdit;
    EAlignment: TFldEdit;
    pnAF: TRbPanel;
    EAFFont: TFldEdit;
    EAFColor: TFldEdit;
    pnAP: TRbPanel;
    EAPFont: TFldEdit;
    EAPColor: TFldEdit;
    EPrm: TFldEdit;
    tsDop: TTabSheet;
    pnDop: TPanelEdit;
    EChrCheck: TFldEdit;
    EDopNul: TEdit;
    procedure PnList1Resize(Sender: TObject);
    function PnEdit1Valid(Sender: TObject): Boolean;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PnColorSetWHMin(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PnEdit1Enter(Sender: TObject);
    procedure PnEdit1Exit(Sender: TObject);
    procedure PnEdit1Escape(Sender: TObject; var Action: TCloseAction);
    procedure pnSampResize(Sender: TObject);
    procedure ENulEnter(Sender: TObject);
    procedure ETypeChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    function pnKeyValid(Sender: TObject): Boolean;
    function FontGetClick(Sender: TObject; lEval: Boolean): String;
    procedure EFontChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure EColorChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure EWidthChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure EInvertedChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure pnKeyEnter(Sender: TObject);
    procedure pnKeyExit(Sender: TObject);
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    procedure EPrmChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure pnKeyEscape(Sender: TObject; var Action: TCloseAction);
    function PrmGetClick(Sender: TObject; lEval: Boolean): String;
    procedure EUnderButChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure EAlignmentChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    function deDirPnlValid(Sender: TObject): Boolean;
    function pnDopValid(Sender: TObject): Boolean;
    procedure pnDopEnter(Sender: TObject);
    procedure deDirPnlCngKey(Sender: TObject; var tb: TKeyBut);
  private
    { Private declarations }
    ListSchem: TFindListBox;
    oldInd: longint;
    curSchem,oSchem: TSchem;
    ls: TStringList;
    Modified,PrmModified,flKey: boolean;
    PrAfterRebuild: TNotifyEvent;
    rButton: TButtonRec;
    oPrm: TButtonTypeStr;
    oActList: boolean;
    procedure ListSchemClick(Sender: TObject);
    procedure ListSchemDblClick(Sender: TObject);
    procedure ListSchemEnter(Sender: TObject);
    procedure ListSchemExit(Sender: TObject);
    procedure ListSchemKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SetOneSchem(lcng: boolean);
		procedure ProcKey(key: longint; tw: TWinControl);
		function RecToSchem(sch: TSchem): boolean;
    procedure EChange(Sender: TObject; const OldVal: Variant; FromShow: Boolean);
		procedure AfterRebuild;
    class procedure KeyAfterRebuild(Sender: TObject);
		procedure ReadButton;
		procedure EKeyChange;
		procedure FIconLoad(const FileName: TFileName; lMod: boolean = true);
    procedure WMCalc(var Msg: TWMCalc); message WM_CALC;
    procedure WMRebuild(var Message: TWMRebuild); message WM_REBUILD;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
  end;

var EdSchem: TEdSchem;
  EdSchemProc: procedure(Oper: TEdSchemOper);

implementation

{$R *.DFM}

uses Graphics,Math,Variants,StrUtils,
  My_pr,ButForms,Askp,FSchemDM;

const
	aNm: array[TButtonAtrType] of string = ('AF','AP','NF','NP','HOTKEY');
  cFont = 'Font';
  cColor = 'Color';

procedure Proc(Oper: TEdSchemOper);
begin
  AddStack('FEdSchem.Proc');
  if Assigned(EdSchemProc) then EdSchemProc(Oper);
  DelStack;
end;

procedure TEdSchem.FormCreate(Sender: TObject);
	procedure tsCrt(const Capt: string; ATabOrderControl: TCustomRbPanel;
  	lNewCol: boolean = true);
  begin
    AddStack('TEdSchem.FormCreate.tsCrt',Self);
	  TPaintSay.CreatePrm(SpaceCapt(Capt),pointer(ATabOrderControl.Parent),ATabOrderControl).Tag:=
    	IfThen(lNewCol,1);
    DelStack;
  end;
const aButtonNmType: TButtonTypeStr = ('Стандарт','Эллипс','Лента','Переключатель','Пуля','Закругления','Многоугольник','Клавиша');
var i: TButtonType;
begin
	AddStack('TEdSchem.FormCreate',Self);
  ListSchem:=TFindListBox.Create(Self);
  with ListSchem do begin
    Parent:=PnList1;
    OnClick:=ListSchemClick; OnDblClick:=ListSchemDblClick;
    OnEnter:=ListSchemEnter; OnExit:=ListSchemExit; OnKeyUp:=ListSchemKeyUp;
  end;
  ls:=SortStrListCreate; RbPage1.SetActivePage(tsSch); ActiveControl:=ListSchem; PnEdit1.MasterControl:=ListSchem;
  with ButTypeGet.Items do begin
  	BeginUpdate;
    for i:=low(i) to high(i) do Add(IntToStr(longint(i))+UnDelim+aButtonNmType[i]);
    EndUpdate;
  end;
  tsCrt('разместить',EAlignment); Proc(eschCreate);
  inherited;
  DelStack;
end;

procedure TEdSchem.FormDestroy(Sender: TObject);
begin
	AddStack('TEdSchem.FormDestroy',Self);
  inherited;
	ls.Free;
  DelStack;
end;

procedure TEdSchem.PnList1Resize(Sender: TObject);
begin
	AddStack('TEdSchem.PnList1Resize',Self);
  inherited;
	ListSchem.Height:=PnList.Height-PnList.BevPanel2-10;
  DelStack;
end;

procedure TEdSchem.ReadButton;
var t: TButtonAtrType;
begin
  AddStack('TEdSchem.ReadButton',Self);
  with rButton do begin
    Rec['Type']:=longint(btnType); Rec['Width']:=Width; Rec['Inverted']:=Inverted;
    Rec['UnderBut']:=UnderBut; Rec['Alignment']:=byte(Alignment)+1;
    for t:=low(aNm) to high(aNm) do begin
    	Rec[aNm[t]+cFont]:=DefFontToStr(aFont[t]); Rec[aNm[t]+cColor]:=SeekColor(aColor[t]);
    end;
  end;
  DelStack;
end;

{ Перерисовка примеров }
procedure TEdSchem.SetOneSchem;
  // Установка возможности редактирования цвета
  procedure SetVsbColor(vsb: boolean; tf: TFldEdit; const Capt,Def,fn: string; c: TColor);
  begin
  	AddStack('TEdSchem.SetOneSchem.SetVsbColor',Self);
    tf.SayCaption:=SpaceCapt(IfThen(Capt='',Def,Capt));
    tf.SetReadOnly(not vsb); Rec[fn]:=SeekColor(c);
    DelStack;
  end;
  // Установка возможности редактирования шрифта
  procedure SetVsbFont(vsb: boolean; tf: TFldEdit; const Capt,Def: string; num: TSchFontList;
  	f: TFont);
  begin
  	AddStack('TEdSchem.SetOneSchem.SetVsbFont',Self);
    tf.SetReadOnly(not vsb);
    tf.Mask:=ButPrm2Mask(IfThen(Capt='',Def,Capt),Int2Str(num));
    SchemDM.aFont[num].Assign(f); Rec[tf.NameRecFld]:=FontToStr(f);
    DelStack;
  end;
var i: longint;
begin
	AddStack('TEdSchem.SetOneSchem',Self);
  i:=ListSchem.IndexFiltered;
	if not(isCalculator or (not lcng and (i=oldInd))) then begin
    oldInd:=i; CurSchem:=PointerObj(ls,oldInd);
    with CurSchem do begin
      SetVsbColor(schColorW in Options,EColW,NameColorW,'окно','ColorW',ColorW);
      SetVsbColor(schColor1 in Options,ECol1,NameColor1,'основной','Color1',Color1);
      SetVsbColor(schColor2 in Options,ECol2,NameColor2,'дополнительный','Color2',Color2);
      SetVsbFont(schFontW in Options,EFontW,NameFontW,'заголовок',dFontW,FontW);
      SetVsbFont(schFont1 in Options,EFont1,NameFont1,'основной',dFont1,Font1);
      SetVsbFont(schFont2 in Options,EFont2,NameFont2,'дополнительный',dFont2,Font2);
      if schNoEffect in CurSchem.Options
      then IncD(SchemDM.FontDialog1,[],[fdEffects])
      else IncD(SchemDM.FontDialog1,[fdEffects]);
    end;
    PnEdit1.FldReadAll([ferdSvOld]); EChange(nil,0,true); pnColor.Sort;
  end;
  DelStack;
end;

{ Перемещение по списку схем - перерисовка примеров }
procedure TEdSchem.ListSchemKeyUp;
begin
	AddStack('TEdSchem.ListSchemKeyUp',Self);
  inherited;
  SetOneSchem(false);
  DelStack;
end;

{ Щелчок - перерисовка примеров }
procedure TEdSchem.ListSchemClick;
begin
	AddStack('TEdSchem.ListSchemClick',Self);
  inherited;
  SetOneSchem(false);
  DelStack;
end;

procedure TEdSchem.ListSchemEnter;
begin
	AddStack('TEdSchem.ListSchemEnter',Self);
  with KeyLb1 do begin
		SetKeys([K_Enter,K_F5],'Редактировать','',ProcKey,'lssch',kmEdit); Redrw;
  end;
	DelStack;
end;

procedure TEdSchem.ListSchemExit;
begin
	AddStack('TEdSchem.ListSchemExit',Self);
  KeyLb1.DelKey(K_All,'lssch'); KeyLb1.Redrw;
  DelStack;
end;

procedure TEdSchem.ProcKey;
begin
	AddStack('TEdSchem.ProcKey',Self);
  PnEdit1.SetFocus;
  DelStack;
end;

function TEdSchem.PnEdit1Valid(Sender: TObject): Boolean;
begin
	AddStack('TEdSchem.PnEdit1Valid',Self);
  inherited;
  if not Modified then Modified:=PnEdit1.Modified;
  RecToSchem(CurSchem); result:=true;
  DelStack;
end;

function TEdSchem.RecToSchem;
var res: boolean;
	function SetColor(const nmc: string; cl: TColor): TColor;
  begin
    AddStack('TEdSchem.RecToSchem.SetColor',Self);
    result:=cl; cl:=AColor[T16Colors(Rec[nmc])];
    if cl<>result then begin
    	result:=cl; res:=true;
    end;
    DelStack;
  end;
  procedure SetFont(nf: TSchFontList; Font: TFont);
  begin
    AddStack('TEdSchem.RecToSchem.SetFont',Self);
    if FontToStr(SchemDM.aFont[nf])<>FontToStr(Font) then begin
	    Font.Assign(SchemDM.aFont[nf]); res:=true;
    end;
    DelStack;
  end;
begin
  AddStack('TEdSchem.RecToSchem',Self);
  res:=false;
  with sch do begin
  	ColorW:=SetColor('ColorW',ColorW);
    Color1:=SetColor('Color1',Color1);
    Color2:=SetColor('Color2',Color2);
    SetFont(dFontW,FontW); SetFont(dFont1,Font1); SetFont(dFont2,Font2);
  end;
  result:=res;
  DelStack;
end;

procedure TEdSchem.ListSchemDblClick;
begin
	AddStack('TEdSchem.ListSchemDblClick',Self);
  inherited;
  KeyLb1.ExecKey(K_Enter);
  DelStack;
end;

procedure TEdSchem.WMCalc;
begin
	AddStack('TEdSchem.WMCalc',Self);
	case Msg.Operation of
  	clcBegin: begin
      oActList := ActiveControl=ListSchem; PnList.Enabled:=false;
    end;
  	clcEnd: begin
      PnList.Enabled:=true;
      if oActList then ListSchem.SetFocus;
    end;
  end;
  DelStack;
end;

procedure TEdSchem.WMRebuild;
begin
	AddStack('TEdSchem.WMRebuild',Self);
  if Message.Oper=rbAfter then AfterRebuild;
  DelStack;
end;

procedure TEdSchem.PnColorSetWHMin(Sender: TObject);
var i,w: longint;
begin
	AddStack('TEdSchem.PnColorSetWHMin',Self);
	with TRbPanel(Sender) do begin
  	w:=0;
  	for i:=0 to ControlCount-1 do
    	if Controls[i] is TFldEdit then MaxSelf(w,Controls[i].Width);
    WMin:=w;
  end;
  DelStack;
end;

procedure TEdSchem.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	AddStack('TEdSchem.FormClose',Self);
  inherited;
  if Modified then AskFormSave(Self,Action);
  DelStack;
end;

procedure TEdSchem.EChange;
var CngSchem,CngProp: boolean;
	s: string;
  i: longint;
begin
	AddStack('TEdSchem.EChange',Self);
  CngSchem := oSchem<>CurSchem; CngProp:=RecToSchem(schSample);
  if CngSchem or CngProp then begin
  	if CngSchem then with pnSamp1 do begin
    	oSchem:=CurSchem; ControlsFree(pnSamp1); Invalidate;
      Place:=rpNone; PrAfterRebuild:=nil;
      Schem:=schSample.CaptSmall; SortObj:=true; SortMode:=smDefault;
      s:='Заголовок'; pnSamp1.OnAfterPaint:=nil; pnSamp1.OnSetWHMin:=nil;
      CurSchem.Sample(pnSamp1,s,PrAfterRebuild); Header:=s;
    end;
    FPanel.SetSchemForm(pnSamp1);
    with pnSamp1 do begin
    	SetWHMin(pnSamp,pnSamp.CltWidth);
      for i:=0 to ControlCount-1 do MsgRebuild(Controls[i]);
      Sort; AfterRebuild; pnSamp1.Invalidate;
    end;
  end;
  DelStack;
end;

procedure TEdSchem.AfterRebuild;
begin
  AddStack('TEdSchem.AfterRebuild',Self);
  IfThenNotify(PrAfterRebuild,pnSamp1);
  DelStack;
end;

procedure TEdSchem.PnEdit1Enter(Sender: TObject);
var i: longint;
begin
	AddStack('TEdSchem.PnEdit1Enter',Self);
  with TPanelEdit(Sender) do for i:=0 to FieldCount-1 do Fields[i].OnChange:=EChange;
  RbPage1.SetTabVisible(tsKey,false);
  DelStack;
end;

procedure TEdSchem.PnEdit1Exit(Sender: TObject);
var i: longint;
begin
	AddStack('TEdSchem.PnEdit1Exit',Self);
  with TPanelEdit(Sender) do for i:=0 to FieldCount-1 do Fields[i].OnChange:=nil;
  RbPage1.SetTabVisible(tsKey,true);
  DelStack;
end;

procedure TEdSchem.PnEdit1Escape(Sender: TObject;
  var Action: TCloseAction);
begin
	AddStack('TEdSchem.PnEdit1Escape',Self);
  SetOneSchem(true);
  DelStack;
end;

procedure TEdSchem.pnSampResize(Sender: TObject);
const iX = 5; iY = 5;
var h: longint;
begin
	AddStack('TEdSchem.pnSampResize',Self);
  with TRbPanel(Sender) do begin
  	h:=HeaderHeight;
    pnSamp1.SetBounds(iX,h+iY,CltWidth-iX shl 1,CltHeight-h-iY shl 1);
  end;
  DelStack;
end;

procedure TEdSchem.ENulEnter(Sender: TObject);
begin
	AddStack('TEdSchem.ENulEnter',Self);
  RbPage1.SetActivePage(tsSch);
  DelStack;
end;

procedure TEdSchem.ETypeChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TEdSchem.ETypeChange',Self);
  rButton.btnType:=TButtonType(Rec['Type']); EPrm.SetReadOnly(aKeyPrmDef[rButton.btnType]='');
  EPrm.Read; EKeyChange;
  DelStack;
end;

procedure TEdSchem.EPrmChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TEdSchem.EPrmChange',Self);
  EKeyChange;
  DelStack;
end;

procedure TEdSchem.EFontChange(Sender: TObject;
  const OldVal: Variant; FromShow: Boolean);
var t: TButtonAtrType;
begin
	AddStack('TEdSchem.EFontChange',Self);
  t:=TButtonAtrType(Int0(TFldEdit(Sender).Mask));
  rButton.aFont[t]:=StrToDefFont(Rec[aNm[t]+cFont]); EKeyChange;
  DelStack;
end;

procedure TEdSchem.EColorChange(Sender: TObject;
  const OldVal: Variant; FromShow: Boolean);
var t: TButtonAtrType;
	s: string;
begin
	AddStack('TEdSchem.EColorChange',Self);
  s:=TFldEdit(Sender).NameRecFld;
  for t:=low(aNm) to high(aNm) do if AnsiStartsText(aNm[t],s) then begin
    rButton.aColor[t]:=AColor[T16Colors(Rec[aNm[t]+cColor])]; EKeyChange; break;
  end;
  DelStack;
end;

procedure TEdSchem.EWidthChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TEdSchem.EWidthChange',Self);
  rButton.Width:=Rec['Width']; EKeyChange;
  DelStack;
end;

procedure TEdSchem.EInvertedChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TEdSchem.EInvertedChange',Self);
  rButton.Inverted:=Rec['Inverted']; EKeyChange;
  DelStack;
end;

procedure TEdSchem.EUnderButChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TEdSchem.EUnderButChange',Self);
  rButton.UnderBut:=Rec['UnderBut']; EKeyChange;
  DelStack;
end;

procedure TEdSchem.EAlignmentChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TEdSchem.EAlignmentChange',Self);
  rButton.Alignment:=TAlignment(Rec['Alignment']-1); EKeyChange;
  DelStack;
end;

procedure TEdSchem.pnKeyEscape(Sender: TObject; var Action: TCloseAction);
var i: TButtonType;
begin
	AddStack('TEdSchem.pnKeyEscape',Self);
  for i:=low(oPrm) to high(oPrm) do rButton.aPrm[i]:=oPrm[i];
  DelStack;
end;

function TEdSchem.pnKeyValid(Sender: TObject): Boolean;
begin
	AddStack('TEdSchem.pnKeyValid',Self);
  result:=true;
  if pnKey.Modified or PrmModified then Modified:=true;
  DelStack;
end;

function TEdSchem.FontGetClick(Sender: TObject; lEval: Boolean): String;
var frm: TForm;
  tf: TFldEdit;
  t: TButtonAtrType;
begin
	AddStack('TEdSchem.FontGetClick',Self);
  tf:=pointer(Sender); t:=TButtonAtrType(Int0(tf.Mask));
  with SchemDM.FontDialog1 do begin
    DefFontToFont(rButton.aFont[t],Font);
    if lEval then begin
      frm:=BeforeShowOther;
      if Execute then	begin
      	FontToDefFont(Font,rButton.aFont[t]);
        tf.VarValue:=DefFontToStr(rButton.aFont[t]);
      end;
      AfterShowOther(frm);
    end;
    result:=FontInf(Font);
  end;
  DelStack;
end;

procedure TEdSchem.pnKeyEnter(Sender: TObject);
var i: TButtonType;
  pn: TRbPanel;
begin
	AddStack('TEdSchem.pnKeyEnter',Self);
  with pnSamp1 do begin
  	ControlsFree(pnSamp1); Place:=rpLeft; Header:='';
    pn:=TRbPanel.Create(Owner);
    with pn do begin
      Parent:=pnSamp1; BevelOuter:=bvNone; Place:=rpBottom; Schem:='';
      with TKeyLb.Create(Owner) do begin
        Parent:=pn; PButton:=@rButton; ButShowing:=true;
        SetKey(K_F2,'Список','',nil,'',kmNone);
        SetKey(K_F5,'Редактировать','',nil,'',kmNone); Press(K_F5,true);
      end;
      with TRbPanel.Create(Owner) do begin
        Parent:=pn; BevelOuter:=bvLowered;
      end;
      FPanel.SetSchemForm(pn);
    end;
  end;
  for i:=low(oPrm) to high(oPrm) do oPrm[i]:=rButton.aPrm[i];
  PrAfterRebuild:=KeyAfterRebuild; AfterRebuild; PrmModified:=false; flKey:=true;
  DelStack;
end;

procedure TEdSchem.pnKeyExit(Sender: TObject);
begin
	AddStack('TEdSchem.pnKeyExit',Self);
  flKey:=false; PrAfterRebuild:=nil; oSchem:=nil; EChange(nil,0,true);
  DelStack;
end;

class procedure TEdSchem.KeyAfterRebuild;
var h: longint;
	tl: TKeyLb;
begin
	AddStack('TEdSchem.KeyAfterRebuild');
  with TRbPanel(Sender) do begin
  	h:=BevPanel;
    with TWinControl(Controls[0]) do begin
      SetBounds(h,h,CltWidth,CltHeight); tl:=pointer(Controls[0]); tl.Redrw; h:=tl.Height;
      tl.SetBounds(0,Height-h,Width,h); Controls[1].SetBounds(0,0,Width,Height-h);
    end;
  end;
  DelStack;
end;

procedure TEdSchem.KeyLb1ProcKey(key: longint; tw: TWinControl);
var f: TForm;
	s: string;
begin
	AddStack('TEdSchem.KeyLb1ProcKey',Self);
  inherited;
  case Key of
    K_F4: with dlgIcon do begin
		  f:=BeforeShowOther; s:=FileName;
      if Execute then FIconLoad(FileName) else FileName:=s;
		  AfterShowOther(f);
    end;
    K_Ctrl_F3: deDir.Execute;
    K_Ctrl_F4: if Ask(['Установить иконку по умолчанию ?']) then FIconLoad('');
    K_Alt_Home: if RbPage1.ActivePage=tsSch then begin
      if Ask(['Установить цвета и шрифты по умолчанию',
      'для объектов типа "'+CurSchem.Caption+'" ?']) then begin
        CurSchem.RestDef; SetOneSchem(true);
      end;
    end
    else if RbPage1.ActivePage=tsKey then begin
      if Ask(['Установить параметры клавиш по умолчанию ?']) then begin
        rButton:=GlobButtonDef; ReadButton; pnKey.FldReadAll;
      end;
    end
    else if RbPage1.ActivePage=tsDop then begin
      if Ask(['Установить дополнительные параметры по умолчанию ?']) then begin
        Rec['ChrCheck']:=''; Proc(eschDef); pnDop.FldReadAll;
      end;
    end;
  end;
  DelStack;
end;

procedure TEdSchem.FIconLoad;
begin
  AddStack('TEdSchem.FIconLoad',Self);
  dlgIcon.FileName:=FileName; Modified:=lMod;
  if not IconLoad(Icon,FileName) then Icon.Assign(Application.Icon);
  DelStack;
end;

procedure TEdSchem.EKeyChange;
var i: longint;
begin
  AddStack('TEdSchem.EKeyChange',Self);
  if flKey then with pnSamp1 do begin
  	FPanel.SetSchemForm(pnSamp1); SetWHMin(pnSamp,pnSamp.CltWidth);
    for i:=0 to ControlCount-1 do MsgRebuild(Controls[i]);
    AfterRebuild;
  end;
  DelStack;
end;

function TEdSchem.PrmGetClick(Sender: TObject; lEval: Boolean): String;
var vSort: TSortMode;
	av: variant;
	EdExit: TNotifyEvent;
  EdChange: TFEChangeEvent;
  EdCheck,PnlValid: TProcValid;
  FrmShow: TNotifyEvent;
begin
	AddStack('TEdSchem.PrmGetClick',Self);
  if lEval then begin
    vSort:=smDefault; av:=null; EdExit:=nil; EdChange:=nil; EdCheck:=nil; PnlValid:=nil; FrmShow:=nil;
    ButtonPrmTrans(rButton,av,vSort,EdExit,EdChange,EdCheck,PnlValid,FrmShow);
    if not IsNil(av) then
      if EdMaskProp('Дополнительные параметры',StrNum('Button',rButton.btnType),vSort,av,true,EdExit,EdChange,EdCheck,PnlValid,FrmShow) then begin
        ButtonPrmTrans(rButton,av,vSort,EdExit,EdChange,EdCheck,PnlValid,FrmShow);
        with rButton do aPrm[btnType]:=av;
        EKeyChange; PrmModified:=true;
      end;
  end;
  DefaultFont(Canvas.Font); result:=astolin(Canvas,ButtonPrmStr(rButton),EPrm.Width-BevelFld2-6);
  DelStack;
end;

procedure TEdSchem.WMFormLimit;
begin
	AddStack('TEdSchem.WMFormLimit',Self);
  inherited;
  FreeLimit(EdSchem);
  DelStack;
end;

procedure TEdSchem.deDirPnlCngKey(Sender: TObject; var tb: TKeyBut);
begin
  AddStack('TEdSchem.deDirPnlCngKey',Self);
  with tb do case Key of
    K_F10: Caption:='';
    K_Enter: begin
      Caption:='Загрузить'; Part:=kmFile;
    end;
  end;
  DelStack;
end;

function TEdSchem.deDirPnlValid(Sender: TObject): Boolean;
var dir,fo,fn: string;
  AOwner: TComponent;
begin
  AddStack('TEdSchem.deDirPnlValid',Self);
  result:=false; dir:=TrimRight(Rec['DIR']);
  if dir<>'' then begin
    fo:=InitFIni[fiSchem].FileName; fn:=CorrDir(dir)+ExtractFileName(fo);
    if FileExists(fn) then begin
      AOwner:=InitFIni.Owner; InitFIni.Destroy; result:=CopyFileOpt(fn,fo);
      InitFIni:=TInitFIni.Create(AOwner);
      if result then begin
        SchemDM.RestSchems; SetSchemAppl; SetModalResult; Modified:=false;
      end
      else meserr('Ошибка копирования настроек !');
    end
    else meserr('В указанной папке отсутствуют настройки !');
  end;
  DelStack;
end;

function TEdSchem.pnDopValid(Sender: TObject): Boolean;
begin
  AddStack('TEdSchem.pnDopValid',Self);
  result:=true;
  if pnDop.Modified then Modified:=true;
  DelStack;
end;

procedure TEdSchem.pnDopEnter(Sender: TObject);
begin
  AddStack('TEdSchem.pnDopEnter',Self);
  ControlsFree(pnSamp1); pnSamp1.Header:='';
  DelStack;
end;

procedure WndKeyProc(Key: longint; tw: TWinControl; var lBreak: boolean);
var i,w,h: longint;
  s: string;
  fl: boolean;
  ts: TSchem;
begin
  AddStack('FEdSchem.WndKeyProc');
  if key=K_Ctrl_F2 then begin
    lBreak:=true;
    if Assigned(LsSchem) then if LsSchem.Count>0 then begin
      TKeyLb.FixKeyShow(Key,false); fl:=CreateForm(TEdSchem,EdSchem);
      with EdSchem do begin
        ls.Clear; w:=0; h:=0; ListSchem.Canvas.Font.Assign(ListSchem.Font);
        for i:=0 to LsSchem.Count-1 do begin
          ts:=PointerObj(LsSchem,i);
          if ts<>schSample then begin
            s:=Trim(ts.Caption);
            if (s<>'') then begin
              ls.AddObject(s,LsSchem.Objects[i]);
              MaxSelf(w,ListSchem.Canvas,s); Inc(h,CanvasMaxH(ListSchem.Canvas));
            end;
          end;
        end;
        ListSchem.Items.Assign(ls);
        with ListSchem do SetBounds(Left,Top,w+8,h+4);
        PnList1.WMin:=ListSchem.Width+10;
        PnList1.HMin:=ListSchem.Height+10;
        PnList1Resize(EdSchem);
        ListSchem.ItemIndex:=0; OldInd:=0;
        SetOneSchem(true); TSchemDM.SaveSchems;
        rButton:=GlobButtonRec; ReadButton;
        if fl then MainRebuild;
        FIconLoad(IconFileName,false); Rec['ChrCheck']:=ChrCheck;
        if ShowModal=mrOk then begin
          IconFileName:=dlgIcon.FileName; ChrCheck:=StrToChar(Rec['ChrCheck']); Proc(eschSave);
          GlobButtonRec:=rButton; TSchemDM.SaveSchems; SetSchemAppl;
        end
        else SchemDM.RestSchems;
        IncD(SchemDM.FontDialog1,[fdEffects]);
        TKeyLb.FixKeyShow(Key,true); NoLimit:=false; ListSchem.Filtered:=false;
      end;
    end;
  end;
  DelStack;
end;

initialization
  AddStack('FEdSchem.initialization');
  AddFrom(aWndKeyProc,WndKeyProc);
  DelStack;
end.
