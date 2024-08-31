unit CDefViasIva;

interface

uses CDefVias, SysUtils, DB, DBTables, cbdt, CIDBFM;

type

TTdefviasiva = class(TTdefvias)            // Superclase

 public
  { Declaraciones Públicas }
  constructor Create(xnomvia, xdescrip: string);
  destructor  Destroy;
  function    setVias: TQuery;

  procedure   conectar;
  procedure   desconectar;
private
  { Declaraciones Privadas }
end;

function defviaiva: TTdefviasiva;

implementation

var
  xdefviaiva: TTdefviasiva = nil;

constructor TTdefviasiva.Create(xnomvia, xdescrip: string);
begin
  //inherited Create(xnomvia, xdescrip);
  tdefvia := datosdb.openDB('vias', 'nomvia');
end;

destructor TTdefviasiva.Destroy;
begin
  inherited Destroy;
end;

function TTdefviasiva.setVias: TQuery;
// Objetivo...: Devolver un set de vías disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM vias');
end;

procedure TTdefviasiva.conectar;
begin
  if not tdefvia.Active then tdefvia.Open;
end;

procedure TTdefviasiva.desconectar;
begin
  datosdb.closeDB(tdefvia);
end;

{===============================================================================}

function defviaiva: TTdefviasiva;
begin
  if xdefviaiva = nil then
    xdefviaiva := TTdefviasiva.Create('', '');
  Result := xdefviaiva;
end;

{===============================================================================}

initialization

finalization
  xdefviaiva.Free;

end.
