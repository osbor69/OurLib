unit FMsOffEd;

interface

{$I LIBTEST}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs, Menus, ExtCtrls, ComCtrls,
    Excel97, Word97, OleServer,
  MyTypes, My_pr, FStat, FRMEDT, KeyMenu, PnlEdit, Keylb, Fpanel, DefEdit, DirGet, ChkGets, MenuGet,
    FFldedit, RecVal, RbPage, GenForm, HtmlFile, CCodeGet;

const msoFormatUser = 41;

type
  TEditorGet = class(TMenuGet)
  private
		class procedure PrMove(oi,ni: longint; const av: array of variant);
 	protected
    class function ListKeyStr: string; override;
    procedure ListKeyProc(key: longint; tw: TWinControl); override;
  end;

  TMSOReopenProc = procedure(const av: array of variant; var result: variant) of object;

  TMSOWeightRec = record
  	LineWidth: WdLineWidth;
    Weight: single;
  end;

  TOleServerClass = class of TOleServer;

	TMSOFormatList = 1..msoFormatUser;

  TMsOffEd = class(TFormEdt)
    Rec: TRecVal;
    RbPage1: TRbPage;
    tsOsn: TTabSheet;
    tsPage: TTabSheet;
    pnOsn: TRbPanel;
    EBrFld: TFldEdit;
    pnPage: TRbPanel;
    EPages: TFldEdit;
    EFormat: TFldEdit;
    FormatGet: TMenuGet;
    OrientGet: TRadioGet;
    EOrient: TFldEdit;
    pnWH: TRbPanel;
    EWidth: TFldEdit;
    EHeight: TFldEdit;
    pnSpot: TRbPanel;
    ETop: TFldEdit;
    EBottom: TFldEdit;
    ELfeft: TFldEdit;
    ERight: TFldEdit;
    GF: TGenForm;
    EVPage: TFldEdit;
    DirGet1: TDirGet;
    SaveDialog1: TSaveDialog;
    EFile: TFldEdit;
    EType: TFldEdit;
    EErr: TFldEdit;
    EFmt: TFldEdit;
    EEditor: TFldEdit;
    deEditor: TDefEdit;
    DirGet2: TDirGet;
    OpenDialog1: TOpenDialog;
    EReadOnly: TFldEdit;
    ENoTrns: TFldEdit;
    procedure FormCreate(Sender: TObject);
    function EBrFldCheck(Sender: TObject): Boolean;
    function PanelEdit1Valid(Sender: TObject): Boolean;
    procedure EFormatChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure EVPageChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    function EFileCheck(Sender: TObject): Boolean;
    procedure FormDestroy(Sender: TObject);
    procedure ETypeChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    function EPagesCheck(Sender: TObject): Boolean;
    procedure EFmtChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure deEditorFldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure deEditorFldExit(Sender: TObject);
    procedure EFmtExit(Sender: TObject);
    procedure PanelEdit1CngKey(Sender: TObject; var tb: TKeyBut);
  private
    { Private declarations }
    Obj: TWinControl;
    EditorGet: TEditorGet;
    lv,lRaise,ApplHide: boolean;
  	nGFLeaf,nRtfFont,nlsRtfFont,nRtfFontSize,nRtfFontRGB,nRtfAlgn,nRtfRowBetween,n,p,cl: longint;
    f: TGFPackFont;
  	pv: PGFObj;
    rf: TGFFillRec;
    ll,lr,lt,lb: byte;
    s,sel: string;
    lsCol,lsRtfColor,lsRtfRGB: TIntegerList;
    lsRtfFont: TStringList;
    alsCol,aRtfRGB,aGFPg: TArrInt;
    aCol,aRow: TArrWord;
    aMerge: TArrStr;
    aX,aY: array of single;
    waWeight: array[TLineWidth] of TMSOWeightRec;
    eaWeight: array[TLineWidth] of XlBorderWeight;
    eRateCol: Single;
    aSrv: array[TMSOEditorList] of record
      cAppl,cDoc: TOleServerClass;
      Appl,Doc: TOleServer;
    end;
    sRtfStyle: TFontStyles;
    TmpBmp: TFileName;
    nLnDef: byte;
    awln: array[TLineWidth] of Double;
    aFont: TArrFont;
    fFile: TCustomFormatFile;
    TxtBmp: TBitMap;
    procedure EEditorChange(Sender: TObject; const OldVal: Variant; FromShow: Boolean);
		procedure StTrans(Sender: TStat);
		procedure StGFPage(Sender: TStat);
    function Line1(nto: longint): boolean;
    function IsBmp(pv: PGFObj): boolean;
    procedure TxtBmpPaint(pv: PGFObj; const fn: TFileName);
    procedure pvFont;
    procedure LineXY(pv: PGFObj);
    procedure HtmLine(n: byte; const sv: string);
    procedure XlsSetGlobals(CountSheet: longint; const acFont: array of TFont;
      const aColor: array of TColor; SizeFontHead: longint = 0);
    procedure XlsBeginSheet(const Name: string; ColCount,RowCount: Word; Format: TMsoFormatList;
      w,h,t,b,l,r: longint; orient: TPrinterOrientation);
    procedure XlsWriteCell(Row1,Row2,Col1,Col2: Word; const Value: variant; const ValueAsStr: string;
      nFont,nColor: byte; const Format: string; algmHorz: TAlignment;
      algmVert: TAlignment = taRightJustify; Angle: Word = 0; AdjustWH: boolean = true;
      wTop   : TLineNulWidth = 1; nclTop   : byte = 0;
      wLeft  : TLineNulWidth = 1; nclLeft  : byte = 0;
      wBottom: TLineNulWidth = 1; nclBottom: byte = 0;
      wRight : TLineNulWidth = 1; nclRight : byte = 0);
		procedure SaveToFile;
    procedure RtfInit;
    function RtfFont(n: longint; RowBetween: ShortInt = 0): string;
    function RtfColor(Color: TColor; const ctrlw: string = 'clcbpat'): string;
    function RtfAlign(a: TAlignment; lJustified: boolean = false): string;
    function ReOpen(const sErr: string; Proc: TMSOReopenProc; const av: array of variant): variant;
    procedure PrLineAdd(const av: array of variant; var result: variant);
    procedure PrLine(const av: array of variant; var result: variant);
    procedure PrAddRow(const av: array of variant; var result: variant);
    procedure PrRowHeight(const av: array of variant; var result: variant);
    procedure SetColWidth(nc,w: longint);
    procedure PrAddCol(const av: array of variant; var result: variant);
    procedure PrColWidth(const av: array of variant; var result: variant);
    procedure SetMerge(r1,c1,r2,c2: longint; x1: longint = 0; x2: longint = 0; y: longint = 0);
    procedure PrMerge(const av: array of variant; var result: variant);
    procedure PrMergeSel(const av: array of variant; var result: variant);
    procedure PrObjAdd(const av: array of variant; var result: variant);
    procedure PrObj(const av: array of variant; var result: variant);
    procedure PrObjFill(const av: array of variant; var result: variant);
    function GFTblX2(c,r: longint): longint;
    function GFTblX(x,y: longint): longint;
    function GFTblY2(r: longint): longint;
    function GFTblY(y: longint): longint;
    function rfX(i: longint): longint;
    function rfY(i: longint): longint;
    function wRange(r1,c1: longint; r2: longint = 0; c2: longint = 0): Range;
    function InchToPnt(nInch: Single): Single;
    function PixToPnt(nPix: longint): Single;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
  end;

  TMsOffInit = class(TControl)
	private
		procedure WMMsOff(var Message: TWMMsOff); message WM_MSOFF;
		class procedure ProcKey(key: longint; tw: TWinControl);
  public
  	constructor Create(AOwner: TComponent); override;
  end;

const
	aMSOFmt: array[TMSOFormatList] of record
  	wPsz: WdPaperSize;
  	ePsz: xlPaperSize;
    wMM,hMm: Single;
		Name: string;
  end =
    ((wPsz:wdPaperA4                ;ePsz:xlPaperA4                ;wMm:210            ;hMm:297            ;Name:'A4')
    ,(wPsz:wdPaperA3                ;ePsz:xlPaperA3                ;wMm:297            ;hMm:420            ;Name:'A3')
    ,(wPsz:wdPaperA5                ;ePsz:xlPaperA5                ;wMm:148.5          ;hMm:210            ;Name:'A5')
    ,(wPsz:wdPaper10x14             ;ePsz:xlPaper10x14             ;wMm:MmInInch*10    ;hMm:MmInInch*14    ;Name:'10 x 14 дюймов')
    ,(wPsz:wdPaper11x17             ;ePsz:xlPaper11x17             ;wMm:MmInInch*11    ;hMm:MmInInch*17    ;Name:'11 x 17 дюймов')
    ,(wPsz:wdPaperLetter            ;ePsz:xlPaperLetter            ;wMm:MmInInch*8.5   ;hMm:MmInInch*11    ;Name:'Letter (8,5 x 11 дюймов)')
    ,(wPsz:wdPaperLetterSmall       ;ePsz:xlPaperLetterSmall       ;wMm:MmInInch*8.5   ;hMm:MmInInch*11    ;Name:'Letter small (8,5 x 11 дюймов)')
    ,(wPsz:wdPaperLegal             ;ePsz:xlPaperLegal             ;wMm:MmInInch*8.5   ;hMm:MmInInch*14    ;Name:'Legal (8,5 x 14 дюймов)')
    ,(wPsz:wdPaperExecutive         ;ePsz:xlPaperExecutive         ;wMm:MmInInch*7.25  ;hMm:MmInInch*10.5  ;Name:'Executive (7,25 x 10,5 дюймов)')
    ,(wPsz:wdPaperA4Small           ;ePsz:xlPaperA4Small           ;wMm:210            ;hMm:297            ;Name:'A4 Small')
    ,(wPsz:wdPaperB4                ;ePsz:xlPaperB4                ;wMm:257            ;hMm:364            ;Name:'B4')
    ,(wPsz:wdPaperB5                ;ePsz:xlPaperB5                ;wMm:182            ;hMm:257            ;Name:'B5')
    ,(wPsz:wdPaperCSheet            ;ePsz:xlPaperCSheet            ;wMm:MmInInch*17    ;hMm:MmInInch*22    ;Name:'C Size (17 x 22 дюйма)')
    ,(wPsz:wdPaperDSheet            ;ePsz:xlPaperDSheet            ;wMm:MmInInch*22    ;hMm:MmInInch*34    ;Name:'D Size (22 x 34 дюйма)')
    ,(wPsz:wdPaperESheet            ;ePsz:xlPaperESheet            ;wMm:MmInInch*34    ;hMm:MmInInch*44    ;Name:'E Size (34 x 44 дюйма)')
    ,(wPsz:wdPaperFanfoldLegalGerman;ePsz:xlPaperFanfoldLegalGerman;wMm:MmInInch*8.5   ;hMm:MmInInch*13    ;Name:'Fanfold Legal German (8,5 x 13 дюймов)')
    ,(wPsz:wdPaperFanfoldStdGerman  ;ePsz:xlPaperFanfoldStdGerman  ;wMm:MmInInch*8.5   ;hMm:MmInInch*12    ;Name:'Fanfold (8,5 x 12 дюймов)')
    ,(wPsz:wdPaperFanfoldUS         ;ePsz:xlPaperFanfoldUS         ;wMm:MmInInch*14.875;hMm:MmInInch*11    ;Name:'FanfoldUS (14,875 x 11 дюйма)')
    ,(wPsz:wdPaperFolio             ;ePsz:xlPaperFolio             ;wMm:MmInInch*8.5   ;hMm:MmInInch*13    ;Name:'Folio (8,5 x 13 дюймов)')
    ,(wPsz:wdPaperLedger            ;ePsz:xlPaperLedger            ;wMm:MmInInch*17    ;hMm:MmInInch*11    ;Name:'Ledger (17 x 11 дюймов)')
    ,(wPsz:wdPaperNote              ;ePsz:xlPaperNote              ;wMm:MmInInch*8.5   ;hMm:MmInInch*11    ;Name:'Note (8,5 x 11 дюймов)')
    ,(wPsz:wdPaperQuarto            ;ePsz:xlPaperQuarto            ;wMm:215            ;hMm:275            ;Name:'Quatro')
    ,(wPsz:wdPaperStatement         ;ePsz:xlPaperStatement         ;wMm:MmInInch*5.5   ;hMm:MmInInch*8.5   ;Name:'Statement (5,5 x 8,5 дюймов)')
    ,(wPsz:wdPaperEnvelope9         ;ePsz:xlPaperEnvelope9         ;wMm:MmInInch*3.875 ;hMm:MmInInch*8.875 ;Name:'Конверт №9 (3,875 x 8,875 дюймов)')
    ,(wPsz:wdPaperEnvelope10        ;ePsz:xlPaperEnvelope10        ;wMm:MmInInch*4.125 ;hMm:MmInInch*9.5   ;Name:'Конверт №10 (4,125 x 9,5 дюймов)')
    ,(wPsz:wdPaperEnvelope11				;ePsz:xlPaperEnvelope11        ;wMm:MmInInch*4.5   ;hMm:MmInInch*10.375;Name:'Конверт №11 (4,5 x 10,375 дюймов)')
    ,(wPsz:wdPaperEnvelope12				;ePsz:xlPaperEnvelope12        ;wMm:MmInInch*4.75  ;hMm:MmInInch*11    ;Name:'Конверт №12 (4,75 x 11 дюймов)')
    ,(wPsz:wdPaperEnvelope14				;ePsz:xlPaperEnvelope14        ;wMm:MmInInch*5     ;hMm:MmInInch*11.5  ;Name:'Конверт №14 (5 x 11,5 дюймов)')
    ,(wPsz:wdPaperEnvelopeB4				;ePsz:xlPaperEnvelopeB4        ;wMm:250            ;hMm:353            ;Name:'Конверт B4')
    ,(wPsz:wdPaperEnvelopeB5				;ePsz:xlPaperEnvelopeB5        ;wMm:176            ;hMm:250            ;Name:'Конверт B5')
    ,(wPsz:wdPaperEnvelopeB6				;ePsz:xlPaperEnvelopeB6        ;wMm:125            ;hMm:176            ;Name:'Конверт B6')
    ,(wPsz:wdPaperEnvelopeC3				;ePsz:xlPaperEnvelopeC3        ;wMm:324            ;hMm:458            ;Name:'Конверт C3')
    ,(wPsz:wdPaperEnvelopeC4				;ePsz:xlPaperEnvelopeC4        ;wMm:229            ;hMm:324            ;Name:'Конверт C4')
    ,(wPsz:wdPaperEnvelopeC5				;ePsz:xlPaperEnvelopeC5        ;wMm:162            ;hMm:229            ;Name:'Конверт C5')
    ,(wPsz:wdPaperEnvelopeC6				;ePsz:xlPaperEnvelopeC6        ;wMm:114            ;hMm:162            ;Name:'Конверт C6')
    ,(wPsz:wdPaperEnvelopeC65       ;ePsz:xlPaperEnvelopeC65       ;wMm:114            ;hMm:229            ;Name:'Конверт С6/С5')
    ,(wPsz:wdPaperEnvelopeDL        ;ePsz:xlPaperEnvelopeDL        ;wMm:110            ;hMm:220            ;Name:'Конверт DL')
    ,(wPsz:wdPaperEnvelopeItaly     ;ePsz:xlPaperEnvelopeItaly     ;wMm:110            ;hMm:230            ;Name:'Конверт Italy')
    ,(wPsz:wdPaperEnvelopeMonarch   ;ePsz:xlPaperEnvelopeMonarch   ;wMm:MmInInch*3.875 ;hMm:MmInInch*7.5   ;Name:'Конверт Monarch (3,875 x 7,5 дюймов)')
    //,(wPsz:wdPaperEnvelopePersonal  ;ePsz:xlPaperEnvelopePersonal  ;wMm:MmInInch*3.875 ;hMm:MmInInch*7.5   ;Name:'Конверт Personal (3,875 x 7,5 дюймов)')
    ,(wPsz:wdPaperTabloid           ;ePsz:xlPaperTabloid           ;wMm:MmInInch*11    ;hMm:MmInInch*17    ;Name:'Tabloid (11 x 17 дюймов)')
    ,(wPsz:wdPaperCustom            ;ePsz:xlPaperUser                                                      ;Name:'другой')
    );

implementation

{$R *.dfm}

uses Variants,Forms,Office97,ActiveX,StdCtrls,DB,Math,ShellAPI,StrUtils,Printers,
  Browl,StrBrowl,Askp,FFdp,MulQry,TreePrim,Inter,ListF2;

const
  TmpFile = '~~msoff.tmp';

  DefColor = clBlack;
  DefWidth = 1;

type
  TErrvList0 = (ervNone,ervOther,ervOverMaxCol); TErrvList = Succ(ervNone)..high(TErrvList0);
	TErrvStr = array[TErrvList] of string;

  TErrdList0 = (erdNone,erdAsk,erdText); TErrdList = Succ(erdNone)..high(TErrdList0);

  PEditorInfo = ^TEditorInfo;
  TEditorInfo = record
    tp: TMSOEditorList0;
    fmt: string[byte(high(TMSOFmtList))-1];
    name: string;
  end;

  TNoTrns = 1..2;

const
  aFmtNm: TMSOFmtStr = ('Обычный','HTML','RTF','XLS');

	aExt: array[TMSOEditorList0,TMSOFmtList] of string =
    (('htm','htm','rtf','xls')
    ,('xls','htm','rtf','xls')
    ,('doc','htm','rtf','xls')
    );

	aEd: array[TMSOEditorList] of string = ('Microsoft Excel','Microsoft Word');

	awType: array[TMSOTrnType] of string = ('в таблицу','в текст');

	aAlgm: array[boolean,TMSOEditorList,TAlignment] of TOleEnum =
		(((xlHAlignLeft,xlHAlignRight,xlHAlignCenter)
		 ,(wdAlignParagraphLeft,wdAlignParagraphRight,wdAlignParagraphCenter)
     )
    ,((xlVAlignTop,xlVAlignBottom,xlVAlignCenter)
     ,(wdCellAlignVerticalTop,wdCellAlignVerticalBottom,wdCellAlignVerticalCenter)
     )
    );

	aTextOrient: array[TMSOTrnType,TMSOEditorList,1..3] of TOleEnum =
    (((xlHorizontal,xlDownward,xlUpward)
     ,(wdTextOrientationHorizontal,wdTextOrientationDownward,wdTextOrientationUpward)
     )
    ,((msoTextOrientationHorizontal,msoTextOrientationDownward,msoTextOrientationUpward)
     ,(msoTextOrientationHorizontal,msoTextOrientationDownward,msoTextOrientationUpward)
     )
    );

	aMaxCol: array[TMSOEditorList] of longint = (230,63);

  sRtfRowBeg = '\trowd\trpaddft3\trpaddt0\trpaddfl3\trpaddl0\trpaddfb3\trpaddb0\trpaddfr3\trpaddr0';

  mrgTop    = 1 shl 0;
  mrgBottom = 1 shl 1;
  mrgLeft   = 1 shl 2;
  mrgRight  = 1 shl 3;

	aGFFmt: array[TGFFrmList] of TMSOFormatList = (2,1,3,2,1,3,msoFormatUser);

var MsOffEd: TMsOffEd;
  sErr: string;
	trntype: TMSOTrnType;
  lSuccess: boolean;
  wTbl: Table;
  eSheet: TExcelWorksheet;
  ted: TMSOEditorList0;
  fmt: TMSOFmtList;
  aErrv: TErrvStr;

function wColorIndex(cl: TColor): WdColorIndex;
const	a: array[0..15] of WdColorIndex =
  (wdBlack,wdDarkRed,wdGreen,wdDarkYellow,wdDarkBlue,wdViolet,wdTeal,wdGray50,
  wdGray25,wdRed,wdBrightGreen,wdYellow,wdBlue,wdPink,wdTurquoise,wdWhite);
begin
  AddStack('FMsOffEd.wColorIndex');
  result:=a[SeekColor(cl,false)];
  DelStack;
end;

function ColorRGB(cl: TColor): longint;
begin
  AddStack('FMsOffEd.ColorRGB');
  result:=ColorToRGB(cl) and $FFFFFF;
  DelStack;
end;

procedure wConvFont(f: TFont; wf: WordFont);
begin
  AddStack('FMsOffEd.wConvFont');
  with wf do begin
    Bold:=IfThen(fsBold in f.Style,1); Italic:=IfThen(fsItalic in f.Style,1);
    Underline:=IfThen(fsUnderline in f.Style,2);
    StrikeThrough:=IfThen(fsStrikeOut in f.Style,1); Size:=f.Size; Name:=f.Name;
    ColorIndex:=wColorIndex(f.Color);
  end;
  DelStack;
end;

function TMsOffEd.wRange;
var Start,End_: OleVariant;
begin
  AddStack('TMsOffEd.wRange',Self);
  if r2=0 then r2:=r1;
  if c2=0 then c2:=c1;
  Start:=wTbl.Cell(r1,c1).Range.Start; End_:=wTbl.Cell(r2,c2).Range.End_;
  result:=TWordDocument(aSrv[ted].Doc).Range(Start,End_);
  DelStack;
end;

procedure eConvFont(f: TFont; ef: Excel97.Font);
begin
  AddStack('FMsOffEd.eConvFont');
  with ef do begin
    Bold := fsBold in f.Style; Italic :=fsItalic in f.Style;
    Underline:=iif(fsUnderline in f.Style,xlUnderlineStyleSingle,null);
    StrikeThrough := fsStrikeOut in f.Style; Size:=f.Size; Name:=f.Name;
    Color:=ColorRGB(f.Color);
  end;
  DelStack;
end;

function eRange(r1,c1: longint; r2: longint = 0; c2: longint = 0): Excel97.ExcelRange;
  function eCell(r,c: longint): string;
    function eCell1(c: longint): string;
    begin
      AddStack('FMsOffEd.eRange.eCell.eCell1');
      if c<0 then result:='' else result:=Chr(Ord('A')+c);
      DelStack;
    end;
  const cntChar = 26;
  begin
    AddStack('FMsOffEd.eRange.eCell');
    Dec(c); result:=eCell1(ModDiv(c,cntChar)); result:=StrNum(eCell1(c-1)+result,r);
    DelStack;
  end;
begin
  AddStack('FMsOffEd.eRange');
  if r2=0 then r2:=r1;
  if c2=0 then c2:=c1;
  result:=eSheet.Range[eCell(r1,c1),eCell(r2,c2)];
  {if not ApplHide then begin
  	mess_ok([eCell(r1,c1),eCell(r2,c2)]); result.Select; ApplHide:=true;
  end;}
  DelStack;
end;

function TMsOffEd.InchToPnt;
begin
  AddStack('TMsOffEd.InchToPnt',Self);
	with aSrv[ted] do case ted of
    msoEdExcel: result:=TExcelApplication(Appl).InchesToPoints(nInch);
    msoEdWord : result:=TWordApplication (Appl).InchesToPoints(nInch);
  else result:=0;
  end;
  DelStack;
end;

function TMsOffEd.PixToPnt;
begin
  AddStack('TMsOffEd.PixToPnt',Self);
	result:=InchToPnt(nPix/Screen.PixelsPerInch);
  DelStack;
end;

{function TestPrm(const av,ap: array of variant): boolean;
var i,h: longint;
begin
  AddStack('FMsOffEd.TestPrm');
  h:=high(av); result := h=high(ap);
  if result then for i:=low(av) to h do
  	if not IsNil(ap[i]) then
      if av[i]<>ap[i] then begin
        result:=false; break;
      end;
  if result then with aSrv[ted] do case ted of
    msoEdExcel: begin
    	TExcelApplication(Appl).Visible[0]:=true; ApplHide:=false;
    end;
  	msoEdWord: TWordApplication(Appl).Visible:=true;
  end;
  DelStack;
end;}

procedure lsEditorClearIndex(ls: TStringList; i: longint);
begin
  AddStack('FMsOffEd.lsEditorClearIndex');
  if Assigned(ls.Objects[i]) then Dispose(PEditorInfo(ls.Objects[i]));
  DelStack;
end;

procedure lsEditorClear(ls: TStringList);
var i: longint;
begin
  AddStack('FMsOffEd.lsEditorClear');
  ls.BeginUpdate;
  for i:=0 to ls.Count-1 do lsEditorClearIndex(ls,i);
  ls.Clear; ls.EndUpdate;
  DelStack;
end;

function FmtEdDef(i: TMSOEditorList): string;
const a: array[TMSOEditorList] of set of TMSOFmtList =
  ([msoFmtDefault,msoFmtRtf]
  ,[msoFmtDefault,msoFmtHtml]
  );
var j: TMSOFmtList;
begin
  AddStack('FMsOffEd.FmtEdDef');
  result:='';
  for j:=low(aFmtNm) to high(aFmtNm) do SetByte(result,byte(j), j in a[i]);
  DelStack;
end;

{ TEditorGet }
class function TEditorGet.ListKeyStr;
begin
  AddStack('TEditorGet.ListKeyStr');
  with TKeyLb do result:=ArrayAsList(
    [GetKeySt(K_F4,'Скопировать')
    ,GetKeySt(K_F5,'Редактировать')
    ,GetKeySt(K_F7,'Добавить')
    ,GetKeySt(K_F8,'Удалить')
    ,GetKeySt(K_Ctrl_Up,'Выше','Переместить выше')
    ,GetKeySt(K_Ctrl_Down,'Ниже','Переместить ниже')
    ],CRLF);
  DelStack;
end;

procedure TEditorGet.ListKeyProc;
var lb: TFindListBox;
  ls: TStringList;
  i: longint;
  Modified: boolean;
  procedure Move(offs: TValueSign);
  begin
    AddStack('TEditorGet.ListKeyProc.Move',Self);
    if ListMoveItem(i,i+offs,0,ls.Count-1,PrMove,[LongInt(lb),LongInt(ls)]) then begin
      lb.ItemIndex:=i+offs; Modified:=true;
    end;
    DelStack;
  end;
var p: PEditorInfo;
  f: TCustomForm;
  s: string;
  l: longint;
begin
  AddStack('TEditorGet.ListKeyProc',Self);
  lb:=pointer(tw);
  if (lb.Items.Count>0) or (Key=K_F7) then begin
    Modified:=false; ls:=TStringList.Create;
    try
      for i:=0 to Items.Count-1 do begin
        New(p); ls.AddObject(ACodName(i).Name,pointer(p)); p^:=PEditorInfo(Items.Objects[i])^;
      end;
      i:=lb.ItemIndex;
      case Key of
        K_F4,K_F5,K_F7: begin
          if Key=K_F7 then begin
            MsOffEd.Rec['EdName']:=''; MsOffEd.Rec['EdType']:=msoEdDefine;
            MsOffEd.Rec['EdFname']:=''; MsOffEd.Rec['EdFmt']:='';
          end
          else begin
            MsOffEd.Rec['EdName']:=lb.Items[i]; p:=PointerObj(ls,i);
            MsOffEd.Rec['EdType']:=p.tp; MsOffEd.Rec['EdFname']:=p.name; MsOffEd.Rec['EdFmt']:=p.fmt;
          end;
          if MsOffEd.deEditor.Execute(IfThen(Key=K_F5,'Редактирование','Добавление')+' редактора').Saved then begin
            s:=TrimRight(MsOffEd.Rec['EdName']);
            if Key=K_F5 then begin
              ls[i]:=s; p:=PointerObj(ls,i); lb.Items[i]:=ls[i];
            end
            else begin
              New(p); ls.AddObject(s,pointer(p)); lb.Items.Add(s); lb.ItemIndex:=ls.Count-1;
              lb.Canvas.Font.Assign(lb.Font); i:=CanvasMaxH(lb.Canvas)*ls.Count+4-lb.Height;
              if i>0 then begin
                f:=GetParentForm(lb); f.ClientHeight:=f.ClientHeight+i; FormOnScreen(f); MainRebuild(f);
              end;
            end;
            p.tp:=MsOffEd.Rec['EdType']; p.name:=MsOffEd.Rec['EdFname']; p.fmt:=MsOffEd.Rec['EdFmt'];
            Modified:=true;
          end;
        end;
        K_F8: if Ask(amsDel) then begin
          lsEditorClearIndex(ls,i); ls.Delete(i);
          lb.Items.Delete(i); lb.ItemIndex:=EnsureRange(i,0,ls.Count-1); Modified:=true;
        end;
        K_Ctrl_Up: Move(-1);
        K_Ctrl_Down: Move(1);
      end;
      if Modified then begin
        Items.BeginUpdate; InitFIni[fiSave].EraseSection('MsOffEditors'); l:=LenIntStr(ls.Count);
        for i:=0 to ls.Count-1 do begin
          s:=IntToStr(i+1)+UnDelim+ls[i];
          if i<Items.Count then begin
            Items[i]:=s; p:=PointerObj(Items,i);
          end
          else begin
            New(p); Items.AddObject(s,pointer(p));
          end;
          p^:=PEditorInfo(ls.Objects[i])^;
          InitFIni[fiSave].WriteString('MsOffEditors',NumStr(i,l),
            ArrayAsList([ls[i],Int2Str(p.tp),p.name,p.fmt],';'));
        end;
        while Items.Count>ls.Count do begin
          i:=Items.Count-1; lsEditorClearIndex(Items,i); Items.Delete(i);
        end;
        Items.EndUpdate; MsOffEd.MainRebuild;
      end;
    finally
      lsEditorClear(ls); ls.Free;
    end;
  end;
  DelStack;
end;

class procedure TEditorGet.PrMove;
begin
  AddStack('TEditorGet.PrMove');
  TFindListBox(LongInt(av[0])).Items.Exchange(oi,ni); StringListVar(av[1]).Exchange(oi,ni);
  DelStack;
end;

{ TMsOffEd }
procedure TMsOffEd.FormCreate(Sender: TObject);
const aNoTrns: array[TNoTrns] of string = ('в числа','в даты');
var i: longint;
	k: TErrdList;
	s,s1: string;
  p: PEditorInfo;
  ls: TStringList;
  a: array[1..4] of string;
  tp: TMSOEditorList;
  fmt: TMSOFmtList;
  v: TErrvList;
begin
	AddStack('TMsOffEd.FormCreate',Self);
  EErr.AssignGet(TTblChkGet.CreateOne);
  EditorGet:=TEditorGet.Create(Self); EEditor.AssignGet(EditorGet);
  with EditorGet.Items do begin
    BeginUpdate;
    if InitFIni[fiSave].SectionExists('MsOffEditors') then begin
      ls:=TStringList.Create;
      try
        InitFIni[fiSave].ReadSectionValues('MsOffEditors',ls);
        for i:=0 to ls.Count-1 do begin
          LsArrFill(ls.ValueFromIndex[i],a,';'); New(p);
          AddObject(IntToStr(i+1)+UnDelim+a[1],pointer(p));
          p.tp:=TMSOEditorList(EnsureRange(Int0(a[2]),byte(low(p.tp)),byte(high(p.tp))));
          if p.tp=msoEdDefine then begin
            p.name:=a[3]; p.fmt:=a[4]
          end
          else p.fmt:=FmtEdDef(p.tp);
        end;
      finally
        ls.Free;
      end;
    end
    else for tp:=low(aEd) to high(aEd) do begin
      New(p); AddObject(Int2Str(tp)+UnDelim+aEd[tp],pointer(p)); p.tp:=tp; p.fmt:=FmtEdDef(tp);
    end;
    EndUpdate;
  end;
  EEditor.OnChange:=EEditorChange; EEditor.OnExit:=EFmtExit;
  inherited;
  aSrv[msoEdWord].cAppl:=TWordApplication; aSrv[msoEdWord].cDoc:=TWordDocument;
  aSrv[msoEdExcel].cAppl:=TExcelApplication; aSrv[msoEdExcel].cDoc:=TExcelWorkBook;
  Rec.CreateFld('EdFmt',ftString,byte(high(aFmtNm))-1,'');
  deEditor.Param['EdType',deMask]:='Определяемый'+mniDlm+RadioMask(aEd,0);
  deEditor.Param['EdFmt',deMask]:=ArrayAsList(aFmtNm,mniDlm,NegDef,false,1);
  s:=InitFIni[fiSave].ReadString('MsOff','Format',aMSOFmt[low(aMSOFmt)].Name);
  with FormatGet.Items do begin
  	BeginUpdate;
    for i:=low(aMSOFmt) to high(aMSOFmt) do begin
    	Add(IntToStr(i)+UnDelim+aMSOFmt[i].Name);
      if AnsiUpperCase(aMSOFmt[i].Name)=s then Rec['Format']:=i;
    end;
    EndUpdate;
  end;
  EType.Mask:=RadioMask(awType);
  Rec.CreateFld('NOTRNS',ftString,Length(aNoTrns),'','Отменить преобразование строк');
  ENoTrns.Mask:=ArrayAsList(aNoTrns,mniDlm);
  s:='';
  for tp:=low(aEd) to high(aEd) do IncD(s,'|Документы '+aEd[tp]+'|*.'+aExt[tp,msoFmtDefault]);
  for fmt:=Succ(low(aFmtNm)) to high(aFmtNm) do IncD(s,'|Документы формата '+aFmtNm[fmt]+'|*.'+aExt[msoEdDefine,fmt]);
  SaveDialog1.Filter:=Copy(s,2,MaxInt);
  with InitFIni[fiSave] do begin
    Rec['Editor']:=1; ted:=TMSOEditorList(ReadInteger('MsOff','Prog',byte(msoEdExcel)));
    for i:=0 to EditorGet.Items.Count-1 do
      if PEditorInfo(EditorGet.Items.Objects[i]).tp=ted then begin
        Rec['Editor']:=Int0(EditorGet.ACodName(i).Cod); break;
      end;
	  EFmt.Mask:=RadioMask(aFmtNm);
	  Rec['FMT']:=msoFmtHtml; Rec['TrnType']:=msoTwTable; Rec.RestFromIni; s1:='';
    for v:=low(aErrv) to high(aErrv) do begin
    	s:=''; SetByte(s,byte(erdAsk),true);
      if v=ervOther then SetByte(s,byte(erdText),true);
      s:=ReadString('MsOff',StrNum('Err.',v),s);
      for k:=low(TErrdList) to high(TErrdList) do
      	if GetByte(s,byte(k)) then SetByte(s1,byte(k),byte(v),true);
    end;
    Rec['Err']:=s1;
  end;
  TmpBmp:=FullNameExe(TmpFile,'BMP');
  aGFLinesLoad; nLnDef:=2;
  while true do with aGFLines[nLnDef] do begin
  	if Color=DefColor then
	  	if Width=DefWidth then break;
    Inc(nLnDef);
  end;
  for i:=low(awln) to high(awln) do awln[i]:=i/MmInInch/10;
  DelStack;
end;

procedure TMsOffEd.FormDestroy(Sender: TObject);
var SaveChanges: OleVariant;
begin
	AddStack('TMsOffEd.FormDestroy',Self);
  Rec.SaveToIni;
  InitFIni[fiSave].WriteString('MsOff','Format',
    AnsiUpperCase(FormatGet.MenuName(IntToStr(Rec['Format']))));
  with aSrv[msoEdExcel] do
  	if Assigned(Appl) then with TExcelApplication(Appl) do
      if ApplHide then Quit;
  with aSrv[msoEdWord] do
  	if Assigned(Appl) then with TWordApplication(Appl) do
      if not Visible then begin
        SaveChanges:=wdDoNotSaveChanges; Quit(SaveChanges);
      end;
  lsEditorClear(EditorGet.Items);
  inherited;
  DelStack;
end;

procedure TMsOffEd.PanelEdit1CngKey(Sender: TObject; var tb: TKeyBut);
begin
	AddStack('TMsOffEd.PanelEdit1CngKey',Self);
  inherited;
  with tb do if Key=K_F10 then Caption:='Выполнить';
  DelStack;
end;

procedure TMsOffEd.deEditorFldChange(Sender: TObject;
  const OldVal: Variant; FromShow: Boolean);
begin
  AddStack('TMsOffEd.deEditorFldChange',Self);
  with TFldEdit(Sender) do if NameRecFld='EDTYPE'
  then deEditor.SetReadOnly(['EdFname','EdFmt'],VarValue<>msoEdDefine);
  DelStack;
end;

procedure TMsOffEd.deEditorFldExit(Sender: TObject);
begin
  AddStack('TMsOffEd.deEditorFldExit',Self);
  with TFldEdit(Sender) do if NameRecFld='EDTYPE' then
    if VarValue<>msoEdDefine then deEditor.FldValue['EdFmt']:=FmtEdDef(VarValue);
  DelStack;
end;

procedure TMsOffEd.EFormatChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
var fl: boolean;
	w,h: Single;
begin
	AddStack('TMsOffEd.EFormatChange',Self);
  with aMSOFmt[TMSOFormatList(Rec['FORMAT'])] do begin
    if TPrinterOrientation(Rec['ORIENT'])=poLandscape then begin
      w:=hMM; h:=wMM;
    end
    else begin
      w:=wMM; h:=hMM;
    end;
    fl := wPsz<>wdPaperCustom; EWidth.SetReadOnly(fl,nround(w)); EHeight.SetReadOnly(fl,nround(h));
  end;
  DelStack;
end;

procedure TMsOffEd.EEditorChange;
const aErrd: array[TErrdList] of string = ('Выдавать сообщение','Преобразовать в текст');
	acErrv: TErrvStr = ('неопределённая ошибка','более 230 столбцов в таблице');
var cnt: longint;
  v: TErrvList;
	s,sfmt: string;
  p: PEditorInfo;
  fl: boolean;
  fmt: TMSOFmtList;
begin
  AddStack('TMsOffEd.EEditorChange',Self);
  ted:=msoEdDefine; sfmt:=SetByte(byte(high(aFmtNm))-1);
  if EditorGet.SeekCod(IntToStr(Rec['EDITOR']),cnt) then begin
    p:=PointerObj(EditorGet.Items,cnt); ted:=p.tp; sfmt:=p.fmt;
    if ted<>msoEdDefine then begin
      for v:=low(aErrv) to high(aErrv) do
        if v=ervOverMaxCol
        then aErrv[v]:=StrTran(acErrv[v],IntToStr(aMaxCol[low(aMaxCol)]),IntToStr(aMaxCol[ted]))
        else aErrv[v]:=acErrv[v];
      s:=EErr.Value;
      EErr.Mask:='Действия при ошибках преобразования в таблицу'
        +UnDelim+IfThen(ted=msoEdExcel,aErrd[erdAsk],IfThen(ted=msoEdWord,ArrayAsList(aErrd,mniDlm)))
        +UnDelim+ArrayAsList(aErrv,mniDlm);
      EErr.Value:=s; EFmtChange(EFmt,OldVal,FromShow);
    end;
  end;
  fl:=ted<>msoEdDefine;
  TCheckSpace.SetButEnabled(EFmt,byte(msoFmtDefault),fl); cnt:=IfThen(fl,1);
  for fmt:=Succ(low(aFmtNm)) to high(aFmtNm) do begin
    fl:=GetByte(sfmt,byte(fmt)-1); TCheckSpace.SetButEnabled(EFmt,byte(fmt),fl);
    if fl then Inc(cnt);
  end;
  EFmt.SetReadOnly(cnt<2);
  DelStack;
end;

procedure TMsOffEd.EFmtChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TMsOffEd.EFmtChange',Self);
  fmt:=Rec['FMT']; SaveDialog1.DefaultExt:=aExt[ted,fmt];
  EFile.Mask:=ArrayAsList(['','',IntToStr(IfThen(fmt=msoFmtDefault,byte(ted),byte(high(TMSOEditorList))+byte(fmt)-1))],UnDelim);
  EType.SetReadOnly((ted<>msoEdWord) or (fmt<>msoFmtDefault)); ETypeChange(EType,OldVal,FromShow);
  TFldEdit.SetReadOnly([EReadOnly,ENoTrns],fmt<>msoFmtXls);
  DelStack;
end;

procedure TMsOffEd.EFmtExit(Sender: TObject);
var p: longint;
begin
  AddStack('TMsOffEd.EFmtExit',Self);
  fmt:=Rec['FMT'];
  if not empty(Rec['FILE']) then begin
    p:=RPos('.',Rec['FILE']);
    EFile.VarValue:=IfThen(p=0,Rec['FILE']+'.'+aExt[ted,fmt],LeftStr(Rec['FILE'],p)+aExt[ted,fmt]);
  end;
  DelStack;
end;

procedure TMsOffEd.ETypeChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TMsOffEd.ETypeChange',Self);
  EErr.SetReadOnly((ted=msoEdWord) and (Rec['TrnType']=msoTwText) or (Rec['FMT']<>msoFmtDefault));
  DelStack;
end;

procedure TMsOffEd.EVPageChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TMsOffEd.EVPageChange',Self);
  EPages.SetReadOnly(Rec['VPage']<>GFStrNum);
  DelStack;
end;

function TMsOffEd.EPagesCheck(Sender: TObject): Boolean;
begin
	AddStack('TMsOffEd.EPagesCheck',Self);
  result := not empty(Rec['PAGES']);
  DelStack;
end;

function TMsOffEd.EFileCheck(Sender: TObject): Boolean;
begin
	AddStack('TMsOffEd.EFileCheck',Self);
  result:=not empty(Rec['FILE']);
  if result then begin
  	result:=DirectoryExists(ExtractFilePath(Rec['FILE']));
    if not result then mess_ok(['Отсутствует папка:',Rec['FILE']]);
  end;
  DelStack;
end;

function TMsOffEd.EBrFldCheck(Sender: TObject): Boolean;
begin
	AddStack('TMsOffEd.EBrFldCheck',Self);
  result:=not empty(Rec['FLD']);
  DelStack;
end;

function TMsOffEd.PanelEdit1Valid(Sender: TObject): Boolean;
var j: longint;
  procedure AddPg(n: longint);
  begin
    AddStack('TMsOffEd.PanelEdit1Valid.AddPg',Self);
    if InRange(n,1,TGenForm(Obj).PageCount) then begin
    	aGFPg[j]:=n; Inc(j);
    end;
    DelStack;
  end;
var l,i,n: longint;
  a1: array[1..100] of string;
  a: TNamePrimStr;
  s: string;
label lend;
begin
	AddStack('TMsOffEd.PanelEdit1Valid',Self);
  inherited;
  result:=false;
  s:=Trim(Rec['FILE']);
  if FileExists(s) then if not Ask(['Файл уже существует:',s,'Перезаписать его ?']) then begin
    PanelEdit1.FldFocus:=EFile; goto lend;
  end;
  if Obj is TGenForm then with TGenForm(Obj) do case TGFStrList(Rec['VPAGE']) of
    GFStrCur: begin
      SetLength(aGFPg,1); aGFPg[low(aGFPg)]:=Leaf;
    end;
    GFStrNum: begin
      SetLength(aGFPg,PageCount); l:=ListAsArray(Rec['PAGES'],a1,',',false); j:=0;
      for i:=1 to l do
        if StrDivDlm('-',a1[i],a)
        then for n:=Int0(a[1]) to Int0(a[2]) do AddPg(n)
        else AddPg(Int0(a1[i]));
      SetLength(aGFPg,j);
      if j=0 then begin
        meserr('Введите существующие листы.'); PanelEdit1.FldFocus:=EPages; goto lend;
      end;
    end;
  else
    SetLength(aGFPg,PageCount);
    for i:=low(aGFPg) to high(aGFPg) do aGFPg[i]:=i+1;
  end;
  if Obj is TGenForm then begin
    CurFdp.SaveLeaf;
    if (fmt=msoFmtHtml) and (Length(aGFPg)>1) then lsCol:=TIntegerList.Create([ilsSorted]);
  end;
  try
    result:=not ShowStat(IfThen(Assigned(lsCol),
      'Объединение листов на одну страницу','Преобразование в документ'),StTrans);
  finally
    FreeAndNil(lsCol); alsCol:=nil;
  end;
lend:
  DelStack;
end;

function HtmInch(Inch: Double): string;
var l: longint;
begin
  AddStack('FMsOffEd.HtmInch');
  result:=StrTran(Trim(SpaceStr(Inch*72,16,1)),DecimalSeparator,'.'); l:=Length(result);
  while result[l]='0' do Dec(l);
  if result[l]='.' then Dec(l);
  SetLength(result,l+2); result[l+1]:='p'; result[l+2]:='t';
  DelStack;
end;

function TwipsInch(inch: Double): string;
begin
  AddStack('FMsOffEd.TwipsInch');
  result:=IntToStr(nround(inch*TwipsInInch));
  DelStack;
end;

function TwipsMm(mm: Double): string;
begin
  AddStack('FMsOffEd.TwipsMm');
  result:=TwipsInch(mm/MmInInch);
  DelStack;
end;

function TwipsPix(pix: longint): string;
begin
  AddStack('FMsOffEd.TwipsPix');
  result:=TwipsInch(pix/Screen.PixelsPerInch);
  DelStack;
end;

function ErrAction(Sender: TStat; v: TErrvList = ervOverMaxCol): boolean;
var mr: TModalResult;
  fl: boolean;
  s: string;
begin
  AddStack('FMsOffEd.ErrAction');
  result:=true; fl:=GetByte(sErr,byte(erdAsk),byte(v));
  s:=Format('Лист %d: %s.',[MsOffEd.GF.Leaf,aErrv[v]]);
  mr:=mrNo;
  case ted of
    msoEdExcel: if fl then
      if not Ask([s,'Продолжить ?'],true,'Ошибка преобразования в таблицу') then mr:=mrCancel;
    msoEdWord: begin
      if GetByte(sErr,byte(erdText),byte(v)) then mr:=mrYes;
      if fl then mr:=AskCancel([s,
        'Преобразовать этот лист в текст ?'],mr,'Ошибка преобразования в таблицу');
    end;
  end;
  case mr of
    mrCancel: Sender.Abort;
    mrYes: begin
      trntype:=msoTwText;
      case ted of
        msoEdExcel: eSheet.Cells.Clear;
        msoEdWord: wTbl.Delete;
      end;
    end;
    mrNo: result:=false;
  end;
  lSuccess:=not result;
  DelStack;
end;

procedure TMsOffEd.StTrans;
var wpgSetup: PageSetup;
	epgSetup: Excel97.PageSetup;
  nmHtmStyle: string;
  procedure PageProp(Orient: TPrinterOrientation; Format: TMSOFormatList; w,h,t,b,l,r: longint);
  const aOrient: array[TMSOEditorList,TPrinterOrientation] of TOleEnum =
  	((xlPortrait,xlLandscape)
  	,(wdOrientPortrait,wdOrientLandscape)
    );
		function SzCm(mm: longint): string;
    begin
      AddStack('TMsOffEd.StTrans.PageProp.SzCm',Self);
      result:=HtmInch(mm/MmInInch);
      DelStack;
    end;
  var ost: longint;
  begin
    ost:=AddStack('TMsOffEd.StTrans.PageProp',Self);
    case fmt of
      msoFmtDefault: case ted of
        msoEdExcel: with epgSetup,TExcelApplication(aSrv[ted].Appl) do begin
          PaperSize:=aMSOFmt[Format].ePsz; Orientation:=aOrient[ted,Orient];
          TopMargin:=InchesToPoints(t/MmInInch); BottomMargin:=InchesToPoints(b/MmInInch);
          LeftMargin:=InchesToPoints(l/MmInInch); RightMargin:=InchesToPoints(r/MmInInch);
        end;
        msoEdWord: with wpgSetup,TWordApplication(aSrv[ted].Appl) do begin
          if aMSOFmt[Format].wPsz=wdPaperCustom then begin
            PageWidth:=MillimetersToPoints(IfThen(Orient=poLandscape,h,w));
            PageHeight:=MillimetersToPoints(IfThen(Orient=poLandscape,w,h));
          end
          else
            try
              PaperSize:=aMSOFmt[Format].wPsz;
            except
              SetStack(ost);
              PageWidth:=MillimetersToPoints(IfThen(Orient=poLandscape,h,w));
              PageHeight:=MillimetersToPoints(IfThen(Orient=poLandscape,w,h));
            end;
          Orientation:=aOrient[ted,Orient];
          TopMargin:=MillimetersToPoints(t); BottomMargin:=MillimetersToPoints(b);
          LeftMargin:=MillimetersToPoints(l); RightMargin:=MillimetersToPoints(r);
        end;
      end;
      msoFmtHtml: begin
        fFile.WriteFile([nmHtmStyle,SzCm(w),SzCm(h),IfThen(Orient=poLandscape,'mso-page-orientation:landscape;'),
          t,l,b,r],'@page %s {size:%s %s;%smargin:%dmm %dmm %dmm %dmm;}',[ffoNoq,ffoCR]);
        fFile.WriteFile([nmHtmStyle,nmHtmStyle],'div.%s {page:%s;}',[ffoNoq,ffoCR]);
      end;
      msoFmtRtf: fFile.WriteFile([IfThen(Orient=poLandscape,'\lndscpsxn'),TwipsMm(h),TwipsMm(w),
        TwipsMm(l),TwipsMm(r),TwipsMm(t),TwipsMm(b)],
        '%s\pghsxn%s\pgwsxn%s\marglsxn%s\margrsxn%s\margtsxn%s\margbsxn%s',[ffoCR]);
    end;
    DelStack;
  end;
  procedure GFPageProp(Orient: TPrinterOrientation; Format: TMSOFormatList = msoFormatUser; nParams: longint = NegDef);
  var sz: TSize;
  begin
    AddStack('TMsOffEd.StTrans.GFPageProp',Self);
    ReplNegSelf(nParams,GF.CurParams);
    with GF.Params.Arr[nParams] do begin
      if GF.SizeNoLimit(nParams) then WinSize(sz,
        nround(GF.Width/GF.ScalePrc/GF.aRate[false]),
        nround(GF.Height/GF.ScalePrc/GF.aRate[true]))
      else sz:=SizeMm;
      PageProp(Orient,Format,sz.cX,sz.cY,SpotMm.Top,SpotMm.Bottom,SpotMm.Left,SpotMm.Right);
    end;
    DelStack;
  end;
var sti,stlr: longint;
  function NewStat(const st: TCaption): boolean;
  begin
    AddStack('TMsOffEd.StTrans.NewStat',Self);
    result:=Sender.SayStat('',st,sti/stlr); Inc(sti);
    DelStack;
  end;
  procedure HtmFontProp(const nmStyle: string; Font: TFont; const s: string = '';
  	nowrap: boolean = true; const BorderStyle: string= 'solid');
  var sf: string;
  begin
    AddStack('TMsOffEd.StTrans.HtmFontProp',Self);
    with Font do begin
      if fsUnderline in Style then sf:='underline' else sf:='';
      if fsStrikeOut in Style then sf:=IfThen(sf<>'',sf+' ')+'line-through';
      if sf='' then sf:='none';
      sf:=Format('font-family: "%s"; font-size: %dpt; font-style: %s; font-variant: normal; font-weight: %s; color: %s; text-decoration: %s',
        [Name,Size,IfThen(fsItalic in Style,'italic','normal'),
        IfThen(fsBold in Style,'bold','normal'),ColorHex(Color),sf]);
    end;
    fFile.WriteFile([nmStyle,sf,HtmInch(awln[DefWidth]),ColorHex(DefColor),
      IfThen(nowrap,'; white-space:nowrap'),IfThen(s<>'',';'+s)],
      '.%s {%s; border-width: %s; border-style: '+BorderStyle+'; border-collapse: collapse; border-color: %s; mso-number-format:"\@"%s%s}',
      [ffoCR,ffoNoq]);
    DelStack;
  end;
  procedure wrHtmBody;
  var cl: TColor;
    pn: TRbPanel;
  begin
    AddStack('TMsOffEd.StTrans.wrHtmBody');
    if IsClass(Obj.Parent,TRbPanel,pointer(pn)) then cl:=pn.Color else cl:=clNone;
    THtmlFile(fFile).WriteBody(cl);
    DelStack;
  end;
  procedure RtfColor1(Color: TColor);
  begin
    AddStack('TMsOffEd.StTrans.RtfColor1',Self);
    lsRtfColor.Add(Color); lsRtfRGB.Add(ColorRGB(Color));
    DelStack;
  end;
  procedure RtfFont1(Font: TFont);
  begin
    AddStack('TMsOffEd.StTrans.RtfFont1',Self);
    aFont[nRtfFont]:=Font; lsRtfFont.Add(Font.Name); RtfColor1(Font.Color); Inc(nRtfFont);
    DelStack;
  end;
  procedure RtfFontWrite;
  var i: longint;
  begin
    AddStack('TMsOffEd.StTrans.RtfFontWrite');
    fFile.WriteFile('{\fonttbl',[ffoSP]);
    for i:=0 to lsRtfFont.Count-1 do
      fFile.WriteFile([i,lsRtfFont[i]],'{\f%d\fnil\fcharset204 %s;}',[ffoCR]);
    fFile.WriteFile('}');
    fFile.WriteFile('{\colortbl',[ffoCR]); SetLength(aRtfRGB,lsRtfColor.Count);
    for i:=0 to lsRtfColor.Count-1 do
      lsRtfRGB.Find(ColorRGB(lsRtfColor[i]),aRtfRGB[i]);
    for i:=0 to lsRtfRGB.Count-1 do
      fFile.WriteFile([GetRValue(lsRtfRGB[i]),GetGValue(lsRtfRGB[i]),GetBValue(lsRtfRGB[i])],
      '\red%d\green%d\blue%d;',[ffoCR]);
    fFile.WriteFile('}'); RtfInit;
    DelStack;
  end;
var l,wt: longint;
  awt: TArrInt;
  hFont: TFont;
  hColor,dColor: TColor;
  function BrHead(TitleFont,Font: TFont; FixedColor,Color: TColor): boolean;
  var h: longint;
  begin
    AddStack('TMsOffEd.StTrans.BrHead',Self);
    result:=NewStat('Заголовок'); hFont:=TitleFont; hColor:=FixedColor; dColor:=Color;
    if not result then begin
      case fmt of
        msoFmtDefault: case ted of
          msoEdExcel: begin
            eConvFont(Font,eSheet.Cells.Font);
            eRange(1,1,stlr,l).Borders.LineStyle:=xlContinuous;
            with eRange(1,1,1,l) do begin
              eConvFont(TitleFont,Font);
              if not(Obj is TFindListBox) then HorizontalAlignment:=xlHAlignCenter;
              Interior.Color:=ColorRGB(FixedColor);
            end;
            eRange(2,1,stlr,l).Interior.Color:=ColorRGB(Color);
          end;
          msoEdWord: with aSrv[ted],TWordApplication(Appl),TWordDocument(Doc) do begin
            wConvFont(Font,Selection.Font);
            wTbl:=Tables.Add(Selection.Range,stlr,l);
            wConvFont(TitleFont,wTbl.Rows.First.Range.Font);
            wTbl.Rows.First.Range.Shading.ForegroundPatternColorIndex:=wColorIndex(FixedColor);
            wRange(2,1,stlr,l).Shading.ForegroundPatternColorIndex:=wColorIndex(Color);
          end;
        end;
        msoFmtHtml: begin
          HtmFontProp('T',TitleFont); HtmFontProp('D',Font); wrHtmBody;
          fFile.WriteFile('DIV class=0',[ffoSP]);
          fFile.WriteFile('TABLE class=D border=1 bgcolor='+ColorHex(Color),
            [ffoSP]);
          if not(Obj is TFindListBox) then begin
            fFile.WriteFile('TR bgcolor='+ColorHex(FixedColor),[ffoSP]);
            fFile.WriteFile('',[ffoCR]);
          end;
        end;
        msoFmtRtf: begin
          SetLength(aFont,2); RtfFont1(TitleFont); RtfFont1(Font);
          RtfColor1(FixedColor); RtfColor1(Color); RtfFontWrite; wt:=0; SetLength(awt,l);
        end;
        msoFmtXls: begin
          Canvas.Font.Assign(Font); h:=CanvasMaxH(Canvas); Canvas.Font.Assign(TitleFont);
          while (Canvas.Font.Size>1) and (CanvasMaxH(Canvas)>h) do IncFontSize(Canvas.Font,-1);
        end;
      end;
      XlsSetGlobals(1,[TitleFont,Font],[clBlack,FixedColor,Color],Canvas.Font.Size);
      XlsBeginSheet('1',l,stlr,Rec['FORMAT'],Rec['WIDTH'],Rec['HEIGHT'],
        Rec['TOP'],Rec['BOTTOM'],Rec['LEFT'],Rec['RIGHT'],Rec['ORIENT']);
    end;
    DelStack;
  end;
var nc,nl: longint;
  sRtfBrd: string;
  procedure BrHead1(w: longint; Alignment: TAlignment = taLeftJustify; const DisplayLabel: string = '');
  var opt: TFormatFileOptions;
    s: string;
    l1: boolean;
  begin
    AddStack('TMsOffEd.StTrans.BrHead1',Self);
    case fmt of
      msoFmtDefault: case nl of
        0: SetColWidth(nc,w+IfThen(ted=msoEdWord,4));
        1: case ted of
          msoEdExcel: begin
            eRange(2,nc,stlr).HorizontalAlignment:=aAlgm[false,ted,Alignment];
            eRange(1,nc).Value:=DisplayLabel;
          end;
          msoEdWord: begin
            wTbl.Columns.Item(nc).Select;
            TWordApplication(aSrv[ted].Appl).Selection.ParagraphFormat.Alignment:=aAlgm[false,ted,Alignment];
            if not(Obj is TFindListBox) then with wTbl.Cell(1,nc).Range do begin
              ParagraphFormat.Alignment:=wdAlignParagraphCenter; Text:=DisplayLabel;
            end;
          end;
        end;
      end;
      msoFmtHtml: if (nl=1) and not(Obj is TFindListBox) then fFile.WriteFile('<TD class=T>'+DisplayLabel);
      msoFmtRtf: case nl of
        0: begin
          Inc(wt,w+4); awt[nc-1]:=wt;
        end;
        1: begin
          l1 := nc=1; opt:=IfThen(l1,ffoCR);
          fFile.WriteFile([IfThen(l1,sRtfRowBeg+'\clbrdrl'+sRtfBrd),sRtfBrd,sRtfBrd,sRtfBrd,
            RtfColor(hColor),TwipsPix(awt[nc-1])],'%s\clbrdrt%s\clbrdrr%s\clbrdrb%s%s\cellx%s',opt);
          if not(Obj is TFindListBox) then begin
            if l1 then s:='\pard\intbl'+RtfAlign(taCenter)+RtfFont(0) else s:='';
            fFile.WriteFile([s,DisplayLabel],'%s{%s}\cell',opt);
          end;
        end;
      end;
      msoFmtXls: with TXlsFile(fFile) do case nl of
        0: ColWidths[nc-1]:=Ceil((w+4)*ProcentCol);
        1: if not(Obj is TFindListBox) then WriteCell(0,0,nc-1,nc-1,DisplayLabel,DisplayLabel,0,1,'',taCenter);
      end;
    end;
    DelStack;
  end;
  procedure BrHead2(lFirst: boolean = false);
  var k: longint;
  begin
    AddStack('TMsOffEd.StTrans.BrHead2',Self);
    case fmt of
      msoFmtHtml: fFile.WriteFile('/tr');
      msoFmtRtf: begin
        if not(lFirst and (Obj is TFindListBox)) then fFile.WriteFile('\row');
        if lFirst then begin
          fFile.WriteFile(RtfFont(1));
          fFile.WriteFile(sRtfRowBeg+'\clbrdrl'+sRtfBrd,[ffoCR]);
          for k:=1 to l do
            fFile.WriteFile([sRtfBrd,sRtfBrd,sRtfBrd,
              RtfColor(IfThen((Obj is TStrTable) and (k=1),hColor,dColor)),TwipsPix(awt[k-1])],
              '\clbrdrt%s\clbrdrr%s\clbrdrb%s%s\cellx%s');
        end;
      end;
    end;
    DelStack;
  end;
  function BrStr: boolean;
  begin
    AddStack('TMsOffEd.StTrans.BrStr',Self);
    result:=NewStat(StrNum('Строка: ',nl-1));
    if not result and (fmt=msoFmtHtml) {and not(Obj is TFindListBox)} then begin
      fFile.WriteFile('TR',[ffoSP]); fFile.WriteFile('',[ffoCR]);
    end;
    DelStack;
  end;
var ds: TDataSet;
	aFld: TArrInt;
  procedure BrStr1(Alignment: TAlignment; const s: string; AsHead: boolean = false;
    DataType: TFieldType = ftString);
  const aAlgm: TAlgmStr = ('left','right','center');
    aTime: array[0..3] of char = ('h','n','s','z');
  var st,st1: string;
    f: TField;
    v: variant;
    n: byte;
    fl: boolean;
  begin
    AddStack('TMsOffEd.StTrans.BrStr1',Self);
    case fmt of
      msoFmtDefault: case ted of
        msoEdExcel: with eRange(nl,nc) do begin
          if AsHead then begin
            eConvFont(hFont,Font); Interior.Color:=ColorRGB(hColor);
          end;
          Value:=s;
        end;
        msoEdWord: with wTbl.Cell(nl,nc).Range do begin
          if AsHead then begin
            wConvFont(hFont,Font); Shading.ForegroundPatternColorIndex:=wColorIndex(hColor);
          end;
          Text:=s;
        end;
      end;
      msoFmtHtml: fFile.WriteFile([IfThen(AsHead,'T bgcolor='+ColorHex(hColor),'vd'),aAlgm[Alignment],s],
        '<TD class=%s align=%s>%s');
      msoFmtRtf: begin
        if empty(s) then st:='' else st:=RtfAlign(Alignment)+'{'+s+'}';
        IncD(st,'\cell');
        if AsHead then IncL(st,RtfFont(0),RtfFont(1));
        fFile.WriteFile(st,IfThen(nc=1,ffoCR));
      end;
      msoFmtXls: begin
        UnDataTypeSelf(DataType); st:=''; v:=s;
        case DataType of
          ftInteger,ftFloat: begin
            f:=ds.Fields[aFld[nc-1]]; v:=f.Value;
            if DataType=ftFloat then st:=TFloatField(f).DisplayFormat;
          end;
          ftDate: begin
            f:=ds.Fields[aFld[nc-1]]; st1:=TDateTimeField(f).DisplayFormat; fl:=true;
            for n:=low(aTime) to high(aTime) do if AnsiContainsText(st1,aTime[n]) then begin
              fl:=false; break;
            end;
            if fl then begin
              v:=f.Value; st:=st1;
            end;
          end;
        end;
        n:=IfThen(not AsHead,1);
        TXlsFile(fFile).WriteCell(nl-1,nl-1,nc-1,nc-1,v,s,n,n+1,st,Alignment);
      end;
    end;
    DelStack;
  end;
  procedure BrAutoFit;
  begin
    AddStack('TMsOffEd.StTrans.BrAutoFit',Self);
    case fmt of
      msoFmtDefault: case ted of
        msoEdExcel: eSheet.Columns.AutoFit;
        msoEdWord: wTbl.Columns.AutoFit;
      end;
      msoFmtHtml: begin
        fFile.WriteFile('/table'); fFile.WriteFile('/div');
      end;
    end;
    DelStack;
  end;
  procedure CloseOpened;
  var s: string;
  	ItemIndex,SaveChanges: OleVariant;
  begin
    AddStack('TMsOffEd.StTrans.CloseOpened',Self);
    s:=TrimUpper(Rec['FILE']); ItemIndex:=1;
    case ted of
      msoEdExcel: with aSrv[ted],TExcelApplication(Appl),WorkBooks do
        while ItemIndex<=Count do with Item[ItemIndex] do
          if CorrDir(Path[0])+TrimUpper(Name)=s then begin
            SaveChanges:=wdDoNotSaveChanges; Close(SaveChanges,EmptyParam,EmptyParam,0);
            break;
          end
          else Inc(ItemIndex);
      msoEdWord: with aSrv[ted],TWordApplication(Appl),Documents do
        while ItemIndex<=Count do with Item(ItemIndex) do
          if CorrDir(Path)+TrimUpper(Name)=s then begin
            SaveChanges:=wdDoNotSaveChanges; Close(SaveChanges,EmptyParam,EmptyParam); break;
          end
          else Inc(ItemIndex);
    end;
    DelStack;
  end;
var aGFSepstrFont: TArrByte;
  aGFSepstr: TArrStr;
  lsGFSepstrX,lsGFSepstrY: TList;
  procedure GFPage(nPage: longint);
  var i,l,x,y,w,h: longint;
    pv: PGFObj;
    ax,ay: TArrDbl;
    av: TArrPGFObj;
  begin
    AddStack('TMsOffEd.StTrans.GFPage',Self);
    if nPage<0 then begin
      GF.Open(TGenForm(Obj).FileName,aGFPg[low(aGFPg)]); SetLength(aGFSepstrFont,GF.FontCount);
      for i:=low(aGFSepstrFont) to high(aGFSepstrFont) do if GF.Fonts[i].Prop.AType=fptSepstr then begin
        if not Assigned(lsGFSepstrX) then begin
          lsGFSepstrX:=TList.Create; lsGFSepstrY:=TList.Create;
        end;
        aGFSepstrFont[i]:=GF.FontCount;
        with GF.FontAdd(GF.Fonts[i]).Prop do begin
          AType:=fptNormal; ZeroMemory(@Dop,SizeOf(Dop)); Dop.OnlyDig:=GF.Fonts[i].Prop.Dop.sepstrOnlyDig;
        end;
      end;
    end
    else GF.RestPage(aGFPg[nPage]);
    // Заменить объекты с посимвольным обрамлением на обычные
    if Assigned(lsGFSepstrX) then begin
      SetLength(av,GF.ObjectCount); l:=low(av)-1;
      for i:=0 to GF.ObjectCount-1 do begin
        pv:=GF.PObjects[i];
        if GF.Fonts[pv.Font].Prop.AType=fptSepstr then begin
          Inc(l); av[l]:=pv;
        end;
      end;
      for i:=0 to l do begin
        pv:=av[i]; w:=trunc(pv.MinWidth); h:=trunc(pv.MinHeight);
        if (w>0) and (h>0) then begin
          pv.Font:=aGFSepstrFont[pv.Font]; SetLength(ax,w); SetLength(ay,h);
          RasprOst(ax,FloatMaxDec,(GF.GridX[pv.Right]-GF.GridX[pv.Left])/GF.aRate[false],[rspoEqual]);
          RasprOst(ay,FloatMaxDec,(GF.GridY[pv.Bottom]-GF.GridY[pv.Top])/GF.aRate[true],[rspoEqual]);
          lsGFSepstrY.Clear; lsGFSepstrY.Add(pv);
          for x:=1 to w-1 do begin
            lsGFSepstrX.Clear; lsGFSepstrX.Add(lsGFSepstrY[lsGFSepstrY.Count-1]);
            GF.SelectObjs(lsGFSepstrX,true); GF.DivSelObj(dvRight,[gfdvNoAutoSize]);
            GF.SelectObjs(lsGFSepstrX,false); lsGFSepstrY.Add(GF.PObjects[GF.ObjectCount-1]);
          end;
          y:=LsArrDynamic(pv.Text,aGFSepstr,CRLF); ArrStrAlign(aGFSepstr,y,w,h);
          for y:=0 to h-1 do begin
            for x:=0 to w-1 do with PGFObj(lsGFSepstrY[x])^ do begin
              TypeObj:=toText; Text:=aGFSepstr[y][x+1]; MMetr:=true; MinWidth:=ax[x]; MinHeight:=ay[y];
            end;
            if y<h-1 then begin
              GF.SelectObjs(lsGFSepstrY,true); GF.DivSelObj(dvBottom,[gfdvNoAutoSize]);
              GF.SelectObjs(lsGFSepstrY,false); lsGFSepstrY.Clear;
              for x:=0 to w-1 do lsGFSepstrY.Add(GF.PObjects[GF.ObjectCount-w+x]);
            end;
          end;
          GF.AutoSize; 
        end;
      end;
    end;
    DelStack;
  end;
const aw1: array[1..9] of TMSOWeightRec =
    ((LineWidth:wdLineWidth025pt; Weight:0.25)
    ,(LineWidth:wdLineWidth050pt; Weight:0.5)
    ,(LineWidth:wdLineWidth075pt; Weight:0.75)
    ,(LineWidth:wdLineWidth100pt; Weight:1)
    ,(LineWidth:wdLineWidth150pt; Weight:1.5)
    ,(LineWidth:wdLineWidth225pt; Weight:2.25)
    ,(LineWidth:wdLineWidth300pt; Weight:3)
    ,(LineWidth:wdLineWidth450pt; Weight:4.5)
    ,(LineWidth:wdLineWidth600pt; Weight:6)
    );
  ae1: array[1..3] of XlBorderWeight = (xlThin,xlMedium,xlThick);
  alfmt: array[TMSOFmtList,1..2] of byte = ((1,1),(1,1),(0,1),(0,1));
  aNoTrns: array[TNoTrns] of TXlsOption = (xlsTrnsNum,xlsTrnsDate);
var NewTemplate,ItemIndex,Start: OleVariant;
  bm: TBookMark;
  p,cp,ost,offs,nlv,ic,ir: longint;
  w: Single;
	lsBmp: TStringList;
  lsTxtBmp: TStringListCase;
  lsc,lsr: TStrings;
  FileName: OleVariant;
  fls,s: string;
  po: TPrinterOrientation;
  erng: Excel97.ExcelRange;
  v: variant;
  tn: TTreeNode;
  fl: boolean;
  X,Y: Word;
label lend;
begin
  ost:=AddStack('TMsOffEd.StTrans',Self);
  try
  	if fmt=msoFmtDefault then with aSrv[ted] do begin
      if not Assigned(Appl) then begin
        Appl:=cAppl.Create(Self);
        if ted=msoEdWord then for nl:=low(waWeight) to high(waWeight) do begin
          waWeight[nl].Weight:=TWordApplication(aSrv[msoEdWord].Appl).MillimetersToPoints(nl/10); w:=0; nc:=low(aw1);
          while nc<=high(aw1) do begin
            if (waWeight[nl].Weight>=w) and (waWeight[nl].Weight<=aw1[nc].Weight) then begin
              if (nc>low(aw1)) and (waWeight[nl].Weight-w<aw1[nc].Weight-waWeight[nl].Weight) then Dec(nc);
              waWeight[nl].LineWidth:=aw1[nc].LineWidth; break;
            end;
            w:=aw1[nc].Weight; Inc(nc);
          end;
        end;
        Doc:=cDoc.Create(Self);
        if ted=msoEdExcel then eSheet:=TExcelWorksheet.Create(Self);
      end;
      Appl.Connect;
    end;
  except
    SetStack(ost);
    MsgDlg(aEd[ted]+' не установлен.'); Sender.Abort;
  end;
  if not Sender.Aborted then begin
    lsBmp:=nil; lsTxtBmp:=nil; TxtBmp:=nil; lsGFSepstrX:=nil; lsGFSepstrY:=nil;
    try
      try
        s:=TrimUpper(Rec['FILE']); ItemIndex:=1;
        case fmt of
          msoFmtDefault: case ted of
            msoEdExcel: with aSrv[ted],TExcelApplication(Appl),WorkBooks do begin
              SheetsInNewWorkbook[0]:=IfThen(Obj is TGenForm,Length(aGFPg),1);
              //Visible[0]:=true;
              Visible[0]:=false; ApplHide:=true; CloseOpened;
              with TExcelWorkBook(Doc) do begin
                ConnectTo(Add(EmptyParam,0)); eSheet.ConnectTo(Worksheets[1] as ExcelWorkSheet);
              end;
            end;
            msoEdWord: with aSrv[ted],TWordApplication(Appl),Documents do begin
              Visible:=false; CloseOpened;
              NewTemplate:=false; TWordDocument(Doc).ConnectTo(Add(EmptyParam,NewTemplate));
            end;
          end;
          msoFmtHtml: fFile:=THtmlFile.Create(TmpFile);
          msoFmtRtf: begin
            fFile:=TRtfFile.Create(TmpFile); nRtfFont:=0; lsRtfFont:=SortStrListCreate;
            lsRtfColor:=TIntegerList.Create([ilsSorted]); lsRtfRGB:=TIntegerList.Create([ilsSorted]);
          end;
          msoFmtXls: begin
            fFile:=TXlsFile.Create(TmpFile); TXlsFile(fFile).Canvas:=Canvas;
            if Rec['READONLY'] then Include(TXlsFile(fFile).Options,xlsProtect);
            s:=Rec['NOTRNS'];
            for ic:=low(aNoTrns) to high(aNoTrns) do
              if GetByte(s,ic) then Exclude(TXlsFile(fFile).Options,aNoTrns[ic]);
          end;
        end;
        if tsPage.TabVisible then begin
          if fmt=msoFmtDefault then case ted of
          	msoEdExcel: epgSetup:=eSheet.PageSetup;
          	msoEdWord: wpgSetup:=TWordDocument(aSrv[ted].Doc).PageSetup;
          end;
          nmHtmStyle:='0';
          PageProp(Rec['ORIENT'],Rec['FORMAT'],Rec['WIDTH'],Rec['HEIGHT'],
            Rec['TOP'],Rec['BOTTOM'],Rec['LEFT'],Rec['RIGHT']);
        end;
        s:=Rec['FLD']; nl:=0; l:=0; sti:=1; sRtfBrd:='\brdrs'; fls:='';
        if Obj is TBrowl then with TBrowl(Obj) do begin
          ds:=DataSource.DataSet; SetLength(aFld,ds.FieldCount);
          for nc:=0 to ds.FieldCount-1 do
            if ds.Fields[nc].Visible then begin
              Inc(nl);
              if GetByte(s,nl) then begin
                aFld[l]:=nc; Inc(l);
              end;
            end;
          SetLength(aFld,l); stlr:=MulQueryOwner(ds).RecordCount+1;
          if BrHead(TitleFont,Font,FixedColor,Color) then goto lend;
          for nl:=alfmt[fmt,1] to alfmt[fmt,2] do
            for nc:=1 to l do with ds.Fields[aFld[nc-1]] do
              BrHead1(ColWidths[nc-1],Alignment,DisplayLabel);
          ds.DisableControls; bm:=ds.GetBookMark;
          try
            nl:=1; BrHead2(true);
            Inc(nl); ds.First;
            while not ds.Eof do begin
              if BrStr then break;
              for nc:=1 to l do with ds.Fields[aFld[nc-1]] do begin
                fl:=false;
                for p:=0 to Columns.Count-1 do if Columns[p].Field=ds.Fields[aFld[nc-1]] then begin
                  fl:=GrayCell(Rect0,p,Columns[p],[]); break;
                end;
                BrStr1(Alignment,DisplayText,fl,DataType);
              end;
              BrHead2; ds.Next; Inc(nl);
            end;
            ds.GotoBookMark(bm);
          finally
            ds.FreeBookMark(bm);
          end;
          ds.EnableControls;
          BrAutoFit;
        end
        else if Obj is TStringBrowl then with TStringBrowl(Obj) do begin
          SetLength(aFld,ColZn.Count);
          for nc:=0 to ColZn.Count-1 do with InfoCol[nc] do
            if Length(aName)>0 then
              if aName[0]<>'' then begin
                Inc(nl);
                if GetByte(s,nl) then begin
                  aFld[l]:=nc; Inc(l);
                end;
              end;
          SetLength(aFld,l); stlr:=RowCount-FixedRows+1;
          if BrHead(TitleFont,Font,FixedColor,Color) then goto lend;
          for nl:=alfmt[fmt,1] to alfmt[fmt,2] do
            for nc:=1 to l do with InfoCol[aFld[nc-1]] do
              BrHead1(ColWidths[nc-1],Alignment,ArrayAsList(aName,CRLF));
          BrHead2(true);
          for nl:=2 to stlr do begin
            if BrStr then break;
            for nc:=1 to l do BrStr1(InfoCol[aFld[nc-1]].Alignment,Cells[aFld[nc-1],FixedRows+nl-2]);
            BrHead2;
          end;
          BrAutoFit;
        end
        else if Obj is TFindListBox then with TFindListBox(Obj) do begin
          l:=1; nc:=1; stlr:=Items.Count;
          if BrHead(Font,Font,Color,Color) then goto lend;
          for nl:=alfmt[fmt,1] to min(alfmt[fmt,2],0) do BrHead1(Width);
          BrHead2(true);
          for nl:=1 to stlr do begin
            if BrStr then break;
            BrStr1(taLeftJustify,Items[nl-1]);
            BrHead2;
          end;
          BrAutoFit;
        end
        else if Obj is TStrTable then with TStrTable(Obj) do begin
          if Inverted then begin
            lsc:=HeadY; lsr:=HeadX;
          end
          else begin
            lsc:=HeadX; lsr:=HeadY;
          end;
          SetLength(aFld,lsc.Count);
          for nc:=0 to lsc.Count-1 do
            if GetByte(s,nc+1) then begin
              aFld[l]:=nc; Inc(l);
            end;
          SetLength(aFld,l); Inc(l); stlr:=RowCount-FixedRows+1;
          if BrHead(TitleFont,Font,FixedColor,Color) then goto lend;
          for nl:=alfmt[fmt,1] to alfmt[fmt,2] do
            for nc:=1 to l do begin
              s:='';
              if nc=1 then cp:=0 else cp:=aFld[nc-2]+1;
              for p:=0 to FixedRows-1 do IncD(s,CRLF+Cells[cp,p]);
              BrHead1(ColWidths[cp],AlignCell(cp,nl),Copy(s,lCRLF1,MaxInt));
            end;
          BrHead2(true); ir:=FixedRows;
          for nl:=2 to stlr do begin
            if BrStr then break;
            nc:=1; BrStr1(taLeftJustify,Cells[0,ir],true);
            for nc:=2 to l do begin
              ic:=aFld[nc-2]+1; s:=Cells[ic,ir];
              if ic<FixedCols then BrStr1(taLeftJustify,s,true)
              else begin
                ColRowToXY(ic,ir,X,Y); BrStr1(AlignCell(ic,ir),s,GrayCell(X,Y,Rect0,[]));
              end;
            end;
            BrHead2; Inc(ir);
          end;
          BrAutoFit;
        end
        else if Obj is TTreePrim then with TTreePrim(Obj) do begin
          Self.Canvas.Font.Assign(Font); stlr:=0; offs:=0; IsFirst(tn);
          while Assigned(tn) do begin
            MaxSelf(l,tn.Level); MaxSelf(offs,Self.Canvas,tn.Text); Inc(stlr);
            GetNextSelf(tn);
          end;
          Inc(l,2);
          case fmt of
            msoFmtDefault: case ted of
              msoEdExcel: begin
                eConvFont(Font,eSheet.Cells.Font);
                eConvFont(FontPrim,eRange(1,l,stlr).Font);
                eSheet.Cells.Interior.Color:=ColorRGB(Color);
                eSheet.Cells.HorizontalAlignment:=xlHAlignLeft;
              end;
              msoEdWord: with aSrv[ted],TWordApplication(Appl),TWordDocument(Doc) do begin
                wConvFont(Font,Selection.Font);
                wTbl:=Tables.Add(Selection.Range,stlr,1);
                wTbl.Rows.SpaceBetweenColumns:=0;
                wRange(1,1,stlr).Shading.ForegroundPatternColorIndex:=wColorIndex(Color);
              end;
            end;
            msoFmtHtml: begin
              HtmFontProp('T',Font,'text-align:left',true,'none');
              HtmFontProp('P',FontPrim,'text-align:left',true,'none');
              wrHtmBody;
              fFile.WriteFile('DIV class=0',[ffoSP]);
              fFile.WriteFile('TABLE border=0 bgcolor='+ColorHex(Color),[ffoSP]);
            end;
            msoFmtRtf: begin
              SetLength(aFont,2); RtfFont1(Font); RtfFont1(FontPrim);
              RtfColor1(Color); RtfFontWrite; wt:=0; SetLength(awt,l);
              IncD(sRtfBrd,'\brdrw0'+RtfColor(Color,'brdrcf'));
            end;
          end;
          XlsSetGlobals(1,[Font,FontPrim],[Color]);
          XlsBeginSheet('1',l,stlr,Rec['FORMAT'],Rec['WIDTH'],Rec['HEIGHT'],
            Rec['TOP'],Rec['BOTTOM'],Rec['LEFT'],Rec['RIGHT'],Rec['ORIENT']);
          nl:=0; p:=Self.Canvas.TextWidth('_');
          for nc:=1 to l-2 do BrHead1(p);
          nc:=l-1; BrHead1(offs);
          Self.Canvas.Font.Assign(FontPrim); offs:=0; IsFirst(tn);
          while Assigned(tn) do begin
            MaxSelf(offs,Self.Canvas,NodeInf(tn).Prim); GetNextSelf(tn);
          end;
          nc:=l; BrHead1(offs); nl:=1;
          if fmt=msoFmtRtf then begin
            fFile.WriteFile('\pard\intbl'+RtfAlign(taLeftJustify),[ffoCR]); offs:=-1;
          end;
          IsFirst(tn); p:=0;
          while Assigned(tn) do with tn do begin
//if sti>stlr then break;
            Inc(nl);
            if BrStr then break;
            nlv:=Level;
            case fmt of
              msoFmtDefault: begin
                if nlv>1 then SetMerge(nl-1,1,0,nlv);
                if nlv<l-2 then SetMerge(nl-1,nlv+1,0,l-1);
                case ted of
                  msoEdExcel: begin
                    erng:=eRange(nl-1,nlv+1,0,l-1); erng.NumberFormat:='@'; erng.Value:=Text;
                    eRange(nl-1,l).Value:=NodeInf(tn).Prim;
                  end;
                  msoEdWord: begin
                    nc:=IfThen(nlv=0,1,2); wRange(nl-1,nc).Text:=Text;
                    with wRange(nl-1,nc+1) do begin
                      wConvFont(FontPrim,Font); Text:=NodeInf(tn).Prim;
                    end;
                  end;
                end;
              end;
              msoFmtHtml: begin
                for nc:=0 to nlv-1 do
                  fFile.WriteFile('<TD class=T><span style=''mso-spacerun:yes''>'#160'</span>');
                fFile.WriteFile('<TD class=T'+IfThen(nlv<l-2,StrNum(' colspan=',l-1-nlv))+'>'+Text);
                fFile.WriteFile('<TD class=P>'+NodeInf(tn).Prim);
              end;
              msoFmtRtf: begin
                if offs<>nlv then begin
                  offs:=nlv;
                  fFile.WriteFile(sRtfRowBeg+'\clbrdrl'+sRtfBrd,[ffoCR]);
                  if nlv>0 then fFile.WriteFile(IfThen(nlv>1,'\clvertal')
                    +'\clbrdrt'+sRtfBrd+'\clbrdrr'+sRtfBrd+'\clbrdrb'+sRtfBrd
                    +'\cellx'+TwipsPix(awt[nlv-1]));
                  fFile.WriteFile(IfThen(nlv<l-2,'\clvertal')
                    +'\clbrdrt'+sRtfBrd+'\clbrdrr'+sRtfBrd+'\clbrdrb'+sRtfBrd
                    +'\cellx'+TwipsPix(awt[l-2]));
                  fFile.WriteFile('\clbrdrt'+sRtfBrd+'\clbrdrr'+sRtfBrd+'\clbrdrb'+sRtfBrd
                    +'\cellx'+TwipsPix(awt[l-1]));
                end;
                fFile.WriteFile(IfThen(nlv>0,'\cell')+RtfFont(0)+'{'+Text+'}\cell'
                  +RtfFont(1)+'{'+NodeInf(tn).Prim+'}\cell',[ffoCR]);
              end;
              msoFmtXls: begin
                if nlv>0 then XlsWriteCell(p,p,0,nlv-1,'','',0,0,'',taLeftJustify,taRightJustify,
                  0,true,0,0,0,0,0,0,0,0);
                XlsWriteCell(p,p,nlv,l-2,Text,Text,0,0,'',taLeftJustify,taRightJustify,
                  0,true,0,0,0,0,0,0,0);
                XlsWriteCell(p,p,l-1,l-1,NodeInf(tn).Prim,NodeInf(tn).Prim,1,0,'',taLeftJustify,taRightJustify,
                  0,true,0,0,0,0,0,0,0);
              end;
            end;
            BrHead2; GetNextSelf(tn); Inc(p);
          end;
          if fmt=msoFmtHtml then BrAutoFit;
        end
        else if Obj is TGenForm then begin
        	//GF.SetIntervalBetwRows(IfThen(ted=msoEdWord,0,0));
          GFPage(-1);
					case fmt of
            msoFmtDefault: begin
              if ted=msoEdWord
                then wpgSetup:=TWordDocument(aSrv[ted].Doc).Sections.Item(1).PageSetup;
              TxtBmp:=TBitMap.Create;
            end;
            msoFmtHtml: begin
              with GF.Params do for nc:=low(Arr) to high(Arr) do with Arr[nc] do begin
                nmHtmStyle:=StrNum('S',nc); GFPageProp(Orientation,msoFormatUser,nc);
              end;
              for nc:=0 to GF.FontCount-1 do HtmFontProp(IntToStr(nc),GF.Fonts[nc].Font,
                'text-align:center; vertical-align:middle'{,ted=msoEdWord});
              wrHtmBody; lsBmp:=SortStrListCreate; lsTxtBmp:=TStringListCase.CreateSort;
              TxtBmp:=TBitMap.Create;
            end;
            msoFmtRtf: begin
              GFPageProp(GF.Params.Arr[GF.CurParams].Orientation);
              SetLength(aFont,GF.FontCount);
              for nc:=0 to GF.FontCount-1 do RtfFont1(GF.Fonts[nc].Font);
              for nc:=low(AColor) to high(AColor) do RtfColor1(AColor[nc]);
              RtfFontWrite;
            end;
            msoFmtXls: with GF.Params.Arr[GF.CurParams] do begin
              SetLength(aFont,GF.FontCount);
              for nc:=0 to GF.FontCount-1 do aFont[nc]:=GF.Fonts[nc].Font;
              XlsSetGlobals(Length(aGFPg),aFont,[]);
            end;
          end;
          stlr:=Length(aGFPg); sErr:=Rec['Err'];
          if Assigned(lsCol) then begin
            for nl:=low(aGFPg) to high(aGFPg) do begin
              if NewStat(StrNum('Лист: ',aGFPg[nl])) then goto lend;
              if nl>low(aGFPg) then GFPage(nl);
              for nc:=0 to GF.ColCount do lsCol.Add(GF.GridX[nc]);
            end;
            if lsCol.Count=0 then begin
              Sender.Abort; goto lend;
            end;
            SetLength(alsCol,lsCol.Count); offs:=-1;
            repeat
              Inc(offs); l:=0; p:=lsCol[0]+offs;
              for nc:=0 to lsCol.Count-1 do begin
                if lsCol[nc]>p then begin
                  Inc(l); p:=lsCol[nc]+offs;
                end;
                alsCol[nc]:=l;
              end;
              if l=0 then begin
                Sender.Abort; goto lend;
              end;
              if (fmt=msoFmtDefault) and (offs=0) then
                if l>aMaxCol[ted] then
                  if ErrAction(Sender) then break;
            until (fmt<>msoFmtDefault) or (l<=aMaxCol[ted]);
            GFPage(low(aGFPg)); sti:=1;
            if Sender.SayStat('Преобразование в документ') then goto lend;
          end;
          cp:=-1; nGFLeaf:=low(aGFPg); 
          while nGFLeaf<=high(aGFPg) do begin
            if NewStat(StrNum('Лист: ',aGFPg[nGFLeaf])) then break;
            if nGFLeaf>low(aGFPg) then begin
              GFPage(nGFLeaf);
              case fmt of
                msoFmtDefault: with aSrv[ted] do case ted of
                  msoEdExcel: eSheet.ConnectTo(TExcelWorkBook(Doc).Worksheets[nGFLeaf+1] as ExcelWorkSheet);
                  msoEdWord: with TWordDocument(Doc) do begin
                    Start:=wdSectionNewPage;
                    wpgSetup:=Sections.Add(EmptyParam,Start).PageSetup; Characters.Last.Select;
                  end;
                end;
                msoFmtHtml: fFile.WriteFile('BR style=''page-break-before:always;mso-break-type:section-break''',
                  [ffoCR]);
                msoFmtRtf: begin
                  fFile.WriteFile('\pard\sect',[ffoCR]); RtfInit;
                  if cp<>GF.CurParams then GFPageProp(GF.Params.Arr[GF.CurParams].Orientation);
                end;
                msoFmtXls: TXlsFile(fFile).EndSheet;
              end;
            end;
            if fmt=msoFmtDefault then with GF.Params.Arr[GF.CurParams] do
              case ted of
                msoEdExcel: begin
                  if not StdFormat then raise Exception.CreateFmt(
                    'Невозможно преобразовать лист %d: нестандартный формат',[aGFPg[nGFLeaf]]);
                  //GF.AutoSize;
                  epgSetup:=eSheet.PageSetup; po:=Orientation;
                  if byte(NFormat)>(byte(high(TGFFrmList)) shr 1)
                  then po:=TPrinterOrientation(byte(high(po))-byte(po));
                  GFPageProp(po,aGFFmt[NFormat]);
                  if cp<>GF.CurParams then begin
                    l:=max(1,nround(GridLineWidth/Length(ae1))); nc:=low(ae1); p:=1;
                    for nl:=low(eaWeight) to GridLineWidth do begin
                      if (p>l) and (nc<high(ae1)) then begin
                        Inc(nc); p:=1;
                      end;
                      eaWeight[nl]:=ae1[nc]; Inc(p);
                    end;
                  end;
                end;
                msoEdWord: if cp<>GF.CurParams then GFPageProp(Orientation);
              end;
            cp:=GF.CurParams;
            if ShowStat(' ',StGFPage,[LongInt(@fls),LongInt(lsBmp),LongInt(lsTxtBmp)]) then begin
              Sender.Abort; break;
            end;
            Inc(nGFLeaf);
          end;
          GF.CloseDtg;
        end;
lend:
      except
        on E: Exception do begin
          SetStack(ost);
          MsgDlg(['Ошибка преобразования в документ:',E.Message+'.']);
        end;
      end;
    finally
      if fmt=msoFmtDefault then begin
        SaveToFile;
        if Visible then case ted of
          msoEdExcel: with TExcelApplication(aSrv[ted].Appl) do begin
            Visible[0]:=true; ApplHide:=false;
          end;
          msoEdWord: TWordApplication(aSrv[ted].Appl).Visible:=true;
        end;
      end
      else begin
        if fls<>'' then
          for nc:=0 to lsBmp.Count-1 do
            if GF.lsBitMap.Find(lsBmp[nc],nl)
            then GF.lsBitMap.GetBM(nl).bm.SaveToFile(fls+GF.lsBitMap[nl]+'.bmp');
        fl:=fFile.Update(true);
        //try
          fFile.Free;
        {except
          SetStack(ost);
        end;}
        lsGFSepstrX.Free; lsGFSepstrY.Free;
        if fl then
          try
            if ted<>msoEdDefine then with aSrv[ted] do
              if Visible then begin
                if not Assigned(Appl) then begin
                  Appl:=cAppl.Create(Self); Doc:=cDoc.Create(Self);
                end;
                try
                  Appl.Connect; FileName:=Rec['FILE']; CloseOpened;
                except
                  SetStack(ost);
                  MsgDlg(aEd[ted]+' не установлен.');
                end;
              end;
            while not CopyFileOpt(TmpFile,Rec['FILE'],[cfStat]) do
              if not Ask(['Ошибка записи в файл:',Rec['FILE'],
              'Возможно, файл открыт другим приложением.','','Повторить ?']) then break;
            DelFileAtr(TmpFile); lsBmp.Free; lsTxtBmp.Free; TxtBmp.Free;
            FreeAndNil(lsRtfFont); FreeAndNil(lsRtfColor); FreeAndNil(lsRtfRGB);
            if ted=msoEdDefine then begin
              if Visible then
                if EditorGet.SeekCod(IntToStr(Rec['EDITOR']),nc) then begin
                  s:=PEditorInfo(EditorGet.Items.Objects[nc]).name;
                  if not empty(s) then ShellExecute(0,nil,PChar(s),PChar('"'+string(Rec['FILE'])+'"'),nil,SW_SHOW);
                end;
            end
            else with aSrv[ted] do if Visible then case ted of
              msoEdExcel: with TExcelApplication(Appl),(Doc as TExcelWorkBook),WorkBooks do begin
                ConnectTo(Open(FileName,EmptyParam,EmptyParam,
                  EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,
                  EmptyParam,EmptyParam,EmptyParam,0));
                Visible[0]:=true;
              end;
              msoEdWord: with TWordApplication(Appl),TWordDocument(Doc) do begin
                ConnectTo(Documents.Open(FileName,
                  EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,
                  EmptyParam,EmptyParam,EmptyParam));
                Visible:=true;
              end;
            end;
          except
            SetStack(ost);
          end;
      end;
      if ted<>msoEdDefine then with aSrv[ted] do begin
        FreeAndNil(eSheet); FreeAndNil(Doc);
        if Assigned(Appl) then begin
          Appl.Disconnect; FreeAndNil(Appl);
        end;
      end;
    end;
  end;
  DelStack;
end;

procedure TMsOffEd.PrAddRow;
begin
	AddStack('TMsOffEd.PrAddRow',Self);
  result:=null; wTbl.Rows.Add(EmptyParam);
  DelStack;
end;

procedure TMsOffEd.PrRowHeight;
begin
	AddStack('TMsOffEd.PrRowHeight',Self);
  result:=null;
  case ted of
	  msoEdExcel: eRange(av[0],1).RowHeight:=av[1];
    msoEdWord: wTbl.Rows.Item(av[0]).SetHeight(av[1],wdRowHeightExactly);
  end;
  DelStack;
end;

procedure TMsOffEd.SetColWidth;
begin
  AddStack('TMsOffEd.SetColWidth',Self);
  if (ted=msoEdWord) and (nc>1) then ReOpen('добавление колонки',PrAddCol,[]);
  ReOpen('установка ширины колонки',PrColWidth,[nc,w]);
  DelStack;
end;

procedure TMsOffEd.PrAddCol;
begin
	AddStack('TMsOffEd.PrAddCol',Self);
  result:=null; wTbl.Columns.Add(EmptyParam);
  DelStack;
end;

procedure TMsOffEd.PrColWidth;
var pnt: Single;
begin
	AddStack('TMsOffEd.PrColWidth',Self);
  result:=null; pnt:=PixToPnt(av[1]);
  case ted of
    msoEdExcel: with eRange(1,av[0]) do begin
      if eRateCol=0 then begin
        ColumnWidth:=200; eRateCol:=ColumnWidth/Width;
      end;
      ColumnWidth:=pnt*eRateCol;
    end;
    msoEdWord: wTbl.Columns.Item(av[0]).SetWidth(pnt,wdAdjustSameWidth);
  end;
  DelStack;
end;

procedure TMsOffEd.SetMerge;
begin
  AddStack('TMsOffEd.SetMerge',Self);
  if r2=0 then r2:=r1;
  if c2=0 then c2:=c1;
  if ReOpen('объединение ячеек',PrMerge,[r1,c1,r2,c2,x1,x2,y])
  then ReOpen('объединение выделенных ячеек',PrMergeSel,[r1,c1,r2,c2]);
  DelStack;
end;

procedure TMsOffEd.PrMerge;
var c: Cell;
  i,j,j1,ost: longint;
  w: Double;
begin
	ost:=AddStack('TMsOffEd.PrMerge',Self);
  result:=false;
  case ted of
    msoEdExcel: eRange(av[0],av[1],av[2],av[3]).Merge(EmptyParam);
    msoEdWord: with wTbl do begin
      w:=0;
      if Length(aMerge)>0 then begin
        j:=0;
        for i:=av[4] to av[5] do begin
          j1:=GFTblX(i,av[6]);
          if j1<>j then begin
            j:=j1; IncD(w,Cell(av[0],j).Width);
          end;
        end;
      end;
      try
        c:=Cell(av[0],av[1]); c.Merge(Cell(av[2],av[3]));
        if Length(aMerge)>0 then result := nround(c.Width)<>nround(w);
      except
        SetStack(ost);
        result:=lRaise;
      end;
    end;
  end;
  DelStack;
end;

procedure TMsOffEd.PrMergeSel;
begin
	AddStack('TMsOffEd.PrMergeSel',Self);
  result:=null;
  with TWordDocument(aSrv[ted].Doc) do begin
    Undo(EmptyParam); wRange(av[0],av[1],av[2],av[3]).Select;
    Application.Selection.Cells.Merge;
  end;
  DelStack;
end;

procedure IncD(var d: OleVariant; const d2: OleVariant); overload;
begin
  d:=d+d2;
end;

function TMsOffEd.IsBmp;
begin
  AddStack('TMsOffEd.IsBmp',Self);
  result := (pv.TypeObj in [toBmp,toCalcBmp])
    or (pv.TypeObj=toText) and (GF.Fonts[pv.Font].Prop.AType in [fptBarCode,fptQRCode,fptPDF417]);
  DelStack;
end;

procedure TMsOffEd.TxtBmpPaint;
var oCnv: TCanvas;
  l,t,r,b: longint;
begin
  AddStack('TMsOffEd.TxtBmpPaint',Self);
  TxtBmp.Width:=GF.GridObj(pv^,false); TxtBmp.Height:=GF.GridObj(pv^,true);
  oCnv:=GF.CurCanvas; GF.CurCanvas:=TxtBmp.Canvas;
  l:=GF.GridX[pv.Left]; GF.GridX[pv.Left]:=0;
  r:=GF.GridX[pv.Right]; GF.GridX[pv.Right]:=TxtBmp.Width;
  t:=GF.GridY[pv.Top]; GF.GridY[pv.Top]:=0;
  b:=GF.GridY[pv.Bottom]; GF.GridY[pv.Bottom]:=TxtBmp.Height;
  GF.CalcRate; GF.PaintObj1(pv);
  GF.CurCanvas:=oCnv;
  GF.GridX[pv.Left]:=l; GF.GridX[pv.Right]:=r;
  GF.GridY[pv.Top]:=t; GF.GridY[pv.Bottom]:=b;
  TxtBmp.SaveToFile(fn);
  DelStack;
end;

procedure TMsOffEd.PrObjAdd;
var Anchor,Orient,Left,Top,Width,Height: OleVariant;
  pv: PGFObj;
  f: TGFPackFont;
  sect: Section;
  bm: TGraphic;
  lbm: boolean;
begin
	AddStack('TMsOffEd.PrObjAdd',Self);
  pv:=PointerVar(av[0]); f:=PointerVar(av[1]); result:=1;
  if f.Prop.Angle=90 then result:=2
  else if f.Prop.Angle=270 then result:=3;
  lbm:=IsBmp(pv);
  if lbm then
    if pv.TypeObj in [toBmp,toCalcBmp] then begin
      if GF.bmObj(pv^,bm) then bm.SaveToFile(TmpBmp);
    end
    else TxtBmpPaint(pv,TmpBmp);
  case trntype of
    msoTwTable: if (ted=msoEdExcel) and lbm then with eRange(av[2],av[3],av[4],av[5]) do
      eSheet.Shapes.AddPicture(TmpBmp,msoFalse,msoTrue,Left,Top,Width,Height);
    msoTwText: begin
      Orient:=aTextOrient[trntype,ted,byte(result)];
      Left:=aX[pv.Left]; Width:=aX[pv.Right]-aX[pv.Left];
      Top:=aY[pv.Top]; Height:=aY[pv.Bottom]-aY[pv.Top];
      case ted of
        msoEdExcel: with eSheet.Shapes do
          if lbm
          then AddPicture(TmpBmp,msoFalse,msoTrue,Left,Top,Width,Height)
          else AddTextbox(Orient,Left,Top,Width,Height);
        msoEdWord: with TWordDocument(aSrv[ted].Doc) do begin
          sect:=Sections.Item(Sections.Count); Anchor:=sect.Range;
          if lbm then begin
            IncD(Left,sect.PageSetup.LeftMargin); IncD(Top,sect.PageSetup.TopMargin);
            Shapes.AddPicture(TmpBmp,EmptyParam,EmptyParam,Left,Top,Width,Height,Anchor);
          end
          else Shapes.AddTextbox(Orient,Left,Top,Width,Height,Anchor);
        end;
      end;
    end;
  end;
  DelStack;
end;

procedure TMsOffEd.PrObj;
var h,l,t,r: single;
	Orient,Index: OleVariant;
  fl,lbm: boolean;
  pv: PGFObj;
  f: TGFPackFont;
  alg: THVAlignment;
  alg1: TAlignment;
  i,ct1,cl1,cb1,cr1: longint;
  txt: string;
begin
	AddStack('TMsOffEd.PrObj',Self);
  result:=null; pv:=PointerVar(av[0]); lbm:=IsBmp(pv);
  if not lbm or (ted=msoEdWord) and (trntype=msoTwTable) then begin
    f:=PointerVar(av[1]); Orient:=aTextOrient[trntype,ted,byte(av[2])]; ct1:=av[3]; cl1:=av[4]; cb1:=av[5]; cr1:=av[6];
    alg:=NumToAlgm(pv.Alignment); txt:=GF.ObjText(pv^);
    case trntype of
      msoTwTable: case ted of
        msoEdExcel: with eRange(ct1,cl1,cb1,cr1) do begin
          eConvFont(f.Font,Font); VerticalAlignment:=aAlgm[true,ted,alg.VertAlignment];
          HorizontalAlignment:=aAlgm[false,ted,alg.HorzAlignment];
          Orientation:=Orient; i:=StrCount(txt);
          if i>1 then begin
            GF.Canvas.Font.Assign(f.Font);
            h:=InchToPnt(CanvasMaxH(GF.Canvas)*i/Screen.PixelsPerInch+(i-1)/MmInInch);
            if Height<h then begin
              h:=(h-Height)/(cb1-ct1+1);
              for i:=ct1 to cb1 do with eRange(i,1) do RowHeight:=RowHeight+h;
            end;
          end
          else NumberFormat:='@';
          Value:=StrTran(txt,CRLF,cXlsCRLF);
        end;
        msoEdWord: with wTbl.Cell(ct1,cl1),Range do
          if lbm then with InlineShapes.AddPicture(TmpBmp,EmptyParam,EmptyParam,EmptyParam) do begin
            Width:=PixToPnt(GF.GridX[pv.Right]-GF.GridX[pv.Left]);
            Height:=PixToPnt(GF.GridY[pv.Bottom]-GF.GridY[pv.Top]);
          end
          else begin
            wConvFont(f.Font,Font); VerticalAlignment:=aAlgm[true,ted,alg.VertAlignment];
            ParagraphFormat.Alignment:=aAlgm[false,ted,alg.HorzAlignment];
            Shading.ForegroundPatternColorIndex:=wColorIndex(AColor[pv.Color]);
            Orientation:=Orient; Text:=txt;
          end;
        end;
      msoTwText: begin
        fl := av[2]<>1;
        if fl then begin
          alg1:=alg.VertAlignment; alg.VertAlignment:=alg.HorzAlignment; alg.HorzAlignment:=alg1;
        end;
        case ted of
          msoEdExcel: with eSheet.Shapes do begin
            Index:=Count;
            with Item(Index),TextFrame,Characters(EmptyParam,EmptyParam) do begin
              MarginRight:=0; MarginBottom:=0; MarginTop:=0; MarginLeft:=0; eConvFont(f.Font,Font);
              Text:=txt; HorizontalAlignment:=aAlgm[false,ted,alg.HorzAlignment];
              VerticalAlignment:=aAlgm[true,ted,alg.VertAlignment];
            end;
          end;
          msoEdWord: begin
            l:=0; r:=0; t:=0; h:=0;
            if alg.VertAlignment<>taLeftJustify then begin
              GF.Canvas.Font.Assign(f.Font);
              h:=max(0,IfThen(fl,aX[pv.Right]-aX[pv.Left],aY[pv.Bottom]-aY[pv.Top])
                -PixToPnt(CanvasMaxH(GF.Canvas)*StrCount(txt)));
              if alg.VertAlignment=taCenter then DivD(h,2);
            end;
            if av[2]=1 then t:=h
            else if av[2]=2 then r:=h
            else l:=h;
            with TWordDocument(aSrv[ted].Doc).Shapes do begin
              Index:=Count;
              with Item(Index) do begin
                Fill.ForeColor.RGB:=ColorRGB(AColor[pv.Color]); Line.Visible:=msoFalse;
                with TextFrame,TextRange do begin
                  MarginTop:=t; MarginBottom:=0; MarginLeft:=l; MarginRight:=r; wConvFont(f.Font,Font);
                  Text:=txt; ParagraphFormat.Alignment:=aAlgm[false,ted,alg.HorzAlignment];
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  DelStack;
end;

procedure TMsOffEd.PrObjFill;
type TBrdList = (bdLeft,bdRight,bdTop,bdBottom);
const a: array[TMSOEditorList,TBrdList] of TOleEnum =
	((xlEdgeLeft,xlEdgeRight,xlEdgeTop,xlEdgeBottom)
	,(wdBorderLeft,wdBorderRight,wdBorderTop,wdBorderBottom)
  );
var wBrd: Borders;
	eBrd: Excel97.Borders;
	l: byte;
	function Brd1(bt: TBrdList): boolean;
	var tl: TGFLine;
  	ost: longint;
  begin
    ost:=AddStack('TMsOffEd.PrObjFill.Brd1',Self);
    result:=false;
    if l>1 then begin
    	tl:=aGFLines[l];
    	case ted of
        msoEdExcel: with eBrd.Item[a[ted,bt]] do begin
          LineStyle:=xlContinuous; Color:=ColorRGB(tl.Color); Weight:=eaWeight[tl.Width];
        end;
        msoEdWord: with wBrd.Item(a[ted,bt]) do begin
          LineStyle:=wdLineStyleSingle; ColorIndex:=wColorIndex(tl.Color);
          try
            LineWidth:=waWeight[tl.Width].LineWidth;
          except
            SetStack(ost);
          end;
        end;
      end;
    end;
    DelStack;
  end;
var pv: PGFObj;
	rf: ^TGFFillRec;
  i,ct1,cl1,cb1,cr1: longint;
begin
	AddStack('TMsOffEd.PrObjFill');
  result:=null; pv:=PointerVar(av[0]); rf:=PointerVar(av[1]); ct1:=av[2]; cl1:=av[3]; cb1:=av[4]; cr1:=av[5];
  case ted of
    msoEdExcel: eBrd:=eRange(ct1,cl1,cb1,cr1).Borders;
    msoEdWord: if (ct1=cb1) and (cl1=cr1)
      then wBrd:=wTbl.Cell(ct1,cl1).Borders
      else wBrd:=wRange(ct1,cl1,cb1,cr1).Borders;
  end;
  pv.Left:=aCol[pv.Left]; pv.Right:=aCol[pv.Right];
  pv.Top:=aRow[pv.Top]; pv.Bottom:=aRow[pv.Bottom];
  l:=rf.y[pv.Left,pv.Bottom];
  for i:=pv.Top+1 to pv.Bottom-1 do
    if rf.y[pv.Left,i]<>l then begin
      l:=0; break;
    end;
  if Brd1(bdLeft) then for i:=pv.Top+1 to pv.Bottom do rf.y[pv.Left,i]:=0;
  l:=rf.y[pv.Right,pv.Bottom];
  for i:=pv.Top+1 to pv.Bottom-1 do
    if rf.y[pv.Right,i]<>l then begin
      l:=0; break;
    end;
  if Brd1(bdRight) then for i:=pv.Top+1 to pv.Bottom do rf.y[pv.Right,i]:=0;
  l:=rf.x[pv.Top,pv.Right];
  for i:=pv.Left+1 to pv.Right-1 do
    if rf.x[pv.Top,i]<>l then begin
      l:=0; break;
    end;
  if Brd1(bdTop) then for i:=pv.Left+1 to pv.Right do rf.x[pv.Top,i]:=0;
  l:=rf.x[pv.Bottom,pv.Right];
  for i:=pv.Left+1 to pv.Right-1 do
    if rf.x[pv.Bottom,i]<>l then begin
      l:=0; break;
    end;
  if Brd1(bdBottom) then for i:=pv.Left+1 to pv.Right do rf.x[pv.Bottom,i]:=0;
  DelStack;
end;

procedure TMsOffEd.PrLineAdd;
var Anchor: OleVariant;
	x1,y1,x2,y2: single;
  r: TRect;
begin
	AddStack('TMsOffEd.PrLineAdd',Self);
  result := av[3]>1;
  if result and (trntype=msoTwText) then begin
    if av[4] then r:=Rect(0,1,0,2) else r:=Rect(1,0,2,0);
  	x1:=aX[Word(av[r.Left])]; y1:=aY[Word(av[r.Top])];
  	x2:=aX[Word(av[r.Right])]; y2:=aY[Word(av[r.Bottom])];
    result := (x1<>x2) or (y1<>y2);
    if result then case ted of
      msoEdExcel: eSheet.Shapes.AddLine(x1,y1,x2,y2);
    	msoEdWord: with TWordDocument(aSrv[ted].Doc) do begin
        Anchor:=Sections.Item(Sections.Count).Range; Shapes.AddLine(x1,y1,x2,y2,Anchor);
      end;
    end;
  end;
  DelStack;
end;

procedure TMsOffEd.PrLine;
var tl: TGFLine;
	Index: OleVariant;
begin
	AddStack('TMsOffEd.PrLine',Self);
  result:=false; tl:=aGFLines[byte(av[0])];
  if ted=msoEdWord then with TWordDocument(aSrv[ted].Doc).Shapes do begin
    Index:=Count;
    with Item(Index).Line do begin
      ForeColor.RGB:=ColorRGB(tl.Color); Weight:=waWeight[tl.Width].Weight;
    end;
  end;
  DelStack;
end;

function SortTopLeft(p: pointer; fi,si: longint; sortID: TSortID): boolean;
var ao: ^TArrPGFObj;
  v: PGFObj;
  i: longint;
begin
  result:=false; ao:=p;
  case sortID of
    sort1MORE2: with MsOffEd do begin
      i:=aRow[ao^[fi].Top]-aRow[ao^[si].Top];
      if i=0 then i:=aCol[ao^[fi].Left]-aCol[ao^[si].Left];
      result := i>0;
    end;
    sortEXCHANGE: begin
      v:=ao^[fi]; ao^[fi]:=ao^[si]; ao^[si]:=v;
    end;
  end;
end;

function TMsOffEd.ReOpen;
var FileName: OleVariant;
  ost: longint;
begin
  ost:=AddStack('TMsOffEd.ReOpen',Self);
  lRaise:=false;
  while true do begin
    try
      Proc(av,result); break;
    except
      on E: Exception do begin
        if lRaise then raise;
        SetStack(ost);
        SaveToFile;
        with aSrv[ted] do case ted of
          msoEdExcel: eSheet.ConnectTo(TExcelWorkBook(Doc).Worksheets[nGFLeaf+1] as ExcelWorkSheet);
          msoEdWord: with TWordDocument(Doc) do begin
            TWordDocument(aSrv[ted].Doc).Close; FileName:=Rec['FILE'];
            ConnectTo(TWordApplication(aSrv[ted].Appl).Documents.Open(FileName,
              EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,
              EmptyParam,EmptyParam,EmptyParam));
            if trntype=msoTwTable then wTbl:=Tables.Item(Tables.Count);
          end;
        end;
      end;
    end;
    lRaise:=true;
  end;
  DelStack;
end;

function TMsOffEd.rfX;
begin
  AddStack('TMsOffEd.rfX',Self);
  case trntype of
    msoTwTable: result:=aCol[i];
    msoTwText: result:=GF.GridX[i];
  else result:=0; //Return value of function might be undefined
  end;
  DelStack;
end;

function TMsOffEd.rfY;
begin
  AddStack('TMsOffEd.rfY',Self);
  case trntype of
    msoTwTable: result:=aRow[i];
    msoTwText: result:=GF.GridY[i];
  else result:=0; //Return value of function might be undefined
  end;
  DelStack;
end;

function TMsOffEd.Line1;
const a: TArrBoolStr = ('горизонтальной','вертикальной');
begin
  AddStack('TMsOffEd.Line1',Self);
  if ReOpen('добавление '+a[lv]+' линии',PrLineAdd,[p,cl,nto,n,lv])
  then result:=ReOpen('установка свойств '+a[lv]+' линии',PrLine,[n])
  else result:=false;
  DelStack;
end;

procedure TMsOffEd.pvFont;
begin
  AddStack('TMsOffEd.pvFont',Self);
  f:=GF.Fonts[pv.Font];
  if GF.ALine(pv^) then begin
    GF.Canvas.Font.Assign(f.Font); lv:=false;
    pv.Text:=astolin(Canvas,pv.Text,GF.GridObj(pv^,false));
  end;
  DelStack;
end;

procedure TMsOffEd.LineXY;
  procedure LineX(t,l,r: longint; var n: byte);
  begin
    AddStack('TMsOffEd.LineXY.LineX',Self);
    t:=aRow[t]; l:=aCol[l]; Inc(l); n:=rf.x[t,l];
    while l<aCol[r] do begin
      Inc(l);
      if rf.x[t,l]<>n then begin
        n:=0; break;
      end;
    end;
    //n:=rf.x[aRow[t],aCol[r]];
    DelStack;
  end;
  procedure LineY(l,t,b: longint; var n: byte);
  begin
    AddStack('TMsOffEd.LineXY.LineY',Self);
    l:=aCol[l]; t:=aRow[t]; Inc(t); n:=rf.y[l,t];
    while t<aRow[b] do begin
      Inc(t);
      if rf.y[l,t]<>n then begin
        n:=0; break;
      end;
    end;
    //n:=rf.y[aCol[l],aRow[b]];
    DelStack;
  end;
begin
  AddStack('TMsOffEd.LineXY',Self);
  LineX(pv.Top,pv.Left,pv.Right,lt);
  LineX(pv.Bottom,pv.Left,pv.Right,lb);
  LineY(pv.Left,pv.Top,pv.Bottom,ll);
  LineY(pv.Right,pv.Top,pv.Bottom,lr);
  DelStack;
end;

procedure TMsOffEd.HtmLine;
var s1,sv1: string;
  tl: TGFLine;
begin
  AddStack('TMsOffEd.HtmLine',Self);
  if n<>nLnDef then begin
    sv1:=DlmBetween('border',sv,'-')+'-';
    if n>1 then begin
      tl:=aGFLines[n];
      s1:=DlmBetween(IfThen(tl.Width<>DefWidth,sv1+'width:'+HtmInch(tl.Width/MmInInch/10)),
        IfThen(tl.Color<>DefColor,sv1+'color:'+ColorHex(tl.Color)),';');
    end
    else s1:=sv1+'style:none';
    DlmBetwSelf(s,s1,';');
  end;
  DelStack;
end;

procedure TMsOffEd.XlsSetGlobals;
begin
  AddStack('TMsOffEd.XlsSetGlobals',Self);
  if fmt=msoFmtXls then TXlsFile(fFile).SetGlobals(CountSheet,acFont,aColor,SizeFontHead);
  DelStack;
end;

procedure TMsOffEd.XlsBeginSheet;
begin
  AddStack('TMsOffEd.XlsBeginSheet',Self);
  case fmt of
    msoFmtDefault: if ted=msoEdExcel then eSheet.Name:=Name;
    msoFmtXls: TXlsFile(fFile).BeginSheet(Name,ColCount,RowCount,aMSOFmt[TMsoFormatList(Format)].ePsz,w,h,t,b,l,r,orient);
  end;
  DelStack;
end;

procedure TMsOffEd.XlsWriteCell;
begin
  AddStack('TMsOffEd.XlsWriteCell',Self);
  if fmt=msoFmtXls then TXlsFile(fFile).WriteCell(Row1,Row2,Col1,Col2,Value,ValueAsStr,nFont,nColor,Format,
    algmHorz,algmVert,Angle,AdjustWH,wTop,nclTop,wLeft,nclLeft,wBottom,nclBottom,wRight,nclRight);
  DelStack;
end;

procedure TMsOffEd.StGFPage;
var j,l,ct: longint;
  ao: TArrPGFObj;
  lsRtfMerge: TIntegerList;
  procedure WrPriorRow;
    function RtfLine(t: char; l: byte): string;
    var tl: TGFLine;
    begin
      AddStack('TMsOffEd.StGFPage.WrPriorRow.RtfLine',Self);
      if l>1 then begin
        tl:=aGFLines[l];
        result:='\clbrdr'+t+'\brdrs\brdrw'+TwipsMm(tl.Width/10)+RtfColor(tl.Color,'brdrcf');
      end
      else result:='';
      DelStack;
    end;
  var nMrg,vb1: longint;
    n: byte;
  	pv: PGFObj;
    procedure RtfColMerge(ro: Word);
    var r: Word;
      fl: boolean;
    	pv: PGFObj;
    begin
      AddStack('TMsOffEd.StGFPage.WrPriorRow.RtfColMerge',Self);
      if n<3 then while nMrg<lsRtfMerge.Count do begin
        r:=lsRtfMerge[nMrg];
        if r>ro then break;
        fl:=true; pv:=lsRtfMerge.PointerObj(nMrg);
        case n of
          1: begin
            LineXY(pv);
            if aRow[pv.Bottom]=vb1 then fFile.WriteFile(RtfLine('b',lb));
            fFile.WriteFile([RtfLine('l',ll),RtfLine('r',lr),TwipsPix(GF.GridX[r]-GF.GridX[0])],
              '\clvmrg%s%s\cellx%s');
          end;
          2: begin
            fFile.WriteFile('\cell');
            if aRow[pv.Bottom]=vb1 then begin
              lsRtfMerge.Delete(nMrg); fl:=false;
            end;
          end;
        end;
        if fl then Inc(nMrg);
      end;
      DelStack;
    end;
  const aa: TAlgmStr = ('t','b','c');
  var i,k,ltxt,vt,vb,vl,vr: longint;
    s,txt: string;
    alg: TAlignment;
    fl: boolean;
  begin
    AddStack('TMsOffEd.StGFPage.WrPriorRow',Self);
    case fmt of
      msoFmtHtml: if ct>=0 then fFile.WriteFile('/tr');
      msoFmtRtf: if l>=0 then begin
        pv:=ao[l]; vb1:=pv.Top;
        while aRow[vb1]=aRow[pv.Top] do Inc(vb1);
        fFile.WriteFile([sRtfRowBeg,TwipsPix(GF.GridY[vb1]-GF.GridY[pv.Top])],'%s\trrh-%s',[ffoCR]);
        vb1:=aRow[vb1];
        for n:=1 to 3 do begin
          nMrg:=0;
          for i:=l to j-1 do begin
            pv:=ao[i]; vt:=aRow[pv.Top]; vb:=aRow[pv.Bottom]; vl:=aCol[pv.Left]; vr:=aCol[pv.Right];
            if (vb>vt) and (vr>vl) then begin
              RtfColMerge(pv.Left);
              case n of
                1: begin
                  LineXY(pv);
                  if vb>vb1 then s:='\clvmgf' else s:=RtfLine('b',lb);
                  fFile.WriteFile([aa[NumToAlgm(pv.Alignment).VertAlignment],
                    RtfLine('l',ll),RtfLine('r',lr),RtfLine('t',lt),s,RtfColor(AColor[pv.Color]),
                    TwipsPix(GF.GridX[pv.Right]-GF.GridX[0])],'\clvertal%s%s%s%s%s%s\cellx%s');
                end;
                2: begin
                  txt:=SubStr(TextCRLF(GF.ObjText(pv^)),1,-lCRLF);
                  s:=IfThen(nRtfFont<0,'\pard\intbl');
                  if empty(txt) then txt:=''
                  else begin
                    alg:=NumToAlgm(pv.Alignment).HorzAlignment;
                    if alg=taRightJustify then TrimLeftSelf(txt)
                    else begin
                      k:=0; ltxt:=Length(txt);
                      while k<ltxt do
                        if txt[k+1]=' ' then Inc(k) else break;
                      if k>0 then StuffStrSelf(txt,1,k,DupeString('\~',k));
                    end;
                    if alg=taLeftJustify then TrimRightSelf(txt)
                    else begin
                      k:=0; ltxt:=Length(txt);
                      while k<ltxt do
                        if txt[ltxt-k]=' ' then Inc(k) else break;
                      if k>0 then StuffStrSelf(txt,ltxt-k+1,k,DupeString('\~',k));
                    end;
                    fl:=GF.OnWidth(pv^); StrTranSelf(txt,CRLF,IfThen(fl,' ','}\par{'));
                    k:=GF.RowBetween(pv^);
                    if k<>0 then Inc(k,nround(GF.Fonts[pv.Font].Prop.Height));
                    IncL(txt,RtfFont(pv.Font,k)+RtfAlign(alg,fl)+'{','}');
                  end;
                  fFile.WriteFile(s+txt+'\cell');
                end;
                3: if vb>vb1 then lsRtfMerge.Add(pv.Right,pv);
              end;
            end;
          end;
          RtfColMerge(MaxWord);
          case n of
            1: fFile.WriteFile('',[ffoCR]);
            2: fFile.WriteFile('\row');
          end;
        end;
      end;
    end;
    DelStack;
  end;
  procedure XlsFill(var l: byte; var cl: longint);
  begin
    AddStack('TMsOffEd.StGFPage.XlsFill',Self);
    cl:=(l-2) div MaxLineWidth; l:=IfThen(l>1,aGFLines[lt].Width);
    DelStack;
  end;
const aHtmAlgm: array[1..2,TLeftRight] of string =
	(('left','right')
	,('top','bottom')
  );
var ost,i,offs,cr,cb,cl1,ct1,cr1,cb1,lo: longint;
  Orientation: byte;
  clr: TColor;
  alg: THVAlignment;
  txt,vs: string;
  fl: boolean;
  v: variant;
  dt: TDateTime;
  d: Extended;
  pFls: PString;
  lsTxtBmp: TStringListCase;
label lend,lend1;
begin
	ost:=AddStack('TMsOffEd.StGFPage',Self);
  try
    trntype:=TMSOTrnType(IfThen((ted=msoEdWord) and (fmt=msoFmtDefault),Rec['TrnType'],byte(msoTwTable)));
    repeat
      lSuccess:=true; Sender.ClearTime; GF.GetArrFill(rf);
      if Sender.SayStat('Преобразование '+awType[trntype]) then break;
      lsRtfMerge:=nil; aMerge:=nil;
      case trntype of
        msoTwTable: begin
          SetLength(aCol,GF.ColCount+1); SetLength(aRow,GF.RowCount+1);
          if ted=msoEdWord then SetLength(aMerge,GF.RowCount+1);
          if fmt=msoFmtRtf then lsRtfMerge:=TIntegerList.Create([ilsSorted]);
        end;
        msoTwText: begin
          SetLength(aX,GF.ColCount+1); SetLength(aY,GF.RowCount+1);
        end;
      end;
      try
        case trntype of
          msoTwTable: begin
            wTbl:=nil; l:=0; p:=GF.GridY[0]; aCol[0]:=0; aRow[0]:=0; fl:=false;
            for j:=1 to GF.RowCount do begin
              if Sender.SayStat('',Format('Строка: %d из %d',[j,GF.RowCount]),j/GF.RowCount)
              then goto lend;
              if GF.GridY[j]<>p then begin
                if (ted=msoEdWord) and (fmt=msoFmtDefault) and (l=0) then begin
                  wTbl:=TWordDocument(aSrv[ted].Doc).Tables.Add(
                    TWordApplication(aSrv[ted].Appl).Selection.Range,1,1);
                  wTbl.Borders.Item(wdBorderTop).LineStyle:=wdLineStyleNone;
                  wTbl.Borders.Item(wdBorderLeft).LineStyle:=wdLineStyleNone;
                  wTbl.Borders.Item(wdBorderBottom).LineStyle:=wdLineStyleNone;
                  wTbl.Borders.Item(wdBorderRight).LineStyle:=wdLineStyleNone;
                  wTbl.Rows.SpaceBetweenColumns:=0;
                end;
                Inc(l);
                if fmt=msoFmtDefault then begin
                  if (ted=msoEdWord) and (l>1) then ReOpen('добавление строки',PrAddRow,[]);
                  ReOpen('установка высоты строки',PrRowHeight,[l,PixToPnt(GF.GridY[j]-p)]);
                end;
                p:=GF.GridY[j];
              end;
              aRow[j]:=l;
            end;
            if l=0 then fl:=true;
            if Assigned(lsCol) then begin
              l:=0;
              for j:=0 to GF.ColCount do begin
                aCol[j]:=alsCol[lsCol.IndexOf(GF.GridX[j])]; MaxSelf(l,aCol[j]);
              end;
              j:=Length(rf.y); Inc(l);
              if l>j then begin
                SetLength(rf.y,l); offs:=Length(rf.y[0]);
                for j:=j to l-1 do SetLength(rf.y[j],offs);
                for j:=low(rf.x) to high(rf.x) do SetLength(rf.x[j],l);
              end;
            end
            else begin
              offs:=-1;
              repeat
                Inc(offs); l:=0; p:=GF.GridX[0]+offs;
                for j:=1 to GF.ColCount do begin
                  if GF.GridX[j]>p then begin
                    Inc(l); p:=GF.GridX[j]+offs;
                  end;
                  aCol[j]:=l;
                end;
                if l=0 then begin
                  fl:=true; break;
                end;
                if (fmt=msoFmtDefault) and (offs=0) then
                  if l>aMaxCol[ted] then
                    if ErrAction(Sender) then break;
              until (fmt<>msoFmtDefault) or (l<=aMaxCol[ted]);
            end;
            with GF.Params.Arr[GF.CurParams] do begin
              if StdFormat then p:=aGFFmt[NFormat] else p:=msoFormatUser;
              XlsBeginSheet(LeftStr(DlmBetween(IntToStr(GF.Leaf)+')',DelTrim(StrTran(GF.PageName[GF.Leaf],
                [':','\','/','?','*','[',']'],
                [' ',' ',' ',' ',' ',' ',' '])),' '),31),
                aCol[GF.ColCount],aRow[GF.RowCount],p,SizeMm.cX,SizeMm.cY,
                SpotMm.Top,SpotMm.Bottom,SpotMm.Left,SpotMm.Right,Orientation);
            end;
            if fl then goto lend;
            case fmt of
              msoFmtDefault: begin
                if trntype=msoTwText then continue;
                if Sender.Aborted then break;
                l:=0; p:=GF.GridX[0]; j:=1;
                while j<=GF.ColCount do begin
                  if Sender.SayStat('',Format('Колонка: %d из %d',[j,GF.ColCount]),j/GF.ColCount)
                  then goto lend;
                  if aCol[j]<>l then begin
                    Inc(l); n:=GF.GridX[j];
                    while j<GF.ColCount do begin
                      if aCol[j+1]<>l then break;
                      Inc(j);
                    end;
                    SetColWidth(l,GF.GridX[j]-p); p:=n;
                  end;
                  Inc(j);
                end;
                if ted=msoEdWord then begin
                  sel:='';
                  for j:=1 to aCol[GF.ColCount] do SetBit(sel,j,true);
                  InitArr(aMerge,1,aRow[GF.RowCount]);
                end;
              end;
              msoFmtXls: begin
                p:=0; l:=0; i:=0;
                for j:=1 to GF.ColCount do
                  if aCol[j]<>aCol[p] then begin
                    cr:=nround((GF.GridX[j]-GF.GridX[0])*TXlsFile(fFile).ProcentCol);
                    TXlsFile(fFile).ColWidths[i]:=cr-l; l:=cr;
                    p:=j; Inc(i);
                  end;
                ct:=i; p:=0; l:=0; i:=0;
                for j:=1 to GF.RowCount do
                  if aRow[j]<>aRow[p] then begin
                    cr:=nround((GF.GridY[j]-GF.GridY[0])*TwipsInInch/Screen.PixelsPerInch);
                    TXlsFile(fFile).RowHeights[i]:=cr-l; l:=cr;
                    p:=j; Inc(i);
                  end;
              end;
            end;
          end;
          msoTwText: begin
            for i:=0 to GF.RowCount do aY[i]:=PixToPnt(GF.GridY[i]-GF.Spot.Top);
            for i:=0 to GF.ColCount do aX[i]:=PixToPnt(GF.GridX[i]-GF.Spot.Left);
          end;
        end;
        i:=0;
        while i<=GF.RowCount do begin
          n:=i; l:=rfY(i); Inc(i);
          while (i<=GF.RowCount) and (rfY(i)=l) do begin
            for j:=1 to GF.ColCount do
              if rf.x[i,j]>1 then begin
                rf.x[n,j]:=rf.x[i,j]; rf.x[i,j]:=0;
              end;
            if (trntype=msoTwText) and (n>0) then
              for j:=0 to GF.ColCount do rf.y[j,i]:=rf.y[j,n];
            Inc(i);
          end;
          if trntype=msoTwTable then begin
            ct:=-1;
            for j:=1 to GF.ColCount do
              if aCol[j]>ct then begin
                ct:=aCol[j]; rf.x[l,ct]:=rf.x[n,j];
              end;
          end;
        end;
        i:=0;
        while i<=GF.ColCount do begin
          n:=i; l:=rfX(i); Inc(i);
          while (i<=GF.ColCount) and (rfX(i)=l) do begin
            for j:=1 to GF.RowCount do
              if rf.y[i,j]>1 then begin
                rf.y[n,j]:=rf.y[i,j]; rf.y[i,j]:=0;
              end;
            if (trntype=msoTwText) and (n>0) then
              for j:=0 to GF.RowCount do rf.x[j,i]:=rf.x[j,n];
            Inc(i);
          end;
          if trntype=msoTwTable then begin
            ct:=-1;
            for j:=1 to GF.RowCount do
              if aRow[j]>ct then begin
                ct:=aRow[j]; rf.y[l,ct]:=rf.y[n,j];
              end;
          end;
        end;
        case fmt of
          msoFmtDefault: begin
            try
              i:=1; ct1:=0; cb1:=0; cl1:=0; cr1:=0;
              for j:=0 to GF.ObjectCount-1 do begin
                if Sender.SayStat('',Format('Объект: %d из %d',[i,GF.ObjectCount]),i/GF.ObjectCount)
                then goto lend1;
                Inc(i); pv:=GF.PFillObj(j);
                if pv.State in [osHide,osSave] then continue;
                if (rfX(pv.Right)>rfX(pv.Left)) and (GF.GridY[pv.Bottom]>GF.GridY[pv.Top]) then begin
                  if trntype=msoTwTable then begin
                    while (pv.Top<pv.Bottom)
                      and ((aRow[pv.Top+1]=0) or (aRow[pv.Top]=aRow[pv.Top+1])) do Inc(pv.Top);
                    while (pv.Left<pv.Right)
                      and ((aCol[pv.Left+1]=0) or (aCol[pv.Left]=aCol[pv.Left+1])) do Inc(pv.Left);
                  end;
                  pvFont;
                  if pv.Text<>CRLF then RightSelfDel(pv.Text,CRLF);
                  if trntype=msoTwTable then begin
                    cl1:=GFTblX(pv.Left+1,pv.Top+1); ct1:=GFTblY(pv.Top+1);
                    cr1:=GFTblX(pv.Right,pv.Bottom); cb1:=GFTblY(pv.Bottom);
                  end;
                  if not empty(pv.Text) then Orientation:=ReOpen('добавление объекта',PrObjAdd,
                    [LongInt(pv),LongInt(f),ct1,cl1,cb1,cr1]);
                  if (trntype=msoTwTable) and not((ted=msoEdWord) and empty(pv.Text))
                  and ((cb1>ct1) or (cb1=ct1) and (cr1>cl1)) then begin
                    SetMerge(ct1,cl1,cb1,cr1,pv.Left+1,pv.Right,pv.Top+1);
                    if ted=msoEdWord then begin
                      ct:=aRow[pv.Top+1]; cb:=aRow[pv.Bottom];
                      cl:=aCol[pv.Left+1]; cr:=aCol[pv.Right]; n:=ct;
                      while n<=cb do begin
                        for l:=cl to cr do SetBit(aMerge[n],l,true);
                        Inc(n);
                      end;
                      SetBit(aMerge[ct],cl,false); cb1:=ct1; cr1:=cl1;
                    end;
                  end;
                  if not empty(pv.Text) then ReOpen('установка свойств объекта',PrObj,
                    [LongInt(pv),LongInt(f),Orientation,ct1,cl1,cb1,cr1]);
                  if trntype=msoTwTable then ReOpen('обрамление объекта',PrObjFill,
                    [LongInt(pv),LongInt(@rf),ct1,cl1,cb1,cr1]);
                end;
              end;
              DelFileAtr(TmpBmp);
              if trntype=msoTwText then begin
                i:=1; l:=GF.ColCount+1; lv:=true; p:=0;
                while p<=GF.ColCount do begin
                  if Sender.SayStat('',Format('Вертикальное обрамление: %d из %d',[i,l]),i/l)
                  then goto lend1;
                  Inc(i); n:=0; cl:=0;
                  for j:=1 to GF.RowCount do begin
                    if rf.y[p,j]<>n then begin
                      if Line1(j-1) then goto lend1;
                      n:=rf.y[p,j]; cl:=j-1;
                    end;
                  end;
                  if Line1(GF.RowCount) then goto lend1;
                  Inc(p);
                end;
                i:=1; l:=GF.RowCount+1; lv:=false; p:=0;
                while p<=GF.RowCount do begin
                  if Sender.SayStat('',Format('Горизонтальное обрамление: %d из %d',[i,l]),i/l)
                  then goto lend1;
                  Inc(i); n:=0; cl:=0;
                  for j:=1 to GF.ColCount do begin
                    if rf.x[p,j]<>n then begin
                      if Line1(j-1) then goto lend1;
                      n:=rf.x[p,j]; cl:=j-1;
                    end;
                  end;
                  if Line1(GF.ColCount) then goto lend1;
                  Inc(p);
                end;
              end;
lend1:
            except
              if trntype=msoTwText then raise;
              SetStack(ost);
              ErrAction(Sender,ervOther);
            end;
          end;
          msoFmtHtml,msoFmtRtf,msoFmtXls: begin
            l:=-1;
            if fmt=msoFmtHtml then begin
              fFile.WriteFile([GF.CurParams],'DIV class=S%d',[ffoSP]);
              fFile.WriteFile('TABLE cellpadding=0 bgcolor=white style=''border-collapse:collapse''',
                [ffoSP]);
              if ted=msoEdExcel then begin
                fFile.WriteFile('',[ffoCR]); j:=0;
                for i:=1 to GF.ColCount do
                  if aCol[i]>aCol[j] then begin
                    fFile.WriteFile('COL style=''width:'
                      +HtmInch((GF.GridX[i]-GF.GridX[j])/Screen.PixelsPerInch)+'''');
                    j:=i;
                  end;
              end;
            end;
            lo:=GF.ObjectCount; SetLength(ao,lo);
            for i:=0 to lo-1 do ao[i]:=GF.PObjects[i];
            QuickSort(SortTopLeft,@ao,0,lo-1); i:=1; j:=0; ct:=-1;
            while j<lo do begin
              if Sender.SayStat('',Format('Объект: %d из %d',[i,lo]),i/lo) then break;
              Inc(i); pv:=ao[j];
              cb:=aRow[pv.Bottom]-aRow[pv.Top]; cr:=aCol[pv.Right]-aCol[pv.Left];
              if (cb>0) and (cr>0) then begin
                pvFont;
                if fmt=msoFmtXls then begin
                  alg:=NumToAlgm(pv.Alignment);
                  vs:=SubStr(TextCRLF(GF.ObjText(pv^)),1,-lCRLF); v:=vs; s:='';
{if vs='17.06.2015' then begin
vs:=vs;
end;}
                  with GF.Params.Arr[GF.CurParams] do begin
                    txt:=PrmDate.Dlm;
                    dt:=ctod(IfThen(PrmDate.MMYY,'01'+DateSeparator)+StrTran(v,txt,DateSeparator));
                    if FmtDate(dt,PrmDate)=v then begin
                      if xlsTrnsDate in TXlsFile(fFile).Options then
                        if PrmDate.ZeroEmp.l and empty(dt) then v:=PrmDate.ZeroEmp.s
                        else begin
                          v:=dt; s:=IfThen(not PrmDate.MMYY,'dd'+txt)+'mm'+txt+StringOfChar('y',PrmDate.NYear);
                        end
                    end
                    else if xlsTrnsNum in TXlsFile(fFile).Options then with PrmNum do if (AllCnt=0) or (Length(v)>=AllCnt) then begin
                      txt:=v; l:=Length(txt);
                      {if l>0 then
                        if IsDigit(txt[1]) then begin}
                          if FracCnt>0 then begin
                            Dec(l,FracCnt);
                            if l>0 then txt[l]:=DecimalSeparator;
                            Dec(l);
                          end;
                          if DigIsDlm then while l>0 do begin
                            Dec(l,3);
                            if l>0 then Delete(txt,l,1);
                          end;
                          d:=Float0(txt);
                          if FmtNum(d,PrmNum)=v then
                            if PrmNum.ZeroEmp.l and empty(d) then v:=PrmNum.ZeroEmp.s
                            else begin
                              v:=d;
                              if FracCnt>0 then s:='0.'+StringOfChar('0',FracCnt);
                            end;
                        //end;
                    end;
                  end;
                  LineXY(pv); XlsFill(lt,ct1); XlsFill(ll,cl1); XlsFill(lb,cb1); XlsFill(lr,cr1);
                  XlsWriteCell(aRow[pv.Top],aRow[pv.Bottom]-1,aCol[pv.Left],aCol[pv.Right]-1,
                    v,vs,pv.Font,SeekColor(AColor[pv.Color],false),s,
                    alg.HorzAlignment,alg.VertAlignment,GF.Fonts[pv.Font].Prop.Angle,not pv.MMetr,
                    lt,ct1,ll,cl1,lb,cb1,lr,cr1);
                end
                else begin
                  if aRow[pv.Top]>ct then begin
                    WrPriorRow;
                    if fmt=msoFmtHtml then begin
                      cb1:=pv.Top;
                      while aRow[cb1]=aRow[pv.Top] do Inc(cb1);
                      l:=0;
                      if ted=msoEdWord then begin
                        ct1:=aRow[pv.Top];
                        for cl1:=ACol[1] to ACol[GF.ColCount] do
                          if rf.x[ct1,cl1]>1 then MaxSelf(l,aGFLines[rf.x[ct1,cl1]].Width);
                        if l>0 then l:=GF.Pix(false,l);
                      end;
                      fFile.WriteFile('TR style=''height:'+HtmInch((GF.GridY[cb1]-GF.GridY[pv.Top]-l)
                        /Screen.PixelsPerInch)+'''',[ffoSP]);
                      fFile.WriteFile('',[ffoCR]);
                    end;
                    ct:=aRow[pv.Top]; l:=j;
                  end;
                  if fmt=msoFmtHtml then begin
                    lv:=true; clr:=AColor[pv.Color]; alg:=NumToAlgm(pv.Alignment);
                    if IsBmp(pv) then begin
                      pFls:=PointerVar(Sender.Params[0]);
                      if pFls^='' then begin
                        pFls^:=ChangeFileExt(Rec['FILE'],'.FLS'+PathDelim); XDel(pFls^); ForceDirectories(pFls^);
                      end;
                      cr1:=GF.GridObj(pv^,false);
                      cr:=IfThen(pv.MMetr and (pv.MinWidth>0),
                        nround(pv.MinWidth/MmInInch*Screen.PixelsPerInch),cr1);
                      cb1:=GF.GridObj(pv^,true);
                      cb:=IfThen(pv.MMetr and (pv.MinHeight>0),
                        nround(pv.MinHeight/MmInInch*Screen.PixelsPerInch),cb1);
                      if pv.TypeObj in [toBmp,toCalcBmp] then begin
                        vs:=Trim(pv.Text); StringListVar(Sender.Params[1]).Add(vs);
                      end
                      else begin
                        ForceDirectories(pFls^+'TXT'+PathDelim);
                        lsTxtBmp:=PointerVar(Sender.Params[2]);
                        fl:=IntObjFindAdd(lsTxtBmp,
                          Format('%d,%d,%d,%s',[pv.Font,cr,cb,StrTran(pv.Text,CRLF,'~')]),l);
                        vs:=StrNum('TXT'+PathDelim,l);
                        if not fl then TxtBmpPaint(pv,pFls^+vs+'.bmp');
                      end;
                      txt:=Format('<IMG src="%s.FLS%s%s.bmp" width=%d height=%d>',
                        [ExtractFileWithOutExt(Rec['FILE']),PathDelim,vs,cr,cb]);
                    end
                    else begin
                      txt:=GF.ObjText(pv^); l:=1; lv:=true;
                      while l<=Length(txt) do begin
                        if txt[l]=' ' then
                          if lv then begin
                            offs:=l; lv:=false;
                            while l<=Length(txt) do
                              if txt[l]=' ' then Inc(l) else break;
                            cr1:=l-offs;
                            s:='<span style=''mso-spacerun:yes''>'+StringOfChar(#160,cr1)+'</span>';
                            Inc(l,Length(s)-cr1); StuffStrSelf(txt,offs,cr1,s); continue;
                          end
                          else lv:=true
                        else lv:=false;
                        Inc(l);
                      end;
                      txt:=StrTran(RightStrDel(txt,CRLF),CRLF,'<BR>');
                    end;
                    LineXY(pv);
                    s:='';
                    if ted=msoEdWord then begin
                      l:=0; cl1:=aCol[pv.Left]; ct1:=pv.Top;
                      while (ct1<=pv.Bottom) and (aRow[ct1]=aRow[pv.Top]) do Inc(ct1);
                      while ct1<=pv.Bottom do begin
                        if rf.y[cl1,ct1]>1 then MaxSelf(l,aGFLines[rf.y[cl1,ct1]].Width);
                        Inc(ct1);
                      end;
                      if l>0 then l:=GF.Pix(true,l);
                      DlmBetwSelf(s,'width:'
                        +HtmInch((GF.GridX[pv.Right]-GF.GridX[pv.Left]-l)/Screen.PixelsPerInch),';');
                    end;
                    if (lt=lb) and (lt=ll) and (lt=lr) then HtmLine(lt,'')
                    else begin
                      HtmLine(lt,'top'); HtmLine(lb,'bottom'); HtmLine(ll,'left'); HtmLine(lr,'right');
                    end;
                    if alg.VertAlignment<>taCenter
                    then DlmBetwSelf(s,'vertical-align:'+aHtmAlgm[2,alg.VertAlignment],';');
                    if alg.HorzAlignment<>taCenter
                    then DlmBetwSelf(s,'text-align:'+aHtmAlgm[1,alg.HorzAlignment],';');
                    if s<>'' then IncL(s,' style=''','''');
                    fFile.WriteFile([pv.Font,IfThen(cb>1,StrNum(' rowspan=',cb)),
                      IfThen(cr>1,StrNum(' colspan=',cr)),
                      IfThen(clr<>clWhite,' bgcolor='+ColorHex(clr)),s,txt],
                      '<TD class=%d%s%s%s%s>%s');
                  end;
                end;
              end;
              Inc(j);
            end;
            WrPriorRow;
            if fmt=msoFmtHtml then begin
              fFile.WriteFile('/table'); fFile.WriteFile('/div');
            end;
          end;
        end;
lend:
      finally
        InitArr(aMerge); aX:=nil; aY:=nil; aCol:=nil; aRow:=nil; aMerge:=nil; lsRtfMerge.Free;
      end;
    until Sender.Aborted or lSuccess;
  except
    on E: Exception do begin
      SetStack(ost);
      Sender.Abort;
      MsgDlg(['Ошибка преобразования в документ:',E.Message+'.']);
    end;
  end;
  DelStack;
end;

procedure TMsOffEd.RtfInit;
begin
  AddStack('TMsOffEd.RtfInit',Self);
  nRtfAlgn:=-1; nRtfFont:=-1; nlsRtfFont:=-1; nRtfFontSize:=-1; nRtfFontRGB:=-1; nRtfRowBetween:=0;
  sRtfStyle:=[];
  DelStack;
end;

function TMsOffEd.RtfFont;
const a: array[TFontStyle] of string = ('b','i','ul','strike');
var fs: TFontStyle;
  i: longint;
  fl: boolean;
begin
  AddStack('TMsOffEd.RtfFont',Self);
  result:='';
  if n<>nRtfFont then with aFont[n] do begin
    nRtfFont:=n; lsRtfFont.Find(Name,i);
    if i<>nlsRtfFont then begin
      nlsRtfFont:=i; IncD(result,StrNum('\f',i));
    end;
    if Size<>nRtfFontSize then begin
      nRtfFontSize:=Size; IncD(result,StrNum('\fs',Size*2));
    end;
    for fs:=low(a) to high(a) do begin
      fl := fs in Style;
      if fl <> (fs in sRtfStyle) then begin
        if fl then Include(sRtfStyle,fs) else Exclude(sRtfStyle,fs);
        IncD(result,'\'+a[fs]+IfThen(not fl,'0'));
      end;
    end;
    i:=aRtfRGB[lsRtfColor.IndexOf(Color)];
    if i<>nRtfFontRGB then begin
      nRtfFontRGB:=i; IncD(result,StrNum('\cf',i));
    end;
    if RowBetween<>nRtfRowBetween then begin
      nRtfRowBetween:=RowBetween; IncD(result,'\sl'+IfThen(RowBetween<>0,'-')+TwipsPix(RowBetween));
    end;
  end;
  DelStack;
end;

function TMsOffEd.RtfColor;
begin
  AddStack('TMsOffEd.RtfColor',Self);
  result:=StrNum('\'+ctrlw,aRtfRGB[lsRtfColor.IndexOf(Color)]);
  DelStack;
end;

function TMsOffEd.RtfAlign;
const aa: TAlgmStr = ('l','r','c');
var n: byte;
begin
  AddStack('TMsOffEd.RtfAlign',Self);
  n:=IfThen(lJustified,byte(high(a))+1,byte(a));
  if nRtfAlgn=n then result:=''
  else begin
    nRtfAlgn:=n; result:='\q'+IfThen(lJustified,'j',aa[a]);
  end;
  DelStack;
end;

function TMsOffEd.GFTblX2;
begin
  AddStack('TMsOffEd.GFTblX2',Self);
  result:=c;
  if (ted=msoEdWord) and (r>0) then for c:=c-1 downto 1 do
  	if GetBit(aMerge[r],c) then Dec(result);
  DelStack;
end;

function TMsOffEd.GFTblX;
begin
  AddStack('TMsOffEd.GFTblX',Self);
  result:=GFTblX2(aCol[x],aRow[y]);
  DelStack;
end;

function TMsOffEd.GFTblY2;
begin
  AddStack('TMsOffEd.GFTblY2',Self);
  result:=r;
  if ted=msoEdWord then for r:=r-1 downto 1 do
    if aMerge[r]=sel then Dec(result);
  DelStack;
end;

function TMsOffEd.GFTblY;
begin
  AddStack('TMsOffEd.GFTblY',Self);
  result:=GFTblY2(aRow[y]);
  DelStack;
end;

procedure TMsOffEd.SaveToFile;
var FileName: OleVariant;
begin
  AddStack('TMsOffEd.SaveToFile',Self);
  FileName:=Rec['FILE'];
  case ted of
  	msoEdExcel: with (aSrv[ted].Doc as TExcelWorkBook) do begin
      if TrimUpper(Name)=TrimUpper(ExtractFileName(Rec['FILE'])) then Save else SaveCopyAs(FileName);
      Close(false);
      ConnectTo(TExcelApplication(aSrv[ted].Appl).WorkBooks.Open(FileName,EmptyParam,EmptyParam,
        EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,
        EmptyParam,EmptyParam,EmptyParam,0));
    end;
  	msoEdWord: TWordDocument(aSrv[ted].Doc).SaveAs(FileName);
  end;
  DelStack;
end;

procedure TMsOffEd.WMFormLimit;
begin
	AddStack('TMsOffEd.WMFormLimit',Self);
  inherited;
  FreeLimit(MsOffEd);
  DelStack;
end;

{ TMsOffInit }
function EdInit(tw: TWinControl; lShow: boolean): boolean;
var s1: string;
	i,j: longint;
  ds: TDataSet;
  ls: TStrings;
  fl: boolean;
begin
  AddStack('FMsOffEd.EdInit');
  result:=MsgMsOff(tw,nil);
  if result then begin
    CreateForm(TMsOffEd,MsOffEd);
    with MsOffEd do begin
      Obj:=tw;
      if tw is TGenForm then begin
        EBrFld.Hide; EType.Show; EErr.Show;
        RbPage1.SetTabVisible(tsPage,false); tsPage.Enabled:=false;
        i:=TGenForm(tw).PageCount; fl := i>1; Rec['VPage']:=GFStrAll;
        if i=0 then begin
          FormFree(MsOffEd); lShow:=false;
        end;
      end
      else begin
        s1:=''; j:=0; fl := not((tw is TTreePrim) or (tw is TFindListBox));
        if fl then begin
          if tw is TBrowl then with TBrowl(tw) do begin
            ds:=DataSource.DataSet;
            for i:=0 to ds.FieldCount-1 do with ds.Fields[i] do if Visible then begin
              IncD(s1,mniDlm+DisplayLabel); Inc(j);
            end;
          end
          else if tw is TStringBrowl then with TStringBrowl(tw) do begin
            for i:=0 to ColZn.Count-1 do with InfoCol[i] do if Length(aName)>0 then if aName[0]<>'' then begin
              IncD(s1,mniDlm+ArrayAsList(aName,' ')); Inc(j);
            end;
          end
          else if tw is TStrTable then with TStrTable(tw) do begin
            ls:=IfThen(Inverted,HeadY,HeadX);
            for i:=0 to ls.Count-1 do begin
              IncD(s1,mniDlm+ls[i]); Inc(j);
            end;
          end;
          Rec['FLD']:=StringOfChar('+',j); EBrFld.Mask:=Copy(s1,lmniDlm1,MaxInt);
        end;
        RbPage1.SetActivePage(tsOsn);
        EBrFld.Visible:=fl; EType.Hide; EErr.Hide;
        RbPage1.SetTabVisible(tsPage,true); tsPage.Enabled:=true; fl:=false;
      end;
      if Assigned(MsOffEd) then begin
        EVPage.Visible:=fl; EPages.Visible:=fl;
      end;
      if lShow then begin
        PanelEdit1.FillFldList; MainRebuild; ShowModal; FormFree(MsOffEd);
      end;
    end;
  end;
  DelStack;
end;

constructor TMsOffInit.Create;
begin
	AddStack('TMsOffInit.Create',Self);
  inherited Create(AOwner);
  Parent:=pointer(AOwner); Visible:=false;
  DelStack;
end;

procedure TMsOffInit.WMMsOff;
var t: longint;
begin
  AddStack('TMsOffInit.WMMsOff',Self);
  with Message do case Oper of
  	msoInit: ResInit:=true;
    msoEnter: if Assigned(KeyLb) then KeyLb.SetKey(K_Ctrl_W,'',
    	'Преобразовать в файл',ProcKey,'msoff',kmFile);
    msoExit: if Assigned(KeyLb) then KeyLb.DelKey(K_All,'msoff');
    msoExec: begin
    	NoResExec:=EdInit(rExec.tw,false);
      if NoResExec then with MsOffEd do begin
      	Rec['FILE']:=rExec.FileName;
        ted:=rExec.Editor;
      	fmt:=rExec.Fmt; Rec['FMT']:=fmt;
      	Rec['TrnType']:=rExec.Trn;
        t:=MyVarType(rExec.Leaf);
        if t<>varNull then
        	if empty(rExec.Leaf) then Rec['VPage']:=GFStrCur
          else begin
          	Rec['VPage']:=GFStrNum;
            if t=varString then Rec['PAGES']:=rExec.Leaf else Rec['PAGES']:=IntToStr(rExec.Leaf);
          end;
        NoResExec:=PanelEdit1.Valid; FormFree(MsOffEd);
      end;
      NotD(NoResExec);
    end;
  end;
  DelStack;
end;

class procedure TMsOffInit.ProcKey;
begin
	AddStack('TMsOffInit.ProcKey');
  EdInit(tw,true);
  DelStack;
end;

procedure HelpTblProc(const Name: string; var result: variant);
begin
  AddStack('FMsOffEd.HelpTblProc');
  if Name=''
    then result:=VarArrayOf(
    [VarArrayOf(['OFF_РЕД','Преобразование в файл: редактор'])
    ,VarArrayOf(['OFF_ФОРМАТ','Преобразование в файл: формат'])
    ,VarArrayOf(['OFF_ВИД','Преобразование в файл: вид'])
    ])
  else if Name='OFF_РЕД'
    then result:=AddFrom(ArrStrToVar(['не вызывать редактор']),ArrStrToVar(aEd))
  else if Name='OFF_ФОРМАТ'
    then result:=ArrStrToVar(aFmtNm,1)
  else if Name='OFF_ВИД'
    then result:=ArrStrToVar(awType,1);
  DelStack;
end;

initialization
  AddStack('FMsOffEd.initialization');
  AddFrom(HelpTblProc);
  DelStack;
end.
