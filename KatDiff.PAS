unit KatDiff;

interface

{$I LIBTEST}

type TKatDiffList = (katdifWin,katdifGG); TKatDiffOpt = set of TKatDiffList;

function c_KatDiff(const cdir,sl: string; Opt: TKatDiffOpt; const PathDB: variant): boolean; overload;
function IfThen(AValue: boolean; ATrue: TKatDiffList): TKatDiffOpt; overload;

implementation

uses SysUtils,Variants,DB,DBTables,Forms,Classes,StrUtils,DateUtils,Windows,
  MyTypes,My_pr,Inter,FFdp,MulQry,FrmPswd,DBF;

function c_KatDiff(const cdir,sl: string; Opt: TKatDiffOpt; const PathDB: variant): boolean;
var s,FileInf: string;
  procedure Err(const msg: string);
  begin
    AddStack('KatDiff.c_KatDiff.Err');
    if katdifGG in Opt then begin
      IncD(s,'E,'); Summ.SetS(s,'MSG',msg);
    end
    else SetStrFile(FileInf,msg);
    DelStack;
  end;
var dbeg: TDateTime;
  function QQsm(m: TDateTime): string;
  begin
    AddStack('KatDiff.c_KatDiff.QQsm');
    if katdifWin in Opt then result:=dtoc(m,'.') else result:=Chr(dton(m,dbeg)+31);
    QQsSelf(result);
    DelStack;
  end;
var r: TDbf;
  pM: longint;
  function kmtod: TDateTime;
  begin
    AddStack('KatDiff.c_KatDiff.kmtod');
    result:=IncMonth(dbeg,Ord(StrToChar(r[pM]))-31);
    DelStack;
  end;
var q: TMulQuery;
  lDone: boolean;
  function qOpen(const table: string; const c_list: array of string;
    const where: string = ''; const g_list: boolean = false): boolean;
  var sc: string;
    ost: longint;
  begin
    ost:=AddStack('KatDiff.c_KatDiff.qOpen');
    sc:=ArrayAsList(c_list,',');
    try
      q.PartSelect(table,sc,where,'',IfThen(g_list,sc));
    except
      SetStack(ost);
      lDone:=false;
    end;
    result:=lDone;
    DelStack;
  end;
var db: TDatabase;
  function dbConnect(ForWin: boolean): boolean;
  var ost: longint;
  begin
    ost:=AddStack('KatDiff.c_KatDiff.dbConnect');
    result:=true;
    if (ForWin=(katdifWin in Opt)) and not Connected(db) then begin
      try
        SetConnected(db,true);
      except
        SetStack(ost); result:=false;
      end;
    end;
    DelStack;
  end;
type
  TParamList = 1..3;
  TParamStr = array[TParamList] of string;
const dlmInf = UnDelim;
  acl: TParamStr = ('CDR','SNACH','NACH');
  aval: TParamStr = ('РАБ','ВНУ','НУ');
var dir,odir,nmmes,where: string;
  a: TParamStr;
  ost,i,mcnt,pCLOS: longint;
  aCnt: array[TParamList] of longint;
  mes,mes1,mes2: TDateTime;
  vr: varrec;
  ls: TStringList;
  v: variant;
begin
  ost:=AddStack('KatDiff.c_KatDiff');
  result:=true; dir:=CorrDir(cdir); FileInf:=dir+FileKatDiff;
  ls:=TStringList.Create;
  try
    try
      Session.GetAliasNames(ls);
    except
      on EDatabaseError do begin
        SetStack(ost);
        mess_ok(['Внимание !','Для расчёта коэффициента сложности "ЗАРПЛАТЫ"',
          'необходима установка дополнительной программы BDE.']);
      end;
    end;
  finally
    ls.Free;
  end;
  try
    if katdifGG in Opt then s:=sl;
    if (katdifGG in Opt) and FileExists(FileInf) then begin
      result:=false;
      if ListAsArray(GetStrFile(FileInf),a,dlmInf)=high(a) then begin
        IncD(s,'D,');
        for i:=low(a) to high(a) do aCnt[i]:=Int0(a[i]);
      end
      else begin
        IncD(s,'E,'); Summ.SetS(s,'MSG',a[1]);
      end;
    end
    else if DirectoryExists(dir) then begin
      db:=TDatabase.Create(Application.MainForm);
      try
        with db do begin
          DatabaseName:='KatDiff'; LoginPrompt:=false;
          if katdifWin in Opt then begin
            nmmes:='M'; DriverName:=drvINTRBASE;
            if katdifGG in Opt then begin
              Params.Values[ibpUserName]:=sSYSDBA;
              Params.Values[ibpPassword]:=smasterkey;
            end
            else begin
              odir:=CngDir(dir);
              try
                TSQLDM.Load; TFormPswd.SetDBPrm(db,stpReg,dir,false);
              finally
                CngDir(odir);
              end;
            end;
          end
          else begin
            dbeg:=StartOfAYear(1990); nmmes:='KM'; DriverName:=drvSTANDARD;
            Params.Values[stpPath]:=dir; Params.Values[stpDefaultDriver]:='FOXPRO';
          end;
          q:=TMulQuery.CreateConnection(Application.MainForm,db); lDone:=false;
          if MyVarType(PathDB)=varArray then v:=PathDB else v:=VarArrayOf([PathDB]);
          for i:=VarArrayLowBound(v,1) to VarArrayHighBound(v,1) do begin
            if (katdifWin in Opt) and (katdifGG in Opt) then Params.Values[ibpServerName]:=v[i];
            if dbConnect(true) then begin
              lDone:=true; break;
            end;
          end;
        end;
        if lDone then begin
          lDone:=false;
          while not lDone do begin
            lDone:=true; mes1:=MaxInt; mes2:=0;
            if katdifWin in Opt then begin
              if qOpen('GLOB2',['min('+nmmes+')']) then mes1:=q.Fields[0].Value;
            end
            else begin
              r:=TDbf.CreatePrm(dir+'GLOB2.DBF');
              try
                if r.Active then begin
                  pM:=r.FieldPos(nmmes);
                  while not r.Eof do begin
                    mes:=kmtod; MinSelf(mes1,mes); MaxSelf(mes2,mes); r.Next;
                  end;
                end
                else lDone:=false;
              finally
                r.Free;
              end;
            end;
            if lDone then begin
              if katdifWin in Opt then begin
                if IsField(db,'CDR2','CLOS')
                then qOpen('CDR2',['min('+nmmes+')'],FldIsTrue('CLOS',false)+sAND+BracketNot(nmmes+sISNULL))
                else qOpen('CDR',['min(MOPEN)']);
                if lDone then
                  if MyVarType(q.Fields[0].Value)=varDate then mes2:=q.Fields[0].Value else mes2:=0;
              end
              else begin
                r:=TDbf.CreatePrm(dir+'CDR2.DBF');
                try
                  if r.Active then begin
                    pM:=r.FieldPos(nmmes); pCLOS:=r.FieldPos('CLOS');
                    while not r.Eof do begin
                      if not(r[pCLOS] or empty(r[pM])) then MinSelf(mes2,kmtod);
                      r.Next;
                    end;
                  end
                  else lDone:=false;
                finally
                  r.Free;
                end;
              end;
              if lDone then begin
                IncMonthSelf(mes2,-1); MaxSelf(mes1,IncYear(mes2,-1));
                if mes2>=mes1 then begin
                  if not dbConnect(false) then begin
                    Err('Ошибка доступа'); break;
                  end;
                  mcnt:=dton(mes2,mes1)+1; ZeroMemory(@aCnt,SizeOf(aCnt));
                  where:=nmmes+'>='+QQsm(mes1)+sAND+nmmes+'<='+QQsm(mes2)+sAND+BrackNoEmp('SUMMA<>0'+sOR+'SUMNEW<>0');
                  if qOpen('NACH',[nmmes,'TN'],where,true) then begin
                    aCnt[1]:=q.RecordCount;
                    if qOpen('NACH',[nmmes,'KNU','NNU'{,'UN'}],where,true) then begin
                      aCnt[2]:=q.RecordCount;
                      if qOpen('NACH',[sCOUNTZV],where) then aCnt[3]:=q.Fields[0].AsInteger;
                    end;
                  end;
                  if empty(aCnt[3]) then Err('Нет данных за последний год')
                  else begin
                    for i:=low(a) to high(a) do begin
                      aCnt[i]:=nround(aCnt[i]/mcnt); a[i]:=IntToStr(aCnt[i]);
                    end;
                    if katdifGG in Opt then IncD(s,'D,') else SetStrFile(FileInf,ArrayAsList(a,dlmInf));
                  end;
                end
                else Err('Нет данных за последний год');
              end;
            end;
            if not lDone then begin
              if not(katdifGG in Opt) then
                if Ask(['Папка: '+dir,'Возможно, запущена программа "ЗАРПЛАТА"','Повторить ?'],
                  true,'Ошибка открытия папки') then continue;
              Err('Запущена программа "ЗАРПЛАТА"'); lDone:=true;
            end;
          end;
        end
        else Err('Ошибка доступа');
      finally
        SetConnected(db,false); q.Free; db.Free;
      end;
    end
    else Err('Ошибка доступа');
    if RightStr(s,2)='D,' then for i:=low(a) to high(a) do begin
      Summ.SetN(s,acl[i],aCnt[i]); vr:=TInter.SeekVar('ПРГ_ЗП'+aval[i]);
      vr.proc(SpaceStr(aCnt[i],Length(vr.proc(null,vr.index,false))),vr.index,true);
    end;
  except
    on Exception do begin
      OutStack('Папка: '+dir);
      raise
    end;
  end;
  DelStack;
end;

function c_KatDiff(var av: array of variant): variant; overload;
begin
  result:=c_KatDiff(av[1],av[3],[katdifGG]+IfThen(av[2],katdifWin),av[4]);
end;

function IfThen(AValue: boolean; ATrue: TKatDiffList): TKatDiffOpt;
begin
  if AValue then Result:=[ATrue] else Result:=[];
end;

initialization
  AddStack('KatDiff.initialization');
	TInter.SetFunction('KatDiff','',
    ['ПапкаФайл: строка','Win: логическое','Стр: строка','[ПутьБД: строка|массив]'],['C','L','C','CAU'],
    c_KatDiff,null,0,'L');
  DelStack;
end.
