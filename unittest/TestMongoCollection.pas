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
    procedure InsertBSONObjectID;
    procedure InsertBSONObjectSimpleTypes;
    procedure InsertBSONObjectWithEmbeddedObject;
    procedure InsertBSONArraySimpleTypes;
    procedure InsertBSONArrayObject;
    procedure InsertBSONArrayWithEmbeddedArrays;
    procedure InsertBSONObjectUUID;
    procedure FindOne;
  end;

implementation

uses Variants, SysUtils, Math, BSONTypes, MongoUtils;

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
  vLongWord: LongWord;
  vBSON: IBSONObject;
begin
  vSingle := 1.21;
  vDouble := 1.22;
  vCurrency := 1.23;
  vLongWord := High(LongWord) div 2; 

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
  vBSON.Put('id11', vLongWord);
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

procedure TTestMongoCollection.InsertBSONObjectID;
begin
  FCollection.Insert(TBSONObject.NewFrom('id', 123).Put('_id', TObjectId.NewFrom));
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

procedure TTestMongoCollection.InsertBSONObjectUUID;
begin
  FCollection.Insert(TBSONObject.NewFrom('uid', TGUIDUtils.NewGuidAsString));
end;

procedure TTestMongoCollection.FindOne;
var
  vDoc: IBSONObject;
begin
  FCollection.Insert(TBSONObject.NewFrom('_id', TObjectId.NewFromOID('4f46b9fa65760489cc96ab49')).Put('id', 123));

  vDoc := FCollection.FindOne(nil);

  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEqualsString('_id', vDoc[0].Name);
  CheckEqualsString('ObjectId("4f46b9fa65760489cc96ab49")', vDoc[0].AsObjectId.ToStringMongo);
  CheckEqualsString('id', vDoc[1].Name);
  CheckEquals(123, Integer(vDoc[1].Value));
end;

initialization
  RegisterTest(TTestMongoCollection.Suite);

end.
