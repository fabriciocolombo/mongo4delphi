program Demo;

uses
  Forms,
  uMainForm in 'uMainForm.pas' {Frm_MainForm},
  uItem in 'uItem.pas' {Frm_Item},
  uFind in 'uFind.pas' {Frm_Find};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrm_MainForm, Frm_MainForm);
  Application.Run;
end.
