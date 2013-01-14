unit TestGridFS;

interface

uses BaseTestCaseMongo, GridFS, Classes;

type
  TTestGridFS = class(TBaseTestCaseMongo)
  published
    procedure StoreString;
  end;

implementation

{ TTestGridFS }

procedure TTestGridFS.StoreString;
var
  vGridFS: TGridFS;
  vGridFSWriter: TGridFSFileWriter;
  vStream: TStringStream;
begin
  vGridFS := TGridFS.Create(DB);
  vStream := TStringStream.Create('');
  try
    vGridFSWriter := vGridFS.CreateFile('teste.txt');
    try
      vStream.WriteString('teste linha um');
      vStream.WriteString(sLineBreak);
      vStream.WriteString('teste linha dois');

      vGridFSWriter.SetContentType('text/plain')
                   .Store(vStream);
    finally
      vGridFSWriter.Free;
    end;
  finally
    vStream.Free;
    vGridFS.Free;
  end;
end;

initialization
  TTestGridFS.RegisterTest;

end.
