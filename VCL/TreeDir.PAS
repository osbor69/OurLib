unit TreeDir;

interface

{$I LIBTEST}
uses
  Windows,Classes,Controls,Dialogs,ComCtrls,SysUtils,
  MyTypes,FPanel,TreePrim,RbMenu,RecVal,DefEdit,KeyLb;

type
  TTreeDirHistory = class(TStringList)
  private
    procedure MoveUp(i: longint; const s: string);
		procedure KeyProcHistory(key: longint; tw: TWinControl);
  public
    Ident: string;
    procedure ReadIni;
    procedure WriteIni;
    function Execute(var s: string; Sender: TWinControl): boolean;
  end;

  TTreeDirCngKeyEvent = procedure(Sender: TObject; var Allowed: boolean; var tb: TKeyBut) of object;
  TTreeDirAddPrimEvent = procedure(var Allowed: boolean; Node: TTreeNode;
    var TextNode,Prim: string; cHelpContext: THelpContext; Dop: Pointer) of object;

	TTreeDirSortType = (dstName,dstExt,dstTime,dstSize);

  TTreeDirNodeType = (dntMyDoc,dntFloppy,dntNet,dntDir,dntFile);

  PTreeDirNode = ^TTreeDirNode;
  TTreeDirNode = record
    tp: TTreeDirNodeType;
    Time,NetResource: longint;
    Size: Int64;
    OriginalName: TFileName;
    IsChkChild: boolean;
  end;

  TTreeDir = class(TRbPanel)
  private
    FHideExt: boolean;
    FOpenDialog: TOpenDialog;
    FProcSel: TKeyProc;
    FRootDir,FSectIni: string;
    FOptions: TTreeDirOptions;
    FIniOptions: TTreePrimIniOptions;
    FOnAddPrim: TTreeDirAddPrimEvent;
    FOnAddedPrim: TNotifyEvent;
    FOnCngKey: TTreeDirCngKeyEvent;
    dmSort,dmFlt: TDefMenu;
    Rec: TRecVal;
    deCreate: TDefEdit;
    KeyLb1: TKeyLb;
    aFlt: TArrStr;
    FltIndex,lNode,lNetResource: longint;
    SortType: TTreeDirSortType;
    ls: TStringList;
    lsHistory: TTreeDirHistory;
    aNode: array of TTreeDirNode;
    aNetResource: array of TNetResource;
    function GetIdent: string;
    procedure SetIdent(const Value: string);
    procedure SetRootDir(const Value: string);
    procedure ProcKey(Key: longint; tw: TWinControl);
		procedure StatSort;
		procedure StatFlt;
		procedure NodeFill(Node: TTreeNode; WithDir: boolean = true);
		procedure DirNodeAdd(const txt,Prim: string; tnParent: TTreeNode = nil;
    	const cdir: string = ''; Dop: longint = 0; const OriginalName: string = '');
		function SeekDir(const Directory: string): boolean;
    procedure RbStatus1Click(Sender: TObject);
    procedure RbStatus1MouseMove(Sender: TObject; Shift: TShiftState; X,Y: longint);
    procedure TreeChange(Sender: TObject; Node: TTreeNode);
    procedure TreeCompare(Sender: TObject; Node1,Node2: TTreeNode; Data: longint; var Compare: longint);
    procedure TreeExpanding(Sender: TObject; Node: TTreeNode; var AllowExpansion: Boolean);
    procedure TreeExpanded(Sender: TObject; Node: TTreeNode);
    procedure TreeChecking(Sender: TObject; Node: TTreeNode; Value: boolean;
      var Allowed: boolean; var StateIndex: longint);
    procedure TreeChecked(Sender: TObject; Node: TTreeNode; Value: boolean);
    procedure TreeCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure dmSortFrmShow(Sender: TObject);
		procedure dmShow(Sender: TObject; SectNum: byte);
    procedure dmFltFrmShow(Sender: TObject);
    class procedure deCreatePnlCngKey(Sender: TObject; var tb: TKeyBut);
    function deCreatePnlValid(Sender: TObject): Boolean;
    procedure IniSave;
    procedure IniRest;
    function NodeInf(Node: TTreeNode; var p: PTreeDirNode): boolean; overload;
    function NodeType(Node: TTreeNode): TTreeDirNodeType;
    function NewNode(tp: TTreeDirNodeType; sz: Int64 = -1): longint; overload;
    function NewNode(tp: TTreeDirNodeType; var p: PTreeDirNode; sz: Int64 = -1): longint; overload;
    function NodeFileName(Node: TTreeNode): string; overload;
  protected
    procedure SetKey(key: longint; const txt: string; const hnt: string = '';
      const nmPr: string = 'treedir'; Part: longint = kmList; Allowed: boolean = true); dynamic;
    function AddPrim(Node: TTreeNode; const cTextNode: string;
    	const cPrim: string = ''; cHelpContext: THelpContext = 0; Dop: Pointer = nil): TTreeNode; dynamic;
  public
    Directory: string;
    Tree: TTreePrim;
    RbStatus1: TRbStatus;
    Modified,ChkOptSet: boolean;
    DopSectRight: byte;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Active: boolean;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure ReloadList;
		function nmDir(tn: TTreeNode = nil; DlmEnd: boolean = true): string;
    function NodeFile(Node: TTreeNode): boolean;
    function NodeFileName(const Text: string; Dop: Pointer; DlmEnd: boolean): string; overload;
    function NodeInf(Node: TTreeNode): PTreeDirNode; overload;
    function AllowMultiSelect: boolean;
    function StdSectRight: longint;
  published
    property HideExt: boolean read FHideExt write FHideExt;
    property Ident: string read GetIdent write SetIdent;
    property OpenDialog: TOpenDialog read FOpenDialog write FOpenDialog;
    property Options: TTreeDirOptions read FOptions write FOptions;
    property IniOptions: TTreePrimIniOptions read FIniOptions write FIniOptions default [low(TTreePrimIniOption)..high(TTreePrimIniOption)];
    property ProcSel: TKeyProc read FProcSel write FProcSel;
    property RootDir: string read FRootDir write SetRootDir;
    property SectIni: string read FSectIni write FSectIni;
    property OnAddPrim: TTreeDirAddPrimEvent read FOnAddPrim write FOnAddPrim;
    property OnAddedPrim: TNotifyEvent read FOnAddedPrim write FOnAddedPrim;
    property OnCngKey: TTreeDirCngKeyEvent read FOnCngKey write FOnCngKey;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
  end;

var TreeDirPrmSize: TFmtNum;

procedure Register;

implementation

uses Forms,ShlObj,DB,Math,StdCtrls,StrUtils,ShellApi,
  My_pr,Askp,FFldEdit,ListF2,BufFile;

const
	anmSort: array[TTreeDirSortType] of string = ('имени','расширению','времени','размеру');

function DrvLabelBrack(const drv: string): string;
begin
  AddStack('TreeDir.DrvLabelBrack');
  result:=BrackNoEmp(DrvLabel(drv),' (');
  DelStack;
end;

{ TTreeDirHistory }
const HistorySectBeg = 'DirTree.';

function SortHistory(List: TStringList; Index1, Index2: longint): longint;
begin
  AddStack('SortHistory');
  result:=Int0(List[Index1])-Int0(List[Index2]);
  DelStack;
end;

procedure TTreeDirHistory.ReadIni;
var i: longint;
begin
  AddStack('TTreeDirHistory.ReadIni');
  InitFIni[fiSave].ReadSectionValues(HistorySectBeg+Ident,Self);
  CustomSort(SortHistory);
  for i:=0 to Count-1 do Strings[i]:=Copy(Strings[i],Pos('=',Strings[i])+1,MaxInt);
  DelStack;
end;

procedure TTreeDirHistory.WriteIni;
var i: longint;
  Sect: string;
begin
  AddStack('TTreeDirHistory.WriteIni');
  Sect:=HistorySectBeg+Ident; InitFIni[fiSave].EraseSection(Sect);
  for i:=0 to Count-1 do InitFIni[fiSave].WriteString(Sect,IntToStr(i),Strings[i]);
  DelStack;
end;

procedure TTreeDirHistory.MoveUp;
begin
  AddStack('TTreeDirHistory.MoveUp');
  if i>=0 then Delete(i);
  Insert(0,s);
  DelStack;
end;

function TTreeDirHistory.Execute;
var mr: TListF2Result;
begin
  AddStack('TTreeDirHistory.Execute');
  mr:=TListF2Result.Create;
  try
    result:=ListF2Down(Text,mr,Sender,0,'Browl',TKeyLb.GetKeySt(K_F8,'Удалить'),KeyProcHistory);
    if result then begin
      s:=Strings[mr.SelectStr]; MoveUp(mr.SelectStr,s);
    end;
  finally
    mr.Free;
  end;
  DelStack;
end;

procedure TTreeDirHistory.KeyProcHistory;
var i,j: longint;
  lb: TFindListBox;
begin
	AddStack('TTreeDirHistory.KeyProcHistory');
  if Count>0 then if Ask(amsDel) then begin
    lb:=pointer(tw); lb.GetIndexFiltered(i,j); Delete(j); lb.ItemDel(i);
    if Count>0 then lb.ItemIndex:=EnsureRange(i,0,lb.Items.Count-1);
  end;
  DelStack;
end;

{ TTreeDir }
constructor TTreeDir.Create;
var pnTree: TRbPanel;
  av: TDEPrmVar;
begin
  AddStack('TTreeDir.Create',Self);
  inherited Create(AOwner);
  SetLength(aNode,10); Finalize(aNode[0]); ZeroMemory(@aNode[0],SizeOf(aNode[0]));
  SetLength(aNetResource,10); ZeroMemory(@aNetResource[0],SizeOf(aNetResource[0]));
  Modified:=true; ls:=TStringList.Create; lsHistory:=TTreeDirHistory.Create;
  BevelOuter:=bvNone;
  FIniOptions:=[low(TTreePrimIniOption)..high(TTreePrimIniOption)];
  Place:=rpBottom; ProcentWnd:=100;
  RbStatus1:=TRbStatus.Create(Self);
  with RbStatus1 do begin
    Parent:=Self; Cursor:=crHandPoint; OnClick:=RbStatus1Click; OnMouseMove:=RbStatus1MouseMove;
  end;
  pnTree:=TRbPanel.Create(Self);
  with pnTree do begin
    Parent:=Self; Schem:='Tree'; ProcentWnd:=100; BevelOuter:=bvNone;
    Tree:=TTreePrim.Create(Self);
    with Tree do begin
      Parent:=pnTree; SeekLength:=30; Options:=[tpEnterExpand,tpNoDopDispose];
      OnCompare:=TreeCompare; OnChange:=TreeChange; OnExpanding:=TreeExpanding; OnExpanded:=TreeExpanded;
    end;
  end;
  dmSort:=TDefMenu.Create(Self);
  with dmSort do begin
    KeyBevel:=1; KeySpot:=1; KeyBetween:=1; FrmBorderStyle:=bsToolWindow; FrmCaption:='Сортировка';
    OnFrmShow:=dmSortFrmShow;
  end;
  dmFlt:=TDefMenu.Create(Self);
  with dmFlt do begin
    KeyBevel:=1; KeySpot:=1; KeyBetween:=1; FrmBorderStyle:=bsToolWindow; FrmCaption:='Фильтр';
    OnFrmShow:=dmFltFrmShow; 
  end;
  Rec:=TRecVal.Create(Self); Rec.CreateFld('FILE',ftMemo,0,'');
  TSimpleGet.CreateOne;
  deCreate:=TDefEdit.Create(Self);
  with deCreate do begin
    FrmCaption:='Создать файл'; NameWnd:='DirTree';
    OnPnlCngKey:=deCreatePnlCngKey; OnPnlValid:=deCreatePnlValid;

    InitArr(av);
    av[deNameRec]:=Rec.NameRec;
    av[deNameRecFld]:='FILE';
    TSimpleGet.AssignGetClass(av);
    av[deAutoSel]:=true;
    av[deNoReadOnly]:=true;
    av[deWidth]:=wallDefault;
    av[deTrimLeft]:=true;
    CreateFld(av);
  end;
  if csDesigning in ComponentState then begin
    pnTree.Align:=alClient; Tree.Align:=alClient;
  end;
  DelStack;
end;

destructor TTreeDir.Destroy;
begin
  AddStack('TTreeDir.Destroy',Self);
  ls.Free; lsHistory.Free;
  inherited Destroy;
  DelStack;
end;

function TTreeDir.Active;
begin
  AddStack('TTreeDir.Active',Self);
  result:=Assigned(KeyLb1);
  DelStack;
end;

procedure TTreeDir.DoEnter;
var lDlg: boolean;
  a: TArrStr;
  i,j,n: longint;
  st: TTreeDirSortType;
  Prim,dir: string;
  p: PTreeDirNode;
begin
  AddStack('TTreeDir.DoEnter',Self);
  if not IsCalculator then begin
    if not Active then
      if FormKeyLb(Self,KeyLb1) then begin
        Tree.OnKeyDown:=OnKeyDown; Tree.OnKeyPress:=OnKeyPress; Tree.OnKeyUp:=OnKeyUp;
        lDlg:=Assigned(FOpenDialog);
        if not ChkOptSet then Tree.SetOption([tpCanCheck,tpCanCheckNode,tpNoCheckAll],AllowMultiSelect);
        with Tree do
          if AllowMultiSelect then IniOptions:=IniOptions+[tpiSelected] else IniOptions:=IniOptions-[tpiSelected];
        if Modified then begin
          dmFlt.Keys.Clear;
          with InitFIni[fiSave] do
            SortType:=TTreeDirSortType(ReadInteger('DirSortType',Ident,
              ReadInteger('DirTree','SortType',byte(dstName))));
          lsHistory.ReadIni;
          Tree.SetOption([tpEnterExpand],not lDlg);
          if lDlg then begin
            Tree.SeekCaption:='Файл';
            if not empty(FOpenDialog.Filter) then begin
              n:=LsArrDynamic(FOpenDialog.Filter,a,'|'); i:=0; SetLength(aFlt,Ceil(n/2));
              for j:=low(aFlt) to high(aFlt) do begin
                dmFlt.InsertKey(K_1+j,a[i]); Inc(i);
                if i<n then aFlt[j]:=a[i] else aFlt[j]:='';
                Inc(i);
              end;
            end;
            FltIndex:=EnsureRange(FOpenDialog.FilterIndex,1,dmFlt.Keys.Count)-1;
          end
          else begin
            Tree.SeekCaption:='Папка';
            if SortType=dstSize then SortType:=low(SortType);
          end;
          StatFlt; StatSort; dmSort.Keys.Clear;
          for st:=low(anmSort) to high(anmSort) do
            if (st<>dstSize) or lDlg then dmSort.InsertKey(K_1+byte(st),'по '+anmSort[st]);
          Tree.BeginUpdate;
          try
            Tree.ClearPrim; lNode:=1; lNetResource:=1; ls.Sorted:=false; dir:=Directory;
            if FRootDir='' then begin
              DirNodeAdd('Мои документы','',nil,'',NewNode(dntMyDoc),
                GetRegKey(HKEY_CURRENT_USER,REGSTR_PATH_SPECIAL_FOLDERS,'Personal'));
              if Win32Platform=VER_PLATFORM_WIN32_NT
              then DirNodeAdd('Общие документы','',nil,'',NewNode(dntMyDoc),
                GetRegKey(HKEY_LOCAL_MACHINE,REGSTR_PATH_SPECIAL_FOLDERS,'Common Documents'));
              if not empty(dir) and empty(ExtractFileDrive(dir)) then IncL(dir,ExeDir);
              GetDriveList(ls); CorrDirSelf(ls,[crdrNoDlmEnd]); ls.Sorted:=true;
              for i:=0 to ls.Count-1 do begin
                if UpCase(ls[i][1])<'C' then begin
                  Prim:='дискета'; n:=NewNode(dntFloppy);
                end
                else begin
                  j:=GetDriveType(PChar(ls[i])); n:=0;
                  Prim:=IfThen(j=DRIVE_REMOVABLE,'съемный ',IfThen(j=DRIVE_REMOTE,'сетевой ',
                    IfThen(j=DRIVE_CDROM,'компакт-')))+'диск'+DrvLabelBrack(ls[i]);
                end;
                DirNodeAdd(ls[i],Prim,nil,'',n);
              end;
              n:=NewNode(dntNet,p); p.NetResource:=0; DirNodeAdd('Сеть','',nil,'',n);
            end
            else NodeFill(nil);
            if lDlg and empty(dir) then dir:=FOpenDialog.InitialDir;
            IniRest;
          finally
            if not(SeekDir(dir) or (tpiSelected in FIniOptions)) then Tree.FirstSelect;
          end;
        end;
        SetKey(K_F11,'Сортировка','','treedir');
        if lDlg then SetKey(K_F7,'Создать','Создать файл','treedirfile',kmFile)
        else begin
          SetKey(K_Enter,'Выбор'); KeyLb1.DelKey(K_All,'treedirfile');
        end;
        SetKey(K_F2,'Список','Список ранее выбранных '+IfThen(lDlg,'файлов','папок'),
          'treedir',kmFile,lsHistory.Count>0);
        SetKey(K_F3,'Фильтр','','treedir',kmList,dmFlt.Keys.Count>1);
        SetKey(K_F8,'Удалить','','treedir',kmFile);
        KeyLb1.ReDrw;
        GetParentForm(Self).ActiveControl:=Tree; Modified:=false;
        if AllowMultiSelect then begin
          Tree.OnChecking:=TreeChecking; Tree.OnChecked:=TreeChecked; Tree.OnCustomDrawItem:=TreeCustomDrawItem;
        end
        else begin
          Tree.OnChecking:=nil; Tree.OnChecked:=nil; Tree.OnCustomDrawPrim:=nil;
        end;
      end;
    inherited DoEnter;
  end;
  DelStack;
end;

procedure TTreeDir.DoExit;
begin
  AddStack('TTreeDir.DoExit',Self);
  if not IsCalculator then begin
    if Active then begin
      Directory:=nmDir(nil,false); KeyLb1.DelKeyNmPr(['treedir','treedirfile']);
      KeyLb1.ReDrw; KeyLb1:=nil;
      lsHistory.WriteIni;
      InitFIni[fiSave].WriteInteger('DirSortType',Ident,byte(SortType));
      IniSave;
    end;
    inherited DoExit;
  end;
  DelStack;
end;

procedure TTreeDir.ProcKey;
var i: longint;
  procedure DelNode(const dir: TFileName; tn: TTreeNode);
  var tn1: TTreeNode;
    s,s1: TFileName;
  begin
    AddStack('TTreeDir.ProcKey.DelNode',Self);
    case NodeType(tn) of
      dntDir: begin
        s:=dir+NodeInf(tn).OriginalName;
        case i of
          mrYes: DelFileAtr(s,true);
          mrNo:
            if NodeNotFill(tn) then XDel(s)
            else begin
              tn1:=tn.getFirstChild; s1:=CorrDir(s);
              while Assigned(tn1) do begin
                DelNode(s1,tn1); GetNextSiblingSelf(tn1);
              end;
              DirRemove(s);
            end;
        end;
      end;
      dntFile: begin
        DelFileAtr(dir+NodeInf(tn).OriginalName,i=mrYes);
        if AllowMultiSelect then Tree.Checked[tn]:=false;
      end;
    end;
    DelStack;
  end;
var tp: TTreeDirNodeType;
  dir: TFileName;
  s: string;
  tn,tn1,tn2: TTreeNode;
begin
  AddStack('TTreeDir.ProcKey',Self);
  case Key of
    K_F2: if lsHistory.Execute(s,RbStatus1) then begin
      Tree.BeginUpdate; Tree.Filtered:=false; SeekDir(s);
    end;
  	K_F3: begin
      i:=K_1+FltIndex;
      if dmFlt.Execute(@i) then begin
        FltIndex:=i-K_1; Tree.BeginUpdate; Tree.Filtered:=false; IniSave;
        try
          dir:=nmDir; Tree.IsFirst(tn);
          while Assigned(tn) do begin
            if NodeFileName(tn)<>'' then
              if not NodeNotFill(tn) then
                if NodeType(tn)=dntDir then begin
                  tn1:=tn.getFirstChild;
                  while Assigned(tn1) do begin
                    tn2:=tn1.getNextSibling;
                    if NodeType(tn1)<>dntDir then Tree.DeletePrim(tn1);
                    tn1:=tn2;
                  end;
                  NodeFill(tn,false);
                end;
            GetNextSelf(tn);
          end;
          IniRest;
          if not(tpiSelected in FIniOptions) then Tree.FirstSelect;
        finally
          SeekDir(dir);
        end;
        StatFlt;
      end;
    end;
    K_F4: begin
      dir:=RbStatus1.SectLeft[0]; s:=GetStrFile(dir);
      if EdTextExec('Редактирование файла: '+dir,s,'',nil,[],edtpText,0,0,'',0,nil,'',nil,nil,dir)
      then SetStrFile(dir,s);
    end;
    K_F7: begin
      tp:=NodeType(Tree.Selected);
      if tp<>dntNet then begin
        dir:=RbStatus1.SectLeft[0];
        if tp=dntFile then begin
          Rec['FILE']:=NodeFileName(Tree.Selected); ExtractFilePathSelf(dir);
        end
        else Rec['FILE']:='';
        deCreate.Param['FILE',deCaption]:=CorrDir(dir); deCreate.Execute;
      end;
    end;
    K_F8: begin
      tn:=Tree.Selected; dir:=FRootDir+RbStatus1.SectLeft[0];
      case NodeType(tn) of
        dntDir: s:=ArrayAsList(['При удалении папки ',dir,'будут удалены все файлы и папки, содержащиеся в ней.',
        'Переместить папку в корзину (Нет - удалить безвозвратно) ?'],CRLF);
        dntFile: s:=ArrayAsList(['Переместить файл',dir,' в корзину (Нет - удалить безвозвратно) ?'],CRLF);
      else s:='';
      end;
      if s<>'' then begin
        i:=AskCancel(s);
        if i<>mrCancel then begin
          DelNode(ExtractFilePath(dir),tn);
          if not IsNextSibling(tn,tn1) then tn1:=tn.GetNext;
          Tree.Selected:=tn1; ReloadList;
          if not Assigned(Tree.Selected) then Tree.FirstSelect;
        end;
      end;
    end;
  	K_F11: begin
      i:=K_1+byte(SortType);
      if dmSort.Execute(@i) then begin
        Tree.Filtered:=false; SortType:=TTreeDirSortType(i-K_1);
        if RootDir='' then begin
          Tree.IsFirst(tn);
          while Assigned(tn) do begin
            tn.CustomSort(nil,0,true); GetNextSelf(tn);
          end;
        end
        else Tree.CustomSort(nil,0);
        StatSort;
      end;
    end;
    K_Enter,K_Ctrl_Enter:
      if Assigned(Tree.Selected) then
        if AllowMultiSelect then begin
          s:=FRootDir+nmDir; ShellExecute(0,nil,PChar(s),nil,PChar(ExtractFilePath(s)),SW_SHOW); Key:=0;
        end
        else begin
          Directory:=nmDir(nil,Key=K_Ctrl_Enter);
          lsHistory.MoveUp(lsHistory.IndexOf(Directory),Directory);
        end
      else Key:=0;
  end;
  IfThenKeyProc(FProcSel,Key,tw);
  DelStack;
end;

procedure TTreeDir.StatSort;
begin
  AddStack('TTreeDir.StatSort',Self);
  RbStatus1.SectRight[0]:='по '+anmSort[SortType];
  DelStack;
end;

procedure TTreeDir.StatFlt;
var cnt: byte;
begin
  AddStack('TTreeDir.StatFlt',Self);
  with RbStatus1.SectRight do begin
    cnt:=StdSectRight+DopSectRight;
    while Count<cnt do Add('');
    while Count>cnt do Delete(Count-1);
    if dmFlt.Keys.Count>0 then Strings[1]:=DlmCopy(dmFlt.Keys[FltIndex],2,1,UnDelim);
  end;
  DelStack;
end;

function TTreeDir.StdSectRight;
begin
  AddStack('TTreeDir.StdSectRight',Self);
  result:=1+IfThen(dmFlt.Keys.Count>0,1);
  DelStack;
end;

function TTreeDir.GetIdent;
begin
  AddStack('TTreeDir.GetIdent',Self);
  result:=lsHistory.Ident;
  DelStack;
end;

procedure TTreeDir.SetIdent;
begin
  AddStack('TTreeDir.SetIdent',Self);
  lsHistory.Ident:=Value;
  DelStack;
end;

procedure TTreeDir.SetRootDir;
begin
  AddStack('TTreeDir.SetRootDir',Self);
  if Value='' then FRootDir:='' else FRootDir:=CorrDir(Value);
  DelStack;
end;

procedure TTreeDir.DirNodeAdd;
var tn: TTreeNode;
begin
  AddStack('TTreeDir.DirNodeAdd',Self);
  if Dop>0 then aNode[Dop].OriginalName:=IfThen(OriginalName='',txt,OriginalName);
  tn:=AddPrim(tnParent,AnsiUpperCase(txt),Prim,0,pointer(Dop));
  if Assigned(tn) then AddPrim(tn,'');
  DelStack;
end;

function TreeDirVar(const v: variant): TTreeDir;
begin
  result:=PointerVar(v);
end;

function NetServer(const av: array of variant; var NetResource: TNetResource): boolean;
var p: PTreeDirNode;
  n: longint;
begin
	AddStack('TreeDir.NetServer');
  result:=true;
  with NetResource,TreeDirVar(av[0]) do if dwDisplayType=RESOURCEDISPLAYTYPE_SERVER then begin
    n:=NewNode(dntNet,p);
    if Length(aNetResource)=lNetResource then SetLength(aNetResource,lNetResource shl 1);
    aNetResource[lNetResource]:=NetResource;
    with aNetResource[lNetResource] do begin
      lpLocalName:=StrNew(NetResource.lpLocalName);
      lpRemoteName:=StrNew(NetResource.lpRemoteName);
      lpComment:=StrNew(NetResource.lpComment);
      lpProvider:=StrNew(NetResource.lpProvider);
    end;
    p.NetResource:=lNetResource; Inc(lNetResource);
    DirNodeAdd(Copy(lpRemoteName,3,MaxInt),'компьютер',PointerVar(av[1]),'',n); dwUsage:=0;
  end;
  DelStack;
end;

function NetDrv(const av: array of variant; var NetResource: TNetResource): boolean;
var tn: TTreeNode;
begin
	AddStack('TreeDir.NetDrv');
  result:=true;
  with NetResource do if (dwUsage and RESOURCEUSAGE_CONNECTABLE)=RESOURCEUSAGE_CONNECTABLE then begin
    tn:=PointerVar(av[1]);
    TreeDirVar(av[0]).DirNodeAdd(Copy(lpRemoteName,Length(tn.Text)+4,MaxInt),'сетевой диск',tn);
  end;
  DelStack;
end;

function PrimDirFile(p: PTreeDirNode): string;
var ost: longint;
begin
  ost:=AddStack('TreeDir.PrimDirFile');
  try
    result:=FormatDateTime('dd/mm/yyyy (hh:nn:ss)',FileDateToDateTime(p.Time));
    if p.Size>=0 then IncD(result,' '+FmtNum(p.Size,TreeDirPrmSize));
  except
    SetStack(ost);
    result:=ArrayAsList(['??','??','????'],DateSeparator)+' ('+ArrayAsList(['??','??','??'],TimeSeparator)+')';
  end;
  DelStack;
end;

procedure PrDirAdd(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
var p: PTreeDirNode;
  n: longint;
begin
	AddStack('TreeDir.PrDirAdd');
  with TreeDirVar(av[0]) do begin
    n:=NewNode(dntDir,p); p.Time:=sr.Time; DirNodeAdd(sr.Name,PrimDirFile(p),PointerVar(av[1]),av[2],n);
  end;
  DelStack;
end;

procedure PrFileAdd(const av: array of variant; const sr: TSearchRec; var lDone: boolean);
var p: PTreeDirNode;
  s: string;
  n: longint;
begin
	AddStack('TreeDir.PrFileAdd');
  with TreeDirVar(av[0]) do begin
    n:=NewNode(dntFile,p,GetFileSize(sr)); p.Time:=sr.Time; s:=sr.Name; p.OriginalName:=s;
    if FHideExt then FileWithOutExtSelf(s);
    AddPrim(PointerVar(av[1]),AnsiLowerCase(s),PrimDirFile(p),0,pointer(n));
  end;
  DelStack;
end;

procedure TTreeDir.NodeFill;
  function NodeDirFile(Node: TTreeNode; var p: PTreeDirNode): boolean;
  begin
    AddStack('TTreeDir.NodeFill.NodeDirFile',Self);
    if NodeInf(Node,p) then result := p.tp in [dntDir,dntFile] else result:=false;
    DelStack;
  end;
var dir: string;
  a: TArrStr;
	i: longint;
  tn: TTreeNode;
  p,pd: PTreeDirNode;
begin
  AddStack('TTreeDir.NodeFill',Self);
  if Assigned(Node) and (NodeType(Node)=dntNet) then begin
    i:=NodeInf(Node).NetResource;
    if i>0 then
      if aNetResource[i].dwDisplayType=RESOURCEDISPLAYTYPE_DOMAIN
      then ProcNetRes(NetServer,[LongInt(Self),LongInt(Node)],RESOURCE_GLOBALNET,@aNetResource[i])
      else ProcNetRes(NetDrv,[LongInt(Self),LongInt(Node)],RESOURCE_GLOBALNET,@aNetResource[i])
    else ProcNetRes(NetServer,[LongInt(Self),LongInt(Node)]);
    Tree.TopItem:=Node;
  end
  else begin
    if Assigned(Node) then dir:=nmDir(Node) else dir:='';
    if WithDir then MaskFilesProc(RootDir+dir+'*.*',PrDirAdd,[LongInt(Self),LongInt(Node),dir],[fmDir]);
    if Assigned(FOpenDialog) then begin
      if dmFlt.Keys.Count=0 then begin
        i:=1; CopyFrom(a,'*.*')
      end
      else i:=LsArrDynamic(aFlt[FltIndex],a,';');
      for i:=0 to i-1 do MaskFilesProc(RootDir+dir+a[i],PrFileAdd,[LongInt(Self),LongInt(Node)]);
    end;
    if Assigned(Node) then begin
      Node.CustomSort(nil,0);
      while Assigned(Node) do begin
        if NodeDirFile(Node,pd) then begin
          tn:=Node.getFirstChild; pd.Size:=0;
          while Assigned(tn) do begin
            if NodeDirFile(tn,p) then
              if p.Size>=0 then Inc(pd.Size,p.Size);
            GetNextSiblingSelf(tn);
          end;
          Tree.NodeInf(Node).Prim:=PrimDirFile(pd);
        end;
        ParentSelf(Node);
      end;
    end
    else Tree.CustomSort(nil,0,false);
  end;
  DelStack;
end;

function TTreeDir.nmDir;
var s: string;
begin
  AddStack('TTreeDir.nmDir',Self);
  Tree.DefSelected(tn); result:='';
  if DlmEnd then DlmEnd := not NodeFile(tn);
  while Assigned(tn) do begin
    s:=NodeFileName(tn);
    if NodeType(tn)=dntNet then if NodeInf(tn).NetResource=0 then s:='\';
    IncL(result,s+PathDelim); ParentSelf(tn);
  end;
  if not DlmEnd then CorrDirSelf(result,[crdrNoDlmEnd,crdrNoUpper]);
  DelStack;
end;

procedure TTreeDir.IniSave;
begin
  AddStack('TTreeDir.IniSave',Self);
  if Tree.IsFirst then Tree.SaveToIni(FSectIni,FIniOptions);
  DelStack;
end;

procedure TTreeDir.IniRest;
begin
  AddStack('TTreeDir.IniRest',Self);
  Tree.RestFromIni(FSectIni,FIniOptions);
  DelStack;
end;

function TTreeDir.SeekDir;
var s,s1: string;
	tn,tnSel: TTreeNode;
  i,l1: longint;
  a,a1: TArrStr;
  fl,fl1: boolean;
begin
  AddStack('TTreeDir.SeekDir',Self);
  tnSel:=nil; 
  if not empty(Directory) then begin
    s:=AnsiUpperCase(ExtractFileDrive(Directory)); fl:=IsNetDrive(s);
  	if RootDir='' then begin
      Tree.IsFirst(tn);
      while Assigned(tn) do begin
        case NodeType(tn) of
          dntMyDoc: begin
            s1:=NodeInf(tn).OriginalName;
            l1:=LsArrDynamic(AnsiUpperCase(s1),a1,PathDelim);
            if LsArrDynamic(AnsiUpperCase(Directory),a,PathDelim)>=l1 then begin
              fl1:=true;
              for i:=0 to l1-1 do
                if a[i]<>a1[i] then begin
                  fl1:=false; break;
                end;
              if fl1 then begin
                tnSel:=tn; s:=s1; fl:=true; break;
              end;
            end;
          end;
          dntNet: if fl then begin
            tnSel:=tn; s:='\'; break;
          end;
        end;
        GetNextSelf(tn);
      end;
    end
    else s:=AnsiUpperCase(DlmCopy(Directory,1,1,PathDelim));
    if not fl then begin
      Tree.IsFirst(tn);
      while Assigned(tn) do begin
        if NodeType(tn)<>dntNet then
          if AnsiUpperCase(NodeFileName(tn))=s then begin
            tnSel:=tn; break;
          end;
        GetNextSelf(tn);
      end;
    end;
    if Assigned(tnSel) then
      for i:=0 to LsArrDynamic(AnsiUpperCase(Copy(Directory,Length(s)+2,MaxInt)),a,PathDelim)-1 do begin
      	if a[i]='' then break;
        tnSel.Expand(false); fl:=true; tn:=tnSel.getFirstChild;
        while Assigned(tn) do
          if AnsiUpperCase(NodeFileName(tn))=a[i] then begin
            fl:=false; tnSel:=tn; break;
          end
          else GetNextSiblingSelf(tn);
        if fl then break;
      end;
  end;
  Tree.EndUpdate; result:=Assigned(tnSel);
  if result and not(tpiSelected in FIniOptions) then Tree.Selected:=tnSel;
  DelStack;
end;

procedure TTreeDir.RbStatus1Click;
const a: array[TRBSTSectType,0..1] of longint = ((K_F2,0),(K_F11,K_F3));
var key: longint;
begin
  AddStack('TTreeDir.RbStatus1Click',Self);
  with RbStatus1 do if Cursor=crHandPoint then begin
  	with MouseInfo do key:=a[SectType,SectNum];
    if (key<>0) and Active then KeyLb1.ExecKey(key);
  end;
  DelStack;
end;

procedure TTreeDir.RbStatus1MouseMove;
var inf: TRBSTMouseInfo;
begin
	AddStack('TTreeDir.RbStatus1MouseMove',Self);
  with RbStatus1 do begin
    inf:=MouseInfo;
    Cursor:=IfThen((inf.SectType=mstLeft) and (inf.SectNum=0) and (lsHistory.Count>0)
    	or (inf.SectType=mstRight) and ((inf.SectNum=0)
    	or (inf.SectNum=1) and (dmFlt.Keys.Count>1)),crHandPoint,crDefault);
  end;
  DelStack;
end;

procedure TTreeDir.TreeChange;
var lFile,lSel: boolean;
begin
  AddStack('TTreeDir.TreeChange',Self);
  RbStatus1.SectLeft[0]:=nmDir(nil,false);
  if Assigned(FOpenDialog) and Active then begin
    lFile:=NodeFile(Tree.Selected); lSel := ofAllowMultiSelect in FOpenDialog.Options;
    SetKey(K_Enter,IfThen(lSel,'Открыть','Выбор'),'','treedir',kmList,lFile);
    SetKey(K_Ctrl_Enter,'Выбор папки','','treedirfile',kmList,not lFile and not lSel);
    SetKey(K_F4,'Редактировать','','treedirfile',kmList,(dtoCanEdit in FOptions) and lFile);
    KeyLb1.ReDrw;
  end;
  DelStack;
end;

procedure TTreeDir.TreeCompare;
  procedure CompTxt(const s1,s2: string);
  begin
    AddStack('TTreeDir.TreeCompare.CompTxt',Self);
    Compare:=CompSign(StrTran(s1,'_',#0),StrTran(s2,'_',#0));
    DelStack;
  end;
var p1,p2: PTreeDirNode;
begin
  AddStack('TTreeDir.TreeCompare',Self);
  if Assigned(Node1.Data) then begin
    Compare:=byte(NodeFile(Node1))-byte(NodeFile(Node2));
    if Compare=0 then begin
	  	p1:=NodeInf(Node1); p2:=NodeInf(Node2);
      if Assigned(p1) and Assigned(p2) then case SortType of
        dstExt: CompTxt(ExtractFileExt(p1.OriginalName),ExtractFileExt(p2.OriginalName));
        dstTime: Compare:=p2.Time-p1.Time;
        dstSize: Compare:=CompSign(p2.Size,p1.Size);
      end;
    end;
  end
  else Compare:=0;
  if Compare=0 then CompTxt(Node1.Text,Node2.Text);
  DelStack;
end;

procedure TTreeDir.TreeExpanding;
var dir: string;
  tn: TTreeNode;
begin
  AddStack('TTreeDir.TreeExpanding',Self);
  if AllowExpansion then if NodeNotFill(Node) then begin
    if NodeType(Node)<>dntNet then begin
      dir:=RootDir+nmDir(Node); AllowExpansion:=DiskReady(dir);
      if AllowExpansion then AllowExpansion:=DirectoryExists(dir);
      if not AllowExpansion then mess_ok(['Ошибка доступа к папке:',dir]);
    end;
    if AllowExpansion then begin
      Tree.BeginUpdate; tn:=Node.getFirstChild; NodeFill(Node); Tree.DeletePrim(tn); Tree.EndUpdate;
    end;
  end;
  DelStack;
end;

procedure TTreeDir.TreeExpanded;
var p: PPrimNodeInf;
begin
	AddStack('TTreeDir.TreeExpanded',Self);
  if NodeType(Node)=dntFloppy then begin
    p:=Tree.NodeInf(Node); IncD(p.Prim,DrvLabelBrack(NodeFileName(Node))); p.Dop:=nil;
  end;
  DelStack;
end;

procedure TTreeDir.TreeChecking;
var tn: TTreeNode;
  omsg,AllowExpansion: boolean;
begin
  AddStack('TTreeDir.TreeChecking',Self);
  if Node.HasChildren then begin
    Allowed:=Ask([IfThen(Value,'Отметить все файлы','Снять отметку со всех файлов')+' в папке',nmDir(Node)+' ?']);
    if Allowed then begin
      omsg:=MessagesHidden; MessagesHidden:=true;
      AllowExpansion:=true; TreeExpanding(Tree,Node,AllowExpansion); tn:=Node.GetFirstChild;
      while Assigned(tn) do begin
        Tree.Checked[tn]:=Value; GetNextSiblingSelf(tn);
      end;
      MessagesHidden:=omsg;
    end;
  end;
  DelStack;
end;

procedure TTreeDir.TreeChecked;
var tn: TTreeNode;
  oChecking: TTreeCheckingEvent;
  ChkChild,CngChkChild: boolean;
  p: PTreeDirNode;
begin
  AddStack('TTreeDir.TreeChecked',Self);
  Tree.BeginUpdate;
  oChecking:=Tree.OnChecking; Tree.OnChecking:=nil; ChkChild:=false; CngChkChild:=false;
  while ParentSelf(Node) do begin
    tn:=Node.getFirstChild;
    while Assigned(tn) do begin
      if tn.Text<>'' then begin
        if Tree.Checked[tn] then ChkChild:=true else Value:=false;
      end;
      GetNextSiblingSelf(tn);
    end;
    Tree.Checked[Node]:=Value;
    if NodeInf(Node,p) then if p.IsChkChild<>ChkChild then begin
      CngChkChild:=true; p.IsChkChild:=ChkChild;
    end;
  end;
  Tree.OnChecking:=oChecking;
  if CngChkChild then Tree.Invalidate;
  Tree.EndUpdate;
  DelStack;
end;

procedure TTreeDir.TreeCustomDrawItem;
var p: PTreeDirNode;
begin
  AddStack('TTreeDir.TreeCustomDrawItem',Self);
  if NodeInf(Node,p) then if p.IsChkChild then
    if Node.Selected
    then Tree.Canvas.Font.Color:=Color
    else Tree.Canvas.Brush.Color:=Color;
  DelStack;
end;

procedure TTreeDir.dmSortFrmShow;
begin
  AddStack('TTreeDir.dmSortFrmShow',Self);
  TFormDefMn(Sender).dMenu.KeyVisible[K_1+byte(dstSize)]:=Assigned(FOpenDialog);
  dmShow(Sender,0);
  DelStack;
end;

procedure TTreeDir.dmShow;
var r: TRect;
	inf: TRBSTMouseInfo;
  p: TPoint;
  f: TFormDefMn;
begin
  AddStack('TTreeDir.dmShow',Self);
  inf.SectType:=mstRight; inf.SectNum:=SectNum; r:=RbStatus1.SectRect(inf); p:=RbStatus1.ClientOrigin;
  f:=TFormDefMn(Sender); f.SetBounds(p.X+r.Left,p.Y-f.Height,f.Width,f.Height); f.FormOnScreen;
  DelStack;
end;

procedure TTreeDir.dmFltFrmShow;
begin
	AddStack('TTreeDir.dmFltFrmShow',Self);
  dmShow(Sender,1);
  DelStack;
end;

class procedure TTreeDir.deCreatePnlCngKey;
begin
  AddStack('TTreeDir.deCreatePnlCngKey');
  with tb do case Key of
    K_F10: Caption:='';
    K_Enter: begin
      Caption:='Создать'; Part:=kmFile;
    end;
  end;
  DelStack;
end;

function TTreeDir.deCreatePnlValid;
var dir,fn: TFileName;
  ost: longint;
  tn,tn1: TTreeNode;
begin
  ost:=AddStack('TTreeDir.deCreatePnlValid',Self);
  fn:=Rec['FILE']; result:=not empty(fn);
  if result then begin
    dir:=deCreate.Param['FILE',deCaption]; result:=DiskReady(dir);
    if result then begin
      FileNameExtSelf(fn,FOpenDialog.DefaultExt); result:=not FileExists(dir+fn);
      if result then begin
        try
          TFileBufStream.Create(dir+fn,fmCreate).Free;
        except
          SetStack(ost);
        end;
        result:=FileExists(dir+fn);
        if result then begin
          IniSave; Tree.BeginUpdate;
          try
            tn:=Tree.Selected;
            if NodeFile(tn) then ParentSelf(tn);
            repeat
              tn1:=tn.getFirstChild;
              if Assigned(tn1) then Tree.DeletePrim(tn1) else break;
            until false;
            NodeFill(tn); IniRest; fn:=AnsiUpperCase(fn); GetFirstChildSelf(tn);
            while Assigned(tn) do
              if AnsiUpperCase(NodeFileName(tn))=fn then begin
                Tree.Selected:=tn; break;
              end
              else GetNextSiblingSelf(tn);
          finally
            Tree.EndUpdate;
          end;
        end
        else MsgDlg(['Ошибка создания файла:',dir+fn]);
      end
      else meserr('Такой файл уже существует.');
    end
    else MsgDlg(['Ошибка доступа к папке:',dir]);
  end;
  DelStack;
end;

procedure TTreeDir.ReloadList;
begin
  AddStack('TTreeDir.ReloadList',Self);
  DoExit; Modified:=true; DoEnter;
  DelStack;
end;

procedure TTreeDir.SetKey;
var tb: TKeyBut;
begin
  AddStack('TTreeDir.SetKey',Self);
  tb.Key:=key; tb.Caption:=txt; tb.Hint:=hnt; tb.Part:=Part;
  if Assigned(FOnCngKey) then FOnCngKey(Self,Allowed,tb);
  if Allowed
  then KeyLb1.SetKey(tb.key,tb.Caption,tb.Hint,ProcKey,nmPr,tb.Part)
  else KeyLb1.DelKey(tb.key,nmPr);
  DelStack;
end;

function TTreeDir.AddPrim;
var Allowed: boolean;
  TextNode,Prim: string;
begin
  AddStack('TTreeDir.AddPrim',Self);
  Allowed:=true; TextNode:=cTextNode; Prim:=cPrim;
  if Assigned(FOnAddPrim) then FOnAddPrim(Allowed,Node,TextNode,Prim,cHelpContext,Dop);
  if Allowed then begin
    result:=Tree.AddPrim(Node,TextNode,Prim,cHelpContext,Dop); IfThenNotify(FOnAddedPrim,result);
  end
  else result:=nil;
  DelStack;
end;

function TTreeDir.NodeInf(Node: TTreeNode; var p: PTreeDirNode): boolean;
var n: longint;
  pp: PPrimNodeInf;
begin
  AddStack('TTreeDir.NodeInf',Self);
  n:=0;
  if Assigned(Node) then if Tree.NodeInf(pp,Node) then n:=longint(pp.Dop);
  result := n>0; p:=@aNode[n];
  DelStack;
end;

function TTreeDir.NodeInf(Node: TTreeNode): PTreeDirNode;
begin
  NodeInf(Node,result);
end;

function TTreeDir.NodeType;
var p: PTreeDirNode;
begin
  AddStack('TTreeDir.NodeType',Self);
  if NodeInf(Node,p) then result:=p.tp else result:=dntDir;
  DelStack;
end;

function TTreeDir.NodeFile;
begin
  AddStack('TTreeDir.NodeFile',Self);
  result := NodeType(Node)=dntFile;
  DelStack;
end;

function TTreeDir.NewNode(tp: TTreeDirNodeType; sz: Int64 = -1): longint;
begin
  AddStack('TTreeDir.NewNode',Self);
  if Length(aNode)=lNode then SetLength(aNode,lNode shl 1);
  aNode[lNode].tp:=tp; aNode[lNode].Size:=sz; aNode[lNode].IsChkChild:=false; result:=lNode; Inc(lNode);
  DelStack;
end;

function TTreeDir.NewNode(tp: TTreeDirNodeType; var p: PTreeDirNode; sz: Int64 = -1): longint;
begin
  result:=NewNode(tp,sz); p:=@aNode[result];
end;

function TTreeDir.NodeFileName(Node: TTreeNode): string;
begin
  AddStack('TTreeDir.NodeFileName',Self);
  result:=NodeFileName(Node.Text,Tree.NodeInf(Node).Dop,false);
  DelStack;
end;

function TTreeDir.NodeFileName(const Text: string; Dop: Pointer; DlmEnd: boolean): string;
var p: PTreeDirNode;
begin
  AddStack('TTreeDir.NodeFileName(Dop)',Self);
  if Assigned(Dop) then begin
    p:=@aNode[longint(Dop)]; result:=p.OriginalName;
    if (p.tp<>dntFile) and DlmEnd then IncD(result,PathDelim);
  end
  else result:=Text;
  DelStack;
end;

function TTreeDir.AllowMultiSelect: boolean;
begin
  AddStack('TTreeDir.AllowMultiSelect',Self);
  if Assigned(FOpenDialog) then result := ofAllowMultiSelect in FOpenDialog.Options else result:=false;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurLib',[TTreeDir]);
end;

initialization
  AddStack('TreeDir.initialization');
  TreeDirPrmSize:=FmtNum; TreeDirPrmSize.FracCnt:=0; TreeDirPrmSize.DigDlm:=''''; TreeDirPrmSize.DigIsDlm:=true;
  DelStack;
end.

