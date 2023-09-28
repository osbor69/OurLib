unit FFind;

interface

{$I LIBTEST}

uses
  Windows, Messages, Classes, Controls, ExtCtrls,
  MyTypes, FRMEMPTY, Keylb, Fpanel, RecVal, FFldedit, PnlEdit, PaintCtl, FStat;

type
  TFind = class(TFormEmp)
    PnMsg: TRbStatus;
    Pe: TPanelEdit;
    ES: TFldEdit;
    RV: TRecVal;
    pn1: TRbPanel;
    ERegistr: TFldEdit;
    EWord: TFldEdit;
    EDirection: TFldEdit;
    EReplace: TFldEdit;
    ER: TFldEdit;
    function ESCheck(Sender: TObject): Boolean;
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    procedure FormCreate(Sender: TObject);
    function PeValid(Sender: TObject): Boolean;
    procedure PeCngKey(Sender: TObject; var tb: TKeyBut);
    procedure EReplaceChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
  private
    { Private declarations }
    gg: TStatGauge;
   	tCont: TControl;
    sprf: TPrFind;
    mSecBeg: longword;
    isModal,Aborted,FPropVisible: boolean;
    Options: TFindOptions;
    function EvalFind: boolean;
    procedure SetPropVisible(Value: boolean);
    procedure SetKeys;
    class function ESGetListOwner(Sender: TObject; SpdBut: TPaintButton;
      const RectList: TRect; PozList: TPozList): Boolean;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  protected
    procedure AfterCreate; override;
  public
    { Public declarations }
    class procedure Init;
    class function LastViewForm: TFind;
  end;

var FindGetRVid: string;

implementation

uses SysUtils,Forms,StrUtils,Math,Variants,
  My_pr,Inter,ComboGet;

{$R *.DFM}

type TFindDirectionStr = array[TFindDirection] of string;

const aDirection: TFindDirectionStr = ('Вперед','Назад','Все');

var ESGet,ERGet: TComboGet;
  aForm: array of TFind;
  nForm: longint = -1;
  SvS: string;
  SvProperty: TFindProperty;

function FWinFind(Sender: TControl; prf: TPrFind; isMod: boolean; opt: TFindOptions; const Capt: string): boolean;
  procedure tfSet(tf: TFldEdit; const nmf: string; vsb: TFindOption; const v: variant);
  begin
  	AddStack('FFind.FWinFind');
    tf.NameRecFld:=nmf; tf.Visible := vsb in opt; tf.VarValue:=v;
    DelStack;
  end;
var w,h,w1,h1: longint;
  pt: TPoint;
begin
	AddStack('FFind.FWinFind');
  with aForm[nForm] do begin
    isModal:=isMod;
    if isMod then begin
      if not CanPriv(PrivDesign) then Exclude(opt,fnoReplace);
      Caption:=IfThen(Capt='','Поиск',Capt); Options:=opt;
      sprf:=prf; tCont:=Sender; ES.SetReadOnly(not isMod);
      if not Assigned(ActiveControl) then ActiveControl:=ES;
      RV['S']:=SvS; ES.NameRecFld:='S';
      if not(fnoSave in opt) then begin
        Finalize(SvProperty); ZeroMemory(@SvProperty,SizeOf(SvProperty));
      end;
      EDirection.Mask:=RadioMask(aDirection,0,Length(aDirection)-IfThen(not(fnoAll in opt),1));
      tfSet(ERegistr,'Registr',fnoRegistr,SvProperty.Registr);
      tfSet(EWord,'Word',fnoWord,SvProperty.Word);
      tfSet(EDirection,'Direction',fnoDirection,SvProperty.Direction);
      tfSet(EReplace,'Replace',fnoReplace,SvProperty.Replace);
      tfSet(ER,'R',fnoReplace,SvProperty.sr);
      BoundsRect:=SysWorkArea; w:=Width; h:=Height;
      if Assigned(Sender) then begin
        w1:=Sender.Width; pt:=Sender.ClientOrigin; MaxSelf(pt.X); MaxSelf(pt.Y);
        MinSelf(w,w1); MinSelf(h,Sender.Height);
      end
      else begin
        w1:=w; pt:=BoundsRect.TopLeft;
      end;
      w1:=MaxIntValue([w1,MinWidthForm(aForm[nForm]),max(KeyLb1.WMin,Pe.WMin+RbPanel2.BevPanel2)
        +RbPanel1.BevPanel2+Width-ClientWidth]);
      h1:=Pe.HMin+PnMsg.Height+RbPanel2.BevPanel2+KeyLb1.Height+RbPanel1.BevPanel2+Height-ClientHeight;
      SetBounds(max(Left,pt.X+nround((w-w1)/2)),
        max(Top,IfThen(pt.Y+h+h1>BoundsRect.Bottom,pt.Y-h1,pt.Y+h)),w1,h1);
      FormOnScreen;
      Pe.FillFldList; Pe.FldReadAll([ferdSvOld]); ES.SetActiveControl; PnMsg.Caption:=''; gg.Hide;
      SetPropVisible(false); result := ShowModal=mrOk;
    end
    else begin
      PnMsg.Caption:=' Поиск';
      KeyLb1.SetButNoEval(true);
      KeyLb1.SetKey(K_Esc,'Отмена','',KeyLb1ProcKey,'findesc',kmNone);
      KeyLb1.ReDrw;
      BeforeShow; Show; Refresh; result:=true;
    end;
  end;
  DelStack;
end;

// Поиск
function WinFind(Sender: TControl; prf: TPrFind; opt: TFindOptions = []; const Capt: string = ''): boolean;
var i: longint;
begin
	AddStack('FFind.WinFind');
  TFind.Init; Inc(nForm);
  if Length(aForm)=nForm then begin
    SetLength(aForm,nForm+1); aForm[nForm]:=nil;
  end;
  if CreateForm(TFind,aForm[nForm]) then with aForm[nForm] do begin
    RV.NameRec:=StrNum('Find',nForm); Pe.FillFldList;
    for i:=0 to Pe.FieldCount-1 do Pe.Fields[i].NameRec:=RV.NameRec;
  end;
  try
    if (Length(aForm)=0) or empty(SvS) then Exclude(opt,fnoContinue);
    if fnoContinue in opt then with aForm[nForm] do begin
      tCont:=Sender; sprf:=prf; isModal:=false; Aborted:=false; result:=EvalFind;
      if Visible then begin
        AfterShow; Hide;
        KeyLb1.DelKey(K_All,'findesc');
        KeyLb1.SetButNoEval(false); KeyLb1.ReDrw;
      end;
      if not(result or Aborted) then mess_ok(['Строка "'+SvS+'" не найдена.']);
    end
  	else result:=FWinFind(Sender,prf,true,opt,Capt);
  finally
    aForm[nForm].NoLimit:=false; Dec(nForm);
  end;
  DelStack;
end;

function WinFindKey(Key: longint; Sender: TControl; prf: TPrFind; opt: TFindOptions = []; const Capt: string = ''): boolean;
begin
  AddStack('FFind.WinFindKey');
  if (Key=K_Shift_F6) or ArrIntMatch(key,aKeyFind)
  then result:=WinFind(Sender,prf,opt+IfThen(Key=K_Shift_F6,[fnoContinue]),Capt)
  else result:=false;
  DelStack;
end;

function c_prm(const cSvS,cRegistr,cWord,cDirection: variant): variant; overload;
  function SetPrm(var res: variant; n: byte; const ov,nv: variant): variant;
  begin
  	AddStack('FFind.c_prm.SetPrm');
    res[n]:=ov; result:=IsNilc(nv,ov);
    DelStack;
  end;
begin
	AddStack('FFind.c_prm');
  result:=VarArrayCreate([1,4],varVariant);
  SvS:=SetPrm(result,1,SvS,cSvS);
  if not IsNil(cSvS) and Assigned(ESGet) then AddSzStrings(ESGet.Items,SvS);
  with SvProperty do begin
    Registr:=SetPrm(result,2,Registr,cRegistr);
    Word:=SetPrm(result,3,Word,cWord);
    Direction:=SetPrm(result,4,Direction,cDirection);
  end;
  DelStack;
end;

function c_prm(var av: array of variant): variant; overload;
begin
  result:=c_prm(av[1],av[2],av[3],av[4]);
end;

{function d_FindStr(const v,ind: variant; lSave: boolean): variant;
begin
	AddStack('FFind.d_FindStr');
  if Assigned(ESGet) then begin
    result:=SvS;
    if lSave then begin
      SvS:=v; AddSzStrings(ESGet.Items,v);
    end;
  end
  else result:='';
  DelStack;
end;

{ TFind }
class procedure TFind.Init;
  function gCrt(const vn: string): TComboGet;
  begin
    AddStack('TFind.Init.gCrt');
    result:=TComboGet.Create(Application.MainForm);
    with result do begin
      VName:=vn; OnListOwner:=ESGetListOwner;
    end;
    DelStack;
  end;
begin
  AddStack('TFind.Init');
  if not Assigned(ESGet) then begin
    ESGet:=gCrt('Find'); ERGet:=gCrt('FindR');
  end;
  DelStack;
end;

procedure TFind.FormCreate(Sender: TObject);
begin
	AddStack('TFind.FormCreate',Self);
  gg:=TStatGauge.Create(Self); gg.Parent:=pnMsg;
  inherited;
  ESGet.RVid:=FindGetRVid;
  DelStack;
end;

class function TFind.ESGetListOwner;
begin
	AddStack('TFind.ESGetListOwner');
	result := TComboGet(TFldEdit(Sender).curget).Items.Count=0;
  DelStack;
end;

procedure TFind.EReplaceChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
var Replace: boolean;
  Opt: TGetOptions;
begin
  AddStack('TFind.EReplaceChange',Self);
  Replace:=RV['REPLACE']; Opt:=ER.Options;
  if FPropVisible then begin
    SetSet(Opt,ogReadOnly,not Replace); Include(Opt,ogReadOnlyNoVsbl);
  end
  else begin
    Include(Opt,ogReadOnly); SetSet(Opt,ogReadOnlyNoVsbl,not Replace);
  end;
  ER.Options:=Opt;
  DelStack;
end;

function TFind.ESCheck(Sender: TObject): Boolean;
var s: string;
begin
	AddStack('TFind.ESCheck',Self);
  inherited;
  s:=Trim(RV['S']); SvS:=s; result:=s<>'';
  if not result then PnMsg.Caption:=' Введите строку для поиска';
  DelStack;
end;

procedure TFind.PeCngKey(Sender: TObject; var tb: TKeyBut);
begin
	AddStack('TFind.PeCngKey',Self);
  with tb do if Key=K_F10 then Caption:='Поиск';
  DelStack;
end;

function TFind.PeValid(Sender: TObject): Boolean;
begin
  AddStack('TFind.PeValid',Self);
  PnMsg.Caption:=' Поиск'; PnMsg.Repaint; SvProperty:=FindProperty;
  if fnoReplace in Options then with SvProperty do begin
    Replace:=RV['Replace']; sr:=RV['R']; AddSzStrings(ERGet.Items,sr);
  end;
  c_prm(Trim(RV['S'])
    ,iif(fnoRegistr   in Options,RV['Registr'  ],null)
    ,iif(fnoWord      in Options,RV['Word'     ],null)
    ,iif(fnoDirection in Options,RV['Direction'],null)
    );
  with KeyLb1 do begin
    SetButNoEval(true);
    SetKey(K_Esc,'Отмена','',KeyLb1ProcKey,'findesc',kmNone);
    ReDrw; Repaint;
    result:=EvalFind;
    gg.Hide;
    DelKey(K_All,'findesc'); SetButNoEval(false);
    ReDrw;
  end;
  if not result then PnMsg.Caption:=' Строка не найдена';
  DelStack;
end;

function TFind.EvalFind;
var oProperty: TFindProperty;
  sf: string;
begin
  AddStack('TFind.EvalFind',Self);
  oProperty:=FindProperty;
  try
    FindProperty:=SvProperty; sf:=FindRegistrStr(SvS); mSecBeg:=My_pr.GetTickCount; result:=sprf(tCont,sf);
  finally
    FindProperty:=oProperty;
  end;
  DelStack;
end;

procedure PrVisible(Sender: TFldEdit; const av: array of variant);
begin
  AddStack('FFind.PrVisible');
  BoolVar(av[0])^:=true;
  DelStack;
end;

procedure TFind.SetKeys;
  procedure SetKey(Key: longint; const txt,hnt: array of string; tf: TFldEdit; n: byte = 0);
  var lVsb,lBool: boolean;
    v: variant;
  begin
    AddStack('TFind.SetKeys.SetKey',Self);
    if Assigned(tf) then begin
      lVsb:=tf.Visible; v:=tf.VarValue; lBool := MyVarType(v)=varBoolean; n:=IfThen(lBool,IfThen(v,1),v);
    end
    else begin
      lVsb:=false; ChildFldAll(pn1,PrVisible,[Longint(@lVsb)]); lBool:=true;
    end;
    if lVsb then begin
      if lBool then n:=byte(not boolean(n))
      else begin
        Inc(n);
        if n=StrCount(mniDlm,tf.Mask)+1 then n:=0;
      end;
      KeyLb1.SetKey(Key,txt[n],hnt[n],KeyLb1ProcKey,'property',kmEdit);
    end;
    DelStack;
  end;
const aDirectionHint: TFindDirectionStr = ('','','');
begin
  AddStack('TFind.SetKeys',Self);
  SetKey(K_F4,['Меньше','Больше'],['Скрыть расширенные возможности','Показать расширенные возможности'],
    nil,byte(FPropVisible));
  SetKey(K_F5,['Без регистра','С регистром'],['Не учитывать регистр','Учитывать регистр'],ERegistr);
  SetKey(K_F6,['Не слово','Слово'],['Не только слово целиком','Только слово целиком'],EWord);
  SetKey(K_F7,aDirection,aDirectionHint,EDirection);
  KeyLb1.Redrw;
  DelStack;
end;

procedure TFind.KeyLb1ProcKey(key: longint; tw: TWinControl);
  procedure ExecKey(k: longint; tf: TFldEdit);
  var v: variant;
  begin
  	AddStack('TFind.KeyLb1ProcKey.ExecKey',Self);
    if key=k then begin
      v:=tf.VarValue;
      if MyVarType(v)=varBoolean then tf.VarValue:=not v
      else begin
        tf.VarValue:=v+1;
        if tf.VarValue=v then tf.VarValue:=0;
      end;
    end;
    DelStack;
  end;
begin
	AddStack('TFind.KeyLb1ProcKey',Self);
	if (Key=K_Esc) and not isModal then Aborted:=true
  else if Key=K_F4 then begin
    SetPropVisible(not FPropVisible); KeyLb1.ExecKey(IfThen(FPropVisible,K_Down,K_Ctrl_Home));
  end
  else begin
    inherited;
    ExecKey(K_F5,ERegistr);
    ExecKey(K_F6,EWord);
    ExecKey(K_F7,EDirection);
    SetKeys;
  end;
  DelStack;
end;

procedure TFind.SetPropVisible;
begin
  AddStack('TFind.SetPropVisible',Self);
  FPropVisible:=Value;
  TFldEdit.SetReadOnly([ERegistr,EWord,EDirection,EReplace],not FPropVisible);
  EReplace.Change(EReplace.VarValue,false);
  SetKeys;
  DelStack;
end;

procedure TFind.AfterCreate;
begin
  // Отключаем RestIniForm
end;

class function TFind.LastViewForm;
begin
  AddStack('TFind.LastViewForm');
  result:=aForm[nForm+1];
  DelStack;
end;

procedure TFind.WMFormLimit;
var i: longint;
begin
  AddStack('TFind.WMFormLimit',Self);
  for i:=low(aForm) to high(aForm) do if FreeLimit(aForm[i]) then break;
  DelStack;
end;

function WinFindSayStat(const Prc: variant): boolean;
var w: longint;
  i: byte;
begin
  AddStack('FFind.WinFindSayStat');
  Application.ProcessMessages;
  with aForm[nForm] do begin
    if isModal then result := ModalResult=mrCancel
    else begin
      if not Visible and (My_pr.GetTickCount-mSecBeg>MSecsPerSec)
      then FWinFind(tCont,sprf,false,Options,Caption);
      result:=IfThen(Visible,Aborted);
    end;
    gg.Progress:=nround(prc*gg.MaxValue);
    if not gg.Visible then if My_pr.GetTickCount-mSecBeg>MSecsPerSec*3 then begin
      i:=PnMsg.BevPanel; w:=PnMsg.Canvas.TextWidth(PnMsg.Caption)+i;
      gg.SetBounds(w,i,PnMsg.Width-i-w,PnMsg.Height-i shl 1);
      gg.Show;
    end;
  end;
  DelStack;
end;

initialization
	AddStack('FFind.initialization');
  MyTypes.WinFind:=WinFind; MyTypes.WinFindKey:=WinFindKey; MyTypes.WinFindSayStat:=WinFindSayStat;
	TInter.SetFunction('FindPrm','',
    ['[Стр: строка]','[УчРег: логическое]','[Слово: логическое]','[Направл: целое]'],
    ['CU','LU','LU','NU'],c_prm,null);
  DelStack;
end.

