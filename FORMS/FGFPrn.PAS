unit FGFPrn;

interface

{$I LIBTEST}
uses
  Messages, Classes, Controls, Menus, ExtCtrls,
  MyTypes, FrmEdt, KeyMenu, PnlEdit, Keylb, Fpanel, GenForm, FFldedit, RecVal;

type
  TGFPrn = class(TFormEdt)
    Rec: TRecVal;
    GF: TGenForm;
    pn1: TRbPanel;
    pn11: TRbPanel;
    pn111: TRbPanel;
    pn12: TRbPanel;
    pn2: TRbPanel;
    pnPrn: TRbPanel;
    EPTop: TFldEdit;
    EPBottom: TFldEdit;
    EPLeft: TFldEdit;
    EPRight: TFldEdit;
    pnEcon: TRbPanel;
    pnEcon1: TRbPanel;
    pnIntv: TRbPanel;
    EVIntv: TFldEdit;
    EHIntv: TFldEdit;
    EEcon: TFldEdit;
    pn122: TRbPanel;
    EFeed: TFldEdit;
    pnFrm: TRbPanel;
    ETop: TFldEdit;
    EBottom: TFldEdit;
    ELeft: TFldEdit;
    ERight: TFldEdit;
    EPWidth: TFldEdit;
    EPHeight: TFldEdit;
    EWidth: TFldEdit;
    EHeight: TFldEdit;
    EBook: TFldEdit;
    ENoNewPage: TFldEdit;
    EBufBmp: TFldEdit;
    EMirror: TFldEdit;
    pn1111: TRbPanel;
    EStr: TFldEdit;
    ENStr: TFldEdit;
    pn1112: TRbPanel;
    EEven: TFldEdit;
    ENPgSmall: TFldEdit;
    pn112: TRbPanel;
    pn1121: TRbPanel;
    ECnt: TFldEdit;
    ESortCop: TFldEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    function PanelEdit1Valid(Sender: TObject): Boolean;
    procedure EStrChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    procedure ECntChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    procedure PnMsg1SetWHMin(Sender: TObject);
    procedure EEconChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
    procedure EEconExit(Sender: TObject);
    procedure ESortCopChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure EFeedChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure EEvenChange(Sender: TObject; const OldVal: Variant;
      FromShow: Boolean);
    procedure PanelEdit1CngKey(Sender: TObject; var tb: TKeyBut);
  private
    { Private declarations }
    PgCur: longint;
    function CalcSpot: boolean;
		procedure WMFormLimit(var Message: TMessage); message WM_FORMLIMIT;
  public
    { Public declarations }
    class function Execute(g: TGenForm; lShow: boolean; var aPrnPrm: TPrnPrmVar;
    	const nStr: string = ''; Even: TGFEvenList = GFEvenAll): boolean;
  end;

var
  GFPrn: TGFPrn;

implementation

{$R *.DFM}

uses Windows,SysUtils,Forms,Printers,StrUtils,Math,
  My_pr,FSchemDM,ChkGets,Askp,FStat;

type TPrinterType = (ptA4,ptA3,ptA3A);

// Тип принтера
function PrinterType: TPrinterType;
var w: longint;
begin
	AddStack('FGFPrn.PrinterType');
	if IsPrinters then begin
    w:=nround(MmInInch
      *GetDeviceCaps(GGPrinter.Handle,IfThen(GGPrinter.Orientation=poPortrait,PHYSICALWIDTH,PHYSICALHEIGHT))
      /GetDeviceCaps(GGPrinter.Handle,IfThen(GGPrinter.Orientation=poPortrait,LOGPIXELSX,LOGPIXELSY)));
    result:=iif(w<280,ptA4,iif(w<400,ptA3,ptA3A));
  end
  else result:=ptA4;
  DelStack;
end;

{ TGFPrn }
class function TGFPrn.Execute;
	function Read1(i: TPrnPrmList): variant;
  begin
    AddStack('TGFPrn.Execute');
    result:=aPrnPrm[i];
    if IsNil(result) then result:=aPrnPrmDef[i].Def;
    DelStack;
  end;
var fl: boolean;
	i: longint;
  oGF: TGenForm;
begin
	AddStack('TGFPrn.Execute');
	if IsPrinters then with GFPrn do begin
	  CreateForm(TGFPrn,GFPrn); GF.OnBeforeCalculate:=nil; PgCur:=g.Leaf;
    oGF:=CurFdpGF; CurFdpGF:=GF; GF.Open(g.FileName,g.Leaf); CurFdpGF:=oGF;
    Rec['NStr']:=nStr; Rec['Even']:=Even; Rec['NPgSmall']:=0;
    Rec['Str']:=Read1(pprmStr); Rec['Book']:=Read1(pprmBook);
    SchemDM.PrnPrm['Cnt']:=max(1,Read1(pprmCntCop)); SchemDM.PrnPrm['SortCop']:=Read1(pprmSortCop);
    Rec['Econ']:=Read1(pprmEcon); Rec['VIntv']:=Read1(pprmVIntv); Rec['HIntv']:=Read1(pprmHIntv);
    SchemDM.PrnPrm['Feed']:=Read1(pprmFeed); SchemDM.PrnPrm['NoNewPage']:=Read1(pprmNoNewPg);
    Rec['MIRROR']:=Read1(pprmMirror);
    fl := GF.PageCount<=1;
    TFldEdit.SetReadOnly([EEven,ENPgSmall,EBook,EFeed],fl); EStr.SetReadOnly(fl,GFStrAll);
    fl := GF.lsBitMap.Count=0;
    if fl then for i:=0 to GF.FontCount-1 do
    	if GF.Fonts[i].Prop.Angle<>0 then begin
      	fl:=false; break;
      end;
    EBufBmp.SetReadOnly(fl);
    with GF,Params,Arr[low(Arr)] do begin
      pnFrm.Header:=IfThen(StdFormat,'Формат бумаги '+aGFFrm[NFormat])+'('+aGFOrientSmall[Orientation]+'): параметры(мм)';
      fl:=GF.SizeNoLimit(low(Arr)); ProcControlsVisible(pnEcon,not fl);
      TFldEdit.SetReadOnly([EWidth,EHeight],fl,ogReadOnlyNoVsbl);
      EWidth .VarValue:=SizeMm.cX; EHeight.VarValue:=SizeMm.cY;
      ETop.VarValue:=SpotMm.Top; EBottom.VarValue:=SpotMm.Bottom;
      ELeft.VarValue:=SpotMm.Left; ERight.VarValue:=SpotMm.Right;
    end;
    if lShow then begin
      MainRebuild; PanelEdit1.FillFldList; result := ShowModal=mrOk;
    end
    else result:=PanelEdit1Valid(PanelEdit1);
    if result then begin
    	aPrnPrm[pprmStr]:=Rec['Str']; aPrnPrm[pprmCntCop]:=SchemDM.PrnPrm['Cnt'];
      aPrnPrm[pprmSortCop]:=SchemDM.PrnPrm['SortCop']; aPrnPrm[pprmEcon]:=Rec['Econ'];
      aPrnPrm[pprmVIntv]:=Rec['VIntv']; aPrnPrm[pprmHIntv]:=Rec['HIntv'];
      aPrnPrm[pprmBook]:=Rec['Book']; aPrnPrm[pprmFeed]:=SchemDM.PrnPrm['Feed'];
      aPrnPrm[pprmNoNewPg]:=SchemDM.PrnPrm['NoNewPage'];
      aPrnPrm[pprmMirror]:=Rec['Mirror'];
    end;
    GF.CloseDtg; GF.OnBeforeCalculate:=g.OnBeforeCalculate; FormFree(GFPrn);
  end
  else result:=false;
  DelStack;
end;

procedure TGFPrn.FormCreate(Sender: TObject);
begin
	AddStack('TGFPrn.FormCreate',Self);
  inherited;
  Rec['BufBmp']:=InitFIni[fiSave].ReadInteger('PRN','BufBmp');
  EFeed.Mask:=StrTran(DlmCopy(TRadioGet(EFeed.curget).Items.Text,1,2,CRLF),CRLF,mniDlm);
  DelStack;
end;

procedure TGFPrn.FormActivate(Sender: TObject);
begin
	AddStack('TGFPrn.FormActivate',Self);
  inherited;
  if CalcSpot then KeyLb1.ExecKey(K_F3);
  DelStack;
end;

function TGFPrn.CalcSpot;
var r: TRect;
	PrnType: TPrinterType;
begin
	AddStack('TGFPrn.CalcSpot',Self);
  with GF.Params,Arr[low(Arr)] do begin
    r:=GFCalcSpotPrn(NFormat,Orientation);
    EPWidth.VarValue:=longint(nround(GetDeviceCaps(GGPrinter.Handle,PHYSICALWIDTH)
      /(GetDeviceCaps(GGPrinter.Handle,LOGPIXELSX)/MmInInch)));
    EPHeight.VarValue:=longint(nround(GetDeviceCaps(GGPrinter.Handle,PHYSICALHEIGHT)
      /(GetDeviceCaps(GGPrinter.Handle,LOGPIXELSY)/MmInInch)));
    EPLeft.VarValue:=r.Left; EPTop.VarValue:=r.Top;
    EPRight.VarValue:=r.Right; EPBottom.VarValue:=r.Bottom;
    PrnType:=PrinterType;
    pnPrn.Header:='Принтер '+GGPrinter.Printers[GGPrinter.PrinterIndex]+': параметры(мм)';
    result := StdFormat and (PrnType=ptA4) and (NFormat=frmA3)
      or not StdFormat and ((SizeMm.cX>Rec['PWIDTH']) or (SizeMm.cY>Rec['PHEIGHT']));
  end;
  if result then mess_ok(['Внимание !',
    'Необходимо изменить размер бумаги для принтера',
    GGPrinter.Printers[GGPrinter.PrinterIndex],'или выбрать другой принтер.']);
  DelStack;
end;

procedure TGFPrn.KeyLb1ProcKey(key: longint; tw: TWinControl);
begin
	AddStack('TGFPrn.KeyLb1ProcKey',Self);
  inherited;
  if Key=K_F3 then begin
  	PrnSetupExec; CalcSpot;
  end;
  DelStack;
end;

// Печать
procedure PrintStat(Sender: TStat; const Params: array of variant; var Aborted: boolean);
var LsStr: TIntegerList;
  procedure LsAdd(v: longint);
  var fl: boolean;
  begin
  	AddStack('FGFPrn.PrintStat.LsAdd');
    with GFPrn do if InRange(v,1,GF.PageCount) then
    	if (Rec['NPgSmall']=0) or (Rec['NPgSmall']=GF.PageInf(v).PgSmall) then begin
        if Rec['Even']=GFEvenAll then fl:=true
        else begin
          fl := (v mod 2) = 0;
          if Rec['Even']=GFEvenNoEven then NotD(fl);
        end;
        if fl then LsStr.Add(v);
      end;
    DelStack;
  end;
type
	TPgInfo1 = record
  	nList,nCop,LeftMm,TopMm: Word;
	end;
  TPgInfo = record
    a1: array of TPgInfo1;
    Count1: longint;
  end;
var
  aPg: array[boolean] of record
    a: array of TPgInfo;
    Count: longint;
  end;
  procedure PgAdd(fl: boolean);
  begin
    AddStack('FGFPrn.PrintStat.PgAdd');
    with aPg[fl] do begin
      if Length(a)=Count then SetLength(a,IfThen(Count=0,10,Count shl 1));
      Inc(Count);
    end;
    DelStack;
  end;
var PgEmp: TPgInfo;
  procedure PgAddEmp(fl: boolean);
  begin
    AddStack('FGFPrn.PrintStat.PgAddEmp');
    PgAdd(fl);
    with aPg[fl] do a[Count-1]:=pgEmp;
    DelStack;
  end;
  procedure PgIns(fl: boolean; const v: TPgInfo);
  var i: longint;
  begin
    AddStack('FGFPrn.PrintStat.PgIns');
    PgAdd(true);
    with aPg[fl] do begin
      for i:=Count-1 downto 1 do a[i]:=a[i-1];
      a[0]:=v;
    end;
    DelStack;
  end;
var ocnt: longint;
  procedure PgMove;
  var i: longint;
  begin
    AddStack('FGFPrn.PrintStat.PgMove');
    with aPg[false] do begin
      PgIns(true,a[ocnt]);
      for i:=ocnt+1 to Count-1 do a[i-1]:=a[i];
      Dec(Count);
    end;
    DelStack;
  end;
var prnW,prnH: Double;
	flr,lfirst,fl,flb,lmsg: boolean;
	po: TPrinterOrientation;
  prm: TGFParams;
  i,j,w,h,ww,hh,iw,ih,spw,sph,lc1,lc2,nc1,nc2,k,l,t,r,b,ost,oPrm,StatNum,StatCnt: longint;
  a: array[1..15] of string;
  Capt: string;
  sv: TPageSave;
  al: TNamePrimStr;
label lend;
begin
	ost:=AddStack('FGFPrn.PrintStat');
  LsStr:=TIntegerList.Create; Finalize(aPg); ZeroMemory(@aPg,SizeOf(aPg));
  with GFPrn,GF do begin
    try
      LsStr.Clear;
      // Номера печатаемых страниц
      case TGFStrList(Rec['Str']) of
        GFStrAll: for i:=1 to PageCount do LsAdd(i);
        GFStrCur: LsAdd(PgCur);
        GFStrNum: begin
          l:=listasarray(Rec['NStr'],a,',');
          for i:=1 to l do
            if StrDivDlm('-',a[i],al)
            then for j:=Int0(al[1]) to Int0(al[2]) do LsAdd(j)
            else LsAdd(Int0(a[i]));
        end;
      end;
      if LsStr.Count>0 then begin
        fl:=true;
        if Rec['Book']=1 then for i:=0 to LsStr.Count-1 do
          if GF.PageInf(LsStr[i]).PgSmall>1 then begin
            fl:=false; break;
          end;
        oPrm:=-1; t:=0; b:=0; r:=0; hh:=0; ww:=0; spw:=0; sph:=0;
        // Экономия бумаги
        with Params do begin
          iw:=Rec['HIntv']; ih:=Rec['VIntv'];
          with PgEmp do begin
            SetLength(a1,1); Count1:=1; ZeroMemory(@a1[0],SizeOf(a1[0]));
          end;
          if SchemDM.PrnPrm['SortCop'] then lc1:=SchemDM.PrnPrm['Cnt'] else lc1:=1;
          for nc1:=1 to lc1 do begin
            ocnt:=aPg[false].Count; PgEmp.a1[0].nCop:=nc1;
            for i:=0 to LsStr.Count-1 do begin
              sv:=PageInf(LsStr[i]); w:=sv.WidthMm; h:=sv.HeightMm;
              if SchemDM.PrnPrm['SortCop'] then lc2:=1 else lc2:=SchemDM.PrnPrm['Cnt'];
              for nc2:=1 to lc2 do begin
                flb:=true;
                if (GF.VersInfo.Vers<27) and (oPrm<0)
                or (GF.VersInfo.Vers>=27) and (sv.CurParams<>oPrm) then begin
                  flb := oPrm<0;
                  oPrm:=IfThen(GF.VersInfo.Vers<27,low(Arr),sv.CurParams);
                  with Arr[oPrm] do begin
                    ww:=SizeMm.cX-SpotMm.Right; hh:=SizeMm.cY-SpotMm.Bottom;
                    spw:=SpotMm.Left; sph:=SpotMm.Top;
                    l:=SizeMm.cX; t:=SizeMm.cY; r:=l+1; b:=t+1;
                  end;
                end;
                flr := (Rec['Econ']=GFEconFull) and (r+w<=ww) and (t+h<=hh);
                AndD(flb,(Rec['Econ']<>GFEconNone) and (b+h<=hh));
                if flr then begin
                  l:=r; MaxSelf(b,t+h+ih);
                end
                else begin
                  l:=spw;
                  if flb then t:=b
                  else begin
                    PgAdd(false); t:=sph;
                  end;
                  b:=t+h+ih;
                end;
                r:=l+w+iw;
                with aPg[false],a[Count-1] do begin
                  if Length(a1)=Count1 then SetLength(a1,IfThen(Count1=0,10,Count1 shl 1));
                  Inc(Count1);
                  with a1[Count1-1] do begin
                    nList:=LsStr[i]; nCop:=IfThen(SchemDM.PrnPrm['SortCop'],nc1,nc2); LeftMm:=l; TopMm:=t;
                  end;
                end;
              end;
            end;
            // Печать "книжкой"
            if Rec['Book']<>0 then begin
              if fl then begin
                if Rec['Book']=1 then Inc(ocnt);
                while ocnt<aPg[false].Count do begin
                  PgMove; Inc(ocnt);
                end;
              end
              else begin
                r:=0; flr:=false;
                while ocnt<aPg[false].Count do begin
                  l:=aPg[false].a[ocnt].a1[0].nList;
                  t:=GF.PageInf(l).PgLong;
                  if t<>r then begin
                    if flr then PgIns(true,PgEmp);
                    r:=t;
                  end;
                  flr := (GF.PageInf(l).PgSmall mod 2)<>0;
                  if flr then Inc(ocnt) else PgMove;
                end;
              end;
              if Rec['Book']=1 then PgAddEmp(true);
              while aPg[false].Count<aPg[true].Count do PgAddEmp(false);
              while aPg[true].Count<aPg[false].Count do PgIns(true,PgEmp);
            end;
          end;
          if GGPrinter.Orientation=poLandscape then begin
            k:=nround(GGPrinter.PageHeight/GetDeviceCaps(GGPrinter.Handle,LOGPIXELSY)*MmInInch)
              -Arr[oPrm].SizeMm.cY;
            if k>0 then
              for fl:=false to true do with aPg[fl] do
                for i:=0 to Count-1 do with a[i] do
                  for j:=0 to Count1-1 do Inc(a1[j].TopMm,k);
          end;
        end;

        // Тест
        {for fl:=false to true do with aPg[fl] do if Count>0 then	begin
          Capt:=Padr('HeightMm',10)+' '+Padr('WidthMm',10)
            +CRLF+SpaceStr0(hh-sph,10)+' '+SpaceStr0(ww-spw,10)+CRLF;
          for i:=0 to LsStr.Count-1 do
            IncD(Capt,CRLF+SpaceStr0(PageInf(LsStr[i]).HeightMm,10)+' '
              +SpaceStr0(PageInf(LsStr[i]).WidthMm,10));
          meserr(Capt,IfThen(fl,'Вторые','Первые')+' листы');
          for i:=0 to Count-1 do
          with a[i] do begin
            Capt:=Padr('Лист(страница)',14)+' '+Padl('nCop',10)+' '+Padl('TopMm',10)+' '+Padl('LeftMm',10);
            for j:=0 to Count1-1 do with a1[j] do begin
              IncD(Capt,CRLF+Padr(Format('%d'+IfThen(nList>0,'(%d.%d)'),
                [nList,PageInf(nList).PgLong,PageInf(nList).PgSmall]),14)+' '+SpaceStr0(nCop,10)+' '
                +SpaceStr0(TopMm,10)+' '+SpaceStr0(LeftMm,10));
            end;
            meserr(Capt,IntToStr(i+1));
          end;
        end;
        goto lend;}

        // Печать
        lmsg:=not MessagesHidden; //flr := not(IsTextMode or (SchemDM.PrnPrm['Feed']=FeedHand));
        for fl:=false to true do with aPg[fl] do if Count>0 then begin
          if Rec['Book']<>0 then begin
            if fl then Capt:='Подготовьте пачку распечатанных листов'+CRLF
              +'для печати на противоположной стороне.'
            else begin
              i:=Count mod 10; j:=((Count mod 100) - i) div 10;
              Capt:=StrNum('Подготовьте для печати ',Count)+' лист'
                +IfThen((i<>1) or (j=1),IfThen(InRange(i,2,4) and (j<>1),'а','ов'))+'.';
            end;
            if not Ask([Capt+CRLF+CRLF+'Продолжить ?'],true,'Печать "книжкой"') then break;
          end;
          lfirst:=true; prm:=GFCopyParams(Params);
          StatCnt:=LsStr.Count*SchemDM.PrnPrm['Cnt']; StatNum:=1;
          GGPrinter.Title:=Trim(FileName)+IfThen(SchemDM.PrnPrm['Feed']=FeedHand,' (страница 1)');
          PrnBeginDoc;
          try
            prnW:=(GetDeviceCaps(GGPrinter.Handle,PHYSICALOFFSETX)+GGPrinter.PageWidth)
              /GetDeviceCaps(GGPrinter.Handle,LOGPIXELSX);
            prnH:=(GetDeviceCaps(GGPrinter.Handle,PHYSICALOFFSETY)+GGPrinter.PageHeight)
              /GetDeviceCaps(GGPrinter.Handle,LOGPIXELSY);
            for i:=0 to Count-1 do begin
              Capt:=StrNum('Печать страницы ',i+1);
              //po:=Params.Arr[CurParams].Orientation;
              with a[i] do for j:=0 to Count1-1 do with a1[j] do begin
                if Sender.SayStat(Capt,
                Format('Лист %d'+IfThen(SchemDM.PrnPrm['Cnt']<>1,'(копия %d)'),[nList,nCop]),
                StatNum/StatCnt)
                  then raise EPrnError.Create('');
                Inc(StatNum);
                if nList>0 then with GF do begin
                  with prm.Arr[CurParams] do begin
                    SpotMm.Left:=LeftMm; SpotMm.Top:=TopMm;
                  end;
                  Params:=prm; RestPage(nList);
                end;
                po:=GF.Params.Arr[GF.CurParams].Orientation; flb := po<>GGPrinter.Orientation;
                if flb then with GGPrinter do begin
                  if lfirst then Abort else PrnEndDoc;
                  SetPrnOrient(po);
                  prnW:=(GetDeviceCaps(Handle,PHYSICALOFFSETX)+PageWidth)
                    /GetDeviceCaps(Handle,LOGPIXELSX);
                  prnH:=(GetDeviceCaps(Handle,PHYSICALOFFSETY)+PageHeight)
                    /GetDeviceCaps(Handle,LOGPIXELSY);
                  if not(not lfirst and (j=0)) then BeginDoc;
                end;
                if not lfirst then
                  if j=0 then PrnNewPage(Trim(FileName)+Format(' (страница %d)',[i+1]),not flb);
                if nList>0 then begin
                  // Лист не влезает в принтер
                  if lmsg then
                    if ((GridX[ColCount]+Spot.Left-GridX[0])/Screen.PixelsPerInch>prnW)
                    or ((GridY[RowCount]+Spot.Top-GridY[0])/Screen.PixelsPerInch>prnH) then begin
                      if not ask([Format('Лист %d не помещается',[nList]),
                      'в область печати принтера.','Продолжить печать ?'])
                        then raise EPrnError.Create('');
                      lmsg:=false;
                    end;
                  Print(Rec['MIRROR'] and (((Rec['Book']<>0) and not fl) or (Rec['Even']=GFEvenEven)));
                end;
                lfirst:=false;
              end;
            end;
            PrnEndDoc;
          except
            on EPrnError do begin
              SetStack(ost);
              if GGPrinter.Printing then GGPrinter.Abort;
            end;
          end;
        end;
      end;
lend:
    finally
      LsStr.Free;
    end;
  end;
  DelStack;
end;

function TGFPrn.PanelEdit1Valid(Sender: TObject): Boolean;
var sp: TRect;
  i: longint;
  ort: TPrinterOrientation;
  procedure spRotate;
  var j: longint;
  begin
    AddStack('TGFPrn.PanelEdit1Valid.spRotate',Self);
    with GF.Params.Arr[i] do if Orientation<>ort then begin
      ort:=Orientation;
      if ort=poLandScape then begin
        j:=sp.Left; sp.Left:=sp.Bottom; sp.Bottom:=sp.Right; sp.Right:=sp.Top; sp.Top:=j;
      end
      else begin
        j:=sp.Left; sp.Left:=sp.Top; sp.Top:=sp.Right; sp.Right:=sp.Bottom; sp.Bottom:=j;
      end;
    end;
    DelStack;
  end;
var fl: longint;
begin
	AddStack('TGFPrn.PanelEdit1Valid',Self);
  inherited;
  with GF do begin
    fl:=mrNo;
    if ogReadOnly in EMirror.Options then Rec['MIRROR']:=false;
    sp:=Rect(Rec['PLeft'],Rec['PTop'],Rec['PRight'],Rec['PBottom']);
    if Rec['MIRROR'] then with sp do begin
    	MaxSelf(Left,Right); Right:=Left;
    end;
    with Params do begin
      ort:=Arr[low(Arr)].Orientation;
      for i:=low(Arr) to high(Arr) do with Arr[i],SpotMm do begin
        spRotate;
        if (sp.Top>Top) or (sp.Bottom>Bottom) or (sp.Left>Left) or (sp.Right>Right) then begin
          fl:=AskCancel(['Внимание !','Отступы в документе не соответствуют',
            'минимальным отступам для принтера.','Использовать отступы принтера ?'],mrYes);
          break;
        end;
      end;
    end;
    result := fl<>mrCancel;
    if result then begin
    	InitFIni[fiSave].WriteInteger('PRN','BufBmp',Rec['BufBmp']);
      if fl=mrYes then with Params do for i:=low(Arr) to high(Arr) do begin
        spRotate; Arr[i].SpotMm:=sp;
      end;
      if not EEcon.Visible or (ogReadOnly in EEcon.Options) then Rec['Econ']:=GFEconNone;
      ShowStat('Печать страницы 1',PrintStat);
    end;
  end;
  DelStack;
end;

procedure TGFPrn.EStrChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
var fl: boolean;
begin
	AddStack('TGFPrn.EStrChange',Self);
  inherited;
  fl := not(ogReadOnly in EStr.Options) and (Rec['Str']=GFStrNum); ENStr.SetReadOnly(not fl);
  if fl and not FromShow then ENStr.SetFocus;
  DelStack;
end;

procedure TGFPrn.ECntChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
var ml,mc: boolean;
begin
	AddStack('TGFPrn.ECntChange',Self);
  inherited;
  ml := GF.PageCount>1; mc := SchemDM.PrnPrm['Cnt']>1;
  EFeed.SetReadOnly(not(ml or mc));
  ESortCop.SetReadOnly(not(ml and mc));
  EEcon.SetReadOnly(not(ml or mc) or (GF.VersInfo.Vers<11)); EEconChange(EEcon,0,FromShow);
  DelStack;
end;

procedure TGFPrn.PanelEdit1CngKey(Sender: TObject; var tb: TKeyBut);
begin
	AddStack('TGFPrn.PanelEdit1CngKey',Self);
  inherited;
	with tb do if Key=K_F10 then Caption:='Печать';
  DelStack;
end;

procedure TGFPrn.PnMsg1SetWHMin(Sender: TObject);
begin
	AddStack('TGFPrn.PnMsg1SetWHMin',Self);
  inherited;
	TRbStatus(Sender).WMin:=0;
  DelStack;
end;

procedure TGFPrn.ESortCopChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TGFPrn.ESortCopChange',Self);
  EBook.SetReadOnly(not SchemDM.PrnPrm['SortCop'] or (GF.PageCount<=1)
  	or not(not EEcon.Visible or (ogReadOnly in EEcon.Options) or (Rec['Econ']=GFEconNone)));
  DelStack;
end;

procedure TGFPrn.EEconChange(Sender: TObject; const OldVal: Variant; FromShow: boolean);
var fl: boolean;
begin
  AddStack('TGFPrn.EEconChange',Self);
	fl := not EEcon.Visible or (ogReadOnly in EEcon.Options);
	EVIntv.SetReadOnly(fl or (Rec['Econ']=GFEconNone));
	EHIntv.SetReadOnly(fl or (Rec['Econ']<>GFEconFull));
  ESortCopChange(ESortCop,OldVal,FromShow);
  DelStack;
end;

procedure TGFPrn.EEconExit(Sender: TObject);
begin
	AddStack('TGFPrn.EEconExit',Self);
  if ogReadonly in EBook.Options then EBook.VarValue:=false;
  DelStack;
end;

procedure TGFPrn.EFeedChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TGFPrn.EFeedChange',Self);
  ENoNewPage.SetReadOnly((SchemDM.PrnPrm['Feed']<>FeedAuto) or (ogReadOnly in EFeed.Options));
  DelStack;
end;

procedure TGFPrn.WMFormLimit;
begin
	AddStack('TGFPrn.WMFormLimit',Self);
  inherited;
  FreeLimit(GFPrn);
  DelStack;
end;

procedure TGFPrn.EEvenChange(Sender: TObject; const OldVal: Variant;
  FromShow: Boolean);
begin
	AddStack('TGFPrn.EEvenChange',Self);
  EMirror.SetReadOnly((Rec['EVEN']<>GFEvenEven) and (Rec['BOOK']=0));
  DelStack;
end;

end.
