unit TestEncoder;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCaseMongo, MongoEncoder, BSONStream;

type
  TTestEncoder = class(TBaseTestCaseMongo)
  private
    FStream: TBSONStream;
    FEncoder: IMongoEncoder;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure ShouldRaiseBufferIsNotConfigured;
    procedure EncodeBSONObject;
    procedure EncodeBSONInt64;
    procedure EncodeBSONObjectSimpleTypes;
    procedure EncodeBSONObjectWithEmbeddedObject;
    procedure EncodeBSONArray;
    procedure EncodeUUID;
    procedure EncodeUnicodeKey;
    procedure EncodeJavaScriptWhere;
    procedure EncodeBinary;
    procedure EncodeBinarySubTypeOldBinary;
    procedure EncodeBinaryUserDefined;
    procedure EncodeRegEx;
    procedure EncodeSymbol;
    procedure EncodeCode;
    procedure EncodeCode_W_Scope;
    procedure EncodeTimeStamp;
    procedure EncodeMinKey;
    procedure EncodeMaxKey;
    procedure EncodeManualDBRef;
    procedure EncodeDBRef;
  end;

implementation

uses Variants, SysUtils, BSONTypes, ComObj, MongoUtils, MongoException, BSON,
  BSONDBRef;

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

procedure TTestEncoder.EncodeBSONInt64;
var
  vBSON: IBSONObject;
  vInt64: Int64;
begin
  vInt64 := 9223372036854775807;
  vBSON := TBSONObject.Create;
  vBSON.Put('id', vInt64);

  //Write object size - 4
  //Write type size 1
  //Write string 'id' size 3 in UTF8
  //Write value Int64 size 8
  //Write EOO size 1

  FEncoder.Encode(vBSON);

  CheckEquals(17, FStream.Size);
end;

procedure TTestEncoder.EncodeBSONObjectSimpleTypes;
var
  vSingle: Single;
  vDouble: Double;
  vCurrency: Currency;
  vInt64: Int64;
  vBSON: IBSONObject;
begin
  vSingle := 1.21;
  vDouble := 1.22;
  vCurrency := 1.23;
  vInt64 := 9223372036854775807;

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
  vBSON.Put('id11', LongWord(4294967295)); //1 + 5 + 4 = 10 + 113 = 123
  vBSON.Put('id12', vInt64);         //1 + 5 + 8 = 14 + 123 = 137
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
  try
    FEncoder.SetBuffer(nil);
    FEncoder.Encode(nil);
    Fail('Not raise exception');
  except
    on E: Exception do
      CheckTrue(E is EMongoBufferIsNotConfigured, E.Message);
  end;
end;

procedure TTestEncoder.TearDown;
begin
  FStream.Free;
  inherited;
end;

procedure TTestEncoder.EncodeUnicodeKey;
var
  vBSON: IBSONObject;
begin
  vBSON := TBSONObject.Create;
  vBSON.Put('ação', 123);

  //Write object size - 4
  //Write type size 1
  //Write string 'ação' size 7 in UTF8
  //Write 123 size 4
  //Write EOO size 1

  FEncoder.Encode(vBSON);

  CheckEquals(17, FStream.Size);
end;

procedure TTestEncoder.EncodeJavaScriptWhere;
var
  vBSON: IBSONObject;
begin
  vBSON := TBSONObject.Create;
  vBSON.Put('$where', 'this.a>3');

  //Write object size - 4
  //Write type size 1
  //Write string '$where' size 7 in UTF8
  //Write valueSize size 4
  //Write this.a>3 size 9
  //Write EOO size 1

  FEncoder.Encode(vBSON);

  CheckEquals(26, FStream.Size);
end;

procedure TTestEncoder.EncodeBinary;
var
  vBSON: IBSONObject;
  vBinary: IBSONBinary;
begin
  vBinary := TBSONBinary.Create;
  vBinary.Stream.LoadFromFile('resource\image.gif'); //size 1.335

  vBSON := TBSONObject.Create;
  vBSON.Put('img', vBinary);

  //Write object size - 4
  //Write type size 1
  //Write string 'img' size 4 in UTF8
  //Write valueSize size 4
  //Write subtype size 1
  //Write binary size 1335
  //Write EOO size 1

  FEncoder.Encode(vBSON);

  CheckEquals(1350, FStream.Size);
end;

procedure TTestEncoder.EncodeBinarySubTypeOldBinary;
var
  vBSON: IBSONObject;
  vBinary: IBSONBinary;
begin
  vBinary := TBSONBinary.Create(BSON_SUBTYPE_OLD_BINARY);
  vBinary.Stream.LoadFromFile('resource\image.gif'); //size 1.335

  vBSON := TBSONObject.Create;
  vBSON.Put('img', vBinary);

  //Write object size - 4
  //Write type size 1
  //Write string 'img' size 4 in UTF8
  //Write valueSize size 4
  //Write subtype size 1
  //Write binary size 1335
  //Write EOO size 1

  FEncoder.Encode(vBSON);

  CheckEquals(1354, FStream.Size);
end;

procedure TTestEncoder.EncodeRegEx;
var
  vBSON: IBSONObject;
  vRegEx: IBSONRegEx;
begin
  vRegEx := TBSONRegEx.Create;
  vRegEx.Pattern := 'acme.*corp';
  vRegEx.CaseInsensitive_I := True;
  vRegEx.Multiline_M := True;
  vRegEx.Verbose_X := True;
  vRegEx.DotAll_S := True;
  vRegEx.LocaleDependent_L := True;
  vRegEx.Unicode_U := True;

  CheckEquals('ilmsux', vRegEx.GetOptions);

  vBSON := TBSONObject.Create;
  vBSON.Put('reg', vRegEx);

  //Write object size - 4
  //Write type size 1
  //Write string 'reg' size 4 in UTF8
  //Write pattern size 11
  //Write flags size 7
  //Write EOO size 1

  FEncoder.Encode(vBSON);

  CheckEquals(28, FStream.Size);
end;

procedure TTestEncoder.EncodeSymbol;
var
  vBSON: IBSONObject;
begin
  vBSON := TBSONObject.Create;
  vBSON.Put('symbol', TBSONSymbol.NewFrom('any symbol'));

  //Write object size - 4
  //Write type size 1
  //Write string 'symbol' size 7 in UTF8
  //Write valueSize size 4
  //Write 'any symbol' size 11
  //Write EOO size 1

  FEncoder.Encode(vBSON);

  CheckEquals(28, FStream.Size);
end;

procedure TTestEncoder.EncodeCode;
var
  vBSON: IBSONObject;
begin
  vBSON := TBSONObject.Create;
  vBSON.Put('code', TBSONCode.NewFrom('this.a>3'));

  //Write object size - 4
  //Write type size 1
  //Write string 'code' size 5 in UTF8
  //Write valueSize size 4
  //Write this.a>3 size 9
  //Write EOO size 1

  FEncoder.Encode(vBSON);

  CheckEquals(24, FStream.Size);
end;

procedure TTestEncoder.EncodeCode_W_Scope;
var
  vBSON: IBSONObject;
begin
  vBSON := TBSONObject.Create;
  vBSON.Put('code_w_scope', TBSONCode_W_Scope.NewFrom('this.a>3', TBSONObject.NewFrom('id', 1)));

  //Write object size - 4
  //Write type size 1
  //Write string 'code_w_scope' size 13 in UTF8
  //Write valueSize size 4
  //Write codeSize size 4
  //Write this.a>3 size 9
  //Write scope size size 13 
    //Write object size - 4
    //Write type size 1
    //Write string 'id' size 3 in UTF8
    //Write value size 4
    //Write EOO size 1
  //Write EOO size 1

  FEncoder.Encode(vBSON);

  CheckEquals(49, FStream.Size);
end;

procedure TTestEncoder.EncodeTimeStamp;
var
  vBSON: IBSONObject;
begin
  vBSON := TBSONObject.Create;
  vBSON.Put('ts', TBSONTimeStamp.NewFrom(0, 0));

  //Write object size - 4
  //Write type size 1
  //Write string 'ts' size 3 in UTF8
  //Write inc size 4
  //Write time size 4
  //Write EOO size 1

  FEncoder.Encode(vBSON);

  CheckEquals(17, FStream.Size);
end;

procedure TTestEncoder.EncodeMinKey;
var
  vBSON: IBSONObject;
begin
  vBSON := TBSONObject.Create;
  vBSON.Put('minkey', MIN_KEY);

  //Write object size - 4
  //Write type size 1
  //Write MinKey size 7
  //Write EOO size 1

  FEncoder.Encode(vBSON);

  CheckEquals(13, FStream.Size);
end;

procedure TTestEncoder.EncodeMaxKey;
var
  vBSON: IBSONObject;
begin
  vBSON := TBSONObject.Create;
  vBSON.Put('maxkey', MAX_KEY);

  //Write object size - 4
  //Write type size 1
  //Write MaxKey size 7
  //Write EOO size 1

  FEncoder.Encode(vBSON);

  CheckEquals(13, FStream.Size);
end;

procedure TTestEncoder.EncodeBinaryUserDefined;
var
  vBSON: IBSONObject;
  vBinary: IBSONBinary;
begin
  vBinary := TBSONBinary.Create(BSON_SUBTYPE_USER);
  vBinary.Stream.LoadFromFile('resource\image.gif'); //size 1.335

  vBSON := TBSONObject.Create;
  vBSON.Put('img', vBinary);

  //Write object size - 4
  //Write type size 1
  //Write string 'img' size 4 in UTF8
  //Write valueSize size 4
  //Write subtype size 1
  //Write binary size 1335
  //Write EOO size 1

  FEncoder.Encode(vBSON);

  CheckEquals(1350, FStream.Size);
end;

procedure TTestEncoder.EncodeDBRef;
var
  vBSON: IBSONObject;
begin
  vBSON := TBSONObject.Create;
  vBSON.Put('id', 1);
  vBSON.Put('ref', TBSONDBRef.NewFrom(DB.DBName, DefaultCollection.CollectionName, TBSONObjectId.NewFrom));

  FEncoder.Encode(vBSON);

  CheckEquals(72, FStream.Size);
end;

procedure TTestEncoder.EncodeManualDBRef;
var
  vBSON,
  vEmbedded: IBSONObject;
begin
  vBSON := TBSONObject.Create;
  vBSON.Put('id', 1);

  //Write object size - 4
  //Write type size 1                   1 + 4 = 5
  //Write string 'id' size 3 in UTF8    5 + 3 = 8
  //Write value '123' size 4            8 + 4 = 12

  vEmbedded := TBSONObject.Create;
  vEmbedded.Put('$ref', 'colref');
  vEmbedded.Put('$id', TBSONObjectId.NewFrom.OID);

  vBSON.Put('ref', vEmbedded);
  //Write type size 1                    12 +  1 = 13
  //Write string 'ref' size 4 in UTF8    13 +  4 = 17
    //Write object size - 4              17 +  4 = 21
    //Write type  size 1                  1 + 21 = 22
    //Write string '$ref' size 5 in UTF8  5 + 22 = 27
    //Write value size 'colref' size 4    4 + 27 = 31
    //Write value 'colref' size 7         7 + 31 = 38
    //Write type  size 1                  1 + 38 = 39
    //Write string '$id' size 4 in UTF8   4 + 39 = 43
    //Write value size 'oid' size 4       4 + 43 = 47
    //Write value oid size 25            25 + 47 = 72
    //Write EOO size 1                    1 + 72 = 73
  //Write EOO size 1                      1 + 73 = 74

  FEncoder.Encode(vBSON);

  CheckEquals(74, FStream.Size);
end;

initialization
  TTestEncoder.RegisterTest;

end.
