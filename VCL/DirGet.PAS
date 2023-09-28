unit DirGet;

interface

{$I LIBTEST}
uses
  Windows,SysUtils,Classes,Controls,Dialogs,
  MyTypes,RecVal,FFldedit,CCodeGet,PaintCtl;

type
	TDirGetOptions = set of (dgServerName,dgCreatePrompt,dgNoCheckDir);

  TDirGet = class(TCustomCodeGet)
  private
    { Private declarations }
    FOpenDialog: TOpenDialog;
    FOptions: TDirGetOptions;
    FItems: TStrings;
		procedure ItemsChange(Sender: TObject);
		procedure KeyProcList(key: longint; tw: TWinControl);
    class procedure ListClick(Sender: TObject);
    procedure SetItems(Value: TStrings);
    procedure SetOpenDialog(Value: TOpenDialog);
    procedure SetOptions(Value: TDirGetOptions);
  protected
    { Protected declarations }
    sL: TPaintButton;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    function Check(tf: TFldEdit): boolean; override;
		procedure DoEnter(tf: TFldEdit); override;
    function AssignObj(tf: TFldEdit): boolean; override;
    procedure StdListDown(tf: TFldEdit; const RectList: TRect; PozList: TPozList); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
  public
    { Public declarations }
		constructor Create(AOwner: TComponent = nil); override;
		destructor Destroy; override;
		procedure MaskPrn(const Mask: string; LsPrn: TStringList); override;
    procedure IncOptions(Incl: TDirGetOptions; Excl: TDirGetOptions = []);
  published
    { Published declarations }
    property Items: TStrings read FItems write SetItems;
    property OpenDialog: TOpenDialog read FOpenDialog write SetOpenDialog;
    property Options: TDirGetOptions read FOptions write SetOptions;
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

{ $IFDEF OLDDIR
function MySelectDirectory(const Caption: string; const Root: WideString;
  var Directory: string): Boolean;
{$ENDIF}
procedure Register;

implementation

uses Forms,Variants,Math,StrUtils,
  My_pr,ListF2,Askp,KeyLb,FStat,BufFile,TreeDir;

//var oWndProc: longint;

const SectBeg = 'DirGet.';

procedure StCopyFile(Sender: TStat; const Params: array of variant; var Aborted: boolean);
const szBlock = 64*KByte;
var	s,st: string;
  fi,fo: TFileBufStream;
  ost,l,b: longint;
  sz,lr,i: Int64;
  Prm: TFmtNum;
begin
	ost:=AddStack('DirGet.StCopyFile');
  fi:=PointerVar(Params[0]); fo:=PointerVar(Params[1]);
  sz:=Params[2]; lr := max(1,Ceil(sz div szBlock)); i:=1; b:=min(sz,szBlock); SetLength(s,b);
  l:=0; // Variable might not have been initialized
  Prm:=FmtNum; Prm.FracCnt:=0; Prm.DigIsDlm:=true; st:='Скопировано: %s из '+FmtNum(sz,Prm)+' байт';
  try
    repeat
      if Sender.SayStat('',Format(st,[FmtNum(i*szBlock,Prm)]),i/lr) then begin
        SetPBoolean(Params[3],true); break;
      end;
      Inc(i); l:=fi.Read(pointer(s)^,b);
      if l>0 then
        if fo.Write(pointer(s)^,l)<>l then begin
          Aborted:=true; break;
        end;
    until l<=0;
  except
  	on EWriteError do begin
	    SetStack(ost);
      Aborted:=true;
    end;
  end;
  DelStack;
end;

function CopyFileOpt(const fFrom,fTo: TFileName; Options: TCopyFileOptions = []; Attr: longword = 0;
  UserAbort: PBoolean = nil; const Capt: TCaption = ''): boolean;
var fi,fo: TFileBufStream;
  ost: longint;
  i: Int64;
  s: string;
  fl: boolean;
  d: TDateTime;
begin
	ost:=AddStack('DirGet.CopyFileOpt');
  result := TrimUpper(fFrom)=TrimUpper(fTo);
  if not result then begin
    if not(cfStat in Options) then
      if (cfNoEsc in Options) or IsFlopDrive(fTo) then Include(Options,cfStat);
    for fl:=false to true do begin
      if fl then
        if MyFileExists(fTo) then
          if not DelFileAtr(fTo) then break;
      if cfStat in Options then begin
        d:=DateEmpty; fi:=nil; fo:=nil;
        try
          try
            fi:=TFileBufStream.Create(fFrom,fmOpenRead or fmShareDenyWrite);
            fo:=TFileBufStream.Create(fTo,fmCreate);
            i:=fi.Size; d:=GetFileDateTime(fFrom);
            if i=0 then result:=true
            else result:=not ShowStat(IfThen(Capt='','Копирование файла '+fFrom,Capt),
              StCopyFile,[LongInt(fi),LongInt(fo),i,Longint(UserAbort)],
              i,MByte,not(cfNoEsc in Options));
            if result then result:=fo.Update;
          except
            on EFCreateError do begin
              SetStack(ost);
              result:=false;
            end;
            on EFOpenError do begin
              SetStack(ost);
              result:=false;
            end;
          end;
        finally
          fi.Free; fo.Free;
        end;
        if not result then DelFileAtr(fTo)
        else if not empty(d) then SetFileDateTime(fTo,d);
        break;
      end
      else result:=CopyFile(PChar(fFrom),PChar(fTo),false);
      if result then break;
    end;
    if result and not(cfNoSetAttr in Options) then FileClrAttr(fTo,Attr);
    if not result and (cfMsg in Options) then begin
      s:=ExtractFileName(fFrom);
      if AnsiUpperCase(s)=AnsiUpperCase(ExtractFileName(fTo))
      then MsgDlg(['Ошибка копирования файла: '+s,
        'из папки: '+ExtractFilePath(fFrom),'в папку: '+ExtractFilePath(fTo)])
      else MsgDlg(['Ошибка копирования файла:','из '+fFrom,'в '+fTo]);
    end;
  end;
  DelStack;
end;

procedure StCopyFiles(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i,j,lr,l,h: longint;
	nmf: variant;
  lVer: boolean;
begin
	AddStack('DirGet.StCopyFiles');
  nmf:=Params[2]; l:=VarArrayLowBound(nmf,1); h:=VarArrayHighBound(nmf,1);
  j:=1; lr:=h-l+1; lVer:=IsNil(Params[0]);
  for i:=l to h do begin
  	if Sender.SayStat('',nmf[i],j/lr) then break;
    if lVer then begin
      if not FileVerCopy(Params[1]+nmf[i]) then begin
        mess_ok(['Внимание! На дискете есть сбои.','','Воспользуйтесь другой дискетой.']);
        Aborted:=true;
      end;
    end
    else if not CopyFileOpt(Params[0]+nmf[i],Params[1]+nmf[i],[cfStat]) then begin
    	Aborted:=true; break;
    end;
  	Inc(j);
  end;
  DelStack;
end;

function DiskWait(const cpTo,cpFrom: TFileName; const cnmf: variant; Opt: TDiskWaitOpt = []): boolean;
  function NoDir(const dir: TFileName; var res: boolean): boolean;
  var drv: TFileName;
  begin
    AddStack('DirGet.DiskWait.NoDrv');
    res:=DiskReady(dir);
    if res then res:=DirectoryExists(dir);
    result:=not res;
    if result then
      if GetLastError in [ERROR_ACCESS_DENIED,ERROR_NOT_READY] then begin
        drv:=ExtractFileDrive(dir);
        if GetDriveType(PChar(drv))=DRIVE_REMOVABLE
        then result:=not Ask(['Вставьте дискету в дисковод '+drv,'Продолжить ?'])
        else meserr('Нет доступа к диску '+drv);
      end
      else mess_ok(['Отсутствует папка:',dir]);
    DelStack;
  end;
var l,h: longint;
  nmf: TArrStr;
  function FExists(const path: string; lmsg: boolean): boolean;
	var i: longint;
  begin
    AddStack('DirGet.DiskWait.FExists');
    result:=true;
    for i:=l to h do
      if not MyFileExists(path+nmf[i]) then begin
      	if lmsg then mess_ok(['Отсутствует файл:',path+nmf[i]]);
        result:=false; break;
      end;
    DelStack;
  end;
  function FSize(const path: string): Int64;
  begin
    AddStack('DirGet.DiskWait.FSize');
    result:=GetFileSize(path,nmf);
    DelStack;
  end;
var pTo,pFrom,drvTo: TFileName;
  sz,sz1: Int64;
  i: longint;
  s: string;
  flopTo: boolean;
begin
  AddStack('DirGet.DiskWait');
  if not(empty(cpTo) or empty(cpFrom)) and empty(cnmf) then result:=CopyFileOpt(cpFrom,cpTo,[cfStat,cfMsg])
  else begin
    result:=false; CopyFromVar(nmf,cnmf); l:=low(nmf); h:=high(nmf); pTo:=CorrDir(cpTo); pFrom:=CorrDir(cpFrom); drvTo:=ExtractFileDrive(pTo);
    while not result do begin
      if NoDir(pTo,result) then break;
      if empty(cnmf) then break;
      if NoDir(pFrom,result) then break;
      if result then begin
        result:=FExists(pFrom,true);
        if not result then break;
        flopTo:=IsFlopDrive(pTo);
        if not flopTo then Exclude(Opt,dskwXDel);
        if dskwXDel in Opt then begin
          i:=CntMaskFiles(pTo+'*.*',[fmFiles,fmDir]);
          result := (i=0) or FExists(pTo,false) and (i=h-l+1);
          if result then begin
            sz:=FSize(pFrom); sz1:=MyDiskFree(pTo)+FSize(pTo);
            result := (sz1<>MyDiskFree(pTo,true)) or (sz1>=sz);
            if not result
            then s:='На диске '+drvTo+Format(' необходимо не менее %d байт для копирования.',[sz]);
          end
          else s:='Дискета '+drvTo+' не пустая.';
        end
        else begin
          sz:=FSize(pFrom)-FSize(pTo); result := MyDiskFree(pTo)>=sz;
          if not result
          then s:='На диске '+drvTo+Format(' необходимо не менее %d байт для копирования.',[sz]);
        end;
        if result then begin
          result:=not ShowStat('Копирование',StCopyFiles,[pFrom,pTo,nmf],h,l+1);
          if result then begin
            if (dskwVer in Opt) and flopTo then begin
              result:=Ask(['Для проверки записи на дискету',
                'желательно достать дискету из дисковода '+drvTo,
                'и вставить её обратно.','','Продолжить ?']);
              if result
              then result:=not ShowStat('Проверка копирования',StCopyFiles,[null,pTo,nmf],h,l+1)
              else break;
            end;
          end
          else begin
          	if l=h then s:='Не удалось скопировать файл:'+CRLF+'из '+pFrom+nmf[l]+CRLF+'в '+pTo+nmf[l]
            else s:='Не удалось скопировать файлы:'+CRLF+'из '+pFrom+CRLF+'в '+pTo;
            if flopTo then begin
              if not ask([s,'Возможен сбой на дискете.','Воспользоваться другой дискетой ?']) then break;
            end
            else begin
              meserr(s); break;
            end;
          end;
        end
        else if flopTo then begin
          sz:=AskCancel([s,
            'Можно воспользоваться данной дискетой или другой.',
            'В первом случае все файлы на дискете будут удалены.','',
            'Воспользоваться данной дискетой ?']);
          case sz of
            mrCancel: break;
            mrYes: if not DirXDel(pTo) then
              if not Ask(['Ошибка удаления всех файлов на дискете.',
              'Возможно, на дискете установлена зашита от записи.',
              'Снимите защиту или вставьте другую дискету в дисковод '+drvTo,'Продолжить ?'])
              then break;
            mrNo: if not Ask(['Вставьте другую дискету в дисковод '+drvTo,'Продолжить ?'])
              then break;
          end;
        end
        else meserr(s);
      end;
    end;
  end;
  DelStack;
end;

{ TDirGet }
constructor TDirGet.Create;
begin
	AddStack('TDirGet.Create');
	inherited Create(AOwner);
  FItems:=TStringList.Create; TStringList(FItems).OnChange:=ItemsChange; Options:=[dgCreatePrompt];
  DelStack;
end;

destructor TDirGet.Destroy;
begin
	AddStack('TDirGet.Destroy',Self);
  FItems.Free;
  inherited Destroy;
  DelStack;
end;

procedure TDirGet.CreateObj;
begin
	AddStack('TDirGet.CreateObj',Self);
	inherited CreateObj(tf);
  eN.TrimLeft:=true;
  if not Assigned(bDyn) then begin
    if FItems.Count>0 then begin
      sL:=TPaintButton.Create(tf);
      with sL do begin
        Canvas:=tf.Canvas; Hint:='Cписок'; ShowHint:=true;
        BMByName(Glyph,bmDown_List); onClick:=ListClick;
      end;
    end;
    sD.Hint:=IfThen(not(dgServerName in FOptions),'Обзор');
  end;
  tf.ReCreateObj;
  DelStack;
end;

procedure TDirGet.ReCreateObj;
begin
	AddStack('TDirGet.ReCreateObj',Self);
	if AssignObj(tf) then begin
  	eC.Visible:=false; eN.Visible:=true;
    eN.AutoSelect := ogAutoSelect in tf.Options;
    eN.ReadOnly := (ogReadOnly in tf.Options) or Assigned(bDyn);
	  inherited ReCreateObj(tf);
    if Assigned(sD) then
      if sD.Visible and (dgServerName in FOptions) then begin
        sD.Visible:=false;
        with tf do SetBounds(Left,Top,Width,Height);
      end;
  end;
  DelStack;
end;

function TDirGet.SizeAuto;
var f: TFld;
begin
	AddStack('TDirGet.SizeAuto',Self);
	f:=RecFldName(tf.NameRec,tf.NameRecFld);
  if Assigned(f) then FDefLenName:=f.Info.Size else FDefLenName:=0;
  if AssignObj(tf) then eN.MaxLength:=FDefLenName;
  result := inherited SizeAuto(tf,Opt);
  DelStack;
end;

function TDirGet.GetValue;
begin
	AddStack('TDirGet.GetValue',Self);
	AssignObj(tf); result:=IfThenGetText(eN);
  DelStack;
end;

procedure TDirGet.SetValue;
begin
	AddStack('TDirGet.SetValue',Self);
	if AssignObj(tf) then begin
    eN.Text:=TrimRight(v); eN.SelAll;
  end;
  DelStack;
end;

function TDirGet.Check;
var path: TFileName;
	procedure Exists;
  begin
  	AddStack('TDirGet.Check.Exists',Self);
  	SetLastError(0);
    if Assigned(FOpenDialog) then result:=MyFileExists(path) else result:=DirectoryExists(path);
    DelStack;
  end;
var ms: string;
begin
	AddStack('TDirGet.Check',Self);
	result := inherited Check(tf);
  if not((dgServerName in FOptions) or (dgNoCheckDir in FOptions)) and result then begin
    path:=DlmCopy(tf.Mask,2,1,UnDelim);
  	path:=IfThen(not empty(path),CorrDir(path))+tf.Value;
  	if not Assigned(FOpenDialog) then CorrDirSelf(path);
    result := path='';
	  if not result then begin
    	Exists;
      if not result and (ExtractFileDrive(path)='') then begin
      	IncL(path,ExeDir); Exists;
      end;
      if not result then begin
      	if GetLastError in [ERROR_ACCESS_DENIED,ERROR_NOT_READY] then begin
        	ExtractFileDriveSelf(path);
        	meserr(IfThen(GetDriveType(PChar(path))=DRIVE_REMOVABLE,
          	'Вставьте дискету в дисковод '+path,
          	'Нет доступа к диску '+path));
          tf.Change(tf.Value,false);
        end
        else begin
          ms:='Отсутствует '+IfThen(Assigned(FOpenDialog),'файл','папка')+':';
          if dgCreatePrompt in FOptions then begin
            result:=Ask([ms,path,'Создать ?']);
            if result then
              if Assigned(FOpenDialog) then begin
                result:=ForceDirMsg(ExtractFilePath(path));
                if result then TFileBufStream.Create(path,fmCreate).Free;
              end
              else result:=ForceDirMsg(path);
          end
          else mess_ok([ms,path]);
        end;
      end;
  	end;
  end;
  DelStack;
end;

procedure TDirGet.DoEnter;
var tl: TKeyLb;
begin
	AddStack('TDirGet.DoEnter',Self);
	inherited DoEnter(tf);
  GetParentForm(tf).ActiveControl:=eN;
  if FormKeyLb(tf,tl) and not((ogReadOnly in tf.Options) or Assigned(bDyn)) then begin
  	if FItems.Count>0 then tl.SetKey(K_F3,'Список','',KeyProcList,'custlistget',kmEdit);
    tl.SetKey(K_Shift_F2,'','Список ранее выбранных '+IfThen(Assigned(FOpenDialog),'файлов','папок'),KeyProcList,'custlistget',kmEdit);
  	tl.ReDrw;
  end;
  DelStack;
end;

function TDirGet.AssignObj;
begin
	AddStack('TDirGet.AssignObj',Self);
  sL:=nil; result := inherited AssignObj(tf);
  if result and (FItems.Count>0) and not Assigned(bDyn) then begin
    result := tf.ComponentCount>3;
  	if result then sL:=pointer(tf.Components[3]);
  end;
  DelStack;
end;

{procedure nWndProc(h: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM) stdcall;
begin
	AddStack('DirGet.nWndProc');
	if (uMsg=WM_ACTIVATE) and (wParam=WA_INACTIVE)
  then LastForm.Enabled:=true;
	//CallWindowProc(Pointer(oWndProc),h,uMsg,wParam,lParam);
  DelStack;
end;}

{ $IFDEF OLDDIR
function DirFind(Wnd: HWND; uMsg: UINT; lParam,lpData: LPARAM): longint stdcall;
begin
	AddStack('DirGet.DirFind');
	if uMsg=BFFM_INITIALIZED then begin
  	if DirectoryExists(StrPas(PChar(lpData)))
	  then SendMessage(Wnd,BFFM_SETSELECTION,1,lpData);
    //oWndProc:=GetWindowLong(Wnd,GWL_WNDPROC); SetWindowLong(Wnd,GWL_WNDPROC,LongInt(@nWndProc));
    //LastForm.Enabled:=false;
  end;
	result:=0;
  DelStack;
end;

function MySelectDirectory;
var BrowseInfo: TBrowseInfo;
  Buffer: PChar;
  RootItemIDList,ItemIDList: PItemIDList;
  ShellMalloc: IMalloc;
  IDesktopFolder: IShellFolder;
  Eaten,Flags: LongWord;
begin
	AddStack('DirGet.MySelectDirectory');
  Result:=False; CorrDirSelf(Directory,false);
  if ExtractFileDrive(Directory)=Directory then IncD(Directory,PathDelim);
  FillChar(BrowseInfo,SizeOf(BrowseInfo),0);
  if (ShGetMalloc(ShellMalloc)=S_OK) and (ShellMalloc<>nil) then
  begin
    Buffer:=ShellMalloc.Alloc(MAX_PATH);
    try
      SHGetDesktopFolder(IDesktopFolder);
      IDesktopFolder.ParseDisplayName(Application.Handle,nil,POleStr(Root),Eaten,RootItemIDList,Flags);
      with BrowseInfo do begin
        hwndOwner:=Application.Handle;
        pidlRoot:=RootItemIDList;
        pszDisplayName:=Buffer;
        lpszTitle:=PChar(DlmBetween(Caption,'(<+> - открыть, <-> - закрыть, <Enter> - выбор)',CRLF));
        ulFlags := BIF_RETURNONLYFSDIRS or BIF_STATUSTEXT;
        lpfn:=DirFind;
        lParam:=longint(PChar(Directory));
      end;
      LastForm.Enabled:=false;
      ItemIDList:=ShBrowseForFolder(BrowseInfo);
      LastForm.Enabled:=true;
      Result := ItemIDList<>nil;
      if Result then begin
        ShGetPathFromIDList(ItemIDList,Buffer);
        ShellMalloc.Free(ItemIDList);
        Directory:=Buffer;
      end;
    finally
      ShellMalloc.Free(Buffer);
    end;
  end;
  DelStack;
end;
{$ENDIF}

procedure TDirGet.StdListDown;
var s,s1: string;
  i,p: longint;
  a,af: array[1..3] of string;
{ $IFDEF OLDDIR
	f: TFormWnd;
{$ENDIF}
begin
	AddStack('TDirGet.StdListDown',Self);
  s:=tf.Value; LsArrFill(tf.Mask,a,UnDelim);
  if Assigned(FOpenDialog) then with FOpenDialog do begin
    FilterIndex:=max(1,Int0(a[3]));
    if (dgServerName in FOptions) and (ListAsArray(s,af,DriveDelim)>2)
    then s:='\\'+af[1]+PathDelim+af[2]+af[3];
  	FileName:=s;
    if FileExec(SectBeg+VName,FOpenDialog,tf,[],a[2],a[1]) then begin
    	s:=FileName;
      if (dgServerName in FOptions) and IsNetDrive(s) then begin
      	s1:=Copy(s,3,MaxInt); s:='';
        for i:=1 to 2 do begin
          p:=PosEnd(PathDelim,s1); IncD(s,ExtractLeftPart(s1,p,PathDelim)+DriveDelim);
        end;
        IncD(s,PathDelim+s1);
      end;
    	tf.Value:=s;
    end;
  end
  else begin
{ $IFDEF OLDDIR
    if empty(ExtractFileDrive(s)) then IncL(s,IfThen(empty(a[2]),ExeDir,CorrDir(a[2])));
	  f:=TFormWnd.BeforeShowOther;
    if MySelectDirectory(a[1],IfThen(empty(a[2]),
    'Сетевое окружение',
    //IfThen(Win32Platform=VER_PLATFORM_WIN32_NT,'Мое сетевое окружение','Сетевое окружение'),
    a[2]),s)
    then tf.Value:=IfThen(empty(a[2]),s,Copy(s,Length(CorrDir(a[2]))+1,MaxInt));
	  TFormWnd.AfterShowOther(f);
{$ELSE}
    if empty(ExtractFileDrive(s)) and empty(a[2]) then IncL(s,ExeDir);
		if DirExec(tf,a[1],a[2],SectBeg+VName,s) then tf.Value:=s;
{ $ENDIF}
  end;
  DelStack;
end;

procedure TDirGet.SetItems;
begin
	AddStack('TDirGet.SetItems',Self);
  FItems.Assign(Value);
  DelStack;
end;

procedure TDirGet.ItemsChange;
begin
  AddStack('TDirGet.ItemsChange',Self);
  UpdateAllFld(mgCreate);
  DelStack;
end;

procedure TDirGet.KeyProcList;
var tf: TFldEdit;
	mr: TListF2Result;
  s: string;
begin
	AddStack('TDirGet.KeyProcList',Self);
  tf:=FldEditOwner(tw);
  if AssignObj(tf) then begin
    sL.Down:=true;
    case Key of
      K_F3: begin
        mr:=TListF2Result.Create;
        try
          if ListF2Down(FItems.Text,mr,eN,0,tf.Schem) then
            if mr.SelectStr>=0 then tf.Value:=FItems[mr.SelectStr];
        finally
          mr.Free;
        end;
      end;
      K_Shift_F2: with TTreeDirHistory.Create do
        try
          Ident:=SectBeg+VName; ReadIni;
          if Execute(s,eN) then tf.Value:=s;
          WriteIni;
        finally
          Free;
        end;
    end;
    sL.Down:=false;
  end;
  DelStack;
end;

class procedure TDirGet.ListClick;
var tf: TFldEdit;
	tl: TKeyLb;
begin
	AddStack('TDirGet.ListClick');
	tf:=pointer(TPaintButton(Sender).Owner);
	if not tf.Active then tf.SetFocus;
  if FormKeyLb(tf,tl) then tl.ExecKey(K_F3);
  DelStack;
end;

procedure TDirGet.SetOpenDialog;
begin
	AddStack('TDirGet.SetOpenDialog',Self);
	FOpenDialog:=Value;
  if Assigned(FOpenDialog) then IncOptions([],[dgCreatePrompt]);
  DelStack;
end;

procedure TDirGet.SetOptions;
begin
	AddStack('TDirGet.SetOptions',Self);
  if (dgServerName in Value) and not(dgServerName in FOptions)
  then Exclude(Value,dgCreatePrompt);
  if (dgCreatePrompt in Value) and not(dgCreatePrompt in FOptions)
  then Exclude(Value,dgServerName);
  if Assigned(FOpenDialog) then Exclude(Value,dgCreatePrompt);
  FOptions:=Value;
  DelStack;
end;

procedure TDirGet.IncOptions;
begin
  Options:=Options+Incl-Excl;
end;

function TDirGet.MaskTrans;
var a: array[1..3] of string;
  i,CntFlt: longint;
  va: TArrVar;
begin
	AddStack('TDirGet.MaskTrans');
  CntFlt:=0;
  if Assigned(FOpenDialog) then begin
    for i:=1 to Length(FOpenDialog.Filter) do
      if FOpenDialog.Filter[i]='|' then Inc(CntFlt);
    CntFlt:=Ceil((CntFlt+1)/2);
  end;
	if MyVarType(av)=varArray then begin
    result:=TrimRight(IsNilc(av[1],''))+UnDelim+TrimRight(IsNilc(av[2],''));
    if CntFlt>1 then IncD(result,StrNum(UnDelim,IsNilc(av[3],1)));
  end
  else begin
    LsArrFill(av,a,UnDelim);
    CopyFromVArr(va,
      [VarArrayOf([mpEdit,'Заголовок',a[1]])
      ,VarArrayOf([mpEdit,'Корневой каталог',a[2]])
      ]);
    if CntFlt>1
    then AddFromVArr(va,[VarArrayOf([mpSpin,'Номер фильтра по умолчанию',Int0(a[3]),1,CntFlt])]);
    result:=ArrVarToVar(va);
  end;
  DelStack;
end;

procedure TDirGet.MaskPrn;
var a: array[1..3] of string;
begin
	AddStack('TDirGet.MaskPrn',Self);
  LsArrFill(Mask,a,UnDelim);
  if not empty(a[1]) then LsPrn.Add('Заголовок: '+a[1]);
  if not empty(a[2]) then LsPrn.Add('Корневой каталог: '+a[2]);
  if not empty(a[3]) then LsPrn.Add('Номер фильтра по умолчанию: '+a[3]);
  DelStack;
end;

procedure TDirGet.FMaskHelp;
const Dlm = '+"'+UnDelim+'"+';
var n: byte;
begin
  AddStack('TDirGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+3);
  Inc(n); CopyFrom(ht.Dat[n],HelpStruct(['Заголовок','Корень','Фильтр']));
  Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr('«Заголовок»')+Dlm+HelpBoldStr('«Корневой каталог»')+'['+Dlm+HelpNum('«Номер фильтра по умолчанию»')+']');
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TDirGet]);
end;

initialization
  AddStack('DirGet.initialization');
  MyTypes.CopyFileOpt:=CopyFileOpt; MyTypes.DiskWait:=DiskWait;
  DelStack;
end.

