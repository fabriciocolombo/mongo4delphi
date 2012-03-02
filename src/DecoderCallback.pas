unit DecoderCallback;

interface

uses AbstractMongo;

type
  IDecoderCallback = interface
  ['{35185E61-47B6-4855-9EA9-8EFB229038CB}']
    function GetCollection: TAbstractMongoCollection;
  end;

  TDecoderCallback = class(TInterfacedObject, IDecoderCallback)
  private
    FCollection: TAbstractMongoCollection;
  public
    function GetCollection: TAbstractMongoCollection;

    constructor Create(ACollection: TAbstractMongoCollection);
  end;

implementation

{ TDecoderCallback }

constructor TDecoderCallback.Create(ACollection: TAbstractMongoCollection);
begin
  FCollection := ACollection;
end;

function TDecoderCallback.GetCollection: TAbstractMongoCollection;
begin
  Result := FCollection;
end;

end.
