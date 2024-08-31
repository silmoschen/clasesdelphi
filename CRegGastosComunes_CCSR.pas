unit CRegGastosComunes_CCSR;

interface

uses CRegGastos_CCSR, CGastosComunes_CCSRural, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTRegistracionGastosComunes = class(TTRegistracionGastos)
 public
  { Declaraciones Públicas }
  constructor Create;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
end;

function reggastoscom: TTRegistracionGastosComunes;

implementation

var
  xreggastoscom: TTRegistracionGastosComunes = nil;

constructor TTRegistracionGastosComunes.Create;
// Objetivo...: Cosntruir la instancia de un objeto
begin
  inherited Create;
  registro := datosdb.openDB('movgastoscom', '');
end;

procedure TTRegistracionGastosComunes.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited conectar;
  gastoscom.conectar;
end;

procedure TTRegistracionGastosComunes.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
  gastoscom.desconectar;
end;

{===============================================================================}

function reggastoscom: TTRegistracionGastosComunes;
begin
  if xreggastoscom = nil then
    xreggastoscom := TTRegistracionGastosComunes.Create;
  Result := xreggastoscom;
end;

{===============================================================================}

initialization

finalization
  xreggastoscom.Free;

end.
