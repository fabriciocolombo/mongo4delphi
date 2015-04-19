unit TestMongoDB;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCaseMongo, Mongo, MongoCollection, WriteResult, Classes;

type
  //Require mongodb service running
  TTestMongoDB = class(TBaseTestCaseMongo)
  private
  published
    procedure TestGetCollection;
    procedure TestBulkGetDB;
    procedure TestBulkGetCollection;
    procedure TestFailedAuthentication;
    procedure TestCreateUser_Authentication_RemoveUser;
    procedure TestSerialization;
  end;

implementation

uses BSONTypes, SysUtils, MongoException;

{ TTestMongoDB }

procedure TTestMongoDB.TestBulkGetCollection;
var
  i: Integer;
begin
  for i := 1 to 1000000 do
  begin
    DB.GetCollection(IntToStr(i)).Free;
  end;
end;

procedure TTestMongoDB.TestBulkGetDB;
var
  i: Integer;
begin
  for i := 1 to 1000000 do
  begin
    Mongo.getDB(IntToStr(i)).Free;
  end;
end;

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

procedure TTestMongoDB.TestFailedAuthentication;
begin
  ExpectedException := EMongoAuthenticationFailed;
  DB.Authenticate('non', 'existent');
end;

procedure TTestMongoDB.TestGetCollection;
var
  vCollections: IBSONObject;
begin
  vCollections := DB.GetCollections;

  CheckNotNull(vCollections);
  CheckTrue(vCollections.Count > 0);
end;

procedure TTestMongoDB.TestSerialization;
var
  vIN, vOUT: IBSONObject;
  vStream: TMemoryStream;
begin
  vIN := TBSONObject.NewFrom('_id', TBSONObjectId.NewFrom).Put('name', 'Fabricio');

  vStream := TMemoryStream.Create;
  try
    Mongo.SaveObjectToStream(vIN, vStream);

    vOUT := Mongo.LoadObjectFromStream(vStream) as IBSONObject;

    CheckNotNull(vOUT);

    CheckEquals(vIN.AsJsonReadable,  vOUT.AsJsonReadable);
  finally
    vStream.Free;
  end;
end;

initialization
  TTestMongoDB.RegisterTest;

end.
