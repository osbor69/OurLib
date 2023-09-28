unit PswdGet;

interface

uses Messages,Classes,Controls,
  MyTypes,FFldEdit,MultiGet,RecVal,PaintCtl;

type
  TPswdGetPrm = record
    RW: TBoolSet;
    NoChkOld,NoChk,CanEmp: boolean;
    aSay: TPswdGetStr;
  end;

  TPswdGet = class(TMultiGet)
  private
    procedure SetProp(i: TPswdGetList; const Prm: TPswdGetPrm);
    function GetVisible(tf: TFldEdit): boolean;
    procedure SetVisible(tf: TFldEdit; Value: boolean);
    procedure SetKeyVisible(tf: TFldEdit);
   	procedure ProcKey(Key: longint; tw: TWinControl);
    procedure VisibleClick(Sender: TObject);
  protected
    sV: TPaintButton;
    Rec: TRecVal;
    atf: array[TPswdGetList] of TFldEdit;
		procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    function GetValue(tf: TFldEdit): string; override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
		procedure ReadFirst(tf: TFldEdit); override;
    function Check(tf: TFldEdit): boolean; override;
    function AssignObj(tf: TFldEdit): boolean; override;
		function SortMode(tf: TFldEdit): TSortMode; override;
    procedure MaskFrmShow(Sender: TObject); override;
    class procedure MaskEdChange(Sender: TObject; const OldVal: variant; FromShow: boolean); override;
  	class function MaskSortMode: TSortMode; override;
    class procedure FMaskView(var Mask: string); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
    procedure PlaceControls(tf: TFldEdit; Condens: boolean); override;
		procedure HookProc(tf: TFldEdit; var Message: TMessage); override;
    property Visible[tf: TFldEdit]: boolean read GetVisible write SetVisible;
  public
		constructor Create(AOwner: TComponent); override;
    procedure SetValueIndex(tf: TFldEdit; i: TPswdGetList; const v: string);
    class function MaskTextReadOnly: boolean; override;
    class function GetFld(tf: TFldEdit; i: TPswdGetList): TFldEdit;
  published
		function MaskEdProc(const Capt: TCaption; var Mask: string;
    	r: TCustomRec; const nmf: string; lSearch: boolean): variant; override;
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
    class function Mask2Prm(const Mask: string): TPswdGetPrm;
    class function Prm2Mask(const Prm: TPswdGetPrm): string;
  end;

procedure Register;

implementation

uses Windows,SysUtils,Forms,DB,StrUtils,Variants,Math,
  My_pr,PnlEdit,FPanel,KeyLb,FldMask;

const
  aSayDef: array[boolean,boolean] of TPswdGetStr =
    ((('','','')
{W}  ,(''             ,'Пароль'      ,'Подтверждение'))
{R} ,(('Пароль'       ,''            ,'')
{RW} ,('Старый пароль','Новый пароль','Подтверждение'))
    );
  aRW: TArrBoolStr = ('чтение','запись');

  dlmSay = '^';
  dlmCRLF = '`';

function S2RW(const srw: string): TBoolSet;
begin
  AddStack('PswdGet.S2RW');
  if srw='' then result:=[false] else GetByte(srw,result);
  DelStack;
end;

function RW2S(RW: TBoolSet): string;
begin
  result:=SetByteSet(RW);
end;

{ TPswdGet }
constructor TPswdGet.Create;
begin
	AddStack('TPswdGet.Create',Self);
	Inherited Create(AOwner);
  RVid:=''{'Ввод пароля'};
  DelStack;
end;

procedure TPswdGet.CreateObj;
var i: TPswdGetList;
  g: TCustomGet;
  Prm: TPswdGetPrm;
begin
  AddStack('TPswdGet.CreateObj',Self);
  DestroyObj(tf);
  sV:=TPaintButton.Create(tf);
  with sV do begin
    Canvas:=tf.Canvas; ShowHint:=true; onClick:=VisibleClick;
  end;
  Rec:=TRecVal.Create(tf); g:=TSimpleGet.CreateOne; Prm:=Mask2Prm(tf.Mask);
  for i:=low(atf) to high(atf) do begin
    atf[i]:=TFldEdit.Create(tf);
    with atf[i] do begin
      Parent:=tf; AssignGet(g); NameRec:=Rec.NameRec; NameRecFld:=Int2Str(i); SetProp(i,Prm);
    end;
  end;
  Visible[tf]:=false; tf.Relation:=frMain; tf.ReCreateObj;
  DelStack;
end;

procedure TPswdGet.ReCreateObj;
var Prm: TPswdGetPrm;
  i: TPswdGetList;
  ov,cv,cs: boolean;
  os,nmf: string;
  tw: TWinControl;
  Opt: TGetOptions;
  f: TFld;
  l: longint;
begin
	AddStack('TPswdGet.ReCreateObj',Self);
  if AssignObj(tf) then begin
    Prm:=Mask2Prm(tf.Mask); Opt:=IfThen(not Visible[tf],ogPassword)+[ogTrimLeft];
    if tf.SeekFld then begin
      l:=tf.PNameRecFld.Info.Size; f:=atf[low(atf)].PNameRecFld;
      if Assigned(f) then cs := f.Info.Size<>l else cs:=true;
      if cs then for i:=low(atf) to high(atf) do with atf[i] do begin
        nmf:=Int2Str(i); os:=Rec[nmf]; Rec.CreateFld(nmf,iif(l=0,ftMemo,ftString),l,''); Rec[nmf]:=os;
        MaxLength:=tf.MaxLength; Read([ferdFromShow]);
      end;
    end;
    cv:=false; cs:=false;
    for i:=low(atf) to high(atf) do with atf[i] do begin
      Options:=tf.Options+Opt; ov:=Visible; os:=SayCaption; SetProp(i,Prm);
      if ov<>Visible then cv:=true;
      if os<>SayCaption then cs:=true;
    end;
    if cv then begin
      tw:=tf;
      while ParentSelf(tw) do
        if tw is TPanelEdit then TPanelEdit(tw).FillFldList;
    end;
    if cv or cs then MainRebuild(tf);
  end;
  inherited RecreateObj(tf);
  DelStack;
end;

procedure TPswdGet.HookProc;
begin
	AddStack('TPswdGet.HookProc',Self);
  inherited HookProc(tf,Message);
  if Message.Msg=WM_FLD then
    if TWMFld(Message).Oper in [foOpenRec,foCloseRec] then tf.RecreateObj;
  DelStack;
end;

procedure TPswdGet.SetProp;
var s: string;
begin
  AddStack('TPswdGet.SetProp',Self);
  with Prm,atf[i] do begin
    s:=aSayDef[false in RW,true in RW,i]; Visible := s<>'';
    if Visible then begin
      if aSay[i]<>'' then s:=aSay[i];
      SayCaption:=s;
    end
    else SayCaption:='';
  end;
  DelStack;
end;

function TPswdGet.GetVisible;
begin
  AddStack('TPswdGet.GetVisible',Self);
  if AssignObj(tf) then result:=not(ogPassword in atf[low(atf)].Options) else result:=false;
  DelStack;
end;

procedure TPswdGet.SetVisible;
var i: TPswdGetList;
begin
  AddStack('TPswdGet.SetVisible',Self);
  if AssignObj(tf) then begin
    sV.Hint:=IfThen(Value,'Скрыть','Показать');
    for i:=low(atf) to high(atf) do atf[i].SetReadOnly(not Value,ogPassword);
    BMByName(sV.Glyph,TBMList(iif(Value,bmPswd_Show,bmPswd_Hide))); sV.Paint;
  end;
  DelStack;
end;

procedure TPswdGet.SetKeyVisible;
var tl: TKeyLb;
begin
  AddStack('TPswdGet.SetKeyVisible',Self);
  if AssignObj(tf) then
    if FormKeyLb(tf,tl) then tl.SetKey(K_F3,sV.Hint,'',ProcKey,'pswdget',kmEdit);
  DelStack;
end;

procedure TPswdGet.ProcKey;
var tf: TFldEdit;
  tl: TKeyLb;
begin
  AddStack('TPswdGet.ProcKey',Self);
  while Assigned(tw) do begin
    if IsClass(tw,TFldEdit,pointer(tf)) then if tf.curget=Self then begin
      Visible[tf]:=not Visible[tf]; SetKeyVisible(tf);
      if FormKeyLb(tf,tl) then tl.ReDrw;
      break;
    end;
    ParentSelf(tw);
  end;
  DelStack;
end;

procedure TPswdGet.VisibleClick;
begin
  AddStack('TPswdGet.VisibleClick',Self);
  ProcKey(K_F3,pointer(TPaintButton(Sender).Owner));
  DelStack;
end;

procedure TPswdGet.DoEnter;
begin
  AddStack('TPswdGet.DoEnter',Self);
  SetKeyVisible(tf);
  inherited DoEnter(tf);
  DelStack;
end;

procedure TPswdGet.DoExit;
var tl: TKeyLb;
begin
  AddStack('TPswdGet.DoExit',Self);
  if FormKeyLb(tf,tl) then tl.DelKey(K_All,'pswdget');
  inherited DoExit(tf);
  DelStack;
end;

procedure TPswdGet.ReadFirst;
var i: TPswdGetList;
begin
  AddStack('TPswdGet.ReadFirst',Self);
  if AssignObj(tf) then begin
    for i:=low(atf) to high(atf) do atf[i].VarValue:='';
    Visible[tf]:=false;
  end;
  DelStack;
end;

function TPswdGet.GetValue;
begin
  AddStack('TPswdGet.GetValue',Self);
  if Assigned(tf.PNameRecFld) then result:=tf.PNameRecFld.Value else result:='';
  DelStack;
end;

function TPswdGet.Check;
const MinLenPsw = 6;
var i: TPswdGetList;
  v: string;
  tfv: TFldEdit;
  Prm: TPswdGetPrm;
begin
  AddStack('TPswdGet.Check',Self);
  result:=true;
  if Assigned(tf.PNameRecFld) then if AssignObj(tf) then begin
    Prm:=Mask2Prm(tf.Mask);
    for i:=low(atf) to high(atf) do with atf[i] do if Visible then begin
      case i of
        pswdRead: if atf[pswdWrite].Visible then if not Prm.NoChkOld then
          if TrimRight(VarValue)<>TrimRight(tf.PNameRecFld.Value) then result:=false;
        pswdWrite: if not Prm.NoChk then begin
          v:=TrimRight(VarValue);
          result := (Prm.CanEmp and (v='')) or (Length(v)>=MinLenPsw);
          if not result then meserr(Format('Длина пароля должна быть не менее %d символов.',[MinLenPsw]));
        end;
        pswdRepl: if TrimRight(VarValue)<>TrimRight(atf[pswdWrite].VarValue) then result:=false;
      end;
      if not result then begin
        TPanelEdit.ParentPnEd(tf).FldFocus:=atf[i]; break;
      end;
    end;
    if result then begin
      tfv:=atf[pswdWrite];
      if not tfv.Visible then tfv:=atf[pswdRead];
      tf.PNameRecFld.Value:=tfv.Value;
    end;
  end;
  DelStack;
end;

function TPswdGet.AssignObj;
var n,l: longint;
  res: boolean;
  function NoClass(ToClass: TClass; var Dest: pointer): boolean;
  begin
  	AddStack('TPswdGet.AssignObj.IsClass',Self);
    while n<l do begin
      if tf.Components[n] is TPaintSay then if Assigned(TPaintSay(tf.Components[n]).FocusControl) then begin
        Inc(n); continue;
      end;
      break;
    end;
    if n=l then result:=true else result:=not IsClass(tf.Components[n],ToClass,Dest);
    if result then res:=false else Inc(n);
    DelStack;
  end;
var i: TPswdGetList;
label lend;
begin
	AddStack('TPswdGet.AssignObj',Self);
  sV:=nil; Rec:=nil; ZeroMemory(@atf,SizeOf(atf)); res:=inherited AssignObj(tf);
  if res then begin
    n:=0; l:=tf.ComponentCount;
    if NoClass(TPaintButton,pointer(sV)) then goto lend;
    if NoClass(TRecVal,pointer(Rec)) then goto lend;
    for i:=low(atf) to high(atf) do if NoClass(TFldEdit,pointer(atf[i])) then goto lend;
lend:
  end;
  result:=res;
  DelStack;
end;

procedure TPswdGet.PlaceControls;
const ib=8;
var i: TPswdGetList;
  ws,we,l,t,h,hm,cnt,wb,hb: longint;
  ah: array[TPswdGetList] of longint;
begin
  AddStack('TPswdGet.PlaceControls',Self);
  if AssignObj(tf) then begin
    ws:=0; we:=0; cnt:=-1; hb:=0; ZeroMemory(@ah,SizeOf(ah));
    for i:=low(atf) to high(atf) do with atf[i] do if Visible then begin
      Inc(cnt); MaxSelf(we,Width); ah[i]:=Height;
      if Assigned(PaintSay) then with PaintSay do begin
        MaxSelf(ws,Width); MaxSelf(ah[i],Height);
      end;
      hb:=ah[i];
    end;
    wb:=sV.Glyph.Width+8; hm:=SumInt(ah); h:=max(hm,hb);
    l:=max(0,(tf.Width-ws-we-wb) div 2);
    t:=max(0,(tf.Height-h) div 2);
    sV.SetBounds(l+ws+we,t+(h-hb) div 2,wb,hb);
    if h>hm then Inc(t,(h-hm) div 2);
    if cnt=0 then h:=0 else h:=(h-hm) div cnt;
    for i:=low(atf) to high(atf) do with atf[i] do if Visible then begin
      if Assigned(PaintSay) then with PaintSay do SetBounds(l,t,Width,Height);
      SetBounds(l+ws,t,Width,Height); Inc(t,ah[i]+h);
    end;
  end;
  DelStack;
end;

function TPswdGet.SortMode;
begin
  result:=smColumns;
end;

function TPswdGet.MaskEdProc;
begin
	result:=null;
end;

function TPswdGet.MaskTrans;
var i: TPswdGetList;
  Prm: TPswdGetPrm;
begin
	AddStack('TPswdGet.MaskTrans',Self);
	if MyVarType(av)=varArray then with Prm do begin
    Finalize(Prm); ZeroMemory(@Prm,SizeOf(Prm));
    RW:=S2RW(IsNilc(av[1],'')); NoChkOld:=IsNilc(av[2],false);
    NoChk:=IsNilc(av[3],false); CanEmp:=IsNilc(av[4],false);
    for i:=low(aSay) to high(aSay) do aSay[i]:=IsNilc(av[6+byte(i)],'');
    result:=Prm2Mask(Prm);
  end
  else with Mask2Prm(av) do begin
    result:=VarArrayCreate([1,5+Length(aSay)],varVariant);
    result[1]:=RW2S(RW);
    result[2]:=NoChkOld;
    result[3]:=NoChk;
    result[4]:=CanEmp;
    result[5]:=ArrayAsList(aRW,mniDlm);
    for i:=low(aSay) to high(aSay) do result[6+byte(i)]:=aSay[i];
  end;
  DelStack;
end;

procedure TPswdGet.MaskFrmShow;
var i: TPswdGetList;
begin
  AddStack('TPswdGet.MaskFrmShow',Self);
  EdMaskFld(2).IncOptions([ogReadOnlyNoVsbl]);
  EdMaskFld(3).IncOptions([ogReadOnlyNoVsbl]);
  EdMaskFld(4).IncOptions([ogReadOnlyNoVsbl]);
  for i:=low(TPswdGetList) to high(TPswdGetList) do with EdMaskFld(6+byte(i)) do begin
    CharWidth:=wallNoSay; IncOptions([ogReadOnlyNoVsbl]);
  end;
  DelStack;
end;

class procedure TPswdGet.MaskEdChange;
var tf,tfRW: TFldEdit;
  RW: TBoolSet;
  i: TPswdGetList;
  os: string;
  fl: boolean;
begin
  AddStack('TPswdGet.MaskEdChange');
  tf:=pointer(Sender); tfRW:=EdMaskFld(1); fl := tf=tfRW;
  if fl or (tf=EdMaskFld(3)) then begin
    RW:=S2RW(tfRW.Value);
    EdMaskFld(4).SetReadOnly(not(true in RW) or GetEdMaskVal(3));
    if fl then begin
      EdMaskFld(2).SetReadOnly(not((false in RW) and (true in RW)));
      EdMaskFld(3).SetReadOnly(not(true in RW));
      fl:=false;
      for i:=low(TPswdGetList) to high(TPswdGetList) do with EdMaskFld(6+byte(i)) do begin
        os:=SayCaption; SayCaption:=aSayDef[false in RW,true in RW,i]; SetReadOnly(SayCaption='');
        if SayCaption<>os then fl:=true;
      end;
      if fl then MainRebuild(tf);
    end;
  end;
  DelStack;
end;

class function TPswdGet.MaskSortMode;
begin
  result:=smColumns;
end;

class procedure TPswdGet.FMaskView;
var fl: boolean;
  i: TPswdGetList;
  s: string;
begin
	AddStack('TPswdGet.FMaskView');
  with Mask2Prm(Mask) do begin
    Mask:='';
    for fl:=false to true do if fl in RW then IncD(Mask,aRW[fl]+'/');
    DecLen(Mask);
    if true in RW then begin
      if false in RW then if NoChkOld then IncD(Mask,',не пров.стар.');
      if NoChk then IncD(Mask,',любое')
      else if CanEmp then IncD(Mask,',пусто');
    end;
    for i:=low(aSay) to high(aSay) do if aSay[i]<>'' then begin
      s:=aSayDef[false in RW,true in RW,i];
      if s<>'' then IncD(Mask,',"'+s+'"->"'+StrTran(aSay[i],UnDelim,' ')+'"');
    end;
  end;
  DelStack;
end;

procedure TPswdGet.FMaskHelp;
const aSayCapt: TPswdGetStr = ('Чтение','Запись','Подтверждение');
var n: byte;
  s: string;
  fl: boolean;
  i: TPswdGetList;
begin
  AddStack('TPswdGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat);
  s:='""';
  for fl:=false to true do
    s:=HelpBoldStr('ОТМ_ПОЗИЦИЯ','(',hlnkInterMemo)+'('+s+Format(',%d,',[byte(fl)+1])
      +HelpBoldStr('<'+aRW[fl]+'>')+')';
  CopyFrom(ht.Dat[n],s+'+"'+UnDelim+'"+;');
  SetLength(ht.Dat,n+3);
  Inc(n); CopyFrom(ht.Dat[n],HelpBool('<Допустимо пустое значение>')+'+'+HelpBool('<Не проверять старый пароль>')+'+'+HelpBool('<Допустимо любое значение>')+'+"'+UnDelim+'"+;');
  s:='';
  for i:=low(aSayCapt) to high(aSayCapt) do
    IncD(s,HelpArrayAsList('<Подск'+aSayCapt[i]+'>','"'+dlmCRLF+'"')+IfThen(i<high(aSayCapt),'+"'+dlmSay+'"+'));
  Inc(n); CopyFrom(ht.Dat[n],s);
  DelStack;
end;

class function TPswdGet.MaskTextReadOnly;
begin
	result:=true;
end;

class function TPswdGet.Mask2Prm;
var a: array[1..3] of string;
  i: TPswdGetList;
begin
  AddStack('TPswdGet.Mask2Prm');
  with result do begin
    LsArrFill(Mask,a,UnDelim); RW:=S2RW(a[1]); PadrSelf(a[2],3);
    CanEmp:=StrToBoolean(a[2][1]);
    NoChkOld:=StrToBoolean(a[2][2]);
    NoChk:=StrToBoolean(a[2][3]);
    LsArrFill(a[3],aSay,dlmSay);
    for i:=low(aSay) to high(aSay) do StrTranSelf(aSay[i],dlmCRLF,UnDelim);
  end;
  DelStack;
end;

class function TPswdGet.Prm2Mask;
var i: TPswdGetList;
begin
  AddStack('TPswdGet.Prm2Mask');
  with Prm do begin
    result:='';
    for i:=low(TPswdGetList) to high(TPswdGetList) do IncD(result,dlmSay+StrTran(aSay[i],UnDelim,dlmCRLF));
    result:=ArrayAsList([RW2S(RW),bStr[CanEmp]+bStr[NoChkOld]+bStr[NoChk],Copy(result,2,MaxInt)],UnDelim);
  end;
  DelStack;
end;

procedure TPswdGet.SetValueIndex;
begin
  AddStack('TPswdGet.SetValueIndex',Self);
  if AssignObj(tf) then atf[i].VarValue:=v;
  DelStack;
end;

class function TPswdGet.GetFld;
begin
  AddStack('TPswdGet.GetFld');
  with TPswdGet(tf.curget) do begin
    AssignObj(tf); result:=atf[i];
  end;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TPswdGet]);
end;

end.
