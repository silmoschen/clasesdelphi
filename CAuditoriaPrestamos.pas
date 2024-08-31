unit CAuditoriaPrestamos;

interface

uses CAuditoria, Ccctsoc, CFondoG, CSEgresos, CPagoServ, CDepSoc, SysUtils, DB, DBTables, CBDT, CVias, CUtiles, CListar, CIDBFM;

type

TTAuditoriaPrestamos = class(TTAuditoria)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ListFacturasEmitidas(salida: char);
  procedure   ListRecaudacionCobros(salida: char);
  procedure   ListCobroCuotasSoc(salida: char);
  procedure   ListEgresosSocios(salida: char);
  procedure   ListServiciosPagos(salida: char);
  procedure   ListRetirosAAR(salida: char);
  procedure   ListDepositosSocTitulares(salida: char);
private
  { Declaraciones Privadas }
end;

function auditoriaprestamos: TTAuditoriaPrestamos;

implementation

var
  xauditoria: TTAuditoriaPrestamos = nil;

constructor TTAuditoriaPrestamos.Create;
begin
  fecha := '';
  inherited Create;
end;

destructor TTAuditoriaPrestamos.Destroy;
begin
  inherited Destroy;
end;

procedure TTAuditoriaPrestamos.ListFacturasEmitidas(salida: char);
// Objetivo...: Listar Créditos otorgados en el día
begin
  Q := ccsoc.AuditoriaFacturasEmitidas(fecha);
  inherited ListFacturasEmitidas(salida);
end;

procedure TTAuditoriaPrestamos.ListRecaudacionCobros(salida: char);
// Objetivo...: Listar cobros de cuotas realizados
begin
  Q := ccsoc.AuditoriaRecaudacionesCobros(fecha);
  inherited ListRecaudacionCobros(salida);
end;

procedure TTAuditoriaPrestamos.ListCobroCuotasSoc(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := fondog.AuditoriaCuotasRecaudadas(fecha, '1');

  verifListado(salida);

  List.Linea(0, 0, 'Recaudación por Cobro de Cuotas Societarias', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, Q.FieldByName('codsocio').AsString + ' ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(50, list.lineactual, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString) + '  ' + Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
      List.importe(90, list.lineactual, '', Q.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + Q.FieldByName('monto').AsFloat;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(90, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Ingresos .....:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(90, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTAuditoriaPrestamos.ListServiciosPagos(salida: char);
// Objetivo...: Listar los servicios de socios adherentes pagos
begin
  Q := pagoserv.AuditoriaServicios(fecha);

  verifListado(salida);

  List.Linea(0, 0, 'Pagos de Servicios', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, Q.FieldByName('codsocio').AsString + ' ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(30, list.lineactual, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString) + '  ' + Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
      List.Linea(60, list.lineactual, utiles.sFormatoFecha(Q.FieldByName('pdfecha').AsString) + '-' + utiles.sFormatoFecha(Q.FieldByName('phfecha').AsString), 3, 'Arial, normal, 8', salida, 'N');
      List.importe(90, list.lineactual, '', Q.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 5, 'Arial, normal, 8', salida, 'S');
      total := total + Q.FieldByName('importe').AsFloat;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(90, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Ingresos .....:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(90, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTAuditoriaPrestamos.ListEgresosSocios(salida: char);
// Objetivo...: Listar los Retiros de Socios titulares
begin
  Q := egrsocios.AuditoriaEgresosSocios(fecha);

  verifListado(salida);

  List.Linea(0, 0, 'Retiros de Socios Titulares', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, Q.FieldByName('codsocio').AsString + ' ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(50, list.lineactual, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString) + '  ' + Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
      List.importe(90, list.lineactual, '', Q.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + Q.FieldByName('importe').AsFloat;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(90, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Egresos .....:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(90, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTAuditoriaPrestamos.ListRetirosAAR(salida: char);
// Objetivo...: Listar los Retiros de Socios titulares
begin
  Q := fondog.AuditoriaRetiros(fecha);

  verifListado(salida);

  List.Linea(0, 0, 'Retiros de Socios - Fondo Genuino A.A.R.', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, Q.FieldByName('codsocio').AsString + ' ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(50, list.lineactual, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString) + '  ' + Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
      List.importe(90, list.lineactual, '', Q.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + Q.FieldByName('importe').AsFloat;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(90, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Egresos .....:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(90, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTAuditoriaPrestamos.ListDepositosSocTitulares(salida: char);
// Objetivo...: Listar los Depositos de Socios titulares
begin
  Q := depsocios.AuditoriaDepositos(fecha);

  verifListado(salida);

  List.Linea(0, 0, 'Depósitos de Socios Titulares', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, Q.FieldByName('codsocio').AsString + ' ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(50, list.lineactual, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'S');
      List.importe(90, list.lineactual, '', Q.FieldByName('deposito').AsFloat, 3, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + Q.FieldByName('deposito').AsFloat;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(90, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Depósitos ...:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(90, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

{===============================================================================}

function auditoriaprestamos: TTAuditoriaPrestamos;
begin
  if xauditoria = nil then
    xauditoria := TTAuditoriaPrestamos.Create;
  Result := xauditoria;
end;

{===============================================================================}

initialization

finalization
  xauditoria.Free;

end.
