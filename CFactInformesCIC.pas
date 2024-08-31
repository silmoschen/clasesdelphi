unit CFactInformesCIC;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CFactCIC;

type

TTFactInfCIC = class(TTFact)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
end;

function factinforme: TTFactInfCIC;

implementation

var
  xfactinforme: TTFactInfCIC = nil;

constructor TTFactInfCIC.Create;
begin
  cabfact := datosdb.openDB('cabfact_inf', '');
  detfact := datosdb.openDB('detfact_inf', '');
end;

destructor TTFactInfCIC.Destroy;
begin
  inherited Destroy;
end;


procedure TTFactInfCIC.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited conectar;
end;

procedure TTFactInfCIC.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
end;

{===============================================================================}

function factinforme: TTFactInfCIC;
begin
  if xfactinforme = nil then
    xfactinforme := TTFactInfCIC.Create;
  Result := xfactinforme;
end;

{===============================================================================}

initialization

finalization
  xfactinforme.Free;

end.
