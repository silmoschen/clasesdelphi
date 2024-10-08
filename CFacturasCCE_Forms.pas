unit CFacturasCCE_Forms;

interface

uses CFacturasCCE, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM,
     CClienteCCE, Classes, CCNetos, CTablaIva;

type

TTFactura_Formularios = class(TTFactura)
  codmovcajaforms, Codmov: String;
  factexentas: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ImprimirFact(xidc, xtipo, xsucursal, xnumero: String; salida: char);
  procedure   ImprimirFactDoble(xidc, xtipo, xsucursal, xnumero: String; salida: char);

  procedure   ListarFacturas(xdesde, xhasta: String; salida: char); overload;
  procedure   ListarFacturas(xdesde, xhasta, xsubtitulo, xcodcli: String; salida: char); overload;
  procedure   ListarMontosFacturas(xdesde, xhasta, xsubtitulo: String; salida: char);
  procedure   ListarFacturasPendientes(xdfecha, xhfecha: String; salida: char);

  function    setNombreEntidad(xcodigo: String): String; override;

  procedure   RegistrarMovCajaForms(xcodmov: String);
  procedure   getDatosMovCajaForms;

  procedure   FacturarComoExento(xidc, xtipo, xsucursal, xnumero, xexento, xcodmov: String);
  function    setFacturarComoExento(xidc, xtipo, xsucursal, xnumero: String): String;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  imp_doble: boolean;
  function    BuscarMov(xcodigo: String): Boolean;
 protected
  { Declaraciones Protegidas }
end;

function factform: TTFactura_Formularios;

implementation

var
  xfactura: TTFactura_Formularios = nil;

constructor TTFactura_Formularios.Create;
begin
  cabfact      := datosdb.openDB('cab_forms', '');
  detfact      := datosdb.openDB('fact_forms', '');
  observac     := datosdb.openDB('obs_forms', '');
  modeloImp    := datosdb.openDB('modeloImpr', '');
  mov_modulos  := datosdb.openDB('mov_modulos', '');
  factexentas  := datosdb.openDB('fact_ivaexentas', '');
end;

destructor TTFactura_Formularios.Destroy;
begin
  inherited Destroy;
end;

procedure TTFactura_Formularios.ImprimirFact(xidc, xtipo, xsucursal, xnumero: String; salida: char);
// Objetivo...: Imprimir Factura
var
  l, z: TStringList;
  i, lineas: Integer;
  totfact: Real;
begin
  if not (imp_doble) then begin
    if salida = 'I' then list.ImprimirVetical;
    list.Setear(salida);
    list.NoImprimirPieDePagina;
  end;
  getDatosFact(xidc, xtipo, xsucursal, xnumero);
  cliente.getDatos(entidad);
  getDatosFormato(xidc + xtipo);

  lineas := 0; totfact := 0;

  // Cabecera ------------------------------------------------------------------
  list.IniciarMemoImpresiones(modeloImp, 'cabecera', 550);
  list.RemplazarEtiquetasEnMemo('#fecha', fecha);
  list.RemplazarEtiquetasEnMemo('#razon_social', utiles.StringLongitudFija(cliente.Nombre, 40));
  list.RemplazarEtiquetasEnMemo('#domicilio', utiles.StringLongitudFija(cliente.Domicilio, 40));
  list.RemplazarEtiquetasEnMemo('#cuit', cliente.Nrocuit);
  list.RemplazarEtiquetasEnMemo('#codpfis', cliente.Codpfis);
  list.RemplazarEtiquetasEnMemo('#localidad', cliente.localidad);
  list.RemplazarEtiquetasEnMemo('#codpost', cliente.codpost);
  list.RemplazarEtiquetasEnMemo('#provincia', cliente.provincia);
  if condicion = '1' then list.RemplazarEtiquetasEnMemo('#tipo_operacion', 'CONTADO') else
    list.RemplazarEtiquetasEnMemo('#tipo_operacion', 'CTA.CTE.');

  l := list.setContenidoMemo;
  For i := 1 to l.Count do
    list.Linea(0, 0, l.Strings[i-1], 1, 'Courier New, Normal, 9', salida, 'S');

  // Detalle -------------------------------------------------------------------
  if BuscarDetFact(xidc, xtipo, xsucursal, xnumero, '01') then Begin
    while not detfact.Eof do Begin
      if (detfact.FieldByName('idc').AsString <> xidc) or (detfact.FieldByName('tipo').AsString <> xtipo) or (detfact.FieldByName('sucursal').AsString <> xsucursal) or (detfact.FieldByName('numero').AsString <> xnumero) then Break;
      list.IniciarMemoImpresiones(modeloImp, 'detalle', 550);
      list.RemplazarEtiquetasEnMemo('#cantidad', utiles.FormatearNumero(detfact.FieldByName('cantidad').AsString));
      list.RemplazarEtiquetasEnMemo('#descripcion', utiles.StringLongitudFija(detfact.FieldByName('descrip').AsString, 40));
      list.RemplazarEtiquetasEnMemo('#precio_unit', utiles.sLlenarIzquierda(utiles.FormatearNumero(detfact.FieldByName('monto').AsString), 9, ' '));
      list.RemplazarEtiquetasEnMemo('#precio_tot', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr( detfact.FieldByName('monto').AsFloat * detfact.FieldByName('cantidad').AsFloat )), 9, ' '));
      totfact := totfact + (detfact.FieldByName('monto').AsFloat * detfact.FieldByName('cantidad').AsFloat);

      l := list.setContenidoMemo;
      For i := 1 to l.Count do
        list.Linea(0, 0, l.Strings[i-1], 1, 'Courier New, Normal, 9', salida, 'S');

      Inc(lineas);

      if Length(Trim(detfact.FieldByName('detalle').AsString)) > 0 then Begin
        list.Linea(0, 0, '                             ' + detfact.FieldByName('detalle').AsString, 1, 'Courier New, Normal, 9', salida, 'S');
        Inc(lineas);
      end;

      detfact.Next;
    end;
  end;

  z := setLineasObservacion(xidc, xtipo, xsucursal, xnumero);
  if z.Count > 0 then Begin
    For i := 1 to z.Count do Begin
      if lineas >= lineasdet then Break;
      if i = 1 then Begin
        list.Linea(0, 0, '', 1, 'Courier New, Normal, 9', salida, 'S');
        Inc(lineas);
      end;

      list.Linea(0, 0, '                    ' + z.Strings[i-1], 1, 'Courier New, Normal, 9', salida, 'S');
    end;
  end;

  For i := lineas to lineasdet do list.Linea(0, 0, '', 1, 'Courier New, Normal, 9', salida, 'S');

  // Subtotal ------------------------------------------------------------------
  list.IniciarMemoImpresiones(modeloImp, 'pie', 550);
  list.RemplazarEtiquetasEnMemo('#subtotal1', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr(subtotal), '########0.00'), 10, ' '));
  if percep = 0 then list.RemplazarEtiquetasEnMemo('#percepciones', utiles.FormatearNumero(FloatToStr(percep), '#########.##')) else
    list.RemplazarEtiquetasEnMemo('#percepciones', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr(percep), '########0.00'), 10, ' '));
  if impuesto = 0 then list.RemplazarEtiquetasEnMemo('#impuesto', utiles.FormatearNumero(FloatToStr(impuesto), '#########.##')) else
    list.RemplazarEtiquetasEnMemo('#impuesto', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr(impuesto), '########0.00'), 10, ' '));
  list.RemplazarEtiquetasEnMemo('#subtotal2', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr(subtotal + percep), '########0.00'), 10, ' '));
  if iva = 0 then list.RemplazarEtiquetasEnMemo('#iva_insc', utiles.FormatearNumero(FloatToStr(iva), '#########.##')) else
    list.RemplazarEtiquetasEnMemo('#iva_insc', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr(iva), '########0.00'), 10, ' '));

  if iva <> 0 then list.RemplazarTodasLasEtiquetasEnMemo('#total', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr(subtotal + percep + impuesto + iva), '########0.00'), 10, ' ')) else
    list.RemplazarTodasLasEtiquetasEnMemo('#total', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr({subtotal}totfact), '########0.00'), 10, ' '));

  l := list.setContenidoMemo;
  For i := 1 to l.Count do
    list.Linea(0, 0, l.Strings[i-1], 1, 'Courier New, Normal, 9', salida, 'S');

  if not (imp_doble) then
    list.FinList;
end;

procedure TTFactura_Formularios.ImprimirFactDoble(xidc, xtipo, xsucursal, xnumero: String; salida: char);
var
  i: integer;
begin
  if salida = 'I' then list.ImprimirVetical;
  list.Setear(salida);
  list.NoImprimirPieDePagina;
  imp_doble := true;
  ImprimirFact(xidc, xtipo, xsucursal, xnumero, salida);
  for i := 1 to lineassep do
    list.Linea(0, 0, '', 1, 'Courier New, Normal, 9', salida, 'S');
  ImprimirFact(xidc, xtipo, xsucursal, xnumero, salida);
  imp_doble := false;
  list.FinList;
end;


function  TTFactura_Formularios.setNombreEntidad(xcodigo: String): String;
// Objetivo...: retornar el nombre de la entidad
Begin
  cliente.getDatos(xcodigo);
  Result := cliente.nombre;
end;

procedure TTFactura_Formularios.ListarFacturas(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Facturas
Begin
  inherited ListarFacturas(xdesde, xhasta, '***  Comprobantes Emitidos por Venta de Formularios ***', salida);
end;

procedure TTFactura_Formularios.ListarFacturas(xdesde, xhasta, xsubtitulo, xcodcli: String; salida: char);
// Objetivo...: Listar Facturas para Estadisticas
Begin
  inherited ListarFacturas(xdesde, xhasta, 'Comprobantes Emitidos por Venta de Formularios - Lapso: ', xcodcli, salida);
end;

procedure TTFactura_Formularios.ListarMontosFacturas(xdesde, xhasta, xsubtitulo: String; salida: char);
// Objetivo...: Listar Montos Facturados
Begin
  inherited ListarMontosFacturas(xdesde, xhasta, '***  Comprobantes Emitidos por Venta de Formularios ***', salida);
end;

procedure TTFactura_Formularios.ListarFacturasPendientes(xdfecha, xhfecha: String; salida: char);
// Objetivo...: Listar Facturas Pendientes de Cobro
Begin
  total := 0;
  if list.m = 0 then Begin
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Listado de Facturas Pendientes - Lapso: ' + xdfecha + '-' + xhfecha, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 9');
    List.Titulo(8, List.lineactual, 'Comprobante', 2, 'Arial, cursiva, 9');
    List.Titulo(25, List.lineactual, 'Cliente', 3, 'Arial, cursiva, 9');
    List.Titulo(90, List.lineactual, 'Monto', 4, 'Arial, cursiva, 9');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 9');
  end else
    iniList := True;

  if iniList then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;

  list.Linea(0, 0, '*** Comprobantes Pendientes de Cobro Formularios ***', 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  cabfact.IndexFieldNames := 'Fecha';
  datosdb.Filtrar(cabfact, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''' + ' and condicion = ' + '''' + '2' + '''');
  cabfact.First;
  while not cabfact.Eof do Begin
    if Length(Trim(cabfact.FieldByName('cobrado').AsString)) = 0 then Begin
      if cabfact.FieldByName('estado').AsString <> 'C' then Begin
        cliente.getDatos(cabfact.FieldByName('codcli').AsString);
        list.Linea(0, 0, utiles.sFormatoFecha(cabfact.FieldByName('fecha').AsString), 1, 'Arial, normal, 9', salida, 'N');
        list.Linea(8, list.Lineactual, cabfact.FieldByName('idc').AsString + ' ' + cabfact.FieldByName('tipo').AsString + ' ' + cabfact.FieldByName('sucursal').AsString + '-' + cabfact.FieldByName('numero').AsString, 2, 'Arial, normal, 9', salida, 'N');
        list.Linea(25, list.Lineactual, cliente.codigo + '  ' + cliente.nombre, 3, 'Arial, normal, 9', salida, 'N');
        list.importe(95, list.Lineactual, '', cabfact.FieldByName('subtotal').AsFloat + cabfact.FieldByName('iva').AsFloat, 4, 'Arial, normal, 9');
        list.Linea(95, list.Lineactual, cabfact.FieldByName('estado').AsString, 5, 'Arial, normal, 9', salida, 'S');
        total := total + (cabfact.FieldByName('subtotal').AsFloat + cabfact.FieldByName('iva').AsFloat);
      End;
    end;
    cabfact.Next;
  end;

  datosdb.QuitarFiltro(cabfact);
  cabfact.IndexFieldNames := 'Idc;Tipo;Sucursal;Numero';

  if total > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', total, 2, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
  end else
    list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');
end;

function  TTFactura_Formularios.BuscarMov(xcodigo: String): Boolean;
// Objetivo...: Buscar una Instancia
Begin
  Result := mov_modulos.FindKey([xcodigo]);
end;

procedure TTFactura_Formularios.RegistrarMovCajaForms(xcodmov: String);
// Objetivo...: Registrar una Instancia
Begin
  if BuscarMov('006') then mov_modulos.Edit else mov_modulos.Append;
  mov_modulos.FieldByName('modulo').AsString := '006';
  mov_modulos.FieldByName('codmov').AsString := xcodmov;
  try
    mov_modulos.Post
   except
    mov_modulos.Cancel
  end;
  datosdb.refrescar(mov_modulos);
end;

procedure TTFactura_Formularios.getDatosMovCajaForms;
// Objetivo...: Recuperar una Instancia
Begin
  if BuscarMov('006') then codmovcajaforms := mov_modulos.FieldByName('codmov').AsString else codmovcajaforms := '';
end;

procedure TTFactura_Formularios.FacturarComoExento(xidc, xtipo, xsucursal, xnumero, xexento, xcodmov: String);
// Objetivo...: marcar si factura o no como exento
begin
  if datosdb.Buscar(factexentas, 'idc', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero) then factexentas.Edit else factexentas.Append;
  factexentas.FieldByName('idc').AsString       := xidc;
  factexentas.FieldByName('tipo').AsString      := xtipo;
  factexentas.FieldByName('sucursal').AsString  := xsucursal;
  factexentas.FieldByName('numero').AsString    := xnumero;
  factexentas.FieldByName('ivaexento').AsString := xexento;
  factexentas.FieldByName('codmov').AsString    := xcodmov;
  try
    factexentas.Post
   except
    factexentas.Cancel
  end;
  datosdb.closeDB(factexentas); factexentas.Open;
end;

function TTFactura_Formularios.setFacturarComoExento(xidc, xtipo, xsucursal, xnumero: String): String;
// Objetivo...: devolver si factura o no como exento
begin
  if datosdb.Buscar(factexentas, 'idc', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero) then Begin
    Codmov := factexentas.FieldByName('codmov').AsString;
    Result := factexentas.FieldByName('ivaexento').AsString;
  end else Begin
    codmov := '';
    Result := 'N';
  end;
end;

procedure TTFactura_Formularios.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited conectar;
  netos.conectar;
  tabliva.conectar;
  if not factexentas.Active then factexentas.Open;
end;

procedure TTFactura_Formularios.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
  netos.desconectar;
  tabliva.desconectar;
  datosdb.closeDB(factexentas);
end;

{===============================================================================}

function factform: TTFactura_Formularios;
begin
  if xfactura = nil then
    xfactura := TTFactura_Formularios.Create;
  Result := xfactura;
end;

{===============================================================================}

initialization

finalization
  xfactura.Free;

end.
