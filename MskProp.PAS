unit MskProp;

interface

implementation

{$I LIBTEST}
uses Windows,Controls,Classes,Forms,SysUtils,Math,DB,Variants,Messages,
  MyTypes,My_pr,FPanel,KeyLb,KeyMenu,PnlEdit,SpinGet,ChkGets,RecVal,ButGet,MenuGet,ComboGet,FrmWnd,
    MultiGet,DateGet,SaveIni,FFldEdit,BtTxtGet,FSchemDM,PswdGet,MemoGet;

type
	TFormMask = class(TFormWnd)
  private
    RecV: TRecVal;
    PnEdit: TPanelEdit;
    FNameWnd: string;
    aHelp: array of function: THelpFile;
  	procedure WMSaveIni(var Msg: TWMSaveIni); message WM_SAVEINI;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  	class procedure FrmResize(Sender: TObject);
    procedure FmlGetHelp(var Message: TMessage); message WM_HELPFILL;
  end;

var LsForm: TList;
	nForm: longint = -1;
  flFormWnd: boolean;
  gRecV: TRecVal;
  gPnEdit: TPanelEdit;

function CurForm: TFormMask;
begin
  AddStack('MskProp.CurForm');
  result:=LsForm[nForm];
  DelStack;
end;

function RV: TRecVal;
begin
  AddStack('MskProp.RV');
  if flFormWnd then result:=CurForm.RecV else result:=gRecV;
  DelStack;
end;

function PnEd: TPanelEdit;
begin
  AddStack('MskProp.PnEd');
  if flFormWnd then result:=CurForm.PnEdit else result:=gPnEdit;
  DelStack;
end;

function EdMaskProp(const Capt: TCaption; const NameWnd: string; vSort: TSortMode; var av: variant;
	lFormWnd: boolean; EdExit: TNotifyEvent; EdChange: TFEChangeEvent;
  EdCheck,PnlValid: TProcValid; FrmShow: TNotifyEvent): boolean;
const sBeg = 'MSKP_';
  wDef=600; hDef=500;
  aClass: array[TMaskPropList] of TCustomGetClass = (TSimpleGet,TSpinGet,TBoolGet,nil,nil,nil,TMemoGet,nil,nil,TMultiGet,TDateGet,nil);
var f: TForm;
	Pn: TRbPanel;
  Kp: TKeyLb;
  tf: TFldEdit;
  mp: TMaskPropList;
  g: TCustomGet;
  cl: TClass;
  i,j,l,p,ph,pa: longint;
  s,nls: string;
  vp: variant;
  fl,oSimpleForm: boolean;
  ft: TFieldType;
  ls: TStringList;
  pp: pointer;
  Par: TWinControl;
  r: TRect;
begin
	AddStack('MskProp.EdMaskProp');
  flFormWnd:=lFormWnd; f:=nil; oSimpleForm:=SimpleForm; SimpleForm:=not lFormWnd;
  if lFormWnd then begin
    Inc(nForm); fl := nForm=ListCreate(LsForm).Count;
    if not fl then f:=LsForm[nForm];
    nls:=IntToStr(LsForm.Count);
  end
  else begin
    fl:=true; nls:='';
  end;
  if fl then begin
    if lFormWnd then begin
    	f:=TFormMask.Create(Application); LsForm.Add(f);
    end
    else f:=TForm.Create(Application);
    with f do begin
      DefaultFont(Font); r:=SysWorkArea;
      SetBounds((r.Right-r.Left-wDef) div 2, (r.Bottom-r.Top-hDef) div 2, wDef, hDef);
      BorderStyle:=bsSizeToolWin; OnResize:=TFormMask.FrmResize;
      TKeyMenu.Create(f);
      if lFormWnd then CurForm.RecV:=TRecVal.Create(f) else gRecV:=TRecVal.Create(f);
      Pn:=TRbPanel.Create(f);
      with Pn do begin
        Parent:=f; BevelOuter:=bvNone; ProcentWnd:=100; Place:=rpBottom;
        Kp:=TKeyLb.Create(f); Kp.Parent:=Pn;
	      if lFormWnd
        then CurForm.PnEdit:=TPanelEdit.Create(f)
        else begin
          Kp.ButShowing:=true; gPnEdit:=TPanelEdit.Create(f);
        end;
        with PnEd do begin
          Parent:=Pn; BevelOuter:=bvLowered; ProcentWnd:=100; Schem:='Edit';
        end;
      end;
    end;
  end
  else Pn:=TRbPanel(f.Controls[0]);
  try
  	with f do begin
      Caption:=Capt;
      if lFormWnd then TFormMask(f).FNameWnd:=NameWnd;
      with Pn do begin
        with PnEd do begin
        	SortMode:=vSort; OnValid:=PnlValid;
          l:=1; Par:=PnEd;
          if lFormWnd then with TFormMask(f) do begin
            i:=VarLength(av);
            SetLength(aHelp,i);
            ZeroMemory(@@aHelp[0],i*SizeOf(@aHelp[0]));
          end;
          for i:=VarArrayLowBound(av,1) to VarArrayHighBound(av,1) do begin
            s:=IntToStr(l); vp:=av[i];
            p:=VarArrayLowBound(vp,1); ph:=VarArrayHighBound(vp,1);
            case MyVarType(vp[p+2]) of
              varInteger: ft:=ftInteger;
              varDouble: ft:=ftFloat;
              varDate: ft:=ftDateTime;
              varBoolean: ft:=ftBoolean;
            else ft:=ftMemo;
            end;
            RV.CreateFld(s,ft,0,vp[p+2]); tf:=TFldEdit.Create(f);
            with tf do begin
            	Parent:=IfThen(vp[p]=mpMulti,PnEd,Par); Font.Style:=[];
              NameRec:=RV.NameRec; NameRecFld:=s; fl:=not empty(vp[p+1]); mp:=vp[p];
              if Assigned(aClass[mp]) then begin
                g:=aClass[mp].GetFirst; Vid:=aClass[mp].CreateOne(g,f).ClassName;
              end;
              case mp of
                mpEdit: begin
                  CharWidth:=40;
                  if ph>=p+3 then
                    if MyVarType(vp[p+3])=varInteger
                    then CharWidth:=vp[p+3]
                    else if vp[p+3] then CharWidth:=wallDefault;
                end;
                mpSpin: Mask:=Format('%d,%d',[longint(vp[p+3]),longint(vp[p+4])]);
                mpBool: begin
                  fl:=false; Mask:=vp[p+1];
                end;
                mpRadio: begin
                  g:=TRadioGet.Create(f); g.VName:=sBeg+s+nls; j:=p+3;
                  ls:=TRadioGet(g).Items; ls.BeginUpdate;
                  if MyVarType(vp[j])=varString then begin
                    ls.Capacity:=ph-j+1;
                    for j:=j to ph do ls.Add(vp[j]);
                  end
                  else begin
                    pa:=vp[j+1]; j:=vp[j]; ls.Capacity:=j;
                    for j:=1 to j do begin
                      ls.Add(string(pointer(pa)^)); Inc(pa,SizeOf(longint));
                    end;
                  end;
                  ls.EndUpdate; AssignGet(g);
                end;
                mpBut: begin
                	fl:=false; g:=TButGet.Create(f); g.VName:=sBeg+s+nls;
                  pp:=PointerVar(vp[p+3]); TButGet(g).OnClick:=TButClickEvent((@pp)^);
                  AssignGet(g); Mask:=ButPrm2Mask(vp[p+1]);
                  if ph>=p+4 then begin
                    pp:=PointerVar(vp[p+4]); TButGet(g).OnPaint:=TButPaintEvent((@pp)^);
                  end;
                end;
                mpButForm: begin
                	fl:=false; g:=TButFormGet.Create(f); g.VName:=sBeg+s+nls;
                  if ph>=p+3 then HelpContext:=vp[p+3];
                  if ph>=p+4 then if lFormWnd then with TFormMask(f) do begin
                    aHelp[l-1]:=PointerVar(vp[p+4]); TButFormGet(g).OnHelp:=FmlGetHelp;
                  end;
                  AssignGet(g); Mask:=vp[p+1];
                end;
                mpMemo: begin
                  fl:=false;
                  Mask:=Format('%d,%d,%d,%d,%s',[0,0,0,0,string(vp[p+1])]);
                  CharWidth:=wallDefault; CharHeight:=-1;
                end;
                mpMenu: begin
									g:=TMenuGet.Create(f); g.VName:=sBeg+s+nls;
                  TMenuGet(g).Items.Text:=vp[p+3]; AssignGet(g); Mask:=vp[p+4];
                end;
                mpCombo: begin
									g:=TComboGet.Create(f); g.VName:=sBeg+s+nls;
                  TComboGet(g).Items.Text:=vp[p+3];
                  TComboGet(g).LenName:=TComboGet.CmbPrm(vp[p+4]).Len;
                  AssignGet(g); Mask:=vp[p+4];
                end;
                mpMulti: begin
                  if ph>=p+3 then if vp[p+3] then CharWidth:=wallDefault;
                  if ph>=p+4 then if vp[p+4] then CharHeight:=-1;
                  if ph>=p+5 then AssignGet(TCustomGet(LongInt(vp[p+5])));
                end;
                mpDate: Mask:=vp[p+3];
                mpCustom: begin
                	AssignGet(TCustomGet(LongInt(vp[p+3])));
                  if ph>=p+4 then Mask:=vp[p+4];
                  if ph>=p+5 then if vp[p+5] then CharWidth:=wallDefault;
                  if ph>=p+6 then if vp[p+6] then CharHeight:=-1;
                end;
              end;
              OnExit:=EdExit; OnChange:=EdChange; OnCheck:=EdCheck;
              RV[s]:=vp[p+2];
            end;
            if fl then tf.SayCaption:=vp[p+1];
            if vp[p]=mpMulti then Par:=tf;
            Inc(l);
          end;
          FillFldList; FldReadAll([ferdSvOld]);
        end;
      end;
      MainRebuild(f);
      RestIniForm(f);
      SetBounds(Left,Top,max(Width,Pn.WMin+Width-ClientWidth),
        max(Height,Pn.HMin+Height-ClientHeight));
      FormOnScreen(f);
      IfThenNotify(FrmShow,f);
      ActiveControl:=PnEd;
      result := ShowModal=mrOk;
      SaveIniForm(f);
      ActiveControl:=PnEd;
      if result then begin
      	l:=1;
        for i:=VarArrayLowBound(av,1) to VarArrayHighBound(av,1) do begin
          av[i]:=RV[IntToStr(l)]; Inc(l);
        end;
      end;
      if lFormWnd then begin
      	if FormsFree then begin
        	i:=LsForm.IndexOf(f); f.Free;
        	if i>=0 then LsForm.Delete(i);
        end
        else begin
          ControlsFree(PnEd); i:=0;
          while i<ComponentCount do begin
            cl:=Components[i].ClassType;
            if(cl=TRadioGet)or(cl=TButGet)or(cl=TButFormGet)or(cl=TMenuGet)or(cl=TComboGet)
            then Components[i].Free else Inc(i);
          end;
        end;
      end
      else f.Free;
    end;
  finally
    SimpleForm:=oSimpleForm;
  end;
  if lFormWnd then Dec(nForm);
  DelStack;
end;

procedure MaskTransProc(Sender: TObject; var av: variant);
var i: TPswdGetList;
begin
  AddStack('MskProp.MaskTransProc');
  if Sender is TBoolGet then begin
    av[1]:=VarArrayOf([mpCustom,'',av[1],LongInt(TButManyStrGet.CreateOne),',,,,Подсказка',true,true]);
    av[2]:=VarArrayOf([mpBool,'Подсказка слева',av[2]]);
    av[3]:=VarArrayOf([mpBool,'Без ввода',av[3]]);
  end
  else if Sender is TBoolMultiGet then begin
    av[1]:=VarArrayOf([mpCustom,'',av[1],LongInt(TButManyStrGet.CreateOne),',,,,Значения',true,true]);
    av[2]:=VarArrayOf([mpBool,'Подсказка слева',av[2]]);
  end
  else if Sender is TPswdGet then begin
    CreateForm(TSchemDM,SchemDM);
    av[1]:=VarArrayOf([mpCustom,'Режим',av[1],LongInt(SchemDM.BoolMultiGetBound),av[5]]);
    av[2]:=VarArrayOf([mpBool,'Не проверять старый пароль',av[2]]);
    av[3]:=VarArrayOf([mpBool,'Допустимо любое значение',av[3]]);
    av[4]:=VarArrayOf([mpBool,'Допустимо пустое значение',av[4]]);
    av[5]:=VarArrayOf([mpMulti,'Подсказки:','',true]);
    for i:=low(TPswdGetList) to high(TPswdGetList) do
      av[6+byte(i)]:=VarArrayOf([mpCustom,'',av[6+byte(i)],LongInt(TButManyStrGet.CreateOne)]);
  end;
  DelStack;
end;

function EdMaskFld(Index: longint): TFldEdit;
begin
	AddStack('MskProp.EdMaskFld');
  result:=nil;
  if PnEd<>nil then if InRange(Index,1,PnEd.FieldCount) then result:=PnEd.Fields[Index-1];
  DelStack;
end;

function GetEdMaskVal(Index: longint): variant;
begin
	AddStack('MskProp.GetEdMaskVal');
	result:=RV[EdMaskFld(Index).NameRecFld];
  DelStack;
end;

procedure SetEdMaskVal(Index: longint; const Value: variant);
begin
	AddStack('MskProp.SetEdMaskVal');
	EdMaskFld(Index).VarValue:=Value;
  DelStack;
end;

{ TFormMask }
procedure TFormMask.WMSaveIni;
begin
  AddStack('TFormMask.WMSaveIni',Self);
  Msg.pSection^:='Mask.'+FNameWnd;
  DelStack;
end;

procedure TFormMask.WMFormLimit;
begin
	AddStack('TFormMask.WMFormLimit',Self);
  inherited;
  FreeLimit(LsForm,nForm);
  DelStack;
end;

class procedure TFormMask.FrmResize;
begin
	AddStack('TFormMask.FrmResize');
	FPanel.RbFormResize(TForm(Sender));
  DelStack;
end;

procedure TFormMask.FmlGetHelp;
var tw: TWinControl;
  i: longint;
begin
  AddStack('TFormMask.FmlGetHelp',Self);
  with TWMHelpFill(Message) do if Oper=hlpFile then
    if ParentClass(tw,ActiveControl,TFldEdit) then if tw.HelpContext=0 then begin
      i:=TPanelEdit.ParentPnEd(tw).FindField(TFldEdit(tw).NameRecFld);
      if Assigned(aHelp[i]) then begin
        pFile.f[hlpfBase]:=aHelp[i]; ResFile:=true;
      end;
    end;
  DelStack;
end;

initialization
  AddStack('MskProp.initialization');
  FFldedit.MaskTransProc:=MaskTransProc;
  FFldedit.EdMaskProp:=EdMaskProp; FFldedit.EdMaskFld:=EdMaskFld;
  FFldedit.GetEdMaskVal:=GetEdMaskVal; FFldedit.SetEdMaskVal:=SetEdMaskVal;
  DelStack;
finalization
	AddStack('MskProp.finalization');
  LsForm.Free;
  DelStack;
end.
