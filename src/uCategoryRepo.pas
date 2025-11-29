unit uCategoryRepo;

interface

uses
  System.JSON,  FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Phys.SQLiteDef, FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Stan.Intf, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  Data.DB, FireDAC.Comp.Client;

type
  ICategoryRepo = interface
    ['{A9F4E8BB-1309-4C28-A86C-FF281C0E0AAF}']
    procedure CreateCategory(id_usuario: Integer;
      const descricao, tipo: string);
    function ListAll: TJSONArray;
  end;

  TCategoryRepo = class(TInterfacedObject, ICategoryRepo)
  private
    FConn: TFDConnection;
  public
    constructor Create(AConn: TFDConnection);
    procedure CreateCategory(id_usuario: Integer;
      const descricao, tipo: string);
    function ListAll: TJSONArray;
  end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Param;

{ TCategoryRepo }

constructor TCategoryRepo.Create(AConn: TFDConnection);
begin
  inherited Create;
  FConn := AConn;
end;

procedure TCategoryRepo.CreateCategory(id_usuario: Integer;
  const descricao, tipo: string);
var
  Q: TFDQuery;
  TipoUpper: string;
begin
  TipoUpper := UpperCase(tipo);
  if not(tipo = 'R') or (tipo = 'D') then
    raise Exception.Create
      ('Tipo de categoria inválido. Use "R" para receita ou "D" para despesa.');

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text :=
      'INSERT INTO categoria (id_usuario, descricao, tipo) VALUES (:id_usuario, :descricao, :tipo)';
    Q.ParamByName('id_usuario').AsInteger := id_usuario;
    Q.ParamByName('descricao').AsString := descricao;
    Q.ParamByName('tipo').AsString := TipoUpper;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TCategoryRepo.ListAll: TJSONArray;
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
      'SELECT id_categoria, id_usuario, descricao, tipo FROM categoria ORDER BY descricao';
    Q.Open;
    while not Q.Eof do
    begin
      Obj := TJSONObject.Create;
      Obj.AddPair('id_categoria',
        TJSONNumber.Create(Q.FieldByName('id_categoria').AsInteger));
      Obj.AddPair('id_usuario', TJSONNumber.Create(Q.FieldByName('id_usuario')
        .AsInteger));
      Obj.AddPair('descricao', Q.FieldByName('descricao').AsString);
      Obj.AddPair('tipo', Q.FieldByName('tipo').AsString);
      Arr.AddElement(Obj);
      Q.Next;
    end;
    Result := Arr;
  finally
    Q.Free;
  end;
end;

end.
