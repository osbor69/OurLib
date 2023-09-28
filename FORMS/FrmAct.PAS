unit FrmAct;
{$I LIBTEST}

interface

uses Controls, ExtCtrls, Classes, Menus,
  MyTypes, FRMEMPTY, Keylb, Fpanel, KeyMenu, FEdText;

type
  TFrmAction = class(TFormEmp)
    pnText: TRbPanel;
    pnObj: TRbPanel;
    KeyMenu1: TKeyMenu;
    procedure KeyLb1ProcKey(key: longint; tw: TWinControl);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    aHistory: TArrStr;
    nHistory: longint;
    class procedure HistoryProcKey(key: longint; tw: TWinControl);
  protected
    TextMemo: TTextMemo;
    class procedure MoveArray(arr: pointer; ixTo,ixFrom,itemCount,itemSize: longint);
    class function PrefHistory: string; virtual;
    class function TextToIni(const s: string): string; virtual; abstract;
    class function IniToText(const s: string): string; virtual;
    class function ClassTextMemo: TClassTextMemo; virtual; abstract;
    procedure Execute(const txt: string); virtual; abstract;
  end;

implementation
{$R *.dfm}

uses Windows,SysUtils,Forms,Math,
  My_pr,ListF2;

const lHistory = 99;

procedure TFrmAction.FormCreate(Sender: TObject);
var s: string;
  j,k: longint;
begin
  AddStack('TFrmAction.FormCreate',Self);
  TextMemo:=ClassTextMemo.CreateParent(Self,pnText);
  with TextMemo do begin
    Align:=alClient; BevelOuter:=bvNone; WantTabs:=false;
  end;
  inherited;
  ActiveControl:=TextMemo.Control;
  j:=0; SetLength(aHistory,lHistory+1);
  for k:=0 to lHistory do begin
    s:=InitFIni[fiSave].ReadString(ClassName,StrNum(PrefHistory,k));
    if (s<>'') then begin
      aHistory[j]:=IniToText(s); inc(j);
    end;
  end;
  SetLength(aHistory,j); nHistory:=j;
  DelStack;
end;

procedure TFrmAction.FormDestroy(Sender: TObject);
var h,j,k: longint;
begin
  AddStack('TFrmAction.FormDestroy',Self);
  inherited;
  h:=0; j:=high(aHistory);
  for k:=max(low(aHistory),j-lHistory) to j do begin
    InitFIni[fiSave].WriteString(ClassName,StrNum(PrefHistory,h),TextToIni(aHistory[k])); inc(h);
  end;
  DelStack;
end;


procedure TFrmAction.KeyLb1ProcKey(key: longint; tw: TWinControl);
var s: string;
  k,j: longint;
  mr: TListF2Result;
begin
  AddStack('TFrmAction.KeyLb1ProcKey',Self);
  case key of
    K_CTRL_E,K_F10: begin
      s:=Trim(TextMemo.Text);
      if s<>'' then begin
        j:=-1;
        for k:=high(aHistory) downto 0 do begin
          if TextToIni(aHistory[k])=TextToIni(s) then begin
            j:=k; break;
          end;
        end;
        k:=length(aHistory);
        if j=-1 then SetLength(aHistory,k+1)
        else begin
          dec(k);
          if j<k then begin(* найденный - не последний *)
            (* j+1 - индекс первого элемента хвоста *)
            (* k-j - длина хвоста *)
            MoveArray(@aHistory[0],j,j+1,k-j,SizeOf(aHistory[0]));
          end;
        end;
        aHistory[k]:=s; nHistory:=k;
        if Key=K_CTRL_E then Execute(s);
      end;
    end;
    K_Ctrl_H: begin
      mr:=TListF2Result.Create;
      try
        for j:=high(aHistory) downto low(aHistory) do mr.Add(TextToIni(aHistory[j]));
        if ListF2Down(mr.Text,mr,TextMemo.Control,0,'Browl',
        TKeyLb.GetKeySt(K_Ctrl_E,'¬ыполнить'),HistoryProcKey) then begin
          nHistory:=high(aHistory)-mr.SelectStr; TextMemo.Text:=aHistory[nHistory];
          if LastKey=K_Ctrl_E then KeyLb1.ExecKey(K_Ctrl_E);
        end;
      finally
        mr.Free;
      end;
    end;
    K_CTRL_N,K_CTRL_P: begin
      case Key of
        K_CTRL_N: if nHistory<=high(aHistory) then Inc(nHistory);
        K_CTRL_P: if nHistory>=low (aHistory) then Dec(nHistory);
      end;
      if InRange(nHistory,low(aHistory),high(aHistory))
      then TextMemo.Text:=aHistory[nHistory] else TextMemo.Text:='';
    end;
  end;
  inherited;
  DelStack;
end;

class procedure TFrmAction.HistoryProcKey;
begin
  AddStack('TFrmAction.HistoryProcKey');
  GetParentForm(tw).ModalResult:=mrOk;
  DelStack;
end;

class procedure TFrmAction.MoveArray;
var p: pointer;
  blockSize,blocksDist,saveSize,pTo,pFrom,pSave,pSaveTo: longint;
begin
  AddStack('TFrmAction.MoveArray');
  if (ixTo>=0)and(ixFrom>=0)and(ixTo<>ixFrom)and(itemCount>0)and(itemSize>0) then begin
    blockSize:=itemCount*itemSize;
    pTo:=longint(arr)+ixTo*itemSize;
    pFrom:=longint(arr)+ixFrom*itemSize;

    pSave:=pTo;
    pSaveTo:=pFrom;
    blocksDist:=abs(pTo-pFrom);
    saveSize:=min(blocksDist,blockSize);
    if blocksDist<blockSize then begin(* пересекаютс€ *)
      if pTo>pFrom then pSave:=pFrom+blockSize else pSaveTo:=pTo+blockSize;
    end;

    GetMem(p,saveSize);
    try
      CopyMemory(p,pointer(pSave),saveSize);
      MoveMemory(pointer(pTo),pointer(pFrom),blockSize);
      CopyMemory(pointer(pSaveTo),p,saveSize);
    finally
      FreeMem(p);
    end;
  end;
  DelStack;
end;

class function TFrmAction.PrefHistory;
begin
  result:='History_';
end;

class function TFrmAction.IniToText;
begin
  result:=s;
end;

end.
