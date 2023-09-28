unit FPDF417;

interface

uses SysUtils;

function Pdf417Init: boolean;
function Pdf417PreviewFile(const FileName: TFileName; const NameNal: string = ''): boolean;

implementation

uses Forms,ComObj,TAXDOCPrt_TLB,
  MyTypes,My_pr;

var Pdf417: _TAXDOCPrint;

function Pdf417Init;
var ost: longint;
  path: TFileName;
begin
  ost:=AddStack('FPDF417.Pdf417Init');
  path:=''; result:=SearchPath('PDF417'+PathDelim,path);
  if result then try
    Pdf417:=CreateComObject(StringToGUID('{CFD2F2DD-0151-4C65-8B21-69F18718EB83}')) as TAXDOCPrint;
    Pdf417.PrintTiffFolder:=path;
  except
    on EOleError do begin
      SetStack(ost); Pdf417:=nil; result:=false;
    end;
  end;
  DelStack;
end;

function Pdf417PreviewFile;
var ost: longint;
  f: TForm;
begin
  ost:=AddStack('FPDF417.Pdf417PreviewFile');
  if not Assigned(Pdf417) then Pdf417Init;
  result:=Assigned(Pdf417);
  if result then begin
    f:=BeforeShowOther;
    try
      Pdf417.SetPrintTiffParam('Ќаименование налогового органа-получател€',NameNal);
      Pdf417.PreviewFile(FileName,0,nil);
    except
      on E:EOleError do begin
        SetStack(ost); MsgDlg([E.Message,FileName]); result:=false;
      end;
    end;
    AfterShowOther(f);
  end
  else MsgDlg('Ќе установлен модуль печати машиночитаемых форм.');
  DelStack;
end;

end.
