program backend;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.JSON, Horse, Horse.Commons, Horse.Jhonson, Horse.BasicAuthentication;

var
  App: THorse;
  Users: TJSONArray;

begin
  App := THorse.Create;
  App.Port := 9000;

  App.Use(Jhonson);
  App.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
      Result := AUsername.Equals('user') and APassword.Equals('password');
    end));

  Users := TJSONArray.Create;

  App.Get('/users',
    procedure(AReq: THorseRequest; ARes: THorseResponse; _Next: TProc)
    begin
      ARes.Send<TJSONAncestor>(Users.Clone);
    end);

  App.Post('/users',
    procedure(AReq: THorseRequest; ARes: THorseResponse; _Next: TProc)
    var
      User: TJSONObject;
    begin
      User := AReq.Body<TJSONObject>.Clone as TJSONObject;
      Users.AddElement(User);
      ARes.Send<TJSONAncestor>(User.Clone).Status(THTTPStatus.Created);
    end);

  App.Delete('/users/:id',
    procedure(AReq: THorseRequest; ARes: THorseResponse; _Next: TProc)
    var
      Id: Integer;
    begin
      Id := AReq.Params.Items['id'].ToInteger;
      Users.Remove(Pred(Id)).Free;
      ARes.Send<TJSONAncestor>(Users.Clone).Status(THTTPStatus.NoContent);
    end);

  App.Listen;
end.
