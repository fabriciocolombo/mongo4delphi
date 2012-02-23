unit TestBSONItem;

interface

uses TestFramework, BSONTypes;

type
  TTestBSONItem = class(TTestCase)
  private
  published
    procedure CheckValueType;
  end;

implementation

uses Variants;

{ TTestBSONItem }

procedure TTestBSONItem.CheckValueType;
var
  vItem: TBSONItem;
begin
  vItem := TBSONItem.NewFrom('key', '123');
  try
    CheckEquals(varOleStr, vItem.ValueType);

    vItem.Value := 123;
    CheckEquals(varInteger, vItem.ValueType);

    vItem.Value := Null;
    CheckEquals(varNull, vItem.ValueType);
  finally
    vItem.Free;
  end;
end;

initialization
  RegisterTest(TTestBSONItem.Suite);

end.
