unit TestMongoProvider;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCase, MongoProvider, MongoDecoder, MongoEncoder, BSONTypes;

type
  TTestMongoProvider = class(TBaseTestCase)
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
  FProvider := nil;
  inherited;
end;

procedure TTestMongoProvider.TestGetLastError;
var
  vLastError: ICommandResult;
begin
  vLastError := FProvider.GetLastError('test');

  CheckNotNull(vLastError);
  CheckTrue(vLastError.Ok, 'Is not Ok');
  CheckFalse(vLastError.HasError, 'Has an error');
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
  CheckTrue(vLastError.Ok, 'Is not Ok');
  CheckTrue(vWriteResult.getCachedLastError = vLastError, 'Not cached the error');
  CheckTrue(vWriteResult.getCachedLastError = vWriteResult.getLastError, 'Not cached the error');
end;

procedure TTestMongoProvider.TestRunCommand;
var
  vCommandResult: ICommandResult;
begin
  vCommandResult := FProvider.RunCommand('test', TBSONObject.NewFrom('dbStats', 1));
  CheckTrue(vCommandResult.Ok, 'Is not Ok');
  CheckFalse(vCommandResult.HasError, 'Has an error');
  CheckEquals('test', vCommandResult.Items['db'].Value);
end;

initialization
   TTestMongoProvider.RegisterTest;

end.
