unit Shifr;

interface

const cShifrPck=#35;

function StrShifr(const st: string; lPck: boolean = false): string;
procedure StrShifrSelf(var st: string; lPck: boolean = false);
function StrDeShifr(const st: string; CanPck: boolean = true): string;
procedure StrDeShifrSelf(var st: string; CanPck: boolean = true);
procedure ZDecompressStrSelf(var s: string);
function ShifrStr(const s: string): string;
function DeShifrStr(const s: string): string;

implementation

uses Windows,SysUtils,Math,
  ZLibEx;

const cEOS = '~';
  aMemTo: array[0..127] of char =
    ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'
    ,'Q','R','S','T','U','V','W','X','Y','Z','А','Б','В','Г','Д','Е'
    ,'Ж','З','И','Й','К','Л','М','Н','О','П','Р','С','Т','У','Ф','Х'
    ,'Ц','Ч','Ш','Щ','Ъ','Ы','Ь','Э','Ю','Я','!','?','a','b','c','d'
    ,'e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t'
    ,'u','v','w','x','y','z','а','б','в','г','д','е','ж','з','и','й'
    ,'к','л','м','н','о','п','р','с','т','у','ф','х','ц','ч','ш','щ'
    ,'ъ','ы','ь','э','ю','я','0','1','2','3','4','5','6','7','8','9'
    );

var aMemFrom: array[byte] of byte;

// Зашифровать строку
function StrShifr;
var i,l,m: longint;
	p1,p2,j: byte;
  fl,fl1: boolean;
  ps: PString;
  s: string;
begin
  m:=0; l:=Length(st);
  if l>0 then begin
    if lPck then begin
      s:=ZCompressStr(st); l:=Length(s); ps:=@s;
    end
    else ps:=@st;
    SetLength(result,IfThen(lPck,1)+Ceil(l*8/7));
    if lPck then begin
      m:=1; result[1]:=cShifrPck;
    end;
    i:=1; j:=0; p2:=0; fl:=false; fl1:=true;
    while fl1 do begin
      if fl then fl1:=false;
      if (j=7) or fl then p1:=0
      else begin
        p1:=Ord(ps^[i]); Inc(i); fl := i>l;
      end;
      inc(m); result[m]:=aMemTo[(p2 or (p1 shr j)) shr 1]; p2 := p1 shl (7-j);
      if j=7 then j:=0 else Inc(j);
    end;
  end;
  SetLength(result,m);
end;

procedure StrShifrSelf;
begin
  st:=StrShifr(st,lPck);
end;

// Расшифровать строку
function StrDeShifr;
var i,l,m: longint;
	p1,p2,j: byte;
  s: string;
  lPck: boolean;
begin
  m:=0; lPck:=false; s:=TrimRight(st); l:=Length(s);
  if l>0 then begin
    if CanPck then lPck := st[1]=cShifrPck;
    if lPck then begin
      s:=Copy(st,2,MaxInt); Dec(l);
    end
    else if s[l]=cEOS then begin
      SetLength(s,l-1); Dec(l);
    end;
    if l>1 then begin
      SetLength(result,l); j:=1; p1:=aMemFrom[Ord(s[1])];
      for i:=2 to l do
        if j=8 then begin
          p1:=aMemFrom[Ord(s[i])]; j:=1;
        end
        else begin
          p2:=aMemFrom[Ord(s[i])]; inc(m); result[m]:=Chr((p1 shl j) or (p2 shr (7-j))); p1:=p2; Inc(j);
        end;
    end;
  end;
  SetLength(result,m);
  if lPck then ZDecompressStrSelf(result);
end;

procedure StrDeShifrSelf;
begin
  st:=StrDeShifr(st,CanPck);
end;

procedure ZDecompressStrSelf;
begin
  s:=ZDecompressStr(s);
end;

function ShifrStr;
var n,i: longint;
begin
  result:=s;
	for i:=1 to length(result) do begin
  	n:=Ord(result[i]);
  	if (n>=33) and (n<=126) then begin
    	Inc(n,20);
      if n>126 then Dec(n,94);
    end
    else if n>=192 then begin
    	Dec(n,30);
      if n<192 then Inc(n,64);
    end;
    result[i]:=Chr(n);
  end;
end;

function DeShifrStr;
var n,i: longint;
begin
  result:=s;
	for i:=1 to length(result) do begin
  	n:=Ord(result[i]);
  	if (n>=33) and (n<=126) then begin
    	Dec(n,20);
      if n<33 then Inc(n,94);
    end
    else if n>=192 then begin
    	Inc(n,30);
      if n>MaxByte then Dec(n,64);
    end;
    result[i]:=Chr(n);
  end;
end;

procedure Init;
var j: byte;
begin
  for j:=low(aMemTo) to high(aMemTo) do aMemFrom[Ord(aMemTo[j])]:=j;
end;

initialization
  Init;
end.
