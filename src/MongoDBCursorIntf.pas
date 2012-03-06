unit MongoDBCursorIntf;

interface

uses BSONTypes;

type
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

implementation

end.
