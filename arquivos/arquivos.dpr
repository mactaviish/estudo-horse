program arquivos;

{$APPTYPE CONSOLE}

{$R *.res}

{$REGION 'uses'}
uses
  Horse,
  Horse.Logger,
  Horse.Logger.Provider.LogFile,
  Horse.OctetStream,
  System.Classes,
  System.SysUtils;
{$ENDREGION}

var
  App: THorse;
  AHorseLoggerCfg: THorseLoggerLogFileConfig;

begin

  App := THorse.Create;
  App.Port := 9000;

  AHorseLoggerCfg := THorseLoggerLogFileConfig.New
    .SetLogFormat('[${time}] | ${request_clientip} | ${request_method} | ${response_status}')
    .SetDir(GetCurrentDir + '\Log');

  App.Use(OctetStream);
  THorseLoggerManager.RegisterProvider(THorseLoggerProviderLogFile.New(AHorseLoggerCfg));
  THorse.Use(THorseLoggerManager.HorseCallback);

  App.Get('/arquivos',
    procedure(AReq: THorseRequest; ARes: THorseResponse; ANext: TProc)
    var
      LStream: TFileStream;
    begin
      LStream := TFileStream.Create(ExtractFilePath(ParamStr(0)) + 'horse.pdf', fmOpenRead);
      ARes.Send<TStream>(LStream);
    end);

  App.Post('/arquivos',
    procedure(AReq: THorseRequest; ARes: THorseResponse; ANext: TProc)
    var
      LStream: TMemoryStream;
    begin
      LStream := AReq.Body<TMemoryStream>;
      LStream.SaveToFile(ExtractFilePath(ParamStr(0)) + 'horse-copia.pdf');
      ARes.Send('Arquivo salvo com sucesso!').Status(THTTPStatus.Created);
    end);


  App.Listen(9000);
end.
