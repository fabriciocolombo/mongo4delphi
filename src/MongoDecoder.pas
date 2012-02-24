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
unit MongoDecoder;

interface

uses BSONStream, BSONTypes;

type
  IMongoDecoder = interface
    ['{FE47DC70-7349-4818-998C-BB0B15D78683}']

    function Decode(ABuffer: TBSONStream): IBSONObject;
  end;

  TDefaultMongoDecoder = class(TInterfacedObject, IMongoDecoder)
  private
    function DecodeElement(ACurrent: IBSONObject; ABuffer: TBSONStream): Boolean;
    function DecodeObject(ABuffer: TBSONStream): IBSONObject;
  public
    function Decode(ABuffer: TBSONStream): IBSONObject;
  end;

  TMongoDecoderFactory = class
  public
    class function DefaultDecoder(): IMongoDecoder;
  end;

implementation

uses MongoException, Classes, BSON, Variants, SysUtils;

{ TMongoDecoderFactory }

class function TMongoDecoderFactory.DefaultDecoder: IMongoDecoder;
begin
  Result := TDefaultMongoDecoder.Create;
end;

{ TDefaultMongoDecoder }

function TDefaultMongoDecoder.Decode(ABuffer: TBSONStream): IBSONObject;
var
  vLength, vRequestId, vResponseTo,
  vOpCode, vFlags, vStartingFrom,
  vNumberReturned: Integer;
  vCursorId: Int64;
  i: Integer;
begin
  vLength := ABuffer.ReadInt;
  vRequestID := ABuffer.ReadInt;
  vResponseTo := ABuffer.ReadInt;
  vOpCode := ABuffer.ReadInt;
  vFlags := ABuffer.ReadInt;
  vCursorId := ABuffer.ReadInt64;
  vStartingFrom := ABuffer.ReadInt;
  vNumberReturned := ABuffer.ReadInt;

  for i := 1 to vNumberReturned do
  begin
    Result := DecodeObject(ABuffer);
  end;
end;

function TDefaultMongoDecoder.DecodeElement(ACurrent: IBSONObject; ABuffer: TBSONStream): Boolean;
var
  vType: Byte;
  vName: String;
begin
  ABuffer.Read(vType, 1);

  if (vType = BSON_EOF) then
  begin
    Result := False;
    Exit;
  end;

  vName := ABuffer.ReadCString;

  case vType of
    BSON_NULL: ACurrent.Put(vName, Null);
    BSON_FLOAT: ACurrent.Put(vName, ABuffer.ReadDouble);
    BSON_STRING: ACurrent.Put(vName, ABuffer.ReadUTF8String);
    BSON_DOC:;
    BSON_ARRAY:;
    BSON_OBJECTID: ACurrent.Put(vName, TObjectId.NewFromOID(ABuffer.ReadObjectId));
    BSON_BOOLEAN: ACurrent.Put(vName, (ABuffer.ReadByte = BSON_BOOL_TRUE));
    BSON_DATETIME: ACurrent.Put(vName, VarFromDateTime((ABuffer.ReadInt64/MSecsPerDay) + UnixDateDelta));
    BSON_INT32: ACurrent.Put(vName, ABuffer.ReadInt);
    BSON_INT64: ACurrent.Put(vName, ABuffer.ReadInt64);
  end;
  Result := True;
end;

function TDefaultMongoDecoder.DecodeObject(ABuffer: TBSONStream): IBSONObject;
var
  vPosition,
  vLength,
  vNumRead: Integer;
begin
  vPosition := ABuffer.Position;
  vLength := ABuffer.ReadInt;

  Result := TBSONObject.Create;

  while DecodeElement(Result, ABuffer) do;

  vNumRead := (ABuffer.Position - vPosition);
  if vNumRead <> vLength then
    raise EIllegalArgumentException.CreateFmt('Bad data. Lengths don''t match read:"%d" != len:"%d"', [vNumRead, vLength]);
end;

end.
