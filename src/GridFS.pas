unit GridFS;

interface

uses MongoDB, MongoCollection, BSONTypes, MongoUtils, Classes;

type
  TGridFSFileWriter = class;

  TGridFS = class
  private
    FDB: TMongoDB;
    FChunksCollection: TMongoCollection;
    FFilesCollection: TMongoCollection;
    FBucketName: String;
  public
    constructor Create(ADB: TMongoDB);overload;
    constructor Create(ADB: TMongoDB; ABucketName: String);overload;

    function CreateFile(AFileName: String): TGridFSFileWriter;
  end;

  TGridFSFile = class
  private
  public
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

uses SysUtils, Math;


{ TGridFS }

constructor TGridFS.Create(ADB: TMongoDB);
begin
  Create(ADB, GRIFS_BUCKET_NAME);
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

{ TGridFSFileWriter }

constructor TGridFSFileWriter.Create(AGridFS: TGridFS; AFileName: String);
begin
  FGridFS := AGridFS;
  FFileName := AFileName;
  FChunkSize := GRISFS_CHUNK_SIZE;
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
  vStreamBuffer: TMemoryStream;
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

  vStreamBuffer := TMemoryStream.Create;
  try
    vStreamBuffer.Clear;

    vChunkNumber := 0;

    while (AStream.Position < AStream.Size) do
    begin
      vStreamBuffer.CopyFrom(AStream, Min(AStream.Size, FChunkSize));

      vStreamBuffer.Position := 0;
      vData := TBSONBinary.Create();
      vData.CopyFrom(vStreamBuffer, vStreamBuffer.Size);

      FGridFS.FChunksCollection.Insert(TBSONObject.NewFrom('files_id', vFileId)
                                                  .Put('n', vChunkNumber)
                                                  .Put('data', vData));

      Inc(vChunkNumber);
    end;
  finally
    vStreamBuffer.Free;
  end;
end;

end.
