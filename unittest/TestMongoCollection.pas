unit TestMongoCollection;

interface

uses TestFramework, Mongo;

type
  //Require mongodb service running
  TTestMongoCollection = class(TTestCase)
  private
    FMongo: TMongo;
    FDB: TMongoDB;
    FCollection: TMongoCollection;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    
  published
    procedure InsertSinglePairDocument;
  end;

implementation

{ TTestMongoCollection }

procedure TTestMongoCollection.InsertSinglePairDocument;
begin
  FCollection.Insert(['id', 123]);
end;

procedure TTestMongoCollection.SetUp;
begin
  inherited;
  FMongo := TMongo.Create;
  FMongo.Open();

  FDB := FMongo.getDB('unit');

  FCollection := FDB.GetCollection('test'); 
end;

procedure TTestMongoCollection.TearDown;
begin
  FCollection.Free;
  FDB.Free;
  FMongo.Free;
  inherited;
end;

initialization
  RegisterTest(TTestMongoCollection.Suite);

end.
