unit ArrGet;

interface

{$I LIBTEST}
uses
  Windows,Messages,Classes,Controls,Forms,Grids,
  MyTypes,FDWPrm,FrmStrm,FrmEmpty,KeyLb,FFldedit,StrBrowl,RecVal,RecDB,DefEdit;

type
  TArrGetKey = record
  	Key: longint;
    txt,hnt,prm: string;
  end;

  TArrGetPrm = record
    Wnd,KeyFml: string;
    NoApp: boolean;
    Keys: array of TArrGetKey;
  end;

  TArrGetFldOpt = set of (arfoNum,arfoWnd);
  
	TArrStm = class;
  TArrBrowl = class;

	TArrGetFld = class(TComponent)
  private
	  ls: TFldList;
    CodArr,Dat: string;
    Prm: TArrGetPrm;
    dw: TDWWin;
    lShowEd,lWnd: boolean;
    fStm: TArrStm;
    fSb: TArrBrowl;
		function SeekDat(const sDef,nmfUp: string; lWnd: boolean = false): boolean; overload;
		function SeekDat(r: TCustomRec; const nmf: string; lWnd: boolean = false): boolean; overload;
    procedure FDWTrans(Sender: TObject; var sTrans: String; lSave: Boolean);
    procedure FDWFldSeek(Sender: TObject; var a: TDWFldArrSeek;
      prAdd: TDWFldProcAdd);
    procedure dwFrmShow(Sender: TObject);
  public
    rdb: TRecDBDef;
		constructor CreateNum(AOwner: TComponent; lNum: boolean = false); overload;
		constructor CreateNum(r: TCustomRec; const nmf: string; Opt: TArrGetFldOpt = []); overload;
		destructor Destroy; override;
  end;

	TArrSaveIniList = (arsiEdit,arsiList,arsiStm);

  TArrGet = class(TCustomGet)
  private
    { Private declarations }
    flMove: boolean;
    ARow: longint;
    tfCur: TFldEdit;
    FData: TRecVal;
    FWnd: TDefEdit;
    procedure SetData(Value: TRecVal);
		function sbCalcZn(Sender: TObject; ACol: longint): String;
    procedure sbBeforeDrawCell(Sender: TObject; ACol,ARow: longint; Rect: TRect; State: TGridDrawState);
    procedure sbDrawCell(Sender: TObject; ACol,ARow: longint; Rect: TRect; State: TGridDrawState);
    procedure sbMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
    procedure sbMouseMove(Sender: TObject; Shift: TShiftState; X,Y: longint);
    procedure sbMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
		procedure sbDblClick(Sender: TObject);
		procedure TimerDblClick(Sender: TObject);
		procedure sbFill(ssb: TStringBrowl);
		procedure ProcKey(key: longint; tw: TWinControl);
		procedure ProcKeyDop(key: longint; tw: TWinControl);
		procedure Move(oi,ni: longint; Sender: TObject);
		procedure PrMove(oi,ni: longint; const av: array of variant);
    procedure tfUpd(Sender: TObject);
    procedure SetKeys(tl: TKeyLb);
    function tfSeek(Sender: TObject): TFldEdit;
    function tfAssignObj(Sender: TObject; var tf: TFldEdit): boolean; overload;
    function tfAssignObj(Sender: TObject): boolean; overload;
    function sbCreate(AOwner: TComponent; AParent: TWinControl): TStringBrowl;
  protected
    { Protected declarations }
    sb: TStringBrowl;
    f: TArrGetFld;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function MayDoKey(tf: TFldEdit; Key: longint): boolean; override;
    function AssignObj(tf: TFldEdit): boolean; override; // После вызова восстанавливать CurRdbArr
		function DWFldUnAllowType(const Mask: string): TDWFldSetType; override;
    procedure HookProc(tf: TFldEdit; var Message: TMessage); override;
    function MinSize(tf: TFldEdit): TSize; override;
  	class function MaskSortMode: TSortMode; override;
    class procedure FMaskView(var Mask: string); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
  	class function RestValType: TGetRestValType; override;
		procedure UpdateRec(tf: TFldEdit; Oper: TFEUpdateOper); override;
  public
    { Public declarations }
		constructor Create(AOwner: TComponent); override;
		function MaskProp(const Capt: TCaption; var Mask: string;
    	r: TCustomRec; const nmf: string; Opt: TMaskPropOpt = []): boolean; override;
		procedure MaskPrn(const Mask: string; LsPrn: TStringList); override;
    class function MaskTextReadOnly: boolean; override;
    class function MaskCngClear: boolean; override;
  	function MaskSearch(const Mask,SubStr: string; lIdent: boolean): boolean; override;
		function MaskReplace(var Mask: string; const stSource,sRepl: string;
    	lIdent: boolean; PrRepl: TReplaceProc; pav: PVariant): longint; override;
		class function SectIni(si: TArrSaveIniList; const CodArr: string): string;
		class procedure VarCreate;
    class function MaskToPrm(const Mask: string): TArrGetPrm;
    class function PrmToMask(const Prm: TArrGetPrm): string;
  published
    { Published declarations }
   	property Data: TRecVal read FData write SetData;
    property Wnd: TDefEdit read FWnd write FWnd;
    property VName;
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

	TArrStm = class(TFormStrm)
  private
  	fLs: TArrGetFld;
    LastRecno: longint;
    procedure sbUnKey(var UnKey: longint; lWrite: Boolean);
    procedure PnEditEscape(Sender: TObject; var Action: TCloseAction);
		function sbCalcZn(Sender: TObject; ACol: longint): String;
  	procedure WMSaveIni(var Msg: TWMSaveIni); message WM_SAVEINI;
  protected
    function BeforeEdit(lFirst: boolean): boolean; override;
  published
		procedure FormDestroy(Sender: TObject);
    function PnEditValid(Sender: TObject): Boolean;
    procedure sbDrawCell(Sender: TObject; ACol,ARow: longint; Rect: TRect; State: TGridDrawState);
  end;

	TArrBrowl = class(TFormEmp)
  private
  	fLs: TArrGetFld;
    sb: TStringBrowl;
  	procedure WMSaveIni(var Msg: TWMSaveIni); message WM_SAVEINI;
  published
		procedure FormDestroy(Sender: TObject);
  end;

procedure Register;

implementation

uses
  SysUtils,DB,Variants,Math,StrUtils,
  My_pr,Inter,ButGet,MenuGet,KeyMenu,FDWVid,FPanel,Shifr,PnlEdit,
    FrmPswd,FrmNul;

const
  VarBeg = 'arrvar';
  ArrNameRec = 'ArrGet';

type
	TArrKeyGet = class(TCustomGet)
  private
  	flMove: boolean;
    ARow: longint;
		class function sbCalcZn(Sender: TObject; ACol: longint): string;
    procedure sbMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
    procedure sbMouseMove(Sender: TObject; Shift: TShiftState; X,Y: longint);
    procedure sbMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
		procedure ProcKey(key: longint; tw: TWinControl);
		procedure Move(oi,ni: longint);
		procedure PrMove(oi,ni: longint; const av: array of variant);
  protected
  	sb: TStringBrowl;
    procedure CreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    function MayDoKey(tf: TFldEdit; Key: longint): boolean; override;
    function AssignObj(tf: TFldEdit): boolean; override;
  end;

  TArrLogCompare = class(TCustomLogCompare)
  public
    class function ListCreate(pv: pointer; const Value: string; lNew: boolean): pointer; override;
    class procedure ListDestroy(pv,ls: pointer); override;
    class function GetCount(pv,ls: pointer): longint; override;
    class procedure GetItem(var Prm: TLogTrnsValPrm; pv,lso,lsn: pointer; no,nn: longint; tp: TLogCompareItemList); override;
  end;

  TNone = class
  private
		class procedure UpdArrGet(Sender: TObject);
    class function ButWndClick(Sender: TObject; lEval: boolean): string;
    class procedure ButWndPaint(Sender: TObject; const ARect: TRect; const Text: string);
    class procedure PrInterDopGetVar(ProcDopGetVarAdd: TProcDopGetVarAdd);
    class function PrInterDopGetVarIgnore(const aPath: TVarPathStr): boolean;
  end;

var LsFld: TIntegerList;
  msrd: TRecDBDef;
  msrv: TDWVidRec;
  msCapt: string;
  msnom: longint;
  msf: TArrGetFld;
  lsVarDop: TVarDopList;
  ArrKeyGet: TArrKeyGet;
  rKey: TRecVal;
  deKey: TDefEdit;
  deKeyShiftGet,deKeyGet: TMenuGet;


function FProcLoad(f: TArrGetFld): variant;
var ac,av: variant;
  an: TArrInt;
  i,j,j1,li,lj: longint;
begin
	AddStack('ArrGet.FProcLoad');
  with f do begin
    li:=rdb.ArrCount; result:=VarArrayCreate([-1,li],varVariant);
    lj:=rdb.FldDef.Count; ac:=VarArrayCreate([1,lj],varVariant); av:=ac; SetLength(an,lj); j1:=0;
    for j:=1 to lj do begin
    	ac[j]:=TrimUpper(rdb.DWSToRec(j1).Name); an[j1]:=rdb.NumFromName(ac[j]);
      av[j]:=VarBlank(rdb.ValueNum[an[j1]]); Inc(j1);
    end;
    result[0]:=ac; result[-1]:=av;
    for i:=1 to li do begin
      rdb.GotoRec(i);
      for j:=1 to lj do av[j]:=rdb.ValueNum[an[j-1]];
      result[i]:=av;
    end;
  end;
  DelStack;
end;

function ProcLoad(const av: array of variant; f: TArrGetFld; i: longint; gk: longword): variant;
begin
	AddStack('ArrGet.ProcLoad');
  f.rdb.ArrValue:=TInter.VarProc(i,null,false); result:=FProcLoad(f);
  DelStack;
end;

procedure FProcSave(f: TArrGetFld; const av: variant);
var i,j,li,lj: longint;
  an: TArrInt;
begin
  AddStack('ArrGet.FProcSave');
  with f.rdb do begin
    li:=VarArrayHighBound(av,1); ArrCount:=li;
    lj:=VarArrayHighBound(av[0],1); SetLength(an,lj);
    for j:=1 to lj do an[j-1]:=NumFromName(av[0][j]);
    for i:=1 to li do begin
      GotoRec(i);
      for j:=1 to lj do ValueNum[an[j-1]]:=av[i][j];
      UpdateRec;
    end;
  end;
  DelStack;
end;

function ProcSave(const av: array of variant; f: TArrGetFld; i: longint; gk: longword): variant;
var k,j,n: longint;
  rf: TVarNmRec;
  a: array of record
    tf: TFldEdit;
    v: TArrVar;
    otl: TGridCoord;
  end;
  g: TArrGet;
  fl: boolean;
  ordb,r: TRecDBDef;
begin
	AddStack('ArrGet.ProcSave');
  ordb:=CurRdbArr;
  try
    if Assigned(LsDWWin) and IsNilc(av[3],true) then begin
      SetLength(a,LsDWWin.Count); rf:=VarNmToRec(av[1]);
      for k:=low(a) to high(a) do with a[k] do begin
        if TDWWin(LsDWWin[k]).de.IsFldEdit(rf[2],tf) then
        if IsClass(tf.PNameRec,TRecDBDef,pointer(r)) then if Assigned(tf.PNameRecFld) then
        if r.DWPrefix=rf[1] then if IsClass(tf.curget,TArrGet,pointer(g)) then
        if tf.PNameRecFld.MemGk=gk then if g.AssignObj(tf) then
        if g.f.rdb.GotoRec(g.sb.Row-g.sb.FixedRows+1) then begin
          SetLength(v,g.f.rdb.FieldCount);
          for j:=low(v) to high(v) do v[j]:=g.f.rdb.Field[j].Value;
          otl:=g.sb.TopLeft; continue;
        end;
        tf:=nil;
      end;
    end
    else a:=nil;
    FProcSave(f,av[2]); TInter.VarProc(i,f.rdb.ArrValue,true); result:=null;
    if Length(a)>0 then for k:=low(a) to high(a) do with a[k] do if Assigned(tf) then begin
      g:=pointer(tf.curget);
      if g.AssignObj(tf) then for n:=1 to g.f.rdb.ArrCount do begin
        g.f.rdb.GotoRec(n); fl:=true;
        for j:=low(v) to high(v) do if g.f.rdb.Field[j].Value<>v[j] then begin
          fl:=false; break;
        end;
        if fl then begin
          g.sb.Row:=EnsureRange(g.sb.FixedRows+n-1,g.sb.FixedRows,g.sb.RowCount-1); g.sb.TopLeft:=otl; break;
        end;
      end;
    end;
  finally
    CurRdbArr:=ordb;
  end;
  DelStack;
end;

function SeekFld(var tf: TFldEdit): boolean;
var i: longint;
  pe: TPanelEdit;
begin
  AddStack('ArrGet.SeekFld');
  result:=false;
  if Assigned(LsDWWin) then for i:=LsDWWin.Count-1 downto 0 do
    if TDWWin(LsDWWin[i]).de.PanelEdit(pe) then if pe.FldActive(tf) then if tf.curget is TArrGet then begin
      result:=true; break;
    end;
  DelStack;
end;

function c_loadsave(var av: array of variant):variant;
type TArrProc = function(const av: array of variant; f: TArrGetFld; i: longint; gk: longword): variant;
var a: TVarNmRec;
	f: TArrGetFld;
  r: TRecDBDef;
  i,j,gk: longint;
  tf: TFldEdit;
  Def: string;
  fl: boolean;
  ad: TArrStr;
begin
	AddStack('ArrGet.c_loadsave');
  if IsNil(av[1]) then begin
    if SeekFld(tf) then
      if IsClass(tf.PNameRec,TRecDBDef,pointer(r)) then av[1]:=r.DWVarName(tf.NameRecFld);
    if IsNil(av[1]) then raise EInterAnyError.Create('Не найден редактируемый массив');
  end;
  result:=false; f:=TArrGetFld.CreateNum(Application.MainForm);
  try
    if TInter.SeekVar(av[1],i) then begin
      a:=VarNmToRec(av[1]);
      if TRecDBDef.SeekDWPrefix(a[1],r) then begin
        DWRdbSeek(r); gk:=0;
        if r.GetValueDefault(rgvFldDef,[],@Def) then begin
          fl:=f.SeekDat(r,a[2]);
          if fl then gk:=r.FldName(a[2]).MemGk;
        end
        else begin
          fl:=false; f.Dat:=''; TrimUpperSelf(a[2]);
          for j:=0 to LsArrDynamic(Def,ad,CRLF)-1 do if f.SeekDat(ad[j],a[2]) then begin
            fl:=true; break;
          end;
          f.rdb.InitFldDef(dwdefGotoRec); f.rdb.OpenRec;
        end;
        if fl then result:=TArrProc(LongInt(av[0]))(av,f,i,gk);
      end;
    end;
  finally
	  f.Free;
  end;
  DelStack;
end;

function d_nrec(const v,ind: variant; lSave: boolean): variant;
var fl: boolean;
  tf: TFldEdit;
  ordb: TRecDBDef;
begin
	AddStack('ArrGet.d_nrec');
  result:=0; fl:=SeekFld(tf);
  if fl then with TArrGet(tf.curget) do begin
    ordb:=CurRdbArr;
    try
      if AssignObj(tf) then begin
        result:=f.rdb.RecNo;
        if lSave then sb.Row:=EnsureRange(sb.FixedRows+v-1,sb.FixedRows,sb.RowCount-1);
      end;
    finally
      CurRdbArr:=ordb;
    end;
  end;
  DelStack;
end;

function c_index(var av: array of variant):variant;
var i: longint;
	v: variant;
  a: TArrStr;
  av1: TArrVar;
begin
	AddStack('ArrGet.c_index');
  case MyVarType(av[2]) of
    V_BOOL: result:=false;
    varArray: begin
      i:=VarArrayHighBound(av[2],1); result:=VarArrayCreate([1,i],varVariant); CopyFromVArr(av1,av);
      for i:=1 to i do begin
        av1[2]:=av[2][i]; result[i]:=c_index(av1);
      end;
    end;
  else
    result:=0; CopyFrom(a,TrimUpper(av[2])); v:=av[1][0];
    if AnsiStartsText(RDBArr.DWVarName,a[0]) then AddFrom(a,Copy(a[0],Length(RDBArr.DWVarName)+1,MaxInt));
    for i:=1 to VarArrayHighBound(v,1) do if AnsiMatchText(v[i],a) then begin
      result:=i; break;
    end;
  end;
  DelStack;
end;

function c_add(var av: array of variant):variant;
var lo,ln: longint;
begin
	AddStack('ArrGet.c_add');
	result:=av[1]; lo:=VarArrayHighBound(result,1); ln:=lo+IsNilc(av[2],1); VarArrayRedim(result,ln);
  for lo:=lo+1 to ln do result[lo]:=result[-1];
  DelStack;
end;

function c_len(var av: array of variant):variant;
var ol,nl: longint;
  v: variant;
begin
  AddStack('ArrGet.c_len');
	result:=av[1]; ol:=VarArrayHighBound(result,1); nl:=av[2]; VarArrayRedim(result,nl);
  if nl>ol then begin
    v:=result[-1];
    for ol:=ol+1 to nl do result[ol]:=v;
  end;
  DelStack;
end;

{ TArrKeyGet }
procedure TArrKeyGet.CreateObj;
var si: TStrBrInfZn;
	i: longint;
begin
	AddStack('TArrKeyGet.CreateObj',Self);
  DestroyObj(tf); tf.Schem:='Browl';
  sb:=TStringBrowl.Create(tf);
  with sb do begin
    Parent:=tf;
    si:=InfoCol[0]; si.Alignment:=taLeftJustify; CopyFrom(si.aName,'Клавиша');
    for i:=1 to KEY_USER do MaxSelf(si.LenData,KeyToTxt(i));
    InfoCol[0]:=si;
    si.aName[0]:='Параметр'; si.LenData:=10; InfoCol[1]:=si;
    si.aName[0]:='Наименование'; InfoCol[2]:=si;
    si.aName[0]:='Подсказка'; si.lMax:=true; InfoCol[3]:=si;
    KeyDblClick:=K_F5; OnCalcZn:=sbCalcZn;
    OnMouseDown:=sbMouseDown; OnMouseMove:=sbMouseMove; OnMouseUp:=sbMouseUp;
    AddSt(Length(msf.Prm.Keys));
  end;
  tf.CharWidth:=wallDefault; tf.CharHeight:=-1; SetSchemForm(tf);
  DelStack;
end;

procedure TArrKeyGet.PaintObj;
begin
	AddStack('TArrKeyGet.PaintObj',Self);
  if AssignObj(tf) then begin
    sb.SetBounds(BevelFld,BevelFld,tf.Width-BevelFld2,tf.Height-BevelFld2); sb.WidthCols;
  end;
  DelStack;
end;

function TArrKeyGet.GetValue;
begin
  result:='';
end;

procedure TArrKeyGet.SetValue;
begin
end;

procedure TArrKeyGet.DoEnter;
var tl: TKeyLb;
begin
	AddStack('TArrKeyGet.DoEnter',Self);
  inherited DoEnter(tf);
	if AssignObj(tf) then GetParentForm(tf).ActiveControl:=sb;
  if FormKeyLb(tf,tl) then with tl do begin
  	SetKey(K_F4,'Скопировать','',ProcKey,'arrkeyget',kmList);
  	SetKey(K_F5,'Редактировать','',ProcKey,'arrkeyget',kmList);
  	SetKey(K_F7,'Добавить','',ProcKey,'arrkeyget',kmList);
  	SetKey(K_F8,'Удалить','',ProcKey,'arrkeyget',kmList);
  	SetKey(K_Ctrl_Up,'Выше','Переместить выше',ProcKey,'arrkeyget',kmList);
  	SetKey(K_Ctrl_Down,'Ниже','Переместить ниже',ProcKey,'arrkeyget',kmList);
    ReDrw;
  end;
  DelStack;
end;

procedure TArrKeyGet.DoExit;
var tl: TKeyLb;
begin
	AddStack('TArrKeyGet.DoExit',Self);
  inherited DoExit(tf);
  if FormKeyLb(tf,tl) then with tl do begin
  	DelKey(K_All,'arrkeyget'); ReDrw;
  end;
  DelStack;
end;

procedure TArrKeyGet.ProcKey;
	function InitEd(const Capt: string): boolean;
	var Shift: TKeyShftList0;
    AKey,i: longint;
    av: TDEPrmVar;
  begin
    AddStack('TArrKeyGet.ProcKey.InitEd',Self);
    if not Assigned(rKey) then begin
    	rKey:=TRecVal.Create(Application.MainForm);
      with rKey do begin
      	CreateFld('Shift',ftInteger,0,0);
      	CreateFld('Key',ftInteger,0,0);
      	CreateFld('Txt',ftMemo,0,'');
      	CreateFld('Hnt',ftMemo,0,'');
      	CreateFld('Prm',ftMemo,0,'');
      end;
      deKeyShiftGet:=TMenuGet.Create(Application.MainForm);
      with deKeyShiftGet do begin
      	VName:='ArrKeyShiftGet'; Items.BeginUpdate; Items.Add('0'+UnDelim+'[нет]');
        for i:=VarArrayLowBound(VAShftKeys,1) to VarArrayHighBound(VAShftKeys,1) do
        	Items.Add(IntToStr(i+1)+UnDelim+VAShftKeys[i]);
        Items.EndUpdate;
      end;
      deKeyGet:=TMenuGet.Create(Application.MainForm);
      with deKeyGet do begin
      	VName:='ArrKeyGet'; Items.BeginUpdate;
        for i:=VarArrayLowBound(VAKeys,1) to VarArrayHighBound(VAKeys,1) do
        	Items.Add(IntToStr(i+1)+UnDelim+VAKeys[i]);
        Items.EndUpdate;
      end;
    	deKey:=TDefEdit.Create(Application.MainForm);
      with deKey do begin
      	NameWnd:='ArrKeyGet';
        InitArr(av);
        av[deCaption]:='Управляющая клавиша';
        av[deNameRec]:=rKey.NameRec;
        av[deNameRecFld]:='Shift';
        deKeyShiftGet.AssignGet(av);
        av[deNoReadOnly]:=true;
        CreateFld(av);

        av[deCaption]:='Клавиша';
        av[deNameRecFld]:='Key';
        deKeyGet.AssignGet(av);
        CreateFld(av);

        av[deCaption]:='Текст';
        av[deNameRecFld]:='Txt';
        TSimpleGet.AssignGetClass(av);
        av[deAutoSel]:=true;
        av[deWidth]:=wallDefault;
        av[deTrimLeft]:=true;
        CreateFld(av);

        av[deCaption]:='Подсказка';
        av[deNameRecFld]:='Hnt';
        CreateFld(av);

        av[deCaption]:='Параметр';
        av[deNameRecFld]:='Prm';
        CreateFld(av);
      end;
    end;
    if Key in [K_F4,K_F5] then begin
      i:=sb.Row-sb.FixedRows; KeyToShift(msf.Prm.Keys[i].Key,Shift,AKey);
      rKey['Shift']:=Shift; rKey['Key']:=AKey;
      with msf.Prm.Keys[i] do begin
        rKey['Txt']:=Txt; rKey['Hnt']:=Hnt; rKey['Prm']:=Prm;
      end;
    end
    else begin
      rKey['Shift']:=0; rKey['Key']:=1; rKey['Txt']:=''; rKey['Hnt']:=''; rKey['Prm']:='';
    end;
    result:=deKey.Execute(Capt).Saved;
    DelStack;
  end;
	procedure RecRead(i: longint);
  begin
    AddStack('TArrKeyGet.ProcKey.RecRead',Self);
    with msf.Prm.Keys[i] do begin
      Key:=ShiftToKey(rKey['Shift'],rKey['Key']);
      Txt:=rKey['Txt']; Hnt:=rKey['Hnt']; Prm:=rKey['Prm'];
    end;
    DelStack;
  end;
var i,j: longint;
begin
	AddStack('TArrKeyGet.ProcKey',Self);
  if (Length(msf.Prm.Keys)>0) or (Key=K_F7) then case Key of
    K_F4,K_F7: if InitEd('Добавить клавишу') then begin
      i:=Length(msf.Prm.Keys); SetLength(msf.Prm.Keys,i+1); RecRead(i);
      if i>0 then begin
        i:=sb.RowCount; sb.RowCount:=i+1; sb.Row:=i;
      end;
      sb.CurStUpdate; sb.WidthCols;
    end;
    K_F5: if InitEd('Редактировать клавишу') then begin
    	RecRead(sb.Row-1); sb.CurStUpdate; sb.WidthCols;
    end;
    K_F8: if Ask(amsDel) then begin
    	j:=sb.Row;
      for i:=j to high(msf.Prm.Keys) do begin
      	msf.Prm.Keys[i-1]:=msf.Prm.Keys[i];
        sb.Rows[sb.FixedRows+i-1].Assign(sb.Rows[sb.FixedRows+i]);
      end;
      i:=Length(msf.Prm.Keys)-1; SetLength(msf.Prm.Keys,i);
      if i=0 then sb.Rows[sb.FixedRows].Clear else sb.IncRowCount(-1);
      sb.Row:=min(j,sb.RowCount-1); sb.WidthCols;
    end;
    K_Ctrl_Up: Move(sb.Row,sb.Row-1);
    K_Ctrl_Down: Move(sb.Row,sb.Row+1);
  end;
  DelStack;
end;

procedure TArrKeyGet.Move;
begin
	AddStack('TArrKeyGet.Move',Self);
  if ListMoveItem(oi,ni,1,sb.RowCount-1,PrMove,[0]) then sb.Row:=ni;
  DelStack;
end;

procedure TArrKeyGet.PrMove;
var s: string;
	k: TArrGetKey;
begin
	AddStack('TArrKeyGet.PrMove',Self);
  s:=sb.Rows[ni].Text; sb.Rows[ni].Assign(sb.Rows[oi]); sb.Rows[oi].Text:=s;
  Dec(oi,sb.FixedRows); Dec(ni,sb.FixedRows);
  k:=msf.Prm.Keys[ni]; msf.Prm.Keys[ni]:=msf.Prm.Keys[oi]; msf.Prm.Keys[oi]:=k;
  DelStack;
end;

class function TArrKeyGet.sbCalcZn;
var sb: TStringBrowl;
begin
	AddStack('TArrKeyGet.sbCalcZn');
  sb:=pointer(Sender);
  if InRange(sb.Row,1,Length(msf.Prm.Keys)) then with msf.Prm.Keys[sb.Row-1] do case ACol of
    0: result:=KeyToTxt(Key);
    1: result:=Prm;
    2: result:=Txt;
    3: result:=Hnt;
  else result:=''; 
  end;
  DelStack;
end;

procedure TArrKeyGet.sbMouseDown;
var ACol: longint;
begin
	AddStack('TArrKeyGet.sbMouseDown',Self);
	if not flMove and (Button=mbLeft) then begin
	  sb.MouseToCell(X,Y,ACol,ARow); flMove := ARow>0; sb.NoSel:=false;
  end;
  DelStack;
end;

procedure TArrKeyGet.sbMouseMove;
var ACol,nr: longint;
begin
	AddStack('TArrKeyGet.sbMouseMove',Self);
	if flMove then begin
	  sb.MouseToCell(X,Y,ACol,nr);
  	if (nr>0) and (nr<>ARow) then begin
		  Move(ARow,nr); ARow:=nr;
    end;
  end;
  DelStack;
end;

procedure TArrKeyGet.sbMouseUp;
begin
	AddStack('TArrKeyGet.sbMouseUp',Self);
	flMove:=false;
  DelStack;
end;

function TArrKeyGet.MayDoKey;
begin
	AddStack('TArrKeyGet.MayDoKey',Self);
  result := inherited MayDoKey(tf,Key);
  if AssignObj(tf) then  result:=not(((Key=K_Down) and (sb.Row<sb.RowCount-1))
  	or ((Key=K_Up) and (sb.Row>sb.FixedRows)));
  DelStack;
end;

function TArrKeyGet.AssignObj;
begin
	AddStack('TArrKeyGet.AssignObj',Self);
  if inherited AssignObj(tf) and (tf.ComponentCount=1)
  then result:=IsClass(tf.Components[0],TStringBrowl,pointer(sb))
  else begin
    sb:=nil; result:=false;
  end;
  DelStack;
end;

{ TArrGetFld }
constructor TArrGetFld.CreateNum(AOwner: TComponent; lNum: boolean = false);
var i: longint;
begin
	AddStack('TArrGetFld.CreateNum',Self);
	inherited Create(AOwner);
  ls:=TFldList.Create; dw:=TDWWin.Create(Self); dw.OnFrmShow:=dwFrmShow;
  rdb:=TRecDBDef.Create(Self);
  with rdb do begin
    DWName:='Данные по текущему массиву'; DWPrefix:=RDBArrPrefix;
    OnDWRdbSeek:=TRecDBDef.ArrDWRdbSeek;
    OnDWTrans:=FDWTrans; OnDWFldSeek:=FDWFldSeek; TDWVid.ArrRdbEvents(rdb);
    if lNum then begin
		  TIntegerList.Create(LsFld,[ilsSorted]); i:=0;
      while i<LsFld.Count do
        if lsFld[i]=i then Inc(i) else break;
      LsFld.Add(i); NameRec:=IntToStr(i)+ArrNameRec;
    end
    else NameRec:=ArrNameRec;
  end;
  DelStack;
end;

constructor TArrGetFld.CreateNum(r: TCustomRec; const nmf: string; Opt: TArrGetFldOpt = []);
begin
  CreateNum(Application.MainForm,arfoNum in Opt); SeekDat(r,nmf,arfoWnd in Opt);
end;

destructor TArrGetFld.Destroy;
begin
	AddStack('TArrGetFld.Destroy',Self);
  ls.Free; fStm.Free; fSb.Free;
  if rdb.NameRec<>ArrNameRec then FindDelFree(LsFld,Int0(rdb.NameRec));
  inherited Destroy;
  DelStack;
end;

procedure TArrGetFld.dwFrmShow;
var tf: TFldEdit;
	g: TArrGet;
  ordb: TRecDBDef;
begin
	AddStack('TArrGetFld.dwFrmShow',Self);
  if IsClass(Owner,TFldEdit,pointer(tf)) then if IsClass(tf.curget,TArrGet,pointer(g)) then begin
    ordb:=CurRdbArr;
    try
      g.AssignObj(tf);
      if Assigned(g.FWnd) then IfThenNotify(g.FWnd.OnFrmShow,Sender);
    finally
      CurRdbArr:=ordb;
    end;
  end;
  DelStack;
end;

procedure TArrGetFld.FDWTrans;
begin
	AddStack('TArrGetFld.FDWTrans',Self);
	if lSave then Dat:=sTrans else sTrans:=Dat;
  DelStack;
end;

procedure TArrGetFld.FDWFldSeek;
begin
	AddStack('TArrGetFld.FDWFldSeek',Self);
	PrAdd(a,Dat,Prm.Wnd,true); PrAdd(a,Dat);
  DelStack;
end;

function TArrGetFld.SeekDat(const sDef,nmfUp: string; lWnd: boolean = false): boolean;
var rv: TDWVidRec;
  ra: TRDBArrDef;
begin
	AddStack('TArrGetFld.SeekDat(Def)',Self);
  rv:=My_pr.DWSToRec(sDef); result := (TrimUpper(rv.Name)=nmfUp) and (rv.AType=dwtArray);
  if result then
    if rv.SvType=dwsNoFix then Dat:=StrDeshifr(rv.AValue)
    else begin
      ra:=TRecDBDef.GetArrDef(rv.AValue); Dat:=ra.Dat;
      if lWnd then begin
        Prm.Wnd:=ra.Wnd; dw.dw.ReplaceNameRecSelf(Prm.Wnd,'',rdb.NameRec);
      end;
    end;
  DelStack;
end;

function TArrGetFld.SeekDat(r: TCustomRec; const nmf: string; lWnd: boolean = false): boolean;
var nmfUp: string;
  i: longint;
begin
	AddStack('TArrGetFld.SeekDat',Self);
  result:=false;
  if r is TRecDBDef then begin
    Dat:=''; nmfUp:=TrimUpper(nmf);
    with TRecDBDef(r) do for i:=0 to FldDef.Count-1 do if SeekDat(FldDef[i],nmfUp,lWnd) then begin
      result:=true; break;
    end;
  end;
  rdb.InitFldDef(dwdefGotoRec); rdb.OpenRec;
  DelStack;
end;

{ TArrGet }
constructor TArrGet.Create;
begin
	AddStack('TArrGet.Create',Self);
  if not(csDesigning in ComponentState) then
    if GetFirst=nil then TDWPrm.VarCreate([RDBArr],TNone.PrInterDopGetVar,TNone.PrInterDopGetVarIgnore);
	Inherited Create(AOwner);
  Data:=nil;
  DelStack;
end;

procedure TArrGet.SetData;
begin
  AddStack('TArrGet.SetData',Self);
  FData:=Value; RVid:=IfThen(not Assigned(FData),'Массив');
  DelStack;
end;

procedure TArrGet.CreateObj;
begin
	AddStack('TArrGet.CreateObj',Self);
  DestroyObj(tf); sb:=sbCreate(tf,tf); sb.KeyDblClick:=K_F5; f:=TArrGetFld.CreateNum(tf,true);
  if Assigned(FWnd) then with f.dw do begin
    OnFrmHide:=FWnd.OnFrmHide;
    OnFldEnter:=FWnd.OnFldEnter; OnFldExit:=FWnd.OnFldExit; OnFldCheck:=FWnd.OnFldCheck; OnFldChange:=FWnd.OnFldChange;
    OnPnlValid:=FWnd.OnPnlValid; OnPnlAskCancel:=FWnd.OnPnlAskCancel; OnPnlEscape:=FWnd.OnPnlEscape;
    OnPnlAfterEscape:=FWnd.OnPnlAfterEscape;
  end;
  inherited CreateObj(tf);
  DelStack;
end;

function TArrGet.sbCreate;
begin
  AddStack('TArrGet.sbCreate');
  result:=TStringBrowl.Create(AOwner);
  with result do begin
	  Parent:=AParent; FixedCols:=0; OnCalcZn:=sbCalcZn; //onPaint:=sbPaint;
    onBeforeDrawCell:=sbBeforeDrawCell; onDrawCell:=sbDrawCell;
    onMouseDown:=sbMouseDown; onMouseMove:=sbMouseMove; onMouseUp:=sbMouseUp;
    onDblClick:=sbDblClick;
    Init;
  end;
  DelStack;
end;

procedure TArrGet.ReCreateObj;
var i: longint;
  r: TDWVidRec;
  s: string;
  a: array[1..1] of string;
	cr: TCustomRec;
  ordb: TRecDBDef;
  Options: TFldFillOptions;
begin
	AddStack('TArrGet.ReCreateObj',Self);
  ordb:=CurRdbArr;
  try
    if AssignObj(tf) then begin
      f.Prm:=MaskToPrm(tf.Mask);
      if RecName(tf.NameRec,cr,TRecDBDef) then begin
        s:=TrimUpper(tf.NameRecFld);
        with TRecDBDef(cr) do for i:=0 to FldDef.Count-1 do with DWSToRec(i) do
          if (SvType=dwsFix) and (TrimUpper(Name)=s) then begin
            f.CodArr:=AValue; f.Prm.Wnd:=TRecDBDef.GetArrDef(f.CodArr).Wnd; break;
          end;
      end;
      f.dw.dw.ReplaceNameRecSelf(f.Prm.Wnd,'',f.rdb.NameRec);
      s:=f.rdb.ArrValue; f.ls.Clear; f.rdb.CloseRec;
      with f.dw.dw do begin
        LoadFromStr(f.Prm.Wnd); f.ls.Text:=Fields; f.lShowEd:=false;
        for i:=0 to f.ls.Count-1 do
          if StrToBoolean(DEGetArrParam(f.ls[i])[deNoReadOnly]) then begin
            f.lShowEd:=true; break;
          end;
      end;
      f.SeekDat(RecName(tf.NameRec),tf.NameRecFld);
      f.rdb.ArrValue:=s; f.ls.Text:=f.Dat; i:=0;
      while i<f.ls.Count do begin
        r:=DWSToRec(f.ls[i]); LsArrFill(r.DopPrm,a,',');
        if StrToBoolean(a[1]) then f.ls.Delete(i)
        else begin
          f.ls[i]:=f.rdb.DWVarName(r.Name); Inc(i);
        end;
      end;
      Options:=[fldfRDBSeek];
      if not Assigned(FWnd) then Include(Options,fldfNoSeekPrimGet);
      f.ls.Fill(nil,Options); f.ls.BrCreate(sb);
      inherited ReCreateObj(tf);
    end;
  finally
    CurRdbArr:=ordb;
  end;
  DelStack;
end;

procedure TArrGet.PaintObj;
var ordb: TRecDBDef;
begin
	AddStack('TArrGet.PaintObj',Self);
  ordb:=CurRdbArr;
  try
    if AssignObj(tf) then begin
      sb.SetBounds(BevelFld,BevelFld,tf.Width-BevelFld2,tf.Height-BevelFld2);
      sb.Color:=tf.Color1;
    end;
  finally
    CurRdbArr:=ordb;
  end;
  DelStack;
end;

function TArrGet.SizeAuto;
var ordb: TRecDBDef;
begin
	AddStack('TArrGet.SizeAuto',Self);
  ordb:=CurRdbArr;
  try
    result := inherited SizeAuto(tf,Opt);
    if AssignObj(tf) then begin
      if tfszWidth in Opt then result.cX:=sb.GridsWidth+SysMetric.iScrollWidth;
      if tfszHeight in Opt then result.cY:=sb.RowHeights[0]+4+(sb.RowHeights[1]+1)*IfThen(tf.CharHeight<0,1,3);
    end;
  finally
    CurRdbArr:=ordb;
  end;
  DelStack;
end;

function TArrGet.GetValue;
var ordb: TRecDBDef;
begin
	AddStack('TArrGet.GetValue',Self);
  ordb:=CurRdbArr;
  try
    if AssignObj(tf) then result:=f.rdb.ArrValue else result:='';
  finally
    CurRdbArr:=ordb;
  end;
  DelStack;
end;

procedure TArrGet.SetValue;
var ordb: TRecDBDef;
begin
	AddStack('TArrGet.SetValue',Self);
  ordb:=CurRdbArr;
  try
    if AssignObj(tf) then
      if f.rdb.ArrValue<>v then begin
        f.rdb.ArrValue:=v; sbFill(sb);
      end;
  finally
    CurRdbArr:=ordb;
  end;
  DelStack;
end;

procedure TArrGet.sbFill;
var i,l: longint;
begin
  AddStack('TArrGet.sbFill',Self);
  l:=f.rdb.ArrCount;
  with ssb do if l=0 then Init
  else begin
  	RowCount:=FixedRows+l;
    for i:=1 to l do begin
      f.rdb.GotoRec(i); CurStUpdate(FixedRows+i-1); 
    end;
  end;
  ssb.Row:=ssb.FixedRows;
  DelStack;
end;

procedure TArrGet.DoEnter;
var ordb: TRecDBDef;
begin
	AddStack('TArrGet.DoEnter',Self);
  ordb:=CurRdbArr;
  try
    inherited DoEnter(tf);
    if AssignObj(tf) then begin
      GetParentForm(tf).ActiveControl:=sb; f.lWnd:=false;
      if not(ogReadOnly in tf.Options) then SetKeys(FormKeyLb(tf));
    end;
  finally
    CurRdbArr:=ordb;
  end;
  flMove:=false;
  DelStack;
end;

procedure TArrGet.SetKeys;
var i: longint;
begin
  AddStack('TArrGet.SetKeys',Self);
  if Assigned(tl) then with tl do begin
  	DelKey(K_All,'arr');
    if f.lWnd
    then SetKeys([K_Esc,K_F10,K_Ctrl_F4],'Выход','',ProcKey,'arr',kmFile)
    else SetKey(K_Ctrl_F4,'В окне','Просмотр в отдельном окне',ProcKey,'arr',kmFile);
    if not f.Prm.NoApp then SetKey(K_F4,'Скопировать','',ProcKey,'arr',kmList);
    if f.lShowEd then SetKey(K_F5,'Редактировать','',ProcKey,'arr',kmList);
    if not f.Prm.NoApp then begin
      SetKey(K_F7,'Добавить','',ProcKey,'arr',kmList);
      if f.lShowEd then SetKey(K_Ctrl_F7,'','Добавление потоком',ProcKey,'arr',kmList);
      SetKey(K_F8,'Удалить','',ProcKey,'arr',kmList);
    end;
    SetKey(K_Ctrl_Up,'','Переместить выше',ProcKey,'arr',kmList);
    SetKey(K_Ctrl_Down,'','Переместить ниже',ProcKey,'arr',kmList);
  	for i:=low(f.Prm.Keys) to high(f.Prm.Keys) do
    	with f.Prm.Keys[i] do SetKey(Key,txt,hnt,ProcKeyDop,'arr',kmServic);
    ReDrw;
  end;
  DelStack;
end;

procedure TArrGet.DoExit;
var tl: TKeyLb;
begin
	AddStack('TArrGet.DoExit',Self);
  if FormKeyLb(tf,tl) then with tl do begin
  	DelKey(K_All,'arr'); ReDrw;
  end;
  inherited DoExit(tf);
  DelStack;
end;

class procedure TArrGet.VarCreate;
begin
  AddStack('TArrGet.VarCreate');
  FreeAndNil(lsVarDop);
  DelStack;
end;

procedure TArrGet.ProcKey;
var tf: TFldEdit;
	function EdWnd(op: TDWActionList; const Capt: string): boolean;
  var oLogVid: longint;
  begin
    AddStack('TArrGet.KeyLb1ProcKey.EdWnd',Self);
    if f.lShowEd then begin
      CopyFromVArr(f.dw.Params,[aDWActionPrm[op]]); f.dw.dw.DoSetting(f.Prm.Wnd);
      oLogVid:=ProgPswd.CngLogVid(logvNone,true);
      result:=f.dw.Execute(f.Prm.Wnd,SectIni(arsiEdit,f.CodArr),f.rdb,'Массив: '+Trim(f.CodArr),[0],
        IfThen(f.dw.dw.Zgl='',FRup(Capt),f.dw.dw.Zgl+' ('+Capt+')'),desAlways,false).Saved;
      ProgPswd.CngLogVid(oLogVid,true);
      if result then result:=AssignObj(tf);
    end
    else result:=true;
    DelStack;
  end;
  procedure fShow(f: TFormNul);
  begin
    AddStack('TArrGet.KeyLb1ProcKey.fShow',Self);
    f.RestIniForm; f.MainRebuild; f.ShowModal; f.SaveIniForm;
    DelStack;
  end;
var fl: boolean;
	i,oLogVid: longint;
  v: variant;
  ordb: TRecDBDef;
  s: string;
begin
	AddStack('TArrGet.ProcKey',Self);
  ordb:=CurRdbArr;
  try
    if tfAssignObj(tw,tf) then begin
      if (f.rdb.ArrCount>0) or (Key in [K_F7,K_F10,K_Esc,K_Ctrl_F4,K_Ctrl_F7])
      then with TStringBrowl(tw) do case Key of
        // Добавить/скопировать
        K_F4,K_F7: begin
          fl := Key=K_F4;
          if fl then f.rdb.GotoRec(Row-FixedRows+1);
          f.rdb.NewRec(IfThen(fl,newrCopy));
          if EdWnd(IfThen(fl,dwaCopy,dwaAdd),'добавление') then begin
            f.rdb.AppRec;
            if f.rdb.ArrCount>1 then begin
              IncRowCount; Row:=RowCount-1;
            end;
            CurStUpdate; tfUpd(tw);
          end;
        end;
        // Редактировать
        K_F5: begin
          f.rdb.GotoRec(Row-FixedRows+1);
          if EdWnd(dwaEdit,'редактирование') then begin
            f.rdb.UpdateRec; CurStUpdate; tfUpd(tw);
          end;
          flMove:=false;
        end;
        // Удалить
        K_F8: begin
          oLogVid:=ProgPswd.CngLogVid(logvNone,true); f.rdb.GotoRec(Row-FixedRows+1);
          s:=TRecDBDef.GetArrDef(f.CodArr).FDel;
          if empty(s)
            then fl:=true
          else if EvalStringsChk(v,[null],s,'Действия при удалении','L')
            then fl:=v
          else fl:=false;
          if fl then
            if Ask(amsDel) then begin
              f.rdb.DelRec('',[delLog]);
              if f.rdb.ArrCount=0 then Init
              else begin
                for i:=Row+1 to RowCount-1 do Rows[i-1].Assign(Rows[i]);
                IncRowCount(-1);
              end;
              tfUpd(tw);
            end;
          ProgPswd.CngLogVid(oLogVid,true);
        end;
        // Выход из просмотра в отдельном окне
        K_F10,K_Esc: begin
          f.lWnd:=false; sbFill(sb); sb.Row:=f.fSb.sb.Row; f.fSb.ModalResult:=mrCancel;
        end;
        // Просмотр в отдельном окне
        K_Ctrl_F4: if f.lWnd then f.fSb.KeyLb1.ExecKey(K_Esc)
        else begin
          f.lWnd:=true; tfCur:=tf;
          if CreateForm(TArrBrowl,f.fSb) then with f.fSb do begin
            fLs:=f; TKeyMenu.Create(f.fSb); sb:=sbCreate(f.fSb,RbPanel2);
            SetKeys(KeyLb1); FPanel.SetSchemForm(f.fSb);
          end;
          f.fSb.Caption:='Просмотр массива "'
            +TRecDBDef(RecName(tf.NameRec)).DWVarName(tf.NameRecFld)+'"';
          f.fSb.sb.ColZn.Assign(sb.ColZn); sbFill(f.fSb.sb); f.fSb.sb.Row:=sb.Row;
          fShow(f.fSb); f.fSb.NoLimit:=false;
        end;
        // Добавление потоком
        K_Ctrl_F7: if f.lShowEd then begin
          oLogVid:=ProgPswd.CngLogVid(logvNone,true);
          if CreateForm(TArrStm,f.fStm) then with f.fStm do begin
            fLs:=f; pnEdit.OnEscape:=PnEditEscape; pnEdit.OnAfterEscape:=fLs.dw.OnPnlAfterEscape;
            sb.OnCalcZn:=sbCalcZn; sb.OnUnKey:=sbUnKey;
          end;
          f.dw.FldOnPanel(f.Prm.Wnd,SectIni(arsiEdit,f.CodArr),'Массив: '+Trim(f.CodArr),f.fStm.pnEdit);
          f.fStm.pnEdit.FillFldList; f.fStm.LastRecno:=0; v:=tf.VarValue;
          f.fStm.Caption:=IfThen(empty(f.dw.dw.Zgl),'Добавление',f.dw.dw.Zgl+' (добавление)');
          if f.fStm.PnEdit.FieldCount>0 then begin
            f.ls.BrCreate(f.fStm.sb); f.dw.Active:=true;
            try
              fShow(f.fStm);
            finally
              f.dw.Active:=false;
            end;
            if f.fStm.LastRecno>0 then begin
              sbFill(pointer(tw)); Row:=f.fStm.LastRecno+FixedRows-1; tf.Change(v,false); tfUpd(tw);
            end;
          end;
          f.fStm.NoLimit:=false; ProgPswd.CngLogVid(oLogVid,true);
        end;
        // Выше
        K_Ctrl_Up: Move(Row,Row-1,tw);
        // Ниже
        K_Ctrl_Down: Move(Row,Row+1,tw);
      end;
    end;
  finally
    CurRdbArr:=ordb;
  end;
  DelStack;
end;

procedure TArrGet.ProcKeyDop;
var i: longint;
	av: variant;
  ordb: TRecDBDef;
begin
	AddStack('TArrGet.ProcKeyDop',Self);
  ordb:=CurRdbArr;
  try
    if tfAssignObj(tw) then for i:=high(f.Prm.Keys) downto low(f.Prm.Keys) do
      if f.Prm.Keys[i].Key=Key then begin
        av:=FProcLoad(f);
        if f.lWnd then sb.Row:=f.fSb.sb.Row;
        f.rdb.GotoRec(sb.Row-sb.FixedRows+1);
        if EvalStringsChk(av,[f.Prm.Keys[i].Prm,av],f.Prm.KeyFml,'Формула дополнительных клавиш') then
        if tfAssignObj(tw) then
          if Key in [K_F4,K_F5,K_F7,K_F8,K_F10,K_Esc,K_Ctrl_F4,K_Ctrl_F7,K_Ctrl_Up,K_Ctrl_Down] then begin
            if av then ProcKey(Key,tw);
          end
          else if MyVarType(av)=varArray then begin
            f.rdb.ArrValue:=''; FProcSave(f,av); sbFill(sb);
            if f.lWnd then begin
              sbFill(f.fSb.sb); f.fSb.sb.Row:=sb.Row;
            end;
          end
          else begin
            f.rdb.UpdateRec; sb.CurStUpdate;
            if f.lWnd then f.fSb.sb.CurStUpdate;
          end;
        break;
      end;
  finally
    CurRdbArr:=ordb;
  end;
  DelStack;
end;

class function TArrGet.SectIni;
const a: array[TArrSaveIniList] of string = ('Edit','List','Stm');
begin
  AddStack('TArrGet.SectIni');
  result:=Trim(CodArr);
  if result<>'' then IncL(result,'Arr'+a[si]+'.');
  DelStack;
end;

function TArrGet.tfSeek;
var ssb: TStringBrowl;
begin
  AddStack('TArrGet.tfSeek',Self);
  ssb:=pointer(Sender); result:=IfThen(ssb.Owner is TFldEdit,ssb.Owner,tfCur);
  DelStack;
end;

function TArrGet.tfAssignObj(Sender: TObject; var tf: TFldEdit): boolean;
begin
  tf:=tfSeek(Sender); result:=AssignObj(tf);
end;

function TArrGet.tfAssignObj(Sender: TObject): boolean;
var tf: TFldEdit;
begin
  result:=tfAssignObj(Sender,tf);
end;

procedure TArrGet.sbMouseDown;
var ACol: longint;
begin
	AddStack('TArrGet.sbMouseDown',Self);
	if not flMove and (Button=mbLeft) then with TStringBrowl(Sender) do begin
  	//addmsgfile('TArrGet.sbMouseDown');
	  MouseToCell(X,Y,ACol,ARow);
    flMove := (ARow>0) and (CellRect(ACol,ARow).Bottom+4<Height); NoSel:=false;
  end;
  DelStack;
end;

procedure TArrGet.sbMouseMove;
var ACol,nr: longint;
begin
	AddStack('TArrGet.sbMouseMove',Self);
	if flMove then begin
	  TStringBrowl(Sender).MouseToCell(X,Y,ACol,nr);
    if (nr>0) and (nr<>ARow) then begin
		  Move(ARow,nr,Sender); ARow:=nr;
    end;
  end;
  DelStack;
end;

procedure TArrGet.sbMouseUp;
begin
	flMove:=false;
end;

procedure TArrGet.sbDblClick;
begin
	AddStack('TArrGet.sbDblClick',Self);
  //addmsgfile('TArrGet.sbDblClick');
  //flMove:=false;
	TTimerOne.CreateProc(TimerDblClick,Self);
  DelStack;
end;

procedure TArrGet.TimerDblClick;
begin
  flMove:=false;
end;

// Переместить запись с позиции oi на ni
procedure TArrGet.Move;
begin
	AddStack('TArrGet.Move',Self);
  with TStringBrowl(Sender) do if ListMoveItem(oi,ni,FixedRows,RowCount-1,PrMove,[LongInt(Sender)]) then begin
    Row:=ni; tfUpd(Sender);
  end;
  DelStack;
end;

procedure TArrGet.PrMove;
var s: string;
begin
	AddStack('TArrGet.PrMove',Self);
  with StringBrowlVar(av[0]) do begin
    s:=Rows[ni].Text; Rows[ni].Assign(Rows[oi]); Rows[oi].Text:=s;
    f.rdb.ArrExchange(ni-FixedRows+1,oi-FixedRows+1);
  end;
  DelStack;
end;

procedure TArrGet.tfUpd;
var tf: TFldEdit;
  ordb: TRecDBDef;
begin
  AddStack('TArrGet.tfUpd',Self);
  ordb:=CurRdbArr;
  try
    if tfAssignObj(Sender,tf) then tf.Value:=f.rdb.ArrValue;
  finally
    CurRdbArr:=ordb;
  end;
  DelStack;
end;

function TArrGet.MayDoKey;
var ordb: TRecDBDef;
begin
	AddStack('TArrGet.MayDoKey',Self);
  ordb:=CurRdbArr;
  try
    result := inherited MayDoKey(tf,Key);
    if AssignObj(tf) then result:=not(((Key in [K_Down,K_PgDn]) and (sb.Row<sb.RowCount-1))
        or ((Key in [K_Up,K_PgUp]) and (sb.Row>sb.FixedRows)));
  finally
    CurRdbArr:=ordb;
  end;
  DelStack;
end;

function TArrGet.AssignObj;
{var cr: TCustomRec;
	i: longint;
  nmf: string;}
{var s: string;
	ost: longint;}
begin
	{ost:=}AddStack('TArrGet.AssignObj',Self);
	sb:=nil; f:=nil; result:=false;
  if tf.ComponentCount>=2 then
  	if IsClass(tf.Components[0],TStringBrowl,pointer(sb))
    and IsClass(tf.Components[1],TArrGetFld,pointer(f)) then begin
{try
	s:=CurRdbArr.NameRec;
except
  SetStack(ost);
  s:='';
end;
if s <> f.rdb.NameRec then begin
	s:='';
end;}
      CurRdbArr:=f.rdb; result:=true;
      {f.Prm:=MaskToPrm(tf.Mask);
      if RecName(tf.NameRec,cr,TRecDBDef) then begin
        nmf:=TrimUpper(tf.NameRecFld);
        with TRecDBDef(cr) do for i:=0 to FldDef.Count-1 do with DWSToRec(i) do
          if Fixed and (TrimUpper(Name)=nmf) then begin
            f.CodArr:=AValue; f.Prm.Wnd:=TRecDBDef.GetArrDef(f.CodArr).Wnd; break;
          end;
      end;
      f.dw.dw.ReplaceNameRecSelf(f.Prm.Wnd,'',f.rdb.NameRec);}
    end;
  DelStack;
end;

function TArrGet.sbCalcZn;
var ordb: TRecDBDef;
begin
	AddStack('TArrGet.sbCalcZn',Self);
  ordb:=CurRdbArr;
  try
    if tfAssignObj(Sender) then result:=f.ls.BrCalc(ACol) else result:='';
  finally
    CurRdbArr:=ordb;
  end;
  DelStack;
end;

procedure TArrGet.sbBeforeDrawCell;
var tf: TFldEdit;
  ordb: TRecDBDef;
begin
	AddStack('TDtblStm.sbBeforeDrawCell',Self);
  ordb:=CurRdbArr;
  try
    if tfAssignObj(Sender,tf) then
      if (gdSelected in State) and not tf.Active then with TStringBrowl(Sender) do begin
        Canvas.Brush.Color:=Color; Canvas.Font.Assign(Font);
      end;
  finally
    CurRdbArr:=ordb;
  end;
  DelStack;
end;

procedure TArrGet.sbDrawCell;
var ordb: TRecDBDef;
begin
	AddStack('TDtblStm.sbDrawCell',Self);
  ordb:=CurRdbArr;
  try
    if tfAssignObj(Sender) then f.ls.BrBool(pointer(Sender),ACol,ARow,Rect,State);
  finally
    CurRdbArr:=ordb;
  end;
  DelStack;
end;

function TArrGet.MaskSearch;
var a: TDWSearchAInfo;
	Prm: TArrGetPrm;
begin
	AddStack('TArrGet.MaskSearch',Self);
  Prm:=MaskToPrm(Mask);
  result:=DataWinSearchIdent(DataWinCreate,Prm.Wnd,SubStr,a,lIdent); DataWinFree;
  if not result then result:=FindInStr(Prm.KeyFml,SubStr);
  DelStack;
end;

function TArrGet.MaskReplace;
  function IncRes(var res: longint; cnt: longint): boolean;
  begin
    AddStack('TArrGet.MaskReplace.IncRes',Self);
    result := cnt>=0;
    if result then Inc(res,cnt) else res:=cnt;
    DelStack;
  end;
var Prm: TArrGetPrm;
	f: TArrGetFld;
begin
	AddStack('TArrGet.MaskReplace',Self);
  f:=TArrGetFld.CreateNum(Application.MainForm);
  try
    Prm:=MaskToPrm(Mask); result:=0;
    if IncRes(result,DataWinReplaceIdent(DataWinCreate,Prm.Wnd,stSource,sRepl,IfThen(not lIdent,gfrNoIdent),PrRepl,pav)) then
    	if IncRes(result,ReplaceInStr(Prm.KeyFml,stSource,sRepl)) then Mask:=PrmToMask(Prm);
    DataWinFree;
  finally
    f.Free;
  end;
  DelStack;
end;

procedure msfFree;
begin
  AddStack('ArrGet.msfFree');
  if Assigned(msf) then begin
    msf.ls.Clear; FreeAndNil(msf); TDWPrm.VarFree(RDBArr);
  end;
  DelStack;
end;

function TArrGet.MaskProp;
begin
  AddStack('TArrGet.MaskProp',Self);
  result := inherited MaskProp(Capt,Mask,r,nmf,Opt);
  msfFree;
  DelStack;
end;

function TArrGet.MaskTrans;
	function nPrm: longint;
  begin
    AddStack('TArrGet.MaskTrans.nPrm',Self);
    result:=IfThen(msrv.SvType<>dwsFix,1);
    DelStack;
  end;
var s: string;
	i: longint;
begin
  AddStack('TArrGet.MaskTrans',Self);
  result := inherited MaskTrans(av,r,nmf);
	if MyVarType(av)=varArray then begin
    if Assigned(msf) then begin
      msf.Prm.NoApp:=IsNilc(av[nPrm+1],false);
      msf.Prm.KeyFml:=IsNilc(av[nPrm+3],'');
      result:=PrmToMask(msf.Prm);
    end;
  end
  else begin
    if IsClass(r,TRecDBDef,pointer(msrd)) then begin
      msf:=TArrGetFld.CreateNum(Self); msf.ls.Text:=msrd.DWTrans; s:=TrimUpper(nmf);
      for i:=0 to msf.ls.Count-1 do begin
        msrv:=DWSToRec(msf.ls[i]);
        if (TrimUpper(msrv.Name)=s) and (msrv.AType=dwtArray) then begin
          msCapt:='Настройка окна редактирования массива "'+msf.rdb.DWVarName(nmf)+'"';
          msnom:=i; msf.Prm:=MaskToPrm(av); result:=VarArrayCreate([1,nPrm+3],varVariant);
          if msrv.SvType=dwsFix then msf.Prm.Wnd:=''
          else result[1]:=VarArrayOf([mpBut,'Настройка окна редактирования',
          	false,LongInt(@TNone.ButWndClick),LongInt(@TNone.ButWndPaint)]);
          result[nPrm+1]:=VarArrayOf([mpBool,'Запретить добавление и удаление',msf.Prm.NoApp]);
          result[nPrm+2]:=VarArrayOf([mpCustom,'Дополнительные клавиши','',LongInt(TArrKeyGet.CreateOne(TCustomGet(ArrKeyGet),Application.MainForm))]);
          result[nPrm+3]:=VarArrayOf([mpButForm,ButPrm2Mask('Формула дополнительных клавиш','10'),msf.Prm.KeyFml,6400]);
          RDBArrv.Seek(RDBArrv.TblFldName(fARRV)+'='+QQs(msrv.AValue));
          TDWPrm.VarCreate(RDBArr);
          break;
        end;
      end;
    end;
    if MyVarType(result)<>varArray then begin
      msfFree; meserr('Вид ввода "'+RVid+'" возможен только для данных типа "массив"');
    end;
  end;
  DelStack;
end;

function ArrWndVar(const Wnd: string): string;
var a: TArrStr;
  dw: TDataWin;
  i,l: longint;
begin
  AddStack('ArrGet.ArrWndVar');
  dw:=TDataWin.aGet(Wnd);
  try
    l:=LsArrDynamic(dw.Fields,a,CRLF);
    for i:=0 to l-1 do a[i]:=DEGetArrParam(a[i])[deNameRecFld];
    result:=ArrayAsList(a,',',l);
  finally
    DataWinFree
  end;
  DelStack;
end;

class function TArrGet.MaskTextReadOnly;
begin
	result:=true;
end;

class function TArrGet.MaskCngClear;
begin
	result:=true;
end;

class function TArrGet.MaskSortMode;
begin
  result:=smColumns;
end;

class procedure TArrGet.FMaskView;
var Prm: TArrGetPrm;
	s: string;
  i: longint;
begin
  AddStack('TArrGet.FMaskView');
  Prm:=MaskToPrm(Mask); s:='';
  for i:=low(Prm.Keys) to high(Prm.Keys) do IncD(s,','+KeyToTxt(Prm.Keys[i].Key));
  Mask:=DlmBetween(ArrWndVar(Prm.Wnd),IfThen(s<>'','клавиши:'+Copy(s,2,MaxInt)),';');
  DelStack;
end;

procedure TArrGet.MaskPrn;
var Prm: TArrGetPrm;
	i: longint;
begin
	AddStack('TArrGet.MaskPrn',Self);
  Prm:=MaskToPrm(Mask);
  if Length(Prm.Keys)>0 then begin
		LsPrn.Add('Дополнительные клавиши:');
    for i:=low(Prm.Keys) to high(Prm.Keys) do with Prm.Keys[i] do
    	LsPrn.Add(' '+DlmBetween(KeyToTxt(Key)+'('+Prm+')',Txt+BrackNoEmp(Hnt),' - '));
  end;
  LsPrnAdd('Формула дополнительных клавиш',Prm.KeyFml,LsPrn);
  DelStack;
end;

procedure TArrGet.FMaskHelp;
const Dlm = '+"'+UnDelim+'"+;';
var n: byte;
  s: string;
begin
  AddStack('TArrGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+14);
  Inc(n); CopyFrom(ht.Dat[n],HelpStruct(['ВОкне','Клавиши','Формула','БезДоб']));
  Inc(n); CopyFrom(ht.Dat[n],HelpIf('«Просмотр в отдельном окне»','"+"','""')+Dlm);
  s:=HelpBoldStr('«Список клавиш»');
  Inc(n); CopyFrom(ht.Dat[n],'StrShifr('+HelpArrayAsList(s,'ПЕРЕВОД_СТРОКИ',false)+')'+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],'StrShifr('+HelpBoldStr('«Формула»','PrmArrKey',HelpFileStd)+')'+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpBool('«Запретить добавление и удаление»'));
  Inc(n); ht.Dat[n]:=nil;
  Inc(n); CopyFrom(ht.Dat[n],s+' - массив, состоящий из элементов нижеследующей структуры:');
  Inc(n); CopyFrom(ht.Dat[n],HelpStruct(['УпрКлав','Клав','Текст','Подсказка','Параметр']));
  Inc(n); CopyFrom(ht.Dat[n],HelpNum(HelpBoldStr('«Управляющая клавиша»',HelpTblVarName('УПРКЛАВ'),hlnkTblFix),false)+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpNum(HelpBoldStr('«Клавиша»',HelpTblVarName('КЛАВ'),hlnkTblFix),false)+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr('«Текст»')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr('«Подсказка»')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr('«Параметр»'));
  DelStack;
end;

class function TArrGet.RestValType;
begin
  result:=grvNone;
end;

function TArrGet.DWFldUnAllowType;
begin
  AddStack('TArrGet.DWFldUnAllowType',Self);
  {if csDesigning in ComponentState
  then result:=inherited DWFldUnAllowType(Mask)
  else} result:=[low(aDWFld)..high(aDWFld)]-[dwtArray];
  DelStack;
end;

procedure TArrGet.UpdateRec;
var aw: TArrStr;
  iw: longint;
  ap: TDEPrmStr;
  g: TCustomGet;
  ordb: TRecDBDef;
begin
  AddStack('TArrGet.UpdateRec',Self);
  inherited UpdateRec(tf,Oper);
  if Oper in [feuBeforeUpd,feuAfterUpd] then begin
    ordb:=CurRdbArr;
    try
      if AssignObj(tf) then if f.SeekDat(tf.PNameRec,tf.NameRecFld,true) then begin
        f.dw.dw.LoadFromStr(f.Prm.Wnd);
        for iw:=0 to LsArrDynamic(f.dw.dw.Fields,aw,CRLF)-1 do begin
          ap:=DEGetArrParam(aw[iw]);
          if NameGet(g,ap) then begin
            ReAssignGet(g,ap[deMask]); g.UpdateArr(f.rdb,ap,Oper);
          end;
        end;
      end;
    finally
      CurRdbArr:=ordb;
    end;
  end;
  DelStack;
end;

procedure TArrGet.HookProc;
var ka: string;
begin
	AddStack('TArrGet.HookProc',Self);
	inherited HookProc(tf,Message);
  if Message.Msg=WM_GETCHANGED then with TWMGetChanged(Message) do
  	if tf.curget=Get then case nOper of
      mgArrCng: begin
        ka:=RDBArrv[fARRV]; GetParentForm(tf).Perform(WM_ARRCHANGE,LongInt(@ka),0);
        tf.PNameRecClr; Result:=1;
      end;
      mgArrDel: begin
        tf.AssignGet; Result:=1;
      end;
    end;
  DelStack;
end;

function TArrGet.MinSize;
var ordb: TRecDBDef;
begin
  AddStack('TArrGet.MinSize',Self);
  ordb:=CurRdbArr;
  try
    result := inherited MinSize(tf);
    if AssignObj(tf) then result.cY:=sb.GridsHeight(sb.FixedRows)+SysMetric.iScrollWidth;
  finally
    CurRdbArr:=ordb;
  end;
  DelStack;
end;

class function TArrGet.MaskToPrm;
var a: array[1..5] of string;
	a1: TArrStr;
  i: longint;
begin
  AddStack('TArrGet.MaskToPrm');
  LsArrFill(Mask,a,UnDelim);
  with result do begin
    Wnd:=a[1];
    // В старых описаниях возможен параметр "Редактировать в отдельном окне"
    if StrToChar(Wnd)='+' then Delete(Wnd,1,1);
    StrDeShifrSelf(Wnd); KeyFml:=StrDeshifr(a[3]); NoApp:=StrToBoolean(a[4]); StrDeShifrSelf(a[2]);
    if empty(a[2]) then Keys:=nil
    else begin
      i:=LsArrDynamic(a[2],a1,CRLF); SetLength(Keys,i);
      for i:=0 to i-1 do with Keys[i] do begin
        LsArrFill(a1[i],a,UnDelim); Key:=ShiftToKey(Int0(a[1]),Int0(a[2]));
        txt:=a[3]; hnt:=a[4]; prm:=a[5];
      end;
    end;
  end;
  DelStack;
end;

class function TArrGet.PrmToMask;
var Shift: TKeyShftList0;
  i,Key: longint;
begin
  AddStack('TArrGet.PrmToMask');
  result:='';
  with Prm do begin
    for i:=low(Keys) to high(Keys) do begin
      KeyToShift(Keys[i].Key,Shift,Key);
    	result:=ArrayAsList([StrNum(result+CRLF,Shift),IntToStr(Key),Keys[i].txt,Keys[i].hnt,
        Keys[i].prm],UnDelim);
    end;
    result:=StrShifr(Wnd)+UnDelim
      +StrShifr(Copy(result,lCRLF1,MaxInt))+UnDelim+StrShifr(KeyFml)+UnDelim+bStr[NoApp];
  end;
  DelStack;
end;

{ TArrStm }
function TArrStm.BeforeEdit;
begin
	AddStack('TArrStm.BeforeEdit',Self);
  with fLs do begin
  	rdb.NewRec; dw.FrmShow(fStm);
  end;
  result := inherited BeforeEdit(lFirst);
  DelStack;
end;

function TArrStm.PnEditValid;
begin
	AddStack('TArrStm.PnEditValid',Self);
  with fLs do if dw.PnlValid(Sender) then begin
    fLs.rdb.AppRec(true); TFldEdit(Owner).Write; LastRecno:=rdb.Recno; dw.FrmHide(fStm);
    result := inherited PnEditValid(Sender);
  end
  else result:=false;
  DelStack;
end;

procedure TArrStm.PnEditEscape;
begin
	AddStack('TArrStm.PnEditEscape',Self);
	with fLs,dw do begin
    PnlEscape(Sender,Action);
    if Action=caHide then FrmHide(fStm);
  end;
  DelStack;
end;

procedure TArrStm.sbUnKey;
begin
	AddStack('TArrStm.sbUnKey',Self);
  with fLs.rdb do
    if lWrite then UnKey:=Recno
    else if UnKey=0 then NewRec else GotoRec(UnKey);
  DelStack;
end;

procedure TArrStm.sbDrawCell;
begin
	AddStack('TArrStm.sbDrawCell',Self);
	inherited;
  fLs.ls.BrBool(sb,ACol,ARow,Rect,State);
  DelStack;
end;

function TArrStm.sbCalcZn;
begin
	AddStack('TArrStm.sbCalcZn',Self);
  result:=fLs.ls.BrCalc(ACol);
  DelStack;
end;

procedure TArrStm.FormDestroy;
begin
	AddStack('TArrStm.FormDestroy',Self);
  if Assigned(fLs) then fLs.fStm:=nil;
  inherited FormDestroy(Sender);
  DelStack;
end;

procedure TArrStm.WMSaveIni;
begin
  AddStack('TArrStm.WMSaveIni',Self);
  if Assigned(fLs) then Msg.pSection^:=TArrGet.SectIni(arsiStm,fLs.CodArr);
  DelStack;
end;

{ TArrBrowl }
procedure TArrBrowl.FormDestroy;
begin
	AddStack('TArrBrowl.FormDestroy',Self);
  if Assigned(fLs) then fLs.fSb:=nil;
  inherited FormDestroy(Sender);
  DelStack;
end;

procedure TArrBrowl.WMSaveIni;
begin
  AddStack('TArrBrowl.WMSaveIni',Self);
  if Assigned(fLs) then Msg.pSection^:=TArrGet.SectIni(arsiList,fLs.CodArr);
  DelStack;
end;

{ TArrLogCompare }
class function TArrLogCompare.ListCreate;
var f: TArrGetFld;
begin
  AddStack('TArrLogCompare.ListCreate');
  with PLogTrnsValPrm(pv)^ do f:=TArrGetFld.CreateNum(Sender,nmf,[arfoNum,arfoWnd]);
  result:=f; f.rdb.OnDWRdbSeek:=nil; f.rdb.ArrValue:=Value;
  DelStack;
end;

class procedure TArrLogCompare.ListDestroy;
begin
  AddStack('TArrLogCompare.ListDestroy');
  TArrGetFld(ls).Free;
  DelStack;
end;

class function TArrLogCompare.GetCount;
begin
  AddStack('TArrLogCompare.GetCount');
  result:=TArrGetFld(ls).rdb.ArrCount;
  DelStack;
end;

class procedure TArrLogCompare.GetItem;
var j: longint;
begin
  AddStack('TArrLogCompare.GetItem');
  if tp<>clogNoKey then with TArrGetFld(lsn).rdb do begin
    GotoRec(nn+1);
    case tp of
      clogKey: for j:=0 to FldDef.Count-1 do IncD(Prm.val,'~'+FldName(DWSToRec(j).Name).GetStrVal);
      clogPrn: Prm.val:=LogPrim([logpKey,logpNoKey,logpNoLogFields]);
    end;
  end;
  DelStack;
end;

{ TNone }
class procedure TNone.UpdArrGet;
begin
	AddStack('TNone.UpdArrGet');
  TCustomGet.UpdateAllGet(TArrGet,mgReCreate);
  DelStack;
end;

type
  TGetSave = array of record
    g: TArrGet;
    RVid: string;
  end;

procedure PrGetSave(Sender: TCustomGet; const av: array of variant; var lBreak: boolean);
var a: ^TGetSave;
  i: PLongInt;
begin
  AddStack('ArrGet.PrGetSave');
  a:=PointerVar(av[0]); i:=PointerVar(av[1]);
  with a^[i^] do begin
    g:=pointer(Sender); RVid:=Sender.RVid; g.RVid:=''; Inc(i^);
  end;
  DelStack;
end;

class function TNone.ButWndClick;
var s: string;
  a: TGetSave;
  i: longint;
begin
  AddStack('TNone.ButWndClick');
  if lEval then begin
    msf.Dat:=StrDeshifr(msrv.AValue);
    SetLength(a,LsCustomGet.Count); i:=0; NameGet(TArrGet.ClassName,PrGetSave,[longint(@a),longint(@i)]);
    AddPrnHead(msCapt); DWFldExec(msCapt,msf.Prm.Wnd,msf.rdb,nil,nil,[dwfCreateVar]); DelPrnHead;
    for i:=low(a) to i-1 do with a[i] do g.RVid:=RVid;
    if msf.rdb.DWModified then begin
      msrv.AValue:=StrShifr(msf.Dat); msf.ls[msnom]:=DWRecTos(msrv);
      s:=msf.ls.Text; msrd.DWTrans(s,true); msrd.DWModified:=true;
      msrd.InitFldDef(dwdefGotoRec);
    end;
  end;
  result:=ArrWndVar(msf.Prm.Wnd);
  DelStack;
end;

class procedure TNone.ButWndPaint;
var tf: TFldEdit;
begin
  AddStack('TNone.ButWndPaint');
  tf:=pointer(Sender); TButGet(tf.curget).DrawText(tf,astolin(tf.Canvas,Text,ARect.Right-ARect.Left));
  DelStack;
end;

class procedure TNone.PrInterDopGetVar;
var lsm: TMemGkList;
  a: TArrStr;
  r: TRecDB;
  rv: TDWVidRec;
  j: longint;
begin
  AddStack('TNone.PrInterDopGetVar');
  if not Assigned(lsVarDop) then begin
    lsVarDop:=TVarDopList.Create;
    lsVarDop.AddDop('$'+VarBeg+iChrPrim+RDBArr.DWVarName,'Данные по массивам');
    if Assigned(ProgPswd) then with ProgPswd.GetQuery do begin
      PartSelect(RDBArrv.NameDB,[fARRV,fNAME,fRECNO,DWMem],'',fARRV);
      r:=TRecDB.Create(Application.MainForm);
      try
        r.NameDB:=RDBArrv.NameDB; r.OpenRec; lsm:=TMemGkList.Create(r);
        while not Eof do begin
          lsm.GetFromQuery;
          lsVarDop.AddDop('$$'+VarBeg+Trim(r[fARRV]),r[fARRV]+'. '+r[fNAME]);
          for j:=0 to LsArrDynamic(r[DWMem],a,CRLF)-1 do begin
            rv:=DWSToRec(a[j]); lsVarDop.AddDop(RDBArr.DWVarName(rv.Name),rv.Prim,VarCreateTypes(rv));
          end;
          Next;
        end;
      finally
        r.Free; 
      end;
      ProgPswd.FreeQuery;
    end;
  end;
  lsVarDop.PrInterDopGetVar(ProcDopGetVarAdd);
  DelStack;
end;

class function TNone.PrInterDopGetVarIgnore;
begin
  AddStack('TNone.PrInterDopGetVarIgnore');
  result := aPath[1]=VarBeg;
  DelStack;
end;

procedure DWFldDefaultProc(const r: TDWVidRec; var ap: TDEPrmStr);
begin
  AddStack('ArrGet.DWFldDefaultProc');
  if r.AType=dwtArray then TArrGet.AssignGetClass(ap);
  DelStack;
end;

procedure ArrLogCompare(var Prm: TLogTrnsValPrm; const so,sn: string);
begin
  AddStack('ArrGet.ArrLogCompare');
  TArrLogCompare.ExecuteStr(Prm,so,sn,@Prm);
  DelStack;
end;

procedure RDBArrDef(const ka: string; var p: PRDBArrDef; var a: TArrStr);
var g: TCustomGet;
  i: longint;
  rv: TDWVidRec;
  Prm: TRecValPrm;
  t: TDWFldType;
  fl: boolean;
begin
  AddStack('ArrGet.RDBArrDef');
  fl:=true;
  if NameGet(g,TArrGet,ka) then with TArrGet(g) do if Assigned(FData) then begin
    fl:=false; rv:=DWSToRec(''); rv.SvType:=dwsFix; i:=FData.Fields.Count; SetLength(a,i);
    for i:=0 to i-1 do if TRecVal.StrToPrm(FData.Fields[i],Prm) then begin
      rv.Name:=Prm.AName; rv.dwCod:=Prm.AName; rv.AType:=dwtString;
      for t:=low(aDWFld) to high(aDWFld) do if aDWFld[t].tp=Prm.AType then begin
        rv.AType:=t; break;
      end;
      if rv.AType=dwtFloat then begin
        rv.Len:=FloatMaxLen; rv.Dec:=FloatMaxDec;
      end
      else rv.Len:=Prm.ASize;
      a[i]:=DWRecTos(rv);
    end;
    if Assigned(FWnd) then with TDataWin.aGet do begin
      Zgl:=FWnd.FrmCaption; SortMode:=FWnd.PnlSortMode;
      AskByCancel:=FWnd.PnlAskByCancel; Fields:=FWnd.Fields.Text; Pages:=FWnd.Pages.Text;
      DcmBased:=FWnd.DcmBased; DcmDef:=FWnd.DcmDef; InitArr(aForm);
      p.Wnd:=SaveToStr; DataWinFree;
    end
    else p.Wnd:='';
  end;
  if fl then p:=nil;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TArrGet]);
end;

initialization
	AddStack('ArrGet.initialization');
  UpdArrGet:=TNone.UpdArrGet;
  RecDB.ArrLogCompare:=ArrLogCompare; RecDB.RDBArrDef:=RDBArrDef;
  AddFrom(DWFldDefaultProc);
	with TInter do begin
    setvar('$arrget','Массивы данных');
    SetVar('ПМД_НОМЗАП','Номер текущей записи в массиве данных',d_nrec,0,'I');

    SetFunction('Массивы данных',1000);
    SetFunction('ПМД_ДОБАВИТЬ','Добавляет записи в массив данных',
      ['Мас: массив данных','[КолЗап: целое = 1]'],['A','NU'],c_add,null,1001,'A');
    SetFunction('ПМД_НОМЕР','Возвращает номер столбца массива данных по наименованию',
      ['Мас: массив данных','НаимСтолб: строка|массив'],['A','CA'],c_index,null,1002,'IA');
    SetFunction('ПМД_СОХРАНИТЬ','Сохраняет массив данных в строку',
      ['[ИмяПоля: строка]','Мас: массив данных','[ОкнаВвода: логическое = '+vTrue+']'],
      ['CU','A','LU'],c_loadsave,LongInt(@ProcSave),1003);
    SetFunction('ПМД_СЧИТАТЬ','Считывает данные из строки в массив данных',
      ['[ИмяПоля: строка]'],['CU'],c_loadsave,LongInt(@ProcLoad),1004,'A');
    SetFunction('ПМД_ДЛИНА','Установить длину массива данных',['Мас: массив данных','Длина: целое'],
      ['A','N'],c_len,null,1005,'A');
  end;
  DelStack;
finalization
	AddStack('ArrGet.finalization');
  TArrGet.VarCreate;
  DelStack;
end.
