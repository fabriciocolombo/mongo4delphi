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
  {$ENDIF}  GuiTestRunner,
  Forms,
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
  DecoderCallback in '..\src\DecoderCallback.pas',
  AbstractMongo in '..\src\AbstractMongo.pas';

{$R *.res}

begin
  Application.Initialize;
  {$IFNDEF FPC}
    GuiTestRunner.RunRegisteredTests;
  {$ELSE}
    Application.CreateForm(TTestRunner, TestRunner);
  {$ENDIF}
  Application.Run;
end.
