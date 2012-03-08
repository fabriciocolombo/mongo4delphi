object Frm_Item: TFrm_Item
  Left = 559
  Top = 325
  Width = 423
  Height = 395
  Caption = 'Frm_Item'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 26
    Top = 15
    Width = 25
    Height = 13
    Alignment = taRightJustify
    Caption = 'Code'
  end
  object Label2: TLabel
    Left = 23
    Top = 47
    Width = 28
    Height = 13
    Alignment = taRightJustify
    Caption = 'Name'
  end
  object Label3: TLabel
    Left = 28
    Top = 79
    Width = 23
    Height = 13
    Alignment = taRightJustify
    Caption = 'Date'
  end
  object Label4: TLabel
    Left = 22
    Top = 103
    Width = 29
    Height = 13
    Alignment = taRightJustify
    Caption = 'Image'
  end
  object Image1: TImage
    Left = 56
    Top = 104
    Width = 177
    Height = 209
    ParentShowHint = False
    Proportional = True
    ShowHint = True
  end
  object edCode: TEdit
    Left = 56
    Top = 8
    Width = 121
    Height = 21
    TabOrder = 0
  end
  object edName: TEdit
    Left = 56
    Top = 40
    Width = 337
    Height = 21
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 56
    Top = 328
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 160
    Top = 328
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnLoad: TButton
    Left = 237
    Top = 288
    Width = 35
    Height = 25
    Caption = 'Load'
    TabOrder = 4
    OnClick = btnLoadClick
  end
  object DateTimePicker: TDateTimePicker
    Left = 56
    Top = 72
    Width = 105
    Height = 21
    Date = 40975.964515833340000000
    Time = 40975.964515833340000000
    TabOrder = 5
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Left = 240
    Top = 256
  end
end
