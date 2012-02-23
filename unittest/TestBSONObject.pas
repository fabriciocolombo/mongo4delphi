unit TestBSONObject;

interface

uses TestFramework, BSONTypes;

type
  TTestBSONObject = class(TTestCase)
  private
  published
    procedure PutNewItem;
    procedure UpdataExistentItem;
    procedure ShouldRaiseExceptionWithDuplicateActionError;
    procedure ShouldNotBeChangeDuplicateActionAfterAddItems;
  end;

implementation

uses MongoException, SysUtils;

{ TTestBSONObject }

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
  CheckEqualsString('key', vItem.Name);
  CheckEqualsString('value', vItem.Value);
end;

procedure TTestBSONObject.ShouldNotBeChangeDuplicateActionAfterAddItems;
var
  vBSON: IBSONObject;
begin
  ExpectedException := EBSONCannotChangeDuplicateAction;

  vBSON := TBSONObject.Create;
  vBSON.Put('key', 1);
  vBSON.DuplicatesAction := daError;
end;

procedure TTestBSONObject.ShouldRaiseExceptionWithDuplicateActionError;
var
  vBSON: IBSONObject;
begin
  ExpectedException := EBSONDuplicateKeyInList;

  vBSON := TBSONObject.Create;
  vBSON.DuplicatesAction := daError;
  vBSON.Put('key', 1);
  vBSON.Put('key', 2);
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
  CheckEqualsString('key', vItem.Name);
  CheckEqualsString('value', vItem.Value);

  vBSON.Put('key', 'changed');
  CheckEquals(1, vBSON.Count);

  vItemChanged := vBSON.Find('key');
  CheckNotNull(vItemChanged);
  CheckEqualsString('key', vItemChanged.Name);
  CheckEqualsString('changed', vItemChanged.Value);

  CheckTrue(vItem = vItemChanged);
end;

initialization
  RegisterTest(TTestBSONObject.Suite);

end.
