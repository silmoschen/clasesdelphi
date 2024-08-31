unit CFacturasCCE_Cuotas;

interface

uses CFacturasCCE, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM,
     CClienteCCE, Classes, CCNetos;

type

TTFactura_Cuotas = class(TTFactura)
  codmov, codmovcajacuotas: String;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ImprimirFact(xidc, xtipo, xsucursal, xnumero: String; salida: char);

  function    BuscarMovIva: Boolean;
  procedure   RegistrarMovIva(xcodmov: String);
  procedure   getDatosMovIva;

  procedure   RegistrarMovCajaCuotas(xcodmov: String);
  procedure   getDatosMovCajaCuotas;

  procedure   ListarFacturas(xdesde, xhasta: String; salida: char);
  procedure   ListarMontosFacturas(xdesde, xhasta, xsubtitulo: String; salida: char);
  procedure   ListarFacturasPendientes(xdfecha, xhfecha: String; salida: char);

  function    setNombreEntidad(xcodigo: String): String; override;

  function    setComprobante(xperiodo, xcuota, xcodcli: String): String;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  function    BuscarMov(xcodigo: String): Boolean;
end;

function factura: TTFactura_Cuotas;

implementation

var
  xfactura: TTFactura_Cuotas = nil;

constructor TTFactura_Cuotas.Create;
begin
  cabfact      := datosdb.openDB('cab_cuotas', '');
  detfact      := datosdb.openDB('fact_cuotas', '');
  modeloImp    := datosdb.openDB('modeloImpr', '');
  observac     := datosdb.openDB('obs_cuotas', '');
  mov_modulos  := datosdb.openDB('mov_modulos', '');
end;

destructor TTFactura_Cuotas.Destroy;
begin
  inherited Destroy;
end;

procedure TTFactura_Cuotas.ImprimirFact(xidc, xtipo, xsucursal, xnumero: String; salida: char);
// Objetivo...: Imprimir Factura
var
  l, z: TStringList;
  i, lineas: Integer;
begin
  if salida = 'I' then list.ImprimirVetical;
  list.Setear(salida);
  list.NoImprimirPieDePagina;
  getDatosFact(xidc, xtipo, xsucursal, xnumero);
  cliente.getDatos(entidad);
  getDatosFormato(xidc + xtipo);

  lineas := 0;

  // Cabecera ------------------------------------------------------------------
  list.IniciarMemoImpresiones(modeloImp, 'cabecera', 550);
  list.RemplazarEtiquetasEnMemo('#fecha', fecha);
  list.RemplazarEtiquetasEnMemo('#razon_social', utiles.StringLongitudFija(cliente.Nombre, 50));
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
      list.RemplazarEtiquetasEnMemo('#precio_unit',  utiles.sLlenarIzquierda(utiles.FormatearNumero(detfact.FieldByName('monto').AsString), 9, ' '));
      list.RemplazarEtiquetasEnMemo('#precio_tot', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr( detfact.FieldByName('monto').AsFloat * detfact.FieldByName('cantidad').AsFloat )), 9, ' '));

      l := list.setContenidoMemo;
      For i := 1 to l.Count do
        list.Linea(0, 0, l.Strings[i-1], 1, 'Courier New, Normal, 9', salida, 'S');

      Inc(lineas);
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
  list.RemplazarEtiquetasEnMemo('#subtotal1', utiles.sLlenarIzquierda( utiles.FormatearNumero(FloatToStr(subtotal), '########0.00'), 10, ' '));
  if percep = 0 then list.RemplazarEtiquetasEnMemo('#percepciones', utiles.FormatearNumero(FloatToStr(percep), '#########.##')) else
    list.RemplazarEtiquetasEnMemo('#percepciones', utiles.sLlenarIzquierda( utiles.FormatearNumero(FloatToStr(percep), '########0.00'), 10, ' '));
  if impuesto = 0 then list.RemplazarEtiquetasEnMemo('#impuesto', utiles.FormatearNumero(FloatToStr(impuesto), '#########.##')) else
    list.RemplazarEtiquetasEnMemo('#impuesto', utiles.sLlenarIzquierda( utiles.FormatearNumero(FloatToStr(impuesto), '########0.00'), 10, ' '));
  list.RemplazarEtiquetasEnMemo('#subtotal2', utiles.sLlenarIzquierda( utiles.FormatearNumero(FloatToStr(subtotal + percep), '########0.00'), 10, ' '));
  if iva = 0 then list.RemplazarEtiquetasEnMemo('#iva_insc', utiles.FormatearNumero(FloatToStr(iva), '#########.##')) else
    list.RemplazarEtiquetasEnMemo('#iva_insc', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr(iva), '########0.00'), 10, ' '));
  list.RemplazarTodasLasEtiquetasEnMemo('#total', utiles.sLlenarIzquierda (utiles.FormatearNumero(FloatToStr(subtotal + percep + impuesto + iva), '########0.00'), 10, ' '));

  l := list.setContenidoMemo;
  For i := 1 to l.Count do
    list.Linea(0, 0, l.Strings[i-1], 1, 'Courier New, Normal, 9', salida, 'S');

  list.FinList;
end;

function  TTFactura_Cuotas.BuscarMov(xcodigo: String): Boolean;
// Objetivo...: Buscar una Instancia
Begin
  Result := mov_modulos.FindKey([xcodigo]);
end;

function  TTFactura_Cuotas.BuscarMovIva: Boolean;
// Objetivo...: Buscar una Instancia
Begin
  Result := BuscarMov('001');
end;

procedure TTFactura_Cuotas.RegistrarMovIva(xcodmov: String);
// Objetivo...: Registrar una Instancia
Begin
  if BuscarMovIva then mov_modulos.Edit else mov_modulos.Append;
  mov_modulos.FieldByName('modulo').AsString := '001';
  mov_modulos.FieldByName('codmov').AsString := xcodmov;
  try
    mov_modulos.Post
   except
    mov_modulos.Cancel
  end;
  datosdb.refrescar(mov_modulos);
end;

procedure TTFactura_Cuotas.getDatosMovIva;
// Objetivo...: Recuperar una Instancia
Begin
  if BuscarMovIva then codmov := mov_modulos.FieldByName('codmov').AsString else codmov := '';
end;

procedure TTFactura_Cuotas.RegistrarMovCajaCuotas(xcodmov: String);
// Objetivo...: Registrar una Instancia
Begin
  if BuscarMov('005') then mov_modulos.Edit else mov_modulos.Append;
  mov_modulos.FieldByName('modulo').AsString := '005';
  mov_modulos.FieldByName('codmov').AsString := xcodmov;
  try
    mov_modulos.Post
   except
    mov_modulos.Cancel
  end;
  datosdb.refrescar(mov_modulos);
end;

procedure TTFactura_Cuotas.getDatosMovCajaCuotas;
// Objetivo...: Recuperar una Instancia
Begin
  if BuscarMov('005') then codmovcajacuotas := mov_modulos.FieldByName('codmov').AsString else codmovcajacuotas := '';
end;
     
procedure TTFactura_Cuotas.ListarFacturas(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Facturas
Begin
  inherited ListarFacturas(xdesde, xhasta, '***  Comprobantes Emitidos por Cuotas Societarias  ***', salida);
end;

procedure TTFactura_Cuotas.ListarMontosFacturas(xdesde, xhasta, xsubtitulo: String; salida: char);
// Objetivo...: Listar Facturas
Begin
  inherited ListarMontosFacturas(xdesde, xhasta, '***  Comprobantes Emitidos por Cuotas Societarias  ***', salida);
end;

procedure TTFactura_Cuotas.ListarFacturasPendientes(xdfecha, xhfecha: String; salida: char);
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
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  end else
    iniList := True;

  if iniList then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;

  list.Linea(0, 0, '*** Comprobantes Pendientes de Cobro Cuotas Societarias ***', 1, 'Arial, normal, 11', salida, 'S');
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

function  TTFactura_Cuotas.setNombreEntidad(xcodigo: String): String;
// Objetivo...: retornar el nombre de la entidad
Begin
  cliente.getDatos(xcodigo);
  Result := cliente.nombre;
end;

function  TTFactura_Cuotas.setComprobante(xperiodo, xcuota, xcodcli: String): String;
// Objetivo...: prorratear comprobante
begin
  if detfact.IndexFieldNames <> 'Periodo;Cuota;Codcli' then detfact.IndexFieldNames := 'Periodo;Cuota;Codcli';
  if datosdb.Buscar(detfact, 'periodo', 'cuota', 'codcli', xperiodo, xcuota, xcodcli) then
    Result := detfact.FieldByName('tipo').AsString + ' ' + detfact.FieldByName('sucursal').AsString + '-' + detfact.FieldByName('numero').AsString
  else
    Result := '';
  detfact.IndexFieldNames := 'idc;tipo;sucursal;numero;items';
end;

procedure TTFactura_Cuotas.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited conectar;
  netos.conectar;
end;

procedure TTFactura_Cuotas.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
  netos.desconectar;
end;

{===============================================================================}

function factura: TTFactura_Cuotas;
begin
  if xfactura = nil then
    xfactura := TTFactura_Cuotas.Create;
  Result := xfactura;
end;

{===============================================================================}

initialization

finalization
  xfactura.Free;

end.
