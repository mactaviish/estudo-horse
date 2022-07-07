program backend;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, Horse, Horse.Commons, Horse.Jhonson, System.JSON;

var
  App: THorse;
  Users: TJSONArray;

begin
  App := THorse.Create;
  App.Use(Jhonson);
  App.Port := 9000;

  Users := TJSONArray.Create;

  App.Get('/ping',
    procedure(_Req: THorseRequest; _Res: THorseResponse; _Next: TProc)
    begin
      _Res.Send<TJSONArray>(Users);
    end);

  App.Post('/users',
    procedure(_Req: THorseRequest; _Res: THorseResponse; _Next: TProc)
    var
      User: TJSONObject;
    begin
      User := _Req.Body<TJSONObject>.Clone as TJSONObject;
      Users.AddElement(User);
      _Res.Send<TJSONAncestor>(User.Clone).Status(THTTPStatus.Created);
    end);

    App.Listen;
end.
