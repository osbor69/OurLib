unit FGFView;

interface

{$I LIBTEST}
uses
  Messages, Classes, Controls, ExtCtrls, Menus,
  MyTypes, FRMEMPTY, Keylb, Fpanel, KeyMenu, FFdp, RecDB;

type
  TGFView = class(TFormEmp)
    KeyMenu1: TKeyMenu;
    Fdp1: TFdp;
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
  private
    { Private declarations }
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    procedure AssignFdp(const Capt: string; Proc: TProcValid;
    	const av: array of string; fState: TFdpState; Opt: TFdpOptions;
      const DopKeyStr: string; DopKeyProc: TKeyProc);
  end;

var
  GFView: TGFView;

procedure Fdp(const Capt: string; Proc: TProcValid; const av: array of string;
	fState: TFdpState = fdpView; Opt: TFdpOptions = [];
  const DopKeyStr: string = ''; DopKeyProc: TKeyProc = nil;
  BeforeForm: TProcValid = nil; AfterForm: TNotifyEvent = nil;
  SetDcmModified: TNotifyEvent = nil;
  PrRestPage: TNotifyEvent = nil; PrGraphObj: TGFGraphObjEvent = nil;
  OpenDcmError: TNotifyEvent = nil; PrmEdit: TNotifyEvent = nil; lShow: boolean = true;
  RecPrim: TRecDB = nil);
procedure FdpClose;

implementation

{$R *.DFM}

uses SysUtils,
  My_pr;

procedure Fdp;
begin
	AddStack('FGFView.Fdp');
  try
    CreateForm(TGFView,GFView);
    with GFView do begin
      AssignFdp(Capt,Proc,av,fState,Opt,DopKeyStr,DopKeyProc);
      Fdp1.OnBeforeDocForm:=BeforeForm; Fdp1.OnAfterDocForm:=AfterForm;
      Fdp1.OnSetDcmModified:=SetDcmModified;
      Fdp1.GF.OnRestPage:=PrRestPage; Fdp1.GF.OnGraphObj:=PrGraphObj;
      Fdp1.OnOpenDcmError:=OpenDcmError; Fdp1.OnPrmEdit:=PrmEdit; Fdp1.RecPrim:=RecPrim;
      AddPrnHead(Caption);
{ $IFNDEF NCACT
      Fdp1.DoEnter;
{$ENDIF}
      if lShow then ShowModal
      else begin
        Fdp1.DoEnter; KeyLb1.ExecKey(K_Enter);
      end;
      DelPrnHead;
    end;
  finally
    if lShow then FdpClose;
  end;
  DelStack;
end;

procedure FdpClose;
begin
  AddStack('FGFView.FdpClose');
  if Assigned(GFView) then GFView.Fdp1.DoExit;
  FormFree(GFView); CurFdp:=nil;
  DelStack;
end;

{ TGFView }
procedure TGFView.FormActivate(Sender: TObject);
begin
  AddStack('TGFView.FormActivate',Self);
  inherited;
  Fdp1.SetFocus;
  DelStack;
end;

procedure TGFView.FormDeactivate(Sender: TObject);
begin
  AddStack('TGFView.FormDeactivate',Self);
  inherited;
  ActiveControl:=nil;
  DelStack;
end;

procedure TGFView.AssignFdp;
begin
	AddStack('TGFView.AssignFdp',Self);
  with Fdp1 do begin
    State:=fState; OnProcExec:=Proc; Options:=Opt; AssignFdp(av);
  end;
  KeyLb1.DelKey(K_All,'dopkeys'); KeyLb1.SetKeysSt(DopKeyStr,DopKeyProc,'dopkeys');
  Caption:='Документ: '+Trim(Capt);
  DelStack;
end;

procedure TGFView.WMFormLimit;
begin
	AddStack('TGFView.WMFormLimit',Self);
  inherited;
  FreeLimit(GFView);
  DelStack;
end;

end.
