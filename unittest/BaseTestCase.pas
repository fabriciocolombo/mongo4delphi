unit BaseTestCase;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses {$IFDEF FPC}fpcunit, testregistry;{$ELSE}TestFramework;{$ENDIF}

type
  TBaseTestCase = class(TTestCase)
  public
    class procedure RegisterTest;
  end;

implementation

{ TBaseTestCase }

class procedure TBaseTestCase.RegisterTest;
begin
  {$IFDEF FPC}testregistry.RegisterTest(Self);
  {$ELSE}
    TestFramework.RegisterTest(Self.Suite);
  {$ENDIF}
end;

end.
