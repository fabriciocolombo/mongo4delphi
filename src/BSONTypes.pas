unit BSONTypes;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses Contnrs, Classes;

type
  IBSONObject = interface;
  IBSONArray = interface;
  
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
    constructor Create;overload;
    constructor Create(const OID: String);overload;

    class function NewFrom(): IObjectId;
    class function NewFromOID(const OID: String): IObjectId;

    function AsByteArray: TObjectIdByteArray;
    function ToStringMongo: String;
  end;

  TBsonValueType = (bvtNull,
                    bvtBoolean, bvtInteger, bvtInt64, bvtDouble,
                    bvtDateTime, bvtString, bvtInterface);

  TBSONItem = class
  private
    FName: String;
    FValue: Variant;
    FValueType: TBsonValueType;

    procedure SetValue(const Value: Variant);

    function GetAsObjectId: IObjectId;
    function GetAsInteger: Integer;
    function GetAsInt64: Int64;
    function GetAsString: String;
    function GetAsDateTime: TDateTime;
    function GetAsFloat: Double;
    function GetAsBoolean: Boolean;
    function GetAsBSONObject: IBSONObject;
    function GetAsBSONArray: IBSONArray;
  public
    property Name: String read FName;
    property Value: Variant read FValue write SetValue;
    property ValueType: TBsonValueType read FValueType;
    property AsObjectId: IObjectId read GetAsObjectId;
    property AsInteger: Integer read GetAsInteger;
    property AsInt64: Int64 read GetAsInt64;
    property AsString: String read GetAsString;
    property AsDateTime: TDateTime read GetAsDateTime;
    property AsFloat: Double read GetAsFloat;
    property AsBoolean: Boolean read GetAsBoolean;
    property AsBSONObject: IBSONObject read GetAsBSONObject;
    property AsBSONArray: IBSONArray read GetAsBSONArray;

    function GetValueTypeDesc: String;

    function IsInteger: Boolean;
    function IsObjectId: Boolean;

    class function NewFrom(AName: String;const AValue: Variant): TBSONItem;
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

    function Put(const AKey: String; Value: Variant): IBSONObject;
    function Find(const AKey: String): TBSONItem;overload;
    function Find(const AKey: String;var AIndex: Integer): TBSONItem;overload;
    function PutAll(const ASource: IBSONObject): IBSONObject;
  end;

  IBSONArray = interface(IBSONBasicObject)
    ['{ADA231EC-9BD6-4FEB-BCB7-56D88580319E}']

    function Put(Value: Variant): IBSONArray;
  end;

  TBSONObject = class(TInterfacedObject, IBSONObject)
  private
    FMap: TStringList;
    FDuplicatesAction: TDuplicatesAction;
  protected
    procedure PushItem(AItem: TBSONItem);
    function GetItems(AKey: String): TBSONItem;
    function GetItem(AIndex: Integer): TBSONItem;
    procedure SetDuplicatesAction(const Value: TDuplicatesAction);
    function GetDuplicatesAction: TDuplicatesAction;
  public
    constructor Create;
    destructor Destroy; override;

    class function NewFrom(const AKey: String; Value: Variant): IBSONObject;
    class function Empty: IBSONObject;

    property DuplicatesAction: TDuplicatesAction read GetDuplicatesAction write SetDuplicatesAction default daUpdateValue;

    property Items[AKey: String]: TBSONItem read GetItems;
    property Item[AIndex: Integer]: TBSONItem read GetItem;default;

    function Put(const AKey: String; Value: Variant): IBSONObject;
    function Find(const AKey: String): TBSONItem;overload;
    function Find(const AKey: String;var AIndex: Integer): TBSONItem;overload;
    function Count: Integer;

    function PutAll(const ASource: IBSONObject): IBSONObject;
  end;

  TBSONArray = class(TBSONObject, IBSONArray)
  public
    function Put(Value: Variant): IBSONArray;

    class function NewFrom(Value: Variant): IBSONArray;
    class function NewFromValues(Values:Array of Variant): IBSONArray;
    class function NewFromObject(Value: IBSONObject): IBSONArray;
  end;

implementation

uses BSON, windows, Registry, SysUtils, Variants, MongoUtils,
  MongoException, TypInfo;

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

constructor TObjectId.Create(const OID: String);
begin
  inherited Create;

  FOID := OID;
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

class function TObjectId.NewFromOID(const OID: String): IObjectId;
begin
  Result := TObjectId.Create(OID);
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

class function TBSONObject.Empty: IBSONObject;
begin
  Result := TBSONObject.Create;
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

class function TBSONObject.NewFrom(const AKey: String;Value: Variant): IBSONObject;
begin
  Result := TBSONObject.Create;
  Result.Put(AKey, Value);
end;

procedure TBSONObject.PushItem(AItem: TBSONItem);
begin
  FMap.AddObject(AItem.Name, AItem);
end;

function TBSONObject.Put(const AKey: String; Value: Variant): IBSONObject;
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

function TBSONObject.PutAll(const ASource: IBSONObject): IBSONObject;
var
  i: Integer;
begin
  for i := 0 to ASource.Count-1 do
  begin
    Put(ASource[i].Name, ASource[i].Value);
  end;
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

function TBSONItem.GetAsBoolean: Boolean;
begin
  if (FValueType = bvtBoolean) then
    Result := FValue
  else
    raise EConvertError.Create('Cannot convert the value to Boolean.');
end;

function TBSONItem.GetAsBSONArray: IBSONArray;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONArray, Result);
  end;
end;

function TBSONItem.GetAsBSONObject: IBSONObject;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONObject, Result);
  end;
end;

function TBSONItem.GetAsDateTime: TDateTime;
begin
  if (FValueType = bvtDateTime) then
    Result := VarToDateTime(FValue)
  else
    raise EConvertError.Create('Cannot convert the value to TDateTime.');
end;

function TBSONItem.GetAsFloat: Double;
begin
  if (FValueType = bvtDouble) or IsInteger then
    Result := FValue
  else
    raise EConvertError.Create('Cannot convert the value to Double.');
end;

function TBSONItem.GetAsInt64: Int64;
begin
  if IsInteger then
    Result := FValue
  else
    raise EConvertError.Create('Cannot convert the value to Int64.');
end;

function TBSONItem.GetAsInteger: Integer;
begin
  Result := AsInt64;
end;

function TBSONItem.GetAsObjectId: IObjectId;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IObjectId, Result);
  end;
end;

function TBSONItem.GetAsString: String;
begin
  Result := VarToStr(FValue);
end;

function TBSONItem.GetValueTypeDesc: String;
begin
  Result := GetEnumName(TypeInfo(TBsonValueType), Ord(FValueType));
end;

function TBSONItem.IsInteger: Boolean;
begin
  Result := FValueType in [bvtInteger, bvtInt64];
end;

function TBSONItem.IsObjectId: Boolean;
begin
  Result := (FValueType = bvtInterface) and
              Supports(IUnknown(FValue), IObjectId);
end;

class function TBSONItem.NewFrom(AName: String;const AValue: Variant): TBSONItem;
begin
  Result := TBSONItem.Create;
  Result.FName := AName;
  Result.SetValue(AValue);
end;

procedure TBSONItem.SetValue(const Value: Variant);
var
  vCurrencyValue: Currency;
begin
  FValue := Value;

  FValueType := bvtNull;
  case VarType(FValue) and varTypeMask of
    varEmpty, varNull: ;
    varDate: FValueType := bvtDateTime;
    varByte, varSmallint,varInteger,varShortInt,varWord,varLongWord: FValueType := bvtInteger;
    varInt64: FValueType := bvtInt64;
    varSingle,varDouble,varCurrency: begin
                                       vCurrencyValue := FValue;
                                       if Frac(vCurrencyValue) = 0 then
                                         FValueType := bvtInteger
                                       else
                                          FValueType := bvtDouble;
                                     end;  
    varOleStr, varString{$IFDEF UNICODE}, varUString{$ENDIF}: FValueType := bvtString;
    varBoolean: FValueType := bvtBoolean;
    varDispatch, varUnknown: FValueType := bvtInterface;
  else
    raise Exception.CreateFmt('Type "%s" not implemented.', [IntToHex(VarType(FValue), 4)]);
  end;
end;

{ TBSONArray }

class function TBSONArray.NewFrom(Value: Variant): IBSONArray;
begin
  Result := TBSONArray.Create;
  Result.Put(Value);
end;

class function TBSONArray.NewFromObject(Value: IBSONObject): IBSONArray;
var
  i: Integer;
begin
  Result := TBSONArray.Create;

  for i := 0 to Value.Count-1 do
  begin
    Result.Put(Value[i].Value);
  end;
end;

class function TBSONArray.NewFromValues(Values: array of Variant): IBSONArray;
var
  i: Integer;
begin
  Result := TBSONArray.Create;

  for i := Low(Values) to High(Values) do
  begin
    Result.Put(Values[i]);
  end;
end;

function TBSONArray.Put(Value: Variant): IBSONArray;
var
  vKey: String;
begin
  vKey := IntToStr(Count);

  inherited Put(vKey, Value);

  Result := Self;
end;

initialization
  InitMongoObjectID;
  
end.
