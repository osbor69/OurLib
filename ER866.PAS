unit ER866;

interface

uses Graphics;

type TDosWinOpt = set of (doswinGraph,doswinAbcOnly);

// Преобразование строки с кодировкой DOS в кодировку WINDOWS
function DosToWin(const s: string; Opt: TDosWinOpt = []): string;
procedure DosToWinSelf(var s: string; Opt: TDosWinOpt = []);
// Преобразование строки с кодировкой WINDOWS в кодировку DOS
function WinToDos(const s: string; Opt: TDosWinOpt = []): string;
procedure WinToDosSelf(var s: string; Opt: TDosWinOpt = []);
// Есть ли шрифты ER866
function ER866IsFonts: boolean;
// Вывести текст шрифтом ER866
procedure ER866TextOut(Canvas: TCanvas; X,Y: longint; const Text: string);

const aEr866FontName: array[boolean] of string = ('ER KURIER 866','ER KURIER 866 1');

implementation

uses Forms;

type TTblChr = array[byte] of byte;
	TTbl866 = record
    cod: byte;
  	grph: boolean;
  end;

var aWD: TTblChr;
  aDW: array[boolean] of TTblChr;
  a866: array[byte] of TTbl866;

function ChrDW(s: string; const a: TTblChr; abcOnly: boolean): string;
var i: longint;
  procedure Chr1;
  var p,p1: Byte;
  begin
    p:=Ord(s[i]); p1:=a[p];
    if p<>p1 then result[i]:=Chr(p1);
    if (abcOnly) and (p = p1) and (p >= $80) then result[i]:= '?';
  end;
begin
	result:=s;
	for i:=1 to length(s) do Chr1;
end;

function DosToWin;
begin
	result:=ChrDW(s,aDW[doswinGraph in Opt],doswinAbcOnly in Opt);
end;

procedure DosToWinSelf;
begin
  s:=DosToWin(s,Opt);
end;

function WinToDos;
begin
	result:=ChrDW(s,aWD,doswinAbcOnly in Opt);
end;

procedure WinToDosSelf;
begin
  s:=WinToDos(s,Opt);
end;

function ER866IsFonts;
var fl: boolean;
begin
  result:=true;
  for fl:=false to true do if Screen.Fonts.IndexOf(aEr866FontName[fl])<0 then begin
    result:=false; break;
  end;
end;

procedure ER866TextOut;
var i: longint;
	function IsGraphic: boolean;
  begin
    //result := Text[i] in [#179..#218];
    result:=a866[Ord(Text[i])].grph;
  end;
var p,l: longint;
	fl: boolean;
  s: string;
begin
  i:=1; l:=Length(Text);
  while i<=l do begin
  	p:=i; fl:=IsGraphic;
    repeat
    	Inc(i);
    until (i>l) or (IsGraphic<>fl);
    s:=Copy(Text,p,i-p); Canvas.Font.Name:=aEr866FontName[fl];
    //if fl then for p:=1 to Length(s) do s[p]:=Chr(Ord(s[p])-114) else DosToWinSelf(s);
    for p:=1 to Length(s) do s[p]:=Chr(a866[Ord(s[p])].cod);
    Canvas.TextOut(X,Y,s); Inc(X,Canvas.TextWidth(s));
  end;
end;

procedure Init;
  procedure ChrInc(l,h: byte; inc: longint);
  var i: byte;
    fl: boolean;
  begin
    for i:=l to h do begin
      aWD[i+inc]:=i;
      for fl:=false to true do aDW[fl][i]:=i+inc;
    end;
  end;
  procedure Chr1(cDos: byte; cWin: char);
  begin
    ChrInc(cDos,cDos,Ord(cWin)-cDos);
  end;
const
  a1: array[1..19] of byte = (180,182,183,189,191,192,193,194,195,196,197,199,
    208,210,211,214,215,217,218);
  a2: array[1..19] of byte = (181,184,185,187,188,190,198,200,201,202,203,204,
    205,206,207,209,212,213,216);
  ac866: array[1..39] of record
    ocod: byte;
    t: TTbl866
  end =
  ((ocod:128; t:(cod:65            )) //А
  ,(ocod:129; t:(cod:32 ; grph:true)) //Б
  ,(ocod:131; t:(cod:33 ; grph:true)) //Г
  ,(ocod:136; t:(cod:34 ; grph:true)) //И
  ,(ocod:138; t:(cod:75            )) //К
  ,(ocod:140; t:(cod:77            )) //М
  ,(ocod:141; t:(cod:72            )) //Н
  ,(ocod:142; t:(cod:79            )) //О
  ,(ocod:143; t:(cod:35 ; grph:true)) //П
  ,(ocod:144; t:(cod:80            )) //Р
  ,(ocod:152; t:(cod:57 ; grph:true)) //Ш
  ,(ocod:154; t:(cod:36 ; grph:true)) //Ъ
  ,(ocod:156; t:(cod:37 ; grph:true)) //Ь
  ,(ocod:157; t:(cod:38 ; grph:true)) //Ь
  ,(ocod:158; t:(cod:176           )) //Ю
  ,(ocod:159; t:(cod:39 ; grph:true)) //Я
  ,(ocod:161; t:(cod:40 ; grph:true)) //б
  ,(ocod:162; t:(cod:41 ; grph:true)) //в
  ,(ocod:163; t:(cod:42 ; grph:true)) //г
  ,(ocod:165; t:(cod:101           )) //е
  ,(ocod:168; t:(cod:43 ; grph:true)) //и
  ,(ocod:170; t:(cod:107           )) //к
  ,(ocod:175; t:(cod:44 ; grph:true)) //п
  ,(ocod:224; t:(cod:112           )) //р
  ,(ocod:225; t:(cod:99            )) //с
  ,(ocod:226; t:(cod:45 ; grph:true)) //т
  ,(ocod:227; t:(cod:121           )) //у
  ,(ocod:228; t:(cod:46 ; grph:true)) //ф
  ,(ocod:229; t:(cod:120           )) //х
  ,(ocod:230; t:(cod:47 ; grph:true)) //ц
  ,(ocod:231; t:(cod:48 ; grph:true)) //ч
  ,(ocod:232; t:(cod:49 ; grph:true)) //ш
  ,(ocod:233; t:(cod:50 ; grph:true)) //щ
  ,(ocod:234; t:(cod:51 ; grph:true)) //ъ
  ,(ocod:235; t:(cod:52 ; grph:true)) //ы
  ,(ocod:236; t:(cod:53 ; grph:true)) //ь
  ,(ocod:237; t:(cod:54 ; grph:true)) //э
  ,(ocod:238; t:(cod:55 ; grph:true)) //ю
  ,(ocod:239; t:(cod:56 ; grph:true)) //я
  );
var i: longint;
  fl: boolean;
begin
  for i:=low(byte) to high(byte) do begin
    aWD[i]:=i;
    for fl:=false to true do aDW[fl,i]:=i;
    a866[i].grph:=false; a866[i].cod:=i;
  end;
  ChrInc(128,175,64); // А - п
  ChrInc(224,239,16); // п - я
  Chr1(240,'Ё');
  Chr1(241,'ё');
  Chr1(242,'Є');
  Chr1(243,'є');
  Chr1(244,'Ї');
  Chr1(245,'ї');
  Chr1(246,'Ў');
  Chr1(247,'ў');
  Chr1(248,'°');
  Chr1(249,'•');
  Chr1(250,'·');
  Chr1(252,'№');
  Chr1(253,'¤');
  aDW[true][179]:=Ord('|'); aDW[true][186]:=Ord('!');
  for i:=low(a1) to high(a1) do aDW[true][a1[i]]:=Ord('-');
  for i:=low(a2) to high(a2) do aDW[true][a2[i]]:=Ord('=');
  for i:=low(ac866) to high(ac866) do with ac866[i] do a866[ocod]:=t;
  for i:=179 to 218 do with a866[i] do begin
  	grph:=true; Dec(cod,114);
  end;
end;

initialization
  Init;
end.
