program samples;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Paginate,
  Horse.Jhonson,
  System.SysUtils,
  System.JSON,
  DataSet.Serialize,
  Services.Bairro in 'src\services\Services.Bairro.pas' {ServiceBairro: TDataModule};

var
  App: THorse;

begin
  App := THorse.Create;

  App.Use(Paginate);
  App.Use(Jhonson);

  THorse.Get('/bairros',
    procedure(AReq: THorseRequest; ARes: THorseResponse; ANext: TProc)
    var
      AService: TServiceBairro;
    begin
      AService := TServiceBairro.Create(nil);

      try
        ARes.Send(AService.Listar.ToJSONObject());
      finally
        FreeAndNil(AService);
      end;
    end);

  THorse.Listen(9000);
end.
