unit ComboGet;

interface

{$I LIBTEST}
uses
  Windows,Messages,Classes,Forms,StdCtrls,
  MyTypes,CCodeGet,RecVal,FFldedit;

type
  TCmbGetListResult = function(Sender: TObject; lr: TListF2Result): string of object;

	TCmbGetPrm = record
  	OnlyList: boolean;
    Mask: string;
    Len: longint;
  end;

  TComboGet = class(TCustomCodeGet)
  private
    { Private declarations }
    FItems: TStringList;
    FItemHeight: longint;
    FListNmProc: TKeyLbNmProc;
    FOnListKeyProc: TKeyProc;
    FOnDrawItem: TDrawItemEvent;
    FOnListResult: TCmbGetListResult;
		function GetDuplicates: TDuplicates;
		function GetSorted: boolean;
		procedure SetDuplicates(Value: TDuplicates);
		procedure SetItems(Value: TStringList);
		procedure SetListNmProc(Value: TKeyLbNmProc);
		procedure SetSorted(Value: boolean);
  protected
    { Protected declarations }
    Prm: TCmbGetPrm;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    function Check(tf: TFldEdit): boolean; override;
    procedure DoEnter(tf: TFldEdit); override;
    function FromCalc(tf: TFldEdit; d: Double; X,Y: longint): boolean; override;
    function AssignObj(tf: TFldEdit): boolean; override;
    procedure StdListDown(tf: TFldEdit; const RectList: TRect;
	    PozList: TPozList); override;
		function GetDefLenName(const Mask: string): longint; override;
		procedure HookProc(tf: TFldEdit; var Message: TMessage); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
  public
    { Public declarations }
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
		procedure MaskPrn(const Mask: string; LsPrn: TStringList); override;
		class function CmbPrm(const ms: string): TCmbGetPrm;
  published
    { Published declarations }
    property Duplicates: TDuplicates read GetDuplicates write SetDuplicates;
    property ItemHeight: longint read FItemHeight write FItemHeight;
    property Items: TStringList read FItems write SetItems;
    property ListNmProc: TKeyLbNmProc read FListNmProc write SetListNmProc;
    property Sorted: boolean read GetSorted write SetSorted;
    property OnDrawItem: TDrawItemEvent read FOnDrawItem write FOnDrawItem;
    property OnListKeyProc: TKeyProc read FOnListKeyProc write FOnListKeyProc;
    property OnListResult: TCmbGetListResult read FOnListResult write FOnListResult;
    { Унаследованные }
    property LenName;
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

procedure Register;

implementation

uses SysUtils,Variants,StrUtils,
  My_pr,ListF2,KeyLb;

const MaskFieldSeparator = ';';

constructor TComboGet.Create;
begin
	AddStack('TComboGet.Create',Self);
	Inherited Create(AOwner);
  FItems:=TStringList.Create; FListNmProc:=TKeyLbNmProc.Create; UpdateAllFld(mgCreate);
  DelStack;
end;

destructor TComboGet.Destroy;
begin
	AddStack('TComboGet.Destroy',Self);
	FItems.Free; FListNmProc.Free;
	inherited Destroy;
  DelStack;
end;

function TComboGet.GetDuplicates;
begin
	AddStack('TComboGet.GetDuplicates',Self);
	result:=FItems.Duplicates;
  DelStack;
end;

procedure TComboGet.SetDuplicates;
begin
	AddStack('TComboGet.SetDuplicates',Self);
	FItems.Duplicates:=Value;
  DelStack;
end;

function TComboGet.GetSorted;
begin
	AddStack('TComboGet.GetSorted',Self);
	result:=FItems.Sorted;
  DelStack;
end;

procedure TComboGet.SetListNmProc;
begin
	AddStack('TComboGet.SetListNmProc',Self);
	ListNmProc.Assign(Value);
  DelStack;
end;

procedure TComboGet.SetSorted;
begin
	AddStack('TComboGet.SetSorted',Self);
	FItems.Sorted:=Value;
  DelStack;
end;

procedure TComboGet.SetItems;
begin
	AddStack('TComboGet.SetItems',Self);
	FItems.Assign(Value);
  DelStack;
end;

procedure TComboGet.CreateObj;
begin
	AddStack('TComboGet.CreateObj',Self);
  inherited CreateObj(tf);
  SetDefLenName; eN.MaxLength:=FDefLenName;
  DelStack;
end;

procedure TComboGet.ReCreateObj;
var oldv: string;
begin
	AddStack('TComboGet.ReCreateObj',Self);
	if AssignObj(tf) then begin
    LenCode:=0;
    with tf do begin
      eN.AutoSelect := ogAutoSelect in Options;
      if eN.EditMask<>Prm.Mask then begin
        oldv:=Value; eN.EditMask:=Prm.Mask;
        if not Empty(eN.EditMask)
        and (Pos(MaskFieldSeparator,eN.EditMask)=0)
        then eN.EditMask:=eN.EditMask+MaskFieldSeparator+'1'+MaskFieldSeparator+' ';
        Value:=oldv;
      end;
      eN.MaxLength:=LenFld(eN.MaxLength,true,Prm.Mask);
      eN.ReadOnly := Prm.OnlyList or (ogReadOnly in Options) or Assigned(bDyn);
      eN.TrimLeft := ogTrimLeft in Options;
    end;
    eC.ReadOnly:=true; eC.Visible:=false;
    inherited ReCreateObj(tf);
  end;
  DelStack;
end;

{ Достать значение Value из объектов }
function TComboGet.GetValue;
begin
	AddStack('TComboGet.GetValue',Self);
	AssignObj(tf); result:=IfThenGetText(eN);
  DelStack;
end;

{ Установить свойства объектов в соответствии с Value }
procedure TComboGet.SetValue;
begin
	AddStack('TComboGet.SetValue',Self);
	if AssignObj(tf) then begin
    eN.Text:=TrimRight(v); eN.SelAll;
  end;
  DelStack;
end;

function TComboGet.Check;
var s: string;
  i: longint;
begin
  AddStack('TComboGet.Check',Self);
  result := not(AssignObj(tf) and Prm.OnlyList);
  if not result then begin
    s:=TrimRight(tf.Value);
    for i:=0 to FItems.Count-1 do
      if TrimRight(FItems[i])=s then begin
        result:=true; break;
      end;
  end;
  DelStack;
end;

procedure TComboGet.DoEnter;
var tl: TKeyLb;
begin
	AddStack('TComboGet.DoEnter',Self);
	inherited DoEnter(tf);
	if AssignObj(tf) then
  	if not Prm.OnlyList then begin
      GetParentForm(tf).ActiveControl:=eN; eN.SelAll;
    end;
  if FormKeyLb(tf,tl) then tl.ReDrw;
  DelStack;
end;

// Взять число из калькулятора
function TComboGet.FromCalc;
begin
	AddStack('TComboGet.FromCalc',Self);
	tf.Value:=FloatToStr(d); result:=true;
  DelStack;
end;

{ Вызов выпадающего списка }
procedure TComboGet.StdListDown;
var lr: TListF2Result;
  i,p1,p2: longint;
  s,s1: string;
begin
	AddStack('TComboGet.StdListDown',Self);
  if AssignObj(tf) then begin
    lr:=TListF2Result.Create;
    try
      s:=AnsiUpperCase(tf.Value);
      p1:=-1; p2:=-1;
      for i:=0 to FItems.Count-1 do begin
        s1:=AnsiUpperCase(FItems[i]);
        if s1=s then begin
          p1:=i; break;
        end;
        if p2<0 then
          if AnsiStartsStr(s,s1) then p2:=i;
      end;
      if p1>=0 then lr.SelectStr:=p1
      else if p2>=0 then lr.SelectStr:=p2;
      if ListF2Down(FItems.Text,lr,eN,RectList.Right-RectList.Left,
      tf.Schem,FListNmProc.Text,FOnListKeyProc,FItemHeight,FOnDrawItem,
      nil,nil,nil,OnRowMove) then
      	if lr.SelectStr<0 then tf.Value:=''
        else if Assigned(FOnListResult) then tf.Value:=FOnListResult(Self,lr)
        else tf.Value:=FItems[lr.SelectStr];
    finally
	    lr.Free;
    end;
  end;
  DelStack;
end;

function TComboGet.AssignObj;
begin
	AddStack('TComboGet.AssignObj',Self);
	Prm.Mask:=''; Prm.OnlyList:=false; Prm.Len:=0;
	result := inherited AssignObj(tf);
  if result then Prm:=CmbPrm(tf.Mask);
  DelStack;
end;

function TComboGet.GetDefLenName;
begin
	AddStack('TComboGet.GetDefLenName',Self);
	result := inherited GetDefLenName(Mask);
	Prm:=CmbPrm(Mask);
  if Prm.Len>0 then result:=Prm.Len;
  DelStack;
end;

function TComboGet.MaskTrans;
var Prm: TCmbGetPrm;
begin
	AddStack('TComboGet.MaskTrans');
	if MyVarType(av)=varArray then result:=StrNum(IfThen(IsNilc(av[1],false),cOnlyList)
    +TrimRight(IsNilc(av[2],''))+UnDelim,IsNilc(av[3],0))
  else begin
  	Prm:=CmbPrm(av);
    result:=ArrVarToVar(
      [VarArrayOf([mpBool,'Только выбор из списка',Prm.OnlyList])
      ,VarArrayOf([mpEdit,'Маска ввода',Prm.Mask])
      ,VarArrayOf([mpSpin,'Длина',Prm.Len,0,MaxInt])
      ]);
  end;
  DelStack;
end;

procedure TComboGet.MaskPrn;
var Prm: TCmbGetPrm;
begin
	AddStack('TComboGet.MaskPrn',Self);
  Prm:=CmbPrm(Mask);
  if Prm.Len<>0 then LsPrn.Add(StrNum('Длина: ',Prm.Len));
  if Prm.OnlyList then LsPrn.Add('Только выбор из списка');
  if not empty(Prm.Mask) then LsPrn.Add('Маска ввода: '+Prm.Mask);
  DelStack;
end;

procedure TComboGet.FMaskHelp;
var n: byte;
begin
  AddStack('TComboGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+5);
  Inc(n); CopyFrom(ht.Dat[n],HelpStruct(['ИзСписИМаска','Длина']));
  Inc(n); CopyFrom(ht.Dat[n],HelpIf('«Только выбор из списка»','"'+cOnlyList+'"','""')+'+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr('«Маска ввода»')+'+"'+UnDelim+'"+;');
  Inc(n); CopyFrom(ht.Dat[n],HelpNum('«Длина»'));
  DelStack;
end;

procedure TComboGet.HookProc;
begin
	AddStack('TComboGet.HookProc',Self);
  inherited HookProc(tf,Message);
  if Message.Msg=WM_FLD then
    if TWMFld(Message).Oper in [foOpenRec,foCloseRec] then tf.RecreateObj;
  DelStack;
end;

procedure TComboGet.Assign;
begin
	AddStack('TComboGet.Assign',Self);
  if Source is TComboGet
  then FItems.Assign(TComboGet(Source).FItems);
	inherited Assign(Source);
  DelStack;
end;

class function TComboGet.CmbPrm;
var a: array[1..2] of string;
begin
	AddStack('TComboGet.CmbPrm');
	result.OnlyList := Pos(cOnlyList,AnsiUpperCase(ms))>0;
  LsArrFill(StrTran(ms,cOnlyList,'',[rfIgnoreCase]),a,UnDelim);
	result.Mask:=a[1]; result.Len:=Int0(a[2]);
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TComboGet]);
end;

end.
