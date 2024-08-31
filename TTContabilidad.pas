unit TTContabilidad;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTContabilidad = class(TTPersona)
  conexion: String;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

 private
  { Declaraciones Privadas }
end;

function contabilidad: TTContabilidad;

implementation

var
  xcontabilidad: TTContabilidad = nil;

constructor TTContabilidad.Create;
begin
end;

destructor TTContabilidad.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function contabilidad: TTContabilidad;
begin
  if xcontabilidad = nil then
    xcontabilidad := TTContabilidad.Create;
  Result := xcontabilidad;
end;

{===============================================================================}

initialization

finalization
  xcontabilidad.Free;

end.
