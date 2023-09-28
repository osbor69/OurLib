unit IconGet;

interface

uses Classes,SysUtils,
  MultiGet,RecVal,FFldEdit;

const icnCnt = 3;

type
  TIconList = 1..icnCnt;

  TIconGet = class(TMultiGet)
  private
    class procedure fChange(Sender: TObject; const OldVal: Variant; FromShow: Boolean);
  protected
  	Rec: TRecVal;
    aFld: array[TIconList] of TFldEdit;
		procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
		procedure PaintObj(tf: TFldEdit); override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    function AssignObj(tf: TFldEdit): boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
		class function Save(tf: TFldEdit; const ObjName,WorkDir,NameLnk: TFileName): boolean;
		class function SaveObj(const aDir: array of string;
    	const ObjName,WorkDir,NameLnk: TFileName): boolean;
  end;

procedure Register;

implementation

uses Windows,DB,ShlObj,ActiveX,Ole2,StrUtils,
  MyTypes,My_pr,DirGet,ChkGets;

var IconDirGet: TDirGet;

type TIconStr = array[TIconList] of string;

function GetRoot(i: TIconList): string;
const aRoot: TIconStr = ('Desktop','Start Menu','');
begin
  AddStack('IconGet.GetRoot');
  if aRoot[i]='' then result:=''
  else result:=GetRegKey(HKEY_CURRENT_USER,REGSTR_PATH_SPECIAL_FOLDERS,aRoot[i]);
  DelStack;
end;

{ TIconGet }
constructor TIconGet.Create;
begin
	AddStack('TIconGet.Create',Self);
  if not Assigned(IconDirGet) then begin
	  IconDirGet:=TDirGet.Create; IconDirGet.VName:='IconDirGet'; 
  end;
  inherited Create(AOwner);
  RVid:='';
  DelStack;
end;

procedure TIconGet.CreateObj;
const aName: TIconStr = ('на рабочем столе','в меню "ѕуск"','в другой папке');
var i: TIconList;
  s: string;
  tf1: TFldEdit;
begin
	AddStack('TIconGet.CreateObj',Self);
  DestroyObj(tf); Rec:=TRecVal.Create(tf);
  for i:=low(aName) to high(aName) do begin
  	s:=IntToStr(i); Rec.CreateFld('L'+s,ftBoolean,0,false); Rec.CreateFld('D'+s,ftMemo,0,'');
    aFld[i]:=TFldEdit.Create(tf);
    with aFld[i] do begin
      Parent:=tf; Vid:=TBoolGet.ClassName; Mask:=aName[i]; NameRec:=Rec.NameRec; NameRecFld:='L'+s;
      OnChange:=fChange;
    end;
    tf1:=TFldEdit.Create(tf);
    with tf1 do begin
      Parent:=tf; AssignGet(IconDirGet); Mask:=DlmBetween('—оздать €рлык '+aName[i],GetRoot(i),UnDelim);
      NameRec:=Rec.NameRec; NameRecFld:='D'+s; IncOptions([ogReadOnlyNoVsbl],[ogAutoSize]);
    end;
    aFld[i].FocusControl:=tf1;
  end;
  tf.Relation:=frMain; tf.ReCreateObj;
  DelStack;
end;

procedure TIconGet.ReCreateObj;
var i: TIconList;
	ro,nv: boolean;
begin
	AddStack('TIconGet.ReCreateObj',Self);
  if AssignObj(tf) then begin
  	ro := ogReadOnly in tf.Options; nv := ogReadOnlyNoVsbl in tf.Options;
  	for i:=low(aFld) to high(aFld) do with aFld[i] do begin
    	SetReadOnly(ro);
    	if ro then begin
      	if nv then IncOptions([ogReadOnlyNoVsbl]);
      	TFldEdit(FocusControl).SetReadOnly(true);
      end
      else begin
      	IncOptions([],[ogReadOnlyNoVsbl]); fChange(aFld[i],false,false);
      end;
    end;
  end;
  inherited RecreateObj(tf);
  DelStack;
end;

procedure TIconGet.PaintObj;
var i: TIconList;
begin
	AddStack('TIconGet.PaintObj',Self);
  if AssignObj(tf) then for i:=low(aFld) to high(aFld) do
	  with TFldEdit(aFld[i].FocusControl) do SetBounds(Left,Top,tf.Width-Left,SizeAuto.cY+BevelFld2);
  DelStack;
end;

function TIconGet.GetValue;
var i: TIconList;
	s: string;
begin
	AddStack('TIconGet.GetValue',Self);
  result:='';
  if AssignObj(tf) then begin
    for i:=low(i) to high(i) do begin
      s:=IntToStr(i); IncD(result,Bool2Str(Rec['L'+s])+Rec['D'+s]+UnDelim);
    end;
    DecLen(result,lUnDelim);
  end;
  DelStack;
end;

procedure TIconGet.SetValue;
var a: TIconStr;
	i: TIconList;
begin
	AddStack('TIconGet.SetValue',Self);
  if AssignObj(tf) then begin
    LsArrFill(v,a,UnDelim);
    for i:=low(a) to high(a) do begin
    	aFld[i].VarValue:=StrToBoolean(LeftStr(a[i],1));
      TFldEdit(aFld[i].FocusControl).VarValue:=Copy(a[i],2,MaxInt);
    end;
  end;
  DelStack;
end;

function TIconGet.AssignObj;
var i: TIconList;
	j: longint;
begin
	AddStack('TIconGet.AssignObj',Self);
  Rec:=nil; ZeroMemory(@aFld,SizeOf(aFld)); result:=false;
  if inherited AssignObj(tf) then begin
    result := tf.ComponentCount = (icnCnt shl 1)+1;
    if result then begin
    	Rec:=pointer(tf.Components[0]); j:=1;
		  for i:=low(aFld) to high(aFld) do begin
		  	aFld[i]:=pointer(tf.Components[j]); Inc(j,2);
      end;
    end;
  end;
  DelStack;
end;

class procedure TIconGet.fChange;
begin
	AddStack('TIconGet.fChange');
  with TFldEdit(Sender) do
  	TFldEdit(FocusControl).SetReadOnly((ogReadOnly in TFldEdit(Owner).Options) or not VarValue);
  DelStack;
end;

class function TIconGet.Save;
var g: TIconGet;
  s: string;
  aDir: TArrStr;
  i,j: byte;
begin
  AddStack('TIconGet.Save');
  result:=false;
  if IsClass(tf.curget,TIconGet,pointer(g)) then
  	if g.AssignObj(tf) then begin
    	j:=0; SetLength(aDir,Length(g.aFld));
      for i:=low(aDir) to high(aDir) do if g.aFld[i].VarValue then begin
        s:=GetRoot(i);
        if s<>'' then CorrDirSelf(s);
        aDir[j]:=s+TFldEdit(g.aFld[i].FocusControl).VarValue; Inc(j);
      end;
      SetLength(aDir,j); result:=SaveObj(aDir,ObjName,WorkDir,NameLnk);
    end;
  DelStack;
end;

class function TIconGet.SaveObj;
var hres: HRESULT;
  psl: IShellLink;
  ppf: IPersistFile;
  tg: System.TGUID;
  i: ShortInt;
  wsz: array[0..MAX_PATH] of WideChar;
begin
	AddStack('TIconGet.SaveObj');
  hres:=ActiveX.CoCreateInstance(CLSID_ShellLink,nil,CLSCTX_INPROC_SERVER,IID_IShellLinkA,psl);
  if hres=S_OK then begin
    psl._AddRef; psl.SetPath(PChar(ObjName)); psl.SetWorkingDirectory(PChar(WorkDir));
    with IID_IPersistFile do begin
      tg.D1:=D1; tg.D2:=D2; tg.D3:=D3;
      for i:=low(D4) to high(D4) do tg.D4[i]:=D4[i];
    end;
    hres:=psl.QueryInterface(tg,ppf);
    if hres=S_OK then begin
      ppf.AddRef;
      for i:=low(aDir) to high(aDir) do begin
        MultiByteToWideChar(CP_ACP,0,PChar(CorrDir(aDir[i])+NameLnk+'.LNK'),-1,wsz,MAX_PATH);
        hres:=ppf.Save(wsz,true);
        if hres<>S_OK then break;
      end;
      ppf.Release;
    end;
    psl._Release;
  end;
  result := hres=S_OK;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TIconGet]);
end;

initialization
finalization
	AddStack('IconGet.finalization');
  IconDirGet.Free;
  DelStack;
end.
