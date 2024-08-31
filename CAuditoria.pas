unit CAuditoria;

interface

uses SysUtils, DB, DBTables, CBDT, CVias, CUtiles, CListar, CIDBFM;

type

TTAuditoria = class(TObject)            // Superclase
  fecha, idanter: string;
  s_inicio: boolean;
  Q: TQuery;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   setFecha(f: string);
  procedure   Listar;
  procedure   ListFacturasEmitidas(salida: char);
  procedure   ListRecaudacionCobros(salida: char);
  procedure   ListPagosEfectuados(salida: char);
  procedure   ListOperacionesProveedores(salida: char);
private
  { Declaraciones Privadas }
protected
  { Declaraciones Protegidas }
  total: real;
  procedure verifListado(salida: char);
  procedure Titulos(salida: char);
end;

function auditoria: TTAuditoria;

implementation

var
  xauditoria: TTAuditoria = nil;

constructor TTAuditoria.Create;
begin
  fecha := '';
  inherited Create;
end;

destructor TTAuditoria.Destroy;
begin
  inherited Destroy;
end;

procedure TTAuditoria.setFecha(f: string);
begin
  s_inicio := False;
  fecha    := utiles.sExprFecha(f);
end;

procedure TTAuditoria.verifListado(salida: char);
// Objetivo...: Verificar emisión del Listado
begin
  if not s_inicio then Titulos(salida);   // Sio no se listo nada, tiramos los titulos
end;

procedure TTAuditoria.ListFacturasEmitidas(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  verifListado(salida);

  List.Linea(0, 0, 'Comprobantes Emitidos', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString + '   ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(55, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
      List.importe(90, list.lineactual, '', Q.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
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

procedure TTAuditoria.ListRecaudacionCobros(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  verifListado(salida);

  List.Linea(0, 0, 'Ingresos por por Cobros Efectuados', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString + '   ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(55, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
      List.importe(90, list.lineactual, '', Q.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
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

procedure TTAuditoria.ListPagosEfectuados(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  verifListado(salida);

  List.Linea(0, 0, 'Egresos por Pagos Efectuados', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString + '   ' + Q.FieldByName('rsocial').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(55, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
      List.importe(90, list.lineactual, '', Q.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');      List.Linea(90, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + Q.FieldByName('importe').AsFloat;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(90, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Egresos  .....:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(90, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTAuditoria.ListOperacionesProveedores(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  verifListado(salida);

  List.Linea(0, 0, 'Comprobantes de Proveedores en cuenta corriente', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString + '   ' + Q.FieldByName('rsocial').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(55, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
      List.importe(90, list.lineactual, '', Q.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');      List.Linea(90, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + Q.FieldByName('importe').AsFloat;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(90, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Egresos  .....:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(90, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTAuditoria.Titulos(salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Informe de Auditoría - ' + utiles.sFormatoFecha(fecha), 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  List.Titulo(0, 0, ' Operaciones Registradas', 1, 'Arial, negrita, 12');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTAuditoria.Listar;
// Objetivo...: Emitir el informe
begin
  List.FinList;
  s_inicio := False;
end;

{===============================================================================}

function auditoria: TTAuditoria;
begin
  if xauditoria = nil then
    xauditoria := TTAuditoria.Create;
  Result := xauditoria;
end;

{===============================================================================}

initialization

finalization
  xauditoria.Free;

end.
