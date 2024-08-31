unit CAudInst;

interface

uses SysUtils, DB, DBTables, CBDT, CVias, CUtiles, CListar, CIDBFM;

type

TTAudInst = class(TObject)            // Superclase
  fecha: string;
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
  procedure   ListIngresosEfectivo(salida: char);
  procedure   ListEgresosEfectivo(salida: char);
private
  { Declaraciones Privadas }
  total: real;
  procedure verifListado(salida: char);
  procedure Titulos(salida: char);
end;

function auditInst: TTAudInst;

implementation

var
  xauditInst: TTAudInst = nil;

constructor TTAudInst.Create;
begin
  fecha := '';
  inherited Create;
end;

destructor TTAudInst.Destroy;
begin
  inherited Destroy;
end;

procedure TTAudInst.setFecha(f: string);
begin
  s_inicio := False;
  fecha    := utiles.sExprFecha(f);
end;

procedure TTAudInst.verifListado(salida: char);
// Objetivo...: Verificar emisión del Listado
begin
  if not s_inicio then Titulos(salida);   // Sio no se listo nada, tiramos los titulos
end;

procedure TTAudInst.ListFacturasEmitidas(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := datosdb.tranSQL('SELECT ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, alumnos.nombre, ctactecl.importe '
                       +'FROM ctactecl, alumnos WHERE ctactecl.idtitular = alumnos.idalumno AND ctactecl.fecha = ' + '''' + fecha + '''' + ' AND items = ' + '''' + '-1' + '''');

  verifListado(salida);

  List.Linea(0, 0, 'Comprobantes Emitidos - Ventas', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString + '   ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(55, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
      List.importe(80, list.lineactual, '', Q.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
      List.Linea(90, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + Q.FieldByName('importe').AsFloat;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(80, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Ingresos .....:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(80, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(90, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTAudInst.ListRecaudacionCobros(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := datosdb.tranSQL('SELECT ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, alumnos.nombre, ctactecl.importe '
                       +'FROM ctactecl, alumnos WHERE ctactecl.idtitular = alumnos.idalumno AND ctactecl.fecha = ' + '''' + fecha + '''' + ' AND dc = ' + '''' + '2' + '''');

  verifListado(salida);

  List.Linea(0, 0, 'Ingresos por por Cobros Efectuados', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString + '   ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(55, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
      List.importe(80, list.lineactual, '', Q.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
      List.Linea(90, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + Q.FieldByName('importe').AsFloat;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(80, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Ingresos .....:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(80, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(90, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTAudInst.ListIngresosEfectivo(salida: char);
// Objetivo...: Listar otros Ingresos de Efectivo
begin
  Q := datosdb.tranSQL('SELECT * FROM cajamov WHERE fecha = ' + '''' + fecha + '''' + ' AND tipomov = ' + '''' + '1' + '''');

  verifListado(salida);

  List.Linea(0, 0, 'Otros Ingresos Efectivo', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      if Copy(Q.FieldByName('nroplanilla').AsString, 1, 1) <> '-' then   // Movimientos que no son automáticos
        begin
          List.Linea(0, 0, Q.FieldByName('pagado').AsString, 1, 'Arial, normal, 8', salida, 'N');
          List.Linea(55, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
          List.importe(80, list.lineactual, '', Q.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');      List.Linea(90, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
          total := total + Q.FieldByName('importe').AsFloat;
        end;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(80, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Ingresos  .....:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(80, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(90, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTAudInst.ListPagosEfectuados(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := datosdb.tranSQL('SELECT ctactepr.tipo, ctactepr.sucursal, ctactepr.numero, ctactepr.concepto, ctactepr.idtitular, ctactepr.clavecta, profesor.nombre, ctactepr.importe '
                       +'FROM ctactepr, profesor WHERE ctactepr.idtitular = profesor.nrolegajo AND ctactepr.fecha = ' + '''' + fecha + '''' + ' AND dc = ' + '''' + '2' + '''');

  verifListado(salida);

  List.Linea(0, 0, 'Egresos por Pagos Efectuados', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString + '   ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(55, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
      List.importe(80, list.lineactual, '', Q.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');      List.Linea(90, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + Q.FieldByName('importe').AsFloat;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(80, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Egresos  .....:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(80, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(90, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTAudInst.ListOperacionesProveedores(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := datosdb.tranSQL('SELECT ctactepr.tipo, ctactepr.sucursal, ctactepr.numero, ctactepr.concepto, ctactepr.idtitular, ctactepr.clavecta, profesor.nombre, ctactepr.importe '
                       +'FROM ctactepr, provedor WHERE ctactepr.idtitular = provedor.codprov AND ctactepr.fecha = ' + '''' + fecha + '''' + ' AND dc = ' + '''' + '1' + '''');

  verifListado(salida);

  List.Linea(0, 0, 'Comprobantes Profesores', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString + '   ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(55, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
      List.importe(80, list.lineactual, '', Q.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');      List.Linea(90, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + Q.FieldByName('importe').AsFloat;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(80, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Egresos  .....:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(80, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(90, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTAudInst.ListEgresosEfectivo(salida: char);
// Objetivo...: Listar otros Ingresos de Efectivo
begin
  Q := datosdb.tranSQL('SELECT * FROM cajamov WHERE fecha = ' + '''' + fecha + '''' + ' AND tipomov = ' + '''' + '2' + '''');

  verifListado(salida);

  List.Linea(0, 0, 'Otros Ingresos Efectivo', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      if Copy(Q.FieldByName('nroplanilla').AsString, 1, 1) <> '-' then   // Movimientos que no son automáticos
        begin
          List.Linea(0, 0, Q.FieldByName('pagado').AsString, 1, 'Arial, normal, 8', salida, 'N');
          List.Linea(55, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
          List.importe(80, list.lineactual, '', Q.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');      List.Linea(90, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
          total := total + Q.FieldByName('importe').AsFloat;
        end;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(80, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Egresos  .....:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(80, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(90, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTAudInst.Titulos(salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Informe de Auditoría - ' + utiles.sFormatoFecha(fecha), 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTAudInst.Listar;
// Objetivo...: Emitir el informe
begin
  List.FinList;
  s_inicio := False;
end;

{===============================================================================}

function auditInst: TTAudInst;
begin
  if xauditInst = nil then
    xauditInst := TTAudInst.Create;
  Result := xauditInst;
end;

{===============================================================================}

initialization

finalization
  xauditInst.Free;

end.
