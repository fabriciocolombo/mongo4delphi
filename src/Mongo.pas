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
unit Mongo;

interface

uses Sockets, MongoEncoder, BSONStream;

const
  DEFAULT_HOST = 'localhost';
  DEFAULT_PORT = 27017;

type
  TMongoDB = class;
  TMongoCollection = class;

  TMongo = class
  private
    FSocket: TTcpClient;
    FEncoder: TMongoEncoder;
    FStream: TBSONStream;
    FRequestId: Integer;

    procedure Insert(FullCollection: String; Doc: Array of Variant);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Open(AHost: String = DEFAULT_HOST; APort: Integer = DEFAULT_PORT);

    function getDB(const ADBname: String): TMongoDB;
  end;

  TMongoDB = class
  private
    FMongo: TMongo;
    FDBName: String;
  public
    constructor Create(AMongo: TMongo; ADBName: String);
    destructor Destroy; override;

    property DBName: String read FDBName;

//    function RunCommand(ACommand: IBSONDocument): IBSONDocument;

    function GetCollection(AName: String): TMongoCollection;
    procedure DropCollection(AName: String);
  end;

  TMongoCollection = class
  private
    FMongoDatabase: TMongoDB;
    FCollectionName: String;
    function GetFullName: String;

    //function GenerateIndexName(KeyFields: IBSONDocument): String;
  public
    constructor Create(AMongoDatabase: TMongoDB; AName: String);

    property CollectionName: String read FCollectionName;
    property FullName: String read GetFullName;

    (*
    function Count(Query: IBSONDocument = nil; Limit: Integer = 0): Integer;

    function Find(Query: IBSONDocument = nil): IMongoDBCursor;

    function CreateIndex(KeyFields: IBSONDocument; AIndexName: String = ''): IBSONDocument;
    function DropIndex(AIndexName: String): Boolean;
    *)
    procedure Insert(Doc: Array of Variant);

    //TODO Map/Reduce
    //TODO remove
    //TODO update

  end;

 IMongoDBCursor = interface
  ['{7204C1E4-ABAC-4DC3-9CBA-76DFCCCB59B2}']
(*
    function Count: Integer;
    function Size: Integer;
    function Sort(AOrder: IBSONDocument): IMongoDBCursor;
    //TODO function Hint(AIndexKeys: IBSONDocument): IMongoDBCursor;overload;
    //TODO function Hint(AIndexName: String): IMongoDBCursor;overload;
    function Snapshot: IMongoDBCursor;
    function Explain: IBSONDocument;
    function Limit(n: Integer): IMongoDBCursor;
    function Skip(n: Integer): IMongoDBCursor;
    function BatchSize(n: Integer): IMongoDBCursor;

    function HasNext: Boolean;
    function Next: IBSONDocument;  *)
  end;

  //TODO Make implement an interface to release object
  TMongoDBCursor = class(TInterfacedObject, IMongoDBCursor)
  private
  (*
    FCollection: TMongoCollection;
    FQuery: IBSONDocument;
    FFields: IBSONDocument;
    FWireQuery: TMongoWireQuery;
    FBatchSize: Integer;
    FLimit: Integer;
    FSkip: Integer;
    FOrderBy: IBSONDocument;
    FExplain: Boolean;
    FSnapShot: Boolean;

    procedure OpenCursor;

    procedure AssertCursorIsNotOpen;

    function ChooseBatchSize(batchSize, limit, fetched: Integer): Integer;

    function Clone: TMongoDBCursor;
  public
    constructor Create(ACollection: TMongoCollection; AQuery: IBSONDocument; AFields: IBSONDocument);
    destructor Destroy; override;

    function Count: Integer;
    function Size: Integer;
    function Sort(AOrder: IBSONDocument): IMongoDBCursor;
    //TODO function Hint(AIndexKeys: IBSONDocument): IMongoDBCursor;overload;
    //TODO function Hint(AIndexName: String): IMongoDBCursor;overload;
    function Snapshot: IMongoDBCursor;
    function Explain: IBSONDocument;
    function Limit(n: Integer): IMongoDBCursor;
    function Skip(n: Integer): IMongoDBCursor;
    function BatchSize(n: Integer): IMongoDBCursor;

    function HasNext: Boolean;
    function Next: IBSONDocument;
    *)
  end;

implementation

uses SysUtils, MongoException, BSON, Classes;

{ TMongo }

constructor TMongo.Create;
begin
  FSocket := TTcpClient.Create(nil);
  FStream := TBSONStream.Create;
  FEncoder := TMongoEncoder.Create(FStream);
end;

destructor TMongo.Destroy;
begin
  FStream.Free;
  FEncoder.Free;
  FSocket.Close;
  FSocket.Free;
  inherited;
end;

function TMongo.getDB(const ADBname: String): TMongoDB;
begin
  Result := TMongoDB.Create(Self, ADBname);
end;

procedure TMongo.Insert(FullCollection: String; Doc: array of Variant);
var
  i: Integer;
  vLength: Integer;
begin
  Inc(FRequestId);

  FStream.Clear;
  FStream.WriteInt(0); //length
  FStream.WriteInt(FRequestId);
  FStream.WriteInt(0);//ResponseTo
  FStream.WriteInt(OP_INSERT);
  FStream.WriteInt(0);//Flagss
  FStream.WriteUTF8String(FullCollection);

  i := Low(Doc);
  while i < High(Doc) do
  begin
    FEncoder.PutObjectField(Doc[i], Doc[i+1]);

    Inc(i, 2);
  end;

  vLength := FStream.Size;
  FStream.WriteInt(0, vLength);

  FSocket.SendBuf(FStream.Memory^, vLength);
end;

procedure TMongo.Open(AHost: String; APort: Integer);
begin
  FSocket.Close;
  FSocket.RemoteHost := AHost;
  FSocket.RemotePort := IntToStr(APort);
  FSocket.Open;
  if not FSocket.Connected then
    raise EMongoConnectionException.CreateFmt('%s: failed to connect to "%s:%d"', [ClassName, AHost, APort]);
end;

{ TMongoDB }

constructor TMongoDB.Create(AMongo: TMongo; ADBName: String);
begin
  FMongo := AMongo;
  FDBName := ADBName;
end;

destructor TMongoDB.Destroy;
begin

  inherited;
end;

procedure TMongoDB.DropCollection(AName: String);
begin

end;

function TMongoDB.GetCollection(AName: String): TMongoCollection;
begin
  Result := TMongoCollection.Create(Self, AName);
end;

{ TMongoCollection }

constructor TMongoCollection.Create(AMongoDatabase: TMongoDB; AName: String);
begin
  FMongoDatabase := AMongoDatabase;
  FCollectionName := AName;
end;

function TMongoCollection.GetFullName: String;
begin
  Result := FMongoDatabase.DBName + '.' + FCollectionName;
end;

procedure TMongoCollection.Insert(Doc: array of Variant);
begin
  FMongoDatabase.FMongo.Insert(FullName, Doc);
end;

end.
