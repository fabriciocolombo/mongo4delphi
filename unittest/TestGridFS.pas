unit TestGridFS;

interface

uses BaseTestCaseMongo, GridFS, Classes;

type
  TTestGridFS = class(TBaseTestCaseMongo)
  private
    procedure CheckEqualsStream(AExpected, AActual: TStream);
  published
    procedure StoreString;
    procedure StoreGifFile;
  end;

implementation

uses TestFramework, BSONTypes, DateUtils, SysUtils, Math, MongoUtils;

const
  STRING_CONTENT = 'test line one' + sLineBreak + 'test line two';
  STRING_CONTENT_TYPE = 'text/plain';

{ TTestGridFS }

procedure TTestGridFS.CheckEqualsStream(AExpected, AActual: TStream);
var
  vExpected, vActual: TMemoryStream;
begin
  vExpected := TMemoryStream.Create;
  vActual := TMemoryStream.Create;
  try
    vExpected.LoadFromStream(AExpected);
    vActual.LoadFromStream(AActual);

    CheckEqualsMem(vExpected.Memory, vActual.Memory, vExpected.Size);
  finally
    vExpected.Free;
    vActual.Free;
  end;
end;

procedure TTestGridFS.StoreGifFile;
const
  CHUNK_SIZE = GRIDFS_CHUNK_SIZE;
var
  vGridFS: TGridFS;
  vGridFSWriter: TGridFSFileWriter;
  vReadStream: TStream;
  vINStream,
  vOUTStream: TFileStream;
  vGridFsFile: IGridFSFile;
  vExpectedSize: Integer;
  vLength: Int64;
begin
  vGridFS := TGridFS.Create(DB);
  vINStream := TFileStream.Create('resource\in.jpg', fmOpenRead);
  vOUTStream := TFileStream.Create('resource\out.jpg', fmOpenReadWrite or fmCreate);
  try
    vExpectedSize := vINStream.Size;
    vGridFSWriter := vGridFS.CreateFile('image.jpg');
    try
      vGridFSWriter.SetContentType('image/jpg')
                   .SetChunkSize(CHUNK_SIZE)
                   .Store(vINStream);
    finally
      vGridFSWriter.Free;
    end;

    vGridFsFile := vGridFS.findOne('image.jpg');

    CheckNotNull(vGridFsFile);
    CheckEquals('image.jpg', vGridFsFile.GetFileName);
    CheckEquals('image/jpg', vGridFsFile.GetContentType);
    CheckEquals(vExpectedSize, vGridFsFile.GetLength);
    CheckEquals(CHUNK_SIZE, vGridFsFile.GetChunkSize);
    CheckEquals(Date, DateOf(vGridFsFile.GetUploadDate));
    CheckEquals(Ceil(vExpectedSize/CHUNK_SIZE), vGridFsFile.numChunks);

    vReadStream := vGridFsFile.GetInputStream;
    try
      vReadStream.Position := 0;

      vLength:= vGridFsFile.GetLength;

      vOUTStream.CopyFrom(vReadStream, vLength);

      CheckEquals(vExpectedSize, vOUTStream.Size);
      CheckEqualsStream(vINStream, vOUTStream);
    finally
      vReadStream.Free;
    end;

  finally
    vINStream.Free;
    vOUTStream.Free;
    vGridFS.Free;
  end;
end;

procedure TTestGridFS.StoreString;
const
  CHUNK_SIZE = 10;
var
  vGridFS: TGridFS;
  vGridFSWriter: TGridFSFileWriter;
  vReadStream: TStream;
  vStream: TStringStream;
  vGridFsFile: IGridFSFile;
begin
  vGridFS := TGridFS.Create(DB);
  vStream := TStringStream.Create('');
  try
    vGridFSWriter := vGridFS.CreateFile('teste.txt');
    try
      vStream.WriteString(STRING_CONTENT);

      vGridFSWriter.SetContentType(STRING_CONTENT_TYPE)
                   .SetChunkSize(CHUNK_SIZE)
                   .Store(vStream);
    finally
      vGridFSWriter.Free;
    end;

    vGridFsFile := vGridFS.findOne('teste.txt');

    CheckNotNull(vGridFsFile);
    CheckEquals('teste.txt', vGridFsFile.GetFileName);
    CheckEquals(STRING_CONTENT_TYPE, vGridFsFile.GetContentType);
    CheckEquals(Length(STRING_CONTENT), vGridFsFile.GetLength);
    CheckEquals(CHUNK_SIZE, vGridFsFile.GetChunkSize);
    CheckEquals(Date, DateOf(vGridFsFile.GetUploadDate));
    CheckEquals(3, vGridFsFile.numChunks);

    vReadStream := vGridFsFile.GetInputStream;
    try
      vStream.Size := 0;

      CheckEquals(EmptyStr, vStream.DataString);
      
      vStream.CopyFrom(vReadStream, vGridFsFile.GetLength);

      CheckEquals(STRING_CONTENT, vStream.DataString);
    finally
      vReadStream.Free;
    end;

  finally
    vStream.Free;
    vGridFS.Free;
  end;
end;

initialization
  TTestGridFS.RegisterTest;

end.
