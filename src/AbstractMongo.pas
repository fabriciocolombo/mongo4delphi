unit AbstractMongo;

interface

uses BSONTypes;

type
  TAbstractMongoCollection = class;

  TAbstractMongoDB = class
  private
  protected
    function GetDBName: String;virtual;abstract;
  public
    property DBName: String read GetDBName;

    function FindCollection(AName: String): TAbstractMongoCollection;virtual;abstract;   
  end;

  TAbstractMongoCollection = class
  private
    FMongoDatabase: TAbstractMongoDB;
    FCollectionName: String;
  protected
    function GetFullName: String;

    function GetDBName: String;
  public
    constructor Create(AMongoDatabase: TAbstractMongoDB; AName: String);

    property DB: TAbstractMongoDB read FMongoDatabase;
    property DBName: String read GetDBName;
    property CollectionName: String read FCollectionName;
    property FullName: String read GetFullName;

    function FindOne(): IBSONObject;overload;virtual;abstract;
    function FindOne(Query: IBSONObject): IBSONObject;overload;virtual;abstract;
    function FindOne(Query, Fields: IBSONObject): IBSONObject;overload;virtual;abstract;
  end;

implementation

{ TAbstractMongoCollection }

constructor TAbstractMongoCollection.Create(AMongoDatabase: TAbstractMongoDB; AName: String);
begin
  inherited Create;
  FMongoDatabase := AMongoDatabase;
  FCollectionName := AName;
end;

function TAbstractMongoCollection.GetDBName: String;
begin
  Result := FMongoDatabase.DBName;
end;

function TAbstractMongoCollection.GetFullName: String;
begin
  Result := GetDBName + '.' + FCollectionName;
end;

{ TAbstractMongoDB }

end.
