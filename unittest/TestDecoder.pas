unit TestDecoder;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCase, MongoDecoder, BSONStream, Classes;

type
  TTestDecoder = class(TBaseTestCase)
  private
    FStream: TBSONStream;
    FDecoder: IMongoDecoder;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure DecodeFindOneRow;
    procedure DecodeFindOneRowSimpleTypes;
    procedure DecodeFindOneEmbeddedDocument;
    procedure DecodeFindOneEmbeddedArray;
    procedure DecodeExplainBasicCursor;
    procedure DecodeExplainBTreeCursor;
    procedure DecodeFindOneBinary;
    procedure DecodeFindOneOldBinary;
    procedure DecodeFindOneBinaryUserDefined;
    procedure DecodeFindOneUUID;
    procedure DecodeFindOneRegEx;
    procedure DecodeFindOneSymbol;
    procedure DecodeFindOneCode;
    procedure DecodeFindOneCode_W_Scope;
    procedure DecodeFindOneTimeStamp;
    procedure DecodeFindOneMinKey;
    procedure DecodeFindOneMaxKey;
    procedure DecodeFindOneRef;
  end;
  
implementation

uses BSONTypes, Variants, SysUtils, DateUtils, BSON;

{ TTestDecoder }

procedure TTestDecoder.DecodeExplainBasicCursor;
var
  vDoc: IBSONObject;
begin
  FStream.LoadFromFile('.\response\ExplainBasicCursor.stream');

  vDoc := FDecoder.Decode(FStream);

  CheckEquals(11, vDoc.Count);
  CheckEquals('BasicCursor', vDoc.Items['cursor'].AsString);
end;

procedure TTestDecoder.DecodeExplainBTreeCursor;
var
  vDoc: IBSONObject;
begin
  FStream.LoadFromFile('.\response\ExplainBTreeCursor.stream');

  vDoc := FDecoder.Decode(FStream);

  CheckEquals(12, vDoc.Count);
  CheckEquals('BtreeCursor idx_id_value', vDoc.Items['cursor'].AsString);
end;

procedure TTestDecoder.DecodeFindOneBinary;
var
  vDoc: IBSONObject;
begin
  FStream.LoadFromFile('.\response\FindOneBinary.stream');

  vDoc := FDecoder.DecodeFromBeginning(FStream);

  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('img', vDoc[1].Name);
  CheckEquals(1335, vDoc[1].AsBSONBinary.Size);
  CheckEquals(BSON_SUBTYPE_GENERIC, vDoc[1].AsBSONBinary.SubType);
end;

procedure TTestDecoder.DecodeFindOneBinaryUserDefined;
var
  vDoc: IBSONObject;
begin
  FStream.LoadFromFile('.\response\FindOneBinaryUserDefined.stream');

  vDoc := FDecoder.DecodeFromBeginning(FStream);

  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('img', vDoc[1].Name);
  CheckEquals(1335, vDoc[1].AsBSONBinary.Size);
  CheckEquals(BSON_SUBTYPE_USER, vDoc[1].AsBSONBinary.SubType);
end;

procedure TTestDecoder.DecodeFindOneCode;
var
  vDoc: IBSONObject;
begin
  FStream.LoadFromFile('.\response\FindOneCode.stream');

  vDoc := FDecoder.DecodeFromBeginning(FStream);

  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('code', vDoc[1].Name);
  CheckEquals('this.a>3', vDoc[1].AsBSONCode.Code);
end;

procedure TTestDecoder.DecodeFindOneCode_W_Scope;
var
  vDoc: IBSONObject;
begin
  FStream.LoadFromFile('.\response\FindOneCode_W_Scope.stream');

  vDoc := FDecoder.DecodeFromBeginning(FStream);

  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('code_w_scope', vDoc[1].Name);
  CheckEquals('this.a>3', vDoc[1].AsBSONCode_W_Scope.Code);
  CheckEquals(1, vDoc[1].AsBSONCode_W_Scope.Scope.Items['id'].AsInteger);
end;

procedure TTestDecoder.DecodeFindOneEmbeddedArray;
var
  vDoc: IBSONObject;
  vItems: IBSONArray;
begin
  FStream.LoadFromFile('.\response\FindOneEmbeddedArray.stream');

  vDoc := FDecoder.DecodeFromBeginning(FStream);

  CheckNotNull(vDoc);
  CheckEquals(3, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('ObjectId("4f4bbc9662a3e6815389f94e")', vDoc[0].AsObjectId.ToStringMongo);
  CheckEquals('id', vDoc[1].Name);
  CheckEquals(123, vDoc[1].AsInteger);
  CheckEquals('items', vDoc[2].Name);
  vItems := vDoc[2].AsBSONArray;

  CheckNotNull(vItems);
  CheckEquals(3, vItems.Count);
  CheckEquals(1, vItems[0].AsInteger);
  CheckEquals(2, vItems[1].AsInteger);
  CheckEquals(3, vItems[2].AsInteger);
end;

procedure TTestDecoder.DecodeFindOneEmbeddedDocument;
var
  vDoc,
  vItems: IBSONObject;
begin
  FStream.LoadFromFile('.\response\FindOneEmbeddedDocument.stream');

  vDoc := FDecoder.DecodeFromBeginning(FStream);

  CheckNotNull(vDoc);
  CheckEquals(3, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('ObjectId("4f4bbbb462a3e6815389f930")', vDoc[0].AsObjectId.ToStringMongo);
  CheckEquals('id', vDoc[1].Name);
  CheckEquals(123, vDoc[1].AsInteger);
  CheckEquals('items', vDoc[2].Name);
  vItems := vDoc[2].AsBSONObject;

  CheckNotNull(vItems);
  CheckEquals(2, vItems.Count);
  CheckEquals('iditem', vItems[0].Name);
  CheckEquals(1, vItems[0].AsInteger);
  CheckEquals('name', vItems[1].Name);
  CheckEquals('Fabricio', vItems[1].AsString);
 
end;

procedure TTestDecoder.DecodeFindOneMaxKey;
var
  vDoc: IBSONObject;
begin
  FStream.LoadFromFile('.\response\FindOneMaxKey.stream');

  vDoc := FDecoder.DecodeFromBeginning(FStream);

  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('maxkey', vDoc[1].Name);
  Check(vDoc[1].IsMaxKey)
end;

procedure TTestDecoder.DecodeFindOneMinKey;
var
  vDoc: IBSONObject;
begin
  FStream.LoadFromFile('.\response\FindOneMinKey.stream');

  vDoc := FDecoder.DecodeFromBeginning(FStream);

  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('minkey', vDoc[1].Name);
  Check(vDoc[1].IsMinKey)
end;

procedure TTestDecoder.DecodeFindOneOldBinary;
var
  vDoc: IBSONObject;
begin
  FStream.LoadFromFile('.\response\FindOneOldBinary.stream');

  vDoc := FDecoder.DecodeFromBeginning(FStream);

  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('img', vDoc[1].Name);
  CheckEquals(1335, vDoc[1].AsBSONBinary.Size);
  CheckEquals(BSON_SUBTYPE_OLD_BINARY, vDoc[1].AsBSONBinary.SubType);
end;

procedure TTestDecoder.DecodeFindOneRef;
var
  vDoc: IBSONObject;
begin
  FStream.LoadFromFile('.\response\FindOneRef.stream');

  vDoc := FDecoder.DecodeFromBeginning(FStream);

  CheckNotNull(vDoc);
  CheckEquals(3, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('id', vDoc[1].Name);
  CheckEquals('ref', vDoc[2].Name);
  CheckNotNull(vDoc[2].AsBSONDBRef, 'Is not a BSONDBRef');
  CheckEquals('colref', vDoc[2].AsBSONDBRef.Collection);
  CheckEquals('4f50294f0ff7660738451101', vDoc[2].AsBSONDBRef.ObjectId.OID);
end;

procedure TTestDecoder.DecodeFindOneRegEx;
var
  vDoc: IBSONObject;
begin
  FStream.LoadFromFile('.\response\FindOneRegEx.stream');

  vDoc := FDecoder.DecodeFromBeginning(FStream);

  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('reg', vDoc[1].Name);
  CheckEquals('acme.*corp', vDoc[1].AsBSONRegEx.Pattern);
  CheckEquals(True, vDoc[1].AsBSONRegEx.CaseInsensitive_I);
  CheckEquals('ilmsux', vDoc[1].AsBSONRegEx.GetOptions);
end;

procedure TTestDecoder.DecodeFindOneRow;
var
  vDoc: IBSONObject;
begin
  FStream.LoadFromFile('.\response\FindOne.stream');

  vDoc := FDecoder.DecodeFromBeginning(FStream);

  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('ObjectId("4f46b9fa65760489cc96ab49")', vDoc[0].AsObjectId.ToStringMongo);
  CheckEquals('id', vDoc[1].Name);
  CheckEquals(123, Integer(vDoc[1].Value));  
end;

procedure TTestDecoder.DecodeFindOneRowSimpleTypes;
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

  vDoc := FDecoder.DecodeFromBeginning(FStream);

  CheckNotNull(vDoc);
  CheckEquals(18, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('ObjectId("4f46e6b971022f40a34a19fa")', vDoc[0].AsObjectId.ToStringMongo);
  CheckEquals('Fabricio', vDoc.Items['id01'].Value);
  CheckTrue(Null = vDoc.Items['id02'].Value, 'is not null');
  CheckTrue(Null = vDoc.Items['id03'].Value, 'is not null');
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
  CheckTrue(vDoc.Items['id16'].Value, 'Is not true');
  CheckFalse(vDoc.Items['id17'].Value, 'Is not false');
end;

procedure TTestDecoder.DecodeFindOneSymbol;
var
  vDoc: IBSONObject;
begin
  FStream.LoadFromFile('.\response\FindOneSymbol.stream');

  vDoc := FDecoder.DecodeFromBeginning(FStream);

  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('symbol', vDoc[1].Name);
  CheckEquals('any symbol', vDoc[1].AsBSONSymbol.Symbol);
end;

procedure TTestDecoder.DecodeFindOneTimeStamp;
var
  vDoc: IBSONObject;
begin
  FStream.LoadFromFile('.\response\FindOneTimeStamp.stream');

  vDoc := FDecoder.DecodeFromBeginning(FStream);

  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('ts', vDoc[1].Name);
  CheckEquals(1330623393, vDoc[1].AsBSONTimeStamp.Time);
  CheckEquals(1, vDoc[1].AsBSONTimeStamp.Inc);
end;

procedure TTestDecoder.DecodeFindOneUUID;
var
  vDoc: IBSONObject;
begin
  FStream.LoadFromFile('.\response\FindOneUUID.stream');

  vDoc := FDecoder.DecodeFromBeginning(FStream);

  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('uid', vDoc[1].Name);
  CheckEquals('{5EB1ED6D-1280-4CF6-AD0C-FA9CE1D87B51}', vDoc[1].AsString);
end;

procedure TTestDecoder.SetUp;
begin
  inherited;
  FStream := TBSONStream.Create;
  FDecoder := TMongoDecoderFactory.DefaultDecoder; 
end;

procedure TTestDecoder.TearDown;
begin
  inherited;
  FStream.Free;
end;

initialization
  TTestDecoder.RegisterTest;

end.
