unit PnlEdit;

interface

{$I LIBTEST}
{$DEFINE OSEEK}
uses
  Messages,Classes,Controls,Forms,
  MyTypes,FFldEdit,KeyMenu,KeyLb,Fpanel;

type
	TWMFldActive = record
   	Msg: longint;
    After: WordBool;
		Fld: TFldEdit;
    Result: LongInt;
	end;

  TPECngKeyEvent = procedure(Sender: TObject; var tb: TKeyBut) of object;
  TPEAskCancelExec = function(Sender: TObject): TModalResult of object;

  TPEExitType = (pexEsc,pexEscYes,pexF10,pexPgDn,pexPgUp,pexEnter,pexDown,pexUp,pexAltF4,pexOther);
  TPEExitTypeEvent = procedure(Sender: TObject; ExitType: TPEExitType) of object;

  TSvGetOption = (sgValue,sgOldVal,sgReadOnly,sgReadOnlyNoVsbl);
  TSvGetOptions = set of TSvGetOption;
  TArrSvGetVar = array of array[TSvGetOption] of variant;

  TPEOptions = set of(peAskByCancel,peCheckOnExit,peCloseOnEsc,peNoChangeByCancel,
    peNoCloseForm,peNoSorted,peNoReadOnEnter);

  TPanelEdit = class(TRbPanel)
  private
    { Private declarations }
    curf: TForm;
    MainMn: TKeyMenu;
    oldClose,FOnEscape: TCloseEvent;
    oldActivate,FOnBeforeEnter,FOnBeforeExit,FOnUpdateRec,FOnBeforeMasterFocus,FOnBeforeSimpleEdit,FOnAfterEscape: TNotifyEvent;
    oProc,nProc: Pointer;
    ActSet,ClosSet,MakeEnter,FSave,FChecked,FModified: boolean;
    FMasterControl: TWinControl;
    FldList: TList;
    {$IFNDEF OSEEK}FldName: TStringList;{$ENDIF}
	  FKeyPanel: TKeyLb;
    FExitType: TPEExitType;
    FOptions: TPEOptions;
    FFldFocus: TFldEdit;
    FOnAskCancel,FOnValid,FOnUpdateRecDB: TProcValid;
    FOnAskCancelExec: TPEAskCancelExec;
    FOnCngKey: TPECngKeyEvent;
    FOnExitType: TPEExitTypeEvent;
    FFldFocusName: PString;
    function GetFields(const Index: variant): TFldEdit;
   	procedure ProcKey(Key: longint; tw: TWinControl);
		procedure UpdateFld(cfld: longint);
		procedure Quit(tpExit: TPEExitType; lSave: boolean = true);
		procedure FormActivate(Sender: TObject);
    procedure FEnter(lRead: boolean);
    procedure FExit;
		function FldActive(var n: longint): boolean; overload;
    function Next(cfld: longint; lDown: boolean): boolean;
		procedure SetFldFocus(Value: TFldEdit);
		procedure SetMakeEnter;
		procedure DoMakeEnter;
		procedure MsgWndProc(var Message: TMessage);
    procedure WMPSort(var Message: TWMPSort); message WM_PSORT;
    procedure WMGetDlgCode(var Msg: TWmGetDlgCode); message wm_GetDlgCode;
    procedure WMFldActive(var Msg: TWMFldActive); message wm_FldActive;
    procedure WMActForm(var Msg: TWMActForm); message WM_ACTFORM;
    procedure WMCloseForm(var Message: TMessage); message WM_CLOSEFORM;
		procedure WMHelpFill(var msg: TWMHelpFill); message WM_HELPFILL;
  protected
    { Protected declarations }
    procedure CreateWnd; override;
		procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure BeforeEnter; dynamic;
    procedure BeforeExit; dynamic;
    procedure Escape(var Action: TCloseAction); dynamic;
    procedure AfterEscape; dynamic;
    function DoValid: boolean; dynamic;
  public
    { Public declarations }
    //property Checked: boolean read FChecked;
    function FieldCount: longint;
    property Fields[const Index: variant]: TFldEdit read GetFields; default;
    property FldFocus: TFldEdit read FFldFocus write SetFldFocus;
    property Modified: boolean read FModified;
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
    procedure SetFocus; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    function Valid: boolean;
		procedure FillKeyLb;
		procedure FillFldList;
		procedure ClearFldList;
		procedure FldReadAll(Opt: TFEReadOpt = []);
		procedure FldWriteAll;
		procedure SaveGets(var sg: TArrSvGetVar);
		procedure RestGets(const sg: TArrSvGetVar; Opt: TSvGetOptions = [low(TSvGetOption)..high(TSvGetOption)]);
		function FldActive: TFldEdit; overload;
		function FldActive(var tf: TFldEdit): boolean; overload;
    function FldFocusRest(FldFocusName: PString; lRest: boolean = true): boolean;
		function FldActiveNameRecFld: string;
    function FindField(const cnmf: string): longint;
    function IsFldEdit(const nmf: variant; var tf: TFldEdit): boolean; overload;
    function IsFldEdit(const nmf: variant): boolean; overload;
		procedure AfterSetActivate;
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure SetTWFocus(Sender: TFldEdit);
		function BeforeSimpleEdit: boolean; dynamic;
    procedure IncOptions(Incl: TPEOptions; Excl: TPEOptions = []);
		procedure SetReadOnly(const anmf: array of variant; Value: boolean; opt: TGetOptions = [ogReadOnly]); overload;
		procedure SetReadOnly(Value: boolean; opt: TGetOptions = [ogReadOnly]); overload;
		function SetReadOnly(const Index: variant; Value: boolean; opt: TGetOptions = [ogReadOnly]): boolean; overload;
    class function ParentPnEd(Sender: TWinControl; WithOutSender: boolean = true): TPanelEdit; overload;
    class function ParentPnEd(Sender: TWinControl; var pe: TPanelEdit; WithOutSender: boolean = true): boolean; overload;
  published
    { Published declarations }
    property MasterControl: TWinControl read FMasterControl write FMasterControl;
    property Options: TPEOptions read FOptions write FOptions;
    property OnAfterEscape: TNotifyEvent read FOnAfterEscape write FOnAfterEscape;
    property OnAskCancel: TProcValid read FOnAskCancel write FOnAskCancel;
    property OnAskCancelExec: TPEAskCancelExec read FOnAskCancelExec write FOnAskCancelExec;
    property OnBeforeEnter: TNotifyEvent read FOnBeforeEnter write FOnBeforeEnter;
    property OnBeforeExit: TNotifyEvent read FOnBeforeExit write FOnBeforeExit;
    property OnBeforeMasterFocus: TNotifyEvent read FOnBeforeMasterFocus write FOnBeforeMasterFocus;
    property OnBeforeSimpleEdit: TNotifyEvent read FOnBeforeSimpleEdit write FOnBeforeSimpleEdit;
    property OnEscape: TCloseEvent read FOnEscape write FOnEscape;
    property OnExitType: TPEExitTypeEvent read FOnExitType write FOnExitType;
    property OnCngKey: TPECngKeyEvent read FOnCngKey write FOnCngKey;
    property OnUpdateRec: TNotifyEvent read FOnUpdateRec write FOnUpdateRec;
    property OnUpdateRecDB: TProcValid read FOnUpdateRecDB write FOnUpdateRecDB;
    property OnValid: TProcValid read FOnValid write FOnValid;
  end;

var DWPnEdHelp: procedure(Sender: TObject; var Message: TMessage);

procedure Register;

implementation

uses Windows,ComCtrls,Math,Variants,{$IFNDEF OSEEK}SysUtils,{$ENDIF}
  My_pr,Askp,RecVal,RecDB;

//var CurPnEd: TPanelEdit;

{ TPanelEdit }
constructor TPanelEdit.Create;
begin
	AddStack('TPanelEdit.Create',Self);
  inherited Create(AOwner);
  FldFocus:=nil; FChecked:=true; FOptions:=[];
  FldList:=TList.Create; {$IFNDEF OSEEK}FldName:=TStringList.Create; FldName.Duplicates:=dupAccept;{$ENDIF}curf:=ParentForm(Self); ActSet:=false; ClosSet:=false;
  DelStack;
end;

destructor TPanelEdit.Destroy;
begin
	AddStack('TPanelEdit.Destroy',Self);
	FldList.Free; {$IFNDEF OSEEK}FldName.Free;{$ENDIF}
  inherited Destroy;
  DelStack;
end;

procedure TPanelEdit.CreateWnd;
begin
	AddStack('TPanelEdit.CreateWnd',Self);
	inherited CreateWnd;
  SeekKeyMenu(Self,MainMn);
  DelStack;
end;

procedure TPanelEdit.Notification;
begin
	AddStack('TPanelEdit.Notification',Self);
	inherited Notification(AComponent,Operation);
  SeekKeyMenu(Self,MainMn,AComponent,Operation);
  if (AComponent=FMasterControl) and (Operation=opRemove) then FMasterControl:=nil;
  DelStack;
end;

procedure TPanelEdit.WMPSort;
begin
	AddStack('TPanelEdit.WMPSort',Self);
  inherited;
	if (Message.Oper=swmNoSorted) and (peNoSorted in FOptions) then Message.Result:=1;
  DelStack;
end;

procedure TPanelEdit.WMGetDlgCode;
begin
	AddStack('TPanelEdit.WMGetDlgCode',Self);
	inherited;
  Msg.Result:=dlgc_WantArrows;
  DelStack;
end;

procedure TPanelEdit.WMFldActive;
var ii,i,j,n: longint;
	tf: TFldEdit;
  tw: TWinControl;
begin
	AddStack('TPanelEdit.WMFldActive',Self);
  if Msg.After then begin
    if Assigned(MainMn) then for ii:=0 to FldList.Count-1 do begin
    	tf:=FldList[ii]; tw:=tf;
      while Assigned(tw) and (tw<>Msg.Fld) do ParentSelf(tw);
      if Assigned(tw) then begin
        n:=ii; j:=FldList.Count;
        for i:=0 to FldList.Count-1 do
          if not(ogReadOnly in TFldEdit(FldList[i]).Options) then begin
            j:=i; break;
          end;
        MainMn.EnabledItem(kmEdit,K_Ctrl_Home,n>j);
        j:=-1;
        for i:=FldList.Count-1 downto 0 do
          if not(ogReadOnly in TFldEdit(FldList[i]).Options) then begin
            j:=i; break;
          end;
        MainMn.EnabledItem(kmEdit,K_Ctrl_End,n<j);
      end
      else begin
      	tw:=Msg.Fld;
        while Assigned(tw) and (tw<>tf) do ParentSelf(tw);
        if not Assigned(tw) then tf.CurGetExit(tf.Owner=Msg.Fld.Owner);
        tf.Active:=false;
      end;
    end;
  end
  else FldFocus:=Msg.Fld;
  Msg.Result:=1;
  DelStack;
end;

procedure TPanelEdit.WMActForm;
var fl: boolean;
	tw: TWinControl;
begin
	AddStack('TPanelEdit.WMActForm',Self);
  if not Assigned(FMasterControl) and msg.Visible then begin
  	fl:=MakeEnter;
    if not fl then begin
    	tw:=curf.ActiveControl;
      while Assigned(tw) do begin
      	fl := tw=Self;
        if fl then break;
        ParentSelf(tw);
      end;
    end;
    if fl then DoMakeEnter;
  end;
  DelStack;
end;

procedure TPanelEdit.WMCloseForm;
begin
  AddStack('TPanelEdit.WMCloseForm',Self);
  FExitType:=pexAltF4;
  DelStack;
end;

procedure TPanelEdit.WMHelpFill;
var i,j,k,l: longint;
  a: TArrStr;
begin
  AddStack('TPanelEdit.WMHelpFill',Self);
  if Assigned(DWPnEdHelp) then DWPnEdHelp(Self,TMessage(Msg));
  with Msg do if Oper=hlpTrns then begin
    i:=FieldCount; SetLength(a,i); l:=0;
    for i:=0 to i-1 do with Fields[i] do if not NoPaintObj then if DWVarName(a[l],true) then Inc(l);
    QuickSort(a,l); i:=low(pArr^);
    while i<=high(pArr^) do with pArr^[i] do begin
      if Length(avk)>0 then begin
        j:=low(avk);
        while j<=high(avk) do begin
          if MyVarType(avk[j])=varString then
            if not QuickFind(avk[j],a,l) then begin
              ArrDel(avk,j); continue;
            end;
          Inc(j);
        end;
        if Length(avk)=0 then begin
          for k:=i+1 to high(pArr^) do pArr^[k-1]:=pArr^[k];
          SetLength(pArr^,Length(pArr^)-1); continue;
        end;
      end;
      Inc(i);
    end;
  end;
  DelStack;
end;

function TPanelEdit.FieldCount;
begin
	AddStack('TPanelEdit.FieldCount',Self);
	result:=FldList.Count;
  DelStack;
end;

function TPanelEdit.GetFields;
var i: longint;
begin
	AddStack('TPanelEdit.GetFields',Self);
  if MyVarType(Index)=varString then begin
    i:=FindField(Index);
    if i<0 then result:=nil else result:=FldList[i];
  end
  else result:=FldList[Index];
  DelStack;
end;

{$IFDEF OSEEK}
function TPanelEdit.FindField;
var nmf: string;
begin
  AddStack('TPanelEdit.FindField',Self);
  result:=FldList.Count-1; nmf:=TrimUpper(cnmf);
  while result>=0 do
    if TrimUpper(TFldEdit(FldList[result]).NameRecFld)=nmf then break else Dec(result);
  DelStack;
end;
{$ELSE}
function TPanelEdit.FindField;
begin
  AddStack('TPanelEdit.FindField',Self);
  IntObjFind(FldName,Trim(cnmf),result);
  DelStack;
end;
{$ENDIF}

function TPanelEdit.IsFldEdit(const nmf: variant; var tf: TFldEdit): boolean;
begin
  AddStack('TPanelEdit.IsFldEdit',Self);
  tf:=Fields[nmf]; result:=Assigned(tf);
  DelStack;
end;

function TPanelEdit.IsFldEdit(const nmf: variant): boolean;
var tf: TFldEdit;
begin
  result:=IsFldEdit(nmf,tf);
end;

procedure TPanelEdit.MsgWndProc;
begin
	AddStack('TPanelEdit.MsgWndProc',Self);
  with Message{,CurPnEd} do begin
  	Result:=CallWindowProc(oProc,curf.Handle,Msg,WParam,LParam);
    case Msg of
      WM_NCDESTROY: oProc:=nil;
      WM_REBUILD: if (TWMRebuild(Message).Oper=rbAfter) and Visible then BeforeSimpleEdit;
    end;
  end;
  DelStack;
end;

procedure TPanelEdit.SetFocus;
begin
	AddStack('TPanelEdit.SetFocus',Self);
  if BeforeSimpleEdit and not(peNoSorted in FOptions) then begin
    Include(FOptions,peNoSorted); Show; //CurPnEd:=Self;
    oProc:=Pointer(GetWindowLong(curf.Handle,GWL_WNDPROC));
    nProc:=Classes.MakeObjectInstance(MsgWndProc);
    SetWindowLong(curf.Handle,GWL_WNDPROC,LongInt(nProc));
    //SetWindowLong(curf.Handle,GWL_WNDPROC,LongInt(@MsgWndProc));
  end;
  inherited SetFocus;
  DelStack;
end;

function TPanelEdit.BeforeSimpleEdit;
var w: longint;
begin
  AddStack('TPanelEdit.BeforeSimpleEdit',Self);
  result:=Assigned(FOnBeforeSimpleEdit);
  if result then begin
  	FOnBeforeSimpleEdit(Self);
    if Assigned(Parent) then begin
      w:=Left+Width-Parent.Width;
      if w>0 then IncLeft(Self,-w);
    end;
  end;
  DelStack;
end;

procedure TPanelEdit.DoEnter;
begin
	AddStack('TPanelEdit.DoEnter',Self);
//addmsgfile('PanelEdit.DoEnter');
	if not isCalculator then begin
    if not ClosSet then begin
      oldClose:=curf.OnClose; curf.OnClose:=FormClose; ClosSet:=true;
    end;
    BeforeEnter;
    if not MakeEnter then begin
      FillFldList;
      if FormKeyLb(Self,FKeyPanel) and (FldList.Count>0) then begin
	      if Assigned(FOnBeforeSimpleEdit) then FKeyPanel.SetButNoEval(true);
        if not ActSet and not Assigned(FMasterControl) then begin
          oldActivate:=curf.OnActivate; curf.OnActivate:=FormActivate;
        end;
        ActSet:=true; FSave := peCheckOnExit in FOptions;
        if Assigned(FMasterControl) and not(peNoReadOnEnter in FOptions)
        then FldReadAll(IfThen(FChecked,ferdSvOld)+[ferdFromShow]);
        FillKeyLb; SetMakeEnter;
      end;
    end;
    inherited DoEnter;
  end;
  DelStack;
end;

procedure TPanelEdit.SetMakeEnter;
//var fl: boolean;
begin
	AddStack('TPanelEdit.SetMakeEnter',Self);
  MakeEnter:=true;
  {if curf is TFormWnd then fl:=TFormWnd(curf).ActiveForm
  else fl:=curf.Showing;
  if fl then} DoMakeEnter;
  DelStack;
end;

procedure TPanelEdit.AfterSetActivate;
begin
	AddStack('TPanelEdit.AfterSetActivate',Self);
  if not Assigned(FMasterControl) then begin
    oldActivate:=curf.OnActivate; curf.OnActivate:=FormActivate;
  end;
  ActSet:=true;
  DelStack;
end;

procedure TPanelEdit.FEnter;
begin
	AddStack('TPanelEdit.FEnter',Self);
	FSave := peCheckOnExit in FOptions;
  //if lRead then FldReadAll(FChecked);
  SetMakeEnter;
  DelStack;
end;

procedure TPanelEdit.DoExit;
var pe: TPanelEdit;
begin
	AddStack('TPanelEdit.DoExit',Self);
//addmsgfile('PanelEdit.DoExit');
	if not((csDestroying in ComponentState) or isCalculator
  or not Assigned(FMasterControl)) then begin
    curf.OnClose:=oldClose; ClosSet:=false; BeforeExit;
    if not Assigned(FMasterControl) then curf.OnActivate:=oldActivate;
    FExit;
    if FChecked then 
      if FormKeyLb(Self,FKeyPanel) and (Assigned(FMasterControl) or Assigned(curf.ActiveControl)) then begin
        if ParentPnEd(Self,pe) then pe.FillKeyLb
        else begin
          FKeyPanel.DelKey(K_ALL,'PnlEdit'); FKeyPanel.ReDrw;
        end;
        if Assigned(FMasterControl) then case FExitType of
          pexDown: FMasterControl.Perform(WM_KEYDOWN,vk_Down,1);
          pexUp: FMasterControl.Perform(WM_KEYDOWN,vk_Up,1);
        end;
      end;
    if Assigned(FKeyPanel) and Assigned(FOnBeforeSimpleEdit) then with FKeyPanel do begin
      SetButNoEval(false); ReDrw;
    end;
    MainMn.EditKeysDel;
    inherited DoExit;
  end;
  DelStack;
end;

procedure TPanelEdit.FExit;
var tf: TFldEdit;
	i: longint;
  r: TCustomRec;
  Action: TCloseAction;
  ls: TList;
  ocw: TFEChangeWhere;
begin
	AddStack('TPanelEdit.FExit',Self);
  ocw:=FEChangeWhere;
  try
    FEChangeWhere:=iif(FSave,fcwValid,fcwEsc);
    if LogActive then with LogFields do begin
      BeginUpdate;
      for i:=0 to FldList.Count-1 do with TFldEdit(FldList[i]) do AddRecFld(PNameRec,NameRecFld);
      EndUpdate;
    end;
    FChecked:=true; FModified:=false;
    for i:=0 to FldList.Count-1 do if TFldEdit(FldList[i]).Active then begin
      UpdateFld(i); break;
    end;
    for i:=0 to FldList.Count-1 do if not FModified then begin
      tf:=FldList[i];
      if TrimSpRight(tf.Value)<>TrimSpRight(tf.OldValue) then begin
        FModified:=true; break;
      end;
    end;
    if not FSave and (peAskByCancel in FOptions) then begin
      if not FModified and Assigned(FOnAskCancel) then FModified:=FOnAskCancel(Self);
      if FModified then begin
        if Assigned(FOnAskCancelExec) then i:=FOnAskCancelExec(Self)
        else i:=AskCancel(amsSaveCng,mrYes);
        case i of
          mrCancel: FChecked:=false;
          mrYes: begin
            FSave:=true; Quit(pexEscYes);
          end;
        end;
      end;
    end;
    if FChecked then
      if FSave then FChecked:=Valid
      else begin
        Action:=caHide; Escape(Action); FChecked := Action=caHide;
      end;
    if FChecked then begin
      SetPString(FFldFocusName,FldActiveNameRecFld); FldFocus:=nil;
      if FSave then begin
        ls:=nil;
        try
          for i:=0 to FldList.Count-1 do begin
            tf:=FldList[i]; tf.UpdateRec(feuBeforeUpd);
            if not Assigned(FOnUpdateRec) then if RecName(tf.NameRec,r,TRecDB) then
              if IfThenValid(FOnUpdateRecDB,r) then if not Assigned(ls) or (ls.IndexOf(r)<0) then ListCreateObj(r,ls);
          end;
          if not IfThenNotify(FOnUpdateRec,Self) then
            if Assigned(ls) then for i:=0 to ls.Count-1 do TRecDB(ls[i]).UpdateRec(true);
        finally
          ls.Free;
        end;
        for i:=0 to FldList.Count-1 do TFldEdit(FldList[i]).UpdateRec(feuAfterUpd);
      end
      else if not isCalculator then begin
        i:=0;
        while i<FldList.Count do begin
          tf:=FldList[i];
          if peNoChangeByCancel in FOptions then tf.WriteStr(tf.OldValue,true)
          else begin
            tf.RestOldVal; tf.Write;
          end;
          Inc(i);
        end;
        AfterEscape;
      end;
      if Assigned(FMasterControl) then FldFocus:=nil else DoMakeEnter;
      if Assigned(FOnExitType) then FOnExitType(Self,FExitType);
      if Assigned(FOnBeforeSimpleEdit) then begin
        Exclude(FOptions,peNoSorted); Hide;
        SetWindowLong(curf.Handle,GWL_WNDPROC,LongInt(oProc)); Classes.FreeObjectInstance(nProc);
      end;
    end
    else if Assigned(FMasterControl) then begin
      SetFocus; FSave:=peCheckOnExit in FOptions; SetMakeEnter;
    end
    else FEnter(true);
  finally
    FEChangeWhere:=ocw;
  end;
  DelStack;
end;

procedure TPanelEdit.FillKeyLb;
  procedure SetKey(key: longint; const txt,hnt: string; Part: longint; keyhelp: longint = 0);
  var tb: TKeyBut;
  begin
    AddStack('TPanelEdit.FillKeyLb.SetKey',Self);
    tb.Key:=key; tb.Caption:=txt; tb.Hint:=hnt; tb.Part:=Part; tb.keyhelp:=keyhelp;
    if Assigned(FOnCngKey) then FOnCngKey(Self,tb);
    FKeyPanel.SetKey(tb.key,tb.Caption,tb.Hint,ProcKey,'PnlEdit',tb.Part,'',tb.keyhelp);
    DelStack;
  end;
begin
	AddStack('TPanelEdit.FillKeyLb',Self);
	FormKeyLb(Self,FKeyPanel);
  SetKey(K_F10,'Сохранить','',kmFile);
  SetKey(K_ESC,'Отмена','',kmFile);
  SetKey(K_Up,'','На предыдущее поле',kmNone);
  SetKey(K_Enter,'','',kmNone,K_Up);
  SetKey(K_Down,'','На следующее поле',kmNone);
  SetKey(K_Ctrl_Home,'','На первое поле',kmEdit);
  SetKey(K_Ctrl_End,'','На последнее поле',kmEdit);
  SetKey(K_Ctrl_PgUp,'','',kmNone,K_Ctrl_Home);
  SetKey(K_Ctrl_PgDn,'','',kmNone,K_Ctrl_End);
  SetKey(K_PgUp,'','',kmNone,K_F10);
  SetKey(K_PgDn,'','',kmNone,K_F10);
  SetKey(K_Alt_Z,'Восстан.','Восстановить старое значение',kmEdit);
  FKeyPanel.ReDrw; MainMn.EditKeysAdd;
  DelStack;
end;

procedure TPanelEdit.FillFldList;
var i: longint;
  tc,tc1: TWinControl;
begin
	AddStack('TPanelEdit.FillFldList',Self);
{$IFDEF OSEEK}
  FldList.Clear; GetTabOrderList(FldList); i:=0;
{$ELSE}
  FldList.Clear; FldName.Sorted:=false; FldName.Clear; GetTabOrderList(FldList); FldName.Capacity:=FldList.Count; i:=0;
{$ENDIF}
  while i<FldList.Count do begin
    tc:=FldList[i];
    if (tc is TFldEdit) and tc.Visible and tc.Enabled then begin
      tc1:=tc.Parent;
      while Assigned(tc1) and not(tc1 is TPanelEdit)
      and (not(tc1 is TFldEdit) or tc1.Visible and tc1.Enabled) do ParentSelf(tc1);
      if tc1=Self then begin
        {$IFNDEF OSEEK}FldName.AddObject(TFldEdit(tc).NameRecFld,pointer(i)); {$ENDIF} Inc(i); continue;
      end;
    end;
    FldList.Delete(i);
  end;
  {$IFNDEF OSEEK}FldName.Sorted:=true;{$ENDIF}  
  DelStack;
end;

procedure TPanelEdit.ClearFldList;
begin
	AddStack('TPanelEdit.ClearFldList',Self);
  FldList.Clear; {$IFNDEF OSEEK}FldName.Clear;{$ENDIF}
  DelStack;
end;

procedure TPanelEdit.ProcKey;
var cfld,i: longint;
	tf: TFldEdit;
  fl: boolean;
  g: TCustomGet;
  ov: variant;
begin
	AddStack('TPanelEdit.ProcKey',Self);
  if FldActive(cfld) then tf:=FldList[cfld] else tf:=nil;
  if Assigned(tf) then fl:=tf.MayDoKey(Key)
  else if Key=K_Enter then begin
  	fl:=true;
    for i:=0 to FldList.Count-1 do
    	if not(ogReadOnly in TFldEdit(FldList[i]).Options) then begin
      	fl:=false; break;
      end;
  end
  else fl := Key in [K_F10,K_Esc];
  if fl then begin
    if Assigned(tf) then begin
      ov:=tf.VarValue; tf.Write; tf.Change(ov,tf.VarValue,false);
    end;
		case key of
    	K_F10: Quit(pexF10);
      K_Enter,K_Down: if not Next(cfld,true) then
        if key=K_Enter then Quit(pexEnter)
        else if Assigned(FOnBeforeSimpleEdit) then Quit(pexDown)
      	else UpdateFld(cfld);
      K_Esc: Quit(pexEsc,false);
    	K_PgUp: Quit(pexPgUp);
    	K_PgDn: Quit(pexPgDn);
      K_Up: if not Next(cfld,false) then
        if Assigned(FOnBeforeSimpleEdit) then Quit(pexUp)
      	else UpdateFld(cfld);
      K_Ctrl_Home,K_Ctrl_End,K_Ctrl_PgUp,K_Ctrl_PgDn: begin
      	fl := key in [K_Ctrl_Home,K_Ctrl_PgUp];
        Next(IfThen(fl,-1,FldList.Count),fl);
      end;
	    K_Alt_Z: if Assigned(tf) then
        if NameGet(g,tf) then begin
          fl := tf.RestValType<>grvAsk;
          if not fl then fl:=Ask(['Восстановить старое значение ?']);
          if fl then begin
		      	tf.RestOldVal; tf.PaintObj;
          end;
        end;
    end;
  end
  else FKeyPanel.NoEval:=true;
  DelStack;
end;

procedure TPanelEdit.Quit;
var Action: TCloseAction;
begin
	AddStack('TPanelEdit.Quit',Self);
  if not(Assigned(FMasterControl) and (tpExit=pexEscYes)
  and (curf.ActiveControl<>FMasterControl))
  then curf.ModalResult:=IfThen(lSave,mrOk,mrCancel);
  Action:=caHide; FExitType:=tpExit;
  if Assigned(Application.MainForm) then
    if (curf=Application.MainForm) then
    	if (peNoCloseForm in FOptions) and lSave then FormClose(curf,Action)
      else curf.Close;
  DelStack;
end;

// Номер активного поля
function TPanelEdit.FldActive(var n: longint): boolean;
var tf: TFldEdit;
begin
	AddStack('TPanelEdit.FldActive',Self);
	result:=false; n:=0;
	while n<FldList.Count do begin
   	tf:=FldList[n];
    if tf.Active and tf.Visible and tf.Enabled and (tf.Relation<>frMain) then begin
     	result:=true; break;
    end;
    Inc(n);
  end;
  DelStack;
end;

function TPanelEdit.FldActive: TFldEdit;
begin
  FldActive(result);
end;

function TPanelEdit.FldActive(var tf: TFldEdit): boolean;
var n: longint;
begin
  result:=FldActive(n);
  if result then tf:=Fields[n] else tf:=nil;
end;

procedure RbPagePgActive(tw: TWinControl);
begin
  AddStack('PnlEdit.RbPagePgActive');
  if Assigned(MyTypes.RbPagePgActive) then MyTypes.RbPagePgActive(tw);
  DelStack;
end;

// Передать фокус следующему/предыдущему FldEdit-у
function TPanelEdit.Next;
var i,ne,ns: longint;
	tf: TFldEdit;
  fl: boolean;
label lend;
begin
	AddStack('TPanelEdit.Next',Self);
	result:=false; fl:=true;
  if lDown then begin
  	i:=cfld+1; ne:=FldList.Count; ns:=1;
  end
  else begin
  	i:=cfld-1; ne:=-1; ns:=-1;
  end;
  if InRange(i,0,FldList.Count-1) then
    while i<>ne do begin
      tf:=FldList[i];
      if not(ogReadOnly in tf.Options) and tf.Visible and tf.Enabled
      and (tf.Relation<>frMain) then begin
        // На другой странице
        if not tf.CanFocus then RbPagePgActive(tf);
        if tf.CanFocus then begin
          if not tf.Active then SetTWFocus(tf);
          fl:=false; result:=true; goto lend;
        end;
      end;
      Inc(i,ns);
    end;
  if InRange(cfld,0,FldList.Count-1) then begin
    fl:=false; SetTWFocus(FldList[cfld]);
  end;
lend:
  if fl then SetFocus;
	DelStack;
end;

procedure TPanelEdit.SetTWFocus;
label lend;
begin
	AddStack('TPanelEdit.SetTWFocus',Self);
  RbPagePgActive(Sender);
  if Assigned(curf) then
    if Assigned(curf.ActiveControl) then
      if (curf.ActiveControl=Sender) or (curf.ActiveControl.Owner=Sender) then begin
        Sender.CurGetEnter; Sender.Active:=true; goto lend;
      end;
  if Sender.CanFocus then begin
  	Sender.SetFocus; Sender.CurGetEnter; Sender.Active:=true;
  end;
lend:
  DelStack;
end;

procedure TPanelEdit.SetFldFocus;
var i: longint;
	tf: TFldEdit;
begin
	AddStack('TPanelEdit.SetFldFocus',Self);
  FFldFocus:=Value;
  if Assigned(FFldFocus) then
    if FFldFocus.Relation=frMain then for i:=0 to FldList.Count-1 do begin
      tf:=FldList[i];
      if (tf.Owner=FFldFocus) and not(ogReadOnly in tf.Options) and tf.Visible and tf.Enabled then begin
        FFldFocus:=tf; break;
      end;
    end;
  DelStack;
end;

// Обновление тек. поля без выхода из него
procedure TPanelEdit.UpdateFld;
var tf: TFldEdit;
  tw: TWinControl;
  a: TArrFldEdit;
  l: longint;
begin
	AddStack('TPanelEdit.UpdateFld',Self);
	if InRange(cfld,0,FldList.Count-1) then begin
  	tf:=FldList[cfld]; tw:=tf; a:=nil;
    while Assigned(tw) do begin
      if tw is TFldEdit then AddFrom(a,TFldEdit(tw));
      ParentSelf(tw);
    end;
    for l:=low(a) to high(a) do a[l].DoExit;
    for l:=high(a) downto low(a) do a[l].DoEnter;
  end;
  DelStack;
end;

// Действия перед получением фокуса
procedure TPanelEdit.BeforeEnter;
begin
	AddStack('TPanelEdit.BeforeEnter',Self);
	IfThenNotify(FOnBeforeEnter,Self);
  DelStack;
end;

// Действия перед потерей фокуса
procedure TPanelEdit.BeforeExit;
begin
	AddStack('TPanelEdit.BeforeExit',Self);
	IfThenNotify(FOnBeforeExit,Self);
  DelStack;
end;

// Действия при откате
procedure TPanelEdit.Escape;
begin
	AddStack('TPanelEdit.Escape',Self);
	IfThenClose(FOnEscape,Self,Action);
  DelStack;
end;

procedure TPanelEdit.AfterEscape;
begin
	AddStack('TPanelEdit.AfterEscape',Self);
	IfThenNotify(FOnAfterEscape,Self);
  DelStack;
end;

// Проверка на корректность ввода
function TPanelEdit.Valid;
var i: longint;
	oFldFocus: TFldEdit;
  ts: TTabSheet;
  fl: boolean;
begin
	AddStack('TPanelEdit.Valid',Self);
  result:=true; oFldFocus:=FFldFocus;
  for i:=0 to FldList.Count-1 do begin
    FldFocus:=FldList[i];
    if SeekTabSheet(FldFocus,ts) then fl:=ts.TabVisible else fl:=true;
    if fl then
      if not TFldEdit(FldList[i]).Check then begin
        result:=false; break;
      end;
  end;
  if result then begin
    FldFocus:=oFldFocus;
    for i:=0 to FldList.Count-1 do TFldEdit(FldList[i]).UpdateRec(feuBeforeValid);
		result:=IfThenValid(FOnValid,Self);
    for i:=0 to FldList.Count-1 do TFldEdit(FldList[i]).UpdateRec(feuAfterValid);
  end;
  DelStack;
end;

function TPanelEdit.DoValid;
begin
  AddStack('TPanelEdit.DoValid',Self);
  result:=IfThenValid(FOnValid,Self);
  DelStack;
end;

procedure TPanelEdit.DoMakeEnter;
var j: longint;
  tf,tf1: TFldEdit;
begin
	AddStack('TPanelEdit.DoMakeEnter',Self);
  MakeEnter:=false; FExitType:=pexOther;
	if FldList.Count>0 then begin
    if Assigned(FMasterControl) then tf:=FldActive else tf:=nil;
    if not Assigned(tf) then
	    if Assigned(FFldFocus) then begin
        tf:=FFldFocus;
        if tf.Relation=frMain then for j:=0 to tf.ControlCount-1 do
          if IsClass(tf.Controls[j],TFldEdit,pointer(tf1)) then if not(ogReadOnly in tf1.Options) then begin
            tf:=tf1; break;
          end;
      end
  	  else begin
      	Next(-1,true); tf:=FldActive;
      end;
    FldFocus:=nil;
    if Assigned(tf) then SetTWFocus(tf);
  end;
  DelStack;
end;

procedure TPanelEdit.FormClose;
var tf: TFldEdit;
begin
	AddStack('TPanelEdit.FormClose',Self);
	FSave := curf.ModalResult=mrOk;
  if not Assigned(FMasterControl) or (peCloseOnEsc in FOptions) and not FSave then begin
  	FExit;
    if not FChecked then Action:=caNone;
    IfThenClose(oldClose,Sender,Action);
    if (Action=caHide) and not Assigned(FMasterControl) then
      if FldActive(tf) then tf.Active:=false;
  end
  else begin
  	Action:=caNone; IfThenNotify(FOnBeforeMasterFocus,Self);
    if FMasterControl.CanFocus then begin
    	RbPagePgActive(FMasterControl); FMasterControl.SetFocus;
    end;
  end;
  if (curf=Application.MainForm) and (Action=caNone) then curf.ModalResult:=mrNone;
  DelStack;
end;

procedure TPanelEdit.FormActivate;
begin
	AddStack('TPanelEdit.FormActivate',Self);
	FEnter(false); IfThenNotify(oldActivate,Sender);
  DelStack;
end;

procedure TPanelEdit.FldReadAll;
begin
	AddStack('TPanelEdit.FldReadAll',Self);
	if not isCalculator then ChildFldReadAll(Self,Opt);
  DelStack;
end;

procedure TPanelEdit.FldWriteAll;
begin
	AddStack('TPanelEdit.FldWriteAll',Self);
	ChildFldWriteAll(Self);
  DelStack;
end;

// Сохранить значения FldEdit-ов
procedure TPanelEdit.SaveGets;
var i,j: longint;
begin
	AddStack('TPanelEdit.SaveGets',Self);
  SetLength(sg,FieldCount); j:=low(sg);
  for i:=0 to FieldCount-1 do with Fields[i] do begin
  	sg[j][sgValue]:=Value; sg[j][sgOldVal]:=OldValue;
  	sg[j][sgReadOnly] := ogReadOnly in Options;
  	sg[j][sgReadOnlyNoVsbl] := ogReadOnlyNoVsbl in Options;
    Inc(j);
  end;
  DelStack;
end;

// Восстановить значения FldEdit-ов
procedure TPanelEdit.RestGets;
var i,j: longint;
	go: TGetOptions;
begin
	AddStack('TPanelEdit.RestGets',Self);
  if Length(sg)>0 then begin
    j:=low(sg);
    for i:=0 to FieldCount-1 do with Fields[i] do begin
      if sgValue in Opt then Value:=sg[j][sgValue];
      if sgOldVal in Opt then OldValue:=sg[j][sgOldVal];
      go:=Options;
      if sgReadOnly in Opt then SetSet(go,ogReadOnly,sg[j][sgReadOnly]);
      if sgReadOnlyNoVsbl in Opt then SetSet(go,ogReadOnlyNoVsbl,sg[j][sgReadOnlyNoVsbl]);
      Options:=go; Inc(j);
      if j>high(sg) then break;
    end;
  end;
  DelStack;
end;

procedure TPanelEdit.IncOptions;
begin
  Options:=Options+Incl-Excl;
end;

procedure TPanelEdit.SetReadOnly(const anmf: array of variant; Value: boolean; opt: TGetOptions = [ogReadOnly]);
var i: longint;
begin
  for i:=low(anmf) to high(anmf) do SetReadOnly(anmf[i],Value,Opt);
end;

procedure TPanelEdit.SetReadOnly(Value: boolean; opt: TGetOptions = [ogReadOnly]);
var i: longint;
begin
  for i:=0 to FieldCount-1 do SetReadOnly(i,Value,opt);
end;

function TPanelEdit.SetReadOnly(const Index: variant; Value: boolean; opt: TGetOptions = [ogReadOnly]): boolean;
begin
  AddStack('TPanelEdit.SetReadOnly',Self);
  result:=Fields[Index].SetReadOnly(Value,opt);
  DelStack;
end;

class function TPanelEdit.ParentPnEd(Sender: TWinControl; WithOutSender: boolean = true): TPanelEdit;
begin
  ParentPnEd(Sender,result,WithOutSender);
end;

class function TPanelEdit.ParentPnEd(Sender: TWinControl; var pe: TPanelEdit; WithOutSender: boolean = true): boolean;
begin
  AddStack('TPanelEdit.ParentPnEd');
  if WithOutSender then ParentSelf(Sender);
  result:=ParentClass(Sender,TPanelEdit); pe:=IfThen(result,Sender);
  DelStack;
end;

function TPanelEdit.FldFocusRest;
begin
  AddStack('TPanelEdit.FldFocusRest',Self);
  result:=false; FldFocus:=nil; FFldFocusName:=FldFocusName;
  if lRest then if Assigned(FFldFocusName) then if not empty(FFldFocusName^) then begin
    result:=true; FldFocus:=Fields[FFldFocusName^];
    if Assigned(FldFocus) then if ogReadOnly in FldFocus.Options then FldFocus:=nil;
  end;
  DelStack;
end;

function TPanelEdit.FldActiveNameRecFld;
var tf: TFldEdit;
begin
  AddStack('TPanelEdit.FldActiveNameRecFld',Self);
  if FldActive(tf) then result:=tf.NameRecFld else result:='';
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurLib',[TPanelEdit]);
end;

end.
