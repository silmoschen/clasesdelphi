unit CFactVentaNormal;

interface

uses CFactVenta, ClienGar, CUtiles, SysUtils, CListar, DBTables, CIDBFM;

type

TTFacturaVentaNormal = class(TTFacturaVenta)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   listFactura(salida: char);
  function    getRsocial(xcodcli: string): string; override;

  procedure conectar;
  procedure desconectar;
 private
  conexiones: shortint;
  { Declaraciones Privadas }
end;

function factventa: TTFacturaVentaNormal;

implementation

var
  xfactventa: TTFacturaVentaNormal = nil;

constructor TTFacturaVentaNormal.Create;
begin
  inherited Create;
  tcabecera := datosdb.openDB('cabventa', 'Idcompr;Tipo;Sucursal;Numero');           // Cabecera de la factura
  tdetalle  := datosdb.openDB('detventa', 'Idcompr;Tipo;Sucursal;Numero;Items');     // Detalle de la factura
end;

destructor TTFacturaVentaNormal.Destroy;
begin
  inherited Destroy;
end;

procedure TTFacturaVentaNormal.listFactura(salida: char);
// Objetivo...: Listar Factura
begin
  IniciarInforme(salida);
  separacion     := 52;      // Gradua la separación entre el detalle y los subtotales
  // Atributos del cliente
  clientegar.getDatos(tcabecera.FieldByName('idtitular').AsString);
  rsCliente      := clientegar.nombre;
  telCliente     := clientegar.telcom;
  domCliente     := clientegar.domicilio;
  locCliente     := clientegar.localidad;
  dniCliente     := clientegar.nrodoc;
  cuitCliente    := clientegar.nrocuit;
  codpfisCliente := clientegar.codpfis;
  // Emisión del comprobante
  inherited listCabeceraFact(salida);
  inherited listItemsFact(salida);
  inherited listDistribucionCobros(salida);
  inherited ImprimirFactura(salida);
end;

function TTFacturaVentaNormal.getRsocial(xcodcli: string): string;
// Objetivo...: devolver la razón social del cliente
begin
  clientegar.conectar;
  clientegar.getDatos(xcodcli);
  clientegar.desconectar;
  Result := clientegar.nombre;
end;

procedure TTFacturaVentaNormal.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  inherited conectar;
  if conexiones = 0 then clientegar.conectar;
  Inc(conexiones);
end;

procedure TTFacturaVentaNormal.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  inherited desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then clientegar.desconectar;
end;

{===============================================================================}

function factventa: TTFacturaVentaNormal;
begin
  if xfactventa = nil then
    xfactventa := TTFacturaVentaNormal.Create;
  Result := xfactventa;
end;

{===============================================================================}

initialization

finalization
  xfactventa.Free;

end.
