unit uAccountsController;

interface

uses
  Horse, System.JSON, uAccountRepo;

procedure RegisterAccountRoutes(const Repo: IAccountRepo);

implementation

uses
  System.SysUtils;

procedure RegisterAccountRoutes(const Repo: IAccountRepo);
begin
  // GET /api/accounts
  THorse.Get('/api/accounts',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      Arr: TJSONArray;
      Json: string;
    begin
      Arr := Repo.ListAll;
      try
        Json := Arr.ToJSON;
        Writeln('JSON /api/accounts: ' + Json);

        Res.ContentType('application/json; charset=utf-8');
        Res.Send(Json);
      finally
        Arr.Free;
      end;
    end);

  // POST /api/accounts
  THorse.Post('/api/accounts',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      Body: TJSONObject;
      IdUsuario: Integer;
      Nome: string;
      SaldoInicial: Double;
    begin
      Body := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
      try
        if not Assigned(Body) then
          raise Exception.Create('Invalid JSON body');
        IdUsuario := Body.GetValue<Integer>('id_usuario');
        Nome := Body.GetValue<string>('nome_conta');
        SaldoInicial := Body.GetValue<Double>('saldo_inicial');
        Repo.CreateAccount(IdUsuario, Nome, SaldoInicial);
        Res.Status(201);
        Res.Send(TJSONObject.Create.AddPair('message',
          'Conta criada com sucesso.'));
      finally
        Body.Free;
      end;
    end);
end;

end.
