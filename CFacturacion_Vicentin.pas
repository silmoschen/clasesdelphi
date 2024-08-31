unit CFacturacion_Vicentin;

interface

uses CCHistoriaDieteticaVicentin, CMotivosConsulta_Vicentin, CBDT, SysUtils, DBTables,
     CUtiles, CListar, CIDBFM, Classes, CAtencionPacientes_Vicentin;

type

TTFacturacion = class
  factura, gastos: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xfecha, xitems: String): Boolean;
  procedure   Registrar(xfecha, xitems, xcodpac, xnombre, xcodmot, xidconsulta, xhora, xadeuda: String; xmonto, xdescuento: Real; xcantitems: Integer);
  procedure   Borrar(xfecha: String);
  function    setItemsFacturacion(xfecha: String): TStringList;
  function    setItemsFacturacionFecha(xdesde, xhasta: String): TStringList;
  function    setItemsFacturacionPaciente(xcodpac: String): TStringList;
  procedure   RegistrarMontoAFavor(xperiodo, xitems: String; xmonto: Real);

  function    BuscarGasto(xperiodo, xitems: String): Boolean;
  procedure   RegistrarGasto(xfecha, xitems, xperiodo, xconcepto: String; xmonto: Real; xcantitems: Integer);
  procedure   BorrarGasto(xperiodo: String);
  function    setGastos(xperiodo: String): TStringList;

  procedure   EstablecerQuitarDeuda(xperiodo, xitems, xestado: String);

  procedure   ListarDetalleFact(xdfecha, xhfecha, xdesdehora, xhastahora, xatencion: String; salida: char);
  procedure   ListarResumenFact(xdfecha, xhfecha: String; salida: char);
  procedure   ListarDeudas(salida: char);

  function    setDeudaPaciente(xcodpac: String): Real;

  procedure   Depurar(xfecha: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  idanter: String;
  totales: array[1..5] of Real;
  procedure   ListarResumen(salida: char);
  procedure   ListarDetalleGastos(xperiodo: String; salida: char);
end;

function facturacionpac: TTFacturacion;

implementation

var
  xfacturacion: TTFacturacion = nil;

constructor TTFacturacion.Create;
begin
  factura := datosdb.openDB('consultas_pacientes', '');
  gastos  := datosdb.openDB('gastos', '');
end;

destructor TTFacturacion.Destroy;
begin
  inherited Destroy;
end;

function  TTFacturacion.Buscar(xfecha, xitems: String): Boolean;
// Objetivo...: Buscar Instancia
begin
  Result := datosdb.Buscar(factura, 'Fecha', 'Items', utiles.sExprFecha2000(xfecha), xitems);
end;

procedure TTFacturacion.Registrar(xfecha, xitems, xcodpac, xnombre, xcodmot, xidconsulta, xhora, xadeuda: String; xmonto, xdescuento: Real; xcantitems: Integer);
// Objetivo...: Registrar Instancia
begin
  if Buscar(xfecha, xitems) then factura.Edit else factura.Append;
  factura.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfecha);
  factura.FieldByName('items').AsString      := xitems;
  factura.FieldByName('codpac').AsString     := xcodpac;
  factura.FieldByName('nombre').AsString     := xnombre;
  factura.FieldByName('idconsulta').AsString := xcodmot;
  factura.FieldByName('idatencion').AsString := xidconsulta;
  factura.FieldByName('hora').AsString       := xhora;
  factura.FieldByName('adeuda').AsString     := xadeuda;
  factura.FieldByName('monto').AsFloat       := xmonto;
  factura.FieldByName('descuento').AsFloat   := xdescuento;
  try
    factura.Post
   except
    factura.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL('delete from ' + factura.TableName + ' where fecha = ' + '''' + utiles.sExprFecha2000(xfecha) + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(factura); factura.Open;
  end;
end;

procedure TTFacturacion.Borrar(xfecha: String);
// Objetivo...: Borrar las instancias de una fecha
begin
  datosdb.tranSQL('delete from ' + factura.TableName + ' where fecha = ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
  datosdb.closeDB(factura); factura.Open;
end;

function TTFacturacion.setItemsFacturacion(xfecha: String): TStringList;
// Objetivo...: Recuperar Items Facturación a una Fecha
var
  l: TStringList;
  d: String;
begin
  l := TStringList.Create;
  d := utiles.ultFechaMes(Copy(xfecha, 4, 2), Copy(utiles.sExprFecha2000(xfecha), 1, 4)) + Copy(xfecha, 3, 6);
  datosdb.Filtrar(factura, 'fecha >= ' + '''' + utiles.sExprFecha2000(xfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
  factura.First;
  while not factura.Eof do Begin
    l.Add(factura.FieldByName('items').AsString + factura.FieldByName('codpac').AsString + factura.FieldByName('idconsulta').AsString + factura.FieldByName('nombre').AsString + ';1' + factura.FieldByName('monto').AsString + ';2' + factura.FieldByName('descuento').AsString + ';3' + factura.FieldByName('idatencion').AsString + factura.FieldByName('hora').AsString + factura.FieldByName('adeuda').AsString + factura.FieldByName('afavor').AsString);
    factura.Next;
  end;
  datosdb.QuitarFiltro(factura);
  Result := l;
end;

function TTFacturacion.setItemsFacturacionFecha(xdesde, xhasta: String): TStringList;
// Objetivo...: Recuperar Items Facturación en un Rango de Fechas
var
  l: TStringList;
begin
  l := TStringList.Create;
  datosdb.Filtrar(factura, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  factura.First;
  while not factura.Eof do Begin
    l.Add(factura.FieldByName('items').AsString + factura.FieldByName('codpac').AsString + factura.FieldByName('idconsulta').AsString + factura.FieldByName('nombre').AsString + ';1' + factura.FieldByName('monto').AsString + ';2' + factura.FieldByName('descuento').AsString + ';3' + factura.FieldByName('idatencion').AsString + factura.FieldByName('hora').AsString + utiles.sFormatoFecha(factura.FieldByName('fecha').AsString) + factura.FieldByName('adeuda').AsString);
    factura.Next;
  end;
  datosdb.QuitarFiltro(factura);
  Result := l;
end;

function TTFacturacion.setItemsFacturacionPaciente(xcodpac: String): TStringList;
// Objetivo...: Recuperar Items Facturación de un Paciente
var
  l: TStringList;
begin
  l := TStringList.Create;
  datosdb.Filtrar(factura, 'codpac = ' + '''' + xcodpac + '''');
  factura.First;
  while not factura.Eof do Begin
    l.Add(factura.FieldByName('items').AsString + factura.FieldByName('codpac').AsString + factura.FieldByName('idconsulta').AsString + factura.FieldByName('nombre').AsString + ';1' + factura.FieldByName('monto').AsString + ';2' + factura.FieldByName('descuento').AsString + ';3' + factura.FieldByName('idatencion').AsString + factura.FieldByName('hora').AsString + utiles.sFormatoFecha(factura.FieldByName('fecha').AsString) + factura.FieldByName('adeuda').AsString);
    factura.Next;
  end;
  datosdb.QuitarFiltro(factura);
  Result := l;
end;

procedure TTFacturacion.RegistrarMontoAFavor(xperiodo, xitems: String; xmonto: Real);
// Objetivo...: Recuperar Gastos
begin
  if Buscar(xperiodo, xitems) then Begin
    factura.Edit;
    factura.FieldByName('afavor').AsFloat := xmonto;
    try
      factura.Post
     except
      factura.Cancel
    end;
    datosdb.refrescar(factura);
  end;
end;


function  TTFacturacion.BuscarGasto(xperiodo, xitems: String): Boolean;
// Objetivo...: Buscar una Instancia
begin
  if gastos.IndexFieldNames <> 'Periodo;Items' then gastos.IndexFieldNames := 'Periodo;Items';
  Result := datosdb.Buscar(gastos, 'periodo', 'items', xperiodo, xitems);
end;

procedure TTFacturacion.RegistrarGasto(xfecha, xitems, xperiodo, xconcepto: String; xmonto: Real; xcantitems: Integer);
// Objetivo...: Registrar una Instancia
begin
  if BuscarGasto(xperiodo, xitems) then gastos.Edit else gastos.Append;
  gastos.FieldByName('periodo').AsString  := xperiodo;
  gastos.FieldByName('items').AsString    := xitems;
  gastos.FieldByName('fecha').AsString    := utiles.sExprFecha2000(xfecha);
  gastos.FieldByName('concepto').AsString := xconcepto;
  gastos.FieldByName('monto').AsFloat     := xmonto;
  try
    gastos.Post
   except
    gastos.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL('delete from gastos where periodo = ' + '''' + xperiodo + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(gastos); gastos.Open;
  end;
end;

procedure TTFacturacion.BorrarGasto(xperiodo: String);
// Objetivo...: Borrar Gasto
begin
  datosdb.tranSQL('delete from gastos where periodo = ' + '''' + xperiodo + '''');
  datosdb.refrescar(gastos);
end;

function  TTFacturacion.setGastos(xperiodo: String): TStringList;
// Objetivo...: Recuperar Gastos
var
  l: TStringList;
Begin
  l := TStringList.Create;
  gastos.IndexFieldNames := 'Fecha';
  datosdb.Filtrar(gastos, 'periodo = ' + '''' + xperiodo + '''');
  gastos.First;
  while not gastos.Eof do Begin
    l.Add(gastos.FieldByName('fecha').AsString + gastos.FieldByName('items').AsString + gastos.FieldByName('periodo').AsString + gastos.FieldByName('concepto').AsString + ';1' + gastos.FieldByName('monto').AsString);
    gastos.Next;
  end;
  datosdb.QuitarFiltro(gastos);
  gastos.IndexFieldNames := 'Periodo;Items';
  Result := l;
end;

procedure TTFacturacion.EstablecerQuitarDeuda(xperiodo, xitems, xestado: String);
// Objetivo...: Informe detallado
Begin
  if Buscar(xperiodo, xitems) then Begin
    factura.Edit;
    factura.FieldByName('adeuda').AsString := xestado;
    if xestado <> 'F' then factura.FieldByName('afavor').AsFloat := 0;
    try
      factura.Post
     except
      factura.Cancel
    end;
    datosdb.refrescar(factura);
  end;
end;

procedure TTFacturacion.ListarDetalleFact(xdfecha, xhfecha, xdesdehora, xhastahora, xatencion: String; salida: char);
// Objetivo...: Informe detallado
var
  l: Boolean;
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Planilla de Facturación - Período: ' + xdfecha + '-' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha / Hora', 1, 'Arial, cursiva, 8');
  List.Titulo(15, list.Lineactual, 'Paciente', 2, 'Arial, cursiva, 8');
  List.Titulo(50, list.Lineactual, 'Mot.', 3, 'Arial, cursiva, 8');
  List.Titulo(60, list.Lineactual, 'Monto', 4, 'Arial, cursiva, 8');
  List.Titulo(68, list.Lineactual, 'Descuento', 5, 'Arial, cursiva, 8');
  List.Titulo(86, list.Lineactual, 'Total', 6, 'Arial, cursiva, 8');
  List.Titulo(92, list.Lineactual, 'Atención', 7, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  totales[1] := 0; totales[2] := 0; totales[3] := 0;
  datosdb.Filtrar(factura, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
  factura.First;
  while not factura.Eof do Begin
    l := False;
    if (Copy(xdesdehora, 1, 2) = '00') and (xatencion = '000') then l := True;
    if (Copy(factura.FieldByName('hora').AsString, 1, 2) >= Copy(xdesdehora, 1, 2)) and (Copy(factura.FieldByName('hora').AsString, 1, 2) <= Copy(xhastahora, 1, 2)) and (factura.FieldByName('idatencion').AsString = xatencion) then l := True;
    if xatencion = '000' then
      if (Copy(factura.FieldByName('hora').AsString, 1, 2) >= Copy(xdesdehora, 1, 2)) and (Copy(factura.FieldByName('hora').AsString, 1, 2) <= Copy(xhastahora, 1, 2)) then l := True;

    if l then Begin
      atencionpac.getDatos(factura.FieldByName('idatencion').AsString);
      list.Linea(0, 0, utiles.sFormatoFecha(factura.FieldByName('fecha').AsString) + ' ' + factura.FieldByName('hora').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(15, list.Lineactual, factura.FieldByName('nombre').AsString, 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(50, list.Lineactual, factura.FieldByName('idconsulta').AsString, 4, 'Arial, normal, 8', salida, 'N');
      list.Importe(65, list.Lineactual, '', factura.FieldByName('monto').AsFloat, 5, 'Arial, normal, 8');
      list.Importe(75, list.Lineactual, '', factura.FieldByName('descuento').AsFloat, 6, 'Arial, normal, 8');
      list.Importe(90, list.Lineactual, '', factura.FieldByName('monto').AsFloat - factura.FieldByName('descuento').AsFloat, 7, 'Arial, normal, 8');
      list.Linea(92, list.Lineactual, atencionpac.Descrip, 8, 'Arial, normal, 8', salida, 'S');
      totales[1] := totales[1] + factura.FieldByName('monto').AsFloat;
      totales[2] := totales[2] + factura.FieldByName('descuento').AsFloat;
      totales[3] := totales[3] + (factura.FieldByName('monto').AsFloat - factura.FieldByName('descuento').AsFloat);
    end;
    factura.Next;
  end;
  datosdb.QuitarFiltro(factura);

  if totales[3] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotales: ', 1, 'Arial, negrita, 8', salida, 'N');
    list.Importe(65, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.Importe(75, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 8');
    list.Importe(90, list.Lineactual, '', totales[3], 4, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, '', 5, 'Arial, negrita, 8', salida, 'S');
  end else
    list.Linea(0, 0, 'No Existen Datos para Listar', 1, 'Arial, normal, 9', salida, 'S');
  list.FinList;
end;

procedure TTFacturacion.ListarResumenFact(xdfecha, xhfecha: String; salida: char);
// Objetivo...: Informe Resumen
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Resumen de Facturación - Período: ' + xdfecha + '-' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Concepto', 1, 'Arial, cursiva, 8');
  List.Titulo(73, list.Lineactual, 'Cantidad', 2, 'Arial, cursiva, 8');
  List.Titulo(91, list.Lineactual, 'Monto', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  totales[1] := 0; totales[2] := 0; totales[3] := 0;
  factura.IndexFieldNames := 'Idconsulta';
  datosdb.Filtrar(factura, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
  factura.First;
  idanter := factura.FieldByName('idconsulta').AsString;
  while not factura.Eof do Begin
    if factura.FieldByName('idconsulta').AsString <> idanter then Begin
      ListarResumen(salida);
      idanter := factura.FieldByName('idconsulta').AsString;
    end;
    totales[1] := totales[1] + 1;
    totales[2] := totales[2] + (factura.FieldByName('monto').AsFloat - factura.FieldByName('descuento').AsFloat);
    factura.Next;
  end;
  datosdb.QuitarFiltro(factura);
  factura.IndexFieldNames := 'Fecha;Items';

  ListarResumen(salida);
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(95, list.Lineactual, '', '------------------------', 2, 'Arial, normal, 8');
  list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Subtotal Ingresos:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(95, list.Lineactual, '', totales[3], 2, 'Arial, negrita, 8');
  list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');


  ListarDetalleGastos(Copy(xdfecha, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xdfecha), 1, 4), salida);
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(95, list.Lineactual, '', '------------------------', 2, 'Arial, normal, 8');
  list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Subtotal Egresos:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(95, list.Lineactual, '', totales[4], 2, 'Arial, negrita, 8');
  list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(95, list.Lineactual, '', '------------------------', 2, 'Arial, normal, 8');
  list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Utilidad Neta:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(95, list.Lineactual, '', totales[3] - totales[4], 2, 'Arial, negrita, 8');
  list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.FinList;
end;

procedure TTFacturacion.ListarResumen(salida: char);
// Objetivo...: Informe Resumen
Begin
  motivocons.getDatos(idanter);
  list.Linea(0, 0, idanter + '   ' + motivocons.Descrip, 1, 'Arial, normal, 8', salida, 'N');
  list.Importe(80, list.Lineactual, '', totales[1], 2, 'Arial, normal, 8');
  list.Importe(95, list.Lineactual, '', totales[2], 3, 'Arial, normal, 8');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
  totales[3] := totales[3] + totales[2];
  totales[1] := 0; totales[2] := 0;
end;

procedure TTFacturacion.ListarDetalleGastos(xperiodo: String; salida: char);
// Objetivo...: Informe Resumen
var
  i, p: Integer;
  l: TStringList;
Begin
  totales[4] := 0;
  list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
  l := setGastos(xperiodo);
  for i := 1 to l.Count do Begin
    p := Pos(';1', l.Strings[i-1]);
    list.Linea(0, 0, utiles.sFormatoFecha(Copy(l.Strings[i-1], 1, 8)) + '  ' + Copy(l.Strings[i-1], 19, p-19), 1, 'Arial, normal, 8', salida, 'N');
    list.Importe(95, list.Lineactual, '', StrToFloat(Trim(Copy(l.Strings[i-1], p+2, 15))), 3, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
    totales[4] := totales[4] + StrToFloat(Trim(Copy(l.Strings[i-1], p+2, 15)));
  end;
end;

procedure TTFacturacion.ListarDeudas(salida: char);
// Objetivo...: Listar Deudas
var
  f: String;
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Informe Detallado de Deudas', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, list.Lineactual, 'Paciente', 2, 'Arial, cursiva, 8');
  List.Titulo(37, list.Lineactual, 'Teléfono', 3, 'Arial, cursiva, 8');
  List.Titulo(60, list.Lineactual, 'Atención', 4, 'Arial, cursiva, 8');
  List.Titulo(88, list.Lineactual, 'Deuda', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  totales[1] := 0; totales[2] := 0;
  datosdb.Filtrar(factura, 'adeuda = ' + '''' + 'S' + '''' + ' or adeuda = ' + '''' + 'F' + '''');
  factura.IndexFieldNames := 'Nombre';
  factura.First;
  while not factura.Eof do Begin
    if factura.FieldByName('adeuda').AsString = 'F' then f := 'Arial, negrita, 8' else f := 'Arial, normal, 8';
    atencionpac.getDatos(factura.FieldByName('idconsulta').AsString);
    historiadiet.getDatos(factura.FieldByName('codpac').AsString);
    list.Linea(0, 0, utiles.sFormatoFecha(factura.FieldByName('fecha').AsString), 1, f, salida, 'N');
    list.Linea(8, list.Lineactual, factura.FieldByName('nombre').AsString, 2, f, salida, 'N');
    list.Linea(37, list.Lineactual, historiadiet.Telefono, 3, f, salida, 'N');
    list.Linea(60, list.Lineactual, atencionpac.Descrip, 4, f, salida, 'N');
    if factura.FieldByName('afavor').AsFloat = 0 then list.importe(93, list.Lineactual, '', factura.FieldByName('monto').AsFloat, 5, f) else
      list.importe(93, list.Lineactual, '', factura.FieldByName('afavor').AsFloat, 5, f);
    if factura.FieldByName('adeuda').AsString = 'S' then Begin
      list.Linea(94, list.Lineactual, '', 6, f, salida, 'S');
      if factura.FieldByName('afavor').AsFloat = 0 then totales[1] := totales[1] + factura.FieldByName('monto').AsFloat else
        totales[1] := totales[1] + factura.FieldByName('afavor').AsFloat;
    end;
    if factura.FieldByName('adeuda').AsString = 'F' then Begin
      list.Linea(94, list.Lineactual, 'A Favor', 6, f, salida, 'S');
      if factura.FieldByName('afavor').AsFloat = 0 then totales[2] := totales[2] + factura.FieldByName('monto').AsFloat else
        if factura.FieldByName('afavor').AsFloat > 0 then totales[2] := totales[2] + factura.FieldByName('afavor').AsFloat;
    end;

    factura.Next;
  end;
  datosdb.QuitarFiltro(factura);
  factura.IndexFieldNames := 'Fecha;Items';

  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(75, list.Lineactual, '', '------------------------', 2, 'Arial, normal, 8');
  list.derecha(95, list.Lineactual, '', '------------------------', 3, 'Arial, normal, 8');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Total a Favor / Deuda:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(75, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 8');
  list.importe(94, list.Lineactual, '', totales[1], 3, 'Arial, negrita, 8');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');

  list.FinList;
end;

function  TTFacturacion.setDeudaPaciente(xcodpac: String): Real;
// Objetivo...: cerrar tablas de persistencia
var
  t: Real;
  estado: Boolean;
begin
  estado := factura.Active;
  if not factura.Active then factura.Open;
  factura.IndexFieldNames := 'codpac'; t:= 0;
  if factura.FindKey([xcodpac]) then Begin
    while not factura.Eof do Begin
      if factura.FieldByName('codpac').AsString <> xcodpac then Break;
      if factura.FieldByName('adeuda').AsString = 'S' then t := t - factura.FieldByName('afavor').AsFloat;
      if factura.FieldByName('adeuda').AsString = 'F' then t := t + factura.FieldByName('afavor').AsFloat;
      factura.Next;
    end;
  end;
  factura.IndexFieldNames := 'fecha;items';
  factura.Active := estado;
  Result := t;
end;

procedure TTFacturacion.Depurar(xfecha: String);
// Objetivo...: cerrar tablas de persistencia
begin
  datosdb.tranSQL('delete from consultas_pacientes where fecha <= ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
  datosdb.tranSQL('delete from gastos where fecha <= ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
end;

procedure TTFacturacion.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not factura.Active then factura.Open;
    if not gastos.Active then gastos.Open;
  end;
  Inc(conexiones);
  historiadiet.conectarHD;
  motivocons.conectar;
  atencionpac.conectar;
end;

procedure TTFacturacion.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(factura);
    datosdb.closeDB(gastos);
  end;
  historiadiet.desconectarHD;
  motivocons.desconectar;
  atencionpac.desconectar;
end;

{===============================================================================}

function facturacionpac: TTFacturacion;
begin
  if xfacturacion = nil then
    xfacturacion := TTFacturacion.Create;
  Result := xfacturacion;
end;

{===============================================================================}

initialization

finalization
  xfacturacion.Free;

end.
