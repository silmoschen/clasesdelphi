unit CInformesCCI;

interface

uses CSociosCIC, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Contnrs, CBancos,
     CConceptosCajaCCExterior, CConceptosCobrosCIC, CCtaCteBancariaCCI, CCajaAhorroCCI;

type

TTInformes = class
  Periodo, Idsocio, Codmov, PerMonto, FechaLiq, Tipo, Sucursal, Numero, CA, CC: String;
  Monto, Cantidad, MonMonto, Efectivo, CtaCte, CAhorro: Real;
  tabla, montos, movcaja: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xperiodo, xidsocio, xcodmov: String): Boolean;
  procedure   Registrar(xperiodo, xidsocio, xcodmov, xtipo, xsucursal, xnumero: String; xcantidad, xmonto: Real);
  procedure   Borrar(xperiodo, xidsocio, xcodmov: String);
  function    setInformes(xperiodo: String): TObjectList;
  procedure   getLiquidacion(xperiodo, xidsocio, xcodmov: String);

  function    BuscarMonto(xperiodo: String): Boolean;
  procedure   RegistrarMonto(xperiodo: String; xmonto: Real);
  procedure   BorrarMonto(xperiodo: String);
  function    setMontos: TObjectList;
  function    setMonto(xperiodo: String): Real;

  procedure   RegistrarCobro(xperiodo, xidsocio, xcodmov, xfecha, xtipo, xsucursal, xnumero: String; xefectivo, xcajaahorro, xctacte: Real; xca, xcc: String);
  procedure   BorrarCobro(xperiodo, xidsocio, xcodmov: String);

  procedure   ListarCobrosEfectuados(xdesde, xhasta: String; salida: char);
  procedure   ListarCobrosPendientes(xdesde, xhasta: String; salida: char);
  procedure   ListarResumenCobros(xdesde, xhasta: String; salida: char);

  procedure   EstablecerMovCaja(xcodmov: String);
  function    getMovCaja: String;
  function    verificarMovCaja: Boolean;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function informe: TTInformes;

implementation

var
  xinforme: TTInformes = nil;

constructor TTInformes.Create;
begin
  tabla   := datosdb.openDB('cobroinf', '');
  montos  := datosdb.openDB('montoinf', '');
  movcaja := datosdb.openDB('movcaja', '');
end;

destructor TTInformes.Destroy;
begin
  inherited Destroy;
end;

function  TTInformes.Buscar(xperiodo, xidsocio, xcodmov: String): Boolean;
// Objetivo...: buscar instancia
begin
  if tabla.IndexFieldNames <> 'Periodo;Idsocio;Codmov' then tabla.IndexFieldNames := 'Periodo;Idsocio;Codmov';
  Result := datosdb.Buscar(tabla, 'periodo', 'idsocio', 'codmov', Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4), xidsocio, xcodmov);
end;

procedure TTInformes.Registrar(xperiodo, xidsocio, xcodmov, xtipo, xsucursal, xnumero: String; xcantidad, xmonto: Real);
// Objetivo...: Registrar Instancia
begin
  if Buscar(xperiodo, xidsocio, xcodmov) then tabla.Edit else tabla.Append;
  tabla.FieldByName('periodo').AsString  := Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
  tabla.FieldByName('idsocio').AsString  := xidsocio;
  tabla.FieldByName('codmov').AsString   := xcodmov;
  tabla.FieldByName('tipo').AsString     := xtipo;
  tabla.FieldByName('sucursal').AsString := xsucursal;
  tabla.FieldByName('numero').AsString   := xnumero;
  tabla.FieldByName('cantidad').AsFloat  := xcantidad;
  tabla.FieldByName('monto').AsFloat     := xmonto;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTInformes.Borrar(xperiodo, xidsocio, xcodmov: String);
// Objetivo...: Registrar Instancia
begin
  if Buscar(xperiodo, xidsocio, xcodmov) then Begin
    tabla.Delete;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

function  TTInformes.setInformes(xperiodo: String): TObjectList;
// Objetivo...: devolver una lista con los movimientos del período
var
  l: TObjectList;
  objeto: TTInformes;
begin
  datosdb.Filtrar(tabla, 'periodo = ' + '''' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4) + ''''); 
  l := TObjectList.Create;
  tabla.First;
  while not tabla.Eof do Begin
    objeto := TTInformes.Create;
    objeto.Periodo  := Copy(tabla.FieldByName('periodo').AsString, 1, 2) + '/' + Copy(tabla.FieldByName('periodo').AsString, 3, 4);
    objeto.Idsocio  := tabla.FieldByName('idsocio').AsString;
    objeto.Codmov   := tabla.FieldByName('codmov').AsString;
    objeto.Cantidad := tabla.FieldByName('cantidad').AsFloat;
    objeto.Monto    := tabla.FieldByName('monto').AsFloat;
    objeto.FechaLiq := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
    objeto.Tipo     := tabla.FieldByName('tipo').AsString;
    objeto.Sucursal := tabla.FieldByName('sucursal').AsString;
    objeto.Numero   := tabla.FieldByName('numero').AsString;
    objeto.Efectivo := tabla.FieldByName('efectivo').AsFloat;
    objeto.CAhorro  := tabla.FieldByName('cajaahorro').AsFloat;
    objeto.Ctacte   := tabla.FieldByName('ctacte').AsFloat;
    objeto.cc       := tabla.FieldByName('cc').AsString;
    objeto.ca       := tabla.FieldByName('ca').AsString;
    l.Add(objeto);
    tabla.Next;
  end;
  Result := l;
end;

procedure TTInformes.getLiquidacion(xperiodo, xidsocio, xcodmov: String);
// Objetivo...: Recuperar una Liquidación
Begin
  if Buscar(xperiodo, xidsocio, xcodmov) then Begin
    FechaLiq := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
    Tipo     := tabla.FieldByName('tipo').AsString;
    Sucursal := tabla.FieldByName('sucursal').AsString;
    Numero   := tabla.FieldByName('numero').AsString;
    Efectivo := tabla.FieldByName('efectivo').AsFloat;
    CAhorro  := tabla.FieldByName('cajaahorro').AsFloat;
    Ctacte   := tabla.FieldByName('ctacte').AsFloat;
    CA       := tabla.FieldByName('CA').AsString;
    CC       := tabla.FieldByName('CC').AsString;
  end else Begin
    FechaLiq := '';
    Tipo     := '';
    Sucursal := '';
    Numero   := '';
    efectivo := 0;
    cahorro  := 0;
    ctacte   := 0;
    CA       := '';
    CC       := '';
  end;
end;

function  TTInformes.BuscarMonto(xperiodo: String): Boolean;
// Objetivo...: buscar instancia
begin
  Result := montos.FindKey([Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4)]);
end;

procedure TTInformes.RegistrarMonto(xperiodo: String; xmonto: Real);
// Objetivo...: cerrar tablas de persistencia
begin
  if BuscarMonto(xperiodo) then montos.Edit else montos.Append;
  montos.FieldByName('periodo').AsString := Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
  montos.FieldByName('monto').AsFloat    := xmonto;
  try
    montos.Post
   except
    montos.Cancel
  end;
  datosdb.closeDB(montos); montos.Open;
end;

procedure TTInformes.BorrarMonto(xperiodo: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if BuscarMonto(xperiodo) then Begin
    montos.Delete;
    datosdb.closeDB(montos); montos.Open;
  end;
end;

function  TTInformes.setMontos: TObjectList;
// Objetivo...: devolver una lista con los montos por período
var
  l: TObjectList;
  objeto: TTInformes;
begin
  l := TObjectList.Create;
  montos.First;
  while not montos.Eof do Begin
    objeto := TTInformes.Create;
    objeto.PerMonto := Copy(montos.FieldByName('periodo').AsString, 1, 2) + '/' + Copy(montos.FieldByName('periodo').AsString, 3, 4);
    objeto.MonMonto := montos.FieldByName('monto').AsFloat;
    l.Add(objeto);
    montos.Next;
  end;
  Result := l;
end;

function  TTInformes.setMonto(xperiodo: String): Real;
// Objetivo...: Sincronizar el monto
var
  m: Real;
begin
  montos.First; m := 0;
  while not montos.Eof do Begin
    m := montos.FieldByName('monto').AsFloat;
    if montos.FieldByName('periodo').AsString >= (Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4)) then Break;
    montos.Next;
  end;
  Result := m;
end;

procedure TTInformes.RegistrarCobro(xperiodo, xidsocio, xcodmov, xfecha, xtipo, xsucursal, xnumero: String; xefectivo, xcajaahorro, xctacte: Real; xca, xcc: String);
// Objetivo...: registrar cobro
begin
  if Buscar(xperiodo, xidsocio, xcodmov) then Begin
    tabla.Edit;
    tabla.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
    tabla.FieldByName('tipo').AsString      := xtipo;
    tabla.FieldByName('sucursal').AsString  := xsucursal;
    tabla.FieldByName('numero').AsString    := xnumero;
    tabla.FieldByName('efectivo').AsFloat   := xefectivo;
    tabla.FieldByName('cajaahorro').AsFloat := xcajaahorro;
    tabla.FieldByName('ctacte').AsFloat     := xctacte;
    tabla.FieldByName('cc').AsString        := xcc;
    tabla.FieldByName('ca').AsString        := xca;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTInformes.BorrarCobro(xperiodo, xidsocio, xcodmov: String);
// Objetivo...: borrar cobro
begin
  if Buscar(xperiodo, xidsocio, xcodmov) then Begin
    tabla.Edit;
    tabla.FieldByName('fecha').AsString     := '';
    tabla.FieldByName('cc').AsString    := '';
    tabla.FieldByName('ca').AsString    := '';
    tabla.FieldByName('efectivo').AsFloat   := 0;
    tabla.FieldByName('cajaahorro').AsFloat := 0;
    tabla.FieldByName('ctacte').AsFloat     := 0;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTInformes.ListarCobrosEfectuados(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Cobros Efectuados
var
  total1, total2, total3, total4: Real;
  idregistro: String;
begin
  list.Setear(salida); total1 := 0; total2 := 0; total3 := 0; total4 := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Cobros Efectuados en el Lapso: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.Soc.   Nombre ó Razón Social', 1, 'Arial, cursiva, 8');
  List.Titulo(29, List.lineactual, 'Cantidad', 2, 'Arial, cursiva, 8');
  List.Titulo(39, List.lineactual, 'Monto', 3, 'Arial, cursiva, 8');
  List.Titulo(45, List.lineactual, 'Fecha', 4, 'Arial, cursiva, 8');
  List.Titulo(52, List.lineactual, 'Tipo/Nro. Compr.', 5, 'Arial, cursiva, 8');
  List.Titulo(69, List.lineactual, 'Efectivo', 6, 'Arial, cursiva, 8');
  List.Titulo(78, List.lineactual, 'C. Ahorro', 7, 'Arial, cursiva, 8');
  List.Titulo(89, List.lineactual, 'Cta. Cte.', 8, 'Arial, cursiva, 8');
  List.Titulo(96, List.lineactual, 'T.Mov.', 9, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.IndexFieldNames := 'Periodo;Fecha';
  datosdb.Filtrar(tabla, 'periodo >= ' + '''' + (Copy(xdesde, 1, 2) + Copy(xdesde, 4, 4)) + '''' + ' and periodo <= ' + '''' + (Copy(xhasta, 1, 2) + Copy(xhasta, 4, 4)) + '''' + ' and tipo >= ' + '''' + 'A' + '''');
  tabla.First;
  while not tabla.Eof do Begin
    socio.getDatos(tabla.FieldByName('idsocio').AsString);
    list.Linea(0, 0, socio.codigo + '  ' + Copy(socio.nombre, 1, 25), 1, 'Arial, normal, 8', salida, 'N');
    list.importe(35, list.Lineactual, '#####', tabla.FieldByName('cantidad').AsFloat, 2, 'Arial, normal, 8');
    list.importe(44, list.Lineactual, '', tabla.FieldByName('cantidad').AsFloat * tabla.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8');
    list.Linea(45, list.Lineactual, utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString), 4, 'Arial, normal, 8', salida, 'N');
    list.Linea(52, list.Lineactual, tabla.FieldByName('tipo').AsString + ' ' + tabla.FieldByName('sucursal').AsString + '-' + tabla.FieldByName('numero').AsString, 5, 'Arial, normal, 8', salida, 'N');
    list.importe(75, list.Lineactual, '', tabla.FieldByName('efectivo').AsFloat, 6, 'Arial, normal, 8');
    list.importe(85, list.Lineactual, '', tabla.FieldByName('cajaahorro').AsFloat, 7, 'Arial, normal, 8');
    list.importe(95, list.Lineactual, '', tabla.FieldByName('ctacte').AsFloat, 8, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, tabla.FieldByName('codmov').AsString, 9, 'Arial, normal, 8', salida, 'S');
    idregistro := tabla.FieldByName('periodo').AsString + tabla.FieldByName('idsocio').AsString + tabla.FieldByName('codmov').AsString;
    if tabla.FieldByName('cajaahorro').AsFloat > 0 then Begin
      cajaahorrobanco.getDatos(idregistro);
      entbcos.getDatos(cajaahorrobanco.Entidad);
      list.Linea(0, 0, '     Transferido a Caja de Ahorro: ' + tabla.FieldByName('CA').AsString + ' - ' + entbcos.descrip, 1, 'Arial, cursiva, 8', salida, 'S');
    end;
    if tabla.FieldByName('ctacte').AsFloat > 0 then Begin
      ctactebanco.getDatos(idregistro);
      entbcos.getDatos(ctactebanco.Entidad);
      list.Linea(0, 0, '     Transferido a Cuenta Corriente: ' + tabla.FieldByName('CC').AsString + ' - ' + entbcos.descrip, 1, 'Arial, cursiva, 8', salida, 'S');
    end;
    total1 := total1 + tabla.FieldByName('cantidad').AsFloat;
    total2 := total2 + tabla.FieldByName('efectivo').AsFloat;
    total3 := total3 + tabla.FieldByName('cajaahorro').AsFloat;
    total4 := total4 + tabla.FieldByName('ctacte').AsFloat;
    tabla.Next;
  end;

  datosdb.QuitarFiltro(tabla);
  tabla.IndexFieldNames := 'Periodo;Idsocio;Codmov';

  if total1 <> 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotales:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(44, list.Lineactual, '######', total1, 2, 'Arial, negrita, 8');
    list.importe(75, list.Lineactual, '', total2, 3, 'Arial, negrita, 8');
    list.importe(85, list.Lineactual, '', total3, 4, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', total4, 5, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 6, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, 'Total General:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', total2 + total3 + total4, 2, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  end;

  list.FinList;
end;

procedure TTInformes.ListarCobrosPendientes(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Cobros Pendientes
var
  total1, total2: Real;
begin
  list.Setear(salida); total1 := 0; total2 := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Cobros Pendientes en el Lapso: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.Soc.   Nombre ó Razón Social', 1, 'Arial, cursiva, 8');
  List.Titulo(64, List.lineactual, 'Cantidad', 2, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Monto', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.IndexFieldNames := 'Periodo;Fecha';
  datosdb.Filtrar(tabla, 'periodo >= ' + '''' + (Copy(xdesde, 1, 2) + Copy(xdesde, 4, 4)) + '''' + ' and periodo <= ' + '''' + (Copy(xhasta, 1, 2) + Copy(xhasta, 4, 4)) + '''');
  tabla.First;
  while not tabla.Eof do Begin
    if Length(Trim(tabla.FieldByName('tipo').AsString)) = 0 then Begin
      socio.getDatos(tabla.FieldByName('idsocio').AsString);
      list.Linea(0, 0, socio.codigo + '  ' + socio.nombre, 1, 'Arial, normal, 8', salida, 'N');
      list.importe(70, list.Lineactual, '#####', tabla.FieldByName('cantidad').AsFloat, 2, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', tabla.FieldByName('cantidad').AsFloat * tabla.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8');
      list.Linea(66, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'N');
      total1 := total1 + tabla.FieldByName('cantidad').AsFloat;
      total2 := total2 + (tabla.FieldByName('cantidad').AsFloat * tabla.FieldByName('monto').AsFloat);
    end;
    tabla.Next;
  end;

  datosdb.QuitarFiltro(tabla);
  tabla.IndexFieldNames := 'Periodo;Idsocio;Codmov';

  if total1 <> 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotales:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(70, list.Lineactual, '######', total1, 2, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', total2, 3, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
  end;

  list.FinList;
end;

procedure TTInformes.ListarResumenCobros(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Resumen de Cobros
var
  idanter: String;
  total1, total2, total3, total4: Real;

  procedure ListLinea(xidmov: String; salida: char);
  Begin
    conceptoing.getDatos(xidmov);
    list.Linea(0, 0, conceptoing.Items + '  ' + conceptoing.Descrip, 1, 'Arial, normal, 8', salida, 'N');
    list.importe(70, list.Lineactual, '#####', total1, 2, 'Arial, normal, 8');
    list.importe(95, list.Lineactual, '', total2, 3, 'Arial, normal, 8');
    list.Linea(66, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'N');
    total3 := total3 + total1;
    total4 := total4 + total2;
    total1 := 0; total2 := 0;
  end;

begin
  list.Setear(salida); total1 := 0; total2 := 0; total3 := 0; total4 := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Resumen de Cobros en el Lapso: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.  Tipo de Movimiento', 1, 'Arial, cursiva, 8');
  List.Titulo(64, List.lineactual, 'Cantidad', 2, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Monto', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.IndexFieldNames := 'Periodo;Fecha';
  datosdb.Filtrar(tabla, 'periodo >= ' + '''' + (Copy(xdesde, 1, 2) + Copy(xdesde, 4, 4)) + '''' + ' and periodo <= ' + '''' + (Copy(xhasta, 1, 2) + Copy(xhasta, 4, 4)) + '''' + ' and tipo >= ' + '''' + 'A' + '''');
  tabla.IndexFieldNames := 'codmov;periodo';
  tabla.First;
  idanter := tabla.FieldByName('codmov').AsString;
  while not tabla.Eof do Begin
    if tabla.FieldByName('codmov').AsString <> idanter then ListLinea(idanter, salida);
    total1  := total1 + tabla.FieldByName('cantidad').AsFloat;
    total2  := total2 + (tabla.FieldByName('cantidad').AsFloat * tabla.FieldByName('monto').AsFloat);
    idanter := tabla.FieldByName('codmov').AsString;
    tabla.Next;
  end;
  ListLinea(idanter, salida);

  datosdb.QuitarFiltro(tabla);
  tabla.IndexFieldNames := 'Periodo;Idsocio;Codmov';

  if total3 + total4 <> 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotales:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(70, list.Lineactual, '######', total3, 2, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', total4, 3, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
  end;

  list.FinList;
end;

procedure TTInformes.EstablecerMovCaja(xcodmov: String);
// Objetivo...: establecer movimiento de caja
begin
  if movcaja.FindKey(['01']) then movcaja.Edit else movcaja.Append;
  movcaja.FieldByName('items').AsString  := '01';
  movcaja.FieldByName('codmov').AsString := xcodmov;
  try
    movcaja.Post
   except
    movcaja.Cancel
  end;
  datosdb.closeDB(movcaja); movcaja.Open;
end;

function  TTInformes.getMovCaja: String;
// Objetivo...: recuperr movimiento de caja
begin
  if movcaja.FindKey(['01']) then Result := movcaja.FieldByName('codmov').AsString else Result := '';
end;

function  TTInformes.verificarMovCaja: Boolean;
// Objetivo...: comprobar movimiento de caja
begin
  if movcaja.FindKey(['01']) then Result := True else Result := False;
end;

procedure TTInformes.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    if not montos.Active then montos.Open;
    if not movcaja.Active then movcaja.Open;
  end;
  Inc(conexiones);
  socio.conectar;
  conccaja.conectar;
  conceptoing.conectar;
  ctactebanco.conectar;
  cajaahorrobanco.conectar;
  entbcos.conectar;
end;

procedure TTInformes.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(montos);
    datosdb.closeDB(movcaja);
  end;
  socio.desconectar;
  conccaja.desconectar;
  conceptoing.desconectar;
  ctactebanco.desconectar;
  cajaahorrobanco.desconectar;
  entbcos.desconectar;
end;

{===============================================================================}

function informe: TTInformes;
begin
  if xinforme = nil then
    xinforme := TTInformes.Create;
  Result := xinforme;
end;

{===============================================================================}

initialization

finalization
  xinforme.Free;

end.
