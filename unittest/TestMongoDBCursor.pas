unit TestMongoDBCursor;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCaseMongo, Mongo, MongoDBCursor, BSONTypes;

type
  //Require mongodb service running
  TTestMongoDBCursor = class(TBaseTestCaseMongo)
  published
    procedure TestCountAndSize;
    procedure TestCursor;
    procedure TestCursorWithFieldsSelector;
    procedure TestExplain;
    procedure TestHint;
    procedure All;
  end;

implementation

uses Classes, MongoDBCursorIntf,
  TestFramework;

{ TTestMongoDBCursor }

procedure TTestMongoDBCursor.All;
var
  vCursor: IMongoDBCursor;
begin
  DefaultCollection.Insert(TBSONObject.NewFrom('codigo', 1).Put('descricao', 'cadeira1'));
  DefaultCollection.Insert(TBSONObject.NewFrom('codigo', 2).Put('descricao', 'cadeira2'));
  DefaultCollection.Insert(TBSONObject.NewFrom('codigo', 3).Put('descricao', 'cadeira3'));
  DefaultCollection.Insert(TBSONObject.NewFrom('codigo', 4).Put('descricao', 'cadeira4'));

  vCursor := DefaultCollection.Find(TBSONObject.EMPTY, TBSONObject.NewFrom('descricao', 1))
                              .Skip(1)
                              .Limit(2)
                              .BatchSize(1)
                              .Sort(TBSONObject.NewFrom('codigo', 1));

  CheckTrue(vCursor.HasNext);
  CheckEquals('cadeira2', vCursor.Next.Items['descricao'].AsString);

  CheckTrue(vCursor.HasNext);
  CheckEquals('cadeira3', vCursor.Next.Items['descricao'].AsString);

  CheckFalse(vCursor.HasNext);
end;

procedure TTestMongoDBCursor.TestCountAndSize;
var
  vCursor: IMongoDBCursor;
begin
  DefaultCollection.Insert(TBSONObject.NewFrom('id', 1));
  DefaultCollection.Insert(TBSONObject.NewFrom('id', 2));
  DefaultCollection.Insert(TBSONObject.NewFrom('id', 3));
  DefaultCollection.Insert(TBSONObject.NewFrom('id', 4));

  vCursor := DefaultCollection.Find().Limit(1);

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
  DefaultCollection.Insert(TBSONObject.NewFrom('id', 1).put('name', 'teste'));
  DefaultCollection.Insert(TBSONObject.NewFrom('id', 2).put('name', 'teste'));
  DefaultCollection.Insert(TBSONObject.NewFrom('id', 3).put('name', 'teste'));
  DefaultCollection.Insert(TBSONObject.NewFrom('id', 4).put('name', 'teste'));
  DefaultCollection.Insert(TBSONObject.NewFrom('id', 5).put('name', 'teste'));

  vCursor := DefaultCollection.Find();
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

  vCursor := DefaultCollection.Find().BatchSize(2);
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
  DefaultCollection.Insert(TBSONObject.NewFrom('id', 1).put('name', 'teste'));

  vCursor := DefaultCollection.Find(TBSONObject.Empty, TBSONObject.NewFrom('id', 1));
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

  vCursor := DefaultCollection.Find(TBSONObject.Empty, TBSONObject.NewFrom('id', 0));
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

procedure TTestMongoDBCursor.TestExplain;
var
  vExplain: IBSONObject;
begin
  vExplain := DefaultCollection.Find.Explain;

  CheckNotNull(vExplain);
  CheckEquals('BasicCursor', vExplain.Items['cursor'].AsString);
  CheckEquals(0, vExplain.Items['nscanned'].AsInteger);
  CheckEquals(0, vExplain.Items['nscannedObjects'].AsInteger);
  CheckEquals(0, vExplain.Items['n'].AsInteger);
  Check(vExplain.Items['millis'].AsInteger >= 0);
  CheckEquals(0, vExplain.Items['nYields'].AsInteger);
  CheckEquals(0, vExplain.Items['nChunkSkips'].AsInteger);
  CheckEquals(False, vExplain.Items['isMultiKey'].AsBoolean);
  CheckEquals(False, vExplain.Items['indexOnly'].AsBoolean);
end;

procedure TTestMongoDBCursor.TestHint;
var
  vDoc: IBSONObject;
begin
  DefaultCollection.CreateIndex(TBSONObject.NewFrom('idHint', 1), 'idx_test_hint');

  //Without hint
  vDoc := DefaultCollection.Find.Explain;
  CheckEquals('BasicCursor', vDoc.Items['cursor'].AsString);

  //Without indexName hint
  vDoc := DefaultCollection.Find.Hint('idx_test_hint').Explain;
  CheckEquals('BtreeCursor idx_test_hint', vDoc.Items['cursor'].AsString);

  //Without indexField hint
  vDoc := DefaultCollection.Find.Hint(TBSONObject.NewFrom('idHint', 1)).Explain;
  CheckEquals('BtreeCursor idx_test_hint', vDoc.Items['cursor'].AsString);

  DefaultCollection.DropIndex('idx_test_hint');
end;

initialization
  TTestMongoDBCursor.RegisterTest;

end.
