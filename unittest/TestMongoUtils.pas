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
unit TestMongoUtils;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCase, MongoUtils;

type
  TTestGuidUtils = class(TBaseTestCase)
  published
    procedure TestStringToGuid;
    procedure TestInvalidGuid;
  end;

implementation

uses TestFramework, SysUtils;

{ TTestGuidUtils }

procedure TTestGuidUtils.TestInvalidGuid;
var
  guid: TGUID;
begin
  CheckFalse(TGUIDUtils.TryStringToGuid('aaa', guid));
  CheckFalse(TGUIDUtils.TryStringToGuid('{"name" : "teste"}', guid));  
end;

procedure TTestGuidUtils.TestStringToGuid;
const
  Expected = '{9C45A389-715A-4D17-A3C6-135EB4EDE939}';
var
  guid: TGUID;
begin
  CheckTrue(TGUIDUtils.TryStringToGuid(Expected, guid));
  CheckEqualsString(Expected, GUIDToString(guid));
end;

initialization
  TTestGuidUtils.RegisterTest;

end.
