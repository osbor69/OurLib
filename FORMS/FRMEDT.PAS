unit FrmEdt;

interface

uses
  Classes, Controls, Menus, ExtCtrls,
  FRMNUL, KeyMenu, PnlEdit, Keylb, Fpanel;

type
  TFormEdt = class(TFormNul)
    PanelEdit1: TPanelEdit;
    KeyMenu1: TKeyMenu;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
		constructor CreateAll(AOwner: TComponent); override;
  end;

  TFormEdtClass = class of TFormEdt;

var
  FormEdt: TFormEdt;

implementation

{$R *.DFM}

uses MyTypes,My_pr;

constructor TFormEdt.CreateAll;
begin
  AddStack('TFormEdt.CreateAll',Self);
  inherited CreateAll(AOwner);
  PanelEdit1:=TPanelEdit.Create(Self);
  with PanelEdit1 do begin
    Parent:=RbPanel1; ProcentWnd:=100; BevelOuter:=bvLowered;
  end;
  KeyMenu1:=TKeyMenu.Create(Self);
  ActiveControl:=PanelEdit1; Menu:=KeyMenu1; OnShow:=FormShow;
  DelStack;
end;

procedure TFormEdt.FormShow(Sender: TObject);
begin
	AddStack('TFormEdt.FormShow',Self);
  inherited;
	PanelEdit1.FldReadAll([ferdSvOld,ferdFromShow]);
  DelStack;
end;

end.
 