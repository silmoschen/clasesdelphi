unit CAuditoriaCtasCtes;

interface

uses CAuditoria, Ccctecl, Ccctepr, SysUtils, DB, DBTables, CBDT, CVias, CUtiles, CListar, CIDBFM;

type

TTAuditoriaCtasCtes = class(TTAuditoria)
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

function auditoriactacte: TTAuditoriaCtasCtes;

implementation

var
  xauditoria: TTAuditoriaCtasCtes = nil;

constructor TTAuditoriaCtasCtes.Create;
begin
  fecha := '';
  inherited Create;
end;

destructor TTAuditoriaCtasCtes.Destroy;
begin
  inherited Destroy;
end;

procedure TTAuditoriaCtasCtes.ListFacturasEmitidas(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := cccl.AuditoriaFacturasEmitidas(fecha);
  inherited ListFacturasEmitidas(salida);
end;

procedure TTAuditoriaCtasCtes.ListRecaudacionCobros(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := cccl.AuditoriaRecaudacionesCobros(fecha);
  inherited ListRecaudacionCobros(salida);
end;

procedure TTAuditoriaCtasCtes.ListPagosEfectuados(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := ccpr.AuditoriaPagosEfectuados(fecha);
  inherited ListPagosEfectuados(salida);
end;

procedure TTAuditoriaCtasCtes.ListOperacionesProveedores(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := ccpr.AuditoriaOperacionesProveedores(fecha);
  inherited ListOperacionesProveedores(salida);
end;

{===============================================================================}

function auditoriactacte: TTAuditoriaCtasCtes;
begin
  if xauditoria = nil then
    xauditoria := TTAuditoriaCtasCtes.Create;
  Result := xauditoria;
end;

{===============================================================================}

initialization

finalization
  xauditoria.Free;

end.
