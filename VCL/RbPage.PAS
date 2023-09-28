unit RbPage;

interface

uses
  Messages,Classes,Controls,ComCtrls,
  MyTypes,FPanel;

type
  TRbPage = class(TPageControl)
  private
    { Private declarations }
    FCngByCtrl,Entered: boolean;
    FFldEdit: TList;
    nmPr: string;
		procedure ProcKey(Key: longint; tw: TWinControl);
		procedure FillFld;
		function ParentPg(var pg: TRbPage): boolean;
		procedure SetKeys;
		procedure DelKeys;
    procedure PagesHighlighted;
		procedure WMRebuild(var Message: TWMRebuild); message WM_REBUILD;
		procedure WMWHMin(var Message: TWMWHMin); message WM_WHMIN;
		procedure WMSchemName(var Message: TWMSchemName); message WM_SCHEMNAME;
		procedure WMKeyRbMenu(var Message: TMessage); message WM_KEYRBMENU;
		procedure WMCtrlInf(var Message: TWMCtrlInf); message WM_CTRLINF;
    procedure WMPSort(var Message: TWMPSort); message WM_PSORT;
  protected
    { Protected declarations }
		procedure DoEnter; override;
		procedure DoExit; override;
    //function CanChange: Boolean; override;
		procedure Change; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
		procedure SetActivePage(ts: TTabSheet);
		function SetTabVisible(ts: TTabSheet; Value: boolean): boolean;
    procedure KeysRefresh;
  published
    { Published declarations }
    property CngByCtrl: boolean read FCngByCtrl write FCngByCtrl;
  end;

procedure Register;

implementation

uses Forms,Math,
  My_pr,KeyLb,KeyMenu,FFldEdit,PnlEdit;

var nIndex: longint = 0;

{ TRbPage }
constructor TRbPage.Create;
begin
	AddStack('TRbPage.Create',Self);
	inherited Create(AOwner);
  FFldEdit:=TList.Create; FCngByCtrl:=true; nmPr:=StrNum('rbpage',nIndex); Inc(nIndex);
  DelStack;
end;

destructor TRbPage.Destroy;
begin
	AddStack('TRbPage.Destroy',Self);
  DoExit; FFldEdit.Free;
	inherited Destroy;
  DelStack;
end;

procedure TRbPage.WMRebuild;
var i,j: longint;
  pn: TCustomRbPanel;
begin
	AddStack('TRbPage.WMRebuild',Self);
	with Message.RbPnl do begin
  	i:=BevPanel; j:=HeaderHeight;
		Self.SetBounds(i,i+j,CltWidth,CltHeight-j);
  end;
	for i:=0 to PageCount-1 do with Pages[i] do
    for j:=0 to ControlCount-1 do
      if IsClass(Controls[j],TCustomRbPanel,pointer(pn)) then pn.Rebuild(ClientWidth,ClientHeight);
  DelStack;
end;

procedure TRbPage.DoEnter;
begin
	AddStack('TRbPage.DoEnter',Self);
  if not IsCalculator then begin
    inherited DoEnter;
    if not Entered then begin
      SetKeys;
      //if Assigned(ActivePage) then ActivePage.Highlighted:=true;
      Entered:=true; PagesHighlighted;
    end;
  end;
  DelStack;
end;

procedure TRbPage.DoExit;
begin
	AddStack('TRbPage.DoExit',Self);
  if not IsCalculator then begin
    if Entered then begin
      DelKeys;
      {if Assigned(Parent) then
        if Assigned(ActivePage) then ActivePage.Highlighted:=false;}
      Entered:=false; PagesHighlighted;
    end;
    inherited DoExit;
  end;
  DelStack;
end;

procedure TRbPage.DelKeys;
var tl: TKeyLb;
	km: TKeyMenu;
  fl: boolean;
  pg: TRbPage;
begin
  AddStack('TRbPage.DelKeys',Self);
  if ParentPg(pg) then fl:=not pg.Entered else fl:=true;
  if fl then
    if SeekKeyMenu(Self,km) then km.DelLine(kmPage,IfThen(FCngByCtrl,K_Ctrl_Left,K_Left));
  if FormKeyLb(Self,tl) then tl.DelKey(K_All,nmPr);
  DelStack;
end;

procedure TRbPage.SetKeys;
var i,j: longint;
	km: TKeyMenu;
	tl: TKeyLb;
begin
  AddStack('TRbPage.SetKeys',Self);
  if PageCount>1 then 
    if FormKeyLb(Self,tl) then with tl do begin
    	j:=K_Ctrl_1;
      for i:=0 to min(9,PageCount)-1 do with Pages[i] do
      	if TabVisible then begin
	        SetKey(j,'',Caption,ProcKey,nmPr,kmPage); Inc(j);
        end;
      if FCngByCtrl then begin
        SetKey(K_Ctrl_Left,'','Предыдущая страница',ProcKey,nmPr,kmPage);
        SetKey(K_Ctrl_Right,'','Следующая страница',ProcKey,nmPr,kmPage);
      end
      else begin
        SetKeys([K_Left,K_Ctrl_Left],'','Предыдущая страница',ProcKey,nmPr,kmPage);
        SetKeys([K_Right,K_Ctrl_Right],'','Следующая страница',ProcKey,nmPr,kmPage);
      end;
      if SeekKeyMenu(Self,km) then Km.InsLine(kmPage,IfThen(FCngByCtrl,K_Ctrl_Left,K_Left));
    end;
  FillFld;
  DelStack;
end;

function TRbPage.SetTabVisible;
begin
  AddStack('TRbPage.SetTabVisible',Self);
  result := ts.TabVisible<>Value;
  if result then begin
	  ts.TabVisible:=Value; KeysRefresh;
  end;
  DelStack;
end;

procedure TRbPage.KeysRefresh;
begin
  AddStack('TRbPage.KeysRefresh',Self);
  if Entered then begin
    DelKeys; SetKeys;
  end;
  DelStack;
end;

{function TRbPage.CanChange;
begin
	AddStack('TRbPage.CanChange',Self);
  result := inherited CanChange;
  if result and Entered and Assigned(ActivePage) then ActivePage.Highlighted:=false;
  DelStack;
end;}

procedure TRbPage.Change;
var i: longint;
  tf: TFldEdit;
label lend;
begin
	AddStack('TRbPage.Change',Self);
	inherited Change;
  if csDesigning in ComponentState then goto lend;
  //if Entered and Assigned(ActivePage) then ActivePage.Highlighted:=true;
  PagesHighlighted;
  FillFld;
  if FFldEdit.Count>0 then begin
  	for i:=0 to FFldEdit.Count-1 do if TFldEdit(FFldEdit[i]).Active then goto lend;
  	for i:=0 to FFldEdit.Count-1 do begin
      tf:=FFldEdit[i];
    	if tf.CanFocus and not(ogReadOnly in tf.Options) then begin
				GetParentForm(Self).ActiveControl:=tf; break;
      end;
    end;
  end;
lend:
	DelStack;
end;

procedure TRbPage.PagesHighlighted;
var i: longint;
  ts: TTabSheet;
begin
  AddStack('TRbPage.PagesHighlighted',Self);
  if Assigned(Parent) then for i:=0 to PageCount-1 do begin
    ts:=Pages[i]; ts.Highlighted := Entered and (ts=ActivePage);
  end;
  DelStack;
end;

procedure TRbPage.FillFld;
var tl: TKeyLb;
	i: longint;
  tw: TWinControl;
begin
	AddStack('TRbPage.FillFld',Self);
  FFldEdit.Clear;
  if Assigned(ActivePage) then begin
    ActivePage.GetTabOrderList(FFldEdit); i:=0;
    while i<FFldEdit.Count do begin
      tw:=FFldEdit[i];
      if (tw is TFldEdit) and tw.Visible and tw.Enabled then
      	if TFldEdit(tw).Relation<>frMain then begin
          while (tw<>Self) and not(tw is TPanelEdit) do ParentSelf(tw);
          if tw=Self then begin
          	Inc(i); continue;
          end;
        end;
      FFldEdit.Delete(i);
    end;
  end;
  if FormKeyLb(Self,tl) then with tl do
    if FFldEdit.Count=0 then begin
      DelKey(K_Shift_Home,nmPr); DelKey(K_Shift_End,nmPr);
    end
    else begin
      SetKey(K_Shift_Home,'','На первое поле страницы',ProcKey,nmPr,kmPage);
      SetKey(K_Shift_End,'','На последнее поле страницы',ProcKey,nmPr,kmPage);
    end;
  DelStack;
end;

procedure TRbPage.ProcKey;
begin
	AddStack('TRbPage.ProcKey',Self);
  Perform(WM_KEYRBMENU,Key,0);
	DelStack;
end;

procedure TRbPage.WMKeyRbMenu;
	function NoParentPg: boolean;
  var pg: TRbPage;
  begin
    AddStack('TRbPage.WMKeyRbMenu.NoParentPg',Self);
    result:=not ParentPg(pg);
    if not result then with Message do pg.perform(WM_KEYRBMENU,WParam,LParam);
    DelStack;
  end;
var i: longint;
	function tfFocus: boolean;
  var tf: TFldEdit;
  begin
  	AddStack('TRbPage.WMKeyRbMenu.tfFocus',Self);
  	tf:=FFldEdit[i]; result := not(ogReadOnly in tf.Options);
    if result then begin
    	tf.SetFocus; Message.LParam:=0;
    end;
    DelStack;
  end;
var n: longint;
	function PgVisible: boolean;
  begin
  	AddStack('TRbPage.WMKeyRbMenu.PgVisible',Self);
  	result:=Pages[i].TabVisible; if result then n:=i;
    DelStack;
  end;
var Menu: TControl;
  function MsgCont(Sender: TWinControl): boolean;
  var j: longint;
    tw: TWinControl;
  begin
    AddStack('TRbPage.WMKeyRbMenu.MsgCont',Self);
    with Sender do for j:=0 to ControlCount-1 do
      if Controls[j]<>Menu then
        if Controls[j].perform(WM_KEYRBMENU,Message.WParam,0)=0 then begin
        	if IsClass(Controls[j],TWinControl,pointer(tw)) then if MsgCont(tw) then break;
        end
        else begin
          SetActivePage(Pages[i]);
          if IsClass(Controls[j],TWinControl,pointer(tw)) then
            if tw.CanFocus then tw.SetFocus;
          Controls[j].perform(WM_KEYRBMENU,Message.WParam,1); Message.result:=1; break;
        end;
    result := Message.result<>0;
    DelStack;
  end;
var ind: longint;
label lend;
begin
  AddStack('TRbPage.WMKeyRbMenu',Self);
  inherited;
  with Message do begin
    ind:=ActivePageIndex;
    if ind<0 then goto lend;
    n:=ind;
    if FCngByCtrl and (WParam in [K_Left,K_Right]) then WParam:=0;
    case WParam of
      K_Left,K_Ctrl_Left: begin
        for i:=ind-1 downto 0 do if PgVisible then break;
        if n=ind then
        	if NoParentPg then
	          for i:=PageCount-1 downto 0 do if PgVisible then break;
      end;
      K_Right,K_Ctrl_Right: begin
        for i:=ind+1 to PageCount-1 do if PgVisible then break;
        if n=ind then
        	if NoParentPg then
	          for i:=0 to PageCount-1 do if PgVisible then break;
      end;
      K_Shift_Home: for i:=0 to FFldEdit.Count-1 do if tfFocus then goto lend;
      K_Shift_End: for i:=FFldEdit.Count-1 downto 0 do if tfFocus then goto lend;
    else
    	ind:=WParam-K_Ctrl_1; n:=-1;
      for i:=0 to PageCount-1 do
      	if Pages[i].TabVisible then
        	if ind=0 then begin
          	n:=i; break;
        	end
          else Dec(ind);
    end;
    if InRange(n,0,PageCount-1) then begin
    	LParam:=0;
      if Pages[n].TabVisible then SetActivePage(Pages[n]);
    end;
lend:
		if LParam<>0 then begin
      Menu:=pointer(LParam);
      for i:=0 to PageCount-1 do if Pages[i].TabVisible then if MsgCont(Pages[i]) then break;
    end;
  end;
  DelStack;
end;

procedure TRbPage.WMCtrlInf;
begin
	AddStack('TRbPage.WMCtrlInf',Self);
  with Message do case Oper of
    ctiCount: Count^:=PageCount;
    ctiItem: Item:=Pages[Index];
  end;
  DelStack;
end;

procedure TRbPage.WMPSort;
begin
	AddStack('TRbPage.WMPSort',Self);
  inherited;
  if Message.Oper in [swmColWidthAll,swmColHeightAll] then Message.result:=1;
  DelStack;
end;

function TRbPage.ParentPg;
var tw: TWinControl;
begin
  AddStack('TRbPage.ParentPg',Self);
  result:=ParentClass(tw,Parent,TRbPage);
  if result then pg:=pointer(tw);
  DelStack;
end;

procedure TRbPage.WMSchemName;
var i,j: longint;
begin
	AddStack('TRbPage.WMSchemName',Self);
	with Message do if Oper=snSetSchem then
  	for i:=0 to PageCount-1 do with Pages[i] do
      for j:=0 to ControlCount-1 do
        Controls[j].perform(WM_SCHEMNAME,byte(Oper),LongInt(SchemName));
  DelStack;
end;

procedure TRbPage.WMWHMin;
var w,h: longint;
  step: boolean;
  procedure WHCalc(tc: TControl);
  var tw: TWinControl;
    i,l: longint;
  begin
  	AddStack('TRbPage.WMWHMin.WHCalc',Self);
    if step then begin
      if tc is TCustomRbPanel then with TCustomRbPanel(tc) do begin
        MaxSelf(w,WMin); MaxSelf(h,HMin);
      end;
    end
    else with TMessage(Message) do tc.perform(Msg,WParam,LParam);
    if IsClass(tc,TWinControl,pointer(tw)) then begin
      l:=CtrlInfCount(tw)-1;
      for i:=0 to l do WHCalc(CtrlInfItem(tw,i));
    end;
    DelStack;
  end;
var i,j: longint;
  ts: TTabSheet;
  tw,twp: TWinControl;
  tp,tp1,tp2: TCustomRbPanel;
  fl: boolean;
begin
	AddStack('TRbPage.WMWHMin',Self);
  if PageCount>0 then begin
    tw:=Message.RbPnl; fl:=false;
    while Assigned(tw) do begin
      twp:=tw.Parent;
      if twp is TCustomRbPanel then begin
        TCustomRbPanel(twp).SeekChild(tp1,tp2);
        if Assigned(tp1) and Assigned(tp2) then begin
          tp:=IfThen(tp1=tw,tp2,IfThen(tp2=tw,tp1));
          if Assigned(tp) then if not(tp is TKeyLb) then if not((tp.WMin=0) and (tp.HMin=0)) then begin
            fl:=true; break;
          end;
        end;
      end;
      tw:=twp;
    end;
    w:=0; h:=0;
    for i:=0 to PageCount-1 do with Pages[i] do
      for j:=0 to ControlCount-1 do
        for step:=false to fl do WHCalc(Controls[j]);
    if fl then begin
      ts:=Pages[0]; Inc(w,Width-ts.Width); Inc(h,Height-ts.Height);
      Message.RbPnl.WMin:=w; Message.RbPnl.HMin:=h;
    end;
  end;
  DelStack;
end;

procedure TRbPage.SetActivePage;
begin
	AddStack('TRbPage.SetActivePage',Self);
  if (ActivePage<>ts) and CanChange then begin
    ActivePage:=ts; Change;
  end;
  DelStack;
end;

procedure RbPagePgActive(tw: TWinControl);
var ts: TTabSheet;
  pg: TRbPage;
begin
  AddStack('RbPage.RbPagePgActive');
  repeat
    if not ParentSelf(tw) then break;
    if IsClass(tw,TTabSheet,pointer(ts)) then begin
      pg:=pointer(ts.PageControl);
      if pg.Visible and ts.TabVisible then pg.SetActivePage(ts);
    end;
  until false;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurLib',[TRbPage]);
end;

initialization
  AddStack('RbPage.initialization');
  MyTypes.RbPagePgActive:=RbPagePgActive;
  DelStack;
end.

