unit DefEdit;

interface

{$I LIBTEST}
{$DEFINE OSEEK}
uses
  Messages,Classes,Controls,Forms,StdCtrls,
  MyTypes,FPanel,PnlEdit,FFldEdit,FrmEdt,Schem,RecVal;

type
  TDESchemEvent = procedure(Sender: TObject; var Message: TWMSchem) of object;

  TDEExitResult = record
    Saved,WasShow: boolean;
  end;

  TDEFldOnPanelList = (depnBound,depnNoScroll); TDEFldOnPanelOpt = set of TDEFldOnPanelList;

  TDefEdit = class(TComponent)
  private
    { Private declarations }
    FFrmBorderIcons: TBorderIcons;
    FFrmBorderStyle: TFormBorderStyle;
    FFrmCaption: TCaption;
    FFields,FPages: TStrings;
    FHelpContext: THelpContext;
    FNameWnd,FDcmDef: string;
    aFldEdit: TArrFldEdit;
    {$IFNDEF OSEEK}FldName: TStringList; {$ENDIF}
	 	FNmProc: TKeyLbNmProc;
    FPnlAskByCancel,FDcmBased: boolean;
    FPnlSortMode: TSortMode;
    FOnFrmShow,FOnFrmHide,FOnFrmActivate,FOnFrmDeactivate,
      FOnFldAfterExit,FOnFldEnter,FOnFldExit,FOnPnlUpdateRec,FOnPnlSetWHMin,FOnPnlAfterEscape: TNotifyEvent;
	 	FOnFldCheck,FOnPnlAskCancel,FOnPnlValid: TProcValid;
    FOnFldChange: TFEChangeEvent;
    FOnMessage: TWndMethod;
    FOnPnlEscape: TCloseEvent;
    FOnPnlCngKey: TPECngKeyEvent;
    FOnKpProcKey: TKeyProc;
    FOnSchem: TDESchemEvent;
		//function Getcurget(const vIndex: variant): TCustomGet;
    function GetFldEdit(const vIndex: variant): TFldEdit;
		function GetFldHelpContext(const vIndex: variant): THelpContext;
		function GetFldSayCaption(const vIndex: variant): string;
		function GetFldValue(const vIndex: variant): variant;
		function GetMask(const vIndex: variant): string;
		//function GetNameRecFld(const vIndex: variant): string;
		function GetOldValue(const vIndex: variant): string;
		function GetOptions(const vIndex: variant): TGetOptions;
    function GetParam(const vIndex: variant; nPrm: TDEPrmList): string;
		function GetParent(const vIndex: variant): TWinControl;
		function GetPNameRec(const vIndex: variant): TCustomRec;
		function GetVisible(const vIndex: variant): boolean;
	 	procedure SetFields(v: TStrings);
	 	procedure SetNmProc(v: TKeyLbNmProc);
	 	procedure SetPages(v: TStrings);
		procedure SetFldHelpContext(const vIndex: variant; v: THelpContext);
		procedure SetFldSayCaption(const vIndex: variant; const v: string);
		procedure SetFldValue(const vIndex,v: variant);
		procedure SetMask(const vIndex: variant; const v: string);
		//procedure SetNameRecFld(const vIndex: variant; const v: string);
		procedure SetOptions(const vIndex: variant; v: TGetOptions);
    procedure SetParam(const vIndex: variant; nPrm: TDEPrmList; const Value: string);
		procedure SetVisible(const vIndex: variant; v: boolean);
    procedure FieldsChange(Sender: TObject);
		procedure FormDeActivate(Sender: TObject);
		procedure FFldOnPanel(Sender: TRbPanel; Opt: TDEFldOnPanelOpt = []);
		class procedure GFEnter(Sender: TObject);
		class procedure GFExit(Sender: TObject);
		class procedure GFProcKey(Key: longint; tw: TWinControl);
    class procedure GFFontKeyProc(key: longint; tw: TWinControl);
    class procedure GFFontProc(lAfter: boolean; var StrList,KeyStr: string; var ProcKey: TKeyProc;
      var MouseDown,MouseUp: TMouseEvent; var MouseMove: TMouseMoveEvent; var Show: TNotifyEvent);
		//procedure FOnFldAfterExitGF(Sender: TObject);
		class procedure InfoShow(Sender: TObject);
    class procedure InfoCngKey(Sender: TObject; var tb: TKeyBut);
  protected
    { Protected declarations }
		procedure FormHide(Sender: TObject); virtual;
		procedure FormActivate(Sender: TObject); virtual;
    procedure FormSchem(Sender: TObject; var Message: TWMSchem); virtual;
  public
    { Public declarations }
    Params: TArrVar;
    Panel: TRbPanel;
    FldCount: longint;
    //property curget[const Index: variant]: TCustomGet read Getcurget;
    property FldEdit[const Index: variant]: TFldEdit read GetFldEdit;
   	property FldHelpContext[const Index: variant]: THelpContext read GetFldHelpContext write SetFldHelpContext;
   	property FldSayCaption[const Index: variant]: string read GetFldSayCaption write SetFldSayCaption;
   	property FldValue[const Index: variant]: variant read GetFldValue write SetFldValue;
   	property Mask[const Index: variant]: string read GetMask write SetMask;
   	//property NameRecFld[const Index: variant]: string read GetNameRecFld write SetNameRecFld;
    property OldValue[const Index: variant]: string read GetOldValue;
    property Options[const Index: variant]: TGetOptions read GetOptions write SetOptions;
    property Param[const Index: variant; nPrm: TDEPrmList]: string read GetParam write SetParam;
    property Parent[const Index: variant]: TWinControl read GetParent;
    property PNameRec[const Index: variant]: TCustomRec read GetPNameRec;
   	property Visible[const Index: variant]: boolean read GetVisible write SetVisible;
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
    function Execute(const av: array of variant;
    	const Capt: TCaption = ''; CanShow: TDECanShow = desAlways; PrPnlUpdateRecDB: TProcValid = nil): TDEExitResult; overload; virtual;
    function Execute(const Capt: TCaption = ''; CanShow: TDECanShow = desAlways; PrPnlUpdateRecDB: TProcValid = nil): TDEExitResult; overload;
    function Execute(usl: boolean; const Capt: TCaption = ''; CanShow: TDECanShow = desAlways; PrPnlUpdateRecDB: TProcValid = nil): boolean; overload;
    function CreateFld(const aPrm: TDEPrmVar; const nmfBefore: string = ''): longint;
    procedure DestroyFld(const vIndex: variant);
    procedure DestroyFlds(const aIndex: array of string);
		procedure FldOnPanel(Sender: TRbPanel; Opt: TDEFldOnPanelOpt = []);
		procedure FormShow(Sender: TObject); virtual;
		function PrFldList(Sender: TWinControl; MinWidth: longint; const Capt: string; var txt: string): boolean;
		function PrEdSay(Sender: TObject): string;
    procedure SetDopKey;
		function SeekIndex(const vIndex: variant; var Index: longint; lFld: boolean = false): boolean; overload;
		function SeekIndex(const vIndex: variant; lFld: boolean = false): longint; overload;
    function PanelEdit: TPanelEdit; overload;
    function PanelEdit(var pe: TPanelEdit): boolean; overload;
		procedure FillFldList;
    procedure MainRebuild(lSetRdw: boolean = true);
    function IsFldEdit(const nmf: variant; var tf: TFldEdit; lPnEd: boolean = false): boolean; overload;
    function IsFldEdit(const nmf: variant; lPnEd: boolean = false): boolean; overload;
    procedure FldEditDef(var Sender: TFldEdit; const nmf: variant);
    procedure Change(const nmf,oldv: variant; FromShow: boolean);
    procedure Read(const anmf: array of variant; Opt: TFEReadOpt = []); overload;
    procedure Read(const nmf: variant; Opt: TFEReadOpt = []); overload;
    procedure SetFocus(const nmf: variant);
		procedure SetReadOnly(const anmf: array of variant; Value: boolean; opt: TGetOptions = [ogReadOnly]); overload;
		function SetReadOnly(const nmf: variant; Value: boolean; opt: TGetOptions = [ogReadOnly]): boolean; overload;
		function SetReadOnly(const nmf: variant; Value: boolean; opt: TGetOption): boolean; overload;
		procedure SetReadOnly(const anmf: array of variant; ro: boolean; const Value: variant); overload;
		function SetReadOnly(const nmf: variant; ro: boolean; const Value: variant; opt: TGetOptions = [ogReadOnly]): boolean; overload;
		procedure SetReadOnly(Value: boolean; opt: TGetOptions = [ogReadOnly]); overload;
    function FldValueDef(const nmf,Def: variant): variant;
    function EditValueDef(const nmf: variant; const Def: string): string;
    function GetArrParam(Index: longint): TDEPrmStr; overload;
    function GetArrParam(const vIndex: variant; var Index: longint; var a: TDEPrmStr): boolean; overload;
    function GetArrParam(const vIndex: variant; var av: TDEPrmVar): boolean; overload;
    procedure SetArrParam(Index: longint; const ac: TDEPrmStr);
		procedure ReplaceNameRec(const OldNmRec: string; NewNmRec: TCustomRec);
    class function Find(const sWnd: string): TDefEdit; overload;
    class function Find(const sWnd: string; var de: TDefEdit): boolean; overload;
    class function ExecNm(const nmWnd: string; const Capt: TCaption = ''): TDEExitResult;
    //class procedure FreeForms;
		class procedure ConvertToForm(SortMode: TSortMode; const Fields: string; var DcmDef: string);
		class procedure RenameSection(const oldSect,newSect: string);
		class procedure EraseSection(const Section: string);
    procedure AssignGet(const vIndex: variant; g: TCustomGet); overload;
    procedure AssignGet(const vIndex: variant; g: TCustomGetClass; const VName: string = ''); overload;
    procedure SetParams(const vIndex: array of variant; nPrm: TDEPrmList; const Value: string);
    procedure SetVisibles(const vIndex: array of variant; Value: boolean);
  published
    { Published declarations }
    property DcmBased: boolean read FDcmBased write FDcmBased;
    property DcmDef: string read FDcmDef write FDcmDef;
    property FrmBorderIcons: TBorderIcons read FFrmBorderIcons write FFrmBorderIcons;
    property FrmBorderStyle: TFormBorderStyle read FFrmBorderStyle write FFrmBorderStyle;
    property FrmCaption: TCaption read FFrmCaption write FFrmCaption;
    property Fields: TStrings read FFields write SetFields;
    property HelpContext: THelpContext read FHelpContext write FHelpContext;
    property NmProc: TKeyLbNmProc read FNmProc write SetNmProc;
    property NameWnd: string read FNameWnd write FNameWnd;
    property Pages: TStrings read FPages write SetPages;
    property PnlAskByCancel: boolean read FPnlAskByCancel write FPnlAskByCancel;
    property PnlSortMode: TSortMode read FPnlSortMode write FPnlSortMode;
	 	property OnFldAfterExit: TNotifyEvent read FOnFldAfterExit write FOnFldAfterExit;
	 	property OnFldCheck: TProcValid read FOnFldCheck write FOnFldCheck;
   	property OnFldChange: TFEChangeEvent read FOnFldChange write FOnFldChange;
	 	property OnFldEnter: TNotifyEvent read FOnFldEnter write FOnFldEnter;
	 	property OnFldExit: TNotifyEvent read FOnFldExit write FOnFldExit;
	 	property OnFrmActivate: TNotifyEvent read FOnFrmActivate write FOnFrmActivate;
	 	property OnFrmDeactivate: TNotifyEvent read FOnFrmDeactivate write FOnFrmDeactivate;
	 	property OnFrmHide: TNotifyEvent read FOnFrmHide write FOnFrmHide;
	 	property OnFrmShow: TNotifyEvent read FOnFrmShow write FOnFrmShow;
    property OnMessage: TWndMethod read FOnMessage write FOnMessage;
	 	property OnKpProcKey: TKeyProc read FOnKpProcKey write FOnKpProcKey;
    property OnPnlAfterEscape: TNotifyEvent read FOnPnlAfterEscape write FOnPnlAfterEscape;
    property OnPnlAskCancel: TProcValid read FOnPnlAskCancel write FOnPnlAskCancel;
    property OnPnlCngKey: TPECngKeyEvent read FOnPnlCngKey write FOnPnlCngKey;
    property OnPnlEscape: TCloseEvent read FOnPnlEscape write FOnPnlEscape;
    property OnPnlSetWHMin: TNotifyEvent read FOnPnlSetWHMin write FOnPnlSetWHMin;
    property OnPnlUpdateRec: TNotifyEvent read FOnPnlUpdateRec write FOnPnlUpdateRec;
    property OnPnlValid: TProcValid read FOnPnlValid write FOnPnlValid;
	 	property OnSchem: TDESchemEvent read FOnSchem write FOnSchem;
  end;

	TFormDefEdt = class(TFormEdt)
  private
    procedure WMSchem(var msg: TWMSchem); message WM_SCHEM;
  	procedure WMSaveIni(var Msg: TWMSaveIni); message WM_SAVEINI;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
		procedure WMHelpFill(var msg: TMessage); message WM_HELPFILL;
		procedure WMFldVar(var msg: TMessage); message WM_FLDVAR;
		procedure WMRebuild(var Message: TMessage); message WM_REBUILD;
		procedure WMMessage(var Message: TMessage);
  public
    de: TDefEdit;
    function MainRbPanel: TRbPanel;
  end;

  TDEInfoOper = (deiSetting,deiBefore,deiFld,deiAfter);
  TDEInfoSetting = procedure(Oper: TDEInfoOper; Sender: TObject; p: pointer);

const
  DEKeyDopName = 'dop';
	aDeToEdit: array[TDECharCase] of TEditCharCase = (ecNormal,ecUpperCase,ecLowerCase);

var ActiveDefEdit: TDefEdit;
  PrDefEditRdbCng: procedure(var a: TDEPrmStr);

procedure DefEditInfo(const Capt: TCaption; const ANameWnd: string; const aSay,aGet: array of string;
	PrSetting: TDEInfoSetting = nil; pSetting: pointer = nil;
  const DopKeyStr: string = ''; DopKeyProc: TKeyProc = nil);
function IfThen(AValue: boolean; ATrue: TDEFldOnPanelList): TDEFldOnPanelOpt; overload;
procedure Register;

implementation

uses
  Windows,Math,SysUtils,DB,ComCtrls,Variants,StrUtils,
  My_pr,KeyLb,ChkGets,MultiGet,RbPage,ListF2,GenForm,RbScroll,RecDB,Shifr;

const SectBeg = 'TDefEdit.';

type
  TDEGFScrollBox = class(TRbScrollBox)
  private
   	procedure WMRebuild(var msg: TWMRebuild); message WM_REBUILD;
  end;

  TDEInfoSetRec = record
    pr: TDEInfoSetting;
    p: pointer;
  end;

var
	LsDefEdit: TList;
  aForm: array of TFormDefEdt;
  nForm: longint = -1;
	ppd: TPPDocRec;
  GFLenCod,GFLenName: longint;
  DefEditGFCur: TGenForm;

procedure IfThenSetting(Tag: longint; Oper: TDEInfoOper; Sender: TObject);
var r: ^TDEInfoSetRec;
begin
  r:=pointer(Tag);
  if Assigned(r.pr) then r.pr(Oper,Sender,r.p);
end;

procedure DefEditInfo;
type TGetList = 1..3;
const agt: array[TGetList] of TCustomGetClass = (TSimpleGet,TBoolGet,TMultiGet);
var i,j: longint;
	sg: string;
  deInfo: TDefEdit;
  rInfo: TRecVal;
  lBool,lMulti: boolean;
  ng: 0..high(TGetList);
  r: TDEInfoSetRec;
  av: TDEPrmVar;
begin
  AddStack('DefEdit.DefEditInfo');
  rInfo:=TRecVal.Create(Application.MainForm); deInfo:=TDefEdit.Create(Application.MainForm);
  try
    with deInfo do begin
      FrmBorderIcons:=[biSystemMenu,biMinimize]; FrmBorderStyle:=bsSizeToolWin;
      NameWnd:=ANameWnd; PnlSortMode:=smColumns; NmProc.Text:=DopKeyStr;
      OnFrmShow:=InfoShow; OnPnlCngKey:=InfoCngKey; OnKpProcKey:=DopKeyProc; Fields.Clear; j:=1;
      InitArr(av);
      av[deNameRec]:=rInfo.NameRec;
      for i:=low(aGet) to high(aGet) do begin
        av[deCaption]:=SpaceCapt(aSay[i]);
        av[deRelation]:='';
        sg:=Trim(aGet[i]);
        lBool:=AnsiStartsStr(UnDelim,sg); lMulti := aSay[i]=UnDelim;
        if lMulti then begin
          av[deRelation]:=rInfo.NameRec+StrNum('.',j); av[deCaption]:=sg;
        end;
        ng:=IfThen(lMulti,3,IfThen(sg='',0,IfThen(lBool,2,1)));
        if ng=0 then av[deVid]:='' else agt[ng].CreateOne.AssignGet(av);
        rInfo.CreateFld(IntToStr(j),ftString,max(1,Length(sg)),IfThen(not lBool,sg));
        av[deNameRecFld]:=IntToStr(j);
        av[deMask]:=IfThen(lBool,Copy(sg,lUnDelim1,MaxInt)+cBoolSay+cBoolLeft);
        av[deWidth]:=IfThen(lMulti,wallDefault);
        CreateFld(av);
        Inc(j);
      end;
      r.pr:=prSetting; r.p:=pSetting; deInfo.Tag:=Longint(@r); IfThenSetting(deInfo.Tag,deiSetting,deInfo);
      Execute(Capt);
    end;
  finally
    deInfo.Free; rInfo.Free;
  end;
  DelStack;
end;

function IfThen(AValue: boolean; ATrue: TDEFldOnPanelList): TDEFldOnPanelOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

function FontStr(i: byte): string;
var f: TGFPackFont;
begin
	AddStack('DefEdit.FontStr');
  f:=TGFPackFont.Create;
  try
  	DefEditGFCur.GetPPFont(ppd,i,f);
    result:=IfThen(TGenForm.IsPPFontDef(ppd,i),' ','*')+' '+SpaceStr0(i,GFLenCod,0)+' '
      +padr(f.Prop.Prim,GFLenName)+' '+FontInf(f.Font)+' '+f.DopInf;
  finally
    f.Free;
  end;
	DelStack;
end;

{ TDefEdit }
constructor TDefEdit.Create;
const NmDef = 'DefEdit';
begin
	AddStack('TDefEdit.Create',Self);
	inherited Create(AOwner);
  FFrmBorderIcons:=[biSystemMenu,biMinimize,biMaximize];
  FFrmBorderStyle:=bsSizeable; FPnlSortMode:=smDefault;
	FFields:=TStringList.Create; TStringList(FFields).OnChange:=FieldsChange;
  FPages:=TStringList.Create; FNmProc:=TKeyLbNmProc.Create;
  {$IFNDEF OSEEK}FldName:=TStringList.Create; FldName.Duplicates:=dupAccept;{$ENDIF}
  ListCreateObj(Self,LsDefEdit);
  DelStack;
end;

destructor TDefEdit.Destroy;
begin
	AddStack('TDefEdit.Destroy',Self);
	FFields.Free; FPages.Free; FNmProc.Free; {$IFNDEF OSEEK}FldName.Free;{$ENDIF}
  ListDestroyObj(Self,LsDefEdit);
  inherited Destroy;
  DelStack;
end;

procedure TDefEdit.SetFields;
begin
	AddStack('TDefEdit.SetFields',Self);
	FFields.Assign(v);
  DelStack;
end;

procedure TDefEdit.FieldsChange;
begin
	AddStack('TDefEdit.FieldsChange',Self);
  DEPageSynchro(FFields,FPages,FDcmBased,FDcmDef);
  DelStack;
end;

procedure TDefEdit.SetNmProc;
begin
	AddStack('TDefEdit.SetNmProc',Self);
	FNmProc.Assign(v);
  DelStack;
end;

procedure TDefEdit.SetPages;
begin
	AddStack('TDefEdit.SetPages',Self);
	FPages.Assign(v);
  DelStack;
end;

{$IFDEF OSEEK}
function TDefEdit.SeekIndex(const vIndex: variant; var Index: longint; lFld: boolean = false): boolean;
var i: longint;
	a: TDEPrmStr;
  nmf: string;
label lend;
begin
	AddStack('TDefEdit.SeekIndex',Self);
	if MyVarType(vIndex)=varString then begin
  	nmf:=TrimUpper(vIndex); i:=0;
	  while i<FFields.Count do begin
	  	LsArrFill(FFields[i],a,UnDelim);
    	if TrimUpper(a[deNameRecFld])=nmf then begin
      	if StrToBoolean(a[deNoVisible]) and lFld then break;
      	Index:=i;
        if lFld then while i>=0 do begin
			  	LsArrFill(FFields[i],a,UnDelim);
          if StrToBoolean(a[deNoVisible]) then Dec(Index);
          Dec(i);
        end;
        goto lend;
      end;
      Inc(i);
    end;
    Index:=FFields.Count;
  end
  else Index:=vIndex;
lend:
	result:=InRange(Index,0,IfThen(lFld,FldCount,FFields.Count)-1);
	DelStack;
end;
{$ELSE}
function TDefEdit.SeekIndex(const vIndex: variant; var Index: longint; lFld: boolean = false): boolean;
var i: longint;
	a: TDEPrmStr;
  nmf: string;
begin
	AddStack('TDefEdit.SeekIndex',Self);
	if MyVarType(vIndex)=varString then begin
    if lFld then begin
      if not IntObjFind(FldName,Trim(vIndex),Index) then Index:=FldCount;
    end
    else begin
      nmf:=TrimUpper(vIndex); i:=0; Index:=FFields.Count;
      while i<Index do begin
        LsArrFill(FFields[i],a,UnDelim);
        if TrimUpper(a[deNameRecFld])=nmf then begin
          Index:=i; break;
        end
        else Inc(i);
      end;
    end;
  end
  else Index:=vIndex;
	result:=InRange(Index,0,IfThen(lFld,FldCount,FFields.Count)-1);
	DelStack;
end;
{$ENDIF}

function TDefEdit.SeekIndex(const vIndex: variant; lFld: boolean = false): longint;
begin
  SeekIndex(vIndex,result,lFld);
end;

function TDefEdit.GetArrParam(Index: longint): TDEPrmStr;
begin
  AddStack('TDefEdit.GetArrParam(i)',Self);
  result:=DEGetArrParam(FFields[Index]);
  DelStack;
end;

function TDefEdit.GetArrParam(const vIndex: variant; var Index: longint; var a: TDEPrmStr): boolean;
begin
  AddStack('TDefEdit.GetArrParam(seek)',Self);
  result:=SeekIndex(vIndex,Index);
  if result then a:=GetArrParam(Index);
  DelStack;
end;

function TDefEdit.GetArrParam(const vIndex: variant; var av: TDEPrmVar): boolean;
var Index: longint;
  a: TDEPrmStr;
begin
  result:=GetArrParam(vIndex,Index,a); CopyFrom(av,a);
end;

procedure TDefEdit.SetArrParam(Index: longint; const ac: TDEPrmStr);
begin
  AddStack('TDefEdit.SetArrParam(i)',Self);
  FFields[Index]:=DESetArrParam(ac);
  DelStack;
end;

procedure TDefEdit.ReplaceNameRec;
begin
  My_pr.ReplaceNameRec(Fields,OldNmRec,NewNmRec.NameRec);
end;

class function TDefEdit.Find(const sWnd: string): TDefEdit;
var i: longint;
	td: TDefEdit;
  nmWnd: string;
begin
	AddStack('TDefEdit.Find');
	result:=nil;
	if Assigned(LsDefEdit) then begin
    nmWnd:=TrimUpper(sWnd);
    with LsDefEdit do for i:=0 to Count-1 do begin
			td:=Items[i];
			if TrimUpper(td.NameWnd)=nmWnd then begin
				result:=td; break;
			end;
		end;
  end;
  DelStack;
end;

class function TDefEdit.Find(const sWnd: string; var de: TDefEdit): boolean;
begin
  de:=Find(sWnd); result:=Assigned(de);
end;

class function TDefEdit.ExecNm;
var de: TDefEdit;
begin
	AddStack('TDefEdit.ExecNm');
  if Find(nmWnd,de) then result:=de.Execute(Capt) else ZeroMemory(@result,SizeOf(result));
  DelStack;
end;

procedure GetLs(Sender: TWinControl; LsGet: TList);
	procedure GetLs1(Sender: TWinControl);
  	procedure GetLs2(tc: TControl);
    var i: longint;
      tf: TFldEdit;
    label lend;
    begin
      AddStack('DefEdit.GetLs.GetLs1.GetLs2');
      if IsClass(tc,TFldEdit,pointer(tf)) then begin
      	LsGet.Add(tf); 
        for i:=0 to tf.ComponentCount-1 do
          if tf.Components[i] is TFldEdit then goto lend;
        GetLs1(tf);
      end
      else if tc is TWinControl then GetLs1(pointer(tc));
  	lend:
      DelStack;
    end;
  var i: longint;
  label lend;
  begin
    AddStack('DefEdit.GetLs.GetLs1');
    if Sender is TRbPage
    then with TRbPage(Sender) do for i:=0 to PageCount-1 do GetLs2(Pages[i])
    else begin
    	if Sender is TTabSheet then
      	if not TTabSheet(Sender).TabVisible then goto lend;
      with Sender do for i:=0 to ControlCount-1 do GetLs2(Controls[i]);
    end;
  lend:
    DelStack;
  end;
begin
  AddStack('DefEdit.GetLs');
  LsGet.Clear; GetLs1(Sender);
  DelStack;
end;

function GFSeek(Sender: TRbPanel; var GF: TGenForm; var sGF: TDEGFScrollBox): boolean;
var k: longint;
begin
  AddStack('DefEdit.GFSeek');
  result:=false; sGF:=nil; GF:=nil;
  for k:=0 to Sender.ControlCount-1 do if IsClass(Sender.Controls[k],TDEGFScrollBox,pointer(sGF)) then begin
    GF:=pointer(sGF.Controls[0]); result:=true; break;
  end;
  DelStack;
end;

function TDefEdit.Execute(const av: array of variant;
  const Capt: TCaption = ''; CanShow: TDECanShow = desAlways; PrPnlUpdateRecDB: TProcValid = nil): TDEExitResult;
const DefWidth=800; DefHeight=600;
var i: longint;
  ows: TWindowState;
  LsGet: TList;
  ode: TDefEdit;
  wp: TWindowPlacement;
  f: TFormDefEdt;
  pn: TRbPanel;
  r: TRect;
  ov: variant;
  oGF: TGenForm;
	sGF: TDEGFScrollBox;
begin
	AddStack('TDefEdit.Execute',Self);
  StdGetState(ov); CopyFromVArr(Params,av); ode:=ActiveDefEdit; ActiveDefEdit:=Self; oGF:=CurDEGF;
	if FormsFree then f:=TFormDefEdt.CreateAll(Application)
  else begin
    Inc(nForm);
    if nForm=Length(aForm) then begin
      SetLength(aForm,nForm+1); aForm[nForm]:=TFormDefEdt.CreateAll(Application);
    end;
    f:=aForm[nForm];
  end;
	LsGet:=TList.Create;
  try
    with f do begin
	    NoLimit:=true; de:=Self; Tag:=Self.Tag; KeyLb1.OnProcKey:=OnKpProcKey;
      //OnResize:=nil;
      OnActivate:=nil; OnDeactivate:=nil; PanelEdit1.OnSetWHMin:=nil;
      if FrmBorderStyle=bsNone then FreeAndNil(KeyMenu1);
      if WindowState=wsNormal then begin
        r:=SysWorkArea;
        SetBounds((r.Right-r.Left-DefWidth) div 2,(r.Bottom-r.Top-DefHeight) div 2,DefWidth,DefHeight);
      end;
      wp:=RestIniForm;
      BorderIcons:=FrmBorderIcons; BorderStyle:=FrmBorderStyle;
      Caption:=IfThen(Capt='',FrmCaption,Capt);
      //for i:=0 to FNmProc.Count-1 do KeyLb1.SetKeySt(FNmProc[i],FOnKpProcKey,DEKeyDopName);
      with RbPanel1 do begin
      	WMin:=0; HMin:=0;
        with PanelEdit1 do begin
        	Header:=IfThen(Capt<>'',FrmCaption);
          if PnlAskByCancel then Options:=[peAskByCancel] else Options:=[];
          OnAskCancel:=OnPnlAskCancel; OnEscape:=OnPnlEscape; OnAfterEscape:=OnPnlAfterEscape;
          OnCngKey:=OnPnlCngKey; OnSetWHMin:=OnPnlSetWHMin;
          OnUpdateRec:=OnPnlUpdateRec; OnValid:=OnPnlValid;
          OnUpdateRecDB:=PrPnlUpdateRecDB;

{GetLs(PanelEdit1,LsSay,LsGet);
for i:=0 to LsGet.Count-1 do with TFldEdit(LsGet[i]) do
	if Active then meserr(NameRecFld);}

          FFldOnPanel(PanelEdit1); pn:=MainRbPanel;
          if Assigned(pn) then begin
            pn.OnSetWHMin:=OnPnlSetWHMin; OnSetWHMin:=nil; GFSeek(pn,CurDEGF,sGF);
          end;
        end;
      end;
      SetSchemForm; 
      {if (wp.showCmd=SW_HIDE) and (WindowState<>wsNormal) then begin
      	WindowState:=wsNormal;
      	//with wp.rcNormalPosition do SetBounds(Left,Top,Right-Left,Bottom-Top);
      end;}
      ows:=WindowState; MainRebuild; WindowState:=ows;
      ActiveControl:=PanelEdit1; OnResize:=FormResize;
      OnActivate:=Self.FormActivate; PanelEdit1.AfterSetActivate;
      OnDeactivate:=Self.FormDeactivate;
      Self.FormShow(f); PanelEdit1.HelpContext:=FHelpContext;
      result.Saved:=false;
      case CanShow of
        desAlways: result.WasShow:=true;
        desVisible: result.WasShow := PanelEdit1.FieldCount<>0;
        desNoReadOnly: begin
          result.WasShow:=false;
          for i:=0 to PanelEdit1.FieldCount-1 do
            if not(ogReadOnly in PanelEdit1.Fields[i].Options) then begin
              result.WasShow:=true; break;
            end;
        end;
        desNever: result.WasShow:=false;
      end;
      PanelEdit1.FillKeyLb; SetDopKey;
      if result.WasShow then result.Saved := ShowModal=mrOk else Self.FormShow(f);
      Self.FormHide(f); GetLs(PanelEdit1,LsGet);
      for i:=0 to LsGet.Count-1 do with TFldEdit(LsGet[i]) do begin
        OnAfterExit:=nil; OnCheck:=nil; OnChange:=nil; OnEnter:=nil; OnExit:=nil;
      end;
      KeyLb1.DelKey(K_All,DEKeyDopName); SaveIniForm;
      NoLimit:=false;
    end;
  finally
    LsGet.Free;
		if FormsFree then begin
			f.Free; FldCount:=0; {$IFNDEF OSEEK}FldName.Clear;{$ENDIF} 
    end;
    ActiveDefEdit:=ode; CurDEGF:=oGF;
  end;
  if not FormsFree then Dec(nForm);
  StdGetState(ov,[stdgAfter]); Panel:=nil;
  DelStack;
end;

function TDefEdit.Execute(const Capt: TCaption = ''; CanShow: TDECanShow = desAlways; PrPnlUpdateRecDB: TProcValid = nil): TDEExitResult;
begin
  result:=Execute([0],Capt,CanShow,PrPnlUpdateRecDB);
end;

function TDefEdit.Execute(usl: boolean; const Capt: TCaption = ''; CanShow: TDECanShow = desAlways; PrPnlUpdateRecDB: TProcValid = nil): boolean;
begin
  if usl then result:=Execute(Capt,CanShow,PrPnlUpdateRecDB).Saved else result:=true;
end;

class procedure TDefEdit.RenameSection;
begin
  AddStack('TDefEdit.RenameSection');
  InitFIni[fiSave].RenameSection(oldSect,newSect);
  InitFIni[fiSave].RenameSection(SectBeg+oldSect,SectBeg+newSect);
  InitFIni[fiPPDoc].RenameSection(SectBeg+oldSect,SectBeg+newSect);
  DelStack;
end;

class procedure TDefEdit.EraseSection;
begin
  AddStack('TDefEdit.EraseSection');
  InitFIni[fiSave].EraseSection(Section);
  InitFIni[fiSave].EraseSection(SectBeg+Section);
  InitFIni[fiPPDoc].EraseSection(SectBeg+Section);
  DelStack;
end;

procedure TDefEdit.FldOnPanel;
var f: TCustomForm;
  pe: TPanelEdit;
  fl: boolean;
  tf: TFldEdit;
begin
	AddStack('TDefEdit.FldOnPanel',Self);
  f:=GetParentForm(Sender); fl:=TPanelEdit.ParentPnEd(Sender,pe);
  if fl then begin
    pe.FillFldList;
    if pe.FldActive(tf) then tf.CurGetExit;
    pe.ClearFldList;
    fl:=not Assigned(pe.MasterControl);
  end;
  if fl then f.ActiveControl:=nil;
  FFldOnPanel(Sender,Opt);
  if Assigned(pe) then pe.FillFldList;
  if fl then f.ActiveControl:=pe;
  SetSchemForm(f); MainRebuild;
  DelStack;
end;

procedure TDefEdit.FFldOnPanel;
var GF: TGenForm;
	sGF: TDEGFScrollBox;
  tf: TFldEdit;
  LsGet: TList;
  lsRel: TStringList;
  aRel: array of record
  	Main,lSubject: longint;
    aSubject: TArrInt;
	end;
var i,n1: longint;
	procedure Pnl1(Sender: TRbPanel; n2: longint; DcmBased: boolean; const DcmDef: string);
  var a: TDEPrmStr;
    function GetOpt: TGetOptions;
    begin
      AddStack('TDefEdit.FFldOnPanel.Pnl1.GetOpt',Self);
      result:=[ogAutoSize]
        +IfThen(StrToBoolean(a[deAutoSel]),ogAutoSelect)
        +IfThen(StrToBoolean(a[dePassword]),ogPassword)
        +IfThen(not StrToBoolean(a[deNoReadOnly]),ogReadOnly)
        +IfThen(StrToBoolean(a[deReadOnlyNoVsbl]),ogReadOnlyNoVsbl)
        +IfThen(StrToBoolean(a[deTrimLeft]),ogTrimLeft);
      DelStack;
    end;
    function EqualParam: boolean;
    var s: string;
    label lend;
    begin
      AddStack('TDefEdit.FFldOnPanel.Pnl1.EqualParam',Self);
      result:=false;
      if depnBound in Opt then goto lend;
      with tf do begin
        if SayCaption<>a[deCaption] then goto lend;
        if Assigned(PaintSay) then with PaintSay do begin
        	s:=Hint;
	        if ShowHint<>not empty(Hint) then goto lend;
        end
        else s:='';
        if s<>a[deSayHint] then goto lend;
        if NameRec<>a[deNameRec] then goto lend;
        if NameRecFld<>a[deNameRecFld] then goto lend;
        if Mask<>a[deMask] then goto lend;
        if MaxLength<>Int0(a[deMaxLen]) then goto lend;
        if CharCase<>aDeToEdit[DEArr2CharCase(a)] then goto lend;
        if Options<>GetOpt then goto lend;
        if CharWidth<>Int0(a[deWidth]) then goto lend;
        if CharHeight<>Int0(a[deHeight]) then goto lend;
        if Tag<>IfThen(StrToBoolean(a[deTag]),1) then goto lend;
        if Hint<>a[deGetHint] then goto lend;
        if Vid<>a[deVid] then goto lend;
        if VName<>a[deVName] then goto lend;
        if SayRight<>StrToBoolean(a[deSayRight]) then goto lend;
      end;
      result:=true;
    lend:
      DelStack;
    end;
  var j,k: longint;
	  r,r1: TCustomRec;
	  v,v1: variant;
	  nmf1,nmrd: string;
  	fl: boolean;
    ls: TGFFldSayList;
	begin
    AddStack('TDefEdit.FFldOnPanel.Pnl1',Self);
		Sender.WMin:=0; Sender.HMin:=0; Sender.SortObj:=not DcmBased; ls:=nil;
    try
      fl:=GFSeek(Sender,GF,sGF);
      if DcmBased then begin
        if not fl then begin
          sGF:=TDEGFScrollBox.Create(Sender.Owner); sGF.Parent:=Sender; sGF.BorderStyle:=bsNone;
          GF:=TGenForm.Create(Sender.Owner); GF.Parent:=sGF; GF.InGet:=true;
          GF.EdlsBitMap:=TGFBitMapList.Create; GF.OnEnter:=GFEnter; GF.OnExit:=GFExit;
        end;
        ls:=TGFFldSayList.Create(GF); GF.stFontSay:=[];
      end
      else if fl then sGF.Free;
      j:=FldCount+n2-n1+1;
      if Length(aFldEdit)<j then SetLength(aFldEdit,j);
      while (n1<=n2) and (i<FFields.Count) do begin
        a:=GetArrParam(i); Inc(i);
        if Assigned(PrDefEditRdbCng) then PrDefEditRdbCng(a);
        if DcmBased then a[deRelation]:='';
        if StrToBoolean(a[deNoVisible]) then continue;
        if n1<LsGet.Count then begin
          tf:=pointer(LsGet[n1]); tf.TabOrder:=n1; tf.FocusControl:=nil;
        end
        else begin
          tf:=TFldEdit.Create(Sender.Owner); tf.Parent:=Sender;
        end;
        if DcmBased then begin
        	tf.Parent:=GF;
          if Assigned(tf.PaintSay) then begin
          	nmf1:=tf.SayCaption; tf.SayCaption:=''; tf.SayCaption:=nmf1;
          end;
        end;
        tf.IncOptions([ogAutoSize]);
        with tf do begin
          if RecName(a[deNameRec],r) then v:=r[a[deNameRecFld]];
          nmf1:=NameRecFld;
          if RecName(NameRec,r1) then v1:=r1[nmf1];
        end;
        nmrd:=a[deNameRec];
        if r is TRecDBDef then with TRecDBDef(r) do
          if DynamicVid>0 then for j:=0 to FldDef.Count-1 do with DWStoRec(j) do
            if TrimUpper(Name)=TrimUpper(a[deNameRecFld]) then begin
              if SvType=dwsDyn then a[deNameRec]:=DynNmDB(DynamicVid);
              break;
            end;
        if not EqualParam then with tf do begin
          SayCaption:=a[deCaption];
          if Assigned(PaintSay) then with PaintSay do begin
            Hint:=a[deSayHint]; ShowHint := not empty(Hint);
          end;
          fl:=Visible; Visible:=true; AssignGet; Visible:=fl;
          NameRecDynRdb:=nmrd; NameRec:=a[deNameRec]; NameRecFld:=a[deNameRecFld]; Mask:=a[deMask];
          MaxLength:=Int0(a[deMaxLen]);
          CharCase:=aDeToEdit[DEArr2CharCase(a)];
          Options:=GetOpt; CharWidth:=Int0(a[deWidth]); CharHeight:=Int0(a[deHeight]);
          j:=Int0(a[deTag]); Tag:=IfThen(j>0,j,IfThen(StrToBoolean(a[deTag]),1));
          Hint:=a[deGetHint]; SayRight:=StrToBoolean(a[deSayRight]);
        end;
        //with ts do Visible := not(DcmBased or empty(Caption));
        with tf do begin
        	ls.AddFld(tf);
          if empty(a[deRelation]) then begin
            if IntObjFind(lsRel,TrimUpper(NameRec+'.'+NameRecFld),k) then aRel[k].Main:=n1;
          end
          else begin
            TrimUpperSelf(a[deRelation]);
            if not IntObjFindAdd(lsRel,a[deRelation],k) then begin
              if Length(aRel)=k then SetLength(aRel,k shl 1);
              with aRel[k] do begin
                Main:=NegDef; SetLength(aSubject,10); lSubject:=0;
                for j:=0 to FldCount-1 do with aFldEdit[j] do if TrimUpper(NameRec+'.'+NameRecFld)=a[deRelation] then begin
                  Main:=j; break;
                end;
              end;
            end;
            with aRel[k] do AddFrom(aSubject,lSubject,n1);
          end;
          Relation:=tf.DefRelation; HelpContext:=0; ParentSchem:=true;
          OnAfterExit:=OnFldAfterExit; OnCheck:=OnFldCheck;
          OnEnter:=OnFldEnter; OnExit:=OnFldExit;
          Visible:=true;
          AssignGet(a[deVid],a[deVName]);
          tf.CurGetExit;
          if Assigned(r) then tf.VarValue:=v;
          OnChange:=OnFldChange; // только после AssignGet !!!
          if Assigned(r1) then r1[nmf1]:=v1;
          Active:=false;
        end;
        aFldEdit[FldCount]:=tf;
{$IFNDEF OSEEK}
        FldName.AddObject(tf.NameRecFld,pointer(FldCount)); Inc(n1);
{$ENDIF}
        Inc(FldCount); Inc(n1);
      end;
      if DcmBased then begin
      	GF.State:=gsDesign; GF.OpenDcmStr(DcmDef); GF.EdPartIni:=SectBeg+FNameWnd;
        GF.EdPpdPrm.Params:=GFCopyParams(GF.Params); GF.EdPpdPrm.Fonts:='';
        for k:=0 to GF.FontCount-1 do TGenForm.PutPPFont(GF.EdPpdPrm,k,GF.Fonts[k]);
        GF.EdlsBitMap.LoadFromDB(GF.lsBitMap,'');
        GF.State:=gsView; GF.MouseInit(GF);
      end;
    finally
    	ls.Free;
    end;
    DelStack;
  end;
  function pnPg(tsh: TTabSheet): TRbPanel;
  begin
    AddStack('TDefEdit.FFldOnPanel.pnPg',Self);
    result:=pointer(TRbScrollBox(TRbPanel(tsh.Controls[0]).Controls[0]).Controls[0]);
    DelStack;
  end;
var scrl: TRbScrollBox;
  pn: TRbPanel;
  procedure scrlCrt(pnsc: TRbPanel; bv: TBevelCut);
  begin
    AddStack('TDefEdit.FFldOnPanel.scrlCrt',Self);
    scrl:=TRbScrollBox.Create(Sender.Owner);
    with scrl do begin
      Parent:=pnsc; BorderStyle:=bsNone; Options:=Options+[rsoNoKeys];
      pn:=TRbPanel.Create(Sender.Owner);
      with pn do begin
        Parent:=scrl; ProcentWnd:=100; BevelOuter:=bv;
      end;
    end;
    DelStack;
  end;
var k: longint;
  apg: TArrInt;
  pg: TRbPage;
  tsh: TTabSheet;
  pnsc: TRbPanel;
  lPg: boolean;
  a1: array[1..5] of string;
  a: TDEPrmStr;
begin
	AddStack('TDefEdit.FFldOnPanel',Self);
  with Sender do begin
    Panel:=Sender;
    if ControlCount=0 then lPg:=false else lPg:=IsClass(Controls[0],TRbPage,pointer(pg));
		scrl:=nil;
    if not lPg then begin
      if FPages.Count>0 then begin
        GFSeek(Sender,GF,sGF); sGF.Free;
      end;
      scrl:=ControlsClass(Sender,TRbScrollBox);
      if FPages.Count>0 then begin
        FreeAndNil(scrl); pg:=TRbPage.Create(Owner); pg.Parent:=Sender;
      end;
    end;
    if FPages.Count=0 then begin
      if Assigned(scrl) then pn:=pointer(scrl.Controls[0]) else scrlCrt(Sender,bvNone);
      if depnNoScroll in Opt then begin
        FreeAndNil(scrl); pn:=Sender;
      end;
      pn.SortMode:=PnlSortMode;
    end
    else begin
      SortMode:=smDefault; SetLength(apg,FPages.Count); k:=0; n1:=-1;
      for i:=0 to FFields.Count-1 do begin
      	a:=GetArrParam(i);
        if not StrToBoolean(a[deNoVisible]) then begin
          if StrToBoolean(a[deNewPage]) and (i>0) then begin
            apg[k]:=n1; Inc(k);
          end;
          Inc(n1);
        end;
      end;
      apg[k]:=n1;
      for i:=0 to FPages.Count-1 do begin
      	if pg.PageCount>i then begin
          tsh:=pg.Pages[i]; pn:=pnPg(tsh);
        end
        else begin
          tsh:=TTabSheet.Create(Owner); tsh.PageControl:=pg;
          pnsc:=TRbPanel.Create(Owner);
          with pnsc do begin
	          Parent:=tsh; ProcentWnd:=100; BevelOuter:=bvNone; scrlCrt(pnsc,bvLowered);
          end;
        end;
        LsArrFill(FPages[i],a1,UnDelim); tsh.Caption:=Trim(a1[1]);
        pn.SortMode:=DEPgSortMode(a1[2]); pg.SetTabVisible(tsh,not StrToBoolean(a1[4]));
      end;
      for i:=FPages.Count to pg.PageCount-1 do pg.SetTabVisible(pg.Pages[i],false);
    end;
  end;
  lsRel:=SortStrListCreate; LsGet:=TList.Create;
  try
{$IFDEF OSEEK}
    FldCount:=0; GetLs(Sender,LsGet);
{$ELSE}
    FldCount:=0; FldName.Sorted:=false; FldName.Clear; FldName.Capacity:=FFields.Count; GetLs(Sender,LsGet);
{$ENDIF}
    if FPages.Count>0 then pn:=pnPg(pg.Pages[0]);
    SetLength(aRel,10); k:=0;
    for i:=0 to LsGet.Count-1 do begin
      tf:=pointer(LsGet[i]);
      if tf.Parent<>pn then begin
        tf.Parent:=pn; tf.Relation:=frNormal;
      end;
      tf.Hide;
    	if FPages.Count>0 then
      	if i=apg[k] then begin
        	Inc(k);
          if k<FPages.Count then pn:=pnPg(pg.Pages[k]);
      	end;
    end;
    n1:=0;
    {for i:=0 to FFields.Count-1 do
      if StrToBoolean(GetArrParam(i)[deNoVisible]) then Inc(n1) else break;}
    i:=0;
    if FPages.Count=0 then begin
    	pg.Free; Pnl1(pn,FFields.Count-1,FDcmBased,FDcmDef);
    end
    else for k:=low(apg) to high(apg) do begin
      LsArrFill(FPages[k],a1,UnDelim);
      if Int0(a1[5])>=1 then StrDeShifrSelf(a1[3]);
      Pnl1(pnPg(pg.Pages[k]),apg[k],a1[2]='0',a1[3]);
    end;
    {$IFNDEF OSEEK}FldName.Sorted:=true;{$ENDIF}
  finally
  	for i:=0 to lsRel.Count-1 do with aRel[IntObj(lsRel,i)] do if Main<>NegDef then begin
      tf:=aFldEdit[Main]; tf.Relation:=frMain;
      for k:=0 to lSubject-1 do aFldEdit[aSubject[k]].Parent:=tf;
    end;
    lsRel.Free; LsGet.Free;
  end;
  DelStack;
end;

class procedure TDefEdit.GFEnter;
var tl: TKeyLb;
begin
	AddStack('TDefEdit.GFEnter');
  if FormKeyLb(TControl(Sender),tl) then begin
  	tl.SetKey(K_F4,'Параметры','Редактирование параметров формы',GFProcKey,'EdGF',kmEdit);
    tl.Redrw;
  end;
  DelStack;
end;

class procedure TDefEdit.GFExit;
var tl: TKeyLb;
begin
	AddStack('TDefEdit.GFExit');
  if FormKeyLb(TControl(  Sender),tl) then begin
  	tl.DelKey(K_All,'EdGF'); tl.Redrw;
  end;
  DelStack;
end;

function GFPrmDef: TGFParams;
begin
	AddStack('DefEdit.GFPrmDef');
  result:=DefEditGFCur.EdPpdPrm.Params;
  DelStack;
end;

class procedure TDefEdit.GFProcKey;
var i: byte;
	lsbm: TGFBitMapList;
  oDefEditGFCur: TGenForm;
begin
  AddStack('TDefEdit.GFProcKey');
  if ParentClass(tw,TGenForm) then begin
    oDefEditGFCur:=DefEditGFCur; lsbm:=TGFBitMapList.Create;
    try
      DefEditGFCur:=pointer(tw); TGenForm.GetPPDcm('',DefEditGFCur.EdPartIni,ppd,DefEditGFCur);
      GFLenCod:=LenIntStr(DefEditGFCur.FontCount-1); GFLenName:=0;
      for i:=0 to DefEditGFCur.FontCount-1 do
        MaxSelf(GFLenName,TrimRight(DefEditGFCur.Fonts[i].Prop.Prim));
      lsbm.LoadFromDB(DefEditGFCur.EdlsBitMap,DefEditGFCur.EdPartIni);
      if GFPrmExec(ppd,GFPrmDef,true,lsbm,DefEditGFCur.EdlsBitMap,DefEditGFCur.EdPartIni,GFFontProc) then begin
        TGenForm.PutPPDcm(DefEditGFCur.EdPartIni,ppd); DefEditGFCur.InGetRebuild;
      end;
    finally
      lsbm.Free; DefEditGFCur:=oDefEditGFCur;
    end;
  end;
  DelStack;
end;

class procedure TDefEdit.GFFontProc;
var i: byte;
begin
	AddStack('TDefEdit.GFFontProc');
  if not lAfter then begin
    for i:=0 to DefEditGFCur.FontCount-1 do IncD(StrList,FontStr(i)+CRLF);
    DecLen(StrList,lCRLF);
    with TKeyLb do KeyStr:=ArrayAsList(
      [GetKeySt(K_Esc,'Выход')
      ,GetKeySt(K_F5,'Редактировать')
      ,GetKeySt(K_Enter,K_F5)
      ,GetKeySt(K_Alt_Home,'По умолчанию')],CRLF);
    ProcKey:=GFFontKeyProc;
  end;
  DelStack;
end;

class procedure TDefEdit.GFFontKeyProc;
var ls: TFindListBox;
	i,j: longint;
  f: TGFPackFont;
  fl: boolean;
begin
	AddStack('TDefEdit.GFFontKeyProc');
	ls:=pointer(tw); ls.GetIndexFiltered(i,j); fl:=false;
  case Key of
	  // Редактирование шрифта
    K_F5,K_Enter: begin
      f:=TGFPackFont.Create;
      try
        DefEditGFCur.GetPPFont(ppd,j,f); fl:=GFEdFontProc(f);
        if fl then TGenForm.PutPPFont(ppd,j,f);
      finally
        f.Free;
      end;
    end;
  	// Выход
    K_Esc: GetParentForm(ls).ModalResult:=mrCancel;
	  // Шрифт по умолчанию
    K_Alt_Home: begin
      TGenForm.PutPPFontDef(ppd,j); fl:=true;
    end;
  end;
  if fl then begin
    ls.ItemSet(i,FontStr(j)); ls.ItemIndex:=i;
  end;
	DelStack;
end;

procedure TDefEdit.FormShow;
var f: TFormEdt;
begin
	AddStack('TDefEdit.FormShow',Self);
  f:=pointer(Sender); f.PanelEdit1.FillFldList;
  if Assigned(FOnFrmShow) then begin
    FOnFrmShow(Sender); f.PanelEdit1.FillFldList;
  end;
	f.FormShow(Sender);
  DelStack;
end;

procedure TDefEdit.FormHide;
begin
	AddStack('TDefEdit.FormHide',Self);
	IfThenNotify(FOnFrmHide,Sender);
  DelStack;
end;

procedure TDefEdit.FormSchem;
begin
  AddStack('TDefEdit.FormSchem',Self);
  if Assigned(FOnSchem) then FOnSchem(Sender,Message);
  DelStack;
end;

procedure TDefEdit.FormActivate;
begin
	AddStack('TDefEdit.FormActivate',Self);
  TFormDefEdt(Sender).FormActivate(Sender); IfThenNotify(FOnFrmActivate,Sender);
  DelStack;
end;

procedure TDefEdit.FormDeActivate;
begin
	AddStack('TDefEdit.FormDeActivate',Self);
	IfThenNotify(FOnFrmDeActivate,Sender);
  DelStack;
end;

// Создать поле с параметрами aPrm
function TDefEdit.CreateFld;
var s: string;
begin
	AddStack('TDefEdit.CreateFld',Self);
  s:=DEVArrToArrParam(aPrm);
  if SeekIndex(nmfBefore,result) then FFields.Insert(result,s) else result:=FFields.Add(s);
  DelStack;
end;

procedure TDefEdit.AssignGet(const vIndex: variant; g: TCustomGet);
var Index: longint;
  a: TDEPrmStr;
begin
  AddStack('TDefEdit.AssignGet',Self);
	if GetArrParam(vIndex,Index,a) then begin
  	a[deVid]:=g.ClassName; a[deVName]:=g.VName; SetArrParam(Index,a);
  end;
  DelStack;
end;

procedure TDefEdit.AssignGet(const vIndex: variant; g: TCustomGetClass; const VName: string = '');
var Index: longint;
  a: TDEPrmStr;
begin
  AddStack('TDefEdit.AssignGet(c)',Self);
	if GetArrParam(vIndex,Index,a) then begin
    if Assigned(g) then a[deVid]:=g.ClassName else a[deVid]:='';
    a[deVName]:=VName; SetArrParam(Index,a);
  end;
  DelStack;
end;

procedure TDefEdit.DestroyFld;
var Index: longint;
begin
  AddStack('TDefEdit.DestroyFld',Self);
  if SeekIndex(vIndex,Index) then FFields.Delete(Index);
  DelStack;
end;

procedure TDefEdit.DestroyFlds;
var i: longint;
begin
  AddStack('TDefEdit.DestroyFlds',Self);
  for i:=low(aIndex) to high(aIndex) do DestroyFld(aIndex[i]);
  DelStack;
end;

{function TDefEdit.Getcurget;
begin
	AddStack('TDefEdit.Getcurget',Self);
  result:=FldEdit[vIndex].curget;
  DelStack;
end;}

function TDefEdit.GetFldEdit;
var Index: longint;
begin
	AddStack('TDefEdit.GetFldEdit',Self);
  if SeekIndex(vIndex,Index,true) then result:=aFldEdit[Index] else result:=nil;
  DelStack;
end;

function TDefEdit.GetFldSayCaption;
begin
	AddStack('TDefEdit.GetFldSayCaption',Self);
  result:=FldEdit[vIndex].SayCaption;
  DelStack;
end;

procedure TDefEdit.SetFldSayCaption;
begin
	AddStack('TDefEdit.SetFldSayCaption',Self);
  FldEdit[vIndex].SayCaption:=v;
  DelStack;
end;

function TDefEdit.GetFldValue;
begin
	AddStack('TDefEdit.GetFldValue',Self);
  result:=FldEdit[vIndex].VarValue;
  DelStack;
end;

procedure TDefEdit.SetFldValue;
var tf: TFldEdit;
begin
	AddStack('TDefEdit.SetFldValue',Self);
  if IsFldEdit(vIndex,tf) then tf.VarValue:=v;
  DelStack;
end;

function TDefEdit.GetFldHelpContext;
begin
	AddStack('TDefEdit.GetFldHelpContext',Self);
  result:=FldEdit[vIndex].HelpContext;
  DelStack;
end;

procedure TDefEdit.SetFldHelpContext;
begin
	AddStack('TDefEdit.SetFldHelpContext',Self);
  FldEdit[vIndex].HelpContext:=v;
  DelStack;
end;

function TDefEdit.GetMask;
begin
	AddStack('TDefEdit.GetMask',Self);
  result:=FldEdit[vIndex].Mask;
  DelStack;
end;

procedure TDefEdit.SetMask;
begin
	AddStack('TDefEdit.SetMask',Self);
  FldEdit[vIndex].Mask:=v;
  DelStack;
end;

{function TDefEdit.GetNameRecFld;
begin
	AddStack('TDefEdit.GetNameRecFld',Self);
  result:=FldEdit[vIndex].NameRecFld;
  DelStack;
end;

procedure TDefEdit.SetNameRecFld;
begin
	AddStack('TDefEdit.SetNameRecFld',Self);
  FldEdit[vIndex].NameRecFld:=v;
  DelStack;
end;}

function TDefEdit.GetOldValue;
begin
	AddStack('TDefEdit.GetFldValue',Self);
  result:=FldEdit[vIndex].OldValue;
  DelStack;
end;

function TDefEdit.GetOptions;
begin
	AddStack('TDefEdit.GetOptions',Self);
  result:=FldEdit[vIndex].Options;
  DelStack;
end;

procedure TDefEdit.SetOptions;
begin
	AddStack('TDefEdit.SetOptions',Self);
  FldEdit[vIndex].Options:=v;
  DelStack;
end;

function TDefEdit.GetParam;
var Index: longint;
  a: TDEPrmStr;
begin
	AddStack('TDefEdit.GetParam',Self);
	if GetArrParam(vIndex,Index,a) then result:=a[nPrm] else result:='';
  DelStack;
end;

procedure TDefEdit.SetParam;
var Index: longint;
  a: TDEPrmStr;
begin
	AddStack('TDefEdit.SetParam',Self);
	if GetArrParam(vIndex,Index,a) then begin
  	a[nPrm]:=Value; SetArrParam(Index,a);
  end;
  DelStack;
end;

procedure TDefEdit.SetParams;
var i: longint;
begin
  for i:=low(vIndex) to high(vIndex) do SetParam(vIndex[i],nPrm,Value);
end;

procedure TDefEdit.SetVisibles;
var i: longint;
begin
  AddStack('TDefEdit.SetVisibles',Self);
  for i:=low(vIndex) to high(vIndex) do Visible[vIndex[i]]:=Value;
  DelStack;
end;

function TDefEdit.GetParent;
begin
	AddStack('TDefEdit.GetParent',Self);
  result:=FldEdit[vIndex].Parent;
  DelStack;
end;

function TDefEdit.GetPNameRec;
begin
	AddStack('TDefEdit.GetPNameRec',Self);
  result:=FldEdit[vIndex].PNameRec;
  DelStack;
end;

function TDefEdit.GetVisible;
begin
	AddStack('TDefEdit.GetVisible',Self);
  result:=VisibleNoNil(FldEdit[vIndex]);
  DelStack;
end;

procedure TDefEdit.SetVisible;
var tf: TFldEdit;
begin
	AddStack('TDefEdit.SetVisible',Self);
  if IsFldEdit(vIndex,tf) then tf.Visible:=v;
  DelStack;
end;

function TDefEdit.PanelEdit: TPanelEdit;
begin
  PanelEdit(result);
end;

function TDefEdit.PanelEdit(var pe: TPanelEdit): boolean;
begin
  AddStack('TDefEdit.PanelEdit',Self);
  result:=TPanelEdit.ParentPnEd(Panel,pe,false);
  DelStack;
end;

procedure TDefEdit.FillFldList;
begin
  PanelEdit.FillFldList;
end;

procedure TDefEdit.MainRebuild;
begin
  AddStack('TDefEdit.MainRebuild',Self);
  if Assigned(Panel) then FPanel.MainRebuild(Panel,lSetRdw);
  DelStack;
end;

function TDefEdit.IsFldEdit(const nmf: variant; var tf: TFldEdit; lPnEd: boolean = false): boolean;
var pe: TPanelEdit;
begin
  AddStack('TDefEdit.IsFldEdit',Self);
  if lPnEd then
    if PanelEdit(pe) then tf:=pe.Fields[nmf] else tf:=nil
  else tf:=FldEdit[nmf];
  result:=Assigned(tf);
  DelStack;
end;

function TDefEdit.IsFldEdit(const nmf: variant; lPnEd: boolean = false): boolean;
var tf: TFldEdit;
begin
  result:=IsFldEdit(nmf,tf,lPnEd);
end;

procedure TDefEdit.FldEditDef;
begin
  AddStack('TDefEdit.FldEditDef',Self);
  if not Assigned(Sender) then Sender:=FldEdit[nmf];
  DelStack;
end;

procedure TDefEdit.Change;
begin
  AddStack('TDefEdit.Change',Self);
  FldEdit[nmf].Change(oldv,FromShow);
  DelStack;
end;

procedure TDefEdit.Read(const anmf: array of variant; Opt: TFEReadOpt = []);
var i: longint;
begin
  for i:=low(anmf) to high(anmf) do Read(anmf[i],Opt);
end;

procedure TDefEdit.Read(const nmf: variant; Opt: TFEReadOpt = []);
begin
  AddStack('TDefEdit.Read',Self);
  FldEdit[nmf].Read(Opt);
  DelStack;
end;

procedure TDefEdit.SetFocus;
begin
  AddStack('TDefEdit.SetFocus',Self);
  FldEdit[nmf].SetFocus;
  DelStack;
end;

procedure TDefEdit.SetReadOnly(const anmf: array of variant; Value: boolean; opt: TGetOptions = [ogReadOnly]);
var i: longint;
begin
  AddStack('TDefEdit.SetReadOnly',Self);
  for i:=low(anmf) to high(anmf) do SetReadOnly(anmf[i],Value,Opt);
  DelStack;
end;

function TDefEdit.SetReadOnly(const nmf: variant; Value: boolean; opt: TGetOptions = [ogReadOnly]): boolean;
begin
  result:=FldEdit[nmf].SetReadOnly(Value,opt);
end;

function TDefEdit.SetReadOnly(const nmf: variant; Value: boolean; opt: TGetOption): boolean;
begin
  result:=SetReadOnly(nmf,Value,[opt]);
end;

procedure TDefEdit.SetReadOnly(const anmf: array of variant; ro: boolean; const Value: variant);
var i: longint;
begin
  AddStack('TDefEdit.SetReadOnly(Value)',Self);
  for i:=low(anmf) to high(anmf) do SetReadOnly(anmf[i],ro,Value);
  DelStack;
end;

function TDefEdit.SetReadOnly(const nmf: variant; ro: boolean; const Value: variant; opt: TGetOptions = [ogReadOnly]): boolean;
begin
  result:=FldEdit[nmf].SetReadOnly(ro,Value,opt);
end;

procedure TDefEdit.SetReadOnly(Value: boolean; opt: TGetOptions = [ogReadOnly]);
begin
  PanelEdit.SetReadOnly(Value,opt);
end;

function TDefEdit.FldValueDef;
var tf: TFldEdit;
begin
  AddStack('TDefEdit.FldValueDef',Self);
  if IsFldEdit(nmf,tf) then result:=tf.VarValue else result:=Def;
  DelStack;
end;

function TDefEdit.EditValueDef;
var tf: TFldEdit;
begin
  AddStack('TDefEdit.EditValueDef',Self);
  if IsFldEdit(nmf,tf) then result:=tf.Value else result:=Def;
  DelStack;
end;

function TDefEdit.PrFldList;
var mr: TListF2Result;
	i,npg: longint;
  ap: TDEPrmStr;
  s: string;
begin
	AddStack('TDefEdit.PrFldList',Self);
  if Fields.Count=0 then result:=false
  else begin
  	npg:=0; TrimUpperSelf(txt); mr:=TListF2Result.Create;
    try
    	for i:=0 to Fields.Count-1 do begin
	    	ap:=GetArrParam(i);
        if (i<>0) and StrToBoolean(ap[deNewPage]) then Inc(npg);
        if (DWPageNumEdit<0) or (npg=DWPageNumEdit) then begin
          s:=ap[deNameRec]+'.'+ap[deNameRecFld]; mr.Add(s);
          if TrimUpper(s)=txt then mr.SelectStr:=mr.Count-1;
        end;
      end;
      result:=ListF2Down(mr.Text,mr,Sender,MinWidth,'Browl','',nil,0,nil,nil,nil,nil,nil,Capt);
     	if result then txt:=mr[mr.SelectStr];
    finally
    	mr.Free;
    end;
  end;
  DelStack;
end;

function TDefEdit.PrEdSay;
var s: string;
	i: longint;
  ap: TDEPrmStr;
begin
  AddStack('TDefEdit.PrEdSay',Self);
  result:=PString(Sender)^;
  if FFields.Count>0 then begin
  	s:=TrimUpper(result);
    for i:=0 to FFields.Count-1 do begin
    	ap:=GetArrParam(i);
      if TrimUpper(ap[deNameRec]+'.'+ap[deNameRecFld])=s then begin
        if not empty(ap[deCaption]) then result:=StrTran(ap[deCaption],UnDelim,CRLF);
        break;
      end;
    end;
  end;
  DelStack;
end;

procedure TDefEdit.SetDopKey;
var i: longint;
  tl: TKeyLb;
begin
  AddStack('TDefEdit.SetDopKey',Self);
  tl:=TFormDefEdt(GetParentForm(Panel)).KeyLb1;
  for i:=0 to FNmProc.Count-1 do tl.SetKeySt(FNmProc[i],FOnKpProcKey,DEKeyDopName);
  tl.Redrw;
  DelStack;
end;

{procedure TDefEdit.FOnFldAfterExitGF;
var i: longint;
begin
  AddStack('TDefEdit.FOnFldAfterExitGF',Self);
  with TFldEdit(Sender) do
	  if Parent is TGenForm then with Parent do
      for i:=0 to ControlCount-1 do
        if Controls[i] is TFldEdit then Controls[i].Invalidate;
  IfThenNotify(FOnFldAfterExit,Sender);
  DelStack;
end;}

class procedure TDefEdit.InfoShow;
var w,w1,h,i: longint;
  f: TFormDefEdt;
  tf: TFldEdit;
begin
  AddStack('TDefEdit.InfoShow');
  f:=pointer(Sender);
  with f do begin
    IfThenSetting(Tag,deiBefore,f);
    FreeAndNil(KeyMenu1); BoundsRect:=SysWorkArea; PanelEdit1.FillKeyLb;
    MainRebuild; w:=0;
    with MainRbPanel do begin
      for i:=0 to ControlCount-1 do if IsClass(Controls[i],TFldEdit,pointer(tf)) then begin
        tf.Enabled:=false;
        if (tf.CharWidth=wallDefault) and tf.Visible then begin
          tf.CharWidth:=0; MaxSelf(w,tf.SizeAuto.cX); tf.CharWidth:=wallDefault;
        end;
        IfThenSetting(f.Tag,deiFld,tf);
      end;
      if RbPanel1.Place in [rpTop,rpBottom] then begin
        w1:=max(KeyLb1.WMin+KeyLb1.BevPanel2,WMin+PanelEdit1.BevPanel2);
        h:=KeyLb1.HMin+KeyLb1.BevPanel2+HMin+PanelEdit1.BevPanel2;
      end
      else begin
        w1:=KeyLb1.WMin+KeyLb1.BevPanel2+WMin+PanelEdit1.BevPanel2;
        h:=max(KeyLb1.HMin+KeyLb1.BevPanel2,HMin+PanelEdit1.BevPanel2);
      end;
      w:=max(MinWidthForm(f),max(w1,w+BevelFld2+PanelEdit1.BevPanel2)+f.Width-f.ClientWidth);
      Inc(h,f.Height-f.ClientHeight);
    end;
    SetBounds((Width-w) div 2,(Height-h) div 2,w,h); IfThenSetting(Tag,deiAfter,f);
  end;
  DelStack;
end;

class procedure TDefEdit.InfoCngKey;
begin
  AddStack('TDefEdit.InfoCngKey');
  with tb do case Key of
    K_F10,K_Alt_Z: Caption:='';
    K_Esc: Caption:='Выход';
  end;
  DelStack;
end;

{class procedure TDefEdit.FreeForms;
var i: longint;
begin
	AddStack('TDefEdit.FreeForms');
  for i:=low(aForm) to high(aForm) do aForm[i].Free;
  aForm:=nil;
  DelStack;
end;}

class procedure TDefEdit.ConvertToForm;
var GF: TGenForm;
  a: TArrStr;
	v: TGFObj;
	function Sort1(const r: TRect; nb,ne: longint; lRows: boolean): TPoint;
  var c: longint;
  	//lmany: boolean;
	  procedure CalcRes;
    var i: longint;
    begin
      AddStack('TDefEdit.ConvertToForm.Sort1.CalcRes');
      with result do begin
        X:=1; Y:=1;
        with GF do for i:=c to ObjectCount-1 do begin
          v:=Objects[i]; MaxSelf(X,v.Right); MaxSelf(Y,v.Bottom);
        end;
        //if lMany then Inc(Y);
      end;
      DelStack;
    end;
	var i,j,h,l,t,t1,lm: longint;
    ap: TDEPrmStr;
    pv: PGFObj;
    lmaxw,fl: boolean;
    cr: TCustomRec;
    nmf: string;
    am: array of record
    	r: TRect;
    	n1,n2: longint;
      lRows: boolean;
    end;
    p: TPoint;
    {awp: TArrStr;
    awp1: array[1..2] of string;}
  begin
    AddStack('TDefEdit.ConvertToForm.Sort1');
    h:=IfThen(lRows,2,1); l:=r.Left; t:=r.Top; {lmany:=false;} fl:=false;
	  with GF do begin
    	c:=ObjectCount; SetLength(am,ceil((ne-nb)/2)); lm:=0;
      while nb<ne do begin
        ap:=DEGetArrParam(a[nb]); lmaxw := Int0(ap[deWidth])=wallDefault;
        if RecName(ap[deNameRec],cr,TRecDBDef) then nmf:=TRecDBDef(cr).DWVarName(ap[deNameRecFld])
        else nmf:='';
        // С новой строки/колонки
        if not fl then fl:=true
        else if StrToBoolean(ap[deTag]) then
          if lRows then begin
            {t:=max(t+2,r.Bottom);} Inc(t,2); l:=r.Left;
          end
          else begin
            {l:=max(l+2,r.Right);} Inc(l,2); Inc(h); t1:=r.Top;
            for j:=c to ObjectCount-1 do begin
              pv:=PObjects[j];
              if pv.Top=r.Top then begin
                t1:=r.Top; t:=pv.Bottom;
              end
              else begin
                if pv.Top=t1 then pv.Top:=t-h
                else begin
                  t1:=pv.Top; pv.Top:=t; Inc(t,h);
                end;
                pv.Bottom:=t;
              end;
            end;
            t:=r.Top; //lmany:=true;
          end;
        // Подсказка
        v.Left:=l; v.Top:=t; v.Bottom:=v.Top+h; v.TypeObj:=toSay; v.Text:=nmf;
        if lmaxw then begin
          v.Alignment:=algmTopCenter; v.Right:=v.Left+2;
          if lRows then v.Bottom:=v.Top+1;
        end
        else begin
          v.Alignment:=algmTopLeft; v.Right:=v.Left+1;
        end;
        {MaxSelf(v.Right,r.Right); MaxSelf(v.Bottom,r.Bottom); }AddObj(v,false);
        // Вводимое поле
        if lmaxw then begin
          v.Top:=v.Bottom; v.Bottom:=v.Top+IfThen(lRows,1,h);
        end
        else begin
        	v.Left:=v.Right; Inc(v.Right);
        end;
        {MaxSelf(v.Right,r.Right); MaxSelf(v.Bottom,r.Bottom);} Inc(nb); i:=nb;
        if NameGet(ap) is TMultiGet then begin
        	nmf:=TrimUpper(ap[deNameRec]+'.'+ap[deNameRecFld]);
          while nb<ne do begin
          	if TrimUpper(DEGetArrParam(a[nb])[deRelation])<>nmf then break;
          	Inc(nb);
          end;
        end;
        if nb>i then begin
          with am[lm] do begin
            r:=Rect(v.Left,v.Top,v.Right,v.Bottom); n1:=i; n2:=nb; lRows := ap[deMask]='2';
          end;
          Inc(lm);
        end
        else begin
	        v.Alignment:=algmTopLeft; v.TypeObj:=toGet; AddObj(v,false);
        end;
        if lRows then {Inc(l,2)} l:=v.Right else t:=v.Bottom;
      end;
      l:=r.Right-r.Left-1; t:=r.Bottom-r.Top-1;
      for j:=c to ObjectCount-1 do begin
      	pv:=PObjects[j]; Inc(pv.Right,l); Inc(pv.Bottom,t);
        if pv.Left>r.Left then Inc(pv.Left,l);
        if pv.Top>r.Top then Inc(pv.Top,t);
      end;
      while lm>0 do begin
      	Dec(lm);
        with am[lm] do begin
        	i:=ObjectCount; p:=Sort1(r,n1,n2,lRows); l:=p.X-r.Right; t:=p.Y-r.Bottom;
          while i>0 do begin
          	Dec(i); pv:=PObjects[i];
            if pv.Left>=r.Right then Inc(pv.Left,l);
            if pv.Right>=r.Right then Inc(pv.Right,l);
            if pv.Top>=r.Bottom then Inc(pv.Top,t);
            if pv.Bottom>=r.Bottom then Inc(pv.Bottom,t);
          end;
          for i:=0 to lm-1 do with am[i].r do begin
            if Left>=r.Right then Inc(Left,l);
            if Right>=r.Right then Inc(Right,l);
            if Top>=r.Bottom then Inc(Top,t);
            if Bottom>=r.Bottom then Inc(Bottom,t);
          end;
        end;
			end;
      CalcRes;
    end;
    DelStack;
  end;
var p: TPoint;
  l: longint;
begin
  AddStack('TDefEdit.ConvertToForm');
  GF:=GFEdCreate;
  with GF do begin
    OpenDcmStr(''); l:=LsArrDynamic(Fields,a,CRLF);
    if l>0 then begin
      DestroyObjects(false); GFObjDef(v); p:=Sort1(Rect(0,0,1,1),0,l,SortMode=smRows);
      ColCount:=p.X; RowCount:=p.Y; ObjSpace(nil,[gfspNoAutoSize],pinTopLeft);
    end;
    SaveCurLeaf; DcmDef:=SaveDcmStr;
  end;
  DelStack;
end;

{ TFormDefEdt }
procedure TFormDefEdt.WMSaveIni;
begin
  AddStack('TFormDefEdt.WMSaveIni',Self);
  if Assigned(de) then Msg.pSection^:=SectBeg+Trim(de.FNameWnd);
  DelStack;
end;

procedure TFormDefEdt.WMFormLimit;
var i,j: longint;
begin
	AddStack('TFormDefEdt.WMFormLimit',Self);
  inherited;
  for i:=low(aForm) to high(aForm) do if FreeLimit(aForm[i]) then begin
    for j:=i+1 to high(aForm) do aForm[j-1]:=aForm[j];
    SetLength(aForm,Length(aForm)-1); break;
  end;
  DelStack;
end;

procedure TFormDefEdt.WMSchem;
var i: longint;
  GF: TGenForm;
begin
	AddStack('TFormDefEdt.WMSchem',Self);
  de.FormSchem(Self,msg);
  if msg.Oper=soAfter then for i:=0 to ComponentCount-1 do
  	if IsClass(Components[i],TGenForm,pointer(GF)) then GF.InGetRebuild;
  DelStack;
end;

procedure TFormDefEdt.WMHelpFill;
begin
  AddStack('TFormDefEdt.WMHelpFill',Self);
  inherited;
  WMMessage(msg);
  DelStack;
end;

procedure TFormDefEdt.WMFldVar;
begin
  AddStack('TFormDefEdt.WMFldVar',Self);
  inherited;
  WMMessage(msg);
  DelStack;
end;

procedure TFormDefEdt.WMRebuild;
begin
  AddStack('TFormDefEdt.WMRebuild',Self);
  inherited;
  WMMessage(Message);
  DelStack;
end;

procedure TFormDefEdt.WMMessage;
begin
  AddStack('TFormDefEdt.WMMessage',Self);
  if Assigned(de) then IfThenWndMethod(de.FOnMessage,Message);
  DelStack;
end;

function TFormDefEdt.MainRbPanel;
var tc: TControl;
  scrl: TRbScrollBox;
begin
  AddStack('TFormDefEdt.MainRbPanel',Self);
  result:=nil;
  if PanelEdit1.ControlCount>0 then begin
    tc:=PanelEdit1.Controls[0];
    if not(tc is TDEGFScrollBox) then
    if IsClass(tc,TRbScrollBox,pointer(scrl)) then
    if scrl.ControlCount>0
      then IsClass(scrl.Controls[0],TRbPanel,pointer(result));
  end;
  DelStack;
end;

{ TDEGFScrollBox }
procedure TDEGFScrollBox.WMRebuild;
var w,h: longint;
begin
	AddStack('TDEGFScrollBox.WMRebuild',Self);
  inherited;
  if ControlCount>0 then with TGenForm(Controls[0]) do begin
    if false in Params.Arr[CurParams].aWidth then Width:=Self.Width;
    if true in Params.Arr[CurParams].aWidth then Height:=Self.Height;
    InGetRebuild(false);
  	w:=GridX[ColCount]+Spot.Right+SysMetric.iScrollWidth; h:=GridY[RowCount]+Spot.Bottom;
  	SetBounds(max(0,(Self.Width-w) div 2),0,w,h);
    PaintAll;
  end;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TDefEdit]);
end;

function BrEditProc(Sender: TObject; lApp: boolean; const Capt: TCaption;
  const glkey,nmfCode,dwValue,dwNameWnd,dwNameScr: string; var Modified: boolean): boolean;
begin
  AddStack('DefEdit.BrEditProc');
  result := Sender is TDefEdit;
  if result then with TDefEdit(Sender) do begin
    if Capt<>'' then FrmCaption:=Capt;
    if nmfCode<>'' then Param[nmfCode,deNoReadOnly]:=bStr[lApp];
    Modified:=Execute.Saved;
  end;
  DelStack;
end;

initialization
	AddStack('DefEdit.initialization');
  AddFrom(BrEditProc);
  DelStack;
end.

