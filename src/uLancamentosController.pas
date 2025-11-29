unit uLancamentosController;

interface

uses
  Horse, System.JSON, uLancamentoRepo;

procedure RegisterLancamentoRoutes(const Repo: ILancamentoRepo);

implementation

uses
  System.SysUtils;

procedure RegisterLancamentoRoutes(const Repo: ILancamentoRepo);
begin
  // GET /api/lancamentos
  THorse.Get('/api/lancamentos',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      ContaStr: string;
      ContaId: Integer;
      DataInicio, DataFim: string;
      Arr: TJSONArray;
      JSON: string;
    begin

      ContaStr := Trim(Req.Query.Field('conta').AsString);
      if ContaStr <> '' then
        ContaId := StrToIntDef(ContaStr, 0)
      else
        ContaId := 0;

      DataInicio := Trim(Req.Query.Field('data_inicio').AsString);
      DataFim := Trim(Req.Query.Field('data_fim').AsString);


      Arr := Repo.ListByFilter(ContaId, DataInicio, DataFim);
      try
        JSON := Arr.ToJSON;
        Writeln('JSON /api/lancamentos: ' + JSON);

        Res.ContentType('application/json; charset=utf-8');
        Res.Send(JSON);
      finally
        Arr.Free;
      end;
    end);

  // POST /api/lancamentos
  THorse.Post('/api/lancamentos',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      Body: TJSONObject;
      IdConta, IdCategoria: Integer;
      TipoStr: string;
      Tipo: Char;
      Descricao, DataLancamento: string;
      Valor: Double;
      Resp: TJSONObject;
    begin
      Body := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
      try
        if not Assigned(Body) then
          raise Exception.Create('Invalid JSON body');

        IdConta := Body.GetValue<Integer>('id_conta');
        IdCategoria := Body.GetValue<Integer>('id_categoria');

        TipoStr := Body.GetValue<string>('tipo');
        if TipoStr = '' then
          raise Exception.Create('Campo "tipo" é obrigatório');
        Tipo := TipoStr[1];

        Descricao := Body.GetValue<string>('descricao');
        Valor := Body.GetValue<Double>('valor');
        DataLancamento := Body.GetValue<string>('data_lancamento');

        if Valor <= 0 then
          raise Exception.Create
            ('O valor do lançamento deve ser maior que zero.');

        Repo.CreateLancamento(IdConta, IdCategoria, Tipo, Descricao, Valor,
          DataLancamento);

        Resp := TJSONObject.Create;
        Resp.AddPair('message', 'Lançamento criado com sucesso.');
        Res.Status(201);
        Res.ContentType('application/json; charset=utf-8');
        Res.Send(Resp.ToJSON);
      finally
        Body.Free;
      end;
    end);
end;

end.
