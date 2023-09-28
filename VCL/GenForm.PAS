unit GenForm;

interface

{$I LIBTEST}
{ $DEFINE NEWLOG}
{ $DEFINE ONP}
uses
	Windows,Messages,SysUtils,Classes,Graphics,Controls,Forms,ExtCtrls,Printers,Menus,pQRCode,
  MyTypes,My_pr,FFldEdit,RecVal,RecDB,BufFile,Schem,Askp,Inter,FIntErLs;

type
  TGFProcObjOpt = set of (gfoFill,gfoSel,gfoPos);
	TGFVSel = set of (vsGrid,vsObj);
  TGFMinWHOpt = set of (mwhNoAll,mwhNoAngle,mwhNoMm,mwhNoALine);
  TGFAutoNewPageOpt = set of (gfnpObjSpace,gfnpAfter,gfnpNoDelSelObj);
  TGFSavePageOpt = set of (gfsvFromNewPage,gfsvEdit);
  TGFSavePagesOpt = set of (gfsvsEdit,gfsvsNoChkSum);
  TGFAutoSizeXOpt = set of (gfszxCalcRate,gfszxNoCngCrd,gfszxWidthOnLeaf);
  TGFAutoSizeYOpt = set of (gfszyCalcRate,gfszyLaWidth);
  TGFDcmPartOpt = set of (gfpSel,gfpClrSel,gfpDown,gfpDyn);
  TGFLineWidthOpt = set of (gfwY,gfwRight);
  TGFDivSelObjOpt = set of (gfdvCopyText,gfdvNoAutoSize);
  TDcmFormOpt = set of (dcmfOnlyCngLeaf,dcmfDynamicPart);
  TDcmNewPageOpt = set of (newpgAuto,newpgPartEnd,newpgPrim);
  TGFFindTextOpt = set of (gffndSel,gffndScrl);
  TGFObjSpaceOpt = set of (gfspNoAutoSize,gfspWidthOnLeaf,gfspSel);
  TGFIdStrAddOpt = set of (gfidHMax,gfidEmpNoFill);

  TGFPackFont = class(TObject)
  public
    Font: TFont;
    Prop: TGFPackFontProp;
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TGFPackFont);
		function DopInf: string;
  end;

  PGFBitMap = ^TGFBitMap;
  TGFBitMap = record
  	Name: string;
    bm: TBitMap;
    ReDef: boolean;
    nRec: longint;
  end;

  TGFBitMapLoadOpt = set of (gfbmUser,gfbmUserName);

  TGFBitMapList = class(TStringList)
  private
  	ss: TStringStream;
    aBM: array of TGFBitMap;
		function GetStrBitMap(Index: longint): string;
		procedure SetStrBitMap(Index: longint; const Value: string);
		procedure DelBM(Index: longint);
		function FAddBM(const S,Name: string; nRec: longint; var bm: TBitMap): longint;
    procedure ProcDel(oi,ni: longint);
  public
  	constructor Create;
  	destructor Destroy; override;
    function AddBM(const S,Name,sBitMap: string; nRec: longint = 0): longint;
    function GetBM(Index: longint): PGFBitMap;
    procedure Delete(Index: longint); override;
    procedure Clear; override;
		function BitMapToStr(bm: TBitMap): string;
		procedure StrToBitMap(const s: string; bm: TBitMap);
		procedure LoadFromDB(lsDsgn: TGFBitMapList; const PartIni: string); overload;
		procedure LoadFromDB(const where: string; Opt: TGFBitMapLoadOpt); overload;
		function FileToStr(const FileName: TFileName): string;
		procedure ReDefine(Index: longint; const sBitMap: string; lRedef: boolean = true);
    property StrBitMap[Index: longint]: string read GetStrBitMap write SetStrBitMap;
  end;

  TDBDcmList = class(TStringList)
  private
    lsm: TMemGkList;
    aInf: array of record
      NumSave,MemDcm: longword;
      ChkSum: LongInt;
    end;
	public
		constructor Create;
  end;

  TGFColList = class(TStringList)
  private
    apv: array of TArrPGFObj;
    procedure ProcDel(oi,ni: longint);
  public
    procedure Delete(Index: Integer); override;
  end;

  PGFIdStr = ^TGFIdStr;
  TGFIdStr = record
  	s: string;
  	a: array of record
      pv: PGFObj;
      MinStr: longint;
      EmpNoFill: boolean;
    end;
    nMax: longint;
    lNewPg: boolean;
  end;

  TGFIdStrList = class(TStringList)
  private
    a: array of TGFIdStr;
    function GetObj(Index: longint): PGFIdStr;
    procedure ProcDel(oi,ni: longint);
  public
    procedure Delete(Index: Integer); override;
  end;

  TGFMacroType = (gfmcDefault,gfmcCtrl,gfmcEval,gfmcSaved); TGFMacroTypes = set of TGFMacroType;
  TGFMacro = (gfmcLEAF,gfmcPAGE,gfmcPART,gfmcNOPART,gfmcALWAYS,gfmcFONT,gfmcEND);

  TGFLevel = array of record
    nm: string;
    Prior: SmallInt;
    LsLen,LsCut: TList;
  end;

  PGFIdent = ^TGFIdent;
  TGFIdent = record
  	Leaf: longint;
    Calc,Edited,lsZero,Bmp: boolean;
    Fml,Value: string;
  end;

  PGFObjSpace = ^TGFObjSpace; TGFObjSpace = array of TRect;

  TGFFindInfo = record
    aObj: array of record
      pv: PGFObj;
      SelStart: TArrInt;
    end;
    SelLength: longint;
  end;

	// Тип объекта по расположению к Part-ам нижнего уровня
  TGFPartPrior0 = (plAll,plBeg,plEnd,plLen,plCut);
  TGFPartPrior = Succ(plAll)..high(TGFPartPrior0);

	PGFPart = ^TGFPart;
  TGFPart = record
  	aPart1: array[TGFPartPrior] of record
      nMin,nMax: Word;
      Objs: TList;
    end;
    nBeg,nEnd: longint;
    nMin,nMax,Level,NextMin,NextMax: Word;
    Prior: SmallInt;
    CntDlm: TSegmList;
  end;

  TGFCrd = record
  	Col,Row: Word;
  end;

  TGFTxtOutProc = procedure(Prm: pointer; const ARect: TRect; X,Y: longint; nFont: byte; const Text: string) of object;

  TGFProcObj = function(pv: PGFObj; const r: TRect; const p: TPoint; const msz: TSize;
  	mh1,i,h: longint; Opt: TGFProcObjOpt; PrTxtOut: TGFTxtOutProc; PrmTxtOut: pointer): boolean of object;

  TGFNewPgProc = procedure(Opt: TGFAutoNewPageOpt; var av: array of variant; var oldr: longint) of object;

  TGFSelObjsEvent = procedure(Sender: TObject; ListObj: TList; lSel: boolean) of object;

  PGFGrid = ^TGFGrid;
  TGFGrid = record
    Crd,Order,Order1: longint;
    Calc,Busy: boolean;
  end;
  TArrGFGrid = array of TGFGrid;

  TGFVidDiv0 = (dvNone,dvRight,dvBottom,dvLeft,dvTop); TGFVidDiv = Succ(dvNone)..high(TGFVidDiv0);

  TGFState = (gsDesign,gsView,gsPrint);

  TGFFillRec1 = array of TArrByte;
  TGFFillRec = record
  	x,y: TGFFillRec1;
  end;

  TGFVersInfo = record
	  Vers: Byte;
    MDName: TModelName;
    MDPrim: TModelPrim;
    MDNSave,NumSave: longword;
    ChkSum: LongInt;
    MDFile: TModelFile;
  end;

  TGFAddPartList = (gfpFirstPartPg,gfpNoFootPg);

  TGenForm = class(TCustomControl)
  private
    { Private declarations }
    FLeaf,FPage,FPgSmall,BvX,BvY,scX,scY,CrdMargin,orcOne,orcMany,olppMany,IdStrCurN,SvSum,SvCount,{$IFDEF ONP} lNewPgObjs,{$ENDIF}
      nActivePaint,lCurPagePart: longint;
    BegSelX,BegSelY,ObjCrdMin,ObjCrdMax: Word;
    FScalePrc: Single;
    FCurParams,nFont0: byte;
    FCurPageName,FCurPagePart,LastPart,sCalc,ocpMany,IdStrCurId,FBlockLeaf: string;
    FSelected,FKbdCtrl,MsgBreak,IsPartInPage,lDcmForm,lSaveVers,
    	NoPartEnd,FAborted,NoPaint,Painted,lDrag,noMove,FirstEval,WasObjAline,AutoNewPage,
      ParentPartOut,FDynamicPart,WasPartFoot,ObjCrdCng,IsFont0: boolean;
    FObjects,FSelObjects,FFillObj,FDcmObj,TmpList,TmpList1,LsFont: TList;
    FPages: TArrPages;
    aCurPagePart: TArrStr;
    LsPart,ColHead,ColFoot,TmpStr: TStringList;
    LsPart1: array[TGFAddPartList] of TStringList;
    IdStr: TGFIdStrList;
    LsFont0: TFontIndexList;
    aPart: array of TGFPart;
    aLevel: TGFLevel;
    aColNm: TArrBoolStrList;
    FFileName: TFileName;
    FGridX,FGridY: TArrGFGrid;
    FRectSel,FSpot: TRect;
    FKbdCrd: TGFCrd;
		FState: TGFState;
    GFDcm: TGenForm;
    aHFPage: array[TGFHeadFoot] of array of record
      Part: string;
      nPart: longint;
    end;
    HFHeight: array[TGFHeadFoot] of Word;
    FBuf: TCustomBuf;
    FOtherCanvas: TCanvas;
    FParams: TGFParams;
    FOnAutoSize,FOnSelectGrid,FOnAfterOpen,FOnAfterPaint,FOnBeforeCalculate: TNotifyEvent;
    FOnSelectObjs: TGFSelObjsEvent;
    BvRect: TBevel;
    Timer: TTimer;
    ColorW,Color1: TColor;
		oldClose: TCloseEvent;
		oldPpMenu: TPopupMenu;
    bmPaint,bmAngle,bmAngPrn,bmStretch: TBitMap;
		FillRec: TGFFillRec;
    aCalc: array of record
      Calc,Calculating: boolean;
    end;
    IdStrCurPV,oCurGFObj,ObjCopy: PGFObj;
    aLongObj: array of record
      txt: string;
      af: TFontIndexSave;
    end;
    aSepCrdX,aSepCrdY,PriorLineEnd: TArrInt;
    aPos: TArrBool;
    InterMouse: TInter;
    aMouse: TByteSet;
    ObjCrdVid: TGFVidDiv0;
    aUnRate: TArrBoolDbl;
{$IFDEF ONP}
    aNewPgObjs: array of record
      pv: PGFObj;
      Bottom: Word;
    end;
{$ENDIF}
    aIdent: array of TGFIdent;
    function GetGridX(Index: longint): longint;
    function GetGridY(Index: longint): longint;
    function GetObjectCount: longint;
    function GetSelObjectCount: longint;
    function GetObjects(Index: longint): TGFObj;
    function GetPObjects(Index: longint): PGFObj;
    function GetSelObjects(Index: longint): TGFObj;
    function GetPSelObjects(Index: longint): PGFObj;
    function GetPageName(Index: longint): string;
		function GetFontCount: byte;
		function GetFonts(Index: byte): TGFPackFont;
		function GetScalePrc: Single;
    function GetColCount: Word;
    function GetRowCount: Word;
		procedure SetColCount(Value: Word);
		procedure SetRowCount(Value: Word);
    procedure SetGridX(Index,Value: longint);
    procedure SetGridY(Index,Value: longint);
    procedure SetObjects(Index: longint; const v: TGFObj);
    procedure SetSelObjects(Index: longint; const vv: TGFObj);
    procedure SetCurPageName(const Value: string);
    procedure SetCurPagePart(const Value: string);
    procedure SetState(Value: TGFState);
    procedure SetPageName(Index: longint; const Value: string);
		procedure SetScalePrc(Value: Single);
		procedure SetParams(const v: TGFParams);
		procedure SetCurParams(v: byte);
		procedure SetLeaf(v: longint);
		procedure SetBlockLeaf(const v: string);
    procedure BlockLeafAdd(DecLeaf: byte);
    procedure Init(DelObj: boolean = true);
    function IsLastPartHFPage(Index: TGFHeadFoot; const Part: string): boolean;
		function CorrObj(const v: TGFObj): TGFObj;
    procedure PaintObj(ListObj: TList); 
    procedure PrObjDrag(Prm: pointer; const ARect: TRect; X,Y: longint; nFont: byte; const Text: string);
		procedure FBringToFront(pv: PGFObj);
		procedure ObjBringToFront(Index: longint);
    procedure SetTmpStr(var v: TGFObj; NoALine: boolean = false; SelStart: PArrInt = nil; SelLength: longint = 0);
    procedure Str2Fon0(var s: string; FontDef: byte; Bound: boolean);
    function Font0Width(nl: longint): longint;
    function Font0Height(nl: longint; lMax: boolean = true): longint;
    function GetFont0(Index: longint): TFont;
    procedure LsFont0ToArr(var af: TFontIndexSave);
    function PointToCrd(X,Y: longint; With0: boolean = false): TGFCrd;
		procedure PaintSelected;
		function RectDefault(const ARect: PRect): TRect;
    procedure PaintFill(const ARect: PRect = nil);
		procedure SelShift(Shift: TShiftState; unSel,GridSel: boolean);
		procedure SaveVal(const Value: variant; tp: TSaveType);
		function SaveStr(const s: string): longint;
		procedure SaveFixStr(const st: string; ln: longint);
		procedure SaveVers;
    procedure SaveParams;
    procedure SaveParam(const Params: TGFParams; i: longint);
    procedure SavePrmNum(const PrmNum: TFmtNum);
    procedure SavePrmDate(const PrmDate: TFmtDate);
    procedure SaveFonts;
    procedure SaveFont(LsFont: TList; i: longint);
		function SavePage(Opt: TGFSavePageOpt = []): boolean;
		procedure SaveLongPage(mnBreakVert: boolean);
		procedure SavePages(Opt: TGFSavePagesOpt = []);
    procedure SaveObj(pv: PGFObj; i: longint = 0; noEdit: boolean = true);
		procedure TypeCursor(X,Y: longint);
    procedure MouseDown1(Shift: TShiftState; X,Y: longint);
    procedure MouseMove1(Shift: TShiftState; X,Y: longint);
    procedure MouseUp1(Shift: TShiftState; X,Y: longint);
		procedure TimerCtrlView(Sender: TObject);
    procedure TmpCtrlView; overload;
    procedure TmpCtrlView(ALeft,ATop: longint); overload;
    procedure aSortFill(Compare: TListSortCompare; var a: TArrPGFObj; var FGrid: TArrGFGrid);
    procedure AutoSizeX(ACol: Word; Opt: TGFAutoSizeXOpt = []);
    procedure AutoSizeY(ARow: Word; Opt: TGFAutoSizeYOpt = []);
    procedure Crd2Visible(var FGrid: TArrGFGrid; var aCrd: TArrInt);
		function PageNew: PPages;
		procedure ClearPart;
    function Parts(i: longint): PGFPart;
		procedure ClearDcmObj(lFree: boolean = false);
		function EvalText(pv,pvInt: PGFObj; pNil: PBoolean = nil): boolean;
		procedure DcmPart1(const Part: string; nPart: longint; typ: TGFPartPrior0; Opt: TGFDcmPartOpt);
    procedure SetWasObjAline(const v: TGFObj; lBound: boolean);
		procedure DcmPartEnd(const Part: string = ''; nPart: longint = NegDef);
		procedure DelCol(fl: boolean; i: longint);
		procedure FontsAddGF(GF: TGenForm);
		class function FontAdd(LsFont: TList; f: TGFPackFont): TGFPackFont; overload;
    class procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure TimerMouseMove(Sender: TObject);
		procedure SaveEdit(Sender: TAsk);
		procedure CorObjTextMode(pv: PGFObj);
		procedure HideColStat(i: longint);
		function TxtWidth(const txt: string): Word;
		function TxtWidthUn(const txt: string): longint;
		function TxtWidthOther(const txt: string): Word;
		function TxtHeight(const txt: string = cMaxH): Word;
		//function TxtHeightUn(const txt: string): longint;
		function TxtHeightOther(const txt: string = cMaxH): Word;
    function GridLine(lY: boolean): Word;
		function LineWidth(Opt: TGFLineWidthOpt = []): TLineNulWidth;
		procedure BeforePaint;
		function TxtOut(i: longint; pv: PGFObj; lb: longint = 0; tb: longint = 0;
    	p: PRect = nil; Opt: TGFProcObjOpt = []; PrTxtOut: TGFTxtOutProc = nil; PrmTxtOut: pointer = nil): longint;
		procedure PrAutoNewPage(oldr,olCurPagePart: longint; const oCurPart: string;
      Opt: TGFAutoNewPageOpt; Proc: TGFNewPgProc; var av: array of variant);
		procedure PrNewPgMany(Opt: TGFAutoNewPageOpt; var av: array of variant; var oldr: longint);
		procedure PrNewPgOne(Opt: TGFAutoNewPageOpt; var av: array of variant; var oldr: longint);
    procedure HFOut(hf: TGFHeadFoot);
    procedure PrimOut;
		function bmSize(const v: TGFObj): TSize;
		function GradToRad(const v: TGFObj): Extended;
		function IsAngle(const v: TGFObj): boolean;
		function AngleWidth(const v: TGFObj; w,h: longint): longint;
		function AngleHeight(const v: TGFObj; w,h: longint): longint;
		procedure RestCurLeaf;
		procedure DrawBmp(bm: TGraphic; const p: TPoint; const sz: TSize);
		function mnBreakExec(lVert: boolean; wGreat: longint): boolean;
    function IdentNew(const Index: variant): PGFIdent;
		function IsObjGet(const v: TGFObj; lNul: boolean = false): boolean;
		procedure SetPrmFromPpdoc(GF: TGenForm; const fnDcm,PartIni: TFileName);
		function BarCodePix(lY: boolean; const v: TGFObj; mm: Double): longint;
		function BarCodePixFont(lY: boolean; f: TGFPackFont; mm: Double): longint;
    function IdStrObjText: boolean;
    procedure DelMacro(var v: TGFObj; Types: TGFMacroTypes);
    procedure ClearLevel(cnt: longint = 0);
    function GetBottomLimit: longint;
    class procedure InterGetAlgProc(Sender: TObject; var Txt: string);
    function MouseEval(vid: byte; const nm: string; Shift: TShiftState = []): boolean;
    procedure InterMouseGetAlgProc(Sender: TObject; var Txt: string);
		function CursDefault: TCursor;
    procedure FSaveDcm;
    procedure SetKbdCtrl(Value: boolean = false);
    procedure KbdRound;
    function OnlyDig(Index: longint): boolean;
    function PrcSpMin(const v: TGFObj): Word;
    function qrInit(const v: TGFObj): longint;
    class procedure qrEncode(Sender: TObject; var Data: AnsiString; Barcode: string);
    function pdf417Init(const v: TGFObj): TSize;
    class procedure PDF417InvalidLength(Sender: TObject; Barcode: string; LinearFlag: Boolean);
		procedure WMGetDlgCode(var Msg: TWmGetDlgCode); message wm_GetDlgCode;
    procedure WMSchem(var msg: TWMSchem); message WM_SCHEM;
		procedure WMCalc(var msg: TWMCalc); message WM_CALC;
		procedure WMPaintCtl(var msg: TWMPaintCtl); message WM_PAINTCTL;
		procedure WMIntErr(var msg: TWMIntErr); message WM_INTERR;
    procedure CMCursorChanged(var Message: TMessage); message CM_CURSORCHANGED;
  protected
    { Protected declarations }
    procedure Click; override;
    procedure DblClick; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
    procedure MouseMove(Shift: TShiftState; X,Y: longint); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
    procedure DoEnter; override;
    procedure DoExit; override;
		procedure Notification(AComponent: TComponent; Operation: TOperation); override;
		procedure SelectGrid; dynamic;
		procedure AfterOpen; dynamic;
		procedure DragOver(Source: TObject; X,Y: longint; State: TDragState; var Accept: Boolean); override;
		procedure DoEndDrag(Target: TObject; X,Y: longint); override;
    procedure DoSelectObjs(ListObj: TList; lSel: boolean); dynamic;
	public
    { Public declarations }
    aRate: TArrBoolDbl;
    TmpCtrl: TControl;
    awDat: TArrBoolStr;
    awWin: TGFWinStr;
    VersInfo: TGFVersInfo;
    lsBitMap,EdlsBitMap: TGFBitMapList;
    ProcBeforeNewPage,OnRestPage,OnNoFitOnPage: TNotifyEvent;
    OnGraphObj: TGFGraphObjEvent;
    StrAlg,DopAlg,DopAlgName,MouseAlg,EdPartIni: string;
    LsIdent,LsBlockLeaf: TStringList;
    InGet,DynAnyLevel,AutoNewPageObjSpace,EvalCalc: boolean;
    EdPpdPrm: TPPDocRec;
    EdSayProc: TStringEvent;
    CurPageFirst: variant;
    BlockLeafBeg,PageCount: longint;
    CurCanvas: TCanvas;
    stFontSay: TByteSet;
    property Params: TGFParams read FParams write SetParams;
    property CurParams: byte read FCurParams write SetCurParams;
    property GridX[Index: longint]: longint read GetGridX write SetGridX;
    property GridY[Index: longint]: longint read GetGridY write SetGridY;
    property ColCount: Word read GetColCount write SetColCount;
    property RowCount: Word read GetRowCount write SetRowCount;
    property ObjectCount: longint read GetObjectCount;
    property Objects[Index: longint]: TGFObj read GetObjects write SetObjects;
    property PObjects[Index: longint]: PGFObj read GetPObjects;
    property SelObjectCount: longint read GetSelObjectCount;
    property SelObjects[Index: longint]: TGFObj read GetSelObjects write SetSelObjects;
    property PSelObjects[Index: longint]: PGFObj read GetPSelObjects;
    property Selected: boolean read FSelected;
    property RectSel: TRect read FRectSel;
    property FileName: TFileName read FFileName write FFileName;
    property Leaf: longint read FLeaf write SetLeaf;
    property Page: longint read FPage;
    property CurPageName: string read FCurPageName write SetCurPageName;
    property CurPagePart: string read FCurPagePart write SetCurPagePart;
    property PageName[Index: longint]: string read GetPageName write SetPageName;
    property Aborted: boolean read FAborted;
    property FontCount: Byte read GetFontCount;
    property Fonts[Index: Byte]: TGFPackFont read GetFonts;
    property ScalePrc: Single read GetScalePrc write SetScalePrc;
    property Spot: TRect read FSpot;
    property OtherCanvas: TCanvas read FOtherCanvas;
    property BlockLeaf: string read FBlockLeaf write SetBlockLeaf;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
    procedure PaintAll;
    procedure PaintFillAll(const ARect: PRect = nil);
    function PaintObj1(pv: PGFObj; lSel: boolean = false; SelStart: PArrInt = nil; SelLength: longint = 0;
      PrTxtOut: TGFTxtOutProc = nil; PrmTxtOut: pointer = nil): TRect;
		procedure DestroyObjects(ClrSel: boolean = true);
    procedure ClearFonts;
    procedure GFProcKey(key: longint; tw: TWinControl);
    //procedure tnpdf(key: longint; tw: TWinControl);
    function AddObj(const v: TGFObj; lCorrObj: boolean = true): PGFObj;
		procedure AddDefObj;
    function DelSelObj(lAutoSize: boolean = true): boolean;
		function NumSelObj(Index: longint): longint;
    function DivSelObj(Vid: TGFVidDiv; Opt: TGFDivSelObjOpt = []): boolean;
    function CombSelObj: boolean;
		procedure SelBringToFront(Index: longint);
    procedure ClearAllSelection;
    procedure ClearSelection(vsel: TGFVSel);
    procedure AutoSize(WidthOnLeaf: boolean = false);
		procedure OpenDcm(const AFileName: TFileName; lCompDB: boolean = true; nLeaf: longint = 1;
    	lsDcm: TDBDcmList = nil);
		procedure OpenDcmStr(const DcmDef: string);
    procedure Open(const AFileName: TFileName; nLeaf: longint);
    function SaveDcm: boolean;
		function SaveDcmStr: string;
		procedure RestPage(Index: longint; NoAutoSize: boolean = true);
    procedure CloseDtg;
		procedure DcmForm(const av: array of variant; ObjDcm: TGenForm; nLeaf: longint;
    	Opt: TDcmFormOpt = []);
		procedure DcmAddCol(const Col: string);
		procedure DcmDelCol(const Col: string);
		procedure DcmDelColGr(const Col: string);
		function DcmArrCol(const Col: string): variant;
		procedure DcmPart(const Part: variant; const PartPrim: string = '');
		procedure DcmClose(lSave: boolean);
		procedure DcmNewPage(Opt: TDcmNewPageOpt = []);
		procedure AddColHead(const Col: string);
		procedure AddColFoot(const Col: string);
    procedure AddPart(const Part: string; n: TGFAddPartList);
    function Pages(Index: longint): PPages;
		function PgObjectCount(PgIndex: longint): longint;
		function PgObjects(PgIndex,Index: longint): PGFObj;
		function FontAdd(f: TGFPackFont): TGFPackFont; overload;
		procedure FontAddDef;
		procedure FontDel(Index: byte);
		procedure FontCngNum(oldInd,newInd: byte);
		function SearchIdent(const s: string; var aInfo: TGFSearchAInfo;
    	lIdent: boolean = true): boolean;
		function ReplaceIdent(const s,s1: string; Opt: TGFReplaceOpt = [];
      PrRepl: TReplaceProc = nil; pav: PVariant = nil): TGFSearchCnt;
		function ObjInPoint(X,Y: longint): PGFObj;
    procedure SaveEditLeaf(nLeaf: longint);
		procedure SaveEditPrm;
    function FindText(const sf: string; var FindInfo: TGFFindInfo): boolean;
		procedure FindTextOut(const FindInfo: TGFFindInfo; Opt: TGFFindTextOpt = []);
		class function GetStdSize(Frm: Byte; Orient: TPrinterOrientation): TSize; overload;
		class function GetStdSize(Frm: TGFFrmList; Orient: TPrinterOrientation): TSize; overload;
		class procedure GetPPDcm(const FileName,sPartIni: TFileName; var result: TPPDocRec; GF: TGenForm = nil);
		class procedure PutPPDcm(const sPartIni: TFileName; const Prm: TPPDocRec);
		procedure GetPPFont(const Prm: TPPDocRec; Index: byte; result: TGFPackFont;
    	GF: TGenForm = nil);
		procedure Print(lMirror: boolean = false);
		function PageInf(Index: longint): TPageSave;
    function Idents(Index: longint): PGFIdent;
		procedure PageAdd(PgCopyFrom: longint = NegDef);
		procedure PageDel(Index: longint);
		procedure PageExchange(oi,ni: longint);
		function SelectObjs(ListObj: TList; lSel: boolean): boolean;
    procedure SelExtendObj(ListObj: TList);
    procedure SetSizeMm;
    procedure SetBounds(ALeft,ATop,AWidth,AHeight: longint); override;
		procedure GetArrFill(var result: TGFFillRec; const ARect: PRect = nil);
    function PFillObj(Index: longint): PGFObj;
		function bmObj(const v: TGFObj; var bm: TGraphic; txtDef: PString = nil): boolean; overload;
		function bmObj(const txt: string; var bm: TGraphic; txtDef: PString = nil): boolean; overload;
		function VArrPart: variant;
		procedure SaveCurLeaf;
		function GetMinWidth(const vv: TGFObj; Opt: TGFMinWHOpt = []): longint;
		function GetMinHeight(const vv: TGFObj; Opt: TGFMinWHOpt = []): longint;
		function SzGridWidth(lY: boolean; n: longint = 0): longint;
		procedure CalcRate;
    function GridObj(const v: TGFObj; lY: boolean): longint;
    function Pix(lY: boolean; w: longint): Word;
		procedure Calculate;
		procedure Calculate1(i: longint);
		procedure InGetRebuild(ParentRebuild: boolean = true);
		function FileBufActive: boolean;
		function ObjSpace(ares: PGFObjSpace = nil; Opt: TGFObjSpaceOpt = [];
      Pin: TGFPinList = pinTopRight): boolean;
    procedure IdStrAdd(const s,id: string; n: longint; Opt: TGFIdStrAddOpt; MinStr: longint);
		procedure CopyWithAutosize(const FileFrom,FileTo: TFileName);
		function RowBetween(const v: TGFObj): longint;
    function OnWidth(const v: TGFObj): boolean;
    function ALine(const v: TGFObj): boolean; overload;
    class function ALine(const f: TGFPackFont): boolean; overload;
    procedure MouseInit(GFDcm: TGenForm);
    function SizeNoLimit(nParams: longint = NegDef): boolean; overload;
    class function SizeNoLimit(const Params: TGFParams; nParams: longint): boolean; overload;
    class function SizeNoLimit(StdFormat: boolean; const SizeMm: TSize): boolean; overload;
    procedure IncRowCount(d2: longint = 1);
    procedure IncColCount(d2: longint = 1);
    procedure GetHFPage(Index: TGFHeadFoot; var result: TArrStr);
    procedure SetHFPage(Index: TGFHeadFoot; const Value: array of string);
    function ObjText(var v: TGFObj): string;
{$IFDEF LIBTEST}
		procedure TestObjs(w: longint = 10; const sBeg: string = ''; Clear: boolean = true);
{$ENDIF}
		//procedure SetIntervalBetwRows(vMm: Single);
		class procedure PutPPFont(var Prm: TPPDocRec; Index: byte; Font: TGFPackFont);
		class procedure PutPPFontDef(var Prm: TPPDocRec; Index: byte);
    class function IsPPFontDef(const Prm: TPPDocRec; Index: byte): boolean;
		class procedure ErasePartIni(const PartIni: TFileName);
		class procedure RenamePartIni(const cPartOld,cPartNew: TFileName);
    class function LoadFromServer(const FileName: TFileName; lAll: boolean = false): boolean;
		class function PrmDef: TGFParamItem;
		class procedure InterCreate(pv: PGFObj);
    class procedure RectObjInit(var r: TRect);
    class procedure RectObjCalc(var r: TRect; const v: TGFObj);
  	{ Унаследованные }
    property Canvas;
  published
    { Published declarations }
		property State: TGFState read FState write SetState;
    property OnAfterPaint: TNotifyEvent read FOnAfterPaint write FOnAfterPaint;
    property OnAutoSize: TNotifyEvent read FOnAutoSize write FOnAutoSize;
    property OnBeforeCalculate: TNotifyEvent read FOnBeforeCalculate write FOnBeforeCalculate;
    property OnSelectGrid: TNotifyEvent read FOnSelectGrid write FOnSelectGrid;
    property OnSelectObjs: TGFSelObjsEvent read FOnSelectObjs write FOnSelectObjs;
    property OnAfterOpen: TNotifyEvent read FOnAfterOpen write FOnAfterOpen;
  	{ Унаследованные }
    property Enabled;
    property PopupMenu;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnEnter;
    property OnExit;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

  EDcmBreakError = class(Exception)
  public
  	Vert: boolean;
    Key: longint;
  	constructor CreateErr(AVert: boolean; AKey: longint);
  end;

  TGFFldSayList = class(TComponent)
  private
    ls: TStringList;
    a: array of array[boolean] of TComponent;
    procedure ProcDel(oi,ni: longint);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddFld(tf: TFldEdit);
  end;

  TDcmLogCompare = class({$IFDEF NEWLOG}TCustomLogCompare{$ELSE}TStrLogCompare {$ENDIF})
  public
{$IFDEF NEWLOG}
    class function ListCreate(pv: pointer; const Value: string; lNew: boolean): pointer; override;
    class procedure ListDestroy(pv,ls: pointer); override;
    class function GetCount(pv,ls: pointer): longint; override;
{$ENDIF}
    class procedure GetItem(var Prm: TLogTrnsValPrm; pv,lso,lsn: pointer; no,nn: longint; tp: TLogCompareItemList); override;
  end;

  TGFPrmListF2Proc = procedure(lAfter: boolean; var StrList,KeyStr: string; var ProcKey: TKeyProc;
    var MouseDown,MouseUp: TMouseEvent; var MouseMove: TMouseMoveEvent; var Show: TNotifyEvent) of object;
  TGFPrmDefProc = function: TGFParams;

const
  DcmLastVers = 51;	// При изменении редактировать Помощь-Библиотека-Содержимое-Форма документа

  // Макроподстановки
  aGFMacro: array[TGFMacro] of record
    cod,nm: string;
    tp: TGFMacroType;
    HideNoLim: boolean;
  end =
    ((cod:'LEAF'                 ;nm:'Номер текущего листа'                                                      ;HideNoLim:true)
    ,(cod:'PAGE'                 ;nm:'Номер текущей страницы'                                                    ;HideNoLim:true)
    ,(cod:'PART'                 ;nm:'Номер текущей части страницы'                                              ;HideNoLim:true)
    ,(cod:'NOPART'               ;nm:'Линии внутри объекта не являются разделителем частей страницы';tp:gfmcCtrl )
    ,(cod:'/*@ВЫПОЛНЯТЬ_ВСЕГДА*/';nm:'Выполнять формулу при каждом выводе в документ'               ;tp:gfmcEval )
    ,(cod:'FONT'                 ;nm:'Начало выделения другим шрифтом'                              ;tp:gfmcSaved)
    ,(                            nm:'Конец выделения другим шрифтом'                               ;tp:gfmcSaved)
    );

  GFSegmDlm  = ','; lGFSegmDlm=Length(GFSegmDlm);	// Разделитель сегментов

  aQRCode_ECCLevel: array[TQRCode_ECCLevel] of record
    nm: TNamePrimStr;
    prc: byte;
  end =
    ((nm:('L','низкий'      );prc:7)
    ,(nm:('M','средний'     );prc:15)
    ,(nm:('Q','качественный');prc:25)
    ,(nm:('H','наивысший'   );prc:30)
    );

  GFChrMac = '@';

  aGFFrm: TGFFrmStr = ('А3','А4','А5','А3 Альбом','А4 Альбом','А5 Альбом','размеры не ограничены');
  aGFOrient: TPrinterOrientationStr = ('горизонтальное','вертикальное');
	aGFOrientSmall: TPrinterOrientationStr = ('гориз.','верт.');
  aGFBoolPrm: TArrBoolStr = ('по ширине','по высоте');
  aGFPropLine: TGFPropLineStr = ('ВЕРХ','НИЗ','ЛЕВ','ПРАВ');
	aGFFontType: array[TGFFontType] of string = ('обычный','посимвольное обрамление','штрих-код','QR-код','PDF417');
  aGFVOut: TGFVOStr = ('в начале','в конце','везде');
  aGFPin: TGFPinStr = ('вверх,влево','вверх,вправо','вниз,влево','вниз,вправо');
  aGFTypeObj: TGFTypeObjStr = ('текст','формула','рисунок','вычисл.','ввод','подск.','выч.рисунок');
  aGFMMetr: TArrBoolStr = ('символ','мм');

  aGFPropObj: array[TGFPropObjList] of record
    v,t,nm: string;
  end =
    ((v:'ОБ_РАЗМЕСТ';t:'I';nm:'Разместить содержимое объекта')
	  ,(v:'ОБ_ПРИЖАТЬ';t:'I';nm:'Прижать объект')
	  ,(v:'ОБ_ЦВЕТ'   ;t:'I';nm:'Цвет объекта')
	  ,(v:'ОБ_ВЫВОД'  ;t:'I';nm:'Вывод содержимого на листах одной страницы')
	  ,(v:'ОБ_НА1СТР' ;t:'L';nm:'Выводить только на первой части страницы')
	  ,(v:'ОБ_ММ'     ;t:'L';nm:'Единица измерения ('+vTrue+'-миллиметры, '+vFalse+'-символы)')
	  ,(v:'ОБ_ШИРИНА' ;t:'I';nm:'Минимальная ширина объекта')
	  ,(v:'ОБ_ВЫСОТА' ;t:'I';nm:'Минимальная высота объекта')
	  ,(v:'ОБ_ШРИФТ'  ;t:'I';nm:'Номер шрифта объекта из набора шрифтов')
	  ,(v:'ОБ_ИДЕНТ'  ;t:'C';nm:'Идентификатор объекта')
	  ,(v:'ОБ_ТИП'    ;t:'I';nm:'Тип объекта')
	  ,(v:'ОБ_ФОРМАТ' ;t:'I';nm:'Номер формата объекта')
    );

  aGFPropLineType: array[TGFPropLineType] of TNamePrimStr =
    (('ОБ_ТОЛЩ_','Толщина')
    ,('ОБ_ЦВЕТ_','Цвет')
    );
  cCalcBmp = #31;

var CurFdpGF,CurDEGF: TGenForm;
  CurGFObj: PGFObj;
  GFEdFontProc: function(var f: TGFPackFont; const KeyStr: string = ''; ProcKey: TKeyProc = nil): boolean;
  GFEdCreate: function: TGenForm;
  GFPrmExec: function(var ppd: TPPDocRec; DefaultProc: TGFPrmDefProc;
    InGet: boolean; lsBitMap,lsBitMapDsgn: TGFBitMapList; const sPartIni: string;
    FontProc: TGFPrmListF2Proc; const pKeyStr: string = ''; pKeyProc: TKeyProc = nil;
    PrmProc: TGFPrmListF2Proc = nil; twActive: TWinControl = nil; nCurPrm: longint = 0;
    PrModify: TNotifyEvent = nil): boolean;
  DcmIdentParams: PGFParamItem;
  CurGFObjParams: longint = NegDef;
  lsbmUser: TGFBitMapList;

procedure Register;
function NamePart: string;
function NameCol: string;
function SegmentPart(n: longint): string; overload;
function SegmentCol(n: longint): string; overload;
procedure UpdateDBDcm(const FileName: TFileName);
procedure UpdateDcmAll;
function VarCurGFObj(const v,ind: variant; lSave: boolean): variant;
function VarCurGFFill(const v,ind: variant; lSave: boolean): variant;
procedure SetPrnOrient(Orientation: TPrinterOrientation);
function GFCalcSpotPrn(frm: TGFFrmList; Orient: TPrinterOrientation): TRect;
function DBDcm: TRecDB;
function DBBmp: TRecDB;
function GFMacroCod(m: TGFMacro): string;
function GFPropLineCapt(tp: TGFPropLineType; pl: TGFPropLineList): string;

implementation

uses
  Variants,StrUtils,pPDF417,pPDF417Custom,pBarcode2D,Math,//tnpdf,
  FStat,PaintCtl,FPanel,KeyLb,MulQry,RbMenu,Shifr;

const
  otsLnSel = 3;
  WLnSel = 6;
  WdtLnSel = otsLnSel shl 1 + WLnSel;

  // Размеры штрих-кода (мм)
  brcSize: TArrBoolDbl = (26.73,21.31);
	brcSpot = 2.31;
  brcHeightLine: TArrBoolDbl = (18.23,19.88);

  brcCntNumLine = 7;   // Кол-во линий для одной цифры
  brcCntNum     = 8;   // Кол-во цифр
	brcCntLine    = brcCntNumLine*brcCntNum+11;	// Кол-во линий штрих-кода

  sGFIdStr = '@ID@';
  //lGFIdStr = Length(sGFIdStr);

  sGFIdEndStr = '@IDE@';
  //lGFIdEndStr = Length(sGFIdEndStr);

  GFMaxWord = MaxWord;

  ShiftStateLow=1; ShiftStateHigh=7;

type
  TGFBreakRead = (gbrVers,gbrMDName,gbrMDPrim,gbrMDNSave,gbrNumSave,gbrNone);

  EGenFormObj = class(Exception);
  EGFReplaceIdentBreak = class(Exception);

var
  lSegmPart,lSegmCol: TSegmList;
  aSegmPart,aSegmCol: TSegmStr;
  FDBDcm,FDBBmp: TRecDB;
  IsChkSum: boolean;
  txtAlg: string;
  qr: TBarcode2D_QRCode;
  pdf417: TBarcode2D_PDF417;

// Наименование текущего раздела
function NamePart;
begin
	AddStack('GenForm.NamePart');
	result:=SubStr(ArrayAsList(aSegmPart,GFSegmDlm,lSegmPart,true),1,-lGFSegmDlm);
  DelStack;
end;

// Наименование текущей колонки
function NameCol;
begin
	AddStack('GenForm.NameCol');
	result:=SubStr(ArrayAsList(aSegmCol,GFSegmDlm,lSegmCol,true),1,-lGFSegmDlm);
  DelStack;
end;

// Часть наименования текущего раздела
function SegmentPart(n: longint): string;
begin
	AddStack('GenForm.SegmentPart');
	if n in [1..lSegmPart] then result:=aSegmPart[n] else result:='';
  DelStack;
end;

// Часть наименования текущей колонки
function SegmentCol(n: longint): string;
begin
	AddStack('GenForm.SegmentCol');
	if n in [1..lSegmCol] then result:=aSegmCol[n] else result:='';
  DelStack;
end;

// Свойства тек.объекта
function VarCurGFObj;
var i: TGFPropObjList;
begin
	AddStack('GenForm.VarCurGFObj');
  result:=null;
  if Assigned(CurGFObj) then with CurGFObj^ do begin
    i:=ind;
    case i of
      vgfoAlignment: result:=Alignment;
      vgfoPin:       result:=Pin;
      vgfoColor:     result:=Color;
      vgfoVOut:      result:=VOut;
      vgfoOnly1:     result:=Only1;
      vgfoMMetr:     result:=MMetr;
      vgfoMinWidth:  result:=MinWidth;
      vgfoMinHeight: result:=MinHeight;
      vgfoFont:      result:=Font;
      vgfoIdent:     result:=Ident;
      vgfoTypeObj:   result:=TypeObj;
      vgfoParams:    result:=CurGFObjParams+1;
    end;
    if lSave then case i of
      vgfoAlignment: Alignment:=v;
      vgfoPin:       Pin:=v;
      vgfoColor:     Color:=v;
      vgfoVOut:      VOut:=v;
      vgfoOnly1:     Only1:=v;
      vgfoMMetr:     MMetr:=v;
      vgfoMinWidth:  MinWidth:=v;
      vgfoMinHeight: MinHeight:=v;
      vgfoFont:      Font:=v;
      vgfoIdent:     Ident:=v;
      vgfoTypeObj:   TypeObj:=v;
      vgfoParams:    CurGFObjParams:=v-1;
    end;
  end;
  DelStack;
end;

// Обрамление тек.объекта
function VarCurGFFill;
var i: Word;
  rf: TVarCurGFFill;
begin
	AddStack('GenForm.VarCurGFFill');
  rf.w:=ind;
	with CurGFObj^ do begin
    case rf.pl of
      vgflTop:    i:=LnTop;
      vgflBottom: i:=LnBottom;
      vgflLeft:   i:=LnLeft;
      vgflRight:  i:=LnRight;
    else i:=0;
    end;
    if i<2 then i:=0;
    case rf.tp of
      vgflnWidth: if i=0 then result:=0 else result:=aGFLines[i].Width;
      vgflnColor: result:=SeekColor(aGFLines[i].Color);
    end;
    if lSave then begin
    	case rf.tp of
        vgflnWidth: i:=GFTypeLine(v+1,SeekColor(aGFLines[i].Color));
        vgflnColor: i:=GFTypeLine(aGFLines[i].Width+1,v);
      end;
      case rf.pl of
        vgflTop:    LnTop:=i;
        vgflBottom: LnBottom:=i;
        vgflLeft:   LnLeft:=i;
        vgflRight:  LnRight:=i;
      end;
    end;
  end;
  DelStack;
end;

function GFCalcSpotPrn;
begin
	AddStack('GenForm.GFCalcSpotPrn');
  SetPrnOrient(Orient); result:=CalcSpotPrn;
  DelStack;
end;

procedure SetPrnOrient;
var ost: longint;
begin
  ost:=AddStack('GenForm.SetPrnOrient');
  try
    if GGPrinter.Orientation<>Orientation then GGPrinter.Orientation:=Orientation;
  except
    on EPrinter do begin
      SetStack(ost);
      MsgDlg('Нет связи с принтером, установленным по умолчанию.');
    end;
  end;
  DelStack;
end;

function DBDcm;
begin
  AddStack('GenForm.DBDcm');
  if TRecDB.Init(FDBDcm,result,tDCM) then IsChkSum:=result.IsField('CHKSUM');
  DelStack;
end;

function DBBmp;
begin
  AddStack('GenForm.DBBmp');
  TRecDB.Init(FDBBmp,result,tDCMBMP);
  DelStack;
end;

function GFMacroCod;
begin
  AddStack('GenForm.GFMacroCod');
  with aGFMacro[m] do result:=IfThen(tp<>gfmcEval,GFChrMac)+cod;
  DelStack;
end;

function GFPropLineCapt;
const avgfl: TGFPropLineStr = ('сверху','снизу','слева','справа');
begin
  AddStack('My_pr.GFPropLineCapt');
  result:=aGFPropLineType[tp,2]+' линии '+avgfl[pl]+' объекта';
  DelStack;
end;

function StrW(w: longint): string;
begin
	AddStack('GenForm.StrW');
	result:=StringOfChar('Д',w);
  DelStack;
end;

function SortTopLeft(Item1,Item2: Pointer): longint;
var pv1,pv2: PGFObj;
begin
	AddStack('GenForm.SortTopLeft');
  pv1:=Item1; pv2:=Item2; result:=pv1.Top-pv2.Top;
  if result=0 then result:=pv1.Left-pv2.Left;
  DelStack;
end;

function SortTopLeftDesc(Item1,Item2: Pointer): longint;
var pv1,pv2: PGFObj;
begin
	AddStack('GenForm.SortTopLeftDesc');
  pv1:=Item1; pv2:=Item2; result:=pv2.Top-pv1.Top;
  if result=0 then result:=pv2.Left-pv1.Left;
  DelStack;
end;

{$IFDEF LIBTEST}
procedure TGenForm.TestObjs;
var a: TArrStr;
  v: TGFObj;
  lDat: longint;
  procedure StrLs(var t: Word; const st: string);
  var s: string;
  begin
    AddStack('GenForm.TestObjs.StrLs');
    if lDat>0 then s:='|'+Padr(st,lDat)+'|' else s:=st;
    StuffStrSelf(a[t],v.Left,Length(s),s);
    if lDat>0 then Inc(t);
    DelStack;
  end;
const h1 = 3; wy = 4;
var i,j,k,w1: longint;
  s,s1: string;
  aCross: TArrStr;
begin
  AddStack('TGenForm.TestObjs',Self);
  if Assigned(FObjects) then begin
    FObjects.Sort(SortTopLeft); w1:=w+1;
    if Clear then clrmsgfile;
    if sBeg<>'' then addmsgfile(sBeg);
    s:=Space(wy); s1:=s;
    for i:=0 to high(FGridX) do begin
      IncD(s,Padr(IntToStr(i),w1)); IncD(s1,Padr(IntToStr(nround(GridX[i]/aRate[false])),w1));
    end;
    addmsgfile(s); addmsgfile(s1);
    s:=Space(high(FGridX)*w1+1); s1:=Space(wy); InitArrLen(aCross,high(FGridY)); SetLength(a,Length(FGridY)*(2+(h1-2))); k:=-1;
    for i:=0 to high(FGridY) do begin
      Inc(k); a[k]:=SpaceStr0(i,wy)+s;
      Inc(k); a[k]:=SpaceStr0(nround(GridY[i]/aRate[true]),wy)+s;
      for j:=3 to h1 do begin
        Inc(k); a[k]:=s1+s;
      end;
    end;
    for i:=0 to ObjectCount-1 do begin
      v:=Objects[i];
      for j:=v.Top to v.Bottom-1 do begin
        for k:=v.Left+1 to v.Right do begin
          if SetBit(aCross[j],k,true) then begin
            v:=v; // Можно поставить точку останова для проверки пересечения объектов
          end;
        end;
      end;
      MultD(v.Top,h1); MultD(v.Bottom,h1);
      v.Left:=wy+v.Left*w1+1; v.Right:=wy+v.Right*w1+1;
      s:=StringOfChar('-',v.Right-v.Left+1); lDat:=0;
      StrLs(v.Top,s); StrLs(v.Bottom,s);
      Inc(v.Top); lDat:=v.Right-v.Left-1;
      if lDat>=0 then begin
        StrLs(v.Top,IfThen(v.State=osSpace,'<_>',StrTran(Trim(v.Text),CRLF)));
        StrLs(v.Top,Int2Str(v.State));
        {if not(v.State in [osHide,osSave]) then begin
          StrLs(v.Top,IfThen(v.LnLeft>1,'LnLeft'));
          StrLs(v.Top,IfThen(v.LnRight>1,'LnRight'));
        end;}
        while v.Top<v.Bottom do StrLs(v.Top,'');
      end;
    end;
    for i:=low(a) to high(a) do addmsgfile(a[i]);
    {addmsgfile('');
    addmsgfile(Padc('Text',10)+ '|'
      +Padc('Part',20)+ '|'
      +Padc('Left',10)+ '|'
      +Padc('Right',10)+ '|'
      +Padc('Top',10)+ '|'
      +Padc('Bottom',10));
    for i:=0 to ObjectCount-1 do begin
      v:=Objects[i];
      addmsgfile(WinToDos(Padr(StrTran(Trim(v.Text),CRLF),10))+'|'
        +WinToDos(Padr(v.Part,20))+'|'
        +SpaceStr0(v.Left,10,0)+'|'
        +SpaceStr0(v.Right,10,0)+ '|'
        +SpaceStr0(v.Top,10,0)+ '|'
        +SpaceStr0(v.Bottom,10,0))
    end;}
  end;
  DelStack;
end;
{$ENDIF}

procedure RasprCrd(var a: array of longint; mw,offs: longint);
var i,w,l,sp: longint;
begin
  AddStack('GenForm.RasprCrd');
  a[0]:=offs; l:=high(a);
  if l>0 then begin
    w := mw div l;
    for i:=1 to l do a[i]:=w;
    w := mw mod l;
    while w>0 do begin
      sp:=nround(l/w); i:=sp;
      while (i<=l) and (w>0) do begin
        Inc(a[i]); Dec(w); Inc(i,sp);
      end;
    end;
    for i:=1 to l do Inc(a[i],a[i-1]);
  end;
  DelStack;
end;

procedure AlgZero(lsZero: boolean; var algm: TGFAlgmList);
var alg: THVAlignment;
begin
  AddStack('GenForm.AlgZero');
  if lsZero then begin
    alg:=NumToAlgm(algm); alg.HorzAlignment:=taCenter; algm:=AlgmToNum(alg);
  end;
  DelStack;
end;

{ TGFPackFont }
constructor TGFPackFont.Create;
begin
  AddStack('TGFPackFont.Create');
  Font:=TFont.Create;
  DelStack;
end;

destructor TGFPackFont.Destroy;
begin
  AddStack('TGFPackFont.Destroy');
  Font.Free;
  inherited Destroy;
  DelStack;
end;

procedure TGFPackFont.Assign;
begin
  AddStack('TGFPackFont.Assign');
  Font.Assign(Source.Font); Prop:=Source.Prop;
  DelStack;
end;

function TGFPackFont.DopInf;
type TCapt = 1..4;
const aCapt: array[TCapt] of string = ('цифры','по тексту','по ширине','разбить');
  function Capt(i: TCapt; usl: boolean): string;
  begin
    AddStack('TGFPackFont.DopInf.Capt');
    result:=aCapt[i];
    if not usl then SpaceSelf(result);
    IncD(result,' ');
    DelStack;
  end;
var l: longint;
  i: TCapt;
begin
  AddStack('TGFPackFont.DopInf');
  with Prop,Dop do begin
  	l:=max(LenIntStr(low(RowBetween)),LenIntStr(high(RowBetween)));
    case AType of
      fptNormal: result:=Capt(1,OnlyDig)+Capt(2,WidthTextAll)+Capt(3,OnWidth)+Capt(4,ALine)
        +SpaceStr(RowBetween,l);
      fptSepstr: result:=Capt(1,sepstrOnlyDig)+'посимв.обрамление'
        +IfThen(MMetr,Format(' %dx%d мм',[Width,Height]));
      fptBarCode: result:='штрих-код'+IfThen(Koef<>0,Format(' %d%%',[Koef]));
      fptQRCode: result:=Format('QR-код корр.%d%% модуль %d/10мм',[aQRCode_ECCLevel[qrECCLevel].prc,qrModule]);
      fptPDF417: result:=Format('PDF417 корр.%d модуль (%dx%d)/10мм',[byte(pdf417ECCLevel),pdf417Module,pdf417Module*pdf417RowHeight]);
    else result:='';
    end;
    for i:=low(aCapt) to high(aCapt) do Inc(l,Length(aCapt[i])+1);
    PadrSelf(result,l);
  end;
  DelStack;
end;

{ TGFBitMapList }
constructor TGFBitMapList.Create;
begin
	AddStack('TGFBitMapList.Create');
  SetLength(aBM,1); Sorted:=true; ss:=TStringStream.Create('');
  DelStack;
end;

destructor TGFBitMapList.Destroy;
begin
	AddStack('TGFBitMapList.Destroy');
  Clear; ss.Free;
  inherited Destroy;
  DelStack;
end;

function TGFBitMapList.AddBM;
var bm: TBitMap;
begin
	AddStack('TGFBitMapList.AddBM');
  result:=FAddBM(s,Name,nRec,bm); StrToBitMap(sBitMap,bm);
  DelStack;
end;

function TGFBitMapList.FAddBM;
var p: PGFBitMap;
  n: longint;
begin
  AddStack('TGFBitMapList.FAddBM');
  n:=Count;
  if Length(aBM)=n then SetLength(aBM,n shl 1);
  p:=@aBM[n]; result:=AddObject(s,pointer(n));
  p.Name:=Name; p.ReDef:=false; p.bm:=TBitMap.Create; bm:=p.bm; p.nRec:=nRec;
  DelStack;
end;

function TGFBitMapList.GetBM;
begin
  AddStack('TGFBitMapList.GetBM');
  result:=@aBM[IntObj(Self,Index)];
  DelStack;
end;

procedure TGFBitMapList.Delete;
begin
	AddStack('TGFBitMapList.Delete');
  DelBM(Index); SLObjIndDel(Self,Index,ProcDel,false);
  inherited Delete(Index);
  DelStack;
end;

procedure TGFBitMapList.ProcDel;
begin
  AddStack('TGFBitMapList.ProcDel');
  aBM[ni]:=aBM[oi];
  DelStack;
end;

procedure TGFBitMapList.DelBM;
var p: PGFBitMap;
begin
  AddStack('TGFBitMapList.DelBM');
  p:=GetBM(Index); p.Name:=''; p.bm.Free;
  DelStack;
end;

procedure TGFBitMapList.Clear;
var i: longint;
begin
	AddStack('TGFBitMapList.Clear');
  for i:=0 to Count-1 do DelBM(i);
  inherited Clear;
  DelStack;
end;

function TGFBitMapList.GetStrBitMap;
begin
  AddStack('TGFBitMapList.GetStrBitMap');
  result:=BitMapToStr(GetBM(Index).bm);
  DelStack;
end;

procedure TGFBitMapList.SetStrBitMap;
begin
  AddStack('TGFBitMapList.SetStrBitMap');
  StrToBitMap(Value,GetBM(Index).bm);
  DelStack;
end;

function TGFBitMapList.BitMapToStr;
begin
  AddStack('TGFBitMapList.BitMapToStr');
  ss.Size:=0; ss.Seek(0,soBeginning); bm.SaveToStream(ss); result:=ss.DataString;
  DelStack;
end;

procedure TGFBitMapList.StrToBitMap;
var ost: longint;
begin
  ost:=AddStack('TGFBitMapList.StrToBitMap');
  try
  	if s='' then raise EInvalidGraphic.Create('');
    ss.Size:=0; ss.Seek(0,soBeginning); ss.WriteString(s); ss.Seek(0,soBeginning);
	  bm.Width:=0; bm.Height:=0; bm.LoadFromStream(ss);
  except
    on EInvalidGraphic do SetStack(ost);
    on EStreamError do SetStack(ost);
  end;
  DelStack;
end;

procedure TGFBitMapList.LoadFromDB(lsDsgn: TGFBitMapList; const PartIni: string);
var i: longint;
	bm1: TBitMap;
begin
  AddStack('TGFBitMapList.LoadFromDB');
  Clear;
  for i:=0 to lsDsgn.Count-1 do with lsDsgn.GetBM(i)^ do begin
  	FAddBM(lsDsgn[i],Name,0,bm1); bm1.Assign(bm);
  end;
  if Count>0 then if PartIni<>'' then LoadFromDB(tDCMBMP+'.'+fDcmBmpPART+'='+QQs(PartIni),[]);
  DelStack;
end;

procedure TGFBitMapList.LoadFromDB(const where: string; Opt: TGFBitMapLoadOpt);
var r: TRecDB;
  lsm: TMemGKList;
  i,j,l: longint;
  s: string;
  a: TArrInt;
begin
  AddStack('TGFBitMapList.LoadFromDB(where)');
  if DBBmp.ActiveNoNil then begin
    l:=0;
    with GetQuery do begin
      SetArrayList(sC_LIST,[tDCMBMP+'.'+fDcmBmpCOD,tDCMBMP+'.'+fDCMBMP,tRECNO(tDCMBMP)]);
      if gfbmUserName in Opt then AddArgList(sC_LIST,tDCMBMP+'.'+fUSERNAME);
      PartSelect(tDCMBMP,'',where); r:=DBBmp; lsm:=TMemGKList.Create(r); i:=RecordCount;
      if gfbmUser in Opt then Capacity:=i;
      for i:=1 to i do begin
        lsm.GetFromQuery; s:=TrimRight(Fields[0].AsString);
        if gfbmUserName in Opt then IncD(s,cCalcBmp+TrimRight(Fields[3].AsString));
        if gfbmUser in Opt then AddBM(s,'',r[fDCMBMP],r.Recno)
        else if Find(s,j) then ReDefine(j,r[fDCMBMP])
        else begin
          if l=Length(a) then SetLength(a,l+10);
          a[l]:=r.Recno; Inc(l);
        end;
        Next;
      end;
    end;
    FreeQuery;
    if not(gfbmUser in Opt) then DBBmp.DelRec(a,l);
  end;
  DelStack;
end;

function TGFBitMapList.FileToStr;
type
  TGFBmpFile = record
  	Path,Name: TFileName;
  end;
  function GetBmpPath(const FileName: TFileName): TGFBmpFile;
  begin
    AddStack('TGFBitMapList.FileToStr.GetBmpPath');
    with result do begin
      Path:=ExtractFilePath(FileName);
      if Path='' then begin
        Path:=ExeDir; Name:=IfThen(FileName<>'',Path+FileName);
      end
      else Name:=FileName;
      Name:=TrimRight(StrDivDlm(CRLF,Name)[1]);
    end;
    DelStack;
  end;
var bm: TBitMap;
	ost: longint;
begin
  ost:=AddStack('TGFBitMapList.FileToStr');
  result:=''; bm:=TBitMap.Create;
  try
    try
	    bm.Width:=0; bm.Height:=0; bm.LoadFromFile(GetBmpPath(FileName).Name);
      result:=BitMapToStr(bm);
    except
      on EInvalidGraphic do SetStack(ost);
      on EFOpenError do SetStack(ost);
    end;
  finally
    bm.Free;
  end;
  DelStack;
end;

procedure TGFBitMapList.ReDefine;
begin
  AddStack('TGFBitMapList.ReDefine');
  with GetBM(Index)^ do begin
	  StrToBitMap(sBitMap,bm); ReDef:=lReDef;
  end;
  DelStack;
end;

{ TDBDcmList }
constructor TDBDcmList.Create;
var q: TMulQuery;
	i,n,l: longint;
  a: TArrRecDB;
begin
	AddStack('TDBDcmList.Create');
	Sorted:=true;
  if DBDcm.ActiveNoNil then begin
    q:=TMulQuery.CreateConnection;
    with q do begin
      try
        PartSelect(tDCM,[fDCM,'NUMSAVE',fDcmDCM,iif(IsChkSum,'CHKSUM',0)],'','','',false);
        CopyFromRecDB(a,[DBDcm]); // Ambiguous overloaded call to 'Create'
        lsm:=TMemGkList.Create(a,q); q.Open; SetLength(aInf,q.RecordCount); l:=0;
        while not Eof do begin
        	if not IntObjFindAdd(Self,TrimRight(Fields[0].AsString),i,n,l) then with aInf[n] do begin
            NumSave:=Fields[1].AsInteger; MemDcm:=Fields[2].AsInteger; ChkSum:=Fields[3].AsInteger;
          end;
          Next;
        end;
        SetLength(aInf,l);
      finally
        Free;
      end;
    end;
  end;
  DelStack;
end;

{ TGFIdStrList }
function TGFIdStrList.GetObj;
begin
  AddStack('TGFIdStrList.GetObj');
  result:=@a[IntObj(Self,Index)];
  DelStack;
end;

procedure TGFIdStrList.Delete;
begin
  AddStack('TGFColList.Delete');
  SLObjIndDel(Self,Index,ProcDel,false);
  inherited Delete(Index);
  DelStack;
end;

procedure TGFIdStrList.ProcDel;
begin
  AddStack('TGFIdStrList.ProcDel');
  a[ni]:=a[oi];
  DelStack;
end;

{ EDcmBreakError }
constructor EDcmBreakError.CreateErr;
begin
	AddStack('EDcmBreakError.CreateErr');
	inherited Create('');
  Vert:=AVert; Key:=AKey;
  DelStack;
end;

{ TGenForm }
constructor TGenForm.Create;
begin
	AddStack('TGenForm.Create',Self);
{$IFDEF LIBTEST}
  TestObjs;
{$ENDIF}
  SetLength(FParams.Arr,1); FCurParams:=0; //FIntervalBetwRows:=0;
	inherited Create(AOwner);
  bmPaint:=TBitMap.Create;
  lsBitMap:=TGFBitMapList.Create; FScalePrc:=1; ColorW:=clBtnFace; Color1:=clWhite;
  TabStop:=false; scX:=0; scY:=0;
  FState:=gsDesign; FLeaf:=1; FPage:=1; FPgSmall:=1;
  CurCanvas:=Canvas; ZeroMemory(@HFHeight,SizeOf(HFHeight)); Finalize(aHFPage);
	LsFont:=TList.Create;
  FObjects:=TList.Create; FSelObjects:=TList.Create; FFillObj:=TList.Create;
  SetLength(FPages,10);

//FObjects.Capacity:=100000; FSelObjects.Capacity:=FObjects.Capacity; FFillObj.Capacity:=FObjects.Capacity;

  TmpList:=TList.Create; TmpList1:=TList.Create;
  TmpStr:=TStringList.Create;
  Timer:=TTimer.Create(Self);
  Timer.Enabled:=false; Timer.Interval:=1;
  TmpCtrl:=TControl.Create(Self);
  TmpCtrl.Parent:=Self; TmpCtrl.SetBounds(0,0,0,0);
  Params.Arr[FCurParams]:=PrmDef;
  Init; FState:=gsView; State:=gsDesign; nActivePaint:=-1; SetLength(aCurPagePart,10);
  DelStack;
end;

class function TGenForm.PrmDef;
begin
  AddStack('TGenForm.PrmDef');
  Finalize(result); ZeroMemory(@result,SizeOf(result));
  with result do begin
		StdFormat:=true; NFormat:=frmA4;
    GridLineMin:=1; GridLineWidth:=3; SetMemory(@aBreak,SizeOf(aBreak));
    PrmNum:=FmtNum; PrmDate:=FmtDate;
    SpotMm:=Rect(3,3,3,3); SizeMm:=GetStdSize(NFormat,Orientation); Name:='Основной формат';
  end;
  DelStack;
end;

procedure TGenForm.Init;
begin
	AddStack('TGenForm.Init',Self);
  if DelObj then begin
  	ClearAllSelection; DestroyObjects(false);
  end;
  SetKbdCtrl;
  ColCount:=1; GridX[0]:=FSpot.Left+WdtLnSel+1; GridX[1]:=GridX[0]+GridLine(false);
  RowCount:=1; GridY[0]:=FSpot.Top +WdtLnSel+1; GridY[1]:=GridY[0]+GridLine(true);
  DelStack;
end;

function TGenForm.Pix;
begin
  AddStack('TGenForm.Pix');
  result:=max(1,Ceil(w/10*aRate[lY]));
  DelStack;
end;

function TGenForm.GetColCount;
begin
  AddStack('TGenForm.GetColCount',Self);
  result:=high(FGridX);
  DelStack;
end;

function TGenForm.GetRowCount;
begin
  AddStack('TGenForm.GetRowCount',Self);
  result:=high(FGridY);
  DelStack;
end;

procedure TGenForm.SetColCount;
begin
  AddStack('TGenForm.SetColCount',Self);
  SetLength(FGridX,Value+1);
  DelStack;
end;

procedure TGenForm.SetRowCount;
begin
  AddStack('TGenForm.SetRowCount',Self);
  SetLength(FGridY,Value+1);
  DelStack;
end;

procedure FClearLevel(var a: TGFLevel);
var i: longint;
begin
	AddStack('GenForm.FClearLevel');
  for i:=low(a) to high(a) do with a[i] do begin
    LsLen.Free; LsCut.Free;
  end;
  DelStack;
end;

destructor TGenForm.Destroy;
var fl: boolean;
  i: TGFAddPartList;
begin
	AddStack('TGenForm.Destroy',Self);
	DestroyObjects(false); ClearDcmObj(true); ClearPart; ClearFonts;
  FObjects.Free; FSelObjects.Free; FFillObj.Free; LsPart.Free;
  ColHead.Free; ColFoot.Free;
  for i:=low(LsPart1) to high(LsPart1) do LsPart1[i].Free;
  IdStr.Free; ClearLevel; TmpList.Free; TmpList1.Free;
  TmpStr.Free; LsFont0.Free; 
  LsFont.Free; bmPaint.Free; bmAngle.Free;
  bmAngPrn.Free; bmStretch.Free; lsBitMap.Free; EdlsBitMap.Free; LsIdent.Free;
  InterMouse.Free; LsBlockLeaf.Free;
  for fl:=false to true do aColNm[fl].Free;
  inherited Destroy;
  DelStack;
end;

procedure TGenForm.ClearLevel;
begin
  AddStack('TGenForm.ClearLevel',Self);
  FClearLevel(aLevel); SetLength(aLevel,cnt);
  DelStack;
end;

function TGenForm.IdentNew;
var n: longint;
  lSet: boolean;
begin
  AddStack('TGenForm.IdentNew',Self);
  lSet := MyVarType(Index)=varInteger; n:=LsIdent.Count-IfThen(lSet,1);
  if Length(aIdent)=n then SetLength(aIdent,IfThen(n=0,10,n shl 1));
  result:=@aIdent[n];
  if lSet
  then LsIdent.Objects[Index]:=Pointer(n)
  else LsIdent.AddObject(Index,Pointer(n));
  DelStack;
end;

procedure TGenForm.ClearFonts;
var i: longint;
begin
  AddStack('TGenForm.ClearFonts',Self);
  if Assigned(LsFont) then begin
    for i:=0 to LsFont.Count-1 do TGFPackFont(LsFont[i]).Free;
    LsFont.Clear; 
  end;
  DelStack;
end;

procedure TGenForm.DestroyObjects;
var i: longint;
begin
	AddStack('TGenForm.DestroyObjects',Self);
	if ClrSel then ClearSelection([vsObj]);
	for i:=0 to FObjects.Count-1 do Dispose(PGFObj(FObjects[i]));
	FObjects.Clear; FFillObj.Clear;
  DelStack;
end;

procedure TGenForm.WMGetDlgCode;
begin
	AddStack('TGenForm.WMGetDlgCode',Self);
	inherited;
  Msg.Result:=dlgc_WantArrows;
  DelStack;
end;

procedure TGenForm.SetState;
var fl: boolean;
  i: TGFAddPartList;
begin
	AddStack('TGenForm.SetState',Self);
	if FState<>Value then begin
	  FState:=Value; CalcRate; SetSizeMm;
    if FState=gsDesign then begin
      BvRect:=TBevel.Create(Self);
      with BvRect do begin
        Parent:=Self;	Shape:=bsFrame; Style:=bsRaised; Visible:=false; SetBounds(0,0,0,0);
      end;
      FreeAndNil(LsFont0);
    end
    else begin
      FreeAndNil(BvRect); LsFont0:=TFontIndexList.Create; LsFont0.OnGetFont:=GetFont0
    end;
    if (FState=gsView) or (FState=gsPrint) and Assigned(ProcBeforeNewPage) then begin
    	if not Assigned(FDcmObj) then begin
        FDcmObj:=TList.Create; LsPart:=SortStrListCreate;
        if Length(aPart)=0 then SetLength(aPart,10);
        aColNm[false]:=TGFColList.Create; aColNm[false].Sorted:=true; aColNm[true]:=SortStrListCreate;
        ColHead:=SortStrListCreate; ColFoot:=SortStrListCreate;
        LsBlockLeaf:=SortStrListCreate;
        for i:=low(LsPart1) to high(LsPart1) do LsPart1[i]:=SortStrListCreate;
      end;
    end
    else begin
    	ClearLevel; ClearPart; FreeAndNil(LsPart); aPart:=nil; ClearDcmObj(true);
      for fl:=false to true do FreeAndNil(aColNm[fl]);
      FreeAndNil(ColHead); FreeAndNil(ColFoot); FreeAndNil(LsBlockLeaf);
      for i:=low(LsPart1) to high(LsPart1) do FreeAndNil(LsPart1[i]);
    end;
    if FState in [gsView,gsPrint] then SortStrListCreate(LsIdent)
    else begin
      aIdent:=nil; FreeAndNil(LsIdent);
    end;
    if FState<>gsPrint then Invalidate;
  end;
  DelStack;
end;

{ Установка цветов и шрифтов }
procedure TGenForm.WMSchem;
begin
	AddStack('TGenForm.WMSchem',Self);
  ColorW:=msg.Schem.ColorW; Color1:=msg.Schem.Color1;
  DelStack;
end;

// Нарисовать
procedure TGenForm.BeforePaint;
var i,j,wl: longint;
  s: string;
  oCanvas: TCanvas;
begin
  AddStack('TGenForm.BeforePaint',Self);
	if not noPaint then begin
	  oCanvas:=CurCanvas;
  	if (FState<>gsPrint) and Assigned(bmPaint) then CurCanvas:=bmPaint.Canvas;
    if FState in [gsDesign,gsView] then with CurCanvas do begin
      Brush.Color:=IfThen((FState=gsDesign) or InGet,ColorW,Color1);
      if InGet then FillRect(Rect(0,0,Width,Height))
      else begin
	      Pen.Color:=clBlack; Pen.Style:=psSolid; Pen.Width:=1; Rectangle(0,0,Width,Height);
      end;
    end;
    if (FState=gsView) and not InGet then begin
      //Application.ProcessMessages;
      SetMapMode(CurCanvas.Handle,MM_ISOTROPIC);
      SetWindowExtEx(CurCanvas.Handle,nround(Width/ScalePrc),nround(Height/ScalePrc),nil);
      SetViewPortExtEx(CurCanvas.Handle,Width,Height,nil);
      SetViewPortOrgEx(CurCanvas.Handle,0,0,nil);
    end;
    // Координатная сетка
    if FState=gsDesign then with CurCanvas do begin
      DefaultFont(Font); Font.Height:=2-WdtLnSel;
      wl:=GridY[high(FGridY)]+FSpot.Bottom+otsLnsel+LineWidth([gfwY]);
      for i:=0 to high(FGridX) do begin
        Pen.Style:=psDot;
        MoveTo(GridX[i],GridY[0]); LineTo(GridX[i],GridY[high(FGridY)]);
        Pen.Style:=psSolid;
        MoveTo(GridX[i],otsLnSel); LineTo(GridX[i],otsLnSel+WLnSel-1);
        MoveTo(GridX[i],wl); LineTo(GridX[i],wl+WLnSel-1);
      end;
      i:=0; Dec(wl,otsLnSel+1);
      while i<Length(FGridX) do begin
        s:=IntToStr(i); j := GridX[i] - TxtWidth(s) shr 1;
        TextOut(j,1,s); TextOut(j,wl,s); Inc(i,10);
      end;
      wl:=GridX[high(FGridX)]+FSpot.Right+otsLnsel+LineWidth;
      for i:=0 to high(FGridY) do begin
        Pen.Style:=psDot;
        MoveTo(GridX[0],GridY[i]); LineTo(GridX[high(FGridX)],GridY[i]);
        Pen.Style:=psSolid;
        MoveTo(otsLnSel,GridY[i]); LineTo(otsLnSel+WLnSel-1,GridY[i]);
        MoveTo(wl,GridY[i]); LineTo(wl+WLnSel-1,GridY[i]);
      end;
      i:=0; Inc(wl,WLnSel);
      while i<=high(FGridY) do begin
        s:=IntToStr(i); j := GridY[i] - TxtHeight(s) shr 1;
        TextOut(1,j,s); TextOut(wl-TxtWidth(s),j,s); Inc(i,10);
      end;
    end;
    // Объекты
    PaintObj(FObjects);
    // Отмеченные ячейки
    PaintSelected;
    // Обрамление
    PaintFill;
    CurCanvas:=oCanvas;
  end;
  DelStack;
end;

procedure TGenForm.Paint;
var i: longint;
  tf: TFldEdit;
begin
	AddStack('TGenForm.Paint',Self);
	if not noPaint then begin
    if Assigned(bmPaint) then CurCanvas.Draw(0,0,bmPaint) else BeforePaint;
    IfThenNotify(FOnAfterPaint,Self);
    if FState=gsView then begin
      for i:=0 to ControlCount-1 do
        if IsClass(Controls[i],TFldEdit,pointer(tf)) then InvalidateAll(tf);
      TPaintControl.PaintAll(Self);
    end;
  end;
  DelStack;
end;

procedure TGenForm.PaintAll;
begin
	AddStack('TGenForm.PaintAll',Self);
  if not Painted then begin
	  Painted:=true; BeforePaint; Invalidate; Painted:=false;
  end;
  DelStack;
end;

function TGenForm.GetScalePrc;
begin
	AddStack('TGenForm.GetScalePrc',Self);
	result:=IfThen(FState=gsView,FScalePrc,1);
  DelStack;
end;

procedure TGenForm.SetScalePrc;
var onp: boolean;
begin
	AddStack('TGenForm.SetScalePrc',Self);
	if (FScalePrc<>Value) and (FState=gsView) then begin
    FScalePrc:=Value; onp:=NoPaint;
    try
    	NoPaint:=true; SetSizeMm;
    finally
	    NoPaint:=onp;
    end;
    PaintAll;
  end;
  DelStack;
end;

{ СЕТКА }

// Ширина и высота в мм
procedure TGenForm.SetSizeMm;
const WdtLnSel2 = WdtLnSel shl 1;
var w,h: longint;
begin
	AddStack('TGenForm.SetSizeMm',Self);
  if SizeNoLimit then begin
    w:=nround((GridX[high(FGridX)]+FSpot.Right+LineWidth)*ScalePrc);
    h:=nround((GridY[high(FGridY)]+FSpot.Bottom+LineWidth([gfwY]))*ScalePrc);
  end
  else begin
    w:=Params.Arr[FCurParams].SizeMm.cX; if w<>0 then w:=nround(w*aRate[false]*ScalePrc);
    h:=Params.Arr[FCurParams].SizeMm.cY; if h<>0 then h:=nround(h*aRate[true]*ScalePrc);
    if FState=gsDesign then begin
      w:=max(w+WdtLnSel2,GridX[high(FGridX)]+FSpot.Right+WdtLnSel+LineWidth);
      h:=max(h+WdtLnSel2,GridY[high(FGridY)]+FSpot.Bottom+WdtLnSel+LineWidth([gfwY]));
    end;
  end;
  SetBounds(Left,Top,w,h);
  DelStack;
end;

procedure TGenForm.IncRowCount;
begin
  AddStack('TGenForm.IncRowCount',Self);
  RowCount:=RowCount+d2;
  DelStack;
end;

procedure TGenForm.IncColCount;
begin
  AddStack('TGenForm.IncColCount',Self);
  ColCount:=ColCount+d2;
  DelStack;
end;

function TGenForm.SizeNoLimit(nParams: longint = NegDef): boolean;
begin
  result:=SizeNoLimit(Params,ReplNeg(nParams,FCurParams));
end;

class function TGenForm.SizeNoLimit(const Params: TGFParams; nParams: longint): boolean;
begin
  AddStack('TGenForm.SizeNoLimit');
  with Params.Arr[nParams] do result:=SizeNoLimit(StdFormat,SizeMm);
  DelStack;
end;

class function TGenForm.SizeNoLimit(StdFormat: boolean; const SizeMm: TSize): boolean;
begin
  result := StdFormat and (SizeMm.cX=0);
end;

procedure TGenForm.SetBounds;
var oCanvas: TCanvas;
  fl: boolean;
  ost: longint;
begin
	ost:=AddStack('TGenForm.SetBounds',Self);
	inherited SetBounds(ALeft,ATop,AWidth,AHeight);
  if FState<>gsPrint then begin
    if Assigned(bmPaint) then begin
    	fl := CurCanvas=bmPaint.Canvas; AWidth:=bmPaint.Width; AHeight:=bmPaint.Height;
    end
    else begin
  	  fl:=false; AWidth:=0; AHeight:=0;
    end;
    if (Width<>AWidth) or (Height<>aHeight) then begin
      oCanvas:=CurCanvas; bmPaint.Free; bmPaint:=TBitMap.Create;
      try
        bmPaint.Width:=Width; bmPaint.Height:=Height;
      except
        on EOutOfResources do begin
          SetStack(ost);
          FreeAndNil(bmPaint);
        end;
      end;
      if Assigned(bmPaint) and fl then CurCanvas:=bmPaint.Canvas else CurCanvas:=oCanvas;
    end;
  end;
  if InGet
  then WinSize(Params.Arr[FCurParams].SizeMm,nround(Width/aRate[false]),nround(Height/aRate[true]));
  DelStack;
end;

// Установка толщины линий сетки
procedure TGenForm.SetParams;
  procedure CorrObj(pv: PGFObj);
    procedure CorrLn(var ln: Byte);
    begin
      AddStack('TGenForm.SetParams.CorrObj.CorrLn',Self);
      with Params.Arr[FCurParams] do if aGFLines[ln].Width>GridLineWidth
      then ln:=GFTypeLine(GridLineWidth+1,SeekColor(aGFLines[ln].Color));
      DelStack;
    end;
  begin
  	AddStack('TGenForm.SetParams.CorrObj',Self);
    CorrLn(pv.LnLeft); CorrLn(pv.LnTop); CorrLn(pv.LnRight); CorrLn(pv.LnBottom);
    DelStack;
  end;
  procedure SetSpot(var SpotMm,FSpot: longint; wh: longint; Rate: Double);
  begin
    AddStack('TGenForm.SetParams.SetSpot',Self);
    if not SizeNoLimit then EnsureSelf(SpotMm,0,wh);
    FSpot:=nround(SpotMm*Rate);
    DelStack;
  end;
var i,j,w: longint;
begin
	AddStack('TGenForm.SetParams',Self);
  FParams:=GFCopyParams(v); w:=Params.Arr[FCurParams].GridLineWidth;
  EnsureSelf(FCurParams,low(FParams.Arr),high(FParams.Arr));
  if Params.Arr[FCurParams].GridLineWidth<>w then begin
  	for i:=0 to FObjects.Count-1 do CorrObj(PGFObj(PObjects[i]));
    if FState=gsDesign then for i:=0 to PageCount-1 do with FPages[i] do
	  	for j:=low(av) to high(av) do CorrObj(@av[j]);
  end;
  with FParams.Arr[FCurParams] do begin
    SetSpot(SpotMm.Left,FSpot.Left,SizeMm.cX,aRate[false]);
    SetSpot(SpotMm.Right,FSpot.Right,SizeMm.cX,aRate[false]);
    SetSpot(SpotMm.Top,FSpot.Top,SizeMm.cY,aRate[true]);
    SetSpot(SpotMm.Bottom,FSpot.Bottom,SizeMm.cY,aRate[true]);
  end;
  DelStack;
end;

procedure TGenForm.SetCurParams;
var fl: boolean;
begin
	AddStack('TGenForm.SetCurParams',Self);
  EnsureSelf(v,low(Params.Arr),high(Params.Arr)); fl := FCurParams<>v;
  FCurParams:=v; Params:=Params;
  if fl then SetSizeMm;
  DelStack;
end;

procedure TGenForm.SetLeaf;
begin
	AddStack('TGenForm.SetLeaf',Self);
  FLeaf:=EnsureRange(v,1,PageCount);
  if FState=gsDesign then begin
    RestCurLeaf; AutoSize;
  end;
  DelStack;
end;

procedure TGenForm.SetBlockLeaf;
begin
  AddStack('TGenForm.SetBlockLeaf',Self);
  if FBlockLeaf<>v then begin
    BlockLeafAdd(1); FBlockLeaf:=v; BlockLeafBeg:=FLeaf-1; 
  end;
  DelStack;
end;

procedure TGenForm.BlockLeafAdd;
begin
  AddStack('TGenForm.BlockLeafAdd',Self);
  if FBlockLeaf<>''
  then IgnoreSlAddInt(LsBlockLeaf,FBlockLeaf,FLeaf-DecLeaf-BlockLeafBeg);
  DelStack;
end;

procedure TGenForm.SaveCurLeaf;
var i: longint;
begin
  AddStack('TGenForm.SaveCurLeaf',Self);
  with FPages[FLeaf-1] do begin
    sv.ColCount:=high(FGridX); sv.RowCount:=high(FGridY);
    SetLength(av,FFillObj.Count);
    for i:=0 to FFillObj.Count-1 do av[i]:=PGFObj(FFillObj[i])^;
  end;
  DelStack;
end;

procedure TGenForm.RestCurLeaf;
var i: longint;
	onp: boolean;
begin
  AddStack('TGenForm.RestCurLeaf',Self);
  onp:=NoPaint;
  try
    NoPaint:=true; Init;
    with FPages[FLeaf-1] do begin
      ColCount:=sv.ColCount; RowCount:=sv.RowCount;
      for i:=low(av) to high(av) do begin
        AddObj(av[i]); ObjBringToFront(i);
      end;
    end;
  finally
	  NoPaint:=onp;
  end;
  AddDefObj;
  DelStack;
end;

function TGenForm.GetGridX;
begin
	AddStack('TGenForm.GetGridX',Self);
	result:=FGridX[Index].Crd;
  DelStack;
end;

function TGenForm.GetGridY;
begin
	AddStack('TGenForm.GetGridY',Self);
	result:=FGridY[Index].Crd;
  DelStack;
end;

procedure TGenForm.SetGridX;
begin
	AddStack('TGenForm.SetGridX',Self);
	FGridX[Index].Crd:=Value;
  DelStack;
end;

procedure TGenForm.SetGridY;
begin
	AddStack('TGenForm.SetGridY',Self);
	FGridY[Index].Crd:=Value;
  DelStack;
end;

{ ОБРАМЛЕНИЕ }

function TGenForm.RectDefault;
begin
  AddStack('TGenForm.RectDefault');
  if Assigned(ARect) then result:=ARect^ else result:=Rect(0,0,high(FGridX),high(FGridY));
  DelStack;
end;

// Нарисовать обрамления
procedure TGenForm.PaintFill;
var i,j,px,py: longint;
	tl: TGFLine;
	r,r1: TRect;
  w: TLineWidth;
begin
	AddStack('TGenForm.PaintFill',Self);
	if not noPaint then begin
    // Заполнить массивы линий
    GetArrFill(FillRec,ARect); r1:=RectDefault(ARect);
    // Нарисовать линии по X
    for i:=r1.Top to r1.Bottom do
      for j:=max(1,r1.Left) to r1.Right do begin
        if FillRec.x[i,j]<2 then continue;
        tl:=aGFLines[FillRec.x[i,j]]; tl.Width:=Pix(true,tl.Width);
        with CurCanvas do
          if tl.Width=1 then begin
            {Pen.Color:=tl.Color;
            MoveTo(GridXMode(j-1,taCenter),GridYMode(i,taCenter));
            LineTo(GridXMode(j,taCenter)+1,GridYMode(i,taCenter));}
            pY:=GridY[i];
            for pX:=GridX[j-1] to GridX[j] do Pixels[pX,pY]:=tl.Color;
          end
          else begin
            Brush.Color:=tl.Color;
            FillRect(Rect(GridX[j-1],GridY[i]-tl.Width shr 1,
              GridX[j]+1,GridY[i]-tl.Width shr 1+tl.Width));
          end;
      end;
    // Нарисовать линии по Y
    for i:=r1.Left to r1.Right do
      for j:=max(1,r1.Top) to r1.Bottom do begin
        if FillRec.y[i,j]<2 then continue;
        tl:=aGFLines[FillRec.y[i,j]]; tl.Width:=Pix(false,tl.Width);
        with CurCanvas do begin
          r.Left := GridX[i] - tl.Width shr 1;
          r.Right:=r.Left+tl.Width;
          r.Top:=GridY[j-1];
          r.Bottom:=GridY[j]+1;
          if i>0 then begin
            if FillRec.x[j-1,i]>1
            then r.Top:=GridY[j-1]-(Pix(true,aGFLines[FillRec.x[j-1,i]].Width) shr 1);
            if FillRec.x[j,i]>1 then begin
              w:=Pix(true,aGFLines[FillRec.x[j,i]].Width);
              r.Bottom:=GridY[j]-w shr 1+w;
            end;
          end;
          if i<high(FGridX) then begin
            if FillRec.x[j-1,i+1]>1
            then MinSelf(r.Top,GridY[j-1]-Pix(true,aGFLines[FillRec.x[j-1,i+1]].Width) shr 1);
            if FillRec.x[j,i+1]>1 then begin
              w:=Pix(true,aGFLines[FillRec.x[j,i+1]].Width);
              MaxSelf(r.Bottom,GridY[j]-w shr 1+w);
            end;
          end;
          if r.Right-r.Left>1 then begin
            Brush.Color:=tl.Color; FillRect(r);
          end
          else begin
            //Pen.Color:=tl.Color; MoveTo(r.Left,r.Top); LineTo(r.Left,r.Bottom);
            for pY:=r.Top to r.Bottom-1 do Pixels[r.Left,pY]:=tl.Color;
          end;
        end;
      end;
  end;
  DelStack;
end;

procedure TGenForm.GetArrFill;
var j: longint;
  procedure Ln1(lnobj: byte; var ln: TGFFillRec1; v,l,h: longint);
  begin
	  AddStack('TGenForm.GetArrFill.Ln1',Self);
    if (lnobj>0) and InRange(v,l,h) then begin
      ln[v,j]:=lnobj;
      if lnobj>1 then with Params.Arr[FCurParams],aGFLines[ln[v,j]] do begin
        if Width>GridLineWidth then ln[v,j]:=GFTypeLine(GridLineWidth+1,SeekColor(Color));
        if Width<GridLineMin then ln[v,j]:=GFTypeLine(GridLineMin,SeekColor(Color));
      end;
    end;
    DelStack;
  end;
var i: longint;
	r: TRect;
begin
  AddStack('TGenForm.GetArrFill',Self);
  r:=RectDefault(ARect);
  if Length(result.x)<r.Bottom+1 then SetLength(result.x,r.Bottom+1);
  for i:=r.Top to r.Bottom do begin
    if Length(result.x[i])<r.Right+1 then SetLength(result.x[i],r.Right+1);
    for j:=max(1,r.Left) to r.Right do result.x[i,j]:=0;
  end;
  if Length(result.y)<r.Right+1 then SetLength(result.y,r.Right+1);
  for i:=r.Left to r.Right do begin
    if Length(result.y[i])<r.Bottom+1 then SetLength(result.y[i],r.Bottom+1);
    for j:=max(1,r.Top) to r.Bottom do result.y[i,j]:=0;
  end;
  for i:=0 to FFillObj.Count-1 do with PGFObj(FFillObj[i])^ do begin
    if State in [osHide,osSave,osSpace] then continue;
    for j:=max(r.Top,Top+1) to min(r.Bottom,Bottom) do begin
      Ln1(LnLeft,result.y,Left,r.Left,r.Right);
      Ln1(LnRight,result.y,Right,r.Left,r.Right);
    end;
    for j:=Left+1 to Right do begin
      Ln1(LnTop,result.x,Top,r.Top,r.Bottom);
      Ln1(LnBottom,result.x,Bottom,r.Top,r.Bottom);
    end;
  end;
  DelStack;
end;

procedure TGenForm.PaintFillAll;
var oCanvas: TCanvas;
begin
	AddStack('TGenForm.PaintFillAll',Self);
  oCanvas:=CurCanvas; PaintFill(ARect);
  if Assigned(bmPaint) then begin
    CurCanvas:=bmPaint.Canvas; PaintFill(ARect); CurCanvas:=oCanvas;
  end;
  DelStack;
end;

// Поместить объект над всеми объектами
procedure TGenForm.FBringToFront;
var i: longint;
begin
	AddStack('TGenForm.FBringToFront',Self);
  i:=FFillObj.IndexOf(pv);
  if i>-1 then begin
  	FFillObj.Delete(i); FFillObj.Add(pv);
  end;
  DelStack;
end;

procedure TGenForm.SelBringToFront;
begin
	AddStack('TGenForm.SelBringToFront',Self);
	FBringToFront(PGFObj(FSelObjects[Index]));
  DelStack;
end;

procedure TGenForm.ObjBringToFront;
begin
	AddStack('TGenForm.ObjBringToFront',Self);
	FBringToFront(PGFObj(FObjects[Index]));
  DelStack;
end;

{ ОБЪЕКТЫ }

// Корректировка атрибутов объекта
function TGenForm.CorrObj;
begin
	AddStack('TGenForm.CorrObj',Self);
	result:=v;
  with result do begin
    EnsureSelf(Left,0,high(FGridX)-1);
  	EnsureSelf(Top,0,high(FGridY)-1);
    EnsureSelf(Right,Left+1,high(FGridX));
    EnsureSelf(Bottom,Top+1,high(FGridY));
  end;
  DelStack;
end;

// Кол-во объектов
function TGenForm.GetObjectCount;
begin
	AddStack('TGenForm.GetObjectCount',Self);
	result:=FObjects.Count;
  DelStack;
end;

// Кол-во отмеченных объектов
function TGenForm.GetSelObjectCount;
begin
	AddStack('TGenForm.GetSelObjectCount',Self);
	result:=FSelObjects.Count;
  DelStack;
end;

// Объект № Index
function TGenForm.GetObjects;
begin
	{$IFDEF STACKALL}AddStack('TGenForm.GetObjects',Self);{$ENDIF}
  result:=GetPObjects(Index)^;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TGenForm.GetPObjects;
begin
	{$IFDEF STACKALL}AddStack('TGenForm.GetPObjects',Self);{$ENDIF}
	if Index<FObjects.Count	then result:=PGFObj(FObjects[Index])
  else raise EGenFormObj.CreateFmt('Некорректный номер объекта: %d',[Index]);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TGenForm.SetObjects;
begin
	AddStack('TGenForm.SetObjects',Self);
	if Index<FObjects.Count	then (PGFObj(FObjects[Index]))^:=CorrObj(v)
  else raise EGenFormObj.CreateFmt('Некорректный номер объекта: %d',[Index]);
  DelStack;
end;

// Отмеченный объект № Index
function TGenForm.GetSelObjects;
begin
	AddStack('TGenForm.GetSelObjects',Self);
  result:=GetPSelObjects(Index)^;
  DelStack;
end;

function TGenForm.GetPSelObjects;
begin
	AddStack('TGenForm.GetSelPObjects',Self);
	if Index<FSelObjects.Count then result:=PGFObj(FSelObjects[Index])
  else raise EGenFormObj.CreateFmt('Некорректный номер отмеченного объекта: %d',[Index]);
  DelStack;
end;

procedure TGenForm.SetSelObjects;
var pv: PGFObj;
begin
	AddStack('TGenForm.SetSelObjects',Self);
	if Index>=FSelObjects.Count then raise EGenFormObj.CreateFmt(
  	'Некорректный номер отмеченного объекта: %d',[Index]);
  pv:=FSelObjects[Index]; pv^:=CorrObj(vv); RightSelfDel(pv.Text,CRLF);
  DelStack;
end;

// Объект в порядке обрамления № Index
function TGenForm.PFillObj;
begin
	AddStack('TGenForm.FillObj',Self);
	if Index<FFillObj.Count	then result:=PGFObj(FFillObj[Index])
  else raise EGenFormObj.CreateFmt('Некорректный номер объекта: %d',[Index]);
  DelStack;
end;

// Номер отмеченного объекта в основном списке
// (Index - номер в списке отмеченных объектов)
function TGenForm.NumSelObj;
begin
	AddStack('TGenForm.NumSelObj',Self);
	if Index<FSelObjects.Count
  then result:=FObjects.IndexOf(PGFObj(FSelObjects[Index]))
  else raise EGenFormObj.CreateFmt(
  	'Некорректный номер отмеченного объекта: %d',[Index]);
  DelStack;
end;

// Добавить объект
function TGenForm.AddObj;
begin
	AddStack('TGenForm.AddObj',Self);
  New(result);
  if lCorrObj then result^:=CorrObj(v) else result^:=v;
  if FState=gsDesign then result.State:=osShow;
  FObjects.Add(result);
  if result.Selected then begin
  	TmpList.Clear; TmpList.Add(result);
    if SelectObjs(TmpList,true) and (FState=gsDesign) then PaintFillAll;
  end;
  FFillObj.Insert(0,result);
  DelStack;
end;

// Добавить объект по умолчанию
procedure TGenForm.AddDefObj;
var v: TGFObj;
begin
	AddStack('TGenForm.AddDefObj',Self);
	if ObjectCount=0 then begin
    GFObjDef(v); v.Right:=1; v.Bottom:=1; v.MinWidth:=1; v.MinHeight:=1; AddObj(v);
  end;
  DelStack;
end;

// Удалить отмеченные объекты
function TGenForm.DelSelObj;
var i,j: longint;
	p: PGFObj;
begin
	AddStack('TGenForm.DelSelObj',Self);
  result := FSelObjects.Count>0;
  if result then begin
    TmpList1.Clear;
    for i:=0 to FSelObjects.Count-1 do begin
      p:=FSelObjects[i];
      j:=FObjects.IndexOf(p); if j>-1 then FObjects.Delete(j);
      j:=FFillObj.IndexOf(p); if j>-1 then FFillObj.Delete(j);
      TmpList1.Add(p);
    end;
	  FObjects.Pack; FFillObj.Pack;
    if SelectObjs(TmpList1,false) then begin
      for i:=0 to TmpList1.Count-1 do Dispose(PGFObj(TmpList1[i]));
      if (FState=gsDesign) and lAutoSize then begin
        PaintFillAll; AddDefObj; AutoSize;
      end;
    end;
  end;
  DelStack;
end;

// Нарисовать объекты
procedure TGenForm.PaintObj;
var j: longint;
begin
	AddStack('TGenForm.PaintObj',Self);
	if not noPaint then begin
	  CalcRate;
	  for j:=0 to ListObj.Count-1 do PaintObj1(PGFObj(ListObj[j]));
  end;
  DelStack;
end;

// Нарисовать объект
function TGenForm.PaintObj1;
  function hAll: longint;
  var i: longint;
  begin
  	AddStack('TGenForm.PaintObj1.hAll',Self);
    if IsFont0 then begin
      result:=0;
      for i:=0 to TmpStr.Count-1 do Inc(result,Font0Height(i));
    end
    else result:=TxtHeight*TmpStr.Count;
    DelStack;
  end;
var msz: TSize;
  i,h,mh1: longint;
  Opt: TGFProcObjOpt;
  function ProcObjPaint(const r: TRect; const p: TPoint): boolean;
  type TBarLineOpt = set of (barBlack,barLong);
  var l: byte;
    at,ab: TArrBoolInt;
    rr: TRect;
    aBarCrd: array[0..brcCntLine] of longint;
    angl: byte;
    v: TGFObj;
    procedure BarLine(w: byte = 1; Opt: TBarLineOpt = []);
    var r1: TRect;
      i,j: longint;
      lLong: boolean;
    begin
      AddStack('TGenForm.PaintObj1.ProcObjPaint.BarLine',Self);
      if (barBlack in Opt) and (aBarCrd[l]<=IfThen(angl and 1 = 0,rr.Right,rr.Bottom)) then begin
        lLong := barLong in Opt;
        case angl of
          1: r1:=Rect(at[lLong],aBarCrd[l],ab[lLong],min(aBarCrd[l+w],rr.Bottom));
          2: r1:=Rect(aBarCrd[l-w],at[lLong],min(aBarCrd[l],rr.Right),ab[lLong]);
          3: r1:=Rect(at[lLong],aBarCrd[l-w],ab[lLong],min(aBarCrd[l],rr.Bottom));
        else r1:=Rect(aBarCrd[l],at[lLong],min(aBarCrd[l+w],rr.Right),ab[lLong])
        end;
        if (r1.Right>=r1.Left) and (r1.Bottom>=r1.Top) then with CurCanvas do
          if (r1.Right=r1.Left) or (r1.Bottom=r1.Top) then
            for i:=r1.Left to r1.Right do
              for j:=r1.Top to r1.Bottom do Pixels[i,j]:=Brush.Color
          else FillRect(r1);
      end;
      Inc(l,aSign[angl and 2 <> 0]*w);
      DelStack;
    end;
    procedure BarLineLong;
    begin
      AddStack('TGenForm.PaintObj1.ProcObjPaint.BarLineLong',Self);
      BarLine(1,[barBlack,barLong]); BarLine; BarLine(1,[barBlack,barLong]);
      DelStack;
    end;
    procedure bmInit(var bm: TBitMap);
    begin
      AddStack('TGenForm.PaintObj1.ProcObjPaint.bmInit',Self);
      BitMapCreate(bm).Canvas.Brush.Color:=CurCanvas.Brush.Color;
      bm.Canvas.Font.Assign(CurCanvas.Font);
      DelStack;
    end;
    procedure Exchange(var n1,n2: longint);
    var n: longint;
    begin
      AddStack('TGenForm.PaintObj1.ProcObjPaint.Exchange',Self);
      n:=n1; n1:=n2; n2:=n;
      DelStack;
    end;
    procedure TxtAngle(const rr: TRect; l,t: longint; const c: string);
    var x,y: longint;
      sz,s: TSize;
    begin
      AddStack('TGenForm.PaintObj1.ProcObjPaint.TxtAngle',Self);
      if angl=0 then CurCanvas.TextRect(rr,l,t,c)
      else with bmAngle do begin
        s:=Canvas.TextExtent(c); Width:=s.cx; Height:=s.cy;
        with bmAngPrn do
          if angl and 1 = 0 then begin
            Width:=bmAngle.Width; Height:=bmAngle.Height;
          end
          else begin
            Width:=bmAngle.Height; Height:=bmAngle.Width;
          end;
        Canvas.FillRect(Rect(0,0,Width-1,Height-1)); Canvas.TextOut(0,0,c);
        for x:=0 to Width-1 do
          for y:=0 to Height-1 do case angl of
            1: bmAngPrn.Canvas.Pixels[Height-y-1,x]:=Canvas.Pixels[x,y];
            2: bmAngPrn.Canvas.Pixels[x,y]:=Canvas.Pixels[Width-x-1,Height-y-1];
            3: bmAngPrn.Canvas.Pixels[y,Width-x-1]:=Canvas.Pixels[x,y];
          end;
        WinSize(sz,bmAngPrn.Width,bmAngPrn.Height);
        if FState=gsPrint then WinSize(sz,ceil(sz.cX*aUnRate[false]),ceil(sz.cY*aUnRate[true]));
        DrawBmp(bmAngPrn,Point(l,t),sz);
      end;
      DelStack;
    end;
  var s: string;
    obc: TColor;
    procedure BarNum(n1,n2,comb: byte);
    const aBar: array[0..9,1..3,1..brcCntNumLine] of byte =
      // Комбинация A    Комбинация B    Комбинация C
      (((0,0,0,1,1,0,1),(0,1,0,0,1,1,1),(1,1,1,0,0,1,0) )	 // 0
      ,((0,0,1,1,0,0,1),(0,1,1,0,0,1,1),(1,1,0,0,1,1,0) )	 // 1
      ,((0,0,1,0,0,1,1),(0,0,1,1,0,1,1),(1,1,0,1,1,0,0) )	 // 2
      ,((0,1,1,1,1,0,1),(0,1,0,0,0,0,1),(1,0,0,0,0,1,0) )	 // 3
      ,((0,1,0,0,0,1,1),(0,0,1,1,1,0,1),(1,0,1,1,1,0,0) )	 // 4
      ,((0,1,1,0,0,0,1),(0,1,1,1,0,0,1),(1,0,0,1,1,1,0) )	 // 5
      ,((0,1,0,1,1,1,1),(0,0,0,0,1,0,1),(1,0,1,0,0,0,0) )	 // 6
      ,((0,1,1,1,0,1,1),(0,0,1,0,0,0,1),(1,0,0,0,1,0,0) )	 // 7
      ,((0,1,1,0,1,1,1),(0,0,0,1,0,0,1),(1,0,0,1,0,0,0) )	 // 8
      ,((0,0,0,1,0,1,1),(0,0,1,0,1,1,1),(1,1,1,0,1,0,0) )	 // 9
      );
    var i,j,k,w: byte;
      r: TRect;
      x,y: Double;
      Opt: TBarLineOpt;
    begin
      AddStack('TGenForm.ProcObjPaint.BarNum',Self);
      for n1:=n1 to n2 do with CurCanvas do begin
        Brush.Color:=obc;
        if angl and 1 = 0 then begin
          if angl=0
          then r:=Rect(aBarCrd[l],ab[false],aBarCrd[l+brcCntNumLine],rr.Bottom)
          else r:=Rect(aBarCrd[l-brcCntNumLine],rr.Top,aBarCrd[l],at[false]);
          x:=Fonts[v.Font].Prop.Width; y:=Fonts[v.Font].Prop.Height;
        end
        else begin
          if angl=1
          then r:=Rect(rr.Left,aBarCrd[l],at[false],aBarCrd[l+brcCntNumLine])
          else r:=Rect(ab[false],aBarCrd[l-brcCntNumLine],rr.Right,aBarCrd[l]);
          y:=aRate[false]/aRate[true];
          x:=Fonts[v.Font].Prop.Height*y; y:=Fonts[v.Font].Prop.Width*y;
        end;
        TxtAngle(r,r.Left+trunc((r.Right-r.Left-x)/2),r.Top+trunc((r.Bottom-r.Top-y)/2),s[n1]);
        Brush.Color:=Font.Color;
        i:=Int0(s[n1]); j:=low(aBar[i,comb]);
        while j<=high(aBar[i,comb]) do begin
          k:=aBar[i,comb,j]; w:=0;
          while j<=high(aBar[i,comb]) do begin
            if aBar[i,comb,j]<>k then break;
            Inc(j); Inc(w);
          end;
          if k=1 then Opt:=[barBlack] else Opt:=[];
          BarLine(w,Opt);
        end;
      end;
      DelStack;
    end;
  const brcCntNum2 = brcCntNum shr 1;
  var st: TGFObjState;
    bm: TGraphic;
    j,sp,lr,tr: longint;
    alg: THVAlignment;
    sz: TSize;
    aX,aY: PArrInt;
    fl: boolean;
    s1: string;
    //cl: TColor;
  begin
    AddStack('TGenForm.ProcObjPaint',Self);
    result:=false; v:=pv^; 
    with CurCanvas do
      if (v.TypeObj in [toBmp,toCalcBmp]) and (FState<>gsDesign) then begin
        if v.TypeObj=toCalcBmp then begin
          SetTmpStr(v,false,SelStart,SelLength); v.Text:=TmpStr.Text;
        end;
        sz:=msz;
        if v.State<>osShow then begin
          st:=v.State; v.State:=osShow; sz.cX:=GetMinWidth(v,[mwhNoAngle]); v.State:=st;
        end;
        if (sz.cX>0) and (sz.cY>0) or (v.State=osLong) then begin
          if gfoSel in Opt then CopyMode:=cmNotSrcCopy;
          if bmObj(v,bm,@s) then begin
            if (FState<>gsPrint) and (v.MinWidth=0) and (v.MinHeight=0) then begin
              Draw(p.x,p.y,bm); WinSize(sz,bm.Width,bm.Height);
            end
            else DrawBmp(bm,p,sz);
            Brush.Color:=AColor[v.Color];
            FloodFill(p.X,p.Y,Pixels[p.X,p.Y],fsSurface);
            //cl:=bm.Canvas.Pixels[0,0];
            {cl:=Pixels[p.X,p.Y];
            for i:=p.X to p.X+sz.cX do
              for j:=p.Y to p.Y+sz.cY do
                if Pixels[i,j]=cl
                then Pixels[i,j]:=AColor[v.Color];}
          end
          else if s<>'' then begin
            v.TypeObj:=toText; v.Text:=s; PaintObj1(@v);
          end;
          if gfoSel in Opt then CopyMode:=cmSrcCopy;
        end;
      end
      else if Fonts[v.Font].Prop.AType=fptQRCode then begin
        j:=qrInit(v); qr.DrawTo(CurCanvas,p.X,p.Y,max(1,msz.cX div j));
      end
      else if Fonts[v.Font].Prop.AType=fptPDF417 then begin
        //j:=pdf417Init(v); pdf417.DrawTo(CurCanvas,p.X,p.Y,max(1,msz.cX div j));
        {if not Assigned(pdf417) then begin
          pdf417:=TBarcode2D_PDF417.Create(Application.MainForm);
        end;
        {pdf417.Stretch:=true;
        pdf417.Barcode:=v.Text;
        //pdf417.Module:=2;
        //pdf417.LeftMargin:=0;
        //pdf417.TopMargin:=0;
        pdf417.BarcodeWidth:=GridObj(v,false);
        pdf417.BarcodeHeight:=GridObj(v,true);
        //pdf417.BarColor:=clBlack;
        //pdf417.SpaceColor:=clWhite;
        //pdf417.Orientation:=boLeftRight;
        //pdf417.ShowQuietZone:=false;
        //pdf417.Options:=[];
        //pdf417.AllowEscape:=false;
        pdf417.MinRows:=12;
        pdf417.MaxRows:=12;
        pdf417.MinColumns:=4;
        //pdf417.MaxColumns:=30;
        //pdf417.StretchOrder:=soRowColumn;
        //pdf417.EccLevel:=elEcc_0;
        //pdf417.EccLevelUpgrade:=true;
        //pdf417.RowHeight:=2;
        //pdf417.Compact:=false;
        //pdf417.Mirrored:=false;
        //pdf417.Locked:=false;
        pdf417.DrawTo(CurCanvas,p.X,p.Y);
        //pdf417.OnInvalidLength:=PDF417InvalidLength;}
        {pdf417.EccLevel:=elEcc_0;
        pdf417.Module:=Pix(false,2);
        pdf417.RowHeight:=3;
        pdf417.MinRows:=min(high(pdf417.MinRows),GridObj(v,true) div (pdf417.Module*pdf417.RowHeight)); pdf417.MaxRows:=pdf417.MinRows;
        pdf417.MinColumns:=4;
        pdf417.Barcode:=v.Text; pdf417.DrawTo(CurCanvas,p.X,p.Y);}
        pdf417Init(v); pdf417.DrawTo(CurCanvas,p.X,p.Y);
      end
      else begin
        s:=TmpStr[i]; rr:=r; angl:=0;
        with Fonts[v.Font].Prop do if AType<>fptNormal then begin
          if Angle=90 then angl:=1
          else if Angle=180 then angl:=2
          else if Angle=270 then angl:=3;
          if angl<>0 then begin
            bmInit(bmAngle); bmInit(bmAngPrn);
          end;
        end;
        case Fonts[v.Font].Prop.AType of
          fptNormal: begin
            if not IsFont0 and (gfoSel in Opt) then begin
              sz:=TextExtent(s);
              MaxSelf(rr.Top,p.y); MinSelf(rr.Bottom,p.y+sz.cy);
              MaxSelf(rr.Left,p.x); MinSelf(rr.Right,p.x+sz.cx);
            end;
            TxtOut(i,pv,p.x,p.y,@rr,Opt,PrTxtOut,PrmTxtOut);
          end;
          fptSepstr: begin
            if angl and 1 = 0 then begin
              aX:=@aSepCrdX; aY:=@aSepCrdY;
            end
            else begin
              aX:=@aSepCrdY; aY:=@aSepCrdX;
            end;
            if i<high(aY^) then begin
              fl:=false;
              for j:=1 to min(high(aX^),Length(s)) do begin
                s1:=s[j];
                if (s1='-') and Fonts[v.Font].Prop.Dop.sepstrOnlyDig then begin
                  fl:=true; continue;
                end;
                if fl then begin
                  IncL(s1,'-'); fl:=false;
                end;
                rr:=Rect(aX^[j-1],aY^[i],aX^[j],aY^[i+1]);
                if angl in [2,3] then begin
                  rr.Left:=aX^[high(aX^)-j]; rr.Right:=aX^[high(aX^)-j+1];
                end;
                if angl in [1,2] then begin
                  rr.Top:=aY^[high(aY^)-i-1]; rr.Bottom:=aY^[high(aY^)-i];
                end;
                if angl and 1 <> 0 then with rr do begin
                  Exchange(Left,Top); Exchange(Right,Bottom);
                end;
                alg:=NumToAlgm(v.Alignment);
                if alg.HorzAlignment=taLeftJustify then lr:=rr.Left
                else begin
                  if angl and 1 = 0 then sp:=TxtWidth(s1)
                  else sp:=trunc(TxtHeight(s1)*aRate[false]/aRate[true]);
                  lr:=IfThen(alg.HorzAlignment=taRightJustify,rr.Right-sp,rr.Left+(rr.Right-rr.Left-sp) div 2);
                end;
                if alg.VertAlignment=taLeftJustify then tr:=rr.Top
                else begin
                  if angl and 1 = 0 then sp:=TxtHeight(s1) else sp:=Trunc(TxtWidth(s1)*aRate[true]/aRate[false]);
                  tr:=IfThen(alg.VertAlignment=taRightJustify,rr.Bottom-sp,rr.Top+(rr.Bottom-rr.Top-sp) div 2);
                end;
                TxtAngle(rr,lr,tr,s1);
              end;
            end;
            if Assigned(PrTxtOut)
            then PrTxtOut(PrmTxtOut,Rect(GridX[pv.Left],GridY[pv.Top],GridX[pv.Right],GridY[pv.Bottom]),
              GridX[pv.Left],GridY[pv.Top],pv.Font,pv.Text);
          end;
          fptBarCode: if i=0 then begin
            Pen.Color:=Font.Color; obc:=Brush.Color; Brush.Color:=Font.Color;
            rr.Bottom:=min(rr.Top+BarCodePix(true,v,brcSize[angl and 1 = 0]),GridY[v.Bottom]);
            sp:=BarCodePix(angl and 1 <> 0,v,brcSpot); j:=BarCodePix(angl and 1 <> 0,v,brcSize[false]);
            if angl and 1 = 0 then begin
              if rr.Right-rr.Left>j then case NumToAlgm(v.Alignment).HorzAlignment of
                taLeftJustify: rr.Right:=rr.Left+j;
                taRightJustify: rr.Left:=rr.Right-j;
                taCenter: begin
                  Inc(rr.Left,(rr.Right-rr.Left-j) div 2); rr.Right:=rr.Left+j;
                end;
              end;
              aBarCrd[0]:=rr.Left+sp; RasprCrd(aBarCrd,j-sp*2,rr.Left+sp); tr:=rr.Top; lr:=rr.Bottom;
            end
            else begin
              if rr.Bottom-rr.Top>j then case NumToAlgm(v.Alignment).VertAlignment of
                taLeftJustify: rr.Bottom:=rr.Top+j;
                taRightJustify: rr.Top:=rr.Bottom-j;
                taCenter: begin
                  Inc(rr.Top,(rr.Bottom-rr.Top-j) div 2); rr.Bottom:=rr.Top+j;
                end;
              end;
              aBarCrd[0]:=rr.Top+sp; RasprCrd(aBarCrd,j-sp*2,rr.Top+sp); tr:=rr.Left; lr:=rr.Right;
            end;
            for fl:=false to true do if angl in [1..2] then begin
              at[fl]:=tr+BarCodePix(angl and 1 = 0,v,brcSize[true]-brcHeightLine[fl]);
              ab[fl]:=lr;
            end
            else begin
              at[fl]:=tr;
              ab[fl]:=lr-BarCodePix(angl and 1 = 0,v,brcSize[true]-brcHeightLine[fl]);
            end;
            l:=IfThen(angl and 2 <> 0, brcCntLine); PadRSelf(s,brcCntNum);
            BarLineLong; BarNum(1,brcCntNum2,1); BarLine; BarLineLong; BarLine;
            BarNum(brcCntNum2+1,brcCntNum,3); BarLineLong;
            if Assigned(PrTxtOut)
            then PrTxtOut(PrmTxtOut,Rect(GridX[pv.Left],GridY[pv.Top],GridX[pv.Right],GridY[pv.Bottom]),
              GridX[pv.Left],GridY[pv.Top],pv.Font,pv.Text);
          end;
        end;
      end;
    DelStack;
  end;
var	w,x,y,hbw,mw1: longint;
  r: TRect;
  p,p1,p2,pc,px1,px2: TPoint;
  alg: THVAlignment;
  s: string;
  v: TGFObj;
  lFill,afl: boolean;
  oCanvas: TCanvas;
  ncos,nsin: Extended;
  cl: TColor;
  tl: TGFLine;
begin
	AddStack('TGenForm.PaintObj1',Self);
  if not(pv.State in [osHide,osSave,osSpace]) then with CurCanvas do begin
    cl:=AColor[pv.Color];
    if (FState=gsDesign) and pv.Selected or lSel then InvColorSelf(cl);
    if InGet and (cl=clWhite) then cl:=ColorW;
    Brush.Color:=cl; lFill := (SelLength=0) and not Assigned(PrTxtOut);
    if lFill then FillRect(Rect(GridX[pv.Left]+1,GridY[pv.Top]+1,
    	GridX[pv.Right],GridY[pv.Bottom]));
    if (FState=gsView) and pv.Selected then InvColorSelf(Brush);
    Pen.Color:=Brush.Color; // Для удаления линий вокруг текста при печати
    if Fonts[pv.Font].Prop.AType=fptSepStr then begin
      x:=trunc(pv.MinWidth); y:=trunc(pv.MinHeight);
      if (FState=gsDesign) and (y=0) then y:=1;
      if (x=0) or (y=0) then begin
        SetTmpStr(pv^);
        if x=0 then x:=MaxSelf(TmpStr);
        if y=0 then y:=TmpStr.Count;
      end;
      SetLength(aSepCrdX,x+1); SetLength(aSepCrdY,y+1);
      RasprCrd(aSepCrdX,GridX[pv.Right]-GridX[pv.Left],GridX[pv.Left]);
      RasprCrd(aSepCrdY,GridY[pv.Bottom]-GridY[pv.Top],GridY[pv.Top]);
    end;
    Opt:=[];
    if lFill then Include(Opt,gfoFill);
    if lSel then Include(Opt,gfoSel);
    if (GridX[pv.Right]>GridX[pv.Left]) and (GridY[pv.Bottom]>GridY[pv.Top]) then begin
      CorObjTextMode(pv); v:=pv^; oCanvas:=CurCanvas; afl:=IsAngle(v);
      if afl then CurCanvas:=BitMapCreate(bmAngle).Canvas;
      CurCanvas.Font.Assign(Fonts[v.Font].Font);
      WinSize(msz,GetMinWidth(v,[mwhNoAll]),GetMinHeight(v,[mwhNoAll]));
      if afl then begin
        if FState=gsPrint then begin
          msz.cY:=GetMinHeight(v);
          BitMapCreate(bmAngPrn).Width :=ceil(max(0,msz.cX)/GetDeviceCaps(GGPrinter.Handle,LOGPIXELSX)*Screen.PixelsPerInch);
          bmAngPrn              .Height:=ceil(max(0,msz.cY)/GetDeviceCaps(GGPrinter.Handle,LOGPIXELSY)*Screen.PixelsPerInch);
          bmAngle.Width:=AngleWidth(v,bmAngPrn.Width,bmAngPrn.Height);
          bmAngle.Height:=AngleHeight(v,bmAngPrn.Width,bmAngPrn.Height);
        end
        else begin
          bmAngle.Width:=GetMinWidth(v,[mwhNoAll,mwhNoAngle,mwhNoMm]);
          bmAngle.Height:=GetMinHeight(v,[mwhNoAll,mwhNoAngle,mwhNoMm]);
        end;
        if gfoFill in Opt then begin
          CurCanvas.Brush.Color:=cl;
          CurCanvas.FillRect(Rect(0,0,bmAngle.Width,bmAngle.Height));
          if FState=gsPrint then begin
            bmAngPrn.Canvas.Brush.Color:=cl;
            bmAngPrn.Canvas.FillRect(Rect(0,0,bmAngPrn.Width,bmAngPrn.Height));
          end;
        end;
        CurCanvas.Brush.Color:=oCanvas.Brush.Color;
      end;
      if (v.TypeObj=toForm) or (FState=gsDesign) and (v.TypeObj in [toBmp,toCalc,toCalcBmp])
        then v.Alignment:=low(v.Alignment)
      else if (FState=gsView) and (v.TypeObj in [toCalc,toCalcBmp]) and LsIdent.Find(v.Ident,i)
        then AlgZero(Idents(i).lsZero,v.Alignment);
      if Fonts[v.Font].Prop.AType=fptSepstr then begin
        alg.VertAlignment:=taLeftJustify; alg.HorzAlignment:=taLeftJustify;
      end
      else alg:=NumToAlgm(v.Alignment);
      px1:=Point(LineWidth,LineWidth([gfwY]));
      px2:=Point(LineWidth([gfwRight]),LineWidth([gfwY,gfwRight]));
      ZeroMemory(@p,SizeOf(p)); i:=0;
      if (FState<>gsPrint) and (v.Selected or (gfoSel in Opt))
      then Include(Opt,gfoSel)
      else Exclude(Opt,gfoSel);
      with CurCanvas do begin
        case alg.VertAlignment of
          taLeftJustify: p.y:=GridY[v.Top]+px2.y+IfThen(InGet and not IsObjGet(v),BevelFld);
          taRightJustify: p.y:=GridY[v.Bottom]-px1.y-msz.cY-IfThen(InGet and not IsObjGet(v),BevelFld);
          taCenter: p.y:=GridY[v.Top]+(GridY[v.Bottom]-GridY[v.Top]-msz.cY) div 2;
        end;
        case alg.HorzAlignment of
          taLeftJustify: p.x:=GridX[v.Left]+px2.x;
          taRightJustify: p.x:=GridX[v.Right]-px1.x-msz.cX;
          taCenter: p.x:=GridX[v.Left]+1+(GridX[v.Right]-GridX[v.Left]-msz.cX) div 2;
        end;
        p1:=p;
        if afl then begin
          ZeroMemory(@p,SizeOf(p));
          if (FState=gsPrint) and (v.TypeObj in [toText,toCalc,toCalcBmp]) then begin
            SetTmpStr(v);
            case alg.VertAlignment of
              taRightJustify: p.y:=bmAngle.Height{-px1.y}-hAll;
              taCenter: p.y:=(bmAngle.Height-hAll) div 2;
            end;
          end;
        end;
        // Рисунок
        if (v.TypeObj in [toBmp,toCalcBmp]) and (FState<>gsDesign) or (Fonts[v.Font].Prop.AType in [fptQRCode,fptPDF417]) then ProcObjPaint(result,p)
        // Текст, формула или ввод
        else begin
          if IsObjGet(v,true) then begin
            if Assigned(v.DopObj) then
              if v.TypeObj=toGet then with TFldEdit(v.DopObj) do begin
                mw1:=Width; mh1:=Height;
                if (CharWidth<0) or (CharHeight<0) then begin
                  IncOptions([],[ogAutoSize]);
                  if CharWidth<0 then mw1:=GridObj(v,false);
                  if CharHeight<0 then mh1:=GridObj(v,true);
                end;
                SetBounds(p.x,p.y,mw1,mh1);
              end
              else with TPaintSay(v.DopObj) do begin
                mw1:=Width; mh1:=Height; SetBounds(p.x,p.y,mw1,mh1); //BringToFront;
              end
          end
          else begin
            hbw:=RowBetween(v);
            if gfoSel in Opt then InvColorSelf(Font);
            if SelLength>0 then Include(Opt,gfoPos);
            SetTmpStr(v,false,SelStart,SelLength);
            for i:=0 to TmpStr.Count-1 do begin
              if p.y>GridY[v.Bottom] then break;
              if (Fonts[v.Font].Prop.AType=fptSepStr) and Fonts[v.Font].Prop.Dop.MMetr
              then h:=nround(Fonts[v.Font].Prop.Dop.Height*aRate[true])
              else if IsFont0 then h:=Font0Height(i,false)
              else begin
                s:=TmpStr[i];
                if empty(s) then s:=cMaxH;
                h:=TxtHeight(s);
              end;
              if afl then case alg.HorzAlignment of
                taLeftJustify: p.x:=0;
                taRightJustify: p.x:=bmAngle.Width-px1.x-TxtOut(i,pv,0,0,nil,[],PrTxtOut,PrmTxtOut);
                taCenter: p.x:=(bmAngle.Width-TxtOut(i,pv,0,0,nil,[],PrTxtOut,PrmTxtOut)) div 2;
              end
              else case alg.HorzAlignment of
                taLeftJustify: p.x:=GridX[v.Left]+px2.x+1;
                taRightJustify: p.x:=GridX[v.Right]-px1.x-TxtOut(i,pv,0,0,nil,[],PrTxtOut,PrmTxtOut)-1;
                taCenter: p.x:=GridX[v.Left]+1
                  +(GridX[v.Right]-GridX[v.Left]-TxtOut(i,pv,0,0,nil,[],PrTxtOut,PrmTxtOut)-1) div 2;
              end;
              if afl then result:=Rect(0,p.y,bmAngle.Width,p.y+h)
              else result:=Rect(GridX[v.Left]+px2.x,max(GridY[v.Top]+px2.y,p.y),
                GridX[v.Right]-IfThen(Fonts[v.Font].Prop.AType<>fptNormal,px1.x),
                min(GridY[v.Bottom]-IfThen(Fonts[v.Font].Prop.AType<>fptNormal,px1.y),p.y+h));
              if ProcObjPaint(result,Point(p.x,p.y{+IfThen((Fonts[v.Font].Prop.AType=fptNormal),hbw)})) then break;
              Inc(p.y,h+hbw);
            end;
          end;
        end;
      end;
      if afl then begin
        CurCanvas:=oCanvas; nsin:=GradToRad(v); ncos:=Cos(nsin); nsin:=System.Sin(nsin);
        px2:=Point(bmAngle.Width div 2,bmAngle.Height div 2);
        if FState=gsPrint then begin
          pc:=Point(bmAngPrn.Width div 2,bmAngPrn.Height div 2);
          r:=Rect(0,0,bmAngPrn.Width,bmAngPrn.Height); oCanvas:=bmAngPrn.Canvas;
        end
        else begin
          pc:=Point(p1.x+msz.cX div 2,p1.y+msz.cY div 2);
          r:=Rect(GridX[v.Left],GridY[v.Top],GridX[v.Right],GridY[v.Bottom]);
        end;
        for mw1:=0 to bmAngle.Width-1 do
          for mh1:=0 to bmAngle.Height-1 do
            if bmAngle.Canvas.Pixels[mw1,mh1]<>cl then begin
              px1:=Point(mw1-px2.x,mh1-px2.y);
              p2:=Point(pc.x+nround(px1.x*ncos-px1.y*nsin),pc.y+nround(px1.y*ncos+px1.x*nsin));
              if InRange(p2.x,r.Left,r.Right) and InRange(p2.y,r.Top,r.Bottom)
              then oCanvas.Pixels[p2.x,p2.y]:=bmAngle.Canvas.Pixels[mw1,mh1];
            end;
        if FState=gsPrint then DrawBmp(bmAngPrn,p1,msz);
      end;
    end;
    with Fonts[pv.Font].Prop do if AType=fptSepStr then begin
      lSel := (FState<>gsPrint) and (pv.Selected or lSel);
      if pv.LnLeft>1 then begin
        tl:=aGFLines[pv.LnLeft]; tl.Width:=Pix(false,max(Params.Arr[FCurParams].GridLineMin,tl.Width));
        w := tl.Width shr 1; lFill:=false;
        if lSel then InvColorSelf(tl.Color);
        if tl.Width>1 then begin
          Brush.Color:=tl.Color; lFill:=true;
        end;
        for x:=1 to high(aSepCrdX)-1 do
          if lFill
          then FillRect(Rect(aSepCrdX[x]-w,GridY[pv.Top],aSepCrdX[x]-w+tl.Width,GridY[pv.Bottom]))
          else for y:=GridY[pv.Top] to GridY[pv.Bottom] do Pixels[aSepCrdX[x],y]:=tl.Color;
      end;
      if pv.LnTop>1 then begin
        tl:=aGFLines[pv.LnTop]; tl.Width:=Pix(true,max(Params.Arr[FCurParams].GridLineMin,tl.Width));
        w := tl.Width shr 1; lFill:=false;
        if lSel then InvColorSelf(tl.Color);
        if tl.Width>1 then begin
          Brush.Color:=tl.Color; lFill:=true;
        end;
        for y:=1 to high(aSepCrdY)-1 do
          if lFill
          then FillRect(Rect(GridX[pv.Left],aSepCrdY[y]-w,GridX[pv.Right],aSepCrdY[y]-w+tl.Width))
          else for x:=GridX[pv.Left] to GridX[pv.Right] do Pixels[x,aSepCrdY[y]]:=tl.Color;
      end;
    end;
  end;
  DelStack;
end;

function TGenForm.IsObjGet;
begin
  AddStack('TGenForm.IsObjGet',Self);
  result := (FState=gsView) and (lNul or Assigned(v.DopObj)) and (v.TypeObj in [toGet,toSay]);
  DelStack;
end;

procedure TGenForm.DrawBmp;
var ow,w,h: longint;
	procedure Line1;
  begin
    AddStack('TGenForm.DrawBmp.Line1',Self);
    if CurCanvas.Pen.Color<>bmStretch.Canvas.Brush.Color then begin
    	CurCanvas.MoveTo(p.X+ow,p.Y+h); CurCanvas.LineTo(p.X+w,p.Y+h)
    	//CurCanvas.MoveTo(p.X+w,p.Y+ow); CurCanvas.LineTo(p.X+w,p.Y+h)
    end;
    DelStack;
  end;
var r,r0: TRect;
  BufBmp: byte;
begin
  AddStack('TGenForm.DrawBmp',Self);
  if (sz.cX>0) and (sz.cY>0) then begin
	  w:=sz.cX; h:=sz.cY; r:=Rect(p.x,p.y,p.x+w,p.y+h); BufBmp:=0;
    if FState=gsPrint then begin
    	BufBmp:=InitFIni[fiSave].ReadInteger('PRN','BufBmp');
      if BufBmp>0 then begin
        BitMapCreate(bmStretch).Width:=w; bmStretch.Height:=h; r0:=Rect(0,0,w,h); bmStretch.Canvas.StretchDraw(r0,bm);
        if BufBmp=2 then CurCanvas.BrushCopy(r,bmStretch,r0,bmStretch.Canvas.Brush.Color)
        else {for w:=0 to r0.Right-1 do
        	for h:=0 to r0.Bottom-1 do CurCanvas.Pixels[p.x+w,p.y+h]:=bmStretch.Canvas.Pixels[w,h]}
        begin
          CurCanvas.Brush.Color:=bmStretch.Canvas.Brush.Color;
          CurCanvas.FillRect(Rect(p.X,p.Y,p.X+r0.Right-1,p.Y+r0.Bottom-1));
          for h:=0 to r0.Bottom-1 do begin
            CurCanvas.Pen.Color:=bmStretch.Canvas.Brush.Color; ow:=0; w:=0;
          	while w<r0.Right do begin
            	if bmStretch.Canvas.Pixels[w,h]<>CurCanvas.Pen.Color then begin
              	Line1; CurCanvas.Pen.Color:=bmStretch.Canvas.Pixels[w,h]; ow:=w;
              end;
              Inc(w);
            end;
            Line1;
          end;
          {for w:=0 to r0.Right-1 do begin
            CurCanvas.Pen.Color:=bmStretch.Canvas.Brush.Color; ow:=0; h:=0;
          	while h<r0.Bottom do begin
            	if bmStretch.Canvas.Pixels[w,h]<>CurCanvas.Pen.Color then begin
              	Line1; CurCanvas.Pen.Color:=bmStretch.Canvas.Pixels[w,h]; ow:=h;
              end;
              Inc(h);
            end;
            Line1;
          end;}
        end;
      end;
    end;
    if BufBmp=0 then CurCanvas.StretchDraw(r,bm);
  end;
  DelStack;
end;

function TGenForm.TxtOut;
var lo,pl: longint;
  algn: TAlignment;
  oFont,nFont: byte;
  function CalcFont(n: longint): boolean;
  begin
    AddStack('TGenForm.TxtOut.CalcFont',Self);
    result:=not(gfoPos in Opt);
    if n>lo then begin
      nFont:=nFont0; algn:=taLeftJustify;
    end
    else begin
      Inc(n,pl);
      if not result then result:=aPos[n];
      algn:=TAlignment(LsFont0.Objects[n]); nFont:=LsFont0[n];
    end;
    DelStack;
  end;
  procedure SetFont(lCalc: boolean);
  begin
    AddStack('TGenForm.TxtOut.SetFont',Self);
    if (oFont<>nFont) or (gfoSel in Opt) then begin
      CurCanvas.Font.Assign(Fonts[nFont].Font);
      if lCalc and (gfoSel in Opt) then InvColorSelf(CurCanvas.Font);
    end;
    oFont:=nFont;
    DelStack;
  end;
  procedure TxtRect(const ARect: TRect; X, Y: longint; nFont: byte; const Text: string);
  begin
    AddStack('TGenForm.TxtOut.TxtRect',Self);
    if Assigned(PrTxtOut) then PrTxtOut(PrmTxtOut,ARect,X,Y,nFont,Text) else CurCanvas.TextRect(ARect,X,Y,Text);
    DelStack;
  end;
var rf: TRect;
  nb,ne,tf: longint;
  procedure TxtFontBeg;
  begin
    AddStack('TGenForm.TxtOut.TxtFontBeg',Self);
    oFont:=MaxByte; nb:=0;
    DelStack;
  end;
var s: string;
  procedure TxtFontOut;
  begin
    AddStack('TGenForm.TxtOut.TxtFontOut',Self);
    if nb>0 then TxtRect(rf,rf.Left,tf,oFont,Copy(s,nb,ne-nb+1));
    DelStack;
  end;
  procedure TxtFont(n: longint; const sz: TSize);
  var r: TRect;
  begin
    AddStack('TGenForm.TxtOut.TxtFont',Self);
    if CalcFont(n) then begin
      r:=Rect(lb,p.Top,min(p.Right,lb+sz.cx),p.Bottom);
      if oFont<>nFont then begin
        TxtFontOut; nb:=n; rf:=r; tf:=tb-sz.cy; SetFont(true);
      end;
      ne:=n; rf.Right:=r.Right;
    end;
    DelStack;
  end;
var sz: TArrSize;
  l: longint;
  procedure szFill;
  var j,h,d: longint;
    a: array of record
      a: TAlignment;
      m: TTextMetric;
    end;
  begin
    AddStack('TGenForm.TxtOut.szFill',Self);
    pl:=PriorLineEnd[i]; SetLength(sz,l); SetLength(a,l); h:=0; d:=0; TxtFontBeg;
    for j:=1 to l do with a[j-1],m do begin
      SetFont(CalcFont(j)); a:=algn; GetTextMetrics(CurCanvas.Handle,m);
      MaxSelf(h,tmHeight); MaxSelf(d,tmDescent); sz[j-1].cx:=TxtWidth(s[j]);
    end;
    d:=h-d;
    for j:=1 to l do with a[j-1],m,sz[j-1] do case a of
      taLeftJustify: cy:=d;
      taRightJustify: cy:=tmAscent;
      taCenter: cy:=d-(h-tmHeight) shr 1;
    end;
    Inc(tb,d);
    DelStack;
  end;
var lSp: boolean;
  a: array of record
    p,l: longint;
    asz: TArrSize;
  end;
  j,h: longint;
  procedure aEnd;
  var k,n: longint;
  begin
    AddStack('TGenForm.TxtOut.aEnd',Self);
    if not lSp then with a[h] do begin
      l:=j-p;
      if IsFont0 then begin
        SetLength(asz,l); n:=p;
        for k:=0 to l-1 do begin
          asz[k]:=sz[n-1]; Inc(result,asz[k].cx); Inc(n);
        end;
      end
      else begin
        SetLength(asz,1); asz[0].cx:=TxtWidth(Copy(s,p,l)); Inc(result,asz[0].cx);
      end;
    end;
    DelStack;
  end;
var c: char;
	n,offs,wFill: longint;
  lOnWidth: boolean;
begin
  AddStack('TGenForm.TxtOut',Self);
  result:=0; s:=TmpStr[i]; nFont:=pv.Font;
  l:=Length(s); lo:=l;
  lOnWidth := (FState<>gsDesign) and OnWidth(pv^);
  if lOnWidth then begin
    wFill:=0;
    if (i=TmpStr.Count-1) and not AnsiStartsStr(sGFIdStr,pv.Text) then begin
    	c:=Fonts[pv.Font].Prop.Dop.ChrFill; lOnWidth := not empty(c);
      if lOnWidth then begin
        if ALine(pv^)
        then offs:=GridObj(pv^,false){-2}
        else offs:=GetMinWidth(pv^);
        if IsFont0 then begin
          j:=Font0Width(i); CurCanvas.Font.Assign(Fonts[nFont0].Font);
        end
        else j:=TxtWidth(s);
        wFill:=TxtWidth(c); offs:=(offs-j) div wFill; IncD(s,StringOfChar(c,offs)); Inc(l,offs);
        if IsFont0 then MultD(wFill,offs);
      end;
    end;
    if lOnWidth then begin
      if l>0 then begin
        if IsFont0 then szFill;
        SetLength(a,Ceil(l/2)); h:=-1; lSp:=true; j:=1;
        while j<=l do begin
          if s[j]>' ' = lSp then begin
            if lSp then begin
              Inc(h); a[h].p:=j;
            end;
            aEnd; NotD(lSp);
          end;
          Inc(j);
        end;
        aEnd;
        if h=0 then offs:=0
        else begin
          if ALine(pv^)
          then offs:=GridObj(pv^,false){-2}
          else offs:=GetMinWidth(pv^);
          if IsFont0 then n:=Font0Width(i)+wFill else n:=TxtWidth(s);
          offs:=nround((EnsureRange(offs-GridLine(false),0,n*1.5)-result)/h); Inc(result,offs*h);
        end;
        if Assigned(p) then with p^ do begin
          TxtFontBeg;
          for h:=0 to h do with a[h] do begin
            n:=p;
            for j:=low(asz) to high(asz) do with asz[j] do begin
              if IsFont0 then begin
                TxtFont(n,asz[j]); Inc(n);
              end
              else TxtRect(Rect(lb,Top,min(Right,lb+cx),Bottom),lb,tb,nFont,Copy(s,p,l));
              Inc(lb,cx);
            end;
            Inc(lb,offs);
          end;
          if IsFont0 then TxtFontOut;
        end;
      end;
    end;
  end;
  if not lOnWidth then
	  if Assigned(p) then with p^ do
      {if Assigned(PrGFTextRect)
        then PrGFTextRect(CurCanvas,p^,lb,tb,s)
      else} if IsFont0 then begin
        szFill; TxtFontBeg;
        for j:=1 to l do with sz[j-1] do begin
          TxtFont(j,sz[j-1]); Inc(lb,cx);
        end;
        TxtFontOut;
      end
      else TxtRect(p^,lb,tb,nFont,TrimRight(s))
    else if IsFont0 then result:=Font0Width(i) else result:=TxtWidth(s);
  DelStack;
end;

function TGenForm.TxtWidth;
begin
  AddStack('TGenForm.TxtWidth',Self);
  result:=CurCanvas.TextWidth(txt);
  DelStack;
end;

function TGenForm.TxtWidthUn;
begin
  AddStack('TGenForm.TxtWidthUn',Self);
  result:=max(TxtWidth(txt),TxtWidthOther(txt));
  DelStack;
end;

function TGenForm.TxtWidthOther;
begin
	AddStack('TGenForm.TxtWidthOther',Self);
  result:=ceil(FOtherCanvas.TextWidth(txt)*aUnRate[false]);
  DelStack;
end;

function TGenForm.TxtHeight;
begin
  AddStack('TGenForm.TxtHeight',Self);
  result:=CurCanvas.TextHeight(txt);
  DelStack;
end;

{function TGenForm.TxtHeightUn;
begin
  AddStack('TGenForm.TxtHeightUn',Self);
  result:=max(TxtHeight(txt),TxtHeightOther(txt));
  DelStack;
end;}

function TGenForm.TxtHeightOther;
begin
	AddStack('TGenForm.TxtHeightOther',Self);
  result:=ceil(FOtherCanvas.TextHeight(txt)*aUnRate[true]);
  DelStack;
end;

function TGenForm.qrInit;
var h,sw,sh: longint;
begin
  AddStack('TGenForm.qrInit',Self);
  if not Assigned(qr) then begin
    qr:=TBarcode2D_QRCode.Create(Application.MainForm); qr.OnEncode:=qrEncode;
  end;
  qr.EccLevel:=Fonts[v.Font].Prop.Dop.qrECCLevel; qr.Barcode:=v.Text; qr.Size(result,h,sw,sh);
  DelStack;
end;

class procedure TGenForm.qrEncode;
begin
  AddStack('TGenForm.qrEncode');
  Data:={#$EF#$BB#$BF+}AnsiToUTF8(Barcode);
  DelStack;
end;

function TGenForm.pdf417Init;
type TPrm = (prmECCLevel,prmModule,prmRowHeight);
var sw,sh: longint;
  wh: TArrBoolInt;
  fl: boolean;
  p: TPrm;
  sp: set of TPrm;
begin
  AddStack('TGenForm.pdf417Init',Self);
  if not Assigned(pdf417) then begin
    pdf417:=TBarcode2D_PDF417.Create(Application.MainForm); pdf417.OnInvalidLength:=PDF417InvalidLength;
  end;
  for fl:=false to true do wh[fl]:=GridObj(v,fl);
  with pdf417 do begin
    Barcode:=v.Text;
    with Fonts[v.Font].Prop,Dop do begin
      EccLevel:=pdf417ECCLevel;
      Module:=Pix(false,pdf417Module);
      RowHeight:=EnsureRange(pdf417RowHeight,low(pdf417RowHeight),high(pdf417RowHeight));
      Orientation:=iif(Angle=90,boTopBottom,iif(Angle=180,boRightLeft,iif(Angle=270,boBottomTop,boLeftRight)));
      BarColor:=Font.Color; SpaceColor:=AColor[v.Color];
    end;
    sp:=[];
    for p:=low(TPrm) to high(TPrm) do Include(sp,p);
    p:=low(TPrm);
    repeat
      MinRows:=min(high(MinRows),wh[true] div (Module*RowHeight)); MaxRows:=MinRows;
      Tag:=0; Size(result.cx,result.cy,sw,sh);
      if (Tag=0) and (result.cx<=wh[false]) and (result.cy<=wh[true]) then break;
      while sp<>[] do begin
        fl:=false;
        case p of
          prmECCLevel: if EccLevel>elEcc_0 then begin
            EccLevel:=Pred(EccLevel); fl:=true;
          end;
          prmModule: if Module>1 then begin
            Module:=Module-1; fl:=true;
          end;
          prmRowHeight: if RowHeight>1 then begin
            RowHeight:=RowHeight-1; fl:=true;
          end;
        end;
        if not fl then Exclude(sp,p);
        if p=high(TPrm) then p:=low(TPrm) else Inc(p);
        if fl then break;
      end;
    until sp=[];
  end;
  DelStack;
end;

class procedure TGenForm.PDF417InvalidLength;
begin
  AddStack('TGenForm.PDF417InvalidLength');
  TBarcode2D_PDF417(Sender).Tag:=1;
  DelStack;
end;

function TGenForm.IsAngle;
begin
  AddStack('TGenForm.IsAngle',Self);
  with Fonts[v.Font].Prop do result := (AType=fptNormal) and (Angle>0);
  DelStack;
end;

// Кол-во пикселов на мм
procedure TGenForm.CalcRate;
const aLogPixels: TArrBoolInt = (LOGPIXELSX,LOGPIXELSY);
var i,w,h,ost: longint;
  p: TGFPackFont;
  s: string;
  lY,fl: boolean;
begin
	ost:=AddStack('TGenForm.CalcRate',Self);
  if FState=gsPrint then begin
    FOtherCanvas:=Canvas;
    for lY:=false to true do begin
      aRate[lY]:=GetDeviceCaps(GGPrinter.Handle,aLogPixels[lY]); aUnRate[lY]:=aRate[lY]/Screen.PixelsPerInch;
    end;
  end
  else begin
    for lY:=false to true do aRate[lY]:=Screen.PixelsPerInch;
    fl:=true;
    if (GGPrinter.Printers.Count>0) and not InGet then
      try
        FOtherCanvas:=GGPrinter.Canvas;
        for lY:=false to true do begin
          aUnRate[lY]:=GetDeviceCaps(GGPrinter.Handle,aLogPixels[lY]);
          if aUnRate[lY]=0 then aUnRate[lY]:=aRate[lY];
        end;
        fl:=false;
      except
        SetStack(ost);
      end;
    if fl then begin
	    FOtherCanvas:=Canvas;
	    for lY:=false to true do aUnRate[lY]:=aRate[lY];
    end;
    for lY:=false to true do aUnRate[lY]:=aRate[lY]/aUnRate[lY];
  end;
  for lY:=false to true do DivD(aRate[lY],MmInInch);
  for i:=0 to LsFont.Count-1 do begin
  	p:=LsFont[i]; CurCanvas.Font.Assign(p.Font);
    if OnlyDig(i) then s:='0' else s:=StrW(1);
    if p.Prop.AType=fptBarCode then with CurCanvas.Font do begin
    	w:=(BarCodePixFont(false,p,brcSize[false]-2*brcSpot) div brcCntLine)*brcCntNumLine;
      h:=BarCodePixFont(true,p,brcSize[true]-brcHeightLine[false]);
    	while (TxtWidth(s)<w) and (TxtHeight(s)<h) do IncFontSize(CurCanvas.Font);
    	while (p.Font.Size>3) and ((TxtWidth(s)>w) or (TxtHeight(s)>h)) do IncFontSize(CurCanvas.Font,-1);
      p.Font.Size:=Size;
    end;
    FOtherCanvas.Font.Assign(p.Font);
    p.Prop.Width:=max(TxtWidth(s),FOtherCanvas.TextWidth(s)*aUnRate[false]);
    p.Prop.Height:=max(TxtHeight,FOtherCanvas.TextHeight(cMaxH)*aUnRate[true]);
  end;
  DelStack;
end;

function TGenForm.OnlyDig;
var p: TGFPackFont;
begin
  AddStack('TGenForm.OnlyDig',Self);
  p:=Fonts[Index];
  case p.Prop.AType of
    fptNormal: result:=p.Prop.Dop.OnlyDig;
    fptSepstr: result:=p.Prop.Dop.sepstrOnlyDig;
    fptBarCode: result:=true;
  else result:=false;
  end;
  DelStack;
end;

function TGenForm.RowBetween;
begin
  AddStack('TGenForm.RowBetween',Self);
  result:=0;
  with Fonts[v.Font].Prop do case AType of
  	fptNormal: result:=nround(Dop.RowBetween*aRate[true]/10);
    fptSepStr: if not Dop.MMetr then result:=GridLine(true);
  end;
  DelStack;
end;

function TGenForm.OnWidth;
begin
  AddStack('TGenForm.OnWidth',Self);
  with Fonts[v.Font].Prop do result := (AType=fptNormal) and Dop.OnWidth;
  DelStack;
end;

function TGenForm.PrcSpMin;
begin
  AddStack('TGenForm.PrcSpMin',Self);
  result:=IfThen(OnWidth(v),Fonts[v.Font].Prop.Dop.PrcSpMin);
  DelStack;
end;

function TGenForm.ALine(const v: TGFObj): boolean;
begin
  result:=ALine(Fonts[v.Font]);
end;

class function TGenForm.ALine(const f: TGFPackFont): boolean;
begin
  AddStack('TGenForm.ALine');
  with f.Prop do result := (AType=fptNormal) and Dop.ALine;
  DelStack;
end;

procedure TGenForm.CorObjTextMode;
var a: THVAlignment;
begin
	AddStack('TGenForm.CorObjTextMode',Self);
	with pv^ do if IsObjGet(pv^) and (TypeObj=toGet) then begin
    a:=NumToAlgm(Alignment);
    with TFldEdit(DopObj) do if (CharWidth<0) or (CharHeight<0) then begin
      if CharWidth<0 then a.HorzAlignment:=taLeftJustify;
      if CharHeight<0 then a.VertAlignment:=taLeftJustify;
      Alignment:=AlgmToNum(a);
    end;
  end;
  DelStack;
end;

// Минимальная ширина объекта
function TGenForm.GetMinWidth;
var v: TGFObj;
  function UnWidth(nf: byte; w: Double): longint;
  begin
    AddStack('TGenForm.GetMinWidth.UnWidth',Self);
    with Fonts[nf] do if Prop.AType=fptSepstr then
      if Prop.Dop.MMetr then result:=nround(Prop.Dop.Width*aRate[false]*w)
      else begin
        result:=GridLine(false);
        //if result>0 then Inc(result,2);
        result:=ceil(Prop.Width)*trunc(w)+result*(trunc(w)-1);
      end
    else result:=ceil(Prop.Width*w);
    DelStack;
  end;
	function wAngle(w: longint): longint;
  begin
    AddStack('TGenForm.GetMinWidth.wAngle',Self);
    result:=w;
    if not(mwhNoAngle in Opt) and IsAngle(v)
    then result:=AngleWidth(v,result,GetMinHeight(v,[mwhNoAll,mwhNoAngle]));
    DelStack;
  end;
var i,j,w,pl,nf,sb,sl: longint;
  s: string;
  lWidthTextAll: boolean;
label lend;
begin
	AddStack('TGenForm.GetMinWidth',Self);
	result:=0; v:=vv;
  if v.State in [osHide,osSave,osSpace] then goto lend;
  if (v.State=osLong) then result:=max(0,CrdMargin-GridX[v.Left]-GridLine(false))
  else begin
  	CorObjTextMode(@v);
    if v.TypeObj in [toBmp,toCalcBmp] then
      if v.MinWidth=0 then begin
      	if FState=gsDesign then begin
		    	if not(mwhNoAll in Opt) then CurCanvas.Font.Assign(Fonts[v.Font].Font);
        	result:=CanvasMaxW(CurCanvas);
        end
        else begin
          result:=bmSize(v).cX;
          if FState=gsPrint then result:=nround(result*aRate[false]/Screen.PixelsPerInch*MmInInch);
        end;
        goto lend;
      end
      else result:=wAngle(nround(v.MinWidth*aRate[false]))
    else begin
    	if not(mwhNoAll in Opt) then CurCanvas.Font.Assign(Fonts[v.Font].Font);
      if v.MMetr and not(mwhNoMm in Opt) and not(mwhNoAll in Opt) and (Fonts[v.Font].Prop.AType<>fptSepStr)
      	then result:=nround(v.MinWidth*aRate[false])
      else if IsObjGet(v,true) then begin
        if Assigned(v.DopObj) then
          if v.TypeObj=toGet
          then with TFldEdit(v.DopObj) do result:=IfThen(CharWidth>=0,Width)
          else result:=TPaintSay(v.DopObj).Width;
      end
      else if Fonts[v.Font].Prop.AType=fptQRCode then begin
        if not v.MMetr and (v.MinWidth=0)
          then result:=qrInit(v)*Pix(false,Fonts[v.Font].Prop.Dop.qrModule)
        else if mwhNoAll in Opt then begin
          result:=qrInit(v);
          result:=(min(GridObj(v,false),GridObj(v,true)) div result)*result;
        end;
      end
      else if Fonts[v.Font].Prop.AType=fptPDF417 then begin
        if mwhNoAll in Opt then result:=pdf417Init(v).cx;
      end
      else begin
        if ((v.TypeObj in [toText,toGet,toSay])
        or (FState<>gsDesign) and (v.TypeObj in [toCalc,toCalcBmp])
        or (Fonts[v.Font].Prop.AType=fptSepStr))
        and ((mwhNoALine in Opt) or not ALine(v)) then begin
          if FState=gsView then DelMacro(v,[gfmcCtrl]);
          SetTmpStr(v,mwhNoALine in Opt);
          lWidthTextAll := (Fonts[v.Font].Prop.AType=fptNormal) and Fonts[v.Font].Prop.Dop.WidthTextAll;
          for i:=0 to TmpStr.Count-1 do begin
            s:=TmpStr[i];
            if IsFont0 then begin
              w:=0; pl:=PriorLineEnd[i]; nf:=-1; sb:=0; sl:=0;
              for j:=1 to Length(s) do
                if lWidthTextAll then begin
                  if nf<>LsFont0[pl+j] then begin
                    if sl>0 then begin
                      Inc(w,TxtWidthUn(Copy(s,sb,sl))); sl:=0;
                    end;
                    sb:=j; nf:=LsFont0[pl+j]; CurCanvas.Font.Assign(LsFont0.GetFont(pl+j));
                    FOtherCanvas.Font.Assign(CurCanvas.Font);
                  end;
                  Inc(sl);
                end
                else begin
                  CurCanvas.Font.Assign(LsFont0.GetFont(pl+j)); Inc(w,UnWidth(LsFont0[pl+j],1));
                end;
              if lWidthTextAll then if sl<>0 then Inc(w,TxtWidthUn(Copy(s,sb,sl)));
            end
            else if lWidthTextAll then begin
              CurCanvas.Font.Assign(Fonts[v.Font].Font);
              FOtherCanvas.Font.Assign(CurCanvas.Font); w:=TxtWidthUn(s);
            end
            else w:=UnWidth(v.Font,Length(s));
            MaxSelf(result,w);
          end;
        end;
        with Fonts[v.Font].Prop do
        	if AType=fptBarCode then result:=BarCodePix(false,v,brcSize[(Angle=90) or (Angle=270)]);
        result:=wAngle(result);
        if not(mwhNoAngle in Opt) then begin
          if FState=gsDesign then MaxSelf(v.MinWidth,1);
          i:=UnWidth(v.Font,IfThen(OnlyDig(v.Font),IfThen(v.MinWidth=0,
            Params.Arr[FCurParams].PrmNum.AllCnt,v.MinWidth),v.MinWidth));
          if Fonts[v.Font].Prop.AType<>fptSepStr then MaxSelf(result,i)
          else if i>0 then result:=i;
        end;
        {if (result <> 0) and not IsTextMode //and (Fonts[v.Font].Prop.AType=fptNormal)
        then Inc(result,2);}
      end;
    end;
    if not(mwhNoAngle in Opt) and (result>0) and not IsObjGet(v)
    and (not(Fonts[v.Font].Prop.AType in [fptQRCode,fptPDF417]) and v.MMetr
    or (v.TypeObj in [toBmp,toCalcBmp])
    or (Fonts[v.Font].Prop.AType=fptSepStr) and Fonts[v.Font].Prop.Dop.MMetr)
  	  then Dec(result,GridLine(false));
    if FState=gsDesign then MaxSelf(result,10);
	end;
lend:
	DelStack;
end;

// Минимальная высота объекта
function TGenForm.GetMinHeight;
var v: TGFObj;
	function hAngle(h: longint): longint;
  begin
    AddStack('TGenForm.GetMinHeight.hAngle',Self);
    result:=h;
    if not(mwhNoAngle in Opt) and IsAngle(v)
    then result:=AngleHeight(v,GetMinWidth(v,[mwhNoAll,mwhNoAngle]),result);
    DelStack;
  end;
var i,j,h,pl,hbw,UnHeight: longint;
label lend;
begin
	AddStack('TGenForm.GetMinHeight',Self);
	result:=0; v:=vv; CorObjTextMode(@v);
  if v.State in [osHide,osSave,osSpace] then if not(mwhNoALine in Opt) then if ALine(v) then goto lend;
  if v.TypeObj in [toBmp,toCalcBmp] then
    if v.MinHeight=0 then begin
      if FState=gsDesign then begin
        if not(mwhNoAll in Opt) then CurCanvas.Font.Assign(Fonts[v.Font].Font);
        result:=TxtHeight;
      end
      else begin
        result:=bmSize(v).cY;
        if FState=gsPrint then result:=nround(result*aRate[true]/Screen.PixelsPerInch*MmInInch);
      end;
      goto lend;
    end
    else result:=hAngle(nround(v.MinHeight*aRate[true]))
  else begin
  	if not(mwhNoAll in Opt) then CurCanvas.Font.Assign(Fonts[v.Font].Font);
  	if v.MMetr and not(mwhNoMm in Opt) and not(mwhNoAll in Opt) and (Fonts[v.Font].Prop.AType<>fptSepStr)
    	then result:=nround(v.MinHeight*aRate[true])
    else if IsObjGet(v,true) then begin
      if Assigned(v.DopObj) then
        if v.TypeObj=toGet then with TFldEdit(v.DopObj) do //result:=IfThen(CharHeight>=0,Height)
          if CharHeight<0 then result:=SizeAuto.cy+BevelFld2 else result:=Height
        else result:=TPaintSay(v.DopObj).Height;
    end
    else if Fonts[v.Font].Prop.AType=fptQRCode then begin
      if not v.MMetr and (v.MinHeight=0)
        then result:=qrInit(v)*Pix(true,Fonts[v.Font].Prop.Dop.qrModule)
      else if mwhNoAll in Opt then begin
        result:=qrInit(v);
        result:=(min(GridObj(v,false),GridObj(v,true)) div result)*result;
      end;
    end
    else if Fonts[v.Font].Prop.AType=fptPDF417 then begin
      if mwhNoAll in Opt then result:=pdf417Init(v).cy;
    end
    else begin
    	hbw:=RowBetween(v){+FIntervalBetwRows};
    	if (Fonts[v.Font].Prop.AType=fptSepStr) and Fonts[v.Font].Prop.Dop.MMetr
      then UnHeight:=nround(Fonts[v.Font].Prop.Dop.Height*aRate[true])
      else UnHeight:=ceil(Fonts[v.Font].Prop.Height);
      if FState=gsDesign then MaxSelf(v.MinHeight,1);
      if (v.TypeObj in [toText,toSay]) or (FState<>gsDesign) and (v.TypeObj in [toCalc,toCalcBmp]) then begin
        SetTmpStr(v,mwhNoALine in Opt);
        //if TmpStr.Count>0 then Inc(result,UnHeight*TmpStr.Count+hbw*(TmpStr.Count-1));
        if IsFont0 then for i:=0 to TmpStr.Count-1 do begin
          h:=0; pl:=PriorLineEnd[i];
          for j:=1 to Length(TmpStr[i]) do MaxSelf(h,ceil(Fonts[LsFont0[pl+j]].Prop.Height));
          Inc(result,h+hbw);
        end
        else
        Inc(result,(UnHeight+hbw)*TmpStr.Count);
      end
      else result:=UnHeight;
      with Fonts[v.Font].Prop do
      	if AType=fptBarCode then result:=BarCodePix(true,v,brcSize[not((Angle=90) or (Angle=270))]);
      result:=hAngle(result);
      if not(mwhNoAll in Opt) and not(mwhNoAngle in Opt) and (not v.MMetr
      or (Fonts[v.Font].Prop.AType=fptSepStr) and Fonts[v.Font].Prop.Dop.MMetr) then begin
        //if v.MinHeight>0 then i:=UnHeight*v.MinHeight+hbw*(v.MinHeight-1) else i:=0;
        i:=ceil((UnHeight+hbw)*v.MinHeight);
        if Fonts[v.Font].Prop.AType<>fptSepStr then MaxSelf(result,i)
        else if i>0 then result:=i;
      end;
      if InGet and (result>0) and not(mwhNoAll in Opt) then Inc(result,BevelFld2);
    end;
  end;
  if not(mwhNoAngle in Opt) and (result>0) and not IsObjGet(v)
  and (not (Fonts[v.Font].Prop.AType in [fptQRCode,fptPDF417]) and v.MMetr
  or (v.TypeObj in [toBmp,toCalcBmp])
  or (Fonts[v.Font].Prop.AType=fptSepStr) and Fonts[v.Font].Prop.Dop.MMetr)
    then Dec(result,GridLine(true));
  if FState=gsDesign then MaxSelf(result,10);
lend:
	DelStack;
end;

function TGenForm.BarCodePix;
begin
  AddStack('TGenForm.BarCodePix');
	result:=BarCodePixFont(lY,Fonts[v.Font],mm);
  DelStack;
end;

function TGenForm.BarCodePixFont;
begin
  AddStack('TGenForm.BarCodePixFont',Self);
  if (f.Prop.Angle=90)or(f.Prop.Angle=270) then NotD(lY);
	result:=nround(mm*aRate[lY]*max(0,f.Prop.Dop.Koef/100+1));
  DelStack;
end;

function TGenForm.GradToRad;
begin
  AddStack('TGenForm.GradToRad',Self);
  result:=Pi/180*Fonts[v.Font].Prop.Angle;
  DelStack;
end;

function TGenForm.AngleWidth;
var rad: Extended;
begin
  AddStack('TGenForm.AngleWidth',Self);
  rad:=GradToRad(v); result:=Ceil(w*Abs(Cos(rad))+h*Abs(System.Sin(rad)));
  DelStack;
end;

function TGenForm.AngleHeight;
var rad: Extended;
begin
  AddStack('TGenForm.AngleHeight',Self);
  rad:=GradToRad(v); result:=Ceil(h*Abs(Cos(rad))+w*Abs(System.Sin(rad)));
  DelStack;
end;

function TGenForm.bmSize;
var bm: TGraphic;
begin
  AddStack('TGenForm.bmSize',Self);
	if bmObj(v,bm)
  then WinSize(result,bm.Width,bm.Height)
  else ZeroMemory(@result,SizeOf(result));
  DelStack;
end;

function TGenForm.bmObj(const v: TGFObj; var bm: TGraphic; txtDef: PString = nil): boolean;
begin
  if bmObj(v.Text,bm,txtDef) then result:=true
  else begin
    if Assigned(OnGraphObj) then bm:=OnGraphObj(Self,v);
    result:=Assigned(bm);
  end;
end;

function TGenForm.bmObj(const txt: string; var bm: TGraphic; txtDef: PString = nil): boolean;
var i: longint;
  s: string;
  a: array[1..3] of string;
begin
  AddStack('TGenForm.bmObj',Self);
  bm:=nil; SetPString(txtDef);
  if Pos(cCalcBmp,txt)>0 then begin
    if not Assigned(lsbmUser) then begin
      lsbmUser:=TGFBitMapList.Create;
      lsbmUser.LoadFromDB(QQNull(tDCMBMP+'.'+fUSERNAME,'',true),[gfbmUser,gfbmUserName]);
    end;
    s:=TrimRight(txt);
    if ListAsArray(s,a,cCalcBmp)>=3 then begin
      SetPString(txtDef,a[3]); s:=TrimRight(ArrayAsList(a,cCalcBmp,2));
    end;
    if lsbmUser.Find(s,i) then bm:=lsbmUser.GetBM(i).bm
  end
  else if lsBitMap.Find(txt,i) then bm:=lsBitMap.GetBM(i).bm;
  result:=Assigned(bm);
  DelStack;
end;

procedure TGenForm.SetTmpStr;
	procedure TxtALine(const st: string);
	var s: string;
    function NoPos(const ss: string): boolean;
    var i: longint;
    begin
      AddStack('TGenForm.SetTmpStr.TxtALine.NoPos',Self);
      result:=not LeftSelfDel(s,ss);
      if not result then begin
        if IsFont0 then for i:=1 to Length(ss) do lsFont0.Delete(0);
        if s=CRLF then begin
          s:=''; IsFont0:=false;
        end;
      end;
      DelStack;
    end;
	var w,i: longint;
    Cnv: TCanvas;
    lPos: boolean;
  begin
    AddStack('TGenForm.SetTmpStr.TxtALine',Self);
    s:=st; lPos := SelLength>0; Str2Fon0(s,v.Font,lPos);
    if (FState<>gsDesign) and (Fonts[v.Font].Prop.AType=fptNormal) then begin
      if not NoALine and ALine(v) and (s<>'') then
        if NoPos(sGFIdStr) then
          if NoPos(sGFIdEndStr) then begin
            w:=max(0,GridObj(v,false));
            if FState=gsPrint then Cnv:=CurCanvas
            else begin
              Cnv:=FOtherCanvas; w:=Trunc(w/aUnRate[false]);
            end;
            Cnv.Font.Assign(Fonts[v.Font].Font);
            s:=astolin(Cnv,s,w,0,PrcSpMin(v),nil,1,1,TFontIndexList(IfThen(IsFont0,lsFont0)));
          end;
      if OnWidth(v) and not empty(Fonts[v.Font].Prop.Dop.ChrFill) and (s='') then s:=CRLF;
    end;
    TmpStr.Text:=s;
    i:=TmpStr.Count;
    if i>0 then begin
      if Length(PriorLineEnd)<i then SetLength(PriorLineEnd,i);
      w:=-1;
      for i:=0 to i-1 do begin
        PriorLineEnd[i]:=w; Inc(w,Length(TmpStr[i])+lCRLF);
      end;
      if lPos then begin
        Inc(w,1-lCRLF); SetLength(aPos,w); ZeroMemory(@aPos[0],w*SizeOf(aPos[0]));
        for i:=low(SelStart^) to high(SelStart^) do
          FillMemory(pointer(longint(@aPos[0])+SelStart^[i]-1),SelLength,ByteTrue);
      end;
    end;
    DelStack;
  end;
var	l: longint;
  fl: boolean;
  m: TGFMacro;
label lend;
begin
	AddStack('TGenForm.SetTmpStr',Self);
  TmpStr.Clear;
  if FState=gsView then begin
    if v.State in [osHide,osSave,osSpace] then goto lend;
    with Params.Arr[FCurParams] do if StdFormat then if NFormat=frmNoLim then
      for m:=low(aGFMacro) to high(aGFMacro) do
        if aGFMacro[m].HideNoLim then if Pos(GFMacroCod(m),v.Text)>0 then goto lend;
  end;
  if FState<>gsDesign then
    if v.TypeObj=toGet then goto lend;
  fl := not((FState=gsView) and (v.TypeObj in [toCalc,toCalcBmp]));
  if not fl then
  	if LsIdent.Find(v.Ident,l) then with Idents(l)^ do
    	if Calc and Edited then fl:=true else TxtALine(Value);
  if (FState=gsDesign) and (v.TypeObj=toSay) then
  	if Assigned(EdSayProc) then begin
    	TxtALine(EdSayProc(@v.Text)); fl:=false;
    end;
  if fl then TxtALine(v.Text);
lend:
  DelStack;
end;

procedure TGenForm.Str2Fon0;
  procedure sInit(m: TGFMacro; var s: string; var l: longint);
  begin
    AddStack('TGenForm.Str2Fon0.sInit',Self);
    s:=GFMacroCod(m); l:=Length(s);
    DelStack;
  end;
  function NoPos(const sf: string; pb: longint; var pe: longint): boolean;
  begin
    AddStack('TGenForm.Str2Fon0.NoPos',Self);
    pe:=PosEx(sf,s,pb); result := pe=0;
    DelStack;
  end;
var i: longint;
  procedure Move(pb,pe,nf: longint; algn: TAlignment = taLeftJustify);
  begin
    AddStack('TGenForm.Str2Fon0.Move',Self);
    while pb<pe do begin
      Inc(i); s[i]:=s[pb]; lsFont0.Add(nf,pointer(algn)); Inc(pb);
    end;
    DelStack;
  end;
var sb,se: string;
  pb,ps,pe,l,lb,le,nf: longint;
  algn: TAlignment;
  a: array[1..2] of string;
begin
  AddStack('TGenForm.Str2Fon0',Self);
  IsFont0:=Assigned(lsFont0);
  if IsFont0 then begin
    sInit(gfmcFONT,sb,lb); IsFont0 := not NoPos(sb,1,pb) or Bound;
    if IsFont0 then begin
      sInit(gfmcEND,se,le); i:=0; l:=Length(s); lsFont0.Clear; lsFont0.Capacity:=l; pe:=1;
      repeat
        Move(pe,pb,FontDef); Inc(pb,lb);
        if NoPos(se,pb,ps) then break;
        LsArrFill(Copy(s,pb,ps-pb),a,'.'); nf:=Int0(a[1]); algn:=TAlignment(Int0(a[2]));
        if not InRange(nf,0,LsFont.Count-1) then break;
        Inc(ps,le);
        if Copy(s,ps,le)=se then begin // Пустые не выделяем
          pe:=ps+1;
        end
        else begin
          if NoPos(se,ps,pe) then break;
          Move(ps,pe,nf,algn); Inc(pe,le);
        end;
      until NoPos(sb,pe,pb);
      Move(pe,l+1,FontDef); SetLength(s,i); nFont0:=FontDef;
    end;
  end;
  DelStack;
end;

function TGenForm.Font0Width;
var pl,i: longint;
  s: string;
begin
  AddStack('TGenForm.Font0Width',Self);
  s:=TmpStr[nl]; pl:=PriorLineEnd[nl]; result:=0;
  for i:=1 to Length(s) do begin
    CurCanvas.Font.Assign(LsFont0.GetFont(pl+i)); Inc(result,TxtWidth(s[i]));
  end;
  DelStack;
end;

function TGenForm.Font0Height;
var pl,i: longint;
  s: string;
begin
  AddStack('TGenForm.Font0Height',Self);
  s:=TmpStr[nl]; pl:=PriorLineEnd[nl];
  if s='' then begin
    if pl<0 then i:=nFont0 else i:=LsFont0[pl];
    CurCanvas.Font.Assign(Fonts[i].Font); result:=TxtHeight;
  end
  else begin
    result:=0;
    for i:=1 to Length(s) do begin
      CurCanvas.Font.Assign(LsFont0.GetFont(pl+i));
      MaxSelf(result,TxtHeight(IfThen(empty(s[i]) or lMax,cMaxH,s[i])));
    end;
  end;
  DelStack;
end;

function TGenForm.GetFont0;
begin
  AddStack('TGenForm.GetFont0',Self);
  result:=Fonts[Index].Font;
  DelStack;
end;

function TGenForm.ObjText;
var s: string;
begin
  AddStack('TGenForm.ObjText',Self);
  SetTmpStr(v); result:=RightStrDel(TmpStr.Text,CRLF);
  if v.TypeObj=toCalcBmp then begin
    s:=DlmCopy(result,3,1,cCalcBmp);
    if s<>'' then result:=s;
  end;
  DelStack;
end;

// Разделить выделенные объекты
function TGenForm.DivSelObj;
var v1: TGFObj;
  procedure CopyObj;
  begin
  	AddStack('TGenForm.DivSelObj.CopyObj',Self);
  	v1.Selected:=false;
    if not(gfdvCopyText in Opt) then v1.Text:='';
    AddObj(v1);
    DelStack;
  end;
var i: longint;
  j: Word;
	onp: boolean;
begin
	AddStack('TGenForm.DivSelObj',Self);
  result := SelObjectCount>0;
	if result then begin
  	onp:=NoPaint;
    try
      NoPaint:=true; v1:=SelObjects[0];
      case Vid of
        // Справа
        dvRight: begin
          ColCount:=high(FGridX)+1; j:=v1.Right;
          for i:=0 to ObjectCount-1 do with PObjects[i]^ do begin
            if Selected then continue;
            if Left>=j then Inc(Left);
            if Right>=j then Inc(Right);
          end;
          for i:=0 to SelObjectCount-1 do begin
            v1:=SelObjects[i]; v1.Left:=v1.Right; v1.Right:=v1.Left+1; CopyObj;
          end;
        end;
        // Снизу
        dvBottom: begin
          RowCount:=high(FGridY)+1; j:=v1.Bottom;
          for i:=0 to ObjectCount-1 do with PObjects[i]^ do begin
            if Selected then continue;
            if Top>=j then Inc(Top);
            if Bottom>=j then Inc(Bottom);
          end;
          for i:=0 to SelObjectCount-1 do begin
            v1:=SelObjects[i]; v1.Top:=v1.Bottom; v1.Bottom:=v1.Top+1; CopyObj;
          end;
        end;
        // Слева
        dvLeft: begin
          ColCount:=high(FGridX)+1; j:=v1.Left;
          for i:=0 to ObjectCount-1 do with PObjects[i]^ do begin
            if (Left>j) or (Selected and (Left=j)) then Inc(Left);
            if Right>j then Inc(Right);
          end;
          for i:=0 to SelObjectCount-1 do begin
            v1:=SelObjects[i]; v1.Right:=v1.Left; v1.Left:=v1.Right-1; CopyObj;
          end;
        end;
        // Сверху
        dvTop: begin
          RowCount:=high(FGridY)+1; j:=v1.Top;
          for i:=0 to ObjectCount-1 do with PObjects[i]^ do begin
            if (Top>j) or (Selected and (Top=j)) then Inc(Top);
            if Bottom>j then Inc(Bottom);
          end;
          for i:=0 to SelObjectCount-1 do begin
            v1:=SelObjects[i]; v1.Bottom:=v1.Top; v1.Top:=v1.Bottom-1; CopyObj;
          end;
        end;
      end;
    finally
    	NoPaint:=onp;
    end;
    if not(gfdvNoAutoSize in Opt) then AutoSize;
  end;
  DelStack;
end;

// Объединить выделенные объекты
function TGenForm.CombSelObj;
var i: longint;
  l,t,r,b: Word;
	v: TGFObj;
  pv: PGFObj;
begin
	AddStack('TGenForm.CombSelObj',Self);
  result := SelObjectCount>0;
  if result then begin
    pv:=nil; l:=GFMaxWord; t:=GFMaxWord; r:=0; b:=0;
    for i:=0 to SelObjectCount-1 do begin
      v:=SelObjects[i];
      MinSelf(l,v.Left); MaxSelf(r,v.Right);
      MinSelf(t,v.Top); MaxSelf(b,v.Bottom);
      if (v.Left=l) and (v.Top=t) then pv:=FSelObjects[i];
    end;
    if Assigned(pv) then begin
      TmpList.Clear; TmpList.Add(pv); SelectObjs(TmpList,false);
      DelSelObj(false); pv.Right:=r; pv.Bottom:=b; AutoSize;
      TmpList.Clear; TmpList.Add(pv);
      if SelectObjs(TmpList,true) then PaintFillAll;
    end;
  end;
  DelStack;
end;

{ МЫШЬ }

procedure TGenForm.Click;
begin
  AddStack('TGenForm.Click',Self);
  if MouseEval(1,'щелчок') then inherited Click;
  DelStack;
end;

procedure TGenForm.DblClick;
begin
  AddStack('TGenForm.DblClick',Self);
  if MouseEval(2,'двойной щелчок') then inherited DblClick;
  DelStack;
end;

procedure TGenForm.MouseDown;
begin
	AddStack('TGenForm.MouseDown',Self);
  if nActivePaint<0 then begin
    if CanFocus and not Focused and not InGet then SetFocus;
    if (FState=gsDesign) and (Button=mbLeft) and not FKbdCtrl
    then MouseDown1(Shift,X,Y);
    if MouseEval(3,'нажатие',Shift) then inherited MouseDown(Button,Shift,X,Y);
  end
  else with TPaintControl(Components[nActivePaint]) do begin
  	MouseDown(Button,Shift,X-Left,Y-Top);
	  if Button=mbLeft then Click;
  end;
  DelStack;
end;

procedure TGenForm.MouseDown1;
var ACrd: TGFCrd;
  w,h,i,lm,rm,tm,bm: longint;
  v,v1: TGFObj;
  fl: boolean;
begin
	AddStack('TGenForm.MouseDown1',Self);
  if ssCtrl in Shift then begin
    ObjCopy:=ObjInPoint(X,Y); TypeCursor(X,Y);
  end
  else begin
    ACrd:=PointToCrd(X,Y);
    if Cursor in [crDefault,crOurUp,crOurLeft] then begin
      if (Cursor<>crDefault)
      or InRange(X,GridX[0],GridX[high(FGridX)])
      and InRange(Y,GridY[0],GridY[high(FGridY)])
      then with BvRect do begin
        w:=0; h:=0;
        case Self.Cursor of
          crDefault: begin
            BegSelX:=ACrd.Col; BegSelY:=ACrd.Row;
            FRectSel:=Rect(BegSelX,BegSelY,BegSelX,BegSelY);
            BvX:=X; BvY:=Y;
          end;
          crOurUp: begin
            BegSelX:=ACrd.Col;
            FRectSel:=Rect(BegSelX,1,BegSelX,high(FGridY));
            BvX:=GridX[FRectSel.Left-1]+2;
            BvY:=GridY[0]+2;
            w:=GridX[FRectSel.Right]-GridX[FRectSel.Left-1]-2;
            h:=GridY[high(FGridY)]-GridY[0]-2;
          end;
          crOurLeft: begin
            BegSelY:=ACrd.Row;
            FRectSel:=Rect(1,BegSelY,high(FGridX),BegSelY);
            BvX:=GridX[0]+2;
            BvY:=GridY[FRectSel.Top-1]+2;
            w:=GridX[high(FGridX)]-GridX[0]-2;
            h:=GridY[FRectSel.Bottom]-GridY[FRectSel.Top-1]-2;
          end;
        else BvX:=0; BvY:=0;
        end;
        SetBounds(BvX,BvY,w,h); Visible:=true;
      end
      else ClearAllSelection;
    end
    else if ObjCrdVid=dvNone then begin
      TmpList.Clear;
      w:=IfThen(Cursor in [crOurLLine,crOurRLine],ACrd.Col,ACrd.Row);
      if Cursor in [crOurLLine,crOurULine] then Dec(w);
      fl := (ssShift in Shift) or (SelObjectCount=1);
      for i:=0 to ObjectCount-1 do begin
        v:=Objects[i];
        if (Cursor=crOurLLine) and (v.Left=w)
        or (Cursor=crOurRLine) and (v.Right=w)
        or (Cursor=crOurULine) and (v.Top=w)
        or (Cursor=crOurDLine) and (v.Bottom=w) then begin
          TmpList.Add(PObjects[i]); AndD(fl,v.Selected);
        end;
      end;
      SelShift(Shift,fl,false);
    end
    else begin
      lm:=0; rm:=GFMaxWord;
      tm:=0; bm:=GFMaxWord;
      for i:=0 to FSelObjects.Count-1 do with PGFObj(FSelObjects[i])^ do begin
        MaxSelf(lm,Left); MinSelf(rm,Right);
        MaxSelf(tm,Top); MinSelf(bm,Bottom);
      end;
      case ObjCrdVid of
        dvRight: begin
          ObjCrdMin:=lm+1; ObjCrdMax:=high(FGridX);
          for i:=0 to ObjectCount-1 do begin
            v:=Objects[i];
            if not v.Selected and (v.Right>lm) then for w:=0 to SelObjectCount-1 do begin
              v1:=SelObjects[w];
              if (v.Top<v1.Bottom) and (v.Bottom>v1.Top) then MinSelf(ObjCrdMax,v.Left);
            end;
          end;
        end;
        dvBottom: begin
          ObjCrdMin:=tm+1; ObjCrdMax:=high(FGridY);
          for i:=0 to ObjectCount-1 do begin
            v:=Objects[i];
            if not v.Selected and (v.Bottom>tm) then for w:=0 to SelObjectCount-1 do begin
              v1:=SelObjects[w];
              if (v.Left<v1.Right) and (v.Right>v1.Left) then MinSelf(ObjCrdMax,v.Top);
            end;
          end;
        end;
        dvLeft: begin
          ObjCrdMin:=0; ObjCrdMax:=rm-1;
          for i:=0 to ObjectCount-1 do begin
            v:=Objects[i];
            if not v.Selected and (v.Left<rm) then for w:=0 to SelObjectCount-1 do begin
              v1:=SelObjects[w];
              if (v.Top<v1.Bottom) and (v.Bottom>v1.Top) then MaxSelf(ObjCrdMin,v.Right);
            end;
          end;
        end;
        dvTop: begin
          ObjCrdMin:=0; ObjCrdMax:=bm-1;
          for i:=0 to ObjectCount-1 do begin
            v:=Objects[i];
            if not v.Selected and (v.Top<bm) then for w:=0 to SelObjectCount-1 do begin
              v1:=SelObjects[w];
              if (v.Left<v1.Right) and (v.Right>v1.Left) then MaxSelf(ObjCrdMin,v.Bottom);
            end;
          end;
        end;
      end;
      ObjCrdCng:=true;
    end;
  end;
  DelStack;
end;

procedure TGenForm.MouseMove;
var tl: TKeyLb;
begin
	AddStack('TGenForm.MouseMove',Self);
  if InGet then nActivePaint:=TPaintControl.nActivePaint(Self,X,Y);
  if nActivePaint<0 then begin
    if not noMove and (FState=gsDesign) then
      if FKbdCtrl then begin
        if FormKeyLb(Self,tl) then tl.ExecKey(K_Esc);
      end
      else MouseMove1(Shift,X,Y);
    if FState=gsView then begin
      BvX:=X; BvY:=Y;
    end;
    if MouseEval(4,'перемещение',Shift) then inherited MouseMove(Shift,X,Y);
    TypeCursor(X,Y);
  end
  else with TPaintControl(Components[nActivePaint]) do MouseMove(Shift,X-Left,Y-Top);
  DelStack;
end;

procedure TGenForm.MouseMove1;
var ACrd: TGFCrd;
	i: Word;
begin
	AddStack('TGenForm.MouseMove1',Self);
  if BvRect.Visible then with BvRect do begin
    ACrd:=PointToCrd(X,Y);
    if Self.Cursor in [crDefault,crOurUp] then
      if ACrd.Col>BegSelX
        then FRectSel.Right:=ACrd.Col
      else if ACrd.Col<BegSelX
        then FRectSel.Left:=ACrd.Col
      else begin
        FRectSel.Left:=BegSelX; FRectSel.Right:=BegSelX;
      end;
    if Self.Cursor in [crDefault,crOurLeft] then
      if ACrd.Row>BegSelY
        then FRectSel.Bottom:=ACrd.Row
      else if ACrd.Row<BegSelY
        then FRectSel.Top:=ACrd.Row
      else begin
        FRectSel.Top:=BegSelY; FRectSel.Bottom:=BegSelY;
      end;
    case Self.Cursor of
      crDefault: begin
        EnsureSelf(X,GridX[0],GridX[high(FGridX)]);
        EnsureSelf(Y,GridY[0],GridY[high(FGridY)]);
        SetBounds(min(BvX,X)+1,min(BvY,Y)+1,Abs(BvX-X),Abs(BvY-Y));
        TmpCtrl.SetBounds(X,Y,0,0);
      end;
      crOurUp: begin
        SetBounds(GridX[FRectSel.Left-1]+2,Top,GridX[FRectSel.Right]-GridX[FRectSel.Left-1]-2,Height);
        i:=IfThen(FRectSel.Left=BegSelX,FRectSel.Right,FRectSel.Left);
        TmpCtrl.SetBounds(GridX[i-1],GridY[high(FGridY)],GridX[i]-GridX[i-1],0);
      end;
      crOurLeft: begin
        SetBounds(Left,GridY[FRectSel.Top-1]+2,Width,GridY[FRectSel.Bottom]-GridY[FRectSel.Top-1]-2);
        i:=IfThen(FRectSel.Top=BegSelY,FRectSel.Bottom,FRectSel.Top);
        TmpCtrl.SetBounds(GridX[high(FGridX)],GridY[i-1],0,GridY[i]-GridY[i-1]);
      end;
    end;
    TmpCtrlView;
  end
  else if ObjCrdCng then begin
    ACrd:=PointToCrd(X,Y,true);
    case ObjCrdVid of
      dvRight: if InRange(ACrd.Col,ObjCrdMin,ObjCrdMax) and (PGFObj(FSelObjects[0]).Right<>ACrd.Col) then begin
        for i:=0 to FSelObjects.Count-1 do PGFObj(FSelObjects[i]).Right:=ACrd.Col;
        PaintAll; GetParentForm(Self).perform(WM_GFCNGOBJ,0,0);
      end;
      dvBottom: if InRange(ACrd.Row,ObjCrdMin,ObjCrdMax) and (PGFObj(FSelObjects[0]).Bottom<>ACrd.Row) then begin
        for i:=0 to FSelObjects.Count-1 do PGFObj(FSelObjects[i]).Bottom:=ACrd.Row;
        PaintAll; GetParentForm(Self).perform(WM_GFCNGOBJ,0,0);
      end;
      dvLeft: if InRange(ACrd.Col,ObjCrdMin,ObjCrdMax) and (PGFObj(FSelObjects[0]).Left<>ACrd.Col) then begin
        for i:=0 to FSelObjects.Count-1 do PGFObj(FSelObjects[i]).Left:=ACrd.Col;
        PaintAll; GetParentForm(Self).perform(WM_GFCNGOBJ,0,0);
      end;
      dvTop: if InRange(ACrd.Row,ObjCrdMin,ObjCrdMax) and (PGFObj(FSelObjects[0]).Top<>ACrd.Row) then begin
        for i:=0 to FSelObjects.Count-1 do PGFObj(FSelObjects[i]).Top:=ACrd.Row;
        PaintAll; GetParentForm(Self).perform(WM_GFCNGOBJ,0,0);
      end;
    end;
  end
  else TypeCursor(X,Y);
  DelStack;
end;

procedure TGenForm.MouseUp;
begin
	AddStack('TGenForm.MouseUp',Self);
  if nActivePaint<0 then begin
    if (FState=gsDesign) and (Button=mbLeft) and not FKbdCtrl then MouseUp1(Shift,X,Y);
    if MouseEval(5,'отпускание',Shift) then inherited MouseUp(Button,Shift,X,Y);
  end
  else with TPaintControl(Components[nActivePaint]) do MouseUp(Button,Shift,X-Left,Y-Top);
  DelStack;
end;

procedure TGenForm.MouseUp1;
var ACrd: TGFCrd;
  fl,sel: boolean;
  pv: PGFObj;
	l,t,r,b,i: longint;
  p: string;
begin
	AddStack('TGenForm.MouseUp1',Self);
  if Assigned(ObjCopy) then begin
    pv:=ObjInPoint(X,Y);
    if Assigned(pv) then
      if pv<>ObjCopy then with pv^ do begin
        l:=Left; t:=Top; r:=Right; b:=Bottom; sel:=Selected; p:=Part; pv^:=ObjCopy^;
        Left:=l; Top:=t; Right:=r; Bottom:=b; Selected:=sel; Part:=p;
        AutoSize; GetParentForm(Self).perform(WM_GFCNGOBJ,0,0);
      end;
    ObjCopy:=nil; Cursor:=CursDefault;
  end
	else if not (Cursor in [crOurLLine,crOurRLine,crOurULine,crOurDLine])
  and BvRect.Visible then begin
    ACrd:=PointToCrd(X,Y); TmpList.Clear;
    fl := (ssShift in Shift) or (SelObjectCount=1);
    for i:=0 to ObjectCount-1 do begin
      pv:=PObjects[i];
      if win2comp(Rect(pv.Left+1,pv.Top+1,pv.Right,pv.Bottom),FRectSel) then begin
      	TmpList.Add(PObjects[i]); AndD(fl,pv.Selected);
      end;
    end;
    BvRect.Visible:=false; SelShift(Shift,fl,true); TypeCursor(X,Y);
  end;
  if ObjCrdCng then begin
    AutoSize; ObjCrdCng:=false;
  end;
  DelStack;
end;

procedure TGenForm.SelShift;
	procedure PaintSel;
  begin
    AddStack('TGenForm.SelShift.PaintSel');
    PaintSelected;
    if Assigned(bmPaint) then begin
      CurCanvas:=bmPaint.Canvas; PaintSelected; CurCanvas:=Canvas;
    end;
    DelStack;
  end;
var i,j: longint;
	r: TRect;
  pv: PGFObj;
begin
	AddStack('TGenForm.SelShift',Self);
  TmpList1.Clear; r:=Rect(MaxInt,MaxInt,0,0);
  for i:=0 to SelObjectCount-1 do begin
  	pv:=FSelObjects[i]; TmpList1.Add(pv);
    MinSelf(r.Left,pv.Left); MaxSelf(r.Right,pv.Right);
    MinSelf(r.Top,pv.Top); MaxSelf(r.Bottom,pv.Bottom);
  end;
  if unSel then
  	if GridSel and (TmpList.Count=0) then begin
      SelectObjs(TmpList1,false); FSelected:=true; SelectGrid; PaintSel;
    end
    else SelectObjs(TmpList,false)
  else
    if TmpList.Count=0 then begin
    	if GridSel then begin
        SelectObjs(TmpList1,false);
        FSelected:=true; SelectGrid; PaintSel;
      end
      else if not(ssShift in Shift) then begin
      	SelectObjs(TmpList1,false);
      end
    end
    else begin
      i:=0;
      while i<TmpList1.Count do begin
        j:=TmpList.IndexOf(PGFObj(TmpList1[i]));
        if j>=0 then begin
          TmpList.Delete(j); TmpList1.Delete(i);
        end
        else Inc(i);
      end;
      if not(ssShift in Shift) then SelectObjs(TmpList1,false);
      SelectObjs(TmpList,true);
    end;
  PaintFillAll(@r);
  DelStack;
end;

function TGenForm.CursDefault;
begin
  AddStack('TGenForm.CursDefault',Self);
  result:=IfThen(Assigned(ObjCopy),crDrag,crDefault);
  DelStack;
end;

// Тип курсора в координате (X,Y)
procedure TGenForm.TypeCursor;
const otsCr = 4;
var cr: TCursor;
	ACrd: TGFCrd;
  i,l,t,r,b,lm,rm,tm,bm,x1,x2,y1,y2: longint;
begin
	AddStack('TGenForm.TypeCursor',Self);
  cr:=CursDefault;
  if FState=gsDesign then
    if ObjCrdCng then cr:=Cursor
    else begin
      if FSelObjects.Count>0 then begin
        with PGFObj(FSelObjects[0])^ do begin
          l:=Left;   lm:=l; 
          t:=Top;    tm:=t;
          r:=Right;  rm:=r;
          b:=Bottom; bm:=b;
        end;
        for i:=1 to FSelObjects.Count-1 do with PGFObj(FSelObjects[i])^ do begin
          if Left  <>l then l:=-1; MinSelf(lm,Left);
          if Top   <>t then t:=-1; MinSelf(tm,Top);
          if Right <>r then r:=-1; MaxSelf(rm,Right);
          if Bottom<>b then b:=-1; MaxSelf(bm,Bottom);
        end;
        x2:=GridLine(false); x1:=x2 shr 1; Dec(x2,x1);
        y2:=GridLine(true ); y1:=y2 shr 1; Dec(y2,y1);
        ObjCrdVid:=dvNone;
        if InRange(Y,GridY[tm],GridY[bm])
        then if (l>=0) and InRange(X,GridX[l]-x1,GridX[l]+x2) then ObjCrdVid:=dvLeft
        else if (r>=0) and InRange(X,GridX[r]-x1,GridX[r]+x2) then ObjCrdVid:=dvRight;
        if InRange(X,GridX[lm],GridX[rm])
        then if (t>=0) and InRange(Y,GridY[t]-y1,GridY[t]+y2) then ObjCrdVid:=dvTop
        else if (b>=0) and InRange(Y,GridY[b]-y1,GridY[b]+y2) then ObjCrdVid:=dvBottom;
        case ObjCrdVid of
          dvRight,dvLeft: cr:=crHSplit;
          dvBottom,dvTop: cr:=crVSplit;
        end;
      end;
      if cr=CursDefault then
        if (Y>GridY[high(FGridY)])
        and (Y<GridY[high(FGridY)]+LineWidth([gfwY])+FSpot.Top+WdtLnSel)
        and (X>GridX[0]-otsCr) and (X<GridX[high(FGridX)]+otsCr)
          then cr:=crOurUp
        else if (X>GridX[high(FGridX)])
        and (X<GridX[high(FGridX)]+LineWidth+FSpot.Left+WdtLnSel)
        and (Y>GridY[0]-otsCr) and (Y<GridY[high(FGridY)]+otsCr)
          then cr:=crOurLeft
        else if (Y<GridY[0]) and (X>GridX[0]) and (X<GridX[high(FGridX)]) then begin
          ACrd:=PointToCrd(X,Y);
          cr:=IfThen(GridX[ACrd.Col]-X>X-GridX[ACrd.Col-1],crOurLLine,crOurRLine);
        end
        else if (X<GridX[0]) and (Y>GridY[0])
        and (Y<GridY[high(FGridY)]) then begin
          ACrd:=PointToCrd(X,Y);
          cr:=IfThen(GridY[ACrd.Row]-Y>Y-GridY[ACrd.Row-1],crOurULine,crOurDLine);
        end;
    end;
  Cursor:=cr;
  DelStack;
end;

// Перевод координат мыши в номер столбца и строки
function TGenForm.PointToCrd;
var i: Word;
begin
	AddStack('TGenForm.PointToCrd',Self);
 	result.Col:=1;
	if X>=GridX[high(FGridX)] then result.Col:=high(FGridX)
  else if With0 and (X<=GridX[0]) then result.Col:=0
  else for i:=1 to high(FGridX) do
    if InRange(X,GridX[i-1],GridX[i]-1) then begin
      result.Col:=i; break;
    end;
 	result.Row:=1;
	if Y>=GridY[high(FGridY)] then result.Row:=high(FGridY)
  else if With0 and (Y<=GridY[0]) then result.Row:=0
  else for i:=1 to high(FGridY) do
    if InRange(Y,GridY[i-1],GridY[i]-1) then begin
      result.Row:=i; break;
    end;
  DelStack;
end;

// Скроллинг
procedure TGenForm.TmpCtrlView;
var sc: TScrollingWinControl;
begin
	AddStack('TGenForm.TmpCtrlView',Self);
  if ParentScroll(Self,sc) then sc.ScrollInView(TmpCtrl);
  DelStack;
end;

procedure TGenForm.TmpCtrlView(ALeft,ATop: longint);
begin
	AddStack('TGenForm.TmpCtrlView(Crd)',Self);
  TmpCtrl.SetBounds(ALeft,ATop,0,0); TmpCtrlView;
  DelStack;
end;

{ КЛАВИАТУРА }

procedure TGenForm.DoEnter;
var sc: TScrollingWinControl;
  //tl: TKeyLb;
begin
	AddStack('TGenForm.DoEnter',Self);
  if not IsCalculator then begin
    inherited DoEnter;
    if ParentScroll(Self,sc) then begin
      scX:=sc.HorzScrollBar.Position;	scY:=sc.VertScrollBar.Position;
      Timer.onTimer:=TimerCtrlView; Timer.Enabled:=true;
    end;
  end;
//if FOrmKeyLb(Self,tl) then tl.SetKey(K_F12,'','',tnpdf,'tnpdf',kmNone);
  DelStack;
end;

procedure TGenForm.DoExit;
begin
	AddStack('TGenForm.DoExit',Self);
  if not IsCalculator then inherited DoExit;
  DelStack;
end;

procedure TGenForm.Notification;
var i: longint;
	pv: PGFObj;
begin
	AddStack('TGenForm.Notification',Self);
	inherited Notification(AComponent,Operation);
  if InGet and (Operation=opRemove) and ((AComponent is TFldEdit) or (AComponent is TPaintSay))
  and not(csDestroying in ComponentState) then
    for i:=0 to ObjectCount-1 do begin
      pv:=PObjects[i];
      if IsObjGet(pv^) then if pv.DopObj=AComponent then begin
        pv.DopObj:=nil; break;
      end;
    end;
  DelStack;
end;

procedure TGenForm.TimerCtrlView;
var sc: TScrollingWinControl;
begin
	AddStack('TGenForm.TimerCtrlView',Self);
	Timer.Enabled:=false;
  if ParentScroll(Self,sc) then begin
  	sc.HorzScrollBar.Position:=scX; sc.VertScrollBar.Position:=scY;
  end;
  DelStack;
end;

// Найти ближайшую точку
procedure TGenForm.KbdRound;
begin
  AddStack('TGenForm.KbdRound',Self);
  FKbdCrd:=PointToCrd(TmpCtrl.Left,TmpCtrl.Top);
  if TmpCtrl.Left-GridX[FKbdCrd.Col-1]<GridX[FKbdCrd.Col]-TmpCtrl.Left then Dec(FKbdCrd.Col);
  if TmpCtrl.Top-GridY[FKbdCrd.Row-1]<GridY[FKbdCrd.Row]-TmpCtrl.Top then Dec(FKbdCrd.Row);
  DelStack;
end;

{procedure TGenForm.tnpdf;
begin
  if Key=K_F12 then with TPrintPDF.Create(Application.MainForm) do try
    FileName:='C:\T\tnpdf.pdf'; PageWidth:=bmPaint.Width; PageHeight:=bmPaint.Height;
    BeginDoc;
    DrawBitmap(0,0,bmPaint);
    EndDoc;
  finally
    Free;
  end;
end;}

procedure TGenForm.GFProcKey;
var tl: TKeyLb;
  sc: TScrollingWinControl;
  X,Y: longint;
  ss: TShiftState;
  p: TPoint;
label lend;
begin
	AddStack('TGenForm.GFProcKey',Self);
  FormKeyLb(Self,tl);
  // Управление курсором с клавиатуры
	if FKbdCtrl then begin
		ParentScroll(Self,sc);
  	case Key of
      K_Enter,K_Shift_Enter: begin
      	Cursor:=CursDefault;
      	X:=GridX[FKbdCrd.Col]+IfThen(FKbdCrd.Col<>high(FGridX),
        	(GridX[FKbdCrd.Col+1]-GridX[FKbdCrd.Col]) div 2);
      	Y:=GridY[FKbdCrd.Row]+IfThen(FKbdCrd.Row<>high(FGridY),
        	(GridY[FKbdCrd.Row+1]-GridY[FKbdCrd.Row]) div 2);
        ss:=IfThen(Key<>K_Enter,[ssShift]);
        // Отметить ячейки
        if BvRect.Visible then begin
        	MouseUp1(ss,X,Y);
          if Assigned(tl) then with tl do begin
          	DelKey(K_All,'GFKbdSel'); SetKbdCtrl; goto lend;
          end;
        end
        // Начать отметку ячеек
        else begin
        	MouseDown1(ss,X,Y);
          if Assigned(tl) then with tl do begin
            SetKeys([K_Esc,K_F10],'Отмена','Отменить отметку',GFProcKey,'GFKbdSel',kmGFKbd);
            SetKey(K_Enter,'Отметить','Отметить ячейки',GFProcKey,'GFKbdSel',kmGFKbd);
            SetKey(K_Shift_Enter,'','Добавить ячейки к существующей отметке',GFProcKey,'GFKbdSel',kmGFKbd);
            SetKeys([K_Alt_Left,K_Alt_Right,K_Alt_Up,K_Alt_Down],'','',GFProcKey,'GFKbdSel',kmNone);
            ReDrw;
          end;
        end;
      end;
    	K_Home: FKbdCrd.Col:=0;
    	K_End: FKbdCrd.Col:=high(FGridX);
    	K_PgUp,K_PgDn: if Assigned(sc) then begin
        if sc.VertScrollBar.Visible then begin
        	TmpCtrl.SetBounds(TmpCtrl.Left,TmpCtrl.Top+sc.Height*aSign[Key=K_PgUp],0,0);
          KbdRound;
        end
        else FKbdCrd.Row:=IfThen(Key<>K_PgUp,high(FGridY));
      end;
    	K_Up: if FKbdCrd.Row>0 then Dec(FKbdCrd.Row);
    	K_Down: Inc(FKbdCrd.Row);
    	K_Left: if FKbdCrd.Col>0 then Dec(FKbdCrd.Col);
    	K_Right: Inc(FKbdCrd.Col);
    	K_Ctrl_Home: begin
      	FKbdCrd.Col:=0; FKbdCrd.Row:=0;
      end;
    	K_Ctrl_End: begin
      	FKbdCrd.Col:=high(FGridX); FKbdCrd.Row:=high(FGridY);
      end;
    	K_Ctrl_PgUp: FKbdCrd.Row:=0;
    	K_Ctrl_PgDn: FKbdCrd.Row:=high(FGridY);
    	K_Ctrl_Left,K_Ctrl_Right: if Assigned(sc) then begin
        if sc.VertScrollBar.Visible then begin
        	TmpCtrl.SetBounds(TmpCtrl.Left+sc.Width*aSign[Key=K_Ctrl_Left],TmpCtrl.Top,0,0);
          KbdRound;
        end
        else FKbdCrd.Col:=IfThen(Key<>K_Ctrl_Left,high(FGridX));
      end;
      K_Alt_Left,K_Alt_Right,K_Alt_Up,K_Alt_Down:
        if not BvRect.Visible then begin
        	X:=GridX[FKbdCrd.Col];	Y:=GridY[FKbdCrd.Row];
          case Key of
          	K_Alt_Left : begin Y:=0; Dec(X); end;
          	K_Alt_Right: begin Y:=0; Inc(X); end;
          	K_Alt_Up   : begin X:=0; Dec(Y); end;
          	K_Alt_Down : begin X:=0; Inc(Y); end;
          end;
          TypeCursor(X,Y);
          if Cursor in [crOurLLine,crOurRLine,crOurULine,crOurDLine]
          then MouseDown1([],X,Y)
          else ClearSelection([vsObj]);
          SetKbdCtrl; goto lend;
        end;
    else
    	// Отменить отметку ячеек
    	if BvRect.Visible then begin
      	BvRect.Visible:=false;
        if Assigned(tl) then with tl do begin
          DelKey(K_All,'GFKbdSel'); ReDrw;
        end;
      end
      // Выйти из управления курсором с клавиатуры
      else begin
        SetKbdCtrl; goto lend;
      end
    end;
  	EnsureSelf(FKbdCrd.Col,0,high(FGridX));
	  EnsureSelf(FKbdCrd.Row,0,high(FGridY)); 
    X:=GridX[FKbdCrd.Col];
    if BvRect.Visible and (X>BvX) then Dec(X);
    Y:=GridY[FKbdCrd.Row];
    if BvRect.Visible and (Y>BvY) then Dec(Y);
    MouseMove1([],X,Y);
  end
  // Начать управление курсором с клавиатуры
  else SetKbdCtrl(true);
  TmpCtrlView(GridX[FKbdCrd.Col],GridY[FKbdCrd.Row]);
	if not FKbdCtrl then goto lend;
  noMove:=true; p:=ClientOrigin;
  SetCursorPos(p.X+GridX[FKbdCrd.Col],p.Y+GridY[FKbdCrd.Row]);
  Timer.OnTimer:=TimerMouseMove; Timer.Enabled:=true;
lend:
	DelStack;
end;

procedure TGenForm.SetKbdCtrl;
var tl: TKeyLb;
begin
  AddStack('TGenForm.SetKbdCtrl',Self);
  if FKbdCtrl<>Value then begin
    FormKeyLb(Self,tl);
    if Value then begin
      Cursor:=CursDefault; KbdRound;
      if Assigned(tl) then with tl do begin
        SetButNoEval(true); oldClose:=ParentForm(Self).OnClose;
        ParentForm(Self).OnClose:=FormClose;
        oldPpMenu:=PopupMenu; PopupMenu:=nil;
        SetKeys([K_Esc,K_F10],'Отмена','Отменить управление с клавиатуры',GFProcKey,'GFKbd',kmGFKbd);
        SetKeys([K_Enter,K_Shift_Enter],'Отметить','Начать отметку ячеек',GFProcKey,'GFKbd',kmGFKbd);
        SetKey(K_Ctrl_Home,'','В начало формы',GFProcKey,'GFKbd',kmGFKbd);
        SetKey(K_Ctrl_End,'','В конец формы',GFProcKey,'GFKbd',kmGFKbd);
        SetKey(K_Ctrl_PgUp,'','На первую строку',GFProcKey,'GFKbd',kmGFKbd);
        SetKey(K_Ctrl_PgDn,'','На последнюю строку',GFProcKey,'GFKbd',kmGFKbd);
        SetKey(K_Alt_Left,'Слева','Отметить объекты слева',GFProcKey,'GFKbd',kmGFKbd);
        SetKey(K_Alt_Right,'Справа','Отметить объекты справа',GFProcKey,'GFKbd',kmGFKbd);
        SetKey(K_Alt_Up,'Сверху','Отметить объекты сверху',GFProcKey,'GFKbd',kmGFKbd);
        SetKey(K_Alt_Down,'Снизу','Отметить объекты снизу',GFProcKey,'GFKbd',kmGFKbd);
        SetKey(K_Home,'','На первую колонку',GFProcKey,'GFKbd',kmNone);
        SetKey(K_End,'','На последнюю колонку',GFProcKey,'GFKbd',kmNone);
        SetKey(K_PgUp,'','На предыдущую вертикальную видимую область',GFProcKey,'GFKbd',kmNone);
        SetKey(K_PgDn,'','На следующую вертикальную видимую область',GFProcKey,'GFKbd',kmNone);
        SetKey(K_Up,'','На предыдущую строку',GFProcKey,'GFKbd',kmNone);
        SetKey(K_Down,'','На следующую строку',GFProcKey,'GFKbd',kmNone);
        SetKey(K_Left,'','На предыдущую колонку',GFProcKey,'GFKbd',kmNone);
        SetKey(K_Right,'','На следующую колонку',GFProcKey,'GFKbd',kmNone);
        SetKey(K_Ctrl_Left,'','На предыдущую горизонтальную видимую область',GFProcKey,'GFKbd',kmNone);
        SetKey(K_Ctrl_Right,'','На следующую горизонтальную видимую область',GFProcKey,'GFKbd',kmNone);
        ReDrw;
      end;
    end
    else if Assigned(tl) then with tl do begin
      DelKey(K_All,'GFKbd'); PopupMenu:=oldPpMenu;
      ParentForm(Self).OnClose:=oldClose; SetButNoEval(false); ReDrw;
    end;
    FKbdCtrl:=Value;
  end;
  DelStack;
end;

procedure TGenForm.TimerMouseMove;
begin
	AddStack('TGenForm.TimerMouseMove',Self);
  Timer.Enabled:=false; noMove:=false;
  DelStack;
end;

class procedure TGenForm.FormClose;
var tl: TKeyLb;
begin
	AddStack('TGenForm.FormClose');
	if FormKeyLb(TControl(Sender),tl) and (Action=caHide) then begin
    Action:=caNone; tl.ExecKey(K_Esc);
  end;
  DelStack;
end;

{ ОТМЕТКА }

// Снять все отметки
procedure TGenForm.ClearAllSelection;
begin
	AddStack('TGenForm.ClearAllSelection',Self);
	ClearSelection([vsGrid,vsObj]);
  DelStack;
end;

// Снять отметку
procedure TGenForm.ClearSelection;
var i: longint;
begin
	AddStack('TGenForm.ClearSelection',Self);
	if vsGrid in vsel then begin
  	FSelected:=false; SelectGrid; Refresh;
  end;
	if vsObj in vsel then begin
  	TmpList1.Clear;
		for i:=0 to SelObjectCount-1 do TmpList1.Add(PGFObj(FSelObjects[i]));
    if SelectObjs(TmpList1,false) then PaintFillAll;
  end;
  DelStack;
end;

// Отметить ячейки
procedure TGenForm.SelectGrid;
begin
	AddStack('TGenForm.SelectGrid',Self);
  IfThenNotify(FOnSelectGrid,Self);
  DelStack;
end;

// Отметить объекты/снять отметку с объектов
function TGenForm.SelectObjs;
var i,p: longint;
	pv: PGFObj;
begin
	AddStack('TGenForm.SelectObjs',Self);
  result:=false;
  if FSelected then begin
  	result:=true; ClearSelection([vsGrid]);
  end;
	if ListObj.Count>0 then begin
  	result:=true;
    for i:=0 to ListObj.Count-1 do begin
      pv:=ListObj[i];
      with FSelObjects do begin
        p:=IndexOf(pv); pv.Selected:=lSel;
        if (p<0)=lSel then
	        if lSel then Add(pv) else Delete(p);
      end;
    end;
    if FState=gsDesign then begin
    	PaintObj(ListObj);
      if Assigned(bmPaint) then begin
        CurCanvas:=bmPaint.Canvas; PaintObj(ListObj); CurCanvas:=Canvas;
      end;
    end;
    DoSelectObjs(ListObj,lSel);
  end;
  DelStack;
end;

procedure TGenForm.DoSelectObjs;
begin
  AddStack('TGenForm.DoSelectObjs',Self);
  if Assigned(FOnSelectObjs) then FOnSelectObjs(Self,ListObj,lSel);
  DelStack;
end;

procedure TGenForm.SelExtendObj;
var i: longint;
  //v: TGFObj;
begin
  AddStack('TGenForm.SelExtendObj',Self);
  if ListObj.Count=0 then begin
    for i:=0 to ObjectCount-1 do
    {begin
      v:=Objects[i];
      if (SzGridWidth(false,GetMinWidth(v))<GridX[v.Right]-GridX[v.Left])
      or (SzGridWidth(true,GetMinHeight(v))<GridY[v.Bottom]-GridY[v.Top]) then}
      ListObj.Add(PObjects[i]);
    //end;
    SelectObjs(ListObj,true);
  end
  else begin
    SelectObjs(ListObj,false); ListObj.Clear;
  end;
  PaintAll;
  DelStack;
end;

// Нарисовать отмеченные ячейки
procedure TGenForm.PaintSelected;
var i: longint;
begin
	AddStack('TGenForm.PaintSelected',Self);
	if not noPaint and (FState=gsDesign) and FSelected then with CurCanvas do begin
  	Brush.Color:=clBlack;
    FillRect(Rect(GridX[FRectSel.Left-1]+1,GridY[FRectSel.Top-1]+1,
    	GridX[FRectSel.Right],GridY[FRectSel.Bottom]));
    Pen.Color:=Color1; Pen.Style:=psDot;
    for i:=FRectSel.Left to FRectSel.Right-1 do begin
			MoveTo(GridX[i],GridY[FRectSel.Top-1]);
      LineTo(GridX[i],GridY[FRectSel.Bottom]);
    end;
    for i:=FRectSel.Top to FRectSel.Bottom-1 do begin
			MoveTo(GridX[FRectSel.Left-1],GridY[i]);
      LineTo(GridX[FRectSel.Right],GridY[i]);
    end;
  end;
  DelStack;
end;

{ ВЫРАВНИВАНИЕ СЕТКИ ПО ОБЪЕКТАМ }

procedure TGenForm.AutoSize;
var i,j: longint;
	pv: PGFObj;
  optX: TGFAutoSizeXOpt;
begin
	AddStack('TGenForm.AutoSize',Self);
	for i:=0 to high(FGridX) do FGridX[i].Calc:=true;
	for i:=0 to high(FGridY) do FGridY[i].Calc:=true;
  // Удаление лишних столбцов и строк
	for i:=0 to ObjectCount-1 do begin
  	pv:=PObjects[i];
    FGridX[pv.Left].Calc:=false; FGridX[pv.Right].Calc:=false;
    FGridY[pv.Top].Calc:=false; FGridY[pv.Bottom].Calc:=false;
  end;
  for i:=high(FGridX) downto 0 do
  	if FGridX[i].Calc then begin
      for j:=0 to ObjectCount-1 do begin
        pv:=PObjects[j];
        if pv.Left>=i then Dec(pv.Left);
        if pv.Right>=i then Dec(pv.Right);
      end;
      if high(FGridX)>1 then ColCount:=high(FGridX)-1;
    end;
  for i:=high(FGridY) downto 0 do
  	if FGridY[i].Calc then begin
      for j:=0 to ObjectCount-1 do begin
        pv:=PObjects[j];
        if pv.Top>=i then Dec(pv.Top);
        if pv.Bottom>=i then Dec(pv.Bottom);
      end;
      if high(FGridY)>1 then RowCount:=high(FGridY)-1;
    end;
  optX:=[gfszxCalcRate];
  if WidthOnLeaf then Include(optX,gfszxWidthOnLeaf);
  AutoSizeX(0,optX); AutoSizeY(0,[gfszyLaWidth]);
  IfThenNotify(FOnAutoSize,Self); DoSelectObjs(FSelObjects,true);
  //if FState=gsView then SetSizeMm;
  PaintAll;
  DelStack;
end;

function SortLeft(Item1,Item2: Pointer): longint;
begin
	AddStack('GenForm.SortLeft');
	result:=PGFObj(Item1).Left;
  if Assigned(Item2) then Dec(result,PGFObj(Item2).Left);
  DelStack;
end;

function SortLeftDesc(Item1,Item2: Pointer): longint;
begin
	AddStack('GenForm.SortLeftDesc');
	result:=PGFObj(Item2).Left-PGFObj(Item1).Left;
  DelStack;
end;

function SortRight(Item1,Item2: Pointer): longint;
begin
	AddStack('GenForm.SortRight');
	result:=PGFObj(Item1).Right;
  if Assigned(Item2) then Dec(result,PGFObj(Item2).Right);
  DelStack;
end;

function SortTop(Item1,Item2: Pointer): longint;
begin
	AddStack('GenForm.SortTop');
	result:=PGFObj(Item1).Top;
  if Assigned(Item2) then Dec(result,PGFObj(Item2).Top);
  DelStack;
end;

function SortTopDesc(Item1,Item2: Pointer): longint;
begin
	AddStack('GenForm.SortTopDesc');
	result:=PGFObj(Item2).Top-PGFObj(Item1).Top;
  DelStack;
end;

function SortBottom(Item1,Item2: Pointer): longint;
begin
	AddStack('GenForm.SortBottom');
	result:=PGFObj(Item1).Bottom;
  if Assigned(Item2) then Dec(result,PGFObj(Item2).Bottom);
  DelStack;
end;

function TGenForm.SzGridWidth;
begin
	AddStack('TGenForm.SzGridWidth',Self);
	result:=n;
  if (FState=gsDesign) or (n>0) then Inc(result,GridLine(lY));
  DelStack;
end;

procedure TGenForm.aSortFill;
var i,oj,nj: longint;
begin
  AddStack('TGenForm.aSortFill',Self);
  for i:=0 to high(FGrid) do FGrid[i].Order1:=-1;
  FObjects.Sort(Compare); SetLength(a,ObjectCount); oj:=-1;
  for i:=low(a) to high(a) do begin
    a[i]:=PObjects[i]; nj:=Compare(a[i],nil);
    if nj<>oj then begin
      oj:=nj; FGrid[nj].Order1:=i;
    end;
  end;
  DelStack;
end;

// Распределение по X начиная от столбца ACol
procedure TGenForm.AutoSizeX;
var aX,aY: TArrPGFObj;
	// Расчёт координаты по X слева
  function SzRashLeft(ACol: Word): longint;
  var i,j,k: longint;
    v: TGFObj;
  begin
  	AddStack('TGenForm.AutoSizeX.SzRashLeft',Self);
    with FGridX[ACol] do begin
      if not Calc then begin
        Calc:=true; Crd:=0;
        // Определение минимального левого предела для линии
        if Order1>=0 then begin
          for i:=Order1 to high(aX) do begin
            if aX[i].Left<>ACol then break;
            for j:=aX[i].Top+1 to high(FGridY) do if FGridY[j].Order1>=0 then begin
              for k:=FGridY[j].Order1 to high(aY) do with aY[k]^ do
                if (Top<aX[i].Bottom) and (Right<aX[i].Left) then MaxSelf(Crd,Right);
              break;
            end;
          end;
          Crd:=SzRashLeft(Crd)+SzGridWidth(false);
        end;
        if Order>=0 then for i:=Order to ObjectCount-1 do begin
          v:=Objects[i]; if v.Right<>ACol then break;
          MaxSelf(Crd,SzRashLeft(v.Left)+SzGridWidth(false,GetMinWidth(v)));
        end
        else if not Busy then Crd:=SzRashLeft(ACol-1)+SzGridWidth(false);
      end;
      result:=Crd;
    end;
    DelStack;
  end;
  // Расчёт координаты по X справа
  function SzRashRight(ACol: Word): longint;
  var i,i1,j,k: longint;
    v: TGFObj;
    fl: boolean;
  begin
  	AddStack('TGenForm.AutoSizeX.SzRashRight',Self);
    with FGridX[ACol] do begin
      if Calc then begin
      	Calc:=false;
        if Order>=0 then begin
        	fl:=true;
          for i:=Order to ObjectCount-1 do begin
            v:=Objects[i]; if v.Left<>ACol then break;
            if PinRight(v.Pin) then begin
            	if fl then begin
			        	fl:=false; Crd:=high(FGridX);
                // Определение максимального правого предела для линии
                if Order1>=0 then for i1:=Order1 to high(aX) do begin
                  if aX[i1].Right<>ACol then break;
                  for j:=aX[i1].Top+1 to high(FGridY) do if FGridY[j].Order1>=0 then begin
                    for k:=FGridY[j].Order1 to high(aY) do with aY[k]^ do
                      if (Top<aX[i1].Bottom) and (Left>aX[i1].Right) then MinSelf(Crd,Left);
                    break;
                  end;
                end;
                Crd:=SzRashRight(Crd)-SzGridWidth(false);
              end;
            	MinSelf(Crd,SzRashRight(v.Right)-SzGridWidth(false,GetMinWidth(v)));
            end;
          end;
        end;
      end;
      result:=Crd;
    end;
    DelStack;
  end;
var r: longint;
  function RightToLeaf: boolean;
  var i,j: longint;
  begin
    AddStack('TGenForm.AutoSizeX.RightToLeaf',Self);
    j:=GridX[high(FGridX)]; result := j<r;
    if result then for i:=high(FGridX) downto 1 do
      if GridX[i]=j then GridX[i]:=r else break;
    DelStack;
  end;
var i,j,w,MaxLineEd: longint;
	pv: PGFObj;
  aCrd: TArrInt;
  tw: TWinControl;
begin
	AddStack('TGenForm.AutoSizeX',Self);
  if gfszxCalcRate in Opt then CalcRate;
  if ACol=0 then GridX[0]:=FSpot.Left+IfThen(FState=gsDesign,WdtLnSel);
  for i:=0 to high(FGridX) do with FGridX[i] do begin
    Order:=0; Calc := i<ACol;
  end;
  aSortFill(SortBottom,aY,FGridY);
  // Определение линий, левее которых есть пустые ячейки
  for i:=0 to ObjectCount-1 do begin
    pv:=PObjects[i]; r:=pv.Bottom-pv.Top;
    for j:=pv.Left+1 to pv.Right do Inc(FGridX[j].Order,r);
  end;
  // Расчёт координат по X слева
  for i:=ACol+1 to high(FGridX) do with FGridX[i] do begin
    Busy := Order=high(FGridY); Order:=-1;
  end;
  aSortFill(SortLeft,aX,FGridX); FGridX[ACol].Calc:=true; j:=0; MaxLineEd:=0;
  FObjects.Sort(SortRight);
  for i:=0 to ObjectCount-1 do begin
    pv:=PObjects[i];
    if pv.Right<>j then begin
      j:=pv.Right; FGridX[j].Order:=i;
    end;
    if MaxLineEd=0 then if IsObjGet(pv^) then if pv.TypeObj=toGet then if TFldEdit(pv.DopObj).CharWidth<0 then begin
      MaxLineEd:=pv.Right;
      for r:=0 to ObjectCount-1 do begin
        pv:=PObjects[r];
        if pv.Left>=MaxLineEd then pv.Pin:=TGFPinList(byte(pv.Pin) or 1);
      end;
    end;
  end;
  for i:=ACol+1 to high(FGridX) do SzRashLeft(i);
  if (FState<>gsDesign) and (false in FParams.Arr[FCurParams].aWidth) and not SizeNoLimit then begin
    r:=nround((Width-FSpot.Right-LineWidth)/ScalePrc);
    if not RightToLeaf and (gfszxWidthOnLeaf in Opt) then begin
      w:=r-nround((FSpot.Left-LineWidth)/ScalePrc);
      for i:=1 to high(FGridX) do
        if GridX[i]>r then begin
          Dec(r,GridX[i-1]);
          for j:=i-1 to high(FGridX) do Inc(FGridX[j].Crd,r);
          r:=GridX[i-1]+w;
        end;
      RightToLeaf;
    end;
  end;
  // Расчёт координат по X справа
  for i:=0 to ObjectCount-1 do with Objects[i] do
    if not((FState<>gsDesign) and (Part='') or PinRight(Pin)) then FGridX[Left].Calc:=false;
  for i:=ACol+1 to high(FGridX) do FGridX[i].Order:=-1;
  aSortFill(SortRight,aX,FGridX); FGridX[ACol].Calc:=false; j:=high(FGridX); FGridX[j].Calc:=false;
  FObjects.Sort(SortLeftDesc);
  for i:=0 to ObjectCount-1 do begin
    pv:=PObjects[i];
    if pv.Left<>j then begin
      j:=pv.Left; FGridX[j].Order:=i;
    end;
  end;
  for i:=high(FGridX) downto ACol+1 do SzRashRight(i);
  // TFldEdit с максимальной шириной
  if MaxLineEd>0 then
    if ParentClass(tw,Parent,TRbPanel) then begin
      j:=TRbPanel(tw).CltWidth-GridX[high(FGridX)]-FSpot.Right-SysMetric.iScrollWidth;
      if j>0 then for i:=MaxLineEd to high(FGridX) do Inc(FGridX[i].Crd,j);
    end;
  if not(gfszxNoCngCrd in Opt) then begin
    // Соответствие формального расположения линий визуальному
    Crd2Visible(FGridX,aCrd);
    for i:=0 to ObjectCount-1 do begin
      pv:=PObjects[i]; pv.Left:=aCrd[pv.Left]; pv.Right:=aCrd[pv.Right];
    end;
  end;
  // Совпадение близлежащих линий
  if FState=gsDesign then begin
    for i:=high(FGridX) downto ACol+1 do begin
      r:=nround(aRate[false]){GridLine(false)}-(GridX[i]-GridX[i-1]);
      if r>0 then
        for j:=i to high(FGridX) do Inc(FGridX[j].Crd,r);
    end;
    SetSizeMm;
  end;
  DelStack;
end;

// Распределение по Y начиная от строки ARow
procedure TGenForm.AutoSizeY;
var aY,aX: TArrPGFObj;
  // Расчёт координаты по Y сверху
  function SzRashTop(ARow: Word): longint;
  var i,j,k: longint;
    v: TGFObj;
  begin
  	AddStack('TGenForm.AutoSizeY.SzRashTop',Self);
    with FGridY[ARow] do begin
      if not Calc then begin
        Calc:=true; Crd:=0;
        // Определение минимального верхнего предела для линии
        if Order1>=0 then begin
          for i:=Order1 to high(aY) do begin
            if aY[i].Top<>ARow then break;
            for j:=aY[i].Left+1 to high(FGridX) do if FGridX[j].Order1>=0 then begin
              for k:=FGridX[j].Order1 to high(aX) do with aX[k]^ do
                if (Left<aY[i].Right) and (Bottom<aY[i].Top) then MaxSelf(Crd,Bottom);
              break;
            end;
          end;
          Crd:=SzRashTop(Crd)+SzGridWidth(true);
        end;
        if Order>=0 then for i:=Order to ObjectCount-1 do begin
          v:=Objects[i]; if v.Bottom<>ARow then break;
          MaxSelf(Crd,SzRashTop(v.Top)+SzGridWidth(true,GetMinHeight(v)))
        end
        else if not Busy then Crd:=SzRashTop(ARow-1)+SzGridWidth(true);
      end;
      result:=Crd;
    end;
    DelStack;
  end;
  // Расчёт координаты по Y снизу
  function SzRashBottom(ARow: Word): longint;
  var i,i1,j,k: longint;
    v: TGFObj;
    fl: boolean;
  begin
  	AddStack('TGenForm.AutoSizeY.SzRashBottom',Self);
    with FGridY[ARow] do begin
      if Calc then begin
        Calc:=false;
        if Order>=0 then begin
        	fl:=true;
          for i:=Order to ObjectCount-1 do begin
            v:=Objects[i]; if v.Top<>ARow then break;
            if PinBottom(v.Pin) then begin
            	if fl then begin
			        	fl:=false; Crd:=high(FGridY);
                // Определение максимального нижнего предела для линии
                if Order1>=0 then for i1:=Order1 to high(aY) do begin
                  if aY[i1].Bottom<>ARow then break;
                  for j:=aY[i1].Left+1 to high(FGridX) do if FGridX[j].Order1>=0 then begin
                    for k:=FGridX[j].Order1 to high(aX) do with aX[k]^ do
                      if (Left<aY[i1].Right) and (Top>aY[i1].Bottom) then MinSelf(Crd,Top);
                    break;
                  end;
                end;
                Crd:=SzRashBottom(Crd)-SzGridWidth(true);
              end;
              MinSelf(Crd,SzRashBottom(v.Bottom)-SzGridWidth(true,GetMinHeight(v)));
            end;
          end;
        end;
      end;
      result:=Crd;
    end;
    DelStack;
  end;
var i,j,r,MaxRowEd: longint;
  pv: PGFObj;
  aCrd: TArrInt;
  tw: TWinControl;
begin
	AddStack('TGenForm.AutoSizeY',Self);
  if gfszyCalcRate in Opt then CalcRate;
  if ARow=0 then GridY[0]:=FSpot.Top+IfThen(FState=gsDesign,WdtLnSel);
	for i:=0 to high(FGridY) do with FGridY[i] do begin
  	Order:=0; Calc := i<ARow;
  end;
  aSortFill(SortRight,aX,FGridX);
  // Определение линий, выше которых есть пустые ячейки
  for i:=0 to ObjectCount-1 do with Objects[i] do begin
    pv:=PObjects[i]; r:=pv.Right-pv.Left;
    for j:=pv.Top+1 to pv.Bottom do Inc(FGridY[j].Order,r);
  end;
  // Расчёт координат по Y сверху
  for i:=ARow+1 to high(FGridY) do with FGridY[i] do begin
    Busy := Order=high(FGridX); Order:=-1;
  end;
  aSortFill(SortTop,aY,FGridY); FGridY[ARow].Calc:=true; j:=0; MaxRowEd:=0;
  FObjects.Sort(SortBottom);
  for i:=0 to ObjectCount-1 do begin
  	pv:=PObjects[i];
    if pv.Bottom<>j then begin
      j:=pv.Bottom; FGridY[j].Order:=i;
    end;
    if MaxRowEd=0 then if IsObjGet(pv^) then if pv.TypeObj=toGet then if TFldEdit(pv.DopObj).CharHeight<0 then begin
      MaxRowEd:=pv.Bottom;
      for r:=0 to ObjectCount-1 do begin
        pv:=PObjects[r];
        if pv.Top>=MaxRowEd then pv.Pin:=TGFPinList(byte(pv.Pin) or 2);
      end;
    end;
  end;
  for i:=ARow+1 to high(FGridY) do SzRashTop(i);
  if (FState<>gsDesign) and not SizeNoLimit
  and (gfszyLaWidth in Opt) and (true in FParams.Arr[FCurParams].aWidth) then begin
    j:=GridY[high(FGridY)]; r:=nround((Height-FSpot.Bottom-LineWidth([gfwY]))/ScalePrc);
    if j<r then for i:=high(FGridY) downto 1 do
      if GridY[i]=j then GridY[i]:=r else break;
  end;
  // Расчёт координат по Y снизу
  for i:=0 to ObjectCount-1 do with Objects[i] do
    if not((FState<>gsDesign) and (Part='') or PinBottom(Pin)) then FGridY[Top].Calc:=false;
  for i:=ARow+1 to high(FGridY) do FGridY[i].Order:=-1;
  aSortFill(SortBottom,aY,FGridY); FGridY[ARow].Calc:=false; j:=high(FGridY); FGridY[j].Calc:=false;
  FObjects.Sort(SortTopDesc);
  for i:=0 to ObjectCount-1 do begin
    pv:=PObjects[i];
    if pv.Top<>j then begin
      j:=pv.Top; FGridY[j].Order:=i;
    end;
  end;
  for i:=high(FGridY) downto ARow+1 do SzRashBottom(i);
  // TFldEdit с максимальной высотой
  if MaxRowEd>0 then
    if ParentClass(tw,Parent,TRbPanel) then begin
      with TRbPanel(tw) do j:=CltHeight-HeaderHeight-GridY[high(FGridY)]-FSpot.Bottom;
      if j>0 then for i:=MaxRowEd to high(FGridY) do Inc(FGridY[i].Crd,j);
    end;
  // Соответствие формального расположения линий визуальному
  Crd2Visible(FGridY,aCrd);
  for i:=0 to ObjectCount-1 do begin
    pv:=PObjects[i]; pv.Top:=aCrd[pv.Top]; pv.Bottom:=aCrd[pv.Bottom];
  end;
  // Совпадение близлежащих линий
  if FState=gsDesign then begin
    for i:=high(FGridY) downto ARow+1 do begin
      r:=nround(aRate[true])-(GridY[i]-GridY[i-1]);
      if r>0 then
        for j:=i to high(FGridY) do Inc(FGridY[j].Crd,r);
    end;
    SetSizeMm;
  end;
  DelStack;
end;

type TArrPGFGrid = array of PGFGrid;

function SortCrd(p: pointer; fi,si: longint; sortID: TSortID): boolean;
var ap: ^TArrPGFGrid;
  v: PGFGrid;
  i: longint;
begin
	AddStack('GenForm.SortCrd');
  result:=false; ap:=p;
  case sortID of
    sort1MORE2: begin
      i:=ap^[fi].Crd-ap^[si].Crd;
      if i=0 then i:=ap^[fi].Order-ap^[si].Order;
      result := i>0;
    end;
    sortEXCHANGE: begin
      v:=ap^[fi]; ap^[fi]:=ap^[si]; ap^[si]:=v;
    end;
  end;
  DelStack;
end;

procedure TGenForm.Crd2Visible;
var i,l: longint;
  a: TArrGFGrid;
  ap: TArrPGFGrid;
begin
  AddStack('TGenForm.Crd2Visible',Self);
  l:=Length(FGrid); SetLength(a,l); SetLength(ap,l); SetLength(aCrd,l); Dec(l);
  for i:=0 to l do with a[i] do begin
    Order:=i; Crd:=FGrid[i].Crd; ap[i]:=@a[i];
  end;
  QuickSort(SortCrd,@ap,0,l);
  for i:=0 to l do with ap[i]^ do begin
    aCrd[Order]:=i; FGrid[i].Crd:=Crd;
  end;
  DelStack;
end;

{ СОХРАНЕНИЕ / ВОССТАНОВЛЕНИЕ }

// Номер версии и номер сохранения (и ещё много чего)
procedure ReadVers(var result: TGFVersInfo; f: TCustomBuf; const fn: TFileName; brk: TGFBreakRead);
var fl: boolean;
  ost: longint;
label lend;
begin
	ost:=AddStack('GenForm.ReadVers');
  Finalize(result); ZeroMemory(@result,SizeOf(result));
  with result do begin
    fl := not Assigned(f);
    if fl then f:=TFileBuf.Create(fn);
    try
      try
        if f.Active and (f.Size>=SizeOfVar[stInteger]) then begin
          f.Seek(-SizeOfVar[stInteger],soFromEnd); ChkSum:=f.Read(stInteger);
          f.Seek(0,soFromBeginning);
          Vers:=f.Read(stByte); if brk=gbrVers then goto lend;
          if Vers>=6 then begin
            f.Read(stByte);
            MDName:=f.ReadStr(MDLenName); if brk=gbrMDName then goto lend;
            if Vers>=15 then begin
              MDNSave:=f.Read(stLongWord); if brk=gbrMDNSave then goto lend;
            end;
            if Vers>=37 then f.ReadModelPrim(MDPrim)
            else begin
              SetLength(MDPrim,1); MDPrim[0].Prim:=f.ReadStr;
            end;
            if brk=gbrMDPrim then goto lend;
          end;
          NumSave:=f.Read(Vers>=4,stLongWord,1);
          if InRange(Vers,6,36) then MDPrim[0].NumSave:=NumSave;
          if brk=gbrNumSave then goto lend;
          MDFile:=f.ReadStr(Vers>=6);
        end;
lend:
      except
        SetStack(ost);
      end;
    finally
      if fl then f.Free;
    end;
  end;
  DelStack;
end;

function ReadPrmNum(f: TCustomBuf; Vers: Byte): TFmtNum;
begin
  AddStack('GenForm.ReadPrmNum');
  with result do begin
    FracDlm:=Chr(Byte(f.Read(stByte)));
    FracCnt:=f.Read(stByte);
    FracEmp:=Bool2FracEmp(f.Read(stBoolean));
    DigIsDlm:=f.Read(stBoolean);
    DigDlm:=Chr(Byte(f.Read(stByte)));
    ZeroEmp.l:=f.Read(Vers>=3,stBoolean,false);
    AllCnt:=f.Read(Vers>=9,stByte,0);
    ZeroEmp.s:=f.ReadStr(Vers>=42);
  end;
  DelStack;
end;

function ReadPrmDate(f: TCustomBuf; Vers: Byte): TFmtDate;
begin
  AddStack('GenForm.ReadPrmDate');
  with result do begin
    Dlm:=Chr(Byte(f.Read(stByte)));
    NYear:=f.Read(stByte);
    MMYY:=f.Read(Vers>=44,stBoolean,false);
    if Vers>=43 then begin
      ZeroEmp.l:=f.Read(stBoolean); ZeroEmp.s:=f.ReadStr;
    end;
  end;
  DelStack;
end;

function ReadParams(f: TCustomBuf; Vers: Byte; InGet: boolean = false): TGFParams;
var i: byte;
  sz: TSize;
begin
  AddStack('GenForm.ReadParams');
  with result do begin
    i:=f.Read(Vers>=25,stByte,1); DateTime:=true; SetLength(Arr,i);
    for i:=0 to i-1 do with Arr[i] do begin
    	Arr[i]:=TGenForm.PrmDef; GridLineWidth:=f.Read(stByte); GridLineMin:=f.Read(Vers>=29,stByte,1);
      f.Read(Vers=18,stReal,null);
      if (Vers<19) and (GGPrinter.Printers.Count>0) then GridLineWidth:=EnsureRange(
        nround(GridLineWidth/GetDeviceCaps(GGPrinter.Handle,LOGPIXELSX)*MmInInch*10),
        low(GridLineWidth),high(GridLineWidth));
      StdFormat:=f.Read(stBoolean);
      if InGet then StdFormat:=false;
      NFormat:=f.Read(stByte); Orientation:=f.Read(stByte)-1;
      if (Vers>=7) and ((Vers<30) or (i=low(Arr))) then DateTime:=f.Read(stBoolean);
      if Vers>=28 then begin
      	SetSet(aBreak,false,f.Read(stBoolean)); SetSet(aBreak,true,f.Read(stBoolean));
      end;
      if Vers>=41 then begin
      	SetSet(aWidth,false,f.Read(stBoolean)); SetSet(aWidth,true,f.Read(stBoolean));
      end;
      if InRange(Vers,8,48) then begin
        // Текстовый режим
      	f.Read(i=low(Arr),stBoolean,null); //TextMode
        f.Read(stByte); f.Read(stWord); //Shrf;SpLeftText
        if Vers<12 then f.Read(stWord) else f.Read(stSmallInt); //Intv
        f.Read(stWord); f.Read(stWord); f.Read(stByte); //WidthText;HeightText;VTabl
      end;
      if Vers>=2 then begin
        PrmNum:=ReadPrmNum(f,Vers); PrmDate:=ReadPrmDate(f,Vers);
      end;
      SpotMm.Left:=f.Read(stWord); SpotMm.Top:=f.Read(stWord);
      SpotMm.Right:=f.Read(stWord); SpotMm.Bottom:=f.Read(stWord);
      sz.cX:=f.Read(stInteger); sz.cY:=f.Read(stInteger);
      if not InGet then SizeMm:=sz;
      Name:=f.ReadStr(Vers>=25);
    end;
  end;
  DelStack;
end;

procedure ReadFonts(FBuf: TCustomBuf; Vers: Byte; LsFont: TList);
var i,m,cnt: longint;
  f: TGFPackFont;
begin
  AddStack('GenForm.ReadFonts');
  cnt:=FBuf.Read(stByte); f:=TGFPackFont.Create;
  try
    for i:=1 to cnt do begin
      f.Font.Color:=AColor[EnsureRange(FBuf.Read(stByte),low(aColor),high(aColor))];
      f.Font.Size:=FBuf.Read(stByte);
      f.Font.Style:=TFontStyles(byte(FBuf.Read(stByte)));
      f.Font.Name:=FBuf.ReadStr; f.Prop.Prim:=FBuf.ReadStr;
      f.Font.CharSet:=DEFAULT_CHARSET; f.Prop.AType:=fptNormal;
      ZeroMemory(@f.Prop.Dop,SizeOf(f.Prop.Dop));
      if Vers>=2 then f.Font.CharSet:=FBuf.Read(stByte);
      if Vers<36 then begin
        if Vers>=10 then f.Prop.Dop.OnlyDig:=FBuf.Read(stBoolean);
        if Vers>=13 then f.Prop.Dop.RowBetween:=FBuf.Read(stShortInt);
        if Vers>=17 then f.Prop.Dop.WidthTextAll:=FBuf.Read(stBoolean);
        if Vers>=20 then f.Prop.Dop.OnWidth:=FBuf.Read(stBoolean);
        if Vers>=21 then f.Prop.Dop.ALine:=FBuf.Read(stBoolean);
        if Vers>=24 then f.Prop.Angle:=FBuf.Read(stWord);
      end
      else begin
        f.Prop.AType:=FBuf.Read(stByte);
        if Vers>=40 then f.Prop.Angle:=FBuf.Read(stWord);
        for m:=low(f.Prop.Dop.s) to IfThen(Vers<38,7,11) do
          f.Prop.Dop.s[m]:=char(byte(FBuf.Read(stByte)));
        if Vers<40 then f.Prop.Angle:=f.Prop.Dop.Unused1;
      end;
      TGenForm.FontAdd(LsFont,f);
    end;
  finally
    f.Free;
  end;
  DelStack;
end;

function TGenForm.FileBufActive;
begin
	AddStack('TGenForm.FileBufActive',Self);
	result:=false;
  if Assigned(FBuf) then
    if FBuf.Active then result:=true;
  DelStack;
end;

// Закрыть файл чтения/записи
procedure TGenForm.CloseDtg;
begin
	AddStack('TGenForm.CloseDtg',Self);
	FreeAndNil(FBuf);
  DelStack;
end;

// Сохранить форму в файл
function TGenForm.SaveDcm;
var fn: TFileName;
  s: string;
begin
	AddStack('TGenForm.SaveDcm',Self);
  fn:=FullNameExe(FFileName,'DCM'); DelFileAtr(fn); result:=false;
  repeat
    FBuf:=TFileBuf.Create(fn,true);
    try
      with FBuf do
        if Active then begin
          FSaveDcm; result:=TFileBuf(FBuf).Update(true); break;
        end
        else s:=ErrorMessage;
    finally
      CloseDtg;
    end;
  until not Ask([s,'Возможно, файл занят другим процессом.',
    'Рекомендуется закрыть другой процесс и повторить попытку,','в противном случае файл может быть удалён.',
    'Повторить попытку сохранения ?']);
  DelStack;
end;

procedure TGenForm.FSaveDcm;
begin
  AddStack('TGenForm.FSaveDcm',Self);
  if FileBufActive then begin
    SaveVers; SavePages;
  end;
  DelStack;
end;

procedure UpdateDBDcm;
var lAct,lCon: boolean;
	db: TComponent;
  inf: TGFVersInfo;
	fn: TFileName;
  s: string;
label lend;
begin
	AddStack('GenForm.UpdateDBDcm');
	if DBDcm<>nil then 
    if FirstDataBase(DBDcm.Connection,db) then begin
      lCon:=Connected(db); SetConnected(db,true); lAct:=DBDcm.Active; DBDcm.Active:=true;
      if DBDcm.Active then begin
        fn:=FullNameExe(FileName,'DCM'); s:=GetStrFile(fn);
        ReadVers(inf,nil,fn,gbrNumSave);
        fn:=AnsiUpperCase(FileNameExt(FileName,'DCM'));
        if not DBDcm.Seek(DBDcm.TblFldName(fDCM)+'='+QQs(Padr(fn,Length(DBDcm[fDCM])))) then begin
          DBDcm.NewRec; DBDcm[fDCM]:=fn;
        end
        else if IsChkSum then begin
          if DBDcm['ChkSum']=inf.ChkSum then goto lend;
        end
        else if DBDcm['NumSave']=inf.NumSave then goto lend;
        if IsChkSum then begin
          DBDcm['NumSave']:=0; DBDcm['ChkSum']:=inf.ChkSum;
        end
        else begin
          DBDcm['NumSave']:=inf.NumSave; DBDcm['ChkSum']:=0;
        end;
        DBDcm[fDcmDCM]:=s; DBDcm.AppUpdRec(true);
      end;
lend:
      DBDcm.Active:=lAct; SetConnected(db,lCon);
    end;
	DelStack;
end;

procedure UpdateDcmAll;
var lAct,lCon: boolean;
	db: TComponent;
	q: TMulQuery;
begin
	AddStack('GenForm.UpdateDcmAll');
  if DBDcm<>nil then 
    if FirstDataBase(DBDcm.Connection,db) then begin
      lCon:=Connected(db); SetConnected(db,true);
      lAct:=DBDcm.Active; DBDcm.Active:=true;
      if DBDcm.Active then begin
        q:=TMulQuery.CreateConnection(nil,db);
        with q do begin
          try
            PartSelect(tDCM,fDCM);
            while not Eof do begin
              UpdateDBDcm(TrimRight(Fields[0].AsString)); Next;
            end;
          finally
            Free;
          end;
        end;
      end;
      DBDcm.Active:=lAct; SetConnected(db,lCon);
    end;
  DelStack;
end;

// Сохранить версию
procedure TGenForm.SaveVers;
var i: longint;
  w: TGFWinList;
  fl: boolean;
begin
	AddStack('TGenForm.SaveVers',Self);
	lSaveVers:=false; SvSum:=0; SvCount:=0;
  // Версия
  VersInfo.Vers:=DcmLastVers; SaveVal(VersInfo.Vers,stByte);
  if FState=gsDesign then begin
  	SaveVal(1,stByte); SaveFixStr(VersInfo.MDName,MDLenName);
    SaveVal(longint(VersInfo.MDNSave),stLongWord);
    TCustomBuf.SaveModelPrim(VersInfo.MDPrim,SaveVal,SaveStr,longint(VersInfo.MDNSave));
    Inc(VersInfo.NumSave); SaveVal(longint(VersInfo.NumSave),stLongWord);
    SaveStr(TrimRight(VersInfo.MDFile));
  end;
  // Параметры страницы
  SaveParams;
  // Шрифты
  SaveFonts;
  if FState=gsDesign then begin
  	SaveStr(StrAlg); SaveStr(DopAlg); SaveStr(DopAlgName); SaveStr(MouseAlg);
    for fl:=false to true do SaveStr(awDat[fl]);
    for w:=low(awWin) to high(awWin) do SaveStr(awWin[w]);
  end;
  // Рисунки
  with lsBitMap do begin
    SaveVal(Count,stByte);
    for i:=0 to Count-1 do with GetBM(i)^ do begin
      SaveStr(Strings[i]); SaveStr(Name); SaveStr(BitMapToStr(bm));
    end;
  end;
  DelStack;
end;

procedure TGenForm.SaveParams;
var i: longint;
begin
  AddStack('GenForm.SaveParams');
  with Params do begin
	  SaveVal(Length(Arr),stByte);
    for i:=low(Arr) to high(Arr) do SaveParam(Params,i);
  end;
  DelStack;
end;

procedure TGenForm.SaveParam;
begin
  AddStack('TGenForm.SaveParam',Self);
  with Params,Arr[i] do begin
    SaveVal(GridLineWidth,stByte);
    SaveVal(GridLineMin,stByte);
    SaveVal(StdFormat,stBoolean);
    SaveVal(NFormat,stByte); SaveVal(Succ(Orientation),stByte);
    if i=low(Arr) then SaveVal(DateTime,stBoolean);
    SaveVal(false in aBreak,stBoolean); SaveVal(true in aBreak,stBoolean);
    SaveVal(false in aWidth,stBoolean); SaveVal(true in aWidth,stBoolean);
    SavePrmNum(PrmNum); SavePrmDate(PrmDate);
    SaveVal(SpotMm.Left,stWord); SaveVal(SpotMm.Top,stWord);
    SaveVal(SpotMm.Right,stWord); SaveVal(SpotMm.Bottom,stWord);
    SaveVal(SizeMm.cX,stInteger); SaveVal(SizeMm.cY,stInteger);
    SaveStr(Name);
  end;
  DelStack;
end;

procedure TGenForm.SavePrmNum;
begin
  AddStack('TGenForm.SavePrmNum',Self);
  with PrmNum do begin
    SaveVal(Ord(FracDlm),stByte); SaveVal(FracCnt,stByte);
    SaveVal(FracEmp2Bool(FracEmp),stBoolean);
    SaveVal(DigIsDlm,stBoolean); SaveVal(Ord(DigDlm),stByte);
    SaveVal(ZeroEmp.l,stBoolean); SaveVal(AllCnt,stByte); SaveStr(ZeroEmp.s);
  end;
  DelStack;
end;

procedure TGenForm.SavePrmDate;
begin
  AddStack('TGenForm.SavePrmDate',Self);
  with PrmDate do begin
    SaveVal(Ord(Dlm),stByte); SaveVal(NYear,stByte); SaveVal(MMYY,stBoolean);
    SaveVal(ZeroEmp.l,stBoolean); SaveStr(ZeroEmp.s);
  end;
  DelStack;
end;

procedure TGenForm.SaveFonts;
var i: longint;
begin
  AddStack('TGenForm.SaveFonts',Self);
  SaveVal(FontCount,stByte);
  for i:=0 to FontCount-1 do SaveFont(LsFont,i);
  DelStack;
end;

procedure TGenForm.SaveFont;
var f: TGFPackFont;
  k: longint;
begin
  AddStack('TGenForm.SaveFont',Self);
  f:=LsFont[i];
  SaveVal(SeekColor(f.Font.Color),stByte); SaveVal(f.Font.Size,stByte);
  SaveVal(byte(f.Font.Style),stByte); SaveStr(f.Font.Name);
  SaveStr(f.Prop.Prim); SaveVal(f.Font.CharSet,stByte);
  SaveVal(f.Prop.AType,stByte);
  SaveVal(f.Prop.Angle,stWord);
  for k:=low(f.Prop.Dop.s) to high(f.Prop.Dop.s) do SaveVal(byte(f.Prop.Dop.s[k]),stByte);
  DelStack;
end;

// Сохранить список страниц
procedure TGenForm.SavePages;
var pi: PGFIdent;
  i,sv,ln: longint;
begin
	AddStack('TGenForm.SavePages',Self);
	if FileBufActive then begin
  	if FState=gsDesign then begin
    	i:=FLeaf; FLeaf:=1;
      while FLeaf<=PageCount do begin
      	RestCurLeaf; SavePage;
      end;
      Leaf:=i;
    end
    else begin
      if not(gfsvsEdit in Opt) then SaveLongPage(false);
      with LsBlockLeaf do begin
        ln:=SvCount;
        for i:=0 to Count-1 do begin
          SaveStr(Strings[i]); SaveVal(IntObj(LsBlockLeaf,i),stInteger);
        end;
        SaveVal(SvCount-ln,stInteger);
      end;
      with LsIdent do begin
        ln:=SvCount;
        for i:=0 to Count-1 do begin
          pi:=Idents(i); SaveStr(Strings[i]); SaveVal(pi.Leaf,stLongWord);
          SaveVal(pi.Calc,stBoolean);
          if pi.Calc then begin
            SaveStr(pi.Fml); SaveVal(pi.Edited,stBoolean);
            if pi.Edited then SaveStr(pi.Value);
            SaveVal(pi.Bmp,stBoolean);
          end
          else SaveStr(pi.Value);
        end;
        SaveVal(SvCount-ln,stInteger);
      end;
    end;
    ln:=0;
    for i:=0 to PageCount-1 do with FPages[i] do begin
      SaveVal(sv.OffSet,stInteger);
      if FState=gsView then begin
        SaveVal(sv.PgLong,stInteger); SaveVal(sv.PgSmall,stInteger);
        SaveVal(sv.Modified,stBoolean);
      end;
      Inc(ln,SaveStr(sv.Text));
      if FState=gsView then begin
        SaveVal(sv.WidthMm,stInteger); SaveVal(sv.HeightMm,stInteger);
  			SaveVal(sv.CurParams,stByte);
      end;
		  SaveVal(sv.ColCount,stWord); SaveVal(sv.RowCount,stWord);
  		SaveVal(sv.ObjCount,stInteger);
    end;
    SaveVal(ln,stInteger); SaveVal(PageCount,stInteger);
    // Контрольная сумма
    if not(gfsvsNoChkSum in Opt) then begin
      sv:=SvSum; SaveVal(SvSum,stInteger); SvSum:=sv;
    end;
  end;
  DelStack;
end;

function SortOrder(Item1,Item2: Pointer): longint;
begin
	AddStack('GenForm.SortOrder');
	result:=PGFObj(Item1).Order-PGFObj(Item2).Order;
  DelStack;
end;

// Сохранить длинную страницу
procedure TGenForm.SaveLongPage;
var MarginLeft,MarginRight: Word;
	w,wf,wold,i,j,k,lHead: longint;
	pv: PGFObj;
  aHead: TArrPGFObj;
  fl,isObj,isALine: boolean;
  anpg: TArrBool;
begin
	AddStack('TGenForm.SaveLongPage',Self);
	if FileBufActive and (FObjects.Count>0) then begin
    isObj:=true;
    if FState=gsView then begin
      if lSaveVers then SaveVers;
      FFillObj.Sort(SortOrder); ObjSpace(nil,[gfspWidthOnLeaf]);
      if SizeNoLimit then begin
        if IdStrObjText then AutoSize(true);
        FreeAndNil(IdStr);
      end
      else begin
        if Assigned(IdStr) then
          if IdStr.Count>0 then begin
            AutoSize(true); IdStrObjText;
            i:=0;
            while i<IdStr.Count do with IdStr.GetObj(i)^ do
              if lNewPg then begin
                lNewPg:=false; Inc(i);
              end
              else IdStr.Delete(i);
            if i=0 then FreeAndNil(IdStr);
          end;
        // Для объектов с разбиваемым текстом, попадающих на 2 части страницы (osLong)
        i:=FFillObj.Count; SetLength(aLongObj,i); fl:=true;
        for i:=0 to i-1 do with aLongObj[i] do begin
          pv:=FFillObj[i]; isALine:=ALine(pv^);
          if isALine then if fl then begin
            fl:=false; AutoSize;
          end;
          SetTmpStr(pv^); LsFont0ToArr(af);
          if isALine or IsFont0 then txt:=TmpStr.Text else txt:='';
        end;
        // Определение объектов открывающих и закрывающих колонок
        j:=GFMaxWord; k:=0; 
        try
          i:=ObjectCount; SetLength(aHead,i); lHEad:=0;
          for i:=0 to i-1 do begin
            pv:=PObjects[i];
            if ColHead.IndexOf(pv.Col)>=0 then begin
              pv.State:=osHead; aHead[lHead]:=pv; Inc(lHead);
            end
            else if ColFoot.IndexOf(pv.Col)>=0 then begin
              pv.State:=osFoot;
              if not PinRight(pv.Pin) then begin
                MinSelf(j,pv.Left); MaxSelf(k,pv.Right);
              end;
            end;
          end;
          if k=0 then wf:=0 else wf:=GridX[k]-GridX[j];
          // Разбивка по малым страницам
          FPgSmall:=1; isObj:=true; w:=Width-FSpot.Right-LineWidth;
          // Не разбивать по ширине
          if mnBreakExec(false,GridX[high(FGridX)]-w) then w:=GridX[high(FGridX)];
          // Не разбивать по высоте
          if mnBreakVert then mnBreakExec(true,GridY[high(FGridY)]-Height+FSpot.Bottom+LineWidth([gfwY]));
          while (GridX[high(FGridX)]>w) and isObj do begin
            wold:=GridX[high(FGridX)];
            if lHead=0 then MarginLeft:=1
            else begin
              MarginLeft:=high(FGridX);
              for i:=0 to lHead-1 do MinSelf(MarginLeft,PGFObj(aHead[i]).Right);
              while MarginLeft<=high(FGridX) do begin
                fl:=true;
                for i:=0 to lHead-1 do if aHead[i].Right=MarginLeft then begin
                  fl:=false; break;
                end;
                if fl and (GridX[MarginLeft-1]<GridX[MarginLeft])
                then break else Inc(MarginLeft);
              end;
            end;
            SetLength(anpg,high(FGridX)+1); TrueMemory(@anpg[0],high(FGridX)+1);
            for i:=0 to ObjectCount-1 do begin
              pv:=PObjects[i];
              if Pos(GFMacroCod(gfmcNOPART),pv.Text)>0 then begin
                j:=pv.Right-1-pv.Left;
                if j>0 then ZeroMemory(@anpg[pv.Left+1],j*SizeOf(anpg[0]));
              end;
            end;
            MarginRight:=0;
            for i:=high(FGridX) downto MarginLeft do
              if anpg[i] and (GridX[i]<=w-wf) then begin
                MarginRight:=i; break;
              end;
            MaxSelf(MarginRight,MarginLeft);
            while (MarginRight<=high(FGridX)) and (MarginRight<>MarginLeft)
              and (GridX[MarginRight]=GridX[MarginLeft]) do Inc(MarginRight);
            CrdMargin:=GridX[MarginRight];
            for i:=0 to ObjectCount-1 do begin
              pv:=PObjects[i];
              if pv.State in [osHead,osFoot,osSave,osSpace] then continue;
              if pv.Only1 then pv.State:=TGFObjState(IfThen(FPgSmall=1,byte(osShow),byte(osHide)))
              else begin
                pv.State:=osShow;
                if LsPart1[gfpFirstPartPg].IndexOf(pv.Part)<0 then
                  if pv.Left>=MarginRight then pv.State:=osHide
                  else if pv.Right>MarginRight then pv.State:=osLong;
              end;
            end;
            AutoSizeX(0,[gfszxCalcRate]);
            isObj:=SavePage([gfsvFromNewPage]); Inc(FPgSmall);
            AutoSizeX(0);
            if {IsTextMode and} (GridX[high(FGridX)]=wold) or (GridX[0]>=w) then break;
          end;
        finally
          aLongObj:=nil;
        end;
      end;
    end;
    if isObj then SavePage([gfsvFromNewPage]);
    Inc(FPage);
  end;
  DelStack;
end;

procedure IdStrDel(p: PGFIdStr; n: longint);
var i: longint;
begin
  AddStack('GenForm.IdStrDel');
  for i:=n+1 to high(p.a) do p.a[i-1]:=p.a[i];
  SetLength(p.a,Length(p.a)-1);
  DelStack;
end;

procedure InsStr(var s: string; var n: longint; const si: string);
var li: longint;
begin
  AddStack('GenForm.InsStr');
  li:=Length(si); DecLen(s,-li); CopyMemory(pointer(longint(pointer(s))+n-1),pointer(si),li); Inc(n,li);
  DelStack;
end;

function TGenForm.IdStrObjText;
var p: PGFIdStr;
	function IdStrPart(j,h: longint): longint;
  var i,n: longint;
    af: TFontIndexSave;
    s: string;
    nf: byte;
    algn: TAlignment;
    fl: boolean;
  begin
    AddStack('TGenForm.IdStrObjText.IdStrPart',Self);
    with p.a[j],pv^ do begin
      if not IsFont0 then FOtherCanvas.Font.Assign(Fonts[Font].Font);
      if p.s='' then begin
        if EmpNoFill then begin
          LnTop:=0; LnBottom:=0; LnLeft:=0; LnRight:=0;
        end;
      end
      else begin
        if IsFont0 then begin
          n:=0;
          for i:=1 to Length(p.s) do begin
            FOtherCanvas.Font.Assign(LsFont0.GetFont(i-1)); MaxSelf(n,FOtherCanvas.TextHeight(p.s[i]));
          end;
        end
        else n:=FOtherCanvas.TextHeight(p.s);
        n:=ceil(n*aUnRate[true]);
        if h>0 then MaxSelf(h,n);
        if MinStr>0 then MaxSelf(h,n*MinStr);
      end;
      LsFont0ToArr(af);
      Text:=astolin(FOtherCanvas,p.s,GridObj(pv^,false){-2},h,PrcSpMin(pv^),@result,
        aUnRate[false],aUnRate[true],TFontIndexList(IfThen(IsFont0,lsFont0)));
      if IsFont0 then begin
        i:=Length(Text); SetLength(s,i); nf:=nFont0; algn:=taLeftJustify; fl:=false; n:=1;
        for i:=0 to i-1 do begin
          if not((LsFont0[i]=nf) and (TAlignment(LsFont0.Objects[i])=algn)) then begin
            nf:=LsFont0[i]; algn:=TAlignment(LsFont0.Objects[i]);
            if fl then InsStr(s,n,GFMacroCod(gfmcEND));
            fl := nf<>nFont0;
            if fl then InsStr(s,n,Format('%s%d.%d%s',[GFMacroCod(gfmcFONT),nf,byte(algn),GFMacroCod(gfmcEND)]));
          end;
          s[n]:=Text[i+1]; Inc(n);
        end;
        if fl then InsStr(s,n,GFMacroCod(gfmcEND));
        Text:=s;
        i:=Length(af); LsFont0.Clear; LsFont0.Capacity:=i;
        for i:=0 to i-1 do with af[i] do LsFont0.Add(n,o);
      end;
    end;
    DelStack;
  end;
	procedure psIdStrPart(j,h: longint);
  var i,l: longint;
  begin
    AddStack('TGenForm.IdStrObjText.psIdStrPart',Self);
    i:=IdStrPart(j,h); l:=Length(p.s);
    while i<=l do if p.s[i]>' ' then break else Inc(i);
    CopySelf(p.s,i);
    if IsFont0 then for i:=1 to i-1 do LsFont0.Delete(0);
    DelStack;
  end;
var a: TArrStr;
  ops,s: string;
  i,j,k,l,n,n1,nf,w,wf,hf,hf1: longint;
  fl: boolean;
begin
  AddStack('TGenForm.IdStrObjText',Self);
  if Assigned(IdStr) then begin
    i:=0;
    while i<IdStr.Count do begin
      p:=IdStr.GetObj(i);
      if not p.lNewPg then begin
        j:=0;
        while j<Length(p.a) do
          if Assigned(p.a[j].pv) then Inc(j)
          else begin
            IdStrDel(p,j);
            if p.nMax>=j then Dec(p.nMax);
          end;
        if j=0 then begin
          IdStr.Delete(i); continue;
        end;
      end;
      Inc(i);
    end;
    result := IdStr.Count>0;
    if result then begin
      l:=0; // Variable might not have been initialized
      for i:=0 to IdStr.Count-1 do begin
        p:=IdStr.GetObj(i);
        if not p.lNewPg then begin
          ops:=p.s; DelTrimSelf(p.s); Str2Fon0(p.s,p.a[0].pv.Font,false);
          if p.nMax<0 then p.nMax:=high(p.a);
          for j:=low(p.a) to p.nMax-1 do psIdStrPart(j,GridObj(p.a[j].pv^,true)+1);
          if p.nMax<high(p.a) then begin
            l:=LsArrDynamic(p.s,a,' '); k:=high(p.a); w:=l-1;
            if not IsFont0 then FOtherCanvas.Font.Assign(Fonts[p.a[k].pv.Font].Font);
            hf:=0; wf:=0;
            for j:=l-1 downto 0 do begin
              if IsFont0 then begin
                nf:=Length(ArrayAsList(a,' ',j));
                if j<w then begin
                  FOtherCanvas.Font.Assign(LsFont0.GetFont(nf-1)); Inc(wf,TxtWidthOther(' '));
                end;
                for n1:=1 to Length(a[j]) do begin
                  FOtherCanvas.Font.Assign(LsFont0.GetFont(nf)); Inc(nf); Inc(wf,TxtWidthOther(a[j][n1]));
                end;
              end
              else wf:=TxtWidthOther(ArrayAsList(a,' ',w-j+1,false,j));
              if wf>GridObj(p.a[k].pv^,false) then begin
                if IsFont0 then begin
                  nf:=Length(ArrayAsList(a,' ',j+1)); hf1:=0;
                  for n:=j+1 to w do begin
                    for n1:=1 to Length(a[n]) do begin
                      FOtherCanvas.Font.Assign(LsFont0.GetFont(nf)); Inc(nf); MaxSelf(hf1,TxtHeightOther);
                    end;
                    if n<w then begin
                      FOtherCanvas.Font.Assign(LsFont0.GetFont(nf)); Inc(nf); MaxSelf(hf1,TxtHeightOther);
                    end;
                  end;
                end
                else hf1:=TxtHeightOther;
                Inc(hf,hf1);
                if hf>GridObj(p.a[k].pv^,true)+1 then begin
                  Dec(k);
                  if k=p.nMax then break;
                  if not IsFont0 then FOtherCanvas.Font.Assign(Fonts[p.a[k].pv.Font].Font);
                  hf:=0;
                end;
                SetLength(p.s,max(0,Length(p.s)-Length(ArrayAsList(a,' ',w-j,false,j+1))-1));
                w:=j;
              end;
            end;
            if k>p.nMax then begin
              if IsFont0 then begin
                wf:=0;
                for n1:=1 to Length(p.s) do begin
                  FOtherCanvas.Font.Assign(LsFont0.GetFont(n1-1)); Inc(wf,TxtWidthOther(p.s[n1]));
                end;
              end
              else wf:=TxtWidthOther(p.s);
              if wf<=GridObj(p.a[k].pv^,false) then
                if hf<=GridObj(p.a[k].pv^,true)+1 then p.s:='';
            end;
          end;
          if p.nMax<Length(p.a) then IdStrPart(p.nMax,0);
          if p.nMax<high(p.a) then begin
            n:=Length(p.s); p.s:=Copy(ArrayAsList(a,' ',l),n+1,MaxInt);
            if IsFont0 then for n:=1 to n do LsFont0.Delete(0);
            for j:=p.nMax+1 to high(p.a) do psIdStrPart(j,GridObj(p.a[j].pv^,true)+1);
          end;
          if ALine(p.a[0].pv^) then begin
            s:=sGFIdEndStr;
            for j:=high(p.a) downto 0 do with p.a[j].pv^ do begin
              fl := Text<>''; IncL(Text,s);
              if fl then s:=sGFIdStr;
            end;
          end;
          p.s:=ops;
        end;
      end;
    end;
  end
  else result:=false;
  DelStack;
end;

procedure TGenForm.LsFont0ToArr;
var i: longint;
begin
  AddStack('TGenForm.LsFont0ToArr',Self);
  if IsFont0 then begin
    i:=LsFont0.Count; SetLength(af,i);
    for i:=0 to i-1 do with af[i] do begin
      n:=LsFont0[i]; o:=LsFont0.Objects[i];
    end;
  end
  else af:=nil;
  DelStack;
end;

function TGenForm.mnBreakExec;
var s: string;
	r: TRect;
  NoLim: boolean;
  brkKey: longint;
begin
  AddStack('TGenForm.mnBreakExec',Self);
  noLim:=SizeNoLimit; result := (not(lVert in Params.Arr[FCurParams].aBreak) or NoLim) and (wGreat>0);
  if result and not noLim then
    if MsgBreak then begin
      MsgBreak:=false; s:=Format('%d мм',[Ceil(wGreat/aRate[lVert])]);
      with TDefMenu.Create(Application.MainForm) do
        try
          InsertKey(K_F10,'Продолжить формирование, игнорируя ошибку');
          InsertKey(K_F3,'Уменьшить размеры шрифтов и повторить формирование');
          InsertKey(K_Esc,'Прервать формирование и настроить параметры формы вручную');
          with FParams.Arr[FCurParams] do begin
            r:=GFCalcSpotPrn(NFormat,Orientation);
            if lVert then InsertKey(K_F3,K_F2,
              'Уменьшить отступы сверху и снизу до минимальных и повторить формирование','',
              IfThen((SpotMm.Top>r.Top) or (SpotMm.Bottom>r.Bottom),rmkVisible))
            else InsertKey(K_F3,K_F2,
              'Уменьшить отступы слева и справа до минимальных и повторить формирование','',
              IfThen((SpotMm.Left>r.Left) or (SpotMm.Right>r.Right),rmkVisible));
          end;
          FrmCaption:=IfThen(lVert,'Высота','Ширина')
            +Format(' страницы %d превышает допустимую на ',[FPage])+s;
          brkKey:=K_F10;
          if not Execute(@brkKey) then brkKey:=K_Esc;
        finally
          Free;
        end;
      if brkKey<>K_F10 then raise EDcmBreakError.CreateErr(lVert,brkKey);
    end;
  DelStack;
end;

// Сохранить страницу
function TGenForm.SavePage;
var i: longint;
	p: PPages;
  pv: PGFObj;
  s: string;
begin
	AddStack('TGenForm.SavePage',Self);
  if (gfsvFromNewPage in Opt) and Assigned(ProcBeforeNewPage) then ProcBeforeNewPage(Self);
	result:=false;
  if not(gfsvEdit in Opt) then begin
  	if FState=gsView then p:=PageNew else p:=@FPages[FLeaf-1];
    p.sv.OffSet:=SvCount; p.sv.Modified:=false;
    if FState=gsView then begin
    	p.sv.PgLong:=FPage; p.sv.PgSmall:=FPgSmall; p.sv.Text:=FCurPageName; p.av:=nil;
      if lCurPagePart>0 then begin
        if not empty(p.sv.Text) then IncD(p.sv.Text,': ');
        if MyVarType(CurPageFirst)=varBoolean then begin
          s:=aCurPagePart[0];
          if not CurPageFirst and (lCurPagePart>1)
          then IncD(s,' - '+aCurPagePart[lCurPagePart-1]);
        end
        else s:=ArrayAsList(aCurPagePart,CurPageFirst,lCurPagePart);
        IncD(p.sv.Text,s);
      end;
    end;
    TrimRightSelf(p.sv.Text);
    p.sv.ColCount:=high(FGridX); p.sv.RowCount:=high(FGridY); p.sv.ObjCount:=FFillObj.Count;
    if FState=gsView then begin
      p.sv.WidthMm:=nround((GridX[high(FGridX)]-GridX[0])/aRate[false]);
      p.sv.HeightMm:=nround((GridY[high(FGridY)]-GridY[0])/aRate[true]);
      p.sv.CurParams:=FCurParams;
    end;
  end;
  if FState=gsView then begin
    for i:=0 to high(FGridX) do SaveVal(GridX[i]*aRate[false],stReal);
    for i:=0 to high(FGridY) do SaveVal(GridY[i]*aRate[true],stReal);
  end;
  // Объекты
  for i:=0 to FFillObj.Count-1 do begin
    pv:=FFillObj[i]; SaveObj(pv,i,not(gfsvEdit in Opt));
    if FState=gsView then if pv.State=osShow then result:=true;
	end;
  Inc(FLeaf);
  DelStack;
end;

procedure TGenForm.SaveObj;
var j,k,w,pl: longint;
  al: TArrStr;
  function TxtNoLimit: boolean;
  var n,w1: longint;
  begin
    AddStack('TGenForm.SaveObj.TxtNoLimit',Self);
    with aLongObj[i] do
      if Length(af)=0
      then w1:=TxtWidthUn(LeftStr(al[j],k))
      else begin
        w1:=0;
        for n:=1 to k do begin
          CurCanvas.Font.Assign(Fonts[af[pl+n].n].Font); FOtherCanvas.Font.Assign(CurCanvas.Font);
          Inc(w1,TxtWidthUn(al[j][n]));
        end;
      end;
    result := w1>w;
    DelStack;
  end;
var s: string;
  v: TGFObj;
  ar: TArrStr;
  afr: TFontIndexSave;
  pi: PGFIdent;
  n,k1,l,lf,l1,nfr: longint;
  nf: byte;
  algn: TAlignment;
  fl: boolean;
begin
  AddStack('TGenForm.SaveObj',Self);
  w:=0; // Variable might not have been initialized
  v:=pv^;
  SaveVal(v.Left,stWord); SaveVal(v.Top,stWord);
  SaveVal(v.Right,stWord); SaveVal(v.Bottom,stWord);
  SaveVal(v.LnLeft,stByte); SaveVal(v.LnTop,stByte);
  SaveVal(v.LnRight,stByte); SaveVal(v.LnBottom,stByte);
  if (FState=gsView) and noEdit then begin
    if v.State=osLong then w:=max(0,GridObj(v,false));
    // Открывающие
    if (v.State in [osHead,osFoot]) and (v.VOut=voBeg)
      then pv.Text:='';
    // Невидимые объекты
    if v.State in [osHide,osSave] then begin
      // Тексты
      if v.TypeObj=toText then begin
        if not v.MMetr then begin
          TmpStr.Text:=v.Text; v.MinHeight:=TmpStr.Count;
        end;
      end
      // Рисунки
      else begin
        if v.MinHeight=0
        then v.MinHeight:=nround(bmSize(v).cY/aRate[true]);
        v.TypeObj:=toText; v.MMetr:=true; v.MinWidth:=0;
      end;
      v.Text:='';
    end
    // Тексты
    else if v.TypeObj=toText then begin
      // Макроподстановки
      DelMacro(v,[gfmcDefault,gfmcCtrl]);
      // Разделить текст длинного объекта
      if v.State=osLong then with aLongObj[i] do begin
        l:=LsArrDynamic(IfThen(txt='',v.Text,txt),al,CRLF); SetLength(ar,l); lf:=Length(af); nfr:=0;
        if lf=0 then begin
          CurCanvas.Font.Assign(Fonts[v.Font].Font); FOtherCanvas.Font.Assign(CurCanvas.Font);
        end
        else begin
          pl:=-1; SetLength(afr,lf);
        end;
        for j:=0 to l-1 do begin
          l1:=Length(al[j]); k:=l1;
          while TxtNoLimit do k:=max(0,RPos(' ',LeftStr(al[j],k))-1);
          if v.VOut=voBeg then begin
            k1:=k+1;
            while k1<=l1 do if al[j][k1]=' ' then Inc(k1) else break;
            ar[j]:=Copy(al[j],k1,MaxInt);
            if lf>0 then for k1:=pl+k1-1 to pl+l1+IfThen(j<l-1,lCRLF)-1 do begin
              afr[nfr]:=af[k1]; Inc(nfr);
            end;
          end;
          if v.VOut<>voEnd then
            if lf=0 then SetLength(al[j],k)
            else begin
              SetLength(s,k); nf:=v.Font; algn:=taLeftJustify; fl:=false; n:=1;
              for k:=1 to k do begin
                if not((af[pl+k].n=nf) and (TAlignment(af[pl+k].o)=algn)) then begin
                  nf:=af[pl+k].n; algn:=TAlignment(af[pl+k].o);
                  if fl then InsStr(s,n,GFMacroCod(gfmcEND));
                  fl := nf<>v.Font;
                  if fl then InsStr(s,n,Format('%s%d.%d%s',[GFMacroCod(gfmcFONT),nf,byte(algn),GFMacroCod(gfmcEND)]));
                end;
                s[n]:=al[j][k]; Inc(n);
              end;
              if fl then InsStr(s,n,GFMacroCod(gfmcEND));
              al[j]:=s;
            end;
          Inc(pl,l1+lCRLF);
        end;
        if v.VOut=voEnd then v.Text:='' else v.Text:=ArrayAsList(al,CRLF,l);
        if v.VOut=voBeg then begin
          s:=ArrayAsList(ar,CRLF,l);
          if txt<>'' then txt:=s;
          pv.Text:=s;
          SetLength(af,nfr);
          for nfr:=0 to nfr-1 do af[nfr]:=afr[nfr];
        end;
      end;
    end
    // Рисунки
    else if v.State=osLong then begin
      v.State:=osShow; k:=GetMinWidth(v); v.State:=osLong;
      if k>w then v.Text:='';
      if (v.VOut=voBeg) and (k<=w) then pv.Text:='';
    end;
  end;
  SaveVal(v.TypeObj,stByte);
  if not((FState=gsView) and (v.TypeObj in [toCalc,toCalcBmp])) then SaveStr(v.Text);
  SaveVal(v.Alignment,stByte);
  SaveVal(v.MinWidth,stWord); SaveVal(v.MinHeight,stWord);
  SaveVal(v.Pin,stByte); SaveVal(v.Color,stByte);
  SaveVal(v.Font,stByte);
  if FState=gsView then SaveVal(v.State,stByte);
  SaveStr(v.Ident);
  if FState=gsView then begin
    if not((v.Ident='') or (v.TypeObj in [toCalc,toCalcBmp]) or (v.State in [osHide,osSave,osSpace])) then begin
      if IgnoreSLFindAdd(LsIdent,v.Ident,k) then pi:=Idents(k)
      else begin
        pi:=IdentNew(k); pi.Calc:=false; pi.lsZero:=false; pi.Bmp := v.TypeObj=toCalcBmp;
      end;
      pi.Leaf:=FLeaf; pi.Value:=v.Text;
    end;
    case v.State of
      osShow: pv.State:=osSave;
      osHide,osLong: pv.State:=osShow;
    end;
    SaveVal(v.Part='',stBoolean); 
  end
  else begin
    SaveStr(v.Part); SaveStr(v.Col);
  end;
  SaveVal(v.MMetr,stBoolean); SaveVal(v.VOut,stByte); SaveVal(v.Only1,stBoolean);
  DelStack;
end;

procedure TGenForm.DelMacro;
var m: TGFMacro;
  s: string;
begin
  AddStack('TGenForm.DelMacro',Self);
  if Pos(GFChrMac,v.Text)>0 then
    for m:=low(aGFMacro) to high(aGFMacro) do with aGFMacro[m] do if tp in Types then begin
      case m of
        gfmcLEAF: s:=IntToStr(FLeaf-BlockLeafBeg);
        gfmcPAGE: s:=IntToStr(FPage);
        gfmcPART: s:=IntToStr(FPgSmall);
      else s:='';
      end;
      s:=StrTran(v.Text,GFMacroCod(m),s);
      if v.Text<>s then begin
        with Params.Arr[FCurParams] do if StdFormat then if NFormat=frmNoLim then if HideNoLim then begin
          v.Text:=''; break;
        end;
        v.Text:=s;
      end;
    end;
  DelStack;
end;

procedure StCopyWithAutosize(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var fFrom,fTo: TCustomBuf;
	i: longint;
begin
  AddStack('GenForm.StCopyWithAutosize');
  fFrom:=PointerVar(Params[1]); fTo:=PointerVar(Params[2]);
  with TGenForm(LongInt(Params[0])) do for i:=1 to PageCount do begin
    if Sender.SayStat('',Format('Страница: %d из %d',[i,PageCount]),i/PageCount) then break;
    if i>1 then begin
      FBuf:=fFrom; RestPage(i,false);
    end;
    FBuf:=fTo;
    with FPages[FLeaf-1].sv do begin
      OffSet:=SvCount; Modified:=false;
      ColCount:=high(FGridX); RowCount:=high(FGridY); ObjCount:=FFillObj.Count;
    end;
    SavePage([gfsvEdit]);
  end;
  DelStack;
end;

procedure TGenForm.CopyWithAutosize;
var fFrom,fTo: TCustomBuf;
  oVers: byte;
  oFile: string;
begin
  AddStack('TGenForm.CopyWithAutosize',Self);
  oFile:=FileName; Open(FileFrom,1); AutoSize; fFrom:=FBuf;
  fTo:=TFileBuf.Create(FileTo,true); FBuf:=fTo; oVers:=VersInfo.Vers;
  SaveVers; VersInfo.Vers:=oVers;
  ShowStat('Преобразование документа',StCopyWithAutosize,
    [LongInt(Self),LongInt(fFrom),LongInt(fTo)],PageCount);
  SavePages([gfsvsEdit]); TFileBuf(fTo).Update(true);
  CloseDtg; FBuf:=fFrom; CloseDtg; FileName:=oFile;
  DelStack;
end;

function TGenForm.ObjSpace;
var j,l: longint;
	v: TGFObj;
  fl: boolean;
  a: TArrStr;
  procedure AddObj1;
  var i,k: longint;
  begin
    AddStack('TGenForm.ObjSpace.AddObj1',Self);
    if fl then begin
    	v.Right:=j-1; result:=true; fl:=false;
      for i:=v.Top to high(a) do
      	if empty(copy(a[i],v.Left+1,v.Right-v.Left)) then begin
        	for k:=v.Left+1 to v.Right do SetByte(a[i],k,true);
          v.Bottom:=i+1;
        end
        else break;
      //v.Bottom:=v.Top+1;
    	if Assigned(ares) then begin
      	if l=Length(ares^) then SetLength(ares^,l+10);
        ares^[l]:=Rect(v.Left,v.Top,v.Right,v.Bottom); Inc(l);
      end
      else begin
        v.Selected:=gfspSel in Opt; AddObj(v);
      end;
    end;
    DelStack;
  end;
var i,k: longint;
	pv: PGFObj;
begin
  AddStack('TGenForm.ObjSpace',Self);
  if Assigned(ares) then ares^:=nil
  else if not(gfspNoAutoSize in Opt) then AutoSize(gfspWidthOnLeaf in Opt);
  // Заполнение пустот
  l:=0; result:=false; InitArrLen(a,high(FGridY)); i:=FFillObj.Count-1;
  while i>=0 do begin
    pv:=FFillObj[i]; fl:=false;
    for j:=pv.Top to pv.Bottom-1 do begin
      for k:=pv.Left+1 to pv.Right do
        if GetByte(a[j],k) then begin
          fl:=true; break;
        end;
      if fl then break;
    end;
    if fl then begin
      j:=FObjects.IndexOf(pv);
      if j>=0 then FObjects.Delete(j);
      j:=FSelObjects.IndexOf(pv);
      if j>=0 then FSelObjects.Delete(j);
      Dispose(pv); FFillObj.Delete(i);
    end
    else for j:=pv.Top to pv.Bottom-1 do
      for k:=pv.Left+1 to pv.Right do SetByte(a[j],k,true);
    Dec(i);
  end;
  GFObjDef(v); v.State:=osSpace; v.Pin:=Pin;
  for i:=low(a) to high(a) do begin
    fl:=false; v.Top:=i; j:=1;
    while j<=high(FGridX) do begin
      if GetByte(a[i],j) then AddObj1
      else if not fl then begin
        v.Left:=j-1; fl:=true;
      end;
      Inc(j);
    end;
    AddObj1;
  end;
  if result then
  	if Assigned(ares) then SetLength(ares^,l)
    else if not(gfspNoAutoSize in Opt) then AutoSize(gfspWidthOnLeaf in Opt);
  DelStack;
end;

// Сохранить отредактированный лист
procedure TGenForm.SaveEditLeaf;
begin
	AddStack('TGenForm.SaveEditLeaf',Self);
	mess_wait([StrNum('Сохранение страницы ',Leaf)],SaveEdit,[false,nLeaf],false);
  DelStack;
end;

// Сохранить с изменёнными параметрами без формирования
procedure TGenForm.SaveEditPrm;
begin
  AddStack('TGenForm.SaveEditPrm',Self);
  mess_wait(['Сохранение документа'],SaveEdit,[true],false);
  DelStack;
end;

function CopyFileMsg(const f1,f2: TFileName): boolean;
begin
  AddStack('GenForm.CopyFileMsg');
  result:=CopyFileOpt(f1,f2);
  if not result then MsgDlg(['Ошибка сохранения документа.',
    'Возможно, у файла предыдущей версии документа установлены атрибуты,',
    'на снятие которых у Вас отсутствуют права.']);
  DelStack;
end;

procedure TGenForm.SaveEdit;
	function SizePages: longint;
  begin
    AddStack('TGenForm.SaveEdit.SizePages',Self);
    result:=2*SizeOfVar[stInteger]+PageCount*(SizeOf(TPageSave)-1);
    DelStack;
  end;
var f: TFileBuf;
  procedure MoveChar;
  var c: Char;
  begin
    AddStack('TGenForm.SaveEdit.MoveChar',Self);
    if f.ReadChar(c) then SaveVal(Ord(c),stByte);
    DelStack;
  end;
var fn1,fn2: TFileName;
	l,i,j,n,sz: longint;
  p: PPages;
begin
	AddStack('TGenForm.SaveEdit',Self);
  l:=Leaf; CloseDtg;
  fn1:=FullNameExe(TmpFile,'DTG'); DelFileAtr(fn1);
  fn2:=FullNameExe(FFileName,'DTG');
  FBuf:=TFileBuf.Create(fn1,true);
  f:=TFileBuf.Create(fn2);
  try
  	if Sender.Params[0] then
    	for i:=0 to PageCount-1 do FPages[i].sv.Modified:=true;
    sz:=f.Size; SvCount:=0; SvSum:=0; p:=@FPages[l-1]; p.sv.Modified:=false;
    if Sender.Params[0] then begin
    	SaveVers; f.Seek(FBuf.Position,soFromBeginning);
    end;
    for i:=FBuf.Position+1 to p.sv.Offset do MoveChar;
    n:=SvCount; SavePage([gfsvEdit]);
    if l<PageCount then begin
      j:=FPages[l].sv.OffSet; n:=SvCount-n-j+p.sv.Offset;
      for i:=l to PageCount-1 do Inc(FPages[i].sv.Offset,n);
      f.Seek(j,soFromBeginning);
      for i:=j to sz-SizePages-1 do MoveChar;
    end;
    SavePages([gfsvsEdit]);
    TFileBuf(FBuf).Update(true);
  finally
    f.Free; CloseDtg;
  end;
  if not Sender.Params[0] then l:=Sender.Params[1];
  if CopyFileMsg(fn1,fn2) then Open(FFileName,l);
  DelStack;
end;

// Сохранить одну переменную
procedure TGenForm.SaveVal;
var sr: TSaveRec;
	Count,i: byte;
begin
	AddStack('TGenForm.SaveVal',Self);
	Count:=FBuf.Write(Value,tp); VarToSvRec(Value,tp,sr);
  // Формирование контрольной суммы
  for i:=1 to Count do Inc(SvSum,Byte(sr.s[i]));
  Inc(SvCount,Count);
  DelStack;
end;

// Сохранить строку
function TGenForm.SaveStr;
begin
	AddStack('TGenForm.SaveStr',Self);
	result:=Length(s); SaveVal(result,stInteger); SaveFixStr(s,result);
  DelStack;
end;

// Сохранить строку фиксированной длины
procedure TGenForm.SaveFixStr;
var i: longint;
	s: string;
begin
	AddStack('TGenForm.SaveFixStr',Self);
	s:=Padr(st,ln);
  for i:=1 to ln do SaveVal(Byte(s[i]),stByte);
  DelStack;
end;

function MustLoadFromDB(const fn: TFileName; NumSave: longword; const ChkSum: variant): boolean;
var inf: TGFVersInfo;
begin
  AddStack('GenForm.MustLoadFromDB');
  ReadVers(inf,nil,fn,gbrNumSave); result := NumSave>inf.NumSave;
  if IsChkSum then
    if ChkSum<>0 then result := ChkSum<>inf.ChkSum;
  DelStack;
end;

// Открыть файл .DCM
procedure TGenForm.OpenDcm;
var n: longint;
  fn: TFileName;
begin
	AddStack('TGenForm.OpenDcm',Self);
  if lCompDB then
  	if Assigned(lsDcm) then begin
    	if IntObjFind(lsDcm,FileNameExt(AFileName,'DCM'),n) and DBDcm.ActiveNoNil then begin
        fn:=FullNameExe(AFileName,'DCM');
        with lsDcm.aInf[n] do
          if MustLoadFromDB(fn,NumSave,ChkSum) then SetStrFile(fn,lsDcm.lsm.GetValue(MemDcm));
      end;
    end
    else LoadFromServer(AFileName);
  InitArr(awDat); InitArr(awWin); StrAlg:=''; DopAlg:=''; DopAlgName:=''; MouseAlg:=''; Open(AFileName,nLeaf);
  DelStack;
end;

procedure TGenForm.OpenDcmStr;
begin
	AddStack('TGenForm.OpenDcmStr',Self);
  FBuf:=TStrBuf.CreateRead(StrDeShifr(DcmDef));
  try
    OpenDcm('',false);
  finally
    CloseDtg;
  end;
  DelStack;
end;

function TGenForm.SaveDcmStr;
begin
	AddStack('TGenForm.SaveDcmStr',Self);
  FBuf:=TStrBuf.CreateWrite(@result);
  try
    FSaveDcm;
  finally
    CloseDtg;
  end;
  StrShifrSelf(result);
  DelStack;
end;

class function TGenForm.LoadFromServer;
var fn: TFileName;
  ar: TArrRecDB;
  q: TMulQuery;
begin
  AddStack('TGenForm.LoadFromServer');
  result:=false;
  if DBDcm.ActiveNoNil then begin
    q:=TMulQuery.CreateConnection;
    try
      q.PartSelect(tDCM,['NUMSAVE',IfThen(DBDcm.IsField('CHKSUM'),'CHKSUM','0'),'MEM_DCM'],
        tDCM+'.'+fDCM+'='+QQs(AnsiUpperCase(FileNameExt(FileName,'DCM'))));
      if q.IsRecords then begin
        fn:=FullNameExe(FileName,'DCM');
        if not lAll then lAll:=MustLoadFromDB(fn,q.Fields[0].AsInteger,q.Fields[1].AsInteger);
        if lAll then begin
          CopyFromRecDB(ar,[DBDcm]); // Ambiguous overloaded call to 'Create'
          SetStrFile(fn,TMemGKList.Create(ar,q).GetValue(q.Fields[2].AsInteger)); result:=true;
        end;
      end;
    finally
      q.Free;
    end;
  end;
  DelStack;
end;

// Восстановить форму из файла
procedure TGenForm.Open;
const GFMaxPgText = 30;	// Макс.длина названия страницы
var i,i1,m,cnt: longint;
  p: PPages;
  sCod,sName,sBmp: string;
  lFile,fl,CanLoad: boolean;
  fn: TFileName;
  s: string;
	w: TGFWinList;
  pi: PGFIdent;
  tp: TSaveType;
begin
	AddStack('TGenForm.Open',Self);
  lFile := AFileName<>''; FFileName:=AFileName;
  fn:=IfThen(lFile,FullNameExe(FFileName,IfThen(FState=gsDesign,'DCM','DTG')));
  CanLoad := (FState=gsDesign) and lFile;
  while true do begin
    if lFile then begin
      CloseDtg; FBuf:=TFileBuf.Create(fn);
    end;
    if FileBufActive then begin
      // Проверка контрольной суммы
      SvSum:=0; cnt:=FBuf.Seek(-SizeOfVar[stInteger],soFromEnd);
      if cnt>0 then begin
        FBuf.Seek(0,soFromBeginning); FBuf.ReadString(s,rdtoEof);
        for i:=1 to cnt do Inc(SvSum,byte(s[i]));
        FBuf.Seek(-SizeOfVar[stInteger],soFromEnd);
        fl := SvSum<>FBuf.Read(stInteger);
      end
      else fl:=true;
      if fl then begin
        CloseDtg;
        if CanLoad then CanLoad:=LoadFromServer(AFileName,true);
        if not CanLoad then
          if lFile then raise EDcmFormError.Create('Нарушено содержимое файла '+fn) else break;
        CanLoad:=false; continue;
      end;
    end
    else CloseDtg;
    break;
  end;
  CrdMargin:=-1; PageCount:=0; ClearFonts;
  VersInfo.Vers:=0; VersInfo.NumSave:=0; VersInfo.ChkSum:=0; lsBitMap.Clear;
  if Assigned(LsIdent) then LsIdent.Clear;
  if FState=gsView then LsBlockLeaf.Clear;
  if FileBufActive then begin
    FBuf.Seek(0,soFromBeginning);
    ReadVers(VersInfo,FBuf,'',iif(FState=gsDesign,gbrNone,gbrVers));
    // Общие параметры
    Params:=ReadParams(FBuf,VersInfo.Vers,InGet); SetSizeMm;
    // Шрифты
    if VersInfo.Vers>=1 then ReadFonts(FBuf,VersInfo.Vers,LsFont);
    // Алгоритм формирования
    if FState=gsDesign then begin
      StrAlg:=FBuf.ReadStr;
      if VersInfo.Vers<32 then begin
        DopAlg:=''; DopAlgName:=''; MouseAlg:=''; InitArr(awDat); InitArr(awWin);
        if VersInfo.Vers>=5 then begin
          awWin[gfwDat]:=FBuf.ReadStr; awDat[false]:=FBuf.ReadStr;
          if VersInfo.Vers>=14 then begin
            awWin[gfwPrm]:=FBuf.ReadStr; awDat[true]:=FBuf.ReadStr;
          end;
        end;
      end
      else begin
      	DopAlg:=FBuf.ReadStr;
        DopAlgName:=FBuf.ReadStr(VersInfo.Vers>=33);
        MouseAlg:=FBuf.ReadStr(VersInfo.Vers>=46);
        for fl:=false to true do awDat[fl]:=FBuf.ReadStr;
        for w:=low(awWin) to high(awWin) do awWin[w]:=FBuf.ReadStr;
      end;
    end;
    if VersInfo.Vers>=23 then begin
      cnt:=FBuf.Read(stByte);
      for i:=1 to cnt do begin
        sCod:=FBuf.ReadStr; sName:=FBuf.ReadStr; sBmp:=FBuf.ReadStr; lsBitMap.AddBM(sCod,sName,sBmp);
      end;
    end;
    // Страницы
    m:=-(IfThen(VersInfo.Vers<22,2,3)*SizeOfVar[stInteger]);
    FBuf.Seek(m,soFromEnd);
    if VersInfo.Vers>=22 then Dec(m,longint(FBuf.Read(stInteger)));
    cnt:=FBuf.Read(stInteger); i:=SizeOfVar[stInteger];
    if (FState=gsView) and (VersInfo.Vers>=2) then Inc(i,i shl 1);
    if (FState=gsView) or (VersInfo.Vers<2) or (VersInfo.Vers>=26)
    then Inc(i,longint(IfThen(VersInfo.Vers<22,GFMaxPgText,SizeOf(longint))));
    if (FState=gsView) and (VersInfo.Vers>=11)
    then Inc(i,IfThen(VersInfo.Vers<49,SizeOf(Word),SizeOf(longint)) shl 1);
    if VersInfo.Vers>=27 then begin
    	if FState=gsView then Inc(i,SizeOf(byte));
      Inc(i,SizeOf(Word)*2+IfThen(VersInfo.Vers<47,SizeOf(Word),SizeOf(longint)));
    end;
    if (VersInfo.Vers>=31) and (FState=gsView) then Inc(i,SizeOf(boolean));
    Dec(m,cnt*i);
    if (FState=gsView) and (VersInfo.Vers>=32) then begin
      FBuf.Seek(m-SizeOfVar[stInteger],soFromEnd); i:=FBuf.Position;
      FBuf.IncPosition(-FBuf.Read(stInteger)-SizeOfVar[stInteger]);
      if VersInfo.Vers>=48 then begin
        FBuf.IncPosition(-SizeOfVar[stInteger]); i1:=FBuf.Position;
        FBuf.IncPosition(-FBuf.Read(stInteger)-SizeOfVar[stInteger]);
        while FBuf.Position<i1 do begin
          s:=FBuf.ReadStr; LsBlockLeaf.AddObject(s,PointerVar(FBuf.Read(stInteger)));
        end;
        FBuf.IncPosition(SizeOfVar[stInteger]);
      end;
      while FBuf.Position<i do begin
        sCod:=FBuf.ReadStr; pi:=IdentNew(sCod);
        pi.Leaf:=FBuf.Read(stLongWord); pi.Value:=''; pi.Fml:='';
        pi.Edited:=false; pi.lsZero:=false;
        if VersInfo.Vers<34 then pi.Calc:=false
        else begin
          pi.Calc:=FBuf.Read(stBoolean); s:=FBuf.ReadStr;
          if pi.Calc then pi.Fml:=s else pi.Value:=s;
          if VersInfo.Vers>=35 then if pi.Calc then begin
            pi.Edited:=FBuf.Read(stBoolean);
            if pi.Edited then pi.Value:=FBuf.ReadStr;
            pi.Bmp:=FBuf.Read(VersInfo.Vers>=51,stBoolean,false);
          end;
        end;
      end;
    end;
    FBuf.Seek(m,soFromEnd); tp:=iif(VersInfo.Vers<49,stWord,stInteger);
    if Length(FPages)<cnt then SetLength(FPages,cnt);
    for i:=1 to cnt do begin
      p:=PageNew; p.sv.OffSet:=FBuf.Read(stInteger); p.sv.Modified:=false;
      if (FState=gsView) and (VersInfo.Vers>=2) then begin
        p.sv.PgLong:=FBuf.Read(stInteger);
        p.sv.PgSmall:=FBuf.Read(stInteger);
        if VersInfo.Vers>=31 then p.sv.Modified:=FBuf.Read(stBoolean);
      end
      else begin
        p.sv.PgLong:=i; p.sv.PgSmall:=1;
      end;
      if (FState=gsView) or (VersInfo.Vers<2) or (VersInfo.Vers>=26) then
        if VersInfo.Vers<22
        then p.sv.Text:=FBuf.ReadStr(GFMaxPgText)
        else p.sv.Text:=FBuf.ReadStr
      else p.sv.Text:='';
      if (FState=gsView) and (VersInfo.Vers>=11) then begin
        p.sv.WidthMm:=FBuf.Read(tp); p.sv.HeightMm:=FBuf.Read(tp);
        if VersInfo.Vers>=27 then p.sv.CurParams:=FBuf.Read(stByte);
      end
      else begin
        p.sv.WidthMm:=0; p.sv.HeightMm:=0;
      end;
      if VersInfo.Vers>=27 then begin
      	p.sv.ColCount:=FBuf.Read(stWord); p.sv.RowCount:=FBuf.Read(stWord);
        p.sv.ObjCount:=FBuf.Read(iif(VersInfo.Vers<47,stWord,stInteger));
      end;
      p.av:=nil;
    end;
  end;
  FontAddDef;
  if FState=gsDesign then begin
  	if PageCount=0 then PageAdd;
  	for i:=1 to PageCount do RestPage(i);
    Leaf:=nLeaf; CloseDtg;
  end
  else begin
  	Calculate; RestPage(nLeaf);
  end;
  AfterOpen;
  DelStack;
end;

procedure TGenForm.Calculate;
var	i,ost: longint;
	p: PGFIdent;
begin
  ost:=AddStack('TGenForm.Calculate',Self);
  IfThenNotify(FOnBeforeCalculate,Self); SetLength(aCalc,LsIdent.Count);
  try
    for i:=low(aCalc) to high(aCalc) do with aCalc[i] do begin
      Calculating:=false; p:=Idents(i); Calc := p.Calc and not p.Edited;
    end;
    try
      for i:=low(aCalc) to high(aCalc) do Calculate1(i);
    except
      on E:EInterAnyError do begin
      	SetStack(ost);
        if not empty(E.Message) then meserr(E.Message+'.');
      end;
    end;
  finally
	  aCalc:=nil;
  end;
  DelStack;
end;

procedure biFloat0(var stack: array of variant; n1: longint; var lStd: boolean);
var s: string;
begin
  AddStack('GenForm.biFloat0');
  s:=stack[n1];
  if Assigned(DcmIdentParams) then with DcmIdentParams.PrmNum do
    if ZeroEmp.l and (s=ZeroEmp.s) then s:=''
    else begin
      if DigIsDlm then StrTranSelf(s,DigDlm);
      StrTranSelf(s,FracDlm,DecimalSeparator);
    end;
  stack[n1]:=Float0(s);
  DelStack;
end;

procedure TGenForm.Calculate1;
var pi: PGFIdent;
	v: variant;
  oCurParams: byte;
  oCurGFObj: PGFObj;
  oLeaf,oPage,oCurGFObjParams: longint;
  oDcmIdentParams: PGFParamItem;
  oBuiltInProc: TBuiltInProc;
  oEvalCalc: boolean;
  s: string;
  a: TArrStr;
begin
  AddStack('TGenForm.Calculate1',Self);
  if InRange(i,low(aCalc),high(aCalc)) then with aCalc[i] do if Calc then begin
  	if Calculating then raise EInterAnyError.Create('Расчёт значения вызывает сам себя');
    Calculating:=true; pi:=Idents(i);
    if empty(pi.Fml) then pi.Value:=''
    else with aBuiltIn[MyTypes.biFloat0],aBuiltInProc[MyTypes.biFloat0] do begin
      oCurParams:=FCurParams; oCurGFObj:=CurGFObj; oCurGFObjParams:=CurGFObjParams; oLeaf:=FLeaf; oPage:=FPage;
      oDcmIdentParams:=DcmIdentParams; oBuiltInProc:=Proc;
      oEvalCalc:=EvalCalc;
      New(CurGFObj);
      try
        CurGFObj.Ident:=LsIdent[i];
        if InRange(pi.Leaf,1,PageCount) then with FPages[pi.Leaf-1].sv do begin
          FCurParams:=CurParams; FPage:=PgLong;
        end;
        CurGFObjParams:=FCurParams; FLeaf:=pi.Leaf; s:='Формула вычисляемого значения ('+CurGFObj.Ident+')';
        Proc:=biFloat0; EvalCalc:=true;
        if not EvalStringsChk(v,[true,false],pi.Fml,s) then raise EInterAnyError.Create('');
        if pi.Bmp then begin
          CopyFromVar(a,v); v:=ArrayAsList(a,cCalcBmp);
        end
        else if not GFFmtStr(v,Params,CurGFObjParams,@pi.lsZero) then raise EInterAnyError.Create(
          s+':'+CRLF+'возвращаемое значение должно быть строкой, числом или датой');
      finally
        Dispose(CurGFObj); CurGFObj:=oCurGFObj; CurGFObjParams:=oCurGFObjParams; FCurParams:=oCurParams;
        FLeaf:=oLeaf; FPage:=oPage;
        DcmIdentParams:=oDcmIdentParams; Proc:=oBuiltInProc; EvalCalc:=oEvalCalc;
      end;
      pi.Value:=v;
    end;
    Calculating:=false; Calc:=false;
  end;
  DelStack;
end;

procedure TGenForm.AfterOpen;
begin
	AddStack('TGenForm.AfterOpen',Self);
	IfThenNotify(FOnAfterOpen,Self);
  DelStack;
end;

// Восстановить страницу
procedure TGenForm.RestPage;
  procedure CorLn(var ln: byte);
  begin
    AddStack('TGenForm.RestPage.CorLn',Self);
    if ln>1 then begin
      Dec(ln,2); ln:=(ln div 10)*MaxLineWidth+(ln mod 10); Inc(ln,2);
    end;
    DelStack;
  end;
var f: TGFPackFont;
  // Найти шрифт (если нет - добавить)
  // Возвращает номер шрифта
  function FontSeekAdd: byte;
  var i: longint;
  label lend;
  begin
  	AddStack('TGenForm.RestPage.FontSeekAdd',Self);
    for i:=0 to FontCount-1 do begin
      with Fonts[i] do
        if (Font.Name=f.Font.Name) and (Font.Color=f.Font.Color)
        and (Font.Size=f.Font.Size) and (Font.Style=f.Font.Style)
        and (Font.CharSet=f.Font.CharSet) and (Prop.AType=f.Prop.AType)
        and (Prop.Dop.s=f.Prop.Dop.s)
        then begin
          result:=i; goto lend;
        end;
    end;
    result:=FontCount; FontAdd(f);
  lend:
  	DelStack;
  end;
var i,j,k: longint;
  v: TGFObj;
	s: string;
  p: PPages;
  fl,onp: boolean;
begin
	AddStack('TGenForm.RestPage',Self);
  onp:=NoPaint;
  try
    NoPaint := FileBufActive and InRange(Index,1,PageCount);
    if FState=gsView then Init;
    IfThenNotify(OnRestPage,Self);
    if NoPaint then begin
      FLeaf:=Index; p:=@FPages[Index-1]; FBuf.Seek(p.sv.OffSet,soFromBeginning);
      f:=TGFPackFont.Create;
      try
        if (VersInfo.Vers>=25) and ((FState=gsView) or (VersInfo.Vers<26))
        then CurParams:=FBuf.Read(VersInfo.Vers<27,stByte,p.sv.CurParams);
        if VersInfo.Vers<27 then begin
          ColCount:=FBuf.Read(stWord); RowCount:=FBuf.Read(stWord);
          if FState=gsDesign then begin
            p.sv.ColCount:=high(FGridX); p.sv.RowCount:=high(FGridY);
          end;
        end
        else begin
          ColCount:=p.sv.ColCount; RowCount:=p.sv.RowCount;
        end;
        if (VersInfo.Vers>=16) and ((FState=gsView) or (VersInfo.Vers<26)) then begin
          for i:=0 to high(FGridX) do GridX[i]:=nround(FBuf.Read(stReal)/aRate[false]);
          for i:=0 to high(FGridY) do GridY[i]:=nround(FBuf.Read(stReal)/aRate[true]);
        end;
        // Объекты
        j:=FBuf.Read(VersInfo.Vers<27,stWord,p.sv.ObjCount);
        if FState=gsDesign then SetLength(p.av,j);
        for i:=1 to j do begin
          GFObjDef(v);
          v.Left:=FBuf.Read(stWord);
          v.Top:=FBuf.Read(stWord);
          v.Right:=FBuf.Read(stWord);
          v.Bottom:=FBuf.Read(stWord);
          v.LnLeft:=FBuf.Read(stByte);
          v.LnTop:=FBuf.Read(stByte);
          v.LnRight:=FBuf.Read(stByte);
          v.LnBottom:=FBuf.Read(stByte);
          if VersInfo.Vers<19 then begin
            CorLn(v.LnLeft); CorLn(v.LnTop); CorLn(v.LnRight); CorLn(v.LnBottom);
          end;
          v.TypeObj:=FBuf.Read(stByte);
          if (FState=gsView) and (v.TypeObj in [toCalc,toCalcBmp]) and (VersInfo.Vers>=34)
          then NoAutoSize:=false else v.Text:=FBuf.ReadStr;
          v.Alignment:=FBuf.Read(stByte);
          v.MinWidth:=FBuf.Read(stWord);
          v.MinHeight:=FBuf.Read(stWord);
          v.Pin:=FBuf.Read(stByte);
          v.Color:=FBuf.Read(stByte);
          if VersInfo.Vers<1 then begin
            f.Font.Color:=AColor[EnsureRange(FBuf.Read(stByte),low(AColor),high(AColor))];
            f.Font.Size:=FBuf.Read(stByte);
            f.Font.Style:=TFontStyles(byte(FBuf.Read(stByte)));
            f.Font.Name:=FBuf.ReadStr;
            f.Prop.Prim:=IfThen(FontCount=0,'нормальный');
            f.Font.CharSet:=DEFAULT_CHARSET;
	          ZeroMemory(@f.Prop.Dop,SizeOf(f.Prop.Dop));
            f.Prop.AType:=fptNormal; v.Font:=FontSeekAdd;
          end
          else v.Font:=FBuf.Read(stByte);
          v.Ident:=FBuf.ReadStr((FState=gsDesign) and (VersInfo.Vers>=45));
          fl := (FState=gsDesign) or (VersInfo.Vers<2);
          v.Part:=FBuf.ReadStr(fl); v.Col:=FBuf.ReadStr(fl and (VersInfo.Vers>=2));
          v.State:=osShow;
          if FState=gsView then begin
	          v.State:=FBuf.Read(VersInfo.Vers>=2,stByte,osShow);
	          if VersInfo.Vers>=32 then begin
            	v.Ident:=FBuf.ReadStr;
              if LsIdent.Find(v.Ident,k) then with Idents(k)^ do
              	if Calc then v.Text:=Value;
            end;
	          if VersInfo.Vers>=39 then v.Part:=IfThen(FBuf.Read(stBoolean),'','1');
          end;
          v.MMetr:=FBuf.Read(stBoolean);
          v.VOut:=FBuf.Read(VersInfo.Vers>=2,stByte,voBeg);
          v.Only1:=FBuf.Read(VersInfo.Vers>=50,stBoolean,false);
          if (VersInfo.Vers<23) and (FState=gsDesign) and (v.TypeObj=toBmp) then begin
            s:=IntToStr(lsBitMap.Count+1);
            lsBitMap.AddBM(s,'',lsBitMap.FileToStr(v.Text)); v.Text:='"'+s+'"';
          end;
          if FState=gsView then begin
            AddObj(v); ObjBringToFront(FObjects.Count-1);
          end
          else p.av[i-1]:=v;
        end;
      finally
        if FState=gsView then SetSizeMm;
        NoPaint:=onp;
        if FState=gsView then
          if (VersInfo.Vers>=16) and NoAutosize and not p.sv.Modified
          then PaintAll else AutoSize;
        f.Free;
      end;
    end
    else PaintAll;
  finally
  	NoPaint:=onp;
  end;
  //if FState=gsView then TestObjs;
  DelStack;
end;

{ ФОРМИРОВАНИЕ ДОКУМЕНТА }

procedure TGFColList.Delete;
begin
  AddStack('TGFColList.Delete');
  SLObjIndDel(Self,Index,ProcDel,false);
  inherited Delete(Index);
  DelStack;
end;

procedure TGFColList.ProcDel;
begin
  AddStack('TGFColList.ProcDel');
  apv[ni]:=apv[oi];
  DelStack;
end;

function SeekLsMask(var nPart: longint; LsMask: TStringList; const s: string; lAll: boolean = false): boolean;
var i,j,lDat,res1: longint;
	aMask,aPrior,aDat: TSegmStr;
  fl: boolean;
begin
	AddStack('GenForm.SeekLsMask');
	nPart:=NegDef;
  if not empty(s) then begin
    lDat:=LsArrNoEnd(s,aDat,GFSegmDlm); res1:=NegDef;
    if lAll then InitArr(aPrior,0,MaxInt,UnDelim);
    for i:=LsMask.Count-1 downto 0 do begin
      if LsArrNoEnd(LsMask[i],aMask,GFSegmDlm)<>lDat then continue;
      fl:=true;
      for j:=low(aDat) to lDat do
        if not((aMask[j]=aDat[j]) or (aMask[j]=UnDelim)
        or AnsiStartsStr('@',aMask[j]) and (Chr(Int0(Copy(aMask[j],2,MaxInt)))=aDat[j]))
        then begin fl:=false; break; end;
      if fl then begin
        if lAll then begin
          if res1<0 then res1:=i;
          for j:=low(aDat) to lDat do if (aMask[j]<>UnDelim) and (aPrior[j]=UnDelim) then begin
            nPart:=i; break;
          end;
          aPrior:=aMask;
        end
        else begin
          nPart:=i; break;
        end;
      end;
    end;
    if lAll then ReplNegSelf(nPart,res1);
  end;
  result := nPart<>NegDef;
  DelStack;
end;

// Сортировка по возрастанию Part-а
function SortPart(Item1,Item2: Pointer): longint;
var p1,p2: PGFObj;
begin
	AddStack('GenForm.SortPart');
	p1:=Item1; p2:=Item2; result:=AnsiCompareStr(p1.Part,p2.Part);
  if result=0 then result:=p1.Order-p2.Order;
  DelStack;
end;

// Начать формирование документа
procedure TGenForm.DcmForm;
var i,l: longint;
	fn,fnDcm,fnDtg,PartIni: TFileName;
  lFirst,onp: boolean;
  pv: PGFObj;
  al: TArrInt;
label lend;
begin
	AddStack('TGenForm.DcmForm',Self);
  if dcmfOnlyCngLeaf in Opt then
  	if GFDcm.FLeaf=nLeaf then goto lend;
	lDcmForm:=true; lFirst := not FileBufActive; FirstEval:=true; AutoNewPage:=true;
  FDynamicPart:=dcmfDynamicPart in Opt; WasObjAline:=false;
  if Assigned(IdStr) then IdStr.Clear;
	// Первый вызов
	if lFirst then begin
		MsgBreak:=true; FAborted:=true;
    // Открыть выходной файл
    fn:=FullNameExe(TmpFile,'DTG'); DelFileAtr(fn);
    FBuf:=TFileBuf.Create(fn,true);
    if not FileBufActive then begin
      CloseDtg; raise EDcmFormError.Create('Ошибка открытия файла '+fn);
    end;
    oCurGFObj:=CurGFObj; New(CurGFObj);
    // Расшифровка параметров
    i:=low(av); l:=high(av)-i;
    fnDcm:=av[i]; fnDtg:=fnDcm;
    if l>=1 then
      if MyVarType(av[i+1])=varString then fnDtg:=av[i+1];
    PartIni:=fnDcm;
    if l>=2 then
      if MyVarType(av[i+2])=varString then PartIni:=av[i+2];
    // Установка параметров
    State:=gsView; FileName:=fnDtg;
	  GFDcm:=ObjDcm; GFDcm.State:=gsDesign; GFDcm.FileName:=fnDcm; LsIdent.Clear;
    LsBlockLeaf.Clear; FBlockLeaf:=''; BlockLeafBeg:=0; 
	end;
  ClearDcmObj; onp:=GFDcm.NoPaint;
  try
    GFDcm.NoPaint:=true;
    if lFirst then begin
      if GFDcm.Leaf<>nLeaf then GFDcm.Leaf:=nLeaf;
      PageCount:=0; FLeaf:=1; FPage:=1; FPgSmall:=1; FCurPageName:='';
      lCurPagePart:=0; CurPageFirst:=false;
      DynAnyLevel:=false; AutoNewPageObjSpace:=false; LastPart:='';
      SetPrmFromPpdoc(nil,fnDcm,PartIni); lSaveVers:=true;
    end
    else if dcmfOnlyCngLeaf in Opt then GFDcm.Leaf:=nLeaf
    else begin
      GFDcm.OpenDcm(GFDcm.FileName,true,nLeaf); LastPart:='';
    end;
    WasPartFoot:=false; LsPart1[gfpNoFootPg].Clear;
  finally
  	GFDcm.NoPaint:=onp;
  end;
  DestroyObjects;
  // Статические колонки
  for onp:=false to true do aColNm[onp].Clear;
  with TGFColList(aColNm[false]) do begin
    l:=GFDcm.ObjectCount; Capacity:=l;
    if Length(apv)<l then SetLength(apv,l);
    for i:=0 to l-1 do begin
      pv:=GFDcm.PObjects[i];
      if not empty(pv.Col) then Add(pv.Col);
    end;
    SetLength(al,Count);
    for l:=low(al) to high(al) do begin
      Objects[l]:=Pointer(l); SetLength(apv[l],GFDcm.ObjectCount); al[l]:=0;
    end;
    for i:=0 to GFDcm.ObjectCount-1 do begin
      pv:=GFDcm.PObjects[i];
      if not empty(pv.Col) then begin
        l:=IndexOf(pv.Col); apv[l,al[l]]:=pv; Inc(al[l]);
      end;
    end;
    for l:=low(al) to high(al) do SetLength(apv[l],al[l]);
  end;
  ColHead.Clear; ColFoot.Clear; LsPart1[gfpFirstPartPg].Clear; Finalize(aHFPage);
lend:
  DelStack;
end;

procedure TGenForm.SetPrmFromPpdoc;
var ppd: TPPDocRec;
	i: longint;
  r: TRect;
begin
  AddStack('TGenForm.SetPrmFromPpdoc',Self);
  if not empty(PartIni) then begin
    TGenForm.GetPPDcm(fnDcm,PartIni,ppd,GF);
    with ppd.Params do for i:=low(Arr) to high(Arr) do with Arr[i] do
      if InGet then begin
        StdFormat:=false;
        if i<=high(Params.Arr) then SizeMm:=Params.Arr[i].SizeMm;
      end
      else begin
        r:=GFCalcSpotPrn(NFormat,Orientation);
        SpotMm.Left:=max(r.Left,SpotMm.Left);
        SpotMm.Top:=max(r.Top,SpotMm.Top);
        SpotMm.Right:=max(r.Right,SpotMm.Right);
        SpotMm.Bottom:=max(r.Bottom,SpotMm.Bottom);
      end;
    Params:=ppd.Params; CurParams:=0;
    if Assigned(GF)
    then lsBitMap.LoadFromDB(GF.EdlsBitMap,PartIni)
    else begin
      SetSizeMm; FontsAddGF(GFDcm);
      lsBitMap.LoadFromDB(GFDcm.lsBitMap,PartIni);
    end;
    for i:=0 to FontCount-1 do GetPPFont(ppd,i,Fonts[i]);
  end;
  DelStack;
end;

// Добавить динамическую колонку
procedure TGenForm.DcmAddCol;
begin
	AddStack('TGenForm.DcmAddCol',Self);
	if FileBufActive and not empty(Col) then begin
    if not lDcmForm then raise EDcmFormError.Create(
      'Вызов функции ДОК_КОЛ_ДОБ() должен быть до первого вызова функции ДОК_РАЗДЕЛ()');
    aColNm[true].Add(Col);
  end;
  DelStack;
end;

// Удалить статическую или динамическую колонку
procedure TGenForm.DcmDelCol;
var i: longint;
	fl: boolean;
begin
	AddStack('TGenForm.DcmDelCol',Self);
	if FileBufActive then begin
    if not lDcmForm then raise EDcmFormError.Create(
      'Вызов функции ДОК_КОЛ_УДАЛ() должен быть до первого вызова функции ДОК_РАЗДЕЛ()');
	  for fl:=false to true do begin
      i:=aColNm[fl].IndexOf(Col); // Find нельзя
	    if i>=0 then DelCol(fl,i);
    end;
  end;
  DelStack;
end;

// Удалить группу колонок
procedure TGenForm.DcmDelColGr;
var i: longint;
	fl: boolean;
  PrComp: TProcStrComp;
begin
	AddStack('TGenForm.DcmDelColGr',Self);
  PrComp:=ProcStrComp(Col);
  for fl:=false to true do begin
    i:=0;
    while i<aColNm[fl].Count do
      if PrComp(aColNm[fl][i],Col) then DelCol(fl,i) else Inc(i);
  end;
  DelStack;
end;

function TGenForm.DcmArrCol;
var ls: TStringListCase;
  PrComp: TProcStrComp;
  fl: boolean;
  i: longint;
begin
	AddStack('TGenForm.DcmArrCol',Self);
  PrComp:=ProcStrComp(Col); ls:=TStringListCase.CreateSort;
  try
    for fl:=false to true do
	    for i:=0 to aColNm[fl].Count-1 do
      	if PrComp(aColNm[fl][i],Col) then ls.Add(aColNm[fl][i]);
    result:=Ls2Var(ls);
  finally
    ls.Free;
  end;
  DelStack;
end;

procedure TGenForm.HideColStat;
var j,n: longint;
  ls: TGFColList;
begin
	AddStack('TGenForm.HideColStat',Self);
  ls:=pointer(aColNm[false]); n:=IntObj(ls,i);
  for j:=low(ls.apv[n]) to high(ls.apv[n]) do with ls.apv[n,j]^ do begin
    Col:=''; TypeObj:=toText; MMetr:=false; Text:=''; MinWidth:=0; MinHeight:=0;
    Font:=0; LnLeft:=0; LnTop:=0; LnRight:=0; LnBottom:=0;
  end;
  DelStack;
end;

// Удалить статическую колонку
procedure TGenForm.DelCol;
begin
	AddStack('TGenForm.DelCol',Self);
  if not fl then HideColStat(i);
  aColNm[fl].Delete(i);
  DelStack;
end;

// Вывести указанный раздел
procedure TGenForm.DcmPart;
var a: TSegmStr;
  lp: longint;
  function CngSegm(const s: string): string;
  var l,k: longint;
    ap: TSegmStr;
  begin
  	AddStack('TGenForm.DcmPart.CngSegm',Self);
    l:=LsArrNoEnd(s,ap,GFSegmDlm);
    for k:=1 to lp do ap[k]:=a[k];
    result:=ArrayAsList(ap,GFSegmDlm,l,RightStr(TrimRight(s),lGFSegmDlm)=GFSegmDlm);
    DelStack;
  end;
  // Предыдущий раздел / колонка
  function IsPrior(l: TSegmList; const s1: string): boolean;
  var a1: TSegmStr;
    l1: TSegmList;
  begin
  	AddStack('TGenForm.DcmPart.IsPrior',Self);
    l1:=LsArrNoEnd(s1,a1,GFSegmDlm); result:=IfThen(DynAnyLevel,l1<l,l1=l-1);
    if result then while l1>0 do
      if a[l1]=a1[l1] then Dec(l1)
      else begin
        result:=false; break;
      end;
    DelStack;
  end;
  procedure PartMinMax(p: PGFPart; j: TGFPartPrior);
  var i: longint;
  begin
  	AddStack('TGenForm.DcmPart.PartMinMax',Self);
  	with p.aPart1[j] do begin
      nMin:=GFMaxWord; nMax:=0;
      for i:=0 to Objs.Count-1 do begin
        MinSelf(nMin,PGFObj(Objs[i]).Top);
        MaxSelf(nMax,PGFObj(Objs[i]).Bottom);
      end;
    end;
    DelStack;
  end;
var nMin,nMax: longint;
  // Установить значения в описании Part
  procedure SetPartAddr(i: longint);
  var p: PGFPart;
  begin
  	AddStack('TGenForm.DcmPart.SetPartAddr',Self);
    if LsPart.Count>0 then begin
      p:=Parts(LsPart.Count-1); p.nEnd:=i-1; p.nMin:=nMin; p.nMax:=nMax;
    end;
    DelStack;
  end;
var pv: PGFObj;
	p: PGFPart;
  aParent,aChild: TArrStr;
  rObj: TRect;
  ap: TSegmStr;
  v: TGFObj;
  typ: TGFPartPrior;
  i,j,l,k,n,hp,hc,lvMax,pa,pa1: longint;
  s,s1: string;
  //s2,s3,s4,s5,s6,s7,s8: string;
  fl,onp,onp1: boolean;
	av: array[0..0] of variant;
  //k: longint;
  hf: TGFHeadFoot;
  ao,a0: TArrStr;
  vp: (vpOut,vpNewPg,vpWasPartFoot,vpAutoNewPage);
  gfnp: TGFAutoNewPageOpt;
label lend;
begin
  AddStack('TGenForm.DcmPart',Self);
{if CompVar(Part,'CDR.DOPPS2DV') then begin
GFDcm:=GFDcm;
end;}
  onp:=NoPaint; onp1:=GFDcm.NoPaint;
  try
    if not FileBufActive then goto lend;
    NoPaint:=true; GFDcm.NoPaint:=true;
    if lSaveVers then SaveVers;
    if lDcmForm then begin
      lDcmForm:=false;
      // Добавить динамические колонки
      GFDcm.ClearSelection([vsObj]);
      for i:=0 to aColNm[true].Count-1 do 
        if SeekLsMask(j,aColNm[false],aColNm[true][i],true) then with TGFColList(aColNm[false]) do begin
          s:=Strings[j];
          if Pos(UnDelim,s)>0 then begin
            LsArrNoEnd(aColNm[true][i],a,GFSegmDlm);
            // Список родительских колонок
            l:=Count;
            if Length(aParent)<l then SetLength(aParent,l);
            hp:=-1;
            for j:=0 to Count-1 do
              if AnsiStartsStr(Strings[j],s) and (Pos(UnDelim,Strings[j])>0) then begin
                Inc(hp); aParent[hp]:=Strings[j];
              end;
            for n:=0 to hp do begin
              lp:=LsArrNoEnd(aParent[n],ap,GFSegmDlm);
              // Список дочерних колонок
              l:=Count;
              if Length(aChild)<l then SetLength(aChild,l);
              hc:=-1;
              for j:=0 to Count-1 do
                if AnsiStartsStr(aParent[n],Strings[j]) and (Pos(UnDelim,Strings[j])>0) then begin
                  Inc(hc); aChild[hc]:=Strings[j];
                end;
              // Выделить объекты дочерних колонок
              RectObjInit(rObj);
              for j:=0 to hc do begin
                pa:=IntObjFind(aColNm[false],aChild[j]);
                for k:=low(apv[pa]) to high(apv[pa]) do begin
                  apv[pa,k].Selected:=true; RectObjCalc(rObj,apv[pa,k]^);
                end;
              end;
              // Увеличить кол-во колонок и сдвинуть координаты неотмеченных объектов
              l:=rObj.Right-rObj.Left; GFDcm.IncColCount(l);
              for j:=0 to GFDcm.ObjectCount-1 do begin
                pv:=GFDcm.PObjects[j];
                if pv.Selected then continue;
                if pv.Left>=rObj.Right then Inc(pv.Left,l);
                if pv.Right>=rObj.Right then Inc(pv.Right,l);
              end;
              // Скопировать объекты дочерних колонок справа и снять с них выделение
              for j:=0 to hc do begin
                pa:=IntObjFind(aColNm[false],aChild[j]); s:=CngSegm(aChild[j]);
                pa1:=Count;
                if Length(apv)=pa1 then SetLength(apv,IfThen(pa1=0,10,pa1 shl 1));
                AddObject(s,pointer(pa1)); SetLength(apv[pa1],Length(apv[pa]));
                for k:=low(apv[pa]) to high(apv[pa]) do begin
                  apv[pa1,k]:=apv[pa,k]; apv[pa,k].Selected:=false;
                  v:=apv[pa,k]^; Inc(v.Left,l); Inc(v.Right,l); apv[pa,k]:=GFDcm.AddObj(v,false);
                  apv[pa1,k].Col:=s;
                end;
              end;
              for j:=n+1 to hp do aParent[j]:=CngSegm(aParent[j]);
            end;
          end;
        end;
      // Удалить статические колонки, описывающие динамические
      for i:=0 to aColNm[false].Count-1 do
        if Pos(UnDelim,aColNm[false][i])>0 then HideColStat(i);
      GFDcm.AutoSize;
      // Сортировка объектов по возрастанию Part
      AutoSize; ColCount:=high(GFDcm.FGridX); RowCount:=0; ClearPart;
      if GFDcm.FFillObj.Count=0 then goto lend;
      for i:=0 to GFDcm.FFillObj.Count-1 do begin
        FDcmObj.Add(GFDcm.FFillObj[i]); pv:=FDcmObj[i]; pv.DopObj:=nil; pv.Order:=i;
        // Формулы
        InterCreate(pv);
      end;
      FDcmObj.Sort(SortPart);
      s1:=PGFObj(FDcmObj[0]).Part+'~';
      // Определение уровней вложенности Part
      lvMax:=0; fl:=false; nMin:=MaxInt; nMax:=0;
      for i:=0 to FDcmObj.Count-1 do begin
        pv:=FDcmObj[i]; s:=pv.Part;
        if s='' then continue;
        if s=s1 then begin
          MinSelf(nMin,pv.Top); MaxSelf(nMax,pv.Bottom);
        end
        else begin
          if fl then SetPartAddr(i) else fl:=true;
          j:=LsPart.Count;
          if Length(aPart)=j then SetLength(aPart,j shl 1);
          p:=@aPart[j]; LsPart.AddObject(s,pointer(j));
          p.nBeg:=i; p.Level:=0; p.NextMin:=GFMaxWord; p.NextMax:=0;
          p.Prior:=NegDef; p.CntDlm:=LsArrNoEnd(s,a,GFSegmDlm);
          nMin:=pv.Top; nMax:=pv.Bottom; s1:=s;
          for j:=LsPart.Count-2 downto 0 do if IsPrior(p.CntDlm,LsPart[j]) then begin
            p.Level:=Parts(j).Level+1; p.Prior:=j; break;
          end;
          MaxSelf(lvMax,p.Level);
        end;
      end;
      SetPartAddr(FDcmObj.Count);
      for i:=0 to LsPart.Count-1 do begin
        p:=Parts(i);
        if p.Level>0 then with Parts(p.Prior)^ do begin
          MinSelf(NextMin,p.nMin); MaxSelf(NextMax,p.nMax);
        end;
      end;
      // Сортировка по типу объекта по отношению к Part-у
      // предыдущего уровня
      for i:=0 to LsPart.Count-1 do begin
        p:=Parts(i);
        if p.NextMin=GFMaxWord then continue;
        for typ:=low(p.aPart1) to high(p.aPart1) do p.aPart1[typ].Objs:=TList.Create;
        for j:=p.nBeg to p.nEnd do begin
          pv:=FDcmObj[j];
          // Тип объекта по расположению к Part-ам нижнего уровня
          typ:=iif((pv.Top<p.NextMin) and (pv.Bottom<=p.NextMin),plBeg,
            iif((pv.Top<p.NextMax) and (pv.Bottom>p.NextMin),iif(pv.Bottom<p.NextMax,plBeg,plLen),plEnd));
          p.aPart1[typ].Objs.Add(pv);
          if typ=plLen then p.aPart1[plBeg].Objs.Add(pv);
        end;
        PartMinMax(p,plEnd); j:=0;
        while j<p.aPart1[plLen].Objs.Count do begin
          pv:=p.aPart1[plLen].Objs[j];
          if pv.Bottom<p.aPart1[plEnd].nMax then begin
            p.aPart1[plCut].Objs.Add(pv); p.aPart1[plLen].Objs.Delete(j);
          end
          else Inc(j);
        end;
        for typ:=low(p.aPart1) to high(p.aPart1) do
          if typ<>plEnd then PartMinMax(p,typ);
      end;
      ClearLevel(lvMax+1);
      for i:=0 to lvMax do with aLevel[i] do begin
        nm:=''; LsLen:=TList.Create; LsCut:=TList.Create; Prior:=NegDef;
      end;
      lSegmPart:=1; aSegmPart[1]:='';
      lSegmCol:=1; aSegmCol[1]:='';
      {s :='Name:   ';
      s1:='nBeg:   ';
      s2:='nEnd:   ';
      s3:='nMin:   ';
      s4:='nMax:   ';
      s5:='Level:  ';
      s6:='Prior:';
      s7:='NextMin: ';
      s8:='CntDlm: ';
      for i:=0 to PartNm.Count-1 do begin
        p:=PartInf[i];
        IncD(s ,Padc(PartNm[i],10)      + '|');
        IncD(s1,SpaceStr0(p.nBeg,10,0)  + '|');
        IncD(s2,paceStr0(p.nEnd,10,0)   + '|');
        IncD(s3,SpaceStr0(p.nMin,10,0)  + '|');
        IncD(s4,SpaceStr0(p.nMax,10,0)  + '|');
        IncD(s5,SpaceStr0(p.Level,10,0) + '|');
        IncD(s6,SpaceStr0(p.Prior,10,0) + '|');
        IncD(s7,SpaceStr0(p.NextMin,10,0)+ '|');
        IncD(s8,SpaceStr0(p.CntDlm,10,0)+ '|');
      end;
      mess_ok([s,s1,s2,s3,s4,s5,s6,s7,s8]);}
      IsPartInPage:=false;
      for hf:=low(aHFPage) to high(aHFPage) do
        if Length(aHFPage[hf])>0 then begin
          GetHFPage(hf,ao); a0:=nil; SetHFPage(hf,a0); SetHFPage(hf,ao);
        end;
    end;
    if MyVarType(Part)=varString
    then vp:=iif(Part='',vpNewPg,vpOut)
    else vp:=iif(CompVar(Part,1),vpWasPartFoot,vpAutoNewPage);
    fl := (vp=vpOut) and (PartPrim<>'') and AutoNewPage; 
    if fl then begin
      GetHFPage(gfPrim,ao);
      if AnsiMatchStr(PartPrim,ao) then fl:=false;
    end;
    if fl then begin
      i:=lCurPagePart;
      DcmPart(0); DcmPart(Part); DcmPart(PartPrim); DcmPart(0,PartPrim);
      DelSelObj; PrAutoNewPage(0,i,'',[],nil,av); DcmPart(Part);
      GetHFPage(gfPrim,ao); AddFrom(ao,PartPrim); SetHFPage(gfPrim,ao);
    end
    else case vp of
      vpOut: if SeekLsMask(i,LsPart,Part) then DcmPart1(Part,i,plAll,[gfpSel,gfpClrSel,gfpDown,gfpDyn]);
      vpNewPg: begin
        NoPartEnd:=true; DcmNewPage;
      end;
      vpWasPartFoot: NotD(WasPartFoot);
      vpAutoNewPage: begin
        NotD(AutoNewPage);
        if AutoNewPage then begin
          gfnp:=[gfnpObjSpace];
          if PartPrim<>'' then Include(gfnp,gfnpNoDelSelObj);
          PrAutoNewPage(orcMany,olppMany,ocpMany,gfnp,PrNewPgMany,av);
        end
        {$IFDEF ONP} else lNewPgObjs:=0 {$ENDIF};
        orcMany:=high(FGridY); ocpMany:=FCurPagePart; olppMany:=lCurPagePart;
      end;
    end;
lend:
  finally
    NoPaint:=onp;
    if Assigned(GFDcm) then GFDcm.NoPaint:=onp1;
  end;
	DelStack;
end;

class procedure TGenForm.RectObjInit(var r: TRect);
begin
  AddStack('TGenForm.RectObjInit');
  r:=Rect(MaxInt,MaxInt,0,0);
  DelStack;
end;

class procedure TGenForm.RectObjCalc(var r: TRect; const v: TGFObj);
begin
  AddStack('TGenForm.RectObjCalc');
  MinSelf(r.Left,v.Left); MaxSelf(r.Right,v.Right);
  MinSelf(r.Top,v.Top); MaxSelf(r.Bottom,v.Bottom);
  DelStack;
end;

class procedure TGenForm.InterCreate;
var Inter: TInter;
begin
  AddStack('TGenForm.InterCreate');
  if pv.TypeObj in [toForm,toBmp,toCalc,toCalcBmp] then begin
    Inter:=TInter.Create('Вычисление значения объекта документа'); Inter.ShowError:=false;
    Inter.GetAlgProc:=InterGetAlgProc;
    if pv.TypeObj in [toBmp,toCalcBmp] then Inter.value_types:='CA';
    Inter.SetProg(TrimRight(pv.Text)); pv.DopObj:=Inter;
  end;
  DelStack;
end;

procedure TGenForm.InGetRebuild;
var i: longint;
	pv: PGFObj;
  oCurGFObj: PGFObj;
begin
  AddStack('TGenForm.InGetRebuild',Self);
  if InGet then begin
    SetPrmFromPpdoc(Self,'',EdPartIni); NoPaint:=true;
    oCurGFObj:=CurGFObj; New(CurGFObj);
    try
      for i:=0 to ObjectCount-1 do begin
        pv:=PObjects[i];
        if Assigned(pv.DopObj) and not IsObjGet(pv^) then begin
          if EvalText(pv,pv) then begin
            pv.Text:='ОШИБКА !'; pv.Color:=SeekColor(clRed);
          end;
          if pv.TypeObj=toForm then pv.TypeObj:=toText;
        end;
      end;
      AutoSize;
      if ParentRebuild then MsgRebuild(Parent);
      NoPaint:=false; PaintAll;
      for i:=0 to ObjectCount-1 do begin
        pv:=PObjects[i];
        if IsObjGet(pv^) then
          if pv.TypeObj=toGet then TFldEdit(pv.DopObj).Refresh else TPaintSay(pv.DopObj).Paint;
      end;
    finally
      Dispose(CurGFObj); CurGFObj:=oCurGFObj;
    end;
  end;
  DelStack;
end;

procedure TGenForm.DcmPart1;
  // Сохранить состояние уровней
  procedure CopyStateDcm(var LsSource,LsDest: TGFLevel;
    const aSource: TSegmStr; var aDest: TSegmStr; lrest: boolean);
  var i: longint;
  begin
  	AddStack('TGenForm.DcmPart1.CopyStateDcm',Self);
    if lrest then FClearLevel(LsDest);
    i:=Length(LsSource); SetLength(LsDest,i);
    for i:=0 to i-1 do with LsDest[i] do begin
      LsLen:=TList.Create; LsCut:=TList.Create;
      nm:=LsSource[i].nm; Prior:=LsSource[i].Prior;
      AddFrom(LsLen,LsSource[i].LsLen); AddFrom(LsCut,LsSource[i].LsCut);
      if not lrest then LsSource[i].Prior:=NegDef;
    end;
    aDest:=aSource;
    if lrest then FClearLevel(LsSource);
    DelStack;
  end;
  function nMinMax(typ: TGFPartPrior0; pr: PGFPart; var nMin,nMax: longint): boolean;
  begin
    AddStack('TGenForm.DcmPart1.nMinMax',Self);
    result:=Assigned(pr);
    if result then
      if typ=plAll then begin
        nMin:=pr.nMin; nMax:=pr.nMax;
      end
      else begin
        result := pr.NextMin<>GFMaxWord;
        if result then begin
          nMin:=pr.aPart1[typ].nMin; nMax:=pr.aPart1[typ].nMax;
        end;
      end;
    DelStack;
  end;
var pvErr: PGFObj;
  txtErr: string;
  // Вывод объектов указанного Part-а и типа
  procedure DcmPartObj(typ: TGFPartPrior0; pr: PGFPart; nTop: longint);
  var i,k,n,oldr: longint;
    pv: PGFObj;
    v: TGFObj;
    ls: TList;
    nBeg,nEnd,nMin,nMax: longint;
    err,lnil,noObj: boolean;
    pi: PGFIdent;
  label lend;
  begin
  	AddStack('TGenForm.DcmPart1.DcmPartObj',Self);
  	oldr:=high(FGridY); noObj:=true; lSegmPart:=pr.CntDlm;
    // Определение списка объектов
    if not nMinMax(typ,pr,nMin,nMax) then goto lend;
    if nMin>nMax then goto lend;
    if typ=plAll then begin
      ls:=FDcmObj; nBeg:=pr.nBeg; nEnd:=pr.nEnd;
    end
    else begin
      ls:=pr.aPart1[typ].Objs; nBeg:=0; nEnd:=pr.aPart1[typ].Objs.Count-1;
    end;
    n:=high(FGridY)-nMin;
    if nTop=NegDef then RowCount:=high(FGridY)+nMax-nMin;
    for i:=nBeg to nEnd do begin
      v:=PGFObj(ls[i])^;
      if nTop=NegDef then begin
        Inc(v.Top,n); Inc(v.Bottom,n);
      end
      else begin
        v.Top:=nTop; v.Bottom:=high(FGridY);
      end;
      err:=false; lnil:=false; IdStrCurN:=-1;
      case v.TypeObj of
        toText: v.DopObj:=nil;
        toForm,toBmp,toCalc,toCalcBmp: begin
          if v.TypeObj=toForm then v.TypeObj:=toText;
          err:=EvalText(@v,@v,@lnil);
          if v.TypeObj in [toCalc,toCalcBmp] then
            if not IgnoreSLFindAdd(LsIdent,v.Ident,k) then begin
              pi:=IdentNew(k); pi.Leaf:=FLeaf; pi.Calc:=true; pi.lsZero:=false; pi.Edited:=false;
              pi.Bmp := v.TypeObj=toCalcBmp; pi.Fml:=txtAlg; pi.Value:=''; v.Text:='';
            end;
          if err then begin
            err := not Assigned(pvErr); v.Text:='';
          end;
          if not err and (v.TypeObj=toText)
          then v.DopObj:=IfThen(Pos(GFMacroCod(gfmcALWAYS),txtAlg)>0,ls[i]);
        end;
        toGet: begin
          v.TypeObj:=toText; TmpStr.Text:=v.Text; v.Text:=TFldEdit(v.DopObj).Value;
        end;
      end;
      if not lNil then begin
        noObj:=false; v.Part:=Part; v.Selected:=false; pv:=AddObj(v);
        if not SizeNoLimit then TmpList.Add(pv);
        if IdStrCurN>=0 then with IdStr do GetObj(IndexOf(IdStrCurId)).a[IdStrCurN].pv:=pv;
        SetWasObjAline(v,IdStrCurN>=0);
        // Список боковых частей
        if typ in [plBeg,plLen,plCut] then begin
          if pr.aPart1[plLen].Objs.IndexOf(ls[i])>=0
          then aLevel[pr.Level].LsLen.Add(pv);
          if pr.aPart1[plCut].Objs.IndexOf(ls[i])>=0
          then aLevel[pr.Level].LsCut.Add(pv);
        end;
        // Первая ошибочная формула
        if err then begin
          pv.Text:='ОШИБКА !'; pv.Color:=SeekColor(clRed); pvErr:=pv; txtErr:=txtAlg;
        end;
      end
      else if IdStrCurN>=0 then with IdStr do GetObj(IndexOf(IdStrCurId)).a[IdStrCurN].pv:=nil;
    end;
    if noObj then SetRowCount(oldr);
  lend:
  	DelStack;
  end;
var pr,pr1: PGFPart;
  sls: TGFLevel;
	i,j,oldr,nMin,nMax,nMin1,nMax1,olpp: longint;
  a: TSegmStr;
  fl,fl1: boolean;
  oCurPart: string;
  av: array[0..3] of variant;
  hf: TGFHeadFoot;
  gfnp: TGFAutoNewPageOpt;
label lend;
begin
	AddStack('TGenForm.DcmPart1: '+Part,Self);
	if InRange(nPart,0,LsPart.Count-1) then begin
    if (typ=plAll) and (not(gfpSel in Opt) or (gfpClrSel in Opt)) and (Part=LastPart) then
      for hf:=low(aHFPage) to high(aHFPage) do
        if IsLastPartHFPage(hf,LastPart) then goto lend;
    oCurPart:=FCurPagePart; olpp:=lCurPagePart;
    if not(gfpDown in Opt) then CopyStateDcm(aLevel,sls,aSegmPart,a,false);
    if typ=plAll then begin
      // Вывод закрывающих частей
      if (gfpDown in Opt) and not NoPartEnd then begin
        DcmPartEnd(Part,nPart);
      end;
      NoPartEnd:=false;
      LsArrNoEnd(Part,aSegmPart,GFSegmDlm);
    end;
    pr:=Parts(nPart);
    // Вывод открывающих частей
    ParentPartOut := typ=plBeg;
    if typ<>plBeg then TmpList.Clear;
    if FDynamicPart and (pr.Level>0) and (gfpDyn in Opt) and (typ in [plAll,plBeg]) then begin
      if InRange(pr.Prior,0,LsPart.Count-1) then pr1:=Parts(pr.Prior) else pr1:=nil;
      if (pr.Prior<>aLevel[pr.Level].Prior)
      or (aLevel[pr.Level-1].nm<>ArrayAsList(aSegmPart,GFSegmDlm,pr1.CntDlm,true)) then begin
        orcOne:=high(FGridY); //i:=FPage;
        DcmPart1('',pr.Prior,plBeg,[gfpSel,gfpClrSel,gfpDown,gfpDyn]);
        if {(FPage=i) and} nMinMax(typ,pr,nMin,nMax) then begin
          fl:=false;
          while nMinMax(plBeg,pr1,nMin1,nMax1) do begin
            fl := (nMin=nMin1) and (nMax=nMax1);
            if fl then begin
              if InRange(pr1.Prior,0,LsPart.Count-1) then begin
                pr1:=Parts(pr1.Prior); continue;
              end;
            end;
            break;
          end;
          if fl then SetRowCount(orcOne);
        end;
      end;
    end;
    if typ<>plBeg then ParentPartOut:=false;
    // Вывод объектов
    //TmpList.Clear;
    oldr:=high(FGridY);
    pvErr:=nil;
    i:=ObjectCount;
{$IFDEF ONP}
    if (gfpSel in Opt) and (gfpClrSel in Opt) and AutoNewPage and FirstEval and (FSelObjects.Count=0) and not SizeNoLimit then begin
      lNewPgObjs:=i;
      if Length(aNewPgObjs)<lNewPgObjs then SetLength(aNewPgObjs,lNewPgObjs);
      for j:=0 to lNewPgObjs-1 do with aNewPgObjs[j] do begin
        pv:=PObjects[j]; Bottom:=pv.Bottom;
      end;
    end;
{$ENDIF}
    DcmPartObj(typ,pr,NegDef);
    fl := ObjectCount=i;
    aLevel[pr.Level].Prior:=pr.Prior;
    aLevel[pr.Level].nm:=ArrayAsList(aSegmPart,GFSegmDlm,pr.CntDlm,true);
    // Вывод боковых частей
    if not IsPartInPage and (gfpDown in Opt) and not fl then
      for i:=1 to min(high(aLevel),pr.Level+IfThen(typ<>plAll,1)) do with aLevel[i] do begin
        if Prior=NegDef then continue;
        DcmPartObj(plLen,Parts(Prior),oldr);
        if (typ=plAll) or (i<=pr.Level) then DcmPartObj(plCut,Parts(Prior),oldr);
      end;
    if not SizeNoLimit then AutoSizeY(oldr,[gfszyCalcRate]);
    // Автоматический перевод страницы
    fl1 := (not(gfpSel in Opt) or (gfpClrSel in Opt)) and (Part<>'');
    if gfpSel in Opt then begin
      SelectObjs(TmpList,true);
      if (gfpClrSel in Opt) and AutoNewPage and FirstEval then begin
        av[0]:=Part; av[1]:=nPart; av[2]:=typ; av[3]:=byte(Opt-[gfpSel,gfpClrSel]);
        if fl1 and IsLastPartHFPage(gfFoot,Part) then LastPart:=Part;
        if typ in [plAll,plEnd] then gfnp:=[gfnpObjSpace] else gfnp:=[];
        PrAutoNewPage(oldr,olpp,oCurPart,gfnp,PrNewPgOne,av);
      end;
    end;
    if gfpDown in Opt then IsPartInPage:=true;
    if fl1 then begin
      LastPart:=Part;
      if LsPart1[gfpNoFootPg].IndexOf(Part)>=0
        then WasPartFoot:=true
      else if AutoNewPage
        then WasPartFoot:=false;
    end;
    // Удлинение боковых частей
    if not((typ=plEnd) and fl) then
      for j:=pr.Level-IfThen(typ=plAll,1) downto 0 do with aLevel[j] do begin
        for i:=0 to LsLen.Count-1 do PGFObj(LsLen[i]).Bottom:=high(FGridY);
        if j<pr.Level then
          for i:=0 to LsCut.Count-1 do PGFObj(LsCut[i]).Bottom:=high(FGridY);
      end;
    if typ=plEnd then with aLevel[pr.Level] do begin
      LsLen.Clear; LsCut.Clear;
    end;
    if not(gfpDown in Opt) then CopyStateDcm(sls,aLevel,a,aSegmPart,true);
    // Вывод сообщения об ошибке в формуле
    if Assigned(pvErr) then begin
      txtAlg:=txtErr;
      aInterStack[nInterStack+1]:=pvErr.DopObj;
      if InterShowError(pvErr.DopObj,[low(TIEKey)..high(TIEKey)],Self,pvErr)=mrCancel then begin
        DcmClose(false);
        raise EDcmPartError.Create('');
      end;
    end;
  end;
lend:
  DelStack;
end;

procedure TGenForm.SetWasObjAline;
begin
  AddStack('TGenForm.SetWasObjAline',Self);
  if ALine(v) and (not empty(v.Text) or lBound) then WasObjAline:=true;
  DelStack;
end;

class procedure TGenForm.InterGetAlgProc;
begin
  AddStack('TGenForm.InterGetAlgProc');
  Txt:=txtAlg;
  DelStack;
end;

function TGenForm.EvalText;
	procedure pvCopy(Dest,Source: PGFObj);
  begin
    AddStack('TGenForm.EvalText.pvCopy',Self);
    with Source^ do begin
      Dest.LnLeft:=LnLeft; Dest.LnTop:=LnTop; Dest.LnRight:=LnRight; Dest.LnBottom:=LnBottom;
      Dest.Alignment:=Alignment; Dest.MinWidth:=MinWidth; Dest.MinHeight:=MinHeight;
      Dest.Pin:=Pin; Dest.Color:=Color; Dest.Font:=Font; Dest.MMetr:=MMetr;
      Dest.VOut:=VOut; Dest.Only1:=Only1; Dest.Ident:=Ident; Dest.TypeObj:=TypeObj;
    end;
    DelStack;
  end;
var Inter: TInter;
  vr: variant;
	lsZero,lNil: boolean;
  oCurGFObjParams: longint;
begin
  AddStack('TGenForm.EvalText',Self);
  pvCopy(CurGFObj,pv); oCurGFObjParams:=CurGFObjParams;
  try
    IdStrCurPV:=pv; lSegmCol:=LsArrNoEnd(pv.Col,aSegmCol,GFSegmDlm);
    Inter:=pvInt.DopObj; CurGFObjParams:=FCurParams; txtAlg:=pvInt.Text;
    if Length(Inter.listcom)=0 then begin
      vr:=''; result:=false;
    end
    else result:=not Inter.EvalChk(vr,[FirstEval,true]);
    if pv.TypeObj in [toCalc,toCalcBmp] then begin
      if not result and empty(CurGFObj.Ident) then begin
        result:=true; Inter.Error:=E_ANY;
        Inter.sError:='Идентификатор вычисляемого объекта должен быть не пустым.';
      end;
    end
    else begin
      if pv.TypeObj=toBmp then if MyVarType(vr)=varArray then vr:=vr[1]+cCalcBmp+vr[2];
      if GFFmtStr(vr,Params,CurGFObjParams,@lsZero) then lNil:=false
      else begin
        lNil := Assigned(pNil) and IsNil(vr);
        if lNil then PNil^:=true
        else begin
          result:=true; Inter.Error:=E_RETURN;
          Inter.sError:='Возвращаемое значение должно быть строкой, числом или датой.';
        end;
      end;
      AlgZero(lsZero,CurGFObj.Alignment);
      if not(result or lNil) then pv.Text:=vr;
    end;
  finally
    pvCopy(pv,CurGFObj); CurGFObjParams:=oCurGFObjParams;
  end;
  DelStack;
end;

function TGenForm.VArrPart;
var i: longint;
begin
  AddStack('TGenForm.VArrPart',Self);
  with TmpStr do begin
    result:=false; Clear; Sorted:=true;
    for i:=0 to FObjects.Count-1 do Add(PGFObj(FObjects[i]).Part);
    Sorted:=false; result:=Ls2Var(TmpStr);
  end;
  DelStack;
end;

procedure TGenForm.PrAutoNewPage;
var w: longint;
  function NoNewPage: boolean;
  begin
    AddStack('TGenForm.PrAutoNewPage.NoNewPage');
    if IsPartInPage then w:=GridY[high(FGridY)]-GetBottomLimit else w:=0;
    result := w<=0;
    DelStack;
  end;
  function Pg1(const oCurPart: string): boolean;
  var i,ocnt: longint;
    s: string;
    fl: boolean;
  label lend;
  begin
    AddStack('TGenForm.PrAutoNewPage.Pg1',Self);
    result:=true;
    if SizeNoLimit then goto lend;
    if AutoNewPageObjSpace and (gfnpObjSpace in Opt) then ObjSpace(nil,[gfspNoAutoSize,gfspSel],pinTopRight);
    if WasObjAline then begin
      AutoSizeX(0,[gfszxCalcRate,gfszxNoCngCrd]); AutoSizeY(0); IdStrObjText;
    end;
    if NoNewPage then goto lend;
    if not WasObjAline then begin
      AutoSizeY(0);
      if NoNewPage then goto lend;
    end;
    if not Assigned(Proc) then goto lend;
    fl:=WasPartFoot; mnBreakExec(true,w); Proc(Opt,av,oldr);
//meserr(GridY[oldr]); AutoSize; meserr(GridY[high(FGridY)]);
    // Удалить Part с предыдущей страницы
    DelSelObj;
    // Восстановить название страницы
    lCurPagePart:=olCurPagePart;
{$IFDEF ONP}
    // Отменить удлинение боковых частей (д.б. как-то по другому, ждём жалобы)
    for i:=0 to lNewPgObjs-1 do with aNewPgObjs[i] do pv.Bottom:=Bottom;
    lNewPgObjs:=0;
{$ENDIF}
    LastPart:=''; oldr:=0; ocnt:=FObjects.Count;
    for i:=0 to ocnt-1 do MaxSelf(oldr,PGFObj(FObjects[i]).Bottom);
    SetLength(FGridY,oldr+1);
    s:=FCurPagePart; FCurPagePart:=oCurPart;
    // Вывести подвал и примечания страницы
    HFOut(gfFoot); PrimOut;
    WasPartFoot:=fl;
    // Перевод страницы
    DcmNewPage([newpgAuto]); TmpList.Clear; FCurPagePart:='';
    CurPagePart:=s;
    // РАЗДЕЛ_ПРИМ обнулять при DcmNewPage
    SetHFPage(gfPrim,[]);
    // Вывести заголовок страницы
    HFOut(gfHead);
    // Если на предыдущей странице был только заголовок страницы, остальное не поместится и на этой странице
    result := FObjects.Count=ocnt;
    orcOne:=high(FGridY);
    WasPartFoot:=fl;
    // Вывести Part на следующую страницу
    Proc(Opt+[gfnpAfter],av,oldr); AutoSizeY(0,[gfszyCalcRate]);
	lend:
    if result and not ParentPartOut and not(gfnpNoDelSelObj in Opt) then begin
      for i:=0 to FSelObjects.Count-1 do PGFObj(FSelObjects[i]).Selected:=false;
      FSelObjects.Clear; {$IFDEF ONP}lNewPgObjs:=0;{$ENDIF}
    end;
    DelStack;
  end;
var oLeaf: longint;
begin
  AddStack('TGenForm.PrAutoNewPage',Self);
  if not Pg1(oCurPart) then while not NoNewPage do begin
    SelectObjs(FObjects,true); oLeaf:=FLeaf;
    if Pg1(FCurPagePart) then break;
    if FLeaf=oLeaf then break;
  end;
  DelStack;
end;

procedure TGenForm.PrNewPgOne;
var i,j: longint;
  p: PGFIdStr;
  pv: PGFObj;
begin
	AddStack('TGenForm.PrNewPgOne',Self);
  if gfnpAfter in Opt then begin
    FirstEval:=false; DcmPart1(av[0],av[1],av[2],TGFDcmPartOpt(byte(av[3]))); FirstEval:=true;
  end
  else begin
    if Assigned(IdStr) then begin
      i:=0;
      while i<IdStr.Count do begin
        p:=IdStr.GetObj(i); j:=0;
        while j<Length(p.a) do
          if p.a[j].pv.Selected then IdStrDel(p,j) else Inc(j);
        if j=0 then IdStr.Delete(i) else Inc(i);
      end;
      if i=0 then FreeAndNil(IdStr);
    end;
    oldr:=0;
    for i:=0 to FObjects.Count-1 do begin
      pv:=PGFObj(FObjects[i]);
      if not pv.Selected then MaxSelf(oldr,pv.Bottom);
    end;
  end;
  DelStack;
end;

procedure TGenForm.PrNewPgMany;
var v: ^TArrGFObj;
	i,j,t,b: longint;
  pv1,pv2: PGFObj;
  ls: TStringList;
  pi: PGFIdStr;
label lend;
begin
	AddStack('TGenForm.PrNewPgMany',Self);
  if gfnpAfter in Opt then begin
    v:=PointerVar(av[0]);
    if Assigned(v) then begin
      t:=MaxInt; b:=0;
      for i:=low(v^) to high(v^) do with v^[i] do begin
        MinSelf(t,Top); MaxSelf(b,Bottom);
      end;
      i:=high(FGridY); RowCount:=i+b-t; t:=i-t;
      for i:=low(v^) to high(v^) do with v^[i] do begin
        Inc(Top,t); Inc(Bottom,t);
        pv1:=AddObj(v^[i]); SetWasObjAline(v^[i],false); IsPartInPage:=true;
        if (TypeObj in [toText,toCalc,toCalcBmp]) and Assigned(DopObj) then begin
          if TypeObj=toText then begin
            pv2:=PGFObj(DopObj); pv1.Text:=pv2.Text;
          end
          else pv2:=pv1;
          EvalText(pv1,pv2);
        end;
        if LsIdent.Find(pv1.Ident,j) then Idents(j).Leaf:=FLeaf;
        if Assigned(IdStr) then for b:=0 to IdStr.Count-1 do begin
          pi:=IdStr.GetObj(b);
          for j:=low(pi.a) to high(pi.a) do
            if pi.a[j].pv=@v^[i] then begin
              pi.a[j].pv:=pv1; goto lend;
            end;
        end;
lend:
      end;
      Dispose(v);
    end;
  end
  else if FSelObjects.Count=0 then av[0]:=0
  else begin
  	if FSelObjects.Count=FObjects.Count then begin // Все не влезли на страницу
      IfThenNotify(OnNoFitOnPage);
    	b:=GetBottomLimit; ls:=SortStrListCreate;
      try
		    for i:=0 to FSelObjects.Count-1 do with SelObjects[i] do
	      	if GridY[Bottom]>b then ls.Add(Part);
        i:=0; oldr:=0;
        while i<FSelObjects.Count do with PSelObjects[i]^ do
          if ls.IndexOf(Part)<0 then begin
          	MaxSelf(oldr,Bottom); Selected:=false; FSelObjects.Delete(i);
          end
          else Inc(i);
      finally
        ls.Free;
      end;
    end;
  	New(v); SetLength(v^,FSelObjects.Count);
    for i:=0 to FSelObjects.Count-1 do begin
    	v^[i]:=SelObjects[i];
      if not(gfnpNoDelSelObj in Opt) then v^[i].Selected:=false;
    end;
    if Assigned(IdStr) then for i:=0 to IdStr.Count-1 do begin
      pi:=IdStr.GetObj(i);
      for t:=low(pi.a) to high(pi.a) do
        for b:=0 to FSelObjects.Count-1 do
          if pi.a[t].pv=PSelObjects[b] then begin
            pi.a[t].pv:=@v^[b]; pi.lNewPg:=true; break;
          end;
    end;
    av[0]:=longint(v);
  end;
  DelStack;
end;

procedure TGenForm.HFOut;
var i: longint;
begin
  AddStack('TGenForm.HFOut',Self);
  for i:=low(aHFPage[hf]) to high(aHFPage[hf]) do with aHFPage[hf,i] do DcmPart1(Part,nPart,plAll,[]);
  DelStack;
end;

// РАЗДЕЛ_ПРИМНАЧ,РАЗДЕЛ_ПРИМ выводить после РАЗДЕЛ_КОН и на посл.странице, если не пусто РАЗДЕЛ_ПРИМ
procedure TGenForm.PrimOut;
begin
  AddStack('TGenForm.PrimOut',Self);
  if Length(aHFPage[gfPrim])>0 then begin
    HFOut(gfPrimBeg); HFOut(gfPrim);
  end;
  DelStack;
end;

// Вывести закрывающие части
procedure TGenForm.DcmPartEnd;
var i,lv: longint;
  a: TSegmStr;
	pr: PGFPart;
  fl: boolean;
begin
	AddStack('TGenForm.DcmPartEnd',Self);
  if FDynamicPart then begin
    if nPart=NegDef then lv:=0 else lv:=Parts(nPart).Level;
    LsArrNoEnd(Part,a,GFSegmDlm);
    for i:=high(aLevel) downto 1 do with aLevel[i] do begin
      fl := i>lv;
      if not fl then begin
        pr:=Parts(nPart); nPart:=pr.Prior;
        fl := (nPart<>Prior)
          or (aLevel[i-1].nm<>ArrayAsList(a,GFSegmDlm,Parts(pr.Prior).CntDlm,true));
      end;
      if fl then begin
        DcmPart1('',Prior,plEnd,[gfpSel,gfpClrSel,gfpDown,gfpDyn]); Prior:=NegDef; nm:='';
      end;
    end;
  end;
  DelStack;
end;

// Закончить формирование
procedure TGenForm.DcmClose;
var fn: TFileName;
	onp: boolean;
begin
	AddStack('TGenForm.DcmClose',Self);
	if FileBufActive and Assigned(GFDcm) then begin
    onp:=NoPaint;
    try
      NoPaint:=true; FAborted := not lSave;
      if lSave then begin
        if lSaveVers then SaveVers;
        DcmPartEnd; PrimOut; BlockLeafAdd(IfThen(FObjects.Count=0,1)); SavePages;
      end;
      TFileBuf(FBuf).Update(true); CloseDtg; fn:=FullNameExe(TmpFile,'DTG');
      if lSave then CopyFileMsg(fn,FullNameExe(FFileName,'DTG'));
      DelFileAtr(fn);
    finally
      ClearPart; ClearLevel; ClearDcmObj; Dispose(CurGFObj);
    	NoPaint:=onp; CurGFObj:=oCurGFObj; GFDcm.NoPaint:=false; GFDcm:=nil;
    end;
  end;
  DelStack;
end;

// Следующая страница
procedure TGenForm.DcmNewPage;
var i: longint;
begin
	AddStack('TGenForm.DcmNewPage',Self);
	if FileBufActive and IsPartInPage then begin
    if newpgPartEnd in Opt then DcmPartEnd;
    if newpgPrim in Opt then begin
      PrimOut; SetHFPage(gfPrimBeg,[]); SetHFPage(gfPrim,[]); 
    end;
    for i:=low(aLevel) to high(aLevel) do with aLevel[i] do begin
      LsLen.Clear; LsCut.Clear;
    end;
    SaveLongPage(not(newpgAuto in Opt));
    DestroyObjects; ColCount:=high(GFDcm.FGridX); RowCount:=0; lCurPagePart:=0; WasObjAline:=false;
    for i:=low(aLevel) to high(aLevel) do with aLevel[i] do begin
      Prior:=NegDef; nm:='';
    end;
  end;
  DelStack;
end;

// Заголовок и подвал страницы
procedure TGenForm.GetHFPage;
var i: longint;
begin
	AddStack('TGenForm.GetHFPage',Self);
  SetLength(result,Length(aHFPage[Index]));
  for i:=low(result) to high(result) do result[i]:=aHFPage[Index,i].Part;
  DelStack;
end;

procedure TGenForm.SetHFPage;
  procedure GridCopy(var Dest: TArrGFGrid; const Source: TArrGFGrid);
  var i: longint;
  begin
  	AddStack('TGenForm.SetHFPage.GridCopy',Self);
    i:=Length(Source); SetLength(Dest,i);
    for i:=0 to i-1 do Dest[i]:=Source[i];
    DelStack;
  end;
  procedure ObjSave(var Dest: TArrPointer; Source: TList);
  var i: longint;
  begin
  	AddStack('TGenForm.SetHFPage.ObjSave',Self);
    i:=Source.Count; SetLength(Dest,i);
    for i:=0 to i-1 do Dest[i]:=Source[i];
    Source.Clear;
    DelStack;
  end;
  procedure ObjRest(Dest: TList; const Source: TArrPointer);
  var i: longint;
  begin
  	AddStack('TGenForm.SetHFPage.ObjRest',Self);
    i:=Length(Source); Dest.Clear; Dest.Capacity:=i;
    for i:=0 to i-1 do Dest.Add(Source[i]);
    DelStack;
  end;
const amsg: array[TGFHeadFoot] of string =
  (', открывающего страницу'
  ,', закрывающего страницу'
  ,', открывающего примечания в конце страницы'
  ,'для вывода примечаний в конце страницы');
var i: longint;
  pr: PGFPart;
  a: TArrStr;
  fl: boolean;
  oGridX,oGridY: TArrGFGrid;
  oObjects,oSelObjects,oFillObj: TArrPointer;
begin
	AddStack('TGenForm.SetHFPage',Self);
	if FileBufActive then begin
    GetHFPage(Index,a);
    fl := Length(a)<>Length(Value);
    if not fl then for i:=low(a) to high(a) do if a[i]<>Value[i] then begin
      fl:=true; break;
    end;
    if fl then begin
      SetLength(aHFPage[Index],Length(Value));
      for i:=low(Value) to high(Value) do with aHFPage[Index,i] do begin
        Part:=Value[i];
        if lDcmForm then nPart:=NegDef
        else if SeekLsMask(nPart,LsPart,Part) then begin
          pr:=Parts(nPart);
          if (pr.nMax<>0) and (pr.Level<>0)
          then raise EDcmFormError.Create('Ошибка установки раздела '+amsg[Index]+'.');
        end;
      end;
      if Index in [gfFoot,gfPrimBeg,gfPrim] then begin
        HFHeight[Index]:=0;
        if not lDcmForm then begin
          GridCopy(oGridX,FGridX); GridCopy(oGridY,FGridY);
          ObjSave(oObjects,FObjects); ObjSave(oSelObjects,FSelObjects); ObjSave(oFillObj,FFillObj);
          Init(false); WasObjAline:=false;
          for i:=low(Value) to high(Value) do with aHFPage[Index,i] do DcmPart1(Part,nPart,plAll,[gfpSel]);
          AutoSizeX(0,[gfszxCalcRate,gfszxWidthOnLeaf]);
          AutoSizeY(0);
          i:=GridY[high(FGridY)]-GridY[0];
          if i>GridLine(true) then HFHeight[Index]:=i;
          DelSelObj; 
          GridCopy(FGridX,oGridX); GridCopy(FGridY,oGridY);
          ObjRest(FObjects,oObjects); ObjRest(FSelObjects,oSelObjects); ObjRest(FFillObj,oFillObj);
        end;
      end;
    end;
  end;
  DelStack;
end;

function TGenForm.GetBottomLimit;
begin
  AddStack('TGenForm.GetBottomLimit',Self);
  result:=Height-FSpot.Bottom;
  if not(WasPartFoot or IsLastPartHFPage(gfFoot,LastPart)) then Dec(result,HFHeight[gfFoot]);
  // К высоте подвала добавлять высоту РАЗДЕЛ_ПРИМНАЧ+РАЗДЕЛ_ПРИМ, если не пусто РАЗДЕЛ_ПРИМ
  if Length(aHFPage[gfPrim])>0 then Dec(result,HFHeight[gfPrimBeg]+HFHeight[gfPrim]);
  DelStack;
end;

function TGenForm.IsLastPartHFPage;
begin
  AddStack('TGenForm.IsLastPartHFPage',Self);
  if Length(aHFPage[Index])=0 then result:=false else result := Part=aHFPage[Index,high(aHFPage[Index])].Part;
  DelStack;
end;

// Добавить колонку, открывающую страницу
procedure TGenForm.AddColHead;
begin
	AddStack('TGenForm.AddColHead',Self);
	if not empty(Col) then ColHead.Add(Col);
  DelStack;
end;

// Добавить колонку, закрывающую страницу
procedure TGenForm.AddColFoot;
begin
	AddStack('TGenForm.AddColFoot',Self);
	if not empty(Col) then ColFoot.Add(Col);
  DelStack;
end;

procedure TGenForm.AddPart;
begin
  AddStack('TGenForm.AddPart',Self);
	if not empty(Part) then LsPart1[n].Add(Part);
  DelStack;
end;

procedure TGenForm.ClearPart;
var i: longint;
  j: TGFPartPrior;
	p: PGFPart;
begin
	AddStack('TGenForm.ClearPart',Self);
	if Assigned(LsPart) then begin
    for i:=0 to LsPart.Count-1 do begin
      p:=Parts(i);
      if p.NextMin<>GFMaxWord then
        for j:=low(p.aPart1) to high(p.aPart1) do p.aPart1[j].Objs.Free;
    end;
    LsPart.Clear;
  end;
  DelStack;
end;

function TGenForm.Parts;
begin
  AddStack('TGenForm.Parts',Self);
  result:=@aPart[IntObj(LsPart,i)];
  DelStack;
end;

procedure TGenForm.ClearDcmObj;
var i,ost: longint;
	v: TGFObj;
  int: TInter;
begin
	ost:=AddStack('TGenForm.ClearDcmObj',Self);
	if Assigned(FDcmObj) then begin
    for i:=0 to FDcmObj.Count-1 do begin
      v:=PGFObj(FDcmObj[i])^;
      if v.TypeObj in [toForm,toBmp,toCalc,toCalcBmp] then
        try
          if IsClass(v.DopObj,TInter,pointer(int)) then int.Free;
        except
          SetStack(ost);
        end;
    end;
    if lFree then FreeAndNil(FDcmObj) else FDcmObj.Clear;
  end;
  DelStack;
end;

// Название страницы
function TGenForm.GetPageName;
begin
	AddStack('TGenForm.GetPageName',Self);
  if InRange(Index,1,PageCount) then result:=FPages[Index-1].sv.Text else result:='';
  DelStack;
end;

procedure TGenForm.SetPageName;
begin
	AddStack('TGenForm.SetPageName',Self);
  if InRange(Index,1,PageCount) then FPages[Index-1].sv.Text:=Value;
  DelStack;
end;

procedure TGenForm.PageAdd;
var p,pFrom: PPages;
	i: longint;
begin
  AddStack('TGenForm.PageAdd',Self);
  p:=PageNew;
  if PgCopyFrom=NegDef then begin
	  p.sv.Text:=''; p.sv.ColCount:=1; p.sv.RowCount:=1; SetLength(p.av,1); GFObjDef(p.av[0]);
  end
  else begin
  	pFrom:=@FPages[PgCopyFrom]; p.sv:=pFrom.sv; SetLength(p.av,Length(pFrom.av));
    for i:=low(p.av) to high(p.av) do p.av[i]:=pFrom.av[i];
  end;
  p.sv.PgLong:=PageCount; p.sv.PgSmall:=1; p.sv.Modified:=false;
  DelStack;
end;

function TGenForm.PageNew;
begin
  AddStack('TGenForm.PageNew',Self);
  if Length(FPages)=PageCount then SetLength(FPages,PageCount shl 1);
  result:=@FPages[PageCount]; Inc(PageCount);
  DelStack;
end;

procedure TGenForm.PageDel;
var i: longint;
begin
	AddStack('TGenForm.PageDel',Self);
  for i:=Index to PageCount-1 do FPages[i-1]:=FPages[i];
  Dec(PageCount);
  DelStack;
end;

procedure TGenForm.PageExchange;
var p: TPages;
begin
	AddStack('TGenForm.PageExchange',Self);
  Dec(oi); Dec(ni); p:=FPages[oi]; FPages[oi]:=FPages[ni]; FPages[ni]:=p;
  DelStack;
end;

function TGenForm.Pages;
begin
  AddStack('TGenForm.Pages',Self);
  if InRange(Index,0,PageCount-1) then result:=@FPages[Index] else result:=nil;
  DelStack;
end;

function TGenForm.PgObjectCount;
begin
  AddStack('TGenForm.PgObjectCount',Self);
  result:=Length(FPages[PgIndex].av);
  DelStack;
end;

function TGenForm.PgObjects;
begin
	AddStack('TGenForm.PgObjects',Self);
  result:=@FPages[PgIndex].av[Index];
  DelStack;
end;

function TGenForm.PageInf;
begin
  AddStack('TGenForm.PageInf',Self);
  if InRange(Index,1,PageCount) then result:=FPages[Index-1].sv
  else begin
    Finalize(result); ZeroMemory(@result,SizeOf(result));
  end;
  DelStack;
end;

function TGenForm.Idents;
begin
  AddStack('TGenForm.Idents',Self);
  result:=@aIdent[IntObj(LsIdent,Index)];
  DelStack;
end;

{ ВВОД ЗНАЧЕНИЙ }

{ ПАРАМЕТРЫ ПЕЧАТИ }

function PrmStrNum(i: longint): string;
begin
  AddStack('GenForm.PrmStrNum');
  result:=IfThen(i>0,StrNum('.',i));
  DelStack;
end;

procedure PutPPDcmBreak(const sPartIni: TFileName; const Prm: TPPDocRec);
var i: longint;
  s: string;
  PartIni: TFileName;
begin
  AddStack('GenForm.PutPPDcmBreak');
	PartIni:=UpperCase(sPartIni);
	with InitFIni[fiPPDoc],Prm.Params do
    for i:=low(Arr) to high(Arr) do with Arr[i] do begin
      s:=PrmStrNum(i);
      WriteBool(PartIni,'HorzBreak'+s,false in aBreak); WriteBool(PartIni,'VertBreak'+s,true in aBreak);
      WriteBool(PartIni,'HorzWidth'+s,false in aWidth); WriteBool(PartIni,'VertWidth'+s,true in aWidth);
    end;
  DelStack;
end;

// Параметры из INI-файла
class procedure TGenForm.GetPPDcm;
var fn: TFileName;
	i: longint;
  v: TGFVersInfo;
  n2: longword;
  f: TFileBuf;
  PartIni: TFileName;
  fl,CanLoad: boolean;
	l: byte;
  s1,s2: string;
begin
	AddStack('TGenForm.GetPPDcm');
	PartIni:=UpperCase(sPartIni);
	with result do begin
  	if not Assigned(GF) then begin
      fn:=FullNameExe(FileName,'DCM');
      if not MyFileExists(fn) then raise EDcmFormError.Create('Ошибка открытия файла '+fn);
    end;
    InitFIni[fiPPDoc].DeleteKey(PartIni,'DateDcm'); CanLoad:=true; f:=nil;
    try
      while true do begin
        if not Assigned(GF) then f:=TFileBuf.Create(fn);
		  	if Assigned(GF) then begin
        	v.NumSave:=GF.VersInfo.NumSave; v.ChkSum:=GF.VersInfo.ChkSum;
          Params:=GFCopyParams(GF.EdPpdPrm.Params);
        end
        else begin
    	    ReadVers(v,f,fn,gbrNone); Params:=ReadParams(f,v.Vers);
        end;
        n2:=InitFIni[fiPPDoc].ReadInteger(PartIni,'ChkSum');
        if n2=0 then begin
          n2:=InitFIni[fiPPDoc].ReadInteger(PartIni,'NumLink'); fl := v.NumSave<>n2;
        end
        else fl := v.ChkSum<>longint(n2);
        // Нет записи в INI-файле или сменилась номер сборки DCM-файла
        if fl then begin
          Fonts:='';
          if not Assigned(GF) then begin
            fl:=false;
            with Params do for i:=low(Arr) to high(Arr) do with Arr[i] do
              if not InRange(byte(Orientation),byte(low(Orientation)),byte(high(Orientation))) then begin
                if CanLoad then CanLoad:=LoadFromServer(FileName,true);
                if not CanLoad then raise EDcmFormError.Create('Нарушено содержимое файла '+fn);
                CanLoad:=false; fl:=true; break;
              end;
            if fl then begin
              FreeAndNil(f);
              continue;
            end;
          end;
          InitFIni[fiPPDoc].DeleteKey(PartIni,'NumLink');
          InitFIni[fiPPDoc].WriteInteger(PartIni,'ChkSum',v.ChkSum);
          if n2=0 then PutPPDcm(PartIni,result) else PutPPDcmBreak(PartIni,result);
        end;
        // Параметры из INI-файла
        if Assigned(GF) then fl:=not GF.InGet else fl:=true;
        with Params do begin
          DateTime:=InitFIni[fiPPDoc].ReadBool(PartIni,'DateTime',DateTime);
          for i:=low(Arr) to high(Arr) do with Arr[i] do begin
            s1:=PrmStrNum(i);
            if fl then begin
              StdFormat:=InitFIni[fiPPDoc].ReadBool(PartIni,'StdFormat'+s1,StdFormat);
              NFormat:=TGFFrmList(InitFIni[fiPPDoc].ReadInteger(PartIni,'NFormat'+s1,byte(NFormat)));
            end;
            Orientation:=TPrinterOrientation(InitFIni[fiPPDoc].ReadInteger(PartIni,'Orientation'+s1,byte(Orientation)+1)-1);
            GridLineWidth:=InitFIni[fiPPDoc].ReadInteger(PartIni,'GridLineWidth'+s1,GridLineWidth);
            GridLineMin:=InitFIni[fiPPDoc].ReadInteger(PartIni,'GridLineMin'+s1,GridLineMin);
            SetSet(aBreak,false,InitFIni[fiPPDoc].ReadBool(PartIni,'HorzBreak'+s1,false in aBreak));
            SetSet(aBreak,true,InitFIni[fiPPDoc].ReadBool(PartIni,'VertBreak'+s1,true in aBreak));
            SetSet(aWidth,false,InitFIni[fiPPDoc].ReadBool(PartIni,'HorzWidth'+s1,false in aWidth));
            SetSet(aWidth,true,InitFIni[fiPPDoc].ReadBool(PartIni,'VertWidth'+s1,true in aWidth));
            with PrmNum do begin
              FracDlm:=StrToChar(InitFIni[fiPPDoc].ReadString(PartIni,'NFracDlm'+s1,FracDlm));
              FracCnt:=EnsureRange(InitFIni[fiPPDoc].ReadInteger(PartIni,'NFracCnt'+s1,FracCnt),0,FloatMaxDec);
              FracEmp:=Bool2FracEmp(InitFIni[fiPPDoc].ReadBool(PartIni,'NFracEmp'+s1,FracEmp2Bool(FracEmp)));
              DigIsDlm:=InitFIni[fiPPDoc].ReadBool(PartIni,'NDigIsDlm'+s1,DigIsDlm);
              DigDlm:=StrToChar(InitFIni[fiPPDoc].ReadString(PartIni,'NDigDlm'+s1,DigDlm));
              ZeroEmp.l:=InitFIni[fiPPDoc].ReadBool(PartIni,'NZeroEmp'+s1,ZeroEmp.l);
              AllCnt:=EnsureRange(InitFIni[fiPPDoc].ReadInteger(PartIni,'NAllCnt'+s1,AllCnt),0,FloatMaxLen);
              ZeroEmp.s:=InitFIni[fiPPDoc].ReadString(PartIni,'NsZero'+s1,ZeroEmp.s);
            end;
            with PrmDate do begin
              Dlm:=StrToChar(InitFIni[fiPPDoc].ReadString(PartIni,'DDlm'+s1,Dlm));
              NYear:=InitFIni[fiPPDoc].ReadInteger(PartIni,'DNYear'+s1,NYear);
              MMYY:=InitFIni[fiPPDoc].ReadBool(PartIni,'DMMYY'+s1,MMYY);
              ZeroEmp.l:=InitFIni[fiPPDoc].ReadBool(PartIni,'DZeroEmp'+s1,ZeroEmp.l);
              ZeroEmp.s:=InitFIni[fiPPDoc].ReadString(PartIni,'DsZero'+s1,ZeroEmp.s);
            end;
            with SpotMm do begin
              Left:=InitFIni[fiPPDoc].ReadInteger(PartIni,'SpotLeftMm'+s1,Left);
              Top:=InitFIni[fiPPDoc].ReadInteger(PartIni,'SpotTopMm'+s1,Top);
              Right:=InitFIni[fiPPDoc].ReadInteger(PartIni,'SpotRightMm'+s1,Right);
              Bottom:=InitFIni[fiPPDoc].ReadInteger(PartIni,'SpotBottomMm'+s1,Bottom);
            end;
            if fl
            then WinSize(SizeMm,
              InitFIni[fiPPDoc].ReadInteger(PartIni,'WidthMm'+s1,SizeMm.cX),
              InitFIni[fiPPDoc].ReadInteger(PartIni,'HeightMm'+s1,SizeMm.cY));
          end;
        end;
        s1:=InitFIni[fiPPDoc].ReadString(PartIni,'Fonts'); i:=1; s2:='';
        while i<=Length(s1) do begin
          l:=Int0(copy(s1,i,3));
          if l=0 then IncD(s2,CRLF)
          else begin
            IncD(s2,CRLF+copy(s1,i+3,l)); Inc(i,l);
          end;
          Inc(i,3);
        end;
        Fonts:=copy(s2,lCRLF1,MaxInt);
        break;
      end;
    finally
      f.Free;
    end;
  end;
  DelStack;
end;

// Параметры в INI-файл
class procedure TGenForm.PutPPDcm;
var i: longint;
  s: string;
  PartIni: TFileName;
  a: TArrStr;
begin
	AddStack('TGenForm.PutPPDcm');
	PartIni:=UpperCase(sPartIni);
	with InitFIni[fiPPDoc] do begin
  	with Prm.Params do begin
      WriteBool(PartIni,'DateTime',DateTime);
      for i:=low(Arr) to high(Arr) do with Arr[i] do begin
        s:=PrmStrNum(i);
        WriteBool(PartIni,'StdFormat'+s,StdFormat);
        WriteInteger(PartIni,'NFormat'+s,byte(NFormat));
        WriteInteger(PartIni,'Orientation'+s,byte(Orientation)+1);
        WriteInteger(PartIni,'GridLineMin'+s,GridLineMin);
        WriteInteger(PartIni,'GridLineWidth'+s,GridLineWidth);
        with PrmNum do begin
          WriteString(PartIni,'NFracDlm'+s,FracDlm);
          WriteInteger(PartIni,'NFracCnt'+s,FracCnt);
          WriteBool(PartIni,'NFracEmp'+s,FracEmp2Bool(FracEmp));
          WriteBool(PartIni,'NDigIsDlm'+s,DigIsDlm);
          WriteString(PartIni,'NDigDlm'+s,DigDlm);
          WriteBool(PartIni,'NZeroEmp'+s,ZeroEmp.l);
          WriteInteger(PartIni,'NAllCnt'+s,AllCnt);
          WriteString(PartIni,'NsZero'+s,ZeroEmp.s);
        end;
        with PrmDate do begin
          WriteString(PartIni,'DDlm'+s,Dlm);
          WriteInteger(PartIni,'DNYear'+s,NYear);
          WriteBool(PartIni,'DMMYY'+s,MMYY);
          WriteBool(PartIni,'DZeroEmp'+s,ZeroEmp.l);
          WriteString(PartIni,'DsZero'+s,ZeroEmp.s);
        end;
        WriteInteger(PartIni,'SpotLeftMm'+s,SpotMm.Left);
        WriteInteger(PartIni,'SpotTopMm'+s,SpotMm.Top);
        WriteInteger(PartIni,'SpotRightMm'+s,SpotMm.Right);
        WriteInteger(PartIni,'SpotBottomMm'+s,SpotMm.Bottom);
        WriteInteger(PartIni,'WidthMm'+s,SizeMm.cX);
        WriteInteger(PartIni,'HeightMm'+s,SizeMm.cY);
      end;
    end;
    s:='';
    for i:=0 to LsArrDynamic(Prm.Fonts,a,CRLF)-1 do s:=StrNum(s,Length(a[i]),3)+a[i];
    WriteString(PartIni,'Fonts',s);
  end;
  PutPPDcmBreak(sPartIni,Prm);
  DelStack;
end;

procedure TGenForm.GetPPFont;
	procedure GetPPFontIni(const Prm: TPPDocRec);
  var s: string;
    function Read1(l: longint = MaxInt): string;
    begin
      AddStack('TGenForm.GetPPFont.GetPPFontIni.Read1',Self);
      result:=ExtractLeftPart(s,l+1);
      DelStack;
    end;
    function Read2(tp: TSaveType): variant;
    begin
      AddStack('TGenForm.GetPPFont.GetPPFontIni.Read2',Self);
      result:=StrToVar(Read1(SizeOfVar[tp]),tp); 
      DelStack;
    end;
  var s1: string;
  	i: longint;
  label lend;
  begin
    AddStack('TGenForm.GetPPFont.GetPPFontIni',Self);
    s:=DlmCopy(Prm.Fonts,Index+1,1,CRLF);
    if not empty(s) then begin
    	if AnsiStartsStr(UnDelim,s) then begin
      	Read1(lUnDelim); StrDeShifrSelf(s); Read2(stByte);
        result.Font.Color:=AColor[EnsureRange(Read2(stByte),low(AColor),high(AColor))];
        result.Font.Size:=Read2(stInteger);
        result.Font.Style:=TFontStyles(byte(Read2(stByte)));
        result.Font.CharSet:=Read2(stByte);
        result.Prop.AType:=Read2(stByte);
        result.Prop.Angle:=Read2(stWord);
        i:=Length(result.Prop.Dop.s); CopyMemory(@result.Prop.Dop,Pointer(s),i);
        result.Font.Name:=Copy(s,i+1,MaxInt);
      end
      else begin
        result.Font.Color:=AColor[EnsureRange(Int0(Read1(3)),low(AColor),high(AColor))];
        result.Font.Size:=Int0(Read1(3));
        result.Font.Style:=TFontStyles(byte(Int0(Read1(3))));
        s1:=Read1(lUnDelim);
        if s1=UnDelim then begin
          result.Font.CharSet:=Int0(Read1(3));
          s1:=Read1(lUnDelim);
          if s1=UnDelim then begin
            result.Prop.Dop.OnlyDig:=StrToBoolean(Read1(1));
            s1:=Read1(lUnDelim);
            if s1=UnDelim then begin
              result.Prop.Dop.RowBetween:=Int0(Read1(4));
              s1:=Read1(lUnDelim);
              if s1=UnDelim then begin
                result.Prop.Dop.WidthTextAll:=StrToBoolean(Read1(1));
                s1:=Read1(lUnDelim);
                if s1=UnDelim then begin
                  result.Prop.Dop.OnWidth:=StrToBoolean(Read1(1));
                  s1:=Read1(lUnDelim);
                  if s1=UnDelim then begin
                    result.Prop.Dop.ALine:=StrToBoolean(Read1(1));
                    s1:=Read1(lUnDelim);
                    if s1=UnDelim then begin
                      result.Prop.Angle:=Int0(Read1(3));
                      s1:=Read1(lUnDelim);
                      if s1=UnDelim then begin
                        result.Prop.AType:=TGFFontType(Int0(Read1(1)));
                        s1:=Read1(lUnDelim);
                        if s1=UnDelim then begin
                          result.Prop.Dop.PrcSpMin:=Int0(Read1(5));
                          s1:=Read1(lUnDelim);
                          if s1=UnDelim then begin
                            result.Prop.Dop.ChrFill:=StrToChar(Read1(1));
                            result.Font.Name:=Read1; goto lend;
                          end;
                        end;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
        result.Font.Name:=s1+Read1;
      end;
    end;
  lend:
    DelStack;
  end;
var tw: TWinControl;
  ts: TSchem;
begin
	AddStack('TGenForm.GetPPFont',Self);
  PointerDef(pointer(GF),Self);
  if GF.InGet then begin
  	GetPPFontIni(EdPpdPrm); result.Prop.Prim:=GF.Fonts[Index].Prop.Prim;
  end
  else result.Assign(GF.Fonts[Index]);
  GetPPFontIni(Prm);
  if GF.InGet then if Index in stFontSay then
    if ParentClass(tw,GF,TRbPanel) then if SchemName(TRbPanel(tw).Schem,ts)
    then result.Font.Assign(ts.Font2);
  DelStack;
end;

procedure FPutPPFont(var Prm: TPPDocRec; Index: byte; s: string);
var a: TArrStr;
	i: longint;
begin
	AddStack('GenForm.FPutPPFont');
  i:=LsArrDynamic(Prm.Fonts,a,CRLF);
  if i<Index+1 then begin
  	InitArr(a,i); i:=Index+1; SetLength(a,i);
  end;
  a[Index]:=s; Prm.Fonts:=ArrayAsList(a,CRLF,i);
  DelStack;
end;

class procedure TGenForm.PutPPFont;
var i: longint;
	s: string;
begin
	AddStack('TGenForm.PutPPFont');
  with Font do begin
  	SetLength(s,Length(Prop.Dop.s));
  	for i:=low(Prop.Dop.s) to high(Prop.Dop.s) do s[i+1]:=Prop.Dop.s[i];
    FPutPPFont(Prm,Index,UnDelim+StrShifr(My_pr.VarToStr(0,stByte)
      +My_pr.VarToStr(SeekColor(Font.Color),stByte)
      +My_pr.VarToStr(Font.Size,stInteger)
      +My_pr.VarToStr(byte(Font.Style),stByte)
      +My_pr.VarToStr(Font.CharSet,stByte)
      +My_pr.VarToStr(Prop.AType,stByte)
      +My_pr.VarToStr(Prop.Angle,stWord)
      +s+Font.Name));
  end;
  DelStack;
end;

class procedure TGenForm.PutPPFontDef;
begin
	AddStack('TGenForm.PutPPFontDef');
	FPutPPFont(Prm,Index,'');
  DelStack;
end;

class function TGenForm.IsPPFontDef;
var a: TArrStr;
begin
	AddStack('TGenForm.IsPPFontDef');
  result := Index>=LsArrDynamic(Prm.Fonts,a,CRLF);
  if not result then result:=empty(a[Index]);
  DelStack;
end;

// Удалить секцию из INI-файла
class procedure TGenForm.ErasePartIni;
begin
	AddStack('TGenForm.ErasePartIni');
	InitFIni[fiPPDoc].EraseSection(UpperCase(PartIni));
  DelStack;
end;

// Переименовать секцию в INI-файле
class procedure TGenForm.RenamePartIni;
var ls: TStrStrList;
	i: longint;
  PartOld,PartNew: TFileName;
begin
	AddStack('TGenForm.RenamePartIni');
	PartOld:=UpperCase(cPartOld); PartNew:=UpperCase(cPartNew);
  with InitFIni[fiPPDoc] do begin
    EraseSection(PartNew);
    if ReadSectionList(PartOld,ls) then
      for i:=0 to ls.Count-1 do WriteString(PartNew,ls[i],ls.Value[i]);
    EraseSection(PartOld);
  end;
  DelStack;
end;

{ СПИСОК ШРИФТОВ }

// Кол-во шрифтов
function TGenForm.GetFontCount;
begin
	{$IFDEF STACKALL}AddStack('TGenForm.GetFontCount',Self);{$ENDIF}
	result:=LsFont.Count;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

// Найти шрифт в списке
function TGenForm.GetFonts;
begin
	{$IFDEF STACKALL}AddStack('TGenForm.GetFonts',Self);{$ENDIF}
	if Index>=FontCount then Index:=0;
	result:=LsFont[Index];
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

// Добавить шрифт по умолчанию
procedure TGenForm.FontAddDef;
var f: TGFPackFont;
begin
	AddStack('TGenForm.FontAddDef',Self);
	if LsFont.Count=0 then begin
    f:=TGFPackFont.Create;
    try
      DefaultFont(f.Font); FontAdd(f).Prop.Prim:='нормальный';
    finally
      f.Free;
    end;
  end;
  DelStack;
end;

// Добавить шрифт
function TGenForm.FontAdd(f: TGFPackFont): TGFPackFont;
begin
	result:=FontAdd(LsFont,f);
end;

class function TGenForm.FontAdd(LsFont: TList; f: TGFPackFont): TGFPackFont;
begin
	AddStack('TGenForm.FontAdd');
  result:=TGFPackFont.Create; result.Assign(f); LsFont.Add(result);
  DelStack;
end;

// Установить шрифты из GF
procedure TGenForm.FontsAddGF;
var i: longint;
begin
	AddStack('TGenForm.FontsAddGF',Self);
  ClearFonts;
  for i:=0 to GF.FontCount-1 do FontAdd(GF.Fonts[i]);
  FontAddDef;
  DelStack;
end;

// Удалить шрифт
procedure TGenForm.FontDel;
	procedure pvCor(pv: PGFObj);
  begin
    AddStack('TGenForm.FontDel.pvCor',Self);
  	if pv.Font>Index then Dec(pv.Font);
    DelStack;
  end;
var i,j: longint;
begin
	AddStack('TGenForm.FontDel',Self);
  for i:=0 to PageCount-1 do
    for j:=0 to PgObjectCount(i)-1 do pvCor(PgObjects(i,j));
	for i:=0 to ObjectCount-1 do pvCor(PObjects[i]);
  TGFPackFont(LsFont[Index]).Free; LsFont.Delete(Index);
  DelStack;
end;

// Сменить номер шрифта
procedure TGenForm.FontCngNum;
var imin,imax: byte;
  step: TValueSign;
	procedure pvCor(pv: PGFObj);
  begin
    AddStack('TGenForm.FontCngNum.pvCor',Self);
    if pv.Font=oldInd then pv.Font:=newInd
  	else if pv.Font in [imin..imax] then Inc(pv.Font,step);
    DelStack;
  end;
var i,j: longint;
begin
	AddStack('TGenForm.FontCngNum',Self);
  i:=oldInd; j:=newInd; step:=aSign[i<j];
  while i<>j do begin
		LsFont.Exchange(i,j); Inc(j,step);
  end;
  imin:=min(oldInd,newInd); imax:=max(oldInd,newInd);
  for i:=0 to PageCount-1 do
    for j:=0 to PgObjectCount(i)-1 do pvCor(PgObjects(i,j));
  for i:=0 to ObjectCount-1 do pvCor(PObjects[i]);
  DelStack;
end;

// Есть ли идентификатор s в формулах
function TGenForm.SearchIdent;
var res: boolean;
	function AddInfo(usl: boolean; t: TGFSearchType; n: longint = 0;
  	tdw: TDWSearchType = dwsFldName; nl: longint = 0; const txt: string = '';
    tdwgf: TGFSearchType = low(TGFSearchType)): boolean;
  begin
    AddStack('TGenForm.SearchIdent.AddInfo');
    if usl then begin
      res:=true; SetLength(aInfo,Length(aInfo)+1);
      with aInfo[high(aInfo)] do begin
        TypeObj:=t; DWType:=tdw; DWGFType:=tdwgf; NumObj:=n; NumLeaf:=nl; Text:=txt; 
      end;
    end;
    result:=res and lIdent;
    DelStack;
  end;
var i,j: longint;
	v: TGFObj;
	dw: TObject;
	a: TDWSearchAInfo;
  w: TGFWinList;
  oprop: TFindProperty;
label lend;
begin
	AddStack('TGenForm.SearchIdent',Self);
  res:=false; dw:=nil; aInfo:=nil; oprop:=SetFindPropertyIdent(lIdent);
  try
    if AddInfo(FindInStr(StrAlg,s),gfsAlg) then goto lend;
    if AddInfo(FindInStr(DopAlg,s),gfsAlgDop) then goto lend;
    if AddInfo(FindInStr(MouseAlg,s),gfsAlgMouse) then goto lend;
    SaveCurLeaf;
    for i:=0 to PageCount-1 do
      for j:=0 to PgObjectCount(i)-1 do begin
        v:=PgObjects(i,j)^;
        if (v.TypeObj in [toForm,toBmp,toCalc,toGet,toSay,toCalcBmp]) or not lIdent then
          if AddInfo(FindInStr(v.Text,s),gfsObjText,j,dwsFldName,i,v.Text) then goto lend;
      end;
    for i:=0 to PageCount-1 do
      for j:=0 to PgObjectCount(i)-1 do begin
        v:=PgObjects(i,j)^;
        if (v.TypeObj in [toForm,toBmp,toCalc,toGet,toSay,toCalcBmp]) or not lIdent then begin
          if AddInfo(FindInStr(v.Ident,s),gfsObjIdent,j,dwsFldName,i,v.Ident) then goto lend;
          if AddInfo(FindInStr(v.Part,s),gfsObjPart,j,dwsFldName,i,v.Part) then goto lend;
          if AddInfo(FindInStr(v.Col,s),gfsObjCol,j,dwsFldName,i,v.Col) then goto lend;
        end;
      end;
    dw:=DataWinCreate;
    for w:=low(awWin) to high(awWin) do
      if DataWinSearchIdent(dw,awWin[w],s,a,lIdent) then
        for i:=low(a) to high(a) do
          if AddInfo(true,aGFWtoS[w],a[i].NumObj,a[i].TypeObj,a[i].NumPage,a[i].Text,a[i].GFType) then goto lend;
lend:
  finally
    if Assigned(dw) then DataWinFree;
    FindProperty:=oprop;
  end;
  result:=res;
  DelStack;
end;

// Заменить идентификатор s в формулах на s1
function TGenForm.ReplaceIdent;
var pav1: PVariant;
  procedure AlgRepl(t: TGFSearchType; var ss: string);
  begin
    AddStack('TGenForm.ReplaceIdent.AlgRepl',Self);
    if Assigned(pav) then pav1^:=AddFrom(pav^,VarArrayOf([t]));
    result[t]:=ReplaceInStr(ss,s,s1,PrRepl,pav1);
    if result[t]<0 then raise EGFReplaceIdentBreak.Create('');
    DelStack;
  end;
var fl: boolean;
	procedure pvRepl(pv: PGFObj);
    procedure spRepl(var sp: string; t: TGFSearchType);
    var st: string;
      cnt: longint;
    begin
      AddStack('TGenForm.ReplaceIdent.pvRepl.spRepl',Self);
      st:=sp;
      if Assigned(pav) then pav1^:=AddFrom(pav^,VarArrayOf([t]));
      cnt:=ReplaceInStr(st,s,s1,PrRepl,pav1);
      if cnt<0 then begin
        result[t]:=cnt; raise EGFReplaceIdentBreak.Create('');
      end;
      Inc(result[t],cnt); sp:=st;
      if cnt>0 then fl:=true;
      DelStack;
    end;
  begin
    AddStack('TGenForm.ReplaceIdent.pvRepl',Self);
    if (gfrNoOnlyFml in Opt) or (pv.TypeObj in [toForm,toBmp,toCalc,toGet,toSay,toCalcBmp]) then begin
      spRepl(pv.Text ,gfsObjText);
      spRepl(pv.Ident,gfsObjIdent);
      spRepl(pv.Part ,gfsObjPart);
      spRepl(pv.Col  ,gfsObjCol);
    end;
    DelStack;
  end;
var i,j,ost: longint;
	dw: TObject;
  w: TGFWinList;
  oprop: TFindProperty;
begin
	ost:=AddStack('TGenForm.ReplaceIdent',Self);
  oprop:=SetFindPropertyIdent(not(gfrNoIdent in Opt)); dw:=DataWinCreate;
  if Assigned(pav) then New(pav1) else pav1:=nil;
  try
    try
      AlgRepl(gfsAlg,StrAlg); AlgRepl(gfsAlgDop,DopAlg); AlgRepl(gfsAlgMouse,MouseAlg);
      result[gfsObjText]:=0; result[gfsObjIdent]:=0; result[gfsObjPart]:=0; result[gfsObjCol]:=0;
      for i:=0 to PageCount-1 do
        if i=FLeaf-1 then begin
        	fl:=false;
        	for j:=0 to ObjectCount-1 do pvRepl(PObjects[j]);
          if fl then begin
          	SaveCurLeaf; PaintAll;
          end;
        end
        else for j:=0 to PgObjectCount(i)-1 do pvRepl(PgObjects(i,j));
	    for w:=low(awWin) to high(awWin) do begin
        if Assigned(pav) then pav1^:=AddFrom(pav^,VarArrayOf([aGFWtoS[w]]));
        result[aGFWtoS[w]]:=DataWinReplaceIdent(dw,awWin[w],s,s1,Opt,PrRepl,pav1);
        if result[aGFWtoS[w]]<0 then raise EGFReplaceIdentBreak.Create('');
      end;
    except
      on EGFReplaceIdentBreak do SetStack(ost);
    end;
  finally
    DataWinFree; FindProperty:=oprop; DisposeNil(pav1);
  end;
  DelStack;
end;

// Объект в точке (X,Y)
function TGenForm.ObjInPoint;
var i,sX,sY: longint;
label lend;
begin
	AddStack('TGenForm.ObjInPoint',Self);
  sX:=nround(X/ScalePrc); sY:=nround(Y/ScalePrc);
  for i:=0 to ObjectCount-1 do begin
	  result:=PObjects[i];
    with result^ do
      if InRange(sX,GridX[Left]+1,GridX[Right]) and InRange(sY,GridY[Top]+1,GridY[Bottom]) then goto lend;
  end;
  result:=nil;
lend:
	DelStack;
end;

// Передать текст в калькулятор
procedure TGenForm.DragOver;
var pv: PGFObj;
  p: TPoint;
begin
	AddStack('TGenForm.DragOver',Self);
	inherited DragOver(Source,X,Y,State,Accept);
  if Source=Self then begin
    if (ScalePrc<>1) then sCalc:='';
    if (State=dsDragEnter) and (ScalePrc=1) and not lDrag then begin
      lDrag:=true; sCalc:=''; pv:=ObjInPoint(X,Y);
      if Assigned(pv) then
	      if pv.TypeObj in [toText,toForm,toCalc,toCalcBmp] then begin
          p.X:=X; p.Y:=Y; PaintObj1(pv,false,nil,0,PrObjDrag,@p);
        end;
    end;
    Accept := sCalc<>'';
  end;
  DelStack;
end;

procedure TGenForm.PrObjDrag;
var p: PPoint;
begin
  AddStack('TGenForm.PrObjDrag',Self);
  if sCalc='' then begin
    p:=Prm;
    if InRange(p.Y,ARect.Top,ARect.Bottom) then sCalc:=NumInStr(Text,X,p.X,CurCanvas);
  end;
  DelStack;
end;

procedure TGenForm.DoEndDrag;
begin
	AddStack('TGenForm.DoEndDrag',Self);
	inherited DoEndDrag(Target,X,Y);
  sCalc:=''; lDrag:=false;
  DelStack;
end;

procedure TGenForm.WMCalc;
begin
	AddStack('TGenForm.WMCalc',Self);
	inherited;
  if (msg.Operation=clcGet) and (sCalc<>'') then begin
		msg.ps^:=Float0(sCalc); msg.result:=1;
  end;
  DelStack;
end;

procedure TGenForm.WMPaintCtl;
begin
	AddStack('TGenForm.WMPaintCtl',Self);
  if Msg.Oper=pcmCanvas then Msg.Canvas:=Canvas;
  DelStack;
end;

procedure TGenForm.WMIntErr;
var GF: TGenForm;
  i: longint;
  pvErr: PGFObj;
begin
  AddStack('TGenForm.WMIntErr',Self);
  with msg,Prm^,lsStack do begin
    pvErr:=PGFObj(PrmShow); ControlsFree(RbScrollBox1);
    if Items.Objects[ItemIndex]=pvErr.DopObj then begin
      GF:=TGenForm.Create(Owner);
      GF.Parent:=RbScrollBox1;
      GF.State:=gsView; GF.TabStop:=true;
      GF.FontsAddGF(Self); GF.Params:=Params;
      GF.ColCount:=high(FGridX); GF.RowCount:=high(FGridY);
      GF.DestroyObjects;
      for i:=0 to ObjectCount-1 do GF.AddObj(Objects[i]);
      GF.AutoSize;
      GF.SetBounds(0,0,max(Width,GF.TmpCtrl.Left),max(Height,GF.TmpCtrl.Top));
      GF.SetSizeMm;
      GF.Width:=max(GF.Width,GF.GridX[high(GF.FGridX)]+GF.FSpot.Right+GF.LineWidth);
      GF.Height:=max(GF.Height,GF.GridY[high(GF.FGridY)]+GF.FSpot.Bottom+GF.LineWidth([gfwY]));
      GF.TmpCtrl.SetBounds(GF.GridX[pvErr.Right],GF.GridY[pvErr.Bottom],0,0);
      GF.BeforePaint;
      ProcentCtrl:=80;
      ViewCtrl:=GF.TmpCtrl;
    end;
  end;
  DelStack;
end;

procedure TGenForm.CMCursorChanged;
var P: TPoint;
begin
	AddStack('TGenForm.CMCursorChanged',Self);
  if FState=gsDesign then begin
    GetCursorPos(P);
    if FindDragTarget(P,False)=Self then Perform(WM_SETCURSOR,Handle,HTCLIENT);
  end
  else inherited;
  DelStack;
end;

procedure TGenForm.Print;
var oState: TGFState;
	i,l: longint;
  prc: Double;
begin
  AddStack('TGenForm.Print',Self);
  Params:=Params;
  with Params,Arr[CurParams] do l:=IfThen(lMirror,Width-FSpot.Left-GridX[high(FGridX)],FSpot.Left)-GridX[0];
  for i:=0 to high(FGridX) do Inc(FGridX[i].Crd,l);
  l:=FSpot.Top-GridY[0];
  for i:=0 to high(FGridY) do Inc(FGridY[i].Crd,l);
	oState:=State; State:=gsPrint;
  CurCanvas:=GGPrinter.Canvas;
  prc:=GetDeviceCaps(GGPrinter.Handle,LOGPIXELSX)/Screen.PixelsPerInch;
  l:=GetDeviceCaps(GGPrinter.Handle,PHYSICALOFFSETX);
  if lMirror then l:=-l;
  for i:=0 to high(FGridX) do GridX[i]:=max(0,nround(GridX[i]*prc)-l);
  prc:=GetDeviceCaps(GGPrinter.Handle,LOGPIXELSY)/Screen.PixelsPerInch;
  l:=GetDeviceCaps(GGPrinter.Handle,PHYSICALOFFSETY);
  for i:=0 to high(FGridY) do GridY[i]:=max(0,nround(GridY[i]*prc)-l);
  noPaint:=false; BeforePaint; State:=oState; CurCanvas:=Canvas;
  DelStack;
end;

// Найти текст
function TGenForm.FindText;
var	VsblTop: longint;
  function FindTextLeaf: boolean;
  var pv: PGFObj;
    function FindObj1(var res: boolean; ss,sl: longint): boolean;
    begin
    	AddStack('TGenForm.FindText.FindTextLeaf.FindObj1',Self);
      result:=FindInStr(ObjText(pv^),sf,@ss,@sl);
      if result then begin
        FindTextOut(FindInfo);
        SetLength(FindInfo.aObj,1); SetLength(FindInfo.aObj[0].SelStart,1); FindInfo.aObj[0].SelStart[0]:=ss;
        FindInfo.SelLength:=sl; res:=true;
      end;
      DelStack;
    end;
  var i,l,ls,ss,sl: longint;
    fl: boolean;
    s: string;
  begin
  	AddStack('TGenForm.FindText.FindTextLeaf',Self);
    if FindProperty.Direction=fndBack then FObjects.Sort(SortTopLeftDesc) else FObjects.Sort(SortTopLeft);
    result := FindProperty.Direction=fndAll; l:=0; fl:=false;
    if result then begin
      FindTextOut(FindInfo); SetLength(FindInfo.aObj,ObjectCount);
    end;
    for i:=0 to ObjectCount-1 do begin
      pv:=PObjects[i];
      if pv.TypeObj<>toText then continue;
      if result then begin
        s:=ObjText(pv^); SetLength(FindInfo.aObj[l].SelStart,Length(s) div Length(sf)); ls:=0; ss:=1; sl:=0;
        while FindInStr(s,sf,@ss,@sl) do begin
          FindInfo.aObj[l].SelStart[ls]:=ss; FindInfo.SelLength:=sl; Inc(ls);
        end;
        if ls>0 then begin
          FindInfo.aObj[l].pv:=pv; SetLength(FindInfo.aObj[l].SelStart,ls); Inc(l);
        end;
      end
      else begin
        if not fl then begin
          if Length(FindInfo.aObj)=0 then fl := GridY[pv.Top]>=VsblTop
          else begin
            if pv=FindInfo.aObj[0].pv then begin
              if FindObj1(result,FindInfo.aObj[0].SelStart[0],FindInfo.SelLength) then break;
              fl:=true; continue;
            end;
          end;
        end;
        if fl then
          if FindObj1(result,IfThen(FindProperty.Direction=fndBack,Length(ObjText(pv^))+1,1),0) then begin
            FindInfo.aObj[0].pv:=pv; break;
          end;
      end;
    end;
    if FindProperty.Direction=fndAll then SetLength(FindInfo.aObj,l);
    DelStack;
  end;
var n,i,j,lr: longint;
	n1,n2: longint;
	sc: TScrollingWinControl;
  f: TFileBuf;
  fl,onp: boolean;
  step: TValueSign;
begin
	AddStack('TGenForm.FindText',Self);
  VsblTop:=RectInScroll(Self).Top; result:=FindTextLeaf;
  if not result then begin
    n:=Leaf; lr:=IfThen(FindProperty.Direction=fndBack,n-1,PageCount-n);
    if lr>0 then begin
      VsblTop:=0; onp:=NoPaint;
      try
        NoPaint:=true; f:=TFileBuf.Create(FullNameExe(FFileName,'DTG'));
        try
          fl:=true; step:=aSign[FindProperty.Direction=fndBack]; i:=n;
          for j:=1 to lr do begin
            if WinFindSayStat(j/lr) then break;
            Inc(i,step); n1:=FPages[i-1].sv.Offset;
            f.Seek(n1,soFromBeginning);
            if i=PageCount then n2:=MaxLongInt else n2:=FPages[i].sv.Offset-n1;
            if Pos(sf,AnsiUpperCase(f.Substr(n2)))>0 then begin
              FindInfo.aObj:=nil; FindInfo.SelLength:=0; RestPage(i); result:=FindTextLeaf;
              if result then begin
                if ParentScroll(Self,sc) then begin
                  sc.VertScrollBar.Position:=0; sc.HorzScrollBar.Position:=0;
                end;
                NoPaint:=onp; PaintAll; fl:=false; break;
              end;
            end;
          end;
          if fl then
            if Leaf=n then begin
              NoPaint:=onp; PaintAll;
            end
            else RestPage(n);
        finally
          f.Free;
        end;
      finally
        NoPaint:=onp;
      end;
    end;
  end;
  DelStack;
end;

// Вывести найденный текст
procedure TGenForm.FindTextOut;
var r: TRect;
  i: longint;
begin
	AddStack('TGenForm.FindTextOut',Self);
  with FindInfo do for i:=low(aObj) to high(aObj) do with aObj[i] do begin
    r:=PaintObj1(pv,gffndSel in Opt,@SelStart,SelLength);
    if gffndScrl in Opt then begin
      TmpCtrlView(r.Right,r.Bottom); TmpCtrlView(r.Left,r.Top); Exclude(Opt,gffndScrl);
    end;
  end;
  DelStack;
end;

function TGenForm.GridLine;
begin
  AddStack('TGenForm.GridLine',Self);
  result:=Pix(lY,Params.Arr[FCurParams].GridLineWidth);
  DelStack;
end;

function TGenForm.LineWidth;
var l: Word;
begin
  AddStack('TGenForm.LineWidth',Self);
  l:=GridLine(gfwY in Opt); result:=l shr 1;
  if gfwRight in Opt then result:=l-result;
  DelStack;
end;

function TGenForm.GridObj;
begin
  AddStack('TGenForm.GridObj',Self);
  if lY
  then result:=GridY[v.Bottom]-GridY[v.Top]
  else result:=GridX[v.Right]-GridX[v.Left];
  Dec(result,GridLine(lY));
  DelStack;
end;

procedure TGenForm.SetCurPageName;
begin
  AddStack('TGenForm.SetCurPageName',Self);
  if FCurPageName<>Value then begin
    FCurPageName:=Value; FCurPagePart:='';
  end;
  DelStack;
end;

procedure TGenForm.SetCurPagePart;
begin
  AddStack('TGenForm.SetCurPagePart',Self);
  if FCurPagePart<>Value then begin
    FCurPagePart:=Value; AddFrom(aCurPagePart,lCurPagePart,Value);
  end;
  DelStack;
end;

{procedure TGenForm.SetIntervalBetwRows;
begin
  AddStack('TGenForm.SetIntervalBetwRows',Self);
  FIntervalBetwRows:=ceil(vMm/MmInInch*Screen.PixelsPerInch);
  DelStack;
end;}

procedure TGenForm.IdStrAdd;
var i: longint;
	p: PGFIdStr;
begin
  AddStack('TGenForm.IdStrAdd',Self);
  if not Assigned(IdStr) then begin
    IdStr:=TGFIdStrList.Create; IdStr.Sorted:=true; SetLength(IdStr.a,1);
  end;
  with IdStr do if IntObjFindAdd(IdStr,id,i) then p:=@a[i]
  else begin
    if Length(a)=i then SetLength(a,i shl 1);
    p:=@a[i]; p.a:=nil; p.lNewPg:=false; p.nMax:=-1;
  end;
  p.s:=s; i:=Length(p.a);
  if i<n then begin
  	SetLength(p.a,n);
    while i<n-1 do begin
    	p.a[i].pv:=nil; p.a[i].MinStr:=0; p.a[i].EmpNoFill:=false; Inc(i);
    end;
  end;
  Dec(n); p.a[n].pv:=IdStrCurPV; p.a[n].MinStr:=MinStr; p.a[n].EmpNoFill:=gfidEmpNoFill in Opt;
  IdStrCurId:=id; IdStrCurN:=n;
  if gfidHMax in Opt then p.nMax:=n;
  DelStack;
end;

procedure TGenForm.MouseInit;
var v: variant;
  i: byte;
begin
  AddStack('TGenForm.MouseInit',Self);
  aMouse:=[];
  if not empty(GFDcm.MouseAlg) then begin
    if not Assigned(InterMouse) then begin
      InterMouse:=TInter.Create(''); InterMouse.showerror:=false;
      InterMouse.GetAlgProc:=InterMouseGetAlgProc;
    end;
    InterMouse.name:='Документ '+ExtractFileWithOutExt(FFileName)+': действия для мыши';
    MouseAlg:=GFDcm.MouseAlg; InterMouse.SetProg(MouseAlg);
    InterMouse.value_types:='A';
    if InterMouse.EvalChk(v,[0]) then begin
      for i:=VarArrayLowBound(v,1) to VarArrayHighBound(v,1) do
        if InRange(v[i],low(byte),high(byte)) then Include(aMouse,byte(v[i]));
    end
    else InterShowError(InterMouse,[ieEnter]);
  end;
  DelStack;
end;

function TGenForm.MouseEval;
var i: longint;
  pv: PGFObj;
  v: variant;
  ss,n: byte;
begin
  AddStack('TGenForm.MouseEval',Self);
  result:=true;
  if (FState=gsView) and (vid in aMouse) then for i:=0 to FObjects.Count-1 do begin
    pv:=PGFObj(FObjects[i]);
    if Length(pv.Ident)>0 then
    if InRange(BvX,GridX[pv.Left],GridX[pv.Right]) then
    if InRange(BvY,GridY[pv.Top],GridY[pv.Bottom]) then begin
      ss:=byte(Shift); v:=VarArrayCreate([ShiftStateLow,ShiftStateHigh],varVariant);
      for n:=ShiftStateLow to ShiftStateHigh do begin
        v[n] := (ss and 1)<>0; ss:=ss shr 1;
      end;
      InterMouse.name:='Документ '+ExtractFileWithOutExt(FFileName)+': действия для мыши ('+nm+')';
      InterMouse.value_types:='L';
      if InterMouse.EvalChk(v,[vid,pv.Ident,v]) then result:=not v
      else if InterShowError(InterMouse)=mrCancel then Exclude(aMouse,vid);
      break;
    end;
  end;
  DelStack;
end;

procedure TGenForm.InterMouseGetAlgProc;
begin
  AddStack('TGenForm.InterMouseGetAlgProc',Self);
  Txt:=MouseAlg;
  DelStack;
end;

// Стандартные размеры в мм по формату и ориентации
class function TGenForm.GetStdSize(Frm: Byte; Orient: TPrinterOrientation): TSize;
begin
	if InRange(Frm,byte(low(aGFFrm)),byte(high(aGFFrm)))
  then result:=GetStdSize(TGFFrmList(Frm),Orient)
  else ZeroMemory(@result,SizeOf(result));
end;

class function TGenForm.GetStdSize(Frm: TGFFrmList; Orient: TPrinterOrientation): TSize;
const a: array[TGFFrmList,TPrinterOrientation] of longint =
	((297,420),(210,297),(148,210),(420,297),(297,210),(210,148),(0,0));
begin
	AddStack('TGenForm.GetStdSize');
	WinSize(result,
	  a[Frm,Orient],a[Frm,TPrinterOrientation(byte(high(Orient))-byte(Orient))]);
  DelStack;
end;

{ TGFFldSayList }
constructor TGFFldSayList.Create;
begin
  AddStack('TGFFldSayList.Create');
  inherited Create(AOwner);
  ls:=SortStrListCreate; SetLength(a,10);
  DelStack;
end;

destructor TGFFldSayList.Destroy;
var i,j,n: longint;
  pv: PGFObj;
  rv: TVarNmRec;
  nmf: string;
  r: TRecDBDef;
  fl: boolean;
  GF: TGenForm;
begin
  AddStack('TGFFldSayList.Destroy');
  GF:=pointer(Owner);
  for i:=0 to GF.ObjectCount-1 do begin
    pv:=GF.PObjects[i]; GF.InterCreate(pv);
    if pv.TypeObj in [toGet,toSay] then begin
      nmf:=TrimRight(pv.Text);
      if Pos('.',nmf)=0 then begin
        rv:=VarNmToRec(nmf);
        if TRecDBDef.SeekDWPrefix(rv[1],r) then begin
          if r.DynamicVid=0 then nmf:=r.DWRdbSeek.NameRec else nmf:=DynNmDB(r.DynamicVid);
          IncD(nmf,'.'+rv[2]);
        end
      end;
      if IntObjFind(ls,nmf,j,n) then begin
        fl := pv.TypeObj=toGet; pv.DopObj:=a[n,fl];
        if Assigned(a[n,fl]) then TPaintControl.ObjSetVisible(a[n,fl],true);
        a[n,fl]:=nil;
        if not Assigned(a[n,not fl]) then SLObjIndDel(ls,j,ProcDel);
      end;
    end;
  end;
  for j:=0 to ls.Count-1 do begin
    n:=IntObj(ls,j);
    for fl:=false to true do
      if Assigned(a[n,fl]) then TPaintControl.ObjSetVisible(a[n,fl],false);
  end;
  ls.Destroy; GF.InGetRebuild;
  inherited Destroy;
  DelStack;
end;

procedure TGFFldSayList.ProcDel;
begin
  AddStack('TGFFldSayList.ProcDel');
  a[ni]:=a[oi];
  DelStack;
end;

procedure TGFFldSayList.AddFld;
var n: longint;
begin
  AddStack('TGFFldSayList.AddFld');
  if Assigned(tf.PaintSay) then tf.PaintSay.Visible:=not Assigned(Self);
  if Assigned(Self) then begin
    n:=ls.Count;
    if Length(a)=n then SetLength(a,n shl 1);
    ls.AddObject(tf.NameRec+'.'+tf.NameRecFld,pointer(n));
    a[n,false]:=tf.PaintSay; a[n,true]:=tf;
  end;
  DelStack;
end;

{ TDcmLogCompare }
{$IFDEF NEWLOG}
type TDcmLogList = (dlogFrm,dlogGridLine,dlogSpot,dlogPrmNum,dlogPrmDate,dlogFont,
  dlogFontDop,dlogBitMap,dlogPages,dlogPage,dlogLine);

  PDcmLogRec = ^TDcmLogRec;
  TDcmLogRec = record
    v: TDcmLogList;
    agf: array[boolean] of TGenForm;
  end;

var nlogFrm,nlogSpot,nlogNum,nlogDate: longint;
  alogFrm: array of TGFParams;
  alogSpot: array of TRect;
  alogNum: array of TFmtNum;
  alogDate: array of TFmtDate;

const
  dlmBM = #31;
  dlmBMName = #30;

class function TDcmLogCompare.ListCreate;
var f: TStrBuf;
  gf: TGenForm;
  a: array[1..4] of string;
  ls: TList;
begin
  AddStack('TDcmLogCompare.ListCreate');
  result:=nil;
  if Assigned(pv) then with PDcmLogRec(pv)^ do
    case v of
      dlogFrm: begin
        if Length(alogFrm)=nlogFrm then SetLength(alogFrm,IfThen(nlogFrm=0,2,nlogFrm shl 1));
        f:=TStrBuf.CreateRead(Value);
        try
          alogFrm[nlogFrm]:=ReadParams(f,DcmLastVers); alogFrm[nlogFrm].DateTime:=false;
        finally
          f.Free;
        end;
        result:=pointer(nlogFrm); Inc(nlogFrm);
      end;
      dlogGridLine: result:=pointer(longword(StrToVar(Value,stLongWord)));
      dlogSpot: begin
        if Length(alogSpot)=nlogSpot then SetLength(alogSpot,IfThen(nlogSpot=0,2,nlogSpot shl 1));
        ListAsArray(Value,a,','); alogSpot[nlogSpot]:=Rect(Int0(a[2]),Int0(a[1]),Int0(a[4]),Int0(a[3]));
        result:=pointer(nlogSpot); Inc(nlogSpot);
      end;
      dlogPrmNum: begin
        if Length(alogNum)=nlogNum then SetLength(alogNum,IfThen(nlogNum=0,2,nlogNum shl 1));
        f:=TStrBuf.CreateRead(Value);
        try
          alogNum[nlogNum]:=ReadPrmNum(f,DcmLastVers);
        finally
          f.Free;
        end;
        result:=pointer(nlogNum); Inc(nlogNum);
      end;
      dlogPrmDate: begin
        if Length(alogDate)=nlogDate then SetLength(alogDate,IfThen(nlogDate=0,2,nlogDate shl 1));
        f:=TStrBuf.CreateRead(Value);
        try
          alogDate[nlogDate]:=ReadPrmDate(f,DcmLastVers);
        finally
          f.Free;
        end;
        result:=pointer(nlogDate); Inc(nlogDate);
      end;
      dlogFont: begin
        ls:=TList.Create; result:=ls; f:=TStrBuf.CreateRead(Value);
        try
          ReadFonts(f,DcmLastVers,ls);
        finally
          f.Free;
        end;
      end;
      dlogFontDop: result:=TStrLogCompare.ListCreate(pv,Value,lNew);
      dlogBitMap: result:=TDlmLogCompare.ListCreateDlm(Value,dlmBM);
      dlogPages: result:=pointer(lNew);
      dlogPage: result:=@agf[lNew].FPages[Int0(Value)];
      dlogLine: result:=PointerInt0(Value);
    end
  else if Value<>'' then begin
    gf:=TGenForm.Create(Application.MainForm); result:=gf;
    gf.Parent:=Application.MainForm; gf.OpenDcmStr(StrShifr(Value));
  end;
  DelStack;
end;

class procedure TDcmLogCompare.ListDestroy;
begin
  AddStack('TDcmLogCompare.ListDestroy');
  if Assigned(pv) then case PDcmLogRec(pv).v of
    dlogFrm: Dec(nlogFrm);
    dlogSpot: Dec(nlogSpot);
    dlogPrmNum: Dec(nlogNum);
    dlogPrmDate: Dec(nlogDate);
    dlogFont: TList(ls).Free;
    dlogFontDop: TStrLogCompare.ListDestroy(pv,ls);
    dlogBitMap: TDlmLogCompare.ListDestroy(pv,ls);
  end
  else TGenForm(ls).Free;
  DelStack;
end;

class function TDcmLogCompare.GetCount;
begin
  AddStack('TDcmLogCompare.GetCount');
  result:=1;
  if Assigned(pv) then with PDcmLogRec(pv)^ do
    case v of
      dlogFrm: result:=Length(alogFrm[longint(ls)].Arr);
      dlogFont: result:=TList(ls).Count;
      dlogBitMap: result:=TDlmLogCompare.GetCount(pv,ls);
      dlogPages: result:=agf[boolean(ls)].PageCount;
      dlogPage: result:=Length(PPages(ls).av);
    end
  else if not Assigned(ls) then result:=0;
  DelStack;
end;

function LogCompareStrModel(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('GenForm.LogCompareStrModel');
  with TGenForm(p).VersInfo do begin
    result:=DlmBetween(MDFile,MDName,'. ');
    if MDNSave>0 then IncD(result,Format('(%d)',[MDNSave]));
  end;
  DelStack;
end;

function LogCompareStrFrm(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('GenForm.LogCompareStrFrm');
  with TGenForm(p) do begin
    FBuf:=TStrBuf.CreateWrite(@result);
    try
      SaveParams;
    finally
      CloseDtg;
    end;
  end;
  DelStack;
end;

function LogCompareStrNFormat(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('GenForm.LogCompareStrNFormat');
  with PGFParamItem(p)^ do
    if StdFormat then result:=aGFFrm[NFormat] else result:=Format('%dx%d мм',[SizeMm.cX,SizeMm.cY]);
  DelStack;
end;

function LogCompareStrGridLine(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var mm: TWord2DWord;
begin
  AddStack('GenForm.LogCompareStrGridLine');
  with PGFParamItem(p)^,mm do begin
    w1:=GridLineMin; w2:=GridLineWidth; result:=VarToStr(dw,stLongWord);
  end;
  DelStack;
end;

function LogCompareStrDigDlm(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('GenForm.LogCompareStrDigDlm');
  with alogNum[longint(p)] do result:=IfThen(DigIsDlm,DigDlm,IfThen(logpMod in Prm.Opt,'[нет]'));
  DelStack;
end;

function LogCompareStrZeroEmp(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('GenForm.LogCompareStrZeroEmp');
  with PFmtZeroEmp(p)^ do result:=IfThen(l,s,IfThen(logpMod in Prm.Opt,'[нет]'));
  DelStack;
end;

function LogCompareStrFont(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('GenForm.LogCompareStrFont');
  with TGenForm(p) do begin
    FBuf:=TStrBuf.CreateWrite(@result);
    try
      SaveFonts;
    finally
      CloseDtg;
    end;
  end;
  DelStack;
end;

function LogCompareStrFontStyle(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
const a: array[TFontStyle] of string = ('жирный','наклонный','подчеркнутый','зачеркнутый');
var i: TFontStyle;
begin
  AddStack('GenForm.LogCompareStrFontStyle');
  result:='';
  for i:=low(a) to high(a) do if i in TGFPackFont(p).Font.Style then IncD(result,a[i]+',');
  DecLen(result);
  DelStack;
end;

function LogCompareStrColor(const Prm: TLogTrnsValPrm; Color: TColor; Default: TColor = clBlack): string;
var cl: T16Colors;
begin
  AddStack('GenForm.LogCompareStrColor');
  cl:=SeekColor(Color); result := IfThen((aColor[cl]<>Default) or (logpMod in Prm.Opt),aNmColor[cl]);
  DelStack;
end;

function LogCompareStrFontColor(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('GenForm.LogCompareStrFontColor');
  result:=LogCompareStrColor(Prm,TGFPackFont(p).Font.Color);
  DelStack;
end;

function LogCompareStrObjColor(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('GenForm.LogCompareStrObjColor');
  result:=LogCompareStrColor(Prm,AColor[PGFObj(p).Color],clWhite);
  DelStack;
end;

function LogCompareStrLineColor(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var n: byte;
begin
  AddStack('GenForm.LogCompareStrLineColor');
  n:=byte(p);
  if n>1 then result:=LogCompareStrColor(Prm,aGFLines[n].Color) else result:='';
  DelStack;
end;

function LogCompareStrFontCharSet(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
const FontCharsets: array[0..12] of TIdentMapEntry =
  ((Value: ANSI_CHARSET       ; Name: 'Западноевропейский')
  ,(Value: DEFAULT_CHARSET    ; Name: 'По умолчанию')
  ,(Value: SYMBOL_CHARSET     ; Name: 'Символьный')
  ,(Value: CHINESEBIG5_CHARSET; Name: 'Китайский')
  ,(Value: GREEK_CHARSET      ; Name: 'Греческий')
  ,(Value: TURKISH_CHARSET    ; Name: 'Турецкий')
  ,(Value: VIETNAMESE_CHARSET ; Name: 'Вьетнамский')
  ,(Value: HEBREW_CHARSET     ; Name: 'Иврит')
  ,(Value: ARABIC_CHARSET     ; Name: 'Арабский')
  ,(Value: BALTIC_CHARSET     ; Name: 'Прибалтика')
  ,(Value: RUSSIAN_CHARSET    ; Name: 'Кириллица')
  ,(Value: THAI_CHARSET       ; Name: 'Тайский')
  ,(Value: EASTEUROPE_CHARSET ; Name: 'Центральная Европа')
  );
var c: TFontCharSet;
begin
  AddStack('GenForm.LogCompareStrFontCharSet');
  c:=TGFPackFont(p).Font.Charset;
  if (c=DEFAULT_CHARSET) and not(logpMod in Prm.Opt) then result:=''
  else if not IntToIdent(c,result,FontCharsets) then
    if not CharsetToIdent(c,result) then result:=IntToStr(c);
  DelStack;
end;

function LogCompareStrFontAType(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var t: TGFFontType;
begin
  AddStack('GenForm.LogCompareStrFontAType');
  t:=TGFPackFont(p).Prop.AType;
  result:=IfThen((t<>fptNormal) or (logpMod in Prm.Opt),aGFFontType[t]);
  DelStack;
end;

function LogCompareStrFontDop(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('GenForm.LogCompareStrFontDop');
  with TGFPackFont(p).Prop do begin
    SetLength(result,1+Length(Dop.s)); result[1]:=Chr(byte(AType));
    CopyMemory(PointerStr(result,1),@Dop.s,Length(Dop.s));
  end;
  DelStack;
end;

function LogCompareStrPrcSpMin(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var i: longint;
begin
  AddStack('GenForm.LogCompareStrPrcSpMin');
  with PGFPackFontPropDop(p)^ do begin
    i:=IfThen(OnWidth,PrcSpMin); result:=LogCompareStrInt(Prm,@i,pv);
  end;
  DelStack;
end;

function LogCompareStrChrFill(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('GenForm.LogCompareStrChrFill');
  with PGFPackFontPropDop(p)^ do begin
    result:=IfThen(OnWidth,ChrFill); result:=LogCompareStrStr(Prm,@result,pv);
  end;
  DelStack;
end;

function LogCompareStrSepstrMm(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var i: longint;
begin
  AddStack('GenForm.LogCompareStrSepstrMm');
  with PGFPackFontPropDop(p)^ do begin
    i:=IfThen(MMetr,IfThen(boolean(pv),Height,Width)); result:=LogCompareStrInt(Prm,@i,pv);
  end;
  DelStack;
end;

function LogCompareStrECCLeval(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('GenForm.LogCompareStrECCLeval');
  result:=aQRCode_ECCLevel[PGFPackFontPropDop(p).qrECCLevel].nm[1];
  DelStack;
end;

function LogCompareStrBitMap(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var i: longint;
begin
  AddStack('GenForm.LogCompareStrBitMap');
  result:='';
  with TGenForm(p) do for i:=0 to lsBitMap.Count-1 do
    IncD(result,lsBitMap[i]+dlmBMName+lsBitMap.GetBM(i).Name+dlmBM);
  DecLen(result);
  DelStack;
end;

function LogCompareStrPages(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('GenForm.LogCompareStrPages');
  with TGenForm(p) do begin
    FBuf:=TStrBuf.CreateWrite(@result);
    try
      SavePages([gfsvsNoChkSum]);
    finally
      CloseDtg;
    end;
  end;
  DelStack;
end;

function LogCompareStrPin(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('GenForm.LogCompareStrPin');
  with PGFObj(p)^ do result:=IfThen((Pin<>pinTopLeft) or (logpMod in Prm.Opt),aGFPin[Pin]);
  DelStack;
end;

function LogCompareStrVOut(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('GenForm.LogCompareStrVOut');
  with PGFObj(p)^ do result:=IfThen((VOut<>voBeg) or (logpMod in Prm.Opt),aGFVOut[VOut]);
  DelStack;
end;

function LogCompareStrTypeObj(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('GenForm.LogCompareStrTypeObj');
  with PGFObj(p)^ do result:=IfThen((TypeObj<>toText) or (logpMod in Prm.Opt),aGFTypeObj[TypeObj]);
  DelStack;
end;

function LogCompareStrMMetr(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('GenForm.LogCompareStrMMetr');
  with PGFObj(p)^ do result:=IfThen(MMetr or (logpMod in Prm.Opt),aGFMMetr[MMetr]);
  DelStack;
end;

function LogCompareStrLineWidth(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var n: byte;
begin
  AddStack('GenForm.LogCompareStrLineWidth');
  n:=byte(p);
  if (n=0) and not(logpMod in Prm.Opt) then result:=''
  else if n=0 then result:='0'
  else if n=1 then result:='нет'
  else with aGFLines[n] do result:=IntToStr(Width);
  DelStack;
end;

class procedure TDcmLogCompare.GetItem;
  function StrPage(lNew: boolean; n: longint): string;
  begin
    AddStack('TDcmLogCompare.GetItem.StrPage');
    with PDcmLogRec(pv).agf[lNew] do begin
      FBuf:=TStrBuf.CreateWrite(@result);
      try
        FLeaf:=n+1; RestCurLeaf; SavePage;
      finally
        CloseDtg;
      end;
    end;
    IncL(result,IntToStr(n)+#31);
    DelStack;
  end;
  function StrObjFont(lNew: boolean; p: PGFObj): string;
  begin
    AddStack('TDcmLogCompare.GetItem.StrObjFont');
    if (p.Font=0) and not(logpMod in Prm.Opt)
    then result:=''
    else result:=PDcmLogRec(pv).agf[lNew].Fonts[p.Font].Prop.Prim;
    DelStack;
  end;
var p: TDcmLogRec;
  function BoolPrm(st: TBoolSet): string;
  var fl: boolean;
  begin
    AddStack('TDcmLogCompare.GetItem.BoolPrm');
    result:='';
    for fl:=false to true do if fl in st then IncD(result,aGFBoolPrm[fl]+',');
    DecLen(result);
    DelStack;
  end;
  function Spot(const r: TRect): string;
  begin
    AddStack('TDcmLogCompare.GetItem.Spot');
    result:=Format('%d,%d,%d,%d',[r.Top,r.Left,r.Bottom,r.Right]);
    DelStack;
  end;
  function PrmNum(const Fmt: TFmtNum; lNew: boolean): string;
  begin
    AddStack('TDcmLogCompare.GetItem.PrmNum');
    with PDcmLogRec(pv).agf[lNew] do begin
      FBuf:=TStrBuf.CreateWrite(@result);
      try
        SavePrmNum(Fmt);
      finally
        CloseDtg;
      end;
    end;
    DelStack;
  end;
  function PrmDate(const Fmt: TFmtDate; lNew: boolean): string;
  begin
    AddStack('TDcmLogCompare.GetItem.PrmDate');
    with PDcmLogRec(pv).agf[lNew] do begin
      FBuf:=TStrBuf.CreateWrite(@result);
      try
        SavePrmDate(Fmt);
      finally
        CloseDtg;
      end;
    end;
    DelStack;
  end;
const asWin: TGFWinStr = ('данных','параметров','для дополнительных действий');
var oVersInfo: TGFVersInfo;
  ko,kn: longint;
  po,pn: PGFParamItem;
  mmo,mmn: TWord2DWord;
  ln: TList;
  fo,fn: TGFPackFont;
  fdo,fdn: TGFPackFontPropDop;
  lno,lnn: boolean;
  pvo,pvn: PGFObj;
  AType: TGFFontType;
  a: array[1..2] of string;
  s: string;
  w: TGFWinList;
begin
  AddStack('TDcmLogCompare.GetItem');
  if Assigned(pv) then with PDcmLogRec(pv)^ do case v of
    dlogFrm: begin
      kn:=longint(lsn);
      if tp=clogNoKey then with agf[true] do begin
        FBuf:=TStrBuf.CreateWrite(@Prm.val);
        try
          SaveParam(alogFrm[kn],nn);
        finally
          CloseDtg;
        end;
      end
      else begin
        pn:=@alogFrm[kn].Arr[nn]; Prm.val:=pn.Name;
        if tp=clogPrn then begin
          po:=@alogFrm[longint(lso)].Arr[no];
          TStrLogCompare.AddRes(LogCompareStrNFormat,Prm,po,pn,nil,'формат',1);
          TStrLogCompare.AddRes(Prm,aGFOrient[po.Orientation],aGFOrient[pn.Orientation],nil,'направление печати',1);
          v:=dlogGridLine; AddRes(LogCompareStrGridLine,Prm,po,pn,pv,'толщина линий(1/10 мм)',1);
          TStrLogCompare.AddRes(Prm,BoolPrm(po.aBreak),BoolPrm(pn.aBreak),nil,'разбивать страницу',1);
          TStrLogCompare.AddRes(Prm,BoolPrm(po.aWidth),BoolPrm(pn.aWidth),nil,'растянуть на листе',1);
          v:=dlogSpot; AddRes(Prm,Spot(po.SpotMm),Spot(pn.SpotMm),pv,'отступы',1);
          v:=dlogPrmNum; AddRes(Prm,PrmNum(po.PrmNum,false),PrmNum(pn.PrmNum,true),pv,'формат числа',1);
          v:=dlogPrmDate; AddRes(Prm,PrmDate(po.PrmDate,false),PrmDate(pn.PrmDate,true),pv,'формат даты',1);
          v:=dlogFrm;
        end;
      end;
    end;
    dlogGridLine: begin
      mmn.dw:=longword(lsn);
      case tp of
        clogNoKey: Prm.val:=VarToStr(mmn.dw,stLongWord);
        clogPrn: begin
          mmo.dw:=longword(lso);
          TStrLogCompare.AddRes(Prm,mmo.w1,mmn.w1,'минимальная',1);
          TStrLogCompare.AddRes(Prm,mmo.w2,mmn.w2,'максимальная',1);
        end;
      end;
    end;
    dlogSpot: case tp of
      clogNoKey: Prm.val:=Spot(alogSpot[longint(lsn)]);
      clogPrn: begin
        ko:=longint(lso); kn:=longint(lsn);
        TStrLogCompare.AddRes(Prm,alogSpot[ko].Top   ,alogSpot[kn].Top   ,'сверху',1);
        TStrLogCompare.AddRes(Prm,alogSpot[ko].Left  ,alogSpot[kn].Left  ,'слева' ,1);
        TStrLogCompare.AddRes(Prm,alogSpot[ko].Bottom,alogSpot[kn].Bottom,'снизу' ,1);
        TStrLogCompare.AddRes(Prm,alogSpot[ko].Right ,alogSpot[kn].Right ,'справа',1);
      end;
    end;
    dlogPrmNum: case tp of
      clogNoKey: Prm.val:=PrmNum(alogNum[longint(lsn)],true);
      clogPrn: begin
        ko:=longint(lso); kn:=longint(lsn);
        TStrLogCompare.AddRes(Prm,alogNum[ko].FracDlm,alogNum[kn].FracDlm,nil,'разделитель целой и дробной части',1);
        TStrLogCompare.AddRes(Prm,alogNum[ko].AllCnt,alogNum[kn].AllCnt,'количество знаков',1);
        TStrLogCompare.AddRes(Prm,alogNum[ko].FracCnt,alogNum[kn].FracCnt,'количество дробных знаков',1);
        TStrLogCompare.AddRes(Prm,FracEmp2Bool(alogNum[ko].FracEmp),FracEmp2Bool(alogNum[kn].FracEmp),'выводить пустую дробую часть',1);
        TStrLogCompare.AddRes(LogCompareStrDigDlm,Prm,lso,lsn,nil,'разделитель разрядов',1);
        TStrLogCompare.AddRes(LogCompareStrZeroEmp,Prm,@alogNum[ko].ZeroEmp,@alogNum[kn].ZeroEmp,nil,'строка, заменяющая 0',1);
      end;
    end;
    dlogPrmDate: case tp of
      clogNoKey: Prm.val:=PrmDate(alogDate[longint(lsn)],true);
      clogPrn: begin
        ko:=longint(lso); kn:=longint(lsn);
        TStrLogCompare.AddRes(Prm,alogDate[ko].Dlm,alogDate[kn].Dlm,nil,'разделитель',1);
        TStrLogCompare.AddRes(Prm,alogDate[ko].NYear,alogDate[kn].NYear,'год (количество знаков)',1);
        TStrLogCompare.AddRes(Prm,alogDate[ko].MMYY,alogDate[kn].MMYY,'только месяц.год',1);
        TStrLogCompare.AddRes(LogCompareStrZeroEmp,Prm,@alogDate[ko].ZeroEmp,@alogDate[kn].ZeroEmp,nil,'строка, заменяющая пустую дату',1);
      end;
    end;
    dlogFont: begin
      ln:=lsn;
      if tp=clogNoKey then with agf[true] do begin
        FBuf:=TStrBuf.CreateWrite(@Prm.val);
        try
          SaveFont(ln,nn);
        finally
          CloseDtg;
        end;
      end
      else begin
        fn:=ln[nn]; Prm.val:=fn.Prop.Prim;
        if tp=clogPrn then begin
          fo:=TList(lso)[no];
          TStrLogCompare.AddRes(Prm,fo.Font.Name,fn.Font.Name,nil,'шрифт',1);
          TStrLogCompare.AddRes(LogCompareStrFontStyle,Prm,fo,fn,nil,'начертание',1);
          TStrLogCompare.AddRes(Prm,fo.Font.Size,fn.Font.Size,'размер',1);
          TStrLogCompare.AddRes(LogCompareStrFontColor,Prm,fo,fn,nil,'цвет',1);
          TStrLogCompare.AddRes(LogCompareStrFontCharSet,Prm,fo,fn,nil,'набор символов',1);
          TStrLogCompare.AddRes(Prm,fo.Prop.Angle,fn.Prop.Angle,'угол поворота по часовой стрелке (градусы)',1);
          TStrLogCompare.AddRes(LogCompareStrFontAType,Prm,fo,fn,nil,'вид',1);
          v:=dlogFontDop; AddRes(LogCompareStrFontDop,Prm,fo,fn,pv,'',1);
          v:=dlogFont;
        end;
      end;
    end;
    dlogFontDop: begin
      TStrLogCompare.GetItem(Prm,nil,lsn,lsn,nn,nn,clogKey);
      case tp of
        clogKey: SetLength(Prm.val,1);
        clogNoKey: Delete(Prm.val,1,1);
        clogPrn: begin
          AType:=TGFFontType(Ord(Prm.val[1]));
          CopyMemory(@fdn.s,PointerStr(Prm.val,1),Length(fdn.s));
          TStrLogCompare.GetItem(Prm,nil,lso,lso,no,no,clogKey);
          CopyMemory(@fdo.s,PointerStr(Prm.val,1),Length(fdo.s));
          Prm.val:='';
          case AType of
            fptNormal: begin
              TStrLogCompare.AddRes(Prm,fdo.OnlyDig,fdn.OnlyDig,'только цифры');
              TStrLogCompare.AddRes(Prm,fdo.WidthTextAll,fdn.WidthTextAll,'ширина по всему тексту');
              TStrLogCompare.AddRes(Prm,fdo.OnWidth,fdn.OnWidth,'границы по ширине');
              TStrLogCompare.AddRes(Prm,fdo.ALine,fdn.ALine,'разбить по полученной ширине');
              TStrLogCompare.AddRes(Prm,fdo.RowBetween,fdn.RowBetween,'интервал между строками (1/10 мм)');
              TStrLogCompare.AddRes(LogCompareStrPrcSpMin,Prm,@fdo,@fdn,nil,'увеличивать пробелы не более чем на (%)');
              TStrLogCompare.AddRes(LogCompareStrChrFill,Prm,@fdo,@fdn,nil,'заполнять справа последнюю строку символом');
            end;
            fptSepstr: begin
              TStrLogCompare.AddRes(Prm,fdo.sepstrOnlyDig,fdn.sepstrOnlyDig,'только цифры');
              TStrLogCompare.AddRes(Prm,fdo.MMetr,fdn.MMetr,'размер ячейки в мм');
              TStrLogCompare.AddRes(LogCompareStrSepstrMm,Prm,@fdo,@fdn,pointer(false),'ширина');
              TStrLogCompare.AddRes(LogCompareStrSepstrMm,Prm,@fdo,@fdn,pointer(false),'высота');
            end;
            fptBarCode: TStrLogCompare.AddRes(Prm,fdo.Koef,fdn.Koef,'увеличение размеров на (%)');
            fptQRCode: begin
              TStrLogCompare.AddRes(LogCompareStrECCLeval,Prm,@fdo,@fdn,nil,'уровень коррекции ошибок');
              TStrLogCompare.AddRes(Prm,fdo.qrModule,fdn.qrModule,'минимальный размер модуля (1/10мм)');
            end;
            fptPDF417: begin
              TStrLogCompare.AddRes(Prm,byte(fdo.pdf417ECCLevel),byte(fdn.pdf417ECCLevel),'уровень коррекции ошибок');
              TStrLogCompare.AddRes(Prm,fdo.pdf417Module,fdn.pdf417Module,'ширина модуля (1/10мм)');
              TStrLogCompare.AddRes(Prm,fdo.pdf417RowHeight,fdn.pdf417RowHeight,'отношение высоты к ширине');
            end;
          end;
        end;
      end;
    end;
    dlogBitMap: begin
      TDlmLogCompare.GetItem(Prm,nil,lsn,lsn,nn,nn,clogKey); ListAsArray(Prm.val,a,dlmBMName);
      if tp=clogPrn then begin
        TDlmLogCompare.GetItem(Prm,nil,lso,lso,no,no,clogKey); s:=DlmCopy(Prm.val,2,1,dlmBMName);
        Prm.val:=a[1]; TStrLogCompare.AddRes(Prm,s,a[2]);
      end
      else Prm.val:=a[IfThen(tp=clogKey,1,2)];
    end;
    dlogPages:
      if tp=clogKey then Prm.val:=IntToStr(nn)
      else begin
        lnn:=boolean(lsn);
        case tp of
          clogNoKey: Prm.val:=agf[lnn].PageName[nn+1]+#31+StrPage(lnn,nn);
          clogPrn: begin
            lno:=boolean(lso);
            TStrLogCompare.AddRes(Prm,agf[lno].PageName[no+1],agf[lnn].PageName[nn+1],nil,'наименование');
            v:=dlogPage; AddRes(Prm,StrPage(lno,no),StrPage(lnn,nn),pv); v:=dlogPages;
          end;
        end;
      end;
    dlogPage: begin
      pvn:=@PPages(lsn).av[nn];
      case tp of
        clogKey: Prm.val:=Format('%d,%d,%d,%d',[pvn.Top,pvn.Bottom,pvn.Left,pvn.Right]);
        clogNoKey: with agf[false] do begin
          FBuf:=TStrBuf.CreateWrite(@Prm.val);
          try
            SaveObj(pvn);
          finally
            CloseDtg;
          end;
        end;
        clogPrn: begin
          Prm.val:=Format('сверху %d, снизу %d, слева %d, справа %d',[pvn.Top,pvn.Bottom,pvn.Left,pvn.Right]);
          pvo:=@PPages(lso).av[no];
          TStrLogCompare.AddRes(Prm,aGFAlgm[pvo.Alignment],aGFAlgm[pvn.Alignment],nil,'разместить',1);
          TStrLogCompare.AddRes(LogCompareStrPin,Prm,pvo,pvn,nil,'прижать',1);
          TStrLogCompare.AddRes(LogCompareStrVOut,Prm,pvo,pvn,nil,'выводить',1);
          TStrLogCompare.AddRes(LogCompareStrObjColor,Prm,pvo,pvn,nil,'цвет',1);
          TStrLogCompare.AddRes(LogCompareStrTypeObj,Prm,pvo,pvn,nil,'тип',1);
          TStrLogCompare.AddRes(LogCompareStrMMetr,Prm,pvo,pvn,nil,'единица измерения',1);
          TStrLogCompare.AddRes(Prm,trunc(pvo.MinWidth),trunc(pvn.MinWidth),'ширина',1);
          TStrLogCompare.AddRes(Prm,trunc(pvo.MinHeight),trunc(pvn.MinHeight),'высота',1);
          TStrLogCompare.AddRes(Prm,StrObjFont(false,pvo),StrObjFont(true,pvn),nil,'шрифт',1);
          TCrlfLogCompare.AddRes(Prm,pvo.Text,pvn.Text,nil,'содержимое',1);
          TStrLogCompare.AddRes(Prm,pvo.Part,pvn.Part,nil,'раздел',1);
          TStrLogCompare.AddRes(Prm,pvo.Col,pvn.Col,nil,'колонка',1);
          TStrLogCompare.AddRes(Prm,pvo.Ident,pvn.Ident,nil,'идентификатор',1);
          v:=dlogLine;
          AddRes(Prm,IntToStr(pvo.LnTop),IntToStr(pvn.LnTop),pv,'линия сверху',1);
          AddRes(Prm,IntToStr(pvo.LnBottom),IntToStr(pvn.LnBottom),pv,'линия снизу',1);
          AddRes(Prm,IntToStr(pvo.LnLeft),IntToStr(pvn.LnLeft),pv,'линия слева',1);
          AddRes(Prm,IntToStr(pvo.LnRight),IntToStr(pvn.LnRight),pv,'линия справа',1);
          v:=dlogPage;
        end;
      end;
    end;
    dlogLine: case tp of
      clogNoKey: Prm.val:=Int2Str(lsn);
      clogPrn: begin
        TStrLogCompare.AddRes(LogCompareStrLineWidth,Prm,lso,lsn,nil,'толщина (1/10 мм)',1);
        TStrLogCompare.AddRes(LogCompareStrLineColor,Prm,lso,lsn,nil,'цвет',1);
      end;
    end;
  end
  else case tp of
    clogNoKey: with TGenForm(lsn) do begin
      oVersInfo:=VersInfo; Prm.val:=SaveDcmStr; VersInfo:=oVersInfo;
      Prm.val:=IntToStr(VersInfo.NumSave);
    end;
    clogPrn: begin
      p.agf[false]:=pointer(lso); p.agf[true]:=pointer(lsn);
      TStrLogCompare.AddRes(Prm,p.agf[false].VersInfo.Vers,p.agf[true].VersInfo.Vers,'версия');
      TStrLogCompare.AddRes(Prm,p.agf[false].VersInfo.NumSave,p.agf[true].VersInfo.NumSave,'номер сохранения');
      TStrLogCompare.AddRes(LogCompareStrModel,Prm,lso,lsn,nil,'основа');
      TStrLogCompare.AddRes(Prm,p.agf[false].Params.DateTime,p.agf[true].Params.DateTime,'выводить дату формирования');
      p.v:=dlogFrm; AddRes(LogCompareStrFrm,Prm,lso,lsn,@p,'форматы');
      p.v:=dlogFont; AddRes(LogCompareStrFont,Prm,lso,lsn,@p,'шрифты');
      TCrlfLogCompare.AddRes(Prm,p.agf[false].StrAlg,p.agf[true].StrAlg,nil,'алгоритм формирования');
      TStrLogCompare.AddRes(Prm,p.agf[false].DopAlgName,p.agf[true].DopAlgName,nil,'клавиша выполнения дополнительных действий');
      TCrlfLogCompare.AddRes(Prm,p.agf[false].DopAlg,p.agf[true].DopAlg,nil,'алгоритм дополнительных действий');
      TCrlfLogCompare.AddRes(Prm,p.agf[false].MouseAlg,p.agf[true].MouseAlg,nil,'действия для мыши');
      TEdGenFr.LoadWait;
      TDatLogCompare.AddRes(Prm,p.agf[false].awDat[false],p.agf[true].awDat[false],EdGenFr.RDocPrm,'данные');
      TDatLogCompare.AddRes(Prm,p.agf[false].awDat[true],p.agf[true].awDat[true],EdGenFr.RDocpPrm,'параметры');
      for w:=low(asWin) to high(asWin) do
        TWinLogCompare.AddRes(Prm,p.agf[false].awWin[w],p.agf[true].awWin[w],nil,'окно ввода '+asWin[w]);
      p.v:=dlogBitMap; AddRes(LogCompareStrBitMap,Prm,lso,lsn,@p,'рисунки');
      p.v:=dlogPages; AddRes(LogCompareStrPages,Prm,lso,lsn,@p,'страницы');
    end;
  end;
  DelStack;
end;

{$ELSE}
class procedure TDcmLogCompare.GetItem;
begin
  AddStack('TDcmLogCompare.GetItem');
  case tp of
    clogNoKey: inherited GetItem(Prm,pv,lso,lsn,no,nn,clogKey);
    clogPrn: Prm.val:='[изменено]';
  end;
  DelStack;
end;
{$ENDIF}

procedure Register;
begin
  RegisterComponents('OurLib',[TGenForm]);
end;

procedure UserBmpClear;
begin
  AddStack('GenForm.UserBmpClear');
  FreeAndNil(lsbmUser);
  DelStack;
end;

procedure HelpTblProc(const Name: string; var result: variant);
const aShift: array[ShiftStateLow..ShiftStateHigh] of TNamePrimStr =
  (('Shift'  ,'')
  ,('Alt'    ,'')
  ,('Ctrl'   ,'')
  ,('Левая'  ,'Левая кнопка мыши')
  ,('Правая' ,'Правая кнопка мыши')
  ,('Средняя','Средняя кнопка мыши')
  ,('Двойной','Двойной щелчок мыши')
  );
var i,j: byte;
  s: string;
begin
  AddStack('GenForm.HelpTblProc');
  if Name=''
    then result:=VarArrayOf([VarArrayOf(['КЛАВНАЖАТ','Нажатые клавиши клавиатуры/мыши'])])
  else if Name='КЛАВНАЖАТ' then begin
    j:=0; result:=VarArrayCreate([j,Length(aShift)],varVariant); s:='';
    for i:=ShiftStateLow to ShiftStateHigh do IncD(s,','+aShift[i,1]);
    s[1]:=' '; result[j]:=ArrStrToVar(['','СТРУКТУРА'+s]);
    for i:=ShiftStateLow to ShiftStateHigh do begin
      Inc(j); result[j]:=IfThen(aShift[i,2]='',aShift[i,1],aShift[i,2]);
    end;
  end;
  DelStack;
end;

initialization
	AddStack('GenForm.initialization');
  MyTypes.UserBmpClear:=UserBmpClear;
  SetPrim(tDCM,'Описания форм документов');
  SetPrim(tDCMBMP,'Переопределения рисунков');
  AddFrom(HelpTblProc);
  DelStack;
finalization
  AddStack('GenForm.finalization');
  lsbmUser.Free;
  DelStack;
end.

