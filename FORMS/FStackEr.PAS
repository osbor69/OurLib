unit FStackEr;

interface

uses
  Classes, Controls, ExtCtrls, Menus, Grids, IniFiles,
  FRMEMPTY, Keylb, Fpanel, FFldedit, DirGet, RecVal, KeyMenu, PnlEdit, StrBrowl, Askp,
    CCodeGet;

type
  TStackErLoadFileProc = procedure(const fn: string; ARow,ACol: longint);

  TStackEr = class(TFormEmp)
    pnEd: TPanelEdit;
    pnLs: TRbPanel;
    KeyMenu1: TKeyMenu;
    Rec: TRecVal;
    EPath: TFldEdit;
    DirGet1: TDirGet;
    sb: TStringBrowl;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    function pnEdValid(Sender: TObject): Boolean;
    function EPathCheck(Sender: TObject): Boolean;
    procedure pnEdEnter(Sender: TObject);
    procedure sbEnter(Sender: TObject);
    procedure sbExit(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    fIni: TIniFile;
    pDelphi: string;
    PrLoad: TStackErLoadFileProc;
    procedure PrFind(Sender: TAsk);
    procedure ProcKey(Key: longint; tw: TWinControl);
    procedure fIniOpen;
  public
    { Public declarations }
    class procedure Execute(const PathDelphi: string; ProcLoad: TStackErLoadFileProc);
  end;

var
  StackEr: TStackEr;

implementation

{$R *.dfm}

uses SysUtils,Forms,Math, 
  MyTypes,My_pr,GGI;

const Section = 'StackEr';

{ TStackEr }
procedure TStackEr.FormCreate(Sender: TObject);
begin
  AddStack('TStackEr.FormCreate',Self);
  inherited;
  sb.Init;
  fIniOpen;
  try
    Rec['Path']:=fIni.ReadString(Section,'Path','');
    pnEd.FldReadAll([ferdSvOld,ferdFromShow]);
  finally
    fIni.Free;
  end;
  DelStack;
end;

class procedure TStackEr.Execute;
begin
  AddStack('TStackEr.Execute');
  TInitFIni.Init(Application.MainForm); CreateForm(TStackEr,StackEr);
  StackEr.pDelphi:=CorrDir(PathDelphi); StackEr.PrLoad:=ProcLoad; StackEr.ShowModal;
  DelStack;
end;

procedure TStackEr.fIniOpen;
begin
  fIni:=TIniFile.Create(GetIniFileName(pDelphi+'MYDELPHI.INI'));
end;

function TStackEr.EPathCheck(Sender: TObject): Boolean;
begin
  AddStack('TStackEr.EPathCheck',Self);
  result:=not empty(Rec['Path']);
  DelStack;
end;

function TStackEr.pnEdValid(Sender: TObject): Boolean;
begin
  AddStack('TStackEr.pnEdValid',Self);
  fIniOpen;
  try
    fIni.WriteString(Section,'Path',Rec['Path']);
  finally
    fIni.Free;
  end;
  sb.Init; SetRedraw(sb);
  result:=mess_wait([' '],PrFind,[CorrDir(Rec['Path'])],true,Caption);
  SetRedraw(sb,rdrwSet);
  DelStack;
end;

procedure TStackEr.PrFind;
const
  aFunc: array[boolean] of record
    nm: string;
    l: byte;
  end = ((nm:'ADDSTACK('''),(nm:'DELSTACK'));
  procedure FindPath(const path: string);
  var af: TArrStr;
    j: longint;
    procedure AddFile(r,c: longint; lDel: boolean);
    var i: longint;
      rc: TWord2DWord;
    begin
      AddStack('TStackEr.PrFind.FindPath.AddFile',Self);
      i:=sb.RowCount-IfThen(empty(sb.Cells[0,sb.FixedRows]),1);
      sb.RowCount:=i+1;
      sb.Cells[0,i]:=af[j];
      sb.Cells[1,i]:=path;
      sb.Cells[2,i]:=aFunc[lDel].nm;
      rc.w1:=r; rc.w2:=c-1; sb.Objects[2,i]:=Pointer(rc.dw);
      DelStack;
    end;
  var i,r,c,l,f,lv,ra,ca,lf: longint;
    a: TArrStr;
    lDel,lFind: boolean;
  begin
    AddStack('TStackEr.PrFind.FindPath',Self);
    if not Sender.SayCapt([path]) then begin
      GetMaskFiles(af,lf,Sender.Params[0]+path+'*.PAS',[],[msfNoUpper]);
      GetMaskFiles(af,lf,Sender.Params[0]+path+'*.DPR',[],[msfAdd,msfNoUpper,msfSort]);
      for j:=0 to lf-1 do begin
        lv:=0; ra:=0; ca:=0;
        for r:=0 to LsArrDynamic(StrTran(StrTran(AnsiUpperCase(GetStrFile(Sender.Params[0]+path+af[j])),
        CRLF,#10),#13,#10),a,#10)-1 do
          if not AnsiStartsArr(['PROCEDURE','FUNCTION'],TrimLeft(a[r])) then begin
            c:=1; l:=Length(a[r]);
            while c<=l do begin
              for lDel:=false to true do begin
                i:=c; lFind:=true;
                with aFunc[lDel] do for f:=1 to l do begin
                  if i<=l then if a[r][i]=nm[f] then begin
                    Inc(i); continue;
                  end;
                  lFind:=false; break;
                end;
                if lFind then begin
                  Inc(lv,aSign[lDel]);
                  if not lDel then begin
                    ra:=r; ca:=c;
                  end
                  else if lv<0 then AddFile(r,c,true);
                  c:=i-1; break;
                end;
              end;
              Inc(c);
            end;
          end;
        if lv>0 then AddFile(ra,ca,false);
      end;
      GetMaskFiles(af,lf,Sender.Params[0]+path+'*.*',[fmDir],[msfNoUpper,msfSort]);
      for j:=0 to lf-1 do begin
        FindPath(path+af[j]+PathDelim);
        if Sender.Aborted then break;
      end;
    end;
    DelStack;
  end;
var lDel: boolean;
begin
  AddStack('TStackEr.PrFind',Self);
  for lDel:=false to true do with aFunc[lDel] do l:=Length(nm);
  FindPath(''); sb.AdjustColsWidth;
  DelStack;
end;

procedure TStackEr.pnEdEnter(Sender: TObject);
begin
  AddStack('TStackEr.pnEdEnter',Self);
  inherited;
  pnEd.FillKeyLb;
  DelStack;
end;

procedure TStackEr.sbEnter(Sender: TObject);
begin
  AddStack('TStackEr.sbEnter',Self);
  inherited;
  if not empty(sb.Cells[0,sb.FixedRows]) then begin
    KeyLb1.SetKey(K_Enter,'Загрузить','',ProcKey,'StackEr',kmList); KeyLb1.Redrw;
  end;
  DelStack;
end;

procedure TStackEr.sbExit(Sender: TObject);
begin
  AddStack('TStackEr.sbExit',Self);
  KeyLb1.DelKey(K_All,'StackEr'); KeyLb1.Redrw;
  DelStack;
end;

procedure TStackEr.ProcKey;
begin
  AddStack('TStackEr.ProcKey',Self);
  SetModalResult(mrOk);
  if Assigned(PrLoad) then Timer1.Enabled:=true;
  DelStack;
end;

procedure TStackEr.Timer1Timer(Sender: TObject);
var rc: TWord2DWord;
begin
  AddStack('TStackEr.Timer1Timer',Self);
  Timer1.Enabled:=false;
  with sb,rc do begin
    dw:=LongWordObj(2,Row); PrLoad(CorrDir(Rec['Path'])+Cells[1,Row]+Cells[0,Row],w1,w2);
  end;
  DelStack;
end;

end.
