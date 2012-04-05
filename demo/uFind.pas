unit uFind;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BSONTypes;

type
  TFrm_Find = class(TForm)
  private
  public
    function BuildQuery: IBSONObject;
  end;

var
  Frm_Find: TFrm_Find;

implementation

{$R *.dfm}

{ TFrm_Find }

function TFrm_Find.BuildQuery: IBSONObject;
begin
  Result := TBSONObject.Create;
end;

end.
