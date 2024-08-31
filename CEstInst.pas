unit CEstInst;

interface

uses SysUtils, DB, DBTables, CVias, CUtiles, CListar, CBDT, CIDBFM;

type

TTEstInstituto = class(TObject)            // Superclase
  fecha1, fecha2, per: string;
  s_inicio: boolean;
  Q: TQuery;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   setFecha(f: string);
  procedure   Listar;
  procedure   ListSaldosCobrar(salida: char);
  procedure   ListCobrosEfectuados(salida: char);
  procedure   ListCuotasVencidas(salida: char);

  // Consultas SQL
  function    sqlSaldosCobrar: TQuery;
  function    sqlCobrosEfectuados: TQuery;
  function    sqlCuotasVencidas: TQuery;
private
  { Declaraciones Privadas }
  total: real;
  procedure verifListado(salida: char);
  procedure Titulos(salida: char);
end;

function estinst: TTEstInstituto;

implementation

var
  xestinst: TTEstInstituto = nil;

constructor TTEstInstituto.Create;
begin
  fecha1 := ''; fecha2 := '';
  inherited Create;
end;

destructor TTEstInstituto.Destroy;
begin
  inherited Destroy;
end;

function TTEstInstituto.sqlSaldosCobrar: TQuery;
// Objetivo...: Generar Transacción SQL para determinar Saldos a Cobrar de c/c
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, alumnos.nombre, ctactecl.importe, ctactecl.entrega '
           +'FROM ctactecl, alumnos WHERE ctactecl.idtitular = alumnos.idalumno AND ctactecl.fecha >= ' + '''' + fecha1 + '''' + ' AND ctactecl.fecha <= ' + '''' + fecha2 + ''''
           +' AND ctactecl.items > ' + '''' + '000' + '''' + ' AND ctactecl.estado = ' + '''' + 'I' + '''');
end;

function TTEstInstituto.sqlCobrosEfectuados: TQuery;
// Objetivo...: Generar Transacción SQL para determinar Cobros Efectuados de c/c
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, alumnos.nombre, ctactecl.importe '
           +'FROM ctactecl, alumnos WHERE ctactecl.idtitular = alumnos.idalumno AND ctactecl.fecha >= ' + '''' + fecha1 + '''' + ' AND ctactecl.fecha <= ' + '''' + fecha2 + '''' + ' AND dc = ' + '''' + '2' + '''');
end;

function TTEstInstituto.sqlCuotasVencidas: TQuery;
// Objetivo...: Generar Transacción SQL para determinar Cobros Efectuados de c/c
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, alumnos.nombre, ctactecl.importe, ctactecl.entrega '
                          + 'FROM ctactecl, alumnos WHERE ctactecl.idtitular = alumnos.idalumno AND ctactecl.fecha < ' + '''' + fecha1 + ''''
                          + ' AND estado = ' + '''' + 'I' + '''' + ' AND dc = ' + '''' + '1' + '''' + ' AND items >= ' + '''' + '000' + '''');
end;

procedure TTEstInstituto.setFecha(f: string);
begin
  s_inicio := False;
  per      := f;
  fecha1   := Copy(f, 4, 4) + Copy(f, 1, 2) + '01';
  fecha2   := Copy(f, 4, 4) + Copy(f, 1, 2) + utiles.ultFechaMes(Copy(f, 1, 2), Copy(f, 4, 4));
end;

procedure TTEstInstituto.verifListado(salida: char);
// Objetivo...: Verificar emisión del Listado
begin
  if not s_inicio then
    begin
      Titulos(salida);   // Sio no se listo nada, tiramos los titulos
      s_inicio := True;
    end;
end;

procedure TTEstInstituto.ListSaldosCobrar(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := sqlSaldosCobrar;
  verifListado(salida);

  List.Linea(0, 0, 'Saldos a Cobrar', 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString) + '  ' + Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString + '   ' + Q.FieldByName('idtitular').AsString + '-' + Q.FieldByName('clavecta').AsString + '  ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(60, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
      List.importe(92, list.lineactual, '', (Q.FieldByName('importe').AsFloat - Q.FieldByName('entrega').AsFloat), 3, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + (Q.FieldByName('importe').AsFloat - Q.FieldByName('entrega').AsFloat);
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(92, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total a Cobrar .....:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(92, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTEstInstituto.ListCobrosEfectuados(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := sqlCobrosEfectuados;
  verifListado(salida);

  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 5', salida, 'S');
  List.Linea(0, 0, 'Ingresos por por Cobros Efectuados', 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString) + ' ' + Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString + '   ' + Q.FieldByName('idtitular').AsString + '-' + Q.FieldByName('clavecta').AsString + ' ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(60, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
      List.importe(92, list.lineactual, '', Q.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + Q.FieldByName('importe').AsFloat;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(92, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Ingresos .....:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(92, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTEstInstituto.ListCuotasVencidas(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := sqlCuotasVencidas;
  verifListado(salida);

  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 5', salida, 'S');
  List.Linea(0, 0, 'Cuotas Vencidas', 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString) + ' ' + Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString + '   ' + Q.FieldByName('idtitular').AsString + '-' + Q.FieldByName('clavecta').AsString + ' ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(60, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
      List.importe(92, list.lineactual, '', (Q.FieldByName('importe').AsFloat - Q.FieldByName('entrega').AsFloat), 3, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + (Q.FieldByName('importe').AsFloat - Q.FieldByName('entrega').AsFloat);
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(92, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total a Cobrar  .....:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(92, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTEstInstituto.Titulos(salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Informe Estadístico -  Período ' + per, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTEstInstituto.Listar;
// Objetivo...: Emitir el informe
begin
  List.FinList;
  s_inicio := False;
end;

{===============================================================================}

function estinst: TTEstInstituto;
begin
  if xestinst = nil then
    xestinst := TTEstInstituto.Create;
  Result := xestinst;
end;

{===============================================================================}

initialization

finalization
  xestinst.Free;

end.
