unit TestMongoDB;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCaseMongo, Mongo, MongoCollection, WriteResult;

type
  //Require mongodb service running
  TTestMongoDB = class(TBaseTestCaseMongo)
  private
  published
    procedure TestGetCollection;
    procedure TestCreateUser_Authentication_RemoveUser;
  end;

implementation

uses BSONTypes, TestFramework;

{ TTestMongoDB }

procedure TTestMongoDB.TestCreateUser_Authentication_RemoveUser;
var
  vWriteResult: IWriteResult;
begin
  vWriteResult := DB.AddUser(sUser, sPasswd, False);

  CheckNotNull(vWriteResult);
  CheckNotNull(vWriteResult.getLastError);
  CheckTrue(vWriteResult.getLastError.Ok);

  CheckTrue(DB.Authenticate(sUser, sPasswd));

  DB.Logout;

  vWriteResult := DB.RemoveUser(sUser);
  CheckNotNull(vWriteResult);
  CheckNotNull(vWriteResult.getLastError);
  CheckTrue(vWriteResult.getLastError.Ok);
end;

procedure TTestMongoDB.TestGetCollection;
var
  vCollections: IBSONObject;
begin
  vCollections := DB.GetCollections;

  CheckNotNull(vCollections);
  CheckTrue(vCollections.Count > 0);
end;

initialization
  TTestMongoDB.RegisterTest;

end.
