unit DlgStLs;

interface

uses Classes,Controls,ExtCtrls,DesignEditors,DesignIntf,Variants,StrUtils,
  PaintCtl,FFldEdit;

type
  TDlgStLsEditType = (teEdit,teMenu,teCombo,teSpin,teBool,teButTxt,teBut);
	TDlgStLsStatMode = (dsmShow,dsmAdd,dsmEdit,dsmDel,dsmMove);

	TDlgStLsProperty = class(TClassProperty)
  private
    aFld: TArrFldEdit;
    function GetNameLs(const s: string): string;
    function GetVal(Index: longint): string;
    procedure SetVal(Index: longint; const v: string);
  protected
  	HeadList,HeadEd: string;
    PrcEdit,PrcList,CurLine: longint;
    isStatus,OnlyEdit: boolean;
    vEd: variant;
    Ls: TStringList;
    Pb: TPaintBox;
    ProcPaint: TNotifyEvent;
    property Val[Index: longint]: string read GetVal write SetVal;
    function TransStr(const st: string; lGet: boolean): string; virtual;
		function TransArr(const st: string; Index: longint; lGet: boolean): string; virtual;
    procedure FormShow(Sender: TObject); virtual;
    procedure EdChange(Sender: TObject; const OldVal: variant; FromShow: boolean); virtual;
    procedure EdExit(Sender: TObject); virtual;
    function EdCheck(Sender: TObject): boolean; virtual;
    function Valid(Sender: TObject): boolean; virtual;
		function NameFromArr(const a: array of string): string; virtual;
		function DefValue(Index: longint): string; virtual;
    procedure BeforeRead(Index: longint); virtual;
  	function ListOwner(Sender: TObject): boolean; virtual;
    procedure RowMove(Sender: TObject; Index: longint); virtual;
		procedure ButTextGetClick(Sender: TObject); virtual; abstract;
  	function ButGetClick(Sender: TObject; lEval: boolean): string; virtual; abstract;
		procedure StatusChange(Sender: TObject; Mode: TDlgStLsStatMode); virtual;
		procedure PnEdEnter(Sender: TObject); virtual;
		function NextName(Index: longint; const sBeg: string): string;
		function NextCod(Index: longint): string;
		function FindEdit(Index: longint): TWinControl;
		function FindGet(Index: longint): TObject;
  public
   	function GetAttributes: TPropertyAttributes; override;
  	procedure Activate; override;
    procedure Edit; override;
  end;

implementation

uses
  Forms,StdCtrls,Spin,Graphics,PSort,SysUtils,Windows,
	MyTypes,My_pr,DB,Math,Askp,FPanel,KeyLb,PnlEdit,RecVal,
    KeyMenu,MenuGet,ComboGet,SpinGet,ChkGets,ButGet,BtTxtGet,ListF2,
    ButForms {initialization};

const
	sBeg = 'STLS_';

type
	TArrFld = array[1..30] of string;

  TDlgStLs = class(TForm)
  private
    { Private declarations }
    Dsgn: TDlgStLsProperty;
    om: longint;
    flMove: boolean;
    oText: string;
    RV: TRecVal;
    Pn1,Pn11,Pn111,Pn112,Pn1111,PnLs,PnPb,PnView: TRbPanel;
    PnEd: TPanelEdit;
    PnStat: TRbStatus;
    Kp: TKeyLb;
    LsBox: TListBox;
    View: StdCtrls.TMemo;
    LsText: TStrings;
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    class procedure PnLsResize(Sender: TObject);
		procedure LsBoxEnter(Sender: TObject);
		procedure LsBoxExit(Sender: TObject);
		procedure KpProcKey(Key: longint; tw: TWinControl);
    function PnEdValid(Sender: TObject): boolean;
    procedure LsBoxClick(Sender: TObject);
    procedure LsBoxKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LsBoxDblClick(Sender: TObject);
    procedure LsBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
    procedure LsBoxMouseMove(Sender: TObject; Shift: TShiftState; X,Y: longint);
    procedure LsBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: longint);
    procedure PnEdRead(lall: boolean);
		procedure Move(oi,ni: longint);
		procedure PrMove(oi,ni: longint; const av: array of variant);
    procedure LsFill;
  	function ListOwner(Sender: TObject; SpdBut: TPaintButton;
	  	const RectList: TRect; PozList: TPozList): boolean;
  end;

{ TDlgStLsProperty }
function TDlgStLsProperty.GetAttributes;
begin
	AddStack('TDlgStLsProperty.GetAttributes');
	result:=[paDialog,paReadOnly];
  DelStack;
end;

procedure TDlgStLsProperty.Activate;
begin
	AddStack('TDlgStLsProperty.Activate');
	inherited Activate;
	HeadList:='Переменные'; HeadEd:='Параметры'; vEd:=null;
  ProcPaint:=nil; aFld:=nil; Pb:=nil; PrcEdit:=50; PrcList:=30;
  DelStack;
end;

// Редактирование
procedure TDlgStLsProperty.Edit;
const
  aTp: array[TDlgStLsEditType] of record
    cl: TCustomGetClass;
    One: boolean;
  end =
  ((cl: TSimpleGet; One: true)
  ,(cl: TMenuGet)
  ,(cl: TComboGet)
  ,(cl: TSpinGet  ; One: true)
  ,(cl: TBoolGet  ; One: true)
  ,(cl: TButTextGet)
  ,(cl: TButGet)
  );
var s: string;
	Frm: TDlgStLs;
	i,j,l,p,ph: longint;
  v,vp: variant;
  tf: TFldEdit;
  tp: TDlgStLsEditType;
  ag: array[TDlgStLsEditType] of TCustomGet;
begin
	AddStack('TDlgStLsProperty.Edit');
  //clrmsgfile;
  //with ToolServices do for i:=0 to GetModuleCount-1 do addmsgfile(GetModuleName(i));
	if MyVarType(vEd)=varArray then begin
    Frm:=TDlgStLs.CreateNew(Application); Ls:=TStringList.Create; 
    if Assigned(ProcPaint) then Pb:=TPaintBox.Create(Frm);
    try
      with Frm do begin
        DefaultFont(Font); SetBounds(0,0,800,600); BorderStyle:=bsSizeToolWin;
        Caption:=TComponent(GetComponent(0)).Owner.Name+'.'
          +TComponent(GetComponent(0)).Name+'.'+GetName;
        Position:=poScreenCenter; OnClose:=FormClose; OnResize:=FormResize;
        Pn1:=TRbPanel.Create(Frm);
        with Pn1 do begin
          Parent:=Frm; ProcentWnd:=100; BevelOuter:=bvNone; Place:=rpLeft;
          Kp:=TKeyLb.Create(Frm);
          with Kp do begin
            Parent:=Pn1;
            SetKey(K_F10,'Сохранить','',KpProcKey,'main',kmFile);
            SetKey(K_Esc,'Отмена','',KpProcKey,'main',kmFile);
          end;
          Pn11:=TRbPanel.Create(Frm);
          with Pn11 do begin
            Parent:=Pn1; ProcentWnd:=100; BevelOuter:=bvNone; Place:=rpTop;
            Pn111:=TRbPanel.Create(Frm);
            with Pn111 do begin
              Parent:=Pn11; ProcentWnd:=PrcEdit; BevelOuter:=bvNone; Place:=rpLeft;
              Pn1111:=TRbPanel.Create(Frm);
              with Pn1111 do begin
                Parent:=Pn111; ProcentWnd:=IfThen(Assigned(ProcPaint),80,100);
                BevelOuter:=bvNone; Place:=rpLeft;
                PnLs:=TRbPanel.Create(Frm);
                with PnLs do begin
                  Parent:=Pn1111; Font.Style:=[fsBold]; ProcentWnd:=PrcList;
                  BevelOuter:=bvLowered; Header:=HeadList; OnResize:=PnLsResize;
                  LsBox:=TListBox.Create(Frm);
                  with LsBox do begin
                    Parent:=PnLs; Font.Style:=[];
                    OnEnter:=LsBoxEnter; OnExit:=LsBoxExit;
                    OnClick:=LsBoxClick; OnDblClick:=LsBoxDblClick;
                    OnKeyUp:=LsBoxKeyUp;
                    OnMouseDown:=LsBoxMouseDown;
                    OnMouseMove:=LsBoxMouseMove;
                    OnMouseUp:=LsBoxMouseUp;
                  end;
                end;
                PnEd:=TPanelEdit.Create(Frm);
                with PnEd do begin
                  Parent:=Pn1111; Font.Style:=[fsBold];
                  ProcentWnd:=100; BevelOuter:=bvLowered;
                  MasterControl:=LsBox; Options:=[peCheckOnExit];
                  Header:=HeadEd; OnEnter:=PnEdEnter; OnValid:=PnEdValid;
                end;
              end;
              if Assigned(ProcPaint) then begin
                PnPb:=TRbPanel.Create(Frm);
                with PnPb do begin
                  Parent:=Pn111; Font.Style:=[fsBold];
                  ProcentWnd:=100; BevelOuter:=bvLowered;
                  Header:='Просмотр'; OnResize:=PnLsResize;
                  with Pb do begin
                    Parent:=PnPb; onPaint:=ProcPaint;
                  end;
                end;
              end;
            end;
            Pn112:=TRbPanel.Create(Frm);
            with Pn112 do begin
              Parent:=Pn11; ProcentWnd:=100; BevelOuter:=bvNone; Place:=rpBottom;
              if IsStatus then begin
                PnStat:=TRbStatus.Create(Frm); PnStat.Parent:=Pn112;
              end;
              if OnlyEdit then LsText:=TStringList.Create
              else begin
                PnView:=TRbPanel.Create(Frm);
                with PnView do begin
                  Parent:=Pn112; ProcentWnd:=100;
                  Font.Style:=[fsBold]; BevelOuter:=bvLowered;
                  Header:='Текст'; onResize:=PnLsResize;
                  View:=StdCtrls.TMemo.Create(Frm);
                  with View do begin
                    Parent:=PnView; Font.Style:=[];
                    ReadOnly:=true;
                    HideSelection:=false; ScrollBars:=ssBoth;
                    LsText:=Lines;
                  end;
                end;
              end;
            end;
          end;
        end;
        l:=0; RV:=TRecVal.Create(Frm); ZeroMemory(@ag,SizeOf(ag)); SetLength(aFld,VarLength(vEd));
        for i:=VarArrayLowBound(vEd,1) to VarArrayHighBound(vEd,1) do begin
          s:=IntToStr(l+1); vp:=vEd[i]; p:=VarArrayLowBound(vp,1); ph:=VarArrayHighBound(vp,1);
          RV.CreateFld(s,ftMemo,0,''); tf:=TFldEdit.Create(Frm);
          with tf do begin
            Parent:=PnEd; Font.Style:=[]; NameRec:=RV.NameRec; NameRecFld:=s; tp:=vp[p];
            with aTp[tp] do if One then begin
              cl.CreateOne(ag[tp],Frm);
            end
            else begin
              ag[tp]:=cl.Create(Frm); ag[tp].VName:=sBeg+s;
            end;
            AssignGet(ag[tp]);
            case tp of
              teEdit: begin
                IncOptions([],[ogAutoSize]); Width:=300;
              end;
              teMenu: with TMenuGet(ag[tp]) do begin
                Ls.Clear;
                for j:=p+2 to ph do Ls.Add(IfThen(Pos(UnDelim,vp[j])=0,IntToStr(j-p-1)+UnDelim)+vp[j]);
                Items.Assign(Ls); OnListOwner:=ListOwner; OnRowMove:=RowMove;
              end;
              teCombo: with TComboGet(ag[tp]) do begin
                Mask:=''; Ls.Clear; Mask:=IfThen(vp[p+2],cOnlyList);
                for j:=p+3 to ph do Ls.Add(vp[j]);
                Items.Assign(Ls); OnListOwner:=ListOwner; OnRowMove:=RowMove;
                IncOptions([],[ogAutoSize]); Width:=300;
              end;
              teSpin: Mask:=Format('%d,%d',[longint(vp[p+2]),longint(vp[p+3])]);
              teBool: Mask:=vp[p+1];
              teButTxt: begin
                TButTextGet(ag[tp]).onClick:=ButTextGetClick;
                IncOptions([],[ogAutoSize]); Width:=300;
              end;
              teBut: TButGet(ag[tp]).onClick:=ButGetClick;
            end;
            SetBounds(0,l,Width,Height);
            OnExit:=EdExit; OnChange:=EdChange; OnCheck:=EdCheck;
            if tp<>teBool then if ph>p then tf.SayCaption:=vp[p+1];
          end;
          aFld[l]:=tf; Inc(l);
        end;
        Dsgn:=Self;
        LsText.Assign(TStrings(GetOrdValue));
        LsFill;
        MainRebuild(Frm);
        oText:=LsText.Text; flMove:=false;
        ActiveControl:=LsBox;
        LsBoxEnter(LsBox); StatusChange(PnStat,dsmShow); FormShow(Frm); Kp.ButShowing:=true;
        if ShowModal=mrOk then SetOrdValue(LongInt(LsText));
      end;
    finally
      Ls.Free; aFld:=nil;
      if Assigned(ProcPaint) then FreeAndNil(Pb);
      Frm.Free;
    end;
  end;
  DelStack;
end;

// Преобразование строки в формат TDlgStLs и обратно
function TDlgStLsProperty.TransStr;
begin
	AddStack('TDlgStLsProperty.TransStr');
	result:=RightStrDel(TrimRight(st),UnDelim);
  DelStack;
end;

function TDlgStLsProperty.TransArr;
begin
	result:=st;
end;

procedure TDlgStLsProperty.FormShow;
begin
end;

// Действия по изменению значения Edit
procedure TDlgStLsProperty.EdChange;
begin
end;

// Действия по выходу из Edit
procedure TDlgStLsProperty.EdExit;
begin
end;

// Проверка Edit
function TDlgStLsProperty.EdCheck;
begin
	result:=true;
end;

// Проверка всех Edit
function TDlgStLsProperty.Valid;
begin
	result:=true;
end;

// Наименование строки для LsBox
function TDlgStLsProperty.GetNameLs;
var a: TArrFld;
begin
	AddStack('TDlgStLsProperty.GetNameLs');
	ListAsArray(s,a,UnDelim); result:=NameFromArr(a);
  DelStack;
end;

function TDlgStLsProperty.NameFromArr;
begin
	AddStack('TDlgStLsProperty.NameFromArr');
	result:=a[low(a)];
  DelStack;
end;

// Значение по умолчанию по номеру
function TDlgStLsProperty.DefValue;
begin
	result:='';
end;

procedure TDlgStLsProperty.BeforeRead;
begin
end;

// Выпадающий список для teMenu и teCombo
function TDlgStLsProperty.ListOwner;
begin
	result:=false;
end;

// Перемещение по списку для teMenu и teCombo
procedure TDlgStLsProperty.RowMove;
begin
end;

// Следующее значение наименования с указанным началом
function TDlgStLsProperty.NextName;
var i,n: longint;
	a: TArrFld;
begin
	AddStack('TDlgStLsProperty.NextName');
  n:=0;
  for i:=0 to Ls.Count-1 do begin
  	LsArrFill(Ls[i],a,UnDelim);
    if AnsiStartsText(sBeg,a[Index])
    then MaxSelf(n,Int0(Copy(a[Index],Length(sBeg)+1,MaxInt)));
  end;
  result:=StrNum(sBeg,n+1);
  DelStack;
end;

// Следующее значение кода
function TDlgStLsProperty.NextCod;
var i,n: longint;
	a: TArrFld;
begin
	AddStack('TDlgStLsProperty.NextCod');
  n:=0;
  for i:=0 to Ls.Count-1 do begin
  	LsArrFill(Ls[i],a,UnDelim); MaxSelf(n,Int0(a[Index]));
  end;
  result:=IntToStr(n+1);
  DelStack;
end;

// Найти Edit по номеру
function TDlgStLsProperty.FindEdit;
begin
	AddStack('TDlgStLsProperty.FindEdit');
  if InRange(Index,1,Length(aFld)) then result:=aFld[Index-1] else result:=nil;
  DelStack;
end;

// Найти Get по номеру
function TDlgStLsProperty.FindGet;
var tw: TWinControl;
begin
	AddStack('TDlgStLsProperty.FindGet');
	tw:=FindEdit(Index);
  if Assigned(tw) then result:=NameGet(TFldEdit(tw)) else result:=nil;
  DelStack;
end;

// Значение Edit по номеру
function TDlgStLsProperty.GetVal;
begin
	AddStack('TDlgStLsProperty.GetVal');
	result:=TFldEdit(FindEdit(Index)).VarValue;
  DelStack;
end;

procedure TDlgStLsProperty.SetVal;
begin
	AddStack('TDlgStLsProperty.SetVal');
  TFldEdit(FindEdit(Index)).VarValue:=v;
  DelStack;
end;

procedure TDlgStLsProperty.StatusChange;
begin
end;

procedure TDlgStLsProperty.PnEdEnter;
begin
end;

{ TDlgStLs }
procedure TDlgStLs.FormResize;
begin
	AddStack('TDlgStLs.FormResize',Self);
	RbFormResize(Self);
  DelStack;
end;

// Размеры списка переменных
class procedure TDlgStLs.PnLsResize;
const iX=7; iY=5;
var h: longint;
begin
	AddStack('TDlgStLs.PnLsResize');
	with TRbPanel(Sender) do if ControlCount>0 then begin
    h:=HeaderHeight;
    Controls[0].SetBounds(iX, h+iY, Width - iX shl 1, Height - h - iY shl 1);
  end;
  DelStack;
end;

// Добавить клавиши списка
procedure TDlgStLs.LsBoxEnter;
begin
	AddStack('TDlgStLs.LsBoxEnter',Self);
	with Kp do begin
  	if not Dsgn.OnlyEdit then begin
    	SetKey(K_F3,'Текст','Редактировать в окне "'+Trim(PnView.Header)+'"',KpProcKey,'lsbox',kmEdit);
	  	SetKey(K_F4,'Скопировать','',KpProcKey,'lsbox',kmList);
    end;
  	SetKeys([K_F5,K_Enter],'Редактировать','',KpProcKey,'lsbox',kmList);
  	if not Dsgn.OnlyEdit then begin
      SetKey(K_F7,'Добавить','',KpProcKey,'lsbox',kmList);
      SetKey(K_F8,'Удалить','',KpProcKey,'lsbox',kmList);
    end;
  	SetKey(K_Ctrl_Up,'Выше','Переместить выше',KpProcKey,'lsbox',kmList);
  	SetKey(K_Ctrl_Down,'Ниже','Переместить ниже',KpProcKey,'lsbox',kmList);
  	ReDrw;
  end;
  DelStack;
end;

// Удалить клавиши списка
procedure TDlgStLs.LsBoxExit;
begin
	AddStack('TDlgStLs.LsBoxExit',Self);
  Kp.DelKey(K_All,'lsbox'); Kp.ReDrw;
  DelStack;
end;

procedure TDlgStLs.KpProcKey;
var s: string;
	i: longint;
begin
	AddStack('TDlgStLs.KpProcKey',Self);
	if (Key in [K_F3,K_F7,K_F10,K_Esc]) or (Dsgn.Ls.Count>0) then case Key of
    // Редактировать текст/список
    K_F3: begin
    	View.ReadOnly := not View.ReadOnly;
      Pn111.Enabled:=View.ReadOnly;
    	if View.ReadOnly then begin
      	LsFill; LsBox.SetFocus;
      end
      else begin
      	View.Color:=clWindow; LsBox.Color:=clBtnFace;
        for i:=0 to high(Dsgn.aFld) do Dsgn.aFld[i].SetReadOnly(true);
        View.SetFocus;
        Kp.SetKey(K_F3,'Список','Редактировать в окне "'+Trim(PnLs.Header)+'"',KpProcKey,'view',kmEdit);
        Kp.ReDrw;
      end;
    end;
  	// Добавить/скопировать
    K_F4,K_F7: begin
      if Key=K_F4 then s:=Dsgn.Ls[Dsgn.CurLine]
      else begin
      	s:='';
        for i:=1 to Length(Dsgn.aFld) do IncD(s,Dsgn.DefValue(i)+UnDelim);
        DecLen(s,lUnDelim);
      end;
      Dsgn.Ls.Add(s); i:=LsBox.Items.Add(Dsgn.GetNameLs(s));
      LsText.Add(Dsgn.TransStr(s,false));
      LsBox.ItemIndex:=i; PnEdRead(true); Dsgn.StatusChange(PnStat,dsmAdd);
      PnEd.SetFocus;
    end;
    // Редактировать
    K_F5,K_Enter: PnEd.SetFocus;
    // Удалить
    K_F8: if Ask(amsDel) then begin
      Dsgn.Ls.Delete(Dsgn.CurLine); LsBox.Items.Delete(Dsgn.CurLine);
      LsText.Delete(Dsgn.CurLine);
      LsBox.ItemIndex:=min(Dsgn.CurLine,Dsgn.Ls.Count-1);
      PnEdRead(true); Dsgn.StatusChange(PnStat,dsmDel);
    end;
    // Сохранить
    K_F10: ModalResult:=mrOk;
    // Отмена
    K_Esc: ModalResult:=mrCancel;
    // Выше
    K_Ctrl_Up: Move(Dsgn.CurLine,Dsgn.CurLine-1);
    // Ниже
    K_Ctrl_Down: Move(Dsgn.CurLine,Dsgn.CurLine+1);
  end;
  DelStack;
end;

// Заполнить списки
procedure TDlgStLs.LsFill;
var i,oi: longint;
	s: string;
begin
	AddStack('TDlgStLs.LsFill',Self);
	oi:=LsBox.ItemIndex; LsBox.Hide; Dsgn.Ls.Clear; LsBox.Items.Clear;
  if Assigned(View) then View.Hide; 
  for i:=0 to LsText.Count-1 do begin
    s:=Dsgn.TransStr(LsText[i],true);
    if s<>'' then begin
      Dsgn.Ls.Add(s); LsBox.Items.Add(Dsgn.GetNameLs(s));
    end;
  end;
  LsText.Clear;
  for i:=0 to Dsgn.Ls.Count-1 do LsText.Add(Dsgn.TransStr(Dsgn.Ls[i],false));
  LsBox.ItemIndex:=EnsureRange(oi,0,LsBox.Items.Count-1);
  Dsgn.CurLine:=LsBox.ItemIndex;
  LsBox.Color:=clWindow; LsBox.Show;
  if Assigned(View) then begin
    View.Color:=clBtnFace; View.Show;
  end;
  for i:=0 to high(Dsgn.aFld) do Dsgn.aFld[i].SetReadOnly(false);
  PnEdRead(true);
  DelStack;
end;

// Закончить редактирование
function TDlgStLs.PnEdValid;
var i: longint;
	a: TArrFld;
begin
	AddStack('TDlgStLs.PnEdValid',Self);
  if LsBox.Items.Count=0 then result:=true
  else begin
    result:=Dsgn.Valid(Sender);
    if result then begin
      for i:=1 to Length(Dsgn.aFld) do
        a[i]:=Dsgn.TransArr(TrimRight(RV[IntToStr(i)]),i,true);
      Dsgn.Ls[Dsgn.CurLine]:=ArrayAsList(a,UnDelim,Length(Dsgn.aFld),true);
      LsBox.Items[Dsgn.CurLine]:=Dsgn.GetNameLs(Dsgn.Ls[Dsgn.CurLine]);
      LsText[Dsgn.CurLine]:=Dsgn.TransStr(Dsgn.Ls[Dsgn.CurLine],false);
      if Assigned(Dsgn.Pb) then Dsgn.Pb.Invalidate;
      Dsgn.StatusChange(PnStat,dsmEdit);
    end;
  end;
  DelStack;
end;

// Перемещение по списку переменных
procedure TDlgStLs.LsBoxClick;
begin
	AddStack('TDlgStLs.LsBoxClick',Self);
	PnEdRead(false);
  DelStack;
end;

procedure TDlgStLs.LsBoxKeyUp;
begin
	AddStack('TDlgStLs.LsBoxKeyUp',Self);
	PnEdRead(false);
  DelStack;
end;

// Двойной щелчок - редактирование
procedure TDlgStLs.LsBoxDblClick;
begin
	AddStack('TDlgStLs.LsBoxDblClick',Self);
	Kp.ExecKey(K_Enter);
  DelStack;
end;

// Считать значения в окно редактирования
procedure TDlgStLs.PnEdRead;
var a: TArrFld;
	i,j: longint;
  tf: TFldEdit;
  s: string;
begin
	AddStack('TDlgStLs.PnEdRead',Self);
	if lall or (Dsgn.CurLine<>LsBox.ItemIndex) then begin
    Dsgn.CurLine:=LsBox.ItemIndex;
    if InRange(Dsgn.CurLine,0,Dsgn.Ls.Count-1) then s:=Dsgn.Ls[Dsgn.CurLine] else s:='';
    LsArrFill(s,a,UnDelim);
    for i:=1 to Length(Dsgn.aFld) do begin
      tf:=Dsgn.aFld[i-1]; Dsgn.BeforeRead(i);
      RV[IntToStr(i)]:=Dsgn.TransArr(a[i],i,false);
      tf.Read; Dsgn.EdExit(tf);
    end;
    if Assigned(View) then begin
      j:=0;
      for i:=0 to Dsgn.CurLine-1 do Inc(j,Length(View.Lines[i]+CRLF));
      View.SelStart:=j;
      if View.Lines.Count>0 then View.SelLength:=Length(View.Lines[Dsgn.CurLine]);
    end;
    if Assigned(Dsgn.Pb) then Dsgn.Pb.Invalidate;
  end;
  DelStack;
end;

// Запрос на сохранение
procedure TDlgStLs.FormClose;
begin
	AddStack('TDlgStLs.FormClose',Self);
  if oText<>LsText.Text then AskFormSave(Self,Action);
  DelStack;
end;

// Переместить мышью
procedure TDlgStLs.LsBoxMouseDown;
begin
	AddStack('TDlgStLs.LsBoxMouseDown',Self);
	if not(flMove or (Button<>mbLeft)) then begin
    om:=LsBox.ItemAtPos(Point(X,Y),true); flMove := om>=0;  
  end;
  DelStack;
end;

procedure TDlgStLs.LsBoxMouseMove;
var nm: longint;
begin
	AddStack('TDlgStLs.LsBoxMouseMove',Self);
	if flMove then begin
    nm:=LsBox.ItemAtPos(Point(X,Y),true);
    if (nm>=0) and (nm<>om) then begin
	    Move(om,nm); om:=nm;
    end;
  end;
  DelStack;
end;

procedure TDlgStLs.LsBoxMouseUp;
begin
	flMove:=false;
end;

// Переместить переменную с позиции oi на ni
procedure TDlgStLs.Move;
begin
	AddStack('TDlgStLs.Move',Self);
  if ListMoveItem(oi,ni,0,Dsgn.Ls.Count-1,PrMove,[0]) then begin
    LsBox.ItemIndex:=ni; PnEdRead(true); Dsgn.StatusChange(PnStat,dsmMove);
  end;
  DelStack;
end;

procedure TDlgStLs.PrMove;
begin
	AddStack('TArrGet.PrMove',Self);
  LsBox.Items.Exchange(ni,oi); Dsgn.Ls.Exchange(ni,oi); LsText.Exchange(ni,oi);
  DelStack;
end;

function TDlgStLs.ListOwner;
begin
	AddStack('TDlgStLs.ListOwner',Self);
	result:=Dsgn.ListOwner(Sender);
  DelStack;
end;

end.
