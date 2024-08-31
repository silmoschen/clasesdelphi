unit CFactVentaFacturacion;

interface

uses CFactVenta, CLPsimpl_Gross, CClienteGross, CArticulosGross, CUtiles, SysUtils, CListar, DBTables, CIDBFM, CAdmNumCompr, CIvaVentaGross;

type

TTFacturaVentaGross = class(TTFacturaVenta)
  idtarjeta: String;
  Margen, EspaciosDescripcion, lineasFinalComprobante: Integer;
  totalFactura: Real;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   listFactura(salida: char);
  function    getRsocial(xcodcli: string): string; override;
  procedure   RegistrarNroCtaCte(xidcompr, xtipo, xsucursal, xnumero, xctacte: String);
  procedure   getDatos(xidcompr, xtipo, xsucursal, xnumero: String);

  procedure   Grabar(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xfecha, xremito, xitems, xcodart, xdescrip, xidart, xentregado, xremitoItems: string; xctcc: integer; xsubtotal, xbonificacion, ximpuestos, xivari, xivarni, xsobretasa, xcantidad, xprecio, xdescuento, xdestogeneral, xentrega, xrecargo, xneto, xtotal: real; xobservacion, xtarjeta, xcliente: string);

  procedure   CalcularTotalesIVA(xperiodo: String);

  procedure   conectar;
  procedure   desconectar;
 protected
   { Declaraciones Protegidas }
   procedure  listItemsFact(salida: char); override;
   procedure  listDistribucionCobros(salida: char); override;
 private
  { Declaraciones Privadas }
  totales: array[1..3] of Real;
  procedure RegistrarTotalIva(xidc, xtipo, xsucursal, xnumero: String; xtotal1, xtotal2, xtotal3: Real);
end;

function factventa: TTFacturaVentaGross;

implementation

var
  xfactventa: TTFacturaVentaGross = nil;

constructor TTFacturaVentaGross.Create;
begin
  inherited Create;
  tcabecera := datosdb.openDB('cabventa', 'Idcompr;Tipo;Sucursal;Numero');           // Cabecera de la factura
  tdetalle  := datosdb.openDB('detventa', 'Idcompr;Tipo;Sucursal;Numero;Items');     // Detalle de la factura
  Margen := 0; EspaciosDescripcion := 0;
end;

destructor TTFacturaVentaGross.Destroy;
begin
  inherited Destroy;
end;

procedure TTFacturaVentaGross.listFactura(salida: char);
// Objetivo...: Listar Factura
var
  i, j: Integer;
begin
  // Atributos del cliente
  nro_ctacte     := Copy(tcabecera.FieldByName('ctacte').AsString, 1, 4) + '-' + Copy(tcabecera.FieldByName('ctacte').AsString, 5, 3);
  if tcabecera.FieldByName('idtitular').AsString <> '0000' then Begin
    cliente.getDatos(tcabecera.FieldByName('idtitular').AsString);
    rsCliente      := cliente.nombre;
    telCliente     := cliente.telcom;
    domCliente     := cliente.domicilio;
    locCliente     := cliente.localidad;
    dniCliente     := cliente.nrodoc;
    cuitCliente    := cliente.nrocuit;
    codpfisCliente := cliente.codpfis;
  end else
    inherited getDatosCliente(tcabecera.FieldByName('idcompr').AsString + tcabecera.FieldByName('tipo').AsString + tcabecera.FieldByName('sucursal').AsString + tcabecera.FieldByName('numero').AsString);

  if salida <> 'T' then Begin
    IniciarInforme(salida);
    separacion     := 52;      // Gradua la separación entre el detalle y los subtotales
    // Emisión del comprobante
    listCabeceraFact(salida);
    listItemsFact(salida);
    listDistribucionCobros(salida);
    inherited ImprimirFactura(salida);
  end else Begin
    for i := 1 to getCantidadCopias do Begin
      if i = getCantidadCopias then lineasblanco := lineasFinalComprobante - 1;
      list.IniciarImpresionModoTexto;
      list.NoImprimirPieDePagina;
      separacion     := 52;      // Gradua la separación entre el detalle y los subtotales
      // Emisión del comprobante
      listCabeceraFact(salida);
      listItemsFact(salida);
      listDistribucionCobros(salida);
      For j := 1 to lineasblanco do list.LineaTxt(' ', True);
      list.FinalizarImpresionModoTexto(1);
    end;
  end;
end;

function TTFacturaVentaGross.getRsocial(xcodcli: string): string;
// Objetivo...: devolver la razón social del cliente
begin
  cliente.conectar;
  cliente.getDatos(xcodcli);
  cliente.desconectar;
  Result := cliente.nombre;
end;

procedure TTFacturaVentaGross.RegistrarNroCtaCte(xidcompr, xtipo, xsucursal, xnumero, xctacte: String);
// Objetivo...: Registrar Cuenta Corriente
Begin
  if BuscarCab(xidcompr, xtipo, xsucursal, xnumero) then Begin
    tcabecera.Edit;
    tcabecera.FieldByName('ctacte').AsString := xctacte;
    try
      tcabecera.Post
     except
      tcabecera.Cancel
    end;
    datosdb.refrescar(tcabecera);
  end;
end;

procedure TTFacturaVentaGross.getDatos(xidcompr, xtipo, xsucursal, xnumero: String);
// Objetivo...: Recuperar datos
Begin
  inherited getDatos(xidcompr, xtipo, xsucursal, xnumero);
  if _existe then Begin
    nro_ctacte := tcabecera.FieldByName('ctacte').AsString;
    idtarjeta  := tcabecera.FieldByName('tarjeta').AsString;
  end else Begin
    nro_ctacte := ''; idtarjeta := '';
  end;
end;

procedure TTFacturaVentaGross.listItemsFact(salida: char);
// Objetivo...: Listar detalle de la Factura
var
  r: TQuery; i, itemsimpresos: integer;
begin
  modeloc.FindKey([plantillaDet]);
  list.IniciarMemoImpresiones(modeloc, 'cuerpo', 500);
  cantidaditems := administNum.Nnmaximo; // Nro. maximo de items por factura

  r := setDetalle(tcabecera.FieldByName('idcompr').AsString, tcabecera.FieldByName('tipo').AsString, tcabecera.FieldByName('sucursal').AsString, tcabecera.FieldByName('numero').AsString);
  r.Open; r.First; lineasdetimpresas := 30; itemsimpresos := 0; totalFactura := 0;
  while not r.EOF do Begin
    // Extraemos los datos de la plantilla para armar el detalle
    if (salida = 'P') or (salida = 'I') then Begin
      // Cantidad
      List.Linea(StrToInt(Copy(list.ExtraerItemsMemoImp(0), 1, 3)), 0, ' ', 1, fe, salida, 'N');
      List.importe(StrToInt(Copy(list.ExtraerItemsMemoImp(0), 1, 3)), 0, ' ', r.FieldByName(Trim(Copy(list.ExtraerItemsMemoImp(0), 5, 10))).AsFloat, 2, fe);
      // Descripción
      List.Linea(StrToInt(Copy(list.ExtraerItemsMemoImp(1), 1, 3)), list.Lineactual, r.FieldByName(Trim(Copy(list.ExtraerItemsMemoImp(1), 5, 10))).AsString, 3, fe, salida, 'N');
      // Precio unitario
      List.importe(StrToInt(Copy(list.ExtraerItemsMemoImp(2), 1, 3)), 0, ' ', r.FieldByName(Trim(Copy(list.ExtraerItemsMemoImp(2), 5, 10))).AsFloat - (r.FieldByName('descuento').AsFloat / r.FieldByName('cantidad').AsFloat), 5, fe);
      // Precio total
      List.importe(StrToInt(Copy(list.ExtraerItemsMemoImp(3), 1, 3)), 0, ' ', (r.FieldByName('cantidad').AsFloat * r.FieldByName('precio').AsFloat) - r.FieldByName('descuento').AsFloat, 6, fe);
      List.Linea(97, list.Lineactual, ' ', 7, fe, salida, 'S');
    end;
    if salida = 'T' then Begin
      list.LineaTxt(utiles.espacios(StrToInt(Copy(list.ExtraerItemsMemoImp(0), 1, 3))), false); list.LineaTxt(utiles.espacios(Margen), False); list.ImporteTxt(r.FieldByName(Trim(Copy(list.ExtraerItemsMemoImp(0), 5, 10))).AsFloat, 7, 2, False);
      list.LineaTxt(utiles.espacios(StrToInt(Copy(list.ExtraerItemsMemoImp(1), 1, 3))), false); list.LineaTxt(TrimLeft(r.FieldByName(TrimRight(Copy(list.ExtraerItemsMemoImp(1), 5, 10))).AsString) + utiles.espacios(30 - Length(TrimLeft(r.FieldByName(TrimRight(Copy(list.ExtraerItemsMemoImp(1), 5, 10))).AsString))) + utiles.espacios(EspaciosDescripcion),  False);
      list.LineaTxt(utiles.espacios(StrToInt(Copy(list.ExtraerItemsMemoImp(2), 1, 3))), false); list.ImporteTxt(r.FieldByName(Trim(Copy(list.ExtraerItemsMemoImp(2), 5, 10))).AsFloat - (r.FieldByName('descuento').AsFloat / r.FieldByName('cantidad').AsFloat), 8, 2, False);
      list.LineaTxt(utiles.espacios(StrToInt(Copy(list.ExtraerItemsMemoImp(3), 1, 3))), false); list.ImporteTxt((r.FieldByName('cantidad').AsFloat * r.FieldByName('precio').AsFloat) - r.FieldByName('descuento').AsFloat, 8, 2, True);
    end;
    Inc(itemsimpresos);
    totalFactura := totalFactura + r.FieldByName('total').AsFloat;
    r.Next;
  end;

  r.Close; r.Free;
  // Llenamos el espacio de items
  For i := 1 to (cantidaditems - itemsimpresos) do Begin
    if (salida = 'P') or (salida = 'I') then List.Linea(0, 0, '  ', 1, 'Arial, Normal, 8', salida, 'S');
    if salida = 'T' then list.LineaTxt(' ', true);
  end;
end;

procedure TTFacturaVentaGross.listDistribucionCobros(salida: char);
// Objetivo...: Listar Leyenda de distribución de cobros
var
  i: integer;
begin
  //totalfactura := totalfactura + (tcabecera.FieldByName('ivari').AsFloat + tcabecera.FieldByName('ivarni').AsFloat);
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
  list.RemplazarEtiquetasEnMemo('#total', utiles.FormatearNumero(FloatToStr(totalFactura)));
  list.RemplazarEtiquetasEnMemo('#observaciones', observacionfact);
  list.RemplazarEtiquetasEnMemo('#importe_letras', utiles.xIntToLletras(StrToInt(Copy(utiles.FormatearNumero(FloatToStr(totalFactura)), 1, Length(Trim(utiles.FormatearNumero(FloatToStr(totalFactura)))) - 3))) + ' con ' + Copy(utiles.FormatearNumero(FloatToStr(totalFactura)), Length(Trim(utiles.FormatearNumero(FloatToStr(totalFactura)))) - 1, 2) + ' ctvos.');
  if (salida = 'P') or (salida = 'I') then Begin
    list.ListMemo('', fe, 0, salida, nil, 500);
    list.CompletarPagina;
  end;
  if salida = 'T' then Begin
    For i := 1 to list.NumeroLineasMemo do    // Vamos imprimiendo en un archivo las lineas del memo
      list.LineaTxt(list.ExtraerItemsMemoImp(i-1), true);
  end;
end;

procedure TTFacturaVentaGross.Grabar(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xfecha, xremito, xitems, xcodart, xdescrip, xidart, xentregado, xremitoItems: string; xctcc: integer; xsubtotal, xbonificacion, ximpuestos, xivari, xivarni, xsobretasa, xcantidad, xprecio, xdescuento, xdestogeneral, xentrega, xrecargo, xneto, xtotal: real; xobservacion, xtarjeta, xcliente: string);
Begin
  inherited Grabar(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xfecha, xremito, xitems, xcodart, xdescrip, xidart, xentregado, xremitoItems, xctcc, xsubtotal, xbonificacion, ximpuestos, xivari, xivarni, xsobretasa, xcantidad, xprecio, xdescuento, xdestogeneral, xentrega, xobservacion);
  if xitems = '001' then
    if BuscarCab(xidcompr, xtipo, xsucursal, xnumero) then Begin
      tcabecera.Edit;
      tcabecera.FieldByName('tarjeta').AsString := xtarjeta;
      tcabecera.Post;
    end;
  tdetalle.Edit;
  tdetalle.FieldByName('recargo').AsFloat := xrecargo;
  tdetalle.FieldByName('neto').AsFloat    := xneto;
  tdetalle.FieldByName('total').AsFloat   := xtotal;
  try
    tdetalle.Post
   except
    tdetalle.Cancel
  end;
  datosdb.closedb(tcabecera); datosdb.closedb(tdetalle);
  tcabecera.Open; tdetalle.Open;
end;

procedure TTFacturaVentaGross.CalcularTotalesIVA(xperiodo: String);
// Objetivo...: Transferir Totales al I.V.A.
var
  medicamentos, aranceles, honorarios: Real;
  idanter: array[1..4] of String;
Begin
  ivav.conectar;
  datosdb.Filtrar(tdetalle, 'fecha >= ' + Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2) + '01' + ' and fecha <= ' + Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2) + utiles.ultimodiames(Copy(xperiodo, 1, 2), Copy(xperiodo, 4, 4)));
  tdetalle.First;
  totales[1] := 0; totales[2] := 0; totales[3] := 0;
  idanter[1] := tdetalle.FieldByName('idcompr').AsString;
  idanter[2] := tdetalle.FieldByName('tipo').AsString;
  idanter[3] := tdetalle.FieldByName('sucursal').AsString;
  idanter[4] := tdetalle.FieldByName('numero').AsString;
  while not tdetalle.Eof do Begin
    if (tdetalle.FieldByName('idcompr').AsString <> idanter[1]) or (tdetalle.FieldByName('tipo').AsString <> idanter[2]) or (tdetalle.FieldByName('sucursal').AsString <> idanter[3]) or (tdetalle.FieldByName('numero').AsString <> idanter[4]) then RegistrarTotalIva(idanter[1], idanter[2], idanter[3], idanter[4], totales[1], totales[2], totales[3]);

    art.getDatos(tdetalle.FieldByName('codart').AsString);
    art.getDatosRubro(art.codrubro);
    medicamentos := art.DMedicamentos;
    honorarios   := art.DHonorarios;
    aranceles    := art.DAranceles;
    if (honorarios = 0) and (aranceles = 0) then medicamentos := 100;

    if medicamentos > 0 then totales[3] := totales[3] + ((((tdetalle.FieldByName('cantidad').AsFloat * tdetalle.FieldByName('precio').AsFloat) - tdetalle.FieldByName('descuento').AsFloat) * medicamentos) * 0.01);
    if honorarios > 0 then   totales[2] := totales[2] + ((((tdetalle.FieldByName('cantidad').AsFloat * tdetalle.FieldByName('precio').AsFloat) - tdetalle.FieldByName('descuento').AsFloat) * honorarios) * 0.01);
    if aranceles > 0 then    totales[1] := totales[1] + ((((tdetalle.FieldByName('cantidad').AsFloat * tdetalle.FieldByName('precio').AsFloat) - tdetalle.FieldByName('descuento').AsFloat) * aranceles) * 0.01);

    idanter[1] := tdetalle.FieldByName('idcompr').AsString;
    idanter[2] := tdetalle.FieldByName('tipo').AsString;
    idanter[3] := tdetalle.FieldByName('sucursal').AsString;
    idanter[4] := tdetalle.FieldByName('numero').AsString;

    tdetalle.Next;
  end;
  RegistrarTotalIva(idanter[1], idanter[2], idanter[3], idanter[4], totales[1], totales[2], totales[3]);
  ivav.desconectar;
end;

procedure TTFacturaVentaGross.RegistrarTotalIva(xidc, xtipo, xsucursal, xnumero: String; xtotal1, xtotal2, xtotal3: Real);
// Objetivo...: Registrar totales
Begin
  ivav.DiscriminarTotales(xidc, xtipo, xsucursal, xnumero, totales[3], totales[2], totales[1]);
  totales[1] := 0; totales[2] := 0; totales[3] := 0;
end;

procedure TTFacturaVentaGross.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  art.conectar;
  cliente.conectar;
  presimples.conectar;
  inherited conectar;
end;

procedure TTFacturaVentaGross.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  inherited desconectar;
  cliente.desconectar;
  art.desconectar;
  presimples.desconectar;
end;

{===============================================================================}

function factventa: TTFacturaVentaGross;
begin
  if xfactventa = nil then
    xfactventa := TTFacturaVentaGross.Create;
  Result := xfactventa;
end;

{===============================================================================}

initialization

finalization
  xfactventa.Free;

end.
