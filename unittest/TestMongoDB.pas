unit TestMongoDB;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCaseMongo, Mongo;

type
  //Require mongodb service running
  TTestMongoDB = class(TBaseTestCaseMongo)
  published
    procedure TestGetCollection;
  end;

implementation

uses BSONTypes;

{ TTestMongoDB }

procedure TTestMongoDB.TestGetCollection;
var
  vCollections: IBSONObject;
begin
  vCollections := DB.GetCollections;

  CheckNotNull(vCollections);
  CheckEquals(1, vCollections.Count);
  CheckEquals('system.indexes', vCollections.Items['name'].AsString);
end;

initialization
  TTestMongoDB.RegisterTest;

end.
