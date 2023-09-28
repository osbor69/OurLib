unit InfoReg;

interface

procedure GetInfoReg(const RegDelphi: string; var pDelphi,LibSearchPath: string);

implementation

uses Windows,Registry,SysUtils;

procedure GetInfoReg;
begin
  pDelphi:=''; LibSearchPath:='';
  with TRegistry.Create do
    try
      RootKey:=HKEY_CURRENT_USER;
      if OpenKeyReadOnly(RegDelphi) then begin
        pDelphi:=Trim(ReadString('RootDir'));
        if OpenKeyReadOnly('Library')
        then LibSearchPath:=Trim(ReadString('Browsing Path'))+';'+Trim(ReadString('Search Path'));
      end;
      CloseKey;
    finally
      Free;
    end;
end;

end.
