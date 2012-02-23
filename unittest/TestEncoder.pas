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
    procedure EncodeTwoSimplePair;
    procedure EncodeAllSimpleTypes;
  end;

implementation

uses Variants, SysUtils;

{ TTestEncoder }

procedure TTestEncoder.EncodeAllSimpleTypes;
var
  vSingle: Single;
  vDouble: Double;
  vCurrency: Currency;
begin
  vSingle := 1.21;
  vDouble := 1.22;
  vCurrency := 1.23;

  FEncoder.BeginEncode; //4
  CheckEquals(4, FStream.Size);
  FEncoder.PutObjectField('id', 'Fabricio');     //1 + 3 + 13 = 17 +  4 = 21
  CheckEquals(21, FStream.Size);
  FEncoder.PutObjectField('id', Null);           //1 + 3     =  4 + 21 = 25
  CheckEquals(25, FStream.Size);
  FEncoder.PutObjectField('id', Unassigned);     //1 + 3     =  4 + 25 = 29
  CheckEquals(29, FStream.Size);
  FEncoder.PutObjectField('id', Date);           //1 + 3 + 8 = 12 + 29 = 41
  CheckEquals(41, FStream.Size);
  FEncoder.PutObjectField('id', Now);            //1 + 3 + 8 = 12 + 41 = 53
  CheckEquals(53, FStream.Size);
  FEncoder.PutObjectField('id', High(Byte));     //1 + 3 + 4 = 8 + 53 = 61
  CheckEquals(61, FStream.Size);
  FEncoder.PutObjectField('id', High(SmallInt)); //1 + 3 + 4 = 8 + 61 = 69
  CheckEquals(69, FStream.Size);
  FEncoder.PutObjectField('id', High(Integer));  //1 + 3 + 4 = 8 + 69 = 77
  CheckEquals(77, FStream.Size);
  FEncoder.PutObjectField('id', High(ShortInt)); //1 + 3 + 4 = 8 + 77 = 85
  CheckEquals(85, FStream.Size);
  FEncoder.PutObjectField('id', High(Word));     //1 + 3 + 4 = 8 + 85 = 93
  CheckEquals(93, FStream.Size);
  FEncoder.PutObjectField('id', High(LongWord)); //1 + 3 + 4 = 8 + 93 = 101
  CheckEquals(101, FStream.Size);
  FEncoder.PutObjectField('id', High(Int64));    //1 + 3 + 8 = 12 + 101 = 113
  CheckEquals(113, FStream.Size);
  FEncoder.PutObjectField('id', vSingle);        //1 + 3 + 8 = 12 + 113 = 125
  CheckEquals(125, FStream.Size);
  FEncoder.PutObjectField('id', vDouble);        //1 + 3 + 8 = 12 + 125 = 137
  CheckEquals(137, FStream.Size);
  FEncoder.PutObjectField('id', vCurrency);      //1 + 3 + 8 = 12 + 137 = 149
  CheckEquals(149, FStream.Size);
  FEncoder.PutObjectField('id', True);           //1 + 3 + 1 =  5 + 149 = 154
  CheckEquals(154, FStream.Size);
  FEncoder.PutObjectField('id', False);          //1 + 3 + 1 =  5 + 154 = 159
  CheckEquals(159, FStream.Size); 
  FEncoder.EndEncode; //1
  CheckEquals(160, FStream.Size);
end;

procedure TTestEncoder.EncodeTwoSimplePair;
var
  vInt64: Int64;
begin
  FEncoder.BeginEncode;
  //Write object size - 4
  //Write type size 1
  //Write string 'idç' size 5 in UTF8
  //Write int '123' size 4
  FEncoder.PutObjectField('idç', 123);

  CheckEquals(14, FStream.Size, 'Fail after write first element');

  //Write type size 1
  //Write string 'a' size 2 in UTF8
  //Write int64 '123' size 8
  //Write EOO

  vInt64 := 123;
  FEncoder.PutObjectField('a', vInt64);

  FEncoder.EndEncode;

  CheckEquals(26, FStream.Size, 'Fail after write second element');
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
