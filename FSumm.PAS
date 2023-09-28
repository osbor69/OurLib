unit fsumm;

interface

{$I LIBTEST}
uses
  Classes,
  MyTypes,My_pr,BufFile;

type
  TSummRenameList = (smrNSumSum,smrMatch); TSummRenameOpt = set of TSummRenameList;

	TSumm = class(Tobject)
	private
    aLine: array of record
      aColNum: TArrRsumm;
      aColStr: TArrStr;
    end;
    LineCnt,iLine0: longint;
    sLine0: string;
    aColCnt: array[TSumType,0..1] of longint;
    lsSum: TStringList;
    aSum: array of record
      a: TArrRsumm;
      lAdd: boolean;
    end;
    procedure lsClear;
    function SearchInit(const s: string; lc: TSummLineCol;
      var pr: TProcStrComp; var sbeg: string; var n: longint; lMatch: boolean = false): longint;
    function AddLine0: longint; overload;
  protected
    class procedure SummException(const Message: string); virtual;
	public
		name:string;
    aName: array[TSummLineCol] of TStringListCase;
		procedure Init;
		procedure InitLine;
		procedure InitCol;
		function AddN(const sl,sc:string;z:rsumm; ndec: longint = NegDef): rsumm; overload;
		function AddN(const sl,sc:string): rsumm; overload;
		function AddIN(indl,indc: longint; z: rsumm = 0; ndec: longint = NegDef): rsumm; overload;
		function AddIN(indl: longint; const indc: TSummColInf; z: rsumm = 0; ndec: longint = NegDef): rsumm; overload;
		function AddN0(const sl,sc:string;z:rsumm; ndec: longint = NegDef): boolean;
		procedure AddIN0(const sl:string; const indc: TSummColInf; z: rsumm = 0; ndec: longint = NegDef); overload;
		procedure AddIN0(const indc: TSummColInf; z: rsumm = 0; ndec: longint = NegDef); overload;
		function AddS(const sl,sc,z:string): string;
		function SetN(const sl,sc: string; z: rsumm = 0; ndec: longint = NegDef): rsumm;
		function SetIN(indl,indc: longint; z: rsumm = 0; ndec: longint = NegDef): rsumm; overload;
		function SetIN(indl: longint; const indc: TSummColInf; z: rsumm = 0; ndec: longint = NegDef): rsumm; overload;
		procedure SetN0(const sl,sc: string; z: rsumm = 0; ndec: longint = NegDef);
		function SetS(const sl,sc:string; const z:string = ''): string;
		function SetIS(indl,indc: longint; const z: string): string; overload;
		function SetIS(indl: longint; const indc: TSummColInf; const z: string): string; overload;
		procedure SetS0(const sl,sc,z:string);
		function SetV(const sl,sc: string; const z: variant; ndec: longint = NegDef): variant; overload;
    function SetV(indl: longint; const indc: TSummColInf; const z: variant; lTrimRight: boolean = false): variant; overload;
    procedure AddLine0(const sl:string); overload;
		procedure SetIN0(const indc: TSummColInf; z: rsumm = 0; ndec: longint = NegDef);
		procedure SetIS0(const indc: TSummColInf; const z: string);
		function AddLine(const sl:string; pi: PLongint = nil):longint; overload;
		procedure AddLine(const sl: array of string); overload;
		function AddLine(const sl:string; var il: longint): boolean; overload;
		function AddCol(const sc: string; t: TSumType = s_string; lCheckType: boolean = false): TSummColInf; overload;
		procedure AddCol(const sc: array of string; t: TSumType = s_string); overload;
    function LineInf(nl: longint): longint;
    procedure LineInfSelf(var nl: longint);
    function ColInf(nc: longint): TSummColInf; overload;
    function ColInf(const sc: string; var indc: TSummColInf): boolean; overload;
		function Value(const sc,sl: string): variant; overload;
		function Value(const sc,sl: string; var v: variant; const Default: variant): boolean; overload;
		function Value(const sc,sl: string; const Default: variant): variant; overload;
    function Value(const indc: TSummColInf; indl: longint): variant; overload;
		function ArrName(lc: TSummLineCol; var a: TArrStr; const s: string = ''; Vid: TSummArrVid = smaArr): longint; overload;
		function ArrName(lc: TSummLineCol; var a: TArrInt; const s: string = ''; Vid: TSummArrVid = smaArr): longint; overload;
	  procedure ArrName(lc: TSummLineCol; var a: TArrStr; var result: longint; const s: string = ''; Vid: TSummArrVid = smaArr); overload;
		procedure ArrName(lc: TSummLineCol; var a: TArrInt; var result: longint; const s: string = ''; Vid: TSummArrVid = smaArr); overload;
		function CntName(lc: TSummLineCol; const s: string = ''): longint;
		function IsName(lc: TSummLineCol; const s: string = ''): boolean;
		function Rename(lc: TSummLineCol; const os,ns: string; Opt: TSummRenameOpt = []): string;
		procedure Rename1(lc: TSummLineCol; const os,ns: string);
		procedure DelName(lc: TSummLineCol; const s: string; lMatch: boolean = false);
		function SumLine(const sl,srez: string; const sc: string = ''; ndec: longint = NegDef;
    	const sExcl: string = ''; Opt: TSummSumOpt = []): boolean;
		function SumCol(const sc,srez: string; const sl: string = ''; ndec: longint = NegDef;
    	const sExcl: string = ''; Opt: TSummSumOpt = []): boolean;
		function SumLineCol(const LineShape,ColShape: string; ndec: longint = NegDef): variant;
		function SepLine(const sl,srez:string): boolean;
    procedure SaveTo(f: TCustomBuf; const aln: array of longint; ll: longint); overload;
    procedure SaveTo(f: TCustomBuf; const s: string = ''); overload;
    procedure LoadFrom(f: TCustomBuf);
		class function Nsumsum(const s,sl,srez:string; var sr: string; lEq: boolean = false): boolean;
    procedure FormSummExec(const sl: string = ''; const sc: string = ''; const Capt: string = '';
      const CaptX: string = ''; const CaptY: string = ''; ProcHead: TFormSummHead = nil; PrmHead: pointer = nil; PrmNum: PFmtNum = nil;
      ProcShow: TNotifyEvent = nil; NoColWidthsCorr: boolean = false);
		constructor Create; overload; virtual;
		class function Create(usl: boolean): TSumm; overload;
		destructor Destroy; override;
	end;

function SummVar(const v: variant): TSumm;

implementation

uses Windows,SysUtils,StrUtils,Math;

function SummVar;
begin
  result:=PointerVar(v);
end;

function CompTrue(const s1,s2: string): boolean;
begin
  result:=true;
end;

function CompFalse(const s1,s2: string): boolean;
begin
  result:=false;
end;

function CompMatch(const s1,s2: string): boolean;
begin
  result := s1=s2;
end;

procedure InitArr(var a: TArrRsumm; l: longint; lSetLen: boolean); overload;
begin
  AddStack('fsumm.InitArr');
  if lSetLen then SetLength(a,l);
  if l>0 then ZeroMemory(@a[0],SizeOf(a[0])*l);
  DelStack;
end;

{ Tsumm }
constructor Tsumm.Create;
var lc: TSummLineCol;
begin
	AddStack('Tsumm.Create');
  lsSum:=SortStrListCreate;
  for lc:=low(aName) to high(aName) do begin
    aName[lc]:=TStringListCase.Create; aName[lc].Sorted:=true;
  end;
  DelStack;
end;

class function Tsumm.Create(usl: boolean): TSumm;
begin
  if usl then result:=Create else result:=nil;
end;

destructor Tsumm.Destroy;
var lc: TSummLineCol;
begin
	AddStack('Tsumm.Destroy');
  init;
  if Assigned(lsSum) then begin
    lsClear; lsSum.Destroy;
  end;
  for lc:=low(aName) to high(aName) do aName[lc].Free;
	inherited Destroy;
  DelStack;
end;

procedure Tsumm.Init;
begin
	AddStack('Tsumm.Init');
  InitLine; InitCol;
  DelStack;
end;

procedure Tsumm.InitLine;
begin
	AddStack('Tsumm.InitLine');
  Finalize(aLine); LineCnt:=0; aName[s_line].Clear;
  DelStack;
end;

procedure Tsumm.InitCol;
begin
	AddStack('Tsumm.InitCol');
  ZeroMemory(@aColCnt,SizeOf(aColCnt)); aName[s_col].Clear;
  DelStack;
end;

procedure Tsumm.lsClear;
begin
  AddStack('Tsumm.lsClear');
  Finalize(aSum); lsSum.Clear;
  DelStack;
end;

function Rnd(v: RSumm; ndec: longint): RSumm;
begin
  AddStack('FSumm.Rnd');
  result:=mround(v,ReplNeg(ndec,FloatMaxDec));
  DelStack;
end;

procedure IncD(var d: RSumm; const d2: RSumm; ndec: longint);
begin
  d:=Rnd(d+d2,ndec);
end;

function Tsumm.AddN(const sl,sc:string;z:rsumm; ndec: longint = NegDef): rsumm;
begin
	AddStack('Tsumm.AddN');
{if (sl='RSV,4,НР,') and (sc='S2') then begin
  aName:=aName;
end;}
  result:=AddIN(AddLine(sl),AddCol(sc,s_num,true),z,ndec);
  DelStack;
end;

function Tsumm.AddN(const sl,sc:string): rsumm;
begin
  result:=AddN(sl,sc,1,0);
end;

function Tsumm.AddIN(indl,indc: longint; z: rsumm = 0; ndec: longint = NegDef): rsumm;
begin
  AddStack('Tsumm.AddIN');
  {if (indl=3) and (indc=12) then begin
    aName:=aName;
  end;}
  result:=aLine[indl].aColNum[indc]; IncD(aLine[indl].aColNum[indc],z,ndec);
  DelStack;
end;

function Tsumm.AddIN(indl: longint; const indc: TSummColInf; z: rsumm = 0; ndec: longint = NegDef): rsumm;
begin
  result:=AddIN(indl,indc.index,z,ndec)
end;

function Tsumm.AddN0;
begin
  AddStack('Tsumm.AddN0');
  result:=not empty(z);
  if result
  then AddN(sl,sc,z,ndec);
  DelStack;
end;

procedure Tsumm.AddIN0(const sl:string; const indc: TSummColInf; z: rsumm = 0; ndec: longint = NegDef);
begin
  AddStack('Tsumm.AddIN0');
  if not empty(z) then AddIN(AddLine(sl),indc,z,ndec);
  DelStack;
end;

procedure Tsumm.AddIN0(const indc: TSummColInf; z: rsumm = 0; ndec: longint = NegDef);
begin
  AddStack('Tsumm.AddIN0(Line0)');
  z:=Rnd(z,ndec);
  if z<>0 then AddIN(AddLine0,indc,z);
  DelStack;
end;

function Tsumm.AddS;
var indl,indc: longint;
begin
	AddStack('Tsumm.AddS');
{if sc='STAT' then begin
  aName:=aName;
end;}
  indl:=AddLine(sl); indc:=AddCol(sc,s_string,true).index;
  result:=aLine[indl].aColStr[indc]; aLine[indl].aColStr[indc]:=result+z;
  DelStack;
end;

function Tsumm.SetN;
begin
	AddStack('Tsumm.SetN');
{if (sl='RSV,4,НР,') and (sc='S2') then begin
  LineCnt:=LineCnt;
end;}
  result:=SetIN(AddLine(sl),AddCol(sc,s_num,true),z,ndec);
  DelStack;
end;

function Tsumm.SetIN(indl,indc: longint; z: rsumm = 0; ndec: longint = NegDef): rsumm;
//var ic: TSummColInf;
begin
	AddStack('Tsumm.SetIN');
  {if ColInf('OSN',ic) then if ic.index=indc then begin
    aName:=aName;
  end;}
  {if Rnd(z,ndec)=12 then begin
    aName:=aName;
  end;}
  result:=aLine[indl].aColNum[indc]; aLine[indl].aColNum[indc]:=Rnd(z,ndec);
  DelStack;
end;

function Tsumm.SetIN(indl: longint; const indc: TSummColInf; z: rsumm = 0; ndec: longint = NegDef): rsumm;
begin
  result:=SetIN(indl,indc.index,z,ndec);
end;

procedure Tsumm.SetN0;
begin
  AddStack('Tsumm.SetN0');
  z:=Rnd(z,ndec);
  if z<>0 then SetN(sl,sc,z);
  DelStack;
end;

function Tsumm.SetS;
begin
	AddStack('Tsumm.SetS');
{if sc='OKATO' then begin
  aName:=aName;
end;}
  result:=SetIS(AddLine(sl),AddCol(sc,s_string,true),z);
  DelStack;
end;

function Tsumm.SetIS(indl,indc: longint; const z: string): string;
begin
  AddStack('Tsumm.SetIS');
  result:=aLine[indl].aColStr[indc]; aLine[indl].aColStr[indc]:=z;
  DelStack;
end;

function Tsumm.SetIS(indl: longint; const indc: TSummColInf; const z: string): string;
begin
  result:=SetIS(indl,indc.index,z);
end;

procedure Tsumm.SetS0;
begin
  AddStack('Tsumm.SetS0');
  if not empty(z) then SetS(sl,sc,z);
  DelStack;
end;

{procedure Tsumm.SetIS0(indl,indc: longint; const z: string);
begin
  if not empty(z) then SetIS(indl,indc,z);
end;

procedure Tsumm.SetIS0(indl: longint; const indc: TSummColInf; const z: string);
begin
  if not empty(z) then SetIS(indl,indc,z);
end;}

function Tsumm.SetV(const sl,sc: string; const z: variant; ndec: longint = NegDef): variant;
begin
  AddStack('Tsumm.SetV(i)');
  if MyVarType(z)=varString then result:=SetS(sl,sc,z) else result:=SetN(sl,sc,z,ndec);
  DelStack;
end;

function Tsumm.SetV(indl: longint; const indc: TSummColInf; const z: variant; lTrimRight: boolean = false): variant;
var s: string;
begin
  AddStack('Tsumm.SetV(i)');
  case indc.rtype of
    s_num: SetIN(indl,indc,IsNilc(z,0));
    s_string: begin
      s:=IsNilc(z,'');
      if lTrimRight then TrimRightSelf(s);
      SetIS(indl,indc,s);
    end;
  end;
  DelStack;
end;

procedure Tsumm.AddLine0(const sl:string);
begin
  sLine0:=sl; iLine0:=NegDef;
end;

function Tsumm.AddLine0: longint;
begin
  if iLine0=NegDef then iLine0:=AddLine(sLine0);
  result:=iLine0;
end;

procedure Tsumm.SetIN0;
begin
  AddStack('Tsumm.SetIN0');
  z:=Rnd(z,ndec);
  if z<>0 then SetIN(AddLine0,indc,z);
  DelStack;
end;

procedure Tsumm.SetIS0;
begin
  AddStack('Tsumm.SetIS0');
  if not empty(z) then SetIS(AddLine0,indc,z);
  DelStack;
end;

function Tsumm.AddLine(const sl:string; pi: PLongint = nil):longint;
var l: longint;
begin
	AddStack('Tsumm.AddLine');
{if sl='D,24^20230301,2,' then begin
  aName:=aName;
end;}
  if not Assigned(pi) then pi:=@l;
  if not IntObjFindAdd(aName[s_line],sl,pi^,result,LineCnt) then begin
    if Length(aLine)=result then begin
      l:=IfThen(result=0,128,result shl 1); SetLength(aLine,l);
      for l:=result to l-1 do with aLine[l] do begin
        SetLength(aColNum,aColCnt[s_num,1]);
        SetLength(aColStr,aColCnt[s_string,1]);
      end;
    end;
    with aLine[result] do begin
      InitArr(aColNum,aColCnt[s_num,0],false);
      InitArr(aColStr,0,aColCnt[s_string,0]-1);
    end;
  end;
  DelStack;
end;

procedure Tsumm.AddLine(const sl: array of string);
var i: longint;
begin
  for i:=low(sl) to high(sl) do AddLine(sl[i]);
end;

function Tsumm.AddLine(const sl:string; var il: longint): boolean;
var ol: longint;
begin
  ol:=aName[s_line].Count; il:=AddLine(sl); result := aName[s_line].Count>ol;
end;

function Tsumm.AddCol(const sc: string; t: TSumType = s_string; lCheckType: boolean = false): TSummColInf;
const
  aType: array[TSumType] of record
    sErr: string;
    ColInit: byte;
  end =
    ((sErr:'числового' ; ColInit:16)
    ,(sErr:'строкового'; ColInit:8)
    );
var l,c: longint;
begin
	AddStack('Tsumm.AddCol');
{if sc='D,24^20230301,2,' then begin
  aName:=aName;
end;}
  with aName[s_col],result do
    if IgnoreSlFindAdd(aName[s_col],sc,c) then begin
      result:=ColInf(c);
      if lCheckType and (rtype<>t) then SummException(
        'Попытка присвоения колонке "'+TrimRight(sc)+'" значения '+aType[t].sErr+' типа');
    end
    else begin
      rtype:=t; index:=aColCnt[t,0]; Inc(aColCnt[t,0]);
      Objects[c]:=pointer(longword(byte(t) shl 31)+longword(index));
      if aColCnt[t,1]=index then begin
        aColCnt[t,1]:=IfThen(index=0,aType[t].ColInit,index shl 1);
        for l:=low(aLine) to high(aLine) do with aLine[l] do case t of
          s_num: begin
            SetLength(aColNum,aColCnt[t,1]);
            if l<LineCnt then ZeroMemory(@aColNum[index],SizeOf(aColNum[index])*(aColCnt[t,0]-index));
          end;
          s_string: begin
            SetLength(aColStr,aColCnt[t,1]);
            if l<LineCnt then for c:=index to aColCnt[t,0]-1 do aColStr[c]:='';
          end;
        end;
      end;
    end;
  DelStack;
end;

procedure Tsumm.AddCol(const sc: array of string; t: TSumType = s_string);
var i: longint;
begin
  for i:=low(sc) to high(sc) do AddCol(sc[i],t);
end;

function Tsumm.Value(const sc,sl: string): variant;
begin
	AddStack('Tsumm.Value(add)');
	result:=Value(AddCol(sc,s_num),AddLine(sl));
  DelStack;
end;

function Tsumm.Value(const sc,sl: string; var v: variant; const Default: variant): boolean;
var indl: longint;
  indc: TSummColInf;
begin
  AddStack('Tsumm.Value(is)');
  v:=Default; result:=false;
  if IntObjFind(aName[s_line],sl,indl) then if ColInf(sc,indc) then begin
    v:=Value(indc,indl); result:=true;
  end;
  DelStack;
end;

function Tsumm.Value(const sc,sl: string; const Default: variant): variant;
begin
  Value(sc,sl,result,Default);
end;

function Tsumm.Value(const indc: TSummColInf; indl: longint): variant;
begin
	AddStack('Tsumm.Value');
  case indc.rtype of
    s_num: result:=aLine[indl].aColNum[indc.index];
    s_string: result:=aLine[indl].aColStr[indc.index];
  end;
  DelStack;
end;

function Tsumm.SearchInit;
begin
  AddStack('Tsumm.SearchInit');
  sbeg:=s;
  if lMatch then begin
    result:=0; pr:=CompMatch;
  end
  else begin
    pr:=ProcStrComp(s,@result);
    if result=0 then pr:=CompTrue else sbeg:=LeftStr(s,result-1);
  end;
  aName[lc].Find(sbeg,n);
  DelStack;
end;

function Tsumm.ArrName(lc: TSummLineCol; var a: TArrStr; const s: string = ''; Vid: TSummArrVid = smaArr): longint;
begin
  result:=0; ArrName(lc,a,result,s,Vid);
end;

function Tsumm.ArrName(lc: TSummLineCol; var a: TArrInt; const s: string = ''; Vid: TSummArrVid = smaArr): longint;
begin
  result:=0; ArrName(lc,a,result,s,Vid);
end;

procedure Tsumm.ArrName(lc: TSummLineCol; var a: TArrStr; var result: longint; const s: string = ''; Vid: TSummArrVid = smaArr);
  procedure ChkLen(l: longint);
  begin
  	AddStack('Tsumm.ArrName(s).ChkLen');
    if Length(a)<l then SetLength(a,l);
    DelStack;
  end;
var n: longint;
	PrUsl: TProcStrComp;
  sbeg: string;
begin
	AddStack('Tsumm.ArrName(s)');
  SearchInit(s,lc,PrUsl,sbeg,n);
  if Vid=smaArr then ChkLen(result+aName[lc].Count-n);
  for n:=n to aName[lc].Count-1 do
    if not AnsiStartsStr(sbeg,aName[lc][n]) then break
    else if prUsl(aName[lc][n],s) then begin
      if Vid in [smaArr,smaFirst] then begin;
        if Vid=smaFirst then ChkLen(result+1);
	  		a[result]:=aName[lc][n];
      end;
      Inc(result);
      if Vid=smaFirst then break;
    end;
  DelStack;
end;

procedure Tsumm.ArrName(lc: TSummLineCol; var a: TArrInt; var result: longint; const s: string = ''; Vid: TSummArrVid = smaArr);
  procedure ChkLen(l: longint);
  begin
  	AddStack('Tsumm.ArrName(i).ChkLen');
    if Length(a)<l then SetLength(a,l);
    DelStack;
  end;
var n: longint;
	PrUsl: TProcStrComp;
  sbeg: string;
begin
	AddStack('Tsumm.ArrName(i)');
  SearchInit(s,lc,PrUsl,sbeg,n);
  if Vid=smaArr then ChkLen(result+aName[lc].Count-n);
  for n:=n to aName[lc].Count-1 do
    if not AnsiStartsStr(sbeg,aName[lc][n]) then break
    else if prUsl(aName[lc][n],s) then begin
      if Vid in [smaArr,smaFirst] then begin;
        if Vid=smaFirst then ChkLen(result+1);
        a[result]:=n;
      end;
      Inc(result);
      if Vid=smaFirst then break;
    end;
  DelStack;
end;

function Tsumm.CntName;
var n: longint;
	PrUsl: TProcStrComp;
  sbeg: string;
begin
	AddStack('Tsumm.CntName');
  SearchInit(s,lc,PrUsl,sbeg,n); result:=0;
  for n:=n to aName[lc].Count-1 do
    if not AnsiStartsStr(sbeg,aName[lc][n]) then break
    else if prUsl(aName[lc][n],s) then Inc(result);
  DelStack;
end;

function Tsumm.LineInf;
begin
  AddStack('Tsumm.LineInf');
  result:=IntObj(aName[s_line],nl);
  DelStack;
end;

procedure Tsumm.LineInfSelf;
begin
  nl:=LineInf(nl);
end;

function Tsumm.ColInf(nc: longint): TSummColInf;
var dw: longword;
begin
  AddStack('Tsumm.ColInf');
{if aName[s_col][nc]='STAT' then begin
  aName:=aName;
end;}
  with result do begin
    dw:=LongWordObj(aName[s_col],nc); rtype:=TSumType(dw shr 31); index:=dw and $7FFFFFFF;
  end;
  DelStack;
end;

function Tsumm.ColInf(const sc: string; var indc: TSummColInf): boolean;
var nc: longint;
begin
  result:=aName[s_col].Find(sc,nc);
  if result then indc:=ColInf(nc);
end;

function Tsumm.SumLine;
var nl,nc,nce: longint;
  nceNoCalc: boolean;
  s,sr,sbc: string;
  prc,prExcl: TProcStrComp;
  procedure ForCols;
  var i,indl,p: longint;
  begin
	  AddStack('Tsumm.SumLine.ForCols');
    if not prExcl(s,sExcl) then begin
      if IntObjFindAdd(lsSum,sr,p) then aSum[p].lAdd:=true
      else with aSum[p] do begin
        lAdd:=not(smsMore1 in Opt); InitArr(a,aColCnt[s_num,0],true);
      end;
      indl:=LineInf(nl);
      if nceNoCalc then begin
        for i:=nc to nce-1 do if not AnsiStartsStr(sbc,aName[s_col][i]) then begin
          nce:=i; break;
        end;
        nceNoCalc:=false;
      end;
      for i:=nc to nce-1 do with ColInf(i) do if rtype=s_num then
        if prc(aName[s_col][i],sc) then begin
          result:=true; IncD(aSum[p].a[index],aLine[indl].aColNum[index],ndec);
        end;
    end;
    DelStack;
  end;
var sbl: string;
	prl: TProcStrComp;
  i,n,indl: longint;
begin
	AddStack('Tsumm.SumLine');
  result:=false;
  SearchInit(sc,s_col,prc,sbc,nc); nce:=aName[s_col].Count; nceNoCalc:=true;
  prExcl:=IfThenComp(sExcl='',CompFalse,EqualShape);
  try
    if pos('#',srez)=0 then begin
      sr:=srez; SearchInit(sl,s_line,prl,sbl,nl); SetLength(aSum,aName[s_line].Count-nl);
      for nl:=nl to aName[s_line].Count-1 do begin
        s:=aName[s_line][nl];
        if not AnsiStartsStr(sbl,s) then break;
        if (s<>srez) and prl(s,sl) then ForCols;
      end;
    end
    else begin
      SetLength(aSum,aName[s_line].Count);
      for nl:=0 to aName[s_line].Count-1 do begin
        s:=aName[s_line][nl];
        if nsumsum(s,sl,srez,sr) then ForCols;
      end;
    end;
    i:=lsSum.Count; SetLength(aSum,i);
    for i:=0 to i-1 do with aSum[IntObj(lsSum,i)] do if lAdd then begin
      indl:=AddLine(lsSum[i]);
      with aLine[indl] do for n:=nc to nce-1 do with ColInf(n) do if rtype=s_num then
        if smsDec in Opt
        then IncD(aColNum[index],-a[index],ndec)
        else IncD(aColNum[index],a[index],ndec);
    end;
  finally
    lsClear;
  end;
  DelStack;
end;

function  Tsumm.SumCol;
var nl,nc,nle: longint;
  nleNoCalc: boolean;
  s,sr,sbl: string;
	prl,prExcl: TProcStrComp;
  procedure ForLines;
  var i,indl,p: longint;
    indc: TSummColInf;
  begin
  	AddStack('Tsumm.SumCol.ForLines');
    indc:=ColInf(nc);
    if (indc.rtype=s_num) and not prExcl(s,sExcl) then begin
      if IntObjFindAdd(lsSum,sr,p) then aSum[p].lAdd:=true
      else with aSum[p] do begin
        lAdd:=not(smsMore1 in Opt); InitArr(a,LineCnt,true);
      end;
      if nleNoCalc then begin
        for i:=nl to nle-1 do if not AnsiStartsStr(sbl,aName[s_line][i]) then begin
          nle:=i; break;
        end;
        nleNoCalc:=false;
      end;
      for i:=nl to nle-1 do if prl(aName[s_line][i],sl) then begin
        result:=true; indl:=LineInf(i);
        IncD(aSum[p].a[indl],aLine[indl].aColNum[indc.index],ndec);
      end;
    end;
    DelStack;
  end;
var sbc: string;
	prc: TProcStrComp;
  i,n,indl,indc: longint;
begin
	AddStack('Tsumm.SumCol');
  result:=false;
  SearchInit(sl,s_line,prl,sbl,nl); nle:=aName[s_line].Count; nleNoCalc:=true;
  prExcl:=IfThenComp(sExcl='',CompFalse,EqualShape);
  try
    if pos('#',srez)=0 then begin
      sr:=srez; SearchInit(sc,s_col,prc,sbc,nc); SetLength(aSum,aName[s_col].Count-nc);
      for nc:=nc to aName[s_col].Count-1 do begin
        s:=aName[s_col][nc];
        if not AnsiStartsStr(sbc,s) then break;
        if (s<>srez) and prc(s,sc) then ForLines;
      end;
    end
    else begin
      SetLength(aSum,aName[s_col].Count);
      for nc:=0 to aName[s_col].Count-1 do begin
        s:=aName[s_col][nc];
        if nsumsum(s,sc,srez,sr) then ForLines;
      end;
    end;
    i:=lsSum.Count; SetLength(aSum,i);
    for i:=0 to i-1 do with aSum[IntObj(lsSum,i)] do if lAdd then begin
      indc:=AddCol(lsSum[i],s_num,true).index;
      for n:=nl to nle-1 do begin
        indl:=LineInf(n);
        with aLine[indl] do
          if smsDec in Opt
          then IncD(aColNum[indc],-a[indl],ndec)
          else IncD(aColNum[indc],a[indl],ndec);
      end;
    end;
  finally
    lsClear;
  end;
  DelStack;
end;

function Tsumm.SumLineCol;
var nlbeg,nl,nc: longint;
	fl: boolean;
  indc: TSummColInf;
  rtype: TSumType;
  rd: RSumm;
  prl,prc: TProcStrComp;
  sbl,sbc,rs: string;
begin
  AddStack('Tsumm.SumLineCol');
  fl:=true; rtype:=s_num; rd:=0; rs:='';
  SearchInit(LineShape,s_line,prl,sbl,nlbeg);
  SearchInit(ColShape,s_col,prc,sbc,nc);
  for nc:=nc to aName[s_col].Count-1 do
    if not AnsiStartsStr(sbc,aName[s_col][nc]) then break
  	else if prc(aName[s_col][nc],ColShape) then begin
      indc:=ColInf(nc);
    	if fl then begin
      	fl:=false; rtype:=indc.rtype;
      end;
      for nl:=nlbeg to aName[s_line].Count-1 do
        if not AnsiStartsStr(sbl,aName[s_line][nl]) then break
        else if prl(aName[s_line][nl],LineShape) then with aLine[LineInf(nl)] do
          case rtype of
            s_num: IncD(rd,aColNum[indc.index],ndec);
            s_string: My_pr.IncD(rs,aColStr[indc.index]);
          end;
    end;
  case rtype of
    s_num: result:=rd;
    s_string: result:=rs;
  end;
  DelStack;
end;

function  Tsumm.SepLine;
var nl,ocnt: longint;
  sr: string;
begin
	AddStack('Tsumm.SepLine');
	result := pos(UnDelim,srez)=0;
  if result then AddLine(srez)
  else begin
    nl:=0;
    while nl<aName[s_line].Count do begin
      if nsumsum(aName[s_line][nl],sl,srez,sr,true) then begin
        ocnt:=LineCnt; AddLine(sr); result:=true;
        if LineCnt>ocnt then continue;
      end;
      inc(nl);
    end;
  end;
  DelStack;
end;

function TSumm.IsName;
var nl: longint;
	PrUsl: TProcStrComp;
  sbeg: string;
begin
  AddStack('TSumm.IsName');
  result:=false; SearchInit(s,lc,PrUsl,sbeg,nl);
  for nl:=nl to aName[lc].Count-1 do
    if not AnsiStartsStr(sbeg,aName[lc][nl]) then break
    else if prUsl(aName[lc][nl],s) then begin
      result:=true; break;
    end;
  DelStack;
end;

function Tsumm.Rename;
var i,j,lo,ln: longint;
  s,sbeg,snext: string;
  lShape,llast: boolean;
  pr: TProcStrComp;
  ao,an: TSegmStr;
begin
	AddStack('Tsumm.Rename');
  result:=''; lShape := SearchInit(os,lc,pr,sbeg,i,smrMatch in Opt)>0;
  if lShape and not(smrNSumSum in Opt) then ln:=LsArrFill(ns,an,',') else ln:=0;
  while i<aName[lc].Count do begin
    s:=aName[lc][i];
    if not(smrMatch in Opt) then if not AnsiStartsStr(sbeg,s) then break;
  	if pr(s,os) then begin
    	if lShape then
        if smrNSumSum in Opt then begin
          nsumsum(s,os,ns,snext); s:=snext;
        end
        else begin
          lo:=ListAsArray(s,ao,',');
          for j:=1 to min(lo,ln) do
            if an[j]<>UnDelim then ao[j]:=an[j];
          s:=ArrayAsList(ao,',',lo,false);
        end
      else StuffStrSelf(s,1,Length(os),ns);
      if aName[lc].IndexOf(s)>=0 then begin
				result:=s; break;
      end;
      llast := i=aName[lc].Count-1;
      if not llast then snext:=aName[lc][i+1];
      aName[lc].Sorted:=false; aName[lc][i]:=s; aName[lc].Sorted:=true;
      if llast then break else aName[lc].Find(snext,i);
	  end
    else Inc(i);
    if smrMatch in Opt then break;
  end;
	DelStack;
end;

procedure Tsumm.Rename1;
var i: longint;
begin
  AddStack('Tsumm.Rename1');
  with aName[lc] do if Find(os,i) then begin
    Sorted:=false; Strings[i]:=ns; Sorted:=true;
  end;
  DelStack;
end;

procedure Tsumm.DelName;
var i: longint;
  sbeg: string;
  pr: TProcStrComp;
begin
  AddStack('Tsumm.DelName');
	SearchInit(s,lc,pr,sbeg,i,lMatch);
  while i<aName[lc].Count do begin
    if not lMatch then if not AnsiStartsStr(sbeg,aName[lc][i]) then break;
  	if pr(aName[lc][i],s) then aName[lc].Delete(i) else Inc(i);
    if lMatch then break;
  end;
  DelStack;
end;

class function  Tsumm.nsumsum;
var ass,asl,asr: TSegmStr;
	i,j,lss,lsl,lsr: longint;rez:boolean;
begin
	AddStack('Tsumm.nsumsum');
  lsl:=LsArrFill(sl,asl,','); lss:=LsArrFill(s,ass,','); rez:=true;
  if lss<lsl then begin
  	rez:=false;
  end else begin
  	i:=1;
		while i<=lsl do begin
      if not((ass[i]=asl[i]) or (asl[i]=UnDelim)) then begin
        rez:=false; break;
      end;
      inc(i);
    end;
	end;
  sr:='';
  if (rez) then begin
	  lsr:=LsArrFill(srez,asr,','); i:=1;
		while i<=lsr do begin
      if copy(asr[i],1,1)=UnDelim then begin
      	j:=Int0(copy(asr[i],2,MaxInt));
        if j=0 then j:=i;
        if j<=length(ass) then My_pr.IncD(sr,IfThen(i=1,ass[j],','+ass[j])) else My_pr.IncD(sr,',');
      end
      else My_pr.IncD(sr,IfThen(i=1,asr[i],','+asr[i]));
      inc(i);
    end;
  end;
  result:=not empty(sr);
  if result and not lEq then result := s<>sr;
  DelStack;
end;

class procedure Tsumm.SummException;
begin
  raise ESummException.Create(Message);
end;

procedure Tsumm.SaveTo(f: TCustomBuf; const aln: array of longint; ll: longint);
var al,ac: TArrInt;
  il,ic,lc: longint;
  aci: TArrSummColInf;
  v: variant;
begin
  AddStack('Tsumm.SaveTo');
  f.Write(ll>0,stBoolean); SetLength(al,ll); Dec(ll);
  for il:=0 to ll do begin
    f.WriteString(aName[s_line][aln[il]]+IfThen(il=ll,#0,#1)); al[il]:=LineInf(aln[il]);
  end;
  lc:=ArrName(s_col,ac); SetLength(aci,lc); f.Write(lc>0,stBoolean); Dec(lc);
  for ic:=0 to lc do begin
    aci[ic]:=ColInf(ic); f.Write(2+byte(aci[ic].rtype),stByte);
    f.WriteString(aName[s_col][ac[ic]]+IfThen(ic=lc,#0,#1));
  end;
  for il:=0 to ll do
    for ic:=0 to lc do begin
      v:=Value(aci[ic],al[il]);
      if not empty(v) then begin
        f.Write(il,stInteger); f.Write(ic,stInteger);
        case aci[ic].rtype of
          s_num: f.Write(v,stDouble);
          s_string: f.WriteStr(TrimRight(v));
        end;
      end;
    end;
  f.Write(-1,stInteger);
  DelStack;
end;

procedure Tsumm.SaveTo(f: TCustomBuf; const s: string = '');
var al: TArrInt;
  ll: longint;
begin
  ll:=ArrName(s_line,al,s); SaveTo(f,al,ll);
end;

procedure Tsumm.LoadFrom;
var al: TArrInt;
  aci: array of record
    ci: TSummColInf;
		nt: TSumType;
  end;
  c: char;
  s: string;
  i,j: longint;
  t: TSumType;
  flt: boolean;
  v: variant;
begin
  AddStack('Tsumm.LoadFrom');
  if f.Active then begin
    SetLength(s,10);
    if f.Read(stBoolean) then begin
      SetLength(al,10); i:=0; j:=0;
      while f.ReadChar(c) do begin
        if c in [#0,#1] then begin
          if Length(al)=j then SetLength(al,j shl 1);
          al[j]:=AddLine(LeftStr(s,i));
          if c=#0 then break;
          Inc(j); i:=0;
        end
        else begin
          if Length(s)=i then SetLength(s,i shl 1);
          Inc(i); s[i]:=c;
        end;
      end;
    end;
    if f.Read(stBoolean) then begin
      SetLength(aci,10); i:=0; j:=0; flt:=true; t:=s_num;
      while f.ReadChar(c) do begin
        if c in [#0,#1] then begin
          if Length(aci)=j then SetLength(aci,j shl 1);
          with aci[j] do begin
            nt:=t; ci:=AddCol(LeftStr(s,i),t);
          end;
          if c=#0 then break;
          Inc(j); i:=0; flt:=true;
        end
        else if flt then begin
          t:=TSumType(byte(c)-2); flt:=false;
        end
        else begin
          if Length(s)=i then SetLength(s,i shl 1);
          Inc(i); s[i]:=c;
        end;
      end;
    end;
    repeat
      i:=f.Read(stInteger);
      if i=-1 then break;
      j:=f.Read(stInteger);
      with aci[j] do begin
        case nt of
          s_num: v:=f.Read(stDouble);
          s_string: v:=f.ReadStr;
        end;
        SetV(al[i],ci,v);
      end;
    until false;
  end;
  DelStack;
end;

procedure Tsumm.FormSummExec;
begin
  AddStack('Tsumm.FormSummExec');
  MyTypes.FormSummExec(sl,sc,Capt,CaptX,CaptY,ProcHead,PrmHead,PrmNum,Self,ProcShow,NoColWidthsCorr);
  DelStack;
end;

end.
