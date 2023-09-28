unit BrQuery;

interface

{$I LIBTEST}
uses
  Classes,DB,Controls,
  MyTypes,MulQry;

type
	TBRQOrder = 1..10;

  TFindQuery = class(TMulQuery)
  private
    sFilter: string;
    lsFilter: TStringList;
    lFiltered,oFiltered: boolean;
    oFilterRecord: TFilterRecordEvent;
    oAfterOpen: TDataSetNotifyEvent;
  	function SeekStCur(DataSet: TDataSet): boolean;
    function FilterField(DataSet: TDataSet): TField;
  	procedure dsFilterRecord(DataSet: TDataSet; var Accept: Boolean);
  	procedure dsAfterOpen(DataSet: TDataSet);
	 	procedure ProcKey(key: longint; tw: TWinControl);
  public
    Control: TControl;
	 	function brfind(Sender: TControl; const sf: string): boolean;
		procedure ClearFilter(lRestRec: boolean = true);
   	constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  end;

	TBrQuery = class(TFindQuery)
 	private
  { Private declarations }
   	FOrder: TBRQOrder;
   	FOrders: TStringList;
    FSeekSection,FSeekKeys: string;
    FOnOrderChange: TNotifyEvent;
    afSeek: TArrField;
    function GetGlobKey: string;
    procedure SetGlobKey(const Value: string);
		procedure SetOrder(Value: TBRQOrder);
		procedure SetOrders(Value: TStringList);
		procedure OrdersChange(Sender: TObject);
		procedure ReOrder;
		function StSeek: string;
		function GetSeekSection: string;
  protected
  { Protected declarations }
   	procedure DoAfterOpen; override;
   	procedure DoBeforeClose; override;
    procedure AssignTo(Dest: TPersistent); override;
  public
  { Public declarations }
   	constructor Create(aOwner: TComponent); override;
		constructor CreateConnection(AOwner: TComponent; AConnection: TComponent; ADataSource: TDataSource); overload;
    destructor Destroy; override;
   	procedure GotoRec(ii: longint);
		function IsCodEqual(const nmf: string; const tbl: string = ''): boolean;
		function CanEdit(Key: longint; const setKey: TByteSet = []; UseStd: boolean = true): boolean;
		function ReadSeekKeysStr: string;
		procedure SaveSeekKeysStr(const st: string);
		procedure SaveSeekKeys;
		function Init(db: TComponent; const aOrder,aSeekKeys: array of string;
    	const table: string; const c_list: array of variant; const where: string = '';
      const g_list: string = ''; PrCalcFields: TDataSetNotifyEvent = nil): TIntegerField; overload;
		function Init(db: TComponent; const aOrder,aSeekKeys: array of string;
    	const table: string; const where: string = '';
      const g_list: string = ''; PrCalcFields: TDataSetNotifyEvent = nil): TIntegerField; overload;
    function GetPrim: string;
  published
  { Published declarations }
    property GlobKey: string read GetGlobKey write SetGlobKey;
    property Order: TBRQOrder read FOrder write SetOrder;
    property Orders: TStringList read FOrders write SetOrders;
    property SeekKeys: string read FSeekKeys write FSeekKeys;
    property SeekSection: string read FSeekSection write FSeekSection;
    property OnOrderChange: TNotifyEvent read FOnOrderChange write FOnOrderChange;
 	end;

procedure Register;

implementation

uses SysUtils,Forms,StrUtils,Math,
  My_pr,KeyLb;

{ TFindQuery }
constructor TFindQuery.Create;
begin
	AddStack('TFindQuery.Create',Self);
	inherited Create(aOwner);
  lsFilter:=SortStrListCreate;
  DelStack;
end;

destructor TFindQuery.Destroy;
begin
	AddStack('TFindQuery.Destroy',Self);
	lsFilter.Free;
  inherited Destroy;
  DelStack;
end;

function TFindQuery.brfind;
var i,cnt: longint;
  lDone: boolean;
	function NextStat: boolean;
  begin
  	AddStack('TFindQuery.brfind.NextStat',Self);
    FindNext; result:=WinFindSayStat(i/cnt); Inc(i);
    if lDone then lDone:=not result;
    DelStack;
  end;
var Upd: TBrFindUpd;
  lAll: boolean;
  function CurRecSt(var res: boolean): boolean;
  begin
    AddStack('TFindQuery.brfind.CurRecSt',Self);
    result:=SeekStCur(DataSet);
    if result then begin
      res:=true;
      if lAll then begin
        lsFilter.Add(FieldAsStr(Upd.f)); result:=NextStat;
      end;
    end
    else result:=NextStat;
    DelStack;
  end;
var lr: longint;
  procedure Find1;
  begin
    AddStack('TFindQuery.brfind.Find1',Self);
    if lDone then while not FindEof and (lr>0) do begin
      if CurRecSt(result) then break;
      if not FindEof then Dec(lr);
    end;
    DelStack;
  end;
var bm: TBookMark;
  Accept: boolean;
  tl: TKeyLb;
begin
	AddStack('TFindQuery.brfind',Self);
	result:=false; sFilter:=sf;
  Upd.tr:=Control.Perform(WM_BRFIND,byte(brfindRow),0);
  Upd.f:=FilterField(DataSet); Upd.v:=Upd.f.Value;
  DisableControls; lr:=CntRec; bm:=nil;
  lAll:=BrFindAll or (FindProperty.Direction=fndAll);
  try
    if lr>0 then begin
      cnt:=lr; i:=1;
      if lAll then begin
        bm:=GetBookMark; ClearFilter(false); First;
        while not Eof do
          if CurRecSt(result) then break;
        if result then begin
          lFiltered:=true; oFiltered:=Filtered; Filtered:=true;
          oFilterRecord:=OnFilterRecord; oAfterOpen:=AfterOpen;
          AfterOpen:=dsAfterOpen;
        end;
      end
      else begin
        lDone:=true;
        if lr<>0 then begin
          bm:=GetBookMark; NextStat; Dec(lr);
        end;
        Find1;
        if not result then begin
          FindFirst; Find1;
        end;
      end;
    end;
    if not result then begin
      GotoBookMark(bm); Control.Perform(WM_BRFIND,byte(brfindUpd),longint(@Upd));
    end;
    if result and lAll then begin
      OnFilterRecord:=oFilterRecord; Filtered:=oFiltered; GotoBookMark(bm); Accept:=true; dsFilterRecord(DataSet,Accept);
      Filtered:=true; Control.Perform(WM_BRFIND,byte(brfindUpd),longint(@Upd));
      if not Accept then First;
      if FormKeyLb(Control,tl) then begin
        tl.SetKey(K_Esc,'','Сбросить результаты поиска',ProcKey,'brfind',kmList); tl.ReDrw;
      end;
    end;
  finally
    FreeBookMark(bm);
  end;
  EnableControls;
  DelStack;
end;

function TFindQuery.SeekStCur;
begin
  AddStack('TFindQuery.SeekStCur',Self);
  result:=boolean(Control.Perform(WM_BRFIND,byte(brfindStr),longint(@sFilter)));
  DelStack;
end;

function TFindQuery.FilterField;
var nmf: string;
begin
  AddStack('TFindQuery.FilterField',Self);
  if Self is TBrQuery then nmf:=TBrQuery(Self).FSeekKeys else nmf:='';
  if (nmf='') or (Pos(',',nmf)>0) then nmf:=fRECNO;
  result:=FindField(nmf);
  DelStack;
end;

procedure TFindQuery.dsFilterRecord;
begin
	AddStack('TFindQuery.dsFilterRecord',Self);
  if oFiltered then IfThenFilterRecord(oFilterRecord,DataSet,Accept);
  if Accept then Accept := lsFilter.IndexOf(FieldAsStr(FilterField(DataSet)))>=0;
  DelStack;
end;

procedure TFindQuery.dsAfterOpen;
var f: TField;
begin
	AddStack('TFindQuery.dsAfterOpen',Self);
  with DataSet do begin
    Filtered:=oFiltered; IfThenDataSet(oAfterOpen,DataSet); f:=FilterField(DataSet); First;
    while not Eof do begin
      if SeekStCur(DataSet) then lsFilter.Add(FieldAsStr(f));
      Next;
    end;
    OnFilterRecord:=dsFilterRecord; Filtered:=true;
  end;
  DelStack;
end;

procedure TFindQuery.ClearFilter;
var Upd: TBrFindUpd;
  tl: TKeyLb;
begin
  AddStack('TFindQuery.ClearFilter',Self);
  if lFiltered then with Upd do begin
    AndD(lRestRec,Active);
    if lRestRec then begin
      tr:=Control.Perform(WM_BRFIND,byte(brfindRow),0); f:=FilterField(DataSet); v:=FieldAsStr(f);
    end
    else begin
      tr:=0; f:=nil;
    end;
    lsFilter.Clear;
    OnFilterRecord:=oFilterRecord; AfterOpen:=oAfterOpen; Filtered:=oFiltered;
    lFiltered:=false;
    if lRestRec then Control.Perform(WM_BRFIND,byte(brfindUpd),longint(@Upd));
    if FormKeyLb(Control,tl) then begin
      tl.DelKey(K_Esc,'brfind'); tl.ReDrw;
    end;
  end;
  DelStack;
end;

procedure TFindQuery.ProcKey;
begin
	AddStack('TFindQuery.ProcKey',Self);
  ClearFilter;
  DelStack;
end;

{ TBrQuery }
constructor TBrQuery.Create;
begin
	AddStack('TBrQuery.Create',Self);
	inherited Create(aOwner);
  FOrders:=TStringList.Create; FOrders.OnChange:=OrdersChange; Order:=1;
  DelStack;
end;

constructor TBrQuery.CreateConnection(AOwner: TComponent; AConnection: TComponent; ADataSource: TDataSource);
begin
  AddStack('TBrQuery.CreateConnection',Self);
  inherited CreateConnection(AOwner,AConnection);
  DataSource:=ADataSource;
  DelStack;
end;

destructor TBrQuery.Destroy;
begin
	AddStack('TBrQuery.Destroy',Self);
	FOrders.Free; 
  inherited Destroy;
  DelStack;
end;

function TBrQuery.GetGlobKey;
begin
	AddStack('TBrQuery.GetGlobKey',Self);
  if Assigned(DataSet) then result:=Arg[SGLOBKEY] else result:='';
  if result='%' then result:='';
  DelStack;
end;

procedure TBrQuery.SetGlobKey;
var fl: boolean;
begin
	AddStack('TBrQuery.SetGlobKey',Self);
  if Assigned(DataSet) then begin
	  fl:=Active; Arg[SGLOBKEY]:=IfThen(Value='','%',Value); Active:=fl;
	end;
  DelStack;
end;

procedure TBrQuery.SetOrder;
begin
	AddStack('TBrQuery.SetOrder',Self);
	if Value<>FOrder then begin
		FOrder:=Value; ReOrder;
  end;
  DelStack;
end;

procedure TBrQuery.SetOrders;
begin
	AddStack('TBrQuery.SetOrders',Self);
	FOrders.Assign(Value);
  DelStack;
end;

procedure TBrQuery.OrdersChange;
begin
	AddStack('TBrQuery.OrdersChange',Self);
	ReOrder;
  DelStack;
end;

procedure TBrQuery.ReOrder;
var fl: boolean;
begin
	AddStack('TBrQuery.ReOrder',Self);
	FOrder:=EnsureRange(FOrder,1,FOrders.Count);
	if FOrders.Count<>0 then begin
    fl:=Active; Active:=false; Arg[sO_LIST]:=FOrders[FOrder-1]; Active:=fl;
  end;
  IfThenNotify(FOnOrderChange,Self);
  DelStack;
end;

{ Встать на указанную RECNO }
procedure TBrQuery.GotoRec;
var f: TField;
begin
	AddStack('TBrQuery.GotoRec',Self);
  if FindField(fRECNO,f) then
  	if f.AsInteger<>ii then begin
      DisableControls; First;
      while not Eof and (f.AsInteger<>ii) do Next;
      EnableControls;
    end;
  DelStack;
end;

function TBrQuery.IsCodEqual;
var a: array[1..5] of string;
  i,l: byte;
  where,p: string;
  q: TBrQuery;
  o,g,h: boolean;
label lend;
begin
	AddStack('TBrQuery.IsCodEqual',Self);
	l:=ListAsArray(nmf,a,','); where:=tRecno(tbl)+'<>'+VarTos(FindField(fRECNO));
  for i:=1 to l do IncAnd(where,a[i]+'='+VarTos(FindField(a[i]),vsQQ));
  q:=TBrQuery.CreateConnection(Owner,Connection);
  try
    q.MulPar:=MulPar; p:=Part;
    q.Arg[sWHERE]:=BrackNoEmp(q.Arg[sWHERE])+sAND+BrackNoEmp(where);
    for o:=low(o) to high(o) do
      for g:=low(g) to high(g) do
        for h:=low(g) to high(g) do
          if aPartWOGH[true,o,g,h]=p then begin
            p:=aPartWOGH[false,o,g,h]; q.Arg[sWHERE]:=where; goto lend;
          end;
lend:
    q.SetPart(p); q.Active:=true; q.First; result:=not q.Eof;
  finally
    q.Free;
  end;
  DelStack;
end;

function TBrQuery.CanEdit;
begin
	AddStack('TBrQuery.CanEdit',Self);
  result := UseStd and (Key=K_F7) or (Key in setKey);
  if not result and Active then result:=IsRecords;
  DelStack;
end;

procedure TBrQuery.DoAfterOpen;
var s: string;
	i,j: longint;
	f: TField;
  a: TArrStr;
begin
	AddStack('TBrQuery.DoAfterOpen',Self);
  inherited DoAfterOpen;
  RecordCount;
  if not(csDesigning in ComponentState) and not empty(FSeekKeys) then begin
    i:=LsArrDynamic(FSeekKeys,a,','); SetLength(afSeek,i); j:=0;
    for i:=0 to i-1 do if FindField(a[i],f) then begin
      afSeek[j]:=f; Inc(j);
    end;
    SetLength(afSeek,j);
    if j>0 then begin
      s:=ReadSeekKeysStr;
      if s<>'' then
        if StSeek<>s then begin
          DisableControls; First;
          while not Eof and (StSeek<>s) do Next;
          if Eof then First;
          EnableControls;
        end;
    end;
  end;
  DelStack;
end;

procedure TBrQuery.DoBeforeClose;
begin
	AddStack('TBrQuery.DoBeforeClose',Self);
  SaveSeekKeys;
  inherited DoBeforeClose;
  DelStack;
end;

procedure TBrQuery.AssignTo;
var d: TBrQuery;
begin
	AddStack('TBrQuery.AssignTo',Self);
  inherited AssignTo(Dest);
  if IsClass(Dest,TBrQuery,pointer(d)) then begin
    d.GlobKey:=GlobKey; d.Order:=Order; d.Orders.Assign(Orders);
    d.SeekKeys:=SeekKeys; d.SeekSection:=SeekSection; d.OnOrderChange:=OnOrderChange;
	end;
  DelStack;
end;

function TBrQuery.ReadSeekKeysStr;
begin
  AddStack('TBrQuery.ReadSeekKeysStr',Self);
  result:=InitFIni[fiSave].ReadString('BrQuery',GetSeekSection);
  if result<>'' then SubStrSelf(result,2,-1);
  DelStack;
end;

procedure TBrQuery.SaveSeekKeysStr;
begin
	AddStack('TBrQuery.SaveSeekKeysStr',Self);
  InitFIni[fiSave].WriteString('BrQuery',GetSeekSection,IfThen(st<>'','"'+st+'"'));
  DelStack;
end;

procedure TBrQuery.SaveSeekKeys;
begin
  AddStack('TBrQuery.SaveSeekKeys',Self);
  if not(csDesigning in ComponentState) and not empty(FSeekKeys) then SaveSeekKeysStr(StSeek);
  DelStack;
end;

function TBrQuery.StSeek;
var i,ost: longint;
begin
  ost:=AddStack('TBrQuery.StSeek',Self);
  result:='';
  for i:=low(afSeek) to high(afSeek) do try
    IncD(result,TrimRight(afSeek[i].AsString));
  except
    SetStack(ost);
  end;
  DelStack;
end;

function TBrQuery.GetSeekSection;
begin
  AddStack('TBrQuery.GetSeekSection',Self);
  if StrToChar(FSeekSection)='@'
  then result:=Copy(FSeekSection,2,MaxInt)
  else result:=DlmBetween(Arg[sTABLE],FSeekSection,'.');
  IncD(result,'.'+FSeekKeys);
  DelStack;
end;

function TBrQuery.Init(db: TComponent; const aOrder,aSeekKeys: array of string;
  const table: string; const c_list: array of variant; const where: string = '';
  const g_list: string = ''; PrCalcFields: TDataSetNotifyEvent = nil): TIntegerField;
var i: longint;
  p: PPswdPrm;
begin
  AddStack('TBrQuery.Init',Self);
  if not Assigned(db) then if IsPswdPrm(p) then db:=p.DBMain;
  Connection:=db; Orders.Text:=ArrayAsList(aOrder,CRLF); FSeekKeys:=ArrayAsList(aSeekKeys,',');
  PartSelect(table,c_list,where,GetListArg(sO_LIST),g_list,false);
  OnCalcFields:=PrCalcFields; FieldDefs.Update;
  i:=FieldDefs.IndexOf(fRECNO);
  if i<0 then result:=nil
  else begin
  	result:=pointer(FieldDefs[i].CreateField(DataSet)); result.Visible:=false;
  end;
  if Owner is TForm then with TForm(Owner) do
    if empty(Caption) then Caption:=GetPrim;
  DelStack;
end;

function TBrQuery.Init(db: TComponent; const aOrder,aSeekKeys: array of string;
  const table: string; const where: string = '';
  const g_list: string = ''; PrCalcFields: TDataSetNotifyEvent = nil): TIntegerField;
begin
  result:=Init(db,aOrder,aSeekKeys,table,[Arg[sC_LIST]],where,g_list,PrCalcFields);
end;

function TBrQuery.GetPrim;
begin
  AddStack('TBrQuery.GetPrim',Self);
  result:=My_pr.GetPrim(GetListArg(sTABLE),false);
  DelStack;
end;

procedure Register;
begin
	RegisterComponents('OurLib',[TBrQuery]);
end;

end.
