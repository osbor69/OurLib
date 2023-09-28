unit FDfmFind;

interface

uses
  Classes, Controls, ExtCtrls, Menus, Grids, IniFiles,
  FRMEMPTY, Keylb, Fpanel, FFldedit, DirGet, RecVal, KeyMenu, PnlEdit, ComboGet, StrBrowl,
    Askp, CCodeGet;

type
  TDFLoadFileProc = procedure(const fn: string);

  TDfmFind = class(TFormEmp)
    pnEd: TPanelEdit;
    pnLs: TRbPanel;
    KeyMenu1: TKeyMenu;
    Rec: TRecVal;
    EPath: TFldEdit;
    DirGet1: TDirGet;
    EStr: TFldEdit;
    StrGet: TComboGet;
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
    pDelphi,sFind: string;
    lFind: longint;
    PrLoad: TDFLoadFileProc;
    procedure PrFind(Sender: TAsk);
    procedure ProcKey(Key: longint; tw: TWinControl);
    procedure fIniOpen;
  public
    { Public declarations }
    class procedure Execute(const PathDelphi: string; ProcLoad: TDFLoadFileProc);
  end;

var
  DfmFind: TDfmFind;

implementation

{$R *.dfm}

uses SysUtils,Forms,Math,
  MyTypes,My_pr,GGI;

const Section = 'DfmFind';
  SectHist = 'DfmFindHistory';

{ TDfmFind }
procedure TDfmFind.FormCreate(Sender: TObject);
var i: longint;
begin
  AddStack('TDfmFind.FormCreate',Self);
  inherited;
  sb.Init;
  fIniOpen;
  try
    Rec['Path']:=fIni.ReadString(Section,'Path','');
    Rec['Str']:=fIni.ReadString(Section,'Str','');
    StrGet.Items.BeginUpdate;
    fIni.ReadSection(SectHist,StrGet.Items);
    for i:=0 to StrGet.Items.Count-1 do StrGet.Items[i]:=fIni.ReadString(SectHist,StrGet.Items[i],'');
    StrGet.Items.EndUpdate;
    pnEd.FldReadAll([ferdSvOld,ferdFromShow]);
  finally
    fIni.Free;
  end;
  DelStack;
end;

class procedure TDfmFind.Execute;
begin
  AddStack('TDfmFind.Execute');
  TInitFIni.Init(Application.MainForm); CreateForm(TDfmFind,DfmFind);
  DfmFind.pDelphi:=CorrDir(PathDelphi); DfmFind.PrLoad:=ProcLoad; DfmFind.ShowModal;
  DelStack;
end;

procedure TDfmFind.fIniOpen;
begin
  fIni:=TIniFile.Create(GetIniFileName(pDelphi+'MYDELPHI.INI'));
end;

function TDfmFind.EPathCheck(Sender: TObject): Boolean;
begin
  AddStack('TDfmFind.EPathCheck',Self);
  result:=not empty(Rec['Path']);
  DelStack;
end;

function TDfmFind.pnEdValid(Sender: TObject): Boolean;
var i: longint;
begin
  AddStack('TDfmFind.pnEdValid',Self);
  AddSzStrings(StrGet.Items,Rec['Str']); fIniOpen;
  try
    fIni.WriteString(Section,'Path',Rec['Path']);
    fIni.WriteString(Section,'Str',Rec['Str']);
    fIni.EraseSection(SectHist);
    for i:=0 to StrGet.Items.Count-1 do fIni.WriteString(SectHist,NumStr(i,10),StrGet.Items[i]);
  finally
    fIni.Free;
  end;
  sb.Init; SetRedraw(sb); sFind:=TrimUpper(Rec['Str']); lFind:=Length(sFind); 
  result:=mess_wait([' '],PrFind,[CorrDir(Rec['Path'])],true,Caption);
  SetRedraw(sb,rdrwSet);
  DelStack;
end;

procedure TDfmFind.PrFind;
  procedure FindPath(const path: string);
  const CntNum = 4;
  var ls: TStringList;
    i,j,l,f,n: longint;
    fn,s,s1: string;
    c: char;
  begin
    AddStack('TDfmFind.PrFind.FindPath',Self);
    if not Sender.SayCapt([path]) then begin
      ls:=TStringList.Create;
      try
        GetMaskFiles(ls,Sender.Params[0]+path+'*.DFM',[],[msfNoUpper,msfSort]); j:=0;
        while j<ls.Count do begin
          f:=1; fn:=Sender.Params[0]+path+ls[j];
          if FileExists(ChangeFileExt(fn,'.PAS')) then
            if lFind=0 then f:=0
            else begin
              s:=GetStrFile(fn); i:=1; l:=Length(s);
              while i<=l do begin
                c:=s[i];
                if c<>'''' then begin
                  if (c='#') and (i+CntNum<=l) then begin
                    s1:=Copy(s,i+1,CntNum); n:=Int0(s1);
                    if NumStr(n,CntNum)=s1 then begin
                      c:=Chr(n-848); Inc(i,CntNum);
                    end;
                  end;
                  if AnsiUpCase(c)=sFind[f] then begin
                    Inc(f);
                    if f>lFind then break;
                  end
                  else f:=1;
                end;
                Inc(i);
              end;
            end;
          if f>lFind then Inc(j) else ls.Delete(j);
        end;
        j:=ls.Count;
        if j>0 then begin
          i:=sb.RowCount-IfThen(empty(sb.Cells[0,sb.FixedRows]),1); sb.RowCount:=i+j;
          for j:=0 to j-1 do begin
            sb.Cells[0,i]:=FileWithOutExt(ls[j]); sb.Cells[1,i]:=path; Inc(i);
          end;
        end;
        GetMaskFiles(ls,Sender.Params[0]+path+'*.*',[fmDir],[msfNoUpper,msfSort]);
        for j:=0 to ls.Count-1 do begin
          FindPath(path+ls[j]+PathDelim);
          if Sender.Aborted then break;
        end;
      finally
        ls.Free;
      end;
    end;
    DelStack;
  end;
begin
  AddStack('TDfmFind.PrFind',Self);
  FindPath('');
  DelStack;
end;

procedure TDfmFind.pnEdEnter(Sender: TObject);
begin
  AddStack('TDfmFind.pnEdEnter',Self);
  inherited;
  pnEd.FillKeyLb;
  DelStack;
end;

procedure TDfmFind.sbEnter(Sender: TObject);
begin
  AddStack('TDfmFind.sbEnter',Self);
  inherited;
  if not empty(sb.Cells[0,sb.FixedRows]) then begin
    KeyLb1.SetKey(K_Enter,'Загрузить','',ProcKey,'dfmfind',kmList); KeyLb1.Redrw;
  end;
  DelStack;
end;

procedure TDfmFind.sbExit(Sender: TObject);
begin
  AddStack('TDfmFind.sbExit',Self);
  KeyLb1.DelKey(K_All,'dfmfind'); KeyLb1.Redrw;
  DelStack;
end;

procedure TDfmFind.ProcKey;
begin
  AddStack('TDfmFind.ProcKey',Self);
  SetModalResult(mrOk);
  if Assigned(PrLoad) then Timer1.Enabled:=true;
  DelStack;
end;

procedure TDfmFind.Timer1Timer(Sender: TObject);
begin
  AddStack('TDfmFind.Timer1Timer',Self);
  Timer1.Enabled:=false; PrLoad(CorrDir(Rec['Path'])+sb.Cells[1,sb.Row]+sb.Cells[0,sb.Row]);
  DelStack;
end;

end.
