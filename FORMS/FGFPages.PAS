unit FGFPages;

interface

uses
  Messages, Classes, Controls, ExtCtrls, Grids,
  MyTypes, FRMEMPTY, Keylb, Fpanel, StrBrowl, GenForm;

type
  TGFPages = class(TFormEmp)
    sb: TStringBrowl;
    function sbCalcZn(Sender: TObject; ACol: Longint): string;
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    procedure sbMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: longint);
    procedure sbMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: longint);
    procedure sbMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: longint);
    procedure sbKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    GF: TGenForm;
    FPrMove: TListMoveItemProc;
    flMove: boolean;
    ARow: longint;
		class procedure TimerFindChar(Sender: TObject);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    LenPage,LenLong,LenSmall,small: longint;
		procedure Move(oi,ni: longint);
    procedure ListRefresh;
		class function Execute(g: TGenForm; const DopKeySt: string = ''; DopKeyProc: TKeyProc = nil;
      PrMove: TListMoveItemProc = nil): boolean;
  end;

var
  GFPages: TGFPages;

implementation

uses Windows,SysUtils,Math,Forms,
  My_pr,FFind;

{$R *.DFM}

class function TGFPages.Execute;
begin
  AddStack('TGFPages.Execute');
  CreateForm(TGFPages,GFPages);
  with GFPages do
    try
      GF:=g; FPrMove:=PrMove;
      with sb do begin
        ListRefresh; AddSt(g.PageCount); MsgRebuild(sb); RbPanel2.Sort;
      end;
      sb.Row:=EnsureRange(g.Leaf,sb.FixedRows,sb.RowCount-1); result:=false;
      with KeyLb1 do begin
        SetKeysSt(DopKeySt,DopKeyProc,'dop'); ReDrw;
        result := ShowModal=mrOk; DelKey(K_All,'dop');
      end;
    finally
      GF:=nil;
    end;
  //FormFree(GFPages);
  DelStack;
end;

procedure TGFPages.ListRefresh;
var i,cnt: longint;
	inf: TStrBrInfZn;
begin
  AddStack('TGFPages.ListRefresh',Self);
  cnt:=GF.PageCount; small:=0;
  for i:=1 to cnt do MaxSelf(small,GF.PageInf(i).PgSmall);
  LenPage:=LenIntStr(cnt);
  LenLong:=LenIntStr(GF.PageInf(cnt).PgLong);
  LenSmall:=LenIntStr(small);
  with sb do begin
    ColZn.Clear; inf:=InfoCol[0]; SetLength(inf.aName,1); i:=0;
    inf.Alignment:=taRightJustify; inf.aName[0]:='Лист'; InfoCol[i]:=inf; Inc(i);
    if small>1 then begin
      inf.aName[0]:='Страница'; InfoCol[i]:=inf; Inc(i);
    end;
    inf.Alignment:=taLeftJustify; inf.aName[0]:='Наименование'; inf.lMax:=true; InfoCol[i]:=inf;
    WidthCols;
  end;
  DelStack;
end;

procedure TGFPages.KeyLb1ProcKey(key: longint; tw: TWinControl);
begin
	AddStack('TGFPages.KeyLb1ProcKey',Self);
	if Key=K_Enter then SetModalResult(mrOk) else inherited;
  DelStack;
end;

function TGFPages.sbCalcZn(Sender: TObject; ACol: Longint): string;
var i: longint;
begin
	AddStack('TGFPages.sbCalcZn',Self);
  inherited;
  result:='';
  if Assigned(GF) then begin
    if (small<=1) and (ACol=1) then ACol:=2;
    i:=sb.Row;
    with GF do
      case ACol of
        0: result:=SpaceStr(i,LenPage);
        1: result:=SpaceStr(PageInf(i).PgLong,LenLong)+'.'+Padr(IntToStr(PageInf(i).PgSmall),LenSmall);
        2: if PageInf(i).PgLong<>PageInf(i-1).PgLong then result:=PageName[i];
      end;
  end;
  DelStack;
end;

procedure TGFPages.sbMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: longint);
var ACol: longint;
begin
	AddStack('TGFPages.sbMouseDown',Self);
	if not flMove and (Button=mbLeft) then begin
	  sb.MouseToCell(X,Y,ACol,ARow); flMove := ARow>0; sb.NoSel:=false;
  end;
  DelStack;
end;

procedure TGFPages.sbMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: longint);
var ACol,nr: longint;
begin
	AddStack('TGFPages.sbMouseMove',Self);
	if flMove then begin
	  sb.MouseToCell(X,Y,ACol,nr);
    if (nr>0) and (nr<>ARow) then begin
		  Move(ARow,nr); ARow:=nr;
    end;
  end;
  DelStack;
end;

procedure TGFPages.sbMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: longint);
begin
  flMove:=false;
end;

procedure TGFPages.Move;
begin
	AddStack('TGFPages.Move',Self);
  if Assigned(FPrMove) then
	  if ListMoveItem(oi,ni,1,sb.RowCount-1,FPrMove,[0]) then sb.Row:=ni;
  DelStack;
end;

procedure TGFPages.WMFormLimit;
begin
	AddStack('TGFPages.WMFormLimit',Self);
  inherited;
  FreeLimit(GFPages);
  DelStack;
end;

procedure TGFPages.sbKeyPress(Sender: TObject; var Key: Char);
begin
  AddStack('TGFPages.sbKeyPress',Self);
  if Key>' ' then begin
    TTimerOne.CreateProc(TimerFindChar,Self).Tag:=Ord(Key); KeyLb1.ExecKey(K_F6);
  end;
  DelStack;
end;

class procedure TGFPages.TimerFindChar;
var f: TForm;
begin
  AddStack('TGFPages.TimerFindChar');
  f:=LastForm;
  with TTimerOne(Sender) do
    if f is TFind then TFind(f).ES.Perform(WM_CHAR,Tag,1) else Enabled:=true;
  DelStack;
end;

end.
