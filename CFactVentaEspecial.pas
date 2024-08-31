unit CFactVentaEspecial;

interface

uses CFactVenta, CClientEspecial, CUtiles, SysUtils, DB, DBTables, CIDBFM, CListar;

type

TTFacturaVentaEspecial = class(TTFacturaVenta)
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
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function factvtaesp: TTFacturaVentaEspecial;

implementation

var
  xfactvtaesp: TTFacturaVentaEspecial = nil;

constructor TTFacturaVentaEspecial.Create;
begin
  inherited Create;
  tcabecera := datosdb.openDB('cabventa1', 'Idcompr;Tipo;Sucursal;Numero');           // Cabecera de la factura
  tdetalle  := datosdb.openDB('detventa1', 'Idcompr;Tipo;Sucursal;Numero;Items');     // Detalle de la factura
end;

destructor TTFacturaVentaEspecial.Destroy;
begin
  inherited Destroy;
end;

procedure TTFacturaVentaEspecial.listFactura(salida: char);
// Objetivo...: Listar Factura
begin
  IniciarInforme(salida);
  separacion := 55;      // Gradua la separación entre el detalle y los subtotales
  // Atributos del cliente
  clientespecial.getDatos(tcabecera.FieldByName('idtitular').AsString);
  rsCliente  := clientespecial.nombre;
  telCliente := clientespecial.telcom;
  domCliente := clientespecial.domicilio;
  locCliente := clientespecial.localidad;
  dniCliente := '  ';
  // Emisión del comprobante
  inherited listCabeceraFact(salida);
  inherited listItemsFact(salida);
  inherited listDistribucionCobros(salida);
  inherited ImprimirFactura(salida);
end;

procedure TTFacturaVentaEspecial.listCFIVA(df, hf: string; salida: char);
// Objetivo...: Generar informe de Ventas - Nivel de ruptura por Cóndición Fiscal
begin
  TSQL := datosdb.tranSQL('SELECT fecha, idcompr, tipo, sucursal, numero, idtitular, subtotal, bonif, impuestos, ivari, ivarni, sobretasa, codpfis FROM ' + tcabecera.TableName + ', clientehesp WHERE ' + tcabecera.TableName + '.idtitular = clientehesp.codcli AND fecha >= ' + '''' + utiles.sExprFecha(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(hf) + '''' + ' ORDER BY codpfis, idtitular, fecha');
  inherited llistCFIVA(df, hf, 'Informe de Ventas por Condiciones Fiscales', salida);  // Heredamos, el método se implementa para compas y ventas
end;

function TTFacturaVentaEspecial.getRsocial(xcodcli: string): string;
// Objetivo...: devolver la razón social del cliente
begin
  clientespecial.conectar;
  clientespecial.getDatos(xcodcli);
  clientespecial.desconectar;
  Result := clientespecial.nombre;
end;

procedure TTFacturaVentaEspecial.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  inherited conectar;
  if conexiones = 0 then clientespecial.conectar;
  Inc(conexiones);
end;

procedure TTFacturaVentaEspecial.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  inherited desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then clientespecial.desconectar;
end;

{===============================================================================}

function factvtaesp: TTFacturaVentaEspecial;
begin
  if xfactvtaesp = nil then
    xfactvtaesp := TTFacturaVentaEspecial.Create;
  Result := xfactvtaesp;
end;

{===============================================================================}

initialization

finalization
  xfactvtaesp.Free;

end.
