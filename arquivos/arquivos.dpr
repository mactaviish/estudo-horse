program arquivos;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse, Horse.OctetStream, System.Classes, System.SysUtils;

var
  App: THorse;

begin
  App := THorse.Create;
  App.Port := 9000;

  App.Use(OctetStream);

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
