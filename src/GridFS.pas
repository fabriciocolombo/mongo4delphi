unit GridFS;

interface

uses MongoDB, MongoCollection, BSONTypes, MongoUtils, Classes;

type
  TGridFS = class;
  TGridFSFile = class;
  TGridFSFileWriter = class;

  IGridFSFile = interface(IBSONObject)
  ['{948F40E2-9D30-44D4-8C97-916C049714CE}']
    function GetLength: Integer;
    function GetChunkSize: Integer;
    function GetId: IBSONObjectId;
    function GetFileName: String;
    function GetContentType: String;
    function GetUploadDate: TDateTime;
    function GetMD5: String;

    function numChunks: Integer;

    function GetInputStream: TStream;

    procedure SetGridFS(AGridFS: TGridFS);
  end;  

  TGridFS = class
  private
    FDB: TMongoDB;
    FChunksCollection: TMongoCollection;
    FFilesCollection: TMongoCollection;
    FBucketName: String;

    function VerifyResult(const ABSONObject: IBSONObject): IGridFSFile;
  public
    constructor Create(ADB: TMongoDB);overload;
    constructor Create(ADB: TMongoDB; ABucketName: String);overload;

    function CreateFile(AFileName: String): TGridFSFileWriter;

    function findOne(const AFileName: String): IGridFSFile;overload;
    function findOne(const AQuery: IBSONObject): IGridFSFile;overload;
  end;
    
  TGridFSFile = class(TBSONObject, IGridFSFile)
  private
    FLength: Integer;
    FChunkSize: Integer;
    FId: IBSONObjectId;
    FFileName: String;
    FContentType: String;
    FUploadDate: TDateTime;
    FMD5: String;
    FExtraData: IBSONObject;
    FGridFS: TGridFS;
  protected
    procedure PushItem(AIndex: Integer; AItem: TBSONItem); override;
  public
    function GetLength: Integer;
    function GetChunkSize: Integer;
    function GetId: IBSONObjectId;
    function GetFileName: String;
    function GetContentType: String;
    function GetUploadDate: TDateTime;
    function GetMD5: String;

    function numChunks: Integer;

    procedure SetGridFS(AGridFS: TGridFS);

    procedure AfterConstruction; override;

    function GetInputStream: TStream;

    function GetChunkData(const AChunkNum: Integer): IBSONBinary;
  end;

  TGridFSFileWriter = class
  private
    FGridFS: TGridFS;
    FFileName: String;
    FContentType: String;
    FChunkSize: Integer;
  public
    constructor Create(AGridFS: TGridFS; AFileName: String);

    function SetContentType(AContentType: String): TGridFSFileWriter;
    function SetChunkSize(AChunkSize: Integer): TGridFSFileWriter;

    procedure Store(AStream: TStream);
  end;

implementation

uses SysUtils, Math, MongoException;

type
  TGridFsFileStreamReader = class(TMemoryStream)
  private
    FGridFsFile: TGridFSFile;
    FNumChunks: Integer;
    FCurrentChunk: Integer;
    FCurrentChunkData: IBSONBinary;

    function Avaliable: Integer;

    function InternalRead(Count: Integer): Integer;
  public
    constructor Create(AGridFsFile: TGridFSFile);

    function Read(var Buffer; Count: Integer): Integer; override;
  end;

{ TGridFS }

constructor TGridFS.Create(ADB: TMongoDB);
begin
  Create(ADB, GRIDFS_BUCKET_NAME);
end;

constructor TGridFS.Create(ADB: TMongoDB; ABucketName: String);
begin
  FDB := ADB;
  FBucketName := ABucketName;

  FFilesCollection := FDB.GetCollection(FBucketName + '.files');
  FChunksCollection := FDB.GetCollection(FBucketName + '.chunks');
end;

function TGridFS.CreateFile(AFileName: String): TGridFSFileWriter;
begin
  Result := TGridFSFileWriter.Create(Self, AFileName);
end;

function TGridFS.findOne(const AFileName: String): IGridFSFile;
begin
  Result := findOne(TBSONObject.NewFrom(GRIDFS_FIELD_FILE_NAME, AFileName) as IBSONObject);
end;

function TGridFS.findOne(const AQuery: IBSONObject): IGridFSFile;
begin
  Result := VerifyResult(FFilesCollection.FindOne(AQuery));
end;

function TGridFS.VerifyResult(const ABSONObject: IBSONObject): IGridFSFile;
begin
  Result := TGridFSFile.Create;
  Result.PutAll(ABSONObject);
  Result.SetGridFS(Self);

  (*
  if not Supports(ABSONObject, IGridFsFile, Result) then
  begin
    raise EBSONTypesException.CreateRes(@sNotAGridFSObject);
  end;
  *)
end;

{ TGridFSFileWriter }

constructor TGridFSFileWriter.Create(AGridFS: TGridFS; AFileName: String);
begin
  FGridFS := AGridFS;
  FFileName := AFileName;
  FChunkSize := GRIDFS_CHUNK_SIZE;
end;

function TGridFSFileWriter.SetChunkSize(AChunkSize: Integer): TGridFSFileWriter;
begin
  FChunkSize := AChunkSize;

  Result := Self;
end;

function TGridFSFileWriter.SetContentType(AContentType: String): TGridFSFileWriter;
begin
  FContentType := AContentType;

  Result := Self;
end;

procedure TGridFSFileWriter.Store(AStream: TStream);
var
  vFile: IBSONObject;
  vFileId: IBSONObjectId;
  vChunkNumber: Integer;
  vData: IBSONBinary;
begin
  vFile := TBSONObject.NewFrom('length', AStream.Size)
                      .Put('chunkSize', FChunkSize)
                      .Put('uploadDate', Now)
                      //.Put('md5', vHashMD5)
                      .Put('filename', FFileName)
                      .Put('contentType', FContentType);

  if not vFile.HasOid then
  begin
    vFile.Put('_id', TBSONObjectId.NewFrom);
  end;

  FGridFS.FFilesCollection.Insert(vFile);

  vFileId := vFile.GetOid;

  AStream.Position := 0;

  vChunkNumber := 0;

  while (AStream.Position < AStream.Size) do
  begin
    vData := TBSONBinary.Create();
    vData.CopyFrom(AStream, Min(AStream.Size - AStream.Position, FChunkSize));

    FGridFS.FChunksCollection.Insert(TBSONObject.NewFrom('files_id', vFileId)
                                                .Put('n', vChunkNumber)
                                                .Put('data', vData));

    Inc(vChunkNumber);
  end;
end;

{ TGridFSFile }

procedure TGridFSFile.AfterConstruction;
begin
  inherited;
  FExtraData := TBSONObject.EMPTY;
end;

function TGridFSFile.GetChunkData(const AChunkNum: Integer): IBSONBinary;
var
  vChunk: IBSONObject;
begin
  vChunk := FGridFS.FChunksCollection.FindOne(TBSONObject.NewFrom('files_id', FId).Put('n', AChunkNum));

//        if ( chunk == null )
//            throw new MongoException( "can't find a chunk!  file id: " + _id + " chunk: " + i );
  Result := vChunk.Items['data'].AsBSONBinary;
  Result.Stream.Position := 0;
end;

function TGridFSFile.GetChunkSize: Integer;
begin
  Result := FChunkSize;
end;

function TGridFSFile.GetContentType: String;
begin
  Result := FContentType;
end;

function TGridFSFile.GetFileName: String;
begin
  Result := FFileName;
end;

function TGridFSFile.GetId: IBSONObjectId;
begin
  Result := FId;
end;

function TGridFSFile.GetInputStream: TStream;
begin
  Result := TGridFsFileStreamReader.Create(Self);
end;

function TGridFSFile.GetLength: Integer;
begin
  Result := FLength;
end;

function TGridFSFile.GetMD5: String;
begin
  Result := FMD5;
end;

function TGridFSFile.GetUploadDate: TDateTime;
begin
  Result := FUploadDate;
end;

function TGridFSFile.numChunks: Integer;
begin
  Result := Ceil(FLength / FChunkSize);
end;

procedure TGridFSFile.PushItem(AIndex: Integer; AItem: TBSONItem);
begin
  if AItem.Name = '_id' then
    FId := TBSONObjectId.NewFromOID(AItem.AsObjectId.OID)
  else if AItem.Name = 'filename' then
    FFileName := AItem.AsString
  else if AItem.Name = 'contentType' then
    FContentType := AItem.AsString
  else if AItem.Name = 'length' then
    FLength := AItem.AsInteger
  else if AItem.Name = 'chunkSize' then
    FChunkSize := AItem.AsInteger
  else if AItem.Name = 'uploadDate' then
    FUploadDate := AItem.AsDateTime
  else if AItem.Name = 'md5' then
    FMD5 := AItem.AsString
  else
    FExtraData.Put(AItem.Name, AItem.Value);

  AItem.Free;
end;


procedure TGridFSFile.SetGridFS(AGridFS: TGridFS);
begin
  FGridFS := AGridFS;
end;

{ TGridFsFileStreamReader }

function TGridFsFileStreamReader.Avaliable: Integer;
begin
  Result := 0;

  if Assigned(FCurrentChunkData) then
  begin
    Result := FCurrentChunkData.Stream.Size - FCurrentChunkData.Stream.Position;
  end;
end;

constructor TGridFsFileStreamReader.Create(AGridFsFile: TGridFSFile);
begin
  FGridFsFile := AGridFsFile;

  FNumChunks := FGridFsFile.numChunks;
  FCurrentChunk := -1;
end;

function TGridFsFileStreamReader.InternalRead(Count: Integer): Integer;
var
  vBytesToRead: Integer;
begin
  if (FCurrentChunkData = nil) or (Avaliable <= 0) then
  begin
    if (FCurrentChunk + 1) >= FNumChunks then
    begin
      Result := -1;
      Exit;
    end
    else
    begin
      Inc(FCurrentChunk);
      FCurrentChunkData := FGridFsFile.GetChunkData(FCurrentChunk);
    end;
  end;

  vBytesToRead := Min(Count, Avaliable);

  Result := Self.CopyFrom(FCurrentChunkData.Stream, vBytesToRead);

  if (Result < Count) then
  begin
    Result := Result + InternalRead(Count - Result);
  end;
end;

function TGridFsFileStreamReader.Read(var Buffer; Count: Integer): Integer;
begin
  InternalRead(Count);

  Self.Position := 0;

  Result := inherited Read(Buffer, Count);
end;

end.
