program unittest;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
  {$IFNDEF FPC}
  FastMM4,
  {$ELSE}
  Interfaces,
  {$ENDIF}
  GuiTestRunner,
  Forms,
  TestBSONItem in 'TestBSONItem.pas',
  TestBSONObject in 'TestBSONObject.pas',
  TestEncoder in 'TestEncoder.pas',
  TestBsonStream in 'TestBsonStream.pas',
  TestDecoder in 'TestDecoder.pas',
  TestMongoProvider in 'TestMongoProvider.pas',
  TestMongoCollection in 'TestMongoCollection.pas',
  BaseTestCase in 'BaseTestCase.pas',
  TestMongoDBCursor in 'TestMongoDBCursor.pas';

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
