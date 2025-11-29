unit uDB;

interface

uses
  System.SysUtils, System.Classes, System.IniFiles,  FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Phys.SQLiteDef, FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Stan.Intf, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  Data.DB, FireDAC.Comp.Client,FireDAC.DApt;

type
  TDBConnectionManager = class
  private
    class var FConnection: TFDConnection;
  public

    class procedure Init;

    class property Connection: TFDConnection read FConnection;
  end;

implementation


function ReadIniValue(const Section, Key, DefaultValue: string): string;
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

{ TDBConnectionManager }

class procedure TDBConnectionManager.Init;
var
  dbPath: string;
begin
  if Assigned(FConnection) then
    Exit;

  dbPath := ReadIniValue('database', 'path', '');
  if dbPath = '' then
    raise Exception.Create('Database path is not configured in config.ini');

  FConnection := TFDConnection.Create(nil);
  try
    FConnection.DriverName := 'SQLite';
    FConnection.Params.Values['Database'] := dbPath;
    FConnection.Params.Values['LockingMode'] := 'Normal';
    FConnection.Params.Values['SQLiteAdvanced'] := 'Synchronous=Full';
    FConnection.Connected := True;
  except
    FConnection.Free;
    FConnection := nil;
    raise;
  end;
end;

end.
