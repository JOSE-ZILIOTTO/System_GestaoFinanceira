unit uAccountRepo;

interface

uses
  System.JSON, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Phys.SQLiteDef, FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Stan.Intf, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  Data.DB, FireDAC.Comp.Client;

type
  IAccountRepo = interface
    ['{5A6A9B56-A49D-4F5B-BFAF-2FBC2166B024}']
    procedure CreateAccount(id_usuario: Integer; const nome_conta: string;
      saldo_inicial: Double);
    function ListAll: TJSONArray;
  end;

  TAccountRepo = class(TInterfacedObject, IAccountRepo)
  private
    FConn: TFDConnection;
  public
    constructor Create(AConn: TFDConnection);
    procedure CreateAccount(id_usuario: Integer; const nome_conta: string;
      saldo_inicial: Double);
    function ListAll: TJSONArray;
  end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Param;

{ TAccountRepo }

constructor TAccountRepo.Create(AConn: TFDConnection);
begin
  inherited Create;
  FConn := AConn;
end;

procedure TAccountRepo.CreateAccount(id_usuario: Integer;
  const nome_conta: string; saldo_inicial: Double);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text :=
      'INSERT INTO conta (id_usuario, nome_conta, saldo_inicial) VALUES (:id_usuario, :nome_conta, :saldo_inicial)';
    Q.ParamByName('id_usuario').AsInteger := id_usuario;
    Q.ParamByName('nome_conta').AsString := nome_conta;
    Q.ParamByName('saldo_inicial').AsFloat := saldo_inicial;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TAccountRepo.ListAll: TJSONArray;
var
  Q: TFDQuery;
  Arr: TJSONArray;
  Obj: TJSONObject;
begin
  Arr := TJSONArray.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text :=
      'SELECT id_conta, id_usuario, nome_conta, saldo_inicial FROM conta ORDER BY nome_conta';
    Q.Open;
    while not Q.Eof do
    begin
      Obj := TJSONObject.Create;
      Obj.AddPair('id_conta', TJSONNumber.Create(Q.FieldByName('id_conta')
        .AsInteger));
      Obj.AddPair('id_usuario', TJSONNumber.Create(Q.FieldByName('id_usuario')
        .AsInteger));
      Obj.AddPair('nome_conta', Q.FieldByName('nome_conta').AsString);
      Obj.AddPair('saldo_inicial',
        TJSONNumber.Create(Q.FieldByName('saldo_inicial').AsFloat));
      Arr.AddElement(Obj);
      Q.Next;
    end;
    Result := Arr;
  finally
    Q.Free;
  end;
end;

end.
