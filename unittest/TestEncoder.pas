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
    procedure EncodeObjectId;
    procedure EncodeBSONObject;
    procedure EncodeBSONObjectSimpleTypes;
    procedure EncodeBSONObjectWithEmbeddedObject;
    procedure EncodeBSONArray;
  end;

implementation

uses Variants, SysUtils, BSONTypes;

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

procedure TTestEncoder.EncodeBSONArray;
var
  vBSON,
  vArray: IBSONObject;
begin
  vArray := TBSONArray.Create;
  vArray.Put('id2', '123'); 
  //Write object size - 4
  //Write type  size 1
  //Write string 'id2' size 4 in UTF8
  //Write value size '123' size 4
  //Write value '123' size 4
  //Write EOO size 1
  // Total 18

  vBSON := TBSONObject.Create;
  vBSON.Put('id', 123);
  vBSON.Put('id2', vArray);

  //Write object size - 4
  //Write type size 1
  //Write string 'id' size 3 in UTF8
  //Write value '123' size 4
  //Write type size 1
  //Write string 'id2' size 4 in UTF8
  //Write EOO size 1
  //Total 18

  //Total = 18 + 18 = 36;

  FEncoder.Encode(vBSON);

  CheckEquals(36, FStream.Size);
end;

procedure TTestEncoder.EncodeBSONObject;
var
  vBSON: IBSONObject;
begin
  vBSON := TBSONObject.Create;
  vBSON.Put('id', 123);

  //Write object size - 4
  //Write type size 1
  //Write string 'id' size 3 in UTF8
  //Write value '123' size 4
  //Write EOO size 1

  FEncoder.Encode(vBSON);

  CheckEquals(13, FStream.Size);
end;

procedure TTestEncoder.EncodeBSONObjectSimpleTypes;
var
  vSingle: Single;
  vDouble: Double;
  vCurrency: Currency;
  vBSON: IBSONObject;
begin
  vSingle := 1.21;
  vDouble := 1.22;
  vCurrency := 1.23;

  vBSON := TBSONObject.Create;

  //Total size info                    4
  vBSON.Put('id01', 'Fabricio');     //1 + 5 + 13 = 19 + 4 = 23
  vBSON.Put('id02', Null);           //1 + 5     =  6 + 23 = 29
  vBSON.Put('id03', Unassigned);     //1 + 5     =  6 + 29 = 35
  vBSON.Put('id04', Date);           //1 + 5 + 8 = 14 + 35 = 49
  vBSON.Put('id05', Now);            //1 + 5 + 8 = 14 + 49 = 63
  vBSON.Put('id06', High(Byte));     //1 + 5 + 4 = 10 + 63 = 73
  vBSON.Put('id07', High(SmallInt)); //1 + 5 + 4 = 10 + 73 = 83
  vBSON.Put('id08', High(Integer));  //1 + 5 + 4 = 10 + 83 = 93
  vBSON.Put('id09', High(ShortInt)); //1 + 5 + 4 = 10 + 93 = 103
  vBSON.Put('id10', High(Word));     //1 + 5 + 4 = 10 + 103 = 113
  vBSON.Put('id11', High(LongWord)); //1 + 5 + 4 = 10 + 113 = 123
  vBSON.Put('id12', High(Int64));    //1 + 5 + 8 = 14 + 123 = 137
  vBSON.Put('id13', vSingle);        //1 + 5 + 8 = 14 + 137 = 151
  vBSON.Put('id14', vDouble);        //1 + 5 + 8 = 14 + 151 = 165
  vBSON.Put('id15', vCurrency);      //1 + 5 + 8 = 14 + 165 = 179
  vBSON.Put('id16', True);           //1 + 5 + 1 =  7 + 179 = 186
  vBSON.Put('id17', False);          //1 + 5 + 1 =  7 + 186 = 193
  //EOO                                1

  FEncoder.Encode(vBSON);

  CheckEquals(194, FStream.Size);
end;

procedure TTestEncoder.EncodeBSONObjectWithEmbeddedObject;
var
  vBSON,
  vEmbedded: IBSONObject;
begin
  vEmbedded := TBSONObject.Create;
  vEmbedded.Put('id2', '123'); 
  //Write object size - 4
  //Write type  size 1
  //Write string 'id2' size 4 in UTF8
  //Write value size '123' size 4
  //Write value '123' size 4
  //Write EOO size 1
  // Total 18

  vBSON := TBSONObject.Create;
  vBSON.Put('id', 123);
  vBSON.Put('id2', vEmbedded);

  //Write object size - 4
  //Write type size 1
  //Write string 'id' size 3 in UTF8
  //Write value '123' size 4
  //Write type size 1
  //Write string 'id2' size 4 in UTF8
  //Write EOO size 1
  //Total 18

  //Total = 18 + 18 = 36;

  FEncoder.Encode(vBSON);

  CheckEquals(36, FStream.Size);
end;

procedure TTestEncoder.EncodeObjectId;
begin
  FEncoder.BeginEncode;
  //Write object size - 4
  //Write type size 1
  //Write string 'idç' size 5 in UTF8
  //Write oid size 12
  //Write EOO size 1
  FEncoder.PutObjectField('idç', TObjectId.NewFrom);

  FEncoder.EndEncode;

  CheckEquals(23, FStream.Size, 'Fail after write second element');
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
