unit CCalcIva;

interface

uses CTablaiva, SysUtils, DB, DBTables, tablas, Utiles;

type

TTCalcularIva = class(TObject)            // Superclase
  
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy;




 private
  { Declaraciones Privadas }
end;

function calciva: TTCalcularIva;

implementation

var
  xcalciva: TTCalcularIva = nil;

constructor TTCalcularIva.Create;
begin
  inherited Create;
end;

destructor TTCalcularIva.Destroy;
begin
  inherited Destroy;
end;


{===============================================================================}

function calciva: TTCalcularIva;
begin
  if xcalciva = nil then
    xcalciva := TTCalcularIva.Create;
  Result := xcalciva;
end;

{===============================================================================}

initialization

finalization
  xcalciva.Free;

end.
