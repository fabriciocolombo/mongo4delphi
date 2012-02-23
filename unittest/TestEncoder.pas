unit TestEncoder;

interface

uses TestFramework, MongoEncoder, BSONStream;

type
  TTestEncoder = class(TTestCase)
  private
    FStream: TBSONStream;
    FEncoder: TMongoEncoder;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure EncodeSimpleTypes;
  end;

implementation

{ TTestEncoder }

procedure TTestEncoder.EncodeSimpleTypes;
var
  vInt64: Int64;
begin
  //Write object size - 4
  //Write type size 1
  //Write string 'idç' size 5 in UTF8
  //Write int '123' size 4
  //Write EOO
  FEncoder.PutObjectField('idç', 123);

  CheckEquals(15, FStream.Size, 'Fail after write first element');

  //Write object size - 4
  //Write type size 1
  //Write string 'a' size 2 in UTF8
  //Write int64 '123' size 8
  //Write EOO

  vInt64 := 123;
  FEncoder.PutObjectField('a', vInt64);

  CheckEquals(31, FStream.Size, 'Fail after write second element');
end;

procedure TTestEncoder.SetUp;
begin
  inherited;
  FStream := TBSONStream.Create;
  FEncoder := TMongoEncoder.Create(FStream);
end;

procedure TTestEncoder.TearDown;
begin
  FStream.Free;
  FEncoder.Free;
  inherited;
end;

initialization
  RegisterTest(TTestEncoder.Suite);

end.
