unit ListF2;

interface

{$I LIBTEST}
uses
  Windows,Classes,Controls,StdCtrls,
  MyTypes,PaintCtl;

type
	TListOwnerEvent = function(Sender: TObject; SpdBut: TPaintButton;
  	const RectList: TRect; PozList: TPozList): boolean of object;

  TFindListBoxFlt = array of record
    s: string;
    o: TObject;
  end;

  TFindListBox = class(TListBox)
  private
    aFlt: ^TFindListBoxFlt;
    anFlt: TArrInt;
    function GetFiltered: boolean;
    procedure SetFiltered(Value: boolean);
    function FGetIndexFiltered: longint;
    procedure SetIndexFiltered(Value: longint);
    function prfind(Sender: TControl; const sf: string): boolean;
    procedure ProcKey(key: longint; tw: TWinControl);
  	procedure WMApplHint(var Msg: TWMApplHint); message WM_APPLHINT;
  protected
    procedure DoEnter; override;
    procedure DoExit; override;
  public
		destructor Destroy; override;
    function GetIndexFiltered(Index: longint): longint; overload;
    procedure GetIndexFiltered(var Index,IndexFiltered: longint); overload;
    function GetTextFiltered: TArrStr;
    function ItemAdd(const Value: string; AObject: TObject = nil): longint;
    procedure ItemSet(Index: longint; const Value: string);
    procedure ItemDel(Index: longint);
    property Filtered: boolean read GetFiltered write SetFiltered;
    property IndexFiltered: longint read FGetIndexFiltered write SetIndexFiltered;
  end;

function ListF2Down(const StrList: string; mr: TListF2Result = nil; Sender: TWinControl = nil;
	MinWidth: longint = 0; const NmSchem: string = 'Browl';
  const DopKeyStr: string = ''; DopKeyProc: TKeyProc = nil;
  ItHeight: longint = 0; ProcDraw: TDrawItemEvent = nil; onLsDown: TMouseEvent = nil;
  onLsMove: TMouseMoveEvent = nil; onLsUp: TMouseEvent = nil;
  onRowMove: TRowMoveEvent = nil; const Capt: TCaption = ''; KeyEnter: boolean = true;
  onFrmShow: TNotifyEvent = nil): boolean;

implementation

uses Forms,StrUtils,Math,
  My_pr,KeyLb,FPanel,Schem,FrmWnd;

type
	TListF2 = class(TFormWnd)
  private
    Mp: TRbPanel;
    Kp: TKeyLb;
    Lp: TRbPanel;
    Ls: TFindListBox;
    oldInd,curInd: longint;
    usDown,usUp: TMouseEvent;
    usMove: TMouseMoveEvent;
    lDown,lMove: boolean;
    FOnRowMove: TRowMoveEvent;
    OwnerControl: TWinControl;
    procedure KpProcKey(key: longint; tw: TWinControl);
    procedure LsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
    procedure LsMouseMove(Sender: TObject; Shift: TShiftState; X,Y: longint);
    procedure LsMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
    procedure LsKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RowMove;
  end;

{ Вызов списка }
function ListF2Down;
var pt: TPoint;
	r: TRect;
	oi,i,mw: longint;
  ts: TSchem;
	LsF2: TListF2;
begin
	AddStack('ListF2.ListF2Down');
	LsF2:=TListF2.CreateAll(Application);
  with LsF2 do try
		OwnerControl:=Sender;
    ClrScroll(LsF2);
    if Capt='' then begin
	    BorderStyle:=bsNone; BorderIcons:=[];
    end
    else begin
    	BorderStyle:=bsSingle; BorderIcons:=[biSystemMenu,biMinimize,biMaximize];
    end;
    Caption:=Capt; lDown:=false; usDown:=onLsDown; usMove:=onLsMove; usUp:=onLsUp;
    FOnRowMove:=onRowMove;
    if Assigned(Sender) then Font:=GetParentForm(Sender).Font;
    BoundsRect:=SysWorkArea;
    Mp:=TRbPanel.Create(LsF2);
    with Mp do begin
      Parent:=LsF2;
      BevelInner:=bvNone; BevelOuter:=bvNone;
      Place:=rpBottom; ProcentWnd:=100; Schem:=IfThen(NmSchem='','Browl',NmSchem);
      SchemName(Schem,ts);
      Lp:=TRbPanel.Create(LsF2);
      with Lp do begin
        Parent:=Mp;
        BevelInner:=bvNone; BevelOuter:=bvNone;
        Place:=rpNone; ProcentWnd:=100; SortObj:=false;
        Ls:=TFindListBox.Create(LsF2);
        with Ls do begin
          Parent:=Lp; Items.Text:=StrList;
          if Assigned(ProcDraw) then begin
          	Style:=lbOwnerDrawFixed;
            ItemHeight:=ItHeight;
            onDrawItem:=ProcDraw;
          end
          else Style:=lbStandard;
          if Assigned(mr)
          then ItemIndex:=max(mr.SelectStr,0)
          else ItemIndex:=0;
          Align:=alClient;
          if Assigned(ts) then begin
          	Color:=ts.Color1; ParentFont:=false; Font.Assign(ts.Font1);
          end;
          onKeyUp:=LsKeyUp;
          onMouseDown:=LsMouseDown;
          onMouseMove:=LsMouseMove;
          onMouseUp:=LsMouseUp;
        end;
      end;
		  Kp:=TKeyLb.Create(LsF2);
		  with Kp do begin
        Parent:=Mp; BorderStyle:=bsSingle;
        BevelInner:=bvNone; BevelOuter:=bvNone;
        CanMove:=false;
        if KeyEnter then begin
          SetKeys([K_Enter,K_F10],'Выбор','',KpProcKey,'listf2',kmNone);
          SetKey(K_Esc,'Отмена','',KpProcKey,'listf2',kmNone);
        end
        else SetKeys([K_Esc,K_F10],'Выход','',KpProcKey,'listf2',kmNone);
        SetKeysSt(DopKeyStr,DopKeyProc,'owner');
      end;
    end;
    SetSchemForm; Ls.DoEnter; Kp.ReDrw; Lp.Canvas.Font.Assign(Ls.Font);
    if Capt='' then mw:=0 else mw:=MinWidthForm(LsF2)+Width-ClientWidth;
    ClientWidth:=MaxIntValue([MinWidth,mw,MaxSelf(Lp.Canvas,Ls.Items,6+SysMetric.iScrollWidth),
      Kp.WMin+Kp.BevPanel2+Mp.BevPanel2]);
    r:=SysWorkArea;
    if Assigned(ProcDraw) then mw:=ItHeight else mw:=CanvasMaxH(Lp.Canvas);
    ClientHeight:=min(Kp.Height+4+Lp.BevPanel2+mw*max(2,Ls.Items.Count),r.Bottom-r.Top-(Height-ClientHeight));
    if Assigned(Sender) then begin
      with Sender do pt:=IfThen(Sender is TCustomForm,Point(Left,Top),ClientOrigin);
      SetBounds(pt.X,pt.Y+Sender.Height,Width,Height);
      if Top+Height>r.Bottom then begin
        Top:=max(r.Top,pt.Y-Height); Kp.SetPlace(rpTop);
      end;
    end
    else begin
    	r:=SysWorkArea;
    	SetBounds((r.Right-r.Left-Width) div 2, (r.Bottom-r.Top-Height) div 2, Width, Height);
    end;
    MainReBuild; FormOnScreen; oldInd:=Ls.ItemIndex; oi:=oldInd; IfThenNotify(onFrmShow,LsF2);
    result := ShowModal=mrOk;
    Ls.Filtered:=false;
    if Assigned(mr) then begin
    	mr.Assign(Ls.Items); mr.SelectStr:=Ls.ItemIndex;
    end;
    Ls.ItemIndex:=oi; RowMove;
  finally
    Free;
  end;
  DelStack;
end;

{ TFindListBox }
destructor TFindListBox.Destroy;
begin
	AddStack('TFindListBox.Destroy',Self);
  if Filtered then begin
    aFlt^:=nil; Filtered:=false;
  end;
	inherited Destroy;
  DelStack;
end;

procedure TFindListBox.DoEnter;
var tl: TKeyLb;
begin
  AddStack('TFindListBox.DoEnter',Self);
  if not IsCalculator then begin
    inherited DoEnter;
    if FormKeyLb(Self,tl) then begin
      MsgMsOff(msoEnter,tl); tl.SetKeyFind(ProcKey,'findlistbox'); tl.ReDrw;
    end;
  end;
  DelStack;
end;

procedure TFindListBox.DoExit;
var tl: TKeyLb;
begin
  AddStack('TFindListBox.DoExit',Self);
  if not IsCalculator then begin
    Filtered:=false;
    if FormKeyLb(Self,tl) then begin
      MsgMsOff(msoExit,tl); tl.DelKey(K_All,'findlistbox'); tl.ReDrw;
    end;
    inherited DoExit;
  end;
  DelStack;
end;

procedure TFindListBox.ProcKey;
begin
  AddStack('TFindListBox.ProcKey',Self);
  if Key=K_Esc then Filtered:=false
  else WinFindKey(Key,Self,prfind,[fnoRegistr,fnoWord]+IfThen(not BrFindAll,[fnoDirection,fnoAll]));
  DelStack;
end;

function TFindListBox.prfind;
var n,lr: longint;
  procedure FindFirst;
  begin
  	AddStack('TFindListBox.prfind.FindFirst',Self);
    n:=IfThen(FindProperty.Direction=fndBack,lr-1);
    DelStack;
  end;
  procedure FindNext;
  begin
  	AddStack('TFindListBox.prfind.FindNext',Self);
    Inc(n,aSign[FindProperty.Direction=fndBack]);
    DelStack;
  end;
var nSel,i,lf: longint;
  lDown,lAll: boolean;
  af: TArrStr;
	procedure FindDown;
  var s: string;
  begin
  	AddStack('TFindListBox.prfind.FindDown',Self);
	  while InRange(n,0,lr-1) and (lAll or (n<>nSel)) do begin
      Inc(i);
      if WinFindSayStat(i/lr) then begin
        lDown:=false; break;
      end;
    	s:=Items[n];
      if FindInStr(s,sf) then begin
        result:=true;
        if lAll then begin
          af[lf]:=s; Inc(lf);
        end
        else break;
      end;
      FindNext;
    end;
    DelStack;
  end;
begin
	AddStack('TFindListBox.prfind',Self);
  result:=false; lDown:=true; lAll:=BrFindAll or (FindProperty.Direction=fndAll); Filtered:=false;
  i:=0; lr:=Items.Count; nSel:=ItemIndex;
  if lAll then begin
    FindFirst; SetLength(af,lr); lf:=0; FindDown;
    if result then begin
      Filtered:=true; SetLength(aFlt^,lr);
      if Length(anFlt)<lr then SetLength(anFlt,lr);
      Items.BeginUpdate; n:=0;
      for i:=0 to lr-1 do with aFlt^[i] do begin
        s:=Items[n]; o:=Items.Objects[n];
        if QuickFind(Items[n],af,lf) then begin
          anFlt[n]:=i; Inc(n);
        end
        else begin
          Items.Delete(n);
          if nSel>=n then Dec(nSel);
        end;
      end;
      if nSel<0 then nSel:=0;
      Items.EndUpdate; ItemIndex:=nSel; Selected[nSel]:=true;
    end;
  end
  else begin
    n:=nSel; FindNext; FindDown;
    if lDown and not result then begin
      FindFirst; FindDown;
    end;
    if result then ItemIndex:=n;
  end;
  DelStack;
end;

function TFindListBox.GetFiltered;
begin
  AddStack('TFindListBox.GetFiltered',Self);
  result:=Assigned(aFlt);
  DelStack;
end;

procedure TFindListBox.SetFiltered;
var tl: TKeyLb;
  i,nSel: longint;
begin
  AddStack('TFindListBox.SetFiltered',Self);
  if Filtered<>Value then begin
    tl:=FormKeyLb(Self);
    if Value then begin
      New(aFlt);
      if Assigned(tl) then tl.SetKey(K_Esc,'','Сбросить результаты поиска',ProcKey,'findlistbox',kmList);
    end
    else begin
      nSel:=anFlt[ItemIndex];
      Items.BeginUpdate; i:=Length(aFlt^); Items.Capacity:=i; Items.Clear;
      for i:=0 to i-1 do with aFlt^[i] do Items.AddObject(s,o);
      Items.EndUpdate; ItemIndex:=nSel; Dispose(aFlt); aFlt:=nil;
      if Assigned(tl) then tl.DelKey(K_Esc,'findlistbox');
    end;
    if Assigned(tl) then tl.ReDrw;
  end;
  DelStack;
end;

function TFindListBox.GetIndexFiltered(Index: longint): longint;
begin
  AddStack('TFindListBox.GetIndexFiltered',Self);
  if Filtered then result:=anFlt[Index] else result:=Index;
  DelStack;
end;

procedure TFindListBox.GetIndexFiltered(var Index,IndexFiltered: longint);
begin
  Index:=ItemIndex; IndexFiltered:=GetIndexFiltered(Index);
end;

function TFindListBox.FGetIndexFiltered;
begin
  AddStack('TFindListBox.FGetIndexFiltered',Self);
  result:=GetIndexFiltered(ItemIndex);
  DelStack;
end;

procedure TFindListBox.SetIndexFiltered;
var i: longint;
begin
  AddStack('TFindListBox.SetIndexFiltered',Self);
  if Filtered then begin
    if InRange(Value,low(aFlt^),high(aFlt^)) then
      for i:=0 to Items.Count-1 do if anFlt[i]=Value then begin
        ItemIndex:=i; break;
      end;
  end
  else if InRange(Value,0,Items.Count-1) then ItemIndex:=Value;
  DelStack;
end;

function TFindListBox.GetTextFiltered;
var i: longint;
begin
  AddStack('TFindListBox.GetTextFiltered',Self);
  if Filtered then begin
    i:=Length(aFlt^); SetLength(result,i);
    for i:=0 to i-1 do result[i]:=aFlt^[i].s;
  end
  else CopyFrom(result,Items);
  DelStack;
end;

function TFindListBox.ItemAdd;
var i: longint;
begin
  AddStack('TFindListBox.ItemAdd',Self);
  result:=Items.AddObject(Value,AObject);
  if Filtered then begin
    i:=Length(aFlt^); SetLength(aFlt^,i+1); Finalize(aFlt^[i]); ZeroMemory(@aFlt^[i],SizeOf(aFlt^[i]));
    aFlt^[i].s:=Value; aFlt^[i].o:=AObject; anFlt[result]:=i;
  end;
  DelStack;
end;

procedure TFindListBox.ItemSet;
begin
  AddStack('TFindListBox.ItemSet',Self);
  Items[Index]:=Value;
  if Filtered then aFlt^[anFlt[Index]].s:=Value;
  DelStack;
end;

procedure TFindListBox.ItemDel;
var i,n,l: longint;
begin
  AddStack('TFindListBox.ItemDel',Self);
  if Filtered then begin
    l:=Items.Count-1; n:=anFlt[Index];
    for i:=0 to l do if anFlt[i]>n then Dec(anFlt[i]);
    for i:=Index to l-1 do anFlt[i]:=anFlt[i+1];
    l:=high(aFlt^);
    for i:=n to l-1 do aFlt^[i]:=aFlt^[i+1];
    SetLength(aFlt^,l);
  end;
  Items.Delete(Index);
  DelStack;
end;

procedure TFindListBox.WMApplHint;
begin
	AddStack('TFindListBox.WMApplHint',Self);
  inherited;
  Msg.Info.HintInfo.ReshowTimeout:=100;
  DelStack;
end;

{ TListF2 }

procedure TListF2.KpProcKey;
begin
	AddStack('TListF2.KpProcKey',Self);
  case Key of
    K_F10,K_Enter: ModalResult:=mrOk;
    K_Esc: ModalResult:=mrCancel;
  end;
  DelStack;
end;

procedure TListF2.LsMouseDown;
begin
	AddStack('TListF2.LsMouseDown',Self);
	IfThenMouse(usDown,Sender,Button,Shift,X,Y);
  if not lDown and (ssLeft in Shift) then begin
    curInd:=Ls.ItemAtPos(Point(X,Y),true);
    lDown:=true; lMove:=false;
  end;
  DelStack;
end;

procedure TListF2.LsMouseMove;
begin
	AddStack('TListF2.LsMouseMove',Self);
	IfThenMouseMove(usMove,Sender,Shift,X,Y);
  if lDown and not lMove then lMove := Ls.ItemAtPos(Point(X,Y),true)<>curInd;
  DelStack;
end;

procedure TListF2.LsMouseUp;
begin
	AddStack('TListF2.LsMouseUp',Self);
	IfThenMouse(usUp,Sender,Button,Shift,X,Y);
  if lDown and not lMove and (Ls.ItemIndex=oldInd) then Kp.ExecKey(K_Enter);
  lDown:=false; RowMove;
  DelStack;
end;

{ Запомнить выделенный элемент }
procedure TListF2.LsKeyUp;
begin
	AddStack('TListF2.LsKeyUp',Self);
	RowMove;
  DelStack;
end;

// Перемещение по списку
procedure TListF2.RowMove;
begin
	AddStack('TListF2.RowMove',Self);
	if (oldInd<>Ls.ItemIndex) and Assigned(FOnRowMove) then FOnRowMove(OwnerControl,Ls.ItemIndex);
  oldInd:=Ls.ItemIndex;
  DelStack;
end;

end.
