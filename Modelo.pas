unit Modelo;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTPrestatario = class
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function prestatario: TTPrestatario;

implementation

var
  xprestatario: TTPrestatario = nil;

constructor TTPrestatario.Create;
begin
end;

destructor TTPrestatario.Destroy;
begin
  inherited Destroy;
end;


procedure TTPrestatario.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
  end;
  Inc(conexiones);
end;

procedure TTPrestatario.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
  end;
end;

{===============================================================================}

function prestatario: TTPrestatario;
begin
  if xprestatario = nil then
    xprestatario := TTPrestatario.Create;
  Result := xprestatario;
end;

{===============================================================================}

initialization

finalization
  xprestatario.Free;

end.
