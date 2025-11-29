unit uCategoriesController;

interface

uses
  Horse, System.JSON, uCategoryRepo;

procedure RegisterCategoryRoutes(const Repo: ICategoryRepo);

implementation

uses
  System.SysUtils;

procedure RegisterCategoryRoutes(const Repo: ICategoryRepo);
begin
  // GET /api/categories
  THorse.Get('/api/categories',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      Arr: TJSONArray;
      JSON: string;
    begin
      Arr := Repo.ListAll;
      try
        JSON := Arr.ToJSON;
        Writeln('JSON /api/categories: ' + JSON);

        Res.ContentType('application/json; charset=utf-8');
        Res.Send(JSON);
      finally
        Arr.Free;
      end;
    end);

  // POST /api/categories
  THorse.Post('/api/categories',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      Body: TJSONObject;
      IdUsuario: Integer;
      Descricao, Tipo: string;
    begin
      Body := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
      try
        if not Assigned(Body) then
          raise Exception.Create('Invalid JSON body');
        IdUsuario := Body.GetValue<Integer>('id_usuario');
        Descricao := Body.GetValue<string>('descricao');
        Tipo := Body.GetValue<string>('tipo');
        Repo.CreateCategory(IdUsuario, Descricao, Tipo);
        Res.Status(201);
        Res.Send(TJSONObject.Create.AddPair('message',
          'Categoria criada com sucesso.'));
      finally
        Body.Free;
      end;
    end);
end;

end.
