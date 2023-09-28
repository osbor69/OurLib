unit FEdText;

interface

{$I LIBTEST}
uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, ExtCtrls, Menus, Graphics, StdCtrls,
    SciLexerMod, SciSupport, SciLexerMemo, ScintillaLanguageManager, ShellApi,
  MyTypes, My_pr, FRMEMPTY, Keylb, Fpanel, KeyMenu, Schem, Inter, BufFile, FFldEdit;

const
  EdMemoFontStyleHigh = Pred(high(TFontStyle));
  EdMemoFoldDrawFlagHigh = Pred(high(sciFoldDrawFlag));

type
  TCustomNoSci = class(StdCtrls.TMemo)
  private
    aKeyWord: TArrStrList;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMInsModeCng(var Message: TMessage); message WM_INSMODECNG;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSchem(var Message: TWMSchem); message WM_SCHEM;
    procedure EMSetReadOnly(var Message: TMessage); message EM_SETREADONLY;
		procedure WMCalc(var Message: TWMCalc); message WM_CALC;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
		procedure WMHelp(var Message: TWMHelp); message WM_HELP;
		procedure WMHelpFill(var Message: TWMHelpFill); message WM_HELPFILL;
  	procedure WMApplHint(var Message: TWMApplHint); message WM_APPLHINT;
		//procedure WMCngClpBrd(var Message: TMessage); message WM_CNGCLPBRD;
  protected
    procedure CreateWnd; override;
    procedure DoEnter; override;
    procedure DoExit; override;
   	procedure KeyDown(var Key: Word; Shift: TShiftState); override;
		procedure KeyPress(var Key: Char); override;
   	procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MouseMove(Shift: TShiftState; X, Y: longint); override;
   	procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
		procedure DragOver(Source: TObject; X,Y: longint; State: TDragState; var Accept: Boolean); override;
		procedure DoEndDrag(Target: TObject; X,Y: longint); override;
    procedure Change; override;
    procedure Resize; override;
  public
		procedure DragDrop(Source:TObject; X,Y:longint); override;
  end;

  TCustomSci = class(TScintilla)
  private
    //FNextClipboardViewer: HWND;
    function KeyWord0: TSciKeyWordsList;
    function Style0: TSciStyleList;
    {procedure WMChangeCBChain(var Message: TWMChangeCBChain); message WM_CHANGECBCHAIN;
    procedure WMDrawClipboard(var Message: TWMDrawClipboard); message WM_DRAWCLIPBOARD;}
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMInsModeCng(var Message: TMessage); message WM_INSMODECNG;
    procedure WMSchem(var Message: TWMSchem); message WM_SCHEM;
    procedure EMSetReadOnly(var Message: TMessage); message SCI_SETREADONLY;
		procedure WMCalc(var Message: TWMCalc); message WM_CALC;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
		procedure WMHelp(var Message: TWMHelp); message WM_HELP;
		procedure WMHelpFill(var Message: TWMHelpFill); message WM_HELPFILL;
  	procedure WMApplHint(var Message: TWMApplHint); message WM_APPLHINT;
		//procedure WMCngClpBrd(var Message: TMessage); message WM_CNGCLPBRD;
  protected
    procedure CreateWnd; override;
    procedure DoEnter; override;
    procedure DoExit; override;
   	procedure KeyDown(var Key: Word; Shift: TShiftState); override;
		procedure KeyPress(var Key: Char); override;
   	procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MouseMove(Shift: TShiftState; X, Y: longint); override;
   	procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
		procedure DragOver(Source: TObject; X,Y: longint; State: TDragState; var Accept: Boolean); override;
		procedure DoEndDrag(Target: TObject; X,Y: longint); override;
    procedure doSciModified(const position: LongInt; const modificationType: LongInt; text: PChar;
      const len,linesAdded,line,foldLevelNow,foldLevelPrev: LongInt); override;
    procedure doSciSavePointReached; override;
    procedure doSciDwellStart(const position: longint); override;
    procedure doSciDwellEnd(const position: longint); override;
    procedure doSciCalltipClick(const position: longint); override;
    procedure doSciStyleNeeded(const position : Integer); override;
    procedure doSciUpdateUI; override;
    procedure doSciUserListSelection(const listType: LongInt; text: PChar); override;
  public
		procedure DragDrop(Source:TObject; X,Y:longint); override;
    property OnClick;
    property OnDblClick;
  end;

  TEdMemoBMCrd = record
    Line,Col,LastVisibleLine: longint;
  end;

  TEdMemoFontList = 0..38;

  TEdMemoFontDef = record
    n: TEdMemoFontList;
    name: string;
  end;

  TEdMemoFontStyle = low(TFontStyle)..EdMemoFontStyleHigh;
  TEdMemoFontStyles = set of TEdMemoFontStyle;

  TEdMemoFont = record
    FontName: string;
    FontSize: longint;
    FontStylesCng: boolean;
    FontStyles: TEdMemoFontStyles;
    ForeColor,BackColor: TColor;
  end;

  TEdMemoFoldDrawFlag = low(sciFoldDrawFlag)..EdMemoFoldDrawFlagHigh;
  TEdMemoFoldDrawFlags = set of TEdMemoFoldDrawFlag;

  TEdMemoProp = record
    aFont: array[TEdMemoFontList] of TEdMemoFont;
    SelFore,SelBack,CaretFore,CaretBack,EdgeColor,BookMarkFore,BookMarkBack,
      MarkerFore,MarkerBack,FoldHi,FoldLo,ForeHlt: TColor;
    CaretWidth,EdgeColumn,MarkerType,MouseDwellTime: longint;
    AutoClose: byte;
    EdgeMode: sciEdgeType;
    LineNumber,CallTip: boolean;
    FoldDrawFlags: TEdMemoFoldDrawFlags;
    Templates: TArrStr;
  end;

  TFMemoCaret = record
  	Line,Pos,Len: longint;
  end;

  TEdMemoCng = (emoEdge,emoLineNumber,emoFolding,emoCallTip); TEdMemoCngs = set of TEdMemoCng;

  TEdMemoUserList0 = (ulsNone,ulsTempl,ulsKeyword);
  TEdMemoUserList = Succ(ulsNone)..high(TEdMemoUserList0);

  TEdMemoBMList = Ord('0')..Ord('9');

  TEdMemoUpd = record
    lMod,lReadOnly: boolean;
  end;

  TCustomEdMemo = class(TComponent)
  private
    sCalc: string;
    dCalc: double;
    lDrag,TextSetting: boolean;
    oldCaret: TFMemoCaret;
    TemplatesDef: TArrStr;
    iTmp: longint;
    nUserList: TEdMemoUserList0;
    //LsUser: array[TEdMemoUserList] of TStringList;
    LineNumberCntChar: byte;
    FBookMark: array[TEdMemoBMList] of record
      Mark: TSciMarker;
      Crd: TEdMemoBMCrd;
    end;
    nHelp,onHelp: longint;
    aHelp: PHelpArr;
    Cng: TEdMemoCngs;
    lsLink: TIntegerList;
    function GetLinesText: string;
    procedure SetLinesText(const Value: string);
    function GetBookMark(Key: TEdMemoBMList): TEdMemoBMCrd;
    procedure SetBookMark(Key: TEdMemoBMList; const Value: TEdMemoBMCrd);
    function GetWordWrapBool: boolean;
    procedure SetWordWrapBool(Value: boolean);
    function GetVisible: Boolean;
    procedure SetVisible(Value: Boolean);
    function GetEnabled: Boolean;
    procedure SetEnabled(Value: Boolean);
    function GetReadOnly: Boolean;
    procedure SetReadOnly(Value: Boolean);
    function GetModified: Boolean;
    procedure SetModified(Value: Boolean);
    function GetSelLength: longint;
    procedure SetSelLength(Value: longint);
    function GetSelStart: longint;
    procedure SetSelStart(Value: longint);
    function GetColor: TColor;
    procedure SetColor(Value: TColor);
    function GetAlign: TAlign;
    procedure SetAlign(Value: TAlign);
    function GetBevelInner: TBevelCut;
    procedure SetBevelInner(Value: TBevelCut);
    function GetBevelOuter: TBevelCut;
    procedure SetBevelOuter(Value: TBevelCut);
    function GetBorderStyle: TBorderStyle;
    procedure SetBorderStyle(Value: TBorderStyle);
    function GetCurrentLineNumber: longint;
    procedure SetCurrentLineNumber(Value: longint);
    procedure ProcKey(Key: longint; tw: TWinControl);
    procedure dePropKpProcKey(key: longint; tw: TWinControl);
    class procedure dePropFldChange(Sender: TObject; const OldVal: variant; FromShow: boolean);
    procedure FontForCanvas(Canvas: TCanvas; const f: TEdMemoFont); overload;
    procedure FontForCanvas(Font: TFont; const f: TEdMemoFont); overload;
    function StrToFont(const s: string): TEdMemoFont;
    function IniToProp(BoundEx: boolean = false): TEdMemoProp;
    procedure PropToRec(const Prop: TEdMemoProp);
    function ColorGetBrushColor(Sender: TObject; tf: TFldEdit; nColor: longint): TColor;
    function FontGetClick(Sender: TObject; lEval: boolean): string;
    procedure FontGetPaint(Sender: TObject; const ARect: TRect;	const Text: string);
    procedure FontGetSize(Sender: TObject; const Text: string; var Size: TSize);
    class procedure deFontFldChange(Sender: TObject; const OldVal: variant; FromShow: boolean);
    procedure deFontFldExit(Sender: TObject);
    procedure deFontKpProcKey(key: longint; tw: TWinControl);
    procedure BookMarkProc(Sender: TObject);
    procedure BookMarkSetProp(const Prop: TEdMemoProp; i: longint);
    procedure SetMarginWidth(const Prop: TEdMemoProp; Margin: TMargin; Visible: boolean;
      CntChar: byte = 1);
    procedure SetLineNumberMarginWidth(linesAdded: longint);
    procedure MenuItemFold;
    procedure FoldCollapse(Sender: TObject);
    procedure FoldExpand(Sender: TObject);
    procedure FoldExpandAll(Sender: TObject);
    function Color2: TColor;
    procedure FUserListSelection(const listType: TEdMemoUserList; text: PChar; lVisible: boolean);
    procedure FUserListShow(lFirst: boolean);
    procedure FUserListHide(lVisible: boolean);
    procedure MnProcUndo(Sender: TObject);
    procedure MnProcClear(Sender: TObject);
    procedure Settopindex(Value: longint);
    function PosFirstNoSpace(line: longint): longint; overload;
    procedure MnProcCopy(Sender: TObject);
    procedure MnProcDelLine(Sender: TObject);
    procedure MnProcSelAll(Sender: TObject);
    procedure MnProcUpCase(Sender: TObject);
    procedure MnProcDnCase(Sender: TObject);
    procedure MnProcCngLang(Sender: TObject);
    procedure MnProcDelTrim(Sender: TObject);
    procedure MoveCaret;
    procedure SetKeyLink(tl: TKeyLb);
    procedure EnabledItem(Key: longint = K_All);
    procedure HelpHead(const Head: string);
    procedure HelpDelEmpPrior;
		function PrFind(Sender: TControl; const sf: string): boolean;
    function LinkPos(i: longint): longint;
    function LinkLen(i: longint): longint;
    function LinkEnd(i: longint): longint;
    function PosInLink(p: longint; var i: longint): boolean;
    function LinkText(i: longint): string;
    class procedure deLinkPnlCngKey(Sender: TObject; var tb: TKeyBut);
 	protected
    MainMn: TKeyMenu;
    CurSchem: TSchem;
    PropDef: array[boolean] of TEdMemoProp;
    CngFont: array of record
      an: array of TEdMemoFontList;
      Caption: string;
    end;
    aKeywords: TArrInt;
    CallTip,Focused: boolean;
    procedure DoMoveCaret(const oldCaret,newCaret: TFMemoCaret); dynamic;
    procedure GetFromSchem; virtual;
    procedure CreateWnd;
		procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CreatingCaret;
    procedure BeforeEnter; virtual;
    procedure AfterEnter; virtual;
    procedure BeforeExit; virtual;
    procedure AfterExit; virtual;
   	procedure BeforeKeyDown(var Key: Word; Shift: TShiftState); virtual;
   	procedure AfterKeyDown(var Key: Word; Shift: TShiftState); virtual;
		procedure BeforeKeyPress(var Key: Char); virtual;
		procedure AfterKeyPress(var Key: Char); virtual;
   	procedure BeforeKeyUp(var Key: Word; Shift: TShiftState); virtual;
   	procedure AfterKeyUp(var Key: Word; Shift: TShiftState); virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: longint); virtual;
   	procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: longint); virtual;
		procedure DragOver(Source: TObject; X,Y: longint; State: TDragState; var Accept: Boolean);
		procedure DoEndDrag(Target: TObject; X,Y: longint);
    procedure SetTemplates; virtual;
    procedure MnProcCut(Sender: TObject); virtual;
    procedure MnProcPaste(Sender: TObject); virtual;
    procedure doSciModified(const position: LongInt; const modificationType: LongInt; text: PChar;
      const len,linesAdded,line,foldLevelNow,foldLevelPrev: LongInt); virtual;
    procedure doSciSavePointReached; virtual;
    procedure doSciDwellStart(const position: longint); virtual;
    procedure doSciDwellEnd(const position: longint); virtual;
    procedure doSciCalltipClick(const position: longint); virtual;
    procedure doSciStyleNeeded(const position : Integer); virtual;
    procedure doSciUpdateUI;
    procedure doSciUserListSelection(const listType: LongInt; text: PChar);
    procedure UserListCont(listType: TEdMemoUserList; Index: longint;
      var cont: string; var pSelStart: longint); virtual;
    procedure PropFontAdd(const cCaption: string; const can: array of TEdMemoFontList); overload;
    procedure PropFontAdd(const cCaption: string; n: TEdMemoFontList); overload;
    procedure PropFontAdd(const a: array of TEdMemoFontDef); overload;
    procedure PropFontAddBrack;
    function IsStyleCng(n: TEdMemoFontList): boolean;
    function NoBookMarkKey(var Key: Word; Shift: TShiftState): boolean;
    procedure BookMarkRestore;
    class procedure MNBookMarkDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
      Selected: boolean);
    function PosFirstNoSpace: longint; overload;
    function GetNextQuote: char;
    procedure BeforeShowKeyword; virtual;
    class function KeywordVisible(const KeyWord: string): boolean; virtual;
    class function AlwaysReadOnly: boolean; virtual;
    function IsMaxLength(var l: longint): boolean; virtual;
    procedure IncCng(Incl: TEdMemoCngs);
    procedure LinesBeginUpdate(var Upd: TEdMemoUpd);
    function LinesEndUpdate(Upd: TEdMemoUpd): boolean;
    procedure HelpFill; virtual;
    procedure HelpPart(const Head: string); virtual;
    procedure HelpKey(const akey: array of variant; const hint: string; const txt: string = ''; lSeek: boolean = false); overload;
    procedure HelpKey(key: longint; const hint: string; lSeek: boolean = false); overload;
    procedure HelpKey(const txt,hint: string; lSeek: boolean = false); overload;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); virtual;
    procedure WMInsModeCng(var Message: TMessage); virtual;
    procedure WMSchem(var Message: TWMSchem); virtual;
    procedure EMSetReadOnly(var Message: TMessage); virtual;
		procedure WMCalc(var Message: TWMCalc); virtual;
		procedure WMPaint(var Message: TWMPaint); virtual;
		procedure WMHelp(var Message: TWMHelp); virtual;
		procedure WMHelpFill(var Message: TWMHelpFill); virtual;
  	procedure WMApplHint(var Message: TWMApplHint); virtual;
    property BookMark[Key: TEdMemoBMList]: TEdMemoBMCrd read GetBookMark write SetBookMark;
  public
    WantTabs,NoInsDateTime: boolean;
    NoSci: TCustomNoSci;
    Sci: TCustomSci;
    PopupMenu: TPopupMenu;
    LsUser: array[TEdMemoUserList] of TStringList;
    OnMaxLength: TMaxLengthEvent;
    OnMoveCaret: procedure(const oldCaret,newCaret: TFMemoCaret) of object;
    function IsSci: boolean;
    function Control: TWinControl;
    function CurrentCol: longint;
    function CurLineStartPos: longint;
    function GetFirstVisibleLine : LongInt;
    function GetTextLength: longint;
    function GetCurrentPos: longint;
    function PositionFromLine(Line: longint): longint;
    function LineFromPosition(pos : LongInt) : LongInt;
    function GetLineEndPosition(Line: longint): longint;
    function LinesOnScreen : LongInt;
    function GetColumn(Pos: longint): longint;
    function GetCharAt(Pos: longint): byte;
    function PositionFromPoint(x,y: longint): longint;
    function GetLineCount: longint;
    procedure InsertText(pos : LongInt; const txt : string);
    function SelText: string;
    function CanPaste: boolean;
    function CanUndo: boolean;
    procedure Clear;
    function Font: TFont;
    function Lines: TStrings;
    procedure LineScroll(columns : LongInt; lines : LongInt);
    procedure ScrollCaret;
    procedure Colourise(start : LongInt; end_ : LongInt);
    function GetStyleAt(pos : LongInt) : LongInt;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: longint);
    function WordStartPosition(pos : LongInt; onlyWordCharacters : Boolean) : LongInt;
    function WordEndPosition(pos : LongInt; onlyWordCharacters : Boolean) : LongInt;
    function AutoCActive: boolean;
    function KeyWordN(n: byte): TStringList;
    function KeyWordCount: longint;
    procedure KeywordBeginUpdate; overload;
    procedure KeywordBeginUpdate(var lMod: boolean); overload;
    procedure KeywordEndUpdate; overload;
    function KeywordEndUpdate(lMod: boolean): boolean; overload;
    procedure AddTemplate(const nm: string; const cont: string = '');
		constructor CreateParent(AOwner: TComponent; AParent: TWinControl); virtual;
		destructor Destroy; override;
    procedure SetSelection(nStart: longint; nLength: longint = 0; lMoveCaret: boolean = true);
		procedure SelectLines(LnBeg,LnEnd: longint);
		procedure InsText(const s: string);
		procedure InsTextPos(const s: string; X,Y: longint);
		procedure DragDrop(Source:TObject; X,Y:longint);
    function GetText: string;
    procedure SetText(const v: string); virtual;
    procedure IncText(const d2: string);
    procedure HideSelection(Value: boolean);
		function SelProcKey(Proc: TSelProcKey): boolean;
    function MaxLengthCheck: boolean;
    procedure ExecFind(Key: longint);
    procedure ReadIdent(var crStart,crLen: longint); overload;
    procedure ReadIdent; overload;
    procedure SaveIdent(const Text: string); overload;
    procedure SaveIdent; overload;
    class procedure RestFromIni;
    class procedure SaveToIni;
    Property topindex : longint read GetFirstVisibleLine write Settopindex;
    Property Text: string read GetLinesText write SetLinesText;
    property WordWrapBool: boolean read GetWordWrapBool write SetWordWrapBool;
    property Visible: Boolean read GetVisible write SetVisible;
    property Enabled: Boolean read GetEnabled write SetEnabled;
    property ReadOnly : Boolean read GetReadOnly write SetReadOnly;
    property Modified: Boolean read GetModified write SetModified;
    property SelLength: longint read GetSelLength write SetSelLength;
    property SelStart: longint read GetSelStart write SetSelStart;
    property Color: TColor read GetColor write SetColor;
    property Align: TAlign read GetAlign write SetAlign;
    property BevelInner: TBevelCut read GetBevelInner write SetBevelInner;
    property BevelOuter: TBevelCut read GetBevelOuter write SetBevelOuter;
    property BorderStyle: TBorderStyle read GetBorderStyle write SetBorderStyle;
    property CurrentLineNumber: longint read GetCurrentLineNumber write SetCurrentLineNumber;
  end;

  TTextMemo = class(TCustomEdMemo)
  private
    FFileName: TFileName;
    FStatus: TRbStatus;
    FReadOnlyColor,FSearchInc: boolean;
    FSearchIncStr: string;
    oClose: TCloseEvent;
    PrChangeFileName: TNotifyEvent;
    procedure SetFileName(const Value: TFileName);
    procedure SetReadOnlyColor(Value: boolean);
    procedure SetSearchInc(Value: boolean = false);
    procedure SearchIncFormClose(Sender: TObject; var Action: TCloseAction);
    function SearchContinue(const Value: string; lNext: boolean): boolean;
    procedure SearchAnchor;
    procedure StatusChar;
    procedure ProcKey(key: longint; tw: TWinControl);
    class procedure deSelFldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    function deSelPnlValid(Sender: TObject): Boolean;
    procedure CngModified;
  protected
   	procedure BeforeKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure AfterExit; override;
		procedure BeforeKeyPress(var Key: Char); override;
   	procedure BeforeKeyUp(var Key: Word; Shift: TShiftState); override;
    procedure GetFromSchem; override;
    procedure SetStatus(Value: TRbStatus); virtual;
    procedure FormShow(Sender: TObject); virtual;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); virtual;
    procedure doSciModified(const position: LongInt; const modificationType: LongInt; text: PChar;
      const len,linesAdded,line,foldLevelNow,foldLevelPrev: LongInt); override;
    procedure doSciSavePointReached; override;
    procedure DoMoveCaret(const oldCaret,newCaret: TFMemoCaret); override;
    procedure HelpPart(const Head: string); override;
    procedure WMInsModeCng(var Message: TMessage); override;
  public
    property FileName: TFileName read FFileName write SetFileName;
		constructor CreateParent(AOwner: TComponent; AParent: TWinControl); override;
    procedure SaveToFile; overload;
    procedure SaveToFile(const txt: string); overload;
    procedure BeforeEnter; override;
    procedure AfterEnter; override;
    //procedure SetReadOnly(Value: Boolean); override;
    property ReadOnlyColor: boolean read FReadOnlyColor write SetReadOnlyColor;
    property Status: TRbStatus read FStatus write SetStatus;
  end;

  TInterPrmOvlList  = 1..10;
  TInterPrmOvlList0 = 0..high(TInterPrmOvlList);
  TInterPrmOvlStr   = array[TInterPrmOvlList] of string;

  PInterBrackList = ^TInterBrackList; TInterBrackList = (brckFunc,brckAtom,brckArr,brckStruct);

  TInterCtrlBrackOper = (cbrkOper,cbrkBrack);
  TInterCtrlBrack = record
    Pos: longint;
    Clos: boolean;
    Oper: TInterCtrlBrackOper;
  end;

  TInterCallTipBrackOpt = set of (ctbrBound,ctbrLast);
  TCallTipDwellType = (ctdwNormal,ctdwDebug);

  TInterMemo = class(TTextMemo)
  private
  	HelpCont: THelpContext;
    oCaption,oCaptF1: TCaption;
    oText,sCallTipView: string;
    oStart,oLen,pCallTip,CntArrElement: longint;
    oModified,oReadOnly,FSelNoUsed,WasCallTip: boolean;
    oClose: TCloseEvent;
    aVar: array[TInterVarType] of TArrVarRec;
    aCallTip: TArrStr;
    aPrm: TInterPrmOvlStr;
    lPrm: TInterPrmOvlList;
    nPrm: TInterPrmOvlList0;
    HelpFile: THelpFile;
    procedure FillTmpVar(const position: LongInt; const modificationType: LongInt;
      const len: LongInt; var lMod: boolean);
    procedure LsVarFill(VarType: TInterVarType; NoDop: boolean = false);
    procedure SetSelNoUsed(Value: boolean);
    function GetVarHelp(vt: TInterVarType; i: longint): THelpContext;
    procedure PrUnUsed(Sender: TObject; const VarName: string; var Pos: TInterVarPos);
    property SelNoUsed: boolean read FSelNoUsed write SetSelNoUsed;
    function FCallTipShow(pos: longint; nFuncPrm: TInterPrmOvlList0 = 0): string;
    procedure FCallTipSetHlt(PosStart,PosEnd: LongInt);
    procedure RightTrimComment(var s: string; var l: longint; nline: longint;
      StrAdd: PString = nil);
    function CallTipBrack(Opt: TInterCallTipBrackOpt = []; p: longint = NegDef;
      brk: PInterBrackList = nil; StrAdd: PString = nil): boolean;
    procedure CallTipBrackCng;
    function CallTipActiveBrack: boolean;
    function DebugEval(const fml: string): string;
    procedure DebugEvalSelf(var fml: string);
    function FindFunc(const kwd: string; var i: longint): boolean;
    procedure ProcKey(key: longint; tw: TWinControl);
    procedure ViewProc(key: longint; tw: TWinControl);
    function IsBrack(p: longint; lEnd: boolean): boolean;
    function CtrlBrack(var cbrk: TInterCtrlBrack): boolean;
    function StructInPos(const s: string; i: longint; var pb,pe: longint): boolean;
    class procedure ViewClose(Sender: TObject; var Action: TCloseAction);
  protected
    //procedure CreateWnd; override;
    //procedure WndDestroy; override;
   	procedure BeforeKeyDown(var Key: Word; Shift: TShiftState); override;
   	procedure AfterKeyUp(var Key: Word; Shift: TShiftState); override;
   	procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
    procedure SetTemplates; override;
    procedure doSciModified(const position: LongInt; const modificationType: LongInt; text: PChar;
      const len,linesAdded,line,foldLevelNow,foldLevelPrev: LongInt); override;
    procedure UserListCont(listType: TEdMemoUserList; Index: longint;
      var cont: string; var pSelStart: longint); override;
    procedure doSciDwellStart(const position: longint); override;
    procedure doSciDwellEnd(const position: longint); override;
    procedure doSciCalltipClick(const position: longint); override;
    procedure BeforeShowKeyword; override;
    class function KeywordVisible(const KeyWord: string): boolean; override;
    procedure DoMoveCaret(const oldCaret,newCaret: TFMemoCaret); override;
    procedure AfterExit; override;
    procedure SetStatus(Value: TRbStatus); override;
    procedure FormShow(Sender: TObject); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure HelpPart(const Head: string); override;
    procedure WMSchem(var Message: TWMSchem); override;
		procedure WMHelpFill(var Message: TWMHelpFill); override;
		procedure WMHelp(var Message: TWMHelp); override;
  public
		inter: TInter;
    CallTipDwellType: TCallTipDwellType;
    CheckOnClose: boolean;
		constructor CreateParent(AOwner: TComponent; AParent: TWinControl); override;
    destructor Destroy; override;
    procedure AfterEnter; override;
    procedure Init(const InterName: string);
    function CompileEval(leval: boolean): variant;
		class function IdentInPos(var Ident: string; const s: string; i: longint;
    	cMacro: Char; lDown: boolean; pPosEnd: PLongInt = nil): boolean;
  end;

  TSQLMemo = class(TTextMemo)
  public
		constructor CreateParent(AOwner: TComponent; AParent: TWinControl); override;
  end;

  {TXmlMemo = class(TTextMemo)
  public
		constructor CreateParent(AOwner: TComponent; AParent: TWinControl); override;
  end;}

  TClassTextMemo = class of TTextMemo;

  TEdText = class(TFormEmp)
    RbStatus1: TRbStatus;
    PnMemo: TRbPanel;
    KeyMenu1: TKeyMenu;
    procedure PnMemoResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FHelpProc: TWndMethod;
    procedure TimerScroll(Sender: TObject);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
		procedure WMHelpFill(var Message: TMessage); message WM_HELPFILL;
		class procedure SimpleFormResize(Sender: TObject);
    class procedure SimpleFormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  public
    { Public declarations }
    MemoEdit: TTextMemo;
		class function Execute(const capt: string; var txt: string;
      const dname: string = ''; dfunc: TKeyProc = nil; Opt: TEdTextOpt = []; EdClass: TClassTextMemo = nil;
      crStart: longint = 0; crLen: longint = 0; const InfStr: string = '';
      hc: THelpContext = 0; AfterShow: TNotifyEvent = nil; const MsgErrBig: string = '';
      PrEditIfError: TNotifyEvent = nil; pav: PArrVar = nil; const FileName: TFileName = '';
      BeforeShow: TNotifyEvent = nil; ChangeFileName: TNotifyEvent = nil; HelpProc: TWndMethod = nil;
      PrMaxLength: TMaxLengthEvent = nil): boolean;
  end;

const
  EdMemoHelpPartCurs     = 'Управление курсором';
  EdMemoHelpPartSel      = 'Выделение фрагмента текста';
  EdMemoHelpPartCng      = 'Изменение';
  EdMemoHelpPartClipBrd  = 'Буфер обмена';
  EdMemoHelpPartZoom     = 'Масштаб';
  EdMemoHelpPartBookMark = 'Закладки';
  EdMemoHelpPartChr      = 'Вставка спец.символов';
  EdMemoHelpPartFold     = 'Свертка';
  EdMemoHelpPartCallTip  = 'Подсказки';

var
  aEdClass: array[TEdTextType] of TClass;
  EdMemoSetTemplate: procedure(Sender: TCustomEdMemo);
  PrFldMaxLength: procedure(tf: TFldEdit; var Proc: TMaxLengthEvent);
  HelpInterMemo: function(const name: string): boolean;

procedure SendToSftp(const FileName: string; Source: TCustomBuf; EditFileName: boolean = true);
function CurEdText: TEdText;
function FldMaxLength(tf: TFldEdit): TMaxLengthEvent;

implementation

uses
  Dialogs,StrUtils,DB,Math,Variants,SciLexer,SciKeyBindings,IdHash,IdHashMessageDigest,Grids,ClipBrd,
  FIntTree,RecVal,DefEdit,Shifr,Askp,SpinGet,ChkGets,GGMReg,ER866,ButGet,StrBrowl,
    MnDrwGet,ComboGet,PnlEdit,MultiGet,DirGet;

{$R *.DFM}

type
  TFontGet = class(TButGet)
  protected
		procedure HookProc(tf: TFldEdit; var Message: TMessage); override;
  end;

	TTemplatesGet = class(TCustomGet)
  private
    class procedure sbBeforeDrawCell(Sender: TObject; ACol,ARow: Longint;
      Rect: TRect; State: TGridDrawState);
		procedure ProcKey(key: longint; tw: TWinControl);
		function deTemplFldCheck(Sender: TObject): boolean;
    class function TemplContGetClick(Sender: TObject; lEval: boolean): string;
  protected
  	sb: TStringBrowl;
    procedure CreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function MayDoKey(tf: TFldEdit; Key: longint): boolean; override;
    function AssignObj(tf: TFldEdit): boolean; override;
  end;

  PTemplInf = ^TTemplInf;
  TTemplInf = record
    cont: string;
    lUser: boolean;
  end;

  TTemplList = class(TStringList)
  private
    a: array of TTemplInf;
    constructor Create;
    procedure Fill(Sender: TCustomEdMemo; const Prop: TEdMemoProp);
    function GetObj(i: longint): PTemplInf;
  end;

  TEdMemoFontSet = set of TEdMemoFontList;

  PIdentRec = ^TIdentRec;
  TIdentRec = record
    DateCng,LastVisibleLine,SelStart,SelLength: longint;
    abm: array[TEdMemoBMList] of TEdMemoBMCrd;
  end;

  TIdentTrns = record
  	case boolean of
	  	false: (i: T4x4LongWordRecord);
      true: (s: array[0..15] of char);
  end;

  TInterBrackBoolStr = array[TInterBrackList] of TArrBoolStr;

const nDefColor = low(AColor)-1;
  MarkerTypeNone = byte(low(sciMarkerType))-1;
  sDefault = '[по умолчанию]';

  FontStyleCnt = byte(EdMemoFontStyleHigh)+1;
  FoldDrawFlagCnt = byte(EdMemoFoldDrawFlagHigh)+1;

  aclBraces = 1;
  aclQuotes = 2;

  aclCnt    = 2;

  cCRLF = #31;
  lTemplName = 20;

  aUlsKey: array[TEdMemoUserList] of longint = (K_Ctrl_J,K_Ctrl_Space);

  cHlp = #31;

  aStConst: array[1..5] of TEdMemoFontDef =
    ((n:SCE_OURLIB_NUMBER ; name:'Целые')
    ,(n:SCE_OURLIB_FLOAT  ; name:'Числа')
    ,(n:SCE_OURLIB_DATE   ; name:'Даты')
    ,(n:SCE_OURLIB_STRING ; name:'Строки с одинарными кавычками')
    ,(n:SCE_OURLIB_STRING2; name:'Строки с двойными кавычками')
    );

  sStruct='СТРУКТУРА';

  aBrack: TInterBrackBoolStr =
    (('('    ,')')
    ,('['    ,']')
    ,('{'    ,'}')
    ,(sStruct,CRLF)
    );

  aDefVar: array[0..4] of string = ('ХРАНИМЫЕ','ПЕРЕМЕННАЯ','ПЕРЕМЕННЫЕ','ПАРАМЕТР',sStruct);

  SCE_OURLIB_WORD_FINDALL = SCE_OURLIB_WORD5;
  SCE_OURLIB_WORD_LINK    = SCE_OURLIB_WORD6;

  kwFindAll  = SCE_OURLIB_WORD_FINDALL-SCE_OURLIB_WORD_FIRST;
  kwReserved = SCE_OURLIB_RESERVED-SCE_OURLIB_WORD_FIRST;

var rProp,rSel,rSFTP,rFindNum,rLink: TRecVal;
  deProp,deFont,deTempl,deSel,deSFTP,deFindNum,deLink: TDefEdit;
  ColorGet: TColorGet;
  FontGet: TFontGet;
  FontNameGet: TComboGet;
  CurEdClass: TClassTextMemo;
  setComment,setConst: TEdMemoFontSet;
  FFontGetSize: TSize;
  TemplContGet: TButGet;
  LinkAddGet: TDirGet;
  aIdent: array of TIdentRec;
  dlgOpen: TOpenDialog;
  dlgSave: TSaveDialog;
  aFunc: PArrFunc; lFunc: longint = 0;
  aOper: TArrOper; lOper: longint = 0;
  pPropEx: PBoolean;
  lsIdent: TStringListCase;
  CtrlIdent: TIdHashMessageDigest5;
  aEdText: array of TEdText;
  nEdText: longint = -1;

procedure SendToSftp;
var fn: TFileName;
  Dest: TFileBuf;
  av: TDEPrmVar;
begin
  AddStack('FEdText.SendToSftp');
  if not Assigned(deSFTP) then begin
    rSFTP:=TRecVal.Create(Application.MainForm);
    rSFTP.CreateFld('FILE',ftMemo,0,'');
    deSFTP:=TDefEdit.Create(Application.MainForm);
    deSFTP.FrmCaption:='Отправить по Интернету разработчикам'; deSFTP.NameWnd:='SFTP';
    InitArr(av);
    av[deCaption]:='Имя файла';
    av[deNameRec]:=rSFTP.NameRec;
    av[deNameRecFld]:='FILE';
    TSimpleGet.AssignGetClass(av);
    av[deAutoSel]:=true;
    av[deNoReadOnly]:=true;
    av[deWidth]:=wallDefault;
    av[deTrimLeft]:=true;
    deSFTP.CreateFld(av);
  end;
  rSFTP['FILE']:=ExtractFileName(FileName);
  if deSFTP.Execute(EditFileName) then begin
    fn:=SftpPath+SmailDirBox[true,false]+PathDelim;
    if ForceDirectories(fn) then begin
      IncD(fn,Trim(rSFTP['FILE']));
      Dest:=TFileBuf.Create(fn,true);
      try
        if Dest.Active then begin
          Dest.CopyFrom(Source); Dest.Update(true);
        end
        else MsgDlg(Dest.ErrorMessage);
      finally
        Dest.Free;
      end;
    end
    else MsgDlg(['Ошибка создания папки:',fn]);
  end;
  DelStack;
end;

function CurEdText;
begin
  AddStack('FEdText.CurEdText');
  if nEdText<0 then result:=nil else result:=aEdText[nEdText];
  DelStack;
end;

function FldMaxLength;
begin
  AddStack('FEdText.FldMaxLength');
  if tf.SeekFld then result:=tf.PrMaxLength else result:=nil;
  if Assigned(PrFldMaxLength) then PrFldMaxLength(tf,result);
  DelStack;
end;

procedure IdentInit;
begin
  AddStack('FEdText.IdentInit');
  if not Assigned(lsIdent) then begin
    lsIdent:=TStringListCase.CreateSort; CtrlIdent:=TIdHashMessageDigest5.Create;
  end;
  DelStack;
end;

function IdentRec(i: longint): PIdentRec;
begin
  AddStack('FEdText.IdentRec');
  result:=@aIdent[IntObj(lsIdent,i)];
  DelStack;
end;

function IdentFind(const s: string; DateCng: longint): PIdentRec;
var n: longint;
begin
  AddStack('FEdText.IdentFind');
  if not IntObjFindAdd(lsIdent,s,n) then 
    if Length(aIdent)=n then SetLength(aIdent,IfThen(n=0,10,n shl 1));
  result:=@aIdent[n]; result.DateCng:=DateCng;
  DelStack;
end;

function StrToTempl(const s: string): TNamePrimStr;
var i: longint;
begin
  AddStack('FEdText.StrToTempl');
  i:=PosEnd('=',s); result:=NamePrimStr(LeftStr(s,i-1),Copy(s,i+1,MaxInt));
  DelStack;
end;

function GetPropEx: boolean;
begin
  AddStack('FEdText.GetPropEx');
  if not Assigned(pPropEx) then begin
    New(pPropEx); pPropEx^:=CanPriv(PrivDesign,false);
  end;
  result:=pPropEx^;
  DelStack;
end;

procedure SetPropEx(Value: boolean);
begin
  AddStack('FEdText.SetPropEx');
  if not Assigned(pPropEx) then New(pPropEx);
  pPropEx^:=Value;
  DelStack;
end;

function GetOpenDialog: TOpenDialog;
begin
  AddStack('FEdText.GetOpenDialog');
  if not Assigned(dlgOpen) then begin
    dlgOpen:=TOpenDialog.Create(Application.MainForm);
    dlgOpen.Options:=[ofHideReadOnly,ofShowHelp,ofPathMustExist,ofFileMustExist];
  end;
  result:=dlgOpen;
  DelStack;
end;

{ TFontGet }
procedure TFontGet.HookProc;
var i: longint;
  tf1: TFldEdit;
begin
  AddStack('TFontGet.HookProc',Self);
  inherited HookProc(tf,Message);
  if Message.Msg=WM_SCHEM then for i:=0 to deProp.FldCount-1 do begin
    tf1:=deProp.FldEdit[i];
    if tf1.curget=Self then begin
      if tf1=tf then FFontGetSize.cX:=-1;
      break;
    end;
  end;
  DelStack;
end;

{ TTemplatesGet }
procedure TTemplatesGet.CreateObj;
var si: TStrBrInfZn;
begin
	AddStack('TTemplatesGet.CreateObj',Self);
  DestroyObj(tf); tf.Schem:='Browl';
  sb:=TStringBrowl.Create(tf);
  with sb do begin
    Parent:=tf;
    si:=InfoCol[0];
    CopyFrom(si.aName,'Наименование'); si.Alignment:=taLeftJustify; si.LenData:=lTemplName; InfoCol[0]:=si;
    si.aName[0]:='Содержимое'; si.lMax:=true; InfoCol[1]:=si;
    KeyDblClick:=K_F5; OnBeforeDrawCell:=sbBeforeDrawCell;
  end;
  DelStack;
end;

procedure TTemplatesGet.PaintObj;
begin
	AddStack('TTemplatesGet.PaintObj',Self);
  if AssignObj(tf) then begin
  	sb.SetBounds(BevelFld,BevelFld,tf.Width-BevelFld2,tf.Height-BevelFld2); sb.WidthCols;
  end;
  DelStack;
end;

function TTemplatesGet.GetValue;
var i: longint;
begin
	AddStack('TTemplatesGet.GetValue',Self);
  result:='';
  if AssignObj(tf) then begin
  	for i:=1 to sb.RowCount-1 do
    	if empty(sb.Cells[0,i]) then break
      else IncD(result,Bool2Str(sb,0,i)+sb.Cells[0,i]+'='+sb.Cells[1,i]+CRLF);
    DecLen(result,lCRLF);
  end;
  DelStack;
end;

procedure TTemplatesGet.SetValue;
var a: TArrStr;
	a1: TNamePrimStr;
  orow,i,l: longint;
  otl: TGridCoord;
begin
	AddStack('TTemplatesGet.SetValue',Self);
  if AssignObj(tf) then begin
  	orow:=sb.Row; otl:=sb.TopLeft; sb.Init; l:=LsArrDynamic(v,a,CRLF);
    if l>0 then begin
    	sb.RowCount:=l+1;
      for i:=1 to l do begin
        sb.Objects[0,i]:=pointer(StrToBoolean(a[i-1][1]));
        a1:=StrToTempl(Copy(a[i-1],2,MaxInt)); sb.Cells[0,i]:=a1[1]; sb.Cells[1,i]:=a1[2];
      end;
    end;
    sb.Row:=EnsureRange(orow,1,sb.RowCount-1); sb.TopLeft:=otl;
  end;
  DelStack;
end;

procedure TTemplatesGet.DoEnter;
var tl: TKeyLb;
begin
	AddStack('TTemplatesGet.DoEnter',Self);
  inherited DoEnter(tf);
	if AssignObj(tf) then GetParentForm(tf).ActiveControl:=sb;
  if FormKeyLb(tf,tl) then with tl do begin
  	SetKey(K_F4,'Скопировать','',ProcKey,'templatesget',kmList);
  	SetKey(K_F5,'Редактировать','',ProcKey,'templatesget',kmList);
  	SetKey(K_F7,'Добавить','',ProcKey,'templatesget',kmList);
  	SetKey(K_F8,'Удалить','',ProcKey,'templatesget',kmList);
    ReDrw;
  end;
  DelStack;
end;

procedure TTemplatesGet.DoExit;
var tl: TKeyLb;
begin
	AddStack('TTemplatesGet.DoExit',Self);
  inherited DoExit(tf);
  if FormKeyLb(tf,tl) then with tl do begin
  	DelKey(K_All,'templatesget'); ReDrw;
  end;
  DelStack;
end;

procedure TTemplatesGet.ProcKey;
	function InitEd(const Capt: string): boolean;
  var av: TDEPrmVar;
  begin
    AddStack('TTemplatesGet.ProcKey.InitEd',Self);
    if not Assigned(deTempl) then begin
      TemplContGet:=TButGet.Create(Application.MainForm); TemplContGet.VName:='TemplCont';
    	deTempl:=TDefEdit.Create(Application.MainForm);
      with deTempl do begin
      	NameWnd:='TemplatesGet'; InitArr(av);

        av[deCaption]:='Наименование';
        av[deNameRec]:=rProp.NameRec;
        av[deNameRecFld]:='TEMPLNAME';
        TSimpleGet.AssignGetClass(av);
        av[deCharCase]:=Succ(ecUpperCase);
        av[deAutoSel]:=true;
        av[deNoReadOnly]:=true;
        av[deTrimLeft]:=true;
        CreateFld(av);

        av[deCaption]:='';
        av[deNameRecFld]:='TEMPLCONT';
        TemplContGet.AssignGet(av);
        av[deMask]:=ButPrm2Mask('Содержание');
        av[deCharCase]:=Succ(ecNormal);
        av[deWidth]:=wallDefault;
        av[deHeight]:=-1;
        av[deTrimLeft]:=false;
        CreateFld(av);
      end;
    end;
    if Key in [K_F4,K_F5] then begin
      rProp['TemplName']:=sb.Cells[0,sb.Row]; rProp['TemplCont']:=StrTran(sb.Cells[1,sb.Row],cCRLF,CRLF);
    end
    else begin
      rProp['TemplName']:=''; rProp['TemplCont']:='';
    end;
    deTempl.OnFldCheck:=deTemplFldCheck;
    TemplContGet.OnClick:=TemplContGetClick;
    result:=deTempl.Execute([IfThen(Key=K_F5,sb.Row)],Capt).Saved;
    DelStack;
  end;
var j: longint;
  procedure Move(step: TValueSign; r: longint = NegDef);
  var ro: longint;
  begin
    AddStack('TTemplatesGet.ProcKey.Move',Self);
    ReplNegSelf(r,sb.Row);
    while r<>j do begin
      ro:=r+step; sb.Rows[r].Text:=sb.Rows[ro].Text; sb.Objects[0,r]:=sb.Objects[0,ro]; r:=ro;
    end;
    DelStack;
  end;
	procedure RowRead;
  begin
    AddStack('TTemplatesGet.ProcKey.RowRead',Self);
    sb.Objects[0,j]:=ObjectTrue; sb.Cells[0,j]:=TrimRight(rProp['TemplName']);
    sb.Cells[1,j]:=StrTran(TrimRight(rProp['TemplCont']),CRLF,cCRLF);
    sb.Row:=j;
    DelStack;
  end;
var i: longint;
  s: string;
begin
	AddStack('TTemplatesGet.ProcKey',Self);
  if not empty(sb.Cells[0,sb.FixedRows]) or (Key=K_F7) then
    if Key in [K_F4,K_F7] then begin
      if InitEd('Добавить шаблон') then begin
        j:=sb.FixedRows;
        if not empty(sb.Cells[0,j]) then begin
          sb.IncRowCount; s:=TrimRight(rProp['TemplName']);
          while j<sb.RowCount-1 do
            if sb.Cells[0,j]>s then break else Inc(j);
          Move(-1,sb.RowCount-1);
        end;
        RowRead;
      end;
    end
    else if sb.BoolObj(sb.Row) then case Key of
      K_F5: if InitEd('Редактировать шаблон') then begin
        j:=sb.FixedRows; s:=TrimRight(rProp['TemplName']);
        while j<sb.RowCount do
          if sb.Cells[0,j]>s then break else Inc(j);
        if j=sb.Row+1 then j:=sb.Row // остался на месте
        else if j=sb.RowCount then begin // на посл.строку
          Move(1); Dec(j);
        end
        else if j<sb.Row then Move(-1)   // переместился выше
        else begin                       // переместился ниже
          Dec(j); Move(1);
        end;
        RowRead;
      end;
      K_F8: if Ask(amsDel) then begin
        j:=sb.Row;
        if sb.RowCount=sb.FixedRows+1 then sb.Init
        else begin
          for i:=j+1 to sb.RowCount-1 do sb.Rows[i-1].Assign(sb.Rows[i]);
          sb.IncRowCount(-1);
        end;
        sb.Row:=min(j,sb.RowCount-1);
      end;
    end;
  DelStack;
end;

function TTemplatesGet.deTemplFldCheck;
var s: string;
	i: longint;
begin
  AddStack('TTemplatesGet.deTemplFldCheck',Self);
  if not NoEmpCheck(Sender,'TEMPLNAME',result) then if result then begin
  	s:=TrimRight(TFldEdit(Sender).VarValue);
    for i:=1 to Length(s) do
      if not IsChrWord(s[i]) then begin
        meserr('Некорректный символ: '+s[i]); result:=false; break;
      end;
    if result then for i:=1 to sb.RowCount-1 do
      if (i<>deTempl.Params[0]) and (sb.Cells[0,i]=s) then begin
        meserr('Шаблон с таким наименованием уже есть.'); result:=false; break;
      end;
  end;
  DelStack;
end;

class function TTemplatesGet.TemplContGetClick;
var tf: TFldEdit;
begin
  AddStack('TTemplatesGet.TemplContGetClick');
  tf:=pointer(Sender); result:=tf.Value;
  if lEval then
    if TEdText.Execute('Содержимое шаблона',result,'',nil,[edtxtNoChkFml],CurEdClass) then tf.Value:=result;
  DelStack;
end;

function TTemplatesGet.MayDoKey;
begin
	AddStack('TTemplatesGet.MayDoKey',Self);
  result := inherited MayDoKey(tf,Key);
  if AssignObj(tf) then  result:=not(((Key=K_Down) and (sb.Row<sb.RowCount-1))
  	or ((Key=K_Up) and (sb.Row>sb.FixedRows)));
  DelStack;
end;

function TTemplatesGet.AssignObj;
begin
	AddStack('TTemplatesGet.AssignObj',Self);
  if inherited AssignObj(tf) and (tf.ComponentCount=1)
  then result:=IsClass(tf.Components[0],TStringBrowl,pointer(sb))
  else begin
    sb:=nil; result:=false;
  end;
  DelStack;
end;

class procedure TTemplatesGet.sbBeforeDrawCell;
begin
  AddStack('TTemplatesGet.sbBeforeDrawCell');
  with TStringBrowl(Sender) do
    if not BoolObj(ARow) and ((State=[]) or (gdSelected in State)) then
      if State=[] then Canvas.Brush.Color:=FixedColor else Canvas.Font.Color:=FixedColor;
  DelStack;
end;

{ TTemplList }
constructor TTemplList.Create;
begin
  AddStack('TTemplList.Create');
  Sorted:=true; SetLength(a,10);
  DelStack;
end;

procedure TTemplList.Fill;
  procedure AddFromArr(const sa: array of string; lUser: boolean);
  var i,n: longint;
    a1: TNamePrimStr;
  begin
  	AddStack('TTemplList.Fill.AddFromArr');
    for i:=low(sa) to high(sa) do if not empty(sa[i]) then begin
      a1:=StrToTempl(sa[i]);
      if not IntObjFindAdd(Self,a1[1],n) then begin
        if Length(a)=n then SetLength(a,n shl 1);
        a[n].cont:=a1[2]; a[n].lUser:=lUser;
      end;
    end;
    DelStack;
  end;
begin
  AddStack('TTemplList.Fill');
  BeginUpdate; Clear;
  AddFromArr(Sender.TemplatesDef,false);
  AddFromArr(Prop.Templates,true);
  EndUpdate;
  DelStack;
end;

function TTemplList.GetObj;
begin
  AddStack('TTemplList.GetObj');
  result:=@a[IntObj(Self,i)];
  DelStack;
end;

{ TCustomNoSci }
procedure TCustomNoSci.WMGetDlgCode;
begin
  inherited; TCustomEdMemo(Owner).WMGetDlgCode(Message);
end;

procedure TCustomNoSci.WMInsModeCng;
begin
  inherited; TCustomEdMemo(Owner).WMInsModeCng(Message);
end;

procedure TCustomNoSci.WMSetFocus;
begin
  inherited; TCustomEdMemo(Owner).CreatingCaret;
end;

procedure TCustomNoSci.WMSchem;
begin
  TCustomEdMemo(Owner).WMSchem(Message);
end;

procedure TCustomNoSci.EMSetReadOnly;
begin
	inherited; TCustomEdMemo(Owner).EMSetReadOnly(Message);
end;

procedure TCustomNoSci.WMCalc;
begin
  inherited; TCustomEdMemo(Owner).WMCalc(Message);
end;

procedure TCustomNoSci.WMPaint;
begin
  inherited; TCustomEdMemo(Owner).WMPaint(Message);
end;

procedure TCustomNoSci.WMHelp;
begin
  TCustomEdMemo(Owner).WMHelp(Message);
end;

procedure TCustomNoSci.WMHelpFill;
begin
  TCustomEdMemo(Owner).WMHelpFill(Message);
end;

procedure TCustomNoSci.WMApplHint;
begin
  TCustomEdMemo(Owner).WMApplHint(Message);
end;

{procedure TCustomNoSci.WMCngClpBrd;
begin
  TCustomEdMemo(Owner).EnabledItem(K_Ctrl_V);
end;}

procedure TCustomNoSci.Change;
begin
  inherited Change; TCustomEdMemo(Owner).doSciModified(0,SC_MODEVENTMASKALL,nil,0,0,0,0,0);
end;

procedure TCustomNoSci.Resize;
begin
  inherited Resize; TCustomEdMemo(Owner).CreatingCaret;
end;

procedure TCustomNoSci.CreateWnd;
begin
  inherited CreateWnd; TCustomEdMemo(Owner).CreateWnd;
end;

procedure TCustomNoSci.DoEnter;
begin
  if not IsCalculator then with TCustomEdMemo(Owner) do begin
    BeforeEnter; inherited DoEnter; AfterEnter;
  end;
end;

procedure TCustomNoSci.DoExit;
begin
  if not IsCalculator then with TCustomEdMemo(Owner) do begin
    BeforeExit; inherited DoExit; AfterExit;
  end;
end;

procedure TCustomNoSci.KeyDown;
begin
  with TCustomEdMemo(Owner) do begin
    BeforeKeyDown(Key,Shift); inherited KeyDown(Key,Shift); AfterKeyDown(Key,Shift);
  end;
end;

procedure TCustomNoSci.KeyPress;
begin
  with TCustomEdMemo(Owner) do begin
    BeforeKeyPress(Key); inherited KeyPress(Key); AfterKeyPress(Key);
  end;
end;

procedure TCustomNoSci.KeyUp;
begin
  with TCustomEdMemo(Owner) do begin
    BeforeKeyUp(Key,Shift); inherited KeyUp(Key,Shift); AfterKeyUp(Key,Shift);
  end;
end;

procedure TCustomNoSci.MouseMove;
begin
  inherited MouseMove(Shift,X,Y); TCustomEdMemo(Owner).MouseMove(Shift,X,Y);
end;

procedure TCustomNoSci.MouseUp;
begin
  inherited MouseUp(Button,Shift,X,Y); TCustomEdMemo(Owner).MouseUp(Button,Shift,X,Y);
end;

procedure TCustomNoSci.DragOver;
begin
  inherited DragOver(Source,X,Y,State,Accept); TCustomEdMemo(Owner).DragOver(Source,X,Y,State,Accept);
end;

procedure TCustomNoSci.DoEndDrag;
begin
  inherited DoEndDrag(Target,X,Y); TCustomEdMemo(Owner).DoEndDrag(Target,X,Y);
end;

procedure TCustomNoSci.DragDrop;
begin
  inherited DragDrop(Source,X,Y); TCustomEdMemo(Owner).DragDrop(Source,X,Y);
end;


{ TCustomSci }
{procedure TCustomSci.WMChangeCBChain;
begin
  AddStack('TCustomSci.WMChangeCBChain',Self);
  inherited;
  Message.Result:=0;
  if Message.Remove=FNextClipboardViewer then FNextClipboardViewer:=Message.Next
  else SendMessage(FNextClipboardViewer,WM_CHANGECBCHAIN,Message.Remove,Message.Next);
  DelStack;
end;

procedure TCustomSci.WMDrawClipboard;
begin
  AddStack('TCustomSci.WMDrawClipboard',Self);
  inherited;
  try
    TCustomEdMemo(Owner).EnabledItem(K_Ctrl_V);
  finally
    SendMessage(FNextClipboardViewer,WM_DRAWCLIPBOARD,0,0);
  end;
  DelStack;
end;}

procedure TCustomSci.WMGetDlgCode;
begin
  inherited; TCustomEdMemo(Owner).WMGetDlgCode(Message);
end;

procedure TCustomSci.WMInsModeCng;
begin
  inherited; TCustomEdMemo(Owner).WMInsModeCng(Message);
end;

procedure TCustomSci.WMSchem;
begin
  TCustomEdMemo(Owner).WMSchem(Message);
end;

procedure TCustomSci.EMSetReadOnly;
begin
	inherited; TCustomEdMemo(Owner).EMSetReadOnly(Message);
end;

procedure TCustomSci.WMCalc;
begin
  inherited; TCustomEdMemo(Owner).WMCalc(Message);
end;

procedure TCustomSci.WMPaint;
begin
  inherited; TCustomEdMemo(Owner).WMPaint(Message);
end;

procedure TCustomSci.WMHelp;
begin
  TCustomEdMemo(Owner).WMHelp(Message);
end;

procedure TCustomSci.WMHelpFill;
begin
  TCustomEdMemo(Owner).WMHelpFill(Message);
end;

procedure TCustomSci.WMApplHint;
begin
  TCustomEdMemo(Owner).WMApplHint(Message);
end;

{procedure TCustomSci.WMCngClpBrd;
begin
  TCustomEdMemo(Owner).EnabledItem(K_Ctrl_V);
end;}

procedure TCustomSci.doSciModified;
begin
  inherited doSciModified(position,modificationType,text,len,linesAdded,line,foldLevelNow,foldLevelPrev);
  TCustomEdMemo(Owner).doSciModified(position,modificationType,text,len,linesAdded,line,foldLevelNow,foldLevelPrev);
end;

procedure TCustomSci.doSciSavePointReached;
begin
  inherited doSciSavePointReached; TCustomEdMemo(Owner).doSciSavePointReached;
end;

procedure TCustomSci.doSciDwellStart;
begin
  inherited doSciDwellStart(position); TCustomEdMemo(Owner).doSciDwellStart(position);
end;

procedure TCustomSci.doSciDwellEnd;
begin
  TCustomEdMemo(Owner).doSciDwellEnd(position); inherited doSciDwellEnd(position);
end;

procedure TCustomSci.doSciCalltipClick;
begin
  inherited doSciCalltipClick(position); TCustomEdMemo(Owner).doSciCalltipClick(position);
end;

procedure TCustomSci.doSciUpdateUI;
begin
  TCustomEdMemo(Owner).doSciUpdateUI; inherited doSciUpdateUI;
end;

procedure TCustomSci.doSciUserListSelection;
begin
  TCustomEdMemo(Owner).doSciUserListSelection(listType,text); inherited doSciUserListSelection(listType,text);
end;

procedure TCustomSci.doSciStyleNeeded;
begin
  inherited doSciStyleNeeded(position); TCustomEdMemo(Owner).doSciStyleNeeded(position);
end;

procedure TCustomSci.CreateWnd;
begin
  inherited CreateWnd; TCustomEdMemo(Owner).CreateWnd;
end;

procedure TCustomSci.DoEnter;
begin
  if not IsCalculator then with TCustomEdMemo(Owner) do begin
    BeforeEnter; inherited DoEnter; AfterEnter;
  end;
end;

procedure TCustomSci.DoExit;
begin
  if not IsCalculator then with TCustomEdMemo(Owner) do begin
    BeforeExit; inherited DoExit; AfterExit;
  end;
end;

procedure TCustomSci.KeyDown;
begin
  with TCustomEdMemo(Owner) do begin
    BeforeKeyDown(Key,Shift); inherited KeyDown(Key,Shift); AfterKeyDown(Key,Shift);
  end;
end;

procedure TCustomSci.KeyPress;
begin
  AddStack('TCustomSci.KeyPress',Self);
  with TCustomEdMemo(Owner) do begin
    BeforeKeyPress(Key); inherited KeyPress(Key); AfterKeyPress(Key);
  end;
  DelStack;
end;

procedure TCustomSci.KeyUp;
begin
  with TCustomEdMemo(Owner) do begin
    BeforeKeyUp(Key,Shift); inherited KeyUp(Key,Shift); AfterKeyUp(Key,Shift);
  end;
end;

procedure TCustomSci.MouseMove;
begin
  inherited MouseMove(Shift,X,Y); TCustomEdMemo(Owner).MouseMove(Shift,X,Y);
end;

procedure TCustomSci.MouseUp;
begin
  inherited MouseUp(Button,Shift,X,Y); TCustomEdMemo(Owner).MouseUp(Button,Shift,X,Y);
end;

procedure TCustomSci.DragOver;
begin
  inherited DragOver(Source,X,Y,State,Accept); TCustomEdMemo(Owner).DragOver(Source,X,Y,State,Accept);
end;

procedure TCustomSci.DoEndDrag;
begin
  inherited DoEndDrag(Target,X,Y); TCustomEdMemo(Owner).DoEndDrag(Target,X,Y);
end;

procedure TCustomSci.DragDrop;
begin
  inherited DragDrop(Source,X,Y); TCustomEdMemo(Owner).DragDrop(Source,X,Y);
end;

function TCustomSci.KeyWord0;
begin
  result:=LanguageManager.LanguageList[0].Keywords;
end;

function TCustomSci.Style0;
begin
  result:=LanguageManager.LanguageList[0].Styles;
end;

{ TCustomEdMemo }
constructor TCustomEdMemo.CreateParent;
  procedure KeyCmd(Key,Mode: word; Command: Longint);
  var cmd: TSciKeyCommand;
  begin
  	AddStack('TCustomEdMemo.CreateParent.KeyCmd',Self);
    with Sci.KeyCommands do begin
      cmd:=FindShortCut(SciKeyToShortCut(SciKey(Key,Mode)));
      if Assigned(cmd) then cmd.Command:=Command else AddCommandKey(Key,Mode,Command);
    end;
    DelStack;
  end;
  procedure MnCrt(const ACaption: string; Key: Word; Shift: TShiftState;
    AOnClick: TNotifyEvent);
  var sc: TShortCut;
    mn: TMenuItem;
  begin
  	AddStack('TCustomEdMemo.CreateParent.MnCrt',Self);
    sc:=ShortCut(Key,Shift); mn:=NewItem(ACaption,sc,false,true,AOnClick,0,'');
    PopupMenu.Items.Add(mn); mn.Tag:=sc;
    DelStack;
  end;
var i: byte;
  fl: boolean;
  uls: TEdMemoUserList;
begin
	AddStack('TCustomEdMemo.CreateParent',Self);
	Inherited Create(AOwner);
  if PswdPrm<>nil then if PswdPrm.NoSciLexer then SciLexerFree;
  if scmod=0 then begin
    NoSci:=TCustomNoSci.Create(Self); NoSci.ScrollBars:=ssBoth;
  end
  else Sci:=TCustomSci.Create(Self);
  Control.Parent:=AParent;
  WantTabs:=true; IncD(Control,[],[csSetCaption]);
  //WordChars :='_'+sci_alphachars+sci_numericchars+sci_accentedchars;
  oldCaret.Line:=0; oldCaret.Pos:=0; oldCaret.Len:=0;
  if IsSci then with Sci do begin
    LayoutCache:=sciCachePage;
    FoldMarkers.MarkerType:=sciMarkCustom;
    KeyCommands.BeginUpdate;
    KeyCmd(Ord('T'),SCI_CTRL,SCI_DELWORDRIGHT);
    KeyCmd(Ord('Z'),SCI_CSHIFT,SCI_REDO);
    KeyCommands.EndUpdate;
  end;
  Control.perform(WM_INSMODECNG,0,0);
  for fl:=false to true do with PropDef[fl] do begin
    for i:=low(aFont) to high(aFont) do with aFont[i] do begin
      FontName:=''; FontSize:=0; FontStylesCng:=false; FontStyles:=[];
      ForeColor:=clDefault; BackColor:=clDefault;
    end;
    SelFore:=clDefault; SelBack:=clDefault;
    CaretWidth:=3; CaretFore:=clDefault; CaretBack:=clDefault;
    AutoClose:=0;
    EdgeMode:=sciEdgeNone; EdgeColumn:=80; EdgeColor:=clDefault;
    LineNumber:=false; BookMarkFore:=clDefault; BookMarkBack:=clLime;
    MarkerType:=MarkerTypeNone; MarkerFore:=clDefault; MarkerBack:=clDefault;
    FoldHi:=clDefault; FoldLo:=clDefault; FoldDrawFlags:=[sciBelowIfNotExpanded];
    with aFont[STYLE_CALLTIP] do begin
      ForeColor:=clInfoText; BackColor:=clInfoBk;
    end;
    aFont[SCE_OURLIB_WORD_FINDALL].BackColor:=clAqua;
    with aFont[SCE_OURLIB_WORD_LINK] do begin
      ForeColor:=clGreen; FontStylesCng:=true; Include(FontStyles,fsUnderline);
    end;
    ForeHlt:=clDefault; MouseDwellTime:=SC_TIME_FOREVER; CallTip:=false;
    Templates:=nil;
  end;
  CngFont:=nil; Cng:=[]; aKeywords:=nil;
  if IsSci then with Sci do begin
    Style0.BeginUpdate;
    for i:=low(TEdMemoFontList) to high(TEdMemoFontList) do Style0.Add.StyleNumber:=i;
    Style0.EndUpdate;
    KeywordBeginUpdate;
    for i:=0 to 20 do Keyword0.Add.KeywordListNumber:=i;
    KeywordEndUpdate;
  end
  else with NoSci do begin
    SetLength(aKeyWord,21);
    for i:=low(aKeyWord) to high(aKeyWord) do aKeyWord[i]:=TStringList.Create;
  end;
  for i:=low(FBookMark) to high(FBookMark) do FBookMark[i].Crd.Col:=NegDef;
  SetLength(TemplatesDef,10); iTmp:=0; SetTemplates;
  if Assigned(EdMemoSetTemplate) then EdMemoSetTemplate(Self);
  SetLength(TemplatesDef,iTmp);
  for uls:=low(LsUser) to high(LsUser) do
    if uls=ulsTempl then LsUser[uls]:=TTemplList.Create else LsUser[uls]:=SortStrListCreate;
  if IsSci then with Sci do begin
    CallTipUseStyle(0); UsePopup(false);
  end;
  PopupMenu:=TPopupMenu.Create(Self);
  with PopupMenu,Items do begin
    MnCrt('Отменить',Word('Z'),[ssCtrl],MnProcUndo);
    Add(Menus.NewLine);
    MnCrt('Вырезать',Word('X'),[ssCtrl],MnProcCut);
    MnCrt('Копировать',Word('C'),[ssCtrl],MnProcCopy);
    MnCrt('Вставить',Word('V'),[ssCtrl],MnProcPaste);
    MnCrt('Удалить',vk_Delete,[],MnProcClear);
    Add(Menus.NewLine);
    MnCrt('Выделить всё',Word('A'),[ssCtrl],MnProcSelAll);
  end;
  if IsSci then begin
    Sci.PopupMenu:=PopupMenu; Sci.LanguageManager.LanguageList[0].Lexer:='ourlib';
  end
  else NoSci.PopupMenu:=PopupMenu;
  PropFontAdd('Выделение результатов поиска',SCE_OURLIB_WORD_FINDALL);
  if IsSci then begin
    PropFontAdd('Ссылки',SCE_OURLIB_WORD_LINK);
    lsLink:=TIntegerList.Create;
  end;
  KeywordBeginUpdate;
  KeywordN(kwReserved).Add(StrNum('s0=',SCE_OURLIB_WORD_FINDALL-SCE_OURLIB_WORD_USER_FIRST+1));
  KeywordEndUpdate;
  DelStack;
end;

procedure TCustomEdMemo.CreateWnd;
begin
	AddStack('TCustomSci.CreateWnd',Self);
  SeekKeyMenu(Control,MainMn);
  DelStack;
end;

procedure TCustomEdMemo.Notification;
begin
  AddStack('TCustomEdMemo.Notification',Self);
  SeekKeyMenu(Control,MainMn,AComponent,Operation);
  DelStack;
end;

destructor TCustomEdMemo.Destroy;
var i: longint;
  uls: TEdMemoUserList;
begin
  AddStack('TCustomEdMemo.Destroy',Self);
  for i:=low(FBookMark) to high(FBookMark) do FBookMark[i].Mark.Free;
  for uls:=low(LsUser) to high(LsUser) do LsUser[uls].Free;
  lsLink.Free;
  inherited Destroy;
  DelStack;
end;

function TCustomEdMemo.Control;
begin
  result:=IfThen(IsSci,Sci,NoSci);
end;

function TCustomEdMemo.IsSci;
begin
  result := Sci<>nil;
end;

function TCustomEdMemo.GetVisible;
begin
  if IsSci then result:=Sci.Visible else result:=NoSci.Visible;
end;

procedure TCustomEdMemo.SetVisible;
begin
  if IsSci then Sci.Visible:=Value else NoSci.Visible:=Value;
end;

function TCustomEdMemo.GetEnabled;
begin
  if IsSci then result:=Sci.Enabled else result:=NoSci.Enabled;
end;

procedure TCustomEdMemo.SetEnabled;
begin
  if IsSci then Sci.Enabled:=Value else NoSci.Enabled:=Value;
end;

function TCustomEdMemo.GetReadOnly;
begin
  if IsSci then result:=Sci.ReadOnly else result:=NoSci.ReadOnly;
end;

procedure TCustomEdMemo.SetReadOnly;
var i,l,j: longint;
  a: array of record
    lSort: boolean;
    ao: TArrObject;
  end;
  ls: TStringList;
begin
  AddStack('TCustomEdMemo.SetReadOnly',Self);
  if IsSci then begin
    l:=KeyWordCount; SetLength(a,l);
    for i:=0 to l-1 do begin
      ls:=KeywordN(i);
      if Assigned(ls) then with a[i],ls do begin
        lSort:=Sorted; j:=Count; SetLength(ao,j);
        for j:=0 to j-1 do ao[j]:=Objects[j];
      end;
    end;
    Sci.ReadOnly:=Value;
    for i:=0 to l-1 do begin
      ls:=KeywordN(i);
      if Assigned(ls) then with a[i],ls do begin
        Sorted:=lSort;
        for j:=0 to Count-1 do Objects[j]:=ao[j];
      end;
    end;
  end
  else NoSci.ReadOnly:=Value;
  DelStack;
end;

function TCustomEdMemo.GetModified;
begin
  if IsSci then result:=Sci.Modified else result:=NoSci.Modified;
end;

procedure TCustomEdMemo.SetModified;
begin
  if IsSci then Sci.Modified:=Value else NoSci.Modified:=Value;
end;

function TCustomEdMemo.GetSelLength;
begin
  if IsSci then result:=Sci.SelLength else result:=NoSci.SelLength;
end;

procedure TCustomEdMemo.SetSelLength;
begin
  if IsSci then Sci.SelLength:=Value else NoSci.SelLength:=Value;
end;

function TCustomEdMemo.GetSelStart;
begin
  if IsSci then result:=Sci.SelStart else result:=NoSci.SelStart;
end;

procedure TCustomEdMemo.SetSelStart;
begin
  if IsSci then Sci.SelStart:=Value else NoSci.SelStart:=Value;
end;

function TCustomEdMemo.GetColor;
begin
  if IsSci then result:=Sci.Color else result:=NoSci.Color;
end;

procedure TCustomEdMemo.SetColor;
begin
  if IsSci then Sci.Color:=Value else NoSci.Color:=Value;
end;

function TCustomEdMemo.GetAlign;
begin
  result:=Control.Align;
end;

procedure TCustomEdMemo.SetAlign;
begin
  Control.Align:=Value;
end;

function TCustomEdMemo.GetBevelInner;
begin
  if IsSci then result:=Sci.BevelInner else result:=NoSci.BevelInner;
end;

procedure TCustomEdMemo.SetBevelInner;
begin
  if IsSci then Sci.BevelInner:=Value else NoSci.BevelInner:=Value;
end;

function TCustomEdMemo.GetBevelOuter;
begin
  if IsSci then result:=Sci.BevelOuter else result:=NoSci.BevelOuter;
end;

procedure TCustomEdMemo.SetBevelOuter;
begin
  if IsSci then Sci.BevelOuter:=Value else NoSci.BevelOuter:=Value;
end;

function TCustomEdMemo.GetBorderStyle;
begin
  if IsSci then result:=Sci.BorderStyle else result:=NoSci.BorderStyle;
end;

procedure TCustomEdMemo.SetBorderStyle;
begin
  if IsSci then Sci.BorderStyle:=Value else NoSci.BorderStyle:=Value;
end;

function TCustomEdMemo.GetFirstVisibleLine;
begin
  AddStack('TCustomEdMemo.GetFirstVisibleLine',Self);
  if IsSci
  then result:=Sci.GetFirstVisibleLine
  else result:=NoSci.perform(EM_GETFIRSTVISIBLELINE,0,0);
  DelStack;
end;

function TCustomEdMemo.GetTextLength;
begin
  if IsSci then result:=Sci.GetTextLength else result:=Length(NoSci.Text);
end;

function TCustomEdMemo.SelText;
begin
  if IsSci then result:=Sci.SelText else result:=NoSci.SelText;
end;

function TCustomEdMemo.CanPaste;
begin
  if IsSci then result:=Sci.CanPaste else result:=not NoSci.ReadOnly;
end;

function TCustomEdMemo.CanUndo;
begin
  if IsSci then result:=Sci.CanUndo else result:=NoSci.CanUndo;
end;

procedure TCustomEdMemo.Clear;
begin
  if IsSci then Sci.Clear else NoSci.perform(WM_KEYDOWN,vk_Delete,1);
end;

function TCustomEdMemo.Font;
begin
  if IsSci then result:=Sci.Font else result:=NoSci.Font;
end;

function TCustomEdMemo.Lines;
begin
  if IsSci then result:=Sci.Lines else result:=NoSci.Lines;
end;

function TCustomEdMemo.GetCurrentLineNumber;
begin
  AddStack('TCustomEdMemo.GetCurrentLineNumber',Self);
  if IsSci then result:=Sci.GetCurrentLineNumber else result:=NoSci.CaretPos.Y;
  DelStack;
end;

procedure TCustomEdMemo.SetCurrentLineNumber;
begin
  AddStack('TCustomEdMemo.SetCurrentLineNumber',Self);
  if IsSci then Sci.GotoLine(Value) else SetSelection(PositionFromLine(Value));
  DelStack;
end;

function TCustomEdMemo.GetCurrentPos;
begin
  if IsSci then result:=Sci.GetCurrentPos else with NoSci do result:=SelStart+SelLength;
end;

function TCustomEdMemo.PositionFromLine;
begin
  AddStack('TCustomEdMemo.PositionFromLine',Self);
  if IsSci then result:=Sci.PositionFromLine(Line) else result:=NoSci.Perform(EM_LINEINDEX,Line,0);
  DelStack;
end;

function TCustomEdMemo.LineFromPosition;
begin
  if IsSci then result:=Sci.LineFromPosition(Pos) else result:=NoSci.perform(EM_LINEFROMCHAR,pos,0);
end;

function TCustomEdMemo.GetLineEndPosition;
begin
  AddStack('TCustomEdMemo.GetLineEndPosition',Self);
  if IsSci then result:=Sci.GetLineEndPosition(Line)
  else with NoSci do result:=PositionFromLine(Line)+Length(Lines[Line]);
  DelStack;
end;

function TCustomEdMemo.LinesOnScreen;
var c: TCanvas;
begin
  AddStack('TCustomEdMemo.LinesOnScreen',Self);
  if IsSci then result:=Sci.LinesOnScreen
  else with NoSci do begin
    c:=GetParentForm(NoSci).Canvas; c.Font.Assign(Font); result:=Height div CanvasMaxH(c);
  end;
  DelStack;
end;

function TCustomEdMemo.GetColumn;
begin
  AddStack('TCustomEdMemo.GetColumn',Self);
  if IsSci then result:=Sci.GetColumn(Pos) else result:=Pos-PositionFromLine(LineFromPosition(Pos));
  DelStack;
end;

function TCustomEdMemo.GetCharAt;
begin
  if IsSci then result:=Sci.GetCharAt(Pos) else result:=Ord(StrToChar(Copy(NoSci.Text,Pos+1,1)));
end;

function TCustomEdMemo.PositionFromPoint;
begin
  if IsSci
  then result:=Sci.PositionFromPoint(x,y)
  else result:=Word(NoSci.Perform(EM_CHARFROMPOS,0,MAKELPARAM(x,y)));
end;

function TCustomEdMemo.GetLineCount;
begin
  if IsSci then result:=Sci.GetLineCount else result:=NoSci.perform(EM_GETLINECOUNT,0,0);
end;

procedure TCustomEdMemo.InsertText;
var i: longint;
begin
  if IsSci then Sci.InsertText(pos,PChar(txt))
  else for i:=1 to Length(txt) do Control.Perform(WM_CHAR,Ord(txt[i]),1);
end;

procedure TCustomEdMemo.LineScroll;
begin
  if IsSci then Sci.LineScroll(columns,lines) else NoSci.perform(EM_LINESCROLL,columns,lines);
end;

procedure TCustomEdMemo.ScrollCaret;
begin
  if IsSci then Sci.ScrollCaret else NoSci.perform(EM_SCROLLCARET,0,0);
end;

procedure TCustomEdMemo.Colourise;
begin
  if IsSci then Sci.Colourise(start,end_);
end;

function TCustomEdMemo.GetStyleAt;
begin
  if IsSci then result:=Sci.GetStyleAt(pos) else result:=0;
end;

procedure TCustomEdMemo.SetBounds;
begin
  Control.SetBounds(ALeft, ATop, AWidth, AHeight);
end;

function TCustomEdMemo.WordStartPosition;
var s: string;
  l: longint;
begin
  AddStack('TCustomEdMemo.WordStartPosition',Self);
  if IsSci then result:=Sci.WordStartPosition(pos,onlyWordCharacters)
  else begin
    s:=Text; l:=Length(s);
    if InRange(pos,1,l) then if IsChrWord(s[pos]) then onlyWordCharacters:=true;
    while InRange(pos,1,l) and (IsChrWord(s[pos])=onlyWordCharacters) do Dec(pos);
    result:=pos;
  end;
  DelStack;
end;

function TCustomEdMemo.WordEndPosition;
var s: string;
  l: longint;
begin
  AddStack('TCustomEdMemo.WordEndPosition',Self);
  if IsSci then result:=Sci.WordEndPosition(pos,onlyWordCharacters)
  else begin
    s:=Text; l:=Length(s);
    if InRange(pos+1,1,l) then if IsChrWord(s[pos+1]) then onlyWordCharacters:=true;
    while InRange(pos+1,1,l) and (IsChrWord(s[pos+1])=onlyWordCharacters) do Inc(pos);
    result:=pos;
  end;
  DelStack;
end;

function TCustomEdMemo.AutoCActive;
begin
  AddStack('TCustomEdMemo.AutoCActive',Self);
  if IsSci then result:=Sci.AutoCActive else result:=false;
  DelStack;
end;

procedure TCustomEdMemo.SetTemplates;
begin
end;

procedure TCustomEdMemo.AddTemplate;
begin
  AddStack('TCustomEdMemo.AddTemplate',Self);
  if Length(TemplatesDef)=iTmp then SetLength(TemplatesDef,iTmp shl 1);
  TemplatesDef[iTmp]:=nm+'='+cont; Inc(iTmp);
  DelStack;
end;

procedure TCustomEdMemo.FontForCanvas(Canvas: TCanvas; const f: TEdMemoFont);
begin
  FontForCanvas(Canvas.Font,f);
end;

procedure TCustomEdMemo.FontForCanvas(Font: TFont; const f: TEdMemoFont);
begin
  AddStack('TCustomEdMemo.FontForCanvas',Self);
  if Assigned(CurSchem) then Font.Assign(CurSchem.Font1);
  if not empty(f.FontName) then Font.Name:=f.FontName;
  if f.FontSize>0 then Font.Size:=f.FontSize;
  if f.FontStylesCng then Font.Style:=f.FontStyles else FontStyle(Font,false,[fsStrikeOut]);
  if f.ForeColor<>clDefault then Font.Color:=f.ForeColor;
  DelStack;
end;

function TCustomEdMemo.KeyWordN;
begin
  if IsSci then result:=pointer(Sci.KeyWord0[n].Keywords) else result:=NoSci.aKeyWord[n]
end;

function TCustomEdMemo.KeyWordCount;
begin
  if IsSci then result:=Sci.KeyWord0.Count else result:=Length(NoSci.aKeyWord)
end;

function DefColor(cl,clDef: TColor): TColor;
begin
  AddStack('FEdText.DefColor');
  result:=IfThen(cl=clDefault,clDef,cl);
  DelStack;
end;

procedure TCustomEdMemo.BookMarkSetProp;
begin
  AddStack('TCustomEdMemo.BookMarkSetProp',Self);
  with FBookMark[i] do if Assigned(Mark) then with Mark do begin
    ForeColor:=DefColor(Prop.BookMarkFore,Font.Color);
    BackColor:=DefColor(Prop.BookMarkBack,Color);
  end;
  DelStack;
end;

procedure TCustomEdMemo.SetMarginWidth;
var cnv: TCanvas;
begin
  AddStack('TCustomEdMemo.SetMarginWidth',Self);
  if Visible then begin
    cnv:=GetParentForm(Control).Canvas; FontForCanvas(cnv,Prop.aFont[STYLE_LINENUMBER]);
    Margin.Width:=cnv.TextWidth(StringOfChar('0',CntChar))+6;
  end
  else Margin.Width:=0;
  DelStack;
end;

procedure TCustomEdMemo.SetLineNumberMarginWidth;
var l: byte;
  lBound: boolean;
begin
  AddStack('TCustomEdMemo.SetLineNumberMarginWidth',Self);
  with Sci do if LineNumberCntChar=0 then Gutter0.Width:=0
  else begin
    l:=LenIntStr(Lines.Count+linesAdded);
    if l>LineNumberCntChar then begin
      LineNumberCntChar:=l; lBound:=true;
    end
    else lBound := linesAdded=0;
    if lBound then SetMarginWidth(IniToProp,Gutter0,true,LineNumberCntChar);
  end;
  DelStack;
end;

function TCustomEdMemo.Color2;
begin
  AddStack('TCustomEdMemo.Color2',Self);
  result:=CurSchem.IfThenColor(dColor2,clBtnFace);
  DelStack;
end;

function CngDefColor(const nmf: string): TColor;
const
  a: array[0..3] of record
    nmf: string;
    cl: TColor;
  end =
  ((nmf:'SELFORE'  ; cl:clHighLightText)
  ,(nmf:'SELBACK'  ; cl:clHighLight)
  ,(nmf:'EDGECOLOR'; cl:clSilver)
  ,(nmf:'FOREHLT'  ; cl:clRed)
  );
var i: byte;
begin
  AddStack('FEdText.CngDefColor');
  result:=clDefault;
  for i:=low(a) to high(a) do
    if nmf=a[i].nmf then begin
      result:=a[i].cl; break;
    end;
  DelStack;
end;

function DefColorNmf(cl: TColor; const nmf: string): TColor;
begin
  AddStack('FEdText.DefColorNmf');
  result:=DefColor(cl,CngDefColor(nmf));
  DelStack;
end;

procedure TCustomEdMemo.WMSchem;
var Prop: TEdMemoProp;
  f: TEdMemoFont;
  i: longint;
  fl: boolean;
  uls: TEdMemoUserList;
begin
	AddStack('TCustomSci.WMSchem',Self);
  CurSchem:=Message.Schem; GetFromSchem; Prop:=IniToProp;
  if IsSci then with Sci do begin
    Colors.SelFore:=DefColorNmf(Prop.SelFore,'SELFORE');
    Colors.SelBack:=DefColorNmf(Prop.SelBack,'SELBACK');
    Caret.LineVisible := Prop.CaretBack<>clDefault;
    Caret.Width:=Prop.CaretWidth;
    Caret.ForeColor:=DefColor(Prop.CaretFore,Font.Color);
    Caret.LineBackColor:=Prop.CaretBack;
    AutoCloseBraces := Prop.AutoClose and aclBraces > 0;
    AutoCloseQuotes := Prop.AutoClose and aclQuotes > 0;
    EdgeMode:=Prop.EdgeMode;
    EdgeColumn:=Prop.EdgeColumn;
    EdgeColor:=DefColorNmf(Prop.EdgeColor,'EDGECOLOR');
    LineNumberCntChar:=IfThen(Prop.LineNumber,1); SetLineNumberMarginWidth(0);
    if Prop.MarkerType=MarkerTypeNone then Folding:=Folding-[foldFold]
    else begin
      Colors.MarkerFore:=DefColor(Prop.MarkerFore,Color);
      Colors.MarkerBack:=DefColor(Prop.MarkerBack,Font.Color);
      Colors.FoldHi:=DefColor(Prop.FoldHi,Color2);
      Colors.FoldLo:=DefColor(Prop.FoldLo,Color2);
      FoldMarkers.MarkerType:=sciMarkerType(Prop.MarkerType);
      if FoldMarkers.MarkerType=sciMarkCircle then begin
        FoldMarkers.FoldOpenMid.MarkerType:=sciMCircleMinusConnected;
        FoldMarkers.FoldEnd.MarkerType:=sciMCirclePlusConnected;
      end;
      FoldDrawFlags:=Prop.FoldDrawFlags;
      Folding:=Folding+[foldFold];
    end;
    MenuItemFold;
    CallTipSetForeHlt(DefColorNmf(Prop.ForeHlt,'FOREHLT'));
    MouseDwellTime:=Prop.MouseDwellTime;
    CallTip:=Prop.CallTip;
    Style0.BeginUpdate;
    for i:=0 to min(high(Prop.aFont),Style0.Count-1) do begin
      f:=Prop.aFont[i];
      Style0[i].FontName:=IfThen(empty(f.FontName),Font.Name,f.FontName);
      Style0[i].FontSize:=IfThen(empty(f.FontSize),Font.Size,f.FontSize);
      Style0[i].FontStyles:=IfThen(f.FontStylesCng,f.FontStyles,Font.Style);
      Style0[i].ForeColor:=DefColor(f.ForeColor,Font.Color);
      Style0[i].BackColor:=DefColor(f.BackColor,IfThen(i=STYLE_LINENUMBER,Color2,Color));
    end;
    Style0.EndUpdate;
    BraceHilite := IsStyleCng(STYLE_BRACELIGHT) or IsStyleCng(STYLE_BRACEBAD);
    fl:=false;
    for i:=low(FBookMark) to high(FBookMark) do begin
      BookMarkSetProp(Prop,i);
      if FBookMark[i].Crd.Col<>NegDef then fl:=true;
    end;
    SetMarginWidth(Prop,Gutter1,fl);
    //Colourise(0,GetTextLength);
  end;
  for uls:=low(LsUser) to high(LsUser) do
    if LsUser[uls] is TTemplList then TTemplList(LsUser[uls]).Fill(Self,Prop);
  if Focused then begin
    BeforeExit; AfterExit; BeforeEnter; AfterEnter;
  end;
  DelStack;
end;

procedure TCustomEdMemo.GetFromSchem;
begin
  AddStack('TCustomEdMemo.GetFromSchem',Self);
  if Assigned(CurSchem) then begin
    if IsSci then Sci.Color:=CurSchem.Color1 else NoSci.Color:=CurSchem.Color1;
    Font.Assign(CurSchem.Font1);
  end;
  DelStack;
end;

procedure TCustomEdMemo.EMSetReadOnly;
begin
	AddStack('TCustomSci.EMSetReadOnly',Self);
	inherited;
  EnabledItem;
  DelStack;
end;

procedure TCustomEdMemo.EnabledItem;
const a: array[1..14] of longint = (K_Del,K_Ctrl_Up,K_Ctrl_Down,K_Ctrl_A,K_Ctrl_C,K_Ctrl_L,K_Ctrl_V,K_Ctrl_X,
  K_Ctrl_Y,K_Ctrl_Z,K_Alt_Left,K_Alt_Right,K_Alt_A,K_Alt_F8);
var i: longint;
  Opt: TKeyMenuHideItem;
  wKey: Word;
  Shift: TShiftState;
begin
  AddStack('TCustomEdMemo.EnabledItem',Self);
  if Assigned(MainMn) then
    if Key=K_All then for i:=low(a) to high(a) do EnabledItem(a[i])
    else begin
      Opt:=[];
      case Key of
        K_Del:
          if ReadOnly then Include(Opt,kmnDisabled);
        K_Ctrl_Up,K_Ctrl_Down,K_Ctrl_L,K_Ctrl_X,K_Alt_F8:
          if ReadOnly or (SelLength=0) then Include(Opt,kmnDisabled);
        K_Ctrl_A:
          if GetTextLength=0 then Include(Opt,kmnDisabled);
        K_Ctrl_C:
          if SelLength=0 then Include(Opt,kmnDisabled);
        {K_Ctrl_V:
          if not CanPaste then Include(Opt,kmnDisabled);}
        K_Ctrl_Y:
          if ReadOnly or (CurrentLineNumber>=Lines.Count) then Include(Opt,kmnDisabled);
        K_Ctrl_Z:
          if not CanUndo then Include(Opt,kmnDisabled);
        K_Alt_Left,K_Alt_Right,K_Alt_A: if IsSci then
          if not(foldFold in Sci.Folding) then Opt:=Opt+[kmnDisabled,kmnHide];
      end;
      if not Focused then Include(Opt,kmnDisabled);
{if Key=122 then begin
MainMn:=MainMn;
end;}
      MainMn.HideItem(kmEdit,Key,Opt);
      with PopupMenu do for i:=0 to Items.Count-1 do with Items[i] do if Tag<>0 then begin
        ShortCutToKey(Tag,wKey,Shift);
        if GetKeyCod(wKey,Shift)=Key then begin
          Enabled:=not(kmnDisabled in Opt); Visible:=not(kmnHide in Opt); System.break;
        end;
      end;
    end;
  DelStack;
end;

function TCustomEdMemo.CurLineStartPos;
begin
	AddStack('TCustomEdMemo.CurLineStartPos',Self);
  result:=PositionFromLine(CurrentLineNumber);
  DelStack;
end;

function TCustomEdMemo.CurrentCol;
begin
	AddStack('TCustomEdMemo.CurrentCol',Self);
  if IsSci then result:=GetColumn(GetCurrentPos) else result:=NoSci.CaretPos.X;
  DelStack;
end;

procedure TCustomEdMemo.Settopindex;
begin
	AddStack('TCustomEdMemo.Settopindex',Self);
  LineScroll(0,EnsureRange(Value,0,Lines.Count-1)-LineFromPosition(MaxWord));
  DelStack;
end;

procedure TCustomEdMemo.SelectLines;
var p: longint;
begin
	AddStack('TCustomEdMemo.SelectLines',Self);
  p:=PositionFromLine(EnsureRange(LnBeg,0,Lines.Count-1));
  SetSelection(p,GetLineEndPosition(EnsureRange(LnEnd,0,Lines.Count-1))-p);
  DelStack;
end;

procedure TCustomEdMemo.SetSelection;
begin
	AddStack('TCustomEdMemo.SetSelection',Self);
  SelStart:=nStart; SelLength:=nLength; ScrollCaret;
  if lMoveCaret then MoveCaret;
  DelStack;
end;

function TCustomEdMemo.GetLinesText;
var i: longint;
begin
  AddStack('TCustomEdMemo.GetLinesText',Self);
  if IsSci then with Sci do begin
    i:=GetTextLength; SetLength(result,i);
    if i>0 then GetText(i+1,PChar(result));
  end
  else result:=Lines.Text;
  DelStack;
end;

procedure TCustomEdMemo.SetLinesText;
var ro: boolean;
begin
  AddStack('TCustomEdMemo.SetLinesText',Self);
  ro:=ReadOnly; ReadOnly:=false; Lines.Text:=Value;
  if IsSci then with Sci do begin
    EmptyUndoBuffer; SetSavePoint;
  end
  else NoSci.Perform(EM_EMPTYUNDOBUFFER,0,0);
  ReadOnly:=ro;
  DelStack;
end;

function TCustomEdMemo.GetWordWrapBool;
begin
  AddStack('TCustomEdMemo.GetWordWrapBool',Self);
  if IsSci then result := Sci.WordWrap<>sciNoWrap else result:=NoSci.WordWrap;
  DelStack;
end;

procedure TCustomEdMemo.SetWordWrapBool;
begin
  AddStack('TCustomEdMemo.SetWordWrapBool',Self);
  if IsSci then Sci.WordWrap:=iif(Value,sciWrap,sciNoWrap) else NoSci.WordWrap:=Value;
  DelStack;
end;

procedure TCustomEdMemo.LinesBeginUpdate;
begin
  AddStack('TCustomEdMemo.LinesBeginUpdate',Self);
  with Upd do if not lMod then begin
    lMod:=true; lReadOnly:=ReadOnly; ReadOnly:=false; Lines.BeginUpdate;
  end;
  DelStack;
end;

function TCustomEdMemo.LinesEndUpdate;
begin
  AddStack('TCustomEdMemo.LinesEndUpdate',Self);
  with Upd do begin
    if lMod then begin
      Lines.EndUpdate; ReadOnly:=lReadOnly;
    end;
    result:=lMod;
  end;
  DelStack;
end;

procedure TCustomEdMemo.BeforeKeyDown;
var sb,sl,db,de,i: longint;
  bm: TEdMemoBMCrd;
  s: string;
  oks,ks: TKeyboardState;
begin
	AddStack('TCustomEdMemo.BeforeKeyDown',Self);
  s:=''; db:=-1; de:=0; sb:=-1; sl:=0; // Variable might not have been initialized
  if not IsSci then begin
    if (Shift=[]) then case Key of
      VK_PRIOR: // PgUp
        if (GetFirstVisibleLine=0) and (CurrentLineNumber>0)
        then SetSelection(min(CurrentCol,Length(Lines[0])));
      VK_NEXT: begin // PgDn
        i:=GetLineCount;
        if (GetFirstVisibleLine+LinesOnScreen>=i) and (CurrentLineNumber<i-1)
        then SetSelection(GetTextLength);
      end;
    end
    else if Shift=[ssCtrl] then case Key of
      VK_BACK: begin // Ctrl+BackSpace
        de:=GetCurrentPos; db:=WordStartPosition(de,false);
      end;
      VK_DELETE,Word('T'): begin // Ctrl+T,Ctrl+Del
        db:=GetCurrentPos; de:=WordEndPosition(db,false);
      end;
      Word('D'): if GetTextLength>0 then begin // Ctrl+D
        sb:=SelStart; sl:=SelLength;
        if sl=0 then begin
          i:=CurrentLineNumber; s:=#13+Lines[i]; SetSelection(GetLineEndPosition(i));
        end
        else begin
          s:=SelText; SetSelection(sb+sl);
        end;
      end;
    end
    else if Shift=[ssCtrl,ssShift] then case Key of
      VK_BACK: begin // Ctrl+Shift+BackSpace
        db:=CurLineStartPos; de:=GetCurrentPos;
      end;
      VK_DELETE: begin // Ctrl+Shift+Del
        db:=GetCurrentPos; de:=GetLineEndPosition(CurrentLineNumber);
      end;
      Word('T'):  begin // Ctrl+Shift+T
        i:=CurrentLineNumber;
        if i<Lines.Count then Clipboard.AsText:=Lines[i];
      end;
    end;
  end;
  if Shift=[ssCtrl] then case Key of
    // Преобразовать в верхний регистр выделенный фрагмент
    vk_Up: if not ReadOnly then begin
      MnProcUpCase(Self); Key:=0;
    end;
    // Преобразовать в нижний регистр выделенный фрагмент
    vk_Down: if not ReadOnly then begin
      MnProcDnCase(Self); Key:=0;
    end;
    low(FBookMark)..high(FBookMark):
      with FBookMark[Key].Crd do if Col=NegDef then case Key of
        50: s:=GetNextQuote; // Ctrl "
        51: s:='#';          // Ctrl #
      end
      else if InRange(Line,0,Lines.Count-1) then begin
        SetSelection(0);
        CurrentLineNumber:=LastVisibleLine;
        SetSelection(PositionFromLine(Line)+min(Col,Length(Lines[Line])));
      end;
    // Сменить язык выделенного фрагмента
    Word('L'): if not ReadOnly then begin
      MnProcCngLang(Self); Key:=0;
    end;
    // Удаление строки
    Word('Y'): if not ReadOnly and (CurrentLineNumber<Lines.Count) then begin
      MnProcDelLine(Self); Key:=0;
    end;
    //Word('Y'): SetSelection(Sci.WordStartPosition(GetCurrentPos,false));
    188: s:='<';          // Ctrl <
    190: s:='>';          // Ctrl >
    219: s:='[';          // Ctrl [
    220: s:='|';          // Ctrl |
    221: s:=']';          // Ctrl ]
    222: s:=GetNextQuote; // Ctrl "
  end;
  if (Shift=[ssAlt]) then begin
    if IsSci then if foldFold in Sci.Folding then case Key of
      vk_Left: FoldCollapse(Self);
      vk_Right: FoldExpand(Self);
      Word('A'): FoldExpandAll(Self);
    end;
    case Key of
      // Удалить лишние пробелы в выделенном фрагменте
      vk_F8: if not ReadOnly then begin
        MnProcDelTrim(Self); Key:=0;
      end;
      219: s:='{';    // Alt {
      221: s:='}';    // Alt }
    end;
  end;
  if (Shift=[ssCtrl,ssShift]) and (emoLineNumber in Cng) then case Key of
    low(FBookMark)..high(FBookMark): begin
      bm.Line:=CurrentLineNumber;
      with FBookMark[Key] do
        bm.Col:=IfThen((Crd.Col>=0) and (Crd.Line=CurrentLineNumber),NegDef,CurrentCol);
      bm.LastVisibleLine:=GetFirstVisibleLine+LinesOnScreen-1;
      BookMark[Key]:=bm;
    end;
    Word('A'): begin
      bm.Col:=NegDef;
      for i:=low(FBookMark) to high(FBookMark) do BookMark[i]:=bm;
    end;
  end;
  if (s<>'') or (db>=0) then begin
    GetKeyboardState(oks);
    ks:=oks; ks[VK_CONTROL]:=0; ks[VK_MENU]:=0; ks[VK_SHIFT]:=0; SetKeyboardState(ks);
    if s<>'' then InsText(s);
    if db>=0 then begin
      SetSelection(db,de-db); Clear;
    end;
    if sb>0 then SetSelection(sb,sl); 
    Key:=0; SetKeyboardState(oks);
  end;
	DelStack;
end;

procedure TCustomEdMemo.AfterKeyDown;
begin
end;

procedure TCustomEdMemo.BeforeKeyPress;
const acUlsKey: array[TEdMemoUserList] of string = (#10,' ');
var l,lt: longint;
begin
	AddStack('TCustomEdMemo.BeforeKeyPress',Self);
  if IsMaxLength(l) then begin
    Dec(l,1+SelLength); lt:=GetTextLength;
    if lt>l then begin
      while lt>0 do if GetCharAt(lt-1)>Ord(' ') then break else Dec(lt);
      if lt>l then Key:=#0;
    end;
  end;
  if Key<>#0 then
    if IsSci then begin
      if (Key<' ') or (GetKeyState(VK_CONTROL)<0) and (Key=' ') then Key:=#0;
    end
    else begin
      if (GetKeyState(VK_CONTROL)<0) and (AnsiMatchStr(Key,acUlsKey) or (Key=#127){Ctrl+BackSpace})
      then Key:=#0;
      // Замена
      if InsModeOverride and (Key<>#0) and (SelLength=0) then SelLength:=1;
    end;
  DelStack;
end;

procedure TCustomEdMemo.AfterKeyPress;
begin
end;

procedure TCustomEdMemo.BeforeKeyUp;
begin
end;

procedure TCustomEdMemo.AfterKeyUp;
begin
  AddStack('TCustomEdMemo.AfterKeyUp',Self);
  if not IsSci then MoveCaret;
  DelStack;
end;

procedure TCustomEdMemo.MouseMove;
begin
end;

procedure TCustomEdMemo.MouseUp;
begin
  AddStack('TCustomEdMemo.MouseUp',Self);
  if not IsSci then MoveCaret;
  DelStack;
end;

procedure TCustomEdMemo.MenuItemFold;
begin
  AddStack('TCustomEdMemo.MenuItemFold',Self);
  if Assigned(MainMn) and Focused and (foldFold in Sci.Folding) then with MainMn do begin
    AddItem(kmEdit,K_Alt_Left,'Свернуть',FoldCollapse);
    AddItem(kmEdit,K_Alt_Right,'Развернуть',FoldExpand);
    AddItem(kmEdit,K_Alt_A,'Развернуть все',FoldExpandAll);
  end;
  EnabledItem(K_Alt_Left); EnabledItem(K_Alt_Right); EnabledItem(K_Alt_A);
  DelStack;
end;

procedure TCustomEdMemo.BeforeEnter;
begin
end;

procedure TCustomEdMemo.AfterEnter;
  procedure BookMarkMenu(offs: byte; const Capt: TCaption);
  var mn: TMenuItem;
    procedure mnNew(const ACaption: string; Key: longint);
    var mn1: TMenuItem;
      Enabled: boolean;
    begin
    	AddStack('TCustomEdMemo.AfterEnter.BookMarkMenu.mnNew',Self);
      if offs=2 then Enabled := FBookMark[Key].Crd.Col<>NegDef else Enabled:=true;
      mn1:=NewItem(ACaption+'   Ctrl'+IfThen(offs=1,'+Shift')+'+'+Chr(Key),0,false,Enabled,BookMarkProc,0,'');
      if (offs=1) and InRange(Key,low(FBookMark),high(FBookMark)) then begin
        mn1.OnDrawItem:=MNBookMarkDrawItem;
        mn1.OnMeasureItem:=mn.OnMeasureItem;
        mn1.Checked := FBookMark[Key].Crd.Col<>NegDef;
      end;
      mn.Add(mn1); mn1.Tag:=Key_User+Key;
      DelStack;
    end;
  var i: byte;
  begin
  	AddStack('TCustomEdMemo.AfterEnter.BookMarkMenu',Self);
    mn:=MainMn.AddItem(kmEdit,Key_User+offs,Capt,nil);
    if mn.Count=0 then begin
      for i:=low(FBookMark) to high(FBookMark) do mnNew(Chr(i),i);
      if offs=1 then begin
        mn.Add(Menus.NewLine); mnNew('Снять все',Ord('A'));
      end;
    end;
    DelStack;
  end;
var tl: TKeyLb;
begin
	AddStack('TCustomEdMemo.AfterEnter',Self);
  Focused:=true;
  if FormKeyLb(Control,tl) then begin
    tl.DelKey(K_All,'rbscrollbox');
    tl.ReDrw; // Чтобы убрать FixKey
    if not(ReadOnly or NoInsDateTime)
    then tl.SetKey(K_F5,'','Вставить текущее время и дату',ProcKey,'customedmemo',kmEdit);
    if IsSci then tl.SetKey(K_Alt_F3,'','Сменить вид редактирования текста',ProcKey,'customedmemo',kmEdit);
    if IsSci or not AlwaysReadOnly
    then tl.SetKey(K_Ctrl_F3,'','Настройки редактирования текста',ProcKey,'customedmemo',kmEdit);
    if not ReadOnly then begin
      if LsUser[ulsTempl].Count>0 then tl.SetKey(aUlsKey[ulsTempl],'','Шаблоны',ProcKey,'customedmemo',kmEdit);
      if Length(aKeywords)>0 then tl.SetKey(aUlsKey[ulsKeyword],'','Ключевые слова',ProcKey,'customedmemo',kmEdit);
    end;
    SetKeyLink(tl);
  end;
  if Assigned(MainMn) then with MainMn do begin
    CngProcItem(kmEdit,K_Ctrl_X,MnProcCut);
    CngProcItem(kmEdit,K_Ctrl_C,MnProcCopy);
    CngProcItem(kmEdit,K_Ctrl_V,MnProcPaste);
    AddItem(kmEdit,K_Ctrl_Y,'Удалить строку',Self.MnProcDelLine);
    AddItem(kmEdit,K_Ctrl_A,'Выделить всё',MnProcSelAll);
    AddItem(kmEdit,K_Ctrl_Up,'Преобразовать в верхний регистр выделенный фрагмент',MnProcUpCase);
    AddItem(kmEdit,K_Ctrl_Down,'Преобразовать в нижний регистр выделенный фрагмент',MnProcDnCase);
    AddItem(kmEdit,K_Ctrl_L,'Сменить язык выделенного фрагмента',MnProcCngLang);
    AddItem(kmEdit,K_Alt_F8,'Удалить лишние пробелы в выделенном фрагменте',MnProcDelTrim);
    if IsSci then MenuItemFold;
    if emoLineNumber in Cng then begin
      BookMarkMenu(1,'Установить/снять закладку');
      BookMarkMenu(2,'Перейти к закладке');
    end;
  end;
  EnabledItem;
  {if IsSci then with Sci do
    if FNextClipboardViewer=0 then begin
      FNextClipboardViewer:=SetClipboardViewer(Handle);
      if FNextClipboardViewer=0 then meserr(SysErrorMessage(GetLastError));
    end;}
  DelStack;
end;

procedure TCustomEdMemo.BeforeExit;
var tl: TKeyLb;
begin
	AddStack('TCustomEdMemo.BeforeExit',Self);
  {if IsSci then with Sci do if FNextClipboardViewer<>0 then begin
    ChangeClipboardChain(Handle,FNextClipboardViewer); FNextClipboardViewer:=0;
  end;}
  if FormKeyLb(Control,tl) then tl.DelKey(K_All,'customedmemo');
  Focused:=false; EnabledItem;
  DelStack;
end;

procedure TCustomEdMemo.AfterExit;
begin
end;

procedure TCustomEdMemo.BookMarkProc;
var mn: TMenuItem;
  Key: Word;
begin
  AddStack('TCustomEdMemo.BookMarkProc',Self);
  mn:=pointer(Sender); Key:=mn.Tag-Key_User;
  BeforeKeyDown(Key,[ssCtrl]+IfThen(mn.Parent.Tag=Key_User+1,[ssShift]));
  DelStack;
end;

function TCustomEdMemo.NoBookMarkKey;
begin
  AddStack('TCustomEdMemo.NoBookMarkKey',Self);
  if Key in [low(FBookMark)..high(FBookMark)]
  then result := not((Shift=[ssCtrl]) and (FBookMark[Key].Crd.Col<>NegDef))
  else result:=true;
  DelStack;
end;

procedure TCustomEdMemo.BookMarkRestore;
var i: byte;
begin
  AddStack('TCustomEdMemo.BookMarkRestore',Self);
  for i:=low(FBookMark) to high(FBookMark) do with FBookMark[i] do
    if Crd.Col<>NegDef then if Assigned(Mark) then Mark.Add(Crd.Line);
  DelStack;
end;

class function TCustomEdMemo.KeywordVisible;
begin
  result:=true;
end;

class function TCustomEdMemo.AlwaysReadOnly;
begin
  result:=false;
end;

function TCustomEdMemo.IsMaxLength;
begin
  AddStack('TCustomEdMemo.IsMaxLength',Self);
  if Assigned(OnMaxLength) then l:=OnMaxLength(Self) else l:=0;
  result := l>0;
  DelStack;
end;

function TCustomEdMemo.MaxLengthCheck;
var l: longint;
begin
  AddStack('TCustomEdMemo.MaxLengthCheck',Self);
  result:=true;
  if IsMaxLength(l) then begin
    l:=Length(TrimRight(Text))-l;
    if l>0 then begin
      meserr('Длина текста превышает максимально допустимую на %d символов.',[l]); result:=false;
    end;
  end;
  DelStack;
end;

function TCustomEdMemo.StrToFont;
var a: array[1..5] of string;
  procedure Color1(var cl: TColor; n: byte);
  begin
    AddStack('TCustomEdMemo.StrToFont.Color1',Self);
    TrimSelf(a[n]);
    if a[n]='' then cl:=clDefault else cl:=StringToColor(a[n]);
    DelStack;
  end;
begin
  AddStack('TCustomEdMemo.StrToFont',Self);
  LsArrFill(s,a,',');
  with result do begin
    FontName:=Trim(a[1]);
    FontSize:=Int0(a[2]);
    FontStylesCng:=not empty(a[3]);
    if FontStylesCng then FontStyles:=TEdMemoFontStyles(byte(Int0(a[3])))
    else if Assigned(CurSchem) then CurSchem.Font1.Style else FontStyles:=[];
    Color1(ForeColor,4);
    Color1(BackColor,5);
  end;
  DelStack;
end;

function FontToStr(const f: TEdMemoFont): string;
begin
  AddStack('FEdText.FontToStr');
  result:=ArrayAsList(
    [f.FontName
    ,IntToStr(f.FontSize)
    ,IfThen(f.FontStylesCng,IntToStr(byte(f.FontStyles)))
    ,ColorToString(f.ForeColor)
    ,ColorToString(f.BackColor)
    ],',');
  DelStack;
end;

procedure ColorToRec(const nmf: string; cl: TColor);
var cl16: T16Colors;
begin
  AddStack('FEdText.ColorToRec');
  rProp[nmf]:=nDefColor;
  if cl<>clDefault then
    if SeekColor(cl,cl16) then rProp[nmf]:=cl16;
  DelStack;
end;

function RecToColor(const nmf: string): TColor;
begin
  AddStack('FEdText.RecToColor');
  if rProp[nmf]=nDefColor then result:=clDefault else result:=AColor[T16Colors(rProp[nmf])];
  DelStack;
end;

function ByteToStr(n,Len: byte): string;
var i,ms: byte;
begin
  AddStack('FEdText.ByteToStr');
  ms:=1; result:=Space(Len);
  for i:=1 to Len do begin
    if (n and ms) > 0 then SetByte(result,i,true);
    ShlD(ms);
  end;
  DelStack;
end;

function StrToByte(const s: string; Len: byte): byte;
var i,ms: byte;
begin
  AddStack('FEdText.StrToByte');
  ms:=1; result:=0;
  for i:=1 to Len do begin
    if GetByte(s,i) then Or_D(result,ms);
    ShlD(ms);
  end;
  DelStack;
end;

const sBegFont = 'F_';

function FontFld(i: longint): string;
begin
  AddStack('FEdText.FontFld');
  result:=StrNum(sBegFont,i,2);
  DelStack;
end;

procedure FontStylesToRec(FontStyles: TEdMemoFontStyles);
begin
  AddStack('FEdText.FontStylesToRec');
  rProp['FontStyles']:=ByteToStr(byte(FontStyles),FontStyleCnt);
  DelStack;
end;

procedure FontToRec(f: TEdMemoFont);
begin
  AddStack('FEdText.FontToRec');
  rProp['FontName']:=IfThen(empty(f.FontName),sDefault,f.FontName);
  rProp['FontSize']:=f.FontSize;
  rProp['FontStylesCng']:=f.FontStylesCng;
  FontStylesToRec(f.FontStyles);
  ColorToRec('ForeColor',f.ForeColor);
  ColorToRec('BackColor',f.BackColor);
  DelStack;
end;

procedure TCustomEdMemo.ProcKey;
var Sect: string;
  procedure WriteColor(const nmf: string);
  begin
    AddStack('TCustomEdMemo.ProcKey.WriteColor',Self);
    InitFIni[fiSchem].WriteString(Sect,nmf,ColorToString(RecToColor(nmf)));
    DelStack;
  end;
  procedure WriteFont(n: TEdMemoFontList);
  begin
    AddStack('TCustomEdMemo.ProcKey.WriteFont',Self);
    InitFIni[fiSchem].WriteString(Sect,StrNum('F',n,2),TrimRight(rProp[FontFld(n)]));
    DelStack;
  end;
var i: longint;
  procedure PgHide(Hide: boolean);
  var apg: array[1..4] of string;
  begin
    AddStack('TCustomEdMemo.ProcKey.PgHide',Self);
    Inc(i); LsArrFill(deProp.Pages[i],apg,UnDelim); apg[4]:=bStr[Hide];
    deProp.Pages[i]:=ArrayAsList(apg,UnDelim);
    DelStack;
  end;
const
  aAutoClose: array[1..aclCnt] of string = ('скобки','кавычки');
  aEdgeMode: array[sciEdgeType] of string = ('[нет]','линия','фон');
  aMarkerType: array[MarkerTypeNone..byte(high(sciMarkerType))-1] of string =
    ('[нет]','круг','квадрат','+/-','стрелка');
  aFoldDrawFlags: array[1..FoldDrawFlagCnt] of string =
    ('над развёрнутым','над свёрнутым','под развёрнутым','под свёрнутым');
var j,l: longint;
  k: TEdMemoCng;
  Prop: TEdMemoProp;
  a: TArrStr;
  a1: TNamePrimStr;
  ls: TStrings;
  av: TDEPrmVar;
  uls: TEdMemoUserList;
  s: string;
begin
  AddStack('TCustomEdMemo.ProcKey',Self);
  case Key of
    K_F5: InsText(FormatDateTime(ShortTimeFormat+' '+ShortDateFormat,Now));
    K_Esc: FUserListHide(true);
    K_Ctrl_F3: if not Assigned(CurEdClass) then begin
      TSimpleGet.CreateOne;
      if ParentClass(tw,TCustomRbPanel) then SchemName(TCustomRbPanel(tw).Schem,CurSchem);
      InitArr(av);
      if not Assigned(rProp) then begin
        FontNameGet:=TComboGet.Create(Application.MainForm);
        with FontNameGet,Items do begin
          VName:='EdMemoFontName'; Add(sDefault); AddStrings(Screen.Fonts); LenName:=MaxSelf(Items);
        end;
        rProp:=TRecVal.Create(Application.MainForm);
        with rProp do begin
          CreateFld('FontName',ftString,FontNameGet.LenName,'');
          CreateFld('FontSize',ftInteger,0,0);
          CreateFld('FontStylesCng',ftBoolean,0,false);
          CreateFld('FontStyles',ftString,FontStyleCnt,'');
          CreateFld('ForeColor',ftInteger,0,0);
          CreateFld('BackColor',ftInteger,0,0);
          for i:=low(TEdMemoFontList) to high(TEdMemoFontList) do CreateFld(FontFld(i),ftMemo,0,'');
          CreateFld('Sel',ftBoolean,0,false);
          CreateFld('SelFore',ftInteger,0,0);
          CreateFld('SelBack',ftInteger,0,0);
          CreateFld('Caret',ftBoolean,0,false);
          CreateFld('CaretWidth',ftInteger,0,0);
          CreateFld('CaretFore',ftInteger,0,0);
          CreateFld('CaretBack',ftInteger,0,0);
          CreateFld('AutoClose',ftString,aclCnt,'');
          CreateFld('EdgeMode',ftInteger,0,0);
          CreateFld('EdgeColumn',ftInteger,0,0);
          CreateFld('EdgeColor',ftInteger,0,0);
          CreateFld('LineNumber',ftBoolean,0,false);
          CreateFld('BookMark',ftBoolean,0,false);
          CreateFld('BookMarkFore',ftInteger,0,0);
          CreateFld('BookMarkBack',ftInteger,0,0);
          CreateFld('MarkerType',ftInteger,0,0);
          CreateFld('MarkerFore',ftInteger,0,0);
          CreateFld('MarkerBack',ftInteger,0,0);
          CreateFld('FoldHi',ftInteger,0,0);
          CreateFld('FoldLo',ftInteger,0,0);
          CreateFld('FoldDrawFlags',ftString,FoldDrawFlagCnt,'');
          CreateFld('ForeHlt',ftInteger,0,0);
          CreateFld('MouseDwell1',ftBoolean,0,false);
          CreateFld('MouseDwell',ftBoolean,0,false);
          CreateFld('MouseDwellSec1',ftBoolean,0,false);
          CreateFld('MouseDwellSec10',ftInteger,0,0);
          CreateFld('CallTip',ftBoolean,0,false);
          CreateFld('Templates',ftMemo,0,'');
          CreateFld('TemplName',ftString,lTemplName,'');
          CreateFld('TemplCont',ftMemo,0,'');
        end;
        ColorGet:=TColorGet.CreateColors(Application.MainForm);
        with ColorGet do begin
          VName:='EdMemoColor';
          Items.Insert(0,IntToStr(nDefColor)+UnDelim+sDefault);
          i:=Length(aNumBeforeLine); SetLength(aNumBeforeLine,i+1); aNumBeforeLine[i]:=0;
        end;
        FontGet:=TFontGet.Create(Application.MainForm); FontGet.VName:='EdMemoFont';
        TTemplatesGet.Create(Application.MainForm);
        deProp:=TDefEdit.Create(Application.MainForm);
        with deProp do begin
          FrmCaption:='Параметры редактирования текста'; NameWnd:='EdMemoProp';
          PnlAskByCancel:=true;
          NmProc.Add(TKeyLb.GetKeySt(K_Alt_Home,'По умолчанию','Установить все параметры по умолчанию',kmEdit));
          OnFldChange:=dePropFldChange;
          av[deNameRec]:=rProp.NameRec;
          av[deNameRecFld]:='SEL';
          TBoolGet.AssignGetClass(av);
          av[deMask]:='Выделение:'+cBoolSay+cBoolLeft;
          CreateFld(av);

          av[deCaption]:='текст';
          av[deNameRecFld]:='SELFORE';
          ColorGet.AssignGet(av);
          av[deMask]:='';
          av[deNoReadOnly]:=true;
          CreateFld(av);
          
          av[deCaption]:='фон';
          av[deNameRecFld]:='SELBACK';
          CreateFld(av);
          
          av[deCaption]:='';
          av[deNameRecFld]:='CARET';
          TBoolGet.AssignGetClass(av);
          av[deMask]:='Курсор:'+cBoolSay+cBoolLeft;
          av[deNoReadOnly]:=false;
          CreateFld(av);

          av[deCaption]:='толщина';
          av[deNameRecFld]:='CARETWIDTH';
          TSpinGet.AssignGetClass(av);
          av[deMask]:='1,9';
          av[deNoReadOnly]:=true;
          CreateFld(av);

          av[deCaption]:='цвет';
          av[deNameRecFld]:='CARETFORE';
          ColorGet.AssignGet(av);
          av[deMask]:='';
          CreateFld(av);

          av[deCaption]:='фон';
          av[deNameRecFld]:='CARETBACK';
          CreateFld(av);
          
          av[deCaption]:='Автоматически'+UnDelim+'закрывать:';
          av[deNameRecFld]:='AUTOCLOSE';
          TBoolMultiGet.AssignGetClass(av);
          av[deMask]:=ArrayAsList(aAutoClose,mniDlm);
          CreateFld(av);

          av[deCaption]:='';
          av[deNameRecFld]:='EDGEMODE';
          TRadioGet.GetFirst.AssignGet(av);
          av[deMask]:=RadioMask(aEdgeMode,0);
          av[deNewPage]:=true;
          CreateFld(av);
          
          av[deCaption]:='столбец';
          av[deNameRecFld]:='EDGECOLUMN';
          TSpinGet.AssignGetClass(av);
          av[deMask]:=StrNum('0,',MaxInt);
          av[deNewPage]:=false;
          av[deReadOnlyNoVsbl]:=true;
          CreateFld(av);
          
          av[deCaption]:='цвет';
          av[deNameRecFld]:='EDGECOLOR';
          ColorGet.AssignGet(av);
          av[deMask]:='';
          CreateFld(av);
          
          av[deCaption]:='Шрифт';
          av[deNameRecFld]:=FontFld(STYLE_LINENUMBER);
          FontGet.AssignGet(av);
          av[deReadOnlyNoVsbl]:=false;
          av[deNewPage]:=true;
          CreateFld(av);

          av[deCaption]:='';
          av[deNameRecFld]:='LINENUMBER';
          TBoolGet.AssignGetClass(av);
          av[deMask]:='Нумерация строк';
          av[deNewPage]:=false;
          CreateFld(av);
          
          av[deNameRecFld]:='BOOKMARK';
          av[deMask]:='Закладки:'+cBoolSay+cBoolLeft;
          av[deNoReadOnly]:=false;
          CreateFld(av);

          av[deCaption]:='текст';
          av[deNameRecFld]:='BOOKMARKFORE';
          ColorGet.AssignGet(av);
          av[deMask]:='';
          av[deNoReadOnly]:=true;
          CreateFld(av);
          
          av[deCaption]:='фон';
          av[deNameRecFld]:='BOOKMARKBACK';
          CreateFld(av);
          
          av[deCaption]:='';
          av[deNameRecFld]:='MARKERTYPE';
          TRadioGet.GetFirst.AssignGet(av);
          av[deMask]:=RadioMask(aMarkerType,MarkerTypeNone);
          av[deNewPage]:=true;
          CreateFld(av);
          
          av[deCaption]:='знаки';
          av[deNameRecFld]:='MARKERFORE';
          ColorGet.AssignGet(av);
          av[deMask]:='';
          av[deReadOnlyNoVsbl]:=true;
          av[deNewPage]:=false;
          CreateFld(av);

          av[deCaption]:='линии';
          av[deNameRecFld]:='MARKERBACK';
          CreateFld(av);

          av[deCaption]:='фон 1';
          av[deNameRecFld]:='FOLDHI';
          CreateFld(av);
          
          av[deCaption]:='фон 2';
          av[deNameRecFld]:='FOLDLO';
          CreateFld(av);
          
          av[deCaption]:='черта';
          av[deNameRecFld]:='FOLDDRAWFLAGS';
          TBoolMultiGet.AssignGetClass(av);
          av[deMask]:=ArrayAsList(aFoldDrawFlags,mniDlm);
          CreateFld(av);

          av[deCaption]:='Шрифт';
          av[deNameRecFld]:=FontFld(STYLE_CALLTIP);
          FontGet.AssignGet(av);
          av[deMask]:='';
          av[deReadOnlyNoVsbl]:=false;
          av[deNewPage]:=true;
          CreateFld(av);
          
          av[deCaption]:='Цвет выделенного'+UnDelim+'текста';
          av[deNameRecFld]:='FOREHLT';
          ColorGet.AssignGet(av);
          av[deNewPage]:=false;
          CreateFld(av);

          av[deCaption]:='Автоматически'+UnDelim+'выводить:';
          av[deNameRecFld]:='MOUSEDWELL1';
          TMultiGet.AssignGetClass(av);
          av[deMask]:='2';
          CreateFld(av);
          
          av[deCaption]:='';
          av[deNameRecFld]:='MOUSEDWELL';
          TBoolGet.AssignGetClass(av);
          av[deMask]:='при наведении курсора мыши';
          av[deRelation]:=rProp.NameRec+'.MouseDwell1';
          CreateFld(av);
          
          av[deNameRecFld]:='MOUSEDWELLSEC1';
          av[deMask]:='через'+cBoolSay;
          av[deNoReadOnly]:=false;
          CreateFld(av);
          
          av[deCaption]:='/10 сек.';
          av[deNameRecFld]:='MOUSEDWELLSEC10';
          TSpinGet.AssignGetClass(av);
          av[deMask]:='1,999';
          av[deReadOnlyNoVsbl]:=true;
          av[deSayRight]:=true;
          CreateFld(av);

          av[deCaption]:='';
          av[deNameRecFld]:='CALLTIP';
          TBoolGet.AssignGetClass(av);
          av[deMask]:='при редактировании текста';
          av[deNoReadOnly]:=true;
          av[deReadOnlyNoVsbl]:=false;
          av[deTag]:=true;
          av[deSayRight]:=false;
          CreateFld(av);
          
          av[deNameRecFld]:='TEMPLATES';
          TTemplatesGet.AssignGetClass(av);
          av[deMask]:='';
          av[deTag]:=false;
          av[deWidth]:=wallDefault;
          av[deHeight]:=-1;
          av[deNewPage]:=true;
          av[deRelation]:='';
          CreateFld(av);
          
          Pages[0]:=StrNum('Общие'+UnDelim,Succ(smColumns));
          Pages[1]:=StrNum('Правая граница'+UnDelim,Succ(smColumns));
          Pages[2]:=StrNum('Информ.столбец'+UnDelim,Succ(smColumns));
          Pages[3]:=StrNum('Свертка'+UnDelim,Succ(smColumns));
          Pages[4]:=StrNum('Подсказки'+UnDelim,Succ(smColumns));
          Pages[5]:='Шаблоны';
        end;
      end;
      Sect:=ClassName;
      with deProp do begin
        Prop:=IniToProp(true); PropToRec(Prop); i:=-1; PgHide(not IsSci);
        for k:=low(TEdMemoCng) to high(TEdMemoCng) do PgHide(not(IsSci and (k in Cng)));
        PgHide(AlwaysReadOnly);
        Param['AutoClose',deNoVisible]:=bStr[AlwaysReadOnly];
        Param['CallTip',deNoVisible]:=bStr[AlwaysReadOnly];
        while AnsiStartsStr(sBegFont,GetArrParam(Fields.Count-1)[deNameRecFld]) do
          DestroyFld(Fields.Count-1);
        if Length(CngFont)>0 then begin
          FontGet.AssignGet(av);
          av[deNameRec]:=rProp.NameRec;
          av[deMask]:='';
          av[deNoReadOnly]:=true;
          av[deNewPage]:=true;
          av[deWidth]:=0;
          av[deHeight]:=0;
          for j:=low(CngFont) to high(CngFont) do with CngFont[j] do begin
            av[deCaption]:=Caption;
            av[deNameRecFld]:=FontFld(an[0]);
            CreateFld(av);
            av[deNewPage]:=false;
          end;
          Pages[Pages.Count-1]:=StrNum('Шрифты'+UnDelim,Succ(smColumns));
          PgHide(not IsSci);
        end;
        OnKpProcKey:=dePropKpProcKey; ColorGet.OnBrushColor:=ColorGetBrushColor;
        with FontGet do begin
          OnClick:=FontGetClick; OnPaint:=FontGetPaint; OnSize:=FontGetSize;
        end;
        CurEdClass:=TClassTextMemo(IfThen(Self is TTextMemo,Self.ClassType,TTextMemo));
        if Execute.Saved and Assigned(InitFIni) then with Prop,InitFIni[fiSchem] do begin
          for i:=low(CngFont) to high(CngFont) do WriteFont(CngFont[i].an[0]);
          WriteColor('SelFore');
          WriteColor('SelBack');
          WriteInteger(Sect,'CaretWidth',rProp['CaretWidth']);
          WriteColor('CaretFore');
          WriteColor('CaretBack');
          WriteInteger(Sect,'AutoClose',StrToByte(rProp['AutoClose'],aclCnt));
          if emoEdge in Cng then begin
            WriteInteger(Sect,'EdgeMode',rProp['EdgeMode']);
            WriteInteger(Sect,'EdgeColumn',rProp['EdgeColumn']);
            WriteColor('EdgeColor');
          end;
          if emoLineNumber in Cng then begin
            WriteBool(Sect,'LineNumber',rProp['LineNumber']);
            WriteFont(STYLE_LINENUMBER);
            WriteColor('BookMarkFore');
            WriteColor('BookMarkBack');
          end;
          if emoFolding in Cng then begin
            WriteInteger(Sect,'MarkerType',rProp['MarkerType']);
            WriteColor('MarkerFore');
            WriteColor('MarkerBack');
            WriteColor('FoldHi');
            WriteColor('FoldLo');
            WriteInteger(Sect,'FoldDrawFlags',StrToByte(rProp['FoldDrawFlags'],FoldDrawFlagCnt));
          end;
          if emoCallTip in Cng then begin
            WriteFont(STYLE_CALLTIP);
            WriteColor('ForeHlt');
            WriteBool(Sect,'MouseDwell',rProp['MouseDwell']);
            WriteInteger(Sect,'MouseDwellSec10',rProp['MouseDwellSec10']);
            WriteBool(Sect,'CallTip',rProp['CallTip']);
          end;
          EraseSection(Sect+'.Templates');
          for i:=0 to LsArrDynamic(rProp['Templates'],a,CRLF)-1 do if not empty(a[i]) then
            if StrToBoolean(a[i][1]) then begin
              a1:=StrToTempl(System.Copy(a[i],2,MaxInt)); WriteString(Sect+'.Templates',a1[1],a1[2]);
            end;
          SetPropEx(true); SetSchemAppl;
        end;
        CurEdClass:=nil;
      end;
    end;
    K_Ctrl_F7: begin
      if not Assigned(rLink) then begin
        rLink:=TRecVal.Create(Application.MainForm);
        rLink.CreateFld('TXT',ftMemo,0,'','Текст ссылки');
        LinkAddGet:=TDirGet.Create(Application.MainForm);
        with LinkAddGet do begin
          VName:='LinkAdd'; OpenDialog:=GetOpenDialog; Options:=[dgNoCheckDir];
        end;
        deLink:=TDefEdit.Create(Application.MainForm);
        with deLink do begin
          FrmCaption:='Добавить ссылку'; NameWnd:='LinkAdd'; OnPnlCngKey:=deLinkPnlCngKey;
          InitArr(av);
          av[deNameRec]:=rLink.NameRec;
          av[deNameRecFld]:='TXT';
          LinkAddGet.AssignGet(av);
          av[deMask]:=FrmCaption;
          av[deAutoSel]:=true;
          av[deNoReadOnly]:=true;
          av[deWidth]:=wallDefault;
          av[deTrimLeft]:=true;
          CreateFld(av);
        end;
      end;
      if deLink.Execute.Saved then begin
        s:=TrimRight(rLink['TXT']); l:=Length(s); j:=GetCurrentPos+1; lsLink.Find(j,i); lsLink.Insert(i,j,pointer(l));
        for i:=i+1 to lsLink.Count-1 do lsLink.IncD(i,l);
        TextSetting:=true; InsText(s); TextSetting:=false;
      end;
    end;
    K_Ctrl_Enter,K_Alt_Enter: begin
      PosInLink(GetCurrentPos,i); s:=LinkText(i);
      case Key of
        K_Ctrl_Enter: ShellExecute(0,nil,PChar(s),nil,nil,SW_SHOW);
        K_Alt_Enter: ShellExecute(0,nil,'explorer.exe',PChar('/select,'+s),nil,SW_SHOW);
      end;
    end;
    K_Alt_F3: if not Assigned(CurEdClass) then begin
      SetPropEx(not GetPropEx); SetSchemAppl;
    end;
  else
    if not(ReadOnly or AutoCActive) and (nUserList=ulsNone) then for uls:=low(aUlsKey) to high(aUlsKey) do
      if Key=aUlsKey[uls] then begin
        if uls=ulsKeyword then with LsUser[uls] do begin
          BeforeShowKeyword; BeginUpdate; Clear;
          for l:=low(aKeywords) to high(aKeywords) do begin
            ls:=KeyWordN(aKeywords[l]);
            for j:=0 to ls.Count-1 do
              if KeywordVisible(ls[j]) then Add(ls[j]);
          end;
          EndUpdate;
        end;
        nUserList:=uls; FUserListShow(true); break;
      end;
  end;
  DelStack;
end;

procedure TCustomEdMemo.BeforeShowKeyword;
begin
end;

procedure TCustomEdMemo.FUserListShow;
const aHeight: array[TEdMemoUserList] of byte = (5,10);
var i,l: longint;
  s: string;
  tl: TKeyLb;
begin
  AddStack('TCustomEdMemo.FUserListShow',Self);
  if nUserList<>ulsNone then begin
    i:=GetColumn(WordStartPosition(GetCurrentPos,true));
    s:=AnsiUpperCase(System.Copy(Lines[CurrentLineNumber],i+1,CurrentCol-i));
    LsUser[nUserList].Find(s,i); l:=i;
    while l<LsUser[nUserList].Count do
      if AnsiStartsText(s,LsUser[nUserList][l]) then Inc(l) else break;
    Dec(l,i);
    if ((l=1) and lFirst) or not IsSci
    then FUserListSelection(nUserList,PChar(LsUser[nUserList][i]),false)
    else if IsSci then with Sci do begin
      AutoCSetMaxHeight(aHeight[nUserList]);
      UserListShow(byte(nUserList),PChar(StrTran(TrimRight(DlmCopy(LsUser[nUserList].Text,i+1,l,CRLF)),CRLF,' ')));
      tl:=FormKeyLb(Control); tl.SetKey(K_Esc,'Отмена','',ProcKey,'customedmemo',kmFile); tl.ReDrw;
    end;
  end;
  DelStack;
end;

procedure TCustomEdMemo.FUserListHide;
var fl: boolean;
  tl: TKeyLb;
begin
  AddStack('TCustomEdMemo.FUserListHide',Self);
  nUserList:=ulsNone; fl:=AutoCActive;
  if fl then Sci.AutoCCancel;
  tl:=FormKeyLb(Control); tl.DelKey(K_Esc,'customedmemo'); tl.ReDrw;
  if not fl and lVisible then tl.ExecKey(K_Esc);
  DelStack;
end;

procedure TCustomEdMemo.doSciUserListSelection;
begin
  AddStack('TCustomEdMemo.doSciUserListSelection',Self);
  FUserListSelection(TEdMemoUserList(listType),text,true);
  DelStack;
end;

procedure TCustomEdMemo.FUserListSelection;
var i,l,s: longint;
  cont: string;
begin
  AddStack('TCustomEdMemo.FUserListSelection',Self);
  cont:=text;
  FUserListHide(lVisible);
  if LsUser[listType].Find(cont,i) then begin
    s:=0; UserListCont(listType,i,cont,s);
    l:=GetCurrentPos; i:=WordStartPosition(l,true);
    if IsSci then begin
      SelStart:=i; Sci.SetSelectionEnd(l);
    end
    else SetSelection(i,l-i);
    InsText(cont);
    if s>0 then SetSelection(i+s-1);
    s:=-1; UserListCont(listType,i,cont,s);
  end;
  DelStack;
end;

procedure TCustomEdMemo.UserListCont;
var p: PTemplInf;
  ls: TTemplList;
begin
  AddStack('TCustomEdMemo.UserListCont',Self);
  if pSelStart>=0 then if IsClass(LsUser[listType],TTemplList,pointer(ls)) then begin
    p:=ls.GetObj(Index);
    if p.cont<>'' then begin
      cont:=p.cont;
      if IsPos(pSelStart,'|',cont) then Delete(cont,pSelStart,1);
    end;
  end;
  DelStack;
end;

function TCustomEdMemo.ColorGetBrushColor;
const aColor2: array[0..1] of string = ('FOLDHI','FOLDLO');
var nmf: string;
  lFore: boolean;
begin
  AddStack('TCustomEdMemo.ColorGetBrushColor',Self);
  nmf:=TrimUpper(tf.NameRecFld); result:=clDefault;
  if nmf='BACKCOLOR' then begin
    with deProp.PanelEdit do
      if FldActive.NameRecFld=FontFld(STYLE_LINENUMBER) then result:=Color2;
  end
  else if AnsiMatchText(nmf,aColor2) then result:=Color2
  else result:=CngDefColor(nmf);
  if result=clDefault then begin
    lFore := Pos('FORE',nmf)>0;
    if AnsiStartsStr('MARKER',nmf) then NotD(lFore);
    if lFore then
      if Assigned(CurSchem) then result:=CurSchem.Font1.Color else result:=clWindowText
    else result:=CurSchem.IfThenColor(dColor1,clWindow);
  end;
  DelStack;
end;

function TCustomEdMemo.FontGetClick;
const a: array[TEdMemoFontStyle] of string = ('жирный','наклонный','подчеркнутый');
var tf: TFldEdit;
  f: TEdMemoFont;
  lCallTip: boolean;
  av: TDEPrmVar;
begin
  AddStack('TCustomEdMemo.FontGetClick',Self);
  if lEval then begin
    if not Assigned(deFont) then begin
      deFont:=TDefEdit.Create(Application.MainForm);
      with deFont do begin
        NameWnd:='EdMemoFont'; PnlSortMode:=smColumns;
        NmProc.Add(TKeyLb.GetKeySt(K_Alt_Home,'По умолчанию','Установить все параметры по умолчанию',kmEdit));
        OnFldChange:=deFontFldChange;

        InitArr(av);
        av[deCaption]:='Шрифт';
        av[deNameRec]:=rProp.NameRec;
        av[deNameRecFld]:='FONTNAME';
        FontNameGet.AssignGet(av);
        av[deMask]:=StrNum(UnDelim+cOnlyList,FontNameGet.LenName);
        av[deNoReadOnly]:=true;
        CreateFld(av);

        av[deCaption]:='Размер'+UnDelim+'(0-по умолчанию)';
        av[deNameRecFld]:='FONTSIZE';
        TSpinGet.AssignGetClass(av);
        av[deMask]:='0,99';
        av[deAutoSel]:=true;
        CreateFld(av);

        av[deCaption]:='';
        av[deNameRecFld]:='FONTSTYLESCNG';
        TBoolGet.AssignGetClass(av);
        av[deMask]:='Изменить атрибуты';
        CreateFld(av);

        av[deNameRecFld]:='FONTSTYLES';
        TBoolMultiGet.AssignGetClass(av);
        av[deMask]:=ArrayAsList(a,mniDlm);
        CreateFld(av);
        
        av[deCaption]:='Текст';
        av[deNameRecFld]:='FORECOLOR';
        ColorGet.AssignGet(av);
        av[deMask]:='';
        CreateFld(av);
        
        av[deCaption]:='Фон';
        av[deNameRecFld]:='BACKCOLOR';
        CreateFld(av);
      end;
    end;
    tf:=pointer(Sender); lCallTip := tf.NameRecFld=FontFld(STYLE_CALLTIP); FontToRec(StrToFont(tf.Value));
    deFont.Param['FontStylesCng',deNoVisible]:=bStr[lCallTip];
    deFont.Param['FontStyles',deNoVisible]:=bStr[lCallTip];
    deFont.OnKpProcKey:=deFontKpProcKey; deFont.OnFldExit:=deFontFldExit;
    if deFont.Execute(IfThen(tf.NameRecFld=FontFld(STYLE_LINENUMBER),'Нумерация строк',tf.SayCaption)).Saved then begin
      f.FontName:=TrimRight(rProp['FontName']);
      if f.FontName=sDefault then f.FontName:='';
      f.FontSize:=rProp['FontSize'];
      if lCallTip then f.FontStylesCng:=false
      else begin
        f.FontStylesCng:=rProp['FontStylesCng'];
        if f.FontStylesCng
        then f.FontStyles:=TEdMemoFontStyles(StrToByte(rProp['FontStyles'],FontStyleCnt));
      end;
      f.ForeColor:=RecToColor('ForeColor');
      f.BackColor:=RecToColor('BackColor');
      tf.VarValue:=FontToStr(f); FFontGetSize.cX:=-1; MainRebuild(tf);
    end;
  end;
  result:='Образец';
  DelStack;
end;

procedure TCustomEdMemo.FontGetSize;
var tf: TFldEdit;
  i: longint;
  cnv: TCanvas;
begin
  AddStack('TCustomEdMemo.FontGetSize',Self);
  tf:=pointer(Sender); cnv:=tf.Canvas;
  if tf.NameRecFld=FontFld(STYLE_LINENUMBER) then begin
    FontForCanvas(cnv,StrToFont(tf.Value));
    Size:=cnv.TextExtent(Text); Inc(Size.cX,6);
  end
  else begin
    with FFontGetSize do if cX<0 then begin
      ZeroMemory(@FFontGetSize,SizeOf(FFontGetSize));
      for i:=low(CngFont) to high(CngFont) do begin
        FontForCanvas(cnv,StrToFont(rProp[FontFld(CngFont[i].an[0])]));
        MaxSelf(FFontGetSize,cnv,Text);
      end;
      Inc(cX,6);
    end;
    Size:=FFontGetSize;
  end;
  DelStack;
end;

procedure TCustomEdMemo.FontGetPaint;
var tf: TFldEdit;
  f: TEdMemoFont;
begin
  AddStack('TCustomEdMemo.FontGetPaint',Self);
  tf:=pointer(Sender); f:=StrToFont(tf.Value);
  with tf.Canvas do begin
    FontForCanvas(tf.Canvas,f);
    Brush.Color:=IfThen(f.BackColor=clDefault,
      IfThen(tf.NameRecFld=FontFld(STYLE_LINENUMBER),clBtnFace,CurSchem.IfThenColor(dColor1,clWindow)),
      f.BackColor);
  end;
  FontGet.DrawText(tf,Text);
  DelStack;
end;

class procedure TCustomEdMemo.deFontFldChange;
begin
  AddStack('TCustomEdMemo.deFontFldChange');
  with TFldEdit(Sender) do if NameRecFld='FONTSTYLESCNG'
  then deFont.SetReadOnly('FontStyles',not VarValue);
  DelStack;
end;

procedure TCustomEdMemo.deFontFldExit;
var FontStyles: TEdMemoFontStyles;
begin
  AddStack('TCustomEdMemo.deFontFldExit',Self);
  with TFldEdit(Sender) do if NameRecFld='FONTSTYLESCNG' then
    if not VarValue then begin
      if Assigned(CurSchem) then FontStyles:=CurSchem.Font1.Style else FontStyles:=[];
      FontStylesToRec(FontStyles); deFont.Read('FontStyles');
    end;
  DelStack;
end;

procedure TCustomEdMemo.deFontKpProcKey;
begin
  AddStack('TCustomEdMemo.deFontKpProcKey',Self);
  if Ask(['Установить значения всех параметров по умолчанию ?']) then begin
    with deProp.PanelEdit do
      FontToRec(PropDef[true].aFont[Int0(System.Copy(FldActive.NameRecFld,2,MaxInt))]);
    deFont.PanelEdit.FldReadAll;
  end;
  DelStack;
end;

class procedure TCustomEdMemo.dePropFldChange;
var fl: boolean;
begin
  AddStack('TCustomEdMemo.dePropFldChange');
  with TFldEdit(Sender),deProp do
    if NameRecFld='EDGEMODE'
      then SetReadOnly(['EdgeColumn','EdgeColor'],VarValue=sciEdgeNone)
    else if NameRecFld='MARKERTYPE'
      then SetReadOnly(['MarkerFore','MarkerBack','FoldHi','FoldLo','FoldDrawFlags'],VarValue=MarkerTypeNone)
    else if NameRecFld='MOUSEDWELL' then begin
      fl:=not VarValue; SetReadOnly('MouseDwellSec10',fl); SetReadOnly('MouseDwellSec1',fl,ogReadOnlyNoVsbl);
    end;
  DelStack;
end;

procedure TCustomEdMemo.dePropKpProcKey;
var pe: TPanelEdit;
begin
  AddStack('TCustomEdMemo.dePropKpProcKey',Self);
  if Ask(['Установить значения всех параметров по умолчанию ?']) then begin
    PropToRec(PropDef[true]); deProp.PanelEdit(pe);
    pe.FldReadAll; FFontGetSize.cX:=-1; MainRebuild(pe);
  end;
  DelStack;
end;

function TCustomEdMemo.IniToProp;
var Sect: string;
  procedure ReadColor(const nmf: string; var cl: TColor);
  begin
    AddStack('TCustomEdMemo.IniToProp.ReadColor',Self);
		cl:=StringToColor(InitFIni[fiSchem].ReadString(Sect,nmf,ColorToString(cl)));
    DelStack;
  end;
  procedure ReadFont(n: TEdMemoFontList);
  var s: string;
  begin
    AddStack('TCustomEdMemo.IniToProp.ReadFont',Self);
    s:=InitFIni[fiSchem].ReadString(Sect,StrNum('F',n,2));
    if not empty(s) then result.aFont[n]:=StrToFont(s);
    DelStack;
  end;
var i,j: longint;
begin
  AddStack('TCustomEdMemo.IniToProp',Self);
  if (GetPropEx or BoundEx) and Assigned(InitFIni) then begin
    result:=PropDef[true]; Sect:=ClassName;
    with result,InitFIni[fiSchem] do begin
      for i:=low(CngFont) to high(CngFont) do with CngFont[i] do begin
        ReadFont(an[0]);
        for j:=1 to high(an) do aFont[an[j]]:=aFont[an[0]];
      end;
      ReadColor('SelFore',SelFore);
      ReadColor('SelBack',SelBack);
      CaretWidth:=ReadInteger(Sect,'CaretWidth',CaretWidth);
      ReadColor('CaretFore',CaretFore);
      ReadColor('CaretBack',CaretBack);
      AutoClose:=ReadInteger(Sect,'AutoClose',AutoClose);
      if emoEdge in Cng then begin
        EdgeMode:=sciEdgeType(ReadInteger(Sect,'EdgeMode',byte(EdgeMode)));
        EdgeColumn:=ReadInteger(Sect,'EdgeColumn',EdgeColumn);
        ReadColor('EdgeColor',EdgeColor);
      end;
      if emoLineNumber in Cng then begin
        LineNumber:=ReadBool(Sect,'LineNumber',LineNumber);
        ReadFont(STYLE_LINENUMBER);
        ReadColor('BookMarkFore',BookMarkFore);
        ReadColor('BookMarkBack',BookMarkBack);
      end;
      if emoFolding in Cng then begin
        MarkerType:=ReadInteger(Sect,'MarkerType',MarkerType);
        ReadColor('MarkerFore',MarkerFore);
        ReadColor('MarkerBack',MarkerBack);
        ReadColor('FoldHi',FoldHi);
        ReadColor('FoldLo',FoldLo);
        FoldDrawFlags:=TEdMemoFoldDrawFlags(byte(ReadInteger(Sect,'FoldDrawFlags',byte(FoldDrawFlags))));
      end;
      if emoCallTip in Cng then begin
        ReadFont(STYLE_CALLTIP);
        ReadColor('ForeHlt',ForeHlt);
        if ReadBool(Sect,'MouseDwell',MouseDwellTime<>SC_TIME_FOREVER) then begin
          if ValueExists(Sect,'MouseDwellSec') then begin
            WriteInteger(Sect,'MouseDwellSec10',ReadInteger(Sect,'MouseDwellSec')*10);
            DeleteKey(Sect,'MouseDwellSec');
          end;
          MouseDwellTime:=ReadInteger(Sect,'MouseDwellSec10',MouseDwellTime div 100)*100;
        end
        else MouseDwellTime:=SC_TIME_FOREVER;
        CallTip:=ReadBool(Sect,'CallTip',CallTip);
      end;
      for i:=0 to ReadSectionValues(Sect+'.Templates',Templates)-1 do StrTranSelf(Templates[i],cCRLF,CRLF);
    end;
  end
  else result:=PropDef[false];
  DelStack;
end;

procedure TCustomEdMemo.PropToRec;
  procedure FontToRec(n: TEdMemoFontList);
  begin
    AddStack('TCustomEdMemo.PropToRec.FontToRec',Self);
    rProp[FontFld(n)]:=FontToStr(Prop.aFont[n]);
    DelStack;
  end;
var i: longint;
  ls: TTemplList;
  p: PTemplInf;
begin
  AddStack('TCustomEdMemo.PropToRec',Self);
  for i:=low(CngFont) to high(CngFont) do FontToRec(CngFont[i].an[0]);
  with Prop do begin
    ColorToRec('SelFore',SelFore);
    ColorToRec('SelBack',SelBack);
    rProp['CaretWidth']:=CaretWidth;
    ColorToRec('CaretFore',CaretFore);
    ColorToRec('CaretBack',CaretBack);
    rProp['AutoClose']:=ByteToStr(AutoClose,aclCnt);
    if emoEdge in Cng then begin
      rProp['EdgeMode']:=EdgeMode;
      rProp['EdgeColumn']:=EdgeColumn;
      ColorToRec('EdgeColor',EdgeColor);
    end;
    if emoLineNumber in Cng then begin
      rProp['LineNumber']:=LineNumber;
      FontToRec(STYLE_LINENUMBER);
  		ColorToRec('BookMarkFore',BookMarkFore);
  		ColorToRec('BookMarkBack',BookMarkBack);
    end;
    if emoFolding in Cng then begin
      rProp['MarkerType']:=MarkerType;
  		ColorToRec('MarkerFore',MarkerFore);
  		ColorToRec('MarkerBack',MarkerBack);
  		ColorToRec('FoldHi',FoldHi);
  		ColorToRec('FoldLo',FoldLo);
      rProp['FoldDrawFlags']:=ByteToStr(byte(FoldDrawFlags),FoldDrawFlagCnt);
    end;
    if emoCallTip in Cng then begin
      FontToRec(STYLE_CALLTIP);
      ColorToRec('ForeHlt',ForeHlt);
      rProp['MouseDwell'] := MouseDwellTime<>SC_TIME_FOREVER;
      rProp['MouseDwellSec10']:=IfThen(rProp['MouseDwell'],MouseDwellTime div 100,10);
      rProp['CallTip']:=CallTip;
    end;
    ls:=TTemplList.Create;
    try
      ls.Fill(Self,Prop); ls.Sorted:=false;
      for i:=0 to ls.Count-1 do begin
        p:=ls.GetObj(i); IncL(ls,i,bStr[p.lUser],'='+StrTran(p.cont,CRLF,cCRLF));
      end;
      rProp['Templates']:=ls.Text;
    finally
      ls.Free;
    end;
  end;
  DelStack;
end;

procedure TCustomEdMemo.MoveCaret;
var newCaret: TFMemoCaret;
  tl: TKeyLb;
begin
	AddStack('TCustomEdMemo.MoveCaret',Self);
  newCaret.Line:=CurrentLineNumber; newCaret.Pos:=CurrentCol; newCaret.Len:=SelLength;
	if not((oldCaret.Line=newCaret.Line) and (oldCaret.Pos=newCaret.Pos) and (oldCaret.Len=newCaret.Len)) then begin
    EnabledItem; FUserListShow(false); DoMoveCaret(oldCaret,newCaret); oldCaret:=newCaret;
  end;
  if Focused then if FormKeyLb(Control,tl) then SetKeyLink(tl);
  DelStack;
end;

procedure TCustomEdMemo.SetKeyLink;
  procedure SetKey(usl: boolean; key: longint; const hnt: string);
  begin
  	AddStack('TCustomEdMemo.SetKeyLink.SetKey',Self);
    if usl then tl.SetKey(key,'',hnt,ProcKey,'customedmemo',kmEdit) else tl.DelKey(key,'customedmemo');
    DelStack;
  end;
var p,i: longint;
  InLink: boolean;
begin
  AddStack('TCustomEdMemo.SetKeyLink',Self);
  if IsSci then begin
    p:=GetCurrentPos; InLink:=PosInLink(p,i); Inc(p);
    SetKey(not ReadOnly and (not InLink or (p=LinkPos(i))),K_Ctrl_F7,'Добавить ссылку');
    SetKey(InLink or InRange(i,0,lsLink.Count-1) and (p=LinkEnd(i)),K_Ctrl_Enter,'Открыть ссылку');
    SetKey(InLink and (ExtractFileDrive(LinkText(i))<>''),K_Alt_Enter,'Открыть папку ссылки');
  end;
  DelStack;
end;

function TCustomEdMemo.LinkPos;
begin
  result:=lsLink[i];
end;

function TCustomEdMemo.LinkLen;
begin
  result:=lsLink.IntObj(i);
end;

function TCustomEdMemo.LinkEnd;
begin
  result:=LinkPos(i)+LinkLen(i);
end;

function TCustomEdMemo.PosInLink;
begin
  AddStack('TCustomEdMemo.PosInLink',Self);
  result:=false;
  if lsLink.Count>0 then begin
    Inc(p);
    if not lsLink.Find(p,i) then Dec(i);
    if InRange(i,0,lsLink.Count-1) then result:=InRange(p,LinkPos(i),LinkEnd(i)-1);
  end;
  DelStack;
end;

function TCustomEdMemo.LinkText;
begin
  AddStack('TCustomEdMemo.LinkText',Self);
  result:=Copy(Text,LinkPos(i),LinkLen(i));
  DelStack;
end;

class procedure TCustomEdMemo.deLinkPnlCngKey;
begin
  AddStack('TCustomEdMemo.deLinkPnlCngKey');
  case tb.Key of
    K_F10: tb.Caption:='';
    K_Enter: tb.Caption:='Добавить';
  end;
  DelStack;
end;

procedure TCustomEdMemo.DoMoveCaret;
begin
  AddStack('TCustomEdMemo.DoMoveCaret',Self);
  if Assigned(OnMoveCaret) then OnMoveCaret(oldCaret,newCaret);
  DelStack;
end;

procedure TCustomEdMemo.CreatingCaret;
var cnv: TCanvas;
begin
  AddStack('TCustomEdMemo.CreatingCaret',Self);
  if Focused then begin
    cnv:=GetParentForm(Control).Canvas; cnv.Font.Assign(Font);
    if InsModeOverride
    then CreateCaret(Control.Handle,0,CanvasMaxW(cnv),CanvasMaxH(cnv))
    else CreateCaret(Control.Handle,0,0,CanvasMaxH(cnv));
    ShowCaret(Control.Handle); Control.Invalidate;
  end;
  DelStack;
end;

procedure TCustomEdMemo.doSciModified;
var i1,i2,p: longint;
  fl1,fl2,lUnit: boolean;
begin
  AddStack('TCustomEdMemo.doSciModified',Self);
  if modificationType and (SC_MOD_BEFOREINSERT or SC_MOD_BEFOREDELETE) > 0 then begin
    EnabledItem(K_Ctrl_Z);
    if KeywordN(kwFindAll).Count>0 then begin
      KeywordBeginUpdate; KeywordN(kwFindAll).Clear; KeywordEndUpdate; Colourise(0,GetTextLength);
    end;
  end;
  if IsSci then begin
    if modificationType and SC_MOD_INSERTTEXT > 0 then begin
      if linesAdded>0 then SetLineNumberMarginWidth(linesAdded);
      if not TextSetting then begin
        if PosInLink(position,i1) then
          if LinkPos(i1)=position+1 then Dec(i1) else lsLink.IncObj(i1,len);
        for i1:=i1+1 to lsLink.Count-1 do lsLink.IncD(i1,len);
      end;
    end;
    if modificationType and SC_MOD_DELETETEXT > 0 then if not TextSetting then if lsLink.Count>0 then begin
      p:=position; fl1:=PosInLink(p,i1); fl2:=PosInLink(p+len,i2);
      // Стирается до первого символа ссылки
      if fl2 then if p+len+1=LinkPos(i2) then fl2:=PosInLink(p+len-1,i2);
      AndD(fl2,i2>i1); lUnit:=false; Inc(p);
      if fl1 then // Начало удаляемого блока в первой ссылке
        if (p=LinkPos(i1)) and (len>=LinkLen(i1))
        // Удаляется первая ссылка
        then Dec(i1)
        // Последняя ссылка объединяются в первую
        else if fl2 then begin
          lUnit:=true; lsLink.Objects[i1]:=pointer((p-LinkPos(i1))+(LinkEnd(i2)-p-len));
        end
        // Уменьшить длину первой ссылки на длину удаляемого в ней текста
        else lsLink.IncObj(i1,-min(len,LinkEnd(i1)-p));
      Inc(i1);
      if fl2 then // Конец удаляемого блока в последней ссылке и последняя ссылка больше первой
        if (p+len=LinkEnd(i2)) or lUnit
        // Удаляется последняя ссылка
        then Inc(i2)
        // Уменьшить длину последней ссылки на длину удаляемого в ней текста
        else begin
          lsLink.IncObj(i2,LinkPos(i2)-p-len); lsLink.IncD(i2);
        end
      else Inc(i2);
      repeat // Удаление ссылок
        Dec(i2);
        if i2<i1 then break;
        lsLink.Delete(i1);
      until false;
      for i1:=i1 to lsLink.Count-1 do lsLink.IncD(i1,-len);
    end;
  end;
  DelStack;
end;

procedure TCustomEdMemo.doSciSavePointReached;
begin
end;

procedure TCustomEdMemo.doSciDwellStart;
begin
end;

procedure TCustomEdMemo.doSciDwellEnd;
begin
end;

procedure TCustomEdMemo.doSciCalltipClick;
begin
end;

procedure TCustomEdMemo.doSciStyleNeeded;
begin
end;

procedure TCustomEdMemo.doSciUpdateUI;
begin
  AddStack('TCustomEdMemo.doSciUpdateUI',Self);
  MoveCaret;
  DelStack;
end;

procedure TCustomEdMemo.KeywordBeginUpdate;
var i: longint;
begin
  if IsSci then Sci.Keyword0.BeginUpdate
  else with NoSci do for i:=low(aKeyWord) to high(aKeyWord) do aKeyWord[i].BeginUpdate;
end;

procedure TCustomEdMemo.KeywordBeginUpdate(var lMod: boolean);
begin
  if not lMod then begin
    lMod:=true; KeywordBeginUpdate;
  end;
end;

procedure TCustomEdMemo.KeywordEndUpdate;
var i: longint;
begin
  if IsSci then Sci.Keyword0.EndUpdate
  else with NoSci do for i:=low(aKeyWord) to high(aKeyWord) do aKeyWord[i].EndUpdate;
end;

function TCustomEdMemo.KeywordEndUpdate(lMod: boolean): boolean;
begin
  if lMod then KeywordEndUpdate;
  result:=lMod;
end;

procedure TCustomEdMemo.MnProcUndo;
begin
  AddStack('TCustomEdMemo.MnProcUndo',Self);
  if IsSci then Sci.Undo else NoSci.Undo;
  DelStack;
end;

procedure TCustomEdMemo.MnProcClear;
begin
  AddStack('TCustomEdMemo.MnProcClear',Self);
  Clear;
  DelStack;
end;

procedure TCustomEdMemo.MnProcCut;
begin
	AddStack('TCustomEdMemo.MnProcCut',Self);
  if IsSci then Sci.Cut else NoSci.CutToClipboard;
  DelStack;
end;

procedure TCustomEdMemo.MnProcCopy;
begin
	AddStack('TCustomEdMemo.MnProcCopy',Self);
  if IsSci then Sci.Copy else NoSci.CopyToClipboard;
  DelStack;
end;

procedure TCustomEdMemo.MnProcPaste;
begin
	AddStack('TCustomEdMemo.MnProcPaste',Self);
  if IsSci then Sci.Paste else NoSci.PasteFromClipboard;
  DelStack;
end;

procedure TCustomEdMemo.MnProcDelLine;
var i,r,c: longint;
begin
	AddStack('TCustomEdMemo.MnProcDelLine',Self);
  r:=CurLineStartPos; c:=CurrentCol; i:=CurrentLineNumber; Lines.Delete(i);
  if i<Lines.Count then MinSelf(c,Length(Lines[i])) else c:=0;
  SetSelection(r+c);
  DelStack;
end;

procedure TCustomEdMemo.MnProcSelAll;
begin
  AddStack('TCustomEdMemo.MnProcSelAll',Self);
  SetSelection(0,GetTextLength);
  DelStack;
end;

procedure TCustomEdMemo.MnProcUpCase;
begin
  SelProcKey(AnsiUpperCase);
end;

procedure TCustomEdMemo.MnProcDnCase;
begin
  SelProcKey(AnsiLowerCase);
end;

procedure TCustomEdMemo.MnProcCngLang;
begin
  SelProcKey(CngLanguage);
end;

function FDelTrim(const s: string): string;
var a: TArrStr;
  i,l: longint;
begin
  AddStack('FEdText.FDelTrim');
  l:=LsArrDynamic(s,a,CRLF);
  for i:=0 to l-1 do DelTrimSelf(a[i]);
  result:=ArrayAsList(a,CRLF,l);
  DelStack;
end;

procedure TCustomEdMemo.MnProcDelTrim;
begin
  SelProcKey(FDelTrim);
end;

function TCustomEdMemo.PosFirstNoSpace(line: longint): longint;
var s: string;
begin
  AddStack('TCustomEdMemo.PosFirstNoSpace',Self);
  s:=Lines[line]; result:=PositionFromLine(line)+Length(s)-Length(TrimLeft(s));
  DelStack;
end;

function TCustomEdMemo.PosFirstNoSpace: longint;
begin
  result:=PosFirstNoSpace(CurrentLineNumber);
end;

function TCustomEdMemo.GetNextQuote;
const aQ: TArrBoolStr = ('«','»');
var fl: boolean;
  i,k: longint;
begin
  AddStack('TCustomEdMemo.GetNextQuote',Self);
  fl:=false;
  for i:=SelStart-1 downto 0 do begin
    k:=AnsiIndexStr(Chr(GetCharAt(i)),aQ);
    if k>=0 then begin
      fl:=not boolean(k); break;
    end;
  end;
  result:=aQ[fl][1];
  DelStack;
end;

procedure TCustomEdMemo.FoldCollapse;
var l: longint;
begin
  AddStack('TCustomEdMemo.FoldCollapse',Self);
  if IsSci then with Sci do begin
    l:=CurrentLineNumber;
    if (GetLastChild(l,-1)=l) or not GetFoldExpanded(l)
    then SetSelection(PosFirstNoSpace(GetFoldParent(l)))
    else ToggleFold(l);
  end;
  DelStack;
end;

procedure TCustomEdMemo.FoldExpand;
var l: longint;
begin
  AddStack('TCustomEdMemo.FoldExpand',Self);
  if IsSci then with Sci do begin
    l:=CurrentLineNumber;
    if (GetLastChild(l,-1)=l) or GetFoldExpanded(l) then begin
      for l:=l+1 to Lines.Count-1 do
        if GetLastChild(l,-1)<>l then begin
          SetSelection(PosFirstNoSpace(l)); break;
        end;
    end
    else ToggleFold(l);
  end;
  DelStack;
end;

procedure TCustomEdMemo.FoldExpandAll;
var l: longint;
begin
  AddStack('TCustomEdMemo.FoldExpandAll',Self);
  if IsSci then with Sci do
    for l:=0 to Lines.Count-1 do
      if not GetFoldExpanded(l) then ToggleFold(l);
  DelStack;
end;

procedure TCustomEdMemo.DragOver;
begin
	AddStack('TCustomEdMemo.DragOver',Self);
  if Source=Control then begin
    if (State=dsDragEnter) and not lDrag then begin
    	lDrag:=true; sCalc:=NumInStr(Text,PositionFromPoint(X,Y)+1);
    end;
    Accept := sCalc<>'';
  end
  else if not ReadOnly
  	then Accept:=MsgCalc(pointer(Source),clcGet,@dCalc);
  DelStack;
end;

// Взять текст из калькулятора
procedure TCustomEdMemo.DragDrop;
begin
	AddStack('TCustomEdMemo.DragDrop',Self);
	if NoFromCalc(Owner,dCalc,x,y) then InsTextPos(FloatToStr(dCalc),X,Y);
  DelStack;
end;

procedure TCustomEdMemo.DoEndDrag;
begin
	AddStack('TCustomEdMemo.DoEndDrag',Self);
  sCalc:=''; lDrag:=false;
  DelStack;
end;

// Передать текст в калькулятор
procedure TCustomEdMemo.WMCalc;
begin
	AddStack('TCustomSci.WMCalc',Self);
	inherited;
  if (Message.Operation=clcGet) and (sCalc<>'') then begin
		Message.ps^:=Float0(sCalc); Message.result:=1;
  end;
  DelStack;
end;

procedure TCustomEdMemo.IncCng;
begin
  Cng:=Cng+Incl;
end;

procedure TCustomEdMemo.WMGetDlgCode;
begin
  AddStack('TCustomSci.WMGetDlgCode',Self);
  inherited;
  if WantTabs and not ReadOnly
  then Or_D(Message.Result,DLGC_WANTTAB)
  else Message.Result := Message.Result xor DLGC_WANTTAB;
  DelStack;
end;

procedure TCustomEdMemo.WMInsModeCng;
begin
	AddStack('TCustomSci.WMInsModeCng',Self);
  if IsSci then Sci.DivOptions.OverType:=InsModeOverride else CreatingCaret;
  DelStack;
end;

function TCustomEdMemo.GetBookMark;
begin
  AddStack('TCustomEdMemo.GetBookMark',Self);
  result:=FBookMark[Key].Crd;
  DelStack;
end;

procedure TCustomEdMemo.SetBookMark;
var Prop: TEdMemoProp;
  i: TEdMemoBMList;
  lSet,fl: boolean;
  mn: TMenuItem;
begin
  AddStack('TCustomEdMemo.SetBookMark',Self);
  with FBookMark[Key] do begin
    Crd:=Value; lSet := Crd.Col<>NegDef;
    if lSet then begin
      Prop:=IniToProp;
      if IsSci then with Sci do if Gutter1.Width=0 then SetMarginWidth(Prop,Gutter1,true);
    end
    else begin
      fl:=true;
      for i:=low(FBookMark) to high(FBookMark) do if FBookMark[i].Crd.Col<>NegDef then begin
        fl:=false; break;
      end;
      if fl then if IsSci then Sci.Gutter1.Width:=0;
    end;
    if IsSci then begin
      if Assigned(Mark) then Mark.ClearAll
      else if lSet then begin
        Mark:=TSciMarker.Create(Sci,Key-low(FBookMark));
        Mark.MarkerType:=SC_MARK_CHARACTER+Key; BookMarkSetProp(Prop,Key);
      end;
      if lSet then Mark.Add(Crd.Line);
    end;
    if Assigned(MainMn) then begin
      if MainMn.SeekItem(kmEdit,Key_User+1,mn) then mn[Key-low(FBookMark)].Checked:=lSet;
      if MainMn.SeekItem(kmEdit,Key_User+2,mn) then mn[Key-low(FBookMark)].Enabled:=lSet;
    end;
  end;
  DelStack;
end;

class procedure TCustomEdMemo.MNBookMarkDrawItem;
begin
  AddStack('TCustomEdMemo.MNBookMarkDrawItem');
  TMenuItem(Sender).Parent.OnDrawItem(Sender,ACanvas,ARect,Selected);
  DelStack;
end;

// Вставить текст в текущую позицию
procedure TCustomEdMemo.InsText;
var i: longint;
begin
	AddStack('TCustomEdMemo.InsText',Self);
  if SelLength>0 then Clear;
  i:=GetCurrentPos; InsertText(i,s); SetSelection(i+Length(s));
  DelStack;
end;

// Вставить текст в точку (X,Y)
procedure TCustomEdMemo.InsTextPos;
var ss,sl: longint;
begin
	AddStack('TCustomEdMemo.InsTextPos',Self);
	ss:=SelStart; sl:=SelLength;
  SetSelection(PositionFromPoint(X,Y)); InsText(s);
  SetSelection(ss,sl);
  DelStack;
end;

function TCustomEdMemo.GetText;
var i,offs: longint;
begin
  AddStack('TCustomEdMemo.GetText',Self);
  if Assigned(Self) then begin
    result:=Text;
    if IsSci then begin
      offs:=0;
      for i:=0 to lsLink.Count-1 do begin
        Insert(cLink,result,offs+LinkPos(i)); Inc(offs);
        Insert(cLink,result,offs+LinkEnd(i)); Inc(offs);
      end;
    end;
  end
  else result:='';
  DelStack;
end;

procedure TCustomEdMemo.SetText;
var s: string;
  p,pe,l: longint;
begin
  AddStack('TCustomEdMemo.SetText',Self);
  s:=v;
  if IsSci then begin
    KeywordBeginUpdate; lsLink.Clear; pe:=1;
    while IsPos(p,cLink,s,pe) do begin
      if IsPos(pe,cLink,s,p+1) then Dec(pe) else pe:=Length(s);
      l:=pe-p; lsLink.Add(p,l); Delete(s,p,1); Delete(s,pe,1);
    end;
    KeywordEndUpdate;
  end;
  TextSetting:=true; Text:=s; TextSetting:=false;
  DelStack;
end;

procedure TCustomEdMemo.IncText;
begin
  SetText(Text+d2);
end;

procedure TCustomEdMemo.HideSelection;
begin
  if IsSci then Sci.HideSelect:=Value else NoSci.HideSelection:=Value;
end;

function TCustomEdMemo.SelProcKey;
var ss,sl: longint;
begin
  AddStack('TCustomEdMemo.SelProcKey',Self);
  result := Visible and Enabled and not ReadOnly;
  if result then if Assigned(Proc) then begin
    sl:=SelLength;
    if sl>0 then begin
    	ss:=SelStart; InsText(Proc(System.Copy(Text,ss+1,sl))); SetSelection(ss,sl);
    end;
  end;
  DelStack;
end;

procedure TCustomEdMemo.PropFontAdd(const cCaption: string; const can: array of TEdMemoFontList);
var i,j: longint;
begin
  AddStack('TCustomEdMemo.PropFontAdd',Self);
  i:=Length(CngFont); SetLength(CngFont,i+1);
  with CngFont[i] do begin
    Caption:=cCaption; SetLength(an,Length(can));
    for j:=low(an) to high(an) do an[j]:=can[j];
  end;
  DelStack;
end;

procedure TCustomEdMemo.PropFontAdd(const cCaption: string; n: TEdMemoFontList);
begin
  AddStack('TCustomEdMemo.PropFontAdd(1)',Self);
  PropFontAdd(cCaption,[n]);
  DelStack;
end;

procedure TCustomEdMemo.PropFontAdd(const a: array of TEdMemoFontDef);
var i: byte;
begin
  AddStack('TCustomEdMemo.PropFontAdd(d)',Self);
  for i:=low(a) to high(a) do with a[i] do PropFontAdd(name,n);
  DelStack;
end;

procedure TCustomEdMemo.PropFontAddBrack;
begin
  AddStack('TCustomEdMemo.PropFontAddBrack',Self);
  PropFontAdd('Парные скобки',STYLE_BRACELIGHT);
  PropFontAdd('Ошибка парности скобок',STYLE_BRACEBAD);
  DelStack;
end;

function TCustomEdMemo.IsStyleCng;
begin
  AddStack('TCustomEdMemo.IsStyleCng',Self);
  if IsSci then with Sci do
    result := not((Style0[n].FontName=Font.Name)
    and (Style0[n].FontSize=Font.Size)
    and (Style0[n].FontStyles=Font.Style)
    and (ColorToRGB(Style0[n].ForeColor)=ColorToRGB(Font.Color))
    and (ColorToRGB(Style0[n].BackColor)=ColorToRGB(Color)))
  else result:=false;
  DelStack;
end;

procedure TCustomEdMemo.WMHelp;
begin
end;

procedure TCustomEdMemo.WMPaint;
var dc: HDC;
  i,j,x,y,p,xc,yc,hc,bw: longint;
  s: string;
  sz: TSize;
  r: TRect;
  cnv: TCanvas;
begin
  AddStack('TCustomEdMemo.WMPaint',Self);
  if IsSci then begin
    i:=lsLink.Count;
    if i>0 then begin
      dc:=GetWindowDC(Control.Handle);
      try
        if dc<>0 then begin
          s:=Text;
          with Sci do begin
            cnv:=GetParentForm(Control).Canvas;
            FontForCanvas(cnv.Font,IniToProp.aFont[SCE_OURLIB_WORD_LINK]);
            SelectObject(dc,cnv.Font.Handle);
            SetBkMode(dc, OPAQUE);
            hc:=0;
            xc:=0; yc:=0; //Variable might not have been initialized
            p:=GetCurrentPos; bw:=IfThen(BorderStyle=bsSingle,2);
            for i:=0 to i-1 do
              for j:=LinkPos(i) to LinkEnd(i)-1 do begin
                x:=bw+PointXFromPosition(j-1); y:=bw+PointYFromPosition(j-1);
                ZeroMemory(@sz,SizeOf(sz));
                GetTextExtentPoint32(dc,@s[j],1,sz);
                r:=Rect(max(bw,x),max(bw,y),min(x+sz.cx,Width-bw),min(y+sz.cy,Height-bw));
                if (r.Right>r.Left) and (r.Bottom>r.Top) then begin
                  if Focused and InRange(j-1,SelStart,SelStart+SelLength-1) then begin
                    SetBkColor(dc,ColorToRGB(Colors.SelBack));
                    SetTextColor(dc,ColorToRGB(Colors.SelFore));
                  end
                  else begin
                    SetBkColor(dc,ColorToRGB(Color));
                    SetTextColor(dc,ColorToRGB(cnv.Font.Color));
                  end;
                  ExtTextOut(dc,r.Left,r.Top,ETO_CLIPPED or ETO_OPAQUE,@r,@s[j],1,nil);
                  if j-1=p then begin
                    xc:=x; yc:=y; hc:=r.Bottom-r.Top;
                  end;
                end;
              end;
            if hc>0 then begin
              cnv.Pen.Width:=GetCaretWidth;
              SelectObject(dc,cnv.Pen.Handle);
              MoveToEx(dc,xc,yc,nil); LineTo(dc,xc,yc+hc-cnv.Pen.Width);
            end;
          end;
        end;
      finally
        ReleaseDC(Control.Handle,dc);
      end;
    end;
  end;
  DelStack;
end;

procedure TCustomEdMemo.WMHelpFill;
begin
  AddStack('TCustomSci.WMHelpFill',Self);
  with Message do case Oper of
    hlpAdd: begin
      aHelp:=pArr; nHelp:=high(aHelp^); onHelp:=nHelp; HelpFill; HelpDelEmpPrior;
      SetLength(aHelp^,nHelp+1);
    end;
    hlpLinkObj: pLinkObj^:='клавиши редактирования';
  end;
  DelStack;
end;

procedure TCustomEdMemo.WMApplHint;
begin
end;

procedure TCustomEdMemo.HelpHead;
begin
  AddStack('TCustomEdMemo.HelpHead',Self);
  Inc(nHelp);
  if nHelp=Length(aHelp^) then SetLength(aHelp^,IfThen(nHelp=0,10,nHelp shl 1));
  with aHelp^[nHelp] do begin
    part:=Head; txt:=''; avk:=nil;
  end;
  DelStack;
end;

procedure TCustomEdMemo.HelpDelEmpPrior;
var l,j,p,lnm: longint;
  ls: TStringList;
begin
  AddStack('TCustomEdMemo.HelpDelEmpPrior',Self);
  if nHelp>onHelp then with aHelp^[nHelp] do begin
    ls:=TStringList.Create;
    try
      ls.Text:=txt; j:=1;
      while j<ls.Count do
        if System.Copy(ls[j],Pos(cHlp,ls[j])+1,MaxInt)='' then ls.Delete(j) else Inc(j);
      l:=ls.Count;
      if l<2 then Dec(nHelp)
      else begin
        lnm:=0; Dec(l);
        for j:=1 to l do MaxSelf(lnm,Pos(cHlp,ls[j]));
        for j:=1 to l do begin
          p:=Pos(cHlp,ls[j]);
          ls[j]:=HelpBoldStr(Padr(LeftStr(ls[j],p-1),lnm),SCE_OURLIB_HELP_PART)+System.Copy(ls[j],p+1,MaxInt);
        end;
        txt:=ls.Text;
      end;
    finally
      ls.Free;
    end;
  end;
  DelStack;
end;

procedure TCustomEdMemo.HelpKey(const akey: array of variant; const hint: string; const txt: string = ''; lSeek: boolean = false);
var s: string;
  i,l: longint;
  a: TArrStr;
begin
  AddStack('TCustomEdMemo.HelpKey',Self);
  if txt='' then begin
    s:='';
    for i:=low(akey) to high(akey) do DlmBetwSelf(s,KeyToTxt(akey[i]),',');
  end
  else s:=txt;
  with aHelp^[nHelp] do begin
    if lSeek then begin
      lSeek:=false; l:=LsArrDynamic(txt,a,CRLF);
      for i:=1 to l-1 do if LeftStr(a[i],Pos(cHlp,a[i])-1)=s then begin
        a[i]:=s+cHlp+hint; txt:=ArrayAsList(a,CRLF,l); lSeek:=true; break;
      end;
    end;
    if not lSeek then begin
      IncD(txt,CRLF+s+cHlp+hint); AddFromVArr(avk,akey);
    end;
  end;
  DelStack;
end;

procedure TCustomEdMemo.HelpKey(key: longint; const hint: string; lSeek: boolean = false);
begin
  HelpKey([key],hint,'',lSeek);
end;

procedure TCustomEdMemo.HelpKey(const txt,hint: string; lSeek: boolean = false);
begin
  HelpKey([],hint,txt,lSeek);
end;

procedure TCustomEdMemo.HelpFill;
begin
  AddStack('TCustomEdMemo.HelpFill',Self);
  HelpPart(EdMemoHelpPartCurs);
  if GetTextLength>0 then HelpPart(EdMemoHelpPartSel);
  if not ReadOnly then HelpPart(EdMemoHelpPartCng);
  HelpPart(EdMemoHelpPartClipBrd);
  if IsSci then HelpPart(EdMemoHelpPartZoom);
  if emoLineNumber in Cng then HelpPart(EdMemoHelpPartBookMark);
  if not ReadOnly then HelpPart(EdMemoHelpPartChr);
  if IsSci then if foldFold in Sci.Folding then HelpPart(EdMemoHelpPartFold);
  if emoCallTip in Cng then HelpPart(EdMemoHelpPartCallTip);
  DelStack;
end;

procedure TCustomEdMemo.HelpPart;
var i,CurrentPos,LinePos,LineNum,LineLen,LineCnt,TextLen,FirstVisibleLine,FirstNoVisibleLine,Zoom: longint;
  fl,fl1,NoTextBeg,NoTextEnd,NoLineBeg,NoLineEnd,PosInSp,IsSci,IsSel,NoLastEmpLine,FoldHeader,FoldExpanded: boolean;
begin
  AddStack('TCustomEdMemo.HelpPart',Self);
  HelpDelEmpPrior; HelpHead(Head);
  CurrentPos:=GetCurrentPos; TextLen:=GetTextLength;
  LineNum:=CurrentLineNumber; LinePos:=PositionFromLine(LineNum); LineCnt:=GetLineCount;
  FirstVisibleLine:=GetFirstVisibleLine; FirstNoVisibleLine:=FirstVisibleLine+LinesOnScreen;
  if TextLen=0 then LineLen:=0 else LineLen:=Length(Lines[LineNum]);
  NoTextBeg := CurrentPos>0; NoTextEnd := CurrentPos<TextLen;
  NoLineBeg := CurrentPos>LinePos; NoLineEnd := CurrentPos<LinePos+LineLen;
  PosInSp := CurrentPos<=PosFirstNoSpace; IsSci:=Self.IsSci; IsSel := SelLength>0;
  NoLastEmpLine := LineNum<Lines.Count;
  if Head=EdMemoHelpPartCurs then begin
    if NoTextBeg then HelpKey(K_Left,'На символ влево');
    if NoTextEnd then HelpKey(K_Right,'На символ вправо');
    if LineNum>0 then HelpKey(K_Up,'На предыдущую строку');
    if LineNum<LineCnt-1 then HelpKey(K_Down,'На следующую строку');
    if NoTextBeg then HelpKey(K_Ctrl_Left,'На начало текущего или конец предыдущего слова');
    if NoTextEnd then HelpKey(K_Ctrl_Right,'На конец текущего или начало следующего слова');
    HelpKey(K_Home,IfThen(NoLineBeg,'На начало текущей строки'));
    HelpKey(K_End,IfThen(NoLineEnd,'На конец текущей строки'));
    if IsSci then begin
      fl := Sci.WrapCount(LineNum)>1;
      HelpKey(K_Alt_Home,IfThen(fl,'На начало текущей части строки'));
      HelpKey(K_Alt_End,IfThen(fl,'На конец текущей части строки'));
    end;
    if NoTextBeg then HelpKey(K_Ctrl_Home,'На начало текста');
    if NoTextEnd then HelpKey(K_Ctrl_End,'На конец текста');
    if FirstVisibleLine>0 then HelpKey(K_PgUp,'На предыдущую страницу')
    else if LineNum>0 then HelpKey(K_PgUp,'На первую строку');
    if FirstNoVisibleLine<LineCnt then HelpKey(K_PgDn,'На следующую страницу')
    else if LineNum<LineCnt-1 then HelpKey(K_PgDn,'На последнюю строку');
    if IsSci then if not(Control.TabStop or PosInSp) then HelpKey(K_Shift_Tab,'Влево на величину отступа');
  end
  else if Head=EdMemoHelpPartSel then begin
    HelpKey('Shift+<упр.курсором>','Начать непрерывное выделение');
    if IsSci then HelpKey('Alt+Shift+<упр.курсором>','Начать прямоугольное выделение');
    HelpKey(K_Ctrl_A,'Выделить всё');
  end
  else if Head=EdMemoHelpPartCng then begin
    if IsSel then HelpKey([K_BS,K_Del],'Удалить выделенный фрагмент')
    else begin
      HelpKey(K_BS,IfThen(NoTextBeg,'Удалить символ слева'));
      if NoTextEnd then HelpKey(K_Del,'Удалить символ справа');
    end;
    if NoTextBeg then HelpKey(K_Ctrl_BS,'Удалить с начала текущего или конца предыдущего слова до текущей позиции');
    if NoTextEnd then HelpKey([K_Ctrl_T,K_Ctrl_Del],'Удалить с текущей позиции до конца текущего или начала следующего слова');
    if NoLineBeg then HelpKey('Ctrl+Shift+Backspace','Удалить с начала текущей строки до текущей позиции');
    if NoLineEnd then HelpKey('Ctrl+Shift+Del','Удалить с текущей позиции до конца текущей строки');
    if NoLastEmpLine then HelpKey([K_Ctrl_Y],'Удалить текущую строку',IfThen(IsSci,'Ctrl+Y,Ctrl+Shift+L'));
    if CanUndo then HelpKey([K_Ctrl_Z,IfThen(IsSci,K_Alt_BS)],'Отмена предыдущего действия');
    if IsSci then if Sci.CanRedo then HelpKey('Ctrl+Shift+Z','Отказ от отмены предыдущего действия');
    if not Control.TabStop then begin
      HelpKey(K_Tab,'Увеличить отступ');
      if IsSci and PosInSp and NoLineBeg then HelpKey(K_Shift_Tab,'Уменьшить отступ');
    end;
    HelpKey(K_Enter,'Добавить строку');
    HelpKey(K_Ctrl_D,'Повторить '+IfThen(IsSel,'выделенный фрагмент','строку'));
    if IsSel then begin
      HelpKey(K_Ctrl_Up,'Преобразовать в верхний регистр выделенный фрагмент');
      HelpKey(K_Ctrl_Down,'Преобразовать в нижний регистр выделенный фрагмент');
      HelpKey(K_Ctrl_L,'Изменить язык для выделенного фрагмента');
      HelpKey(K_Alt_F8,'Удалить лишние пробелы в выделенном фрагменте');
    end;
    if LsUser[ulsTempl].Count>0 then HelpKey(aUlsKey[ulsTempl],'Шаблоны');
    if Length(aKeywords)>0 then HelpKey(aUlsKey[ulsKeyword],'Ключевые слова');
    HelpKey(K_Ins,'Переключить режим '+HelpBoldStr('«вставка/замена»'));
  end
  else if Head=EdMemoHelpPartClipBrd then begin
    if IsSel then begin
      HelpKey([K_Ctrl_C,K_Ctrl_Ins],'Копировать выделенный текст в буфер обмена');
      if not ReadOnly then HelpKey([K_Ctrl_X,K_Shift_Del],'Перенести выделенный текст в буфер обмена');
    end;
    {if CanPaste then }HelpKey([K_Ctrl_V,K_Shift_Ins],'Вставить текст из буфера обмена');
    if NoLastEmpLine then HelpKey('Ctrl+Shift+T','Копировать текущую строку в буфер обмена');
  end
  else if Head=EdMemoHelpPartZoom then begin
    Zoom:=Sci.GetZoom;
    if Zoom<20 then HelpKey(K_Ctrl_Plus,'Приблизить');
    if Zoom>-10 then HelpKey(K_Ctrl_Minus,'Удалить');
    if Zoom<>0 then HelpKey(K_Ctrl_Div,'Вернуть исходный масштаб');
  end
  else if Head=EdMemoHelpPartBookMark then begin
    fl:=false;
    for i:=low(FBookMark) to high(FBookMark) do with BookMark[i] do begin
      fl1 := Col<>NegDef;
      HelpKey('Ctrl+Shift+'+Chr(i),IfThen(fl1 and (LineNum=Line),'Снять','Установить')+' закладку '+HelpBoldStr(Chr(i)));
      if fl1 then fl:=true;
    end;
    if fl then HelpKey('Ctrl+Shift+A','Снять все закладки');
    for i:=low(FBookMark) to high(FBookMark) do with BookMark[i] do
      if (Col<>NegDef) and not((LineNum=Line) and (CurrentCol=Col) and (LastVisibleLine=FirstNoVisibleLine-1))
      then HelpKey(K_Ctrl_0+i-low(FBookMark),'Перейти к закладке '+HelpBoldStr(Chr(i)));
  end
  else if Head=EdMemoHelpPartChr then begin
    if BookMark[Ord('2')].Col=NegDef then HelpKey([K_Ctrl_2],GetNextQuote,'Ctrl+"');
    if BookMark[Ord('3')].Col=NegDef then HelpKey([K_Ctrl_3],'#','Ctrl+#');
    HelpKey('Ctrl+<','<');
    HelpKey('Ctrl+>','>');
    HelpKey('Ctrl+[','[');
    HelpKey('Ctrl+]',']');
    HelpKey('Ctrl+|','|');
    HelpKey('Alt+{','{');
    HelpKey('Alt+}','}');
  end
  else if Head=EdMemoHelpPartFold then with Sci do begin
    i:=GetFoldLevel(LineNum); FoldHeader := i and SC_FOLDLEVELHEADERFLAG > 0; FoldExpanded:=GetFoldExpanded(LineNum);
    if FoldHeader or (i and SC_FOLDLEVELNUMBERMASK > SC_FOLDLEVELBASE)
    then HelpKey(K_Alt_Left,IfThen(FoldHeader and FoldExpanded,'Свернуть','Перейти к предыдущему узлу свертки'));
    for i:=LineNum+1 to LineCnt-1 do if GetFoldLevel(i) and SC_FOLDLEVELHEADERFLAG > 0 then begin
      HelpKey(K_Alt_Right,IfThen(FoldHeader and not FoldExpanded,'Развернуть','Перейти к следующему узлу свертки'));
      break;
    end;
    for i:=0 to LineCnt-1 do if (GetFoldLevel(i) and SC_FOLDLEVELHEADERFLAG > 0) and not GetFoldExpanded(i) then begin
      HelpKey(K_Alt_A,'Развернуть все'); break;
    end;
  end
  ;DelStack;
end;

procedure TCustomEdMemo.ExecFind;
begin
  AddStack('TCustomEdMemo.ExecFind',Self);
  WinFindKey(Key,Control,PrFind,[fnoRegistr,fnoWord,fnoDirection,fnoReplace]
    +IfThen(IsSci and (Sci.LanguageManager.LanguageList[0].Lexer='ourlib'),[fnoAll]));
  DelStack;
end;

function TCustomEdMemo.PrFind;
var p,l,cnt: longint;
  s: string;
begin
	AddStack('TCustomEdMemo.PrFind',Self);
  with FindProperty do if Replace then begin
    s:=Text; cnt:=ReplaceInStr(s,sf,sr);
    if cnt>0 then begin
      l:=GetFirstVisibleLine; p:=CurrentLineNumber;
      lines.BeginUpdate; Lines.Text:=s; LineScroll(0,l); CurrentLineNumber:=p; lines.EndUpdate;
      BookMarkRestore;
      result:=not Ask([Format('Заменено: %d.',[cnt]),'Повторить поиск с заменой ?'],true,'Поиск с заменой');
    end
    else result:=false;
  end
  else if Direction=fndAll then begin
    KeywordBeginUpdate;
    KeywordN(kwReserved).Values['s1']:=IfThen(Word,'1','0');
    KeywordN(kwReserved).Values['s2']:=IfThen(Registr,'1','0');
    KeywordN(kwFindAll).Text:=sf;
    KeywordEndUpdate; Colourise(0,GetTextLength); result:=true;
  end
  else begin
    p:=SelStart+1; l:=SelLength; result:=FindInStr(Text,sf,@p,@l);
    if result then SetSelection(p-1,l);
  end;
  DelStack;
end;

procedure TCustomEdMemo.ReadIdent(var crStart,crLen: longint);
var Ctrl: TIdentTrns;
  i: longint;
  p: PIdentRec;
begin
  AddStack('TCustomEdMemo.ReadIdent',Self);
  if Assigned(lsIdent) then begin
    Ctrl.i:=CtrlIdent.HashValue(TextCRLF(TrimRight(Text)));
    if lsIdent.Find(StrShifr(Ctrl.s),i) then begin
      p:=IdentRec(i);
      if (crStart=0) and (crLen=0) and not EdTextInitFind then begin
        CurrentLineNumber:=p.LastVisibleLine; crStart:=p.SelStart; crLen:=p.SelLength;
      end;
      if emoLineNumber in Cng then for i:=low(p.abm) to high(p.abm) do BookMark[i]:=p.abm[i];
    end;
  end;
  DelStack;
end;

procedure TCustomEdMemo.ReadIdent;
var crStart,crLen: longint;
begin
  crStart:=0; crLen:=0; ReadIdent(crStart,crLen); SetSelection(crStart,crLen);
end;

procedure TCustomEdMemo.SaveIdent(const Text: string);
var Ctrl: TIdentTrns;
  i: longint;
  p: PIdentRec;
begin
  AddStack('TCustomEdMemo.SaveIdent',Self);
  IdentInit; Ctrl.i:=CtrlIdent.HashValue(TextCRLF(TrimRight(Text)));
  p:=IdentFind(StrShifr(Ctrl.s),trunc(Date));
  p.LastVisibleLine:=GetFirstVisibleLine+LinesOnScreen-1; p.SelStart:=SelStart; p.SelLength:=SelLength;
  for i:=low(p.abm) to high(p.abm) do p.abm[i]:=BookMark[i];
  DelStack;
end;

procedure TCustomEdMemo.SaveIdent;
begin
  SaveIdent(Text);
end;

const IniSect = 'TextMemo';
  IniLastVers = 1;

class procedure TCustomEdMemo.RestFromIni;
var ls: TStrStrList;
  n,i,dt,dt1: longint;
  sb: TStrBuf;
  p: PIdentRec;
  j: TEdMemoBMList;
begin
  AddStack('TCustomEdMemo.RestFromIni');
  if InitFIni[fiSave].ReadSectionList(IniSect,ls) then begin
    IdentInit; dt:=trunc(Date);
    for n:=0 to ls.Count-1 do begin
      sb:=TStrBuf.CreateRead(StrDeShifr(ls.Value[n]),IniLastVers);
      try
        if sb.Active then begin
          dt1:=sb.Read(stInteger);
          if dt-dt1<100 then begin
            p:=IdentFind(ls[n],dt1);
            p.LastVisibleLine:=sb.Read(stInteger); p.SelStart:=sb.Read(stInteger); p.SelLength:=sb.Read(stInteger);
            for j:=low(p.abm) to high(p.abm) do p.abm[j].Col:=NegDef;
            repeat
              i:=sb.Read(stByte);
              if i=0 then break;
              with p.abm[TEdMemoBMList(i)] do begin
                Line:=sb.Read(stInteger); Col:=sb.Read(stInteger); LastVisibleLine:=sb.Read(stInteger);
              end;
            until false;
          end;
        end;
      finally
        sb.Free;
      end;
    end;
  end;
  DelStack;
end;

class procedure TCustomEdMemo.SaveToIni;
var i: longint;
  sb: TStrBuf;
  p: PIdentRec;
  j: TEdMemoBMList;
  s: string;
begin
  AddStack('TCustomEdMemo.SaveToIni');
  with InitFIni[fiSave] do begin
    EraseSection(IniSect);
    if Assigned(lsIdent) then for i:=0 to lsIdent.Count-1 do begin
      sb:=TStrBuf.CreateWrite(@s,IniLastVers);
      try
        p:=IdentRec(i); sb.Write(p.DateCng,stInteger);
        sb.Write(p.LastVisibleLine,stInteger); sb.Write(p.SelStart,stInteger); sb.Write(p.SelLength,stInteger);
        for j:=low(p.abm) to high(p.abm) do with p.abm[j] do if Col<>NegDef then begin
          sb.Write(j,stByte);
          sb.Write(Line,stInteger); sb.Write(Col,stInteger); sb.Write(LastVisibleLine,stInteger);
        end;
        sb.Write(0,stByte);
      finally
        sb.Free;
      end;
      WriteString(IniSect,lsIdent[i],StrShifr(s));
    end;
  end;
  DelStack;
end;

{ TTextMemo }
constructor TTextMemo.CreateParent;
begin
  AddStack('TTextMemo.CreateParent',Self);
  inherited CreateParent(AOwner,AParent);
  if IsSci then with Sci do begin
    TabWidth:=I_TAB; UseTabs:=false;
  end;
  PropFontAdd('Пробелы',SCE_OURLIB_DEFAULT);
  PropFontAdd(aStConst);
  PropFontAdd('Знаки препинания',SCE_OURLIB_WORD_OPERATOR);
  PropFontAdd('Прочие символы',[SCE_OURLIB_COMMENT_LINE,SCE_OURLIB_COMMENT_LINE_FROM_BEGIN,
    SCE_OURLIB_COMMENT_BLOCK,SCE_OURLIB_PREPROCESSOR,SCE_OURLIB_OPERATOR,SCE_OURLIB_WORD]);
  IncCng([emoEdge,emoLineNumber]);
  KeywordBeginUpdate;
  KeywordN(kwOperator).Text:=ArrayAsList(['!',',','-','.',':',';','?'],CRLF);
  KeywordEndUpdate;
  DelStack;
end;

procedure TTextMemo.GetFromSchem;
begin
	AddStack('TTextMemo.GetFromSchem',Self);
  if ReadOnly and FReadOnlyColor and Assigned(CurSchem) then begin
    Color:=CurSchem.Color2; Font.Assign(CurSchem.Font2);
  end
  else inherited GetFromSchem;
  DelStack;
end;

{procedure TTextMemo.SetReadOnly;
begin
	AddStack('TTextMemo.SetReadOnly',Self);
	inherited SetReadOnly(Value);
  SetSchemForm(GetParentForm(Control));
  DelStack;
end;}

procedure TTextMemo.SetFileName;
begin
  AddStack('TTextMemo.SetFileName',Self);
  FFileName:=Value; IfThenNotify(PrChangeFileName,Owner);
  DelStack;
end;

procedure TTextMemo.SetReadOnlyColor;
begin
  AddStack('TTextMemo.SetReadOnlyColor',Self);
  if Value<>FReadOnlyColor then begin
    FReadOnlyColor:=Value; SetSchemForm(GetParentForm(Control));
  end;
  DelStack;
end;

procedure TTextMemo.BeforeKeyDown;
var p: longint;
begin
  AddStack('TTextMemo.BeforeKeyDown',Self);
  if FSearchInc and (Key=VK_BACK) then Key:=0;
  if (Shift=[]) and (Key=vk_Home) then begin
    // На первый символ-не пробел
    p:=PosFirstNoSpace;
    if not((p=CurLineStartPos) or (p=GetCurrentPos)) then begin
      SetSelection(p); Key:=0;
    end;
  end;
  inherited BeforeKeyDown(Key,Shift);
  DelStack;
end;

procedure TTextMemo.BeforeKeyPress;
  procedure SetSearchIncStr(const Value: string);
  var fl: boolean;
    ol: longint;
  begin
    AddStack('TTextMemo.BeforeKeyPress.SetSearchIncStr',Self);
    fl := Length(Value)=0; ol:=SelLength;
    if fl or not IsSci then SelLength:=0;
    if not fl then begin
      fl:=SearchContinue(Value,true);
    end;
    if fl then begin
      ScrollCaret; FSearchIncStr:=Value;
      if Assigned(FStatus) then FStatus.SectLeft[2]:='Поиск: '+FSearchIncStr;
      with FormKeyLb(Control) do begin
        if FSearchIncStr='' then DelKey(K_All,'searchincnext')
        else begin
          SetKey(K_F3,'Вперед','Найти следующее совпадение',ProcKey,'searchincnext',kmFile);
          SetKey(K_Shift_F3,'Назад','Найти предыдущее совпадение',ProcKey,'searchincnext',kmFile);
        end;
        Redrw;
      end;
    end
    else if not IsSci then SelLength:=ol;
    DelStack;
  end;
begin
  AddStack('TTextMemo.BeforeKeyPress',Self);
  if FSearchInc then begin
    if Key=Chr(VK_BACK)
      then SetSearchIncStr(LeftStr(FSearchIncStr,Length(FSearchIncStr)-1))
    else if Key>=' '
      then SetSearchIncStr(FSearchIncStr+Key);
    Key:=#0;
  end;
  inherited BeforeKeyPress(Key);
  DelStack;
end;

procedure TTextMemo.BeforeKeyUp;
begin
  AddStack('TTextMemo.BeforeKeyUp',Self);
  if FSearchInc and (Key=VK_BACK) then Key:=0;
  inherited BeforeKeyUp(Key,Shift);
  DelStack;
end;

procedure TTextMemo.BeforeEnter;
var tl: TKeyLb;
begin
  AddStack('TTextMemo.BeforeEnter',Self);
  MainMn.EditKeysAdd;
  if FormKeyLb(Control,tl) then begin
    tl.SetKeyFind(ProcKey,'textmemo',kmEdit);
    tl.SetKey(K_Ctrl_F12,'','Поиск вхождения целых чисел',ProcKey,'textmemo',kmEdit);
    tl.SetKey(K_Alt_F5,'','Перейти/выделить',ProcKey,'textmemo',kmEdit);
    if not tl.IsKeyBut(K_Ctrl_E) then tl.SetKey(K_Ctrl_E,'','Посимвольный поиск',ProcKey,'textmemo',kmEdit);
    tl.SetKey(K_Shift_F2,'','Сохранить в файл',ProcKey,'textmemo',kmFile);
    if not ReadOnly then tl.SetKey(K_Shift_F3,'','Считать из файла',ProcKey,'textmemo',kmFile);
    tl.SetKey(K_Ctrl_F6,'Печать','',ProcKey,'textmemo',kmFile);
    if SftpPath<>'' then tl.SetKey(K_Alt_I,'','Отправить по Интернету разработчикам',ProcKey,'textmemo',kmFile);
    tl.ReDrw;
  end;
  inherited BeforeEnter;
  DelStack;
end;

procedure TTextMemo.AfterEnter;
begin
  inherited AfterEnter;
end;

procedure TTextMemo.AfterExit;
var tl: TKeyLb;
begin
  AddStack('TTextMemo.AfterExit',Self);
  inherited AfterExit;
  MainMn.EditKeysDel;
  if FormKeyLb(Control,tl) then begin
    tl.DelKey(K_All,'textmemo'); tl.ReDrw;
  end;
  DelStack;
end;

procedure TTextMemo.ProcKey;
var s: string;
  d: TOpenDialog;
  f: TForm;
  i,j,l: longint;
  sb: TStrBuf;
  av: TDEPrmVar;
  oProperty: TFindProperty;
begin
  AddStack('TTextMemo.ProcKey',Self);
  case Key of
    K_F3: begin
      j:=SelStart; l:=SelLength; SetSelection(j+l); SearchAnchor;
      if not SearchContinue(FSearchIncStr,true) then begin
        meserr('Строка "'+FSearchIncStr+'" не найдена.'); SetSelection(j,l); SearchAnchor;
      end
      else ScrollCaret;
    end;
    K_F10,K_Esc: SetSearchInc;
    K_Ctrl_F6: begin
      s:=Text; PrnTxtExec(s,System.Copy(s,SelStart,SelLength),Font);
    end;
    K_Ctrl_F12: begin
      if not Assigned(rFindNum) then begin
        rFindNum:=TRecVal.Create(Application.MainForm);
        with rFindNum do begin
          CreateFld('N1',ftInteger,10,0);
          CreateFld('N2',ftInteger,10,0);
        end;
        deFindNum:=TDefEdit.Create(Application.MainForm);
        with deFindNum do begin
          FrmCaption:='Поиск вхождений целых чисел (слово целиком)'; NameWnd:='FindNum'; PnlSortMode:=smColumns;
          InitArr(av);
          av[deCaption]:='Начало';
          av[deNameRec]:=rFindNum.NameRec;
          av[deNameRecFld]:='N1';
          TSpinGet.AssignGetClass(av);
          av[deAutoSel]:=true;
          av[deNoReadOnly]:=true;
          CreateFld(av);

          av[deCaption]:='Конец';
          av[deNameRecFld]:='N2';
          CreateFld(av);
        end;
      end;
      if deFindNum.Execute.Saved then begin
        s:=''; j:=0; l:=0; oProperty:=FindProperty;
        try
          Finalize(FindProperty); FindProperty.Word:=true;
          for i:=rFindNum['N1'] to rFindNum['N2'] do
            if FindInStr(Text,IntToStr(i)) then begin
              if l=0 then IncD(s,StrNum(',',i));
              Inc(j); Inc(l);
            end
            else begin
              if l>1 then IncD(s,StrNum('-',i-1));
              l:=0;
            end;
        finally
          FindProperty:=oProperty;
        end;
        if l>1 then IncD(s,StrNum('-',rFindNum['N2']));
        meserr('Найдено (%d): %s',[j,Copy(s,2,MaxInt)]);
      end;
    end;
    K_Ctrl_E: SetSearchInc(true);
    K_Alt_F5: begin
      if not Assigned(rSel) then begin
        rSel:=TRecVal.Create(Application.MainForm);
        with rSel do begin
          CreateFld('LineBeg',ftInteger,1,0);
          CreateFld('ColBeg',ftInteger,1,0);
          CreateFld('LineEnd',ftInteger,1,0);
          CreateFld('ColEnd',ftInteger,1,0);
          CreateFld('LSEL',ftBoolean,0,false);
        end;
        deSel:=TDefEdit.Create(Application.MainForm);
        with deSel do begin
          FrmCaption:='Перейти'; NameWnd:='Gotoline'; PnlSortMode:=smColumns;
          OnFldChange:=deSelFldChange;

          InitArr(av);
          av[deCaption]:='Строка';
          av[deNameRec]:=rSel.NameRec;
          av[deNameRecFld]:='LineBeg';
          TSpinGet.AssignGetClass(av);
          av[deMask]:=StrNum('1,',MaxInt);
          av[deAutoSel]:=true;
          av[deNoReadOnly]:=true;
          CreateFld(av);

          av[deCaption]:='Столбец';
          av[deNameRecFld]:='ColBeg';
          CreateFld(av);

          av[deCaption]:='';
          av[deNameRecFld]:='LSEL';
          TBoolGet.AssignGetClass(av);
          av[deMask]:='Выделить до:';
          CreateFld(av);

          av[deCaption]:='строки';
          av[deNameRecFld]:='LineEnd';
          TSpinGet.AssignGetClass(av);
          av[deMask]:=StrNum('1,',MaxInt);
          av[deReadOnlyNoVsbl]:=true;
          CreateFld(av);

          av[deCaption]:='столбца';
          av[deNameRecFld]:='ColEnd';
          CreateFld(av);
        end;
      end;
      rSel['LSEL']:=false; deSel.OnPnlValid:=deSelPnlValid; deSel.Execute;
    end;
    K_Alt_I: begin
      sb:=TStrBuf.CreateRead(Text);
      try
        SendToSftp(FFileName,sb);
      finally
        sb.Free;
      end;
    end;
    K_Shift_F2,K_Shift_F3: if FSearchInc then
      if SearchContinue(FSearchIncStr,false) then begin
        ScrollCaret; SearchAnchor;
      end
      else meserr('Строка "'+FSearchIncStr+'" не найдена.')
    else begin
      f:=BeforeShowOther;
    	if key=K_Shift_F3 then d:=GetOpenDialog
      else begin
        if not Assigned(dlgSave) then begin
          dlgSave:=TSaveDialog.Create(Application.MainForm);
          dlgSave.Options:=[ofHideReadOnly,ofShowHelp,ofPathMustExist];
        end;
        d:=dlgSave;
      end;
      with d do begin
        if InitialDir='' then InitialDir:=ExeDir;
        if FFileName<>'' then FileName:=FFileName;
        if FileExec('EdText',d) then begin
          Self.FileName:=FileName;
          if key=K_Shift_F3 then begin
            SaveIdent; Lines.Text:=GetStrFile(FileName); ReadIdent;
          end
          else SaveToFile;
          AddSzStrings(pointer(HistoryList),FileName);
        end;
      end;
      AfterShowOther(f);
    end;
  else ExecFind(Key);
  end;
  DelStack;
end;

procedure TTextMemo.SearchIncFormClose;
begin
  AddStack('TTextMemo.SearchIncFormClose',Self);
  SetSearchInc; IfThenClose(oClose,Sender,Action);
  DelStack;
end;

procedure TTextMemo.SetSearchInc;
var f: TForm;
begin
  AddStack('TTextMemo.SetSearchInc',Self);
  if Assigned(FStatus) then FStatus.SectLeft[2]:=IfThen(Value,'[Введите символы для поиска]');
  FSearchIncStr:=''; f:=ParentForm(Control);
  with FormKeyLb(f) do begin
    if Value then begin
      oClose:=f.OnClose; f.OnClose:=SearchIncFormClose;
    end
    else begin
      f.OnClose:=oClose; DelKey(K_All,'searchinc');
    end;
    SetButNoEval(Value);
    if Value then begin
      SetKeys([K_Esc,K_F10],'Выход','Выход из режима посимвольного поиска',ProcKey,'searchinc',kmFile);
      SearchAnchor;
    end;
    Redrw;
  end;
  FSearchInc:=Value;
  DelStack;
end;

function TTextMemo.SearchContinue;
var s,su,sl: string;
  iv,i,l: longint;
  oProperty: TFindProperty;
begin
  AddStack('TTextMemo.SearchContinue',Self);
  if IsSci then begin
    l:=Length(Value); SetLength(s,l shl 2); i:=0; su:=AnsiUpperCase(Value); sl:=AnsiLowerCase(Value);
    for iv:=1 to l do begin
      Inc(i); s[i]:='[';
      Inc(i); s[i]:=su[iv];
      Inc(i); s[i]:=sl[iv];
      Inc(i); s[i]:=']';
    end;
    with Sci do if lNext
    then i:=SearchNext(SCFIND_REGEXP,PChar(s))
    else i:=SearchPrev(SCFIND_REGEXP,PChar(s));
    result := i>=0;
  end
  else begin
    oProperty:=FindProperty;
    try
      Finalize(FindProperty); FindProperty.Direction:=iif(lNext,fndForward,fndBack);
      i:=SelStart+1; l:=SelLength; result:=FindInStr(Text,Value,@i,@l);
      if result then SetSelection(i-1,l);
    finally
      FindProperty:=oProperty;
    end;
  end;
  DelStack;
end;

procedure TTextMemo.SearchAnchor;
begin
  if IsSci then Sci.SearchAnchor;
end;

class procedure TTextMemo.deSelFldChange;
var fl: boolean;
  tfLineEnd,tfColEnd: TFldEdit;
begin
  AddStack('TTextMemo.deSelFldChange');
  with TFldEdit(Sender),deSel do if NameRecFld='LSEL' then begin
    fl:=not VarValue;
    tfLineEnd:=FldEdit['LineEnd']; tfLineEnd.SetReadOnly(fl);
    tfColEnd:=FldEdit['ColEnd']; tfColEnd.SetReadOnly(fl);
    if not fl then begin
      tfLineEnd.VarValue:=rSel['LineBeg'];
      tfColEnd.VarValue:=rSel['ColBeg'];
    end;
  end;
  DelStack;
end;

function TTextMemo.deSelPnlValid;
var pb,pe: longint;
begin
  AddStack('TTextMemo.deSelPnlValid',Self);
  pb:=PositionFromLine(rSel['LineBeg']-1)+rSel['ColBeg']-1;
  if rSel['LSEL'] then pe:=PositionFromLine(rSel['LineEnd']-1)+rSel['ColEnd']-1 else pe:=pb;
  result := pe>=pb;
  if result then SetSelection(pb,pe-pb);
  DelStack;
end;

procedure TTextMemo.SetStatus;
var oldCaret,newCaret: TFMemoCaret;
begin
  AddStack('TTextMemo.SetStatus',Self);
  FStatus:=Value; Control.perform(WM_INSMODECNG,0,0);
  if IsSci then Sci.doSciModified(0,SC_MOD_INSERTTEXT,'',0,0,0,0,0) else NoSci.Change;
  DoMoveCaret(oldCaret,newCaret);
  DelStack;
end;

procedure TTextMemo.WMInsModeCng;
begin
	AddStack('TTextMemo.WMInsModeCng',Self);
  inherited WMInsModeCng(Message);
  if Assigned(FStatus) then FStatus.SectLeft[1]:=IfThen(InsModeOverride,'Замена','Вставка');
  DelStack;
end;

procedure TTextMemo.doSciModified;
begin
  AddStack('TTextMemo.doSciModified',Self);
  inherited doSciModified(position,modificationType,text,len,linesAdded,line,foldLevelNow,foldLevelPrev);
	if Assigned(FStatus) then begin
    CngModified;
    if (modificationType and (SC_MOD_INSERTTEXT or SC_MOD_DELETETEXT) > 0) then StatusChar;
  end;
  DelStack;
end;

procedure TTextMemo.doSciSavePointReached;
begin
  AddStack('TTextMemo.doSciSavePointReached',Self);
  inherited doSciSavePointReached;
  if Assigned(FStatus) then CngModified;
  DelStack;
end;

procedure TTextMemo.CngModified;
begin
  AddStack('TTextMemo.CngModified',Self);
  FStatus.SectLeft[0]:=IfThen(Modified,'*',' ');
  DelStack;
end;

procedure TTextMemo.StatusChar;
begin
  AddStack('TTextMemo.StatusChar',Self);
  FStatus.SectRight[2]:='0x'+IntToHex(byte(GetCharAt(GetCurrentPos)),2);
  DelStack;
end;

procedure TTextMemo.DoMoveCaret;
begin
  AddStack('TTextMemo.DoMoveCaret',Self);
  inherited DoMoveCaret(oldCaret,newCaret);
  if Assigned(FStatus) then begin
    FStatus.SectRight[0]:='Столбец: '+SpaceStr(CurrentCol+1,6);
    FStatus.SectRight[1]:='Строка: '+SpaceStr(CurrentLineNumber+1,6);
    StatusChar;
  end;
  DelStack;
end;

procedure TTextMemo.FormShow;
begin
  AddStack('TTextMemo.FormShow',Self);
  Modified:=false;
  DelStack;
end;

procedure TTextMemo.FormClose;
begin
  AddStack('TTextMemo.FormClose',Self);
  if Modified then AskFormSave(pointer(Sender),Action);
  DelStack;
end;

procedure TTextMemo.SaveToFile;
begin
  SaveToFile(Text);
end;

procedure TTextMemo.SaveToFile(const txt: string);
begin
  AddStack('TTextMemo.SaveToFile',Self);
  repeat
    if SetStrFile(FFileName,txt) then break;
  until not Ask(['Ошибка записи в файл',FFileName,
    'Возможно, отсутствуют права на запись,','или файл занят другим приложением.',
    'Повторить попытку записи ?']);
  DelStack;
end;

procedure TTextMemo.HelpPart;
var PosFirstNoSp: longint;
begin
  AddStack('TTextMemo.HelpPart',Self);
  inherited HelpPart(Head);
  if Head=EdMemoHelpPartCurs then begin
    PosFirstNoSp:=PosFirstNoSpace;
    if PosFirstNoSp=GetCurrentPos then begin
      if CurrentCol=0 then HelpKey(K_Home,'',true);
    end
    else if PosFirstNoSp<>CurLineStartPos then HelpKey(K_Home,'На первый непустой символ',true)
  end
  else if Head=EdMemoHelpPartSel
    then HelpKey(K_Alt_F5,'Указать начало и конец выделения')
  else if Head=EdMemoHelpPartCng then begin
    if FSearchInc then HelpKey(K_BS,'Удалить символ в строке поиска',true);
    HelpKey(K_F5,'Вставить текущее время и дату');
  end;
  DelStack;
end;

{ TInterMemo }
const
  SCE_OURLIB_WORD_FUNC    = SCE_OURLIB_WORD1;
  SCE_OURLIB_WORD_VAR     = SCE_OURLIB_WORD2;
  SCE_OURLIB_WORD_NOUSED  = SCE_OURLIB_WORD3;
  SCE_OURLIB_WORD_TMPVAR  = SCE_OURLIB_WORD4;

  kwFunc    = SCE_OURLIB_WORD_FUNC   -SCE_OURLIB_WORD_FIRST;
  kwVar     = SCE_OURLIB_WORD_VAR    -SCE_OURLIB_WORD_FIRST;
  kwNoUsed  = SCE_OURLIB_WORD_NOUSED -SCE_OURLIB_WORD_FIRST;
  kwTmpVar  = SCE_OURLIB_WORD_TMPVAR -SCE_OURLIB_WORD_FIRST;

  aVtKw: array[TInterVarType] of byte = (kwVar,kwTmpVar);

  aStComment: array[1..3] of TEdMemoFontDef =
    ((n:SCE_OURLIB_COMMENT_LINE           ; name:'Комментарий до конца строки')
    ,(n:SCE_OURLIB_COMMENT_LINE_FROM_BEGIN; name:'Комментарий с начала строки')
    ,(n:SCE_OURLIB_COMMENT_BLOCK          ; name:'Комментарий на несколько строк')
    );

  cDlmPrm = ', ';

procedure StatTypes(Sender: TObject; const nm,types: string);
begin
  AddStack('FEdText.StatTypes');
	with TRbStatus(Sender) do begin
  	SectLeft[0]:=nm; SectLeft[1]:=InterEdStrTypes(types);
  end;
  DelStack;
end;

function FuncBrackNul: string;
begin
  result:=aBrack[brckFunc,false]+aBrack[brckFunc,true];
end;

constructor TInterMemo.CreateParent;
  procedure GrupColor(const a: array of TEdMemoFontDef; cl: TColor);
  var i: byte;
  begin
    AddStack('TInterMemo.CreateParent.GrupColor',Self);
    for i:=low(a) to high(a) do PropDef[true].aFont[a[i].n].ForeColor:=cl;
    DelStack;
  end;
const
  aStUslComp: array[1..2] of TEdMemoFontDef =
    ((n:SCE_OURLIB_PREPROCESSOR    ; name:'Символы условной компиляции')
    ,(n:SCE_OURLIB_WORD_PREPROC_DEF; name:'Ключевые слова условной компиляции')
    );
  aStOper: array[1..3] of TEdMemoFontList = (11,12,14);
var i: longint;
  fl: boolean;
  vt: TInterVarType;
begin
  AddStack('TInterMemo.CreateParent',Self);
  inherited CreateParent(AOwner,AParent);
  aCallTip:=nil; Inter:=TInter.Create(''); Inter.ShowError:=false;
  for fl:=false to true do with PropDef[fl] do begin
    aFont[SCE_OURLIB_WORD_NOUSED].BackColor:=clAqua; LineNumber:=true;
  end;
  PropDef[false].CaretBack:=clYellow;
  with PropDef[true] do begin
    GrupColor(aStComment,clNavy);
    GrupColor(aStUslComp,clGreen);
    GrupColor(aStConst,clRed);
    for i:=low(aStOper) to high(aStOper) do with aFont[aStOper[i]] do begin
      FontStylesCng:=true; Include(FontStyles,fsBold);
    end;
    MarkerType:=byte(sciMarkBox);
    MouseDwellTime:=300;
  end;
  CngFont:=nil;
  PropFontAdd('Пробелы',SCE_OURLIB_DEFAULT);
  PropFontAdd(aStComment);
  PropFontAdd(aStUslComp);
  PropFontAdd(aStConst);
  PropFontAdd('Слова',SCE_OURLIB_WORD);
  PropFontAdd('Операторы',aStOper);
  PropFontAdd('Функции',SCE_OURLIB_WORD_FUNC);
  PropFontAdd('Переменные',SCE_OURLIB_WORD_VAR);
  PropFontAdd('Временные переменные',SCE_OURLIB_WORD_TMPVAR);
  PropFontAdd('Неиспользуемые временные переменные',SCE_OURLIB_WORD_NOUSED);
  PropFontAddBrack;
  PropFontAdd('Прочие символы',SCE_OURLIB_OPERATOR);
  IncCng([emoFolding,emoCallTip]);
  KeywordBeginUpdate;
  for i:=0 to KeyWordCount-1 do if i<>kwReserved then KeywordN(i).Clear;
  if lOper=0 then Tinter.GetOperator(aOper,lOper);
  for i:=1 to lOper do with aOper[i] do if (name<>'') and (oplev>=0) then
    if AnsiStartsStr('/*$',name)
    then KeywordN(SCE_OURLIB_WORD_PREPROC_DEF-SCE_OURLIB_WORD_FIRST).Add(Trim(SubStr(name,4,-2)))
    else begin
      KeywordN(kwOperator).AddObject(name,pointer(i));
      if oplev=1 then KeywordN(SCE_OURLIB_WORD_FOLD_BEGIN-SCE_OURLIB_WORD_FIRST).Add(name);
      if oplev=2 then KeywordN(SCE_OURLIB_WORD_FOLD_END-SCE_OURLIB_WORD_FIRST).Add(name);
    end;
  if lFunc=0 then lFunc:=Tinter.GetFunction(aFunc);
  for i:=1 to lFunc do with aFunc[i] do
    if name<>'' then KeywordN(kwFunc).AddObject(name,pointer(i));
  KeywordN(kwOperator).Sorted:=true;
  KeywordN(kwFunc).Sorted:=true;
  KeywordN(kwNoUsed).CaseSensitive:=true; KeywordN(kwNoUsed).Sorted:=true;
  KeywordN(kwReserved).Add(StrNum('f=',SCE_OURLIB_WORD_FUNC-SCE_OURLIB_WORD_USER_FIRST+1));
  KeywordEndUpdate;
  SetLength(aKeywords,2+Length(aVtKw)); aKeywords[0]:=kwOperator; aKeywords[1]:=kwFunc;
  for vt:=low(aVtKw) to high(aVtKw) do begin
    KeywordN(aVtKw[vt]).CaseSensitive:=true; KeywordN(aVtKw[vt]).Sorted:=true;
    aKeywords[2+byte(vt)]:=aVtKw[vt];
  end;
  CheckOnClose:=true;
  DelStack;
end;

{procedure TInterMemo.WndDestroy;
begin
end;

{procedure TInterMemo.CreateWnd;
var i: longint;
begin
  AddStack('TInterMemo.CreateWnd',Self);
  inherited CreateWnd;
  if InRange(kwFunc,0,KeyWordCount-1) then with KeywordN(kwFunc) do
    if Count>0 then for i:=1 to lFunc do with aFunc[i] do
      if name<>'' then Objects[IndexOf(name)]:=Pointer(i);
  DelStack;
end;}

destructor TInterMemo.Destroy;
begin
	AddStack('TInterMemo.Destroy',Self);
  inter.Free;
  inherited;
  DelStack;
end;

procedure TInterMemo.SetTemplates;
begin
  AddStack('TInterMemo.SetTemplates',Self);
  inherited SetTemplates;
  AddTemplate('ЕСЛИ','ЕСЛИ |'+CRLF+Space(I_TAB)+CRLF+'КОНЕЦ_ЕСЛИ');
  AddTemplate('ИНАЧЕ','ЕСЛИ |'+CRLF+Space(I_TAB)+CRLF+'ИНАЧЕ'+CRLF+Space(I_TAB)+CRLF+'КОНЕЦ_ЕСЛИ');
  AddTemplate('ПОКА','ПОКА |'+CRLF+Space(I_TAB)+CRLF+'КОНЕЦ_ПОКА');
  AddTemplate('УЕСЛИ','/*$ЕСЛИ |*/'+CRLF+CRLF+'/*$КОНЕЦ_ЕСЛИ*/');
  AddTemplate('УИНАЧЕ','/*$ЕСЛИ |*/'+CRLF+CRLF+'/*$ИНАЧЕ*/'+CRLF+CRLF+'/*$КОНЕЦ_ЕСЛИ*/');
  DelStack;
end;

procedure TInterMemo.doSciModified;
var lMod: boolean;
begin
  AddStack('TInterMemo.doSciModified',Self);
  inherited doSciModified(position,modificationType,text,len,linesAdded,line,foldLevelNow,foldLevelPrev);
  if (modificationType and (SC_MOD_BEFOREINSERT or SC_MOD_BEFOREDELETE) > 0) then SelNoUsed:=false;
  lMod:=false; FillTmpVar(position,modificationType,len,lMod);
  CallTipBrackCng;
  if (modificationType and SC_MOD_INSERTTEXT > 0) and (len=1) and CallTip and not CallTipActiveBrack then
    if IsBrack(position,false)
    then CallTipBrack([ctbrBound],position+1);
  DelStack;
end;

function TInterMemo.IsBrack;
var nbrk: TInterBrackList;
  j: byte;
  p1: longint;
begin
  AddStack('TInterMemo.IsBrack',Self);
  result:=false;
  for nbrk:=low(aBrack) to high(aBrack) do begin
    j:=Length(aBrack[nbrk,lEnd]);
    for p1:=p downto 0 do begin
      if Chr(GetCharAt(p1))<>aBrack[nbrk,lEnd][j] then break;
      if j=1 then begin
        result:=true; break;
      end;
      Dec(j);
    end;
    if result then break;
  end;
  DelStack;
end;

procedure TInterMemo.RightTrimComment;
var pb: longint;
  lCommentUpd: boolean;
begin
  AddStack('TInterMemo.RightTrimComment',Self);
  s:=Lines[nline]; pb:=PositionFromLine(nline)-1;
  if Assigned(StrAdd) and (nline=CurrentLineNumber) then Insert(StrAdd^,s,GetCurrentPos-pb);
  l:=Length(s); lCommentUpd:=not Assigned(StrAdd);
  while l>0 do begin
    if s[l]>' ' then begin
      if lCommentUpd then begin
        lCommentUpd:=false; Colourise(pb+1,pb+1+l);
      end;
      if not(GetStyleAt(pb+l) in setComment) then break;
    end;
    Dec(l);
  end;
  DelStack;
end;

function LineContinue(const s: string; l: longint): boolean;
begin
  AddStack('FEdText.LineContinue');
  if l=0 then result:=false else result := s[l]=';';
  DelStack;
end;

procedure TInterMemo.FillTmpVar;
var i,l: longint;
  s: string;
  lFirst: boolean;
  function NextWord: string;
  var p: longint;
  begin
    AddStack('TInterMemo.FillTmpVar.NextWord',Self);
    while i<=l do if IsChrWord(s[i]) and not IsDigit(s[i]) or lFirst and (s[i]>' ') then break else Inc(i);
    p:=i;
    while i<=l do if IsChrWord(s[i]) then Inc(i) else break;
    result:=System.Copy(s,p,i-p);
    DelStack;
  end;
var ln,le: longint;
  lAfter,lVar: boolean;
  sw: string;
begin
  AddStack('TInterMemo.FillTmpVar',Self);
  if (modificationType and (SC_MOD_BEFOREINSERT or SC_MOD_BEFOREDELETE or SC_MOD_INSERTTEXT or SC_MOD_DELETETEXT) > 0)
  and IsStyleCng(SCE_OURLIB_WORD_TMPVAR) then begin
    lAfter := modificationType and (SC_MOD_INSERTTEXT or SC_MOD_DELETETEXT) > 0;
    ln:=LineFromPosition(position);
    if modificationType and (SC_MOD_BEFOREINSERT or SC_MOD_DELETETEXT) > 0
    then le:=ln
    else le:=LineFromPosition(position+len);
    while ln>0 do begin
      RightTrimComment(s,l,ln-1);
      if LineContinue(s,l) then Dec(ln) else break;
    end;
    repeat
      lFirst:=true; lVar:=false;
      while ln<Lines.Count do begin
        RightTrimComment(s,l,ln); i:=1;
        if lFirst then begin
          lVar:=AnsiMatchStr(NextWord,aDefVar); lFirst:=false;
        end;
        if lVar then
          repeat
            sw:=NextWord;
            if sw='' then break;
            KeywordBeginUpdate(lMod);
            if lAfter then KeywordN(kwTmpVar).AddObject(sw,ObjectNeg)
            else FindDel(KeywordN(kwTmpVar),sw);
          until false;
        if LineContinue(s,l) then Inc(ln) else break;
      end;
      Inc(ln);
    until ln>le;
  end;
  if KeywordEndUpdate(lMod) then Colourise(0,GetTextLength);
  DelStack;
end;

procedure TInterMemo.WMSchem;
var oCng,lMod: boolean;
begin
  AddStack('TInterMemo.WMSchem',Self);
  oCng:=IsStyleCng(SCE_OURLIB_WORD_TMPVAR);
  inherited;
  if oCng<>IsStyleCng(SCE_OURLIB_WORD_TMPVAR) then begin
    lMod:=false;
    if KeywordN(kwTmpVar).Count>0 then begin
      KeywordBeginUpdate(lMod); KeywordN(kwTmpVar).Clear;
    end;
    FillTmpVar(0,SC_MOD_INSERTTEXT,GetTextLength,lMod);
  end;
  DelStack;
end;

procedure TInterMemo.Init;
begin
  AddStack('TInterMemo.Init',Self);
  Inter.name:=InterName; HelpCont:=Control.HelpContext;
  KeywordBeginUpdate; LsVarFill(ivtVar,true); KeywordEndUpdate; Colourise(0,GetTextLength);
  DelStack;
end;

function TInterMemo.GetVarHelp;
begin
  AddStack('TInterMemo.GetVarHelp',Self);
  result:=TInter.GetVarHelp(aVar[vt,i]).help;
  DelStack;
end;

procedure TInterMemo.WMHelp;
var s: string;
  i,pEnd: longint;
  hc: THelpContext;
  vt: TInterVarType;
label lend;
begin
  AddStack('TInterMemo.WMHelp',Self);
  HelpFile.sFile:=''; hc:=HelpCont;
  if IdentInPos(s,Lines[CurrentLineNumber],CurrentCol,' ',false,@pEnd) then begin
    TrimUpperSelf(s);
    if StrToChar(TrimLeft(System.Copy(Lines[CurrentLineNumber],pEnd,MaxInt)))='(' then
      if IntObjFind(KeywordN(kwFunc),s,i) then begin
        hc:=aFunc[i].help; HelpFile:=TInter.HelpFile(aFunc[i]); goto lend;
      end;
    if IntObjFind(KeywordN(kwOperator),s,i) then begin
      hc:=aOper[i].help; HelpFile:=TInter.HelpFile(aOper[i]); goto lend;
    end;
    for vt:=low(aVar) to high(aVar) do if IntObjFind(KeywordN(aVtKw[vt]),s,i) then begin
      if i>=0 then begin
        hc:=GetVarHelp(vt,i); HelpFile:=TInter.HelpFile(aVar[vt,i]);
      end;
      if Assigned(HelpInterMemo) then if HelpInterMemo(s) then rHelpFile(HelpFile,hlnkInterMemo,s);
      goto lend;
    end;
  end;
lend:
  Control.HelpContext:=hc;
  inherited;
  DelStack;
end;

procedure TInterMemo.WMHelpFill;
begin
  AddStack('TInterMemo.WMHelpFill',Self);
  inherited;
  with Message do if (Oper=hlpFile) and (Control.HelpContext=0) then begin
    pFile.f[hlpfBase]:=HelpFile; ResFile := HelpFile.sFile<>'';
  end;
  DelStack;
end;

function TInterMemo.CtrlBrack;
var s: string;
	j,l,nls: longint;
  function lsFind(ls: TStringList; p: longint; noElse: boolean = false): boolean;
  var s1: string;
  	PosEnd: LongInt;
    oplev1: boolean;
  begin
    AddStack('TInterMemo.CtrlBrack.lsFind',Self);
    j:=p; result:=false;
    if l>0 then begin
      while (j<=l) and (s[j]<=' ') do Inc(j);
      if IdentInPos(s1,s,j,' ',false,@PosEnd) then begin
        result:=BoolObjFind(ls,s1,nls,oplev1);
        if result and noElse then result:=oplev1;
        if result then j:=PosEnd;
      end;
    end;
    DelStack;
  end;
  procedure jDec;
  begin
    AddStack('TInterMemo.CtrlBrack.jDec',Self);
    while (j>0) and (System.Copy(s,j,lCRLF)<>CRLF) do Dec(j);
    while (j>0) and (System.Copy(s,j-lCRLF,lCRLF)=CRLF) do Dec(j,lCRLF);
    DelStack;
  end;
const aBracket: array[boolean,1..4] of char =
  (('(','[','{','«')
  ,(')',']','}','»')
  );
var ls,ls1: TStringList;
  i,j1,k: longint;
  c: char;
  fl: boolean;
label lend;
begin
  AddStack('TInterMemo.CtrlBrack',Self);
  result:=false; ls:=SortStrListCreate; ls1:=SortStrListCreate;
  try
    for i:=1 to lOper do with aOper[i] do
      if (oplev=1) or (oplev=3) then ls.AddObject(name,pointer(oplev=1))
      else if oplev=2 then ls1.Add(name);
    s:=Text; l:=Length(s); k:=0;
    if lsFind(ls,SelStart) then while j<=l do begin
      while (j<=l) and (System.Copy(s,j,lCRLF)<>CRLF) do Inc(j);
      if j>l then break;
      j1:=j;
      if lsFind(ls1,j) then
        if k=0 then with cbrk do begin
          Pos:=j-Length(ls1[nls])-1; Oper:=cbrkOper; Clos:=true; result:=true; break;
        end
        else Dec(k)
      else if lsFind(ls,j1,true) then Inc(k);
    end
    else if lsFind(ls1,SelStart) then begin
      Dec(j,Length(ls1[nls])); jDec; Dec(j);
      while j>0 do begin
        jDec;
        if j=0 then break;
        j1:=j;
        if lsFind(ls,j,true) then
          if k=0 then with cbrk do begin
            Pos:=j-Length(ls[nls])-1; Oper:=cbrkOper; Clos:=false; result:=true; break;
          end
          else Dec(k)
        else if lsFind(ls1,j1) then Inc(k);
        j:=j1-lCRLF;
      end;
    end
    else if SelStart<l then begin
      j1:=SelStart+1; c:=s[j1];
      for fl:=false to true do
        for i:=low(aBracket[fl]) to high(aBracket[fl]) do
          if c=aBracket[fl,i] then begin
            k:=0; j:=aSign[fl]; Inc(j1,j);
            while InRange(j1,1,l) do begin
              if s[j1]=aBracket[fl,i] then Inc(k)
              else if s[j1]=aBracket[not fl,i] then
                if k=0 then with cbrk do begin
                  Pos:=j1-1; Oper:=cbrkBrack; Clos:=not fl; result:=true; break;
                end
                else Dec(k);
              Inc(j1,j);
            end;
            goto lend;
          end;
lend:
    end;
  finally
    ls.Free; ls1.Free;
  end;
  DelStack;
end;

procedure TInterMemo.BeforeKeyDown;
var s: string;
  cbrk: TInterCtrlBrack;
  ctbr: TInterCallTipBrackOpt;
  fl: boolean;
begin
  AddStack('TInterMemo.BeforeKeyDown',Self);
  WasCallTip:=CallTipActiveBrack;
  if NoBookMarkKey(Key,Shift) then begin
    s:='';
    if Shift=[ssCtrl] then case Key of
      48,57: if CtrlBrack(cbrk) then SetSelection(cbrk.Pos); // Ctrl ()
      55: s:='&&';    // Ctrl &
      187: s:='=>';   // Ctrl =
    //else if Key<>17 then s:=IntToStr(Key);
    end;
    if Shift=[ssAlt] then case Key of
      48,57: begin // Alt ()
        fl := Key=48;
        if WasCallTip then doSciCalltipClick(IfThen(fl,1,2))
        else begin
          ctbr:=[ctbrBound];
          if fl then Include(ctbr,ctbrLast);
          CallTipBrack(ctbr);
        end;
        WasCallTip:=CallTipActiveBrack;
      end;
    //else if Key<>18 then s:=IntToStr(Key);
    end;
    if s<>'' then begin
      Key:=0; InsText(s);
    end;
  end;
  inherited BeforeKeyDown(Key,Shift);
  DelStack;
end;

procedure TInterMemo.AfterKeyUp;
begin
  AddStack('TInterMemo.AfterKeyUp',Self);
  inherited AfterKeyUp(Key,Shift);
  if WasCallTip then begin
    WasCallTip:=false; CallTipBrack;
  end;
  DelStack;
end;

function TInterMemo.StructInPos;
var kwd: string;
begin
  AddStack('TInterMemo.StructInPos',Self);
  result:=false;
  if CallTipDwellType=ctdwDebug then begin
    if IdentInPos(kwd,s,i,' ',false,@pe) then begin
      pb:=pe-Length(kwd)-1;
      if pb>0 then
        if s[pb]='.' then begin
          LsVarFill(ivtTmpVar); result := Inter.lsStruct.IndexOf(kwd)>=0;
        end;
    end;
  end;
  DelStack;
end;

procedure TInterMemo.MouseUp;
var p,pb,i: longint;
  fl: boolean;
begin
  AddStack('TInterMemo.MouseUp',Self);
  inherited MouseUp(Button,Shift,X,Y);
  if CallTipDwellType=ctdwDebug then begin
    p:=PositionFromPoint(X,Y); fl:=IsBrack(p,true);
    if not fl then begin
      i:=LineFromPosition(p); pb:=PositionFromLine(i); fl:=StructInPos(Lines[i],p-pb,pb,i);
    end;
    if fl then CallTipBrack([ctbrBound],p);
  end;
  DelStack;
end;

function TInterMemo.CallTipBrack;
var s: string;
  lStruct: boolean;
  function sIsBrack(p: longint; lEnd: boolean; var nbrk: TInterBrackList): boolean;
  var j: byte;
    p1: longint;
  begin
    AddStack('FEdText.sIsBrack');
    result:=false; nbrk:=low(aBrack);
    while nbrk<=high(aBrack) do begin
      j:=Length(aBrack[nbrk,lEnd]);
      for p1:=p downto 1 do begin
        if s[p1]<>aBrack[nbrk,lEnd][j] then break;
        if j=1 then begin
          result:=true; break;
        end;
        Dec(j);
      end;
      if result then break;
      Inc(nbrk);
    end;
    DelStack;
  end;
var lCur: boolean;
  pb,pf,l: longint;
  procedure pCallTipCalc;
  var lt: longint;
  begin
    AddStack('TInterMemo.CallTipBrack.pCallTipCalc',Self);
    if lCur then pf:=pb+l+1
    else begin
      lt:=GetTextLength;
      while pf<lt do
        if byte(GetCharAt(pf))>32 then break else Inc(pf);
    end;
    DelStack;
  end;
var np,np1,HltBeg: longint;
  nActPrm: TInterPrmOvlList0;
  procedure BrackPrmAdd;
  begin
    AddStack('TInterMemo.CallTipBrack.BrackPrmAdd',Self);
    if np1=np then HltBeg:=Length(aPrm[nActPrm])+1;
    IncD(aPrm[nActPrm],IntToStr(np1));
    DelStack;
  end;
const aPrmInit: array[TCallTipDwellType] of TInterPrmOvlList0 = (1,0);
var pb1,ln,l1,k,i,i1,lv,HltLen,spb,spe: longint;
  j,j1: TInterBrackList;
  kwd: string;
  lDec,fl: boolean;
  ap: TInterPrmOvlStr;
label lend,lFn,lBr;
begin
  AddStack('TInterMemo.CallTipBrack',Self);
  if ctbrBound in Opt then pCallTip:=-1;
  if ReplNegSelf(p,GetCurrentPos) then
    if Assigned(StrAdd) then Inc(p,Length(StrAdd^));
  ln:=LineFromPosition(p); pf:=PositionFromLine(ln);
  HltBeg:=0; HltLen:=0; nActPrm:=aPrmInit[CallTipDwellType];
  RightTrimComment(s,l,ln,StrAdd); MinSelf(l,p-pf); lCur:=true; np:=1; lv:=0;
  repeat
    pb:=PositionFromLine(ln)-1;
    while l>0 do begin
      lDec:=true;
      if not(GetStyleAt(pb+l) in setConst) then
        if s[l]=',' then begin
          if lv=0 then Inc(np);
        end
        else if sIsBrack(l,true,j) then Inc(lv)
        else begin
          lStruct:=StructInPos(s,l,spb,spe);
          if lStruct or sIsBrack(l,false,j) then begin
            if lStruct then begin
              j:=brckAtom; l:=spb;
            end;
            Dec(lv);
            if lv<0 then begin
              l1:=l;
              if j in [brckFunc,brckAtom] then begin
                Dec(l);
                while l>0 do if s[l]>' ' then break else Dec(l);
                k:=l;
                while l>0 do if IsChrWord(s[l]) then Dec(l) else break;
                if l=k then continue;
                if (j=brckAtom) and (l>0) then
                  if s[l]>' ' then begin
                    lv:=0; continue;
                  end;
                kwd:=System.Copy(s,l+1,k-l);
              end
              else kwd:='';
              if j=brckFunc then begin
                if kwd='' then fl:=false else fl:=FindFunc(kwd,i);
                if fl or (CallTipDwellType<>ctdwNormal) then begin
                  pCallTipCalc; result:=true;
                  case CallTipDwellType of
                    ctdwNormal: with aFunc[i] do begin
                      s:=InterEdStrTypes(types);
                      if s<>'' then for l1:=1 to lPrm do IncD(Self.aPrm[l1],': '+s);
                      if pCallTip=pf then nActPrm:=nPrm
                      else if ctbrLast in Opt then nActPrm:=lPrm;
                      HltBeg:=Length(name)+IfThen(lPrm=1,2,3); Dec(np);
                      for k:=low(aPrm) to high(aPrm) do begin
                        i1:=min(ListAsArray(aPrm[k,1],ap,'~',false),nActPrm);
                        if k=np then begin
                          HltLen:=Length(ap[i1]); break;
                        end;
                        Inc(HltBeg,Length(ap[i1])+Length(cDlmPrm));
                      end;
                    end;
                    ctdwDebug: begin
                      if fl then Inc(l) else l:=l1;
                      Inc(l,pb); i:=l1+1; lv:=0;
                      while ln<Lines.Count do begin
                        pb1:=PositionFromLine(ln)-1; RightTrimComment(s,l1,ln);
                        while i<=l1 do begin
                          if not(GetStyleAt(pb1+i) in setConst) then
                            if sIsBrack(i,false,j1) then Inc(lv)
                            else if sIsBrack(i,true,j1) then begin
                              Dec(lv);
                              if lv<0 then begin
                                s:=System.Copy(Text,l+1,pb1+i-l+1); LsArrDynamic(s,aCallTip,CRLF,lsaSetLen);
                                HltBeg:=Length(StrTran(s,CRLF,#10))+1;
                                LsVarFill(ivtTmpVar); DebugEvalSelf(s); AddFrom(aCallTip,s); HltLen:=Length(s);
                                goto lFn;
                              end;
                            end;
                          Inc(i);
                        end;
                        if not LineContinue(s,l1) then break;
                        Inc(ln); i:=1;
                      end;
                      result:=false;
lFn:
                    end;
                  end;
                  goto lend;
                end;
                lDec:=false;
              end
              else begin
                result:=true;
                nActPrm:=max(1,nActPrm);
                lPrm:=nActPrm; aPrm[nActPrm]:=aBrack[j,false]+IfThen(j=brckStruct,' ');
                i:=l1+1; np1:=1; lv:=IfThen(lStruct,-1); HltLen:=LenIntStr(np);
                while ln<Lines.Count do begin
                  pb1:=PositionFromLine(ln)-1; RightTrimComment(s,l1,ln,StrAdd);
                  while i<=l1 do begin
                    if not(GetStyleAt(pb1+i) in setConst) then
                      if s[i]=',' then begin
                        if lv=0 then begin
                          BrackPrmAdd; IncD(aPrm[nActPrm],cDlmPrm); Inc(np1);
                        end;
                      end
                      else if sIsBrack(i,false,j1) then Inc(lv)
                      else begin
                        lStruct:=StructInPos(s,i,spb,spe);
                        if lStruct or sIsBrack(i,true,j1) then begin
                          if lStruct then begin
                            j1:=brckAtom; i:=spe;
                            if i<=Length(s) then
                              if s[i]>' ' then continue;
                            Dec(i);
                          end;
                          Dec(lv);
                          if lv<0 then begin
                            case CallTipDwellType of
                              ctdwNormal: begin
                                if np1=np then HltBeg:=Length(aPrm[nActPrm])+1;
                                IncD(aPrm[nActPrm],IntToStr(np1)+aBrack[j1,true]);
                              end;
                              ctdwDebug: begin
                                if j=brckAtom then Inc(l);
                                s:=System.Copy(Text,pb+l+1,p-pb-l+1); LsArrDynamic(s,aCallTip,CRLF,lsaSetLen);
                                HltBeg:=Length(StrTran(s,CRLF,#10))+1;
                                LsVarFill(ivtTmpVar); DebugEvalSelf(s); AddFrom(aCallTip,s); HltLen:=Length(s);
                              end;
                            end;
                            goto lBr;
                          end;
                          if lStruct then Inc(lv);
                        end;
                      end;
                    Inc(i);
                  end;
                  if not LineContinue(s,l1) then begin
                    BrackPrmAdd; break;
                  end;
                  Inc(ln); i:=1;
                end;
                if CallTipDwellType=ctdwDebug then result:=false;
lBr:
                if CntArrElement<>np1 then begin
                  CntArrElement:=np1; pCallTip:=-1;
                end;
                pCallTipCalc; goto lend;
              end;
            end;
          end;
        end;
      if lDec then Dec(l);
    end;
    lCur:=false;
    if ln=0 then break;
    Dec(ln); RightTrimComment(s,l,ln,StrAdd);
    if not LineContinue(s,l) then break;
  until false;
  result:=false;
lend:
  if result then begin
    pCallTip:=pf; FCallTipShow(pf,nActPrm); FCallTipSetHlt(HltBeg,HltBeg+HltLen);
    if Assigned(brk) then brk^:=j;
  end;
  DelStack;
end;

procedure TInterMemo.CallTipBrackCng;
begin
  AddStack('TInterMemo.CallTipBrackCng',Self);
  if IsSci then if CallTipActiveBrack then if not CallTipBrack then Sci.CallTipCancel;
  DelStack;
end;

function TInterMemo.CallTipActiveBrack;
begin
  AddStack('TInterMemo.CallTipActiveBrack',Self);
  if IsSci then result := Sci.CallTipActive and (nPrm>0) else result:=false;
  DelStack;
end;

procedure TInterMemo.doSciCalltipClick;
begin
  AddStack('TInterMemo.doSciCalltipClick',Self);
  inherited doSciCalltipClick(position);
  if IsSci and (nPrm>0) and (position>0) then begin
    Inc(nPrm,aSign[position<>2]);
    if InRange(nPrm,1,lPrm) then FCallTipShow(pCallTip,nPrm) else Sci.CallTipCancel;
  end;
  DelStack;
end;

procedure TInterMemo.AfterEnter;
const kmLists = 24;
var tl: TKeyLb;
  tb: PKeyBut;
begin
  AddStack('TInterMemo.AfterEnter',Self);
  inherited AfterEnter;
  if FormKeyLb(Control,tl) then begin
    if Assigned(MainMn) then MainMn.SeekPart(kmLists,'Списки');
    tl.SetKey(K_F2,'Данные','',ProcKey,'intermemo',kmLists);
    tl.SetKey(K_F3,'Подробно','',ProcKey,'intermemo',kmEdit);
    tl.SetKey(K_F4,'Функции','',ProcKey,'intermemo',kmLists);
    tl.SetKey(K_F5,'Операторы','',ProcKey,'intermemo',kmLists);
    if not ReadOnly then tl.SetKey(K_Ctrl_F5,'Форматировать','',ProcKey,'intermemo',kmEdit);
    if IsSci then tl.SetKey(K_Ctrl_F8,'','Неиспользуемые временные переменные',ProcKey,'intermemo',kmEdit);
    if tl.SeekKey(K_F1,tb) then with tb^ do begin
      oCaptF1:=Caption; Caption:='Помощь';
    end
    else oCaptF1:='';
    tl.ReDrw;
  end;
  DelStack;
end;

procedure TInterMemo.AfterExit;
var tl: TKeyLb;
  tb: PKeyBut;
begin
  AddStack('TInterMemo.AfterExit',Self);
  inherited AfterExit;
  if FormKeyLb(Control,tl) then begin
    if tl.SeekKey(K_F1,tb) then tb.Caption:=oCaptF1;
    tl.DelKey(K_All,'intermemo'); tl.ReDrw;
  end;
  DelStack;
end;

procedure PrStatVar(Sender: TObject; const r: TITRec; Prm: Pointer);
var v: varrec;
begin
	AddStack('FEdText.PrStatVar');
  v:=TInterMemo(Prm).aVar[r.vt,r.i];
  StatTypes(Sender,IfThen(v.name[1]='$',v.hint,v.name),v.types);
	TRbStatus(Sender).SectLeft[2]:=IfThen(v.ReadOnly,'Только для чтения');
  IntTree.HelpFile:=TInter.HelpFile(v);
  DelStack;
end;

procedure PrStatFunc(Sender: TObject; const r: TITRec; Prm: Pointer);
var f: funcrec;
begin
	AddStack('FEdText.PrStatFunc');
  f:=aFunc[r.i]; StatTypes(Sender,f.name,f.types);
  if f.name=''
  then rHelpFile(IntTree.HelpFile,Int2Str(hlnkFuncPart),IntToStr(r.i))
  else IntTree.HelpFile:=TInter.HelpFile(f);
  DelStack;
end;

procedure PrStatOper(Sender: TObject; const r: TITRec; Prm: Pointer);
begin
	AddStack('FEdText.PrStatOper');
  IntTree.HelpFile:=TInter.HelpFile(aOper[r.i]);
  DelStack;
end;

procedure TInterMemo.ProcKey;
var fl_list:boolean;
  PrStat: TITStatProc;
  Prm: Pointer;
  ar: TITArr;
  a: TArrStr;
  i,j,j1,k,l:longint;
  zag,Sect,czn,s: string;
  f: TForm;
  vt: TInterVarType;
  LsVar: array[TInterVarType] of TStringList;
begin
  AddStack('TInterMemo.ProcKey',Self);
  fl_list:=false; PrStat:=nil; Prm:=nil; l:=0;
  case key of
    K_F2,K_F3: begin
      LsVarFill(ivtVar); LsVarFill(ivtTmpVar);
      case Key of
        K_F2: begin
          for vt:=low(aVar) to high(aVar) do begin
            i:=Length(aVar[vt]); SetLength(ar,l+i);
            for i:=0 to i-1 do with aVar[vt][i] do if KeywordVisible(name) then begin
              ar[l].name:=name; ar[l].vt:=vt; ar[l].i:=i; ar[l].hlp:=GetVarHelp(vt,i); ar[l].prim:=hint; Inc(l);
            end;
          end;
          Prm:=pointer(Self);
          fl_list:=true; zag:='Список данных'; Sect:='Var'; PrStat:=PrStatVar; 
        end;
        K_F3: begin
          oModified:=Modified; oReadOnly:=ReadOnly; oText:=Text; oStart:=SelStart; oLen:=SelLength;
          l:=LsArrDynamic(oText,a,CRLF);
          for vt:=low(LsVar) to high(LsVar) do LsVar[vt]:=KeywordN(aVtKw[vt]);
          for i:=0 to l-1 do begin
            j:=1;
            while j<=Length(a[i]) do begin
              if IdentInPos(czn,a[i],j,' ',true) then begin
                j1:=Length(czn); s:='';
                for vt:=low(LsVar) to high(LsVar) do if IntObjFind(lsVar[vt],czn,k) then begin
                  if k>=0 then s:=LeftStrDel(aVar[vt,k].Hint,idShapeHint);
                  if empty(s) then s:=czn;
                  s:='['+Trim(s)+']'; StuffStrSelf(a[i],j,j1,s); j1:=Length(s);
                  break;
                end;
              end
              else j1:=1;
              Inc(j,j1);
            end;
          end;
          Text:=ArrayAsList(a,CRLF,l); SetSelection(0); ReadOnly:=true; ReadOnlyColor:=true;
          f:=ParentForm(Control);
          oCaption:=f.Caption; f.Caption:='Просмотр формулы';
          oClose:=f.OnClose; f.OnClose:=ViewClose;
          with FormKeyLb(Control) do begin
            SetButNoEval(true);
            SetKey(K_Esc,'Отмена','Отмена режима просмотра',ViewProc,'view',kmFile);
            SetKey(K_F3,'','',ViewProc,'view',kmFile);
            SetKey(K_F10,'','',ViewProc,'view',kmFile);
            ReDrw;
          end;
        end;
      end;
    end;
    K_F4:begin
      Prm:=@aFunc; SetLength(ar,lFunc);
      for i:=1 to lFunc do with aFunc[i] do if KeywordVisible(name) then begin
        ar[l].name:=name; ar[l].i:=i; ar[l].hlp:=IfThen(name<>'',help); ar[l].prim:=hint; Inc(l);
      end;
      fl_list:=true; zag:='Список функций'; Sect:='Func'; PrStat:=PrStatFunc; 
    end;
    K_F5:begin
      SetLength(ar,lOper);
      for i:=1 to lOper do with aOper[i] do begin
        ar[l].name:=name; ar[l].i:=i; ar[l].hlp:=help; ar[l].prim:=hint; Inc(l);
      end;
      fl_list:=true; zag:='Список операторов'; Sect:='Oper'; PrStat:=PrStatOper;
    end;
    K_Ctrl_F5: begin
      l:=GetFirstVisibleLine; i:=CurrentLineNumber; s:=Tinter.FormatStr(Text);
      if TrimRight(s)<>TrimRight(Text) then begin
        lines.BeginUpdate; Lines.Text:=s; LineScroll(0,l); CurrentLineNumber:=i; lines.EndUpdate;
        BookMarkRestore;
      end;
    end;
    K_Ctrl_F8: SelNoUsed:=not SelNoUsed;
  end;
  if fl_list then begin
    IdentInPos(s,Lines[CurrentLineNumber],CurrentCol,' ',false,@i);
    czn:=TIntTree.Execute(zag,Sect,s,ar,l,IfThen(ReadOnly,itreNoSel),nil,PrStat,Prm);
    if not empty(czn) then begin
      if key=K_F4 then IncD(czn,FuncBrackNul);
      if AnsiStartsText(s,czn) then begin
        for j:=0 to CurrentLineNumber-1 do Inc(i,Length(Lines[j])+lCRLF);
        l:=Length(s); SetSelection(i-l-1,l);
      end;
      InsText(czn);
      if key=K_F4 then SetSelection(SelStart-1);
    end;
  end;
  DelStack;
end;

// Отмена просмотра
procedure TInterMemo.ViewProc;
var f: TForm;
begin
	AddStack('TInterMemo.ViewProc',Self);
  ReadOnly:=oReadOnly; ReadOnlyColor:=false; Text:=oText;
  Modified:=oModified; SetSelection(oStart,oLen);
  f:=ParentForm(Control); f.Caption:=oCaption; f.OnClose:=oClose;
	with FormKeyLb(Control) do begin
		DelKey(K_All,'view'); SetButNoEval(false); ReDrw;
  end;
  DelStack;
end;

class procedure TInterMemo.ViewClose;
begin
	AddStack('TInterMemo.ViewClose');
	if Action=caHide then begin
  	FormKeyLb(TControl(Sender)).ExecKey(K_Esc); Action:=caNone;
  end;
  DelStack;
end;

function IsDefVar(const s,DefVar: string): boolean;
var l: longint;
begin
  AddStack('FEdText.IsDefVar');
  result:=AnsiStartsStr(DefVar,s);
  if result then begin
    l:=Length(DefVar);
    if Length(s)>l then result:=empty(s[l+1]);
  end;
  DelStack;
end;

procedure TInterMemo.SetSelNoUsed;
var i,j: longint;
  s: string;
  fl: boolean;
  oFindProperty: TFindProperty;
  kw: TStringList;
begin
  AddStack('TInterMemo.SetSelNoUsed',Self);
  if FSelNoUsed<>Value then begin
    FSelNoUsed:=Value; KeywordBeginUpdate;
    if FSelNoUsed then begin
      Inter.Setprog(Text); Inter.Compile(PrUnUsed);
      oFindProperty:=FindProperty; ZeroMemory(@FindProperty,SizeOf(FindProperty));
      FindProperty.Registr:=true; FindProperty.Word:=true; i:=0;
      while i<Lines.Count do begin
        s:=TrimLeft(Lines[i]); fl:=false;
        for j:=low(aDefVar) to high(aDefVar) do
          if IsDefVar(s,aDefVar[j]) then begin
            fl:=true; break;
          end;
        if fl then
          while i<Lines.Count do begin
            RightTrimComment(s,j,i); Inc(i);
            if not LineContinue(s,j) then break;
          end
        else begin
          kw:=KeywordN(kwNoUsed); j:=0;
          while j<kw.Count do begin
            if not BoolObj(kw,j) then
              if FindInStr(s,kw[j]) then begin
                kw.Delete(j); continue;
              end;
            Inc(j);
          end;
          if kw.Count=0 then break else Inc(i);
        end;
      end;
      FindProperty:=oFindProperty;
    end
    else KeywordN(kwNoUsed).Clear;
    KeywordEndUpdate; Colourise(0,GetTextLength);
  end;
  DelStack;
end;

procedure TInterMemo.PrUnUsed;
var ls: TStringList;
  i: longint;
  lFind,NoCor: boolean;
begin
  AddStack('TInterMemo.PrUnUsed',Self);
  if Pos in [ivpDefine,ivpRepeat] then begin
    ls:=KeywordN(kwNoUsed); lFind:=IgnoreSlFindAdd(ls,VarName,i); NoCor:=InterTmpVarPrefNoCor(VarName);
    if NoCor then FindDel(KeywordN(kwVar),VarName);
    ls.Objects[i]:=Pointer(lFind or NoCor); Pos:=iif(NoCor,ipvPrefNoCor,ivpDefine);
  end;
  DelStack;
end;

procedure TInterMemo.UserListCont;
var fl: boolean;
begin
  AddStack('TInterMemo.UserListCont',Self);
  fl:=true;
  if listType=ulsKeyword then
    if pSelStart<0 then begin
      if (RightStr(cont,2)=FuncBrackNul) and CallTip and not CallTipActiveBrack
      then CallTipBrack([ctbrBound]);
    end
    else if KeywordN(kwFunc).IndexOf(cont)>=0 then begin
      IncD(cont,FuncBrackNul); pSelStart:=Length(cont); fl:=false;
    end;
  if fl then inherited UserListCont(listType,Index,cont,pSelStart);
  DelStack;
end;

procedure TInterMemo.doSciDwellStart;
const lStruct=Length(sStruct)+2;
var p,pb,i,j,k,l,nStruct: longint;
  kwd,hnt,s,s1,s2: string;
  fl: boolean;
  vt: TInterVarType;
  a: TArrStr;
  dwStruct: TWord2DWord;
label lend;
begin
  AddStack('TInterMemo.doSciDwellStart',Self);
  inherited doSciDwellStart(position);
  if (position>=0) and not CallTipActiveBrack then begin
    i:=LineFromPosition(position); pb:=PositionFromLine(i); s:=Lines[i];
    aCallTip:=nil; hnt:='';
    if IdentInPos(kwd,s,position-pb,' ',false,@p) then begin
      Inc(pb,p-Length(kwd)-1); s1:=s;
      while i>0 do begin
        RightTrimComment(s2,l,i-1);
        if LineContinue(s2,l) then begin
          IncL(s1,SubStr(s2,1,-1)); Dec(i);
        end
        else break;
      end;
      TrimLeftSelf(s1);
      if IsDefVar(s1,sStruct) then
        for i:=0 to LsArrDynamic(System.Copy(s1,lStruct,MaxInt),a,',')-1 do if Trim(a[i])=kwd then begin
          AddFrom(aCallTip,'#'+kwd); hnt:=IntToStr(i+1); break;
        end;
      if hnt='' then begin
        for j:=p to Length(s) do begin
          case s[j] of
            #0..' ': continue;
            '(': if CallTipDwellType=ctdwNormal then
              if FindFunc(kwd,i) then with aFunc[i] do begin
                SetLength(aCallTip,lPrm);
                for k:=1 to lPrm do aCallTip[k-1]:=Self.aPrm[k];
                s:=InterEdStrTypes(types);
                if s<>'' then begin
                  IncL(s,': ');
                  if lPrm>1 then AddFrom(aCallTip,s)
                  else IncD(aCallTip[high(aCallTip)],s);
                end;
                hnt:=hint; goto lend;
              end;
          end;
          break;
        end;
        nStruct:=-1;
        if pb>0 then if char(GetCharAt(pb-1)) in ['.','#'] then begin
          LsVarFill(ivtTmpVar);
          if Inter.lsStruct.Find(kwd,i) then begin
            IncL(kwd,'#'); nStruct:=i;
          end;
        end;
        case CallTipDwellType of
          ctdwNormal:
            if nStruct>=0 then begin
              AddFrom(aCallTip,kwd); dwStruct.dw:=LongWordObj(Inter.lsStruct,nStruct); hnt:=IntToStr(dwStruct.w2);
            end
            else if IntObjFind(KeywordN(kwVar),kwd,i) then begin
              if i>=0 then with aVar[ivtVar][i] do begin
                AddFrom(aCallTip,[DlmBetween(DlmBetween(kwd,InterEdStrTypes(types),': '),
                  IfThen(ReadOnly,'только для чтения'),',')]);
                hnt:=hint;
              end;
            end
            else if IntObjFind(KeywordN(kwOperator),kwd,i) then begin
              AddFrom(aCallTip,kwd); hnt:=aOper[i].hint;
            end;
          ctdwDebug: begin
            fl := nStruct>=0;
            if not fl then begin
              LsVarFill(ivtTmpVar);
              for vt:=low(aVar) to high(aVar) do if KeywordN(aVtKw[vt]).IndexOf(kwd)>=0 then begin
                fl:=true; break;
              end;
            end;
            if fl then begin
              AddFrom(aCallTip,kwd); hnt:=DebugEval(kwd);
            end;
          end;
        end;
      end;
    end;
lend:
    fl := hnt<>'';
    if fl then AddFrom(aCallTip,hnt);
    l:=Length(aCallTip);
    if l>0 then
      if not((l=1) and (aCallTip[0]=kwd)) then begin
        s:=FCallTipShow(pb);
        if fl then begin
          l:=Length(s); FCallTipSetHlt(l-Length(hnt),l);
        end;
      end;
  end;
  DelStack;
end;

procedure TInterMemo.doSciDwellEnd;
begin
  AddStack('TInterMemo.doSciDwellEnd',Self);
  if IsSci then if nPrm=0 then Sci.CallTipCancel;
  inherited doSciDwellEnd(position);
  DelStack;
end;

function TInterMemo.DebugEval;
  function StMeserr(const s: variant; lPck: boolean): string;
  var i,l,h: longint;
    c: Char;
  begin
    AddStack('TInterMemo.DebugEval.StMeserr',Self);
    case MyVarType(s) of
      varNull: result:='NIL';
      varDate: result:=dtoc(s);
      varBoolean: result:=bVar[boolean(s)];
      varString: begin
        result:=StrTran(s,' ',#183);
        if lPck then result:=Trim(Str3t(result,30));
        result:='"'+StrTran(result,CRLF,#10)+'"';
      end;
      varArray: begin
        l:=VarArrayLowBound(s,1); h:=VarArrayHighBound(s,1); result:='';
        for i:=l to h do IncD(result,','+StMeserr(s[i],true));
        result:=IntToStr(h-l+1)+':{'+System.Copy(result,2,MaxInt)+'}';
      end;
    else
      c:=DecimalSeparator;
      try
        DecimalSeparator:='.'; result:=VarAsType(s,varString);
      finally
        DecimalSeparator:=c;
      end;
    end;
    DelStack;
  end;
var v: variant;
  ost: longint;
  oDebug: boolean;
begin
  ost:=AddStack('TInterMemo.DebugEval',Self);
  with Inter do begin
    oDebug:=lDebug; lDebug:=true; SetProg(fml); result:='[Ошибка вычисления]';
    try
      if EvalChk(v) then result:=StMeserr(v,false);
    except
      SetStack(ost);
    end;
    lDebug:=oDebug;
  end;
  DelStack;
end;

procedure TInterMemo.DebugEvalSelf;
begin
  fml:=DebugEval(fml);
end;

function TInterMemo.FindFunc;
var p: longint;
  k,l: TInterPrmOvlList;
  ap: TInterPrmOvlStr;
begin
  AddStack('TInterMemo.FindFunc',Self);
  result:=IntObjFind(KeywordN(kwFunc),kwd,i);
  if result then begin
    lPrm:=1; aPrm[lPrm]:='';
    with aFunc[i] do for p:=low(aPrm) to high(aPrm) do begin
      if aPrm[p,1]='' then break;
      l:=ListAsArray(aPrm[p,1],ap,'~');
      while lPrm<l do begin
        Self.aPrm[lPrm+1]:=Self.aPrm[lPrm]; Inc(lPrm);
      end;
      for k:=1 to l do
        if ap[k]<>'' then IncD(Self.aPrm[k],IfThen(p>low(aPrm),cDlmPrm)+ap[k]);
    end;
    for k:=1 to lPrm do aPrm[k]:=kwd+BrackNoEmp(aPrm[k]);
  end;
  DelStack;
end;

function TInterMemo.FCallTipShow;
var w: longint;
  function NoIsScreen: boolean;
  begin
    AddStack('TInterMemo.FCallTipShow.NoIsScreen',Self);
    result := Sci.PointXFromPosition(pos)>w;
    DelStack;
  end;
var i,w1: longint;
  cnv: TCanvas;
  s1,s2: string;
begin
  AddStack('TInterMemo.FCallTipShow',Self);
  if IsSci then with Sci do begin
    CallTipUseStyle(0); nPrm:=nFuncPrm;
    if (nPrm>0) and (CallTipDwellType=ctdwNormal)
    then My_pr.CopyFrom(aCallTip,IfThen(lPrm>1,#2)+#1+aPrm[nPrm]);
    result:=ArrayAsList(aCallTip,#10);
    cnv:=GetParentForm(Control).Canvas;
    with Style0[STYLE_CALLTIP] do begin
      cnv.Font.Name:=FontName;
      cnv.Font.Size:=FontSize;
      cnv.Font.Style:=FontStyles;
    end;
    w1:=ScreenToClient(SysWorkArea.BottomRight).X; w:=w1-MaxSelf(cnv,aCallTip);
    i:=PositionFromLine(LineFromPosition(pos));
    while (pos>i) and NoIsScreen do Dec(pos);
    if NoIsScreen then begin
      i:=1;
      while i<=Length(result) do
        if result[i]>#2 then break else Inc(i);
      s1:=LeftStr(result,i-1); s2:=System.Copy(result,i,MaxInt);
      sCallTipView:=s1+StrTran(astolin(cnv,StrTran(s2,#10,CRLF),w1-max(0,PointXFromPosition(pos)),
        SysWorkArea.Bottom-SysWorkArea.Top),CRLF,#10);
      result:=s1+s2; CallTipShow(pos,PChar(sCallTipView));
    end
    else begin
      sCallTipView:=''; CallTipShow(pos,PChar(result));
    end;
  end
  else result:='';
  DelStack;
end;

procedure TInterMemo.FCallTipSetHlt;
var s: string;
  ps,pe,i1,i2,l1,l2: longint;
begin
  AddStack('TInterMemo.FCallTipSetHlt',Self);
  if IsSci then begin
    ps:=PosStart; pe:=PosEnd;
    if sCallTipView<>'' then begin
      s:=ArrayAsList(aCallTip,#10);
      i1:=1; l1:=min(Length(s),PosEnd);
      i2:=1; l2:=Length(sCallTipView);
      while i1<=l1 do begin
        while i2<=l2 do
          if s[i1]=sCallTipView[i2] then begin
            Inc(i2); break;
          end
          else begin
            while i1<=l1 do
              if s[i1]>' ' then break
              else begin
                if i1<=PosStart+1 then Dec(ps);
                Dec(pe); Inc(i1);
              end;
            if i1<=PosStart+1 then Inc(ps);
            Inc(pe); Inc(i2);
          end;
        Inc(i1);
      end;
    end;
    Sci.CallTipSetHlt(ps,pe);
  end;
  DelStack;
end;

procedure TInterMemo.BeforeShowKeyword;
begin
  AddStack('TInterMemo.BeforeShowKeyword',Self);
  if not IsStyleCng(SCE_OURLIB_WORD_TMPVAR) then LsVarFill(ivtTmpVar);
  DelStack;
end;

procedure TInterMemo.LsVarFill;
var ls: TStringList;
  i,l,n: longint;
  a: TVarPathStr;
  lv: TVarPathList;
  j: byte;
  Opt: TInterVarOpt;
begin
  AddStack('TInterMemo.LsVarFill',Self);
  if VarType=ivtTmpVar then with Inter do begin
    Setprog(Text); Compile(nil,false);
  end;
  Opt:=[ivWithEng];
  if NoDop then Include(Opt,ivNoDop);
  Tinter.GetVar(aVar[VarType],'',[VarType],Opt);
  if VarType=ivtTmpVar then with Inter do if lsStruct.Count>0 then begin
    l:=Length(aVar[VarType]); SetLength(aVar[VarType],l+1+lsStruct.Count); VarInit(aVar[VarType,l]);
    with aVar[VarType,l] do begin
      name:='$'; hint:='Структура';
    end;
    for i:=0 to lsStruct.Count-1 do begin
      Inc(l); VarInit(aVar[VarType,l]); aVar[VarType,l].name:=lsStruct[i];
    end;
  end;
  ls:=KeywordN(aVtKw[VarType]); ls.Clear; lv:=low(a);
  for i:=low(aVar[VarType]) to high(aVar[VarType]) do with aVar[VarType][i] do begin
    j:=0; l:=Length(name);
    while j<l do
      if name[j+1]='$' then Inc(j) else break;
    if j=0 then begin
      a[lv]:=name; l:=i;
      if VarType=ivtVar then
        if TInter.MemoVarIgnore(a) then l:=-1;
      if not(IgnoreSlFindAdd(ls,name,n) and (l<0)) then ls.Objects[n]:=Pointer(l);
    end
    else begin
      lv:=j+1; a[j]:=VarWithoutPrim(System.Copy(name,lv,MaxInt));
    end;
  end;
  DelStack;
end;

class function TInterMemo.KeywordVisible;
begin
  AddStack('TInterMemo.KeywordVisible');
  result:=not FirstEngChar(Keyword);
  DelStack;
end;

class function TInterMemo.IdentInPos;
  function CharIdent: boolean;
  begin
  	AddStack('TInterMemo.IdentInPos.CharIdent');
    result := IsChrWord(s[i]) or (cMacro<>' ') and (s[i]=cMacro);
    DelStack;
  end;
var fl: boolean;
  p,l: longint;
begin
	AddStack('TInterMemo.IdentInPos');
  fl:=true;
  while i>0 do
    if CharIdent then begin
      fl:=false; Dec(i);
    end
    else break;
  if fl and lDown then Ident:=''
  else begin
    inc(i); p:=i; l:=length(s);
    while i<=l do
      if CharIdent then Inc(i) else break;
    Ident:=System.Copy(s,p,i-p);
    SetPLongInt(pPosEnd,i);
  end;
  result := Ident<>'';
  DelStack;
end;

procedure TInterMemo.SetStatus;
begin
  AddStack('TInterMemo.SetStatus',Self);
  inherited SetStatus(Value);
  if Assigned(FStatus) then FStatus.SectType[mstLeft,2]:=1;
  DelStack;
end;

procedure TInterMemo.DoMoveCaret;
begin
  AddStack('TInterMemo.DoMoveCaret',Self);
  inherited DoMoveCaret(oldCaret,newCaret);
  if not FSearchInc and Assigned(FStatus) then FStatus.SectLeft[2]:='';
  CallTipBrackCng;
  DelStack;
end;

function TInterMemo.CompileEval;
var fl: boolean;
begin
  AddStack('TInterMemo.CompileEval',Self);
  Inter.Setprog(Text);
  if leval then fl:=Inter.EvalChk(result)
  else begin
    result:=Variants.null; fl:=Inter.Compile;
  end;
  if not fl then begin
    SelectLines(Inter.lError-1,Inter.lError-1);
    if Assigned(FStatus)
    then FStatus.SectLeft[2]:=SysUtils.Format('Строка %d: ',[Inter.lError])
      +DelTrim(StrTran(Inter.sError,CRLF,' '));
  end;
  DelStack;
end;

procedure TInterMemo.FormShow;
begin
  AddStack('TInterMemo.FormShow',Self);
  inherited FormShow(Sender);
	Init(TForm(Sender).Caption);
  DelStack;
end;

procedure TInterMemo.FormClose;
begin
  AddStack('TInterMemo.FormClose',Self);
  inherited FormClose(Sender,Action);
  if (Action=caHide) and (TForm(Sender).ModalResult=mrOk) and CheckOnClose then begin
    CompileEval(false);
    if Inter.Error<>E_NO then Action:=caNone;
  end;
  DelStack;
end;

procedure TInterMemo.HelpPart;
const
  acc: TInterBrackBoolStr =
    (('перебор вариантов наборов параметров функции с первого до последнего, после последнего варианта скрыть подсказку','перебор вариантов наборов параметров функции с последнего до первого, после первого варианта скрыть подсказку')
    ,('просмотр нумерации уровней вложенности массива','')
    ,('просмотр нумерации элементов массива','')
    ,('просмотр номера, соответствующего элементу структуры','')
    );
  aFuncOvl0: TArrBoolStr = ('просмотр набора параметров функции','');
  ak: TArrBoolInt = (K_Alt_9,K_Alt_0);
  acbrk: array[TInterCtrlBrackOper] of record
    nm: string;
    aBeg,aEnd: TArrBoolStr;
  end =
    ((nm:'блок оператора';aBeg:('закрывающего','открывающего');aEnd:('открывающему','закрывающему'))
    ,(nm:'скобки'        ;aBeg:('закрывающей' ,'открывающей' );aEnd:('открывающей' ,'закрывающей' ))
    );
var brk,b: TInterBrackList;
  fl: boolean;
  ac: TInterBrackBoolStr;
  a: array[TInterBrackList,boolean] of record
    akey: TArrVar;
    atxt: TArrStr;
  end;
  cbrk: TInterCtrlBrack;
begin
  AddStack('TInterMemo.HelpPart',Self);
  inherited HelpPart(Head);
  if Head=EdMemoHelpPartCurs then begin
    if CtrlBrack(cbrk) then with cbrk,acbrk[Oper] do HelpKey([K_Ctrl_9,K_Ctrl_0],
      'Перейти от '+aBeg[Clos]+' '+nm+' к '+aEnd[Clos],'Ctrl+(,Ctrl+)');
  end
  else if Head=EdMemoHelpPartCng
    then HelpKey(K_F5,'',true)
  else if Head=EdMemoHelpPartChr then begin
    HelpKey([K_Ctrl_7],'&&','Ctrl+&');
    HelpKey('Ctrl+=','=>');
  end
  else if Head=EdMemoHelpPartCallTip then begin
    ac:=acc; Finalize(a);
    if CallTipBrack([ctbrBound],NegDef,@brk) then begin
      if (brk=brckFunc) and (lPrm<2) then ac[brk]:=aFuncOvl0;
      for fl:=false to true do with a[brk,(ac[brk,fl]='')<>fl] do begin
        AddFromVArr(akey,[ak[fl]]); AddFrom(atxt,'Alt+'+aBrack[brckFunc,fl]);
      end;
    end;
    for b:=low(a) to high(a) do
      for fl:=false to true do with a[b,fl] do
        if Length(atxt)>0 then HelpKey(akey,FRup(ac[b,fl]),ArrayAsList(atxt,','));
    if CallTip then for b:=low(a) to high(a) do if Length(aBrack[b,false])=1 then
      if CallTipBrack([ctbrBound],NegDef,@brk,@aBrack[b,false]) then
        if brk=b then HelpKey(aBrack[b,false],'Вывод символа '+HelpBoldStr('«'+aBrack[b,false]+'»')+' и '+ac[b,false]);
  end
  ;DelStack;
end;

{ TSQLMemo }
constructor TSQLMemo.CreateParent;
  procedure FontBold(n: TEdMemoFontList);
  begin
    AddStack('TSQLMemo.CreateParent.FontBold',Self);
    with PropDef[true].aFont[n] do begin
      FontStylesCng:=true; Include(FontStyles,fsBold);
    end;
    DelStack;
  end;
var i: longint;
begin
  AddStack('TSQLMemo.CreateParent',Self);
  inherited CreateParent(AOwner,AParent);
  FontBold(SCE_SQL_WORD);
  FontBold(SCE_SQL_OPERATOR);
  CngFont:=nil;
  PropFontAdd('Пробелы',SCE_SQL_DEFAULT);
  PropFontAdd('Комментарий на несколько строк',[SCE_SQL_COMMENT,SCE_SQL_COMMENTDOC]);
  PropFontAdd('Комментарий до конца строки',SCE_SQL_COMMENTLINE);
  PropFontAdd('Числа',SCE_SQL_NUMBER);
  PropFontAdd('Ключевые слова',SCE_SQL_WORD);
  PropFontAdd('Строки с двойными кавычками',SCE_SQL_STRING);
  PropFontAdd('Строки с одинарными кавычками',SCE_SQL_CHARACTER);
  PropFontAdd('Операторы',SCE_SQL_OPERATOR);
  PropFontAdd('Идентификаторы',SCE_SQL_IDENTIFIER);
  PropFontAddBrack;
  IncCng([emoFolding]);
  if IsSci then Sci.LanguageManager.LanguageList[0].Lexer:='sql';
  KeywordBeginUpdate;
  for i:=0 to KeyWordCount-1 do if i<>kwReserved then KeywordN(i).Clear;
  KeywordN(0).Text:=ArrayAsList(
    ['absolute','action','add','admin','after','aggregate','alias','all','allocate'
    ,'alter','and','any','are','array','as','asc','assertion','at','authorization'
    ,'before','begin','binary','bit','blob','boolean','both','breadth','by'
    ,'call','cascade','cascaded','case','cast','catalog','char','character'
    ,'check','class','clob','close','collate','collation','column','commit','completion'
    ,'connect','connection','constraint','constraints','constructor','continue','corresponding'
    ,'create','cross','cube','current','current_date','current_path','current_role'
    ,'current_time','current_timestamp','current_user','cursor','cycle'
    ,'data','date','day','deallocate','dec','decimal','declare','default'
    ,'deferrable','deferred','delete','depth','deref','desc','describe','descriptor'
    ,'destroy','destructor','deterministic','dictionary','diagnostics','disconnect'
    ,'distinct','domain','double','drop','dynamic'
    ,'each','else','end','end-exec','equals','escape','every','except'
    ,'exception','exec','execute','external'
    ,'false','fetch','first','float','for','foreign','found','from','free','full'
    ,'function'
    ,'general','get','global','go','goto','grant','group','grouping'
    ,'having','host','hour'
    ,'identity','if','ignore','immediate','in','indicator','initialize','initially'
    ,'inner','inout','input','insert','int','integer','intersect','interval'
    ,'into','is','isolation','iterate'
    ,'join'
    ,'key'
    ,'language','large','last','lateral','leading','left','less','level','like'
    ,'limit','local','localtime','localtimestamp','locator'
    ,'map','match','minute','modifies','modify','module','month'
    ,'names','national','natural','nchar','nclob','new','next','no','none'
    ,'not','null','numeric'
    ,'object','of','off','old','on','only','open','operation','option'
    ,'or','order','ordinality','out','outer','output'
    ,'pad','parameter','parameters','partial','path','postfix','precision','prefix'
    ,'preorder','prepare','preserve','primary'
    ,'prior','privileges','procedure','public'
    ,'read','reads','real','recursive','ref','references','referencing','relative'
    ,'restrict','result','return','returns','revoke','right'
    ,'role','rollback','rollup','routine','row','rows'
    ,'savepoint','schema','scroll','scope','search','second','section','select'
    ,'sequence','session','session_user','set','sets','size','smallint','some|','space'
    ,'specific','specifictype','sql','sqlexception','sqlstate','sqlwarning','start'
    ,'state','statement','static','structure','system_user'
    ,'table','temporary','terminate','than','then','time','timestamp'
    ,'timezone_hour','timezone_minute','to','trailing','transaction','translation'
    ,'treat','trigger','true'
    ,'under','union','unique','unknown'
    ,'unnest','update','usage','user','using'
    ,'value','values','varchar','variable','varying','view'
    ,'when','whenever','where','with','without','work','write'
    ,'year'
    ,'zone'
    ],CRLF);
  KeywordEndUpdate;
  SetLength(aKeywords,1); aKeywords[0]:=0;
  DelStack;
end;

{ TXmlMemo
constructor TXmlMemo.CreateParent;
var fl: boolean;
begin
  AddStack('TXmlMemo.CreateParent',Self);
  inherited CreateParent(AOwner,AParent);
  for fl:=false to true do with PropDef[fl] do begin
    MarkerType:=byte(sciMarkBox); LineNumber:=true;
  end;
  Include(Cng,emoFolding);
  LanguageManager.LanguageList[0].Lexer:='xml';
  DelStack;
end;}

{ TEdText }
class function TEdText.Execute;
var ost,i,ogg: longint;
  fl: boolean;
  vtxt: string;
  f: TForm;
  MemoEd: StdCtrls.TMemo;
begin
	ost:=AddStack('TEdText.Execute');
  if SimpleForm then begin
    f:=TForm.Create(Application);
    with f do begin
      SetBounds(0,0,800,600); Caption:=capt; KeyPreview:=true;
      Position:=poScreenCenter; OnResize:=SimpleFormResize; OnKeyDown:=SimpleFormKeyDown;
      MemoEd:=StdCtrls.TMemo.Create(f);
      with MemoEd do begin
        Parent:=f; ScrollBars:=ssBoth; Text:=txt;
      end;
      result := ShowModal=mrOk;
      if result then txt:=MemoEd.Text;
    end;
  end
  else begin
    ogg:=GetUserGG;
    if (EdClass=TInterMemo) and (ogg<2) and CanPriv(PrivDesign) then SetUserGG(2);
    Inc(nEdText);
    if nEdText=Length(aEdText) then SetLength(aEdText,nEdText+1);
    fl:=CreateForm(TEdText,aEdText[nEdText]);
    try
      with aEdText[nEdText] do begin
        if not fl then
          if MemoEdit.ClassType<>EdClass then begin
            MemoEdit.Free; fl:=true;
          end;
        if fl then begin
          MemoEdit:=TClassTextMemo(EdClass).CreateParent(aEdText[nEdText],PnMemo);
          MemoEdit.Status:=RbStatus1;
          SetSchemForm; PnMemoResize(PnMemo);
        end;
      end;
      IfThenNotify(BeforeShow,aEdText[nEdText]);
      with aEdText[nEdText] do begin
        caption:=capt; MemoEdit.PrChangeFileName:=ChangeFileName; MemoEdit.FileName:=FileName;
        FHelpProc:=HelpProc; MemoEdit.OnMaxLength:=PrMaxLength; vtxt:=txt;
        if edtxtReadOnly in Opt then for i:=1 to Length(vtxt) do
          if (vtxt[i]<' ') and not(vtxt[i] in [TAB,CRLF[1],CRLF[2],cLink]) then vtxt[i]:=#31;
        result:=true;
        if Pos(cLink,vtxt)=0 then TextCRLFSelf(vtxt);
        try
          MemoEdit.SetText(vtxt);
        except
          on EInvalidOperation do begin
            SetStack(ost);
            if not IfThenNotify(PrEditIfError,TObject(pav))
            then MsgDlg(IfThen(MsgErrBig='','Ошибка '+IfThen(edtxtReadOnly in Opt,'просмотра','редактирования')+' текста:'
              +CRLF+'размер текста слишком большой.',MsgErrBig));
            result:=false;
          end;
        end;
        if result then begin
          with KeyLb1 do begin
            DelKey(K_All,'dopfunc'); SetKeysSt(dname,dfunc,'dopfunc'); ReDrw;
          end;
          MemoEdit.ReadOnly:=edtxtReadOnly in Opt;
          MemoEdit.FStatus.SectLeft[2]:=InfStr;
          if MemoEdit is TInterMemo then TInterMemo(MemoEdit).CheckOnClose:=not(edtxtNoChkFml in Opt);
          if hc<>0 then MemoEdit.Control.HelpContext:=hc;
          MemoEdit.WordWrapBool := edtxtWordWrap in Opt;
          MemoEdit.ReadIdent(crStart,crLen);
          if EdTextInitFind then begin
            SetExecKey([K_Shift_F6]); EdTextInitFind:=false;
          end;
          MemoEdit.SetSelection(crStart,crLen);
          result := showmodal=mrOK; MemoEdit.SaveIdent;
          if result then txt:=TextCRLF(MemoEdit.GetText);
        end;
      end;
      IfThenNotify(AfterShow,aEdText[nEdText]);
    finally
      FormFree(aEdText[nEdText]); Dec(nEdText); SetUserGG(ogg);
    end;
  end;
  DelStack;
end;

function EdTextExec(const capt: string; var txt: string;
  const dname: string = ''; dfunc: TKeyProc = nil; Opt: TEdTextOpt = []; EdType: TEdTextType = edtpText;
  crStart: longint = 0; crLen: longint = 0; const InfStr: string = '';
  hc: THelpContext = 0; AfterShow: TNotifyEvent = nil; const MsgErrBig: string = '';
  PrEditIfError: TNotifyEvent = nil; pav: PArrVar = nil; const FileName: TFileName = '';
  BeforeShow: TNotifyEvent = nil; ChangeFileName: TNotifyEvent = nil; HelpProc: TWndMethod = nil;
  PrMaxLength: TMaxLengthEvent = nil): boolean;
begin
  AddStack('FEdText.EdTextExec');
	result:=TEdText.Execute(capt,txt,
    dname,dfunc,Opt,TClassTextMemo(aEdClass[EdType]),crStart,crLen,InfStr,hc,AfterShow,MsgErrBig,
    PrEditIfError,pav,FileName,BeforeShow,ChangeFileName,HelpProc,PrMaxLength);
  DelStack;
end;

procedure TEdText.FormShow(Sender: TObject);
begin
	AddStack('TEdText.FormShow',Self);
  inherited;
  MemoEdit.FormShow(Sender); TTimerOne.CreateProc(TimerScroll,Self);
  DelStack;
end;

procedure TEdText.TimerScroll;
begin
  AddStack('TEdText.TimerScroll',Self);
  MemoEdit.ScrollCaret;
  DelStack;
end;

procedure TEdText.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	AddStack('TEdText.FormClose',Self);
  inherited;
  MemoEdit.FormClose(Sender,Action);
  if Action=caHide then if ModalResult=mrOk then if not MemoEdit.MaxLengthCheck then Action:=caNone;
  DelStack;
end;

procedure TEdText.PnMemoResize(Sender: TObject);
begin
	AddStack('TEdText.PnMemoResize',Self);
  inherited;
  if Assigned(MemoEdit) then with PnMemo do MemoEdit.SetBounds(BevPanel,BevPanel,CltWidth,CltHeight);
  DelStack;
end;

procedure TEdText.WMFormLimit;
var i: longint;
begin
	AddStack('TEdText.WMFormLimit',Self);
  inherited;
  for i:=low(aEdText) to high(aEdText) do if FreeLimit(aEdText[i]) then break;
  DelStack;
end;

procedure TEdText.WMHelpFill;
begin
  AddStack('TEdText.WMHelpFill',Self);
  inherited;
  IfThenWndMethod(FHelpProc,Message);
  DelStack;
end;

class procedure TEdText.SimpleFormResize;
begin
	AddStack('TEdText.SimpleFormResize');
	with TForm(Sender) do
  	if ControlCount>0 then Controls[0].SetBounds(0,0,ClientWidth,ClientHeight);
  DelStack;
end;

class procedure TEdText.SimpleFormKeyDown;
begin
	AddStack('TEdText.SimpleFormKeyDown');
	if Shift=[] then with TForm(Sender) do case Key of
    vk_Escape: ModalResult:=mrCancel;
    vk_F10: ModalResult:=mrOk;
  end;
  DelStack;
end;

// ФАЙЛ_РЕДАКТ
function c_edfile(var av: array of variant): variant;
var s: string;
  EdClass: TClassTextMemo;
  tpcod: byte;
begin
	AddStack('FEdText.c_edfile');
  TrimSelf(av[1]); result:=MyFileExists(av[1]);
  if result then begin
    s:=GetStrFile(av[1]); tpcod:=Bool2Int(av[2]);
    case tpcod of
      1: DosToWinSelf(s);
      2: Utf8ToWinSelf(s);
    end;
    {if IsNilc(av[7],0)=1 then EdClass:=TXmlMemo else} EdClass:=TTextMemo;
    result:=TEdText.Execute(IsNilc(av[5],'Файл: '+av[1]),s,'',nil,
      IfThen(IsNilc(av[3],false),edtxtReadOnly)+IfThen(IsNilc(av[6],false),edtxtWordWrap),EdClass,0,0,
    	FormatDateTime('Дата формирования: dd/mm/yyyy (hh:nn:ss)',GetFileDateTime(av[1])),
      0,nil,IsNilc(av[4],''),nil,nil,av[1]);
    if result then begin
      case tpcod of
        1: WinToDosSelf(s);
        2: s:=WinToUtf8(s);
      end;
    	SetStrFile(av[1],s);
    end;
  end
  else mess_ok(['Отсутствует файл:',av[1]]);
  DelStack;
end;

procedure CngSelfPriv;
begin
  AddStack('FEdText.CngSelfPriv');
  DisposeNil(pointer(pPropEx));
  DelStack;
end;

procedure SetFill(const a: array of TEdMemoFontDef; var st: TEdMemoFontSet);
var i: byte;
begin
  AddStack('FEdText.SetFill');
  st:=[];
  for i:=low(a) to high(a) do Include(st,a[i].n);
  DelStack;
end;

initialization
  AddStack('FEdText.initialization');
  MyTypes.EdTextExec:=EdTextExec;
  MyTypes.c_edfile:=Tinter.ReSetFunction('ФАЙЛ_РЕДАКТ',c_edfile);
  aEdClass[edtpText]:=TTextMemo; aEdClass[edtpInter]:=TInterMemo;
  SetFill(aStComment,setComment);
  SetFill(aStConst,setConst);
  AddFrom(aCngSelfPriv,CngSelfPriv);
  DelStack;
finalization
  AddStack('FEdText.finalization');
  lsIdent.Free; CtrlIdent.Free; DisposeNil(pointer(pPropEx)); 
  DelStack;
end.

