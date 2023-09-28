unit FLockLst;

interface

{$I LIBTEST}
uses
	Windows, Messages, Classes, Controls, Forms, Menus, DB, Grids, DBGrids, ExtCtrls, Chart,
  MyTypes, My_pr, FRMBRIB, KeyMenu, mulqry, Browl, Keylb, Fpanel, DefEdit, RecVal, FrmPswd;

const StdModeCnt = 3;

type
  TStdModeList = 1..StdModeCnt;

  PChartInf = ^TChartInf;
	TChartInf = record
  	LastDU,Mode: string;
    Used,Worked: boolean;
    crt: TChart;
    X: Double;
  end;

  TLockLst = class(TFormBrIB)
    de: TDefEdit;
    Rec: TRecVal;
    deIntv: TDefEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Browl1BrowlKey(key: longint; tw: TWinControl);
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    procedure FormDestroy(Sender: TObject);
    procedure Browl1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: longint; Column: TColumn; State: TGridDrawState);
    function Browl1GrayCell(Sender: TObject; const Rect: TRect;
      DataCol: longint; Column: TColumn; State: TGridDrawState): Boolean;
    procedure Browl1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: longint);
    procedure Browl1ShowHint(var HintStr: String; var CanShow: Boolean;
      var HintInfo: THintInfo);
    procedure Browl1BeforePaint(Sender: TObject);
    procedure dePnlCngKey(Sender: TObject; var tb: TKeyBut);
  private
    { Private declarations }
    fStdMode: array[TStdModeList] of TField;
    BrQuery1SMMODE,FBrQuery1NAME: TStringField;
    BrQuery1DU,BrQuery1IDUPD: TField;
    ProcUsl: TProcValid;
    LsChart: TStringList;
    Qry: Tmulquery;
    fPswd: TFormPswd;
    procedure BrQuery1CalcFields(DataSet: TDataSet);
    procedure BrQuery1AfterOpen(DataSet: TDataSet);
		procedure ClearChart(i: longint);
		procedure ClearCharts;
		function GetChart: PChartInf;
		procedure ChartMouseMove(Sender: TObject; Shift: TShiftState; X,Y: longint);
    procedure Timer1Timer(Sender: TObject);
    function CanLock: boolean;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    BrQuery1DR,BrQuery1NAME: TField;
    BrQuery1COMP,BrQuery1MODE,BrQuery1DRTXT,BrQuery1IP: TStringField;
    Timer1: TTimerLock;
  end;

var
  LockLst: TLockLst;

implementation

{$R *.DFM}

uses SysUtils,Math,TeEngine,Series,StrUtils,DateUtils,   
  BrQuery,SpGet,SpinGet;

type TStdModeStr = array[TStdModeList] of string;

function DtToStr(f: TField): string;
var v: variant;
begin
	AddStack('FLockLst.DtToStr');
  v:=FieldAsVariant(f);
  if MyVarType(v)=varDate then result:=FormatDateTime('yyyymmddhhnnsszzz',v) else result:=v;
  DelStack;
end;

{ TLockLst }
procedure TLockLst.FormCreate(Sender: TObject);
begin
	AddStack('TLockLst.FormCreate',Self);
  Timer1:=TTimerLock.CreateProc(Timer1Timer,Self);
  with TIniFileSave.Create do try
    Timer1.Interval:=ReadInteger(stpSection,stpIBrUpd,10)*MSecsPerSec;
  finally
    Free;
  end;
  Qry:=Tmulquery.Create(Self); LsChart:=SortStrListCreate;
  inherited;
  DelStack;
end;

procedure TLockLst.FormDestroy(Sender: TObject);
begin
	AddStack('TLockLst.FormDestroy',Self);
  with TIniFileSave.Create do try
    WriteInteger(stpSection,stpIBrUpd,Timer1.Interval div MSecsPerSec);
  finally
    Free;
  end;
  if Assigned(LsChart) then ClearCharts;
  LsChart.Free;
  inherited;
  DelStack;
end;

function LockExec(const Capt: string; ProgPswd: TObject;
  Options: TLockLstOptions = []; const Head: string = '';
  const where: string = ''; PrUsl: TProcValid = nil): boolean;
  procedure CngFldProc(lBefore: boolean);
  begin
    AddStack('FLockLst.LockExec.CngFldProc');
    with LockLst do begin
      BrQuery1NAME:=FBrQuery1NAME;
      if Assigned(LockLstCngFldProc) then LockLstCngFldProc(LockLst,lBefore,BrQuery1NAME);
    end;
    DelStack;
  end;
var ls: TMQFieldList;
  procedure qfAdd(const nmf: string);
  begin
    AddStack('FLockLst.LockExec.qfAdd');
    if ls.IsField(nmf) then LockLst.BrQuery1.AddArgList(sC_LIST,nmf);
    DelStack;
  end;
const aStdMode: TStdModeStr = ('FSUPER','FMONO','FEDCONF');
  a: TArrBoolNamePrimStr = (('Выход',''),('Повторить','Обновить список пользователей'));
var i: longint;
begin
	AddStack('FLockLst.LockExec');
	CreateForm(TLockLst,LockLst);
  with LockLst do begin
    fPswd:=pointer(ProgPswd);
    BrQuery1.Free; BrQuery1:=TBrQuery.CreateConnection(LockLst,nil,DataSource1);
    with BrQuery1 do begin
      SetArrayList(sC_LIST,[RegDt('DU'),fNAME,RegDt,'COMP',fIP]);
      ls:=MulQry.GetFieldList(tREGS); qfAdd('IDUPD');
      for i:=low(aStdMode) to high(aStdMode) do qfAdd(aStdMode[i]);
      for i:=low(fPswd.aModeFld) to high(fPswd.aModeFld) do qfAdd(fPswd.aModeFld[i]);
      CngFldProc(true);
      Init(fPswd.PswdPrm.DBMain,[RegDt],[RegDt],tREGS,fNAME+'='+QQs,'',BrQuery1CalcFields);
      AfterOpen:=BrQuery1AfterOpen;
      FBrQuery1NAME:=CreateStringField(fNAME,'Пользователь');
      BrQuery1COMP:=CreateStringField('COMP','Компьютер');
      BrQuery1MODE:=CreateStringField('MODE','',1000); BrQuery1MODE.Visible:=false;
      BrQuery1SMMODE:=CreateStringField('SMMODE','Режим',100); BrQuery1SMMODE.DisplayWidth:=35;
      CreateStringField('AFTDU','Отметка в сети',30);
      BrQuery1DRTXT:=CreateStringField('DRTXT','Регистрация',8,taCenter);
      BrQuery1IP:=CreateStringField(fIP,'IP-адрес');
      BrQuery1DU:=CreateField(RegDt('DU'));
      BrQuery1DR:=CreateField(RegDt);
      BrQuery1IDUPD:=CreateField(ls,'IDUPD');
      for i:=low(aStdMode) to high(aStdMode) do fStdMode[i]:=CreateField(ls,aStdMode[i]);
      for i:=low(fPswd.aModeFld) to high(fPswd.aModeFld) do CreateField(ls,fPswd.aModeFld[i]);
      CngFldProc(false);
    end;
    Qry.Connection:=BrQuery1.Connection;
  	with KeyLb1 do begin
    	SetKey(K_F10,a[lockReplF10 in Options,1],a[lockReplF10 in Options,2],KeyLb1ProcKey,'f10',kmFile);
      if fPswd.PswdPrm.SuperUser or (lockCanDel in Options)
      then SetKey(K_F8,'Удалить','Удалить пользователя из сети',KeyLb1ProcKey,'delus',kmList)
      else DelKey(K_All,'delus');
      ReDrw;
    end;
  	with BrQuery1 do begin
      PartSelect('','',where,Arg[sO_LIST]);
      if lockReplF10 in Options then OutStackQry(DlmBetween(Capt,Head,CRLF));
    end;
    Caption:=Capt; RbPanel2.Header:=Head; ProcUsl:=PrUsl;
    Timer1.Enabled := not(lockNoShow in Options); ClearCharts;
    BrQuery1.Open; result:=true;
    if Timer1.Enabled then
      if not CanLock then result := ShowModal=mrOk;
    ClearCharts;
  end;
  if not(lockNoFree in Options) then FormFree(LockLst);
  DelStack;
end;

procedure TLockLst.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	AddStack('TLockLst.FormClose',Self);
  inherited;
  if Action=caHide then Timer1.Enabled:=false;
  DelStack;
end;

// Обновление списка пользователей
procedure TLockLst.Timer1Timer;
begin
	AddStack('TLockLst.Timer1Timer',Self);
  inherited;
  Browl1.BrUpdate(Browl1.Row,FieldAsVariant(BrQuery1DR),RegDt);
  if CanLock then KeyLb1.ExecKey(K_F10);
  DelStack;
end;

function TLockLst.CanLock;
begin
  AddStack('TLockLst.CanLock',Self);
  result:=IfThenValid(ProcUsl,Self,not BrQuery1.IsRecords);
  DelStack;
end;

// Отправить сообщение
procedure TLockLst.Browl1BrowlKey(key: longint; tw: TWinControl);
const lnIntv = 3;
var d: variant;
	fl: boolean;
  sTo: string;
begin
	AddStack('TLockLst.Browl1BrowlKey',Self);
  inherited;
  if Key=K_F5 then with deIntv do begin
  	Timer1.Enabled:=false; Rec['BrUpd']:=longint(Timer1.Interval div MSecsPerSec);
    TSpinGet.CreateOne; Param[0,deMask]:='1,'+StringOfChar('9',lnIntv);
    if Execute.Saved then Timer1.Interval:=Rec['BrUpd']*MSecsPerSec;
  	Timer1.Enabled:=true;
  end
  else begin
    fPswd.LogVid:=logvAppRec;
    de.FrmCaption:='Отправить сообщение '
      +IfThen(Key=K_Enter,'пользователю "'+Trim(BrQuery1NAME.AsString)+'"','всем пользователям');
    TSpGkLs.GetPrm(de,tMSGS,'MSG');
    Timer1.Enabled:=false; fl:=de.Execute.Saved; Timer1.Enabled:=true;
    if fl then begin
      if Key=K_Enter then d:=FieldAsVariant(BrQuery1DR) else d:='';
      Timer1.Timer;
      if BrQuery1.IsRecords then
	      if not((Key=K_Enter) and (FieldAsVariant(BrQuery1DR)<>d)) then with Qry do begin
          // Сообщение одному пользователю
          if Key=K_Enter then begin
            SetArrayList(sC_LIST,[RegDt,RegDt(fMsgsDSEND),'MSG',fNAME]);
            SetArrayList(sV_LIST,[SQLDateTime(d),StrNow,QQs(Rec['Msg']),QQs(fPswd.UserName)]);
            if not empty(fPswd.SDateReg) then begin
              AddArgList(sC_LIST,RegDt(fMsgsDRFROM));
              AddArgList(sV_LIST,fPswd.SDateReg);
            end;
            Arg[sTABLE]:=tMSGS; ExecPart(sI_TABLE);
            sTo:=Trim(BrQuery1NAME.AsString)+FormatDateTime('(dd.mm.yyyy hh:nn:ss:zzz)',d);
          end
          // Сообщение всем пользователям
          else begin
            Arg[sTABLE]:=tREGS;
            SetArrayList(sC_LIST,[RegDt,StrNow,QQs(Rec['Msg']),QQs(fPswd.UserName)]);
            if not empty(fPswd.SDateReg) then AddArgList(sC_LIST,fPswd.SDateReg);
            if empty(BrQuery1.Arg[sWHERE]) then SetPart(sSELECT_FLIST)
            else begin
	            Arg[sWHERE]:=BrQuery1.Arg[sWHERE]; SetPart(sSELECT_WHERE);
            end;
            Arg[sSELECT]:=Text; Arg[sTABLE]:=tMSGS;
            SetArrayList(sC_LIST,[RegDt,RegDt(fMsgsDSEND),'MSG',fNAME]);
            if not empty(fPswd.SDateReg) then AddArgList(sC_LIST,RegDt(fMsgsDRFROM));
            ExecPart(sIS_TABLE);
            sTo:='все';
          end;
          fPswd.LogWrite(tMSGS,ArrayAsList(['время:"'+FormatDateTime('dd.mm.yyyy hh:nn',Now)+'"',
            'отправитель:"'+Trim(fPswd.UserName)+FormatDateTime('(dd.mm.yyyy hh:nn:ss:zzz)',fPswd.DateReg)+'"',
            'получатель:"'+sTo+'"','текст:"'+Trim(Rec['Msg'])+'"'],LogDlm));
        end;
    end;
    fPswd.LogVid:=logvNone;
  end;
  DelStack;
end;

procedure TLockLst.dePnlCngKey(Sender: TObject; var tb: TKeyBut);
begin
	AddStack('TLockLst.dePnlCngKey',Self);
  with tb do case Key of
  	K_F10,K_Alt_Z: begin
    	Caption:=''; Hint:='';
    end;
    K_Enter: begin
    	Caption:='Отправить'; Hint:='Отправить сообщение'; Part:=kmFile;
    end;
  end;
  DelStack;
end;

procedure TLockLst.KeyLb1ProcKey(key: longint; tw: TWinControl);
var dr: TDateTime;
  s: string;
  sec: longword;
  lMsg: boolean;
label lend;
begin
	AddStack('TLockLst.KeyLb1ProcKey',Self);
	// Удаление пользователя из сети
	if Key=K_F8 then begin
    Timer1.Enabled:=false; lMsg:=false;
    if not fPswd.PswdPrm.SuperUser then
      if fPswd.SDateReg<>Qry.SQLDateTime(FieldAsVariant(BrQuery1DR)) then begin
        meserr('Нельзя удалять другого пользователя.'); goto lend;
      end;
    if Assigned(BrQuery1IDUPD) then begin
      sec:=BrQuery1IDUPD.AsInteger*2;
      if FieldAsVariant(BrQuery1DU) >= NowDouble-sec*OneSecond then begin
        s:='"'+Trim(BrQuery1NAME.AsString)+'"';
        lMsg:=Ask([Format('От пользователя %s за последние %d секунд',[s,sec]),
          'были получены сигналы подтверждения работы.','Запрещено удалять работающих пользователей.',
          'Послать сообщение пользователю '+s+' ?']);
        goto lend;
      end;
    end;
    fPswd.LogVid:=logvDelRec; s:='"'+Trim(BrQuery1NAME.AsString)+'"';
    if Ask(['Внимание !',
    IfThen(GetChart.Worked,'Пользователь '+s+' в настоящее время работает в сети.',
    'От пользователя '+s+' не получены сигналы подтверждения работы.'+CRLF
    +'Возможно, в настоящее время у него выполняется длительный процесс,'+CRLF
    +'блокирующий отправку этих сигналов.'),
    'При удалении его экземпляр программы будет аварийно завершен,',
    'что может привести к нарушению целостности','логической структуры данных.','',
    'Вы уверены, что нужно удалить пользователя '+s+' ?']) then with Qry do begin
      dr:=FieldAsVariant(BrQuery1DR); PartSelect(tREGS,[],RegDt+'='+SQLDateTime(dr));
      if IsRecords then begin
        RegsDelProc(FindField(RegDt)); ExecPart(sDW_TABLE); Arg[sTABLE]:=tMSGS; ExecPart(sDW_TABLE);
        fPswd.LogWrite(tREGS,'пользователь: '+s
          +LogDlm+'дата регистрации: "'+FormatDateTime('dd/mm/yyyy hh:nn:ss:zzz',dr)+'"');
        Timer1.Timer;
      end;
    end;
    fPswd.LogVid:=logvNone;
lend:
    Timer1.Enabled:=true;
    if lMsg then KeyLb1.ExecKey(K_Enter);
  end
  else inherited;
  DelStack;
end;

procedure TLockLst.BrQuery1CalcFields;
const amsg: TStdModeStr = ('администратор программы','монопольный','редактирование конфигурации');
var a: array[1..StdModeCnt+1] of string;
	s: string;
  i: TStdModeList;
  d: variant;
begin
	AddStack('TLockLst.BrQuery1CalcFields',Self);
  for i:=low(fStdMode) to high(fStdMode) do begin
    a[i]:='';
    if Assigned(fStdMode[i]) then
      if fStdMode[i].AsInteger>0 then a[i]:=amsg[i];
  end;
  a[high(a)]:=fPswd.CalcMode(MulQueryOwner(DataSet)); s:=DlmBetween(a,',');
  BrQuery1MODE.AsString:=s; BrQuery1SMMODE.AsString:=s;
  d:=FieldAsVariant(BrQuery1DR);
  if MyVarType(d)=varString then d:=qStrToDateTime(d);
  BrQuery1DRTXT.AsString:=FormatDateTime('hh:nn:ss',d);
  DelStack;
end;

// Графики
const
	XMaxVal = 30;
	YMaxVal = 10;
  YBot    = 2;
  YTop    = YMaxVal-YBot;

procedure TLockLst.Browl1BeforePaint(Sender: TObject);
var i,j: longint;
begin
	AddStack('TLockLst.Browl1BeforePaint',Self);
  inherited;
  j:=-1;
  with BrQuery1 do for i:=0 to FieldCount-1 do begin
  	if Fields[i].Visible then Inc(j);
    if Fields[i].FieldName='AFTDU' then break;
  end;
  if (j<Browl1.LeftCol) or (j>Browl1.LeftCol+Browl1.VisibleColCount) then
	  for i:=0 to LsChart.Count-1 do PChartInf(LsChart.Objects[i]).crt.Visible:=false;//Left:=Browl1.Width;
  DelStack;
end;

procedure TLockLst.Browl1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: longint; Column: TColumn; State: TGridDrawState);
var r: TRect;
begin
	AddStack('TLockLst.Browl1DrawColumnCell',Self);
  inherited;
	if not(gdFixed in State) and Assigned(Column.Field) then
    if Column.Field.FieldName='AFTDU' then with GetChart.crt do begin
      Color:=Browl1.Canvas.Brush.Color;
      Series[0].SeriesColor:=Browl1.Canvas.Font.Color;
      r:=Rect; InflateRect(r,1,1); BoundsRect:=r; Visible:=true;
    end
    else if Column.Field=BrQuery1SMMODE then GetChart.Mode:=Trim(BrQuery1MODE.AsString);
  DelStack;
end;

procedure TLockLst.ClearChart;
var p: PChartInf;
begin
	AddStack('TLockLst.ClearChart',Self);
  p:=PointerObj(LsChart,i); p.crt.Free; p.LastDU:=''; p.Mode:=''; Dispose(p); LsChart.Delete(i);
  DelStack;
end;

procedure TLockLst.ClearCharts;
begin
	AddStack('TLockLst.ClearCharts',Self);
	while LsChart.Count>0 do ClearChart(0);
  DelStack;
end;

procedure TLockLst.BrQuery1AfterOpen;
var i: longint;
  newDU: string;
  lw: boolean;
begin
	AddStack('TLockLst.BrQuery1AfterOpen',Self);
  for i:=0 to LsChart.Count-1 do PChartInf(LsChart.Objects[i]).Used:=false;
  with BrQuery1 do begin
  	DisableControls; First;
    while not Eof do with GetChart^ do begin
    	newDU:=DtToStr(BrQuery1DU);
      with crt do begin
        lw := newDU<>LastDU;
        Series[0].AddXY(X+0.5,IfThen((X>0) and lw,YTop,YBot),'',clTeeColor);
        Series[0].AddXY(X+1,YBot,'',clTeeColor);
        IncD(X,1);
        if X>XMaxVal then begin
          BottomAxis.Minimum:=BottomAxis.Minimum+1;
          BottomAxis.Maximum:=BottomAxis.Maximum+1;
          Series[0].Delete(0); Series[0].Delete(0);
        end;
      end;
      if lw then Worked:=true;
    	Used:=true; LastDU:=newDU; Next;
    end;
  	First; EnableControls;
  end;
  i:=0;
  while i<LsChart.Count do
  	if PChartInf(LsChart.Objects[i]).Used then Inc(i) else ClearChart(i);
  DelStack;
end;

function TLockLst.GetChart;
var srs: TLineSeries;
	s: string;
  i: longint;
begin
	AddStack('TLockLst.GetChart',Self);
	s:=DtToStr(BrQuery1DR);
  if not PointerObjFindAdd(LsChart,s,i,pointer(result)) then begin
  	New(result); LsChart.Objects[i]:=Pointer(result);
    result.Used:=true; result.Worked:=false; result.LastDU:=DtToStr(BrQuery1DU); result.X:=0;
    result.crt:=TChart.Create(Self);
    with result.crt do begin
      Parent:=Browl1;
      MarginBottom:=0; MarginLeft:=0; MarginRight:=0; MarginTop:=0;
      Title.Visible:=False; AxisVisible:=False;
      with BottomAxis do begin
        Automatic:=False; Maximum:=XMaxVal;
      end;
      with LeftAxis do begin
        Automatic:=False; Maximum:=YMaxVal;
      end;
      Legend.Visible:=False; ScaleLastPage:=False;
      View3D:=False; View3DWalls:=False;
      srs:=TLineSeries.Create(result.crt);
      with srs do begin
        Marks.Visible:=False; LinePen.Width:=2; Pointer.Visible:=False;
        Stairs:=True; AddXY(0,YBot,'',clTeeColor);
      end;
      AddSeries(srs); Visible:=false; onMouseMove:=ChartMouseMove;
    end;
  end;
  DelStack;
end;

function TLockLst.Browl1GrayCell(Sender: TObject; const Rect: TRect;
  DataCol: longint; Column: TColumn; State: TGridDrawState): Boolean;
begin
	AddStack('TLockLst.Browl1GrayCell',Self);
  inherited;
  if empty(fPswd.SDateReg) then result:=false
  else result := Qry.SQLDateTime(FieldAsVariant(BrQuery1DR))=fPswd.SDateReg;
  DelStack;
end;

procedure TLockLst.Browl1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: longint);
var hnt,s: string;
  c,r: longint;
  f: TField;
begin
	AddStack('TLockLst.Browl1MouseMove',Self);
  inherited;
  if BrQuery1.Active then with Browl1 do begin
	  hnt:='';
    if GetXField(X,c,f) then
      if f=BrQuery1SMMODE then begin
        r:=MouseCoord(X,Y).Y;
        if InRange(r,1,LsChart.Count) then begin
          Canvas.Font.Assign(Font); s:=PChartInf(LsChart.Objects[r-1]).Mode;
          if Canvas.TextWidth(s)>ColWidths[c] then hnt:=s;
        end;
      end;
    Hint:=hnt; ShowHint := not empty(hnt);
  end;
  DelStack;
end;

procedure TLockLst.Browl1ShowHint(var HintStr: String;
  var CanShow: Boolean; var HintInfo: THintInfo);
begin
	AddStack('TLockLst.Browl1ShowHint',Self);
  inherited;
	HintInfo.ReshowTimeout:=100;
  DelStack;
end;

procedure TLockLst.ChartMouseMove;
begin
	AddStack('TLockLst.ChartMouseMove',Self);
  inherited;
  Browl1.ShowHint:=false;
  DelStack;
end;

procedure TLockLst.WMFormLimit;
begin
	AddStack('TLockLst.WMFormLimit',Self);
  inherited;
  FreeLimit(LockLst);
  DelStack;
end;

initialization
  AddStack('FLockLst.initialization');
  MyTypes.LockExec:=LockExec;
  SetPrim(tREGS,'Регистрации');
  DelStack;
end.
