unit CSHMC;

interface

uses SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM;

type

TTCSHMC = class(TObject)            // Superclase
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
end;

function shmc: TTCSHMC;

implementation

var
  xshmc: TTCSHMC = nil;

constructor TTCSHMC.Create;
begin
  inherited Create;
end;

destructor TTCSHMC.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function shmc: TTCSHMC;
begin
  if xshmc = nil then
    xshmc := TTCSHMC.Create;
  Result := xshmc;
end;

{===============================================================================}

initialization

finalization
  xshmc.Free;

end.
