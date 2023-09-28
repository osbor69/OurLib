unit FrmCode;

interface

uses
  Classes, Controls, Menus, ExtCtrls,
  MyTypes, FRMEDT, FFldedit, KeyMenu, Keylb, PnlEdit, Fpanel;

type
  TFormCode = class(TFormEdt)
    ECode: TFldEdit;
    function ECodeCheck(Sender: TObject): Boolean;
    procedure ECodeExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FTypeEdit: TCodeTypeEdit;
		procedure SetTypeEdit(Value: TCodeTypeEdit);
  protected
    function BrEditProc(lApp: boolean; const Capt: TCaption; const glkey: string): boolean; override;
  public
    { Public declarations }
    GK: string;
    CodCheck: TProcValid;
    property TypeEdit: TCodeTypeEdit read FTypeEdit write SetTypeEdit;
  end;

var
  FormCode: TFormCode;

implementation

uses StdCtrls,
  My_pr;

{$R *.DFM}

procedure TFormCode.FormCreate(Sender: TObject);
begin
	AddStack('TFormCode.FormCreate',Self);
  inherited;
	GK:=''; CodCheck:=nil; FTypeEdit:=cteCod;
  DelStack;
end;

function TFormCode.ECodeCheck(Sender: TObject): Boolean;
begin
	AddStack('TFormCode.ECodeCheck',Self);
  inherited;
  if Assigned(CodCheck) then result:=CodCheck(Sender) else result:=KodCheck(Sender,GK);
  DelStack;
end;

procedure TFormCode.ECodeExit(Sender: TObject);
begin
	AddStack('TFormCode.ECodeExit',Self);
  inherited;
  if FTypeEdit=cteCod then SpaceStrSelf(Sender);
  DelStack;
end;

procedure TFormCode.SetTypeEdit;
begin
	AddStack('TFormCode.SetTypeEdit',Self);
	if Value<>FTypeEdit then begin
    ECode.CharCase:=iif(Value=cteName,ecUpperCase,ecNormal); FTypeEdit:=Value;
  end;
  DelStack;
end;

function TFormCode.BrEditProc;
begin
  AddStack('TFormCode.BrEditProc',Self);
  ECode.SetReadOnly(not lApp);
  if lApp then GK:=glkey;
  result:=inherited BrEditProc(lApp,Capt,glkey);
  DelStack;
end;

end.
