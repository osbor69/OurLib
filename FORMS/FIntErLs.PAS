unit FIntErLs;

interface

{$I LIBTEST}
uses
  Windows, Messages, Classes, Controls, Forms, ExtCtrls, Menus, StdCtrls,
  MyTypes, FRMEMPTY, Keylb, Fpanel, RbScroll, Inter, FEdText, KeyMenu, Schem, ListF2;

type
  TIntErLs = class(TFormEmp)
    pnStack: TRbPanel;
    RbPanel3: TRbPanel;
    RbStatus1: TRbStatus;
    RbPanel4: TRbPanel;
    PnCtrl: TRbPanel;
    RbScrollBox1: TRbScrollBox;
    PnMemo: TRbPanel;
    KeyMenu1: TKeyMenu;
    mnDebug: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure PnMemoEnter(Sender: TObject);
    procedure PnMemoExit(Sender: TObject);
  private
    { Private declarations }
    lsStack: TFindListBox;
    rStack: longint;
    FSender: TControl;
    FPrmBeforeShowError: pointer;
    procedure lsStackKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lsStackMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
    procedure lsStackDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ReadStack;
    procedure ProcKey(key: longint; tw: TWinControl);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
    procedure WMSchem(var msg: TWMSchem); message WM_SCHEM;
  public
    { Public declarations }
    MemoView: TInterMemo;
  end;

  PIntErrPrm = ^TIntErrPrm;
  TIntErrPrm = record
    lsStack: TFindListBox;
    RbScrollBox1: TScrollBox;
    ProcentCtrl: TProcent;
    ViewCtrl: TControl;
  end;

  TWMIntErr = record
   	Msg: longint;
    Prm: PIntErrPrm;
		PrmShow: pointer;
    Result: LongInt;
  end;

implementation

{$R *.dfm}

uses Graphics,StrUtils,
  My_pr;

var aForm: array of TIntErLs;
  nForm: longint = -1;

procedure TIntErLs.FormCreate(Sender: TObject);
begin
  AddStack('TIntErLs.FormCreate',Self);
  lsStack:=TFindListBox.Create(Self);
  with lsStack do begin
    Parent:=pnStack; Style:=lbOwnerDrawFixed; Align:=alClient;
    OnDrawItem:=lsStackDrawItem; OnKeyUp:=lsStackKeyUp; OnMouseUp:=lsStackMouseUp;
  end;
  RbStatus1.SectType[mstLeft,0]:=1;
  MemoView:=TInterMemo.CreateParent(Self,pnMemo); MemoView.CallTipDwellType:=ctdwDebug;
  MemoView.Align:=alClient; ActiveControl:=MemoView.Control;
  inherited;
  DelStack;
end;

procedure TIntErLs.ReadStack;
var Txt: string;
  Prm: TIntErrPrm;
  i,j,l: longint;
begin
  AddStack('TIntErLs.ReadStack',Self);
  i:=lsStack.ItemIndex;
  if rStack<>i then begin
    if rStack>=0 then MemoView.SaveIdent;
    rStack:=i; CurInter:=TInter(lsStack.Items.Objects[rStack]);
    InterErr:=CurInter;
    if Assigned(CurInter.GetAlgProc) then CurInter.GetAlgProc(CurInter,Txt) else Txt:=CurInter.GetAlgPrm;
    Prm.lsStack:=lsStack; Prm.RbScrollBox1:=RbScrollBox1;
    Prm.ProcentCtrl:=0; Prm.ViewCtrl:=nil;
    if Assigned(FSender) then FSender.perform(WM_INTERR,longint(@Prm),longint(FPrmBeforeShowError));
    MemoView.ReadOnly:=false; MemoView.SetText(Txt); MemoView.ReadOnly:=true;
    l:=CurInter.lError;
    RbStatus1.SectLeft[0]:=' '+DlmBetween(IfThen(l>0,StrNum('Строка ',l)),
      DelTrim(StrTran(CurInter.sError,CRLF,' ')),': ')+' ';
    if PnCtrl.ProcentWnd<>Prm.ProcentCtrl then begin
      PnCtrl.ProcentWnd:=Prm.ProcentCtrl; MainRebuild;
    end;
    MemoView.Init(CurInter.name);
    if Assigned(Prm.ViewCtrl) then RbScrollBox1.ScrollInView(Prm.ViewCtrl);
    MemoView.ScrollCaret; MemoView.ReadIdent(i,j); Dec(l); MemoView.SelectLines(l,l);
  end;
  DelStack;
end;

procedure TIntErLs.lsStackKeyUp;
begin
  AddStack('TIntErLs.lsStackKeyUp',Self);
  ReadStack;
  DelStack;
end;

procedure TIntErLs.lsStackMouseUp;
begin
  AddStack('TIntErLs.lsStackKeyUp',Self);
  ReadStack;
  DelStack;
end;

procedure TIntErLs.WMFormLimit;
var i: longint;
begin
	AddStack('TIntErLs.WMFormLimit',Self);
  inherited;
  for i:=low(aForm) to high(aForm) do if FreeLimit(aForm[nForm]) then break;
  DelStack;
end;

procedure TIntErLs.WMSchem;
var ts: TSchem;
begin
	AddStack('TIntErLs.WMSchem',Self);
	if msg.Oper=soAfter then with lsStack do begin
    if SchemName(pnStack.Schem,ts) then begin
      Color:=ts.Color1; Font:=ts.Font1;
    end;
    Canvas.Font.Assign(Font); ItemHeight:=CanvasMaxH(Canvas);
  end;
  DelStack;
end;

procedure TIntErLs.lsStackDrawItem;
begin
  AddStack('TIntErLs.lsStackDrawItem',Self);
  with lsStack.Canvas do begin
    Font.Assign(lsStack.Font);
    if odSelected in State then
      if ActiveControl=lsStack then begin
        Brush.Color:=clHighLight; Font.Color:=clHighLightText;
      end
      else Brush.Color:=pnStack.Color
    else Brush.Color:=lsStack.Color;
    TextRect(Rect,Rect.Left+2,Rect.Top,lsStack.Items[Index]);
  end;
  DelStack;
end;

procedure TIntErLs.PnMemoEnter(Sender: TObject);
begin
  AddStack('TIntErLs.PnMemoEnter',Self);
  with KeyLb1 do begin
    SetKey(K_F7,'Внутрь','Вызов внутреннего алгоритма',ProcKey,'debug',mnDebug.Tag);
    SetKey(K_F8,'Шаг','Пошаговое выполнение',ProcKey,'debug',mnDebug.Tag);
    SetKey(K_F12,'До курсора','Продолжить выполнение до курсора',ProcKey,'debug',mnDebug.Tag);
    ReDrw;
  end;
  DelStack;
end;

procedure TIntErLs.PnMemoExit(Sender: TObject);
begin
  AddStack('TIntErLs.PnMemoExit',Self);
  KeyLb1.DelKey(K_All,'debug'); KeyLb1.ReDrw;
  DelStack;
end;

procedure TIntErLs.ProcKey;
begin
	AddStack('TIntErLs.ProcKey',Self);
  if Key in [K_F10,K_Esc] then SetModalResult
  else begin
    InterStopOn := Key<>K_Enter;
    if InterStopOn then begin
      InterDebug:=CurInter.IntStatVar;
      if Key=K_F12 then lErrorDebug:=MemoView.CurrentLineNumber+1
      else begin
        lErrorDebug:=0; InterAnyDebug := Key=K_F7;
      end;
    end;
    SetModalResult(mrOk);
  end;
  DelStack;
end;

function InterShowError(Inter: TInter; AKeys: TIEKeys = [low(TIEKey)..high(TIEKey)];
  Sender: TControl = nil; PrmBeforeShowError: pointer = nil;
  const Capt: TCaption = 'Ошибка выполнения формулы'): TModalResult;
var oInter: TInter;
  i: longint;
begin
  AddStack('FIntErLs.InterShowError');
  oInter:=CurInter; Inc(nForm);
  if nForm=Length(aForm) then SetLength(aForm,nForm+1);
  CreateForm(TIntErLs,aForm[nForm]);
  with aForm[nForm] do begin
    Caption:=Capt; FSender:=Sender; FPrmBeforeShowError:=PrmBeforeShowError;
    with lsStack,Items do begin
      BeginUpdate; Clear;
      for i:=low(aInterStack) to nInterStack+1 do begin
        InsertObject(0,aInterStack[i].name,aInterStack[i]);
        if aInterStack[i]=Inter then break;
      end;
      EndUpdate; ItemIndex:=0; rStack:=-1; ReadStack;
    end;
    with KeyLb1 do begin
      DelKey(K_All,'cont');
      if ieEsc in AKeys then SetKeys([K_Esc,K_F10],'Прервать','',ProcKey,'cont',kmFile);
      if ieEnter in AKeys then SetKey(K_Enter,'Продолжить','',ProcKey,'cont',kmFile);
      Redrw;
    end;
    result:=ShowModal; lsStack.Filtered:=false; MemoView.SaveIdent;
    if not FormFree(aForm[nForm]) then ControlsFree(RbScrollBox1);
  end;
  Dec(nForm); CurInter:=oInter;
  DelStack;
end;

initialization
  AddStack('FIntErLs.initialization');
  Inter.InterShowError:=InterShowError;
  DelStack;
end.
