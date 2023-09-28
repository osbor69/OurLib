unit AdrGet;

interface

{$I LIBTEST}
uses Classes,SysUtils,Controls,
  MyTypes,CodeGets,FFldEdit,RecVal,RecDB,ButGet,DefEdit,RbMenu,Askp;

type
  TAdrPartOption = (apoSocrEnd,apoUpper,apoWithoutPref,apoWithoutPrefNo1,apoOnlyPref,apoGOST);
  TAdrPartOptions = set of TAdrPartOption;

  TAdrNameOpt = set of (anoFull,anoGOST);

	TAdrGet = class(TCustomButGet)
  private
    oSp: TAdrSpStr;
    FActive: boolean;
  	Rec: TRecVal;
    de: TDefEdit;
    FiasExe,FiasPath,FiasIn,FiasOut: TFileName;
    function GetFld(Index: TAdrList): variant;
    function GetSp(Index: TAdrSpList): variant;
    procedure SetFld(Index: TAdrList; const Value: variant);
    procedure SetSp(Index: TAdrSpList; const Value: variant);
    property Fld[Index: TAdrList]: variant read GetFld write SetFld;
    property Sp[Index: TAdrSpList]: variant read GetSp write SetSp;
    procedure deFldEnter(Sender: TObject);
		procedure deFldExit(Sender: TObject);
		procedure deFldChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    function deFldCheck(Sender: TObject): boolean;
    procedure deKpProcKey(Key: longint; tw: TWinControl);
		procedure FldRead(n: TAdrList);
		function SpRegSeek: boolean;
		procedure SpNpSeek;
		procedure SpUlSeek;
		procedure RecCor(i: TAdrSpList);
    function IsCity: boolean;
  public
		constructor Create(AOwner: TComponent); override;
  	function Click(tf: TFldEdit; lEval: boolean): string; override;
		procedure StdDWFldValue(r: TCustomRec; const Mask: string; var Value: variant); override;
		class function Name(const Value: TAdrStr; Opt: TAdrNameOpt = []): string; overload;
		class function Name(const Value: string; Opt: TAdrNameOpt = []): string; overload;
    class function Part(const Value: TAdrStr; p: TAdr1List; Opt: TAdrPartOptions = []): string; overload;
    class function Part(const Value: string; p: TAdr1List; Opt: TAdrPartOptions = []): string; overload;
		class function IsCor(Rec: TRecDB; const nmf: string): TAnkList; overload;
		class function IsCor(Rec: TRecDB; const nmf: string; var sreg,snp,sul: string): TAnkList; overload;
    class procedure KrUpdate;
    class function SpGkMask(i: TAdr1List): string;
  end;

  TAdrLsOper = (adrCreate,adrProcKey);
  TAdrLsProc = procedure(oper: TAdrLsOper; const av: array of variant);

const
  aAdrFld: TAdrStr = ('SPREG','SPNP','SPUL','LAND','IND',
    fSPREG,'RN1','RN','CITY1','CITY','NP1','NP','UL1','UL','DOM','KOR1','KOR','KV','FIASHOUSE','FIAS');

  aAdrSp: array[TAdrSpList] of record
    f: TAdrList;
    g: TCodeGet;
  end = ((f:adrSpreg),(f:adrSpnp),(f:adrSpul));

  aAdrCD: array[TAdrCDList] of record
    af: array[1..2] of TAdrList;
    empka: string;
    g: TCodeGet;
  end =
    ((af:(adrNp1  ,adrNp  ); empka:'НП')
    ,(af:(adrUl1  ,adrUl  ); empka:'УЛ')
    ,(af:(adrKor1 ,adrKor ); empka:'КОРПУС')
    ,(af:(adrRn1  ,adrRn  ); empka:'Р-Н')
    ,(af:(adrCity1,adrCity); empka:'Г')
    );

var
  CDAdrCur: TAdrCDList;
  CDAdrLsProc,AdrSpLsProc: TAdrLsProc;

function AdrSpRdb(n: TAdrSpList): TRecDB;
function AdrMenu: TDefMenu;
procedure IncD(var Opt: TAdrPartOptions; Incl: TAdrPartOptions; Excl: TAdrPartOptions = []); overload;
function IfThen(AValue: boolean; ATrue: TAdrPartOption): TAdrPartOptions; overload;

implementation

uses Windows,Messages,Forms,Math,StrUtils,Variants,DBGrids,Grids,DB,StdCtrls,
  My_pr,FStat,KeyLb,FrmBrIB,PaintCtl,BrQuery,FrmPswd,Inter,FSchemDM,BufFile,DBF,GGMReg,SpGet,MulQry;

type TAdrKrList = 1..99;

  TNone = class
  private
    class procedure KrRecAfterOpen(Sender: TObject);
    class procedure KrRecBeforeClose(Sender: TObject);
    class procedure AdrMenuProcKey(key: longint; tw: TWinControl);
    class procedure deDoPnlCngKey(Sender: TObject; var tb: TKeyBut);
    class function deKrAddPnlValid(Sender: TObject): Boolean;
    class function deKrDelPnlValid(Sender: TObject): Boolean;
    class function KrApp(const kr: string = ''): boolean;
  end;

  TDbRegLs = class(TFormBrIB)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    sAdrKr: set of TAdrKrList;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
    class function CodeGetFormIBList(Sender: TFldEdit): TFormBrIB;
    class procedure CodeGetAfterList(Sender: TObject);
		class function CodeGetStrName(Sender: TObject; Qry: TBrQuery): String;
    class function CodeGetTransSeek(Sender: TObject; tf: TFldEdit;
      const Value: String; Size: longint; lSQL: Boolean): String;
		class procedure CodeGetAfterMinWidthCode(Sender: TObject; var result: longint);
    class function Browl1TransSeek(Sender: TObject; const Value: String;
      Size: longint; lQuery: Boolean): String;
    function Browl1GrayCell(Sender: TObject; const Rect: TRect;
      DataCol: longint; Column: TColumn; State: TGridDrawState): Boolean;
  end;

  TSpLs = class(TFormBrIB)
    procedure FormCreate(Sender: TObject);
    procedure KeyLb1ProcKey(key: Integer; tw: TWinControl);
  private
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
    class function CodeGetFormIBList(Sender: TFldEdit): TFormBrIB; virtual;
    class procedure CodeGetAfterList(Sender: TObject);
		class function CodeGetStrName(Sender: TObject; Qry: TBrQuery): String;
    class function CodeGetStrDop(Sender: TObject; Qry: TBrQuery): String;
    class function CodeGetTransSeek(Sender: TObject; tf: TFldEdit;
      const Value: String; Size: longint; lSQL: Boolean): String;
		class procedure CodeGetAfterMinWidthCode(Sender: TObject; var result: longint);
    class function Browl1TransSeek(Sender: TObject; const Value: String;
      Size: longint; lQuery: Boolean): String; virtual; abstract;
    class procedure RdbCalculate(Sender: TCustomRec; lApp: Boolean);
  end;

  TSpRegLs = class(TSpLs)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    sAdrKr: set of TAdrKrList;
    class function CodeGetFormIBList(Sender: TFldEdit): TFormBrIB; override;
    class function Browl1TransSeek(Sender: TObject; const Value: String;
      Size: longint; lQuery: Boolean): String; override;
    function Browl1GrayCell(Sender: TObject; const Rect: TRect;
      DataCol: longint; Column: TColumn; State: TGridDrawState): Boolean;
  end;

  TSpNpLs = class(TSpLs)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    class function Browl1TransSeek(Sender: TObject; const Value: String;
      Size: longint; lQuery: Boolean): String; override;
  end;

  TSpUlLs = class(TSpNpLs);

  TCDAdrLs = class(TFormBrIB)
    procedure FormCreate(Sender: TObject);
    procedure KeyLb1ProcKey(key: Integer; tw: TWinControl);
  private
    { Private declarations }
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
    class function CodeGetListOwner(Sender: TObject; SpdBut: TPaintButton;
      const RectList: TRect; PozList: TPozList): Boolean;
		class function CodeGetFormIBList(Sender: TFldEdit): TFormBrIB;
		class procedure CodeGetAfterList(Sender: TObject);
		class function CodeGetStrDop(Sender: TObject; Qry: TBrQuery): String;
    class function CodeGetTransSeek(Sender: TObject; tf: TFldEdit;
      const Value: String; Size: longint; lSQL: Boolean): String;
  end;

  TSpLsClass = class of TSpLs;

  TAdrIndList = (adiKLADR,adiSTREET,adiDOMA);
  TAdrIndStr = array[TAdrIndList] of string;
  TAdrIndDbf = array[TAdrIndList] of TDbf;
  TAdrIndCrd = array[TAdrIndList,1..2] of longword;

const
  aFld1: array[TAdr1List] of record
    f: TAdrList;
    l: longint;
    nm,ms: string;
  end =
    ((f:adrSpreg    ; l:2 ; nm:'код региона'                                      ; ms:cCdName+cCdCod+cCdAny)
    ,(f:adrSpnp     ; l:9 ; nm:'справочник'+UnDelim+'населённых'+UnDelim+'пунктов'; ms:cCdName+cCdAny)
    ,(f:adrSpul     ; l:9 ; nm:'справочник'+UnDelim+'улиц'                        ; ms:cCdName+cCdAny)
    ,(f:adrLand     ; l:3 ; nm:'код страны'                                       ; ms:'SP,A1')
    ,(f:adrInd      ; l:6 ; nm:'индекс'                                           ; ms:'SP,A2')
    ,(f:adrKr       ; l:40; nm:'регион'                                           ; ms:'SP,A3')
    ,(f:adrRn1      ; l:40; nm:'район'                                            ; ms:'SP,A4')
    ,(f:adrCity1    ; l:40; nm:'город'                                            ; ms:'SP,A8')
    ,(f:adrNP1      ; l:40; nm:'населённый'+UnDelim+'пункт'                       ; ms:'SP,A5')
    ,(f:adrUL1      ; l:40; nm:'улица'                                            ; ms:'SP,A6')
    ,(f:adrDOM      ; l:15; nm:'дом')
    ,(f:adrKOR1     ; l:3 ; nm:'корпус')
    ,(f:adrKV       ; l:15; nm:'квартира')
    ,(f:adrFiasHouse; l:1 ; nm:'код ФИАС:'                                        ; ms:'с учётом дома'+mniDlm+'без учёта дома'+cRdBeg+'0')
    ,(f:adrFias     ; l:36)
    );
  aspCnt = Length(aAdrSp);

  FuncAdrFill = 'AdrFill';

  aSp: array[TAdrSpList] of record
    cod,nm,dop,gk: string;
    cls: TSpLsClass;
    fls: TSpLs;
    lLoad: boolean;
    rdb: TRecDB;
  end =
    ((cod:fSPREG; nm:fNAME; dop:'SOCR'           ; cls:TSpRegLs)
    ,(cod:'KN'  ; nm:fTXT ; dop:'GNI' ; gk:fSPREG; cls:TSpNpLs ; lLoad:true)
    ,(cod:'KU'  ; nm:fTXT ; dop:'GNI' ; gk:'GK'  ; cls:TSpUlLs ; lLoad:true)
    );

  aIndTbl: TAdrIndStr = ('KLADR','STREET','DOMA');
  FileAdrInd = 'INDEX.ZPI';
  LastVersAdrInd = 1;

var CDAdrLs: TCDAdrLs;
  DBRegLs: TDBRegLs;
  FAdrMenu: TDefMenu;
  deKrAdd,deKrDel: TDefEdit;
  FKrRec: TRecVal;
  RegOnlyExists: boolean;
  lKrUpdate: boolean = true;
  VersAdr: longint;
  aReg: array[TAdrKrList] of string;
  lsReg: TStringList; 

function AdrSpRdb;
begin
  AddStack('AdrGet.AdrSpRdb');
  if TRecDB.Init(aSp[n].rdb,result,aAdrFld[aAdrSp[n].f],'',TSpLs.RdbCalculate) then result.Tag:=byte(n);
  DelStack;
end;

procedure SetAdrVers(fIni: TIniFileCheck; const Sect: string; p: pointer; var path: TFileName);
begin
  AddStack('AdrGet.SetAdrVers');
  VersAdr:=fIni.ReadInteger(Sect,GGMUtilVers);
  DelStack;
end;

function AdrKrRec: TRecVal;
var path: TFileName;
begin
  AddStack('AdrGet.AdrKrRec');
  if not Assigned(FKrRec) then begin
    FKrRec:=TRecVal.Create(Application.MainForm);
    with TNone,FKrRec do begin
      NameRec:='ADR';
      CreateFld('ADRDIR',ftMemo,0,'');
      CreateFld('ADRKR',ftString,Length(AdrSpRdb(aspReg)[fSPREG]),'');
      OnAfterOpen:=KrRecAfterOpen; OnBeforeClose:=KrRecBeforeClose; RestFromIni;
    end;
    path:='';
    if My_pr.SearchPath('ETKLADR'+PathDelim,path,'',true,SetAdrVers) then FKrRec['ADRDIR']:=path;
  end;
  result:=FKrRec;
  DelStack;
end;

function AdrMenu;
var av: TDEPrmVar;
  g: TCodeGet;
begin
  AddStack('AdrGet.AdrMenu');
  if not Assigned(FAdrMenu) then with TNone do begin
    FAdrMenu:=TDefMenu.Create(Application.MainForm);
    with FAdrMenu do begin
      InsertKey(K_1,'Добавление');
      InsertKey(K_2,'Удаление');
      InsertKey(K_3,'Обновление');
      OnProcKey:=AdrMenuProcKey;
    end;
    deKrAdd:=TDefEdit.Create(Application.MainForm);
    with deKrAdd do begin
      NameWnd:='AdrAdd';
      OnPnlCngKey:=deDoPnlCngKey; OnFldCheck:=TFldEdit.NoEmpValue; OnPnlValid:=deKrAddPnlValid;

      InitArr(av);
      av[deCaption]:='Папка баз данных программы "КЛАДР"';
      av[deNameRec]:=AdrKrRec.NameRec;
      av[deNameRecFld]:='ADRDIR';
      SchemDM.DirGet1.AssignGet(av);
      av[deMask]:='Папка баз данных программы "КЛАДР"';
      av[deAutoSel]:=true;
      av[deNoReadOnly]:=true;
      av[deWidth]:=wallDefault;
      CreateFld(av);

      g:=TCodeGet.Create(Application.MainForm);
      with TDBRegLs,g do begin
        VName:='DBREG'; FieldsCode:=fDBREG;
        Part:=sSELECT_WORDER;
        MulPar.Values[sTABLE]:=tDBREG;
        MulPar.Values[sWHERE]:=FieldsCode+qCod_C;
        OnFormIBList:=CodeGetFormIBList; OnAfterList:=CodeGetAfterList;
        onStrName:=CodeGetStrName;
        onTransSeek:=CodeGetTransSeek; OnAfterMinWidthCode:=CodeGetAfterMinWidthCode;
      end;
      av[deCaption]:='Код региона';
      av[deNameRecFld]:='ADRKR';
      g.AssignGet(av);
      av[deMask]:='';
      av[deWidth]:=0;
      CreateFld(av);
    end;
    deKrDel:=TDefEdit.Create(Application.MainForm);
    with deKrDel do begin
      NameWnd:='AdrDel'; FrmCaption:='Удаление адресов';
      CreateFld(av);
      OnPnlCngKey:=deDoPnlCngKey; OnFldCheck:=TFldEdit.NoEmpValue; OnPnlValid:=deKrDelPnlValid;
    end;
  end;
  result:=FAdrMenu;
  DelStack;
end;

procedure IncD(var Opt: TAdrPartOptions; Incl: TAdrPartOptions; Excl: TAdrPartOptions = []);
begin
  Opt:=Opt+Incl-Excl;
end;

function IfThen(AValue: boolean; ATrue: TAdrPartOption): TAdrPartOptions;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

// АДРЕС()
function c_name(var av: array of variant): variant;
var Opt: TAdrNameOpt;
begin
  AddStack('AdrGet.c_name');
  if IsNilc(av[2],false) then Opt:=[anoGOST] else Opt:=[];
  result:=TAdrGet.Name(av[1],Opt);
  DelStack;
end;

// АДРЕС_ЧАСТЬ()
function c_part(var av: array of variant): variant;
var Opt: TAdrPartOptions;
begin
  AddStack('AdrGet.c_part');
  Opt:=[apoWithoutPrefNo1];
  if IsNilc(av[4],false) then IncD(Opt,[apoSocrEnd,apoUpper]);
  if MyVarType(IsNil(av[3],true))=V_BOOL then av[3]:=IfThen(av[3],1);
  case byte(av[3]) of
    0: Include(Opt,apoWithoutPref);
    2: IncD(Opt,[apoOnlyPref],[apoWithoutPrefNo1]);
  end;
  result:=TAdrGet.Part(av[1],av[2],Opt);
  DelStack;
end;

function c_fill(var av: array of variant): variant;
var i: TAdrSpList;
begin
	AddStack('AdrGet.c_fill');
  result:=null;
  with TAdrGet(LongInt(av[1])) do begin
    FActive:=false; InitArr(oSp);
    for i:=low(aAdrSp) to high(aAdrSp) do RecCor(i);
    de.PanelEdit.FldReadAll;
    FActive:=true;
  end;
  DelStack;
end;

procedure Proc(pr: TAdrLsProc; oper: TAdrLsOper; const av: array of variant);
begin
  AddStack('AdrGet.Proc');
  if Assigned(pr) then pr(oper,av);
  DelStack;
end;

{ TAdrGet }
constructor TAdrGet.Create;
var av: TDEPrmVar;
  a: TArrStr;
  procedure CreateFld(l: longint);
  var la: longint;
  begin
    AddStack('TAdrGet.Create.CreateFld',Self);
    la:=LsArrDynamic(av[deCaption],a,UnDelim); av[deCaption]:=SpaceCapt(a,la);
    if av[deNameRec]=Rec.NameRec then Rec.CreateFld(av[deNameRecFld],ftString,l,'');
    de.CreateFld(av);
    DelStack;
  end;
const
  aVid: array[TAdr1List] of record
    Vid,VName: string;
  end =
    ((Vid:'TCodeGet')
    ,(Vid:'TCodeGet')
    ,(Vid:'TCodeGet')
    ,(Vid:'TSpGet')
    ,(Vid:'TSpGet')
    ,(Vid:'TSpGet')
    ,(Vid:'TSpGet')
    ,(Vid:'TSpGet')
    ,(Vid:'TSpGet')
    ,(Vid:'TSpGet')
    ,()
    ,()
    ,()
    ,(Vid:'TRadioGet'; VName:'Customize')
    ,()
    );
	aSay1: TAdrCDStr = ('наименование','наименование','номер','наименование','наименование');
var i: TAdrSpList;
  j: TAdrSpList;
  cd: TAdrCDList0;
  n1: TAdr1List;
  s: string;
begin
	AddStack('TAdrGet.Create',Self);
  inherited Create(AOwner);
  RVid:='Адрес';
  for i:=low(aAdrSp) to high(aAdrSp) do with aAdrSp[i],aSp[i] do begin
    g:=TCodeGet.Create(Application.MainForm);
    with cls,g do begin
      Tag:=byte(i); VName:=aAdrFld[f]; FieldsCode:=cod; FieldsName:='UP'+nm;
      Part:=sSELECT_WORDER;
      MulPar.Values[sTABLE]:=aAdrFld[f];
      MulPar.Values[sWHERE]:=IfThen(gk<>'',gk+sLIKE+qGlobKey+sAND)+cod+qCod_C;
      OnFormIBList:=CodeGetFormIBList; OnAfterList:=CodeGetAfterList;
      onStrName:=CodeGetStrName; onStrDop:=CodeGetStrDop;
      onTransSeek:=CodeGetTransSeek; OnAfterMinWidthCode:=CodeGetAfterMinWidthCode;
    end;
  end;
  for cd:=low(aAdrCD) to high(aAdrCD) do with aAdrCD[cd] do begin
    g:=TCodeGet.Create(Application.MainForm);
    with TCDAdrLs,g do begin
      FieldsCode:=fCdadrKA; FieldsName:=fUPNAME;
      GlobKey:=Int2Str(cd); Part:=sSELECT_WORDER; VName:='CDADR'+GlobKey;
      onListOwner:=CodeGetListOwner; OnFormIBList:=CodeGetFormIBList; OnAfterList:=CodeGetAfterList;
      onStrDop:=CodeGetStrDop; onTransSeek:=CodeGetTransSeek;
      with MulPar do begin
        Values[sTABLE]:=tCDADR;
        Values[sWHERE]:=fCdadrGK+sLIKE+qGlobKey+sAND+fCdadrKA+qCod_C;
      end;
    end;
  end;
	Rec:=TRecVal.Create(Self);
  de:=TDefEdit.Create(Self);
  with de do begin
    PnlSortMode:=smColumns; OnFldEnter:=deFldEnter; OnFldExit:=deFldExit;
    OnFldChange:=deFldChange; OnFldCheck:=deFldCheck;
    if SearchPath('fias.exe',FiasExe) then begin
      FiasPath:=ExtractFilePath(FiasExe); FiasIn:=FiasPath+'in.txt'; FiasOut:=FiasPath+'out.txt';
      NmProc.Text:=ArrayAsList(
        [TKeyLb.GetKeySt(K_Ctrl_F5,'Код ФИАС','Определение кода ФИАС по адресу',kmServic)
        ,TKeyLb.GetKeySt(K_Ctrl_F6,'Адрес ФИАС','Определение адреса по коду ФИАС',kmServic)
        ],CRLF);
      OnKpProcKey:=deKpProcKey;
    end;
  end;
  InitArr(av);
  av[deAutoSel]:=true;
  av[deNoReadOnly]:=true;
  av[deTrimLeft]:=true;
  for n1:=low(aFld1) to high(aFld1) do with aFld1[n1] do begin
    av[deRelation]:=''; cd:=aFld1CDAdr[n1];
    if cd=acdNone then begin
      av[deCaption]:=FRup(nm);
      av[deNameRecFld]:=aAdrFld[f];
    end
    else with aAdrCD[cd].g do begin
      s:=StrNum('CDADR',cd);
      av[deCaption]:=FRup(nm)+':';
      av[deNameRec]:='';
      av[deNameRecFld]:=s;
      SchemDM.MultiGet1.AssignGet(av);
      av[deMask]:='';
      CreateFld(0);

      av[deCaption]:='тип';
      av[deNameRec]:=Rec.NameRec;
      av[deNameRecFld]:=aAdrFld[f];
      AssignGet(av);
      av[deMask]:=cCdName+cCdCod+cCdAny;
      av[deCharCase]:=Succ(ecUpperCase);
      av[deRelation]:='.'+s;
      CreateFld(CodLen);

      av[deCaption]:=aSay1[cd];
      av[deNameRecFld]:=aAdrFld[aAdrCD[cd].af[2]];
      av[deCharCase]:=Succ(ecNormal);
    end;
    av[deNameRec]:=Rec.NameRec;
    with aVid[n1] do begin
      av[deVid]:=ReplVar(Vid,TSimpleGet.ClassName);
      av[deVName]:=VName;
    end;
    for j:=low(aAdrSp) to high(aAdrSp) do if aAdrSp[j].f=f then begin
      av[deVName]:=aAdrFld[f]; break;
    end;
    av[deMask]:=SpGkMask(n1);
    CreateFld(l);
  end;
  av[deCaption]:='';
  av[deNameRec]:='';
  av[deNameRecFld]:='';
  SchemDM.BtMskGet1.AssignGet(av);
  av[deMask]:=ButPrm2Mask('Заполнить адрес из справочника',
    FmlToMask(BracketInt(FuncAdrFill,LongInt(Self))));
  av[deRelation]:='';
  de.CreateFld(av,aAdrFld[adrLand]);
  DelStack;
end;

function TAdrGet.Click;
var a: TAdrStr;
  i: TAdrList;
  ost: longint;
  Prm: TButGetPrm;
begin
  ost:=AddStack('TAdrGet.Click',Self);
  a:=StrToAdr(tf.Value);
  if lEval then begin
    for i:=low(a) to high(a) do Fld[i]:=a[i];
    FActive:=true;
    try
      InitArr(oSp); Prm:=ButMask2Prm(tf.Mask);
      if empty(Prm.Capt) then begin
        Prm.Capt:=Prm.Mask;
        if empty(Prm.Capt) then Prm.Capt:=tf.SayCaption;
      end;
      if de.Execute(Prm.Capt).Saved then begin
        for i:=low(a) to high(a) do a[i]:=TrimRight(Fld[i]);
        tf.Value:=AdrToStr(a);
      end;
    finally
      SetStack(ost);
      FActive:=false;
    end;
  end;
  result:=Name(a);
  DelStack;
end;

procedure TAdrGet.StdDWFldValue;
begin
  AddStack('TAdrGet.StdDWFldValue',Self);
  Value:=Name(Value);
  DelStack;
end;

class function TAdrGet.SpGkMask;
begin
  AddStack('TAdrGet.SpGkMask');
  with aFld1[i] do result:=StrTran(ms,'SP',StrNum('1,',l));
  DelStack;
end;

function IsSp(Sender: TObject; var n: TAdrSpList): boolean;
var nmf: string;
begin
  AddStack('AdrGet.IsSp');
	nmf:=AnsiUpperCase(TFldEdit(Sender).NameRecFld); n:=low(aAdrSp); result:=false;
  while n<=high(aAdrSp) do
    if nmf=aAdrFld[aAdrSp[n].f] then begin
      result:=true; break;
    end
    else Inc(n);
  DelStack;
end;

procedure TAdrGet.deFldEnter;
var n: TAdrSpList;
begin
  AddStack('TAdrGet.deFldEnter',Self);
  if IsSp(Sender,n) then oSp[n]:=TFldEdit(Sender).VarValue;
  DelStack;
end;

procedure TAdrGet.deFldExit;
var n: TAdrSpList;
begin
	AddStack('TAdrGet.deFldExit',Self);
  if IsSp(Sender,n) then RecCor(n);
  DelStack;
end;

procedure TAdrGet.deFldChange;
var n: TAdrSpList;
  tf: TFldEdit;
  v: string;
  fl: boolean;
  i: TAdrCDList;
  j: byte;
begin
	AddStack('TAdrGet.deFldChange',Self);
  if IsSp(Sender,n) then case n of
    aspReg: begin
      tf:=pointer(Sender); v:=tf.VarValue;
      aAdrSp[aspNp].g.GlobKey:=v; FldRead(adrSpnp);
      aAdrSp[aspUl].g.GlobKey:=v+Sp[aspNp]; FldRead(adrSpul);
      fl:=aAdrSp[aspReg].g.IsCod(tf,v);
      de.SetReadOnly([aAdrFld[adrLand],aAdrFld[adrKr]],fl);
      de.SetReadOnly([aAdrFld[adrSpNp],aAdrFld[adrSpUl]],not fl);
    end;
    aspNp: begin
      v:=TFldEdit(Sender).VarValue;
      aAdrSp[aspUl].g.GlobKey:=Sp[aspReg]+v; FldRead(adrSpul);
      fl := Int0(v)<>0;
      for i:=low(aAdrCD) to high(aAdrCD) do if i in [acdNp,acdUl,acdRn,acdCity] then with aAdrCD[i] do
        for j:=low(af) to high(af) do de.SetReadOnly(aAdrFld[af[j]],fl);
      NotD(fl);
      if not fl then begin
        SpNpSeek; fl:=not StrToBoolean(AdrSpRdb(aspNp)['ISUL']);
      end;
      de.SetReadOnly(aAdrFld[adrSpUl],fl);
    end;
  end;
  DelStack;
end;

function TAdrGet.deFldCheck;
var tf: TFldEdit;
begin
  AddStack('TAdrGet.deFldCheck',Self);
  tf:=pointer(Sender);
  if (AnsiUpperCase(tf.NameRecFld)=aAdrFld[aAdrSp[aspUl].f])
  and not(ogReadOnly in tf.Options) and IsCity
    then result:=aAdrSp[aspUl].g.IsCod(tf,tf.VarValue) else result:=true;
  DelStack;
end;

procedure FiasWait(AfterExe: boolean; Prm: pointer; var lBreak: boolean);
begin
  AddStack('AdrGet.FiasWait');
  if AfterExe then with TAdrGet(Prm) do lBreak := not FileExists(FiasIn) and FileExists(FiasOut);
  DelStack;
end;

procedure TAdrGet.deKpProcKey;
const aErr: array[1..6] of TNamePrimStr =
  (('400','Некорректный запрос')
  ,('401','В запросе отсутствует API-ключ или секретный ключ'+CRLF+'Или в запросе указан несуществующий ключ')
  ,('403','Не подтверждена почта'+CRLF+'Или недостаточно средств для обработки запроса, пополните баланс')
  ,('405','Запрос сделан с методом, отличным от POST')
  ,('429','Слишком много запросов в секунду или новых соединений в минуту')
  ,('5??','Произошла внутренняя ошибка сервиса')
  );
var operation,source: string;
  a: TAdrStr;
  i: TAdrList;
  f: TFileBuf;
  ls: TStringList;
  lDone: boolean;
  j: longint;
begin
  AddStack('TAdrGet.deKpProcKey',Self);
  de.PanelEdit.FldActive.Write;
  case Key of
    K_Ctrl_F5: begin
      for i:=low(a) to high(a) do a[i]:=TrimRight(Fld[i]);
      operation:='clean'; source:=Name(a);
    end;
    K_Ctrl_F6: begin
      operation:='find_by_id'; source:=TrimRight(Fld[adrFias]);
    end;
  end;
  repeat
    f:=TFileBuf.Create(FiasIn,true);
    try
      if f.Active then begin
        f.WriteString(operation,[wrCrlf]);
        f.WriteString(source,[wrCrlf]);
      end
      else meserr(f.ErrorMessage);
    finally
      f.Free;
    end;
    lDone:=RunExe(FiasExe,FiasPath,'Запуск сервиса DaData',[],'',[runNoConsole,runWin],0,FiasWait,Self);
    if lDone then begin
      ls:=TStringList.Create;
      try
        ls.LoadFromFile(FiasOut); DelFileAtr(FiasOut);
        lDone := (ls.Values['operation']=operation) and (ls.Values['source']=source);
        if lDone then case Key of
          K_Ctrl_F5: begin
            operation:=ls.Values['error'];
            if operation='' then begin
              de.FldEdit[aAdrFld[adrFiasHouse]].VarValue:=IfThen(Int0(ls.Values['fias_level'])<8,'1');
              de.FldEdit[aAdrFld[adrFias]].VarValue:=ls.Values['fias_id'];
            end
            else begin
              source:='';
              for j:=low(aErr) to high(aErr) do if EqualShape(operation,aErr[j,1]) then begin
                source:=aErr[j,2]; break;
              end;
              mess_ok(['Ошибка поиска кода ФИАС по адреса (код '+operation+'):',source]);
            end
          end;
          K_Ctrl_F6:
            if ls.Values['error']=''
            then DefEditInfo('Адрес для кода ФИАС: '+source,'Fias.'+operation,[''],[ls.Values['unrestricted_value']])
            else mess_ok(['Ошибка поиска адреса по коду ФИАС.','Возможно, код ФИАС некорректный.']);
        end;
      finally
        ls.Free;
      end;
    end;
  until lDone;
  DelStack;
end;

function TAdrGet.GetFld;
begin
  AddStack('TAdrGet.GetFld',Self);
  result:=Rec[aAdrFld[Index]];
  DelStack;
end;

procedure TAdrGet.SetFld;
begin
  AddStack('TAdrGet.SetFld',Self);
  Rec[aAdrFld[Index]]:=Value;
  DelStack;
end;

function TAdrGet.GetSp;
begin
  AddStack('TAdrGet.GetSp',Self);
  result:=Fld[aAdrSp[Index].f];
  DelStack;
end;

procedure TAdrGet.SetSp;
begin
  AddStack('TAdrGet.SetSp',Self);
  Fld[aAdrSp[Index].f]:=Value;
  DelStack;
end;

class function TAdrGet.Name(const Value: TAdrStr; Opt: TAdrNameOpt = []): string;
type TAdrNmList = 1..11;
const aOrder: array[boolean,TAdrNmList] of TAdr1List =
  ((adr1Land,adr1Ind,adr1SpReg,adr1Kr,adr1Rn,adr1City,adr1Np,adr1Ul,adr1Dom,adr1Kor,adr1Kv)
  ,(adr1Ul,adr1Dom,adr1Kor,adr1Kv,adr1Np,adr1City,adr1Rn,adr1Kr,adr1SpReg,adr1Land,adr1Ind)
  );
var i: TAdrNmList;
  s: string;
  j,n: longint;
  fl: boolean;
begin
	AddStack('TAdrGet.Name');
	result:='';
	for i:=low(i) to high(i) do if (anoFull in Opt) or not(aOrder[anoGOST in Opt,i] in [adr1Land,adr1SpReg]) then begin
    s:=Part(Value,aOrder[anoGOST in Opt,i],IfThen(anoGOST in Opt,apoGOST));
    if anoGOST in Opt then if aOrder[anoGOST in Opt,i]=adr1Kr then if IsTable(tDBREG) then begin
      if not Assigned(lsReg) then with ProgPswd.GetQuery do begin
        PartSelect(tDBREG,['CODE',fNAME,'FNAME']); Finalize(aReg); ZeroMemory(@aReg,SizeOf(aReg));
        j:=RecordCount; lsReg:=TStringList.Create; lsReg.Capacity:=j;
        for j:=1 to j do begin
          n:=Int0(Fields[0].AsString); lsReg.AddObject(TrimRight(Fields[1].AsString),pointer(n));
          aReg[n]:=TrimRight(Fields[2].AsString); Next;
        end;
        ProgPswd.FreeQuery; lsReg.Sorted:=true;
      end;
      n:=Int0(Value[adrSpreg]); fl:=InRange(n,low(aReg),high(aReg));
      if fl then fl := aReg[n]<>'';
      if not fl then fl:=IntObjFind(lsReg,TrimRight(s),n);
      if fl then s:=aReg[n];
    end;
    DlmBetwSelf(result,s,', ');
  end;
  DelStack;
end;

class function TAdrGet.Name(const Value: string; Opt: TAdrNameOpt = []): string;
begin
  AddStack('TAdrGet.Name(s)');
  result:=Name(StrToAdr(Value),Opt);
  DelStack;
end;

class function TAdrGet.Part(const Value: TAdrStr; p: TAdr1List; Opt: TAdrPartOptions = []): string;
var sb,se: string;
  fl: boolean;
  cd: TAdrCDList0;
begin
  AddStack('TAdrGet.Part');
  sb:=''; se:=''; cd:=aFld1CDAdr[p];
  with aFld1[p] do if cd=acdNone then begin
    if not(apoWithoutPref in Opt) then sb:=aAbr1Beg[apoGOST in Opt,p];
    result:=Value[f];
  end
  else with aAdrCD[cd] do begin
    if not(apoWithoutPref in Opt) then begin
      sb:=Value[f];
      if apoWithoutPrefNo1 in Opt then begin
        if sb=empka then sb:='';
      end
      else if empty(sb) then sb:=empka;
      if not empty(sb) then
        if apoSocrEnd in Opt then se:=sb else sb:=g.CodeDop(sb,[cdgBufAll]);
    end;
    result:=Value[af[2]];
  end;
  TrimSelf(result);
  if apoOnlyPref in Opt then begin
    fl := result<>''; result:='';
  end
  else fl:=false;
  if (result<>'') or fl then begin
    if not(apoSocrEnd in Opt) then result:=DlmBetween(sb,result,' ');
    if not(apoWithoutPref in Opt) then DlmBetwSelf(result,se,' ');
    if apoUpper in Opt then AnsiUpperCaseSelf(result);
  end;
  DelStack;
end;

class function TAdrGet.Part(const Value: string; p: TAdr1List; Opt: TAdrPartOptions = []): string;
begin
  AddStack('TAdrGet.Part(o)');
  result:=Part(StrToAdr(Value),p,Opt);
  DelStack;
end;

procedure TAdrGet.RecCor;
	procedure FldSet(n: TAdrList; const v: string = '');
  begin
  	AddStack('TAdrGet.RecCor.FldSet',Self);
  	Fld[n]:=v; FldRead(n);
    DelStack;
  end;
  procedure SeekCDAdr(n: TAdrCDList; const name: string = ''; const socr: string = '');
  var i: longint;
    fl: boolean;
  begin
  	AddStack('TAdrGet.RecCor.SeekCDAdr',Self);
    with aAdrCD[n] do begin
      FldSet(af[2],name);
      if empty(socr) then i:=-1 else i:=g.SeekCod(socr,[cdgBufAll]);
      if i<0 then fl:=true else fl := TrimRight(g.BufCod[i])=empka;
      if fl then FldSet(af[1]) else FldSet(af[1],g.BufCod[i]);
    end;
    DelStack;
  end;
  procedure PutInd(n: TAdrSpList);
  var ind: string;
  begin
  	AddStack('TAdrGet.RecCor.PutInd',Self);
    ind:=AdrSpRdb(n)['IND'];
  	if not empty(ind) then FldSet(adrInd,ind);
    DelStack;
  end;
begin
  AddStack('TAdrGet.RecCor',Self);
  Sp[i]:=TSpLs.CodeGetTransSeek(aAdrSp[i].g,nil,Sp[i],NegDef,false);
  if oSp[i]<>Sp[i] then begin
    case i of
      aspReg: begin
        if SpRegSeek then with AdrSpRdb(aspReg) do begin
          FldSet(adrLand,Value['LAND']);
          FldSet(adrKr,TrimRight(Value[fNAME])+' '+Value['SOCR']);
        end;
        if FActive then begin
          FldSet(adrSpnp); FldSet(adrSpul);
        end;
      end;
      aspNp: begin
        if Int0(Sp[i])=0 then FldSet(adrSpul)
        else with AdrSpRdb(aspNp) do begin
          SpNpSeek;
          if IsCity then
            if (RTrimUpper(AdrSpRdb(aspReg)['SOCR'])=aAdrCD[acdCity].empka)
            and (TrimRight(AdrSpRdb(aspReg)[fNAME])=TrimRight(Value[fNAME]))
              then SeekCDAdr(acdCity)
              else SeekCDAdr(acdCity,Value[fNAME],Value['SOCR'])
          else begin
            SeekCDAdr(acdCity,Value['CITY'],Value['SOCRCITY']);
            SeekCDAdr(acdNp,Value[fNAME],Value['SOCR']);
          end;
          SeekCDAdr(acdRn,Value['RN'],Value['SOCRRN']);
          if not StrToBoolean(Value['ISUL']) then begin
            putind(aspNp); FldSet(adrUl); FldSet(adrUl1);
            if FActive then de.FldEdit[aAdrFld[adrSpul]].DoExit else RecCor(aspUl);
          end;
        end;
        if FActive then FldSet(adrSpul);
      end;
      aspUl: begin
        if Int0(Sp[i])=0 then begin
          if Int0(Sp[aspNp])<>0 then begin
            if IsCity then SeekCDAdr(acdNp);
            SeekCDAdr(acdUl);
          end;
        end
        else with AdrSpRdb(aspUl) do begin
          SpUlSeek; putind(aspUl);
          if IsCity then SeekCDAdr(acdNp,Value['NP'],Value['SOCRNP']);
          SeekCDAdr(acdUl,Value[fNAME],Value['SOCR']);
        end;
      end;
    end;
    oSp[i]:=Sp[i];
  end;
  DelStack;
end;

function TAdrGet.IsCity;
var snp: string;
begin
  AddStack('TAdrGet.IsCity',Self);
  if empty(Sp[aspReg]) then result:=false
  else begin
    snp:=Sp[aspNp];
    result := (Int0(Copy(snp,4,3))<>0) and (Int0(Copy(snp,7,3))=0);
  end;
  DelStack;
end;

procedure TAdrGet.FldRead;
begin
	AddStack('TAdrGet.FldRead',Self);
	if FActive then de.Read(aAdrFld[n]);
  DelStack;
end;

function TAdrGet.SpRegSeek;
var reg: string;
begin
	AddStack('TAdrGet.SpRegSeek',Self);
  reg:=Sp[aspReg];
  if empty(reg) then result:=false
  else with AdrSpRdb(aspReg) do result:=Seek(TblFldName(fSPREG)+'='+QQs(reg));
  DelStack;
end;

procedure TAdrGet.SpNpSeek;
var reg,snp: string;
begin
	AddStack('TAdrGet.SpNpSeek',Self);
  reg:=Sp[aspReg]; snp:=Sp[aspNp];
  with AdrSpRdb(aspNp) do
    if empty(reg) or empty(snp) then NewRec
    else if not Seek(TblFldName(fSPREG)+'='+QQs(reg)+sAND+TblFldName('KN')+'='+QQs(snp)) then NewRec;
  DelStack;
end;

procedure TAdrGet.SpUlSeek;
var gk,sul: string;
begin
	AddStack('TAdrGet.SpUlSeek',Self);
  gk:=Sp[aspReg]+Sp[aspNp]; sul:=Sp[aspUl];
  with AdrSpRdb(aspUl) do
    if empty(gk) or empty(sul) then NewRec
    else if not Seek(TblFldName('GK')+'='+QQs(gk)+sAND+TblFldName('KU')+'='+QQs(sul)) then NewRec;
  DelStack;
end;

class function TAdrGet.IsCor(Rec: TRecDB; const nmf: string): TAnkList;
var sreg,snp,sul: string;
begin
  result:=IsCor(Rec,nmf,sreg,snp,sul);
end;

class function TAdrGet.IsCor(Rec: TRecDB; const nmf: string; var sreg,snp,sul: string): TAnkList;
var acd: TAdrCDStr;
  function EqCD(i: longint; n: TAdrCDList): boolean;
  var s: string;
  begin
    AddStack('TAdrGet.IsCor.EqCD');
    s:=RTrimUpper(ProgPswd.CurQuery.Fields[i].AsString);
    if s='' then s:=aAdrCD[n].empka;
    result := s=acd[n];
    DelStack;
  end;
const aCity: array[1..3,1..3] of string = ( ('Г',' ',' '),('Г.','',' '),('ГОРОД','',' ') );
var s,st: string;
  i,l: longint;
  cd: TAdrCDList;
  a: TAdrStr;
  lCity,lCityReg: boolean;
begin
  AddStack('TAdrGet.IsCor');
  a:=StrToAdr(Rec[nmf]);
  if empty(Name(a,[])) then result:=ankEmp
  else begin
    TrimSelf(a[adrCity]); st:=AnsiUpperCase(a[adrCity]);
    for i:=low(aCity) to high(aCity) do begin
      l:=length(aCity[i,1])+length(aCity[i,2]);
      if LeftStr(st,l)=aCity[i,1]+aCity[i,2] then begin
        Delete(a[adrCity],1,l); break;
      end;
    end;
    for i:=low(aCity) to high(aCity) do begin
      l:=length(aCity[i,3])+length(aCity[i,1]);
      if RightStr(st,l)=aCity[i,3]+aCity[i,1] then begin
        DecLen(a[adrCity],l); break;
      end;
    end;
    TrimSelf(a[adrCity]); Rec[aAdrFld[adrCity]]:=a[adrCity]; Rec.UpdateRec;
    lCity:=not empty(a[adrCity]);
    for cd:=low(acd) to high(acd) do with aAdrCD[cd] do begin
      acd[cd]:=a[af[1]];
      if empty(acd[cd]) and not empty(a[af[2]]) then acd[cd]:=empka;
    end;
    s:=a[IfThen(lCity,adrCity,adrNp)];
    if empty(s) then begin
      lCity:=true; s:=a[adrKr];
    end;
    RTrimUpperSelf(s); result:=ankNopr;
    if not empty(s) then with AdrSpRdb(aspReg) do
    	if Seek(TblFldName(fSPREG)+'='+QQs(a[adrSpreg])) then begin
        sreg:=Value[fSPREG];
        if RTrimUpper(Value['LAND'])=RTrimUpper(a[adrLand]) then with ProgPswd.GetQuery do begin
          PartSelect(tSPNP,['RN','SOCR',fSpCODE,'ISUL','KN','SOCRRN',fNAME],
            fSPREG+'='+QQs(a[adrSpreg])+sAND+'UPTXT'+sLIKE+QQs(s+'%'),'UPTXT');
          result:=ankErr; st:=RTrimUpper(a[adrRn]);
          while not Eof do begin
            s:=RTrimUpper(Fields[0].AsString);
            lCityReg := (RTrimUpper(Value['SOCR'])=aAdrCD[acdCity].empka)
              and (TrimRight(Value[fNAME])=TrimRight(Fields[6].AsString));
            if (s=st)
            and ((s='') or EqCD(5,acdRn))
            and (lCity
              and (lCityReg and empty(a[adrCity])
              or not lCityReg and EqCD(1,acdCity))
            or not lCity and EqCD(1,acdNp)) then begin
              result:=ankCor; snp:=FieldValueIndex(4); break;
            end;
            Next;
          end;
          if (result=ankCor) and StrToBoolean(Fields[3]) then begin
            PartSelect(tSPUL,['SOCR','SOCRNP','NP','KU',fNAME],'GK='+QQs(Fields[2])
              +sAND+'UPTXT'+sLIKE+QQs(RTrimUpper(a[adrUl])+'%'),'UPTXT');
            result:=ankErr; st:=RTrimUpper(a[adrNp]);
            while not Eof do begin
              s:=RTrimUpper(Fields[2].AsString);
              if (empty(Fields[4].AsString) or EqCD(0,acdUl))
              and (not lCity or (s=st) and ((s='') or EqCD(1,acdNp))) then begin
                result:=ankCor; sul:=FieldValueIndex(3); break;
              end;
              Next;
            end;
          end;
          ProgPswd.FreeQuery;
        end
        else result:=ankErr;
      end;
  end;
  DelStack;
end;

class procedure TAdrGet.KrUpdate;
begin
  AddStack('TAdrGet.KrUpdate');
  if lKrUpdate then begin
    lKrUpdate:=false;
    if Ask(['Обновить адреса загруженных регионов ?']) then TNone.KrApp;
  end;
  DelStack;
end;

{ TNone }
class procedure TNone.KrRecAfterOpen;
begin
  AddStack('TNone.KrRecAfterOpen');
  TRecVal(Sender).RestFromIni;
  DelStack;
end;

class procedure TNone.KrRecBeforeClose;
begin
  AddStack('TNone.KrRecBeforeClose');
  TRecVal(Sender).SaveToIni;
  DelStack;
end;

// Добавление/удаление адресов
class procedure TNone.AdrMenuProcKey;
var fl: boolean;
begin
  AddStack('TNone.AdrMenuProcKey');
	case Key of
  	K_1,K_3: begin
      fl := Key=K_3; deKrAdd.Param['ADRKR',deNoVisible]:=bStr[fl];
      deKrAdd.Execute(IfThen(fl,'Обновление','Добавление')+' адресов');
    end;
    K_2:
      try
        RegOnlyExists:=true; deKrDel.Execute;
      finally
        RegOnlyExists:=false;
      end;
  end;
  DelStack;
end;

class procedure TNone.deDoPnlCngKey;
begin
	AddStack('TNone.deDoPnlSetKey');
	if tb.Key=K_F10 then tb.Caption:='Выполнить';
  DelStack;
end;

// Добавление/обновление адресов
class function TNone.deKrAddPnlValid;
begin
  AddStack('TNone.deKrAddPnlValid');
  result:=KrApp(IfThen(not StrToBoolean(deKrAdd.Param['ADRKR',deNoVisible]),string(AdrKrRec['ADRKR'])));
  DelStack;
end;

procedure StCdAdr(Sender: TStat; const Params: array of variant; var Aborted: boolean);
type TLevel = 2..5;
const aLevelGk: array[TLevel] of TAdrCDList = (acdRn,acdCity,acdNp,acdUl);
var f: TDbf;
  i,l,n1,n2,n3,n4: longint;
  CdAdr: TRecDB;
  level: TLevel;
  gk,nm,s: string;
  sSocrbaseGk: set of TAdrCDList;
begin
  AddStack('AdrGet.StCdAdr');
  sSocrbaseGk:=[];
  for level:=low(aLevelGk) to high(aLevelGk) do Include(sSocrbaseGk,aLevelGk[level]);
  with ProgPswd.GetQuery do begin
    DeleteTable(tCDADR);
  	CdAdr:=TRecDB.Create(Application.MainForm);
    try
      CdAdr.NameDB:=tCDADR; CdAdr.OpenRec;
      f:=TDbf.CreatePrm(Params[0]+'SOCRBASE'+IfThen(not Params[1],'W'));
      try
        n1:=f.FieldPos('LEVEL'); n2:=f.FieldPos('SCNAME'); n3:=f.FieldPos('SOCRNAME');
        l:=f.RecordCount;
        for i:=1 to l do begin
          nm:=TrimRight(f.Fields[n3]);
          if Sender.SayStat('',nm,i/l) then break;
          level:=Int0(f.Fields[n1]);
          if InRange(level,low(aLevelGk),high(aLevelGk)) then begin
            CdAdr.NewRec; CdAdr[fCdadrGK]:=Int2Str(aLevelGk[level]);
            s:=f.Fields[n2]; CdAdr[fCdadrKA]:=AnsiUpperCase(s); CdAdr['ABR']:=s;
            CdAdr[fNAME]:=nm; CdAdr[fUPNAME]:=AnsiUpperCase(nm);
            CdAdr.AppRec;
          end;
          f.Next;
        end;
      finally
        f.Free;
      end;
      if not Aborted then
        if not Sender.SayStat('Cокращения: обновление') then begin
          f:=TDbf.CreatePrm(ExeDir+'DBCDADR');
          try
            n1:=f.FieldPos(fCdadrGK); n2:=f.FieldPos(fCdadrKA); n3:=f.FieldPos('ABR'); n4:=f.FieldPos(fNAME);
            l:=f.RecordCount;
            for i:=1 to l do begin
              nm:=TrimRight(f.Fields[n4]);
              if Sender.SayStat('',nm,i/l) then break;
              gk:=f.Fields[n1];
              if TAdrCDList(Int0(gk)) in sSocrbaseGk then begin
                s:=QQs(f.Fields[n3]);
                UpdateTable('',['ABR'],[s],fCdadrKA+'='+QQs(f.Fields[n2])+sAND+'ABR<>'+s);
              end
              else begin
                CdAdr.NewRec; CdAdr[fCdadrGK]:=gk;
                CdAdr[fCdadrKA]:=f.Fields[n2]; CdAdr['ABR']:=f.Fields[n3];
                CdAdr[fNAME]:=nm; CdAdr[fUPNAME]:=AnsiUpperCase(nm);
                CdAdr.AppRec;
              end;
              f.Next;
            end;
          finally
            f.Free;
          end;
        end;
    finally
      CdAdr.Free;
    end;
  end;
  ProgPswd.FreeQuery;
  DelStack;
end;

procedure StKrUpdDel(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i: TAdrSpList;
begin
  AddStack('AdrGet.StKrUpdDel');
  for i:=low(aAdrSp) to high(aAdrSp) do with aAdrSp[i] do
    if Sender.SayStat('',GetPrim(aAdrFld[f]),(byte(i)+1)/aspCnt) then break
    else TRecDB.DeleteTable(aAdrFld[f],'*',ProgPswd.CurQuery);
  DelStack;
end;

procedure StKrIndSave(Sender: TStat; const Params: array of variant; var Aborted: boolean);
const aIndNm: TAdrIndStr = ('населённых пунктов','улиц','домов');
var ar: ^TAdrIndDbf;
  r: TAdrIndList;
  j: TAdrKrList;
  k,pCODE,pNAME: longint;
  f: TFileBuf;
  fn,s: string;
  a: array[TAdrKrList] of record
    ls: TStringList;
    crd: TAdrIndCrd;
  end;
begin
  AddStack('TNone.StKrIndSave');
  ar:=PointerVar(Params[0]);
  for j:=low(a) to high(a) do with a[j] do begin
    ls:=TStringList.Create; ZeroMemory(@crd,SizeOf(crd));
  end;
  fn:=ExtractFilePath(ar[low(ar^)].FileName)+FileAdrInd; f:=TFileBuf.Create(fn,true,LastVersAdrInd);
  try
    if f.Active then begin
      for r:=low(ar^) to high(ar^) do f.Write(GetFileDateTime(ar[r].FileName),stDouble);
      for r:=low(ar^) to high(ar^) do with ar[r] do begin
        if Sender.SayStat('Сортировка '+aIndNm[r]+' (чтение)') then break;
        pCODE:=FieldPos(fSpCODE); pNAME:=FieldPos(fNAME);
        while not Eof do begin
          if Sender.SayStat('',Fields[pNAME],Recno/RecordCount) then break;
          s:=Fields[pCODE];
          a[Int0(LeftStr(s,2))].ls.AddObject(Copy(s,3,MaxInt),pointer(LongWord(Recno)));
          Next;
        end;
        if Sender.SayStat('Сортировка '+aIndNm[r]+' (запись)') then break;
        for j:=low(a) to high(a) do with a[j] do if ls.Count>0 then begin
          if Sender.SayStat('',StrNum('Регион: ',j,2),j/high(a)) then break;
          ls.Sorted:=true; crd[r,1]:=f.Position; crd[r,2]:=ls.Count;
          for k:=0 to ls.Count-1 do f.Write(LongWordObj(ls,k),stLongWord);
          ls.Sorted:=false; ls.Clear;
        end;
      end;
      if not Sender.Aborted then
        for j:=low(a) to high(a) do with a[j] do
          for r:=low(crd) to high(crd) do
            for k:=low(crd[r]) to high(crd[r]) do f.Write(crd[r,k],stLongWord);
      if not f.Update(true) then Sender.Abort;
    end
    else begin
      MsgDlg(f.ErrorMessage); Sender.Abort;
    end;
  finally
    f.Free;
    for j:=low(a) to high(a) do a[j].ls.Free;
  end;
  if Sender.Aborted then DelFileAtr(fn);
  DelStack;
end;

procedure StKrApp(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var lsNp: TStringList;
  lsDom: TArrBoolStrList;
	lNp,lUl: longint;
  lSpnpTXT,lSpulTXT: byte;
  ogk: string;
  aNp: array of record
    code,name,socr,ind,gni,rn,socrrn: string;
    isul: boolean;
  end;
  aUl: array of record
    code,name,socr,ind,gni,dom,ku,np,socrnp: string;
  end;
  procedure spApp;
    function ulregcode(const cd: string): string;
    begin
      AddStack('AdrGet.StKrApp.spApp.ulregcode');
      if Int0(Copy(cd,6,3))=0 then result:=StuffString(cd,6,3,StringOfChar('9',3)) else result:=cd;
      DelStack;
    end;
  var s: string;
    iUl,iNp: longint;
    procedure UlAppRec(lg: boolean);
    begin
      AddStack('AdrGet.StKrApp.spApp.UlAppRec');
      with aSp[aspUl].rdb,aUl[iUl] do begin
        Value[fTXT]:=str3t(DlmBetween([s,
          IfThen(BoolObj(lsDom[lg],IfThen(not lg,aNp[iNp].code)+name+' '+socr),dom),
          StrUtils.IfThen(not empty(Value['NP']),Value['NP']+' '+Value['SOCRNP'])],', '),lSpulTXT);
        AppRec;
      end;
      DelStack;
    end;
  var NpCode: string;
  begin
    AddStack('AdrGet.StKrApp.spApp');
    if ogk<>'' then begin
      iUl:=0;
      for iNp:=0 to lNp-1 do with aSp[aspNp].rdb,aNp[iNp] do begin
        NewRec;
        NpCode:=ulregcode(code); Value[fSpCODE]:=NpCode; Value[fNAME]:=name; Value['SOCR']:=socr;
        Value['IND']:=ind; Value['GNI']:=gni;
        Value['KN']:=RightStr(NpCode,9); Value[fSPREG]:=LeftStr(NpCode,2);
        Value['RN']:=rn; Value['SOCRRN']:=socrrn; Value['ISUL']:=bStr[isul];
        if iNp>0 then with aNp[0] do begin
          Value['CITY']:=name; Value['SOCRCITY']:=socr;
        end;
        Value[fTXT]:=str3t(DlmBetween(name+' '+socr,IfThen(lsNp.IndexOf(name)>=0,
          DlmBetween([IfThen(not empty(ind),ind),
          StrUtils.IfThen(not Empty(Value['CITY']),Value['CITY']+' '+Value['SOCRCITY']),
          IfThen(not Empty(rn),rn+' '+socrrn)],', ')),', '),lSpnpTXT);
        AppRec;
        while iUl<lUl do with aSp[aspUl].rdb,aUl[iUl] do begin
          if LeftStr(code,11)>aNp[iNp].code then break;
          NewRec; Value[fSpCODE]:=ulregcode(code); Value[fNAME]:=name; Value['SOCR']:=socr;
          Value['IND']:=ind; Value['GNI']:=gni; Value['DOM']:=dom; Value['KU']:=ku;
          s:=DlmBetween(name+' '+TrimRight(socr),ind,', ');
          Value['GK']:=NpCode; UlAppRec(false);
          if iNp>0 then begin
            NewRec([newrCopy]);
            Value['NP']:=np; Value['SOCRNP']:=socrnp;
            Value['GK']:=ulregcode(aNp[0].code); UlAppRec(true);
          end;
          Inc(iUl);
        end;
      end;
    end;
    DelStack;
  end;
var ccity,cnp: string;
  ncity,nnp,kdom: Word;
  sCODE,sNAME,sSOCR: string;
  procedure AddUl(const cul,ctpul,cdom,ccode,cgni,cind: string);
  var ils: longint;
    lg,fl: boolean;
  begin
    AddStack('AdrGet.StKrApp.AddUl');
    if kdom<100 then begin
      if lUl=Length(aUl) then SetLength(aUl,lUl shl 1);
      with aUl[lUl] do begin
        code:=ccode; name:=cul; socr:=ctpul;
        np:=sNAME; socrnp:=sSOCR;
        ind:=TrimRight(cind); dom:=cdom; gni:=TrimRight(cgni);
        if empty(RightStr(ccode,4)) then ku:='' else ku:=StrNum(Copy(ccode,9,7),kdom,2);
        for lg:=false to true do begin
          fl:=IgnoreSlFindAdd(lsDom[lg],IfThen(not lg,aNp[lNp].code)+name+' '+socr,ils);
          lsDom[lg].Objects[ils]:=pointer(fl);
        end;
        Inc(kdom);
      end;
      Inc(lUl);
    end;
    DelStack;
  end;
var ar: TAdrIndDbf;
  ap,ai: TAdrIndCrd;
  f: TFileBuf;
  function IndNoEof(r: TAdrIndList): boolean;
  begin
    AddStack('AdrGet.StKrApp.IndNoEof');
    result := ai[r,2]<=ap[r,2];
    DelStack;
  end;
  procedure IndNext(r: TAdrIndList);
  begin
    AddStack('AdrGet.StKrApp.IndNext');
    if ai[r,2]<ap[r,2] then begin
      f.Seek(ai[r,1],soFromBeginning); ar[r].Recno:=f.Read(stLongWord);
      Inc(ai[r,1],SizeOfVar[stLongWord]);
    end;
    Inc(ai[r,2]);
    DelStack;
  end;
  procedure IndFirst(r: TAdrIndList);
  begin
    AddStack('AdrGet.StKrApp.IndFirst');
    ai[r,2]:=0;
    if ap[r,2]>0 then begin
      ai[r,1]:=ap[r,1]; IndNext(r);
    end;
    DelStack;
  end;
var sIND,sGNI: string;
  ssCODE,ssSOCR,ssNAME: string;
  creg,crn,cUrgent,ngk,rn,socrrn,fn,s: string;
  nrn: Word;
  lSpulCODE: byte;
  r: TAdrIndList;
  sp: TAdrSpList;
  i,
    fnNAME,fnCODE,fnSOCR,fnIND,fnGNI,
    fsCODE,fsSOCR,fsNAME,fsIND,fsGNI,
    fdCODE,fdNAME,fdIND,fdGNI: longint;
  fl,lg: boolean;
  p: longword;
begin
  AddStack('AdrGet.StKrApp');
  for sp:=low(aAdrSp) to high(aAdrSp) do AdrSpRdb(sp);
  s:=IfThen(not Params[2],'W');
  for r:=low(ar) to high(ar) do ar[r]:=TDbf.CreatePrm(Params[1]+aIndTbl[r]+s);
  lsNp:=SortStrListCreate;
  for lg:=false to true do lsDom[lg]:=SortStrListCreate;
  try
    fl:=true; fn:=Params[1]+FileAdrInd; f:=TFileBuf.Create(fn,false,LastVersAdrInd);
    try
      if f.Active then
        if f.Vers=LastVersAdrInd then begin
          fl:=false;
          for r:=low(ar) to high(ar) do
            if f.Read(stDouble)<>GetFileDateTime(ar[r].FileName) then begin
              fl:=true; break;
            end;
        end;
      if fl then begin
        FreeAndNil(f);
        if ShowStat('Сортировка адресов',StKrIndSave,[LongInt(@ar)]) then Aborted:=true
        else begin
          f:=TFileBuf.Create(fn,false,LastVersAdrInd);
          if not f.Active then Aborted:=true;
        end;
      end;
      if not Aborted then begin
        for r:=low(ap) to high(ap) do ar[r].lDosToWin:=Params[2];
        with ar[adiKLADR] do begin
          fnNAME:=FieldPos(fNAME); fnCODE:=FieldPos(fSpCODE); fnSOCR:=FieldPos('SOCR');
          fnIND:=FieldPos('INDEX'); fnGNI:=FieldPos('GNINMB');
        end;
        with ar[adiSTREET] do begin
          fsCODE:=FieldPos(fSpCODE); fsSOCR:=FieldPos('SOCR'); fsNAME:=FieldPos(fNAME);
          fsIND:=FieldPos('INDEX'); fsGNI:=FieldPos('GNINMB');
        end;
        with ar[adiDOMA] do begin
          fdCODE:=FieldPos(fSpCODE); fdNAME:=FieldPos(fNAME); fdIND:=FieldPos('INDEX');
          fdGNI:=FieldPos('GNINMB');
        end;
        if Params[3] then for nnp:=low(TAdrKrList) to high(TAdrKrList) do begin
          f.Seek(-SizeOfVar[stLongWord]
            -(high(TAdrKrList)+1-nnp)*(Length(ap)-byte(adiKLADR))*Length(ap[low(ap)])*SizeOfVar[stLongWord],soFromEnd);
          p:=f.Read(stLongWord);
          if p>0 then with aSp[aspReg].rdb do begin
            f.Seek(p,soFromBeginning); ar[adiKLADR].Recno:=f.Read(stLongWord);
            NewRec; Value[fSPREG]:=LeftStr(ar[adiKLADR][fnCODE],2);
            Value['LAND']:=ProgPswd.RecGlob.ValueDef('LANDDEF','643');
            Value[fNAME]:=ar[adiKLADR][fnNAME]; Value['SOCR']:=ar[adiKLADR][fnSOCR]; AppRec;
          end;
        end;
        f.Seek(-SizeOfVar[stLongWord]
          -(high(TAdrKrList)+1-Int0(Params[0]))*Length(ap)*Length(ap[low(ap)])*SizeOfVar[stLongWord],
          soFromEnd);
        for r:=low(ap) to high(ap) do
          for i:=low(ap[r]) to high(ap[r]) do ap[r,i]:=f.Read(stLongWord);
        if ap[adiKLADR,2]=0 then begin
          mess_ok(['В папке '+Params[1],'отсутствуют адреса по региону '+Params[0]]); Aborted:=true;
        end
        else begin
          IndFirst(adiKLADR);
          while IndNoEof(adiKLADR) do begin
            if empty(Int0(Copy(TrimRight(ar[adiKLADR][fnCODE]),12,2))) then begin
              fl:=IgnoreSlFindAdd(lsNp,TrimRight(ar[adiKLADR][fnNAME]),i); lsNp.Objects[i]:=pointer(fl);
            end;
            IndNext(adiKLADR);
          end;
          BoolObjPack(lsNp);
          ogk:=''; SetLength(aNp,100); SetLength(aUl,100);
          lSpnpTXT:=Length(aSp[aspNp].rdb[fTXT]);
          lSpulTXT:=Length(aSp[aspUl].rdb[fTXT]);
          lSpulCODE:=Length(aSp[aspUl].rdb[fSpCODE]);
          for r:=low(ar) to high(ar) do IndFirst(r);
          while IndNoEof(adiKLADR) do begin
            sNAME:=TrimRight(ar[adiKLADR][fnNAME]);
            if Sender.SayStat('',sNAME,ai[adiKLADR,2]/ap[adiKLADR,2]) then break;
            sCODE:=TrimRight(ar[adiKLADR][fnCODE]); cUrgent:=Copy(sCODE,12,2);
            if empty(Int0(cUrgent)) then begin
              SetLength(sCODE,11); sSOCR:=TrimRight(ar[adiKLADR][fnSOCR]);
              sGNI:=TrimRight(ar[adiKLADR][fnGNI]); sIND:=TrimRight(ar[adiKLADR][fnIND]);
              creg:=LeftStr(sCODE,2);
              crn:=Copy(sCODE,3,3); nrn:=Int0(crn);
              ccity:=Copy(sCODE,6,3); ncity:=Int0(ccity);
              cnp:=Copy(sCODE,9,3); nnp:=Int0(cnp);
              // Регион
              if (nrn=0) and (ncity=0) and (nnp=0) then begin
                while IndNoEof(adiSTREET) and (LeftStr(ar[adiSTREET][fsCODE],11)<sCODE) do
                  IndNext(adiSTREET);
                if AnsiStartsStr(sCODE,TrimRight(ar[adiSTREET][fsCODE])) then begin
                  ccity:=StringOfChar('9',3); ncity:=Int0(ccity);
                end;
              end;
              // Район
              if (ncity=0) and (nnp=0) then begin
                rn:=sNAME; socrrn:=sSOCR;
              end;
              // Населённый пункт
              if (ncity<>0) or (nnp<>0) then begin
                sCODE:=creg+crn+IfThen(ccity='999','000',ccity)+cnp; fl := (ncity<>0) and (nnp<>0);
                ngk:=LeftStr(sCODE,8)+IfThen(ncity=0,cnp,StringOfChar('0',length(cnp))); kdom:=0;
                if ngk<>ogk then with aSp[aspNp].rdb do begin
                  spApp; ogk:=ngk; lNp:=0; lUl:=0;
                  for lg:=false to true do lsDom[lg].Clear;
                end;
                if lNp=Length(aNp) then SetLength(aNp,lNp shl 1);
                with aNp[lNp] do begin
                  code:=sCODE; name:=sNAME; socr:=sSOCR; ind:=sIND; gni:=sGNI; isul:=false;
                end;
                if nrn=0 then begin
                  aNp[lNp].rn:=''; aNp[lNp].socrrn:='';
                end
                else begin
                  aNp[lNp].rn:=rn; aNp[lNp].socrrn:=socrrn;
                end;
                while IndNoEof(adiSTREET) and (LeftStr(ar[adiSTREET][fsCODE],11)<sCODE) do IndNext(adiSTREET);
                s:='';
                while IndNoEof(adiSTREET) do begin
                  ssCODE:=TrimRight(ar[adiSTREET][fsCODE]);
                  if LeftStr(ssCODE,11)<>sCODE then break;
                  if AnsiStartsStr(cUrgent,RightStr(ssCODE,2)) then begin
                    ssSOCR:=TrimRight(ar[adiSTREET][fsSOCR]);
                    if ssSOCR<>'ДОМ' then begin
                      aNp[lNp].isul:=true; aNp[0].isul:=true;
                      fl:=false; ssNAME:=TrimRight(ar[adiSTREET][fsNAME]); ngk:=LeftStr(ssCODE,15);
                      if ngk<>s then begin
                        s:=ngk; kdom:=0;
                      end;
                      while IndNoEof(adiDOMA) and (TrimRight(ar[adiDOMA][fdCODE])<s) do IndNext(adiDOMA);
                      if IndNoEof(adiDOMA) and AnsiStartsStr(s,ar[adiDOMA][fdCODE]) then
                        while IndNoEof(adiDOMA) and AnsiStartsStr(s,ar[adiDOMA][fdCODE]) do begin
                          AddUl(ssNAME,ssSOCR,TrimRight(ar[adiDOMA][fdNAME]),
                            ssCODE,ar[adiDOMA][fdGNI],ar[adiDOMA][fdIND]);
                          IndNext(adiDOMA);
                        end
                      else AddUl(ssNAME,ssSOCR,'',ssCODE,
                        ar[adiSTREET][fsGNI],ar[adiSTREET][fsIND]);
                    end;
                  end;
                  IndNext(adiSTREET);
                end;
                if fl then AddUl('','','',padr(sCODE,lSpulCODE,'0'),sGNI,sIND);
                Inc(lNp);
              end;
            end;
            IndNext(adiKLADR);
          end;
          spApp;
        end;
      end;
    finally
      f.Free;
    end;
  finally
    for r:=low(ar) to high(ar) do ar[r].Free;
    for lg:=false to true do lsDom[lg].Free;
    lsNp.Free; 
  end;
  DelStack;
end;

procedure StKrUpdApp(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i,l: ShortInt;
  a: PArrStr;
  s: string;
begin
  AddStack('AdrGet.StKrUpdApp');
  a:=PointerVar(Params[0]); l:=Length(a^);
  for i:=low(a^) to high(a^) do begin
    s:='Регион '+a^[i];
    if Sender.SayStat('',s,(i+1)/l) then break;
    if ShowStat(s,StKrApp,[a^[i],Params[1],Params[2],i=low(a^)]) then begin
      Aborted:=true; break;
    end;
  end;
  DelStack;
end;

procedure StKrDel(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i: TAdrSpList;
  w: string;
begin
  AddStack('AdrGet.StKrDel');
  w:=fSpCODE+sLIKE+QQs(NumStr(Params[0],2)+'%');
  with ProgPswd.GetQuery do for i:=low(aAdrSp) to high(aAdrSp) do with aAdrSp[i] do begin
    if Sender.SayStat('',GetPrim(aAdrFld[f]),(byte(i)+1)/aspCnt) then break;
    if aSp[i].lLoad then DeleteTable(aAdrFld[f],w);
  end;
  ProgPswd.FreeQuery;
  DelStack;
end;

class function TNone.KrApp;
var dir: TFileName;
  function ExFile(const send: string): boolean;
  var i: TAdrIndList;
  begin
    AddStack('TNone.KrApp.ExFile');
    result:=MyFileExists(dir+'SOCRBASE'+send+'.DBF');
    if result then for i:=low(aIndTbl) to high(aIndTbl) do
      if not MyFileExists(dir+aIndTbl[i]+send+'.DBF') then begin
        result:=false; break;
      end;
    DelStack;
  end;
var lDos: boolean;
  sp: TAdrSpList;
  a: TArrStr;
begin
  AddStack('TNone.KrApp');
  dir:=CorrDir(AdrKrRec['ADRDIR']); lDos:=ExFile(''); result:=false;
  if lDos or ExFile('W') then begin
    SetLength(a,Length(aAdrSp)); 
    for sp:=low(aAdrSp) to high(aAdrSp) do a[byte(sp)]:=aAdrFld[aAdrSp[sp].f];
    AddFrom(a,tCDADR);
    if TrnsStart(a) then try
      if not ShowStat('Cокращения: добавление',StCdAdr,[dir,lDos]) then begin
        if kr='' then begin
          result:=true;
          with ProgPswd.GetQuery do begin
            PartSelect(tSPNP,fSPREG,'',fSPREG,fSPREG); SaveTo(a);
            if Length(a)>0 then
              if ShowStat('Удаление справочников',StKrUpdDel) then result:=false;
          end;
          ProgPswd.FreeQuery;
          if result then begin
            if ShowStat('Обновление регионов',StKrUpdApp,[Longint(@a),dir,lDos],Length(a)) then result:=false;
            if result and (VersAdr>0) then with ProgPswd.RecGlob do begin
              Value['VERSADR']:=VersAdr; UpdateRec;
            end;
          end;
        end
        else begin
          for sp:=low(aAdrSp) to high(aAdrSp) do
            if not aSp[sp].lLoad then TRecDB.DeleteTable(aAdrFld[aAdrSp[sp].f]);
          if not ShowStat('Регион '+kr+': удаление',StKrDel,[kr])
          then result:=not ShowStat('Регион '+kr+': добавление',StKrApp,[kr,dir,lDos,true]);
        end;
        if result then ProgPswd.SendUpd(updCodeGet,true);
      end;
      TrnsEnd(IfThen(result,trnsCommit));
    except
      TrnsEnd; raise
    end;
  end
  else mess_ok(['В папке',TrimRight(AdrKrRec['ADRDIR']),
    'отсутствуют базы данных программы "КЛАДР".']);
  DelStack;
end;

// Удаление адресов
class function TNone.deKrDelPnlValid;
var kr: string;
  a: TAdrSpStr;
  i: TAdrSpList;
begin
  AddStack('TNone.deKrDelPnlValid');
  kr:=AdrKrRec['ADRKR']; result:=false;
  if Ask(['Вы уверены, что хотите удалить','адреса по региону',
  Trim(aAdrSp[aspReg].g.Codes(deKrDel.FldEdit['ADRKR'],kr))+' ?']) then begin
    for i:=low(aAdrSp) to high(aAdrSp) do a[i]:=IfThen(aSp[i].lLoad,aAdrFld[aAdrSp[i].f]);
    if TrnsStart(a) then try
      result:=not ShowStat('Регион '+Trim(aAdrSp[aspReg].g.Codes(kr))+': удаление',StKrDel,[kr]);
      TrnsEnd(IfThen(result,trnsCommit));
      if result then ProgPswd.SendUpd(updCodeGet,true);
    except
      TrnsEnd; raise
    end;
  end;
  DelStack;
end;

{ TDBRegLs}
procedure TDBRegLs.FormCreate;
begin
	AddStack('TDBRegLs.FormCreate',Self);
  inherited;
  Caption:='Регионы'; Browl1.OnTransSeek:=Browl1TransSeek;
  with BrQuery1 do begin
    Connection:=DBMain;
  	Init(DBMain,[fDBREG],[fDBREG],tDBREG,[fDBREG,'FNAME']);
    Browl1.FieldSeek:=CreateStringField(fDBREG,'Код',0,taRightJustify);
    CreateStringField('FNAME','Наименование');
  end;
  Browl1.OnGrayCell:=Browl1GrayCell;
  DelStack;
end;

class function TDBRegLs.Browl1TransSeek;
begin
  AddStack('TDBRegLs.Browl1TransSeek');
  result:=NumStr(Value,Size);
  DelStack;
end;

function TDBRegLs.Browl1GrayCell;
var i: longint;
begin
  AddStack('TDBRegLs.Browl1GrayCell');
  i:=Int0(Browl1.FieldSeek.AsString);
  if InRange(i,low(TAdrKrList),high(TAdrKrList)) then result:=not(i in sAdrKr) else result:=false;
  DelStack;
end;

procedure TDBRegLs.WMFormLimit;
begin
	AddStack('TDBRegLs.WMFormLimit',Self);
  inherited;
  FreeLimit(DBRegLs);
  DelStack;
end;

class function TDBRegLs.CodeGetFormIBList;
begin
  AddStack('TDBRegLs.CodeGetFormIBList');
  CreateForm(TDBRegLs,DBRegLs); result:=DBRegLs;
  with DBRegLs,ProgPswd.GetQuery do begin
    PartSelect(tSPNP,fSPREG,'','',fSPREG); sAdrKr:=[];
    while not Eof do begin
      Include(sAdrKr,Int0(Fields[0].AsString)); Next;
    end;
    ProgPswd.FreeQuery;
  end;
  DelStack;
end;

class procedure TDBRegLs.CodeGetAfterList;
begin
  AddStack('TDBRegLs.CodeGetAfterList');
  FormFree(DBRegLs);
  DelStack;
end;

class function TDBRegLs.CodeGetStrName;
begin
	AddStack('TDBRegLs.CodeGetStrName');
	result:=Qry.FieldZN('FNAME');
  DelStack;
end;

class function TDBRegLs.CodeGetTransSeek;
begin
  AddStack('TDBRegLs.CodeGetTransSeek');
  if empty(Value) then result:=Space(Size) else result:=NumStr(Value,Size);
  DelStack;
end;

class procedure TDBRegLs.CodeGetAfterMinWidthCode;
begin
  AddStack('TDBRegLs.CodeGetAfterMinWidthCode');
  with TFldEdit(Sender) do result:=Canvas.TextWidth(StringOfChar('0',Length(Value)));
  DelStack;
end;

{ TSpLs }
procedure TSpLs.FormCreate;
var i: TAdrSpList;
begin
	AddStack('TSpLs.FormCreate',Self);
  inherited;
  for i:=low(aSp) to high(aSp) do if ClassType=aSp[i].cls then begin
    Tag:=byte(i); break;
  end;
  Caption:=''; Browl1.OnTransSeek:=Browl1TransSeek;
  Proc(AdrSpLsProc,adrCreate,[longint(KeyLb1)]);
  DelStack;
end;

procedure TSpLs.KeyLb1ProcKey(key: Integer; tw: TWinControl);
begin
  AddStack('TSpLs.KeyLb1ProcKey',Self);
  inherited;
  Proc(AdrSpLsProc,adrProcKey,[key,longint(tw)]);
  DelStack;
end;

function spTag(Sender: TObject): TAdrSpList;
begin
  result:=TAdrSpList(TComponent(Sender).Tag);
end;

procedure TSpLs.WMFormLimit;
var i: TAdrSpList;
begin
	AddStack('TSpLs.WMFormLimit',Self);
  inherited;
  for i:=low(aSp) to high(aSp) do if FreeLimit(aSp[i].fls) then break;
  DelStack;
end;

class function TSpLs.CodeGetFormIBList;
begin
	AddStack('TSpLs.CodeGetFormIBList');
  with aSp[spTag(Sender.curget)] do begin
    if CreateForm(cls,fls) then fls.BrQuery1.CreateField(dop);
    result:=fls;
  end;
  DelStack;
end;

class procedure TSpLs.CodeGetAfterList;
begin
  AddStack('TSpLs.CodeGetAfterList');
  FormFree(aSp[spTag(Sender)].fls);
  DelStack;
end;

class function TSpLs.CodeGetStrName;
begin
	AddStack('TSpLs.CodeGetStrName');
	result:=Qry.FieldZN(aSp[spTag(Sender)].nm);
  DelStack;
end;

class function TSpLs.CodeGetStrDop;
begin
	AddStack('TSpLs.RegGetStrDop');
  result:=Qry.FieldZN(aSp[spTag(Sender)].dop);
  DelStack;
end;

class function TSpLs.CodeGetTransSeek;
begin
  AddStack('TSpLs.CodeGetTransSeek');
  if empty(Value) then result:=Space(Size) else result:=NumStr(Value,Size);
  DelStack;
end;

class procedure TSpLs.CodeGetAfterMinWidthCode;
begin
  AddStack('TSpLs.CodeGetAfterMinWidthCode');
  with TFldEdit(Sender) do result:=Canvas.TextWidth(StringOfChar('0',Length(Value)));
  DelStack;
end;

class procedure TSpLs.RdbCalculate;
begin
  AddStack('TSpLs.RdbCalculate');
  with TRecDB(Sender),aSp[spTag(Sender)] do Value['UP'+nm]:=AnsiUpperCase(Value[nm]);
  DelStack;
end;

{ TSpRegLs }
procedure TSpRegLs.FormCreate;
begin
	AddStack('TSpRegLs.FormCreate',Self);
  inherited;
  with BrQuery1 do begin
    Connection:=DBMain; Arg['kr']:=QryNone(true);
  	Init(DBMain,[fSPREG,fUPNAME],[],tSPREG,[fSPREG,fNAME,fUPNAME,fRECNO,'SOCR'],'{kr}');
    Browl1.FieldSeek:=CreateStringField(fSPREG,'Код',0,taRightJustify);
    CreateField(fUPNAME).DisplayLabel:=CreateStringField(fNAME,'Наименование').DisplayLabel;
  end;
  DelStack;
end;

class function TSpRegLs.Browl1TransSeek;
begin
  AddStack('TSpRegLs.Browl1TransSeek');
  result:=NumStr(Value,Size);
  DelStack;
end;

function TSpRegLs.Browl1GrayCell;
var i: longint;
begin
  AddStack('TSpRegLs.Browl1GrayCell');
  i:=Int0(Browl1.FieldSeek.AsString);
  if InRange(i,low(TAdrKrList),high(TAdrKrList)) then result:=not(i in sAdrKr) else result:=false;
  DelStack;
end;

class function TSpRegLs.CodeGetFormIBList;
begin
  AddStack('TSpRegLs.CodeGetFormIBList');
  result:=inherited CodeGetFormIBList(Sender);
  with TSpRegLs(result),ProgPswd.GetQuery do begin
    PartSelect(tSPNP,fSPREG,'','',fSPREG);
    if RegOnlyExists then begin
      BrQuery1.Arg['kr']:=QryNone(FldInSel(fSPREG,'','','',[],nil,'',ProgPswd.CurQuery));
      Browl1.OnGrayCell:=nil;
    end
    else begin
      BrQuery1.Arg['kr']:=QryNone(true); sAdrKr:=[];
      while not Eof do begin
        Include(sAdrKr,Int0(Fields[0].AsString)); Next;
      end;
      Browl1.OnGrayCell:=Browl1GrayCell;
    end;
    ProgPswd.FreeQuery;
  end;
  DelStack;
end;

{ TSpNpLs }
procedure TSpNpLs.FormCreate;
var i: TAdrSpList;
begin
	AddStack('TSpNpLs.FormCreate',Self);
  inherited;
  i:=spTag(Self);
  with BrQuery1,aSp[i] do begin
  	Init(DBMain,[cod,'UPTXT'],[],aAdrFld[aAdrSp[i].f],[],gk+'='+QQs(qGlobKey));
    CreateStringField(cod,'Код',0,taRightJustify);
    CreateStringField(fTXT,'Наименование');
    Browl1.FieldSeek:=CreateStringField('UPTXT','Наименование'); Browl1.FieldSeek.Visible:=false;
  end;
  DelStack;
end;

class function TSpNpLs.Browl1TransSeek;
begin
  AddStack('TSpNpLs.Browl1TransSeek');
  result:=AnsiUpperCase(Value);
  DelStack;
end;

{ TCDAdrLs }
procedure TCDAdrLs.FormCreate(Sender: TObject);
begin
	AddStack('TCDAdrLs.FormCreate',Self);
  inherited;
  with BrQuery1 do begin
  	Init(DBMain,[fCdadrKA,fUPNAME],[],tCDADR,[],fCdadrGK+'='+QQs(qGlobKey));
    Browl1.FieldSeek:=CreateStringField(fCdadrKA,'Сокращение');
    CreateField(fUPNAME).DisplayLabel:=CreateStringField(fNAME,'Наименование').DisplayLabel;
    CreateField('ABR');
  end;
  Proc(CDAdrLsProc,adrCreate,[longint(KeyLb1)]);
  DelStack;
end;

procedure TCDAdrLs.KeyLb1ProcKey(key: Integer; tw: TWinControl);
begin
  AddStack('TCDAdrLs.KeyLb1ProcKey',Self);
  inherited;
  Proc(CDAdrLsProc,adrProcKey,[key,longint(tw)]);
  DelStack;
end;

procedure TCDAdrLs.WMFormLimit;
begin
	AddStack('TCDAdrLs.WMFormLimit',Self);
  inherited;
  FreeLimit(CDAdrLs);
  DelStack;
end;

class function TCDAdrLs.CodeGetListOwner;
const aCapt: TAdrCDStr = ('населённых пунктов','улиц','корпусов','районов','городов');
begin
	AddStack('TCDAdrLs.CodeGetListOwner');
	CreateForm(TCDAdrLs,CDAdrLs); result:=false;
  CDAdrCur:=TAdrCDList(Int0(RightStr(TFldEdit(Sender).VName,1)));
  CDAdrLs.Caption:='Типы '+aCapt[CDAdrCur];
  DelStack;
end;

class function TCDAdrLs.CodeGetFormIBList;
begin
	AddStack('TCDAdrLs.CodeGetFormIBList');
	result:=CDAdrLs;
  DelStack;
end;

class procedure TCDAdrLs.CodeGetAfterList;
begin
	AddStack('TCDAdrLs.CodeGetAfterList');
  FormFree(CDAdrLs);
  DelStack;
end;

class function TCDAdrLs.CodeGetStrDop;
begin
	AddStack('TCDAdrLs.CodeGetStrDop');
	result:=Qry.FieldZN('ABR');
  DelStack;
end;

class function TCDAdrLs.CodeGetTransSeek;
begin
	AddStack('TCDAdrLs.CodeGetTransSeek');
	result:=Padr(AnsiUpperCase(Value),Size);
  DelStack;
end;

procedure SpGkDefProc(lsDef: TSpGkStrList);
var i: TAdr1List;
  p: PSpGkStr;
  a: array[1..2] of string;
begin
  AddStack('AdrGet.SpGkDefProc');
  for i:=low(aFld1) to high(aFld1) do with aFld1[i] do begin
    LsArrFill(ms,a,',');
    if a[1]='SP' then begin
      p:=lsDef.AddKey(a[2]);
      p[spgkPrim]:=StrTran(nm,UnDelim,' ');
      p[spgkRows]:='1';
      p[spgkCols]:=IntToStr(l);
    end;
  end;
  DelStack;
end;

{procedure SetNewExeVers;
var oVersAdr: longint;
  i: TAdrSpList;
  fl: boolean;
begin
  AddStack('AdrGet.SetNewExeVers');
  AdrKrRec; ProgPswd.RecGlob.OpenRec; oVersAdr:=ProgPswd.RecGlob.ValueDef('VERSADR',3);
  if VersAdr>oVersAdr then begin
    fl:=true;
    for i:=low(aAdrSp) to high(aAdrSp) do with AdrSpRdb(i) do begin
      OpenRec;
      if not Active then begin
        fl:=false; break;
      end;
    end;
    with AdrSpRdb(aspNp) do if not IsField('CITY') then begin
      fl:=false; CloseRec;
    end;
    if fl then TAdrGet.KrUpdate;
  end;
  DelStack;
end;}

procedure Init;
const aSpNm: TAdrSpStr = ('Регионы','Населённые пункты','Улицы');
var i: TAdr1List;
  j: TAdrCDList;
  n: TAdrSpList;
begin
  AddStack('AdrGet.initialization');
  SetPrim(tCDADR,'Справочники типов компонентов адреса');
	with TInter do begin
    SetFunction('Адрес',1800);
    SetFunction('АДРЕС','Преобразует значение из вида ввода "Адрес" в строку',
      ['Значение: строка','[ГОСТ: логическое = '+vFalse+']'],['C','LU'],c_name,null,1801);
    SetFunction('АДРЕС_ЧАСТЬ','Часть адреса',
      ['Значение: строка','Номер: целое','[Преф: логическое|целое = '+vTrue+']','[Больш: логическое = '+vFalse+']'],
      ['C','N','LNU','LU'],c_part,null,1802,'C');
    SetFunction(FuncAdrFill,'',['АдрВвод: целое'],['N'],c_fill,null);
  end;
  ZeroMemory(@aFld1CDAdr,SizeOf(aFld1CDAdr));
  for i:=low(aFld1CDAdr) to high(aFld1CDAdr) do
    for j:=low(aAdrCD) to high(aAdrCD) do if aAdrCD[j].af[1]=aFld1[i].f then begin
      aFld1CDAdr[i]:=j; break;
    end;
  for n:=low(aAdrSp) to high(aAdrSp) do SetPrim(aAdrFld[aAdrSp[n].f],aSpNm[n]);
  AddFrom(SpGkDefProc);
  //AddFrom(aSetNewExeVers,SetNewExeVers);
  DelStack;
end;

initialization
  Init;
finalization
  AddStack('AdrGet.finalization');
  lsReg.Free;
  DelStack;
end.
