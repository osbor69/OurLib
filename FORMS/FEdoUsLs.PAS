unit FEdoUsLs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, Menus, DB,
    Grids, DBGrids, ExtCtrls,
  MyTypes, FrmSel, KeyMenu, Browl, Keylb, Fpanel;

type
  TEdoUsLs = class(TFormSel)
    function Browl1TransSeek(Sender: TObject; const Value: String;
      Size: Integer; lQuery: Boolean): String;
  private
    { Private declarations }
    procedure WMFormLimit(var msg: TMessage); message WM_FORMLIMIT;
  protected
    procedure Init; override;
  public
    { Public declarations }
  end;

var
  EdoUsLs: TEdoUsLs;

implementation

{$R *.dfm}

uses My_pr;

procedure TEdoUsLs.Init;
var i: TFio;
begin
  AddStack('TEdoFUs.Init',Self);
  with BrQuery1 do begin
    QryFio([fNAME,'CEH',fRECNO]); Init(DBMain,[fNAME],[fNAME],tUSERS,[Arg[sC_LIST]]);
    Browl1.FieldSeek:=CreateStringField(fNAME,'Пользователь');
    for i:=low(aFio) to high(aFio) do CreateStringField(aFio[i].f);
    CreateStringField('CEH');
  end;
  DelStack;
end;

function TEdoUsLs.Browl1TransSeek(Sender: TObject; const Value: String;
  Size: Integer; lQuery: Boolean): String;
begin
	AddStack('TEdoFUs.Browl1TransSeek');
  result:=TrimUpper(Value);
  DelStack;
end;

procedure TEdoUsLs.WMFormLimit;
begin
  AddStack('TEdoFUs.WMFormLimit');
  inherited;
  FreeLimit(EdoUsLs);
  DelStack;
end;

end.
