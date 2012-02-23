unit BSONTypes;

interface

type
  TObjectIdByteArray = array[0..11] of byte;

  IObjectId = interface
  ['{B666B7F9-2E6A-45EA-A686-BCF212821AAA}']
    function AsByteArray: TObjectIdByteArray;
    function ToStringMongo: String;
  end;

  TObjectId = class(TInterfacedObject, IObjectId)
  private
    FOID: String;

    procedure GenId;
  public
    constructor Create;

    class function NewFrom(): IObjectId;

    function AsByteArray: TObjectIdByteArray;
    function ToStringMongo: String;
   end;

implementation

uses BSON, windows, Registry, SysUtils;

var
  _mongoObjectID_MachineID: Integer;
  _mongoObjectID_Counter: Integer;

procedure InitMongoObjectID;
const 
  KEY_WOW64_64KEY = $0100;
var
  r:TRegistry;
  s:string;
  i,l:integer;
begin
  //render a number out of the host name
  r:=TRegistry.Create(KEY_READ or KEY_WOW64_64KEY);
  try
    r.RootKey:=HKEY_LOCAL_MACHINE;
    if r.OpenKey('\Software\Microsoft\Cryptography',false) then
      s:=r.ReadString('MachineGuid')
    else
      s:='';
  finally
    r.Free;
  end;
  if s='' then
   begin
    l:=MAX_PATH;
    SetLength(s,l);
    if GetComputerName(PChar(s),cardinal(l)) then SetLength(s,l) else
      s:=GetEnvironmentVariable('COMPUTERNAME');
    _mongoObjectID_MachineID:=$10101;
    for i:=1 to Length(s) do
      case s[i] of
        '0'..'9':
          _mongoObjectID_MachineID:=(_mongoObjectID_MachineID*36+(byte(s[i]) and $0F)) and $FFFFFF;
        'A'..'Z','a'..'z':
          _mongoObjectID_MachineID:=(_mongoObjectID_MachineID*36+(byte(s[i]) and $1F)+9) and $FFFFFF;
        //else ignore
      end;
   end
  else
    _mongoObjectID_MachineID:=StrToInt('$'+Copy(s,1,6));

  _mongoObjectID_Counter := GetTickCount;
end;

{ TObjectId }

function TObjectId.AsByteArray: TObjectIdByteArray;
var
  vStringOID: String;
  i, j: Integer;
  vByte: Byte;
begin
  vStringOID := ToStringMongo;
  j := length(BSON_OBJECTID_PREFIX)+1;
  for i:=0 to 11 do
  begin
    vByte := byte(AnsiChar(vStringOID[j+i*2]));

    if (vByte and $F0) = $30 then
      Result[i] := vByte shl 4
    else
      Result[i] := (9+vByte) shl 4;

    vByte := byte(AnsiChar(vStringOID[j+i*2+1]));
    
    if (vByte and $F0)=$30 then
      inc(Result[i], vByte and $F)
    else
      inc(Result[i],(9+ vByte) and $F);
  end;
end;

constructor TObjectId.Create;
begin
  inherited;
  
  GenId;
end;

procedure TObjectId.GenId;
var
  st:TSystemTime;
  a,b,c,d:integer;
const
  hex:array[0..15] of char='0123456789abcdef';
begin
  GetSystemTime(st);
  
  a:= (((Round(EncodeDate(st.wYear,st.wMonth,st.wDay))-UnixDateDelta)*24+st.wHour)*60+st.wMinute)*60+st.wSecond;
  b:= _mongoObjectID_MachineID;
  c:= GetCurrentThreadId;//GetCurrentProcessId;
  d:= InterlockedIncrement(_mongoObjectID_Counter);
  FOID:=
    hex[(a shr 28) and $F]+hex[(a shr 24) and $F]+
    hex[(a shr 20) and $F]+hex[(a shr 16) and $F]+
    hex[(a shr 12) and $F]+hex[(a shr  8) and $F]+
    hex[(a shr  4) and $F]+hex[(a       ) and $F]+

    hex[(b shr 20) and $F]+hex[(b shr 16) and $F]+
    hex[(b shr 12) and $F]+hex[(b shr  8) and $F]+
    hex[(b shr  4) and $F]+hex[(b       ) and $F]+

    hex[(c shr 12) and $F]+hex[(c shr  8) and $F]+
    hex[(c shr  4) and $F]+hex[(c       ) and $F]+

    hex[(d shr 20) and $F]+hex[(d shr 16) and $F]+
    hex[(d shr 12) and $F]+hex[(d shr  8) and $F]+
    hex[(d shr  4) and $F]+hex[(d       ) and $F];
end;

class function TObjectId.NewFrom: IObjectId;
begin
  Result := TObjectId.Create;
end;

function TObjectId.ToStringMongo: String;
begin
  Result := Format('%s%s%s', [BSON_OBJECTID_PREFIX, FOID, BSON_OBJECTID_SUFIX]);
end;

initialization
  InitMongoObjectID;
  
end.
