unit SpdBtGet;

interface

uses
  Windows,Classes,Controls,
  MyTypes,KeyMenu,FFldedit,PaintCtl;

type
  TSBClickEvent = procedure(PaintButton: TPaintButton; Index: longint) of object;

	TSBButInf = record
  	BitMap,Hint: string;
    AllowAllUp: boolean;
  end;

  TSpdButGet = class(TCustomGet)
  private
    { Private declarations }
		MainMn: TKeyMenu;
    FButtons: TStrings;
    FDimKey: array[1..2] of string;
    FOnClick: TSBClickEvent;
    function GetDimKey(Index: longint): string;
    procedure SetDimKey(Index: longint; const Value: string);
		procedure SetButtons(Value: TStrings);
    function ButInf(i: longint): TSBButInf;
    procedure EvalClick(Sender: TObject);
		procedure ProcKey(key: longint; tw: TWinControl);
		procedure EnabledKeys(tf: TFldEdit);
  protected
    { Protected declarations }
    aBut: TArrPaintButton;
    lBut: longint;
    procedure CreateObj(tf: TFldEdit); override;
    //procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function AssignObj(tf: TFldEdit): boolean; override;
		procedure Paint(tf: TFldEdit); override;
    procedure Click(PaintButton: TPaintButton; Index: longint); dynamic;
  public
    { Public declarations }
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
		class procedure SetButDown(tf: TFldEdit; Index: longint; Down: boolean);
    class procedure SetButEnabled(tf: TFldEdit; Index: longint; Enabled: boolean);
  published
    { Published declarations }
    property Buttons: TStrings read FButtons write SetButtons;
    property KeyTxt: string index 1 read GetDimKey write SetDimKey;
    property KeyHint: string index 2 read GetDimKey write SetDimKey;
    property OnClick: TSBClickEvent read FOnClick write FOnClick;
	  { Унаследованные }
   	property RVid;
   	property RVName;
   	property VName;
  end;

procedure Register;

implementation

uses SysUtils,Graphics,StrUtils,Math,
  My_pr,KeyLb;

const DefSzBut = 19;
	iX = 5;
	iY = 5;
  dXY = 2;
  hCurs = 2;

{ TSpdButGet }
constructor TSpdButGet.Create;
begin
	AddStack('TSpdButGet.Create',Self);
	Inherited Create(AOwner);
  FButtons:=TStringList.Create; UpdateAllFld(mgCreate);
  DelStack;
end;

destructor TSpdButGet.Destroy;
begin
	AddStack('TSpdButGet.Destroy',Self);
	FButtons.Free; 
	inherited Destroy;
  DelStack;
end;

procedure TSpdButGet.SetButtons;
begin
	AddStack('TSpdButGet.SetButtons',Self);
	if not FButtons.Equals(Value) then begin
		FButtons.Assign(Value); UpdateAllFld(mgCreate);
  end;
  DelStack;
end;

function TSpdButGet.GetDimKey;
begin
	AddStack('TSpdButGet.GetDimKey',Self);
	result:=FDimKey[Index];
  DelStack;
end;

procedure TSpdButGet.SetDimKey;
begin
	AddStack('TSpdButGet.SetDimKey',Self);
	if FDimKey[Index]<>Value then FDimKey[Index]:=Value;
  DelStack;
end;

{ Создание объектов }
procedure TSpdButGet.CreateObj;
var i: longint;
	ib: TSBButInf;
  sb: TPaintButton;
begin
	AddStack('TSpdButGet.CreateObj',Self);
	DestroyObj(tf);
  for i:=0 to FButtons.Count-1 do begin
    ib:=ButInf(i); sb:=TPaintButton.Create(tf);
    with sb do begin
      Canvas:=tf.Canvas; AllowAllUp:=ib.AllowAllUp;
      if ib.Hint<>'' then begin
        Hint:=ib.Hint; ShowHint:=true;
      end;
      BMByName(Glyph,ib.BitMap); OnClick:=EvalClick;
    end;
  end;
  inherited CreateObj(tf);
  DelStack;
end;

{procedure TSpdButGet.ReCreateObj;
var i: longint;
	ib: TSBButInf;
  sb: TPaintButton;
begin
	AddStack('TSpdButGet.ReCreateObj',Self);
	if AssignObj(tf) then begin
    for i:=0 to lBut-1 do begin
      ib:=ButInf(i); sb:=aBut[i];
    end;
    inherited ReCreateObj(tf);
  end;
  DelStack;
end;

{ Нарисовать объекты }
procedure TSpdButGet.PaintObj;
var i,lb: longint;
  sb: TPaintButton;
begin
	AddStack('TSpdButGet.PaintObj',Self);
	if AssignObj(tf) then begin
    lb:=dXY+BevelFld;
    for i:=0 to lBut-1 do begin
      sb:=aBut[i];
      if Assigned(sb.Glyph) then begin
        sb.SetBounds(lb,dXY+BevelFld,sb.Glyph.Height+iX,sb.Glyph.Height+iY);
        Inc(lb,sb.Glyph.Height+iX);
      end
      else begin
        sb.SetBounds(lb,dXY,DefSzBut+iX,DefSzBut+iY);
        Inc(lb,DefSzBut+iX);
      end;
    end;
  end;
  DelStack;
end;

{ Автоматическая установка размеров }
function TSpdButGet.SizeAuto;
var i: longint;
  sb: TPaintButton;
begin
	AddStack('TSpdButGet.SizeAuto');
	result := inherited SizeAuto(tf,Opt);
  if AssignObj(tf) then begin
    if tfszWidth in Opt then result.cX:=0;
    if tfszHeight in Opt then result.cY:=0;
    for i:=0 to lBut-1 do begin
      sb:=aBut[i];
      if Assigned(sb.Glyph) then begin
        if tfszWidth in Opt then Inc(result.cX,sb.Glyph.Height+iX);
        if tfszHeight in Opt then MaxSelf(result.cY,sb.Glyph.Height);
      end
      else begin
        if tfszWidth in Opt then Inc(result.cX,DefSzBut+iX);
        if tfszHeight in Opt then MaxSelf(result.cY,DefSzBut);
      end;
    end;
    if tfszWidth in Opt then Inc(result.cX,2*dXY);
    if tfszHeight in Opt then Inc(result.cY,iY+3*dXY+hCurs);
  end;
  DelStack;
end;

{ Достать значение Value из объектов }
function TSpdButGet.GetValue;
var i: longint;
begin
	AddStack('TSpdButGet.GetValue',Self);
	result:='0';
  if AssignObj(tf) then for i:=0 to lBut-1 do if aBut[i].Tag=1 then begin
    result:=IntToStr(i+1); break;
  end;
  DelStack;
end;

{ Установить свойства объектов в соответствии с Value }
procedure TSpdButGet.SetValue;
var i,n: longint;
begin
	AddStack('TSpdButGet.SetValue',Self);
  if AssignObj(tf) then begin
    n:=Int0(v)-1;
    for i:=0 to lBut-1 do aBut[i].Tag:=IfThen(i=n,1);
    tf.PaintObj; Paint(tf);
  end;
  DelStack;
end;

{ Действия при получении фокуса }
procedure TSpdButGet.DoEnter;
var tl: TKeyLb;
begin
	AddStack('TSpdButGet.DoEnter',Self);
  inherited DoEnter(tf);
  if AssignObj(tf) then
    if FormKeyLb(tf,tl) and not(ogReadOnly in tf.Options) then with tl do begin
      SetKey(K_Space,IfThen(KeyTxt='','Выполнить',KeyTxt),KeyHint,ProcKey,'spdbutget',kmEdit);
      SetKey(K_Home,'','Первая кнопка',ProcKey,'spdbutget',kmNone);
      SetKey(K_End,'','Последняя кнопка',ProcKey,'spdbutget',kmNone);
      SetKey(K_Left,'','Предыдущая кнопка',ProcKey,'spdbutget',kmEdit);
      SetKey(K_Right,'','Следующая кнопка',ProcKey,'spdbutget',kmEdit);
      ReDrw;
      if SeekKeyMenu(tf,MainMn) then MainMn.InsLine(kmEdit,K_Space);
      EnabledKeys(tf);
    end;
  DelStack;
end;

{ Действия при утере фокуса }
procedure TSpdButGet.DoExit;
var tl: TKeyLb;
begin
	AddStack('TSpdButGet.DoExit',Self);
  if SeekKeyMenu(tf,MainMn) then MainMn.DelLine(kmEdit,K_Space);
  if FormKeyLb(tf,tl) then begin
  	tl.DelKey(K_All,'spdbutget'); tl.ReDrw;
  end;
  inherited DoExit(tf);
  DelStack;
end;

procedure TSpdButGet.ProcKey;
var tf: TFldEdit;
	p: longint;
begin
	AddStack('TSpdButGet.ProcKey',Self);
  tf:=pointer(tw); p:=Int0(GetValue(tf));
  if p<>0 then begin
    case Key of
      K_Space: if p>0 then aBut[p-1].Click;
      K_Home: tf.Value:='1';
      K_End: tf.Value:=IntToStr(lBut);
      K_Left: if p>1 then tf.Value:=IntToStr(p-1);
      K_Right: if p<lBut then tf.Value:=IntToStr(p+1);
    end;
    if Key<>K_Space then EnabledKeys(tf);
  end;
  DelStack;
end;

procedure TSpdButGet.EnabledKeys;
var v: Longint;
begin
	AddStack('TSpdButGet.EnabledKeys',Self);
	if Assigned(MainMn) then begin
    v:=Int0(tf.Value);
    MainMn.EnabledItem(kmEdit,K_Left,v>1);
    MainMn.EnabledItem(kmEdit,K_Right,v<lBut);
  end;
  DelStack;
end;

// Выполнить
procedure TSpdButGet.EvalClick;
var tf: TFldEdit;
	i: longint;
  sb1: TPaintButton;
  fl: boolean;
begin
	AddStack('TSpdButGet.EvalClick',Self);
	sb1:=pointer(Sender); tf:=FldEditOwner(sb1);
	if not tf.Active then begin
	  fl:=sb1.Down; tf.SetFocus; sb1.Down:=fl;
  end;
  if not(ogReadOnly in tf.Options) then if AssignObj(tf) then for i:=1 to lBut do if aBut[i-1]=sb1 then begin
  	tf.Value:=IntToStr(i); Click(sb1,i); EnabledKeys(tf); break;
  end;
  DelStack;
end;

procedure TSpdButGet.Click;
begin
	AddStack('TSpdButGet.Click',Self);
	if Assigned(FOnClick) then FOnClick(PaintButton,Index);
  DelStack;
end;

{ Поиск объектов }
function TSpdButGet.AssignObj;
var i: longint;
begin
	AddStack('TSpdButGet.AssignObj',Self);
  lBut:=0; result:=false;
  if inherited AssignObj(tf) then
		if tf.ComponentCount>0 then begin
      lBut:=tf.ComponentCount;
      if Length(aBut)<lBut then SetLength(aBut,lBut);
      for i:=0 to lBut-1 do aBut[i]:=pointer(tf.Components[i]);
      result:=true;
    end;
  DelStack;
end;

procedure TSpdButGet.Paint;
var r: TRect;
	i: longint;
begin
	AddStack('TSpdButGet.Paint',Self);
  with tf do begin
    r:=Rect(BevelFld,BevelFld,Width-BevelFld,Height-BevelFld);
    Frame3D1(Canvas,r);
    if lBut>0 then begin
    	Canvas.Brush.Color:=Color;
	    with aBut[0].Bounds do Canvas.FillRect(Rect(Left,Bottom+dXY,aBut[lBut-1].Bounds.Right,Bottom+dXY+hCurs));
      for i:=0 to lBut-1 do with aBut[i] do if Tag=1 then begin
        Canvas.Brush.Color:=clBlack;
        with Bounds do Canvas.FillRect(Rect(Left,Bottom+dXY,Right,Bottom+dXY+hCurs));
        break;
      end;
    end;
  end;
  DelStack;
end;

function TSpdButGet.ButInf;
var a: TNamePrimStr;
begin
	AddStack('TSpdButGet.ButInf',Self);
  with result do begin
    a:=StrDivDlm(UnDelim,FButtons[i]); BitMap:=Trim(a[1]);
    StrDivDlm(UnDelim,a); Hint:=Trim(a[1]);
    AllowAllUp:=StrToBoolean(StrToChar(Trim(a[2])));
  end;
  DelStack;
end;

// Поиск кнопок с указанным номером
function SeekButs(tf: TFldEdit; Index: longint; var aBut: TArrPaintButton): longint;
var i,j: longint;
begin
	AddStack('SpdButGet.SeekButs');
	result:=0;
  if NameGet(tf) is TSpdButGet then with tf do begin
    j:=1; i:=ComponentCount;
    if Length(aBut)<i then SetLength(aBut,i);
    for i:=0 to i-1 do if IsClass(Components[i],TPaintButton,pointer(aBut[result])) then begin
      if (Index=0) or (Index=j) then Inc(result);
      Inc(j);
    end;
  end;
  DelStack;
end;

class procedure TSpdButGet.SetButDown;
var aBut: TArrPaintButton;
  i: longint;
begin
	AddStack('TSpdButGet.SetButDown');
  for i:=0 to SeekButs(tf,Index,aBut)-1 do aBut[i].Down:=Down;
  DelStack;
end;

class procedure TSpdButGet.SetButEnabled;
var aBut: TArrPaintButton;
  i: longint;
begin
	AddStack('TSpdButGet.SetButEnabled');
  for i:=0 to SeekButs(tf,Index,aBut)-1 do aBut[i].Enabled:=Enabled;
  DelStack;
end;

procedure TSpdButGet.Assign;
var cg: TSpdButGet;
begin
	AddStack('TSpdButGet.Assign',Self);
  if IsClass(Source,TSpdButGet,pointer(cg)) then begin
    Buttons.Assign(cg.Buttons);
  	OnClick:=cg.OnClick;
  end;
	inherited Assign(Source);
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TSpdButGet]);
end;

end.
