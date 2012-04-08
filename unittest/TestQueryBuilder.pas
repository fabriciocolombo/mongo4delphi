unit TestQueryBuilder;

interface

uses BaseTestCaseMongo;

type
  TTestQueryBuilder = class(TBaseTestCaseMongo)
  published
    procedure Field_X_Equals_1;
    procedure Field_X_Equals_1_and_Field_Y_equals_2;
  end;

implementation

uses BSONTypes, QueryBuilder, TestFramework;

{ TTestQueryBuilder }

procedure TTestQueryBuilder.Field_X_Equals_1;
var
  vQuery: IBSONObject;
begin
  vQuery := TQueryBuilder.query('X').equals(1).buildAndFree();

  CheckNotNull(vQuery);
  CheckEquals(1, vQuery.Count);
  CheckEqualsString('X', vQuery.Item[0].Name);
  CheckEquals(1, vQuery.Item[0].AsInteger);
end;

procedure TTestQueryBuilder.Field_X_Equals_1_and_Field_Y_equals_2;
var
  vQuery: IBSONObject;
begin
  vQuery := TQueryBuilder.query('X').equals(1).andField('Y').equals(2).buildAndFree();

  CheckNotNull(vQuery);
  CheckEquals(2, vQuery.Count);
  CheckEqualsString('X', vQuery.Item[0].Name);
  CheckEquals(1, vQuery.Item[0].AsInteger);
  CheckEqualsString('Y', vQuery.Item[1].Name);
  CheckEquals(2, vQuery.Item[1].AsInteger);
end;

initialization
  TTestQueryBuilder.RegisterTest;

end.
