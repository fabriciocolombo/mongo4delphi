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
  end;

implementation

uses TestFramework;

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
  FCollection.Insert(TBSONObject.NewFrom('id', 1));
  FCollection.Insert(TBSONObject.NewFrom('id', 2));
  FCollection.Insert(TBSONObject.NewFrom('id', 3));
  FCollection.Insert(TBSONObject.NewFrom('id', 4));
  FCollection.Insert(TBSONObject.NewFrom('id', 5));

  vCursor := FCollection.Find();

  vId := 0;
  CheckNotNull(vCursor);
  while vCursor.HasNext do
  begin
    vItem := vCursor.Next;

    Inc(vId);
    CheckEquals(vId, vItem.Items['id'].AsInteger);
  end;
  CheckEquals(5, vId);
  
  vCursor := FCollection.Find().BatchSize(2);

  vId := 0;
  CheckNotNull(vCursor);
  while vCursor.HasNext do
  begin
    vItem := vCursor.Next;

    Inc(vId);
    CheckEquals(vId, vItem.Items['id'].AsInteger);
  end;

  CheckEquals(5, vId);
end;


initialization
  TTestMongoDBCursor.RegisterTest;

end.
