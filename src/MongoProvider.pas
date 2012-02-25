unit MongoProvider;

interface

uses Sockets, MongoEncoder, MongoDecoder, BSONTypes, Classes, BSONStream;

const
  DEFAULT_HOST = 'localhost';
  DEFAULT_PORT = 27017;
  
type
  IMongoProvider = interface;

  ICommandResult = interface(IBSONObject)
    ['{8F4C1FA8-5CD5-433A-A641-16DA896B42DB}']

    function Ok: Boolean;
    function HasError: Boolean;
    function GetCode: Integer;
  end;

  TCommandResult = class(TBSONObject, ICommandResult)
  public
    function HasError: Boolean;
    function Ok: Boolean;
    function GetCode: Integer;
  end;

  IWriteResult = interface
    ['{0D69DCD2-60CA-4EA6-9318-6B1EAC69ABE2}']

    function getCachedLastError(): ICommandResult;
    function getLastError(): ICommandResult;
  end;

  TWriteResult = class(TInterfacedObject, IWriteResult)
  private
    FProvider: IMongoProvider;
    FRequestId: Integer;
    FDB: String;
    FLastErrorResult: ICommandResult;
  public
    function getCachedLastError: ICommandResult;
    function getLastError: ICommandResult;

    constructor Create(const AProvider: IMongoProvider; ADB: String; ARequestId: Integer);
  end;

  IMongoProvider = interface
    ['{DBF272FB-59BE-4CA6-B38B-2B1E5879EC34}']

    procedure SetEncoder(const AEncoder: IMongoEncoder);
    procedure SetDecoder(const ADecoder: IMongoDecoder);
        
    procedure Connect(AHost: String; APort: Integer);
    procedure Close;

    function GetLastError(DB: String; RequestId: Integer=0): ICommandResult;
    function RunCommand(DB: String; Command: IBSONObject): ICommandResult;

    function Insert(DB, Collection: String; BSONObject: IBSONObject): IWriteResult;

    function FindOne(DB, Collection: String; Query: IBSONObject): IBSONObject;
  end;

  TDefaultMongoProvider = class(TInterfacedObject, IMongoProvider)
  private
    FRequestId: Integer;
    FSocket: TTcpClient;
    FEncoder: IMongoEncoder;
    FDecoder: IMongoDecoder;
    FQueueRequests: TStringList;

    procedure ReadResponse(AStream: TBSONStream; ARequestId: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetEncoder(const AEncoder: IMongoEncoder);
    procedure SetDecoder(const ADecoder: IMongoDecoder);

    procedure Connect(AHost: String; APort: Integer);
    procedure Close;

    function GetLastError(DB: String; RequestId: Integer=0): ICommandResult;
    function RunCommand(DB: String; Command: IBSONObject): ICommandResult;

    function Insert(DB, Collection: String; BSONObject: IBSONObject): IWriteResult;

    function FindOne(DB, Collection: String; Query: IBSONObject): IBSONObject;

    //TODO - Assert socket is Connected
  end;

implementation

uses MongoException, SysUtils, Windows, BSON, Variants;

const
  COMMAND_COLLECTION = '$cmd'; 

{ TDefaultMongoProvider }

procedure TDefaultMongoProvider.Close;
begin
  FSocket.Close;
end;

constructor TDefaultMongoProvider.Create;
begin
  inherited;

  FSocket := TTcpClient.Create(nil);
  FQueueRequests := TStringList.Create;
end;

destructor TDefaultMongoProvider.Destroy;
begin
  FQueueRequests.Free;
  Close;
  FSocket.Free;
  inherited;
end;

function TDefaultMongoProvider.FindOne(DB, Collection: String; Query: IBSONObject): IBSONObject;
var
  vLength: Integer;
  vStartingFrom: Integer;
  vNumberReturned: Integer;
  vRequestID:integer;
  vResponseTo:integer;
  vOpCode:integer;
  vFlags:integer;
  vCursorId: Int64;
  vStream: TBSONStream;
begin
  InterlockedIncrement(FRequestId);

  vStream := TBSONStream.Create;
  try
    vStream.Clear;
    vStream.WriteInt(0); //length
    vStream.WriteInt(FRequestId);
    vStream.WriteInt(0);//ResponseTo
    vStream.WriteInt(OP_QUERY);
    vStream.WriteInt(0);//Flags
    vStream.WriteUTF8String(Format('%s.%s', [DB, Collection]));
    vStream.WriteInt(0); //NumberToSkip
    vStream.WriteInt(1); //NumberToReturn

    if (Query = nil) then
    begin
      Query := TBSONObject.Create;
    end;

    FEncoder.SetBuffer(vStream);
    FEncoder.Encode(Query);

    vLength := vStream.Size;
    vStream.WriteInt(0, vLength);

    FSocket.SendBuf(vStream.Memory^, vLength);

//    if ReturnFieldSelector<>nil then (ReturnFieldSelector as IPersistStream).Save(FData,false);
    ReadResponse(vStream, FRequestId);

//    vStream.SaveToFile('FindOneRowSingleTypes.stream');

    vStream.Position := 0;
    vStream.Read(vLength, 4);
    vStream.Read(vRequestID, 4);
    vStream.Read(vResponseTo, 4);
    vStream.Read(vOpCode, 4);
    vStream.Read(vFlags, 4);
    vStream.Read(vCursorId, 8);
    vStream.Read(vStartingFrom, 4);
    vStream.Read(vNumberReturned, 4);

    if (vFlags and $0001) <> 0 then
      raise Exception.Create('MongoWire.Get: cursor not found');

    if vNumberReturned = 0 then
      raise Exception.Create('MongoWire.Get: no documents returned');

    vStream.Position := 0;
    Result := FDecoder.Decode(vStream);

    if (vFlags and $0002) <> 0 then
      raise Exception.Create('MongoWire.Get: '+VarToStr(Result.Items['$err'].Value));

///    Result := TWriteResult.Create(Self, DB, FRequestId);
  finally
    vStream.Free;
  end;
end;

function TDefaultMongoProvider.GetLastError(DB: String; RequestId: Integer): ICommandResult;
begin
  if (RequestId > 0) and (RequestId <> FRequestId) then
  begin
    Result := nil;
    Exit;
  end;
  Result := RunCommand(DB, TBSONObject.NewFrom('getlasterror', 1));
end;

function TDefaultMongoProvider.Insert(DB, Collection: String;BSONObject: IBSONObject): IWriteResult;
var
  vLength: Integer;
  vStream: TBSONStream;
begin
  InterlockedIncrement(FRequestId);

  vStream := TBSONStream.Create;
  try
    vStream.Clear;
    vStream.WriteInt(0); //length
    vStream.WriteInt(FRequestId);
    vStream.WriteInt(0);//ResponseTo
    vStream.WriteInt(OP_INSERT);
    vStream.WriteInt(0);//Flagss
    vStream.WriteUTF8String(Format('%s.%s', [DB, Collection]));

    FEncoder.SetBuffer(vStream);
    FEncoder.Encode(BSONObject);

    vLength := vStream.Size;
    vStream.WriteInt(0, vLength);

    FSocket.SendBuf(vStream.Memory^, vLength);

    Result := TWriteResult.Create(Self, DB, FRequestId);
  finally
    vStream.Free;
  end;
end;

procedure TDefaultMongoProvider.Connect(AHost: String; APort: Integer);
begin
  FSocket.Close;
  FSocket.RemoteHost := AHost;
  FSocket.RemotePort := IntToStr(APort);
  FSocket.Open;
  if not FSocket.Connected then
    raise EMongoConnectionFailureException.CreateResFmt(@sMongoConnectionFailureException, [AHost, APort]);
end;

procedure TDefaultMongoProvider.ReadResponse(AStream: TBSONStream; ARequestId: Integer);
const
  dSize=$10000;
var
  i,l:integer;
  buf:array[0..2] of integer;
  d:array[0..dSize-1] of byte;
begin
  repeat
    //MsgLength,RequestID,ResponseTo
    i := FSocket.ReceiveBuf(buf[0],12);
    if i <> 12 then
      raise EMongoException.Create('MongoWire: invalid response');

      if buf[2] = ARequestId then
      begin
        //forward start of header
        AStream.Position:=0;
        AStream.Write(buf[0],12);
        l:=buf[0]-12;
        while l>0 do
         begin
          if l<dSize then i:=l else i:=dSize;
          i:=FSocket.ReceiveBuf(d[0],i);
          if i=0 then raise EMongoException.Create('MongoWire: response aborted');
          AStream.Write(d[0],i);
          dec(l,i);
         end;
        //set position after message header
        if buf[0]<36 then
          AStream.Position:=buf[0]
        else
          AStream.Position:=36;
      end;
  until buf[2]= ARequestID;
end;

function TDefaultMongoProvider.RunCommand(DB: String; Command: IBSONObject): ICommandResult;
var
  vBSON: IBSONObject;
begin
  vBSON := FindOne(DB, COMMAND_COLLECTION, Command);

  Result := TCommandResult.Create;
  Result.PutAll(vBSON);
end;

procedure TDefaultMongoProvider.SetDecoder(const ADecoder: IMongoDecoder);
begin
  FDecoder := ADecoder;
end;

procedure TDefaultMongoProvider.SetEncoder(const AEncoder: IMongoEncoder);
begin
  FEncoder := AEncoder;
end;

{ TWriteResult }


constructor TWriteResult.Create(const AProvider: IMongoProvider; ADB: String; ARequestId: Integer);
begin
  FProvider := AProvider;
  FDB := ADB;
  FRequestId := ARequestId;
end;

function TWriteResult.getCachedLastError: ICommandResult;
begin
  Result := ICommandResult(FLastErrorResult);
end;

function TWriteResult.getLastError: ICommandResult;
begin
  if Assigned(FLastErrorResult) then
  begin
    Result := FLastErrorResult
  end
  else
  begin
    Result := FProvider.GetLastError(FDB, FRequestId);

    FLastErrorResult := Result;
  end;
end;

{ TCommandResult }

function TCommandResult.GetCode: Integer;
var
  vCode: TBSONItem;
begin
  Result := -1;

  vCode := Find('code');

  if (vCode <> nil) then
  begin
    Result := vCode.Value;
  end;
end;

function TCommandResult.HasError: Boolean;
var
  vOK: TBSONItem;
begin
  vOK := Items['err'];

  Result := Length(vOK.AsString) > 1;
end;

function TCommandResult.Ok: Boolean;
var
  vOK: TBSONItem;
begin
  vOK := Items['ok'];

  Result := (vOK.Value = True) or (vOK.Value = Ord(True));
end;

end.
