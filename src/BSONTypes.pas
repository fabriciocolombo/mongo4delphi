unit BSONTypes;

interface

uses Contnrs, Classes;

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

  TBSONItem = class
  private
    FName: String;
    FValue: OleVariant;
    FValueType: Integer;
    procedure SetValue(const Value: OleVariant);
  public
    property Name: String read FName;
    property Value: OleVariant read FValue write SetValue;
    property ValueType: Integer read FValueType;

    class function NewFrom(AName: String; AValue: OleVariant): TBSONItem;
  end;

  TDuplicatesAction = (daUpdateValue, daError);

  IBSONBasicObject = interface
    ['{FF4178D1-D45B-480D-9704-85ACD5BA02E9}']
    function GetItem(AIndex: Integer): TBSONItem;

    property Item[AIndex: Integer]: TBSONItem read GetItem;default;

    function Count: Integer;
  end;

  IBSONObject = interface(IBSONBasicObject)
    ['{BC5F07D7-0A81-40AF-9F09-E8DA38BC446C}']

    function GetItems(AKey: String): TBSONItem;
    function GetDuplicatesAction: TDuplicatesAction;

    procedure SetDuplicatesAction(const Value: TDuplicatesAction);

    property DuplicatesAction: TDuplicatesAction read GetDuplicatesAction write SetDuplicatesAction;
    property Items[AKey: String]: TBSONItem read GetItems;

    function Put(const AKey: String; Value: OleVariant): IBSONObject;
    function Find(const AKey: String): TBSONItem;overload;
    function Find(const AKey: String;var AIndex: Integer): TBSONItem;overload;
  end;

  IBSONArray = interface(IBSONBasicObject)
    ['{ADA231EC-9BD6-4FEB-BCB7-56D88580319E}']

    function Put(Value: OleVariant): IBSONObject;
  end;

  TBSONObject = class(TInterfacedObject, IBSONObject)
  private
    FMap: TStringList;
    FDuplicatesAction: TDuplicatesAction;

    procedure PushItem(AItem: TBSONItem);
    function GetItems(AKey: String): TBSONItem;
    function GetItem(AIndex: Integer): TBSONItem;
    procedure SetDuplicatesAction(const Value: TDuplicatesAction);
    function GetDuplicatesAction: TDuplicatesAction;
  public
    constructor Create;
    destructor Destroy; override;

    class function NewFrom(const AKey: String; Value: OleVariant): IBSONObject;

    property DuplicatesAction: TDuplicatesAction read GetDuplicatesAction write SetDuplicatesAction default daUpdateValue;

    property Items[AKey: String]: TBSONItem read GetItems;
    property Item[AIndex: Integer]: TBSONItem read GetItem;default;

    function Put(const AKey: String; Value: OleVariant): IBSONObject;
    function Find(const AKey: String): TBSONItem;overload;
    function Find(const AKey: String;var AIndex: Integer): TBSONItem;overload;
    function Count: Integer;
  end;

  TBSONArray = class(TBSONObject, IBSONArray)
  public
    function Put(Value: OleVariant): IBSONObject;

    class function NewFrom(Value: OleVariant): IBSONArray;
  end;

implementation

uses BSON, windows, Registry, SysUtils, Variants, MongoUtils,
  MongoException;

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

{ TBSONObject }

function TBSONObject.Count: Integer;
begin
  Result := FMap.Count;
end;

constructor TBSONObject.Create;
begin
  FMap := TStringList.Create;
  FDuplicatesAction := daUpdateValue;
end;

destructor TBSONObject.Destroy;
begin
  TListUtils.FreeObjects(FMap);
  FMap.Free;
  inherited;
end;

function TBSONObject.Find(const AKey: String): TBSONItem;
var
  vIndex: Integer;
begin
  Result := Find(AKey, vIndex);
end;

function TBSONObject.Find(const AKey: String;var AIndex: Integer): TBSONItem;
begin
  Result := nil;

  AIndex := FMap.IndexOf(AKey);

  if (AIndex >= 0) then
  begin
    Result := TBSONItem(FMap.Objects[AIndex]);
  end;
end;

function TBSONObject.GetDuplicatesAction: TDuplicatesAction;
begin
  Result := FDuplicatesAction;
end;

function TBSONObject.GetItem(AIndex: Integer): TBSONItem;
begin
  Result := TBSONItem(FMap.Objects[AIndex]);
end;

function TBSONObject.GetItems(AKey: String): TBSONItem;
begin
  Result := Find(AKey);

  if (Result = nil) then
  begin
    Result := TBSONItem.NewFrom(AKey, Null);

    PushItem(Result);
  end;
end;

class function TBSONObject.NewFrom(const AKey: String;Value: OleVariant): IBSONObject;
begin
  Result := TBSONObject.Create;
  Result.Put(AKey, Value);
end;

procedure TBSONObject.PushItem(AItem: TBSONItem);
begin
  FMap.AddObject(AItem.Name, AItem);
end;

function TBSONObject.Put(const AKey: String; Value: OleVariant): IBSONObject;
var
  vItem: TBSONItem;
begin
  vItem := Find(AKey);

  if Assigned(vItem) then
  begin
    if (FDuplicatesAction = daError) then
      raise EBSONDuplicateKeyInList.CreateResFmt(@sBSONDuplicateKeyInList, [AKey]);

    vItem.Value := Value;
  end
  else
  begin
    PushItem(TBSONItem.NewFrom(AKey, Value));
  end;

  Result := Self;
end;

procedure TBSONObject.SetDuplicatesAction(const Value: TDuplicatesAction);
begin
  if (FDuplicatesAction <> Value) then
  begin
    if (FMap.Count > 0) then
      raise EBSONCannotChangeDuplicateAction.CreateRes(@sBSONCannotChangeDuplicateAction);

    FDuplicatesAction := Value;
  end;
end;

{ TBSONItem }

class function TBSONItem.NewFrom(AName: String; AValue: OleVariant): TBSONItem;
begin
  Result := TBSONItem.Create;
  Result.FName := AName;
  Result.SetValue(AValue);
end;

procedure TBSONItem.SetValue(const Value: OleVariant);
begin
  FValue := Value;
  FValueType := VarType(FValue) and varTypeMask;
end;

{ TBSONArray }

class function TBSONArray.NewFrom(Value: OleVariant): IBSONArray;
begin
  Result := TBSONArray.Create;
  Result.Put(Value);
end;

function TBSONArray.Put(Value: OleVariant): IBSONObject;
var
  vKey: String;
begin
  vKey := IntToStr(Count);

  Result := inherited Put(vKey, Value);
end;

initialization
  InitMongoObjectID;
  
end.
