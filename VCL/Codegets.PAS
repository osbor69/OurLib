unit Codegets;

interface

{$I LIBTEST}
uses
	Windows,Messages,Classes,Controls,DB,Graphics,DBGrids,
  MyTypes,My_pr,FldMask,BrQuery,MulQry,ListF2,RecVal,RecDB,FFldedit,PaintCtl,FrmBrIB,FrmNul,CCodeGet,Browl;

type
	TStrBrqEvent = function(Sender: TObject; Qry: TBrQuery): string of object;
	TCGTransEvent = function(Sender: TObject; tf: TFldEdit; const Value: string;
  	Size: longint; lSQL: boolean): string of object;
	TCGFormListEvent = function(Sender: TFldEdit = nil): TFormNul of object;
	TCGFormIBListEvent = function(Sender: TFldEdit = nil): TFormBrIB of object;
  TCGNameWhere = (cgwCreate,cgwInclude,cgwFree);
	TCGNameWhereEvent = function(Sender: TObject; tf: TFldEdit; const Cod,Dop: string;
  	op: TCGNameWhere; var p: Pointer): boolean of object;
  TCGIncWidthListDownEvent = function(Sender: TObject; f: TFormNul): longint of object;
  TCGQueryWhereEvent = function(Sender: TObject; const PrmCode: string): string of object;
  TCGBufCodCngEvent = procedure(Sender: TObject; const cod: string; qApp: TMulQuery) of object;
  TCGPaintEvent = procedure(Sender: TObject; tf: TFldEdit) of object;
  TCGListFindEvent = procedure(Sender: TObject; tf: TFldEdit; Qry: TMulQuery; var result: boolean) of object;
  
  TCGParam = record
  	Mask,FmlFlt,Dop: string;
    lCodOnly,lNameOnly,lEmpty,lAny,lNameGet,lCodFocus: boolean;
  end;

  PBufCod = ^TBufCod;
  TBufCod = record
  	Name,Dop: string;
  end;
  
  TCGSelListLoadOpt = set of (cgselAny,cgselLoadBuf);
  
  PCodeGet = ^TCodeGet;
	TCodeGet = class(TCustomCodeGet)
 	private
  { Private declarations }
    FDimInt: array[1..2] of longint;
    FDimStr: array[1..2] of string;
		FPart,FGlobKey,osk: string;
    FOnBufCodCng: TCGBufCodCngEvent;
    FOnFormList: TCGFormListEvent;
    FOnFormIBList: TCGFormIBListEvent;
    FOnIncWidthListDown: TCGIncWidthListDownEvent;
    FOnListFind: TCGListFindEvent;
    FOnStrCode,FOnStrName,FOnStrDop: TStrBrqEvent;
    FOnTransSeek: TCGTransEvent;
    FOnNameWhere: TCGNameWhereEvent;
    FOnQueryWhere: TCGQueryWhereEvent;
    FOnPaint: TCGPaintEvent;
    FQuery: TBrQuery;
    FMulPar: TMulQueryMulPar;
    FCodLen: longint;
    FTrimLeft,FListFindEqual,NameFocus: boolean;
	  PFormList: TFormNul;
    BrQuery1: TBrQuery;
    lNmSQL: boolean;
    lsSelFlt: TStrVarList;
    ao: array of record
      otf: TFldEdit;
      oBeforeOpen: TDataSetNotifyEvent;
      oFilterRecord: TFilterRecordEvent;
      oFiltered: boolean;
    end;
    lo,lFlt: longint;
    BufName: TStringList;
    aCodNameDop: array of TBufCod;
    aCodName,aNameCod,aFlt: TArrStr;
		function GetConnection: TComponent;
    function GetDimInt(Index: longint): longint;
    function GetDimStr(Index: longint): string;
		procedure SetConnection(Value: TComponent);
    procedure SetDimInt(Index: longint; Value: longint);
    procedure SetDimStr(Index: longint; const Value: string);
	 	procedure SetGlobKey(const Value: string);
	 	procedure SetPart(const Value: string);
	 	procedure SetMulPar(Value: TMulQueryMulPar);
		procedure SetOnStrDop(Value: TStrBrqEvent);
		procedure MulParChange(Sender: TObject);
    procedure eCEnter(Sender: TObject);
    procedure eCExit(Sender: TObject);
    procedure eNEnter(Sender: TObject);
    function DoSQL(const PrmCode: string = '%'; tf: TFldEdit = nil): boolean;
    procedure ProcKey(key: longint; tw: TWinControl);
    function NmFind(Sender: TControl; const sf: string): boolean;
    procedure TabClick(Sender: TObject);
    procedure DoTab(tf: TFldEdit);
    procedure SetNameValue(tf: TFldEdit);
		procedure FormActivate(Sender: TObject);
    function StrBrq(Sender: TBrQuery; Proc: TStrBrqEvent; const nmf: string): string;
		procedure BufLoad(tf: TFldEdit; q: TBrQuery = nil);
		procedure BufCodAdd(tf: TFldEdit; q: TBrQuery);
    procedure DelCod(oi,ni: longint);
    procedure DelName(oi,ni: longint);
    function GetCodNameDop(i: longint): PBufCod;
    function GetCodName(i: longint): PString;
    function GetNameCod(i: longint): PString;
		function ValEmp(tf: TFldEdit; const v: string): boolean;
    function SelDel(var i: longint): boolean; overload;
    function GetSelFlt(const Index: string): variant;
    procedure SetSelFlt(const Index: string; const Value: variant);
    function lsSelFltFind(const Index: string; var i: longint): boolean;
    procedure qBeforeOpen(DataSet: TDataSet);
 	protected
  { Protected declarations }
    sT: TPaintButton;
    Param: TCGParam;
    SelRedef: boolean;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const vv: string); override;
    function Check(tf: TFldEdit): boolean; override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function MayDoKey(tf: TFldEdit; Key: longint): boolean; override;
    function AssignObj(tf: TFldEdit): boolean; override;
    procedure SetDefLenCode; override;
    procedure SetDefLenName; override;
		function DWFldUnAllowType(const Mask: string): TDWFldSetType; override;
    procedure StdListDown(tf: TFldEdit; const RectList: TRect;
    	PozList: TPozList); override;
		procedure Paint(tf: TFldEdit); override;
    procedure AutoSelect(tf: TFldEdit);
    function StrCode(Sender: TBrQuery): string; dynamic;
    function StrDop(Sender: TBrQuery): string; dynamic;
    function StrName(Sender: TBrQuery): string; dynamic;
    function IncWidthListDown(f: TFormNul): longint; dynamic;
    procedure BufCodCng(i: longint; qApp: TMulQuery = nil); dynamic;
		function NameWhere(tf: TFldEdit; const Cod,Dop: string; op: TCGNameWhere;
    	var p: Pointer): boolean; dynamic;
    procedure ListFind(tf: TFldEdit; Qry: TMulQuery; var result: boolean); dynamic;
    procedure FltListAdd(const Code: string; var Accept: boolean); virtual;
    procedure qFilterRecord(DataSet: TDataSet; var Accept: Boolean); virtual;
    procedure MaskFrmShow(Sender: TObject); override;
    class procedure MaskEdChange(Sender: TObject; const OldVal: variant; FromShow: boolean); override;
		class function MaskSortMode: TSortMode; override;
    class procedure FMaskView(var Mask: string); override;
		function MinWidthCode(tf: TFldEdit): longint; override;
    function MaskDop(const av: variant): string; virtual;
    function GetNameText(tf: TFldEdit; const ACode: string): string; virtual;
    function GetSelCodeGet: TCustomGet; override;
		function DWFldSelCodeGetValid(Sender: TCustomGet; const dwInf: TDWVidRec;
    	var nFldFocus: TDEPrmList; var nVarFocus: TVarParam; var amsg: TArrStr): boolean; override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
 	public
  { Public declarations }
    BufCod: TStringListCase;
    BufLoaded: boolean;
		constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
		function DoFormList(tf: TFldEdit): TFormNul; dynamic;
		function DoFormIBList(tf: TFldEdit): TFormBrIB; dynamic;
		procedure ListExec;
    function TransSeek(tf: TFldEdit; const Value: string; Size: longint = 0; lSQL: boolean = false): string; overload; dynamic;
    function TransSeek(const Value: string; Size: longint = 0; lSQL: boolean = false): string; overload;
    function SeekCod(tf: TFldEdit; const ACode: string; Options: TCGSeekOptions = []): longint; overload; virtual;
    function SeekCod(const ACode: string; Options: TCGSeekOptions = []): longint; overload;
    function SeekCod(var i: longint; tf: TFldEdit; const ACode: string; Options: TCGSeekOptions = []): boolean; overload;
    function SeekCod(var i: longint; const ACode: string; Options: TCGSeekOptions = []): boolean; overload;
    function IsCod(tf: TFldEdit; const ACode: string; Options: TCGSeekOptions = []): boolean; overload;
    function IsCod(const ACode: string; Options: TCGSeekOptions = []): boolean; overload;
    function CodeName(tf: TFldEdit; const ACode: string; Options: TCGSeekOptions = []): string; overload;
    function CodeName(const ACode: string; Options: TCGSeekOptions = []): string; overload;
    function CodeDop(tf: TFldEdit; const ACode: string; Options: TCGSeekOptions = []): string; overload;
    function CodeDop(const ACode: string; Options: TCGSeekOptions = []): string; overload;
    procedure CodeDopSelf(var ACode: string; Options: TCGSeekOptions = []);
    function Codes(tf: TFldEdit; const ACode: string; Options: TCGSeekOptions = []): string; overload;
    function Codes(const ACode: string; Options: TCGSeekOptions = []): string; overload;
    function Codest(tf: TFldEdit; const ACode: string; Options: TCGSeekOptions = []): string; overload;
    function Codest(const ACode: string; Options: TCGSeekOptions = []): string; overload;
		procedure ClearBuf;
		procedure ClearBufCod(tf: TFldEdit; const cCode: string);
		procedure BufCodLoadAll;
		function GetNameDop(i: longint): TArrBoolStr; overload;
		function GetNameDop(tf: TFldEdit; const ACode: string; Options: TCGSeekOptions = []): TArrBoolStr; overload;
		function GetNameDop(const ACode: string; Options: TCGSeekOptions = []): TArrBoolStr; overload;
		procedure DefLen;
    function CodLen: longint;
		class procedure ClearBufAll;
		procedure MaskPrn(const Mask: string; LsPrn: TStringList); override;
		class function MaskTextReadOnly: boolean; override;
		procedure StdDWFldInfo(const Mask: string; var FldInfo: TDWFldInfo); override;
		procedure StdDWFldValue(r: TCustomRec; const Mask: string; var Value: variant); override;
    class function IsFlt(tf: TFldEdit): boolean;
    procedure FltList(tf: TFldEdit; const aCode: array of string); virtual;
    class function CodeInFlt(tf: TFldEdit; const Code: string): boolean;
    class function MaskToPrm(const ms: string): TCGParam; virtual;
    class function PrmToMask(const Prm: TCGParam): string; virtual;
    function Name2Cod(const name: string; var cod: string): boolean;
    procedure SelAdd(const tbl,nmf: string); overload;
    procedure SelAdd(r: TRecDB; const nmf: string); overload;
    procedure SelDel(const tbl,nmf: string); overload;
    procedure SelDel(r: TRecDB; const nmf: string); overload;
    function SelCodCanDel(const cod: string; lLike: boolean = false; const where: string = ''): boolean; overload;
    class function SelCodCanDel(const ag: array of TCodeGet; const cod: string; lLike: boolean = false; const where: string = ''): boolean; overload;
    procedure SelCodCng(const ocod,ncod: string; lLike: boolean = false; const where: string = ''); overload;
    class procedure SelCodCng(const ag: array of TCodeGet; const ocod,ncod: string; lLike: boolean = false; const where: string = ''); overload;
    function SelWhere: string; overload;
    function SelWhere(const cod: string; lLike: boolean = false): string; overload;
    class function SelWhere(const ag: array of TCodeGet; const cod: string; lLike: boolean = false): string; overload;
    class function SelWhere(const ag: array of TCodeGet): string; overload;
    function SelRVName: string; virtual;
    class procedure SelListLoad(tf: TFldEdit;
      ls: TStringList; q: TBrQuery = nil; Opt: TCGSelListLoadOpt = []); overload;
    procedure SelListLoad(const Value: string;
      ls: TStringList; q: TBrQuery = nil; Opt: TCGSelListLoadOpt = []); overload;
    class procedure SelListSave(tf: TFldEdit; ls: TStringList); overload;
    class function SelListSave(ls: TStringList): string; overload;
    class procedure SelChange(Sender: TObject; lAny: boolean = false);
    function bmCheckPaint(Browl: TBrowl; const ARect: TRect; Column: TColumn; Field: TField; lsCode: TStrings;
      lSet: boolean = true): boolean; overload;
    function bmCheckPaint(Browl: TBrowl; const ARect: TRect; Column: TColumn; Field,FieldCode: TField; lsCode: TStrings;
      lSet: boolean = true): boolean; overload;
    procedure FltLsSet(tf: TFldEdit; q: TMulQuery);
    procedure FltLsClear(tf: TFldEdit; q: TMulQuery);
   	property SelFlt[const Index: string]: variant read GetSelFlt write SetSelFlt;
  published
  { Published declarations }
    property Connection: TComponent read GetConnection write SetConnection;
   	property FieldsCode: string index 1 read GetDimStr write SetDimStr;
   	property FieldsName: string index 2 read GetDimStr write SetDimStr;
   	property GlobKey: string read FGlobKey write SetGlobKey;
   	property OrderCode: longint index 1 read GetDimInt write SetDimInt;
   	property OrderName: longint index 2 read GetDimInt write SetDimInt;
   	property Part: string read FPart write SetPart;
   	property MulPar: TMulQueryMulPar read FMulPar write SetMulPar;
    property TrimLeft: boolean read FTrimLeft write FTrimLeft;
  	property ListFindEqual: boolean read FListFindEqual write FListFindEqual;
	 	property OnBufCodCng: TCGBufCodCngEvent read FOnBufCodCng write FOnBufCodCng;
	 	property OnFormList: TCGFormListEvent read FOnFormList write FOnFormList;
	 	property OnFormIBList: TCGFormIBListEvent read FOnFormIBList write FOnFormIBList;
	 	property OnIncWidthListDown: TCGIncWidthListDownEvent read FOnIncWidthListDown write FOnIncWidthListDown;
    property OnListFind: TCGListFindEvent read FOnListFind write FOnListFind;
    property OnNameWhere: TCGNameWhereEvent read FOnNameWhere write FOnNameWhere;
	 	property OnPaint: TCGPaintEvent read FOnPaint write FOnPaint;
    property OnQueryWhere: TCGQueryWhereEvent read FOnQueryWhere write FOnQueryWhere;
	 	property OnStrCode: TStrBrqEvent read FOnStrCode write FOnStrCode;
	 	property OnStrDop: TStrBrqEvent read FOnStrDop write SetOnStrDop;
	 	property OnStrName: TStrBrqEvent read FOnStrName write FOnStrName;
	 	property OnTransSeek: TCGTransEvent read FOnTransSeek write FOnTransSeek;
  { Унаследованные }
   	property LenCode;
   	property LenName;
    property OnSizeAuto;
    property OnMaskTrans;
    property OnMaskHelp;
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

  TArrCodeGet = array of TCodeGet;
  TArrBoolCodeGet = array[boolean] of TCodeGet;

const cFmlText ='@F';

var ArrvCodeGetFormIBList: TCGFormIBListEvent;
  ArrvCodeGetAfterList: TNotifyEvent;
  SelGetReassign: procedure(var g: TCodeGet; const r: TDWVidRec);

function IsSelCodeGet(var g: TCodeGet; const TblFld,SelVid,SelVName: string): boolean;
function SelRdbDefFld(r: TRecDB; const cnmf: string): string;
procedure AddFrom(var Dest: TArrCodeGet; Source: TCodeGet); overload;
function bmCheckPaint(Browl: TBrowl; const ARect: TRect; Column: TColumn; Field: TField;
  tf: TFldEdit; lsCode: TStrings; lSet: boolean = true): boolean; overload;
procedure Register;

implementation

uses Math,SysUtils,Forms,Variants,MaskUtils,StrUtils,StdCtrls,
  FPanel,FrmEmpty,Schem,KeyLb,KeyMenu,StrBrowl,DefEdit,Inter;

var LsSelCodeGet: TStringList;

function IsSelCodeGet;
begin
  AddStack('Codegets.IsSelCodeGet');
  if not PointerObjFind(LsSelCodeGet,TblFld,pointer(g)) then
    if not empty(SelVid) then NameGet(TCustomGet(g),SelVid,SelVName,TCodeGet);
  result:=Assigned(g);
  DelStack;
end;

function SelRdbDefFld;
var i: longint;
begin
  AddStack('Codegets.SelRdbDefFld');
  result:=TrimUpper(cnmf);
  if r is TRecDBDef then with TRecDBDef(r) do
    for i:=0 to FldDef.Count-1 do with DWSToRec(i) do if TrimUpper(Name)=result then begin
      result:=dwCod;
      if SvType=dwsNoFix then Delete(result,1,1);
      IncL(result,FixSt(sFixSel)); break;
    end;
  DelStack;
end;

procedure AddFrom(var Dest: TArrCodeGet; Source: TCodeGet);
var j: longint;
begin
	AddStack('Codegets.AddFrom');
  j:=Length(Dest); SetLength(Dest,j+1); Dest[j]:=Source;
  DelStack;
end;

function bmCheckPaint(Browl: TBrowl; const ARect: TRect; Column: TColumn; Field: TField;
  tf: TFldEdit; lsCode: TStrings; lSet: boolean = true): boolean;
var g: TCodeGet;
begin
  AddStack('Codegets.bmCheckPaint');
  result:=false;
  if Assigned(tf) then if IsClass(tf.curget.SelCodeGet,TCodeGet,pointer(g))
  then result:=g.bmCheckPaint(Browl,ARect,Column,Field,lsCode,lSet);
  DelStack;
end;

{ TCodeGet }
constructor TCodeGet.Create;
begin
	AddStack('TCodeGet.Create',Self);
	inherited Create(AOwner);
  BufCod:=TStringListCase.CreateSort; BufName:=SortStrListCreate(dupAccept); FCodLen:=-1;
  SetLength(aCodNameDop,10); SetLength(aCodName,10); SetLength(aNameCod,10);
	FQuery:=TBrQuery.CreateConnection(Self);
  FMulPar:=TMulQueryMulPar.Create; FMulPar.OnChange:=MulParChange;
  lo:=-1; OrderCode:=1; OrderName:=2;
  MulPar.Text:=SGlobKey+'="%"'+CRLF+SCod_C+'="%"'+CRLF
    +sTABLE+'='+CRLF+sC_LIST+'=*'+CRLF
    +sWHERE+'=_'+sLIKE+qGlobKey+sAND+'_'+qCod_C;
  Part:=sSELECT_WORDER; UpdateAllFld(mgCreate);
  DelStack;
end;

destructor TCodeGet.Destroy;
var i: longint;
begin
	AddStack('TCodeGet.Destroy',Self);
	inherited Destroy;
	ClearBuf; BufCod.Free; BufName.Free; FMulPar.Free; 
  i:=0;
  while i<LsSelCodeGet.Count do SelDel(i);
  lsSelFlt.Free;
  DelStack;
end;

procedure TCodeGet.ClearBuf;
var i: longint;
begin
	AddStack('TCodeGet.ClearBuf',Self);
	for i:=0 to BufCod.Count-1 do BufCodCng(i);
  BufCod.Clear; BufName.Clear; BufLoaded:=false;
  DelStack;
end;

procedure TCodeGet.ClearBufCod;
var iCod,iNm: longint;
  nm: string;
begin
	AddStack('TCodeGet.ClearBufCod',Self);
  if BufCod.Find(TransSeek(tf,cCode,0,true),iCod) then begin
    if Assigned(FOnStrDop) then nm:=GetCodNameDop(iCod).Name else nm:=GetCodName(iCod)^;
    with BufName do if Find(nm,iNm) then while iNm<Count do begin
      if Strings[iNm]<>nm then break;
      if GetNameCod(iNm)^=BufCod[iCod] then begin
        SLObjIndDel(BufName,iNm,DelName); break;
      end;
      Inc(iNm);
    end;
    BufCodCng(iCod); SLObjIndDel(BufCod,iCod,DelCod); BufLoaded:=false;
  end;
  DelStack;
end;

procedure TCodeGet.DelCod;
begin
  AddStack('TCodeGet.DelCod',Self);
  if Assigned(FOnStrDop) then aCodNameDop[ni]:=aCodNameDop[oi] else aCodName[ni]:=aCodName[oi];
  DelStack;
end;

procedure TCodeGet.DelName;
begin
  AddStack('TCodeGet.DelName',Self);
  aNameCod[ni]:=aNameCod[oi];
  DelStack;
end;

function TCodeGet.GetCodNameDop;
begin
  AddStack('TCodeGet.GetCodNameDop',Self);
  result:=@aCodNameDop[IntObj(BufCod,i)];
  DelStack;
end;

function TCodeGet.GetCodName;
begin
  AddStack('TCodeGet.GetCodName',Self);
  result:=@aCodName[IntObj(BufCod,i)];
  DelStack;
end;

function TCodeGet.GetNameCod;
begin
  AddStack('TCodeGet.GetNameCod',Self);
  result:=@aNameCod[IntObj(BufName,i)];
  DelStack;
end;

function TCodeGet.Name2Cod;
var n: longint;
begin
  AddStack('TCodeGet.Name2Cod',Self);
  result:=IntObjFind(BufName,name,n);
  if result then cod:=BufCod[n];
  DelStack;
end;

procedure TCodeGet.BufCodCng;
begin
  AddStack('TCodeGet.BufCodCng',Self);
  if Assigned(FOnBufCodCng) then FOnBufCodCng(Self,BufCod[i],qApp);
  DelStack;
end;

class procedure TCodeGet.ClearBufAll;
var i: longint;
  g: TCodeGet;
begin
	AddStack('TCodeGet.ClearBufAll');
	if Assigned(LsCustomGet) then for i:=0 to LsCustomGet.Count-1 do
    if IsClass(LsCustomGet.Objects[i],TCodeGet,pointer(g)) then g.ClearBuf;
  DelStack;
end;

function TCodeGet.GetConnection;
begin
	AddStack('TCodeGet.GetConnection',Self);
  result:=FQuery.Connection;
  DelStack;
end;

procedure TCodeGet.SetConnection;
begin
  AddStack('TCodeGet.SetConnection',Self);
  if FQuery.Connection<>Value then begin
	  FQuery.Connection:=Value; MulParChange(FMulPar); FQuery.Part:=FPart;
    if Assigned(lsSelFlt) then lsSelFlt.Clear;
  end;
  DelStack;
end;

function TCodeGet.GetDimInt;
begin
	AddStack('TCodeGet.GetDimInt',Self);
	result:=FDimInt[Index];
  DelStack;
end;

procedure TCodeGet.SetDimInt;
begin
	AddStack('TCodeGet.SetDimInt',Self);
	FDimInt[Index]:=Value;
  DelStack;
end;

function TCodeGet.GetDimStr;
begin
	AddStack('TCodeGet.GetDimStr',Self);
	result:=FDimStr[Index];
  DelStack;
end;

procedure TCodeGet.SetDimStr;
begin
	AddStack('TCodeGet.SetDimStr',Self);
	FDimStr[Index]:=Value;
  DelStack;
end;

procedure TCodeGet.SetGlobKey;
begin
	AddStack('TCodeGet.SetGlobKey',Self);
	if FGlobKey<>Value then begin
		FGlobKey:=Value;
    MulPar.Values[SGLOBKEY]:='"'+IfThen(FGlobKey='','%',FGlobKey)+'"';
    ClearBuf;
  end;
  DelStack;
end;

procedure TCodeGet.SetPart;
begin
	AddStack('TCodeGet.SetPart',Self);
  if FPart<>Value then begin
    FPart:=Value;
	  if Assigned(FQuery.DataSet) then FQuery.Part:=Value;
    UpdateAllFld(mgReCreate);
  end;
  DelStack;
end;

procedure TCodeGet.SetMulPar;
begin
	AddStack('TCodeGet.SetMulPar',Self);
	FMulPar.Assign(Value);
  DelStack;
end;

procedure TCodeGet.SetOnStrDop;
begin
  AddStack('TCodeGet.SetOnStrDop',Self);
  ClearBuf; FOnStrDop:=Value; 
  DelStack;
end;

procedure TCodeGet.MulParChange;
var i{,p}: longint;
  s: string;
begin
	AddStack('TCodeGet.MulParChange',Self);
  if Assigned(FQuery.DataSet) then begin
    for i:=0 to FMulPar.Count-1 do begin
      s:=FMulPar.Names[i];
      if s<>'' then FQuery.Arg[s]:=FMulPar.ValueFromIndex[i];
    end;
    UpdateAllFld(mgReCreate);
  end;
  ClearBuf;
  DelStack;
end;

{ Создать объекты }
procedure TCodeGet.CreateObj;
begin
	AddStack('TCodeGet.CreateObj',Self);
	inherited CreateObj(tf);
	if inherited AssignObj(tf) then begin
    DefLen; //SetDefLenCode; SetDefLenName;
    with eC do begin
      MaxLength:=FDefLenCode;
      onEnter:=eCEnter;
      onExit:=eCExit;
      onClick:=tf.EdClick;
      onDblClick:=tf.EdDblClick;
      onKeyDown:=tf.EdKeyDown;
      onKeyPress:=tf.EdKeyPress;
      onKeyUp:=tf.EdKeyUp;
      onMouseDown:=tf.EdMouseDown;
      onMouseMove:=tf.EdMouseMove;
      onMouseUp:=tf.EdMouseUp;
    end;
    with eN do begin
      MaxLength:=FDefLenName;
      onEnter:=eNEnter;
      onClick:=tf.EdClick;
      onDblClick:=tf.EdDblClick;
      onKeyDown:=tf.EdKeyDown;
      onKeyPress:=tf.EdKeyPress;
      onKeyUp:=tf.EdKeyUp;
      onMouseDown:=tf.EdMouseDown;
      onMouseMove:=tf.EdMouseMove;
      onMouseUp:=tf.EdMouseUp;
    end;
    eC.Enabled:=true;
    sT:=TPaintButton.Create(tf);
    with sT do begin
      Canvas:=tf.Canvas; Hint:='Код/наименование'; ShowHint:=true;
      BMByName(Glyph,bmLeft_Right); onClick:=TabClick;
    end;
    tf.ReCreateObj;
  end;
  DelStack;
end;

{ Переустановить свойства объектов }
procedure TCodeGet.ReCreateObj;
var s: string;
begin
	AddStack('TCodeGet.ReCreateObj',Self);
	if AssignObj(tf) then begin
    sT.Visible := tf.Visible and Param.lNameGet and not Param.lNameOnly and not Assigned(bDyn);
    eC.Visible := tf.Visible and not Param.lNameOnly;
    eC.AutoSelect := ogAutoSelect in tf.Options;
    eN.Visible := tf.Visible and not Param.lCodOnly;
    eN.Enabled:=Param.lNameGet;
    eC.ReadOnly := (ogReadOnly in tf.Options) or Assigned(bDyn);
    eN.ReadOnly:=eC.ReadOnly; eN.AutoSelect:=eC.AutoSelect;
    eC.TrimLeft := (ogTrimLeft in tf.Options) or FTrimLeft;
    s:=Param.Mask
      +IfThen((Param.Mask<>'') and (Pos(MaskFieldSeparator,Param.Mask)=0),
      MaskFieldSeparator+'1'+MaskFieldSeparator+' ');
    if eC.EditMask<>s then eC.EditMask:=s;
    inherited ReCreateObj(tf);
    eN.CharCase:=ecNormal;
  end;
  DelStack;
end;

{ Достать значение Value из объектов }
function TCodeGet.GetValue;
begin
	AddStack('TCodeGet.GetValue',Self);
	AssignObj(tf); result:=TransSeek(tf,IfThenGetText(eC),FDefLenCode);
  DelStack;
end;

function CodeEmpty(const v: variant): boolean;
begin
  result:=empty(v);
end;

{ Установить свойства объектов в соответствии с Value }
procedure TCodeGet.SetValue;
var sn,v: string;
begin
	AddStack('TCodeGet.SetValue',Self);
	if AssignObj(tf) then begin
    v:=TransSeek(tf,vv);
    if CodeEmpty(v) then sn:='' else sn:=GetNameText(tf,v);
    eC.Text:=TrimRight(v); eN.Text:=TrimRight(sn); AutoSelect(tf); tf.PaintObj;
  end;
  DelStack;
end;

function TCodeGet.GetNameText;
begin
  AddStack('TCodeGet.GetNameText',Self);
  result:=CodeName(tf,ACode);
  DelStack;
end;

function TCodeGet.GetNameDop(i: longint): TArrBoolStr;
var p: PBufCod;
begin
  AddStack('TCodeGet.GetNameDop',Self);
	result[true]:='';
	if i<0 then result[false]:=''
  else if Assigned(FOnStrDop) then begin
    p:=GetCodNameDop(i); result[false]:=p.Name; result[true]:=p.Dop;
  end
  else result[false]:=GetCodName(i)^;
  DelStack;
end;

function TCodeGet.GetNameDop(tf: TFldEdit; const ACode: string; Options: TCGSeekOptions = []): TArrBoolStr;
begin
  result:=GetNameDop(SeekCod(tf,ACode,Options));
end;

function TCodeGet.GetNameDop(const ACode: string; Options: TCGSeekOptions = []): TArrBoolStr;
begin
  result:=GetNameDop(nil,ACode,Options);
end;

function TCodeGet.ValEmp;
var vv: variant;
begin
  AddStack('TCodeGet.ValEmp',Self);
  result:=Param.lEmpty;
  if result then begin
  	vv:=tf.VarValue;
  	if MyVarType(vv,true)=varString then vv:=v;
    result:=CodeEmpty(vv);
  end;
  DelStack;
end;

{ Проверка корректности значения }
function TCodeGet.Check;
var v: string;
begin
	AddStack('TCodeGet.Check',Self);
	result:=inherited Check(tf);
  if result then if AssignObj(tf) then if not Param.lAny then begin
    v:=GetValue(tf);
    if not ValEmp(tf,v) then
      if IsFlt(tf) then begin
        FltList(tf,[v]); result:=CodeInFlt(tf,v);
      end
      else result:=IsCod(tf,v);
  end;
  DelStack;
end;

{ Поиск объектов }
class function TCodeGet.MaskToPrm;
begin
	AddStack('TCodeGet.MaskToPrm');
	with result do begin
    lNameGet := Pos(cCdName,ms)>0;
    lCodFocus := Pos(cCdCod,ms)>0;
    lCodOnly := not lNameGet and lCodFocus;
    lNameOnly := lNameGet and (Pos(cCdNameOnly,ms)>0);
    lCodFocus := not lNameGet or lCodFocus and not lNameOnly;
    lEmpty := Pos(cCd0,ms)>0;
    lAny := Pos(cCdAny,ms)>0;
    Mask:=StrToAtPart(StrToAtPart(
      StrTran(Trim(ms),[cCdName,cCdCod,cCd0,cCdAny,cCdNameOnly],['','','','',''],[rfReplaceAll,rfIgnoreCase]),
      FmlFlt,cFmlText),Dop,cButCapt);
    StrTranSelf(FmlFlt,'^',CRLF);
  end;
  DelStack;
end;

class function TCodeGet.PrmToMask;
begin
  AddStack('TCodeGet.PrmToMask');
  with Prm do result:=Trim(Mask)+StrTran(AtPartToStr(FmlFlt,cFmlText),CRLF,'^')+AtPartToStr(Dop,cButCapt)
    +IfThen(lNameGet,cCdName+IfThen(lNameOnly,cCdNameOnly))
  	+IfThen(lNameGet and lCodFocus or not lNameGet and lCodOnly,cCdCod)
    +IfThen(lAny,cCdAny)+IfThen(lEmpty,cCd0);
  DelStack;
end;

function TCodeGet.AssignObj;
var i: longint;
  p: TPaintButton;
begin
	AddStack('TCodeGet.AssignObj',Self);
	sT:=nil; result:=false;
  if inherited AssignObj(tf) then with tf do begin
    for i:=0 to ComponentCount-1 do
    	if IsClass(Components[i],TPaintButton,pointer(p)) then if p.Tag<>1 then if p<>bDyn then begin
        sT:=p; result:=true; break;
      end;
	  Param:=MaskToPrm(Mask);
  end;
  DelStack;
end;

{ Выполнить SQL-запрос }
function TCodeGet.DoSQL;
var fl: boolean;
	ost: longint;
begin
	ost:=AddStack('TCodeGet.DoSQL',Self);
	FQuery.Close; FQuery.ConnectionDef;
  if Assigned(FQuery.Connection) then begin
  	FQuery.Arg[sO_LIST]:=IfThen(NameFocus,FieldsName,FieldsCode);
    if Assigned(FOnQueryWhere) then FQuery.Arg[sWHERE]:=FOnQueryWhere(Self,PrmCode)
    else if PrmCode='%' then FQuery.Arg[SCOD_C]:='"%"'
		else FQuery.Arg[SCOD_C]:=QQs(TrimSpRight(PrmCode)+'%');
    fl:=Assigned(tf);
    if lNmSQL<>fl then begin
      if fl then FQuery.Arg['owhere']:=FQuery.Arg[sWHERE]
      else FQuery.Arg[sWHERE]:=FQuery.Arg['owhere'];
      lNmSQL:=fl;
    end;
    try
      FQuery.Open; FQuery.First;
    except
      SetStack(ost);
    end;
  end;
  result:=FQuery.Active;
  DelStack;
end;

function TCodeGet.NameWhere;
begin
  AddStack('TCodeGet.NameWhere',Self);
  if Assigned(FOnNameWhere) then result:=FOnNameWhere(Self,tf,Cod,Dop,op,p) else result:=true;
  DelStack;
end;

// Длина кода по умолчанию
procedure TCodeGet.SetDefLenCode;
begin
	{AddStack('TCodeGet.SetDefLenCode',Self);
  //inherited SetDefLenCode;
  DefLen;
  DelStack;}
end;

// Длина наименования по умолчанию
procedure TCodeGet.SetDefLenName;
begin
	{AddStack('TCodeGet.SetDefLenName',Self);
  //inherited SetDefLenName;
  DefLen;
  DelStack;}
end;

procedure TCodeGet.DefLen;
var oAct,fl: boolean;
begin
  AddStack('TCodeGet.DefLen',Self);
  if (FDefLenCode=0) and (LenCode<>0) then FDefLenCode:=LenCode;
  if (FDefLenName=0) and (LenName<>0) then FDefLenName:=LenName;
  if (FDefLenCode=0) or (FDefLenName=0) or (FCodLen<0) then begin
    oAct:=FQuery.Active;
    if oAct then fl:=true else fl:=DoSQL(#31);
    if fl then begin
      if FCodLen<0 then
      	if FDefLenCode=0 then FCodLen:=Length(StrCode(FQuery)) else FCodLen:=FDefLenCode;
    	if FDefLenCode=0 then	FDefLenCode:=FCodLen;
      if FDefLenName=0 then	FDefLenName:=length(StrName(FQuery));
    end;
    FQuery.Active:=oAct;
    if FDefLenCode=0 then FDefLenCode:=1;
    if FDefLenName=0 then FDefLenName:=10;
  end;
  DelStack;
end;

function TCodeGet.StrBrq;
begin
  AddStack('TCodeGet.StrBrq',Self);
  if Assigned(Proc) then result:=Proc(Self,Sender) else result:=FieldAsVariant(Sender.FindField(nmf));
  DelStack;
end;

function TCodeGet.StrCode;
begin
	AddStack('TCodeGet.StrCode',Self);
  result:=StrBrq(Sender,FOnStrCode,FieldsCode);
  DelStack;
end;

function TCodeGet.StrName;
begin
	AddStack('TCodeGet.StrName',Self);
  result:=StrBrq(Sender,FOnStrName,fNAME);
  DelStack;
end;

function TCodeGet.StrDop;
begin
	AddStack('TCodeGet.StrDop',Self);
	if Assigned(FOnStrDop) then result:=FOnStrDop(Self,Sender) else result:='';
  DelStack;
end;

{ Преобразование значения для поиска }
function TCodeGet.TransSeek(tf: TFldEdit; const Value: string; Size: longint = 0; lSQL: boolean = false): string;
begin
	AddStack('TCodeGet.TransSeek',Self);
  if Size=0 then Size:=CodLen;
  if Assigned(FOnTransSeek)
  then result:=FOnTransSeek(Self,tf,Value,Size,lSQL)
  else result:=TransMask(Value,Size,msk9);
  DelStack;
end;

function TCodeGet.TransSeek(const Value: string; Size: longint = 0; lSQL: boolean = false): string;
begin
  result:=TransSeek(nil,Value,Size,lSQL);
end;

function TCodeGet.CodLen;
begin
	AddStack('TCodeGet.CodLen',Self);
  DefLen; result:=max(0,FCodLen);
  DelStack;
end;

{ Вызов выпадающего списка }
procedure TCodeGet.StdListDown;
  procedure vSet(const s: string);
  begin
    AddStack('TCodeGet.StdListDown.vSet');
    tf.Value:=s; tf.Write;
    DelStack;
  end;
var br: TBrowl;
  frm: TFormNul;
  function SeekBr(f: TFormNul): boolean;
  var i: longint;
  begin
    AddStack('TCodeGet.StdListDown.SeekBr',Self);
    result:=false;
    if Assigned(f) then begin
      i:=f.Perform(WM_BROWLFORM,0,0);
      if i<>0 then begin
        frm:=f; br:=pointer(i); result:=true;
      end;
    end;
    DelStack;
  end;
var wb,ord: longint;
	lsel,lFind: boolean;
  gk,sc,sn: string;
  pr: TRect;
  oAct,fAct: TNotifyEvent;
  ofrm: TForm;
  bm: TBookMark;
  q: TBrQuery;
  owp: PWindowPlacement;
  opl: TRbPanelPlace;
  wp: TWindowPlacement;
begin
	AddStack('TCodeGet.StdListDown',Self);
	if AssignObj(tf) then begin
    frm:=nil;
    if not SeekBr(DoFormIBList(tf)) then SeekBr(DoFormList(tf));
    if Assigned(frm) then with frm do begin
      br.FindQuery; q:=pointer(br.Qry); 
      if IsLastForm(ofrm) then begin
        oAct:=ofrm.OnActivate; ofrm.OnActivate:=nil;
      end
      else oAct:=nil;
      lsel:=br.CloseOnSelect; br.CloseOnSelect:=true;
      gk:=q.GlobKey; q.GlobKey:=GlobKey; ord:=q.Order; q.Order:=IfThen(NameFocus,OrderName,OrderCode);
      osk:=q.SeekKeys; q.SeekKeys:='';
      FltLsSet(tf,q); q.Open; q.DisableControls; q.First;
      if not KeyLb1.IsKeyBut(K_F6) then br.DoEnter;
      opl:=RbPanel1.Place; 
      if WindowState=wsMaximized then owp:=nil
      else begin
        New(owp); owp.length:=SizeOf(owp^); GetWindowPlacement(Handle,owp);
        RbPanel1.Place:=rpRight; BoundsRect:=SysWorkArea;
        wb:=br.Width+RbPanel1.BevPanel2+Width-ClientWidth+KeyLb1.Width+IncWidthListDown(frm);
        if frm is TFormEmp then Inc(wb,TFormEmp(frm).RbPanel2.BevPanel2);
        pr:=SysWorkArea;
        EnsureSelf(wb,RectList.Right-RectList.Left+1,pr.Right-pr.Left);
        wp:=owp^; wp.showCmd:=SW_HIDE;
        wp.rcNormalPosition:=Rect(min(RectList.Left,pr.Right-wb),RectList.Top,wb,RectList.Bottom);
        Inc(wp.rcNormalPosition.Right,wp.rcNormalPosition.Left);
        SetWindowPlacement(Handle,@wp);
        frm.RbFormResize;
        ClientHeight:=max(RbPanel1.HMin,ClientHeight);
        if (RbPanel1.WMin>ClientWidth) then begin
          SetWindowPlacement(Handle,owp); RbPanel1.Place:=opl; MainRebuild;
        end;
        FormOnScreen;
      end;
      lFind:=false; ListFind(tf,q,lFind);
      with q do begin
        if not lFind then begin
          q.First; sc:=TrimRight(TransSeek(tf,eC.Text));
          if NameFocus then begin
            sn:=RTrimUpper(eN.Text);
            while not Eof and (RTrimUpper(StrName(q))<sn) do Next;
            if not Eof then begin
              bm:=GetBookMark;
              try
                while not Eof and AnsiStartsText(sn,StrName(q))
                  and (TrimRight(StrCode(q))<>sc) do Next;
                if Eof or not AnsiStartsText(sn,StrName(q)) then GotoBookMark(bm);
              finally
                FreeBookMark(bm);
              end;
            end;
          end
          else if FListFindEqual
            then while not Eof and (TrimRight(StrCode(q))<>sc) do Next
            else while not Eof and (TrimRight(StrCode(q))<sc) do Next;
          if Eof then First;
        end;
        EnableControls;
      end;
      fAct:=OnActivate; OnActivate:=Self.FormActivate; PFormList:=frm; BrQuery1:=q;
      ShowModal;
      if AssignObj(tf) then
        if ModalResult=mrOk
        then vSet(StrCode(q))
        else if not NameFocus then vSet(eC.Text);
      FltLsClear(tf,q);
      if not IsFlt(tf) then if not BufLoaded then begin
      	BufLoad(tf,q); BufLoaded:=true;
      end;
      OnActivate:=fAct;
      q.Active:=false; q.Order:=ord; q.GlobKey:=gk;
      if Assigned(owp) then begin
        owp.showCmd:=SW_HIDE; SetWindowPlacement(Handle,owp); RbPanel1.Place:=opl; Dispose(owp);
      end;
      br.CloseOnSelect:=lsel;
      if Assigned(ofrm) then ofrm.OnActivate:=oAct;
    end;
  end;
  DelStack;
end;

procedure TCodeGet.ListFind;
begin
  AddStack('TCodeGet.ListFind',Self);
  if Assigned(FOnListFind) then FOnListFind(Self,tf,Qry,result);
  DelStack;
end;

function TCodeGet.IncWidthListDown;
begin
  AddStack('TCodeGet.IncWidthListDown',Self);
  if Assigned(FOnIncWidthListDown) then result:=FOnIncWidthListDown(Self,f) else result:=0;
  DelStack;
end;

procedure TCodeGet.Paint;
begin
  AddStack('TCodeGet.Paint',Self);
  inherited Paint(tf);
  if Assigned(FOnPaint) then FOnPaint(Self,tf);
  DelStack;
end;

procedure TCodeGet.BufLoad;
begin
  AddStack('TCodeGet.BufLoad',Self);
  PointerDef(pointer(q),FQuery);
  with q do if IsRecords then begin
    First; BufCod.BeginUpdate; BufName.BeginUpdate;
    while not Eof do begin
      BufCodAdd(tf,q); Next;
    end;
    BufCod.EndUpdate; BufName.EndUpdate;
  end;
  DelStack;
end;

function TCodeGet.DoFormList;
begin
  AddStack('TCodeGet.DoFormList',Self);
  if Assigned(FOnFormList) then result:=FOnFormList(tf) else result:=nil;
  DelStack;
end;

function TCodeGet.DoFormIBList;
begin
  AddStack('TCodeGet.DoFormIBList',Self);
  if Assigned(FOnFormIBList) then result:=FOnFormIBList(tf) else result:=nil;
  DelStack;
end;

procedure TCodeGet.ListExec;
begin
  AddStack('TCodeGet.ListExec',Self);
  DoFormIBList(nil).ShowModal; AfterList;
  DelStack;
end;

procedure TCodeGet.FormActivate;
begin
	AddStack('TCodeGet.FormActivate',Self);
  if Assigned(PFormList) then BrQuery1.SeekKeys:=osk;
  DelStack;
end;

{ Действия при получении фокуса }
procedure TCodeGet.DoEnter;
var tl: TKeyLb;
begin
	AddStack('TCodeGet.DoEnter',Self);
	inherited DoEnter(tf);
	if AssignObj(tf) then begin
    if Param.lCodFocus
    then GetParentForm(tf).ActiveControl:=eC
    else GetParentForm(tf).ActiveControl:=eN;
    if FormKeyLb(tf,tl) then
	    if AssignObj(tf) and not((ogReadOnly in tf.Options) or Assigned(bDyn)) then begin
        if not Param.lCodOnly then tl.SetKeyFind(ProcKey,'codeget',kmEdit,false);
        if Param.lNameGet and not Param.lNameOnly then tl.SetKey(K_F11,'Код/наим.','Код/наименование',
          ProcKey,'codeget',kmEdit);
        tl.ReDrw;
      end;
  end;
  tf.ValueRepeat; // для перерисовки наименования
  DelStack;
end;

{ Действия при утере фокуса }
procedure TCodeGet.DoExit;
var tl: TKeyLb;
begin
	AddStack('TCodeGet.DoExit',Self);
  if FormKeyLb(tf,tl)
  //and Assigned(GetParentForm(tf).ActiveControl)
	then tl.DelKey(K_All,'codeget');
	inherited DoExit(tf);
  DelStack;
end;

{ Реакция на клавиши }
procedure TCodeGet.ProcKey;
var tf: TFldEdit;
begin
	AddStack('TCodeGet.ProcKey',Self);
	tf:=GetOwnerFldEdit(tw);
	if AssignObj(tf) then
    if key=K_F11 then DoTab(tf) else WinFindKey(Key,eN,NmFind,[fnoRegistr,fnoDirection]);
  DelStack;
end;

{ Поиск по наименованию }
function TCodeGet.NmFind;
var i,cnt: longint;
  lDone: boolean;
	function NextStat: boolean;
  begin
  	AddStack('TCodeGet.NmFind.NextStat',Self);
    FQuery.FindNext; result:=WinFindSayStat(i/cnt); Inc(i);
    if lDone then lDone:=not result;
    DelStack;
  end;
var lr: longint;
  procedure Find1;
  begin
  	AddStack('TCodeGet.NmFind.Find1',Self);
    if lDone then while not FQuery.FindEof and (lr>0) do begin
      if AnsiStartsStr(sf,FindRegistrStr(StrName(FQuery))) then begin
        result:=true; break;
      end;
      if NextStat then break;
      if not FQuery.FindEof then Dec(lr);
    end;
    DelStack;
  end;
var tf: TFldEdit;
	ii: longint;
  f: TField;
  v: string;
begin
	AddStack('TCodeGet.NmFind',Self);
	tf:=GetOwnerFldEdit(Sender); result:=false; ii:=0; v:=tf.Value;
  if not CodeEmpty(v) then
    if DoSQL(TransSeek(tf,v,0,true)) then
      if not FQuery.Eof then
        if FQuery.FindField(fRECNO,f) then ii:=f.AsInteger;
  if DoSQL then with FQuery do begin
    if not WinFindSayStat(0) then begin
      DisableControls; lr:=RecordCount; cnt:=lr; i:=1; lDone:=true;
      if lr<>0 then begin
        if ii=0 then FindFirst
        else begin
          GotoRec(ii); NextStat; Dec(lr);
        end;
      end;
      Find1;
      if not result then begin
        FindFirst; Find1;
      end;
      if result then tf.Value:=StrCode(FQuery);
      EnableControls;
    end;
    Close;
  end;
  DelStack;
end;

{ Щелчок на кнопке Tab }
procedure TCodeGet.TabClick;
var tf: TFldEdit;
begin
	AddStack('TCodeGet.TabClick',Self);
	tf:=pointer(TPaintButton(Sender).Owner);
  if not tf.Active then DoEnter(tf) else DoTab(tf);
  DelStack;
end;

{ Переход "Код/наименование" }
procedure TCodeGet.DoTab;
begin
	AddStack('TCodeGet.DoTab',Self);
	if AssignObj(tf) and not(ogReadOnly in tf.Options) then begin
    SetNameValue(tf); NotD(NameFocus);
    if NameFocus then eN.SetFocus else eC.SetFocus;
  end;
  DelStack;
end;

procedure TCodeGet.eCEnter;
begin
	AddStack('TCodeGet.eCEnter',Self);
	NameFocus:=false;
  DelStack;
end;

procedure TCodeGet.eCExit;
var te: TFldMask;
begin
	AddStack('TCodeGet.eCExit',Self);
	te:=pointer(Sender); FldEditOwner(te).Value:=te.Text;
  DelStack;
end;

procedure TCodeGet.eNEnter;
begin
	AddStack('TCodeGet.eNEnter',Self);
	NameFocus:=true; TFldMask(Sender).Modified:=false;
  DelStack;
end;

{ Установка значения в соответствии с наименованием }
procedure TCodeGet.SetNameValue;
type TEqualOpt = set of (eqBeg,eqNameWhere);
var	i: longint;
	sn: string;
  p: Pointer;
	function Equal(Opt: TEqualOpt): boolean;
  var Dop: string;
		j: longint;
  begin
    AddStack('TCodeGet.SetNameValue.Equal',Self);
    if eqBeg in Opt then
    	if sn='' then result:=empty(BufName[i])
      else result:=AnsiStartsText(sn,SysUtils.TrimLeft(BufName[i]))
    else result:=true;
    if result and (eqNameWhere in Opt) then begin
    	BufCod.Find(GetNameCod(i)^,j);
      if Assigned(FOnStrDop) then Dop:=GetCodNameDop(j).Dop else Dop:='';
    	result:=NameWhere(tf,BufCod[j],Dop,cgwInclude,p);
    end;
    DelStack;
  end;
var sc: string;
	i1: longint;
  fl: boolean;
begin
	AddStack('TCodeGet.SetNameValue',Self);
	if NameFocus then
		if AssignObj(tf) then
		  if eN.Modified then begin
        sc:=TransSeek(tf,eC.Text,0,true); sn:=TrimUpper(eN.Text); i1:=-1;
        NameWhere(tf,'','',cgwCreate,p);
        try
          for fl:=false to true do begin
            i:=0;
            while i<BufName.Count do
              if Equal([eqBeg,eqNameWhere]) then begin
              	if fl then i1:=i;
                while i<BufName.Count do
                  if Equal([eqBeg]) then begin
                    if Equal([eqNameWhere]) then
                      if GetNameCod(i)^=sc then begin
                        i1:=i; break;
                      end;
                    Inc(i);
                  end
                  else break;
                break;
              end
              else Inc(i);
            if (i1<0) and not fl then begin
              if DoSQL then begin
                BufLoad(tf); FQuery.Close;
              end;
            end
            else break;
          end;
        finally
	        NameWhere(tf,'','',cgwFree,p);
        end;
        if i1>=0 then begin
        	eC.Text:=BufCod[BufCod.IndexOf(GetNameCod(i1)^)]; eN.Text:=TrimRight(BufName[i1]);
        end
        else eC.Text:='';
        AutoSelect(tf);
      end;
  DelStack;
end;

procedure TCodeGet.AutoSelect;
begin
  AddStack('TCodeGet.AutoSelect',Self);
  if NameFocus then eN.SelAll else eC.SelAll;
  DelStack;
end;

{ Можно ли выполнить клавишу }
function TCodeGet.MayDoKey;
var v: string;
begin
	AddStack('TCodeGet.MayDoKey',Self);
	result := inherited MayDoKey(tf,Key);
  SetNameValue(tf);
  if result then
  	if AssignObj(tf) then
      if not Assigned(bDyn) then begin
        if not NameFocus then tf.Value:=eC.Text;
        if Key=K_Enter then begin
          if Param.lAny then result:=true
          else begin
            v:=tf.Value;
            if ValEmp(tf,v) then result:=true else result:=IsCod(tf,v);
          end;
          if not result then sD.Click;
        end;
      end;
  DelStack;
end;

// Найти запись в кэше
function TCodeGet.SeekCod(tf: TFldEdit; const ACode: string; Options: TCGSeekOptions = []): longint;
var v: string;
begin
	AddStack('TCodeGet.SeekCod',Self);
  if cdgNoTrans in Options then v:=ACode else v:=TransSeek(tf,ACode,0,true);
  result:=BufCod.IndexOf(v);
  if (result<0) and not CodeEmpty(v) and (not(cdgNoSQL in Options) or not BufLoaded) then
	  if DoSQL(IfThen(cdgBufAll in Options,'%',v)) then begin
    	if cdgBufAll in Options then begin
        BufLoad(tf); BufLoaded:=true;
      end
      else if not FQuery.Eof then BufCodAdd(tf,FQuery);
      FQuery.Close; result:=BufCod.IndexOf(v);
    end;
  DelStack;
end;

function TCodeGet.SeekCod(const ACode: string; Options: TCGSeekOptions = []): longint;
begin
  result:=SeekCod(nil,ACode,Options);
end;

function TCodeGet.SeekCod(var i: longint; tf: TFldEdit; const ACode: string; Options: TCGSeekOptions = []): boolean;
begin
  i:=SeekCod(tf,ACode,Options); result := i>=0;
end;

function TCodeGet.SeekCod(var i: longint; const ACode: string; Options: TCGSeekOptions = []): boolean;
begin
  result:=SeekCod(i,nil,ACode,Options);
end;

{ Найти запись по коду }
function TCodeGet.IsCod(tf: TFldEdit; const ACode: string; Options: TCGSeekOptions = []): boolean;
var nf: boolean;
begin
  AddStack('TCodeGet.IsCod',Self);
	nf:=NameFocus; NameFocus:=false; result := SeekCod(tf,ACode,Options)>=0; NameFocus:=nf;
  DelStack;
end;

function TCodeGet.IsCod(const ACode: string; Options: TCGSeekOptions = []): boolean;
begin
  result:=IsCod(nil,ACode,Options);
end;

procedure TCodeGet.BufCodLoadAll;
begin
  AddStack('TCodeGet.BufCodLoadAll',Self);
  CodLen;
  if DoSQL('%') then begin
    BufLoad(nil); BufLoaded:=true; FQuery.Close;
  end;
  DelStack;
end;

procedure TCodeGet.BufCodAdd;
var ic,nc,inm,nnm: longint;
begin
	AddStack('TCodeGet.BufCodAdd',Self);
  if not IntObjFindAdd(BufCod,TransSeek(tf,StrCode(q),0,true),ic,nc) then begin
    nnm:=BufName.Count;
    if Length(aNameCod)=nnm then SetLength(aNameCod,nnm shl 1);
  	aNameCod[nnm]:=BufCod[ic]; inm:=BufName.AddObject(StrName(q),pointer(nnm));
  	if Assigned(FOnStrDop) then begin
      if Length(aCodNameDop)=nc then SetLength(aCodNameDop,nc shl 1);
      with aCodNameDop[nc] do begin
      	Name:=BufName[inm]; Dop:=StrDop(q);
      end;
    end
    else begin
      if Length(aCodName)=nc then SetLength(aCodName,nc shl 1);
      aCodName[nc]:=BufName[inm];
    end;
    BufCodCng(ic,q);
  end;
  DelStack;
end;

{ Наименование по коду }
function TCodeGet.CodeName(tf: TFldEdit; const ACode: string; Options: TCGSeekOptions = []): string;
begin
	AddStack('TCodeGet.CodeName',Self);
  result:=GetNameDop(tf,ACode,Options)[false];
  DelStack;
end;

function TCodeGet.CodeName(const ACode: string; Options: TCGSeekOptions = []): string;
begin
  result:=CodeName(nil,ACode,Options);
end;

{ Доп.строка по коду }
function TCodeGet.CodeDop(tf: TFldEdit; const ACode: string; Options: TCGSeekOptions = []): string;
begin
	AddStack('TCodeGet.CodeDop',Self);
  result:=GetNameDop(tf,ACode,Options)[true];
  DelStack;
end;

function TCodeGet.CodeDop(const ACode: string; Options: TCGSeekOptions = []): string;
begin
  result:=CodeDop(nil,ACode,Options);
end;

procedure TCodeGet.CodeDopSelf;
begin
  ACode:=CodeDop(ACode,Options);
end;

{ "Код - Наименование" по коду }
function TCodeGet.Codes(tf: TFldEdit; const ACode: string; Options: TCGSeekOptions = []): string;
var i: longint;
begin
	AddStack('TCodeGet.Codes',Self);
  if SeekCod(i,tf,ACode,Options)
  then result:=TransSeek(tf,ACode)+' - '+GetNameDop(i)[false]
  else result:='';
  DelStack;
end;

function TCodeGet.Codes(const ACode: string; Options: TCGSeekOptions = []): string;
begin
  result:=Codes(nil,ACode,Options);
end;

{ "Код. Наименование" по коду }
function TCodeGet.Codest(tf: TFldEdit; const ACode: string; Options: TCGSeekOptions = []): string;
var i: longint;
begin
	AddStack('TCodeGet.Codest',Self);
  if SeekCod(i,tf,ACode,Options)
  then result:=TransSeek(tf,ACode)+'. '+GetNameDop(i)[false]
  else result:='';
  DelStack;
end;

function TCodeGet.Codest(const ACode: string; Options: TCGSeekOptions = []): string;
begin
  result:=Codest(nil,ACode,Options);
end;

procedure TCodeGet.Assign;
var cg: TCodeGet;
begin
	AddStack('TCodeGet.Assign',Self);
  if IsClass(Source,TCodeGet,pointer(cg)) then begin
   	LenCode:=cg.LenCode; LenName:=cg.LenName;
   	FieldsCode:=cg.FieldsCode; FieldsName:=cg.FieldsName;
   	OrderCode:=cg.OrderCode; OrderName:=cg.OrderName;
    MulPar.Assign(cg.MulPar); Part:=cg.Part;
	 	OnStrCode:=cg.OnStrCode;
	 	OnStrName:=cg.OnStrName;
	 	OnTransSeek:=cg.OnTransSeek;
  end;
	inherited Assign(Source);
  DelStack;
end;

function TCodeGet.MaskTrans;
var Param: TCGParam;
begin
	AddStack('TCodeGet.MaskTrans');
	with Param do if MyVarType(av)=varArray then begin
    lNameGet:=IsNilc(av[1],false); lCodOnly:=IsNilc(av[2],false); lNameOnly:=IsNilc(av[3],false);
    lCodFocus:=IsNilc(av[4],true); lAny:=IsNilc(av[5],false); lEmpty:=IsNilc(av[6],false);
    Mask:=IsNilc(av[7],''); FmlFlt:=IsNilc(av[8],''); Dop:=MaskDop(av); result:=PrmToMask(Param);
  end
  else begin
    Param:=MaskToPrm(av);
    result:=ArrVarToVar(
      [VarArrayOf([mpBool,'Ввод по наименованию',lNameGet])
      ,VarArrayOf([mpBool,'Только ввод кода',lCodOnly])
      ,VarArrayOf([mpBool,'Только ввод наименования',lNameOnly])
      ,VarArrayOf([mpBool,'Установить курсор на коде',lCodFocus])
      ,VarArrayOf([mpBool,'Допустимо любое значение',lAny])
      ,VarArrayOf([mpBool,'Допустимо пустое значение',lEmpty])
      ,VarArrayOf([mpEdit,'Маска кода',Mask,true])
      ,VarArrayOf([mpButForm,ButPrm2Mask('Формула фильтра'),FmlFlt,6201])
      ]);
  end;
  DelStack;
end;

procedure TCodeGet.MaskPrn;
var s: string;
begin
	AddStack('TCodeGet.MaskPrn',Self);
  with MaskToPrm(Mask) do begin
	  s:=IfThen(lNameGet,'ввод по наименованию'+IfThen(lNameOnly,',только ввод наименования',
    	IfThen(not lCodFocus,',курсор на наименовании')),
      IfThen(lCodOnly,'только ввод кода'));
    if lAny then DlmBetwSelf(s,'допустимо любое значение',',')
    else if lEmpty then DlmBetwSelf(s,'допустимо пустое значение',',');
    if not empty(s) then LsPrn.Add(FRup(s));
    if not empty(Mask) then LsPrn.Add('Маска кода: '+Mask);
    if not empty(FmlFlt) then LsPrn.Add('Формула фильтра:'+CRLF+FmlFlt);
  end;
  DelStack;
end;

class function TCodeGet.MaskTextReadOnly;
begin
	result:=true;
end;

class procedure TCodeGet.FMaskView;
var p: TCGParam;
begin
  AddStack('TCodeGet.FMaskView');
  p:=MaskToPrm(Mask);
  Mask:=DlmBetween([
    IfThen(p.lNameGet,'по наимен.',IfThen(p.lCodOnly,'только код')),
    IfThen(p.lNameGet,IfThen(p.lNameOnly,'только наимен.',IfThen(not p.lCodFocus,'курсор на наимен.'))),
    IfThen(p.lAny,'любое знач.',IfThen(p.lEmpty,'пустое знач.')),
    IfThen(not empty(p.Mask),'маска:'+p.Mask)],',');
  DelStack;
end;

function TCodeGet.MaskDop;
begin
  result:='';
end;

function TCodeGet.MinWidthCode;
begin
	AddStack('TCodeGet.MinWidthCode',Self);
  if Assigned(FOnTransSeek) then result := inherited MinWidthCode(tf)
  else begin
  	result:=tf.Canvas.TextWidth(StringOfChar('0',{max(2,}GetDefLenCode(tf.Mask){)}));
	  AfterMinWidthCode(tf,result);
  end;
  DelStack;
end;

procedure TCodeGet.MaskFrmShow;
begin
  AddStack('TCodeGet.MaskFrmShow',Self);
  if empty(FieldsName) then EdMaskFld(1).SetReadOnly(true,false);
  DelStack;
end;

class procedure TCodeGet.MaskEdChange;
var fl: boolean;
begin
	AddStack('TCodeGet.MaskEdChange');
	if Sender=EdMaskFld(1) then begin
    fl:=GetEdMaskVal(1); EdMaskFld(2).SetReadOnly(fl); EdMaskFld(3).SetReadOnly(not fl);
  end
  else if Sender=EdMaskFld(5) then EdMaskFld(6).SetReadOnly(GetEdMaskVal(5));
  if (Sender=EdMaskFld(1)) or (Sender=EdMaskFld(3))
  then EdMaskFld(4).SetReadOnly(not GetEdMaskVal(1) or GetEdMaskVal(3));
  DelStack;
end;

class function TCodeGet.MaskSortMode;
begin
	result:=smColumns;
end;

procedure TCodeGet.StdDWFldInfo;
begin
	AddStack('TCodeGet.StdDWFldInfo',Self);
  Param:=MaskToPrm(Mask); DefLen; FldInfo.Size:=FDefLenCode;
  //SetDefLenCode; SetDefLenName;
  if not Param.lCodOnly then Inc(FldInfo.Size,FDefLenName+3);
  DelStack;
end;

procedure TCodeGet.StdDWFldValue;
var s: variant;
begin
	AddStack('TCodeGet.StdDWFldValue',Self);
  Param:=MaskToPrm(Mask);
  if Param.lCodOnly then Value:=TransSeek(Value)
  else begin
    s:=Value; Value:=Codes(s,[cdgBufAll]);
    if empty(Value) and Param.lAny then Value:=TransSeek(s);
  end;
  if LogPrimCalc then TrimSelf(Value);
  DelStack;
end;

class function TCodeGet.IsFlt;
begin
  AddStack('TCodeGet.IsFlt');
  result := not empty(MaskToPrm(tf.Mask).FmlFlt);
  DelStack;
end;

procedure TCodeGet.FltList;
  procedure CodAdd;
  var Accept: boolean;
  begin
    AddStack('TCodeGet.FltList.CodAdd',Self);
    Accept:=true; FltListAdd(aFlt[lFlt],Accept);
    if Accept then Inc(lFlt);
    DelStack;
  end;
var i,t,l: longint;
  v: variant;
  fl: boolean;
begin
  AddStack('TCodeGet.FltList',Self);
  lFlt:=0; i:=Length(aCode);
  if i>0 then begin
    l:=CodLen;
    with Tinter.create('Формула фильтра') do
      try
        value_types:='LAU'; SetProg(MaskToPrm(tf.Mask).FmlFlt);
        if Length(aFlt)<i then SetLength(aFlt,i);
        for i:=0 to i-1 do begin
          aFlt[lFlt]:=TransSeek(tf,aCode[i],l); fl:=EvalChk(v,[aFlt[lFlt]]); t:=MyVarType(v);
          if fl and (t=V_BOOL) then begin
            if v then CodAdd;
          end
          else begin
            lFlt:=0;
            if fl and (t=varArray) then begin
              t:=VarLength(v);
              if Length(aFlt)<t then SetLength(aFlt,t);
              for t:=VarArrayLowBound(v,1) to VarArrayHighBound(v,1) do begin
                aFlt[lFlt]:=TransSeek(tf,v[t],l); CodAdd;
              end;
            end;
            break;
          end;
        end;
      finally
        Free; 
      end;
    QuickSort(aFlt,lFlt,true);
  end;
  DelStack;
end;

procedure TCodeGet.FltListAdd;
begin
end;

class function TCodeGet.CodeInFlt;
begin
  AddStack('TCodeGet.CodeInFlt');
  if Assigned(tf)
  then with TCodeGet(tf.curget) do result:=QuickFind(TransSeek(tf,Code),aFlt,lFlt,true)
  else result:=true;
  DelStack;
end;

procedure TCodeGet.FltLsSet;
begin
  AddStack('TCodeGet.FltLsSet',Self);
  if IsFlt(tf) then begin
    Inc(lo);
    if lo=Length(ao) then SetLength(ao,lo+1);
    with ao[lo] do begin
      otf:=tf; oBeforeOpen:=q.BeforeOpen; oFilterRecord:=q.OnFilterRecord; oFiltered:=q.Filtered;
    end;
    q.Tag:=lo; q.BeforeOpen:=qBeforeOpen; q.Filtered:=false; q.Close;
  end;
  DelStack;
end;

procedure TCodeGet.FltLsClear;
begin
  AddStack('TCodeGet.FltLsClear',Self);
  if IsFlt(tf) then with ao[lo] do begin
    q.BeforeOpen:=oBeforeOpen; q.OnFilterRecord:=oFilterRecord; q.Filtered:=oFiltered; Dec(lo);
  end;
  DelStack;
end;

procedure TCodeGet.qBeforeOpen;
var q: TBrQuery;
  aCode: TArrStr;
  i: longint;
  oAfterScroll: TDataSetNotifyEvent;
begin
  AddStack('TCodeGet.qBeforeOpen',Self);
  q:=PointerOwner(DataSet);
  with ao[q.Tag] do begin
    oAfterScroll:=q.AfterScroll; q.AfterScroll:=nil;
    q.OnFilterRecord:=oFilterRecord; q.Filtered:=oFiltered;
    q.BeforeOpen:=nil; q.Open; q.First;
    SetLength(aCode,q.RecordCount);
    for i:=low(aCode) to high(aCode) do begin
      aCode[i]:=StrCode(q); q.Next;
    end;
    FltList(otf,aCode);
    q.OnFilterRecord:=qFilterRecord; q.Filtered:=true; q.First; q.Close;
    q.AfterScroll:=oAfterScroll;
    IfThenDataSet(oBeforeOpen,DataSet);
  end;
  q.BeforeOpen:=qBeforeOpen;
  DelStack;
end;

procedure TCodeGet.qFilterRecord;
var q: TBrQuery;
begin
  AddStack('TCodeGet.qFilterRecord',Self);
  q:=PointerOwner(DataSet);
  with ao[q.Tag] do begin
    IfThenFilterRecord(oFilterRecord,DataSet,Accept);
    if Accept then Accept:=CodeInFlt(otf,StrCode(q));
  end;
  DelStack;
end;

procedure TCodeGet.SelAdd(const tbl,nmf: string);
begin
  AddStack('TCodeGet.SelAdd',Self);
  LsSelCodeGet.AddObject(tbl+'.'+nmf,Self);
  DelStack;
end;

procedure TCodeGet.SelAdd(r: TRecDB; const nmf: string);
begin
  AddStack('TCodeGet.SelAdd(r)',Self);
  SelAdd(r.NameDB,SelRdbDefFld(r,nmf));
  DelStack;
end;

procedure TCodeGet.SelDel(const tbl,nmf: string);
var s: string;
  i: longint;
begin
  AddStack('TCodeGet.SelDel(tf)',Self);
  s:=tbl+'.'+nmf;
  with LsSelCodeGet do if Find(s,i) then while i<Count do
    if Strings[i]<>s then break
    else if SelDel(i) then break;
  DelStack;
end;

function TCodeGet.SelDel(var i: longint): boolean;
begin
  AddStack('TCodeGet.SelDel',Self);
  result := LsSelCodeGet.Objects[i]=Self;
  if result then LsSelCodeGet.Delete(i) else Inc(i);
  DelStack;
end;

procedure TCodeGet.SelDel(r: TRecDB; const nmf: string);
begin
  AddStack('TCodeGet.SelDel(r)',Self);
  SelDel(r.NameDB,SelRdbDefFld(r,nmf));
  DelStack;
end;

function TCodeGet.SelCodCanDel(const cod: string; lLike: boolean = false; const where: string = ''): boolean;
begin
  AddStack('TCodeGet.SelCodCanDel',Self);
  result:=SelCodCanDel(Self,cod,lLike,where);
  DelStack;
end;

class function TCodeGet.SelCodCanDel(const ag: array of TCodeGet; const cod: string; lLike: boolean = false; const where: string = ''): boolean;
begin
  AddStack('TCodeGet.SelCodCanDel');
  if (Length(ag)=0) or empty(cod) then result:=true
  else result:=not SelSeekMsg(ag[0].Connection,true,'Ошибка удаления',
    'Код "'+Trim(cod)+'" используется в данных.','',DlmBetween(SelWhere(ag,cod,lLike),where,sAND));
  DelStack;
end;

procedure TCodeGet.SelCodCng(const ocod,ncod: string; lLike: boolean = false; const where: string = '');
begin
  AddStack('TCodeGet.SelCodCng',Self);
  SelCodCng(Self,ocod,ncod,lLike,where);
  DelStack;
end;

class procedure TCodeGet.SelCodCng(const ag: array of TCodeGet; const ocod,ncod: string; lLike: boolean = false; const where: string = '');
var qs,qu: TMulQuery;
  oc,nc,wg: string;
  l: longint;
begin
  AddStack('TCodeGet.SelCodCng');
  if Length(ag)>0 then if IsTable(ag[0].Connection,tSEL) then begin
    qu:=GetQuery(ag[0].Connection);
    if lLike then begin
      wg:=sAND+SelWhere(ag); DlmBetwSelf(wg,where,sAND);
      nc:=TrimRight(ncod); l:=Length(nc)+1;
      qs:=GetQuery(ag[0].Connection);
      qs.PartSelect(tSEL,'COD',DlmBetween(SelWhere(ag,ocod,true),where,sAND),'','COD');
      qu.Arg[sTABLE]:=tSEL; qu.Arg[sC_LIST]:='COD';
      while not qs.Eof do begin
        oc:=qs.Fields[0].AsString; qu.Arg[sV_LIST]:=QQs(nc+Copy(oc,l,MaxInt));
        qu.Arg[sWHERE]:='COD='+QQs(oc)+wg;
        qu.ExecPart(sUW_TABLE);
        qs.Next;
      end;
      FreeQuery;
    end
    else qu.UpdateTable(tSEL,['COD'],[QQs(ncod)],DlmBetween(SelWhere(ag,ocod),where,sAND));
    FreeQuery;
  end;
  DelStack;
end;

function TCodeGet.SelWhere: string;
begin
  AddStack('TCodeGet.SelWhere',Self);
  result:=tSEL+'.VID='+QQs(TrimUpper(ClassName))+sAND+tSEL+'.VNAME='+QQs(TrimUpper(VName));
  DelStack;
end;

function TCodeGet.SelWhere(const cod: string; lLike: boolean = false): string;
begin
  AddStack('TCodeGet.SelWhere(cod)',Self);
  result:=SelWhere+sAND+tSEL+'.COD';
  if lLike
  then IncD(result,sLIKE+QQs(TrimRight(cod)+'%'))
  else IncD(result,'='+QQs(cod));
  DelStack;
end;

class function TCodeGet.SelWhere(const ag: array of TCodeGet; const cod: string; lLike: boolean = false): string;
var i: longint;
begin
  AddStack('TCodeGet.SelWhere(ag,cod)');
  result:='';
  for i:=low(ag) to high(ag) do if Assigned(ag[i]) then IncD(result,sOR+ag[i].SelWhere(cod,lLike));
  result:=BrackNoEmp(QryNone(Copy(result,lOR1,MaxInt)));
  DelStack;
end;

class function TCodeGet.SelWhere(const ag: array of TCodeGet): string;
var i: longint;
begin
  AddStack('TCodeGet.SelWhere(ag)');
  result:='';
  for i:=low(ag) to high(ag) do if Assigned(ag[i]) then IncD(result,sOR+ag[i].SelWhere);
  result:=BrackNoEmp(QryNone(Copy(result,lOR1,MaxInt)));
  DelStack;
end;

function TCodeGet.SelRVName;
begin
  AddStack('TCodeGet.SelRVName',Self);
  result:=IfThen(not empty(RVid),FRup(RVName));
  DelStack;
end;

function TCodeGet.GetSelFlt;
var i: longint;
begin
  AddStack('TCodeGet.GetSelFlt',Self);
  if lsSelFltFind(Index,i) then result:=lsSelFlt.Value[i] else result:=null;
  DelStack;
end;

procedure TCodeGet.SetSelFlt;
var i: longint;
begin
  AddStack('TCodeGet.SetSelFlt',Self);
  if lsSelFltFind(Index,i) then lsSelFlt.Value[i]:=Value;
  DelStack;
end;


function TCodeGet.lsSelFltFind;
var fi: PMQFieldInfo;
begin
  AddStack('TCodeGet.lsSelFltFind',Self);
  result:=TStrVarList.Create(TStrCustomList(lsSelFlt),true,1).Find(Index,i);
  if not result then if GetFieldInfo(tSEL,Index,fi) then begin
    result:=true; lsSelFlt.IgnoreFindAdd(Index,VarBlank(fi.DataType),i);
  end;
  DelStack;
end;

function TCodeGet.DWFldUnAllowType;
begin
	AddStack('TCodeGet.DWFldUnAllowType',Self);
  result:=inherited DWFldUnAllowType(Mask)-[dwtSel];
  DelStack;
end;

procedure TCodeGet.FMaskHelp;
var n: byte;
  s: string;
begin
  AddStack('TCodeGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+7);
  Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr('«Маска кода»')+'+;');
  s:=HelpBoldStr('«Формула фильтра»','PrmCGFmlFlt',HelpFileStd);
  Inc(n); CopyFrom(ht.Dat[n],HelpIfEmpty(s,'"'+cFmlText+'"+'+HelpStrTran(s,'ПЕРЕВОД_СТРОКИ','"^"',false)+'+"'+cAtPartEnd+'"')+'+;');
  s:=HelpBoldStr('«Ввод по наименованию»');
  Inc(n); CopyFrom(ht.Dat[n],HelpIf(s,'"'+cCdName+'"+'+HelpIf('«Только ввод наименования»','"'+cCdNameOnly+'"','""'),'""',false)+'+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpIf(s+' '+HelpBoldStr('И',hlnkInterMemo)+' '+HelpBoldStr('«Установить курсор на коде»')+' '+HelpBoldStr('ИЛИ',hlnkInterMemo)+' !'+s+' '+HelpBoldStr('И',hlnkInterMemo)+' '+HelpBoldStr('«Только ввод кода»'),'"'+cCdCod+'"','""',false)+'+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpIf('«Допустимо любое значение»','"'+cCdAny+'"','""')+'+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpIf('«Допустимо пустое значение»','"'+cCd0+'"','""'));
  DelStack;
end;

class procedure TCodeGet.SelListLoad(tf: TFldEdit;
  ls: TStringList; q: TBrQuery = nil; Opt: TCGSelListLoadOpt = []);
begin
  AddStack('TCodeGet.SelListLoad(tf)');
  TCodeGet(tf.curget.SelCodeGet).SelListLoad(tf.Value,ls,q,Opt);
  DelStack;
end;

procedure TCodeGet.SelListLoad(const Value: string;
  ls: TStringList; q: TBrQuery = nil; Opt: TCGSelListLoadOpt = []);
var i,l: longint;
begin
  AddStack('TCodeGet.SelListLoad');
  if ((cgselLoadBuf in Opt) or not(empty(Value) or (cgselAny in Opt))) and not BufLoaded then
    if Assigned(q) then begin
      BufLoad(nil,q); BufLoaded:=true;
    end
    else BufCodLoadAll;
  ls.Sorted:=false;
  if empty(Value) then ls.Clear
  else begin
    LsArrList(Value,ls,','); l:=CodLen; i:=0;
    while i<ls.Count do begin
      if not(cgselAny in Opt) then if not IsCod(ls[i],[cdgBufAll,cdgNoSQL]) then begin
        ls.Delete(i); continue;
      end;
      ls[i]:=TransSeek(ls[i],l); Inc(i);
    end;
  end;
  ls.Sorted:=true;
  DelStack;
end;

class procedure TCodeGet.SelListSave(tf: TFldEdit; ls: TStringList);
begin
  tf.Value:=SelListSave(ls);
end;

class function TCodeGet.SelListSave(ls: TStringList): string;
begin
  AddStack('TCodeGet.SelListSave');
  result:=StrTran(TrimRight(ls.Text),[CRLF,' '],[',','']);
  DelStack;
end;

class procedure TCodeGet.SelChange;
var tf: TFldEdit;
	ls: TStringList;
  Opt: TCGSelListLoadOpt;
begin
  AddStack('TCodeGet.SelChange');
  tf:=pointer(Sender); ls:=TStringList.Create;
  try
    if lAny then Opt:=[cgselAny] else Opt:=[];
    SelListLoad(tf,ls,nil,Opt); SelListSave(tf,ls);
  finally
    ls.Free;
  end;
  DelStack;
end;

function TCodeGet.bmCheckPaint(Browl: TBrowl; const ARect: TRect; Column: TColumn; Field: TField; lsCode: TStrings;
  lSet: boolean = true): boolean;
begin
  result:=bmCheckPaint(Browl,ARect,Column,Field,Browl.FieldSeek,lsCode,lSet);
end;

function TCodeGet.bmCheckPaint(Browl: TBrowl; const ARect: TRect; Column: TColumn; Field,FieldCode: TField; lsCode: TStrings;
  lSet: boolean = true): boolean;
begin
  AddStack('TCodeGet.bmCheckPaint',Self);
  result := Column.Field=Field;
  if result then My_pr.bmCheckPaint(Browl.Canvas,ARect,lsCode.IndexOf(TransSeek(FieldCode.AsString))>=0 = lSet);
  DelStack;
end;

function TCodeGet.GetSelCodeGet;
begin
  AddStack('TCodeGet.GetSelCodeGet',Self);
  result:=inherited GetSelCodeGet;
  if not(csDesigning in ComponentState) then PointerDef(pointer(result),IsClass(Self,TCodeGet));
  DelStack;
end;

function TCodeGet.DWFldSelCodeGetValid;
var g: TCustomGet;
begin
  AddStack('TCodeGet.DWFldSelCodeGetValid',Self);
  result:=inherited DWFldSelCodeGetValid(Sender,dwInf,nFldFocus,nVarFocus,amsg);
  if NameGet(g,dwInf.SelVid,dwInf.SelVName,TCodeGet) then
    if g<>Self then begin
      result:=false;
      AddFrom(amsg,['Данные типа "'+aDWFld[dwInf.AType].nm
        +'" с видом ввода "'+TCodeGet(g).SelRVName+'"',
        'недопустимы для вида ввода "'+DlmBetween(Sender.RVid,Sender.RVName,': ')+'".']);
      nFldFocus:=deVName; nVarFocus:=dwvSel;
    end;
  DelStack;
end;

procedure SelCodeGetProc(Oper: TSelCodeGetOper; const av: array of variant);
  function SelFltList(Connection: TComponent; var af: TArrStr): longint;
  var lsf: TMQFieldList;
    i: longint;
  begin
    AddStack('Codegets.SelCodeGetProc.SelFltList');
    result:=0;
    if GetFieldList(Connection,tSEL,lsf) then begin
      lsf.Find(fSelFLT,i); SetLength(af,lsf.Count-i);
      while i<lsf.Count do begin
        if not AnsiStartsText(fSelFLT,lsf[i]) then break;
        af[result]:=lsf[i]; Inc(i); Inc(result);
      end;
    end;
    DelStack;
  end;
var ag: array[1..2] of string;
  g: TCodeGet;
  pg: PCodeGet;
  j,j1,l,n,lf: longint;
  s,vn: string;
  a,af: TArrStr;
  f: TFld;
  rdb: TRecDBDef;
  pa: PRdbArrDef;
  fl: PBoolean;
  q: TMulQuery;
  rv: PDWVidRec;
  pv: PVariant;
  pd: PFldDefInf;
begin
  AddStack('Codegets.SelCodeGetProc');
  case Oper of
    selSetMemValue: begin
      ListAsArray(av[0],ag,'.');
      if IsSelCodeGet(g,av[1],ag[1],ag[2]) then with MulQueryVar(av[2]) do begin
        //if Assigned(SelGetReassign) then SelGetReassign(g,rv^);
        l:=g.CodLen; SetArrayList(sC_LIST,[fMGK,fMNPP,'COD','VID','VNAME']); s:=av[3];
        if s<>'' then AddArgList(sC_LIST,'FLD');
        lf:=SelFltList(Connection,af); AddArrayList(sC_LIST,ArrStrToArrVar(af,lf)); j1:=0; Dec(lf);
        for j:=0 to LsArrDynamic(av[4],a,',')-1 do if not empty(a[j]) then begin
          SetArrayList(sV_LIST,[av[5],j1,QQs(g.TransSeek(a[j],l)),
            QQs(TrimUpper(g.ClassName)),QQs(TrimUpper(g.VName))]);
          if s<>'' then AddArgList(sV_LIST,s);
          for n:=0 to lf do AddArgList(sV_LIST,VarTos(g.SelFlt[af[n]],vsQQ));
          ExecPart(sI_TABLE); Inc(j1);
        end;
      end;
    end;
    selModified: with PFldDefInf(longint(av[0]))^,Inf do if IsSelCodeGet(g,av[1],SelVid,SelVName) then begin
      SelGetReassign(g,Inf); f:=PointerVar(av[2]);
      for j:=0 to SelFltList(PointerVar(av[3]),af)-1 do if not CompVar(f.SelFlt[j],g.SelFlt[af[j]]) then begin
        SetPBoolean(av[4],true); break;
      end;
    end;
    selMemGkInit: begin
      SetLength(PArrArrVar(longint(av[0]))^,100);
      SetLength(ArrIntVar(av[3])^,SelFltList(PointerVar(av[1]),ArrStrVar(av[2])^));
    end;
    selMemGkIsSel: begin
      rdb:=PointerVar(av[3]);
      if rdb=RDBArr then InitArr(ag) else ListAsArray(av[4],ag,'.');
      if not IsSelCodeGet(g,av[1],ag[1],ag[2]) then if rdb=RDBArr then begin
        s:=av[4];
        if s<>'' then
          if TRecDBDef.PGetArrDef(s,pa) then begin
            rdb.SaveInf(RDBSaveInfVar(av[5])^); rdb.SetFldDefText(pa.Dat);
          end
          else SetPBoolean(av[0],false);
      end;
      PObject(longint(av[2]))^:=g;
    end;
    selMemGkGet: begin
      rv:=PointerVar(av[3]);
      if rv.SelVid='' then g:=nil
      else begin
        g:=pointer(NameGet(rv.SelVid,rv.SelVName,TCodeGet));
        if Assigned(SelGetReassign) then SelGetReassign(g,rv^);
        PObject(longint(av[2]))^:=g;
      end;
      if av[1]<>tDDAT+'.'+aDDatZnFld[ddznSel] then if not Assigned(g) then SetPBoolean(av[0],false);
    end;
    selMemGkReassign: begin
      fl:=PointerVar(av[0]); pg:=PointerVar(av[1]);
      if av[3]<>'' then begin
        q:=PointerVar(av[5]);
        for j:=0 to LsArrDynamic(TMemGkList(PointerVar(av[4])).GetValue(q.Fields[q.FieldCount-1].AsInteger),a,CRLF)-1 do
          with DWSToRec(a[j]) do if (AType=dwtSel) and (av[6]+dwCod=av[7]) then begin
            g:=pointer(NameGet(SelVid,SelVName));
            if g<>pg^ then begin
              pg^:=g; fl^:=Assigned(g);
            end;
            break;
          end;
      end;
      if fl^ then begin
        fl^:=false; LongIntVar(av[2])^:=pg^.CodLen;
      end;
    end;
    selMemGkTrans: begin
      l:=0; q:=PointerVar(av[4]);
      if av[5]=tDDAT then begin
        s:=''; g:=nil;
        if Assigned(DDSelCodeGet) then begin
          DDSelCodeGet(q.FieldZn(fDDVid,tDDAT),q.FieldZn(fDDKv,tDDAT),s,vn);
          if s<>'' then if NameGet(TCustomGet(g),s,vn,TCodeGet) then l:=g.CodLen;
        end;
      end
      else begin
        g:=PointerVar(av[1]);
        if Assigned(g) then
          if g.SelRedef then begin
            if NameGet(TCustomGet(g),q.FieldZn('VID',tSEL),q.FieldZn('VNAME',tSEL),TCodeGet) then l:=g.CodLen;
          end
          else l:=av[3];
      end;
      if Assigned(g) then StringVar(av[0])^:=g.TransSeek(av[2],l);
    end;
    selValTrans: begin
      pd:=PointerVar(av[1]);
      if NameGet(TCustomGet(g),pd.Inf.SelVid,pd.Inf.SelVName,TCodeGet) then begin
        pv:=PointerVar(av[0]); pv^:=g.TransSeek(pv^,g.CodLen);
      end;
    end;
  end;
  DelStack;
end;

procedure DWFldDefaultProc(const r: TDWVidRec; var ap: TDEPrmStr);
var i: longint;
  cg: TCustomGet;
  g: TCodeGet;
begin
  AddStack('Codegets.DWFldDefaultProc');
  if r.AType in [dwtString,dwtManyStr,dwtMemo,dwtSel] then begin
    TSimpleGet.AssignGetClass(ap);
    if r.AType in [dwtMemo,dwtSel] then begin
      ap[deWidth]:=IntToStr(wallDefault);
      if r.AType=dwtSel then if IsSelCodeGet(g,'',r.SelVid,r.SelVName) then begin
        for i:=0 to LsCustomGet.Count-1 do begin
          cg:=PointerObj(LsCustomGet,i);
          if (cg.SelCodeGetMask(ap[deMask])=g) and (cg<>g) and not empty(cg.RVid) then begin
            cg.AssignGet(ap); g:=nil; break;
          end;
        end;
        if Assigned(g) then begin
          ap[deWidth]:=''; g.AssignGet(ap);
        end;
      end;
    end;
  end;
  DelStack;
end;

procedure Register;
begin
	RegisterComponents('OurGets',[TCodeGet]);
end;

initialization
  AddStack('Codegets.initialization');
  RecDB.SelCodeGetProc:=SelCodeGetProc;
  AddFrom(DWFldDefaultProc);
  LsSelCodeGet:=SortStrListCreate(dupAccept);
  DelStack;
finalization
  LsSelCodeGet.Free;
end.
