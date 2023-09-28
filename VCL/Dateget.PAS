unit Dateget;

interface

{$I LIBTEST}
{ $DEFINE PROP}

uses
  Windows,Classes,Controls,
  MyTypes,FFldEdit,RecVal;

type
	TDateGet = class(TSimpleGet)
	private
   	{ Private declarations }
    function SetEditMask(tf: TFldEdit; const m: string): string;
		procedure ProcKey(Key: longint; tw: TWinControl);
	protected
   	{ Protected declarations }
    procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const vv: string); override;
    function Check(tf: TFldEdit): boolean; override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function MayDoKey(tf: TFldEdit; Key: longint): boolean; override;
    function FromCalc(tf: TFldEdit; d: Double; X,Y: longint): boolean; override;
		function DWFldUnAllowType(const Mask: string): TDWFldSetType; override;
		procedure Paint(tf: TFldEdit); override;
		class procedure MaskEdChange(Sender: TObject; const OldVal: variant; FromShow: boolean); override;
  	class function MaskSortMode: TSortMode; override;
    class procedure FMaskView(var Mask: string); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
	public
   	{ Public declarations }
		constructor Create(AOwner: TComponent); override;
		procedure StdDWFldInfo(const Mask: string; var FldInfo: TDWFldInfo); override;
		procedure StdDWFldValue(r: TCustomRec; const Mask: string; var Value: variant); override;
		class function MaskTextReadOnly: boolean; override;
	published
   	{ Published declarations }
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
	end;

  TTimeCurGet = class(TSimpleGet)
  private
		class procedure ProcKey(Key: longint; tw: TWinControl);
  protected
  	procedure CreateObj(tf: TFldEdit); override;
    function Check(tf: TFldEdit): boolean; override;
  	procedure DoEnter(tf: TFldEdit); override;
  	procedure DoExit(tf: TFldEdit); override;
  public
		constructor Create(AOwner: TComponent = nil); override;
    class function DateToTime(d: TDateTime): string;
  end;

procedure Register;

implementation

uses SysUtils,Variants,Math,StrUtils,DateUtils,
  My_pr,KeyLb,Schem;

const
  cDtProp = '@PROP';

  KeyDateCur = K_Alt_Home;

type
  TDateGetVid = (dgvNormal,dgvYear4,dgvMMYYYY,dgvDD,dgvYYYY);

	TDateGetPrm = record
    {$IFDEF PROP}LProp,{$ENDIF}lEnd,DayOfWeek: boolean;
    Msk,Dop: string;
    v: TDateGetVid;
  end;

const aNmVid: array[TDateGetVid] of string =
  ('обычный','(устар.)год полностью','только месяц.год','только день','только год');

function MaskPrm(const Mask: string): TDateGetPrm;
var p: longint;
begin
  AddStack('DateGet.MaskPrm');
  with result do begin
{$IFDEF PROP}
    lProp := Pos(cDtProp,Mask)>0;
{$ENDIF}
    lEnd := Pos(cDtEnd,Mask)>0;
    DayOfWeek := Pos(cDtWeek,Mask)>0;
    Msk:=Trim(StrTran(Mask,[cDtEnd,cDtProp,cDtWeek],['','','']));
    Dop:=''; v:=dgvNormal;
    if Msk=cDtYear then v:=dgvYear4
    else if Msk=cDtYYYY then v:=dgvYYYY
    else begin
      if IsPos(p,cDtMY,Msk) then begin
      	v:=dgvMMYYYY;
        if p>3 then Dop:=LeftStr(Msk,p-2);
      end
      else if AnsiStartsStr(cDtDay,Msk) then begin
        v:=dgvDD;
        if Msk<>cDtDay then Dop:=Copy(Msk,Length(cDtDay)+2,MaxInt);
      end;
    end;
  end;
  DelStack;
end;

function DtMask(tf: TFldEdit): string;
var s: string;
  p,i,l: longint;
  Prm: TDateGetPrm;
begin
	AddStack('DateGet.DtMask');
	with tf do begin
    Prm:=MaskPrm(Mask);
    if Prm.Msk=cDtYear then result:='99/99/9999'
    else if Prm.Msk=cDtYYYY then result:='9999'
    else if IsPos(p,cDtMY,Prm.Msk) then begin
      result:='99/9999';
      if p>3 then begin
        s:='';
        for i:=1 to p-2 do IncD(s,'\'+Prm.Msk[i]);
        IncL(result,s+'/');
      end;
    end
    else begin
      if AnsiStartsStr(cDtDay,Prm.Msk) then begin
        result:='99';
        if Prm.Msk<>cDtDay then begin
          s:=ReadStr; l:=length(s);
          if l>=7 then begin
            IncD(result,'/');
            for i:=4 to 5 do IncD(result,'\'+s[i]);
            IncD(result,'/');
            for i:=7 to l do IncD(result,'\'+s[i]);
          end;
        end;
      end
      else result:='99/99/9999';
    end;
	  IncD(result,';1; ');
  end;
  DelStack;
end;

{ TDateGet }
constructor TDateGet.Create;
begin
	AddStack('TDateGet.Create',Self);
	Inherited Create(AOwner);
  RVid:='Ввод даты';
  DelStack;
end;

// Переустановить свойства объектов
procedure TDateGet.ReCreateObj;
var m: string;
  Prm: TDateGetPrm;
begin
	AddStack('TDateGet.ReCreateObj',Self);
	if AssignObj(tf) then begin
    Prm:=MaskPrm(tf.Mask);
    if (Prm.v=dgvMMYYYY) and not empty(Prm.Dop) then begin
      tm.SelAllStart:=Length(Prm.Dop)+1; tm.SelAllLength:=7;
    end
    else tm.SelAllLength:=0;
    m:=tm.Text;
    //inherited ReCreateObj(tf);
    tm.ReadOnly := (ogReadOnly in tf.Options) or Assigned(bDyn);
    //tm.EditMask:='';
    tm.Text:=m;
{$IFDEF PROP}
    if Prm.lProp and not tf.Active then m:='' else
{$ENDIF}
    m:=DtMask(tf);
    SetEditMask(tf,m); tf.PaintObj; tm.SelStart:=0; tm.SelLength:=0; tm.AutoSelect:=false;
  end;
  DelStack;
end;

// Достать значение Value из объектов
function TDateGet.GetValue;
var s: string;
  Prm: TDateGetPrm;
begin
	AddStack('TDateGet.GetValue',Self);
	result := inherited GetValue(tf);
	if AssignObj(tf) then with tf do begin
    Prm:=MaskPrm(tf.Mask);
{$IFDEF PROP}
    if Prm.lProp and not Active then
      if Prm.Msk=cDtMY then result:=dtoc(our_ctom(result)) else result:=dtoc(our_ctod(result))
    else begin
{$ENDIF}
      if Prm.Msk=cDtYear
        then result:=dtoc(ctod(result))
      else if Prm.Msk=cDtYYYY
        then result:=dtoc(IfThen(not empty(Int0(result)),ctod('01'+DateSeparator+'01'+DateSeparator+Trim(result))))
      else if Prm.Msk=cDtMY
        then result:=dtoc(ctod(IfThen(Empty(LeftStr(result,2))
        	and Empty(copy(result,4,MaxInt)),
          IfThen(Prm.lEnd,numstr(IntToStr(DayOf(DateBig)),2),'  '),'01')
          +DateSeparator+result))
      else if Prm.Msk=cDtDay then begin
        s:=ReadStr; IncD(result,copy(s,3,MaxInt));
      end;
{$IFDEF PROP}
    end;
{$ENDIF}
  	if Prm.lEnd and (ctod(result)=DateEmpty) then result:=dtoc(DateBig);
  end;
  DelStack;
end;

function FSetValue(const v: string; const ReadStr,Mask: string; Active: boolean): string;
var Prm: TDateGetPrm;
	s: string;
  p: longint;
begin
  AddStack('DateGet.FSetValue');
  Prm:=MaskPrm(Mask); result:=v;
  if Prm.lEnd and (result=dtoc(DateBig)) then result:=dtoc(DateEmpty);
{$IFDEF PROP}
  if Prm.lProp and not Active then
    if Prm.Msk=cDtMY then result:=our_mtoc(ctod(result)) else result:=our_dtoc(ctod(result))
  else begin
{$ENDIF}
    if Prm.Msk=cDtYear then result:=dtoc(ctod(result))
    else if Prm.Msk=cDtYYYY then result:=SpaceStr0(Year(ctod(result)),4)
    else begin
      if IsPos(p,cDtMY,Prm.Msk) then begin
        result:=copy(dtoc(ctod(result)),4,MaxInt);
        if p<>1 then IncL(result,LeftStr(Prm.Msk,p-2)+DateSeparator);
      end
      else if AnsiStartsStr(cDtDay,Prm.Msk) then begin
        SetLength(result,2);
        if Prm.Msk<>cDtDay then begin
          s:=ReadStr; IncD(result,copy(s,3,MaxInt));
        end;
      end
      else result:=dtoc(ctod(result));
    end;
{$IFDEF PROP}
  end;
{$ENDIF}
  DelStack;
end;

// Установить свойства объектов в соответствии с Value
procedure TDateGet.SetValue;
var Prm: TDateGetPrm;
begin
	AddStack('TDateGet.SetValue',Self);
  inherited SetValue(tf,FSetValue(vv,tf.ReadStr,tf.Mask,tf.Active));
  Prm:=MaskPrm(tf.Mask);
	if AssignObj(tf)
  then tm.SelStart:=IfThen((Prm.v=dgvMMYYYY) and not empty(Prm.Dop),Length(Prm.Dop)+1);
  if Prm.DayOfWeek then tf.Invalidate;
  DelStack;
end;

{ Проверка корректности значения }
function TDateGet.Check;
var Prm: TDateGetPrm;
  v,v0: string;
  d,d1,d2: TDateTime;
begin
	AddStack('TDateGet.Check',Self);
	result := inherited Check(tf);
  if result then with tf do begin
		Prm:=MaskPrm(Mask); v := inherited GetValue(tf);
    if Prm.v=dgvYYYY then v0:=SpaceStr(Int0(v),4) else v0:=LeftStr(v,2)+Copy(v,4,2)+Copy(v,7,MaxInt);
    if not empty(v0) then begin
      case Prm.v of
        dgvMMYYYY: if empty(Prm.Dop) then IncL(v,'01'+DateSeparator);
        dgvDD: if empty(Prm.Dop) then IncD(v,DateSeparator+'01'+DateSeparator+'01');
        dgvYYYY: IncL(v,'01'+DateSeparator+'01'+DateSeparator);
      end;
      result:=TryStrToDate(v,d);
      if result then begin
        d1:=StartOfAYear(1900); d2:=DateBig-1; result:=InRange(d,d1,d2);
        if not result then meserr('Дата должна быть в пределах с '+dtoc(d1)+' по '+dtoc(d2)+'.');
      end;
    end;
  end;
  DelStack;
end;

procedure CntChr(const Prm: TDateGetPrm; var nDig,nSep: longint);
{$IFDEF PROP}
var m: longint;
{$ENDIF}
begin
  AddStack('DateGet.CntChr');
{$IFDEF PROP}
  if Prm.lProp then
    if Prm.Msk=cDtMY then begin
      m:=SetMonthName(1); nDig:=7+Length(MaxMonth); SetMonthName(m);
    end
    else nDig:=10+Length(MaxMonth)
    nSep:=0;
  else
{$ENDIF}
  if Prm.Msk=cDtYYYY then begin
    nDig:=4; nSep:=0;
  end
  else if Prm.Msk=cDtMY then begin
  	nDig:=6; nSep:=1;
  end
  else if Prm.Msk=cDtDay then begin
    nDig:=2; nSep:=0;
  end
  else begin
    nDig:=8; nSep:=2;
  end;
  DelStack;
end;

const iX=2; iY=2;

function SzDayOfWeek(tf: TFldEdit): TSize;
var i: byte;
  ts: TSchem;
begin
  AddStack('DateGet.SzDayOfWeek');
  if SchemName(tf.Schem,ts) then tf.Canvas.Font.Assign(ts.Font2) else tf.Canvas.Font.Assign(tf.Font);
  ZeroMemory(@result,SizeOf(result));
  for i:=low(ShortDayNames) to high(ShortDayNames) do MaxSelf(result,tf.Canvas,ShortDayNames[i]);
  with result do begin
    Inc(cX,iX shl 1); Inc(cY,iY shl 1);
  end;
  DelStack;
end;

procedure TDateGet.PaintObj;
begin
	AddStack('TDateGet.PaintObj',Self);
  inherited PaintObj(tf);
  if MaskPrm(tf.Mask).DayOfWeek and AssignObj(tf) then IncWidth(tm,-SzDayOfWeek(tf).cX);
  DelStack;
end;

procedure TDateGet.Paint;
var sz: TSize;
  d: TDateTime;
  Prm: TDateGetPrm;
begin
  AddStack('TDateGet.Paint',Self);
  inherited Paint(tf);
  Prm:=MaskPrm(tf.Mask);
  if Prm.DayOfWeek then begin
    d:=ctod(tf.Value);
    if not(empty(d) or Prm.lEnd and (d=DateBig)) then begin
      sz:=SzDayOfWeek(tf);
      tf.Canvas.TextOut(tf.Width-BevelFld-sz.cX+iX,(tf.Height-sz.cY) div 2+iY,
        ShortDayNames[DayOfWeek(d)]);
    end;
  end;
  DelStack;
end;

function TDateGet.SizeAuto;
var sz: TSize;
  Prm: TDateGetPrm;
{$IFDEF PROP}
  d: TDateTime;
  s: string;
{$ENDIF}
begin
	AddStack('TDateGet.SizeAuto',Self);
	result := inherited SizeAuto(tf,Opt);
  if Opt<>[] then begin
    Prm:=MaskPrm(tf.Mask);
{$IFDEF PROP}
    if Prm.LProp and lw then begin
      d:=EncodeDate(2000,9,20);
      if Prm.Msk=cDtMY then s:=our_mtoc(d) else s:=our_dtoc(d);
      MaxSelf(result.cX,tf.Canvas,s);
    end;
{$ENDIF}
    if Prm.DayOfWeek then begin
      sz:=SzDayOfWeek(tf);
      if tfszWidth in Opt then Inc(result.cX,sz.cX);
      if tfszHeight in Opt then MaxSelf(result.cY,sz.cY);
    end;
  end;
  DelStack;
end;

function TrnsKey(key: longint; v: TDateGetVid): longint;
var kNoCtrl: longint;
begin
  AddStack('Dateget.TrnsKey');
  result:=key;
  case result of
    K_Alt_Left: result:=K_Minus;
    K_Alt_Right: result:=K_Plus;
  end;
  kNoCtrl := ((result-1) mod KEY_CNT)+1;
  case v of
    dgvMMYYYY: if result=K_Plus then result:=K_Ctrl_Plus
      else if result=K_Minus then result:=K_Ctrl_Minus;
    dgvDD: if kNoCtrl=K_Plus then result:=K_Plus
      else if kNoCtrl=K_Minus then result:=K_Minus;
    dgvYYYY: if kNoCtrl=K_Plus then result:=K_Shift_Plus
      else if kNoCtrl=K_Minus then result:=K_Shift_Minus;
  end;
  DelStack;
end;

{ Действия при получении фокуса }
procedure TDateGet.DoEnter;
var tl: TKeyLb;
  Prm: TDateGetPrm;
  procedure SetKey(key: longint; const hnt: string = '');
  var keyhelp: longint;
  begin
  	AddStack('TDateGet.DoEnter.SetKey',Self);
    keyhelp:=TrnsKey(key,Prm.v);
    if keyhelp=key
    then tl.SetKey(key,'',hnt,ProcKey,'dateget',kmEdit)
    else tl.SetKey(key,'','',ProcKey,'dateget',kmNone,'',keyhelp);
    DelStack;
  end;
begin
	AddStack('TDateGet.DoEnter',Self);
	inherited DoEnter(tf);
  Prm:=MaskPrm(tf.Mask);
{$IFDEF PROP}
	if Prm.lProp then tf.Value:=SetEditMask(tf,DtMask(tf));
{$ENDIF}
  if not Assigned(bDyn) then
    if FormKeyLb(tf,tl) and not(ogReadOnly in tf.Options) then begin
      tl.SetKey(KeyDateCur,'Тек.дата','',ProcKey,'dateget',kmEdit);
      tl.SetKey(K_Space,'','Установить пустую дату',ProcKey,'dateget',kmEdit);
      SetKey(K_Plus,'Увеличить на день');
      SetKey(K_Minus,'Уменьшить на день');
      SetKey(K_Ctrl_Plus,'Увеличить на месяц');
      SetKey(K_Ctrl_Minus,'Уменьшить на месяц');
      SetKey(K_Shift_Plus,'Увеличить на год');
      SetKey(K_Shift_Minus,'Уменьшить на год');
      SetKey(K_Alt_Right);
      SetKey(K_Alt_Left);
      tl.ReDrw;
    end;
  if Assigned(tm) then tm.SelAll(true);
  DelStack;
end;

{ Действия при утере фокуса }
procedure TDateGet.DoExit;
var tl: TKeyLb;
{$IFDEF PROP}
  vv: string;
  Prm: TDateGetPrm;
{$ENDIF}
begin
	AddStack('TDateGet.DoExit',Self);
  if FormKeyLb(tf,tl) then begin
  	tl.DelKey(K_All,'dateget'); tl.ReDrw;
  end;
{$IFDEF PROP}
	if AssignObj(tf) then with tf do begin
    Prm:=MaskPrm(tf.Mask);
		if Prm.lProp then begin
   		SetEditMask(tf,''); vv:=Value;
	   	if Prm.lEnd and (vv=dtoc(DateBig)) then vv:=dtoc(DateEmpty);
      if Prm.Msk=cDtMY then tm.Text:=our_mtoc(ctod(vv)) else tm.Text:=our_dtoc(ctod(vv));
   	end;
  end;
{$ENDIF}
  inherited DoExit(tf);
  DelStack;
end;

procedure TDateGet.ProcKey;
var tf: TFldEdit;
  procedure SetVarValue(v: TDateTime);
  begin
    AddStack('Dateget.SetVarValue',Self);
    if MyVarType(tf.VarValue)=varString then tf.VarValue:=dtoc(v) else tf.VarValue:=v;
    DelStack;
  end;
var v: TDateGetVid;
  d: TDateTime;
begin
  AddStack('TDateGet.ProcKey',Self);
  tf:=FldEditOwner(tw);
  with tf do begin
    v:=MaskPrm(Mask).v; d:=StrToDateDef(GetValue(tf),DateEmpty);
    case TrnsKey(Key,v) of
      K_Space: SetVarValue(DateEmpty);
      K_Plus: if not((v=dgvDD) and (d=eom(d))) then SetVarValue(d+1);
      K_Minus: if not((v=dgvDD) and (d=bom(d)) or empty(d)) then SetVarValue(d-1);
      K_Ctrl_Plus: SetVarValue(IncMonth(d));
      K_Ctrl_Minus: if not empty(d) then SetVarValue(IncMonth(d,-1));
      KeyDateCur: SetVarValue(Date);
      K_Shift_Plus: SetVarValue(IncYear(d));
      K_Shift_Minus: if not empty(d) then SetVarValue(IncYear(d,-1));
    end;
  end;
  DelStack;
end;

function TDateGet.SetEditMask;
begin
	AddStack('TDateGet.SetEditMask',Self);
	if AssignObj(tf) then begin
    result:=tm.Text;
  	if tm.EditMask<>m then begin
      tm.EditMask:=m; tm.Text:=result;
    end;
  end
  else result:='';
  DelStack;
end;

// Можно ли выполнить клавишу
function TDateGet.MayDoKey;
begin
	AddStack('TDateGet.MayDoKey',Self);
	if Key in [K_Esc,K_Alt_Z]
  then result := inherited MayDoKey(tf,Key)
  else result:=Check(tf);
  if not result and (ogAutoSelect in tf.Options) and AssignObj(tf)
  then tm.SelAll(true);
  DelStack;
end;

// Взять число из калькулятора
function TDateGet.FromCalc;
begin
	result:=false;
end;

function TDateGet.MaskTrans;
var Prm: TDateGetPrm;
  s: string;
begin
	AddStack('TDateGet.MaskTrans');
{$IFDEF PROP}
	if MyVarType(av)=varArray then begin
  	s:=Trim(IsNilc(av[5],''));
  	case TDateGetVid(IsNilc(av[4],Succ(dgvNormal))-1) of
      dgvYear4: result:=cDtYear;
      dgvMMYYYY: result:=IfThen(s<>'',s+'.')+cDtMY;
      dgvDD: result:=cDtDay+IfThen(s<>'','.'+s);
      dgvYYYY: result:=cDtYYYY;
    else result:='';
    end;
  	IncD(result,IfThen(IsNilc(av[1],false),cDtProp)+IfThen(IsNilc(av[2],false),cDtEnd)
      +IfThen(IsNilc(av[3],false),cDtWeek));
  end
  else begin
    Prm:=MaskPrm(av);
    result:=ArrVarToVar(
      [VarArrayOf([mpBool,'Прописью',Prm.lProp])
      ,VarArrayOf([mpBool,'Пустая дата как наибольшая',Prm.lEnd])
      ,VarArrayOf([mpBool,'День недели',Prm.DayOfWeek])
      ,VarArrayOf([mpRadio,'Вид ввода',Succ(Prm.v),Length(aNmVid),longint(@aNmVid)])
      ,VarArrayOf([mpEdit,'Месяц.год',Prm.Dop])
      ]);
  end;
{$ELSE}
	if MyVarType(av)=varArray then begin
  	s:=Trim(IsNilc(av[4],''));
  	case TDateGetVid(IsNilc(av[3],Succ(dgvNormal))-1) of
      dgvYear4: result:=cDtYear;
      dgvMMYYYY: result:=IfThen(s<>'',s+'.')+cDtMY;
      dgvDD: result:=cDtDay+IfThen(s<>'','.'+s);
      dgvYYYY: result:=cDtYYYY;
    else result:='';
    end;
  	IncD(result,IfThen(IsNilc(av[1],false),cDtEnd)+IfThen(IsNilc(av[2],false),cDtWeek));
  end
  else begin
    Prm:=MaskPrm(av);
    result:=ArrVarToVar(
      [VarArrayOf([mpBool,'Пустая дата как наибольшая',Prm.lEnd])
      ,VarArrayOf([mpBool,'День недели',Prm.DayOfWeek])
      ,VarArrayOf([mpRadio,'Вид ввода',Succ(Prm.v),Length(aNmVid),longint(@aNmVid)])
      ,VarArrayOf([mpEdit,'Месяц.год',Prm.Dop])
      ]);
  end;
{$ENDIF}
  DelStack;
end;

function TDateGet.DWFldUnAllowType;
begin
  result:=[dwtFloat,dwtBool,dwtArray,dwtSel];
end;

class procedure TDateGet.MaskEdChange;
var v: TDateGetVid;
	tf: TFldEdit;
  s: string;
  a: array[1..2] of string;
begin
	AddStack('TDateGet.MaskEdChange');
{$IFDEF PROP}
	if (Sender=EdMaskFld(4)) or (Sender=EdMaskFld(5)) then begin
    v:=TDateGetVid(GetEdMaskVal(4)-1);
    if Sender=EdMaskFld(4) then begin
      tf:=EdMaskFld(5);
      if v in [dgvNormal,dgvYear4,dgvYYYY] then begin
        s:=''; tf.IncOptions([ogReadOnly,ogReadOnlyNoVsbl]);
      end
      else begin
        s:=IfThen(v=dgvMMYYYY,'День','Месяц.год'); tf.SetReadOnly(false);
      end;
      tf.SayCaption:=padr(s,Length(tf.SayCaption));
    end;
    if v in [dgvMMYYYY,dgvDD] then begin
      s:=GetEdMaskVal(5);
      if not empty(s) then begin
        if v=dgvDD then begin
          LsArrFill(s,a,'.'); s:=NumStr(a[1],2)+StrNum('.',a[2],2);
        end
        else NumStrSelf(s,2);
        SetEdMaskVal(5,s);
      end;
    end;
  end;
{$ELSE}
	if (Sender=EdMaskFld(3)) or (Sender=EdMaskFld(4)) then begin
    v:=TDateGetVid(GetEdMaskVal(3)-1);
    if Sender=EdMaskFld(3) then begin
      tf:=EdMaskFld(4);
      if v in [dgvNormal,dgvYear4,dgvYYYY] then begin
        s:=''; tf.IncOptions([ogReadOnly,ogReadOnlyNoVsbl]);
      end
      else begin
        s:=IfThen(v=dgvMMYYYY,'День','Месяц.год'); tf.SetReadOnly(false);
      end;
      tf.SayCaption:=padr(s,Length(tf.SayCaption));
    end;
    if v in [dgvMMYYYY,dgvDD] then begin
      s:=GetEdMaskVal(4);
      if not empty(s) then begin
        if v=dgvDD then begin
          LsArrFill(s,a,'.'); s:=NumStr(a[1],2)+StrNum('.',a[2],2);
        end
        else NumStrSelf(s,2);
        SetEdMaskVal(4,s);
      end;
    end;
  end;
{$ENDIF}
  DelStack;
end;

class function TDateGet.MaskSortMode;
begin
	result:=smColumns;
end;

class function TDateGet.MaskTextReadOnly;
begin
	result:=true;
end;

class procedure TDateGet.FMaskView;
var Prm: TDateGetPrm;
begin
  AddStack('TDateGet.FMaskView');
  Prm:=MaskPrm(Mask);
  Mask:=DlmBetween([aNmVid[Prm.v],{$IFDEF PROP}IfThen(Prm.lProp,'прописью'),{$ENDIF}
    IfThen(Prm.lEnd,'пустая дата-наибольшая'),
    IfThen(Prm.DayOfWeek,'день недели'),
    IfThen(not empty(Prm.Dop),IfThen(Prm.v=dgvMMYYYY,'день','месяц.год')+':'+Prm.Dop)],',');
  DelStack;
end;

procedure TDateGet.StdDWFldInfo;
var nDig,nSep: longint;
  Prm: TDateGetPrm;
begin
	AddStack('TDateGet.StdDWFldInfo',Self);
  Prm:=MaskPrm(Mask); CntChr(Prm,nDig,nSep); FldInfo.Size:=nDig+nSep;
  FldInfo.Alignment:={$IFDEF PROP}iif(Prm.lProp,taLeftJustify,taCenter){$ELSE}taCenter{$ENDIF};
  DelStack;
end;

procedure TDateGet.StdDWFldValue;
var t: longint;
begin
	AddStack('TDateGet.StdDWFldValue',Self);
  t:=MyVarType(Value,true);
  case t of
    varDouble,varDate: dtocSelf(Value);
    varString: ;
  else Value:='';
  end;
  Value:=FSetValue(Value,Value,Mask,false);
  DelStack;
end;

procedure TDateGet.FMaskHelp;
var n: byte;
  s,s1: string;
begin
  AddStack('TDateGet.FMaskHelp',Self);
  inherited;
  n:=0; SetLength(ht.Dat,n+6);
  Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr('МАС_ВЫБОР','(',hlnkInterMemo)+'('+HelpBoldStr('«Вид ввода»')+',;');
  Inc(n); CopyFrom(ht.Dat[n],['{'+HelpBoldStr('«только месяц.год»')       ,','+HelpBoldStr('«только день»')               ,','+HelpBoldStr('«только год»')+'},;']);
  s:=HelpBoldStr('«День»'); s1:=HelpBoldStr('«Месяц.год»');
  Inc(n); CopyFrom(ht.Dat[n],['{'+HelpIf(s+'==""','""',s+'+"."',false)+'+"'+cDtMY+'"',',"'+cDtDay+'"+'+HelpIf(s1+'==""','""','"."+'+s1,false),',"'+cDtYYYY+'"},"")+;']);
  Inc(n); CopyFrom(ht.Dat[n],HelpIf('«Пустая дата как наибольшая»','"'+cDtEnd+'"','""')+'+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpIf('«День недели»','"'+cDtWeek+'"','""'));
  DelStack;
end;

{ TTimeCurGet }
constructor TTimeCurGet.Create;
begin
	AddStack('TTimeCurGet.Create',Self);
	Inherited Create(AOwner);
  RVid:='';
  DelStack;
end;

procedure TTimeCurGet.CreateObj;
begin
	AddStack('TTimeCurGet.CreateObj',Self);
  inherited CreateObj(tf);
  tf.Mask:='99:99';
  DelStack;
end;

function TTimeCurGet.Check;
var s: string;
begin
	AddStack('TTimeCurGet.Check',Self);
  s:=tf.Value;
  result := InRange(Int0(LeftStr(s,2)),0,HoursPerDay-1) and InRange(Int0(RightStr(s,2)),0,MinsPerHour-1);
  DelStack;
end;

procedure TTimeCurGet.DoEnter;
var tl: TKeyLb;
begin
	AddStack('TTimeCurGet.DoEnter',Self);
  inherited DoEnter(tf);
  if FormKeyLb(tf,tl) and not(ogReadOnly in tf.Options) then begin
  	tl.SetKey(KeyDateCur,'Тек.время','',ProcKey,'timecurget',kmEdit); tl.ReDrw;
  end;
  DelStack;
end;

procedure TTimeCurGet.DoExit;
var tl: TKeyLb;
begin
	AddStack('TTimeCurGet.DoExit',Self);
  if FormKeyLb(tf,tl) then begin
  	tl.DelKey(K_All,'timecurget'); tl.ReDrw;
  end;
  inherited DoExit(tf);
  DelStack;
end;

class procedure TTimeCurGet.ProcKey;
begin
  AddStack('TTimeCurGet.ProcKey');
  FldEditOwner(tw).VarValue:=DateToTime(Now);
  DelStack;
end;

class function TTimeCurGet.DateToTime;
var Hour,Min,Sec,MSec: Word;
begin
  AddStack('TTimeCurGet.DateToTime');
  DecodeTime(d,Hour,Min,Sec,MSec); result:=NumStr(Hour,2)+StrNum(TimeSeparator,Min,2);
  DelStack;
end;

procedure DWFldDefaultProc(const r: TDWVidRec; var ap: TDEPrmStr);
begin
  AddStack('Dateget.DWFldDefaultProc');
  if r.AType=dwtDate then TDateGet.AssignGetClass(ap);
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TDateGet]);
end;

initialization
  AddStack('Dateget.initialization');
  AddFrom(DWFldDefaultProc);
  DelStack;
end.
