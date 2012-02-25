unit TestMongoProvider;

interface

uses TestFramework, MongoProvider, MongoDecoder, MongoEncoder, BSONTypes;

type
  TTestMongoProvider = class(TTestCase)
  private
    FProvider: IMongoProvider;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRunCommand;
    procedure TestGetLastError;
    procedure TestInsert;
  end;

implementation

{ TTestMongoProvider }

procedure TTestMongoProvider.SetUp;
begin
  inherited;
  FProvider := TDefaultMongoProvider.Create;
  FProvider.SetEncoder(TMongoEncoderFactory.DefaultEncoder);
  FProvider.SetDecoder(TMongoDecoderFactory.DefaultDecoder);
  FProvider.Connect(DEFAULT_HOST, DEFAULT_PORT);
end;

procedure TTestMongoProvider.TearDown;
begin
  inherited;
end;

procedure TTestMongoProvider.TestGetLastError;
var
  vLastError: ICommandResult;
begin
  vLastError := FProvider.GetLastError('test');

  CheckNotNull(vLastError);
  CheckTrue(vLastError.Ok);
  CheckFalse(vLastError.HasError);
  CheckEquals(-1, vLastError.GetCode);
end;

procedure TTestMongoProvider.TestInsert;
var
  vWriteResult: IWriteResult;
  vLastError: ICommandResult;
begin
  vWriteResult := FProvider.Insert('test', 'test', TBSONObject.NewFrom('id', 123));

  CheckNotNull(vWriteResult);

  vLastError := vWriteResult.getLastError;

  CheckNotNull(vLastError);
  CheckTrue(vLastError.Ok);
  CheckTrue(vWriteResult.getCachedLastError = vLastError);
  CheckTrue(vWriteResult.getCachedLastError = vWriteResult.getLastError);
end;

procedure TTestMongoProvider.TestRunCommand;
var
  vCommandResult: ICommandResult;
begin
  vCommandResult := FProvider.RunCommand('test', TBSONObject.NewFrom('dbStats', 1));
  CheckTrue(vCommandResult.Ok);
  CheckFalse(vCommandResult.HasError);
  CheckEqualsString('test', vCommandResult.Items['db'].Value);
end;

initialization
   RegisterTest(TTestMongoProvider.Suite);

end.
