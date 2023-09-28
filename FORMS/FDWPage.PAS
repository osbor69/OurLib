unit FDWPage;

interface

uses
  Windows, Messages, Classes, Controls, ExtCtrls, Menus, Grids,
  MyTypes, FRMEMPTY, Keylb, Fpanel, KeyMenu, StrBrowl, RecVal, DefEdit;

type
  TDWPage = class(TFormEmp)
    sb: TStringBrowl;
    KeyMenu1: TKeyMenu;
    Rec: TRecVal;
    de: TDefEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    function sbCalcZn(Sender: TObject; ACol: longint): String;
    function dePnlValid(Sender: TObject): Boolean;
    procedure deFldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure FormShow(Sender: TObject);
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    procedure sbBeforeDrawCell(Sender: TObject; ACol, ARow: longint;
      Rect: TRect; State: TGridDrawState);
    procedure sbKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure sbMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: longint);
  private
    { Private declarations }
		procedure SetKeyForm;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    aCol: array[1..5] of string;
    LsStr,LsPg: TStringList;
    SearchInfo: TDWSearchInfo;
    fListProc: TDWFldListProc;
  end;

var
  DWPage: TDWPage;

implementation

{$R *.DFM}

uses SysUtils,Math,StrUtils,
  My_pr,FFldedit,Inter,Shifr;

procedure TDWPage.FormCreate(Sender: TObject);
var inf: TStrBrInfZn;
	i: TSortMode;
begin
	AddStack('TDWPage.FormCreate',Self);
  inherited;
	LsPg:=TStringList.Create; inf:=sb.InfoCol[1]; inf.LenData:=Length(DEPgSortName(false,smDefault));
  for i:=low(i) to high(i) do MaxSelf(inf.LenData,DEPgSortName(false,i));
  sb.InfoCol[1]:=inf;
  DelStack;
end;

procedure TDWPage.FormDestroy(Sender: TObject);
begin
	AddStack('TDWPage.FormDestroy',Self);
	LsPg.Free;
  inherited;
  DelStack;
end;

procedure TDWPage.FormShow(Sender: TObject);
var fl: boolean;
begin
	AddStack('TDWPage.FormShow',Self);
  inherited;
  fl := SearchInfo.NumObj>=0; sb.Row:=IfThen(fl,SearchInfo.NumPage,1); SetKeyForm;
  if fl then
    if SearchInfo.TypeObj=dwsGF then begin
    	DWPrmSearchGF(SearchInfo); KeyLb1.ExecKey(K_Ctrl_F5);
    end;
  DelStack;
end;

procedure TDWPage.SetKeyForm;
var s: string;
begin
  AddStack('TDWPage.SetKeyForm',Self);
  s:=DlmCopy(LsPg[sb.Row-sb.FixedRows],2,1,UnDelim);
  with KeyLb1 do if (s='0') or (DEPgSortMode(s)<>smDefault)
  	then SetKey(K_Ctrl_F5,'',IfThen(s='0','Редактирование формы','Преобразовать в форму'),
    	KeyLb1ProcKey,'edform',kmFile)
    else DelKey(K_Ctrl_F5,'edform');
  DelStack;
end;

function TDWPage.sbCalcZn(Sender: TObject; ACol: longint): String;
begin
	AddStack('TDWPage.sbCalcZn',Self);
  result:='';
  if Assigned(LsPg) then
    if InRange(sb.Row,1,LsPg.Count) then begin
      result:=DlmCopy(LsPg[sb.Row-1],ACol+1,1,UnDelim);
      if ACol=1 then result:=DEPgSortName(result='0',DEPgSortMode(result));
    end;
  DelStack;
end;

procedure TDWPage.deFldChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TDWPage.deFldChange',Self);
  with TFldEdit(Sender) do if NameRecFld='SORTMODE' then de.SetReadOnly('Form',VarValue<>0);
  DelStack;
end;

function TDWPage.dePnlValid(Sender: TObject): Boolean;
begin
	AddStack('TDWPage.dePnlValid',Self);
  result:=true; aCol[1]:=Rec['NAME']; aCol[2]:=IntToStr(Rec['SORTMODE']);
  aCol[4]:=Bool2Str(Rec['NoVisible']);
  StrShifrSelf(aCol[3]); aCol[5]:=LastVersDefEditPages;
  LsPg[sb.Row-sb.FixedRows]:=ArrayAsList(aCol,UnDelim);
  sb.CurStUpdate; SetKeyForm;
  DelStack;
end;

procedure TDWPage.KeyLb1ProcKey(key: longint; tw: TWinControl);
var lSetMod: boolean;
	s,w: string;
  i,j: longint;
  a: TArrStr;
label lend;
begin
	AddStack('TDWPage.KeyLb1ProcKey',Self);
  if Key in [K_F10,K_Esc] then inherited
  else begin
    DWPageNumEdit:=sb.Row-sb.FixedRows; LsArrFill(LsPg[DWPageNumEdit],aCol,UnDelim);
    if Int0(aCol[5])>=1 then StrDeShifrSelf(aCol[3]);
    if Key=K_Ctrl_F5 then begin
    	lSetMod := aCol[2]<>'0';
      if lSetMod then begin
        w:=LsStr.Text; IfThenDWFldList(fListProc,s,w); s:=''; j:=0;
      	for i:=0 to LsArrDynamic(w,a,CRLF)-1 do begin
        	if (i>0) and StrToBoolean(DEGetArrParam(a[i])[deNewPage]) then Inc(j);
          if j=DWPageNumEdit then IncD(s,a[i]+CRLF);
        end;
      	TDefEdit.ConvertToForm(DEPgSortMode(aCol[2]),s,aCol[3]);
      end;
      if c_EdFormEd(lSetMod) then begin
      	aCol[2]:='0'; StrShifrSelf(aCol[3]); aCol[5]:=LastVersDefEditPages;
        LsPg[DWPageNumEdit]:=ArrayAsList(aCol,UnDelim);
        if lSetMod then begin
	        sb.CurStUpdate; SetKeyForm;
        end;
      end;
    end
    else begin
      Rec['NAME']:=aCol[1]; Rec['SORTMODE']:=IfThen(empty(aCol[2]),1,Int0(aCol[2]));
      Rec['NoVisible']:=StrToBoolean(aCol[4]); de.Execute;
    end;
lend:
    DWPageNumEdit:=-1;
  end;
  DelStack;
end;

procedure TDWPage.WMFormLimit;
begin
	AddStack('TDWPage.WMFormLimit',Self);
  inherited;
  FreeLimit(DWPage);
  DelStack;
end;

procedure TDWPage.sbBeforeDrawCell(Sender: TObject; ACol, ARow: longint;
  Rect: TRect; State: TGridDrawState);
begin
	AddStack('TDWPage.sbBeforeDrawCell',Self);
  if not(gdFixed in State) and InRange(ARow,1,LsPg.Count) then
    if StrToBoolean(DlmCopy(LsPg[ARow-1],4,1,UnDelim)) then with sb.Canvas do
    	if gdSelected in State then Font.Color:=sb.FixedColor else Brush.Color:=sb.FixedColor;
  DelStack;
end;

procedure TDWPage.sbKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
	AddStack('TDWPage.sbKeyUp',Self);
  SetKeyForm;
  DelStack;
end;

procedure TDWPage.sbMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: longint);
begin
	AddStack('TDWPage.sbMouseUp',Self);
  SetKeyForm;
  DelStack;
end;

end.
