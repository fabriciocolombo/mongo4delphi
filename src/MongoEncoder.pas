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
unit MongoEncoder;

interface

uses BSONStream, BSONTypes;

type
  TMongoEncoder = class
  private
    FBuffer: TBSONStream;
    FStart: Integer;

    procedure put(AType: Byte; AName: String);overload;
    function put(AValue: String): Integer;overload;
    procedure putValueString(AValue: String);
    procedure putNull(AName: String);
    procedure putDate(AName: String; AValue: TDateTime);
    procedure putInt(AName: String; AValue: LongWord);
    procedure putInt64(AName: String; AValue: Int64);
    procedure putFloat(AName: String; AValue: Extended);
    procedure putString(AName: String; AValue: String);
    procedure putBoolean(AName: String; AValue: Boolean);
    procedure putObjectId(AName: String; const AValue: IObjectId);

    procedure PutInterfaceField(name: String; const val: IUnknown);
  public
    procedure BeginEncode;
    procedure EndEncode;

    procedure PutObjectField(name: String; val: OleVariant);

    constructor Create(ABuffer: TBSONStream);
  end;

implementation

uses DateUtils, SysUtils, Variants, BSON, MongoException, Classes, Math;

{ TMongoEncoder }

procedure TMongoEncoder.put(AType: Byte; AName: String);
begin
  FBuffer.WriteByte(AType);
  put(AName);
end;

constructor TMongoEncoder.Create(ABuffer: TBSONStream);
begin
  FBuffer := ABuffer;
  FBuffer.Clear;
end;

function TMongoEncoder.put(AValue: String): Integer;
begin
  Result := FBuffer.WriteUTF8String(AValue);  
end;

procedure TMongoEncoder.putBoolean(AName: String; AValue: Boolean);
begin
  put(BSON_BOOLEAN, AName);

  if AValue then
    FBuffer.WriteByte(BSON_BOOL_TRUE)
  else
    FBuffer.WriteByte(BSON_BOOL_FALSE);
end;

procedure TMongoEncoder.putDate(AName: String; AValue: TDateTime);
var
  vUTCDate: Int64;
begin
  put(BSON_DATETIME, AName);

  vUTCDate := Round((AValue - UnixDateDelta) * MSecsPerDay);

  FBuffer.WriteInt64(vUTCDate);
end;

procedure TMongoEncoder.putFloat(AName: String; AValue: Extended);
begin
  put(BSON_FLOAT, AName);
  FBuffer.writeDouble(AValue);
end;

procedure TMongoEncoder.putInt(AName: String; AValue: LongWord);
begin
  put(BSON_INT32, AName);
  FBuffer.writeInt(AValue);
end;

procedure TMongoEncoder.putInt64(AName: String; AValue: Int64);
begin
  put(BSON_INT64, AName);
  FBuffer.WriteInt64(AValue);
end;

procedure TMongoEncoder.putNull(AName: String);
begin
  put(BSON_NULL, AName);
end;

procedure TMongoEncoder.PutObjectField(name: String; val: OleVariant);
var
  valueType: TVarType;
begin
  valueType := VarType(val);

  if SameText(name, '_transientFields') then Exit;

  if SameText(name, '$where') and (valueType = vtString) then
  begin
      put(BSON_CODE, name);
      putValueString(val.toString() );
      Exit;
  end;

  case valueType and varTypeMask of
    varEmpty, varNull: putNull(name);
    varDate: putDate( name , VarToDateTime(val));
    varByte, varSmallint,varInteger,varShortInt,varWord,varLongWord: putInt(name, val);
    varInt64: putInt64(name, val);
    varSingle,varDouble,varCurrency: putFloat(name, val);
    varOleStr, varString: putString(name, val);
    varBoolean: putBoolean(name, val);
    varDispatch, varUnknown: PutInterfaceField(name, IUnknown(val));
    varError,
    varAny,
    varTypeMask,
    varArray,
    varByRef: ;
    varVariant:;
//  if ( val instanceof ObjectId )
//      putObjectId(name, (ObjectId)val );
//  else if ( val instanceof BSONObject )
//      putObject(name, (BSONObject)val );
//  if ( val instanceof Pattern )
//      putPattern(name, (Pattern)val );
//  else if ( val instanceof Map )
//      putMap( name , (Map)val );
//  else if ( val instanceof Iterable)
//      putIterable( name , (Iterable)val );
//  else if ( val instanceof byte[] )
//      putBinary( name , (byte[])val );
//  else if ( val instanceof Binary )
//      putBinary( name , (Binary)val );
//  else if ( val instanceof UUID )
//      putUUID( name , (UUID)val );
//  else if ( val.getClass().isArray() )
//    putArray( name , val );
//  else if (val instanceof Symbol)
//      putSymbol(name, (Symbol) val);
//  else if (val instanceof CodeWScope)
//      putCodeWScope( name , (CodeWScope)val );
//  else if (val instanceof Code)
//      putCode( name , (Code)val );
//  else if (val instanceof DBRefBase)
//      BSONObject temp = new BasicBSONObject();
//      temp.put("$ref", ((DBRefBase)val).getRef());
//      temp.put("$id", ((DBRefBase)val).getId());
//      putObject( name, temp );
//  else if ( val instanceof MinKey )
//      putMinKey( name );
//  else if ( val instanceof MaxKey )
//      putMaxKey( name );
//  else if ( putSpecial( name , val ) )
//      // no-op
  else
    raise EIllegalArgumentException('can''t serialize ' + VarToStrDef(val, EmptyStr));
  end;
end;

procedure TMongoEncoder.putString(AName, AValue: String);
begin
  put(BSON_STRING, AName);
  putValueString(AValue);
end;

procedure TMongoEncoder.putValueString(AValue: String);
var
  lenPos, strLen: Int64;
begin
  lenPos := FBuffer.Position;
  FBuffer.WriteInt(0); // making space for length
  strLen := put(AValue);
  FBuffer.writeInt(lenPos, strLen);
end;

procedure TMongoEncoder.BeginEncode;
begin
  FStart := FBuffer.Position;
  FBuffer.WriteInt(0); // making space for length
end;

procedure TMongoEncoder.EndEncode;
begin
  FBuffer.WriteByte(BSON_EOF);
  FBuffer.WriteInt(FStart, FBuffer.Size - FStart);
end;

procedure TMongoEncoder.PutInterfaceField(name: String; const val: IInterface);
var
  vObjectId: IObjectId;
begin
  if Supports(val, IObjectId, vObjectId) then
  begin
    putObjectId(name, vObjectId);
  end;
end;

procedure TMongoEncoder.putObjectId(AName: String; const AValue: IObjectId);
var
  OID: TObjectIdByteArray;
begin
  put(BSON_OBJECTID, AName);

  OID := AValue.AsByteArray;

  FBuffer.Write(OID[0], 12);
end;

end.
