unit TestServerError;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCase, ServerError, BSONTypes;

type
  TTestServerError = class(TBaseTestCase)
  private
  published
    procedure ShouldReturnEmptyMessage;
    procedure ShouldReturnMessageForErr;
    procedure ShouldReturnMessageForErrSpecial;
    procedure ShouldReturnMessageForErrmsg;
    procedure ShouldReturnEmptyCode;
    procedure ShouldReturnCodeForCode;
    procedure ShouldReturnCodeForCodeSpecial;
    procedure ShouldReturnCodeForAssertionCode;
    procedure ShouldBeNotMasterError;
  end;

implementation

uses SysUtils;

const
  sTestErrorMessage = 'Test message - ';
  sTestErrorCode = 9;

{ TTestServerError }

procedure TTestServerError.ShouldBeNotMasterError;
begin
  Check(TServerError.IsNotMasterError(10054, EmptyStr));
  Check(TServerError.IsNotMasterError(10056, EmptyStr));
  Check(TServerError.IsNotMasterError(10058, EmptyStr));
  Check(TServerError.IsNotMasterError(10107, EmptyStr));
  Check(TServerError.IsNotMasterError(13435, EmptyStr));
  Check(TServerError.IsNotMasterError(13436, EmptyStr));
  Check(TServerError.IsNotMasterError(0, 'not master error'));
end;

procedure TTestServerError.ShouldReturnCodeForAssertionCode;
begin
  CheckEquals(sTestErrorCode, TServerError.GetErrorCode(TBSONObject.NewFrom('assertionCode', sTestErrorCode)));
end;

procedure TTestServerError.ShouldReturnCodeForCode;
begin
  CheckEquals(sTestErrorCode, TServerError.GetErrorCode(TBSONObject.NewFrom('code', sTestErrorCode)));
end;

procedure TTestServerError.ShouldReturnCodeForCodeSpecial;
begin
  CheckEquals(sTestErrorCode, TServerError.GetErrorCode(TBSONObject.NewFrom('$code', sTestErrorCode)));
end;

procedure TTestServerError.ShouldReturnEmptyCode;
begin
  CheckEquals(-1, TServerError.GetErrorCode(TBSONObject.Empty));
end;

procedure TTestServerError.ShouldReturnEmptyMessage;
begin
  CheckEquals(EmptyStr, TServerError.GetErrorMessage(TBSONObject.Empty));
end;

procedure TTestServerError.ShouldReturnMessageForErr;
begin
  CheckEquals(sTestErrorMessage + 'err', TServerError.GetErrorMessage(TBSONObject.NewFrom('err', sTestErrorMessage + 'err')));
end;

procedure TTestServerError.ShouldReturnMessageForErrmsg;
begin
  CheckEquals(sTestErrorMessage + 'errmsg', TServerError.GetErrorMessage(TBSONObject.NewFrom('errmsg', sTestErrorMessage + 'errmsg')));
end;

procedure TTestServerError.ShouldReturnMessageForErrSpecial;
begin
  CheckEquals(sTestErrorMessage + '$err', TServerError.GetErrorMessage(TBSONObject.NewFrom('$err', sTestErrorMessage + '$err')));
end;

initialization
  TTestServerError.RegisterTest;

end.
