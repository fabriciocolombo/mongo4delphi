unit TestMongoProvider;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCase, MongoProvider, MongoDecoder, MongoEncoder, BSONTypes,
     CommandResult, WriteResult;

type
  TTestMongoProvider = class(TBaseTestCase)
  private
    FProvider: IMongoProvider;

    procedure CheckCommandResult(Result: ICommandResult);
    procedure CheckWriteResult(Result: IWriteResult);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRunCommand;
    procedure TestGetLastError;
    procedure TestInsert;
    procedure TestFindOne;
    procedure TestFindOneEmpty;
    procedure TestFindWithWhere;
    procedure TestRemove;
    procedure TestRemoveMultipleRows;
    procedure TestUpdate;
    procedure TestUpdateUpsert;
    procedure TestUpdateMulti;
    procedure TestUpdateUpsertMulti;
    procedure TestBatchRemove;
    procedure TestBatchInsert;
    procedure TestAuthentication;
    procedure TestCreateIndex;
  end;

implementation

const
  sDB = 'test';
  sColl = 'test';
  sUser = 'username';
  sPasswd = 'passwd';
  
{ TTestMongoProvider }

procedure TTestMongoProvider.CheckCommandResult(Result: ICommandResult);
begin
  CheckNotNull(Result);
  CheckTrue(Result.Ok, 'Is not Ok');

  CheckFalse(Result.HasError, 'Has an error: ' + Result.GetErrorMessage);
end;

procedure TTestMongoProvider.CheckWriteResult(Result: IWriteResult);
begin
  CheckNotNull(Result);

  CheckCommandResult(Result.getLastError);
end;

procedure TTestMongoProvider.SetUp;
begin
  inherited;
  FProvider := TDefaultMongoProvider.Create;
  FProvider.SetEncoder(TMongoEncoderFactory.DefaultEncoder);
  FProvider.SetDecoder(TMongoDecoderFactory.DefaultDecoder);
  FProvider.Connect(DEFAULT_HOST, DEFAULT_PORT);

  FProvider.RunCommand(sDB, TBSONObject.NewFrom('drop', sColl));
end;

procedure TTestMongoProvider.TearDown;
begin
  FProvider := nil;
  inherited;
end;

procedure TTestMongoProvider.TestAuthentication;
begin
  FProvider.Authenticate(sDB, sUser, sPasswd);

  FProvider.Logout(sDB);
end;

procedure TTestMongoProvider.TestBatchInsert;
var
  vOne, vTwo, vDoc: IBSONObject;
begin
  CheckNull(FProvider.FindOne(sDB, sColl));

  vOne := TBSONObject.NewFrom('_id', TBSONObjectId.NewFrom).Put('id', 123).Put('code', 2);
  vTwo := TBSONObject.NewFrom('_id', TBSONObjectId.NewFrom).Put('id', 123).Put('code', 2);

  CheckWriteResult(FProvider.Insert(sDB, sColl, [vOne, vTwo]));

  vDoc := FProvider.FindOne(sDB, sColl, TBSONObjectQueryHelper.NewFilterOid(vOne));
  CheckNotNull(vDoc);
  CheckEquals(vOne.GetOid.ToStringMongo, vDoc.GetOid.ToStringMongo);

  vDoc := FProvider.FindOne(sDB, sColl, TBSONObjectQueryHelper.NewFilterOid(vTwo));
  CheckNotNull(vDoc);
  CheckEquals(vTwo.GetOid.ToStringMongo, vDoc.GetOid.ToStringMongo);

end;

procedure TTestMongoProvider.TestBatchRemove;
var
  vOne, vTwo, vFilter,
  vDoc: IBSONObject;
begin
  vOne := TBSONObject.NewFrom('_id', TBSONObjectId.NewFrom).Put('id', 123).Put('code', 2);
  vTwo := TBSONObject.NewFrom('_id', TBSONObjectId.NewFrom).Put('id', 123).Put('code', 2);

  CheckWriteResult(FProvider.Insert(sDB, sColl, vOne));
  CheckWriteResult(FProvider.Insert(sDB, sColl, vTwo));

  vDoc := FProvider.FindOne(sDB, sColl);
  CheckNotNull(vDoc);

  vFilter := TBSONObjectQueryHelper.NewFilterBatchOID([vOne, vTwo]);

  CheckWriteResult(FProvider.Remove(sDB, sColl, vFilter));

  vDoc := FProvider.FindOne(sDB, sColl);
  CheckNull(vDoc);
end;

procedure TTestMongoProvider.TestCreateIndex;
begin
  CheckWriteResult(FProvider.CreateIndex(sDB, sColl, TBSONObject.NewFrom('id', 1), 'idx_teste'));
end;

procedure TTestMongoProvider.TestFindOne;
var
  vDoc: IBSONObject;
begin
  FProvider.Insert(sDB, sColl, TBSONObject.NewFrom('id', 1).Put('name', 'Fabricio'));
  FProvider.Insert(sDB, sColl, TBSONObject.NewFrom('id', 2).Put('name', 'Fabricio'));

  vDoc := FProvider.FindOne(sDB, sColl);

  CheckNotNull(vDoc);
  CheckEquals(3, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('id', vDoc[1].Name);
  CheckEquals(1, vDoc[1].AsInteger);
  CheckEquals('name', vDoc[2].Name);

  vDoc := FProvider.FindOne(sDB, sColl, TBSONObject.NewFrom('id', 2));
  CheckNotNull(vDoc);
  CheckEquals(3, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('id', vDoc[1].Name);
  CheckEquals(2, vDoc[1].AsInteger);
  CheckEquals('name', vDoc[2].Name);

  vDoc := FProvider.FindOne(sDB, sColl, TBSONObject.NewFrom('id', 2), TBSONObject.NewFrom('name', 1));
  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('name', vDoc[1].Name);
  CheckEquals('Fabricio', vDoc[1].AsString);
end;

procedure TTestMongoProvider.TestFindOneEmpty;
var
  vDoc: IBSONObject;
begin
  vDoc := FProvider.FindOne(sDB, sColl);

  CheckNull(vDoc);
end;

procedure TTestMongoProvider.TestFindWithWhere;
var
  vDoc: IBSONObject;
begin
  FProvider.Insert(sDB, sColl, TBSONObject.NewFrom('id', 1));
  FProvider.Insert(sDB, sColl, TBSONObject.NewFrom('id', 2));
  FProvider.Insert(sDB, sColl, TBSONObject.NewFrom('id', 3));

  vDoc := FProvider.FindOne(sDB, sColl, TBSONObject.NewFrom('$where', 'this.id == 2'));
  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEquals(2, vDoc.Items['id'].AsInteger);
end;

procedure TTestMongoProvider.TestGetLastError;
var
  vLastError: ICommandResult;
begin
  vLastError := FProvider.GetLastError(sDB);

  CheckCommandResult(vLastError);
end;

procedure TTestMongoProvider.TestInsert;
var
  vWriteResult: IWriteResult;
begin
  vWriteResult := FProvider.Insert(sDB, sColl, TBSONObject.NewFrom('id', 123));

  CheckWriteResult(vWriteResult);
end;

procedure TTestMongoProvider.TestRemove;
var
  vWriteResult: IWriteResult;
  vDoc: IBSONObject;
begin
  vWriteResult := FProvider.Insert(sDB, sColl, TBSONObject.NewFrom('id', 123));
  CheckWriteResult(vWriteResult);

  vDoc := FProvider.FindOne(sDB, sColl);
  CheckNotNull(vDoc);

  vWriteResult := FProvider.Remove(sDB, sColl, vDoc);
  CheckWriteResult(vWriteResult);
  
  vDoc := FProvider.FindOne(sDB, sColl);
  CheckNull(vDoc);
end;

procedure TTestMongoProvider.TestRemoveMultipleRows;
var
  vWriteResult: IWriteResult;
  vDoc: IBSONObject;
begin
  vWriteResult := FProvider.Insert(sDB, sColl, TBSONObject.NewFrom('id', 123).Put('code', 2));
  CheckWriteResult(vWriteResult);

  vWriteResult := FProvider.Insert(sDB, sColl, TBSONObject.NewFrom('id', 123).Put('code', 2));
  CheckWriteResult(vWriteResult);

  vDoc := FProvider.FindOne(sDB, sColl);
  CheckNotNull(vDoc);

  vWriteResult := FProvider.Remove(sDB, sColl, TBSONObject.NewFrom('code', 2));
  CheckWriteResult(vWriteResult);

  vDoc := FProvider.FindOne(sDB, sColl);
  CheckNull(vDoc);
end;

procedure TTestMongoProvider.TestRunCommand;
var
  vCommandResult: ICommandResult;
begin
  vCommandResult := FProvider.RunCommand(sDB, TBSONObject.NewFrom('dbStats', 1));

  CheckTrue(vCommandResult.Ok, 'Is not Ok');
  CheckFalse(vCommandResult.HasError, 'Has an error');
  CheckEquals(sDB, vCommandResult.Items['db'].Value);
end;

procedure TTestMongoProvider.TestUpdate;
var
  vInsert, vDoc: IBSONObject;
begin
  vInsert := TBSONObject.NewFrom('_id', TBSONObjectId.NewFrom).Put('id', 123).Put('code', 2);

  CheckWriteResult(FProvider.Insert(sDB, sColl, vInsert));

  vDoc := FProvider.FindOne(sDB, sColl);
  CheckEquals(2, vDoc.Items['code'].AsInteger);

  vInsert.Items['code'].Value := 7;

  CheckWriteResult(FProvider.Update(sDB, sColl, vDoc, vInsert, False, False));

  vDoc := FProvider.FindOne(sDB, sColl);
  CheckEquals(7, vDoc.Items['code'].AsInteger);
end;

procedure TTestMongoProvider.TestUpdateMulti;
var
  vOne, vTwo, vDoc: IBSONObject;
begin
  vOne := TBSONObject.NewFrom('_id', TBSONObjectId.NewFrom).Put('id', 123).Put('code', 2);
  vTwo := TBSONObject.NewFrom('_id', TBSONObjectId.NewFrom).Put('id', 123).Put('code', 2);

  CheckWriteResult(FProvider.Insert(sDB, sColl, [vOne, vTwo]));

  CheckWriteResult(FProvider.UpdateMulti(sDB, sColl, TBSONObject.NewFrom('code', 2), TBSONObject.NewFrom('$set', TBSONObject.NewFrom('code', 7))));

  vDoc := FProvider.FindOne(sDB, sColl);
  CheckEquals(7, vDoc.Items['code'].AsInteger);
end;

procedure TTestMongoProvider.TestUpdateUpsert;
var
  vInsert, vDoc: IBSONObject;
begin
  vInsert := TBSONObject.NewFrom('_id', TBSONObjectId.NewFrom).Put('id', 123).Put('code', 2);

  CheckWriteResult(FProvider.Update(sDB, sColl, TBSONObject.Empty, vInsert, True, False));

  vDoc := FProvider.FindOne(sDB, sColl);
  CheckEquals(2, vDoc.Items['code'].AsInteger);
end;

procedure TTestMongoProvider.TestUpdateUpsertMulti;
var
  vOne, vTwo, vDoc: IBSONObject;
begin
  vOne := TBSONObject.NewFrom('_id', TBSONObjectId.NewFrom).Put('id', 123).Put('code', 2);
  vTwo := TBSONObject.NewFrom('_id', TBSONObjectId.NewFrom).Put('id', 123).Put('code', 2);

  CheckWriteResult(FProvider.Update(sDB, sColl, TBSONObject.Empty, TBSONObject.NewFrom('$set', TBSONObject.NewFrom('code', 7)), True, True));

  vDoc := FProvider.FindOne(sDB, sColl);
  CheckEquals(7, vDoc.Items['code'].AsInteger);

end;

initialization
   TTestMongoProvider.RegisterTest;

end.

