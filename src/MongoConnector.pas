unit MongoConnector;

interface

uses MongoDB, MongoCollection, OutMessage, WriteConcern, WriteResult;

type
  IMongoConnector = interface
  ['{78A85A28-75DA-4F72-AC75-76F59327E073}']
//    procedure RequestStart;
//    procedure RequestDone;
//    procedure RequestEnsureConnection;

    function Send(ADB: TMongoDB; AOutMessage: IOutMessage; AConcern: IWriteConcern) : IWriteResult;
    //function Send(ADB: TMongoDB; AOutMessage: IOutMessage; AConcern: IWriteConcern; AHostNeeded: IServerAddress) : IWriteResult;

    //function call(ADB: TMongoDB; ACollection: TMongoCollection; AOutMessage: IOutMessage; ServerAddress hostNeeded, DBDecoder decoder ): Response;
    //function call(ADB: TMongoDB; ACollection: TMongoCollection; AOutMessage: IOutMessage; ServerAddress hostNeeded, Retries: Integer): Response;
    //function call(ADB: TMongoDB; ACollection: TMongoCollection; AOutMessage: IOutMessage; ServerAddress hostNeeded, Retries: Integer, ReadPreferences, DBDecoder decoder ): Response;

    function IsOpen: Boolean;
    
  end;

implementation

end.
