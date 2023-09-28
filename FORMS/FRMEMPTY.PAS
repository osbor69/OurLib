unit FRMEMPTY;

interface

uses
  Classes, Controls, ExtCtrls, 
  FRMNUL, Keylb, Fpanel;

type
  TFormEmp = class(TFormNul)
    RbPanel2: TRbPanel;
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
  private
    { Private declarations }
  public
    { Public declarations }
		constructor CreateAll(AOwner: TComponent); override;
  end;

var
  FormEmp: TFormEmp;

implementation

{$R *.DFM}

uses MyTypes,My_pr;

constructor TFormEmp.CreateAll;
begin
  AddStack('TFormEmp.CreateAll',Self);
  inherited CreateAll(AOwner);
  with KeyLb1 do begin
    NmProc.Text:=ArrayAsList(
      [ArrayAsList(['Esc','Выход','','FILE'],UnDelim)
      ,ArrayAsList(['F10','','','','','Esc'],UnDelim)
      ],CRLF);
    OnProcKey:=KeyLb1ProcKey;
  end;
  RbPanel2:=TRbPanel.Create(Self);
  with RbPanel2 do begin
    Parent:=RbPanel1; ProcentWnd:=100; BevelOuter:=bvLowered;
  end;
  DelStack;
end;

procedure TFormEmp.KeyLb1ProcKey(key: longint; tw: TWinControl);
begin
	AddStack('TFormEmp.KeyLb1ProcKey',Self);
  case Key of
   	K_Esc: SetModalResult;
   	K_F10: SetModalResult(mrOk);
  else inherited;
  end;
  DelStack;
end;

end.
 