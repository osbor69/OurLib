unit Crypto;

interface

uses Classes, HCMngr;

type
  THardInt = packed array[1..4]of byte;
  TCryptoStream = class(TStream)
  private
    FStream: TStream;
    FCipherMng: TCipherManager;
    FReadBuf: string;
  public
    constructor Create(aStream: TStream; const aPswd: string);
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function EncodeStr(const s: string): string;
    function DecodeStr(const s: string): string;
    class function Hard2Int(const hi: THardInt): longword;
    class function Int2Hard(int2Write: longword): THardInt;
  end;

implementation
{$B-}

uses SysUtils, Math;

constructor TCryptoStream.Create;
var s: string;
begin
  FStream:=aStream; s:=TrimRight(aPswd);
  if s<>'' then begin
    FCipherMng:=TCipherManager.Create(nil);
    FCipherMng.Algorithm:='Blowfish';
    FCipherMng.InitKey(s,nil);
  end;
end;

destructor TCryptoStream.Destroy;
begin
  inherited;
  FCipherMng.Free;
end;

function TCryptoStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  result:=FStream.Seek(Offset,Origin);
end;

class function TCryptoStream.Hard2Int;
begin
  result:=(((((hi[1] shl 8)or hi[2])shl 8)or hi[3])shl 8)or hi[4];
end;

class function TCryptoStream.Int2Hard;
begin
  result[4]:=int2Write;
  int2Write:=int2Write shr 8;
  result[3]:=int2Write;
  int2Write:=int2Write shr 8;
  result[2]:=int2Write;
  result[1]:=int2Write shr 8;
end;

function TCryptoStream.Read;
var s: string;
    k: longint;
    hi: THardInt;
begin
  if Assigned(FCipherMng) then begin
    while (length(FReadBuf)<Count) do begin
      k:=FStream.Read(hi,SizeOf(THardInt));
      if (k<>SizeOf(THardInt)) then begin
        if (k>0) then begin
          {нарушено содержимое}
        end;
        break;
      end;
      k:=Hard2Int(hi);
      if (k>20*1024*1024) then begin
        {нарушено содержимое}
        break;
      end;
      SetLength(s,k);
      k:=FStream.Read(pchar(s)^,length(s));
      if (k<>length(s)) then begin
        {нарушено содержимое}
        break;
      end;
      try
        FCipherMng.DecodeBuffer(pchar(s)^,pchar(s)^,k);
      except
        {неверный пароль}
      end;
      FReadBuf:=FReadBuf+s;
    end;
    result:=min(length(FReadBuf),Count);
    Move(pchar(FReadBuf)^,Buffer,result);
    Delete(FReadBuf,1,result);
  end
  else result:=FStream.Read(Buffer,Count);
end;

function TCryptoStream.Write;
var s: string;
    hi: THardInt;
begin
  if Assigned(FCipherMng) then begin
    result:=0;
    SetLength(s,Count);
    FCipherMng.EncodeBuffer(Buffer,pchar(s)^,Count);
    hi:=Int2Hard(Count);
    if (FStream.Write(hi,SizeOf(THardInt))=SizeOf(THardInt)) then begin
      if (FStream.Write(pchar(s)^,Count)=Count) then begin
        result:=Count;
      end;
    end;
  end
  else result:=FStream.Write(Buffer,Count);
end;

function TCryptoStream.EncodeStr;
var k: longint;
begin
  if Assigned(FCipherMng) then begin
    k:=length(s); SetLength(result,k); FCipherMng.EncodeBuffer(pchar(s)^,pchar(result)^,k);
  end
  else result:='';
end;

function TCryptoStream.DecodeStr;
var k: longint;
begin
  if Assigned(FCipherMng) then begin
    k:=length(s); SetLength(result,k); FCipherMng.DecodeBuffer(pchar(s)^,pchar(result)^,k);
  end
  else result:='';
end;

end.
