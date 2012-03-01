unit TestBSONTypes;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCase, BSONTypes;

type
  TTestBSONObject = class(TBaseTestCase)
  private
  published
    procedure PutNewItem;
    procedure UpdataExistentItem;
    procedure ShouldRaiseExceptionWithDuplicateActionError;
    procedure ShouldNotBeChangeDuplicateActionAfterAddItems;
    procedure ExtractOID;
    procedure ExtractOIDShouldRaiseExceptionWhenNotFound;
  end;

  TTestBSONBinary = class(TBaseTestCase)
  private
  published
    procedure TestAcceptableBinarySubtypes;
  end;

implementation

uses MongoException, SysUtils, BSON;

{ TTestBSONObject }

procedure TTestBSONObject.ExtractOID;
var
  vDoc: IBSONObject;
  vNewOID, vOID: IBSONObjectId;
begin
  vNewOID := TBSONObjectId.NewFrom;
  vDoc := TBSONObject.NewFrom('_id', vNewOID).Put('code', 1);

  Check(vDoc.HasOid);

  vOID := vDoc.GetOid;

  CheckNotNull(vOID);
  CheckEquals(vNewOID.ToStringMongo, vOID.ToStringMongo);
end;

procedure TTestBSONObject.ExtractOIDShouldRaiseExceptionWhenNotFound;
var
  vDoc: IBSONObject;
begin
  vDoc := TBSONObject.NewFrom('code', 1);

  CheckFalse(vDoc.HasOid, 'Should not have OID');

  vDoc.Put('_id', 123);

  CheckFalse(vDoc.HasOid, 'Should not have OID');

  try
    vDoc.GetOid;
    Fail('Not raise exception');
  except
    on E: Exception do
      Check(E is EBSONObjectHasNoObjectId);
  end;
end;

procedure TTestBSONObject.PutNewItem;
var
  vBSON: IBSONObject;
  vItem: TBSONItem;
begin
  vBSON := TBSONObject.Create;

  CheckEquals(0, vBSON.Count);

  vBSON.Put('key', 'value');

  CheckEquals(1, vBSON.Count);

  vItem := vBSON.Find('key');
  CheckNotNull(vItem);
  CheckEquals('key', vItem.Name);
  CheckEquals('value', vItem.Value);
end;

procedure TTestBSONObject.ShouldNotBeChangeDuplicateActionAfterAddItems;
var
  vBSON: IBSONObject;
begin
  try
    vBSON := TBSONObject.Create;
    vBSON.Put('key', 1);
    vBSON.DuplicatesAction := daError;

    Fail('Not raise exception');
  except
    on E: Exception do
      CheckTrue(E is EBSONCannotChangeDuplicateAction, E.Message);
  end;
end;

procedure TTestBSONObject.ShouldRaiseExceptionWithDuplicateActionError;
var
  vBSON: IBSONObject;
begin
  try
    vBSON := TBSONObject.Create;
    vBSON.DuplicatesAction := daError;
    vBSON.Put('key', 1);
    vBSON.Put('key', 2);

    Fail('Not raise exception');
  except
    on E: Exception do
      CheckTrue(E is EBSONDuplicateKeyInList, E.Message);
  end;
end;

procedure TTestBSONObject.UpdataExistentItem;
var
  vBSON: IBSONObject;
  vItem,
  vItemChanged: TBSONItem;
begin
  vBSON := TBSONObject.Create;

  CheckEquals(0, vBSON.Count);

  vBSON.Put('key', 'value');

  CheckEquals(1, vBSON.Count);

  vItem := vBSON.Find('key');
  CheckNotNull(vItem);
  CheckEquals('key', vItem.Name);
  CheckEquals('value', vItem.Value);

  vBSON.Put('key', 'changed');
  CheckEquals(1, vBSON.Count);

  vItemChanged := vBSON.Find('key');
  CheckNotNull(vItemChanged);
  CheckEquals('key', vItemChanged.Name);
  CheckEquals('changed', vItemChanged.Value);

  CheckTrue(vItem = vItemChanged, 'Not is the same item');
end;

{ TTestBSONBinary }

procedure TTestBSONBinary.TestAcceptableBinarySubtypes;
var
  vBinary: IBSONBinary;
begin
  vBinary := TBSONBinary.Create(BSON_SUBTYPE_GENERIC);
  vBinary := TBSONBinary.Create(BSON_SUBTYPE_OLD_BINARY);
  vBinary := TBSONBinary.Create(BSON_SUBTYPE_USER);

  try
    TBSONBinary.Create(BSON_SUBTYPE_FUNC);
    Fail('Not raise exception');
  except
    on E: Exception do
      Check(E is EIllegalArgumentException);
  end;

  try
    TBSONBinary.Create(BSON_SUBTYPE_UUID);
    Fail('Not raise exception');
  except
    on E: Exception do
      Check(E is EIllegalArgumentException);
  end;

  try
    TBSONBinary.Create(BSON_SUBTYPE_MD5);
    Fail('Not raise exception');
  except
    on E: Exception do
      Check(E is EIllegalArgumentException);
  end;
end;

initialization
  TTestBSONObject.RegisterTest;
  TTestBSONBinary.RegisterTest;

end.
