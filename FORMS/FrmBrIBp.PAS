unit FrmBrIBp;

interface

uses
  Classes, Controls, ExtCtrls, Grids, DBGrids, Menus, DB, 
  FRMEMPTY, Keylb, Fpanel, Browl, KeyMenu, BrQuery;

{$I LIBTEST}

type
  TFormBrIBPnl = class(TFormEmp)
    DataSource1: TDataSource;
    KeyMenu1: TKeyMenu;
    RbPanel3: TRbPanel;
    RbPanel4: TRbPanel;
    Browl1: TBrowl;
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    BrQuery1: TBrQuery;
  end;

var
  FormBrIBPnl: TFormBrIBPnl;

implementation

uses My_pr;

{$R *.DFM}

procedure TFormBrIBPnl.FormCreate(Sender: TObject);
begin
	AddStack('TFormBrIBPnl.FormCreate',Self);
  inherited;
  BrQuery1:=TBrQuery.CreateConnection(Self,nil,DataSource1);
  DelStack;
end;

procedure TFormBrIBPnl.FormHide(Sender: TObject);
begin
	AddStack('TFormBrIBPnl.FormHide',Self);
  inherited;
	Browl1.FormHide(Sender);
  DelStack;
end;

end.
