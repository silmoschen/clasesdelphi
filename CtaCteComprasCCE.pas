unit CtaCteComprasCCE;

interface

uses CCProveedoresCCE, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes, Contnrs;

type

TTCtaCteCompras = class
  Idc, Tipo, Sucursal, Numero, Entidad, Fecha, Estado, Referencia: String;
  Monto: Real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xidc, xtipo, xsucursal, xnumero, xentidad: String): Boolean;
  procedure   Registrar(xidc, xtipo, xsucursal, xnumero, xentidad, xfecha: String; xmonto: Real);
  procedure   Borrar(xidc, xtipo, xsucursal, xnumero, xentidad: String);
  function    setMovimientosPendientes(xdesde, xhasta, xentidad: String): TObjectList;
  function    setMovimientosCancelados(xdesde, xhasta, xentidad: String): TObjectList;

  procedure   SaldarItems(xidc, xtipo, xsucursal, xnumero, xentidad: String);
  procedure   ReactivarItems(xidc, xtipo, xsucursal, xnumero, xentidad: String);

  procedure   RegistrarReferencia(xidc, xtipo, xsucursal, xnumero, xentidad, xreferencia: String);
  procedure   AnularPago(xreferencia: String);

  procedure   Listar(xdesde, xhasta: String; salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  function    setCargarMovimientos(xdesde, xhasta, xentidad: String): TObjectList;
  procedure   CambiarEstadoItems(xidc, xtipo, xsucursal, xnumero, xentidad, xestado: String);
end;

function ctactecom: TTCtaCteCompras;

implementation

var
  xctactecom: TTCtaCteCompras = nil;

constructor TTCtaCteCompras.Create;
begin
  tabla := datosdb.openDB('ctactecompras', '');
end;

destructor TTCtaCteCompras.Destroy;
begin
  inherited Destroy;
end;

function  TTCtaCteCompras.Buscar(xidc, xtipo, xsucursal, xnumero, xentidad: String): Boolean;
// Objetivo...: recuperar una instancia
begin
  if tabla.IndexFieldNames <> 'idc;tipo;sucursal;numero;entidad' then tabla.IndexFieldNames := 'idc;tipo;sucursal;numero;entidad';
  Result := datosdb.Buscar(tabla, 'idc', 'tipo', 'sucursal', 'numero', 'entidad', xidc, xtipo, xsucursal, xnumero, xentidad);
end;

procedure TTCtaCteCompras.Registrar(xidc, xtipo, xsucursal, xnumero, xentidad, xfecha: String; xmonto: Real);
// Objetivo...: registrar una instancia
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xentidad) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idc').AsString      := xidc;
  tabla.FieldByName('tipo').AsString     := xtipo;
  tabla.FieldByName('sucursal').AsString := xsucursal;
  tabla.FieldByName('numero').AsString   := xnumero;
  tabla.FieldByName('entidad').AsString  := xentidad;
  tabla.FieldByName('fecha').AsString    := utiles.sExprFecha2000(xfecha);
  tabla.FieldByName('monto').AsFloat     := xmonto;
  tabla.FieldByName('estado').AsString   := 'P';
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTCtaCteCompras.Borrar(xidc, xtipo, xsucursal, xnumero, xentidad: String);
// Objetivo...: borrar una instancia
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xentidad) then Begin
    tabla.Delete;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

function  TTCtaCteCompras.setMovimientosPendientes(xdesde, xhasta, xentidad: String): TObjectList;
// Objetivo...: devolver una lista de comprobantes pendientes
begin
  datosdb.Filtrar(tabla, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' +  utiles.sExprFecha2000(xhasta) + '''' + ' and entidad = ' + '''' + xentidad + '''' + ' and estado = ' + '''' + 'P' + '''');
  Result := setCargarMovimientos(xdesde, xhasta, xentidad);
end;

function  TTCtaCteCompras.setMovimientosCancelados(xdesde, xhasta, xentidad: String): TObjectList;
// Objetivo...: devolver una lista de comprobantes saldados
begin
  datosdb.Filtrar(tabla, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' +  utiles.sExprFecha2000(xhasta) + '''' + ' and entidad = ' + '''' + xentidad + '''' + ' and estado = ' + '''' + 'C' + '''');
  Result := setCargarMovimientos(xdesde, xhasta, xentidad);
end;

function  TTCtaCteCompras.setCargarMovimientos(xdesde, xhasta, xentidad: String): TObjectList;
// Objetivo...: devolver una lista
var
  l: TObjectList;
  objeto: TTCtaCteCompras;
begin
  l := TObjectList.Create;
  tabla.First;
  while not tabla.Eof do Begin
    objeto            := TTCtaCteCompras.Create;
    objeto.Idc        := tabla.FieldByName('idc').AsString;
    objeto.Tipo       := tabla.FieldByName('tipo').AsString;
    objeto.Sucursal   := tabla.FieldByName('sucursal').AsString;
    objeto.Numero     := tabla.FieldByName('numero').AsString;
    objeto.Fecha      :=  utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
    objeto.Monto      := tabla.FieldByName('monto').AsFloat;
    objeto.Referencia := tabla.FieldByName('referencia').AsString;
    l.Add(objeto);
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);    
  Result := l;
end;

procedure TTCtaCteCompras.SaldarItems(xidc, xtipo, xsucursal, xnumero, xentidad: String);
// Objetivo...: saldar items
begin
  CambiarEstadoItems(xidc, xtipo, xsucursal, xnumero, xentidad, 'C');
end;

procedure TTCtaCteCompras.ReactivarItems(xidc, xtipo, xsucursal, xnumero, xentidad: String);
// Objetivo...: reactivar items
begin
  CambiarEstadoItems(xidc, xtipo, xsucursal, xnumero, xentidad, 'P');
end;

procedure TTCtaCteCompras.CambiarEstadoItems(xidc, xtipo, xsucursal, xnumero, xentidad, xestado: String);
// Objetivo...: modificar estado items
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xentidad) then Begin
    tabla.Edit;
    tabla.FieldByName('estado').AsString := xestado;
    if xestado = 'P' then tabla.FieldByName('referencia').AsString := '';
    try
      tabla.Post
     except
      tabla.Cancel
    end;
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTCtaCteCompras.RegistrarReferencia(xidc, xtipo, xsucursal, xnumero, xentidad, xreferencia: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xentidad) then Begin
    tabla.Edit;
    tabla.FieldByName('referencia').AsString := xreferencia;
    tabla.FieldByName('estado').AsString     := 'C';
    try
      tabla.Post
     except
      tabla.Cancel
    end;
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTCtaCteCompras.AnularPago(xreferencia: String);
// objetivo...: Anular Pago
var
  r: TQuery;
Begin
  r := datosdb.tranSQL('select * from ' + tabla.TableName + ' where referencia = ' + '''' + xreferencia + '''');
  r.Open;
  while not r.Eof do Begin
    ReactivarItems(r.FieldByName('idc').AsString, r.FieldByName('tipo').AsString, r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString, r.FieldByName('entidad').AsString);
    r.Next;
  end;
  r.Close; r.Free;
end;

procedure TTCtaCteCompras.Listar(xdesde, xhasta: String; salida: char);
// Objetivo...: Generar Informe
var
  ldat: Boolean;
  totales: array[1..5] of Real;
Begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Operaciones Pendientes de Pago - Lapso: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, list.Lineactual, 'Comprobante', 2, 'Arial, cursiva, 8');
  List.Titulo(25, list.Lineactual, 'Proveedor', 3, 'Arial, cursiva, 8');
  List.Titulo(90, list.Lineactual, 'Monto', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  datosdb.Filtrar(tabla, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and estado = ' + '''' + 'P' + '''');
  tabla.First; ldat := False; totales[1] := 0;
  while not tabla.Eof do Begin
    list.Linea(0, 0, utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(8, list.Lineactual, tabla.FieldByName('idc').AsString, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(11, list.Lineactual, tabla.FieldByName('tipo').AsString + ' ' + tabla.FieldByName('sucursal').AsString + '-' + tabla.FieldByName('numero').AsString, 3, 'Arial, normal, 8', salida, 'N');
    proveedor.getDatos(tabla.FieldByName('entidad').AsString);
    list.Linea(25, list.Lineactual, proveedor.nombre, 4, 'Arial, normal, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', tabla.FieldByName('monto').AsFloat, 5, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S');
    totales[1] := totales[1] + tabla.FieldByName('monto').AsFloat;
    ldat := True;
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);

  if totales[1] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Total a Pagar:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[1], 4, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, '', 5, 'Arial, negrita, 8', salida, 'S');
  end;

  if not ldat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');

  list.FinList;
end;

procedure TTCtaCteCompras.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
  proveedor.conectar;
end;

procedure TTCtaCteCompras.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
  proveedor.desconectar;
end;

{===============================================================================}

function ctactecom: TTCtaCteCompras;
begin
  if xctactecom = nil then
    xctactecom := TTCtaCteCompras.Create;
  Result := xctactecom;
end;

{===============================================================================}

initialization

finalization
  xctactecom.Free;

end.
