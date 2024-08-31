unit CSocTit;

interface

uses CBDT, CSocio, COperacion, CCodpost, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM;

type

TTSocioTitular = class(TTSocio)
 public
  { Declaraciones Públicas }
  constructor Create(xcodigo, xnombre, xdomicilio, xcp, xorden, xnrodoc, xtipoper, xcatsocio, xtelefono: string);
  destructor  Destroy; override;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
end;

function sociotitular: TTSocioTitular;

implementation

var
  xsociotitular: TTSocioTitular = nil;

constructor TTSocioTitular.Create(xcodigo, xnombre, xdomicilio, xcp, xorden, xnrodoc, xtipoper, xcatsocio, xtelefono: string);
// Vendedor - Heredada de Persona
begin
  inherited Create(xcodigo, xnombre, xdomicilio, xcp, xorden, xnrodoc, xcatsocio, xtelefono);
  tperso := datosdb.openDB('soctit', 'Codsocio');
  tabla2 := datosdb.openDB('soctih', 'Codsocio');
end;

destructor TTSocioTitular.Destroy;
begin
  inherited Destroy;
end;

procedure TTSocioTitular.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if not tperso.Active then tperso.Open;
  if not tabla2.Active then tabla2.Open;
  cpost.conectar;
end;

procedure TTSocioTitular.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  datosdb.closeDB(tperso);
  datosdb.closeDB(tabla2);
  cpost.desconectar;
end;

{===============================================================================}

function sociotitular: TTSocioTitular;
begin
  if xsociotitular = nil then
    xsociotitular := TTSocioTitular.Create('', '', '', '', '', '', '', '', '');
  Result := xSocioTitular;
end;

{===============================================================================}

initialization

finalization
  xsociotitular.Free;

end.
