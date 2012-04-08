unit QueryBuilder;

interface

uses BsonTypes;

type
  TQueryBuilder = class
  private
    FQuery: IBSONObject;
    FCurrentKey: String;

    function putKey(key: String): TQueryBuilder;
  protected
    constructor Create;
  public
    class function empty(): TQueryBuilder;
    class function query(key: String): TQueryBuilder;

    function build: IBSONObject;
    function buildAndFree: IBSONObject;

    function equals(value: Variant): TQueryBuilder;
    function andField(key: String): TQueryBuilder;
  end;

implementation

uses Variants;

{ TQueryBuilder }

function TQueryBuilder.andField(key: String): TQueryBuilder;
begin
  Result := putKey(key);
end;

function TQueryBuilder.build: IBSONObject;
begin
  Result := FQuery;
end;

function TQueryBuilder.buildAndFree: IBSONObject;
begin
  Result := build;

  Free;
end;

constructor TQueryBuilder.Create;
begin
  FQuery := TBSONObject.Create;
end;

class function TQueryBuilder.empty: TQueryBuilder;
begin
  Result := TQueryBuilder.Create;
end;

function TQueryBuilder.equals(value: Variant): TQueryBuilder;
begin
  FQuery.Put(FCurrentKey, value); 

  Result := Self;
end;

function TQueryBuilder.putKey(key: String): TQueryBuilder;
begin
  FQuery.Put(key, Null);
  FCurrentKey := key;

  Result := Self;
end;

class function TQueryBuilder.query(key: String): TQueryBuilder;
begin
  Result := TQueryBuilder.Create;

  Result.putKey(key);
end;

end.
