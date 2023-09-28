unit FEdoExUs;

interface

{$I LIBTEST}
uses
  Messages, Classes, Controls, ExtCtrls, Menus, Forms,
  MyTypes, FRMEMPTY, Keylb, Fpanel, RecDB, Grids, StrBrowl, KeyMenu, DefEdit,
  FFldedit, PnlEdit, MemoGet, BtTxtGet;

type
  TEdoExUs = class(TFormEmp)
    tbl: TStrTable;
    deExe: TDefEdit;
    KeyMenu1: TKeyMenu;
    InGet: TButTextGet;
    deUs: TDefEdit;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure KeyLb1ProcKey(key: Integer; tw: TWinControl);
    procedure FormCreate(Sender: TObject);
    procedure deExeFldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure deExeFldExit(Sender: TObject);
    function deExeFldCheck(Sender: TObject): Boolean;
    procedure tblFill(Sender: TObject);
    procedure InGetClick(Sender: TObject);
    function deUsPnlValid(Sender: TObject): Boolean;
    procedure deUsPnlUpdateRec(Sender: TObject);
  private
    { Private declarations }
    procedure FillTbl(const nmus,ke: string);
    function GetX(X: Word): string;
    function GetY(Y: Word): string;
  	procedure NewNum(const oldnum: string; Options: TCngNumOptions; var result: boolean);
    procedure WMFormLimit(var msg: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    Modified: boolean;
  end;

var
  EdoExUs: TEdoExUs;

implementation

{$R *.dfm}

uses Windows,DB,SysUtils,Math,StrUtils,
  My_pr,FrmPswd,FSchemDM,ListF2,FEdoOrLs,FCngNum,DDProc,FDDatLs{не стирать},FEdoDM,MulQry,FGFBmp;

const aTbl: array[0..2] of string = (tEDOUS,tEDOORD,tEDO);

{ TEdoExUs }
procedure TEdoExUs.FormCreate(Sender: TObject);
var tp: TEdoExeType;
  io: TEdoExeIO;
  av: TDEPrmVar;
begin
  AddStack('TEdoExUs.FormCreate',Self);
  inherited;
  InitArr(av);
  av[deAutoSel]:=true;
  av[deNoReadOnly]:=true;
  av[deReadOnlyNoVsbl]:=true;
  av[deTrimLeft]:=true;
  for tp:=low(aEdoExeType) to high(aEdoExeType) do begin
    av[deCaption]:=aEdoExeType[tp]+':';
    av[deNameRec]:='';
    av[deNameRecFld]:=Int2Str(tp);
    SchemDM.MultiGet1.AssignGet(av);
    av[deRelation]:='';
    av[deWidth]:=wallDefault;
    deExe.CreateFld(av);

    av[deRelation]:=av[deNameRec]+'.'+av[deNameRecFld];
    av[deNameRec]:=EdoDM.Exe.NameRec;
    av[deWidth]:=wallNoSay;
    for io:=low(aEdoExeIO) to high(aEdoExeIO) do begin
      av[deNameRecFld]:=EdoExeFld(tp,io);
      if EdoDM.Exe.IsField(av[deNameRecFld]) then with aEdoExeIO[io] do begin
        av[deCaption]:=IfThen(not bool,nm);
        av[deMask]:=IfThen(bool,nm);
        av[deWidth]:=IfThen(not bool,wallNoSay);
        case io of
          edoexeOutTrue: TSimpleGet.AssignGetClass(av);
          edoexeOutMsg: SchemDM.BoolGet1.AssignGet(av);
        else InGet.AssignGet(av);
        end;
        deExe.CreateFld(av);
      end;
    end;
  end;
  if IsField(tDCMBMP,fUSERNAME)
  then KeyLb1.SetKey(K_Shift_F8,'Рисунки','Рисунки пользователя',KeyLb1ProcKey,'user',kmList,'SUPER');
  DelStack;
end;

procedure TEdoExUs.FormShow(Sender: TObject);
begin
  AddStack('TEdoExUs.FormShow',Self);
  with InitFIni[fiSave] do FillTbl(ReadString('EdoExUs',fUSERNAME),ReadString('EdoExUs',fEDOEXE));
  inherited;
  Modified:=false;
  DelStack;
end;

procedure TEdoExUs.FormHide(Sender: TObject);
var X,Y: Word;
begin
  AddStack('TEdoExUs.FormHide',Self);
  with InitFIni[fiSave] do begin
    tbl.ColRowToXY(X,Y);
    WriteString('EdoExUs',fUSERNAME,GetX(X));
    WriteString('EdoExUs',fEDOEXE,GetY(Y));
  end;
  inherited;
  DelStack;
end;

function TEdoExUs.GetX;
begin
  AddStack('TEdoExUs.GetX',Self);
  with tbl do if InRange(X,0,HeadX.Count-1) then result:=HeadX[X] else result:='';
  DelStack;
end;

function TEdoExUs.GetY;
begin
  AddStack('TEdoExUs.GetY',Self);
  with tbl do if InRange(Y,0,HeadY.Count-1) then result:=DlmCopy(HeadY[Y],1,1,'.') else result:='';
  DelStack;
end;

procedure TEdoExUs.FillTbl;
var l: longint;
  Y: Word;
  ke1: string;
begin
  AddStack('TEdoExUs.FillTbl',Self);
  with tbl,ProgPswd.GetQuery do begin
    PartSelect(tUSERS,fNAME,'',fNAME); SaveTo(TStringList(HeadX));
    PartSelect(tEDOEXE,[fEDOEXE,fNAME],'',fEDOEXE); Y:=0;
    with HeadY do begin
      l:=RecordCount; BeginUpdate; Clear; Capacity:=l;
      for l:=0 to l-1 do begin
        ke1:=Fields[0].AsString; Add(ke1+'. '+TrimRight(Fields[1].AsString)); Next;
        if ke1=ke then Y:=l;
      end;
      EndUpdate;
    end;
    Fill(ReplVar(HeadX.IndexOf(nmus),NegDef,0),Y,[tbfTopLeft]);
  end;
  ProgPswd.FreeQuery;
  DelStack;
end;

procedure TEdoExUs.tblFill(Sender: TObject);
var X,Y: Word;
  ke,nmus: string;
  cX,cY: longint;
  lY: boolean;
begin
  AddStack('TEdoExUs.tblFill',Self);
  with ProgPswd.GetQuery do begin
    PartSelect(tEDOUS,[fEDOEXE,fUSERNAME,'LOGIN'],'',GetList([fEDOEXE,fUSERNAME])); Y:=0;
    while not Eof do begin
      ke:=Fields[0].AsString; lY:=false;
      while Y<tbl.HeadY.Count do begin
        cY:=AnsiCompareStr(GetY(Y),ke);
        if cY<0 then Inc(Y)
        else begin
          lY := cY=0; break;
        end;
      end;
      X:=0;
      while not Eof and (Fields[0].AsString=ke) do begin
        nmus:=Fields[1].AsString;
        while X<tbl.HeadX.Count do begin
          cX:=AnsiCompareStr(GetX(X),nmus);
          if cX<0 then Inc(X)
          else begin
            if lY and (cX=0) then tbl.DatCells[X,Y]:=Fields[2].AsString;
            break;
          end;
        end;
        Next;
      end;
    end;
  end;
  ProgPswd.FreeQuery;
  DelStack;
end;

procedure TEdoExUs.KeyLb1ProcKey(key: Integer; tw: TWinControl);
var X: Word;
  procedure Modify(const ke: string);
  begin
    AddStack('TEdoExUs.KeyLb1ProcKey.Modify',Self);
    FillTbl(GetX(X),ke); ProgPswd.SendUpd(updCodeGet); Modified:=true;
    DelStack;
  end;
var NoSeekExe: boolean;
  Y: Word;
  ke,nmus: string;
  a: TArrStr;
  fn: TModelFile;
begin
  AddStack('TEdoExUs.KeyLb1ProcKey',Self);
  NoSeekExe := Key in [K_F7,K_Enter,K_Ctrl_R];
  if NoSeekExe or (tbl.HeadY.Count>0) then begin
    tbl.ColRowToXY(X,Y); ke:=GetY(Y);
    if not NoSeekExe then if not EdoDM.Exe.Seek(tEDOEXE+'.'+fEDOEXE+'='+QQs(ke)) then begin
      mess_ok(['Программа с номером '+Trim(ke)+' отсутствует',
        '(возможно, была удалена другим пользователем).','Список будет обновлён.']);
      Key:=K_Ctrl_R;
    end;
    case Key of
      K_F3: begin
        CopyFrom(a,tEDOEXE); AddFrom(a,aTbl);
        if TCngNum.GetNewNum('Новый номер программы',nil,EdoDM.Exe,fEDOEXE,a,[],'',NewNum)
        then Modify(EdoDM.Exe[fEDOEXE]);
      end;
      K_F4,K_F7: begin
        EdoDM.Exe.NewRec(IfThen(Key=K_F4,newrCopy));
        SetLogVid(logvAppRec);
        deExe.Param[fEDOEXE,deNoReadOnly]:=bTrue;
        if deExe.Execute('Добавление программы').Saved then begin
          EdoDM.Exe.AppRec(true); Modify(EdoDM.Exe[fEDOEXE]);
        end;
        SetLogVid;
      end;
      K_F5: begin
        SetLogVid(logvEditRec);
        deExe.Param[fEDOEXE,deNoReadOnly]:=bFalse;
        if deExe.Execute('Редактирование программы').Saved then Modify(ke);
        SetLogVid;
      end;
      K_F8: if not EdoDM.Ord.SeekMsg(tEDOORD+'.'+fEDOEXE+'='+QQs(GetY(Y)),
      'Программа используется в последовательности подписания.') then begin
        SetLogVid(logvDelRec);
        if Ask(amsDel) then if TrnsStart([tEDOEXE,tEDOUS]) then try
          ProgPswd.DeleteTable(tEDOUS,fEDOEXE+'='+QQs(ke));
          EdoDM.Exe.DelRec('',[delLog]); Modify(GetY(Y-aSign[Y<tbl.HeadY.Count-1]));
          TrnsEnd([trnsCommit]);
        except
          TrnsEnd; raise
        end;
        SetLogVid;
      end;
      K_Enter: begin
        nmus:=GetX(X);
        with EdoDM.Us do if Seek(tEDOUS+'.'+fUSERNAME+'='+QQs(nmus)+sAND+tEDOUS+'.'+fEDOEXE+'='+QQs(ke))
        then SetLogVid(logvEditRec)
        else begin
          SetLogVid(logvAppRec); NewRec; Value[fUSERNAME]:=nmus; Value[fEDOEXE]:=ke;
        end;
        deUs.Execute('Пользователь: '+Trim(nmus)+', программа: '+Trim(tbl.HeadY[Y]));
        SetLogVid;
      end;
      K_Ctrl_R: Modify(ke);
      K_Alt_F3: EdoDM.mgExe.Add;
      K_Alt_F5: begin
        fn:=EdoDM.Exe[fMODEL];
        if EdoDM.mgExe.List(fn) then Modify(ke);
      end;
      K_Shift_F8: TGFBmp.Execute(GetX(X));
    end;
  end;
  inherited;
  DelStack;
end;

procedure TEdoExUs.deExeFldChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
var tp: TEdoExeType;
begin
  AddStack('TEdoExUs.deExeFldChange',Self);
  with TFldEdit(Sender) do
    for tp:=low(aEdoExeType) to high(aEdoExeType) do if NameRecFld=EdoExeFld(tp,edoexeIn) then begin
      deExe.SetReadOnly([EdoExeFld(tp,edoexeOutTrue),EdoExeFld(tp,edoexeOut)],empty(VarValue));
      break;
    end;
  DelStack;
end;

procedure TEdoExUs.deExeFldExit(Sender: TObject);
begin
  AddStack('TEdoExUs.deExeFldExit',Self);
  SpaceStrSelf(Sender,fEDOEXE);
  DelStack;
end;

function TEdoExUs.deExeFldCheck(Sender: TObject): Boolean;
var tp: TEdoExeType;
begin
  AddStack('TEdoExUs.deExeFldCheck',Self);
  if KodCheck(Sender,fEDOEXE,result) then with TFldEdit(Sender) do
    for tp:=low(aEdoExeType) to high(aEdoExeType) do
      if not NoEmpCheck(Sender,EdoExeFld(tp,edoexeOutTrue),result) then break;
  DelStack;
end;

procedure TEdoExUs.InGetClick(Sender: TObject);
const anm: TEdoExeCtrlStr =
  ('Имя файла исходного документа'
  ,''
  ,'Имя пользователя для входа'
  ,'Пароль'
  ,'Отпечаток сертификата пользователя'
  );
var s: string;
  i,n: TEdoExeCtrl;
  l: byte;
  mr: TListF2Result;
  tf: TFldEdit;
  an: array[TEdoExeCtrl] of TEdoExeCtrl;
begin
  AddStack('TEdoExUs.InGetClick',Self);
  l:=MaxSelf(aEdoExeCtrl)+1; s:=''; n:=low(anm);
  for i:=low(anm) to high(anm) do if aEdoExeCtrl[i]<>'' then begin
    IncD(s,Padr(aEdoExeCtrl[i],l)+anm[i]+CRLF); an[n]:=i; Inc(n);
  end;
  mr:=TListF2Result.Create;
  try
    tf:=pointer(Sender);
    if ListF2Down(s,mr,tf,0,SchemDM.Browl.CaptSmall,'',nil,0,nil,nil,nil,nil,nil,'Служебные коды')
    then TButTextGet(tf.curget).InsText(tf,aEdoExeCtrl[an[TEdoExeCtrl(mr.SelectStr)]]);
  finally
    mr.Free;
  end;
  DelStack;
end;

procedure TEdoExUs.NewNum;
var i: byte;
  w: string;
begin
  AddStack('TEdoExUs.NewNum',Self);
  with ProgPswd.GetQuery do begin
    Arg[sC_LIST]:=fEDOEXE; Arg[sV_LIST]:=QQs(EdoDM.Exe[fEDOEXE]); w:=fEDOEXE+'='+QQs(oldnum);
    for i:=low(aTbl) to high(aTbl) do UpdateTable(aTbl[i],w);
  end;
  ProgPswd.FreeQuery;
  DelStack;
end;

function TEdoExUs.deUsPnlValid(Sender: TObject): Boolean;
var login: string;
  X,Y: Word;
begin
  AddStack('TEdoExUs.deUsPnlValid',Self);
  with EdoDM.Us do begin
    result:=true; login:=TrimRight(Value['LOGIN']);
    if (login<>'') or not empty(Value['CERT']) then AppUpdRec(true)
    else if RecNo>0 then begin
      ProgPswd.CngLogVid(logvDelRec); DelRec('',[delLog]);
    end;
  end;
  tbl.ColRowToXY(X,Y); tbl.DatCells[X,Y]:=login; 
  DelStack;
end;

procedure TEdoExUs.deUsPnlUpdateRec(Sender: TObject);
begin
// см. deUsPnlValid
end;

procedure TEdoExUs.WMFormLimit;
begin
  AddStack('TEdoExUs.WMFormLimit');
  inherited;
  FreeLimit(EdoExUs);
  DelStack;
end;

end.
