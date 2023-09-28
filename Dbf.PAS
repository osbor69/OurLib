unit DBF;

interface

{$I LIBTEST}
uses SysUtils,Classes,DB,
  MyTypes,My_pr,BufFile;

type
  TDbfFieldType = (dftString,dftInteger,dftFloat,dftDate,dftBoolean);

  PDbfFieldInf = ^TDbfFieldInf;
	TDbfFieldInf = record
  	FieldType: TDbfFieldType;
    Len: Word;
    Dec: Byte;
    Value: variant;
	end;

  PDbfInfCreate = ^TDbfInfCreate;
  TDbfInfCreate = array of record
    Name: string;
  	FieldType: TDbfFieldType;
    Len: Word;
    Dec: Byte;
  end;

  TDbfOption = (dbfNoReadOnly,dbfDateEmptyAsNull,dbfValEmptyFill); TDbfOptions = set of TDbfOption;

  PDbf = ^TDbf;
  TDBF = class(TCustomDataFile)
  private
    { Private declarations }
    f: TFileBufStream;
    lsFld: TStringList;
    aFld: array of TDbfFieldInf;
    anFld: TArrInt;
    FPosBeg,LenRec,FFRecNo {Конфликтует с fRECNO}: Int64;
    FRecordCount: longint;
    Deleted,FRecModified,FDosToWin: boolean;
		function GetFields(const vIndex: variant): variant;
		procedure SetFields(const vIndex: variant; const cv: variant);
		procedure SetRecno(Value: Int64);
    procedure SetDosToWin(Value: boolean);
		function ConvIndex(const vIndex: variant; var Index: longint): boolean;
		function FDeleted: boolean;
    procedure GetRec;
    procedure SetRec;
    procedure WriteBuffer(const Buffer; Count: Longint);
    function GetFieldInf(i: longint): PDbfFieldInf;
  protected
    { Protected declarations }
  public
    { Public declarations }
    VisibleDeleted: boolean;
    FileName: TFileName;
    CodePage: variant;
    Options: TDbfOptions;
    property lDosToWin: boolean read FDosToWin write SetDosToWin;
    property Fields[const Index: variant]: variant read GetFields write SetFields; default;
    property PosBeg: Int64 read FPosBeg;
    property Recno: Int64 read FFRecNo write SetRecno;
    property RecModified: boolean read FRecModified;
  	constructor CreatePrm(const AFileName: TFileName; AOptions: TDbfOptions = []; pInfCreate: PDbfInfCreate = nil);
  	destructor Destroy; override;
		function FieldCount: longint; override;
		function FieldName(Index: longint): string; override;
    function FieldPos(const nmFld: string): longint;
		function FieldLen(Index: longint): Word; override;
		function FieldDec(Index: longint): Byte; override;
		function FieldType(const vIndex: variant): TDbfFieldType;
		function FieldIndex(const vIndex: variant): longint;
    function Active: boolean;
    procedure Close; override;
		function RecordCount: longint; override;
    procedure First; override;
    procedure Last; override;
    procedure Next; override;
    procedure Prior;
    function MoveBy(Distance: longint): longint; //override;
    function Eof: boolean; override;
    function Bof: boolean;
    procedure Append;
    procedure Delete;
    procedure DeleteAll;
		function NumFromName(const nmf: string; var i: longint): boolean; override;
    function ValueNum(Index: longint): variant; override;
    function ValueName(const Name: string): variant; override;
    function IsField(const FieldName: string): boolean; override;
		function DataType(Index: longint): TFieldType; override;
    function NotNull(Index: longint; p: pointer): boolean; override;
  end;

const aDbfToFt: array[TDbfFieldType] of TFieldType = (ftString,ftInteger,ftFloat,ftDate,ftBoolean);

function IfThen(AValue: boolean; ATrue: TDbfOption): TDbfOptions; overload;

implementation

uses Windows,Math,Variants,
  ER866;

const cEOF: char = #$1A;

function IfThen(AValue: boolean; ATrue: TDbfOption): TDbfOptions;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

{ TDbf }
constructor TDbf.CreatePrm;
  function Err(uslErr: boolean): boolean;
  begin
    AddStack('TDbf.CreatePrm.Err',Self);
    result:=uslErr;
    if result then FreeAndNil(f);
    DelStack;
  end;
  function SeekErr(const Offset: Int64; Origin: longint = soFromBeginning): boolean;
  begin
    AddStack('TDbf.CreatePrm.SeekErr',Self);
    result:=Err(longword(f.Seek(Offset,Origin))=INVALID_HANDLE_VALUE);
    DelStack;
  end;
  function ReadErr(var Buffer; Count: Longint = 1): boolean;
  begin
    AddStack('TDbf.CreatePrm.ReadErr',Self);
    result:=Err(f.Read(Buffer,Count)<>Count);
    DelStack;
  end;
var s: string;
  procedure Wr0(l: byte);
  begin
    AddStack('TDbf.CreatePrm.Wr0',Self);
    ZeroMemory(pointer(s),l); WriteBuffer(pointer(s)^,l);
    DelStack;
  end;
const a: array[TDbfFieldType] of char = ('C','N','N','D','L');
  l0=22;
var c,c1: char;
  p: PDbfFieldInf;
  offs,ost,i,j: longint;
  sz1,sz2: Int64;
  y,m,d: Word;
label lend;
begin
	ost:=AddStack('TDbf.CreatePrm',Self);
  inherited Create(nil);
	lsFld:=SortStrListCreate; FDosToWin:=true; FileName:=FullNameExe(AFileName,'DBF'); CodePage:=null;
  Options:=AOptions+IfThen(Assigned(pInfCreate),dbfNoReadOnly);
  try
  	f:=TFileBufStream.Create(FileName,IfThen(Assigned(pInfCreate),fmCreate,
      IfThen(dbfNoReadOnly in Options,fmOpenReadWrite,fmOpenRead) or fmShareDenyNone));
  except
    on EFileStreamError do begin
      SetStack(ost);
      f:=nil;
    end;
  end;
  LenRec:=1; FPosBeg:=0;
  if Active then begin
    if Assigned(pInfCreate) then
      try
        c:=#$03; WriteBuffer(c,1);
        DecodeDate(Date,y,m,d); ModD(y,100); WriteBuffer(y,1); WriteBuffer(m,1); WriteBuffer(d,1);
        i:=0; WriteBuffer(i,4);
        i:=32*(Length(pInfCreate^)+1)+1; WriteBuffer(i,2); offs:=f.Position; j:=1;
        SetLength(s,l0); Wr0(l0);
        for i:=low(pInfCreate^) to high(pInfCreate^) do with pInfCreate^[i] do begin
          AnsiUpperCaseSelf(Name); CopyMemory(pointer(s),pointer(Name),Length(Name));
          WriteBuffer(pointer(s)^,11);
          WriteBuffer(a[FieldType],1);
          case FieldType of
            dftString,dftInteger,dftFloat: MaxSelf(Len,1);
            dftDate: Len:=8;
            dftBoolean: Len:=1;
          end;
          if FieldType=dftFloat then EnsureSelf(Dec,0,Len-2) else Dec:=0;
          Wr0(4);
          if FieldType=dftFloat then begin
            WriteBuffer(Len,1); WriteBuffer(Dec,1);
          end
          else WriteBuffer(Len,2);
          Wr0(14); Inc(j,Len);
        end;
        c:=#$0D; WriteBuffer(c,1);
        WriteBuffer(cEof,1);
        f.Position:=offs; WriteBuffer(j,2);
      except
        on EWriteError do begin
          SetStack(ost);
          FreeAndNil(f); DelFileAtr(FileName);
        end;
      end;
    if Active then begin
      {if ReadErr(c) then goto lend;
      if Err(not(Ord(c) in [$03,$04,$05,$43,$B3,$83,$8B,$8E,$F5])) then goto lend;}
      f.Position:=4;
      if ReadErr(FRecordCount,4) then goto lend;
      if ReadErr(FPosBeg,2) then goto lend;
      // Структура
      SetLength(aFld,10); offs:=$20; i:=0;
      while true do begin
        // Имя
        if SeekErr(offs) then goto lend;
        s:='';
        repeat
          if ReadErr(c) then goto lend;
          if c in [#0,#$0D] then break;
          IncD(s,c);
        until false;
        if s='' then break;
        if IgnoreSlFindAdd(lsFld,s,j) then raise EReadDBFError.Create(
          'Обнаружены совпадающие поля с наименованием '+s+CRLF+'Файл: '+FileName);
        if Length(aFld)=i then SetLength(aFld,i shl 1);
        lsFld.Objects[j]:=pointer(i); p:=@aFld[i]; Inc(i); p.FieldType:=low(a); p.Len:=0; p.Dec:=0; 
        // Тип
        if SeekErr(offs+11) then goto lend;
        if ReadErr(c) then goto lend;
        while p.FieldType<=high(a) do
          if a[p.FieldType]=c then break else Inc(p.FieldType);
        // Длина
        if SeekErr(offs+16) then goto lend;
        if ReadErr(c) then goto lend;
        if ReadErr(c1) then goto lend;
        if p.FieldType=dftString then p.Len:=MakeWord(Ord(c),Ord(c1))
        else begin
          p.Len:=Ord(c); p.Dec:=Ord(c1);
          if p.FieldType in [dftInteger,dftFloat]
          then p.FieldType:=iif(p.Dec=0,dftInteger,dftFloat);
        end;
        Inc(LenRec,p.Len); Inc(offs,$20);
      end;
      SetLength(aFld,i); SetLength(anFld,i);
      for i:=0 to i-1 do anFld[IntObj(lsFld,i)]:=i;
      //FPosBeg:=offs+1;
      if SeekErr(FPosBeg) then goto lend;
      if ReadErr(c) then goto lend;
      if c=#0 then Inc(FPosBeg);
      sz1:=f.Size-FPosBeg; sz2:=FRecordCount*LenRec;
      if sz1<>sz2 then begin
        Dec(sz1);
        if Err(sz1<>sz2) then goto lend;
        if SeekErr(-1,soFromEnd) then goto lend;
        if ReadErr(c) then goto lend;
        if Err(c<>cEof) then goto lend;
      end;
      First;
    end;
  end;
  if not Active then FFRecNo:=1;
lend:
  DelStack;
end;

destructor TDbf.Destroy;
begin
	AddStack('TDbf.Destroy',Self);
  Close; lsFld.Free;
  inherited Destroy;
  DelStack;
end;

procedure TDbf.Close;
var i: longint;
begin
  AddStack('TDbf.Close',Self);
  if Active then begin
    if dbfNoReadOnly in Options then begin
      SetRec; f.Position:=4; WriteBuffer(FRecordCount,4);
      i:=MyVarType(CodePage);
      if i<>varNull then begin
        if i=varBoolean then i:=IfThen(CodePage,$65,$C9) else i:=CodePage;
        f.Position:=29; WriteBuffer(i,1);
      end;
    end;
    f.Update(true); FreeAndNil(f);
  end;
  DelStack;
end;

function TDbf.FDeleted;
begin
  AddStack('TDbf.FDeleted',Self);
  result := Deleted and not VisibleDeleted;
  DelStack;
end;

function TDbf.Active;
begin
  AddStack('TDbf.Active',Self);
  if Assigned(Self) then result:=Assigned(f) else result:=false;
  DelStack;
end;

function TDbf.NumFromName;
begin
  {$IFDEF STACKALL}AddStack('TDbf.NumFromName',Self);{$ENDIF}
  result:=lsFld.Find(nmf,i);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDbf.ValueNum;
begin
  {$IFDEF STACKALL}AddStack('TDbf.ValueNum',Self);{$ENDIF}
  result:=GetFieldInf(Index).Value;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDbf.ValueName;
begin
  {$IFDEF STACKALL}AddStack('TDbf.ValueName',Self);{$ENDIF}
  result:=GetFieldInf(lsFld.IndexOf(Name)).Value;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDbf.IsField;
begin
  {$IFDEF STACKALL}AddStack('TDbf.IsField',Self);{$ENDIF}
  result := lsFld.IndexOf(FieldName)>=0;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDbf.DataType;
begin
  {$IFDEF STACKALL}AddStack('TDbf.DataType',Self);{$ENDIF}
  result:=aDbfToFt[GetFieldInf(Index).FieldType];
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDbf.NotNull;
begin
  result:=false;
end;

function TDbf.GetFields;
var Index: longint;
begin
	{$IFDEF STACKALL}AddStack('TDbf.GetFields',Self);{$ENDIF}
  if ConvIndex(vIndex,Index) then result:=GetFieldInf(Index).Value else result:='';
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TDbf.SetFields;
var Index: longint;
  v: variant;
begin
  {$IFDEF STACKALL}AddStack('TDbf.SetFields',Self);{$ENDIF}
  if not(dbfNoReadOnly in Options) then raise EReadDBFError.Create(
    'Ошибка присвоения значения в базе данных:'+CRLF+FileName+CRLF+'база открыта только для чтения');
  if ConvIndex(vIndex,Index) then with GetFieldInf(Index)^ do begin
    if FieldType=dftString then v:=Padr(cv,Len) else v:=cv;
    if not CompVar(Value,v) then begin
      Value:=v; FRecModified:=true;
    end;
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDbf.FieldCount;
begin
	{$IFDEF STACKALL}AddStack('TDbf.FieldCount',Self);{$ENDIF}
	result:=lsFld.Count;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDbf.FieldName;
begin
	{$IFDEF STACKALL}AddStack('TDbf.FieldName',Self);{$ENDIF}
	result:=lsFld[Index];
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDbf.FieldPos;
begin
  {$IFDEF STACKALL}AddStack('TDbf.FieldPos',Self);{$ENDIF}
	result:=lsFld.IndexOf(nmFld);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDbf.FieldLen;
begin
	{$IFDEF STACKALL}AddStack('TDbf.FieldLen',Self);{$ENDIF}
	result:=GetFieldInf(Index).Len;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDbf.FieldDec;
begin
	{$IFDEF STACKALL}AddStack('TDbf.FieldDec',Self);{$ENDIF}
	result:=GetFieldInf(Index).Dec;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDbf.FieldType;
var Index: longint;
begin
	{$IFDEF STACKALL}AddStack('TDbf.FieldType',Self);{$ENDIF}
	if ConvIndex(vIndex,Index) then result:=GetFieldInf(Index).FieldType else result:=dftString;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDbf.FieldIndex;
var Index: longint;
begin
	{$IFDEF STACKALL}AddStack('TDbf.FieldIndex',Self);{$ENDIF}
	if ConvIndex(vIndex,Index) then result:=IntObj(lsFld,Index) else result:=-1;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDbf.ConvIndex;
begin
	{$IFDEF STACKALL}AddStack('TDbf.ConvIndex',Self);{$ENDIF}
  if MyVarType(vIndex)=varString then Index:=lsFld.IndexOf(vIndex) else Index:=vIndex;
  result:=InRange(Index,0,lsFld.Count-1);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TDbf.SetRecno;
begin
	AddStack('TDbf.SetRecno',Self);
	Value:=max(1,Value);
  if FFRecNo<>Value then begin
  	SetRec; FFRecNo:=Value; f.Position:=FPosBeg+(Value-1)*LenRec; GetRec;
  end;
  DelStack;
end;

procedure TDbf.SetDosToWin;
begin
  AddStack('TDbf.SetDosToWin',Self);
  if FDosToWin<>Value then begin
    FDosToWin:=Value; f.IncPosition(-LenRec); GetRec;
  end;
  DelStack;
end;

function TDbf.RecordCount;
begin
  result:=FRecordCount;
end;

procedure TDbf.First;
begin
  AddStack('TDbf.First',Self);
  SetRec; FFRecNo:=0; f.Position:=FPosBeg; Next;
  DelStack;
end;

procedure TDbf.Last;
begin
  AddStack('TDbf.Last',Self);
  SetRec; FFRecNo:=FRecordCount+1; f.Seek(0,soFromEnd); Prior;
  DelStack;
end;

procedure TDbf.Next;
begin
  {$IFDEF STACKALL}AddStack('TDbf.Next',Self);{$ENDIF}
  if not Eof then begin
    SetRec;
    repeat
      Inc(FFRecNo);
      if Eof then break;
      GetRec;
    until not FDeleted;
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

procedure TDbf.Prior;
var lr,lr2: Int64;
begin
  AddStack('TDbf.Prior',Self);
  if not Bof then begin
    SetRec; lr2:=-(LenRec shl 1); lr:=IfThen(Eof,-LenRec,lr2);
    repeat
      Dec(FFRecNo);
      if Bof then begin
        f.IncPosition(-LenRec); break;
      end;
      f.IncPosition(lr); GetRec; lr:=lr2;
    until not FDeleted;
  end;
  DelStack;
end;

function TDbf.MoveBy;
begin
  AddStack('TDbf.MoveBy',Self);
  result:=FFRecno; Recno:=EnsureRange(FFRecno+Distance,1,RecordCount); result:=Recno-result;
  DelStack;
end;

procedure TDbf.GetRec;
var i: longint;
  s: string;
  c: char;
begin
  AddStack('TDbf.GetRec',Self);
  f.Read(c,1); Deleted:=c<>' ';
  for i:=low(anFld) to high(anFld) do with GetFieldInf(anFld[i])^ do begin
    SetLength(s,Len); f.Read(pointer(s)^,Len);
    if (dbfValEmptyFill in Options) and empty(s) and (FieldType<>dftString)
    then Value:=null
    else case FieldType of
      dftInteger: Value:=Int064(s);
      dftFloat: Value:=Float0(s);
      dftDate: begin
        Value:=stod(s);
        if (dbfDateEmptyAsNull in Options) and empty(Value) then Value:=null;
      end;
      dftBoolean: Value:=StrToBoolean(s);
    else if FDosToWin then Value:=DosToWin(s) else Value:=s;
    end;
  end;
  DelStack;
end;

procedure TDbf.SetRec;
var i: longint;
  s: string;
  c: char;
begin
  {$IFDEF STACKALL}AddStack('TDbf.SetRec',Self);{$ENDIF}
  if FRecModified then begin
    f.IncPosition(-LenRec);
    c:=IfThenChar(Deleted,'*');
    WriteBuffer(c,1);
    for i:=low(anFld) to high(anFld) do with GetFieldInf(anFld[i])^ do begin
      if not(dbfValEmptyFill in Options) and empty(Value) or IsNil(Value)
      then s:=Space(Len)
      else case FieldType of
        dftInteger,dftFloat: s:=StrTran(SpaceStr0(Value,Len,Dec),DecimalSeparator,'.');
        dftDate: s:=dtos(Value);
        dftBoolean: s:=Bool2Str(Value);
      else s:=Value;
      end;
      if FDosToWin then WinToDosSelf(s);
      WriteBuffer(pointer(s)^,Len);
    end;
    f.IncPosition(0); FRecModified:=false;
  end;
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDbf.Eof;
begin
  {$IFDEF STACKALL}AddStack('TDbf.Eof',Self);{$ENDIF}
  result := FFRecNo>Int64(FRecordCount);
  {$IFDEF STACKALL}DelStack;{$ENDIF}
end;

function TDbf.Bof;
begin
  AddStack('TDbf.Bof',Self);
  result := FFRecNo<=0;
  DelStack;
end;

procedure TDbf.Append;
var s: string;
begin
  AddStack('TDbf.Append',Self);
  if not(dbfNoReadOnly in Options) then raise EReadDBFError.Create(
    'Ошибка добавления записи в базу данных:'+CRLF+FileName+CRLF+'база открыта только для чтения');
  SetRec; Inc(FRecordCount); FFRecNo:=FRecordCount; Deleted:=false; f.Seek(-1,soFromEnd);
  s:=Space(LenRec); WriteBuffer(pointer(s)^,LenRec);
  WriteBuffer(cEof,1);
  f.Seek(-LenRec-1,soFromEnd); GetRec;
  DelStack;
end;

procedure TDbf.Delete;
begin
  AddStack('TDbf.Delete',Self);
  if not(dbfNoReadOnly in Options) then raise EReadDBFError.Create(
    'Ошибка удаления записи в базе данных:'+CRLF+FileName+CRLF+'база открыта только для чтения');
  if not Deleted then begin
    Deleted:=true; FRecModified:=true; SetRec;
  end;
  DelStack;
end;

procedure TDbf.DeleteAll;
begin
  AddStack('TDbf.DeleteAll',Self);
  if FRecordCount>0 then begin
    if not(dbfNoReadOnly in Options) then raise EReadDBFError.Create(
      'Ошибка удаления записей в базе данных:'+CRLF+FileName+CRLF+'база открыта только для чтения');
    FFRecNo:=0; FRecordCount:=0; f.Position:=FPosBeg; f.Size:=FPosBeg; WriteBuffer(cEof,1);
    FRecModified:=false;
  end;
  DelStack;
end;

procedure TDbf.WriteBuffer;
begin
  AddStack('TDbf.WriteBuffer',Self);
  try
    f.WriteBuffer(Buffer,Count);
  except
    on EWriteError do raise EReadDBFError.Create(
      'Ошибка записи в базу данных:'+CRLF+FileName+CRLF+'Возможно, недостаточно свободного места на диске.');
  end;
  DelStack;
end;

function TDbf.GetFieldInf;
begin
  AddStack('TDbf.GetFieldInf',Self);
  result:=@aFld[IntObj(lsFld,i)];
  DelStack;
end;

end.
