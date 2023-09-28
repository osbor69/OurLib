unit FSpList;

interface

{$I LIBTEST}
uses
  Messages, Classes, Controls, ExtCtrls, StdCtrls, DBCtrls, DB, dbcgrids, Menus,
  MyTypes, KeyMenu, FRMEMPTY, Keylb, Fpanel, Browl, BrQuery, DefEdit, FFldEdit;

type
  TSpList = class(TFormEmp)
    DataSource1: TDataSource;
    CtrlBrowl1: TCtrlBrowl;
    Panel1: TPanel;
    DBText1: TDBText;
    KeyMenu1: TKeyMenu;
    deSp: TDefEdit;
    procedure FormCreate(Sender: TObject);
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    function CtrlBrowl1StrFind: string;
    procedure deSpFrmShow(Sender: TObject);
    function deSpPnlValid(Sender: TObject): Boolean;
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
    function PrMaxLength(Sender: TObject): longint;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    ParCtrl: TControl;
    ValSeek: string;
    Qry: TFindQuery;
    tfCur: TFldEdit;
    NoLimSize: boolean;
    function Edit(const Capt: TCaption): boolean;
		class procedure AddZn(const gk: string);
  end;

var SpList: TSpList;
  GetSpLogPrm: function(logk: longint; const Mask: string): TSpGkLog;
  SetSpLogPrm: procedure(const Value: TSpGkLog);

implementation

{$R *.DFM}

uses Windows,SysUtils,Math,StrUtils,
  My_pr,PnlEdit,FrmEdt,RecDB,MulQry;

{ TSpList }
procedure TSpList.FormCreate(Sender: TObject);
begin
	AddStack('TSpList.FormCreate',Self);
  Qry:=TFindQuery.Create(Self);
  with Qry do begin
  	Connection:=FirstDatabase;
  	Arg[SGLOBKEY]:='1'; PartSelect(tSPDB,[],fSpGK+'='+QQs(qGlobKey),fUPNAME,'',false);
  end;
	Qry.DataSource:=DataSource1;
  deSp.Param[fNAME,deNameRec]:=Spdb.NameRec;
 	inherited;
  DelStack;
end;

procedure TSpList.KeyLb1ProcKey(key: longint; tw: TWinControl);
var tr,ii: longint;
  oLog: TSpGkLog;
begin
	AddStack('TSpList.KeyLb1ProcKey',Self);
	inherited;
  if Qry.IsRecords or (Key=K_F7) then begin
    ii:=Qry.FieldZn(fRECNO);
    if Key<>K_F7 then SpDb.GotoRec(ii);
    case Key of
      K_F4,K_F7: begin
        oLog:=GetSpLogPrm(logvAppRec,tfCur.Mask);
        try
          SpDb.NewRec(IfThen(Key=K_F4,newrCopy),Qry.Arg[SGLOBKEY]);
          if Key=K_F7 then Spdb[fNAME]:=tfCur.Value;
          if Edit(IfThen(Key=K_F4,'Копирование','Добавление')) then begin
            AddZn(Qry.Arg[SGLOBKEY]);
            CtrlBrowl1.BrUpdate(CtrlBrowl1.Row,SpDb.Recno); MainRebuild;
          end
          else SpDb.GotoRec(ii);
        finally
          SetSpLogPrm(oLog);
        end;
      end;
      K_F5: begin
        oLog:=GetSpLogPrm(logvEditRec,tfCur.Mask);
        try
          if Edit('Корректировка') then CtrlBrowl1.BrUpdate(CtrlBrowl1.Row,ii);
        finally
          SetSpLogPrm(oLog);
        end;
      end;
      K_F8: begin
        oLog:=GetSpLogPrm(logvDelRec,tfCur.Mask);
        try
          if Ask(amsDel,true) then with Qry do begin
            tr:=CtrlBrowl1.Row; Spdb.DelRec('',[delLog]); Next;
            if Eof then ii:=0 else ii:=FieldZn(fRECNO);
            CtrlBrowl1.BrUpdate(tr,ii); MainRebuild;
          end;
        finally
          SetSpLogPrm(oLog);
        end;
      end;
      K_Enter: SetModalResult(mrOk);
    end;
  end;
  DelStack;
end;

function TSpList.Edit;
var s: string;
  i: longint;
begin
  AddStack('TSpList.Edit',Self);
  if NoLimSize then begin
    i:=Spdb.NumFromName(fNAME); s:=TrimRight(Spdb.ValueNum[i]);
    result:=EdTextExec(Capt,s,'',nil,[edtxtWordWrap],edtpText,0,0,'',0,nil,'',nil,nil,'',nil,nil,nil,PrMaxLength);
    if result then begin
      Spdb.ValueNum[i]:=s; Spdb.UpdateRec(true);
    end;
  end
  else result:=deSp.Execute(Capt).Saved;
  DelStack;
end;

function TSpList.PrMaxLength;
begin
  AddStack('TSpList.PrMaxLength',Self);
  result:=Length(Spdb[fNAME]);
  DelStack;
end;

class procedure TSpList.AddZn;
var nm: string;
begin
	AddStack('TSpList.AddZn');
  nm:=Spdb[fNAME];
  with Spdb do if not Seek(TblFldName(fSpGK)+'='+QQs(gk)+sAND+TblFldName(fUPNAME)+'='+QQs(AnsiUpperCase(nm))) then begin
    NewRec([],gk); Spdb[fNAME]:=nm; AppRec(true);
  end;
  DelStack;
end;

function TSpList.CtrlBrowl1StrFind: string;
begin
	AddStack('TSpList.CtrlBrowl1StrFind',Self);
  inherited;
  result:=Qry.FieldZn(fNAME);
  DelStack;
end;

// Системные списки
procedure TSpList.deSpFrmShow(Sender: TObject);
var l,t,w,h,pw,ph: longint;
	pt: TPoint;
  tf: TFldEdit;
  wAll,lr: boolean;
  r: TRect;
begin
	AddStack('TSpList.deSpFrmShow',Self);
  inherited;
  with TFormEdt(Sender) do begin
    PanelEdit1.FillKeyLb; PanelEdit1.FillFldList;
    if Assigned(ParCtrl) then with ParCtrl do begin
      pt:=ClientOrigin; pw:=Width; ph:=Height;
    end
    else begin
      ZeroMemory(@pt,SizeOf(pt)); pw:=0; ph:=0;
    end;
    if Assigned(tfCur) then wAll := tfCur.CharWidth<0 else wAll:=false;
    tf:=PanelEdit1.Fields[0]; tf.CharWidth:=IfThen(wAll,wallDefault); lr := RbPanel1.Place in [rpLeft,rpRight];
    r:=SysWorkArea; BoundsRect:=r; l:=Left;
    w:=RbPanel1.BevPanel2+PanelEdit1.BevPanel2+tf.Width;
    h:=RbPanel1.BevPanel2+PanelEdit1.BevPanel2+tf.Height;
    if lr then Inc(w,KeyLb1.Width) else MaxSelf(w,KeyLb1.WMin);
    if not wAll then if w>ClientWidth then begin
      wAll:=true; tf.CharWidth:=wallDefault; MainRebuild;
    end;
    if lr then begin
      ClientHeight:=max(h,KeyLb1.HMin);
      if not wAll then begin
        ClientWidth:=w; l:=pt.X+(pw-Width) div 2; t := KeyLb1.Width div 2;
        if RbPanel1.Place=rpLeft then Dec(l,t) else Inc(l,t);
      end;
    end
    else begin
      ClientHeight:=h+KeyLb1.Height;
      if not wAll then begin
        ClientWidth:=w; l:=pt.X+(pw-Width) div 2;
      end;
    end;
    t:=pt.Y+ph;
    if t+Height>r.Bottom then t:=pt.Y-Height;
    SetBounds(l,t,Width,Height);
    while (tf.BoundsRect.Bottom>PanelEdit1.CltHeight) and (BoundsRect.Right<r.Right) do IncWidth(pointer(Sender),1);
  end;
  DelStack;
end;

function TSpList.deSpPnlValid(Sender: TObject): Boolean;
begin
	AddStack('TSpList.deSpPnlValid',Self);
  inherited;
  ValSeek:=TPanelEdit(Sender).Fields[0].Value; result:=true;
  DelStack;
end;

procedure TSpList.WMFormLimit;
begin
	AddStack('TSpList.WMFormLimit',Self);
  inherited;
  FreeLimit(SpList);
  DelStack;
end;

procedure TSpList.FormHide(Sender: TObject);
begin
  AddStack('TSpList.FormHide');
  inherited;
  Qry.ClearFilter;
  DelStack;
end;

initialization
  AddStack('FSpList.initialization');
  SetPrim(tSPDB,'Списки');
  DelStack;
end.
