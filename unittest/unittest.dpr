program unittest;

uses
  FastMM4,
  Forms,
  GuiTestRunner,
  MongoDecoder in '..\src\MongoDecoder.pas',
  MongoEncoder in '..\src\MongoEncoder.pas',
  BSON in '..\src\BSON.pas',
  MongoException in '..\src\MongoException.pas',
  TestEncoder in 'TestEncoder.pas',
  TestBsonStream in 'TestBsonStream.pas',
  BSONStream in '..\src\BSONStream.pas',
  Mongo in '..\src\Mongo.pas',
  TestMongoCollection in 'TestMongoCollection.pas',
  BSONTypes in '..\src\BSONTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  GuiTestRunner.RunRegisteredTests;
  Application.Run;
end.
