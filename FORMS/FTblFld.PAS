unit FTblFld;

interface

uses
  Messages, Classes, Controls, ExtCtrls, ComCtrls, Menus, 
  MyTypes, FRMEMPTY, Keylb, Fpanel, TreePrim, KeyMenu;

type
  TTblFldView = (tfvAll,tfvKey,tfvSort);

  TTblFld = class(TFormEmp)
    Tree: TTreePrim;
    KeyMenu1: TKeyMenu;
    procedure FormShow(Sender: TObject);
    procedure TreeExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
    CurView: TTblFldView;
    procedure SetView;
    function NextView: TTblFldView;
    procedure ProcKey(key: longint; tw: TWinControl);
    procedure Fill;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses DB,StrUtils,
  My_pr,MulQry,RecDB;

var TblFld: TTblFld;

procedure TTblFld.FormCreate(Sender: TObject);
begin
  AddStack('TTblFld.FormCreate',Self);
  inherited;
  CurView:=TTblFldView(InitFIni[fiSave].ReadInteger('TblFld','CurView'));
  DelStack;
end;

procedure TTblFld.FormDestroy(Sender: TObject);
begin
  AddStack('TTblFld.FormDestroy',Self);
  InitFIni[fiSave].WriteInteger('TblFld','CurView',byte(CurView));
  inherited;
  DelStack;
end;

procedure TTblFld.FormShow(Sender: TObject);
begin
  AddStack('TTblFld.FormShow',Self);
  Fill;
  inherited;
  DelStack;
end;

procedure TTblFld.FormHide(Sender: TObject);
begin
  AddStack('TTblFld.FormHide',Self);
  Tree.SaveToIni;
  inherited;
  DelStack;
end;

procedure TTblFld.Fill;
var i: longint;
begin
  AddStack('TTblFld.Fill',Self);
  Tree.BeginUpdate; Tree.ClearPrim;
  with GetTableList do for i:=0 to Count-1 do
    Tree.AddPrim(Tree.AddPrim(nil,Strings[i],GetPrim(Strings[i],false)));
  Tree.EndUpdate; Tree.RestFromIni; SetView;
  DelStack;
end;

procedure TTblFld.WMFormLimit;
begin
	AddStack('TTblFld.WMFormLimit',Self);
  inherited;
  FreeLimit(TblFld);
  DelStack;
end;

procedure TTblFld.TreeExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
const aSort: TArrBoolStr = ('Индексы','Уникальные ключи');
var i,j,k: longint;
  lsf: TMQFieldList;
  tn: TTreeNode;
  fl,lDop: boolean;
  tbl,s: string;
  r,r1: TRecDBDef;
  a: TArrInt;
  af: TArrStr;
begin
  AddStack('TTblFld.TreeExpanding',Self);
  af:=nil; // Variable might not have been initialized
  if AllowExpansion then
    if NodeNotFill(Node) then begin
      Tree.BeginUpdate;
      if CurView=tfvSort then begin
        tbl:='';
        case Node.Level of
          0: for fl:=false to true do with TMQIndexList.Create(DBMain,Node.Text,fl) do
            try
              if Count>0 then Tree.AddPrim(Tree.AddPrim(Node,aSort[fl]));
            finally
              Free;
            end;
          1: with TMQIndexList.Create(DBMain,Node.Parent.Text,boolean(Node.Index)) do
            try
              for i:=0 to Count-1 do Tree.AddPrim(Tree.AddPrim(Node,Strings[i]));
            finally
              Free;
            end;
          2: begin
            tbl:=Node.Parent.Parent.Text;
            with TMQIndexList.Create(DBMain,tbl,boolean(Node.Parent.Index)) do
            try
              af:=Indices(Node.Index);
            finally
              Free;
            end;
          end;
        end;
      end
      else tbl:=Node.Text;
      if tbl<>'' then begin
        lsf:=GetFieldList(tbl); lDop:=false;
        case CurView of
          tfvAll: begin
            SetLength(a,lsf.Count);
            for i:=low(a) to high(a) do a[i]:=i;
          end;
          tfvKey: lsf.GetKeyOrd(a);
          tfvSort: begin
            SetLength(a,Length(af));
            for i:=low(af) to high(af) do a[i]:=lsf.IndexOf(af[i]);
          end;
        end;
        for i:=low(a) to high(a) do begin
          with lsf.Fields(a[i])^ do if mqfBool in Options then s:='логическое'
          else case UnDataType(DataType) of
            ftInteger: s:='целое';
            ftFloat: s:='число';
            ftDate: s:='дата';
            ftBlob: s:='объект';
          else s:=StrNum('строка ',Size);
          end;
          tn:=Tree.AddPrim(Node,lsf[a[i]],'['+s+'] '+GetPrimFld(tbl,lsf,a[i]));
          if not lDop and AnsiStartsText(sLong,lsf[a[i]]) then begin
            if Assigned(LsCustomRec) then with LsCustomRec do for k:=0 to Count-1 do
              if IsClass(Objects[k],TRecDBDef,pointer(r)) then if r.NameDB=tbl then begin
                r1:=r.DWRdbSeek;
                if Assigned(r1) then r:=r1;
                for j:=0 to r.FldDef.Count-1 do with r.DWSToRec(j) do if SvType=dwsNoFix then begin
                  s:=aDWFld[AType].nm;
                  if AType in DWsetLen then IncD(s,StrNum(' ',Len));
                  if (AType=dwtFloat) and (Dec<>0) then IncD(s,StrNum('.',Dec));
                  Tree.AddPrim(tn,Name,'['+s+'] '+GetPrimFld(tbl,Name,Prim,lDop));
                end;
                tn.AlphaSort; break;
              end;
            lDop:=true;
          end;
        end;
      end;
      Tree.DeletePrim(Node.getFirstChild); Tree.EndUpdate;
    end;
  DelStack;
end;

procedure TTblFld.SetView;
const a: array[TTblFldView,1..3] of string =
  (('Все'       ,'Просмотр всех полей'           ,'и полей')
  ,('Ключевые'  ,'Просмотр только ключевых полей','(только ключевые поля)')
  ,('Сортировки','Просмотр сортировок'           ,'(сортировки)')
  );
var n: TTblFldView;
begin
  AddStack('TTblFld.SetView',Self);
  n:=NextView; KeyLb1.SetKey(K_Tab,a[n,1],a[n,2],ProcKey,'tblfld',kmList);
  Caption:='Наименования таблиц '+a[CurView,3];
  DelStack;
end;

function TTblFld.NextView;
begin
  AddStack('TTblFld.NextView',Self);
  result:=iif(CurView=high(CurView),low(CurView),Succ(CurView));
  DelStack;
end;

procedure TTblFld.ProcKey;
begin
  AddStack('TTblFld.ProcKey',Self);
  Tree.SaveToIni; CurView:=NextView; Fill; KeyLb1.ReDrw;
  DelStack;
end;

procedure PswdKeyProc(Key: longint; tw: TWinControl; var lBreak: boolean);
begin
  AddStack('FTblFld.PswdKeyProc');
  if Key=K_Alt_H then begin
    lBreak:=true; CreateShow(TTblFld,TblFld,true);
  end;
  DelStack;
end;

initialization
  AddStack('FTblFld.initialization');
  AddFrom(aPswdKeyProc,PswdKeyProc);
  DelStack;
end.
