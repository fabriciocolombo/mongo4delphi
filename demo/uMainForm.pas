unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Mongo, MongoDB, MongoCollection, BSONTypes,
  MongoDBCursorIntf;

type
  TFrm_MainForm = class(TForm)
    ListView1: TListView;
    Image1: TImage;
    btnAdd: TButton;
    btnUpdate: TButton;
    btnRemove: TButton;
    btnClear: TButton;
    btnFind: TButton;
    procedure btnAddClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnFindClick(Sender: TObject);
  private
    FMongo: TMongo;
    FDB: TMongoDB;
    FCollection: TMongoCollection;
    FRefList: IInterfaceList;

    function Current: IBSONObject;

    procedure LoadFromDB;
    procedure LoadItems(const ACursor: IMongoDBCursor);
    procedure UpdateListView(AItem: TListItem;const ABSONObject: IBSONObject);
    procedure UpdateImage(ABSONObject: IBSONObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Frm_MainForm: TFrm_MainForm;

implementation

uses uItem, uFind;

{$R *.dfm}

procedure TFrm_MainForm.btnAddClick(Sender: TObject);
var
  vBSON: IBSONObject;
begin
  Frm_Item := TFrm_Item.Create(nil);
  try
    if (Frm_Item.ShowModal = mrOk) then
    begin
      vBSON := Frm_Item.GetContentAsBSON;
      vBSON.Put('_id', TBSONObjectId.NewFrom);

      FCollection.Insert(vBSON);

      UpdateListView(ListView1.Items.Add, vBSON);
    end;
  finally
    Frm_Item.Free;
  end;
end;

constructor TFrm_MainForm.Create(AOwner: TComponent);
begin
  inherited;
  FRefList := TInterfaceList.Create;

  FMongo := TMongo.Create;
  FMongo.Connect();

  FDB := FMongo.getDB('demo');

  FCollection := FDB.GetCollection('app');

  LoadFromDB;
end;

destructor TFrm_MainForm.Destroy;
begin
  FMongo.Free;
  inherited;
end;

procedure TFrm_MainForm.UpdateListView(AItem: TListItem;const ABSONObject: IBSONObject);
begin
  AItem.Caption := ABSONObject.GetOID.OID;
  AItem.SubItems.Clear;
  AItem.SubItems.Add(IntToStr(ABSONObject.Items['code'].AsInteger));
  AItem.SubItems.Add(ABSONObject.Items['name'].AsString);
  AItem.SubItems.Add(DateToStr(ABSONObject.Items['date'].AsDateTime));
  AItem.Data := Pointer(ABSONObject);

  UpdateImage(ABSONObject);

  if FRefList.IndexOf(ABSONObject) = -1 then
  begin
    FRefList.Add(ABSONObject);
  end;
end;

procedure TFrm_MainForm.btnUpdateClick(Sender: TObject);
var
  vBSON: IBSONObject;
begin
  if Assigned(ListView1.Selected) then
  begin
    Frm_Item := TFrm_Item.Create(nil);
    try
      Frm_Item.SetContent(Current);
      
      if (Frm_Item.ShowModal = mrOk) then
      begin
        vBSON := Frm_Item.GetContentAsBSON;
        vBSON.Put('_id', Current.GetOid);

        FCollection.Update(Current, vBSON);

        UpdateListView(ListView1.Selected, vBSON);
      end;
    finally
      Frm_Item.Free;
    end;
  end else
    MessageBox(Handle, PAnsiChar('No record selected.'), PAnsiChar('Error'), MB_OK or MB_ICONERROR);
end;

function TFrm_MainForm.Current: IBSONObject;
begin
  if Assigned(ListView1.Selected) then
    Result := IBSONObject(ListView1.Selected.Data)
  else
    Result := nil;
end;

procedure TFrm_MainForm.LoadFromDB;
var
  vCursor: IMongoDBCursor;
begin
  vCursor := FCollection.Find;

  ListView1.Items.Clear;
  ListView1.Items.BeginUpdate;
  try
    LoadItems(vCursor);
  finally
    ListView1.Items.EndUpdate;
  end;
end;

procedure TFrm_MainForm.ListView1Click(Sender: TObject);
begin
  UpdateImage(Current);
end;

procedure TFrm_MainForm.UpdateImage(ABSONObject: IBSONObject);
begin
  if (ABSONObject <> nil) and (ABSONObject.Items['image'].AsBSONBinary.Stream.Size > 0) then
  begin
    ABSONObject.Items['image'].AsBSONBinary.Stream.Position := 0;
    Image1.Picture.Bitmap.LoadFromStream(ABSONObject.Items['image'].AsBSONBinary.Stream);
  end;
end;

procedure TFrm_MainForm.btnClearClick(Sender: TObject);
begin
  FCollection.Drop;
  ListView1.Items.Clear;
end;

procedure TFrm_MainForm.btnRemoveClick(Sender: TObject);
begin
  if Current <> nil then
  begin
    FCollection.Remove(Current);
    ListView1.Items.Delete(ListView1.Selected.Index);
  end;
end;

procedure TFrm_MainForm.btnFindClick(Sender: TObject);
var
  vQuery: IBSONObject;
begin
  Frm_Find := TFrm_Find.Create(nil);
  try
    if (Frm_Find.ShowModal = mrOk) then
    begin
      vQuery := Frm_Find.BuildQuery;
      
      LoadItems(FCollection.Find(vQuery));
    end;
  finally
    FreeAndNil(Frm_Find);
  end;
end;

procedure TFrm_MainForm.LoadItems(const ACursor: IMongoDBCursor);
begin
  while ACursor.HasNext do
  begin
    UpdateListView(ListView1.Items.Add, ACursor.Next);
  end;
end;

end.
