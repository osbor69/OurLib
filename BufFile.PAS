unit BufFile;

interface

{$I LIBTEST}

uses Classes,SysUtils,Windows,Controls,Messages,
  MyTypes;

type
  TMGSaveValProc = procedure(const Value: variant; tp: TSaveType) of object;
  TMGSaveStrProc = function(const s: string): longint of object;

  TBufWriteOpt = set of (wrCrlf,wrLen);

  TBufReadStringTo = (rdtoChar,rdtoCtrl,rdtoEof);

  TCustomBuf = class(TObject)
  private
    FErrorMessage: string;
    FCtrl: longword;
    FLastVers,FVers: byte;
    FForWrite: boolean;
    function GetDim(Index: longint): Int64;
  protected
    Stream: TStream;
    procedure BeforeDestroy; virtual;
    function CheckControlErrorMsg: string; virtual;
  public
    property ErrorMessage: string read FErrorMessage write FErrorMessage;
    property Ctrl: longword read FCtrl;
    property Position: Int64 index 1 read GetDim;
    property Size: Int64 index 2 read GetDim;
    property Vers: byte read FVers;
  	constructor Create(AForWrite: boolean = false; LastVers: byte = 0; VersCheck: byte = 0);
  	destructor Destroy; override;
    function Active: boolean; virtual;
    function Eof: boolean;
    function Seek(Offset: Int64; Origin: Word): Int64;
    procedure IncPosition(const Offset: Int64);
    function Substr(Count: LongInt): string;
		function Read(tp: TSaveType): variant; overload;
		function Read(usl: boolean; tp: TSaveType; const Def: variant): variant; overload;
		function ReadBuf(var Buffer: TSaveRec; Count: byte): byte;
		function ReadChar(var c: char): boolean;
		function ReadString(var s: string; rdto: TBufReadStringTo; c: char = #13): boolean;
		function ReadStr(tp: TSaveType = stLongWord): string; overload;
		function ReadStr(ln: longword): string; overload;
		function ReadStr(usl: boolean; tp: TSaveType = stLongWord): string; overload;
		function ReadStr(var s: string): longword; overload;
		function Write(const Value: variant; tp: TSaveType): byte;
    function WriteBuf(const Buffer: TSaveRec; Count: byte): byte; virtual;
		function WriteChar(c: char): boolean;
		function WriteString(const st: string; Opt: TBufWriteOpt = [];
      l: longint = NegDef; tp: TSaveType = stLongWord): boolean;
    function WriteStr(const s: string; tp: TSaveType = stLongWord): boolean;
    function CopyFrom(Source: TCustomBuf): Int64;
		procedure ReadModelPrim(var MDPrim: TModelPrim);
		class procedure SaveModelPrim(const MDPrim: TModelPrim;
    	SaveVal: TMGSaveValProc; SaveStr: TMGSaveStrProc; NSave: longint);
  end;

  TBufWrite = class(TObject)
  private
    Owner: TStream;
    PrWrite: pointer;
    sBuf: string;
    lBuf: Word;
    Active: boolean;
    procedure Update;
    constructor Create(AOwner: TStream; ProcWrite: pointer);
    function PrWriteEval(const Buffer; Count: Longint): Longint;
    function Write(const Buffer; Count: Longint): Longint;
  public
    destructor Destroy; override;
  end;

  TStrBufStream = class(TStringStream)
  private
    BufWrite: TBufWrite;
  public
    constructor Create(const AString: string);
    destructor Destroy; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
  end;

  TMemoBufStream = class(TMemoryStream)
  private
    BufWrite: TBufWrite;
  public
    constructor Create;
    destructor Destroy; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
  end;

  TStrBuf = class(TCustomBuf)
  private
    pResult: PString;
  protected
    procedure BeforeDestroy; override;
  public
  	constructor CreateRead(const AString: string; LastVers: byte = 0; VersCheck: byte = 0);
  	constructor CreateWrite(pRes: PString = nil; LastVers: byte = 0);
    function DataString: string;
  end;

  TClipboardBuf = class(TStrBuf)
  protected
    procedure BeforeDestroy; override;
  public
  	constructor CreateRead(ClipboardType: TClipboardType; LastVers: byte = 0);
  	constructor CreateWrite(ClipboardType: TClipboardType; LastVers: byte = 0);
    class procedure ViewerCreate(var Viewer: HWND; Sender: TWinControl);
    class procedure ViewerFree(var Viewer: HWND; Sender: TWinControl);
    class procedure ViewerChangeCBChain(var Viewer: HWND; var Msg: TWMChangeCBChain);
    class procedure ViewerDrawClipboard(Viewer: HWND);
  end;

  TCryptoBufProcStream = procedure(Sender: TStream; AForWrite: boolean; const av: array of variant);

  TCryptoBuf = class(TCustomBuf)
  private
    FPswd: string;
    FProcStream: TCryptoBufProcStream;
    PrmProcStream: TArrVar;
  protected
    procedure BeforeDestroy; override;
    procedure ProcStream(Sender: TStream; AForWrite: boolean); dynamic;
  public
  	constructor Create(const aPswd: string; const av: array of variant;
      PrStream: TCryptoBufProcStream; AForWrite: boolean = false; LastVers: byte = 0);
  end;

  TFileBufStream = class(TFileStream)
  private
    BufWrite: TBufWrite;
  	FFileName: TFileName;
  public
    property FileName: TFileName read FFileName;
    constructor Create(const AFileName: TFileName; Mode: Word);
    destructor Destroy; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    function Update(lMsg: boolean = false): boolean;
    function Active: boolean;
    procedure IncPosition(const Offset: Int64);
  end;

  TFileBuf = class(TCustomBuf)
  private
  	FFileName: TFileName;
  protected
    function CheckControlErrorMsg: string; override;
  public
    property FileName: TFileName read FFileName;
  	constructor Create(const AFileName: TFileName;
      AForWrite: boolean = false; LastVers: byte = 0; VersCheck: byte = 0); overload; virtual;
    function WriteBuf(const Buffer: TSaveRec; Count: byte): byte; override;
    function Update(lMsg: boolean = false): boolean;
    function Active: boolean; override;
  end;

  TXmlState = record
    nLine,nLv: longint;
    cRead: Char;
    lIncLv,Struct: boolean;
    Name: string;
    Value: variant;
    aAtr: TArrNamePrimStr;
  end;

  TFileBufXmlFmtError = procedure(const Message: string) of object;

  TXmlList = (xmlWrite,xmlUTF8,xmlSetCode); TXmlOpt = set of TXmlList;

  TXmlWriteList = (xmlwBound,xmlwNillable,xmlwAtr,xmlwNoTrimLeft,xmlwNoTrimRight);
  PXmlWriteOpt = ^TXmlWriteOpt; TXmlWriteOpt = set of TXmlWriteList;

  TXmlStrOper = (xmlsBeg,xmlsRekv,xmlsAtr,xmlsEnd);
  TXmlStrProc = procedure(Oper: TXmlStrOper; const ap: array of variant; var av: TArrVar) of object;
  
  TFileBufXml = class(TFileBuf)
  private
    FUTF8,AtrNoBound: boolean;
    sAtr: string;
		function FWriteString(const st: string; lcrlf: boolean = true): boolean;
    function FWriteStrBeg(nLv: longint): boolean;
    function FWriteStrBegCrlf(nLv: longint): boolean;
    function WriteStrPrior: boolean;
    procedure PrRead(Oper: TXmlStrOper; const ap: array of variant; var av: TArrVar);
  public
    aPrefIgnore: TArrStr;
    aLv: array of record
      nm,sAtr: string;
      Opt: set of (xmllvWrited,xmllvEmpty,xmllvNillable);
    end;
    State: TXmlState;
    OnReadRekv: TNotifyEvent;
    OnFmtError: TFileBufXmlFmtError;
    FmtDate: string;
    EndAtrIgnore: boolean;
  	constructor Create(const AFileName: TFileName;
      Opt: TXmlOpt = []; LastVers: byte = 0; VersCheck: byte = 0); overload;
    function WriteStrBeg(const Name: string; Opt: TXmlWriteOpt = []): boolean;
    function WriteStrEnd: boolean;
    function WriteSimple(const Name: string; const Value: variant; const Fmt: string = '';
      Opt: TXmlWriteOpt = []): boolean;
    function WriteSimpleDef(const Name: string; const Value,Def: variant;
      const Fmt: string = ''; Opt: TXmlWriteOpt = []): boolean;
    function ReadRekv(const Fmt: string = ''; qAtr: TCharSet = ['"']): boolean;
    function ReadStruct(const nmRekv: string; const ap: array of variant;
      Proc: TXmlStrProc = nil; lav: longint = 0): boolean; 
    function FmtCheck(const Fmt: string = ''; lTrimLeft: boolean = true): variant; overload;
    function FmtCheck(var Value: variant; const nmRekv: string;
      const Fmt: string = ''; lTrimLeft: boolean = true): boolean; overload;
    function FmtCheck(var Value: variant; i: longint; const nmRekv: string;
      const Fmt: string = ''; lTrimLeft: boolean = true): boolean; overload;
    function FmtCheck(var Value: variant; i1,i2: longint; const nmRekv: string;
      const Fmt: string = ''; lTrimLeft: boolean = true): boolean; overload;
    function FmtCheck(var Value: variant; i1,i2,i3: longint; const nmRekv: string;
      const Fmt: string = ''; lTrimLeft: boolean = true): boolean; overload;
  end;

procedure FileCloseAll;
function FileBufXmlVar(const v: variant): TFileBufXml;
function IfThen(AValue: boolean; ATrue: TXmlList): TXmlOpt; overload;
function IfThen(AValue: boolean; ATrue: TXmlWriteList): TXmlWriteOpt; overload;

implementation

uses Variants,Math,StrUtils,DateUtils,ClipBrd,{$IFDEF MSWINDOWS}RTLConsts,{$ENDIF}
  My_pr,Inter,Shifr,Crypto;

const MaxBuf = 262144;
  MaxBufWrite = 16384;

  GGClipboards = 'GGClipboards';

  AtrNil = ' xsi:nil="true"';

var nFile: byte = 0;
	aFile: array[1..5] of TFileBuf;

function OptCrlf(AValue: boolean): TBufWriteOpt;
begin
  if AValue then Result:=[wrCrlf] else Result:=[];
end;

// ФАЙЛ_НОМЕР
function d_num(const v,ind: variant; lSave: boolean): variant;
begin
	AddStack('BufFile.d_num');
  if lSave then nFile:=v;
  result:=nFile;
  DelStack;
end;

function fAct(k: longint): boolean;
begin
  AddStack('BufFile.fAct');
  if InRange(k,Low(aFile),High(aFile)) then result:=Assigned(aFile[k]) else result:=false;
  DelStack;
end;

// ФАЙЛ_КОНЕЦ
function d_eof(const v,ind: variant; lSave: boolean): variant;
begin
	AddStack('BufFile.d_eof');
  if fAct(nFile) then result:=aFile[nFile].Eof else result:=true;
  DelStack;
end;

// ФАЙЛ_ЗАКРЫТЬ
function c_close(var av: array of variant): variant;
var k: longint;
  ResAct,lMsg: boolean;
begin
	AddStack('BufFile.c_close');
  case MyVarType(av[1],true) of
    varNull: k:=nFile;
    varDouble,varDate: k:=av[1];
  else k:=0;
  end;
  ResAct := MyVarType(av[2])=V_BOOL;
  if ResAct then lMsg:=av[2] else lMsg:=false;
  result:=fAct(k);
  if result then begin
    if ResAct then
      if not aFile[k].Update(lMsg) then result:=false;
    FreeAndNil(aFile[k]);
    if k=nFile then nFile:=0;
  end
  else if lMsg then meserr(StrNum('Отсутствует открытый файл с номером ',k));
  DelStack;
end;

procedure FileCloseAll;
var i: byte;
begin
  AddStack('BufFile.FileCloseAll');
  for i:=low(aFile) to high(aFile) do FreeAndNil(aFile[i]);
  DelStack;
end;

function FileBufXmlVar;
begin
  result:=PointerVar(v);
end;

function IfThen(AValue: boolean; ATrue: TXmlList): TXmlOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TXmlWriteList): TXmlWriteOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

// ФАЙЛ_ОТКРЫТЬ
function c_open(var av: array of variant): variant;
var k,j: longint;
  AForWrite: boolean;
  fXml: TFileBufXml;
begin
	AddStack('BufFile.c_open');
	result:=0; j:=-1;
	for k:=low(aFile) to high(aFile) do
		if aFile[k]=nil then begin
      j:=k; break;
		end;
	if j=-1 then raise EInterAnyError.Create('Уже существует максимальное число открытых файлов');
  av[1]:=FullNameExe(av[1],''); AForWrite:=IsNilc(av[2],false);
  if IsNil(av[4],0)=0
  then aFile[j]:=TFileBuf.Create(av[1],AForWrite)
  else begin
    aFile[j]:=TFileBufXml.Create(av[1],IfThen(AForWrite,xmlWrite)+IfThen(av[4]=2,xmlUTF8),0,0);
    TFileBufXml(aFile[j]).AtrNoBound:=IsNilc(av[6],false);
  end;
  if aFile[j].Active then begin
  	nFile:=j; result:=j;
    if MyVarType(av[5])=varArray then
      if aFile[j].FForWrite then
        for k:=VarArrayLowBound(av[5],1) to VarArrayHighBound(av[5],1) do
          aFile[j].WriteString(av[5][k],[wrCrlf])
      else if IsClass(aFile[j],TFileBufXml,pointer(fXml)) then with fXml do while ReadRekv('?') do
        if (State.nLv=0) and (StrToChar(State.Name)<>'/') then InterProcStat([av[5],null,State.Name,null]);
  end
  else begin
    if IsNilc(av[3],false) then MsgDlg(aFile[j].FErrorMessage);
    InitArr(av); av[1]:=j; c_close(av);
  end;
  DelStack;
end;

// ФАЙЛ_СЧИТАТЬ
function c_read(var av: array of variant): variant;
var c: char;
	i,l: Int64;
  j: byte;
  s: string;
  fl: boolean;
  fXml: TFileBufXml;
begin
	AddStack('BufFile.c_read');
  result:='';
  if fAct(nFile) then
    if IsClass(aFile[nFile],TFileBufXml,pointer(fXml)) then with fXml do
      if MyVarType(IsNil(av[1],''))=varArray
      then ReadStruct(av[1][1],av[1],PrRead)
      else result:=FmtCheck(string(av[1]),IsNilc(av[2],true))
    else with aFile[nFile] do begin
      if MyVarType(IsNil(av[1],true))=varBoolean then l:=Size-Position
      else begin
        l:=av[1]; av[1]:=true;
      end;
      SetLength(s,l); i:=0;
      while i<l do
        if ReadChar(c) then begin
          if not av[1] and (Pos(c,CRLF)>0) then begin
            j:=0; fl:=true;
            repeat
              Inc(j);
              if c<>CRLF[j] then break;
              if j=lCRLF then begin
                fl:=false; break;
              end;
            until not ReadChar(c);
            if fl then IncPosition(1-j);
            break;
          end;
          Inc(i); s[i]:=c;
        end
        else break;
      SetLength(s,i); result:=s;
    end;
  DelStack;
end;

// ФАЙЛ_ВСТАТЬ
function c_seek(var av: array of variant): variant;
begin
	AddStack('BufFile.c_seek');
  if fAct(nFile)
  then result:=aFile[nFile].Seek(IsNilc(av[1],0),IsNilc(av[2],soFromBeginning))
  else result:=0;
  DelStack;
end;

// ФАЙЛ_ЗАПИСАТЬ
function c_write(var av: array of variant): variant;
var ap: TArrVar;
  i: byte;
  Opt: TXmlWriteOpt;
  fXml: TFileBufXml;
begin
	AddStack('BufFile.c_write');
  result:=false;
  if fAct(nFile) then
    if IsClass(aFile[nFile],TFileBufXml,pointer(fXml)) then with fXml do begin
      i:=Bool2Int(av[4]); Opt:=IfThen(i=1,xmlwBound)+IfThen(i=2,xmlwNillable);
      if MyVarType(av[2])=varArray then begin
        if WriteStrBeg(av[1],Opt) then begin
          SetLength(ap,Length(av)); InitArr(ap);
          for i:=VarArrayLowBound(av[2],1) to min(Length(ap),VarArrayHighBound(av[2],1)) do ap[i-1]:=av[2][i];
          IsNil(ap[0],av[1]); InterProcStat(ap); result:=WriteStrEnd;
        end;
      end
      else begin
        IsNil(av[3],'');
        if IsNilc(av[6],false) then Include(Opt,xmlwAtr);
        if not IsNilc(av[7],true) then Include(Opt,xmlwNoTrimLeft);
        if not IsNilc(av[8],true) then Include(Opt,xmlwNoTrimRight);
        if IsNil(av[5])
        then result:=WriteSimple(av[1],av[2],av[3],Opt)
        else result:=WriteSimpleDef(av[1],av[2],av[5],av[3],Opt);
      end;
    end
    else result:=aFile[nFile].WriteString(av[1],OptCrlf(IsNilc(av[2],false)));
  DelStack;
end;

// КОП_ДИСК
function c_diskwait(var av: array of variant):variant;
begin
	AddStack('BufFile.c_diskwait');
  result:=DiskWait(av[1],IsNilc(av[2],''),IsNilc(av[3],''),
    IfThen(IsNilc(av[4],false),dskwXDel)+IfThen(IsNilc(av[5],false),dskwVer));
  DelStack;
end;

// ТЕК_ПАПКА
function c_curdir(var av: array of variant):variant;
begin
	AddStack('BufFile.c_curdir');
  result:=IfThen(IsNilc(av[1],true),ExeDir,CurrentDir);
  DelStack;
end;

// ФАЙЛ_УДАЛИТЬ
function c_del(var av: array of variant):variant;
begin
	AddStack('BufFile.c_del');
  result:=DelFileAtr(av[1]);
  DelStack;
end;

// ФАЙЛ_ПЕРЕИМЕН
function c_rename(var av: array of variant):variant;
begin
	AddStack('BufFile.c_rename');
  result:=RnmFileAtr(av[1],av[2]);
  DelStack;
end;

// ПАПКА_СОЗДАТЬ
function c_mdir(var av: array of variant):variant;
begin
	AddStack('BufFile.c_mdir');
  result:=ForceDirMsg(av[1]);
  DelStack;
end;

// МАСК_ФАЙЛ
function PrCompTime(List: TStringList; Index1,Index2: longint): longint;
begin
  AddStack('BufFile.PrCompTime');
  result:=IntObj(List,Index2)-IntObj(List,Index1);
  DelStack;
end;

function c_maskfile(var av: array of variant): variant;
var ls: TStringList;
	Attr: TFileMaskType;
begin
	AddStack('BufFile.c_maskfile');
  ls:=TStringList.Create;
  try
  	Attr:=[];
    if IsNilc(av[2],true) then Include(Attr,fmFiles);
    if IsNilc(av[3],false) then Include(Attr,fmDir);
  	GetMaskFiles(ls,av[1],Attr,[msfAge]);
    case byte(IsNilc(av[4],0)) of
      1: ls.Sorted:=true;
      2: ls.CustomSort(PrCompTime);
    end;
    result:=Ls2Var(ls);
  finally
    ls.Free;
  end;
  DelStack;
end;

// ФАЙЛ_ИМЯ
function c_extr(var av: array of variant): variant;
const l=1; h=4;
begin
	AddStack('BufFile.c_extr');
  result:=VarArrayCreate([l,h],varVariant);
  result[1]:=ExtractFilePath(av[1]);
  result[2]:=ExtractFileName(av[1]);
  result[3]:=ExtractFileExt(av[1]);
  result[4]:=ExtractFileDrive(av[1]);
  if not IsNil(av[2]) then
    if InRange(av[2],l,h) then result:=result[byte(av[2])]
    else raise EInterAnyError.CreateFmt('2-й параметр должен быть от %d до %d',[l,h]);
  DelStack;
end;

// ФАЙЛ_РАЗМЕР
function c_size(var av: array of variant): variant;
begin
	AddStack('BufFile.c_size');
  if IsNil(av[1]) then
    if fAct(nFile) then result:=aFile[nFile].Size else result:=0
  else result:=GetFileSize(FullNameExe(av[1],''));
  DelStack;
end;

// ФАЙЛ_ДАТА
function c_date(var av: array of variant): variant;
begin
	AddStack('BufFile.c_date');
  if IsNil(av[1]) then
    if fAct(nFile)
    then result:=FileDateToDateTime(FileGetDate(TFileBufStream(aFile[nFile].Stream).Handle))
    else result:=DateEmpty
  else result:=GetFileDateTime(FullNameExe(av[1],''));
  DelStack;
end;

// ФАЙЛ_НАЙТИ
function c_searchpath(var av: array of variant): variant;
var path,PathDop: TFileName;
	v: variant;
  i: longint;
begin
	AddStack('BufFile.c_searchpath');
  v:=IsNilc(av[2],'');
  if MyVarType(v)=varArray then begin
  	PathDop:='';
  	for i:=VarArrayLowBound(v,1) to VarArrayHighBound(v,1) do IncD(PathDop,v[i]+';');
    DecLen(PathDop);
  end
  else PathDop:=v;
  path:=''; SearchPath(av[1],path,PathDop); result:=path;
  DelStack;
end;

// ФАЙЛ_ПРОТОКОЛ
function c_protstradd(var av: array of variant): variant;
begin
	AddStack('BufFile.c_protstradd');
  result:=null; MyTypes.ProtocolStrAdd(IsNilc(av[1],protDebug),av[2]);
  DelStack;
end;

{ TCustomBuf }
constructor TCustomBuf.Create;
var s: string;
  l,i,lb: longint;
  j: byte;
  p,pCtrl,pz: Int64;
  sr: TSaveRec;
begin
	AddStack('TCustomBuf.Create');
  FForWrite:=AForWrite; FLastVers:=LastVers;
  if Active and (FLastVers>0) then
    if AForWrite then Write(FLastVers,stByte)
    else begin
      FVers:=Read(stByte);
      if FVers>=VersCheck then begin
        FErrorMessage:=CheckControlErrorMsg;
        if FVers<=FLastVers then begin
          pz:=Stream.Position; Stream.Position:=0;
          lb:=min(Size,MaxBuf); SetLength(s,lb); p:=0; pCtrl:=Size-SizeOfVar[stLongWord];
          repeat
            l:=Stream.Read(pointer(s)^,lb);
            for i:=1 to l do
              if p=pCtrl then begin
                for j:=1 to SizeOfVar[stLongWord] do sr.s[j]:=s[i+j-1];
                if sr.crd=FCtrl then FErrorMessage:='';
                break;
              end
              else begin
                Inc(FCtrl,Ord(s[i])); Inc(p);
              end;
          until l=0;
          Stream.Position:=pz;
        end;
      end;
    end;
  DelStack;
end;

destructor TCustomBuf.Destroy;
begin
	AddStack('TCustomBuf.Destroy');
  if FForWrite and (FLastVers>0) then Write(FCtrl,stLongWord);
  BeforeDestroy; Stream.Free;
  inherited Destroy;
  DelStack;
end;

procedure TCustomBuf.BeforeDestroy;
begin
end;

function TCustomBuf.CheckControlErrorMsg;
begin
  result:='Некорректная структура';
end;

function TCustomBuf.GetDim;
begin
	AddStack('TCustomBuf.GetDim');
  if Index=1 then result:=Stream.Position else result:=Stream.Size;
  DelStack;
end;

function TCustomBuf.Eof;
begin
  result := Position>=Size;
end;

function TCustomBuf.Active;
begin
  result := FErrorMessage='';
end;

function TCustomBuf.Seek;
begin
  result:=Stream.Seek(Offset,Origin);
end;

procedure TCustomBuf.IncPosition;
begin
  Seek(Offset,soFromCurrent);
end;

function TCustomBuf.Substr;
var i: longint;
begin
	AddStack('TCustomBuf.Substr');
  if Active then begin
    i:=min(Count,Stream.Size-Stream.Position); SetLength(result,i);
    i:=Stream.Read(pointer(result)^,i); SetLength(result,i);
  end
  else result:='';
  DelStack;
end;

function TCustomBuf.Read(tp: TSaveType): variant;
var sr: TSaveRec;
begin
	AddStack('TCustomBuf.Read');
  ReadBuf(sr,SizeOfVar[tp]); result:=SvRecToVar(sr,tp);
  DelStack;
end;

function TCustomBuf.Read(usl: boolean; tp: TSaveType; const Def: variant): variant;
begin
  if usl then result:=Read(tp) else result:=Def;
end;

function TCustomBuf.ReadBuf;
begin
	AddStack('TCustomBuf.ReadBuf');
	if Active then result:=Stream.Read(Buffer.s,Count) else result:=0;
  DelStack;
end;

function TCustomBuf.ReadChar;
begin
	AddStack('TCustomBuf.ReadChar');
	if Active then result := Stream.Read(c,1)=1 else result:=false;
  DelStack;
end;

function TCustomBuf.ReadString;
var l,i,ps,lb: longint;
label lend;
begin
	AddStack('TCustomBuf.ReadString');
	result:=Active;
	if result then
    if rdto=rdtoChar then begin
      ps:=0; lb:=min(Stream.Size-Stream.Position,MaxBuf); SetLength(s,lb);
      repeat
        l:=Stream.Read(PointerStr(s,ps)^,lb); Dec(lb,l);
        for i:=ps+1 to ps+l do if s[i]=c then begin
          SetLength(s,i-1); IncPosition(i-ps-l+IfThen(c=#13,1)); goto lend;
        end;
        Inc(ps,MaxBuf);
      until l=0;
    end
    else begin
      l:=Stream.Size-IfThen(rdto=rdtoCtrl,SizeOfVar[stLongWord])-Stream.Position; result := l>0;
      if result then begin
        SetLength(s,l); Stream.Read(pointer(s)^,l);
      end;
    end;
lend:
  DelStack;
end;

function TCustomBuf.ReadStr(tp: TSaveType = stLongWord): string;
var ln: longword;
begin
  AddStack('TCustomBuf.ReadStr');
  ln:=Read(tp); result:=ReadStr(ln);
  DelStack;
end;

function TCustomBuf.ReadStr(ln: longword): string;
begin
  AddStack('TCustomBuf.ReadStr(l)');
  SetLength(result,ln); Stream.Read(pointer(result)^,ln);
  DelStack;
end;

function TCustomBuf.ReadStr(usl: boolean; tp: TSaveType = stLongWord): string;
begin
  if usl then result:=ReadStr(tp) else result:='';
end;

function TCustomBuf.ReadStr(var s: string): longword;
begin
  result:=Stream.Read(pointer(s)^,Length(s));
end;

function TCustomBuf.Write;
var sr: TSaveRec;
begin
	{$IFDEF STACKALL}AddStack('TCustomBuf.Write');{$ENDIF}
	VarToSvRec(Value,tp,sr); result:=WriteBuf(sr,SizeOfVar[tp]);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TCustomBuf.WriteBuf;
var i: SmallInt;
begin
	{$IFDEF STACKALL}AddStack('TCustomBuf.WriteBuf');{$ENDIF}
	if Active then begin
    result:=Stream.Write(Buffer.s,Count);
  	for i:=1 to Count do Inc(FCtrl,Ord(Buffer.s[i]));
  end
  else result:=0;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

// Записать 1 байт
function TCustomBuf.WriteChar;
begin
	AddStack('TCustomBuf.WriteChar');
	result:=Active;
	if result then begin
    result := Stream.Write(c,1)=1; Inc(FCtrl,Ord(c));
  end;
  DelStack;
end;

// Записать строку
function TCustomBuf.WriteString;
var i: longint;
	s: string;
begin
	{$IFDEF STACKALL}AddStack('TCustomBuf.WriteString');{$ENDIF}
  if Active then begin
    s:=st;
    if wrCrlf in Opt then IncD(s,CRLF);
    ReplNegSelf(l,s);
    if wrLen in Opt then Write(l,tp);
    result := Stream.Write(pointer(s)^,l)=l;
    for i:=1 to l do Inc(FCtrl,Ord(s[i]));
  end
  else result:=false;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TCustomBuf.WriteStr;
begin
  AddStack('TCustomBuf.WriteStr');
  result:=WriteString(s,[wrLen],NegDef,tp);
  DelStack;
end;

function TCustomBuf.CopyFrom;
var s: string;
  l: longint;
begin
  AddStack('TCustomBuf.CopyFrom');
  result:=0;
  repeat
    s:=Source.Substr(MaxBuf); l:=Length(s);
    if l=0 then break;
    Inc(result,l); WriteString(s);
  until false;
  DelStack;
end;

procedure TCustomBuf.ReadModelPrim;
var Vers: byte;
  i,l: longint;
begin
  AddStack('TCustomBuf.ReadModelPrim');
  Vers:=Read(stByte); SetLength(MDPrim,longint(Read(stInteger)));
  for i:=low(MDPrim) to high(MDPrim) do with MDPrim[i] do begin
    NumSave:=Read(stInteger); Prim:=ReadStr;
    if Vers<1 then begin
      Date:=DateEmpty; Autor:=''; Themes:=nil;
    end
    else begin
      Date:=Read(stDouble); Autor:=ReadStr; l:=Read(stInteger); SetLength(Themes,l);
      for l:=0 to l-1 do Themes[l]:=ReadStr; 
    end;
  end;
  DelStack;
end;

class procedure TCustomBuf.SaveModelPrim;
var i,l: longint;
begin
  AddStack('TCustomBuf.SaveModelPrim');
  // При изменении редактировать Помощь-Библиотека-Содержимое-Последние изменения основы
  SaveVal(1,stByte); l:=0;
  for i:=low(MDPrim) to high(MDPrim) do
    if MDPrim[i].NumSave<=NSave then Inc(l);
  SaveVal(l,stInteger);
  for i:=low(MDPrim) to high(MDPrim) do with MDPrim[i] do if NumSave<=NSave then begin
    SaveVal(NumSave,stInteger); SaveStr(Prim);
    SaveVal(Date,stDouble); SaveStr(Autor); l:=Length(Themes); SaveVal(l,stInteger);
    for l:=0 to l-1 do SaveStr(Themes[l]);
  end;
  DelStack;
end;

{ TBufWrite }
constructor TBufWrite.Create;
begin
  AddStack('TBufWrite.Create');
  Owner:=AOwner; PrWrite:=ProcWrite; SetLength(sBuf,MaxBufWrite); Active:=true;
  DelStack;
end;

destructor TBufWrite.Destroy;
begin
  AddStack('TBufWrite.Destroy');
  Update;
  inherited Destroy;
  DelStack;
end;

procedure TBufWrite.Update;
begin
  AddStack('TBufWrite.Update');
  if lBuf>0 then begin
    PrWriteEval(pointer(sBuf)^,lBuf); lBuf:=0;
  end;
  DelStack;
end;

function TBufWrite.PrWriteEval;
var Proc: function(const Buffer; Count: Longint): Longint of object;
begin
  {$IFDEF STACKALL}AddStack('TBufWrite.PrWriteEval');{$ENDIF}
  TMethod(Proc).Code:=PrWrite;
  TMethod(Proc).Data:=Owner;
  result:=Proc(Buffer,Count);
  if result<>Count then Active:=false;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TBufWrite.Write;
begin
  {$IFDEF STACKALL}AddStack('TBufWrite.Write');{$ENDIF}
  if Count>MaxBufWrite then begin
    Update; result:=PrWriteEval(Buffer,Count);
    if not Active then result:=0;
  end
  else begin
    result:=Count;
    if lBuf+Count>MaxBufWrite then begin
      Update;
      if not Active then result:=0;
    end;
    if result>0 then begin
      CopyMemory(PointerStr(sBuf,lBuf),@Buffer,Count); Inc(lBuf,Count);
    end;
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

{ TStrBufStream }
constructor TStrBufStream.Create;
begin
  AddStack('TStrBufStream.Create');
  inherited Create(AString);
  BufWrite:=TBufWrite.Create(Self,@TStringStream.Write);
  DelStack;
end;

destructor TStrBufStream.Destroy;
begin
  AddStack('TStrBufStream.Destroy');
  BufWrite.Free;
  inherited Destroy;
  DelStack;
end;

function TStrBufStream.Write;
begin
  {$IFDEF STACKALL}AddStack('TStrBufStream.Write');{$ENDIF}
  result:=BufWrite.Write(Buffer,Count);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TStrBufStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  AddStack('TStrBufStream.Seek');
  BufWrite.Update; result := inherited Seek(Offset*aSign[Origin=soFromEnd],Origin);
  DelStack;
end;

{ TMemoBufStream }
constructor TMemoBufStream.Create;
begin
  AddStack('TMemoBufStream.Create');
  inherited Create;
  BufWrite:=TBufWrite.Create(Self,@TMemoryStream.Write);
  DelStack;
end;

destructor TMemoBufStream.Destroy;
begin
  AddStack('TMemoBufStream.Destroy');
  BufWrite.Free;
  inherited Destroy;
  DelStack;
end;

function TMemoBufStream.Write;
begin
  {$IFDEF STACKALL}AddStack('TMemoBufStream.Write');{$ENDIF}
  result:=BufWrite.Write(Buffer,Count);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TMemoBufStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  AddStack('TMemoBufStream.Seek');
  BufWrite.Update; result := inherited Seek(Offset*aSign[Origin=soFromEnd],Origin);
  DelStack;
end;

{ TStrBuf }
constructor TStrBuf.CreateRead;
begin
  AddStack('TStrBuf.CreateRead');
  Stream:=TStrBufStream.Create(AString);
  inherited Create(false,LastVers,VersCheck);
  DelStack;
end;

constructor TStrBuf.CreateWrite;
begin
  AddStack('TStrBuf.CreateWrite');
  Stream:=TStrBufStream.Create(''); pResult:=pRes;
  inherited Create(true,LastVers);
  DelStack;
end;

function TStrBuf.DataString;
begin
  AddStack('TStrBuf.DataString');
  with TStrBufStream(Stream) do begin
    BufWrite.Update; result:=DataString;
  end;
  DelStack;
end;

procedure TStrBuf.BeforeDestroy;
begin
  AddStack('TStrBuf.BeforeDestroy');
  SetPString(pResult,DataString);
  DelStack;
end;

{ TClipboardBuf }
constructor TClipboardBuf.CreateRead;
var s: string;
begin
  AddStack('TClipboardBuf.CreateRead');
  try
    s:=StrDeShifr(ClipBoard.AsText,false);
  except
    s:='';
  end;
  inherited CreateRead(s,LastVers);
  if Active then
    if not((ReadStr(Length(GGClipboards))=GGClipboards) and (Read(stByte)=ClipboardType))
    then FErrorMessage:=ClipBoardErrorMessage(ClipboardType);
  DelStack;
end;

constructor TClipboardBuf.CreateWrite;
begin
  AddStack('TClipboardBuf.CreateWrite');
  inherited CreateWrite(nil,LastVers);
  WriteString(GGClipboards); Write(ClipboardType,stByte);
  DelStack;
end;

procedure TClipboardBuf.BeforeDestroy;
begin
  AddStack('TClipboardBuf.BeforeDestroy');
  if FForWrite then ClipBoard.AsText:=StrShifr(DataString);
  DelStack;
end;

class procedure TClipboardBuf.ViewerCreate;
begin
  AddStack('TClipboardBuf.ViewerCreate');
  Viewer:=SetClipboardViewer(Sender.Handle);
  DelStack;
end;

class procedure TClipboardBuf.ViewerFree;
begin
  AddStack('TClipboardBuf.ViewerFree');
  if Viewer<>0 then begin
    ChangeClipboardChain(Sender.Handle,Viewer); Viewer:=0;
  end;
  DelStack;
end;

class procedure TClipboardBuf.ViewerChangeCBChain;
begin
  AddStack('TClipboardBuf.ViewerChangeCBChain');
  Msg.Result:=0;
  if Msg.Remove=Viewer then Viewer:=Msg.Next
  else SendMessage(Viewer,WM_CHANGECBCHAIN,Msg.Remove,Msg.Next);
  DelStack;
end;

class procedure TClipboardBuf.ViewerDrawClipboard;
begin
  AddStack('TClipboardBuf.ViewerDrawClipboard');
  SendMessage(Viewer,WM_DRAWCLIPBOARD,0,0);
  DelStack;
end;

{ TCryptoBuf }
constructor TCryptoBuf.Create;
var ss: TMemoryStream;
  cs: TCryptoStream;
  cnt: longword;
  LastVersCrypto: byte;
begin
  AddStack('TCryptoBuf.Create');
  Stream:=TMemoBufStream.Create; FProcStream:=PrStream; CopyFromVArr(PrmProcStream,av); FPswd:=aPswd;
  if not AForWrite then begin
    ss:=TMemoryStream.Create; ProcStream(ss,false); cs:=TCryptoStream.Create(ss,FPswd);
    try
      ss.Position:=0;
      ss.Read(LastVersCrypto,SizeOf(LastVersCrypto));
      ss.Read(cnt,SizeOf(cnt));
      Stream.CopyFrom(cs,cnt);
      Stream.Position:=0;
    finally
      cs.Free; ss.Free;
    end;
  end;
  inherited Create(AForWrite,LastVers);
  DelStack;
end;

procedure TCryptoBuf.BeforeDestroy;
const LastVersCrypto: byte = 1;
var ss: TMemoryStream;
  cs: TCryptoStream;
  cnt: longword;
begin
  AddStack('TCryptoBuf.BeforeDestroy');
  if FForWrite then begin
    cnt:=Stream.Size; ss:=TMemoryStream.Create; cs:=TCryptoStream.Create(ss,FPswd);
    try
      ss.Write(LastVersCrypto,SizeOf(LastVersCrypto)); ss.Write(cnt,SizeOf(cnt)); cs.CopyFrom(Stream,0);
      ProcStream(ss,true);
    finally
      cs.Free; ss.Free;
    end;
  end;
  DelStack;
end;

procedure TCryptoBuf.ProcStream;
begin
  AddStack('TCryptoBuf.ProcStream');
  if Assigned(FProcStream) then FProcStream(Sender,AForWrite,PrmProcStream);
  DelStack;
end;

{ TFileBufStream }
constructor TFileBufStream.Create;
begin
  AddStack('TFileBufStream.Create');
  FFileName:=Trim(AFileName);
  if Mode=fmCreate then
  begin
    inherited Create(FileBufCreate(FFileName));
    if FHandle<0 then
      raise EFCreateError.CreateResFmt(@SFCreateErrorEx,[ExpandFileName(FFileName),SysErrorMessage(GetLastError)]);
  end
  else
  begin
    inherited Create(FileBufOpen(FFileName,Mode));
    if FHandle<0 then
      raise EFOpenError.CreateResFmt(@SFOpenErrorEx,[ExpandFileName(FFileName),SysErrorMessage(GetLastError)]);
  end;
  BufWrite:=TBufWrite.Create(Self,@TFileStream.Write);
  DelStack;
end;

destructor TFileBufStream.Destroy;
begin
  AddStack('TFileBufStream.Destroy');
  BufWrite.Free;
  inherited Destroy;
  DelStack;
end;

function TFileBufStream.Write;
begin
  {$IFDEF STACKALL}AddStack('TFileBufStream.Write');{$ENDIF}
  result:=BufWrite.Write(Buffer,Count);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TFileBufStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  AddStack('TFileBufStream.Seek');
  Update; result := inherited Seek(Offset,Origin);
  DelStack;
end;

function TFileBufStream.Active;
begin
  result:=BufWrite.Active;
end;

function TFileBufStream.Update;
begin
  AddStack('TFileBufStream.Update');
  BufWrite.Update; result:=Active;
  if not result and lMsg then mess_ok(['Ошибка записи в файл:',FFileName]);
  DelStack;
end;

procedure TFileBufStream.IncPosition;
begin
  Seek(Offset,soFromCurrent);
end;

{ TFileBuf }
constructor TFileBuf.Create(const AFileName: TFileName;
  AForWrite: boolean = false; LastVers: byte = 0; VersCheck: byte = 0);
var ost: longint;
  s: string;
begin
	ost:=AddStack('TFileBuf.Create');
	FFileName:=Trim(AFileName);
  try
    Stream:=TFileBufStream.Create(FFileName,IfThen(AForWrite,fmCreate,fmOpenRead or fmShareDenyNone));
  except
    on EFileStreamError do begin
      SetStack(ost);
      FErrorMessage:='Ошибка '+IfThen(AForWrite,'создания','открытия')+' файла:'+CRLF+FFileName;
      s:=ExtractFilePath(FFileName);
      if not empty(s) then
        if not DirectoryExists(s) then IncD(FErrorMessage,CRLF+'Нет доступа к папке:'+CRLF+s);
    end;
  end;
  inherited Create(AForWrite,LastVers,VersCheck);
  DelStack;
end;

function TFileBuf.CheckControlErrorMsg;
begin
  AddStack('TFileBuf.CheckControlErrorMsg');
  result := inherited CheckControlErrorMsg+' файла:'+CRLF+FFileName;
  DelStack;
end;

function TFileBuf.WriteBuf;
begin
  {$IFDEF STACKALL}AddStack('TFileBuf.WriteBuf');{$ENDIF}
  result:=inherited WriteBuf(Buffer,Count);
  if not Active then FErrorMessage:='Ошибка записи в файл:'+CRLF+FFileName;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TFileBuf.Update;
begin
  AddStack('TFileBuf.Update');
  result:=Active;
  if result then begin
    result:=TFileBufStream(Stream).Update(lMsg);
    if not result then FErrorMessage:='Ошибка записи в файл:'+CRLF+FFileName;
  end
  else if lMsg then meserr(FErrorMessage);
  DelStack;
end;

function TFileBuf.Active;
begin
  result:=inherited Active;
  if result then result:=TFileBufStream(Stream).Active;
end;

{ TFileBufXml }
const Utf8First = #$EF#$BB#$BF;
  scb='&#x'; sce=';';

constructor TFileBufXml.Create(const AFileName: TFileName;
  Opt: TXmlOpt = []; LastVers: byte = 0; VersCheck: byte = 0);
var i: longint;
  lErr: boolean;
begin
  AddStack('TFileBufXml.Create');
  State.nLine:=0; State.nLv:=0; State.lIncLv:=false;
  inherited Create(AFileName,xmlWrite in Opt);
  if Active then begin
    SetLength(aLv,10); FUTF8 := xmlUTF8 in Opt;
    if xmlWrite in Opt then FWriteString({IfThen(FUTF8,Utf8First)+}'<?xml version="1.0" encoding="'+IfThen(FUTF8,'UTF-8','windows-1251')+'"?>')
    else begin
      State.cRead:=' '; lErr:=not(xmlSetCode in Opt);
      if lErr then if ReadRekv('',['"','''']) then
        if (AnsiUpperCase(State.Name)='?XML') and (State.Value='') then begin
          i:=high(State.aAtr);
          if i>=0 then if (State.aAtr[i,1]='?') and (State.aAtr[i,2]='') then begin
            lErr:=false;
            for i:=low(State.aAtr) to i do if AnsiUpperCase(State.aAtr[i,1])='ENCODING' then begin
              FUTF8 := AnsiUpperCase(State.aAtr[i,2])='UTF-8'; break;
            end;
          end;
        end;
      FErrorMessage:=IfThen(lErr,'Некорректный формат файла:'+CRLF+FFileName); State.lIncLv:=false;
    end;
  end;
  DelStack;
end;

function TFileBufXml.FWriteString;
var s: string;
begin
  AddStack('TFileBufXml.FWriteString');
  if FUTF8 then s:=WinToUtf8(st) else s:=st;
  result:=WriteString(s,OptCrlf(lcrlf));
  DelStack;
end;

function TFileBufXml.WriteStrBeg;
begin
  AddStack('TFileBufXml.WriteStrBeg');
  if Length(aLv)=State.nLv then SetLength(aLv,State.nLv shl 1);
  aLv[State.nLv].nm:=Trim(Name);
  aLv[State.nLv].sAtr:=sAtr;
  aLv[State.nLv].Opt:=[];
  if (xmlwBound in Opt) or (sAtr<>'') and not AtrNoBound then Include(aLv[State.nLv].Opt,xmllvWrited);
  if xmlwNillable in Opt then Include(aLv[State.nLv].Opt,xmllvNillable);
  result:=not(xmllvWrited in aLv[State.nLv].Opt);
  if not result then
    if WriteStrPrior then result:=FWriteStrBeg(State.nLv);
  Inc(State.nLv); sAtr:='';
  DelStack;
end;

function TFileBufXml.WriteStrEnd;
begin
  AddStack('TFileBufXml.WriteStrEnd');
  Dec(State.nLv);
  with aLv[State.nLv] do begin
    if not(xmllvWrited in Opt) and not(xmllvEmpty in Opt) and (xmllvNillable in Opt) then begin
      if AtrNoBound then sAtr:=AtrNil+'/' else IncD(sAtr,AtrNil+'/');
      FWriteStrBeg(State.nLv); FWriteString('',true);
    end;
    if xmllvWrited in Opt
    then result:=FWriteString(IfThen(not(xmllvEmpty in Opt),Space(State.nLv))+'</'+nm+'>')
    else result:=true;
  end;
  DelStack;
end;

function TFileBufXml.FWriteStrBeg;
begin
  AddStack('TFileBufXml.FWriteStrBeg');
  result:=FWriteStrBegCrlf(nLv);
  if result then begin
    Include(aLv[nLv].Opt,xmllvEmpty); result:=FWriteString(Space(nLv)+'<'+aLv[nLv].nm+aLv[nLv].sAtr+'>',false);
  end;
  DelStack;
end;

function TFileBufXml.FWriteStrBegCrlf;
begin
  AddStack('TFileBufXml.FWriteStrBegCrlf');
  result:=true;
  if nLv>0 then with aLv[nLv-1] do if xmllvEmpty in Opt then begin
    Exclude(Opt,xmllvEmpty); result:=WriteString('',[wrCrlf]);
  end;
  DelStack;
end;

function TFileBufXml.WriteStrPrior;
var i: longint;
begin
  AddStack('TFileBufXml.WriteStrPrior');
  result:=true;
  for i:=low(aLv) to State.nLv-1 do if not(xmllvWrited in aLv[i].Opt) then
    if FWriteStrBeg(i) then Include(aLv[i].Opt,xmllvWrited)
    else begin
      result:=false; break;
    end;
  DelStack;
end;

function FmtEncode(const Fmt: string; var l,h: longint): longint;
var i,j: longint;
begin
  AddStack('BufFile.FmtEncode');
  case StrToChar(Fmt) of
    'D','M','М': result:=varDate;
    'L': result:=varBoolean;
    'N': begin
      result:=varDouble; l:=FloatMaxLen; h:=0;
      if IsPos(i,'(',Fmt) then begin
        Inc(i);
        if IsPos(j,'.',Fmt,i) then begin
          l:=Int0(Copy(Fmt,i,j-i)); h:=Int0(Copy(Fmt,j+1,MaxInt));
        end
        else l:=Int0(Copy(Fmt,i,MaxInt));
      end;
    end;
  else
    result:=varString; l:=0; h:=MaxInt; i:=Pos('(',Fmt);
    if InRange(i,1,Length(Fmt)-2) then begin
      Inc(i);
      if Fmt[i]='=' then begin
        l:=Int0(Copy(Fmt,i+1,MaxInt)); h:=l;
      end
      else if IsPos(j,'-',Fmt,i) then begin
        l:=Int0(Copy(Fmt,i,j-i)); h:=Int0(Copy(Fmt,j+1,MaxInt));
        if h=0 then h:=MaxInt;
      end
      else h:=Int0(Copy(Fmt,i,MaxInt));
    end;
  end;
  DelStack;
end;

function GetDate(const Fmt: string; dt: TDateTime): TDateTime;
begin
  AddStack('BufFile.GetDate');
  if (StrToChar(Fmt) in ['M','М']) and (dt<>DateEmpty) and (dt<>DateBig)
  then result:=StartOfTheMonth(dt)
  else result:=dt;
  DelStack;
end;

function TFileBufXml.WriteSimple;
var s,v: string;
  {i,}ost,l,h,t: longint;
  fl: boolean;
  a: TArrStr;
  ov: variant;
  oErr: TFileBufXmlFmtError;
  d: TDateTime;
begin
  ost:=AddStack('TFileBufXml.WriteSimple');
  result:=true; v:=''; t:=MyVarType(Value,true); s:=Fmt;
  if (t=varDouble) and (s='') then s:='N';
  l:=LsArrDynamic(s,a,'|');
  if l>1 then begin
    ov:=State.Value; oErr:=OnFmtError;
    try
      s:=a[0];
      for l:=0 to l-1 do begin
        State.Value:=Value; fl:=true;
        try
          FmtCheck(a[l]);
        except
          on EFileBufXmlError do begin
            SetStack(ost); fl:=false;
          end;
        end;
        if fl then begin
          s:=a[l]; break;
        end;
      end;
    finally
      State.Value:=ov; OnFmtError:=oErr;
    end;
  end;
  FmtEncode(s,l,h);
  case t of
    varDouble: {if mround(Value,h)=0 then v:='0'
      else} v:=StrTran(Trim(SpaceStr0(Value,l,h)),DecimalSeparator,'.');
    {begin
      v:=Trim(SpaceStr0(Value,l,h));
      if h>0 then begin
        i:=Length(v);
        repeat
          fl := v[i]='0';
          if fl or (v[i]=DecimalSeparator) then Dec(i);
        until not fl;
        SetLength(v,i); StrTranSelf(v,DecimalSeparator,'.');
      end;
    end;}
    varDate: begin
      d:=GetDate(s,Value);
      if FmtDate='' then v:=dtoc(d,'.') else v:=OurFormatDateTime(FmtDate,d);
    end;
    varBoolean: if Value then v:=bTrue;
    varString: begin
      v:=Value;
      if not(xmlwNoTrimLeft in Opt) then TrimLeftSelf(v);
      if not(xmlwNoTrimRight in Opt) then TrimRightSelf(v);
      //if Length(v)<l then PadRSelf(v,l,'-');
      StrTranSelf(v,['"',CRLF,'&'],['''''','^',scb+IntToHex(Ord('&'),2)+sce]);
      if Length(v)>h then begin
        SetLength(v,h); TrimSelf(v);
      end;
    end;
  end;
  fl := (xmlwBound in Opt) or not empty(Value) or not((xmlwAtr in Opt) or (sAtr='') or AtrNoBound);
  if not fl and (xmlwNillable in Opt) and empty(Value) and not(xmlwAtr in Opt) then begin
    if AtrNoBound then sAtr:=AtrNil else IncD(sAtr,AtrNil);
    fl:=true; v:='';
  end;
  if fl then begin
    s:=Trim(Name);
    if xmlwAtr in Opt then IncD(sAtr,' '+s+'="'+v+'"')
    else begin
      result:=WriteStrPrior;
      if result then begin
        result:=FWriteStrBegCrlf(State.nLv);
        if result then result:=FWriteString(Space(State.nLv)+'<'+s+sAtr+IfThen(v='','/>','>'+v+'</'+s+'>'));
      end;
    end;
  end;
  if not(xmlwAtr in Opt) then sAtr:='';
  DelStack;
end;

function TFileBufXml.WriteSimpleDef;
begin
  AddStack('TFileBufXml.WriteSimpleDef');
  if Value=Def then result:=true else result:=WriteSimple(Name,Value,Fmt,Opt+[xmlwBound]);
  DelStack;
end;

function TFileBufXml.ReadRekv;
  function NextNoSpace(lNext: boolean = false): Char;
  begin
    AddStack('TFileBufXml.ReadRekv.NextNoSpace');
    if lNext then lNext:=not ReadChar(State.cRead);
    if not lNext and (State.cRead<=' ') then
      repeat
        if State.cRead=#13 then Inc(State.nLine);
      until not ReadChar(State.cRead) or (State.cRead>' ');
    result:=State.cRead;
    DelStack;
  end;
var l: longint;
  procedure StrAdd(var s: string);
  begin
    if Length(s)=l then SetLength(s,l shl 1);
    Inc(l); s[l]:=State.cRead;
  end;
  procedure StrInit(var s: string; lAdd: boolean = false);
  begin
    SetLength(s,100); l:=0;
    if lAdd then StrAdd(s);
  end;
  procedure StrSet(var s: string);
  const lb=Length(scb); le=Length(sce)-1;
  var b,bn,e: longint;
    i: Int64;
  begin
    AddStack('TFileBufXml.ReadRekv.StrSet');
    SetLength(s,l);
    if FUTF8 then Utf8ToWinSelf(s);
    StrTranSelf(s
      ,['&quot;',scb+'2018'+sce,scb+'2019'+sce,scb+'201D'+sce,scb+'201D'+sce,scb+'2026'+sce,scb+'2116'+sce]
      ,['"'     ,'‘'           ,'’'           ,'“'           ,'”'           ,'…'           ,'№'           ]);
    while IsPos(b,scb,s) and IsPos(e,sce,s) do begin
      bn:=b+lb; i:=HexToInt(Copy(s,bn,e-bn));
      if i>MaxByte then Dec(i,$410-Ord('А'));
      s[b]:=Chr(i);
      Delete(s,b+1,e+le-b);
    end;
    DelStack;
  end;
var v: string;
  h: longint;
  lFirst,fl,EndAtr: boolean;
begin
  AddStack('TFileBufXml.ReadRekv');
  result:=false; State.aAtr:=nil;
  lFirst := FUTF8 and (Position=0); fl := NextNoSpace='<';
  if not fl then if lFirst then begin
    fl:=true;
    for h:=1 to Length(Utf8First) do begin
      if State.cRead<>Utf8First[h] then begin
        fl:=false; break;
      end;
      if not ReadChar(State.cRead) then begin
        fl:=false; break;
      end;
    end;
    if fl then fl := State.cRead='<';
  end;
  if fl then begin
    State.Struct:=true; StrInit(State.Name);
    while ReadChar(State.cRead) do
      if (State.cRead<=' ') or (State.cRead='>') then break else StrAdd(State.Name);
    if l>1 then
      if State.Name[l]='/' then begin
        State.Struct:=false; Dec(l);
      end;
    if l=0 then raise EFileBufXmlError.Create('Обнаружен реквизит с пустым наименованием.');
    StrSet(State.Name);
    for h:=low(aPrefIgnore) to high(aPrefIgnore) do if AnsiStartsStr(aPrefIgnore[h]+':',State.Name) then begin
      Delete(State.Name,1,Length(aPrefIgnore[h])+1); break;
    end;
    SetLength(State.aAtr,10); h:=0;
    while not Eof and (NextNoSpace<>'>') do begin
      if Length(State.aAtr)=h then SetLength(State.aAtr,h shl 1);
      StrInit(State.aAtr[h,1],true);
      while ReadChar(State.cRead) do
        if (State.cRead<=' ') or (State.cRead='>') or (State.cRead='=') then break
        else StrAdd(State.aAtr[h,1]);
      if l=0 then raise EFileBufXmlError.Create(
        'Обнаружен атрибут реквизита <'+State.Name+'> с пустым наименованием.');
      StrSet(State.aAtr[h,1]); State.aAtr[h,2]:='';
      if NextNoSpace='=' then
        if NextNoSpace(true) in qAtr then begin
          StrInit(State.aAtr[h,2]);
          while ReadChar(State.cRead) do
            if State.cRead in qAtr then break else StrAdd(State.aAtr[h,2]);
          if State.cRead in qAtr then ReadChar(State.cRead) else l:=0;
          StrSet(State.aAtr[h,2]);
        end;
      Inc(h);
    end;
    EndAtr:=false;
    if h>0 then if State.aAtr[h-1,1]='/' then begin
      EndAtr:=true; Dec(h); State.Struct:=false;
    end;
    SetLength(State.aAtr,h); result := State.cRead='>';
    if result then begin
      if State.lIncLv and (not EndAtr or EndAtrIgnore) then begin
        State.lIncLv:=false; Inc(State.nLv);
      end;
      if State.Struct then begin
        StrInit(v);
        while ReadChar(State.cRead) do
          if State.cRead='<' then break else begin
            if State.cRead=#13 then Inc(State.nLine);
            StrAdd(v);
          end;
        StrSet(v); State.Struct := Eof or (State.cRead='<');
        if not Eof and (State.cRead='<') and (State.Name[1]<>'/') then
          if ReadChar(State.cRead) then
            if State.cRead='/' then begin
              State.Struct:=false;
              while ReadChar(State.cRead) do
                if State.cRead='>' then begin
                  NextNoSpace(true); break;
                end;
            end
            else begin
              IncPosition(-1); State.cRead:='<';
            end;
        if State.Struct then
          if State.Name[1]='/' then Dec(State.nLv) else State.lIncLv:=true;
      end
      else begin
        v:=''; NextNoSpace(true);
      end;
    end;
  end;
  if result then begin
    if State.Struct and (State.Name[1]<>'/') then begin
      if high(aLv)<State.nLv then SetLength(aLv,Length(aLv) shl 1);
      aLv[State.nLv].nm:=State.Name;
    end;
    IfThenNotify(OnReadRekv,Self); State.Value:=v;
    if Fmt<>'?' then FmtCheck(Fmt);
  end;
  DelStack;
end;

function TFileBufXml.ReadStruct;
var av: TArrVar;
  procedure Beg;
  var i: longint;
  begin
    AddStack('TFileBufXml.ReadStruct.Beg');
    Proc(xmlsBeg,ap,av);
    with State do begin
      Struct:=false;
      for i:=low(aAtr) to high(aAtr) do begin
        Name:=aAtr[i,1]; Value:=aAtr[i,2]; Proc(xmlsAtr,ap,av);
      end;
    end;
    DelStack;
  end;
var NoClos: boolean;
  lv,lb: longint;
  nm: string;
begin
  AddStack('TFileBufXml.ReadStruct');
  nm:=State.Name; result := (nm=nmRekv) or (nmRekv='');
  if result then begin
    SetLength(av,lav);
    if State.Struct then begin
      NoClos:=true; lv:=State.nLv; lb:=NegDef;
      repeat
        if Assigned(Proc) then case State.nLv-lv of
          0: if State.Name[1]='/' then Proc(xmlsEnd,ap,av) else if State.Struct then begin
            lb:=State.nLine; Beg;
          end;
          1: Proc(xmlsRekv,ap,av);
        end;
        if State.Struct and (State.Name[1]='/') and (State.nLv=lv) then begin
          NoClos:=false; break;
        end;
      until not ReadRekv('?');
      if NoClos
      then raise EFileBufXmlError.CreateFmt(
        'Для реквизита <%s> не обнаружен закрывающий реквизит </%s>'+IfThen(lb<>NegDef,' (строка %d)')+'.',[nm,nm,lb]);
    end
    else if Assigned(Proc) then begin
      Beg; Proc(xmlsEnd,ap,av);
    end;
  end;
  DelStack;
end;

function TFileBufXml.FmtCheck(const Fmt: string = ''; lTrimLeft: boolean = true): variant;
  procedure FmtRaise(usl: boolean);
  var msg: string;
  begin
    if usl then begin
      msg:='Значение реквизита <'+State.Name+'> не соответствует формату "'+Fmt+'".'
        +CRLF+'Значение: '+State.Value;
      if Assigned(OnFmtError) then OnFmtError(msg) else raise EFileBufXmlError.CreateHelp(msg,7000);
    end;
  end;
type TDatePart = (dtY,dtM,dtD);
const aFmt: array[TDatePart] of char = ('Y','M','D');
var t,l,h,lv: longint;
  dt: TDateTime;
  s: string;
  a: array[TDatePart] of string;
begin
  AddStack('TFileBufXml.FmtCheck');
  t:=FmtEncode(Fmt,l,h);
  if lTrimLeft or (t<>varString) then TrimSelf(State.Value) else TrimRightSelf(State.Value);
  case t of
    varDouble: begin
      lv:=Length(State.Value); FmtRaise(lv>l);
      if IsPos(t,'.',State.Value) then begin
        FmtRaise(lv-t>h); StuffStrSelf(State.Value,t,1,DecimalSeparator);
      end;
      Float0Self(State.Value);
    end;
    varDate: begin
      s:=State.Value;
      if FmtDate='' then dt:=ctod(StrTran(s,'.',DateSeparator))
      else begin
        InitArr(a);
        for l:=1 to min(Length(s),Length(FmtDate)) do
          if AnsiFindChar(AnsiUpCase(FmtDate[l]),aFmt,h) then IncD(a[TDatePart(h)],s[l]);
        if Length(a[dtY])=2 then IncL(a[dtY],'20');
        dt:=EncodeDateTry(Int0(a[dtY]),Int0(a[dtM]),Int0(a[dtD]));
      end;
      State.Value:=GetDate(Fmt,dt);
    end;
    varBoolean: State.Value := State.Value<>'';
    varString: begin
      StrTranSelf(State.Value,['^',''''''],[CRLF,'"']);
      FmtRaise(not InRange(Length(State.Value),l,h));
    end;
  end;
  result:=State.Value;
  DelStack;
end;

function TFileBufXml.FmtCheck(var Value: variant; const nmRekv: string;
  const Fmt: string = ''; lTrimLeft: boolean = true): boolean;
begin
  AddStack('TFileBufXml.FmtCheck(v)');
  result := State.Name=nmRekv;
  if result then Value:=FmtCheck(Fmt,lTrimLeft);
  DelStack;
end;

function TFileBufXml.FmtCheck(var Value: variant; i: longint; const nmRekv: string;
  const Fmt: string = ''; lTrimLeft: boolean = true): boolean;
begin
  AddStack('TFileBufXml.FmtCheck(a)');
  result := State.Name=nmRekv;
  if result then Value[i]:=FmtCheck(Fmt,lTrimLeft);
  DelStack;
end;

function TFileBufXml.FmtCheck(var Value: variant; i1,i2: longint; const nmRekv: string;
  const Fmt: string = ''; lTrimLeft: boolean = true): boolean;
var v1: variant;
begin
  AddStack('TFileBufXml.FmtCheck(a2)');
  result := State.Name=nmRekv;
  if result then begin
    v1:=Value[i1]; v1[i2]:=FmtCheck(Fmt,lTrimLeft); Value[i1]:=v1;
  end;
  DelStack;
end;

function TFileBufXml.FmtCheck(var Value: variant; i1,i2,i3: longint; const nmRekv: string;
  const Fmt: string = ''; lTrimLeft: boolean = true): boolean;
var v1,v2: variant;
begin
  AddStack('TFileBufXml.FmtCheck(a2)');
  result := State.Name=nmRekv;
  if result then begin
    v1:=Value[i1]; v2:=v1[i2]; v2[i3]:=FmtCheck(Fmt,lTrimLeft); v1[i2]:=v2; Value[i1]:=v1;
  end;
  DelStack;
end;

procedure TFileBufXml.PrRead;
begin
  AddStack('TFileBufXml.PrRead');
  case Oper of
    xmlsBeg: InterProcStat([ap[0],State.Name,'<',false]);
    xmlsEnd: InterProcStat([ap[0],State.Name,'>',false]);
  else       InterProcStat([ap[0],State.Name,State.Name,Oper=xmlsAtr]);
  end;
  DelStack;
end;

initialization
	AddStack('BufFile.initialization');
	with TInter do begin
    setvar('$buffile','ФАЙЛ_','Файлы');
    setvar('ФАЙЛ_НОМЕР','Номер текущего открытого файла',d_num,null,'I');
    setvar('ФАЙЛ_КОНЕЦ','Признак достижения конца текущего открытого файла',d_eof,null,'L',true);

    SetFunction('Файлы',1400);
    SetFunction('ФАЙЛ_ОТКРЫТЬ','Открыть файл для чтения/записи',
      ['Имя: строка','[Запись: логическое = '+vFalse+']','[Сообщ: логическое = '+vFalse+']',
      '[Формат: целое = 0]','[Парам: массив]','[АтрНеОбяз: логическое = '+vFalse+']'],
      ['C','LU','LU','NU','AU','LU'],c_open,null,1401,'I');
    SetFunction('ФАЙЛ_ЗАКРЫТЬ','Закрыть текущий открытый файл',
      ['[Номер: целое = ФАЙЛ_НОМЕР]','[Сообщ: логическое]'],['NU','LU'],c_close,null,1402,'L');
    SetFunction('ФАЙЛ_СЧИТАТЬ','Считать информацию из текущего открытого файла',
      ['[Длина: целое|логическое = '+vTrue+']~[Формат: строка = ""]~Парам: массив',
      '~[УбрЛевПробелы: логическое = '+vTrue+']'],['NLCAU','LU'],c_read,null,1403,'CNDL');
    SetFunction('ФАЙЛ_ВСТАТЬ','Встать на указанную позицию в текущем открытом файле для чтения',
      ['[Смещ: целое = 0]','[Относ: целое = 0]'],['NU','NU'],c_seek,null,1404,'I');
    SetFunction('ФАЙЛ_ЗАПИСАТЬ','Записать информацию в текущий открытый файл',
      ['Стр: строка~Наим: строка','[Перевод: логическое = '+vFalse+']~Знач: строка|число|дата|логическое|массив',
      '~[Формат: строка = ""]','~[Обязат: логическое|целое = 0]','~[ПоУмолч: строка|число|дата|логическое]',
      '~[Атрибут: логическое = '+vFalse+']','~[ПробСлева: логическое = '+vTrue+']','~[ПробСправа: логическое = '+vTrue+']'],
      ['C','','CU','LNU','CNDLU','LU','LU','LU'],c_write,null,1405,'L');
    SetFunction('КОП_ДИСК','Копирование файла',
      ['Куда: строка','[Откуда: строка = ""]','[Файл: строка|массив = ""]','[Очистить: логическое = '+vFalse+']',
      '[Проверить: логическое = '+vFalse+']'],
      ['C','CU','CAU','LU','LU'],c_diskwait,null,1406,'L');
    SetFunction('ТЕК_ПАПКА','Возвращает текущую папку',['[ДляПрил: логическое = '+vTrue+']'],
      ['LU'],c_curdir,null,1407,'C');
    SetFunction('ФАЙЛ_УДАЛИТЬ','Удалить файл',['Файл: строка'],['C'],c_del,null,1408,'L');
    SetFunction('ПАПКА_СОЗДАТЬ','Создать папку',['Папка: строка'],['C'],c_mdir,null,1409,'L');
    SetFunction('МАСК_ФАЙЛ','Список файлов и папок, удовлетворяющих маске',
      ['Маска: строка','[Файлы: логическое = '+vTrue+']','[Папки: логическое = '+vFalse+']','[Сорт: целое = 0]'],
      ['C','LU','LU','NU'],c_maskfile,null,1410,'A');
    SetFunction('ФАЙЛ_РЕДАКТ','Просмотр или редактирование файла',
      ['Файл: строка','[Кодировка: целое|логическое = 0]','[НеРед: логическое = '+vFalse+']','[Ошибка: строка]',
      '[Загл: строка]','[Перенос: логическое = '+vFalse+']'{,'[Формат: целое = 0]'}],
      ['C','NLU','LU','CU','CU','LU'{,'NU'}],c_edfile,null,1411,'L');
    SetFunction('ФАЙЛ_ИМЯ','Возвращает путь, имя, расширение и диск файла из полного имени файла',
      ['Файл: строка','[Часть: целое]'],['C','NU'],c_extr,null,1412,'AC');
    SetFunction('ФАЙЛ_РАЗМЕР','Возвращает размер файла',['[Файл: строка]'],['CU'],c_size,null,1413,'I');
    SetFunction('ФАЙЛ_НАЙТИ','Найти файл или папку с файлами последней версии',
      ['Файл: строка','[Папки: строка|массив = ""]'],['C','CAU'],c_searchpath,null,1414,'C');
    SetFunction('ФАЙЛ_ПРОТОКОЛ','Добавить строку в файл протокола',
      [Format('[Файл: целое|строка = %d]',[byte(protDebug)]),'Стр: строка'],['CIU','C'],c_protstradd,null,1415);
    SetFunction('ФАЙЛ_ПЕРЕИМЕН','Переименовать файл',
      ['Откуда: строка','Куда: строка'],['C','C'],c_rename,null,1416,'L');
    SetFunction('ФАЙЛ_ДАТА','Возвращает дату и время файла',['[Файл: строка]'],['CU'],
      c_date,null,1417,'I');
  end;
  DelStack;
end.

