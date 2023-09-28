unit HtmlFile;

interface

{$I LIBTEST}
{ $DEFINE XLSINDEX}
{ $DEFINE XLSEXTSST}

uses Classes,SysUtils,Graphics,Printers,
  MyTypes,My_pr,BufFile;

const
  XlsColorCount = $10;
  XlsRowsInBlock = 32;

  cXlsCRLF = #10;

type
	TFormatFileOption = (ffoSP,ffoCR,ffoCREnd,ffoNoq); TFormatFileOptions = set of TFormatFileOption;

	TCustomFormatFile = class(TFileBufStream)
  private
    sSp: string;
    class function BeforeWrite(var s: string; var opt: TFormatFileOptions): char; virtual; abstract;
  public
  	constructor Create(const FileName: TFileName); virtual;
		procedure WriteFile(const st: string; opt: TFormatFileOptions = []); overload;
    procedure WriteFile(const Args: array of const; const Format: string;
      opt: TFormatFileOptions = []); overload;
  end;

	THtmlFile = class(TCustomFormatFile)
  private
    class function BeforeWrite(var s: string; var opt: TFormatFileOptions): char; override;
  public
  	constructor Create(const FileName: TFileName); override;
    destructor Destroy; override;
		procedure WriteBody(bgColor: TColor = clNone);
  end;

	TRtfFile = class(TCustomFormatFile)
  private
    class function BeforeWrite(var s: string; var opt: TFormatFileOptions): char; override;
  public
  	constructor Create(const FileName: TFileName); override;
    destructor Destroy; override;
  end;

  TXlsColors = array[0..XlsColorCount-1] of TColor;

  TXlsFile = class;

  TXlsCells = class(TObject)
  private
    FOffset: byte;
    FOwner: TXlsFile;
    FProc: procedure(Index,Value: Word) of object;
    FValues: array of record
      w: Word;
      p: Int64;
    end;
    Modified: boolean;
    function GetCount: Word;
    procedure SetCount(Value: Word);
    function GetValues(Index: Word): Word;
    procedure SetValues(Index,Value: Word);
    procedure OffsetPositions;
    procedure WriteChanges;
    procedure IncValue(Index1,Index2,Value: Word);
    property Count: Word read GetCount write SetCount;
  public
  	constructor Create(Owner: TXlsFile; Offset: byte);
    property Values[Index: Word]: Word read GetValues write SetValues; default;
  end;

  TXlsOption = (xlsProtect,xlsTrnsNum,xlsTrnsDate); TXlsOptions = set of TXlsOption;

	TXlsFile = class(TCustomFormatFile)
  private
    lsFormat: TStringList;
    lsXF,lsSST: TStringListCase;
    lsBlank: TIntegerList;
    cntSST: longword;
    pCntSAT,pSidMSAT,pGlobals{$IFDEF XLSINDEX},pRow,pRow1,pDbCell{$ENDIF}: Int64;
{$IFDEF XLSINDEX}
    apRow: array[1..XlsRowsInBlock] of Word;
    CntRow: byte;
{$ENDIF}
    ssGlobals: TStringStream;
    anFont: TArrFont;
    anColor: TXlsColors;
    aSheet: array of record
      nm: string;
      p: Int64;
    end;
    nSheet,nMerge,oRow: longint;
    lsBlankWriting: boolean;
    RKCrd: record
      Row,Col,Count: longint;
    end;
    aRK: array of record
      XF: Word;
      RK: longword;
    end;
    aMerge: array of array[1..4] of Word;
    procedure WriteHex(const a: array of byte);
    procedure WriteFF;
    procedure WriteBlank(ARow,ACol: Word);
    procedure WriteRK;
    procedure WriteCol(Index,Value: Word);
{$IFDEF XLSINDEX}
    procedure DbCell;
{$ENDIF}
    procedure aWrite(ID: Word; const a: array of variant; const at: array of TSaveType;
      CntByte: TUnicodeSize = 2; CntPack: TUnicodeSize = 1{$IFDEF XLSEXTSST}; paEXTSST: PArrVar = nil{$ENDIF});
    procedure aWriteCell(ID: Word; const a: array of variant; const at: array of TSaveType);
    procedure NewRow(ARow,ACol: Word);
    class function BeforeWrite(var s: string; var opt: TFormatFileOptions): char; override;
  public
    Canvas: TCanvas;
    ProcentCol: Double;
    ColWidths,RowHeights: TXlsCells;
    Options: TXlsOptions;
  	constructor Create(const FileName: TFileName); override;
    destructor Destroy; override;
    procedure SetGlobals(CountSheet: longint; const aFont: array of TFont;
      const aColor: array of TColor; SizeFontHead: longint = 0);
    procedure BeginSheet(const Name: string; ColCount,RowCount,Format: Word;
      w,h,t,b,l,r: longint; orient: TPrinterOrientation);
    procedure EndSheet;
    procedure WriteCell(Row1,Row2,Col1,Col2: Word; const Value: variant; const ValueAsStr: string;
      nFont,nColor: byte; const Format: string; algmHorz: TAlignment;
      algmVert: TAlignment = taRightJustify; Angle: Word = 0; AdjustWH: boolean = true;
      wTop   : TLineNulWidth = 1; nclTop   : byte = 0;
      wLeft  : TLineNulWidth = 1; nclLeft  : byte = 0;
      wBottom: TLineNulWidth = 1; nclBottom: byte = 0;
      wRight : TLineNulWidth = 1; nclRight : byte = 0);
    class procedure aColorSet(const Source: array of TColor; var Dest: TXlsColors);
  end;

function ColorHex(cl: TColor): string;
function IfThen(AValue: boolean; ATrue: TFormatFileOption): TFormatFileOptions; overload;

implementation

uses Windows,StrUtils,Math,Forms,
  Shifr;

type TArrSaveType = array of TSaveType;

function ColorHex;
{const a: array[T16Colors] of string =
  ('Black','Maroon','Green','Olive','Navy','Purple','Teal','Gray',
  'Silver','Red','Lime','Yellow','Blue','Fuchsia','Aqua','White',
  'ScrollBar','Background','ActiveCaption',
  'InactiveCaption','Menu','Window','WindowFrame','MenuText','WindowText',
  'CaptionText','ActiveBorder','InactiveBorder',
  'AppWorkSpace','Highlight','HighlightText','ButtonFace',
  'ButtonShadow','GrayText','ButtonText','InactiveCaptionText',
  'ButtonHighlight','');}
var i: longint;
begin
  AddStack('FMsOffEd.ColorHex');
  //result:='"'+IntToHex(ColorRGB(cl,false),6)+'"';
  {result:='';
  for i:=low(AColor) to high(AColor) do
  	if AColor[i]=cl then begin
    	result:=a[i]; break;
    end;
  if result='' then begin
	  i:=ColorToRGB(cl); result:=IntToHex(Windows.RGB(GetBValue(i),GetGValue(i),GetRValue(i)),6);
  end;
  IncL(result,'"','"');}
  i:=ColorToRGB(cl);
  result:='#'+IntToHex(Windows.RGB(GetBValue(i),GetGValue(i),GetRValue(i)),6);
  DelStack;
end;

function IfThen(AValue: boolean; ATrue: TFormatFileOption): TFormatFileOptions;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

{ TCustomFormatFile }
constructor TCustomFormatFile.Create;
begin
	AddStack('TCustomFormatFile.Create');
  inherited Create(FileName,fmCreate);
  DelStack;
end;

procedure TCustomFormatFile.WriteFile(const st: string; opt: TFormatFileOptions = []);
var s1,s: string;
  c: char;
begin
  AddStack('TCustomFormatFile.WriteFile');
  s:=Trim(st); s1:=s; c:=BeforeWrite(s,opt);
  if (s1<>'') and (c<>#0) then
    if s1[1]=c then begin
      DecLen(sSp); Include(opt,ffoCR);
    end;
  if ffoSP in opt then Include(opt,ffoCR);
  if ffoCR in opt then IncL(s,IfThen(Position>0,CRLF)+sSp);
  if ffoCREnd in opt then IncD(s,CRLF);
  if ffoSP in opt then IncD(sSp,' ');
  Write(pointer(s)^,Length(s));
  DelStack;
end;

procedure TCustomFormatFile.WriteFile(const Args: array of const; const Format: string;
  opt: TFormatFileOptions = []);
begin
  AddStack('TCustomFormatFile.WriteFile(f)');
  WriteFile(SysUtils.Format(Format,Args),opt);
  DelStack;
end;

{ THtmlFile }
constructor THtmlFile.Create;
begin
	AddStack('THtmlFile.Create');
  inherited Create(FileName);
  WriteFile('HTML',[ffoSP]);
  WriteFile('HEAD',[ffoSP]);
  WriteFile('META HTTP-EQUIV="Content-type" CONTENT="text/htmp; charset=windows-1251"',[ffoCR]);
	WriteFile('STYLE',[ffoSP]);
  DelStack;
end;

destructor THtmlFile.Destroy;
begin
	AddStack('THtmlFile.Destroy');
  WriteFile('/body'); WriteFile('/html');
  inherited Destroy;
  DelStack;
end;

procedure THtmlFile.WriteBody;
var s: string;
begin
  AddStack('THtmlFile.WriteBody');
  WriteFile('/style'); WriteFile('/head');
  if bgColor=clNone then s:='' else s:=' bgcolor='+ColorHex(bgColor);
  WriteFile('BODY'+s,[ffoSP]);
  DelStack;
end;

class function THtmlFile.BeforeWrite;
begin
  AddStack('THtmlFile.BeforeWrite');
  if s='' then Include(opt,ffoNoq)
  else if s[1]='<' then Include(opt,ffoNoq);
  if not(ffoNoq in opt) then IncL(s,'<','>');
  result:='/';
  DelStack;
end;

{ TRtfFile }
constructor TRtfFile.Create;
begin
	AddStack('TRtfFile.Create');
  inherited Create(FileName);
  WriteFile('{\rtf1\ansi',[ffoSP]);
  DelStack;
end;

destructor TRtfFile.Destroy;
begin
	AddStack('TRtfFile.Destroy');
  WriteFile('}');
  inherited Destroy;
  DelStack;
end;

class function TRtfFile.BeforeWrite;
begin
  AddStack('TRtfFile.BeforeWrite');
  if ffoSP in opt then opt:=opt+[ffoCR]-[ffoSP];
  result:='}';
  DelStack;
end;

{ TXlsCells }
constructor TXlsCells.Create;
begin
  AddStack('TXlsCells.Create');
  FOwner:=Owner; FOffset:=Offset;
  DelStack;
end;

function TXlsCells.GetCount;
begin
  AddStack('TXlsCells.GetCount');
  result:=Length(FValues);
  DelStack;
end;

procedure TXlsCells.SetCount;
var i: longint;
begin
  AddStack('TXlsCells.GetCount');
  SetLength(FValues,Value); Modified:=false;
  for i:=low(FValues) to high(FValues) do with FValues[i] do begin
    p:=-1; w:=0;
  end;
  DelStack;
end;

function TXlsCells.GetValues;
begin
  AddStack('TXlsCells.GetValues');
  result:=FValues[Index].w;
  DelStack;
end;

procedure TXlsCells.SetValues;
begin
  AddStack('TXlsCells.SetValues');
  with FValues[Index] do begin
    w:=Value; MaxSelf(p,FOwner.Position);
    if Assigned(FProc) then FProc(Index,Value);
  end;
  DelStack;
end;

procedure TXlsCells.OffsetPositions;
var i: longint;
begin
  AddStack('TXlsCells.OffsetPositions');
  for i:=low(FValues) to high(FValues) do with FValues[i] do
    if p>=0 then Inc(p,FOwner.ssGlobals.Size);
  DelStack;
end;

procedure TXlsCells.WriteChanges;
var i: longint;
begin
  AddStack('TXlsCells.WriteChanges');
  if Modified then
    for i:=low(FValues) to high(FValues) do with FValues[i] do if p>=0 then begin
      FOwner.Position:=p+FOffset; FOwner.Write(w,2);
    end;
  DelStack;
end;

procedure TXlsCells.IncValue;
var i,w: longint;
begin
  AddStack('TXlsCells.IncValue');
  w:=Value;
  for i:=Index1 to Index2-1 do Dec(w,FValues[i].w);
  if w>FValues[Index2].w then begin
    FValues[Index2].w:=w; Modified:=true;
  end;
  DelStack;
end;

{ TXlsFile }
const
  XlsLenSect = $200;
  XlsMaxLenCmd = $2020;
{$IFDEF XLSINDEX}
  XlsLenBof = 20;
{$ENDIF}

  aXlsLine: array[1..3] of byte = (1,3,5);

var awXlsLine: array[0..Length(aXlsLine)-2] of longint;


function XlsColor(n: longint): Word;
begin
  result:=8+n;
end;

constructor TXlsFile.Create;
begin
	AddStack('TXlsFile.Create');
  inherited Create(FileName);
  WriteHex(
    [$D0,$CF,$11,$E0,$A1,$B1,$1A,$E1,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0   //00
    ,$00,$00,0  ,0  ,0  ,0  ,0  ,0  ,$3E,0  ,$03,0  ,$FE,$FF,$09,0   //01
    ,$06,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0                   //02
    ]);
  pCntSAT:=Position;
  WriteHex(
    [                                                0  ,0  ,0  ,0   //02
    ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,$10,0  ,0  ,$FE,$FF,$FF,$FF //03
    ,0  ,0  ,0  ,0                                                   //04
    ]);
  pSidMSAT:=Position; WriteFF;

  aWrite(XLS_BOF,
    [$0600 ,$0005 ,3515  ,1996  ,0         ,0],
    [stWord,stWord,stWord,stWord,stLongWord,stLongWord]);
  //aWrite(XLS_WRITEACCESS,[Padr('×Ï Ãóëÿåâ',$70)],[stChar]);
  aWrite(XLS_CODEPAGE,[$04E3],[]);
  aWrite(XLS_WINDOW1,[0,0,0,0,$38,0,0,1,0.6*1000],[]);
  lsXF:=TStringListCase.CreateSort;
  lsFormat:=SortStrListCreate; lsFormat.AddObject('General',Object0);
  lsSST:=TStringListCase.CreateSort; cntSST:=0;
  lsBlank:=TIntegerList.Create([ilsSorted,ilsUnSigned]);
  SetLength(aMerge,100); SetLength(aRK,100);
  ColWidths:=TXlsCells.Create(Self,8); ColWidths.FProc:=WriteCol;
  RowHeights:=TXlsCells.Create(Self,10);
  Options:=[xlsTrnsNum,xlsTrnsDate];
  DelStack;
end;

function lsObjIntSort(List: TStringList; Index1,Index2: longint): longint;
begin
  AddStack('HtmlFile.lsObjIntSort');
  result:=IntObj(List,Index1)-IntObj(List,Index2);
  DelStack;
end;

function CeilTo(Divided,Divider: Int64): longword;
begin
  AddStack('HtmlFile.CeilTo');
  if Divided<=0 then result:=0
  else begin
    result:=Divided;
    if ModDiv(result,Divider)>0 then Inc(result);
  end;
  DelStack;
end;

destructor TXlsFile.Destroy;
  procedure Dir1(const nm: string = ''; tp: byte = 0;
    NodeLeft: Int64 = -1; NodeRight: Int64 = -1; NodeChild: Int64 = -1;
    Sid: Int64 = 0; Size: longword = 0);
  var s: string;
    i,l,inm,lnm: longword;
    pz: Int64;
  begin
    AddStack('TXlsFile.Destroy.Dir1');
    lnm:=Length(nm); l := lnm shl 1; SetLength(s,l); ZeroMemory(pointer(s),l); i:=1;
    for inm:=1 to lnm do begin
      s[i]:=nm[inm]; Inc(i,2);
    end;
    pz:=Position; Write(pointer(s)^,l); Position:=pz+$40;
    if l<>0 then Inc(l,2);
    Write(l,2); i:=MakeWord(tp,0); Write(i,2);
    Write(NodeLeft,4); Write(NodeRight,4); Write(NodeChild,4); IncPosition(36);
    Write(Sid,4); Write(Size,4); i:=0; Write(i,4);
    DelStack;
  end;
const SectSI = 8; SizeSI = SectSI*XlsLenSect;
  EndOfChain = longword(-2);
  SectHeadMSAT = 109;
var cnt,SzBook,CntSect,SidMSAT,CntMSAT,CntSAT,nSAT,ocnt: longword;
  i,l: Int64;
  j: longint;
  s: string;
  av{$IFDEF XLSEXTSST},aEXTSST{$ENDIF}: TArrVar;
  at: TArrSaveType;
  w: Word;
  agSheet: array of Int64;
begin
	AddStack('TXlsFile.Destroy');
  ssGlobals:=TStringStream.Create('');
  try
    lsFormat.Sorted:=false; lsFormat.CustomSort(lsObjIntSort);
    for j:=0 to lsFormat.Count-1 do aWrite(XLS_FORMAT,[j,lsFormat[j]],[stWord,stChar]);
    for j:=0 to $0E do aWrite(XLS_XF,
      [0     ,0     ,$FFF5 ,$20   ,0     ,0     ,0     ,0         ,0         ,0],
      [stWord,stWord,stWord,stByte,stByte,stByte,stByte,stLongWord,stLongWord]);
    aWrite(XLS_XF,
      [1     ,0     ,0     ,$20   ,0     ,0     ,0     ,0         ,0         ,0],
      [stWord,stWord,stWord,stByte,stByte,stByte,stByte,stLongWord,stLongWord]); //$0F
    lsXF.Sorted:=false; lsXF.CustomSort(lsObjIntSort);
    for j:=0 to lsXF.Count-1 do begin
      w:=XLS_XF; ssGlobals.Write(w,2);
      s:=StrDeshifr(lsXF[j]); w:=Length(s); ssGlobals.Write(w,2); ssGlobals.Write(pointer(s)^,w);
    end;
    aWrite(XLS_STYLE,[$8000,$FF00],[]);
    SetLength(agSheet,Length(aSheet));
    for j:=low(aSheet) to high(aSheet) do begin
      agSheet[j]:=ssGlobals.Position;
      aWrite(XLS_BOUNDSHEET,
        [0         ,0     ,0     ,aSheet[j].nm],
        [stLongWord,stByte,stByte,stChar],1,2);
    end;
    cnt:=lsSST.Count;
    if cnt>0 then begin
      lsSST.Sorted:=false; lsSST.CustomSort(lsObjIntSort);
      SetLength(av,2+cnt); SetLength(at,Length(av));
      av[0]:=cntSST; at[0]:=stLongWord; av[1]:=cnt; at[1]:=stLongWord;
      for j:=2 to cnt+1 do begin
        av[j]:=StrDeshifr(lsSST[j-2]); at[j]:=stChar;
      end;
{$IFDEF XLSEXTSST}
      j:=max(8,Ceil(cnt/((XlsMaxLenCmd-2) div 8))); l:=Ceil(cnt/j)*3+1;
      SetLength(aEXTSST,l); aEXTSST[0]:=j;
      aWrite(XLS_SST,av,at,2,1,@aEXTSST);
      SetLength(at,l); at[0]:=stWord; j:=1;
      while j<l do begin
        at[j]:=stLongWord; Inc(j); at[j]:=stWord; Inc(j); at[j]:=stWord; Inc(j);
      end;
      aWrite(XLS_EXTSST,aEXTSST,at);
{$ELSE}
      aWrite(XLS_SST,av,at);
{$ENDIF}
    end;
    repeat
      l:=min(ssGlobals.Size,Position-pGlobals); SetLength(s,l);
      IncPosition(-l); Read(pointer(s)^,l);
      IncPosition(-l+ssGlobals.Size); Write(pointer(s)^,l);
      IncPosition(-l-ssGlobals.Size);
    until Position=pGlobals;
    CopyFrom(ssGlobals,0);
    for j:=low(aSheet) to high(aSheet) do begin
      Position:=pGlobals+agSheet[j]+4; cnt:=aSheet[j].p+ssGlobals.Size-XlsLenSect; Write(cnt,4);
{$IFDEF XLSINDEX}
      Position:=ssGlobals.Size+aSheet[j].p+XlsLenBof+12; Read(cnt,4); l:=Ceil(cnt/XlsRowsInBlock)+1;
      while l>0 do begin
        Read(cnt,4); Inc(cnt,ssGlobals.Size); Seek(-4,soFromCurrent); Write(cnt,4); Dec(l);
      end;
{$ENDIF}
    end;
    ColWidths.OffsetPositions; RowHeights.OffsetPositions;
{$IFDEF XLSINDEX}
    if pRow>0 then Inc(pRow,ssGlobals.Size);
    Inc(pDbCell,ssGlobals.Size);
{$ENDIF}
  finally
    FreeAndNil(ssGlobals);
  end;
  Seek(0,soFromEnd); EndSheet;
  // Header
  SzBook:=Position-XlsLenSect;
  if SzBook<SizeSI then begin
    SzBook:=SizeSI; Position:=XlsLenSect+SzBook;
  end;
  CntSect:=CeilTo(Position,XlsLenSect)-1; SidMSAT:=CntSect; CntSAT:=CeilTo(CntSect+1,$80);
  repeat
    ocnt:=CntSAT; CntSAT:=CeilTo(CntSect+CntSAT+1,$80);
    if CntSAT>SectHeadMSAT then begin
      cnt:=CntSAT-SectHeadMSAT; CntMSAT:=CeilTo(cnt,$80-1);
      if (CntMSAT>1) and (cnt mod ($80-1) = 1) then Dec(CntMSAT);
      CntSAT:=CeilTo(CntSect+CntMSAT+CntSAT+1,$80);
    end
    else CntMSAT:=0;
  until CntSAT=ocnt;
  cnt:=CntSect+CntMSAT+CntSAT;
  if CntMSAT=0 then SidMSAT:=EndOfChain;
  Position:=pCntSAT; Write(CntSAT,4); Write(cnt,4);
  Position:=pSidMSAT; Write(SidMSAT,4); Write(CntMSAT,4); Dec(cnt,CntSAT); nSAT:=CntSAT; i:=SectHeadMSAT;
  while nSAT>0 do begin
    Write(cnt,4); Inc(cnt); Dec(nSAT); Dec(i);
    if i=0 then break;
  end;
  Position:=(CntSect+1)*XlsLenSect;
  // MSAT
  i:=0;
  while nSAT>0 do begin
    Inc(i);
    if i=$80 then begin
      i:=0;
      if nSAT>1 then begin
        ocnt := (Position+4-1) div XlsLenSect; Write(ocnt,4); continue;
      end;
    end;
    Write(cnt,4); Inc(cnt); Dec(nSAT);
  end;
  WriteFF;
  // SAT
  cnt:=1;
  for ocnt:=1 to CntSect-1 do begin
    Write(cnt,4); Inc(cnt);
  end;
  cnt:=EndOfChain; Write(cnt,4);
  cnt:=longword(-4);
  for nSAT:=1 to CntMSAT do Write(cnt,4);
  cnt:=longword(-3);
  for nSAT:=1 to CntSAT do Write(cnt,4);
  cnt:=EndOfChain; Write(cnt,4); WriteFF;
  // DIR
  Dir1('Root Entry',5,-1,-1,1,-1);
  Dir1('Workbook',2,-1,-1,-1,0,SzBook);
  Dir1; Dir1;
  lsSST.Free; lsXF.Free; lsFormat.Free; lsBlank.Free;
  inherited Destroy;
  DelStack;
end;

class function TXlsFile.BeforeWrite;
begin
  result:=#0;
end;

function AWordToStr(const a: array of Word): string;
var i,j: longint;
begin
  AddStack('HtmlFile.AWordToStr');
  SetLength(result,Length(a) shl 1); j:=0;
  for i:=low(a) to high(a) do begin
    Inc(j); result[j]:=Chr(Byte(a[i])); Inc(j); result[j]:=Chr(HiByte(a[i]));
  end;
  DelStack;
end;

procedure TXlsFile.WriteCell;
  function Line(w: TLineNulWidth): byte;
  var n,nb,ne: byte;
  begin
    AddStack('TXlsFile.WriteCell.Line');
    if w=0 then result:=0
    else begin
      n:=low(awXlsLine); nb:=1;
      while n<=high(awXlsLine) do begin
        ne:=nb+awXlsLine[n]-1;
        if InRange(w,nb,ne) then begin
          if ne-w>w-nb then Inc(n);
          break;
        end;
        Inc(nb,awXlsLine[n]); Inc(n);
      end;
      result:=aXlsLine[n];
    end;
    DelStack;
  end;
  function TxtAlgm(const txt: string): string;
  begin
    AddStack('TXlsFile.WriteCell.TxtAlgm');
    case algmHorz of
      taLeftJustify: result:=TrimRight(txt);
      taRightJustify: result:=TrimLeft(txt);
    else result:=Trim(txt);
    end;
    DelStack;
  end;
  function wTxt(const txt: string): longint;
  begin
    AddStack('TXlsFile.WriteCell.wTxt');
    result:=Ceil((Canvas.TextWidth(TxtAlgm(txt)))*ProcentCol)+245;
    DelStack;
  end;
var nxf: Word;
  procedure SetBlank(ARow,ACol: Word);
  begin
    AddStack('TXlsFile.WriteCell.SetBlank');
    lsBlank.Add(MakeLong(ACol,ARow),nxf);
    DelStack;
  end;
const aAlgm: array[1..2,TAlignment] of byte = ((1,3,2),(0,2,1));
var i,nN,nD,t,pt,l: longint;
  vi: Int64;
  nFormat,nWrap: byte;
  s,st: string;
  vw: LongWord;
  vd: Double;
  fl,lN,lD: boolean;
  v: variant;
  dt: TDateTime;
  a: TArrStr;
begin
  AddStack('TXlsFile.WriteCell');
  v:=Value; st:=''; nWrap:=0;
  if MyVarType(v)=varString then begin
    StrTranSelf(v,CRLF,cXlsCRLF,[rfReplaceAll],@i);
    if i=0 then begin
      s:=Trim(v);
      if s<>'' then begin
        nN:=0; nD:=0; lN:=true; lD:=true; fl := DecimalSeparator<>DateSeparator;
        for i:=1 to Length(s) do begin
          if s[i]=DecimalSeparator then begin
            Inc(nN);
            if nN>1 then lN:=false;
            if fl then lD:=false;
          end
          else if s[i]=DateSeparator then begin
            Inc(nD);
            if nD>2 then lD:=false;
            if fl then lN:=false;
          end
          else if s[i] in ['+','-','0'..'9'] then begin
            if s[i] in ['+','-'] then lD:=false
          end
          else begin
            lN:=false; lD:=false;
          end;
          if not(lN or lD) then break;
        end;
        if (xlsTrnsDate in Options) and lD then begin
          i:=Length(s)-6;
          if (nD=2) and (Pos(DateSeparator,s)=3) and (RPos(DateSeparator,s)=6) and (i in [2,4]) then begin
            dt:=ctod(s); st:='dd/mm/'+StringOfChar('y',i);
            if OurFormatDateTime(st,dt)=s then begin
              lN:=false; v:=dt;
            end
            else st:='';
          end;
        end;
        if (xlsTrnsNum in Options) and lN and (Length(s)<=13) and (algmHorz=taRightJustify) and (TrimRight(v)=v) then
          if nN=0 then v:=Int064(v)
          else begin
            Float0Self(v); st:=StrTran(s,DecimalSeparator,'.',[]);
          end;
      end;
    end
    else begin
      nWrap:=1;
      if AdjustWH then begin
        Canvas.Font.Assign(anFont[2+nFont]);
        RowHeights.IncValue(Row1,Row2,Ceil((CanvasMaxH(Canvas)*(i+1)
          +0.5/MmInInch*Screen.PixelsPerInch*(i+2))*TwipsInInch/Screen.PixelsPerInch));
        vi:=0;
        for i:=0 to LsArrDynamic(v,a,cXlsCRLF)-1 do MaxSelf(vi,wTxt(a[i]));
        ColWidths.IncValue(Col1,Col2,vi);
      end;
    end;
  end
  else st:=Format;
  pt:=0; t:=MyVarType(v); l:=Length(st);
  if t=varDouble then
    if IsPos(pt,'.',st) then st:='0.'+StringOfChar('0',Length(st)-pt) else t:=varInteger;
  if t=varInteger then st:='0';
  if st='' then nFormat:=pt else nFormat:=IntObjFindAdd(lsFormat,st);
  s:=AWordToStr([nFont+5,nFormat,IfThen(xlsProtect in Options,1),
    MakeWord(aAlgm[2,algmVert] shl 4 + nWrap shl 3 + aAlgm[1,algmHorz],
    IfThen(InRange(Angle,1,164),Angle+90,IfThen(InRange(Angle,270,359),360-Angle))),
    $7C00 or IfThen(xlsProtect in Options,$8000),
    MakeWord(Line(wLeft)+Line(wRight) shl 4,Line(wTop)+Line(wBottom) shl 4),
    XlsColor(nclLeft)+XlsColor(nclRight) shl 7,XlsColor(nclTop)+XlsColor(nclBottom) shl 7,
    1 shl 10,XlsColor(nColor)]);
  nD:=$10+lsXF.Count; IntObjFindAdd(lsXF,StrShifr(s),i,nN,nD); nxf:=nN;
  if t in [varInteger,varDouble,varDate] then begin
    fl:=true; vw:=0;
    if t<>varDouble then begin
      vi:=v;
      if vi<0 then t:=varDouble
      else if vi <= (MaxLong shr 2) then begin
        fl:=false; vw:=vi;
      end;
    end;
    if pt>0 then
      if l-pt=2 then begin
        vd:=v*100;
        if aSign[vd<0]*vd <= (MaxLong shr 2) then begin
          fl:=false; vw:=nround(vd);
        end;
      end;
    if fl
    then aWriteCell(XLS_NUMBER,
      [Row1  ,Col1  ,nxf   ,v],
      [stWord,stWord,stWord,stDouble])
    else aWriteCell(XLS_RK,
      [Row1  ,Col1  ,nxf   ,vw shl 2 + 2 + byte(IfThen(t=varDouble,1))],
      [stWord,stWord,stWord,stLongWord]);
    if AdjustWH then begin
      Canvas.Font.Assign(anFont[2+nFont]); ColWidths.IncValue(Col1,Col2,wTxt(ValueAsStr));
    end;
  end
  else if empty(v)
    then SetBlank(Row1,Col1)
  else begin
    aWriteCell(XLS_LABELSST,
      [Row1  ,Col1  ,nxf   ,IntObjFindAdd(lsSST,StrShifr(TxtAlgm(v)))],
      [stWord,stWord,stWord,stLongWord]);
    Inc(cntSST);
  end;
  if (Row2>Row1) or (Col2>Col1) then begin
    if Length(aMerge)=nMerge then SetLength(aMerge,nMerge shl 1);
    aMerge[nMerge,1]:=Row1; aMerge[nMerge,2]:=Row2; aMerge[nMerge,3]:=Col1; aMerge[nMerge,4]:=Col2;
    Inc(nMerge);
    for i:=Row1 to Row2 do
      for t:=Col1 to Col2 do
        if not((i=Row1) and (t=Col1)) then SetBlank(i,t);
  end;
  DelStack;
end;

procedure TXlsFile.aWriteCell;
var n: byte;
  h: Word;
  i: longint;
  fl: boolean;
begin
  AddStack('TXlsFile.aWriteCell');
  if a[0]>oRow then NewRow(a[0],a[1]);
  if a[0]>oRow then begin
    oRow:=a[0]; n := oRow mod XlsRowsInBlock;
    if n=0 then begin
{$IFDEF XLSINDEX}
      if pRow=0 then aWrite(XLS_DIMENSIONS,
        [0         ,RowHeights.Count,0,ColWidths.Count,0],
        [stLongWord,stLongWord]);
      DbCell; pRow:=Position; CntRow:=0;
{$ENDIF}
      for i:=oRow to min(oRow+XlsRowsInBlock,RowHeights.Count)-1 do begin
{$IFDEF XLSINDEX}
        Inc(CntRow);
{$ENDIF}
        h:=RowHeights[i];
        aWrite(XLS_ROW,
          [i     ,0     ,ColWidths.Count,IfThen(h=0,$8000,h),0     ,0     ,$0100+IfThen(h>0,$40)],
          [stWord,stWord,stWord         ,stWord             ,stWord,stWord,stLongWord]);
{$IFDEF XLSINDEX}
        if i=oRow then pRow1:=Position;
{$ENDIF}
      end;
    end;
{$IFDEF XLSINDEX}
    apRow[n+1]:=Position-pRow1; pRow1:=Position;
{$ENDIF}
  end;
  fl:=true;
  if not lsBlankWriting then
    if ID=XLS_BLANK then begin
      lsBlank.Add(MakeLong(a[1],a[0]),Word(a[2])); fl:=false;
    end
    else WriteBlank(a[0],a[1]);
  if ID=XLS_RK then begin
    if RKCrd.Count=0 then begin
      RKCrd.Row:=a[0]; RKCrd.Col:=a[1];
    end;
    if RKCrd.Count=Length(aRK) then SetLength(aRK,RKCrd.Count shl 1);
    aRK[RKCrd.Count].XF:=a[2]; aRK[RKCrd.Count].RK:=a[3]; Inc(RKCrd.Count); fl:=false;
  end
  else WriteRK;
  if fl then aWrite(ID,a,at);
  DelStack;
end;

procedure TXlsFile.WriteBlank;
var i,n: longint;
  procedure Wr1;
  var j,l: longint;
    a: TArrVar;
  begin
    AddStack('TXlsFile.WriteBlank.Wr1');
    l:=i-n;
    if l>0 then
      if l=1 then begin
        aWriteCell(XLS_BLANK,[HiWord(lsBlank[n]),Word(lsBlank[n]),lsBlank.IntObj(n)],[]);
        n:=i;
      end
      else begin
        SetLength(a,l+3); a[0]:=HiWord(lsBlank[n]); a[1]:=Word(lsBlank[n]); j:=2;
        while n<i do begin
          a[j]:=lsBlank.IntObj(n); Inc(j); Inc(n);
        end;
        a[j]:=Word(a[1])+l-1; aWriteCell(XLS_MULBLANK,a,[]);
      end;
    DelStack;
  end;
  {procedure Wr1;
  begin
    AddStack('TXlsFile.WriteBlank.Wr1');
    while n<i do begin
      aWriteCell(XLS_BLANK,[HiWord(lsBlank[n]),Word(lsBlank[n]),lsBlank.IntObj(n)],[]);
      Inc(n);
    end;
    DelStack;
  end;}
var j: longword;
  oldr,r: Word;
begin
  AddStack('TXlsFile.WriteBlank');
  if (lsBlank.Count>0) and not lsBlankWriting then begin
    lsBlankWriting:=true; i:=0; n:=0; j:=MakeLong(ACol,ARow); oldr:=HiWord(lsBlank[0]);
    while i<lsBlank.Count do begin
      if longword(lsBlank[i])>j then break;
      r:=HiWord(lsBlank[i]);
      if r>oldr then begin
        oldr:=r; Wr1;
      end;
      Inc(i);
    end;
    Wr1;
    while i>0 do begin
      lsBlank.Delete(0); Dec(i);
    end;
    lsBlankWriting:=false;
  end;
  DelStack;
end;

procedure TXlsFile.WriteRK;
var a: TArrVar;
  i,j: longint;
  at: TArrSaveType;
begin
  AddStack('TXlsFile.WriteRK');
  with RKCrd do if Count>0 then begin
    if Count=1 then with aRK[0] do aWrite(XLS_RK,
      [Row   ,Col   ,XF    ,RK],
      [stWord,stWord,stWord,stLongWord])
    else begin
      SetLength(a,Count*2+3); SetLength(at,Length(a));
      a[0]:=Row; at[0]:=stWord; a[1]:=Col; at[1]:=stWord; j:=2;
      for i:=0 to Count-1 do with aRK[i] do begin
        a[j]:=XF; at[j]:=stWord; Inc(j); a[j]:=RK; at[j]:=stLongWord; Inc(j);
      end;
      a[j]:=Col+Count-1; at[j]:=stWord; aWrite(XLS_MULRK,a,at);
    end;
    Count:=0;
  end;
  DelStack;
end;

procedure TXlsFile.aWrite;
var Stream: TStream;
  function Write1(const Value: variant; tp: TSaveType = stWord): Longint;
  var sr: TSaveRec;
  begin
    AddStack('TXlsFile.aWrite.Write1');
    VarToSvRec(Value,tp,sr);
    result:=Stream.Write(sr.s,SizeOfVar[tp]);
    DelStack;
  end;
var l: longword;
  pl: Int64;
  procedure WriteID(ID: Word);
  begin
    AddStack('TXlsFile.aWrite.WriteID');
    Write1(ID); pl:=Stream.Position;
    if not Assigned(ssGlobals) then Write1(0);
    l:=0;
    DelStack;
  end;
  procedure WriteLen;
  var s: string;
    p: Int64;
  begin
    AddStack('TXlsFile.aWrite.WriteLen');
    if Assigned(ssGlobals) then begin
      s:=Copy(ssGlobals.DataString,pl+1,MaxInt); Stream.Position:=pl; Write1(l);
      Stream.Write(pointer(s)^,Length(s));
    end
    else begin
      p:=Position; Position:=pl; Write1(l); Position:=p;
    end;
    DelStack;
  end;
var l1{$IFDEF XLSEXTSST},ne,le{$ENDIF}: Word;
  s,st: string;
  cb: 0..2;
  cp: TUnicodeSize;
  procedure UniCode;
  var n: longint;
    sr: record
      case boolean of
        false: (w: Word);
        true: (s: array[1..2] of char);
    end;
    j: TUnicodeSize;
  begin
    AddStack('TXlsFile.aWrite.UniCode');
    cp:=CntPack;
    if (CntByte=2) and (cp=1) then cp:=UnicodeSize(s);
    SetLength(st,cb+1); n:=0;
    if cb<>0 then begin
{$IFDEF XLSEXTSST}
      if Assigned(paEXTSST) then begin
        if le=0 then begin
          paEXTSST^[ne]:=pGlobals+ssGlobals.Position+2-XlsLenSect; Inc(ne);
          paEXTSST^[ne]:=ssGlobals.Position-pl; le:=paEXTSST^[0]; Inc(ne,2);
        end;
        Dec(le);
      end;
{$ENDIF}
      sr.w:=Length(s);
      for j:=1 to cb do begin
        Inc(n); st[n]:=sr.s[j];
      end;
    end;
    Inc(n); st[n]:=Chr(cp-1); IncD(st,WinToUnicode(s,cp)); l1:=Length(st);
    DelStack;
  end;
var i,l2: longint;
  tp: TSaveType;
begin
  AddStack('TXlsFile.aWrite');
  Stream:=IfThen(Assigned(ssGlobals),ssGlobals,Self);
{$IFDEF XLSEXTSST}
  le:=0; ne:=1;
{$ENDIF}
  WriteID(ID);
  for i:=low(a) to high(a) do begin
    if i>high(at) then tp:=stWord else tp:=at[i];
    if tp=stChar then begin
      cb:=CntByte; s:=a[i]; UniCode;
      while l+l1>XlsMaxLenCmd do begin
        l2:=XlsMaxLenCmd-l-cb;
        if l2>cp then begin
          l2 := (l2-1) div cp;
          if l2>0 then begin
            l1:=cb+1+cp*l2; SetLength(st,l1); Stream.Write(pointer(st)^,l1); Inc(l,l1);
            cb:=0; Delete(s,1,l2); UniCode;
          end;
        end;
        WriteLen; WriteID(XLS_CONTINUE);
      end;
      Stream.Write(pointer(st)^,l1);
    end
    else begin
      l1:=SizeOfVar[tp]; Write1(a[i],tp);
    end;
    Inc(l,l1);
  end;
  WriteLen;
  DelStack;
end;

procedure TXlsFile.WriteHex;
var s: string;
  i,j,l: longint;
begin
  AddStack('TXlsFile.WriteHex');
  l:=Length(a); SetLength(s,l); i:=low(a);
  for j:=1 to l do begin
    s[j]:=Chr(a[i]); Inc(i);
  end;
  Write(pointer(s)^,l);
  DelStack;
end;

procedure TXlsFile.WriteFF;
var l: longword;
  s: string;
begin
  AddStack('TXlsFile.WriteFF');
  l:=CeilTo(Position,XlsLenSect)*XlsLenSect-Position;
  if l>0 then begin
    SetLength(s,l); SetMemory(pointer(s),l); Write(pointer(s)^,l);
  end;
  DelStack;
end;

procedure TXlsFile.SetGlobals;
var afc: TArrShortInt;
  j: Word;
  procedure WriteFont(nFont: longint);
  begin
    AddStack('TXlsFile.SetGlobals.WriteFont');
    with anFont[nFont] do aWrite(XLS_FONT,
      [IfThen((nFont=1)and(SizeFontHead<>0),SizeFontHead,Size)*20,IfThen(fsItalic in Style,2)+IfThen(fsStrikeOut in Style,8),XlsColor(afc[nFont]),IfThen(fsBold in Style,$02BC,$0190),0     ,IfThen(fsUnderline in Style,1),0     ,CharSet,0     ,Name],
      [stWord                                                    ,stWord                                                    ,stWord              ,stWord                             ,stWord,stByte                        ,stByte,stByte ,stByte,stChar],
      1);
    DelStack;
  end;
type TPaletteList = 0..XlsColorCount;
var i: Word;
  h: longint;
  avColor: array[TPaletteList] of variant;
  at: array[TPaletteList] of TSaveType;
begin
  AddStack('TXlsFile.SetGlobals');
  SetLength(anFont,2+Length(aFont)); DefaultFont(Canvas.Font); anFont[0]:=Canvas.Font; anFont[1]:=aFont[0];
  ProcentCol:=256/Canvas.TextWidth('W'); h:=low(aFont);
  for i:=2 to high(anFont) do begin
    anFont[i]:=aFont[h]; Inc(h);
  end;
  SetLength(afc,Length(anFont)); aColorSet(aColor,anColor); h:=high(aColor);
  for j:=low(afc) to high(afc) do begin
    afc[j]:=-1;
    for i:=low(anColor) to high(anColor) do
      if anColor[i]=anFont[j].Color then begin
        afc[j]:=i; break;
      end;
    if afc[j]<0 then
      if h<high(anColor) then begin
        Inc(h); anColor[h]:=anFont[j].Color; afc[j]:=h;
      end
      else afc[j]:=0;
  end;
  avColor[0]:=$10; at[0]:=stWord; j:=0;
  for i:=low(anColor) to high(anColor) do begin
    Inc(j); avColor[j]:=ColorToRGB(anColor[i]) and $FFFFFF; at[j]:=stLongWord;
  end;
  aWrite(XLS_PALETTE,avColor,at);
  WriteFont(0); WriteFont(1); WriteFont(0); WriteFont(0);
  for i:=2 to high(anFont) do WriteFont(i);
  pGlobals:=Position;
  aWrite(XLS_EOF,[],[]);
  SetLength(aSheet,CountSheet); nSheet:=low(aSheet);
  DelStack;
end;

procedure TXlsFile.BeginSheet;
{$IFDEF XLSINDEX}
var av: TArrVar;
  at: TArrSaveType;
  i: longint;
  p,dw: longword;
{$ENDIF}
begin
  AddStack('TXlsFile.BeginSheet');
  aSheet[nSheet].nm:=Name; aSheet[nSheet].p:=Position;
  aWrite(XLS_BOF,
    [$0600 ,$0010 ,0     ,0     ,0         ,0],
    [stWord,stWord,stWord,stWord,stLongWord,stLongWord]);
{$IFDEF XLSINDEX}
  i:=4+Ceil(RowCount/XlsRowsInBlock);
  SetLength(av,i); av[1]:=0; av[2]:=RowCount; av[3]:=0;
  SetLength(at,i); FillMemory(@at[0],i,byte(stLongWord));
  aWrite(XLS_INDEX,av,at);
{$ENDIF}
  nMerge:=0; RKCrd.Count:=0;
  aWrite(XLS_LEFTMARGIN,[l/MMInInch],[stDouble]);
  aWrite(XLS_RIGHTMARGIN,[r/MMInInch],[stDouble]);
  aWrite(XLS_TOPMARGIN,[t/MMInInch],[stDouble]);
  aWrite(XLS_BOTTOMMARGIN,[b/MMInInch],[stDouble]);
  aWrite(XLS_SETUP,
    [Format,0     ,1     ,0     ,0     ,IfThen(orient=poPortrait,2),0     ,0     ,0       ,0       ,0],
    [stWord,stWord,stWord,stWord,stWord,stWord                     ,stWord,stWord,stDouble,stDouble]);
  if xlsProtect in Options then begin
    aWrite(XLS_PROTECT,[1],[stWord]);
    aWrite(XLS_PASSWORD,[$FF],[stWord]);
  end;
{$IFDEF XLSINDEX}
  p:=Position; dw:=p-XlsLenSect; Position:=aSheet[nSheet].p+XlsLenBof+16; Write(dw,4);
  pDbCell:=Position; Position:=p; pRow:=0;
{$ENDIF}
  aWrite(XLS_DEFCOLWIDTH,[8],[stWord]);
  ColWidths.Count:=ColCount; RowHeights.Count:=RowCount; oRow:=-1; Inc(nSheet);
  DelStack;
end;

procedure TXlsFile.EndSheet;
const MaxLenMerge = 1026;
var a: TArrVar;
  i,n: longint;
  j: byte;
  p: Int64;
begin
  AddStack('TXlsFile.EndSheet');
  NewRow(MaxWord,MaxWord); p:=Position; ColWidths.WriteChanges; RowHeights.WriteChanges; Position:=p;
{$IFDEF XLSINDEX}
  DbCell;
{$ENDIF}
  if nMerge>0 then begin
    n:=min(MaxLenMerge,nMerge); SetLength(a,n*Length(aMerge[0])+1); a[0]:=n; n:=0; p:=nMerge;
    for i:=0 to nMerge-1 do begin
      if n=high(a) then begin
        aWrite(XLS_MERGEDCELLS,a,[]); n:=0; Dec(p,MaxLenMerge);
      end;
      for j:=low(aMerge[i]) to high(aMerge[i]) do begin
        Inc(n); a[n]:=aMerge[i,j];
      end;
    end;
    if n>0 then begin
      SetLength(a,n+1); a[0]:=p; aWrite(XLS_MERGEDCELLS,a,[]);
    end;
  end;
  aWrite(XLS_WINDOW2,
    [$06B6 ,0     ,0     ,0     ,0     ,0     ,0     ,0],
    [stWord,stWord,stWord,stWord,stWord,stWord,stWord,stLongWord]);
  aWrite(XLS_EOF,[],[]);
  DelStack;
end;

procedure TXlsFile.NewRow;
begin
  AddStack('TXlsFile.NewRow');
  WriteBlank(ARow,ACol); WriteRK;
  DelStack;
end;

procedure TXlsFile.WriteCol;
begin
  AddStack('TXlsFile.WriteCol');
  aWrite(XLS_COLINFO,[Index,Index,Value,0,0,0],[]);
  DelStack;
end;

{$IFDEF XLSINDEX}
procedure TXlsFile.DbCell;
var av: TArrVar;
  i: byte;
  p,dw: longword;
begin
  AddStack('TXlsFile.DbCell');
  if pRow>0 then begin
    SetLength(av,CntRow+1); av[0]:=Position-pRow; pRow:=0;
    for i:=1 to CntRow do av[i]:=apRow[i];
    p:=Position; dw:=p-XlsLenSect; Position:=pDbCell; Write(dw,4); Position:=p; Inc(pDbCell,4);
    aWrite(XLS_DBCELL,av,[stLongWord]);
  end;
  DelStack;
end;
{$ENDIF}

class procedure TXlsFile.aColorSet;
var i,h: longint;
begin
  AddStack('TXlsFile.aColorSet');
  h:=high(Source);
  for i:=low(Dest) to high(Dest) do
    if i>h then Dest[i]:=AColor[i] else Dest[i]:=Source[i];
  DelStack;
end;

initialization
  AddStack('HtmlFile.initialization');
  RasprOst(awXlsLine,MaxLineWidth,[rspoEqual]);
  DelStack;
end.
