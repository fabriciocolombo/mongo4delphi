unit uItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Mask, StdCtrls, ExtCtrls, ExtDlgs, BSONTypes, ComCtrls;

type
  TFrm_Item = class(TForm)
    Label1: TLabel;
    edCode: TEdit;
    edName: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Image1: TImage;
    btnOK: TButton;
    btnCancel: TButton;
    btnLoad: TButton;
    OpenPictureDialog1: TOpenPictureDialog;
    DateTimePicker: TDateTimePicker;
    procedure btnLoadClick(Sender: TObject);
  private
  public
    function GetContentAsBSON: IBSONObject;
    procedure SetContent(ABSONObject: IBSONObject);
  end;

var
  Frm_Item: TFrm_Item;

implementation

{$R *.dfm}

procedure TFrm_Item.btnLoadClick(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
  begin
    Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
  end;
end;

function TFrm_Item.GetContentAsBSON: IBSONObject;
var
  vBinary: IBSONBinary;
begin
  Result := TBSONObject.Create;
  Result.Put('code', StrToInt(edCode.Text));
  Result.Put('name', edName.Text);
  Result.Put('date', TDateTime(DateTimePicker.DateTime));

  vBinary := TBSONBinary.Create();
  Image1.Picture.Bitmap.SaveToStream(vBinary.Stream);
  Result.Put('image', vBinary);
end;

procedure TFrm_Item.SetContent(ABSONObject: IBSONObject);
begin
  edCode.Text := IntToStr(ABSONObject.Items['code'].AsInteger);
  edName.Text := ABSONObject.Items['name'].AsString;
  DateTimePicker.Date := ABSONObject.Items['date'].AsDateTime;
  ABSONObject.Items['image'].AsBSONBinary.Stream.Position := 0;
  Image1.Picture.Bitmap.LoadFromStream(ABSONObject.Items['image'].AsBSONBinary.Stream);
end;

end.
