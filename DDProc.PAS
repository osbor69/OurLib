unit DDProc;

interface

{$I LIBTEST}
uses Classes,DB,Math,
  MyTypes,My_pr,RecVal,RecDB,MulQry;

type
  TDDatSetOpt = set of (ddToEnd,ddModified,ddNoChkBig,ddLog);
  TDDatStrDateList = (ddstrD2,ddstrPref); TDDatStrDateOpt = set of TDDatStrDateList;
  TDDatAddVarOpt = set of (ddaEmptyD1ForFirstCod,ddaValueEqTrue);

  TDynamicDat = class(TObject)
  private
    FCurCod: string;
    lsKv,lsLast: TStringList;
    lsBuf: TStrVarList;
    aKv: array of TDDatKvInfo;
    aLast: array of TDDatLastInfo;
    Rec: TRecVal;
    aKvEmptyD1ForFirstCod: TArrStr;
    procedure lsBufCreate;
    procedure SetCurCod(const Value: string);
    procedure SetMaxLenCod(Value: byte);
    function BufAutoLoad(const kv: string; var cod: string; var l: longint): boolean;
    function GetValue(const kv: string; d: TDateTime; inf: PDDatKvInfo; var i: longint; lDop: boolean = false): variant; overload;
    function GetValBuf(i: longint; lDop: boolean): variant;
  public
    Vid: longint;
    FMaxLenCod: byte;
    lCodLoad: boolean;
    CurDate: TDateTime;
    OnBeforeModify: TDDatBeforeModifyEvent;
    OnModify,OnAfterModify: TDDatModifyEvent;
    OnValDef: procedure(Sender: TObject; const kv: string; var result: variant);
    OnBufInf: function(Sender: TObject; const kv: string): boolean;
    constructor Create(AVid: longint);
    destructor Destroy; override;
    procedure ClearVars;
    procedure AddVar(const ckv: string; const valdef: variant; tp: TDDatType; td2: TDDatD2;
      ft: TFieldType; Len: Word = 0; Dec: byte = 0; Opt: TDDatAddVarOpt = [];
      tzn: TDDatZnType = ddznSimple; const SelVid: string = ''; const SelVName: string = '');
    function GetValue(const kv: string; lDop: boolean = false): variant; overload;
    function GetValue(const kv: string; inf: PDDatKvInfo; lDop: boolean = false): variant; overload;
    function GetValue(const kv: string; d: TDateTime; lDop: boolean = false): variant; overload;
    function GetValue(const kv: string; d: TDateTime; inf: PDDatKvInfo; lDop: boolean = false): variant; overload;
    procedure GetValues(const kv: string; var aValues: TDDatValues; lDop: boolean = false); overload;
    procedure GetValues(var aValues: TDDatValues; lDop: boolean = false); overload;
    procedure GetValues(const akv: array of string; var aValues: TDDatValues; lDop: boolean = false); overload;
    function SetValue(const kv: string; const zn: variant; d1: TDateTime; d2: TDateTime = 0;
      Opt: TDDatSetOpt = []): boolean;
    function FirstNoEmp(const kv: string; db,de: TDateTime): variant;
    function GetKvInfo(const ckv: string; var inf: PDDatKvInfo): boolean; overload;
    function GetKvInfo(const ckv: string): PDDatKvInfo; overload;
    procedure BufClear;
    function GetValDef(const kv: string; inf: PDDatKvInfo): variant;
    function GetLastInfo(const kv: string; inf: PDDatKvInfo): TDDatLastInfo;
    function BeforeModify(const kv: string): boolean; dynamic;
    procedure DispLast(oi,ni: longint);
    procedure SetFldLsCurVR(const kv: string; r: TCustomRec);
    procedure Modify(const kv: string); dynamic;
    procedure AfterModify(const kv: string); dynamic;
    procedure IfThenModify(Proc: TDDatModifyEvent; const kv: string);
    class procedure QryOpen(const where: string; lCodLoad: boolean = true; const tbldop: string = '');
    class procedure QryBufLoad(const cCod: string; lCodLoad: boolean = true);
    class procedure QryClose(lCodLoad: boolean = true);
    class function QryActive(lCodLoad: boolean = true): boolean;
    class function Period(d1,d2: TDateTime; inf: PDDatKvInfo; lLabel: boolean = true): string;
    class function StrDate(d: TDateTime; inf: PDDatKvInfo; Opt: TDDatStrDateOpt = []): string;
    class procedure OperWhere(const clist,vlist: array of variant; const where: string;
      Proc: TNotifyEvent = nil);
    class procedure DelWhere(const where: string; Proc: TNotifyEvent = nil);
    class procedure KvRdbPref(const vvid,vkv: variant; var vid: longint; var kv: string);
    class procedure DDatCalculate(Sender: TCustomRec; lApp: boolean);
    function GetWhere(const kv: string): string;
    class function MemCreate(q: TMulQuery = nil): TMemGKList;
    property CurCod: string read FCurCod write SetCurCod;
    property MaxLenCod: byte read FMaxLenCod write SetMaxLenCod;
  end;

  TDDatLoadProc = procedure(const cod: string; vid: longint; const kv: string; inf: PDDatKvInfo;
    d1,d2: TDateTime; const va: variant);

  TDDatBufLoadOper = (dboBegin,dboNoEof,dboNext,dboEnd,dboInf,dboCod,dboVid,dboKv,dboD1,dboD2,dboZN,dboDop);

  TDDatBufLoadProc = procedure(var result: variant; lCodLoad: boolean; const ACod: string;
    op: TDDatBufLoadOper; inf: PDDatKvInfo; const av: array of variant);
  TDDatBufLoadProcArr = array of TDDatBufLoadProc;

  TDDatGetOper = (ddgGet,ddgPrim);
  TDDatGetOpt = set of(ddgDop,ddgNoUnit,ddgCngPer,ddgNoInPer,ggdEmp);

const
  aDDatType: array[TDDatType] of record
    lbl,ms: string;
  end =
    ((lbl:'Дата' ; ms:'dd/mm/yyyy')
    ,(lbl:'Месяц'; ms:'mm/yyyy')
    ,(lbl:'Месяц'; ms:'mm/yyyy')
    ,(lbl:'Год'  ; ms:'yyyy')
    );
  sDDatD2 = [dd2Default];

var
  aDDat: array of TDynamicDat;
  DDatMaxCount,DDHintVid: longint;
  DDatStrDateProc: procedure(Source: TDateTime; inf: PDDatKvInfo; var Dest: string; var Def: boolean);
  DDatWhereProc,DDatDopFldProc: TStringEvent;
  DDatLoadProc: TDDatLoadProc;
  aDDatBufLoadProc: TDDatBufLoadProcArr;

function DDat: TRecDB;
function IsDDat(vid: longint; var dd: TDynamicDat): boolean;
function IfThen(AValue: boolean; ATrue: TDDatStrDateList): TDDatStrDateOpt; overload;
function c_ddatget(Oper: TDDatGetOper; vid: longint; const kv: string; const cPer: variant;
  Opt: TDDatGetOpt = []; db: TDateTime = 0.0; de: TDateTime = MaxDouble;
  const Capt: string = ''; const Dlm: string = ','; const cFmt: string = ''): variant; overload;
function c_ddatcng(const va: variant; db: TDateTime = 0.0; de: TDateTime = MaxDouble; lSum: boolean = false): variant; overload;

implementation

uses Windows,SysUtils,StrUtils,Variants,Forms,
  Inter;

var lKV: byte;
  FDDat: TRecDB;
  aq: array[boolean] of record
    q: TMulQuery;
    lsm: TMemGkList;
  end;

procedure DDatGetMemPrm(Sender: TRecDB; i: longint; fa: TFldMemoAttr; var faPrm: string);
var dd: TDynamicDat;
  inf: PDDatKvInfo;
begin
  AddStack('DDProc.DDatGetMemPrm');
  if fa=famSel then if IsDDat(Sender[fDDVid],dd) then if dd.GetKvInfo(Sender[fDDKV],inf) then faPrm:=inf.SelVid+'.'+inf.SelVName;
  DelStack;
end;

function DDat;
begin
  AddStack('DDProc.DDat');
  if TRecDB.Init(FDDat,result,tDDAT,'Значение с таким началом периода уже есть.',TDynamicDat.DDatCalculate)
  then with FDDat do begin
    NameRec:=tDDAT; OnGetMemPrm:=DDatGetMemPrm;
  end;
  DelStack;
end;

function IsDDat;
begin
  AddStack('DDProc.IsDDat');
  if InRange(vid,1,high(aDDat)) then dd:=aDDat[vid] else dd:=nil;
  result:=Assigned(dd);
  DelStack;
end;

function IfThen(AValue: boolean; ATrue: TDDatStrDateList): TDDatStrDateOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

procedure ArrValDop(var v: variant);
var l: longint;
  va: variant;
begin
  AddStack('DDProc.ArrValDop');
  l:=StrCount(',',DDatDopFldProc)+2; va:=VarArrayCreate([1,l],varVariant); va[1]:=v;
  while l>1 do begin
    va[l]:=''; Dec(l);
  end;
  v:=va;
  DelStack;
end;

function BufLoadProc(pr: TDDatBufLoadProc; lCodLoad: boolean; const ACod: string;
  op: TDDatBufLoadOper; inf: PDDatKvInfo; const av: array of variant): variant;
begin
  AddStack('DDProc.BufLoadProc');
  case op of
    dboBegin,dboInf: result:=true;
    dboNoEof: result:=false;
    dboCod,dboKv,dboZn,dboDop: result:='';
    dboVid: result:=0;
    dboD1: result:=DateEmpty;
    dboD2: result:=DateBig;
  else result:=null;
  end;
  pr(result,lCodLoad,ACod,op,inf,av);
  DelStack;
end;

function c_ddatget(Oper: TDDatGetOper; vid: longint; const kv: string; const cPer: variant;
  Opt: TDDatGetOpt = []; db: TDateTime = 0.0; de: TDateTime = MaxDouble;
  const Capt: string = ''; const Dlm: string = ','; const cFmt: string = ''): variant;
var j: longint;
  ozn: variant;
  procedure AddRes(d: TDateTime; const zn: variant);
  begin
    AddStack('DDProc.c_ddatget.AddRes');
    if (ddgNoUnit in Opt) or not CompVar(zn,ozn) then begin
      ozn:=zn; Inc(j); result[j]:=ArrVarToVar([d,zn]);
    end;
    DelStack;
  end;
var inf: PDDatKvInfo;
  i,k: longint;
  d,d1,pb,pe,psb,pse: TDateTime;
  ad: TDDatValues;
  Per,vdef: variant;
  s,s1,sd,Fmt: string;
  FromTbl,lPer: boolean;
  Prm: TFmtNum;
  p: PFldInf;
  pr: TDDatBufLoadProc;
  rdb: TRecDBDef;
  lsm: TMemGkList;
  q: TMulQuery;
begin
  AddStack('DDProc.c_ddatget');
  case Oper of
    ddgGet: Per:=cPer;
    ddgPrim: Per:=ArrVarToVar([db,iif(de>DateBig,DateBig,de)]);
  end;
  j:=0; pb:=DateEmpty; pse:=DateEmpty; //Variable might not have been initialized
  with aDDat[vid] do begin
    if MyVarType(Per)=V_DATE then result:=GetValue(kv,Per,ddgDop in Opt)
    else begin
      FromTbl:=CompVar(Per,true); lPer:=FromTbl;
      if FromTbl then begin
        for i:=1 to high(aDDatBufLoadProc) do begin
          pr:=aDDatBufLoadProc[i];
          if (BufLoadProc(pr,false,'',dboVid,nil,[])=vid) and (BufLoadProc(pr,false,'',dboKv,nil,[])=kv) then begin
            FromTbl:=false; break;
          end;
        end;
        if FromTbl then begin
          q:=TMulQuery.CreateConnection;
          try
            q.SetArrayList(sC_LIST,[fDDD1,'D2']); q.AddArrayList(sC_LIST,aDDatZnFld);
            if ddgDop in Opt then if Assigned(DDatDopFldProc) then q.AddArgList(sC_LIST,DDatDopFldProc);
            q.PartSelect(tDDAT,'',GetWhere(kv),
              q.GetList([tDDAT+'.'+fDDCod,tDDAT+'.'+fDDVid,tDDAT+'.'+fDDKv,tDDAT+'.'+fDDD1]));
            if not q.Eof then
              if GetKvInfo(kv,inf) then begin
                lsm:=MemCreate(q); VarArrLenInit(result,j,q.RecordCount);
                while not q.Eof do begin
                  vdef:=DDStr2Var(q,2,lsm,inf);
                  if ddgDop in Opt then begin
                    ArrValDop(vdef);
                    if Assigned(DDatDopFldProc) then begin
                      k:=2;
                      for i:=2+lDDatMemo to q.FieldCount-1 do begin
                        vdef[k]:=TrimRight(q.Fields[i].AsString); Inc(k);
                      end;
                    end;
                  end;
                  Inc(j); result[j]:=ArrVarToVar([q.Fields[0].AsDateTime,q.Fields[1].AsDateTime,vdef]); q.Next;
                end;
              end;
          finally
            q.Free;
          end;
        end;
      end;
      if not FromTbl then begin
        VAddEndSelf(Per,2,DateEmpty);
        if empty(Per[2]) then Per[2]:=DateBig;
        pb:=Per[1]; pe:=Per[2];
        if ddgNoInPer in Opt then begin
          psb:=DateEmpty; pse:=DateBig;
        end
        else begin
          psb:=pb; pse:=pe;
        end;
        d:=DateEmpty-1; GetValues(kv,ad,ddgDop in Opt);
        if GetKvInfo(kv,inf) then vdef:=inf.valdef else vdef:=null;
        if ddgDop in Opt then ArrValDop(vdef);
        if Length(ad)>0 then begin
          VarArrLenInit(result,j,Length(ad)+1); ozn:=null;
          for i:=low(ad) to high(ad) do begin
            d1:=ad[i].d;
            if d1>pe then begin
              if ddgNoInPer in Opt then begin
                pse:=d1-1; AddRes(d1,ad[i].zn);
              end;
              break;
            end;
            if d1<pb then begin
              vdef:=ad[i].zn;
              if ddgNoInPer in Opt then psb:=d1;
            end
            else if d1>d then begin
              if (j=0) and (d1>psb) then AddRes(psb,vdef);
              d:=d1; AddRes(d1,ad[i].zn);
            end;
          end;
        end;
        if j=0 then begin
          j:=1; result:=ArrVarToVar([ArrVarToVar([pb,vdef])]);
        end;
      end;
      VarArrLenSet(result,j); AndD(lPer,not FromTbl);
      if (Oper=ddgGet) and not lPer then lPer := ddgCngPer in Opt;
      if lPer then for i:=1 to j do begin
        if i=j then d:=pse else d:=result[i+1][1]-1;
        result[i]:=ArrVarToVar([result[i][1],d,result[i][2]]);
      end;
    end;
  end;
  if Oper=ddgPrim then
    if (MyVarType(result)=varArray) and Assigned(inf) then begin
      s:=''; Fmt:=ReplVar(cFmt,aDDatType[inf.tp].ms);
      if RdbDDVidSeek(vid,rdb) then p:=PFldInfGet(rdb.DWVarName(kv)) else p:=nil;
      try
        for i:=1 to j do begin
          if not(ggdEmp in Opt) and empty(result[i][2]) then continue;
          if Assigned(p) then sd:=FldBrCalc(result[i][2],p,true)
          else begin
            lPer:=true;
            if Assigned(DDGetTrans) then DDGetTrans(inf,result[i][2],sd,lPer);
            if lPer then case inf.ft of
              ftInteger,ftFloat: begin
                Prm:=FmtNum; Prm.FracEmp:=frempNo; Prm.FracCnt:=inf.Dec; sd:=FmtNum(result[i][2],Prm);
              end;
              ftBoolean: sd:=bRus2Str(result[i][2]);
              ftDate: sd:=dtoc(result[i][2]);
            else sd:=result[i][2];
            end;
          end;
          s1:=IfThen(result[i][1]<>pb,'с '+FormatDateTime(Fmt,result[i][1]));
          if not(ggdEmp in Opt) then begin
            d:=DateEmpty;
            if i<j then
              if empty(result[i+1][2]) then d:=IncPer(result[i+1][1],inf,-1);
            if not empty(d) then IncD(s1,' по '+FormatDateTime(Fmt,d));
          end;
          IncD(s1,' '+Trim(sd)); TrimSelf(s1);
          if s1<>'' then begin
            IncD(s1,Capt); TrimSelf(s1);
            if s1<>'' then IncD(s,Dlm+s1);
          end;
        end;
      finally
        if Assigned(p) then Dispose(p);
      end;
      result:=Copy(s,Length(Dlm)+1,MaxInt);
    end
    else result:='';
  DelStack;
end;

function c_ddatget(var av: array of variant):variant; overload;
var Oper: TDDatGetOper;
  vid,i: longint;
  kv,Capt,Dlm,Fmt: string;
  Opt: TDDatGetOpt;
  db,de: TDateTime;
begin
  Oper:=av[0]; TDynamicDat.KvRdbPref(av[1],av[2],vid,kv); Opt:=[];
  i:=0; db:=DateEmpty; de:=DateEmpty; // Variable might not have been initialized
  case Oper of
    ddgGet: begin
      i:=7;
      if IsNilc(av[4],false) then Include(Opt,ddgDop);
      if not IsNilc(av[5],true) then Include(Opt,ddgNoUnit);
      if IsNilc(av[6],false) then Include(Opt,ddgCngPer);
    end;
    ddgPrim: begin
      i:=9; db:=IsNilc(av[3],DateEmpty); de:=IsNilc(av[4],DateBig);
      if IsNilc(av[6],false) then Include(Opt,ggdEmp);
      Capt:=IsNil(av[5],''); Dlm:=IsNil(av[7],','); Fmt:=IsNilc(av[8],'');
    end;
  end;
  if not IsNilc(av[i],true) then Include(Opt,ddgNoInPer);
  result:=c_ddatget(Oper,vid,kv,av[3],Opt,db,de,Capt,Dlm,Fmt);
end;

function c_ddatcng(const va: variant; db: TDateTime = 0.0; de: TDateTime = MaxDouble; lSum: boolean = false): variant;
var ls,ls1: TIntVarList;
  i,i1,i2,j,l,h,n: longint;
  a: TArrVar;
  d1,d2: longint;
  dt1,dt2: TDateTime;
  v,v1: variant;
  sum: Double;
  kv: string;
begin
  AddStack('DDProc.c_ddatcng');
  if de>DateBig then de:=DateBig;
  result:=false; d1:=trunc(db); d2:=trunc(de);
  if d2>=d1 then begin
    ls:=TIntVarList.Create([ilsSorted],10); ls1:=nil;
    try
      if MyVarType(va)=varArray then begin
        l:=VarArrayHighBound(va,1); ls1:=TIntVarList.Create([ilsSorted],10);
      end
      else begin
        l:=0; ls.Add(d1,false);
      end;
      SetLength(a,l); i1:=low(a);
      for i:=1 to l do begin
        v:=va[i];
        if MyVarType(v)=varArray then begin
          case MyVarType(v[1]) of
            varDate: begin // Период активности
              dt1:=v[1]; dt2:=v[2]; j:=0;
              v:=VarArrayCreate([1,IfThen(not empty(dt1),1)+1+IfThen(dt2<DateBig,1)],varVariant);
              if not empty(dt1) then begin
                Inc(j); v[j]:=ArrVarToVar([DateEmpty,false]);
              end;
              Inc(j); v[j]:=ArrVarToVar([dt1,true]);
              if dt2<DateBig then begin
                Inc(j); v[j]:=ArrVarToVar([dt2+1,false]);
              end;
            end;
            varArray:;
          else
            TDynamicDat.KvRdbPref(v[1],v[2],j,kv); v:=c_ddatget(ddgGet,j,kv,ArrVarToVar([d1,d2])); // ДДАН_ЗНАЧ
          end;
          h:=VarArrayHighBound(v[1],1); // Определение различий массива изменений и массива периодов
          if MyVarType(v[1][h])=varArray then begin
            j:=VarArrayHighBound(v[1][h],1);
            a[i1]:=VarArrayCreate([1,j],varVariant); a[i1][1]:=VarBlank(v[1][h][1]);
            while j>1 do begin
              a[i1][j]:=''; Dec(j);
            end;
          end
          else a[i1]:=VarBlank(v[1][h]);
          ls1.Clear;
          for j:=1 to VarArrayHighBound(v,1) do ls1.Add(trunc(ReplDateSmallEmpty(v[j][1])),v[j][h],i2);
          for j:=0 to ls1.Count-1 do begin
            v1:=ls1.Value[j];
            if j>0 then
              if CompVar(ls1.Value[j-1],v1) then continue;
            if ls.Add(ls1[j],null,i2) then begin
              InitArrLen(v,1,l,null); ls.Value[i2]:=v;
            end
            else v:=ls.Value[i2];
            v[i]:=v1; ls.Value[i2]:=v;
          end;
        end
        else a[i1]:=null;
        Inc(i1);
      end;
      i2:=ls.Count-1;
      n:=low(a);
      for i:=1 to l do begin
        for j:=0 to i2 do begin
          v:=ls.Value[j];
          if IsNil(v[i]) then begin
            v[i]:=a[n]; ls.Value[j]:=v;
          end
          else a[n]:=v[i];
        end;
        Inc(n);
      end;
      while i2>=0 do
        if ls[i2]>d2 then Dec(i2) else break;
      if i2>=0 then begin
        i1:=i2;
        while i1>0 do
          if ls[i1]<d1 then break else Dec(i1);
        VarArrLenInit(result,i,i2-i1+1);
        while i1<=i2 do begin
          dt1:=ls[i1];
          if i=0 then MaxSelf(dt1,d1);
          if i1=i2 then dt2:=d2 else dt2:=ls[i1+1]-1;
          if dt2>=dt1 then begin
            Inc(i); v:=ls.Value[i1];
            if lSum then begin
              sum:=0;
              if MyVarType(v)=varArray then for j:=VarArrayLowBound(v,1) to VarArrayHighBound(v,1) do IncD(sum,v[j]);
              v:=sum;
            end;
            result[i]:=ArrVarToVar([dt1,dt2,v]);
          end;
          Inc(i1);
        end;
        VarArrLenSet(result,i);
      end;
    finally
      ls.Free; ls1.Free;
    end;
  end;
  DelStack;
end;

function c_ddatcng(var av: array of variant): variant; overload;
begin
  result:=c_ddatcng(av[1],IsNilc(av[2],DateEmpty),IsNilc(av[3],DateBig),IsNilc(av[4],false));
end;

function c_set(var av: array of variant):variant;
var inf: PDDatKvInfo;
  i,j,vid,r: longint;
  kv: string;
  d1,d1e: variant;
  d2,dd2: TDateTime;
  aDel: TArrStr;
  ls: TIntegerList;
  fl: boolean;
  Opt: TDDatSetOpt;
begin
  AddStack('DDProc.c_set');
  result:=true; TDynamicDat.KvRdbPref(av[1],av[2],vid,kv); d1:=av[3]; i:=MyVarType(d1);
  with aDDat[vid] do begin
    if (FMaxLenCod>0) and empty(FCurCod) then raise EInterAnyError.Create(
      'Не определён код источника динамических данных');
    if lsKv.IndexOf(kv)<0 then Delete(kv,1,Pos('_',kv));
    if GetKvInfo(kv,inf) then with GetQuery do begin
      if i=V_DATE then begin
        d2:=IsNilc(av[4],DateBig); Opt:=[];
        if IsNilc(av[6],false) then begin
          PartSelect(tDDAT,[fDDD1,'D2',fRECNO],GetWhere(kv),GetList([fDDCod,fDDVid,fDDKv,fDDD1]));
          d1e:=IncPer(d2,inf); SetLength(aDel,RecordCount); i:=0;
          ls:=TIntegerList.Create([ilsSorted,ilsUnSigned]);
          try
            while not Eof do begin
              if InRange(Fields[0].AsDateTime,d1,d1e) then begin
                Include(Opt,ddModified); dd2:=Fields[1].AsDateTime; r:=Fields[2].AsInteger; fl:=true;
                if dd2>d2 then
                  if not ls.IgnoreFindAdd(trunc(dd2),j) then begin
                    fl:=false; ls.Objects[j]:=pointer(r);
                  end;
                if fl then begin
                  aDel[i]:=Vtos(r); Inc(i);
                end;
              end;
              Next;
            end;
            for j:=ls.Count-1 downto 0 do begin
              if j=0 then dd2:=d2 else dd2:=ls[j-1];
              IncPerSelf(dd2,inf.tp); r:=ls.IntObj(j);
              if QryFind(dd2) and (Fields[2].AsInteger<>r) then begin
                aDel[i]:=Vtos(r); Inc(i);
              end
              else UpdateTable(tDDAT,[fDDD1],[dd2],RecnoWhere(r));
            end;
            DDat.DelRec(aDel,i);
          finally
            ls.Free;
          end;
        end;
        result:=SetValue(kv,av[5],d1,d2,Opt);
      end
      else begin
        result:=BeforeModify(kv);
        if result then try
          DDat.DelRec(GetWhere(kv)); Modify(kv);
        finally
          AfterModify(kv);
        end;
        if result and (i=varArray) then for i:=VarArrayLowBound(d1,1) to VarArrayHighBound(d1,1) do
          if not SetValue(kv,d1[i][3],d1[i][1],IsNilc(d1[i][2],DateBig),[ddNoChkBig]) then begin
            result:=false; break;
          end;
      end;
      FreeQuery;
    end;
  end;
  DelStack;
end;

function c_firstnoemp(var av: array of variant):variant;
var vid: longint;
  kv: string;
begin
  AddStack('DDProc.c_firstnoemp');
  TDynamicDat.KvRdbPref(av[1],av[2],vid,kv);
  result:=aDDat[vid].FirstNoEmp(kv,IsNilc(av[3],DateEmpty),IsNilc(av[4],DateBig));
  DelStack;
end;

function c_per(var av: array of variant):variant;
var i: longint;
  function dChk(n: byte; dErr: TDateTime; const sErr: string): TDateTime;
  begin
    result:=av[1][i][n];
    if result=dErr then raise EInterAnyError.Create(sErr);
  end;
var l,lr: longint;
  d1,d2: TDateTime;
  zn: variant;
begin
  AddStack('DDProc.c_per');
  if MyVarType(av[1])=varDate then begin
    av[1]:=ArrVarToVar([ArrVarToVar([av[1],av[2],null])]); result:=c_per(av);
  end
  else begin
    VarArrLenInit(result,l,10,@lr);
    for i:=VarArrayLowBound(av[1],1) to VarArrayHighBound(av[1],1) do begin
      d1:=dChk(1,DateEmpty,'Слишком малое значение начала периода');
      d2:=dChk(2,DateBig,'Слишком большое значение конца периода');
      zn:=av[1][i][3];
      while d1<d2 do begin
        VarArrLenAdd(result,l,lr); result[l]:=ArrVarToVar([d1,TDateTime(min(eom(d1),d2)),zn]);
        d1:=bom(IncMonth(d1));
      end;
    end;
    VarArrLenSet(result,l);
  end;
  DelStack;
end;

function c_prm(var av: array of variant):variant;
var inf: PDDatKvInfo;
  t: longint;
  kv: string;
begin
  AddStack('DDProc.c_prm');
  TDynamicDat.KvRdbPref(av[1],av[2],t,kv);
  if aDDat[t].GetKvInfo(kv,inf) then with inf^ do begin
    case ft of
      ftInteger: t:=V_INT;
      ftBoolean: t:=V_BOOL;
      ftFloat: t:=V_FLOAT;
      ftDate: t:=V_DATE;
    else t:=V_STRING;
    end;
    result:=ArrVarToVar([t,Len,Dec,tp,td2,valdef]);
  end
  else result:=null;
  DelStack;
end;

function LastInfoDef(inf: PDDatKvInfo): TDDatLastInfo;
begin
  AddStack('DDProc.LastInfoDef');
  with result do begin
    d1:=DateSmall; d2:=DateBig; val:=inf.valdef;
  end;
  DelStack;
end;

{ TDynamicDat }
constructor TDynamicDat.Create;
begin
  AddStack('TDynamicDat.Create');
  if Length(aDDat)=0 then SetLength(aDDat,DDatMaxCount+1);
  Vid:=AVid; aDDat[Vid]:=Self; lsKv:=SortStrListCreate;
  SetLength(aKv,10); SetLength(aLast,10);
  Rec:=TRecVal.Create(Application.MainForm); Rec.NameRec:=DynNmDb(Vid);
  DelStack;
end;

destructor TDynamicDat.Destroy;
begin
  AddStack('TDynamicDat.Destroy');
  lsKv.Free; BufClear;
  inherited Destroy;
  DelStack;
end;

procedure TDynamicDat.ClearVars;
begin
  AddStack('TDynamicDat.ClearVars');
  lsKv.Clear; Rec.Fields.Clear;
  DelStack;
end;

procedure TDynamicDat.AddVar;
var kv: string;
  p: PDDatKvInfo;
  n: longint;
begin
  AddStack('TDynamicDat.AddVar');
  kv:=Trim(ckv);
  if not IntObjFindAdd(lsKv,kv,n) then if Length(aKv)=n then SetLength(aKv,n shl 1);
  p:=@aKv[n]; p.valdef:=valdef; p.tp:=tp; p.td2:=td2; p.ft:=UnDataType(ft); p.Len:=Len; p.Dec:=Dec;
  p.tzn:=tzn; p.SelVid:=SelVid; p.SelVName:=SelVName; p.ValueEqTrue:=ddaValueEqTrue in Opt;
  Rec.CreateFld(kv,p.ft,Len,valdef);
  if ddaEmptyD1ForFirstCod in Opt then AddFrom(aKvEmptyD1ForFirstCod,kv);
  DelStack;
end;

procedure TDynamicDat.BufClear;
begin
  AddStack('TDynamicDat.BufClear');
  FreeAndNil(lsBuf); FreeAndNil(lsLast);
  if Vid=DDHintVid then DDHintVid:=0;
  DelStack;
end;

procedure DDBufClearAll(lCodLoad: boolean = false);
var i: longint;
begin
  AddStack('DDProc.DDBufClearAll');
  for i:=1 to high(aDDat) do
    if Assigned(aDDat[i]) then if aDDat[i].lCodLoad=lCodLoad then aDDat[i].BufClear;
  DelStack;
end;

function TDynamicDat.GetLastInfo;
var n: longint;
begin
  AddStack('TDynamicDat.GetLastInfo');
  if IntObjFind(lsLast,Padr(kv,lKV)+FCurCod,n) then result:=aLast[n] else result:=LastInfoDef(inf);
  DelStack;
end;

class procedure TDynamicDat.QryOpen;
var a: TArrStr;
  i,l: longint;
  w: string;
begin
  AddStack('TDynamicDat.QryOpen');
  TMulQuery.CreateConnection(aq[lCodLoad].q,Application.MainForm,nil);
  if lCodLoad then begin
    SetLength(a,Length(aDDat)); l:=0;
    for i:=1 to high(aDDat) do if Assigned(aDDat[i]) then if aDDat[i].lCodLoad then begin
      FreeAndNil(aDDat[i].lsLast); a[l]:=Vtos(i); Inc(l);
    end;
    w:=FldInList(tDDAT+'.'+fDDVid,a,l);
  end
  else w:='';
  with aq[lCodLoad],q do begin
    SetArrayList(sC_LIST,[fDDCod,fDDVid,fDDKv,fDDD1,'D2']); AddArrayList(sC_LIST,aDDatZnFld);
    if Assigned(DDatDopFldProc) then AddArgList(sC_LIST,DDatDopFldProc);
    PartSelect(GetList([tDDAT,tbldop]),'',DlmBetween([where,w,IfThenStr(DDatWhereProc)],sAND),
      GetList([tDDAT+'.'+fDDCod,tDDAT+'.'+fDDVid,tDDAT+'.'+fDDKv,tDDAT+'.'+fDDD1]));
    lsm:=MemCreate(q);
    if lKV=0 then lKV:=Fields[2].Size;
  end;
  DelStack;
end;

procedure QryBufLoadProc(var result: variant; lCodLoad: boolean; const ACod: string;
  op: TDDatBufLoadOper; inf: PDDatKvInfo; const av: array of variant);
var cod: string;
  d: TDynamicDat;
begin
  AddStack('DDProc.QryBufLoadProc');
  with aq[lCodLoad],q do case op of
    dboBegin: if lCodLoad then begin
      DDBufClearAll(lCodLoad); QryFind(ACod,q);
    end;
    dboNoEof: begin
      result:=not Eof;
      if result and lCodLoad then begin
        cod:=TrimRight(Fields[0].AsString); result := cod=ACod;
        if not result and (Length(cod)>Length(ACod)) then result:=AnsiStartsStr(ACod+',',cod);
      end;
    end;
    dboNext: Next;
    dboInf: begin
      d:=PointerVar(av[0]);
      if Assigned(d.OnBufInf) then result:=d.OnBufInf(d,av[1]);
    end;
    dboCod: result:=Fields[0].AsString;
    dboVid: result:=Fields[1].AsInteger;
    dboKv: result:=Fields[2].AsString;
    dboD1: result:=Fields[3].AsDateTime;
    dboD2: result:=Fields[4].AsDateTime;
    dboZn: result:=DDStr2Var(q,5,lsm,inf);
    dboDop: result:=Fields[av[0]+lDDatMemo+3].AsString;
  end;
  DelStack;
end;

procedure TDynamicDat.lsBufCreate;
begin
  AddStack('TDynamicDat.lsBufCreate');
  lsBuf:=TStrVarList.Create; lsBuf.CaseSensitive:=true;
  DelStack;
end;

class procedure TDynamicDat.QryBufLoad;
var pr: TDDatBufLoadProc;
  ACod: string;
  inf: PDDatKvInfo;
  function Proc(op: TDDatBufLoadOper; const av: array of variant): variant;
  begin
    result:=BufLoadProc(pr,lCodLoad,ACod,op,inf,av);
  end;
  function vaGet(const v: variant): variant;
  var i,l: longint;
  begin
    AddStack('TDynamicDat.QryBufLoad.vaGet');
    if Assigned(DDatDopFldProc) then begin
      l:=aq[lCodLoad].q.FieldCount-4-lDDatMemo;
      result:=VarArrayCreate([1,l],varVariant); result[1]:=v;
      for i:=2 to l do result[i]:=TrimRight(Proc(dboDop,[i]));
    end
    else result:=v;
    DelStack;
  end;
var ls: TIntegerList;
  a: array of record
    v,va: variant;
    d2: TDateTime;
  end;
  la: longint;
  function lsAdd(d1,d2: TDateTime; const v: variant; lSetDop: boolean): longint;
  var n: longint;
  begin
    AddStack('TDynamicDat.QryBufLoad.LsAdd');
    if not ls.IntObjFindAdd(trunc(ReplDateSmallEmpty(d1)),result,n,la) then
      if Length(a)=n then SetLength(a,n shl 1);
    a[n].va:=vaGet(v); a[n].v:=v; a[n].d2:=d2;
    DelStack;
  end;
var kv,cod: string;
  Vid,i,j,ipr,n,n1: longint;
  d: TDynamicDat;
  ad: TArrBool;
  v: variant;
  d1,d2: TDateTime;
begin
  AddStack('TDynamicDat.QryBufLoad');
  i:=Length(aDDat); SetLength(ad,i); ZeroMemory(@ad[0],i*SizeOf(ad[0])); SetLength(a,10); la:=0;
  ls:=TIntegerList.Create([ilsSorted,ilsUnSigned]);
  try
    ACod:=TrimRight(cCod);
    for ipr:=low(aDDatBufLoadProc) to high(aDDatBufLoadProc) do begin
      pr:=aDDatBufLoadProc[ipr];
      if Proc(dboBegin,[]) then begin
        while Proc(dboNoEof,[]) do begin
          Vid:=Proc(dboVid,[]);
          if InRange(Vid,1,high(aDDat)) then begin
            d:=aDDat[Vid];
            if Assigned(d) then begin
              if not Assigned(d.lsBuf) then d.lsBufCreate;
              SortStrListCreate(d.lsLast);
              if lCodLoad then d.CurCod:=StuffString(d.CurCod,1,Length(ACod),ACod);
            end;
          end
          else d:=nil;
          while Proc(dboNoEof,[]) do
            if Proc(dboVid,[])=Vid then
              if Assigned(d) then begin
                kv:=Proc(dboKv,[]); inf:=nil;
                if Proc(dboInf,[Longint(d),kv]) then d.GetKvInfo(kv,inf);
                while Proc(dboNoEof,[]) do
                  if (Proc(dboVid,[])=Vid) and (Proc(dboKv,[])=kv) then
                    if Assigned(inf) then begin
                      cod:=Proc(dboCod,[]);
                      if not IntObjFindAdd(d.lsLast,Padr(kv,lKV)+Padr(cod,d.FMaxLenCod),n1) then begin
                        if Length(d.aLast)=n1 then SetLength(d.aLast,n1 shl 1);
                        d.aLast[n1]:=LastInfoDef(inf);
                      end;
                      while Proc(dboNoEof,[]) do begin
                        if not((Proc(dboVid,[])=Vid) and (Proc(dboKv,[])=kv)
                        and (Proc(dboCod,[])=cod)) then break;
                        d1:=Proc(dboD1,[]); d2:=DDGetD2(d1,Proc(dboD2,[]),inf);
                        if d2>=d1 then begin
                          v:=Proc(dboZn,[]);
                          if Assigned(DDatLoadProc) then DDatLoadProc(cod,Vid,kv,inf,d1,d2,vaGet(v));
                          if d1>=d.aLast[n1].d1 then begin
                            d.aLast[n1].d1:=d1; d.aLast[n1].d2:=d2; d.aLast[n1].val:=v;
                          end;
                          i:=lsAdd(d1,d2,v,true); v:=d.GetValDef(kv,inf);
                          for j:=0 to i-1 do begin
                            n:=ls.IntObj(j);
                            if a[n].d2>d2 then v:=a[n].v;
                          end;
                          Inc(i);
                          while i<ls.Count do begin
                            if ls[i]>d2 then break;
                            v:=a[ls.IntObj(i)].v; ls.Delete(i);
                          end;
                          if d2<DateBig then lsAdd(IncPer(d2,inf),DateEmpty,v,false);
                        end;
                        Proc(dboNext,[]);
                      end;
                      if ls.Count>0 then begin
                        ad[Vid]:=true; cod:=Padr(kv,lKV)+Padr(cod,d.FMaxLenCod);
                        for i:=0 to ls.Count-1 do
                          d.lsBuf.IgnoreFindAdd(cod+dtos(ls[i]),a[ls.IntObj(i)].va);
                        ls.Clear;
                      end;
                    end
                    else Proc(dboNext,[])
                  else break;
              end
              else Proc(dboNext,[])
            else break;
        end;
        Proc(dboEnd,[]);
      end;
    end;
  finally
    ls.Free;
  end;
  for Vid:=1 to high(ad) do if ad[Vid] then with aDDat[Vid] do
    for j:=low(aKvEmptyD1ForFirstCod) to high(aKvEmptyD1ForFirstCod) do begin
      kv:=Padr(aKvEmptyD1ForFirstCod[j],lKv); lsBuf.Find(kv,i); lsBuf.Sorted:=false; ACod:='';
      while i<lsBuf.Count do begin
        if not AnsiStartsStr(kv,lsBuf[i]) then break;
        cod:=Copy(lsBuf[i],lKv+1,FMaxLenCod);
        if cod<>ACod then begin
          ACod:=cod; lsBuf[i]:=kv+cod+dtos(DateEmpty);
        end;
        Inc(i);
      end;
      lsBuf.Sorted:=true;
    end;
  DelStack;
end;

class procedure TDynamicDat.QryClose;
begin
  AddStack('TDynamicDat.QryClose');
  with aq[lCodLoad] do if Assigned(q) then q.Close;
  DelStack;
end;

class function TDynamicDat.QryActive;
begin
  AddStack('TDynamicDat.QryActive');
  result:=aq[lCodLoad].q.ActiveNoNil;
  DelStack;
end;

function TDynamicDat.BufAutoLoad;
begin
  AddStack('TDynamicDat.BufAutoLoad');
  if not lCodLoad and not Assigned(lsBuf) then begin
    lsBufCreate;
    QryOpen(tDDAT+'.'+fDDVid+'='+Vtos(Vid),false); FreeAndNil(lsLast); QryBufLoad('',false); QryClose(false);
  end;
  result:=Assigned(lsBuf); cod:=AnsiUpperCase(Padr(kv,lKV)+FCurCod); l:=lKV+FMaxLenCod;
  DelStack;
end;

function TDynamicDat.GetValBuf;
begin
  AddStack('TDynamicDat.GetValBuf');
  result:=lsBuf.Value[i];
  if Assigned(DDatDopFldProc)<>lDop then
    if lDop then ArrValDop(result) else result:=result[1];
  DelStack;
end;

function TDynamicDat.GetValue(const kv: string; lDop: boolean = false): variant;
begin
  result:=GetValue(kv,CurDate,lDop);
end;

function TDynamicDat.GetValue(const kv: string; inf: PDDatKvInfo; lDop: boolean = false): variant;
begin
  result:=GetValue(kv,CurDate,inf,lDop);
end;

function TDynamicDat.GetValue(const kv: string; d: TDateTime; lDop: boolean = false): variant;
var inf: PDDatKvInfo;
begin
  if GetKvInfo(kv,inf) then result:=GetValue(kv,d,inf,lDop) else result:=null;
end;

function TDynamicDat.GetValue(const kv: string; d: TDateTime; inf: PDDatKvInfo; lDop: boolean = false): variant;
var i: longint;
begin
  result:=GetValue(kv,d,inf,i,lDop);
end;

function TDynamicDat.GetValue(const kv: string; d: TDateTime; inf: PDDatKvInfo; var i: longint; lDop: boolean = false): variant;
var {s,}cod: string;
  l: longint;
  fl: boolean;
begin
  AddStack('TDynamicDat.GetValue');
  if BufAutoLoad(kv,cod,l) then begin
    fl:=lsBuf.Find(cod+dtos(d),i);
{if Vid=22 then begin
    if not fl and (i>0) then s:=AnsiUpperCase(LeftStr(lsBuf[i-1],l)) else s:='';
ProtocolStrAdd(protDebug,ArrayAsList(
['Ошибка РД_И'
,'"'+kv+'"'
,'"'+cod+'"'
,IntToStr(l)
,dtos(d)
,IntToStr(i)
,bStr[fl]
,bStr[i>0]
,Int2Str(lsBuf.Duplicates)
,'"'+s+'"'
],';')+CRLF+lsBuf.Text);
end;}
    if not fl and (i>0) then begin
      Dec(i); fl := AnsiUpperCase(LeftStr(lsBuf[i],l))=cod;
    end;
  end
  else begin
    i:=-1; fl:=false;
  end;
  if fl then result:=GetValBuf(i,lDop)
  else begin
    result:=GetValDef(kv,inf);
    if lDop then ArrValDop(result);
  end;
  DelStack;
end;

function DDGetValue(vid: longint; const kv: string; lDop: boolean = false): variant;
begin
  AddStack('DDProc.DDGetValue');
  result:=aDDat[vid].GetValue(kv,lDop);
  DelStack;
end;

function DDSetValue(vid: longint; const kv: string; const zn: variant): boolean;
begin
  AddStack('DDProc.DDSetValue');
  with aDDat[vid] do result:=SetValue(kv,zn,CurDate);
  DelStack;
end;

{function DDGetKvInfo(vid: longint; const kv: string; var inf: PDDatKvInfo): boolean;
begin
  AddStack('DDProc.DDGetKvInfo');
  result:=aDDat[vid].GetKvInfo(kv,inf);
  DelStack;
end;}

procedure TDynamicDat.GetValues(const kv: string; var aValues: TDDatValues; lDop: boolean = false);
var cod: string;
  i,j,l: longint;
begin
  AddStack('TDynamicDat.GetValues');
  j:=0;
  if BufAutoLoad(kv,cod,l) then begin
    lsBuf.Find(cod,i); SetLength(aValues,lsBuf.Count-i);
    while i<lsBuf.Count do
      if AnsiUpperCase(LeftStr(lsBuf[i],l))=cod then begin
        aValues[j].kv:=kv;
        aValues[j].d:=stod(Copy(lsBuf[i],l+1,MaxInt)); aValues[j].zn:=GetValBuf(i,lDop);
        Inc(i); Inc(j);
      end
      else break;
  end;
  SetLength(aValues,j);
  DelStack;
end;

procedure TDynamicDat.GetValues(var aValues: TDDatValues; lDop: boolean = false);
begin
  GetValues([],aValues,lDop);
end;

procedure TDynamicDat.GetValues(const akv: array of string; var aValues: TDDatValues; lDop: boolean = false);
var cod: string;
  i,j,l: longint;
  lAll: boolean;
begin
  AddStack('TDynamicDat.GetValues(akv)');
  j:=0;
  if BufAutoLoad('',cod,l) then begin
    SetLength(aValues,lsBuf.Count); lAll := Length(akv)=0;
    for i:=0 to lsBuf.Count-1 do if Copy(lsBuf[i],lKV+1,FMaxLenCod)=FCurCod then begin
      cod:=LeftStr(lsBuf[i],lKV);
      if lAll or AnsiMatchText(Trim(cod),akv) then with aValues[j] do begin
        kv:=TrimRight(cod); d:=stod(Copy(lsBuf[i],l+1,MaxInt)); zn:=GetValBuf(i,lDop); Inc(j);
      end;
    end;
  end;
  SetLength(aValues,j);
  DelStack;
end;

function TDynamicDat.SetValue;
var inf: PDDatKvInfo;
  lMod: boolean;
  function znEq(const zn: variant; d1: TDateTime): boolean;
  var i: longint;
    fl: boolean;
    q: TMulQuery;
    lsm: TMemGkList;
  begin
    AddStack('TDynamicDat.SetValue.znEq');
    result := GetValue(kv,d1,inf,i)=zn;
    if result then if AnsiMatchText(kv,aKvEmptyD1ForFirstCod) then begin
      if i<0 then fl:=true else fl:=empty(stod(Copy(lsBuf[i],lKv+FMaxLenCod+1,MaxInt)));
      if fl then begin
        q:=TMulQuery.CreateConnection;
        try
          q.PartSelect(tDDAT,[aDDatZnFld[inf.tzn]],GetWhere(kv)+sAND+fDDD1+'<='+q.VarTos(d1),fDDD1);
          if q.IsRecords then begin
            if inf.tzn=ddznSimple then lsm:=nil else lsm:=TMemGKList.Create(q);
            q.Last; result := DDStr2Var(q.Fields[0],lsm,inf)=zn;
          end
          else result:=false;
        finally
          q.Free;
        end;
      end;
    end;
    DelStack;
  end;
var q: TMulQuery;
  function qGet: TMulQuery;
  begin
    AddStack('TDynamicDat.SetValue.qGet');
    TMulQuery.CreateConnection(q,nil,nil); result:=q;
    DelStack;
  end;
  procedure vSet(const zn: variant; d1: TDateTime);
  var lDel,lSeek,fl1: boolean;
    szn: string;
  begin
    AddStack('TDynamicDat.SetValue.vSet');
    lDel:=IsNil(zn); fl1:=true;
    if not lDel then begin
      szn:=DDVar2Str(zn,inf);
      if DoDDatSetValProc(dsvEqDel) and not(ddNoChkBig in Opt) then fl1 := not znEq(zn,d1);
    end;
    if fl1 then if d1<=DateBig then with DDat do begin
      lSeek:=Seek(GetWhere(kv)+sAND+TblFldName(fDDD1)+'='+qGet.VarToS(d1));
      if lSeek then fl1:=DoDDatSetValProc(dsvCanCng) else fl1:=true;
      if fl1 then
        if lDel then begin
          if lSeek then begin
            DelRec; lMod:=true;
          end;
        end
        else begin
          lMod:=true;
          if not lSeek then begin
            NewRec([newrNoDoNewRec]);
            Value[fDDCod]:=FCurCod; Value[fDDVid]:=Vid; Value[fDDKv]:=kv; Value[fDDD1]:=d1;
          end;
          Value['D2']:=DDGetD2(d1,d2,inf);
          Value[aDDatZnFld[inf.tzn]]:=szn;
          DoDDatSetValProc(dsvUpdate); AppUpdRec(ddLog in Opt);
        end;
    end;
    DelStack;
  end;
var lsm: TMemGKList;
begin
  AddStack('TDynamicDat.SetValue');
  if GetKvInfo(kv,inf) then begin
    q:=nil; result:=BeforeModify(kv);
    if result then try
      if empty(d1) or (inf.td2=dd2All) then d1:=DateSmall;
      IncPerSelf(d1,inf.tp,0); lMod := ddModified in Opt;
      if (inf.td2=dd2Period) and DoDDatSetValProc(dsvEqDel) and CompVar(zn,inf.valdef)
      then vSet(null,d1)
      else if not(ddNoChkBig in Opt) and (inf.td2=dd2Big) and DoDDatSetValProc(dsvEqDel) then begin
        if lMod then begin
          Modify(kv); lMod:=false;
        end;
        vSet(iif(znEq(zn,IncPer(d1,inf,-1)),null,zn),d1);
        with qGet do begin
          PartSelect(tDDAT,[],GetWhere(kv)+sAND+tDDAT+'.'+fDDD1+'>'+VarToS(d1),tDDAT+'.'+fDDD1);
          if not Eof then begin
            lsm:=MemCreate(q);
            if ddToEnd in Opt then begin
              lMod:=true;
              while not Eof do begin
                lsm.GetFromQuery; DoDDatSetValProc(dsvCanCng); Next;
              end;
              DDat.DelRec(Arg[sWHERE]);
            end
            else begin
              lsm.GetFromQuery;
              if CompVar(DDStr2Var(DDat[aDDatZnFld[inf.tzn]],inf),zn) then begin
                DoDDatSetValProc(dsvCanCng); DDat.DelRec;
              end;
            end;
          end;
        end;
      end
      else vSet(zn,d1);
      if lMod then Modify(kv);
    finally
      AfterModify(kv); q.Free;
    end;
  end
  else result:=false;
  DelStack;
end;

function TDynamicDat.BeforeModify;
begin
  AddStack('TDynamicDat.BeforeModify');
  result:=true;
  if Assigned(OnBeforeModify) then OnBeforeModify(Self,kv,result);
  DelStack;
end;

procedure TDynamicDat.DispLast;
begin
  AddStack('TDynamicDat.DispLast');
  aLast[ni]:=aLast[oi];
  DelStack;
end;

procedure TDynamicDat.SetFldLsCurVR;
var i: longint;
  rv: TDWVidRec;
begin
  AddStack('TDynamicDat.SetFldLsCurVR');
  if r is TRecDBDef then with TRecDBDef(r) do if DynamicVid>0 then for i:=0 to FldDef.Count-1 do begin
    rv:=DWSToRec(i);
    if rv.Name=kv then begin
      FldLsCurVR:=rv; break;
    end;
  end;
  DelStack;
end;

procedure TDynamicDat.Modify;
var s: string;
  procedure Disp(ls: TStringList; Proc: TSLObjIndProc);
  var i: longint;
  begin
    AddStack('TDynamicDat.Modify.Disp');
    if Assigned(ls) then begin
      s:=Padr(kv,lKV)+FCurCod; ls.Find(s,i);
      while i<ls.Count do
        if AnsiStartsStr(s,ls[i]) then
          if Assigned(Proc) then SLObjIndDel(ls,i,Proc) else ls.Delete(i)
        else break;
    end;
    DelStack;
  end;
begin
  AddStack('TDynamicDat.Modify');
  if lCodLoad then begin
    s:=Padr(kv,lKV)+FCurCod; Disp(lsBuf,nil); Disp(lsLast,DispLast);
    QryOpen(GetWhere(kv),false); QryBufLoad('',false); QryClose(false);
  end
  else begin
    BufClear; PswdSendUpd(updDDat);
  end;
  IfThenModify(OnModify,kv);
  DelStack;
end;

procedure TDynamicDat.AfterModify;
begin
  AddStack('TDynamicDat.AfterModify');
  IfThenModify(OnAfterModify,kv);
  DelStack;
end;

procedure TDynamicDat.IfThenModify;
begin
  if Assigned(Proc) then Proc(Self,kv);
end;

procedure TDynamicDat.SetCurCod;
begin
  AddStack('TDynamicDat.SetCurCod');
  FCurCod:=Padr(Value,FMaxLenCod);
  DelStack;
end;

procedure TDynamicDat.SetMaxLenCod;
begin
  AddStack('TDynamicDat.SetMaxLenCod');
  FMaxLenCod:=Value; CurCod:=FCurCod;
  DelStack;
end;

function TDynamicDat.FirstNoEmp;
var inf: PDDatKvInfo;
  av: TDDatValues;
  i: longint;
begin
  AddStack('TDynamicDat.FirstNoEmp');
  if GetKvInfo(kv,inf) then begin
    result:=inf.valdef; GetValues(kv,av);
    for i:=low(av) to high(av) do with av[i] do begin
      if d>de then break;
      result:=zn;
      if (d>=db) and not empty(result) then break;
    end;
  end
  else result:=null;
  DelStack;
end;

function TDynamicDat.GetKvInfo(const ckv: string; var inf: PDDatKvInfo): boolean;
var n: longint;
begin
  AddStack('TDynamicDat.GetKvInfo');
  result:=IntObjFind(lsKv,Trim(ckv),n);
  if result then inf:=@aKv[n] else inf:=nil;
  DelStack;
end;

function TDynamicDat.GetKvInfo(const ckv: string): PDDatKvInfo;
begin
  GetKvInfo(ckv,result);
end;

function TDynamicDat.GetValDef;
begin
  AddStack('TDynamicDat.GetValDef');
  result:=inf.valdef;
  if Assigned(OnValDef) then OnValDef(Self,kv,result);
  DelStack;
end;

class function TDynamicDat.Period;
begin
  AddStack('TDynamicDat.Period');
  result:=IfThen(lLabel,': ')+StrDate(d1,inf);
  if inf.td2 in sDDatD2
  then IncL(result,IfThen(lLabel,'Период'),' - '+StrDate(d2,inf,[ddstrD2]))
  else if lLabel then IncL(result,aDDatType[inf.tp].lbl);
  DelStack;
end;

class function TDynamicDat.StrDate;
var i: byte;
  Def: boolean;
begin
  AddStack('TDynamicDat.StrDate');
  Def:=true;
  if Assigned(DDatStrDateProc) then DDatStrDateProc(d,inf,result,Def);
  if Def then result:=FormatDateTime(aDDatType[inf.tp].ms,d);
  if IfThen(ddstrD2 in Opt,d=DateBig,d<=DateSmall) then begin
    if ddstrPref in Opt then result:=''
    else for i:=1 to Length(result) do if result[i]<>DateSeparator then result[i]:=' ';
  end
  else if ddstrPref in Opt then IncL(result,IfThen(ddstrD2 in Opt,'по','с')+' ');
  DelStack;
end;

class procedure TDynamicDat.OperWhere;
var q: TMulQuery;
  lsm: TMemGkList;
begin
  AddStack('TDynamicDat.OperWhere');
  q:=TMulQuery.CreateConnection;
  try
    q.PartSelect(tDDAT,[],where);
    if not q.Eof then begin
      lsm:=MemCreate(q);
      while not q.Eof do begin
        lsm.GetFromQuery; DoDDatSetValProc(dsvCanCng); IfThenNotify(Proc,DDat); q.Next;
      end;
      if Length(clist)=0 then DDat.DelRec(where)
      else begin
        q.SetArrayList(sC_LIST,clist); q.SetArrayList(sV_LIST,vlist); q.ExecPart(sUW_TABLE);
      end;
    end;
  finally
    q.Free;
  end;
  DelStack;
end;

class procedure TDynamicDat.DelWhere;
begin
  AddStack('TDynamicDat.DelWhere');
  OperWhere([],[],where,Proc);
  DelStack;
end;

class procedure TDynamicDat.KvRdbPref;
var a: TNamePrimStr;
  rdb: TRecDBDef;
  lvid: boolean;
begin
  AddStack('TDynamicDat.KvRdbPref');
  kv:=IsNilc(vkv,''); lvid:=true;
  if StrDivDlm('_',kv,a) then if TRecDBDef.SeekDWPrefix(a[1],rdb) then begin
    lvid:=false; vid:=IsNilc(vvid,rdb.DynamicVid);
    if rdb.DynamicVid=vid then kv:=a[2];
  end;
  if lvid then if MyVarType(vvid,true)=varDouble then vid:=vvid;
  DelStack;
end;

class procedure TDynamicDat.DDatCalculate;
begin
  AddStack('TDynamicDat.DDatCalculate');
  DoDDatSetValProc(dsvCalculate);
  DelStack;
end;

function TDynamicDat.GetWhere;
begin
  result:=DDGetWhere(FCurCod,vid,kv);
end;

class function TDynamicDat.MemCreate;
var ar: array[0..0] of TRecDB;
begin
  AddStack('DDProc.MemCreate');
  ar[0]:=DDat; result:=TMemGkList.Create(ar,q);
  DelStack;
end;

procedure DDSelCodeGet(vid: longint; const kv: string; var SelVid,SelVName: string);
var inf: PDDatKvInfo;
  dd: TDynamicDat;
begin
  AddStack('DDProc.DDSelCodeGet');
  if IsDDat(vid,dd) then if dd.GetKvInfo(kv,inf) then begin
    SelVid:=inf.SelVid; SelVName:=inf.SelVName;
  end;
  DelStack;
end;

procedure DDRecDBProc(Sender: TRecDBDef; Oper: TDDRecDBOper; const av: array of variant);
const aftSel: array[TSelType] of TFieldType = (ftMemo,ftInteger);
var dd: TDynamicDat;
  pd: PFldDefInf;
begin
  AddStack('DDProc.DDRecDBProc');
  with Sender do case Oper of
    ddrdbOpenRec: begin
      pd:=PointerVar(av[0]);
      with pd^,Inf do aDDat[DynamicVid].AddVar(Name,pd.AValue,DDatType,DDatD2,
        iif(AType=dwtSel,aftSel[SelType],aDWFld[AType].tp),Len,Dec,[],DDZnType(Inf),SelVid,SelVName);
    end;
    ddrdbSetDDat: if InRange(DynamicVid,1,DDatMaxCount) then begin
      if not IsDDat(DynamicVid,dd) then dd:=TDynamicDat.Create(DynamicVid);
      with dd do begin
        MaxLenCod:=DDatMaxLenCod; lCodLoad:=DDatIsCod;
        OnBeforeModify:=OnDDatBeforeModify; OnModify:=OnDDatModify; OnAfterModify:=OnDDatAfterModify; ClearVars;
      end;
    end;
    ddrdbCloseRec: if IsDDat(DynamicVid,dd) then dd.ClearVars;
  end;
  DelStack;
end;

procedure LogTrnsValProc(var Prm: TLogTrnsValPrm);
var dd: TDynamicDat;
begin
  AddStack('DDProc.LogTrnsValProc');
  if LogEqual(Prm,tDDAT) then with Prm do
    if IsDDat(Sender[fDDVid],dd) then
      if AnsiMatchText(nmf,[fDDD1,'D2']) then begin
        val:=TDynamicDat.StrDate(ctod(val),dd.GetKvInfo(Sender[fDDKV]),IfThen(nmf='D2',ddstrD2));
        lBreak:=true;
      end
      else if nmf=fDDZN then
        if dd.GetKvInfo(Sender[fDDKV]).ft=ftBoolean then begin
          val:=bRus[StrToBoolean(val)]; lBreak:=true;
        end;
  DelStack;
end;

procedure Final;
var i: longint;
begin
  AddStack('DDProc.finalization');
  for i:=1 to high(aDDat) do aDDat[i].Free;
  DelStack;
end;

initialization
  AddStack('DDProc.initialization');
  MyTypes.DDBufClearAll:=DDBufClearAll; MyTypes.DDGetValue:=DDGetValue; MyTypes.DDSetValue:=DDSetValue;
  {MyTypes.DDGetKvInfo:=DDGetKvInfo;} MyTypes.DDSelCodeGet:=DDSelCodeGet;
  RecDB.DDRecDBProc:=DDRecDBProc;
  SetLength(aDDatBufLoadProc,1); aDDatBufLoadProc[0]:=QryBufLoadProc;
  SetPrim(tDDAT,'Динамические данные');
	with TInter do begin
    SetFunction('Динамические данные',1700);
    SetFunction('ДДАН_ЗНАЧ','Возвращает значения динамических данных за указанный период',
      ['[Груп: целое]','[Вид: строка = ""]','[Период: дата|массив|логическое = '+vFalse+']',
      '[Доп: логическое = '+vFalse+']','[ОбъедЗнач: логическое = '+vTrue+']','[ИзмВПер: логическое = '+vFalse+']',
      '[ОгранПер: логическое = '+vTrue+']'],
      ['NU','CU','DALU','LU','LU','LU','LU'],c_ddatget,ddgGet,1701);
    SetFunction('ДДАН_УСТ','Устанавливает значения динамических данных за указанный период',
      ['[Груп: целое]','[Вид: строка = ""]','[Начало: дата|массив = {}]','[Конец: дата = ДАТА_МАКС]',
      '[Знач: любое]','[Заменить: логическое = '+vFalse+']'],
      ['NU','CU','DAU','DU','','LU'],c_set,null,1702,'L');
    SetFunction('ДДАН_ИЗМЕН','Объединение изменений нескольких динамических данных',
      ['Измен: массив','[Начало: дата = 0.0.0]','[Конец: дата = ДАТА_МАКС]','[Сумма: логическое = '+vFalse+']'],
      ['A','DU','DU','LU'],c_ddatcng,null,1703,'A');
    SetFunction('ДДАН_ДНИ','Количество дней с указанным значением динамических данных за указанный период',
      [],[],nil,null);
    SetFunction('ДДАН_ПРИМ','Строка изменений значения динамического данного за указанный период',
      ['[Груп: целое]','[Вид: строка = ""]','[Начало: дата = 0.0.0]','[Конец: дата = ДАТА_МАКС]',
      '[Подсказка: строка = ""]','[Пустые: логическое = '+vFalse+']','[Разделитель: строка = ","]',
      '[Формат: строка]','[ОгранПер: логическое = '+vTrue+']'],
      ['NU','CU','DU','DU','CU','LU','CU','CU','LU'],c_ddatget,ddgPrim,1704,'C');
    SetFunction('ДДАН_НЕПУСТ','Возвращает первое непустое значение динамических данных за указанный период',
      ['[Груп: целое]','[Вид: строка = ""]','[Начало: дата = 0.0.0]','[Конец: дата = ДАТА_МАКС]'],
      ['NU','CU','DU','DU'],c_firstnoemp,null);
    SetFunction('ДДАН_ПЕРИОД','Разбивка периодов динамических данных по месяцам',
      ['Периоды: массив~Начало: дата','~Конец: дата'],
      ['AD','DU'],c_per,null,0,'A');
    SetFunction('ДДАН_ПАРАМ','Параметры динамических данных',
      ['[Груп: целое]','[Вид: строка = ""]'],['NU','CU'],c_prm,null);
  end;
  LogTrnsValProcAdd(LogTrnsValProc);
  DelStack;
finalization
  Final;
end.
