unit CFactCuotasCIC;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CFactCIC;

type

TTFactCIC = class(TTFact)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
end;

function factcuotas: TTFactCIC;

implementation

var
  xfactcuotas: TTFactCIC = nil;

constructor TTFactCIC.Create;
begin
  cabfact := datosdb.openDB('cabfact_cuotas', '');
  detfact := datosdb.openDB('detfact_cuotas', '');
end;

destructor TTFactCIC.Destroy;
begin
  inherited Destroy;
end;


procedure TTFactCIC.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited conectar;
end;

procedure TTFactCIC.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
end;

{===============================================================================}

function factcuotas: TTFactCIC;
begin
  if xfactcuotas = nil then
    xfactcuotas := TTFactCIC.Create;
  Result := xfactcuotas;
end;

{===============================================================================}

initialization

finalization
  xfactcuotas.Free;

end.
