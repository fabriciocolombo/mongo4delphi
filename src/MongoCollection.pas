unit MongoCollection;

interface

uses MongoDBCursorIntf, BSONTypes, WriteResult, CommandResult;

type
  TMongoCollection = class
  private
  protected
    function GetCollectionName: String;virtual;abstract;
    function GetFullName: String;virtual;abstract;
    function GetDBName: String;virtual;abstract;
  public
    property DBName: String read GetDBName;
    property CollectionName: String read GetCollectionName;
    property FullName: String read GetFullName;

    function Find: IMongoDBCursor;overload;virtual;abstract;
    function Find(Query: IBSONObject): IMongoDBCursor;overload;virtual;abstract;
    function Find(Query, Fields: IBSONObject): IMongoDBCursor;overload;virtual;abstract;

    function Count(Limit: Integer = 0): Integer;overload;virtual;abstract;
    function Count(Query: IBSONObject; Limit: Integer = 0): Integer;overload;virtual;abstract;

    function CreateIndex(KeyFields: IBSONObject; AIndexName: String = ''): IWriteResult;virtual;abstract;
    procedure DropIndex(AIndexName: String);virtual;abstract;
    procedure DropIndexes;virtual;abstract;

    procedure Drop();virtual;abstract;

    function Insert(const BSONObject: IBSONObject): IWriteResult;overload;virtual;abstract;
    function Insert(const BSONObjects: Array of IBSONObject): IWriteResult;overload;virtual;abstract;

    function Update(Query, BSONObject: IBSONObject): IWriteResult;overload;virtual;abstract;
    function Update(Query, BSONObject: IBSONObject; Upsert, Multi: Boolean): IWriteResult;overload;virtual;abstract;
    function UpdateMulti(Query, BSONObject: IBSONObject): IWriteResult;virtual;abstract;

    function Remove(DB, Collection: String; AObject: IBSONObject): IWriteResult;virtual;abstract;

    function FindOne(): IBSONObject;overload;virtual;abstract;
    function FindOne(Query: IBSONObject): IBSONObject;overload;virtual;abstract;
    function FindOne(Query, Fields: IBSONObject): IBSONObject;overload;virtual;abstract;

    function GetIndexInfo: IBSONArray;virtual;abstract;
  end;

implementation

end.
