unit FrmBrIB;

interface

uses
  Messages, Classes, Controls, Grids, DBGrids, DB, ExtCtrls, Menus,
  MyTypes, KeyMenu, FRMEMPTY, Browl, Keylb, Fpanel, BrQuery;

{$I LIBTEST}

type
  TFormBrIB = class(TFormEmp)
    DataSource1: TDataSource;
    Browl1: TBrowl;
    KeyMenu1: TKeyMenu;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
		procedure WMBrowlForm(var Message: TMessage); message WM_BROWLFORM;
  public
    { Public declarations }
    BrQuery1: TBrQuery;
		constructor CreateAll(AOwner: TComponent); override;
  end;

var
	FormBrIB: TFormBrIB;

implementation

{$R *.DFM}

uses My_pr;

constructor TFormBrIB.CreateAll;
begin
  AddStack('TFormBrIB.CreateAll',Self);
  inherited CreateAll(AOwner);
  with RbPanel2 do begin
    Schem:='Browl'; SortObj:=False;
    Browl1:=TBrowl.Create(Self);
    with Browl1 do begin
      Parent:=RbPanel2; CloseOnSelect:=False;
      Options:=[dgTitles,dgColLines,dgRowLines,dgRowSelect,dgAlwaysShowSelection];
      ReadOnly:=True; DefaultFont(TitleFont);
    end;
  end;
  KeyMenu1:=TKeyMenu.Create(Self);
  DataSource1:=TDataSource.Create(Self); BrQuery1.DataSource:=DataSource1;
  Browl1.DataSource:=DataSource1; ActiveControl:=Browl1; Menu:=KeyMenu1;
  OnShow:=FormShow; OnHide:=FormHide;
  DelStack;
end;

procedure TFormBrIB.FormCreate(Sender: TObject);
begin
	AddStack('TFormBrIB.FormCreate',Self);
  inherited;
  BrQuery1:=TBrQuery.CreateConnection(Self,nil,DataSource1);
  DelStack;
end;

procedure TFormBrIB.FormShow(Sender: TObject);
begin
	AddStack('TFormBrIB.FormShow',Self);
  inherited;
	Browl1.FormShow(Sender);
  DelStack;
end;

procedure TFormBrIB.FormHide(Sender: TObject);
begin
	AddStack('TFormBrIB.FormHide',Self);
  inherited;
	Browl1.FormHide(Sender);
  DelStack;
end;

procedure TFormBrIB.WMBrowlForm;
begin
  AddStack('TFormBrIB.WMBrowlForm',Self);
  Message.result:=LongInt(Browl1);
  DelStack;
end;

end.
