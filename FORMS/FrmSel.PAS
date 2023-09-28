unit FrmSel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, Menus,
    ExtCtrls, DB, Grids, DBGrids,
  MyTypes, FrmBrIB, KeyMenu, Browl, Keylb, Fpanel, CodeGets;

type
  TFormSel = class(TFormBrIB)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Browl1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    { Private declarations }
    BrQuery1SEL: TBooleanField;
    ls: TStringList;
    g: TCodeGet;
    procedure ProcKey(key: Integer; tw: TWinControl);
    function lsStr: string;
		procedure WMRebuild(var Message: TWMRebuild); message WM_REBUILD;
  protected
    procedure Init; virtual; abstract;
    procedure BrQuery1CalcFields(DataSet: TDataSet); virtual;
    function SelVisible: boolean;
  public
    { Public declarations }
    class procedure Execute(Sender: TObject; FormClass: TFormClass; var Reference; lFree: boolean = true);
  end;

var
  FormSel: TFormSel;

implementation

{$R *.dfm}

uses My_pr,FFldEdit;

class procedure TFormSel.Execute;
var tf: TFldEdit;
  bm: TBookMark;
  i: longint;
  ov,v: string;
begin
  AddStack('TFormSel.Execute');
	CreateForm(FormClass,Reference,true);
  with TFormSel(Reference) do begin
    BrQuery1SEL.Visible:=true; Browl1.CloseOnSelect:=true; SaveIniForm;
    tf:=pointer(Sender); g:=pointer(tf.curget.SelCodeGet); PlaceToControl(tf);
    ls.Sorted:=false; ls.Text:=TrimRight(StrTran(tf.Value,',',CRLF));
    for i:=0 to ls.Count-1 do begin
      if Assigned(g) then ls[i]:=g.TransSeek(ls[i]);
      TrimSelf(ls,i);
    end;
    ls.Sorted:=true;
    with BrQuery1 do begin
      Open; bm:=GetBookMark; First;
      while not Eof do begin
        if ls.Find(lsStr,i) then ls.Objects[i]:=ObjectTrue;
        Next;
      end;
      GotoBookMark(bm); FreeBookMark(bm);
    end;
    BoolObjPack(ls); ov:=TrimRight(ls.Text);
    with KeyLb1 do begin
      SetKeys([K_Space,K_Enter,K_Ins],'־עלועטעü','',ProcKey,'sel',kmList);
      SetKeySel([K_Plus],[K_Minus],ProcKey,'sel');
    end;
    if ShowModal=mrOk then begin
      if ls.Count=0 then ls.Add(lsStr);
      v:=TrimRight(ls.Text);
      if v<>ov then tf.Value:=StrTran(v,CRLF,',');
    end;
    BrQuery1SEL.Visible:=false; Browl1.CloseOnSelect:=false; RestIniForm; KeyLb1.DelKey(K_All,'sel');
  end;
  if lFree then FormFree(Reference);
  DelStack;
end;

procedure TFormSel.FormCreate(Sender: TObject);
begin
  AddStack('TFormSel.FormCreate',Self);
  inherited;
  ls:=TStringList.Create; Init;
  with BrQuery1 do begin
    BrQuery1SEL:=CreateBooleanField('SEL'); BrQuery1SEL.Index:=0; BrQuery1SEL.Visible:=false;
    OnCalcFields:=BrQuery1CalcFields;
  end;
  DelStack;
end;

procedure TFormSel.FormDestroy(Sender: TObject);
begin
  AddStack('TFormSel.FormDestroy',Self);
  ls.Free;
  inherited;
  DelStack;
end;

procedure TFormSel.FormShow(Sender: TObject);
begin
  AddStack('TFormSel.FormShow',Self);
  inherited;
  if SelVisible then MainRebuild;
  DelStack;
end;

procedure TFormSel.BrQuery1CalcFields(DataSet: TDataSet);
begin
	AddStack('TFormSel.BrQuery1CalcFields',Self);
  if SelVisible then BrQuery1SEL.AsBoolean := ls.IndexOf(lsStr)>=0;
  DelStack;
end;

procedure TFormSel.WMRebuild;
begin
  AddStack('TFormSel.WMRebuild',Self);
  if Message.Oper=rbBefore then
  if Assigned(BrQuery1SEL) then
  if SelVisible then Browl1.ColWidths[0]:=bmCheckSize.cX+2;
  DelStack;
end;

procedure TFormSel.Browl1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  AddStack('TFormSel.Browl1DrawColumnCell',Self);
  inherited;
  Browl1.bmCheckPaint(Rect,Column);
  DelStack;
end;

procedure TFormSel.ProcKey;
var bm: TBookMark;
begin
  AddStack('TFormSel.ProcKey',Self);
  if BrQuery1.CanEdit(key) then case Key of
    K_Plus: if AskSel(true) then with BrQuery1 do begin
      bm:=GetBookMark; DisableControls; First;
      while not Eof do begin
        ls.Add(lsStr); Next;
      end;
      GotoBookMark(bm); FreeBookMark(bm); EnableControls;
    end;
    K_Minus: if AskSel(false) then begin
      ls.Clear; Browl1.BrUpdate;
    end;
  else
    IgnoreSlAddDel(ls,lsStr); Browl1.BrUpdate;
    if Key=K_Ins then BrQuery1.Next;
  end;
  DelStack;
end;

function TFormSel.lsStr;
begin
  AddStack('TFormSel.lsStr',Self);
  result:=Browl1.FieldSeek.AsString;
  if Assigned(g) then result:=g.TransSeek(result);
  TrimSelf(result);
  DelStack;
end;

function TFormSel.SelVisible;
begin
  AddStack('TFormSel.SelVisible',Self);
  result:=BrQuery1SEL.Visible;
  DelStack;
end;

end.
