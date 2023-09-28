unit FGFBmp;

interface

{$I LIBTEST}
uses
  Windows, Messages, Classes, Graphics, Controls, Dialogs, ExtCtrls, Grids, Menus,
  MyTypes, GenForm, FRMEMPTY, Keylb, Fpanel, StrBrowl, KeyMenu, DefEdit, RecVal, FFldEdit, ButGet;

type
  TGFBmpOpt = set of (gfbmpSel);

  TGFBmp = class(TFormEmp)
    pnLs: TRbPanel;
    pnSamp: TRbPanel;
    sb: TStringBrowl;
    KeyMenu1: TKeyMenu;
    Rec: TRecVal;
    de: TDefEdit;
    BmpGet: TButGet;
    dlgBmp: TOpenDialog;
    function sbCalcZn(Sender: TObject; ACol: longint): String;
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    procedure FormCreate(Sender: TObject);
    procedure BmpGetPaint(Sender: TObject; const ARect: TRect; const Text: String);
    procedure FormDestroy(Sender: TObject);
    function BmpGetClick(Sender: TObject; lEval: Boolean): String;
    function deFldCheck(Sender: TObject): Boolean;
    procedure sbKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure sbMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X,Y: longint);
    procedure sbDrawCell(Sender: TObject; ACol,ARow: longint; Rect: TRect;
      State: TGridDrawState);
    procedure pnSampAfterPaint(Sender: TObject);
  private
    { Private declarations }
    ls: TGFBitMapList;
    sel: boolean;
    bm: TBitMap;
    nSel,oRow: longint;
    PartIni,UserName: string;
    lsbmDsgn: TGFBitMapList;
    ProcModify: TNotifyEvent;
		class procedure pbBitMap(Canvas: TCanvas; const ARect: TRect; bm: TBitMap; offs: byte);
		procedure SampRead;
    procedure ProcKeyNoCng(key: longint; tw: TWinControl);
		function dlgBmpExec(var s: string): boolean;
    class procedure UserBmpModify(Sender: TObject);
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
		class function Execute(lsBM,lsBitMapDsgn: TGFBitMapList;
    	Opt: TGFBmpOpt; const CurCod,sPartIni,sUserName: string; PrModify: TNotifyEvent): string; overload;
		class procedure Execute(const sUserName: string); overload;
  end;

var
  GFBmp: TGFBmp;

implementation

{$R *.dfm}

uses SysUtils,Math,StrUtils,
  My_pr,MulQry,RecDB;

procedure TGFBmp.FormCreate(Sender: TObject);
begin
	AddStack('TGFBmp.FormCreate',Self);
  inherited;
  bm:=TBitMap.Create;
  DelStack;
end;

procedure TGFBmp.FormDestroy(Sender: TObject);
begin
	AddStack('TGFBmp.FormDestroy',Self);
  inherited;
  bm.Free;
  DelStack;
end;

class function TGFBmp.Execute(lsBM,lsBitMapDsgn: TGFBitMapList;
  Opt: TGFBmpOpt; const CurCod,sPartIni,sUserName: string; PrModify: TNotifyEvent): string;
var i: longint;
  inf: TStrBrInfZn;
begin
  AddStack('TGFBmp.Execute');
  CreateForm(TGFBmp,GFBmp);
  with GFBmp do begin
  	sel:=gfbmpSel in Opt;
    ls:=lsBM; lsbmDsgn:=lsBitMapDsgn; PartIni:=sPartIni; UserName:=sUserName; ProcModify:=PrModify;
  	with KeyLb1 do begin
      if Assigned(lsbmDsgn) then begin
      	DelKey(K_All,'cng');
        SetKeys([K_F5,K_Enter],'Изменить','Изменить рисунок',ProcKeyNoCng,'nocng',kmList);
        SetKey(K_Ctrl_Home,'По умолчанию','Установить рисунок по умолчанию',ProcKeyNoCng,'nocng',kmList);
      end
      else begin
      	DelKey(K_All,'nocng');
        SetKey(K_F4,'Скопировать','',KeyLb1ProcKey,'cng',kmList);
        SetKeys([K_F5,K_Enter],'Редактировать','',KeyLb1ProcKey,'cng',kmList);
        SetKey(K_F7,'Добавить','',KeyLb1ProcKey,'cng',kmList);
        SetKey(K_F8,'Удалить','',KeyLb1ProcKey,'cng',kmList);
      end;
      if sel then begin
        SetKey(K_Enter,'Выбор','',KeyLb1ProcKey,'sel',kmList);
        SetKey(K_Esc,'Отмена','',KeyLb1ProcKey,'sel',kmList);
      end
      else DelKey(K_All,'sel');
      Redrw;
    end;
    sb.ColZn.BeginUpdate; sb.ColZn.Clear;
    Finalize(inf); ZeroMemory(@inf,SizeOf(inf));
    CopyFrom(inf.aName,'Код'); inf.LenData:=Length(Rec[fDcmBmpCOD]); sb.InfoCol[0]:=inf;
    if UserName='' then begin
      inf.aName[0]:='Наименование'; inf.lMax:=true; sb.InfoCol[1]:=inf;
    end;
    de.Param[fNAME,deNoVisible]:=bStr[UserName<>''];
    sb.ColZn.EndUpdate;
    sb.AddSt(ls.Count);
    sb.Row:=sb.FixedRows; result:='';
    for i:=sb.Row to sb.RowCount-1 do if TrimUpper(sb.Cells[0,i])=TrimUpper(CurCod) then begin
      sb.Row:=i; break;
    end;
    MainRebuild;
    Caption:='Рисунки'+IfThen(UserName<>'',' (пользователь '+Trim(UserName)+')');
    if ShowModal=mrOk then if ls.Count>0 then result:='"'+ls[sb.Row-sb.FixedRows]+'"';
  end;
  FormFree(GFBmp);
  DelStack;
end;

class procedure TGFBmp.Execute(const sUserName: string);
var ls: TGFBitMapList;
begin
  AddStack('TGFBmp.Execute(user)');
  ls:=TGFBitMapList.Create;
  try
    ls.LoadFromDB(fUSERNAME+'='+QQs(sUserName),[gfbmUser]);
    Execute(ls,nil,[],'','',sUserName,UserBmpModify);
  finally
    ls.Free;
  end;
  DelStack;
end;

class procedure TGFBmp.UserBmpModify;
begin
  AddStack('TGFBmp.UserBmpModify');
  UserBmpClear;
  DelStack;
end;

procedure TGFBmp.SampRead;
begin
  AddStack('TGFBmp.SampRead',Self);
  if sb.Row<>oRow then begin
  	oRow:=sb.Row; pnSamp.Invalidate;
  end;
  DelStack;
end;

class procedure TGFBmp.pbBitMap;
const iX=5; iY=5; iX2 = iX shl 1; iY2 = iY shl 1;
var prc: Double;
	r: TRect;
  w,h: longint;
begin
  AddStack('TGFBmp.pbBitMap');
  with Canvas do begin
  	FillRect(ARect);
    if Assigned(bm) then begin
    	w:=ARect.Right-ARect.Left-offs-iX2; h:=ARect.Bottom-ARect.Top-offs-iY2;
    	if (bm.Width>w) or (bm.Height >h) then begin
      	prc:=max(bm.Width/w,bm.Height/h);
        r.Right:=nround(bm.Width/prc); r.Bottom:=nround(bm.Height/prc);
        r.Left:=ARect.Left+iX+(w-r.Right) div 2; r.Top:=ARect.Top+iY+(h-r.Bottom) div 2;
        Inc(r.Right,r.Left); Inc(r.Bottom,r.Top); StretchDraw(r,bm);
      end
      else Draw(ARect.Left+(ARect.Right-ARect.Left-offs-bm.Width) div 2,
      	ARect.Top+(ARect.Bottom-ARect.Top-offs-bm.Height) div 2,bm);
    end;
  end;
  DelStack;
end;

function TGFBmp.sbCalcZn(Sender: TObject; ACol: longint): String;
var i: longint;
begin
	AddStack('TGFBmp.sbCalcZn',Self);
  result:='';
  if Assigned(ls) then begin
    i:=sb.Row-sb.FixedRows;
  	if InRange(i,0,ls.Count-1) then case ACol of
      0: result:=Padr(ls[i],Length(Rec[fDcmBmpCOD]));
      1: result:=ls.GetBM(i).Name;
    end;
  end;
  DelStack;
end;

procedure TGFBmp.KeyLb1ProcKey(key: longint; tw: TWinControl);
	procedure ReadRec;
  begin
    AddStack('TGFBmp.KeyLb1ProcKey.ReadRec',Self);
    nSel:=sb.Row-sb.FixedRows; Rec[fDcmBmpCOD]:=ls[nSel];
    with ls.GetBM(nSel)^ do begin
	    Rec[fNAME]:=Name; Rec['BMP']:=ls.BitMapToStr(bm);
    end;
    DelStack;
  end;
  procedure Modify;
  begin
    AddStack('TGFBmp.KeyLb1ProcKey.Modify',Self);
    SampRead; IfThenNotify(ProcModify); 
    DelStack;
  end;
var i: longint;
  otl: TGridCoord;
begin
	AddStack('TGFBmp.KeyLb1ProcKey',Self);
	if sel then case Key of
  	K_F10: Key:=K_Esc;
  	K_Enter: Key:=K_F10;
	end;
  inherited;
  if (ls.Count>0) or (Key=K_F7) then case Key of
    K_F4,K_F7: begin
      SetLogVid(logvAppRec);
    	if Key=K_F4 then ReadRec
      else begin
      	Rec[fDcmBmpCOD]:=''; Rec[fNAME]:=''; Rec['BMP']:='';
      end;
    	if de.Execute('Добавить рисунок').Saved then begin
        if UserName='' then i:=0
        else with DBBmp do begin
          NewRec; Value[fUSERNAME]:=UserName; Value[fDcmBmpCOD]:=Rec[fDcmBmpCOD];
          Value[fDCMBMP]:=Rec['BMP']; AppRec(true); i:=Recno;
        end;
      	nSel:=ls.AddBM(TrimRight(Rec[fDcmBmpCOD]),Rec[fNAME],Rec['BMP'],i);
        if ls.Count>1 then begin
        	SetRedraw(sb); sb.AddSt;
          for i:=nSel to ls.Count-1 do begin
          	sb.Row:=sb.FixedRows+i; sb.CurStUpdate;
          end;
          sb.Row:=sb.FixedRows+nSel; SetRedraw(sb,rdrwSet);
        end
        else sb.CurStUpdate;
        Modify;
      end
      else nSel:=-1;
      SetLogVid;
    end;
    K_F5,K_Enter: begin
      SetLogVid(logvEditRec);
    	ReadRec;
    	if de.Execute('Редактировать рисунок').Saved then begin
      	SetRedraw(sb); ls.Sorted:=false; i:=nSel; ls[i]:=TrimRight(Rec[fDcmBmpCOD]);
        with ls.GetBM(nSel)^ do begin
          Name:=Rec[fNAME]; ls.StrToBitMap(Rec['BMP'],bm);
          if UserName<>'' then with DBBmp do begin
            GotoRec(nRec); Value[fDcmBmpCOD]:=Rec[fDcmBmpCOD]; Value[fDCMBMP]:=Rec['BMP']; UpdateRec(true);
          end;
        end;
      	ls.Sorted:=true; nSel:=ls.IndexOf(TrimRight(Rec[fDcmBmpCOD])); otl:=sb.TopLeft;
        for i:=min(i,nSel) to max(i,nSel) do begin
        	sb.Row:=sb.FixedRows+i; sb.CurStUpdate;
        end;
        sb.Row:=sb.FixedRows+nSel; sb.TopLeft:=otl; SetRedraw(sb,rdrwSet); Modify;
      end;
      SetLogVid;
    end;
    K_F8: if Ask(amsDel) then begin
    	SetRedraw(sb); nSel:=sb.Row-sb.FixedRows;
      if UserName<>'' then with DBBmp do begin
        GotoRec(ls.GetBM(nSel).nRec); DelRec('',[delLog]);
      end;
      ls.Delete(nSel);
      if ls.Count>0 then sb.IncRowCount(-1);
      for i:=nSel to ls.Count-1 do begin
        sb.Row:=sb.FixedRows+i; sb.CurStUpdate;
      end;
      sb.Row:=min(sb.FixedRows+nSel,sb.RowCount-1); SetRedraw(sb,rdrwSet);
      Modify;
    end;
  end;
  DelStack;
end;

function TGFBmp.deFldCheck(Sender: TObject): Boolean;
var i: longint;
begin
	AddStack('TGFBmp.deFldCheck',Self);
  if not NoEmpCheck(Sender,fDcmBmpCOD,result) then
    if result then if ls.Find(TrimRight(TFldEdit(Sender).VarValue),i) then if i<>nSel then begin
      meserr('Рисунок с таким кодом уже есть.'); result:=false;
    end;
  DelStack;
end;

procedure TGFBmp.BmpGetPaint(Sender: TObject; const ARect: TRect; const Text: String);
begin
	AddStack('TGFBmp.BmpGetPaint',Self);
  ls.StrToBitMap(Rec['BMP'],bm); pbBitMap(TFldEdit(Sender).Canvas,ARect,bm,4);
  DelStack;
end;

function TGFBmp.BmpGetClick(Sender: TObject; lEval: Boolean): String;
var s: string;
begin
	AddStack('TGFBmp.BmpGetClick',Self);
  if lEval then if dlgBmpExec(s) then TFldEdit(Sender).VarValue:=s;
  result:='';
  DelStack;
end;

function TGFBmp.dlgBmpExec;
begin
  AddStack('TGFBmp.dlgBmpExec',Self);
  result:=FileExec('GFBmp',dlgBmp);
  if result then s:=ls.FileToStr(dlgBmp.FileName);
  DelStack;
end;

procedure TGFBmp.pnSampAfterPaint(Sender: TObject);
var i,b,h: longint;
	bm: TBitMap;
begin
  i:=sb.Row-sb.FixedRows;
  if InRange(i,0,ls.Count-1) then bm:=ls.GetBM(i).bm else bm:=nil;
  with TRbPanel(Sender) do begin
  	b:=BevPanel; h:=HeaderHeight; pbBitMap(Canvas,Rect(b,b+h,CltWidth,CltHeight-h),bm,0);
  end;
end;

procedure TGFBmp.sbKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
	AddStack('TGFBmp.sbKeyUp',Self);
  SampRead;
  DelStack;
end;

procedure TGFBmp.sbMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: longint);
begin
	AddStack('TGFBmp.sbMouseUp',Self);
  SampRead;
  DelStack;
end;

procedure TGFBmp.ProcKeyNoCng;
var s,w: string;
	i: longint;
begin
	AddStack('TGFBmp.ProcKeyNoCng',Self);
  i:=sb.Row-sb.FixedRows;
  w:=DBBmp.TblFldName(fDcmBmpPART)+'='+QQs(PartIni)+sAND+DBBmp.TblFldName(fDcmBmpCOD)+'='+QQs(ls[i]);
  case Key of
    K_F5,K_Enter: if dlgBmpExec(s) then with DBBmp do begin
      if not Seek(w) then begin
        NewRec; DBBmp[fDcmBmpPART]:=PartIni; DBBmp[fDcmBmpCOD]:=ls[i];
      end;
      DBBmp[fDCMBMP]:=s; AppUpdRec; ls.ReDefine(i,s); sb.Refresh; pnSamp.Invalidate;
    end;
    K_Ctrl_Home: begin
      if Ask(['Установить рисунок "'+ls[i]+'" по умолчанию ?']) then begin
        DbBmp.DelRec(w);
        ls.ReDefine(i,ls.BitMapToStr(lsbmDsgn.GetBM(i).bm),false);
        sb.Refresh; pnSamp.Invalidate;
      end;
    end;
  end;
  DelStack;
end;

procedure TGFBmp.sbDrawCell(Sender: TObject; ACol,ARow: longint;
  Rect: TRect; State: TGridDrawState);
var i: longint;
begin
  AddStack('TGFBmp.sbDrawCell',Self);
  i:=ARow-sb.FixedRows;
  if InRange(i,0,ls.Count-1) then
  	if ls.GetBM(i).ReDef then with sb.Canvas do begin
    	if State=[] then Brush.Color:=sb.FixedColor else Font.Color:=sb.FixedColor;
    	TextRect(Rect,Rect.Left+2,Rect.Top+2,sb.Cells[ACol,ARow]);
    end;
  DelStack;
end;

procedure TGFBmp.WMFormLimit;
begin
	AddStack('TGFBmp.WMFormLimit',Self);
  inherited;
  FreeLimit(GFBmp);
  DelStack;
end;

end.
