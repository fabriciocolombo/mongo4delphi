program unittest;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

(*
  {$IFNDEF FPC}
  FastMM4,
  {$ELSE}
  Interfaces,
  {$ENDIF}
*)
uses
  {$IFNDEF FPC}
  FastMM4,
  {$ELSE}
  Interfaces,
  {$ENDIF}
  Forms,
  GuiTestRunner,
  TestBSONItem in 'TestBSONItem.pas',
  TestBSONTypes in 'TestBSONTypes.pas',
  TestEncoder in 'TestEncoder.pas',
  TestBsonStream in 'TestBsonStream.pas',
  TestDecoder in 'TestDecoder.pas',
  TestMongoProvider in 'TestMongoProvider.pas',
  TestMongoCollection in 'TestMongoCollection.pas',
  BaseTestCase in 'BaseTestCase.pas',
  TestMongoDBCursor in 'TestMongoDBCursor.pas',
  BSON in '..\src\BSON.pas',
  BSONStream in '..\src\BSONStream.pas',
  BSONTypes in '..\src\BSONTypes.pas',
  Mongo in '..\src\Mongo.pas',
  MongoDecoder in '..\src\MongoDecoder.pas',
  MongoEncoder in '..\src\MongoEncoder.pas',
  MongoException in '..\src\MongoException.pas',
  MongoProvider in '..\src\MongoProvider.pas',
  MongoUtils in '..\src\MongoUtils.pas',
  MongoMD5 in '..\src\MongoMD5.pas',
  ServerError in '..\src\ServerError.pas',
  TestServerError in 'TestServerError.pas',
  TestMongoDB in 'TestMongoDB.pas',
  BaseTestCaseMongo in 'BaseTestCaseMongo.pas',
  BSONDBRef in '..\src\BSONDBRef.pas',
  MongoDB in '..\src\MongoDB.pas',
  MongoCollection in '..\src\MongoCollection.pas',
  MongoConnector in '..\src\MongoConnector.pas',
  MongoDBApiLayer in '..\src\MongoDBApiLayer.pas',
  OutMessage in '..\src\OutMessage.pas',
  WriteConcern in '..\src\WriteConcern.pas',
  WriteResult in '..\src\WriteResult.pas',
  CommandResult in '..\src\CommandResult.pas',
  MongoDBCursor in '..\src\MongoDBCursor.pas',
  MongoCollectionApiLayer in '..\src\MongoCollectionApiLayer.pas',
  MongoDBCursorIntf in '..\src\MongoDBCursorIntf.pas',
  TestQueryBuilder in 'TestQueryBuilder.pas',
  QueryBuilder in '..\src\QueryBuilder.pas',
  TestJsonWriter in 'TestJsonWriter.pas',
  JsonWriter in '..\src\JsonWriter.pas',
  TestMongoUpdate in 'TestMongoUpdate.pas',
  BSONObjectIdGenerator in '..\src\BSONObjectIdGenerator.pas',
  GridFS in '..\src\GridFS.pas',
  TestGridFS in 'TestGridFS.pas',
  TestMongoUtils in 'TestMongoUtils.pas';

{$R *.res}

const
  LEAK_INDY = 21;
begin
  RegisterExpectedMemoryLeak(LEAK_INDY);

  Application.Initialize;
  {$IFNDEF FPC}
    GuiTestRunner.RunRegisteredTests;
  {$ELSE}
    Application.CreateForm(TTestRunner, TestRunner);
  {$ENDIF}
  Application.Run;
end.
