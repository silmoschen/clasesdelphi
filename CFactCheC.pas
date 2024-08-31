// Clase......: CFactCheC
// Objetivo...: Retener los cheques librados para una Factura de Compras

unit CFactCheC;

interface

uses CFactChe, SysUtils, DB, DBTables, CUtiles, CIDBFM;

type

TTChequesFactCompras = class(TTChequesFact)
 public
  { Declaraciones Públicas }
  constructor Create(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta, xnrocheque: string);
  destructor  Destroy; override;

 private
  { Declaraciones Privadas }
end;

function refercfc: TTChequesFactCompras;

implementation

var
  xrefercf: TTChequesFactCompras = nil;

constructor TTChequesFactCompras.Create(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta, xnrocheque: string);
begin
  inherited Create(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta, xnrocheque);
  tabla     := datosdb.openDB('refercf', 'idc;tipo;sucursal;numero;cuit');
end;

destructor TTChequesFactCompras.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function refercfc: TTChequesFactCompras;
begin
  if xrefercf = nil then
    xrefercf := TTChequesFactCompras.Create('', '', '', '', '', '', '');
  Result := xrefercf;
end;

{===============================================================================}

initialization

finalization
  xrefercf.Free;

end.