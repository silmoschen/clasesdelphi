unit CCuentasCaidasCIC;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CAfectadosCIC, CSociosCIC,
     Contnrs;

type

TTCuentasCaidas = class
  Idregistro, Nrodoc, Idsocio, FechaAf, Observac, FePago, Tipo, Sucursal, Numero: String;
  Monto, Comision: Real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xidregistro: String): Boolean;
  procedure   Registrar(xidregistro, xnrodoc, xidsocio, xfechaaf, xobservac: String; xmonto: Real);
  procedure   Borrar(xidregistro: String);
  procedure   getDatos(xidregistro: String);

  function    setCuentasPendientes(xperiodo: String): TObjectList;
  function    setCuentasAfectado(xnrodoc: String): TObjectList;
  function    setCobrosRealizados(xnrodoc: String): TObjectList;

  procedure   RegistrarCobro(xidregistro, xfecha, xtipo, xsucursal, xnumero: String; xcomision: Real);
  procedure   BorrarCobro(xidregistro: String);

  procedure   ListarCobrosPendientes(xdesde, xhasta: String; salida: char);
  procedure   ListarCobrosRealizados(xdesde, xhasta: String; salida: char);

  procedure   DefinirConceptoTransferenciaCaja(xidconcepto: String);
  function    setConceptoTransferenciaCaja: String;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  listdat: Boolean;
  mc: TTable;
  totales: array[1..2] of Real;
  function    setDatosCobro(xnrodoc: String; xmodo: ShortInt): TObjectList;
end;

function cuentacaida: TTCuentasCaidas;

implementation

var
  xcuentacaida: TTCuentasCaidas = nil;

constructor TTCuentasCaidas.Create;
begin
  tabla := datosdb.openDB('ctascaidas', '');
  mc    := datosdb.openDB('movcaja', '');
end;

destructor TTCuentasCaidas.Destroy;
begin
  inherited Destroy;
end;

function  TTCuentasCaidas.Buscar(xidregistro: String): Boolean;
// Objetivo...: recuperar una instancia
begin
  if tabla.IndexFieldNames <> 'Idregistro' then tabla.IndexFieldNames := 'Idregistro';
  Result := tabla.FindKey([xidregistro]);
end;

procedure TTCuentasCaidas.Registrar(xidregistro, xnrodoc, xidsocio, xfechaaf, xobservac: String; xmonto: Real);
// Objetivo...: registrar una instancia
begin
  if Buscar(xidregistro) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idregistro').AsString := xidregistro;
  tabla.FieldByName('nrodoc').AsString     := xnrodoc;
  tabla.FieldByName('idsocio').AsString    := xidsocio;
  tabla.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfechaaf);
  tabla.FieldByName('observac').AsString   := xobservac;
  tabla.FieldByName('monto').AsFloat       := xmonto;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTCuentasCaidas.Borrar(xidregistro: String);
// Objetivo...: borrar una instancia
begin
  if Buscar(xidregistro) then Begin
    tabla.Delete;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTCuentasCaidas.getDatos(xidregistro: String);
// Objetivo...: cargar una instancia
begin
  if Buscar(xidregistro) then Begin
    idregistro := tabla.FieldByName('idregistro').AsString;
    nrodoc     := tabla.FieldByName('nrodoc').AsString;
    idsocio    := tabla.FieldByName('idsocio').AsString;
    fechaaf    := utiles.sFormatoFecha(tabla.FieldByName('fechaaf').AsString);
    observac   := tabla.FieldByName('observac').AsString;
    monto      := tabla.FieldByName('monto').AsFloat;
  end else Begin
    idregistro := ''; nrodoc := ''; idsocio := ''; fechaaf := ''; observac := ''; monto := 0;
  end;
end;

function  TTCuentasCaidas.setCuentasPendientes(xperiodo: String): TObjectList;
// Objetivo...: devolver una collection de cuentas pendientes
var
  l: TObjectList;
  objeto: TTCuentasCaidas;
  f: String;
begin
  f := Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2);
  l := TObjectList.Create;
  datosdb.Filtrar(tabla, 'fecha >= ' + '''' + f + '01' + '''' + ' and fecha <= ' + '''' + f + '31' + '''');
  tabla.First;
  while not tabla.Eof do Begin
    objeto := TTCuentasCaidas.Create;
    objeto.Idregistro  := tabla.FieldByName('idregistro').AsString;
    objeto.Nrodoc      := tabla.FieldByName('nrodoc').AsString;
    objeto.Idsocio     := tabla.FieldByName('idsocio').AsString;
    objeto.FechaAf     := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
    objeto.Observac    := tabla.FieldByName('observac').AsString;
    objeto.Monto       := tabla.FieldByName('monto').AsFloat;
    l.Add(objeto);
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);
  Result := l;
end;

function TTCuentasCaidas.setDatosCobro(xnrodoc: String; xmodo: ShortInt): TObjectList;
// Objetivo...: devolver una collection de cuentas de un afectado
var
  l: TObjectList;
  objeto: TTCuentasCaidas;
  incluye: Boolean;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(tabla, 'nrodoc = ' + '''' + xnrodoc + '''');
  tabla.First;
  while not tabla.Eof do Begin
    incluye := False;
    if xmodo = 1 then
      if Length(Trim(tabla.FieldByName('fepago').AsString)) < 8 then incluye := True;
    if xmodo = 2 then
      if Length(Trim(tabla.FieldByName('fepago').AsString)) = 8 then incluye := True;
    if incluye then Begin
      objeto := TTCuentasCaidas.Create;
      objeto.Idregistro  := tabla.FieldByName('idregistro').AsString;
      objeto.Nrodoc      := tabla.FieldByName('nrodoc').AsString;
      objeto.Idsocio     := tabla.FieldByName('idsocio').AsString;
      objeto.FechaAf     := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
      objeto.FePago      := utiles.sFormatoFecha(tabla.FieldByName('fepago').AsString);
      objeto.Observac    := tabla.FieldByName('observac').AsString;
      objeto.Monto       := tabla.FieldByName('monto').AsFloat;
      objeto.Comision    := tabla.FieldByName('comision').AsFloat;
      objeto.Tipo        := tabla.FieldByName('tipo').AsString;
      objeto.Sucursal    := tabla.FieldByName('sucursal').AsString;
      objeto.Numero      := tabla.FieldByName('numero').AsString;
      l.Add(objeto);
    end;
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);
  Result := l;
end;

function  TTCuentasCaidas.setCuentasAfectado(xnrodoc: String): TObjectList;
// Objetivo...: devolver una collection de cuentas de un afectado
Begin
  Result := setDatosCobro(xnrodoc, 1);
end;

function TTCuentasCaidas.setCobrosRealizados(xnrodoc: String): TObjectList;
// Objetivo...: devolver una collection de cuentas de un afectado
Begin
  Result := setDatosCobro(xnrodoc, 2);
end;

procedure TTCuentasCaidas.RegistrarCobro(xidregistro, xfecha, xtipo, xsucursal, xnumero: String; xcomision: Real);
// Objetivo...: cerrar tablas de persistencia
begin
  if Buscar(xidregistro) then Begin
    tabla.Edit;
    tabla.FieldByName('fepago').AsString   := utiles.sExprFecha2000(xfecha);
    tabla.FieldByName('tipo').AsString     := xtipo;
    tabla.FieldByName('sucursal').AsString := xsucursal;
    tabla.FieldByName('numero').AsString   := xnumero;
    tabla.FieldByName('comision').AsFloat  := xcomision;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTCuentasCaidas.BorrarCobro(xidregistro: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if Buscar(xidregistro) then Begin
    tabla.Edit;
    tabla.FieldByName('fepago').AsString := '';
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTCuentasCaidas.ListarCobrosPendientes(xdesde, xhasta: String; salida: char);
// Objetivo...: cerrar tablas de persistencia
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Cobros Pendientes en el Lapso: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, List.lineactual, 'Documento/Nombre del Afectado', 2, 'Arial, cursiva, 8');
  List.Titulo(50, List.lineactual, 'Entidad que lo Afecta', 3, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Monto', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  listdat := False; totales[1] := 0;
  datosdb.Filtrar(tabla, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  tabla.First;
  while not tabla.Eof do Begin
    if Length(Trim(tabla.FieldByName('fepago').AsString)) = 0 then Begin
      afectado.getDatos(tabla.FieldByName('nrodoc').AsString);
      socio.getDatos(tabla.FieldByName('idsocio').AsString);
      list.Linea(0, 0, utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(8, list.Lineactual, tabla.FieldByName('nrodoc').AsString + '  ' + afectado.nombre, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(50, list.Lineactual, socio.nombre, 3, 'Arial, normal, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', tabla.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
      totales[1] := totales[1] + tabla.FieldByName('monto').AsFloat;
    end;
    tabla.Next;
  end;

  datosdb.QuitarFiltro(tabla);

  if totales[1] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'N');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  end else
    list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');

  list.FinList;
end;

procedure TTCuentasCaidas.ListarCobrosRealizados(xdesde, xhasta: String; salida: char);
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Cobros Realizados en el Lapso: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, List.lineactual, 'Documento/Nombre del Afectado', 2, 'Arial, cursiva, 8');
  List.Titulo(50, List.lineactual, 'Entidad que lo Afecta', 3, 'Arial, cursiva, 8');
  List.Titulo(0, List.lineactual, 'F.Cobro', 1, 'Arial, cursiva, 8');
  List.Titulo(8, List.lineactual, 'Comprobante', 2, 'Arial, cursiva, 8');
  List.Titulo(75, List.lineactual, 'Monto', 3, 'Arial, cursiva, 8');
  List.Titulo(88, List.lineactual, 'Comisión', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  listdat := False; totales[1] := 0; totales[2] := 0;
  datosdb.Filtrar(tabla, 'fepago >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fepago <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  tabla.First;
  while not tabla.Eof do Begin
    afectado.getDatos(tabla.FieldByName('nrodoc').AsString);
    socio.getDatos(tabla.FieldByName('idsocio').AsString);
    list.Linea(0, 0, utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(8, list.Lineactual, tabla.FieldByName('nrodoc').AsString + '  ' + afectado.nombre, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(50, list.Lineactual, socio.nombre, 3, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, utiles.sFormatoFecha(tabla.FieldByName('fepago').AsString), 1, 'Arial, cursiva, 8', salida, 'N');
    list.Linea(8, list.Lineactual, tabla.FieldByName('tipo').AsString + ' ' + tabla.FieldByName('sucursal').AsString + '-' + tabla.FieldByName('numero').AsString, 2, 'Arial, cursiva, 8', salida, 'N');
    list.importe(80, list.Lineactual, '', tabla.FieldByName('monto').AsFloat, 3, 'Arial, cursiva, 8');
    list.importe(95, list.Lineactual, '', tabla.FieldByName('comision').AsFloat, 4, 'Arial, cursiva, 8');
    list.Linea(95, list.Lineactual, '', 5, 'Arial, cursiva, 8', salida, 'S');
    totales[1] := totales[1] + tabla.FieldByName('monto').AsFloat;
    totales[2] := totales[2] + tabla.FieldByName('comision').AsFloat;
    tabla.Next;
  end;

  datosdb.QuitarFiltro(tabla);

  if totales[1] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'N');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(80, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
  end else
    list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');

  list.FinList;
end;

procedure TTCuentasCaidas.DefinirConceptoTransferenciaCaja(xidconcepto: String);
// Objetivo...: Definir Concepto de Transferencia
begin
  if mc.FindKey(['002']) then mc.Edit else mc.Append;
  mc.FieldByName('codmov').AsString := xidconcepto;
  try
    mc.Post
   except
    mc.Cancel
  end;
  datosdb.closeDB(mc); mc.Open;
end;

function  TTCuentasCaidas.setConceptoTransferenciaCaja: String;
// Objetivo...: Recuperar Concepto de Transferencia
begin
  if mc.FindKey(['002']) then Result := mc.FieldByName('codmov').AsString else Result := '';
end;

procedure TTCuentasCaidas.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    if not mc.Active then mc.Open;
  end;
  Inc(conexiones);
  afectado.conectar;
end;

procedure TTCuentasCaidas.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(mc);
  end;
  afectado.desconectar;
end;

{===============================================================================}

function cuentacaida: TTCuentasCaidas;
begin
  if xcuentacaida = nil then
    xcuentacaida := TTCuentasCaidas.Create;
  Result := xcuentacaida;
end;

{===============================================================================}

initialization

finalization
  xcuentacaida.Free;

end.
