unit CRemitosGross;

interface

uses CRemitos, CClienteGross, SysUtils, DBTables, CIDBFM, CUtiles;

type

TTRemitosN = class(TTRemitos)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure conectar;
  procedure desconectar;
 protected
  procedure getDatosCliente(xcodcli: String); override;
 private
   { Declaraciones Privadas }
end;

function remito: TTRemitosN;

implementation

var
  xremito: TTRemitosN = nil;

constructor TTRemitosN.Create;
begin
  inherited Create;
  cabecera    := datosdb.openDB('remitocab', 'Idc;Tipo;Sucursal;Numero');
  detalle     := datosdb.openDB('remitodet', 'Idc;Tipo;Sucursal;Numero;Items');
  remitosfact := datosdb.openDB('remitofact', 'Idcf;Tipof;Sucursalf;Numerof;Items');
end;

destructor TTRemitosN.Destroy;
begin
  inherited Destroy;
end;

procedure TTRemitosN.getDatosCliente(xcodcli: String);
begin
  cliente.getDatos(xcodcli);
  nombre := cliente.nombre;
  cuit   := cliente.nrocuit;
end;

procedure TTRemitosN.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  inherited conectar;
  cliente.conectar;
end;

procedure TTRemitosN.desconectar;
// Objetivo...: conectar tablas de persistencia
begin
  inherited desconectar;
  cliente.desconectar;
end;

{===============================================================================}

function remito: TTRemitosN;
begin
  if xremito = nil then
    xremito := TTRemitosN.Create;
  Result := xremito;
end;

{===============================================================================}

initialization

finalization
  xremito.Free;

end.
