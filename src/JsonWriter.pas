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
unit JsonWriter;

interface

uses BSONTypes;

type
  TJsonWriter = class
  private
    function WriteInterface(const val: IUnknown): String;
    function BsonObjectToJson(const ABSON: IBSONObject): String;
    function BsonArrayToJson(const ABSONArray: IBSONArray): String;

    function ItemToJson(AItem: TBSONItem): String;
    function ItemValueToJson(AItem: TBSONItem): String;
  public
    function ToJson(const ABSON: IBSONObject): String;
  end;

implementation

uses SysUtils;

{ TJsonWriter }

function TJsonWriter.BsonArrayToJson(const ABSONArray: IBSONArray): String;
var
  i: Integer;
begin
  Result := '[';
  for i := 0 to ABSONArray.Count-1 do
  begin
    Result := Result + ItemValueToJson(ABSONArray[i]);

    if (i < ABSONArray.Count-1) then
    begin
      Result := Result + ',';
    end;
  end;
  Result := Result + ']';
end;

function TJsonWriter.BsonObjectToJson(const ABSON: IBSONObject): String;
var
  i: Integer;
  vItem: TBSONItem;
begin
  Result := '{';

  for i := 0 to ABSON.Count-1 do
  begin
    vItem := ABSON[i];

    Result := Result + ItemToJson(vItem);
  end;

  Result := Result + '}';
end;

function TJsonWriter.ItemToJson(AItem: TBSONItem): String;
begin
  Result := Format('"%s" : %s', [AItem.Name, ItemValueToJson(AItem)]);
end;

function TJsonWriter.ItemValueToJson(AItem: TBSONItem): String;
begin
  Result := EmptyStr;
  case AItem.ValueType of
    bvtNull: Result := 'null';
    bvtBoolean: Result := LowerCase(BoolToStr(AItem.AsBoolean, True));
    bvtInteger,
    bvtInt64: Result := IntToStr(AItem.AsInt64);
    bvtDouble: Result := StringReplace(FormatFloat('0.00', AItem.AsFloat),',', '.', []);
    bvtDateTime: Result := DateToStr(AItem.AsDateTime);
    bvtString: Result := '"' + AItem.AsString + '"';
    bvtInterface: Result := WriteInterface(IUnknown(AItem.Value));
  end;
end;

function TJsonWriter.ToJson(const ABSON: IBSONObject): String;
begin
  Result := BsonObjectToJson(ABSON);
end;

function TJsonWriter.WriteInterface(const val: IUnknown): String;
var
  vBsonArray: IBSONArray;
  vBsonObject: IBSONObject;
begin
  if Supports(val, IBSONArray, vBsonArray) then
  begin
    Result := BsonArrayToJson(vBsonArray);
  end
  else if Supports(val, IBsonObject, vBsonObject) then
  begin
    Result := BsonObjectToJson(vBsonObject);
  end;
end;

end.
