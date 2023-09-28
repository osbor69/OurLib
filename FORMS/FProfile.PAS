unit FProfile;

interface

{$I LIBTEST}

uses
  Messages, Classes, Controls, Dialogs, ExtCtrls, Grids, Menus,
  {$IFDEF PROF}MyTypes, {$ENDIF}FRMEMPTY, Keylb, Fpanel, StrBrowl, KeyMenu,
    FFldedit, DirGet, DefEdit, CCodeGet, RecVal;

type
{$IFDEF PROF}
	TColList = (nName,nCnt,nSelf,nSelfOne,nAll,nAllOne);
{$ENDIF}

  TProfile = class(TFormEmp)
    KeyMenu1: TKeyMenu;
    sb: TStringBrowl;
    de: TDefEdit;
    Rec: TRecVal;
    DirGet1: TDirGet;
    SaveDialog1: TSaveDialog;
{$IFDEF PROF}
  private
    { Private declarations }
    nSort: TColList;
    ViewPrc: boolean;
    itg: longword;
  	al: array[TColList] of longint;
    procedure SetLen(nc: TColList; l: longint);
    procedure Fill;
		procedure SetSort(ns: TColList);
		procedure ProcKey(key: longint; tw: TWinControl);
		procedure sbAfterPaint(Sender: TObject);
    procedure sbMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: longint);
		function dePnlValid(Sender: TObject): boolean;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
{$ENDIF}
  end;

{$IFDEF PROF}
  PProfRec = ^TProfRec;
	TProfRec = record
  	tSelf,tAll,tBeg,Cnt,Recursion,Correction: longword;
  end;

  TProfList = class(TStringList)
  private
  	aProf: array of TProfRec;
    function GetObj(i: longint): PProfRec;
    procedure ProcDel(oi,ni: longint);
  public
    function AddObj(const s: string; var obj: PProfRec): boolean;
  end;

var LsProf: TProfList;

{$ENDIF}

implementation

{$R *.DFM}

{$IFDEF PROF}
uses Windows,SysUtils,Graphics,Math,StrUtils,
  My_pr,BufFile;

var Profile: TProfile;
  TimeProf,TimeCorrection: longword;
  lProf: boolean = false;

// Включить профайлер
procedure ProfOn;
begin
	if not ProfSwitch then Exit;
  LsProf:=TProfList.Create; LsProf.Sorted:=true; SetLength(LsProf.aProf,100);
  lProf:=true; TimeProf:=My_pr.GetTickCount; TimeCorrection:=0;
end;

// Вывести профайлер на экран
procedure ProfOut(const Capt: TCaption = '');
var i: longint;
begin
	if not ProfSwitch then Exit;
  ProfSwitch:=false; lProf:=false;
  if CreateForm(TProfile,Profile) then with Profile do begin
    nSort:=nSelf; sb.OnAfterPaint:=sbAfterPaint; sb.OnMouseUp:=sbMouseUp; SetLen(nCnt,10);
    KeyLb1.SetKey(K_F2,'Сохранить','',ProcKey,'prof',kmFile);
    KeyLb1.SetKey(K_F11,'Сортировка','Сменить вид сортировки',ProcKey,'prof',kmList);
    KeyLb1.SetKey(K_Tab,'Вид','',ProcKey,'prof',kmFile);
    KeyLb1.SetKey(K_Ctrl_F6,'Печать','',ProcKey,'prof',kmFile);
    ViewPrc:=InitFIni[fiSchem].ReadBool('Global','ProfPrc');
    de.OnPnlValid:=dePnlValid;
  end;
  with Profile do begin
    Caption:=DlmBetween('Профайлер',Capt,': '); i:=0; itg:=0;
    while i<LsProf.Count do with LsProf.GetObj(i)^ do begin
      if tAll=0 then SLObjIndDel(LsProf,i,LsProf.ProcDel)
    	else begin
        MaxSelf(Cnt,1); Inc(itg,tSelf); Inc(i);
      end;
    end;
    Fill; ShowModal;
  end;
  FreeAndNil(LsProf); ProfSwitch:=true; FormFree(Profile);
end;

procedure ProfAddTime(FuncName: PString; const FuncAdd: string; oTime: longword; lIncCnt: boolean);
	function SeekRec(const fn: string): PProfRec;
  begin
    if LsProf.AddObj(fn,result) then begin
      ZeroMemory(result,SizeOf(result^)); result.Correction:=TimeCorrection;
    end;
  end;
var intv,cor: longword;
begin
	if lProf then begin
  	if Assigned(FuncName) then with SeekRec(FuncName^)^ do begin
      Inc(tSelf,oTime-TimeProf);
      if lIncCnt then Inc(Cnt);
    end;
    with SeekRec(FuncAdd)^ do if lIncCnt then begin
      Dec(Recursion);
      if Recursion=0 then begin
        intv:=oTime-tBeg; cor:=TimeCorrection-Correction;
        if intv>=cor then Dec(intv,cor);
        Inc(tAll,intv);
      end;
    end
    else begin
      Inc(Recursion);
      if Recursion=1 then begin
        tBeg:=My_pr.GetTickCount; Correction:=TimeCorrection;
      end;
    end;
    TimeProf:=My_pr.GetTickCount; Inc(TimeCorrection,TimeProf-oTime);
  end;
end;

{$IFDEF PROF}
{ TProfList }
function TProfList.AddObj;
var n: longint;
begin
  result:=not IntObjFindAdd(Self,s,n);
  if result then if Length(aProf)=n then SetLength(aProf,n shl 1);
  obj:=@aProf[n];
end;

function TProfList.GetObj;
begin
  result:=@aProf[IntObj(Self,i)];
end;

procedure TProfList.ProcDel;
begin
  aProf[ni]:=aProf[oi];
end;
{$ENDIF}

{ TProfile }
procedure TProfile.SetLen;
var ic: TStrBrInfZn;
  n: byte;
begin
  n:=byte(nc);
  with sb do begin
    ic:=InfoCol[n]; ic.LenData:=l; InfoCol[n]:=ic; al[nc]:=InfoCol[n].LenData;
  end;
end;

procedure TProfile.Fill;
  function MSecToStr(ms: longword): string;
  const t=2; l=t+4;
  var d: Double;
  begin
    if ViewPrc then begin
      if itg=0 then d:=0 else d:=mround(ms/itg*100,t);
      if d=0 then result:=space(l) else result:=SpaceStr0(d,l,t);
    end
    else result:=My_pr.MSecToStr(ms);
  end;
var j: longint;
  procedure ColTime(n: TColList; msec: longword);
  begin
  	if msec>0 then Profile.sb.Cells[byte(n),j]:=Padc(MSecToStr(msec),al[n]);
  end;
var i: longint;
  inf: TStrBrInfZn;
begin
  i:=Length(MSecToStr(0)); SetLen(nSelf,i); SetLen(nSelfOne,i); SetLen(nAll,i); SetLen(nAllOne,i);
  with sb do begin
	  Init; RowCount:=max(LsProf.Count,FixedRows)+1; j:=FixedRows; al[nName]:=0;
    for i:=0 to LsProf.Count-1 do with LsProf.GetObj(i)^ do begin
      Cells[byte(nName),j]:=LsProf[i]; Cells[byte(nCnt),j]:=SpaceStr(longint(Cnt),al[nCnt]);
      ColTime(nSelf,tSelf); ColTime(nSelfOne,nround(tSelf/Cnt));
      ColTime(nAll,tAll); ColTime(nAllOne,nround(tAll/Cnt));
      MaxSelf(al[nName],LsProf[i]); Inc(j);
    end;
    RowCount:=max(j,FixedRows+1); j:=1;
    inf:=sb.InfoCol[byte(nSelf)]; SetLength(inf.aName,2);
    inf.aName[1]:=Padc(MSecToStr(itg),al[nSelf])+IfThen(ViewPrc,'%'); sb.InfoCol[byte(nSelf)]:=inf;
    SetLen(nName,al[nName]); SetSort(nSort); MainRebuild;
  end;
end;

function FSort(p: pointer; fi,si: longint; sortID: TSortID): boolean;
var i: longint;
  s: string;
begin
  AddStack('FProfile.FSort');
  result:=false;
  with Profile,sb do case sortID of
    sort1MORE2:
      if nSort=nName
      then result := AnsiCompareText(Cells[byte(nSort),fi],Cells[byte(nSort),si])>0
      else result := AnsiCompareText(Cells[byte(nSort),fi],Cells[byte(nSort),si])<0;
    sortEXCHANGE: for i:=0 to ColCount-1 do begin
      s:=Cells[i,fi]; Cells[i,fi]:=Cells[i,si]; Cells[i,si]:=s;
    end;
  end;
  DelStack;
end;

procedure TProfile.SetSort;
var oName: string;
	i,l,h: longint;
  otl: TGridCoord;
begin
  AddStack('TProfile.SetSort',Self);
  nSort:=ns; SetRedraw(RbPanel2);
  with sb do begin
    oName:=Cells[byte(nName),Row]; l:=FixedRows; h:=RowCount-1; otl:=TopLeft; QuickSort(FSort,nil,l,h);
    for i:=l to h do
    	if Cells[byte(nName),i]=oName then begin
      	Row:=i; break;
      end;
    TopLeft:=otl;
  end;
  SetRedraw(RbPanel2,rdrwSet);
  DelStack;
end;

procedure TProfile.sbAfterPaint;
var r: TRect;
begin
	AddStack('TProfile.sbAfterPaint',Self);
	with sb do begin
    if nSort=nSelf then r:=GetRowRect(byte(nSort),byte(nSort),0)
    else begin
      r:=CellRect(byte(nSelf),0); Frame3D1(Canvas,r,false);
      r:=GetRowRect(byte(nSort),byte(nSort),0,FixedRows-1);
    end;
    Frame3D1(Canvas,r);
    with Canvas do begin
      r:=CellRect(byte(nSelf),1); Pen.Color:=clBlack;
      MoveTo(r.Left,r.Top-1); LineTo(r.Right,r.Top-1);
      Brush.Color:=Color; FillRect(r);
      Canvas.TextRect(r,r.Left+2,r.Top+2,Cells[byte(nSelf),1]);
    end;
  end;
  DelStack;
end;

procedure TProfile.sbMouseUp;
var ACol,ARow: longint;
begin
	AddStack('TProfile.sbMouseUp',Self);
	sb.MouseToCell(X,Y,ACol,ARow);
  if InRange(ACol,0,sb.ColCount-1) and InRange(ARow,0,sb.FixedRows-1) then SetSort(TColList(ACol));
  DelStack;
end;

function FPadR(const s: string; l: longint): string;
begin
	result:=Padr(s,l);
end;

function FZppR(const s: string; l: longint): string;
begin
	result:=Zppr(s,l);
end;

procedure TProfile.ProcKey;
type TProcPrn = function(const s: string; l: longint): string;
var txt: string;
	i: longint;
  procedure PrnRow(ProcPrn: TProcPrn);
  var j: TColList;
  	s: string;
  begin
    AddStack('TProfile.ProcKey.PrnRow',Self);
    s:='';
    with sb do for j:=low(al) to high(al) do IncD(s,'|'+ProcPrn(Cells[byte(j),i],al[j]));
    IncD(txt,Copy(s,2,MaxInt)+CRLF);
    DelStack;
  end;
var otl: TGridCoord;
begin
	AddStack('TProfile.ProcKey',Self);
  case Key of
		K_F2: begin
    	if Assigned(InitFIni) then Rec['FILE']:=InitFIni[fiSave].ReadString('PROFILE','FILE',ExeDir+'PROFILE.PFD');
    	de.Execute;
    	if Assigned(InitFIni) then InitFIni[fiSave].WriteString('PROFILE','FILE',Rec['FILE']);
    end;
		K_F11: SetSort(TColList(IfThen(nSort<high(al),byte(nSort)+1)));
    K_Tab: begin
      txt:=sb.Cells[byte(nName),sb.Row]; NotD(ViewPrc);
      InitFIni[fiSchem].WriteBool('Global','ProfPrc',ViewPrc); otl:=sb.TopLeft; Fill;
      for i:=sb.FixedRows to sb.RowCount-1 do
        if sb.Cells[byte(nName),i]=txt then begin
          sb.Row:=i; break;
        end;
      sb.TopLeft:=otl;
    end;
    K_Ctrl_F6: with sb do begin
      txt:='';
    	for i:=0 to FixedRows-1 do PrnRow(FPadr);
      IncD(txt,StringOfChar('-',SumInt(al)+ColCount-1)+CRLF);
    	for i:=FixedRows to RowCount-1 do PrnRow(FZppr);
    	PrnTxtHeadExec(['Профайлер'],txt);
		  //EdTextView('Профайлер',txt);
    end;
  end;
  DelStack;
end;

procedure TProfile.WMFormLimit;
begin
	AddStack('TProfile.WMFormLimit',Self);
  inherited;
  FreeLimit(Profile);
  DelStack;
end;

function TProfile.dePnlValid;
var i: longint;
	f: TFileBuf;
begin
  AddStack('TProfile.dePnlValid',Self);
  result:=not empty(Rec['FILE']);
  if result then begin
    f:=TFileBuf.Create(Rec['FILE'],true);
    try
      if f.Active then begin
        f.Write(0,stByte);
        for i:=0 to LsProf.Count-1 do with LsProf.GetObj(i)^ do begin
          f.Write(Cnt,stLongWord); f.Write(tSelf,stLongWord); f.Write(tAll,stLongWord);
          f.WriteString(LsProf[i]+#0);
        end;
        f.Update;
      end;
      if not f.Active then meserr(f.ErrorMessage);
    finally
    	f.Free;
    end;
  end;
  DelStack;
end;

initialization
  MyTypes.ProfOn:=ProfOn; MyTypes.ProfOut:=ProfOut; MyTypes.ProfAddTime:=ProfAddTime;
finalization
  FreeAndNil(LsProf); ProfSwitch:=false; lProf:=false;
{$ENDIF}
end.
