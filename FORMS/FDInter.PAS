unit FDInter;

interface

{$I LIBTEST}
uses
  Classes, Controls, Fpanel, Menus, KeyMenu, Keylb, ExtCtrls,
  FrmAct, FEdText;

type
  TDInter = class(TFrmAction)
    stFml: TRbStatus;
    pnRes: TRbPanel;
    stRes: TRbStatus;
    pnRes1: TRbPanel;
    procedure FormCreate(Sender: TObject);
    procedure pnRes1Resize(Sender: TObject);
    procedure KeyLb1ProcKey(key: Integer; tw: TWinControl);
    procedure FormShow(Sender: TObject);
  private
    ResMemo: TInterMemo;
  protected
    class function TextToIni(const s: string): string; override;
    class function IniToText(const s: string): string; override;
    class function ClassTextMemo: TClassTextMemo; override;
    procedure Execute(const txt: string); override;
  end;

implementation

{$R *.dfm}

uses Windows,SysUtils,Variants,Forms,StrUtils,
  MyTypes,My_pr,Inter,FIntErLs,FrmWnd;

var DInter: TDInter;

{ TDInter }
procedure TDInter.FormCreate(Sender: TObject);
begin
  AddStack('TDInter.FormCreate',Self);
  ResMemo:=TInterMemo.CreateParent(Self,pnRes);
  with ResMemo do begin
    BorderStyle:=bsNone; BevelOuter:=bvNone; WantTabs:=false; ReadOnly:=true; Status:=stRes;
  end;
  KeyLb1.NmProc.Add(TKeyLb.GetKeySt(K_Ctrl_Tab,'','œÂÂÌÓÒ ÔÓ ÒÎÓ‚‡Ï',kmFile));
  inherited;
  TextMemo.Status:=stFml;  //TextMemo.BorderStyle:=bsNone;
  DelStack;
end;

procedure TDInter.FormShow(Sender: TObject);
var i: longint;
  f: TIntErLs;
begin
  AddStack('TDInter.FormShow',Self);
  inherited;
  TInterMemo(TextMemo).inter.lDebug:=Assigned(CurInter);
  ResMemo.Init('–ÂÁÛÎ¸Ú‡Ú'); TInterMemo(TextMemo).Init('¬˚ÔÓÎˇÂÏ‡ˇ ÙÓÏÛÎ‡');
  for i:=LsFormWnd.Count-1 downto 0 do if IsClass(LsFormWnd[i],TIntErLs,pointer(f)) then begin
    f.MemoView.CompileEval(false); break;
  end;
  DelStack;
end;

class function TDInter.TextToIni;
begin
  result:=StrTran(s,CRLF,#31);
end;

class function TDInter.IniToText;
begin
  result:=StrTran(s,#31,CRLF);
end;

class function TDInter.ClassTextMemo;
begin
  result:=TInterMemo;
end;

procedure TDInter.pnRes1Resize(Sender: TObject);
var b,h: longint;
begin
  AddStack('TDInter.pnObjResize',Self);
  inherited;
  if Assigned(ResMemo) then with TRbPanel(Sender) do begin
    b:=BevPanel; h:=HeaderHeight; ResMemo.SetBounds(b,b+h,CltWidth,CltHeight-h);
  end;
  DelStack;
end;

procedure TDInter.Execute;
var a: TArrStr;
  nl: longint;
  procedure lsAdd;
  begin
    AddStack('TDInter.Execute.lsAdd',Self);
    Inc(nl);
    if Length(a)=nl then SetLength(a,nl shl 1);
    a[nl]:='';
    DelStack;
  end;
  procedure sAdd(const s: string);
  begin
    AddStack('TDInter.Execute.sAdd',Self);
    IncD(a[nl],s);
    DelStack;
  end;
var lArr: boolean;
  lvArr: ShortInt;
  procedure OutRes(const v: variant);
  var s: string;
    i,l: longint;
    procedure sStuff(ln: longint; const s1: string);
    begin
      AddStack('TDInter.Execute.OutRes.sStuff',Self);
      StuffStrSelf(s,i,ln,s1); Inc(i,Length(s1)-ln); l:=Length(s);
      DelStack;
    end;
  const aQQ: TArrBoolChr = ('''','"');
  var fl: boolean;
    nQQ: TArrBoolInt;
    cQQ: char;
    h: longint;
    i64: Int64;
  begin
    AddStack('TDInter.Execute.OutRes',Self);
    case MyVarType(v) of
      V_NULL: if not lArr then sAdd('NIL');
      V_INT: begin
        i64:=v; sAdd(IntToStr(i64));
      end;
      V_FLOAT: begin
        s:=SpaceStr0(v,FloatMaxLen,FloatMaxDec); i:=FloatMaxLen;
        while (i>FloatMaxLen-FloatMaxDec+1) and (s[i]='0') do Dec(i);
        SetLength(s,i); sAdd(StrTran(Trim(s),DecimalSeparator,'.'));
      end;
      V_DATE: sAdd(dtoc(v));
      V_BOOL: sAdd(bVar[boolean(v)]);
      V_STRING: begin
        ZeroMemory(@nQQ,SizeOf(nQQ)); s:=v; l:=Length(s);
        for i:=1 to l do
          for fl:=false to true do if s[i]=aQQ[fl] then Inc(nQQ[fl]);
        fl := nQQ[true]<=nQQ[false]; cQQ:=aQQ[fl];
        if l=0 then s:=cQQ+cQQ
        else begin
          i:=1; fl:=true;
          while i<=l do begin
            if not lArr and (s[i]=CRLF[1]) and (i<l) then
              if s[i+1]=CRLF[2] then begin
                sAdd(LeftStr(s,i-1)+IfThen(not fl,cQQ)+IfThen(i>1,'+')
                  +'œ≈–≈¬Œƒ_—“–Œ »'+IfThen(i+1<l,'+;'));
                Delete(s,1,i+1); l:=Length(s); i:=1; fl:=true; lsAdd; continue;
              end;
            if (s[i]<' ') or (s[i]=cQQ) then begin
              sStuff(1,IfThen(not fl,cQQ)+IfThen(i>1,'+')+Format(' Œƒ_—»Ã¬ŒÀ(%d)',[Ord(s[i])])); fl:=true;
            end
            else begin
              if fl then sStuff(0,IfThen(i>1,'+')+cQQ);
              fl:=false;
            end;
            Inc(i);
          end;
          if not fl then IncD(s,cQQ);
        end;
        sAdd(s);
      end;
      varArray: begin
        fl:=false; l:=VarArrayLowBound(v,1); h:=VarArrayHighBound(v,1);
        for i:=l to h do
          if MyVarType(v[i])=varArray then begin
            fl:=true; break;
          end;
        if fl then begin
          Inc(lvArr); s:=Space(lvArr);
          for i:=l to h do begin
            sAdd(IfThen(i=l,'{',s+',')); OutRes(v[i]); sAdd(';'); lsAdd;
          end;
          sAdd(s+'}'); Dec(lvArr);
        end
        else begin
          for i:=l to h do begin
            sAdd(IfThen(i=l,'{',',')); OutRes(v[i]);
          end;
          sAdd('}');
        end;
      end;
    end;
    DelStack;
  end;
var v: variant;
begin
  AddStack('TDInter.Execute',Self);
  with TInterMemo(TextMemo) do begin
    v:=CompileEval(true);
    if Inter.Error=E_NO then begin
      lArr := MyVarType(v)=varArray; SetLength(a,10); nl:=-1; lsAdd; lvArr:=-1;
      OutRes(v); ResMemo.Text:=TrimRight(ArrayAsList(a,CRLF,nl+1));
    end;
  end;
  DelStack;
end;

procedure TDInter.KeyLb1ProcKey(key: Integer; tw: TWinControl);
begin
  AddStack('TDInter.KeyLb1ProcKey',Self);
  if Key=K_Ctrl_Tab then with ResMemo do WordWrapBool:=not WordWrapBool else inherited;
  DelStack;
end;

procedure PswdKeyProc(Key: longint; tw: TWinControl; var lBreak: boolean);
begin
  AddStack('FDInter.PswdKeyProc');
  if Key=K_Alt_W then begin
    lBreak:=true; CreateShow(TDInter,DInter,true);
  end;
  DelStack;
end;

initialization
  AddStack('FDInter.initialization');
  AddFrom(aPswdKeyProc,PswdKeyProc);
  DelStack;
end.
