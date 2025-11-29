unit uConfig;

interface

type
  TAppConfig = record
    ServerPort: Integer;
    DatabasePath: string;
    class function Load: TAppConfig; static;
  end;

implementation

uses
  System.SysUtils, System.IniFiles;

{ TAppConfig }

class function TAppConfig.Load: TAppConfig;
var
  Ini: TIniFile;
  AppDir, IniPath: string;
begin
  AppDir := ExtractFilePath(ParamStr(0));
  IniPath := AppDir + 'config.ini';

  if not FileExists(IniPath) then
    raise Exception.Create('Arquivo de configuração não encontrado: ' + IniPath);

  Ini := TIniFile.Create(IniPath);
  try
    Result.ServerPort := Ini.ReadInteger('server', 'port', 9000);
    Result.DatabasePath := Ini.ReadString('database', 'path', AppDir + 'bd\financeiro.db');
  finally
    Ini.Free;
  end;
end;

end.
