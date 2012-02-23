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
unit BSONStream;

interface

uses Classes;

type
  TBSONStream = class(TMemoryStream)
  public
    procedure WriteUTF8String(value: AnsiString);
    procedure WriteInt(value: Integer);overload;
    procedure WriteInt(pos, value: Integer);overload;
    procedure WriteInt64(value: Int64);
    procedure WriteByte(value: Byte);
  end;

implementation

{ TBSONStream }

procedure TBSONStream.WriteByte(value: Byte);
begin
  Write(value, SizeOf(value));
end;

procedure TBSONStream.WriteInt(value: Integer);
begin
  Write(value, SizeOf(value));
end;

procedure TBSONStream.WriteInt(pos, value: Integer);
var
  vSavePos: Int64;
begin
  vSavePos := Position;
  Position := pos;
  WriteInt(value);
  Position := vSavePos; 
end;

procedure TBSONStream.WriteInt64(value: Int64);
begin
  Write(value, SizeOf(value));
end;

procedure TBSONStream.WriteUTF8String(value: AnsiString);
var
  vUTF8: UTF8String;
  vSize: Integer;
begin
  vUTF8 := UTF8Encode(value);
  vSize := Length(vUTF8);
  Write(PChar(vUTF8)^, vSize + 1);
end;

end.
