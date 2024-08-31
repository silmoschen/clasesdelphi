unit CLDiaAuC;

interface

uses CLDiaAuxiliar, CPlanctas, SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM, CPeriodo;

type

TTLDiarioAuxiliarCompras = class(TTLDiarioAuxiliar)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Via(xvia: string);
 private
  { Declaraciones Privadas }
 protected
  { Declaraciones Protegidas }
end;

function ldiarioauxc: TTLDiarioAuxiliarCompras;

implementation

var
  xldiarioauxc: TTLDiarioAuxiliarCompras = nil;

constructor TTLDiarioAuxiliarCompras.Create;
begin
  inherited Create;
  cabasien     := datosdb.openDB('cabasixc', 'Periodo;Nroasien');
  asientos     := datosdb.openDB('asientxc', '', 'Idasiento');
  trefconex    := datosdb.openDB('refconexc', 'idc;tipo;sucursal;numero;cuit');
end;

destructor TTLDiarioAuxiliarCompras.Destroy;
begin
  inherited Destroy;
end;

procedure TTLDiarioAuxiliarCompras.Via(xvia: string);
// Objetivo...: Abrir tablas de persistencia
begin
  per.Via(xvia);
//  planctas.Via(xvia);
  cabasien := nil; asientos := nil; refercompact := nil;
  cabasien     := datosdb.openDB('cabasixc', 'Periodo;Nroasien', '', dbs.dirSistema + xvia);
  asientos     := datosdb.openDB('asientxc', '', 'Idasiento', '', dbs.dirSistema + xvia);
  refercompact := datosdb.openDB('refcompactc', 'codcompact', '', dbs.dirSistema + xvia);
  trefconex    := datosdb.openDB('refconexc', 'idc;tipo;sucursal;numero;cuit', '', dbs.dirSistema + xvia);
  path := dbs.dirSistema + xvia; inherited conectar;
end;

{===============================================================================}

function ldiarioauxc: TTLDiarioAuxiliarCompras;
begin
  if xldiarioauxc = nil then
    xldiarioauxc := TTLDiarioAuxiliarCompras.Create;
  Result := xldiarioauxc;
end;

{===============================================================================}

initialization

finalization
  xldiarioauxc.Free;

end.