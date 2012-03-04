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
unit BSONDBRef;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BsonTypes, Mongo;

type
  TBSONDBRef = class(TBSONObject, IBSONDBRef)
  private
    FObjectId: IBSONObjectId;
    FDB: String;
    FCollection: String;
    FRefDoc: IBSONObject;
    function GetCollection: String;
    function GetDB: String;
    function GetObjectId: IBSONObjectId;
  public
    property DB: String read GetDB;
    property Collection: String read GetCollection;
    property ObjectId: IBSONObjectId read GetObjectId;

    constructor Create(const ADB, ACollection: String; const AObjectId: IBSONObjectId);

    class function NewFrom(const ADB, ACollection: String; const AObjectId: IBSONObjectId): IBSONDBRef;

    function Fetch(DB: TMongoDB): IBSONObject;overload;
    class function Fetch(DB: TMongoDB; ARef: IBSONDBRef): IBSONObject;overload;
    class function Fetch(DB: TMongoDB; AQuery: IBSONObject): IBSONObject;overload;

    procedure SetRefObj(const ARefObj: IBSONObject);
  end;

implementation

uses SysUtils;

{ TBSONDBRef }

constructor TBSONDBRef.Create(const ADB, ACollection: String; const AObjectId: IBSONObjectId);
begin
  inherited Create;
  FDB := ADB;
  FCollection := ACollection;
  FObjectId := AObjectId;
end;

function TBSONDBRef.Fetch(DB: TMongoDB): IBSONObject;
begin
  if (FRefDoc = nil) then
  begin
//    FRefDoc := FCollection.FindOne(TBSONObject.NewFrom('_id', FObjectId));
  end;

  Result := FRefDoc;
end;

class function TBSONDBRef.Fetch(DB: TMongoDB; ARef: IBSONDBRef): IBSONObject;
begin
  if (DB.DBName <> ARef.DB) then
    raise Exception.CreateFmt('Must use same db.', []);

  Result := DB.GetCollection(ARef.Collection).FindOne(TBSONObject.NewFrom('_id', ARef.ObjectId));
end;

class function TBSONDBRef.Fetch(DB: TMongoDB;AQuery: IBSONObject): IBSONObject;
var
  vIndexRef, vIndexId: Integer;
begin
  Result := nil;

  if AQuery.Find('$ref', vIndexRef) and AQuery.Find('$id', vIndexId) then
  begin
    Result := DB.GetCollection(AQuery.Item[vIndexRef].AsString).FindOne(TBSONObject.NewFrom('_id', AQuery.Item[vIndexId].AsString));
  end;
end;

function TBSONDBRef.GetCollection: String;
begin
  Result := FCollection;
end;

function TBSONDBRef.GetDB: String;
begin
  Result := FDB;
end;

function TBSONDBRef.GetObjectId: IBSONObjectId;
begin
  Result := FObjectId;
end;

class function TBSONDBRef.NewFrom(const ADB, ACollection: String; const AObjectId: IBSONObjectId): IBSONDBRef;
begin
  Result := TBSONDBRef.Create(ADB, ACollection, AObjectId);
end;

procedure TBSONDBRef.SetRefObj(const ARefObj: IBSONObject);
begin

end;

end.
