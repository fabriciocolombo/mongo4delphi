unit MongoMD5;

interface

uses {$IFDEF FPC}MD5,{$ELSE}IdHashMessageDigest, idHash,{$ENDIF} SysUtils;

function MD5(value: String): String;

implementation

function MD5(value: String): String;
{$IFDEF FPC}
begin
  Result := LowerCase(MD5Print(MD5String(UTF8Encode(value))));
end;
{$ELSE}
var
  vIdMD5: TIdHashMessageDigest5;
begin
  vIdMD5 := TIdHashMessageDigest5.Create;
  try
    {$IFDEF UNICODE} //Is the correct directive to use?
    Result := vIdMD5.HashStringAsHex(value, TEncoding.UTF8);
    {$ELSE}
    Result := vIdMD5.AsHex(vIdMD5.HashValue(UTF8Encode(PAnsiChar(value))));
    {$ENDIF}

    Result := LowerCase(Result);
  finally
    vIdMD5.Free;
  end;
end;
{$ENDIF}

end.
