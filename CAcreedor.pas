unit CAcreedor;

interface

uses CBDT, CAcreDeu, SysUtils, DB, DBTables, CUtiles, CIDBFM;

type

TTAcreedores = class(TTAcreedorDeudor)
 public
  { Declaraciones Públicas }
  constructor Create(xnrocuit, xnombre, xdomicilio, xcp, xorden, xnumero, xpiso, xdepto, xpartdepto, xfechanac, xnrodoc: string; xtdocnac, xtdocext, xestcivil: byte);
  destructor  Destroy; override;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function acreedor: TTAcreedores;

implementation

var
  xacreedor: TTAcreedores = nil;

constructor TTAcreedores.Create(xnrocuit, xnombre, xdomicilio, xcp, xorden, xnumero, xpiso, xdepto, xpartdepto, xfechanac, xnrodoc: string; xtdocnac, xtdocext, xestcivil: byte);
// Vendedor - Heredada de Persona
begin
  inherited Create(xnrocuit, xnombre, xdomicilio, xcp, xorden, xnumero, xpiso, xdepto, xpartdepto, xfechanac, xnrodoc, xtdocnac, xtdocext, xestcivil);
  tperso    := datosdb.openDB('acreedor', 'nrocuit');
  tabla2    := datosdb.openDB('acreedh1', 'nrocuit');
end;

destructor TTAcreedores.Destroy;
begin
  inherited Destroy;
end;

procedure TTAcreedores.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    inherited conectar;
    if not tperso.Active then tperso.Open;
    if not tabla2.Active then tabla2.Open;
  end;
  Inc(conexiones);
end;

procedure TTAcreedores.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    inherited desconectar;
    datosdb.closeDB(tperso);
    datosdb.closeDB(tabla2);
  end;
end;

{===============================================================================}

function acreedor: TTAcreedores;
begin
  if xacreedor = nil then
    xacreedor := TTAcreedores.Create('', '', '', '', '', '', '', '', '', '', '', 0, 0, 0);
  Result := xacreedor;
end;

{===============================================================================}

initialization

finalization
  xacreedor.Free;

end.

