unit FLogLs;

interface

uses
  Messages, Classes, Controls, Menus, DB, Grids, DBGrids, ExtCtrls,
  MyTypes, FrmBrIBp, KeyMenu, Browl, Keylb, Fpanel, DefEdit, RecVal, FEdText;

type
  TLogFltList = (logfComp,logfIP,logfUserName,logfVid,logfTbl);

  TLogLs = class(TFormBrIBPnl)
    RFlt: TRecVal;
    de: TDefEdit;
    procedure FormCreate(Sender: TObject);
    procedure dePnlCngKey(Sender: TObject; var tb: TKeyBut);
    procedure deFldChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure Browl1BrowlKey(key: Integer; tw: TWinControl);
    procedure RbPanel4Resize(Sender: TObject);
    function dePnlValid(Sender: TObject): Boolean;
  private
    { Private declarations }
    BrQuery1VID,BrQuery1TBL,BrQuery1KEYS,BrQuery1UN,BrQuery1PRIM,BrQuery1NPRIM: TField;
    BrQuery1D,BrQuery1DREGS,BrQuery1DBEG: TArrBoolField;
    BrQuery1CKEYS,BrQuery1CPRIM,BrQuery1KEYSTACK: TStringField;
    BrQuery1USERNUM: TIntegerField;
    afFlt: array[TLogFltList] of TField;
    vFlt: array[TLogFltList] of variant;
    aks,akr: TArrStr;
    Memo: TTextMemo;
    procedure BrQuery1CalcFields(DataSet: TDataSet);
    procedure BrQuery1AfterScroll(DataSet: TDataSet);
    function UnKey: string;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
  end;

var
  LogFltKeysProc: procedure(nKeys: longint; const sKeys: string; var where: string);
  LogKeysCalcFieldsProc: procedure(const tbl: string; var sKeys: string);

implementation

{$R *.dfm}

uses Windows,SysUtils,StrUtils,Math,Variants,
  My_pr,MulQry,FFldEdit,FSchemDM,FrmPswd,FStat;

const
  aFlt: array[TLogFltList] of record
    f: string;
    nolist: boolean;
  end =
    ((f:'COMP')
    ,(f:fIP)
    ,(f:fUSERNAME)
    ,(f:'VID'     ; nolist:true)
    ,(f:'TBL')
    );

var LogLs: TLogLs;

procedure TLogLs.FormCreate(Sender: TObject);
  procedure ColDate(var af: TArrBoolField; const FieldName,DisplayLabel: string);
  begin
    AddStack('TLogLs.FormCreate.ColDate',Self);
    af:=ArrBoolField(
      BrQuery1.CreateField(FieldName),
      BrQuery1.CreateDateField('C'+FieldName,DisplayLabel,'dd/mm/yyyy hh:nn:ss',19));
    DelStack;
  end;
var i,l: longint;
  a: TDEPrmVar;
  s: string;
  flt: TLogFltList;
  ls: TMQFieldList;
begin
  AddStack('TLogLs.FormCreate',Self);
  Memo:=TTextMemo.CreateParent(Self,RbPanel4); Memo.ReadOnly:=true; Memo.WordWrapBool:=true;
  inherited;
  ls:=GetFieldList(tLOG);
  InitArr(a);
  a[deCaption]:='';
  a[deNameRec]:=RFlt.NameRec;
  a[deAutoSel]:=true;
  a[deNoReadOnly]:=true;
  a[deReadOnlyNoVsbl]:=true;
  a[deRelation]:=RFlt.NameRec+'.FLT';
  for flt:=low(aFlt) to high(aFlt) do with aFlt[flt] do begin
    a[deNameRecFld]:='L'+f; RFlt.CreateFld(a[deNameRecFld],ftBoolean,0,false);
    SchemDM.BoolGet1.AssignGet(a);
    a[deMask]:=FRup(GetPrimFld(tLOG,f));
    a[deTag]:=true;
    a[deWidth]:=0;
    de.CreateFld(a,'KEYS');

    a[deNameRecFld]:=f;
    with ls.Fields(f)^ do RFlt.CreateFld(f,DataType,Size,VarBlank(DataType));
    SchemDM.MenuGet1.AssignGet(a);
    a[deTag]:=false;
    a[deWidth]:=wallDefault;
    de.CreateFld(a,'KEYS');
  end;
  with ProgPswd,BrQuery1 do begin
    RFlt['VID']:=aLogVidOrd[0];
    Arg['DB']:=0; Arg['DE']:=0;
    Arg[sC_LIST]:=Concat([fLogD,fUSERNUM,fLogUN,fLogNPRIM]);
    for i:=0 to ls.Count-1 do AddArgList(sC_LIST,ls[i]);
    Init(DBMain,[fLogD+','+fUSERNUM+','+fLogUN+','+fLogNPRIM],['CONCATENATION'],tLOG,
      fLogD+'>={DB}'+sAND+fLogD+'<{DE}','',BrQuery1CalcFields);
    CreateField('CONCATENATION'); // чтобы не было ошибки при поиске F6
    ColDate(BrQuery1D,fLogD,'Дата');
    afFlt[logfComp]:=CreateStringField('COMP','Компьютер');
    afFlt[logfIP]:=CreateStringField(fIP,'IP-адрес');
    afFlt[logfUserName]:=CreateStringField(fUSERNAME,'Пользователь');
    s:=''; l:=0;
    for i:=low(aLogVidOrd) to high(aLogVidOrd) do with aLogVid[aLogVidOrd[i]-lLogVid] do begin
      IncD(s,StrNum(mniDlm,aLogVidOrd[i])+UnDelim+nm); MaxSelf(l,nm);
    end;
    de.Param['VID',deMask]:=Copy(s,lmniDlm1,MaxInt);
    BrQuery1VID:=CreateField('VID');
    afFlt[logfVid]:=CreateStringField('CVID','Вид',l);
    BrQuery1TBL:=CreateField('TBL');
    afFlt[logfTbl]:=CreateStringField('CTBL','Данные',MaxByte);
    BrQuery1UN:=CreateField(fLogUN); BrQuery1NPRIM:=CreateField(fLogNPRIM);
    if Length(aLogKeys)=0 then de.DestroyFlds(['KEYS','NKEYS','SKEYS'])
    else begin
      s:='все';
      for i:=low(aLogKeysOrd) to high(aLogKeysOrd) do
        IncD(s,mniDlm+aLogKeys[aLogKeysOrd[i]-lLogKeys].nm);
      de.Param['NKEYS',deMask]:=s+StrNum(cRdBeg,0);
      BrQuery1KEYS:=CreateField('KEYS');
      BrQuery1CKEYS:=CreateStringField('CKEYS','Ключевые поля',MaxByte); 
      l:=Length(aLogKeys); SetLength(aks,l); SetLength(akr,l); l:=0;
      for i:=low(aLogKeys) to high(aLogKeys) do with aLogKeys[i] do if cod<>'' then begin
        aks[l]:=cod+'='; akr[l]:=nm+':'; Inc(l);
      end;
      aks[l]:=UnDelim; akr[l]:=LogDlm; Inc(l); SetLength(aks,l); SetLength(akr,l);
    end;
    BrQuery1PRIM:=CreateField('PRIM');
    BrQuery1CPRIM:=CreateStringField('CPRIM','Описание',BrQuery1PRIM.Size*lCRLF);
    BrQuery1KEYSTACK:=CreateStringField('KEYSTACK','Последовательность');
    BrQuery1USERNUM:=CreateIntegerField(fUSERNUM,'№ рег.');
    ColDate(BrQuery1DREGS,'DREGS','Дата рег.');
    ColDate(BrQuery1DBEG,'DBEG','Начало');
    AfterScroll:=BrQuery1AfterScroll;
  end;
  DelStack;
end;

function TblPrim(const tbl: string): string; overload;
begin
  AddStack('FLogLs.TblPrim');
  result:=GetPrim(tbl,false);
  if result='' then result:=tbl;
  DelStack;
end;

function TblPrim(fTbl: TField): string; overload;
begin
  result:=TblPrim(fTbl.AsString);
end;

procedure TLogLs.WMFormLimit;
begin
	AddStack('TLogLs.WMFormLimit',Self);
  inherited;
  FreeLimit(LogLs);
  DelStack;
end;

procedure TLogLs.dePnlCngKey(Sender: TObject; var tb: TKeyBut);
begin
  AddStack('TLogLs.dePnlCngKey',Self);
  if tb.Key=K_F10 then tb.Caption:='Просмотр';
  DelStack;
end;

procedure StFltLoad(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var s: PString;
  i,l: longint;
  f,sc: string;
  ls: TStrStrList;
  lTbl: boolean;
begin
  AddStack('FLogLs.StFltLoad');
  s:=PointerVar(Params[0]); f:=Params[1]; lTbl := f='TBL';
  with ProgPswd.GetQuery do begin
    PartSelect(tLOG,f,'',f,f); s^:=''; l:=RecordCount;
    ls:=TStrStrList.CreateIf(lTbl,false,l);
    try
      for i:=1 to l do begin
        sc:=TrimRight(Fields[0].AsString);
        if Sender.SayStat('',sc,i/l) then break;
        if lTbl then ls.IgnoreFindAdd(TblPrim(Fields[0]),sc) else IncD(s^,mniDlm+sc+UnDelim+sc);
        Next;
      end;
      if not Sender.Aborted and lTbl then begin
        ls.Sorted:=true;
        for i:=0 to ls.Count-1 do IncD(s^,mniDlm+ls.Value[i]+UnDelim+ls[i]);
      end;
    finally
      ls.Free;
    end;
    ProgPswd.FreeQuery;
  end;
  DelStack;
end;

procedure TLogLs.deFldChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
var flt: TLogFltList;
  fl: boolean;
  i: longint;
  s: string;
  tf: TFldEdit;
begin
  AddStack('TLogLs.deFldChange',Self);
  with ProgPswd,TFldEdit(Sender) do
    if NameRecFld='NKEYS' then begin
      i:=VarValue; fl := i=0;
      with de.FldEdit['SKEYS'] do begin
        SetReadOnly(fl);
        if not fl then with aLogKeys[aLogKeysOrd[i-1]-lLogKeys] do begin
          AssignGet; Mask:=ms; AssignGet(g); de.FillFldList;
        end;
      end;
    end
    else begin
      if AnsiMatchText(NameRecFld,['LVID','VID'])
      then de.SetReadOnly('LTBL',boolean(RFlt['LVID']) and not aLogVid[longint(RFlt['VID'])-lLogVid].ltbl,false);
      for flt:=low(aFlt) to high(aFlt) do with aFlt[flt] do if NameRecFld='L'+f then begin
        fl:=VarValue; tf:=de.FldEdit[f];
        if fl and not nolist and not IsNil(vFlt[flt]) then begin
          s:='';
          if ShowStat('Загрузка списка "'+Mask+'"',StFltLoad,[longint(@s),f]) then begin
            VarValue:=false; fl:=false;
          end
          else begin
            s:=cMnNoNum+Copy(s,lmniDlm1,MaxInt);
            if Assigned(LogFltMaskFldProc) then LogFltMaskFldProc(f,s);
            tf.Mask:=s; tf.VarValue:=vFlt[flt]; vFlt[flt]:=null;
          end;
        end;
        tf.SetReadOnly(not fl); break;
      end;
    end;
  DelStack;
end;

function TLogLs.dePnlValid(Sender: TObject): Boolean;
var flt: TLogFltList;
  j: longint;
  s,sc: string;
  fl: boolean;
begin
  AddStack('TLogLs.dePnlValid',Self);
  result:=false; RFlt.SaveToIni;
  with ProgPswd,BrQuery1 do begin
    s:=fLogD+'>={DB}'+sAND+fLogD+'<{DE}'; Arg['DB']:=Double(RFlt['DB']); Arg['DE']:=Double(RFlt['DE'])+1;
    for flt:=low(aFlt) to high(aFlt) do with aFlt[flt] do begin
      fl:=RFlt['L'+f];
      if fl then IncAnd(s,f+'='+VarTos(RFlt[f],vsQQ));
      afFlt[flt].Visible:=not fl;
    end;
    if (Length(aLogKeys)>0) and (RFlt['NKEYS']>0) then begin
      j:=aLogKeysOrd[longint(RFlt['NKEYS'])-1]; sc:=Trim(RFlt['SKEYS']);
      if Assigned(LogFltKeysProc) then LogFltKeysProc(j,sc,s);
      with aLogKeys[j-lLogKeys] do
        if cod<>'' then IncAnd(s,'KEYS'+sLIKE+QQs('%'+cod+'='+sc+UnDelim+'%'));
    end;
    Arg[sWHERE]:=s;
  end;
  Browl1.FormShow(Self); ShowModal;
  DelStack;
end;

procedure TLogLs.BrQuery1CalcFields;
  procedure ColDate(const af: TArrBoolField);
  begin
    AddStack('TLogLs.BrQuery1CalcFields.ColDate',Self);
    af[true].AsDateTime:=af[false].AsFloat;
    DelStack;
  end;
var s: string;
begin
  AddStack('TLogLs.BrQuery1CalcFields',Self);
  with ProgPswd do begin
    ColDate(BrQuery1D);
    ColDate(BrQuery1DREGS);
    ColDate(BrQuery1DBEG);
    afFlt[logfVid].AsString:=aLogVid[BrQuery1VID.AsInteger-lLogVid].nm;
    afFlt[logfTbl].AsString:=TblPrim(BrQuery1TBL);
    if Assigned(BrQuery1KEYS) then begin
      s:=SubStr(TrimRight(BrQuery1KEYS.AsString),1,-lUnDelim);
      if Assigned(LogKeysCalcFieldsProc) then LogKeysCalcFieldsProc(TrimRight(BrQuery1TBL.AsString),s);
      BrQuery1CKEYS.AsString:=StrTran(s,aks,akr);
    end;
    BrQuery1CPRIM.AsString:=StrTran(BrQuery1PRIM.AsString,LogCRLF,CRLF);
  end;
  DelStack;
end;

function TLogLs.UnKey;
begin
  AddStack('TLogLs.UnKey',Self);
  result:=FormatDateTime('yyyymmddhhnnsszzz',BrQuery1D[false].AsFloat)
    +SpaceStr(BrQuery1UN.AsInteger,10)+SpaceStr(BrQuery1USERNUM.AsInteger,10);
  DelStack;
end;

function PrComp(q: TMulQuery; const v: variant): TValueSign;
begin
  AddStack('FLogLs.PrComp');
  result:=CompSign(TLogLs(LongInt(v[0])).UnKey,v[1]);
  DelStack;
end;

procedure TLogLs.Browl1BrowlKey(key: Integer; tw: TWinControl);
var s: string;
  l: longint;
  procedure sZppc(f: TField; const s1: string);
  var s2: string;
  begin
    AddStack('TLogLs.Browl1BrowlKey.sZppc',Self);
    s2:=TrimRight(s1);
    if s2<>'' then IncD(s,Zppc(f.DisplayLabel,max(Length(f.DisplayLabel),l))+CRLF+s2+CRLF);
    DelStack;
  end;
var s1,s2: string;
  i: longint;
  bm: TBookMark;
begin
  AddStack('TLogLs.Browl1BrowlKey',Self);
  case Key of
    K_Enter: begin
      s:=''; l:=0;
      with BrQuery1 do begin
        for i:=0 to FieldCount-1 do if not((Fields[i]=BrQuery1CPRIM) or (Fields[i]=BrQuery1KEYSTACK) or (Fields[i]=BrQuery1CKEYS)) then
          with Fields[i] do if Visible then begin
            s1:=Trim(AsString);
            if s1<>'' then begin
              IncL(s1,DisplayLabel+': '); MaxSelf(l,s1); IncD(s,s1+CRLF);
            end;
          end;
        if Assigned(BrQuery1CKEYS) then sZppc(BrQuery1CKEYS,BrQuery1CKEYS.AsString);
        sZppc(BrQuery1KEYSTACK,BrQuery1KEYSTACK.AsString);
        DisableControls; bm:=GetBookMark;
        s2:=''; s1:=UnKey; QryFind(VarArrayOf([longint(Self),s1]),BrQuery1,PrComp);
        while not Eof and (UnKey=s1) do begin
          IncD(s2,StrTran(FieldAsVariant(BrQuery1PRIM),LogCRLF,CRLF)); Next;
        end;
        sZppc(BrQuery1CPRIM,s2);
        GotoBookMark(bm); FreeBookMark(bm); EnableControls;
      end;
      EdTextView('Подробно',s,'',nil,[edtxtWordWrap]);
    end;
  else inherited;
  end;
  DelStack;
end;

procedure TLogLs.BrQuery1AfterScroll;
begin
  AddStack('TLogLs.BrQuery1AfterScroll',Self);
  if BrQuery1NPRIM.AsInteger=0
  then Memo.SetText(DlmBetween(BrQuery1KEYSTACK.AsString,BrQuery1CPRIM.AsString,CRLF))
  else Memo.SetText(TrimRight(BrQuery1CPRIM.AsString));
  DelStack;
end;

procedure TLogLs.RbPanel4Resize(Sender: TObject);
begin
  AddStack('TLogLs.RbPanel4SetWHMin',Self);
  inherited;
  if Assigned(Memo) then with TRbPanel(Sender) do Memo.SetBounds(BevPanel,BevPanel,CltWidth,CltHeight);
  DelStack;
end;

procedure PswdKeyProc(Key: longint; tw: TWinControl; var lBreak: boolean);
var flt: TLogFltList;
  ls: TStringList;
  i,l: longint;
begin
  AddStack('FLogLs.PswdKeyProc');
  if Key=K_Alt_L then begin
    lBreak:=true; CreateForm(TLogLs,LogLs);
    with LogLs do begin
      RFlt.RestFromIni;
      for flt:=low(aFlt) to high(aFlt) do vFlt[flt]:=RFlt[aFlt[flt].f];
      ls:=GetTableList; l:=0;
      for i:=0 to ls.Count-1 do MaxSelf(l,TblPrim(ls[i]));
      afFlt[logfTbl].DisplayWidth:=l;
      de.Execute;
    end;
    FormFree(LogLs);
  end;
  DelStack;
end;

initialization
  AddStack('FLogLs.initialization');
  AddFrom(aPswdKeyProc,PswdKeyProc);
  DelStack;
end.
