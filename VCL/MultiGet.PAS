unit MultiGet;

interface

{$I LIBTEST}
uses
  Windows,Messages,Classes,Controls,
  MyTypes,FFldedit,RecVal;

type
  TMultiGet = class(TCustomGet)
  private
    { Private declarations }
  protected
    { Protected declarations }
		procedure CreateObj(tf: TFldEdit); override;
		procedure PaintObj(tf: TFldEdit); override;
    function SizeAuto(tf: TFldEdit; Opt: TFESizeAutoOpt): TSize; override;
    procedure HookProc(tf: TFldEdit; var Message: TMessage); override;
		function SortMode(tf: TFldEdit): TSortMode; virtual;
    class procedure FMaskView(var Mask: string); override;
    procedure FMaskHelp(var mh: TMaskHelp; var ht: THelpTbl); override;
    procedure PlaceControls(tf: TFldEdit; Condens: boolean); virtual;
  public
    { Public declarations }
		constructor Create(AOwner: TComponent); override;
		procedure StdDWFldInfo(const Mask: string; var FldInfo: TDWFldInfo); override;
    class function MaskTextReadOnly: boolean; override;
		class function DefRelation: TFldRelation; override;
  	class function DDatSupport: boolean; override;
  published
    { Published declarations }
		function MaskEdProc(const Capt: TCaption; var Mask: string;
    	r: TCustomRec; const nmf: string; lSearch: boolean): variant; override;
  end;

procedure Register;

implementation

uses Forms,StrUtils,Math,
  My_pr,FPanel,PSort,PaintCtl;

{ TMultiGet }
constructor TMultiGet.Create;
begin
	AddStack('TMultiGet.Create',Self);
	Inherited Create(AOwner);
  RVid:='Ввод нескольких значений'; UpdateAllFld(mgCreate);
  DelStack;
end;

procedure TMultiGet.CreateObj;
begin
	AddStack('TMultiGet.CreateObj',Self);
  DestroyObj(tf);
  tf.Relation:=frMain;
	inherited CreateObj(tf);
  DelStack;
end;

procedure TMultiGet.PaintObj;
begin
	AddStack('TMultiGet.PaintObj',Self);
  PlaceControls(tf,false);
  DelStack;
end;

function TMultiGet.SizeAuto;
var i: longint;
	p: TPaintControl;
begin
	AddStack('TMultiGet.SizeAuto',Self);
	result := inherited SizeAuto(tf,Opt);
  if (tf.ControlCount>0) or not(csDesigning in ComponentState) then with result do begin
    PlaceControls(tf,true);
    if tfszWidth in Opt then cX:=0;
    if tfszHeight in Opt then cY:=0;
    for i:=0 to tf.ControlCount-1 do
      if tf.Controls[i].Visible then begin
        if tfszWidth in Opt then MaxSelf(cX,tf.Controls[i].Left+tf.Controls[i].Width);
        if tfszHeight in Opt then MaxSelf(cY,tf.Controls[i].Top+tf.Controls[i].Height);
      end;
    for i:=0 to tf.ComponentCount-1 do
      if IsClass(tf.Components[i],TPaintControl,pointer(p)) then if p.Visible then begin
        if tfszWidth in Opt then MaxSelf(cX,p.Bounds.Right);
        if tfszHeight in Opt then MaxSelf(cY,p.Bounds.Bottom);
      end;
    if (tfszWidth in Opt) and (cX>0) then Dec(cX,BevelFld2);
    if (tfszHeight in Opt) and (cY>0) then Dec(cY,BevelFld2);
  end;
  DelStack;
end;

procedure TMultiGet.PlaceControls;
begin
  AddStack('TMultiGet.PlaceControls',Self);
  PSortObj(tf,0,0,tf.Width,tf.Height,SortMode(tf),Condens);
  DelStack;
end;

class function TMultiGet.DefRelation;
begin
	result:=frMain;
end;

class function TMultiGet.DDatSupport;
begin
  result:=true;
end;

procedure TMultiGet.HookProc;
var ls: TList;
  i: longint;
  tw: TWinControl;
begin
	AddStack('TMultiGet.HookProc',Self);
  inherited HookProc(tf,Message);
  case Message.Msg of
    WM_SETFOCUS: if not tf.IsDynamic then begin
      tw:=ActiveFldEdit;
      while Assigned(tw) do
        if tw=tf then begin
          tw:=ActiveFldEdit; break;
        end
        else ParentSelf(tw);
      if not Assigned(tw) then begin
        ls:=TList.Create;
        try
          tf.GetTabOrderList(ls);
          for i:=0 to ls.Count-1 do if IsClass(ls[i],TFldEdit,pointer(tf)) then if tf.CanFocus then
            if not(ogReadOnly in tf.Options) then begin
              tw:=tf; break;
            end;
        finally
          ls.Free;
        end;
      end;
      if Assigned(tw) then GetParentForm(tf).ActiveControl:=tw;
    end;
    WM_PSORT: with TWMPSort(Message) do if Oper=swmSortInfo then with si^ do begin
      Mode:=SortMode(tf); Width:=tf.Width; Height:=tf.Height; result:=1;
    end;
  end;
  DelStack;
end;

function TMultiGet.MaskEdProc;
begin
	AddStack('TMultiGet.MaskEdProc',Self);
  Mask:=IfThen(Int0(Mask)>1,'1','2'); result:=true;
  DelStack;
end;

class procedure TMultiGet.FMaskView;
begin
	AddStack('TMultiGet.FMaskView');
  Mask:='Сортировка по '+IfThen(Int0(Mask)>1,'строкам','колонкам');
  DelStack;
end;

class function TMultiGet.MaskTextReadOnly;
begin
	result:=true;
end;

procedure TMultiGet.FMaskHelp;
var n: byte;
begin
  AddStack('TMultiGet.FMaskHelp',Self);
  inherited;
  n:=high(ht.Dat); SetLength(ht.Dat,n+2);
  Inc(n); CopyFrom(ht.Dat[n],HelpNum('«Сортировка: 1-по колонкам, 2-по строкам»'));
  DelStack;
end;

function TMultiGet.SortMode;
begin
  AddStack('TMultiGet.SortMode',Self);
  result:=iif(Int0(tf.Mask)>1,smRows,smColumns);
  DelStack;
end;

procedure TMultiGet.StdDWFldInfo;
begin
	AddStack('TMultiGet.StdDWFldInfo',Self);
  FldInfo.FieldClass:=nil;
  DelStack;
end;

procedure Register;
begin
  RegisterComponents('OurGets',[TMultiGet]);
end;

end.
