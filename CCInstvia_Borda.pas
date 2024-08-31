unit CCInstvia_Borda;

interface

uses SysUtils, CUtiles, CCNetos, CIvacompra_Borda, CIvaventa_Borda, CCliente, CProve,
     CVias, CBDT, CEmpresas;

type

TTCVias = class(TObject)            // Superclase
   empr, cuit, codpfis, viaiva: string;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    conectarIvacompra(xvia: string): boolean;
  function    conectarIvaventas(xvia: string): boolean;
  function    conectarClientes(xvia: string): boolean;
  function    conectarProveedores(xvia: string): boolean;
  function    conectarNetos(xvia: string): boolean;

  procedure   desconectarIvacompras;
  procedure   desconectarIvaventas;
  procedure   desconectarClientes;
  procedure   desconectarProveedores;
  procedure   desconectarNetos;
 private
  { Declaraciones Privadas }
  function testVia: boolean;
end;

function instvia: TTCVias;

implementation

var
  xinstvia: TTCVias = nil;

constructor TTCVias.Create;
begin
  inherited Create;
end;

destructor TTCVias.Destroy;
begin
  inherited Destroy;
end;

function TTCVias.TestVia: boolean;
// Objetivo...: Testear Vía contabilidad
begin
  Result := False;
  empresa.conectar;
  viaiva := empresa.Nomvia;
  if Length(Trim(viaiva)) > 0 then Result := True;
  empr := empresa.nombre;
  empresa.desconectar;
end;

function TTCVias.conectarIvacompra(xvia: string): boolean;
// Objetivo...: conectar Vía I.V.A. compras correspondiente
begin
  if testVia then Begin
    ivac.Via(viaiva);
    Result := True;
   end
  else Result := False;
end;

function TTCVias.conectarIvaventas(xvia: string): boolean;
// Objetivo...: conectar Vía I.V.A. compras correspondiente
begin
  if testVia then Begin
    ivav.Via(viaiva);
    Result := True;
   end
  else Result := False;
end;

function TTCVias.conectarClientes(xvia: string): boolean;
// Objetivo...: conectar Vía I.V.A. compras correspondiente
begin
  if testVia then Begin
    cliente.Via(viaiva);
    Result := True;
   end
  else Result := False;
end;

function TTCVias.conectarProveedores(xvia: string): boolean;
// Objetivo...: conectar Vía Proveedores
begin
  if testVia then Begin
    proveedor.Via(viaiva);
    Result := True;
   end
  else Result := False;
end;

function TTCVias.conectarNetos(xvia: string): boolean;
// Objetivo...: conectar Vía Netos discriminados
begin
  if testVia then Begin
    netos.Via(viaiva);
    Result := True;
   end
  else Result := False;
end;

procedure TTCVias.desconectarIvacompras;
// Objetivo...: desconectar Vía I.V.A. compras
begin
  ivac.desconectar;
end;

procedure TTCVias.desconectarIvaventas;
// Objetivo...: desconectar Vía I.V.A. ventas
begin
  ivav.desconectar;
end;

procedure TTCVias.desconectarClientes;
// Objetivo...: desconectar Clientes
begin
  cliente.desconectar;
end;

procedure TTCVias.desconectarProveedores;
// Objetivo...: desconectar Proveedores
begin
  proveedor.desconectar;
end;

procedure TTCVias.desconectarNetos;
// Objetivo...: desconectar Netos
begin
  netos.desconectar;
end;

{===============================================================================}

function instvia: TTCVias;
begin
  if xinstvia = nil then
    xinstvia := TTCVias.Create;
  Result := xinstvia;
end;

{===============================================================================}

initialization

finalization
  xinstvia.Free;

end.