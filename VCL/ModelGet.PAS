unit ModelGet;

interface

{$I LIBTEST}
uses
	Windows,SysUtils,Classes,Controls,DB,
  MyTypes,BufFile,RecVal,RecDB,MulQry,FStat,DefEdit,FFldedit,CCodeGet,Browl;

type
  TModelInterDefOper = (mdiVarName,mdiSeekName,mdiApp,mdiAfterLoad);

  TModelFmlUpdEvent = procedure(Sender: TObject; lAfter: boolean) of object;
  TModelUsedEvent = procedure(Sender: TObject; lsUsed: TStringList) of object;
  TModelUsedCodPrimEvent = function(Sender: TObject; const Cod: string; lPrim: boolean): string of object;
	TModelInterDefEvent = procedure(Sender: TObject; Oper: TModelInterDefOper; const av: array of variant; var result: variant) of object;
  TModelHelpEvent = procedure(Sender: TObject; var ht: THelpTbl) of object;
	TModelNSaveEvent = function(Sender: TObject): longint of object;
	TModelLoadEvent = procedure(Sender: TObject; FromEdit: boolean) of object;
	TModelCanSaveEvent = procedure(Sender: TObject; FromEdit: boolean; const FileName: TModelFile; var result: boolean) of object;

  TModelGet = class;
  TMGProcAll = procedure(Sender: TModelGet; const av: array of variant; var Aborted: boolean);
	TModelProcAllEvent = procedure(Sender: TObject; Proc: TMGProcAll; const av: array of variant; var Aborted: boolean) of object;

  PMGContainer = ^TMGContainer;
  TMGContainer = record
  	Vers: byte;
    Value: string;
  end;

  TMDSortType = (mstCod,mstName,mstDate);
  TMDSortInt = array[TMDSortType] of longint;

  TMDSaveList = (mdsvFromEdit,mdsvDoSave); TMDSaveOpt = set of TMDSaveList;
  TMDLoadList = (mdldCheckSum,mdldFromEdit,mdldDoLoad,mdldCloseBeforeLoad,mdldChkNSave); TMDLoadOpt = set of TMDLoadList;

  TModelGet = class(TCustomCodeGet)
  private
    { Private declarations }
    FPrefix: TModelFile;
    FFrmCaption: TCaption;
    FLastVers: byte;
    FMDFile: TModelFile;
    FMDName: TModelName;
    FMDFmlUpd,FMDPrimg: string;
   	FNmProc: TKeyLbNmProc;
    FUserArrStr: array[1..7] of string;
    FMDPrim: TModelPrim;
    FOnOwnerSave,FOnOwnerLoad,FOnModify: TNotifyEvent;
    FOnDefCod,FOnDefName: TStringEvent;
    FOnDefNSave: TModelNSaveEvent;
    FOnSave,FOnLoad: TModelLoadEvent;
    FOnFmlUpdate: TModelFmlUpdEvent;
    FOnUsedArr: TModelUsedEvent;
    FOnUsedCodPrim: TModelUsedCodPrimEvent;
	 	FOnProcKey: TKeyProc;
    FOnInterDef: TModelInterDefEvent;
    FOnCanSave: TModelCanSaveEvent;
    FOnHelp: TModelHelpEvent;
    FOnProcAll: TModelProcAllEvent;
    SvSum: longint;
		function GetUsedArrStr(Index: longint): string;
		procedure SetUsedArrStr(Index: longint; const Value: string);
   	procedure SetNmProc(Value: TKeyLbNmProc);
		class procedure ProcKey(key: longint; tw: TWinControl);
		function FWriteStr(const s: string; tp: TSaveType): longint;
		function FReadStr(tp: TSaveType): string;
    procedure StMDNew(Sender: TStat);
		procedure GrayName(tf: TFldEdit);
    function GetRecDB(Browl: TBrowl): TRecDB;
  protected
    { Protected declarations }
    FBuf: TFileBuf;
		procedure CreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
		procedure DoEnter(tf: TFldEdit); override;
		procedure DoExit(tf: TFldEdit); override;
    procedure StdListDown(tf: TFldEdit; const RectList: TRect;
      PozList: TPozList); override;
    procedure SetDefLenCode; override;
    procedure SetDefLenName; override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
    function DefNSave: longint; dynamic;
    function DoHelp: THelpTbl; dynamic;
  public
    { Public declarations }
    Vers: byte;
    NSave: longint;
    Root: TFileName;
		constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
		procedure MaskPrn(const Mask: string; LsPrn: TStringList); override;
		function List(var SelRow: TModelFile; DoLoad: TProcValid = nil; const Capt: string = '';
      LsMDNew: TStringList = nil; Browl: TBrowl = nil): boolean; overload;
		function List(LsMDNew: TStringList = nil; Browl: TBrowl = nil;
      DoLoad: TProcValid = nil; const Capt: string = ''): boolean; overload;
		function Add(Browl: TBrowl = nil; FromEdit: boolean = false): boolean;
		procedure LoadList(ls: TStringList; SortType: TMDSortType);
    function DefCod: string; dynamic;
    function DefName: string; dynamic;
    procedure FmlUpdate(lAfter: boolean); dynamic;
    procedure Modify; dynamic;
		function Update(const OldName,NewName: TModelFile; OldNSave: longint;
      lLoad: boolean = false): boolean;
		function CanUpdate: boolean;
    function InterDef(Oper: TModelInterDefOper; const av: array of variant; const Def: variant): variant; dynamic;
		function Path: TFileName;
    procedure SaveToFile(const FileName: TModelFile; const Name: TModelName;
    	const Prim: TModelPrim; const Primg,FmlUpd: string; NumSave: longint;
      Opt: TMDSaveOpt = []; StSave: PMGContainer = nil);
    function LoadFromFile(const FileName: TModelFile; Options: TMDLoadOpt = [];
      StLoad: PMGContainer = nil): boolean; overload;
		procedure WriteVal(const Value: variant; tp: TSaveType);
		procedure WriteFixStr(const st: string; ln: longint = 1);
		function WriteStr(const s: string): longint;
		procedure WriteStr1(const s: string);
		function ReadVal(tp: TSaveType): variant; overload;
		function ReadVal(usl: boolean; tp: TSaveType; const Def: variant): variant; overload;
		function ReadFixStr(ln: longint = 1): string; overload;
		function ReadFixStr(usl: boolean; const Def: string = bFalse; ln: longint = 1): string; overload;
		function ReadStr(VersByte: byte = MaxByte): string; overload;
		function ReadStr(usl: boolean; VersByte: byte = MaxByte): string; overload;
		function ReadStr1: string; overload;
		function ReadStr1(usl: boolean): string; overload;
    procedure ModelNew(q: TMulQuery; var LsMDNew: TStringList; fqCod: TField; Obj: TControl;
      LsUsed: PStringList = nil); overload;
    procedure ModelNew(Browl: TBrowl; var LsMDNew: TStringList; fqCod: TField; LsUsed: PStringList = nil); overload;
    procedure ModelNew(Browl: TBrowl; var LsMDNew: TStringList; LsUsed: PStringList = nil); overload;
		function ModelUpdList(LsMDNew: TStringList): boolean;
		procedure UsedArr(lsUsed: TStringList);
    function EmpCodApp(Sender: TObject): boolean;
		class procedure UpdDBList;
    function UsedCodPrimDef(const Cod: string; lPrim: boolean; var res: string): boolean;
    property MDFile: TModelFile read FMDFile;
    property MDName: TModelName read FMDName;
    property MDPrim: TModelPrim read FMDPrim;
    property MDFmlUpd: string read FMDFmlUpd;
    property MDPrimg: string read FMDPrimg;
  published
    { Published declarations }
    property FrmCaption: TCaption read FFrmCaption write FFrmCaption;
    property LastVers: byte read FLastVers write FLastVers;
   	property NmProc: TKeyLbNmProc read FNmProc write SetNmProc;
    property Prefix: TModelFile read FPrefix write FPrefix;
    property UsedTableName:  string index 1 read GetUsedArrStr write SetUsedArrStr;
    property UsedFieldName:  string index 2 read GetUsedArrStr write SetUsedArrStr;
    property UsedFieldNSave: string index 3 read GetUsedArrStr write SetUsedArrStr;
    property UsedFieldCod:   string index 4 read GetUsedArrStr write SetUsedArrStr;
    property UsedFieldPrim:  string index 5 read GetUsedArrStr write SetUsedArrStr;
    property UsedWhere:      string index 6 read GetUsedArrStr write SetUsedArrStr;
    property OnCanSave: TModelCanSaveEvent read FOnCanSave write FOnCanSave;
    property OnDefCod: TStringEvent read FOnDefCod write FOnDefCod;
    property OnDefName: TStringEvent read FOnDefName write FOnDefName;
    property OnDefNSave: TModelNSaveEvent read FOnDefNSave write FOnDefNSave;
    property OnFmlUpdate: TModelFmlUpdEvent read FOnFmlUpdate write FOnFmlUpdate;
    property OnInterDef: TModelInterDefEvent read FOnInterDef write FOnInterDef;
    property OnHelp: TModelHelpEvent read FOnHelp write FOnHelp;
    property OnLoad: TModelLoadEvent read FOnLoad write FOnLoad;
    property OnModify: TNotifyEvent read FOnModify write FOnModify;
    property OnOwnerLoad: TNotifyEvent read FOnOwnerLoad write FOnOwnerLoad;
    property OnOwnerSave: TNotifyEvent read FOnOwnerSave write FOnOwnerSave;
	 	property OnProcAll: TModelProcAllEvent read FOnProcAll write FOnProcAll;
	 	property OnProcKey: TKeyProc read FOnProcKey write FOnProcKey;
    property OnSave: TModelLoadEvent read FOnSave write FOnSave;
    property OnUsedArr: TModelUsedEvent read FOnUsedArr write FOnUsedArr;
    property OnUsedCodPrim: TModelUsedCodPrimEvent read FOnUsedCodPrim write FOnUsedCodPrim;
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

  TMGProcAllDop = procedure(Before: boolean; var lCreate: boolean);

  TMGLsOper = (mglsCreate,mglsShow,mglsProcKey);

function ModelGetVar(const v: variant): TModelGet;
function MdLsModel: TModelGet;
function ModelGetProcAll(Proc: TMGProcAll; const av: array of variant; const StatCapt: string = ''): boolean;
function MdSavePrepare(var a: TArrStr; var lr: longint): boolean;
procedure MdSaveExec(const a: TArrStr; lr: longint);
procedure AddFrom(Proc: TMGProcAllDop); overload;
function IfThen(AValue: boolean; ATrue: TMDSaveList): TMDSaveOpt; overload;
function IfThen(AValue: boolean; ATrue: TMDLoadList): TMDLoadOpt; overload;
procedure Register;

var
  lNSave: longint;
  MDDirExec: function(const sPath,ToPath: TFileName; AModel: TModelGet;
    var SelRow: string; lCopy: boolean): boolean;
  MGLsProc: procedure(oper: TMGLsOper; const av: array of variant);
  ModelLoadProc: TModelLoadEvent;

implementation

uses
  Math,Graphics,Forms,Variants,StrUtils,Grids,Messages,StdCtrls,
  My_pr,KeyLb,Inter,Schem,FrmEmpty,StrBrowl,KeyMenu,ComboGet,ButGet,FCngNum,FSchemDM,FrmPswd,PnlEdit,
  MemoGet,ListF2,FEdText;

type
  TFillOpt = set of (fillNoMod,fillTopLeft);

  TMDLs = class(TFormEmp)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
  private
    { Private declarations }
    sb: TStringBrowl;
    de: TDefEdit;
    Rec: TRecVal;
    deDir: TDefEdit;
    CodGet: TComboGet;
	  ls,lsUsed: TStringList;
    aPrim: TModelPrim;
    FSortType: TMDSortType;
    Model: TModelGet;
    FFromEdit: boolean;
		function FList(mg: TModelGet; var SelRow: TModelFile; FromEdit: boolean; DoLoad: TProcValid;
      const Capt: string): boolean;
    procedure sbMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: longint);
    procedure sbAfterPaint(Sender: TObject);
    procedure sbBeforeDrawCell(Sender: TObject; ACol,ARow: longint;
      Rect: TRect; State: TGridDrawState);
    function sbCalcZn(Sender: TObject; ACol: longint): String;
    procedure deFrmShow(Sender: TObject);
    procedure deFldExit(Sender: TObject);
    procedure deFldChange(Sender: TObject; const OldVal: Variant; FromShow: Boolean);
    function deFldCheck(Sender: TObject): Boolean;
    function dePnlValid(Sender: TObject): Boolean;
    procedure ButFormGet1BeforeClick(Sender: TObject);
    procedure ButFormGet1AfterClick(Sender: TObject);
    procedure deDirPnlCngKey(Sender: TObject; var tb: TKeyBut);
    function deDirPnlValid(Sender: TObject): Boolean;
		function CngCheck(Sender: TObject): boolean;
		procedure SetSortType(v: TMDSortType);
		function PrimNSave: longint; overload;
		function PrimNSave(NSave: longint): longint; overload;
		procedure LoadPrim;
		procedure SaveToPrim(var Prim: TModelPrim);
		procedure FillList(const SelectRow: string; Opt: TFillOpt = []);
    procedure FillStr(const Name,Primg: string; nSave,ARow: longint);
  	procedure WMSaveIni(var Msg: TWMSaveIni); message WM_SAVEINI;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
		procedure WMHelpFill(var Message: TMessage); message WM_HELPFILL;
  public
    { Public declarations }
  end;

  TMDThemesGet = class(TMemoGet)
  protected
    function KeyDop: string; override;
    procedure ProcKey(key: longint; tw: TWinControl); override;
  end;

var aForm: array of TMDLs;
  nForm: longint;
  aMDAppRdb: PArrStr;
  aProcAllDop: array of record
    lCreate: boolean;
    Proc: TMGProcAllDop;
  end;
  lsThemes: TStringList;
  AutorDef: string;
  Qry: TMulQuery;

procedure Proc(oper: TMGLsOper; const av: array of variant);
begin
  AddStack('ModelGet.Proc');
  if Assigned(MGLsProc) then MGLsProc(oper,av);
  DelStack;
end;

procedure IfThenModelLoad(Proc: TModelLoadEvent; Sender: TObject; FromEdit: boolean);
begin
  if Assigned(Proc) then Proc(Sender,FromEdit);
end;

function IfThen(AValue: boolean; ATrue: TMDSaveList): TMDSaveOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function IfThen(AValue: boolean; ATrue: TMDLoadList): TMDLoadOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

{ TModelGet }
constructor TModelGet.Create;
begin
	AddStack('TModelGet.Create',Self);
	//clrmsgfile;
	//addmsgfile('Create');
  FBuf:=nil;
	inherited Create(AOwner);
  FNmProc:=TKeyLbNmProc.Create; SetDefLenCode; SetDefLenName;
  if csDesigning in ComponentState then begin
	  UsedFieldName:=fMODEL; UsedFieldNSave:=fNMODEL; UsedFieldPrim:=fNAME;
  end;
  DelStack;
end;

destructor TModelGet.Destroy;
begin
	AddStack('TModelGet.Destroy',Self);
  FNmProc.Free; 
  inherited Destroy;
  DelStack;
end;

function TModelGet.GetUsedArrStr;
begin
  AddStack('TModelGet.GetUsedArrStr',Self);
  result:=FUserArrStr[Index];
  DelStack;
end;

procedure TModelGet.SetUsedArrStr;
begin
  AddStack('TModelGet.SetUsedArrStr',Self);
  FUserArrStr[Index]:=Value;
  DelStack;
end;

procedure TModelGet.SetNmProc;
begin
	AddStack('TModelGet.SetNmProc',Self);
  NmProc.Assign(Value);
  DelStack;
end;

{ Создать объекты }
procedure TModelGet.CreateObj;
begin
	AddStack('TModelGet.CreateObj',Self);
	//addmsgfile('CreateObj');
	inherited CreateObj(tf);
	if AssignObj(tf) then begin
    eC.ReadOnly:=true; eN.ReadOnly:=true; tf.ReCreateObj;
  end;
  DelStack;
end;

procedure TModelGet.PaintObj;
begin
	AddStack('TModelGet.PaintObj',Self);
  inherited PaintObj(tf);
  if AssignObj(tf) then GrayName(tf);
  DelStack;
end;

procedure TModelGet.GrayName;
var ts: TSchem;
begin
  AddStack('TModelGet.GrayName',Self);
  if not(ogReadOnly in tf.Options) then begin
    if csDesigning in ComponentState then ts:=nil else SchemName(tf.Schem,ts);
    eN.Color:=IfThen(RightStr(eN.Text,2)='*)',
      ts.IfThenColor(dColor2,clBtnFace),ts.IfThenColor(dColor1,clWindow));
  end;
  DelStack;
end;

// Достать значение Value из объектов
function TModelGet.GetValue;
begin
	AddStack('TModelGet.GetValue',Self);
	//addmsgfile('GetValue');
	AssignObj(tf); result:=PadR(IfThenGetText(eC),FDefLenCode);
  DelStack;
end;

// Установить свойства объектов в соответствии с Value
procedure TModelGet.SetValue;
var sn: string;
  f: TFld;
begin
	AddStack('TModelGet.SetValue',Self);
	//addmsgfile('SetValue');
  if AssignObj(tf) then begin
    if LoadFromFile(v) then begin
      sn:=TrimRight(FMDName); f:=RecFldName(tf.NameRec,tf.Mask);
      if Assigned(f) then IncD(sn,Format('(%d'+IfThen(NSave>f.Value,'*')+')',[longint(f.Value)]));
    end
    else sn:='';
    eC.Text:=v; eN.Text:=sn; GrayName(tf);
  end;
  DelStack;
end;

{ Действия при получении фокуса }
procedure TModelGet.DoEnter;
var tl: TKeyLb;
begin
	AddStack('TModelGet.DoEnter',Self);
	//addmsgfile('DoEnter');
	inherited DoEnter(tf);
	if AssignObj(tf) then GetParentForm(tf).ActiveControl:=eC;
  if FormKeyLb(tf,tl) and not(ogReadOnly in tf.Options) then begin
   	tl.SetKey(K_Space,'','',ProcKey,'modelget',kmNone,'',K_F2);
    tl.ReDrw;
  end;
  DelStack;
end;

{ Действия при утере фокуса }
procedure TModelGet.DoExit;
var tl: TKeyLb;
begin
	AddStack('TModelGet.DoExit',Self);
	//addmsgfile('DoExit');
  if FormKeyLb(tf,tl)
  //and Assigned(GetParentForm(tf).ActiveControl)
	then tl.DelKey(K_All,'modelget');
	inherited DoExit(tf);
  DelStack;
end;

{ Реакция на клавиши }
class procedure TModelGet.ProcKey;
begin
	AddStack('TModelGet.ProcKey');
  FormKeyLb(tw).ExecKey(K_F2);
  DelStack;
end;

{ Длина кода по умолчанию }
procedure TModelGet.SetDefLenCode;
begin
	AddStack('TModelGet.SetDefLenCode',Self);
	//addmsgfile('SetDefLenCode');
  FDefLenCode:=MDLenFile;
  DelStack;
end;

{ Длина наименования по умолчанию }
procedure TModelGet.SetDefLenName;
begin
	AddStack('TModelGet.SetDefLenName',Self);
	//addmsgfile('SetDefLenName');
  FDefLenName:=MDLenName+lNSave+3;
  DelStack;
end;

function GetLs: TMdLs;
begin
  AddStack('ModelGet.GetLs');
  if Length(aForm)=nForm then SetLength(aForm,nForm+1);
  CreateForm(TMdLs,aForm[nForm]); result:=aForm[nForm]; Inc(nForm);
  DelStack;
end;

procedure FreeLs;
begin
  AddStack('ModelGet.FreeLs');
  Dec(nForm); FormFree(aForm[nForm]);
  DelStack;
end;

// Вызов выпадающего списка
procedure TModelGet.StdListDown;
var s: TModelFile;
	w: longint;
  fl: boolean;
begin
	AddStack('TModelGet.StdListDown',Self);
  if AssignObj(tf) then with GetLs do try
    fl := WindowState<>wsMaximized;
    if fl then begin
      SaveIniForm; BoundsRect:=SysWorkArea;
      w:=max(KeyLb1.WMin,sb.Width+RbPanel2.BevPanel2+10);
      BoundsRect:=RectList;
      ClientWidth:=max(ClientWidth,w);
      FormOnScreen;
    end;
    s:=tf.Value;
    if FList(Self,s,true,nil,'') then begin
      tf.Value:=s; tf.Write;
    end
    else tf.Value:=eC.Text;
    if fl then RestIniForm;
  finally
    FreeLs;
  end;
  DelStack;
end;

function TModelGet.List(var SelRow: TModelFile; DoLoad: TProcValid = nil; const Capt: string = '';
  LsMDNew: TStringList = nil; Browl: TBrowl = nil): boolean;
begin
	AddStack('TModelGet.List',Self);
  SetLogVid(logvMDLoad);
  try
    result:=GetLs.FList(Self,SelRow,false,DoLoad,Capt);
  finally
    FreeLs;
  end;
  if result then begin
    if Assigned(LsMDNew) then ModelUpdList(LsMDNew);
    if Assigned(Browl) then Browl.BrUpdate;
  end;
  SetLogVid;
  DelStack;
end;

function TModelGet.List(LsMDNew: TStringList = nil; Browl: TBrowl = nil;
  DoLoad: TProcValid = nil; const Capt: string = ''): boolean;
var r: TRecDB;
  SelRow: TModelFile;
begin
  AddStack('TModelGet.List(r)',Self);
  SetLogVid(logvMDLoad); r:=GetRecDB(Browl);
  if Assigned(r) then begin
    SelRow:=r[UsedFieldName]; result:=List(SelRow,DoLoad,Capt,LsMDNew);
    if result then begin
      r[UsedFieldName]:=SelRow; r.UpdateRec(true);
      if Assigned(Browl) then Browl.BrUpdate;
    end;
  end
  else result:=false;
  SetLogVid;
  DelStack;
end;

function TModelGet.GetRecDB;
var f: TField;
begin
  AddStack('TModelGet.GetRecDB',Self);
  if RecName(UsedTableName,TCustomRec(result),TRecDB) then
    if Assigned(Browl) then if Browl.FindQuery then
      if Browl.Qry.FindField(fRECNO,f) then result.GotoRec(f);
  DelStack;
end;

function TModelGet.Add;
var FileName: TModelFile;
begin
	AddStack('TModelGet.Add',Self);
  SetLogVid(logvEditRec);
  GetRecDB(Browl); ForceDirectories(Path);
  with GetLs do try
  	Model:=Self; LoadList(CodGet.Items,mstCod);
    Rec['COD']:=DefCod; Rec['NAME']:=''; aPrim:=nil; Rec['FmlUpd']:=''; Rec['NSAVE']:=DefNSave;
    de.FrmCaption:='Создать основу'; de.Param[0,deNoReadOnly]:=bTrue;
    result:=de.Execute.Saved;
    if result then begin
      FileName:=Rec['COD'];
      if Assigned(FOnCanSave) then FOnCanSave(Self,FromEdit,FileName,result);
      if result then begin
        LogFields.Clear; SaveToPrim(FMDPrim);
        SaveToFile(FileName,Rec['NAME'],FMDPrim,Rec['PRIMG'],Rec['FmlUpd'],Rec['NSAVE'],
          IfThen(FromEdit,mdsvFromEdit)+[mdsvDoSave]);
        Modify;
      end;
    end;
  finally
    FreeLs;
  end;
  if result and Assigned(Browl) then Browl.BrUpdate;
  SetLogVid;
  DelStack;
end;

var paSort: pointer;

function CompName(List: TStringList; Index1, Index2: longint): Integer;
  function paGet(Index: longint): string;
  begin
    AddStack('ModelGet.CompName.paGet');
    result:=PArrStr(paSort)^[IntObj(List,Index)];
    DelStack;
  end;
begin
  AddStack('ModelGet.CompName');
  Result:=AnsiCompareText(paGet(Index1),paGet(Index2));
  DelStack;
end;

function CompDate(List: TStringList; Index1, Index2: longint): Integer;
  function paGet(Index: longint): TDateTime;
  begin
    AddStack('ModelGet.CompDate.paGet');
    result:=PArrDate(paSort)^[IntObj(List,Index)];
    DelStack;
  end;
begin
  AddStack('ModelGet.CompDate');
  Result:=CompSign(paGet(Index1),paGet(Index2));
  DelStack;
end;

procedure TModelGet.LoadList;
var i,n: longint;
	sr: TSearchRec;
  s: string;
  an: TArrStr;
  ad: TArrDate;
begin
	AddStack('TModelGet.LoadList',Self);
  case SortType of
    mstName: SetLength(an,10);
    mstDate: SetLength(ad,10);
  end;
  ForceDirectories(Path); ls.Clear; i:=FindFirst(Path+'*',faAnyFile-faDirectory,sr);
  while i=0 do begin
    s:=TrimUpper(sr.Name);
    if SortType=mstCod then ls.Add(s)
    else begin
      n:=ls.Count; ls.AddObject(s,pointer(n));
      case SortType of
        mstName: begin
          if Length(an)=n then SetLength(an,n shl 1);
          LoadFromFile(s); an[n]:=FMDName;
        end;
        mstDate: begin
          if Length(ad)=n then SetLength(ad,n shl 1);
          ad[n]:=FileDateToDateTime(sr.Time);
        end;
      end;
    end;
    i:=FindNext(sr);
  end;
  SysUtils.FindClose(sr);
  case SortType of
    mstCod: begin
      ls.Sorted:=true; ls.Sorted:=false;
    end;
    mstName: begin
      paSort:=@an; ls.CustomSort(CompName);
    end;
    mstDate: begin
      paSort:=@ad; ls.CustomSort(CompDate);
    end;
  end;
  DelStack;
end;

// Сохранить в файл
procedure TModelGet.SaveToFile;
var i: longint;
	v: byte;
begin
	AddStack('TModelGet.SaveToFile',Self);
  ForceDirectories(Path);
  FMDFile:=TrimRight(FileName); FMDName:=Name;
  CopyFrom(FMDPrim,Prim); FMDFmlUpd:=FmlUpd; FMDPrimg:=Primg; NSave:=NumSave;
  if not IfThenNotify(FOnOwnerSave,Self) then begin
    FBuf:=TFileBuf.Create(Path+FMDFile,true);
    try
      if FBuf.Active then begin
        SvSum:=0;
        if not(mdsvDoSave in Opt) and Assigned(StSave) then v:=StSave.Vers else v:=FLastVers;
        WriteVal(v,stByte); WriteVal(4,stByte); // При изменении редактировать Помощь-Библиотека-Содержимое-Основа
        WriteFixStr(FMDName,MDLenName); WriteVal(NSave,stLongWord); WriteStr(TrimRight(FMDPrimg));
        TCustomBuf.SaveModelPrim(FMDPrim,WriteVal,WriteStr,NSave); WriteStr(TrimRight(FMDFmlUpd));
        if mdsvDoSave in Opt
          then IfThenModelLoad(FOnSave,Self,mdsvFromEdit in Opt)
        else if Assigned(StSave) then with StSave^ do
          for i:=1 to Length(Value) do WriteVal(Ord(Value[i]),stByte);
        WriteVal(SvSum,stLongWord);
      end;
      TFileBuf(FBuf).Update(true);
    finally
      FreeAndNil(FBuf);
    end;
  end;
  DelStack;
end;

// Сохранить строку
function TModelGet.WriteStr;
begin
	AddStack('TModelGet.WriteStr',Self);
	result:=FWriteStr(s,stInteger);
  DelStack;
end;

// Сохранить строку длиной не более 255 символов
procedure TModelGet.WriteStr1;
begin
	AddStack('TModelGet.WriteStr1',Self);
	FWriteStr(s,stByte);
  DelStack;
end;

function TModelGet.FWriteStr;
begin
	AddStack('TModelGet.FWriteStr',Self);
	result:=Length(s); WriteVal(result,tp); WriteFixStr(s,result);
  DelStack;
end;

// Сохранить строку фиксированной длины
procedure TModelGet.WriteFixStr;
var i: longint;
	s: string;
begin
	AddStack('TModelGet.WriteFixStr',Self);
	s:=Padr(st,ln);
  for i:=1 to ln do WriteVal(Byte(s[i]),stByte);
  DelStack;
end;

// Сохранить одну переменную
procedure TModelGet.WriteVal;
var sr: TSaveRec;
	Count,i: byte;
begin
	AddStack('TModelGet.WriteVal',Self);
	Count:=FBuf.Write(Value,tp); VarToSvRec(Value,tp,sr);
  // Формирование контрольной суммы
  for i:=1 to Count do Inc(SvSum,Byte(sr.s[i]));
  DelStack;
end;

// Считать из файла
function TModelGet.LoadFromFile(const FileName: TModelFile; Options: TMDLoadOpt = [];
  StLoad: PMGContainer = nil): boolean;
const MaxBuf = 16*KByte;
var i,j: longint;
  MDVers: byte;
  s: string;
label lend;
begin
	AddStack('TModelGet.LoadFromFile',Self);
	result:=true;
  if mdldCloseBeforeLoad in Options then FreeAndNil(FBuf)
  else if Assigned(FBuf) then
  	if FBuf.Active then goto lend;
  FBuf:=TFileBuf.Create(Path+FileName);
  try
  	result:=FBuf.Active;
  	if result then begin
    	FMDFile:=FileName;
    	if mdldCheckSum in Options then begin
        // Проверка контрольной суммы
        SvSum:=0; i:=FBuf.Seek(-SizeOfVar[stInteger],soFromEnd);
        if i>0 then begin
          FBuf.Seek(0,soFromBeginning);
          SetLength(s,MaxBuf);
          while i>0 do begin
            j:=min(i,FBuf.ReadStr(s)); Dec(i,j);
            for j:=1 to j do Inc(SvSum,Byte(s[j]));
          end;
          FBuf.Seek(-SizeOfVar[stInteger],soFromEnd);
          result := SvSum=FBuf.Read(stInteger);
          FBuf.Seek(0,soFromBeginning);
        end
        else result:=false;
        if not result then mess_ok(['Нарушено содержимое файла:',Path+FileName]);
      end;
      if result then begin
        Vers:=ReadVal(stByte); MDVers:=ReadVal(stByte);
        FMDName:=ReadFixStr(MDLenName); NSave:=ReadVal(MDVers>=1,stLongWord,0);
        if mdldChkNSave in Options then begin
          i:=DefNSave;
          if NSave<i then result:=Ask(['Внимание !',
            Format('Версия основы (%d) меньше существующей (%d).',[NSave,i]),'Продолжить ?'],false);
        end;
        if result then begin
          FMDPrimg:=ReadStr(MDVers>=4);
          if mdldCheckSum in Options then begin
            if MDVers<3 then begin
              SetLength(FMDPrim,1);	FMDPrim[0].NumSave:=NSave; FMDPrim[0].Prim:=ReadStr;
            end
            else FBuf.ReadModelPrim(FMDPrim);
            i:=Length(FMDPrim);
            if i>0 then with FMDPrim[i-1] do
              if empty(Date) then Date:=My_pr.GetFileDateTime(Path+FileName);
            FMDFmlUpd:=ReadStr(MDVers>=2);
            if mdldDoLoad in Options then begin
              IfThenModelLoad(FOnLoad,Self,mdldFromEdit in Options);
              IfThenModelLoad(ModelLoadProc,Self,mdldFromEdit in Options);
            end
            else if Assigned(StLoad) then with StLoad^ do begin
              Vers:=Self.Vers; FBuf.ReadString(Value,rdtoCtrl);
            end;
          end;
        end;
      end;
    end;
  finally
    FreeAndNil(FBuf);
  end;
lend:
	DelStack;
end;

// Считать строку
function TModelGet.ReadStr(VersByte: byte = MaxByte): string;
begin
	AddStack('TModelGet.ReadStr',Self);
	result:=FReadStr(TSaveType(IfThen(Vers<VersByte,byte(stInteger),byte(stByte))));
  DelStack;
end;

function TModelGet.ReadStr(usl: boolean; VersByte: byte = MaxByte): string;
begin
  if usl then result:=ReadStr(VersByte) else result:='';
end;

// Считать строку длиной не более 255 символов
function TModelGet.ReadStr1: string;
begin
	AddStack('TModelGet.ReadStr1',Self);
	result:=FReadStr(stByte);
  DelStack;
end;

function TModelGet.ReadStr1(usl: boolean): string;
begin
  if usl then result:=ReadStr1 else result:='';
end;

function TModelGet.FReadStr;
begin
	AddStack('TModelGet.FReadStr',Self);
	result:=ReadFixStr(longint(ReadVal(tp)));
  DelStack;
end;

// Считать строку фиксированной длины
function TModelGet.ReadFixStr(ln: longint = 1): string;
begin
	AddStack('TModelGet.ReadFixStr',Self);
  result:=FBuf.ReadStr(ln);
  DelStack;
end;

function TModelGet.ReadFixStr(usl: boolean; const Def: string = bFalse; ln: longint = 1): string;
begin
  if usl then result:=ReadFixStr(ln) else result:=Def;
end;

// Считать одну переменную
function TModelGet.ReadVal(tp: TSaveType): variant;
begin
	AddStack('TModelGet.ReadVal',Self);
	result:=FBuf.Read(tp);
  DelStack;
end;

function TModelGet.ReadVal(usl: boolean; tp: TSaveType; const Def: variant): variant;
begin
	AddStack('TModelGet.ReadVal(Def)',Self);
	result:=FBuf.Read(usl,tp,Def);
  DelStack;
end;

function TModelGet.DefCod;
var r: TCustomRec;
begin
	AddStack('TModelGet.DefCod',Self);
	if not IfThenStr(result,FOnDefCod,Self) then if RecName(UsedTableName,r) then begin
    result:=r[UsedFieldName];
    if empty(result) then result:=r[UsedFieldCod];
  end;
  DelStack;
end;

function TModelGet.DefName;
var r: TCustomRec;
begin
	AddStack('TModelGet.DefName',Self);
	if not IfThenStr(result,FOnDefName,Self) then if RecName(UsedTableName,r) then result:=r[UsedFieldPrim];
  DelStack;
end;

function TModelGet.DefNSave;
var r: TCustomRec;
begin
	AddStack('TModelGet.DefNSave',Self);
	if Assigned(FOnDefNSave)
    then result:=FOnDefNSave(Self)
  else if RecName(UsedTableName,r)
    then result:=r[UsedFieldNSave]
  else result:=0;
  DelStack;
end;

function TModelGet.DoHelp;
begin
  AddStack('TModelGet.DoHelp',Self);
  with result do begin
    Head:=AnsiUpperCase(FPrefix); Dat0:=' - '+FLow(FFrmCaption); SetLength(Dat,1); Dat[0]:=nil;
    if Assigned(FOnHelp) then FOnHelp(Self,result);
  end;
  DelStack;
end;

procedure TModelGet.FmlUpdate;
begin
	AddStack('TModelGet.FmlUpdate',Self);
  if Assigned(FOnFmlUpdate) then FOnFmlUpdate(Self,lAfter);
  DelStack;
end;

function TModelGet.Update;
var v: variant;
begin
  AddStack('TModelGet.Update',Self);
  result:=true;
  if lLoad then if FileExists(Path+NewName) then result:=LoadFromFile(NewName,[mdldCheckSum]);
  if CanUpdate then begin
    FmlUpdate(false);
    result:=EvalStringsChk(v,[IfThen(TrimRight(OldName)=TrimRight(NewName),OldNSave,NSave)],
      FMDFmlUpd,'Действия при обновлении версии основы','L');
    FmlUpdate(true);
    if result and (MyVarType(v)=V_BOOL) then result:=v;
  end;
  DelStack;
end;

function TModelGet.CanUpdate;
begin
	AddStack('TModelGet.CanUpdate',Self);
  result:=not empty(FMDFmlUpd);
  DelStack;
end;

procedure TModelGet.Modify;
begin
  AddStack('TModelGet.Modify',Self);
  IfThenNotify(FOnModify,Self);
  DelStack;
end;

function TModelGet.InterDef;
begin
  AddStack('TModelGet.InterDef',Self);
  result:=Def;
  if Assigned(FOnInterDef) then FOnInterDef(Self,Oper,av,result);
  DelStack;
end;

procedure TModelGet.UsedArr;
begin
  AddStack('TModelGet.UsedArr',Self);
  lsUsed.Clear;
  if Assigned(FOnUsedArr) then FOnUsedArr(Self,lsUsed)
  else if Assigned(ProgPswd) then with ProgPswd.GetQuery do begin
  	PartSelect(UsedTableName,UsedFieldName,
      DlmBetween(UsedFieldName+'<>'+QQs,BrackNoEmp(UsedWhere),sAND),'',UsedFieldName);
    while not Eof do begin
    	lsUsed.Add(TrimRight(Fields[0].AsString)); Next;
    end;
  	ProgPswd.FreeQuery;
  end;
  DelStack;
end;

function TModelGet.Path;
begin
	AddStack('TModelGet.Path',Self);
	result:=IfThen(Root='',ExeDir,Root)+DirModels+FPrefix+PathDelim;
  DelStack;
end;

function TModelGet.MaskTrans;
var s: string;
	i: longint;
  fl: boolean;
begin
	AddStack('TModelGet.MaskTrans');
	if MyVarType(av)=varArray then result:=IsNilc(av[1],'')
  else begin
    s:='';
    if Assigned(r) then begin
      fl:=r.Active; r.Active:=true;
      for i:=0 to r.FieldCount-1 do IncD(s,CRLF+r.FieldName[i]);
      r.Active:=fl;
    end;
    result:=ArrVarToVar(
      [VarArrayOf([mpCombo,'Имя поля версии',av,s,UnDelim+'10'])
      ]);
  end;
  DelStack;
end;

procedure TModelGet.MaskPrn;
begin
	AddStack('TModelGet.MaskPrn',Self);
  if not empty(Mask) then LsPrn.Add('Имя поля версии: '+Mask);
  DelStack;
end;

procedure TModelGet.FMaskHelp;
var n: byte;
begin
  AddStack('TModelGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+2);
  Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr('«Имя поля версии»'));
  DelStack;
end;

procedure TModelGet.ModelNew(q: TMulQuery; var LsMDNew: TStringList; fqCod: TField; Obj: TControl;
  LsUsed: PStringList = nil);
begin
  AddStack('TModelGet.ModelNew',Self);
  if Assigned(LsUsed) then FreeAndNil(LsUsed^);
  if Assigned(LsMDNew) then LsMDNew.Clear else LsMDNew:=SortStrListCreate;
  ShowStat('Поиск устаревших',StMDNew,[LongInt(q),LongInt(LsMDNew),LongInt(fqCod)]);
  Obj.Refresh;
  DelStack;
end;

procedure TModelGet.ModelNew(Browl: TBrowl; var LsMDNew: TStringList; fqCod: TField; LsUsed: PStringList = nil);
begin
  ModelNew(Browl.Qry,LsMDNew,fqCod,Browl,LsUsed);
end;

procedure TModelGet.ModelNew(Browl: TBrowl; var LsMDNew: TStringList; LsUsed: PStringList = nil);
begin
  ModelNew(Browl,LsMDNew,Browl.FieldSeek);
end;

procedure TModelGet.StMDNew;
var bm: TBookMark;
  i,lr: longint;
  fqCod,fqName,fqModel,fqNModel: TField;
begin
	AddStack('TModelGet.StMDNew',Self);
  fqCod:=PointerVar(Sender.Params[2]);
  with MulQueryVar(Sender.Params[0]) do begin
    fqName:=FindField(UsedFieldPrim); fqModel:=FindField(UsedFieldName); fqNModel:=FindField(UsedFieldNSave);
    DisableControls; bm:=GetBookMark;
    try
      lr:=RecordCount; First;
      for i:=1 to lr do begin
        if Sender.SayStat('',Trim(fqCod.AsString)+'.'+Trim(fqName.AsString),i/lr) then break;
        if LoadFromFile(TrimRight(fqModel.AsString)) then
          if NSave>fqNModel.AsInteger
          then StringListVar(Sender.Params[1]).Add(TrimRight(fqCod.AsString));
        Next;
      end;
      GotoBookMark(bm);
    finally
      FreeBookMark(bm);
    end;
    EnableControls;
  end;
  DelStack;
end;

function TModelGet.ModelUpdList;
var s: string;
  at: TArrStr;
  function fVar(const f: string): boolean;
  var af: array[1..2] of string;
    t: longint;
    r: TCustomRec;
  begin
    AddStack('TModelGet.ModelUpdList.fVar',Self);
    if ListAsArray(f,af,'.')>1 then begin
      t:=AnsiIndexText(af[1],at); s:=af[2];
    end
    else begin
      t:=0; s:=af[1];
    end;
    result:=RecName(at[t],r);
    if result then s:=r[s];
    DelStack;
  end;
var i: longint;
begin
  AddStack('TModelGet.ModelUpdList',Self);
  result:=false;
  if Assigned(LsMDNew) then begin
    LsArrDynamic(UsedTableName,at,',',lsaSetLen);
    if fVar(UsedFieldCod) then if LsMDNew.Find(TrimRight(s),i) then
      if fVar(UsedFieldName) then if LoadFromFile(s) then
        if NSave<=DefNSave then begin
          LsMDNew.Delete(i); result:=true;
        end;
  end;
  DelStack;
end;

procedure FldNoVisible(Sender: TFldEdit; const av: array of variant);
begin
  AddStack('ModelGet.FldNoVisible');
  Sender.Visible:=false;
  DelStack;
end;

function TModelGet.EmpCodApp;
var r: TRecDB;
  i: longint;
  SelRow: TModelFile;
  pe: TPanelEdit;
begin
  AddStack('TModelGet.EmpCodApp',Self);
  result:=true;
  if RecName(UsedTableName,TCustomRec(r),TRecDB) then if r.RecNo=0 then begin
    i:=r.NumFromName(UsedFieldCod);
    if empty(r.ValueNum[i]) then begin
      pe:=pointer(Sender); SelRow:=''; result:=List(SelRow,TNoneProc.ValidFalse);
      if result then begin
        r.ValueNum[i]:=SelRow; result:=r.KodCheck(UsedFieldCod);
        if result then begin
          r.AppRec; //r[UsedFieldName]:=SelRow;
          ChildFldAll(pe,FldNoVisible,[],false);
          result:=LoadFromFile(SelRow,[mdldCheckSum,mdldDoLoad]);
          if not result then r.DelRec;
        end
        else r.ValueNum[i]:='';
      end;
      if not result then pe.FldFocus:=pe.Fields[UsedFieldCod];
    end
  end;
  DelStack;
end;

procedure StUpdDBList1(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var lsp,lsf: TStringList;
	i,j: longint;
begin
	AddStack('ModelGet.StUpdDBList1');
  lsp:=PointerVar(Params[0]); i:=Params[1]; lsf:=PointerObj(lsp,i);
  for j:=0 to lsf.Count-1 do begin
    if Sender.SayStat('',lsf[j],(j+1)/lsf.Count) then break;
    with ProgPswd.CurQuery do begin
	    SetArrayList(sV_LIST,[QQs(lsp[i]),QQs(lsf[j])]); ExecPart(sI_TABLE);
    end;
  end;
  DelStack;
end;

procedure StUpdDBList(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var lsp,lsf: TStringList;
	i,jp,lr: longint;
  q: TMulQuery;
  p,f: string;
begin
  AddStack('ModelGet.StUpdDBList');
  lsp:=SortStrListCreate; q:=ProgPswd.GetQuery;
  try
  	GetMaskFiles(lsp,ExeDir+DirModels+'*.*',[fmDir]);
    for i:=0 to lsp.Count-1 do begin
      lsf:=SortStrListCreate; GetMaskFiles(lsf,ExeDir+DirModels+lsp[i]+PathDelim+'*.*');
      lsp.Objects[i]:=lsf;
    end;
  	with q do begin
    	PartSelect(tMDLIST,[fMDPrefix,fNAME],'',GetList([fMDPrefix,fNAME]),GetList([fMDPrefix,fNAME]));
      lr:=RecordCount;
      for i:=1 to lr do begin
      	p:=TrimRight(Fields[0].AsString); f:=TrimRight(Fields[1].AsString);
	    	if Sender.SayStat('',p+PathDelim+f,i/lr) then break;
        if PointerObjFind(lsp,p,pointer(lsf),jp) then 
          if FindDelFree(lsf,f) then lsp.Delete(jp);
      	Next;
      end;
    end;
    for i:=0 to lsp.Count-1 do begin
    	if Sender.SayStat('',lsp[i],(i+1)/lsp.Count) then break;
      if ShowStat(lsp[i],StUpdDBList1,[LongInt(lsp),i],TStringList(lsp.Objects[i]).Count) then begin
      	Aborted:=true; break;
      end;
    end;
  finally
    FreeObjects(lsp); ProgPswd.FreeQuery;
  end;
  DelStack;
end;

class procedure TModelGet.UpdDBList;
begin
  AddStack('TModelGet.UpdDBList');
  ShowStat('Фиксация списка существующих основ',StUpdDBList);
  DelStack;
end;

function TModelGet.UsedCodPrimDef;
begin
  AddStack('TModelGet.UsedCodPrimDef',Self);
  result:=not Assigned(OnUsedCodPrim);
  if not result then res:=OnUsedCodPrim(Self,Cod,lPrim);
  DelStack;
end;

{ TMDLs }
const aColSort: TMDSortInt = (0,1,3);
  DateFmt = 'dd/mm/yyyy (hh:nn)';

procedure TMDLs.FormCreate;
var inf: TStrBrInfZn;
  a: TDEPrmVar;
  bg: TButFormGet;
begin
	AddStack('TMDLs.FormCreate',Self);
  Menu:=TKeyMenu.Create(Self);
  with KeyLb1 do NmProc.Text:=ArrayAsList(
    [GetKeySt(K_Esc,'Отмена','',kmFile)
    ,GetKeySt(K_Enter,'Выбор','',kmList)
    ,GetKeySt([K_F10],K_Enter)
    ,GetKeySt(K_F3,'Сменить','Сменить код',kmList)
    ,GetKeySt(K_F5,'Редактировать','',kmList)
    ,GetKeySt(K_F7,'Добавить','',kmList)
    ,GetKeySt(K_F8,'Удалить','',kmList)
    ,GetKeySt(K_Ctrl_F3,'Из др.папки','Копирование основ из другой папки',kmServic)
    ,GetKeySt(K_Ctrl_F4,'В др.папку','Копирование основ в другую папку',kmServic)
    ,GetKeySt(K_Ctrl_F7,'','Загрузка основ с сервера',kmServic)
    ,GetKeySt(K_Ctrl_F8,'','Копирование основ на сервер',kmServic,'SUPER')
    ,GetKeySt(K_F11,'Сортировка','',kmList)
    ,GetKeySt(SelNoUsedKey)
    ,GetKeySt(K_Ctrl_F5,'','Установить код основы',kmList)
    ],CRLF);
  with RbPanel2 do begin
    Schem:=SchemDM.Browl.CaptSmall;
    sb:=TStringBrowl.Create(Self);
    with sb do begin
      Parent:=RbPanel2;
      Options:=[goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goRowSizing,goColSizing,goRowSelect];
      inf:=InfoCol[0];
      CopyFrom(inf.aName,'Код'); inf.Alignment:=taLeftJustify; InfoCol[0]:=inf;
      inf.aName[0]:='Наименование'; InfoCol[1]:=inf;
      inf.aName[0]:='Версия'; inf.Alignment:=taRightJustify; InfoCol[2]:=inf;
      inf.aName[0]:='Дата'; inf.Alignment:=taCenter; inf.LenData:=18; InfoCol[3]:=inf;
      inf.aName[0]:='Примечание'; inf.Alignment:=taLeftJustify; inf.LenData:=0; InfoCol[4]:=inf;
      SelectedOnlyFocused:=false;
      OnMouseUp:=sbMouseUp; OnAfterPaint:=sbAfterPaint; OnBeforeDrawCell:=sbBeforeDrawCell;
      OnCalcZn:=sbCalcZn;
    end;
  end;
  Rec:=TRecVal.Create(Self);
  with Rec do begin
    CreateFld('DIR',ftString,60,InitFIni[fiSave].ReadString('Model','Dir'),'Папка с основами');
    CreateFld('NSAVE',ftInteger,0,0,'Версия');
    CreateFld('DATE',ftString,Length(DateFmt),'','Дата');
    CreateFld('AUTOR',ftString,10,'','Автор');
    CreateFld('FMLUPD',ftMemo,0,'','Действия при обновлении версии основы');
    CreateFld('COD',ftString,MDLenFile,''); CreateFld(fNAME,ftString,MDLenName,'');
    CreateFld('PRIMG',ftMemo,0,''); CreateFld('PRIM',ftMemo,0,''); CreateFld('THEMES',ftMemo,0,'');
  end;
  CodGet:=TComboGet.Create(Self);
  with CodGet do begin
    VName:=StrNum('ModelCod',nForm); Duplicates:=dupIgnore; Sorted:=true; LenName:=MDLenFile;
  end;
  bg:=TButFormGet.Create(Self);
  with bg do begin
    Caption:='Действия при обновлении версии основы'; VName:=StrNum('MDUpdate',nForm);
    OnBeforeClick:=ButFormGet1BeforeClick; OnAfterClick:=ButFormGet1AfterClick;
  end;
  de:=TDefEdit.Create(Self);
  with de do begin
    NameWnd:='Model'; PnlAskByCancel:=true;
    OnFrmShow:=deFrmShow; OnFldExit:=deFldExit; OnFldChange:=deFldChange; OnFldCheck:=deFldCheck;
    OnPnlValid:=dePnlValid; OnMessage:=WMHelpFill;

    InitArr(a);
    a[deCaption]:='Код';
    a[deNameRec]:=Rec.NameRec;
    a[deNameRecFld]:='COD';
    CodGet.AssignGet(a);
    a[deCharCase]:=Succ(ecUpperCase);
    a[deAutoSel]:=true;
    a[deNoReadOnly]:=true;
    a[deTrimLeft]:=true;
    CreateFld(a);

    a[deCaption]:='Наименование';
    a[deNameRecFld]:=fNAME;
    TSimpleGet.AssignGetClass(a);
    a[deCharCase]:=Succ(ecNormal);
    CreateFld(a);

    a[deCaption]:='';
    a[deNameRecFld]:='PRIMG';
    SchemDM.MemoGet1.AssignGet(a);
    a[deMask]:=',,,3,Примечание';
    a[deAutoSel]:=false;
    a[deTrimLeft]:=true;
    a[deWidth]:=wallDefault;
    CreateFld(a);

    a[deCaption]:='Версия';
    a[deNameRecFld]:='NSAVE';
    SchemDM.SpinGet1.AssignGet(a);
    a[deMask]:='0,9999';
    a[deAutoSel]:=true;
    a[deTrimLeft]:=false;
    a[deWidth]:=0;
    CreateFld(a);

    a[deCaption]:='Дата';
    a[deNameRecFld]:='DATE';
    TSimpleGet.AssignGetClass(a);
    a[deMask]:='';
    a[deNoReadOnly]:=false;
    CreateFld(a);

    a[deCaption]:='Автор';
    a[deNameRecFld]:='AUTOR';
    a[deNoReadOnly]:=true;
    CreateFld(a);

    a[deCaption]:='';
    a[deNameRecFld]:='THEMES';
    TMDThemesGet.CreateOne.AssignGet(a);
    a[deMask]:=',,,3,Темы';
    a[deAutoSel]:=false;
    a[deTrimLeft]:=true;
    a[deWidth]:=wallDefault;
    CreateFld(a);

    a[deNameRecFld]:='PRIM';
    SchemDM.MemoGet1.AssignGet(a);
    a[deMask]:=',,,3,Последние изменения';
    a[deHeight]:=-1;
    CreateFld(a);

    a[deCaption]:='';
    a[deNameRecFld]:='FMLUPD';
    bg.AssignGet(a);
    a[deMask]:=cButFormMax+','+cButFormMax;
    a[deAutoSel]:=true;
    a[deNewPage]:=true;
    a[deTrimLeft]:=false;
    CreateFld(a);

    Pages[0]:='Общие';
    Pages[1]:='Формула';
  end;
  deDir:=TDefEdit.Create(Self);
  with deDir do begin
    NameWnd:='ModelDir'; OnPnlCngKey:=deDirPnlCngKey; OnPnlValid:=deDirPnlValid;
    a[deCaption]:='Папка';
    a[deNameRecFld]:='DIR';
    SchemDM.DirGet1.AssignGet(a);
    a[deMask]:='Выбор папки с основами';
    a[deTrimLeft]:=true;
    a[deHeight]:=0;
    a[deNewPage]:=false;
    CreateFld(a);
  end;
  inherited;
  ls:=TStringList.Create;
  with InitFIni[fiSave] do
    if ValueExists('MDList','SortDate') then begin
      FSortType:=iif(ReadBool('MDList','SortDate'),mstDate,mstCod);
      DeleteKey('MDList','SortDate');
    end
    else FSortType:=TMDSortType(ReadInteger('MDList','SortType',byte(mstCod)));
  Proc(mglsCreate,[longint(KeyLb1)]);
  DelStack;
end;

procedure TMDLs.FormDestroy;
begin
	AddStack('TMDLs.FormDestroy',Self);
  InitFIni[fiSave].WriteInteger('MDList','SortType',byte(FSortType));
	ls.Free; FreeAndNil(lsUsed); 
  inherited;
  DelStack;
end;

function TMDLs.FList;
var i: longint;
  opt: TMDLoadOpt;
begin
	AddStack('TMDLs.FList',Self);
  if empty(mg.FPrefix) then result:=false
  else with mg do begin
    Model:=mg; FFromEdit:=FromEdit; Caption:=IfThen(Capt='',FrmCaption,Capt); FillList(SelRow); KeyLb1.DelKey(K_All,'dop');
    for i:=0 to FNmProc.Count-1 do KeyLb1.SetKeySt(FNmProc[i],FOnProcKey,'dop');
    KeyLb1.Redrw; result := ShowModal in [mrOk,mrYes];
    if result then begin
      SelRow:=sb.Cells[0,sb.Row];
      if ModalResult=mrOk then if IfThenValid(DoLoad,Self) then begin
        opt:=[mdldChkNSave]+IfThen(FromEdit,mdldFromEdit);
        if Assigned(FOnOwnerLoad) then begin
          FMDFile:=SelRow; LoadFromFile(SelRow,opt); FOnOwnerLoad(Model);
        end
        else LoadFromFile(SelRow,opt+[mdldCheckSum,mdldDoLoad]);
      end;
    end;
  end;
  DelStack;
end;

procedure TMDLs.FormShow;
begin
	AddStack('TMDLs.FormShow',Self);
  inherited;
  FreeAndNil(lsUsed); Proc(mglsShow,[longint(KeyLb1)]);
  DelStack;
end;

function TMDLs.sbCalcZn;
var l: longint;
begin
	AddStack('TMDLs.sbCalcZn',Self);
  case ACol of
    0: l:=MDLenFile;
    1: l:=MDLenName;
    2: l:=lNSave;
    4: l:=200;
  else l:=0;
  end;
	result:=Space(l);
  DelStack;
end;

procedure TMDLs.FillList;
var i,j: longint;
	SelRow: string;
  otl: TGridCoord;
begin
	AddStack('TMDLs.FillList',Self);
	SetRedraw(sb);
	otl:=sb.TopLeft; sb.Init; SelRow:=TrimRight(SelectRow);
	Model.LoadList(ls,FSortType); sb.Cells[1,sb.RowCount-1]:='[нет основы]';
  for i:=0 to ls.Count-1 do begin
    Model.LoadFromFile(ls[i]); j:=sb.RowCount; sb.IncRowCount;
    sb.Cells[0,j]:=ls[i]; FillStr(Model.MDName,Model.MDPrimg,Model.NSave,j);
    if SelRow=TrimRight(ls[i]) then sb.Row:=j;
  end;
  if fillTopLeft in Opt then sb.TopLeft:=otl;
  MainRebuild; SetRedraw(sb,rdrwSet);
  if not(fillNoMod in Opt) then Model.Modify;
  DelStack;
end;

procedure TMDLs.FillStr;
begin
  AddStack('TMDLs.FillStr',Self);
  sb.Cells[1,ARow]:=Name;
  sb.Cells[2,ARow]:=SpaceStr(NSave,lNSave);
  sb.Cells[3,ARow]:=FormatDateTime(DateFmt,My_pr.GetFileDateTime(Model.Path+sb.Cells[0,ARow]));
  sb.Cells[4,ARow]:=DelTrim(StrTran(Primg,CRLF,' '));
  DelStack;
end;

function QryCreate(const pref: string): TMulQuery;
begin
	AddStack('ModelGet.QryCreate');
	TMulQuery.CreateConnection(Qry,Application.MainForm,nil);
  Qry.PartSelect(tMODEL,[],fMDPrefix+'='+QQs(pref),'','',false); result:=Qry;
  DelStack;
end;

procedure PrLoad(q: TMulQuery; const fname: string; const av: array of variant);
var f: TField;
begin
  AddStack('ModelGet.PrLoad');
  if q.FindField('D',f) then SetFileDateTime(ExeDir+DirModels+av[0]+PathDelim+fname,f.AsFloat);
  DelStack;
end;

procedure StLoad1(Sender: TStat; const Params: array of variant; var Aborted: boolean);
begin
	AddStack('ModelGet.StLoad1');
  TFormPswd.LoadFromServer(Sender,QryCreate(Params[1]),Params[0],[Params[1]],PrLoad,true);
  DelStack;
end;

procedure StLoad(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var dir,pref: string;
  i,lr: longint;
begin
	AddStack('ModelGet.StLoad');
  lr:=Params[1];
  with ProgPswd.CurQuery do for i:=1 to lr do begin
    pref:=TrimRight(Fields[0].AsString);
    if Sender.SayStat('',pref,i/lr) then break;
    dir:=ExeDir+DirModels+pref+PathDelim; ForceDirectories(dir); DelMaskFiles(dir+'*');
    if ShowStat(pref,StLoad1,[dir,pref]) then begin
      Aborted:=true; break;
    end;
    Next;
  end;
  with TMDLs(longint(Params[0])) do FillList(sb.Cells[0,sb.Row],[fillTopLeft]);
  DelStack;
end;

procedure PrSave(q: TMulQuery; const fname: string; const av: array of variant);
var f: TField;
begin
	AddStack('ModelGet.PrSave');
  with q do
    if RequestLive then begin
      FindField(fMDPrefix).AsString:=av[0];
      if FindField('D',f) then f.AsFloat:=GetFileDateTime(ExeDir+DirModels+av[0]+PathDelim+fname);
    end
    else begin
      AddArgList(sC_LIST,fMDPrefix); AddArgList(sV_LIST,QQs(av[0]));
      if MulQry.IsField(tMODEL,'D') then begin
        AddArgList(sC_LIST,'D'); AddArgList(sV_LIST,VarTos(Double(GetFileDateTime(ExeDir+DirModels+av[0]+PathDelim+fname))));
      end;
    end;
  DelStack;
end;

procedure StSave1(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var s: string;
begin
	AddStack('ModelGet.StSave1');
  s:=Params[0];
  TFormPswd.SaveToServer(Sender,['*'],QryCreate(s),ExeDir+DirModels+s+PathDelim,[s],PrSave,[srvCanEsc]);
  DelStack;
end;

procedure StSave(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i,lr: longint;
  a: PArrStr;
begin
	AddStack('ModelGet.StSave');
  lr:=Params[0]; a:=PointerVar(Params[1]);
  for i:=0 to lr-1 do begin
    if Sender.SayStat('',a^[i],i/lr) then break;
    if ShowStat(a^[i],StSave1,[a^[i]]) then begin
      Aborted:=true; break;
    end;
  end;
  DelStack;
end;

procedure TMDLs.KeyLb1ProcKey;
var s,s1,s2: string;
  st: TMGContainer;
  Prim: TModelPrim;
  lr: longint;
  a: TArrStr;
begin
	AddStack('TMDLs.KeyLb1ProcKey',Self);
  if Key=SelNoUsedKey.Key then begin
    SortStrListCreate(lsUsed); Model.UsedArr(lsUsed); sb.Refresh;
  end
	else case Key of
  	K_F3: if Model.LoadFromFile(sb.Cells[0,sb.Row]) then begin
    	Rec['COD']:=sb.Cells[0,sb.Row];
      if TCngNum.GetNewNum('Новый код:',nil,Rec,'COD',[''],[],'',nil,cteName,CngCheck,nil,
      [cngNoLockEdConf,cngNoLockMono]) then begin
      	if RnmFileAtr(Model.Path+sb.Cells[0,sb.Row],Model.Path+Rec['COD'])
        then FillList(Rec['COD']);
      end;
    end;
    K_F5: if Model.LoadFromFile(sb.Cells[0,sb.Row],[mdldCheckSum],@st) then begin
      Rec['COD']:=sb.Cells[0,sb.Row]; Rec['NAME']:=Model.MDName; LoadPrim;
      Rec['PRIMG']:=Model.MDPrimg; Rec['FMLUPD']:=Model.MDFmlUpd; Rec['NSAVE']:=Model.NSave;
      de.FrmCaption:='Редактировать основу'; de.Param['COD',deNoReadOnly]:=bFalse;
      if de.Execute.Saved then with Model do begin
        SaveToPrim(Prim);
        SaveToFile(Rec['COD'],Rec['NAME'],Prim,Rec['PRIMG'],Rec['FmlUpd'],Rec['NSAVE'],[],@st);
        FillStr(Rec['NAME'],Rec['PRIMG'],Rec['NSAVE'],sb.Row); Model.Modify;
      end;
    end;
    K_F7: if Model.Add(nil,FFromEdit) then FillList(Rec['COD']);
    K_F8: with sb do
      if Row>FixedRows then
        if Ask(amsDel) then
          if DelFileAtr(Model.Path+Cells[0,Row]) then FillList(Cells[0,Row-aSign[Row<RowCount-1]]);
    K_F10: Key:=K_Esc;
    K_F11: if FSortType=high(FSortType) then SetSortType(low(FSortType)) else SetSortType(Succ(FSortType));
    K_Enter: Key:=K_F10;
    K_Ctrl_F3,K_Ctrl_F4: if deDir.Execute(KeyLb1.SeekKey(Key).Hint).Saved then begin
    	s:=sb.Cells[0,sb.Row];
      if Key=K_Ctrl_F3 then begin
        s1:=Rec['DIR']; s2:=ExeDir;
      end
      else begin
        s1:=ExeDir; s2:=Rec['DIR'];
      end;
    	if MDDirExec(s1,s2,Model,s,true) then if Key=K_Ctrl_F3 then FillList(s,[fillTopLeft]);
    end;
    K_Ctrl_F5: SetModalResult(mrYes);
    K_Ctrl_F7: if Ask(['Вы уверены, что нужно','загрузить основы с сервера ?']) then with ProgPswd.GetQuery do begin
      PartSelect(tMODEL,fMDPrefix,'','',fMDPrefix); lr:=RecordCount;
      ShowStat('Загрузка основ с сервера',StLoad,[longint(Self),lr],lr); ProgPswd.FreeQuery;
    end;
    K_Ctrl_F8: if MdSavePrepare(a,lr) then
      if Ask(['Вы уверены, что нужно','скопировать основы на сервер ?']) then
        if LockSuper then try
          ShowStat('Копирование основ на сервер',StSave,[lr,longint(@a)],lr);
        finally
          UnlockSuper;
        end;
  end;
  Proc(mglsProcKey,[key,longint(tw)]);
  inherited;
  DelStack;
end;

procedure TMDLs.SaveToPrim;
var i,j: longint;
begin
  AddStack('TMDLs.SaveToPrim',Self);
  i:=Length(aPrim); SetLength(Prim,i); j:=0;
  for i:=0 to i-1 do if not empty(aPrim[i].Prim) then begin
    Prim[j]:=aPrim[i]; Prim[j].NumSave:=i; Inc(j);
  end;
  SetLength(Prim,j);
  if j>0 then with Prim[j-1] do Date:=Now;
  DelStack;
end;

procedure TMDLs.LoadPrim;
var i,ns: longint;
begin
  AddStack('TMDLs.LoadPrim',Self);
  with Model do begin
    i:=Length(FMDPrim);
    if i=0 then aPrim:=nil
    else for i:=i-1 downto 0 do with FMDPrim[i] do if not empty(Prim) then begin
      ns:=PrimNSave(NumSave); aPrim[ns]:=FMDPrim[i];
    end;
  end;
  DelStack;
end;

function TMDLs.CngCheck;
var i: longint;
begin
	AddStack('TMDLs.CngCheck',Self);
	result := not empty(Rec['COD']);
  if result then
    for i:=sb.FixedRows to sb.RowCount-1 do
      if (i<>sb.Row) and (TrimRight(sb.Cells[0,i])=TrimRight(Rec['COD'])) then begin
        meserr('Такая основа уже есть.'); result:=false; break;
      end;
  DelStack;
end;

procedure TMDLs.deFrmShow;
begin
	AddStack('TMDLs.deFrmShow',Self);
  de.FldHelpContext['FmlUpd']:=6200;
  DelStack;
end;

function TMDLs.PrimNSave: longint;
begin
  result:=PrimNSave(Rec['NSAVE']);
end;

function TMDLs.PrimNSave(NSave: longint): longint;
var i,l: longint;
begin
  AddStack('TMDLs.PrimNSave',Self);
  l:=Length(aPrim);
  if l<NSave+1 then begin
    SetLength(aPrim,NSave+1);
    for i:=l to NSave do with aPrim[i] do begin
      Finalize(aPrim[i]); ZeroMemory(@aPrim[i],SizeOf(aPrim[i])); Autor:=AutorDef;
    end;
  end;
  result:=NSave;
  DelStack;
end;

procedure TMDLs.deFldExit;
begin
	AddStack('TMDLs.deFldExit',Self);
  with TFldEdit(Sender) do
    if NameRecFld='AUTOR' then aPrim[PrimNSave].Autor:=TrimRight(VarValue)
    else if NameRecFld='THEMES' then LsArrDynamic(TrimRight(VarValue),aPrim[PrimNSave].Themes,CRLF,lsaSetLen)
    else if NameRecFld='PRIM' then aPrim[PrimNSave].Prim:=TrimRight(VarValue);
  DelStack;
end;

procedure TMDLs.deFldChange;
  procedure ReadPrim;
  begin
  	AddStack('TMDLs.deFldChange.ReadPrim',Self);
    with aPrim[PrimNSave] do begin
      de.FldValue['AUTOR']:=Autor;
      de.FldValue['DATE']:=IfThen(not empty(Date),FormatDateTime(DateFmt,Date));
      de.FldValue['THEMES']:=ArrayAsList(Themes,CRLF);
      de.FldValue['PRIM']:=Prim;
    end;
    DelStack;
  end;
var s: string;
begin
	AddStack('TMDLs.deFldChange',Self);
  with TFldEdit(Sender) do
    if NameRecFld='COD' then begin
      if not(ogReadOnly in Options) then begin
        s:=Model.DefName;
        if Model.LoadFromFile(VarValue,[mdldCheckSum]) then begin
          s:=Model.MDName; de.FldValue['PRIMG']:=Model.MDPrimg; de.FldValue['FMLUPD']:=Model.MDFmlUpd;
          LoadPrim; ReadPrim;
        end;
        de.FldValue['NAME']:=s;
      end;
    end
    else if NameRecFld='NSAVE' then ReadPrim;
  DelStack;
end;

function TMDLs.deFldCheck;
var tf: TFldEdit;
begin
	AddStack('TMDLs.deFldCheck',Self);
  tf:=pointer(Sender);
  if NoEmpCheck(Sender,'COD',result) then begin
    if (tf.NameRecFld='PRIMG') and empty(tf.VarValue) then
      if Model.LoadFromFile(Rec['COD'],[mdldCheckSum]) then tf.VarValue:=Model.MDPrimg;
    if (tf.NameRecFld='FMLUPD') and empty(tf.VarValue) then
      if Model.LoadFromFile(Rec['COD'],[mdldCheckSum]) then tf.VarValue:=Model.MDFmlUpd;
  end
  else begin
    Or_D(result,ogReadOnly in tf.Options);
    if result then begin
      result := not Model.LoadFromFile(tf.VarValue);
      if not result then result:=Ask(['Основа "'+Trim(tf.VarValue)+'" уже есть.','Заменить ?']);
    end;
  end;
  DelStack;
end;

function TMDLs.dePnlValid;
var a: TArrStr;
  i: longint;
  autor: string;
begin
  AddStack('TMDLs.dePnlValid',Self);
  if Assigned(lsThemes) then for i:=0 to LsArrDynamic(Rec['THEMES'],a,CRLF)-1 do begin
    TrimSelf(a[i]);
    if a[i]<>'' then lsThemes.Add(a[i]);
  end;
  autor:=TrimRight(Rec['AUTOR']);
  if autor<>'' then AutorDef:=autor;
  result:=true;
  DelStack;
end;

function TMDLs.deDirPnlValid;
var s: string;
begin
	AddStack('TMDLs.deDirPnlValid',Self);
	s:=CorrDir(Rec['DIR']); result:=DirectoryExists(s);
  if result then begin
  	result:=DirectoryExists(s+DirModels+Model.Prefix);
	  if result then InitFIni[fiSave].WriteString('Model','Dir',s)
    else mess_ok(['В папке '+s,'отсутствуют основы.']);
  end
  else mess_ok(['Отсутствует папка:',s]);
  DelStack;
end;

procedure TMDLs.deDirPnlCngKey;
begin
	AddStack('TMDLs.deDirPnlCngKey',Self);
	with tb do case Key of
    K_F10,K_Alt_Z: Caption:='';
    K_Enter: begin
    	Caption:='Копировать'; Part:=kmFile;
    end;
  end;
  DelStack;
end;

procedure TMDLs.ButFormGet1BeforeClick;
begin
	AddStack('TMDLs.ButFormGet1BeforeClick',Self);
  Model.FmlUpdate(false); AddPrnHead([Model.FrmCaption,Trim(Model.MDFile)+': '+Model.MDName]);
  DelStack;
end;

procedure TMDLs.ButFormGet1AfterClick;
begin
	AddStack('TMDLs.ButFormGet1AfterClick',Self);
  Model.FmlUpdate(true); DelPrnHead(2);
  DelStack;
end;

procedure TMDLs.sbAfterPaint;
var Rect: TRect;
begin
	AddStack('TMDLs.sbAfterPaint',Self);
  Rect:=sb.CellRect(aColSort[FSortType],0); Frame3D1(sb.Canvas,Rect);
  DelStack;
end;

procedure TMDLs.sbMouseUp;
var ACol,ARow: longint;
	fl: TMDSortType;
begin
	AddStack('TMDLs.sbMouseUp',Self);
	sb.MouseToCell(X,Y,ACol,ARow);
  if ARow<sb.FixedRows then for fl:=low(fl) to high(fl) do if ACol=aColSort[fl] then begin
    SetSortType(fl); break;
  end;
  DelStack;
end;

procedure TMDLs.SetSortType;
begin
  AddStack('TMDLs.SetSortType',Self);
  if FSortType<>v then begin
	  FSortType:=v; FillList(sb.Cells[0,sb.Row],[fillNoMod]);
  end;
  DelStack;
end;

procedure TMDLs.sbBeforeDrawCell;
begin
	AddStack('TMDLs.sbBeforeDrawCell',Self);
  if Assigned(lsUsed) and not(gdFixed in State) and (aRow>sb.FixedRows) then with sb,Canvas do
  	if lsUsed.IndexOf(Cells[0,ARow])<0 then
	  	if gdSelected in State then Font.Color:=FixedColor else Brush.Color:=FixedColor;
  DelStack;
end;

procedure TMDLs.WMSaveIni;
begin
  AddStack('TMDLs.WMSaveIni',Self);
  Msg.pSection^:='TMDList';
  DelStack;
end;

procedure TMDLs.WMFormLimit;
var i: longint;
begin
	AddStack('TMDLs.WMFormLimit',Self);
  inherited;
  for i:=low(aForm) to high(aForm) do if FreeLimit(aForm[i]) then break;
  DelStack;
end;

procedure TMDLs.WMHelpFill;
begin
  AddStack('TMDLs.WMHelpFill',Self);
  inherited;
  if Assigned(Model.FOnHelp) then with TWMHelpFill(Message) do case Oper of
    hlpAdd: HelpTbl2Arr(Model.DoHelp,pArr);
    hlpFillType: ResFillType:=iif(Length(pFillType^)=0,hlpftBefore,hlpftDefault);
    hlpLinkObj: pLinkObj^:='содержимое основы';
  end;
  DelStack;
end;

procedure fLoadThemes(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
var i: longint;
begin
  AddStack('ModelGet.fLoadThemes');
  with TModelGet(longint(av[1])) do
    if LoadFromFile(sr.Name,[mdldCheckSum])
    then for i:=low(FMDPrim) to high(FMDPrim) do AddFrom(StringListVar(av[0]),FMDPrim[i].Themes)
    else lDone:=false;
  DelStack;
end;

procedure mgLoadThemes(Sender: TModelGet; const av: array of variant; var Aborted: boolean);
var op: TFileName;
begin
  AddStack('ModelGet.mgLoadThemes');
  with Sender do begin
    op:=Root;
    try
      Root:=av[1];
      if not MaskFilesProc(Path+'*.*',fLoadThemes,[av[0],longint(Sender)]) then Aborted:=true;
    finally
      Root:=op;
    end;
  end;
  DelStack;
end;

{ TMDThemesGet }
function TMDThemesGet.KeyDop;
begin
  AddStack('TMDThemesGet.KeyDop',Self);
  result:=TKeyLb.GetKeySt(K_F7,'Добавить','Добавить тему',kmEdit);
  DelStack;
end;

procedure TMDThemesGet.ProcKey;
var mr: TListF2Result;
  Root: TFileName;
  fl: boolean;
begin
  AddStack('TMDThemesGet.ProcKey',Self);
  if Key=K_F7 then begin
    if Assigned(lsThemes) then fl:=true
    else begin
      lsThemes:=SortStrListCreate; Root:=ParamByCode('MODELS');
      if Root<>'' then CorrDirSelf(Root);
      fl:=ModelGetProcAll(mgLoadThemes,[longint(lsThemes),Root],'Загрузка тем');
      if not fl then FreeAndNil(lsThemes);
    end;
    if fl then if lsThemes.Count>0 then begin
      mr:=TListF2Result.Create;
      try
        if ListF2Down(lsThemes.Text,mr,nil,0,SchemDM.Browl.CaptSmall,'',nil,0,nil,nil,nil,nil,nil,'Добавить тему')
        then with TCustomEdMemo(tw.Owner) do InsertText(CurLineStartPos,mr[mr.SelectStr]+CRLF);
      finally
        mr.Free;
      end;
    end;
  end
  else inherited;
  DelStack;
end;

procedure ModelGetCreate(var aPrm: TArrPointer; lAfter: boolean);
var k: longint;
begin
  AddStack('ModelGet.ModelGetCreate');
  if not lAfter then SetLength(aPrm,Length(aModelGetCreate));
  for k:=low(aPrm) to high(aPrm) do aModelGetCreate[k](aPrm[k],lAfter);
  DelStack;
end;

procedure InterVarCreate;
var j,k: longint;
  mg: TModelGet;
  VarIdent: string;
  aPrm: TArrPointer;
begin
  AddStack('ModelGet.InterVarCreate');
  if not Assigned(aMDAppRdb) then begin
    New(aMDAppRdb); ModelGetCreate(aPrm,false);
    TInter.SetVar('$model','ОСНОВА_','Основы');
    with LsCustomGet do begin
      SetLength(aMDAppRdb^,Count); j:=0;
      for k:=0 to Count-1 do if IsClass(Objects[k],TModelGet,pointer(mg)) then with mg do begin
        VarIdent:=InterDef(mdiVarName,[],'');
        if VarIdent<>'' then begin
          TInter.SetVar('ОСНОВА_'+VarIdent,FrmCaption,i_const,VName,'C',true);
          aMDAppRdb^[j]:=UsedTableName; Inc(j);
        end;
      end;
      SetLength(aMDAppRdb^,j);
    end;
    ModelGetCreate(aPrm,true);
  end;
  DelStack;
end;

procedure biMDLoad(var stack: array of variant; n1: longint; var lStd: boolean);
var aPrm: TArrPointer;
  r: TRecDB;
  aRdb: TArrRecDB;
  svi,svi1: TRDBSaveInf;
  fn,cod,w: string;
  i: longint;
  lnm: boolean;
begin
  AddStack('ModelGet.biMDLoad');
  ModelGetCreate(aPrm,false); fn:=stack[n1+1];
  with TModelGet(NameGet(TModelGet,stack[n1])) do begin
    r:=pointer(RecName(UsedTableName)); r.SaveInf(svi);
    lnm:=InterDef(mdiSeekName,[],false);
    if lnm then begin
      w:=UsedFieldName; cod:=fn;
    end
    else begin
      w:=UsedFieldCod; cod:=IsNilc(stack[n1+2],fn);
    end;
    if r.Seek(DlmBetween(UsedWhere,r.TblFldName(w)+'='+QQs(LeftStr(cod,r.FldName(w).Info.Size)),sAND))
    then stack[n1]:=true
    else begin
      stack[n1]:=LoadFromFile(fn,[mdldCheckSum]);
      if stack[n1] then begin
        if lnm then cod:=r.KodNext(UsedFieldCod,UsedWhere);
        r.NewRec; r[UsedFieldCod]:=cod; InterDef(mdiApp,[],null); r.AppRec;
        SetLength(aRdb,Length(aMDAppRdb^));
        for i:=low(aRdb) to high(aRdb) do aRdb[i]:=pointer(RecName(aMDAppRdb^[i]));
        TRecDB.SaveInf(aRdb,svi1);
        stack[n1]:=LoadFromFile(fn,[mdldCheckSum,mdldDoLoad,mdldCloseBeforeLoad]); InterDef(mdiAfterLoad,[],null);
        TRecDB.RestInf(svi1);
      end
      else raise EInterAnyError.Create(FrmCaption+': ошибка загрузки из основы '+Trim(fn));
    end;
    TRecDB.RestInf(svi);
  end;
  ModelGetCreate(aPrm,true);
  DelStack;
end;

function ModelGetVar;
begin
  result:=PointerVar(v);
end;

function MdLsModel;
begin
  AddStack('ModelGet.MdLsModel');
  result:=aForm[nForm-1].Model;
  DelStack;
end;

procedure StModelGetProcAll(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var Proc: TMGProcAll;
  av: TArrVar;
  io,i,n,l: longint;
  mg: TModelGet;
  so: string;
begin
  AddStack('ModelGet.StModelGetProcAll');
  Proc:=TMGProcAll(PointerVar(Params[0])); CopyFromVar(av,Params[1]);
  if DBMain<>nil then for i:=low(aProcAllDop) to high(aProcAllDop) do with aProcAllDop[i] do begin
    lCreate:=false; Proc(true,lCreate);
  end;
  with LsCustomGet do begin
    l:=0;
    if Assigned(Sender) then for i:=0 to Count-1 do if Objects[i] is TModelGet then Inc(l);
    i:=0; n:=1;
    while i<Count do begin
      if IsClass(Objects[i],TModelGet,pointer(mg)) then begin
        if l>0 then if Sender.SayStat('',mg.FFrmCaption,n/l) then break else Inc(n);
        io:=i; so:=Strings[i];
        if Assigned(mg.FOnProcAll) then mg.FOnProcAll(mg,Proc,av,Aborted) else Proc(mg,av,Aborted);
        if Aborted then break;
        if Find(so,i) then begin
          // Игнорировать совпадающие VName
          AnsiUpperCaseSelf(so);
          while i<Count do
            if AnsiUpperCase(Strings[i])=so then Inc(i) else break;
          Dec(i);
        end
        else i:=io;
      end;
      Inc(i);
    end;
  end;
  if DBMain<>nil then for i:=low(aProcAllDop) to high(aProcAllDop) do with aProcAllDop[i] do Proc(false,lCreate);
  DelStack;
end;

function ModelGetProcAll;
begin
  AddStack('ModelGet.ModelGetProcAll');
  result:=not ShowStat(StatCapt,StModelGetProcAll,[longint(@Proc),ArrVarToVar(av,0)],IfThen(StatCapt='',stNoShow));
  DelStack;
end;

function MdSavePrepare;
begin
  AddStack('ModelGet.MdSavePrepare');
  result:=GetMaskFiles(a,lr,ExeDir+DirModels+'*.*',[fmDir],[msfSort]);
  DelStack;
end;

procedure MdSaveExec;
begin
  AddStack('ModelGet.MdSavePrepare');
  ShowStat('Копирование основ на сервер',StSave,[lr,longint(@a)],lr);
  DelStack;
end;

procedure AddFrom(Proc: TMGProcAllDop);
var i: longint;
begin
  AddStack('ModelGet.AddFrom');
  i:=Length(aProcAllDop); SetLength(aProcAllDop,i+1); aProcAllDop[i].Proc:=Proc;
  DelStack;
end;

procedure HelpCnt1(Sender: TModelGet; const av: array of variant; var Aborted: boolean);
var result: ^THelpCntArr;
  PrAdd: THelpCntAddProc;
  ht: THelpTbl;
begin
  AddStack('ModelGet.HelpCnt1');
  result:=PointerVar(av[0]); PrAdd:=THelpCntAddProc(longint(av[1]));
  if result.l=0 then PrAdd(result^,0,'Список основ');
  with Sender do begin
    ht:=DoHelp; PrAdd(result^,1,ht.Head,HelpTbl2Str(ht),NegDef,hlnkTbl,FFrmCaption);
  end;
  DelStack;
end;

procedure HelpCntProc(var result: THelpCntArr; const Name: string; PrAdd: THelpCntAddProc);
begin
  AddStack('ModelGet.HelpCntProc');
  if Name='MODELS' then if DBMain<>nil then begin
    SetLength(result.a,10); ModelGetProcAll(HelpCnt1,[longint(@result),longint(@PrAdd)]);
  end;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TModelGet]);
end;

initialization
	AddStack('ModelGet.initialization');
  AddFrom(aInterVarCreate,InterVarCreate);
  AddFrom(HelpCntProc);
  aBuiltInProc[MyTypes.biMDLoad].Proc:=biMDLoad;
  SetPrim(tMDLIST,'Список существующих основ');
  SetPrim(tMODEL ,'Основы');
  lNSave:=LenIntStr(MaxInt);
  AutorDef:=ParamByCode(PrmAutor);
  DelStack;
finalization
  AddStack('ModelGet.finalization');
  if Assigned(aMDAppRdb) then begin
    aMDAppRdb^:=nil; Dispose(aMDAppRdb);
  end;
  lsThemes.Free;
  DelStack;
end.
