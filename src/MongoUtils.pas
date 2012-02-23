unit MongoUtils;

interface

uses Classes;

type
  TListUtils = class
  private
  public
    class procedure FreeObjects(AList: TStringList);
  end;

implementation

uses SysUtils;

{ TListUtils }

class procedure TListUtils.FreeObjects(AList: TStringList);
var
  vObject: TObject;
  i: Integer;
begin
  for i := AList.Count-1 downto 0 do
  begin
    vObject := AList.Objects[i];

    FreeAndNil(vObject);
  end;
  AList.Clear;
end;

end.
