unit uFind;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BSONTypes, ComCtrls, StdCtrls, QueryBuilder;

type
  TFrm_Find = class(TForm)
    Label1: TLabel;
    edCodeStart: TEdit;
    Label2: TLabel;
    edName: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    edId: TEdit;
    btnFind: TButton;
    btnClose: TButton;
    edDate: TEdit;
    Label5: TLabel;
    edCodeEnd: TEdit;
    procedure btnFindClick(Sender: TObject);
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
var
  vQueryBuilder: TQueryBuilder;
  vCodeStart,
  vCodeEnd: Integer;
begin
  vQueryBuilder := TQueryBuilder.empty;

  if (Trim(edId.Text) <> EmptyStr) then
    vQueryBuilder.andField('_id').equals(TBSONObjectId.NewFromOID(edId.Text));

  vCodeStart := StrToIntDef(edCodeStart.Text, 0);
  vCodeEnd := StrToIntDef(edCodeEnd.Text, 0);

  if (vCodeStart > 0) and (vCodeEnd > 0) then
  begin
    vQueryBuilder.andField('code').between(vCodeStart, vCodeEnd);
  end
  else
  begin
    if (vCodeStart > 0) then
      vQueryBuilder.andField('code').greaterThanEquals(vCodeStart);

    if (vCodeEnd > 0) then
      vQueryBuilder.andField('code').lessThanEquals(vCodeEnd);
  end;

  if (Trim(edName.Text) <> EmptyStr) then
    vQueryBuilder.andField('name').equals(edName.Text);

  if (StrToDateDef(edDate.Text, 0) > 0) then
    vQueryBuilder.andField('date').equals(StrToDate(edDate.Text));            

  Result := vQueryBuilder.buildAndFree;
end;

procedure TFrm_Find.btnFindClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

end.
