unit FrmStrm;

interface

{$I LIBTEST}
uses
  Windows, Classes, Controls, Forms, ExtCtrls, Grids, Menus,
  MyTypes, KeyMenu, FRMEMPTY, Keylb, Fpanel, StrBrowl, PnlEdit;

type
  TFormStrm = class(TFormEmp)
    PnList: TRbPanel;
    PnEdit: TPanelEdit;
    sb: TStringBrowl;
    tmClose: TTimer;
    KeyMenu1: TKeyMenu;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbEnter(Sender: TObject);
    procedure sbExit(Sender: TObject);
    function PnEditValid(Sender: TObject): Boolean;
    procedure FormHide(Sender: TObject);
    procedure PnEditBeforeExit(Sender: TObject);
    procedure tmCloseTimer(Sender: TObject);
    procedure PnEditBeforeMasterFocus(Sender: TObject);
    procedure PnEditBeforeEnter(Sender: TObject);
    procedure PnEditEnter(Sender: TObject);
    procedure sbBeforeDrawCell(Sender: TObject; ACol,ARow: longint;
      Rect: TRect; State: TGridDrawState);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    oldClose: TCloseEvent;
    SvGet: TArrSvGetVar;
    SvUnKey,LogVid: longint;
    lShow: boolean;
		procedure ProcKey(Key: longint; tw: TWinControl);
    procedure NoClose(Sender: TObject; var Action: TCloseAction);
    procedure TimerNoEdit(Sender: TObject);
  protected
    ListToCur: boolean;
    function BeforeEdit(lFirst: boolean): boolean; virtual;
		procedure FldRead(lFirst: boolean); virtual;
		function PnEditFieldCount: longint; virtual;
  public
    { Public declarations }
  end;

var
  FormStrm: TFormStrm;

implementation

{$R *.DFM}

uses Math,
  My_pr;

procedure TFormStrm.FormCreate(Sender: TObject);
begin
	AddStack('TFormStrm.FormCreate',Self);
  inherited;
  oldClose:=OnClose; ListToCur:=false;
  DelStack;
end;

procedure TFormStrm.FormShow(Sender: TObject);
begin
	AddStack('TFormStrm.FormShow',Self);
  inherited;
  sb.Init; SvUnKey:=0; SvGet:=nil; sb.Enabled:=false; PnEdit.DoEnter; lShow:=true;
  DelStack;
end;

procedure TFormStrm.FormActivate(Sender: TObject);
begin
  AddStack('TFormStrm.FormActivate',Self);
  inherited;
  if lShow then begin
    lShow:=false;
    if BeforeEdit(true) then
      if PnEditFieldCount=0 then TTimerOne.CreateProc(TimerNoEdit,Self) else PnEdit.FillKeyLb
    else tmClose.Enabled:=true;
  end;
  DelStack;
end;

procedure TFormStrm.FormHide(Sender: TObject);
begin
	AddStack('TFormStrm.FormHide',Self);
  KeyLb1.DelKey(K_All,'stream'); KeyLb1.Redrw;
  inherited;
  DelStack;
end;

function TFormStrm.PnEditFieldCount;
begin
  AddStack('TFormStrm.PnEditFieldCount',Self);
  result:=PnEdit.FieldCount;
  DelStack;
end;

procedure TFormStrm.ProcKey;
begin
	AddStack('TFormStrm.ProcKey',Self);
  if peCheckOnExit in PnEdit.Options then begin
    if Key in [K_F10,K_Esc] then sb.Row:=sb.RowCount-1;
    PnEdit.Enabled:=true; pnEdit.SetFocus;
  end
  else begin
  	sb.Row:=sb.RowCount-2; sb.SetFocus;
  end;
  DelStack;
end;

procedure TFormStrm.sbEnter(Sender: TObject);
begin
	AddStack('TFormStrm.sbEnter',Self);
  if not(IsCalculator or tmClose.Enabled) then begin
    PnEdit.SetReadOnly(true,[ogReadOnly,ogReadOnlyNoVsbl]);
    with KeyLb1 do begin
      DelKey(K_All,'stream');
      SetKeys([K_Esc,K_F10],'Продолжить','',ProcKey,'prior',kmFile);
      SetKeys([K_Enter,K_F5],'Редактировать','',ProcKey,'prior',kmList);
      Redrw;
    end;
    if not(peCheckOnExit in PnEdit.Options) then begin
      PnEdit.IncOptions([peCheckOnExit],[peCloseOnEsc]); OnClose:=NoClose;
    end;
    PnEdit.Enabled:=false;
  end;
  DelStack;
end;

procedure TFormStrm.sbExit(Sender: TObject);
var ck: longint;
begin
	AddStack('TFormStrm.sbExit',Self);
  if not IsCalculator then begin
    KeyLb1.DelKey(K_All,'prior'); KeyLb1.Redrw;
    if peCheckOnExit in PnEdit.Options then begin
      if sb.Row=sb.RowCount-1 then begin
        PnEdit.IncOptions([peCloseOnEsc],[peCheckOnExit]); OnClose:=oldClose; ListToCur:=true; ck:=SvUnKey;
      end
      else ck:=sb.CurUnKey;
      sb.SetUnKey(ck,false); FldRead(false); PnEdit.RestGets(SvGet,[sgReadOnly,sgReadOnlyNoVsbl]);
    end;
  end;
  DelStack;
end;

function TFormStrm.PnEditValid(Sender: TObject): Boolean;
begin
	AddStack('TFormStrm.PnEditValid',Self);
  result:=peCheckOnExit in PnEdit.Options;
  if result then sb.CurStUpdate
  else begin
  	PnEdit.FldWriteAll; sb.AddSt;
    if BeforeEdit(false) then PnEdit.FldFocus:=nil else tmClose.Enabled:=true;
  end;
  DelStack;
end;

function TFormStrm.BeforeEdit;
begin
	AddStack('TFormStrm.BeforeEdit',Self);
	FldRead(lFirst); PnEdit.FldReadAll([ferdSvOld]+IfThen(lFirst,ferdFromShow)); result:=true;
  DelStack;
end;

procedure TFormStrm.FldRead;
begin
  AddStack('TFormStrm.FldRead',Self);
  if lFirst then LogVid:=GetLogVid
  else if LogVid<>logvNone then begin
    SetLogVid; SetLogVid(IfThen(peCheckOnExit in PnEdit.Options,logvEditRec,LogVid));
  end;
  DelStack;
end;

procedure TFormStrm.sbBeforeDrawCell(Sender: TObject; ACol,ARow: longint;
  Rect: TRect; State: TGridDrawState);
begin
	AddStack('TFormStrm.sbBeforeDrawCell',Self);
	if (gdSelected in State) and not sb.Focused then begin
  	sb.Canvas.Brush.Color:=sb.FixedColor; sb.Canvas.Font.Assign(sb.Font);
  end;
  DelStack;
end;

procedure TFormStrm.PnEditBeforeEnter(Sender: TObject);
begin
  AddStack('TFormStrm.PnEditBeforeEnter',Self);
  if not IsCalculator and sb.Enabled and ListToCur then begin
  	PnEdit.RestGets(SvGet,[sgValue,sgOldVal]); ListToCur:=false;
  end;
  DelStack;
end;

procedure TFormStrm.PnEditEnter(Sender: TObject);
begin
	AddStack('TFormStrm.PnEditEnter',Self);
  if not IsCalculator and sb.Enabled and not(peCheckOnExit in PnEdit.Options)
  and (sb.RowCount>sb.FixedRows+1) then with KeyLb1 do begin
    SetKey(K_PgUp,'Предыдущие','Редактирование предыдущих записей',ProcKey,'stream',kmEdit);
    ReDrw;
  end;
  DelStack;
end;

procedure TFormStrm.PnEditBeforeExit(Sender: TObject);
begin
	AddStack('TFormStrm.PnEditBeforeExit',Self);
  if not(IsCalculator or (peCheckOnExit in PnEdit.Options)) then begin
		PnEdit.SaveGets(SvGet); sb.SetUnKey(SvUnKey,true);
  end;
  DelStack;
end;

procedure TFormStrm.tmCloseTimer(Sender: TObject);
begin
	AddStack('TFormStrm.tmCloseTimer',Self);
  tmClose.Enabled:=false; KeyLb1.ExecKey(K_Esc);
  DelStack;
end;

// Не закрывать форму, если находимся в списке
procedure TFormStrm.NoClose;
begin
	AddStack('TFormStrm.NoClose',Self);
	Action:=caNone; KeyLb1.ExecKey(K_Esc);
  DelStack;
end;

procedure TFormStrm.PnEditBeforeMasterFocus(Sender: TObject);
begin
  AddStack('TFormStrm.PnEditBeforeMasterFocus',Self);
	sb.Enabled:=true;
  DelStack;
end;

procedure TFormStrm.TimerNoEdit;
begin
  AddStack('TFormStrm.TimerNoEdit',Self);
  sb.AddSt;
  while BeforeEdit(false) do sb.AddSt;
  tmClose.Enabled:=true;
  DelStack;
end;

end.
