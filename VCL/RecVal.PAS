unit RecVal;

interface

{$I LIBTEST}

uses Classes,DB,
  MyTypes;

const FldAttrAll = [low(TFldAttr)..high(TFldAttr)];

type
	TCustomRec = class;

  TFldChangeEvent = procedure(Sender: TObject; const OldValue,Value: variant);

	TFld = class(TObject)
  private
		function GetModified: boolean;
		procedure SetModified(v: boolean);
		function GetValue: variant;
		procedure SetValue(const vv: variant);
	public
  	Owner: TCustomRec;
		OldValue: variant;
    MemGk: longword;
  	Info: record
      Attr: TFldAttr;
      DataType: TFieldType;
      Size: longint;
      Value: variant;
    end;
    SelFlt: TArrVar;
    OnChange: TFldChangeEvent;
    property Modified: boolean read GetModified write SetModified;
		property Value: variant read GetValue write SetValue;
		constructor Create(AOwner: TCustomRec);
		function GetStrVal: string;
		procedure SetStrVal(const v: string);
    function Change(const v: variant): boolean;
		function StrToVar(const v: string): variant;
		function VarToStr(const v: variant): string; overload;
		class function VarToStr(const v: variant; t: TFieldType): string; overload;
    function GetFldVal(const nmf: string): TFldVal;
    function DuplFld(var f: TFld): boolean;
	end;

  PArrFld = ^TArrFld; TArrFld = array of TFld;

  TRecCalcEvent = procedure(Sender: TCustomRec; lApp: boolean) of object;

  TWMFld = record
   	Msg: longint;
    Oper: TFldOper;
		Rec: TCustomRec;
    Result: LongInt;
  end;

  PLogTrnsValPrm = ^TLogTrnsValPrm;
  TLogTrnsValPrm = record
    Sender: TCustomRec;
    nmf,nm,val: string;
    lOld,lOut,lBreak: boolean;
    ap,av: TArrVar;
    Opt: TLogPrimOptions;
  end;

	TWMUsPrm = record
   	Msg,UnUsed: longint;
    Prm: PLogTrnsValPrm;
    ResUnUsed: longint;
	end;

  TLogPrimProc = procedure(const Prm: TLogTrnsValPrm; ProcPrm: pointer);
  TAFieldValueProc = function(i: longint): boolean;

  TFldSetValueOper = (fsvOwner,fsvBefore,fsvAfter);

  TLogPrimOper = (logpCreate,logpIsFld,logpNoEmpKey,logpGet,logpGet1,logpFree);

  TCustomRecClass = class of TCustomRec;

	TCustomRec = class(TComponent)
	private
		FField: TStringList;
   	FNameRec: string;
		FActive: boolean;
    FOnAfterOpen,FOnBeforeClose: TNotifyEvent;
    FOnCalculate: TRecCalcEvent;
		function GetField(i: longint): TFld;
		function GetFieldName(i: longint): string;
		function GetFieldCount: longint;
    function GetValue(const Index: string): variant;
    function GetValueNum(Index: longint): variant;
    procedure SetActive(v: boolean);
    procedure SetNameRec(const v: string);
    procedure SetValueNum(Index: longint; const v: variant);
    procedure LsAdd;
    procedure LsDel;
  protected
    procedure SetValue(const Index: string; const v: variant); virtual;
  	function FCreateFld(const AName: string; AType: TFieldType;
    	ASize: longint; const AValue: variant): TFld; virtual;
	 	function FOpenRec: boolean; virtual;
		procedure MsgFld(nOper: TFldOper); virtual;
    procedure BeforeClose; dynamic;
	 	procedure FCloseRec; virtual;
    function FldGetValue(Sender: TFld; var v: variant): boolean; virtual;
    function FldSetValue(Sender: TFld; var v: variant; Oper: TFldSetValueOper): boolean; virtual;
    class procedure LogTrnsVal(var Prm: TLogTrnsValPrm; var v: string; lOld: boolean); overload;
    procedure FLogPrim(var Prm: TLogTrnsValPrm; Oper: TLogPrimOper; const av: array of variant; var ap: TArrVar); virtual;
  public
  	NoFldEdit: boolean;
    {FixFld: TFld;
    FixError: string;}
    OnGetValue: procedure(Sender: TCustomRec; npr: TRecGetValueList; const av: array of variant;
      pResult: pointer; var Default: boolean);
   	property Active: boolean read FActive write SetActive;
   	property FieldCount: longint read GetFieldCount;
   	property Field[i: longint]: TFld read GetField;
   	property FieldName[i: longint]: string read GetFieldName;
   	property Value[const Index: string]: variant read GetValue write SetValue;
    	default;
   	property ValueNum[Index: longint]: variant read GetValueNum write SetValueNum;
   	constructor Create(AOwner: TComponent = nil); override;
   	class function CreateOne(var Sender: TCustomRec; AOwner: TComponent = nil): TCustomRec;
   	destructor Destroy; override;
	 	function OpenRec: boolean; virtual;
	 	procedure CloseRec;
    procedure AfterOpen; dynamic;
    //procedure Assign(Source: TPersistent); override;
		function FldName(const s: string): TFld; overload;
		function FldName(const s: string; var f: TFld): boolean; overload;
		function NumFromName(const s: string): longint; overload;
		function NumFromName(const s: string; var i: longint): boolean; overload;
    function GetValueDefault(npr: TRecGetValueList; const av: array of variant;
      pResult: pointer): boolean;
		function IsField(const s: string): boolean;
		function FieldFind(const s: string; var Index: longint): boolean;
		procedure FieldDel(Index: longint);
    function CntFldNm(const sbeg: string; nmax: byte = 1): byte;
    function ValueDef(const nmf: string; const Def: variant): variant;
    function IsFldValue(const nmf: string; lOld: boolean; var v: variant): boolean;
		procedure Calculate(lApp: boolean); dynamic;
		procedure GetAFieldValue(var a: TArrFldVal;	Attr: TFldAttrs = FldAttrAll;
    	Proc: TAFieldValueProc = nil; lSetLen: boolean = true);
    function GetFldVal(const nmf: string): TFldVal;
		procedure SetAFieldValue(const a: TArrFldVal; OnlyVal: boolean = true);
		procedure Cancel;
		function ActiveNoNil: boolean;
    function AbcKodCheck(const NmFld,NmFldCheck: string; Opt: TKodCheckOptions = []): boolean;
    procedure SpaceStrSelf(const nmf: string; nlen: longint = NegDef; ndec: longint = 0; Limit: boolean = true);
    procedure VarBlankSelf(const nmf: string); overload;
    procedure VarBlankSelf(i: longint); overload;
    procedure VarBlankSelf(const anmf: array of string); overload;
    procedure StuffStrSelf(const nmf: string; AStart, ALength: longword; const ASubText: string);
    procedure eomSelf(const nmf: string);
    procedure IncMonthSelf(const nmf: string; NumberOfMonths: longint = 1);
    procedure IncV(const nmf: string; const d2: double = 1); overload;
    procedure IncV(const nmf,d2: string); overload;
    procedure IncV(i: longint; const d2: variant); overload;
    procedure IncV(i: longint; const d2: Double; ndec: longint); overload;
    procedure SetArrayValue(const anmf: array of string; const v: variant);
    function LogPrim(Opt: TLogPrimOptions = [logpKey]; af: PArrBool = nil;
      Proc: TLogPrimProc = nil; ProcPrm: pointer = nil): string; overload;
    class function LogTrnsVal(var Prm: TLogTrnsValPrm; const Value: variant; lOld: boolean; t: TFieldType; fi: PMQFieldInfo): string; overload;
    procedure RestOldVal;
    function FldDataType(i: longint): TFieldType; overload;
    function FldDataType(const nmf: string): TFieldType; overload;
		function FldModified: boolean; overload;
		function FldModified(i: longint): boolean; overload; virtual;
		function FldModified(const nmf: string): boolean; overload;
    procedure IfThenCalculate(Proc: TRecCalcEvent; lApp: boolean);
    procedure IfThenFldChange(const nmf: string; AValue: boolean; ATrue: TFldChangeEvent; AFalse: TFldChangeEvent = nil);
    //procedure ReplFldVar(const nmf: string; const vFrom,vTo: variant);
  published
   	property NameRec: string read FNameRec write SetNameRec;
   	property OnAfterOpen: TNotifyEvent read FOnAfterOpen write FOnAfterOpen;
   	property OnBeforeClose: TNotifyEvent read FOnBeforeClose write FOnBeforeClose;
   	property OnCalculate: TRecCalcEvent read FOnCalculate write FOnCalculate;
  end;

  TRecValIniTrns = procedure(const FieldName: string; var Value: variant; lSave: boolean);

	TRecVal = class(TCustomRec)
	private
    FFields: TStrings;
	 	procedure SetFields(v: TStrings);
		procedure FieldsChange(Sender: TObject);
  protected
    procedure FLogPrim(var Prm: TLogTrnsValPrm; Oper: TLogPrimOper; const av: array of variant; var ap: TArrVar); override;
  public
   	constructor Create(AOwner: TComponent = nil); override;
   	destructor Destroy; override;
	 	function OpenRec: boolean; override;
    //procedure Assign(Source: TPersistent); override;
    procedure CreateFld(const AName: string; AType: TFieldType;
     	ASize: longint; const cValue: variant; const APrim: string = ''; ReWrite: boolean = true);
    procedure DestroyFld(const cfName: string);
    procedure BeginUpdate;
    procedure EndUpdate;
    function SaveToIni(pFldInc: PArrStr = nil;
      const SectId: string = ''; PrTrns: TRecValIniTrns = nil): string;
    procedure RestFromIni(const SectId: string = ''; PrTrns: TRecValIniTrns = nil);
    function SectIni(const SectId: string = ''): string;
    procedure LogWrite(const tbl: string = ''); overload;
    class function StrToPrm(const st: string; var Prm: TRecValPrm): boolean;
  published
   	property Fields: TStrings read FFields write SetFields;
  end;

  TLogFieldsList = class(TStringList)
  public
    procedure AddRecFld(r: TCustomRec; const nmf: string); overload;
    procedure AddRecFld(r: TCustomRec; const nmf: array of string); overload;
    procedure DelRecFld(r: TCustomRec; const nmf: string);
    procedure ReplaceNameRec(ro,rn: TCustomRec);
  end;

  TLogTrnsValProc = procedure(var Prm: TLogTrnsValPrm);

  TLogCompareStrProc = function(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
  TLogCompareStrNewProc = function(const Prm: TLogTrnsValPrm; p,pv: pointer; lNew: boolean): string;

  TCustomLogCompare = class
  protected
    class procedure Init(var Prm: TLogTrnsValPrm; pv: pointer); virtual;
    class procedure Execute(var Prm: TLogTrnsValPrm; pv: pointer; PrTrans: TPrimTrans = nil); overload;
  public
    class function ListCreate(pv: pointer; const Value: string; lNew: boolean): pointer; virtual; abstract;
    class procedure ListDestroy(pv,ls: pointer); virtual; abstract;
    class function GetCount(pv,ls: pointer): longint; virtual; abstract;
    class procedure GetItem(var Prm: TLogTrnsValPrm; pv,lso,lsn: pointer; no,nn: longint; tp: TLogCompareItemList); virtual; abstract;
    class procedure AddRes(var Prm: TLogTrnsValPrm; const so,sn: string; pv: pointer = nil;
      const Capt: string = ''; Level: byte = 0); overload;
    class procedure AddRes(var Prm: TLogTrnsValPrm; so,sn: longint; 
      const Capt: string = ''; Level: byte = 0); overload;
    class procedure AddRes(var Prm: TLogTrnsValPrm; so,sn: boolean;
      const Capt: string = ''; Level: byte = 0); overload;
    class procedure AddRes(Proc: TLogCompareStrProc;
      var Prm: TLogTrnsValPrm; po,pn: pointer; pv: pointer = nil;
      const Capt: string = ''; Level: byte = 0); overload;
    class procedure AddRes(Proc: TLogCompareStrNewProc;
      var Prm: TLogTrnsValPrm; po,pn: pointer; pv: pointer = nil;
      const Capt: string = ''; Level: byte = 0); overload;
    class procedure Execute(var Prm: TLogTrnsValPrm); overload;
    class procedure ExecuteStr(var Prm: TLogTrnsValPrm; const so,sn: string; pv: pointer = nil);
  end;

  TCustomLogCompareClass = class of TCustomLogCompare;

  TStrLogCompare = class(TCustomLogCompare)
  public
    class function ListCreate(pv: pointer; const Value: string; lNew: boolean): pointer; override;
    class procedure ListDestroy(pv,ls: pointer); override;
    class function GetCount(pv,ls: pointer): longint; override;
    class procedure GetItem(var Prm: TLogTrnsValPrm; pv,lso,lsn: pointer; no,nn: longint; tp: TLogCompareItemList); override;
  end;

  TDlmLogCompare = class(TCustomLogCompare)
  public
    class function ListCreate(pv: pointer; const Value: string; lNew: boolean): pointer; override;
    class procedure ListDestroy(pv,ls: pointer); override;
    class function GetCount(pv,ls: pointer): longint; override;
    class procedure GetItem(var Prm: TLogTrnsValPrm; pv,lso,lsn: pointer; no,nn: longint; tp: TLogCompareItemList); override;
    class procedure Execute(var Prm: TLogTrnsValPrm; const Dlm: string); overload;
    class function ListCreateDlm(const Value,Dlm: string): pointer;
  end;

  TCrlfLogCompare = class(TDlmLogCompare)
  public
    class function ListCreate(pv: pointer; const Value: string; lNew: boolean): pointer; override;
  end;

  TStrListLogCompare = class(TCustomLogCompare)
  public
    class function ListCreate(pv: pointer; const Value: string; lNew: boolean): pointer; override;
    class procedure ListDestroy(pv,ls: pointer); override;
    class function GetCount(pv,ls: pointer): longint; override;
    class procedure GetItem(var Prm: TLogTrnsValPrm; pv,lso,lsn: pointer; no,nn: longint; tp: TLogCompareItemList); override;
  end;

  TChkLogCompare = class(TCustomLogCompare)
  public
    class function ListCreate(pv: pointer; const Value: string; lNew: boolean): pointer; override;
    class procedure ListDestroy(pv,ls: pointer); override;
    class function GetCount(pv,ls: pointer): longint; override;
    class procedure GetItem(var Prm: TLogTrnsValPrm; pv,lso,lsn: pointer; no,nn: longint; tp: TLogCompareItemList); override;
    class procedure Execute(var Prm: TLogTrnsValPrm; const a: array of string;
      Invert: boolean = false; PrTrans: TPrimTrans = nil); overload;
  end;

var LogFields: TLogFieldsList;
  RecCalculate: TRecCalcEvent;
  FldChangeOn: boolean = true;
  LogPrimCalc: boolean;
  LogFieldsBound: TStringList;
  LsFldEdit: TList;

function RecName(const nameRec: string): TCustomRec; overload;
function RecName(const nameRec: string; var r: TCustomRec): boolean; overload;
function RecName(const nameRec: string; var r: TCustomRec; cType: TCustomRecClass): boolean; overload;
function RecIntName(const nameRec: string): longint;
procedure RecIntNameSelf(var v: variant; i: longint);
function RecFldName(const nmRec,nmFld: string): TFld;
function FldSizeCheck(const nmRec,nmFld: string; f: TFld; Size: longint): boolean;
procedure LogTrnsValProcAdd(Proc: TLogTrnsValProc); overload;
procedure LogTrnsValProcAdd(Proc: TLogTrnsValProc; const ap: array of variant); overload;
procedure LogTrnsValProcIns(Proc: TLogTrnsValProc); overload;
procedure LogTrnsValProcIns(Proc: TLogTrnsValProc; const ap: array of variant); overload;
procedure LogTrnsValProcDel(Proc: TLogTrnsValProc);
function LogEnumVal(var Prm: TLogTrnsValPrm; const a: array of string; LowLim: longint = 0): boolean;
function LogCompareStrStr(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
function LogCompareStrInt(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
function IfThenCustomLogCompareClass(AValue: boolean; ATrue: TCustomLogCompareClass; AFalse: TCustomLogCompareClass = nil): TCustomLogCompareClass;
function IfThenFldChange(AValue: boolean; ATrue: TFldChangeEvent; AFalse: TFldChangeEvent = nil): TFldChangeEvent;
function UnDataType(f: TFld): TFieldType; overload;
function CustomRecVar(const v: variant): TCustomRec;

implementation

uses SysUtils,Variants,Forms,Controls,StrUtils,Math,
  My_pr;

type
  TArrLogTrnsValProc = array of record
    Proc: TLogTrnsValProc;
    ap: TArrVar;
  end;

var nRecId: Int64 = 0;
  aLogTrnsValProc: TArrLogTrnsValProc;
  lsFldSizeCheck: TStringList;

function RecName(const nameRec: string): TCustomRec;
begin
	AddStack('RecVal.RecName');
	result:=PointerObjFind(LsCustomRec,Trim(nameRec));
  DelStack;
end;

function RecName(const nameRec: string; var r: TCustomRec): boolean;
begin
  r:=RecName(nameRec); result:=Assigned(r);
end;

function RecName(const nameRec: string; var r: TCustomRec; cType: TCustomRecClass): boolean;
begin
  r:=RecName(nameRec); result := r is cType;
end;

function RecIntName;
begin
  result:=longint(RecName(nameRec));
end;

procedure RecIntNameSelf;
begin
  AddStack('RecVal.RecIntNameSelf');
  if MyVarType(v[i])=varString then v[i]:=RecIntName(v[i]);
  DelStack;
end;

function RecFldName;
var rc: TCustomRec;
begin
	AddStack('RecVal.RecFldName');
	//addmsgfile('RecFldName');
  if RecName(nmRec,rc) then result:=rc.FldName(nmFld) else result:=nil;
	DelStack;
end;

function FldSizeCheck;
var s: string;
begin
  AddStack('RecVal.FldSizeCheck');
  result := f.Info.Size>=Size;
  if not result then begin
    SortStrListCreate(lsFldSizeCheck); s:=nmRec+'.'+nmFld;
    if not IgnoreSLFindAdd(lsFldSizeCheck,s) then begin
      s:=Format('Необходимо увеличить длину поля %s до %d символов.%sОбратитесь к разработчикам.',[s,Size,CRLF]);
      meserr(s); OutStack(s);
    end;
  end;
  DelStack;
end;

procedure LogTrnsValProcAdd(Proc: TLogTrnsValProc);
begin
  LogTrnsValProcAdd(Proc,[]);
end;

procedure LogTrnsValProcAdd(Proc: TLogTrnsValProc; const ap: array of variant);
var i: longint;
begin
  AddStack('RecVal.LogTrnsValProcAdd');
  if Assigned(Proc) then begin
    i:=Length(aLogTrnsValProc); SetLength(aLogTrnsValProc,i+1);
    aLogTrnsValProc[i].Proc:=Proc; CopyFromVArr(aLogTrnsValProc[i].ap,ap);
  end;
  DelStack;
end;

procedure LogTrnsValProcIns(Proc: TLogTrnsValProc);
begin
  LogTrnsValProcIns(Proc,[]);
end;

procedure LogTrnsValProcIns(Proc: TLogTrnsValProc; const ap: array of variant);
var i: longint;
begin
  AddStack('RecVal.LogTrnsValProcIns');
  if Assigned(Proc) then begin
    SetLength(aLogTrnsValProc,Length(aLogTrnsValProc)+1);
    for i:=high(aLogTrnsValProc) downto 1 do aLogTrnsValProc[i]:=aLogTrnsValProc[i-1];
    aLogTrnsValProc[0].Proc:=Proc; CopyFromVArr(aLogTrnsValProc[0].ap,ap);
  end;
  DelStack;
end;

procedure LogTrnsValProcDel;
var i,h: longint;
begin
  AddStack('RecVal.LogTrnsValProcDel');
  if Assigned(Proc) then begin
    i:=low(aLogTrnsValProc); h:=high(aLogTrnsValProc);
    while i<=h do
      if @aLogTrnsValProc[i].Proc=@Proc then begin
        for i:=i to h-1 do aLogTrnsValProc[i]:=aLogTrnsValProc[i+1];
        SetLength(aLogTrnsValProc,h); break;
      end
      else Inc(i);
  end;
  DelStack;
end;

function LogEnumVal;
var i: longint;
begin
  AddStack('RecVal.LogEnumVal');
  with Prm do begin
    i:=Int0(val); result:=InRange(i,LowLim,LowLim+high(a));
    if result then val:=TransPrim(a[i-LowLim]);
    lBreak:=true;
  end;
  DelStack;
end;

function LogCompareStrStr;
begin
  AddStack('RecVal.LogCompareStrStr');
  result:=PString(p)^;
  if empty(result) and not(logpMod in Prm.Opt) then result:='';
  DelStack;
end;

function IfThenCustomLogCompareClass;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function IfThenFldChange;
begin
  if AValue then Result:=ATrue else Result:=AFalse;
end;

function UnDataType(f: TFld): TFieldType;
begin
  result:=UnDataType(f.Info.DataType);
end;

function CustomRecVar;
begin
  result:=PointerVar(v);
end;

{ TFld }
constructor TFld.Create;
begin
	AddStack('TFld.Create');
	//addmsgfile('TFld.Create');
  Owner:=AOwner; Info.DataType:=ftString; Info.Attr:=faNormal; Info.Size:=10;
  Info.Value:=''; OldValue:='';
  DelStack;
end;

function TFld.DuplFld;
begin
  AddStack('TFld.DuplFld');
  f:=nil;
  if Info.Attr in setDBDupl then if MyVarType(Info.Value)<>varString then f:=PointerVar(Info.Value);
  result:=Assigned(f);
  DelStack;
end;

function TFld.GetModified;
var f: TFld;
begin
	AddStack('TFld.GetModified');
  if DuplFld(f) then result:=f.Modified else result := not CompVar(Value,OldValue);
  DelStack;
end;

procedure TFld.SetModified;
//var f: TFld;
begin
  AddStack('TFld.SetModified');
  if v then OldValue:=null else OldValue:=Value;
  //if DuplFld(f) then f.Modified:=v;
  DelStack;
end;

function TFld.GetValue;
var f: TFld;
begin
	{$IFDEF STACKALL}AddStack('TFld.GetValue');{$ENDIF}
	//addmsgfile('TFld.GetValue');
  if Info.Attr in setDBDupl then begin
    if DuplFld(f) then begin
      result:=f.GetValue;
      case Info.Attr of
        faFix: if Info.DataType=ftString then PadRSelf(result,Info.Size);
        faFixSel: if Info.DataType=ftInteger then Int0Self(result);
      end;
    end
    else result:='';
    if (Info.Attr=faFix) and (Info.DataType=ftBoolean) then StrToBoolSelf(result);
  end
  else if Owner.FldGetValue(Self,result) then result:=Info.Value;
	{$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TFld.SetValue;
var v: variant;
  t{$IFDEF STACKALL},ost {$ENDIF}: longint;
  fl: boolean;
  //r: TCustomRec; ov: variant; const nmr='SNACH2'; nmf=sSel+'KRF';
label lend;
begin
	{$IFDEF STACKALL}ost:=AddStack('TFld.SetValue');{$ENDIF}
	//addmsgfile('TFld.SetValue');
  //if RecName(nmr,r) then ov:=r[nmf];
  v:=vv;
  if not Owner.FldSetValue(Self,v,fsvOwner) then begin
    case Info.DataType of
      ftString:	if MyVarType(v)=varString then PadRSelf(v,Info.Size) else goto lend;
      ftBlob: goto lend;
    end;
    Owner.FldSetValue(Self,v,fsvBefore);
    if Change(v) then begin
    	try
        case Info.DataType of
          ftInteger: VarAsTypeSelf(v,varInteger);
          ftFloat: VarAsTypeSelf(v,varDouble);
          ftDateTime: VarAsTypeSelf(v,varDate);
        end;
      except
        {$IFDEF STACKALL}SetStack(ost);{$ENDIF}
      end;
      t:=MyVarType(v,true);
      case Info.DataType of
        ftString: fl := t=varString;
        ftInteger,ftFloat: fl := t=varDouble;
        ftDateTime: fl := t=varDate;
        ftBoolean: fl := t=varBoolean;
      else fl:=true;
      end;
      if fl then begin
        //if Self=Owner.FixFld then raise Exception.Create(Owner.FixError);
        Info.Value:=v; Owner.FldSetValue(Self,v,fsvAfter);
      end;
    end;
  end;
lend:
  {if Assigned(r) then if not CompVar(r[nmf],ov) then begin
    LsCustomRec:=LsCustomRec;
  end;}
	{$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TFld.Change;
begin
  {$IFDEF STACKALL}AddStack('TFld.Change');{$ENDIF}
  result:=not CompVar(v,Info.Value);
  if result then if Assigned(OnChange) then if FldChangeOn then OnChange(Owner,Info.Value,v);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TFld.GetStrVal;
begin
	AddStack('TFld.GetStrVal');
	//addmsgfile('TFld.GetStrVal');
  result:=VarToStr(Value);
  DelStack;
end;

procedure TFld.SetStrVal;
begin
	AddStack('TFld.SetStrVal');
	//addmsgfile('TFld.SetStrVal');
	SetValue(StrToVar(v));
  DelStack;
end;

function TFld.StrToVar;
begin
	AddStack('TFld.StrToVar');
  case Info.DataType of
    ftInteger: result:=Int0(v);
    ftBoolean: result:=StrToBoolean(v);
    ftDateTime:	result:=ctod(v);
    ftFloat: result:=Float0(v);
  else result:=v;
  end;
  DelStack;
end;

function TFld.VarToStr(const v: variant): string;
begin
	result:=VarToStr(v,Info.DataType);
end;

class function TFld.VarToStr(const v: variant; t: TFieldType): string;
begin
	AddStack('TFld.VarToStr');
  case t of
    ftInteger: result:=IntToStr(v);
    ftBoolean: result:=Bool2Str(v);
    ftDateTime: result:=dtoc(v);
    ftFloat: result:=MyFloatToStr(v,FloatMaxLen,FloatMaxDec);
  else result:=ReplVar(v,null,'');
  end;
  DelStack;
end;

function TFld.GetFldVal;
begin
  AddStack('TFld.GetFldVal');
  with result do begin
    nm:=nmf; v:=Value; ov:=OldValue; gk:=MemGk;
  end;
  DelStack;
end;

{ TCustomRec }
constructor TCustomRec.Create;
var fl: boolean;
begin
	AddStack('TCustomRec.Create',Self);
	//clrmsgfile;
	//addmsgfile('Create');
  FField:=SortStrListCreate;
	inherited Create(AOwner);
  if Assigned(AOwner)
  then fl := not((csLoading in AOwner.ComponentState) or (csDesigning in AOwner.ComponentState))
    or not(AOwner is TForm) and not(AOwner is TDataModule)
  else fl:=true;
  if fl then begin
    Inc(nRecId); FNameRec:=StrNum('__',nRecId);
  end;
  FActive:=false; LsAdd;
  DelStack;
end;

class function TCustomRec.CreateOne;
begin
  AddStack('TCustomRec.CreateOne');
  if not Assigned(Sender) then Sender:=Create(AOwner);
  result:=Sender;
  DelStack;
end;

destructor TCustomRec.Destroy;
begin
	AddStack('TCustomRec.Destroy',Self);
	//addmsgfile('Destroy');
	CloseRec; FreeAndNil(FField); LsDel;
  MsgFld(foDestroy);
  inherited Destroy;
  DelStack;
end;

procedure TCustomRec.LsAdd;
begin
  AddStack('TCustomRec.LsAdd',Self);
  SortStrListCreate(LsCustomRec,dupAccept).AddObject(Trim(NameRec),Self);
  DelStack;
end;

procedure TCustomRec.LsDel;
var i: longint;
  nmr: string;
begin
  AddStack('TCustomRec.LsDel',Self);
  if Assigned(LsCustomRec) then begin
    nmr:=Trim(nameRec);
    if LsCustomRec.Find(nmr,i) then while i<LsCustomRec.Count do begin
      if AnsiSameText(Trim(LsCustomRec[i]),nmr) then
        if LsCustomRec.Objects[i]=Self then begin
          LsCustomRec.Delete(i);
          if LsCustomRec.Count=0 then FreeAndNil(LsCustomRec);
        end
        else begin
          Inc(i); continue;
        end;
      break;
    end;
  end;
  DelStack;
end;

procedure TCustomRec.SetActive;
begin
	AddStack('TCustomRec.SetActive',Self);
	if v<>FActive then
	  if v then OpenRec else CloseRec;
  DelStack;
end;


procedure TCustomRec.SetNameRec;
begin
  AddStack('TCustomRec.SetNameRec',Self);
  if FNameRec<>v then begin
    LsDel; FNameRec:=v; LsAdd;
  end;
  DelStack;
end;

function TCustomRec.OpenRec;
begin
	AddStack('TCustomRec.OpenRec',Self);
	//addmsgfile('OpenRec');
  result:=FOpenRec;
  DelStack;
end;

function TCustomRec.FOpenRec;
begin
	AddStack('TCustomRec.FOpenRec',Self);
	result:=true;
  if FField.Count>0 then MsgFld(foOpenRec);
  FActive:=true; AfterOpen;
  DelStack;
end;

procedure TCustomRec.AfterOpen;
begin
	AddStack('TCustomRec.AfterOpen',Self);
	IfThenNotify(FOnAfterOpen,Self);
  DelStack;
end;

procedure TCustomRec.CloseRec;
begin
	AddStack('TCustomRec.CloseRec',Self);
	//addmsgfile('CloseRec');
  if FActive then begin
	  BeforeClose; FCloseRec;
  end;
  DelStack;
end;

procedure TCustomRec.FCloseRec;
begin
	AddStack('TCustomRec.FCloseRec',Self);
	//addmsgfile('FCloseRec');
	if FField.Count>0 then begin
    ClearObjects(FField); MsgFld(foCloseRec);
  end;
  FActive:=false;
  DelStack;
end;

function TCustomRec.FldGetValue;
begin
  result:=true;
end;

function TCustomRec.FldSetValue;
begin
  result:=false;
end;

procedure TCustomRec.MsgFld;
var i: longint;
begin
  AddStack('TCustomRec.MsgFld',Self);
  if not NoFldEdit and Assigned(LsFldEdit) then for i:=0 to LsFldEdit.Count-1 do
  	TControl(LsFldEdit[i]).Perform(WM_FLD,byte(nOper),LongInt(Self));
  DelStack;
end;

procedure TCustomRec.BeforeClose;
begin
	AddStack('TCustomRec.BeforeClose',Self);
	IfThenNotify(FOnBeforeClose,Self);
  DelStack;
end;

{procedure TCustomRec.Assign(Source: TPersistent);
begin
	AddStack('TCustomRec.Assign',Self);
	//addmsgfile('Assign');
  if Source is TCustomRec then with TCustomRec(Source) do begin
  	Self.NameRec:=NameRec;
  	Self.onCalculate:=onCalculate;
  end;
	inherited Assign(Source);
  DelStack;
end;}

function TCustomRec.GetField;
begin
	{$IFDEF STACKALL}AddStack('TCustomRec.GetField',Self);{$ENDIF}
	//addmsgfile('GetField');
	result:=PointerObj(FField,i);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TCustomRec.GetFieldName;
begin
	{$IFDEF STACKALL}AddStack('TCustomRec.GetFieldName',Self);{$ENDIF}
	//addmsgfile('GetFieldName');
	result:=FField[i];
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TCustomRec.GetFieldCount;
begin
	AddStack('TCustomRec.GetFieldCount',Self);
	//addmsgfile('GetFieldCount');
	result:=FField.Count;
  DelStack;
end;

function TCustomRec.GetValueDefault;
begin
  AddStack('TCustomRec.GetValueDefault',Self);
  result:=true;
  if Assigned(OnGetValue) then OnGetValue(Self,npr,av,pResult,result);
  DelStack;
end;

// Значение поля Index
function TCustomRec.GetValue;
begin
	AddStack('TCustomRec.GetValue',Self);
	//addmsgfile('GetValue');
  if GetValueDefault(rgvValue,[Index],@result) then result:=ValueDef(Index,'');
  DelStack;
end;

procedure TCustomRec.SetValue;
var f: TFld;
begin
	AddStack('TCustomRec.SetValue',Self);
	//addmsgfile('SetValue');
  if FldName(Index,f) then f.SetValue(v);
  DelStack;
end;

function TCustomRec.GetValueNum;
begin
	AddStack('TCustomRec.GetValueNum',Self);
  if GetValueDefault(rgvGetValueNum,[Index],@result) then result:=Field[Index].Value;
  DelStack;
end;

procedure TCustomRec.SetValueNum;
begin
	AddStack('TCustomRec.SetValueNum',Self);
  if GetValueDefault(rgvSetValueNum,[Index,v],nil) then Field[Index].SetValue(v);
  DelStack;
end;

function TCustomRec.NumFromName(const s: string): longint;
begin
  AddStack('TCustomRec.NumFromName',Self);
  if GetValueDefault(rgvNumFromName,[s],@result) then result:=FField.IndexOf(s);
  DelStack;
end;

function TCustomRec.NumFromName(const s: string; var i: longint): boolean;
begin
  i:=NumFromName(s); result := i>=0;
end;

function TCustomRec.IsField;
begin
  AddStack('TCustomRec.IsField',Self);
  result := NumFromName(s)>=0;
  DelStack;
end;

function TCustomRec.FieldFind;
begin
  AddStack('TCustomRec.FieldFind',Self);
	result:=FField.Find(s,Index);
  DelStack;
end;

procedure TCustomRec.FieldDel;
begin
  AddStack('TCustomRec.FieldDel',Self);
  FField.Delete(Index);
  DelStack;
end;

function TCustomRec.ValueDef;
var i: longint;
begin
  AddStack('TCustomRec.ValueDef',Self);
  if NumFromName(nmf,i) then result:=Field[i].Value else result:=Def;
  DelStack;
end;

function TCustomRec.IsFldValue;
var f: TFld;
begin
  AddStack('TCustomRec.IsFldValue',Self);
  result:=FldName(nmf,f);
  if result then
    if lOld then v:=f.OldValue else v:=f.Value;
  DelStack;
end;

function TCustomRec.CntFldNm;
begin
	AddStack('TCustomRec.CntFldNm',Self);
  result:=1;
  while IsField(StrNum(sbeg,result,nmax)) do Inc(result);
  Dec(result);
  DelStack;
end;

// Создать поле
function TCustomRec.FCreateFld;
label lend;
begin
	AddStack('TCustomRec.FCreateFld',Self);
	//addmsgfile('FCreateFld');
  result:=nil;
	if empty(AName) then goto lend;
  if not FldName(AName,result) then begin
		result:=TFld.Create(Self); FField.AddObject(AnsiUpperCase(AName),result);
  end;
  with result do begin
   	Info.DataType:=AType; Info.Attr:=faNormal;
		case Info.DataType of
			ftInteger: Info.Size:=LenIntStr(MaxLongInt)+1;
			ftBoolean: Info.Size:=1;
      ftFloat: Info.Size:=20;
      ftDateTime: Info.Size:=8;
      ftMemo,ftArray: begin
      	Info.Size:=0; goto lend;
      end;
    else Info.Size:=ASize;
		end;
    SetValue(AValue);
  end;
lend:
	DelStack;
end;

// Ссылка на поле по имени поля
function TCustomRec.FldName(const s: string): TFld;
begin
  FldName(s,result);
end;

function TCustomRec.FldName(const s: string; var f: TFld): boolean;
var o: TObject;
begin
	{$IFDEF STACKALL}AddStack('TCustomRec.FldName',Self);{$ENDIF}
	//addmsgfile('FldName');
  o:=PointerObjFind(FField,s); result:=IsClass(o,TFld,pointer(f));
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

// Расчёт вычисляемых полей
procedure TCustomRec.Calculate;
begin
	AddStack('TCustomRec.Calculate',Self);
	//addmsgfile('Calculate');
	IfThenCalculate(FOnCalculate,lApp);
  IfThenCalculate(RecCalculate,lApp);
  DelStack;
end;

function TCustomRec.FldModified: boolean;
var i: longint;
begin
  AddStack('TCustomRec.FldModified',Self);
  result:=false;
  for i:=0 to FieldCount-1 do if FldModified(i) then begin
    result:=true; break;
  end;
  DelStack;
end;

function TCustomRec.FldModified(i: longint): boolean;
begin
	{$IFDEF STACKALL}AddStack('TCustomRec.FldModified',Self);{$ENDIF}
  with Field[i] do result := not CompVar(Value,OldValue);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TCustomRec.FldModified(const nmf: string): boolean;
var i: longint;
begin
  if NumFromName(nmf,i) then result:=FldModified(i) else result:=false;
end;

procedure TCustomRec.GetAFieldValue;
var i,l,n: longint;
begin
  AddStack('TCustomRec.GetAFieldValue',Self);
  if lSetLen then SetLength(a,FieldCount);
  l:=0; n:=low(a);
  for i:=0 to FieldCount-1 do
  	if Field[i].Info.Attr in Attr then begin
      if Assigned(Proc) then
        if not Proc(i) then continue;
      a[n]:=Field[i].GetFldVal(FieldName[i]); Inc(l); Inc(n);
    end;
  if lSetLen then SetLength(a,l);
  DelStack;
end;

function TCustomRec.GetFldVal;
var f: TFld;
begin
  AddStack('TCustomRec.GetFldVal');
  if FldName(nmf,f) then result:=f.GetFldVal(nmf) else result.nm:='';
  DelStack;
end;

procedure TCustomRec.SetAFieldValue;
var n: longint;
  f: TFld;
begin
  AddStack('TCustomRec.SetAFieldValue',Self);
  for n:=low(a) to high(a) do with a[n] do
    if FldName(nm,f) then begin
      f.Value:=v;
      if not OnlyVal then begin
        f.OldValue:=ov; f.MemGk:=gk;
      end;
    end;
  DelStack;
end;

procedure TCustomRec.Cancel;
var i: longint;
begin
  for i:=0 to FieldCount-1 do Field[i].Modified:=false;
end;

function TCustomRec.ActiveNoNil;
begin
  AddStack('TMulQuery.ActiveNoNil',Self);
  if Assigned(Self) then result:=FActive else result:=false;
  DelStack;
end;

function TCustomRec.AbcKodCheck;
var s: string;
  i: longint;
begin
  AddStack('TCustomRec.AbcKodCheck',Self);
  if nmFld=NmFldCheck then begin
    s:=Trim(Value[NmFld]); result := (chkNoEmpty in Opt) or (s<>'');
    if result then begin
      for i:=1 to Length(s) do
        if not IsChrWord(s[i]) then begin
          meserr('Некорректный символ: "'+s[i]+'".'); result:=false; break;
        end;
    end
    else meserr('Значение не должно быть пустым.');
  end
  else result:=true;
  DelStack;
end;

procedure TCustomRec.SpaceStrSelf;
var i: longint;
begin
  AddStack('TCustomRec.SpaceStrSelf',Self);
  if NumFromName(nmf,i) then ValueNum[i]:=SpaceStr(ValueNum[i],nlen,ndec,Limit);
  DelStack;
end;

procedure TCustomRec.VarBlankSelf(const nmf: string);
var i: longint;
begin
  if NumFromName(nmf,i) then VarBlankSelf(i);
end;

procedure TCustomRec.VarBlankSelf(i: longint);
begin
  AddStack('TCustomRec.VarBlankSelf',Self);
  ValueNum[i]:=VarBlank(ValueNum[i]);
  DelStack;
end;

procedure TCustomRec.VarBlankSelf(const anmf: array of string);
var i: longint;
begin
  for i:=low(anmf) to high(anmf) do VarBlankSelf(anmf[i]);
end;

procedure TCustomRec.StuffStrSelf;
var i: longint;
begin
  AddStack('TCustomRec.StuffStrSelf',Self);
  if NumFromName(nmf,i) then ValueNum[i]:=StuffString(ValueNum[i],AStart,ALength,ASubText);
  DelStack;
end;

procedure TCustomRec.eomSelf;
var i: longint;
begin
  AddStack('TCustomRec.eomSelf',Self);
  if NumFromName(nmf,i) then ValueNum[i]:=eom(ValueNum[i]);
  DelStack;
end;

procedure TCustomRec.IncMonthSelf;
var i: longint;
begin
  AddStack('TCustomRec.IncMonthSelf',Self);
  if NumFromName(nmf,i) then ValueNum[i]:=IncMonth(ValueNum[i],NumberOfMonths);
  DelStack;
end;

procedure TCustomRec.IncV(const nmf: string; const d2: double = 1);
var i: longint;
begin
  AddStack('TCustomRec.IncV(n)',Self);
  if NumFromName(nmf,i) then IncV(i,d2);
  DelStack;
end;

procedure TCustomRec.IncV(const nmf,d2: string);
var i: longint;
begin
  AddStack('TCustomRec.IncV(s)',Self);
  if NumFromName(nmf,i) then IncV(i,d2);
  DelStack;
end;

procedure TCustomRec.IncV(i: longint; const d2: variant);
begin
  AddStack('TCustomRec.IncV(i)',Self);
  ValueNum[i]:=ValueNum[i]+d2;
  DelStack;
end;

procedure TCustomRec.IncV(i: longint; const d2: Double; ndec: longint);
begin
  AddStack('TCustomRec.IncV(i,dec)',Self);
  ValueNum[i]:=mround(ValueNum[i]+d2,ndec);
  DelStack;
end;

procedure TCustomRec.SetArrayValue;
var i: longint;
begin
  AddStack('TCustomRec.SetArrayValue',Self);
  for i:=low(anmf) to high(anmf) do Value[anmf[i]]:=v;
  DelStack;
end;

class procedure TCustomRec.LogTrnsVal(var Prm: TLogTrnsValPrm; var v: string; lOld: boolean);
var j: longint;
begin
  AddStack('TCustomRec.LogTrnsVal(Prm)');
  Prm.lOld:=lOld; Prm.lBreak:=false; Prm.val:=v;
  if not Prm.lBreak then for j:=low(aLogTrnsValProc) to high(aLogTrnsValProc) do begin
    Prm.ap:=aLogTrnsValProc[j].ap; aLogTrnsValProc[j].Proc(Prm);
    if Prm.lBreak then begin
      v:=Prm.val; break;
    end;
  end;
  DelStack;
end;

class function TCustomRec.LogTrnsVal(var Prm: TLogTrnsValPrm; const Value: variant; lOld: boolean; t: TFieldType; fi: PMQFieldInfo): string;
const PrmNum: TFmtNum = (FracDlm:','; FracCnt:FloatMaxDec);
var fl,Bool: boolean;
begin
  AddStack('TCustomRec.LogTrnsVal');
  if IsNil(Value) then result:=''
  else begin
    Bool := t=ftBoolean;
    if Bool then fl:=Value
    else begin
      if Assigned(fi) then Bool := mqfBool in fi.Options;
      if Bool then fl:=StrToBoolean(Value) else fl:=false;
    end;
    if Bool
      then result:=bRus[fl]
    else if t=ftFloat then begin
      result:=FmtNum(Value,PrmNum);
      if Pos(PrmNum.FracDlm,result)>0 then result:=TrimSpRight(result,['0']);
    end
    else if (t=ftDate) and empty(Value)
      then result:=''
    else result:=TFld.VarToStr(Value,t);
    LogTrnsVal(Prm,result,lOld); TrimRightSelf(result);
  end;
  DelStack;
end;

function TCustomRec.LogPrim(Opt: TLogPrimOptions = [logpKey]; af: PArrBool = nil;
  Proc: TLogPrimProc = nil; ProcPrm: pointer = nil): string;
var Prm: TLogTrnsValPrm;
  ap: TArrVar;
  procedure FLogPrim(Oper: TLogPrimOper; const av: array of variant);
  begin
    Self.FLogPrim(Prm,Oper,av,ap);
  end;
var i: longint;
  function NoEmpKey(const v: variant): boolean;
  begin
    AddStack('TCustomRec.LogPrim.NoEmpKey',Self);
    result := (logpMod in Opt) or not empty(v); FLogPrim(logpNoEmpKey,[longint(@result),i]);
    DelStack;
  end;
var fi: PMQFieldInfo;
  f: TFld;
  function v2s(const Value: variant; lOld: boolean): string;
  begin
    AddStack('TCustomRec.LogPrim.v2s',Self);
    result:=LogTrnsVal(Prm,Value,lOld,UnDataType(f),fi);
    DelStack;
  end;
const PrmNum: TFmtNum = (FracDlm:','; FracCnt:FloatMaxDec);
var keyord: byte;
  ov,v,q,oq: string;
  akey: TArrStr;
  fv,fov: variant;
  fl,olp: boolean;
begin
  AddStack('TCustomRec.LogPrim',Self);
  Prm.Opt:=Opt;
  with Prm do begin
    result:=''; Sender:=Self; FLogPrim(logpCreate,[]);
    InitArrLen(akey,FField.Count); olp:=LogPrimCalc;
    try
      LogPrimCalc:=true;
      for i:=0 to FField.Count-1 do begin
        f:=Field[i]; fv:=f.Value; fov:=f.OldValue; keyord:=0; fi:=nil; fl:=true;
        FLogPrim(logpIsFld,[longint(@fl),i,longint(@fi),longint(@fv),longint(@fov),longint(@keyord),longint(af),byte(Opt)]);
        if not fl then continue;
        lOut := IfThen(keyord=0,(logpNoKey in Opt) and lOut
          and ((logpNoLogFields in Opt) or (LogFields.Count=0) or (LogFields.IndexOf(NameRec+'.'+FField[i])>=0)),
          logpKey in Opt);
        if lOut and NoEmpKey(fv) then begin
          nmf:=FField[i]; av:=nil; nm:=''; fl:=true;
          FLogPrim(logpGet,[longint(@fl),i,byte(Opt),fov,longint(@ov),longint(@v)]);
          if fl then begin
            v:=v2s(f.Value,false);
            if logpMod in Opt then begin
              ov:=v2s(fov,true);
              if (keyord>0) and not NoEmpKey(f.Value) and not NoEmpKey(fov) then lOut:=false;
            end;
          end;
          if lOut and NoEmpKey(v) then begin
            if nm='' then nm:=FField[i];
            if Assigned(Proc) then Proc(Prm,ProcPrm);
            if SubStr(nm,-1)<>':' then IncD(nm,':');
            fl:=true; FLogPrim(logpGet1,[longint(@fl),i,ov,v]);
            if fl then begin
              oq:=IfThen(Pos(CRLF,ov)=0,'"',CRLF);
              q :=IfThen(Pos(CRLF,v )=0,'"',CRLF);
              IncD(nm,IfThen((logpMod in Opt) and (ov<>v),oq+ov+oq+'->')+q+v+q);
            end;
            if keyord=0 then IncD(result,nm+LogDlm) else akey[keyord-1]:=nm;
          end;
        end;
      end;
    finally
      FLogPrim(logpFree,[]); LogPrimCalc:=olp;
    end;
    for i:=high(akey) downto low(akey) do
      if akey[i]<>'' then IncL(result,akey[i]+LogDlm);
    result:=DlmBetween(DlmBetween(LogPrimBeg,SubStr(result,1,-lLogDlm),LogDlm),LogPrimEnd,LogDlm);
  end;
  DelStack;
end;

procedure TCustomRec.FLogPrim;
begin
end;

procedure TCustomRec.RestOldVal;
var i: longint;
begin
  AddStack('TCustomRec.RestOldVal',Self);
  for i:=0 to FField.Count-1 do with Field[i] do Value:=OldValue;
  DelStack;
end;

function TCustomRec.FldDataType(i: longint): TFieldType;
begin
  AddStack('TCustomRec.FldDataType(i)',Self);
  result:=UnDataType(Field[i]);
  DelStack;
end;

function TCustomRec.FldDataType(const nmf: string): TFieldType;
begin
  AddStack('TCustomRec.FldDataType(nmf)',Self);
  result:=UnDataType(FldName(nmf));
  DelStack;
end;

procedure TCustomRec.IfThenCalculate;
begin
  if Assigned(Proc) then Proc(Self,lApp);
end;

procedure TCustomRec.IfThenFldChange;
begin
  AddStack('TCustomRec.IfThenFldChange',Self);
  FldName(nmf).OnChange:=RecVal.IfThenFldChange(AValue,ATrue,AFalse);
  DelStack;
end;

{procedure TCustomRec.ReplFldVar;
var n: longint;
begin
  AddStack('TCustomRec.ReplFldVar',Self);
  n:=NumFromName(nmf);
  if ValueNum[n]=vFrom then ValueNum[n]:=vTo;
  DelStack;
end;

{ TRecVal }
constructor TRecVal.Create;
begin
	AddStack('TRecVal.Create',Self);
	inherited Create(AOwner);
	FFields:=TStringList.Create; TStringList(FFields).onChange:=FieldsChange;
  DelStack;
end;

destructor TRecVal.Destroy;
begin
	AddStack('TRecVal.Destroy',Self);
  FFields.Free;
  inherited Destroy;
  DelStack;
end;

{procedure TRecVal.Assign(Source: TPersistent);
begin
	AddStack('TRecVal.Assign',Self);
  if Source is TRecVal
  then Fields.Assign(TRecVal(Source).Fields);
	inherited Assign(Source);
  DelStack;
end;}

procedure TRecVal.SetFields;
begin
	AddStack('TRecVal.SetFields',Self);
	FFields.Assign(v); OpenRec;
  DelStack;
end;

procedure TRecVal.FieldsChange;
begin
	AddStack('TRecVal.FieldsChange',Self);
	OpenRec;
  DelStack;
end;

procedure TRecVal.BeginUpdate;
begin
  FFields.BeginUpdate;
end;

procedure TRecVal.EndUpdate;
begin
  FFields.EndUpdate;
end;

function TRecVal.OpenRec;
var i: longint;
  Prm: TRecValPrm;
begin
	AddStack('TRecVal.OpenRec',Self);
	if csDesigning in ComponentState then CloseRec;
	for i:=0 to FFields.Count-1 do
    if StrToPrm(FFields[i],Prm) then with Prm do FCreateFld(AName,AType,ASize,AValue);
  result := inherited OpenRec;
  DelStack;
end;

class function TRecVal.StrToPrm;
var l: longint;
  a: TNamePrimStr;
begin
  AddStack('TRecVal.StrToPrm');
  result:=StrDivDlm('=',st,a);
  if result then with Prm do begin
    AName:=Trim(a[1]); AType:=ftString; ASize:=10; AValue:='';
    l:=ListAsArray(StrToAtPart(a[2],APrim,cButCapt),a,UnDelim); TrimSelf(a);
    if l>0 then begin
    	if length(a[1])>0 then
        case UpCase(a[1][1]) of
          'B','L': AType:=ftBoolean;
          'D': AType:=ftDateTime;
          'F': AType:=ftFloat;
          'I','N': AType:=ftInteger;
          'M': AType:=ftMemo;
        end;
	    ASize:=Int0(copy(a[1],2,MaxInt));
    end;
    case AType of
      ftBoolean: AValue:=false;
      ftString,ftMemo: AValue:='';
    else AValue:=0;
    end;
    if l>1 then
      case AType of
        ftInteger: AValue:=Int0(a[2]);
        ftFloat: AValue:=Float0(a[2]);
        ftBoolean: AValue:=AnsiStartsText(bTrue,a[2]);
        ftDateTime: AValue:=ctod(a[2]);
      else AValue:=StrDefQQ(a[2]);
      end;
  end;
  DelStack;
end;

procedure TRecVal.CreateFld;
var s: string;
begin
	AddStack('TRecVal.CreateFld',Self);
  case UnDataType(AType) of
    ftInteger: s:=StrNum('N'+UnDelim,cValue);
    ftBoolean: s:='L'+UnDelim+Bool2Str(cValue);
    ftFloat: s:='F'+UnDelim+MyFloatToStr(cValue,FloatMaxLen,FloatMaxDec);
    ftDate: s:='D'+UnDelim+dtoc(cValue);
    ftMemo: s:='M'+UnDelim+'"'+cValue+'"';
  else s:=StrNum('S',ASize)+UnDelim+'"'+cValue+'"';
  end;
  if not ReWrite then ReWrite:=empty(FFields.Values[AName]);
  if ReWrite then FFields.Values[AName]:=s+AtPartToStr(APrim,cButCapt);
  DelStack;
end;

// Уничтожить поле
procedure TRecVal.DestroyFld;
var i: longint;
	nmf: string;
begin
	AddStack('TRecVal.DestroyFld',Self);
	nmf:=AnsiUpperCase(cfName); i:=0;
	while i<FFields.Count do
    if AnsiUpperCase(FFields.Names[i])=nmf then FFields.Delete(i) else Inc(i);
  DelStack;
end;

procedure IfThenTrns(PrTrns: TRecValIniTrns; const FieldName: string; var Value: variant; lSave: boolean);
begin
  if Assigned(PrTrns) then PrTrns(FieldName,Value,lSave);
end;

function TRecVal.SaveToIni;
  procedure Fld1(const nm: string; f: TFld);
  var v: variant;
  begin
    AddStack('TRecVal.SaveToIni.Fld1',Self);
    v:=f.Value; IfThenTrns(PrTrns,nm,v,true);
    case UnDataType(f) of
      ftInteger: IntToStrSelf(v);
      ftBoolean: bStrSelf(v);
      ftFloat: v:=Trim(StrTran(MyFloatToStr(v,FloatMaxLen,FloatMaxDec),DecimalSeparator,'.'));
      ftDate: dtosSelf(v);
    else IncL(v,'"');
    end;
    InitFIni[fiSave].WriteString(result,nm,v);
    DelStack;
  end;
var i: longint;
begin
  AddStack('TRecVal.SaveToIni',Self);
  result:=SectIni(SectId); InitFIni[fiSave].EraseSection(result);
  if Assigned(pFldInc)
  then for i:=low(pFldInc^) to high(pFldInc^) do Fld1(pFldInc^[i],FldName(pFldInc^[i]))
  else for i:=0 to FField.Count-1 do Fld1(FField[i],Field[i]);
  DelStack;
end;

procedure TRecVal.RestFromIni;
var Sect: string;
  v: variant;
  ls: TStrStrList;
  i,j: longint;
begin
  AddStack('TRecVal.RestFromIni',Self);
  Sect:=SectIni(SectId);
  for i:=0 to FField.Count-1 do if InitFIni[fiSave].FindValueIndex(Sect,FField[i],ls,j) then begin
    v:=ls.Value[j];
    case FldDataType(i) of
      ftInteger: Int0Self(v);
      ftBoolean: StrToBoolSelf(v);
      ftFloat: Float0Self(v);
      ftDate: stodSelf(v);
    else DeleteVar(v);
    end;
    IfThenTrns(PrTrns,FField[i],v,false); Field[i].Value:=v;
  end;
  DelStack;
end;

function TRecVal.SectIni;
begin
  AddStack('TRecVal.SectIni',Self);
  result:='TRecVal.'+IfThen(SectId='',NameRec,SectId);
  DelStack;
end;

procedure TRecVal.FLogPrim;
var nmf: string;
  vp: TRecValPrm;
begin
  AddStack('TRecVal.FLogPrim',Self);
  case Oper of
    logpIsFld: Prm.lOut:=true;
    logpGet: begin
      nmf:=FieldName[longint(av[1])];
      if StrToPrm(nmf+'='+FFields.Values[nmf],vp) then Prm.nm:=vp.APrim;
    end;
  end;
  DelStack;
end;

procedure TRecVal.LogWrite(const tbl: string = '');
begin
  AddStack('TRecVal.LogWrite',Self);
  MyTypes.LogWrite(tbl,LogPrim([logpNoKey]));
  DelStack;
end;

{ TLogFieldsList }
function LogFldStr(r: TCustomRec; const nmf: string): string;
begin
  AddStack('RecVal.LogFldStr');
  result:=r.NameRec+'.'+nmf;
  DelStack;
end;

procedure TLogFieldsList.AddRecFld(r: TCustomRec; const nmf: string);
begin
  AddStack('TLogFieldsList.AddRecFld');
  if Assigned(r) then Add(LogFldStr(r,nmf));
  DelStack;
end;

procedure TLogFieldsList.AddRecFld(r: TCustomRec; const nmf: array of string);
var i: longint;
begin
  for i:=low(nmf) to high(nmf) do AddRecFld(r,nmf[i]);
end;

procedure TLogFieldsList.DelRecFld;
begin
  AddStack('TLogFieldsList.DelRecFld');
  FindDel(Self,LogFldStr(r,nmf));
  DelStack;
end;

procedure TLogFieldsList.ReplaceNameRec;
var i: longint;
  a: array[1..2] of string;
  nmr: string;
begin
  AddStack('TLogFieldsList.ReplaceNameRec');
  BeginUpdate; Sorted:=false; nmr:=TrimUpper(ro.NameRec);
  for i:=0 to Count-1 do begin
    ListAsArray(Strings[i],a,'.');
    if TrimUpper(a[1])=nmr then begin
      a[1]:=rn.NameRec; Strings[i]:=ArrayAsList(a,'.');
    end;
  end;
  Sorted:=true; EndUpdate;
  DelStack;
end;

{ TCustomLogCompare }
class procedure TCustomLogCompare.ExecuteStr;
var ls: array[boolean] of pointer;
  l: TArrBoolInt;
  Prm1: TLogTrnsValPrm;
  function FGetItem(lNew: boolean; n: longint; tp: TLogCompareItemList): string;
  begin
    AddStack('TCustomCompare.ExecuteStr.FGetItem');
    Exclude(Prm1.Opt,logpMod); Prm1.val:=''; GetItem(Prm1,pv,ls[lNew],ls[lNew],n,n,tp); result:=Prm1.val;
    DelStack;
  end;
  procedure PrnCng(no,nn: longint);
  var s,sn: string;
  begin
    AddStack('TCustomCompare.ExecuteStr.PrnCng');
    Include(Prm1.Opt,logpMod); Prm1.val:=''; GetItem(Prm1,pv,ls[false],ls[true],no,nn,clogPrn);
    sn:=TrimSpRight(Prm1.val); s:=IfThen(Pos(CRLF,sn)=0,'"',CRLF);
    if s=CRLF then TrimRightSelf(sn);
    IncD(Prm.val,IfThen(not((s=CRLF)and empty(Prm.val)),s)+sn+s);
    DelStack;
  end;
  function IsEqual(no,nn: longint; MaybeStr1: boolean = false): boolean;
  begin
    AddStack('TCustomCompare.ExecuteStr.IsEqual');
    result := FGetItem(false,no,clogKey)=FGetItem(true,nn,clogKey);
    if result then if (FGetItem(false,no,clogNoKey)<>FGetItem(true,nn,clogNoKey)) then begin
      if not(MaybeStr1 or (logpFixCnt in Prm.Opt))
      then IncD(Prm.val,'[ред.'+Format(IfThen(no=nn,'№%d','№%d->%d'),[no+1,nn+1])+']');
      PrnCng(no,nn);
    end;
    DelStack;
  end;
  procedure AddRes(lNew: boolean; nb,ne: longint);
  begin
    AddStack('TCustomCompare.ExecuteStr.AddRes');
    if not(logpFixCnt in Prm.Opt)
    then IncD(Prm.val,'['+IfThen(lNew,'доб.','удал.')+Format(IfThen(nb=ne,'№%d','№№%d-%d'),[nb+1,ne+1])+']'+CRLF);
    while nb<=ne do begin
      IncD(Prm.val,TrimRight(FGetItem(lNew,nb,clogPrn))+CRLF); Inc(nb);
    end;
    DelStack;
  end;
var no,nob: longint;
  fl: boolean;
  procedure PrDel;
  begin
    AddStack('TCustomCompare.ExecuteStr.PrDel');
    if nob>=0 then begin
      AddRes(false,nob,no-1); nob:=-1;
    end;
    Inc(no); fl:=false;
    DelStack;
  end;
var nn,nn1: longint;
  lNew,lApp: boolean;
  v: TArrBoolStr;
  s: string;
begin
  AddStack('TCustomLogCompare.ExecuteStr');
  Init(Prm,pv); Prm1:=Prm;
  with Prm do begin
    val:=''; lApp := not(logpMod in Opt);
    for lNew:=lApp to true do ls[lNew]:=ListCreate(pv,IfThen(lNew,sn,so),lNew);
    try
      for lNew:=lApp to true do l[lNew]:=GetCount(pv,ls[lNew]);
      if lApp then for nn:=0 to l[true]-1 do IncD(val,TrimRight(FGetItem(true,nn,clogPrn))+CRLF)
      else if (l[false]>1) or (l[true]>1) then begin
        no:=0; nob:=-1; nn:=0;
        while no<l[false] do begin
          fl:=true;
          if nn<l[true] then
            if IsEqual(no,nn) then begin
              PrDel; Inc(nn); continue;
            end;
          nn1:=nn+1;
          while nn1<l[true] do
            if IsEqual(no,nn1) then begin
              PrDel; AddRes(true,nn,nn1-1); nn:=nn1+1; break;
            end
            else Inc(nn1);
          if fl then begin
            if nob<0 then nob:=no;
            Inc(no);
          end;
        end;
        PrDel;
        if nn<l[true] then AddRes(true,nn,l[true]-1);
      end
      else begin
        if (l[false]=1) and (l[true]=1)
        then fl := not IsEqual(0,0,true)
        else fl := (l[false]>0) or (l[true]>0);
        if fl then begin
          s:='"';
          for lNew:=false to true do begin
            if l[lNew]=0 then v[lNew]:='' else v[lNew]:=TrimRight(FGetItem(lNew,0,clogPrn));
            if Pos(CRLF,v[lNew])>0 then s:=CRLF;
          end;
          val:=v[false]+s+'->'+s+v[true];
        end;
      end;
    finally
      for lNew:=true downto lApp do ListDestroy(pv,ls[lNew]);
    end;
  end;
  DelStack;
end;

class procedure TCustomLogCompare.Init;
begin
end;

class procedure TCustomLogCompare.Execute(var Prm: TLogTrnsValPrm; pv: pointer; PrTrans: TPrimTrans = nil);
  function Trans(const s: string): string;
  begin
    AddStack('TCustomLogCompare.Execute.Trans');
    result:=IfThenTrans(PrTrans,s);
    DelStack;
  end;
var sn,so: string;
begin
  AddStack('TCustomLogCompare.Execute');
  with Prm do begin
    if Length(av)=0 then with Sender.FldName(nmf) do begin
      sn:=Trans(Value);
      if IsNil(OldValue) then so:=sn else so:=Trans(OldValue);
      ExecuteStr(Prm,so,sn,pv); AddFromVArr(av,[val]);
    end
    else val:=av[0];
    lBreak:=true;
  end;
  DelStack;
end;

class procedure TCustomLogCompare.Execute(var Prm: TLogTrnsValPrm);
begin
  Execute(Prm,nil);
end;

class procedure TCustomLogCompare.AddRes(var Prm: TLogTrnsValPrm; const so,sn: string; pv: pointer = nil;
  const Capt: string = ''; Level: byte = 0);
var Prm1: TLogTrnsValPrm;
  a: TArrStr;
  s: string;
  i: longint;
begin
  AddStack('TCustomLogCompare.AddRes');
  Prm1:=Prm; Prm1.val:=''; ExecuteStr(Prm1,so,sn,pv); TrimRightSelf(Prm1.val);
  if Prm1.val<>'' then begin
    TrimRightSelf(Prm.val);
    if Capt<>'' then DlmBetwSelf(Prm.val,Space(Level)+Capt+':',CRLF,false);
    i:=LsArrDynamic(Prm1.val,a,CRLF);
    if i>1 then begin
      TrimRightSelf(Prm.val); s:=CRLF+Space(Level+IfThen(Capt<>'',1));
      for i:=0 to i-1 do DlmBetwSelf(Prm.val,a[i],s,false);
    end
    else begin
      s:=IfThen((Prm1.val[1]<>'"') or (Prm1.val[Length(Prm1.val)]<>'"'),'"');
      IncD(Prm.val,' '+s+TrimRight(Prm1.val)+s);
    end;
    IncD(Prm.val,CRLF);
  end;
  DelStack;
end;

function LogCompareStrInt;
var i: longint;
begin
  AddStack('RecVal.LogCompareStrInt');
  i:=PLongInt(p)^; result:=IfThen(not empty(i) or (logpMod in Prm.Opt),IntToStr(i));
  DelStack;
end;

class procedure TCustomLogCompare.AddRes(var Prm: TLogTrnsValPrm; so,sn: longint;
  const Capt: string = ''; Level: byte = 0);
begin
  AddRes(LogCompareStrInt,Prm,@so,@sn,nil,Capt,Level);
end;

function LogCompareStrBool(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var fl: boolean;
begin
  AddStack('RecVal.LogCompareStrBool');
  fl:=PBoolean(p)^; result:=IfThen(fl or (logpMod in Prm.Opt),bRus[fl]);
  DelStack;
end;

class procedure TCustomLogCompare.AddRes(var Prm: TLogTrnsValPrm; so,sn: boolean;
  const Capt: string = ''; Level: byte = 0);
begin
  AddRes(LogCompareStrBool,Prm,@so,@sn,nil,Capt,Level);
end;

class procedure TCustomLogCompare.AddRes(Proc: TLogCompareStrProc;
  var Prm: TLogTrnsValPrm; po,pn: pointer; pv: pointer = nil;
  const Capt: string = ''; Level: byte = 0);
begin
  AddRes(Prm,Proc(Prm,po,pv),Proc(Prm,pn,pv),pv,Capt,Level);
end;

class procedure TCustomLogCompare.AddRes(Proc: TLogCompareStrNewProc;
  var Prm: TLogTrnsValPrm; po,pn: pointer; pv: pointer = nil;
  const Capt: string = ''; Level: byte = 0);
begin
  AddRes(Prm,Proc(Prm,po,pv,false),Proc(Prm,pn,pv,true),pv,Capt,Level);
end;

{ TStrLogCompare }
class function TStrLogCompare.ListCreate;
begin
  AddStack('TStrLogCompare.ListCreate');
  result:=NewString(Value);
  DelStack;
end;

class procedure TStrLogCompare.ListDestroy;
begin
  AddStack('TStrLogCompare.ListDestroy');
  Dispose(PString(ls));
  DelStack;
end;

class function TStrLogCompare.GetCount;
begin
  result:=1;
end;

class procedure TStrLogCompare.GetItem;
begin
  AddStack('TStrLogCompare.GetItem');
  if tp<>clogNoKey then Prm.val:=PString(lsn)^;
  DelStack;
end;

{ TDlmLogCompare }
class function TDlmLogCompare.ListCreate;
begin
  AddStack('TDlmLogCompare.ListCreate');
  result:=ListCreateDlm(Value,PString(pv)^);
  DelStack;
end;

class function TDlmLogCompare.ListCreateDlm;
var a: PArrStr;
begin
  AddStack('TDlmLogCompare.ListCreateDlm');
  New(a); result:=a; LsArrDynamic(Value,a^,Dlm,lsaSetLen);
  DelStack;
end;

class procedure TDlmLogCompare.ListDestroy;
var a: PArrStr;
begin
  AddStack('TDlmLogCompare.ListDestroy');
  a:=ls; a^:=nil; Dispose(a);
  DelStack;
end;

class function TDlmLogCompare.GetCount;
begin
  AddStack('TDlmLogCompare.GetCount');
  result:=Length(PArrStr(ls)^);
  DelStack;
end;

class procedure TDlmLogCompare.GetItem;
begin
  AddStack('TDlmLogCompare.GetItem');
  if tp<>clogNoKey then Prm.val:=PArrStr(lsn)^[nn];
  DelStack;
end;

class procedure TDlmLogCompare.Execute(var Prm: TLogTrnsValPrm; const Dlm: string);
begin
  AddStack('TDlmLogCompare.Execute');
  Execute(Prm,@Dlm);
  DelStack;
end;

{ TCrlfLogCompare }
class function TCrlfLogCompare.ListCreate;
const s: string = CRLF;
begin
  AddStack('TCrlfLogCompare.ListCreate');
  result:=inherited ListCreate(@s,Value,lNew);
  DelStack;
end;

{ TStrListLogCompare }
class function TStrListLogCompare.ListCreate;
begin
  AddStack('TStrListLogCompare.ListCreate');
  result:=TStringList.Create;
  DelStack;
end;

class procedure TStrListLogCompare.ListDestroy;
begin
  AddStack('TStrListLogCompare.ListDestroy');
  TStringList(ls).Free;
  DelStack;
end;

class function TStrListLogCompare.GetCount;
begin
  AddStack('TStrListLogCompare.GetCount');
  result:=TStringList(ls).Count;
  DelStack;
end;

class procedure TStrListLogCompare.GetItem;
begin
  AddStack('TStrListLogCompare.GetItem');
  if tp<>clogNoKey then Prm.val:=TStringList(lsn)[nn];
  DelStack;
end;

{ TChkLogCompare }
class function TChkLogCompare.ListCreate;
var p: PChkLogPrm;
  a: PArrInt;
  i,j: longint;
  v: string;
begin
  AddStack('TChkLogCompare.ListCreate');
  New(a); result:=a; p:=pv;
  if p.Invert then v:=NoBytes(Value) else v:=Value;
  i:=Length(p.a); SetLength(a^,i); j:=0;
  for i:=low(p.a) to high(p.a) do if GetByte(v,i+1) then begin
    a^[j]:=i; Inc(j);
  end;
  SetLength(a^,j);
  DelStack;
end;

class procedure TChkLogCompare.ListDestroy;
var a: PArrInt;
begin
  AddStack('TChkLogCompare.ListDestroy');
  a:=ls; a^:=nil; Dispose(a);
  DelStack;
end;

class function TChkLogCompare.GetCount;
begin
  AddStack('TChkLogCompare.GetCount');
  result:=Length(PArrInt(ls)^);
  DelStack;
end;

class procedure TChkLogCompare.GetItem;
var a: PArrInt;
  p: PChkLogPrm;
begin
  AddStack('TChkLogCompare.GetItem');
  if tp<>clogNoKey then begin
    a:=lsn; p:=pv;
    case tp of
      clogKey: Prm.val:=IntToStr(a^[nn]);
      clogPrn: Prm.val:=p.a[a^[nn]];
    end;
  end;
  DelStack;
end;

class procedure TChkLogCompare.Execute(var Prm: TLogTrnsValPrm; const a: array of string;
  Invert: boolean = false; PrTrans: TPrimTrans = nil);
var p: TChkLogPrm;
begin
  AddStack('TChkLogCompare.Execute');
  CopyFrom(p.a,a); p.Invert:=Invert; Execute(Prm,@p,PrTrans);
  DelStack;
end;

initialization
  AddStack('RecVal.initialization');
  LogFields:=TLogFieldsList.Create; LogFields.Sorted:=true;
  LogFieldsBound:=SortStrListCreate;
  DelStack;
finalization
	AddStack('RecVal.finalization');
  LogFields.Free; LogFieldsBound.Free;
  DelStack;
end.
