unit InfoBrw;

interface

uses ExptIntf,EditIntf,VirtIntf,SysUtils,DB,Windows,Variants,StdCtrls,Forms,Registry,Math;

type
	TCustomExpert = class(TIExpert)
  public
    function GetAuthor: string; override; stdcall;
    function GetComment: string; override; stdcall;
    function GetPage: string; override; stdcall;
    function GetGlyph: HICON; override; stdcall;
		function GetStyle: TExpertStyle; override;
		function GetState: TExpertState; override;
		procedure Execute; override;
    procedure ExecPrm(const pDelphi,LibSearchPath: string); virtual; abstract;
  end;

	TEInfoBrowser = class(TCustomExpert)
  public
		function GetName: string; override;
		function GetIDString: string; override;
		function GetMenuText: string; override;
    procedure ExecPrm(const pDelphi,LibSearchPath: string); override;
  end;

	TEDfmFind = class(TCustomExpert)
  public
		function GetName: string; override;
		function GetIDString: string; override;
		function GetMenuText: string; override;
    procedure ExecPrm(const pDelphi,LibSearchPath: string); override;
  end;

	TEIncDFind = class(TCustomExpert)
  public
		function GetName: string; override;
		function GetIDString: string; override;
		function GetMenuText: string; override;
    procedure ExecPrm(const pDelphi,LibSearchPath: string); override;
  end;

	TEStackEr = class(TCustomExpert)
  public
		function GetName: string; override;
		function GetIDString: string; override;
		function GetMenuText: string; override;
    procedure ExecPrm(const pDelphi,LibSearchPath: string); override;
  end;

procedure Register;

implementation

uses InfoReg,FIBTree,FDfmFind,FIncDFind,FStackEr;

procedure HandleException;
begin
  ToolServices.RaiseException(ReleaseException);
end;

{ TCustomExpert }
function TCustomExpert.GetAuthor;
begin
  result:='';
end;

function TCustomExpert.GetComment;
begin
  result:='';
end;

function TCustomExpert.GetPage;
begin
  result:='';
end;

function TCustomExpert.GetGlyph;
begin
  result:=0;
end;

function TCustomExpert.GetStyle;
begin
	result:=esStandard;
end;

function TCustomExpert.GetState;
begin
  try
    result:=[esEnabled];
  except
    HandleException;
  end;
end;

procedure TCustomExpert.Execute;
var pDelphi,LibSearchPath: string;
begin
  try
    GetInfoReg(ToolServices.GetBaseRegistryKey,pDelphi,LibSearchPath); ExecPrm(pDelphi,LibSearchPath);
  except
    HandleException;
  end;
end;

{ TEInfoBrowser }
function TEInfoBrowser.GetName;
begin
  try
    result:='Классы OURLIB';
  except
    HandleException;
  end;
end;

function TEInfoBrowser.GetIDString;
begin
  try
    result:='Ourlib InfoBrowser';
  except
    HandleException;
  end;
end;

function TEInfoBrowser.GetMenuText;
begin
  try
    result:='Классы OURLIB';
  except
    HandleException;
  end;
end;

procedure IBProcLoad(const fn,s: string; Pos: longint);
var i: longint;
  ep: TEditPos;
  cp: TCharPos;
begin
  cp.Line:=1; cp.CharIndex:=0;
  for i:=Pos downto 1 do begin
  	if s[i]=#10 then Inc(cp.Line);
  	if cp.Line=1 then Inc(cp.CharIndex);
  end;
  ToolServices.OpenFile(fn);
  with ToolServices.GetModuleInterface(fn).GetEditorInterface.GetView(0) do begin
  	ConvertPos(false,ep,cp); CursorPos:=ep;
    ep.Col:=1; ep.Line:=max(1,ep.Line-round(ViewSize.cy/2)); TopPos:=ep;
  end;
end;


procedure TEInfoBrowser.ExecPrm;
begin
  TIBTree.Execute(ToolServices.GetProjectName,pDelphi,LibSearchPath,IBProcLoad);
end;

{ TEDfmFind }
function TEDfmFind.GetName;
begin
  try
    result:='Поиск текста в .DFM';
  except
    HandleException;
  end;
end;

function TEDfmFind.GetIDString;
begin
  try
    result:='Ourlib DfmFind';
  except
    HandleException;
  end;
end;

function TEDfmFind.GetMenuText;
begin
  try
    result:='Поиск текста в .&DFM';
  except
    HandleException;
  end;
end;

procedure DFProcLoad(const fn: string);
begin
  ToolServices.OpenFile(fn+'.PAS');
end;

procedure TEDfmFind.ExecPrm;
begin
  TDfmFind.Execute(pDelphi,DFProcLoad);
end;

{ TEIncDFind }
function TEIncDFind.GetName;
begin
  try
    result:='Поиск для использования функций';
  except
    HandleException;
  end;
end;

function TEIncDFind.GetIDString;
begin
  try
    result:='Ourlib IncDFind';
  except
    HandleException;
  end;
end;

function TEIncDFind.GetMenuText;
begin
  try
    result:='Поиск для использования функций (&I)';
  except
    HandleException;
  end;
end;

procedure LoadFileProc(const fn: string; ARow,ACol: longint);
var ep: TEditPos;
  cp: TCharPos;
begin
  ToolServices.OpenFile(fn);
  with ToolServices.GetModuleInterface(fn).GetEditorInterface.GetView(0) do begin
    cp.Line:=ARow+1; cp.CharIndex:=ACol; ConvertPos(false,ep,cp); CursorPos:=ep;
    ep.Col:=1; ep.Line:=max(1,ep.Line-round(ViewSize.cy/2)); TopPos:=ep;
  end;
end;

procedure TEIncDFind.ExecPrm;
begin
  TIncDFind.Execute(pDelphi,LoadFileProc);
end;

{ TEStackEr }
function TEStackEr.GetName;
begin
  try
    result:='Ошибки стека';
  except
    HandleException;
  end;
end;

function TEStackEr.GetIDString;
begin
  try
    result:='Ourlib StackEr';
  except
    HandleException;
  end;
end;

function TEStackEr.GetMenuText;
begin
  try
    result:='Ошибки стека (&E)';
  except
    HandleException;
  end;
end;

procedure TEStackEr.ExecPrm;
begin
  TStackEr.Execute(pDelphi,LoadFileProc);
end;

procedure Register;
begin
  RegisterLibraryExpert(TEInfoBrowser.Create);
	RegisterLibraryExpert(TEDfmFind.Create);
	RegisterLibraryExpert(TEIncDFind.Create);
	RegisterLibraryExpert(TEStackEr.Create);
end;

end.
