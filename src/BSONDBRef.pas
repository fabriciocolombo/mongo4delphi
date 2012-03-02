unit BSONDBRef;

interface

uses BsonTypes, AbstractMongo, Mongo;

type
  TBSONDBRef = class(TBSONObject, IBSONDBRef)
  private
    FObjectId: IBSONObjectId;
    FCollection: TAbstractMongoCollection;
    FRefDoc: IBSONObject;
    function GetCollection: String;
    function GetDB: String;
    function GetObjectId: IBSONObjectId;
  public
    property DB: String read GetDB;
    property Collection: String read GetCollection;
    property ObjectId: IBSONObjectId read GetObjectId;

    constructor Create(const ACollection: TAbstractMongoCollection; const AObjectId: IBSONObjectId);

    class function NewFrom(const ACollection: TAbstractMongoCollection; const AObjectId: IBSONObjectId): IBSONDBRef;

    function Fetch: IBSONObject;overload;
    class function Fetch(DB: TMongoDB; ARef: IBSONObject): IBSONObject;overload;
  end;

implementation

{ TBSONDBRef }

constructor TBSONDBRef.Create(const ACollection: TAbstractMongoCollection; const AObjectId: IBSONObjectId);
begin
  inherited Create;
  FCollection := ACollection;
  FObjectId := AObjectId;
end;

function TBSONDBRef.Fetch: IBSONObject;
begin
  if (FRefDoc = nil) then
  begin
    FRefDoc := FCollection.FindOne(TBSONObject.NewFrom('_id', FObjectId));
  end;

  Result := FRefDoc;
end;

class function TBSONDBRef.Fetch(DB: TMongoDB; ARef: IBSONObject): IBSONObject;
var
  vIndexRef, vIndexId: Integer;
begin
  Result := nil;
  if ARef.Find('$ref', vIndexRef) and ARef.Find('$id', vIndexId) then
  begin
    Result := DB.GetCollection(ARef.Item[vIndexRef].AsString).FindOne(TBSONObject.NewFrom('_id', ARef.Item[vIndexId].AsString));
  end;
end;

function TBSONDBRef.GetCollection: String;
begin
  Result := FCollection.CollectionName;
end;

function TBSONDBRef.GetDB: String;
begin
  Result := FCollection.DBName;
end;

function TBSONDBRef.GetObjectId: IBSONObjectId;
begin
  Result := FObjectId;
end;

class function TBSONDBRef.NewFrom(const ACollection: TAbstractMongoCollection; const AObjectId: IBSONObjectId): IBSONDBRef;
begin
  Result := TBSONDBRef.Create(ACollection, AObjectId);
end;
end.
