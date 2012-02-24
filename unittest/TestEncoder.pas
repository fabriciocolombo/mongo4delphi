unit TestEncoder;

interface

uses TestFramework, MongoEncoder, BSONStream;

type
  TTestEncoder = class(TTestCase)
  private
    FStream: TBSONStream;
    FEncoder: IMongoEncoder;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure ShouldRaiseBufferIsNotConfigured;
    procedure EncodeBSONObject;
    procedure EncodeBSONObjectSimpleTypes;
    procedure EncodeBSONObjectWithEmbeddedObject;
    procedure EncodeBSONArray;
    procedure EncodeUUID;
  end;

implementation

uses Variants, SysUtils, BSONTypes, ComObj, MongoUtils, MongoException;

{ TTestEncoder }

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

procedure TTestEncoder.EncodeUUID;
begin
  //Write object size - 4
  //Write type size 1
  //Write string 'uid' size 4 in UTF8
  //Write size guid 4
  //Write subtype size 1
  //Write guid size 16
  //Write EOO size 1


  FEncoder.Encode(TBSONObject.NewFrom('uid', TGUIDUtils.NewGuidAsString));

  CheckEquals(31, FStream.Size);
end;

procedure TTestEncoder.SetUp;
begin
  inherited;
  FStream := TBSONStream.Create;
  FEncoder := TDefaultMongoEncoder.Create;
  FEncoder.SetBuffer(FStream);
end;

procedure TTestEncoder.ShouldRaiseBufferIsNotConfigured;
begin
  ExpectedException := EMongoBufferIsNotConfigured;
  FEncoder.SetBuffer(nil);
  FEncoder.Encode(nil);
end;

procedure TTestEncoder.TearDown;
begin
  FStream.Free;
  inherited;
end;

initialization
  RegisterTest(TTestEncoder.Suite);

end.
