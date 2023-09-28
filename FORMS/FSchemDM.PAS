unit FSchemDM;

interface

{$I LIBTEST}
{ $DEFINE PRNSCREEN}
uses
  Classes, Graphics, Controls, Dialogs, ComCtrls, Types,
  MyTypes, Schem, MemoGet, RecVal, FFldedit, MenuGet, SpGet, ChkGets, ButGet, BtTxtGet,
    MnDrwGet, DirGet, SpinGet, MultiGet, Dateget, CCodeGet, PswdGet,
  DefEdit, ModelGet;

type
  THVAlignmentGet = class(TMenuDrawGet)
  protected
    procedure MouseDown(tf: TFldEdit; Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
  	procedure DrawItem(Canvas: TCanvas;
    	const nRect: TRect; Index: longint; State: TOwnerDrawState;
      tf: TFldEdit; const Cod: string; isList: boolean); override;
    procedure DoSizePaint(tf: TFldEdit; isList: boolean; var Size: TSize); override;
  end;

	TSchemDM = class(TDataModule)
    SayStat: TSchem;
    Browl: TSchem;
    Edit: TSchem;
    Ask: TSchem;
    Status: TSchem;
    GenFr: TSchem;
    Calc: TSchem;
    ViewGF: TSchem;
    FeedGet: TRadioGet;
    SortCopGet: TBoolDrwGet;
    PrnSetup: TPrinterSetupDialog;
    PrnPrm: TRecVal;
    FontGet: TButGet;
    FontDialog1: TFontDialog;
    Tree: TSchem;
    DirGet1: TDirGet;
    Menu: TSchem;
    SpinGet1: TSpinGet;
    BoolGet1: TBoolGet;
    GFStrGet: TRadioGet;
    BoolMultiGetBound: TBoolMultiGet;
    MultiGet1: TMultiGet;
    EconGet: TRadioGet;
    EvenGet: TRadioGet;
    BookGet: TRadioGet;
    BtMskGet1: TBtMskGet;
    SpGet1: TSpGet;
    MemoGet1: TMemoGet;
    EdTxt: TSchem;
    DirGetNoCheck: TDirGet;
    BoolMultiGet1: TBoolMultiGet;
    TxtGet: TButFormGet;
    MenuGet1: TMenuGet;
    DateGet1: TDateGet;
    PswdGet1: TPswdGet;
    mgLastCng: TModelGet;
    mgArrv: TModelGet;
    mgDcm: TModelGet;
    mgFAQ: TModelGet;
    mgNote: TModelGet;
    mgDfrm: TModelGet;
    mgDwnd: TModelGet;
    RadioGet1: TRadioGet;
    procedure SchemDMCreate(Sender: TObject);
    function FontGetClick(Sender: TObject; lEval: Boolean): String;
    procedure FontGetPaint(Sender: TObject; const ARect: TRect; const Text: String);
    procedure SchemDMDestroy(Sender: TObject);
    procedure FontGetSize(Sender: TObject; const Text: String; var Size: tagSIZE);
    procedure EditSample(Sender: TObject; Parent: TWinControl;
      var Header: String; var AfterRebuild: TNotifyEvent);
    procedure BrowlSample(Sender: TObject; Parent: TWinControl;
      var Header: String; var AfterRebuild: TNotifyEvent);
    procedure ViewGFSample(Sender: TObject; Parent: TWinControl;
      var Header: String; var AfterRebuild: TNotifyEvent);
    procedure TreeSample(Sender: TObject; Parent: TWinControl;
      var Header: String; var AfterRebuild: TNotifyEvent);
    procedure MenuSample(Sender: TObject; Parent: TWinControl;
      var Header: String; var AfterRebuild: TNotifyEvent);
    procedure CalcSample(Sender: TObject; Parent: TWinControl;
      var Header: String; var AfterRebuild: TNotifyEvent);
    procedure AskSample(Sender: TObject; Parent: TWinControl;
      var Header: String; var AfterRebuild: TNotifyEvent);
    procedure SayStatSample(Sender: TObject; Parent: TWinControl;
      var Header: String; var AfterRebuild: TNotifyEvent);
    procedure StatusSample(Sender: TObject; Parent: TWinControl;
      var Header: String; var AfterRebuild: TNotifyEvent);
    procedure EdTxtSample(Sender: TObject; Parent: TWinControl;
      var Header: String; var AfterRebuild: TNotifyEvent);
    procedure StatusSetToAppl(Sender: TObject);
  private
    { Private declarations }
		schSamp: TSchem;
		function EdFont(tf: TFldEdit): TFont;
		class procedure SayStatAfterRebuild(Sender: TObject);
		procedure AskAfterRebuild(Sender: TObject);
		class procedure StatusAfterRebuild(Sender: TObject);
		procedure CalcAfterRebuild(Sender: TObject);
		class procedure ViewGFAfterRebuild(Sender: TObject);
    class procedure EdTxtPnResize(Sender: TObject);
{$IFDEF PRNSCREEN}
    class procedure PrnTextBeforeShow(Sender: TObject);
    class procedure PrnTextAfterShow(Sender: TObject);
{$ENDIF}
  public
    { Public declarations }
    aFont: TSchFont;
    AlgmGet: THVAlignmentGet;
    class procedure SaveSchems;
    procedure RestSchems;
    procedure RestSchem(ts: TSchem);
  end;

var
  SchemDM: TSchemDM;
  aColorGet: array[boolean] of TColorGet;

procedure PrnSetupExec;
procedure PrnBeginDoc;
procedure PrnEndDoc;
procedure PrnNewPage(const Title: string; lEndDoc: boolean = true);

implementation

{$R *.DFM}

uses Windows,SysUtils,StdCtrls,StrUtils,Math,Forms,
  My_pr,Askp,FPanel,StrBrowl,TreePrim,RbMenu,Calc,FStat,FEdText {$IFDEF PRNSCREEN},Er866{$ENDIF};

const SectKeyLb = 'KeyLb';
	aIdent: array[TButtonAtrType] of record
    Font,Color: string
  end =
    ((Font:'Font1'  ; Color:'Color1')
    ,(Font:'Font1P' ; Color:'Color2')
    ,(Font:'Font1N' ; Color:'ColorN')
    ,(Font:'Font1NP'; Color:'ColorNP')
    ,(Font:'Font2'  ; Color:'ColorW')
    );

// Установка параметров принтера
procedure PrnSetupExec;
var f: TForm;
begin
	AddStack('FSchemDM.PrnSetupExec');
  f:=BeforeShowOther; SchemDM.PrnSetup.Execute; AfterShowOther(f); PrnInit;
  DelStack;
end;

procedure PrnBeginDoc;
var f: TForm;
begin
	AddStack('FSchemDM.PrnBeginDoc');
  f:=BeforeShowOther; GGPrinter.BeginDoc; AfterShowOther(f);
  DelStack;
end;

procedure PrnEndDoc;
begin
	AddStack('FSchemDM.PrnEndDoc');
  if not GGPrinter.Aborted then GGPrinter.EndDoc;
  DelStack;
end;

procedure PrnNewPage;
begin
	AddStack('FSchemDM.PrnNewPage');
  if (SchemDM.PrnPrm['Feed']=FeedHand)
  or (SchemDM.PrnPrm['Feed']=FeedAuto) and SchemDM.PrnPrm['NoNewPage'] then begin
  	if lEndDoc then PrnEndDoc;
    if SchemDM.PrnPrm['Feed']=FeedHand then
      if not ask(['Для продолжения печати','вставьте лист бумаги в принтер.','Продолжить печать ?'],true)
      then raise EPrnError.Create('');
    GGPrinter.Title:=Title; PrnBeginDoc;
  end
  else if lEndDoc then GGPrinter.NewPage else PrnBeginDoc;
  DelStack;
end;

procedure SaveFont(const Section,s: string; Font: TFont);
begin
  AddStack('FSchemDM.SaveFont');
  with Font,InitFIni[fiSchem] do begin
    WriteString(Section,s+'.Color',ColorToString(Color));
    WriteString(Section,s+'.Name',Name);
    WriteInteger(Section,s+'.Size',Size);
    WriteInteger(Section,s+'.CharSet',CharSet);
    WriteBool(Section,s+'.Bold',fsBold in Style);
    WriteBool(Section,s+'.Italic',fsItalic in Style);
    WriteBool(Section,s+'.Underline',fsUnderline in Style);
    WriteBool(Section,s+'.StrikeOut',fsStrikeOut in Style);
  end;
  DelStack;
end;

procedure RestFont(const Section,s: string; Font,DefFont: TFont);
var new: TFontStyles;
begin
  AddStack('FSchemDM.RestFont');
  with Font,InitFIni[fiSchem] do begin
    Color:=StringToColor(ReadString(Section,s+'.Color',ColorToString(DefFont.Color)));
    Name:=ReadString(Section,s+'.Name',DefFont.Name);
    Size:=ReadInteger(Section,s+'.Size',DefFont.Size);
    CharSet:=ReadInteger(Section,s+'.CharSet',DefFont.CharSet);
    new:=[];
    if ReadBool(Section,s+'.Bold',fsBold in DefFont.Style) then Include(new,fsBold);
    if ReadBool(Section,s+'.Italic',fsItalic in DefFont.Style) then Include(new,fsItalic);
    if ReadBool(Section,s+'.Underline',fsUnderline in DefFont.Style) then Include(new,fsUnderline);
    if ReadBool(Section,s+'.StrikeOut',fsStrikeOut in DefFont.Style) then Include(new,fsStrikeOut);
    Style:=new;
  end;
  DelStack;
end;

procedure SaveSchem(ts: TSchem);
begin
	AddStack('FSchemDM.SaveSchem');
	with ts,InitFIni[fiSchem] do begin
		EraseSection(Section);
    if schColorW in Options then WriteString(Section,'ColorW',ColorToString(ColorW));
		if schColor1 in Options then WriteString(Section,'Color1',ColorToString(Color1));
		if schColor2 in Options then WriteString(Section,'Color2',ColorToString(Color2));
    if schFontW in Options then SaveFont(Section,'FontW',FontW);
    if schFont1 in Options then SaveFont(Section,'Font1',Font1);
    if schFont2 in Options then SaveFont(Section,'Font2',Font2);
  end;
  DelStack;
end;

{ THVAlignmentGet }
const
	algBord  = 2;
	algPoint = 2;
	algSpace = 3;
  algMax = algBord shl 1 + 3*algPoint + algSpace shl 1;

procedure THVAlignmentGet.MouseDown;
  function pAlgm(v: longint): TAlignment;
	var i,j: longint;
  begin
  	AddStack('THVAlignmentGet.MouseDown.pAlgm',Self);
    Dec(v,BevelFld); i:=algBord+2*algPoint+algSpace+algSpace shr 1; j:=2;
    while (j>=0) and (v<i) do begin
      Dec(j); Dec(i,algPoint+algSpace);
    end;
	  result:=PosToAlgm[j];
    DelStack;
  end;
var alg: THVAlignment;
begin
  AddStack('THVAlignmentGet.MouseDown',Self);
  inherited MouseDown(tf,Button,Shift,X,Y);
  if X<BevelFld+algMax then begin // Не на кнопках
    alg.HorzAlignment:=pAlgm(X); alg.VertAlignment:=pAlgm(Y); tf.VarValue:=AlgmToNum(alg);
  end;
  DelStack;
end;

procedure THVAlignmentGet.DrawItem;
var cl: TColor;
	ts: TSchem;
  i,j,nv,ng: Byte;
  tb,lb: longint;
  t: THVAlignment;
begin
  AddStack('THVAlignmentGet.DrawItem',Self);
  with Canvas do begin
    Font.Assign(tf.Font); cl:=clBlack;
    if odSelected in State then begin
      Brush.Color:=clHighLight; Font.Color:=clHighLightText;
    end
    else begin
      if SchemName(tf.Schem,ts) then cl:=ts.Font1.Color;
    	Brush.Color:=tf.Color1(ts);
    end;
  	FillRect(nRect);
    if not(ogReadOnly in tf.Options) then begin
    	if isList then TextRect(nRect,nRect.Left+2,nRect.Top,TrimRight(MenuName(Cod)))
      else begin
        t:=NumToAlgm(TGFAlgmList(Int0(Cod)));
        nv:=AlgmToPos[t.VertAlignment];
        ng:=AlgmToPos[t.HorzAlignment];
        tb:=nRect.Top+(nRect.Bottom-nRect.Top+1-algMax) div 2+algBord;
        Brush.Color:=cl;
        for i:=0 to 2 do begin
          lb:=nRect.Left+algBord;
          for j:=0 to 2 do begin
            if (i=nv) and (j=ng)
            then FillRect(Rect(lb-1,tb-1,lb+algPoint+1,tb+algPoint+1))
            else FillRect(Rect(lb,tb,lb+algPoint,tb+algPoint));
            Inc(lb,algPoint+algSpace);
          end;
          Inc(tb,algPoint+algSpace);
        end;
      end;
    end;
  end;
  DelStack;
end;

procedure THVAlignmentGet.DoSizePaint;
var ts: TSchem;
begin
  AddStack('THVAlignmentGet.DoSizePaint',Self);
  with tf.Canvas do begin
    if SchemName(tf.Schem,ts) then Font.Assign(ts.Font1) else DefaultFont(Font);
    if isList then Size.cX:=CanvasMaxW(tf.Canvas)*MaxSymb
    else begin
		  Size.cX:=algMax; MaxSelf(Size.cY,Size.cX);
    end;
  end;
  DelStack;
end;

{ TSchemDM }
procedure TSchemDM.SchemDMCreate(Sender: TObject);
const
  aColor: array[boolean] of record
    VName: string;
    nHigh: longint;
  end =
    ((VName:'Color'  ; nHigh:high(T16Colors))
    ,(VName:'Color16'; nHigh:15)
    );
  aFeed: array[TFeedList] of string = ('Авто','Ручная','Рулон');
  aGFStr: array[TGFStrList] of string = ('Все','Текущий','Номера');
  aGFEcon: array[TGFEconList] of record
    nm: string;
    bm: TBMList;
  end =
    ((nm:'нет'         ; bm:bmGF_NoEcon)
    ,(nm:'по вертикали'; bm:bmGF_EconVert)
    ,(nm:'полная'      ; bm:bmGF_EconFull)
    );
  aGFEven: array[TGFEvenList] of string = ('Все листы диапазона','Нечётные листы','Чётные листы');

var sch: TSchFontList;
  algm: TGFAlgmList;
  fl: boolean;
  v: TGFEconList;
begin
	AddStack('TSchemDM.SchemDMCreate',Self);
	TInitFIni.Init(Self); TInitBM.Init(Self);
  for fl:=false to true do with aColor[fl] do begin
    aColorGet[fl]:=TColorGet.CreateColors(Self,nHigh); aColorGet[fl].VName:=VName;
  end;
  for sch:=low(aFont) to high(aFont) do aFont[sch]:=TFont.Create;
  FeedGet.Items.Text:=ArrayAsList(aFeed,CRLF);
  GFStrGet.Items.Text:=ArrayAsList(aGFStr,CRLF);
  with EconGet.Items do begin
    BeginUpdate;
    for v:=low(aGFEcon) to high(aGFEcon) do with aGFEcon[v] do Add(nm+UnDelim+BMPref+aBMName[bm]);
    EndUpdate;
  end;
  EvenGet.Items.Text:=ArrayAsList(aGFEven,CRLF);
  AlgmGet:=THVAlignmentGet.Create(Self);
  with AlgmGet do begin
    VName:='Alignment'; Items.BeginUpdate;
    for algm:=low(aGFAlgm) to high(aGFAlgm) do Items.Add(Int2Str(algm)+UnDelim+aGFAlgm[algm]);
    Items.EndUpdate;
  end;
  BoolMultiGetBound.OnCheck:=TFldEdit.NoEmpValue;
  RestSchems; fl:=MessagesHidden; MessagesHidden:=true; SetSchemAppl; MessagesHidden:=fl;
  DelStack;
end;

procedure TSchemDM.SchemDMDestroy(Sender: TObject);
var sch: TSchFontList;
begin
	AddStack('TSchemDM.SchemDMDestroy',Self);
  for sch:=low(sch) to high(sch) do FreeAndNil(aFont[sch]);
  DelStack;
end;

// Редактирование шрифта
function TSchemDM.EdFont;
var i: longint;
begin
	AddStack('TSchemDM.EdFont',Self);
  i:=Int0(ButMask2Prm(tf.Mask).Mask);
  if InRange(i,byte(low(aFont)),byte(high(aFont))) then result:=aFont[TSchFontList(i)] else result:=nil;
  DelStack;
end;

function TSchemDM.FontGetClick(Sender: TObject; lEval: Boolean): String;
var f: TFont;
	frm: TForm;
  tf: TFldEdit;
begin
	AddStack('TSchemDM.FontGetClick',Self);
  tf:=pointer(Sender); f:=EdFont(tf);
  if Assigned(f) then begin
    if lEval then begin
      FontDialog1.Font.Assign(f); frm:=BeforeShowOther;
      if FontDialog1.Execute then	begin
      	f.Assign(FontDialog1.Font); tf.VarValue:=FontToStr(f);
      end;
      AfterShowOther(frm);
    end;
    result:=FontInf(f);
  end
  else result:='';
  DelStack;
end;

procedure TSchemDM.FontGetPaint(Sender: TObject; const ARect: TRect; const Text: String);
const
	LbExample = 'Образец: ';
	LbFont = 'Шрифт, Font';
var r: TRect;
  f: TFont;
  cl: TColor;
  tf: TFldEdit;
  sz: TSize;
begin
	AddStack('TSchemDM.FontGetPaint',Self);
  tf:=pointer(Sender);
  if not(ogReadOnly in tf.Options) then begin
    f:=EdFont(tf);
    if Assigned(f) then begin
			FontGet.DrawText(tf,Text+CRLF+LbExample);
      with tf.Canvas do begin
        r.Left:=ARect.Left+TextWidth(LbExample)+1;
        r.Top:=ARect.Top+(StrCount(Text)*CanvasMaxH(tf.Canvas)+1);
        Font.Assign(f); sz:=TextExtent(LbFont);
        r.Right:=min(ARect.Right-2,r.Left+sz.cx+6);
        r.Bottom:=min(ARect.Bottom-2,r.Top+sz.cy);
        Pen.Color:=clNavy; Pen.Width:=1;
        cl:=Brush.Color;
        if AColor[SeekColor(Font.Color)]=clWhite then Brush.Color:=InvColor(Font.Color);
        Rectangle(r.Left-1,r.Top-1,r.Right+1,r.Bottom+1);
        TextRect(r,r.Left+2,r.Top,LbFont); Brush.Color:=cl; Font.Assign(tf.Font);
      end;
    end;
  end;
  DelStack;
end;

procedure TSchemDM.FontGetSize(Sender: TObject; const Text: String; var Size: tagSIZE);
var a: TArrStr;
  l: longint;
begin
	AddStack('TSchemDM.FontGetSize',Self);
  l:=LsArrDynamic(Text,a,CRLF);
  if l>0 then with TFldEdit(Sender) do WinSize(Size,Canvas.TextWidth(a[0])+6,l*CanvasMaxH(Canvas)+30);
  DelStack;
end;

{ Сохранение схем в SCHEM.INI }
class procedure TSchemDM.SaveSchems;
var f: TFont;
	i: longint;
	j: TButtonAtrType;
  t: TButtonType;
begin
	AddStack('TSchemDM.SaveSchems');
  with InitFIni[fiSchem] do begin
    WriteString('Global','IconFileName',IconFileName);
    WriteString('Global','ChrCheck',ChrCheck);
    if Assigned(LsSchem) then
      for i:=0 to LsSchem.Count-1 do SaveSchem(PointerObj(LsSchem,i));
    f:=TFont.Create;
    try
      with GlobButtonRec do begin
        WriteInteger(SectKeyLb,'BtnType',longint(btnType));
        WriteInteger(SectKeyLb,'Width',Width);
        WriteBool(SectKeyLb,'Inverted',Inverted);
        WriteBool(SectKeyLb,'UnderBut',UnderBut);
        WriteInteger(SectKeyLb,'Alignment',longint(Alignment));
        for j:=low(j) to high(j) do with aIdent[j] do begin
          DefFontToFont(GlobButtonRec.aFont[j],f); SaveFont(SectKeyLb,Font,f);
          WriteString(SectKeyLb,Color,ColorToString(aColor[j]));
        end;
        for t:=low(aPrm) to high(aPrm) do WriteString(SectKeyLb,StrNum('Prm',t),aPrm[t]);
      end;
    finally
      f.Free;
    end;
  end;
  DelStack;
end;

{ Восстановление схем из SCHEM.INI }
procedure TSchemDM.RestSchems;
var f,df: TFont;
	procedure fRest(j: TButtonAtrType);
  begin
    AddStack('TSchemDM.RestSchems.fRest',Self);
    RestFont(SectKeyLb,aIdent[j].Font,f,df); FontToDefFont(f,GlobButtonRec.aFont[j]);
    DelStack;
	end;
var i: longint;
	j: TButtonAtrType;
  t: TButtonType;
begin
	AddStack('TSchemDM.RestSchems',Self);
  with InitFIni[fiSchem] do begin
    IconFileName:=ReadString('Global','IconFileName');
    ChrCheck:=StrToChar(ReadString('Global','ChrCheck'));
    if Assigned(LsSchem) then
      for i:=0 to LsSchem.Count-1 do RestSchem(PointerObj(LsSchem,i));
    f:=TFont.Create; df:=TFont.Create;
    try
      with GlobButtonRec do begin
        btnType:=TButtonType(ReadInteger(SectKeyLb,'BtnType',longint(btnStandart)));
        Width:=ReadInteger(SectKeyLb,'Width',2);
        Inverted:=ReadBool(SectKeyLb,'Inverted');
        UnderBut:=ReadBool(SectKeyLb,'UnderBut');
        Alignment:=TAlignment(ReadInteger(SectKeyLb,'Alignment',longint(taLeftJustify)));
        DefaultFont(df); FontStyle(df); fRest(btfWinActFreeAction);
        df.Assign(f); fRest(btfWinActPressAction);
        FontStyle(df,false); fRest(btfWinNotActFreeAction);
        df.Assign(f); fRest(btfWinNotActPressAction);
        FontStyle(df); df.Size:=8; df.Color:=clNavy;
        fRest(btfHotKey);
        for j:=low(aIdent) to high(aIdent) do
          aColor[j]:=StringToColor(ReadString(SectKeyLb,aIdent[j].Color,ColorToString(clBtnFace)));
        for t:=low(aPrm) to high(aPrm) do aPrm[t]:=ReadString(SectKeyLb,StrNum('Prm',t),aKeyPrmDef[t]);
      end;
    finally
      f.Free; df.Free;
    end;
  end;
  DelStack;
end;

procedure TSchemDM.RestSchem;
begin
	AddStack('TSchemDM.RestSchem',Self);
	with ts,InitFIni[fiSchem] do begin
		ColorW:=StringToColor(ReadString(Section,'ColorW',ColorToString(DefColorW)));
		Color1:=StringToColor(ReadString(Section,'Color1',ColorToString(DefColor1)));
		Color2:=StringToColor(ReadString(Section,'Color2',ColorToString(DefColor2)));
   	RestFont(Section,'FontW',FontW,DefFontW);
   	RestFont(Section,'Font1',Font1,DefFont1);
    RestFont(Section,'Font2',Font2,DefFont2);
  end;
  DelStack;
end;

procedure TSchemDM.SayStatSample(Sender: TObject; Parent: TWinControl;
  var Header: String; var AfterRebuild: TNotifyEvent);
var pn: TStatPanel;
begin
	AddStack('TSchemDM.StandartSample',Self);
  Header:=''; AfterRebuild:=SayStatAfterRebuild;
  pn:=TStatPanel.Create(Parent.Owner); pn.Parent:=Parent;
  with pn do begin
  	Header:='Идёт процесс'; pn.SectLeft[0]:='Код: 200';
    pn.SectRight[0]:='Осталось 00:01:20'; gg.Progress:=50;
  end;
  DelStack;
end;

class procedure TSchemDM.SayStatAfterRebuild;
var h: byte;
	w,hpn,hgg: longint;
begin
	AddStack('TSchemDM.SayStatAfterRebuild');
  with TRbPanel(Sender) do begin
    with TStatPanel(Controls[0]) do begin
      hpn:=CanvasMaxH(pn.Canvas)+pn.BevPanel2;
      Canvas.Font.Assign(gg.Font); hgg:=CanvasMaxH(Canvas); Canvas.Font.Assign(Font); 
      SetBounds(Left,Top,max(MinWidth,Canvas.TextWidth(Header)+10),
      	hpn+hgg+BevPanel2+HeaderHeight);
      h:=BevPanel; w:=CltWidth; pn.SetBounds(h,h+HeaderHeight,w,hpn);
      gg.SetBounds(h,pn.Top+pn.Height,w,hgg);
    end;
    Sort;
  end;
  DelStack;
end;

procedure TSchemDM.BrowlSample(Sender: TObject; Parent: TWinControl;
  var Header: String; var AfterRebuild: TNotifyEvent);
var sb: TStringBrowl;
	i: byte;
  s: string;
begin
	AddStack('TSchemDM.BrowlSample',Self);
  sb:=TStringBrowl.Create(Parent.Owner); sb.Parent:=Parent;
  with sb do begin
  	FixedCols:=0; ColZn.Text:='Столбец 1'+CRLF+'Столбец 2'; i:=2; AddSt(i);
    for i:=1 to i do begin
    	s:=StringOfChar('0',i); Cells[0,i]:='1'+s; Cells[1,i]:='2'+s;
    end;
    Row:=FixedRows;
  end;
  DelStack;
end;

procedure TSchemDM.EditSample(Sender: TObject; Parent: TWinControl;
  var Header: String; var AfterRebuild: TNotifyEvent);
var n: longint;
	procedure Crt1(lReadOnly: boolean);
  var tf: TFldEdit;
    s: string;
  begin
    AddStack('TSchemDM.EditSample.Crt1',Self);
    tf:=TFldEdit.Create(Parent.Owner); tf.Parent:=Parent; s:=IntToStr(n); Inc(n);
    with tf do begin
      Vid:=TSimpleGet.ClassName; Value:='Поле '+s; MaxLength:=Length(Value);
      SayCaption:='Подсказка '+s; SetReadOnly(lReadOnly);
    end;
    DelStack;
  end;
begin
	AddStack('TSchemDM.EditSample',Self);
  n:=1; Crt1(false); Crt1(true);
  DelStack;
end;

procedure TSchemDM.AskSample(Sender: TObject; Parent: TWinControl;
  var Header: String; var AfterRebuild: TNotifyEvent);
var pn: TAskPanel;
	procedure btCrt(const Capt: string);
  begin
		AddStack('TSchemDM.AskSample.BtCrt',Self);
    with TButton.Create(Parent.Owner) do begin
    	Parent:=pn; Caption:='  '+Capt+'  ';
    end;
    DelStack;
  end;
begin
	AddStack('TSchemDM.AskSample',Self);
  Header:=''; AfterRebuild:=AskAfterRebuild; TRbPanel(Parent).SortObj:=false;
  pn:=TAskPanel.Create(Parent.Owner); pn.Parent:=Parent;
  with pn do begin
  	BevelInner:=bvLowered; BevelOuter:=bvRaised;
    SetLength(alb,1); alb[0]:='Выполнить действия ?';
    BtCrt('Да'); BtCrt('Нет');
  end;
  SchemName(TRbPanel(Parent).Schem,schSamp); TRbPanel(Parent).Schem:='';
  DelStack;
end;

procedure TSchemDM.AskAfterRebuild;
var pn: TAskPanel;
	i,w,w1,h,hb,wb: longint;
  sz: TSize;
begin
	AddStack('TSchemDM.AskAfterRebuild',Self);
  with TRbPanel(Sender) do begin
    pn:=pointer(Controls[0]); hb:=0; wb:=0;
    for i:=0 to pn.ControlCount-1 do with TButton(pn.Controls[i]) do begin
      Font.Assign(schSamp.Font2); Canvas.Font.Assign(Font); sz:=Canvas.TextExtent(Caption);
      MaxSelf(wb,sz.cx); MaxSelf(hb,sz.cy);
    end;
		pn.Font.Assign(schSamp.Font1); Canvas.Font.Assign(pn.Font); sz:=Canvas.TextExtent(pn.alb[0]);
    w := AskiX shl 1 + max(wb*2+AskiX,sz.cx); Inc(hb,AskiY); h:=sz.cy+hb+AskiY*3;
    pn.SetBounds(nround((Width-w)/2),nround((Height-h)/2),w,h);
    w:=nround((w-wb*2)/3); w1:=w;
    for i:=0 to pn.ControlCount-1 do with TButton(pn.Controls[i]) do begin
    	SetBounds(w1, AskiY shl 1 + sz.cy, wb, hb); Inc(w1,Width+w);
    end;
  end;
  DelStack;
end;

procedure TSchemDM.StatusSample(Sender: TObject; Parent: TWinControl;
  var Header: String; var AfterRebuild: TNotifyEvent);
var	pn: TRbPanel;
  ps: TRbStatus;
begin
	AddStack('TSchemDM.StatusSample',Self);
  Header:=''; TRbPanel(Parent).Place:=rpBottom; AfterRebuild:=StatusAfterRebuild;
  ps:=TRbStatus.Create(Parent.Owner); ps.Parent:=Parent;
  with ps do begin
    ParentSchem:=true; SectLeft[0]:='Информация'; SectLeft[1]:='Ошибка'; SectType[mstLeft,1]:=1;
  end;
  pn:=TRbPanel.Create(Parent.Owner); pn.Parent:=Parent;
  with pn do begin
  	BevelOuter:=bvLowered; ProcentWnd:=100; Schem:='';
  end;
  DelStack;
end;

class procedure TSchemDM.StatusAfterRebuild;
var tc: TRbStatus;
	h: longint;
begin
	AddStack('TSchemDM.StatusAfterRebuild');
  with TRbPanel(Sender) do begin
  	tc:=pointer(Controls[0]); h:=tc.MinHeight;
    tc.SetBounds(0,Height-h,Width,h); tc.Invalidate; Controls[1].SetBounds(0,0,Width,Height-h);
  end;
  DelStack;
end;

procedure TSchemDM.StatusSetToAppl(Sender: TObject);
var Sect: string;
  i: longint;
  ts: TSchem;
  ls: TStrStrList;
begin
  AddStack('TSchemDM.StatusSetToAppl',Self);
  with InitFIni[fiSchem] do if not ValueExists('Global','StatusAdd1') then begin
    WriteString('Global','StatusAdd1','1');
    Sect:=TSchem(Sender).Section; DeleteKey(Sect,'Color1');
    if ReadSectionList(Sect,ls) then begin
      i:=0;
      while i<ls.Count do
        if AnsiStartsStr('Font1.',ls[i]) then ls.Delete(i) else Inc(i);
    end;
		for i:=0 to LsSchem.Count-1 do begin
      ts:=PointerObj(LsSchem,i); RestSchem(ts); SaveSchem(ts);
    end;
  end;
  DelStack;
end;

procedure TSchemDM.CalcSample(Sender: TObject; Parent: TWinControl;
  var Header: String; var AfterRebuild: TNotifyEvent);
var pn: TPCalc;
begin
	AddStack('TSchemDM.CalcSample',Self);
  Header:=''; AfterRebuild:=CalcAfterRebuild;
  pn:=TPCalc.Create(Parent.Owner); pn.Parent:=Parent;
  pn.Pnl.Cpt:='10'; pn.aMem[1].pn.Capt:='20';
  SchemName(TRbPanel(Parent).Schem,schSamp); TRbPanel(Parent).Schem:='';
  DelStack;
end;

procedure TSchemDM.CalcAfterRebuild;
begin
	AddStack('TSchemDM.CalcAfterRebuild',Self);
  TPCalc(TRbPanel(Sender).Controls[0]).Init(schSamp);
  DelStack;
end;

procedure TSchemDM.ViewGFSample(Sender: TObject; Parent: TWinControl;
  var Header: String; var AfterRebuild: TNotifyEvent);
var tf: TFldEdit;
begin
	AddStack('TSchemDM.ViewGFSample',Self);
  Header:=''; AfterRebuild:=ViewGFAfterRebuild;
  tf:=TFldEdit.Create(Parent.Owner); tf.Parent:=Parent;
  with tf do begin
    Vid:=TSimpleGet.ClassName; IncOptions([],[ogAutoSize]);
  end;
  DelStack;
end;

class procedure TSchemDM.ViewGFAfterRebuild;
const iY=10;
begin
	AddStack('TSchemDM.ViewGFAfterRebuild');
  with TRbPanel(Sender) do Controls[0].SetBounds(BevelFld,iY,Width-BevelFld2,Height-iY shl 1);
  DelStack;
end;

procedure TSchemDM.TreeSample(Sender: TObject; Parent: TWinControl;
  var Header: String; var AfterRebuild: TNotifyEvent);
var t: TTreePrim;
begin
	AddStack('TSchemDM.TreeSample',Self);
  t:=TTreePrim.Create(Parent.Owner); t.Parent:=Parent;
  with t do begin
  	HideSelection:=false; BeginUpdate;
    try
      Selected:=AddPrim(nil,'1','Примечание 1'); AddPrim(nil,'2','Примечание 2');
      AddPrim(Selected,'1.1','Примечание 1.1'); Selected.Expand(true);
    finally
      EndUpdate;
    end;
  end;
  DelStack;
end;

procedure TSchemDM.MenuSample(Sender: TObject; Parent: TWinControl;
  var Header: String; var AfterRebuild: TNotifyEvent);
var mn: TRbMenu;
begin
	AddStack('TSchemDM.MenuSample',Self);
  mn:=TRbMenu.Create(Parent.Owner); mn.Parent:=Parent;
  with mn do begin
  	InsertKey(K_F2,'Список'); InsertKey(K_F5,'Редактировать'); MinSized:=true;
  end;
  DelStack;
end;

procedure TSchemDM.EdTxtSample(Sender: TObject; Parent: TWinControl;
  var Header: String; var AfterRebuild: TNotifyEvent);
  procedure CrtMemo(RdOnly: boolean);
  var m: TTextMemo;
  begin
    AddStack('TSchemDM.EdTxtSample.CrtMemo',Self);
    m:=TTextMemo.CreateParent(Parent.Owner,Parent);
    with m do begin
      Text:='Этот текст '+IfThen(RdOnly,'не')+'доступен для редактирования';
      ReadOnly:=RdOnly; ReadOnlyColor:=RdOnly; WordWrapBool:=true;
    end;
    DelStack;
  end;
begin
  AddStack('TSchemDM.EdTxtSample',Self);
  with TRbPanel(Parent) do begin
    SortObj:=false; OnResize:=EdTxtPnResize;
  end;
  CrtMemo(false); CrtMemo(true); EdTxtPnResize(Parent);
  DelStack;
end;

class procedure TSchemDM.EdTxtPnResize;
var w,h: longint;
  mw,mr: TTextMemo;
begin
  AddStack('TSchemDM.EdTxtPnResize');
  with TRbPanel(Sender) do if ControlCount=2 then
    if IsClass(Controls[0].Owner,TTextMemo,pointer(mw)) and IsClass(Controls[1].Owner,TTextMemo,pointer(mr)) then begin
      h:=HeaderHeight; w:=CltWidth; mw.SetBounds(BevPanel,BevPanel+h,w div 2,CltHeight-h);
      with mw.Control do mr.SetBounds(Left+Width,Top,w-Width,Height);
    end;
  DelStack;
end;

{$IFDEF PRNSCREEN}
class procedure TSchemDM.PrnTextBeforeShow;
begin
  AddStack('TSchemDM.PrnTextBeforeShow');
  with TEdText(Sender).MemoEdit.Font do begin
    Name:=aEr866FontName[false]; CharSet:=DEFAULT_CHARSET;
  end;
  DelStack;
end;

class procedure TSchemDM.PrnTextAfterShow;
begin
  AddStack('TSchemDM.PrnTextAfterShow');
  SetSchemForm(pointer(Sender));
  DelStack;
end;
{$ENDIF}

end.

