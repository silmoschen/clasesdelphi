unit CLDiaAuV;

interface

uses CLDiaAuxiliar, CPlanctas, SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM, CPeriodo;

type

TTLDiarioAuxiliarVentas = class(TTLDiarioAuxiliar)
  codres: string;
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

function ldiarioauxv: TTLDiarioAuxiliarVentas;

implementation

var
  xldiarioauxv: TTLDiarioAuxiliarVentas = nil;

constructor TTLDiarioAuxiliarVentas.Create;
begin
  inherited Create;
  cabasien     := datosdb.openDB('cabasixv', 'Periodo;Nroasien');
  asientos     := datosdb.openDB('asientxv', '', 'Idasiento');
  trefconex    := datosdb.openDB('refconexv', 'idc;tipo;sucursal;numero;cuit');
end;

destructor TTLDiarioAuxiliarVentas.Destroy;
begin
  inherited Destroy;
end;

procedure TTLDiarioAuxiliarVentas.Via(xvia: string);
// Objetivo...: Abrir tablas de persistencia
begin
  cabasien := nil; asientos := nil; refercompact := nil;        // Necesitamos definirla de nuevo, para soporte de múltiples Vías
  per.Via(xvia); //planctas.Via(xvia);
  cabasien     := datosdb.openDB('cabasixv', 'Periodo;Nroasien', '', dbs.dirSistema + xvia);
  asientos     := datosdb.openDB('asientxv', '', 'Idasiento', '', dbs.dirSistema + xvia);
  refercompact := datosdb.openDB('refcompactv', 'codcompact', '', dbs.dirSistema + xvia);
  trefconex    := datosdb.openDB('refconexv', 'idc;tipo;sucursal;numero;cuit', '', dbs.dirSistema + xvia);
  path := dbs.dirSistema + xvia; inherited conectar;
end;

{===============================================================================}

function ldiarioauxv: TTLDiarioAuxiliarVentas;
begin
  if xldiarioauxv = nil then
    xldiarioauxv := TTLDiarioAuxiliarVentas.Create;
  Result := xldiarioauxv;
end;

{===============================================================================}

initialization

finalization
  xldiarioauxv.Free;

end.