unit TestBSONItem;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCase, BSONTypes;

type
  { TTestBSONItem }
  TTestBSONItem = class(TBaseTestCase)
  private
  published
    procedure CheckValueType;
    procedure CheckVariantInt64Value;
  end;

implementation

uses Variants, SysUtils;

{ TTestBSONItem }

procedure TTestBSONItem.CheckValueType;
var
  vItem: TBSONItem;
begin
  vItem := TBSONItem.NewFrom('key', '123');
  try
    CheckEquals(Ord(bvtString), Ord(vItem.ValueType));

    vItem.Value := 123;
    CheckEquals(Ord(bvtInteger), Ord(vItem.ValueType));

    vItem.Value := Null;
    CheckEquals(Ord(bvtNull), Ord(vItem.ValueType));
  finally
    vItem.Free;
  end;
end;

procedure TTestBSONItem.CheckVariantInt64Value;
var
  vItem: TBSONItem;
  vInt64: Int64;
  v: Variant;
begin
  vInt64 := 9223372036854775807;

  v := vInt64;

  vItem := TBSONItem.NewFrom('key', v);
  try
    CheckEquals(vInt64, vItem.AsInt64);
    CheckEquals(Ord(bvtInt64), Ord(vItem.ValueType), 'Invalid ValueType');
  finally
    vItem.Free;
  end;
end;


initialization
  TTestBSONItem.RegisterTest;

end.
