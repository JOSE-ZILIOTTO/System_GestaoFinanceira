unit uServer;

interface

procedure StartServer;

implementation

uses
  System.SysUtils, System.Classes, System.IniFiles, Horse,
  Horse.CORS,FireDAC.Stan.Factory,
  uDB, uAccountRepo, uCategoryRepo, uLancamentoRepo,
  uAccountsController, uCategoriesController, uLancamentosController, uHealthController;

function ReadIniString(const Section, Key, DefaultValue: string): string;
var
  Ini: TIniFile;
  IniFileName: string;
begin
  IniFileName := ChangeFileExt(ParamStr(0), '.ini');
  Ini := TIniFile.Create(IniFileName);
  try
    Result := Ini.ReadString(Section, Key, DefaultValue);
  finally
    Ini.Free;
  end;
end;

procedure StartServer;
var
  PortStr: string;
  Port: Word;
  AccountRepo: IAccountRepo;
  CategoryRepo: ICategoryRepo;
  LancamentoRepo: ILancamentoRepo;
begin
  // Initialise database connection
  TDBConnectionManager.Init;

  // Create repository instances
  AccountRepo := TAccountRepo.Create(TDBConnectionManager.Connection);
  CategoryRepo := TCategoryRepo.Create(TDBConnectionManager.Connection);
  LancamentoRepo := TLancamentoRepo.Create(TDBConnectionManager.Connection);

  // Register routes
  RegisterHealthRoutes;
  RegisterAccountRoutes(AccountRepo);
  RegisterCategoryRoutes(CategoryRepo);
  RegisterLancamentoRoutes(LancamentoRepo);

  // Enable CORS (allow all origins)
  THorse.Use(CORS);

  // Read server port from config
  PortStr := ReadIniString('server', 'port', '9000');
  Port := StrToIntDef(PortStr, 9000);

  // Start listening
  Writeln(Format('Starting server on port %d...', [Port]));
  THorse.Listen(Port);
end;
end.
