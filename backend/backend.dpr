program backend;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.JSON, Horse, Horse.Commons, Horse.Jhonson,
  Horse.BasicAuthentication, Horse.Compression, Horse.HandleException;

var
  App: THorse;
  Users: TJSONArray;

begin
  App := THorse.Create;
  App.Port := 9000;

  App.Use(Compression());
  App.Use(Jhonson);
  App.Use(HandleException);
  App.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
      Result := AUsername.Equals('user') and APassword.Equals('password');
    end));

  Users := TJSONArray.Create;

  App.Get('/exception',
    procedure(AReq: THorseRequest; ARes: THorseResponse; ANext: TProc)
    var
      LConteudo: TJSONObject;
    begin
      raise EHorseException.Create('Error Message');
      LConteudo := TJSONObject.Create;
      LConteudo.AddPair('nome', 'Leonardo');
      ARes.Send(LConteudo);
    end);

  App.Get('/ping',
    procedure(AReq: THorseRequest; ARes: THorseResponse; ANext: TProc)
    var
      I: Integer;
      LPong: TJSONArray;
    begin
      LPong := TJSONArray.Create;
      for I := 0 to 1000 do
        LPong.Add(TJSONObject.Create(TJSONPair.Create('ping', 'pong')));
      ARes.Send(LPong);
    end);

  App.Get('/users',
    procedure(AReq: THorseRequest; ARes: THorseResponse; ANext: TProc)
    begin
      ARes.Send<TJSONAncestor>(Users.Clone);
    end);

  App.Post('/users',
    procedure(AReq: THorseRequest; ARes: THorseResponse; ANext: TProc)
    var
      User: TJSONObject;
    begin
      User := AReq.Body<TJSONObject>.Clone as TJSONObject;
      Users.AddElement(User);
      ARes.Send<TJSONAncestor>(User.Clone).Status(THTTPStatus.Created);
    end);

  App.Delete('/users/:id',
    procedure(AReq: THorseRequest; ARes: THorseResponse; ANext: TProc)
    var
      Id: Integer;
    begin
      Id := AReq.Params.Items['id'].ToInteger;
      Users.Remove(Pred(Id)).Free;
      ARes.Send<TJSONAncestor>(Users.Clone).Status(THTTPStatus.NoContent);
    end);

  App.Listen;
end.
