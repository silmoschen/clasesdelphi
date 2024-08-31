unit CContabilidad;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CIDBFM;

type

TTContabilidad = class(TObject)
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
  inherited Create;
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
