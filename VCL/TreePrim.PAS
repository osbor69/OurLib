unit TreePrim;

interface

{$I LIBTEST}
uses
  Windows,Messages,Classes,Graphics,Controls,ComCtrls,
  MyTypes,My_pr,FPanel,Schem,LbSeek,FStat;

type
  PPrimNodeInf = ^TPrimNodeInf;
	TPrimNodeInf = record
  	Prim,Hint: string;
    HelpContext: THelpContext;
    nFlt: longint;
    Dop: Pointer;
	end;

  PTreePrimFlt = ^TTreePrimFlt;
  TTreePrimFlt = array of record
    txt: string;
    lv: longint;
    chk: boolean;
    rprim: TPrimNodeInf;
  end;

  TTreeCheckAllEvent = function(Sender: TObject; Value: boolean): boolean of object;
  TTreeCheckingEvent = procedure(Sender: TObject; Node: TTreeNode; Value: boolean;
    var Allowed: boolean; var StateIndex: longint) of object;
  TTreeCheckedEvent = procedure(Sender: TObject; Node: TTreeNode; Value: boolean) of object;
  TTreeSeekNodeEvent = function(Sender: TObject; Node: TTreeNode): boolean of object;
  TTreeSeekTransEvent = function(Sender: TObject; const s: string): string of object;
  TCustomDrawPrimEvent = procedure (Sender: TObject; Node: TTreeNode;
    Stage: TCustomDrawStage; var DefaultDraw: Boolean) of object;

	TTreePrimState = (tpsNone,tpsPlus,tpsMinus);

  TTreePrimOption = (tpCanCheck,tpEnterExpand,tpCanCheckNode,tpNoDopDispose,tpNoCheckAll);
  TTreePrimOptions = set of TTreePrimOption;

  TTreePrimIniOption = (tpiExpanded,tpiSelected);
  TTreePrimIniOptions = set of TTreePrimIniOption;

  TTreePrimEnterOpt = set of (tpenMinus,tpenComp);

  TTreePrim = class(TTreeView)
  private
    { Private declarations }
    FFontPrim: TFont;
    FOptions: TTreePrimOptions;
    FOnChangeOffsetPrim,FOnAfterEnter: TNotifyEvent;
    FOnCustomDrawPrim: TCustomDrawPrimEvent;
    FOnCheckAll: TTreeCheckAllEvent;
    FOnChecking: TTreeCheckingEvent;
    FOnChecked: TTreeCheckedEvent;
    FOnSeekNode: TTreeSeekNodeEvent;
    FOnSeekTrans: TTreeSeekTransEvent;
    SelState: TTreePrimState;
    FPrimLeft,FPrimRight,FUpdateCount,FSeekLength,lPrim: longint;
   	GSeek: TLbSeek;
    FSeekCaption: string;
    aPrim: array of TPrimNodeInf;
    aFlt: PTreePrimFlt;
		function GetChecked(Node: TTreeNode): boolean;
		procedure SetChecked(Node: TTreeNode; Value: boolean);
    function GetFiltered: boolean;
    procedure SetFiltered(Value: boolean);
		procedure SetFontPrim(Value: TFont);
		procedure SetOptions(Value: TTreePrimOptions);
		procedure SetSeekCaption(const Value: string);
		procedure SetSeekLength(Value: longint);
		procedure NmEnter(Opt: TTreePrimEnterOpt); overload;
		procedure NmEnter(lComp: boolean = false); overload;
    procedure StExpandAll(Sender: TStat);
		function TreeFind(Sender: TControl; const sf: string): boolean;
    class procedure FCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure CalcOffsPrim;
    procedure NodePrimOut(Node: TTreeNode);
		procedure CheckPSeek;
		procedure PrSeek(Sender: TObject);
		procedure SchemPSeek;
    procedure DataDispose(Node: TTreeNode);
    function IniSect(const cSect: string; var Sect: string): boolean;
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
    procedure WMGetDlgCode(var Msg: TWmGetDlgCode); message wm_GetDlgCode;
  	procedure WMApplHint(var Msg: TWMApplHint); message WM_APPLHINT;
  	procedure WMSchem(var Message: TWMSchem); message WM_SCHEM;
  	procedure WMRebuild(var Message: TWMRebuild); message WM_REBUILD;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
  protected
    { Protected declarations }
    procedure DoExit; override;
    procedure DblClick; override;
		procedure KeyDown(var Key: Word; Shift: TShiftState); override;
		procedure KeyPress(var Key: Char); override;
		procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: longint); override;
    procedure MouseMove(Shift: TShiftState; X,Y: longint); Override;
    procedure Expand(Node: TTreeNode); override;
    procedure Collapse(Node: TTreeNode); override;
    procedure CustomDrawPrim(Node: TTreeNode; Stage: TCustomDrawStage; var DefaultDraw: Boolean); dynamic;
		function SeekNode(Node: TTreeNode): boolean; dynamic;
		function SeekTrans(const s: string): string; dynamic;
		procedure ProcKey(key: longint; tw: TWinControl); virtual;
  public
    { Public declarations }
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
    procedure DoEnter; override;
    procedure Change(Node: TTreeNode); override;
    function AddPrim(Node: TTreeNode; const TextNode: string = '';
    	const cPrim: string = ''; cHelpContext: THelpContext = 0; cDop: Pointer = nil; const cHint: string = ''): TTreeNode;
    procedure AddPrimSelf(var Node: TTreeNode; const TextNode: string;
    	const cPrim: string = ''; cHelpContext: THelpContext = 0; cDop: Pointer = nil; const cHint: string = '');
		procedure DeletePrim(Node: TTreeNode);
		procedure ClearPrim(ClearFilter: boolean = true);
    function GetPrimRect(Node: TTreeNode): TRect;
    procedure BeginUpdate;
    procedure EndUpdate;
    function CanUpdate: boolean;
  	procedure SetOption(Value: TTreePrimOptions; lSet: boolean);
    function NodeInf(Node: TTreeNode = nil): PPrimNodeInf; overload;
    function NodeInf(var p: PPrimNodeInf; Node: TTreeNode = nil): boolean; overload;
    function SaveToIni(const cSect: string = ''; Opt: TTreePrimIniOptions = [low(TTreePrimIniOption)..high(TTreePrimIniOption)]): string;
    function RestFromIni(const cSect: string = ''; Opt: TTreePrimIniOptions = [low(TTreePrimIniOption)..high(TTreePrimIniOption)];
      const cSel: string = ''): boolean;
    function FindFirst(lr: longint): TTreeNode;
    class procedure FindNext(var result: TTreeNode);
    function IsSelected(var tn: TTreeNode): boolean;
    function DefSelected(var tn: TTreeNode): TTreeNode;
    function SelectNoNil(tn: TTreeNode): boolean;
    function IsNodeAt(X,Y: longint; var tn: TTreeNode): boolean;
    function IsFirst(var tn: TTreeNode): boolean; overload;
    function IsFirst: boolean; overload;
    procedure FirstSelect;
    procedure FirstIfNil(var tn: TTreeNode);
    function IfThenText: string; overload;
    class function IfThenText(tn: TTreeNode): string; overload;
    class procedure AddListFiltered(flt: TIntegerList; tn: TTreeNode);
    procedure SetListFiltered(flt: TIntegerList);
	//function IsCodEqual: boolean;
    property Checked[Node: TTreeNode]: boolean read GetChecked write SetChecked;
    property PrimLeft: longint read FPrimLeft write FPrimLeft;
    property PrimRight: longint read FPrimRight write FPrimRight;
    property Filtered: boolean read GetFiltered write SetFiltered;
  published
    { Published declarations }
    property FontPrim: TFont read FFontPrim write SetFontPrim;
    property SeekCaption: string read FSeekCaption write SetSeekCaption;
    property SeekLength: longint read FSeekLength write SetSeekLength;
    property Options: TTreePrimOptions read FOptions write SetOptions;
    property OnAfterEnter: TNotifyEvent read FOnAfterEnter write FOnAfterEnter;
    property OnChangeOffsetPrim: TNotifyEvent read FOnChangeOffsetPrim write FOnChangeOffsetPrim;
    property OnCheckAll: TTreeCheckAllEvent read FOnCheckAll write FOnCheckAll;
    property OnChecking: TTreeCheckingEvent read FOnChecking write FOnChecking;
    property OnChecked: TTreeCheckedEvent read FOnChecked write FOnChecked;
    property OnCustomDrawPrim: TCustomDrawPrimEvent read FOnCustomDrawPrim write FOnCustomDrawPrim;
    property OnSeekNode: TTreeSeekNodeEvent read FOnSeekNode write FOnSeekNode;
    property OnSeekTrans: TTreeSeekTransEvent read FOnSeekTrans write FOnSeekTrans;
  end;

procedure Register;

procedure IfThenTreeChecked(Proc: TTreeCheckedEvent; Sender: TObject; Node: TTreeNode; Value: boolean);
procedure SetSet(var s: TTreePrimOptions; Value: TTreePrimOption; lSet: boolean); overload;

implementation

uses SysUtils,Forms,Commctrl,StrUtils,Math,Clipbrd,
  KeyLb;

const
  brCurs = '_';
  GSeekMax = 30;

procedure IfThenTreeChecked;
begin
  if Assigned(Proc) then Proc(Sender,Node,Value);
end;

procedure SetSet(var s: TTreePrimOptions; Value: TTreePrimOption; lSet: boolean);
begin
  if lSet then Include(s,Value) else Exclude(s,Value);
end;

{ TTreePrim }
constructor TTreePrim.Create;
var bm: TBitMap;
begin
	AddStack('TTreePrim.Create',Self);
	inherited Create(AOwner);
  FFontPrim:=TFont.Create; FFontPrim.Assign(Font); SelState:=tpsNone; ReadOnly:=true; FPrimLeft:=0;
  OnCustomDrawItem:=FCustomDrawItem;
  StateImages:=TImageList.Create(Self);
  with StateImages do begin
    TInitBM.Init(Application.MainForm);
    InitBM.FindBM(bmNoCheck,bm); AddMasked(bm,bm.TransparentColor);
    AddMasked(bm,bm.TransparentColor);
    InitBM.FindBM(bmCheck,bm); AddMasked(bm,bm.TransparentColor);
  end;
  SetLength(aPrim,10); Finalize(aPrim[0]); ZeroMemory(@aPrim[0],SizeOf(aPrim[0])); lPrim:=1;
  DelStack;
end;

destructor TTreePrim.Destroy;
begin
	AddStack('TTreePrim.Destroy',Self);
  if Filtered then begin
    aFlt^:=nil; Filtered:=false;
  end;
	ClearPrim; FFontPrim.Free;
	inherited Destroy;
  DelStack;
end;

function TTreePrim.AddPrim;
begin
	AddStack('TTreePrim.AddPrim',Self);
  if Length(aPrim)=lPrim then SetLength(aPrim,lPrim shl 1);
  with aPrim[lPrim] do begin
	  Prim:=cPrim; HelpContext:=cHelpContext; Dop:=cDop; Hint:=cHint;
  end;
  result:=Items.AddChildObject(Node,TextNode,pointer(lPrim)); Inc(lPrim);
  if (tpCanCheck in FOptions) and (Assigned(Node) or (tpCanCheckNode in FOptions))
  then Checked[result]:=false;
  DelStack;
end;

procedure TTreePrim.AddPrimSelf;
begin
  Node:=AddPrim(Node,TextNode,cPrim,cHelpContext,cDop,cHint);
end;

procedure TTreePrim.DataDispose;
var p: PPrimNodeInf;
begin
  AddStack('TTreePrim.DataDispose');
	if NodeInf(p,Node) then begin
    if Assigned(p.Dop) then
      if not(tpNoDopDispose in FOptions) then Dispose(p.Dop);
    p.Prim:=''; Node.Data:=nil;
  end;
  DelStack;
end;

procedure TTreePrim.DeletePrim;
	procedure tnDel(tn: TTreeNode);
	var tn1: TTreeNode;
  begin
    AddStack('TTreePrim.DeletePrim.tnDel',Self);
    tn1:=tn.GetFirstChild;
    while Assigned(tn1) do begin
      tnDel(tn1); GetNextSiblingSelf(tn1);
    end;
		DataDispose(tn);
    DelStack;
  end;
begin
	AddStack('TTreePrim.DeletePrim',Self);
  tnDel(Node); Node.Delete;
  DelStack;
end;

procedure TTreePrim.ClearPrim;
var tn: TTreeNode;
begin
	AddStack('TTreePrim.ClearPrim',Self);
  if ClearFilter then Filtered:=false;
  if Assigned(Parent) then begin
    IsFirst(tn);
    while Assigned(tn) do begin
      DataDispose(tn); GetNextSelf(tn);
    end;
  end;
  Items.Clear; lPrim:=1;
  DelStack;
end;

procedure TTreePrim.SetFontPrim;
begin
	AddStack('TTreePrim.SetFontPrim',Self);
	FFontPrim.Assign(Value); Invalidate;
  DelStack;
end;

procedure TTreePrim.WMApplHint;
begin
  AddStack('TTreePrim.WMApplHint',Self);
  Msg.Info.HintInfo.ReshowTimeout:=100;
  DelStack;
end;

procedure TTreePrim.WMSchem;
begin
	AddStack('TTreePrim.WMSchem',Self);
	inherited;
  with Message do
    if Assigned(Schem) then begin
    	Color:=Schem.Color1; Font.Assign(Schem.Font1); FontPrim.Assign(Schem.Font2);
    end
    else begin
      DefaultFont(Font); FFontPrim.Assign(Font);
    end;
  SchemPSeek; CalcOffsPrim; Invalidate;
  DelStack;
end;

procedure TTreePrim.SchemPSeek;
begin
	AddStack('TTreePrim.SchemPSeek',Self);
  if Assigned(GSeek) then begin
  	if Parent is TRbPanel then GSeek.TitleFont.Assign(TRbPanel(Parent).Font);
    GSeek.Color:=Color; GSeek.Font.Assign(Font);
  end;
  DelStack;
end;

procedure TTreePrim.WMRebuild;
const iY = 5;
var t,h: longint;
begin
	AddStack('TTreePrim.WMRebuild',Self);
	inherited;
	with Message.RbPnl do begin
    t:=HeaderHeight+BevPanel;
    if Assigned(GSeek) then begin
  		GSeek.Title:=FSeekCaption+':'; SchemPSeek;
      GSeek.SetBounds((Width-GSeek.Width) div 2,t+iY,0,0);
      Inc(t,GSeek.Height+iY*2);
    end;
    h:=BevPanel; Self.SetBounds(h,t,CltWidth,Height-h-t); SortObj:=false;
  end;
  DelStack;
end;

procedure TTreePrim.CMShowingChanged;
begin
  inherited;
end;

procedure TTreePrim.CNNotify;
  function GetNodeFromItem(const Item: TTVItem): TTreeNode;
  begin
    if Items=nil then Result:=nil
    else with Item do
      if (state and TVIF_PARAM) = 0 then Result:=Items.GetNode(hItem) else Result:=Pointer(lParam);
  end;
var TmpItem: TTVItem;
  Node: TTreeNode;
begin
	AddStack('TTreePrim.CNNotify',Self);
  inherited;
  with Message do
    if NMHdr^.code=NM_CUSTOMDRAW then with PNMCustomDraw(NMHdr)^ do begin
      Canvas.Lock;
      try
        if (dwDrawStage and CDDS_ITEM) <> 0 then begin
          FillChar(TmpItem,SizeOf(TmpItem),0);
          TmpItem.hItem:=HTREEITEM(dwItemSpec);
          Node:=GetNodeFromItem(TmpItem);
          if Node<>nil then NodePrimOut(Node);
        end;
      finally
        Canvas.Unlock;
      end;
    end;
  DelStack;
end;

procedure TTreePrim.WMGetDlgCode;
begin
	AddStack('TTreePrim.WMGetDlgCode',Self);
	inherited;
  GetDlgCodeTab(Self,Msg);
  DelStack;
end;

procedure TTreePrim.NodePrimOut;
var r: TRect;
  p: PPrimNodeInf;
  DefaultDraw: Boolean;
begin
  AddStack('TTreePrim.NodePrimOut',Self);
  Canvas.Font.Assign(FFontPrim); Canvas.Brush.Color:=Color; DefaultDraw:=true;
  CustomDrawPrim(Node,cdPrePaint,DefaultDraw);
  if DefaultDraw and NodeInf(p,Node) then begin
    r:=Node.DisplayRect(true); r.Left:=r.Right; r.Right:=ClientRect.Right; Canvas.FillRect(r);
    if not empty(p.Prim) then begin
      r.Left:=FPrimLeft;
      r.Right:=min(FPrimLeft+Canvas.TextWidth(p.Prim),ClientRect.Right);
      Canvas.TextRect(r,FPrimLeft,r.Top+1,p.Prim);
    end;
  end;
  CustomDrawPrim(Node,cdPostPaint,DefaultDraw);
  DelStack;
end;

procedure TTreePrim.CustomDrawPrim;
begin
  AddStack('TTreePrim.CustomDrawPrim',Self);
  if Assigned(FOnCustomDrawPrim) then FOnCustomDrawPrim(Self,Node,Stage,DefaultDraw);
  DelStack;
end;

class procedure TTreePrim.FCustomDrawItem;
begin
end;

procedure TTreePrim.Change;
begin
	AddStack('TTreePrim.Change',Self);
  if CanUpdate then begin
    inherited Change(Node);
    if Assigned(Selected) then begin
      HelpContext:=NodeInf.HelpContext; NmEnter(true);
    end
    else NmEnter;
  end;
  DelStack;
end;

procedure TTreePrim.CalcOffsPrim;
var oLeft,oRight: longint;
  tn: TTreeNode;
  p: PPrimNodeInf;
begin
  AddStack('TTreePrim.CalcOffsPrim',Self);
  if CanUpdate then begin
    oLeft:=0; oRight:=0; Canvas.Font.Assign(FFontPrim); IsFirst(tn);
    while Assigned(tn) do begin
      if tn.IsVisible then MaxSelf(oLeft,tn.DisplayRect(true).Right);
      GetNextSelf(tn);
    end;
    Inc(oLeft,10); IsFirst(tn);
    while Assigned(tn) do begin
      if tn.IsVisible and NodeInf(p,tn) then MaxSelf(oRight,oLeft+Canvas.TextWidth(p.Prim));
      GetNextSelf(tn);
    end;
    if (oLeft<>FPrimLeft) or (oRight<>FPrimRight) then begin
      if oLeft<>FPrimLeft then begin
        FPrimLeft:=oLeft; IsFirst(tn);
        while Assigned(tn) do begin
          NodePrimOut(tn); GetNextSelf(tn);
        end;
      end;
      FPrimRight:=oRight; IfThenNotify(FOnChangeOffsetPrim,Self);
    end;
  end;
  DelStack;
end;

procedure TTreePrim.DoEnter;
var tl: TKeyLb;
begin
	AddStack('TTreePrim.DoEnter',Self);
  if not IsCalculator then begin
    inherited DoEnter;
    NmEnter;
    if FormKeyLb(Self,tl) then with tl do begin
      SetKey(K_Ctrl_C,'','Скопировать в буфер обмена',ProcKey,'treeprim',kmList);
      SetKey(K_Ctrl_Mult,'','Развернуть все',ProcKey,'treeprim',kmList);
      SetKeyFind(ProcKey,'treeprim'); MsgMsOff(msoEnter,tl); ReDrw;
    end;
    IfThenNotify(FOnAfterEnter,Self);
  end;
  DelStack;
end;

procedure TTreePrim.DoExit;
var tl: TKeyLb;
begin
	AddStack('TTreePrim.DoExit',Self);
  if not IsCalculator then begin
    if FormKeyLb(Self,tl) then with tl do begin
      DelKeyNmPr(['treeprim','treechk','treeall']); MsgMsOff(msoExit,tl); ReDrw;
    end;
    Filtered:=false;
    inherited DoExit;
  end;
  DelStack;
end;

procedure TTreePrim.DblClick;
var tn: TTreeNode;
 tl: TKeyLb;
begin
	AddStack('TTreePrim.DblClick',Self);
  inherited DblClick;
  if IsSelected(tn) then if not tn.HasChildren then if FormKeyLb(Self,tl) then tl.ExecKey(K_Enter);
  DelStack;
end;

procedure TTreePrim.KeyDown;
//var tn,tnSel: TTreeNode;
begin
	AddStack('TTreePrim.KeyDown',Self);
  {if (Shift=[]) and (Key=vk_End) then begin
    IsFirst(tn); tnSel:=nil;
    while Assigned(tn) do begin
      tnSel:=tn; GetNextVisibleSelf(tn);
    end;
    if SelectNoNil(tnSel) then Key:=0;
  end;}
  if Assigned(GSeek) then GSeek.KeyDown(Key,Shift);
  inherited KeyDown(Key,Shift);
  DelStack;
end;

procedure TTreePrim.KeyPress;
var tn: TTreeNode;
begin
	AddStack('TTreePrim.KeyPress',Self);
	if (Word(Key)=vk_Return) or (Key=' ') then Key:=#0;
  if Key in ['+','-','*'] then if IsSelected(tn) then if tn.HasChildren then Key:=#0;
  if Assigned(GSeek) and IsFirst then GSeek.KeyPress(Key);
  inherited KeyPress(Key);
  DelStack;
end;

procedure TTreePrim.MouseDown;
var tn: TTreeNode;
begin
	AddStack('TTreePrim.MouseDown',Self);
  inherited;
  if Button=mbLeft then if IsNodeAt(X,Y,tn) then tn.Selected:=true;
  DelStack;
end;

procedure TTreePrim.MouseMove;
var tn: TTreeNode;
begin
  AddStack('TTreePrim.MouseMove',Self);
  inherited;
  if IsNodeAt(X,Y,tn) then Hint:=NodeInf(tn).Hint else Hint:='';
  ShowHint := Hint<>'';
  DelStack;
end;

procedure TTreePrim.Expand;
begin
	AddStack('TTreePrim.Expand',Self);
  NmEnter([tpenMinus,tpenComp]);
  inherited Expand(Node);
  CalcOffsPrim;
  //inherited Change(Node);
  DelStack;
end;

procedure TTreePrim.Collapse;
begin
	AddStack('TTreePrim.Collapse',Self);
  CalcOffsPrim; NmEnter([tpenComp]);
  inherited Collapse(Node);
  //inherited Change(Node);
  DelStack;
end;

procedure TTreePrim.NmEnter(Opt: TTreePrimEnterOpt);
var tl: TKeyLb;
	st: TTreePrimState;
  procedure KeyChk;
  var a: TArrInt;
  begin
    AddStack('TTreePrim.NmEnter.KeyChk',Self);
    if tpCanCheck in FOptions then begin
      if st=tpsNone then CopyFromInt(a,[K_Enter,K_Space]) else CopyFromInt(a,[K_Space,K_Enter]);
      AddFromInt(a,K_Ins); tl.SetKeys(a,'Отметить','',ProcKey,'treechk',kmList);
    end;
    DelStack;
  end;
const anm: array[TTreePrimState] of TNamePrimStr =
  (('','')
  ,('Открыть','Открыть раздел')
  ,('Закрыть','Закрыть раздел')
  );
var ap,am: TArrInt;
  tn: TTreeNode;
begin
	AddStack('TTreePrim.NmEnter',Self);
	if GetParentForm(Self).ActiveControl=Self then begin
  	st:=tpsNone;
  	if IsSelected(tn) then if tn.HasChildren then st:=iif(tpenMinus in Opt,tpsMinus,tpsPlus);
    if not(tpenComp in Opt) or (st<>SelState) then begin
      SelState:=st;
      if FormKeyLb(Self,tl) then with tl do begin
        if (tpCanCheck in FOptions) and not(tpNoCheckAll in FOptions) then begin
          CopyFromInt(ap,K_Plus); CopyFromInt(am,K_Minus);
          if not IsAllKeyBut(K_F2) then begin
            AddFromInt(ap,K_F2); AddFromInt(am,K_F3);
          end;
          SetKeySel(ap,am,ProcKey,'treeall');
        end
        else DelKey(K_All,'treeall');
        if st=tpsNone then begin
        	DelKey(K_Enter,'treeprim'); KeyChk;
        end
        else begin
          if not(tpEnterExpand in FOptions) then begin
            if not IsKeyBut(K_Enter) then ReDrw;
            SetKey(K_Enter,anm[st,1],anm[st,2],ProcKey,'treeprim',kmList);
          end;
          if tpCanCheckNode in FOptions then KeyChk else DelKey(K_All,'treechk');
        end;
        ReDrw;
      end;
    end;
  end;
  DelStack;
end;

procedure TTreePrim.NmEnter(lComp: boolean = false);
var Opt: TTreePrimEnterOpt;
  tn: TTreeNode;
begin
  if lComp then Opt:=[tpenComp] else Opt:=[];
  if IsSelected(tn) then if tn.Expanded then Include(Opt,tpenMinus);
  NmEnter(Opt);
end;

procedure TTreePrim.ProcKey;
var tn,tnSel: TTreeNode;
  st: TTreePrimState;
  fl,chk: boolean;
begin
	AddStack('TTreePrim.ProcKey',Self);
	case Key of
  	K_F2,K_F3,K_Plus,K_Minus: begin
      chk := Key in [K_F2,K_Plus];
      if AskSel(chk) then begin
        if Assigned(FOnCheckAll) then fl:=FOnCheckAll(Self,chk) else fl:=true;
        if fl then begin
          IsFirst(tn);
          while Assigned(tn) do begin
            if (tpCanCheckNode in Options) or not tn.HasChildren then Checked[tn]:=chk;
            GetNextSelf(tn);
          end;
        end;
      end;
    end;
    K_Enter,K_Space,K_Ins: if IsSelected(tnSel) then begin
      st:=iif((tpCanCheckNode in FOptions) and (Key<>K_Enter),tpsNone,SelState);
      case st of
        tpsPlus: begin
          tnSel.Expand(false); Expand(tnSel);
        end;
        tpsMinus: begin
          tnSel.Collapse(false); Collapse(tnSel);
        end;
      else Checked[tnSel] := not Checked[tnSel];
      end;
      if Key=K_Ins then begin
      	tn:=tnSel.GetNextSibling;
        if not Assigned(tn) then begin
        	tn:=tnSel;
          while true do begin
	        	GetNextVisibleSelf(tn);
            if Assigned(tn) then
            	if not Assigned(tn.Parent) then continue;
            break;
          end;
        end;
        SelectNoNil(tn);
      end;
    end;
    K_Esc: Filtered:=false;
    K_Ctrl_C: ClipBoard.AsText:=Selected.Text;
    K_Ctrl_Mult: ShowStat('Развернуть все',StExpandAll);
  else if IsFirst or BrFindAll
    then WinFindKey(Key,Self,TreeFind,[fnoRegistr,fnoWord]+IfThen(not BrFindAll,[fnoDirection,fnoAll]));
  end;
  DelStack;
end;

function TTreePrim.TreeFind;
var tn: TTreeNode;
  i,lr,lv: longint;
  lDown,lAll: boolean;
  flt: TIntegerList;
	procedure FindDown(var res: boolean);
  var lFind: boolean;
    function Find1(const s: string): boolean;
    begin
    	AddStack('TTreePrim.TreeFind.FindDown.Find1',Self);
    	result:=false;
      if lAll and (tn.Level>lv) then lFind:=true
      else begin
        lFind:=FindInStr(s,sf); lv:=IfThen(lFind,tn.Level,MaxInt);
      end;
      if lFind then begin
        res:=true;
        if lAll then AddListFiltered(flt,tn) else result:=true;
      end;
      DelStack;
    end;
  var p: PPrimNodeInf;
  begin
  	AddStack('TTreePrim.TreeFind.FindDown',Self);
	  while Assigned(tn) and (lAll or (tn<>Selected)) do begin
      Inc(i);
      if WinFindSayStat(i/lr) then begin
        lDown:=false; break;
      end;
      if Find1(tn.Text) then break
      else if not lFind then if NodeInf(p,tn) then if Find1(p.Prim) then break;
      FindNext(tn);
    end;
    DelStack;
  end;
begin
	AddStack('TTreePrim.TreeFind',Self);
  result:=false; lDown:=true; lAll:=BrFindAll or (FindProperty.Direction=fndAll); Filtered:=false;
  i:=0; lr:=Items.Count; lv:=MaxInt;
  if lAll then begin
    flt:=TIntegerList.Create([ilsSorted]);
    try
      tn:=FindFirst(lr); flt.Capacity:=lr; FindDown(result);
      if result then SetListFiltered(flt);
    finally
      flt.Free;
    end;
  end
  else begin
    tn:=Selected; FindNext(tn); FindDown(result);
    if lDown and not result then begin
      tn:=FindFirst(lr); FindDown(result);
    end;
    if result then Selected:=tn;
  end;
  DelStack;
end;

function TTreePrim.GetFiltered;
begin
  AddStack('TTreePrim.GetFiltered',Self);
  result:=Assigned(aFlt);
  DelStack;
end;

procedure TTreePrim.SetFiltered;
var tl: TKeyLb;
  fl: boolean;
  i,j,hSel: longint;
  tn: TTreeNode;
  aSel: TArrStr;
  alv: TArrTreeNode;
  oFlt: PTreePrimFlt;
begin
  AddStack('TTreePrim.SetFiltered',Self);
  if Filtered<>Value then begin
    tl:=FormKeyLb(Self);
    if Value then begin
      New(aFlt);
      if Assigned(tl) then tl.SetKey(K_Esc,'','Сбросить результаты поиска',ProcKey,'treeprim',kmList);
    end
    else begin
      if IsSelected(tn) then begin
        hSel:=tn.Level; SetLength(aSel,hSel+1);
        for i:=hSel downto 0 do begin
          aSel[i]:=tn.Text; ParentSelf(tn);
        end;
      end
      else hSel:=-1;
      BeginUpdate; tn:=nil;
      fl := tpNoDopDispose in FOptions; Include(FOptions,tpNoDopDispose);
      ClearPrim(false); SetSet(FOptions,tpNoDopDispose,fl);
      SetLength(alv,1); alv[0]:=nil; oFlt:=aFlt;
      for i:=low(aFlt^) to high(aFlt^) do with aFlt^[i],rprim do begin
        if Length(alv)=lv then SetLength(alv,lv+1);
        alv[lv]:=AddPrim(alv[lv-1],txt,Prim,HelpContext,Dop,Hint); aFlt:=nil; Checked[alv[lv]]:=chk; aFlt:=oFlt;
        if not Assigned(tn) then if lv-1=hSel then begin
          fl:=true;
          for j:=lv downto 1 do if alv[j].Text<>aSel[j-1] then begin
            fl:=false; break;
          end;
          if fl then tn:=alv[lv];
        end;
      end;
      EndUpdate; SelectNoNil(tn); Dispose(aFlt); aFlt:=nil;
      if Assigned(tl) then tl.DelKey(K_Esc,'treeprim');
    end;
    if Assigned(tl) then tl.ReDrw;
  end;
  DelStack;
end;

procedure TTreePrim.SetListFiltered;
var lr: longint;
  tn,otn: TTreeNode;
  p: PPrimNodeInf;
begin
  AddStack('TTreePrim.SetListFiltered',Self);
  Filtered:=true; lr:=Items.Count; SetLength(aFlt^,lr); IsFirst(tn);
  for lr:=0 to lr-1 do with aFlt^[lr] do begin
    txt:=tn.Text; lv:=tn.Level+1; chk:=Checked[tn]; p:=NodeInf(tn); p.nFlt:=lr; rprim:=p^;
    GetNextSelf(tn);
  end;
  BeginUpdate; otn:=nil;
  repeat
    if Assigned(otn) then tn:=otn.GetNext else IsFirst(tn);
    if not Assigned(tn) then break;
    if flt.FindDel(longint(tn)) then otn:=tn else DeletePrim(tn);
  until false;
  EndUpdate;
  DelStack;
end;

class procedure TTreePrim.AddListFiltered;
var tn1: TTreeNode;
begin
  AddStack('TTreePrim.AddListFiltered');
  tn1:=tn;
  while Assigned(tn1) do begin
    flt.Add(longint(tn1)); ParentSelf(tn1);
  end;
  DelStack;
end;

procedure TTreePrim.StExpandAll;
var tn: TTreeNode;
  i,lr: longint;
begin
  AddStack('TTreePrim.StExpandAll',Self);
  BeginUpdate;
  IsFirst(tn); lr:=0;
  while Assigned(tn) do begin
    Inc(lr); GetNextSiblingSelf(tn);
  end;
  IsFirst(tn);
  for i:=1 to lr do begin
    if Sender.SayStat('',tn.Text,i/lr) then break;
    tn.Expand(true); GetNextSiblingSelf(tn);
  end;
  if IsSelected(tn) then if tn.Expanded then Expand(tn);
  EndUpdate;
  DelStack;
end;

procedure TTreePrim.SetOptions;
var lCanCheck,lEnterExpand: boolean;
  si: SmallInt;
  tn: TTreeNode;
begin
	AddStack('TTreePrim.SetCanCheck',Self);
	if FOptions<>Value then begin
    lCanCheck := (tpCanCheck in FOptions) <> (tpCanCheck in Value);
    lEnterExpand := (tpEnterExpand in FOptions) <> (tpEnterExpand in Value);
  	FOptions:=Value;
    if not(csDesigning in ComponentState) then begin
      if lCanCheck then begin
        si:=aSign[not(tpCanCheck in FOptions)]; IsFirst(tn);
        while Assigned(tn) do begin
          tn.StateIndex:=si; GetNextSelf(tn);
        end;
        NmEnter(true);
      end;
      if lEnterExpand then NmEnter;
    end;
    CalcOffsPrim;
  end;
  DelStack;
end;

procedure TTreePrim.SetOption;
begin
  AddStack('TTreePrim.SetOption',Self);
  if lSet then Options:=Options+Value else Options:=Options-Value;
  DelStack;
end;

function TTreePrim.GetChecked;
begin
	AddStack('TTreePrim.GetChecked',Self);
	result := Node.StateIndex>1;
  DelStack;
end;

procedure TTreePrim.SetChecked;
var cng,Allowed: boolean;
  StateIndex: longint;
begin
	AddStack('TTreePrim.SetChecked',Self);
  cng := Value<>Checked[Node]; Allowed:=true; StateIndex:=IfThen(Value,2,1);
  if cng and Assigned(FOnChecking) then FOnChecking(Self,Node,Value,Allowed,StateIndex);
  if Allowed then begin
    Node.StateIndex:=StateIndex;
    if cng then begin
      IfThenTreeChecked(FOnChecked,Self,Node,Value);
      if Filtered then aFlt^[NodeInf(Node).nFlt].chk:=Value;
    end;
  end;
  DelStack;
end;

function TTreePrim.GetPrimRect;
begin
  AddStack('TTreePrim.GetPrimRect',Self);
  result:=Node.DisplayRect(true); result.Left:=FPrimLeft;
  Canvas.Font.Assign(FFontPrim);
  result.Right:=min(FPrimLeft+Canvas.TextWidth(NodeInf(Node).Prim),ClientRect.Right);
  DelStack;
end;


procedure TTreePrim.BeginUpdate;
begin
  AddStack('TTreePrim.BeginUpdate',Self);
  if Assigned(Parent) then begin
    if CanUpdate then Items.BeginUpdate;
    Inc(FUpdateCount);
  end;
  DelStack;
end;

procedure TTreePrim.EndUpdate;
begin
  AddStack('TTreePrim.EndUpdate',Self);
  if Assigned(Parent) then begin
    Dec(FUpdateCount);
    if CanUpdate then begin
      Items.EndUpdate; Change(Selected); CalcOffsPrim;
    end;
  end;
  DelStack;
end;

function TTreePrim.CanUpdate;
begin
  result := FUpdateCount=0;
end;

procedure TTreePrim.SetSeekCaption;
begin
  AddStack('TTreePrim.SetSeekCaption',Self);
  FSeekCaption:=Value; CheckPSeek;
  DelStack;
end;

procedure TTreePrim.SetSeekLength;
begin
	AddStack('TTreePrim.SetSeekLength',Self);
  FSeekLength:=Value; CheckPSeek;
  DelStack;
end;

procedure TTreePrim.CheckPSeek;
var lMust,lIs: boolean;
begin
  AddStack('TTreePrim.CheckPSeek',Self);
  lIs:=Assigned(GSeek);
  lMust := (FSeekCaption<>'') and (FSeekLength>0) and not(csDesigning in ComponentState);
  if not lIs and lMust then begin
    GSeek:=TLbSeek.CreateParent(Parent,{Self,}FSeekLength,PrSeek);
    if Parent is TRbPanel then GSeek.Canvas:=TRbPanel(Parent).Canvas;
    MainRebuild(Self);
  end
  else if lIs and not lMust then begin
  	FreeAndNil(GSeek); MainRebuild(Self);
  end;
  DelStack;
end;

procedure TTreePrim.PrSeek;
var s: string;
  tn,tnBeg: TTreeNode;
	procedure Seek1(tn1,tn2: TTreeNode);
  var s1: string;
  begin
    AddStack('TTreePrim.PrSeek.Seek1',Self);
    while Assigned(tn1) do begin
      if SeekNode(tn1) then begin
        s1:=SeekTrans(tn1.Text);
        if s1=s then begin
          tn:=tn1; break;
        end;
        if not Assigned(tnBeg) and AnsiStartsStr(s,s1) then tnBeg:=tn1;
      end;
      if tn1=tn2 then break else GetNextSelf(tn1);
    end;
    DelStack;
  end;
var tnSel: TTreeNode;
begin
  AddStack('TTreePrim.PrSeek',Self);
  s:=SeekTrans(GSeek.GetCaption); tn:=nil; tnBeg:=nil;
  if IsSelected(tnSel) then Seek1(tnSel.GetNext,nil);
  if not Assigned(tn) then Seek1(Items.GetFirstNode,tnSel);
  SelectNoNil(IfThen(tn,tnBeg));
  DelStack;
end;

function TTreePrim.SeekNode;
begin
  AddStack('TTreePrim.SeekNode',Self);
  if Assigned(FOnSeekNode) then result:=FOnSeekNode(Self,Node) else result:=true;
  DelStack;
end;

function TTreePrim.SeekTrans;
begin
  AddStack('TTreePrim.SeekTrans',Self);
  if Assigned(FOnSeekTrans) then result:=FOnSeekTrans(Self,s) else result:=TrimUpper(s);
  DelStack;
end;

function TTreePrim.NodeInf(Node: TTreeNode = nil): PPrimNodeInf;
begin
  NodeInf(result,Node);
end;

function TTreePrim.NodeInf(var p: PPrimNodeInf; Node: TTreeNode = nil): boolean;
var n: longint;
begin
  AddStack('TTreePrim.NodeInf',Self);
  n:=longint(DefSelected(Node).Data); p:=@aPrim[n]; result := n>0;
  DelStack;
end;

function TTreePrim.IniSect;
begin
  AddStack('TTreePrim.IniSect',Self);
  if cSect='' then Sect:=GetParentForm(Self).Name else Sect:=cSect;
  result:=not empty(Sect);
  if result then IncL(Sect,'Tree.');
  DelStack;
end;

function TTreePrim.SaveToIni;
var Sect: string;
  nExp: longint;
  function IsExpanded(tn: TTreeNode; const sParent: string): boolean;
  var s,sp: string;
    tn1: TTreeNode;
    NoExp: boolean;
  begin
    AddStack('TTreePrim.SaveToIni.IsExpanded',Self);
    result:=tn.Expanded;
    if result then begin
      s:=sParent+Trim(tn.Text); sp:=s+UnDelim; NoExp:=true; tn1:=tn.getFirstChild;
      while Assigned(tn1) do begin
        if IsExpanded(tn1,sp) then NoExp:=false;
        GetNextSiblingSelf(tn1);
      end;
      if NoExp then begin
        Inc(nExp); InitFIni[fiSave].WriteString(Sect,IntToStr(nExp),s);
      end;
    end;
    DelStack;
  end;
var tn: TTreeNode;
  s: string;
begin
  AddStack('TTreePrim.SaveToIni',Self);
  if IniSect(cSect,Sect) then begin
    InitFIni[fiSave].EraseSection(Sect);
    if tpiExpanded in Opt then begin
      nExp:=0; IsFirst(tn);
      while Assigned(tn) do begin
        IsExpanded(tn,''); GetNextSiblingSelf(tn);
      end;
    end;
    if tpiSelected in Opt then if IsSelected(tn) then begin
      s:='';
      while Assigned(tn) do begin
        IncL(s,UnDelim+Trim(tn.Text)); ParentSelf(tn);
      end;
      InitFIni[fiSave].WriteString(Sect,'SEL',Copy(s,lUnDelim1,MaxInt));
    end;
  end;
  result:=Sect;
  DelStack;
end;

function TTreePrim.RestFromIni;
var tn: TTreeNode;
  procedure tnFind(const s: string; lExpand: boolean);
  var tn1: TTreeNode;
    s1: string;
    pb,p,l: longint;
    fl: boolean;
  begin
    AddStack('TTreePrim.RestFromIni.tnFind',Self);
    l:=Length(s); tn:=nil; p:=0;
    repeat
      if Assigned(tn) then tn1:=tn.getFirstChild else IsFirst(tn1);
      fl:=true; pb:=p+1; p:=PosEnd(UnDelim,s,pb); s1:=Copy(s,pb,p-pb);
      while Assigned(tn1) do
        if Trim(tn1.Text)=s1 then begin
          fl:=false; tn:=tn1;
          if lExpand then tn.Expand(false);
          break;
        end
        else GetNextSiblingSelf(tn1);
    until (p>l) or fl;
    DelStack;
  end;
var ls: TStringList;
  i: longint;
  s,Sel: string;
  a: TNamePrimStr;
  fl: boolean;
begin
  AddStack('TTreePrim.RestFromIni',Self);
  result:=false;
  if IniSect(cSect,s) then begin
    BeginUpdate; Sel:=cSel;
    if tpiExpanded in Opt then begin
      ls:=TStringList.Create;
      try
        InitFIni[fiSave].ReadSectionValues(s,ls);
        for i:=0 to ls.Count-1 do if StrDivDlm(ls.NameValueSeparator,ls[i],a) then
          if a[1]='SEL' then Sel:=a[2]
          else if tpiExpanded in Opt then tnFind(a[2],true);
      finally
        ls.Free;
      end;
    end;
    fl := (tpiSelected in Opt) and (Sel<>'');
    if fl then tnFind(Sel,false);
    EndUpdate;
    if fl then result:=SelectNoNil(tn);
  end;
  DelStack;
end;

function TTreePrim.FindFirst;
begin
  AddStack('TTreePrim.FindFirst',Self);
  if FindProperty.Direction=fndBack then result:=Items[lr-1] else IsFirst(result);
  DelStack;
end;

class procedure TTreePrim.FindNext;
begin
  AddStack('TTreePrim.FindNext');
  if FindProperty.Direction=fndBack then GetPrevSelf(result) else GetNextSelf(result);
  DelStack;
end;

function TTreePrim.IsSelected;
begin
  result:=My_pr.IsSelected(Self,tn);
end;

function TTreePrim.DefSelected;
begin
  AddStack('TTreePrim.DefSelected');
  if not Assigned(tn) then tn:=Selected;
  result:=tn;
  DelStack;
end;

function TTreePrim.SelectNoNil;
begin
  AddStack('TTreePrim.SelectNoNil',Self);
  result:=Assigned(tn);
  if result then Selected:=tn;
  DelStack;
end;

function TTreePrim.IsNodeAt;
begin
  result:=My_pr.IsNodeAt(Self,X,Y,tn);
end;

function TTreePrim.IsFirst(var tn: TTreeNode): boolean;
begin
  result:=My_pr.IsFirst(Self,tn);
end;

function TTreePrim.IsFirst: boolean;
var tn: TTreeNode;
begin
  result:=IsFirst(tn);
end;

procedure TTreePrim.FirstSelect;
var tn: TTreeNode;
begin
  AddStack('TTreePrim.FirstSelect',Self);
  if IsFirst(tn) then Selected:=tn;
  DelStack;
end;

procedure TTreePrim.FirstIfNil;
begin
  AddStack('TTreePrim.FirstIfNil',Self);
  if not Assigned(tn) then IsFirst(tn);
  DelStack;
end;

function TTreePrim.IfThenText: string;
begin
  result:=IfThenText(Selected);
end;

class function TTreePrim.IfThenText(tn: TTreeNode): string;
begin
  AddStack('TTreePrim.IfThenText');
  if Assigned(tn) then result:=tn.Text else result:='';
  DelStack;
end;

{function TTreePrim.IsCodEqual: boolean;
	procedure Cmp(var result: boolean; tn: TTreeNode);
  begin
  	if not result and Assigned(tn) then result := tn.Text=Selected.Text;
  end;
var tn: TTreeNode;
begin
	result:=false;
  if IsSelected(tn) then begin
	  Cmp(result,tn.GetPrev); Cmp(result,tn.GetNext);
  end;
end;}

procedure Register;
begin
  RegisterComponents('OurLib',[TTreePrim]);
end;

end.

