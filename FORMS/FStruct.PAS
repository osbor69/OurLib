unit FStruct;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, ExtCtrls, Grids, DB, Math, StrUtils,
  MyTypes, My_pr, FRMEMPTY, Keylb, Fpanel, StrBrowl;

type
  TStruct = class(TFormEmp)
    RbStatus1: TRbStatus;
    pnsb: TRbPanel;
    sb: TStringBrowl;
    procedure FormShow(Sender: TObject);
    procedure sbDrawCell(Sender: TObject; ACol,ARow: longint; Rect: TRect;
      State: TGridDrawState);
  private
    { Private declarations }
    nRow,lTbl: longint;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    procedure AddRows(CntRow: longint);
    procedure AddRow(const tbl,nmf: string; DataType: TFieldType; Size: longint; NotNull: boolean);
    class procedure Init(const Capt: TCaption; CntRow: longint);
  end;

var
  Struct: TStruct;

implementation

{$R *.dfm}

class procedure TStruct.Init;
begin
  AddStack('TStruct.Init');
  CreateForm(TStruct,Struct); Struct.Caption:=Capt; Struct.sb.Init;
  Struct.nRow:=Struct.sb.FixedRows; Struct.AddRows(CntRow); Struct.lTbl:=0;
  DelStack;
end;

procedure TStruct.AddRows;
begin
  AddStack('TStruct.AddRows',Self);
  if CntRow>0 then sb.IncRowCount(CntRow-IfThen(nRow=sb.FixedRows,1));
  DelStack;
end;

procedure TStruct.AddRow;
begin
  AddStack('TStruct.AddRow',Self);
  sb.Cells[0,nRow]:=tbl; MaxSelf(lTbl,tbl);
  sb.Cells[1,nRow]:=nmf;
  case DataType of
    ftString: begin
      sb.Cells[2,nRow]:='строка'; sb.Cells[3,nRow]:=IntToStr(Size);
    end;
    ftInteger: sb.Cells[2,nRow]:='целое';
    ftBoolean: sb.Cells[2,nRow]:='логическое';
    ftFloat: sb.Cells[2,nRow]:='число';
    ftDate: sb.Cells[2,nRow]:='дата';
    ftBlob: sb.Cells[2,nRow]:='текст';
  end;
  if NotNull then sb.Cells[4,nRow]:='+';
  Inc(nRow);
  DelStack;
end;

procedure TStruct.FormShow(Sender: TObject);
var si: TStrBrInfZn;
begin
  AddStack('TStruct.FormShow',Self);
  inherited;
  si:=sb.InfoCol[0]; si.LenData:=lTbl; si.aName[0]:=IfThen(lTbl>0,'Таблица'); sb.InfoCol[0]:=si;
  RbStatus1.Caption:=StrNum(' Количество полей: ',nRow-sb.FixedRows); MainRebuild;
  DelStack;
end;

procedure TStruct.sbDrawCell(Sender: TObject; ACol,ARow: longint;
  Rect: TRect; State: TGridDrawState);
begin
  AddStack('TStruct.sbDrawCell',Self);
  if not(gdFixed in State) and (ACol=4) then sb.bmCheckPaint(ACol,ARow);
  DelStack;
end;

procedure TStruct.WMFormLimit;
begin
	AddStack('TStruct.WMFormLimit',Self);
  inherited;
  FreeLimit(Struct);
  DelStack;
end;

end.
