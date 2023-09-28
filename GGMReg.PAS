unit GGMReg;

interface

const
  REGSTR_PATH_GGPROG = 'Software\GGProg';

  REGSTR_PATH_GGMASTER = 'Software\GGMaster';
  REGSTR_KEY_GGMASTER = 'Path';

  GGMasterExeFile = 'GGMaster.exe';
  GGMasterSetupExeFile = 'GGMasterSetup.exe';
  GGMasterEmpGdbFile = 'EMPGDB.DFM';
  GGMasterIniFile = 'GGMaster.ini';

  GGMasterTitle: array[1..2] of string =
    ('Управление программами Гуляев Г.Ю.'
    ,'Гуляев Г.Ю. (управление программами)'
    );

  GGMUtilSect = 'Util';
  GGMUtilSectBeg = 'GGM_';

  GGMSetupSection = 'GGMSetup';
  GGMSetupPath    = 'Path';
  GGMSetupUtils   = 'SetupUtils';
  GGMDelOneself   = 'DelOneself';
  GGMDelUtils     = 'DelUtils';

  GGMParamsSect = 'Params';

  GGMProgSect = 'Prog';

  GGMParamsSmail     = 'Smail';
  GGMParamsSmRmt     = 'Sm_Rmt';
  GGMParamsSmRmtFold = 'Sm_Rmt_Fold';
  GGMParamsBanPckLog = 'BanPckLog';

  GGMUtilDir     = 'Dir';
  GGMUtilUserDir = 'UserDir';
  GGMUtilExeFile = 'ExeFile';
  GGMUtilRegDir  = 'RegDir';
  GGMUtilRegExe  = 'RegExe';
  GGMUtilVers    = 'UtilVers';

  SmailDirClientSide = 'GGMASTER';

  SmailDirOnServer   = 'на сервере';

  SmailDirBox: array[boolean,boolean] of string = (('входящие','полученные'),('исходящие','отправленные'));

  NalLastCngFile = 'LASTCNG.DNF';

  MsgAutoBeg = 'АС:';

  CODSZ_ORG = 4;
  CODSZ_PRG = 3;
  CODSZ_NPP = 5;

  BwOlAuKod='C50';
  BwOlAuKo='N5';

function NalGetVers(const dir: string): string;

implementation

uses Classes,SysUtils,StrUtils;

function NalGetVers;
const sDel='/*'; lDel=Length(sDel);
var ls: TStringList;
	i,p: longint;
  s: string;
begin
  result:='';
  if FileExists(dir+NalLastCngFile) then begin
    ls:=TStringList.Create;
    try
      ls.LoadFromFile(dir+NalLastCngFile);
      for i:=ls.Count-1 downto 0 do begin
        s:=TrimLeft(ls[i]);
        if LeftStr(s,lDel)=sDel then begin
          Delete(s,1,lDel); p:=Pos(')',s);
          if p>0 then begin
            result:=Trim(LeftStr(s,p-1)); break;
          end;
        end;
      end;
    finally
      ls.Free;
    end;
  end;
end;

end.
