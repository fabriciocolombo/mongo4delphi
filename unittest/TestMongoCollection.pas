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
    procedure InsertSinglePairDocumentForSimplesType;
    procedure InsertTwoPairDocument;
  end;

implementation

uses Variants, SysUtils, Math;

{ TTestMongoCollection }

procedure TTestMongoCollection.InsertSinglePairDocumentForSimplesType;
var
  vSingle: Single;
  vDouble: Double;
  vCurrency: Currency;
begin
  vSingle := 1.21;
  vDouble := 1.22;
  vCurrency := 1.23;
  FCollection.Insert(['id', 'Fabricio']);
  FCollection.Insert(['id', Null]); //null
  FCollection.Insert(['id', Unassigned]); //null
  FCollection.Insert(['id', Date]);
  FCollection.Insert(['id', Now]);
  FCollection.Insert(['id', High(Byte)]);
  FCollection.Insert(['id', High(SmallInt)]);
  FCollection.Insert(['id', High(Integer)]);
  FCollection.Insert(['id', High(ShortInt)]);
  FCollection.Insert(['id', High(Word)]);
  FCollection.Insert(['id', High(LongWord)]);
  FCollection .Insert(['id', High(Int64)]);
  FCollection.Insert(['id', vSingle]);
  FCollection.Insert(['id', vDouble]);
  FCollection.Insert(['id', vCurrency]);
  FCollection.Insert(['id', True]);
  FCollection.Insert(['id', False]);
end;

procedure TTestMongoCollection.InsertTwoPairDocument;
begin
  FCollection.Insert(['id', 123, 'name', 'Fabricio']);
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
