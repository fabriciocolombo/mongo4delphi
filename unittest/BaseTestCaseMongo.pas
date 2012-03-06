unit BaseTestCaseMongo;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCase, Mongo, MongoDB, MongoCollection;

const
  sDB = 'unit';
  sColl = 'test';
  
type
  //Require mongodb service running
  TBaseTestCaseMongo = class(TBaseTestCase)
  private
    FMongo: TMongo;
    FDB: TMongoDB;
    FDefaultCollection: TMongoCollection;
  protected
    property Mongo: TMongo read FMongo;
    property DB: TMongoDB read FDB;
    property DefaultCollection: TMongoCollection read FDefaultCollection;

    procedure SetUp; override;
    procedure TearDown; override;
  end;


implementation

{ TBaseTestCaseMongo }

procedure TBaseTestCaseMongo.SetUp;
begin
  inherited;
  FMongo := TMongo.Create;
  FMongo.Connect();

  FDB := FMongo.getDB(sDB);

  FDefaultCollection := FDB.GetCollection(sColl);

  FDefaultCollection.Drop;
end;

procedure TBaseTestCaseMongo.TearDown;
begin
  FMongo.Free;
  inherited;
end;

end.
