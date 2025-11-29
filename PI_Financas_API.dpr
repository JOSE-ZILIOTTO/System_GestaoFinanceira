program PI_Financas_API;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  uConfig in 'src\uConfig.pas',
  uDB in 'src\uDB.pas',
  uAccountRepo in 'src\uAccountRepo.pas',
  uCategoryRepo in 'src\uCategoryRepo.pas',
  uHealthController in 'src\uHealthController.pas',
  uAccountsController in 'src\uAccountsController.pas',
  uCategoriesController in 'src\uCategoriesController.pas',
  uServer in 'src\uServer.pas',
  uLancamentoRepo in 'src\uLancamentoRepo.pas',
  uLancamentosController in 'src\uLancamentosController.pas';

begin
  try
    StartServer;
  except
    on E: Exception do
    begin
      Writeln('Erro ao iniciar o servidor: ' + E.Message);
      Halt(1);
    end;
  end;
end.
