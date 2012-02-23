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
    procedure InsertObjectID;
    procedure InsertBSONObjectSimpleTypes;
    procedure InsertBSONObjectWithEmbeddedObject;
    procedure InsertBSONArraySimpleTypes;
    procedure InsertBSONArrayObject;
    procedure InsertBSONArrayWithEmbeddedArrays;
  end;

implementation

uses Variants, SysUtils, Math, BSONTypes;

{ TTestMongoCollection }

procedure TTestMongoCollection.InsertBSONArrayObject;
var
  vBSON: IBSONObject;
  vArray: IBSONArray;
begin
  vArray := TBSONArray.Create;
  vArray.Put(TBSONObject.NewFrom('name', 'Fabricio'));

  vBSON := TBSONObject.Create;
  vBSON.Put('id', 123);
  vBSON.Put('id2', vArray);

  FCollection.Insert(vBSON);
end;

procedure TTestMongoCollection.InsertBSONArraySimpleTypes;
var
  vBSON: IBSONObject;
  vArray: IBSONArray;
begin
  vArray := TBSONArray.Create;
  vArray.Put('123');
  vArray.Put(123);
  vArray.Put(1.23);

  vBSON := TBSONObject.Create;
  vBSON.Put('id', 123);
  vBSON.Put('id2', vArray);

  FCollection.Insert(vBSON);
end;

procedure TTestMongoCollection.InsertBSONArrayWithEmbeddedArrays;
var
  vBSON: IBSONObject;
  vArray: IBSONArray;
begin
  vArray := TBSONArray.NewFrom(TBSONArray.NewFrom(TBSONArray.NewFrom(TBSONObject.NewFrom('name', 'Fabricio'))));

  vBSON := TBSONObject.Create;
  vBSON.Put('id', 123);
  vBSON.Put('id2', vArray);

  FCollection.Insert(vBSON);
end;

procedure TTestMongoCollection.InsertBSONObjectSimpleTypes;
var
  vSingle: Single;
  vDouble: Double;
  vCurrency: Currency;
  vBSON: IBSONObject;
begin
  vSingle := 1.21;
  vDouble := 1.22;
  vCurrency := 1.23;

  vBSON := TBSONObject.Create;

  vBSON.Put('id01', 'Fabricio');
  vBSON.Put('id02', Null);
  vBSON.Put('id03', Unassigned);
  vBSON.Put('id04', Date);
  vBSON.Put('id05', Now);
  vBSON.Put('id06', High(Byte));
  vBSON.Put('id07', High(SmallInt));
  vBSON.Put('id08', High(Integer));
  vBSON.Put('id09', High(ShortInt));
  vBSON.Put('id10', High(Word));
  vBSON.Put('id11', High(LongWord));
  vBSON.Put('id12', High(Int64));
  vBSON.Put('id13', vSingle);
  vBSON.Put('id14', vDouble);
  vBSON.Put('id15', vCurrency);
  vBSON.Put('id16', True);
  vBSON.Put('id17', False);

  FCollection.Insert(vBSON);
end;

procedure TTestMongoCollection.InsertBSONObjectWithEmbeddedObject;
var
  vBSON,
  vEmbedded: IBSONObject;
begin
  vEmbedded := TBSONObject.Create;
  vEmbedded.Put('id2', '123'); 

  vBSON := TBSONObject.Create;
  vBSON.Put('id', 123);
  vBSON.Put('id2', vEmbedded);

  FCollection.Insert(vBSON);
end;

procedure TTestMongoCollection.InsertObjectID;
begin
  FCollection.Insert(['id', 123, '_id', TObjectId.NewFrom]);
end;

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
  FCollection.Insert(['id', High(Int64)]);
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
