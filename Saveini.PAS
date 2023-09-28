unit Saveini;

interface

{$I LIBTEST}
uses
  Windows,Forms,
  MyTypes;

procedure SaveIniForm(f: TForm);
function RestIniForm(f: TForm): TWindowPlacement;
function MsgSaveIni(f: TForm; Oper: TSaveIniOper; var Section: string): boolean;

implementation

uses Classes,Math,
  My_pr;

type TWsInt = 0..2;

const
	awstat1: array[TWindowState] of longint = (0,1,2);
	awstat2: array[TWsInt] of TWindowState = (wsNormal,wsNormal,wsMaximized);

procedure SaveIniForm;
var wp: TWindowPlacement;
  Section: string;
begin
	AddStack('SaveIni.SaveIniForm');
  if not FormWndDestroying and Assigned(InitFIni) then with f do if Handle<>0 then
    if MsgSaveIni(f,opsCanSave,Section) then begin
      InitFIni[fiSave].EraseSection(Section);
      wp.length:=SizeOf(wp); GetWindowPlacement(Handle,@wp);
      with InitFIni[fiSave],wp.rcNormalPosition do begin
        WriteInteger(Section,'WindowState',awstat1[WindowState]);
        WriteInteger(Section,'Left',Left);
        WriteInteger(Section,'Top',Top);
        WriteInteger(Section,'Width',Right-Left);
        WriteInteger(Section,'Height',Bottom-Top);
      end;
      MsgSaveIni(f,opsSave,Section);
    end;
  DelStack;
end;

function RestIniForm;
const a: array[TWsInt] of longint = (SW_HIDE,SW_HIDE,SW_MAXIMIZE);
var fl: boolean;
  Section: string;
  r,rs: TRect;
  w: TWsInt;
begin
	AddStack('SaveIni.RestIniForm');
	if Assigned(InitFIni) and (f.BorderStyle<>bsNone) then with f do
    if MsgSaveIni(f,opsRest,Section) then begin
      result.length:=SizeOf(result); GetWindowPlacement(Handle,@result);
      with InitFIni[fiSave] do begin
        r:=result.rcNormalPosition; Dec(r.Right,r.Left); Dec(r.Bottom,r.Top);
        if BorderStyle in [bsSizeable,bsSizeToolWin] then begin
          r.Right:=ReadInteger(Section,'Width',r.Right);
          r.Bottom:=ReadInteger(Section,'Height',r.Bottom);
        end;
        r.Left:=ReadInteger(Section,'Left',r.Left);
        r.Top:=ReadInteger(Section,'Top',r.Top);
        Inc(r.Right,r.Left); Inc(r.Bottom,r.Top);
        w:=EnsureRange(InitFIni[fiSave].ReadInteger(Section,'WindowState',
          awstat1[WindowState]),low(awstat2),high(awstat2));
        if (awstat2[w]=wsMaximized) and not(biMaximize in BorderIcons) then w:=0;
        if awstat2[w]=wsMaximized then fl:=true
        else begin
          rs:=SysWorkArea;
          fl := (min(rs.Right,r.Right)-max(rs.Left,r.Left)>=MinWidthForm(f))
            and (min(rs.Bottom,r.Bottom)-max(rs.Top,r.Top)>=SysMetric.iCaptionHeight*3);
        end;
        if fl then begin
          result.showCmd:=a[w]; result.rcNormalPosition:=r;
          SetWindowPlacement(Handle,@result);
          case awstat2[w] of
            wsNormal: WindowState:=wsNormal;
            wsMaximized: begin
              if not Visible then result.showCmd:=SW_HIDE;
              SetWindowPlacement(Handle,@result);
            end;
          end;
        end;
      end;
    end;
  DelStack;
end;

function MsgSaveIni;
begin
  AddStack('Saveini.MsgSaveIni');
  Section:=f.ClassName; ProcControlsMsg(f,WM_SAVEINI,byte(Oper),Longint(@Section)); result := Section<>'';
  DelStack;
end;

end.
