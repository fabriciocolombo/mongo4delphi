{***************************************************************************}
{                                                                           }
{                    Mongo Delphi Driver                                    }
{                                                                           }
{           Copyright (c) 2012 Fabricio Colombo                             }
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}
unit BSONTypes;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses Contnrs, Classes, BSON;
//     {$IF CompilerVersion >= 22}RegularExpressionsCore{$ELSE}PerlRegEx{$IFEND};

type
  TBSONItem = class;
  IBSONObject = interface;

  TDuplicatesAction = (daUpdateValue, daError);

  TBsonValueType = (bvtNull,
                    bvtBoolean, bvtInteger, bvtInt64, bvtDouble,
                    bvtDateTime, bvtString, bvtInterface);

  TBSONObjectIdByteArray = array[0..11] of byte;

  IBSONObjectId = interface
    ['{B666B7F9-2E6A-45EA-A686-BCF212821AAA}']
    function AsByteArray: TBSONObjectIdByteArray;
    function ToStringMongo: String;
  end;

  IBSONBinary = interface
  ['{37130A33-E87F-491B-8061-84C7F4A8AC1A}']
    function GetStream: TMemoryStream;
    function GetSize: Integer;
    function GetSubType: Integer;

    property Stream: TMemoryStream read GetStream;
    property Size: Integer read GetSize;
    property SubType: Integer read GetSubType;
  end;

  IBSONRegEx = interface
  ['{504A4D84-3C11-49CA-8F11-2FAE90A18A38}']
    procedure SetCaseInsensitive_I(const Value: Boolean);
    procedure SetDotAll_S(const Value: Boolean);
    procedure SetVerbose_X(const Value: Boolean);
    procedure SetMultiline_M(const Value: Boolean);
    procedure SetPattern(const Value: String);
    procedure SetLocaleDependent_L(const Value: Boolean);
    procedure SetUnicode_U(const Value: Boolean);
    function GetCaseInsensitive_I: Boolean;
    function GetDotAll_S: Boolean;
    function GetVerbose_X: Boolean;
    function GetMultiline_M: Boolean;
    function GetPattern: String;
    function GetLocaleDependent_L: Boolean;
    function GetUnicode_U: Boolean;

    property Pattern: String read GetPattern write SetPattern;
    property CaseInsensitive_I: Boolean read GetCaseInsensitive_I write SetCaseInsensitive_I;
    property Multiline_M: Boolean read GetMultiline_M write SetMultiline_M;
    property Verbose_X: Boolean read GetVerbose_X write SetVerbose_X;
    property DotAll_S: Boolean read GetDotAll_S write SetDotAll_S;
    property LocaleDependent_L: Boolean read GetLocaleDependent_L write SetLocaleDependent_L;
    property Unicode_U: Boolean read GetUnicode_U write SetUnicode_U;

    function GetOptions: String;
    procedure SetOptions(const AOptions: String);
  end;

  IBSONSymbol = interface
  ['{D1889152-5905-494F-9F20-5EB2DC74130F}']

    procedure SetSymbol(const Value: String);
    function GetSymbol: String;

    property Symbol: String read GetSymbol write SetSymbol;
  end;

  IBSONCode = interface
  ['{40331741-7564-4696-A687-2623CFFEF828}']

    procedure SetCode(const Value: String);
    function GetCode: String;
    property Code: String read GetCode write SetCode;
  end;

  IBSONCode_W_Scope = interface
  ['{C108B8AC-0520-40FB-992F-D160A0160F77}']

    procedure SetCode(const Value: String);
    procedure SetScope(const Value: IBSONObject);
    function GetCode: String;
    function GetScope: IBSONObject;

    property Code: String read GetCode write SetCode;
    property Scope: IBSONObject read GetScope write SetScope;
  end;

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
    function Find(const AKey: String;var AIndex: Integer): Boolean;overload;
    function PutAll(const ASource: IBSONObject): IBSONObject;

    function HasOid: Boolean;
    function GetOid: IBSONObjectId;
  end;

  IBSONArray = interface(IBSONBasicObject)
    ['{ADA231EC-9BD6-4FEB-BCB7-56D88580319E}']

    function Put(Value: Variant): IBSONArray;
  end;

  TBSONObjectId = class(TInterfacedObject, IBSONObjectId)
  private
    FOID: String;

    procedure GenId;
  public
    constructor Create;overload;
    constructor Create(const OID: String);overload;

    class function NewFrom(): IBSONObjectId;
    class function NewFromOID(const OID: String): IBSONObjectId;

    function AsByteArray: TBSONObjectIdByteArray;
    function ToStringMongo: String;
  end;

  TBSONBinary = class(TInterfacedObject, IBSONBinary)
  private
    FStream: TMemoryStream;
    FSubType: Integer;
    function GetStream: TMemoryStream;
    function GetSubType: Integer;
    function GetSize: Integer;
  public
    constructor Create(ASubType: Integer = BSON_SUBTYPE_GENERIC);

    class function NewFromFile(AFileName: String; ASubType: Integer = BSON_SUBTYPE_GENERIC): IBSONBinary;

    destructor Destroy; override;

    property Stream: TMemoryStream read GetStream;
    property SubType: Integer read GetSubType;
    property Size: Integer read GetSize;
  end;

  //Do not match the pattern in client-side
  TBSONRegEx = class(TInterfacedObject, IBSONRegEx)
  private
    FDotAll_S: Boolean;
    FMultiline_M: Boolean;
    FVerbose_X: Boolean;
    FCaseInsensitive_I: Boolean;
    FPattern: String;
    FUnicode_U: Boolean;
    FLocaleDependent_L: Boolean;
    procedure SetCaseInsensitive_I(const Value: Boolean);
    procedure SetDotAll_S(const Value: Boolean);
    procedure SetVerbose_X(const Value: Boolean);
    procedure SetMultiline_M(const Value: Boolean);
    procedure SetPattern(const Value: String);
    procedure SetLocaleDependent_L(const Value: Boolean);
    procedure SetUnicode_U(const Value: Boolean);
    function GetCaseInsensitive_I: Boolean;
    function GetDotAll_S: Boolean;
    function GetVerbose_X: Boolean;
    function GetMultiline_M: Boolean;
    function GetPattern: String;
    function GetLocaleDependent_L: Boolean;
    function GetUnicode_U: Boolean;
  public
    property Pattern: String read GetPattern write SetPattern;
    property CaseInsensitive_I: Boolean read GetCaseInsensitive_I write SetCaseInsensitive_I;
    property Multiline_M: Boolean read GetMultiline_M write SetMultiline_M;
    property Verbose_X: Boolean read GetVerbose_X write SetVerbose_X;
    property DotAll_S: Boolean read GetDotAll_S write SetDotAll_S;
    property LocaleDependent_L: Boolean read GetLocaleDependent_L write SetLocaleDependent_L;
    property Unicode_U: Boolean read GetUnicode_U write SetUnicode_U;

    function GetOptions: String;
    procedure SetOptions(const AOptions: String);

    class function NewFrom(APattern: String; AOptions: String=''): IBSONRegEx;
  end;

  TBSONSymbol = class(TInterfacedObject, IBSONSymbol)
  private
    FSymbol: String;
    procedure SetSymbol(const Value: String);
    function GetSymbol: String;
  public
    property Symbol: String read GetSymbol write SetSymbol;

    class function NewFrom(const ASymbol: String): IBSONSymbol;
  end;

  TBSONCode = class(TInterfacedObject, IBSONCode)
  private
    FCode: String;
    procedure SetCode(const Value: String);
    function GetCode: String;
  public
    property Code: String read GetCode write SetCode;

    class function NewFrom(const ACode: String): IBSONCode;
  end;

  TBSONCode_W_Scope = class(TInterfacedObject, IBSONCode_W_Scope)
  private
    FCode: String;
    FScope: IBSONObject;
    procedure SetCode(const Value: String);
    procedure SetScope(const Value: IBSONObject);
    function GetCode: String;
    function GetScope: IBSONObject;
  public
    property Code: String read GetCode write SetCode;
    property Scope: IBSONObject read GetScope write SetScope;

    class function NewFrom(const ACode: String;const AScope: IBSONObject): IBSONCode_W_Scope;
  end;

  TBSONItem = class
  private
    FName: String;
    FValue: Variant;
    FValueType: TBsonValueType;

    procedure SetValue(const Value: Variant);

    function GetAsObjectId: IBSONObjectId;
    function GetAsInteger: Integer;
    function GetAsInt64: Int64;
    function GetAsString: String;
    function GetAsDateTime: TDateTime;
    function GetAsFloat: Double;
    function GetAsBoolean: Boolean;
    function GetAsBSONObject: IBSONObject;
    function GetAsBSONArray: IBSONArray;
    function GetAsBSONBinary: IBSONBinary;
    function GetAsBSONRegEx: IBSONRegEx;
    function GetAsBSONSymbol: IBSONSymbol;
    function GetAsBSONCode: IBSONCode;
    function GetAsBSONCode_W_Scope: IBSONCode_W_Scope;
  public
    property Name: String read FName;
    property Value: Variant read FValue write SetValue;
    property ValueType: TBsonValueType read FValueType;
    property AsObjectId: IBSONObjectId read GetAsObjectId;
    property AsInteger: Integer read GetAsInteger;
    property AsInt64: Int64 read GetAsInt64;
    property AsString: String read GetAsString;
    property AsDateTime: TDateTime read GetAsDateTime;
    property AsFloat: Double read GetAsFloat;
    property AsBoolean: Boolean read GetAsBoolean;
    property AsBSONObject: IBSONObject read GetAsBSONObject;
    property AsBSONArray: IBSONArray read GetAsBSONArray;
    property AsBSONBinary: IBSONBinary read GetAsBSONBinary;
    property AsBSONRegEx: IBSONRegEx read GetAsBSONRegEx;
    property AsBSONSymbol: IBSONSymbol read GetAsBSONSymbol;
    property AsBSONCode: IBSONCode read GetAsBSONCode;
    property AsBSONCode_W_Scope: IBSONCode_W_Scope read GetAsBSONCode_W_Scope; 

    function GetValueTypeDesc: String;

    function IsInteger: Boolean;
    function IsObjectId: Boolean;

    class function NewFrom(AName: String;const AValue: Variant): TBSONItem;
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
    function Find(const AKey: String;var AIndex: Integer): Boolean;overload;
    function Count: Integer;

    function PutAll(const ASource: IBSONObject): IBSONObject;

    function HasOid: Boolean;
    function GetOid: IBSONObjectId;
  end;

  TBSONArray = class(TBSONObject, IBSONArray)
  public
    function Put(Value: Variant): IBSONArray;

    class function NewFrom(Value: Variant): IBSONArray;
    class function NewFromValues(Values:Array of Variant): IBSONArray;
    class function NewFromObject(Value: IBSONObject): IBSONArray;
  end;

  TBSONObjectQueryHelper = class
  private
  public
    //All items must contain a _id field

    class function NewFilterOid(AObjects: IBSONObject): IBSONObject;
    class function NewFilterBatchOID(AObjects: Array of IBSONObject): IBSONObject;
  end;

implementation

uses windows, Registry, SysUtils, Variants, MongoUtils,
  MongoException, TypInfo, StrUtils;

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

{ TBSONObjectId }

function TBSONObjectId.AsByteArray: TBSONObjectIdByteArray;
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

constructor TBSONObjectId.Create;
begin
  inherited;
  
  GenId;
end;

constructor TBSONObjectId.Create(const OID: String);
begin
  inherited Create;

  FOID := OID;
end;

procedure TBSONObjectId.GenId;
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

class function TBSONObjectId.NewFrom: IBSONObjectId;
begin
  Result := TBSONObjectId.Create;
end;

class function TBSONObjectId.NewFromOID(const OID: String): IBSONObjectId;
begin
  Result := TBSONObjectId.Create(OID);
end;

function TBSONObjectId.ToStringMongo: String;
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
  Result := nil;

  if Find(AKey, vIndex) then
  begin
    Result := Item[vIndex];
  end;
end;

class function TBSONObject.Empty: IBSONObject;
begin
  Result := TBSONObject.Create;
end;

function TBSONObject.Find(const AKey: String;var AIndex: Integer): Boolean;
begin
  AIndex := FMap.IndexOf(AKey);

  Result := (AIndex >= 0);
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

function TBSONObject.HasOid: Boolean;
var
  vItem: TBSONItem;
begin
  vItem := Find('_id');

  Result := Assigned(vItem) and Assigned(vItem.AsObjectId);
end;

function TBSONObject.GetOid: IBSONObjectId;
var
  vIndex: Integer;
  vItem: TBSONItem;
begin
  Result := nil;

  if Find('_id', vIndex) then
  begin
    vItem := Item[vIndex];

    Result := vItem.AsObjectId;
  end;

  if (Result = nil) then
  begin
    raise EBSONObjectHasNoObjectId.CreateRes(@sBSONObjectHasNoObjectId);
  end;
end;

{ TBSONItem }

function TBSONItem.GetAsBSONBinary: IBSONBinary;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONBinary, Result);
  end;
end;

function TBSONItem.GetAsBoolean: Boolean;
begin
  if (FValueType = bvtBoolean) then
    Result := FValue
  else
    raise EBSONValueConvertError.CreateResFmt(@sBSONValueConvertError, ['Boolean']);
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
    raise EBSONValueConvertError.CreateResFmt(@sBSONValueConvertError, ['TDateTime']);
end;

function TBSONItem.GetAsFloat: Double;
begin
  if (FValueType = bvtDouble) or IsInteger then
    Result := FValue
  else
    raise EBSONValueConvertError.CreateResFmt(@sBSONValueConvertError, ['Double']);
end;

function TBSONItem.GetAsInt64: Int64;
begin
  if IsInteger then
    Result := FValue
  else
    raise EBSONValueConvertError.CreateResFmt(@sBSONValueConvertError, ['Int64']);
end;

function TBSONItem.GetAsInteger: Integer;
begin
  Result := AsInt64;
end;

function TBSONItem.GetAsObjectId: IBSONObjectId;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONObjectId, Result);
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
              Supports(IUnknown(FValue), IBSONObjectId);
end;

class function TBSONItem.NewFrom(AName: String;const AValue: Variant): TBSONItem;
begin
  Result := TBSONItem.Create;
  Result.FName := AName;
  Result.SetValue(AValue);
end;

procedure TBSONItem.SetValue(const Value: Variant);
var
  vTempValue: Extended;
begin
  FValue := Value;

  FValueType := bvtNull;
  case VarType(FValue) and varTypeMask of
    varEmpty, varNull: ;
    varDate: FValueType := bvtDateTime;
    varByte, varSmallint,varInteger,varShortInt,varWord,varLongWord: FValueType := bvtInteger;
    varInt64: FValueType := bvtInt64;
    varSingle,varDouble,varCurrency: begin
                                       vTempValue := FValue;
                                       if Frac(vTempValue) <= 0.00001 then
                                         FValueType := bvtInteger
                                       else
                                         FValueType := bvtDouble;
                                     end;  
    varOleStr, varString{$IFDEF UNICODE}, varUString{$ENDIF}: FValueType := bvtString;
    varBoolean: FValueType := bvtBoolean;
    varDispatch, varUnknown: FValueType := bvtInterface;
  else
    raise EBSONValueTypeUnknown.CreateResFmt(@sBSONValueTypeUnknown, [IntToHex(VarType(FValue), 4)]);
  end;
end;

function TBSONItem.GetAsBSONRegEx: IBSONRegEx;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONRegEx, Result);
  end;
end;

function TBSONItem.GetAsBSONSymbol: IBSONSymbol;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONSymbol, Result);
  end;
end;

function TBSONItem.GetAsBSONCode: IBSONCode;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONCode, Result);
  end;
end;

function TBSONItem.GetAsBSONCode_W_Scope: IBSONCode_W_Scope;
begin
  Result := nil;
  if (FValueType = bvtInterface) then
  begin
    Supports(IUnknown(FValue), IBSONCode_W_Scope, Result);
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

{ TBSONObjectQueryHelper }

class function TBSONObjectQueryHelper.NewFilterBatchOID(AObjects: array of IBSONObject): IBSONObject;
var
  i: Integer;
  vOidArray: IBSONArray;
begin
  Result := TBSONObject.Create;

  vOidArray := TBSONArray.Create;
  
  for i := Low(AObjects) to High(AObjects) do
  begin
    vOidArray.Put(AObjects[i].GetOid);
  end;

  Result  := TBSONObject.NewFrom('_id', TBSONObject.NewFrom('$in', vOidArray));
end;

class function TBSONObjectQueryHelper.NewFilterOid(AObjects: IBSONObject): IBSONObject;
begin
  Result  := TBSONObject.NewFrom('_id', AObjects.GetOid);
end;

{ TBSONBinary }

constructor TBSONBinary.Create(ASubType: Integer);
begin
  inherited Create;

  if not(ASubType in [BSON_SUBTYPE_GENERIC, BSON_SUBTYPE_OLD_BINARY]) then
  begin
    raise EIllegalArgumentException.CreateResFmt(@sInvalidBSONBinarySubtype, [ASubType]);
  end;

  FStream := TMemoryStream.Create;
  FSubType := ASubType;
end;

destructor TBSONBinary.Destroy;
begin
  FStream.Free;
  inherited;
end;

function TBSONBinary.GetSize: Integer;
begin
  Result := FStream.Size;
end;

function TBSONBinary.GetStream: TMemoryStream;
begin
  Result := FStream;
end;

function TBSONBinary.GetSubType: Integer;
begin
  Result := FSubType;
end;

class function TBSONBinary.NewFromFile(AFileName: String; ASubType: Integer): IBSONBinary;
begin
  Result := TBSONBinary.Create(ASubType);
  Result.Stream.LoadFromFile(AFileName);
end;

{ TBSONRegEx }

function TBSONRegEx.GetCaseInsensitive_I: Boolean;
begin
  Result := FCaseInsensitive_I;
end;

function TBSONRegEx.GetDotAll_S: Boolean;
begin
  Result := FDotAll_S;
end;

function TBSONRegEx.GetVerbose_X: Boolean;
begin
  Result := FVerbose_X;
end;

function TBSONRegEx.GetMultiline_M: Boolean;
begin
  Result := FMultiline_M;
end;

function TBSONRegEx.GetOptions: String;
begin
  Result := IfThen(FCaseInsensitive_I, 'i');
  Result := Result + IfThen(FLocaleDependent_L, 'l');
  Result := Result + IfThen(FMultiline_M, 'm');
  Result := Result + IfThen(FDotAll_S, 's');
  Result := Result + IfThen(FUnicode_U, 'u');
  Result := Result + IfThen(FVerbose_X, 'x');
end;

function TBSONRegEx.GetPattern: String;
begin
  Result := FPattern;
end;

procedure TBSONRegEx.SetCaseInsensitive_I(const Value: Boolean);
begin
  FCaseInsensitive_I := Value;
end;

procedure TBSONRegEx.SetDotAll_S(const Value: Boolean);
begin
  FDotAll_S := Value;
end;

procedure TBSONRegEx.SetVerbose_X(const Value: Boolean);
begin
  FVerbose_X := Value;
end;

procedure TBSONRegEx.SetMultiline_M(const Value: Boolean);
begin
  FMultiline_M := Value;
end;

procedure TBSONRegEx.SetOptions(const AOptions: String);
var
  i: Integer;
begin
  for i := 1 to Length(AOptions) do
  begin
    case AOptions[i] of
      'i', 'I': FCaseInsensitive_I := True;
      'l', 'L': FLocaleDependent_L := True;
      'm', 'M': FMultiline_M := True;
      's', 'S': FDotAll_S := True;
      'u', 'U': FUnicode_U := True;
      'x', 'X': FVerbose_X := True;  
    else
      raise EBSONUnrecognizedRegExOption.CreateResFmt(@sBSONUnrecognizedRegExOption, [AOptions[i]]); 
    end;
  end;
end;

procedure TBSONRegEx.SetPattern(const Value: String);
begin
  FPattern := Value;
end;

procedure TBSONRegEx.SetLocaleDependent_L(const Value: Boolean);
begin
  FLocaleDependent_L := Value;
end;

procedure TBSONRegEx.SetUnicode_U(const Value: Boolean);
begin
  FUnicode_U := Value;
end;

function TBSONRegEx.GetLocaleDependent_L: Boolean;
begin
  Result := FLocaleDependent_L;
end;

function TBSONRegEx.GetUnicode_U: Boolean;
begin
  Result := FUnicode_U;
end;

class function TBSONRegEx.NewFrom(APattern, AOptions: String): IBSONRegEx;
begin
  Result := TBSONRegEx.Create;
  Result.Pattern := APattern;
  Result.SetOptions(AOptions);
end;

{ TBSONSymbol }

function TBSONSymbol.GetSymbol: String;
begin
  Result := FSymbol;
end;

class function TBSONSymbol.NewFrom(const ASymbol: String): IBSONSymbol;
begin
  Result := TBSONSymbol.Create;
  Result.Symbol := ASymbol;
end;

procedure TBSONSymbol.SetSymbol(const Value: String);
begin
  FSymbol := Value;
end;

{ TBSONCode }

function TBSONCode.GetCode: String;
begin
  Result := FCode;
end;

class function TBSONCode.NewFrom(const ACode: String): IBSONCode;
begin
  Result := TBSONCode.Create;
  Result.Code := ACode;
end;

procedure TBSONCode.SetCode(const Value: String);
begin
  FCode := Value;
end;

{ TBSONCode_W_Scope }

function TBSONCode_W_Scope.GetCode: String;
begin
  Result := FCode;
end;

function TBSONCode_W_Scope.GetScope: IBSONObject;
begin
  Result := FScope;
end;

class function TBSONCode_W_Scope.NewFrom(const ACode: String; const AScope: IBSONObject): IBSONCode_W_Scope;
begin
  Result := TBSONCode_W_Scope.Create;
  Result.Code := ACode;
  Result.Scope := AScope;
end;

procedure TBSONCode_W_Scope.SetCode(const Value: String);
begin
  FCode := Value;
end;

procedure TBSONCode_W_Scope.SetScope(const Value: IBSONObject);
begin
  FScope := Value;
end;

initialization
  InitMongoObjectID;
  
end.
