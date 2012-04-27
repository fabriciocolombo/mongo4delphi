unit TestJsonWriter;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCase, BSONTypes;

type
  { TTestBSONItem }
  TTestJsonWriter = class(TBaseTestCase)
  private
  published
    procedure WriteEmptyJson;
    procedure WriteJsonNull;
    procedure WriteJsonString;
    procedure WriteJsonInteger;
    procedure WriteJsonInt64;
    procedure WriteJsonFloat;
    procedure WriteJsonDate;
    procedure WriteJsonBoolean;
    procedure WriteJsonArray;
    procedure WriteJsonNestedObject;
    procedure WriteJsonNestedArray;
    procedure WriteJsonComplex;
    procedure WriteJsonBeautiful;
  end;

implementation

uses TestFramework, SysUtils, Variants;

{ TTestJsonWriter }

procedure TTestJsonWriter.WriteEmptyJson;
begin
  CheckEqualsString('{}', TBSONObject.EMPTY.AsJson);
end;

procedure TTestJsonWriter.WriteJsonArray;
begin
  CheckEqualsString('[1,2,3]', TBSONArray.NewFromValues([1,2,3]).AsJson);
end;

procedure TTestJsonWriter.WriteJsonBeautiful;
begin
  CheckEqualsString('['+ sLineBreak +
                    '    {' + sLineBreak +
                    '        "key": {' + sLineBreak +
                    '            "key2": "value"' + sLineBreak +
                    '        }' + sLineBreak +
                    '    },' + sLineBreak +
                    '    {' + sLineBreak +
                    '        "key2": [' + sLineBreak +
                    '            1,' + sLineBreak +
                    '            2,' + sLineBreak +
                    '            3' + sLineBreak +
                    '        ]' + sLineBreak +
                    '    }' + sLineBreak +
                    ']',
                     TBSONArray.NewFromValues([TBSONObject.NewFrom('key', TBSONObject.NewFrom('key2', 'value')),
                                               TBSONObject.NewFrom('key2', TBSONArray.NewFromValues([1,2,3]))])
                               .AsJsonReadable);
end;

procedure TTestJsonWriter.WriteJsonBoolean;
begin
  CheckEqualsString('{"key" : false}', TBSONObject.NewFrom('key', False).AsJson);
  CheckEqualsString('{"key" : true}', TBSONObject.NewFrom('key', True).AsJson);
end;

procedure TTestJsonWriter.WriteJsonComplex;
begin
  CheckEqualsString('[{"key" : {"key2" : "value"}},{"key2" : [1,2,3]}]',
                     TBSONArray.NewFromValues([TBSONObject.NewFrom('key', TBSONObject.NewFrom('key2', 'value')),
                                               TBSONObject.NewFrom('key2', TBSONArray.NewFromValues([1,2,3]))])
                               .AsJson);
end;

procedure TTestJsonWriter.WriteJsonDate;
var
  vDate: TDateTime;
  vDateString: String;
begin
  vDate := Date;
  vDateString := DateToStr(vDate);

  CheckEqualsString(Format('{"key" : %s}', [vDateString]), TBSONObject.NewFrom('key', vDate).AsJson);
end;

procedure TTestJsonWriter.WriteJsonFloat;
begin
  CheckEqualsString('{"key" : 123.45}', TBSONObject.NewFrom('key', 123.45).AsJson);
end;

procedure TTestJsonWriter.WriteJsonInt64;
begin
  CheckEqualsString('{"key" : ' + IntToStr(High(Int64)) + '}', TBSONObject.NewFrom('key', High(Int64)).AsJson);
end;

procedure TTestJsonWriter.WriteJsonInteger;
begin
  CheckEqualsString('{"key" : 123}', TBSONObject.NewFrom('key', 123).AsJson);
end;

procedure TTestJsonWriter.WriteJsonNestedArray;
begin
  CheckEqualsString('{"key" : [1,2,3]}', TBSONObject.NewFrom('key', TBSONArray.NewFromValues([1,2,3])).AsJson);
end;

procedure TTestJsonWriter.WriteJsonNestedObject;
begin
  CheckEqualsString('{"key" : {"key2" : "value"}}', TBSONObject.NewFrom('key', TBSONObject.NewFrom('key2', 'value')).AsJson);
end;

procedure TTestJsonWriter.WriteJsonNull;
begin
  CheckEqualsString('{"key" : null}', TBSONObject.NewFrom('key', Null).AsJson);
end;

procedure TTestJsonWriter.WriteJsonString;
begin
  CheckEqualsString('{"key" : "value"}', TBSONObject.NewFrom('key', 'value').AsJson);
end;

initialization
  TTestJsonWriter.RegisterTest;

end.
