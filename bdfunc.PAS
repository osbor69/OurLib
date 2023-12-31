unit bdfunc;

interface

{$I LIBTEST}

procedure DbfCloseAll;

implementation

uses Windows,Variants,SysUtils,Math,
  MyTypes,My_pr,inter,DBF;

const aType: array[TDbfFieldType] of longint = (V_STRING,V_INT,V_FLOAT,V_DATE,V_BOOL);

var CrrDBF: byte = 0;
    atDBF: array[1..5] of TDbf;

function VarCurrentDBF(const v,index:variant; lSave: boolean):variant;
begin
  AddStack('bdfunc.VarCurrentDBF');
  if lSave then CrrDBF:=v;
  result:=CrrDBF;
  DelStack;
end;

function VarRecCnt(const v,index:variant; lSave: boolean):variant;
begin
  AddStack('bdfunc.VarRecCnt');
  result:=i_const(atDbf[CrrDbf].RecordCount,lSave);
  DelStack;
end;

function dbf_CloseTable(k: longint; const CodePage: variant): boolean; overload;
begin
  AddStack('bdfunc.dbf_CloseTable');
  result := InRange(k,Low(atDbf),High(atDbf)) and (atDbf[k]<>nil);
  if result then begin
    if not IsNil(CodePage) then atDbf[k].CodePage:=CodePage;
    FreeAndNil(atDbf[k]);
  end;
  DelStack;
end;

function dbf_CloseTable(var av: array of variant): variant; overload;
var k: longint;
begin
  case MyVarType(av[1],true) of
    varNull: k:=CrrDbf;
    varDouble,varDate: k:=av[1];
  else k:=0;
  end;
  result:=dbf_CloseTable(k,av[2]);
end;

procedure DbfCloseAll;
var i: byte;
begin
  AddStack('bdfunc.DbfCloseAll');
  for i:=low(atDbf) to high(atDbf) do FreeAndNil(atDbf[i]);
  DelStack;
end;

type TOpenTableOpt = set of(otReadOnly,otMsgHide,otValEmptyFill);

function dbf_OpenTable(pInfCreate: PDbfInfCreate; const FileName: TFileName; Opt: TOpenTableOpt; const aChk: variant): longint; overload;
var fl: boolean;
	function MsgUsl(const msg: string): boolean;
  begin
    AddStack('bdfunc.dbf_OpenTable.MsgUsl');
    result:=not fl;
    if result then mess_ok(['������������ ��������� ���� ������: ',FileName,'',msg]);
    DelStack;
  end;
var ost,k,j,t,t1,fi: longint;
	ohide,larr: boolean;
  nmf: string;
begin
  ost:=AddStack('bdfunc.dbf_OpenTable');
	result:=0; j:=-1;
	for k:=low(atDBF) to high(atDBF) do if atDBF[k]=nil then begin
    j:=k; break;
  end;
  ohide:=MessagesHidden; MessagesHidden:=otMsgHide in Opt;
	if j=-1 then mess_ok(['��_�������: ��� ���������� ������������ ����� ��� ������'])
  else begin
    try
      atDBF[j]:=TDbf.CreatePrm(FileName,
        IfThen(not(otReadOnly in Opt),dbfNoReadOnly)+IfThen(otValEmptyFill in Opt,dbfValEmptyFill),
        pInfCreate);
    except
      on E:Exception do begin
        SetStack(ost);
        if not MessagesHidden then meserr(E.Message);
      end;
    end;
    if atDBF[j].Active then begin
      atDBF[j].lDosToWin:=false; CrrDbf:=j; result:=j;
      if MyVarType(aChk)=varArray then
        if result=0 then mess_ok(['������ �������� ���� ������: ',atDBF[CrrDbf].FileName])
        else begin
          fl:=true;
          for j:=VarArrayLowBound(aChk,1) to VarArrayHighBound(aChk,1) do begin
            larr := MyVarType(aChk[j])=varArray;
            if larr then nmf:=aChk[j][1] else nmf:=aChk[j];
            fi:=atDbf[CrrDbf].FieldPos(nmf);	fl := fi>=0;
            if MsgUsl('����������� ���� "'+nmf+'".') then break;
            if larr then begin
              k:=VarArrayHighBound(aChk[j],1);
              if k>=2 then begin
                case atDbf[CrrDbf].FieldType(fi) of
                  dftString: t:=varString;
                  dftInteger: t:=varInteger;
                  dftFloat: t:=varDouble;
                  dftDate: t:=varDate;
                  dftBoolean: t:=varBoolean;
                else t:=varNull;
                end;
                t1:=aChk[j][2];
                if (t=varDouble) and (t1=varInteger) then t1:=varDouble;
                fl := t=t1;
              end;
              if MsgUsl('������������ ��� ���� "'+nmf+'".') then break;
            end;
          end;
          if not fl then begin
            result:=0; dbf_CloseTable(CrrDBF,null);
          end;
        end;
    end
    else dbf_CloseTable(j,null);
  end;
  MessagesHidden:=ohide;
  DelStack;
end;

function dbf_OpenTable(var av: array of variant): variant; overload;
var Opt: TOpenTableOpt;
begin
  Opt:=[];
  if     IsNilc(av[2],false) then Include(Opt,otReadOnly);
  if not IsNilc(av[4],true ) then Include(Opt,otMsgHide);
  if     IsNilc(av[5],false) then Include(Opt,otValEmptyFill);
  result:=dbf_OpenTable(nil,av[1],Opt,av[3]);
end;

function dbf_Value(var av: array of variant):variant;
var i: longint;
begin
  AddStack('bdfunc.dbf_Value');
  with atDbf[CrrDbf] do begin
    if MyVarType(av[1])=varString then i:=FieldPos(av[1]) else i:=av[1];
    if i>=0 then begin
      result:=Fields[i];
      if not IsNil(av[2]) then
        try
          Fields[i]:=av[2];
        except
          on E:EReadDBFError do raise EInterAnyError.Create(E.Message);
        end;
    end;
  end;
  DelStack;
end;

function dbf_pos(var av: array of variant):variant;
begin
  AddStack('bdfunc.dbf_pos');
  result:=atDbf[CrrDbf].FieldPos(av[1]);
  DelStack;
end;

function dbf_Create(var av: array of variant):variant;
const atpc: array[TDbfFieldType] of string = ('SC','I','NF','D','BL');
var path,fn: string;
  c: char;
  a: TDbfInfCreate;
  i,j,l,h,tpi: longint;
  t: TDbfFieldType;
  v: variant;
begin
	AddStack('bdfunc.dbf_Create');
  fn:=FullNameExe(av[1],'DBF'); path:=ExtractFilePath(fn);
  ForceDirectories(path); result:=DirectoryExists(path);
  if result then begin
    DelFileAtr(fn); result:=not FileExists(fn);
    if result and (MyVarType(av[2])=varArray) then begin
      l:=VarArrayLowBound(av[2],1); h:=VarArrayHighBound(av[2],1);
      SetLength(a,h-l+1); j:=low(a);
      for i:=l to h do
        if MyVarType(av[2][i])=varArray then with a[j] do begin
          v:=VAddEnd(av[2][i],4); Name:=v[1]; FieldType:=dftString; v[2]:=IsNilc(v[2],FieldType);
          Len:=IsNilc(v[3],0); Dec:=IsNilc(v[4],0);
          if MyVarType(v[2],true)=varDouble then begin
            tpi:=trunc(v[2]);
            for t:=low(aType) to high(aType) do if tpi=aType[t] then begin
              FieldType:=t; break;
            end;
          end
          else begin
            c:=UpCase(StrToChar(v[2]));
            for t:=low(atpc) to high(atpc) do if Pos(c,atpc[t])>0 then begin
              FieldType:=t; break;
            end;
          end;
          Inc(j);
        end;
      SetLength(a,j); i:=dbf_OpenTable(@a,fn,[otMsgHide],null); result := i>0;
      if result then begin
        atDbf[i].CodePage:=av[4];
        if not IsNilc(av[3],false) then dbf_CloseTable(CrrDBF,null);
      end;
    end;
  end;
  if not result then DelFileAtr(fn);
  DelStack;
end;

function dbf_Append(var av: array of variant):variant;
begin
  AddStack('bdfunc.dbf_Append');
  result:=Unassigned;
  try
    atDbf[CrrDbf].Append;
  except
    on E:EReadDBFError do raise EInterAnyError.Create(E.Message);
  end;
  DelStack;
end;

function dbf_Delete(var av: array of variant):variant;
begin
  AddStack('bdfunc.dbf_Delete');
  result:=Unassigned;
  try
    atDbf[CrrDbf].Delete;
  except
    on E:EReadDBFError do raise EInterAnyError.Create(E.Message);
  end;
  DelStack;
end;

function dbf_Goto(var av: array of variant):variant;
begin
  AddStack('bdfunc.dbf_Goto');
  result:=Unassigned; atDbf[CrrDbf].Recno:=av[1];
  DelStack;
end;

function dbf_Eof(var av: array of variant):variant;
begin
  AddStack('bdfunc.dbf_Eof');
	result:=atDbf[CrrDbf].Eof;
  DelStack;
end;

function dbf_First(var av: array of variant):variant;
begin
  AddStack('bdfunc.dbf_First');
	with atDbf[CrrDbf] do begin
  	First; result:=RecordCount;
  end;
  DelStack;
end;

function dbf_GetRecNo(var av: array of variant):variant;
begin
  AddStack('bdfunc.dbf_GetRecNo');
	result:=atDbf[CrrDbf].RecNo;
  DelStack;
end;

function dbf_DeleteAll(var av: array of variant):variant;
begin
  AddStack('bdfunc.dbf_DeleteAll');
  result:=Unassigned;
  with atDbf[CrrDbf] do begin
    if not(dbfNoReadOnly in Options) then raise EInterAnyError.Create(
      '������ �������� �������, ���� ������� ������ ��� ������');
  	First;
		while not Eof do begin
      Delete; Next;
    end;
  end;
  DelStack;
end;

function dbf_Next(var av: array of variant):variant;
begin
  AddStack('bdfunc.dbf_Next');
  result:=Unassigned; atDbf[CrrDbf].Next;
  DelStack;
end;

function dbf_Struct(var av: array of variant):variant;
var t: TDbf;
	i: longint;
begin
  AddStack('bdfunc.dbf_Struct');
  result:=false; t:=TDbf.CreatePrm(av[1]);
  try
  	if t.Active then begin
	  	result:=VarArrayCreate([1,t.FieldCount],varVariant);
      for i:=0 to t.FieldCount-1 do result[t.FieldIndex(i)+1]:=ArrVarToVar(
        [t.FieldName(i),aType[t.FieldType(i)],t.FieldLen(i),t.FieldDec(i),i]);
    end;
  finally
    t.Free;
  end;
  DelStack;
end;

initialization
  AddStack('bdfunc.initialization');
  ZeroMemory(@atDbf,SizeOf(atDbf));
  with TInter do begin
    SetVar('$dbffunc','���� ������ .DBF');
    SetVar('�������_��','����� ������� ���� ������',VarCurrentDBF,0,'I');
    SetVar('��_������','���������� ������� � ���� ������',VarRecCnt,0,'I',true,3002);
    SetFunction('���� ������ .DBF',1100);
    SetFunction('��_�������','������� ���� ������',
      ['����: ������','[���������: ���������� = '+vFalse+']','[����: ������]','[�����: ���������� = '+vTrue+']',
      '[������0: ���������� = '+vFalse+']'],
      ['C','LU','AU','LU','LU'],dbf_OpenTable,null,1101,'I');
    SetFunction('��_�������','������� ���� ������',
      ['[��: ���� ������]','[�����: ����������|�����]'],['NU','LNU'],dbf_CloseTable,0,1102);
    SetFunction('��_��������','�������� ���� �� ���� ������',
      ['����: ������|�����','[��������: ������|�����|����|����������]'],['CN','CNDLU'],dbf_Value,0,1103,'CFDL');
    SetFunction('��_�������','������� ���� ������',
      ['����: ������','[���: ������]','[����: ���������� = '+vFalse+']','[�����: ����������|�����]'],
      ['C','AU','LU','LNU'],dbf_Create,0,1104,'L');
    SetFunction('��_��������','�������� ������ � ���� ������',dbf_Append,0);
    SetFunction('��_�������','������� ������� ������ � ���� ������',dbf_Delete,0);
    SetFunction('��_������','������ ��������� ���� ������',['����: ������'],['C'],dbf_Struct,0,1105,'L');
    SetFunction('��_������','������ �� ��������� ������ � ���� ������',['�����: �����'],['N'],
      dbf_Goto,0,1106);
    SetFunction('��_�����','������� ����� ���� ������',dbf_Eof,0,1107,'L');
    SetFunction('��_������','������ � ������ ���� ������',dbf_First,0,1108,'I');
    SetFunction('��_������','����� ������� ������ � ���� ������',dbf_GetRecNo,0,1109,'I');
    SetFunction('��_��������','������� ��� ������ � ���� ������',dbf_DeleteAll,0);
    SetFunction('��_����','������ �� ��������� ������ � ���� ������',dbf_Next,0);
    SetFunction('��_�������','����� ���� �� ����� � ���� ������',['����: ������'],['C'],dbf_Pos,0,1110,'I');
  end;
  DelStack;
end.
