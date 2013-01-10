unit TestQueryBuilder;

interface

uses BaseTestCaseMongo;

type
  TTestQueryBuilder = class(TBaseTestCaseMongo)
  published
    procedure Field_X_Equals_1;
    procedure Field_X_Equals_1_and_Field_Y_equals_2;
    procedure Field_X_Greater_Than_1;
    procedure Field_X_Less_Than_1;
    procedure Field_X_Between_1_and_2;
  end;

implementation

uses BSONTypes, QueryBuilder, TestFramework;

{ TTestQueryBuilder }

procedure TTestQueryBuilder.Field_X_Between_1_and_2;
var
  vQuery: IBSONObject;
  vBetween: IBSONObject;
begin
  vQuery := TQueryBuilder.query('X').between(1, 2).buildAndFree();

  CheckNotNull(vQuery);
  CheckEquals(1, vQuery.Count);
  CheckEqualsString('X', vQuery.Item[0].Name);

  vBetween := vQuery.Item[0].AsBSONObject;
  CheckNotNull(vBetween);
  CheckEquals(2, vBetween.Count);
  CheckEquals ('$gte', vBetween.Item[0].Name);
  CheckEquals(1, vBetween.Item[0].AsInteger);

  CheckEquals ('$lte', vBetween.Item[1].Name);
  CheckEquals(2, vBetween.Item[1].AsInteger);
end;

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

procedure TTestQueryBuilder.Field_X_Greater_Than_1;
var
  vQuery: IBSONObject;
  vGT: IBSONObject;
begin
  vQuery := TQueryBuilder.query('X').greaterThan(1).buildAndFree();

  CheckNotNull(vQuery);
  CheckEquals(1, vQuery.Count);
  CheckEqualsString('X', vQuery.Item[0].Name);

  vGT := vQuery.Item[0].AsBSONObject;
  CheckNotNull(vGT);
  CheckEquals(1, vGT.Count);
  CheckEquals ('$gt', vGT.Item[0].Name);
  CheckEquals(1, vGT.Item[0].AsInteger);
end;

procedure TTestQueryBuilder.Field_X_Less_Than_1;
var
  vQuery: IBSONObject;
  vLT: IBSONObject;
begin
  vQuery := TQueryBuilder.query('X').lessThan(2).buildAndFree();

  CheckNotNull(vQuery);
  CheckEquals(1, vQuery.Count);
  CheckEqualsString('X', vQuery.Item[0].Name);

  vLT := vQuery.Item[0].AsBSONObject;
  CheckNotNull(vLT);
  CheckEquals(1, vLT.Count);
  CheckEquals ('$lt', vLT.Item[0].Name);
  CheckEquals(2, vLT.Item[0].AsInteger);
end;

initialization
  TTestQueryBuilder.RegisterTest;

end.
