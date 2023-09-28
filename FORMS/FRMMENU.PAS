unit FrmMenu;

interface

uses
  Classes, Controls, ExtCtrls,
  FRMWND, Fpanel;

type
  TFormMenu = class(TFormWnd)
    RbPanel1: TRbPanel;
    RbStatus1: TRbStatus;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure AfterCreate; override;
  public
    { Public declarations }
  end;

var
  FormMenu: TFormMenu;

implementation

{$R *.DFM}

uses My_pr,Saveini;

procedure TFormMenu.FormCreate(Sender: TObject);
begin
	AddStack('TFormMenu.FormCreate',Self);
  RbStatus1.SectRight[0]:='сборка '+StrExeVersion;
  inherited;
	SetSchemForm; MainRebuild;
  DelStack;
end;

procedure TFormMenu.AfterCreate;
begin
  AddStack('TFormMenu.AfterCreate',Self);
  RestIniForm(Self);
  DelStack;
end;

procedure TFormMenu.FormDestroy(Sender: TObject);
begin
  AddStack('TFormMenu.FormDestroy',Self);
	SaveIniForm(Self);
  inherited;
  DelStack;
end;

procedure TFormMenu.FormResize(Sender: TObject);
begin
	AddStack('TFormMenu.FormResize',Self);
  inherited;
  if not(csDestroying in ComponentState) then RbFormResize;
  DelStack;
end;

end.
