unit CommandResult;

interface

uses BSONTypes, SysUtils;

type
  ICommandResult = interface(IBSONObject)
    ['{8F4C1FA8-5CD5-433A-A641-16DA896B42DB}']

    function Ok: Boolean;
    function HasError: Boolean;
    function GetCode: Integer;
    function GetErrorMessage: String;
    function GetException: Exception;
    procedure RaiseOnError;
  end;

implementation

end.
