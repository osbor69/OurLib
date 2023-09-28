unit FDQuery;

interface

{$I LIBTEST}
uses
  Windows, Messages, Classes, Controls, Menus, ExtCtrls, SyncObjs, Grids, DB,
  MyTypes, FrmAct, KeyMenu, Keylb, Fpanel, StrBrowl, MulQry, FEdText;

type
  TRecCountThread = class(TThread)
  protected
    procedure Execute; override;
  private
    FTM: TThreadMethod;
    constructor Create(tm: TThreadMethod);
  end;

  TDQBrowl = class(TStringBrowl)
  private
		procedure WMMsOff(var Message: TWMMsOff); message WM_MSOFF;
  end;

  TDQuery = class(TFrmAction)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure KeyLb1ProcKey(key: Integer; tw: TWinControl);
  private
    { Private declarations }
    sg: TDQBrowl;
    FQuery: TMulQuery;
    FRCT: TRecCountThread;
    FCSection: TCriticalSection;
    FRecLoaded: TBits;
    FRecAllLoaded: boolean;
    FCol2Fld: TArrInt;
    FQPos,ffc,FQryTime: longint;
    procedure sgDrawCell(Sender: TObject; ACol, ARow: longint; Rect: TRect;
      State: TGridDrawState);
    procedure sgColumnMoved(Sender: TObject; FromIndex, ToIndex: longint);
    procedure sgDblClick(Sender: TObject);
    procedure sgEnter(Sender: TObject);
    procedure sgExit(Sender: TObject);
    procedure RowLoad(ARow: longint);
    procedure SetCaption(recCnt: longint; lastRec: boolean);
    procedure ShutDownThread;
    procedure FQueryBeforeClose(DataSet: TDataSet);
    procedure IncRowCnt;
    procedure WMFormLimit(var msg: TMessage); message WM_FORMLIMIT;
  protected
    class function PrefHistory: string; override;
    class function TextToIni(const s: string): string; override;
    class function ClassTextMemo: TClassTextMemo; override;
    procedure Execute(const txt: string); override;
  end;

var
  DQuery: TDQuery;

implementation

{$R *.dfm}

uses SysUtils,Math,StrUtils,
  My_pr,FrmPswd;

{ TRecCountThread }
constructor TRecCountThread.Create;
begin
  AddStack('TRecCountThread.Create');
  FTM:=tm;
  inherited Create(false);
  DelStack;
end;

procedure TRecCountThread.Execute;
begin
  AddStack('TRecCountThread.Execute');
  repeat
    Synchronize(FTM);
    if (Terminated) then break;
  until false;
  DelStack;
end;

{ TDQBrowl }
procedure TDQBrowl.WMMsOff;
var i: longint;
begin
  AddStack('TDQBrowl.WMMsOff',Self);
  if Message.Oper=msoExec then with TDQuery(Owner) do if not FRecAllLoaded then begin
    FCSection.Enter;
    try
      for i:=FixedRows to RowCount-1 do RowLoad(i);
      FRecAllLoaded:=true;
    finally
      FCSection.Leave;
    end;
  end;
  DelStack;
end;

{ TDQuery }
procedure TDQuery.FormCreate(Sender: TObject);
begin
  AddStack('TDQuery.FormCreate',Self);
  sg:=TDQBrowl.Create(Self);
  with sg do begin
    Parent:=pnObj; IncOptions([goDrawFocusSelected],[goRowSelect]);
    OnColumnMoved:=sgColumnMoved; OnDblClick:=sgDblClick; OnDrawCell:=sgDrawCell;
    OnEnter:=sgEnter; OnExit:=sgExit; Init;
  end;
  inherited;
  FQuery:=TMulQuery.CreateConnection(Self); FQuery.BeforeClose:=FQueryBeforeClose;
  FRecLoaded:=TBits.Create;
  FCSection:=TCriticalSection.Create;
  DelStack;
end;

procedure TDQuery.FormDestroy(Sender: TObject);
begin
  AddStack('TDQuery.FormDestroy',Self);
  inherited;
  FreeAndNil(FRecLoaded); FreeAndNil(FCSection);
  DelStack;
end;

procedure TDQuery.FormHide(Sender: TObject);
begin
  AddStack('TDQuery.FormHide',Self);
  inherited;
  FQuery.Close;
  sg.Init;
  DelStack;
end;

procedure TDQuery.RowLoad;
var k: longint;
begin
  AddStack('TDQuery.RowLoad',Self);
  if (FQuery.Active)and(not FRecLoaded[ARow]) then begin
    if ARow>0 then begin
      k:=ARow-FQPos;
      if (k<>0) then inc(FQPos,FQuery.MoveBy(k));
      for k:=0 to ffc do sg.Cells[k,ARow]:=FQuery.Fields[FCol2Fld[k]].AsString;
    end;
    FRecLoaded[ARow]:=true;
  end;
  DelStack;
end;

procedure TDQuery.SetCaption;
begin
  AddStack('TDQuery.SetCaption',Self);
  Caption:=Format(' оличество записей [%d%s]  ¬рем€ выполнени€ запроса [%d]',
    [recCnt,IfThen(not lastRec,'+'),FQryTime]);
  DelStack;
end;

procedure TDQuery.ShutDownThread;
begin
  AddStack('TDQuery.ShutDownThread',Self);
  FreeAndNil(FRCT);
  DelStack;
end;

procedure TDQuery.FQueryBeforeClose;
begin
  AddStack('TDQuery.FQueryBeforeClose',Self);
  ShutDownThread;
  DelStack;
end;

procedure TDQuery.IncRowCnt;
var k,rc: longint;
begin
  AddStack('TDQuery.IncRowCnt',Self);
  FCSection.Enter;
  try
    inc(FQPos,FQuery.MoveBy(100));
    if (FQuery.Eof) then FRCT.Terminate;
    rc:=FQPos+1;
    k:=max(FRecLoaded.Size,1);
    while k<rc do k:=2*k;
    FRecLoaded.Size:=k;
    SetCaption(FQPos,FQuery.Eof);
    sg.RowCount:=max(2,rc{FQPos+1}); MainRebuild;
  finally
    FCSection.Leave;
  end;
  DelStack;
end;

procedure TDQuery.WMFormLimit;
begin
  AddStack('TDQuery.WMFormLimit',Self);
  inherited;
  FreeLimit(DQuery);
  DelStack;
end;

class function TDQuery.PrefHistory;
begin
  result:='dq_query';
end;

class function TDQuery.TextToIni;
begin
  result:=StrTran(s,CRLF,' ');(* ' '(но не '') нужен дл€ сравнени€ запросов друг с другом *)
end;

class function TDQuery.ClassTextMemo;
begin
  result:=TSQLMemo;
end;

procedure TDQuery.KeyLb1ProcKey(key: Integer; tw: TWinControl);
var inf: TStrBrInfZn;
begin
  AddStack('TDQuery.KeyLb1ProcKey',Self);
  if Key in [K_F5,K_Enter] then begin
    inf:=sg.InfoCol[sg.Col]; EdTextView(DelTrim(ArrayAsList(inf.aName,' ')),sg.Cells[sg.Col,sg.Row]);
  end
  else inherited;
  DelStack;
end;

procedure TDQuery.Execute;
var b,oq: boolean;
  stck,h: longint;
  inf: TStrBrInfZn;
  t: TFieldType;
  k: int64;
  s: string;
begin
  stck:=AddStack('TDQuery.Execute',Self);
  ShutDownThread; sg.Init; FQuery.Close; s:=AnsiLowerCase(txt); oq:=IsPos(h,'select ',s);
  if oq then oq:=Trim(TextToIni(copy(txt,1,h-1)))='';
  b:=false; k:=0;
  try
    k:=My_pr.GetTickCount; FQuery.SQLText('');
    if s='transaction' then TrnsStart([])
    else if s='commit' then TrnsEnd([trnsCommit])
    else if s='rollback' then TrnsEnd
    else begin
      FQuery.SQLText(txt);
//FQuery.BufferChunks:=20000000;
      FQuery.Open;
    end;
    k:=My_pr.GetTickCount-k;
    b:=true;
  except
    on E:Exception do begin
      SetStack(stck);
      MsgDlg(E.Message);
    end;
  end;
  if b then begin
    FQryTime:=k;
    FQPos:=1;
    FRecLoaded.Size:=0;(* перед установкой нормального размера, т.к. метода занулить содержимое нету *)
    FRecAllLoaded:=false;
    if (oq) then begin
      ffc:=FQuery.FieldCount-1; sg.ColZn.BeginUpdate; sg.ColZn.Clear;
      SetLength(FCol2Fld,ffc+1); inf:=sg.InfoCol[0]; CopyFrom(inf.aName);
      for h:=0 to ffc do begin
        FCol2Fld[h]:=h; inf.aName[0]:=FQuery.Fields[h].FullName;
        t:=FQuery.FldDataType(h);
        inf.Alignment:=iif(t in [ftInteger,ftFloat],taRightJustify,iif(t=ftDate,taCenter,taLeftJustify));
        inf.LenData:=IfThen(t in [ftInteger,ftDate],10,IfThen(t=ftFloat,20,min(FQuery.Fields[h].Size,50)));
        sg.InfoCol[h]:=inf;
      end;
      sg.ColZn.EndUpdate;
      if (FQuery.Eof) then begin
        SetCaption(0,true); MainRebuild;
      end
      else FRCT:=TRecCountThread.Create(IncRowCnt);
    end else begin
      if empty(FQuery.Text) then k:=0 else k:=FQuery.RowsAffected;
      SetCaption(k,true);
    end;
  end;
  DelStack;
end;

procedure TDQuery.sgDrawCell;
begin
  AddStack('TDQuery.sgDrawCell',Self);
  FCSection.Enter;
  try
    if InRange(ARow,0,FRecLoaded.Size-1) then RowLoad(ARow);
  finally
    FCSection.Leave;
  end;
  DelStack;
end;

procedure TDQuery.sgColumnMoved;
var inf: TStrBrInfZn;
begin
  AddStack('TDQuery.sgColumnMoved',Self);
  MoveArray(@FCol2Fld[0],ToIndex,FromIndex,1,SizeOf(FCol2Fld[0]));
  sg.ColZn.BeginUpdate;
  inf:=sg.InfoCol[ToIndex]; sg.InfoCol[ToIndex]:=sg.InfoCol[FromIndex]; sg.InfoCol[FromIndex]:=inf;
  sg.ColZn.EndUpdate;
  DelStack;
end;

procedure TDQuery.sgDblClick;
var p: TPoint;
    c,r,k: longint;
    s,t: string;
begin
  AddStack('TDQuery.sgDblClick',Self);
  p:=sg.ScreenToClient(Mouse.CursorPos);
  sg.MouseToCell(p.X,p.Y,c,r);
  if (r=0) then begin
    s:=sg.Cells[c,0];
    for k:=1 to sg.RowCount-1 do IncD(s,','+sg.Cells[c,k]);
    t:=ExeDir+'query'+FormatDateTime('dd.mm.yyyy hh-nn-ss-zzz',Now)+'.txt';
    if (SetStrFile(t,s)) then MsgDlg('File saved <'+t+'>');
  end;
  DelStack;
end;

procedure TDQuery.sgEnter;
begin
  AddStack('TDQuery.sgEnter',Self);
  with KeyLb1 do begin
    SetKeys([K_Enter,K_F5],'«начение','ѕросмотр значени€',KeyLb1ProcKey,'view',kmList);
    Redrw;
  end;
  DelStack;
end;

procedure TDQuery.sgExit;
begin
  AddStack('TDQuery.sgExit',Self);
  KeyLb1.DelKey(K_All,'view'); KeyLb1.Redrw;
  DelStack;
end;

procedure PswdKeyProc(Key: longint; tw: TWinControl; var lBreak: boolean);
begin
  AddStack('FDQuery.PswdKeyProc');
  if Key=K_Alt_Q then begin
    lBreak:=true; CreateShow(TDQuery,DQuery,true);
  end;
  DelStack;
end;

initialization
  AddStack('FDQuery.initialization');
  AddFrom(aPswdKeyProc,PswdKeyProc);
  DelStack;
end.
