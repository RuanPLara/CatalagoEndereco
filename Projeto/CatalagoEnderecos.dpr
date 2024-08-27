program CatalagoEnderecos;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {frmMain},
  uModel.Endereco in 'Model\uModel.Endereco.pas',
  uController.Endereco in 'Controller\uController.Endereco.pas',
  uConexao in 'uConexao.pas',
  uInterface.Endereco in 'Interfaces\uInterface.Endereco.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
