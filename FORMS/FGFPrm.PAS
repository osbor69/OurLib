unit FGFPrm;

interface

{$I LIBTEST}
uses
  Windows, Messages, Classes, Controls, Forms, ExtCtrls, ComCtrls, Menus,
  MyTypes, GenForm, FRMEMPTY, Keylb, Fpanel, FFldedit, RbPage, MenuGet, RecVal, KeyMenu, PnlEdit,
    RbScroll, CCodeGet;

type
	TGFPrmHideOption = (gptPrm,gptSpot,gptNFmt,gptDFmt);
	TGFPrmHideOptions = set of TGFPrmHideOption;

  TGFPrm = class(TFormEmp)
    KeyMenu1: TKeyMenu;
    RV: TRecVal;
    FrmGet: TMenuGet;
    PanelEdit1: TPanelEdit;
    RbPage1: TRbPage;
    tsPrm: TTabSheet;
    tsSpot: TTabSheet;
    PnSpot: TRbPanel;
    ESpTop: TFldEdit;
    ESpBottom: TFldEdit;
    ESpLeft: TFldEdit;
    ESpRight: TFldEdit;
    tsNFmt: TTabSheet;
    tsDFmt: TTabSheet;
    pnSamp: TRbPanel;
    tsPrn: TTabSheet;
    pnPrn1: TRbPanel;
    scrlPrn: TRbScrollBox;
    pnPrn: TRbPanel;
    pnscPrm: TRbPanel;
    scrlPrm: TRbScrollBox;
    PnPrm: TRbPanel;
    pnPrm1: TRbPanel;
    EStdFrm: TFldEdit;
    ENFrm: TFldEdit;
    EWidth: TFldEdit;
    EHeight: TFldEdit;
    EOrient: TFldEdit;
    pnPrm2: TRbPanel;
    EDateTime: TFldEdit;
    EBreak: TFldEdit;
    pnGridLine: TRbPanel;
    EGridLineWidth: TFldEdit;
    EGridLineMin: TFldEdit;
    pnscNFmt: TRbPanel;
    scrlNFmt: TRbScrollBox;
    PnNFmt: TRbPanel;
    pnscDFmt: TRbPanel;
    scrlDFmt: TRbScrollBox;
    PnDFmt: TRbPanel;
    PnDEd: TRbPanel;
    EDDlm: TFldEdit;
    EDNYear: TFldEdit;
    EAWidth: TFldEdit;
    PnNSamp1: TRbPanel;
    PnNSamp: TRbPanel;
    ENSamp: TFldEdit;
    ENSamp1: TFldEdit;
    PnNEd: TRbPanel;
    ENFracDlm: TFldEdit;
    ENFracCnt: TFldEdit;
    ENFracEmp: TFldEdit;
    ENDigIsDlm: TFldEdit;
    ENDigDlm: TFldEdit;
    ENZeroEmp: TFldEdit;
    ENAllCnt: TFldEdit;
    pnDSamp1: TRbPanel;
    PnDSamp: TRbPanel;
    EDSamp: TFldEdit;
    ENsZero: TFldEdit;
    EDZeroEmp: TFldEdit;
    EDsZero: TFldEdit;
    ENSamp2: TFldEdit;
    EDSamp1: TFldEdit;
    EDMMYY: TFldEdit;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    procedure EStdFrmChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    procedure pnSampSetWHMin(Sender: TObject);
    procedure PBChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    procedure ENPrmChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    function EDlmCheck(Sender: TObject): Boolean;
    procedure EDPrmChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    procedure PnFSampSetWHMin(Sender: TObject);
    procedure ENFracCntChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    procedure EOrientChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    procedure PnSpotSetWHMin(Sender: TObject);
    procedure PnSpotResize(Sender: TObject);
    procedure EGridLineWidthChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    function PanelEdit1AskCancel(Sender: TObject): Boolean;
    function EGridLineWidthCheck(Sender: TObject): Boolean;
    procedure pnPrnSetWHMin(Sender: TObject);
    procedure pnSampAfterPaint(Sender: TObject);
    procedure pnPrnAfterPaint(Sender: TObject);
    procedure ENZeroEmpChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure EDZeroEmpChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure ENDigIsDlmChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
  private
    { Private declarations }
    DefaultPr: TGFPrmDefProc;
    FontPr,PrmPr: TGFPrmListF2Proc;
    ProcModify: TNotifyEvent;
    PartIni: string;
    ft,fl,fb,fr: TFldEdit;
    wl,wr,wt,wb,hl,hr,ht,hb,FNprm: longint;
    ls,lsbmDsgn: TGFBitMapList;
    function SetTsHide(const Value: TGFPrmHideOptions): TGFPrmHideOptions;
    procedure SetNPrm(Value: longint);
		procedure SetRV(const prm: TGFParams; SvOld: boolean);
		procedure ReadNprm(SvOld: boolean);
		procedure WriteNprm;
		procedure PnSpotPrm;
    procedure PrnKeyProc(key: longint; tw: TWinControl);
		class procedure TimerActPg(Sender: TObject);
    procedure RecToNPrm(var prm: TFmtNum);
    procedure RecToDPrm(var prm: TFmtDate);
    procedure SPrnEnter(Sender: TObject);
    procedure SPrnExit(Sender: TObject);
    class procedure SPrnChange(Sender: TObject; const OldVal: variant; FromShow: boolean);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    aPrm: TArrGFParam;
    Modified: boolean;
    property nPrm: longint read FnPrm write SetNPrm;
  end;

const
  aPrnPrmFld: array[TPrnPrmList] of string =
	  ('Str','Cnt','SortCop','Econ','VIntv','HIntv','Book','Feed','NoNewPg','Mirror');

var GFPrm,GFPrmEd: TGFPrm;

implementation

{$R *.DFM}

uses SysUtils,Graphics,DB,StrUtils,Printers,Math,
  My_pr,FGFBmp,ListF2,FSchemDM;

const
  wSamp = 200;
  wSpot = 105;

  nmRec = 'GFPrm';

var GFPrmTsHide: TGFPrmHideOptions = [];

procedure TGFPrm.FormCreate(Sender: TObject);
const
  aPrnPrms: array[TPrnPrmList,1..4] of string =
  	(('Диапазон листов'                        ,'TRadioGet'  ,'GFStr'    ,'')
  	,('Число копий'                            ,'TSpinGet'   ,''         ,'1,10')
  	,('Разобрать по копиям'                    ,'TBoolDrwGet','SortCop'  ,cChkPictPlace+cppRight)
  	,('Экономия бумаги'                        ,'TRadioGet'  ,'GFEcon'   ,cChkPictPlace+cppRight)
  	,('Интервал по вертикали(мм)'              ,'TSpinGet'   ,''         ,'0,99999')
  	,('Интервал по горизонтали(мм)'            ,'TSpinGet'   ,''         ,'0,99999')
  	,('Печать "книжкой"'                       ,'TRadioGet'  ,'GFPrnBook',cRdBeg+'0'+cChkPictPlace+cppRight)
  	,('Подача бумаги'                          ,'TRadioGet'  ,'Feed'     ,'')
  	,('Посылать на печать каждый лист отдельно','TBoolGet'   ,''         ,'')
  	,('Зеркальные отступы для чётных листов'   ,'TBoolGet'   ,''         ,'')
    );
var ts,tf: TFldEdit;
  p: TPrnPrmList;
begin
	AddStack('TGFPrm.FormCreate',Self);
  RV.NameRec:=nmRec;
  for p:=low(aPrnPrmFld) to high(aPrnPrmFld) do begin
  	RV.CreateFld('LPrn'+aPrnPrmFld[p],ftBoolean,0,false);
  	if p in sPrnPrmBool
    then RV.CreateFld('Prn'+aPrnPrmFld[p],ftBoolean,0,false)
    else RV.CreateFld('Prn'+aPrnPrmFld[p],ftInteger,0,0);
    ts:=TFldEdit.Create(Self);
    with ts do begin
    	Parent:=pnPrn;
      AssignGet(SchemDM.BoolGet1); Mask:=aPrnPrms[p,1];
      NameRec:=RV.NameRec; NameRecFld:='LPrn'+aPrnPrmFld[p];
      OnEnter:=SPrnEnter; OnExit:=SPrnExit; OnChange:=SPrnChange;
    end;
    tf:=TFldEdit.Create(Self);
    with tf do begin
    	Parent:=pnPrn;
      AssignGet(aPrnPrms[p,2],aPrnPrms[p,3]); Mask:=aPrnPrms[p,4];
      NameRec:=RV.NameRec; NameRecFld:='Prn'+aPrnPrmFld[p];
      IncOptions([ogReadOnlyNoVsbl]);
    end;
    ts.FocusControl:=tf;
    if p=low(aPrnPrmFld) then TPaintSay.CreatePrm('Начальное значение',pnPrn,tf);
  end;
  inherited;
  FrmGet.Arr2Mask(aGFFrm,byte(low(aGFFrm)));
  EOrient.Mask:=RadioMask(aGFOrient,0);
  EGridLineWidth.Mask:=StrNum('1,',GFWMaxMax); EGridLineMin.Mask:=EGridLineWidth.Mask;
  EBreak.Mask:=ArrayAsList(aGFBoolPrm,mniDlm); EAWidth.Mask:=EBreak.Mask;
  SetTsHide(GFPrmTsHide);
  DelStack;
end;

procedure TGFPrm.FormShow(Sender: TObject);
begin
	AddStack('TGFPrm.FormShow',Self);
	PanelEdit1.FldReadAll([ferdSvOld]); RbPage1.SetActivePage(tsPrm);
  inherited;
  DelStack;
end;

function GFPrmExec(var ppd: TPPDocRec; DefaultProc: TGFPrmDefProc;
  InGet: boolean; lsBitMap,lsBitMapDsgn: TGFBitMapList; const sPartIni: string;
  FontProc: TGFPrmListF2Proc; const pKeyStr: string = ''; pKeyProc: TKeyProc = nil;
  PrmProc: TGFPrmListF2Proc = nil; twActive: TWinControl = nil; nCurPrm: longint = 0;
  PrModify: TNotifyEvent = nil): boolean;
var f: TGFPrm;
  i: longint;
	hPrm: string;
  tw: TWinControl;
  tf: TFldEdit;
begin
	AddStack('FGFPrm.GFPrmExec');
  if InGet then begin
	  CreateForm(TGFPrm,GFPrmEd); f:=GFPrmEd;
  end
  else begin
	  CreateForm(TGFPrm,GFPrm); f:=GFPrm;
  end;
  with f do begin
  	RV.NameRec:=nmRec+'_'+IfThen(InGet,'2','1');
    for i:=0 to ComponentCount-1 do if IsClass(Components[i],TFldEdit,pointer(tf)) then
      if tf.NameRec=nmRec then tf.NameRec:=RV.NameRec;
  	if InGet then begin
      ProcControlsVisible(PnPrm,false); ProcControlsVisible(EAWidth,true);
      tw:=pnGridLine; ProcControlsVisible(tw,true);
      repeat
        tw.Visible:=true; ParentSelf(tw);
      until tw=f;
      hPrm:=PnPrm1.Header; PnPrm1.Header:=''; PnPrm1.SortObj:=false;
      KeyLb1.SetKey(K_F7,'','',nil,'none',kmNone); PanelEdit1.FillFldList; MainRebuild;
    end;
    lsbmDsgn:=lsBitMapDsgn;
    DefaultPr:=DefaultProc; FontPr:=FontProc; PrmPr:=PrmProc; ProcModify:=PrModify;
    tsPrn.TabVisible := Assigned(DefaultPr) and not InGet; PartIni:=sPartIni;
    SetLength(aPrm,Length(ppd.Params.Arr)); nPrm:=nCurPrm;
	  for i:=low(aPrm) to high(aPrm) do aPrm[i]:=ppd.Params.Arr[i];
    SetRV(ppd.Params,true);
		with KeyLb1 do begin
      if Assigned(DefaultPr)
      then SetKey(K_Alt_Home,'','Установка параметров по умолчанию',KeyLb1ProcKey,'prmdef',kmFile)
      else DelKey(K_All,'prmdef');
      if tsPrn.TabVisible then with pnPrn do for i:=0 to ControlCount-1 do with TFldEdit(Controls[i]) do
        if Enabled then with InitFIni[fiPPdoc] do
          if Assigned(FocusControl) or (MyVarType(VarValue)=varBoolean)
          then VarValue:=ReadBool(PartIni,NameRecFld,VarValue)
          else VarValue:=ReadInteger(PartIni,NameRecFld,VarValue);
      if not Assigned(DefaultPr) or DBBmp.ActiveNoNil and (lsBitMap.Count>0)
      then SetKey(K_F8,'Рисунки','Настройка рисунков',KeyLb1ProcKey,'bmp',kmFile)
      else DelKey(K_All,'bmp');
      DelKey(K_All,'dop'); SetKeysSt(pKeyStr,pKeyProc,'dop'); Redrw;
    end;
		ls:=lsBitMap; Modified:=false;
    if Assigned(twActive) then TTimerOne.CreateProc(TimerActPg,f).Tag:=longint(twActive);
    result := ShowModal=mrOk;
    if result then with ppd.Params do begin
      DateTime:=RV['DateTime']; WriteNprm; SetLength(Arr,Length(aPrm));
		  for i:=low(aPrm) to high(aPrm) do Arr[i]:=aPrm[i];
      if tsPrn.TabVisible then with pnPrn do
      	for i:=0 to ControlCount-1 do with TFldEdit(Controls[i]) do
        	if Enabled then with InitFIni[fiPPdoc] do
          	if Assigned(FocusControl) or (MyVarType(VarValue)=varBoolean)
            then WriteBool(PartIni,NameRecFld,VarValue)
            else WriteInteger(PartIni,NameRecFld,VarValue);
    end;
    if InGet then begin
      SetTsHide(GFPrmTsHide); ProcControlsVisible(PnPrm,true); PnPrm1.Header:=hPrm;
      PnPrm1.SortObj:=true; KeyLb1.DelKey(K_All,'none'); PanelEdit1.FillFldList; MainRebuild;
    end;
    NoLimit:=false;
  end;
  DelStack;
end;

class procedure TGFPrm.TimerActPg;
var tw: TWinControl;
begin
  AddStack('TGFPrm.TimerActPg');
  tw:=TWinControl(TTimerOne(Sender).Tag); RbPagePgActive(tw); tw.SetFocus;
  DelStack;
end;

procedure TGFPrm.KeyLb1ProcKey(key: longint; tw: TWinControl);
var mr: TListF2Result;
  StrList: string;
  function LsF2Down(Proc: TGFPrmListF2Proc): boolean;
  var KeyStr: string;
    ProcKey: TKeyProc;
    MouseDown,MouseUp: TMouseEvent;
    MouseMove: TMouseMoveEvent;
    Show: TNotifyEvent;
    procedure IfThenProc(lAfter: boolean);
    begin
    	AddStack('TGFPrm.KeyLb1ProcKey.LsF2Down.IfThenProc',Self);
      if Assigned(Proc) then Proc(lAfter,StrList,KeyStr,ProcKey,MouseDown,MouseUp,MouseMove,Show);
      DelStack;
    end;
  begin
  	AddStack('TGFPrm.KeyLb1ProcKey.LsF2Down',Self);
    KeyStr:=''; ProcKey:=nil; MouseDown:=nil; MouseUp:=nil; MouseMove:=nil; Show:=nil;
    IfThenProc(false);
    result:=ListF2Down(StrList,mr,KeyLb1,0,PanelEdit1.Schem,KeyStr,ProcKey,0,nil,MouseDown,MouseMove,MouseUp,
      nil,'',true,Show);
    IfThenProc(true);
    DelStack;
  end;
var r: TRect;
  i: longint;
  prm: TGFParams;
begin
	AddStack('TGFPrm.KeyLb1ProcKey',Self);
	case Key of
  	// Установка отступов
  	K_F3: if IsPrinters then
      if Ask(['Установить отступы, соответствующие',
      'минимальным отступам для принтера ?'],true) then begin
        r:=GFCalcSpotPrn(RV['NFrm'],RV['Orient']);
        RV['SPLeft']:=r.Left; RV['SPTop']:=r.Top;
        RV['SPRight']:=r.Right; RV['SPBottom']:=r.Bottom;
        PanelEdit1.FldReadAll;
      end;
		// Настройка шрифтов
  	K_F4: begin
      StrList:=''; LsF2Down(FontPr);
    end;
    // Форматы
    K_F7: begin
      StrList:='';
      for i:=low(aPrm) to high(aPrm) do IncD(StrList,SpaceStr(i+1,3)+'. '+aPrm[i].Name+CRLF);
      mr:=TListF2Result.Create;
      try
      	mr.SelectStr:=nPrm; DecLen(StrList,lCRLF);
        if not LsF2Down(PrmPr) or (mr.SelectStr=nPrm)
          then nPrm:=nPrm
        else if PanelEdit1.Valid then begin
          WriteNprm; nPrm:=mr.SelectStr; ReadNprm(true);
        end;
      finally
        mr.Free;
      end;
    end;
		// Настройка рисунков
  	K_F8: TGFBmp.Execute(ls,lsbmDsgn,[],'',PartIni,'',ProcModify);
    // По умолчанию
    K_Alt_Home: if Ask(['Установить параметры формы по умолчанию ?'])
    then begin
    	prm:=GFCopyParams(DefaultPr); aPrm[nPrm]:=prm.Arr[nPrm]; SetRV(prm,false); Modified:=true;
    end;
  else inherited;
  end;
  DelStack;
end;

procedure TGFPrm.SetRV;
var i: TPrnPrmList;
begin
	AddStack('TGFPrm.SetRV',Self);
  RV['DateTime']:=prm.DateTime;
  if tsPrn.TabVisible then for i:=low(i) to high(i) do with aPrnPrmDef[i] do begin
  	RV['LPrn'+aPrnPrmFld[i]]:=lSave; RV['Prn'+aPrnPrmFld[i]]:=Def;
  end;
  ReadNprm(SvOld);
  DelStack;
end;

procedure TGFPrm.SetNPrm;
begin
	AddStack('TGFPrm.SetNPrm',Self);
  FNprm:=Value;
  PanelEdit1.Header:=Format('Формат %d из %d: ',[nPrm+1,Length(aPrm)])+aPrm[nPrm].Name;
  DelStack;
end;

procedure TGFPrm.ReadNprm;
  procedure BoolPrm(st: TBoolSet; const nmf: string);
  begin
    AddStack('TGFPrm.ReadNprm.BoolPrm',Self);
    RV[nmf]:=SetByteSet(st);
    DelStack;
  end;
begin
  AddStack('TGFPrm.ReadNprm',Self);
  nPrm:=nPrm;
  with aPrm[nPrm] do begin
    RV['StdFrm']:=StdFormat; RV['NFrm']:=NFormat; RV['Orient']:=Orientation;
	  RV['GridLineWidth']:=GridLineWidth; RV['GridLineMin']:=GridLineMin;
    BoolPrm(aBreak,'Break'); BoolPrm(aWidth,'AWidth');
    with PrmNum do begin
      RV['NFracDlm']:=FracDlm; RV['NFracCnt']:=FracCnt; RV['NFracEmp']:=FracEmp2Bool(FracEmp);
      RV['NDigIsDlm']:=DigIsDlm; RV['NDigDlm']:=DigDlm; RV['NZeroEmp']:=ZeroEmp.l;
      RV['NAllCnt']:=AllCnt; RV['NsZero']:=ZeroEmp.s;
    end;
    with PrmDate do begin
      RV['DDlm']:=Dlm; RV['DNYear']:=NYear; RV['DMMYY']:=MMYY;
      RV['DZeroEmp']:=ZeroEmp.l; RV['DsZero']:=ZeroEmp.s;
    end;
    RV['Width']:=SizeMm.cX; RV['Height']:=SizeMm.cY;
    RV['SpLeft']:=SpotMm.Left; RV['SpTop']:=SpotMm.Top;
    RV['SpRight']:=SpotMm.Right; RV['SpBottom']:=SpotMm.Bottom;
  end;
  PanelEdit1.FldReadAll(IfThen(SvOld,ferdSvOld));
  DelStack;
end;

procedure TGFPrm.WriteNprm;
  procedure BoolPrm(var st: TBoolSet; const nmf: string);
  begin
    AddStack('TGFPrm.WriteNprm.BoolPrm',Self);
    GetByte(RV[nmf],st);
    DelStack;
  end;
var i: longint;
begin
  AddStack('TGFPrm.WriteNprm',Self);
  with PanelEdit1 do for i:=0 to FieldCount-1 do with Fields[i] do
  	if Value<>OldValue then with aPrm[nPrm] do begin
      StdFormat:=RV['StdFrm']; NFormat:=RV['NFrm']; Orientation:=RV['Orient'];
      GridLineWidth:=RV['GridLineWidth']; GridLineMin:=RV['GridLineMin'];
      BoolPrm(aBreak,'Break'); BoolPrm(aWidth,'AWidth');
      RecToNPrm(PrmNum); RecToDPrm(PrmDate);
      WinSize(SizeMm,RV['Width'],RV['Height']);
      SpotMm.Left:=RV['SpLeft']; SpotMm.Top:=RV['SpTop'];
      SpotMm.Right:=RV['SpRight']; SpotMm.Bottom:=RV['SpBottom'];
      Self.Modified:=true; break;
    end;
  DelStack;
end;

procedure TGFPrm.EStdFrmChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
var stdfmt,nolim: boolean;
  sz: TSize;
  ow,oh: TGetOptions;
begin
	AddStack('TGFPrm.EStdFrmChange',Self);
	stdfmt:=RV['StdFrm'];
  if TFldEdit(Sender).NameRecFld='STDFRM' then begin
    ENFrm.SetReadOnly(not stdfmt);
    if not stdfmt then begin
      pnSamp.Invalidate; pnSpot.Invalidate;
    end;
  end;
  ow:=EWidth.Options; oh:=EHeight.Options; SetSet(ow,ogReadOnly,stdfmt); SetSet(oh,ogReadOnly,stdfmt);
  if stdfmt then begin
    sz:=TGenForm.GetStdSize(longint(RV['NFrm']),RV['Orient']);
    EWidth.VarValue:=sz.cX; EHeight.VarValue:=sz.cY;
  end;
  nolim:=TGenForm.SizeNoLimit(stdfmt,sz);
  SetSet(ow,ogReadOnlyNoVsbl,nolim); SetSet(oh,ogReadOnlyNoVsbl,nolim);
  EWidth.Options:=ow; EHeight.Options:=oh; TFldEdit.SetReadOnly([EBreak,EAWidth],nolim);
  DelStack;
end;

procedure TGFPrm.pnSampSetWHMin(Sender: TObject);
begin
	AddStack('TGFPrm.pnSampSetWHMin',Self);
  with TRbPanel(Sender) do begin
	  MaxWMin(wSamp+BevPanel2);
	  MaxHMin(wSamp+BevPanel2+HeaderHeight);
  end;
  DelStack;
end;

procedure TGFPrm.PBChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
begin
	AddStack('TGFPrm.PBChange',Self);
  pnSamp.Invalidate; pnSpot.Invalidate;
  DelStack;
end;

procedure TGFPrm.pnSampAfterPaint(Sender: TObject);
const
	wBox    = 15;
	wBox2   = wBox shl 1;
  wBox1   = 2;
	wShadow = 2;
  aBeg    = 0.1;
  aEnd    = 0.3;
  wLine   = 1;
  hLine   = 3;
  hPar    = 5;
  cntLine = 4;
  txtW    = 1;
  txtH    = 1;
var t,h: longint;
  function IncTop(step: longint): boolean;
  begin
  	AddStack('TGFPrm.pbPaint.IncTop',Self);
  	Inc(t,step); result := t>h;
    DelStack;
  end;
var l,w: longint;
  function IncLeft(step: longint): boolean;
  begin
  	AddStack('TGFPrm.pbPaint.IncLeft',Self);
  	Inc(l,step); result := l>w;
    DelStack;
  end;
var t1,b1,l1,i,j,ab,ae: longint;
  lscp: boolean;
  pn: TRbPanel;
	prc: Double;
label lend;
begin
	AddStack('TGFPrm.pnSampAfterPaint',Self);
	w:=RV['Width']; h:=RV['Height']; pn:=TRbPanel(Sender);
  if (w<>0) and (h<>0) then with pn.Canvas do begin
    if RV['Orient']=poLandscape then begin
    	ab:=w; w:=h; h:=ab;
    end;
    l:=IfThen(pn=pnSamp,wSamp,wSpot);
  	// Лист
    if w>h then begin
    	t:=l-wBox2; prc:=t/w; w:=t; h:=nround(h*prc);
    end
    else begin
      t:=l-wBox2; prc:=t/h; h:=t; w:=nround(w*prc);
    end;
    l := (pn.Width-w) div 2 - 1; t := pn.HeaderHeight + (pn.Height-pn.HeaderHeight-h) div 2 - 1;
    Pen.Color:=clBlack; Brush.Color:=clWhite;
    Rectangle(l,t,l+w,t+h);
    // Тень
    for i:=0 to wShadow-1 do begin
    	MoveTo(l+w+i,t+wShadow);
      LineTo(l+w+i,t+h+i); LineTo(l+wShadow,t+h+i);
    end;
    // Строчки
    Inc(w,l-wBox1); Inc(h,t-wBox1); Inc(l,wBox1); Inc(t,wBox1); lscp := RV['Orient']=poLandscape;
    if lscp then begin
      Dec(w,nround(RV['SpBottom']*prc));
      Dec(h,nround(RV['SpLeft']  *prc));
      Inc(l,nround(RV['SpTop']   *prc));
      Inc(t,nround(RV['SpRight'] *prc));
      t1:=l; b1:=w; l1:=t+nround((h-t)/2);
      if (l>=w) or (t>=h) then goto lend;
      ab:=nround((h-t)*aBeg); ae:=nround((h-t)*aEnd);
      while l<=w do begin
        for i:=1 to cntLine do begin
          for j:=1 to wLine do begin
            MoveTo(l,IfThen(i=cntLine,h-ae,t));
            LineTo(l,IfThen(i=1,h-ab,h));
            if IncLeft(1) then goto lend;
          end;
          if IncLeft(hLine) then goto lend;
        end;
        if IncLeft(hPar) then goto lend;
      end;
    end
    else begin
      Dec(w,nround(RV['SpRight'] *prc));
      Dec(h,nround(RV['SpBottom']*prc));
      Inc(l,nround(RV['SpLeft']  *prc));
      Inc(t,nround(RV['SpTop']   *prc));
      t1:=t; b1:=h; l1:=l+nround((w-l)/2);
      if (l>=w) or (t>=h) then goto lend;
      ab:=nround((w-l)*aBeg); ae:=nround((w-l)*aEnd);
      while t<=h do begin
        for i:=1 to cntLine do begin
          for j:=1 to wLine do begin
            MoveTo(IfThen(i=1,l+ab,l),t);
            LineTo(IfThen(i=cntLine,l+ae,w),t);
            if IncTop(1) then goto lend;
          end;
          if IncTop(hLine) then goto lend;
        end;
        if IncTop(hPar) then goto lend;
      end;
    end;
lend:
    w:=Mm10ToScr(RV['GridLineWidth']); l:=l1-nround(w/2); Inc(w,l); Brush.Color:=clBlack;
    if (b1>=t1) and (w>=l) then with pn.Canvas do
      if lscp then FillRect(Rect(t1,l,b1,w)) else FillRect(Rect(l,t1,w,b1));
  end;
  DelStack;
end;

procedure TGFPrm.ENFracCntChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
var l,t: longint;
begin
	AddStack('TGFPrm.ENFracCntChange',Self);
  l:=18; t:=RV['NFracCnt'];
  if t>0 then Inc(l,t+1);
  with ENAllCnt do begin
	  Mask:=StrNum('0,',l); VarValue:=min(VarValue,l); ENPrmChange(Sender,OldVal,FromShow);
  end;
  DelStack;
end;

procedure TGFPrm.ENDigIsDlmChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
  AddStack('TGFPrm.ENDigIsDlmChange',Self);
  ENDigDlm.SetReadOnly(not RV['NDigIsDlm']); ENPrmChange(Sender,OldVal,FromShow);
  DelStack;
end;

procedure TGFPrm.ENZeroEmpChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
  AddStack('TGFPrm.ENZeroEmpChange',Self);
  ENsZero.SetReadOnly(not RV['NZeroEmp']); ENPrmChange(Sender,OldVal,FromShow);
  DelStack;
end;

procedure TGFPrm.ENPrmChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
var prm: TFmtNum;
	l,i: longint;
  v: Extended;
begin
	AddStack('TGFPrm.ENPrmChange',Self);
  with prm do begin
    RecToNPrm(prm); v:=0;
    if AllCnt=0 then l:=1 else l:=LenInt(AllCnt,FracCnt);
    for i:=1 to l do IncD(v,(i mod 10)*Trunc(IntPower(10,l-i)));
    ENSamp.VarValue:=FmtNum(v,prm);
    for i:=1 to FracCnt do IncD(v,i*IntPower(10,-i));
    ENSamp1.VarValue:=FmtNum(v,prm);
    ENSamp2.VarValue:=FmtNum(0,prm);
  end;
  DelStack;
end;

procedure TGFPrm.RecToNPrm;
begin
  AddStack('TGFPrm.RecToNPrm',Self);
  with prm do begin
    FracDlm:=StrToChar(RV['NFracDlm']); FracCnt:=RV['NFracCnt']; FracEmp:=Bool2FracEmp(RV['NFracEmp']);
    DigIsDlm:=RV['NDigIsDlm']; DigDlm:=StrToChar(RV['NDigDlm']);
    ZeroEmp.l:=RV['NZeroEmp']; AllCnt:=RV['NAllCnt']; ZeroEmp.s:=RV['NsZero'];
  end;
  DelStack;
end;

procedure TGFPrm.RecToDPrm;
begin
  AddStack('TGFPrm.RecToDPrm',Self);
  with prm do begin
    Dlm:=StrToChar(RV['DDlm']); NYear:=RV['DNYear']; MMYY:=RV['DMMYY'];
    ZeroEmp.l:=RV['DZeroEmp']; ZeroEmp.s:=RV['DsZero'];
  end;
  DelStack;
end;

function TGFPrm.EDlmCheck(Sender: TObject): Boolean;
begin
	AddStack('TGFPrm.EDlmCheck',Self);
  result := not IsDigit(StrToChar(TFldEdit(Sender).VarValue));
  DelStack;
end;

procedure TGFPrm.EDZeroEmpChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
  AddStack('TGFPrm.EDZeroEmpChange',Self);
  EDsZero.SetReadOnly(not RV['DZeroEmp']); EDPrmChange(Sender,OldVal,FromShow);
  DelStack;
end;

procedure TGFPrm.EDPrmChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
var prm: TFmtDate;
begin
	AddStack('TGFPrm.EDPrmChange',Self);
  RecToDPrm(prm);
  EDSamp.VarValue:=FmtDate(Date,prm);
  EDSamp1.VarValue:=FmtDate(DateEmpty,prm);
  DelStack;
end;

procedure TGFPrm.PnFSampSetWHMin(Sender: TObject);
const iX=5; iY=5;
var ts: TPaintSay;
	a: TArrFldEdit;
  i,h,w,l: longint;
begin
	AddStack('TGFPrm.PnFSampSetWHMin',Self);
  with TRbPanel(Sender) do
  	if tsNFmt.TabVisible then begin
      ts:=nil; i:=ControlCount; SetLength(a,i); l:=0;
      for i:=0 to i-1 do if IsClass(Controls[i],TFldEdit,pointer(a[l])) then begin
        PointerDef(pointer(ts),a[l].PaintSay); Inc(l);
      end;
      h:=0; w:=0;
      for i:=0 to l-1 do with a[i] do begin
        MaxSelf(w,Width); Inc(h,Height);
      end;
      Width:=ts.Width+w+3*iX; Height:=max(ts.Height,h)+iY shl 1;
      ts.SetBounds(iX,(Height-ts.Height) div 2,0,0);
      h:=iY;
      for i:=0 to l-1 do with a[i] do begin
        SetBounds(ts.Bounds.Right+iX,h,Width,Height); Inc(h,Height);
      end;
    end
    else begin
    	WMin:=0; HMin:=0; Width:=0; Height:=0;
    end;
  DelStack;
end;

// Включение/отключение панелей
function TGFPrm.SetTsHide;
	procedure Set1(ts: TTabSheet; opt: TGFPrmHideOption);
  begin
  	AddStack('TGFPrm.SetTsHide.Set1',Self);
    if ts.TabVisible then Include(result,opt);
	  RbPage1.SetTabVisible(ts,not(opt in Value)); ProcControlsVisible(ts.Controls[0],ts.TabVisible);
    DelStack;
  end;
begin
	AddStack('TGFPrm.SetTsHide',Self);
  result:=[]; Set1(tsPrm,gptPrm);
  Set1(tsSpot,gptSpot); Set1(tsNFmt,gptNFmt); Set1(tsDFmt,gptDFmt); MainRebuild;
  DelStack;
end;

procedure TGFPrm.EOrientChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
begin
	AddStack('TGFPrm.EOrientChange',Self);
  ESpRight.TabOrder:=IfThen(RV['Orient']<>poLandscape,3); PanelEdit1.FillFldList;
	EStdFrmChange(Sender,OldVal,FromShow); PnSpotResize(pnSpot);
  DelStack;
end;

procedure TGFPrm.PnSpotSetWHMin(Sender: TObject);
begin
	AddStack('TGFPrm.PnSpotSetWHMin',Self);
  PnSpotPrm;
  with TRbPanel(Sender) do begin
    WMin:=MaxIntValue([wt,wb,wl+wSpot+wr]);
    HMin:=MaxIntValue([hl,hr,ht+wSpot+hb]);
  end;
  DelStack;
end;

procedure TGFPrm.PnSpotResize(Sender: TObject);
var l,t,r,b: longint;
begin
	AddStack('TGFPrm.PnSpotResize',Self);
  PnSpotPrm;
  with TRbPanel(Sender) do begin
    l:=nround((Width-WMin)/2); t:=nround((Height-HMin)/2);
    fl.PaintSay.SetBounds(l+nround((wl-fl.PaintSay.Width)/2),
    	t+nround((HMin-hl)/2),0,0);
    fl.SetBounds(l+nround((wl-fl.Width)/2),fl.PaintSay.Bounds.Bottom,0,0);
    ft.PaintSay.SetBounds(l+nround((WMin-wt)/2),t,0,0);
    ft.SetBounds(ft.PaintSay.Bounds.Right,t,0,0);
    r:=l+wl+wSpot; b:=t+ht+wSpot;
    fr.PaintSay.SetBounds(r+nround((wr-fr.PaintSay.Width)/2),
    	t+nround((HMin-hr)/2),0,0);
    fr.SetBounds(r+nround((wr-fl.Width)/2),fr.PaintSay.Bounds.Bottom,0,0);
    fb.PaintSay.SetBounds(l+nround((WMin-wb)/2),b,0,0);
    fb.SetBounds(fb.PaintSay.Bounds.Right,b,0,0);
  end;
  DelStack;
end;

procedure TGFPrm.PnSpotPrm;
begin
  AddStack('TGFPrm.PnSpotPrm',Self);
  if RV['Orient']=poLandscape then begin
  	fl:=ESpTop; fb:=ESpLeft; fr:=ESpBottom; ft:=ESpRight;
  end
  else begin
  	ft:=ESpTop; fl:=ESpLeft; fb:=ESpBottom; fr:=ESpRight;
  end;
  with pnSpot do begin
  	wl:=max(fl.PaintSay.Width,fl.Width); hl:=fl.PaintSay.Height+fl.Height;
    wr:=max(fr.PaintSay.Width,fr.Width); hr:=fr.PaintSay.Height+fr.Height;
  	ht:=max(ft.PaintSay.Height,ft.Height); wt:=ft.PaintSay.Width+ft.Width;
    hb:=max(fb.PaintSay.Height,fb.Height); wb:=fb.PaintSay.Width+fb.Width;
  end;
  DelStack;
end;

procedure TGFPrm.EGridLineWidthChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TGFPrm.EGridLineWidthChange',Self);
  pnSamp.Invalidate;
  DelStack;
end;

function TGFPrm.PanelEdit1AskCancel(Sender: TObject): Boolean;
begin
  result:=Modified;
end;

procedure TGFPrm.WMFormLimit;
begin
	AddStack('TGFPrm.WMFormLimit',Self);
  inherited;
  if not FreeLimit(GFPrm) then FreeLimit(GFPrmEd);
  DelStack;
end;

function TGFPrm.EGridLineWidthCheck(Sender: TObject): Boolean;
begin
	AddStack('TGFPrm.EGridLineWidthCheck',Self);
  result:=RV['GridLineWidth']>=RV['GridLineMin'];
  if not result then meserr('Максимальная толщина линий меньше минимальной.');
  DelStack;
end;

procedure TGFPrm.pnPrnSetWHMin(Sender: TObject);
begin
	AddStack('TGFPrm.pnPrnSetWHMin',Self);
  with pnPrn do if ComponentCount>0 then TPaintSay(pnPrn.Components[0]).Font.Assign(Font);
  DelStack;
end;

procedure TGFPrm.SPrnEnter;
begin
	AddStack('TGFPrm.SPrnEnter',Self);
  with KeyLb1 do begin
  	SetKeySel([K_Plus,K_F2],[K_Minus,K_F3],PrnKeyProc,'sprn',kmEdit);
    Redrw;
  end;
  DelStack;
end;

procedure TGFPrm.SPrnExit;
begin
	AddStack('TGFPrm.SPrnExit',Self);
  with KeyLb1 do begin
  	DelKey(K_All,'sprn'); Redrw;
  end;
  DelStack;
end;

class procedure TGFPrm.SPrnChange;
begin
  AddStack('TGFPrm.SPrnChange');
  with TFldEdit(Sender) do TFldEdit(FocusControl).SetReadOnly(VarValue);
  DelStack;
end;

procedure TGFPrm.PrnKeyProc;
var fl: boolean;
	i: longint;
begin
	AddStack('TGFPrm.PrnKeyProc',Self);
  fl := Key in [K_F2,K_Plus];
  if AskSel(fl) then with pnPrn do
	  for i:=0 to ControlCount-1 do with TfldEdit(Controls[i]) do
    	if Enabled and Assigned(FocusControl) then VarValue:=fl;
  DelStack;
end;

procedure TGFPrm.pnPrnAfterPaint(Sender: TObject);
begin
	AddStack('TGFPrm.pnPrnAfterPaint',Self);
  with pnPrn do if (ControlCount>0) and (ComponentCount>0) then begin
  	Canvas.Font.Assign(Font);
    Canvas.TextOut(Controls[0].Left,TPaintSay(pnPrn.Components[0]).Top+BevelFld,
    	'Сохранять после печати');
  end;
  DelStack;
end;

initialization
  AddStack('FGFPrm.initialization');
  GenForm.GFPrmExec:=GFPrmExec;
  DelStack;
end.
