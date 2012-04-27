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
