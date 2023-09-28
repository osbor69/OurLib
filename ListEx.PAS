unit ListEx;

interface

uses Classes, 
  MyTypes;

type
  PLEItem = ^TLEItem;
  TLEItem = record
    leiPointer,leiObject: pointer;
  end;
  TLEItemList = array[0..(MaxInt div 16)]of TLEItem;
  TListEx = class;
  TListExSortCompare = function(le: TListEx; ix1,ix2: longint): longint;
  TListEx = class
  private
    FLEList: ^TLEItemList;
    FCount: longint;
    FCapacity: longint;
    FSorted: Boolean;
    FDuplicates: TDuplicates;
    procedure LEGrow;
    procedure LESetCapacity(newCapacity: longint);
    procedure LESetSorted(value: Boolean);
    procedure LEQuickSort(L,R: longint; leSortCompare: TListExSortCompare);
    procedure LEExchangeItems(ix1,ix2: longint);
    procedure LEInsertItem(ix: longint; p,obj: pointer);
    function LEComparePointers(p1,p2: pointer): longint;
    function LEGet(ix: longint): TObject;
    procedure LEPut(ix: longint; p: TObject);
    function LEGetObject(ix: longint): pointer;
    procedure LEPutObject(ix: longint; obj: pointer);
    function LEGetBool(ix: longint): boolean;
    procedure LEPutBool(ix: longint; b: boolean);
  public
    constructor Create(notToSort: boolean=false);
    destructor Destroy; override;
    function Add(p: pointer): longint;
    function AddInt(i: longint): longint;
    function AddIntInt(i,obj: longint): longint;
    function AddObject(p,obj: pointer): longint;
    function AddBool(p: pointer; b: boolean=false): longint;
    function IgnoreFindAdd(p: pointer; var ix: longint): boolean;
    function Find(p: pointer; var ix: longint): boolean;
    function FindAdd(i: longint; var ix: longint): boolean;
    function FindInt(i: longint): boolean; overload;
    function FindInt(i: longint; var ix: longint): boolean; overload;
    function IndexOf(p: pointer): longint;
    procedure Clear;
    procedure Delete(ix: longint);
    function Remove(p: pointer; obj: ppointer=nil): boolean;
    procedure Sort;
    procedure CustomSort(leSortCompare: TListExSortCompare);
    function FindTruePointer(o: PObject): boolean;
    function TruePointer(p: pointer): boolean;
    procedure AsStrArray(var sa: TArrStr);
    function AsIntArray: TArrInt;
    class procedure FreeWithObjects(const ale: array of TListEx);
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    property Sorted: Boolean read FSorted write LESetSorted;
    property Capacity: longint read FCapacity write LESetCapacity;
    property Count: longint read FCount;
    property Pointers[ix: longint]: TObject read LEGet write LEPut; default;
    property Objects[ix: longint]: pointer read LEGetObject write LEPutObject;
    property Bools[ix: longint]: boolean read LEGetBool write LEPutBool;
    procedure FreeLimit(f: TObject);
  end;

implementation

uses Math,
  My_pr;

procedure TListEx.LEGrow;
var delta: longint;
begin
  if (FCapacity>64) then delta:=(FCapacity div 4) else delta:=IfThen(FCapacity>8,16,4);
  LESetCapacity(FCapacity+delta);
end;

procedure TListEx.LESetCapacity;
begin
  ReallocMem(FLEList,newCapacity*SizeOf(TLEItem));
  FCapacity:=newCapacity;
end;

function TListEx.LEGet;
begin
  if (ix<0)or(ix>=FCount) then result:=nil else result:=FLEList^[ix].leiPointer;
end;

procedure TListEx.LEPut;
begin
  if (not Sorted) then begin
    if (ix>=0)and(ix<FCount) then FLEList^[ix].leiPointer:=p;
  end;
end;

function TListEx.LEGetObject;
begin
  if (ix<0)or(ix>=FCount) then result:=nil else result:=FLEList^[ix].leiObject;
end;

procedure TListEx.LEPutObject;
begin
  if (ix>=0)and(ix<FCount) then FLEList^[ix].leiObject:=obj;
end;

procedure TListEx.Delete;
begin
  if (ix>=0)and(ix<FCount) then begin
    Dec(FCount);
    if (ix<FCount) then begin
      System.Move(FLEList^[ix+1],FLEList^[ix],(FCount-ix)*SizeOf(TLEItem));
    end;
  end;
end;

function TListEx.Remove;
var k: longint;
begin
  k:=IndexOf(p);
  result:=k>=0;
  if (result) then begin
    if (obj<>nil) then obj^:=Objects[k];
    Delete(k);
  end;
end;

procedure TListEx.FreeLimit;
var k: longint;
begin
  if Assigned(Self) then begin
    k:=IndexOf(f);
    if k>=0 then Delete(k);
  end;
  f.Free;
end;

function Bool2Pointer(b: boolean): pointer;
begin
  result:=pointer(ord(b));
end;

function TListEx.LEGetBool;
begin
  result:=LEGetObject(ix)=Bool2Pointer(true);
end;

procedure TListEx.LEPutBool;
begin
  LEPutObject(ix,Bool2Pointer(b));
end;

function TListEx.AddBool;
begin
  result:=AddObject(p,Bool2Pointer(b));
end;

procedure TListEx.LESetSorted;
begin
  if (FSorted<>value) then begin
    if (value) then Sort;
    FSorted:=value;
  end;
end;

function TListEx.LEComparePointers;
begin
  result:=longint(p1)-longint(p2);
end;

function ListExComparePointers(le: TListEx; ix1,ix2: longint): longint;
begin
  result:=le.LEComparePointers(le.FLEList^[ix1].leiPointer,le.FLEList^[ix2].leiPointer);
end;

procedure TListEx.Sort;
begin
  CustomSort(ListExComparePointers);
end;

procedure TListEx.CustomSort;
begin
  if (not FSorted)and(FCount>1) then begin
    LEQuickSort(0,FCount-1,leSortCompare);
  end;
end;

procedure TListEx.LEQuickSort;
var I,J,P: longint;
begin
  repeat
    I:=L;
    J:=R;
    P:=(L + R) shr 1;
    repeat
      while leSortCompare(Self, I, P) < 0 do Inc(I);
      while leSortCompare(Self, J, P) > 0 do Dec(J);
      if (I<=J) then begin
        LEExchangeItems(I,J);
        if (P=I) then P:=J
        else begin
          if (P=J) then P:=I;
        end;
        Inc(I);
        Dec(J);
      end;
    until I>J;
    if (L<J) then LEQuickSort(L,J,leSortCompare);
    L:=I;
  until I>=R;
end;

procedure TListEx.LEExchangeItems;
var it1,it2: PLEItem;
    lei: TLEItem;
begin
  it1:=@FLEList^[ix1];
  it2:=@FLEList^[ix2];
  lei:=it1^;
  it1^:=it2^;
  it2^:=lei;
end;

constructor TListEx.Create;
begin
  Sorted:=not notToSort;
end;

destructor TListEx.Destroy;
begin
  inherited Destroy;
  FCount:=0;
  LESetCapacity(0);
end;

function TListEx.IgnoreFindAdd;
var k: longint;
begin
  k:=Self.Count;
  ix:=Self.Add(p);
  result:=(k=Self.Count);
end;

function TListEx.Find;
var L,H,I,C: longint;
begin
  Result:=False;
  L:=0;
  H:=FCount-1;
  while L<=H do begin
    I:=(L+H) shr 1;
    C:=LEComparePointers(FLEList^[I].leiPointer,p);
    if (C<0) then L:=I+1
    else begin
      H:=I-1;
      if (C=0) then begin
        Result:=True;
        if (Duplicates<>dupAccept) then L:=I;
      end;
    end;
  end;
  ix:=L;
end;

function TListEx.FindInt(i: longint): boolean;
var k: longint;
begin
  result:=Find(pointer(i),k);
end;

function TListEx.FindInt(i: longint; var ix: longint): boolean;
begin
  result:=Find(pointer(i),ix);
end;

function TListEx.FindAdd;
var k: longint;
begin
  k:=Count;
  ix:=AddInt(i);
  result:=(k=Count);
end;

function TListEx.IndexOf;
var k: longint;
begin
  if (Sorted) then begin
    if (not Find(p,result)) then result:=-1;
  end else begin
    result:=-1;
    for k:=0 to FCount-1 do begin
      if (LEGet(k)=p) then begin
        result:=k;
        break;
      end;
    end;
  end;
end;

procedure TListEx.LEInsertItem;
var lei: PLEItem;
begin
  if (FCount=FCapacity) then LEGrow;
  if (ix<FCount) then begin
    System.Move(FLEList^[ix],FLEList^[ix+1],(FCount-ix)*SizeOf(TLEItem));
  end;
  lei:=@FLEList^[ix];
  lei^.leiPointer:=p;
  lei^.leiObject:=obj;
  Inc(FCount);
end;

function TListEx.Add;
begin
  result:=AddObject(p,nil);
end;

function TListEx.AddInt;
begin
  result:=AddObject(pointer(i),nil);
end;

function TListEx.AddIntInt;
begin
  result:=AddObject(pointer(i),pointer(obj));
end;

function TListEx.AddObject;
begin
  if (Sorted) then begin
    if (Find(p,result))and(Duplicates=dupIgnore) then exit;
  end else begin
    result:=FCount;
  end;
  LEInsertItem(result,p,obj);
end;

procedure TListEx.Clear;
begin
  if (FCount<>0) then begin
    FCount:=0;
    LESetCapacity(0);
  end;
end;

class procedure TListEx.FreeWithObjects;
var k,j: longint;
    le: TListEx;
begin
  for j:=0 to high(ale) do begin
    le:=ale[j];
    if (le<>nil) then begin
      for k:=0 to le.Count-1 do le[k].Free;
      le.Free;
    end;
  end;
end;

function TListEx.FindTruePointer;
var k: longint;
begin
  result:=false;
  for k:=0 to Count-1 do begin
    if (Bools[k]) then begin
      o^:=Pointers[k];
      Bools[k]:=false;
      result:=true;
      break;
    end;
  end;
end;

function TListEx.TruePointer;
var k: longint;
begin
  result:=Find(p,k);
  if (result) then Bools[k]:=true;
end;

procedure TListEx.AsStrArray;
var k: longint;
begin
  k:=Self.Count; SetLength(sa,k);
  for k:=0 to k-1 do sa[k]:=Int2Str(Self[k]);
end;

function TListEx.AsIntArray;
var k: longint;
begin
  k:=Self.Count;
  SetLength(result,k);
  for k:=0 to k-1 do begin
    result[k]:=longint(Self[k]);
  end;(* for k *)
end;

end.
