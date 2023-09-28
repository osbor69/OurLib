unit FrmSumm;

interface

{$I LIBTEST}
uses
	Messages, Classes, Controls, Grids, ExtCtrls,
	MyTypes, fsumm, FRMEMPTY, Keylb, Fpanel, StrBrowl, DefEdit, RecVal, Menus,
  KeyMenu;

type
  TStrTableSumm = class(TStrTable)
  private
    al,ali,af: TArrInt;
    ac: TArrSummColInf;
    ll,lf: longint;
    sm: Tsumm;
    lSender: boolean;
    FPrmNum: PFmtNum;
    FProcHead: TFormSummHead;
    FNSumm: byte;
    Fl,Fc: string;
    procedure TblFill(const sX,sY: string);
    procedure sgFill(Sender: TObject);
  protected
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    function GetFindOptions: TFindOptions; override;
    procedure PrFindAll(ARow: longint); override;
    procedure FilteredChanged; override;
  public
    FPrmHead: pointer;
    function AlignCell(ACol,ARow: longint): TAlignment; override;
  end;

	TFormSumm = class(TFormEmp)
    Rec: TRecVal;
    de: TDefEdit;
    KeyMenu1: TKeyMenu;
    procedure FormCreate(Sender: TObject);
	private
		{ Private declarations }
    procedure ProcKey(key: longint; tw: TWinControl);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
	public
		{ Public declarations }
    sg: TStrTableSumm;
  end;

implementation

{$R *.DFM}

uses Windows,StrUtils,Math,SysUtils,
  My_pr,FFdp;

var FormSumm: TFormSumm;

{ TStrTableSumm }
function TStrTableSumm.AlignCell;
const Algm: array[TSumType] of TAlignment = (taRightJustify,taLeftJustify);
var X,Y: Word;
begin
  AddStack('TStrTableSumm.AlignCell',Self);
  result:=inherited AlignCell(ACol,ARow);
  if (ACol>=FixedCols) and (ARow>=FixedRows) then begin
    ColRowToXY(ACol,ARow,X,Y);
    if InRange(X,low(ac),high(ac)) then result:=Algm[ac[X].rtype];
  end;
  DelStack;
end;

procedure TStrTableSumm.MouseMove;
var ACol,ARow: longint;
  wX,wY: Word;
  s: string;
begin
  AddStack('TStrTableSumm.MouseMove',Self);
  inherited;
  MouseToCell(X,Y,ACol,ARow); s:='';
  if InRange(ACol,0,ColCount-1) then if InRange(ARow,0,RowCount-1) then begin
    Canvas.Font.Assign(IfThen((ACol<FixedCols) or (ARow<FixedRows),TitleFont,Font));
    with CellRect(ACol,ARow) do if Canvas.TextWidth(Cells[ACol,ARow])>Right-Left then begin
      ColRowToXY(ACol,ARow,wX,wY); s:=Cells[ACol,ARow];
    end;
  end;
  ShowHint := s<>''; Hint:=s;
  DelStack;
end;

const alc: array[boolean] of TSummLineCol = (s_line,s_col);

procedure TStrTableSumm.TblFill;
var lCur: boolean;
  function Head1(ls: TStrings; lc: TSummLineCol; const s,sFill: string; var iFill: Word): longint;
  var	i: longint;
    head: string;
  begin
    AddStack('TStrTableSumm.TblFill.Head1',Self);
    iFill:=0;
    if (lc=alc[Inverted]) and Filtered then begin
      result:=lf; CopyFromInt(al,af);
    end
    else result:=sm.ArrName(lc,al,s);
    if result=0 then ls.Text:='[íåò]'
    else begin
      ls.Clear;
      for i:=0 to result-1 do begin
        head:=sm.aName[lc][al[i]];
        if lCur and Assigned(FProcHead) then FProcHead(FPrmHead,lc,head);
        head:=TrnsABC(head); ls.Add(head);
        if head=sFill then iFill:=i;
      end;
    end;
    DelStack;
  end;
var i: longint;
  X,Y: Word;
begin
  AddStack('TStrTableSumm.TblFill',Self);
  if lSender then lCur:=true
  else begin
    sm:=Summ; lCur := NumSumm=FNSumm;
  end;
  i:=Head1(HeadX,s_col,IfThen(lCur,Fc),sX,X); SetLength(ac,i);
  for i:=0 to i-1 do ac[i]:=sm.ColInf(al[i]);
  ll:=Head1(HeadY,s_line,IfThen(lCur,Fl),sY,Y); SetLength(ali,ll); Dec(ll);
  for i:=0 to ll do ali[i]:=sm.LineInf(al[i]);
  Fill(X,Y,[tbfTopLeft]);
  DelStack;
end;

procedure TStrTableSumm.sgFill;
var	i,j: longint;
  t: variant;
begin
  AddStack('TStrTableSumm.sgFill',Self);
  for i:=low(ac) to high(ac) do
    for j:=0 to ll do begin
      t:=sm.Value(ac[i],ali[j]);
      if MyVarType(t,true)=varDouble then FmtNumSelf(t,FPrmNum^);
      DatCells[i,j]:=TrnsABC(t);
    end;
  DelStack;
end;

function TStrTableSumm.GetFindOptions;
begin
  AddStack('TStrTableSumm.GetFindOptions',Self);
  result:=inherited GetFindOptions;
  if BrFindAll then Exclude(result,fnoDirection) else Include(result,fnoAll);
  DelStack;
end;

procedure TStrTableSumm.PrFindAll;
var i: longint;
begin
  AddStack('TStrTableSumm.PrFindAll',Self);
  if ARow=0 then begin
    lf:=0; i:=RowCount-FixedRows;
    if Length(af)<i then SetLength(af,i);
  end
  else begin
    af[lf]:=al[ARow-FixedRows]; Inc(lf);
  end;
  DelStack;
end;

procedure TStrTableSumm.FilteredChanged;
var X,Y: Word;
  sX,sY: string;
begin
  AddStack('TStrTableSumm.FilteredChanged',Self);
  if not(csDestroying in ComponentState) then begin
    ColRowToXY(X,Y);
    if X<HeadX.Count then sX:=HeadX[X] else sX:='';
    if Y<HeadY.Count then sY:=HeadY[Y] else sY:='';
    TblFill(sX,sY);
  end;
  DelStack;
end;

{ TFormSumm }
procedure TFormSumm.FormCreate(Sender: TObject);
begin
  AddStack('TFormSumm.FormCreate',Self);
  sg:=TStrTableSumm.Create(Self);
  with sg do begin
    Parent:=RbPanel2; AlignCells:=taLeftJustify; OnFill:=sgFill;
  end;
  inherited;
  de.Param['NTBL',deMask]:=StrNum('1,',MaxByte);
  DelStack;
end;

procedure FormSummExec(const sl: string = ''; const sc: string = ''; const Capt: string = '';
  const CaptX: string = ''; const CaptY: string = '';
  ProcHead: TFormSummHead = nil; PrmHead: pointer = nil; PrmNum: PFmtNum = nil; Sender: TObject = nil;
  ProcShow: TNotifyEvent = nil; FNoColWidthsCorr: boolean = false);
const PrmNumDef: TFmtNum = (FracDlm:','; FracCnt:4);
begin
  AddStack('FrmSumm.FormSummExec');
  CreateForm(TFormSumm,FormSumm);
  with FormSumm,sg do begin
    FNSumm:=NumSumm; Caption:=Capt;
    CaptX:=ReplVar(CaptX,'ÑÒÎËÁÖÛ'); CaptY:=ReplVar(CaptY,'ÑÒÐÎÊÈ'); NoColWidthsCorr:=FNoColWidthsCorr;
    FPrmNum:=IfThen(PrmNum,@PrmNumDef);
    FProcHead:=ProcHead; FPrmHead:=PrmHead; Fl:=sl; Fc:=sc; lSender:=Assigned(Sender);
    with KeyLb1 do begin
      if lSender then begin
        sm:=pointer(Sender); DelKey(K_All,'summ');
      end
      else SetKeys([K_F3,K_Alt_G],'Ñìåíèòü','Ñìåíèòü íîìåð òàáëèöû',ProcKey,'summ',kmFile);
      ReDrw;
    end;
    TblFill('',''); IfThenNotify(ProcShow,FormSumm);
    Showmodal; NumSumm(FNSumm);
    if not FormFree(FormSumm) then FormSumm.sg.Filtered:=false;
  end;
  DelStack;
end;

procedure TFormSumm.WMFormLimit;
begin
	AddStack('TFormSumm.WMFormLimit',Self);
  inherited;
  FreeLimit(FormSumm);
  DelStack;
end;

procedure TFormSumm.ProcKey;
begin
  AddStack('TFormSumm.ProcKey',Self);
  Rec['NTBL']:=NumSumm;
  if de.Execute.Saved then begin
    sg.Filtered:=false; NumSumm(Rec['NTBL']); sg.TblFill('','');
  end;
  DelStack;
end;

initialization
  AddStack('FrmSumm.initialization');
  MyTypes.FormSummExec:=FormSummExec;
  DelStack;
end.
