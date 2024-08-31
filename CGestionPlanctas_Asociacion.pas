// agregar: copiarmovimiento, testintegridad

unit CGestionPlanctas_Asociacion;

interface

uses CGestionPlanctas, Capitul, CUtiles, SysUtils, DB, DBTables, CBDT, Forms, CIDBFM;

type

TTGestCuentas_Asoc = class(TTGestCuentas)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
end;

function gestplanctas: TTGestCuentas_Asoc;

implementation

var
  xgestplanctas: TTGestCuentas_Asoc = nil;

constructor TTGestCuentas_Asoc.Create;
begin
  inherited Create;
end;

destructor TTGestCuentas_Asoc.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function gestplanctas: TTGestCuentas_Asoc;
begin
  if xgestplanctas = nil then
    xgestplanctas := TTGestCuentas_Asoc.Create;
  Result := xgestplanctas;
end;

{===============================================================================}

initialization

finalization
  xgestplanctas.Free;

end.
