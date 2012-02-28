unit TestMongoDBCursor;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCase, Mongo, BSONTypes;

type
  //Require mongodb service running
  TTestMongoDBCursor = class(TBaseTestCase)
  private
    FMongo: TMongo;
    FDB: TMongoDB;
    FCollection: TMongoCollection;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCountAndSize;
    procedure TestCursor;
    procedure TestCursorWithFieldsSelector;
  end;

implementation

{ TTestMongoDBCursor }

procedure TTestMongoDBCursor.SetUp;
begin
  inherited;
  FMongo := TMongo.Create;
  FMongo.Connect();

  FDB := FMongo.getDB('unit');

  FCollection := FDB.GetCollection('test');
  FCollection.Drop;
end;

procedure TTestMongoDBCursor.TearDown;
begin
  FMongo.Free;
  inherited;
end;

procedure TTestMongoDBCursor.TestCountAndSize;
var
  vCursor: IMongoDBCursor;
begin
  FCollection.Insert(TBSONObject.NewFrom('id', 1));
  FCollection.Insert(TBSONObject.NewFrom('id', 2));
  FCollection.Insert(TBSONObject.NewFrom('id', 3));
  FCollection.Insert(TBSONObject.NewFrom('id', 4));

  vCursor := FCollection.Find().Limit(1);

  CheckNotNull(vCursor);
  CheckEquals(4, vCursor.Count);
  CheckEquals(1, vCursor.Size);
end;

procedure TTestMongoDBCursor.TestCursor;
var
  vCursor: IMongoDBCursor;
  vItem: IBSONObject;
  vId: Integer;
begin
  FCollection.Insert(TBSONObject.NewFrom('id', 1).put('name', 'teste'));
  FCollection.Insert(TBSONObject.NewFrom('id', 2).put('name', 'teste'));
  FCollection.Insert(TBSONObject.NewFrom('id', 3).put('name', 'teste'));
  FCollection.Insert(TBSONObject.NewFrom('id', 4).put('name', 'teste'));
  FCollection.Insert(TBSONObject.NewFrom('id', 5).put('name', 'teste'));

  vCursor := FCollection.Find();
  vId := 0;
  CheckNotNull(vCursor);
  while vCursor.HasNext do
  begin
    vItem := vCursor.Next;

    Inc(vId);
    CheckEquals(3, vItem.Count);
    CheckEquals(vId, vItem.Items['id'].AsInteger);
  end;
  CheckEquals(5, vId);

  (*
  FCollection.Insert(TBSONObject.NewFrom('id', 6).put('name', 'teste'));
  FCollection.Insert(TBSONObject.NewFrom('id', 7).put('name', 'teste'));
  FCollection.Insert(TBSONObject.NewFrom('id', 8).put('name', 'teste'));
  FCollection.Insert(TBSONObject.NewFrom('id', 9).put('name', 'teste'));
  FCollection.Insert(TBSONObject.NewFrom('id', 10).put('name', 'teste'));
  *)
  
  vCursor := FCollection.Find().BatchSize(2);
  vId := 0;
  CheckNotNull(vCursor);
  while vCursor.HasNext do
  begin
    vItem := vCursor.Next;

    Inc(vId);
    CheckEquals(3, vItem.Count);
    CheckEquals(vId, vItem.Items['id'].AsInteger);
  end;
  CheckEquals(5, vId);
end;


procedure TTestMongoDBCursor.TestCursorWithFieldsSelector;
var
  vCursor: IMongoDBCursor;
  vItem: IBSONObject;
  vId: Integer;
begin
  FCollection.Insert(TBSONObject.NewFrom('id', 1).put('name', 'teste'));

  vCursor := FCollection.Find(TBSONObject.Empty, TBSONObject.NewFrom('id', 1));
  vId := 0;
  CheckNotNull(vCursor);
  while vCursor.HasNext do
  begin
    vItem := vCursor.Next;

    Inc(vId);
    CheckEquals(2, vItem.Count);
    CheckEquals('id', vItem.Item[1].Name);
    CheckEquals(vId, vItem.Items['id'].AsInteger);
  end;
  CheckEquals(1, vId);

  vCursor := FCollection.Find(TBSONObject.Empty, TBSONObject.NewFrom('id', 0));
  vId := 0;
  CheckNotNull(vCursor);
  while vCursor.HasNext do
  begin
    vItem := vCursor.Next;

    Inc(vId);
    CheckEquals(2, vItem.Count);
    CheckEquals('name', vItem.Item[1].Name);
    CheckEquals('teste', vItem.Items['name'].AsString);
  end;
  CheckEquals(1, vId);  
end;

initialization
  TTestMongoDBCursor.RegisterTest;

end.
