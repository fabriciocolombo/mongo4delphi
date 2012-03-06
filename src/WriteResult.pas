unit WriteResult;

interface

uses CommandResult;

type
  IWriteResult = interface
    ['{0D69DCD2-60CA-4EA6-9318-6B1EAC69ABE2}']

    function getCachedLastError(): ICommandResult;
    function getLastError(): ICommandResult;
  end;

implementation

end.
