unit FNumEd;

interface

uses
  Messages, Classes, Controls, Forms, ExtCtrls, Grids, Menus,
  MyTypes, FRMEMPTY, Keylb, Fpanel, StrBrowl, FFldedit, PnlEdit, KeyMenu, RecVal;

type
  TNumEd = class(TFormEmp)
    tbl: TStrTable;
    pnEd: TPanelEdit;
    Ed: TFldEdit;
    KeyMenu1: TKeyMenu;
    Rec: TRecVal;
    procedure tblFill(Sender: TObject);
    procedure pnEdBeforeSimpleEdit(Sender: TObject);
    procedure pnEdEscape(Sender: TObject; var Action: TCloseAction);
    procedure tblKeyPress(Sender: TObject; var Key: Char);
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function pnEdValid(Sender: TObject): Boolean;
  private
    { Private declarations }
    pVal: ^TArrArrDbl;
    pEmp: PArrArrBool;
    nLen,nDec: longint;
    xEd,yEd: Word;
    Modified: boolean;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    class function Execute(var aVal: TArrArrDbl; const Capt,tCaptX,tCaptY,tInvertedIniSect: string;
      const ax,ay: array of string; Len,Dec: longint; Opt: TNumEdOpt = []; aEmp: PArrArrBool = nil): boolean;
  end;

implementation

{$R *.dfm}

uses Windows,SysUtils,Variants,Math,DB,StrUtils,
  My_pr,Inter,Askp;

const
	cDlmY=';';
	cDlmX=',';

var NumEd: TNumEd;

procedure PrmDef(const av: array of variant; nY,nX,nEmp: byte; var DlmY,DlmX: string; var lEmp: boolean);
begin
  AddStack('FNumEd.PrmDef');
  DlmY:=IsNilc(av[nY],cDlmY); DlmX:=IsNilc(av[nX],cDlmX); lEmp:=IsNilc(av[nEmp],false);
  DelStack;
end;

// ЧИСЛТБЛ_РЕД
function c_edit(var av: array of variant):variant;
var lx,ly,x,y,Len,Dec: longint;
	ax,ay: TArrStr;
  DlmY,DlmX,s,s1: string;
  aVal: TArrArrDbl;
  aEmp: TArrArrBool;
  Opt: TNumEdOpt;
  lEmp: boolean;
begin
	AddStack('FNumEd.c_edit');
  result:=IsNilc(av[1],''); lx:=VarArrayHighBound(av[6],1); ly:=VarArrayHighBound(av[5],1);
  if (lx>0) and (ly>0) then begin
    PrmDef(av,10,11,12,DlmY,DlmX,lEmp); SetLength(aVal,lx);
    if lEmp then SetLength(aEmp,lx);
    for x:=low(aVal) to high(aVal) do begin
      SetLength(aVal[x],ly); ZeroMemory(@aVal[x,0],ly*SizeOf(aVal[x,0]));
      if lEmp then begin
        SetLength(aEmp[x],ly); FillMemory(@aEmp[x,0],ly*SizeOf(aEmp[x,0]),MaxByte);
      end;
    end;
    for y:=0 to min(LsArrDynamic(result,ay,DlmY),ly)-1 do
      for x:=0 to min(LsArrDynamic(ay[y],ax,DlmX),lx)-1 do begin
        aVal[x,y]:=Float0(ax[x]);
        if lEmp then aEmp[x,y] := ax[x]='';
      end;
    CopyFromVar(ax,av[6]); CopyFromVar(ay,av[5]); Len:=av[7]; Dec:=IsNilc(av[8],0);
    if IsNilc(av[9],true) then Opt:=[] else Opt:=[numReadOnly];
    if TNumEd.Execute(aVal,IsNilc(av[2],''),IsNilc(av[4],''),IsNilc(av[3],''),'',ax,ay,Len,Dec,Opt,IfThen(lEmp,@aEmp)) then begin
      result:='';
      for y:=ly-1 downto 0 do begin
        s:='';
        for x:=lx-1 downto 0 do begin
          if not lEmp and empty(aVal[x,y]) and (s='') then continue;
          if lEmp and aEmp[x,y] then s1:=''
          else begin
            if lEmp
            then s1:=SpaceStr0(aVal[x,y],Len,Dec)
            else s1:=SpaceStr(aVal[x,y],Len,Dec);
            s1:=StrTran(Trim(s1),DlmX,'.');
          end;
          IncL(s,DlmX+s1);
        end;
        if (s='') and (result='') then continue;
        IncL(result,DlmY+Copy(s,Length(DlmX)+1,MaxInt));
      end;
      DeleteVar(result,1,Length(DlmY));
    end;
  end;
  DelStack;
end;

// ЧИСЛТБЛ_ЗНАЧ
function c_val(var av: array of variant):variant;
var a: TArrStr;
	x,y: longint;
  DlmY,DlmX,s: string;
  lEmp: boolean;
begin
	AddStack('FNumEd.c_val');
  result:=iif(lEmp,'',0); x:=av[3]; y:=av[2]; PrmDef(av,4,5,6,DlmY,DlmX,lEmp);
  if y<=LsArrDynamic(av[1],a,DlmY) then begin
  	s:=a[y-1];
	  if x<=LsArrDynamic(s,a,DlmX) then if not(lEmp and (a[x-1]='')) then result:=Float0(a[x-1]);
  end;
  DelStack;
end;

{ TNumEd }
class function TNumEd.Execute;
begin
  AddStack('TNumEd.Execute');
  if (Length(ax)=0) or (Length(ay)=0) then result:=false
  else begin
    CreateForm(TNumEd,NumEd);
    with NumEd do begin
      pVal:=@aVal; pEmp:=aEmp; Caption:=Capt; nLen:=Len; nDec:=Dec; Modified:=false;
      if Assigned(pEmp) then begin
        Rec.CreateFld('S',ftString,Len,''); Ed.NameRecFld:='S';
      end
      else Ed.NameRecFld:='N';
      Ed.Mask:=MaskNum(nLen,nDec);
      with tbl do begin
      	CaptX:=tCaptX; CaptY:=tCaptY; ArrStr2Ls(ax,HeadX); ArrStr2Ls(ay,HeadY);
        InvertedIniDefault := numInverted in Opt; InvertedIniSect:=tInvertedIniSect; Fill;
      end;
      with KeyLb1 do begin
        if numReadOnly in Opt then begin
          SetKeys([K_Esc,K_F10],'Выход','',KeyLb1ProcKey,'numexit',kmFile);
          DelKey(K_All,'numed');
        end
        else begin
          SetKey(K_Esc,'Отмена','',KeyLb1ProcKey,'numexit',kmFile);
          SetKey(K_F10,'Сохранить','',KeyLb1ProcKey,'numexit',kmFile);
          SetKey(K_Enter,'Редактировать','',KeyLb1ProcKey,'numed',kmList);
        end;
        Redrw;
      end;
      result := (ShowModal=mrOk) and Modified;
    end;
    FormFree(NumEd);
  end;
  DelStack;
end;

procedure TNumEd.tblFill(Sender: TObject);
var x,y: SmallInt;
begin
	AddStack('TNumEd.tblFill',Self);
  for x:=low(pVal^) to high(pVal^) do
	  for y:=low(pVal^[x]) to high(pVal^[x]) do
      if Assigned(pEmp) and pEmp^[x,y]
      then tbl.DatCells[x,y]:=Space(nLen)
      else tbl.DatCells[x,y]:=SpaceStr0(pVal^[x,y],nLen,nDec);
  DelStack;
end;

procedure TNumEd.pnEdBeforeSimpleEdit(Sender: TObject);
var r: TRect;
begin
  AddStack('TNumEd.pnEdBeforeSimpleEdit',Self);
  r:=tbl.CellRect;
  pnEd.SetBounds(max(0,tbl.Left+r.Left+nround((r.Right-r.Left-Ed.Width)/2)+2),
    max(0,tbl.Top+r.Top-BevelFld+2),Ed.Width,Ed.Height);
  DelStack;
end;

procedure TNumEd.pnEdEscape(Sender: TObject; var Action: TCloseAction);
begin
	AddStack('TNumEd.pnEdEscape',Self);
	KeyLb1.SetButNoEval(false);
  DelStack;
end;

function TNumEd.pnEdValid(Sender: TObject): Boolean;
var v: variant;
  e,fl: boolean;
begin
	AddStack('TNumEd.pnEdValid',Self);
  KeyLb1.SetButNoEval(false); result:=true; v:=Ed.VarValue;
  if Assigned(pEmp) then begin
    e:=empty(v); Float0Self(v); fl := e<>pEmp^[xEd,yEd]; pEmp^[xEd,yEd]:=e;
  end
  else fl:=false;
  if (v<>pVal^[xEd,yEd]) or fl then begin
    if Assigned(pEmp) and pEmp^[xEd,yEd]
    then tbl.DatCells[xEd,yEd]:=Space(nLen)
    else tbl.DatCells[xEd,yEd]:=SpaceStr0(v,nLen,nDec);
    pVal^[xEd,yEd]:=v; Modified:=true;
  end;
  DelStack;
end;

procedure TNumEd.tblKeyPress(Sender: TObject; var Key: Char);
begin
  AddStack('TNumEd.tblKeyPress',Self);
  if IsDigit(Key) then begin
  	KeyLb1.ExecKey(K_Enter); ED.Perform(WM_CHAR,Ord(Key),1);
  end;
  DelStack;
end;

procedure TNumEd.KeyLb1ProcKey(key: longint; tw: TWinControl);
begin
	AddStack('TNumEd.KeyLb1ProcKey',Self);
  if Key=K_Enter then begin
  	tbl.ColRowToXY(xEd,yEd);
    if Assigned(pEmp)
    then Rec['S']:=IfThen(not pEmp^[xEd,yEd],SpaceStr0(pVal^[xEd,yEd],nLen,nDec))
    else Rec['N']:=pVal^[xEd,yEd];
    KeyLb1.SetButNoEval(true); pnEd.SetFocus;
  end
  else inherited;
  DelStack;
end;

procedure TNumEd.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	AddStack('TNumEd.FormClose',Self);
  inherited;
  if Modified then AskFormSave(Self,Action);
  DelStack;
end;

procedure TNumEd.WMFormLimit;
begin
	AddStack('TNumEd.WMFormLimit',Self);
  inherited;
  FreeLimit(NumEd);
  DelStack;
end;

initialization
	AddStack('FNumEd.initialization');
	with TInter do begin
    SetFunction('Числовые таблицы',1500);
    SetFunction('ЧИСЛТБЛ_РЕД','Просмотр и редактирование числовой таблицы',
      ['[Знач: строка = ""]','[ЗглОкно: строка = ""]','[ЗглСтр: строка = ""]','[ЗглСтб: строка = ""]',
      'МасСтр: массив','МасСтб: массив','Длина: целое','[Точн: целое = 0]','[Редакт: логическое = '+vTrue+']',
      '[РаздСтр: строка = "'+cDlmY+'"]','[РаздСтб: строка = "'+cDlmX+'"]','[Пустые: логическое = '+vFalse+']'],
      ['CU','CU','CU','CU','A','A','N','NU','LU','CU','CU','LU'],c_edit,null,1501,'C');
    SetFunction('ЧИСЛТБЛ_ЗНАЧ','Значение из числовой таблицы',
      ['Знач: строка','НомСтр: целое','НомСтб: целое',
      '[РаздСтр: строка = "'+cDlmY+'"]','[РаздСтб: строка = "'+cDlmX+'"]','[Пустые: логическое = '+vFalse+']'],
      ['C','N','N','CU','CU','LU'],c_val,null,1502,'NC');
  end;
  DelStack;
end.
