unit TestBSONStream;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCase, BSONStream;

type
  TTestBSONStream = class(TBaseTestCase)
  private
    FStream: TBSONStream;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure WriteSimpleTypes;
    procedure ReadCString;
  end;

implementation

{ TTestBSONStream }

procedure TTestBSONStream.ReadCString;
var
  vInput, vOutput: String;
begin
  vInput := 'ABCDEFÇÃÉÓ';

  FStream.WriteUTF8String(vInput);

  FStream.Position := 0;

  vOutput := FStream.ReadCString;

  CheckEquals(vInput, vOutput);
end;

procedure TTestBSONStream.SetUp;
begin
  inherited;
  FStream := TBSONStream.Create;
end;

procedure TTestBSONStream.TearDown;
begin
  FStream.Free;
  inherited;
end;

procedure TTestBSONStream.WriteSimpleTypes;
begin
  //Write string 'idç' size 5 in UTF8
  //Write int '123' size 4
  //Write string 'a' size 2 in UTF8
  //Write int64 '123' size 8
  //Write string 'b' size 2 in UTF8
  //Write byte 9 size 1
  //Total size 22

  FStream.WriteUTF8String('idç');
  FStream.WriteInt(123);
  FStream.WriteUTF8String('a');
  FStream.WriteInt64(123);
  FStream.WriteUTF8String('b');
  FStream.WriteByte(9);

  CheckEquals(22, FStream.Size);
  CheckEquals(22, FStream.Position);
end;

initialization
  TTestBSONStream.RegisterTest;

end.
