unit CTInteres;

interface

uses SysUtils, DB, DBTables, CUtiles, CIDBFM;

type

TTIntereses = class(TObject)
  categoria: string; interes: real; tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xcategoria: string; xinteres: real);
  destructor  Destroy; override;

  function    getInteres: real;

  procedure   Grabar(xcategoria: string; xinteres: real);
  function    Buscar(xcategoria: string): boolean;
  procedure   Borrar(xcategoria: string);
  procedure   getDatos(xcategoria: string);

  procedure  conectar;
  procedure  desconectar;
 private
  { Declaraciones Privadas }
end;

function interes: TTIntereses;

implementation

var
  xinteres: TTIntereses = nil;

constructor TTIntereses.Create(xcategoria: string; xinteres: real);
begin
  inherited Create;
  tabla := datosdb.openDB('interes.DB', 'categoria');
end;

destructor TTIntereses.Destroy;
begin
  inherited Destroy;
end;

function    TTIntereses.getInteres: real;
begin
  Result := interes;
end;

procedure   TTIntereses.Grabar(xcategoria: string; xinteres: real);
begin
  if Buscar(xcategoria) then tabla.Edit else tabla.Append;
  tabla.FieldByName('categoria').AsString := xcategoria;
  tabla.FieldByName('interes').AsFloat    := xinteres;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

function    TTIntereses.Buscar(xcategoria: string): boolean;
begin
  if tabla.FindKey([xcategoria]) then Result := True else Result := False;
end;

procedure   TTIntereses.Borrar(xcategoria: string);
begin
  if Buscar(xcategoria) then tabla.Delete;
end;

procedure   TTIntereses.getDatos(xcategoria: string);
begin
  if Buscar(xcategoria) then interes := tabla.FieldByName('interes').AsFloat else interes := 0;
end;

procedure TTIntereses.conectar;
begin
  if not tabla.Active then tabla.Open;
end;

procedure TTIntereses.desconectar;
begin
  datosdb.closeDB(tabla);
end;

{===============================================================================}

function interes: TTIntereses;
begin
  if xinteres = nil then
    xinteres := TTIntereses.Create('', 0);
  Result := xinteres;
end;

{===============================================================================}

initialization

finalization
  xinteres.Free;

end.