{***************************************************************************}
{                                                                           }
{                    Mongo Delphi Driver                                    }
{                                                                           }
{           Copyright (c) 2012 Fabricio Colombo                             }
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}
unit MongoUtils;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses Classes;

type
  TListUtils = class
  private
  public
    class procedure FreeObjects(AList: TStringList);
  end;

  TGUIDUtils = class
  private
  public
    class function NewGuid: TGUID;overload;
    class function NewGuidAsString: String;overload;
    class function TryStringToGuid(value: String;var GUID: TGUID): Boolean;
  end;

implementation

uses SysUtils, StrUtils, ComObj;

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

{ TGUIDUtils }



class function TGUIDUtils.NewGUID: TGUID;
begin
  OleCheck(CreateGUID(Result));
end;

class function TGUIDUtils.NewGuidAsString: String;
begin
  Result := GuidToString(NewGuid);
end;

class function TGUIDUtils.TryStringToGuid(value: String;var GUID: TGUID): Boolean;
begin
  Result := (LeftStr(value, 1) = '{') and (RightStr(value, 1) = '}');

  if Result then
  begin
    try
      GUID := StringToGuid(value);

      Result := True;
    except
      on E: EConvertError do
        Result := False
      else
        raise;
    end;
  end
end;

end.
