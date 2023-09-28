unit FArrvEd;

interface

{$I LIBTEST}
uses
  Windows, Messages, Classes, Controls, Menus, ExtCtrls,
  MyTypes, FrmEdt, KeyMenu, PnlEdit, Keylb, Fpanel, FFldedit, ModelGet, ButGet, FDWPrm, CCodeGet;

type
  TArrvEdModifyOpt = set of (aredNoDef,aredCod);

  TArrvEd = class(TFormEdt)
    pn1: TRbPanel;
    EKa: TFldEdit;
    EModel: TFldEdit;
    EName: TFldEdit;
    pn2: TRbPanel;
    pnDW: TRbPanel;
    pnFdel: TRbPanel;
    EFdel: TFldEdit;
    FmlGet: TButFormGet;
    DWGet: TButGet;
    procedure FormCreate(Sender: TObject);
    function EKaCheck(Sender: TObject): Boolean;
    procedure FormDestroy(Sender: TObject);
    procedure pnButResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function PanelEdit1Valid(Sender: TObject): Boolean;
    procedure FmlGetBeforeClick(Sender: TObject);
    procedure FmlGetAfterClick(Sender: TObject);
    procedure DWGetPaint(Sender: TObject; const ARect: TRect;
      const Text: String);
    function DWGetClick(Sender: TObject; lEval: Boolean): String;
  private
    { Private declarations }
    oDef: string;
    dw: TDataWin;
    procedure mgInterDef(Sender: TObject; Oper: TModelInterDefOper;
      const av: array of Variant; var result: Variant);
    procedure mgHelp(Sender: TObject; var ht: THelpTbl);
    procedure mgSave(Sender: TObject; FromEdit: Boolean);
    procedure mgLoad(Sender: TObject; FromEdit: Boolean);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    class procedure Modify(const ka: string; Opt: TArrvEdModifyOpt = []);
  end;

const ArrvFdelHelpContext = 6401;

var ArrvEd: TArrvEd;
  ArrvEdDopKey: string;
  ArrvEdDopProc: TKeyProc;
  ArrvModifiedProc: procedure(var aUpd: TArrStr);

implementation

{$R *.DFM}

uses SysUtils,Variants,
  My_pr,ArrGet,RecVal,Recdb,FDWVid,FDWFld,FrmPswd,FSchemDM;

procedure AddPrnHead;
begin
  AddStack('FArrvEd.AddPrnHead');
  My_pr.AddPrnHead('Массив: '+Trim(RDBArrv[fARRV])+'. '+RDBArrv[fNAME]);
  DelStack;
end;

{ TArrvEd }
procedure TArrvEd.FormCreate(Sender: TObject);
const aprc: TDWPostPrc = (50,100);
var i: longint;
	nmr: string;
  p: TDWPostList;
  pn: TRbPanel;
begin
	AddStack('TArrvEd.FormCreate',Self);
  dw:=TDataWin.Create;
  for p:=low(aDWPost) to high(aDWPost) do begin
    pn:=TRbPanel.Create(Self);
    with pn do begin
      Parent:=pnDW; Name:='pn'+aDWPost[p].post; ProcentWnd:=aprc[p]; SortObj:=false; BevelOuter:=bvLowered;
      with TFldEdit.Create(Self) do begin
        Parent:=pn; AssignGet(DWGet); Mask:=ButPrm2Mask(FRup(aDWPost[p].nm));
        NameRecFld:=DWMem(p); IncOptions([],[ogAutoSize]);
      end;
      OnResize:=pnButResize;
    end;
  end;
  with PanelEdit1 do begin
  	FillFldList; nmr:=RDBArrv.NameRec;
    for i:=0 to FieldCount-1 do Fields[i].NameRec:=nmr;
  end;
  KeyLb1.SetKeysSt(ArrvEdDopKey,ArrvEdDopProc,'dop');
  EFdel.HelpContext:=ArrvFdelHelpContext;
  with SchemDM.mgArrv do begin
    OnInterDef:=mgInterDef; OnHelp:=mgHelp; OnLoad:=mgLoad; OnSave:=mgSave;
  end;
  inherited;
  DelStack;
end;

procedure TArrvEd.FormDestroy(Sender: TObject);
begin
	AddStack('TArrvEd.FormDestroy',Self);
  inherited;
  FreeAndNil(dw);
  DelStack;
end;

procedure TArrvEd.FormShow(Sender: TObject);
var i: longint;
begin
	AddStack('TArrvEd.FormShow',Self);
  oDef:=RDBArrv[DWMem]; i:=RDBArrv.NumFromName(DWMem(postWin));
  RDBArrv.ValueNum[i]:=dw.ReplaceNameRec(RDBArrv.ValueNum[i],'DWVidArr',RDBArr.NameRec);
  inherited;
  DelStack;
end;

function TArrvEd.EKaCheck(Sender: TObject): Boolean;
begin
	AddStack('TArrvEd.EKaCheck',Self);
	result:=KodCheck(Sender,'','',[chkNoEmpty]);
  DelStack;
end;

procedure TArrvEd.pnButResize(Sender: TObject);
begin
	AddStack('TArrvEd.pnButResize',Self);
  with TRbPanel(Sender) do Controls[0].SetBounds(2,2,Width-4,Height-4);
  DelStack;
end;

function TArrvEd.PanelEdit1Valid(Sender: TObject): Boolean;
begin
	AddStack('TArrvEd.PanelEdit1Valid',Self);
  inherited;
  if RDBArrv.RecNo=0 then result:=SchemDM.mgArrv.EmpCodApp(Sender)
  else begin
    result:=TrnsStart([tARRV,tARR],1,FLockMono);
    if result then try
      result:=ChangeDat(RDBArr,oDef,RDBArrv[DWMem],RDBArr.TblFldName(fARRV)+'='+QQs(RDBArrv[fARRV]));
      if result then RDBArrv.UpdateRec(true) else PanelEdit1.FldFocus:=PanelEdit1.Fields[DWMem];
      TrnsEndMono(not result);
    except
      TrnsEndMono; raise
    end;
  end;
  DelStack;
end;

procedure TArrvEd.mgHelp;
var n: byte;
  p: TDWPostList;
begin
  AddStack('TArrvEd.mgHelp',Self);
  n:=high(ht.Dat); SetLength(ht.Dat,n+DWPostLen+2);
  with RDBArrv do begin
    for p:=low(aDWPost) to high(aDWPost) do HelpTblAdd(ht,n,[DWMem(p)]);
    HelpTblAdd(ht,n,[fArrvFDEL]);
  end;
  DelStack;
end;

procedure TArrvEd.mgSave;
var p: TDWPostList;
begin
  AddStack('TArrvEd.mgSave',Self);
	with TModelGet(Sender) do begin
    for p:=low(aDWPost) to high(aDWPost) do WriteStr(RDBArrv[DWMem(p)]);
    WriteStr(RDBArrv[fArrvFDEL]);
  	RDBArrv[fMODEL]:=MDFile; RDBArrv[fNMODEL]:=NSave;
  	if FromEdit then EModel.Read else RDBArrv.UpdateRec(true);
  end;
  DelStack;
end;

procedure TArrvEd.mgLoad;
var fl: boolean;
  p: TDWPostList;
  ka: string;
begin
  AddStack('TArrvEd.mgLoad',Self);
	with TModelGet(Sender) do begin
  	oDef:=RDBArrv[DWMem];
		if empty(RDBArrv[fARRV]) then RDBArrv[fARRV]:=MDFile;
    if empty(RDBArrv[fNAME]) then RDBArrv[fNAME]:=MDName;
    RDBArrv[fNMODEL]:=NSave;
    for p:=low(aDWPost) to high(aDWPost) do RDBArrv[DWMem(p)]:=ReadStr;
    if Vers>=1 then RDBArrv[fArrvFDEL]:=ReadStr;
    if FromEdit then PanelEdit1.FldReadAll
    else begin
      RDBArrv[fMODEL]:=MDFile;
      if TrnsStart([tARRV,tARR],1,FLockMono) then try
        ka:=RDBArrv[fARRV]; fl:=ChangeDat(RDBArr,oDef,RDBArrv[DWMem],RDBArr.TblFldName(fARRV)+'='+QQs(ka));
        if fl then begin
          RDBArrv.UpdateRec(true); TArrvEd.Modify(ka);
        end;
        TrnsEndMono(not fl);
      except
        TrnsEndMono; raise
      end;
    end;
  end;
  DelStack;
end;

procedure TArrvEd.mgInterDef;
begin
  AddStack('TArrvEd.mgInterDef',Self);
  case Oper of
    mdiVarName: result:='МД';
    mdiAfterLoad: Modify(RDBArrv[fARRV]);
  end;
  DelStack;
end;

procedure TArrvEd.WMFormLimit;
begin
	AddStack('TArrvEd.WMFormLimit',Self);
  inherited;
  FreeLimit(ArrvEd);
  DelStack;
end;

procedure TArrvEd.FmlGetBeforeClick(Sender: TObject);
begin
	AddStack('TArrvEd.FmlGetBeforeClick',Self);
  AddPrnHead; My_pr.AddPrnHead('Действия при удалении'); TDWPrm.VarCreate(RDBArr);
  DelStack;
end;

procedure TArrvEd.FmlGetAfterClick(Sender: TObject);
begin
  AddStack('TArrvEd.FmlGetAfterClick',Self);
  TDWPrm.VarFree(RDBArr); DelPrnHead(2);
  DelStack;
end;

procedure TArrvEd.DWGetPaint(Sender: TObject; const ARect: TRect;
  const Text: String);
var tf: TFldEdit;
begin
	AddStack('TArrvEd.DWGetPaint',Self);
  tf:=pointer(Sender);
  if tf.NameRecFld=DWMem
  then TDWVid.ButGetPaint(Sender,ARect,RDBArr,[dwbShortType,dwbBrackets])
  else begin
    RDBArr; dw.ButGetPaint(Sender,ARect,tf.Value);
  end;
  DelStack;
end;

function TArrvEd.DWGetClick(Sender: TObject; lEval: Boolean): String;
var tf: TFldEdit;
  s: string;
  ordbArr: TRecDBDef;
begin
	AddStack('TArrvEd.DWGetClick',Self);
	if lEval then begin
  	AddPrnHead; tf:=pointer(Sender);
    if tf.NameRecFld=DWMem then begin
      ordbArr:=CurRdbArr;
      try
        CurRdbArr:=RDBArr;
        if DWVidExec(RDBArr) then ChildFldReadAll(pn2);
      finally
        CurRdbArr:=ordbArr;
      end;
    end
    else begin
      My_pr.AddPrnHead('Окно ввода данных'); TDWPrm.VarCreate(RDBArr); s:=tf.Value;
      if DWFldExec('Настройка редактирования данных по массиву',s,[RDBArr],
        nil,nil,[],nil,nil,@aDWActHelp)
      then tf.VarValue:=s;
      if RDBArr.DWModified then ChildFldReadAll(pn2);
      TDWPrm.VarFree(RDBArr); DelPrnHead;
    end;
    DelPrnHead;
  end;
	result:='';
  DelStack;
end;

class procedure TArrvEd.Modify;
var a: TArrStr;
begin
  AddStack('TArrvEd.Modify');
  a:=nil;
  if aredCod in Opt then begin
    ArrFixGet.ClearBufCod(nil,ka); AddFrom(a,updCodeGet);
  end;
  if not(aredNoDef in Opt) then begin
    TRecDBDef.ClearArrDefCod(ka); AddFrom(a,updArrDef);
  end;
  TArrGet.VarCreate;
  if Assigned(ArrvModifiedProc) then ArrvModifiedProc(a);
  ProgPswd.SendUpd(a); TCustomGet.UpdateAllGet(TArrGet,mgCreate);
  DelStack;
end;

procedure MDInterVarCreate(var Prm: pointer; lAfter: boolean);
begin
  AddStack('FArrvEd.MDInterVarCreate');
  if lAfter then begin
    if boolean(Prm) then FormFree(ArrvEd);
  end
  else Prm:=pointer(CreateForm(TArrvEd,ArrvEd));
  DelStack;
end;

procedure ModelGetProc(Before: boolean; var lCreate: boolean);
begin
  AddStack('FArrvEd.ModelGetProc');
  if Before then lCreate:=CreateForm(TArrvEd,ArrvEd)
  else if lCreate then FormFree(ArrvEd);
  DelStack;
end;

procedure LogTrnsValProc(var Prm: TLogTrnsValPrm);
var p: TDWPostList;
begin
  AddStack('FArrvEd.LogTrnsValProc');
  if LogEqual(Prm,tARRV,fArrvFDEL)
    then TCrlfLogCompare.Execute(Prm)
  else for p:=low(aDWPost) to high(aDWPost) do
    if LogEqual(Prm,tARRV,DWMem(p)) then with Prm do begin
      case p of
        postDat: TDatLogCompare.Execute(Prm,RDBArr);
        postWin: TWinLogCompare.Execute(Prm);
      end;
      break;
    end;
  DelStack;
end;

initialization
  AddStack('FArrvEd.initialization');
  AddFrom(MDInterVarCreate);
  AddFrom(ModelGetProc);
  LogTrnsValProcAdd(LogTrnsValProc);
  DelStack;
end.
