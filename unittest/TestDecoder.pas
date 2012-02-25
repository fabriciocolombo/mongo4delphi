unit TestDecoder;

interface

uses TestFramework, MongoDecoder, BSONStream;

type
  TTestEncoder = class(TTestCase)
  private
    FStream: TBSONStream;
    FDecoder: IMongoDecoder;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure DecodeFindOneRow;
    procedure DecodeFindOneRowSimpleTypes;
  end;
  
implementation

uses BSONTypes, Variants, SysUtils, DateUtils;

{ TTestEncoder }

procedure TTestEncoder.DecodeFindOneRow;
var
  vDoc: IBSONObject;
begin
  FStream.LoadFromFile('.\response\FindOne.stream');

  vDoc := FDecoder.Decode(FStream);

  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEqualsString('_id', vDoc[0].Name);
  CheckEqualsString('ObjectId("4f46b9fa65760489cc96ab49")', vDoc[0].AsObjectId.ToStringMongo);
  CheckEqualsString('id', vDoc[1].Name);
  CheckEquals(123, Integer(vDoc[1].Value));  
end;

procedure TTestEncoder.DecodeFindOneRowSimpleTypes;
var
  vDoc: IBSONObject;
  vSingle: Single;
  vDouble: Double;
  vCurrency: Currency;
begin
  vSingle := 1.21;
  vDouble := 1.22;
  vCurrency := 1.23;
  
  FStream.LoadFromFile('.\response\FindOneRowSingleTypes.stream');

  vDoc := FDecoder.Decode(FStream);

  CheckNotNull(vDoc);
  CheckEquals(18, vDoc.Count);
  CheckEqualsString('_id', vDoc[0].Name);
  CheckEqualsString('ObjectId("4f46e6b971022f40a34a19fa")', vDoc[0].AsObjectId.ToStringMongo);
  CheckEqualsString('Fabricio', vDoc.Items['id01'].Value);
  CheckTrue(Null = vDoc.Items['id02'].Value);
  CheckTrue(Null = vDoc.Items['id03'].Value);
  CheckEquals(EncodeDate(2012, 02, 23), VarToDateTime(vDoc.Items['id04'].Value));
  CheckEquals(EncodeDateTime(2012, 02, 23, 22, 24, 09, 643), VarToDateTime(vDoc.Items['id05'].Value));
  CheckEquals(High(Byte), vDoc.Items['id06'].AsInteger);
  CheckEquals(High(SmallInt), vDoc.Items['id07'].AsInteger);
  CheckEquals(High(Integer), vDoc.Items['id08'].AsInteger);
  CheckEquals(High(ShortInt), vDoc.Items['id09'].AsInteger);
  CheckEquals(High(Word), vDoc.Items['id10'].AsInteger);
  CheckEquals(-1, vDoc.Items['id11'].AsInteger); //Fail LongWord
  CheckEquals(High(Int64), vDoc.Items['id12'].AsInt64);
  CheckEquals(vSingle, vDoc.Items['id13'].Value);
  CheckEquals(vDouble, vDoc.Items['id14'].Value, 0.001);
  CheckEquals(vCurrency, vDoc.Items['id15'].Value, 0.001);
  CheckTrue(vDoc.Items['id16'].Value);
  CheckFalse(vDoc.Items['id17'].Value);
end;

procedure TTestEncoder.SetUp;
begin
  inherited;
  FStream := TBSONStream.Create;
  FDecoder := TMongoDecoderFactory.DefaultDecoder; 
end;

procedure TTestEncoder.TearDown;
begin
  inherited;
  FStream.Free;
end;

initialization
  RegisterTest(TTestEncoder.Suite);

end.
