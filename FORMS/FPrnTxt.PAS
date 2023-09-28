unit FPrnTxt;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, Menus,
  MyTypes, FRMEMPTY, Keylb, Fpanel, PnlEdit, FFldedit, ChkGets, RecVal, KeyMenu, DirGet, CCodeGet;

type
  TPrnTxt = class(TFormEmp)
    RbStatus1: TRbStatus;
    PnEd: TPanelEdit;
    PnSpot: TRbPanel;
    Pn1: TRbPanel;
    PnPrm: TRbPanel;
    PnCop: TRbPanel;
    EVPrn: TFldEdit;
    KeyMenu1: TKeyMenu;
    Rec: TRecVal;
    VPrnGet: TRadioGet;
    EFeed: TFldEdit;
    ECnt: TFldEdit;
    ESortCop: TFldEdit;
    EPTop: TFldEdit;
    EPBottom: TFldEdit;
    EPLeft: TFldEdit;
    EPRight: TFldEdit;
    EFont: TFldEdit;
    EFile: TFldEdit;
    DirGet1: TDirGet;
    SaveDialog1: TSaveDialog;
    procedure PnPrmSetWHMin(Sender: TObject);
    procedure PnCopSetWHMin(Sender: TObject);
    procedure PnEdEnter(Sender: TObject);
    procedure PnEdEscape(Sender: TObject; var Action: TCloseAction);
    procedure ECntChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    function PnEdValid(Sender: TObject): Boolean;
    procedure FormActivate(Sender: TObject);
    procedure EFileChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure PnEdCngKey(Sender: TObject; var tb: TKeyBut);
  private
    { Private declarations }
    FSel: string;
    LsStr: TstringList;
    procedure pSet(const r: TRect);
		procedure StatCapt;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
  end;

var PrnHeadEnabled: boolean;

implementation

{$R *.DFM}

uses SysUtils,Math,StrUtils,
  My_pr,FStat,Askp,FSchemDM;

const
	vpAll = 1;
	vpSel = 2;

var PrnTxt: TPrnTxt;

procedure TPrnTxt.FormCreate(Sender: TObject);
begin
	AddStack('TPrnTxt.FormCreate',Self);
  inherited;
  LsStr:=TStringList.Create; TCheckSpace.SetButEnabled(EFeed,3,false);
  DelStack;
end;

procedure TPrnTxt.FormDestroy(Sender: TObject);
begin
	AddStack('TPrnTxt.FormDestroy',Self);
	LsStr.Free;
  inherited;
  DelStack;
end;

procedure TPrnTxt.FormActivate(Sender: TObject);
begin
	{AddStack('TPrnTxt.FormActivate',Self);
  KeyLb1.ExecKey(K_Ctrl_End);
  DelStack;}
end;

procedure PrnTxtExec(const txt: string; const sel: string = ''; DefFont: TFont = nil);
const af: array[TFontStyle] of byte = (1,2,4,8);
var s: string;
	n: byte;
  st: TFontStyles;
  fs: TFontStyle;
begin
	AddStack('FPrnTxt.PrnTxtExec');
	if IsPrinters then
    if empty(txt) then meserr('Нет информации для печати.')
    else with PrnTxt do begin
      CreateForm(TPrnTxt,PrnTxt);
      // Печатать всё/выдел.фрагмент
      Rec.RestFromIni; Rec['VPrn']:=vpAll; LsStr.Text:=txt; FSel:=sel;
      EVPrn.SetReadOnly(sel='');
      // Шрифт
      s:=InitFIni[fiSave].ReadString('PRN','Font');
      if s='' then
        if Assigned(DefFont) then SchemDM.aFont[dFont1].Assign(DefFont)
        else DefaultFont(SchemDM.aFont[dFont1])
      else with SchemDM.aFont[dFont1] do begin
        Color:=AColor[Int0(LeftStr(s,2))];
        Size:=Int0(Copy(s,3,3));
        n:=Int0(Copy(s,6,2)); st:=[];
        for fs:=low(af) to high(af) do if (n and af[fs]) > 0 then Include(st,fs);
        Style:=st;
        CharSet:=Int0(Copy(s,8,3));
        Name:=Copy(s,11+lUnDelim,MaxInt);
      end;
      // Копии
      SchemDM.PrnPrm['Cnt']:=1;
      ESortCop.SetReadOnly(true);
      PnEd.FldReadAll([ferdSvOld]); StatCapt; ShowModal;
      // Шрифт
      with SchemDM.aFont[dFont1] do begin
        n:=0;
        for fs:=low(af) to high(af) do if fs in Style then Or_D(n,af[fs]);
        InitFIni[fiSave].WriteString('PRN','Font',NumStr(SeekColor(Color),2)
          +NumStr(Size,3)+NumStr(n,2)+NumStr(CharSet,3)
          +UnDelim+Name);
      end;
      Rec.SaveToIni; FormFree(PrnTxt);
    end;
  DelStack;
end;

procedure PrnTxtHeadExec(const aHead: array of string;
  const txt: string; const sel: string = ''; DefFont: TFont = nil);
begin
  AddStack('FPrnTxt.PrnTxtHeadExec');
  AddPrnHead(aHead); PrnTxtExec(txt,sel,DefFont); DelPrnHead(Length(aHead));
  DelStack;
end;

procedure TPrnTxt.StatCapt;
begin
	AddStack('TPrnTxt.StatCapt',Self);
  RbStatus1.Caption:=' Принтер: '+GGPrinter.Printers[GGPrinter.PrinterIndex];
  DelStack;
end;

procedure TPrnTxt.PnPrmSetWHMin(Sender: TObject);
begin
	AddStack('TPrnTxt.PnPrmSetWHMin',Self);
  inherited;
  TRbPanel(Sender).WMin:=EFont.Width+10;
  DelStack;
end;

procedure TPrnTxt.PnCopSetWHMin(Sender: TObject);
begin
	AddStack('TPrnTxt.PnCopSetWHMin',Self);
  inherited;
  TRbPanel(Sender).WMin:=ESortCop.Width+10;
  DelStack;
end;

procedure TPrnTxt.PnEdEnter(Sender: TObject);
begin
	AddStack('TPrnTxt.PnEdEnter',Self);
  inherited;
  SchemDM.aFont[dFont2].Assign(SchemDM.aFont[dFont1]);
  DelStack;
end;

procedure TPrnTxt.PnEdEscape(Sender: TObject; var Action: TCloseAction);
begin
	AddStack('TPrnTxt.PnEdEscape',Self);
  inherited;
  SchemDM.aFont[dFont1].Assign(SchemDM.aFont[dFont2]);
  DelStack;
end;

procedure TPrnTxt.EFileChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
var fl: boolean;
	i: byte;
  tf: TFldEdit;
begin
	AddStack('TPrnTxt.EFileChange',Self);
  fl:=not empty(Rec['File']); TFldEdit.SetReadOnly([EFont,EFeed,ECnt],fl); ECntChange(Sender,OldVal,FromShow);
  with PnSpot do for i:=0 to ControlCount-1 do
  	if IsClass(Controls[i],TFldEdit,pointer(tf)) then tf.SetReadOnly(fl);
  DelStack;
end;

procedure TPrnTxt.ECntChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
begin
	AddStack('TPrnTxt.ECntChange',Self);
  inherited;
  ESortCop.SetReadOnly(not empty(Rec['File']) or (SchemDM.PrnPrm['Cnt']<=1));
  DelStack;
end;

procedure TPrnTxt.KeyLb1ProcKey(key: longint; tw: TWinControl);
begin
	AddStack('TPrnTxt.KeyLb1ProcKey',Self);
  inherited;
	case Key of
    K_F3: begin
      PrnSetupExec; StatCapt;
    end;
    K_Ctrl_F3: if Ask(['Установить отступы, соответствующие',
      'минимальным отступам для принтера ?'],true) then pSet(CalcSpotPrn);
  end;
  DelStack;
end;

// Печать
procedure PrintTxt(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var nl,nc,nn,cnt: longint;
  procedure SayCapt;
  begin
  	AddStack('FPrnTxt.PrintTxt.SayCapt');
  	if (nl>1) or (nc>1) then PrnNewPage(PrnTxt.Caption+Format(' (лист %d)',[nl]));
    if Sender.SayStat(IfThen(SchemDM.PrnPrm['Cnt']<>1,
    Format('Печать (копия %d)',[nc])),StrNum('Лист ',nl),nn/cnt)
      then raise EPrnError.Create('');
    Inc(nn);
    DelStack;
  end;
  function TxtHeight(const s: string): longint;
  begin
  	AddStack('FPrnTxt.PrintTxt.TxtHeight');
  	result:=GGPrinter.Canvas.TextHeight(IfThen(empty(s),cMaxH,s));
    DelStack;
  end;
var l,t,w,h,i,i1,i2,p,tb,hb,n1,n2,onc,ost: longint;
	ls: TIntegerList;
	s: string;
  lAbort: boolean;
begin
	ost:=AddStack('FPrnTxt.PrintTxt');
  with PrnTxt do begin
    h:=GetDeviceCaps(GGPrinter.Handle,LOGPIXELSY); t:=Ceil(h*Rec['PTop']/MmInInch);
    h:=GetDeviceCaps(GGPrinter.Handle,PHYSICALHEIGHT)-t-Ceil(h*Rec['PBottom']/MmInInch);
    Dec(t,GetDeviceCaps(GGPrinter.Handle,PHYSICALOFFSETY));
    w:=GetDeviceCaps(GGPrinter.Handle,LOGPIXELSX); l:=Ceil(w*Rec['PLeft']/MmInInch);
    w:=GetDeviceCaps(GGPrinter.Handle,PHYSICALWIDTH)-l-Ceil(w*Rec['PRight']/MmInInch);
    Dec(l,GetDeviceCaps(GGPrinter.Handle,PHYSICALOFFSETX));
    GGPrinter.Canvas.Font.Assign(SchemDM.aFont[dFont1]);
    GGPrinter.Canvas.Brush.Color:=clWhite;
    i:=0; tb:=t; cnt:=1; ls:=TIntegerList.Create;
    try
      ls.Capacity:=1+LsStr.Count; ls.Add(0);
      while i<LsStr.Count do begin
        s:=LsStr[i]; p:=Length(s);
        while (p>0) and (GGPrinter.Canvas.TextWidth(LeftStr(s,p))>w) do Dec(p);
        if p=0 then LsStr[i]:=''
        else if p<Length(s) then begin
          LsStr[i]:=LeftStr(s,p); LsStr.Insert(i+1,Copy(s,p+1,MaxInt));
        end;
        hb:=TxtHeight(LsStr[i]); Inc(tb,hb);
        if tb>h then begin
          tb:=t+hb; ls.Add(i);
        end;
        Inc(i);
      end;
      nn:=1; cnt:=ls.Count*SchemDM.PrnPrm['Cnt']; lAbort:=false;
      GGPrinter.Title:=Caption+IfThen(SchemDM.PrnPrm['Feed']<>FeedAuto,' (лист 1)');
      GGPrinter.BeginDoc;
      try
        nc:=1;
        for i1:=1 to IfThen(SchemDM.PrnPrm['SortCop'],SchemDM.PrnPrm['Cnt'],1) do begin
          nl:=1;
          for i:=0 to ls.Count-1 do begin
            n1:=ls[i];
            if i<ls.Count-1 then n2:=ls[i+1] else n2:=LsStr.Count;
            Dec(n2); onc:=nc;
            if not SchemDM.PrnPrm['SortCop'] then nc:=1;
            for i2:=1 to IfThen(SchemDM.PrnPrm['SortCop'],1,SchemDM.PrnPrm['Cnt']) do begin
              SayCapt; tb:=t;
              for p:=n1 to n2 do begin
                GGPrinter.Canvas.TextOut(l,tb,LsStr[p]);
                Inc(tb,TxtHeight(LsStr[p]));
              end;
              Inc(nc);
            end;
            nc:=onc;
            Inc(nl);
          end;
          Inc(nc);
        end;
      except
        on EPrnError do begin
          SetStack(ost);
          if GGPrinter.Printing then GGPrinter.Abort;
          lAbort:=true;
        end;
      end;
      if not lAbort then GGPrinter.EndDoc;
    finally
      ls.Free;
    end;
  end;
  DelStack;
end;

function TPrnTxt.PnEdValid(Sender: TObject): Boolean;
var r: TRect;
	s: string;
  i,l: longint;
  lPrn: boolean;
begin
	AddStack('TPrnTxt.PnEdValid',Self);
  result:=true; lPrn:=empty(Rec['File']);
  if lPrn then begin
    r:=CalcSpotPrn;
    if (r.Top>Rec['PTop']) or (r.Bottom>Rec['PBottom'])
    or (r.Left>Rec['PLeft']) or (r.Right>Rec['PRight']) then
      case AskCancel(['Внимание !',
      'Указанные отступы не соответствуют',
      'минимальным отступам для принтера.',
      'Использовать отступы принтера ?']) of
        mrCancel: result:=false;
        mrYes: pSet(r);
      end;
  end;
  if result then begin
    if Rec['VPrn']=vpSel then LsStr.Text:=FSel;
    if LsStr.Count>0 then begin
      StrTranSelf(LsStr,TAB,Space(I_TAB));
      if PrnHeadEnabled and (nPrnHead>0) then begin
        l:=0;
        for i:=nPrnHead downto 1 do begin
          s:=TrimRight(aPrnHead[i]); LsStr.Insert(0,s); MaxSelf(l,s);
        end;
        LsStr.Insert(nPrnHead,StringOfChar('=',l));
      end;
    	if lPrn
      then ShowStat('Печать'+IfThen(SchemDM.PrnPrm['Cnt']<>1,' (копия 1)'),PrintTxt)
      else LsStr.SaveToFile(Rec['File']);
    end;
  end;
  DelStack;
end;

procedure TPrnTxt.pSet;
begin
  AddStack('TPrnTxt.pSet',Self);
  EPTop.VarValue:=r.Top; EPBottom.VarValue:=r.Bottom;
  EPLeft.VarValue:=r.Left; EPRight.VarValue:=r.Right;
  DelStack;
end;

procedure TPrnTxt.PnEdCngKey(Sender: TObject; var tb: TKeyBut);
begin
	AddStack('TPrnTxt.PnEdCngKey',Self);
  inherited;
  with tb do if Key=K_F10 then Caption:='Печать';
  DelStack;
end;

procedure TPrnTxt.WMFormLimit;
begin
	AddStack('TPrnTxt.WMFormLimit',Self);
  inherited;
  FreeLimit(PrnTxt);
  DelStack;
end;

initialization
  AddStack('FPrnTxt.initialization');
  MyTypes.PrnTxtExec:=PrnTxtExec; MyTypes.PrnTxtHeadExec:=PrnTxtHeadExec;
  DelStack;
end.
