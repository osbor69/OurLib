unit MnDrwGet;

interface

{$I LIBTEST}
uses
  Windows,Classes,Graphics,Controls,
  MyTypes,FFldedit,MenuGet;

type
	TMnDrwSzEvent = procedure(Sender: TObject; tf: TFldEdit; isList: boolean; var Size: TSize) of object;
  TMnDrwItemEvent = procedure(Sender: TObject; Canvas: TCanvas;
  	const nRect: TRect;	Index: longint; State: TOwnerDrawState;
    tf: TFldEdit; const Cod: string; isList: boolean) of object;

  TMenuDrawGet = class(TMenuGet)
  private
    { Private declarations }
    CurFld: TFldEdit;
    FOnDrawItem: TMnDrwItemEvent;
    FOnSizePaint: TMnDrwSzEvent;
  	procedure LbDraw(Control: TWinControl; Index: longint; Rect: TRect; State: TOwnerDrawState);
    function SizePaint(tf: TFldEdit; isList: boolean): TSize;
  protected
    { Protected declarations }
    procedure PaintObj(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
		procedure Paint(tf: TFldEdit); override;
    procedure StdListDown(tf: TFldEdit; const RectList: TRect; PozList: TPozList); override;
  	procedure DrawItem(Canvas: TCanvas; const nRect: TRect; Index: longint; State: TOwnerDrawState;
      tf: TFldEdit; const Cod: string; isList: boolean); dynamic;
    procedure DoSizePaint(tf: TFldEdit; isList: boolean; var Size: TSize); dynamic;
  public
    { Public declarations }
    property DefLenCode: longint read FDefLenCode;
    property DefLenName: longint read FDefLenName;
    procedure Assign(Source: TPersistent); override;
  published
    { Published declarations }
    property OnDrawItem: TMnDrwItemEvent read FOnDrawItem write FOnDrawItem;
    property OnSizePaint: TMnDrwSzEvent read FOnSizePaint write FOnSizePaint;
  end;

  TColorGetBrushColorEvent = function(Sender: TObject; tf: TFldEdit; nColor: longint): TColor of object;

  TColorGet = class(TMenuDrawGet)
  private
    FOnBrushColor: TColorGetBrushColorEvent;
  protected
  	procedure DrawItem(Canvas: TCanvas; const nRect: TRect; Index: longint; State: TOwnerDrawState;
      tf: TFldEdit; const Cod: string; isList: boolean); override;
    procedure DoSizePaint(tf: TFldEdit; isList: boolean; var Size: TSize); override;
  public
    aNumBeforeLine: TArrInt;
    constructor CreateColors(AOwner: TComponent; nHigh: longint = high(T16Colors));
    property OnBrushColor: TColorGetBrushColorEvent read FOnBrushColor write FOnBrushColor;
  end;

procedure Register;

implementation

uses SysUtils,Math,StdCtrls,StrUtils,
  My_pr,ListF2,Schem;

{ TMenuDrawGet }

{ Нарисовать объекты }
procedure TMenuDrawGet.PaintObj;
var w,h: longint;
begin
	AddStack('TMenuDrawGet.PaintObj',Self);
	if AssignObj(tf) then begin
    w:=SysMetric.iScrollWidth; h:=tf.Height-BevelFld2;
		eC.SetBounds(BevelFld,BevelFld,0,h); eN.SetBounds(BevelFld,BevelFld,0,h);
    sL.SetBounds(BevelFld+tf.Width-BevelFld2-CountBut(tf)*w,BevelFld,w,h);
    sR.SetBounds(sL.Bounds.Right,BevelFld,w,h);
    sD.SetBounds(sR.Bounds.Right,BevelFld,w,h);
    tf.Invalidate;
  end;
  DelStack;
end;

{ Автоматическая установка размеров }
function TMenuDrawGet.SizeAuto;
begin
	AddStack('TMenuDrawGet.SizeAuto',Self);
	result:=SizePaint(tf,false);
  if tfszHeight in Opt then Inc(result.cY,4);
  if tfszWidth in Opt then Inc(result.cX,4+CountBut(tf)*SysMetric.iScrollWidth);
  DelStack;
end;

{ Установить свойства объектов в соответствии с Value }
procedure TMenuDrawGet.SetValue;
begin
	AddStack('TMenuDrawGet.SetValue',Self);
	inherited SetValue(tf,v);
	tf.Invalidate;
  DelStack;
end;

procedure TMenuDrawGet.DrawItem;
var sn: string;
  Prm: TMenuGetPrm;
begin
	AddStack('TMenuDrawGet.DrawItem');
	if Assigned(FOnDrawItem)
  then FOnDrawItem(Self,Canvas,nRect,Index,State,tf,Cod,isList)
  else begin
    Prm:=MenuMask2Prm(tf.Mask);
    if (mngCod in Prm.Opt) and (mngName in Prm.Opt)
      then sn:=MenuSt(Cod)
    else if mngName in Prm.Opt
      then sn:=MenuName(Cod)
    else sn:=Cod;
    with Canvas do begin
      Font.Assign(tf.Font); Pen.Color:=clBlack;
      if odSelected in State then begin
        Brush.Color:=clHighLight; Font.Color:=clHighLightText;
      end
      else if csDesigning in ComponentState then Brush.Color:=clWindow else Brush.Color:=tf.Color1;
      FillRect(nRect);
      TextRect(nRect,nRect.Left+2,nRect.Top,TrimRight(sn));
    end;
  end;
  DelStack;
end;

{ Вызов выпадающего списка }
procedure TMenuDrawGet.StdListDown;
var lr: TListF2Result;
	mr: TMenuGetRec;
	ac: TArrStr;
  i: longint;
  s: string;
  ts: TSchem;
begin
	AddStack('TMenuDrawGet.StdListDown',Self);
  if AssignObj(tf) then begin
    lr:=TListF2Result.Create;
    try
      i:=Items.Count; SetLength(ac,i); s:='';
      for i:=0 to i-1 do begin
        mr:=ACodName(i); IncD(s,CRLF+IfThen(eC.Visible,mr.Cod+' ')+mr.Name); ac[i]:=mr.Cod;
      end;
      lr.SelectStr:=SeekCurCod(tf); CurFld:=tf;
      if SchemName(tf.Schem,ts) then tf.Font.Assign(ts.Font1);
      if ListF2Down(copy(s,lCRLF1,MaxInt),lr,eN,max(RectList.Right-RectList.Left,SizePaint(tf,true).cX+8),
      tf.Schem,'',nil,CanvasMaxH(tf.Canvas),LbDraw) then
        if lr.SelectStr<0 then tf.Value:='' else tf.Value:=ac[lr.SelectStr];
    finally
	    lr.Free; 
    end;
  end;
  DelStack;
end;

function TMenuDrawGet.SizePaint;
var ts: TSchem;
	w: longint;
  Prm: TMenuGetPrm;
begin
	AddStack('TMenuDrawGet.SizePaint',Self);
	if AssignObj(tf) then begin
    if not(csDesigning in ComponentState) then
      if SchemName(tf.Schem,ts) then tf.Font.Assign(ts.Font1) else DefaultFont(tf.Font);
    tf.Canvas.Font.Assign(tf.Font);
    result.cY:=CanvasMaxH(tf.Canvas);
		Prm:=MenuMask2Prm(tf.Mask); w:=0;
    if mngCod in Prm.Opt then Inc(w,DefLenCode);
    if mngName in Prm.Opt then Inc(w,DefLenName);
    if (mngCod in Prm.Opt) and (mngName in Prm.Opt) then Inc(w,2);
    result.cX:=CanvasMaxW(tf.Canvas)*w+6;
    DoSizePaint(tf,false,result);
  end
  else DefSize(result);
  DelStack;
end;

procedure TMenuDrawGet.DoSizePaint;
begin
  AddStack('TMenuDrawGet.DoSizePaint',Self);
  if Assigned(FOnSizePaint) then FOnSizePaint(Self,tf,isList,Size);
  DelStack;
end;

procedure TMenuDrawGet.LbDraw;
var ls: TFindListBox;
begin
	AddStack('TMenuDrawGet.LbDraw',Self);
  ls:=pointer(Control);
	DrawItem(ls.Canvas,Rect,Index,State,CurFld,ACodName(ls.GetIndexFiltered(Index)).Cod,true);
  DelStack;
end;

procedure TMenuDrawGet.Paint;
var r: TRect;
begin
	AddStack('TMenuDrawGet.Paint',Self);
  with tf.Canvas do begin
  	r:=Rect(BevelFld,BevelFld,tf.Width-BevelFld-CountBut(tf)*SysMetric.iScrollWidth,
      tf.Height-BevelFld);
  	Frame3D2(tf.Canvas,r); Brush.Color:=tf.Color1; FillRect(r);
    DrawItem(tf.Canvas,r,0,[odDisabled],tf,tf.Value,false);
  end;
  DelStack;
end;

procedure TMenuDrawGet.Assign;
var cg: TMenuDrawGet;
begin
	AddStack('TMenuDrawGet.Assign',Self);
  if IsClass(Source,TMenuDrawGet,pointer(cg)) then begin
   	OnDrawItem:=cg.OnDrawItem; OnSizePaint:=cg.OnSizePaint;
  end;
	inherited Assign(Source);
  DelStack;
end;

{ TColorGet }
constructor TColorGet.CreateColors;
var i: SmallInt;
begin
	AddStack('TColorGet.CreateColors',Self);
  inherited Create(AOwner);
  SetLength(aNumBeforeLine,1); aNumBeforeLine[0]:=16;
  with Items do begin
    BeginUpdate; Clear;
  	for i:=low(ANmColor) to nHigh do Add(IntToStr(i)+UnDelim+ANmColor[i]);
    EndUpdate;
  end;
  DelStack;
end;

procedure TColorGet.DrawItem;
var l,cl: longint;
	nRect1: TRect;
begin
  AddStack('TColorGet.DrawItem',Self);
  with Canvas do begin
    Brush.Color:=tf.Color1; nRect1:=nRect; FillRect(nRect1);
    with nRect1 do begin
      Inc(Left); Inc(Top); Dec(Right); Dec(Bottom);
    end;
    Font.Assign(tf.Font);
    if odSelected in State then begin
  		Brush.Color:=clHighLight; Font.Color:=clHighLightText;
    end;
    FillRect(nRect1);
    if not(ogReadOnly in tf.Options) then begin
    	Pen.Color:=clBlack;
      Rectangle(nRect1.Left+2,nRect1.Top+2,nRect1.Left+32,nRect1.Bottom-2);
      l:=nRect1.Left; Inc(nRect1.Left,34);
      if isList or (Pos(cMnCod,AnsiUpperCase(tf.Mask))=0)
      then TextRect(nRect1,nRect1.Left,nRect1.Top-1,TrimRight(MenuName(Cod)));
      cl:=Int0(Cod);
      if InRange(cl,low(AColor),high(AColor)) then Brush.Color:=AColor[cl]
      else Brush.Color:=FOnBrushColor(Self,tf,cl);
      FillRect(Rect(l+3,nRect1.Top+3,nRect1.Left-3,nRect1.Bottom-3));
      if isList then for l:=low(aNumBeforeLine) to high(aNumBeforeLine) do
        if (cl=aNumBeforeLine[l]) then with nRect do begin
          MoveTo(Left,Top); LineTo(Right,Top); break;
        end;
    end;
  end;
  DelStack;
end;

procedure TColorGet.DoSizePaint;
var ts: TSchem;
begin
  AddStack('TColorGet.DoSizePaint',Self);
  with tf.Canvas do begin
	  if SchemName(tf.Schem,ts) then Font.Assign(ts.Font1) else DefaultFont(Font);
    Size.cX:=34;
    if isList or (Pos(cMnCod,AnsiUpperCase(tf.Mask))=0)
    then Inc(Size.cX,2+CanvasMaxW(tf.Canvas)*DefLenName);
  end;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TMenuDrawGet]);
end;

end.
