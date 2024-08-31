unit CFactCompra;

interface

uses CComprobantes, CProve, CStock, SysUtils, DB, DBTables, CIDBFM, CUtiles, CTablaIva;

type

TTFacturaCompra = class(TTComprobantereg)            // Superclase
  rsProveedor: string;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function  getProveedor(xcodprov: string): string;

  procedure getDatos(xIdcompr, xTipo, xSucursal, xNumero, xIdtitular: string);
  function  setItems(xidcompr, xtipo, xsucursal, xnumero, xidtitular: string): TQuery;
  function  verifProveedor(xcodprov: string): boolean;

  procedure Borrar(xidcompr, xtipo, xsucursal, xnumero, xidtitular: string);
  procedure Grabar(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xfecha, xremito, xitems, xcodart, xidart: string; xctcc: integer; xsubtotal, xbonificacion, ximpuestos, xivari, xivarni, xsobretasa, xcantidad, xprecio, xdescuento: real);

  procedure listFechas(df, hf: string; salida: char);
  procedure listCliProv(df, hf: string; salida: char);
  procedure listCFIva(df, hf: string; salida: char);
  procedure listCTADO(df, hf: string; salida: char);
  procedure listCC(df, hf: string; salida: char);

  procedure conectar;
  procedure desconectar;
 private
  conexiones: shortint;
  { Declaraciones Privadas }
end;

function factcompra: TTFacturaCompra;

implementation

var
  xfactcompra: TTFacturaCompra = nil;

constructor TTFacturaCompra.Create;
begin
  inherited Create;
  tdetalle  := datosdb.openDB('detcompr',  'Idcompr;Tipo;Sucursal;Numero;Idtitular;Items');
  tcabecera := datosdb.openDB('cabcomp', 'Idcompr;Tipo;Sucursal;Numero;Idtitular');
end;

destructor TTFacturaCompra.Destroy;
begin
  inherited Destroy;
end;

function TTFacturaCompra.verifProveedor(xcodprov: string): boolean;
// Objetivo...: Verificar la existencia del Proveedor
begin
  if proveedor.Buscar(xcodprov) then Result := True else Result := False;
end;

function TTFacturaCompra.getProveedor(xcodprov: string): string;
// Objetivo...: Devolver la Razón Social del Proveedor
begin
  proveedor.getDatos(xcodprov);
  Result := proveedor.Nombre;
end;

procedure TTFacturaCompra.Borrar(xidcompr, xtipo, xsucursal, xnumero, xidtitular: string);
// Objetivo...: Eliminar un Comprobante
begin
  if BuscarCab(xidcompr, xtipo, xsucursal, xnumero, xidtitular) then
    begin
      BorrarLineas(xidcompr, xtipo, xsucursal, xnumero, xidtitular);  // Líneas de la Factura
      tcabecera.Delete;      // Cabecera
    end;
end;

procedure TTFacturaCompra.getDatos(xIdcompr, xTipo, xSucursal, xNumero, xIdtitular: string);
// Objetivo...: Cargar Datos
begin
  tdetalle.Refresh; tcabecera.Refresh;
  inherited getDatos(xIdcompr, xtipo, xsucursal, xnumero, xidtitular);
  rsProveedor := getProveedor(xIdtitular);
end;

function TTFacturaCompra.setItems(xIdcompr, xTipo, xSucursal, xNumero, xIdtitular: string): TQuery;
// Objetivo...: Extraer el detalle para una factura dada
begin
  Result := datosdb.tranSQL('SELECT * FROM detcompr WHERE idcompr = ' + '''' + xidcompr + '''' + ' and tipo = ' + '''' + xtipo + '''' + ' and sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''' + ' and idtitular = ' + '''' + xidtitular + '''');
end;

procedure TTFacturaCompra.Grabar(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xfecha, xremito, xitems, xcodart, xidart: string; xctcc: integer; xsubtotal, xbonificacion, ximpuestos, xivari, xivarni, xsobretasa, xcantidad, xprecio, xdescuento: real);
// Objetivo...: Grabar los datos de una Factura
begin
  if xitems <= '001' then
    begin
      GrabarCab(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xfecha, xremito, xctcc, xsubtotal, xbonificacion, ximpuestos, xivari, xivarni, xsobretasa, 0, 0, '');
      if _existe then BorrarLineas(xidcompr, xtipo, xsucursal, xnumero, xidtitular);  // Líneas de la Factura
    end;
  GrabarItems(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xitems, xcodart, '', xidart, xfecha, '', xcantidad, xprecio, xdescuento);
end;

procedure TTFacturaCompra.listFechas(df, hf: string; salida: char);
// Objetivo...: Generar informe de Ventas - Nivel de ruptura por fecha
begin
  TSQL := datosdb.tranSQL('SELECT cabcomp.fecha, cabcomp.idcompr, cabcomp.tipo, cabcomp.sucursal, cabcomp.numero, provedor.rsocial, cabcomp.subtotal, cabcomp.bonif, cabcomp.impuestos, cabcomp.ivari, cabcomp.ivarni, cabcomp.sobretasa ' +
                          ' FROM cabcomp, provedor WHERE ' + ' fecha >= ' + '''' + utiles.sExprFecha(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(hf) + '''' + ' AND cabcomp.idtitular = provedor.codprov ' + ' ORDER BY fecha');
  inherited llistFechas(df, hf, 'Informe de Compras por Fecha', salida);  // Heredamos, el método se implementa para compas y ventas
end;

procedure TTFacturaCompra.listCliProv(df, hf: string; salida: char);
// Objetivo...: Generar informe de Ventas - Nivel de ruptura por fecha
begin
  TSQL := datosdb.tranSQL('SELECT cabcomp.fecha, cabcomp.idcompr, cabcomp.tipo, cabcomp.sucursal, cabcomp.numero, provedor.codprov AS clipro, provedor.rsocial, cabcomp.subtotal, cabcomp.bonif, cabcomp.impuestos, cabcomp.ivari, cabcomp.ivarni, cabcomp.sobretasa ' +
                          ' FROM cabcomp, provedor WHERE ' + ' fecha >= ' + '''' + utiles.sExprFecha(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(hf) + '''' + ' AND cabcomp.idtitular = provedor.codprov ' + ' ORDER BY codprov, fecha');
  inherited llistCliProv(df, hf, 'Informe de Compras por Proveedor', salida);  // Heredamos, el método se implementa para compas y ventas
end;

procedure TTFacturaCompra.listCFIVA(df, hf: string; salida: char);
// Objetivo...: Generar informe de Ventas - Nivel de ruptura por Cóndición Fiscal
begin
  TSQL := datosdb.tranSQL('SELECT cabcomp.fecha, cabcomp.idcompr, cabcomp.tipo, cabcomp.sucursal, cabcomp.numero, provedor.codprov AS clipro, provedor.rsocial, provedoh.codpfis, cabcomp.subtotal, cabcomp.bonif, cabcomp.impuestos, cabcomp.ivari, cabcomp.ivarni, ' +
                          'cabcomp.sobretasa FROM cabcomp, provedor, provedoh WHERE ' + ' fecha >= ' + '''' + utiles.sExprFecha(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(hf) + '''' + ' AND cabcomp.idtitular = provedor.codprov AND provedor.codprov = provedoh.codprov ORDER BY codpfis, codprov, fecha');
  inherited llistCFIVA(df, hf, 'Informe de Compras por Condiciones Fiscales', salida);  // Heredamos, el método se implementa para compas y ventas
end;

procedure TTFacturaCompra.listCTADO(df, hf: string; salida: char);
// Objetivo...: Generar informe de Ventas - Nivel de ruptura por tipo de operacion (contado y cuenta corriente)
begin
  TSQL := datosdb.tranSQL('SELECT cabcomp.fecha, cabcomp.idcompr, cabcomp.tipo, cabcomp.sucursal, cabcomp.numero, cabcomp.cc, provedor.codprov AS clipro, provedor.rsocial, cabcomp.subtotal, cabcomp.bonif, cabcomp.impuestos, cabcomp.ivari, cabcomp.ivarni, ' +
                          'cabcomp.sobretasa FROM cabcomp, provedor WHERE ' + ' fecha >= ' + '''' + utiles.sExprFecha(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(hf) + '''' + ' AND cabcomp.idtitular = provedor.codprov AND cabcomp.cc = 1 ORDER BY cc, fecha');
  inherited llistCTADOCC(df, hf, 'Informe de Compras de Contado', salida);  // Heredamos, el método se implementa para compas y ventas
end;

procedure TTFacturaCompra.listCC(df, hf: string; salida: char);
// Objetivo...: Generar informe de Ventas - Nivel de ruptura por tipo de operacion (contado y cuenta corriente)
begin
  TSQL := datosdb.tranSQL('SELECT cabcomp.fecha, cabcomp.idcompr, cabcomp.tipo, cabcomp.sucursal, cabcomp.numero, cabcomp.cc, provedor.codprov AS clipro, provedor.rsocial, cabcomp.subtotal, cabcomp.bonif, cabcomp.impuestos, cabcomp.ivari, cabcomp.ivarni, ' +
                          'cabcomp.sobretasa FROM cabcomp, provedor WHERE ' + ' fecha >= ' + '''' + utiles.sExprFecha(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(hf) + '''' + ' AND cabcomp.idtitular = provedor.codprov AND cabcomp.cc = 2 ORDER BY cc, fecha');
  inherited llistCTADOCC(df, hf, 'Informe de Compras en Cuenta Corriente', salida);  // Heredamos, el método se implementa para compas y ventas
end;

procedure TTFacturaCompra.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    inherited conectar;
    if not tdetalle.Active then tdetalle.Open;
    if not tcabecera.Active then tcabecera.Open;
    proveedor.conectar;
    tabliva.conectar;
  end;
  Inc(conexiones);
end;

procedure TTFacturaCompra.desconectar;
// Objetivo...: conectar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    inherited desconectar;
    datosdb.closeDB(tdetalle);
    datosdb.closeDB(tcabecera);
    proveedor.desconectar;
    stock.desconectar;
    tabliva.desconectar;
  end;
end;

{===============================================================================}

function factcompra: TTFacturaCompra;
begin
  if xfactcompra = nil then
    xfactcompra := TTFacturaCompra.Create;
  Result := xfactcompra;
end;

{===============================================================================}

initialization

finalization
  xfactcompra.Free;

end.
