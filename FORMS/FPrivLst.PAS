unit FPrivLst;

interface

uses
  Windows, Messages, Classes, Controls, ExtCtrls, Grids, Menus, 
  MyTypes, FRMEMPTY, Keylb, Fpanel, StrBrowl, KeyMenu;

type
  TPrivLst = class(TFormEmp)
    tbl: TStrTable;
    KeyMenu1: TKeyMenu;
    procedure tblDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure KeyLb1ProcKey(key: Integer; tw: TWinControl);
  private
    { Private declarations }
		procedure WMRebuild(var Message: TWMRebuild); message WM_REBUILD;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    PrivUserX: Word;
  end;

  TPrivLsOper = (privCreate,privProcKey);

var
  PrivLst: TPrivLst;
  PrivLsProc: procedure(oper: TPrivLsOper; const av: array of variant);

implementation

{$R *.DFM}

uses My_pr;

procedure Proc(oper: TPrivLsOper; const av: array of variant);
begin
  AddStack('FPrivLst.Proc');
  if Assigned(PrivLsProc) then PrivLsProc(oper,av);
  DelStack;
end;

{ TPrivLst }
procedure TPrivLst.FormCreate(Sender: TObject);
begin
  AddStack('TPrivLst.FormCreate',Self);
  inherited;
  Proc(privCreate,[longint(KeyLb1)]);
  DelStack;
end;

procedure TPrivLst.tblDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  AddStack('TPrivLst.tblDrawCell',Self);
  if not(gdFixed in State) then tbl.bmCheckPaint(ACol,ARow);
  DelStack;
end;

procedure TPrivLst.WMRebuild;
var i: longint;
	sz: TSize;
begin
	AddStack('TPrivLst.WMRebuild',Self);
  inherited;
  if Message.Oper=rbBefore then with tbl do begin
    sz:=bmCheckSize; Inc(sz.cX,2); Inc(sz.cY,2);
		for i:=FixedCols to ColCount-1 do MaxColWidths(i,sz.cX);
    for i:=FixedRows to RowCount-1 do MaxRowHeights(i,sz.cY);
  end;
  DelStack;
end;

procedure TPrivLst.WMFormLimit;
begin
	AddStack('TPrivLst.WMFormLimit',Self);
  inherited;
  FreeLimit(PrivLst);
  DelStack;
end;

procedure TPrivLst.KeyLb1ProcKey(key: Integer; tw: TWinControl);
begin
  AddStack('TPrivLst.KeyLb1ProcKey',Self);
  inherited;
  Proc(privProcKey,[key,longint(tw)]);
  DelStack;
end;

end.
