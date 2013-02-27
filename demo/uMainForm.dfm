object Frm_MainForm: TFrm_MainForm
  Left = 283
  Top = 267
  Width = 851
  Height = 372
  Caption = 'Demo - Mongo Delphi Driver'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    835
    334)
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 640
    Top = 8
    Width = 187
    Height = 249
    Anchors = [akTop, akRight]
    ParentShowHint = False
    ShowHint = True
  end
  object ListView1: TListView
    Left = 8
    Top = 8
    Width = 625
    Height = 249
    Anchors = [akLeft, akTop, akRight]
    Columns = <
      item
        Caption = 'Id'
        Width = 170
      end
      item
        Caption = 'Code'
      end
      item
        Caption = 'Name'
        Width = 250
      end
      item
        Caption = 'Date'
        Width = 120
      end>
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnClick = ListView1Click
  end
  object btnAdd: TButton
    Left = 8
    Top = 264
    Width = 75
    Height = 25
    Caption = 'Add'
    TabOrder = 1
    OnClick = btnAddClick
  end
  object btnUpdate: TButton
    Left = 96
    Top = 264
    Width = 75
    Height = 25
    Caption = 'Update'
    TabOrder = 2
    OnClick = btnUpdateClick
  end
  object btnRemove: TButton
    Left = 184
    Top = 264
    Width = 75
    Height = 25
    Caption = 'Remove'
    TabOrder = 3
    OnClick = btnRemoveClick
  end
  object btnClear: TButton
    Left = 272
    Top = 264
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 4
    OnClick = btnClearClick
  end
  object btnFind: TButton
    Left = 360
    Top = 264
    Width = 75
    Height = 25
    Caption = 'Find'
    TabOrder = 5
    OnClick = btnFindClick
  end
end
