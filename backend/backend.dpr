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

  App.Get('/users',
    procedure(_Req: THorseRequest; _Res: THorseResponse; _Next: TProc)
    begin
      _Res.Send<TJSONAncestor>(Users.Clone);
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

  App.Delete('/users/:id',
    procedure(_Req: THorseRequest; _Res: THorseResponse; _Next: TProc)
    var
      Id: Integer;
    begin
      Id := _Req.Params.Items['id'].ToInteger;
      Users.Remove(Pred(Id)).Free;
      _Res.Send<TJSONAncestor>(Users.Clone).Status(THTTPStatus.NoContent);
    end);

  App.Listen;
end.
