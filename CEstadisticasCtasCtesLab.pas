unit CEstadisticasCtasCtesLab;

interface

uses CEstInfo, CccteLab, SysUtils, DB, DBTables, CVias, CUtiles, CListar, CBDT, CIDBFM;

type

TTEstadisticaCtaCte = class(TTInformesEstadisticos)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ListSaldosCobrar(salida: char);
  procedure   ListCobrosEfectuados(salida: char);
  procedure   ListCuotasVencidas(salida: char);
private
  { Declaraciones Privadas }
end;

function estadisticactacteLab: TTEstadisticaCtaCte;

implementation

var
  xestadistica: TTEstadisticaCtaCte = nil;

constructor TTEstadisticaCtaCte.Create;
begin
  inherited Create;
end;

destructor TTEstadisticaCtaCte.Destroy;
begin
  inherited Destroy;
end;

procedure TTEstadisticaCtaCte.ListSaldosCobrar(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := cclab.EstsqlSaldosCobrar(fecha1, fecha2);
  inherited ListSaldosCobrar(salida);
end;

procedure TTEstadisticaCtaCte.ListCobrosEfectuados(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := cclab.EstsqlCobrosEfectuados(fecha1, fecha2);
  inherited ListCobrosEfectuados(salida);
end;

procedure TTEstadisticaCtaCte.ListCuotasVencidas(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := cclab.EstsqlCuotasVencidas(fecha2, fecha2);
  inherited ListCuotasVencidas(salida);
end;

{===============================================================================}

function estadisticactacteLab: TTEstadisticaCtaCte;
begin
  if xestadistica = nil then
    xestadistica := TTEstadisticaCtaCte.Create;
  Result := xestadistica;
end;

{===============================================================================}

initialization

finalization
  xestadistica.Free;

end.
