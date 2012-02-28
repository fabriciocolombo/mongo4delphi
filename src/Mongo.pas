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

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses Sockets, MongoEncoder, MongoDecoder, BSONStream, BSONTypes, MongoProvider,
     Contnrs, Classes;



type
  TMongoDB = class;
  TMongoCollection = class;
  IMongoDBCursor = interface;

  TMongo = class
  private
    FProvider: IMongoProvider;
    FEncoder: IMongoEncoder;
    FDecoder: IMongoDecoder;
    FDBList: TObjectList;
    procedure SetEncoder(const Value: IMongoEncoder);
    procedure SetDecoder(const Value: IMongoDecoder);
  protected
    property Provider: IMongoProvider read FProvider;
  public
    constructor Create;
    destructor Destroy; override;

    property Encoder: IMongoEncoder read FEncoder write SetEncoder;
    property Decoder: IMongoDecoder read FDecoder write SetDecoder; 

    procedure Connect(AHost: AnsiString = DEFAULT_HOST; APort: Integer = DEFAULT_PORT);

    function getDB(const ADBname: String): TMongoDB;
    procedure GetDatabaseNames(AList: TStrings);
    procedure dropDatabase(DBName: String);
  end;

  TMongoDB = class
  private
    FMongo: TMongo;
    FDBName: String;
    FCollectionList: TObjectList;
    function GetProvider: IMongoProvider;
  protected
    property Provider: IMongoProvider read GetProvider;
  public
    constructor Create(AMongo: TMongo; ADBName: String);
    destructor Destroy; override;

    property DBName: String read FDBName;

    function RunCommand(ACommand: IBSONObject): ICommandResult;
    function GetLastError: ICommandResult;

    function GetCollection(AName: String): TMongoCollection;
    procedure DropCollection(AName: String);

    function Authenticate(AUserName, APassword: String): Boolean;
    procedure Logout;
  end;

  TMongoCollection = class
  private
    FMongoDatabase: TMongoDB;
    FCollectionName: String;

    function GetFullName: String;
    function GetProvider: IMongoProvider;

    function GenerateIndexName(KeyFields: IBSONObject): String;
  protected
    property Provider: IMongoProvider read GetProvider;
  public
    constructor Create(AMongoDatabase: TMongoDB; AName: String);

    property CollectionName: String read FCollectionName;
    property FullName: String read GetFullName;

    function Find: IMongoDBCursor;overload;
    function Find(Query: IBSONObject): IMongoDBCursor;overload;
    function Find(Query, Fields: IBSONObject): IMongoDBCursor;overload;

    function Count(Limit: Integer = 0): Integer;overload;
    function Count(Query: IBSONObject; Limit: Integer = 0): Integer;overload;

    function CreateIndex(KeyFields: IBSONObject; AIndexName: String = ''): IWriteResult;
    function DropIndex(AIndexName: String): ICommandResult;

    procedure Drop();

    function Insert(const BSONObject: IBSONObject): IWriteResult;overload;
    function Insert(const BSONObjects: Array of IBSONObject): IWriteResult;overload;

    function Update(Query, BSONObject: IBSONObject): IWriteResult;overload;
    function Update(Query, BSONObject: IBSONObject; Upsert, Multi: Boolean): IWriteResult;overload;
    function UpdateMulti(Query, BSONObject: IBSONObject): IWriteResult;

    function Remove(DB, Collection: String; AObject: IBSONObject): IWriteResult;

    function FindOne(): IBSONObject;overload;
    function FindOne(Query: IBSONObject): IBSONObject;overload;
    function FindOne(Query, Fields: IBSONObject): IBSONObject;overload;

    //TODO Map/Reduce
  end;

 IMongoDBCursor = interface
    ['{BA92DC10-CEF6-440A-B7B1-1C1E4F79652B}']

    function Count: Integer;
    function Size: Integer;
    function Sort(AOrder: IBSONObject): IMongoDBCursor;
    function Hint(AIndexKeys: IBSONObject): IMongoDBCursor;overload;
    function Hint(AIndexName: String): IMongoDBCursor;overload;
    function Snapshot: IMongoDBCursor;
    function Explain: IBSONObject;
    function Limit(n: Integer): IMongoDBCursor;
    function Skip(n: Integer): IMongoDBCursor;
    function BatchSize(n: Integer): IMongoDBCursor;

    function HasNext: Boolean;
    function Next: IBSONObject;
  end;

  TMongoDBCursor = class(TInterfacedObject, IMongoDBCursor)
  private
    FCollection: TMongoCollection;
    FQuery: IBSONObject;
    FFields: IBSONObject;
    FBatchSize: Integer;
    FLimit: Integer;
    FSkip: Integer;
    FOrderBy: IBSONObject;
    FExplain: Boolean;
    FSnapShot: Boolean;
    FRequestId: Integer;
    FNumberReturned: Integer;
    FFetchedRecords: Integer;
    FTotalRecordsReturned: Integer;
    FStream: TBSONStream;
    FCursorId: Int64;
    FSavedCursorId: Int64;
    FIndexName: String;
    FIndexKeys: IBSONObject;

    procedure OpenCursor;

    procedure AssertCursorIsNotOpen;

    function Clone: TMongoDBCursor;

    function ChooseBatchSize(batchSize, limit, fetched: Integer): Integer;

    procedure KillOpenedCursor;
  public
    constructor Create(ACollection: TMongoCollection; AQuery: IBSONObject; AFields: IBSONObject);
    destructor Destroy; override;

    //does not consider the limit
    function Count: Integer;

    //consider the Limit
    function Size: Integer;

    function Sort(AOrder: IBSONObject): IMongoDBCursor;
    function Hint(AIndexKeys: IBSONObject): IMongoDBCursor;overload;
    function Hint(AIndexName: String): IMongoDBCursor;overload;
    function Snapshot: IMongoDBCursor;
    function Explain: IBSONObject;
    function Limit(n: Integer): IMongoDBCursor;
    function Skip(n: Integer): IMongoDBCursor;
    function BatchSize(n: Integer): IMongoDBCursor;

    function HasNext: Boolean;
    function Next: IBSONObject;
  end;

implementation

uses SysUtils, MongoException, BSON, Math;

{ TMongo }

constructor TMongo.Create;
begin
  inherited;
  FDBList := TObjectList.Create;
  FProvider := TDefaultMongoProvider.Create;
  SetEncoder(TMongoEncoderFactory.DefaultEncoder);
  SetDecoder(TMongoDecoderFactory.DefaultDecoder);
end;

destructor TMongo.Destroy;
begin
  FDBList.Free;
  inherited;
end;

procedure TMongo.GetDatabaseNames(AList: TStrings);
var
  vResult: ICommandResult;
  vDatabases: IBSONArray;
  i: Integer;
begin
  AList.Clear;

  vResult := FProvider.RunCommand('admin', TBSONObject.NewFrom('listDatabases', 1));

  vResult.RaiseOnError;

  vDatabases := vResult.Items['databases'].AsBSONArray;

  for i := 0 to vDatabases.Count-1 do
  begin
    AList.Add(vDatabases[i].AsBSONObject.Items['name'].AsString);
  end;
end;

function TMongo.getDB(const ADBname: String): TMongoDB;
begin
  Result := TMongoDB.Create(Self, ADBname);

  FDBList.Add(Result);
end;

procedure TMongo.Connect(AHost: AnsiString; APort: Integer);
begin
  FProvider.Connect(AHost, APort);
end;

procedure TMongo.SetDecoder(const Value: IMongoDecoder);
begin
  FDecoder := Value;
  FProvider.SetDecoder(FDecoder);
end;

procedure TMongo.SetEncoder(const Value: IMongoEncoder);
begin
  FEncoder := Value;
  FProvider.SetEncoder(FEncoder);
end;

procedure TMongo.dropDatabase(DBName: String);
begin
  FProvider.RunCommand(DBName, TBSONObject.NewFrom('dropDatabase', 1));
end;

{ TMongoDB }

function TMongoDB.Authenticate(AUserName, APassword: String): Boolean;
begin
  Result := Provider.Authenticate(FDBName, AUserName, APassword);
end;

constructor TMongoDB.Create(AMongo: TMongo; ADBName: String);
begin
  inherited Create;
  FCollectionList := TObjectList.Create;
  FMongo := AMongo;
  FDBName := ADBName;
end;

destructor TMongoDB.Destroy;
begin
  FCollectionList.Free;
  inherited;
end;

procedure TMongoDB.DropCollection(AName: String);
begin
  Provider.RunCommand(FDBName, TBSONObject.NewFrom('drop', AName));
end;

function TMongoDB.GetCollection(AName: String): TMongoCollection;
begin
  Result := TMongoCollection.Create(Self, AName);

  FCollectionList.Add(Result);
end;

function TMongoDB.GetLastError: ICommandResult;
begin
  Result := Provider.GetLastError(FDBName);
end;

function TMongoDB.GetProvider: IMongoProvider;
begin
  Result := FMongo.Provider;
end;

procedure TMongoDB.Logout;
begin
  Provider.RunCommand(FDBName, TBSONObject.NewFrom('logout', 1));
end;

function TMongoDB.RunCommand(ACommand: IBSONObject): ICommandResult;
begin
  Result := Provider.RunCommand(FDBName, ACommand);
end;

{ TMongoCollection }

function TMongoCollection.Count(Limit: Integer): Integer;
begin
  Result := Count(TBSONObject.Empty, Limit);
end;

function TMongoCollection.Count(Query: IBSONObject; Limit: Integer): Integer;
var
  vCommand: IBSONObject;
  vCommandResult: ICommandResult;
  vErrorMessage: String;
begin
  Result := 0;

  vCommand := TBSONObject.NewFrom('count', FCollectionName);
  vCommand.Put('query', Query);

  if Limit > 0 then
    vCommand.Put('limit', Limit);

  vCommandResult := Provider.RunCommand(FMongoDatabase.DBName, vCommand);

  if (not vCommandResult.Ok) or vCommandResult.HasError then
  begin
    vErrorMessage := vCommandResult.GetErrorMessage();

    if SameText(vErrorMessage, 'ns does not exist') or
       SameText(vErrorMessage, 'ns missing') then
      Result := 0 // for now, return 0 - lets pretend it does exist
    else
      vCommandResult.RaiseOnError();
  end
  else
    Result := vCommandResult.Items['n'].AsInteger;
end;

constructor TMongoCollection.Create(AMongoDatabase: TMongoDB; AName: String);
begin
  FMongoDatabase := AMongoDatabase;
  FCollectionName := AName;
end;

function TMongoCollection.CreateIndex(KeyFields: IBSONObject; AIndexName: String): IWriteResult;
begin
  if (Trim(AIndexName) = EmptyStr) then
  begin
    AIndexName := GenerateIndexName(KeyFields); 
  end;

  Result := Provider.CreateIndex(FMongoDatabase.DBName, FCollectionName, KeyFields, AIndexName);
end;

procedure TMongoCollection.Drop;
begin
  Provider.RunCommand(FMongoDatabase.DBName, TBSONObject.NewFrom('drop', FCollectionName));
end;

function TMongoCollection.Find: IMongoDBCursor;
begin
  Result := Find(TBSONObject.Create as IBSONObject);
end;

function TMongoCollection.Find(Query: IBSONObject): IMongoDBCursor;
begin
  Result := Find(Query, TBSONObject.Create as IBSONObject);
end;

function TMongoCollection.DropIndex(AIndexName: String): ICommandResult;
begin
  Result := Provider.DropIndex(FMongoDatabase.DBName, FCollectionName, AIndexName);
end;

function TMongoCollection.Find(Query, Fields: IBSONObject): IMongoDBCursor;
begin
  Result := TMongoDBCursor.Create(Self, Query, Fields);
end;

function TMongoCollection.GetFullName: String;
begin
  Result := FMongoDatabase.DBName + '.' + FCollectionName;
end;

function TMongoCollection.GetProvider: IMongoProvider;
begin
  Result := FMongoDatabase.Provider;
end;

function TMongoCollection.GenerateIndexName(KeyFields: IBSONObject): String;
var
  i: Integer;
  vIndexName: String;
begin
  vIndexName := 'idx';

  for i := 0 to KeyFields.Count-1 do
  begin
    vIndexName := vIndexName + '_' + KeyFields[i].Name;
  end;

  Result := vIndexName;
end;

function TMongoCollection.Insert(const BSONObject: IBSONObject): IWriteResult;
begin
  Result := Provider.Insert(FMongoDatabase.DBName, FCollectionName, BSONObject);
end;

function TMongoCollection.Insert(const BSONObjects: array of IBSONObject): IWriteResult;
begin
  Result := Provider.Insert(FMongoDatabase.DBName, FCollectionName, BSONObjects);
end;

function TMongoCollection.Remove(DB, Collection: String; AObject: IBSONObject): IWriteResult;
begin
  Result := Provider.Remove(DB, Collection, AObject);
end;

function TMongoCollection.Update(Query, BSONObject: IBSONObject): IWriteResult;
begin
  Result := Provider.Update(FMongoDatabase.DBName, FCollectionName, Query, BSONObject);
end;

function TMongoCollection.Update(Query, BSONObject: IBSONObject; Upsert, Multi: Boolean): IWriteResult;
begin
  Result := Provider.Update(FMongoDatabase.DBName, FCollectionName, Query, BSONObject, Upsert, Multi);
end;

function TMongoCollection.UpdateMulti(Query,BSONObject: IBSONObject): IWriteResult;
begin
  Result := Provider.UpdateMulti(FMongoDatabase.DBName, FCollectionName, Query, BSONObject);
end;

function TMongoCollection.FindOne: IBSONObject;
begin
  Result := Provider.FindOne(FMongoDatabase.DBName, FCollectionName);
end;

function TMongoCollection.FindOne(Query: IBSONObject): IBSONObject;
begin
  Result := Provider.FindOne(FMongoDatabase.DBName, FCollectionName, Query);
end;

function TMongoCollection.FindOne(Query, Fields: IBSONObject): IBSONObject;
begin
  Result := Provider.FindOne(FMongoDatabase.DBName, FCollectionName, Query, Fields);
end;

{ TMongoDBCursor }

procedure TMongoDBCursor.AssertCursorIsNotOpen;
begin
  if (FRequestId > 0) then
    raise EMongoDBCursorStateException.CreateRes(@sMongoDBCursorStateException);
end;

function TMongoDBCursor.BatchSize(n: Integer): IMongoDBCursor;
begin
  AssertCursorIsNotOpen;

  //Java driver documented a server bug with batchsize 1 
  if (n = 1) then
    n := 2;

  FBatchSize := n;

  Result := Self; 
end;

function TMongoDBCursor.ChooseBatchSize(batchSize, limit, fetched: Integer): Integer;
var
  bs: Integer;
  remaining: Integer;
  res: Integer;
begin
  bs := abs(batchSize);
  remaining := IfThen(limit > 0, limit - fetched, 0);
  if (bs = 0) and (remaining > 0) then
    res := remaining
  else if (bs > 0) and (remaining = 0) then
    res := bs
  else
    res := Min(bs, remaining);

  if (batchSize < 0) then
      res := res * (-1); // force close

  if (res = 1) then
      res := -1; // optimization: use negative batchsize to close cursor
      
  Result := res;
end;

function TMongoDBCursor.Clone: TMongoDBCursor;
var
  vClone: TMongoDBCursor;
begin
  vClone := TMongoDBCursor.Create(FCollection, FQuery, FFields);
  vClone.FBatchSize := FBatchSize;
  vClone.FLimit:= FLimit;
  vClone.FSkip:= FSkip;
  vClone.FOrderBy:= FOrderBy;
  vClone.FExplain := FExplain;
  vClone.FSnapShot := FSnapShot;
  vClone.FIndexName := FIndexName;
  vClone.FIndexKeys := FIndexKeys;

  Result := vClone;
end;

function TMongoDBCursor.Count: Integer;
begin
  Result := FCollection.Count(FQuery);
end;

constructor TMongoDBCursor.Create(ACollection: TMongoCollection; AQuery, AFields: IBSONObject);
begin
  inherited Create;
  FStream := TBSONStream.Create;
  FCollection := ACollection;
  FQuery := AQuery;
  FFields := AFields;
end;

destructor TMongoDBCursor.Destroy;
begin
  KillOpenedCursor;
  
  FStream.Free;
  inherited;
end;

function TMongoDBCursor.Explain: IBSONObject;
var
  vClone: TMongoDBCursor;
begin
  vClone := Clone;
  try
    vClone.FExplain := True;

    if (vClone.FLimit > 0) then
    begin
      //need to pass a negative batchSize as limit for explain
      vClone.FBatchSize := vClone.FLimit * (-1);
      vClone.FLimit := 0;
    end;

    Result := vClone.Next;
  finally
    vClone.Free;
  end;
end;

procedure TMongoDBCursor.OpenCursor;
var
  vQuery: IBSONObject;
  vResponse: IBSONObject;
begin
  if (FRequestId > 0) then Exit;

  vQuery := TBSONObject.Create;
  vQuery.Put('query', FQuery);
  if Assigned(FOrderBy) then
  begin
    vQuery.Put('orderby', FOrderBy);
  end;

  if (Trim(FIndexName) <> EmptyStr) then
    vQuery.Put('$hint', FIndexName);
  if (FIndexKeys <> nil) then
    vQuery.Put('$hint', FIndexKeys);

  if (FExplain) then
    vQuery.Put('$explain', True);

  if (FSnapShot) then
    vQuery.Put('$snapshot', True);

  vResponse := FCollection.Provider.OpenQuery(FStream, FCollection.FMongoDatabase.DBName, FCollection.FCollectionName, vQuery, FFields, FSkip, ChooseBatchSize(FBatchSize, FLimit, 0));
  FRequestId := vResponse.Items['requestId'].AsInteger;
  FNumberReturned := vResponse.Items['numberReturned'].AsInteger;
  FCursorId := vResponse.Items['cursorId'].AsInt64;
  FSavedCursorId := FCursorId;
end;

function TMongoDBCursor.HasNext: Boolean;
var
  vResponse: IBSONObject;
begin
  OpenCursor;

  if (FLimit > 0) and (FTotalRecordsReturned >= FLimit) then
    Result := False
  else if (FFetchedRecords < FNumberReturned) then
    Result := True
  else
  begin
    vResponse := FCollection.Provider.HasNext(FStream, FCollection.FMongoDatabase.DBName, FCollection.CollectionName, FCursorId, ChooseBatchSize(FBatchSize, FLimit, FTotalRecordsReturned));
    FRequestId := vResponse.Items['requestId'].AsInteger;
    FNumberReturned := vResponse.Items['numberReturned'].AsInteger;
    FCursorId := vResponse.Items['cursorId'].AsInt64;

    FFetchedRecords := 0;

    Result := vResponse.Items['hasNext'].AsBoolean;
  end;
end;

function TMongoDBCursor.Next: IBSONObject;
begin
  OpenCursor;

  Result := FCollection.FMongoDatabase.FMongo.Decoder.Decode(FStream);

  Inc(FFetchedRecords);
  Inc(FTotalRecordsReturned);
end;

function TMongoDBCursor.Limit(n: Integer): IMongoDBCursor;
begin
  AssertCursorIsNotOpen;

  FLimit := n;

  Result := Self;
end;

function TMongoDBCursor.Size: Integer;
begin
  Result := FCollection.Count(FQuery, FLimit);
end;

function TMongoDBCursor.Skip(n: Integer): IMongoDBCursor;
begin
  AssertCursorIsNotOpen;

  FSkip := n;

  Result := Self;
end;

function TMongoDBCursor.Snapshot: IMongoDBCursor;
begin
  AssertCursorIsNotOpen;

  FSnapShot := True;

  Result := Self;
end;

function TMongoDBCursor.Sort(AOrder: IBSONObject): IMongoDBCursor;
begin
  AssertCursorIsNotOpen;

  FOrderBy := AOrder;

  Result := Self;
end;

procedure TMongoDBCursor.KillOpenedCursor;
begin
  if FSavedCursorId > 0 then
  begin
    FCollection.Provider.KillCursor(FSavedCursorId);
  end;
end;

function TMongoDBCursor.Hint(AIndexName: String): IMongoDBCursor;
begin
  AssertCursorIsNotOpen;

  FIndexName := AIndexName;

  Result := Self;
end;

function TMongoDBCursor.Hint(AIndexKeys: IBSONObject): IMongoDBCursor;
begin
  AssertCursorIsNotOpen;

  FIndexKeys := AIndexKeys;
  
  Result := Self;
end;

end.
