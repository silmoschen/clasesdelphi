unit CRecibosCCE;

interface

uses CFacturasCCE, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM,
     CClienteCCE, Classes, CCNetos, CAdmNumCompr, CDistribucionCobrosCCE,
     CBancos, Contnrs;

type

TTRecibos = class(TTFactura)
  codmov, codmovcajacuotas: String;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Registrar(xidc, xtipo, xsucursal, xnumero, xcodcli, xfecha, xitems, xdescrip, xreferencia: String; xmonto: Real);
  procedure   Borrar(xreferencia: String);

  procedure   ImprimirRecibo(xreferencia: String; salida: char);

  function    BuscarMovIva: Boolean;
  procedure   RegistrarMovIva(xcodmov: String);
  procedure   getDatosMovIva;

  procedure   RegistrarMovCajaCuotas(xcodmov: String);
  procedure   getDatosMovCajaCuotas;

  procedure   ListarFacturas(xdesde, xhasta: String; salida: char);

  function    setNombreEntidad(xcodigo: String): String; override;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  function    BuscarMov(xcodigo: String): Boolean;
end;

function recibo: TTRecibos;

implementation

var
  xrecibo: TTRecibos = nil;

constructor TTRecibos.Create;
begin
  cabfact      := datosdb.openDB('recibos', '');
  detfact      := datosdb.openDB('recibosdet', '');
  modeloImp    := datosdb.openDB('modeloImpr', '');
  observac     := datosdb.openDB('obs_cuotas', '');
  mov_modulos  := datosdb.openDB('mov_modulos', '');
end;

destructor TTRecibos.Destroy;
begin
  inherited Destroy;
end;

procedure TTRecibos.Registrar(xidc, xtipo, xsucursal, xnumero, xcodcli, xfecha, xitems, xdescrip, xreferencia: String; xmonto: Real);
// Objetivo...: Registrar Recibo
Begin
  if xitems = '01' then Begin
    if BuscarFact(xidc, xtipo, xsucursal, xnumero) then cabfact.Edit else cabfact.Append;
    cabfact.FieldByName('idc').AsString        := xidc;
    cabfact.FieldByName('tipo').AsString       := xtipo;
    cabfact.FieldByName('sucursal').AsString   := xsucursal;
    cabfact.FieldByName('numero').AsString     := xnumero;
    cabfact.FieldByName('codcli').AsString     := xcodcli;
    cabfact.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfecha);
    cabfact.FieldByName('referencia').AsString := xreferencia;
    try
      cabfact.Post
     except
      cabfact.Cancel
    end;
    datosdb.closeDB(cabfact); cabfact.Open;

    if BuscarDetFact(xidc, xtipo, xsucursal, xnumero, '01') then Begin
      datosdb.tranSQL('delete from ' + detfact.TableName + ' where referencia = ' + '''' + xreferencia + '''');
      datosdb.closeDB(detfact); detfact.Open;
    end;
  end;

  if BuscarDetFact(xidc, xtipo, xsucursal, xnumero, xitems) then detfact.Edit else detfact.Append;
  detfact.FieldByName('idc').AsString        := xidc;
  detfact.FieldByName('tipo').AsString       := xtipo;
  detfact.FieldByName('sucursal').AsString   := xsucursal;
  detfact.FieldByName('numero').AsString     := xnumero;
  detfact.FieldByName('items').AsString      := xitems;
  detfact.FieldByName('cantidad').AsFloat    := 1;
  detfact.FieldByName('descrip').AsString    := xdescrip;
  detfact.FieldByName('monto').AsFloat       := xmonto;
  detfact.FieldByName('referencia').AsString := xreferencia;
  try
    detfact.Post
   except
    detfact.Cancel
  end;
  datosdb.refrescar(detfact);
end;

procedure TTRecibos.Borrar(xreferencia: String);
// Objetivo...: Borrar Comprobante
Begin
  datosdb.tranSQL('delete from ' + cabfact.TableName + ' where referencia = ' + '''' + xreferencia + '''');
  datosdb.closeDB(cabfact); cabfact.Open;
  datosdb.tranSQL('delete from ' + detfact.TableName + ' where referencia = ' + '''' + xreferencia + '''');
  datosdb.closeDB(detfact); detfact.Open;
end;

procedure TTRecibos.ImprimirRecibo(xreferencia: String; salida: char);
// Objetivo...: Imprimir Factura
var
  z, n: TStringList;
  l: TObjectList;
  objeto: TTDistribucion;
  i, lineas, xi, p1, p2: Integer;
  t: Real;
  il: String;
begin
  list.Setear(salida);
  list.NoImprimirPieDePagina;
  cabfact.IndexFieldNames := 'Referencia';
  if cabfact.FindKey([xreferencia]) then Begin
  cabfact.IndexFieldNames := 'idc;tipo;sucursal;numero';
  if BuscarFact(cabfact.FieldByName('idc').AsString, cabfact.FieldByName('tipo').AsString, cabfact.FieldByName('sucursal').AsString, cabfact.FieldByName('numero').AsString) then Begin
  getDatosFact(cabfact.FieldByName('idc').AsString, cabfact.FieldByName('tipo').AsString, cabfact.FieldByName('sucursal').AsString, cabfact.FieldByName('numero').AsString);
  cliente.getDatos(entidad);

  // Recuperamos el Formato del Recibo
  administnum.conectar;
  administnum.getReciboPagos;
  getDatosFormato(administnum.NidRecibo + administnum.NcodRecibo);
  administnum.desconectar;

  lineas := 0;

  // Cabecera ------------------------------------------------------------------
  list.IniciarMemoImpresiones(modeloImp, 'cabecera', 600);
  list.RemplazarEtiquetasEnMemo('#fecha', fecha);
  list.RemplazarEtiquetasEnMemo('#razon_social', utiles.StringLongitudFija(cliente.Nombre, 50));
  list.RemplazarEtiquetasEnMemo('#domicilio', utiles.StringLongitudFija(cliente.Domicilio, 40));
  list.RemplazarEtiquetasEnMemo('#cuit', cliente.Nrocuit);
  list.RemplazarEtiquetasEnMemo('#codpfis', cliente.Codpfis);
  list.RemplazarEtiquetasEnMemo('#localidad', cliente.localidad);
  list.RemplazarEtiquetasEnMemo('#codpost', cliente.codpost);
  list.RemplazarEtiquetasEnMemo('#provincia', cliente.provincia);

  z := list.setContenidoMemo;
  For i := 1 to z.Count do
    list.Linea(0, 0, z.Strings[i-1], 1, 'Courier New, Normal, 9', salida, 'S');

  // Detalle -------------------------------------------------------------------
  if BuscarDetFact(cabfact.FieldByName('idc').AsString, cabfact.FieldByName('tipo').AsString, cabfact.FieldByName('sucursal').AsString, cabfact.FieldByName('numero').AsString, '01') then Begin
    while not detfact.Eof do Begin
      if (detfact.FieldByName('idc').AsString <> cabfact.FieldByName('idc').AsString) or (detfact.FieldByName('tipo').AsString <> cabfact.FieldByName('tipo').AsString) or (detfact.FieldByName('sucursal').AsString <> cabfact.FieldByName('sucursal').AsString) or (detfact.FieldByName('numero').AsString <> cabfact.FieldByName('numero').AsString) then Break;
      list.IniciarMemoImpresiones(modeloImp, 'detalle', 600);
      list.RemplazarEtiquetasEnMemo('#descripcion', utiles.StringLongitudFija(Copy(detfact.FieldByName('descrip').AsString, 1, 40), 40));
      list.RemplazarEtiquetasEnMemo('#monto', utiles.sLlenarIzquierda(utiles.FormatearNumero(FloatToStr( detfact.FieldByName('monto').AsFloat * detfact.FieldByName('cantidad').AsFloat )), 9, ' '));
      list.RemplazarEtiquetasEnMemo('#comprobante', '');

      n := list.setContenidoMemo;
      For i := 1 to n.Count do
        list.Linea(0, 0, n.Strings[i-1], 1, 'Courier New, Normal, 9', salida, 'S');

      Inc(lineas);
      detfact.Next;
    end;

    list.Linea(0, 0, '', 1, 'Courier New, Normal, 9', salida, 'S');
    Inc(lineas);
    list.Linea(0, 0, '', 1, 'Courier New, Normal, 9', salida, 'S');
    Inc(lineas);

    // Detalle de Efectivo y cheques
    distribucion.conectar;
    entbcos.conectar;
    distribucion.getDatosRefDistCobro(xreferencia);
    list.Linea(0, 0, '      Efectivo: ', 1, 'Courier New, Normal, 9', salida, 'N');
    list.importe(27, list.Lineactual, '', distribucion.Efectivo, 2, 'Courier New, Normal, 9');
    list.Linea(29, list.Lineactual, 'Cheques: ', 3, 'Courier New, Normal, 9', salida, 'N');
    list.importe(50, list.Lineactual, '', distribucion.Cheques, 4, 'Courier New, Normal, 9');
    list.Linea(52, list.Lineactual, 'Ret. I.V.A.: ', 5, 'Courier New, Normal, 9', salida, 'N');
    list.importe(70, list.Lineactual, '', distribucion.Retencion1, 6, 'Courier New, Normal, 9');
    list.Linea(72, list.Lineactual, 'Ret. Contr.: ', 7, 'Courier New, Normal, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', distribucion.retencion2, 8, 'Courier New, Normal, 9');
    list.Linea(96, list.Lineactual, '', 9, 'Courier New, Normal, 9', salida, 'S');
    t := distribucion.Efectivo + distribucion.Cheques;
    Inc(lineas);

    // Cheques
    l := distribucion.setDatosChequeReferencia(xreferencia);

    list.Linea(0, 0, '', 1, 'Courier New, Normal, 9', salida, 'S');
    Inc(lineas);

    For i := 1 to l.Count do Begin
      objeto := TTDistribucion(l.Items[i-1]);
      entbcos.getDatos(objeto.Codbanco);

      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(8, list.Lineactual, objeto.FechaCheque + '  ' + objeto.Nrocheque, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(26, list.Lineactual, Copy(entbcos.descrip, 1, 30), 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(60, list.Lineactual, objeto.Filial, 4, 'Arial, normal, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', objeto.Monto, 5, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
      Inc(lineas);
    end;

    if l <> Nil then
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

    l.Free; l := Nil;

    entbcos.desconectar;
    distribucion.desconectar;
  end;


  For i := lineas to lineasdet do list.Linea(0, 0, '', 1, 'Courier New, Normal, 9', salida, 'S');

  // Subtotal ------------------------------------------------------------------
  list.IniciarMemoImpresiones(modeloImp, 'pie', 550);
  list.RemplazarEtiquetasEnMemo('#total', utiles.sLlenarIzquierda( utiles.FormatearNumero(FloatToStr(t), '########0.00'), 10, ' '));
  il := utiles.FormatearNumero(FloatToStr(t));
  xi := StrToInt(Copy(il, 1, Length(Trim(il)) - 3));
  list.RemplazarEtiquetasEnMemo('#importeenletras', LowerCase(utiles.xIntToLletras(xi) + ' C/ ' + Copy(il, Length(Trim(il)) - 1, 2)));

  z := list.setContenidoMemo;
  For i := 1 to z.Count do
    list.Linea(0, 0, z.Strings[i-1], 1, 'Courier New, Normal, 9', salida, 'S');

  end;

  end;

  if z <> Nil then Begin
    z.Destroy; z := Nil;
  end;
  if n <> Nil then Begin
    n.Destroy; n := Nil;
  end;

  list.FinList;
end;

function  TTRecibos.BuscarMov(xcodigo: String): Boolean;
// Objetivo...: Buscar una Instancia
Begin
  Result := mov_modulos.FindKey([xcodigo]);
end;

function  TTRecibos.BuscarMovIva: Boolean;
// Objetivo...: Buscar una Instancia
Begin
  Result := BuscarMov('001');
end;

procedure TTRecibos.RegistrarMovIva(xcodmov: String);
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

procedure TTRecibos.getDatosMovIva;
// Objetivo...: Recuperar una Instancia
Begin
  if BuscarMovIva then codmov := mov_modulos.FieldByName('codmov').AsString else codmov := '';
end;

procedure TTRecibos.RegistrarMovCajaCuotas(xcodmov: String);
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

procedure TTRecibos.getDatosMovCajaCuotas;
// Objetivo...: Recuperar una Instancia
Begin
  if BuscarMov('005') then codmovcajacuotas := mov_modulos.FieldByName('codmov').AsString else codmovcajacuotas := '';
end;
     
procedure TTRecibos.ListarFacturas(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Facturas
Begin
  inherited ListarFacturas(xdesde, xhasta, '***  Comprobantes Emitidos por Cuotas Societarias  ***', salida);
end;

function  TTRecibos.setNombreEntidad(xcodigo: String): String;
// Objetivo...: retornar el nombre de la entidad
Begin
  cliente.getDatos(xcodigo);
  Result := cliente.nombre;
end;

procedure TTRecibos.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited conectar;
  netos.conectar;
end;

procedure TTRecibos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
  netos.desconectar;
end;

{===============================================================================}

function recibo: TTRecibos;
begin
  if xrecibo = nil then
    xrecibo := TTRecibos.Create;
  Result := xrecibo;
end;

{===============================================================================}

initialization

finalization
  xrecibo.Free;

end.
