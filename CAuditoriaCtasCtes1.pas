unit CAuditoriaCtasCtes1;

interface

uses CAuditoria, CccteclSimple, Ccctepr, SysUtils, DB, DBTables, CBDT, CVias, CUtiles, CListar, CIDBFM;

type

TTAuditoriaCtasCtes1 = class(TTAuditoria)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ListFacturasEmitidas(salida: char);
  procedure   ListRecaudacionCobros(salida: char);
  procedure   ListPagosEfectuados(salida: char);
  procedure   ListOperacionesProveedores(salida: char);
private
  { Declaraciones Privadas }
end;

function auditoriactacte: TTAuditoriaCtasCtes1;

implementation

var
  xauditoria: TTAuditoriaCtasCtes1 = nil;

constructor TTAuditoriaCtasCtes1.Create;
begin
  fecha := '';
  inherited Create;
end;

destructor TTAuditoriaCtasCtes1.Destroy;
begin
  inherited Destroy;
end;

procedure TTAuditoriaCtasCtes1.ListFacturasEmitidas(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := cccls.AuditoriaFacturasEmitidas(fecha);
  inherited ListFacturasEmitidas(salida);
end;

procedure TTAuditoriaCtasCtes1.ListRecaudacionCobros(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := cccls.AuditoriaRecaudacionesCobros(fecha);
  inherited ListRecaudacionCobros(salida);
end;

procedure TTAuditoriaCtasCtes1.ListPagosEfectuados(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := ccpr.AuditoriaPagosEfectuados(fecha);
  inherited ListPagosEfectuados(salida);
end;

procedure TTAuditoriaCtasCtes1.ListOperacionesProveedores(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := ccpr.AuditoriaOperacionesProveedores(fecha);
  inherited ListOperacionesProveedores(salida);
end;

{===============================================================================}

function auditoriactacte: TTAuditoriaCtasCtes1;
begin
  if xauditoria = nil then
    xauditoria := TTAuditoriaCtasCtes1.Create;
  Result := xauditoria;
end;

{===============================================================================}

initialization

finalization
  xauditoria.Free;

end.
