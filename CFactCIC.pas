unit CFactCIC;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Contnrs, Classes,
     CSociosCIC, CModeloImpresionCIC;

type

TTFact = class
  Idc, Tipo, Sucursal, Numero, Fecha, Entidad, Items, Nroliq, Descrip, Condicion, Liquidado, Tipoper: String;
  Codmov, Estado, Transaccion, FechaLiq: String;
  Cantidad, Monto, Subtotal, Percep, Impuesto, IVA: Real;
  cabfact, detfact: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xidc, xtipo, xsucursal, xnumero: String): Boolean;
  procedure   Registrar(xidc, xtipo, xsucursal, xnumero, xfecha, xentidad, xitems, xnroliq, xdescrip, xcodmovcaja, xestadoitems, xtipoper: String;
                        xcantidad, xmonto, xsubtotal, xpercep, ximpuesto, xiva: Real; xcantitems: Integer);
  procedure   Borrar(xidc, xtipo, xsucursal, xnumero: String);
  procedure   getDatos(xidc, xtipo, xsucursal, xnumero: String);
  function    setItems(xidc, xtipo, xsucursal, xnumero: String): TObjectList;

  procedure   RegistrarTransaccion(xidc, xtipo, xsucursal, xnumero, xitems, xtransaccion, xfecha: String);

  procedure   ImprimirFact(xidc, xtipo, xsucursal, xnumero: String; salida: char; xnrocopia: Integer); overload;
  procedure   ImprimirFact; overload;

  procedure   AnularComprobante(xidc, xtipo, xsucursal, xnumero: String);

  procedure   LiquidarCobro(xidc, xtipo, xsucursal, xnumero, xfechaliq: String);
  procedure   CancelarLiquidacionCobro(xidc, xtipo, xsucursal, xnumero: String);

  function    getItemsPendientes(xentidad: String): TObjectList;
  function    getItemsLiquidados(xentidad: String): TObjectList;

  function    getComprobantesEmitidos(xdesde, xhasta: String): TObjectList;
  function    getComprobantesLiquidados(xdesde, xhasta: String): TObjectList;
  function    getComprobantesLiquidadosPorFechaLiquidacion(xdesde, xhasta: String): TObjectList;
  function    getComprobantesEnCtaCtePendientes(xdesde, xhasta: String): TObjectList;

  function    getOperacionesAdicionalesPendientes(xdesde, xhasta: String): TObjectList;
  function    getOperacionesAdicionalesLiquidadas(xdesde, xhasta: String): TObjectList;

  function    getFacturasEnCtaCteLiquidadas(xdesde, xhasta: String): TObjectList;

  procedure   conectar;
  procedure   desconectar;
 protected
  { Declaraciones Protegidas }
  function    BuscarDet(xidc, xtipo, xsucursal, xnumero, xitems: String): Boolean;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  function    getItemsFactura(xentidad, xmodo: String): TObjectList;
  function    getFacturas(xdesde, xhasta, xmodo, xtipoliq: String): TObjectList;
  function    getOperaciones(xdesde, xhasta, xmodo: String): TObjectList;
end;

implementation

constructor TTFact.Create;
begin
end;

destructor TTFact.Destroy;
begin
  inherited Destroy;
end;

function  TTFact.Buscar(xidc, xtipo, xsucursal, xnumero: String): Boolean;
// Objetivo...: recuperar una instancia
begin
  Result := datosdb.Buscar(cabfact, 'idc', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero);
end;

function  TTFact.BuscarDet(xidc, xtipo, xsucursal, xnumero, xitems: String): Boolean;
// Objetivo...: recuperar una instancia
begin
  Result := datosdb.Buscar(detfact, 'idc', 'tipo', 'sucursal', 'numero', 'items', xidc, xtipo, xsucursal, xnumero, xitems);
end;

procedure TTFact.Registrar(xidc, xtipo, xsucursal, xnumero, xfecha, xentidad, xitems, xnroliq, xdescrip, xcodmovcaja, xestadoitems, xtipoper: String;
                           xcantidad, xmonto, xsubtotal, xpercep, ximpuesto, xiva: Real; xcantitems: Integer);
// Objetivo...: registrar una instancia
begin
  if xitems = '01' then Begin
    if Buscar(xidc, xtipo, xsucursal, xnumero) then cabfact.Edit else cabfact.Append;
    cabfact.FieldByName('idc').AsString       := xidc;
    cabfact.FieldByName('tipo').AsString      := xtipo;
    cabfact.FieldByName('sucursal').AsString  := xsucursal;
    cabfact.FieldByName('numero').AsString    := xnumero;
    cabfact.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
    cabfact.FieldByName('entidad').AsString   := xentidad;
    cabfact.FieldByName('subtotal').AsFloat   := xsubtotal;
    cabfact.FieldByName('percep').AsFloat     := xpercep;
    cabfact.FieldByName('impuesto').AsFloat   := ximpuesto;
    cabfact.FieldByName('iva').AsFloat        := xiva;
    cabfact.FieldByName('liquidado').AsString := 'N';
    cabfact.FieldByName('tipoper').AsString   := xtipoper;
    try
      cabfact.Post
     except
      cabfact.Cancel
    end;
    datosdb.closeDB(cabfact); cabfact.Open;
  end;

  if BuscarDet(xidc, xtipo, xsucursal, xnumero, xitems) then detfact.Edit else detfact.Append;
  detfact.FieldByName('idc').AsString      := xidc;
  detfact.FieldByName('tipo').AsString     := xtipo;
  detfact.FieldByName('sucursal').AsString := xsucursal;
  detfact.FieldByName('numero').AsString   := xnumero;
  detfact.FieldByName('items').AsString    := xitems;
  detfact.FieldByName('nroliq').AsString   := xnroliq;
  detfact.FieldByName('descrip').AsString  := xdescrip;
  detfact.FieldByName('codcaja').AsString   := xcodmovcaja;
  detfact.FieldByName('estado').AsString   := xestadoitems;
  detfact.FieldByName('cantidad').AsFloat  := xcantidad;
  detfact.FieldByName('monto').AsFloat     := xmonto;
  try
    detfact.Post
   except
    detfact.Cancel
  end;

  if (xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0')) then Begin
    datosdb.tranSQL('delete from ' + detfact.TableName + ' where idc = ' + '''' + xidc + '''' + ' and tipo = ' + '''' + xtipo + '''' + ' and sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(detfact); detfact.Open;
  end;
end;

procedure TTFact.RegistrarTransaccion(xidc, xtipo, xsucursal, xnumero, xitems, xtransaccion, xfecha: String);
// Objetivo...: registrar transaccion de caja
begin
  if BuscarDet(xidc, xtipo, xsucursal, xnumero, xitems) then Begin
    detfact.Edit;
    detfact.FieldByName('transaccion').AsString  := xtransaccion;
    if (Length(Trim(xtransaccion)) > 0) then Begin
      detfact.FieldByName('estado').AsString   := 'L';
      detfact.FieldByName('fechaliq').AsString := utiles.sExprFecha2000(xfecha);
    end else Begin
      detfact.FieldByName('estado').AsString   := 'N';
      detfact.FieldByName('fechaliq').AsString := '';
    End;
    try
      detfact.Post
     except
      detfact.Cancel
    end;
    datosdb.refrescar(detfact);
  End;
end;

procedure TTFact.Borrar(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: borrar una instancia
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero) then Begin
    cabfact.Delete;
    datosdb.closeDB(cabfact); cabfact.Open;
  end;
end;

procedure TTFact.getDatos(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: cargar una instancia
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero) then Begin
    idc      := cabfact.FieldByName('idc').AsString;
    tipo     := cabfact.FieldByName('tipo').AsString;
    sucursal := cabfact.FieldByName('sucursal').AsString;
    numero   := cabfact.FieldByName('numero').AsString;
    fecha    := utiles.sFormatoFecha(cabfact.FieldByName('fecha').AsString);
    entidad  := cabfact.FieldByName('entidad').AsString;
    tipoper  := cabfact.FieldByName('tipoper').AsString;
  end else Begin
    idc := ''; tipo := ''; sucursal := ''; numero := ''; fecha := ''; entidad := ''; tipoper := '';
  end;
end;

function  TTFact.setItems(xidc, xtipo, xsucursal, xnumero: String): TObjectList;
// Objetivo...: devolver los items de un comprobante
var
  l: TObjectList;
  objeto: TTFact;
  i: Integer;
begin
  if BuscarDet(xidc, xtipo, xsucursal, xnumero, '001') then Begin
    while not detfact.Eof do Begin
      if (detfact.FieldByName('idc').AsString <> xidc) or (detfact.FieldByName('tipo').AsString <> xtipo) or (detfact.FieldByName('sucursal').AsString <> xsucursal) or (detfact.FieldByName('numero').AsString <> xnumero) then Break;
      objeto := TTFact.Create;
      objeto.Items       := detfact.FieldByName('items').AsString;
      objeto.Nroliq      := detfact.FieldByName('nroliq').AsString;
      objeto.Descrip     := detfact.FieldByName('descrip').AsString;
      objeto.Cantidad    := detfact.FieldByName('items').AsFloat;
      objeto.Monto       := detfact.FieldByName('monto').AsFloat;
      objeto.Codmov      := detfact.FieldByName('codcaja').AsString;
      objeto.Estado      := detfact.FieldByName('estado').AsString;
      objeto.Transaccion := detfact.FieldByName('transaccion').AsString;
      l.Add(objeto);
      detfact.Next;
    end;
  end;
  Result := l;
end;

procedure TTFact.ImprimirFact(xidc, xtipo, xsucursal, xnumero: String; salida: char; xnrocopia: Integer);
// Objetivo...: Imprimir Factura
var
  l, z: TStringList;
  i, lineas: Integer;
  totfact: Real;
begin
  if xnrocopia = 1 then Begin
    if salida = 'I' then list.ImprimirVetical;
    list.Setear(salida);
    list.NoImprimirPieDePagina;
  End;
  getDatos(xidc, xtipo, xsucursal, xnumero);
  socio.getDatos(entidad);
  modeloImp.getDatosFormato(xidc + xtipo);

  lineas := 0; totfact := 0;

  // Cabecera ------------------------------------------------------------------
  list.IniciarMemoImpresiones(modeloImp.modeloImp, 'cabecera', 550);
  list.RemplazarEtiquetasEnMemo('#fecha', fecha);
  list.RemplazarEtiquetasEnMemo('#razon_social', utiles.StringLongitudFija(socio.Nombre, 40));
  list.RemplazarEtiquetasEnMemo('#domicilio', utiles.StringLongitudFija(socio.Domicilio, 40));
  list.RemplazarEtiquetasEnMemo('#cuit', socio.Nrocuit);
  list.RemplazarEtiquetasEnMemo('#codpfis', socio.Codpfis);
  list.RemplazarEtiquetasEnMemo('#localidad', socio.localidad);
  list.RemplazarEtiquetasEnMemo('#codpost', socio.codpost);
  list.RemplazarEtiquetasEnMemo('#provincia', socio.provincia);
  list.RemplazarEtiquetasEnMemo('#comprobante', xtipo + '  '  + xsucursal + '-' + xnumero);
  if condicion = '1' then list.RemplazarEtiquetasEnMemo('#tipo_operacion', 'CONTADO') else
    list.RemplazarEtiquetasEnMemo('#tipo_operacion', 'CTA.CTE.');

  l := list.setContenidoMemo;
  For i := 1 to l.Count do
    list.Linea(0, 0, l.Strings[i-1], 1, 'Courier New, Negrita, 9', salida, 'S');

  // Detalle -------------------------------------------------------------------
  if BuscarDet(xidc, xtipo, xsucursal, xnumero, '01') then Begin
    while not detfact.Eof do Begin
      if (detfact.FieldByName('idc').AsString <> xidc) or (detfact.FieldByName('tipo').AsString <> xtipo) or (detfact.FieldByName('sucursal').AsString <> xsucursal) or (detfact.FieldByName('numero').AsString <> xnumero) then Break;
      list.IniciarMemoImpresiones(modeloImp.modeloImp, 'detalle', 550);
      list.RemplazarEtiquetasEnMemo('#cantidad', utiles.FormatearNumero(detfact.FieldByName('cantidad').AsString));
      list.RemplazarEtiquetasEnMemo('#descripcion', utiles.StringLongitudFija(detfact.FieldByName('descrip').AsString, 40));
      list.RemplazarEtiquetasEnMemo('#precio_unit', utiles.sLlenarIzquierda(utiles.FormatearNumero(detfact.FieldByName('monto').AsString), 9, ' '));
      list.RemplazarEtiquetasEnMemo('#precio_tot', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr( detfact.FieldByName('monto').AsFloat * detfact.FieldByName('cantidad').AsFloat )), 9, ' '));
      totfact := totfact + (detfact.FieldByName('monto').AsFloat * detfact.FieldByName('cantidad').AsFloat);

      l := list.setContenidoMemo;
      For i := 1 to l.Count do
        list.Linea(0, 0, l.Strings[i-1], 1, 'Courier New, Negrita, 9', salida, 'S');

      Inc(lineas);

      detfact.Next;
    end;
  end;

  For i := lineas to modeloimp.Lineasdet do list.Linea(0, 0, '', 1, 'Courier New, Negrita, 9', salida, 'S');

  // Subtotal ------------------------------------------------------------------
  list.IniciarMemoImpresiones(modeloImp.modeloImp, 'pie', 550);
  list.RemplazarEtiquetasEnMemo('#subtotal1', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr(subtotal), '########0.00'), 10, ' '));
  if percep = 0 then list.RemplazarEtiquetasEnMemo('#percepciones', utiles.FormatearNumero(FloatToStr(percep), '#########.##')) else
    list.RemplazarEtiquetasEnMemo('#percepciones', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr(percep), '########0.00'), 10, ' '));
  if impuesto = 0 then list.RemplazarEtiquetasEnMemo('#impuesto', utiles.FormatearNumero(FloatToStr(impuesto), '#########.##')) else
    list.RemplazarEtiquetasEnMemo('#impuesto', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr(impuesto), '########0.00'), 10, ' '));
  list.RemplazarEtiquetasEnMemo('#subtotal2', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr(subtotal + percep), '########0.00'), 10, ' '));
  if iva = 0 then list.RemplazarEtiquetasEnMemo('#iva_insc', utiles.FormatearNumero(FloatToStr(iva), '#########.##')) else
    list.RemplazarEtiquetasEnMemo('#iva_insc', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr(iva), '########0.00'), 10, ' '));

  if iva <> 0 then list.RemplazarTodasLasEtiquetasEnMemo('#total', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr(subtotal + percep + impuesto + iva), '########0.00'), 10, ' ')) else
    list.RemplazarTodasLasEtiquetasEnMemo('#total', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr(totfact), '########0.00'), 10, ' '));

  l := list.setContenidoMemo;
  For i := 1 to l.Count do
    list.Linea(0, 0, l.Strings[i-1], 1, 'Courier New, Negrita, 9', salida, 'S');

  For i := lineas to modeloimp.Lineassep do list.Linea(0, 0, '', 1, 'Courier New, Negrita, 9', salida, 'S');
end;

procedure TTFact.ImprimirFact;
// Objetivo...: Imprimir Factura
Begin
  list.FinList;
End;

procedure TTFact.AnularComprobante(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: Anular/Reactivar Comprobante
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero) then Begin
    cabfact.Edit;
    if cabfact.FieldByName('estado').AsString = 'C' then cabfact.FieldByName('estado').AsString := '' else
      cabfact.FieldByName('estado').AsString := 'C';
    try
      cabfact.Post
     except
      cabfact.Cancel
    end;
    datosdb.refrescar(cabfact);
  end;
end;

function TTFact.getItemsFactura(xentidad, xmodo: String): TObjectList;
// Objetivo...: devolver los items pendientes
var
  l: TObjectList;
  objeto: TTFact;
  i: Integer;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(detfact, 'estado = ' + '''' + xmodo + '''');
  detfact.First;
  while not detfact.Eof do Begin
    if Buscar(detfact.FieldByName('idc').AsString, detfact.FieldByName('tipo').AsString, detfact.FieldByName('sucursal').AsString, detfact.FieldByName('numero').AsString) then Begin
      if cabfact.FieldByName('estado').AsString <> 'C' then Begin
        objeto := TTFact.Create;
        objeto.Idc         := detfact.FieldByName('idc').AsString;
        objeto.Tipo        := detfact.FieldByName('tipo').AsString;
        objeto.Sucursal    := detfact.FieldByName('sucursal').AsString;
        objeto.Numero      := detfact.FieldByName('numero').AsString;
        objeto.Items       := detfact.FieldByName('items').AsString;
        objeto.Nroliq      := detfact.FieldByName('nroliq').AsString;
        objeto.Descrip     := detfact.FieldByName('descrip').AsString;
        objeto.Cantidad    := detfact.FieldByName('cantidad').AsFloat;
        objeto.Monto       := detfact.FieldByName('monto').AsFloat;
        objeto.Codmov      := detfact.FieldByName('codcaja').AsString;
        objeto.Estado      := detfact.FieldByName('estado').AsString;
        objeto.Transaccion := detfact.FieldByName('transaccion').AsString;
        l.Add(objeto);
      End;
    end;
    detfact.Next;
  end;
  datosdb.QuitarFiltro(detfact);
  Result := l;
end;

procedure TTFact.LiquidarCobro(xidc, xtipo, xsucursal, xnumero, xfechaliq: String);
// Objetivo...: liquidar cobro
Begin
  if Buscar(xidc, xtipo, xsucursal, xnumero) then Begin
    cabfact.Edit;
    cabfact.FieldByName('liquidado').AsString := 'L';
    cabfact.FieldByName('fechaliq').AsString  := utiles.sExprFecha2000(xfechaliq);
    try
      cabfact.Post
    except
      cabfact.Cancel
    end;
    datosdb.refrescar(cabfact);
  End;
end;

procedure TTFact.CancelarLiquidacionCobro(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: cancelar liquidacion
Begin
  if Buscar(xidc, xtipo, xsucursal, xnumero) then Begin
    cabfact.Edit;
    cabfact.FieldByName('liquidado').AsString := 'N';
    cabfact.FieldByName('fechaliq').AsString  := '';
    try
      cabfact.Post
    except
      cabfact.Cancel
    end;
    datosdb.refrescar(cabfact);
  End;
end;

function TTFact.getItemsPendientes(xentidad: String): TObjectList;
// Objetivo...: devolver los items pendientes
Begin
  result := getItemsFactura(xentidad, 'N');
End;

function TTFact.getItemsLiquidados(xentidad: String): TObjectList;
// Objetivo...: devolver los items liquidados
Begin
  result := getItemsFactura(xentidad, 'L');
End;

function TTFact.getComprobantesEmitidos(xdesde, xhasta: String): TObjectList;
// Objetivo...: devolver los items pendientes
Begin
  result := getFacturas(xdesde, xhasta, 'P', '1');
End;

function TTFact.getComprobantesLiquidados(xdesde, xhasta: String): TObjectList;
// Objetivo...: devolver los items pendientes
Begin
  result := getFacturas(xdesde, xhasta, 'L', '1');
End;

function TTFact.getComprobantesLiquidadosPorFechaLiquidacion(xdesde, xhasta: String): TObjectList;
// Objetivo...: devolver los items pendientes
Begin
  result := getFacturas(xdesde, xhasta, 'L', '2');
End;

function TTFact.getComprobantesEnCtaCtePendientes(xdesde, xhasta: String): TObjectList;
// Objetivo...: devolver los items pendientes
Begin
  result := getFacturas(xdesde, xhasta, '', '3');
End;

function TTFact.getFacturasEnCtaCteLiquidadas(xdesde, xhasta: String): TObjectList;
// Objetivo...: devolver comprobantes en cta cte liquidados
Begin
  result := getFacturas(xdesde, xhasta, '', '4');
End;

function TTFact.getFacturas(xdesde, xhasta, xmodo, xtipoliq: String): TObjectList;
// Objetivo...: devolver los items pendientes
var
  l: TObjectList;
  objeto: TTFact;
  i: Integer;
begin
  l := TObjectList.Create;
  if (xtipoliq = '1') then Begin
    if (xmodo = 'P') then
      datosdb.Filtrar(cabfact, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and liquidado = ' + '''' + 'N' + '''')
    else
      datosdb.Filtrar(cabfact, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and liquidado = ' + '''' + 'L' + '''');
  End;
  if (xtipoliq = '2') then
    datosdb.Filtrar(cabfact, 'fechaliq >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fechaliq <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and liquidado = ' + '''' + 'L' + '''');
  if (xtipoliq = '3') then
    datosdb.Filtrar(cabfact, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and liquidado = ' + '''' + 'N' + '''' + ' and tipoper = ' + '''' + '2' + '''');
  if (xtipoliq = '4') then
    datosdb.Filtrar(cabfact, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and liquidado = ' + '''' + 'S' + '''' + ' and tipoper = ' + '''' + '2' + '''');

  cabfact.First;
  while not cabfact.Eof do Begin
    objeto             := TTFact.Create;
    objeto.Idc         := cabfact.FieldByName('idc').AsString;
    objeto.Tipo        := cabfact.FieldByName('tipo').AsString;
    objeto.Sucursal    := cabfact.FieldByName('sucursal').AsString;
    objeto.Numero      := cabfact.FieldByName('numero').AsString;
    objeto.Fecha       := utiles.sFormatoFecha(cabfact.FieldByName('fecha').AsString);
    objeto.Entidad     := cabfact.FieldByName('entidad').AsString;
    objeto.subtotal    := cabfact.FieldByName('subtotal').AsFloat;
    objeto.Percep      := cabfact.FieldByName('percep').AsFloat;
    objeto.Impuesto    := cabfact.FieldByName('impuesto').AsFloat;
    objeto.Iva         := cabfact.FieldByName('iva').AsFloat;
    objeto.Estado      := cabfact.FieldByName('estado').AsString;
    objeto.Liquidado   := cabfact.FieldByName('liquidado').AsString;
    objeto.FechaLiq    := utiles.sFormatoFecha(cabfact.FieldByName('fechaliq').AsString);
    objeto.Tipoper     := cabfact.FieldByName('tipoper').AsString;
    objeto.Transaccion := cabfact.FieldByName('transaccion').AsString;
    l.Add(objeto);
    cabfact.Next;
  end;
  datosdb.QuitarFiltro(cabfact);
  Result := l;
end;

function TTFact.getOperacionesAdicionalesPendientes(xdesde, xhasta: String): TObjectList;
// Objetivo...: devolver los items pendientes
Begin
  result := getOperaciones(xdesde, xhasta, 'P');
End;

function TTFact.getOperacionesAdicionalesLiquidadas(xdesde, xhasta: String): TObjectList;
// Objetivo...: devolver los items liquidados
Begin
  result := getOperaciones(xdesde, xhasta, 'L');
End;


function TTFact.getOperaciones(xdesde, xhasta, xmodo: String): TObjectList;
// Objetivo...: devolver los items pendientes
var
  l: TObjectList;
  objeto: TTFact;
  i: Integer;
begin
  l := TObjectList.Create;
  if (xmodo = 'P') then
    datosdb.Filtrar(detfact, 'estado = ' + '''' + 'N' + '''')
  else
    datosdb.Filtrar(detfact, 'fechaliq >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fechaliq <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and estado = ' + '''' + 'L' + '''');

  detfact.First;
  while not detfact.Eof do Begin
    objeto             := TTFact.Create;
    Buscar(detfact.FieldByName('idc').AsString, detfact.FieldByName('tipo').AsString, detfact.FieldByName('sucursal').AsString, detfact.FieldByName('numero').AsString);
    objeto.Idc         := detfact.FieldByName('idc').AsString;
    objeto.Tipo        := detfact.FieldByName('tipo').AsString;
    objeto.Sucursal    := detfact.FieldByName('sucursal').AsString;
    objeto.Numero      := detfact.FieldByName('numero').AsString;
    objeto.Fecha       := utiles.sFormatoFecha(cabfact.FieldByName('fecha').AsString);
    objeto.Entidad     := cabfact.FieldByName('entidad').AsString;
    objeto.cantidad    := detfact.FieldByName('cantidad').AsFloat;
    objeto.Descrip     := detfact.FieldByName('descrip').AsString;
    objeto.monto       := detfact.FieldByName('monto').AsFloat;
    objeto.FechaLiq    := utiles.sFormatoFecha(detfact.FieldByName('fechaliq').AsString);
    l.Add(objeto);
    detfact.Next;
  end;
  datosdb.QuitarFiltro(detfact);
  Result := l;
end;

procedure TTFact.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  modeloImp.conectar;
  if conexiones = 0 then Begin
    if not cabfact.Active then cabfact.Open;
    if not detfact.Active then detfact.Open;
  end;
  Inc(conexiones);
end;

procedure TTFact.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  modeloImp.desconectar;
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(cabfact);
    datosdb.closeDB(detfact);
  end;
end;

end.
