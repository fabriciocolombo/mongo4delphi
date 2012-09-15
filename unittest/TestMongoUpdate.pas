unit TestMongoUpdate;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses BaseTestCaseMongo, BSONTypes, MongoCollection;

type
  TTestMongoUpdate = class(TBaseTestCaseMongo)
  private
    FCollection: TMongoCollection;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
   procedure ReplaceArray;
   procedure ReplaceItemForNull;
   procedure ReplaceItemOfArray;
  end;

implementation

uses TestFramework;

{ TTestMongoUpdate }

procedure TTestMongoUpdate.SetUp;
var
  vPerson: IBSONObject;
  vAddresses: IBSONArray;
begin
  inherited;
  FCollection := DB.GetCollection('updates');

  vAddresses := TBSONArray.NewFromValues(['one address', 'two address']);
  vPerson := TBSONObject.NewFrom('id', 1).Put('name', 'fabricio').Put('addresses', vAddresses);

  FCollection.Insert(vPerson);
end;

procedure TTestMongoUpdate.TearDown;
begin
  FCollection.Drop;
  inherited;
end;

procedure TTestMongoUpdate.ReplaceArray;
var
  vPerson: IBSONObject;
  vAddresses,
  vNewAddresses: IBSONArray;
begin
  vPerson := FCollection.FindOne;

  vAddresses := vPerson.Items['addresses'].AsBSONArray;

  CheckEquals(2, vAddresses.Count);
  CheckEquals('one address', vAddresses.Item[0].AsString);
  CheckEquals('two address', vAddresses.Item[1].AsString);

  vNewAddresses := TBSONArray.NewFromValues(['one', 'two']);

  //replace entire old addresses array
  vPerson.Put('addresses', vNewAddresses);
  FCollection.Save(vPerson);

  //Reload
  vPerson := FCollection.FindOne;

  vAddresses := vPerson.Items['addresses'].AsBSONArray;

  CheckEquals(2, vAddresses.Count);
  CheckEquals('one', vAddresses.Item[0].AsString);
  CheckEquals('two', vAddresses.Item[1].AsString);  
end;

procedure TTestMongoUpdate.ReplaceItemForNull;
var
  vPerson: IBSONObject;
begin
  vPerson := FCollection.FindOne;

  CheckEquals('fabricio', vPerson.Items['name'].AsString);

  vPerson.Remove('name');

  FCollection.Save(vPerson);

  //Reload
  vPerson := FCollection.FindOne;

  CheckFalse(vPerson.Contain('name'));
end;

procedure TTestMongoUpdate.ReplaceItemOfArray;
var
  vPerson: IBSONObject;
  vAddresses: IBSONArray;
begin
  vPerson := FCollection.FindOne;

  vAddresses := vPerson.Items['addresses'].AsBSONArray;

  CheckEquals(2, vAddresses.Count);
  CheckEquals('one address', vAddresses.Item[0].AsString);
  CheckEquals('two address', vAddresses.Item[1].AsString);

  //Replace First item
  vAddresses.Put(0, 'one');

  FCollection.Save(vPerson);

  //Reload
  vPerson := FCollection.FindOne;

  vAddresses := vPerson.Items['addresses'].AsBSONArray;

  CheckEquals(2, vAddresses.Count);
  CheckEquals('one', vAddresses.Item[0].AsString);
  CheckEquals('two address', vAddresses.Item[1].AsString);
end;

initialization
  TTestMongoUpdate.RegisterTest;

end.
