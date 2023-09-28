unit GGI;

interface

{$I LIBTEST}

uses SysUtils;

const IniExt = '.GGI';

function GetIniFileName(const FileName: TFileName; DelOldIni: boolean = true): TFileName;
procedure GetIniFileNameSelf(var FileName: TFileName; DelOldIni: boolean = true);

implementation

uses Windows;

function GetIniFileName;
var fl: boolean;
begin
  if AnsiUpperCase(ExtractFileExt(FileName))='.INI' then begin
    result:=ChangeFileExt(FileName,IniExt);
    if FileExists(result)
      then fl:=true
    else if FileExists(FileName)
      then fl:=CopyFile(PChar(FileName),PChar(result),false)
    else fl:=false;
    if fl and DelOldIni then for fl:=false to true do begin
{$IFDEF MSWINDOWS}
      if fl then SetFileAttributes(PChar(FileName),0);
{$ENDIF}
      if SysUtils.DeleteFile(FileName) then break;
    end;
  end
  else result:=FileName;
end;

procedure GetIniFileNameSelf(var FileName: TFileName; DelOldIni: boolean = true);
begin
  FileName:=GetIniFileName(FileName,DelOldIni);
end;

end.
