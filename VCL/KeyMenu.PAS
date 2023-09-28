unit KeyMenu;

interface

uses
  Windows,Classes,Graphics,Controls,Forms,Menus,
  MyTypes;

type
  TKeyMenuHideItem = set of (kmnDisabled,kmnHide);
	TKeyMenuHideItemEvent = procedure(Sender: TObject; Part,Key: longint; Opt: TKeyMenuHideItem) of object;

  TKeyMenu = class(TMainMenu)
  private
    { Private declarations }
    curf: TForm;
    oCH: longint;
    ows: TWindowState;
    FOnHideItem: TKeyMenuHideItemEvent;
		procedure BeginCH;
		procedure EndCH;
    function FDelItem(mn1: TMenuItem): boolean;
    class procedure MNDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    class procedure MNMeasureItem(Sender: TObject; ACanvas: TCanvas; var Width,Height: longint);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function AddItem(Part,Key: longint; const Capt: TCaption; Proc: TNotifyEvent): TMenuItem;
    function SeekItem(Part,Key: longint; var Item: TMenuItem): boolean;
    function CngProcItem(Part,Key: longint; Proc: TNotifyEvent): TMenuItem;
		procedure DelItem(Part,Key: longint);
    procedure EnabledItem(Part,Key: longint; Enabled: boolean);
    procedure HideItem(Part,Key: longint; Opt: TKeyMenuHideItem = []);
    procedure InsLine(Part,Key: longint);
    procedure DelLine(Part,Key: longint);
		function IsPriorLine(Part,Key: longint): boolean;
    function SeekPart(Part: longint; const Capt: string = ''): TMenuItem;
  	procedure EditKeysAdd;
  	procedure EditKeysDel;
    class function LatToPart(const nmLat: string): longint;
    class function PartToLat(Part: longint): string;
    class function LatToRus(const nmLat: string): string;
    class function RusToLat(const nameRus: string): string;
    //class function CaptWithOutKey(const s: string): string;
  published
  	property OnHideItem: TKeyMenuHideItemEvent read FOnHideItem write FOnHideItem;
  end;

procedure Register;
function SeekKeyMenu(Sender: TControl): TKeyMenu; overload;
function SeekKeyMenu(Sender: TControl; var mn: TKeyMenu): boolean; overload;
procedure SeekKeyMenu(Sender: TControl; var mn: TKeyMenu; AComponent: TComponent; Operation: TOperation); overload;

implementation

uses SysUtils,Math,Variants,
  My_pr,FPanel;

const MaxPart = 11;
	iX = 20;
	iX2 = iX shl 1;

type TKMPart = 1..MaxPart;

const
	anPart: array[TKMPart] of string =
  	('FILE','EDIT','LIST','SERVIC','CALC','PAGE','GENFORM','ARHIV','DESIGN','HELP','EXIT');

	anRusPart: array[TKMPart] of string =
  	('Файл','Правка','Список','Обслуживание','Калькулятор','Страницы','Документ',
    'Архив','Разработка','Помощь','Выход');

	akmPart: array[TKMPart] of Word =
  	(kmFile,kmEdit,kmList,kmServic,kmCalc,kmPage,kmGenForm,kmArhiv,kmDesign,kmHelp,kmExit);

// Найти меню
function SeekKeyMenu(Sender: TControl): TKeyMenu;
begin
  SeekKeyMenu(Sender,result);
end;

function SeekKeyMenu(Sender: TControl; var mn: TKeyMenu): boolean;
var f: TForm;
begin
	AddStack('KeyMenu.SeekKeyMenu');
  if ParentForm(Sender,f) then result:=IsClass(f.Menu,TKeyMenu,pointer(mn))
  else begin
  	mn:=nil; result:=false;
  end;
  DelStack;
end;

procedure SeekKeyMenu(Sender: TControl; var mn: TKeyMenu; AComponent: TComponent; Operation: TOperation);
begin
  case Operation of
    opInsert: if AComponent is TKeyMenu then SeekKeyMenu(Sender,mn);
    opRemove: if AComponent=mn then mn:=nil;
  end;
end;

function IsLine(mn: TMenuItem): boolean;
begin
	AddStack('KeyMenu.IsLine');
	result := mn.Caption=cLineCaption;
  DelStack;
end;

{ TKeyMenu }
constructor TKeyMenu.Create;
begin
	AddStack('TKeyMenu.Create',Self);
	inherited Create(AOwner);
  AutoHotKeys:=maManual; OwnerDraw:=true;
  DelStack;
end;

// Найти раздел
function TKeyMenu.SeekPart;
var i,j: longint;
  s: string;
label lend;
begin
	AddStack('TKeyMenu.SeekPart',Self);
  result:=nil;
  if Part=kmNone then goto lend;
  if not Assigned(Owner) then goto lend;
	if (csDesigning in ComponentState) or (csLoading in ComponentState)
  then goto lend;
  j:=-1;
  for i:=0 to Items.Count-1 do begin
    if Items[i].Tag=Part then begin
      result:=Items[i]; goto lend;
    end;
    if Items[i].Tag>Part then begin
      j:=i; break;
    end;
  end;
  s:=Capt;
  if s='' then for i:=low(akmPart) to high(akmPart) do
  	if Part=akmPart[i] then begin
    	s:=anRusPart[i]; break;
    end;
  if s='' then goto lend;
  BeginCH;
  result:=TMenuItem.Create(Self);
  result.Tag:=Part; result.Caption:=s;
  if j=-1 then Items.Add(result) else Items.Insert(j,result);
  EndCH;
lend:
	DelStack;
end;

// Изменение высоты меню
procedure TKeyMenu.BeginCH;
begin
	AddStack('TKeyMenu.BeginCH',Self);
  curf:=pointer(Owner);
  if Assigned(curf) then begin
    oCH:=curf.ClientHeight; ows:=curf.WindowState;
  end;
  DelStack;
end;

procedure TKeyMenu.EndCH;
begin
	AddStack('TKeyMenu.EndCH',Self);
  if Assigned(curf) then begin
    if curf.ClientHeight<>oCH then MainRebuild(curf);
    curf.WindowState:=ows;
  end;
  DelStack;
end;

// Добавить пункт в указанный раздел
function TKeyMenu.AddItem;
  procedure FAddItem(mn,mn1: TMenuItem);
	var i: longint;
  begin
    AddStack('TKeyMenu.AddItem.FAddItem',Self);
    BeginCH;
    mn.Add(mn1); mn.Visible:=true;
    for i:=0 to Items.Count-1 do
      if (Items[i]<>mn) and (Items[i].Count=0) then Items[i].Visible:=false;
    EndCH;
    DelStack;
  end;
var i,j: longint;
  mn,mn1,mn2: TMenuItem;
  f: TForm;
  ows: TWindowState;
  fl: boolean;
begin
	AddStack('TKeyMenu.AddItem',Self);
  result:=nil;
	if not((csDesigning in ComponentState) or (csLoading in ComponentState)) then begin
    if IsClass(Owner,TForm,pointer(f)) then ows:=f.WindowState else ows:=wsNormal;
    if empty(Capt) then mn:=nil else mn:=SeekPart(Part);
    for i:=0 to Items.Count-1 do begin
      mn1:=Items[i];
      for j:=0 to mn1.Count-1 do begin
        mn2:=mn1[j];
        if mn2.Tag=Key then begin
          if not Assigned(mn) or (mn1<>mn) then begin
            fl:=FDelItem(mn2);
            if Assigned(mn) then begin
              mn2.Enabled:=true; FAddItem(mn,mn2);
            end
            else begin
              if fl then mn2.Free;
              mn2:=nil;
            end;
          end;
          result:=mn2; break;
        end;
      end;
      if Assigned(result) then break;
    end;
    if not Assigned(result) and Assigned(mn) then begin
      result:=TMenuItem.Create(Self);
      result.OnDrawItem:=MNDrawItem; result.OnMeasureItem:=MNMeasureItem;
      FAddItem(mn,result);
    end;
    if Assigned(result) then with result do begin
      Tag:=Key; Caption:=Capt; onClick:=Proc;
    end;
    if Assigned(f) then f.WindowState:=ows;
  end;
  DelStack;
end;

function TKeyMenu.IsPriorLine;
var mn: TMenuItem;
begin
  AddStack('TKeyMenu.IsPriorLine',Self);
  result:=false;
  if SeekItem(Part,Key,mn) then
    if mn.MenuIndex>0 then result:=IsLine(mn.Parent[mn.MenuIndex-1]);
  DelStack;
end;

function MnKey(mn: TMenuItem): string;
begin
	AddStack('KeyMenu.MnKey');
	if IsLine(mn) then result:='' else result:=KeyToTxt(mn.Tag);
  DelStack;
end;

class procedure TKeyMenu.MNDrawItem;
var mn: TMenuItem;
	t,j: longint;
  sk: string;
  procedure CaptOut;
  begin
  	AddStack('TKeyMenu.MNDrawItem.CaptOut');
  	ACanvas.TextRect(ARect,ARect.Left+iX,t,mn.Caption);
    if sk<>'' then begin
    	Inc(ARect.Left,j);
    	ACanvas.TextRect(ARect,ARect.Left,t,sk);
    	Dec(ARect.Left,j);
    end;
    DelStack;
  end;
var fs: TFontStyles;
	bs: TBrushStyle;
  fc,bc: TColor;
  i: longint;
begin
	AddStack('TKeyMenu.MNDrawItem');
  mn:=pointer(Sender);
  with ACanvas do begin
  	fs:=Font.Style; bs:=Brush.Style; fc:=Font.Color; bc:=Brush.Color;
    if Selected then Brush.Color:=clHighlight;
    FillRect(ARect);
    if mn.Default then FontStyle(Font);
    j:=0;
    for i:=0 to mn.Parent.Count-1 do MaxSelf(j,ACanvas,mn.Parent[i].Caption);
    Inc(j,iX2); sk:=MnKey(mn); t:=ARect.Top+max(0,(ARect.Bottom-ARect.Top-CanvasMaxH(ACanvas)) div 2);
    if not mn.Enabled then begin
    	if not Selected then begin
		    Brush.Style:=bsClear;
        OffsetRect(ARect,1,1);
        Font.Color:=aclBtn[true];
        CaptOut;
        OffsetRect(ARect,-1,-1);
      end;
      Font.Color:=aclBtn[Selected and (ColorToRGB(clHighlight)=ColorToRGB(aclBtn[false]))];
    end;
    CaptOut;
    bmCheckPaint(ACanvas,Rect(ARect.Left,ARect.Top,ARect.Left+iX,aRect.Bottom),mn.Checked);
    Font.Style:=fs; Brush.Style:=bs; Font.Color:=fc; Brush.Color:=bc;
  end;
  DelStack;
end;

class procedure TKeyMenu.MNMeasureItem;
var mn: TMenuItem;
  s: string;
  w: longint;
begin
	AddStack('TKeyMenu.MNMeasureItem');
  mn:=pointer(Sender);
  if mn.Default then FontStyle(ACanvas.Font);
  w:=ACanvas.TextWidth(mn.Caption)+iX2; s:=MnKey(mn);
  if s<>'' then Inc(w,iX2+ACanvas.TextWidth(s));
  MaxSelf(Width,w);
  DelStack;
end;

function TKeyMenu.SeekItem;
var mn: TMenuItem;
	i: longint;
begin
  AddStack('TKeyMenu.SeekItem',Self);
	result:=false; mn:=SeekPart(Part);
  if Assigned(mn) then for i:=0 to mn.Count-1 do begin
  	Item:=mn[i];
    if Item.Tag=Key then begin
    	result:=true; break;
    end;
  end;
  DelStack;
end;

// Сменить процедуру указанного пункта
function TKeyMenu.CngProcItem;
begin
	AddStack('TKeyMenu.CngProcItem',Self);
  if SeekItem(Part,Key,result) then result.onClick:=Proc else result:=nil;
  DelStack;
end;

// Удалить пункт из указанного раздела
procedure TKeyMenu.DelItem;
var mn: TMenuItem;
  {i,j: longint;
  fl: boolean;}
begin
	AddStack('TKeyMenu.DelItem',Self);
  {if Part=kmNone then begin
    fl:=false;
    for i:=0 to Items.Count-1 do begin
      for j:=0 to Items[i].Count-1 do begin
        mn:=Items[i][j];
        if mn.Tag=Key then begin
          fl:=true; break;
        end;
      end;
      if fl then break;
    end;
  end
  else fl:=SeekItem(Part,Key,mn);
  if fl then if FDelItem(mn) then mn.Free;}
  if SeekItem(Part,Key,mn) then if FDelItem(mn) then mn.Free;
  DelStack;
end;

function TKeyMenu.FDelItem;
var mn,mnl: TMenuItem;
	procedure DelMn1;
  begin
    AddStack('TKeyMenu.FDelItem.DelMn1',Self);
    if mnl=mn1 then result:=false;
    mn.Remove(mnl); mnl.Free;
    DelStack;
  end;
  procedure DelMn(Index: longint);
  begin
  	AddStack('TKeyMenu.FDelItem.DelMn');
    if mn.Count>0 then begin
      mnl:=mn[Index];
      if IsLine(mnl) then DelMn1;
    end;
    DelStack;
  end;
var fl: boolean;
	i,j: longint;
begin
	AddStack('TKeyMenu.FDelItem',Self);
  mn:=mn1.Parent; mn.Remove(mn1); result:=true;
  for i:=0 to mn.Count-2 do
    if IsLine(mn[i]) then begin
      j:=i+1;
      while j<mn.Count-1 do begin
        mnl:=mn[j];
        if not IsLine(mnl) then break;
        DelMn1;
      end;
    end;
  DelMn(0); DelMn(mn.Count-1);
  if mn.Count=0 then begin
    fl:=true;
    for i:=0 to Items.Count-1 do
    	if (Items[i]<>mn) and Items[i].Visible then begin
      	fl:=false; break;
      end;
    BeginCH; mn.Visible:=fl; EndCH;
  end;
  DelStack;
end;

// Разрешить/запретить выбор пункта
procedure TKeyMenu.EnabledItem;
var Opt: TKeyMenuHideItem;
begin
	AddStack('TKeyMenu.EnabledItem',Self);
  if Enabled then Opt:=[] else Opt:=[kmnDisabled];
  HideItem(Part,Key,Opt);
  DelStack;
end;

procedure TKeyMenu.HideItem;
var mn: TMenuItem;
	ost: longint;
begin
  ost:=AddStack('TKeyMenu.HideItem',Self);
  if SeekItem(Part,Key,mn) then
    try
      mn.Enabled:=not(kmnDisabled in Opt); mn.Visible:=not(kmnHide in Opt);
    except
      SetStack(ost);
    end;
  if Assigned(FOnHideItem) then FOnHideItem(Self,Part,Key,Opt);
  DelStack;
end;

// Вставить линию в указанный раздел перед указанным пунктом
procedure TKeyMenu.InsLine;
var mn: TMenuItem;
begin
	AddStack('TKeyMenu.InsLine',Self);
  if SeekItem(Part,Key,mn) then
    if mn.MenuIndex>0 then
      if not IsLine(mn.Parent[mn.MenuIndex-1]) then mn.Parent.Insert(mn.MenuIndex,MenuNewLine(Self));
  DelStack;
end;

procedure TKeyMenu.DelLine;
var mn,mn1: TMenuItem;
begin
	AddStack('TKeyMenu.DelLine',Self);
  if SeekItem(Part,Key,mn) then
    if mn.MenuIndex>0 then begin
      mn1:=mn.Parent[mn.MenuIndex-1];
      if IsLine(mn1) then begin
        mn.Parent.Remove(mn1); mn1.Free;
      end;
    end;
  DelStack;
end;

procedure TKeyMenu.EditKeysAdd;
begin
	AddStack('TKeyMenu.EditKeysAdd',Self);
	if Assigned(Self) then begin
    AddItem(kmEdit,K_Ctrl_X,'Вырезать',nil);
    AddItem(kmEdit,K_Ctrl_C,'Копировать',nil);
    AddItem(kmEdit,K_Ctrl_V,'Вставить',nil);
    AddItem(kmEdit,K_Ctrl_Y,'Удалить строку',nil);
    AddItem(kmEdit,K_Ctrl_A,'Выделить всё',nil);
    InsLine(kmEdit,K_Ctrl_X);
    EnabledItem(kmEdit,K_Ctrl_X,false);
    EnabledItem(kmEdit,K_Ctrl_C,false);
    EnabledItem(kmEdit,K_Ctrl_V,false);
    EnabledItem(kmEdit,K_Ctrl_Y,false);
    EnabledItem(kmEdit,K_Ctrl_A,false);
	end;
  DelStack;
end;

procedure TKeyMenu.EditKeysDel;
begin
	AddStack('TKeyMenu.EditKeysDel',Self);
	if Assigned(Self) then begin
    DelLine(kmEdit,K_Ctrl_X);
    DelItem(kmEdit,K_Ctrl_X); DelItem(kmEdit,K_Ctrl_C);
    DelItem(kmEdit,K_Ctrl_V); DelItem(kmEdit,K_Ctrl_Y); DelItem(kmEdit,K_Ctrl_A);
	end;
  DelStack;
end;

class function TKeyMenu.LatToPart;
var i: longint;
begin
	AddStack('TKeyMenu.LatToPart');
  if AnsiFindText(nmLat,anPart,low(anPart),i) then result:=akmPart[i] else result:=kmNone;
  DelStack;
end;

class function TKeyMenu.PartToLat;
var i: longint;
begin
  AddStack('TKeyMenu.PartToLat');
  result:=IntToStr(Part);
  for i:=low(akmPart) to high(akmPart) do
  	if Part=akmPart[i] then begin
    	result:=anPart[i]; break;
    end;
  DelStack;
end;

class function TKeyMenu.LatToRus;
var i: longint;
begin
	AddStack('TKeyMenu.LatToRus');
  if AnsiFindText(nmLat,anPart,low(anPart),i) then result:=anRusPart[i] else result:='';
  DelStack;
end;

class function TKeyMenu.RusToLat;
var i: longint;
begin
	AddStack('TKeyMenu.RusToLat');
  if AnsiFindText(Trim(nameRus),anRusPart,low(anRusPart),i) then result:=anPart[i] else result:='';
  DelStack;
end;

// Удаляет в строке подсказку о клавише
{class function TKeyMenu.CaptWithOutKey;
const begKey='<'; endKey='>';
var i,j: longint;
begin
	AddStack('TKeyMenu.CaptWithOutKey');
	result:=Trim(s);
  if result<>'' then begin
    j:=length(result);
    if result[j]=endKey then for i:=j-1 downto 1 do
      if result[i]=begKey then begin
        result:=TrimRight(LeftStr(result,i-1)); break;
      end;
  end;
  DelStack;
end;}

procedure Register;
begin
  RegisterComponents('OurLib',[TKeyMenu]);
end;

initialization
	AddStack('KeyMenu.initialization');
	VARusPart:=ArrStrToVar(anRusPart);
  DelStack;
end.

