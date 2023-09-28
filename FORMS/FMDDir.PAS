unit FMDDir;

interface

uses
  Messages, SysUtils, Classes, Controls, Forms, ExtCtrls, Grids, Menus,
  MyTypes, ModelGet, FRMEMPTY, Keylb, Fpanel, StrBrowl, KeyMenu, RecVal, DefEdit;

type
  TMDDir = class(TFormEmp)
    sb: TStringBrowl;
    KeyMenu1: TKeyMenu;
    de: TDefEdit;
    function sbCalcZn(Sender: TObject; ACol: longint): String;
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure deKpProcKey(key: longint; tw: TWinControl);
    procedure sbAfterPaint(Sender: TObject);
    procedure sbWidthCols(Sender: TObject; ACol: longint);
    procedure FormDestroy(Sender: TObject);
    procedure sbMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: longint);
    procedure dePnlCngKey(Sender: TObject; var tb: TKeyBut);
  private
    { Private declarations }
    ls: TStringList;
    Rec: TRecVal;
    Model: TModelGet;
    lEmp,flCopy: boolean;
    FSortType: TMDSortType;
    PSelRow: PString;
    CopyType: (mdcAsk,mdcRewrite,mdcPass,mdcAbort);
    FToPath: TFileName;
		procedure SetSortType(v: TMDSortType);
		procedure FillList(lsSel: TStringList);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

uses Windows,Graphics,DB,Math,StrUtils,
  My_pr;

const aColSort: TMDSortInt = (1,2,4);
	SelIs='+';

var aForm: array of TMDDir;
  nForm: longint;

procedure TMDDir.FormCreate(Sender: TObject);
begin
	AddStack('TMDDir.FormCreate',Self);
  inherited;
  ls:=TStringList.Create; Rec:=TRecVal.Create(Self);
  Rec.CreateFld('COD',ftString,MDLenFile,''); de.Param['COD',deNameRec]:=Rec.NameRec;
  with InitFIni[fiSave] do
    if ValueExists('MDDir','SortDate') then begin
      FSortType:=iif(ReadBool('MDDir','SortDate'),mstDate,mstCod);
      DeleteKey('MDDir','SortDate');
    end
    else FSortType:=TMDSortType(ReadInteger('MDDir','SortType',byte(mstCod)));
  DelStack;
end;

procedure TMDDir.FormDestroy(Sender: TObject);
begin
	AddStack('TMDDir.FormDestroy',Self);
  InitFIni[fiSave].WriteInteger('MDDir','SortType',byte(FSortType)); ls.Free;
  inherited;
  DelStack;
end;

function MDDirExec(const sPath,ToPath: TFileName; AModel: TModelGet;
  var SelRow: string; lCopy: boolean): boolean;
var lsSel: TStringList;
begin
	AddStack('FMDDir.MDDirExec');
  if Length(aForm)=nForm then SetLength(aForm,nForm+1);
  CreateForm(TMDDir,aForm[nForm]);
  with aForm[nForm] do begin
    Inc(nForm);
  	Model:=AModel; PSelRow:=@SelRow; flCopy:=lCopy; lsSel:=nil;
    try
      if lCopy then begin
        Model.Root:=CorrDir(sPath); Caption:='Основы из папки '+Model.Root; FToPath:=ToPath;
      end
      else begin
        Caption:=Model.FrmCaption; lsSel:=SortStrListCreate; LsArrList(SelRow,lsSel,',');
      end;
      FillList(lsSel); result := ShowModal=mrOk; Model.Root:='';
    finally
      lsSel.Free; Dec(nForm); FormFree(aForm[nForm]);
    end;
  end;
  DelStack;
end;

procedure TMDDir.FillList;
var j: longint;
  fl: boolean;
  procedure sbRow;
  begin
    AddStack('TMDDir.FillList.sbRow',Self);
    if fl then begin
      fl:=false; sb.Row:=j;
    end;
    DelStack;
  end;
var i: longint;
begin
  AddStack('TMDDir.FillList',Self);
  sb.Init; Model.LoadList(ls,FSortType); lEmp := ls.Count=0; fl:=not Visible;
  for i:=0 to ls.Count-1 do begin
    Model.LoadFromFile(ls[i]);
    if i>0 then sb.IncRowCount;
    j:=sb.RowCount-1; sb.Cells[1,j]:=ls[i]; sb.Cells[2,j]:=Model.MDName;
    sb.Cells[3,j]:=SpaceStr(Model.NSave,lNSave);
    sb.Cells[4,j]:=FormatDateTime('dd/mm/yyyy (hh:nn)',My_pr.GetFileDateTime(Model.Path+ls[i]));
    if Assigned(lsSel) then begin
    	if lsSel.IndexOf(ls[i])>=0 then begin
        sb.Cells[0,j]:=SelIs; sbRow;
      end;
    end
    else if ls[i]=PSelRow^ then sbRow;
  end;
  MainRebuild;
  DelStack;
end;

function TMDDir.sbCalcZn(Sender: TObject; ACol: longint): String;
const a: array[0..2] of Byte = (1,MDLenFile,MDLenName);
var l: longint;
begin
	AddStack('TMDDir.sbCalcZn',Self);
  if InRange(ACol,low(a),high(a)) then l:=a[ACol] else l:=lNSave;
  result:=Space(l);
  DelStack;
end;

procedure TMDDir.KeyLb1ProcKey(key: longint; tw: TWinControl);
	procedure Fill(const s: string);
	var i: longint;
  begin
  	AddStack('TMDDir.KeyLb1ProcKey.Fill',Self);
  	for i:=sb.FixedRows to sb.RowCount-1 do sb.Cells[0,i]:=s;
    DelStack;
  end;
var fl: boolean;
begin
	AddStack('TMDDir.KeyLb1ProcKey',Self);
	inherited;
	if not lEmp then with sb do case Key of
    K_Space,K_Ins: begin
    	Cells[0,Row]:=IfThen(empty(Cells[0,Row]),SelIs);
      if (Key=K_Ins) and (Row<RowCount-1) then IncRow;
    end;
  	K_F2,K_F3,K_Plus,K_Minus: begin
      fl := Key in [K_F2,K_Plus];
      if AskSel(fl) then Fill(IfThen(fl,SelIs));
    end;
    K_F5: if Model.LoadFromFile(Cells[1,Row],[mdldCheckSum]) then
    	if Length(Model.MDPrim)>0 then begin
        AddPrnHead([Model.FrmCaption,Trim(Model.MDFile)+': '+Model.MDName]);
        EdTextView(Model.MDName,Model.MDPrim[0].Prim);
        DelPrnHead(2);
      end;
    K_F11: if FSortType=high(FSortType) then SetSortType(low(FSortType)) else SetSortType(Succ(FSortType));
    K_Enter: begin
    	Fill(''); Cells[0,Row]:=SelIs; ModalResult:=mrOk;
    end;
  end;
  DelStack;
end;

procedure TMDDir.FormClose(Sender: TObject; var Action: TCloseAction);
var ds,dd,fCopy: string;
	i: longint;
  fl: boolean;
label lend;
begin
	AddStack('TMDDir.FormClose',Self);
  inherited;
  if ModalResult=mrOk then begin
    ds:=Model.Path; dd:=CorrDir(FToPath)+DirModels+Model.Prefix+PathDelim;
    CopyType:=mdcAsk; fl:=false;
    if not flCopy then PSelRow^:='';
    for i:=sb.FixedRows to sb.RowCount-1 do begin
    	if CopyType=mdcAbort then goto lend;
      if not empty(sb.Cells[0,i]) then begin
      	fCopy:=sb.Cells[1,i];
      	if flCopy then begin
          if MyFileExists(dd+fCopy) and (CopyType<>mdcRewrite) then begin
            if CopyType=mdcPass then begin
              fl:=true; continue;
            end;
            de.FrmCaption:='Основа "'+Trim(fCopy)+'" уже есть.'; Rec['COD']:=fCopy;
            if not de.Execute.Saved then begin
              fl:=true; continue;
            end;
            fCopy:=TrimRight(Rec['COD']);
          end;
          sb.Cells[0,i]:=''; PSelRow^:=fCopy; CopyFileOpt(ds+sb.Cells[1,i],dd+fCopy,[cfMsg]);
        end
        else IncD(PSelRow^,fCopy+',');
      end;
    end;
    if not flCopy then DecLen(PSelRow^);
    if fl then begin
    	mess_ok(['Внимание !','Были скопированы не все основы.']); Action:=caNone;
    end;
  end;
lend:
	DelStack;
end;

procedure TMDDir.deKpProcKey(key: longint; tw: TWinControl);
var k: longint;
begin
	AddStack('TMDDir.deKpProcKey',Self);
	k:=K_Esc;
	case Key of
    K_Ctrl_Q: CopyType:=mdcAbort;
    K_F2: begin
    	CopyType:=mdcRewrite; k:=K_F10;
    end;
    K_F3: CopyType:=mdcPass;
  end;
  FormKeyLb(tw).ExecKey(k);
  DelStack;
end;

procedure TMDDir.dePnlCngKey(Sender: TObject; var tb: TKeyBut);
begin
  AddStack('TMDDir.dePnlCngKey',Self);
	with tb do case Key of
    K_F10: Caption:='Записать';
    K_Alt_Z: Caption:='';
  end;
  DelStack;
end;

procedure TMDDir.sbAfterPaint(Sender: TObject);
	procedure Paint1(j: longint);
  begin
  	AddStack('TMDDir.sbAfterPaint.Paint1',Self);
    sb.bmCheckPaint(0,j);
    DelStack;
  end;
var j: longint;
	Rect: TRect;
begin
	AddStack('TMDDir.sbAfterPaint',Self);
  Rect:=sb.CellRect(aColSort[FSortType],0); Frame3D1(sb.Canvas,Rect);
	with sb do begin
  	Canvas.Brush.Color:=Color;
    for j:=max(TopRow,FixedRows) to min(TopRow+VisibleRowCount,RowCount)-1 do Paint1(j);
    Canvas.Brush.Color:=clHighlight; Paint1(Row);
  end;
  DelStack;
end;

procedure TMDDir.sbWidthCols(Sender: TObject; ACol: longint);
begin
	AddStack('TMDDir.sbWidthCols',Self);
  inherited;
  if ACol=0 then sb.MaxColWidths(ACol,bmCheckSize.cX+2);
  DelStack;
end;

procedure TMDDir.SetSortType;
var a: TArrStr;
	i,l: longint;
begin
  AddStack('TMDDir.SetSortType',Self);
  if FSortType<>v then with sb do begin
    SetLength(a,RowCount-FixedRows); l:=0;
    for i:=FixedRows to RowCount-1 do if Cells[0,i]=SelIs then begin
      a[l]:=Cells[1,i]; Inc(l);
    end;
    QuickSort(a,l); FSortType:=v; FillList(nil);
    for i:=FixedRows to RowCount-1 do if QuickFind(Cells[1,i],a,l) then Cells[0,i]:=SelIs;
    sb.Refresh;
  end;
  DelStack;
end;

procedure TMDDir.sbMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: longint);
var ACol,ARow: longint;
begin
	AddStack('TMDDir.sbMouseUp',Self);
	sb.MouseToCell(X,Y,ACol,ARow);
  if ARow<sb.FixedRows then if ArrIntFind(ACol,aColSort,ARow) then SetSortType(TMDSortType(ARow));
  DelStack;
end;

procedure TMDDir.WMFormLimit;
var i: longint;
begin
	AddStack('TMDDir.WMFormLimit',Self);
  inherited;
  for i:=low(aForm) to high(aForm) do if FreeLimit(aForm[nForm]) then break;
  DelStack;
end;

initialization
  AddStack('FMDDir.initialization');
  ModelGet.MDDirExec:=MDDirExec;
  DelStack;
end.
