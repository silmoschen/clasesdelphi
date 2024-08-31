unit CDTotCom;

interface

uses CDTotFact, SysUtils, DB, DBTables, CUtiles, CIDBFM;

type

TTCTotFact = class(TTCDTotFact)
 public
  { Declaraciones Públicas }
  constructor Create(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta: string; xmonto1, xmonto2, xmonto3, xmonto4, xmonto5: real);
  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
end;

function ctotfact: TTCTotFact;

implementation

var
  xctotfact: TTCTotFact = nil;

constructor TTCTotFact.Create(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta: string; xmonto1, xmonto2, xmonto3, xmonto4, xmonto5: real);
begin
  inherited Create;
  tabla := datosdb.openDB('distcomp', 'idc;tipo;sucursal;numero;cuit');
end;

destructor TTCTotFact.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function ctotfact: TTCTotFact;
begin
  if xctotfact = nil then
    xctotfact := TTCTotFact.Create('', '', '', '', '', '', 0, 0, 0, 0, 0);
  Result := xctotfact;
end;

{===============================================================================}

initialization

finalization
  xctotfact.Free;

end.