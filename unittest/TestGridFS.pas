unit TestGridFS;

interface

uses BaseTestCaseMongo, GridFS, Classes;

type
  TTestGridFS = class(TBaseTestCaseMongo)
  published
    procedure StoreString;
  end;

implementation

uses TestFramework, BSONTypes, DateUtils, SysUtils;

const
  STRING_CONTENT = 'test line one' + sLineBreak + 'test line two';
  STRING_CONTENT_TYPE = 'text/plain';
  STRING_CHUNK_SIZE = 10;

{ TTestGridFS }

procedure TTestGridFS.StoreString;
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
                   .SetChunkSize(STRING_CHUNK_SIZE)
                   .Store(vStream);
    finally
      vGridFSWriter.Free;
    end;

    vGridFsFile := vGridFS.findOne('teste.txt');

    CheckNotNull(vGridFsFile);
    CheckEquals('teste.txt', vGridFsFile.GetFileName);
    CheckEquals(STRING_CONTENT_TYPE, vGridFsFile.GetContentType);
    CheckEquals(Length(STRING_CONTENT), vGridFsFile.GetLength);
    CheckEquals(STRING_CHUNK_SIZE, vGridFsFile.GetChunkSize);
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
