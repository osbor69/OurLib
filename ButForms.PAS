unit ButForms;

interface

uses Windows,Graphics,Classes,
  MyTypes;

function ButtonPrmStr(const ButtonRec: TButtonRec): string;
procedure ButtonPrmTrans(const ButtonRec: TButtonRec; var av: variant; var vSort: TSortMode;
	var EdExit: TNotifyEvent; var EdChange: TFEChangeEvent;	var EdCheck,PnlValid: TProcValid;
  var FrmShow: TNotifyEvent);

implementation

uses SysUtils,Math,Variants,StrUtils,
  My_pr,FFldEdit;

const n=150;
  aPolyButNmType: array[1..3] of string = ('Ромб','Параллелограмм','Указатель');
  aAtr: array[boolean,boolean] of TButtonAtrType =
    ((btfWinNotActFreeAction ,btfWinActFreeAction)
    ,(btfWinNotActPressAction,btfWinActPressAction)
    );

var ap: array[1..9] of string;

type
  TNone = class(TObject)
  private
    class procedure EdChange(Sender: TObject; const OldVal: variant; FromShow: boolean);
    class procedure FrmShow(Sender: TObject);
  end;

procedure apSet(const ButtonRec: TButtonRec);
begin
  AddStack('ButForms.apSet');
  with ButtonRec do begin
    LsArrFill(aPrm[btnType],ap,UnDelim);
    case btnType of
      btnStandart: begin
        if empty(ap[1]) then ap[1]:='3';
        if empty(ap[2]) then ap[2]:='0';
        if empty(ap[3]) then ap[3]:='да';
      end;
      btnEllipse: begin
        if empty(ap[1]) then ap[1]:='да';
      end;
      btnDown: begin
        if empty(ap[1]) then ap[1]:='1';
        if empty(ap[2]) then ap[2]:='5';
        if empty(ap[3]) then ap[3]:='3';
        if empty(ap[4]) then ap[4]:='0';
        if empty(ap[5]) then ap[5]:='нет';
        if empty(ap[6]) then ap[6]:='да';
        if empty(ap[7]) then ap[7]:='да';
        if empty(ap[8]) then ap[8]:='да';
      end;
      btnSwitch: begin
        if empty(ap[1]) then ap[1]:='0';
        if empty(ap[2]) then ap[2]:='0';
        if empty(ap[3]) then ap[3]:='60';
        if empty(ap[4]) then ap[4]:='5';
        if empty(ap[5]) then ap[5]:='нет';
        if empty(ap[6]) then ap[6]:='да';
      end;
      btnBullet: begin
        if empty(ap[1]) then ap[1]:='2';
        if empty(ap[2]) then ap[2]:='0';
        if empty(ap[3]) then ap[3]:='Влево';
        if empty(ap[4]) then ap[4]:='да';
      end;
      btnRounded: begin
        if empty(ap[1]) then ap[1]:='Выпуклый';
        if empty(ap[2]) then ap[2]:='10';
        if empty(ap[3]) then ap[3]:='10';
        if empty(ap[4]) then ap[4]:='да';
      end;
      btnPoly: begin
        if empty(ap[1]) then ap[1]:=aPolyButNmType[1];
        if empty(ap[2]) then ap[2]:='0';
        if empty(ap[3]) then ap[3]:='0';
        if empty(ap[4]) then ap[4]:='да';
        if empty(ap[5]) then ap[5]:='10';
        if empty(ap[6]) then ap[6]:='нет';
        if empty(ap[7]) then ap[7]:='оба';
      end;
      btnTumb: begin
        if empty(ap[1]) then ap[1]:='нет';
        if empty(ap[2]) then ap[2]:='вдавлена';
        if empty(ap[3]) then ap[3]:='7';
        if empty(ap[4]) then ap[4]:='7';
        if empty(ap[5]) then ap[5]:='3';
        if empty(ap[6]) then ap[6]:='3';
        if empty(ap[7]) then ap[7]:='справа';
      end;
    end;
  end;
  DelStack;
end;

procedure GetButton(Canvas: TCanvas; const FirstPos: TPoint; const txtAction,txtHotKey: String;
	Opt: TButtonOpt; var result: TSize; const GlobButtonRec: TButtonRec;
  bm: TBitMap = nil);
var ActionText,HotKeyText: string;
  sze: TSize;
  
  procedure GetSize;
  var lDown,lWinAct: boolean;
  begin
    AddStack('ButForms.GetButton.GetSize');
    ZeroMemory(@result,SizeOf(result));
    with GlobButtonRec do begin
      for lDown:=false to true do
        for lWinAct:=false to true do begin
          DefFontToFont(aFont[aAtr[lDown,lWinAct]],Canvas.Font); MaxSelf(result,Canvas,ActionText);
        end;
      DefFontToFont(aFont[btfHotKey],Canvas.Font); sze:=Canvas.TextExtent(HotKeyText);
    end;
    DelStack;
  end;

  var Atr: TButtonAtrType;

  function clBtn(lEq: boolean): TColor;
  begin
    result := aclBtn[(butDown in Opt) = lEq];
  end;

  function CoSinus(x,a,b: Real):Real;
  begin
    AddStack('ButForms.GetButton.CoSinus');
    CoSinus:=a*cos(x)+b;
    DelStack;
  end;

  procedure EllipseBut;
  const alpha=15;
  var wt,ht,a,b,mx,my,dx,dy,hpos: longint;
    r,rt: TRect;
    ang: Real;
    fil: Boolean;
  begin
    { Расчёт прямоугольника для эллипса }
    AddStack('ButForms.GetButton.EllipseBut');
    with GlobButtonRec do begin
      { Рисование }
      if Assigned(bm) then begin
        fil := ap[1]='да';
        bm.Canvas.Brush.Color:=aColor[btfHotKey];
        if result.cX>bm.Width then bm.Width:=result.cX;
        if result.cY+2>bm.Height then bm.Height:=result.cY+2;
        r.left:=0; r.Top:=0; r.Right:=bm.Width; r.Bottom:=bm.Height;
        bm.Canvas.FillRect(r);
        With bm.Canvas do
        begin
          DefFontToFont(aFont[btfHotKey],Font);
          hpos:=TextHeight(HotKeyText);
          b:=(result.cY-2*Width-hpos) div 2;
          ht:=2*nround(b/sqrt(2));
          a:=(result.cX-2*Width) div 2;
          wt:=2*nround(a/sqrt(2));
          r.Left:=Width;
          r.Top:=Width+IfThen(not UnderBut,hpos);
          r.Right:=r.Left+2*a;
          r.Bottom:=r.Top+2*b;
          { 'Окантовка' }
          rt.TopLeft:=Point(r.Left-Width,r.Top-Width);
          rt.BottomRight:=Point(r.Right+Width,r.Bottom+Width);
          mx:=(rt.Right-rt.Left)div 2;
          my:=(rt.Bottom-rt.Top)div 2;
          ang:=ArcTan(sqrt(my/(mx*alpha)));
          dx:=nround(my/Tan(ang));
          dy:=nround(mx*Tan(ang));
          if dx>mx then dx:=mx;
          if dy>my then dy:=my;
          Pen.Color:=clBtn(false);
          Brush.Color:=Pen.Color;
          Chord(rt.Left,rt.Top,rt.Right,rt.Bottom,rt.Left+mx+dx,rt.Bottom-my-dy,rt.Right-mx-dx,rt.Top+my+dy);
          Pen.Color:=clBtn(true);
          Brush.Color:=Pen.Color;
          Chord(rt.Left,rt.Top,rt.Right,rt.Bottom,rt.Right-mx-dx,rt.Top+my+dy,rt.Left+mx+dx,rt.Bottom-my-dy);
          { Эллипс и тексты }
          Pen.Color:=aColor[Atr];
          Brush.Color:=IfThen(fil,Pen.Color,aColor[btfHotKey]);
          Ellipse(r);
          mx:=(r.Left+r.Right)div 2;
          my:=(r.Top+r.Bottom)div 2;
          rt.Left:=mx-(wt div 2); rt.Top:=my-(ht div 2);
          rt.Right:=mx+(wt div 2); rt.Bottom:=my+(ht div 2);
          DefFontToFont(aFont[Atr],Font);
          sze:=TextExtent(ActionText);
          TextOut(rt.Left+(rt.Right-rt.Left-sze.cx)div 2,rt.top+(rt.Bottom-rt.Top-sze.cy)div 2,ActionText);
          DefFontToFont(aFont[btfHotKey],Font);
          sze:=TextExtent(HotKeyText);
          Brush.Color:=aColor[btfHotKey];
          Dec(r.Left,Width); Inc(r.Right,Width);
          case Alignment of
            taLeftJustify: hpos:=r.Left;
            taRightJustify: hpos:=r.Right-sze.cx;
            taCenter: hpos:=r.Left+((r.Right-r.Left-sze.cx)div 2);
          end;
          TextOut(hpos,IfThen(UnderBut,r.Bottom+Width,r.top-(Width+sze.cy)),HotKeyText);
        end;
        r.Left:=0; r.Top:=0;
        r.Right:=r.Left+result.cX;
        r.Bottom:=r.Top+result.cY;
        rt.Left:=FirstPos.x; rt.Top:=FirstPos.y;
        rt.Right:=rt.Left+result.cX;
        rt.Bottom:=rt.Top+result.cY;
        Canvas.CopyRect(rt,bm.Canvas,r);
      end
      else begin
        GetSize;
        a:=nround(result.cx/sqrt(2));
        b:=nround(result.cy/sqrt(2));
        WinSize(result,max(sze.cx,2*a+2*Width),sze.cy+2*b+2*Width);
      end;
    end;
    DelStack;
  end;

  procedure StandartBut;
  var ht,horz,vert,hpos: longint;
    r,rt: TRect;
    fil: Boolean;
  begin
    AddStack('ButForms.GetButton.StandartBut');
    { Расчёт прямоугольника }
    horz:=Int0(ap[1]);
    vert:=Int0(ap[2]);
    with GlobButtonRec do
      { Рисование }
      if Assigned(bm) then begin
        fil := ap[3]='да';
        bm.Canvas.Brush.Color:=aColor[btfHotKey];
        if result.cX>bm.Width then bm.Width:=result.cX;
        if result.cY+2>bm.Height then bm.Height:=result.cY+2;
        r.left:=0; r.Top:=0; r.Right:=bm.Width; r.Bottom:=bm.Height;
        bm.Canvas.FillRect(r);
        bm.Canvas.Brush.Color:=aColor[btfHotKey];
        DefFontToFont(aFont[btfHotKey],bm.Canvas.Font);
        hpos:=bm.Canvas.TextHeight(HotKeyText);
        ht:=result.cY-2*Width-hpos;
        r.Left:=0;
        r.Top:=IfThen(not UnderBut,hpos);
        r.Right:=r.Left+result.cX;
        r.Bottom:=r.Top+ht+2*Width;
        { Кнопка и тексты }
        Frame3D1(bm.Canvas,r,butDown in Opt,Width);
        DefFontToFont(aFont[Atr],bm.Canvas.Font);
        bm.Canvas.Pen.Color:=aColor[Atr];
        if fil then begin
          bm.Canvas.Brush.Color:=bm.Canvas.Pen.Color;
          bm.Canvas.Rectangle(r);
        end;
        sze:=bm.Canvas.TextExtent(ActionText);
        bm.Canvas.TextOut(r.Left+(r.Right-r.Left-sze.cx)div 2,r.top+(r.Bottom-r.Top-sze.cy)div 2,ActionText);
        if not fil then begin
          bm.Canvas.Brush.Color:=bm.Canvas.Pen.Color;
          bm.Canvas.FrameRect(r);
        end;
        DefFontToFont(aFont[btfHotKey],bm.Canvas.Font);
        sze:=bm.Canvas.TextExtent(HotKeyText);
        bm.Canvas.Brush.Color:=aColor[btfHotKey];
        Dec(r.Left,Width); Inc(r.Right,Width);
        case Alignment of
          taLeftJustify: hpos:=r.Left;
          taRightJustify: hpos:=r.Right-sze.cx;
          taCenter: hpos:=r.Left+((r.Right-r.Left-sze.cx)div 2);
        end;
        bm.Canvas.TextOut(hpos,IfThen(UnderBut,r.Bottom+Width,r.top-(Width+sze.cy)),HotKeyText);
        r.Left:=0; r.Top:=0;
        r.Right:=r.Left+result.cX;
        r.Bottom:=r.Top+result.cY;
        rt.Left:=FirstPos.x; rt.Top:=FirstPos.y;
        rt.Right:=rt.Left+result.cX;
        rt.Bottom:=rt.Top+result.cY;
        Canvas.CopyRect(rt,bm.Canvas,r);
      end
      else begin
        GetSize;
        MaxSelf(result.cx,sze.cx);
        Inc(result.cX,2*Width+2*horz);
        Inc(result.cY,2*Width+sze.cy+2*vert);
      end;
    DelStack;
  end;

  procedure DownParabolaBut;
  var wt,ht,xe,ye,i,j,{mx,my,}w,h,horz,vert,kf,snpr,hpos: longint;
    r,rt: TRect;
    a,b,step,k,xj,yj,tj,dx: Double;
    pix: array [0..2*n+1] of TPoint;
    fil: Boolean;
  begin
    AddStack('ButForms.GetButton.DownParabolaBut');
    h:=Int0(ap[2]);
    horz:=Int0(ap[3]);
    vert:=Int0(ap[4]);
    { Расчёт прямоугольника }
    with GlobButtonRec do begin
      if Assigned(bm) then
      begin
        w:=Int0(ap[1]);
        kf:=aSign[ap[5]='да'];
        dx:=IfThen(ap[6]<>'да',pi/2);
        snpr:=aSign[ap[7]='да'];
        fil := ap[8]='да';
        bm.Canvas.Brush.Color:=aColor[btfHotKey];
        if result.cX>bm.Width then bm.Width:=result.cX;
        if result.cY+2>bm.Height then bm.Height:=result.cY+2;
        r.left:=0; r.Top:=0; r.Right:=bm.Width; r.Bottom:=bm.Height;
        bm.Canvas.FillRect(r);
        With bm.Canvas do
        begin
          k:=h/2;
          DefFontToFont(aFont[btfHotKey],Font);
          hpos:=TextHeight(HotKeyText);
          ht:=result.cY-2*Width-2*h-hpos-2*vert;
          wt:=result.cX-2*Width-2*horz;
          r.Left:=Width;
          r.Top:=Width+h+IfThen(not UnderBut,hpos);
          r.Right:=r.Left+wt+2*horz;
          r.Bottom:=r.Top+ht+2*vert;
          { Кнопка и тексты }
          a:=-(wt/2)-horz; b:=wt/2+horz;
          i:=Width;
          While i>=0 do
          begin
            IncD(a,-i); IncD(b,i);
            step:=(b-a)/n;
            if i>0 then begin
              Pen.Color:=clBtn(false);
              Brush.Color:=Pen.Color;
              tj:=2*pi*w*(a+i)/(b-a-2*i)+dx;
              xe:=nround(a+i+horz+Width+wt/2);
              if UnderBut then hpos:=0 else hpos:=TextHeight(HotKeyText);
              ye:=nround(-CoSinus(tj,snpr*kf*k,-(3*h/2+ht))+(Width+hpos+2*vert));
              pix[0]:=Point(xe,ye);
              tj:=2*pi*w*a/(b-a)+dx;
              xe:=nround(a+horz+Width+wt/2);
              ye:=nround(-CoSinus(tj,snpr*kf*k,-(3*h/2+ht)-i)+(Width+hpos+2*vert));
              pix[1]:=Point(xe,ye);
              for j:=0 to n do
              begin
                xj:=a+j*step;
                tj:=2*pi*w*xj/(b-a)+dx;
                yj:=CoSinus(tj,kf*k,-h/2+i);
                xe:=nround(xj+horz+Width+wt/2);
                ye:=nround(-yj+(Width+hpos));
                pix[j+2]:=Point(xe,ye);
              end;
              tj:=2*pi*w*(b-i)/(b-a-2*i)+dx;
              yj:=CoSinus(tj,kf*k,-h/2);
              xe:=nround(b-i+horz+Width+wt/2);
              ye:=nround(-yj+(Width+hpos));
              pix[n+3]:=Point(xe,ye);
              Polygon(Slice(pix,n+4));
              Pen.Color:=clBtn(true);
              Brush.Color:=Pen.Color;
              tj:=2*pi*w*(b-i)/(b-a-2*i)+dx;
              xe:=nround(b-i+horz+Width+wt/2);
              ye:=nround(-CoSinus(tj,kf*k,-h/2)+(Width+hpos));
              pix[0]:=Point(xe,ye);
              tj:=2*pi*w*b/(b-a)+dx;
              xe:=nround(b+horz+Width+wt/2);
              ye:=nround(-CoSinus(tj,kf*k,-h/2+i)+(Width+hpos));
              pix[1]:=Point(xe,ye);
              for j:=n downto 0 do
              begin
                xj:=a+j*step;
                tj:=2*pi*w*xj/(b-a)+dx;
                yj:=CoSinus(tj,snpr*kf*k,-(3*h/2+ht)-i);
                xe:=nround(xj+horz+Width+wt/2);
                ye:=nround(-yj+(Width+hpos+2*vert));
                pix[n+2-j]:=Point(xe,ye);
              end;
              tj:=2*pi*w*(a+i)/(b-a-2*i)+dx;
              yj:=CoSinus(tj,snpr*kf*k,-(3*h/2+ht));
              xe:=nround(a+i+horz+Width+wt/2);
              ye:=nround(-yj+(Width+hpos+2*vert));
              pix[n+3]:=Point(xe,ye);
              Polygon(Slice(pix,n+4));
            end
            else begin
              Pen.Color:=aColor[Atr];
              Brush.Color:=IfThen(fil,Pen.Color,aColor[btfHotKey]);
              for j:=0 to n do
              begin
                xj:=a+j*step;
                tj:=2*pi*w*xj/(b-a)+dx;
                yj:=CoSinus(tj,kf*k,-h/2);
                xe:=nround(xj+horz+Width+wt/2);
                ye:=nround(-yj+(Width+hpos));
                pix[j]:=Point(xe,ye);
              end;
              for j:=n downto 0 do
              begin
                xj:=a+j*step;
                tj:=2*pi*w*xj/(b-a)+dx;
                yj:=CoSinus(tj,snpr*kf*k,-(3*h/2+ht));
                xe:=nround(xj+horz+Width+wt/2);
                ye:=nround(-yj+(Width+hpos+2*vert));
                pix[2*n+1-j]:=Point(xe,ye);
              end;
              Polygon(pix);
              {mx:=(r.Left+r.Right)div 2;
              my:=(r.Top+r.Bottom)div 2;}
              DefFontToFont(aFont[Atr],Font);
              sze:=TextExtent(ActionText);
              TextOut(r.Left+(r.Right-r.Left-sze.cx)div 2,r.top+(r.Bottom-r.Top-sze.cy)div 2,ActionText);
              DefFontToFont(aFont[btfHotKey],Font);
              sze:=TextExtent(HotKeyText);
              Brush.Color:=aColor[btfHotKey];
              Dec(r.Left,Width); Inc(r.Right,Width);
              case Alignment of
                taLeftJustify: hpos:=r.Left;
                taRightJustify: hpos:=r.Right-sze.cx;
                taCenter: hpos:=r.Left+((r.Right-r.Left-sze.cx)div 2);
              else hpos:=0;
              end;
              TextOut(hpos,IfThen(UnderBut,r.Bottom+Width+h,r.top-(Width+sze.cy+h)),HotKeyText);
            end;
            IncD(a,i); IncD(b,-i); Dec(i,max(1,Width));
          end;
        end;
        r.Left:=0; r.Top:=0;
        r.Right:=r.Left+result.cX;
        r.Bottom:=r.Top+result.cY;
        rt.Left:=FirstPos.x; rt.Top:=FirstPos.y;
        rt.Right:=rt.Left+result.cX;
        rt.Bottom:=rt.Top+result.cY;
        Canvas.CopyRect(rt,bm.Canvas,r);
      end
      else begin
        GetSize;
        MaxSelf(result.cx,sze.cx);
        Inc(result.cX,2*Width+2*horz);
        Inc(result.cY,2*h+2*Width+sze.cy+2*vert);
      end;
    end;
    DelStack;
  end;

  procedure SwitchBut;
  var wt,ht,addht,{mx,my,}horz,vert,{h,}hpos,{ang,}hdx,kdx,dx: longint;
    r,rt: TRect;
    //p: TPoint;
    pix: array [0..4] of TPoint;
    //k: Real;
    rot,fil,log: boolean;
  begin
    AddStack('ButForms.GetButton.SwitchBut');
    { Расчёт прямоугольника }
    horz:=Int0(ap[1]);
    vert:=Int0(ap[2]);
    dx:=Int0(ap[3]);
    addht:=Int0(ap[4]);
    with GlobButtonRec do
      { Рисование }
      if Assigned(bm) then
      begin
        rot := ap[5]='да';
        fil := ap[6]='да';
        bm.Canvas.Brush.Color:=aColor[btfHotKey];
        if result.cX>bm.Width then bm.Width:=result.cX;
        if result.cY+2>bm.Height then bm.Height:=result.cY+2;
        r.left:=0; r.Top:=0; r.Right:=bm.Width; r.Bottom:=bm.Height;
        bm.Canvas.FillRect(r);
        With bm.Canvas do
        begin
          DefFontToFont(aFont[btfHotKey],Font);
          hpos:=TextHeight(HotKeyText);
          ht:=result.cY-2*Width-hpos-addht-2*vert;
          hdx:=nround(Width*(1+(dx/ht)));
          wt:=result.cX-2*hdx;
          r.Left:=hdx;
          r.Right:=r.Left+wt;
          log := (butDown in Opt) <> rot;
          r.Top:=Width+IfThen(log,addht)+IfThen(not UnderBut,hpos);
          r.Bottom:=r.Top+ht+2*vert;
          { Кнопка и тексты }
          rt.TopLeft:=Point(r.Left-hdx,r.Top-Width);
          rt.BottomRight:=Point(r.Right+hdx,r.Bottom+Width);
          kdx:=nround(dx*(rt.Bottom-rt.Top)/(r.Bottom-r.Top));
          Pen.Color:=aclBtn[true];
          if log then
          begin
            pix[0]:=Point(r.Left+dx,r.Bottom);
            pix[1]:=Point(rt.Left+kdx,rt.Bottom);
            pix[2]:=Point(rt.Left,rt.Top);
            pix[3]:=Point(rt.Right,rt.Top);
            pix[4]:=Point(r.Right,r.Top);
          end
          else
          begin
            pix[0]:=Point(r.Left,r.Bottom);
            pix[1]:=Point(rt.Left,rt.Bottom);
            pix[2]:=Point(rt.Left+kdx,rt.Top);
            pix[3]:=Point(rt.Right-kdx,rt.Top);
            pix[4]:=Point(r.Right-dx,r.Top);
          end;
          Brush.Color:=Pen.Color;
          Polygon(pix);
          Pen.Color:=aclBtn[false];
          if log then
          begin
            pix[0]:=Point(r.Right,r.Top);
            pix[1]:=Point(rt.Right,rt.Top);
            pix[2]:=Point(rt.Right-kdx,rt.Bottom);
            pix[3]:=Point(rt.Left+kdx,rt.Bottom);
            pix[4]:=Point(r.Left+dx,r.Bottom);
          end
          else
          begin
            pix[0]:=Point(r.Right-dx,r.Top);
            pix[1]:=Point(rt.Right-kdx,rt.Top);
            pix[2]:=Point(rt.Right,rt.Bottom);
            pix[3]:=Point(rt.Left,rt.Bottom);
            pix[4]:=Point(r.Left,r.Bottom);
          end;
          Brush.Color:=Pen.Color;
          Polygon(pix);
          Pen.Color:=aColor[Atr];
          Brush.Color:=IfThen(fil,Pen.Color,aColor[btfHotKey]);
          if log then
          begin
            pix[0]:=Point(r.Left,r.Top);
            pix[1]:=Point(r.Right,r.Top);
            pix[2]:=Point(r.Right-dx,r.Bottom);
            pix[3]:=Point(r.Left+dx,r.Bottom);
          end
          else
          begin
            pix[0]:=Point(r.Left+dx,r.Top);
            pix[1]:=Point(r.Right-dx,r.Top);
            pix[2]:=Point(r.Right,r.Bottom);
            pix[3]:=Point(r.Left,r.Bottom);
          end;
          Polygon(Slice(pix,4));
          DefFontToFont(aFont[Atr],Font);
          sze:=TextExtent(ActionText);
          TextOut(r.Left+(r.Right-r.Left-sze.cx)div 2,r.top+(r.Bottom-r.Top-sze.cy)div 2,ActionText);
          PolyLine([pix[0],pix[1],pix[2],pix[3],pix[0]]);
          DefFontToFont(aFont[btfHotKey],Font);
          sze:=TextExtent(HotKeyText);
          Brush.Color:=aColor[btfHotKey];
          case Alignment of
            taLeftJustify: hpos:=rt.Left;
            taRightJustify: hpos:=rt.Right-sze.cx;
            taCenter: hpos:=rt.Left+((rt.Right-rt.Left-sze.cx)div 2);
          else hpos:=0;
          end;
          TextOut(hpos,IfThen(UnderBut,rt.Bottom+IfThen(not log,addht),rt.top-IfThen(log,addht)-sze.cy),HotKeyText);
          Pen.Color:=IfThen((butDown in Opt)=rot,clBackground,clBtnShadow);
          Brush.Color:=Pen.Color;
          if log then
          begin
            pix[0]:=Point(rt.Left,rt.Top);
            pix[1]:=Point(rt.Right,rt.Top);
            pix[2]:=Point(rt.Right-addht,rt.Top-addht);
            pix[3]:=Point(rt.Left+addht,rt.Top-addht);
          end
          else
          begin
            pix[0]:=Point(rt.Left,rt.Bottom);
            pix[1]:=Point(rt.Right,rt.Bottom);
            pix[2]:=Point(rt.Right-addht,rt.Bottom+addht);
            pix[3]:=Point(rt.Left+addht,rt.Bottom+addht);
          end;
          Polygon(Slice(pix,4));
        end;
        r.Left:=0; r.Top:=0;
        r.Right:=r.Left+result.cX;
        r.Bottom:=r.Top+result.cY;
        rt.Left:=FirstPos.x; rt.Top:=FirstPos.y;
        rt.Right:=rt.Left+result.cX;
        rt.Bottom:=rt.Top+result.cY;
        Canvas.CopyRect(rt,bm.Canvas,r);
      end
      else begin
        GetSize;
        hdx:=nround(Width*(1+(dx/result.cy)));
        Inc(result.cX,2*(hdx+dx+horz)); MaxSelf(result.cx,sze.cx);
        Inc(result.cY,2*Width+sze.cy+addht+2*vert);
      end;
    DelStack;
  end;

  procedure BulletBut;
  const h=4;
  var wt,ht,a,b,mx,my,horz,vert,hpos: longint;
    r,rt: TRect;
    pix: array[1..6] of TPoint;
    ldir,fil: Boolean;
  begin
    { Расчёт прямоугольника для эллипса }
    AddStack('ButForms.GetButton.BulletBut');
    with GlobButtonRec do begin
      { Рисование }
      horz:=Int0(ap[1]);
      vert:=Int0(ap[2]);
      if Assigned(bm) then
      begin
        ldir := ap[3]='Влево';
        fil := ap[4]='да';
        bm.Canvas.Brush.Color:=aColor[btfHotKey];
        if result.cX>bm.Width then bm.Width:=result.cX;
        if result.cY+2>bm.Height then bm.Height:=result.cY+2;
        r.left:=0; r.Top:=0; r.Right:=bm.Width; r.Bottom:=bm.Height;
        bm.Canvas.FillRect(r);
        With bm.Canvas do
        begin
          DefFontToFont(aFont[btfHotKey],Font);
          hpos:=TextHeight(HotKeyText);
          b:=(result.cY-2*Width-hpos) div 2;
          a:=((result.cX-2*Width) div 2);
          wt:=2*nround(a/sqrt(2));
          r.Left:=Width;
          r.Top:=Width+IfThen(not UnderBut,hpos);
          r.Right:=r.Left+2*a;
          r.Bottom:=r.Top+2*b;
          { 'Окантовка' }
          rt.TopLeft:=Point(r.Left-Width,r.Top-Width);
          rt.BottomRight:=Point(r.Right+Width,r.Bottom+Width);
          mx:=(rt.Left+rt.Right)div 2;
          my:=(rt.Bottom+rt.Top)div 2;
          Pen.Color:=clBtn(false);
          Brush.Color:=Pen.Color;
          if ldir then
          begin
            Chord(rt.Left,rt.Top,rt.Right,rt.Bottom,mx,rt.Top,rt.Left,my);
            pix[1]:=Point(mx,rt.Top);
            pix[2]:=Point(rt.Right-h,rt.Top);
            pix[3]:=Point(rt.Right,rt.Top+h);
            pix[4]:=Point(rt.Left,my);
            Polygon(Slice(pix,4));
          end
          else
          begin
            Chord(rt.Left,rt.Top,rt.Right,rt.Bottom,rt.Right,my,mx,rt.Top);
            pix[1]:=Point(mx,rt.Top);
            pix[2]:=Point(rt.Left+h,rt.Top);
            pix[3]:=Point(rt.Left,rt.Top+h);
            pix[4]:=Point(rt.Left,rt.Bottom-h);
            pix[5]:=Point(rt.Right,my);
            Polygon(Slice(pix,5));
          end;
          Pen.Color:=clBtn(true);
          Brush.Color:=Pen.Color;
          if ldir then
          begin
            Chord(rt.Left,rt.Top,rt.Right,rt.Bottom,rt.Left,my,mx,rt.Bottom);
            pix[1]:=Point(mx,rt.Bottom);
            pix[2]:=Point(rt.Right-h,rt.Bottom);
            pix[3]:=Point(rt.Right,rt.Bottom-h);
            pix[4]:=Point(rt.Right,rt.Top+h);
            pix[5]:=Point(rt.Left,my);
            Polygon(Slice(pix,5));
          end
          else
          begin
            Chord(rt.Left,rt.Top,rt.Right,rt.Bottom,mx,rt.Bottom,rt.Right,my);
            pix[1]:=Point(mx,rt.Bottom);
            pix[2]:=Point(rt.Left+h,rt.Bottom);
            pix[3]:=Point(rt.Left,rt.Bottom-h);
            pix[4]:=Point(rt.Right,my);
            Polygon(Slice(pix,4));
          end;
          { Пуля и тексты }
          Pen.Color:=aColor[Atr];
          Brush.Color:=IfThen(fil,Pen.Color,aColor[btfHotKey]);
          mx:=(r.Left+r.Right)div 2;
          if ldir then
          begin
            Chord(r.Left,r.Top,r.Right,r.Bottom,mx,r.Top,mx,r.Bottom);
            pix[1]:=Point(mx,r.Top);
            pix[2]:=Point(r.Right-h,r.Top);
            pix[3]:=Point(r.Right,r.Top+h);
            pix[4]:=Point(r.Right,r.Bottom-h);
            pix[5]:=Point(r.Right-h,r.Bottom);
            pix[6]:=Point(mx,r.Bottom);
            Polygon(pix);
          end
          else
          begin
            Chord(r.Left,r.Top,r.Right,r.Bottom,mx,r.Bottom,mx,r.Top);
            pix[1]:=Point(mx,r.Top);
            pix[2]:=Point(r.Left+h,r.Top);
            pix[3]:=Point(r.Left,r.Top+h);
            pix[4]:=Point(r.Left,r.Bottom-h);
            pix[5]:=Point(r.Left+h,r.Bottom);
            pix[6]:=Point(mx,r.Bottom);
            Polygon(pix);
          end;
          if not fil then
          begin
            Pen.Color:=aColor[btfHotKey];
            pix[1]:=Point(mx,r.Top);
            pix[2]:=Point(mx,r.Bottom);
            Polyline(Slice(pix,2));
          end;
          rt.Left:=IfThen(ldir,r.Right-wt-horz,r.Left); rt.Top:=r.Top;
          rt.Right:=IfThen(ldir,r.Right,r.Left+wt+horz); rt.Bottom:=r.Bottom;
          DefFontToFont(aFont[Atr],Font);
          sze:=TextExtent(ActionText);
          TextOut(rt.Left+(rt.Right-rt.Left-sze.cx)div 2,rt.top+(rt.Bottom-rt.Top-sze.cy)div 2,ActionText);
          DefFontToFont(aFont[btfHotKey],Font);
          sze:=TextExtent(HotKeyText);
          Brush.Color:=aColor[btfHotKey];
          Dec(r.Left,Width); Inc(r.Right,Width);
          case Alignment of
            taLeftJustify: hpos:=r.Left;
            taRightJustify: hpos:=r.Right-sze.cx;
            taCenter: hpos:=r.Left+((r.Right-r.Left-sze.cx)div 2);
          else hpos:=0;
          end;
          TextOut(hpos,IfThen(UnderBut,r.Bottom+Width,r.top-(Width+sze.cy)),HotKeyText);
        end;
        r.Left:=0; r.Top:=0;
        r.Right:=r.Left+result.cX;
        r.Bottom:=r.Top+result.cY;
        rt.Left:=FirstPos.x; rt.Top:=FirstPos.y;
        rt.Right:=rt.Left+result.cX;
        rt.Bottom:=rt.Top+result.cY;
        Canvas.CopyRect(rt,bm.Canvas,r);
      end
      else begin
        GetSize;
        a:=nround((result.cx+2*horz)/sqrt(2));
        b:=nround((result.cy+2*vert)/sqrt(2));
        WinSize(result,max(sze.cx,2*a+2*Width),sze.cY+2*b+2*Width);
      end;
    end;
    DelStack;
  end;

  procedure RoundedBut;
  var wt,ht,{a,b,}mx,my,i,hh,hv,hpos{,j}: longint;
    //t: Real;
    r,rt: TRect;
    ldir,fil: Boolean;
  begin
    { Расчёт прямоугольника для эллипса }
    AddStack('ButForms.GetButton.RoundedBut');
    with GlobButtonRec do begin
      { Рисование }
      hh:=Int0(ap[2]);
      hv:=Int0(ap[3]);
      fil := ap[4]='да';
      if Assigned(bm) then
      begin
        ldir := ap[1]='Выпуклый';
        bm.Canvas.Brush.Color:=aColor[btfHotKey];
        if result.cX>bm.Width then bm.Width:=result.cX;
        if result.cY>bm.Height then bm.Height:=result.cY;
        r.left:=0; r.Top:=0; r.Right:=bm.Width; r.Bottom:=bm.Height;
        bm.Canvas.FillRect(r);
        With bm.Canvas do
        begin
          DefFontToFont(aFont[btfHotKey],Font);
          wt:=result.cX-2*(Width+hh);
          hpos:=TextHeight(HotKeyText);
          ht:=result.cY-2*(Width+hv)-hpos;
          r.Left:=Width;
          r.Top:=Width+IfThen(not UnderBut,hpos);
          r.Right:=r.Left+wt+2*hh;
          r.Bottom:=r.Top+ht+2*hv;
          { 'Окантовка' }
          for i:=Width downto 1 do
          begin
            rt.TopLeft:=Point(r.Left-i,r.Top-i);
            rt.BottomRight:=Point(r.Right+i,r.Bottom+i);
            Pen.Color:=clBtn(false);
            if ldir then
            begin
              PolyLine([Point(rt.Right,rt.Bottom-hv),Point(rt.Right,rt.Top+hv)]);
              Arc(rt.Right-2*hh,rt.Top,rt.Right,rt.Top+2*hv,rt.Right,rt.Top+hv,rt.Right-hh,rt.Top);
              PolyLine([Point(rt.Right-hh,rt.Top),Point(rt.Left+hh,rt.Top)]);
              Arc(rt.Left,rt.Top,rt.Left+2*hh,rt.Top+2*hv,rt.Left+hh,rt.Top,rt.Left,rt.Top+hv);
            end
            else
            begin
              Arc(rt.Left-hh,rt.Top-hv,rt.Left+hh,rt.Top+hv,rt.Left,rt.Top+hv,rt.Left+hh,rt.Top);
              PolyLine([Point(rt.Left+hh,rt.Top),Point(rt.Right-hh,rt.Top)]);
              Arc(rt.Right-hh,rt.Top-hv,rt.Right+hh,rt.Top+hv,rt.Right-hh,rt.Top,rt.Right,rt.Top+hv);
              PolyLine([Point(rt.Right,rt.Top+hv),Point(rt.Right,rt.Bottom-hv)]);
            end;
            Pen.Color:=clBtn(true);
            if ldir then
            begin
              PolyLine([Point(rt.Left,rt.Top+hv),Point(rt.Left,rt.Bottom-hv)]);
              Arc(rt.Left,rt.Bottom-2*hv,rt.Left+2*hh,rt.Bottom,rt.Left,rt.Bottom-hv,rt.Left+hh,rt.Bottom);
              PolyLine([Point(rt.Left+hh,rt.Bottom),Point(rt.Right-hh,rt.Bottom)]);
              Arc(rt.Right-2*hh,rt.Bottom-2*hv,rt.Right,rt.Bottom,rt.Right-hh,rt.Bottom,rt.Right,rt.Bottom-hv);
            end
            else
            begin
              Arc(rt.Right-hh,rt.Bottom-hv,rt.Right+hh,rt.Bottom+hv,rt.Right,rt.Bottom-hv,rt.Right-hh,rt.Bottom);
              PolyLine([Point(rt.Right-hh,rt.Bottom),Point(rt.Left+hh,rt.Bottom)]);
              Arc(rt.Left-hh,rt.Bottom-hv,rt.Left+hh,rt.Bottom+hv,rt.Left+hh,rt.Bottom,rt.Left,rt.Bottom-hv);
              PolyLine([Point(rt.Left,rt.Bottom-hv),Point(rt.Left,rt.Top+hv)]);
            end;
          end;
          { Фигура и тексты }
          Pen.Color:=aColor[Atr];
          if fil then Brush.Color:=Pen.Color;
          mx:=(r.Left+r.Right)div 2;
          my:=(r.Top+r.Bottom)div 2;
          if ldir then
          begin
            PolyLine([Point(r.Right,r.Bottom-hv),Point(r.Right,r.Top+hv)]);
            Arc(r.Right-2*hh,r.Top,r.Right,r.Top+2*hv,r.Right,r.Top+hv,r.Right-hh,r.Top);
            PolyLine([Point(r.Right-hh,r.Top),Point(r.Left+hh,r.Top)]);
            Arc(r.Left,r.Top,r.Left+2*hh,r.Top+2*hv,r.Left+hh,r.Top,r.Left,r.Top+hv);
            PolyLine([Point(r.Left,r.Top+hv),Point(r.Left,r.Bottom-hv)]);
            Arc(r.Left,r.Bottom-2*hv,r.Left+2*hh,r.Bottom,r.Left,r.Bottom-hv,r.Left+hh,r.Bottom);
            PolyLine([Point(r.Left+hh,r.Bottom),Point(r.Right-hh,r.Bottom)]);
            Arc(r.Right-2*hh,r.Bottom-2*hv,r.Right,r.Bottom,r.Right-hh,r.Bottom,r.Right,r.Bottom-hv);
          end
          else
          begin
            Arc(r.Left-hh,r.Top-hv,r.Left+hh,r.Top+hv,r.Left,r.Top+hv,r.Left+hh,r.Top);
            PolyLine([Point(r.Left+hh,r.Top),Point(r.Right-hh,r.Top)]);
            PolyLine([Point(r.Left+hh,r.Top),Point(r.Left+hh,r.Top+(hv div 2))]);
            PolyLine([Point(r.Left+hh,r.Bottom),Point(r.Left+hh,r.Bottom-(hv div 2))]);
            Arc(r.Right-hh,r.Top-hv,r.Right+hh,r.Top+hv,r.Right-hh,r.Top,r.Right,r.Top+hv);
            PolyLine([Point(r.Right,r.Top+hv),Point(r.Right,r.Bottom-hv)]);
            PolyLine([Point(r.Left,r.Top+hv),Point(r.Left+(hh div 2),r.Top+hv)]);
            PolyLine([Point(r.Right,r.Top+hv),Point(r.Right-(hh div 2),r.Top+hv)]);
            Arc(r.Right-hh,r.Bottom-hv,r.Right+hh,r.Bottom+hv,r.Right,r.Bottom-hv,r.Right-hh,r.Bottom);
            PolyLine([Point(r.Right-hh,r.Bottom),Point(r.Left+hh,r.Bottom)]);
            PolyLine([Point(r.Right-hh,r.Top),Point(r.Right-hh,r.Top+(hv div 2))]);
            PolyLine([Point(r.Right-hh,r.Bottom),Point(r.Right-hh,r.Bottom-(hv div 2))]);
            Arc(r.Left-hh,r.Bottom-hv,r.Left+hh,r.Bottom+hv,r.Left+hh,r.Bottom,r.Left,r.Bottom-hv);
            PolyLine([Point(r.Left,r.Bottom-hv),Point(r.Left,r.Top+hv)]);
            PolyLine([Point(r.Left,r.Bottom-hv),Point(r.Left+(hh div 2),r.Bottom-hv)]);
            PolyLine([Point(r.Right,r.Bottom-hv),Point(r.Right-(hh div 2),r.Bottom-hv)]);
          end;
          if fil then FloodFill(mx,my,Pixels[mx,my],fsSurface);
          DefFontToFont(aFont[Atr],Font);
          sze:=TextExtent(ActionText);
          TextOut(r.Left+(r.Right-r.Left-sze.cx)div 2,r.top+(r.Bottom-r.Top-sze.cy)div 2,ActionText);
          DefFontToFont(aFont[btfHotKey],Font);
          sze:=TextExtent(HotKeyText);
          Brush.Color:=aColor[btfHotKey];
          Dec(r.Left,Width); Inc(r.Right,Width);
          case Alignment of
            taLeftJustify: hpos:=r.Left;
            taRightJustify: hpos:=r.Right-sze.cx;
            taCenter: hpos:=r.Left+((r.Right-r.Left-sze.cx)div 2);
          else hpos:=0;
          end;
          TextOut(hpos,IfThen(UnderBut,r.Bottom+Width,r.top-(Width+sze.cy)),HotKeyText);
        end;
        r.Left:=0; r.Top:=0;
        r.Right:=r.Left+result.cX;
        r.Bottom:=r.Top+result.cY;
        rt.Left:=FirstPos.x; rt.Top:=FirstPos.y;
        rt.Right:=rt.Left+result.cX;
        rt.Bottom:=rt.Top+result.cY;
        Canvas.CopyRect(rt,bm.Canvas,r);
      end
      else begin
        GetSize;
        Inc(result.cX,2*Width+2*hh); MaxSelf(result.cX,sze.cx);
        Inc(result.cY,2*Width+sze.cy+2*hv);
      end;
    end;
    DelStack;
  end;

  procedure PolygonBut;
  const hv=5;
  var wt,ht,mx,my,hh,hpos,fig,kdx,hdx,horz,vert,dx,dir: longint;
    r,rt: TRect;
    fil,rot: Boolean;
    pix: array [1..10] of TPoint;
  label lend;
  begin
    { Расчёт прямоугольника }
    AddStack('ButForms.GetButton.PolygonBut');
    with GlobButtonRec do begin
      { Рисование }
      AnsiFindText(ap[1],aPolyButNmType,low(aPolyButNmType),fig);
      horz:=int0(ap[2]);
      vert:=int0(ap[3]);
      dx:=int0(ap[5]);
      rot:=(ap[6]='да');
      fil:=(ap[4]='да');
      dir:=IfThen(ap[7]='оба',1,IfThen(ap[7]='влево',2,3));
      if Assigned(bm) then
      begin
        bm.Canvas.Brush.Color:=aColor[btfHotKey];
        if result.cX>bm.Width then bm.Width:=result.cX;
        if result.cY+2>bm.Height then bm.Height:=result.cY+2;
        r.left:=0; r.Top:=0; r.Right:=bm.Width; r.Bottom:=bm.Height;
        bm.Canvas.FillRect(r);
        With bm.Canvas do
        begin
          DefFontToFont(aFont[btfHotKey],Font);
          hpos:=TextHeight(HotKeyText);
          if not((fig=3)and(rot)) then
          begin
            ht:=result.cY-2*Width-hpos;
            hdx:=nround(IfThen(fig>1,Width*(1+(dx/ht)),Width*result.cX/result.cY));
            wt:=result.cX-2*hdx;
          end
          else
          begin
            wt:=result.cX-2*Width;
            hdx:=nround(Width*(1+(dx/wt)));
            ht:=result.cY-2*hdx-hpos;
          end;
          r.Left:=IfThen((fig=3)and(rot),Width,hdx);
          r.Top:=IfThen((fig=3)and(rot),hdx,Width)+IfThen(not UnderBut,hpos);
          r.Right:=r.Left+wt;
          r.Bottom:=r.Top+ht;
          { 'Окантовка' }
          rt.TopLeft:=Point(r.Left-IfThen((fig=3)and(rot),Width,hdx),r.Top-IfThen((fig=3)and(rot),hdx,Width));
          rt.BottomRight:=Point(r.Right+IfThen((fig=3)and(rot),Width,hdx),r.Bottom+IfThen((fig=3)and(rot),hdx,Width));
          kdx:=nround(dx*(rt.Bottom-rt.Top)/(r.Bottom-r.Top));
          mx:=(rt.Left+rt.Right)div 2;
          my:=(rt.Top+rt.Bottom)div 2;
          Pen.Color:=clBtn(false);
          Brush.Color:=Pen.Color;
          case fig of
            1: begin
              pix[1]:=Point(rt.Left,my);
              pix[2]:=Point(mx,rt.Top);
              pix[3]:=Point(rt.Right,my);
              Polygon(Slice(Pix,3));
            end;
            2: begin
              pix[1]:=Point(r.Left+IfThen(not rot,dx),r.Bottom);
              pix[2]:=Point(rt.Left+IfThen(not rot,kdx),rt.Bottom);
              pix[3]:=Point(rt.Left+IfThen(rot,kdx),rt.Top);
              pix[4]:=Point(rt.Right-IfThen(not rot,kdx),rt.Top);
              pix[5]:=Point(r.Right-IfThen(not rot,dx),r.Top);
              Polygon(Slice(Pix,5));
            end;
            3: case dir of
              1: begin
                pix[1]:=Point(r.Left+IfThen(not rot,dx),r.Bottom-IfThen(rot,dx));
                pix[2]:=Point(rt.Left+IfThen(not rot,kdx),rt.Bottom-IfThen(rot,kdx));
                pix[3]:=Point(rt.Left,IfThen(rot,rt.Top+kdx,my));
                pix[4]:=Point(IfThen(rot,mx,rt.Left+kdx),rt.Top);
                pix[5]:=Point(rt.Right-IfThen(not rot,kdx),rt.Top+IfThen(rot,kdx));
                pix[6]:=Point(r.Right-IfThen(not rot,dx),r.Top+IfThen(rot,dx));
                Polygon(Slice(Pix,6));
              end;
              2: begin
                pix[1]:=Point(r.Left+IfThen(not rot,dx),r.Bottom);
                pix[2]:=Point(rt.Left+IfThen(not rot,kdx),rt.Bottom);
                pix[3]:=Point(rt.Left,IfThen(rot,rt.Top+kdx,my));
                pix[4]:=Point(IfThen(rot,mx,rt.Left+kdx),rt.Top);
                pix[5]:=Point(rt.Right,rt.Top+IfThen(rot,kdx));
                pix[6]:=Point(r.Right,r.Top+IfThen(rot,dx));
                Polygon(Slice(Pix,6));
              end;
              3: begin
                pix[1]:=Point(IfThen(rot,mx,r.Left),r.Bottom);
                pix[2]:=Point(IfThen(rot,mx,rt.Left),rt.Bottom);
                pix[3]:=Point(rt.Left,IfThen(rot,rt.Bottom-kdx,rt.Top));
                pix[4]:=Point(IfThen(rot,rt.Left,rt.Right-kdx),rt.Top);
                pix[5]:=Point(rt.Right,IfThen(rot,rt.Top,my));
                pix[6]:=Point(r.Right,IfThen(rot,r.Top,my));
                Polygon(Slice(Pix,6));
              end;
            end;
          else goto lend;
          end;
          Pen.Color:=clBtn(true);
          Brush.Color:=Pen.Color;
          case fig of
            1: begin
              pix[1]:=Point(rt.Left,my);
              pix[2]:=Point(mx,rt.Bottom);
              pix[3]:=Point(rt.Right,my);
              Polygon(Slice(Pix,3));
            end;
            2: begin
              pix[1]:=Point(r.Right-IfThen(not rot,dx),r.Top);
              pix[2]:=Point(rt.Right-IfThen(not rot,kdx),rt.Top);
              pix[3]:=Point(rt.Right-IfThen(rot,kdx),rt.Bottom);
              pix[4]:=Point(rt.Left+IfThen(not rot,kdx),rt.Bottom);
              pix[5]:=Point(r.Left+IfThen(not rot,dx),r.Bottom);
              Polygon(Slice(Pix,5));
            end;
            3: case dir of
              1: begin
                pix[1]:=Point(r.Left+IfThen(not rot,dx),r.Bottom-IfThen(rot,dx));
                pix[2]:=Point(rt.Left+IfThen(not rot,kdx),rt.Bottom-IfThen(rot,kdx));
                pix[3]:=Point(IfThen(rot,mx,rt.Right-kdx),rt.Bottom);
                pix[4]:=Point(rt.Right,IfThen(rot,rt.Bottom-kdx,my));
                pix[5]:=Point(rt.Right-IfThen(not rot,kdx),rt.Top+IfThen(rot,kdx));
                pix[6]:=Point(r.Right-IfThen(not rot,dx),r.Top+IfThen(rot,dx));
                Polygon(Slice(Pix,6));
              end;
              2: begin
                pix[1]:=Point(r.Left+IfThen(not rot,dx),r.Bottom);
                pix[2]:=Point(rt.Left+IfThen(not rot,kdx),rt.Bottom);
                pix[3]:=Point(rt.Right,rt.Bottom);
                pix[4]:=Point(rt.Right,rt.Top+IfThen(rot,kdx));
                pix[5]:=Point(r.Right,r.Top+IfThen(rot,dx));
                Polygon(Slice(Pix,5));
              end;
              3: begin
                pix[1]:=Point(IfThen(rot,mx,r.Left),r.Bottom);
                pix[2]:=Point(IfThen(rot,mx,rt.Left),rt.Bottom);
                pix[3]:=Point(rt.Right-IfThen(not rot,kdx),rt.Bottom-IfThen(rot,kdx));
                pix[4]:=Point(rt.Right,IfThen(rot,rt.Top,my));
                pix[5]:=Point(r.Right,IfThen(rot,r.Top,my));
                Polygon(Slice(Pix,5));
              end;
            end;
          else goto lend;
          end;
          { Фигура и тексты }
          Pen.Color:=aColor[Atr];
          Brush.Color:=IfThen(fil,Pen.Color,aColor[btfHotKey]);
          mx:=(r.Left+r.Right)div 2;
          my:=(r.Top+r.Bottom)div 2;
          case fig of
            1: begin
              pix[1]:=Point(r.Left,my);
              pix[2]:=Point(mx,r.Top);
              pix[3]:=Point(r.Right,my);
              pix[4]:=Point(mx,r.Bottom);
              Polygon(Slice(Pix,4));
            end;
            2: begin
              pix[1]:=Point(r.Left+IfThen(not rot,dx),r.Bottom);
              pix[2]:=Point(r.Left+IfThen(rot,dx),r.Top);
              pix[3]:=Point(r.Right-IfThen(not rot,dx),r.Top);
              pix[4]:=Point(r.Right-IfThen(rot,dx),r.Bottom);
              Polygon(Slice(Pix,4));
            end;
            3: case dir of
              1: begin
                pix[1]:=Point(r.Left+IfThen(not rot,dx),r.Bottom-IfThen(rot,dx));
                pix[2]:=Point(r.Left,IfThen(rot,r.Top+dx,my));
                pix[3]:=Point(IfThen(rot,mx,r.Left+dx),r.Top);
                pix[4]:=Point(r.Right-IfThen(not rot,dx),r.Top+IfThen(rot,dx));
                pix[5]:=Point(r.Right,IfThen(rot,r.Bottom-dx,my));
                pix[6]:=Point(IfThen(rot,mx,r.Right-dx),r.Bottom);
                Polygon(Slice(Pix,6));
              end;
              2: begin
                pix[1]:=Point(r.Left,IfThen(rot,r.Bottom,my));
                pix[2]:=Point(r.Left+IfThen(not rot,dx),r.Top+IfThen(rot,dx));
                pix[3]:=Point(IfThen(rot,mx,r.Right),r.Top);
                pix[4]:=Point(r.Right,IfThen(rot,r.Top+dx,r.Bottom));
                pix[5]:=Point(IfThen(rot,r.Right,r.Left+dx),r.Bottom);
                Polygon(Slice(Pix,5));
              end;
              3: begin
                pix[1]:=Point(IfThen(rot,mx,r.Left),r.Bottom);
                pix[2]:=Point(r.Left,IfThen(rot,r.Bottom-dx,r.Top));
                pix[3]:=Point(IfThen(rot,r.Left,r.Right-dx),r.Top);
                pix[4]:=Point(r.Right,IfThen(rot,r.Top,my));
                pix[5]:=Point(r.Right-IfThen(not rot,dx),r.Bottom-IfThen(rot,dx));
                Polygon(Slice(Pix,5));
              end;
            end;
          else goto lend;
          end;
          DefFontToFont(aFont[Atr],Font);
          sze:=TextExtent(ActionText);
          rt.Left:=r.Left+IfThen((fig=3)and(not rot)and(dir=2),dx);
          rt.Right:=r.Right-IfThen((fig=3)and(not rot)and(dir=3),dx);
          rt.Top:=r.Top+IfThen((fig=3)and(rot)and(dir=2),dx);
          rt.Bottom:=r.Bottom-IfThen((fig=3)and(rot)and(dir=3),dx);
          TextOut(rt.Left+(rt.Right-rt.Left-sze.cx)div 2,rt.top+(rt.Bottom-rt.Top-sze.cy)div 2,ActionText);
          if fig<3 then
          Polyline([pix[1],pix[2],pix[3],pix[4],pix[1]])
          else
          if dir=1 then
            Polyline([pix[1],pix[2],pix[3],pix[4],pix[5],pix[6],pix[1]])
          else
            Polyline([pix[1],pix[2],pix[3],pix[4],pix[5],pix[1]]);
          DefFontToFont(aFont[btfHotKey],Font);
          sze:=TextExtent(HotKeyText);
          Brush.Color:=aColor[btfHotKey];
          Dec(r.Left,IfThen((fig=3)and(rot),Width,hdx)); Inc(r.Right,IfThen((fig=3)and(rot),Width,hdx));
          case Alignment of
            taLeftJustify: hpos:=r.Left;
            taRightJustify: hpos:=r.Right-sze.cx;
            taCenter: hpos:=r.Left+((r.Right-r.Left-sze.cx)div 2);
          else hpos:=0;
          end;
          TextOut(hpos,IfThen(UnderBut,r.Bottom+IfThen((fig=3)and(rot),hdx,Width),
          r.top-(IfThen((fig=3)and(rot),hdx,Width)+sze.cy)),HotKeyText);
        end;
        r.Left:=0; r.Top:=0;
        r.Right:=r.Left+result.cX;
        r.Bottom:=r.Top+result.cY;
        rt.Left:=FirstPos.x; rt.Top:=FirstPos.y;
        rt.Right:=rt.Left+result.cX;
        rt.Bottom:=rt.Top+result.cY;
        Canvas.CopyRect(rt,bm.Canvas,r);
      end
      else begin
        GetSize;
        hh:=nround((result.cx*result.cy/(4*hv)));
        hdx:=nround(IfThen(fig>1,Width*(1+(dx/IfThen((fig=3)and(rot),result.cx,result.cy))),Width*result.cx/result.cy));
        Inc(result.cX,2*IfThen(fig>1,IfThen((fig=3)and(rot),Width,hdx),hh)+2*horz+2*dx-IfThen((fig=3)and(not rot)and(dir>1),dx));
        MaxSelf(result.cX,sze.cx);
        Inc(result.cY,2*IfThen((fig=3)and(rot),hdx+dx,Width)+sze.cy+2*IfThen(fig<=1,hv)+2*vert-IfThen((fig=3)and(rot)and(dir>1),dx));
      end;
    end;
  lend:
    DelStack;
  end;

  procedure TumblerBut;
  const z=2;
  var wt,ht,hpos,dx,dy,horz,vert: longint;
    r,rt: TRect;
    pix: array [0..4] of TPoint;
    fil,rdir,plat: boolean;
    //cl: TColor;
  begin
    AddStack('ButForms.GetButton.TumblerBut');
    { Расчёт прямоугольника }
    with GlobButtonRec do
    begin
      { Рисование }
      fil := ap[1]='да';
      plat := ap[2]='вдавлена';
      dy:=Int0(ap[3]);
      dx:=Int0(ap[4]);
      horz:=Int0(ap[5]);
      vert:=Int0(ap[6]);
      rdir:=(ap[7]='справа');
      if Assigned(bm) then
      begin
        bm.Canvas.Brush.Color:=aColor[btfHotKey];
        if result.cX>bm.Width then bm.Width:=result.cX;
        if result.cY>bm.Height then bm.Height:=result.cY;
        r.left:=0; r.Top:=0; r.Right:=bm.Width; r.Bottom:=bm.Height;
        bm.Canvas.FillRect(r);
        With bm.Canvas do
        begin
          DefFontToFont(aFont[btfHotKey],Font);
          wt:=result.cX-Width-dx-Max(Width,dx)-2*horz;
          hpos:=TextHeight(HotKeyText);
          ht:=result.cY-2*Width-dy-hpos-2*vert;
          r.Left:=Max(Width,IfThen(rdir,dx));
          r.Right:=r.Left+wt+2*horz+dx;
          r.Top:=Width+IfThen(not UnderBut,hpos);
          r.Bottom:=r.Top+ht+dy+2*vert;
          { Кнопка и тексты }
          rt.TopLeft:=Point(r.Left-Width,r.Top-Width);
          rt.BottomRight:=Point(r.Right+Width,r.Bottom+Width);
          Pen.Color:=aclBtn[not plat];
          pix[0]:=Point(r.Left,r.Bottom);
          pix[1]:=Point(rt.Left,rt.Bottom);
          pix[2]:=rt.TopLeft;
          pix[3]:=Point(rt.Right,rt.Top);
          pix[4]:=Point(r.Right,r.Top);
          Brush.Color:=Pen.Color;
          Polygon(pix);
          Pen.Color:=aclBtn[plat];
          pix[0]:=Point(r.Left,r.Bottom);
          pix[1]:=Point(rt.Left,rt.Bottom);
          pix[2]:=rt.BottomRight;
          pix[3]:=Point(rt.Right,rt.Top);
          pix[4]:=Point(r.Right,r.Top);
          Brush.Color:=Pen.Color;
          Polygon(pix);
          Pen.Color:=aColor[Atr];
          Brush.Color:=aColor[btfHotKey];
          if not(butDown in Opt) then begin
            pix[0]:=Point(r.Left+aSign[rdir]*dx,r.Bottom-dy);
            pix[1]:=Point(r.Left,r.Bottom);
            pix[2]:=r.BottomRight;
            pix[3]:=Point(r.Right+aSign[rdir]*dx,r.Bottom-dy);
            Polygon(Slice(pix,4));
            pix[0]:=Point(IfThen(rdir,r.Right-dx,r.Left+dx),r.Bottom-dy);
            pix[1]:=Point(IfThen(rdir,r.Right,r.Left),r.Top);
            pix[2]:=Point(IfThen(rdir,r.Right,r.Left),r.Bottom);
            Polygon(Slice(pix,3));
            //cl:=Pen.Color;
            Pen.Color:=aclBtn[not rdir];
            pix[0]:=Point(r.Left+aSign[rdir]*dx,r.Bottom-dy);
            pix[1]:=Point(r.Left,r.Bottom);
            pix[2]:=r.BottomRight;
            pix[3]:=Point(r.Right+aSign[rdir]*dx,r.Bottom-dy);
            pix[4]:=pix[0];
            PolyLine(pix);
            pix[0]:=Point(IfThen(rdir,r.Right-dx,r.Left+dx),r.Bottom-dy);
            pix[1]:=Point(IfThen(rdir,r.Right,r.Left),r.Top);
            pix[2]:=Point(IfThen(rdir,r.Right,r.Left),r.Bottom);
            pix[3]:=pix[0];
            PolyLine(Slice(pix,4));
          end;
          Pen.Color:=aColor[Atr];
          Brush.Color:=IfThen(fil,Pen.Color,aColor[btfHotKey]);
          if butDown in Opt then begin
            pix[0]:=Point(r.Left,r.Top);
            pix[1]:=Point(r.Right,r.Top);
            pix[2]:=Point(r.Right,r.Bottom);
            pix[3]:=Point(r.Left,r.Bottom);
          end
          else begin
            pix[0]:=Point(r.Left,r.Top);
            pix[1]:=Point(r.Right,r.Top);
            pix[2]:=Point(r.Right+aSign[rdir]*dx,r.Bottom-dy);
            pix[3]:=Point(r.Left+aSign[rdir]*dx,r.Bottom-dy);
          end;
          Polygon(Slice(pix,4));
          DefFontToFont(aFont[Atr],Font);
          sze:=TextExtent(ActionText);
          TextOut(r.Left+IfThen(not(rdir or (butDown in Opt)),dx)+(r.Right-r.Left-IfThen(not(butDown in Opt),dx)-sze.cx)div 2,(r.top+r.Bottom-dy-sze.cy)div 2,ActionText);
          Pen.Color:=aColor[Atr];
          if not fil then
            if butDown in Opt then begin
              pix[0]:=Point(r.Left,r.Top);
              pix[1]:=Point(r.Right,r.Top);
              pix[2]:=Point(r.Right,r.Bottom);
              pix[3]:=Point(r.Left,r.Bottom);
              pix[4]:=pix[0];
            end
            else begin
              pix[0]:=Point(r.Left,r.Top);
              pix[1]:=Point(r.Right,r.Top);
              pix[2]:=Point(r.Right+aSign[rdir]*dx,r.Bottom-dy);
              pix[3]:=Point(r.Left+aSign[rdir]*dx,r.Bottom-dy);
              pix[4]:=pix[0];
            end;
          if not(butDown in Opt) then begin
            Polyline(pix);
            pix[0]:=Point(r.Left+aSign[rdir]*dx,r.Bottom-dy);
            pix[1]:=Point(r.Left,r.Bottom);
            pix[2]:=r.BottomRight;
            pix[3]:=Point(r.Right+aSign[rdir]*dx,r.Bottom-dy);
            pix[4]:=pix[0];
            Polyline(pix);
            pix[0]:=Point(IfThen(rdir,r.Right-dx,r.Left+dx),r.Bottom-dy);
            pix[1]:=Point(IfThen(rdir,r.Right,r.Left),r.Top);
            pix[2]:=Point(IfThen(rdir,r.Right,r.Left),r.Bottom);
            Polyline(Slice(pix,3));
          end;
          DefFontToFont(aFont[btfHotKey],Font);
          sze:=TextExtent(HotKeyText);
          Brush.Color:=aColor[btfHotKey];
          case Alignment of
            taLeftJustify: hpos:=r.Left-Width;
            taRightJustify: hpos:=r.Right+Width-sze.cx;
            taCenter: hpos:=r.Left-Width+((r.Right-r.Left+2*Width-sze.cx)div 2);
          else hpos:=0;
          end;
          TextOut(hpos,IfThen(UnderBut,r.Bottom+Width,r.top-Width-sze.cy),HotKeyText);
        end;
        r.Left:=0; r.Top:=0;
        r.Right:=r.Left+result.cX;
        r.Bottom:=r.Top+result.cY;
        rt.Left:=FirstPos.x; rt.Top:=FirstPos.y;
        rt.Right:=rt.Left+result.cX;
        rt.Bottom:=rt.Top+result.cY;
        Canvas.CopyRect(rt,bm.Canvas,r);
      end
      else begin
        GetSize;
        Inc(result.cX,Width+dx+Max(Width,dx)+2*horz); MaxSelf(result.cX,sze.cx+dx);
        Inc(result.cY,2*Width+sze.cy+dy+2*vert);
      end;
    end;
    DelStack;
  end;
begin
	AddStack('ButForms.GetButton');
	if GlobButtonRec.Inverted then begin
  	ActionText:=txtHotKey; HotKeyText:=txtAction;
  end
  else begin
  	ActionText:=txtAction; HotKeyText:=txtHotKey;
  end;
  apSet(GlobButtonRec);
  Atr:=aAtr[butDown in Opt,butWinActive in Opt];
  with GlobButtonRec do
    case btnType of
      btnStandart: StandartBut;
      btnEllipse: EllipseBut;
      btnDown: DownParabolaBut;
      btnSwitch: SwitchBut;
      btnBullet: BulletBut;
      btnRounded: RoundedBut;
      btnPoly: PolygonBut;
      btnTumb: TumblerBut;
    end;
  DelStack;
end;

function GlobButtonDef: TButtonRec;
var f: TFont;
  procedure FontSet(lWinAct: boolean);
  var lDown: boolean;
  begin
    AddStack('ButForms.GlobButtonDef.FontSet');
    for lDown:=false to true do FontToDefFont(f,result.aFont[aAtr[lDown,lWinAct]]);
    DelStack;
  end;
var	i: TButtonAtrType;
begin
  AddStack('ButForms.GlobButtonDef');
  f:=TFont.Create;
  try
  	DefaultFont(f);
    with result do begin
			btnType:=btnStandart; Width:=2; Inverted:=false; UnderBut:=false; Alignment:=taLeftJustify;
      for i:=low(i) to high(i) do aColor[i]:=clBtnFace;
      FontSet(false); FontStyle(f); FontSet(true);
      f.Color:=clNavy; f.Size:=8; FontToDefFont(f,aFont[btfHotKey]); aPrm:=aKeyPrmDef;
    end;
  finally
    f.Free;
  end;
  DelStack;
end;

function ButtonPrmStr;
begin
  AddStack('ButForms.ButtonPrmStr');
  apSet(ButtonRec);
  with ButtonRec do
    case btnType of
      btnEllipse: result:='Заливка: '+ap[1];
      btnStandart: result:=Format('Отступы гориз.: %d, верт.отступ: %d, Заливка: ',
        [Int0(ap[1]),Int0(ap[2])])+ap[3];
      btnDown: result:=Format('Звеньев: %d, Амплитуда: %d, Отступы гориз.: %d, верт.: %d, Перевернуть: ',
        [Int0(ap[1]),Int0(ap[2]),Int0(ap[3]),Int0(ap[4])])+ap[5]
        +', Симметрия верт.: '+ap[6]+', гориз.: '+ap[7]+', Заливка: '+ap[8];
      btnSwitch: result:=Format('Отступы гориз.: %d, Верт.: %d, Наклон: %d, Рельефность: %d, Перевернуть: ',
        [Int0(ap[1]),Int0(ap[2]),Int0(ap[3]),Int0(ap[4])])+ap[5]+', Заливка: '+ap[6];
      btnBullet: result:=Format('Отступы гориз.: %d, Верт.: %d, Направление: ',
        [Int0(ap[1]),Int0(ap[2])])+ap[3]+', Заливка: '+ap[4];
      btnRounded: result:='Направление: '+ap[1]+', Отступы гориз.: '+ap[2]+', Верт.: '+ap[3]
        +', Заливка: '+ap[4];
      btnPoly: result:='Фигура: '+ap[1]+', Отступы гориз.: '+ap[2]
        +', верт.: '+ap[3]+', Заливка: '+ap[4]
        +IfThen(ap[1]<>aPolyButNmType[1],', Наклон: '+ap[5]
        +', Перевернуть: '+ap[6])+IfThen(ap[1]=aPolyButNmType[3],', Направление: '+ap[7]);
      btnTumb: result:='Заливка: '+ap[1]+', Платформа: '+ap[2]
        +Format(', Рельефность: %d, Кривизна: %d, Отступы гориз.: %d, верт.: %d, Обзор: ',
        [Int0(ap[3]),Int0(ap[4]),Int0(ap[5]),Int0(ap[6])])+ap[7];
    else result:='';
    end;
  DelStack;
end;

procedure ButtonPrmTrans;
var fl: boolean;
  a: TArrStr;
  av1: array[0..2+Length(aPolyButNmType)] of variant;
  i: longint;
begin
  AddStack('ButForms.ButtonPrmTrans');
  fl:=IsNil(av);
  if fl then apSet(ButtonRec);
  with ButtonRec do
    case btnType of
      btnEllipse: if fl then av:=ArrVarToVar(
        [VarArrayOf([mpBool,'Залить кнопку выбранным цветом',ap[1]='да'])
        ]);
      btnStandart: if fl then av:=ArrVarToVar(
		    [VarArrayOf([mpSpin,'Горизонтальный отступ',Int0(ap[1]),0,10])
		    ,VarArrayOf([mpSpin,'Вертикальный отступ',Int0(ap[2]),0,10])
        ,VarArrayOf([mpBool,'Залить кнопку выбранным цветом',ap[3]='да'])
        ]);
      btnDown: if fl then av:=ArrVarToVar(
		    [VarArrayOf([mpSpin,'Количество звеньев',Int0(ap[1]),0,10])
		    ,VarArrayOf([mpSpin,'Амплитуда',Int0(ap[2]),0,10])
        ,VarArrayOf([mpSpin,'Горизонтальный отступ',Int0(ap[3]),0,10])
        ,VarArrayOf([mpSpin,'Вертикальный отступ',Int0(ap[4]),0,10])
        ,VarArrayOf([mpBool,'Перевернуть',ap[5]='да'])
        ,VarArrayOf([mpBool,'Вертикальная симметрия',ap[6]='да'])
        ,VarArrayOf([mpBool,'Горизонтальная симметрия',ap[7]='да'])
        ,VarArrayOf([mpBool,'Залить кнопку выбранным цветом',ap[8]='да'])
        ]);
      btnSwitch: if fl then av:=ArrVarToVar(
		    [VarArrayOf([mpSpin,'Горизонтальный отступ',Int0(ap[1]),0,10])
		    ,VarArrayOf([mpSpin,'Вертикальный отступ',Int0(ap[2]),0,10])
        ,VarArrayOf([mpSpin,'Степень наклона',Int0(ap[3]),0,20])
        ,VarArrayOf([mpSpin,'Рельефность',Int0(ap[4]),0,20])
        ,VarArrayOf([mpBool,'Перевернуть',ap[5]='да'])
        ,VarArrayOf([mpBool,'Залить кнопку выбранным цветом',ap[6]='да'])
        ]);
      btnBullet: if fl then av:=ArrVarToVar(
		    [VarArrayOf([mpSpin,'Горизонтальный отступ',Int0(ap[1]),0,10])
		    ,VarArrayOf([mpSpin,'Вертикальный отступ',Int0(ap[2]),0,10])
        ,VarArrayOf([mpRadio,'Направление пули',IfThen(ap[3]='Влево',1,2),'Влево','Вправо'])
        ,VarArrayOf([mpBool,'Залить кнопку выбранным цветом',ap[4]='да'])
        ])
      else av[3]:=IfThen(av[3]=1,'Влево','Вправо');
      btnRounded: if fl then av:=ArrVarToVar(
        [VarArrayOf([mpRadio,'Характер закругления',IfThen(ap[1]='Выпуклый',1,2),'Выпуклый','Вогнутый'])
        ,VarArrayOf([mpSpin,'Горизонтальный отступ',Int0(ap[2]),5,20])
        ,VarArrayOf([mpSpin,'Вертикальный отступ',Int0(ap[3]),5,20])
        ,VarArrayOf([mpBool,'Залить кнопку выбранным цветом',ap[4]='да'])
        ])
      else av[1]:=IfThen(av[1]=1,'Выпуклый','Вогнутый');
      btnPoly: if fl then begin
        FrmShow:=TNone.FrmShow;
        EdChange:=TNone.EdChange;
        AnsiFindText(ap[1],aPolyButNmType,low(aPolyButNmType),i);
        av1[0]:=mpRadio; av1[1]:='Фигура'; av1[2]:=i;
        for i:=low(aPolyButNmType) to high(aPolyButNmType) do av1[2+i]:=aPolyButNmType[i];
      	av:=ArrVarToVar(
          [VarArrayOf(av1)
          ,VarArrayOf([mpSpin,'Горизонтальный отступ',Int0(ap[2]),0,20])
          ,VarArrayOf([mpSpin,'Вертикальный отступ',Int0(ap[3]),0,20])
          ,VarArrayOf([mpBool,'Залить кнопку выбранным цветом',ap[4]='да'])
          ,VarArrayOf([mpSpin,'Степень наклона',Int0(ap[5]),0,20])
          ,VarArrayOf([mpBool,'Перевернуть',ap[6]='да'])
          ,VarArrayOf([mpRadio,'Направление',IfThen(ap[7]='оба',1,IfThen(ap[7]='влево',2,3)),'оба','влево','вправо'])
          ]);
      end
      else begin
        av[1]:=aPolyButNmType[Int0(av[1])];
        av[7]:=IfThen(av[7]=1,'оба',IfThen(av[7]=2,'влево','вправо'));
      end;
      btnTumb: if fl then av:=ArrVarToVar(
        [VarArrayOf([mpBool,'Залить кнопку выбранным цветом',ap[1]='да'])
        ,VarArrayOf([mpRadio,'Состояние платформы',IfThen(ap[2]='вдавлена',1,2),'вдавлена','выпукла'])
        ,VarArrayOf([mpSpin,'Рельефность',Int0(ap[3]),1,15])
        ,VarArrayOf([mpSpin,'Кривизна',Int0(ap[4]),5,20])
        ,VarArrayOf([mpSpin,'Горизонтальный отступ',Int0(ap[5]),0,10])
        ,VarArrayOf([mpSpin,'Вертикальный отступ',Int0(ap[6]),0,10])
        ,VarArrayOf([mpRadio,'Обзор',IfThen(ap[7]='справа',1,2),'справа','слева'])
        ])
      else begin
        av[2]:=IfThen(av[2]=1,'вдавлена','выпукла');
        av[7]:=IfThen(av[7]=1,'справа','слева');
      end;
    end;
  if not fl then begin
    SetLength(a,VarArrayHighBound(av,1));
    for i:=1 to Length(a) do case MyVarType(av[i]) of
      varBoolean: a[i-1]:=AnsiLowerCase(bRus2Str(av[i]));
      varString: a[i-1]:=av[i];
    else a[i-1]:=IntToStr(av[i]);
    end;
    av:=ArrayAsList(a,UnDelim);
  end;
  DelStack;
end;

class procedure TNone.EdChange;
var fl: boolean;
begin
  AddStack('TNone.EdChange');
  if Sender=EdMaskFld(1) then begin
    fl := GetEdMaskVal(1)=1; EdMaskFld(5).SetReadOnly(fl); EdMaskFld(6).SetReadOnly(fl);
    EdMaskFld(7).SetReadOnly(GetEdMaskVal(1)<>3);
  end;
  DelStack;
end;

class procedure TNone.FrmShow;
begin
  AddStack('TNone.FrmShow');
  EdMaskFld(5).IncOptions([ogReadOnlyNoVsbl]);
  EdMaskFld(6).IncOptions([ogReadOnlyNoVsbl]);
  EdMaskFld(7).IncOptions([ogReadOnlyNoVsbl]);
  DelStack;
end;

initialization
  AddStack('ButForms.initialization');
  MyTypes.GetButton:=GetButton; MyTypes.GlobButtonDef:=GlobButtonDef; GlobButtonRec:=GlobButtonDef; 
  DelStack;
end.
