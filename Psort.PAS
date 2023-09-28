unit Psort;

interface

{$I LIBTEST}
uses
  Classes,Controls,
  MyTypes;

var PSortCondens: boolean;

procedure PSortObj(P: TWinControl;
	aLeft,aTop,aWidth,aHeight: longint; Mode: TSortMode; Condens: boolean);
function PSortList(P: TWinControl; Mode: TSortMode; var ps: TBoolPPSortObj; var ols: TArrInt; var ao: TArrPSortObj): boolean;
function MsgPSort(Sender: TComponent; Oper: TPSortOper; si: PPSortInfo = nil): longint;

implementation

uses Windows,SysUtils,Forms,Math,
  My_Pr,PaintCtl;

type
	TNone = class(TObject)
	private
		class procedure PsortMove(oi,ni: longint; const av: array of variant);
  end;

function SortTabOrder(o1,o2: PPSortObj): TValueSign;
var tw1,tw2: TWinControl;
begin
  AddStack('PSort.SortTabOrder');
  result:=0;
  if IsClass(o1.Obj,TWinControl,pointer(tw1)) and IsClass(o2.Obj,TWinControl,pointer(tw2))
  	then result:=CompSign(tw1.TabOrder,tw2.TabOrder)
  else if (o1.Obj is TPaintControl) and (o2.Obj is TPaintControl)
  	then result:=CompSign(o1.Obj.ComponentIndex,o2.Obj.ComponentIndex)
  else if o1.Obj is TPaintControl
  	then result:=CompSign(0,1)
  else if o2.Obj is TPaintControl
  	then result:=CompSign(1,0);
  DelStack;
end;

{ Сортировка объектов внутри панели }
procedure PSortObj;
  function wrnd(Width,Height: longint): longint;
  begin
    AddStack('PSort.PSortObj.wrnd');
    result:=nround(Width*Height/10);
    DelStack;
  end;
const
  ilX = 10;
  ilY = 7;
  minX = 20;
  minY = 50;
var ps: TBoolPPSortObj;
	ols: TArrInt;
  function PsWidth(n:longint): longint;
  begin
  	AddStack('PSort.PSortObj.PsWidth');
    if ols[n]<0 then result:=0
    else result:=ps[true,ols[n]].Width+IfThen(Mode=smDefault,ilX);
    DelStack;
  end;
	function PsHeight(n:longint): longint;
  begin
  	AddStack('PSort.PSortObj.PsHeight');
    if ols[n]<0 then result:=0 else result:=ps[true,ols[n]].Height;
    DelStack;
  end;
  function PsTop(n,zn:longint): longint;
  var p: PPSortObj;
  begin
  	AddStack('PSort.PSortObj.PsTop');
    if ols[n]<0 then result:=0
    else begin
    	p:=ps[true,ols[n]]; result:=p.Top;
      if zn<>MaxInt then p.Top:=zn;
    end;
    DelStack;
  end;
  function PsLeft(n: longint; zn: longint = MaxInt): longint;
  var pb: PPSortObj;
  begin
  	AddStack('PSort.PSortObj.PsLeft');
    result:=0;
    if ols[n]>=0 then begin
    	pb:=ps[true,ols[n]]; result:=pb.Left;
      if zn<>MaxInt then pb.Left:=zn;
    end;
    DelStack;
  end;
var i,lb,wl,hl,whl,nfr: longint;
  a: TArrInt;
  procedure ObjLeft;
  var j: longint;
  	pb: PPSortObj;
  begin
    AddStack('PSort.PSortObj.ObjLeft');
    MaxSelf(whl,wl+hl);
    for j:=nfr to i-1 do begin
    	pb:=ps[false,j]; pb.Left:=lb+IfThen(a[j]<>-1,wl);
      if a[j]=-1 then PsLeft(j,lb+nRound((pb.Width-PsWidth(j))/2));
    end;
    DelStack;
  end;
var j,tb,maxh,lcb,nsY,iX,iY: longint;
	oldAct: TWinControl;
	sP,sO: longint;
  pb,pb1: PPSortObj;
  oCond,fl: boolean;
  ar: array of array[1..3] of longint;
  ao: TArrPSortObj;
  al: TArrBoolInt;
begin
	AddStack('PSort.PSortObj');
  oldAct:=GetParentForm(P).ActiveControl;
  oCond:=PSortCondens; PSortCondens := (Mode<>smDefault) and Condens;
  for i:=0 to P.ControlCount-1 do
    with P.Controls[i] do SetBounds(Left,Top,Width,Height);
  if PSortList(P,Mode,ps,ols,ao) then begin
    for fl:=false to true do al[fl]:=Length(ps[fl]);
    tb:=0;
    case Mode of
      // СОРТИРОВКА ПО УМОЛЧАНИЮ
      smDefault: begin
        sP:=wrnd(aWidth,aHeight); iX:=10; iY:=10; sO:=0;
        for i:=0 to al[false]-1 do begin
          pb:=ps[false,i]; Inc(sO,wrnd(pb.Width,pb.Height)+wrnd(PsWidth(i),PsHeight(i)));
        end;
        if sO<>0 then begin
          iX:=nround(iX*sP/sO*0.7); MinSelf(iX,minX); iY:=iX;
        end;
        { Расположить на панели }
        tb:=iY; lb:=iX; maxh:=0; nfr:=0; wl:=0; hl:=0; nsY:=1;
        for j:=0 to al[false]-1 do begin
          pb:=ps[false,j];
          if (lb+pb.Width+PsWidth(j)+iX>aWidth) or (pb.Obj.Tag>0) then begin
            { Выровнять по горизонтали }
            if j<>nfr then begin
              wl:=nround(mdouble(max(0,aWidth-wl))/mdouble(j-nfr)); lcb := wl div 2;
              for i:=nfr to j-1 do	begin
                pb1:=ps[false,i]; PsLeft(i,lcb); pb1.Left:=lcb+PsWidth(i); Inc(lcb,pb1.Width+PsWidth(i)+wl);
              end;
            end;
            Inc(tb,maxh+iY); lb:=iX; Inc(hl,maxh); maxh:=0; nfr:=j; wl:=0; Inc(nsY);
          end;
          { Label и объект не влезают в строку }
          if (PsWidth(j)>0) and (pb.Width+PsWidth(j)+iX+iX>aWidth) then begin
            psTop(j,tb); psLeft(j,(aWidth-psWidth(j)+ilX) div 2);
            pb.Top:=tb+psHeight(j)+ilY;
            pb.Left := (aWidth-pb.Width) div 2;
            Inc(tb,pb.Height+psHeight(j)+iY+ilY); lb:=iX;
            Inc(hl,pb.Height+psHeight(j)+ilY);
            maxh:=0; nfr:=j+1; wl:=0;
            if j<al[false]-1 then Inc(nsY);
          end
          else begin
            psTop(j,tb); psLeft(j,lb);
            pb.Top:=tb; pb.Left:=lb+psWidth(j);
            maxh:=MaxIntValue([maxh,pb.Height,psHeight(j)]);
            Inc(wl,pb.Width+PsWidth(j));
            Inc(lb,pb.Width+PsWidth(j)+iX);
          end;
        end;

        { Выровнять по горизонтали последнюю строку }
        if al[false]<>nfr then begin
          wl:=nround(mdouble(aWidth-wl)/mdouble(al[false]-nfr));
          lcb := wl div 2;
          for i:=nfr to al[false]-1 do begin
            pb:=ps[false,i]; PsLeft(i,lcb); pb.Left:=lcb+PsWidth(i);
            Inc(lcb,pb.Width+PsWidth(i)+wl);
          end;
        end;

        { Выровнять по вертикали }
        hl:=EnsureRange(nround(mdouble(aHeight-hl-maxh)/mdouble(nsY)),0,minY);
        tb := hl div 2; maxh:=0; j:=MaxInt;
        for i:=0 to al[false]-1 do begin
          pb:=ps[false,i];
          if j=MaxInt then j:=pb.Top;
          if (j<>MaxInt) and (pb.Top<>j) then begin
            Inc(tb,maxh+hl); maxh:=0; j:=pb.Top;
          end;
          if (psWidth(i)>0) and (pb.Top<>psTop(i,MaxInt)) then begin
            PsTop(i,tb); pb.Top:=tb+psHeight(i)+ilY;
            Inc(tb,pb.Height+psHeight(i)+hl+ilY); maxh:=0; j:=MaxInt;
          end
          else begin
            PsTop(i,tb); pb.Top:=tb; maxh:=MaxIntValue([maxh,pb.Height,psHeight(i)]);
          end;
        end;
      end;
      // СОРТИРОВКА ПО КОЛОНКАМ
      smColumns: begin
        lb:=0; maxh:=0; wl:=0; hl:=0; whl:=0; SetLength(a,al[false]);
        for i:=0 to al[false]-1 do begin
          pb:=ps[false,i];
          if (i=0) or (pb.Obj.Tag<>0) then begin
            tb:=0; Inc(lb); Inc(maxh,max(whl,wl+hl)); wl:=0; hl:=0; whl:=0;
          end;
          a[i]:=MsgPsort(pb.Obj,swmColWidthAll); pb.Left:=lb; PsTop(i,tb);
          if (a[i]<0) and Condens then pb.Width:=0;
          if a[i]=wallDefault then begin
            whl:=MaxIntValue([whl,psWidth(i),pb.Width]); pb.Top:=tb+PsHeight(i);
            Inc(tb,pb.Height+PsHeight(i));
          end
          else begin
            MaxSelf(wl,psWidth(i)); MaxSelf(hl,pb.Width); pb.Top:=tb;
            Inc(tb,max(pb.Height,PsHeight(i)));
          end;
        end;
        Inc(maxh,max(whl,wl+hl));
        lcb:=max(0,IfThen(not Condens,nround((aWidth-SysMetric.iScrollWidth-maxh)/lb)));
        lb := lcb div 2; nsY:=1; nfr:=0; wl:=0; hl:=0; whl:=0;
        for i:=0 to al[false]-1 do begin
          pb:=ps[false,i];
          if pb.Left<>nsY then begin
            ObjLeft; nsY:=pb.Left; Inc(lb,whl+lcb); nfr:=i; wl:=0; hl:=0; whl:=0;
          end;
          if a[i]=wallDefault then whl:=MaxIntValue([whl,psWidth(i),pb.Width])
          else begin
            if MsgPSort(pb.Obj,swmSayRight)=0 then MaxSelf(wl,psWidth(i));
            MaxSelf(hl,pb.Width);
          end;
          PsLeft(i,lb);
        end;
        ObjLeft;
      end;
      // СОРТИРОВКА ПО СТРОКАМ
      smRows: begin
        SetLength(ar,al[false]); j:=-1; nfr:=0; hl:=0;
        for i:=0 to al[false]-1 do begin
          pb:=ps[false,i];
          //if (a[i]<0) and Condens then pb.Width:=0;
          if pb.Obj.Tag<>0 then begin
            Inc(tb,hl); hl:=0; nfr:=0;
          end;
          if j<nfr then begin
            j:=nfr; ZeroMemory(@ar[j],SizeOf(ar[j]));
          end;
          MaxSelf(ar[nfr,IfThen(MsgPSort(pb.Obj,swmSayRight)=0,1,3)],psWidth(i));
          MaxSelf(ar[nfr,2],pb.Width);
          psTop(i,tb); pb.Top:=tb; hl:=MaxIntValue([hl,psHeight(i),pb.Height]); Inc(nfr);
        end;
        Inc(j); SetLength(ar,j); lcb:=0;
        if not Condens then begin
          for i:=low(ar) to high(ar) do Inc(lcb,SumInt(ar[i]));
          lcb:=nround((aWidth-lcb)/j);
        end;
        j := lcb div 2; lb:=j; nfr:=0;
        for i:=0 to al[false]-1 do begin
          pb:=ps[false,i];
          if pb.Obj.Tag<>0 then begin
            lb:=j; nfr:=0;
          end;
          fl := MsgPSort(pb.Obj,swmSayRight)=0;
          if fl then psLeft(i,lb);
          Inc(lb,ar[nfr,1]); pb.Left:=lb; Inc(lb,ar[nfr,2]);
          if not fl then psLeft(i,lb);
          Inc(lb,ar[nfr,3]+lcb); Inc(nfr);
        end;
      end;
    end;
    for i:=0 to al[false]-1 do with ps[false,i]^ do begin
      // Подсказки справа
      if Mode<>smRows then if ols[i]>=0 then
        if (MsgPSort(Obj,swmSayRight)>0) and (MsgPSort(Obj,swmColWidthAll)=0) then begin
          pb:=ps[true,ols[i]]; Left:=pb.Left; pb.Left:=Left+Width;
        end;
      TPaintControl.ObjSetBounds(Obj,Left+aLeft,Top+aTop,Width,Height);
    end;
    for i:=0 to al[true]-1 do with ps[true,i]^ do
      TPaintControl.ObjSetBounds(Obj,Left+aLeft,Top+aTop,Width,Height);
  end;
  PSortCondens:=oCond; GetParentForm(P).ActiveControl:=oldAct;
  DelStack;
end;

function SortTopLeft(p: pointer; fi,si: longint; sortID: TSortID): boolean;
var a: PArrPPSortObj;
  i: TValueSign;
begin
	AddStack('PSort.SortTopLeft');
  result:=false; a:=p;
  case sortID of
    sort1MORE2: begin
      i:=SortTabOrder(a^[fi],a^[si]);
      if i=0 then begin
        i:=CompSign(a^[fi].Top,a^[si].Top);
        if i=0 then i:=CompSign(a^[fi].Left,a^[si].Left);
      end;
      result := i>0;
    end;
    sortEXCHANGE: TNone.PsortMove(fi,si,[longint(a)]);
  end;
  DelStack;
end;

function SortLeftTop(p: pointer; fi,si: longint; sortID: TSortID): boolean;
var a: PArrPPSortObj;
  i: TValueSign;
begin
	AddStack('PSort.SortLeftTop');
  result:=false; a:=p;
  case sortID of
    sort1MORE2: begin
      i:=SortTabOrder(a^[fi],a^[si]);
      if i=0 then begin
        i:=CompSign(a^[fi].Left,a^[si].Left);
        if i=0 then i:=CompSign(a^[fi].Top,a^[si].Top);
      end;
      result := i>0;
    end;
    sortEXCHANGE: TNone.PsortMove(fi,si,[longint(a)]);
  end;
  DelStack;
end;

function PSortList;
var twc: TComponent;
  procedure SeekFocCont(tc: TComponent);
  var i: longint;
  begin
  	AddStack('PSort.PSortList.SeekFocCont');
    i:=MsgPSort(tc,swmFocusControl);
    if i=0 then twc:=nil else twc:=TComponent(i);
    DelStack;
  end;
var pb: PPSortObj;
  al: TArrBoolInt;
  // Исключить Label и TFldEdit с объявленным FocusControl
  procedure lsAdd;
  var fl,lsay: boolean;
  begin
    AddStack('PSort.PSortList.lsAdd');
    lsay:=false; SeekFocCont(pb.Obj);
    if Assigned(twc) then begin
      if twc is TPaintControl
      then fl:=TPaintControl(twc).Visible
      else fl:=     TControl(twc).Visible;
      if fl then if MsgPSort(pb.Obj,swmNoSorted)=0 then lsay:=true;
    end;
    ps[lsay,al[lsay]]:=pb; Inc(al[lsay]);
    DelStack;
  end;
const aSortProc: array[boolean] of TFSort = (SortTopLeft,SortLeftTop);
var i,j,k,l: longint;
  pb1: PPSortObj;
  tc: TComponent;
  fl: boolean;
  lsps: TList;
  pc: TPaintControl;
begin
  AddStack('PSort.PSortList');
  l:=P.ControlCount+P.ComponentCount; SetLength(ao,l);
  for fl:=false to true do SetLength(ps[fl],l);
  l:=0; ZeroMemory(@al,SizeOf(al));
  for i:=0 to P.ControlCount-1 do begin
    if not P.Controls[i].Visible then continue;
    if MsgPSort(P.Controls[i],swmNoSorted)<>0 then continue;
    pb:=@ao[l]; Inc(l); pb.Obj:=P.Controls[i];
    with TControl(pb.Obj) do begin
    	pb.Left:=Left; pb.Top:=Top; pb.Width:=Width; pb.Height:=Height;
    end;
    lsAdd;
  end;
  for i:=0 to P.ComponentCount-1 do if IsClass(P.Components[i],TPaintControl,pointer(pc)) then begin
    if not pc.Visible then continue;
    if MsgPSort(pc,swmNoSorted)<>0 then continue;
    pb:=@ao[l]; Inc(l); pb.Obj:=pc;
    pb.Left:=pc.Left; pb.Top:=pc.Top; pb.Width:=pc.Width; pb.Height:=pc.Height;
    lsAdd;
  end;
  for fl:=false to true do SetLength(ps[fl],al[fl]);
  SetLength(ao,l); SetLength(ols,al[false]); result := al[false]>0;
  if result then begin
    if al[false]>1 then QuickSort(aSortProc[Mode=smColumns],@ps[false],0,al[false]-1);
    // TabOrder для PaintSay
    lsps:=TList.Create;
    try
      j:=0;
      while j<al[false] do begin
        pb:=ps[false,j];
        if pb.Obj is TPaintControl then
        	if lsps.IndexOf(pb.Obj)<0 then begin
            k:=TPaintControl(pb.Obj).perform(WM_PAINTCTL,byte(pcmTabOrdCtl),0);
            if k<>0 then begin
              tc:=TComponent(k); fl:=false;
              for k:=0 to al[false]-1 do if ps[false,k].Obj=tc then begin
                ListMoveItem(j,IfThen(k>j,k-1,k),0,al[false]-1,TNone.PSortMove,[LongInt(@ps[false])]);
                lsps.Add(pb.Obj); fl:=true; break;
              end;
              if fl then continue;
            end;
        end;
        Inc(j);
      end;
    finally
      lsps.Free;
    end;
    // Сопоставить объектам их Label-ы
    for j:=0 to al[false]-1 do begin
      pb:=ps[false,j]; i:=al[true]-1;
      while i>=0 do begin
        pb1:=ps[true,i]; SeekFocCont(pb1.Obj);
        if twc=pb.Obj then break else Dec(i);
      end;
      ols[j]:=i;
    end;
  end;
  DelStack;
end;

function MsgPSort;
begin
  AddStack('Psort.MsgPSort');
  result:=TPaintControl.ObjPerform(Sender,WM_PSORT,byte(Oper),longint(si));
  DelStack;
end;

{ TNone }
class procedure TNone.PsortMove;
var a: PArrPPSortObj;
  v: PPSortObj;
begin
	AddStack('TNone.PsortMove');
  a:=PointerVar(av[0]); v:=a^[oi]; a^[oi]:=a^[ni]; a^[ni]:=v;
  DelStack;
end;

end.
