unit MongoDB;

interface

uses MongoCollection, BSONTypes, CommandResult;

type
  TMongoDB = class
  private
  protected
    function GetDBName: String;virtual;abstract;
  public
    property DBName: String read GetDBName;

    function RunCommand(ACommand: IBSONObject): ICommandResult;virtual;abstract;
    function GetLastError: ICommandResult;virtual;abstract;

    function GetCollection(AName: String): TMongoCollection;virtual;abstract;
    procedure DropCollection(AName: String);virtual;abstract;

    function Authenticate(AUserName, APassword: String): Boolean;virtual;abstract;
    procedure Logout;virtual;abstract;

    function GetCollections: IBSONObject;virtual;abstract;
    function GetUserCollections: IBSONObject;virtual;abstract;

    function CreateCollection(AName: String; AOptions: IBSONObject): TMongoCollection;virtual;abstract;
  end;

implementation

end.
