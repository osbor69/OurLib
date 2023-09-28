unit FDWFld;

interface

{$I LIBTEST}
uses
	Windows, Messages, Classes, Controls, Forms, ExtCtrls, Grids, Menus, ComCtrls,
  MyTypes, DefEdit, FDWPrm, FRMEMPTY, Keylb, Fpanel, StrBrowl, PnlEdit, RecVal, Recdb, KeyMenu, FFldedit,
    ButGet, BtTxtGet, MenuGet, ChkGets, ComboGet, PaintCtl, MemoGet, CCodeGet;

type
  PDWRecModified = ^TDWRecModified;
  TDWRecModified = record
  	r: TRecDBDef;
    lMod: boolean;
  end;

  TDWFld = class(TFormEmp)
    PnLs: TRbPanel;
    PnEd: TPanelEdit;
    LsFld: TStringBrowl;
    KeyMenu1: TKeyMenu;
    Rec: TRecVal;
    RecGet: TMenuGet;
    VarGet: TMenuGet;
    VidGet: TMenuGet;
    VNameGet: TMenuGet;
    EMaxLen: TFldEdit;
    CaseGet: TMenuGet;
    ECharCase: TFldEdit;
    MaskGet: TButTextGet;
    ERelation: TFldEdit;
    RelationGet: TComboGet;
    pnDat: TRbPanel;
    ERec: TFldEdit;
    ERecFld: TFldEdit;
    pnVid: TRbPanel;
    EVid: TFldEdit;
    EVName: TFldEdit;
    EMask: TFldEdit;
    pnBool: TRbPanel;
    EAutoSel: TFldEdit;
    EPassword: TFldEdit;
    ENoReadOnly: TFldEdit;
    ENoVsbl: TFldEdit;
    ETag: TFldEdit;
    pnHint: TRbPanel;
    ESayHint: TFldEdit;
    EGetHint: TFldEdit;
    pnWH: TRbPanel;
    EWidth: TFldEdit;
    EHeight: TFldEdit;
    ENoVisible: TFldEdit;
    deFix: TDefEdit;
    ENewPage: TFldEdit;
    SortGet: TRadioGet;
    ESayRight: TFldEdit;
    ETrimLeft: TFldEdit;
    ECaption: TFldEdit;
    function LsFldCalcZn(Sender: TObject; ACol: longint): String;
    procedure LsFldEnter(Sender: TObject);
    procedure LsFldExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EVidChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    procedure ERecChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    function VarGetListOwner(Sender: TObject; SpdBut: TPaintButton;
      const RectList: TRect; PozList: TPozList): Boolean;
    function PnEdValid(Sender: TObject): Boolean;
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    procedure MaskGetClick(Sender: TObject);
    procedure LsFldMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: longint);
    procedure LsFldMouseMove(Sender: TObject; Shift: TShiftState; X,Y: longint);
    procedure LsFldMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: longint);
    procedure ERecExit(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EMaskChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    procedure PnEdEscape(Sender: TObject; var Action: TCloseAction);
    procedure PnEdExitType(Sender: TObject; ExitType: TPEExitType);
    function deFixPnlValid(Sender: TObject): Boolean;
    function deFixFldCheck(Sender: TObject): Boolean;
    procedure deFixFldExit(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure PnEdEnter(Sender: TObject);
    procedure PnEdExit(Sender: TObject);
    function ERelationCheck(Sender: TObject): Boolean;
    procedure ERecFldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure FormShow(Sender: TObject);
    procedure EMaskEnter(Sender: TObject);
    procedure EMaskExit(Sender: TObject);
    procedure deFixPnlCngKey(Sender: TObject; var tb: TKeyBut);
    procedure LsFldSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    { Private declarations }
    dw,odw: TDataWin;
    flMove,lAppNew,DDatGetList: boolean;
  	prCreate: TNotifyEvent;
		LsStr,LsGet,ls1: TStringList;
    aRec: array of TDWRecModified;
    oRow,ARow,nDefRec,RowBeforeApp: longint;
    fAccess: TProcValid;
    fListProc: TDWFldListProc;
    aInfo: TDWSearchAInfo;
    aFld: array[TDEPrmList] of TFldEdit;
    aFormHelp: PDWFormHelp;
    aFormHelpFileProc: TDWFormHelpFileProc;
    aFormHelpFilePrm: pointer;
    tmSearch: TTimer;
    SearchInfo: TDWSearchInfo;
    ClpBrdViewer: HWND;
    PClpBrd: PString;
		function IsReadOnly(Sender: TRecDBDef): boolean;
		procedure FldList(var sDat,sWnd: string);
		procedure LsGetClear;
		function SeekRDB: PDWRecModified; overload;
		function SeekRDB(var pd: PDWRecModified): boolean; overload;
    function GetRDB(i: longint): PDWRecModified;
		function SeekGet(var g: TCustomGet): boolean;
		procedure PnEdRead(ARow: longint = NegDef);
		procedure Move(oi,ni: longint);
		procedure PrMove(oi,ni: longint; const av: array of variant);
		function prFind(Sender: TControl; const sf: string): boolean;
		procedure TimerSearch(Sender: TObject);
    procedure MaskView(const ms: string; g: TCustomGet; lRead: boolean = true);
    procedure DelStr;
		function PrFldList(Sender: TWinControl; MinWidth: longint;
	  	const Capt: string; var txt: string): boolean;
		function PrEdSay(Sender: TObject): string;
		procedure PrFldSeek(rdb: TRecDBDef; var a: TDWFldArrSeek; prAdd: TDWFldProcAdd);
		procedure SetKeyForm;
		function VarNmToRec(var vr: TVarNmRec): boolean;
		procedure SetGet(const a: TDEPrmStr; FromShow: boolean);
    procedure PrMask(key: longint; tw: TWinControl);
    procedure PageSynchro; overload;
    class procedure PageSynchro(lsField,lsPage: TStrings; dw: TDataWin); overload;
    procedure ClpBrdCanPast;
    procedure DisposeClpBrd;
    procedure WMDrawClipboard(var Msg: TWMDrawClipboard); message WM_DRAWCLIPBOARD;
    procedure WMChangeCBChain(var Msg: TWMChangeCBChain); message WM_CHANGECBCHAIN;
		procedure WMHelpFill(var msg: TWMHelpFill); message WM_HELPFILL;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
		class procedure PrnLsAdd(lsPrn: TStringList; const Wnd: string);
  end;

  TWinLogCompare = class(TCustomLogCompare)
  public
    class function ListCreate(pv: pointer; const Value: string; lNew: boolean): pointer; override;
    class procedure ListDestroy(pv,ls: pointer); override;
    class function GetCount(pv,ls: pointer): longint; override;
    class procedure GetItem(var Prm: TLogTrnsValPrm; pv,lso,lsn: pointer; no,nn: longint; tp: TLogCompareItemList); override;
    class procedure Execute(var Prm: TLogTrnsValPrm; r: TRecDBDef); overload;
  end;

var PDWFldSearchInfo: PDWSearchInfo;

implementation

{$R *.DFM}

uses Math,SysUtils,DB,StrUtils,Clipbrd,Variants,
  My_pr,ListF2,Askp,FSrchTre,SpinGet,FrmPswd,FDWPage,Inter,FDWVid,FEdGenFr,
    SpGet,FHelpLs,GenForm,Shifr,BufFile;

type
	TSpinMinMaxGet = class(TSpinGet)
  public
		constructor Create(AOwner: TComponent); override;
    procedure SetMaxLen(l: longint); override;
		function GetText: longint; override;
		function SetText(n: longint): string; override;
  end;

  TNone = class
  private
		class procedure LoadWait(Sender: TAsk);
  end;

var aForm: array[TDWVidForm] of TDWFld;
  nForm: TDWVidForm;

const aMinMaxDef: array[wallLow..0] of string = ('максимум без подск.','максимум','по умолч.');
  ClpBrdLastVers = 1;

function IfThen(AValue: boolean; ATrue: TDEEdFormEdList): TDEEdFormEdOpt; overload;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function c_EdFormEd(lSetMod: boolean): boolean; overload;
var p: PString;
begin
	AddStack('FDWFld.c_EdFormEd');
  if DWPageNumEdit<0 then p:=@DWPrm.dw.DcmDef else p:=@DWPage.aCol[3];
  with aForm[nForm] do result:=TEdGenFr.EdFormEd(p,PrFldList,PrEdSay,IfThen(lSetMod,defrmSetMod));
  DelStack;
end;

function c_EdFormEd(var av: array of variant): variant; overload;
begin
  result:=c_EdFormEd(false);
end;

{ TDWFld }
procedure TDWFld.FormCreate(Sender: TObject);
	procedure Set1(g: TCustomGet; tf: TFldEdit; const nm: string);
  begin
    AddStack('TDWFld.FormCreate',Self);
  	g.VName:=Rec.NameRec+nm; tf.AssignGet(g);
    DelStack;
  end;
var i: longint;
  cc: TDECharCase;
	spg: TCustomGet;
begin
	AddStack('TDWFld.FormCreate',Self);
  LsStr:=TStringList.Create;
  LsGet:=TStringList.Create; ls1:=TStringList.Create;
  Rec.CreateFld('FixKA',ftString,Length(RDBArrv[fARRV]),'');
  Rec.CreateFld('FixNAME',ftString,Length(RDBArrv[fNAME]),'');
  RowBeforeApp:=-1;
  ECaption.AssignGet(TButManyStrGet.CreateOne); ECaption.Mask:=',,,2,Наименование';
  spg:=TSpinMinMaxGet.CreateOne; EWidth.AssignGet(spg); EWidth.Mask:=Format('%d,%d',[wallLow,999]); EHeight.AssignGet(spg);
  Rec.NameRec:='DWFld'+aDWVidFormChr[nForm]; PnEd.FillFldList;
  for i:=0 to PnEd.FieldCount-1 do PnEd.Fields[i].NameRec:=Rec.NameRec;
  Set1(RecGet,ERec,'Rec'); Set1(VarGet,ERecFld,'Var');
  Set1(VidGet,EVid,'Vid'); Set1(VNameGet,EVName,'VName'); Set1(MaskGet,EMask,'Mask');
  with CaseGet.Items do begin
    BeginUpdate;
    for cc:=low(aDECharCase) to high(aDECharCase) do Add(Int2Str(cc)+UnDelim+aDECharCase[cc]);
    EndUpdate;
  end;
  Set1(CaseGet,ECharCase,'Case'); Set1(RelationGet,ERelation,'Rel');
  VarGet.LenName:=DWVidNameLen;
  dw:=TDataWin.Create; odw:=TDataWin.Create;
  flMove:=false;
  RelationGet.LenName:=Length(Rec['Relation']); SearchInfo.NumObj:=-1;
  for i:=0 to deFix.Fields.Count-1 do deFix.Param[i,deNameRec]:=Rec.NameRec;
  deFix.AssignGet('FixKA',ArrFixGet);
  aFld[deCaption]:=ECaption; aFld[deNameRec]:=ERec; aFld[deNameRecFld]:=ERecFld;
  aFld[deVid]:=EVid; aFld[deVName]:=EVName; aFld[deMask]:=EMask; aFld[deMaxLen]:=EMaxLen;
  aFld[deCharCase]:=ECharCase; aFld[deAutoSel]:=EAutoSel; aFld[dePassword]:=EPassword;
  aFld[deNoReadOnly]:=ENoReadOnly; aFld[deReadOnlyNoVsbl]:=ENoVsbl; aFld[deTag]:=ETag;
  aFld[deSayHint]:=ESayHint; aFld[deGetHint]:=EGetHint; aFld[deRelation]:=ECaption;
  aFld[deWidth]:=ERelation; aFld[deHeight]:=EWidth; aFld[deNoVisible]:=EHeight;
  aFld[deNewPage]:=ENewPage; aFld[deSayRight]:=ESayRight; aFld[deTrimLeft]:=ETrimLeft;
  TClipboardBuf.ViewerCreate(ClpBrdViewer,Self);
  inherited;
  DelStack;
end;

procedure TDWFld.FormDestroy(Sender: TObject);
begin
	AddStack('TDWFld.FormDestroy',Self);
  if Assigned(lsGet) then LsGetClear;
  LsGet.Free; ls1.Free; FreeAndNil(LsStr); dw.Free; odw.Free;
  DisposeClpBrd; TClipboardBuf.ViewerFree(ClpBrdViewer,Self);
  inherited;
  DelStack;
end;

procedure TDWFld.FormHide(Sender: TObject);
begin
	AddStack('TDWFld.FormHide',Self);
  inherited;
  FormFree(SpGkLs);
  DelStack;
end;

procedure TDWFld.LsGetClear;
begin
	AddStack('TDWFld.LsGetClear',Self);
  ClearObjects(lsGet);
  DelStack;
end;

function DWFldExec(const Capt: TCaption; var Value: string;
  const acRec: array of TRecDBDef; DefaultRec: TRecDBDef = nil;
  FldAccess: TProcValid = nil; Opt: TDWFldOpt = [];
  ProcCreate: TNotifyEvent = nil; PSearchInfo: PDWSearchInfo = nil;
  PFormHelpArr: PDWFormHelp = nil; FldListProc: TDWFldListProc = nil;
  FormHelpFileProc: TDWFormHelpFileProc = nil; FormHelpFilePrm: pointer = nil): boolean;
var i,j,l: longint;
	g: TCustomGet;
  ls,LsRec,opgLsStr: TStringList;
  oForm: TDWVidForm;
  ardb: TArrRecDBDef;
  ocr: TRecDBDef;
  pgcrt,opgNoLimit: boolean;
  opgListProc: TDWFldListProc;
  opgLsPgText: string;
begin
	AddStack('FDWFld.DWFldExec');
  oForm:=nForm; ocr:=CurDWFldRdb; SetLength(ardb,Length(acRec)); j:=low(ardb);
  for i:=low(acRec) to high(acRec) do if Assigned(acRec[i]) then begin
    ardb[j]:=acRec[i]; Inc(j);
  end;
  SetLength(ardb,j); nForm:=ardb[low(ardb)].DWVidForm;
	if not Assigned(aForm[nForm]) then mess_wait(['Загрузка формы настройки полей окна ввода'],TNone.LoadWait,false);
  with aForm[nForm] do begin
    NoLimit:=true;
    if Assigned(PSearchInfo) then SearchInfo:=PSearchInfo^
    else if Assigned(PDWFldSearchInfo) then begin
      SearchInfo:=PDWFldSearchInfo^; PDWFldSearchInfo:=nil;
    end;
  	Caption:=Capt; 
    dw.LoadFromStr(Value); odw.Assign(dw);
    // TRecDBDef
    LsRec:=RecGet.Items; LsRec.BeginUpdate; LsRec.Clear; i:=Length(ardb);
    if Length(aRec)<i then SetLength(aRec,i);
    for i:=0 to i-1 do with aRec[i] do begin
      r:=ardb[i]; r.DWModified:=false; lMod:=false; LsRec.AddObject(ardb[i].DWName,pointer(i));
    end;
    LsRec.Sorted:=true; LsRec.EndUpdate;
    if not Assigned(DefaultRec) then nDefRec:=0
    else if not LsRec.Find(DefaultRec.DWName,nDefRec) then nDefRec:=0;
    LsRec.Sorted:=false; prCreate:=ProcCreate;
    for i:=0 to LsRec.Count-1 do begin
    	IncL(LsRec,i,IntToStr(i)+UnDelim);
      if dwfCreateVar in Opt then TDWPrm.VarCreate(GetRDB(i).r);
    end;
    fAccess:=FldAccess; fListProc:=FldListProc;
    // TCustomGet
    LsGetClear; LsGet.Sorted:=true; l:=0;
    if Assigned(LsCustomGet) then
      for i:=0 to LsCustomGet.Count-1 do begin
        g:=PointerObj(LsCustomGet,i);
        if not empty(g.RVid) then begin
          j:=LsGet.Add(g.RVid);
          if not PointerObj(LsGet,j,pointer(ls)) then begin
            ls:=SortStrListCreate(dupAccept); LsGet.Objects[j]:=ls;
          end;
          ls.AddObject(g.RVName,g); MaxSelf(l,g.RVName);
        end;
      end;
    LsGet.Sorted:=false;
    ls:=SortStrListCreate(dupAccept); ls.AddObject('',nil);
    LsGet.InsertObject(0,'[отсутствует]',ls);
    for i:=0 to LsGet.Count-1 do begin
      IncL(LsGet,i,IntToStr(i)+UnDelim); ls:=PointerObj(LsGet,i); ls.Sorted:=false;
      for j:=0 to ls.Count-1 do ls[j]:=IntToStr(j)+UnDelim+padr(ls[j],l);
    end;
    VidGet.Items.Assign(LsGet); DDatGetList:=false;
    ERec.SetReadOnly(LsRec.Count<=1);
    // Поля
    pgcrt:=CreateForm(TDWPage,DWPage);
    opgNoLimit:=DWPage.NoLimit; opgLsStr:=DWPage.LsStr; opgListProc:=DWPage.fListProc; opgLsPgText:=DWPage.LsPg.Text;
    DWPage.NoLimit:=true; DWPage.LsStr:=LsStr; DWPage.fListProc:=fListProc; {DWPage.dw:=dw;} DWPage.LsPg.Text:=dw.Pages;
    LsStr.Text:=dw.Fields; PageSynchro;
    LsFld.AddSt(LsStr.Count);
    if LsStr.Count>0 then LsFld.Row:=1;
    PnEdRead; MainRebuild;
    aFormHelp:=PFormHelpArr; aFormHelpFileProc:=FormHelpFileProc; aFormHelpFilePrm:=FormHelpFilePrm;
    SetKeyForm;
  	result := ShowModal=mrOk;
    if result then Value:=dw.SaveToStr;
    if dwfCreateVar in Opt then for i:=0 to LsRec.Count-1 do TDWPrm.VarFree(GetRDB(i).r);
    LsGetClear; NoLimit:=false;
    if pgcrt then FormFree(DWPage)
    else begin
      DWPage.LsStr:=opgLsStr; DWPage.fListProc:=opgListProc; DWPage.LsPg.Text:=opgLsPgText; DWPage.NoLimit:=opgNoLimit; 
    end;
  end;
  nForm:=oForm; CurDWFldRdb:=ocr;
  DelStack;
end;

function TDWFld.LsFldCalcZn(Sender: TObject; ACol: longint): String;
var a: TDEPrmStr;
begin
	AddStack('TDWFld.LsFldCalcZn',Self);
  inherited;
  if Assigned(LsStr) then begin
    if InRange(LsFld.Row,1,LsStr.Count) then result:=LsStr[LsFld.Row-1] else result:='';
    a:=DEGetArrParam(result);
    case ACol of
      0: result:=Padr(TRecDBDef.DWVarName(a),15);
      1: result:=Str3t(StrTran(a[deCaption],UnDelim,' '),25);
    else result:='';
    end;
  end;
  DelStack;
end;

// Добавить клавиши списка
procedure TDWFld.LsFldEnter(Sender: TObject);
begin
	AddStack('TDWFld.LsFldEnter',Self);
  inherited;
	with KeyLb1 do begin
  	if nForm=dwfArray
    then SetKey(K_F3,'','Скопировать описание в фиксированный массив',KeyLb1ProcKey,'lsbox',kmServic);
  	SetKey(K_F2,'Параметры','Параметры окна редактирования',KeyLb1ProcKey,'lsbox',kmFile);
  	SetKey(K_F4,'Скопировать','',KeyLb1ProcKey,'lsbox',kmList);
  	SetKeys([K_F5,K_Enter],'Редактировать','',KeyLb1ProcKey,'lsbox',kmList);
    SetKeyFind(KeyLb1ProcKey,'lsbox',kmList,false);
  	SetKey(K_F7,'Добавить','',KeyLb1ProcKey,'lsbox',kmList);
  	SetKey(K_F8,'Удалить','',KeyLb1ProcKey,'lsbox',kmList);
  	SetKey(K_F11,'Страницы','',KeyLb1ProcKey,'lsbox',kmList);
  	SetKey(K_Ctrl_Up,'Выше','Переместить выше',KeyLb1ProcKey,'lsbox',kmList);
  	SetKey(K_Ctrl_Down,'Ниже','Переместить ниже',KeyLb1ProcKey,'lsbox',kmList);
  	SetKey(K_Ctrl_F6,'','Печать',KeyLb1ProcKey,'lsbox',kmFile);
    SetKeyForm; ReDrw;
  end;
  DelStack;
end;

procedure TDWFld.SetKeyForm;
begin
  AddStack('TDWFld.SetKeyForm',Self);
  if Assigned(DWPage) then begin
    PageSynchro;
    with KeyLb1 do
      if (DWPage.LsPg.Count=0) and (dw.DcmBased or (dw.SortMode<>smDefault))
      then SetKey(K_Ctrl_F5,'',IfThen(dw.DcmBased,'Редактирование формы','Преобразовать в форму'),
        KeyLb1ProcKey,'lsbox',kmFile)
      else DelKey(K_Ctrl_F5,'lsbox');
  end;
  DelStack;
end;

// Удалить клавиши списка
procedure TDWFld.LsFldExit(Sender: TObject);
begin
	AddStack('TDWFld.LsFldExit',Self);
  inherited;
  KeyLb1.DelKey(K_All,'lsbox'); KeyLb1.ReDrw;
  DelStack;
end;

procedure TDWFld.ERecChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
var i: longint;
  rdb: PDWRecModified;
  ov: variant;
begin
	AddStack('TDWFld.ERecChange',Self);
  inherited;
  if SeekRDB(rdb) then begin
  	CurDWFldRdb:=rdb.r; ls1.Text:=rdb.r.DWTrans;
    for i:=0 to ls1.Count-1 do ls1[i]:=IntToStr(i)+UnDelim+DWSToRec(ls1[i]).Name;
    if ls1.Count=0 then ls1.Add('0'+UnDelim);
    SetRedraw(ERecFld); ov:=ERecFld.VarValue;
    VarGet.Items.Assign(ls1); ERecFld.Read; ERecFld.Change(ov,FromShow);
    SetRedraw(ERecFld,rdrwSet); ENoReadOnly.SetReadOnly(IsReadOnly(rdb.r));
  end;
  DelStack;
end;

function TDWFld.SeekRDB: PDWRecModified;
begin
  SeekRDB(result);
end;

function TDWFld.SeekRDB(var pd: PDWRecModified): boolean;
var i: longint;
begin
	AddStack('TDWFld.SeekRDB',Self);
	i:=Rec['Rec']; result:=InRange(i,0,RecGet.Items.Count-1);
  if result then pd:=GetRDB(i);
  DelStack;
end;

function TDWFld.GetRDB;
begin
  AddStack('TDWFld.GetRDB',Self);
  result:=@aRec[IntObj(RecGet.Items,i)];
  DelStack;
end;

procedure TDWFld.ERecFldChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
var rdb: PDWRecModified;
  i,j: longint;
  a: TDEPrmStr;
  r: TDWVidRec;
  ls: TStringList;
  fl: boolean;
  g: TCustomGet;
begin
  AddStack('TDWFld.ERecFldChange',Self);
  if SeekRDB(rdb) then begin
    ls1.Text:=rdb.r.DWTrans;
    if InRange(LsFld.Row,1,LsStr.Count) then begin
      i:=Rec['RecFld'];
      if InRange(i,0,ls1.Count-1) then begin
        r:=DWSToRec(ls1[i]);
        if (r.SvType=dwsDyn) <> DDatGetList then begin
          VidGet.Items.BeginUpdate;
          VidGet.Items.Assign(LsGet); DDatGetList := r.SvType=dwsDyn;
          if DDatGetList then begin
            i:=0;
            while i<VidGet.Items.Count do begin
              ls:=PointerObj(VidGet.Items,i); fl:=false;
              for j:=0 to ls.Count-1 do 
                if IsClass(ls.Objects[j],TCustomGet,pointer(g)) then if g.DDatSupport then begin
                  fl:=true; break;
                end;
              if fl then Inc(i) else VidGet.Items.Delete(i);
            end;
          end;
          VidGet.Items.EndUpdate;
        end;
        if lAppNew then begin
          a:=DEGetArrParam(LsStr[LsFld.Row-1]); TDataWin.FldDefault(r,a); SetGet(a,FromShow);
          TFldEdit.Read(IfThen(FromShow,ferdFromShow),[EVid,EVName]);
        end;
      end;
    end;
  end;
  DelStack;
end;

procedure TDWFld.EVidChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
var n: longint;
  g: TCustomGet;
  a: TDEPrmStr;
  rdb: PDWRecModified;
  r: TDWVidRec;
  lro: boolean;
begin
	AddStack('TDWFld.EVidChange',Self);
  inherited;
	n:=Rec['Vid'];
  if InRange(n,0,LsGet.Count-1) then begin
    SetRedraw(EVName); VNameGet.Items.BeginUpdate;
    VNameGet.Items.Assign(PointerObj(LsGet,n));
    if DDatGetList then with VNameGet.Items do begin
      n:=0;
      while n<Count do begin
        if IsClass(Objects[n],TCustomGet,pointer(g)) then if not g.DDatSupport then begin
          Delete(n); continue;
        end;
        Inc(n);
      end;
    end;
    VNameGet.Items.EndUpdate; EVName.Read(IfThen(FromShow,ferdFromShow));
    EVName.SetReadOnly(VNameGet.Items.Count<2);
    SetRedraw(EVName,rdrwSet);
    if SeekGet(g) then begin
    	if not FromShow and g.MaskCngClear then Rec['Mask']:='';
      MaskGet.TextReadOnly:=g.MaskTextReadOnly; MaskView(Rec['Mask'],g);
      if lAppNew then
        if SeekRDB(rdb) then begin
          ls1.Text:=rdb.r.DWTrans;
          if InRange(LsFld.Row,1,LsStr.Count) then begin
            n:=Rec['RecFld'];
            if InRange(n,0,ls1.Count-1) then begin
              a:=DEGetArrParam(LsStr[LsFld.Row-1]);
              r:=DWSToRec(ls1[n]); TDataWin.FldDefault(r,a);
              a[deVid]:=g.ClassName; a[deVName]:=g.VName; g.FldDefault(r,a);
              a[deCaption]:=ECaption.VarValue; SetGet(a,FromShow);
            end;
          end;
        end;
      lro:=g.MaskReadOnly;
    end
    else lro:=true;
    EMask.SetReadOnly(lro);
  end;
  DelStack;
end;

function TDWFld.ERelationCheck(Sender: TObject): Boolean;
var g,g1: TCustomGet;
	i: longint;
  a: TDEPrmStr;
  r: TVarNmRec;
begin
	AddStack('TDWFld.ERelationCheck',Self);
  result:=true;
  if not empty(Rec['Relation']) then
    if SeekGet(g) then
      if g.DefRelation=frMain then
        if VarNmToRec(r) then begin
          for i:=low(r) to high(r) do AnsiUpperCaseSelf(r[i]);
          for i:=0 to LsStr.Count-1 do begin
            a:=DEGetArrParam(LsStr[i]);
            if (TrimUpper(a[deNameRec])=r[1]) and (TrimUpper(a[deNameRecFld])=r[2]) then begin
              if NameGet(g1,a) then
                if g1.DefRelation=frMain then begin
                  mess_ok(['Поле с видом ввода','"'+Trim(g.RVid)+'"',
                    'не может быть подчинено полю с видом ввода','"'+Trim(g1.RVid)+'"']);
                  result:=false;
                end;
              break;
            end;
          end;
        end;
  DelStack;
end;

function TDWFld.VarNmToRec;
var i: longint;
begin
  AddStack('TDWFld.VarNmToRec',Self);
  vr:=My_pr.VarNmToRec(Rec['Relation'],false); result:=false;
  for i:=0 to RecGet.Items.Count-1 do with GetRDB(i)^ do if TrimUpper(r.DWPrefix)=vr[1] then begin
    vr[1]:=Trim(r.NameRec); TrimSelf(vr[2]); result:=true; break;
  end;
  DelStack;
end;

function TDWFld.SeekGet;
var i: longint;
	ls: TStringList;
begin
	AddStack('TDWFld.SeekGet',Self);
	g:=nil; i:=Rec['Vid'];
  if i<LsGet.Count then begin
    ls:=PointerObj(LsGet,i); i:=Rec['VName'];
    if i<ls.Count then g:=PointerObj(ls,i);
  end;
  result:=Assigned(g);
  DelStack;
end;

function TDWFld.VarGetListOwner(Sender: TObject; SpdBut: TPaintButton;
  const RectList: TRect; PozList: TPozList): Boolean;
var rdb: PDWRecModified;
  oAct: TNotifyEvent;
  n: longint;
  f: TForm;
  fv: TDWVid;
begin
	AddStack('TDWFld.VarGetListOwner',Self);
  inherited;
	result:=true;
  if SeekRDB(rdb) then begin
  	fv:=TDWVid.NmForm(rdb.r);
    with fv do begin
    	SaveIniForm; WindowState:=wsNormal;
      SetBounds(Left,RectList.Top,Width,RectList.Bottom-RectList.Top);
      FormOnScreen;
      if IsLastForm(f) then begin
        oAct:=f.OnActivate; f.OnActivate:=nil;
      end
      else oAct:=nil;
      ERecFld.Write; n:=Self.Rec['RecFld'];
      if DWVidExec(rdb.r,nil,n) then begin
        ERecChange(ERec,0,false); rdb.r.DWModified:=true; rdb.lMod:=true;
      end;
      ERecFld.VarValue:=LsVar.Row-1; RestIniForm;
      if Assigned(f) then f.OnActivate:=oAct;
      if not NmFormFree then NoLimit:=false;
    end;
  end;
  DelStack;
end;

// Считать значения в окно редактирования
procedure TDWFld.PnEdRead;
var a: TDEPrmStr;
	function nRDB: longint;
  var cr: TCustomRec;
	  rdb: TRecDBDef;
  begin
  	AddStack('TDWFld.PnEdRead.nRDB',Self);
    result:=nDefRec;
    if RecName(a[deNameRec],cr,TRecDBDef) then begin
      rdb:=pointer(cr); result:=Int0(RecGet.CodFromName(rdb.DWName));
      if IsReadOnly(rdb) then a[deNoReadOnly]:=bFalse;
    end;
    DelStack;
  end;
var s: string;
  i: longint;
  lall: boolean;
begin
	AddStack('TDWFld.PnEdRead',Self);
  lall:=ReplNegSelf(ARow,LsFld.Row);
	if lall or (oRow<>ARow) then begin
    oRow:=ARow;
    with KeyLb1 do if InRange(oRow,1,LsStr.Count) then begin
      s:=LsStr[oRow-1]; SetKey(K_Shift_C,'','Скопировать описание вводимого поля',KeyLb1ProcKey,'lsbox',kmList)
    end
    else begin
      s:=sDWFldDef; DelKey(K_Shift_C,'lsbox');
    end;
    ClpBrdCanPast;
    a:=DEGetArrParam(s);
    ERec.VarValue:=nRDB;
    Rec['RecFld']:=Int0(VarGet.CodFromName(a[deNameRecFld]));
    SetGet(a,true);
    Rec['MaxLen']:=Int0(a[deMaxLen]);
    Rec['CharCase']:=max(1,Int0(a[deCharCase]));
    Rec['AutoSel']:=StrToBoolean(a[deAutoSel]);
    Rec['Password']:=StrToBoolean(a[dePassword]);
    Rec['NoRdOnly']:=StrToBoolean(a[deNoReadOnly]);
    Rec['NoVsbl']:=StrToBoolean(a[deReadOnlyNoVsbl]);
    Rec['NoVisible']:=StrToBoolean(a[deNoVisible]);
    Rec['Tag']:=StrToBoolean(a[deTag]);
    Rec['NewPage']:=StrToBoolean(a[deNewPage]);
    Rec['SayRight']:=StrToBoolean(a[deSayRight]);
    Rec['TrimLeft']:=StrToBoolean(a[deTrimLeft]);
    Rec['SayHint']:=a[deSayHint];
    Rec['GetHint']:=a[deGetHint];
    Rec['Height']:=Int0(a[deHeight]);
    Rec['Relation']:=TRecDBDef.DWVarNameRel(a);
    RelationGet.Items.Clear; RelationGet.Items.Add('');
    for i:=0 to LsStr.Count-1 do begin
      LsArrFill(LsStr[i],a,UnDelim);
      if i<>oRow-1 then RelationGet.Items.Add(TRecDBDef.DWVarName(GetRDB(nRDB).r.NameRec,a[deNameRecFld]));
    end;
    PnEd.FldReadAll([ferdSvOld,ferdFromShow]);
  end;
  DelStack;
end;

procedure TDWFld.SetGet;
var fl: boolean;
	s: string;
  i,j: longint;
  ls: TStringList;
  g,g1: TCustomGet;
begin
  AddStack('TDWFld.SetGet',Self);
  Rec['Caption']:=a[deCaption]; Rec['Vid']:=0; Rec['VName']:=0;
  if NameGet(g,a) then begin
    fl:=false; s:=TrimUpper(g.VName);
    for i:=0 to LsGet.Count-1 do begin
      ls:=PointerObj(LsGet,i);
      for j:=0 to ls.Count-1 do if IsClass(ls.Objects[j],TCustomGet,pointer(g1)) then
        if (g1.ClassName=g.ClassName) and (TrimUpper(g1.VName)=s) then begin
          Rec['Vid']:=i; Rec['VName']:=j; fl:=true; break;
        end;
      if fl then break;
    end;
  end
  else MaskGet.TextReadOnly:=false;
  MaskView(a[deMask],g,false);
  Rec['Width']:=Int0(a[deWidth]);
  Rec['Height']:=Int0(a[deHeight]);
  TFldEdit.Read(IfThen(FromShow,ferdFromShow),[ECaption,EMask,EWidth,EHeight]);
  DelStack;
end;

procedure TDWFld.MaskGetClick(Sender: TObject);
var g: TCustomGet;
  s: string;
  Opt: TMaskPropOpt;
begin
	AddStack('TDWFld.MaskGetClick',Self);
  inherited;
  EMask.Write; EMaskChange(EMask,0,false);
  if SeekGet(g) then begin
    s:=Rec['Mask']; Opt:=[mskFormWnd];
    if SearchInfo.NumObj>=0 then Include(Opt,mskSearch);
    if g.MaskProp('Параметры ввода',s,SeekRDB.r,VarGet.MenuName(Rec['RecFld']),Opt) then MaskView(s,g);
  end;
  DelStack;
end;

procedure TDWFld.MaskView;
var s: string;
begin
  AddStack('TDWFld.MaskView',Self);
  s:=ms;
  if Assigned(g) then g.MaskView(s);
  Rec['Mask']:=ms; Rec['MaskView']:=s;
  if lRead then EMask.Read;
  DelStack;
end;

function TDWFld.PnEdValid(Sender: TObject): Boolean;
var pd: PDWRecModified;
	g: TCustomGet;
  ap: TDEPrmStr;
  nFldFocus: TDEPrmList;
  nVarFocus: TVarParam;
  s: string;
  vr: TVarNmRec;
begin
	AddStack('TDWFld.PnEdValid',Self);
  inherited;
	result:=true;
  if LsStr.Count>0 then begin
    if SeekRDB(pd) then ap[deNameRec]:=Trim(pd.r.NameRec)
    else begin
      ap[deNameRec]:=''; pd:=nil;
    end;
    SeekGet(g); g.AssignGet(ap);
    if VarNmToRec(vr) then s:=ArrayAsList(vr,'.') else s:='';
    ap[deCaption]:=TrimRight(Rec['Caption']);
    ap[deNameRecFld]:=Trim(VarGet.MenuName(IntToStr(Rec['RecFld'])));
    ap[deMask]:=TrimRight(Rec['Mask']);
    ap[deMaxLen]:=IntToStr(Rec['MaxLen']);
    ap[deCharCase]:=IntToStr(Rec['CharCase']);
    ap[deAutoSel]:=Bool2Str(Rec['AutoSel']);
    ap[dePassword]:=Bool2Str(Rec['Password']);
    ap[deNoReadOnly]:=Bool2Str(Rec['NoRdOnly']);
    ap[deReadOnlyNoVsbl]:=Bool2Str(Rec['NoVsbl']);
    ap[deNoVisible]:=Bool2Str(Rec['NoVisible']);
    ap[deTag]:=Bool2Str(Rec['Tag']);
    ap[deNewPage]:=Bool2Str(Rec['NewPage']);
    ap[deSayRight]:=Bool2Str(Rec['SayRight']);
    ap[deTrimLeft]:=Bool2Str(Rec['TrimLeft']);
    ap[deSayHint]:=Trim(Rec['SayHint']);
    ap[deGetHint]:=Trim(Rec['GetHint']);
    ap[deRelation]:=s;
    ap[deWidth]:=IntToStr(Rec['Width']);
    ap[deHeight]:=IntToStr(Rec['Height']);
    if Assigned(pd) then begin
      ls1.Text:=pd.r.DWTrans; s:=ap[deNameRecFld]+'='+ls1.Values[ap[deNameRecFld]];
    end
    else s:='';
    DWFldValid(ap,DWSToRec(s),nFldFocus,nVarFocus,result,g);
    if result then begin
      LsStr[oRow-1]:=DESetArrParam(ap); LsFld.CurStUpdate;
    end
    else pnEd.FldFocus:=aFld[nFldFocus];
  end;
  DelStack;
end;

procedure TDWFld.KeyLb1ProcKey(key: longint; tw: TWinControl);
var i: longint;
	s,d,w: string;
  p: PDWRecModified;
	a: TDEPrmStr;
  fl: boolean;
  ams: TArrStr;
  sb: TClipboardBuf;
begin
	AddStack('TDWFld.KeyLb1ProcKey',Self);
  inherited;
  if ArrIntMatch(Key,[K_F2,K_F3,K_F7,K_Shift_V]) or (LsStr.Count>0) then case Key of
  	K_F2: begin
      for i:=0 to RecGet.Items.Count-1 do begin
        p:=GetRDB(i);
        if p.lMod then begin
          if not IfThenNotify(prCreate,p.r) then TDWPrm.VarCreate(p.r);
          p.lMod:=false;
        end;
      end;
      PageSynchro; TDWPrm.Execute(dw,SearchInfo,aFormHelp,aFormHelpFileProc,aFormHelpFilePrm); SetKeyForm;
    end;
    // Скопировать в фиксированный массив
    K_F3: deFix.Execute;
  	// Добавить/скопировать/вставить описание вводимого поля
    K_F4,K_F7,K_Shift_V: begin
      RowBeforeApp:=oRow;
      case Key of
        K_F4: s:=LsStr[oRow-1];
        K_F7: begin
          s:=sDWFldDef; lAppNew:=true;
        end;
        K_Shift_V: s:=PClpBrd^;
      end;
      i:=LsStr.Add(s)+1; 
      if i>1 then LsFld.AddSt;
      LsFld.Row:=i; LsFld.CurStUpdate; PnEdRead; PnEd.SetFocus;
    end;
    // Редактировать
    K_F5,K_Enter: PnEd.SetFocus;
    // Удалить
    K_F8: begin
    	p:=SeekRDB; fl:=false;
      s:=AnsiUpperCase(Trim(p.r.NameRec)+'.'+Trim(VarGet.MenuName(Rec['RecFld'])));
      for i:=0 to LsStr.Count-1 do if TrimUpper(DEGetArrParam(LsStr[i])[deRelation])=s then begin
        fl:=true; break;
      end;
      if fl then CopyFrom(ams,['Вводимому полю "'
        +TRecDBDef.DWVarName(p.r.NameRec,Trim(VarGet.MenuName(Rec['RecFld'])))+'"',
        'подчинены другие поля.','Удалить это поле со снятием связи его с подчинёнными ?'])
      else CopyFrom(ams,amsDel);
      if Ask(ams,true) then begin
        if fl then for i:=0 to LsStr.Count-1 do begin
          a:=DEGetArrParam(LsStr[i]);
          if TrimUpper(a[deRelation])=s then begin
            a[deRelation]:=''; LsStr[i]:=DESetArrParam(a);
          end;
        end;
        DelStr;
      end;
    end;
    // Страницы
    K_F11: begin
      PageSynchro;
      with DWPage do if LsPg.Count>0 then begin
        sb.AddSt(LsPg.Count); SearchInfo:=Self.SearchInfo; ShowModal;
        {i:=1;
        if SearchInfo.NumObj>=0 then i:=SearchInfo.NumPage;
        sb.Row:=i; ShowModal;}
      end;
    end;
    // Редактирование формы
    K_Ctrl_F5: begin
    	fl:=not dw.DcmBased; s:=dw.DcmDef;
	    if fl then begin
        FldList(d,w); TDefEdit.ConvertToForm(dw.SortMode,w,dw.DcmDef);
      end;
    	if TEdGenFr.EdFormEd(@dw.DcmDef,PrFldList,PrEdSay,IfThen(fl,defrmSetMod)) {and fl} then begin
        dw.DcmBased:=true; SetKeyForm;
      end
      else dw.DcmDef:=s;
    end;
    // Печать
    K_Ctrl_F6: begin
    	ls1.Clear; PrnLsAdd(ls1,dw.SaveToStr); PrnTxtExec(ls1.Text);
    end;
    // Выше
    K_Ctrl_Up: Move(oRow,oRow-1);
    // Ниже
    K_Ctrl_Down: Move(oRow,oRow+1);
    // Скопировать описание вводимого поля
  	K_Shift_C: begin
      sb:=TClipboardBuf.CreateWrite(cbrdDWFld,ClpBrdLastVers);
      try
        sb.WriteString(LsStr[LsFld.Row-1]);
      finally
        sb.Free;
      end;
    end;
  // Поиск
  else if WinFindKey(Key,RbPanel2,prFind,[fnoRegistr,fnoWord,fnoReplace]) then
    if Assigned(SearchTree) then with SearchTree do begin
      Tree.ClearPrim;
      if Execute(dw.SetSearchNode(nil,aInfo),i) then begin
        SearchInfo:=aInfo[i]; TimerSearch(nil);
      end;
    end;
  end;
  DelStack;
end;

class procedure TDWFld.PrnLsAdd;
var Prm: TLogTrnsValPrm;
begin
  AddStack('TDWFld.PrnLsAdd');
  if not empty(Wnd) then begin
    Prm.Opt:=[]; TWinLogCompare.ExecuteStr(Prm,Wnd,Wnd); LsArrList(Prm.val,LsPrn,CRLF,false);
  end;
  DelStack;
end;

procedure TDWFld.DelStr;
var i: longint;
begin
  AddStack('TDWFld.DelStr',Self);
  LsStr.Delete(oRow-1);
  for i:=oRow+1 to LsFld.RowCount-1 do LsFld.Rows[i-1].Assign(LsFld.Rows[i]);
  LsFld.RowCount:=max(2,LsFld.RowCount-1);
  if LsStr.Count=0 then LsFld.Rows[LsFld.RowCount-1].Text:=''
  else LsFld.Row:=min(IfThen(RowBeforeApp<0,oRow,RowBeforeApp),LsStr.Count);
  PnEdRead;
  DelStack;
end;

function TDWFld.prFind;
var s: string;
  cnt: longint;
begin
	AddStack('TDWFld.prFind',Self);
  dw.Fields:=LsStr.Text; s:=dw.SaveToStr;
  with FindProperty do if Replace then begin
    cnt:=DataWinReplaceIdent(dw,s,sf,sr,[gfrNoIdent,gfrNoOnlyFml]);
    if cnt>0 then begin
      LsStr.Text:=dw.Fields; FreeAndNil(SearchTree);
      result:=not Ask([Format('Заменено: %d.',[cnt]),'Повторить поиск с заменой ?'],true,'Поиск с заменой');
    end
    else result:=false;
  end
  else begin
    result:=DataWinSearchIdent(dw,s,sf,aInfo,false);
    if result then TSearchTree.Init(sf);
  end;
  DelStack;
end;

procedure TDWFld.LsFldSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  AddStack('TDWFld.LsFldSelectCell',Self);
  PnEdRead(ARow);
  DelStack;
end;

// Переместить мышью
procedure TDWFld.LsFldMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: longint);
var ACol: longint;
begin
	AddStack('TDWFld.LsFldMouseDown',Self);
  inherited;
	if not flMove and (Button=mbLeft) then begin
	  LsFld.MouseToCell(X,Y,ACol,ARow); flMove := ARow>0; LsFld.NoSel:=false; 
  end;
  DelStack;
end;

procedure TDWFld.LsFldMouseMove(Sender: TObject; Shift: TShiftState; X,Y: longint);
var ACol,nr: longint;
begin
	AddStack('TDWFld.LsFldMouseMove',Self);
  inherited;
	if flMove then begin
	  LsFld.MouseToCell(X,Y,ACol,nr);
  	if (nr>0) and (nr<>ARow) then begin
		  Move(ARow,nr); ARow:=nr;
    end;
  end;
  DelStack;
end;

procedure TDWFld.LsFldMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: longint);
begin
	AddStack('TDWFld.LsFldMouseUp',Self);
  inherited;
	flMove:=false;
  DelStack;
end;

// Переместить переменную с позиции oi на ni
procedure TDWFld.Move;
begin
	AddStack('TDWFld.Move',Self);
  if ListMoveItem(oi,ni,1,LsStr.Count,PrMove,[0]) then begin
    LsFld.Row:=ni; PnEdRead;
  end;
  DelStack;
end;

procedure TDWFld.PrMove;
var s: string;
begin
	AddStack('TDWFld.PrMove',Self);
  s:=LsFld.Rows[ni].Text; LsFld.Rows[ni].Assign(LsFld.Rows[oi]); LsFld.Rows[oi].Text:=s;
  LsStr.Exchange(ni-1,oi-1);
  DelStack;
end;

procedure TDWFld.ERecExit(Sender: TObject);
begin
	AddStack('TDWFld.ERecExit',Self);
	with ENoReadOnly do if ogReadOnly in Options then VarValue:=false;
  DelStack;
end;

function TDWFld.IsReadOnly;
begin
	AddStack('TDWFld.IsReadOnly',Self);
  result := not IfThenValid(fAccess,Sender);
  DelStack;
end;

procedure TDWFld.FldList;
begin
	AddStack('TDWFld.FldList',Self);
  sWnd:=LsStr.Text; IfThenDWFldList(fListProc,sDat,sWnd);
  DelStack;
end;

procedure TDWFld.FormClose(Sender: TObject; var Action: TCloseAction);
var s: string;
begin
	AddStack('TDWFld.FormClose',Self);
  inherited;
  PageSynchro; dw.Fields:=LsStr.Text; dw.Pages:=DWPage.LsPg.Text;
  if not dw.Equals(odw) then AskFormSave(Self,Action);
  if Action=caHide then begin
    if ModalResult=mrOk then
      if not dw.IsAllFldInDcm(s) then
        if not Ask(['Данное "'+s+'" отсутствует в форме.','Сохранить описание окна редактирования ?'])
        then Action:=caNone;
  end;
  DelStack;
end;

procedure TDWFld.FormShow(Sender: TObject);
begin
	AddStack('TDWFld.FormShow',Self);
  inherited;
  if SearchInfo.NumObj>=0 then
    if Assigned(tmSearch) then tmSearch.Enabled:=true
    else begin
      tmSearch:=TTimer.Create(Self); tmSearch.Interval:=1; tmSearch.OnTimer:=TimerSearch;
    end;
  DelStack;
end;

procedure TDWFld.TimerSearch;
begin
	AddStack('TDWFld.TimerSearch',Self);
  if Assigned(tmSearch) then tmSearch.Enabled:=false;
  with SearchInfo do begin
    if TypeObj in [dwsZgl,dwsForm,dwsGF]
    then KeyLb1.ExecKey(IfThen((TypeObj in [dwsZgl,dwsGF]) and (NumPage>0), K_F11, K_F2))
    else begin
      LsFld.Row:=LsFld.FixedRows+NumObj; PnEdRead;
      if TypeObj=dwsFldMask then begin
        EdTextInitFind:=true; EMask.SetFocus; KeyLb1.ExecKey(K_F5); 
      end;
    end;
    NumObj:=-1;
  end;
  DelStack;
end;

procedure TDWFld.EMaskChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
var g: TCustomGet;
begin
  AddStack('TDWFld.EMaskChange',Self);
  if SeekGet(g) then MaskGet.TextReadOnly:=g.MaskTextReadOnly else MaskGet.TextReadOnly:=false;
  if not MaskGet.TextReadOnly then Rec['Mask']:=Rec['MaskView'];
  DelStack;
end;

procedure TDWFld.PnEdEscape(Sender: TObject; var Action: TCloseAction);
begin
  AddStack('TDWFld.PnEdEscape',Self);
  lAppNew:=false;
  if RowBeforeApp>=0 then DelStr;
  DelStack;
end;

procedure TDWFld.PnEdExitType(Sender: TObject; ExitType: TPEExitType);
begin
  RowBeforeApp:=-1; lAppNew:=false;
end;

procedure TDWFld.PnEdEnter(Sender: TObject);
begin
	AddStack('TDWFld.PnEdEnter',Self);
  AddPrnHead(DlmBetween(LsFldCalcZn(Sender,0),LsFldCalcZn(Sender,1),': '));
  DelStack;
end;

procedure TDWFld.PnEdExit(Sender: TObject);
begin
	AddStack('TDWFld.PnEdExit',Self);
  DelPrnHead;
  DelStack;
end;

// Скопировать в фиксированный массив
procedure TDWFld.deFixPnlCngKey(Sender: TObject; var tb: TKeyBut);
begin
	AddStack('TDWFld.deFixPnlCngKey',Self);
  with tb do if Key=K_F10 then Caption:='Выполнить';
  DelStack;
end;

procedure TDWFld.deFixFldExit(Sender: TObject);
var tf,tf1: TFldEdit;
begin
	AddStack('TDWFld.deFixFldExit',Self);
  tf:=pointer(Sender);
  if tf.NameRecFld='FIXKA' then begin
    tf1:=deFix.FldEdit['FixNAME'];
    if empty(tf1.VarValue) then tf1.VarValue:=ArrFixGet.CodeName(tf,tf.VarValue,[cdgBufAll]);
  end;
  DelStack;
end;

function TDWFld.deFixFldCheck(Sender: TObject): Boolean;
begin
	AddStack('TDWFld.deFixFldCheck',Self);
  NoEmpCheck(Sender,'FIXKA',result);
  DelStack;
end;

function TDWFld.deFixPnlValid(Sender: TObject): Boolean;
var rdb: PDWRecModified;
	i: longint;
  s: string;
  a: TDEPrmStr;
label lend;
begin
	AddStack('TDWFld.deFixPnlValid',Self);
  result:=false;
  if not RDBArrv.Seek(RDBArrv.TblFldName(fARRV)+'='+QQs(Rec['FixKA'])) then begin
    RDBArrv.NewRec; RDBArrv[fARRV]:=Rec['FixKA'];
  end
  else if not Ask(['Указанный массив уже существует.','Заменить его описание ?']) then goto lend;
  if not SeekRDB(rdb) then goto lend;
  s:=rdb.r.DWTrans;
  if not TDWVid.ConvertToFix(RDBArr,s) then goto lend;
  RDBArrv[DWMem]:=s; ls1.Text:=LsStr.Text;
  for i:=0 to ls1.Count-1 do begin
  	a:=DEGetArrParam(ls1[i]); a[deNameRec]:=RDBArr.NameRec; ls1[i]:=DESetArrParam(a);
  end;
  dw.Fields:=ls1.Text; RDBArrv[DWMem(postWin)]:=dw.SaveToStr; RDBArrv[fNAME]:=Rec['FixNAME'];
  RDBArrv.AppUpdRec; ProgPswd.SendUpd(updCodeGet,true); result:=true;
lend:
  DelStack;
end;

procedure TDWFld.WMFormLimit;
var i: TDWVidForm;
begin
	AddStack('TDWFld.WMFormLimit',Self);
  inherited;
  for i:=low(aForm) to high(aForm) do if FreeLimit(aForm[i]) then break;
  DelStack;
end;

function TDWFld.PrFldList;
var ls: TFldList;
	i,l,npg: longint;
  ap: TDEPrmStr;
  s,w: string;
  p: PFldInf;
  mr: TListF2Result;
  a: TArrStr;
begin
	AddStack('TDWFld.PrFldList',Self);
  dw.Fields:=LsStr.Text; FldList(s,w);
  if w='' then result:=false
  else begin
  	l:=0; TrimUpperSelf(txt); npg:=0;
    ls:=TFldList.Create; mr:=TListF2Result.Create;
    try
    	for i:=0 to LsArrDynamic(w,a,CRLF)-1 do begin
	    	ap:=DEGetArrParam(a[i]);
        if (i<>0) and StrToBoolean(ap[deNewPage]) then Inc(npg);
        if (DWPageNumEdit<0) or (npg=DWPageNumEdit) then begin
          s:=TRecDBDef.DWVarName(ap); MaxSelf(l,s); ls.Add(s);
        end;
      end;
	    ls.Fill(PrFldSeek,[fldfWithoutRelation,fldfArray]);
      for i:=0 to ls.Count-1 do if Pos(UnDelim,ls[i])=0 then begin
        p:=ls.GetInf(i); s:=p.rdb.DWVarName(ls[i]);
        mr.Add(Padr(s,l)+' '+p.DWFldInfo.DisplayLabel);
        if TrimUpper(s)=txt then mr.SelectStr:=mr.Count-1;
      end;
      result:=ListF2Down(mr.Text,mr,Sender,MinWidth,'Browl','',nil,0,nil,nil,nil,nil,nil,Capt);
     	if result then txt:=TrimRight(LeftStr(mr[mr.SelectStr],l));
    finally
      ls.Free; mr.Free;
    end;
  end;
  DelStack;
end;

function TDWFld.PrEdSay;
var i: longint;
  ap: TDEPrmStr;
  s,w: string;
  a: TArrStr;
begin
	AddStack('TDWFld.PrEdSay',Self);
  result:=PString(Sender)^; FldList(s,w); i:=LsArrDynamic(w,a,CRLF);
  if i>0 then begin
    s:=TrimUpper(result);
    for i:=0 to i-1 do begin
      ap:=DEGetArrParam(a[i]);
      if TrimUpper(TRecDBDef.DWVarName(ap))=s then begin
        if not empty(ap[deCaption]) then result:=StrTran(ap[deCaption],UnDelim,CRLF);
        break;
      end;
    end;
  end;
  DelStack;
end;

procedure TDWFld.PrFldSeek;
var s: string;
begin
	AddStack('TDWFld.PrFldSeek',Self);
  s:=rdb.DWTrans; FldList(s,dw.Fields); PrAdd(a,s,dw.SaveToStr,true); PrAdd(a,s); dw.Fields:=LsStr.Text;
  DelStack;
end;

procedure TDWFld.EMaskEnter(Sender: TObject);
begin
  AddStack('TDWFld.EMaskEnter',Self);
  KeyLb1.SetKey(K_Shift_C,'','Копировать строку параметров в буфер обмена',PrMask,'mask',kmEdit);
  KeyLb1.SetKey(K_Alt_B,'','Редактировать раздел помощи',PrMask,'mask',kmDesign,PrivDesign);
  DelStack;
end;

procedure TDWFld.EMaskExit(Sender: TObject);
begin
  AddStack('TDWFld.EMaskExit',Self);
  KeyLb1.DelKey(K_All,'mask');
  DelStack;
end;

procedure TDWFld.PrMask;
var g: TCustomGet;
  mh: TMaskHelp;
begin
  AddStack('TDWFld.PrMask',Self);
  case Key of
    K_Alt_B: if SeekGet(g) then
      if g.MaskHelp(mh) then THelpLs.Edit(mh.hf.sPage,mh.hf.sFile);
    K_Shift_C: Clipboard.AsText:=Rec['MASK'];
  end;
  DelStack;
end;

procedure TDWFld.PageSynchro;
begin
  PageSynchro(LsStr,DWPage.LsPg,dw);
end;

class procedure TDWFld.PageSynchro(lsField,lsPage: TStrings; dw: TDataWin);
begin
  DEPageSynchro(lsField,lsPage,dw.DcmBased,dw.DcmDef);
end;

procedure TDWFld.WMHelpFill;
var g: TCustomGet;
  mh: TMaskHelp;
begin
  AddStack('TDWFld.WMHelpFill',Self);
  inherited;
  with msg do if (Oper=hlpFile) and EMask.Active and SeekGet(g) then
    if g.MaskHelp(mh) then begin
      pFile.f[hlpfBase]:=mh.hf; ResFile:=true;
    end;
  DelStack;
end;

procedure TDWFld.ClpBrdCanPast;
var result: boolean;
  sb: TClipboardBuf;
  ost: longint;
begin
  ost:=AddStack('TDWFld.ClpBrdCanPast',Self);
  result:=false; sb:=TClipboardBuf.CreateRead(cbrdDWFld,ClpBrdLastVers);
  try
    try
      if sb.Active then begin
        if not Assigned(PClpBrd) then New(PClpBrd);
        sb.ReadString(PClpBrd^,rdtoCtrl); result:=true;
      end;
    except
      SetStack(ost);
    end;
  finally
    sb.Free;
  end;
  with KeyLb1 do
    if result then SetKey(K_Shift_V,'','Вставить описание вводимого поля',KeyLb1ProcKey,'lsbox',kmList)
    else begin
      DelKey(K_Shift_V,'lsbox'); DisposeClpBrd;
    end;
  DelStack;
end;

procedure TDWFld.WMChangeCBChain;
begin
  AddStack('TDWFld.WMChangeCBChain',Self);
  inherited;
  TClipboardBuf.ViewerChangeCBChain(ClpBrdViewer,Msg);
  DelStack;
end;

procedure TDWFld.WMDrawClipboard;
begin
  AddStack('TDWFld.WMDrawClipboard',Self);
  inherited;
  try
    ClpBrdCanPast;
  finally
    TClipboardBuf.ViewerDrawClipboard(ClpBrdViewer);
  end;
  DelStack;
end;

procedure TDWFld.DisposeClpBrd;
begin
  AddStack('TDWFld.DisposeClpBrd',Self);
  DisposeNil(PClpBrd);
  DelStack;
end;

{ TWinLogCompare }
type
  TWinLogCompareField = record
    dw: TDataWin;
    a: TDEPrmArrStr;
  end;

  TWinLogList = (wlogBase,wlogFields,wlogPages);

var nwlogFields,nwlogPages,nwlogDataWin: longint;
  awlogFields: array of TDEPrmArrStr;
  awlogPages: TArrArrStr;
  awlogDataWin: TArrDataWin;

class function TWinLogCompare.ListCreate;
var dw: TDataWin;
  a: TArrStr;
  i: longint;
begin
  AddStack('TWinLogCompare.ListCreate');
  case TWinLogList(pv) of
    wlogFields: begin
      if Length(awlogFields)=nwlogFields then SetLength(awlogFields,IfThen(nwlogFields=0,2,nwlogFields shl 1));
      i:=LsArrDynamic(Value,a,CRLF); SetLength(awlogFields[nwlogFields],i);
      for i:=0 to i-1 do awlogFields[nwlogFields,i]:=DEGetArrParam(a[i]);
      result:=pointer(nwlogFields); Inc(nwlogFields);
    end;
    wlogPages: begin
      if Length(awlogPages)=nwlogPages then SetLength(awlogPages,IfThen(nwlogPages=0,2,nwlogPages shl 1));
      LsArrDynamic(Value,awlogPages[nwlogPages],CRLF,lsaSetLen);
      result:=pointer(nwlogPages); Inc(nwlogPages);
    end;
  else
    if Value='' then result:=nil
    else begin
      if Length(awlogDataWin)=nwlogDataWin then SetLength(awlogDataWin,IfThen(nwlogDataWin=0,2,nwlogDataWin shl 1));
      dw:=TDataWin.CreateOne(awlogDataWin[nwlogDataWin]); Inc(nwlogDataWin); result:=dw;
      dw.LoadFromStr(Value);
    end;
  end;
  DelStack;
end;

class procedure TWinLogCompare.ListDestroy;
begin
  AddStack('TWinLogCompare.ListDestroy');
  case TWinLogList(pv) of
    wlogFields: begin
      Dec(nwlogFields); awlogFields[nwlogFields]:=nil;
    end;
    wlogPages: begin
      Dec(nwlogPages); awlogPages[nwlogPages]:=nil;
    end;
  else if Assigned(ls) then Dec(nwlogDataWin);
  end;
  DelStack;
end;

class function TWinLogCompare.GetCount;
begin
  AddStack('TWinLogCompare.GetCount');
  case TWinLogList(pv) of
    wlogFields: result:=Length(awlogFields[longint(ls)]);
    wlogPages: result:=Length(awlogPages[longint(ls)]);
  else result:=IfThen(Assigned(ls),1)
  end;
  DelStack;
end;

function LogCompareStrSort(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('FDWFld.LogCompareStrSort');
  with TDataWin(p) do result:=Trim(DEPgSortName(DcmBased,SortMode));
  DelStack;
end;

function LogCompareStrForm(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('FDWFld.LogCompareStrForm');
  with TDataWin(p) do if DcmBased then result:=StrDeShifr(DcmDef) else result:='';
  DelStack;
end;

function LogCompareStrFldNameRec(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var cr: TCustomRec;
begin
  AddStack('FDWFld.LogCompareStrFldNameRec');
  if RecName(PDEPrmStr(p)[deNameRec],cr,TRecDBDef) then result:=TRecDBDef(cr).DWName else result:='';
  DelStack;
end;

function LogCompareStrFldGet(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var g: TCustomGet;
begin
  AddStack('FDWFld.LogCompareStrFldGet');
  if NameGet(g,PDEPrmStr(p)^)
  then result:=DelTrim(g.RVid)+BrackNoEmp(DelTrim(g.RVName))
  else result:='отсутствует';
  DelStack;
end;

function LogCompareStrFldMask(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var a: PDEPrmStr;
  g: TCustomGet;
  lsPrn: TStringList;
begin
  AddStack('FDWFld.LogCompareStrFldMask');
  a:=p;
  if NameGet(g,a^) then begin
    lsPrn:=TStringList.Create;
    try
      g.MaskPrn(a[deMask],LsPrn); result:=LsPrn.Text;
    finally
      lsPrn.Free;
    end;
  end
  else result:='';
  DelStack;
end;

function LogCompareStrFldMaxLen(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var l: longint;
begin
  AddStack('FDWFld.LogCompareStrFldMaxLen');
  l:=Int0(PDEPrmStr(p)[deMaxLen]); result := IfThen((l>0) or (logpMod in Prm.Opt),IntToStr(l));
  DelStack;
end;

function LogCompareStrFldCharCase(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var l: TDECharCase;
begin
  AddStack('FDWFld.LogCompareStrFldCharCase');
  l:=DEArr2CharCase(PDEPrmStr(p)^); result:=IfThen((l<>deccNone) or (logpMod in Prm.Opt),aDECharCase[l]);
  DelStack;
end;

function LogCompareStrFldBool(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var fl: boolean;
begin
  AddStack('FDWFld.LogCompareStrFldBool');
  fl:=StrToBoolean(PString(p)^); result:=IfThen((fl=PBoolean(pv)^) or (logpMod in Prm.Opt),bRus[fl]);
  DelStack;
end;

function LogCompareStrFldRel(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('FDWFld.LogCompareStrFldRel');
  result:=TRecDBDef.DWVarNameRel(PDEPrmStr(p)^);
  DelStack;
end;

function LogCompareStrFldWH(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var i: longint;
begin
  AddStack('FDWFld.LogCompareStrFldWH');
  i:=Int0(PString(p)^);
  if (i=0) and not(logpMod in Prm.Opt)
    then result:=''
  else if InRange(i,low(aMinMaxDef),high(aMinMaxDef))
    then result:=aMinMaxDef[i]
  else result:=Format('%d симв.',[i]);
  DelStack;
end;

function LogCompareStrPgName(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
begin
  AddStack('FDWFld.LogCompareStrPgName');
  result:=DlmCopy(PString(p)^,1,1,UnDelim);
  DelStack;
end;

function LogCompareStrPgSort(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var DcmBased: boolean;
  SortMode: TSortMode;
begin
  AddStack('FDWFld.LogCompareStrPgSort');
  result:=DlmCopy(PString(p)^,2,1,UnDelim); DcmBased := result='0'; SortMode:=DEPgSortMode(result);
  result:=Trim(DEPgSortName(DcmBased,SortMode));
  DelStack;
end;

function LogCompareStrPgForm(const Prm: TLogTrnsValPrm; p,pv: pointer): string;
var a: array[1..3] of string;
begin
  AddStack('FDWFld.LogCompareStrPgForm');
  LsArrFill(PString(p)^,a,UnDelim);
  if a[2]='0' then result:=StrDeShifr(a[3]) else result:='';
  DelStack;
end;

class procedure TWinLogCompare.GetItem;
  procedure PgInfo(pg: boolean; odw,ndw: TDataWin);
  begin
    AddStack('TWinLogCompare.ExecuteStr.PgInfo');
    if pg
    then AddRes(Prm,odw.Pages,ndw.Pages,pointer(wlogPages),'страницы')
    else begin
      TStrLogCompare.AddRes(LogCompareStrSort,Prm,odw,ndw,nil,'сортировка');
      TDcmLogCompare.AddRes(LogCompareStrForm,Prm,odw,ndw,nil,'форма');
    end;
    DelStack;
  end;
var ao,an: PDEPrmStr;
  procedure sBool(const Capt: string; n: TDEPrmList; Value: boolean = true);
  begin
    AddStack('TWinLogCompare.GetItem.sBool');
    TStrLogCompare.AddRes(LogCompareStrFldBool,Prm,@ao[n],@an[n],@Value,Capt,1);
    DelStack;
  end;
  procedure sStr(const Capt: string; n: TDEPrmList);
  begin
    AddStack('TWinLogCompare.GetItem.sStr');
    TStrLogCompare.AddRes(LogCompareStrStr,Prm,@ao[n],@an[n],nil,Capt,1);
    DelStack;
  end;
  procedure wh(const Capt: string; n: TDEPrmList);
  begin
    AddStack('TWinLogCompare.GetItem.wh');
    TStrLogCompare.AddRes(LogCompareStrFldWH,Prm,@ao[n],@an[n],nil,Capt,1);
    DelStack;
  end;
var odw,ndw: TDataWin;
  pso,psn: PString;
  opg,npg: boolean;
  oOpt: TLogPrimOptions;
  s: string;
  nf: TDWForm;
begin
  AddStack('TWinLogCompare.GetItem');
  case TWinLogList(pv) of
    wlogFields: begin
      an:=@awlogFields[longint(lsn)][nn];
      case tp of
        clogKey: Prm.val:=an[deNameRec]+UnDelim+an[deNameRecFld];
        clogNoKey: Prm.val:=DESetArrParam(an^);
      else
        ao:=@awlogFields[longint(lso)][no];
        Prm.val:=TRecDBDef.DWVarName(an^);
        TStrLogCompare.AddRes(LogCompareStrFldNameRec,Prm,ao,an,nil,'вид данных',1);
        s:=UnDelim; TDlmLogCompare.AddRes(LogCompareStrStr,Prm,@ao[deCaption],@an[deCaption],@s,'наименование',1);
        TStrLogCompare.AddRes(LogCompareStrFldGet,Prm,ao,an,nil,'вид ввода',1);
        TCrlfLogCompare.AddRes(LogCompareStrFldMask,Prm,ao,an,nil,'параметры ввода',1);
        TStrLogCompare.AddRes(LogCompareStrFldMaxLen,Prm,ao,an,nil,'максимальная длина',1);
        TStrLogCompare.AddRes(LogCompareStrFldCharCase,Prm,ao,an,nil,'преобразование символов',1);
        sBool('выделять',deAutoSel,false);
        sBool('ввод пароля',dePassword);
        sBool('редактировать',deNoReadOnly,false);
        sBool('невидимое, если нередактируемое',deReadOnlyNoVsbl);
        sBool('невидимое',deNoVisible);
        sBool('в новой колонке/строке',deTag);
        sBool('с новой страницы',deNewPage);
        sBool('наименование справа',deSayRight);
        sBool('убрать пробелы слева',deTrimLeft);
        sStr('подсказка для наименования',deSayHint);
        sStr('подсказка для ввода',deGetHint);
        TStrLogCompare.AddRes(LogCompareStrFldRel,Prm,ao,an,nil,'подчинено',1);
        wh('ширина',deWidth); wh('высота',deHeight);
      end;
    end;
    wlogPages:
      if tp=clogKey then Prm.val:=IntToStr(nn)
      else begin
        psn:=@awlogPages[longint(lsn)][nn];
        if tp=clogNoKey then Prm.val:=psn^
        else begin
          pso:=@awlogPages[longint(lso)][no];
          TStrLogCompare.AddRes(LogCompareStrPgName,Prm,pso,psn,nil,'наименование');
          TStrLogCompare.AddRes(LogCompareStrPgSort,Prm,pso,psn,nil,'сортировка');
          TDcmLogCompare.AddRes(LogCompareStrPgForm,Prm,pso,psn,nil,'форма');
        end;
      end;
  else
    if tp<>clogKey then begin
      ndw:=lsn;
      if tp=clogNoKey then Prm.val:=ndw.SaveToStr
      else begin
        odw:=lso; opg := Pos(CRLF,TrimRight(odw.Pages))>0;
        npg := Pos(CRLF,TrimRight(ndw.Pages))>0;
        AddRes(Prm,odw.Fields,ndw.Fields,pointer(wlogFields),'вводимые поля');
        TStrLogCompare.AddRes(Prm,odw.Zgl,ndw.Zgl,nil,'заголовок');
        TStrLogCompare.AddRes(Prm,odw.AskByCancel,ndw.AskByCancel,'запрос на сохранение');
        if opg=npg then PgInfo(npg,odw,ndw)
        else begin
          oOpt:=Prm.Opt; Exclude(Prm.Opt,logpMod);
          PgInfo(opg,odw,odw); IncD(Prm.val,'->'); PgInfo(npg,ndw,ndw);
          Prm.Opt:=oOpt;
        end;
        for nf:=low(odw.aForm) to high(odw.aForm) do
          TCrlfLogCompare.AddRes(Prm,odw.aForm[nf],ndw.aForm[nf],nil,aDWFormSay[nf]);
      end;
    end;
  end;
  DelStack;
end;

class procedure TWinLogCompare.Execute(var Prm: TLogTrnsValPrm; r: TRecDBDef);
begin
  AddStack('TWinLogCompare.Execute');
  if Assigned(r) then with TDataWin do begin
    aGet.ReplaceNameRecSelf(Prm.val,'',r.NameRec); aFree;
  end;
  Execute(Prm);
  DelStack;
end;

{ TSpinMinMaxGet }
constructor TSpinMinMaxGet.Create;
begin
	AddStack('TSpinMinMaxGet.Create',Self);
  inherited Create(AOwner);
  RVid:='';
  DelStack;
end;

procedure TSpinMinMaxGet.SetMaxLen;
begin
  AddStack('TSpinMinMaxGet.SetMaxLen',Self);
  tm.MaxLength:=max(l,MaxSelf(aMinMaxDef));
  DelStack;
end;

function TSpinMinMaxGet.GetText;
begin
	AddStack('TSpinMinMaxGet.GetText',Self);
  if not AnsiFindText(TrimRight(tm.Text),aMinMaxDef,low(aMinMaxDef),result)
  then result := inherited GetText;
  DelStack;
end;

function TSpinMinMaxGet.SetText;
begin
	AddStack('TSpinMinMaxGet.SetText',Self);
  if InRange(n,low(aMinMaxDef),high(aMinMaxDef)) then result:=aMinMaxDef[n]
  else result := inherited SetText(n);
  DelStack;
end;

{ TNone }
class procedure TNone.LoadWait;
begin
	AddStack('TNone.LoadWait');
  CreateForm(TDWFld,aForm[nForm]); aForm[nForm].MainRebuild;
  DelStack;
end;

procedure Final;
var i: longint;
begin
	AddStack('FDWFld.finalization');
  for i:=low(awlogDataWin) to high(awlogDataWin) do awlogDataWin[i].Free;
  DelStack;
end;

initialization
	AddStack('FDWFld.initialization');
  MyTypes.c_EdFormEd:=c_EdFormEd;
  RecDB.DWFldExec:=DWFldExec;
  TInter.SetFunction('EdFormEd','',c_EdFormEd,null,0,'L');
  DelStack;
finalization
  Final;
end.
