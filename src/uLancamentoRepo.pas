unit uLancamentoRepo;

interface

uses
  System.JSON, FireDAC.Comp.Client;

type
  ILancamentoRepo = interface
    ['{A0029C37-7F0F-4B7D-9D61-0C6B4E21D18B}']
    procedure CreateLancamento(id_conta, id_categoria: Integer;
      const tipo, descricao: string; valor: Double;
      const data_lancamento: string);
    function ListByFilter(id_conta: Integer;
      const data_inicio, data_fim: string): TJSONArray;
  end;

  TLancamentoRepo = class(TInterfacedObject, ILancamentoRepo)
  private
    FConn: TFDConnection;
  public
    constructor Create(AConn: TFDConnection);
    procedure CreateLancamento(id_conta, id_categoria: Integer;
      const tipo, descricao: string; valor: Double;
      const data_lancamento: string);
    function ListByFilter(AContaId: Integer;
      const ADataInicio, ADataFim: string): TJSONArray;
  end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Param, System.Classes, Data.DB;

{ TLancamentoRepo }

constructor TLancamentoRepo.Create(AConn: TFDConnection);
begin
  inherited Create;
  FConn := AConn;
end;

procedure TLancamentoRepo.CreateLancamento(id_conta, id_categoria: Integer;
  const tipo, descricao: string; valor: Double; const data_lancamento: string);
var
  Q: TFDQuery;
  TipoUpper: string;
begin
  TipoUpper := UpperCase(tipo);
  if not(tipo = 'R') or (tipo = 'D') then
    raise Exception.Create
      ('Tipo de lançamento inválido. Use "R" para receita ou "D" para despesa.');
  if valor <= 0 then
    raise Exception.Create('O valor do lançamento deve ser maior que zero.');

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text :=
      'INSERT INTO lancamento (id_conta, id_categoria, tipo, descricao, valor, data_lancamento) '
      + 'VALUES (:id_conta, :id_categoria, :tipo, :descricao, :valor, :data_lancamento)';
    Q.ParamByName('id_conta').AsInteger := id_conta;
    Q.ParamByName('id_categoria').AsInteger := id_categoria;
    Q.ParamByName('tipo').AsString := TipoUpper;
    Q.ParamByName('descricao').AsString := descricao;
    Q.ParamByName('valor').AsFloat := valor;
    Q.ParamByName('data_lancamento').AsString := data_lancamento;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TLancamentoRepo.ListByFilter(AContaId: Integer;
  const ADataInicio, ADataFim: string): TJSONArray;
var
  Q: TFDQuery;
  Arr: TJSONArray;
  Obj: TJSONObject;
  SQL: string;
  HasWhere: Boolean;
begin
  Arr := TJSONArray.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;

    SQL := 'SELECT id_lancamento, id_conta, id_categoria, tipo, descricao, valor, '
      + '       data_lancamento, data_registro ' + 'FROM lancamento';

    HasWhere := False;


    if AContaId > 0 then
    begin
      if not HasWhere then
      begin
        SQL := SQL + ' WHERE ';
        HasWhere := True;
      end
      else
        SQL := SQL + ' AND ';

      SQL := SQL + 'id_conta = :id_conta';
    end;


    if ADataInicio <> '' then
    begin
      if not HasWhere then
      begin
        SQL := SQL + ' WHERE ';
        HasWhere := True;
      end
      else
        SQL := SQL + ' AND ';


      SQL := SQL + 'date(data_lancamento) >= date(:data_inicio)';
    end;


    if ADataFim <> '' then
    begin
      if not HasWhere then
      begin
        SQL := SQL + ' WHERE ';
        HasWhere := True;
      end
      else
        SQL := SQL + ' AND ';

      SQL := SQL + 'date(data_lancamento) <= date(:data_fim)';
    end;

    SQL := SQL + ' ORDER BY date(data_lancamento) DESC, id_lancamento DESC';

    Q.SQL.Text := SQL;
    Writeln('SQL /api/lancamentos: ' + Q.SQL.Text);


    if AContaId > 0 then
      Q.ParamByName('id_conta').AsInteger := AContaId;

    if ADataInicio <> '' then
      Q.ParamByName('data_inicio').AsString := ADataInicio;

    if ADataFim <> '' then
      Q.ParamByName('data_fim').AsString := ADataFim;

    Q.Open;

    while not Q.Eof do
    begin
      Obj := TJSONObject.Create;
      Obj.AddPair('id_lancamento',
        TJSONNumber.Create(Q.FieldByName('id_lancamento').AsInteger));
      Obj.AddPair('id_conta', TJSONNumber.Create(Q.FieldByName('id_conta')
        .AsInteger));
      Obj.AddPair('id_categoria',
        TJSONNumber.Create(Q.FieldByName('id_categoria').AsInteger));
      Obj.AddPair('tipo', Q.FieldByName('tipo').AsString);
      Obj.AddPair('descricao', Q.FieldByName('descricao').AsString);
      Obj.AddPair('valor', TJSONNumber.Create(Q.FieldByName('valor').AsFloat));
      Obj.AddPair('data_lancamento', Q.FieldByName('data_lancamento').AsString);
      Obj.AddPair('data_registro', Q.FieldByName('data_registro').AsString);
      Arr.AddElement(Obj);
      Q.Next;
    end;

    Result := Arr;
  finally
    Q.Free;
  end;
end;

end.
