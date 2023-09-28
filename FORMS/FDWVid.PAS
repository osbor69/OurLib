unit FDWVid;

interface

{$I LIBTEST}
uses
  Windows, Messages, Classes, Controls, Forms, ExtCtrls, Grids, Menus,
  MyTypes, Schem, FRMEMPTY, PnlEdit, Keylb, Fpanel, StrBrowl, FFldedit, Codegets, KeyMenu, ButGet,
    DefEdit, ChkGets, PaintCtl, RecVal, Recdb, MenuGet, MemoGet, BtTxtGet;

type
  TDWVidProcOper = (dwvidCreate,dwvidShow,dwvidCng,dwvidRead,dwvidWrite);

  TDWVidCngRec = record
    tf: TFldEdit;
    FromShow: boolean;
  end;

  TDWVidUsedProc = procedure(var result: boolean; const r: TDWVidRec;
    const a: array of string; const av: array of variant);

  TDWButMode = set of (dwbPrefix,dwbShortType,dwbBrackets);

  TDWVid = class(TFormEmp)
    Rec: TRecVal;
    KeyMenu1: TKeyMenu;
    pn1: TRbPanel;
    PnLs: TRbPanel;
    LsVar: TStringBrowl;
    PnEd: TPanelEdit;
    EName: TFldEdit;
    ECod: TFldEdit;
    EType: TFldEdit;
    EValue: TFldEdit;
    EPrim: TFldEdit;
    RbStatus1: TRbStatus;
    ArrGet: TButGet;
    RecArr: TRecDBDef;
    EDop: TFldEdit;
    DopGet: TButGet;
    ESvType: TFldEdit;
    pnFill: TRbPanel;
    EFillType: TFldEdit;
    EFillChr: TFldEdit;
    FillGet: TRadioGet;
    ELen: TFldEdit;
    EDec: TFldEdit;
    EDDatType: TFldEdit;
    EDDatD2: TFldEdit;
    ESel: TFldEdit;
    ESelType: TFldEdit;
    ManyGet: TButGet;
    function LsVarCalcZn(Sender: TObject; ACol: longint): String;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    procedure LsVarEnter(Sender: TObject);
    procedure LsVarExit(Sender: TObject);
    function PnEdValid(Sender: TObject): Boolean;
    procedure ETypeChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    procedure ETypeExit(Sender: TObject);
    function ECodCheck(Sender: TObject): Boolean;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function ENameCheck(Sender: TObject): Boolean;
    function ArrGetClick(Sender: TObject; lEval: Boolean): String;
    procedure RecArrDWTrans(Sender: TObject; var sTrans: String;
      lSave: Boolean);
    procedure PnEdEscape(Sender: TObject; var Action: TCloseAction);
    procedure PnEdExitType(Sender: TObject; ExitType: TPEExitType);
    procedure ESvTypeExit(Sender: TObject);
    procedure ELenExit(Sender: TObject);
    function ELenCheck(Sender: TObject): Boolean;
    procedure ESvTypeChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure LsVarDrawCell(Sender: TObject; ACol,ARow: longint;
      Rect: TRect; State: TGridDrawState);
    procedure LsVarSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    function EDDatD2Check(Sender: TObject): Boolean;
    procedure EChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    function ManyGetClick(Sender: TObject; lEval: Boolean): String;
  private
    { Private declarations }
    lsNew,LsSelV2N: TStringList;
    aOld: TArrStr;
    LenType,RowBeforeApp,oRow,ARow,lAvailable,lNeed: longint;
    flMove,EnterSel: boolean;
    pWhere,PClpBrd: PString;
    aFld: array[TVarParam] of TFldEdit;
    aTypeGet: array[TDWSaveType] of TMenuGet;
    aUsed: TArrBoolSet;
    aSelN2V: TArrInt;
    ClpBrdViewer: HWND;
    PrmUser: pointer;
    function OldDef: string;
    function NewDef: string;
    procedure FProc(Oper: TDWVidProcOper; Prm: pointer = nil);
		procedure PnEdRead(ARow: longint = NegDef);
		procedure Move(oi,ni: longint);
		procedure PrMove(oi,ni: longint; const av: array of variant);
    function nOld(i: longint): longint;
    function IsOld: boolean;
		procedure CalcMem;
    procedure DelStr;
		function DWVidRecDef: TDWVidRec;
		function CodList: TDWVidCodList;
		function aCodGetListOwner(Sender: TObject; SpdBut: TPaintButton;
  		const RectList: TRect; PozList: TPozList): boolean;
		procedure aCodGetDrawItem(Control: TWinControl; Index: longint;
	    Rect: TRect; State: TOwnerDrawState);
		procedure SetF3;
		procedure TypeCng;
		procedure CodCng;
		procedure LenDecCng;
		procedure LsVarFill(nRow: longint);
		procedure ListKeyProc(key: longint; tw: TWinControl);
  	function ListResult(Sender: TObject; lr: TListF2Result): string;
    procedure FCodManyStr(var a: TArrStr);
    procedure ClpBrdCanPast;
    procedure DisposeClpBrd;
    procedure TimerMouse(Sender: TObject);
    procedure LsVarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
    procedure LsVarMouseMove(Sender: TObject; Shift: TShiftState; X,Y: longint);
    procedure LsVarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
		procedure WMSchem(var msg: TWMSchem); message WM_SCHEM;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
    procedure WMChangeCBChain(var Msg: TWMChangeCBChain); message WM_CHANGECBCHAIN;
    procedure WMDrawClipboard(var Msg: TWMDrawClipboard); message WM_DRAWCLIPBOARD;
  public
    { Public declarations }
    RecD: TRecDBDef;
    aCodGet: array[TDWVidCodList] of TCustomGet;
		class procedure ButGetPaint(Sender: TObject; const ARect: TRect; rdb: TRecDBDef;
    	Mode: TDWButMode = [dwbPrefix,dwbBrackets]);
		class function NmForm(rdb: TRecDBDef = nil; lRestCurForm: boolean = true): TDWVid;
		class function CurForm: TDWVid;
		function NmFormFree: boolean;
		class function ConvertToFix(rdb: TRecDBDef; var Def: string;
    	lAddChr: boolean = false): boolean;
		class procedure ArrRdbEvents(rdb: TRecDbDef);
		class procedure PrnLsAdd(RecD: TRecDBDef; lsPrn: TStringList; const Def: string);
    function PrUsed(ct: TDWVidCodList; Proc: TDWVidUsedProc; const cav: array of variant): boolean;
    function CodCheck(AType: TDWFldType; const Cod: string; ct: TDWVidCodList): boolean;
    function Edit2Rec: TDWVidRec;
  end;

  TDatLogCompare = class(TCustomLogCompare)
  public
    class function ListCreate(pv: pointer; const Value: string; lNew: boolean): pointer; override;
    class procedure ListDestroy(pv,ls: pointer); override;
    class function GetCount(pv,ls: pointer): longint; override;
    class procedure GetItem(var Prm: TLogTrnsValPrm; pv,lso,lsn: pointer; no,nn: longint; tp: TLogCompareItemList); override;
    class procedure Execute(var Prm: TLogTrnsValPrm; r: TRecDBDef); overload;
  end;

const
  ArrvVName = 'Arrv';
  DWVidNameLen = 10;
  aDWVidFormChr: array[TDWVidForm] of char = ('N','A','F');
	aFixTypeCod: array[TDWSaveType,TDWFldType] of TDWVidCodList =
		((dwcNoFix ,dwcNoFix   ,dwcNoFix  ,dwcNoFix ,dwcNoFixMemo,dwcNoFixMemo,dwcNoFix ,dwcNoFix ,dwcNoFix)
		,(dwcFixStr,dwcFixFloat,dwcFixDate,dwcFixStr,dwcFixMemo  ,dwcFixArray ,dwcFixStr,dwcFixSel,dwcMany )
		,(dwcDyn   ,dwcDyn     ,dwcDyn    ,dwcDyn   ,dwcDyn      ,dwcDyn      ,dwcDyn   ,dwcDyn   ,dwcDyn  )
    );
  aDWVidBeg: TDWVidCodStr = ('',sDefMemo,sFix,sFix,sFix,sFixMemo,sArray,'',sFixSel,'');

var deArrDopPrm: TDefEdit;
  rArrDopPrm: TRecVal;
  CanChangeDat: boolean = true;
  DWVidProc: procedure(Sender: TDWVid; Oper: TDWVidProcOper; Prm: pointer; var PrmUser: pointer);
  DWFldValidProc: procedure(g: TCustomGet; const ap: TDEPrmStr; const dwInf: TDWVidRec;
    var nFldFocus: TDEPrmList; var nVarFocus: TVarParam; var amsg: TArrStr);
  DWChangeDatProc: procedure(Sender: TObject; rdb: TRecDBDef; const oldDef,newDef,where: string);
  DWSelGetSort1More2: procedure(g1,g2: TCustomGet; var result: boolean);
  DWVidFldVisible: procedure(rdb: TRecDBDef; const nmf: string; var result: boolean);

function ArrvCodeGet: TCodeGet;
function ArrFixGet: TCodeGet;
procedure DWFldValid(const ap: TDEPrmStr; const dwInf: TDWVidRec;
  var nFldFocus: TDEPrmList; var nVarFocus: TVarParam; var result: boolean;
  g: TCustomGet; const Capt: string = ''; ProcName: TProcVarValidName = nil);

implementation

{$R *.DFM}

uses SysUtils,Graphics,StdCtrls,Math,DB,StrUtils,
  My_pr,Askp,FStat,ComboGet,BufFile,DateGet,FDWPrm,FrmPswd,Shifr,DDProc,MulQry,ListF2;

type
  TArrVidRec = array[boolean] of PDWVidRec;

  TArrArrVidRec = array of TArrVidRec;

  TArrVidRec1 = array of record
  	Inf: TArrVidRec;
    lNm: boolean;
  end;

  TCngDatMemo = class
  private
    Owner: TCustomRec;
    af: TArrStr;
    lf: longint;
    anf: TFldMemoAttrArrInt;
    lnf: TFldMemoAttrInt;
    aa: array of TCngDatMemo;
    procedure Add(const nmf,ka: string; fa: TFldMemoAttr);
    procedure FillGK(var adelgk: TFldMemoAttrArrStr; var ldelgk: TFldMemoAttrInt; const tbl,where: string);
  public
    constructor Create(AOwner: TCustomRec; MaxCnt: longint);
    destructor Destroy; override;
  end;

  TNone = class
  private
    class procedure PrCngDat(Sender: TAsk);
		class function RDBArrDWCanDel(Sender: TObject; const VarName,MsgName: String): Boolean;
    class procedure RDBArrDWCngName(Sender: TObject; const OldName,NewName: String;
    	var result: Boolean);
    class procedure RDBArrDWVarValid(Sender: TObject; Proc: TProcVarValid;
      const r: TDWVidRec; var result: Boolean);
    class function ArrDopEdit(Sender: TObject; lEval: Boolean): String;
		class procedure deArrDopPrmFldChange(Sender: TObject; const OldVal: variant; FromShow: boolean);
		class procedure ArrFldInfo(Sender: TObject; const r: TDWVidRec; var FldInfo: TDWFldInfo);
    class function ArrvCodeGetTransSeek(Sender: TObject; tf: TFldEdit;
      const Value: String; Size: longint; lSQL: Boolean): String;
  end;

const aFill: array[TDWFillList] of string = ('справа','слева');
  ClpBrdLastVers = 1;

var aForm: array[TDWVidForm] of TDWVid;
  nForm: TDWVidForm = dwfNormal;
  FArrvCodeGet,FArrFixGet: TCodeGet;

function FArrCodeGet(var cg: TCodeGet; const vn: string): TCodeGet;
begin
  AddStack('FDWVid.FArrCodeGet');
  if not Assigned(cg) then begin
  	cg:=TCodeGet.Create(Application.MainForm);
    with cg,TNone do begin
      VName:=vn; FieldsCode:=fARRV; FieldsName:=fUPNAME; TrimLeft:=true;
      MulPar.Values[sTABLE]:=tARRV; MulPar.Values[sWHERE]:=fARRV+qCod_C;
      OnFormIBList:=ArrvCodeGetFormIBList; OnAfterList:=ArrvCodeGetAfterList;
      OnTransSeek:=ArrvCodeGetTransSeek;
    end;
  end;
  result:=cg;
  DelStack;
end;

function ArrvCodeGet;
begin
  AddStack('FDWVid.ArrvCodeGet');
  result:=FArrCodeGet(FArrvCodeGet,ArrvVName);
  DelStack;
end;

function ArrFixGet;
begin
	AddStack('FDWVid.ArrFixGet');
  result:=FArrCodeGet(FArrFixGet,'DWVidArrFix');
  DelStack;
end;

procedure Fld1(tf: TFldEdit; GetClass: TCustomGetClass; const vn,m: string; l: longint = 0);
var ov: variant;
	v: string;
begin
  AddStack('FDWVid.Fld1');
  v:=GetClass.ClassName;
  with tf do if (Vid<>v) or (VName<>vn) or (Mask<>m) or (MaxLength<>l) then begin
    ov:=VarValue; SetRedraw(tf); AssignGet(v,vn); Mask:=m; MaxLength:=l;
    VarValue:=ov; SetRedraw(tf,rdrwSet);
  end;
  DelStack;
end;

function CompareType(rdb: TRecDBDef; NumField: longint; NumCod: TDWVidCodList): boolean;
var setTyp: set of TFieldType;
begin
  AddStack('FDWVid.CompareType');
  if AnsiStartsText(rdb.FixSt(aDWVidBeg[NumCod]),rdb.FieldName[NumField]) then begin
    case NumCod of
      dwcFixStr: setTyp:=[ftString];
      dwcFixFloat: setTyp:=[ftSmallint,ftInteger,ftWord,ftFloat,ftCurrency,ftBCD,ftAutoInc,ftLargeint];
      dwcFixDate: setTyp:=[ftDate,ftTime,ftDateTime];
    else setTyp:=[low(TFieldType)..high(TFieldType)];
    end;
    result := rdb.Field[NumField].Info.DataType in setTyp;
  end
  else result:=false;
  DelStack;
end;

function ChangeDat(rdb: TRecDBDef; const oldDef,newDef,where: string;
  lTransaction: boolean = true; WhereProc: TChangeDatWhereProc = nil;
  const DDatFieldCodValue: string = ''): boolean;
begin
  AddStack('FDWVid.ChangeDat');
  if CanChangeDat and (newDef<>oldDef)
  then result:=mess_wait(['Корректировка данных'],TNone.PrCngDat,
    [LongInt(rdb),oldDef,newDef,where,lTransaction,Longint(@WhereProc),DDatFieldCodValue],
    true,rdb.DWName)
  else result:=true;
  DelStack;
end;

{ TDWVid }
procedure TDWVid.FormCreate(Sender: TObject);
const aSelType: array[TSelType] of string = ('строка','целое');
var i: longint;
  j: TDWVidCodList;
  g: TCustomGet;
  sv: TDWSaveType;
begin
	AddStack('TDWVid.FormCreate',Self);
  lsNew:=TStringList.Create; RowBeforeApp:=-1; flMove:=false;
  RbStatus1.SectRight.Add('');
  if nForm<>dwfArray then RbStatus1.SectRight.Add('');
  g:=TSimpleGet.CreateOne; i:=1;
  for j:=low(aCodGet) to high(aCodGet) do
    if j=dwcMany then aCodGet[j]:=ManyGet
    else if (aDWVidBeg[j]<>'') and (nForm<>dwfArray) then begin
      aCodGet[j]:=TComboGet.Create(Self);
      with TComboGet(aCodGet[j]) do begin
        Sorted:=true; VName:=StrNum('DWCod'+aDWVidFormChr[nForm],i); Inc(i);
        OnListOwner:=aCodGetListOwner; OnDrawItem:=aCodGetDrawItem;
      end;
    end
    else aCodGet[j]:=g;
  FillGet.Items.Text:=ArrayAsList(aFill,CRLF);
  Rec.CreateFld('NAME',ftString,DWVidNameLen,'');
  Rec.NameRec:='DWVid'+aDWVidFormChr[nForm]; ArrGet.VName:='DWVidArr'+aDWVidFormChr[nForm];
  for sv:=low(aTypeGet) to high(aTypeGet) do begin
  	aTypeGet[sv]:=TMenuGet.Create(Self);
    aTypeGet[sv].VName:=StrNum('DWType'+aDWVidFormChr[nForm],sv);
    aTypeGet[sv].Items.Sorted:=true;
  end;
  FillGet.VName:='DWFill'+aDWVidFormChr[nForm]; DopGet.VName:='DWDop'+aDWVidFormChr[nForm]; PnEd.FillFldList;
  for i:=0 to PnEd.FieldCount-1 do PnEd.Fields[i].NameRec:=Rec.NameRec;
  ESelType.Mask:=RadioMask(aSelType,0);
  EFillType.AssignGet(FillGet); EDDatType.Mask:=RadioMask(aDWDDatType,0);
  EDDatD2.Mask:=RadioMask(aDWDDatD2,0);
  EDop.AssignGet(DopGet); RecArr.DWPrefix:=RDBArrPrefix; ArrRdbEvents(RecArr);
  with RDBArr,TNone do begin
	  OnDWCanDel:=RDBArrDWCanDel; OnDWCngName:=RDBArrDWCngName;
    OnDWVarValid:=RDBArrDWVarValid; OnDopEditProc:=ArrDopEdit;
  end;
  aFld[dwvName]:=EName; aFld[dwvSvType]:=ESvType; aFld[dwvType]:=EType;
  aFld[dwvCod]:=ECod; aFld[dwvLen]:=ELen; aFld[dwvDec]:=EDec;
  aFld[dwvFillType]:=EFillType; aFld[dwvFillChr]:=EFillChr;
  aFld[dwvDDatType]:=EDDatType; aFld[dwvDDatD2]:=EDDatD2;
  aFld[dwvValue]:=EValue; aFld[dwvPrim]:=EPrim; aFld[dwvDop]:=EDop;
  aFld[dwvSel]:=ESel; aFld[dwvSelType]:=ESelType;
  LsSelV2N:=TStringList.Create; LsSelV2N.Duplicates:=dupAccept;
  TClipboardBuf.ViewerCreate(ClpBrdViewer,Self);
  FProc(dwvidCreate);
  inherited;
  DelStack;
end;

procedure TDWVid.FormDestroy(Sender: TObject);
begin
	AddStack('TDWVid.FormDestroy',Self);
  inherited;
  FreeAndNil(lsNew); LsSelV2N.Free;
  DisposeClpBrd; TClipboardBuf.ViewerFree(ClpBrdViewer,Self);
  DelStack;
end;

type
  TSelGetSort1 = record
    s: string;
    g: TCustomGet;
  end;
  TSelGetSort = array of TSelGetSort1;

function SelGetSort(p: pointer; fi,si: longint; sortID: TSortID): boolean;
var a: ^TSelGetSort;
  function Str1(i: longint): string;
  begin
    AddStack('FDWVid.SelGetSort.Str1');
    result:=AnsiUpperCase(DlmCopy(a^[i].s,2,1,UnDelim));
    DelStack;
  end;
var v: TSelGetSort1;
begin
  AddStack('FDWVid.SelGetSort');
  result:=false; a:=p;
  case sortID of
    sort1MORE2: begin
      result := Str1(fi)>Str1(si);
      if Assigned(DWSelGetSort1More2) then DWSelGetSort1More2(a^[fi].g,a^[si].g,result);
    end;
    sortEXCHANGE: begin
      v:=a^[fi]; a^[fi]:=a^[si]; a^[si]:=v;
    end;
  end;
  DelStack;
end;

function DWVidExec(rdb: TRecDBDef; pStrWhere: PString = nil; nRow: longint = NegDef): boolean;
  function SetVsb(tf: TFldEdit; g: TCustomGetClass; vsb: boolean): boolean;
  begin
    AddStack('FDWVid.DWVidExec.SetVsb');
    tf.Vid:=IfThen(vsb,g.ClassName); tf.Visible:=vsb; tf.SetReadOnly(vsb,ogAutoSize);
    if not vsb then tf.SetBounds(0,0,0,0);
    result:=vsb;
    DelStack;
  end;
var f: TDWVid;
	procedure TypeGetAdd(sv: TDWSaveType; st: TDWFldSetType; lEq: boolean = true);
  var t: TDWFldType;
  begin
    AddStack('FDWVid.DWVidExec.TypeGetAdd');
    for t:=low(aDWFld) to high(aDWFld) do
      if (t in st) = lEq then f.aTypeGet[sv].Items.Add(Int2Str(t)+UnDelim+aDWFld[t].nm);
    DelStack;
  end;
const
  aFix: array[TDWVidCodList] of record
    sv: TDWSaveType;
    st: TDWFldSetType;
  end =
  	((sv:dwsNoFix)
    ,(sv:dwsNoFix; st:[dwtMemo,dwtArray])
    ,(sv:dwsFix  ; st:[dwtString,dwtBool,dwtManyStr])
    ,(sv:dwsFix  ; st:[dwtFloat])
    ,(sv:dwsFix  ; st:[dwtDate])
    ,(sv:dwsFix  ; st:[dwtMemo])
    ,(sv:dwsFix  ; st:[dwtArray])
    ,(sv:dwsDyn)
    ,(sv:dwsFix  ; st:[dwtSel])
    ,(sv:dwsFix)
    );
  addzn: array[TDDatZnType] of TDWFldSetType = ([dwtString,dwtFloat,dwtDate,dwtBool],[dwtSel]);
var i,l,l1: longint;
  j: TDWVidCodList;
  s,so: string;
  sv,sv1,sv2: TDWSaveType;
  oForm: TDWVidForm;
  ordbArr,r: TRecDBDef;
  fl: boolean;
  a: TSelGetSort;
  t: TDWFldType;
  cg: TCodeGet;
  tzn: TDDatZnType;
begin
	AddStack('FDWVid.DWVidExec');
  oForm:=nForm; f:=TDWVid.NmForm(rdb,false);
  with f do begin
    EnterSel := nRow<>NegDef; RecD:=rdb; pWhere:=pStrWhere; Caption:=rdb.DWName;
    i:=LsArrDynamic(rdb.DWTrans,aOld,CRLF,lsaSetLen); lsNew.Capacity:=i;
    for i:=0 to i-1 do lsNew.AddObject(aOld[i],pointer(i+1));
    lAvailable:=Length(rdb.Dop_);
  	for sv:=low(aTypeGet) to high(aTypeGet) do with aTypeGet[sv].Items do begin
    	BeginUpdate; Clear;
    end;
    if (lAvailable>0) or (RecD.NameDB='')
    then TypeGetAdd(dwsNoFix,[dwtMemo,dwtArray,dwtManyStr,dwtSel],false);
    if RecD.NameDB<>'' then begin
    	if lAvailable>0 then RbStatus1.SectRight[0]:=Format('Доступно: %d байт',[lAvailable]);
    	ordbArr:=CurRdbArr;
      try
        CurRdbArr:=RDBArr;
        for j:=low(aCodGet) to high(aCodGet) do if aDWVidBeg[j]<>'' then with TComboGet(aCodGet[j]).Items do begin
          BeginUpdate; Clear; r:=rdb.DWRdbSeek;
          for i:=0 to r.FieldCount-1 do if CompareType(r,i,j) then begin
            fl:=true;
            if Assigned(DWVidFldVisible) then DWVidFldVisible(r,r.FieldName[i],fl);
            if fl then begin
              Add(Copy(r.FieldName[i],Length(r.FixSt(aDWVidBeg[j]))+1,MaxInt));
              with aFix[j] do TypeGetAdd(sv,st);
            end;
          end;
          EndUpdate;
        end;
        fl:=false; DWTypeMany(dwtoIs,[longint(f),longint(@fl)]);
        if fl then TypeGetAdd(dwsFix,[dwtMany]);
      finally
        CurRdbArr:=ordbArr;
      end;
    end;
    if RecD.DynamicVid>0 then for tzn:=low(addzn) to high(addzn) do TypeGetAdd(dwsDyn,addzn[tzn]);
    l:=0; LenType:=0;
  	for sv:=low(aTypeGet) to high(aTypeGet) do with aTypeGet[sv].Items do begin
    	EndUpdate;
      for i:=0 to Count-1 do with aTypeGet[sv].ACodName(i) do begin
      	l1:=Length(Name); MaxSelf(l,l1);
      	MaxSelf(LenType,l1+IfThen(TDWFldType(Int0(Cod)) in DWsetLen,10));
      end;
    end;
    sv1:=low(aTypeGet);
  	for sv:=low(aTypeGet) to high(aTypeGet) do if aTypeGet[sv].Items.Count>0 then begin
      sv1:=sv; break;
    end;
    sv2:=high(aTypeGet);
  	for sv:=high(aTypeGet) downto low(aTypeGet) do
      if aTypeGet[sv].Items.Count>0 then begin
        sv2:=sv; break;
      end;
    ESvType.Mask:=RadioMask(aDWSvTypeNm,byte(sv1),byte(sv2)-byte(sv1)+1,byte(sv1));
    l1:=0; fl:=false;
  	for sv:=sv1 to sv2 do begin
      aTypeGet[sv].LenName:=l;
      if aTypeGet[sv].Items.Count>0 then begin
        Inc(l1);
        if sv=dwsDyn then fl:=true;
      end;
    end;
    if SetVsb(ESvType,TRadioGet,l1>1) then begin
      i:=0;
      for sv:=sv1 to sv2 do begin
        Inc(i); TCheckSpace.SetButEnabled(ESvType,i,aTypeGet[sv].Items.Count>0);
      end;
    end;
    SetVsb(EDDatType,TRadioGet,fl); SetVsb(EDDatD2,TRadioGet,fl);
    fl:=false; s:=Int2Str(dwtSel);
    for sv:=low(aTypeGet) to high(aTypeGet) do if aTypeGet[sv].SeekCod(s) then begin
      fl:=true; break;
    end;
    SetVsb(ESelType,TRadioGet,fl);
    if SetVsb(ESel,TMenuGet,fl) then begin
      LsSelV2N.BeginUpdate; LsSelV2N.Sorted:=false; LsSelV2N.Clear; LsSelV2N.Capacity:=LsCustomGet.Count;
      SetLength(a,LsCustomGet.Count); l1:=0;
      for i:=0 to LsCustomGet.Count-1 do if IsClass(LsCustomGet.Objects[i],TCodeGet,pointer(cg)) then begin
{if cg.VName='Podp' then begin
cg:=cg;
end;}
        s:=cg.SelRVName;
        if not empty(s) then begin
          LsSelV2N.AddObject(cg.ClassName+'.'+cg.VName,pointer(l1+1));
          a[l1].s:=IntToStr(l1+1)+UnDelim+s; a[l1].g:=cg; Inc(l1);
        end;
      end;
      LsSelV2N.Sorted:=true; LsSelV2N.EndUpdate; SetLength(aSelN2V,l1);
      QuickSort(SelGetSort,@a,0,l1-1); s:='0'+UnDelim+'[нет]';
      for i:=0 to l1-1 do IncD(s,mniDlm+a[i].s);
      ESel.Mask:=s;
      for i:=0 to l1-1 do aSelN2V[IntObj(LsSelV2N,i)-1]:=i;
    end;
    if l=0 then begin
      mess_ok([Caption+':','отсутствуют поля для определения данных.']); result:=false;
    end
    else begin
    	LsVarFill(nRow+1); ordbArr:=CurRdbArr;
      try
        CurRdbArr:=RecArr; Inc(LenType);
        DopGet.OnClick:=rdb.OnDopEditProc; EDop.SetReadOnly(not Assigned(DopGet.OnClick));
        PnEdRead; CalcMem; SetF3; FProc(dwvidShow); MainRebuild; so:=OldDef;
        if ShowModal<>mrOk then begin
          if not EnterSel then lsNew.Text:=OldDef;
          if lsNew.Count>0 then LsVar.Row:=max(1,nRow+1);
        end;
        s:=NewDef; result := s<>so;
        if result then rdb.DWTrans(s,true);
      finally
        CurRdbArr:=ordbArr;
      end;
    end;
    lsNew.Clear;
    if not EnterSel then FormFree(aForm[nForm]);
  end;
  nForm:=oForm;
  DelStack;
end;

function TDWVid.OldDef;
begin
  AddStack('TDWVid.OldDef',Self);
  result:=TrimRight(ArrayAsList(aOld,CRLF));
  DelStack;
end;

function TDWVid.NewDef;
begin
  AddStack('TDWVid.NewDef',Self);
  result:=TrimRight(lsNew.Text);
  DelStack;
end;

procedure TDWVid.FProc;
begin
  AddStack('TDWVid.FProc',Self);
  if Assigned(DWVidProc) then DWVidProc(Self,Oper,Prm,PrmUser);
  DelStack;
end;

class function TDWVid.NmForm;
var oForm: TDWVidForm;
begin
  AddStack('TDWVid.NmForm');
  oForm:=nForm; nForm:=rdb.DWVidForm; CreateForm(TDWVid,aForm[nForm]); result:=aForm[nForm];
  if lRestCurForm then nForm:=oForm;
  DelStack;
end;

class function TDWVid.CurForm;
begin
  result:=aForm[nForm];
end;

function TDWVid.NmFormFree;
var i: TDWVidForm;
begin
  AddStack('TDWVid.NmFormFree',Self);
  result:=false;
  for i:=low(aForm) to high(aForm) do if aForm[i]=Self then begin
    result:=FormFree(aForm[i]); break;
  end;
  DelStack;
end;

function TDWVid.nOld;
begin
  AddStack('TDWVid.nOld',Self);
  result:=IntObj(lsNew,i)-1;
  DelStack;
end;

function TDWVid.IsOld;
begin
  AddStack('TDWVid.IsOld',Self);
  if EnterSel then result := nOld(oRow-1)>=0 else result:=false;
  DelStack;
end;

function TDWVid.LsVarCalcZn(Sender: TObject; ACol: longint): String;
const a: TDWSaveStr = ('*','','');
var r: TDWVidRec;
begin
	AddStack('TDWVid.LsVarCalcZn',Self);
  if Assigned(lsNew) then begin
    if InRange(LsVar.Row,1,lsNew.Count) then r:=DWSToRec(lsNew[LsVar.Row-1]) else r:=DWVidRecDef;
    case ACol of
      0: result:=Padr(r.Name,10);
      1: begin
        result:=r.dwCod;
        if r.AType=dwtMany then DWTypeMany(dwtoClick,[longint(@result)]);
      end;
      2: result:=Padr(a[r.SvType]+aDWFld[r.AType].nm+Format(IfThen(r.AType in DWsetLen,
        ' (%d'+IfThen((r.AType=dwtFloat) and (r.Dec>0),'.%d')+')'),[r.Len,r.Dec]),LenType);
    else result:='';
    end;
  end;
  DelStack;
end;

// Считать значения в окно редактирования
procedure TDWVid.PnEdRead;
var s: string;
  r: TDWVidRec;
  fl: boolean;
  n: longint;
begin
	AddStack('TDWVid.PnEdRead',Self);
  fl:=ReplNegSelf(ARow,LsVar.Row);
	if fl or (oRow<>ARow) then begin
    oRow:=ARow; fl:=InRange(oRow,1,lsNew.Count);
    with KeyLb1 do if fl then begin
      s:=lsNew[oRow-1]; SetKey(K_Shift_C,'','Скопировать описание переменной',KeyLb1ProcKey,'lsbox',kmList)
    end
    else begin
      s:=''; DelKey(K_Shift_C,'lsbox');
    end;
    ClpBrdCanPast;
    r:=DWSToRec(s);
    EName.VarValue:=r.Name; ESvType.VarValue:=r.SvType;
    TypeCng; EType.VarValue:=r.AType; ESelType.VarValue:=r.SelType;
    CodCng; ECod.VarValue:=r.dwCod;
    LenDecCng; ELen.VarValue:=r.Len; EDec.VarValue:=r.Dec;
    EFillType.VarValue:=r.FillType; EFillChr.VarValue:=r.FillChr;
    EDDatType.VarValue:=r.DDatType; EDDatD2.VarValue:=r.DDatD2;
    EPrim.VarValue:=r.Prim; EDop.VarValue:=r.DopPrm;
    if not IntObjFind(LsSelV2N,r.SelVid+'.'+r.SelVName,n) then n:=0;
    ESel.VarValue:=n;
    if fl then fl:=IsOld;
    EName.SetReadOnly(fl); ELenExit(ELen); EValue.VarValue:=r.AValue; FProc(dwvidRead,@r);
  end;
  DelStack;
end;

procedure TDWVid.LsVarFill;
var otl: TGridCoord;
begin
  AddStack('TDWVid.LsVarFill',Self);
  with LsVar do begin
    otl:=TopLeft; AddSt(lsNew.Count);
	  if lsNew.Count>0 then begin
      Row:=max(1,nRow); TopLeft:=otl;
    end;
  end;
  DelStack;
end;

// Добавить клавиши списка
procedure TDWVid.LsVarEnter(Sender: TObject);
begin
	AddStack('TDWVid.LsVarEnter',Self);
	with KeyLb1 do begin
  	SetKey(K_F10,IfThen(not EnterSel,'Сохранить'),'',KeyLb1ProcKey,'lsbox',kmFile);
  	SetKey(K_Enter,IfThen(EnterSel,'Выбор'),'',KeyLb1ProcKey,'lsbox',kmList);
  	SetKey(K_F4,'Скопировать','',KeyLb1ProcKey,'lsbox',kmList);
  	SetKey(K_F5,'Редактировать','',KeyLb1ProcKey,'lsbox',kmList);
  	SetKey(K_F7,'Добавить','',KeyLb1ProcKey,'lsbox',kmList);
    SetKey(K_F8,'Удалить','',KeyLb1ProcKey,'lsbox',kmList);
  	SetKey(K_Ctrl_Up,'Выше','Переместить выше',KeyLb1ProcKey,'lsbox',kmList);
  	SetKey(K_Ctrl_Down,'Ниже','Переместить ниже',KeyLb1ProcKey,'lsbox',kmList);
  	SetKey(K_Ctrl_F6,'','Печать',KeyLb1ProcKey,'lsbox',kmFile);
  	SetF3; ReDrw;
  end;
  TTimerOne.CreateProc(TimerMouse,Self); // М.б. при DWVarValid вызван SayStat, тогда flMove не сбрасывается
  DelStack;
end;

procedure TDWVid.TimerMouse;
begin
  AddStack('TDWVid.TimerMouse',Self);
  with LsVar do begin
    OnMouseDown:=LsVarMouseDown; OnMouseMove:=LsVarMouseMove; OnMouseUp:=LsVarMouseUp
  end;
  DelStack;
end;

// Удалить клавиши списка
procedure TDWVid.LsVarExit(Sender: TObject);
begin
	AddStack('TDWVid.LsVarExit',Self);
  with LsVar do begin
    OnMouseDown:=nil; OnMouseMove:=nil; OnMouseUp:=nil
  end;
  KeyLb1.DelKey(K_All,'lsbox'); KeyLb1.ReDrw;
  DelStack;
end;

procedure TDWVid.SetF3;
begin
  AddStack('TDWVid.SetF3',Self);
  with KeyLb1 do
    if aTypeGet[dwsNoFix].Items.Count=0 then DelKey(K_F3,'lsbox')
    else SetKey(K_F3,'','Преобразовать данные в фиксированные',KeyLb1ProcKey,'lsbox',kmServic);
  DelStack;
end;

procedure TDWVid.KeyLb1ProcKey(key: longint; tw: TWinControl);
const NmDef = 'VAL';
var i,nn: longint;
	r: TDWVidRec;
  fl: boolean;
  s: string;
  ls1: TStringList;
  sb: TClipboardBuf;
  a: TArrStr;
begin
	AddStack('TDWVid.KeyLb1ProcKey',Self);
	if (Key=K_F10) and EnterSel then ModalResult:=mrCancel
  else inherited;
	if ArrIntMatch(Key,[K_F7,K_Shift_V]) or (lsNew.Count>0) then case Key of
  	// Преобразовать в фиксированные
    K_F3: if Ask(['Преобразовать нефиксированные поля','в фиксированные ?']) then begin
    	s:=NewDef;
      if ConvertToFix(RecD,s) then begin
        for i:=0 to LsArrDynamic(s,a,CRLF)-1 do lsNew[i]:=a[i];
        LsVarFill(LsVar.Row); PnEdRead; CalcMem;
      end;
    end;
  	// Добавить/скопировать/вставить описание переменной
    K_F4,K_F7,K_Shift_V: begin
      RowBeforeApp:=oRow; nn:=0; fl:=true;
      case Key of
        K_F4: r:=DWSToRec(lsNew[oRow-1]);
        K_F7: r:=DWVidRecDef;
        K_Shift_V: begin
          r:=DWSToRec(PClpBrd^); fl:=false;
          for i:=0 to lsNew.Count-1 do if DWSToRec(lsNew[i]).Name=r.Name then begin
            fl:=true; break;
          end;
        end;
      end;
      if fl then begin
        for i:=0 to lsNew.Count-1 do with DWSToRec(lsNew[i]) do
          if AnsiStartsText(NmDef,Name)
          then MaxSelf(nn,Int0(Copy(Name,Length(NmDef)+1,MaxInt)));
        r.Name:=StrNum(NmDef,nn+1);
      end;
      i:=lsNew.Add(DWRecToS(r))+1;
      if i>1 then LsVar.AddSt;
      LsVar.Row:=i; LsVar.CurStUpdate; PnEdRead; EName.SetReadOnly(false); PnEd.SetFocus;
    end;
    // Редактировать
    K_F5: PnEd.SetFocus;
    // Выбор/редактировать
    K_Enter: if EnterSel then ModalResult:=mrOk else PnEd.SetFocus;
    // Удалить
    K_F8:
      if IsOld then meserr('Нельзя удалять ранее добавленные данные.')
      else begin
        i:=nOld(oRow-1);
        if i<0
        then fl:=true
        else fl:=RecD.DWCanDel(DWSToRec(aOld[i]).Name,TrimRight(Rec['NAME']));
        if fl then if Ask(amsDel) then DelStr;
      end;
    // Печать
    K_Ctrl_F6: begin
      ls1:=TStringList.Create;
      try
        PrnLsAdd(RecD,ls1,NewDef); PrnTxtHeadExec([RecD.DWName],ls1.Text);
      finally
        ls1.Free;
      end;
    end;
    // Выше
    K_Ctrl_Up: Move(oRow,oRow-1);
    // Ниже
    K_Ctrl_Down: Move(oRow,oRow+1);
    // Скопировать описание переменной
  	K_Shift_C: begin
      sb:=TClipboardBuf.CreateWrite(cbrdDWVid,ClpBrdLastVers);
      try
        sb.WriteString(lsNew[LsVar.Row-1]);
      finally
        sb.Free;
      end;
    end;
  end;
  DelStack;
end;

class procedure TDWVid.PrnLsAdd;
var Prm: TLogTrnsValPrm;
begin
  AddStack('TDWVid.PrnLsAdd');
  Prm.Opt:=[]; TDatLogCompare.ExecuteStr(Prm,'',Def,RecD); LsArrList(Prm.val,LsPrn,CRLF,false);
  DelStack;
end;

procedure TDWVid.DelStr;
var i: longint;
begin
  AddStack('TDWVid.DelStr',Self);
  lsNew.Delete(oRow-1);
  for i:=oRow+1 to LsVar.RowCount-1 do LsVar.Rows[i-1].Assign(LsVar.Rows[i]);
  LsVar.RowCount:=max(2,LsVar.RowCount-1);
  if lsNew.Count=0
  then LsVar.Rows[LsVar.RowCount-1].Text:=''
  else LsVar.Row:=min(IfThen(RowBeforeApp<0,oRow,RowBeforeApp),lsNew.Count);
  PnEdRead; CalcMem;
  DelStack;
end;

function TDWVid.ENameCheck(Sender: TObject): Boolean;
var r: TDWVidRec;
	i: longint;
  s: string;
label lend;
begin
	AddStack('TDWVid.ENameCheck',Self);
  result:=false; s:=TrimRight(AnsiUpperCase(Rec['NAME']));
  if empty(s) then goto lend;
  for i:=1 to Length(TrimRight(s)) do
  	if not(s[i] in ['0'..'9','A'..'Z','_','Ё','А'..'Я']) then goto lend;
  for i:=0 to lsNew.Count-1 do begin
  	r:=DWSToRec(lsNew[i]);
    if (i<>LsVar.Row-1) and (TrimRight(AnsiUpperCase(r.Name))=s) then begin
    	meserr('Данное "'+Trim(Rec['NAME'])+'" уже есть.'); goto lend;
    end;
  end;
  result:=true;
lend:
	DelStack;
end;

procedure TDWVid.ESvTypeChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
  AddStack('TDWVid.ESvTypeChange',Self);
  TFldEdit.SetReadOnly([EDDatType,EDDatD2],Rec['SVTYPE']<>dwsDyn);
  ECod.Change(ECod.VarValue,FromShow);
  DelStack;
end;

procedure TDWVid.ESvTypeExit(Sender: TObject);
begin
	AddStack('TDWVid.ESvTypeExit',Self);
  TypeCng; CodCng; ELenExit(ELen);
  DelStack;
end;

function TDWVid.EDDatD2Check(Sender: TObject): Boolean;
begin
  AddStack('TDWVid.EDDatD2Check',Self);
  with TFldEdit(Sender) do result:=IfThenAsk((Int0(OldValue)<>byte(dd2Period)) and (VarValue=dd2Period),
    ['Внимание !','При изменении вида ввода периода на значение',
    '"'+aDWDDatD2[dd2Period]+'"','возможна потеря данных,',
    'так как в незаполненных периодах будет действовать значение по умолчанию.',
    'Сохранить изменения ?'],false);
  DelStack;
end;

procedure TDWVid.ETypeChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
var t: TDWFldType;
  fl: boolean;
	r: TDWVidRec;
  ct: TDWVidCodList;
  i,icur,nc: longint;
  s: string;
begin
	AddStack('TDWVid.ETypeChange',Self);
  t:=Rec['TYPE'];
  ELen.SetReadOnly(not(t in DWsetLen));
  EDec.SetReadOnly(t<>dwtFloat);
  fl:=not(t in [dwtString,dwtManyStr]); TFldEdit.SetReadOnly([EFillType,EFillChr],fl);
  pnFill.SayCaption:=IfThen(fl,' ',SpaceCapt('Заполнить'));
  TFldEdit.SetReadOnly([ESel,ESelType],t<>dwtSel);
  if (RowBeforeApp>=0) and (lsNew.Count>0) and (Rec['SVTYPE']<>dwsDyn) then begin
    r.dwCod:='';
    if t=dwtMany then DWTypeMany(dwtoAppCod,[longint(Self),longint(@r.dwCod)])
    else begin
      icur:=LsVar.Row-1;
      if InRange(icur,0,lsNew.Count-1) then begin
        r:=DWSToRec(lsNew[icur]); s:=r.dwCod; r.dwCod:='';
        ct:=aFixTypeCod[TDWSaveType(ESvType.VarValue),t];
        if aDWVidBeg[ct]='' then begin
          nc:=0;
          for i:=0 to lsNew.Count-1 do with DWSToRec(lsNew[i]) do
            if (i<>icur) and (aFixTypeCod[SvType,AType]=ct) then MaxSelf(nc,Int0(dwCod));
          r.dwCod:=IntToStr(nc+1);
        end
        else with TComboGet(aCodGet[ct]),Items do begin
          OnListOwner(nil,nil,Rect(0,0,0,0),plDown);
          for i:=Count-1 downto 0 do
            if false in aUsed[i] then break
            else {if Strings[i]<>s then} r.dwCod:=Strings[i];
          if r.dwCod='' then for i:=0 to Count-1 do if not(false in aUsed[i]) then {if Strings[i]<>s then }begin
            r.dwCod:=Strings[i]; break;
          end;
        end;
      end;
    end;
    ETypeExit(EType); ECod.VarValue:=r.dwCod;
  end;
  ECod.Change(ECod.VarValue,FromShow);
  DelStack;
end;

procedure TDWVid.ETypeExit(Sender: TObject);
begin
	AddStack('TDWVid.ETypeExit',Self);
  CodCng; LenDecCng; ELenExit(ELen);
  DelStack;
end;

procedure TDWVid.TypeCng;
begin
  AddStack('TDWVid.TypeCng',Self);
  Fld1(EType,TMenuGet,aTypeGet[TDWSaveType(Rec['SVTYPE'])].VName,'');
  DelStack;
end;

procedure TDWVid.CodCng;
var ct: TDWVidCodList;
	ov,ovn: string;
begin
	AddStack('TDWVid.CodCng',Self);
  with ECod do begin
    ov:=Vid; ovn:=VName; ct:=CodList;
    Fld1(ECod,TCustomGetClass(aCodGet[ct].ClassType),aCodGet[ct].VName,
      IfThen((aDWVidBeg[ct]<>'') and (Rec['TYPE']<>dwtManyStr),cOnlyList));
    if (RowBeforeApp<0) and Self.Visible and ((Vid<>ov) or (VName<>ovn)) and (aDWVidBeg[ct]<>'')
      then with TComboGet(aCodGet[ct]) do
        if Items.Count>0 then VarValue:=Items[0] else VarValue:='';
  end;
  DelStack;
end;

procedure TDWVid.LenDecCng;
begin
  AddStack('TDWVid.LenDecCng',Self);
  if not(TDWFldType(Rec['TYPE']) in DWsetLen) then ELen.VarValue:=0;
  if Rec['TYPE']<>dwtFloat then EDec.VarValue:=0;
  DelStack;
end;

procedure TDWVid.EChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
var r: TDWVidCngRec;
begin
  AddStack('TDWVid.EChange',Self);
  r.tf:=pointer(Sender); r.FromShow:=FromShow; FProc(dwvidCng,@r);
  DelStack;
end;

procedure PrUsedCheck(var result: boolean; const r: TDWVidRec;
  const a: array of string; const av: array of variant);
var a0: PArrStr;
  i: longint;
begin
  AddStack('FDWVid.PrUsedCheck');
  a0:=PointerVar(av[0]);
  for i:=low(a0^) to high(a0^) do if AnsiMatchStr(a0^[i],a) then begin
    mess_ok(['Данное с кодом "'+a0^[i]+'" уже используется.','Наименование: "'+r.Name+'".']);
    result:=true; break;
  end;
  DelStack;
end;

function TDWVid.ECodCheck(Sender: TObject): Boolean;
begin
	AddStack('TDWVid.ECodCheck',Self);
  result:=CodCheck(Rec['TYPE'],Rec['COD'],CodList);
  DelStack;
end;

function TDWVid.CodCheck;
var a: TArrStr;
  i: longint;
label lend;
begin
  AddStack('TDWVid.CodCheck',Self);
  result:=false;
  if empty(Cod) then goto lend;
  CodManyStr(a,AType,Cod);
  if (aDWVidBeg[ct]<>'') and (Rec['TYPE']<>dwtManyStr) then
    for i:=low(a) to high(a) do if TComboGet(aCodGet[ct]).Items.IndexOf(a[i])<0 then goto lend;
  result:=not PrUsed(ct,PrUsedCheck,[longint(@a)]);
lend:
  DelStack;
end;

procedure TDWVid.ELenExit(Sender: TObject);
var vn,m,Capt: string;
	l: longint;
  g: TCustomGetClass;
begin
	AddStack('TDWVid.ELenExit',Self);
	vn:=''; m:=''; l:=Rec['LEN']; Capt:=' Значение '+UnDelim+' по умолчанию ';
	case TDWFldType(Rec['TYPE']) of
    dwtFloat: begin
    	g:=TNumGet; m:=MaskNum(Rec['LEN'],Rec['DEC']);
    end;
    dwtDate: begin
    	g:=TDateGet; m:=cDtYear;
    end;
    dwtBool: g:=TBoolGet;
    dwtArray: begin
      if Rec['SVTYPE']=dwsFix then begin
        g:=TCodeGet; vn:=ArrFixGet.VName; Capt:=' Код вида '+UnDelim+' массива '; m:=cCdName+cCdCod;
      end
      else begin
        g:=TButGet; vn:=ArrGet.VName; Capt:=' Описание '+UnDelim+' массива ';
      end;
    end;
  else g:=TSimpleGet;
  end;
  EValue.SayCaption:=Capt; Fld1(EValue,g,vn,m,l);
  DelStack;
end;

function TDWVid.ELenCheck(Sender: TObject): Boolean;
var i,l: longint;
	a: TArrStr;
begin
	AddStack('TDWVid.ELenCheck',Self);
  result:=true; l:=0;
  case CodList of
    dwcFixStr: begin
      FCodManyStr(a);
      for i:=low(a) to high(a) do Inc(l,Length(RecD[RecD.FixSt+a[i]]));
    end;
    dwcDyn: l:=GetFieldInfo(tDDAT,fDDZN).Size;
  end;
  if l>0 then if Rec['LEN']>l then begin
    meserr('Указанная длина превышает предельно допустимую (%d).',[l]); result:=false;
  end;
  DelStack;
end;

procedure DWFldValid;
var amsg: TArrStr;
	s: string;
begin
  AddStack('FDWVid.DWFldValid');
  nFldFocus:=deMask; nVarFocus:=dwvLen;
  if Assigned(g) then g.DWFldValid(ap,dwInf,nFldFocus,nVarFocus,amsg);
  if Assigned(DWFldValidProc) then DWFldValidProc(g,ap,dwInf,nFldFocus,nVarFocus,amsg);
  result := Length(amsg)=0;
  if not result then begin
  	s:=Capt;
    if Assigned(ProcName) then ProcName(s);
  	mess_ok(amsg,s);
  end;
  DelStack;
end;

procedure FDWFldValid(const ap: TDEPrmStr; const dwInf: TDWVidRec;
  var result: boolean; g: TCustomGet; const Capt: string ; ProcName: TProcVarValidName);
var nFldFocus: TDEPrmList; var nVarFocus: TVarParam;
begin
  AddStack('FDWVid.FDWFldValid');
  DWFldValid(ap,dwInf,nFldFocus,nVarFocus,result,g,Capt,ProcName);
  if not result then with aForm[nForm] do pnEd.FldFocus:=aFld[nVarFocus];
  DelStack;
end;

procedure DWVarValid(const r: TDWVidRec; var result: boolean; const Wnd,Name: string;
	ProcName: TProcVarValidName = nil);
var i: longint;
	a: TDEPrmStr;
  nmRec,nmFld: string;
  af: TArrStr;
begin
	AddStack('FDWVid.DWVarValid');
  if result then begin
    nmRec:=TrimUpper(aForm[nForm].RecD.NameRec); nmFld:=TrimUpper(r.Name);
    for i:=0 to LsArrDynamic(TDataWin.aGet(Wnd).Fields,af,CRLF)-1 do begin
      a:=DEGetArrParam(af[i]);
      if (TrimUpper(a[deNameRec])=nmRec) and (TrimUpper(a[deNameRecFld])=nmFld) then begin
        FDWFldValid(a,r,result,NameGet(a),Name,ProcName);
        if not result then break;
      end;
    end;
    TDataWin.aFree;
  end;
  DelStack;
end;

function TDWVid.PnEdValid(Sender: TObject): Boolean;
var r: TDWVidRec;
	a: TDEPrmStr;
begin
	AddStack('TDWVid.PnEdValid',Self);
	result:=true;
  if lsNew.Count>0 then begin
    r:=Edit2Rec;
    if r.AType in DWsetLen then result := LenInt(r.Len,r.Dec)>0;
    if result then begin
    	if RowBeforeApp<0 then begin
        RecD.DWVarValid(DWVarValid,r,result);
        if result then FDWFldValid(a,r,result,nil,'',nil);
      end;
      if result then begin
        lsNew[oRow-1]:=DWRecToS(r); LsVar.CurStUpdate;
      end;
    end
    else TPanelEdit(Sender).FldFocus:=ELen;
    CalcMem;
  end;
  DelStack;
end;

function TDWVid.Edit2Rec;
var a: array[1..2] of string;
  i: longint;
begin
  AddStack('TDWVid.Edit2Rec',Self);
  with result do begin
    Name:=TrimRight(Rec['NAME']); SvType:=Rec['SVTYPE']; AType:=Rec['TYPE'];
    SelType:=Rec['SELTYPE']; 
    dwCod:=TrimRight(Rec['COD']); Len:=Rec['LEN']; Dec:=Rec['DEC'];
    FillType:=Rec['FILLTYPE']; FillChr:=StrToChar(Rec['FILLCHR']);
    DDatType:=Rec['DDATTYPE']; DDatD2:=Rec['DDATD2'];
    AValue:=Rec['VALUE']; Prim:=Rec['PRIM']; DopPrm:=Rec['DOP'];
    i:=Rec['SEL'];
    if i=0 then begin
      SelVid:=''; SelVName:='';
    end
    else begin
      ListAsArray(LsSelV2N[aSelN2V[i-1]],a,'.'); SelVid:=a[1]; SelVName:=a[2];
    end;
    SelPrm:=''; FProc(dwvidWrite,@result);
  end;
  DelStack;
end;

procedure TDWVid.PnEdEscape(Sender: TObject; var Action: TCloseAction);
begin
	AddStack('TDWVid.PnEdEscape',Self);
  if RowBeforeApp<0 then PnEdRead else DelStr;
  DelStack;
end;

procedure TDWVid.PnEdExitType(Sender: TObject; ExitType: TPEExitType);
begin
	AddStack('TDWVid.PnEdExitType',Self);
  RowBeforeApp:=-1; PnEdRead;
  DelStack;
end;

// Переместить мышью
procedure TDWVid.LsVarMouseDown;
var ACol: longint;
begin
	AddStack('TDWVid.LsVarMouseDown',Self);
	if not flMove and (Button=mbLeft) then begin
	  LsVar.MouseToCell(X,Y,ACol,ARow); flMove := ARow>0; LsVar.NoSel:=false;
  end;
  DelStack;
end;

procedure TDWVid.LsVarMouseMove;
var ACol,nr: longint;
begin
	AddStack('TDWVid.LsVarMouseMove',Self);
	if flMove then begin
	  LsVar.MouseToCell(X,Y,ACol,nr);
    if (nr>0) and (nr<>ARow) then begin
		  Move(ARow,nr); ARow:=nr;
    end;
  end;
  DelStack;
end;

procedure TDWVid.LsVarMouseUp;
begin
	AddStack('TDWVid.LsVarMouseUp',Self);
	flMove:=false;
  DelStack;
end;

procedure TDWVid.LsVarSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  AddStack('TDWVid.LsVarSelectCell',Self);
  PnEdRead(ARow);
  DelStack;
end;

// Переместить переменную с позиции oi на ni
procedure TDWVid.Move;
begin
	AddStack('TDWVid.Move',Self);
  if ListMoveItem(oi,ni,1,lsNew.Count,PrMove,[0]) then begin
    LsVar.Row:=ni; PnEdRead;
  end;
  DelStack;
end;

procedure TDWVid.PrMove;
var s: string;
begin
	AddStack('TDWVid.PrMove',Self);
  s:=LsVar.Rows[ni].Text; LsVar.Rows[ni].Assign(LsVar.Rows[oi]); LsVar.Rows[oi].Text:=s;
  lsNew.Exchange(ni-1,oi-1);
  DelStack;
end;

procedure TDWVid.FormClose(Sender: TObject; var Action: TCloseAction);
var result: boolean;
	i,j: longint;
  ro,rn: TDWVidRec;
  so,sn: string;
begin
	AddStack('TDWVid.FormClose',Self);
  inherited;
  if not EnterSel then begin
    so:=OldDef; sn:=NewDef;
    if sn<>so then begin
      AskFormSave(Self,Action); result := (Action=caHide) and (ModalResult=mrOk);
      if result then begin
        for i:=0 to lsNew.Count-1 do begin
          j:=nOld(i);
          if j>=0 then begin
            ro:=DWSToRec(aOld[j]); rn:=DWSToRec(lsNew[i]);
            if ro.Name<>rn.Name then
              with RecD do DWCngName(DWVarName(ro.Name),DWVarName(rn.Name),result);
            if not result then begin
              Action:=caNone; break;
            end;
          end;
        end;
        if result and Assigned(pWhere) then
          if not ChangeDat(RecD,so,sn,pWhere^) then Action:=caNone;
      end;
    end;
  end;
  if (Action=caHide) and (ModalResult<>mrCancel) and (lNeed>lAvailable) and (RecD.NameDB<>'') then begin
  	mess_ok([Format('Требуемый объём памяти (%d байт)',[lNeed]),
    	Format('превышает доступный объём памяти (%d байт).',[lAvailable]),
      'Необходимо удалить лишние данные или уменьшить длину данных.']);
    Action:=caNone;
  end;
  DelStack;
end;

class procedure TDWVid.ButGetPaint;
	function nm1(const nm: string): string;
  begin
    AddStack('TDWVid.ButGetPaint.nm1');
    if dwbPrefix in Mode then result:=rdb.DWVarName(nm) else result:=nm;
    DelStack;
  end;
const aShort: TDWFldTypeChr = ('С','Ч','Д','Л','Т','М','С','В','О');
var a: TArrStr;
	s,s1: string;
	i,l,t,b,lmax: longint;
  Canvas: TCanvas;
begin
  AddStack('TDWVid.ButGetPaint');
  Canvas:=TFldEdit(Sender).Canvas;
  with Canvas do begin
  	FillRect(ARect); l:=LsArrDynamic(rdb.DWTrans,a,CRLF)-1; lmax:=0; t:=ARect.Top;
    for i:=0 to l do MaxSelf(lmax,Canvas,nm1(DWSToRec(a[i]).Name));
    Inc(lmax,ARect.Left+TextWidth(' '));
    for i:=0 to l do with DWSToRec(a[i]) do begin
      s:=nm1(Name);
      s1:=IfThen(dwbShortType in Mode,aShort[AType],aDWFld[AType].nm)
        +IfThen(AType in DWsetLen,Format('%s%d'+IfThen((AType=dwtFloat) and (Dec<>0),'.%d'),
        [IfThen(dwbBrackets in Mode,'(',' '),Len,Dec])+IfThen(dwbBrackets in Mode,')'));
      b:=min(ARect.Bottom,t+max(TextHeight(s),TextHeight(s1)));
      TextRect(Rect(ARect.Left,t,lmax,b),ARect.Left,t,s);
      TextRect(Rect(lmax,t,ARect.Right,b),lmax,t,s1); t:=b;
      if t>ARect.Bottom then break;
    end;
  end;
  DelStack;
end;

procedure TDWVid.CalcMem;
var i: longint;
begin
	AddStack('TDWVid.CalcMem',Self);
	lNeed:=0;
  for i:=0 to lsNew.Count-1 do with DWSToRec(lsNew[i]) do if aFixTypeCod[SvType,AType]=dwcNoFix then begin
    case AType of
      dwtDate: Len:=10;
      dwtBool: Len:=1;
    end;
    Inc(lNeed,Length(dwCod)+Len+2);
  end;
  with RbStatus1.SectRight do Strings[Count-1]:=Format('Требуется: %d байт',[lNeed]);
  DelStack;
end;

function TDWVid.ArrGetClick(Sender: TObject; lEval: Boolean): String;
var fl: boolean;
	sg: TArrSvGetVar;
  i,l: longint;
  a: TArrStr;
begin
	AddStack('TDWVid.ArrGetClick',Self);
	if lEval then begin
  	RecArr.DWName:='Данные по массиву "'+RecD.DWVarName(Trim(Rec['NAME']))+'"';
  	PnEd.SaveGets(sg); fl:=DWVidExec(RecArr); PnEd.RestGets(sg);
    if fl then EValue.Read;
  end;
  l:=LsArrDynamic(TrimRight(RecArr.DWTrans),a,CRLF);
  for i:=0 to l-1 do a[i]:=DWSToRec(a[i]).Name;
  result:=ArrayAsList(a,',',l);
  DelStack;
end;

procedure TDWVid.RecArrDWTrans(Sender: TObject; var sTrans: String;
  lSave: Boolean);
begin
	AddStack('TDWVid.RecArrDWTrans',Self);
	if lSave then Rec['VALUE']:=StrShifr(sTrans) else sTrans:=StrDeShifr(Rec['VALUE']);
  DelStack;
end;

function TDWVid.DWVidRecDef;
const a: array[TDWSaveType] of TDWSaveType = (dwsFix,dwsNoFix,dwsDyn);
var sv: TDWSaveType;
begin
	AddStack('TDWVid.DWVidRecDef',Self);
  DWVidRec0(result);
  for sv:=low(a) to high(a) do
    if Assigned(aTypeGet[a[sv]]) then
      if aTypeGet[a[sv]].Items.Count>0 then begin
        result.SvType:=a[sv]; break;
      end;
  DelStack;
end;

function TDWVid.CodList;
var fl: boolean;
begin
  AddStack('TDWVid.CodList',Self);
  fl:=false; DWTypeMany(dwtoVidCod,[longint(@fl),longint(@result)]);
  if not fl then result:=aFixTypeCod[TDWSaveType(Rec['SVTYPE']),
    TDWFldType(EnsureRange(Rec['TYPE'],byte(low(aDWFld)),byte(high(aDWFld))))];
  DelStack;
end;

procedure AddUsed(var aUsed: TArrBoolSet; const a: array of string; gls: TStringList; chk: boolean);
var i,j: longint;
begin
  AddStack('FDWVid.AddUsed');
  for i:=low(a) to high(a) do if gls.Find(a[i],j) then Include(aUsed[j],chk);
  DelStack;
end;

function TDWVid.PrUsed;
var i: longint;
  r: TDWVidRec;
  a: TArrStr;
  av: TArrVar;
begin
  AddStack('TDWVid.PrUsed',Self);
  result:=false;
  for i:=0 to lsNew.Count-1 do if i<>oRow-1 then begin
    r:=DWSToRec(lsNew[i]);
    if aFixTypeCod[r.SvType,r.AType]=ct then begin
      CodManyStr(a,r); Proc(result,r,a,cav);
    end
    else if r.AType=dwtMany then begin
      CopyFromVArr(av,cav); DWTypeMany(dwtoUsed,[longint(@r),ct,longint(@Proc),longint(@av),longint(@result)]);
    end;
    if result then break;
  end;
  DelStack;
end;

procedure PrUsedList(var result: boolean; const r: TDWVidRec;
  const a: array of string; const av: array of variant);
begin
  AddStack('FDWVid.PrUsedList');
  AddUsed(PArrBoolSet(longint(av[0]))^,a,PointerVar(av[1]),false);
  DelStack;
end;

function TDWVid.aCodGetListOwner;
var i: longint;
	ct: TDWVidCodList;
  cg: TComboGet;
  a: TArrStr;
  gls: TStringList;
begin
	AddStack('TDWVid.aCodGetListOwner',Self);
  result:=false; ct:=CodList; cg:=pointer(aCodGet[ct]);
  gls:=cg.Items; i:=gls.Count; SetLength(aUsed,i); ZeroMemory(@aUsed[0],SizeOf(aUsed[0])*i);
  if Rec['TYPE']=dwtManyStr then begin
  	with TKeyLb do cg.ListNmProc.Text:=ArrayAsList(
      [GetKeySt(K_Space,'Отметить')
      ,GetKeySt(K_Ins,K_Space)],CRLF);
    cg.OnListKeyProc:=ListKeyProc; cg.OnListResult:=ListResult;
    FCodManyStr(a); AddUsed(aUsed,a,gls,true);
  end
  else begin
  	cg.ListNmProc.Clear; cg.OnListKeyProc:=nil; cg.OnListResult:=nil;
  end;
  PrUsed(ct,PrUsedList,[longint(@aUsed),longint(gls)]);
  DelStack;
end;

procedure TDWVid.ListKeyProc;
var i,j: longint;
	lb: TFindListBox;
begin
	AddStack('TDWVid.ListKeyProc',Self);
  lb:=pointer(tw); lb.GetIndexFiltered(i,j); SetSet(aUsed[j],true,not(true in aUsed[j]));
  if (Key=K_Ins) and (i<lb.Items.Count-1) then lb.ItemIndex:=i+1 else tw.Refresh;
  DelStack;
end;

function TDWVid.ListResult;
var i: longint;
begin
	AddStack('TDWVid.ListResult',Self);
  result:='';
  for i:=low(aUsed) to high(aUsed) do
  	if true in aUsed[i] then IncD(result,lr.Strings[i]+',');
  DecLen(result);
  DelStack;
end;

procedure TDWVid.aCodGetDrawItem;
var s: string;
  cl: TColor;
  r: TRect;
begin
  AddStack('TDWVid.aCodGetDrawItem',Self);
  with TFindListBox(Control) do begin
    s:=Items[Index];
    if CodList=dwcFixStr then BracketIntSelf(s,Length(RecD[Recd.FixSt+s]));
    Index:=GetIndexFiltered(Index);
    if false in aUsed[Index] then begin
    	cl:=SchemName(ECod.Schem).Color2;
    	if odSelected in State then Canvas.Font.Color:=cl else Canvas.Brush.Color:=cl;
    end;
    if Assigned(TComboGet(aCodGet[CodList]).OnListKeyProc) then begin
    	r:=Rect; r.Right:=r.Left+bmCheckSize.cX;
      bmCheckPaint(Canvas,r,true in aUsed[Index]); Rect.Left:=r.Right;
    end;
    Canvas.TextRect(Rect,Rect.Left+2,Rect.Top,s);
  end;
  DelStack;
end;

procedure ConvertToFixErr(Oper: TDEInfoOper; Sender: TObject; p: pointer);
var aNewCol: PArrInt;
  i: longint;
begin
  AddStack('FDWVid.ConvertToFixErr');
  if Oper=deiSetting then begin
    aNewCol:=p;
    for i:=low(aNewCol^) to high(aNewCol^) do TDefEdit(Sender).Param[aNewCol^[i],deTag]:=bTrue;
  end;
  DelStack;
end;

class function TDWVid.ConvertToFix;
var aSay,aGet: TArrStr;
	l: longint;
	procedure AddInf(const sSay,sGet: string);
  begin
    AddStack('TDWVid.ConvertToFix.AddInf');
    aSay[l]:=sSay; aGet[l]:=sGet; Inc(l);
    DelStack;
  end;
type TCntList = 0..1;
var aCod: array[TDWVidCodList] of record
  	aFld: array of record
    	Cod: string;
      Used: boolean;
    end;
    aCnt: array[TCntList] of longint;
    Pos: longint;
  end;
  j: TDWVidCodList;
  procedure SeekNext;
  begin
    AddStack('TDWVid.ConvertToFix.SeekNext');
    with aCod[j] do while Pos<aCnt[1] do
      if aFld[Pos].Used then begin
        Inc(aCnt[0]); Inc(Pos);
      end
      else break;
    DelStack;
  end;
const aHead: array[TCntList] of string = ('Требуется','Доступно');
	aNmCod: TDWVidCodStr = ('','','строка(логическое)','число','дата','текст','массив','','выбор','');
var i,p,k,ln,ln1,la: longint;
  aStr: array of record
  	nmf: string;
    Len: longint;
  end;
  a: TArrStr;
  r: TDWVidRec;
  aNewCol: PArrInt;
  de: TDefEdit;
  Rec: TRecVal;
  f: TFld;
  av: TDEPrmVar;
begin
  AddStack('TDWVid.ConvertToFix');
  l:=rdb.FieldCount;
  for j:=low(aCod) to high(aCod) do with aCod[j] do begin
  	SetLength(aFld,l); Pos:=0; ZeroMemory(@aCnt,SizeOf(aCnt));
  end;
  for i:=0 to l-1 do
	  for j:=low(aCod) to high(aCod) do
    	if (aDWVidBeg[j]<>'') and CompareType(rdb,i,j) then with aCod[j] do begin
        aFld[aCnt[1]].Cod:=Copy(rdb.FieldName[i],Length(rdb.FixSt(aDWVidBeg[j]))+1,MaxInt);
        aFld[aCnt[1]].Used:=false; Inc(aCnt[1]); break;
      end;
  for j:=low(aCod) to high(aCod) do with aCod[j] do SetLength(aFld,aCnt[1]);
  de:=nil; Rec:=nil; aNewCol:=nil;
  try
    la:=LsArrDynamic(Def,a,CRLF); result:=true;
    for i:=0 to la-1 do begin
      r:=DWSToRec(a[i]);
      if r.SvType=dwsFix then with aCod[aFixTypeCod[r.SvType,r.AType]] do
      	for l:=low(aFld) to high(aFld) do
        	if aFld[l].Cod=r.dwCod then begin
          	aFld[l].Used:=true; break;
          end;
    end;
    l:=0; SetLength(aStr,la);
    for i:=0 to la-1 do begin
      r:=DWSToRec(a[i]);
      if r.SvType=dwsNoFix then begin
      	j:=aFixTypeCod[dwsFix,r.AType]; SeekNext;
       	with aCod[j] do begin
          p:=Pos;
          case j of
            dwcFixStr: begin
              p:=aCnt[1]; ln:=MaxInt;
              for k:=Pos to aCnt[1]-1 do if not aFld[k].Used then begin
                ln1:=Length(rdb[rdb.FixSt+aFld[k].Cod]);
                if InRange(ln1,r.Len,ln-1) then begin
                  p:=k; ln:=ln1;
                end;
              end;
              if p=aCnt[1] then begin
              	j:=dwcFixMemo; SeekNext;
                with aCod[j] do if Pos=aCnt[1] then begin
                  aStr[l].nmf:=r.Name; aStr[l].Len:=r.Len; Inc(l);
                end
                else begin
                	r.AType:=dwtMemo; p:=Pos;
                end;
              end;
            end;
            dwcFixArray: begin
            	if not Assigned(de) then begin
                Rec:=TRecVal.Create(Application.MainForm);
              	de:=TDefEdit.Create(Application.MainForm);
                de.NameWnd:='ConvertToFix'; de.PnlSortMode:=smColumns;
              end;
              Rec.CreateFld(r.Name,ftString,Length(RDBArrv[fARRV]),'');
              InitArr(av);
              av[deCaption]:=SpaceCapt(r.Name);
              av[deNameRec]:=Rec.NameRec;
              av[deNameRecFld]:=r.Name;
              ArrvCodeGet.AssignGet(av);
              av[deAutoSel]:=true;
              av[deNoReadOnly]:=true;
              de.CreateFld(av);
            end;
          end;
        end;
       	with aCod[j] do begin
          if p<aCnt[1] then begin
            r.SvType:=dwsFix; r.dwCod:=IfThen(lAddChr,aDWFld[r.AType].c)+aFld[p].Cod;
            a[i]:=DWRecTos(r); aFld[p].Used:=true;
            if j=dwcFixStr then continue else Inc(Pos);
          end
          else result:=false;
          Inc(aCnt[0]);
        end;
      end;
    end;
    if result then begin
    	if Assigned(de) then begin
      	result:=de.Execute('Введите коды фиксированных массивов').Saved;
        if result then for i:=0 to la-1 do begin
		      r:=DWSToRec(a[i]);
          if r.AType=dwtArray then
            if Rec.FldName(r.Name,f) then begin
            	r.AValue:=f.Value; a[i]:=DWRecTos(r);
            end;
        end;
      end;
      if result then Def:=ArrayAsList(a,CRLF,la);
    end
    else begin
    	SetLength(aStr,l); p:=0;
      for j:=low(aCod) to high(aCod) do with aCod[j] do
        if aCnt[0]>aCnt[1] then Inc(p);
      if p>0 then begin
        New(aNewCol); SetLength(aNewCol^,Length(aHead)-1); p:=(p+1)*Length(aHead)+1;
      end;
      if l>0 then Inc(p,l+2);
      SetLength(aSay,p); SetLength(aGet,p); l:=0;
      if Assigned(aNewCol) then begin
      	AddInf(UnDelim,'НЕДОСТАТОЧНОЕ КОЛИЧЕСТВО ФИКСИРОВАННЫХ ПОЛЕЙ');
        for i:=low(aHead) to high(aHead) do begin
          AddInf('',UnDelim+aHead[i]);
          for j:=low(aCod) to high(aCod) do with aCod[j] do
            if aCnt[0]>aCnt[1] then AddInf(IfThen(i=low(aHead),aNmCod[j]),IntToStr(aCnt[i]));
          if i<high(aHead) then aNewCol^[i]:=l;
        end;
      end;
      if Length(aStr)>0 then begin
      	AddInf(UnDelim,'НЕ НАЙДЕНЫ ДОСТУПНЫЕ СТРОКИ НЕОБХОДИМОЙ ДЛИНЫ');
        AddInf('',UnDelim+'Длина');
        for p:=low(aStr) to high(aStr) do with aStr[p] do AddInf(nmf,IntToStr(Len));
      end;
      DefEditInfo(rdb.DWName+': ошибка преобразования в фиксированные','ErrorCngDatFix',aSay,aGet,ConvertToFixErr,aNewCol);
    end;
  finally
    de.Free; Rec.Free; DisposeNil(aNewCol);
  end;
  DelStack;
end;

procedure TDWVid.WMSchem;
var j: TDWVidCodList;
begin
	AddStack('TDWVid.WMSchem',Self);
	if msg.Oper=soBefore then with SchemName(ECod.Schem) do
    for j:=low(aCodGet) to high(aCodGet) do
      if aCodGet[j] is TComboGet then begin
      	Canvas.Font.Assign(Font1); TComboGet(aCodGet[j]).ItemHeight:=CanvasMaxH(Canvas);
      end;
  DelStack;
end;

class procedure TDWVid.ArrRdbEvents;
begin
  AddStack('TDWVid.ArrRdbEvents');
  with TNone do begin
    rdb.OnDWRdbSeek:=TRecDBDef.ArrDWRdbSeek; rdb.OnDopEditProc:=ArrDopEdit; rdb.OnDWFldInfo:=ArrFldInfo;
  end;
  DelStack;
end;

procedure TDWVid.WMFormLimit;
var i: TDWVidForm;
begin
	AddStack('TDWVid.WMFormLimit',Self);
  inherited;
  for i:=low(aForm) to high(aForm) do if FreeLimit(aForm[i]) then break;
  DelStack;
end;

procedure TDWVid.LsVarDrawCell(Sender: TObject; ACol,ARow: longint;
  Rect: TRect; State: TGridDrawState);
var bm: TBitMap;
  r: TRect;
begin
  AddStack('TDWVid.LsVarDrawCell',Self);
  if not(gdFixed in State) and (ACol=2) and InRange(ARow,1,lsNew.Count) then
    if DWSToRec(lsNew[ARow-1]).SvType=dwsDyn then begin
      InitBM.FindBM(bmDDat,bm);
      if bm.Height>Rect.Bottom-Rect.Top then begin
        r:=Rect; r.Left:=r.Right-((Rect.Bottom-Rect.Top)*bm.Width) div bm.Height;
        LsVar.Canvas.StretchDraw(r,bm);
      end
      else LsVar.Canvas.Draw(Rect.Right-bm.Width,Rect.Top+(Rect.Bottom-Rect.Top-bm.Height) div 2,bm);
    end;
  DelStack;
end;

procedure TDWVid.FCodManyStr;
begin
  AddStack('TDWVid.FCodManyStr',Self);
  CodManyStr(a,Rec['TYPE'],Rec['COD']);
  DelStack;
end;

procedure TDWVid.ClpBrdCanPast;
var result: boolean;
  sb: TClipboardBuf;
  ost: longint;
begin
  ost:=AddStack('TDWVid.ClpBrdCanPast',Self);
  result:=false; sb:=TClipboardBuf.CreateRead(cbrdDWVid,ClpBrdLastVers);
  try
    try
      if sb.Active then begin
        if not Assigned(PClpBrd) then New(PClpBrd);
        sb.ReadString(PClpBrd^,rdtoCtrl); result:=true;
      end;
    except
      SetStack(ost);
    end;
  finally
    sb.Free;
  end;
  with KeyLb1 do
    if result then SetKey(K_Shift_V,'','Вставить описание переменной',KeyLb1ProcKey,'lsbox',kmList)
    else begin
      DelKey(K_Shift_V,'lsbox'); DisposeClpBrd;
    end;
  DelStack;
end;

procedure TDWVid.WMChangeCBChain;
begin
  AddStack('TDWVid.WMChangeCBChain',Self);
  inherited;
  TClipboardBuf.ViewerChangeCBChain(ClpBrdViewer,Msg);
  DelStack;
end;

procedure TDWVid.WMDrawClipboard;
begin
  AddStack('TDWVid.WMDrawClipboard',Self);
  inherited;
  try
    ClpBrdCanPast;
  finally
    TClipboardBuf.ViewerDrawClipboard(ClpBrdViewer);
  end;
  DelStack;
end;

procedure TDWVid.DisposeClpBrd;
begin
  AddStack('TDWVid.DisposeClpBrd',Self);
  DisposeNil(PClpBrd);
  DelStack;
end;

function TDWVid.ManyGetClick(Sender: TObject; lEval: Boolean): String;
var lCng: boolean;
  v: string;
  av: TArrVar;
begin
  AddStack('TDWVid.ManyGetClick',Self);
  lCng:=false; result:=ECod.VarValue; CopyFromVArr(av,[longint(@result)]);
  if lEval then AddFromVArr(av,[longint(Self),longint(@lCng),longint(@v)]);
  DWTypeMany(dwtoClick,av);
  if lCng then ECod.VarValue:=v;
  DelStack;
end;

{ TDatLogCompare }
var aLogRec: array of TDWArrVidRec;
  nLogRec: longint;

class function TDatLogCompare.ListCreate;
var af: TArrStr;
  i: longint;
begin
  AddStack('TDatLogCompare.ListCreate');
  if Length(aLogRec)=nLogRec then SetLength(aLogRec,IfThen(nLogRec=0,2,nLogRec shl 1));
  i:=LsArrDynamic(Value,af,CRLF); SetLength(aLogRec[nLogRec],i);
  for i:=0 to i-1 do aLogRec[nLogRec,i]:=DWSToRec(af[i]);
  result:=pointer(nLogRec); Inc(nLogRec);
  DelStack;
end;

class procedure TDatLogCompare.ListDestroy;
begin
  AddStack('TDatLogCompare.ListDestroy');
  Dec(nLogRec); aLogRec[nLogRec]:=nil;
  DelStack;
end;

class function TDatLogCompare.GetCount;
begin
  AddStack('TDatLogCompare.GetCount');
  result:=Length(aLogRec[longint(ls)]);
  DelStack;
end;

function LogCompareStrFill(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('FDWVid.LogCompareStrFill');
  with PDWVidRec(p)^ do result:=IfThen(AType in [dwtString,dwtManyStr],IfThen(longint(pv)=1,FillChr,aFill[FillType]));
  DelStack;
end;

const aCaptValue: TArrBoolStr = ('значение по умолчанию','код вида массива');

function ValueArr(r: PDWVidRec): boolean;
begin
  AddStack('FDWVid.ValueArr');
  result := r.AType=dwtArray;
  DelStack;
end;

function LogCompareStrValue(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var r: PDWVidRec;
  v: variant;
  la: boolean;
begin
  AddStack('FDWVid.LogCompareStrValue');
  r:=p; result:=r.AValue; la:=ValueArr(r);
  if la then begin
    if not empty(result) then result:=Trim(result)+'. '+ArrFixGet.CodeName(result,[cdgBufAll])
  end
  else begin
    v:=TRecDBDef.GetFldInfValue(r.AType,result);
    if not empty(v) then
      if r.AType=dwtBool then result:=bRus2Str(v) else result:=Trim(r.AValue);
  end;
  if not boolean(pv) then IncL(result,aCaptValue[la]+': ');
  DelStack;
end;

function LogCompareStrDopPrm(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var fv: TFldValue;
begin
  AddStack('FDWVid.LogCompareStrDopPrm');
  fv:=TFldValue.Create;
  try
    fv.Value:=PDWVidRec(p).DopPrm; result:=TRecDBDef(pv).OnDopEditProc(fv,false);
  finally
    fv.Free;
  end;
  DelStack;
end;

class procedure TDatLogCompare.GetItem;
var ro,rn: PDWVidRec;
  RecD: TRecDBDef;
  fl: boolean;
begin
  AddStack('TDatLogCompare.GetItem');
  rn:=@aLogRec[longint(lsn)][nn];
  case tp of
    clogKey: Prm.val:=rn.Name;
    clogNoKey: Prm.val:=DWRecToS(rn^);
  else
    ro:=@aLogRec[longint(lso)][no]; RecD:=pv; Prm.val:=RecD.DWVarName(rn.Name);
    TStrLogCompare.AddRes(Prm,aDWFld[ro.AType].nm,aDWFld[rn.AType].nm,nil,'тип',1);
    TStrLogCompare.AddRes(Prm,ro.dwCod,rn.dwCod,nil,'код',1);
    TStrLogCompare.AddRes(LogCompareStrFill,Prm,ro,rn,pointer(0),'заполнить',1);
    TStrLogCompare.AddRes(LogCompareStrFill,Prm,ro,rn,pointer(1),'заполнить символом',1);
    fl := ValueArr(ro)=ValueArr(rn);
    TStrLogCompare.AddRes(LogCompareStrValue,Prm,ro,rn,pointer(fl),IfThen(fl,aCaptValue[ValueArr(rn)]),1);
    TStrLogCompare.AddRes(Prm,ro.Prim,rn.Prim,nil,'примечание',1);
    if Assigned(RecD.OnDopEditProc) then TStrLogCompare.AddRes(LogCompareStrDopPrm,Prm,ro,rn,RecD,'параметры',1);
  end;
  DelStack;
end;

class procedure TDatLogCompare.Execute(var Prm: TLogTrnsValPrm; r: TRecDBDef);
begin
  AddStack('TDatLogCompare.Execute');
  Execute(Prm,pointer(r));
  DelStack;
end;

{ TCngDatMemo }
constructor TCngDatMemo.Create;
var fa: TFldMemoAttr;
begin
  AddStack('TCngDatMemo.Create');
  Owner:=AOwner; SetLength(af,MaxCnt); lf:=0; ZeroMemory(@lnf,SizeOf(lnf));
  for fa:=low(anf) to high(anf) do SetLength(anf[fa],MaxCnt);
  SetLength(aa,MaxCnt);
  if MaxCnt>0 then ZeroMemory(@aa[0],MaxCnt*SizeOf(aa[0]));
  DelStack;
end;

procedure TCngDatMemo.Add;
var p: PRDBArrDef;
  i: longint;
  faa: TFldMemoAttr;
  sBeg: string;
begin
  AddStack('TCngDatMemo.Add');
  if Owner.IsField(nmf) then begin
    af[lf]:=nmf; anf[fa,lnf[fa]]:=lf;
    if fa=famArray then if TRecDBDef.PGetArrDef(ka,p) then for i:=low(p.aDat) to high(p.aDat) do
      if IsDWFldMemo(p.aDat[i].AType,faa,sBeg) then begin
        if not Assigned(aa[lnf[fa]]) then aa[lnf[fa]]:=TCngDatMemo.Create(Owner,Length(p.aDat));
        aa[lnf[fa]].Add(sBeg+p.aDat[i].dwCod,p.aDat[i].AValue,faa);
      end;
    Inc(lnf[fa]); Inc(lf);
  end;
  DelStack;
end;

procedure TCngDatMemo.FillGK;
var i,j,lr: longint;
  fa: TFldMemoAttr;
  gk: longword;
begin
  AddStack('TCngDatMemo.FillGK');
  with ProgPswd.GetQuery do begin
    PartSelect(tbl,ArrStrToArrVar(af,lf),where);
    if IsRecords then begin
      lr:=RecordCount;
      for fa:=low(adelgk) to high(adelgk) do if lnf[fa]>0 then begin
        j:=ldelgk[fa]+lr*lnf[fa];
        if j>Length(adelgk[fa]) then SetLength(adelgk[fa],j);
        First;
        while not Eof do begin
          for i:=0 to lnf[fa]-1 do begin
            gk:=Fields[anf[fa,i]].AsInteger;
            if gk>0 then begin
              adelgk[fa,ldelgk[fa]]:=VTos(gk); Inc(ldelgk[fa]);
              if fa=famArray then if Assigned(aa[i]) then aa[i].FillGK(adelgk,ldelgk,tARR,fMGK+'='+Vtos(gk));
            end;
          end;
          Next;
        end;
      end;
    end;
    ProgPswd.FreeQuery;
  end;
  DelStack;
end;

destructor TCngDatMemo.Destroy;
var i: longint;
begin
  AddStack('TCngDatMemo.Destroy');
  for i:=0 to lnf[famArray]-1 do aa[i].Free;
  inherited Destroy;
  DelStack;
end;

{ TNone }
procedure ZnSet(tzn: TDDatZnType; const zn: string);
var t: TDDatZnType;
begin
  AddStack('FDWVid.ZnSet');
  for t:=low(aDDatZnFld) to high(aDDatZnFld) do DDat[aDDatZnFld[t]]:=IfThen(t=tzn,zn);
  DelStack;
end;

procedure StCngDat(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var v: variant;
  aRec: ^TArrVidRec1;
  j: longint;
  procedure CngType(nt: longint);
  var ot: longint;
  begin
    AddStack('FDWVid.StCngDat.CngType');
    ot:=MyVarType(v,true);
    if nt<>ot then case ot of
      varBoolean: case nt of
        varDouble: Bool2IntSelf(v,1,2);
        varDate: v:=DateEmpty;
        varString: bStrSelf(v);
      end;
      varDouble: case nt of
        varBoolean: v := v>1;
        varDate: v:=DateEmpty;
        varString: with aRec^[j] do SpaceStrSelf(v,Inf[true].Len,Inf[false].Dec);
      end;
      varDate: case nt of
        varBoolean: v:=false;
        varDouble: v:=0;
        varString: dtocSelf(v);
      end;
      varString: case nt of
        varBoolean: StrToBoolSelf(v);
        varDouble: Float0Self(v);
        varDate: ctodSelf(v);
      end;
    end;
    DelStack;
  end;
const aDynType: array[TDWFldType] of longint =
  (varString,varDouble,varDate,varBoolean,varString,varArray,varString,varString,varString);
var i,i1,i2,lr,n,lcod: longint;
  rdb,ordb,nrdb: TRecDBDef;
  ac,av,acDel: PArrVar;
  af,afCod: TArrField;
  fddD: TField;
  acod: TArrStr;
  fa: TFldMemoAttr;
  lsArr: TStringList;
  aArr: ^TArrArrBoolRecDBDef;
  p: ^TArrBoolRecDBDef;
  s,oCod,nCod,oDynCod: string;
  oDynDate: TDateTime;
  d: TDateTime;
  olsm,nlsm: TMemGkList;
  afa: ^TFldMemoAttrArr;
  adelgk: ^TFldMemoAttrArrStr;
  ldelgk: ^TFldMemoAttrInt;
begin
	AddStack('FDWVid.StCngDat');
  rdb:=PointerVar(Params[0]); ac:=PointerVar(Params[1]); av:=PointerVar(Params[2]);
  aRec:=PointerVar(Params[3]); acDel:=PointerVar(Params[4]);
  ordb:=PointerVar(Params[5]); nrdb:=PointerVar(Params[6]);
  lsArr:=PointerVar(Params[7]); aArr:=PointerVar(Params[8]); afa:=PointerVar(Params[9]);
  adelgk:=PointerVar(Params[10]); ldelgk:=PointerVar(Params[11]); lr:=Params[12];
  if rdb.DynamicVid>0 then with aDDat[rdb.DynamicVid] do begin
    oDynCod:=CurCod; oDynDate:=CurDate;
  end
  else oDynDate:=DateEmpty;
  try
    with ProgPswd.CurQuery do begin
      i:=Length(acDel^); SetLength(af,i); MultD(i,lr);
      for fa:=low(adelgk^) to high(adelgk^) do begin
        j:=ldelgk[fa]+i;
        if j>Length(adelgk[fa]) then SetLength(adelgk[fa],j);
      end;
      for j:=low(af) to high(af) do af[j]:=FindField(acDel^[j]);
      lcod:=0; fddD:=nil;
      if rdb.DynamicVid>0 then begin
        if not empty(rdb.DDatFieldCod) then begin
          lcod:=LsArrDynamic(rdb.DDatFieldCod,acod,','); SetLength(afCod,lcod);
          for j:=0 to lcod-1 do afCod[j]:=FindField(acod[j]);
        end;
        if not empty(rdb.DDatField) then fddD:=FindField(rdb.DDatField);
      end;
      oCod:='';
      olsm:=TMemGkList.Create(ordb);
      nlsm:=TMemGkList.Create(nrdb);
      for i:=1 to lr do begin
        if Sender.SayStat(i/lr) then break;
        olsm.GetFromQuery; nlsm.GetFromQuery;
        if lcod>0 then begin
          for j:=0 to lcod-1 do acod[j]:=TrimRight(afCod[j].AsString);
          nCod:=ArrayAsList(acod,',',lcod);
          if nCod<>oCod then begin
            oCod:=nCod; aDDat[rdb.DynamicVid].CurCod:=oCod;
            for j:=low(ac^) to high(ac^) do with aRec^[j].Inf[true]^ do
              if SvType=dwsDyn then av^[j]:=TRecDBDef.GetFldInfValue(AType,AValue);
          end;
        end;
        if Assigned(fddD) then aDDat[rdb.DynamicVid].CurDate:=fddD.AsDateTime;
        for j:=low(ac^) to high(ac^) do with aRec^[j] do
          if not(((Inf[false].SvType=dwsDyn) or (Inf[true].SvType=dwsDyn)) and (rdb.DynamicVid=0)) then
            if Inf[true].SvType=dwsDyn then begin
              v:=ordb[ac^[j]]; CngType(aDynType[Inf[true].AType]);
              if MyVarType(v)=varString then TrimRightSelf(v);
              if not CompVar(av^[j],v) then begin
                av^[j]:=v; d:=DateSmall;
                if Assigned(fddD) then
                  if not empty(fddD.AsDateTime) then d:=fddD.AsDateTime;
                if d>DateSmall then s:='='+ProgPswd.VarToS(d) else s:='<='+ProgPswd.VarToS(DateSmall);
                if not DDat.Seek(DDGetWhere(oCod,rdb.DynamicVid,ac^[j])
                +sAND+DDat.TblFldName(fDDD1)+s) then begin
                  DDat.NewRec([newrNoDoNewRec]); DDat[fDDCod]:=oCod; DDat[fDDVid]:=rdb.DynamicVid;
                  DDat[fDDKv]:=ac^[j]; DDat[fDDD1]:=d;
                end;
                DDat['D2']:=DateBig;
                ZnSet(aDDat[rdb.DynamicVid].GetKvInfo(ac^[j]).tzn,
                  DDVar2Str(v,aDWFld[Inf[true].AType].tp,Inf[true].Len,Inf[true].Dec));
                DoDDatSetValProc(dsvUpdate); DDat.AppUpdRec;
              end;
            end
            else if nrdb.NumFromName(ac^[j],n) then begin
              v:=av^[j];
              if lNm then begin
                if Inf[false].SvType=dwsDyn
                then v:=aDDat[rdb.DynamicVid].GetValue(ac^[j])
                else v:=ordb[v];
                CngType(MyVarType(nrdb.ValueNum[n],true));
                if (Inf[false].AType=dwtArray) and (Inf[true].AType=dwtArray) then begin
                  p:=@aArr^[IntObjFind(lsArr,Inf[false].Name)];
                  with p[false] do begin
                    ArrValue:=v; p[true].ArrCount:=ArrCount;
                    for i1:=1 to ArrCount do begin
                      GotoRec(i1); p[true].GotoRec(i1);
                      for i2:=0 to FieldCount-1 do p[true][FieldName[i2]]:=Value[FieldName[i2]];
                      p[true].UpdateRec;
                    end;
                  end;
                  v:=p[true].ArrValue;
                end;
              end;
              nrdb.ValueNum[n]:=TRecDBDef.FillValue(v,Inf[false]^,Inf[true]^);
            end;
        for j:=low(af) to high(af) do begin
          n:=af[j].AsInteger;
          if n>0 then begin
            fa:=afa^[j]; adelgk[fa,ldelgk[fa]]:=VTos(n); Inc(ldelgk[fa]);
          end;
        end;
        nrdb.UpdateRec; Next;
      end;
    end;
    ordb.CloseRec; nrdb.CloseRec;
  finally
    if rdb.DynamicVid>0 then with aDDat[rdb.DynamicVid] do begin
      CurCod:=oDynCod; CurDate:=oDynDate;
    end;
  end;
  DelStack;
end;

procedure StCngDyn(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i,lr: longint;
  fKV: TField;
  lsDynSel: TStringList;
  aDynSel: ^TArrArrVidRec;
  okv,kv: string;
  pvr: ^TArrVidRec;
  lsm: TMemGkList;
begin
  AddStack('FDWVid.StCngDyn');
  lsDynSel:=PointerVar(Params[0]); aDynSel:=PointerVar(Params[1]); lr:=Params[2];
  lsm:=PointerVar(Params[3]);
  with ProgPswd.CurQuery do begin
    fKV:=FindField(fDDKv); okv:=''; pvr:=nil;
    for i:=1 to lr do begin
      if Sender.SayStat(i/lr) then break;
      kv:=TrimRight(fKV.AsString);
      if kv<>okv then begin
        okv:=kv; pvr:=@aDynSel^[IntObjFind(lsDynSel,kv)];
      end;
      lsm.GetFromQuery; DoDDatSetValProc(dsvCanCng);
      ZnSet(DDZnType(pvr[true]^),TRecDBDef.FillValue(
        DDat[aDDatZnFld[DDZnType(pvr[false]^)]],pvr[false]^,pvr[true]^));
      DDat.UpdateRec; Next;
    end;
  end;
  DelStack;
end;

class procedure TNone.PrCngDat;
type TDynUpd = 1..2;
var lDynUpd: longint;
  fl: boolean;
  aDynUpd: array of record
  	ac,av: array[TDynUpd] of variant;
    where: string;
  end;
var ap: TArrVidRec;
  procedure aDynUpdAdd(const v: string; n: TDynUpd = 2; const where: string = ''; lQQ: boolean = true);
  const af: array[TDynUpd] of string = (fDDKv,fDDZN);
  begin
    AddStack('TNone.PrCngDat.aDynUpdAdd');
    aDynUpd[lDynUpd].ac[n]:=af[n];
    if lQQ then aDynUpd[lDynUpd].av[n]:=QQs(v) else aDynUpd[lDynUpd].av[n]:=v;
    aDynUpd[lDynUpd].where:=DlmBetween(tDDAT+'.'+fDDKv+'='+QQs(ap[false].Name),where,sAND);
    if where='' then fl:=true
    else begin
      aDynUpd[lDynUpd].ac[1]:=''; aDynUpd[lDynUpd].av[1]:=''; Inc(lDynUpd);
    end;
    DelStack;
  end;
type TUpdList = (dwuUpd,dwuUpd0,dwuMove,dwuSel,dwuDel);
var upd: TUpdList;
  nct: TDWVidCodList;
  vv: variant;
  FillNoCng: boolean;
  function dwuFill(const nmf: string): boolean;
  var lFill: boolean;
    l: longint;
  begin
    AddStack('TNone.PrCngDat.dwuFill');
    with ap[true]^ do begin
      lFill := (FillType=ap[false].FillType) and (FillChr=ap[false].FillChr);
      FillNoCng := (AType<>dwtString) or (Len=ap[false].Len) {and lFill};
      result:=(dwCod<>ap[false].dwCod)
        or (not FillNoCng and not((AType=dwtString) and (Len>ap[false].Len)
        and (FillType=dwftRight) and (FillChr=' ') and lFill));
      if result then begin
        if (aDWVidBeg[nct]<>'') and (AType<>dwtManyStr) and (ap[false].AType<>dwtManyStr) then
          if FillNoCng then upd:=dwuUpd
          else begin
            l:=Len-ap[false].Len;
            if (l>0) and (FillType=dwftLeft) {and lFill} then begin
              upd:=dwuUpd;
              vv:=ProgPswd.CurQuery.GetPart('s+s',[sC_LIST],
                [ProgPswd.CurQuery.GetList(['"'+StringOfChar(FillChr,l)+'"',nmf])]);
            end;
          end;
      end;
    end;
    DelStack;
  end;
var
  aInf: array[boolean] of record
  	lsName: TStringlist;
    aName: TDWArrVidRec;
    alsCod: array[TDWVidCodList] of TStringlist;
    Def: string;
  end;
  function lsNameRec(fl: boolean; i: longint): PDWVidRec;
  begin
    AddStack('TNone.PrCngDat.lsNameRec');
    with aInf[fl] do result:=@aName[IntObj(lsName,i)];
    DelStack;
  end;
var
  aUpd: array[TUpdList] of record
  	ac,av: TArrVar;
    nUpd: longint;
	end;
  rdb: TRecDBDef;
  procedure ChkLen(n: TUpdList);
  var l: longint;
  begin
    AddStack('TNone.PrCngDat.ChkLen');
    with aUpd[n] do if Length(ac)=nUpd then begin
      l:=nUpd shl 1; SetLength(ac,l); SetLength(av,l);
    end;
    DelStack;
  end;
var WhereProc: TChangeDatWhereProc;
  a: TArrStr;
  where: string;
  procedure aWhere;
  begin
    AddStack('TNone.PrCngDat.aWhere');
    if Assigned(WhereProc) then WhereProc(true,a) else CopyFrom(a,where);
    DelStack;
  end;
	procedure rdbCrt(var r: TRecDBDef; nPrm: longint);
  begin
    AddStack('TNone.PrCngDat.rdbCrt');
    r:=TRecDBDef.CreateFrom(rdb);
    r.OnTrnsCan:=rdb.OnTrnsCan; r.OnTrnsEnd:=rdb.OnTrnsEnd;
    r.OnTrnsExec:=rdb.OnTrnsExec; r.OnTrnsTable:=rdb.OnTrnsTable;
    r.FldDef.Text:=Sender.Params[nPrm]; r.OpenRec;
    DelStack;
  end;
var n: longint;
  lsDynSel: TStringList;
  aDynSel: TArrArrVidRec;
  procedure DynSelAdd;
  begin
    AddStack('TNone.PrCngDat.DynSelAdd');
    n:=lsDynSel.Count;
    if Length(aDynSel)=n then SetLength(aDynSel,n shl 1);
    lsDynSel.AddObject(ap[true].Name,pointer(n)); aDynSel[n]:=ap;
    DelStack;
  end;
type TOperList = (opMove,opUpd,opApp);
const sDWVidCodSimple = [dwcFixStr,dwcFixFloat,dwcFixDate];
  aUpdOrd: array[0..1] of TUpdList = (dwuMove,dwuUpd);
var oct: TDWVidCodList;
  aRec: TArrVidRec1;
  lsArr,ls: TStringList;
  aArr: TArrArrBoolRecDBDef;
	i,l,l1,j,lDynDel: longint;
  ct: TDWVidCodList;
  ast: TArrBoolStr;
  a1,aDynDel: TArrStr;
  fa: TFldMemoAttr;
  afa: TFldMemoAttrArr;
  s,s1: string;
  pw: pointer;
  op: TOperList;
  lTransaction,lMemo: boolean;
  cm: TCngDatMemo;
  adelgk: TFldMemoAttrArrStr;
  ldelgk: TFldMemoAttrInt;
  qu: TMulQuery;
  g: TCodeGet;
  ordb,nrdb: TRecDBDef;
  isFld: TFldMemoAttrSet;
  lsm: TMemGKList;
label lused;
begin
	AddStack('TNone.PrCngDat');
  with Sender do begin
  	rdb:=PointerVar(Params[0]); lTransaction:=Params[4];
    if not IfThenTrnsStart(lTransaction,[rdb.NameDB]) then Abort;
    if not Aborted then try
      where:=Sender.Params[3]; pw:=PointerVar(Sender.Params[5]); WhereProc:=TChangeDatWhereProc((@pw)^);
      lsDynSel:=nil; lsArr:=nil; ordb:=nil; nrdb:=nil;
      for fl:=false to true do with aInf[fl] do begin
        lsName:=TStringList.Create; Def:=Params[1+byte(fl)]; lsName.Text:=Def; i:=lsName.Count; SetLength(aName,i);
        for i:=0 to i-1 do begin
          lsName.Objects[i]:=Pointer(i); aName[i]:=DWSToRec(lsName[i]); lsName[i]:=aName[i].Name;
        end;
        lsName.Sort;
        for ct:=low(alsCod) to high(alsCod) do alsCod[ct]:=SortStrListCreate;
        for i:=0 to lsName.Count-1 do with lsNameRec(fl,i)^ do
          alsCod[aFixTypeCod[SvType,AType]].AddObject(dwCod,pointer(i));
      end;
      try
        n:=aInf[true].lsName.Count; SetLength(aRec,n);
        for upd:=low(aUpd) to high(aUpd) do with aUpd[upd] do begin
          case upd of
            dwuUpd: l:=n+aInf[false].lsName.Count;
            dwuUpd0: l:=aInf[false].lsName.Count;
          else l:=n;
          end;
          SetLength(ac,l); SetLength(av,l); nUpd:=0;
        end;
        l:=aInf[false].lsName.Count;
        SetLength(aDynDel,l); lDynDel:=0;
        SetLength(aDynUpd,l); lDynUpd:=0;
        Finalize(adelgk);
        isFld:=[];
        for fa:=low(aMemo) to high(aMemo) do if IsField(aMemoTbl[fa],'FLD') then Include(isFld,fa);
        with ProgPswd.GetQuery do begin
          // Обнулить неиспользуемые значения
          cm:=TCngDatMemo.Create(rdb,aInf[false].lsName.Count);
          try
            for i:=0 to aInf[false].lsName.Count-1 do begin
              ap[false]:=lsNameRec(false,i);
              with ap[false]^ do begin
                oct:=aFixTypeCod[SvType,AType];
                lMemo := not(oct in sDWVidCodSimple);
                if lMemo then fl:=IsDWFldMemo(AType,fa) else fl:=true;
              end;
              if fl then begin
                CodManyStr(a1,ap[false]^);
                for j:=0 to aInf[true].alsCod[oct].Count-1 do begin
                  CodManyStr(a,lsNameRec(true,IntObj(aInf[true].alsCod[oct],j))^);
                  for n:=low(a1) to high(a1) do if AnsiMatchText(a1[n],a) then goto lused;
                end;
                vv:=iif(lMemo or (oct=dwcFixFloat),0,iif(oct=dwcFixDate,DateEmpty,QQs));
                for n:=low(a1) to high(a1) do with aUpd[dwuUpd0] do begin
                  ChkLen(dwuUpd0); ac[nUpd]:=rdb.FixSt(aDWVidBeg[oct])+a1[n]; av[nUpd]:=vv;
                  if lMemo then if aInf[true].lsName.IndexOf(aInf[false].lsName[i])<0
                  then cm.Add(ac[nUpd],ap[false].AValue,fa);
                  Inc(nUpd);
                end;
              end;
lused:
            end;
            if cm.lf>0 then begin
              aWhere;
              for i:=low(a) to high(a) do cm.FillGK(adelgk,ldelgk,rdb.NameDB,a[i]);
            end;
          finally
            cm.Free;
          end;
          afa:=nil;
          // Нефиксированные и фиксированные
          for op:=low(TOperList) to high(TOperList) do begin
            i:=0;
            while i<aInf[true].lsName.Count do begin
              ap[true]:=lsNameRec(true,i);
              if ap[true].SvType<>dwsDyn then begin
                with ap[true]^ do nct:=aFixTypeCod[SvType,AType];
                n:=aInf[false].lsName.IndexOf(ap[true].Name);
                if n<0 then
                  if IntObjFind(aInf[false].alsCod[nct],ap[true].dwCod,n) then
                    if lsNameRec(false,n).SvType=dwsDyn then n:=-1;
                if (n<0) = (op=opApp) then begin
                  fl:=false; upd:=dwuSel;
                  // Добавлено
                  if op=opApp then begin
                    ap[false]:=ap[true]; oct:=nct;
                    with ap[true]^ do if (aDWVidBeg[nct]<>'')
                    or ((AType=dwtString) and ((FillType=dwftLeft) or (FillChr<>' '))) then begin
                      vv:=TRecDBDef.GetFldInfValue(AType,AValue);
                      if (AType<>dwtManyStr) and (nct in sDWVidCodSimple) then upd:=dwuUpd;
                      if AType in [dwtMemo,dwtSel] then
                        if vv='' then with aUpd[dwuDel] do begin
                          upd:=dwuUpd; vv:=0;
                          ChkLen(dwuDel); ac[nUpd]:=rdb.FixSt(aDWVidBeg[nct])+dwCod;
                          if Length(afa)<Length(ac) then SetLength(afa,Length(ac));
                          IsDWFldMemo(AType,fa); afa[nUpd]:=fa; Inc(nUpd);
                        end;
                      vv:=TRecDBDef.FillValue(vv,ap[false]^,ap[true]^); fl:=true;
                      if upd=dwuUpd then vv:=VarTos(vv,vsQQ);
                    end;
                  end
                  else begin
                    ap[false]:=lsNameRec(false,n);
                    with ap[false]^ do begin
                      oct:=aFixTypeCod[SvType,AType];
                      if SvType<>dwsDyn then begin
                        vv:=Name;
                        if nct=oct then
                          if nct=dwcFixSel then begin
                            if (SelVid<>ap[true].SelVid) or (SelVName<>ap[true].SelVName) then begin
                              if NameGet(TCustomGet(g),ap[true].SelVid,ap[true].SelVName,TCodeGet) then begin
                                aWhere; qu:=ProgPswd.GetQuery; l1:=g.CodLen;
                                for j:=low(a) to high(a) do begin
                                  FldInSel(fMGK,rdb.NameDB,a[j],rdb.FixSt(aDWVidBeg[nct])+ap[true].dwCod,[],@a1);
                                  for l:=low(a1) to high(a1) do begin
                                    UpdateTable(tSEL,['VID','VNAME'],
                                      [QQs(ap[true].SelVid),QQs(ap[true].SelVName)],a1[l]);
                                    PartSelect(tSEL,'COD',a1[l],'','COD');
                                    while not Eof do begin
                                      s:=TrimRight(Fields[0].AsString); s1:=TrimRight(g.TransSeek(s,l1));
                                      if s1<>s then qu.UpdateTable(tSEL,['COD'],[QQs(s1)],'COD='+QQs(s));
                                      Next;
                                    end;
                                  end;
                                end;
                                ProgPswd.FreeQuery;
                              end;
                            end
                            else if dwCod<>ap[true].dwCod then fl:=true;
                          end
                          else begin
                            fl:=dwuFill(rdb.FixSt(aDWVidBeg[oct])+dwCod);
                            if fl and FillNoCng and (upd=dwuUpd) then begin
                              s:=rdb.FixSt(aDWVidBeg[oct])+dwCod;
                              if rdb.FldName(rdb.FixSt(aDWVidBeg[nct])+ap[true].dwCod).Info.Size
                              <rdb.FldName(s).Info.Size
                              then upd:=dwuSel
                              else begin
                                upd:=dwuMove; vv:=s;
                              end;
                            end;
                          end
                        // Изменён тип хранения
                        else if (oct<>dwcFixArray) and (nct<>dwcFixArray)
                        or (AType=dwtArray) and (ap[true].AType=dwtArray) then begin
                          if (AType=dwtArray) and (ap[true].AType=dwtArray) then begin
                            if not Assigned(lsArr) then begin
                              lsArr:=SortStrListCreate; SetLength(aArr,1);
                            end;
                            if ap[true].SvType=dwsFix then begin
                              ast[false]:=StrDeshifr(AValue); ast[true]:=ast[false];
                              if not TDWVid.ConvertToFix(RDBArr,ast[true],true) then begin
                                Abort; break;
                              end;
                            end
                            else begin
                              ast[false]:=TRecDBDef.GetArrDef(AValue).Dat; ast[true]:=ast[false];
                            end;
                            n:=lsArr.Count;
                            if Length(aArr)=n then SetLength(aArr,n shl 1);
                            for fl:=false to true do begin
                              aArr[n,fl]:=TRecDBDef.Create(Application.MainForm);
                              aArr[n,fl].FldDef.Text:=ast[fl]; aArr[n,fl].OpenRec;
                            end;
                            lsArr.AddObject(Name,pointer(n));
                          end;
                          if (AType in [dwtMemo,dwtSel]) and (ap[true].AType=AType) then begin
                            upd:=dwuMove; vv:=rdb.FixSt(aDWVidBeg[oct])+dwCod;
                          end;
                          fl:=true;
                        end;
                      end;
                    end;
                  end;
                  if fl and ((upd=dwuMove) = (op=opMove)) then with aUpd[upd] do begin
                    ChkLen(upd);
                    if upd=dwuSel then begin
                      aRec[nUpd].Inf:=ap; aRec[nUpd].lNm := op<>opApp; ac[nUpd]:=ap[true].Name;
                    end
                    else begin
                      ac[nUpd]:=rdb.FixSt(aDWVidBeg[nct])+ap[true].dwCod;
                      if op=opMove then if not(nct in sDWVidCodSimple) then
                      if IsDWFldMemo(ap[true].AType,fa) then if fa in isFld then begin
                        s:=QQs(rdb.NameDB+'.'+LeftStrDel(ac[nUpd],aMemo[fa].beg));
                        aWhere;
                        for j:=low(a) to high(a) do begin
                          FldInSel(fMGK,rdb.NameDB,DlmBetween(a[j],vv+'<>'+VToS,sAND),vv,[],@a1);
                          UpdateTableList(a1,['FLD'],[s],aMemoTbl[fa]);
                        end;
                      end;
                    end;
                    av[nUpd]:=vv; Inc(nUpd);
                    if op<>opApp then begin
                      with aInf[false] do if IntObjFind(alsCod[oct],ap[false].dwCod,n,l) then begin
                        alsCod[oct].Delete(n); aInf[false].lsName.Delete(l);
                        for ct:=low(alsCod) to high(alsCod) do with alsCod[ct] do
                          for j:=0 to Count-1 do begin
                            l1:=IntObj(alsCod[ct],j);
                            if l1>l then Objects[j]:=Pointer(l1-1);
                          end;
                      end;
                      with aInf[true] do begin
                        for ct:=low(alsCod) to high(alsCod) do with alsCod[ct] do begin
                          j:=0;
                          while j<Count do begin
                            l:=IntObj(alsCod[ct],j);
                            if l=i then begin
                              Delete(j); continue;
                            end;
                            if l>i then Objects[j]:=Pointer(l-1);
                            Inc(j);
                          end;
                        end;
                        lsName.Delete(i);
                      end;
                      continue;
                    end;
                  end;
                end;
              end;
              Inc(i);
            end;
          end;
          // Динамические
          if rdb.DynamicVid>0 then begin
            lsDynSel:=SortStrListCreate; SetLength(aDynSel,10); nct:=dwcFixStr;
            for i:=0 to aInf[false].lsName.Count-1 do begin
              ap[false]:=lsNameRec(false,i);
              with ap[false]^ do begin
                n:=aInf[true].lsName.IndexOf(Name);
                if n<0 then
                  if IntObjFind(aInf[true].alsCod[dwcDyn],dwCod,n) then
                    if (SvType=dwsDyn) <> (ap[true].SvType=dwsDyn) then n:=-1;
                // Удалено
                if n<0 then begin
                  if SvType=dwsDyn then begin
                    aDynDel[lDynDel]:=QQs(Name); Inc(lDynDel);
                  end;
                end
                else begin
                  ap[true]:=lsNameRec(true,n);
                  // (Динам.->фикс.) или (Фикс.->динам.)
                  if (ap[true].SvType<>SvType) then with aUpd[dwuSel] do begin
                    ChkLen(dwuSel); aRec[nUpd].Inf:=ap; ac[nUpd]:=Name;
                    if ap[true].SvType=dwsDyn
                    then av[nUpd]:=TRecDBDef.GetFldInfValue(ap[true].AType,ap[true].AValue)
                    else begin
                      aRec[nUpd].lNm:=true; aDynDel[lDynDel]:=QQs(Name); Inc(lDynDel);
                    end;
                    Inc(nUpd);
                  end
                  // Измененение параметров динам.данных
                  else if SvType=dwsDyn then begin
                    fl:=false;
                    InitArr(aDynUpd[lDynUpd].ac,0,MaxInt,'');
                    InitArr(aDynUpd[lDynUpd].av,0,MaxInt,'');
                    if ap[true].Name<>Name then aDynUpdAdd(ap[true].Name,1);
                    if (ap[true].AType=dwtDate) and not(AType in [dwtString,dwtDate])
                    or (AType=dwtDate) and not(ap[true].AType in [dwtString,dwtDate])
                      then with ap[true]^ do
                        aDynUpdAdd(DDVar2Str(TRecDBDef.GetFldInfValue(AType,AValue),aDWFld[AType].tp,Len,Dec))
                    else begin
                      upd:=dwuSel;
                      if DDZnType(ap[true]^)<>DDZnType(ap[false]^) then DynSelAdd
                      else if dwuFill(fDDZN) then
                        if upd=dwuUpd then begin
                          if not FillNoCng then aDynUpdAdd(vv,2,'',false)
                        end
                        else DynSelAdd;
                    end;
                    if fl then Inc(lDynUpd);
                    if (AType=dwtFloat) and (ap[true].AType=dwtBool) then begin
                      s:=QQs(DDVar2Str(2,aDWFld[AType].tp,Len,Dec));
                      for fl:=false to true do with ap[true]^,aDWFld[AType] do
                        aDynUpdAdd(DDVar2Str(fl,tp,Len,Dec),2,
                        fDDZN+IfThen(fl,'>=','<')+s+sAND+fDDZN+'<>'+QQs(DDVar2Str(not fl,tp,Len,Dec)));
                    end;
                    if (AType=dwtBool) and (ap[true].AType=dwtFloat) then begin
                      s:=QQs(DDVar2Str(true,aDWFld[AType].tp,Len,Dec));
                      for l:=1 to 2 do with ap[true]^ do
                        aDynUpdAdd(DDVar2Str(l,aDWFld[AType].tp,Len,Dec),2,fDDZN+aqEq[l=2]+s);
                    end;
                  end;
                end;
              end;
            end;
          end;
          with aUpd[dwuUpd] do for i:=0 to aUpd[dwuUpd0].nUpd-1 do begin
            ChkLen(dwuUpd);
            ac[nUpd]:=aUpd[dwuUpd0].ac[i];
            av[nUpd]:=aUpd[dwuUpd0].av[i];
            Inc(nUpd);
          end;
          ls:=SortStrListCreate;
          try
            for upd:=low(aUpd) to high(aUpd) do with aUpd[upd] do begin
              ls.Clear;
              if nUpd>0 then begin
                if upd=dwuSel then begin
                  rdbCrt(ordb,1); rdbCrt(nrdb,2);
                end;
                i:=0;
                while i<nUpd do begin
                  if upd=dwuSel
                  then fl:=not(ordb.IsField(ac[i]) or nrdb.IsField(ac[i]))
                  else fl:=not rdb.IsField(ac[i]);
                  if not fl then fl:=IgnoreSlFindAdd(ls,ac[i]);
                  if fl then begin
                    Dec(nUpd);
                    for j:=i+1 to nUpd do begin
                      ac[j-1]:=ac[j]; av[j-1]:=av[j];
                      if upd=dwuSel then aRec[j-1]:=aRec[j];
                    end;
                  end
                  else Inc(i);
                end;
              end;
            end;
          finally
            ls.Free;
          end;
          fl:=false;
          for upd:=low(aUpd) to high(aUpd) do with aUpd[upd] do begin
            SetLength(ac,nUpd); SetLength(av,nUpd);
            if nUpd>0 then fl:=true;
          end;
          if fl then begin
            with aUpd[dwuSel] do
              if not Aborted and ((nUpd>0) or (aUpd[dwuDel].nUpd>0)) then begin
                SetLength(aRec,nUpd); Arg[sTABLE]:=rdb.NameDB;
                if Assigned(WhereProc) then begin
                  SetLength(a,2); WhereProc(false,a); AddArgList(sTABLE,a[0]); s:=a[1];
                end
                else s:=where;
                if not Assigned(ordb) then begin
                  rdbCrt(ordb,1); rdbCrt(nrdb,2);
                end;
                TRecDBDef.AddCList([ordb,nrdb]);
                PartSelect('','',s,GetList([rdb.TblFldName(rdb.DDatFieldCod),rdb.TblFldName(rdb.DDatField)]));
                l:=RecordCount;
                if l>0 then
                  if ShowStat(rdb.DWName+': корректировка',StCngDat,
                    [LongInt(rdb),LongInt(@ac),LongInt(@av),LongInt(@aRec),
                    LongInt(@aUpd[dwuDel].ac),longint(ordb),longint(nrdb),
                    LongInt(lsArr),longint(@aArr),LongInt(@afa),LongInt(@adelgk),LongInt(@ldelgk),l],l) then Abort;
              end;
            if not Aborted then for n:=low(aUpdOrd) to high(aUpdOrd) do with aUpd[aUpdOrd[n]] do if nUpd>0 then begin
              aWhere; rdb.UpdateTableList(ac,av,a);
            end;
          end;
          if not SayCapt(['Очистка текстовых полей']) then
            for fa:=low(adelgk) to high(adelgk) do
              DeleteTableFldList(adelgk[fa],ldelgk[fa],fMGK,[flsUnique],aMemoTbl[fa]);
          if not Aborted then begin
            s:=Sender.Params[6];
            if s<>'' then s:=tDDAT+'.'+fDDCod+'='+QQs(s)+sAND;
            IncD(s,tDDAT+'.'+fDDVid+'='+Vtos(rdb.DynamicVid));
            if lDynUpd>0 then begin
              fl:=true; aWhere;
              for i:=low(aDynUpd) to lDynUpd-1 do with aDynUpd[i] do
                for j:=low(a) to high(a) do TDynamicDat.OperWhere(ac,av,DlmBetween([s,where,a[j]],sAND));
            end;
            if Assigned(lsDynSel) then if lsDynSel.Count>0 then begin
              fl:=true;
              PartSelect(tDDAT,[],s+sAND+FldInListQQ(tDDAT+'.'+fDDKv,lsDynSel),fDDKv); l:=RecordCount;
              if l>0 then begin
                lsm:=TDynamicDat.MemCreate;
                if ShowStat(rdb.DWName+': корректировка динамических данных',StCngDyn,
                  [LongInt(lsDynSel),longint(@aDynSel),l,longint(lsm)],l) then Abort;
              end;
            end;
            if not Aborted and (lDynDel>0) then begin
              fl:=true; TDynamicDat.DelWhere(s+sAND+FldInList(tDDAT+'.'+fDDKv,aDynDel,lDynDel));
            end;
          end;
          if fl and not Aborted and Assigned(lsArr) then TTimerOne.CreateProc(UpdArrGet,nil);
        end;
        ProgPswd.FreeQuery;
      finally
        for fl:=false to true do with aInf[fl] do begin
          lsName.Free;
          for ct:=low(alsCod) to high(alsCod) do alsCod[ct].Free;
        end;
        lsArr.Free; lsDynSel.Free; ordb.Free; nrdb.Free;
      end;
      if Assigned(DWChangeDatProc) then DWChangeDatProc(Sender,rdb,aInf[false].Def,aInf[true].Def,where);
      if lTransaction then TrnsEndWnd(Sender);
    except
      if lTransaction then TrnsEnd;
      raise
    end;
  end;
  DelStack;
end;

class function TNone.RDBArrDWCanDel;
var a: TDWSearchAInfo;
begin
	AddStack('TNone.RDBArrDWCanDel');
  result := not DataWinSearchIdent(TDataWin.aGet,RDBArrv[DWMem(postWin)],VarName,a);
  TDataWin.aFree;
  if not result then mess_ok(['Данное "'+MsgName+'" используется',
    'в окне ввода данных по массиву.']);
  DelStack;
end;

class procedure TNone.RDBArrDWCngName;
var s: string;
begin
	AddStack('TNone.RDBArrDWCngName');
	if result then begin
    s:=RDBArrv[DWMem(postWin)];
    if DataWinReplaceIdent(TDataWin.aGet,s,OldName,NewName)>0 then RDBArrv[DWMem(postWin)]:=s;
    TDataWin.aFree;
  end;
  DelStack;
end;

class procedure TNone.RDBArrDWVarValid;
begin
	AddStack('TNone.RDBArrDWVarValid');
  Proc(r,result,RDBArrv[DWMem(postWin)],'Окно ввода данных по массиву');
  DelStack;
end;

class function TNone.ArrDopEdit;
const aAlgm: array[1..4] of string = ('стандартное','слева','в центре','справа');
var tf: TFldEdit;
	a: array[1..2] of string;
  av: TDEPrmVar;
begin
  AddStack('TNone.ArrDopEdit');
  if lEval then begin
  	if not Assigned(deArrDopPrm) then begin
      rArrDopPrm:=TRecVal.Create(Application.MainForm);
      with rArrDopPrm do begin
	      CreateFld('VIEW',ftBoolean,0,false); CreateFld('ALGM',ftInteger,0,0);
      end;
    	deArrDopPrm:=TDefEdit.Create(Application.MainForm);
      with deArrDopPrm do begin
      	FrmCaption:='Параметры поля массива'; NameWnd:='ArrDopEdit';
        InitArr(av);
        av[deNameRec]:=rArrDopPrm.NameRec;
        av[deNameRecFld]:='VIEW';
        TBoolGet.AssignGetClass(av);
        av[deMask]:='Выводить в просмотре';
        av[deNoReadOnly]:=true;
        CreateFld(av);
        av[deCaption]:='Размещение';
        av[deNameRecFld]:='ALGM';
        TRadioGet.CreateOne.AssignGet(av);
        av[deMask]:=RadioMask(aAlgm);
        CreateFld(av);
        OnFldChange:=deArrDopPrmFldChange;
      end;
    end;
    tf:=pointer(Sender); LsArrFill(tf.Value,a,','); rArrDopPrm['VIEW']:=not StrToBoolean(a[1]);
    rArrDopPrm['ALGM']:=Int0(a[2]);
    if deArrDopPrm.Execute.Saved
    then tf.Value:=StrNum(Bool2Str(not rArrDopPrm['VIEW'])+',',rArrDopPrm['ALGM']);
  end;
  LsArrFill(TFldEdit.GetStrValue(Sender),a,',');
  result:=IfThen(StrToBoolean(a[1]),'не выводить в просмотре',
  	'размещение: '+aAlgm[EnsureRange(Int0(a[2]),low(aAlgm),high(aAlgm))]);
  DelStack;
end;

class procedure TNone.deArrDopPrmFldChange;
begin
	AddStack('TNone.deArrDopPrmFldChange');
  with TFldEdit(Sender) do if NameRecFld='VIEW' then deArrDopPrm.SetReadOnly('ALGM',not VarValue);
  DelStack;
end;

class procedure TNone.ArrFldInfo;
const aAlgm: array[2..4] of TAlignment = (taLeftJustify,taCenter,taRightJustify);
var n: longint;
begin
	AddStack('TNone.ArrFldInfo');
  n:=Int0(DlmCopy(r.DopPrm,2,1));
  if InRange(n,low(aAlgm),high(aAlgm)) then FldInfo.Alignment:=aAlgm[n];
  DelStack;
end;

class function TNone.ArrvCodeGetTransSeek;
begin
	AddStack('TNone.ArrvCodeGetTransSeek');
	result:=Padr(Value,Size);
  DelStack;
end;

initialization
  AddStack('FDWVid.initialization');
  RecDB.DWVidExec:=DWVidExec; RecDB.ChangeDat:=ChangeDat;
  DelStack;
end.

