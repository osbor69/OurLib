unit SpGet;

interface

{$I LIBTEST}
uses
  Windows,Messages,Classes,Controls,
  MyTypes,My_pr,MemoGet,RecVal,PaintCtl,FFldEdit,CCodeGet,FrmEmpty,StrBrowl,DefEdit;

type
	TSpGet = class(TCustomListGet)
  private
   	{ Private declarations }
    FConnection: TComponent;
    FCountCol,FCountRow: longword;
    lAppSeek: boolean;
    procedure PrClick(Sender: TObject);
    procedure ProcKey(key: longint; tw: TWinControl);
		function GKListOwner(Sender: TObject; SpdBut: TPaintButton;
  		const RectList: TRect; PozList: TPozList): boolean;
 	protected
   	{ Protected declarations }
   	tm: TFldMemo;
    sW,sA: TPaintButton;
    GlobKey: string;
    procedure CreateObj(tf: TFldEdit); override;
    procedure ReCreateObj(tf: TFldEdit); override;
    procedure PaintObj(tf: TFldEdit); override;
		procedure Paint(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    function GetValue(tf: TFldEdit): string; override;
    procedure SetValue(tf: TFldEdit; const v: string); override;
    function Check(tf: TFldEdit): boolean; override;
    procedure DoEnter(tf: TFldEdit); override;
    procedure DoExit(tf: TFldEdit); override;
    procedure Write(tf: TFldEdit); override;
    function MayDoKey(tf: TFldEdit; Key: longint): boolean; override;
    function AssignObj(tf: TFldEdit): boolean; override;
    procedure StdListDown(tf: TFldEdit; const RectList: TRect;
	    PozList: TPozList); override;
		function DWFldUnAllowType(const Mask: string): TDWFldSetType; override;
    procedure MaskFrmShow(Sender: TObject); override;
    class procedure MaskEdChange(Sender: TObject; const OldVal: variant; FromShow: boolean); override;
    class function MaskEdCheck(Sender: TObject): boolean; override;
    class function MaskPnlValid(Sender: TObject): boolean; override;
  	class function MaskSortMode: TSortMode; override;
    class procedure FMaskView(var Mask: string); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
		procedure GetPaintCtlActive(Sender: TObject; tf: TFldEdit; var result: boolean); override;
  public
   	{ Public declarations }
		procedure StdDWFldInfo(const Mask: string; var FldInfo: TDWFldInfo); override;
		procedure StdDWFldValue(r: TCustomRec; const Mask: string; var Value: variant); override;
		procedure DWFldValid(const ap: TDEPrmStr; const dwInf: TDWVidRec;
    	var nFldFocus: TDEPrmList; var nVarFocus: TVarParam; var amsg: TArrStr); override;
		class function MaskTextReadOnly: boolean; override;
		function SelProcKey(tf: TFldEdit; Proc: TSelProcKey): boolean; override;
  published
   	{ Published declarations }
    property Connection: TComponent read FConnection write FConnection;
    property CountCol: longword read FCountCol write FCountCol;
    property CountRow: longword read FCountRow write FCountRow;
   	{ Унаследованные }
   	property RVid;
   	property RVName;
   	property VName;
		function MaskTrans(const av: variant; r: TCustomRec; const nmf: string): variant; override;
  end;

  TSpGkStrList = class(TStringListCase)
  private
    aStr: array of TSpGkStr;
    function PStr(i: longint): PSpGkStr;
  public
    constructor Create;
    function AddKey(const Key: string): PSpGkStr;
  end;

  TSpGkDefProc = procedure(lsDef: TSpGkStrList);

  TSpGkLs = class(TFormEmp)
    procedure FormCreate(Sender: TObject);
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
  private
    { Private declarations }
    sb: TStringBrowl;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    class procedure GetPrm(const tbl,nmf: string; var g: TCustomGet; var Mask: string); overload;
    class procedure GetPrm(tf: TFldEdit); overload;
    class procedure GetPrm(de: TDefEdit; const tbl,nmf: string); overload;
    class procedure GetPrm(de: TDefEdit; const tbl,nmf: string; const anmf: array of string); overload;
    class procedure GetPrm(var a: TDEPrmVar); overload;
    class procedure GetPrm(var a: TDEPrmVar; const NameRec,NameRecFld: string); overload;
    class function GetPrm(const key: string): string; overload;
    class function CanList: boolean;
    class function Seek(const Key: string; var Row: longint): boolean;
  end;

var SpGkLs: TSpGkLs;
  WndDefProc: procedure(pa: PArrWndDef; var result: boolean);
	WndPrimProc: procedure(var Prim: string);

procedure Register;

procedure AddFrom(const a: array of TSpGkTblDef); overload;
procedure AddFrom(Proc: TSpGkDefProc); overload;

implementation

uses
  SysUtils,Forms,DB,Variants,StrUtils,Math,Grids,
  KeyLb,KeyMenu,PnlEdit,MulQry,FSpList,ComboGet,FrmPswd,RecDB,FEdText,Schem;

type
  TNone = class
  private
		class procedure SpdbCalculate(Sender: TCustomRec; lApp: boolean);
		class procedure SpdbNewRec(Sender: TRecDB; lcopy: Boolean; const gKey: String);
  end;

var FSpDb: TRecDB;

const dlmZpt = '^';

function GetSpLogPrm(logk: longint; const Mask: string): TSpGkLog;
begin
  AddStack('SpGet.GetSpLogPrm');
  SetLogVid(logk); result.Keys:=ProgPswd.PLogKeysLen; result.PrimDop:=LogPrimBeg;
  LogPrimBeg:=DlmCopy(Mask,5,1);
  DelStack;
end;

procedure SetSpLogPrm(const Value: TSpGkLog);
begin
  AddStack('SpGet.SetSpLogPrm');
  ProgPswd.PLogKeys:=Value.Keys; LogPrimBeg:=Value.PrimDop; SetLogVid;
  DelStack;
end;

procedure SpGk(rSpdb: TRecDB);
const ac: array[1..2] of TSpGkTblDef =
  ((tbl:tMSGS;nmf:'MSG')
  ,(tbl:tNOTE;nmf:'ZGL')
  );
var a: TArrSpGkTblDef;
  i,j,l: byte;
begin
  AddStack('SpGet.SpGk');
  SetLength(a,Length(ac)); j:=0; l:=Length(rSpdb[fSpGK]);
  for i:=low(ac) to high(ac) do if IsTable(ac[i].tbl) then begin
    a[j]:=ac[i]; a[j].key:=PadL(IntToStr(i),l,'_'); Inc(j);
  end;
  SetLength(a,j); AddFrom(a);
  DelStack;
end;

function SpDb: TRecDB;
var p: PPswdPrm;
begin
  AddStack('SpGet.SpDb');
  if TRecDB.Init(FSpDb,result,tSPDB,'',TNone.SpdbCalculate,TNone.SpdbNewRec) then
    if IsPswdPrm(p) then if Assigned(p.DBMain) then SpGk(result);
  DelStack;
end;

{ TSpGet }
procedure TSpGet.CreateObj;
begin
	AddStack('TSpGet.CreateObj',Self);
  inherited CreateObj(tf);
  if inherited AssignObj(tf) then begin
    tm:=TFldMemo.CreateParent(tf,tf);
    if not Assigned(bDyn) then begin
      sW:=TPaintButton.Create(tf);
      with sW do begin
        Canvas:=tf.Canvas; AllowAllUp:=true; Hint:='Редактировать в отдельном окне'; ShowHint:=true;
        BMByName(Glyph,bmEval); onClick:=PrClick;
      end;
      sA:=TPaintButton.Create(tf);
      with sA do begin
        Canvas:=tf.Canvas; AllowAllUp:=true; Hint:='Добавить'; ShowHint:=true;
        BMByName(Glyph,bmPlus); onClick:=PrClick;
      end;
    end;
    tf.ReCreateObj;
  end;
  DelStack;
end;

procedure TSpGet.ReCreateObj;
var fl: boolean;
begin
	AddStack('TSpGet.ReCreateObj',Self);
	if AssignObj(tf) then begin
    tm.PropFromFld(tf,bDyn); fl:=tm.NoLimSize; tm.WordWrapBool:=fl;
    if fl then tm.OnMaxLength:=FldMaxLength(tf) else tm.OnMaxLength:=nil;
    if Assigned(sW) then sW.Visible:=fl;
    inherited ReCreateObj(tf);
  end;
  DelStack;
end;

{ Нарисовать объекты }
procedure TSpGet.PaintObj;
var w,wc,h,hc: longint;
begin
	AddStack('TSpGet.PaintObj',Self);
	if AssignObj(tf) then with tf do begin
    h:=Height-BevelFld2;
    if Assigned(bDyn) then begin
      w:=DynButSize.cX; bDyn.SetBounds(Width-BevelFld-w,BevelFld,w,h); w:=bDyn.Left;
    end
    else begin
      w:=SysMetric.iScrollWidth;
      if tm.NoLimSize then begin
        hc:=SysMetric.iScrollHeight;
        if max(hc,sW.Glyph.Height+4)+max(hc,sA.Glyph.Height+4)+max(hc,sD.Glyph.Height+4)>h then begin
          sD.SetBounds(Width-BevelFld-w,BevelFld,w,h);
          sA.SetBounds(sD.Left-w,BevelFld,w,h);
          sW.SetBounds(sA.Left-w,BevelFld,w,h);
        end
        else begin
          hc := h div 3;
          sW.SetBounds(Width-BevelFld-w,BevelFld,w,hc);
          sA.SetBounds(sW.Left,sW.Top+hc,w,hc);
          sD.SetBounds(sW.Left,sA.Top+hc,w,h-hc shl 1);
        end;
        w:=sW.Left;
      end
      else begin
        if tm.CountLine>1 then begin
          sA.SetBounds(Width-BevelFld-w,BevelFld,w,h div 2);
          sD.SetBounds(sA.Left,sA.Top+sA.Height,w,h-sA.Height);
        end
        else begin
          sD.SetBounds(Width-BevelFld-w,BevelFld,w,h); sA.SetBounds(sD.Left-w,BevelFld,w,h);
        end;
        w:=sA.Left;
      end;
    end;
    wc:=DynCaptSize(h).cX; tm.SetBounds(BevelFld+2+wc,BevelFld+2,w-BevelFld-4-wc,h-4);
  end;
  DelStack;
end;

procedure TSpGet.Paint;
begin
  AddStack('TSpGet.Paint',Self);
  if AssignObj(tf) then tf.FldMaskBorder(tm.Control);
  DelStack;
end;

{ Автоматическая установка размеров }
function TSpGet.SizeAuto;
var ts: TSchem;
  dsz,dcsz: TSize;
  h: longint;
begin
	AddStack('TSpGet.SizeAuto',Self);
	result := inherited SizeAuto(tf,Opt);
	if AssignObj(tf) then with tf do begin
    if not(csDesigning in ComponentState) then
      if SchemName(Schem,ts) then tm.Font.Assign(ts.Font1);
    Canvas.Font.Assign(tm.Font);
    if Opt<>[] then begin
      dsz:=DynButSize;
      h:=max(max(IfThen(tm.NoLimSize,tm.MinHeight,1),tm.CountLine)*CanvasMaxH(Canvas)+IfThen(tm.CountLine>1,6,4),dsz.cY);
      dcsz:=tf.DynCaptSize(h);
      if tfszHeight in Opt then result.cY:=max(h,dcsz.cY);
      if tfszWidth in Opt then begin
        result.cX:=CanvasMaxW(Canvas)*ReplVar(tm.CountChar,10)+10;
        if Assigned(bDyn) then Inc(result.cX,dsz.cX+dcsz.cX)
        else Inc(result.cX,IfThen(tm.CountLine>1,1,2)*SysMetric.iScrollWidth);
      end;
    end;
    Canvas.Font.Assign(Font);
  end;
  DelStack;
end;

{ Достать значение Value из объектов }
function TSpGet.GetValue;
begin
	AddStack('TSpGet.GetValue',Self);
	AssignObj(tf); result:=tm.GetText;
  DelStack;
end;

{ Установить свойства объектов в соответствии с Value }
procedure TSpGet.SetValue;
begin
	AddStack('TSpGet.SetValue',Self);
	if AssignObj(tf) then begin
    tm.SetText(v); tm.SelAll;
  end;
  DelStack;
end;

function TSpGet.Check;
begin
  AddStack('TSpGet.Check',Self);
  result:=inherited Check(tf);
  if result then if AssignObj(tf) then result:=tm.MaxLengthCheck;
  DelStack;
end;

{ Можно ли выполнить клавишу }
function TSpGet.MayDoKey;
begin
	AddStack('TSpGet.MayDoKey',Self);
	result := inherited MayDoKey(tf,Key);
  if result then
	  if AssignObj(tf) then result:=tm.MayDoKey(Key);
  DelStack;
end;

{ Поиск объектов }
function TSpGet.AssignObj;
var i: longint;
  a: array[1..6] of string;
  n: byte;
  p: pointer;
label lend;
begin
	AddStack('TSpGet.AssignObj',Self);
	tm:=nil; sW:=nil; sA:=nil; GlobKey:=VName; result:=false;
  if inherited AssignObj(tf) then begin
    n:=IfThen(Assigned(bDyn),1);
		if tf.ComponentCount<=n then goto lend;
    if not IsClass(tf.Components[n+1],TFldMemo,pointer(tm)) then goto lend;
    LsArrFill(tf.Mask,a,','); tm.CountLine:=Int0(a[1]); tm.CountChar:=Int0(a[2]); tm.MinHeight:=max(1,Int0(a[6]));
    if not empty(a[3]) then GlobKey:=a[3];
    if tm.CountLine=0 then tm.CountLine:=FCountRow;
   	//if tm.CountLine=0 then tm.CountLine:=1;
		if tm.CountChar=0 then tm.CountChar:=FCountCol;
    //if tm.CountChar=0 then tm.CountChar:=MaxByte;
    if Assigned(bDyn) then result:=true
    else with tf do for i:=n to ComponentCount-1 do
      if Components[i].Tag<>1 then if IsClass(Components[i],TPaintButton,p) then begin
        if Assigned(sW) then sA:=p else sW:=p;
        if Assigned(sW) and Assigned(sA) then begin
          result:=true; break;
        end;
      end;
    if result then goto lend;
  end;
  if not(csDesigning in ComponentState) then PadRSelf(GlobKey,Length(Spdb[fSpGK]));
lend:
	DelStack;
end;

{ Вызов выпадающего списка }
procedure TSpGet.StdListDown;
const wTxt=2; wPnl=8;
var l,h,w,wMax: longint;
	s1,s2: string;
  c1,c2: PChar;
  pr: TRect;
  oAct: TNotifyEvent;
  frm: TForm;
  a: TArrStr;
  f: TField;
  wAll: boolean;
begin
	AddStack('TSpGet.StdListDown',Self);
  if AssignObj(tf) then begin
    if IsLastForm(frm) then begin
      oAct:=frm.OnActivate; frm.OnActivate:=nil;
    end
    else oAct:=nil;
    wAll := tf.CharWidth<0;
    CreateForm(TSpList,SpList);
    with SpList do begin
      ParCtrl:=Panel1;
      with Qry do begin
        Close; Connection:=FirstDatabase(FConnection); Arg[SGLOBKEY]:=Self.GlobKey; Open;
      end;
      BoundsRect:=SysWorkArea; NoLimSize:=tm.NoLimSize; Canvas.Font.Assign(tm.Font);
      if NoLimSize then h:=CanvasMaxH(Canvas)*tm.MinHeight
      else begin
        deSp.Param[0,deMask]:=Format('%d,%d',[tm.CountLine,tm.CountChar]); h:=tm.Control.Height;
      end;
      wMax:=ClientWidth-IfThen(RbPanel1.Place in [rpLeft,rpRight],KeyLb1.Width)
        -RbPanel2.BevPanel2+RbPanel1.BevPanel2-wPnl shl 1-wTxt shl 1-SysMetric.iScrollWidth;
      if wAll then w:=wMax
      else if not NoLimSize and (tf.CharWidth>0) then w:=min(CanvasMaxW(Canvas)*tm.CountChar,wMax)
      else w:=tm.Control.Width+wTxt;
      DBText1.SetBounds(wTxt,wTxt,w,h+wTxt);
      Panel1.SetBounds(wPnl,wPnl,DBText1.Width,DBText1.Height);
      CtrlBrowl1.DoEnter;
      CtrlBrowl1.PanelWidth := Panel1.Width + wPnl shl 1;
      CtrlBrowl1.PanelHeight := Panel1.Height + wPnl shl 1;
      RbPanel2.WMin:=CtrlBrowl1.Width;
      RbPanel2.HMin:=CtrlBrowl1.PanelHeight;
      Panel1.Color:=tm.Color;
      DBText1.Font.Assign(tm.Font);
      if not wAll then ClientWidth:=IfThen(RbPanel1.Place in [rpLeft,rpRight],
        KeyLb1.Width+CtrlBrowl1.Width+RbPanel2.BevPanel2+RbPanel1.BevPanel2,
        max(CtrlBrowl1.Width+RbPanel2.BevPanel2,KeyLb1.WMin)+RbPanel1.BevPanel2);
      with RectList do SetBounds(IfThen(wAll,SpList.Left,Left),Top,max(Width,Right-Left),Bottom-Top);
      h:=CtrlBrowl1.Height+RbPanel2.BevPanel2+RbPanel1.BevPanel2;
      ClientHeight:=IfThen(RbPanel1.Place in [rpLeft,rpRight],max(h,KeyLb1.HMin),h+KeyLb1.Height);
      h := (Width-ClientWidth) div 2 + CtrlBrowl1.Left + Panel1.Left;
      if RbPanel1.Place=rpLeft then Inc(h,KeyLb1.Width);
      pr:=SysWorkArea;
      if Left-h+Width>pr.Right
      then h:=min(Left+Width-pr.Right,Left-pr.Left);
      SetBounds(IfThen(wAll,Left,max(pr.Left,Left-h)),IfThen(PozList=plUp,
        max(0,Top+RectList.Bottom-RectList.Top-Height),min(Top,pr.Bottom-Height)),
        min(Width,pr.Right-pr.Left),Height);
      s1:=RTrimUpper(IfThen(lAppSeek,ValSeek,tf.Value));
      c1:=StrAlloc(Length(s1)+1); StrPCopy(c1,s1);
      if empty(s1) then begin
        if TrimRight(SpDb.Value[fSpGK])=TrimRight(GlobKey)
        then CtrlBrowl1.BrUpdate(CtrlBrowl1.Row,SpDb.Recno);
      end
      else with Qry do begin
        f:=FindField(fUPNAME);
        while not Eof do begin
          s2:=RTrimUpper(f.AsString);
          c2:=StrAlloc(Length(s2)+1); StrPCopy(c2,s2);
          h:=StrComp(c1,c2); StrDispose(c2);
          if h<=0 then break;
          Next;
        end;
        if Eof then First;
      end;
      tfCur:=tf;
      if ShowModal=mrOk then
      	if AssignObj(tf) then begin
          l:=LsArrDynamic(Qry.FindField(fNAME).AsString,a,CRLF);
          if not NoLimSize then begin
            MinSelf(l,tm.CountLine);
            for h:=0 to l-1 do a[h]:=TrimRight(LeftStr(a[h],tm.CountChar));
          end;
          tf.Value:=TrimRight(ArrayAsList(a,CRLF,l));
          tm.SetSelection(Length(tm.Text)); tm.Control.Perform(WM_CHAR,Ord(' '),1);
        end;
      if not FormFree(SpList) then begin
        ParCtrl:=nil; tfCur:=nil;
      end;
    end;
    if Assigned(frm) then frm.OnActivate:=oAct;
  end;
  DelStack;
end;

{ Действия при получении фокуса }
procedure TSpGet.DoEnter;
var tl: TKeyLb;
  a: TArrInt;
begin
	AddStack('TSpGet.DoEnter',Self);
	inherited DoEnter(tf);
	if AssignObj(tf) then begin
    GetParentForm(tf).ActiveControl:=tm.Control; tm.HideSelection(false);
    if FormKeyLb(tf,tl) and not Assigned(bDyn) then begin
      tl.SetKeyFind(ProcKey,'spget',kmEdit);
      if tm.NoLimSize then begin
        CopyFromInt(a,K_Ctrl_F4);
        if ogReadOnly in tf.Options then AddFromInt(a,K_Space);
        tl.SetKeys(a,'В окне','Редактировать в отдельном окне',ProcKey,'spget',kmEdit);
      end;
      if not(ogReadOnly in tf.Options) then tl.SetKey(K_F7,'Добавить','',ProcKey,'spget',kmEdit);
      tl.ReDrw;
    end;
  end;
  DelStack;
end;

{ Действия при утере фокуса }
procedure TSpGet.DoExit;
var tl: TKeyLb;
begin
	AddStack('TSpGet.DoExit',Self);
  if FormKeyLb(tf,tl) then tl.DelKey(K_All,'spget');
	inherited DoExit(tf);
  if not(csDestroying in tf.ComponentState) then if AssignObj(tf) then tm.HideSelection(true);
  DelStack;
end;

procedure TSpGet.Write;
begin
  AddStack('TSpGet.Write',Self);
  if AssignObj(tf) then tm.TrimText;
  DelStack;
end;

{ Реакция на клавиши }
procedure TSpGet.ProcKey;
begin
	AddStack('TSpGet.ProcKey',Self);
	if AssignObjOwner(tw) then case Key of
    K_F7: sA.Click;
    K_Space,K_Ctrl_F4: sW.Click;
  else tm.ExecFind(Key);
  end;
  DelStack;
end;

procedure TSpGet.PrClick;
var tf: TFldEdit;
  ii: longint;
  fl: boolean;
  oLog: TSpGkLog;
  pb: TPaintButton;
  s: string;
begin
	AddStack('TSpGet.PrClick',Self);
	pb:=pointer(Sender); tf:=PointerOwner(pb);
	if not tf.Active then DoEnter(tf);
	if AssignObj(tf) then begin
    pb.Down:=true;
    if pb=sW then begin
      s:=tf.Value; tm.SaveIdent;
      if EdTextExec(IfThen(ogReadOnly in tf.Options,'Просмотр','Редактирование'),s,'',nil,
      IfThen(ogReadOnly in tf.Options,edtxtReadOnly)+[edtxtWordWrap],
      edtpText,0,0,'',0,nil,'',nil,nil,'',nil,nil,nil,FldMaxLength(tf)) then begin
        tf.VarValue:=s;
        if AssignObj(tf) then tm.ReadIdent;
      end;
    end
    else if pb=sA then if not(ogReadOnly in tf.Options) then begin
      oLog:=GetSpLogPrm(logvAppRec,tf.Mask);
      try
        ii:=SpDb.Recno; SpDb.NewRec([],GlobKey);
        CreateForm(TSpList,SpList);
        SpList.deSp.Param[0,deMask]:=Format('%d,%d',[tm.CountLine,tm.CountChar]);
        SpList.ParCtrl:=tm.Control;
        SpDb[fNAME]:=tf.Value; SpList.tfCur:=tf; SpList.NoLimSize:=tm.NoLimSize;
        fl:=SpList.Edit('Добавление'); SpList.tfCur:=nil; AssignObj(tf);
        if fl then begin
          sD.Down:=true; sA.Down:=false;
          TSpList.AddZn(GlobKey);
          lAppSeek:=true; ListOwner(tf); lAppSeek:=false;
          AssignObj(tf); sD.Down:=false;
        end
        else SpDb.GotoRec(ii);
        FormFree(SpList);
      finally
        SetSpLogPrm(oLog);
      end;
    end;
 		pb.Down:=false;
  end;
  DelStack;
end;

function TSpGet.MaskTrans;
var a: array[1..6] of string;
  function Spin1(n,l: byte; const s: string): variant;
  begin
  	AddStack('TSpGet.MaskTrans.Spin1',Self);
    result:=VarArrayOf([mpSpin,s,longint(max(l,Int0(a[n]))),l,999]);
    DelStack;
  end;
var va: TArrVar;
  l,c: longint;
begin
	AddStack('TSpGet.MaskTrans');
	if MyVarType(av)=varArray then begin
    if IsNilc(av[1],false) then begin
      l:=0; c:=0;
    end
    else begin
      l:=IsNilc(av[2],1); c:=IsNilc(av[3],3);
    end;
    result:=ArrayAsList([IntToStr(l),IntToStr(c),
      IsNilc(av[4],''),IntToStr(IsNilc(av[6],0)),StrTran(IsNilc(av[5],''),',',dlmZpt),IntToStr(IsNilc(av[7],0))],',')
  end
  else begin
  	LsArrFill(av,a,',');
    if TSpGkLs.CanList and Spdb.Active
    then CopyFromVArr(va,[mpCombo,'Ключ для поиска',a[3],'',StrNum(UnDelim,Length(Spdb[fSpGK]))])
    else CopyFromVArr(va,[mpEdit,'Ключ для поиска',a[3]]);
    result:=ArrVarToVar(
      [VarArrayOf([mpBool,'Размеры не ограничены',Int0(a[1])=0])
      ,Spin1(1,1,'Количество строк')
      ,Spin1(2,1,'Количество символов в строке')
      ,va
      ,VarArrayOf([mpEdit,'Примечание',StrTran(a[5],dlmZpt,','),wallNoSay])
      ,Spin1(4,0,'Длина поля для вывода в таблицу')
      ,Spin1(6,1,'Минимальное количество строк')
      ]);
  end;
  DelStack;
end;

procedure TSpGet.MaskFrmShow;
var g: TCustomGet;
begin
	AddStack('TSpGet.MaskFrmShow',Self);
  TFldEdit.SetReadOnly([EdMaskFld(2),EdMaskFld(3),EdMaskFld(7)],true,ogReadOnlyNoVsbl);
  g:=EdMaskFld(4).curget;
  if g is TComboGet then TComboGet(g).OnListOwner:=GKListOwner;
  DelStack;
end;

function TSpGet.GKListOwner;
var fl: boolean;
  tf: TFldEdit;
  pr: TRect;
  nl: longint;
begin
	AddStack('TSpGet.GKListOwner',Self);
  result:=true; tf:=pointer(Sender); fl:=TSpGkLs.Seek(TrimRight(tf.Value),nl);
  if Assigned(SpGkLs) then with SpGkLs do begin
    pr:=SysWorkArea;
    SetBounds(pr.Left,RectList.Top,pr.Right-pr.Left,RectList.Bottom-RectList.Top);
    if fl then sb.Row:=nl;
    if ShowModal=mrOk then begin
      tf.Value:=sb.Cells[0,sb.Row];
      if empty(GetEdMaskVal(5)) then SetEdMaskVal(5,sb.Cells[1,sb.Row]);
    end;
  end;
  DelStack;
end;

class function TSpGet.MaskTextReadOnly;
begin
	result:=true;
end;

class procedure TSpGet.MaskEdChange;
var lsz: boolean;
begin
  AddStack('TSpGet.MaskEdChange');
  lsz:=GetEdMaskVal(1);
  TFldEdit.SetReadOnly([EdMaskFld(2),EdMaskFld(3)],lsz); EdMaskFld(7).SetReadOnly(not lsz);
  DelStack;
end;

class function TSpGet.MaskEdCheck;
begin
  AddStack('TSpGet.MaskEdCheck');
  result := inherited MaskEdCheck(Sender);
  if Sender=EdMaskFld(4) then result:=not empty(GetEdMaskVal(4))
  else if Sender=EdMaskFld(5) then result:=not empty(GetEdMaskVal(5));
  DelStack;
end;

class function TSpGet.MaskPnlValid;
var tf: TFldEdit;
	l,l1: longint;
begin
	AddStack('TSpGet.MaskPnlValid');
  if (Spdb=nil) or GetEdMaskVal(1) then result:=true
  else begin
  	tf:=EdMaskFld(2); l:=TMemoGet.LenFull(tf.Value,EdMaskFld(3).Value);
    l1:=Length(Spdb[fNAME]); result := (l1=0) or (l<=l1);
    if not result then begin
    	mess_ok([Format('Требуемая длина данных (%d символов)',[l]),
    		Format('превышает допустимую (%d символов).',[l1])]);
      TPanelEdit(Sender).FldFocus:=tf;
    end;
  end;
  DelStack;
end;

class function TSpGet.MaskSortMode;
begin
	result:=smColumns;
end;

class procedure TSpGet.FMaskView;
var a: array[1..6] of string;
  l,c,lv: longint;
begin
  AddStack('TSpGet.FMaskView');
  LsArrFill(Mask,a,','); l:=Int0(a[1]); c:=Int0(a[2]); TrimSelf(a[3]); lv:=Int0(a[4]);
  a[5]:=Trim(StrTran(a[5],dlmZpt,','));
  Mask:=DlmBetween([IfThen(l>0,StrNum('строк:',Int0(a[1]))),IfThen(c>0,StrNum('символов в строке:',Int0(a[2]))),
    IfThen(a[3]<>'','ключ:'+a[3]),IfThen(not empty(a[5]),'Примечание: '+a[5]),
    IfThen(lv<>0,StrNum('длина в таблице:',lv)),IfThen(l=0,StrNum('мин.строк:',max(1,Int0(a[6]))))],',');
  DelStack;
end;

function DWSize(const Mask: string): longint;
var a: array[1..4] of string;
begin
  AddStack('SpGet.DWSize');
  LsArrFill(Mask,a,','); result:=Int0(a[4]);
  if result=0 then result:=Int0(a[2]);
  DelStack;
end;

procedure TSpGet.StdDWFldInfo;
begin
  AddStack('TSpGet.StdDWFldInfo',Self);
  FldInfo.Size:=DWSize(Mask);
  DelStack;
end;

procedure TSpGet.FMaskHelp;
const Dlm = '+","+;';
var n: byte;
begin
  AddStack('TSpGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+9);
  Inc(n); CopyFrom(ht.Dat[n],HelpStruct(['Строк','Символов','Ключ','Длина','Прим','МинСтр']));
  Inc(n); CopyFrom(ht.Dat[n],HelpNum('«Количество строк»')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpNum('«Количество символов в строке»')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpBoldStr('«Ключ для поиска»')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpNum('«Длина поля для вывода в таблицу»')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpStrTran('«Примечание»','","','"'+dlmZpt+'"')+Dlm);
  Inc(n); CopyFrom(ht.Dat[n],HelpNum('«Минимальное количество строк»'));
  Inc(n); CopyFrom(ht.Dat[n],'Если размеры не ограничены, '+HelpBoldStr('«Количество строк»')+' и '+HelpBoldStr('«Количество символов в строке»')+' равны '+HelpBoldStr('0')+'.');
  DelStack;
end;

procedure TSpGet.DWFldValid;
var l: longint;
	a: array[1..2] of string;
begin
	AddStack('TSpGet.DWFldValid',Self);
  inherited DWFldValid(ap,dwInf,nFldFocus,nVarFocus,amsg);
  if (Length(amsg)=0) and not IsDWFldMemo(dwInf.AType) then begin
  	LsArrFill(ap[deMask],a,','); l:=TMemoGet.LenFull(a[1],a[2]);
    if l>dwInf.Len then begin
    	AddFrom(amsg,[BracketInt('Длина поля для указанного количества строк и символов',l),
      	BracketInt('превышает длину данного',dwInf.Len)+'.']);
      nFldFocus:=deNameRecFld;
    end;
  end;
  DelStack;
end;

function TSpGet.DWFldUnAllowType;
begin
  result:=[low(aDWFld)..high(aDWFld)]-[dwtString,dwtMemo,dwtManyStr];
end;

procedure TSpGet.StdDWFldValue;
var l: longint;
begin
  AddStack('TSpGet.StdDWFldValue',Self);
  Value:=DelTrim(StrTran(Value,CRLF,' ')); l:=DWSize(Mask);
  if l>0 then PadrSelf(Value,l);
  DelStack;
end;

function TSpGet.SelProcKey;
begin
  AddStack('TSpGet.SelProcKey',Self);
  result:=inherited SelProcKey(tf,Proc);
  if AssignObj(tf) then result:=tm.SelProcKey(Proc);
  DelStack;
end;

procedure TSpGet.GetPaintCtlActive;
begin
  AddStack('TSpGet.GetPaintCtlActive',Self);
  if AssignObj(tf) then if Sender=sW then result:=true;
  DelStack;
end;

{ TNone }
class procedure TNone.SpdbCalculate;
begin
	AddStack('TNone.SpdbCalculate');
	with TRecDB(Sender) do Value[fUPNAME]:=AnsiUpperCase(Value[fNAME]);
  DelStack;
end;

class procedure TNone.SpdbNewRec;
begin
	AddStack('TNone.SpdbNewRec');
  if not lcopy then Sender[fSpGK]:=gKey;
  DelStack;
end;

var SpGkTblArr: TArrSpGkTblDef;
  SpGkDefArr: array of TSpGkDefProc;

{ TSpGkLs }
procedure TSpGkLs.FormCreate;
var inf: TStrBrInfZn;
begin
  AddStack('TSpGkLs.FormCreate',Self);
  Caption:='Ключ для поиска';
  Menu:=TKeyMenu.Create(Self);
  with KeyLb1 do NmProc.Text:=ArrayAsList(
    [GetKeySt(K_Enter,'Выбор','',kmFile)
    ,GetKeySt(K_Esc,'Отмена','',kmFile)
    ,GetKeySt([K_F10],K_Esc)
    ],CRLF);
  with RbPanel2 do begin
    Schem:='Browl';
    sb:=TStringBrowl.Create(Self);
    with sb do begin
      Parent:=RbPanel2; SelectedOnlyFocused:=false;
      Options:=[goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goRowSizing,goColSizing,goRowSelect];
      inf:=InfoCol[0];
      CopyFrom(inf.aName,'Ключ'); inf.Alignment:=taLeftJustify; InfoCol[0]:=inf;
      inf.aName[0]:='Примечание'; InfoCol[1]:=inf;
      inf.aName[0]:='Строк'; inf.Alignment:=taRightJustify; InfoCol[2]:=inf;
      inf.aName[0]:='Символов'; InfoCol[3]:=inf;
      inf.aName[0]:='Окно ввода'; inf.Alignment:=taLeftJustify; inf.LenData:=200; InfoCol[4]:=inf;
    end
  end;
  inherited;
  DelStack;
end;

procedure TSpGkLs.KeyLb1ProcKey(key: longint; tw: TWinControl);
begin
	AddStack('TSpGkLs.KeyLb1ProcKey',Self);
  case Key of
    K_F10: Key:=K_Esc;
    K_Enter: Key:=K_F10;
  end;
  inherited;
  DelStack;
end;

procedure TSpGkLs.WMFormLimit;
begin
	AddStack('TSpGkLs.WMFormLimit',Self);
  inherited;
  FreeLimit(SpGkLs);
  DelStack;
end;

function SpGkTblCols(i: longint): byte;
var fi: PMQFieldInfo;
begin
  AddStack('SpGet.SpGkTblCols');
  result:=0;
  with SpGkTblArr[i] do if rows>0 then if GetFieldInfo(tbl,nmf,fi) then result := (fi.Size+lCRLF) div rows - lCRLF;
  DelStack;
end;

class procedure TSpGkLs.GetPrm(const tbl,nmf: string; var g: TCustomGet; var Mask: string);
var i,j: longint;
  t,f: string;
begin
  AddStack('TSpGkLs.GetPrm');
  SpDb; j:=-1;
  if NameGet(g,TSpGet) then begin
    t:=TrimUpper(tbl); f:=TrimUpper(nmf);
    for i:=low(SpGkTblArr) to high(SpGkTblArr) do with SpGkTblArr[i] do if nmf=f then begin
      if j<0 then j:=i;
      if tbl=t then begin
        j:=i; break;
      end;
    end;
  end;
  if j<0 then begin
    g:=NameGet(TSimpleGet); Mask:='';
  end
  else with SpGkTblArr[j] do Mask:=Format('%d,%d,',[rows,SpGkTblCols(j)])+key+',,'
    +DlmBetween(FLow(GetPrim(tbl)),GetPrimFld(tbl,nmf),LogDlm)+StrNum(',',minrow);
  DelStack;
end;

class procedure TSpGkLs.GetPrm(tf: TFldEdit);
var g: TCustomGet;
  Mask: string;
begin
  GetPrm(TRecDB(tf.PNameRec).NameDB,tf.NameRecFld,g,Mask); tf.AssignGet(g); tf.Mask:=Mask;  
end;

class procedure TSpGkLs.GetPrm(de: TDefEdit; const tbl,nmf: string);
begin
  GetPrm(de,tbl,nmf,[nmf]);
end;

class procedure TSpGkLs.GetPrm(de: TDefEdit; const tbl,nmf: string; const anmf: array of string);
var g: TCustomGet;
  Mask: string;
  i,j: longint;
  a: TDEPrmStr;
begin
  GetPrm(tbl,nmf,g,Mask);
  for i:=low(anmf) to high(anmf) do if de.GetArrParam(anmf[i],j,a) then begin
    g.AssignGet(a); a[deMask]:=Mask; de.SetArrParam(j,a);
  end;
end;

class procedure TSpGkLs.GetPrm(var a: TDEPrmVar);
var g: TCustomGet;
  Mask: string;
begin
  GetPrm(TRecDB(RecName(a[deNameRec])).NameDB,a[deNameRecFld],g,Mask); g.AssignGet(a); a[deMask]:=Mask;
end;

class procedure TSpGkLs.GetPrm(var a: TDEPrmVar; const NameRec,NameRecFld: string);
begin
  a[deNameRec]:=NameRec; a[deNameRecFld]:=NameRecFld; GetPrm(a);
end;

class function TSpGkLs.GetPrm(const key: string): string;
var lsDef: TSpGkStrList;
  i: longint;
  p: PSpGkStr;
begin
  AddStack('TSpGkLs.GetPrm(Mask)');
  lsDef:=TSpGkStrList.Create;
  try
    i:=lsDef.IndexOf(key);
    if i<0 then result:=''
    else begin
      p:=lsDef.PStr(i); result:=p[spgkRows]+','+p[spgkCols]+','+lsDef[i]+',0,'+p[spgkPrim]+','+p[spgkMinRow];
    end;
  finally
    lsDef.Free;
  end;
  DelStack;
end;

class function TSpGkLs.CanList;
begin
  AddStack('TSpGkLs.CanList');
  result := (Length(SpGkTblArr)>0) or (Length(SpGkDefArr)>0) or Assigned(WndDefProc);
  DelStack;
end;

procedure AddFrom(const a: array of TSpGkTblDef);
var i,j: longint;
begin
  AddStack('SpGet.AddFrom(TSpGkTblDef)');
  j:=Length(SpGkTblArr); i:=Length(a); SetLength(SpGkTblArr,j+i);
  for i:=0 to i-1 do if a[i].tbl<>'' then begin
    SpGkTblArr[j]:=a[i];
    with SpGkTblArr[j] do begin
      if key='' then key:=nmf;
      if (rows=0) and (minrow=0) then rows:=1;
    end;
    Inc(j);
  end;
  SetLength(SpGkTblArr,j);
  DelStack;
end;

procedure AddFrom(Proc: TSpGkDefProc);
var i: longint;
begin
  AddStack('SpGet.AddFrom(TSpGkDefProc)');
  i:=Length(SpGkDefArr); SetLength(SpGkDefArr,i+1); SpGkDefArr[i]:=Proc;
  DelStack;
end;

class function TSpGkLs.Seek;
const acmw: array[0..4] of longint = (3,5,1,2,6);
var ad: TArrWndDef;
  i,j,l,ld: longint;
  k: byte;
  dw: TObject;
  a: TArrStr;
  lsDef: TSpGkStrList;
  ap: TDEPrmStr;
  v,s,prim: string;
	am: array[1..6] of string;
	inf: TStrBrInfZn;
  p: PSpGkStr;
  fl: boolean;
begin
  AddStack('TSpGkLs.Seek');
  result:=false; dw:=nil; lsDef:=nil;
  try
    if Assigned(SpGkLs) then with SpGkLs do begin
      for i:=sb.FixedRows to sb.RowCount-1 do
        if sb.Cells[0,i]=Key then begin
          Row:=i; result:=true; break;
        end;
    end
    else begin
      fl:=true;
      if Assigned(WndDefProc) then WndDefProc(@ad,fl) else ad:=nil;
      if fl then try
        CreateForm(TSpGkLs,SpGkLs);
        with SpGkLs do begin
          lsDef:=TSpGkStrList.Create;
          v:=TrimUpper(TSpGet.ClassName); dw:=DataWinCreate;
          p:=nil; // Variable might not have been initialized
          for i:=low(ad) to high(ad) do if Pos(v,AnsiUpperCase(ad[i].Def))>0 then
            for j:=0 to LsArrDynamic(DataWinFields(dw,ad[i].Def),a,CRLF)-1 do begin
              ap:=DEGetArrParam(a[j]);
              if TrimUpper(ap[deVid])=v then begin
                LsArrFill(ap[deMask],am,',');
                if not empty(am[1]) then begin
                  prim:=ad[i].Prim;
                  if Assigned(WndPrimProc) then WndPrimProc(prim);
                  StrTranSelf(am[5],dlmZpt,',');
                  for k:=low(acmw) to high(acmw) do begin
                    s:=TrimRight(am[acmw[k]]);
                    if k=0 then p:=lsDef.AddKey(s) else p[TSpGkList(k-1)]:=s;
                  end;
                  p[spgkWndName]:=prim;
                end;
              end;
            end;
          ad:=nil; lsDef.Sorted:=true; ld:=lsDef.Count; sb.AddSt(ld); Dec(ld);
          for k:=low(acmw) to high(acmw) do begin
            inf:=sb.InfoCol[k]; inf.LenData:=0;
            for i:=0 to ld do begin
              if k=0 then s:=lsDef[i] else s:=lsDef.PStr(i)[TSpGkList(k-1)];
              MaxSelf(inf.LenData,s);
            end;
            sb.InfoCol[k]:=inf;
          end;
          l:=sb.FixedRows;
          for i:=0 to ld do begin
            sb.Cells[0,l]:=lsDef[i]; p:=lsDef.PStr(i);
            for k:=1 to sb.ColCount-1 do sb.Cells[k,l]:=p[TSpGkList(k-1)];
            if not result and (lsDef[i]=Key) then begin
              result:=true; Row:=l;
            end;
            Inc(l);
          end;
        end;
      finally
        if Assigned(WndDefProc) then WndDefProc(nil,fl);
      end;
    end;
  finally
    if Assigned(dw) then DataWinFree;
    lsDef.Free;
  end;
  DelStack;
end;

{ TSpGkStrList }
constructor TSpGkStrList.Create;
var i: longint;
  p: PSpGkStr;
begin
  AddStack('TSpGkStrList.Create');
  Duplicates:=dupAccept; SetLength(aStr,10);
  for i:=low(SpGkTblArr) to high(SpGkTblArr) do with SpGkTblArr[i] do begin
    p:=AddKey(key);
    p[spgkPrim]:=GetPrimFld(tbl,nmf);
    p[spgkRows]:=IntToStr(rows);
    p[spgkCols]:=IntToStr(SpGkTblCols(i));
    p[spgkWndName]:=FLow(GetPrim(tbl,false))
  end;
  for i:=low(SpGkDefArr) to high(SpGkDefArr) do SpGkDefArr[i](Self);
  DelStack;
end;

function TSpGkStrList.AddKey;
var i: longint;
begin
  AddStack('TSpGkStrList.AddKey');
  i:=Count;
  if Length(aStr)=i then SetLength(aStr,i shl 1);
  AddObject(Key,pointer(i)); result:=@aStr[i]; InitArr(aStr[i]);
  DelStack;
end;

function TSpGkStrList.PStr;
begin
  AddStack('TSpGkStrList.PStr');
  result:=@aStr[IntObj(Self,i)];
  DelStack;
end;

procedure LogTrnsValProc(var Prm: TLogTrnsValPrm);
begin
  AddStack('SpGet.LogTrnsValProc');
  with Prm do if LogEqual(Prm,tSPDB,fSpGK) then begin
    lOut:=false; lBreak:=true;
  end;
  DelStack;
end;

procedure biSpCopy(var stack: array of variant; n1: longint; var lStd: boolean);
var ln: boolean;
  a: array[boolean] of record
    gk: string;
    q: TMulQuery;
    fqNAME: TField;
  end;
  nm: string;
begin
  AddStack('SpGet.biSpCopy');
  for ln:=false to true do with a[ln] do begin
    gk:=stack[n1]; Inc(n1);
    q:=ProgPswd.GetQuery; q.PartSelect(tSPDB,[],fSpGK+'='+QQs(gk),fNAME); fqNAME:=q.FindField(fNAME);
  end;
  with a[false],q do begin
    while not Eof do begin
      nm:=fqNAME.AsString;
      with a[true],q do begin
        while not Eof and (fqNAME.AsString<nm) do Next;
        if Eof or (fqNAME.AsString>nm) then with Spdb do begin
          GetFromQuery(a[false].q); NewRec([newrCopy]); Value[fSpGK]:=gk; AppRec;
        end;
      end;
      Next;
    end;
    if IsNilc(stack[n1],false) then Spdb.DelRec(fSpGK+'='+QQs(gk));
  end;
  for ln:=false to true do ProgPswd.FreeQuery;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TSpGet]);
end;

initialization
  AddStack('SpGet.initialization');
  FSpList.GetSpLogPrm:=GetSpLogPrm; FSpList.SetSpLogPrm:=SetSpLogPrm;
  RecDB.SpDb:=SpDb;
  aBuiltInProc[MyTypes.biSpCopy].Proc:=biSpCopy;
  LogTrnsValProcAdd(LogTrnsValProc);
  DelStack;
end.
