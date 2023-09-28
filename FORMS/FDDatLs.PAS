unit FDDatLs;

interface

{$I LIBTEST}
uses
  Windows, Messages, Classes, Controls, Menus, DB, Grids, DBGrids, ExtCtrls,
  MyTypes, My_pr, FrmBrIB, KeyMenu, Browl, Keylb, Fpanel, RecVal, RecDB, DefEdit, FFldEdit, DDProc;

type
  TDDatLs = class(TFormBrIB)
    de: TDefEdit;
    Rec: TRecVal;
    procedure FormCreate(Sender: TObject);
    procedure Browl1BrowlKey(key: longint; tw: TWinControl);
    function deFldCheck(Sender: TObject): Boolean;
    procedure deFldExit(Sender: TObject);
    function dePnlValid(Sender: TObject): Boolean;
    procedure deFrmShow(Sender: TObject);
    procedure Browl1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: longint; Column: TColumn; State: TGridDrawState);
  private
    { Private declarations }
    dd: TDynamicDat;
    inf: PDDatKvInfo;
    tfCur: TFldEdit;
    oNewRec: TRDBNewRec;
    BrQuery1RECNO: TIntegerField;
    BrQuery1D1,BrQuery1D2,BrQuery1ZN: TField;
    lsm: TMemGkList;
    procedure BrQuery1AfterOpen(DataSet: TDataSet);
    procedure BrQuery1AfterClose(DataSet: TDataSet);
    procedure BrQuery1CalcFields(DataSet: TDataSet);
    procedure SetRightBound(const ARect: TRect);
    procedure Modify(Sender: TObject); overload;
    procedure Modify(db: TRecDB; var tr,ii: longint); overload;
    procedure DDatNewRec(Sender: TRecDB; lcopy: boolean; const gKey: string);
    class procedure DDatLsExec(Sender: TObject);
    class function CanDel(Sender: TObject): boolean;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    BrQuery1CD1,BrQuery1CD2: TStringField;
    BrQuery1CZN: TField;
    class function DWVidRec(tf: TFldEdit; var r: TDWVidRec): boolean;
  end;

var
  nDDatLs: longint = -1;
  DDatCanEdit: TProcValid;

implementation

{$R *.dfm}

uses SysUtils,StrUtils,Math,FIBDataSet,
  MulQry;

const sDDatLs = 'DDatLs';

var aDDatLs: array of TDDatLs;

{ TDDatLs }
procedure TDDatLs.FormCreate(Sender: TObject);
begin
  AddStack('TDDatLs.FormCreate',Self);
  inherited;
  with BrQuery1 do begin
    Connection:=DBMain; GlobKey:='1'; Arg['kv']:='1'; Arg['cod']:=QQs;
    BrQuery1RECNO:=Init(DBMain,[fDDD1],[],tDDAT,[],
      ArrayAsList([tDDAT+'.'+fDDCod+'={cod}',tDDAT+'.'+fDDVid+'='+qGlobKey,tDDAT+'.'+fDDKv+'='+QQs('{kv}')],sAND),
      '',BrQuery1CalcFields);
    BrQuery1CD1:=CreateStringField('CD1','Начало периода',10,taCenter);
    BrQuery1CD2:=CreateStringField('CD2','Конец периода',10,taCenter);
    BrQuery1D1:=CreateField(fDDD1);
    BrQuery1D2:=CreateField('D2');
    AfterOpen:=BrQuery1AfterOpen; AfterClose:=BrQuery1AfterClose;
  end;
  de.ReplaceNameRec('DDat',DDat);
  Rec.NameRec:=StrNum(sDDatLs,nDDatLs);
  de.ReplaceNameRec(sDDatLs,Rec);
  DDatLsProc(Self,ddoCreate);
  DelStack;
end;

class procedure TDDatLs.DDatLsExec;
const aDtEd: TDDatStr = ('',cDtMY,cDtMY,cDtYYYY);
var tf: TFldEdit;
  i,l: longint;
  FldInfo,oi: TDWFldInfo;
  fl: boolean;
  p: TPoint;
  r: TRect;
  a: TDEPrmStr;
begin
  AddStack('TDDatLs.DDatLsExec');
  Inc(nDDatLs);
  if nDDatLs=Length(aDDatLs) then SetLength(aDDatLs,nDDatLs+1);
  CreateForm(TDDatLs,aDDatLs[nDDatLs]); tf:=pointer(Sender); tf.IsDynamic(i);
  with aDDatLs[nDDatLs] do if aDDat[i].GetKvInfo(tf.NameRecFld,inf) then begin
    DDatLsProc(aDDatLs[nDDatLs],ddoBeforeShow);
    FreeAndNil(BrQuery1ZN); BrQuery1ZN:=BrQuery1.CreateField(aDDatZnFld[inf.tzn]);
    BrQuery1CD1.Visible := inf.td2<>dd2All; BrQuery1CD2.Visible := inf.td2 in sDDatD2;
    de.Param[fDDD1,deNoVisible]:=bStr[not BrQuery1CD1.Visible];
    de.Param['D2',deNoVisible]:=bStr[not BrQuery1CD2.Visible];
    de.Param['D',deNoVisible]:=bStr[not(BrQuery1CD1.Visible and BrQuery1CD2.Visible)];
    if BrQuery1CD2.Visible then begin
      BrQuery1CD1.DisplayLabel:='Начало периода';
      de.Param[fDDD1,deCaption]:='начало'; de.Param[fDDD1,deRelation]:=Rec.NameRec+'.D';
    end
    else begin
      BrQuery1CD1.DisplayLabel:=aDDatType[inf.tp].lbl;
      de.Param[fDDD1,deCaption]:=BrQuery1CD1.DisplayLabel; de.Param[fDDD1,deRelation]:='';
    end;
    de.Param[fDDZN,deCaption]:=tf.SayCaption;
    FldInfo.DisplayLabel:=Trim(tf.SayCaption); FldInfo.Size:=inf.Len; FldInfo.r.Dec:=inf.Dec;
    case inf.ft of
      ftInteger,ftFloat: FldInfo.Alignment:=taRightJustify;
      ftDate: FldInfo.Alignment:=taCenter;
    else FldInfo.Alignment:=taLeftJustify;
    end;
    FldInfo.FieldClass:=IfThen(inf.ft=ftBoolean,TBooleanField,
      IfThen(BrQuery1.DataSet is TIBQuery,TFIBStringField,TStringField));
    oi:=FldInfo; tf.curget.DWFldInfo(tf.Mask,FldInfo);
    if not Assigned(FldInfo.FieldClass) then FldInfo:=oi;
    with BrQuery1 do begin
      GlobKey:=Vtos(i); dd:=aDDat[i]; Arg['kv']:=tf.NameRecFld; Arg['cod']:=QQs(aDDat[i].CurCod);
      BrQuery1CD1.DisplayWidth:=Length(aDDatType[inf.tp].ms);
      BrQuery1CD2.DisplayWidth:=BrQuery1CD1.DisplayWidth;
      if Assigned(BrQuery1CZN) then fl := BrQuery1CZN.ClassType<>FldInfo.FieldClass else fl:=true;
      if fl then begin
        BrQuery1CZN.Free;
        BrQuery1CZN:=FldInfo.FieldClass.Create(BrQuery1);
        BrQuery1CZN.FieldName:='CZN'; BrQuery1CZN.Calculated:=true;
        BrQuery1CZN.DataSet:=BrQuery1.DataSet;
        BrQuery1CZN.Index:=BrQuery1CD2.Index+1;
      end;
      if BrQuery1CZN is TStringField then BrQuery1CZN.Size:=ReplVar(FldInfo.Size,30);
      BrQuery1CZN.DisplayLabel:='Значение'; BrQuery1CZN.Alignment:=FldInfo.Alignment;
      BrQuery1CZN.Visible := not inf.ValueEqTrue; de.Param[fDDZN,deNoVisible]:=bStr[inf.ValueEqTrue];
    end;
    Caption:=DelTrim(StrTran(FldInfo.DisplayLabel,UnDelim,' ')); tfCur:=tf;
    p:=tf.ClientOrigin; Inc(p.X,tf.DynCaptSize(tf.Height-BevelFld2).cX); r:=SysWorkArea; l:=r.Left;
    DDatLsProc(aDDatLs[nDDatLs],ddoShow);
    BrQuery1.Open; BrQuery1.Last;
    Browl1.DoEnter;
    BoundsRect:=r;
    if Height-p.Y-tf.Height<p.Y then r.Bottom:=p.Y+BevelFld else r.Top:=p.Y+tf.Height-BevelFld;
    r.Left:=max(l,p.X+BevelFld-Browl1.ColWidths[0]-IfThen(BrQuery1CD2.Visible,Browl1.ColWidths[1]+2)
      -4-RbPanel2.BevPanel);
    case KeyLb1.GetPlace of
      rpTop,rpBottom: begin
        i:=KeyLb1.WMin+KeyLb1.BevPanel2-(Browl1.GridsWidth+SysMetric.iScrollWidth+RbPanel2.BevPanel2);
        if i>0 then Dec(r.Left,i shr 1);
      end;
      rpLeft: r.Left:=max(l,r.Left-KeyLb1.Width);
    end;
    SetRightBound(r);
    de.Param[fDDD1,deMask]:=aDtEd[inf.tp];
    de.Param['D2',deMask]:=aDtEd[inf.tp]+cDtEnd;
    Rec.CreateFld(fDDZN,inf.ft,inf.Len,inf.valdef);
    de.GetArrParam(fDDZN,i,a);
    a[deVid]:=tfCur.Vid;
    a[deVName]:=tfCur.VName;
    a[deMask]:=tfCur.Mask;
    a[deMaxLen]:=IntToStr(tfCur.MaxLength);
    a[deCharCase]:=IntToStr(1+byte(tfCur.CharCase));
    a[deAutoSel]:=bStr[ogAutoSelect in tfCur.Options];
    a[dePassword]:=bStr[ogPassword in tfCur.Options];
    a[deSayHint]:=tfCur.SayCaption;
    a[deGetHint]:=tfCur.Hint;
    a[deWidth]:=IntToStr(tfCur.CharWidth);
    a[deHeight]:=IntToStr(tfCur.CharHeight);
    a[deTrimLeft]:=bStr[ogTrimLeft in tfCur.Options];
    de.SetArrParam(i,a);
    oNewRec:=DDat.OnNewRec; DDat.OnNewRec:=DDatNewRec;
    try
      if inf.td2=dd2All then KeyLb1.ExecKey(IfThen(BrQuery1.IsRecords,K_F5,K_F7)) else ShowModal;
    finally
      DDat.OnNewRec:=oNewRec;
    end;
    DDatLsProc(aDDatLs[nDDatLs],ddoHide);
  end;
  FormFree(aDDatLs[nDDatLs]); Dec(nDDatLs);
  DelStack;
end;

procedure TDDatLs.SetRightBound;
var r: TRect;
begin
  AddStack('TDDatLs.SetRightBound',Self);
  r:=ARect; r.Right:=Browl1.GridsWidth+SysMetric.iScrollWidth+RbPanel2.BevPanel2;
  if KeyLb1.GetPlace in [rpTop,rpBottom]
  then MaxSelf(r.Right,KeyLb1.WMin+KeyLb1.BevPanel2)
  else Inc(r.Right,KeyLb1.Width);
  r.Right:=min(SysWorkArea.Right,r.Left+max(MinWidthForm(Self),r.Right+Width-ClientWidth-2));
  BoundsRect:=r;
  DelStack;
end;

procedure TDDatLs.WMFormLimit;
var i,j: longint;
begin
	AddStack('TDDatLs.WMFormLimit',Self);
  inherited;
  for i:=low(aDDatLs) to high(aDDatLs) do if FreeLimit(aDDatLs[i]) then begin
    for j:=i+1 to high(aDDatLs) do aDDatLs[j-1]:=aDDatLs[j];
    aDDatLs[high(aDDatLs)]:=nil; break;
  end;
  DelStack;
end;

procedure TDDatLs.BrQuery1AfterOpen;
var oCalcFields: TDataSetNotifyEvent;
begin
  AddStack('TDDatLs.BrQuery1AfterOpen',Self);
  if not Assigned(lsm) then with BrQuery1 do begin
    oCalcFields:=OnCalcFields; OnCalcFields:=nil; lsm:=TDynamicDat.MemCreate(BrQuery1);
    OnCalcFields:=oCalcFields; First;
  end;
  DelStack;
end;

procedure TDDatLs.BrQuery1AfterClose;
begin
  AddStack('TDDatLs.BrQuery1AfterClose',Self);
  lsm:=nil;
  DelStack;
end;

procedure TDDatLs.BrQuery1CalcFields;
var v: variant;
begin
  AddStack('TDDatLs.BrQuery1CalcFields',Self);
  BrQuery1CD1.AsString:=TDynamicDat.StrDate(BrQuery1D1.AsDateTime,inf);
  BrQuery1CD2.AsString:=TDynamicDat.StrDate(BrQuery1D2.AsDateTime,inf,[ddstrD2]);
  if Assigned(lsm) then begin
    v:=DDStr2Var(BrQuery1ZN,lsm,inf);
    tfCur.curget.DWFldValue(tfCur.PNameRec,tfCur.Mask,v); BrQuery1CZN.AsVariant:=v;
  end;
  DelStack;
end;

procedure TDDatLs.Browl1BrowlKey(key: longint; tw: TWinControl);
var lCopy: boolean;
begin
  AddStack('TDDatLs.Browl1BrowlKey',Self);
  if BrQuery1.CanEdit(Key) then if dd.BeforeModify(tfCur.NameRecFld) then try
    case Key of
      K_F4,K_F7: begin
        lCopy := Key=K_F4;
        if lCopy
        then Rec[fDDZN]:=DDStr2Var(BrQuery1ZN,lsm,inf)
        else Rec[fDDZN]:=dd.GetValDef(tfCur.NameRecFld,inf);
        Browl1.AppRec('Добавление',DDat,de,IfThen(lCopy,brappCopy),'','',Modify);
      end;
    else
      if IfThenValid(DDatCanEdit,BrQuery1) then case Key of
        K_F5,K_Enter: begin
          Rec[fDDZN]:=DDStr2Var(BrQuery1ZN,lsm,inf);
          Browl1.EditRec('Редактирование',DDat,de,'',Modify);
        end;
        K_F8: Browl1.DelAsk(DDat,CanDel,'',Modify);
      end;
    end;
  finally
    dd.AfterModify(tfCur.NameRecFld);
  end;
  inherited;
  DelStack;
end;

procedure TDDatLs.Modify(Sender: TObject);
begin
  AddStack('TDDatLs.Modify',Self);
  DoDDatSetValProc(dsvUpdate); dd.Modify(tfCur.NameRecFld); tfCur.Read; tfCur.Invalidate;
  DelStack;
end;

procedure TDDatLs.Modify(db: TRecDB; var tr,ii: longint);
begin
  Modify(nil);
end;

class function TDDatLs.CanDel;
begin
  AddStack('TDDatLs.CanDel');
  result:=DoDDatSetValProc(dsvCanCng);
  DelStack;
end;

procedure TDDatLs.deFrmShow(Sender: TObject);
begin
  AddStack('TDDatLs.deFrmShow',Self);
  Rec[fDDD1]:=ReplDateSmallEmpty(DDat[fDDD1]);
  if DDat.RecNo>0 then DoDDatSetValProc(dsvCanCng);
  DelStack;
end;

procedure TDDatLs.deFldExit(Sender: TObject);
var tf: TFldEdit;
begin
  AddStack('TDDatLs.deFldExit',Self);
  if inf.tp=ddtQuart then begin
    tf:=pointer(Sender);
    if tf.NameRecFld=fDDD1 then tf.VarValue:=boq(tf.VarValue)
    else if tf.NameRecFld='D2' then tf.VarValue:=eoq(tf.VarValue);
  end;
  DelStack;
end;

function TDDatLs.deFldCheck(Sender: TObject): Boolean;
begin
  AddStack('TDDatLs.deFldCheck',Self);
  with TFldEdit(Sender) do
    if NameRecFld=fDDD1 then begin
      DDat[fDDD1]:=max(DateSmall,ReplDateEmptySmall(VarValue));
      result:=DDat.KodCheck(fDDD1,dd.GetWhere(BrQuery1.Arg['kv']));
    end
    else F1GreatOrEqF2(Sender,'D2',fDDD1,result);
  DelStack;
end;

function TDDatLs.dePnlValid(Sender: TObject): Boolean;
begin
  AddStack('TDDatLs.dePnlValid',Self);
  result:=true; 
  DDat['D2']:=DDGetD2(DDat[fDDD1],DDat['D2'],inf);
  if not inf.ValueEqTrue then DDat[aDDatZnFld[inf.tzn]]:=DDVar2Str(Rec[fDDZN],inf);
  LogFields.AddRecFld(DDat,[fDDD1,'D2',aDDatZnFld[inf.tzn]]);
  DDat.UpdateRec(true);
  DelStack;
end;

procedure TDDatLs.DDatNewRec;
begin
  AddStack('TDDatLs.DDatNewRec',Self);
  Sender.DoNewRec(oNewRec,lcopy,gKey);
  if not lcopy then begin
    Sender[fDDVid]:=Int0(BrQuery1.GlobKey); Sender[fDDKv]:=BrQuery1.Arg['kv']; Sender[fDDCod]:=dd.CurCod;
    if inf.ValueEqTrue then Sender[fDDZN]:=bTrue;
    if inf.td2=dd2All then DDat[fDDD1]:=DateSmall;
  end;
  DelStack;
end;

procedure TDDatLs.Browl1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: longint; Column: TColumn; State: TGridDrawState);
begin
  AddStack('TDDatLs.Browl1DrawColumnCell',Self);
  inherited;
  Browl1.bmCheckPaint(Rect,Column);
  DelStack;
end;

class function TDDatLs.DWVidRec;
var cr: TCustomRec;
  rdb: TRecDBDef;
  i,v: longint;
  s: string;
  lDyn: boolean;
begin
  AddStack('TDDatLs.DWVidRec');
  result:=false; lDyn:=tf.IsDynamic(v);
  if lDyn or AnsiStartsStr(sDDatLs,tf.NameRec) then begin
    if not lDyn then begin
      i:=Int0(Copy(tf.NameRec,Length(sDDatLs)+1,MaxInt));
      v:=Int0(aDDatLs[i].BrQuery1.GlobKey); tf:=aDDatLs[i].tfCur;
    end;
    if RdbDDVidSeek(v,rdb) then cr:=rdb else cr:=nil;
  end
  else cr:=RecName(tf.NameRec);
  if IsClass(cr,TRecDBDef,pointer(rdb)) then begin
    s:=TrimUpper(tf.NameRecFld);
    for i:=0 to rdb.FldDef.Count-1 do begin
      r:=rdb.DWSToRec(i);
      if TrimUpper(r.Name)=s then begin
        result:=true; break;
      end;
    end;
  end;
  DelStack;
end;

initialization
  AddStack('FDDatLs.initialization');
  DDatLsExec:=TDDatLs.DDatLsExec;
  DelStack;
end.
