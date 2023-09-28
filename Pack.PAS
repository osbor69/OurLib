unit Pack;

interface

{$I LIBTEST}
uses SysUtils,Classes,ZLibEx,Controls,
  MyTypes,FStat,Crypto,BufFile;

const
  ArhBlockSize = 64*KByte;

  prmDirFrom    = 0;
  prmAvDopFiles = 1;
  prmSubDir     = 2;
  prmDirInf     = 3;
  prmLsDopFiles = 4;
  prmCrypto     = 5;

{
Структура архива PCK(0):
n4	Vers
$head
$contents

Структура архива PCK(1):
n4	Vers
n4	ChkSum \ <-
n4	ChkCnt /  |
n1	cntVol  \ |
n4	szFiles |--
n4	szPck   |
s	  Comment /
n4	ChkSum \ <-
n4	ChkCnt /  |
$head ---------
$contents

Структура архива PCK(2):
n4	Vers
n4	ChkSum \ <-
n4	ChkCnt /  |
n1	cntVol  \ |
n4	szFiles |--
n4	szPck   |
s	  Comment /
n4	ChkSum \ <-
n4	ChkCnt /  |
$head ---------
$contents -------\
n4  ChkSumFile <-/

Структура архива PCK(4):
n4	Vers
l   IsPassNeed
n4	ChkSum \ <-
n4	ChkCnt /  |
n1	cntVol  \ |
n8	szFiles |--
n8	szPck   |
s	  Comment /
n4	ChkSum \ <-
n4	ChkCnt /  |
$head ---------
$contents -------\
n4  ChkSumFile <-/

Структура $head:
n4	cntFile
$file*cntFile
n4	cntDir
$dir*cntDir

Структура $file(0):
s	  Name
n4	Pos
n4	Len

Структура $file(1):
s	  Name
n4	Pos
n4	Len
n4	DateTime

Структура $file(4):
s	  Name
n8	Pos
n8	Len
n4	DateTime

Структура $dir:
s   Name
$head
}

type
  PPckFileInf = ^TPckFileInf;
	TPckFileInf = record
  	p,l: Int64;
    d: longint;
  end;

  TPackFileList = class(TStringList)
  private
    a: array of TPckFileInf;
    la: longint;
    function ObjCreate(i: longint): PPckFileInf;
  protected
    procedure SetCapacity(NewCapacity: Integer); override;
  public
    constructor Create;
    function GetObj(i: longint): PPckFileInf;
  end;

  TPackDirList = class;

  PPckDirInf = ^TPckDirInf;
  TPckDirInf = record
    FileList: TPackFileList;
    DirList: TPackDirList;
  end;

  TPackDirList = class(TStringList)
  private
    a: array of TPckDirInf;
    la: longint;
    function ObjCreate(i: longint; Sender: TStat = nil): PPckDirInf;
    function GetObj(i: longint; Sender: TStat; nPrm: longint = prmDirInf): boolean; overload;
  protected
    procedure SetCapacity(NewCapacity: Integer); override;
  public
    constructor Create;
    function GetObj(i: longint; var pdi: PPckDirInf;
      Sender: TStat = nil; nPrm: longint = prmDirInf): boolean; overload;
  end;

  TFileStreamSave = record
    fn: TFileName;
    f: TFileBufStream;
  end;

  TPckErrOpt = set of (pckErrWrite,pckErrMsg);

	TPacker = class(TObject)
  private
  	PckFileName,PckFullName,FileStreamName: TFileName;
		FileStream: TFileBufStream;
	  PckStream: TCustomZStream;
	  ChkCnt,szFlop,Vers,ChkSumFile: longword;
	  WrChkSum,lFlop: boolean;
    CheckState: (pchkNone,pchkPck,pchkRepck);
    FKeyword: string;
    szi64r: byte;
    sr: TSaveRec;
		procedure wri(i: longword);
		procedure wri64(i: Int64);
		procedure rds(var s: string; cs: TCryptoStream);
		procedure wrs(const s: string; cs: TCryptoStream);
		procedure ArhNameExt(const cnmArh: string = '');
		function CaptDef(const cDef: string): string;
		function WriteStr(f: longint; var s: string; l: longint): longint;
		function FGetPackInfo: boolean;
		procedure ReadErr(var buffer; count: Longint; lPck: boolean = false);
		procedure rdi64(var result: Int64);
		function IsErr(E: Exception; Opt: TPckErrOpt = []; ost: longint = NegDef; Sender: TStat = nil): boolean;
    function FileStreamCreate(var SvInf: TFileStreamSave; const FileName: TFileName; 
      Sender: TStat = nil; lWrite: boolean = false): boolean;
    procedure FileStreamFree(const SvInf: TFileStreamSave; Sender: TStat = nil; FromClose: boolean = true);
		procedure StPck(Sender: TStat);
		procedure StPckFind(Sender: TStat);
		procedure StPckFind1(Sender: TStat);
		procedure StPckHead(Sender: TStat);
		procedure StPckDir(Sender: TStat);
		procedure StPckVol(Sender: TStat);
		procedure StPckFlop(Sender: TStat);
		procedure StRepck(Sender: TStat);
		procedure StRepckChk(Sender: TStat);
		procedure StRepckHead(Sender: TStat);
		procedure StRepckGum(Sender: TStat);
		procedure StRepckDir(Sender: TStat);
		function SayStat(Sender: TStat; const Capt,st: TCaption; prc: Double): boolean;
  public
  	aMask,aExclude: TArrStr;
    avSubDir,avDopFiles: variant;
    compressionLevel: TZCompressionLevel;
  	sPath,ArhName,Capt,Comment,CommentFileName,TmpDir,MsgErrorRead: string;
	  CheckFlop,VolDiv,WithHead,ExtSave,UserAborted,IsPassNeed: boolean;
    PackInfo: TPackInfo;
    ChkSum,Attr: longword;
    aPrm: TArrVar;
    PrAfterClose: function(const FileName: TFileName; const aPrm: array of variant): boolean;
    constructor Create;
		procedure Init(const aKeyword: string='');
    function DoPack(noCanEsc: boolean=false): boolean;
    function DoRepack(DirInf: PPckDirInf = nil): boolean;
		function GetPackInfo: boolean;
		class function DirInfCreate: PPckDirInf;
		class procedure DirInfFree(DirInf: PPckDirInf; lFree: boolean = true);
		class function CntBlock(l: Int64; l1: longint = ArhBlockSize): longint;
  end;

function DopMakePackerComment(const aName,aPrim,aProgs: string; aVers: longint): string; overload;
function DopGetHeader(const fn: string; out dh: TDopHeader): boolean;

implementation
{$B-}

uses Windows,Variants,Math,StrUtils,
  My_pr,Askp,ListF2;

const
	cEndStr: char = '\';
  szi = SizeOf(longword);
  szi64 = SizeOf(Int64);
  TmpFile = '~~GGPACK.TMP';
  LastVers = 4;

  DOP_INI_SECT = 'GGPACK';
  DOP_INI_NAME = 'NAME';
  DOP_INI_PRIM = 'PRIM';
  DOP_INI_PROGS = 'PROGS';
  DOP_INI_VERS = 'VERS';

  DOP_COMMENT_VERS = 1;
  DOP_COMMENT_DEL = #31;

function DopMakePackerComment(const aName,aPrim,aProgs: string; aVers: longint): string; overload;
begin
  result:=Format('%d%s%s%s%s%s%s%s%d',
    [DOP_COMMENT_VERS,DOP_COMMENT_DEL,
    aName,DOP_COMMENT_DEL,
    aPrim,DOP_COMMENT_DEL,
    aProgs,DOP_COMMENT_DEL,
    aVers]);
end;

function DopMakePackerComment(const fn: string): string; overload;
var ifc: TIniFileCheck;
    s,t: string;
    k: Int64;
begin
  AddStack('Pack.DopMakePackerComment');
  result:='';
  if (FileExists(fn)) then begin
    ifc:=TIniFileCheck.Create(fn);
    try
      if (ifc.SectionExists(DOP_INI_SECT)) then begin
        t:=TrimRight(ifc.ReadString(DOP_INI_SECT,DOP_INI_NAME));
        s:=Trim(ifc.ReadString(DOP_INI_SECT,DOP_INI_VERS));
        if not Str2IntEq(k,s,MaxInt) then begin
          if (Ask(['Версия утилиты'+IfThen(t<>'',' '+t)+': '+s,'Увеличить номер версии?'])) then begin
            inc(k);
            ifc.WriteInteger(DOP_INI_SECT,DOP_INI_VERS,k);
            ifc.UpdateFile;
          end;
        end;
        result:=DopMakePackerComment(
          t,
          ifc.ReadString(DOP_INI_SECT,DOP_INI_PRIM),
          ifc.ReadString(DOP_INI_SECT,DOP_INI_PROGS),
          k);
      end;
    finally
      ifc.Free;
    end;
  end;
  DelStack;
end;

function DopGetHeader;
var sti: longint;
    p: TPacker;
    b: boolean;
    a: array[1..5]of string;
begin
  sti:=AddStack('Pack.DopGetHeader');
  result:=false;

  Finalize(dh);
  dh.dhRecVers:=0;
  dh.dhVers:=0;

  p:=TPacker.Create;
  try
    p.ArhName:=fn;
    try
      b:=p.GetPackInfo;
    except
      on EFOpenError do begin
        (* было "файл занят другим процессом" *)
        SetStack(sti);
        b:=false;
      end;
    end;
    if (b) then begin
      LsArrFill(p.Comment,a,DOP_COMMENT_DEL);
      dh.dhRecVers:=StrToIntDef(Trim(a[1]),0);
      dh.dhName:=TrimRight(a[2]);
      dh.dhPrim:=TrimRight(a[3]);
      dh.dhProgs:=TrimRight(a[4]);
      dh.dhVers:=StrToIntDef(Trim(a[5]),MaxInt);
      if (dh.dhRecVers>0)and(dh.dhVers<>MaxInt) then result:=true;
    end;
  finally
    p.Free;
  end;
  DelStack;
end;

// Расширение файла архива
function extfilepck(nd: byte): string;
begin
	AddStack('Pack.extfilepck');
  result:='.'+IfThen(nd=1,'PCK',StrNum('P',nd-1,2));
  DelStack;
end;

// Ожидание дискеты
type TDiskFlWaitOpt = set of (dskwNoFile,dskwNoFirst,dskwWrite,dskwMsg);

function diskflwait(const FileName: TFileName; nd: longint;
  Opt: TDiskFlWaitOpt = []; nprior: longint = NegDef): boolean;
begin
	AddStack('Pack.diskflwait');
  result:=false;
  while true do begin
  	result := not((dskwNoFirst in Opt) or (dskwMsg in Opt));
    if result then result:=DirectoryExists(ExtractFileDrive(FileName)); //result := MyDiskFree(FileName)>=0;
    if result and not(dskwNoFile in Opt) then result:=MyFileExists(FileName+extfilepck(nd));
    if result and (nprior<>NegDef) then result := not MyFileExists(FileName+extfilepck(nprior));
    if result then break;
    Opt:=Opt-[dskwNoFirst,dskwMsg];
    if not Ask([Format('Вставьте дискету %d в дисковод ',[nd])+ExtractFileDrive(FileName),
    	'Продолжить ?']) then break;
  end;
  DelStack;
end;

function FileOpenMsg(const FileName: TFileName; var Handle: longint; Sender: TStat;
  lMsg: boolean = true; const MsgDop: string = ''): boolean;
begin
  AddStack('Pack.FileOpenMsg');
  repeat
    Handle:=FileBufOpen(FileName,fmOpenRead or fmShareDenyWrite);
    result := longword(Handle)<>INVALID_HANDLE_VALUE;
    if not result then begin
      if lMsg then
        if Ask(['Ошибка открытия файла:',DlmBetween(FileName,MsgDop,CRLF),
          'Повторить попытку открытия файла ?']) then continue;
      Sender.Abort; break;
    end;
  until result;
  DelStack;
end;

function FileStreamCreateMsg(const FileName: TFileName; var FileStream: TFileBufStream; Sender: TStat;
  lWrite: boolean = false): boolean;
var ost: longint;
begin
  ost:=AddStack('Pack.FileStreamCreateMsg');
  repeat
    result:=true;
    try
      FileStream:=TFileBufStream.Create(FileName,IfThen(lWrite,fmCreate,fmOpenRead or fmShareDenyWrite));
    except
      on EFCreateError do begin
        SetStack(ost);
        result:=false;
      end;
    end;
    if not result then begin
      if Ask(['Ошибка '+IfThen(lWrite,'создания','открытия')+' файла:',FileName,
      'Повторить попытку открытия файла ?'])
        then continue;
      Sender.Abort; break;
    end;
  until result;
  DelStack;
end;

function EmpCurDir(const Dir: TFileName): TFileName;
begin
  AddStack('Pack.EmpCurDir');
  result:=IfThen(ExtractFileDrive(Dir)='',CurrentDir)+Dir;
  DelStack;
end;

{ TPackFileList }
constructor TPackFileList.Create;
begin
  AddStack('TPackFileList.Create');
  SetLength(a,10); la:=0;
  DelStack;
end;

function TPackFileList.ObjCreate;
begin
  AddStack('TPackFileList.ObjCreate');
  if Length(a)=la then SetLength(a,la shl 1);
  result:=@a[la]; Inc(la); Objects[i]:=Pointer(la);
  DelStack;
end;

function TPackFileList.GetObj;
begin
  AddStack('TPackFileList.GetObj');
  result:=@a[IntObj(Self,i)-1];
  DelStack;
end;

procedure TPackFileList.SetCapacity;
begin
  AddStack('TPackFileList.SetCapacity');
  inherited SetCapacity(NewCapacity);
  if Length(a)<NewCapacity then SetLength(a,NewCapacity);
  DelStack;
end;

{ TPackDirList }
constructor TPackDirList.Create;
begin
  AddStack('TPackDirList.Create');
  SetLength(a,10); la:=0;
  DelStack;
end;

function TPackDirList.ObjCreate;
begin
  AddStack('TPackDirList.ObjCreate');
  if Length(a)=la then SetLength(a,la shl 1);
  result:=@a[la]; Inc(la); Objects[i]:=Pointer(la);
  if Assigned(Sender) then Sender.Params[prmDirInf]:=LongInt(result);
  DelStack;
end;

function TPackDirList.GetObj(i: longint; var pdi: PPckDirInf;
  Sender: TStat = nil; nPrm: longint = prmDirInf): boolean;
begin
  AddStack('TPackDirList.GetObj');
  result:=Assigned(Objects[i]);
  if result then begin
    pdi:=@a[IntObj(Self,i)-1];
    if Assigned(Sender) then Sender.Params[nPrm]:=LongInt(pdi);
  end;
  DelStack;
end;

function TPackDirList.GetObj(i: longint; Sender: TStat; nPrm: longint = prmDirInf): boolean;
var pdi: PPckDirInf;
begin
  result:=GetObj(i,pdi,Sender,nPrm);
end;

procedure TPackDirList.SetCapacity;
begin
  AddStack('TPackDirList.SetCapacity');
  inherited SetCapacity(NewCapacity);
  if Length(a)<NewCapacity then SetLength(a,NewCapacity);
  DelStack;
end;

{ TPacker }

constructor TPacker.Create;
begin
	AddStack('TPacker.Create');
  Init;
  DelStack;
end;

procedure TPacker.Init;
begin
  AddStack('TPacker.Init');
  aMask:=nil; aExclude:=nil; avSubDir:=null; avDopFiles:=null;
  compressionLevel:=zcDefault; sPath:=''; ArhName:=''; Capt:=''; Comment:=''; CommentFileName:='';
  TmpDir:=''; MsgErrorRead:=''; CheckFlop:=true; VolDiv:=false; WithHead:=true; ExtSave:=false;
  Attr:=0; CheckState:=pchkNone; aPrm:=nil; PrAfterClose:=nil;
  ZeroMemory(@PackInfo,SizeOf(PackInfo)); PackInfo.cntVol:=1;
  FKeyword:=TrimRight(aKeyword); IsPassNeed := FKeyword<>'';
  DelStack;
end;

// Архивация
function TPacker.DoPack;
begin
  AddStack('TPacker.DoPack');
  result:=not ShowStat(CaptDef('Создание архива'),StPck,
    [sPath,avDopFiles,avSubDir,0,0,0],not noCanEsc);
  DelStack;
end;

procedure TPacker.ArhNameExt;
var nmArh,ext: string;
  l: longint;
begin
  AddStack('TPacker.ArhNameExt');
  nmArh:=EmpCurDir(IfThen(cnmArh='',ArhName,cnmArh)); sPath:=EmpCurDir(sPath);
  ext:=AnsiUpperCase(ExtractFileExt(nmArh)); l:=Length(ext);
  if l=0 then PckFileName:=nmArh else PckFileName:=SubStr(nmArh,1,-l);
  PckFullName:=PckFileName+IfThen(ExtSave,ext,'.PCK');
  DelStack;
end;

function TPacker.CaptDef;
begin
  AddStack('TPacker.CaptDef');
  result:=IfThen(Capt='',cDef,Capt);
  DelStack;
end;

function TPacker.SayStat;
begin
  AddStack('TPacker.SayStat');
  result:=Sender.SayStat(Capt,st,prc);
  if not result then UserAborted:=true;
  DelStack;
end;

procedure TPacker.StPck;
	function ChkPz: Int64;
  begin
    AddStack('TPacker.StPck.ChkPz');
    result:=FileStream.Position; wri(0); wri(0);
    DelStack;
  end;
	procedure ChkInit(pz: Int64);
  begin
    AddStack('TPacker.StPck.ChkInit');
    ChkSum:=0; ChkCnt:=0; WrChkSum:=true; FileStream.Position:=pz+szi*2;
    DelStack;
  end;
  procedure ChkWrite(pz: Int64);
  begin
    AddStack('TPacker.StPck.ChkWrite');
    FileStream.Position:=pz; WrChkSum:=false; wri(ChkSum); wri(ChkCnt);
    DelStack;
  end;
var i,lr: byte;
	function Stat1(const Capt: string; Proc: TStatEvent; aPrmObj: pointer=nil): boolean;
  var se: TStatEvent;
      cs: TCryptoStream;
  begin
    AddStack('TPacker.StPck.Stat1: '+Capt);
    result:=SayStat(Sender,'',Capt,i/lr);
    Inc(i);
    if not result then begin
      se:=StPckHead;
      if (@Proc<>@se) then cs:=nil
      else begin
        cs:=TCryptoStream.Create(nil,FKeyword);
        Sender.Params[prmCrypto]:=longint(cs);
      end;
      try
        result:=ShowStat(Capt,Proc,Sender.Params,Sender.FCanEsc);
      finally
        cs.Free;
      end;
      if result then Sender.Abort;
    end;
    DelStack;
  end;
  procedure wrInf;
  begin
    AddStack('TPacker.StPck.wrInf');
    FileStream.WriteBuffer(PackInfo.cntVol,1);
    if WrChkSum then begin
      Inc(ChkSum,PackInfo.cntVol); Inc(ChkCnt);
    end;
    wri64(PackInfo.szFiles);
    wri64(PackInfo.szPck);
    wrs(Comment,nil);
    DelStack;
  end;
var pdi: PPckDirInf;
	lsDopFiles: TStringList;
  a: TArrStr;
  ost,j: longint;
  pzi,pzh: Int64;
  oFile,oFull: string;
  SvInf: TFileStreamSave;
label lend,lend1;
begin
	ost:=AddStack('TPacker.StPck');
  UserAborted:=false; ArhNameExt; lr:=IfThen(WithHead,5,2); lFlop:=IsFlopDrive(PckFullName);
  oFile:=PckFileName; oFull:=PckFullName;
	if lFlop or VolDiv then begin
    ArhNameExt(EmpCurDir(TmpDir)+ExtractFileName(PckFileName)); Inc(lr);
    if lFlop and (TmpDir<>'') then Inc(lr);
  end;
  if ForceDirMsg(ExtractFilePath(PckFullName)) then begin
    FileStreamCreate(SvInf,PckFullName,Sender,true);
    try
      if not Sender.Aborted then
        try
          pdi:=DirInfCreate;
          lsDopFiles:=SortStrListCreate(MyVarType(Sender.Params[prmAvDopFiles])=varArray);
          try
            Sender.Params[prmDirInf]:=LongInt(pdi);
            Sender.Params[prmLsDopFiles]:=LongInt(lsDopFiles);
            PackInfo.szFiles:=0; i:=1;
            if MyVarType(Sender.Params[prmSubDir])=varBoolean then
              if GetMaskFiles(a,j,Sender.Params[prmDirFrom]+'*.*',[fmDir])
              then Sender.Params[prmSubDir]:=ArrStrToVar(a,0,j);
            if MyVarType(Sender.Params[prmSubDir])=varArray then begin
              if Stat1('Поиск файлов',StPckFind) then goto lend;
            end
            else begin
              Sender.Params[prmSubDir]:='';
              if Stat1('Поиск файлов',StPckFind1) then goto lend;
            end;
            pzi:=0; pzh:=0;
            if WithHead then begin
              WrChkSum:=false; wri(LastVers); FileStream.WriteBuffer(IsPassNeed,SizeOf(boolean));
              if WrChkSum then begin
                sr.l:=IsPassNeed; Inc(ChkSum,Ord(sr.s[1])); Inc(ChkCnt);
              end;
              pzi:=ChkPz;
              if CommentFileName<>'' then Comment:=DopMakePackerComment(CommentFileName);
              wrInf; pzh:=ChkPz;
              if Stat1('Подготовка заголовка',StPckHead) then goto lend;
            end;
            ChkSumFile:=0;
            if Stat1('Запись данных',StPckDir) then goto lend;
            if WithHead then begin
              wri(ChkSumFile); PackInfo.szPck:=FileStream.Position; PackInfo.cntVol:=1;
              if lFlop or VolDiv then begin
                if lFlop then begin
                  if not diskflwait(oFile,1,[dskwNoFile]) then goto lend;
                  szFlop:=MyDiskFree(oFull,true);
                end
                else szFlop:=1457664;
                PackInfo.cntVol:=CntBlock(PackInfo.szPck,szFlop);
              end;
              ChkInit(pzi); wrInf; ChkWrite(pzi); ChkInit(pzh);
              if Stat1('Запись заголовка',StPckHead) then goto lend;
              ChkWrite(pzh);
            end;
lend:
          finally
            DirInfFree(pdi); lsDopFiles.Free;
          end;
        except
          on E:Exception do if not IsErr(E,[pckErrWrite],ost,Sender) then raise
        end;
    finally
      FileStreamFree(SvInf,Sender);
    end;
    if WithHead then begin
      CheckState:=pchkPck;
      try
        if Stat1('Проверка созданного архива',StRepck) then Sender.Abort;
      finally
        CheckState:=pchkNone;
      end;
    end;
    if not Sender.Aborted then
      if lFlop or VolDiv then begin
        if (TmpDir<>'') or VolDiv then
          if PackInfo.cntVol=1 then
            if lFlop then Inc(i)
            else if CopyFileOpt(PckFullName,oFull,[cfStat],Attr) then DelFileAtr(PckFullName)
            else begin
              Sender.Abort; goto lend1;
            end
          else begin
            if not lFlop then PckFileName:=oFile;
            if Stat1('Распределение архива по дискетам',StPckVol) then goto lend1;
          end;
        if lFlop then begin
          Sender.Params[prmDirInf]:=oFile;
          if Stat1('Копирование архива на дискеты',StPckFlop) then goto lend1;
        end;
      end
      else if Attr<>0 then FileClrAttr(PckFullName,Attr);
  end
  else Sender.Abort;
lend1:
  if Sender.Aborted or (lFlop and (TmpDir='')) then DelMaskFiles(PckFileName+'.*');
  DelStack;
end;

function TPacker.FileStreamCreate;
begin
  AddStack('TPacker.FileStreamCreate');
  SvInf.fn:=FileStreamName; SvInf.f:=FileStream;
  FileStreamName:=FileName; result:=FileStreamCreateMsg(FileName,FileStream,Sender,lWrite);
  DelStack;
end;

procedure TPacker.FileStreamFree;
begin
  AddStack('TPacker.FileStreamFree');
  if Assigned(Sender) and Assigned(FileStream) then
    if not FileStream.Update(true) then Sender.Abort;
  FreeAndNil(FileStream);
  if FromClose and Assigned(Sender) then
    if not Sender.Aborted and Assigned(PrAfterClose) and (CheckState=pchkNone) then
      if not PrAfterClose(FileStreamName,aPrm) then Sender.Abort;
  FileStreamName:=SvInf.fn; FileStream:=SvInf.f;
  DelStack;
end;

function TPacker.WriteStr;
var i: longint;
begin
  AddStack('TPacker.WriteStr');
  result:=FileRead(f,pointer(s)^,l);
  if result>0 then
    try
      PckStream.WriteBuffer(pointer(s)^,result);
      for i:=1 to result do Inc(ChkSumFile,Ord(s[i]));
    except
      on E:Exception do begin
        IsErr(E,[pckErrWrite,pckErrMsg]); raise
      end;
    end;
  DelStack;
end;

procedure TPacker.wri;
begin
  AddStack('TPacker.wri');
  FileStream.WriteBuffer(i,szi);
  if WrChkSum then begin
  	sr.crd:=i;
    for i:=1 to szi do Inc(ChkSum,Ord(sr.s[i]));
    Inc(ChkCnt,szi);
  end;
  DelStack;
end;

procedure TPacker.wri64;
var j: byte;
begin
  AddStack('TPacker.wri64');
  FileStream.WriteBuffer(i,szi64);
  if WrChkSum then begin
  	sr.i64:=i;
    for j:=1 to szi64 do Inc(ChkSum,Ord(sr.s[j]));
    Inc(ChkCnt,szi64);
  end;
  DelStack;
end;

procedure TPacker.rds;
var k: longint;
    c: char;
    hi: THardInt;
begin
  AddStack('TPacker.rds');
  if IsPassNeed and (cs<>nil) then begin
    ReadErr(hi,SizeOf(THardInt));
    k:=TCryptoStream.Hard2Int(hi);
    SetLength(s,k);
    ReadErr(pchar(s)^,length(s));
    s:=cs.DecodeStr(s);
  end else begin
    k:=0;
    repeat
      ReadErr(c,1);
      Inc(k);
    until c=cEndStr;
    FileStream.Seek(-k,soCurrent);
    Dec(k);
    SetLength(s,k);
    ReadErr(pointer(s)^,k);
    FileStream.Seek(1,soCurrent);
  end;
  DelStack;
end;

procedure TPacker.wrs;
var k: longint;
    hi: THardInt;
    t,u: string;
begin
  AddStack('TPacker.wrs');
  if IsPassNeed and (cs<>nil) then begin
    t:=cs.EncodeStr(s);
    k:=length(t);
    SetLength(u,SizeOf(THardInt)+k);
    hi:=TCryptoStream.Int2Hard(k);
    Move(hi,pchar(u)^,SizeOf(THardInt));
    Move(pchar(t)^,pchar(longint(pchar(u))+SizeOf(THardInt))^,k);
    k:=length(u);
    FileStream.WriteBuffer(pchar(u)^,k);
    if (WrChkSum) then begin
      inc(ChkCnt,k);
      while (k>0) do begin
        inc(ChkSum,ord(u[k]));
        dec(k);
      end;
    end;
  end else begin
    k:=Length(s);
    FileStream.WriteBuffer(pointer(s)^,k);
    FileStream.WriteBuffer(cEndStr,1);
    if WrChkSum then begin
      Inc(ChkCnt,k+1);
      while k>0 do begin
        Inc(ChkSum,Ord(s[k]));
        Dec(k);
      end;
      Inc(ChkSum,Ord(cEndStr));
    end;
  end;
  DelStack;
end;

procedure TPacker.StPckFind;
var i,lr: longint;
	function Dir1(const dir: string): boolean;
  begin
    AddStack('TPacker.StPckFind.Dir1');
	  Sender.Params[prmSubDir]:=dir;
    result:=SayStat(Sender,'',Sender.Params[prmDirFrom]+dir,i/lr); Inc(i);
    if not result then begin
    	result:=ShowStat(Sender.Params[prmDirFrom]+dir,StPckFind1,Sender.Params,Sender.FCanEsc);
      if result then Sender.Abort;
    end;
    DelStack;
  end;
var avSubDir: variant;
	pdi: PPckDirInf;
  s: string;
  i1: longint;
begin
	AddStack('TPacker.StPckFind');
  avSubDir:=Sender.Params[prmSubDir]; pdi:=PointerVar(Sender.Params[prmDirInf]);
  i1:=VarArrayLowBound(avSubDir,1); lr:=VarArrayHighBound(avSubDir,1)-i1+2; i:=1;
  if not Dir1('') then begin
    Sender.Params[prmAvDopFiles]:=null; pdi.DirList:=TPackDirList.Create;
    with pdi.DirList do begin
      Capacity:=lr-i+1;
      while i<=lr do begin
        s:=avSubDir[i1]; ObjCreate(Add(s),Sender);
        if Dir1(s) then break;
        Inc(i1);
      end;
    end;
  end;
  DelStack;
end;

function PckDirInfVar(const v: variant): PPckDirInf;
begin
  result:=PointerVar(v);
end;

procedure TPacker.StPckFind1;
var i,lr: longint;
  s,path: string;
  avDopFiles: variant;
  lsDopFiles,lsf: TStringList;
  pfi: PPckFileInf;
begin
	AddStack('TPacker.StPckFind1');
  path:=Sender.Params[prmDirFrom];
  avDopFiles:=Sender.Params[prmAvDopFiles];
  lsDopFiles:=PointerVar(Sender.Params[prmLsDopFiles]);
  if not empty(Sender.Params[prmSubDir]) then IncD(path,Sender.Params[prmSubDir]+PathDelim);
  with PckDirInfVar(Sender.Params[prmDirInf])^ do begin
    FileList:=TPackFileList.Create;
    with FileList do begin
      if Length(aMask)=0 then GetMaskFiles(FileList,path+'*.*',[],[msfAdd,msfNoUpper])
      else for i:=low(aMask) to high(aMask) do
        GetMaskFiles(FileList,path+aMask[i],[],[msfAdd,msfNoUpper]);
      FindDel(FileList,TmpFile);
      if TrimUpper(path)=TrimUpper(ExtractFilePath(PckFullName))
      then FindDel(FileList,ExtractFileName(PckFullName));
      if Assigned(lsDopFiles) then
        for i:=VarArrayLowBound(avDopFiles,1) to VarArrayHighBound(avDopFiles,1) do
          if MyVarType(avDopFiles[i])<>varArray then FindDel(FileList,avDopFiles[i]);
      Sorted:=false;
      if Length(aExclude)>0 then begin
        lsf:=TStringList.Create;
        try
          for i:=low(aExclude) to high(aExclude) do
            GetMaskFiles(lsf,path+aExclude[i],[],[msfAdd,msfNoUpper]);
          lsf.Sorted:=true; i:=0;
          while i<Count do
            if FindDel(lsf,Strings[i]) then Delete(i) else Inc(i);
        finally
          lsf.Free;
        end;
      end;
      if Assigned(lsDopFiles) then
        for i:=VarArrayLowBound(avDopFiles,1) to VarArrayHighBound(avDopFiles,1) do begin
          if MyVarType(avDopFiles[i])=varArray then s:=avDopFiles[i][1] else s:=avDopFiles[i];
          Add(s); lsDopFiles.AddObject(s,TObject(i));
        end;
      lr:=Count;
      if lr=0 then FreeAndNil(FileList)
      else begin
        Capacity:=lr;
        for i:=0 to lr-1 do begin
          pfi:=ObjCreate(i); ZeroMemory(pfi,SizeOf(pfi^));
        end;
      end;
    end;
    DirList:=nil;
    if not empty(Sender.Params[prmSubDir]) then begin
      Sender.Params[prmDirFrom]:=path; DirList:=TPackDirList.Create;
      with DirList do begin
        GetMaskFiles(DirList,path+'*.*',[fmDir],[msfNoUpper]); lr:=Count;
        if lr=0 then FreeAndNil(DirList)
        else begin
          Capacity:=lr; InitObjects(DirList);
          for i:=0 to lr-1 do begin
            s:=Strings[i];
            if SayStat(Sender,'',s,(i+1)/lr) then break;
            Sender.Params[prmSubDir]:=s; ObjCreate(i,Sender);
            if ShowStat(s,StPckFind1,Sender.Params,Sender.FCanEsc) then begin
              Sender.Abort; break;
            end;
          end;
        end;
      end;
    end;
  end;
  DelStack;
end;

procedure TPacker.StPckHead;
var pfi: PPckFileInf;
	i,lr,ost: longint;
  cs: TCryptoStream;
  s: string;
begin
	ost:=AddStack('TPacker.StPckHead');
  try
    cs:=PointerVar(Sender.Params[prmCrypto]);
    with PckDirInfVar(Sender.Params[prmDirInf])^ do begin
      if Assigned(FileList) then with FileList do begin
        lr:=Count; wri(lr);
        for i:=0 to lr-1 do begin
          if SayStat(Sender,'',Strings[i],(i+1)/lr) then break;
          wrs(Strings[i],cs);
          pfi:=GetObj(i);
          wri64(pfi.p);
          wri64(pfi.l);
          sr.i:=pfi.d;
          wri(sr.crd);
        end;
      end
      else wri(0);
      if not Sender.Aborted then
        if Assigned(DirList) then with DirList do begin
          lr:=Count; wri(lr); Sender.ClearCurTime;
          for i:=0 to lr-1 do begin
            s:=Strings[i];
            if SayStat(Sender,'',s,(i+1)/lr) then break;
            wrs(s,cs);
            if GetObj(i,Sender) then begin
              if ShowStat(s,StPckHead,Sender.Params,Sender.FCanEsc) then begin
                Sender.Abort; break;
              end;
            end
            else begin
              wri(0); wri(0);
            end;
          end;
        end
        else wri(0);
    end;
  except
  	on E:Exception do if not IsErr(E,[pckErrWrite],ost,Sender) then raise
  end;
  DelStack;
end;

procedure StPckFile(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var s: string;
  f,i,lr,b,ost: longint;
  l: Int64;
  pck: TPacker;
begin
	ost:=AddStack('Pack.StPckFile');
  f:=Params[0]; pck:=PointerVar(Params[2]);
  lr:=Params[3]; i:=1; b:=0; l:=min(Int064(Params[1]),ArhBlockSize); SetLength(s,l);
  try
    repeat
      if pck.SayStat(Sender,'','',i/lr) then break;
      Inc(i); b:=pck.WriteStr(f,s,l);
    until b<=0;
  except
    on E:Exception do if not pck.IsErr(E,[pckErrWrite],ost,Sender) then raise
  end;
  DelStack;
end;

procedure TPacker.StPckDir;
var path,s: string;
  pfi: PPckFileInf;
  lsDopFiles: TStringList;
  avDopFiles: variant;
  ost,i,j,f,lr: longint;
  l: Int64;
  fl: boolean;
  cs: TCryptoStream;
begin
	ost:=AddStack('TPacker.StPckDir');
  try
    path:=Sender.Params[prmDirFrom];
    avDopFiles:=Sender.Params[prmAvDopFiles];
    lsDopFiles:=PointerVar(Sender.Params[prmLsDopFiles]);
    with PckDirInfVar(Sender.Params[prmDirInf])^ do begin
      if Assigned(FileList) then with FileList do begin
        lr:=Count;
        for i:=0 to lr-1 do begin
          s:=Strings[i];
          if SayStat(Sender,'',s,(i+1)/lr) then break;
          fl:=true;
          if IntObjFind(lsDopFiles,s,j) then
            if MyVarType(avDopFiles[j])=varArray then begin
              s:=avDopFiles[j][0]; fl:=false;
            end
            else continue;
          if not FileOpenMsg(path+s,f,Sender,fl,MsgErrorRead) then
            if fl then break else continue;
          try
            pfi:=GetObj(i); pfi.d:=FileGetDate(f); l:=GetFileSize(f);
            if not WithHead then wri(l);
            pfi.l:=l;
            if l<=0 then pfi.p:=0
            else begin
              Inc(PackInfo.szFiles,l); pfi.p:=FileStream.Position;
              cs:=TCryptoStream.Create(FileStream,FKeyword);
              try
                PckStream:=TZCompressionStream.Create(cs,compressionLevel);
                try
                  j:=CntBlock(l);
                  if ShowStat(s,StPckFile,[f,IntToStr(l),longint(Self),j],j,Sender.FCanEsc) then begin
                    Sender.Abort; break;
                  end;
                finally
                  try
                    PckStream.Free;
                  except
                    on E:Exception do begin
                      if IsErr(E,[pckErrWrite,pckErrMsg]) then PckStream.Free;
                      raise
                    end;
                  end;
                end;
              finally
                cs.Free;
              end;
            end;
          finally
            FileClose(f);
          end;
        end;
      end;
      if not Sender.Aborted and Assigned(DirList) then with DirList do begin
        Sender.Params[prmLsDopFiles]:=IntNil; Sender.ClearCurTime; lr:=Count;
        for i:=0 to lr-1 do begin
          s:=Strings[i];
          if SayStat(Sender,'',s,(i+1)/lr) then break;
          if GetObj(i,Sender) then begin
            Sender.Params[prmDirFrom]:=path+s+PathDelim;
            if ShowStat(s,StPckDir,Sender.Params,Sender.FCanEsc) then begin
              Sender.Abort; break;
            end;
          end;
        end;
      end;
    end;
  except
    on E:Exception do
      if not IsErr(E,[pckErrWrite],ost,Sender) then raise
  end;
  DelStack;
end;

procedure TPacker.StPckVol;
var i: longint;
	fi,fo: TFileBufStream;
  s,fn: string;
begin
	AddStack('TPacker.StPckVol');
  fn:=ExtractFilePath(PckFullName)+TmpFile;
  if MyFileExists(fn) then
	  if not DelFileAtr(fn) then Sender.Abort;
  if not Sender.Aborted then
    if not RnmFileAtr(PckFullName,fn) then Sender.Abort
    else begin
      if FileStreamCreateMsg(fn,fi,Sender) then
        try
          SetLength(s,szFlop);
          for i:=1 to PackInfo.cntVol do begin
            if SayStat(Sender,'',Format('Дискета: %d из %d',[i,PackInfo.cntVol]),
              i/PackInfo.cntVol) then break;
            if not FileStreamCreateMsg(PckFileName+extfilepck(i),fo,Sender,true) then break;
            try
              fo.Write(pointer(s)^,fi.Read(pointer(s)^,szFlop));
              if not fo.Update(true) then begin
                Sender.Abort; break;
              end;
            finally
              fo.Free;
            end;
          end;
        finally
          fi.Free;
        end;
      DelFileAtr(fn);
    end;
  DelStack;
end;

procedure TPacker.StPckFlop;
var nd: longint;
  function NewStat(const Capt: string): boolean;
  begin
  	AddStack('TPacker.StPckFlop.NewStat');
    Sender.ClearCurTime;
		result:=SayStat(Sender,Capt,Format('Дискета: %d из %d',[nd,PackInfo.cntVol]),nd/PackInfo.cntVol);
    DelStack;
  end;
var s,drvTo,fFrom,fTo: string;
	sz: Int64;
  function LowSize: boolean;
  begin
    AddStack('TPacker.StPckFlop.LowSize');
    result := sz>MyDiskFree(drvTo)+GetFileSize(fTo);
    DelStack;
  end;
var st: string;
	nprior,ond: longint;
  lmsg,fl: boolean;
	fi,fo: TFileBufStream;
  Opt: TDiskFlWaitOpt;
begin
	AddStack('TPacker.StPckFlop');
  lmsg:=false; drvTo:=ExtractFileDrive(Sender.Params[prmDirInf])+PathDelim; fi:=nil; sz:=0;
  if TmpDir='' then FileStreamCreateMsg(PckFullName,fi,Sender);
  if not Sender.Aborted then
    try
      if TmpDir='' then SetLength(st,szFlop);
      while true do begin
        nprior:=NegDef; ond:=0; nd:=1; s:=extfilepck(nd);
        while true do begin
          if NewStat('Формирование архива на дискете') then break;
          Opt:=[dskwNoFile,dskwWrite];
          if nd>1 then Include(Opt,dskwNoFirst);
          if lmsg then Include(Opt,dskwMsg);
          if not diskflwait(Sender.Params[prmDirInf],nd,Opt,nprior) then begin
            Sender.Abort; break;
          end;
          Sender.Refresh; fFrom:=PckFileName+s; fTo:=Sender.Params[prmDirInf]+s;
          if ond<>nd then begin
            ond:=nd;
            if TmpDir='' then begin
              if lFlop and (nd>1) then begin
                fi.Free;
                if not FileStreamCreateMsg(fFrom,fi,Sender) then break;
              end;
              sz:=min(szFlop,fi.Read(pointer(st)^,szFlop));
            end
            else sz:=GetFileSize(fFrom);
          end;
          if IsMaskFiles(drvTo+'*.*',[fmFiles,fmDir]) and LowSize then 
            case AskCancel(['Внимание!','На дискете '+drvTo
            +Format(' необходимо не менее %d байт для копирования.',[sz]),
            'Вы можете использовать данную дискету или другую.',
            'При использовании данной дискеты все файлы на ней будут уничтожены.',
            '','Использовать данную дискету ?','']) of
              mrCancel: begin
                Sender.Abort; break;
              end;
              mrYes: dirxdel(LeftStr(drvTo,1));
            else continue;
            end;
          Sender.Refresh;
          if LowSize then begin
            mess_ok(['На дискете '+drvTo+Format(' необходимо не менее %d байт для копирования.',[sz]),
              'На дискете имеются сбойные блоки',
              'либо её размер недостаточен для копирования.','',
              'Воспользуйтесь другой дискетой.']);
            continue;
          end;
          DelMaskFiles(Sender.Params[prmDirInf]+'.*'); fl:=true;
          if TmpDir='' then begin
            if not FileStreamCreateMsg(fTo,fo,Sender,true) then break;
            try
              if fo.Write(pointer(st)^,sz)<>sz then fl:=false;
              if fo.Update then fl:=false;
            finally
              fo.Free;
            end;
          end
          else fl:=CopyFileOpt(fFrom,fTo,[],Attr);
          if not fl then begin
            if GetLastError=ERROR_WRITE_PROTECT
            then fl:=ask(['На дискете установлена защита от записи.',
              'Снимите защиту, вставьте дискету и нажмите <Enter>.','','Продолжить ?'])
            else fl:=ask(['Не удалось произвести копирование на дискету.',
              'Воспользуйтесь другой дискетой.','','Продолжить ?']);
            if fl then continue
            else begin
              Sender.Abort; break;
            end;
          end;
          Sender.Refresh;
          if CheckFlop then begin
            mess_ok(['Для достоверности проверки копирования на дискету',
              'желательно достать дискету из дисковода '+drvTo,
              'и вставить её обратно.']);
            if NewStat('Проверка копирования на дискете') then break;
            if not FileVerCopy(fTo) then begin
              mess_ok(['Внимание! На дискете есть сбои.','','Воспользуйтесь другой дискетой.']);
              continue;
            end;
          end;
          if nd=PackInfo.cntVol then break;
          nprior:=nd; Inc(nd); s:=extfilepck(nd);
        end;
        if Sender.Aborted then break;
        if TmpDir='' then break;
        if not ask(['Сделать ещё одну копию ?']) then break;
        lmsg:=true;
      end;
    finally
      fi.Free;
    end;
  DelStack;
end;

// Разархивация
function TPacker.DoRepack;
begin
  AddStack('TPacker.DoRepack');
  if not Assigned(DirInf) and IsPassNeed then begin
    CheckState:=pchkRepck;
    try
      result:=not ShowStat('Проверка архива',StRepck);
    finally
      CheckState:=pchkNone;
    end;
  end
  else result:=true;
  if result then result:=not ShowStat(CaptDef(IfThen(Assigned(DirInf),'Чтение информации об архиве',
  	'Копирование данных из архива')),StRepck,[LongInt(DirInf)]);
  DelStack;
end;

procedure ClearPath(const aPath: string);
var k: longint;
  sr: TSearchRec;
  s: string;
begin
  k:=FindFirst(aPath+'*',faAnyFile,sr);
  while (k=0) do begin
    s:=aPath+sr.Name;
    if ((sr.Attr and faDirectory)=0)
      then DelFileAtr(s)
    else if NotSysDir(sr) then begin
      ClearPath(s+PathDelim); DirRemove(s);
    end;
    k:=FindNext(sr);
  end;
  SysUtils.FindClose(sr);
end;

procedure TPacker.StRepck;
  function brk(usl: boolean; const msg: string): boolean;
  begin
    AddStack('TPacker.StRepck.brk');
    result:=usl;
    if result then mess_ok(['Нарушена структура заголовка архива:',msg+'.'],PckFullName);
    DelStack;
  end;
  function MsgSpaceDrive(const dir: TFileName; sz: longword; const msg: string): boolean;
  begin
    AddStack('TPacker.StRepck.MsgSpaceDrive');
    result := sz>MyDiskFree(dir);
    if result then begin
    	mess_ok(['На диске '+ExtractFileDrive(dir)+Format(' необходимо не менее %d байт',[sz]),
      	'для '+msg+'.']);
      Sender.Abort;
    end;
    DelStack;
  end;
var i,lr: byte;
	function Stat1(const Capt: string; Proc: TStatEvent; const Prm: array of variant; ce: boolean): boolean;
  begin
    AddStack('TPacker.StRepck.Stat1');
    result:=true;
    if not SayStat(Sender,'',Capt,i/lr) then
      if ShowStat(Capt,Proc,Prm,ce) then Sender.Abort else result:=false;
    Inc(i);
    DelStack;
  end;
var ost: longint;
  pzh: Int64;
  ls: TStringList;
  DirInf,pdi: PPckDirInf;
  sVol,s: string;
  pfi: PPckFileInf;
  cs: TCryptoStream;
  b: boolean;
  SvInf: TFileStreamSave;
label lend,lend1;
begin
	ost:=AddStack('TPacker.StRepck');
  UserAborted:=false; sVol:='';
  if CheckState=pchkNone then begin
  	DirInf:=PointerVar(Sender.Params[0]); ArhNameExt; lFlop:=IsFlopDrive(PckFullName);
  end
  else DirInf:=nil;
  if FileStreamCreate(SvInf,PckFullName,Sender) then
    try
      try
        Vers:=1; i:=1; lr:=1;
        if WithHead then begin
          if not FGetPackInfo and (Vers>=1) then goto lend;
          ReadErr(ChkCnt,szi);
          if Assigned(DirInf) then pdi:=DirInf
          else begin
            lr:=3;
            if (CheckState=pchkNone) and (PackInfo.cntVol>1) then begin
              sVol:=EmpCurDir(TmpDir)+TmpFile; Inc(lr);
            end;
            pzh:=FileStream.Position;
            if brk(ChkCnt>FileStream.Size-FileStream.Position,
              'размер заголовка превышает размер архива') then goto lend;
            if Stat1('Проверка контрольной суммы',StRepckChk,[0],Sender.FCanEsc) then goto lend;
            if brk(ChkSum<>0,'ошибка контрольной суммы') then goto lend;
            FileStream.Position:=pzh;
            pdi:=DirInfCreate;
          end;
        end else begin
        	szi64r:=szi; pdi:=DirInfCreate;
          pdi.FileList:=TPackFileList.Create;
          with pdi.FileList do begin
            Capacity:=1; Sorted:=true; pfi:=ObjCreate(Add(ExtractFileName(PckFullName)));
          end;
          rdi64(pfi.l); pfi.p:=FileStream.Position;
        end;
        try
	        if WithHead then begin
            cs:=TCryptoStream.Create(nil,FKeyword);
            try
              b:=Stat1('Чтение заголовка',StRepckHead,[LongInt(pdi),longint(cs)],Sender.FCanEsc);
            finally
              cs.Free;
            end;
            if b then goto lend1;
          end;
          if not Assigned(DirInf) then begin
		        if WithHead then begin
              if sVol<>'' then begin
                pzh:=FileStream.Position; FileStreamFree(SvInf,Sender,false); DelFileAtr(sVol);
                if MsgSpaceDrive(sVol,PackInfo.szPck,IfThen(lFlop,'копирования архива с дискет',
                  'соединения файлов архива')) then goto lend1;
                if Stat1(IfThen(lFlop,'Копирование архива с дискет','Соединение файлов архива'),
                  StRepckGum,[sVol],Sender.FCanEsc) then goto lend1;
                if not FileStreamCreate(SvInf,sVol,Sender) then goto lend1;
                FileStream.Position:=pzh;
              end;
            end;
            if CheckState=pchkNone then
              if MsgSpaceDrive(sPath,PackInfo.szFiles,'копирования данных из архива') then goto lend1;
            ls:=SortStrListCreate;
            try
              b:=false;
              s:='ВОЗМОЖНО ВВЕДЁН НЕВЕРНЫЙ ПАРОЛЬ!';
              if not Stat1('Чтение данных',StRepckDir,
              [IfThen(CheckState=pchkNone,sPath),LongInt(pdi),LongInt(ls),longint(@b)],Sender.FCanEsc)
              and (ls.Count>0) and WithHead then begin
                if FKeyword<>'' then begin
                  ls.Sorted:=false;
                  ls.Insert(0,StringOfChar('-',length(s)));
                  ls.Insert(0,s);
                end;
                if CheckState=pchkRepck then meserr(s,'Ошибка проверки архива')
                else ListF2Down(ls.Text,nil,nil,0,'Browl','',nil,0,nil,nil,nil,nil,nil,
                  'Ошибка '+IfThen(CheckState=pchkNone,'разархивации','упаковки')+' файлов:',false);
                if (CheckState=pchkNone)and(FKeyword<>'')and(IsMaskFiles(sPath+'*.*',[fmFiles,fmDir])) then begin
                  if (Ask(['Возможно, папка: ',sPath,'содержит ненужные файлы.','Очистить её?'])) then begin
                    ClearPath(sPath);
                  end;
                end;
                Sender.Abort;
              end else begin
                if (CheckState=pchkNone)and(b)and(FKeyword<>'') then begin
                  if (not IsMaskFiles(sPath+'*.*',[fmFiles,fmDir])) then mess_ok([s])
                  else begin
                    if (Ask([s,'Папка: '+sPath,'содержит файлы.','Очистить её?'])) then begin
                      ClearPath(sPath);
                    end;
                  end;
                end;
              end;
            finally
              ls.Free;
            end;
          end;
lend1:
        finally
        	if not Assigned(DirInf) then DirInfFree(pdi);
        end;
lend:
      except
        on E:Exception do if not IsErr(E,[],ost,Sender) then raise
      end;
    finally
      FileStreamFree(SvInf,Sender);
    end;
  if sVol<>'' then DelFileAtr(sVol);
  DelStack;
end;

function TPacker.FGetPackInfo;
  function brk(usl: boolean; const msg: string): boolean;
  begin
    AddStack('TPacker.FGetPackInfo.brk');
    result:=usl;
    if result then mess_ok(['Нарушена структура комментария архива:',msg+'.'],PckFullName);
    DelStack;
  end;
var c: char;
	pzi: Int64;
label lend;
begin
	AddStack('TPacker.FGetPackInfo');
  ReadErr(sr.s,szi); result:=false; IsPassNeed:=false;
  if brk(sr.crd>LastVers,Format('версия архива (%d) больше максимально поддерживаемой версии (%d)',[sr.crd,LastVers])) then goto lend;
  ChkSumFile:=0; Vers:=sr.crd; szi64r:=IfThen(Vers<4,szi,szi64);
  if Vers>=1 then begin
    if Vers=3 then IsPassNeed:=true
    else if Vers>=4 then ReadErr(IsPassNeed,SizeOf(boolean));
    ReadErr(ChkSum,szi); ReadErr(ChkCnt,szi);
    if brk(ChkCnt>FileStream.Size-FileStream.Position,
      'размер комментария превышает размер архива') then goto lend;
    pzi:=FileStream.Position;
    while ChkCnt>0 do begin
      ReadErr(c,1); Dec(ChkSum,Ord(c)); Dec(ChkCnt);
    end;
    if brk(ChkSum<>0,'ошибка контрольной суммы') then goto lend;
    FileStream.Position:=pzi; ReadErr(PackInfo.cntVol,1);
    rdi64(PackInfo.szFiles); rdi64(PackInfo.szPck);
    if brk(PackInfo.szPck=0,'испорчен заголовок архива') then goto lend;
    rds(Comment,nil);
    ReadErr(ChkSum,szi);
    if Vers>=2 then begin
      pzi:=FileStream.Position; FileStream.Seek(-szi,soFromEnd);
      ReadErr(ChkSumFile,szi); FileStream.Position:=pzi;
    end;
    result:=true;
  end;
lend:
  DelStack;
end;

procedure TPacker.StRepckChk;
var ost,i: longint;
	c: char;
begin
	ost:=AddStack('TPacker.StRepckChk');
  try
    for i:=1 to ChkCnt do begin
      if SayStat(Sender,'','',i/ChkCnt) then break;
      ReadErr(c,1); Dec(ChkSum,Ord(c));
    end;
  except
    on E:Exception do if not IsErr(E,[],ost,Sender) then raise
  end;
  DelStack;
end;

procedure TPacker.StRepckHead;
var cs: TCryptoStream;
  i,l: longword;
  function rdStat(var s: string): boolean;
  begin
    AddStack('TPacker.StRepckHead.rdStat');
    rds(s,cs); result:=SayStat(Sender,'',s,i/l);
    DelStack;
  end;
var ost: longword;
  pfi: PPckFileInf;
  s: string;
begin
	ost:=AddStack('TPacker.StRepckHead');
  try
    ReadErr(l,szi);
    cs:=PointerVar(Sender.Params[1]);
    with PckDirInfVar(Sender.Params[0])^ do begin
      if l>0 then begin
        FileList:=TPackFileList.Create;
        with FileList do begin
          Capacity:=l;
          for i:=1 to l do begin
            if rdStat(s) then break;
            pfi:=ObjCreate(Add(s)); rdi64(pfi.p); rdi64(pfi.l);
            if Vers>=1 then begin
              ReadErr(sr.crd,szi); pfi.d:=sr.i;
            end;
          end;
        end;
      end;
      if not Sender.Aborted then begin
        ReadErr(l,szi);
        if l>0 then begin
          DirList:=TPackDirList.Create; DirList.Capacity:=l; Sender.ClearCurTime;
          with DirList do for i:=1 to l do begin
            if rdStat(s) then break;
            if ShowStat(s,StRepckHead,[LongInt(ObjCreate(Add(s))),longint(cs)],Sender.FCanEsc) then begin
              Sender.Abort; break;
            end;
          end;
        end;
      end;
    end;
  except
    on E:Exception do if not IsErr(E,[],ost,Sender) then raise
  end;
  DelStack;
end;

procedure StRepckGumFile(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var i,f,l1,lr: longint;
  l: Int64;
	s: string;
  pck: TPacker;
begin
	AddStack('Pack.StRepckGumFile');
  f:=Params[0]; l:=Params[2]; lr:=Params[3]; pck:=PointerVar(Params[4]);
  SetLength(s,ArhBlockSize);
  for i:=1 to lr do begin
    if pck.SayStat(Sender,'','',i/lr) then break;
    l1:=min(l,ArhBlockSize); l1:=FileRead(f,Pointer(s)^,l1);
    if l1<0 then begin
      mess_ok(['Ошибка чтения файла:',Params[1]]); Aborted:=true; break;
    end;
    pck.FileStream.WriteBuffer(pointer(s)^,l1); Dec(l,ArhBlockSize);
  end;
  DelStack;
end;

procedure TPacker.StRepckGum;
var i,f,l,lr: longint;
	s: string;
  SvInf: TFileStreamSave;
begin
	AddStack('TPacker.StRepckGum');
  if FileStreamCreate(SvInf,Sender.Params[0],Sender,true) then
    try
      for i:=1 to PackInfo.cntVol do begin
        s:=PckFileName+extfilepck(i);
        if lFlop then begin
          if SayStat(Sender,'',Format('Дискета: %d из %d',[i,PackInfo.cntVol]),i/PackInfo.cntVol) then break;
          if not diskflwait(PckFileName,i) then begin
            Sender.Abort; break;
          end;
          Sender.Refresh;
        end
        else if SayStat(Sender,'',s,i/PackInfo.cntVol) then break;
        if FileOpenMsg(s,f,Sender) then
          try
            l:=GetFileSize(f); lr:=CntBlock(l);
            if ShowStat(s,StRepckGumFile,[f,s,l,lr,longint(Self)],lr) then Sender.Abort;
          finally
            FileClose(f);
          end;
        if Sender.Aborted then break;
      end;
    finally
      FileStreamFree(SvInf);
    end;
  DelStack;
end;

procedure StRepckFile(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var f,i,lr,l1,ost: longint;
  l: Int64;
	s: string;
  pck: TPacker;
begin
	ost:=AddStack('Pack.StRepckFile');
  pck:=PointerVar(Params[0]);
  try
    l:=Int064(Params[1]); f:=Params[3]; lr:=Params[4]; SetLength(s,min(l,ArhBlockSize));
    for i:=1 to lr do begin
      if pck.SayStat(Sender,'','',i/lr) then break;
      l1:=min(l,ArhBlockSize); pck.ReadErr(pointer(s)^,l1,true);
      if pck.CheckState=pchkNone then FileWrite(f,pointer(s)^,l1);
      Dec(l,ArhBlockSize);
    end;
  except
    on E:Exception do if pck.IsErr(E,[],ost)
    then BoolVar(Params[2])^:=true
    else raise
  end;
  DelStack;
end;

procedure TPacker.StRepckDir;
var path,s,s1: string;
	i,j,f,lr: longint;
  l: Int64;
  pfi: PPckFileInf;
  fl: boolean;
  cs: TCryptoStream;
  ls: TStringList;
begin
	AddStack('TPacker.StRepckDir');
  path:=Sender.Params[0]; ls:=PointerVar(Sender.Params[2]);
  if CheckState=pchkNone then
    if not ForceDirMsg(path) then begin
      Sender.Abort; BoolVar(Sender.Params[3])^:=true;
    end;
  with PckDirInfVar(Sender.Params[1])^ do begin
    if not Sender.Aborted and Assigned(FileList) then with FileList do begin
      lr:=Count;
      for i:=0 to lr-1 do begin
        s:=Strings[i]; s1:=path+s;
        if SayStat(Sender,'',s,(i+1)/lr) then break;
        fl:=false; pfi:=GetObj(i); f:=0;
        if CheckState=pchkNone then begin
          if MyFileExists(s1) then
            if not DelFileAtr(s1) then begin
              mess_ok(['Ошибка записи в файл:',s1]); Sender.Abort;
            end;
          if not Sender.Aborted then f:=FileBufCreate(s1);
        end;
        if not Sender.Aborted then
          try
            if (pfi^.p>0) and (s<>IndFile) then begin
              FileStream.Position:=pfi^.p;
              cs:=TCryptoStream.Create(FileStream,FKeyword);
              try
                PckStream:=TZDecompressionStream.Create(cs);
                try
                  l:=pfi^.l; j:=CntBlock(l);
                  if ShowStat(s,StRepckFile,[longint(Self),IntToStr(l),LongInt(@fl),f,j],j,Sender.FCanEsc) then begin
                    Sender.Abort; break;
                  end;
                finally
                  PckStream.Free;
                end;
              finally
                cs.Free;
              end;
            end;
            if (CheckState=pchkNone) and (Vers>=1) then FileSetDate(f,pfi^.d);
          finally
            if CheckState=pchkNone then FileClose(f);
          end;
        if fl then begin
          ls.Add(s1);
          if CheckState=pchkNone then DelFileAtr(s1);
        end;
      end;
    end;
    if not Sender.Aborted and Assigned(DirList) then with DirList do begin
      Sender.ClearCurTime; lr:=Count;
      for i:=0 to lr-1 do begin
        s:=Strings[i];
        if SayStat(Sender,'',s,(i+1)/lr) then break;
        if GetObj(i,Sender,1) then begin
          Sender.Params[0]:=path+s+PathDelim;
          if ShowStat(s,StRepckDir,Sender.Params,Sender.FCanEsc) then begin
            Sender.Abort; break;
          end;
        end;
      end;
    end;
  end;
  DelStack;
end;

procedure TPacker.ReadErr;
begin
	AddStack('TPacker.ReadErr');
  if lPck then PckStream.ReadBuffer(Buffer,Count) else FileStream.ReadBuffer(Buffer,Count);
  DelStack;
end;

procedure TPacker.rdi64;
begin
  AddStack('TPacker.rdi64');
  result:=0; //ReadErr(result,szi64r);
  FileStream.ReadBuffer(result,szi64r);
  DelStack;
end;

function TPacker.GetPackInfo;
var ost: longint;
  oms: boolean;
  SvInf: TFileStreamSave;
begin
	ost:=AddStack('TPacker.GetPackInfo');
  ArhNameExt; result:=false;
  if MyFileExists(PckFullName) then
    if FileStreamCreate(SvInf,PckFullName) then begin
      oms:=MessagesHidden; MessagesHidden:=true;
      try
        try
          result:=FGetPackInfo;
        except
          on E:Exception do if IsErr(E,[],ost) then result:=false else raise
        end;
      finally
        FileStreamFree(SvInf); MessagesHidden:=oms;
      end;
    end;
  DelStack;
end;

function TPacker.IsErr;
begin
  result:=IfThen(pckErrWrite in Opt,
    (E is EZCompressionError) or (E is EWriteError),
    (E is EZDecompressionError) or (E is EReadError));
  if result then begin
    if ost<>NegDef then SetStack(ost);
    if Assigned(Sender) then begin
    	if not(pckErrWrite in Opt) then mess_ok(['Ошибка чтения файла архива: ',PckFullName]);
      Sender.Abort;
    end;
    if (pckErrWrite in Opt) and (pckErrMsg in Opt) then begin
      mess_ok(['Недостаточно места на диске '+ExtractFileDrive(PckFullName),'для создания архива.']);
      PckStream.Aborted:=true;
    end;
  end;
end;

class function TPacker.DirInfCreate;
begin
  AddStack('TPacker.DirInfCreate');
  New(result); ZeroMemory(result,SizeOf(result^));
  DelStack;
end;

class procedure TPacker.DirInfFree;
var i: longint;
  pdi: PPckDirInf;
begin
  AddStack('TPacker.DirInfFree');
  with DirInf^ do begin
    FileList.Free;
    if Assigned(DirList) then with DirList do begin
      for i:=0 to Count-1 do if GetObj(i,pdi) then DirInfFree(pdi,false);
      Destroy;
    end;
  end;
  if lFree then Dispose(DirInf);
  DelStack;
end;

class function TPacker.CntBlock;
begin
  AddStack('TPacker.CntBlock');
  result := l div l1;
  if (result=0) and (l>0) or ((result mod l1) > 0) then Inc(result);
  DelStack;
end;

end.
