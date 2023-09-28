unit FEdGenFr;

interface

{$I LIBTEST}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls,
    Menus, Types, pQRCode,
  MyTypes, My_pr, Askp, MulQry, FRMEMPTY, Keylb, Fpanel, PnlEdit, GenForm, RecVal, Recdb, FFldedit,
    MenuGet, SpdBtGet, MnDrwGet, ButGet, ComboGet, RbScroll, KeyMenu, DefEdit, ChkGets, ModelGet,
    PaintCtl, RbMenu, CCodeGet, ListF2;

type
	TGFEdGetEvent = function(Sender: TWinControl; MinWidth: longint;
  	const Capt: string; var txt: string): boolean of object;

  TGFClpBrd = record
    aObj: TArrGFObj;
    rObj: TRect;
    aFont: array of record
      Font: TDefFont;
      Prop: TGFPackFontProp;
    end;
  end;

  TEdGenFr = class(TFormEmp)
    PnGF1: TRbPanel;
    PnEdit: TRbPanel;
    RGF: TRecVal;
    FillGet: TSpdButGet;
    LnWidthGet: TMenuDrawGet;
    RGF1: TRecVal;
    TypeGet: TMenuGet;
    TextGet: TButGet;
    TextDlg: TOpenDialog;
    PnObj: TPanelEdit;
    SLeft: TFldEdit;
    ELeft: TFldEdit;
    STop: TFldEdit;
    ETop: TFldEdit;
    SRight: TFldEdit;
    ERight: TFldEdit;
    SBottom: TFldEdit;
    EBottom: TFldEdit;
    STypeObj: TFldEdit;
    ETypeObj: TFldEdit;
    SText: TFldEdit;
    EText: TFldEdit;
    SAlignment: TFldEdit;
    EAlignment: TFldEdit;
    SOColor: TFldEdit;
    EOColor: TFldEdit;
    SFont: TFldEdit;
    EFont: TFldEdit;
    SMinWidth: TFldEdit;
    EMinWidth: TFldEdit;
    SMinHeight: TFldEdit;
    EMinHeight: TFldEdit;
    SPin: TFldEdit;
    EPin: TFldEdit;
    PnFill: TPanelEdit;
    EVFill: TFldEdit;
    EColor: TFldEdit;
    ELnWidth: TFldEdit;
    SPart: TFldEdit;
    EPart: TFldEdit;
    RbStatus1: TRbStatus;
    PnGF: TRbPanel;
    PnGF2: TRbPanel;
    ScrlGF: TRbScrollBox;
    GF: TGenForm;
    PinGet: TMenuDrawGet;
    KeyMenu1: TKeyMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    SMMetr: TFldEdit;
    EMMetr: TFldEdit;
    MMetrGet: TMenuGet;
    FontGet: TMenuGet;
    PopupMenu1: TPopupMenu;
    M_Shift_F2: TMenuItem;
    MSelObj: TMenuItem;
    M_R2: TMenuItem;
    M_Shift_F3: TMenuItem;
    M_Ctrl_1: TMenuItem;
    M_Ctrl_2: TMenuItem;
    M_Ctrl_3: TMenuItem;
    M_Ctrl_4: TMenuItem;
    M_F4: TMenuItem;
    M_Ctrl_F5: TMenuItem;
    M_Space: TMenuItem;
    M_Enter: TMenuItem;
    M_F2: TMenuItem;
    M_F5: TMenuItem;
    M_F8: TMenuItem;
    M_Ctrl_F7: TMenuItem;
    M_F7: TMenuItem;
    MDivObj: TMenuItem;
    M_Ctrl_Left: TMenuItem;
    M_Ctrl_Right: TMenuItem;
    M_Ctrl_Up: TMenuItem;
    M_Ctrl_Down: TMenuItem;
    M_R3: TMenuItem;
    M_R1: TMenuItem;
    PartGet: TComboGet;
    ColGet: TComboGet;
    M_Ctrl_5: TMenuItem;
    SVOut: TFldEdit;
    EVOut: TFldEdit;
    M_Ctrl_6: TMenuItem;
    VOutGet: TMenuGet;
    deAdd: TDefEdit;
    DivVidGet: TRadioGet;
    deFont: TDefEdit;
    FontLsGet: TButGet;
    deSel: TDefEdit;
    RDocPrm: TRecDBDef;
    RDocpPrm: TRecDBDef;
    MDW: TMenuItem;
    M_Ctrl_F6: TMenuItem;
    M_Ctrl_F8: TMenuItem;
    M_Shift_F8: TMenuItem;
    M_Shift_F6: TMenuItem;
    PrmGet: TButGet;
    M_Ctrl_7: TMenuItem;
    M_Ctrl_8: TMenuItem;
    M_R4: TMenuItem;
    M_Ctrl_V: TMenuItem;
    M_Ctrl_C: TMenuItem;
    M_Ctrl_F3: TMenuItem;
    dePrm: TDefEdit;
    dePage: TDefEdit;
    deDopAlgName: TDefEdit;
    M_Ctrl_X: TMenuItem;
    deFont0: TDefEdit;
    FontDopGet: TButGet;
    FontTypeGet: TRadioGet;
    deFont1: TDefEdit;
    deFont2: TDefEdit;
    M_Shift_F7: TMenuItem;
    deNewLine: TDefEdit;
    mnInsObj: TDefMenu;
    SCol: TFldEdit;
    ECol: TFldEdit;
    SIdent: TFldEdit;
    EIdent: TFldEdit;
    deAutoSave: TDefEdit;
    M_Ctrl_9: TMenuItem;
    M_Ctrl_0: TMenuItem;
    M_Ctrl_Zpt: TMenuItem;
    M_Ctrl_Point: TMenuItem;
    M_Ctrl_Plus: TMenuItem;
    deFont3: TDefEdit;
    deFont4: TDefEdit;
    SOnly1: TFldEdit;
    EOnly1: TFldEdit;
    M_Ctrl_Minus: TMenuItem;
    deFontSel: TDefEdit;
    procedure GFSelectGrid(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GFEnter(Sender: TObject);
    procedure GFExit(Sender: TObject);
    procedure PnObjBeforeEnter(Sender: TObject);
    procedure PnObjBeforeExit(Sender: TObject);
    procedure PnFillBeforeEnter(Sender: TObject);
    procedure PnFillBeforeExit(Sender: TObject);
    procedure FillGetClick(PaintButton: TPaintButton; Index: longint);
    procedure SLeftExit(Sender: TObject);
    procedure PnObjExit(Sender: TObject);
    procedure ELeftChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    procedure ETypeObjChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    procedure PnObjEnter(Sender: TObject);
    procedure PnObjEscape(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure PnGFResize(Sender: TObject);
    procedure PnFillEnter(Sender: TObject);
    procedure EColorChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    procedure PnFillSetWHMin(Sender: TObject);
    procedure PnFillExit(Sender: TObject);
    procedure ELeftAfterExit(Sender: TObject);
    function PnObjValid(Sender: TObject): Boolean;
    procedure EAlignmentMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: longint);
    procedure APopupClick(Sender: TObject);
    function FontGetListOwner(Sender: TObject; SpdBut: TPaintButton;
      const RectList: TRect; PozList: TPozList): Boolean;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure deAddFrmShow(Sender: TObject);
    function deAddPnlValid(Sender: TObject): Boolean;
    procedure RDocPrmDWTrans(Sender: TObject; var sTrans: String;
      lSave: Boolean);
    function TextGetClick(Sender: TObject; lEval: Boolean): String;
    function FontLsGetClick(Sender: TObject; lEval: Boolean): String;
    procedure FontLsGetPaint(Sender: TObject; const ARect: TRect; const Text: String);
    procedure FontLsGetSize(Sender: TObject; const Text: String; var Size: tagSIZE);
    function RDocPrmDWCanDel(Sender: TObject; const VarName,MsgName: String): Boolean;
    procedure RDocPrmDWCngName(Sender: TObject; const OldName,NewName: String;
      var result: Boolean);
    procedure LnWidthGetSizePaint(Sender: TObject; tf: TFldEdit;
      isList: Boolean; var Size: tagSIZE);
    procedure LnWidthGetDrawItem(Sender: TObject; Canvas: TCanvas;
      const nRect: TRect; Index: longint; State: TOwnerDrawState;
      tf: TFldEdit; const Cod: String; isList: Boolean);
    procedure PinGetSizePaint(Sender: TObject; tf: TFldEdit;
      isList: Boolean; var Size: tagSIZE);
    procedure PinGetDrawItem(Sender: TObject; Canvas: TCanvas;
      const nRect: TRect; Index: longint; State: TOwnerDrawState;
      tf: TFldEdit; const Cod: String; isList: Boolean);
    procedure RDocPrmDWVarValid(Sender: TObject; Proc: TProcVarValid;
      const r: TDWVidRec; var result: Boolean);
    procedure RDocPrmDWArrSeek(Sender: TObject; var result: TDWArrSeekRec);
    procedure RDocPrmDWArrCodName(Sender: TObject; Qry: Tmulquery; var Cod,
      Name: String);
    function dePrmFldCheck(Sender: TObject): Boolean;
    procedure RDocPrmDWFldSeek(Sender: TObject; var a: TDWFldArrSeek;
      prAdd: TDWFldProcAdd);
    procedure deFontFldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    function FontDopGetClick(Sender: TObject; lEval: Boolean): String;
    procedure deFont1FldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure deFont0FldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure FontDopGetPaint(Sender: TObject; const ARect: TRect;
      const Text: String);
    procedure deNewLineFrmShow(Sender: TObject);
    function deNewLinePnlValid(Sender: TObject): Boolean;
    procedure RDocPrmCalculate(Sender: TCustomRec; lApp: boolean);
    procedure EAlignmentMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: longint);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure deAddPnlCngKey(Sender: TObject; var tb: TKeyBut);
    procedure deSelPnlCngKey(Sender: TObject; var tb: TKeyBut);
    procedure deNewLinePnlCngKey(Sender: TObject; var tb: TKeyBut);
    procedure deFontFldExit(Sender: TObject);
    procedure deFont4FldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
  private
    { Private declarations }
    tmAutoSave: TTimerLock;
    EnblObj,EnblFill,GFRefresh,oGFRefresh,FModified,ModFromLastAutoSave,CngDat,CngPrm,KeyExtend,AlignmentMouseDown: boolean;
    oSelCnt,curInd,oldInd,CurLeaf: longint;
    rSO: TRect;
    TextObj,oTextObj: string;
    TmpList: TList;
    aoObj: TArrGFObj;
    PFont: TGFPackFont;
    aInfo: TGFSearchAInfo;
    SearchInfo: TGFSearchInfo;
    prEdGet: TGFEdGetEvent;
    oApplException: TExceptionEvent;
    PClpBrd: ^TGFClpBrd;
    ClpBrdViewer: HWND;
    pDcmDef: PString;
		procedure ApplException(Sender: TObject; E: Exception);
    procedure SetModified(Value: boolean);
    procedure GrSelProc(key: longint; tw: TWinControl);
    procedure ObjSelProc(key: longint; tw: TWinControl);
    procedure ObjDivProc(key: longint; tw: TWinControl);
    procedure ProcKey(key: longint; tw: TWinControl);
	  procedure FillLnWidth;
    procedure SetSpdBut;
		procedure PnObjUpdate(All: boolean = true);
    function SaveMsg: boolean;
    procedure OpenMsg(FromServer: boolean = false);
		procedure SaveDcm(Sender: TAsk);
		procedure OpenDcm(Sender: TAsk);
		procedure FontGetAssign;
    function FontGetList: string;
		function FontStr(i: byte; lFull: boolean): string;
    procedure FontGetProc(key: longint; tw: TWinControl);
		function FontCheck(Sender: TObject): Boolean;
		procedure FontUpdate(i: byte; ls: TFindListBox);
    procedure FontProc(lAfter: boolean; var StrList,KeyStr: string; var ProcKey: TKeyProc;
      var MouseDown,MouseUp: TMouseEvent; var MouseMove: TMouseMoveEvent; var Show: TNotifyEvent);
    procedure PrmProc(lAfter: boolean; var StrList,KeyStr: string; var ProcKey: TKeyProc;
      var MouseDown,MouseUp: TMouseEvent; var MouseMove: TMouseMoveEvent; var Show: TNotifyEvent);
		procedure GFAutoSize(Sender: TObject);
    procedure GFSelectObjs(Sender: TObject; ListObj: TList;
      lSel: Boolean);
    procedure FontMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: longint);
    procedure FontMouseMove(Sender: TObject;
      Shift: TShiftState; X,Y: longint);
    procedure FontMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: longint);
		procedure ProcKeyEdObj(key: longint; tw: TWinControl);
    procedure PrModify(Sender: TObject);
		procedure MsgVers;
		function prFind(Sender: TControl; const sf: string): boolean;
    procedure ClpBrdCanCopyPast;
    procedure ClpBrdCanPast;
    procedure SetClpBrdFont(pv: PGFObj);
    procedure FontToRGF;
    procedure RGFToFont;
		procedure RDBDef;
    procedure PrmKeyProc(key: longint; tw: TWinControl);
    procedure PrmMouseMove(Sender: TObject; Shift: TShiftState; X,Y: longint);
    procedure PrmMouseUp(Sender: TObject; Button: TMouseButton;
    	Shift: TShiftState; X,Y: longint);
		procedure AutoSaveKeyProc(key: longint; tw: TWinControl);
		procedure PageKeyProc(key: longint; tw: TWinControl);
		procedure PageMove(oi,ni: longint; const av: array of variant);
		procedure SetLeaf(nLeaf: longint);
		function ObjSpace: boolean;
		procedure ObjSpProcKey(key: longint; tw: TWinControl);
    procedure DisposeClpBrd;
    procedure tmAutoSaveTimer(Sender: TObject);
		function EdFont(var f: TGFPackFont; NoReadOnly: boolean; const KeyStr: string = '';
    	ProcKey: TKeyProc = nil): boolean;
    procedure FontAdd;
    function QRCode_ECCLevel: TQRCode_ECCLevel;
    function mgDefCod(Sender: TObject): String;
    procedure mgOwnerSave(Sender: TObject);
    procedure mgOwnerLoad(Sender: TObject);
    function mgDefNSave(Sender: TObject): longint;
    procedure mgHelp(Sender: TObject; var ht: THelpTbl);
    procedure mgUsedArr(Sender: TObject; lsUsed: TStringList);
    procedure WMGFSeekObj(var Message: TWMGFSeek); message WM_GFSEEKOBJ;
    procedure WMGFCngObj(var Message: TMessage); message WM_GFCNGOBJ;
    procedure WMChangeCBChain(var Msg: TWMChangeCBChain); message WM_CHANGECBCHAIN;
    procedure WMDrawClipboard(var Msg: TWMDrawClipboard); message WM_DRAWCLIPBOARD;
  public
    { Public declarations }
    CheckFml: boolean;
    function DcmDesign(const FileName: TFileName; const cCapt: string = '';
      EdGet: TGFEdGetEvent = nil; const whereDtg: string = '';
      lSetMod: boolean = false; EdSayProc: TStringEvent = nil; pDef: PString = nil): boolean;
		class procedure LoadWait;
    class procedure UpdateNumSave(const AFileName: TFileName; const DBFName: TFileName = '');
		class function EdFormEd(pDcmDef: PString; EdGet: TGFEdGetEvent; EdSayProc: TStringEvent;
    	Opt: TDEEdFormEdOpt = []): boolean;
		function ChangeDat(const whereDtg: string; const ao: TArrBoolStr; lTransaction: boolean = true): boolean;
    property Modified: boolean read FModified write SetModified;
  end;

const
	aGFSearchName: TGFSearchStr =
    ('алгоритм формирования','алгоритм дополнительных действий','действия для мыши',
    'текст объекта','идентификатор объекта','раздел объекта','колонка объекта',
    'окно ввода параметров','окно ввода данных','окно ввода для дополнительных действий');

var EdGenFr,LastEdGenFr: TEdGenFr;
  GFSaveDcm: TFuncBool;
  DcmArrCodNameProc: procedure(const FileDcmName: string; var Cod,Name: String);

implementation

{$R *.DFM}

uses Db,Math,pPDF417Custom,ComCtrls,StrUtils,
  Schem,MemoGet,Inter,FEdText,FGFPrm,FCngNum,FSchemDM,FIntTree,FDWPrm,FrmPswd,
    FSrchTre,FGFBmp,FGFPages,BufFile;

type
  TClipboardBufObj = class(TClipboardBuf)
  public
    constructor CreateRead;
  end;

  TNone = class
  private
		class procedure PrMove(oi,ni: longint; const av: array of variant);
		class function PrmCheck(Sender: TObject): Boolean;
		class procedure FLoadWait(Sender: TAsk);
		class procedure RDocPrmFldDefProc(Sender: TObject; Qry: TMulQuery; var s: string; lSave: boolean);
  end;

  TFillList = (btTop,btBottom,btLeft,btRight,btAll,btNone);

const
  sWND = '_WND';

  ClpBrdLastVers = 4;

  lGFPackFontProp = SizeOf(TGFPackFontProp);

  LenTmpNum = 6;

  SelObjsList = [K_Ctrl_0..K_Ctrl_Minus];

var aGF: TGenForm;
  fEdGF: TEdGenFr;
  lsDcmPrim: TStrStrList;

function PrmStr(i: byte): string;
begin
	AddStack('FEdGenFr.PrmStr');
	result:=SpaceStr(i+1,3)+'. '+GFPrm.aPrm[i].Name;
  DelStack;
end;

function FontGetStr: string;
begin
  AddStack('FEdGenFr.FontGetStr');
  with TKeyLb do result:=ArrayAsList(
    [GetKeySt(K_F3,'Сменить','Сменить номер')
    ,GetKeySt(K_F4,'Скопир.','Скопировать')
    ,GetKeySt(K_F5,'Редакт.','Редактировать')
    ,GetKeySt(K_F7,'Добав.','Добавить')
    ,GetKeySt(K_F8,'Удалить')
    ,GetKeySt(K_Ctrl_Up,'','Переместить выше')
    ,GetKeySt(K_Ctrl_Down,'','Переместить ниже')
    ],CRLF);
  DelStack;
end;

function GFPackFontPropToStr(const Prop: TGFPackFontProp): string;
begin
	AddStack('FEdGenFr.GFPackFontPropToStr');
  result:=PointerToStr(@Prop,lGFPackFontProp);
  DelStack;
end;

function StrToGFPackFontProp(const s: string): TGFPackFontProp;
begin
	AddStack('My_pr.StrToGFPackFontProp');
  StrToPointer(s,lGFPackFontProp,@result);
  DelStack;
end;

{ TEdGenFr }
function TEdGenFr.DcmDesign;
const at: array[TGFTypeObjList] of TBoolSet = (BoolSetAll,BoolSetAll,BoolSetAll,[false],[true],[true],[false]);
var ao: TArrBoolStr;
	fl: boolean;
  oEdGenFr: TEdGenFr;
  i: TGFTypeObjList;
begin
	AddStack('TEdGenFr.DcmDesign',Self);
  oEdGenFr:=LastEdGenFr; LastEdGenFr:=Self;
  GF.onAutoSize:=GFAutoSize; GF.onSelectObjs:=GFSelectObjs; fl:=Assigned(EdGet);
  with TypeGet.Items do begin
  	BeginUpdate; Clear;
    for i:=low(at) to high(at) do if fl in at[i] then Add(Int2Str(i)+UnDelim+aGFTypeObj[i]);
  	EndUpdate;
  end;
  GF.State:=gsDesign; prEdGet:=EdGet; GF.EdSayProc:=EdSayProc; GF.FileName:=FileName; pDcmDef:=pDef;
  Caption:=IfThen(empty(cCapt),'Редактирование формы: '+FileName,cCapt);
  OpenMsg;
  if Assigned(PrmGet) then PrmGet.RVid:='Параметры формы';
  Modified:=lSetMod; ao:=GF.awDat;
  CngDat:=true; CngPrm:=true; SetLeaf(GF.Leaf); MainRebuild;
  AddPrnHead(Caption); tmAutoSave.Enabled:=true;
  oApplException:=Application.OnException; Application.OnException:=ApplException;
  result := ShowModal=mrOk; Application.OnException:=oApplException;
  tmAutoSave.Enabled:=false; DelPrnHead;
  if result then if not Assigned(EdGet) then if whereDtg<>'' then result:=ChangeDat(whereDtg,ao);
  if result then
    if Assigned(pDcmDef) then begin
      GF.SaveCurLeaf; pDcmDef^:=GF.SaveDcmStr;
    end
    else SaveMsg;
  if Assigned(PrmGet) then PrmGet.RVid:='';
  GF.onAutoSize:=nil; GF.ClearAllSelection; GF.onSelectObjs:=nil;
  if not Assigned(EdGet) then begin
	  TDWPrm.VarFree(RDocPrm); TDWPrm.VarFree(RDocpPrm);
  end;
  if not Application.Terminated
  then DelMaskFiles(FullNameExe(FileName,'DCM')+'.'+StringOfChar('?',LenTmpNum)+'.BDC');
  LastEdGenFr:=oEdGenFr; LogFields.Clear;
  DelStack;
end;

procedure TEdGenFr.FormCreate(Sender: TObject);
	procedure RnmRec(r: TRecVal);
  var nmr: string;
  	i,j: longint;
    pv: PGFObj;
    tf: TFldEdit;
    de: TDefEdit;
  begin
    AddStack('TEdGenFr.FormCreate.RnmRec',Self);
    nmr:=TrimUpper(r.NameRec); r.NameRec:=nmr+sWND;
    for i:=0 to ComponentCount-1 do
      if IsClass(Components[i],TFldEdit,pointer(tf)) then begin
        if TrimUpper(tf.NameRec)=nmr then tf.NameRec:=r.NameRec;
      end
      else if IsClass(Components[i],TDefEdit,pointer(de)) then begin
        de.ReplaceNameRec(nmr,r);
        if de.DcmBased then begin
          GF.OpenDcmStr(de.DcmDef);
          for j:=0 to GF.ObjectCount-1 do begin
            pv:=GF.PObjects[j];
            if pv.TypeObj in [toGet,toSay] then
              if AnsiStartsText(nmr+'.',pv.Text)
              then StuffStrSelf(pv.Text,1,Length(nmr),r.NameRec);
          end;
          GF.SaveCurLeaf; de.DcmDef:=GF.SaveDcmStr;
        end;
      end;
    DelStack;
  end;
  procedure MenuInit(g: TMenuGet; const a: array of string; const VName: string; tf: TFldEdit);
  var i: byte;
  begin
  	AddStack('TEdGenFr.FormCreate.MenuInit',Self);
    g.Items.BeginUpdate;
    for i:=low(a) to high(a) do g.Items.Add(IntToStr(i)+UnDelim+a[i]);
    g.Items.EndUpdate;
	  g.VName:=VName; tf.AssignGet(g);
    DelStack;
  end;
var s: string;
  procedure deFontNameWnd(de: TDefEdit);
  begin
    de.NameWnd:=de.NameWnd+s;
  end;
const
  aFill: array[TFillList] of record
    bm: TBMList;
    nm: string;
    repl: boolean;
  end =
  ((bm:bmFill_Top   ; nm:'Линия сверху'; repl:true)
  ,(bm:bmFill_Bottom; nm:'Линия снизу' ; repl:true)
  ,(bm:bmFill_Left  ; nm:'Линия слева' ; repl:true)
  ,(bm:bmFill_Right ; nm:'Линия справа'; repl:true)
  ,(bm:bmFill_Out   ; nm:'Обрамление снаружи')
  ,(bm:bmFill_None  ; nm:'Обрамление отсутствует')
  );
  aFontAlgn: TAlgmStr = ('сверху','в центре','снизу');
var lv: TQRCode_ECCLevel;
  bt: TFillList;
begin
	AddStack('TEdGenFr.FormCreate',Self);
  with FillGet.Buttons do begin
    BeginUpdate; 
    for bt:=low(aFill) to high(aFill) do with aFill[bt] do
      Add(BMPref+aBMName[bm]+UnDelim+nm+IfThen(repl,UnDelim+bTrue));
    EndUpdate;
  end;
  TSimpleGet.CreateOne; TClipboardBuf.ViewerCreate(ClpBrdViewer,Self);
  RGF.CreateFld('PRIM',ftString,GFFontPrimLen,'');
  if Self=EdGenFr then begin
    RDocPrm.Connection:=FirstDatabase; RDocPrm.OpenRec;
    RDocpPrm.Connection:=RDocPrm.Connection; RDocpPrm.OpenRec; s:='';
    MenuInit(VOutGet,aGFVOut,'GFVOut',EVOut);
	  PartGet.VName:='GFPart'; EPart.AssignGet(PartGet);
	  ColGet.VName:='GFCol'; ECol.AssignGet(ColGet);
  end
  else begin
    FreeAndNil(RDocPrm); FreeAndNil(RDocpPrm); FreeAndNil(PrmGet);
    FreeAndNil(SVOut); FreeAndNil(EVOut); FreeAndNil(VOutGet);
    FreeAndNil(SOnly1); FreeAndNil(EOnly1); 
    FreeAndNil(SPart); FreeAndNil(EPart); FreeAndNil(PartGet);
    FreeAndNil(SCol); FreeAndNil(ECol); FreeAndNil(ColGet);
    FreeAndNil(M_Ctrl_4); FreeAndNil(M_Ctrl_5); FreeAndNil(M_Ctrl_6);
    RnmRec(RGF); RnmRec(RGF1); s:=sWND;
    deFontNameWnd(deFont0); deFontNameWnd(deFont1); deFontNameWnd(deFont2);
  end;
  EAlignment.AssignGet(SchemDM.AlgmGet);
  MenuInit(PinGet,aGFPin,'GFPin'+s,EPin);
  TypeGet.VName:='TypeObj'+s; ETypeObj.AssignGet(TypeGet);
  MenuInit(MMetrGet,aGFMMetr,'GFMMetr',EMMetr);
  FontGet.VName:='GFFont'+s; EFont.AssignGet(FontGet); deFontSel.AssignGet('FONTNOM',FontGet);
  TextGet.VName:='GFText'+s; EText.AssignGet(TextGet);
  LnWidthGet.VName:='LnWidth'+s; ELnWidth.AssignGet(LnWidthGet);
  FillGet.VName:='Fill'+s; EVFill.AssignGet(FillGet);
  DivVidGet.VName:='GFDiv'+s; deAdd.AssignGet('DivVid',DivVidGet);
  FontTypeGet.VName:='GFFontType'+s; deFont.AssignGet('AType',FontTypeGet);
  FontLsGet.VName:='GFFont'+s; deFont.AssignGet('',FontLsGet);
  deFont.Param['',deMask]:=ButPrm2Mask('Свойства',Int2Str(low(TSchFontList)));
  FontDopGet.VName:='GFFontDop'+s; deFont.AssignGet('Z',FontDopGet);
  deFontSel.Param['FONTALGN',deMask]:=RadioMask(aFontAlgn,0);
  PrnInit; PFont:=TGFPackFont.Create; TmpList:=TList.Create; GFRefresh:=false; oSelCnt:=0;
  FillLnWidth; LnWidthGet.LenCode:=LenIntStr(MaxLineWidth);
  FontTypeGet.Items.Text:=ArrayAsList(aGFFontType,CRLF);
  with PFont.Prop.Dop do begin
    deFont0.Param['RowBetween',deMask]:=Format('%d,%d',[low(RowBetween),high(RowBetween)]);
    deFont0.Param['PrcSpMin',deMask]:=Format('%d,%d',[low(PrcSpMin),high(PrcSpMin)]);
    deFont1.Param['WidthMm',deMask]:=Format('%d,%d',[low(Width),high(Width)]);
    deFont1.Param['HeightMm',deMask]:=Format('%d,%d',[low(Height),high(Height)]);
    deFont4.Param['ECCLevel',deMask]:=Format('%d,%d',[byte(low(pdf417ECCLevel)),byte(Pred(elEcc_Auto))]);
    deFont4.Param['RowHeight',deMask]:=Format('%d,%d',[low(pdf417RowHeight),high(pdf417RowHeight)]);
  end;
  s:='';
  for lv:=low(aQRCode_ECCLevel) to high(aQRCode_ECCLevel) do with aQRCode_ECCLevel[lv] do
    IncD(s,mniDlm+nm[1]+UnDelim+nm[2]+Format(' (%d%%)',[prc]));
  deFont3.Param['ECCLevel',deMask]:=cMnCod+cMnNoNum+Copy(s,lmniDlm1,MaxInt);
  PnFill.FldReadAll([ferdSvOld]); PnObjUpdate; SearchInfo.NumObj:=-1; CurLeaf:=1;
  tmAutoSave:=TTimerLock.CreateProc(tmAutoSaveTimer,Self);
  RGF['AutoSaveIntv']:=300; RGF.RestFromIni('EdGenFr'); tmAutoSave.Interval:=RGF['AutoSaveIntv']*MSecsPerSec;
  CheckFml:=true;
  with SchemDM.mgDcm do begin
    OnDefCod:=mgDefCod; OnDefNSave:=mgDefNSave; OnHelp:=mgHelp; OnOwnerLoad:=mgOwnerLoad; OnOwnerSave:=mgOwnerSave; OnUsedArr:=mgUsedArr;
  end;
  inherited;
  DelStack;
end;

procedure TEdGenFr.FormDestroy(Sender: TObject);
var a: TArrStr;
begin
	AddStack('TEdGenFr.FormDestroy',Self);
  CopyFrom(a,'AutoSaveIntv'); RGF.SaveToIni(@a,'EdGenFr');
  if Assigned(RDocPrm) then RDocPrm.CloseRec;
  if Assigned(RDocpPrm) then RDocpPrm.CloseRec;
  PFont.Free;
  inherited;
  TmpList.Free; DisposeClpBrd; TClipboardBuf.ViewerFree(ClpBrdViewer,Self);
  DelStack;
end;

procedure TEdGenFr.FormShow(Sender: TObject);
var i,j: longint;
	pv: PGFObj;
begin
	AddStack('TEdGenFr.FormShow',Self);
  inherited;
  FillLnWidth;
  if Assigned(PartGet) then begin
  	PartGet.Items.BeginUpdate; PartGet.Items.Clear; ColGet.Items.BeginUpdate; ColGet.Items.Clear;
    for i:=0 to GF.PageCount-1 do
      for j:=0 to GF.PgObjectCount(i)-1 do begin
        pv:=GF.PgObjects(i,j);
        if not Empty(pv.Part) then PartGet.Items.Add(pv.Part);
        if not Empty(pv.Col) then ColGet.Items.Add(pv.Col);
      end;
    PartGet.Items.EndUpdate; ColGet.Items.EndUpdate;
  end;
  SetSpdBut; ActiveControl:=GF;
  DelStack;
end;

procedure TEdGenFr.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	AddStack('TEdGenFr.FormClose',Self);
  inherited;
  if Modified then AskFormSave(Self,Action);
  if (Action=caHide) and (ModalResult=mrOk) then
  	if not ObjSpace then Action:=caNone;
  DelStack;
end;

procedure TEdGenFr.ApplException;
begin
  if tmAutoSave.Enabled then tmAutoSave.Timer;
  if Assigned(oApplException) then oApplException(Sender,E);
end;

function TEdGenFr.ObjSpace;
var a: TGFObjSpace;
	a1: TArrStr;
  i: longint;
begin
  AddStack('TEdGenFr.ObjSpace',Self);
  result:=not GF.ObjSpace(@a);
  if not result then begin
  	SetLength(a1,Length(a));
    for i:=low(a) to high(a) do with a[i] do
    	a1[i]:=Format('%d-%d; %d-%d',[Top,Bottom,Left,Right]);
  	result:=ListF2Down(ArrayAsList(a1,CRLF),nil,nil,0,'Browl',
    	TKeyLb.GetKeySt(K_F10,'Сохранить'),ObjSpProcKey,0,nil,nil,nil,nil,nil,
      'Обнаружены пустоты: (сверху-снизу; слева-справа)',false);
  end;
  DelStack;
end;

procedure TEdGenFr.ObjSpProcKey;
begin
  AddStack('TEdGenFr.ObjSpProcKey',Self);
  SetModalResult(mrOk);
  DelStack;
end;

// Заполнение меню толщины линии
procedure TEdGenFr.FillLnWidth;
var i: longint;
	s: string;
  w: TLineWidth;
begin
	AddStack('TEdGenFr.FillLnWidth',Self);
  w:=low(w);
  with GF.Params do for i:=low(Arr) to high(Arr) do
  	w:=max(w,EnsureRange(Arr[i].GridLineWidth,low(w),high(w)));
  with LnWidthGet.Items do
  	if Count<>w+1 then begin
      s:='';
      for i:=0 to w do s:=StrNum(s+CRLF,i)+UnDelim;
      Text:=Copy(s,lCRLF1,MaxInt);
    end;
  DelStack;
end;

// Отметка ячеек
procedure TEdGenFr.GFSelectGrid(Sender: TObject);
begin
	AddStack('TEdGenFr.GFSelectGrid',Self);
  inherited;
  with KeyLb1 do begin
  	PnFill.Enabled := not GF.Selected;
    M_F7.Visible:=GF.Selected; M_R2.Visible:=GF.Selected;
    if GF.Selected then SetKey(K_F7,'Добавить','Добавить объект',GrSelProc,'GrSel',kmGFObj)
    else DelKey(K_All,'GrSel');
    ClpBrdCanCopyPast; ReDrw;
  end;
  DelStack;
end;

// Добавление объекта
procedure TEdGenFr.GrSelProc;
var v: TGFObj;
begin
	AddStack('TEdGenFr.GrSelProc',Self);
  with GF.RectSel do begin
  	GF.ClearSelection([vsGrid]);
    GFObjDef(v);
  	v.Left:=Left-1; v.Top:=Top-1; v.Right:=Right; v.Bottom:=Bottom;
    v.Selected:=true; GF.AddObj(v); Modified:=true; //PnObj.SetFocus;
  end;
  DelStack;
end;

// Область объектов прямоугольная или нет
procedure RectObjFillInit(var aFill: TArrStr; const r: TRect);
var y,lx: Word;
begin
  AddStack('FEdGenFr.RectObjFillInit');
  SetLength(aFill,r.Bottom-r.Top); lx:=r.Right-r.Left;
  for y:=low(aFill) to high(aFill) do aFill[y]:=StringOfChar('1',lx);
  DelStack;
end;

procedure RectObjFillCalc(var aFill: TArrStr; const r: TRect; const v: TGFObj);
var y,px,lx: Word;
begin
  AddStack('FEdGenFr.RectObjFillCalc');
  px:=v.Left-r.Left; lx:=v.Right-v.Left;
  for y:=v.Top-r.Top to v.Bottom-1-r.Top do ZeroMemory(PointerStr(aFill[y],px),lx);
  DelStack;
end;

function RectObjFillRectangle(const aFill: TArrStr): boolean;
var y: Word;
begin
  AddStack('FEdGenFr.RectObjFillRectangle');
  result:=true;
  for y:=low(aFill) to high(aFill) do
    if not empty(aFill[y]) then begin
      result:=false; break;
    end;
  DelStack;
end;

// Обновление панели редактирования свойств объектов
procedure TEdGenFr.PnObjUpdate;
  procedure SetEdProp(fl: boolean; const nmFld: string;
    const Value: variant; SFld,EFld: TFldEdit);
  label lend;
  begin
    AddStack('TEdGenFr.PnObjUpdate.SetEdProp',Self);
    if not Assigned(SFld) then goto lend;
    if not All then
      if RGF1[nmFld]=fl then goto lend;
    RGF1[nmFld]:=fl; AndD(fl,GF.SelObjectCount<>0); SFld.SetReadOnly(fl); EFld.SetReadOnly(not fl);
    SFld.Mask:=StrTran(SFld.Mask,cBoolSay)+IfThen(fl or (GF.SelObjectCount=0),cBoolSay);
    if nmFld='Text' then TextObj:=Value else RGF[nmFld]:=Value;
    TFldEdit.Read([ferdSvOld],[SFld,EFld]);
  lend:
    DelStack;
  end;
var fl: boolean;
  procedure IsEqual(var flEq: boolean; usl: boolean);
  begin
  	AddStack('TEdGenFr.PnObjUpdate.IsEqual',Self);
    if flEq and usl then flEq:=false;
    DelStack;
  end;
  function UslAllUpd(SFld: TFldEdit): boolean;
  begin
  	AddStack('TEdGenFr.PnObjUpdate.UslAllUpd',Self);
    result:=false;
    if Assigned(SFld) then
	    if All or (ogReadOnly in SFld.Options) then result:=fl;
    DelStack;
  end;
var i: longint;
	v,v1: TGFObj;
  lLeft,lTop,lRight,lBottom,lTypeObj,lText,lAlignment,lMinWidth,
  	lMinHeight,lPin,lColor,lFont,lPart,lCol,lMMetr,lVOut,lOnly1,lIdent: boolean;
	ac: TWinControl;
  scX,scY: longint;
begin
	AddStack('TEdGenFr.PnObjUpdate',Self);
  SetRedraw(KeyLb1);
	fl := GF.SelObjectCount<>0;
  if fl then v1:=GF.SelObjects[0] else GFObjDef(v1);
  lLeft     :=UslAllUpd(SLeft);
  lTop      :=UslAllUpd(STop);
  lRight    :=UslAllUpd(SRight);
  lBottom   :=UslAllUpd(SBottom);
  lTypeObj  :=UslAllUpd(STypeObj);
  lText     :=UslAllUpd(SText);
  lAlignment:=UslAllUpd(SAlignment);
  lMinWidth :=UslAllUpd(SMinWidth);
  lMinHeight:=UslAllUpd(SMinHeight);
  lPin      :=UslAllUpd(SPin);
  lColor    :=UslAllUpd(SOColor);
  lFont     :=UslAllUpd(SFont);
  lPart     :=UslAllUpd(SPart);
  lCol      :=UslAllUpd(SCol);
  lMMetr    :=UslAllUpd(SMMetr);
  lVOut     :=UslAllUpd(SVOut);
  lOnly1    :=UslAllUpd(SOnly1);
  lIdent    :=UslAllUpd(SIdent);
  for i:=IfThen(not All,GF.SelObjectCount-1) to GF.SelObjectCount-1 do begin
  	v:=GF.SelObjects[i];
    IsEqual(lLeft     ,v.Left     <>v1.Left);
    IsEqual(lTop      ,v.Top      <>v1.Top);
    IsEqual(lRight    ,v.Right    <>v1.Right);
    IsEqual(lBottom   ,v.Bottom   <>v1.Bottom);
    IsEqual(lTypeObj  ,v.TypeObj  <>v1.TypeObj);
    IsEqual(lText     ,v.Text     <>v1.Text);
    IsEqual(lAlignment,v.Alignment<>v1.Alignment);
    IsEqual(lMinWidth ,v.MinWidth <>v1.MinWidth);
    IsEqual(lMinHeight,v.MinHeight<>v1.MinHeight);
    IsEqual(lPin      ,v.Pin      <>v1.Pin);
    IsEqual(lColor    ,v.Color    <>v1.Color);
    IsEqual(lFont     ,v.Font     <>v1.Font);
    IsEqual(lPart     ,v.Part     <>v1.Part);
    IsEqual(lCol      ,v.Col      <>v1.Col);
    IsEqual(lMMetr    ,v.MMetr    <>v1.MMetr);
    IsEqual(lVOut     ,v.VOut     <>v1.VOut);
    IsEqual(lOnly1    ,v.Only1    <>v1.Only1);
    IsEqual(lIdent    ,v.Ident    <>v1.Ident);
  end;
	ac:=ActiveControl;
  scX:=ScrlGF.HorzScrollBar.Position;
  scY:=ScrlGF.VertScrollBar.Position;
  SetEdProp(lLeft     ,'Left'     ,v1.Left          ,SLeft     ,ELeft);
  SetEdProp(lTop      ,'Top'      ,v1.Top           ,STop      ,ETop);
  SetEdProp(lRight    ,'Right'    ,v1.Right         ,SRight    ,ERight);
  SetEdProp(lBottom   ,'Bottom'   ,v1.Bottom        ,SBottom   ,EBottom);
  SetEdProp(lTypeObj  ,'TypeObj'  ,v1.TypeObj       ,STypeObj  ,ETypeObj);
  SetEdProp(lText     ,'Text'     ,TextCRLF(v1.Text),SText     ,EText);
  SetEdProp(lAlignment,'Alignment',v1.Alignment     ,SAlignment,EAlignment);
  SetEdProp(lMinWidth ,'MinWidth' ,v1.MinWidth      ,SMinWidth ,EMinWidth);
  SetEdProp(lMinHeight,'MinHeight',v1.MinHeight     ,SMinHeight,EMinHeight);
  SetEdProp(lPin      ,'Pin'      ,v1.Pin           ,SPin      ,EPin);
  SetEdProp(lColor    ,'OColor'   ,v1.Color         ,SOColor   ,EOColor);
  SetEdProp(lFont     ,'Font'     ,v1.Font          ,SFont     ,EFont);
  SetEdProp(lPart     ,'Part'     ,v1.Part          ,SPart     ,EPart);
  SetEdProp(lCol      ,'Col'      ,v1.Col           ,SCol      ,ECol);
  SetEdProp(lMMetr    ,'MMetr'    ,byte(v1.MMetr)   ,SMMetr    ,EMMetr);
  SetEdProp(lVOut     ,'VOut'     ,v1.VOut          ,SVOut     ,EVOut);
  SetEdProp(lOnly1    ,'Only1'    ,v1.Only1         ,SOnly1    ,EOnly1);
  SetEdProp(lIdent    ,'Ident'    ,v1.Ident         ,SIdent    ,EIdent);
  ScrlGF.HorzScrollBar.Position:=scX;
  ScrlGF.VertScrollBar.Position:=scY;
  ActiveControl:=ac;
  SetRedraw(KeyLb1,rdrwSet);
  DelStack;
end;

// Редактирование/удаление/обрамление объекта
procedure TEdGenFr.ObjSelProc;
var v: TGFObj;
  pv: PGFObj;
  t,i,c,r: longint;
  fl: boolean;
  sb: TClipboardBufObj;
  rSel: TRect;
begin
	AddStack('TEdGenFr.ObjSelProc',Self);
	case Key of
  	K_F2: PnFill.SetFocus;
    K_F8: if GF.DelSelObj then Modified:=true;
    K_Enter: if GF.SelObjectCount=1 then begin
      TextGetClick(nil,true); v:=GF.SelObjects[0];
      if v.TypeObj=toText
      then fl := TextCRLF(v.Text)<>TextCRLF(TextObj)
      else fl := TrimRight(v.Text)<>TrimRight(TextObj);
      if fl then begin
        v.Text:=TextObj; GF.SelObjects[0]:=v; PnObjUpdate(false); GF.AutoSize; Modified:=true;
      end;
    end
    else Key:=K_F5;
    K_Ctrl_C,K_Ctrl_X: if GF.SelObjectCount>0 then begin
      if not Assigned(PClpBrd) then New(PClpBrd);
      with PClpBrd^ do begin
        SetLength(aObj,GF.SelObjectCount); c:=0;
        for i:=GF.ObjectCount-1 downto 0 do
          if GF.PFillObj(i).Selected then begin
            aObj[c]:=GF.PFillObj(i)^; Inc(c);
          end;
        sb:=TClipboardBufObj.CreateWrite(cbrdGFObj,ClpBrdLastVers);
        try
          sb.Write(lDefFont,stInteger); sb.Write(lGFPackFontProp,stInteger);
          sb.Write(c,stInteger);
          if c=0 then aFont:=nil
          else begin
            for i:=low(aObj) to high(aObj) do with aObj[i] do begin
              sb.Write(Left,stWord); sb.Write(Top,stWord);
              sb.Write(Right,stWord); sb.Write(Bottom,stWord);
              sb.Write(MinWidth,stWord); sb.Write(MinHeight,stWord);
              sb.Write(LnLeft,stByte); sb.Write(LnTop,stByte);
              sb.Write(LnRight,stByte); sb.Write(LnBottom,stByte);
              sb.Write(TypeObj,stByte); sb.Write(Alignment,stByte); sb.Write(Pin,stByte);
              sb.Write(Color,stByte); sb.Write(Font,stByte); sb.Write(VOut,stByte); sb.Write(Only1,stBoolean);
              sb.WriteStr(Text); sb.WriteStr(Part); sb.WriteStr(Col); sb.Write(MMetr,stBoolean);
              sb.WriteStr(Ident);
            end;
            c:=GF.FontCount; sb.Write(c,stByte); SetLength(aFont,c);
            for i:=0 to c-1 do with GF.Fonts[i] do begin
              FontToDefFont(Font,aFont[i].Font); aFont[i].Prop:=Prop;
              sb.WriteString(FontToStr(Font)); sb.WriteString(GFPackFontPropToStr(Prop));
            end;
          end;
        finally
          sb.Free;
        end;
      end;
      if Key=K_Ctrl_X then KeyLb1.ExecKey(K_F8);
    end;
    K_Ctrl_V:
      if GF.Selected or (GF.SelObjectCount>0) then begin
        SetRedraw(GF);
        if GF.Selected then begin
          rSel:=GF.RectSel; Dec(rSel.Left); Dec(rSel.Top);
        end
        else begin
          rSel:=rSO; GF.DelSelObj(false);
        end;
        with PClpBrd^ do begin
          c:=rObj.Right-rObj.Left-(rSel.Right-rSel.Left);
          if c>0 then begin
            GF.IncColCount(c);
            for i:=0 to GF.ObjectCount-1 do begin
              pv:=GF.PObjects[i];
              if pv.Left>=rSel.Right then Inc(pv.Left,c);
              if pv.Right>=rSel.Right then Inc(pv.Right,c);
            end;
            Inc(rSel.Right,c);
          end;
          r:=rObj.Bottom-rObj.Top-(rSel.Bottom-rSel.Top);
          if r>0 then begin
            GF.IncRowCount(r);
            for i:=0 to GF.ObjectCount-1 do begin
              pv:=GF.PObjects[i];
              if pv.Top>=rSel.Bottom then Inc(pv.Top,r);
              if pv.Bottom>=rSel.Bottom then Inc(pv.Bottom,r);
            end;
            Inc(rSel.Bottom,r);
          end;
          TmpList.Clear;
          for i:=low(aObj) to high(aObj) do begin
            v:=aObj[i];
            c:=rSel.Left-rObj.Left; Inc(v.Left,c);
            if v.Right=rObj.Right then v.Right:=rSel.Right else Inc(v.Right,c);
            r:=rSel.Top-rObj.Top; Inc(v.Top,r);
            if v.Bottom=rObj.Bottom then v.Bottom:=rSel.Bottom else Inc(v.Bottom,r);
            v.Selected:=false; SetClpBrdFont(@v); TmpList.Add(GF.AddObj(v));
          end;
          GF.OnSelectObjs:=nil; GF.SelectObjs(TmpList,true); GFSelectObjs(GF,TmpList,true);
          TmpList.Clear; GF.onSelectObjs:=GFSelectObjs;
        end;
        SetRedraw(GF,rdrwNoPaint); GF.AutoSize;
        Modified:=true;
      end
      else begin
        Key:=K_1;
        if mnInsObj.Execute(@Key) then begin
          SetRedraw(GF); c:=GF.ColCount; r:=GF.RowCount;
          with PClpBrd^ do begin
            if key in [K_1,K_3] then begin
              GF.ColCount:=max(c,rObj.Right-rObj.Left); t:=r; GF.RowCount:=t+rObj.Bottom-rObj.Top;
              if GF.ColCount>c then for i:=0 to GF.ObjectCount-1 do begin
                pv:=GF.PObjects[i];
                if pv.Right=c then pv.Right:=GF.ColCount;
              end;
            end
            else begin
              GF.RowCount:=max(r,rObj.Bottom-rObj.Top); t:=c; GF.ColCount:=t+rObj.Right-rObj.Left;
              if GF.RowCount>r then for i:=0 to GF.ObjectCount-1 do begin
                pv:=GF.PObjects[i];
                if pv.Bottom=r then pv.Bottom:=GF.RowCount;
              end;
            end;
            if key in [K_3,K_4] then begin
              t:=IfThen(key=K_3,GF.RowCount,GF.ColCount)-t;
              for i:=0 to GF.ObjectCount-1 do begin
                pv:=GF.PObjects[i];
                if key=K_3 then begin
                  Inc(pv.Top,t); Inc(pv.Bottom,t);
                end
                else begin
                  Inc(pv.Left,t); Inc(pv.Right,t);
                end;
              end;
            end;
            TmpList.Clear;
            t:=IfThen(key in [K_1,K_3],rObj.Top-IfThen(key=K_1,t),rObj.Left-IfThen(key=K_2,t));
            for i:=low(aObj) to high(aObj) do begin
              v:=aObj[i];
              if key in [K_1,K_3] then begin
                Dec(v.Top,t); Dec(v.Bottom,t);
              end
              else begin
                Dec(v.Left,t); Dec(v.Right,t);
              end;
              v.Selected:=false; SetClpBrdFont(@v); TmpList.Add(GF.AddObj(v));
            end;
            GF.OnSelectObjs:=nil; GF.SelectObjs(TmpList,true); GFSelectObjs(GF,TmpList,true);
            TmpList.Clear; GF.onSelectObjs:=GFSelectObjs;
          end;
          SetRedraw(GF,rdrwNoPaint); Modified:=true; GF.AutoSize;
        end;
      end;
  end;
  if Key=K_F5 then PnObj.SetFocus;
  DelStack;
end;

procedure TEdGenFr.ClpBrdCanCopyPast;
var result: boolean;
begin
  AddStack('TEdGenFr.ClpBrdCanCopyPast',Self);
  result := GF.SelObjectCount>0; M_Ctrl_X.Enabled:=result; M_Ctrl_C.Enabled:=result;
  with KeyLb1 do if result then begin
  	SetKey(K_Ctrl_X,'','Вырезать',ObjSelProc,'ClpBrdGFObj',kmGFObj);
  	SetKey(K_Ctrl_C,'','Скопировать',ObjSelProc,'ClpBrdGFObj',kmGFObj);
  end
  else begin
    DelKey(K_Ctrl_X,'ClpBrdGFObj'); DelKey(K_Ctrl_C,'ClpBrdGFObj');
  end;
  ClpBrdCanPast; 
  DelStack;
end;

procedure TEdGenFr.ClpBrdCanPast;
var result: boolean;
  sb: TClipboardBufObj;
  ost,l: longint;
  aFill: TArrStr;
begin
  ost:=AddStack('TEdGenFr.ClpBrdCanPast',Self);
  result:=false; sb:=TClipboardBufObj.CreateRead;
  try
    try
      if sb.Active then begin
        l:=sb.Read(stInteger);
        if l>0 then begin
          if not Assigned(PClpBrd) then New(PClpBrd);
          with PClpBrd^ do begin
            SetLength(aObj,l); TGenForm.RectObjInit(rObj);
            for l:=low(aObj) to high(aObj) do with aObj[l] do begin
              Left:=sb.Read(stWord); Top:=sb.Read(stWord);
              Right:=sb.Read(stWord); Bottom:=sb.Read(stWord);
              MinWidth:=sb.Read(stWord); MinHeight:=sb.Read(stWord);
              LnLeft:=sb.Read(stByte); LnTop:=sb.Read(stByte);
              LnRight:=sb.Read(stByte); LnBottom:=sb.Read(stByte);
              TypeObj:=sb.Read(stByte); Alignment:=sb.Read(stByte); Pin:=sb.Read(stByte);
              Color:=sb.Read(stByte); Font:=sb.Read(stByte); VOut:=sb.Read(stByte);
              Only1:=sb.Read(sb.Vers>=4,stBoolean,false);
              Text:=sb.ReadStr; Part:=sb.ReadStr; Col:=sb.ReadStr; MMetr:=sb.Read(stBoolean);
              Ident:=sb.ReadStr;
              TGenForm.RectObjCalc(rObj,aObj[l]);
            end;
            if sb.Vers<3 then begin
              sb.Read(stInteger); sb.Read(stInteger); sb.Read(stInteger); sb.Read(stInteger);
            end;
            l:=sb.Read(stByte); SetLength(aFont,l);
            for l:=low(aFont) to high(aFont) do begin
              aFont[l].Font:=StrToDefFont(sb.ReadStr(lDefFont));
              aFont[l].Prop:=StrToGFPackFontProp(sb.ReadStr(lGFPackFontProp));
            end;
            result:=true;
            if GF.Selected or (GF.SelObjectCount>0) then begin
              if not GF.Selected then result := M_Ctrl_F7.Visible or (GF.SelObjectCount=1);
              if result then begin
                RectObjFillInit(aFill,rObj);
                for l:=low(aObj) to high(aObj) do RectObjFillCalc(aFill,rObj,aObj[l]);
                result:=RectObjFillRectangle(aFill);
              end;
            end;
          end;
        end;
      end;
    except
      SetStack(ost);
      result:=false;
    end;
  finally
    sb.Free;
  end;
  M_Ctrl_V.Enabled:=result;
  if result then KeyLb1.SetKey(K_Ctrl_V,'','Вставить',ObjSelProc,'ClpBrdGFObj',kmGFObj)
  else begin
    KeyLb1.DelKey(K_Ctrl_V,'ClpBrdGFObj'); DisposeClpBrd;
  end;
  DelStack;
end;

procedure TEdGenFr.PnObjBeforeEnter(Sender: TObject);
begin
	AddStack('TEdGenFr.PnObjBeforeEnter',Self);
  inherited;
  KeyMenu1.DelLine(kmGFObj,K_F7); KeyLb1.SetButNoEval(true); KeyLb1.ReDrw;
  DelStack;
end;

procedure TEdGenFr.PnObjEnter(Sender: TObject);
var i: longint;
begin
	AddStack('TEdGenFr.PnObjEnter',Self);
  inherited;
  GFRefresh:=true; oTextObj:=GF.SelObjects[0].Text; i:=GF.SelObjectCount;
  if Length(aoObj)<i then SetLength(aoObj,i);
  for i:=0 to i-1 do aoObj[i]:=GF.SelObjects[i];
	EnblFill:=PnFill.Enabled; PnFill.Enabled:=false;
  DelStack;
end;

procedure TEdGenFr.PnObjBeforeExit(Sender: TObject);
begin
	AddStack('TEdGenFr.PnObjBeforeExit',Self);
  inherited;
  GFRefresh:=false;
  DelStack;
end;

procedure TEdGenFr.PnObjExit(Sender: TObject);
begin
	AddStack('TEdGenFr.PnObjExit',Self);
  inherited;
	PnObjUpdate;
  KeyLb1.SetButNoEval(false); KeyLb1.ReDrw;
  KeyMenu1.InsLine(kmGFObj,K_F7);
  PnFill.Enabled:=EnblFill;
  DelStack;
end;

function TEdGenFr.PnObjValid(Sender: TObject): Boolean;
begin
	AddStack('TEdGenFr.PnObjValid',Self);
  inherited;
  if RGF1['Part'] then PartGet.Items.Add(TrimRight(RGF['Part']));
  if RGF1['Col'] then ColGet.Items.Add(TrimRight(RGF['Col']));
  GF.AutoSize; Modified:=true; result:=true;
  DelStack;
end;

procedure TEdGenFr.PnObjEscape(Sender: TObject; var Action: TCloseAction);
var i: longint;
begin
	AddStack('TEdGenFr.PnObjEscape',Self);
  inherited;
  GFRefresh:=false; TextObj:=oTextObj;
  for i:=0 to GF.SelObjectCount-1 do GF.SelObjects[i]:=aoObj[i];
  GF.PaintAll; 
  DelStack;
end;

// Разрешить/запретить редактировать общие свойства объектов
procedure TEdGenFr.SLeftExit(Sender: TObject);
var tf: TFldEdit;
begin
	AddStack('TEdGenFr.SLeftExit',Self);
  inherited;
  tf:=pointer(Sender);
  if tf.VarValue then begin
    tf.SetReadOnly(true); tf.Mask:=StrTran(tf.Mask,cBoolSay)+cBoolSay;
  end;
  DelStack;
end;

// Изменить Hint (текст/формула/рисунок)
procedure TEdGenFr.ETypeObjChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
const
  a: array[TGFTypeObjList] of record
    sHint,gHint: string;
    OnlyMm: boolean;
  end =
    ((sHint:'текст')
    ,(sHint:'формулу')
    ,(sHint:'имя файла рисунка'    ; gHint:'Имя файла рисунка'; OnlyMm:true)
    ,(sHint:'формулу')
    ,(sHint:'имя вводимого данного')
    ,(sHint:'имя вводимого данного')
    ,(sHint:'имя файла рисунка'    ; gHint:'Имя файла рисунка'; OnlyMm:true)
    );
var s: string;
begin
	AddStack('TEdGenFr.ETypeObjChange',Self);
  inherited;
  with a[TGFTypeObjList(RGF['TypeObj'])] do begin
    SText.Hint:='Редактировать '+sHint;
    EText.Hint:=gHint; EText.ShowHint := gHint<>'';
    if OnlyMm then begin
      EMinWidth.Hint:='Ширина в миллиметрах';
      EMinHeight.Hint:='Высота в миллиметрах';
    end
    else begin
      s:=IfThen(RGF['MMetr'],'миллиметрах','символах');
      EMinWidth.Hint:='Минимальная ширина в '+s;
      EMinHeight.Hint:='Минимальная высота в '+s;
    end;
  end;
  EText.Read; ELeftChange(Sender,OldVal,FromShow);
  DelStack;
end;

// Изменение свойств объектов при редактировании
procedure TEdGenFr.ELeftChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
	function GetEdProp(const nmFld: string; const Default: variant): variant;
  begin
    AddStack('TEdGenFr.ELeftChange.GetEdProp',Self);
    if RGF1[nmFld] then
      if nmFld='Text' then result:=TextObj else result:=RGF[nmFld]
    else result:=Default;
    DelStack;
  end;
  // Проверка границ
  function NoValidPlace(const nm1,nm2: string): boolean;
  var lr: boolean;
    i: longint;
    v: TGFObj;
  label lend;
  begin
    AddStack('TEdGenFr.ELeftChange.NoValidPlace',Self);
    result:=true; lr := UpperCase(nm1)='LEFT';
    for i:=0 to GF.SelObjectCount-1 do begin
      v:=GF.SelObjects[i];
      if GetEdProp(nm1,IfThen(lr,v.Left,v.Top))
      >= GetEdProp(nm2,IfThen(lr,v.Right,v.Bottom)) then goto lend;
    end;
    result:=false;
  lend:
    DelStack;
  end;
var i,j,j1: longint;
  v,v1: TGFObj;
  r,r1: TRect;
  tf: TFldEdit;
label lend;
begin
	AddStack('TEdGenFr.ELeftChange',Self);
  inherited;
  tf:=pointer(Sender);
  if Assigned(tf.FocusControl) then TFldEdit(tf.FocusControl).SetReadOnly(not tf.VarValue);
  if not GFRefresh then goto lend;
  if (tf.Name[1]='S') and not StrToBoolean(tf) then goto lend;
  if (tf=ELeft) or (tf=ERight) or (tf=ETop) or (tf=EBottom)
  or (tf=SLeft) or (tf=SRight) or (tf=STop) or (tf=SBottom)
  then begin
    // Левая и правая границы
    if NoValidPlace('Left','Right') then goto lend;
    // Верхняя и нижняя границы
    if NoValidPlace('Top','Bottom') then goto lend;
    // Пересечение с объектами
    for i:=0 to GF.SelObjectCount-1 do begin
      v1:=GF.SelObjects[i]; j1:=GF.NumSelObj(i);
      r1:=Rect(
        GetEdProp('Left',v1.Left)+1,
        GetEdProp('Top',v1.Top)+1,
        GetEdProp('Right',v1.Right),
        GetEdProp('Bottom',v1.Bottom));
      for j:=0 to GF.ObjectCount-1 do begin
        v:=GF.Objects[j];
        if j=j1 then continue;
        if v.Selected
        then r:=Rect(
          GetEdProp('Left',v.Left),
          GetEdProp('Top',v.Top),
          GetEdProp('Right',v.Right),
          GetEdProp('Bottom',v.Bottom))
        else r:=Rect(v.Left,v.Top,v.Right,v.Bottom);
        Inc(r.Left); Inc(r.Top);
        if win2comp(r,r1) then goto lend;
      end;
    end;
  end;
  // Всё правильно - записать
	for i:=0 to GF.SelObjectCount-1 do begin
  	v:=GF.SelObjects[i];
    v.Left     :=GetEdProp('Left'     ,v.Left);
    v.Top      :=GetEdProp('Top'      ,v.Top);
    v.Right    :=GetEdProp('Right'    ,v.Right);
    v.Bottom   :=GetEdProp('Bottom'   ,v.Bottom);
    v.TypeObj  :=GetEdProp('TypeObj'  ,v.TypeObj);
    v.Text     :=GetEdProp('Text'     ,v.Text);
    v.Alignment:=GetEdProp('Alignment',v.Alignment);
    v.MinWidth :=GetEdProp('MinWidth' ,v.MinWidth);
    v.MinHeight:=GetEdProp('MinHeight',v.MinHeight);
    v.Pin      :=GetEdProp('Pin'      ,v.Pin);
    v.Color    :=GetEdProp('OColor'   ,v.Color);
    v.Font     :=GetEdProp('Font'     ,v.Font);
    v.Part     :=TrimRight(GetEdProp('Part',v.Part));
    v.Col      :=TrimRight(GetEdProp('Col',v.Col));
    v.MMetr    :=boolean(GetEdProp('MMetr',byte(v.MMetr)));
    v.VOut     :=GetEdProp('VOut'     ,v.VOut);
    v.Only1    :=GetEdProp('Only1'    ,v.Only1);
    v.Ident    :=TrimRight(GetEdProp('Ident',v.Ident));
    GF.SelObjects[i]:=v;
  end;
  GF.PaintAll;
lend:
	DelStack;
end;

procedure TEdGenFr.ELeftAfterExit(Sender: TObject);
begin
	AddStack('TEdGenFr.ELeftAfterExit',Self);
  inherited;
  PnObjUpdate;
  DelStack;
end;

procedure TEdGenFr.EAlignmentMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X,Y: longint);
begin
	AddStack('TEdGenFr.EAlignmentMouseDown',Self);
  if not AlignmentMouseDown then begin
    AlignmentMouseDown:=true; oGFRefresh:=GFRefresh; GFRefresh:=true;
  end;
  DelStack;
end;

procedure TEdGenFr.EAlignmentMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: longint);
begin
  AddStack('TEdGenFr.EAlignmentMouseUp',Self);
  if AlignmentMouseDown then begin
    GFRefresh:=oGFRefresh; AlignmentMouseDown:=false;
  end;
  DelStack;
end;

// Меню "Прижать"
const
	pinBord  = 1;
	pinBord2 = pinBord shl 1;

procedure TEdGenFr.PinGetSizePaint(Sender: TObject; tf: TFldEdit;
  isList: Boolean; var Size: tagSIZE);
var ts: TSchem;
	bm: TBitMap;
begin
	AddStack('TEdGenFr.PinGetSizePaint',Self);
  with tf.Canvas do begin
    if SchemName(tf.Schem,ts) then Font.Assign(ts.Font1) else DefaultFont(Font);
    if isList then Size.cX:=CanvasMaxW(tf.Canvas)*PinGet.MaxSymb
    else begin
      InitBM.FindBM(bmGF_Top_Left,bm);
      Size.cX:=bm.Width+pinBord2;
      MaxSelf(Size.cY,bm.Height+pinBord2);
    end;
  end;
  DelStack;
end;

procedure TEdGenFr.PinGetDrawItem(Sender: TObject; Canvas: TCanvas;
  const nRect: TRect; Index: longint; State: TOwnerDrawState; tf: TFldEdit;
  const Cod: String; isList: Boolean);
const
  a: array[boolean,boolean] of TBMList =
    ((bmGF_Top_Left,bmGF_Top_Right)
    ,(bmGF_Bot_Left,bmGF_Bot_Right)
    );
var n: TGFPinList;
	i: longint;
	bm: TBitMap;
begin
	AddStack('TEdGenFr.PinGetDrawItem',Self);
  with Canvas do begin
    Font.Assign(tf.Font);
    if odSelected in State then begin
      Brush.Color:=clHighLight; Font.Color:=clHighLightText;
    end
    else Brush.Color:=tf.Color1;
  	FillRect(nRect);
    if not(ogReadOnly in tf.Options) then begin
    	if isList then TextRect(nRect,nRect.Left+2,nRect.Top,TrimRight(PinGet.MenuName(Cod)))
      else begin
				n:=TGFPinList(Int0(Cod));
        InitBM.FindBM(a[PinBottom(n),PinRight(n)],bm);
        i:=(nRect.Bottom-nRect.Top-bm.Height-pinBord2-1) div 2;
        BrushCopy(Rect(nRect.Left+pinBord,nRect.Top+i+pinBord,
	        nRect.Left+pinBord+bm.Width,
	        nRect.Top+i+pinBord+bm.Height),
          bm,Rect(0,0,bm.Width,bm.Height),
          clOlive);
      end;
    end;
  end;
  DelStack;
end;

// Список макроподстановок
procedure TEdGenFr.ProcKeyEdObj;
const aFontAlgn: array[TAlignment] of TAlignment = (taLeftJustify,taCenter,taRightJustify);
var ar: TITArr;
  ozn,czn: string;
  i,j: longint;
  m: TGFMacro;
begin
	AddStack('TEdGenFr.ProcKeyEdObj',Self);
  with TCustomEdMemo(tw.Owner) do begin
  	czn:=''; TInterMemo.IdentInPos(ozn,Lines[CurrentLineNumber],CurrentCol,GFChrMac,false,@i);
    case Key of
      K_F7: begin
        j:=0; SetLength(ar,Length(aGFMacro));
        for m:=low(aGFMacro) to high(aGFMacro) do with aGFMacro[m] do begin
          if (tp=gfmcEval) and (RGF['TypeObj']<>toForm) then continue;
          ar[j].name:=GFMacroCod(m); ar[j].hlp:=0; ar[j].prim:=nm; Inc(j);
        end;
        czn:=TIntTree.Execute('Список макроподстановок','Macro',ozn,ar,j,[itreNoSubItems]);
      end;
      K_F8: czn:=TGFBmp.Execute(GF.lsBitMap,nil,[gfbmpSel],ozn,'','',PrModify);
      K_Ctrl_B: begin
        if SelLength>0 then ozn:=SelText;
        RGF['FONTNOM']:=FontGet.SeekCurCod(EFont); RGF['FONTALGN']:=high(aFontAlgn); oldInd:=-1;
        if deFontSel.Execute('Выделение строки "'+ozn+'" другим шрифтом').Saved then begin
          if SelLength=0 then begin
            for j:=0 to CurrentLineNumber-1 do Inc(i,Length(Lines[j])+lCRLF);
            Dec(i);
          end
          else i:=SelStart+SelLength;
          j:=Length(ozn); SetSelection(i-j,j);
          InsText(Format('%s%d.%d%s%s%s',
            [GFMacroCod(gfmcFONT),longint(RGF['FONTNOM']),byte(aFontAlgn[TAlignment(RGF['FONTALGN'])]),
            GFMacroCod(gfmcEND),ozn,GFMacroCod(gfmcEND)]));
        end;
      end;
    end;
    if czn<>'' then begin
      if AnsiStartsText(ozn,czn) then begin
        for j:=0 to CurrentLineNumber-1 do Inc(i,Length(Lines[j])+lCRLF);
        j:=Length(ozn); SetSelection(i-j-1,j);
      end;
    	InsText(czn);
    end;
	end;
  DelStack;
end;

procedure TEdGenFr.PrModify;
begin
  AddStack('TEdGenFr.PrModify');
  Modified:=true;
  DelStack;
end;

// Редактирование содержимого объекта
function TEdGenFr.TextGetClick(Sender: TObject; lEval: Boolean): String;
var oldt,Capt: string;
  fl: boolean;
  MinWidth: longint;
begin
	AddStack('TEdGenFr.TextGetClick',Self);
  inherited;
	if lEval then begin
		result:=TextObj; oldt:=result;
    if (TGFTypeObjList(RGF['TypeObj']) in [toGet,toSay]) and Assigned(prEdGet) then begin
      if Assigned(Sender) then begin
        MinWidth:=TWinControl(Sender).Width; Capt:='';
      end
      else begin
        MinWidth:=0; Capt:='Вводимые поля';
      end;
    	fl:=prEdGet(pointer(Sender),MinWidth,Capt,result);
    end
    else begin
      fl := RGF['TypeObj']=toText; AddPrnHead(IfThen(fl,'Текст','Формула')+' объекта');
      if not fl then RDBDef;
      if SearchInfo.NumObj>=0 then EdTextInitFind:=true;
      fl:=EdTextExec('Редактирование '+IfThen(fl,'текста','формулы'),result,
        TKeyLb.GetKeySt(K_F7,'Макро','Список макроподстановок',kmEdit)
        +IfThen(TGFTypeObjList(RGF['TypeObj']) in [toBmp,toCalcBmp],CRLF+TKeyLb.GetKeySt(K_F8,'Рисунки','Список рисунков',kmEdit))
        +CRLF+TKeyLb.GetKeySt(K_Ctrl_B,'Выделить','Выделить часть текста другим шрифтом',kmEdit),
        ProcKeyEdObj,IfThen(not CheckFml,edtxtNoChkFml),iif(fl,edtpText,edtpInter),0,0,'',IfThen(not fl,6100));
      DelPrnHead;
    end;
    if fl then TextObj:=result;
	  if result<>oldt then ELeftChange(EText,oldt,false);
  end
  else result:=TrimRight(TextObj);
  result:=DelTrim(StrTran(result,CRLF,' '));
  DelStack;
end;

// Меню "Шрифт"
procedure TEdGenFr.FontGetAssign;
var i: longint;
begin
	AddStack('TEdGenFr.FontGetAssign',Self);
	with FontGet.Items do begin
  	BeginUpdate; Clear;
    for i:=0 to GF.FontCount-1 do Add(FontStr(i,false));
    EndUpdate; 
  end;
  DelStack;
end;

function TEdGenFr.FontStr;
var f: TGFPackFont;
begin
	AddStack('TEdGenFr.FontStr',Self);
	f:=GF.Fonts[i]; SchemDM.aFont[dFont1].Assign(f.Font);
	result:=SpaceStr0(i,FontGet.LenCode,0)+IfThen(lFull,' ',UnDelim)+padr(f.Prop.Prim,FontGet.LenName);
  if lFull then IncD(result,' '+FontInf(SchemDM.aFont[dFont1])+' '+f.DopInf);
  DelStack;
end;

function TEdGenFr.FontGetList;
var i: longint;
begin
  AddStack('TEdGenFr.FontGetList',Self);
  result:='';
  for i:=0 to FontGet.Items.Count-1 do IncD(result,FontStr(i,true)+CRLF);
  DecLen(result,lCRLF);
  DelStack;
end;

function TEdGenFr.FontGetListOwner(Sender: TObject; SpdBut: TPaintButton;
  const RectList: TRect; PozList: TPozList): Boolean;
var lr: TListF2Result;
  oldval: string;
  oldcng: TNotifyEvent;
  tf: TFldEdit;
begin
	AddStack('TEdGenFr.FontGetListOwner',Self);
  inherited;
	result:=true; oldcng:=FontGet.Items.onChange; FontGet.Items.onChange:=nil;
  tf:=pointer(Sender); oldval:=tf.Value;
  lr:=TListF2Result.Create;
  try
    lr.SelectStr:=FontGet.SeekCurCod(tf); oldInd:=-1;
    if ListF2Down(FontGetList,lr,tf,RectList.Right-RectList.Left,tf.Schem,
    FontGetStr,FontGetProc,0,nil,FontMouseDown,FontMouseMove,FontMouseUp)
      then tf.Value:=IntToStr(lr.SelectStr) else tf.Value:=oldval;
  finally
    lr.Free; FontGet.Items.onChange:=oldcng;
  end;
  DelStack;
end;

procedure TEdGenFr.FontGetProc;
var ls: TFindListBox;
	i,j,j1: longint;
  fl,fl1: boolean;
begin
	AddStack('TEdGenFr.FontGetProc',Self);
	ls:=pointer(tw); ls.Filtered:=false; i:=ls.ItemIndex; PFont.Assign(GF.Fonts[i]); fl:=false;
	case Key of
  	// Сменить номер шрифта
  	K_F3: if i=0 then mess_ok(['Нельзя сменить номер шрифта "нормальный".'])
    else begin
      RGF['NumFont']:=SpaceStr0(i,FontGet.LenCode,0);
      fl:=TCngNum.GetNewNum('Новый номер шрифта:',nil,RGF,'NumFont',[''],[],'',nil,cteCod,FontCheck,nil,
        [cngNoLockEdConf,cngNoLockMono]);
      if fl then begin
        GF.FontCngNum(i,RGF['NumFont']);
        if i<RGF['NumFont'] then j:=RGF['NumFont']
        else begin
          j:=i; i:=RGF['NumFont'];
        end;
        for i:=i to j do FontUpdate(i,ls);
        i:=RGF['NumFont'];
      end;
    end;
    // Добавить/скопировать шрифт
  	K_F4,K_F7: begin
      deFont.FrmCaption:='Добавление шрифта';
      deFont.Param[0,deNoReadOnly]:=bTrue;
      if Key=K_F7 then begin
        PFont.Prop.Prim:=''; PFont.Prop.AType:=fptNormal;
        ZeroMemory(@PFont.Prop.Dop,SizeOf(PFont.Prop.Dop));
        DefaultFont(SchemDM.aFont[dFont1]); PFont.Font.Assign(SchemDM.aFont[dFont1]);
      end;
      FontToRGF; fl:=deFont.Execute.Saved;
      if fl then begin
        RGFToFont; i:=GF.FontCount; FontAdd; ls.Items.Add(FontStr(i,true));
      end;
    end;
    // Редактировать шрифт
  	K_F5,K_Enter: begin
    	fl:=EdFont(PFont,i<>0);
      if fl then begin
	      GF.Fonts[i].Assign(PFont); FontUpdate(i,ls);
      end;
    end;
    // Удалить шрифт
  	K_F8: if i=0 then meserr('Нельзя удалить шрифт "нормальный".')
    else begin
    	fl1:=true; GF.SaveCurLeaf;
      for j:=0 to GF.PageCount-1 do begin
        for j1:=0 to GF.PgObjectCount(j)-1 do
          if GF.PgObjects(j,j1).Font=i then begin
            meserr('Данный шрифт используется в форме.'); fl1:=false; break;
          end;
        if not fl1 then break;
      end;
      if fl1 then begin
        fl:=ask(['Удалить шрифт "'+Trim(PFont.Prop.Prim)+'" ?'],true);
        if fl then begin
          GF.FontDel(i); FontGet.Items.Delete(i); ls.Items.Delete(i);
          for j:=i to GF.FontCount-1 do FontUpdate(j,ls);
          MinSelf(i,GF.FontCount-1);
        end;
      end;
    end;
    K_Esc: GetParentForm(ls).ModalResult:=mrCancel;
    K_Ctrl_Up,K_Ctrl_Down: if i>0 then begin
      j:=i;
      if Key=K_Ctrl_Up then Dec(i) else Inc(i);
      if InRange(i,1,ls.Items.Count-1) then begin
        ls.Items.Exchange(i,j); GF.FontCngNum(i,j);
        FontUpdate(i,ls); FontUpdate(j,ls); fl:=true;
      end;
    end;
	end;
  if fl then begin
  	ls.ItemIndex:=i; GF.PaintAll; Modified:=true;
  end;
  DelStack;
end;

procedure TEdGenFr.deFontFldChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
var t: TGFFontType;
  fl: boolean;
begin
	AddStack('TEdGenFr.deFontFldChange',Self);
  with TFldEdit(Sender) do if NameRecFld='ATYPE' then begin
  	t:=VarValue; fl:=Assigned(TDefEdit.Find(StrNum('GFFont',t)+IfThen(Self<>EdGenFr,sWND)));
  	with deFont.FldEdit['Z'] do begin
    	SetReadOnly(not fl);
	    if fl then Read;
    end;
    if (t in [fptQRCode,fptPDF417]) and (RGF['Module']=0) then begin
      RGF['Module']:=5; deFont.Read('Z',IfThen(FromShow,ferdFromShow));
    end;
    if (t=fptPDF417) and (RGF['RowHeight']=0) then RGF['RowHeight']:=3;
    deFont.SetReadOnly('ANGLE',t=fptQRCode);
  end;
  DelStack;
end;

procedure TEdGenFr.deFontFldExit(Sender: TObject);
begin
  AddStack('TEdGenFr.deFontFldExit',Self);
  if RGF['ATYPE']=fptQRCode then deFont.FldValue['ANGLE']:=0;
  DelStack;
end;

function TEdGenFr.FontDopGetClick(Sender: TObject; lEval: Boolean): String;
var t: TGFFontType;
	a: TArrStr;
begin
	AddStack('TEdGenFr.FontDopGetClick',Self);
  t:=RGF['ATYPE'];
  if lEval then TDefEdit.ExecNm(StrNum('GFFont',t)+IfThen(Self<>EdGenFr,sWND),
    'Дополнительные параметры (вид: '+aGFFontType[t]+')');
  case t of
    fptNormal: CopyFrom(a,
    	[IfThen(RGF['OnlyDig'],'только цифры')
    	,IfThen(RGF['WidthTextAll'],'ширина по всему тексту')
      ,IfThen(RGF['OnWidth'],'границы по ширине')
      ,IfThen(RGF['ALine'],'разбить по полученной ширине')
      ,IfThen(RGF['RowBetween']<>0,Format('интервал между строками: %d/10 мм',[longint(RGF['RowBetween'])]))
      ,IfThen(RGF['PrcSpMin']<>0,Format('увеличивать пробелы не более чем на: %d%%',[longint(RGF['PrcSpMin'])]))
      ,StrUtils.IfThen(not empty(RGF['ChrFill']),'заполнить справа последнюю строку символом "'+RGF['ChrFill']+'"')
      ]);
    fptSepstr: CopyFrom(a,
    	[IfThen(RGF['OnlyDig'],'только цифры')
    	,IfThen(RGF['MMetrSep'],Format('размер ячейки: %dx%d мм',[longint(RGF['WidthMm']),longint(RGF['HeightMm'])]))
      ]);
    fptBarCode: CopyFrom(a,IfThen(RGF['Koef']<>0,Format('увеличение размеров на %d%%',[longint(RGF['Koef'])])));
    fptQRCode: with aQRCode_ECCLevel[QRCode_ECCLevel] do CopyFrom(a,
    	['уровень коррекции ошибок: '+nm[1]+' - '+nm[2]+Format(' (%d%%)',[prc])
      ,Format('минимальный размер модуля: %d/10 мм',[longint(RGF['Module'])])
      ]);
    fptPDF417: CopyFrom(a,
    	['максимальный уровень коррекции ошибок: '+RGF['ECCLevel']
      ,StrNum('отношение высоты модуля к ширине: ',RGF['RowHeight'])
    	,Format('максимальная ширина модуля: %d/10 мм',[longint(RGF['Module'])])
      ]);
  end;
  result:=DlmBetween(a,', ');
  DelStack;
end;

procedure TEdGenFr.FontDopGetPaint(Sender: TObject; const ARect: TRect;
  const Text: String);
var tf: TFldEdit;
begin
	AddStack('TEdGenFr.FontDopGetPaint',Self);
  tf:=pointer(Sender); FontDopGet.DrawText(tf,astolin(tf.Canvas,Text,ARect.Right-ARect.Left));
  DelStack;
end;

function TEdGenFr.FontLsGetClick(Sender: TObject; lEval: Boolean): String;
begin
	AddStack('TEdGenFr.FontLsGetClick',Self);
  inherited;
  SchemDM.aFont[dFont1].Assign(PFont.Font);
  result:=SchemDM.FontGetClick(Sender,lEval);
  PFont.Font.Assign(SchemDM.aFont[dFont1]);
  DelStack;
end;

procedure TEdGenFr.FontLsGetSize(Sender: TObject; const Text: String; var Size: tagSIZE);
begin
	AddStack('TEdGenFr.FontLsGetSize',Self);
  inherited;
  SchemDM.FontGetSize(Sender,Text,Size);
  DelStack;
end;


procedure TEdGenFr.FontLsGetPaint(Sender: TObject; const ARect: TRect; const Text: String);
begin
	AddStack('TEdGenFr.FontLsGetPaint',Self);
  inherited;
  SchemDM.aFont[dFont1].Assign(PFont.Font);
  SchemDM.FontGetPaint(Sender,ARect,Text);
  DelStack;
end;

procedure TEdGenFr.deFont0FldChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TEdGenFr.deFont0FldChange',Self);
  with TFldEdit(Sender) do if NameRecFld='ONWIDTH'
  then deFont0.SetReadOnly(['Z1','PRCSPMIN','CHRFILL'],not VarValue);
  DelStack;
end;

procedure TEdGenFr.deFont1FldChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TEdGenFr.deFont1FldChange',Self);
  with TFldEdit(Sender) do if NameRecFld='MMETRSEP'
  then deFont1.SetReadOnly(['WidthMm','HeightMm'],not VarValue);
  DelStack;
end;

procedure TEdGenFr.deFont4FldChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
  AddStack('TEdGenFr.deFont4FldChange',Self);
  if AnsiMatchText(TFldEdit(Sender).NameRecFld,['MODULE','ROWHEIGHT'])
  then deFont4.FldValue['ModuleHeight']:=RGF['MODULE']*RGF['ROWHEIGHT'];
  DelStack;
end;

// Смена номера шрифта с помощью мыши
procedure TEdGenFr.FontMouseDown;
var Ls: TFindListBox;
begin
	AddStack('TEdGenFr.FontMouseDown',Self);
	if ssLeft in Shift then begin
    Ls:=pointer(Sender); ls.Filtered:=false; curInd:=Ls.ItemAtPos(Point(X,Y),true); oldInd:=curInd;
    if oldInd>=0 then begin
      Ls.ItemIndex:=curInd; //Ls.Cursor:=crDrag;
    end;
  end;
  DelStack;
end;

procedure TEdGenFr.FontMouseMove;
var Ls: TFindListBox;
	i,j: longint;
	step: TValueSign;
begin
	AddStack('TEdGenFr.FontMouseMove',Self);
	if oldInd>0 then begin
		Ls:=pointer(Sender); i:=Ls.ItemAtPos(Point(X,Y),true);
    if (i>0) and (curInd<>i) then begin
      j:=i; step:=aSign[curInd<i];
      while j<>curInd do begin
        Ls.Items.Exchange(j,curInd); Inc(j,step);
      end;
      curInd:=i; Ls.ItemIndex:=curInd;
    end;
  end;
  DelStack;
end;

procedure TEdGenFr.FontMouseUp;
var Ls: TFindListBox;
	i,j: longint;
begin
	AddStack('TEdGenFr.FontMouseUp',Self);
	if oldInd>0 then begin
		Ls:=pointer(Sender);
    if Y<0 then i:=1
    else begin
      i:=Ls.ItemAtPos(Point(X,Y),true); i:=IfThen(i=-1,GF.FontCount-1,IfThen(i=0,1,i));
    end;
    if i<>oldInd then begin
      GF.FontCngNum(oldInd,i); GF.PaintAll;
      for j:=min(oldInd,i) to max(oldInd,i) do FontUpdate(j,Ls);
      Ls.ItemIndex:=i; Modified:=true;
    end;
		Ls.Cursor:=crDefault; oldInd:=0;
  end;
  DelStack;
end;

procedure TEdGenFr.FontUpdate;
begin
	AddStack('TEdGenFr.FontUpdate',Self);
  FontGet.Items[i]:=FontStr(i,false); ls.Items[i]:=FontStr(i,true);
  DelStack;
end;

function TEdGenFr.FontCheck;
begin
	AddStack('TEdGenFr.FontCheck',Self);
  result:=InRange(Int0(TFldEdit(Sender).Value),1,GF.FontCount-1);
  DelStack;
end;

class function PrmExchange(ls: TFindListBox; oi,ni: longint): boolean;
var i: longint;
begin
  AddStack('FEdGenFr.PrmExchange');
  result:=ListMoveItem(oi,ni,0,ls.Items.Count-1,TNone.PrMove,[0]);
  if result then for i:=min(oi,ni) to max(oi,ni) do ls.Items[i]:=PrmStr(i);
  DelStack;
end;

// Форматы
procedure TEdGenFr.PrmKeyProc;
var ls: TFindListBox;
	i,j: longint;
  fl,fl1: boolean;
begin
	AddStack('TEdGenFr.PrmKeyProc',Self);
	ls:=pointer(tw); ls.Filtered:=false; i:=ls.ItemIndex; fl:=false;
	with GFPrm do begin
    case Key of
      // Сменить номер формата
      K_F3: begin
        RGF['NumFont']:=SpaceStr0(i+1,3,0);
        if TCngNum.GetNewNum('Новый номер формата:',nil,RGF,'NumFont',[''],[],'',nil,cteCod,TNone.PrmCheck,nil,
        [cngNoLockEdConf,cngNoLockMono]) then begin
          j:=i; i:=RGF['NumFont']-1; fl:=PrmExchange(ls,j,i);
        end;
      end;
      // Добавить/скопировать формат
      K_F4,K_F7: begin
        fl1 := Key=K_F4;
        if fl1 then RGF['PrmName']:=aPrm[i].Name else RGF['PrmName']:='';
        if dePrm.Execute('Добавление формата').Saved then begin
          fl:=true; j:=Length(aPrm); SetLength(aPrm,j+1);
          if fl1 then aPrm[j]:=aPrm[i] else aPrm[j]:=TGenForm.PrmDef;
          i:=j; aPrm[i].Name:=RGF['PrmName']; ls.Items.Add(PrmStr(i));
        end;
      end;
      // Редактировать формат
      K_F5,K_Enter: begin
        RGF['PrmName']:=aPrm[i].Name;
        if dePrm.Execute('Редактирование формата').Saved then begin
          fl:=true; aPrm[i].Name:=RGF['PrmName']; ls.Items[i]:=PrmStr(i); nPrm:=i;
        end;
      end;
      // Удалить формат
      K_F8: if Length(aPrm)=1 then mess_ok(['Нельзя удалить последний формат.'])
      else if ask(['Удалить формат "'+Trim(aPrm[i].Name)+'" ?'],true) then begin
        fl:=true;
        for j:=i to high(aPrm)-1 do begin
          aPrm[j]:=aPrm[j+1]; ls.Items[j]:=PrmStr(j);
        end;
        SetLength(aPrm,Length(aPrm)-1); ls.Items.Delete(ls.Items.Count-1);
        MinSelf(i,ls.Items.Count-1);
      end;
      K_Ctrl_Up,K_Ctrl_Down: begin
        j:=i;
        if Key=K_Ctrl_Up then Dec(i) else Inc(i);
        fl:=PrmExchange(ls,j,i);
      end;
    end;
    if fl then begin
      ls.ItemIndex:=i; Modified:=true;
    end;
  end;
  DelStack;
end;

procedure TEdGenFr.PrmMouseMove;
var Ls: TFindListBox;
	i: longint;
begin
	AddStack('TEdGenFr.PrmMouseMove',Self);
	if oldInd>=0 then begin
		Ls:=pointer(Sender); i:=Ls.ItemAtPos(Point(X,Y),true);
    if PrmExchange(ls,curInd,i) then begin
      curInd:=i; Ls.ItemIndex:=curInd; GFPrm.Modified:=true;
    end;
  end;
  DelStack;
end;

procedure TEdGenFr.PrmMouseUp;
begin
  oldInd:=-1;
end;

function TEdGenFr.dePrmFldCheck(Sender: TObject): Boolean;
begin
	AddStack('TEdGenFr.dePrmFldCheck',Self);
  NoEmpCheck(Sender,'PRMNAME',result);
  DelStack;
end;

// Деление или объединение объектов
procedure TEdGenFr.ObjDivProc;
begin
	AddStack('TEdGenFr.ObjDivProc',Self);
	case Key of
    K_F7: deAdd.Execute;
    K_Ctrl_Up: if GF.DivSelObj(dvTop) then Modified:=true;
    K_Ctrl_Down: if GF.DivSelObj(dvBottom) then Modified:=true;
    K_Ctrl_Left: if GF.DivSelObj(dvLeft) then Modified:=true;
    K_Ctrl_Right: if GF.DivSelObj(dvRight) then Modified:=true;
    K_Ctrl_F7: if GF.CombSelObj then Modified:=true;
		K_Shift_F7: deNewLine.Execute; 
  end;
  DelStack;
end;

procedure TEdGenFr.deAddFrmShow(Sender: TObject);
var tf: TFldEdit;
begin
	AddStack('TEdGenFr.deAddFrmShow',Self);
  tf:=deAdd.FldEdit['DIVVID'];
  TCheckSpace.SetButEnabled(tf,byte(dvRight ),ogReadOnly in SRight.Options);
  TCheckSpace.SetButEnabled(tf,byte(dvBottom),ogReadOnly in SBottom.Options);
  TCheckSpace.SetButEnabled(tf,byte(dvLeft  ),ogReadOnly in SLeft.Options);
  TCheckSpace.SetButEnabled(tf,byte(dvTop   ),ogReadOnly in STop.Options);
  DelStack;
end;

procedure TEdGenFr.deAddPnlCngKey(Sender: TObject; var tb: TKeyBut);
begin
	AddStack('TEdGenFr.deAddPnlCngKey',Self);
  with tb do if Key=K_F10 then Caption:='Разделить';
  DelStack;
end;

function TEdGenFr.deAddPnlValid(Sender: TObject): Boolean;
var i: longint;
  Opt: TGFDivSelObjOpt;
begin
	AddStack('TEdGenFr.deAddPnlValid',Self);
  inherited;
  result:=true; i:=RGF['DivVid'];
  if RGF['DivCopy'] then Opt:=[gfdvCopyText] else Opt:=[];
  if TCheckSpace.GetButEnabled(TPanelEdit(Sender).Fields[0],i) then
    if GF.DivSelObj(TGFVidDiv(i),Opt) then Modified:=true;
  DelStack;
end;

procedure TEdGenFr.GFEnter(Sender: TObject);
var fl: boolean;
begin
	AddStack('TEdGenFr.GFEnter',Self);
  inherited;
  fl:=not Assigned(PrEdGet);
  with KeyLb1 do begin
    if fl then begin
      SetKey(K_Shift_F2,'','Сохранить в файл',ProcKey,'Prm',kmFile);
      SetKey(K_Shift_F3,'','Считать из файла',ProcKey,'Prm',kmFile);
      SetKey(K_Ctrl_F3,'','Загрузить с центрального компьютера',ProcKey,'Prm',kmFile);
    end
    else begin
      SetKey(K_Shift_F3,'','Восстановить предыдущее описание',ProcKey,'Prm',kmFile);
    end;
  	SetKey(K_Ctrl_A,'','Отметить все объекты',ProcKey,'Prm',kmGFKbd);
  	SetKey(K_Ctrl_1,'','Отметить объекты по типу',ProcKey,'Prm',kmGFKbd);
  	SetKey(K_Ctrl_2,'','Отметить объекты по ед.изм.',ProcKey,'Prm',kmGFKbd);
  	SetKey(K_Ctrl_3,'','Отметить объекты по шрифту',ProcKey,'Prm',kmGFKbd);
    if fl then begin
      SetKey(K_Ctrl_4,'','Отметить объекты по разделу',ProcKey,'Prm',kmGFKbd);
      SetKey(K_Ctrl_5,'','Отметить объекты по колонке',ProcKey,'Prm',kmGFKbd);
     	SetKey(K_Ctrl_6,'','Отметить объекты по типу вывода',ProcKey,'Prm',kmGFKbd);
    end;
  	SetKey(K_Ctrl_7,'','Отметить объекты по размещению',ProcKey,'Prm',kmGFKbd);
  	SetKey(K_Ctrl_8,'','Отметить объекты по прижатию',ProcKey,'Prm',kmGFKbd);
  	SetKey(K_Ctrl_9,'','Отметить объекты по цвету',ProcKey,'Prm',kmGFKbd);
  	SetKey(K_Ctrl_0,'','Отметить объекты по содержимому',ProcKey,'Prm',kmGFKbd);
  	SetKey(K_Ctrl_Zpt,'','Отметить объекты по ширине',ProcKey,'Prm',kmGFKbd);
  	SetKey(K_Ctrl_Point,'','Отметить объекты по высоте',ProcKey,'Prm',kmGFKbd);
  	SetKey(K_Ctrl_Plus,'','Отметить объекты по идентификатору',ProcKey,'Prm',kmGFKbd);
    if fl then SetKey(K_Ctrl_Minus,'','Отметить объекты по выводу только на первой странице',ProcKey,'Prm',kmGFKbd);
  	SetKey(K_F4,'Параметры','Редактирование параметров формы',ProcKey,'Prm',kmEdit);
    SetKeyFind(ProcKey,'Prm',kmEdit,false);
    if fl then begin
	  	SetKey(K_F11,'Листы','Список листов',ProcKey,'Prm',kmEdit);
      SetKey(K_Ctrl_F4,'','Редактирование алгоритма дополнительных действий',ProcKey,'Prm',kmEdit);
      SetKey(K_Ctrl_F5,'Алгоритм','Редактирование алгоритма формирования',ProcKey,'Prm',kmEdit);
      SetKey(K_Ctrl_F6,'Окно ввода','Настройка окна ввода данных',ProcKey,'Prm',kmEdit);
      SetKey(K_Ctrl_F8,'Данные','Данные по документу',ProcKey,'Prm',kmEdit);
      SetKey(K_Shift_F4,'','Настройка окна ввода для дополнительных действий',ProcKey,'Prm',kmEdit);
      SetKey(K_Shift_F5,'','Название клавиши выполнения дополнительных действий',ProcKey,'Prm',kmEdit);
      SetKey(K_Shift_F6,'','Настройка окна ввода параметров',ProcKey,'Prm',kmEdit);
      SetKey(K_Shift_F8,'','Параметры документа',ProcKey,'Prm',kmEdit);
    end;
    SetKey(K_Ctrl_F9,'','Редактирование действий для мыши',ProcKey,'Prm',kmEdit);
  	SetKeys([K_Space,K_Up,K_Down,K_Left,K_Right],'','Начать управление с клавиатуры',GF.GFProcKey,'Prm',kmEdit);
  	SetKey(K_Alt_F3,'','Создать основу',ProcKey,'Prm',kmEdit);
  	SetKey(K_Alt_F5,'','Взять за основу',ProcKey,'Prm',kmEdit);
  	SetKey(K_Ctrl_Z,'','Восстановление из резервной копии',ProcKey,'Prm',kmEdit);
  	SetKey(K_Ctrl_R,'','Перенести идентификаторы из содержимого в свойства',ProcKey,'Prm',kmNone);
    ReDrw;
  end;
  GF.PopupMenu:=PopupMenu1; tmAutoSave.Enabled:=true;
  if tmAutoSave.Interval>0 then tmAutoSave.Timer;
  DelStack;
end;

procedure TEdGenFr.GFExit(Sender: TObject);
begin
	AddStack('TEdGenFr.GFExit',Self);
  inherited;
  KeyLb1.DelKey(K_All,'Prm'); KeyLb1.ReDrw; GF.PopupMenu:=nil; tmAutoSave.Enabled:=false;
  DelStack;
end;

procedure TEdGenFr.ProcKey;
var p: PDWSearchInfo;
  function PSearch: PDWSearchInfo;
  begin
    AddStack('TEdGenFr.ProcKey.PSearch',Self);
    if SearchInfo.NumObj<0 then p:=nil
    else begin
      New(p); p.TypeObj:=SearchInfo.DWType; p.GFType:=SearchInfo.DWGFType;
      p.NumObj:=SearchInfo.NumObj; p.NumPage:=SearchInfo.NumLeaf;
    end;
    result:=p;
    DelStack;
  end;
  procedure PSearchFree;
  begin
    AddStack('TEdGenFr.ProcKey.PSearchFree',Self);
    if Assigned(p) then Dispose(p);
    DelStack;
  end;
var pv: PGFObj;
  j,l: longint;
  function DecStr(const s: string): boolean;
  var i,i1: longint;
  begin
    AddStack('TEdGenFr.ProcKey.DecStr',Self);
    while j>0 do
      if (pv.Text[j]>' ') or (pv.Text[j] in [#10,#13]) then break else Dec(j);
    i:=j; i1:=Length(s); result:=false;
    while i>0 do begin
      if i1=0 then break;
      if pv.Text[i]<>s[i1] then break;
      Dec(i);
      if i1=1 then begin
        result:=true; j:=i; break;
      end;
      Dec(i1);
    end;
    DelStack;
  end;
  function IncStr(const s: string): boolean;
  var i,i1,l1: longint;
  begin
    AddStack('TEdGenFr.ProcKey.IncStr',Self);
    while j<=l do
      if (pv.Text[j]>' ') or (pv.Text[j] in [#10,#13]) then break else Inc(j);
    i:=j; i1:=1; l1:=Length(s); result:=false;
    while i<=l do begin
      if i1>l1 then break;
      if pv.Text[i]<>s[i1] then break;
      Inc(i);
      if i1=l1 then begin
        result:=true; j:=i; break;
      end;
      Inc(i1);
    end;
    DelStack;
  end;
type
  TGFGroup = (ggAll,ggTypeObj,ggMMetr,ggFont,ggPart,ggCol,ggVOut,ggAlignment,ggPin,
    ggColor,ggText,ggWidth,ggHeight,ggIdent,ggOnly1);
  procedure SelGroupObj(gr: TGFGroup; const Value: variant; lTextEq: boolean = false);
  var i: longint;
    pv: PGFObj;
    fl: boolean;
  begin
    AddStack('TEdGenFr.ProcKey.SelGroupObj',Self);
    with GF do begin
      if not KeyExtend then begin
        TmpList.Clear;
        for i:=0 to SelObjectCount-1 do TmpList.Add(PSelObjects[i]);
        SelectObjs(TmpList,false);
      end;
      TmpList.Clear;
      for i:=0 to ObjectCount-1 do begin
        pv:=PObjects[i];
        case gr of
          ggAll      : fl := true;
          ggTypeObj  : fl := pv.TypeObj=Value;
          ggMMetr    : fl := byte(pv.MMetr)=Value;
          ggFont     : fl := pv.Font=Value;
          ggPart     : fl := TrimRight(pv.Part)=TrimRight(Value);
          ggCol      : fl := TrimRight(pv.Col)=TrimRight(Value);
          ggVOut     : fl := pv.VOut=Value;
          ggAlignment: fl := pv.Alignment=Value;
          ggPin      : fl := pv.Pin=Value;
          ggColor    : fl := pv.Color=Value;
          ggText     :
            if lTextEq
            then       fl := TrimRight(Value)=TrimRight(pv.Text)
            else       fl := Pos(RTrimUpper(Value),AnsiUpperCase(pv.Text))>0;
          ggWidth    : fl := pv.MinWidth=Value;
          ggHeight   : fl := pv.MinHeight=Value;
          ggIdent    : fl := TrimRight(pv.Ident)=TrimRight(Value);
          ggOnly1    : fl := pv.Only1=Value;
        else fl:=false;
        end;
        if fl then TmpList.Add(pv);
      end;
      if SelectObjs(TmpList,true) then PaintFillAll;
      TmpList.Clear;
    end;
    DelStack;
  end;
const	aGFSearchPrim: TGFSearchStr = ('','','','(№ листа)','(№ листа)','(№ листа)','(№ листа)','','','');
  sObjIdent = 'ОБ_ИДЕНТ';
var ts,tf: TFldEdit;
  gr: TGFGroup;
  f: TFld;
  pd: TPPDocRec;
  SelRow: TModelFile;
  tn,tn1,tnSel: TTreeNode;
	i,k,p1,p2,j1: longint;
  tp: TGFSearchType;
  dw: TDataWin;
  a: TDWSearchAInfo;
  fl,fl1,fl2: boolean;
  c: char;
  mr: TListF2Result;
  ofn,fn: TFileName;
  def: variant;
  oDef: PString;
  ap: TDEPrmStr;
  af: TArrStr;
  ad: TArrDate;
begin
	AddStack('TEdGenFr.ProcKey',Self);
	case Key of
		// Редактирование параметров формы
  	K_F4: with GF do begin
      pd.Params:=GFCopyParams(Params); oldInd:=-1;
      if GFPrmExec(pd,nil,Assigned(PrEdGet),lsBitMap,nil,'',FontProc,'',nil,PrmProc,nil,0,PrModify) then begin
      	Params:=pd.Params; SetSizeMm; FillLnWidth; AutoSize; Modified:=true;
      end;
    end;
    // Список листов
  	K_F11: begin
    	j:=0; CurLeaf:=GF.Leaf; GF.SaveCurLeaf;
    	with TKeyLb do if TGFPages.Execute(GF,ArrayAsList(
      [GetKeySt(K_F4,'Скопировать')
      ,GetKeySt(K_F5,'Редактировать')
      ,GetKeySt(K_F7,'Добавить')
      ,GetKeySt(K_F8,'Удалить')
	  	,GetKeySt(K_Ctrl_Up,'Выше')
  		,GetKeySt(K_Ctrl_Down,'Ниже')
      ],CRLF),PageKeyProc,PageMove)
      	then j:=GFPages.sb.Row
      else if CurLeaf=0 then j:=1;
      FormFree(GFPages);
      if (j<>0) and (j<>CurLeaf) then
        if ObjSpace then CurLeaf:=j;
      SetLeaf(CurLeaf);
    end;
    // Загрузить с центрального компьютера
    K_Ctrl_F3: if ask(['Загрузить с центрального компьютера ?'],true) then begin
      OpenMsg(true); Modified:=false;
    end;
    // Редактирование алгоритмов
    K_Ctrl_F4,K_Ctrl_F5,K_Ctrl_F9: begin
    	RDBDef;
      if SearchInfo.NumObj>=0 then EdTextInitFind:=true;
      AddPrnHead(FRup(aGFSearchName[
        IfThen(Key=K_Ctrl_F4,gfsAlgDop,IfThen(Key=K_Ctrl_F9,gfsAlgMouse,gfsAlg))]));
      case Key of
        K_Ctrl_F4: fl:=EdTextExec('Редактирование алгоритма дополнительных действий',
          GF.DopAlg,'',nil,[],edtpInter,0,0,'',6101);
        K_Ctrl_F9: fl:=EdTextExec('Редактирование действий для мыши',
          GF.MouseAlg,'',nil,[],edtpInter,0,0,'',6102);
      else fl:=EdTextExec('Редактирование алгоритма формирования',
        GF.StrAlg,'',nil,[],edtpInter,0,0,'',6101);
      end;
      if fl then Modified:=true;
      DelPrnHead;
    end;
    // Настройка окна ввода данных и доп.действий
    K_Ctrl_F6,K_Shift_F4: begin
    	fl := Key=K_Ctrl_F6;
      AddPrnHead(FRup(aGFSearchName[TGFSearchType(iif(fl,gfsWDat,gfsWDop))]));
    	if DWFldExec('Настройка окна ввода '+IfThen(fl,'данных','для дополнительных действий'),
        GF.awWin[TGFWinList(iif(fl,gfwDat,gfwDop))],[RDocPrm,RDocpPrm],RDocPrm,nil,[dwfCreateVar],nil,{nil,}PSearch)
        then Modified:=true;
	    DelPrnHead;
      if RDocPrm.DWModified then begin
      	Modified:=true; CngDat:=true;
      end;
      if RDocpPrm.DWModified then begin
      	Modified:=true; CngPrm:=true;
      end;
      PSearchFree; TDWPrm.VarCreate(RDocPrm); TDWPrm.VarCreate(RDocpPrm);
    end;
    K_Ctrl_F8: begin
      if DWVidExec(RDocPrm) then begin
      	Modified:=true; CngDat:=true;
      end;
      TDWPrm.VarCreate(RDocPrm);
    end;
    // Отметка всех объектов
		K_Ctrl_A: SelGroupObj(ggAll,0);
		K_Ctrl_R: if Ask(['Перенести идентификаторы из содержимого в свойства ?']) then begin
    	GF.SaveCurLeaf; fl:=false;
      for j1:=0 to GF.PageCount-1 do
        for i:=0 to GF.PgObjectCount(j1)-1 do begin
          pv:=GF.PgObjects(j1,i); l:=Length(pv.Text);
          if (pv.TypeObj in [toForm,toCalc,toCalcBmp]) and (l>0) and (pv.Ident='') then 
            if IsPos(j,sObjIdent,pv.Text) then begin
              p1:=j; Dec(j);
              if DecStr('=>') and DecStr('"') or DecStr('''') then begin
                c:=pv.Text[j+1]; p2:=j;
                while j>0 do
                  if pv.Text[j]=c then begin
                    k:=j-1; fl1:=true; fl2:=true;
                    while k>0 do begin
                      case pv.Text[k] of
                        #10: break;
                        ',': if fl2 then begin
                          fl2:=false; j:=k;
                        end;
                      else
                        if (pv.Text[k]>' ') and fl2 then begin
                          fl1:=false; break;
                        end;
                      end;
                      Dec(k);
                    end;
                    if fl1 and (pv.Text[k+1]>' ') then begin
                      pv.Ident:=Copy(pv.Text,j+1,p2-j); p2:=j; j:=p1+Length(sObjIdent);
                      if fl2 then IncStr(',');
                      pv.Text:=TInter.FormatStr(TrimLeft(StuffString(pv.Text,p2,j-p2,''))); fl:=true; j:=1;
                      if IncStr('"') or IncStr('''') then begin
                        c:=pv.Text[j-1]; p1:=j;
                        while j<=l do
                          if pv.Text[j]=c then begin
                            p2:=j;
                            if empty(Copy(pv.Text,j+1,MaxInt)) then begin
                              CopySelf(pv.Text,p1,p2-p1); pv.TypeObj:=toText;
                            end;
                            break;
                          end
                          else Inc(j);
                      end;
                    end;
                    break;
                  end
                  else Dec(j);
              end;
            end;
        end;
      if fl then begin
        SetLeaf(GF.Leaf); GF.AutoSize; Modified:=true;
      end;
    end;
    // Восстановление из резервной копии
    K_Ctrl_Z: begin
      tmAutoSave.Timer;
      fn:=FullNameExe(GF.FileName,'DCM')+'.'+StringOfChar('?',LenTmpNum)+'.BDC';
      mr:=TListF2Result.Create;
      try
        GetMaskFiles(af,j,fn,[],[msfNoUpper,msfSort],@ad); mr.Capacity:=j; Dec(j); 
        for i:=0 to j do mr.Add(FormatDateTime('dd/mm/yyyy hh:nn:ss',ad[i]));
        if ListF2Down(mr.Text,mr,nil,0,'Browl',
        TKeyLb.GetKeySt(K_F5,'Интервал','Изменить интервал автосохранения'),AutoSaveKeyProc,
        0,nil,nil,nil,nil,nil,'Резервные копии') then
          if InRange(mr.SelectStr,0,j) then begin
            ofn:=GF.FileName; GF.FileName:=ExtractFilePath(fn)+af[mr.SelectStr];
            oDef:=pDcmDef; pDcmDef:=nil;
            OpenMsg; GF.FileName:=ofn; pDcmDef:=oDef; Modified:=true;
          end;
      finally
        mr.Free; 
      end;
    end;
    K_Alt_F3: SchemDM.mgDcm.Add;
    K_Alt_F5: begin
    	SelRow:=GF.VersInfo.MDFile; SchemDM.mgDcm.List(SelRow);
    end;
    // Сохранение
    K_Shift_F2: if ask(['Сохранить в файл ?'],true) then begin
      SaveMsg; Modified:=false;
    end;
    // Название клавиши выполнения дополнительных действий
    K_Shift_F5: begin
    	RGF['PrmName']:=GF.DopAlgName;
      if deDopAlgName.Execute.Saved then begin
      	GF.DopAlgName:=RGF['PrmName']; Modified:=true;
      end;
    end;
    // Восстановление
    K_Shift_F3: if ask([KeyLb1.SeekKey(Key).Hint+' ?'],true) then begin
      OpenMsg; Modified:=false;
    end;
    // Настройка окна ввода параметров
    K_Shift_F6: begin
    	AddPrnHead('Окно ввода параметров');
    	if DWFldExec('Настройка окна ввода параметров документа',
      	GF.awWin[gfwPrm],RDocpPrm,nil,nil,[dwfCreateVar],nil,{nil,}PSearch)
        then Modified:=true;
	    DelPrnHead;
      if RDocpPrm.DWModified then begin
      	Modified:=true; CngPrm:=true;
      end;
      PSearchFree; TDWPrm.VarCreate(RDocpPrm);
    end;
    K_Shift_F8: begin
      if DWVidExec(RDocpPrm) then begin
      	Modified:=true; CngPrm:=true;
      end;
      TDWPrm.VarCreate(RDocpPrm);
    end;
  else
    // Отметка группы объектов
		if Key in SelObjsList then begin
    	i:=0; k:=0; fl:=true;
      case Key of
      	K_Ctrl_0: begin
        	ts:=SText; gr:=ggText; i:=-1; k:=-1; fl:=false;
        end;
      	K_Ctrl_1: begin
        	ts:=STypeObj; gr:=ggTypeObj;
        end;
      	K_Ctrl_2: begin
        	ts:=SMMetr; gr:=ggMMetr;
        end;
      	K_Ctrl_3: begin
        	ts:=SFont; gr:=ggFont;
        end;
      	K_Ctrl_4: begin
	        ts:=SPart; gr:=ggPart; i:=-1;
        end;
      	K_Ctrl_5: begin
	        ts:=SCol; gr:=ggCol; i:=-1;
        end;
      	K_Ctrl_6: begin
	        ts:=SVOut; gr:=ggVOut;
        end;
      	K_Ctrl_7: begin
	        ts:=SAlignment; gr:=ggAlignment;
        end;
      	K_Ctrl_8: begin
	        ts:=SPin; gr:=ggPin;
        end;
      	K_Ctrl_9: begin
	        ts:=SOColor; gr:=ggColor;
        end;
      	K_Ctrl_Zpt: begin
	        ts:=SMinWidth; gr:=ggWidth;
        end;
      	K_Ctrl_Point: begin
	        ts:=SMinHeight; gr:=ggHeight;
        end;
      	K_Ctrl_Plus: begin
	        ts:=SIdent; gr:=ggIdent; i:=-1;
        end;
      	K_Ctrl_Minus: begin
	        ts:=SOnly1; gr:=ggOnly1;
        end;
      else
        ts:=nil; gr:=low(gr);
      end;
      if Assigned(ts) then begin
        tf:=pointer(ts.FocusControl); RGF.FldName(tf.NameRecFld,f);
        if gr=ggText then def:=TextObj else def:=f.Value;
        if (ogReadOnly in tf.Options) or KeyExtend then with deSel do begin
          ap:=GetArrParam(0);
          if gr=ggText then begin
            RGF.CreateFld('Sel',ftMemo,0,def);
            ap[deCaption]:='';
            ap[deMask]:=',,,3,'+StrTran(ts.Mask,cBoolSay);
            SchemDM.MemoGet1.AssignGet(ap);
          end
          else begin
            RGF.CreateFld('Sel',f.Info.DataType,f.Info.Size,def);
            ap[deCaption]:=StrTran(ts.Mask,cBoolSay);
            ap[deMask]:=tf.Mask;
            tf.curget.AssignGet(ap);
          end;
          ap[deAutoSel]:=bStr[fl];
          ap[deSayHint]:=ts.Hint;
          ap[deGetHint]:=tf.Hint;
          ap[deWidth]:=IntToStr(i);
          ap[deHeight]:=IntToStr(k);
          SetArrParam(0,ap);
          if Execute.Saved then SelGroupObj(gr,RGF['Sel']);
        end
        else SelGroupObj(gr,def,true);
      end;
    end
    else begin
      GF.SaveCurLeaf;
      if WinFindKey(Key,GF,prFind,[fnoRegistr,fnoWord,fnoReplace]) then
        if Assigned(SearchTree) then with SearchTree,SearchTree.Tree do begin
          ClearPrim; tp:=low(aGFSearchName); tn:=nil; tnSel:=nil; dw:=nil;
          try
            for i:=low(aInfo) to high(aInfo) do begin
              tn1:=nil;
              if (i=low(aInfo)) or (tp<>aInfo[i].TypeObj) then begin
                tp:=aInfo[i].TypeObj; tn:=AddPrim(nil,FRup(aGFSearchName[tp]),aGFSearchPrim[tp]);
                if tp in [gfsWPrm,gfsWDat,gfsWDop] then begin
                  SetLength(a,high(aInfo)-i+1); j1:=low(a);
                  for j:=i to high(aInfo) do begin
                    if aInfo[j].TypeObj<>tp then begin
                      SetLength(a,j-i); break;
                    end;
                    a[j1].TypeObj:=aInfo[j].DWType;
                    a[j1].GFType:=aInfo[j].DWGFType;
                    a[j1].NumObj:=aInfo[j].NumObj;
                    a[j1].Text:=aInfo[j].Text;
                    Inc(j1);
                  end;
                  TDataWin.aGet(dw).LoadFromStr(GF.awWin[aGFStoW[tp]]);
                  tn1:=dw.SetSearchNode(tn,a);
                end;
              end;
              case tp of
                gfsAlg,gfsAlgDop,gfsAlgMouse: tn1:=tn;
                gfsObjText,gfsObjIdent,gfsObjPart,gfsObjCol: begin
                  tn1:=AddPrim(tn,TDWPrm.GFObjSearchNode(aInfo[i].Text),BracketInt('',aInfo[i].NumLeaf+1),0,nil,aInfo[i].Text);
                end;
              end;
              PointerDef(pointer(tnSel),tn1);
            end;
          finally
            if Assigned(dw) then DataWinFree;
          end;
          if Execute(tnSel,i) then begin
            SearchInfo:=aInfo[i];
            with Self.KeyLb1 do case aInfo[i].TypeObj of
              gfsAlg: ExecKey(K_Ctrl_F5);
              gfsAlgDop: ExecKey(K_Ctrl_F4);
              gfsAlgMouse: ExecKey(K_Ctrl_F9);
              gfsObjText,gfsObjIdent,gfsObjPart,gfsObjCol: begin
                SetLeaf(aInfo[i].NumLeaf+1);
                Self.perform(WM_GFSEEKOBJ,byte(aInfo[i].TypeObj),aInfo[i].NumObj);
              end;
              gfsWPrm: ExecKey(K_Shift_F6);
              gfsWDat: ExecKey(K_Ctrl_F6);
              gfsWDop: ExecKey(K_Shift_F4);
            end;
            SearchInfo.NumObj:=-1;
          end;
        end;
    end;
  end;
  DelStack;
end;

procedure TEdGenFr.AutoSaveKeyProc;
begin
  AddStack('TEdGenFr.AutoSaveKeyProc',Self);
  if deAutoSave.Execute.Saved then tmAutoSave.Interval:=RGF['AutoSaveIntv']*MSecsPerSec;
  DelStack;
end;

procedure TEdGenFr.PageKeyProc;
var lAdd: boolean;
	i: longint;
begin
	AddStack('TEdGenFr.PageKeyProc',Self);
  with GFPages,sb do case Key of
    K_F4,K_F5,K_F7: begin
    	lAdd := Key<>K_F5; RGF['PrmName']:=IfThen(Key in [K_F4,K_F5],Cells[1,Row]);
      if dePage.Execute(IfThen(lAdd,'Добавление','Редактирование')+' листа').Saved then begin
      	if lAdd then begin
          GF.PageAdd(IfThen(Key=K_F4,Row)-1);
        	ListRefresh; IncRowCount; Row:=RowCount-1; Cells[0,Row]:=SpaceStr(Row,LenPage);
        end;
        GF.PageName[Row]:=RGF['PrmName']; Cells[1,Row]:=RGF['PrmName']; Modified:=true;
      end;
    end;
    K_F8: if RowCount<3 then meserr('Нельзя удалять последний лист.')
    else if Ask(['Внимание!','При удалении листа будут удалены',
    'все объекты, находящиеся на этом листе.','',Format('Удалить лист %d ?',[Row])]) then begin
    	if Row<=CurLeaf then CurLeaf:=0;
      GF.PageDel(Row); ListRefresh;
    	for i:=Row to RowCount-2 do Cells[1,i]:=Cells[1,i+1];
      i:=Row; IncRowCount(-1); Row:=EnsureRange(i,1,RowCount-1); Modified:=true;
    end;
    K_Ctrl_Up: Move(Row,Row-1);
    K_Ctrl_Down: Move(Row,Row+1);
  end;
  DelStack;
end;

procedure TEdGenFr.PageMove;
var s: string;
begin
	AddStack('TEdGenFr.PageMove',Self);
  with GFPages.sb do begin
	  s:=Cells[1,ni]; Cells[1,ni]:=Cells[1,oi]; Cells[1,oi]:=s;
  end;
  GF.PageExchange(ni,oi); CurLeaf:=0; Modified:=true;
  DelStack;
end;

procedure TEdGenFr.SetLeaf;
begin
  AddStack('TEdGenFr.SetLeaf',Self);
  GF.Leaf:=nLeaf;
  if not Assigned(PrEdGet)
  then RbStatus1.SectLeft[1]:=Format('Лист: %d. ',[GF.Leaf])+Trim(GF.PageName[GF.Leaf]);
  DelStack;
end;

procedure TEdGenFr.RDBDef;
	procedure Def1(var Cng: boolean; rdb: TRecDBDef);
  begin
    AddStack('TEdGenFr.RDBDef.Def1',Self);
    if Cng then begin
      rdb.InitFldDef; Cng:=false;
    end;
    DelStack;
	end;
begin
  AddStack('TEdGenFr.RDBDef',Self);
  if not Assigned(PrEdGet) then begin
	  Def1(CngDat,RDocPrm); Def1(CngPrm,RDocpPrm);
  end;
  DelStack;
end;

function TEdGenFr.prFind;
var a: TGFSearchCnt;
  i: TGFSearchType;
  cnt: longint;
begin
	AddStack('TEdGenFr.prFind',Self);
  with FindProperty do if Replace then begin
    a:=GF.ReplaceIdent(sf,sr,[gfrNoIdent,gfrNoOnlyFml]); cnt:=0; result:=false;
    for i:=low(a) to high(a) do if a[i]>=0 then begin
      Inc(cnt,a[i]); Modified:=true; result:=true;
    end;
    if result then begin
      FreeAndNil(SearchTree); 
      result:=not Ask([Format('Заменено: %d.',[cnt]),'Повторить поиск с заменой ?'],true,'Поиск с заменой');
    end;
  end
  else begin
    result:=GF.SearchIdent(sf,aInfo,false);
    if result then TSearchTree.Init(sf);
  end;
  DelStack;
end;

procedure TEdGenFr.deSelPnlCngKey(Sender: TObject; var tb: TKeyBut);
begin
	AddStack('TEdGenFr.deSelPnlCngKey',Self);
	with tb do case Key of
  	K_Enter: begin
    	Caption:='Отметить'; Hint:=''; Part:=kmFile;
    end;
  	K_F10,K_Alt_Z: begin
    	Caption:=''; Hint:=''; Part:=kmNone;
    end;
  end;
  DelStack;
end;

// Открытие файла
procedure TEdGenFr.OpenMsg;
var ofn: TFileName;
begin
	AddStack('TEdGenFr.OpenMsg',Self);
  if Assigned(pDcmDef) then begin
    ofn:=GF.FileName; GF.OpenDcmStr(pDcmDef^); GF.FileName:=ofn; GF.AutoSize; FontGetAssign; MsgVers;
  end
  else mess_wait(['Загрузка описания документа'],OpenDcm,[FromServer],false);
  DelStack;
end;

procedure TEdGenFr.OpenDcm;
var ost: longint;
	fl: boolean;
begin
	ost:=AddStack('TEdGenFr.OpenDcm',Self);
  try
    fl:=true;
  	if Sender.Params[0] then
      if not TGenForm.LoadFromServer(GF.FileName,true) then begin
        mess_ok(['На центральном компьютере',
        	'отсутствует форма документа "'+FileNameExt(GF.FileName,'DCM')+'".']);
        fl:=false;
      end;
    if fl then begin
    	fl:=not Assigned(prEdGet); GF.OpenDcm(GF.FileName,fl,CurLeaf);
      GF.AutoSize; FontGetAssign; MsgVers;
      if fl then begin
      	TDWPrm.VarCreate(RDocPrm); TDWPrm.VarCreate(RDocpPrm);
      end;
    end;
  except
  	on E:EDcmFormError do begin
    	SetStack(ost);
      mess_ok(E.Message); 
    end;
  end;
  DelStack;
end;

// Сохранение файла
function TEdGenFr.SaveMsg;
begin
	AddStack('TEdGenFr.SaveMsg',Self);
	result:=mess_wait(['Сохранение описания документа'],SaveDcm,false);
  DelStack;
end;

procedure TEdGenFr.SaveDcm;
begin
	AddStack('TEdGenFr.SaveDcm',Self);
  GF.SaveCurLeaf; 
  if not GF.SaveDcm then Sender.Abort;
  MsgVers;
  DelStack;
end;

procedure TEdGenFr.MsgVers;
begin
  AddStack('TEdGenFr.MsgVers',Self);
  RbStatus1.SectRight[0]:=Format('Версия: %d(%d)',[GF.VersInfo.Vers,GF.VersInfo.NumSave]);
  DelStack;
end;

procedure TEdGenFr.FontProc;
var i: longint;
begin
	AddStack('TEdGenFr.FontProc',Self);
  if not lAfter then begin
    for i:=0 to GF.FontCount-1 do IncD(StrList,FontStr(i,true)+CRLF);
    DecLen(StrList,lCRLF);
    with TKeyLb do KeyStr:=ArrayAsList(
      [GetKeySt(K_Esc,'Выход')
      ,GetKeySt(K_Enter,K_F5)
      ,FontGetStr],CRLF);
    ProcKey:=FontGetProc; MouseDown:=FontMouseDown; MouseMove:=FontMouseMove; MouseUp:=FontMouseUp;
  end;
  DelStack;
end;

procedure TEdGenFr.PrmProc;
begin
	AddStack('TEdGenFr.PrmProc',Self);
  if not lAfter then begin
    with TKeyLb do KeyStr:=ArrayAsList(
      [GetKeySt(K_F3,'Сменить','Сменить номер')
      ,GetKeySt(K_F4,'Скопир.','Скопировать')
      ,GetKeySt(K_F5,'Редакт.','Редактировать')
      ,GetKeySt(K_F7,'Добав.','Добавить')
      ,GetKeySt(K_Ctrl_Up,'','Переместить выше')
      ,GetKeySt(K_Ctrl_Down,'','Переместить ниже')
      ,GetKeySt(K_F8,'Удалить')
      ],CRLF);
    ProcKey:=PrmKeyProc; MouseDown:=FontMouseDown; MouseMove:=PrmMouseMove; MouseUp:=PrmMouseUp;
  end;
  DelStack;
end;

procedure TEdGenFr.PnFillBeforeEnter(Sender: TObject);
begin
	AddStack('TEdGenFr.PnFillBeforeEnter',Self);
  inherited;
  KeyMenu1.DelLine(kmGFObj,K_F7); KeyLb1.SetButNoEval(true); KeyLb1.ReDrw;
  DelStack;
end;

procedure TEdGenFr.PnFillEnter(Sender: TObject);
begin
	AddStack('TEdGenFr.PnFillEnter',Self);
  inherited;
  GFRefresh:=true; EnblObj:=PnObj.Enabled; PnObj.Enabled:=false;
  DelStack;
end;

procedure TEdGenFr.PnFillBeforeExit(Sender: TObject);
begin
	AddStack('TEdGenFr.PnFillBeforeExit',Self);
  inherited;
  GFRefresh:=false;
  DelStack;
end;

procedure TEdGenFr.PnFillExit(Sender: TObject);
begin
	AddStack('TEdGenFr.PnFillExit',Self);
  inherited;
  KeyLb1.SetButNoEval(false); KeyLb1.ReDrw; KeyMenu1.InsLine(kmGFObj,K_F7);
  PnObj.Enabled:=EnblObj;
  DelStack;
end;

procedure TEdGenFr.PnFillSetWHMin(Sender: TObject);
var i,w,h: longint;
begin
	AddStack('TEdGenFr.PnFillSetWHMin',Self);
  inherited;
  with TPanelEdit(Sender) do begin
  	w:=0; h:=0;
    for i:=0 to ControlCount-1 do begin
    	Inc(w,Controls[i].Width); MaxSelf(h,Controls[i].Height);
    end;
    MaxWMin(w+8); MaxHMin(h+8);
  end;
  DelStack;
end;

procedure TEdGenFr.EColorChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
begin
	AddStack('TEdGenFr.EColorChange',Self);
  inherited;
  if GFRefresh then SetSpdBut;
  DelStack;
end;

// Выполнить обрамление
procedure TEdGenFr.FillGetClick(PaintButton: TPaintButton;
  Index: longint);
var tl: Byte;
	i: longint;
  v: TGFObj;
  bt: TFillList;
begin
	AddStack('TEdGenFr.FillGetClick',Self);
  inherited;
  bt:=TFillList(Index-1);
  tl:=GFTypeLine(IfThen(PaintButton.Down and (bt<>btNone) or (bt=btAll),byte(RGF['LnWidth'])+1),RGF['Color']);
  with GF do begin
    // Обрамить выделенные объекты
    for i:=0 to SelObjectCount-1 do begin
      v:=SelObjects[i];
      case bt of
        btTop:    v.LnTop   :=tl;
        btBottom: v.LnBottom:=tl;
        btLeft:   v.LnLeft  :=tl;
        btRight:  v.LnRight :=tl;
      else
        v.LnTop:=tl; v.LnBottom:=tl;
        v.LnLeft:=tl; v.LnRight:=tl;
      end;
      SelObjects[i]:=v; SelBringToFront(i);
    end;
    if SelObjectCount>0 then begin
      if bt in [btAll,btNone] then SetSpdBut;
	    PaintAll; Modified:=true;
    end;
  end;
  DelStack;
end;

// Текущее обрамление
procedure TEdGenFr.SetSpdBut;
var tl: Byte;
	lt,lb,ll,lr: boolean;
  i: longint;
  v: TGFObj;
begin
	AddStack('TEdGenFr.SetSpdBut',Self);
	tl:=GFTypeLine(RGF['LnWidth']+1,RGF['Color']);
  lt := GF.SelObjectCount=0; TFldEdit.SetReadOnly([EColor,ELnWidth],lt);
  // Нет обрамления
  if lt then begin
  	TSpdButGet.SetButDown(EVFill,0,false);
    TSpdButGet.SetButEnabled(EVFill,0,false);
  end
  // Обрамление объектов
  else begin
    TSpdButGet.SetButEnabled(EVFill,0,true);
    lt:=true; lb:=true; ll:=true; lr:=true;
    for i:=0 to GF.SelObjectCount-1 do begin
      v:=GF.SelObjects[i];
      if lt then lt := v.LnTop   =tl;
      if lb then lb := v.LnBottom=tl;
      if ll then ll := v.LnLeft  =tl;
      if lr then lr := v.LnRight =tl;
    end;
    TSpdButGet.SetButDown(EVFill,byte(btTop)+1,lt);
    TSpdButGet.SetButDown(EVFill,byte(btBottom)+1,lb);
    TSpdButGet.SetButDown(EVFill,byte(btLeft)+1,ll);
    TSpdButGet.SetButDown(EVFill,byte(btRight)+1,lr);
  end;
  DelStack;
end;

// Меню толщины линии
const
	lnwBord = 2;
	lnwLen = 50;

procedure TEdGenFr.LnWidthGetSizePaint(Sender: TObject; tf: TFldEdit;
  isList: Boolean; var Size: tagSIZE);
const lnwBord2 = lnwBord shl 1;
var ts: TSchem;
begin
	AddStack('TEdGenFr.LnWidthGetSizePaint',Self);
  WinSize(Size,lnwLen+lnwBord2,Mm10ToScr(MaxLineWidth)+lnwBord2); 
  if Pos(cMnCod,AnsiUpperCase(tf.Mask))>0 then with tf.Canvas do begin
    if SchemName(tf.Schem,ts) then Font.Assign(ts.Font1) else DefaultFont(Font);
    Inc(Size.cX,lnwBord+CanvasMaxW(tf.Canvas)*LenIntStr(MaxLineWidth));
    MaxSelf(Size.cY,tf.Canvas,true);
  end;
  DelStack;
end;

procedure TEdGenFr.LnWidthGetDrawItem(Sender: TObject; Canvas: TCanvas;
  const nRect: TRect; Index: longint; State: TOwnerDrawState; tf: TFldEdit;
  const Cod: String; isList: Boolean);
var i,j,k,cnt: longint;
begin
	AddStack('TEdGenFr.LnWidthGetDrawItem',Self);
  with Canvas do begin
    Font.Assign(tf.Font);
    if odSelected in State then begin
      Pen.Color:=clHighLightText; Brush.Color:=clHighLight; Font.Color:=clHighLightText;
    end
    else begin
      Pen.Color:=AColor[T16Colors(RGF['Color'])]; Brush.Color:=tf.Color1;
    end;
  	FillRect(nRect);
    if not(ogReadOnly in tf.Options) then begin
      cnt:=Int0(Cod); k:=nRect.Top+(nRect.Bottom-nRect.Top-CanvasMaxH(Canvas)) div 2;
      if cnt=0 then TextRect(nRect,nRect.Left+lnwBord,k,'Нет')
      else begin
        j:=lnwBord;
        if Pos(cMnCod,AnsiUpperCase(tf.Mask))>0 then begin
          TextRect(nRect,nRect.Left+lnwBord,k,TrimRight(Cod));
          Inc(j,lnwBord+CanvasMaxW(Canvas)*LenIntStr(MaxLineWidth));
        end;
        Brush.Color:=Pen.Color; cnt:=Mm10ToScr(cnt);
        i:=nRect.Top+(nRect.Bottom-nRect.Top-cnt+1) div 2;
        FillRect(Rect(j,i,j+lnwLen,i+cnt));
      end;
    end;
  end;
  DelStack;
end;

procedure TEdGenFr.PnGFResize(Sender: TObject);
begin
	AddStack('TEdGenFr.PnGFResize',Self);
  inherited;
	with PnGF do PnGF2.SetBounds(5,5,Width-10,Height-10);
  MsgRebuild(ScrlGF);
  DelStack;
end;

procedure TEdGenFr.APopupClick(Sender: TObject);
begin
	AddStack('TEdGenFr.APopupClick',Self);
  inherited;
  KeyLb1.ExecKey(NmToKey(copy(TMenuItem(Sender).Name,3,MaxInt)));
  DelStack;
end;

procedure TEdGenFr.GFAutoSize;
var fl: boolean;
  procedure OneMask(tf: TFldEdit; MinValue,MaxValue: longint);
  var result: string;
  begin
  	AddStack('TEdGenFr.GFAutoSize.OneMask',Self);
    result:=Format('%d,%d',[MinValue,MaxValue]);
    if fl then
	    if {max(2,}LenIntStr(SpinGetPrm(tf.Mask).MaxValue){)}
  	  <>{max(2,}LenIntStr(SpinGetPrm(result).MaxValue){)}
    		then fl:=false;
    tf.Mask:=result;
    DelStack;
  end;
begin
	AddStack('TEdGenFr.GFAutoSize',Self);
	// Установка пределов редактирования границ объектов
	fl:=true;
	OneMask(ELeft  ,0,GF.ColCount-1);
	OneMask(ERight ,1,GF.ColCount);
	OneMask(ETop   ,0,GF.RowCount-1);
	OneMask(EBottom,1,GF.RowCount);
  if not fl then MainRebuild;
	PnObjUpdate;
  DelStack;
end;

procedure TEdGenFr.GFSelectObjs;
var mustCF7,isCF7,mustF7,isF7,ll,lt,lr,lb: boolean;
  aFill: TArrStr;
  i: longint;
begin
	AddStack('TEdGenFr.GFSelectObjs',Self);
  with KeyLb1 do begin
    PnObjUpdate;
    if GF.SelObjectCount=0 then begin
      DelKey(K_All,'ObjSel');
      M_Enter.Visible:=false; M_F2.Visible:=false; M_F5.Visible:=false; M_F8.Visible:=false;
      DelKey(K_All,'ObjDiv');
      M_F7.Visible:=false; MDivObj.Visible:=false;
      DelKey(K_All,'ObjComb'); M_Ctrl_F7.Visible:=false; M_Shift_F7.Visible:=false; ReDrw;
      M_R2.Visible:=false;
		  PnFill.Enabled:=false; PnObj.Enabled:=false;
    end
    else begin
      if (oSelCnt<>1) and (GF.SelObjectCount=1) then begin
        SetKey(K_Enter,'','Редактирование содержимого объекта',ObjSelProc,'ObjSel',kmGFObj);
			  M_Enter.Visible:=true;
      end;
      if oSelCnt=0 then begin
        SetKey(K_F2,'Обрамление','Обрамление объектов',ObjSelProc,'ObjSel',kmGFObj);
				M_F2.Visible:=true;
        SetKey(K_F5,'Коррект.','Редактирование свойств объектов',ObjSelProc,'ObjSel',kmGFObj);
				M_F5.Visible:=true;
        SetKey(K_F8,'Удалить','Удаление объектов',ObjSelProc,'ObjSel',kmGFObj);
				M_F8.Visible:=true;
        PnFill.Enabled:=true; PnObj.Enabled:=true;
      end;
    end;
    if GF.SelObjectCount>0 then begin
      TGenForm.RectObjInit(rSO);
      for i:=0 to GF.SelObjectCount-1 do TGenForm.RectObjCalc(rSO,GF.SelObjects[i]);
      if GF.SelObjectCount>1 then begin
        RectObjFillInit(aFill,rSO);
        for i:=0 to GF.SelObjectCount-1 do RectObjFillCalc(aFill,rSO,GF.SelObjects[i]);
        mustCF7:=RectObjFillRectangle(aFill);
      end
      else mustCF7:=false;
      isCF7:=IsKeyBut(K_Ctrl_F7);
      ll := ogReadOnly in SLeft.Options;
      lt := ogReadOnly in STop.Options;
      lr := ogReadOnly in SRight.Options;
      lb := ogReadOnly in SBottom.Options;
      mustF7 := lr or lb or ll or lt; isF7:=IsKeyBut(K_F7);
      if mustCF7 and not isCF7 then begin
        SetKey(K_Ctrl_F7,'Объединить','Объединение объектов',ObjDivProc,'ObjComb',kmGFObj);
        SetKey(K_Shift_F7,'','Новые линии границ объектов',ObjDivProc,'ObjComb',kmGFObj);
        M_Ctrl_F7.Visible:=true; M_Shift_F7.Visible:=true;
      end
      else if not mustCF7 and isCF7 then begin
        DelKey(K_All,'ObjComb'); M_Ctrl_F7.Visible:=false; M_Shift_F7.Visible:=false;
      end;
      if mustF7 and not isF7 then begin
        SetKey(K_F7,'Разделить','Разделение объектов',ObjDivProc,'ObjDiv',kmGFObj);
        M_F7.Visible:=true; MDivObj.Visible:=true;
      end
      else if not mustF7 and isF7 then begin
        DelKey(K_All,'ObjDiv');
        M_F7.Visible:=false; MDivObj.Visible:=false;
      end;
      if lr then SetKey(K_Ctrl_Right,'','Разделить объекты справа',ObjDivProc,'ObjDiv',kmGFObj)
      else DelKey(K_Ctrl_Right,'ObjDiv');
      M_Ctrl_Right.Visible:=lr;
      if lb then SetKey(K_Ctrl_Down,'','Разделить объекты снизу',ObjDivProc,'ObjDiv',kmGFObj)
      else DelKey(K_Ctrl_Down,'ObjDiv');
      M_Ctrl_Down.Visible:=lb;
      if ll then SetKey(K_Ctrl_Left,'','Разделить объекты слева',ObjDivProc,'ObjDiv',kmGFObj)
      else DelKey(K_Ctrl_Left,'ObjDiv');
      M_Ctrl_Left.Visible:=ll;
      if lt then SetKey(K_Ctrl_Up,'','Разделить объекты сверху',ObjDivProc,'ObjDiv',kmGFObj)
      else DelKey(K_Ctrl_Up,'ObjDiv');
      M_Ctrl_Up.Visible:=lt;
    end;
    ClpBrdCanCopyPast; SetSpdBut; ReDrw;
  end;
  RbStatus1.SectLeft[IfThen(Assigned(PrEdGet),1,2)]:=IfThen(GF.SelObjectCount<>0,
  	StrNum(' Выделено объектов: ',GF.SelObjectCount));
  oSelCnt:=GF.SelObjectCount;
  DelStack;
end;

procedure TEdGenFr.RDocPrmDWTrans(Sender: TObject; var sTrans: String;
  lSave: Boolean);
var fl: boolean;
begin
	AddStack('TEdGenFr.RDocPrmDWTrans',Self);
  fl := Sender=RDocpPrm;
  if lSave then GF.awDat[fl]:=sTrans else sTrans:=GF.awDat[fl];
  DelStack;
end;

function TEdGenFr.RDocPrmDWCanDel(Sender: TObject; const VarName,MsgName: String): Boolean;
const ams: TGFSearchStr =
	('алгоритме формирования','алгоритме дополнительных действий','действиях для мыши',
  'текстах объектов','идентификаторах объектов','разделах объектов','колонках объектов',
  'окне ввода параметров','окне ввода данных','окне ввода для дополнительных действий');
var a: TGFSearchAInfo;
begin
	AddStack('TEdGenFr.RDocPrmDWCanDel',Self);
  result:=not GF.SearchIdent(VarName,a);
  if not result then meserr(IfThen(Sender=RDocPrm,'Данное','Параметр')+' "'+MsgName+'" используется в '
    +ams[a[low(a)].TypeObj]+'.');
  DelStack;
end;

procedure TEdGenFr.RDocPrmDWCngName(Sender: TObject; const OldName,
  NewName: String; var result: Boolean);
begin
	AddStack('TEdGenFr.RDocPrmDWCngName',Self);
 	if GF.ReplaceIdent(OldName,NewName)[gfsObjText]>0 then begin
    PnObjUpdate; Modified:=true;
  end;
  DelStack;
end;

procedure TEdGenFr.RDocPrmDWFldSeek(Sender: TObject; var a: TDWFldArrSeek;
  prAdd: TDWFldProcAdd);
begin
	AddStack('TEdGenFr.RDocPrmDWFldSeek',Self);
  PrAdd(a,GF.awDat[Sender=RDocpPrm]);
  DelStack;
end;

procedure TEdGenFr.RDocPrmDWVarValid(Sender: TObject; Proc: TProcVarValid;
  const r: TDWVidRec; var result: Boolean);
var i: longint;
	fl: boolean;
begin
	AddStack('TEdGenFr.RDocpPrmDWVarValid',Self);
  fl := Sender=RDocpPrm;
  for i:=low(aGFLtoW[fl]) to high(aGFLtoW[fl]) do
	  Proc(r,result,GF.awWin[aGFLtoW[fl,i]],FRup(aGFSearchName[aGFWtoS[aGFLtoW[fl,i]]]));
  DelStack;
end;

procedure TEdGenFr.RDocPrmDWArrSeek(Sender: TObject;
  var result: TDWArrSeekRec);
begin
	AddStack('TEdGenFr.RDocPrmDWArrSeek',Self);
  with result do begin
  	RecDef:=tDCM; PrFldDef:=TNone.RDocPrmFldDefProc; FldOrd:=fDCM; NoDat:=true;
  end;
  DelStack;
end;

procedure TEdGenFr.RDocPrmDWArrCodName(Sender: TObject; Qry: Tmulquery;
  var Cod,Name: String);
begin
	AddStack('TEdGenFr.RDocPrmDWArrCodName',Self);
  if Assigned(DcmArrCodNameProc) then DcmArrCodNameProc(TrimRight(Qry.Fields[0].AsString),Cod,Name);
  DelStack;
end;

procedure TEdGenFr.RDocPrmCalculate(Sender: TCustomRec; lApp: boolean);
var r: TRecDBDef;
  lUser: boolean;
  s: string;
begin
  AddStack('TEdGenFr.RDocPrmCalculate',Self);
  r:=pointer(Sender); lUser := r=RDocPrm;
  s:='Ошибка установки '+IfThen(lUser,'данных по документу','параметров документа')+': ';
  if empty(r[fFDTG]) then raise Exception.Create(s+'тип отсутствует');
  if lUser=empty(r[fUSERNAME]) then raise Exception.Create(
    s+'пользователь '+IfThen(lUser,'отсутствует','должен отсутствовать'));
  DelStack;
end;

function TEdGenFr.mgDefCod;
begin
	AddStack('TEdGenFr.mgDefCod',Self);
  result:=ReplVar(GF.VersInfo.MDFile,ExtractFileWithOutExt(GF.FileName));
  DelStack;
end;

function TEdGenFr.mgDefNSave;
begin
	AddStack('TEdGenFr.mgDefNSave',Self);
  result:=GF.VersInfo.MDNSave;
  DelStack;
end;

procedure TEdGenFr.mgHelp;
var n: byte;
begin
  AddStack('TEdGenFr.mgHelp',Self);
  n:=high(ht.Dat); SetLength(ht.Dat,n+2);
  HelpTblAddDcm(ht,n);
  DelStack;
end;

procedure TEdGenFr.mgOwnerSave;
var fnDcm,fnTmp: TFileName;
begin
	AddStack('TEdGenFr.mgOwnerSave',Self);
	fnDcm:=FullNameExe(GF.FileName,'DCM'); fnTmp:=FullNameExe(TmpFile,'DCM'); CopyFileOpt(fnDcm,fnTmp);
	with TModelGet(Sender) do begin
    GF.VersInfo.MDFile:=MDFile; GF.VersInfo.MDName:=MDName;
    CopyFrom(GF.VersInfo.MDPrim,MDPrim);
    GF.VersInfo.MDNSave:=NSave;
    if SaveMsg then CopyFileOpt(fnDcm,Path+MDFile);
  end;
  CopyFileOpt(fnTmp,fnDcm); DelFileAtr(fnTmp); Modified:=true;
  DelStack;
end;

procedure TEdGenFr.mgOwnerLoad;
var fnDcm,fnTmp: TFileName;
begin
	AddStack('TEdGenFr.mgOwnerLoad',Self);
	fnDcm:=FullNameExe(GF.FileName,'DCM'); fnTmp:=FullNameExe(TmpFile,'DCM'); CopyFileOpt(fnDcm,fnTmp);
	with TModelGet(Sender) do CopyFileOpt(Path+MDFile,fnDcm);
  if GFSaveDcm then UpdateDBDcm(fnDcm);
  OpenMsg; CopyFileOpt(fnTmp,fnDcm); DelFileAtr(fnTmp); Modified:=true;
  DelStack;
end;

procedure PrUsedArr(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
begin
  AddStack('FEdGenFr.PrUsedArr');
  with TGenForm(longint(av[0])) do begin
    OpenDcm(sr.Name);
    if not empty(VersInfo.MDFile) then StringListVar(av[1]).Add(VersInfo.MDFile);
  end;
  DelStack;
end;

procedure TEdGenFr.mgUsedArr;
var GF: TGenForm;
begin
	AddStack('TEdGenFr.mgUsedArr',Self);
  GF:=TGenForm.Create(Self);
  try
    GF.Visible:=false; GF.State:=gsDesign;
    MaskFilesProc(ExeDir+'*.DCM',PrUsedArr,[longint(GF),longint(lsUsed)]);
    GF.State:=gsDesign;
  finally
    GF.Free;
  end;
  DelStack;
end;

function TEdGenFr.EdFont;
begin
	AddStack('TEdGenFr.EdFont',Self);
  deFont.FrmCaption:='Редактирование шрифта';
  deFont.Param[0,deNoReadOnly]:=bStr[NoReadOnly];
  PFont.Assign(f); FontToRGF; deFont.NmProc.Text:=KeyStr; deFont.OnKpProcKey:=ProcKey;
  result:=deFont.Execute.Saved;
  if result then begin
    RGFToFont; f.Assign(PFont);
  end;
  DelStack;
end;

procedure TEdGenFr.FontToRGF;
begin
  AddStack('TEdGenFr.FontToRGF',Self);
  with PFont.Prop do begin
    RGF['Prim']:=Prim; RGF['AType']:=AType; RGF['Angle']:=Angle;
    case AType of
      fptNormal: begin
        RGF['OnlyDig']:=Dop.OnlyDig; RGF['RowBetween']:=Dop.RowBetween;
        RGF['WidthTextAll']:=Dop.WidthTextAll; RGF['OnWidth']:=Dop.OnWidth;
        RGF['ALine']:=Dop.ALine; RGF['PrcSpMin']:=Dop.PrcSpMin;
        RGF['ChrFill']:=Dop.ChrFill;
      end;
      fptSepstr: begin
        RGF['OnlyDig']:=Dop.sepstrOnlyDig;
        RGF['MMetrSep']:=Dop.MMetr; RGF['WidthMm']:=Dop.Width; RGF['HeightMm']:=Dop.Height;
      end;
      fptBarCode: RGF['Koef']:=Dop.Koef;
      fptQRCode: begin
        RGF['ECCLevel']:=aQRCode_ECCLevel[Dop.qrECCLevel].nm[1];
        RGF['Module']:=Dop.qrModule;
      end;
      fptPDF417: begin
        RGF['ECCLevel']:=Int2Str(Dop.pdf417ECCLevel);
        RGF['Module']:=Dop.pdf417Module;
        RGF['RowHeight']:=Dop.pdf417RowHeight;
      end;
    end;
  end;
  DelStack;
end;

procedure TEdGenFr.RGFToFont;
begin
  AddStack('TEdGenFr.RGFToFont',Self);
  with PFont.Prop do begin
    Prim:=RGF['Prim']; AType:=RGF['AType']; Angle:=RGF['Angle'];
    case AType of
      fptNormal: begin
        Dop.OnlyDig:=RGF['OnlyDig']; Dop.RowBetween:=RGF['RowBetween'];
        Dop.WidthTextAll:=RGF['WidthTextAll']; Dop.OnWidth:=RGF['OnWidth']; Dop.ALine:=RGF['ALine'];
        Dop.PrcSpMin:=RGF['PrcSpMin']; Dop.ChrFill:=StrToChar(RGF['ChrFill']);
      end;
      fptSepstr: begin
		    Dop.sepstrOnlyDig:=RGF['OnlyDig']; Dop.MMetr:=RGF['MMetrSep'];
        Dop.Width:=RGF['WidthMm']; Dop.Height:=RGF['HeightMm'];
      end;
      fptBarCode: Dop.Koef:=RGF['Koef'];
      fptQRCode: begin
        Dop.qrECCLevel:=QRCode_ECCLevel; Dop.qrModule:=RGF['Module'];
      end;
      fptPDF417: begin
        Dop.pdf417ECCLevel:=TPDF417_EccLevel(Int0(RGF['ECCLevel']));
        Dop.pdf417Module:=RGF['Module'];
        Dop.pdf417RowHeight:=RGF['RowHeight'];
      end;
    end;
  end;
  DelStack;
end;

class procedure TEdGenFr.UpdateNumSave;
begin
  AddStack('TEdGenFr.UpdateNumSave');
  LoadWait;
  if DBDcm.ActiveNoNil then
    if DBDcm.Seek(DBDcm.TblFldName(fDCM)+'='+
    QQs(AnsiUpperCase(FileNameExt(IfThen(DBFName='',AFileName,DBFName),'DCM'))),'',[seekNoMemo])
    then with EdGenFr.GF do begin
      FileName:=AFileName; OpenDcm(FileName,false); VersInfo.NumSave:=DBDcm['NUMSAVE']; SaveDcm;
    end;
  DelStack;
end;

class procedure TEdGenFr.LoadWait;
begin
	AddStack('TEdGenFr.LoadWait');
	if not Assigned(EdGenFr) then mess_wait(['Загрузка формы описания документа'],TNone.FLoadWait,false);
  DelStack;
end;

procedure TEdGenFr.SetModified;
begin
  AddStack('TEdGenFr.SetModified',Self);
  FModified:=Value; ModFromLastAutoSave:=Value; RbStatus1.SectLeft[0]:=IfThen(Value,'*',' ');
  DelStack;
end;

procedure PrLastTmp(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
begin
  AddStack('FEdGenFr.PrLastTmp');
  MaxSelf(LongIntVar(av[0])^,Int0(Copy(sr.Name,longint(av[1]),LenTmpNum)));
  DelStack;
end;

procedure TEdGenFr.tmAutoSaveTimer;
var ofn,pref: TFileName;
  n: longint;
  fl: boolean;
begin
  AddStack('TEdGenFr.tmAutoSaveTimer',Self);
  tmAutoSave.Enabled:=false;
  if ModFromLastAutoSave then begin
    ModFromLastAutoSave:=false; pref:=FullNameExe(GF.FileName,'DCM')+'.'; n:=0;
    MaskFilesProc(pref+StringOfChar('?',LenTmpNum)+'.BDC',PrLastTmp,
      [Longint(@n),Length(ExtractFileName(pref))+1]);
    ofn:=GF.FileName; GF.FileName:=StrNum(pref,n+1,LenTmpNum)+'.BDC'; fl:=SaveMsg; GF.FileName:=ofn;
  end
  else fl:=true;
  tmAutoSave.Enabled:=fl;
  DelStack;
end;

class function TEdGenFr.EdFormEd;
var fGF: TEdGenFr;
begin
  AddStack('TEdGenFr.EdFormEd');
  if defrmCrt in Opt then begin
  	fGF:=nil; CreateForm(TEdGenFr,fGF);
  end
  else begin
  	CreateForm(TEdGenFr,fEdGF); fGF:=fEdGF;
  end;
  try
    fGF.CheckFml:=not(defrmCrt in Opt);
    result:=fGF.DcmDesign('__DEDCM','Редактирование формы',EdGet,'',defrmSetMod in Opt,EdSayProc,pDcmDef);
  finally
  	if defrmCrt in Opt then fGF.Free else fGF.NoLimit:=false;
  end;
  DelStack;
end;

function TEdGenFr.ChangeDat;
var fl: boolean;
  a: TArrBoolRecDBDef;
begin
  AddStack('TEdGenFr.ChangeDat',Self);
  if DBMain=nil then result:=true
  else begin
    result:=IfThenTrnsStart(lTransaction,[tDOCPRM]);
    if result then try
      a[false]:=RDocPrm; a[true]:=RDocpPrm;
      for fl:=false to true do begin
        if not RecDB.ChangeDat(a[fl],ao[fl],GF.awDat[fl],
        BrackNoEmp(whereDtg)+sAND+a[fl].TblFldName(fUSERNAME)+aqEq[fl]+QQs,false) then begin
          result:=false; break;
        end;
      end;
      if lTransaction then TrnsEnd(IfThen(result,trnsCommit));
    except
      if lTransaction then TrnsEnd;
      raise
    end;
  end;
  DelStack;
end;

procedure TEdGenFr.WMGFSeekObj;
var ls: TList;
	pv: PGFObj;
begin
	AddStack('TEdGenFr.WMGFSeekObj',Self);
  if Visible then begin
    pv:=GF.PFillObj(Message.NumObj); GF.ClearAllSelection; ls:=TList.Create;
    try
      ls.Add(pv); GF.SelectObjs(ls,true);
    finally
      ls.Free;
    end;
    if not(pv.TypeObj in [toGet,toSay]) and (Message.TypeObj=gfsObjText) then KeyLb1.ExecKey(K_Enter);
    Message.Result:=1;
  end;
  DelStack;
end;

procedure TEdGenFr.WMGFCngObj;
begin
  AddStack('TEdGenFr.WMGFCngObj',Self);
  PnObjUpdate; Modified:=true;
  DelStack;
end;

procedure TEdGenFr.deNewLinePnlCngKey(Sender: TObject; var tb: TKeyBut);
begin
	AddStack('TEdGenFr.deNewLinePnlCngKey',Self);
  with tb do case Key of
    K_F10,K_Alt_Z: Caption:='';
    K_Enter: begin
    	Caption:='Установить'; Hint:='Установить новые линии границ объектов'; Part:=kmFile;
    end;
  end;
  DelStack;
end;

procedure TEdGenFr.deNewLineFrmShow(Sender: TObject);
var tf: TFldEdit;
  lX,lY: boolean;
  s: string;
  i: longint;
  v: TGFObj;
begin
	AddStack('TEdGenFr.deNewLineFrmShow',Self);
  lX:=true; lY:=true;
  for i:=0 to GF.SelObjectCount-1 do begin
    v:=GF.SelObjects[i];
    if (v.Left>rSO.Left) or (v.Right<rSO.Right) then lX:=false;
    if (v.Top>rSO.Top) or (v.Bottom<rSO.Bottom) then lY:=false;
  end;
  tf:=deNewLine.FldEdit['NewLine']; s:=tf.VarValue;
  TBoolMultiGet.ItemReadOnly(tf,0,lX);
  TBoolMultiGet.ItemReadOnly(tf,1,lY);
  if lX then begin
    SetByte(s,1,false); SetByte(s,2,true);
  end
  else if lY then begin
    SetByte(s,1,true); SetByte(s,2,false);
  end;
  tf.VarValue:=s;
  DelStack;
end;

function TEdGenFr.deNewLinePnlValid(Sender: TObject): Boolean;
var a: TArrBoolSet;
	offs: Word;
  pv: PGFObj;
  procedure aSet(crd: longint);
  begin
    AddStack('TEdGenFr.deNewLinePnlValid.aSet',Self);
    Dec(crd,offs);
    if InRange(crd,low(a),high(a)) then Include(a[crd],pv.Selected);
    DelStack;
  end;
var s: string;
  i,j,k: longint;
begin
  AddStack('TEdGenFr.deNewLinePnlValid',Self);
  result:=false; s:=RGF['NewLine'];
  if GetByte(s,1) then begin
  	offs:=rSO.Left+1; i:=rSO.Right-offs; SetLength(a,i);
    if i>0 then ZeroMemory(@a[0],i*SizeOf(a[0]));
    for i:=0 to GF.ObjectCount-1 do begin
      pv:=GF.PObjects[i]; aSet(pv.Left); aSet(pv.Right);
    end;
    for i:=low(a) to high(a) do if (false in a[i]) and (true in a[i]) then begin
    	result:=true; GF.IncColCount; k:=offs+i;
      for j:=0 to GF.ObjectCount-1 do begin
        pv:=GF.PObjects[j];
        if (pv.Left>=k) and not(pv.Selected and (pv.Left=k)) then Inc(pv.Left);
        if (pv.Right>=k) and not(pv.Selected and (pv.Right=k)) then Inc(pv.Right);
      end;
      Inc(offs);
    end;
  end;
  if GetByte(s,2) then begin
  	offs:=rSO.Top+1; i:=rSO.Bottom-offs; SetLength(a,i);
    if i>0 then ZeroMemory(@a[0],i*SizeOf(a[0]));
    for i:=0 to GF.ObjectCount-1 do begin
      pv:=GF.PObjects[i]; aSet(pv.Top); aSet(pv.Bottom);
    end;
    for i:=low(a) to high(a) do if (false in a[i]) and (true in a[i]) then begin
    	result:=true; GF.IncRowCount; k:=offs+i;
      for j:=0 to GF.ObjectCount-1 do begin
        pv:=GF.PObjects[j];
        if (pv.Top>=k) and not(pv.Selected and (pv.Top=k)) then Inc(pv.Top);
        if (pv.Bottom>=k) and not(pv.Selected and (pv.Bottom=k)) then Inc(pv.Bottom);
      end;
      Inc(offs);
    end;
  end;
  if result then begin
	  GF.AutoSize; Modified:=true;
  end;
  result:=true;
  DelStack;
end;

procedure TEdGenFr.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  AddStack('TEdGenFr.FormKeyDown',Self);
  inherited;
  if (ssShift in Shift) and (ssCtrl in Shift) and (GetKeyCod(Key,[ssCtrl]) in SelObjsList) then begin
    Shift:=[ssCtrl]; KeyExtend:=true;
  end;
  KeyLb1.FormKeyDown(Sender,Key,Shift); KeyExtend:=false;
  DelStack;
end;

procedure TEdGenFr.DisposeClpBrd;
begin
  AddStack('TEdGenFr.DisposeClpBrd',Self);
  if Assigned(PClpBrd) then begin
    Dispose(PClpBrd); PClpBrd:=nil;
  end;
  DelStack;
end;

procedure TEdGenFr.WMChangeCBChain;
begin
  AddStack('TEdGenFr.WMChangeCBChain',Self);
  inherited;
  TClipboardBuf.ViewerChangeCBChain(ClpBrdViewer,Msg);
  DelStack;
end;

procedure TEdGenFr.WMDrawClipboard;
begin
  AddStack('TEdGenFr.WMDrawClipboard',Self);
  inherited;
  try
    ClpBrdCanPast;
  finally
    TClipboardBuf.ViewerDrawClipboard(ClpBrdViewer);
  end;
  DelStack;
end;

procedure TEdGenFr.FontAdd;
begin
  AddStack('TEdGenFr.FontAdd',Self);
  GF.FontAdd(PFont); FontGet.Items.Add(FontStr(GF.FontCount-1,false));
  DelStack;
end;

procedure TEdGenFr.SetClpBrdFont;
var sFont,sProp: string;
  onf: byte;
begin
  AddStack('TEdGenFr.SetClpBrdFont',Self);
  onf:=pv.Font;
  with PClpBrd.aFont[onf] do begin
    sFont:=DefFontToStr(Font); sProp:=GFPackFontPropToStr(Prop);
  end;
  pv.Font:=0;
  while pv.Font<GF.FontCount do with GF.Fonts[pv.Font] do
    if (FontToStr(Font)=sFont) and (GFPackFontPropToStr(Prop)=sProp) then break else Inc(pv.Font);
  if pv.Font=GF.FontCount then with PClpBrd.aFont[onf] do begin
    DefFontToFont(Font,PFont.Font); PFont.Prop:=Prop; FontAdd;
  end;
  DelStack;
end;

function TEdGenFr.QRCode_ECCLevel;
var l,h: TQRCode_ECCLevel;
  fl: boolean;
begin
  AddStack('TEdGenFr.QRCode_ECCLevel',Self);
  fl:=true; l:=low(aQRCode_ECCLevel); h:=high(aQRCode_ECCLevel); result:=l;
  while result<=h do
    if aQRCode_ECCLevel[result].nm[1]=RGF['ECCLevel'] then begin
      fl:=false; break;
    end
    else Inc(result);
  if fl then result:=l;
  DelStack;
end;

{ TClipboardBufObj }
constructor TClipboardBufObj.CreateRead;
var fl: boolean;
begin
  AddStack('TClipboardBufObj.CreateRead');
  inherited CreateRead(cbrdGFObj,ClpBrdLastVers);
  if Active then begin
    if Vers<2 then fl:=true
    else fl:=not((Read(stInteger)=lDefFont) and (Read(stInteger)=lGFPackFontProp));
    if fl then ErrorMessage:=ClipBoardErrorMessage(cbrdGFObj);
  end;
  DelStack;
end;

{ TNone }
class procedure TNone.PrMove;
var prm: TGFParamItem;
begin
	AddStack('TNone.PrMove');
  with GFPrm do begin
  	prm:=aPrm[ni]; aPrm[ni]:=aPrm[oi]; aPrm[oi]:=prm;
    if oi=nPrm then nPrm:=ni
    else if ni=nPrm then nPrm:=oi;
  end;
  DelStack;
end;

class function TNone.PrmCheck;
begin
	AddStack('TNone.PrmCheck');
  result:=InRange(Int0(TFldEdit(Sender).Value),1,Length(GFPrm.aPrm));
  DelStack;
end;

class procedure TNone.FLoadWait;
begin
	AddStack('TNone.FLoadWait');
	CreateForm(TEdGenFr,EdGenFr);
  DelStack;
end;

class procedure TNone.RDocPrmFldDefProc;
var fl: boolean;
begin
  AddStack('TNone.RDocPrmFldDefProc');
  fl := Sender=EdGenFr.RDocpPrm;
  if lSave then begin
  	aGF.awDat[fl]:=s; aGF.SaveDcm;
  end
  else begin
    if not Assigned(aGF) then begin
      aGF:=TGenForm.Create(Application.MainForm); aGF.Parent:=Application.MainForm;
    end;
	  aGF.OpenDcm(TrimRight(Qry.Fields[0].AsString)); s:=aGF.awDat[fl];
  end;
  DelStack;
end;

function GFEdFontProc(var f: TGFPackFont; const KeyStr: string = ''; ProcKey: TKeyProc = nil): boolean;
begin
  AddStack('FEdGenFr.GFEdFontProc');
  TEdGenFr.LoadWait; result:=EdGenFr.EdFont(f,false,KeyStr,ProcKey);
  DelStack;
end;

function GFEdCreate: TGenForm;
begin
  AddStack('FEdGenFr.GFEdCreate');
  CreateForm(TEdGenFr,fEdGF); result:=fEdGF.GF;
  DelStack;
end;

procedure ModelGetProc(Before: boolean; var lCreate: boolean);
begin
  AddStack('FEdGenFr.ModelGetProc');
  if Before then TEdGenFr.LoadWait;
  DelStack;
end;

procedure LogTrnsValProc(var Prm: TLogTrnsValPrm);
var i: longint;
  GF: TGenForm;
  dw: TDataWin;
  s: string;
begin
  AddStack('FEdGenFr.LogTrnsValProc');
  with Prm do
    if LogEqual(Prm,tDOCPRM,fFDTG) then begin
      TrimRightSelf(val);
      if not TStrStrList.Create(TStrCustomList(lsDcmPrim)).IgnoreFindAdd(val,i) then
        if FileExists(ExeDir+val+'.DCM') then begin
          GF:=TGenForm.Create(Application.MainForm); dw:=TDataWin.aGet;
          try
            GF.Parent:=Application.MainForm; GF.State:=gsDesign; GF.OpenDcm(val,false);
            dw.LoadFromStr(GF.awWin[gfwDat]); lsDcmPrim.Value[i]:=dw.Zgl;
          finally
            DataWinFree; GF.Free;
          end;
        end;
      s:=lsDcmPrim.Value[i];
      if s<>'' then begin
        IncD(val,'('+TransPrim(s)+')'); lBreak:=true;
      end;
    end
    else if LogEqual(Prm,tDCM,fDcmDCM) then TDcmLogCompare.Execute(Prm)
  ;DelStack;
end;

initialization
	AddStack('FEdGenFr.initialization');
  GenForm.GFEdFontProc:=GFEdFontProc; GenForm.GFEdCreate:=GFEdCreate;
  SetPrim(tDOCPRM,'Параметры документов');
  AddFrom(ModelGetProc);
  LogTrnsValProcAdd(LogTrnsValProc);
  DelStack;
finalization
  AddStack('FEdGenFr.finalization');
  lsDcmPrim.Free;
  DelStack;
end.
