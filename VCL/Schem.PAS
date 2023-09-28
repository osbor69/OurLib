unit Schem;

interface

uses
  Classes,Graphics,Controls,
  MyTypes;

type
  TSchDefFont = class(TPersistent)
  private
   	FDimFont: TSchFont;
		function GetDimFont(Index: TSchFontList): TFont;
		procedure SetDimFont(Index: TSchFontList; Value: TFont);
  public
		constructor Create;
		destructor Destroy; override;
  published
		property Font1: TFont index dFont1 read GetDimFont write SetDimFont;
		property Font2: TFont index dFont2 read GetDimFont write SetDimFont;
		property FontW: TFont index dFontW read GetDimFont write SetDimFont;
  end;

  TSchemSampleEvent = procedure(Sender: TObject; Parent: TWinControl;
  	var Header: string; var AfterRebuild: TNotifyEvent) of object;

  TSchemOptions = set of (schColorW,schColor1,schColor2,schFontW,schFont1,schFont2,schNoEffect);

  TSchColorList = (dColor1,dColor2,dColorW);

  TSchDefFontList = (dfn0800,dfn1024);

	TSchem = class(TComponent)
	private
   	{ Private declarations }
   	FCaption,FCaptSmall: TCaption;
   	FDimColor: array[TSchColorList] of record
      cl,clDef: TColor;
    end;
   	FDimFont: TSchFont;
   	FDimDefFont: array[TSchDefFontList] of TSchDefFont;
    FDimName: array[0..byte(high(TSchColorList))+byte(high(TSchFontList))+1] of string;
    FOptions: TSchemOptions;
    FOnSample: TSchemSampleEvent;
    FOnSetToAppl: TNotifyEvent;
		function GetCurDefFont(Index: longint): TFont;
    function GetDimColor(Index: TSchColorList): TColor;
    function GetDimDefColor(Index: TSchColorList): TColor;
		function GetDimDefFont(Index: TSchDefFontList): TSchDefFont;
    function GetDimFont(Index: TSchFontList): TFont;
		function GetDimName(Index: longint): string;
    procedure SetCaptSmall(Index: longint; const Value: TCaption);
    procedure SetDimColor(Index: TSchColorList; Value: TColor);
    procedure SetDimDefColor(Index: TSchColorList; Value: TColor);
		procedure SetDimDefFont(Index: TSchDefFontList; Value: TSchDefFont);
    procedure SetDimFont(Index: TSchFontList; Value: TFont);
		procedure SetDimName(Index: longint; const Value: string);
	protected
   	{ Protected declarations }
	public
   	{ Public declarations }
		property Color1: TColor index dColor1 read GetDimColor write SetDimColor;
		property Color2: TColor index dColor2 read GetDimColor write SetDimColor;
		property ColorW: TColor index dColorW read GetDimColor write SetDimColor;
		property Font1: TFont index dFont1 read GetDimFont write SetDimFont;
		property Font2: TFont index dFont2 read GetDimFont write SetDimFont;
		property FontW: TFont index dFontW read GetDimFont write SetDimFont;
		property DefFont1: TFont index dFont1 read GetCurDefFont;
		property DefFont2: TFont index dFont2 read GetCurDefFont;
		property DefFontW: TFont index dFontW read GetCurDefFont;
		constructor Create(AOwner:TComponent); override;
		destructor Destroy; override;
    procedure SetToAppl; dynamic;
		procedure Sample(Parent: TWinControl; var Header: string;
    	var AfterRebuild: TNotifyEvent); dynamic;
    procedure RestDef;
		function Section: string;
    function IfThenColor(tp: TSchColorList; Def: TColor): TColor;
	published
   { Published declarations }
		property Caption: TCaption index 1 read FCaption write FCaption;
		property CaptSmall: TCaption index 2 read FCaptSmall write SetCaptSmall;
		property DefColor1: TColor index dColor1 read GetDimDefColor write SetDimDefColor;
		property DefColor2: TColor index dColor2 read GetDimDefColor write SetDimDefColor;
		property DefColorW: TColor index dColorW read GetDimDefColor write SetDimDefColor;
		property DefFont0800: TSchDefFont index dfn0800 read GetDimDefFont write SetDimDefFont;
		property DefFont1024: TSchDefFont index dfn1024 read GetDimDefFont write SetDimDefFont;
		property NameColor1: string index dColor1 read GetDimName write SetDimName;
		property NameColor2: string index dColor2 read GetDimName write SetDimName;
		property NameColorW: string index dColorW read GetDimName write SetDimName;
		property NameFont1: string index byte(high(TSchColorList))+1+byte(dFont1) read GetDimName write SetDimName;
		property NameFont2: string index byte(high(TSchColorList))+1+byte(dFont2) read GetDimName write SetDimName;
		property NameFontW: string index byte(high(TSchColorList))+1+byte(dFontW) read GetDimName write SetDimName;
    property Options: TSchemOptions read FOptions write FOptions
    	default [schColorW,schColor1,schColor2,schFontW,schFont1,schFont2];
		property OnSample: TSchemSampleEvent read FOnSample write FOnSample;
		property OnSetToAppl: TNotifyEvent read FOnSetToAppl write FOnSetToAppl;
  end;

	TWMSchem = record
   	Msg: longint;
    Oper: (soBefore,soAfter);
		Schem: TSchem;
    Result: LongInt;
	end;

var LsSchem: TStringList;

procedure Register;
function SchemName(const s: string): TSchem; overload;
function SchemName(const s: string; var ts: TSchem): boolean; overload;

implementation

uses Forms,
  My_pr;

var CurDefFont: TSchDefFontList;

// Возвращает указатель на схему по её имени
function SchemName(const s: string): TSchem;
begin
	SchemName(s,result);
end;

function SchemName(const s: string; var ts: TSchem): boolean;
begin
	AddStack('Schem.SchemName');
  if csDesigning in Application.ComponentState then ts:=nil else ts:=PointerObjFind(LsSchem,s);
  result:=Assigned(ts);
  DelStack;
end;

{ TSchDefFont }
constructor TSchDefFont.Create;
var i: TSchFontList;
begin
	AddStack('TSchDefFont.Create');
	for i:=low(FDimFont) to high(FDimFont) do begin
  	FDimFont[i]:=TFont.Create; DefaultFont(FDimFont[i]);
  end;
  FontStyle(FDimFont[dFontW]);
  DelStack;
end;

destructor TSchDefFont.Destroy;
var i: TSchFontList;
begin
	AddStack('TSchDefFont.Destroy');
	for i:=low(FDimFont) to high(FDimFont) do FDimFont[i].Free;
	inherited Destroy;
  DelStack;
end;

function TSchDefFont.GetDimFont;
begin
  AddStack('TSchDefFont.GetDimFont');
  result:=FDimFont[Index];
  DelStack;
end;

procedure TSchDefFont.SetDimFont;
begin
  AddStack('TSchDefFont.SetDimFont');
  FDimFont[Index].Assign(Value);
  DelStack;
end;

{ TSchem }
constructor TSchem.Create;
var f: TSchFontList;
  df: TSchDefFontList;
begin
	AddStack('TSchem.Create',Self);
	Inherited Create(AOwner);
  FOptions:=[schColorW,schColor1,schColor2,schFontW,schFont1,schFont2];
  DefColor1:=clWindow; DefColor2:=clBtnFace; DefColorW:=clBtnFace;
  for df:=low(FDimDefFont) to high(FDimDefFont) do FDimDefFont[df]:=TSchDefFont.Create;
  with FDimDefFont[dfn0800] do
  	for f:=low(FDimFont) to high(FDimFont) do FDimFont[f].Size:=7;
	for f:=low(FDimFont) to high(FDimFont) do FDimFont[f]:=TFont.Create;
  RestDef;
  DelStack;
end;

destructor TSchem.Destroy;
var f: TSchFontList;
  df: TSchDefFontList;
begin
	AddStack('TSchem.Destroy',Self);
	for f:=low(FDimFont) to high(FDimFont) do FDimFont[f].Free;
  for df:=low(FDimDefFont) to high(FDimDefFont) do FDimDefFont[df].Free;
  CaptSmall:='';
	inherited Destroy;
  DelStack;
end;

function TSchem.GetDimColor;
begin
	AddStack('TSchem.GetDimColor',Self);
	result:=FDimColor[Index].cl;
  DelStack;
end;

procedure TSchem.SetDimColor;
begin
	AddStack('TSchem.SetDimColor',Self);
	FDimColor[Index].cl:=Value;
  DelStack;
end;

function TSchem.GetDimFont;
begin
	AddStack('TSchem.GetDimFont',Self);
  result:=FDimFont[Index]; result.Color:=FDimFont[Index].Color;
  DelStack;
end;

procedure TSchem.SetDimFont;
begin
	AddStack('TSchem.SetDimFont',Self);
	FDimFont[Index].Assign(Value);
  DelStack;
end;

function TSchem.GetDimDefColor;
begin
	AddStack('TSchem.GetDimDefColor',Self);
	result:=FDimColor[Index].clDef;
  DelStack;
end;

procedure TSchem.SetCaptSmall;
begin
  AddStack('TSchem.SetCaptSmall',Self);
  if Value<>FCaptSmall then begin
    if Assigned(LsSchem) and not empty(FCaptSmall) then FindDelFree(LsSchem,FCaptSmall);
    if not empty(Value) then SortStrListCreate(LsSchem).AddObject(Value,Self);
    FCaptSmall:=Value;
  end;
  DelStack;
end;

procedure TSchem.SetDimDefColor;
begin
	AddStack('TSchem.SetDimDefColor',Self);
	FDimColor[Index].clDef:=Value;
  DelStack;
end;

function TSchem.GetDimDefFont;
begin
  AddStack('TSchem.GetDimDefFont',Self);
  result:=FDimDefFont[Index];
  DelStack;
end;

procedure TSchem.SetDimDefFont;
begin
  AddStack('TSchem.SetDimDefFont');
  FDimDefFont[Index].Assign(Value);
  DelStack;
end;

function TSchem.GetDimName;
begin
  AddStack('TSchem.GetDimName',Self);
  result:=FDimName[Index];
  DelStack;
end;

procedure TSchem.SetDimName;
begin
  AddStack('TSchem.SetDimName',Self);
  FDimName[Index]:=Value;
  DelStack;
end;

procedure TSchem.RestDef;
var c: TSchColorList;
  f: TSchFontList;
begin
	AddStack('TSchem.RestDef',Self);
	for c:=low(FDimColor) to high(FDimColor) do with FDimColor[c] do cl:=clDef;
  for f:=low(FDimFont) to high(FDimFont) do FDimFont[f].Assign(FDimDefFont[CurDefFont].FDimFont[f]);
  DelStack;
end;

procedure TSchem.SetToAppl;
begin
	AddStack('TSchem.SetToAppl',Self);
	IfThenNotify(FOnSetToAppl,Self);
  DelStack;
end;

function TSchem.GetCurDefFont;
begin
  AddStack('TSchem.DefFontW',Self);
  result:=FDimDefFont[CurDefFont].FDimFont[TSchFontList(Index)];
  DelStack;
end;

function TSchem.Section;
const a: array[TSchDefFontList] of string = ('800','');
begin
  AddStack('TSchem.Section',Self);
  result:=CaptSmall+a[CurDefFont];
  DelStack;
end;

function TSchem.IfThenColor;
begin
  AddStack('TSchem.IfThenColor',Self);
  if Assigned(Self) then result:=GetDimColor(tp) else result:=Def;
  DelStack;
end;

procedure TSchem.Sample;
begin
  AddStack('TSchem.Sample',Self);
  if Assigned(FOnSample) then FOnSample(Self,Parent,Header,AfterRebuild);
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurLib',[TSchem]);
end;

procedure Init;
const a: array[TSchDefFontList] of Word = (800,1024);
var i: TSchDefFontList;
begin
	AddStack('Schem.initialization');
	CurDefFont:=low(CurDefFont);
  for i:=low(i) to high(i) do if Screen.Width>=a[i] then CurDefFont:=i;
  DelStack;
end;

initialization
  Init;
end.

