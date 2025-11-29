unit uHealthController;

interface

uses
  Horse;

procedure RegisterHealthRoutes;

implementation

procedure RegisterHealthRoutes;
begin
  THorse.Get('/api/health',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send('OK');
    end);
end;

end.
