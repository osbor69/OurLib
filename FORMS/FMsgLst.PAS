unit FMsgLst;

interface

{$I LIBTEST}
uses
  Classes, Controls, Menus, DB, Grids, DBGrids, ExtCtrls,
  FRMBRIB, KeyMenu, mulqry, Browl, Keylb, Fpanel;

type
  TMsgLst = class(TFormBrIB)
    procedure Browl1BrowlKey(key: longint; tw: TWinControl);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    BrQuery1DSEND: TField;
    BrQuery1SDSEND: TStringField;
    Qry: Tmulquery;
    procedure BrQuery1CalcFields(DataSet: TDataSet);
  public
    { Public declarations }
		class function Execute(const SDateReg: string; var MsgLst: TMsgLst; AConnection: TComponent): boolean;
  end;

implementation

{$R *.DFM}

uses SysUtils,StrUtils,Forms, 
  MyTypes,My_pr,Tone;

const FmtDSend = 'dd/mm/yyyy tt';

procedure TMsgLst.FormCreate(Sender: TObject);
begin
  AddStack('TMsgLst.FormCreate',Self);
  inherited;
  Qry:=Tmulquery.Create(Self);
  DelStack;
end;

class function TMsgLst.Execute;
var vs: boolean;
  dsend: string;
begin
	AddStack('TMsgLst.Execute');
  result:=false;
  if CreateForm(TMsgLst,MsgLst) then with MsgLst do begin
    with BrQuery1 do begin
      dsend:=RegDt(fMsgsDSEND);
      Init(nil,[dsend],[dsend],GetList([tMSGS,tREGS]),
        [tREGS+'.'+fNAME,tREGS+'.COMP',tREGS+'.'+fIP,tMSGS+'.MSG',tMSGS+'.'+dsend],
        tMSGS+'.'+RegDt(fMsgsDRFROM)+'='+tREGS+'.'+RegDt+sAND+tMSGS+'.'+RegDt+'='+SDateReg,
        '',BrQuery1CalcFields);
      CreateStringField('MSG','Текст сообщения');
      BrQuery1SDSEND:=CreateStringField('SDSEND','Когда',Length(FormatDateTime(FmtDSend,Now)));
      CreateStringField(fNAME,'От кого');
      CreateStringField('COMP','Компьютер');
      CreateStringField(fIP,'IP-адрес');
      BrQuery1DSEND:=CreateField(dsend);
    end;
    with Qry do begin
      Connection:=PswdPrm.DBMain; Arg[sTABLE]:=tMSGS; Arg[sWHERE]:=RegDt+'='+SDateReg;
      SetPart(sDW_TABLE);
    end;
  end;
	with MsgLst do begin
    BrQuery1.Connection:=AConnection; Qry.Connection:=AConnection; vs:=Visible;
    if vs
    then Browl1.BrUpdate(Browl1.Row,BrQuery1.FieldZn(RegDt(fMsgsDSEND)),RegDt(fMsgsDSEND))
    else BrQuery1.Open;
    if vs then begin
      if not BrQuery1.IsRecords then begin
        ModalResult:=mrCancel; BrQuery1.Close;
      end;
    end
    else begin
      if not BrQuery1.Eof then begin
        Application.Restore; Application.BringToFront; MelodyOn(aSndSmith); ApplTitle.SetActive(Caption,true);
        try
	        ShowModal;
        finally
          MelodyOff; ApplTitle.SetActive(Caption,false);
        end;
        Qry.ExecSQL; result:=true;
      end;
      BrQuery1.Close;
    end;
  end;
  DelStack;
end;

procedure TMsgLst.BrQuery1CalcFields;
var d: TDateTime;
begin
	AddStack('TMsgLst.BrQuery1CalcFields',Self);
  with MulQueryOwner(DataSet) do begin
  	if DrvCan('DateTime') then d:=BrQuery1DSEND.AsDateTime
    else d:=qStrToDateTime(BrQuery1DSEND.AsString);
    BrQuery1SDSEND.AsString:=FormatDateTime(FmtDSend,d);
  end;
  DelStack;
end;

procedure TMsgLst.Browl1BrowlKey(key: longint; tw: TWinControl);
var v: variant;
begin
  AddStack('TMsgLst.Browl1BrowlKey',Self);
  if BrQuery1.DrvCan('DateTime') then v:=BrQuery1DSEND.AsDateTime else v:=BrQuery1DSEND.AsString;
  Browl1.BrUpdate(Browl1.Row,v,RegDt(fMsgsDSEND));
  DelStack;
end;

initialization
  AddStack('FMsgLst.initialization');
  SetPrim(tMSGS,'Сообщения');
  DelStack;
end.
