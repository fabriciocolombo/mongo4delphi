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
unit MongoException;

interface

uses SysUtils;

type
  EMongoException = class(Exception);
  EIllegalArgumentException = class(EMongoException);
  EMongoConnectionFailureException = class(EMongoException);
  EBSONDuplicateKeyInList = class(EMongoException);
  EBSONCannotChangeDuplicateAction = class(EMongoException);

resourcestring
  sInvalidVariantValueType = 'Can''t serialize type "%s".';
  sMongoConnectionFailureException = 'failed to connect to "%s:%d"';
  sBSONDuplicateKeyInList = 'Key "%s" already exist.';
  sBSONCannotChangeDuplicateAction = 'Cannot change duplicate action after items added ';

implementation

end.
