unit CopyData;

interface

uses Windows;

const
	idDbgOnOff = $E2E4;		// Отладчик включён/выключен
	idProgOn   = $E2E5;		// Запуск программы
	idProgDir  = $E2E6;		// Каталог для сохранения файла HISTORY.DER
	idProgData = $E2E7;		// Данные для отладчика
  idOffEsc   = $E2E8;		// Отмена выключения комьютера

function CopyDataAllWnd(Handle: HWND; cds: TCopyDataStruct): boolean;
procedure GetNextWindowSelf(var hWnd: HWND);
function HandleClassName(Handle: HWND): string;
function HandleWindowText(Handle: HWND): string;

implementation

uses Messages,SysUtils;

function CopyDataAllWnd;
var w: HWND;
begin
  w:=GetTopWindow(0); result:=false;
  while w<>0 do begin
    if HandleClassName(w)='TAPPLICATION' then
	    if SendMessage(w,WM_COPYDATA,Handle,longint(@cds))=LResult(cds.dwData) then begin
      	result:=true; break;
      end;
    GetNextWindowSelf(w);
  end;
end;

function HandleClassName;
const MaxClass=200;
begin
  SetLength(result,MaxClass); SetLength(result,GetClassName(Handle,pointer(result),MaxClass));
  result:=AnsiUpperCase(result);
end;

function HandleWindowText;
const MaxName=200;
begin
  SetLength(result,MaxName); SetLength(result,GetWindowText(Handle,pointer(result),MaxName));
  result:=AnsiUpperCase(result);
end;

procedure GetNextWindowSelf;
begin
  hWnd:=GetNextWindow(hWnd,GW_HWNDNEXT);
end;

end.
