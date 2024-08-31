unit CFactVenta;

interface

uses CComregi, CComprobantes, CStock, CTablaIva, CLPsimpl, CUtiles, SysUtils, DB,
     DBTables, CIDBFM, CListar, CAdmNumCompr, CBDT, CComprob;

type

TTFacturaVenta = class(TTComprobantereg)
  entregado, ObservacionFact: String; anulada: Boolean; lineasBlanco: Integer;
  efectivo, ctacte, cheque, otros: real;
  planilla, items, rsCliente, telCliente, domCliente, locCliente, dniCliente, cuitCliente, codpfisCliente, Nro_ctacte: string;
  idcarta, plantillaCab, plantillaDet, plantillaPie: shortint; cuerpo, fe, lineasentrecomp: string;
  tablapsw, modeloc, clientesfact: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    getrsCliente: string;
  function    getPlanilla: string;
  function    getEntrega: string;
  function    getNroremito: string;
  function    getItems: string;
  function    setDetalle(xidc, xtipo, xsucursal, xnumero: string): TQuery;
  function    getNroSiguiente(xcodnumer: string): string;
  function    getNroItems(xidc, xtipo, xcategoria: string): integer;
  function    getCantidadCopias: integer;
  function    getControlarStock: string;

  procedure   Borrar(xidcompr, xtipo, xsucursal, xnumero, xidtitular: string);
  procedure   Grabar(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xfecha, xremito, xitems, xcodart, xdescrip, xidart, xentregado, xremitoItems: string; xctcc: integer; xsubtotal, xbonificacion, ximpuestos, xivari, xivarni, xsobretasa, xcantidad, xprecio, xdescuento, xdestogeneral, xentrega: real; xobservacion: string); overload;
  procedure   Grabar(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xfecha, xremito, xitems, xcodart, xdescrip, xidart, xentregado, xremitoItems: string; xctcc: integer; xsubtotal, xbonificacion, ximpuestos, xivari, xivarni, xsobretasa, xcantidad, xprecio, xdescuento, xdestogeneral, xentrega, xiva1, xiva2, xiva: real; xobservacion: string); overload;

  procedure   listFechas(df, hf: string; salida: char); virtual;
  procedure   listCliProv(df, hf: string; salida: char); virtual;
  procedure   listCFIva(df, hf: string; salida: char); virtual;
  procedure   listCTADO(df, hf: string; salida: char); virtual;
  procedure   listCC(df, hf: string; salida: char); virtual;

  procedure   getDatos(xidcompr, xtipo, xsucursal, xnumero: string);
  function    getFacturas(xdf, xhf: string): TQuery; overload;
  function    getFactOrdRubros(xdf, xhf: string): TQuery;
  function    setFacturas(xcodcli: String): TQuery;
  procedure   IngresarCtaCte(estado: shortint);
  function    getIngresarCtaCte: shortint;

  // Formatos de preimpresos
  procedure   GuardarFormatoCartas(xidcarta: shortint; xcuerpo, xfe, xlineasentrecomp: string);
  procedure   BorrarDatosFormatoCartas;
  procedure   getDatosFormatoCartas(xidcarta: shortint);

  procedure   AnularFactura(xidc, xtipo, xsucursal, xnumero: String);

  // Clientes Manuales
  function    BuscarDatosCliente(xidfact: String): Boolean;
  procedure   RegistrarDatosCliente(xidfact, xnombre, xdireccion, xcuit, xtelefono, xcodiva: String);
  procedure   getDatosCliente(xidfact: String);
  procedure   BorrarDatosCliente(xidfact: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
 protected
  { Declaraciones Protegidas }
  linea_actual, separacion, cantidaditems, lineasdetimpresas: Integer;
  procedure   IniciarInforme(salida: char); override;
  procedure   listCabeceraFact(salida: char);
  procedure   listItemsFact(salida: char); virtual;
  procedure   listDistribucionCobros(salida: char); virtual;
  procedure   ImprimirFactura(salida: char);
end;

function facturavta: TTFacturaVenta;

implementation

var
  xfactventa: TTFacturaVenta = nil;

constructor TTFacturaVenta.Create;
begin
  inherited Create;
  efectivo := 0; cheque := 0; ctacte := 0; otros := 0; lineasentrecomp := '2';
  t_operacion := 'ventas';
  tablapsw := TTable.Create(nil);
  tablapsw.TableName := 'Habpass';
  modeloc      := datosdb.openDB('modcarta', 'Idcarta');
  clientesfact := datosdb.openDB('clientesfact', '');
end;

destructor TTFacturaVenta.Destroy;
begin
  inherited Destroy;
end;

function TTFacturaVenta.getrsCliente: string;
begin
  Result := rsCliente;
end;

function TTFacturaVenta.getPlanilla: string;
begin
  Result := tcabecera.FieldByName('planilla').AsString;
end;

function TTFacturaVenta.getItems: string;
begin
  Result := tcabecera.FieldByName('nroitems').AsString;
end;

function TTFacturaVenta.getEntrega: string;
begin
  Result := tcabecera.FieldByName('entregado').AsString;
end;

function TTFacturaVenta.getNroremito: string;
begin
  Result := tcabecera.FieldByName('remito').AsString;
end;

procedure TTFacturaVenta.getDatos(xidcompr, xtipo, xsucursal, xnumero: string);
// Objetivo...: Cargar los atributos de una Factura
begin
  inherited getDatos(xidcompr, xtipo, xsucursal, xnumero);
  entregado := tcabecera.FieldByName('entregado').AsString;
  if tcabecera.FieldByName('anulada').AsString <> 'S' then anulada := False else anulada := True;
  if tcabecera.FieldByName('idtitular').AsString = '0000' then getDatosCliente(xidcompr + xtipo + xsucursal + xnumero);
end;

procedure TTFacturaVenta.Borrar(xidcompr, xtipo, xsucursal, xnumero, xidtitular: string);
// Objetivo...: Eliminar un Comprobante
begin
  if datosdb.Buscar(tcabecera, 'idcompr', 'tipo', 'sucursal', 'numero', xidcompr, xtipo, xsucursal, xnumero) then Begin
    BorrarLineas(xidcompr, xtipo, xsucursal, xnumero, xidtitular);  // Líneas de la Factura
    tcabecera.Delete;      // Cabecera
    datosdb.refrescar(tcabecera);
    datosdb.refrescar(tdetalle);
  end;
end;

procedure TTFacturaVenta.Grabar(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xfecha, xremito, xitems, xcodart, xdescrip, xidart, xentregado, xremitoItems: string; xctcc: integer; xsubtotal, xbonificacion, ximpuestos, xivari, xivarni, xsobretasa, xcantidad, xprecio, xdescuento, xdestogeneral, xentrega: real; xobservacion: string);
// Objetivo...: Grabar los datos de una Factura
begin
  if xitems <= '001' then Begin
    inherited GrabarCab(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xfecha, xremito, xctcc, xsubtotal, xbonificacion, ximpuestos, xivari, xivarni, xsobretasa, xdestogeneral, xentrega, xobservacion);
    tcabecera.Edit;
    tcabecera.FieldByName('entregado').AsString := xentregado;
    try
      tcabecera.Post
    except
      tcabecera.Cancel
    end;
    if _existe then BorrarLineas(xidcompr, xtipo, xsucursal, xnumero, xidtitular);  // Líneas de la Factura
  end;
  inherited GrabarItems(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xitems, xcodart, xdescrip, xidart, xfecha, xremitoItems, xcantidad, xprecio, xdescuento);
end;

procedure TTFacturaVenta.Grabar(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xfecha, xremito, xitems, xcodart, xdescrip, xidart, xentregado, xremitoItems: string; xctcc: integer; xsubtotal, xbonificacion, ximpuestos, xivari, xivarni, xsobretasa, xcantidad, xprecio, xdescuento, xdestogeneral, xentrega, xiva1, xiva2, xiva: real; xobservacion: string);
// Objetivo...: Grabar los datos de una Factura
begin
  if xitems <= '001' then Begin
    inherited GrabarCab(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xfecha, xremito, xctcc, xsubtotal, xbonificacion, ximpuestos, xivari, xivarni, xsobretasa, xdestogeneral, xentrega, xobservacion);
    tcabecera.Edit;
    tcabecera.FieldByName('entregado').AsString := xentregado;
    try
      tcabecera.Post
    except
      tcabecera.Cancel
    end;
    if _existe then BorrarLineas(xidcompr, xtipo, xsucursal, xnumero, xidtitular);  // Líneas de la Factura
  end;

  inherited GrabarItems(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xitems, xcodart, xdescrip, xidart, xfecha, xremitoItems, xcantidad, xprecio, xdescuento);

  if BuscarItems(xidcompr, xtipo, xsucursal, xnumero, xitems) then Begin
    tdetalle.Edit;
    tdetalle.FieldByName('iva1').AsFloat := xiva1;
    tdetalle.FieldByName('iva2').AsFloat := xiva2;
    tdetalle.FieldByName('iva').AsFloat  := xiva;
    try
      tdetalle.Post
     except
      tdetalle.Cancel
    end;
    datosdb.closeDB(tdetalle); tdetalle.Open;
  end;
end;

procedure TTFacturaVenta.listFechas(df, hf: string; salida: char);
// Objetivo...: Generar informe de Ventas - Nivel de ruptura por fecha
begin
  TSQL := datosdb.tranSQL('SELECT cabventa.fecha, cabventa.idcompr, cabventa.tipo, cabventa.sucursal, cabventa.numero, clientes.nombre AS rsocial, cabventa.subtotal, cabventa.bonif, cabventa.impuestos, cabventa.ivari, cabventa.ivarni, cabventa.sobretasa ' +
                          ' FROM cabventa, clientes WHERE ' + ' fecha >= ' + '''' + utiles.sExprFecha2000(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha2000(hf) + '''' + ' AND cabventa.idtitular = clientes.codcli ' + ' ORDER BY fecha');
  inherited llistFechas(df, hf, 'Informe de Ventas por Fecha', salida);  // Heredamos, el método se implementa para compas y ventas
end;

procedure TTFacturaVenta.listCliProv(df, hf: string; salida: char);
// Objetivo...: Generar informe de Ventas - Nivel de ruptura por fecha
begin
  TSQL := datosdb.tranSQL('SELECT fecha, idcompr, tipo, sucursal, numero, idtitular, subtotal, bonif, impuestos, ivari, ivarni, sobretasa FROM ' + tcabecera.TableName + ' WHERE fecha >= ' + '''' + utiles.sExprFecha2000(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha2000(hf) + '''' + ' ORDER BY idtitular, fecha');
  inherited llistCliProv(df, hf, 'Informe de Ventas por Clientes', salida);  // Heredamos, el método se implementa para compas y ventas
end;

procedure TTFacturaVenta.listCFIVA(df, hf: string; salida: char);
// Objetivo...: Generar informe de Ventas - Nivel de ruptura por Cóndición Fiscal
begin
  TSQL := datosdb.tranSQL('SELECT fecha, idcompr, tipo, sucursal, numero, idtitular, subtotal, bonif, impuestos, ivari, ivarni, sobretasa, codpfis FROM ' + tcabecera.TableName + ', clienteh WHERE ' + tcabecera.TableName + '.idtitular = clienteh.codcli AND fecha >= ' + '''' + utiles.sExprFecha2000(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha2000(hf) + '''' + ' ORDER BY codpfis, idtitular, fecha');
  inherited llistCFIVA(df, hf, 'Informe de Ventas por Condiciones Fiscales', salida);  // Heredamos, el método se implementa para compas y ventas
end;

procedure TTFacturaVenta.listCTADO(df, hf: string; salida: char);
// Objetivo...: Generar informe de Ventas - Nivel de ruptura por tipo de operacion (contado y cuenta corriente)
begin
  TSQL := datosdb.tranSQL('SELECT fecha, idcompr, tipo, sucursal, numero, cc, subtotal, bonif, impuestos, ivari, ivarni, sobretasa, idtitular FROM ' + tcabecera.TableName + ' WHERE fecha >= ' + '''' + utiles.sExprFecha2000(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha2000(hf) + '''' + ' AND cc = 1 ORDER BY cc, fecha');
  inherited llistCTADOCC(df, hf, 'Informe de Ventas de Contado', salida);  // Heredamos, el método se implementa para compas y ventas
end;

procedure TTFacturaVenta.listCC(df, hf: string; salida: char);
// Objetivo...: Generar informe de Ventas - Nivel de ruptura por tipo de operacion (contado y cuenta corriente)
begin
  TSQL := datosdb.tranSQL('SELECT fecha, idcompr, tipo, sucursal, numero, cc, subtotal, bonif, impuestos, ivari, ivarni, sobretasa, idtitular FROM ' + tcabecera.TableName + ' WHERE fecha >= ' + '''' + utiles.sExprFecha2000(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha2000(hf) + '''' + ' AND cc = 2 ORDER BY cc, fecha');
  inherited llistCTADOCC(df, hf, 'Informe de Ventas en Cuenta Corriente', salida);  // Heredamos, el método se implementa para compas y ventas
end;

function TTFacturaVenta.getNroSiguiente(xcodnumer: string): string;
// Objetivo...: calcular el nro. siguiente de factura
begin
  Result := utiles.sLLenarIzquierda(administNum.getNroSiguienteNF(xcodnumer), 8, '0');
end;

function TTFacturaVenta.setDetalle(xidc, xtipo, xsucursal, xnumero: string): TQuery;
// Objetivo...: calcular el nro. siguiente de factura
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tdetalle.TableName + ' WHERE idcompr = ' + '''' + xidc + '''' + ' AND tipo = ' + '''' + xtipo + '''' + ' AND sucursal = ' + '''' + xsucursal + '''' + ' AND numero = ' + '''' + xnumero + '''');
end;

function TTFacturaVenta.getNroItems(xidc, xtipo, xcategoria: string): integer;
// Objetivo...: Extraer la cantidad de items correspondientes al comprobante definido
begin
  administNum.getDatosDefF(xidc, xtipo, xcategoria);
  Result := administNum.Nnmaximo;
end;

function TTFacturaVenta.getCantidadCopias: integer;
// Objetivo...: Devolver el número de copias que se deben imprimir para este comprobante
begin
  Result := administNum.Ncantcopias;
end;

function TTFacturaVenta.getControlarStock: string;
// Objetivo...: Devolver si se calcula o no stock
begin
  Result := administNum.Ncontrolstock;
end;

function  TTFacturaVenta.getFacturas(xdf, xhf: string): TQuery;
// Objetivo...: retornar un subset de registros con las facturas de compra en un rango de fechas dado
begin
  Result := datosdb.tranSQL('SELECT idcompr AS IDC, tipo, sucursal, numero, fecha, subtotal, bonif, impuestos, ivari, ivarni, sobretasa, idtitular AS Cod, clientes.nombre AS clipro FROM cabventa, clientes WHERE cabventa.idtitular = clientes.codcli AND fecha >= ' + '''' + xdf + '''' + ' AND fecha <= ' + '''' + xhf + '''' + ' ORDER BY fecha');
end;

function TTFacturaVenta.getFactOrdRubros(xdf, xhf: string): TQuery;
// Objetivo...: retornar un subset de registros con las facturas de compra en un rango de fechas dado - ordenados por rubro
begin
  Result := datosdb.tranSQL('SELECT idcompr AS IDC, tipo, sucursal, numero, fecha, subtotal, bonif, impuestos, ivari, ivarni, sobretasa, idtitular AS Cod, clientes.nombre AS clipro FROM cabventa, clientes WHERE cabventa.idtitular = clientes.codcli AND fecha >= ' + '''' + xdf + '''' + ' AND fecha <= ' + '''' + xhf + '''' + ' ORDER BY fecha');
end;

function TTFacturaVenta.setFacturas(xcodcli: String): TQuery;
// Objetivo...: retornar un subset de registros con las facturas de compra en un rango de fechas dado - ordenados por rubro
begin
  Result := datosdb.tranSQL('SELECT idcompr, tipo, sucursal, numero, fecha, subtotal, bonif, impuestos, ivari, ivarni, sobretasa, idtitular FROM cabventa WHERE idtitular = ' + '"' + xcodcli + '"' + ' ORDER BY fecha');
end;

procedure TTFacturaVenta.IniciarInforme(salida: char);
// Objetivo...: Desencadenar una secuencia de eventos para la Preparación de Informes
begin
  list.AjustarResolImpresora(administNum.NResolucion, salida);
  if salida = 'I' then list.CantidadDeCopias(cantcopias);
  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto;
    list.LineaTxt(CHR(18), false);
  end;
  list.Setear(salida);     // Iniciar Listado
  IniciarListado;          // Emisión Múltiple
  list.FijarSaltoManual;   // Controlamos el Salto de la Página
end;

// Imprimir Factura
procedure TTFacturaVenta.listCabeceraFact(salida: char);
// Objetivo...: Listar cabecera de Factura
const
  c: string = '           ';
var
  i: integer;
  contado, ctacte, condicion: string;
begin
  modeloc.FindKey([plantillaCab]);
  fe     := modeloc.FieldByName('fe').AsString;
  if tcabecera.FieldByName('cc').AsInteger = 1 then Begin
    contado := 'X'; ctacte := ' '; condicion := 'Contado';
  end else Begin
    contado := ' '; ctacte := 'X'; condicion := 'Cta. Cte.';
  end;
  list.IniciarMemoImpresiones(modeloc, 'cuerpo', 500);
  list.RemplazarEtiquetasEnMemo('#fecha', utiles.sFormatoFecha(tcabecera.FieldByName('fecha').AsString));
  list.RemplazarEtiquetasEnMemo('#dni', dniCliente);
  list.RemplazarEtiquetasEnMemo('#cliente', rsCliente);
  list.RemplazarEtiquetasEnMemo('#telefono', telCliente);
  list.RemplazarEtiquetasEnMemo('#domicilio', domCliente);
  list.RemplazarEtiquetasEnMemo('#localidad', locCliente);
  list.RemplazarEtiquetasEnMemo('#codpfis', codpfisCliente);
  list.RemplazarEtiquetasEnMemo('#cuit', cuitCliente);
  list.RemplazarEtiquetasEnMemo('#contado', contado);
  list.RemplazarEtiquetasEnMemo('#ctacte', ctacte);
  list.RemplazarEtiquetasEnMemo('#condicionvta', condicion);
  list.RemplazarEtiquetasEnMemo('#cuenta', nro_ctacte);
  if (salida = 'P') or (salida = 'I') then list.ListMemo('', fe, 0, salida, nil, 500) else Begin
    For i := 1 to list.NumeroLineasMemo do    // Vamos imprimiendo en un archivo las lineas del memo
      list.LineaTxt(Copy(TrimRight(list.ExtraerItemsMemoImp(i-1)), 1, 80), true);
  end;
end;

procedure TTFacturaVenta.listItemsFact(salida: char);
// Objetivo...: Listar detalle de la Factura
var
  r: TQuery; i, itemsimpresos: integer;
begin
  //utiles.msgError(fe);
  modeloc.FindKey([plantillaDet]);
  list.IniciarMemoImpresiones(modeloc, 'cuerpo', 500);
  cantidaditems := administNum.Nnmaximo; // Nro. maximo de items por factura

  r := setDetalle(tcabecera.FieldByName('idcompr').AsString, tcabecera.FieldByName('tipo').AsString, tcabecera.FieldByName('sucursal').AsString, tcabecera.FieldByName('numero').AsString);
  r.Open; r.First; lineasdetimpresas := 30; itemsimpresos := 0;
  while not r.EOF do Begin
    // Extraemos los datos de la plantilla para armar el detalle
    if (salida = 'P') or (salida = 'I') then Begin
      // Cantidad
      List.Linea(StrToInt(Copy(list.ExtraerItemsMemoImp(0), 1, 3)), 0, ' ', 1, fe, salida, 'N');
      List.importe(StrToInt(Copy(list.ExtraerItemsMemoImp(0), 1, 3)), 0, ' ', r.FieldByName(Trim(Copy(list.ExtraerItemsMemoImp(0), 5, 10))).AsFloat, 2, fe);
      // Descripción
      List.Linea(StrToInt(Copy(list.ExtraerItemsMemoImp(1), 1, 3)), list.Lineactual, r.FieldByName(Trim(Copy(list.ExtraerItemsMemoImp(1), 5, 10))).AsString, 3, fe, salida, 'N');
      // Precio unitario
      List.importe(StrToInt(Copy(list.ExtraerItemsMemoImp(2), 1, 3)), 0, ' ', r.FieldByName(Trim(Copy(list.ExtraerItemsMemoImp(2), 5, 10))).AsFloat, 5, fe);
      // Precio total
      List.importe(StrToInt(Copy(list.ExtraerItemsMemoImp(3), 1, 3)), 0, ' ', r.FieldByName('cantidad').AsFloat * r.FieldByName('precio').AsFloat, 6, fe);
      List.Linea(97, list.Lineactual, ' ', 7, fe, salida, 'S');
    end;
    if salida = 'T' then Begin
      list.LineaTxt(utiles.espacios(StrToInt(Copy(list.ExtraerItemsMemoImp(0), 1, 3))), false); list.ImporteTxt(r.FieldByName(Trim(Copy(list.ExtraerItemsMemoImp(0), 5, 10))).AsFloat, 12, 2, false);
      list.LineaTxt(utiles.espacios(StrToInt(Copy(list.ExtraerItemsMemoImp(1), 1, 3))), false); list.LineaTxt(r.FieldByName(Trim(Copy(list.ExtraerItemsMemoImp(1), 5, 10))).AsString +  utiles.espacios(30 - Length(Trim(r.FieldByName(Trim(Copy(list.ExtraerItemsMemoImp(1), 5, 10))).AsString))) + ' ' + r.FieldByName('remito').AsString + utiles.espacios(15 - Length(Trim(r.FieldByName('remito').AsString))), False);
      list.LineaTxt(utiles.espacios(StrToInt(Copy(list.ExtraerItemsMemoImp(2), 1, 3))), false); list.ImporteTxt(r.FieldByName(Trim(Copy(list.ExtraerItemsMemoImp(2), 5, 10))).AsFloat, 8, 2, false);
      list.LineaTxt(utiles.espacios(StrToInt(Copy(list.ExtraerItemsMemoImp(3), 1, 3))), false); list.ImporteTxt(r.FieldByName('cantidad').AsFloat * r.FieldByName('precio').AsFloat, 8, 2, true);
    end;
    Inc(itemsimpresos);
    r.Next;
  end;

  r.Close; r.Free;
  // Llenamos el espacio de items
  For i := 1 to (cantidaditems - itemsimpresos) do Begin
    if (salida = 'P') or (salida = 'I') then List.Linea(0, 0, '  ', 1, 'Arial, Normal, 8', salida, 'S');
    if salida = 'T' then list.LineaTxt(' ', true);
  end;
end;

procedure TTFacturaVenta.listDistribucionCobros(salida: char);
// Objetivo...: Listar Leyenda de distribución de cobros
var
  i: integer;
begin
  getDatos(idcompr, tipo, sucursal, numero);
  modeloc.FindKey([plantillaPie]);
  fe     := modeloc.FieldByName('fe').AsString;
  list.IniciarMemoImpresiones(modeloc, 'cuerpo', 500);
  list.RemplazarEtiquetasEnMemo('#subtotal', utiles.FormatearNumero(FloatToStr(tcabecera.FieldByName('subtotal').AsFloat)));
  list.RemplazarEtiquetasEnMemo('#bonificacion', utiles.FormatearNumero(FloatToStr(tcabecera.FieldByName('bonif').AsFloat)));
  list.RemplazarEtiquetasEnMemo('#subtotal1', utiles.FormatearNumero(FloatToStr(tcabecera.FieldByName('subtotal').AsFloat - tcabecera.FieldByName('bonif').AsFloat)));
  list.RemplazarEtiquetasEnMemo('#impuestos', utiles.FormatearNumero(FloatToStr(tcabecera.FieldByName('impuestos').AsFloat)));
  list.RemplazarEtiquetasEnMemo('#descuentos', utiles.FormatearNumero(FloatToStr(tcabecera.FieldByName('destogeneral').AsFloat)));
  list.RemplazarEtiquetasEnMemo('#ivari', utiles.FormatearNumero(FloatToStr(tcabecera.FieldByName('ivari').AsFloat)));
  list.RemplazarEtiquetasEnMemo('#ivarni', utiles.FormatearNumero(FloatToStr(tcabecera.FieldByName('ivarni').AsFloat)));
  list.RemplazarEtiquetasEnMemo('#total', utiles.FormatearNumero(FloatToStr(tcabecera.FieldByName('subtotal').AsFloat + tcabecera.FieldByName('ivari').AsFloat + tcabecera.FieldByName('ivarni').AsFloat)));
  list.RemplazarEtiquetasEnMemo('#observaciones', tcabecera.FieldByName('observacion').AsString);
  list.RemplazarEtiquetasEnMemo('#observacionfinal', ObservacionFact);
  if (salida = 'P') or (salida = 'I') then Begin
    list.ListMemo('', fe, 0, salida, nil, 500);
    list.CompletarPagina;
  end;
  if salida = 'T' then Begin
    For i := 1 to list.NumeroLineasMemo do    // Vamos imprimiendo en un archivo las lineas del memo
      list.LineaTxt(list.ExtraerItemsMemoImp(i-1), true);
  end;
end;

procedure TTFacturaVenta.ImprimirFactura(salida: char);
// Objetivo...: Imprimir factura
var
  i: ShortInt;
begin
  if salida = 'I' then list.CantidadDeCopias(getCantidadCopias);
  if (salida = 'I') or (salida = 'P') then list.FinList else Begin
    For i := 1 to lineasblanco do list.LineaTxt(' ', True);
    list.NoImprimirPieDePagina;
    list.FinalizarImpresionModoTexto(getCantidadCopias);
  end;
end;

procedure TTFacturaVenta.IngresarCtaCte(estado: shortint);
// Objetivo...: Fijar el estado (transfiere/no transfiere al historico)
begin
  tablapsw.Open;
  if tablapsw.RecordCount > 0 then Begin
    tablapsw.Edit;
    tablapsw.FieldByName('cargarctacte').AsInteger := estado;
    try
      tablapsw.Post
    except
      tablapsw.Cancel
    end;
  end;
  tablapsw.Close;
end;

function TTFacturaVenta.getIngresarCtaCte: shortint;
// Objetivo...: Fijar el estado (transfiere/no transfiere al historico)
begin
  tablapsw.Open;
  Result := tablapsw.FieldByName('cargarctacte').AsInteger;
  tablapsw.Close;
end;

//------------------------------------------------------------------------------
// Manejo de Modelos de cartas preimpresos
procedure TTFacturaVenta.GuardarFormatoCartas(xidcarta: shortint; xcuerpo, xfe, xlineasentrecomp: string);
begin
  if not modeloc.FindKey([xidcarta]) then modeloc.Append else modeloc.Edit;
  modeloc.FieldByName('idcarta').AsInteger   := xidcarta;
  modeloc.FieldByName('cuerpo').AsString     := xcuerpo;
  modeloc.FieldByName('fe').AsString         := xfe;
  modeloc.FieldByName('fc').AsString         := xlineasentrecomp;
  try
    modeloc.Post
  except
    modeloc.Cancel
  end;
end;

procedure TTFacturaVenta.BorrarDatosFormatoCartas;
begin
  if modeloc.FindKey([idcarta]) then modeloc.Delete;
end;

procedure TTFacturaVenta.getDatosFormatoCartas(xidcarta: shortint);
begin
  if modeloc.FindKey([xidcarta]) then Begin
    cuerpo          := modeloc.FieldByName('cuerpo').AsString;
    fe              := modeloc.FieldByName('fe').AsString;
    lineasentrecomp := modeloc.FieldByName('fc').AsString;
  end else Begin
    idcarta := xidcarta; cuerpo := ''; fe := ''; lineasentrecomp := '0';
  end;
end;

//------------------------------------------------------------------------------
procedure TTFacturaVenta.AnularFactura(xidc, xtipo, xsucursal, xnumero: String);
begin
  if datosdb.Buscar(tcabecera, 'idcompr', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero) then Begin
    tcabecera.Edit;
    if tcabecera.FieldByName('anulada').AsString <> 'S' then tcabecera.FieldByName('anulada').AsString := 'S' else tcabecera.FieldByName('anulada').AsString := '';
    try
      tcabecera.Post
     except
      tcabecera.Cancel
    end;
    if tcabecera.FieldByName('anulada').AsString <> 'S' then anulada := False else anulada := True;
  end;
end;
//------------------------------------------------------------------------------

function  TTFacturaVenta.BuscarDatosCliente(xidfact: String): Boolean;
// Objetivo...: Buscar datos Facturados
Begin
  Result := clientesfact.FindKey([xidfact]);
end;

procedure TTFacturaVenta.RegistrarDatosCliente(xidfact, xnombre, xdireccion, xcuit, xtelefono, xcodiva: String);
// Objetivo...: Registrar datos clientes
Begin
  if BuscarDatosCliente(xidfact) then clientesfact.Edit else clientesfact.Append;
  clientesfact.FieldByName('idfact').AsString    := xidfact;
  clientesfact.FieldByName('nombre').AsString    := xnombre;
  clientesfact.FieldByName('cuit').AsString      := xcuit;
  clientesfact.FieldByName('direccion').AsString := xdireccion;
  clientesfact.FieldByName('telefono').AsString  := xtelefono;
  clientesfact.FieldByName('codiva').AsString    := xcodiva;
  try
    clientesfact.Post
   except
    clientesfact.Cancel
  end;
end;

procedure TTFacturaVenta.getDatosCliente(xidfact: String);
// Objetivo...: Recuperar datos clientes
Begin
  if BuscarDatosCliente(xidfact) then Begin
    rsCliente      := clientesfact.FieldByName('nombre').AsString;
    domCliente     := clientesfact.FieldByName('direccion').AsString;
    cuitCliente    := clientesfact.FieldByName('cuit').AsString;
    telCliente     := clientesfact.FieldByName('telefono').AsString;
    domCliente     := clientesfact.FieldByName('direccion').AsString;
    codpfisCliente := clientesfact.FieldByName('codiva').AsString;
  end else Begin
    rsCliente := ''; domCliente := ''; cuitCliente := ''; telCliente := ''; domCliente := ''; codpfisCliente := '';
  end;
end;

procedure TTFacturaVenta.BorrarDatosCliente(xidfact: String);
// Objetivo...: Borrar datos clientes
Begin
  if BuscarDatosCliente(xidfact) then clientesfact.Delete;
end;

procedure TTFacturaVenta.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  inherited conectar;
  if conexiones = 0 then Begin
    if not tdetalle.Active then tdetalle.Open;
    if not tcabecera.Active then tcabecera.Open;
    if not modeloc.Active then modeloc.Open;
    if not clientesfact.Active then clientesfact.Open;
  end;
  tabliva.conectar;
  presimples.conectar;
  administNum.conectar;
  comprobante.conectar;
  Inc(conexiones);
end;

procedure TTFacturaVenta.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  inherited desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tdetalle);
    datosdb.closeDB(tcabecera);
    datosdb.closeDB(modeloc);
    datosdb.closeDB(clientesfact);
  end;
  tabliva.desconectar;
  presimples.desconectar;
  administNum.desconectar;
  comprobante.desconectar;
end;

{===============================================================================}

function facturavta: TTFacturaVenta;
begin
  if xfactventa = nil then
    xfactventa := TTFacturaVenta.Create;
  Result := xfactventa;
end;

{===============================================================================}

initialization

finalization
  xfactventa.Free;

end.
