unit CEstadisticasVentas;

interface

uses CEstInfo, CFactVentaNormal, SysUtils, DB, DBTables, CVias, CUtiles, CListar, CBDT, CIDBFM;

type

TTEstadisticaVentas = class(TTInformesEstadisticos)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ProyeccionMensual(salida: char);
  procedure   ListCobrosEfectuados(salida: char);
  procedure   ListCuotasVencidas(salida: char);
private
  { Declaraciones Privadas }
end;

function estadisticaventas: TTEstadisticaVentas;

implementation

var
  xestadistica: TTEstadisticaVentas = nil;

constructor TTEstadisticaVentas.Create;
begin
  inherited Create;
end;

destructor TTEstadisticaVentas.Destroy;
begin
  inherited Destroy;
end;

procedure TTEstadisticaVentas.ProyeccionMensual(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := factventa.getFacturas(fecha1, fecha2);
  inherited ProyeccionMensual(salida, 'Ventas');
end;

procedure TTEstadisticaVentas.ListCobrosEfectuados(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
//  Q := cccl.EstsqlCobrosEfectuados(fecha1, fecha2);
  //inherited ListCobrosEfectuados(salida);
end;

procedure TTEstadisticaVentas.ListCuotasVencidas(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  //Q := cccl.EstsqlCuotasVencidas(fecha2, fecha2);
  //inherited ListCuotasVencidas(salida);
end;

{===============================================================================}

function estadisticaventas: TTEstadisticaVentas;
begin
  if xestadistica = nil then
    xestadistica := TTEstadisticaVentas.Create;
  Result := xestadistica;
end;

{===============================================================================}

initialization

finalization
  xestadistica.Free;

end.
