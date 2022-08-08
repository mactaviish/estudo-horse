unit Services.Bairro;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TServiceBairro = class(TDataModule)
    mtBairros: TFDMemTable;
    mtBairrosID: TIntegerField;
    mtBairrosNOME: TStringField;
  private
    { Private declarations }
  public
    { Public declarations }

    function Listar: TDataSet;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TServiceBairro }

function TServiceBairro.Listar: TDataSet;
var
  ACount: Integer;
begin
  mtBairros.Open;

  Result := mtBairros;
  for ACount := 1 to 200 do
  begin
    mtBairros.Append;
    mtBairrosNOME.Value := 'Bairro ' + ACount.ToString;
    mtBairros.Post;
  end;
end;

end.
