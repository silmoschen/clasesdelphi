unit CFactVentaExtra;

interface

uses CFactVenta, CClientExtra, CUtiles, SysUtils, DB, DBTables, CIDBFM, CListar;

type

TTFacturaVentaExtra = class(TTFacturaVenta)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   listFactura(salida: char);
  procedure   listCFIva(df, hf: string; salida: char); override;
  function    getRsocial(xcodcli: string): string; override;

  procedure conectar;
  procedure desconectar;
 private
  conexiones: shortint;
  { Declaraciones Privadas }
end;

function factvtaextra: TTFacturaVentaExtra;

implementation

var
  xfactvtaextra: TTFacturaVentaExtra = nil;

constructor TTFacturaVentaExtra.Create;
begin
  inherited Create;
  tcabecera := datosdb.openDB('cabventa2', 'Idcompr;Tipo;Sucursal;Numero');           // Cabecera de la factura
  tdetalle  := datosdb.openDB('detventa2', 'Idcompr;Tipo;Sucursal;Numero;Items');     // Detalle de la factura
end;

destructor TTFacturaVentaExtra.Destroy;
begin
  inherited Destroy;
end;

procedure TTFacturaVentaExtra.listFactura(salida: char);
// Objetivo...: Listar Factura
begin
  IniciarInforme(salida);
  separacion := 55;      // Gradua la separación entre el detalle y los subtotales
  // Atributos del cliente
  clienteextra.getDatos(tcabecera.FieldByName('idtitular').AsString);
  rsCliente  := clienteextra.nombre;
  telCliente := clienteextra.telcom;
  domCliente := clienteextra.domicilio;
  locCliente := clienteextra.localidad;
  dniCliente := '  ';
  // Emisión del comprobante
  inherited listCabeceraFact(salida);
  inherited listItemsFact(salida);
  inherited listDistribucionCobros(salida);
  inherited ImprimirFactura(salida);
end;

procedure TTFacturaVentaExtra.listCFIVA(df, hf: string; salida: char);
// Objetivo...: Generar informe de Ventas - Nivel de ruptura por Cóndición Fiscal
begin
  TSQL := datosdb.tranSQL('SELECT fecha, idcompr, tipo, sucursal, numero, idtitular, subtotal, bonif, impuestos, ivari, ivarni, sobretasa, codpfis FROM ' + tcabecera.TableName + ', clienteh WHERE ' + tcabecera.TableName + '.idtitular = clienteh.codcli AND fecha >= ' + '''' + utiles.sExprFecha(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(hf) + '''' + ' ORDER BY codpfis, idtitular, fecha');
  inherited llistCFIVA(df, hf, 'Informe de Ventas por Condiciones Fiscales', salida);  // Heredamos, el método se implementa para compas y ventas
end;

function TTFacturaVentaExtra.getRsocial(xcodcli: string): string;
// Objetivo...: devolver la razón social del cliente
begin
  clienteextra.conectar;
  clienteextra.getDatos(xcodcli);
  clienteextra.desconectar;
  Result := clienteextra.nombre;
end;

procedure TTFacturaVentaExtra.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  inherited conectar;
  if conexiones = 0 then clienteextra.conectar;
  Inc(conexiones);
end;

procedure TTFacturaVentaExtra.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  inherited desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then clienteextra.desconectar;
end;

{===============================================================================}

function factvtaextra: TTFacturaVentaExtra;
begin
  if xfactvtaextra = nil then
    xfactvtaextra := TTFacturaVentaExtra.Create;
  Result := xfactvtaextra;
end;

{===============================================================================}

initialization

finalization
  xfactvtaextra.Free;

end.
