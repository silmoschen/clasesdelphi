unit LDiAux;

interface

uses CLDiario, CPlanctas, SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM, CPeriodo;

type

TTldiarioauxAuxiliar = class(TTLDiario)
 public
  { Declaraciones Públicas }
  constructor Create(xperiodo, xnroasien, xfecha, xobservac, xcodcta, xconcepto, xdh: string; ximporte: real);
  destructor  Destroy; override;

  procedure CambiarVia(xvia: string);
  procedure conectar; overload;
  procedure conectar(sesion, privatedir: string); overload;
  procedure desconectar;
 private
  { Declaraciones Privadas }
 protected
  { Declaraciones Protegidas }
end;

function ldiarioaux: TTldiarioauxAuxiliar;

implementation

var
  xldiarioaux: TTldiarioauxAuxiliar = nil;

constructor TTldiarioauxAuxiliar.Create(xperiodo, xnroasien, xfecha, xobservac, xcodcta, xconcepto, xdh: string; ximporte: real);
begin
  inherited Create(xperiodo, xnroasien, xfecha, xobservac, xcodcta, xconcepto, xdh, ximporte);

  cabasien := datosdb.openDB('cabasix.DB', 'Periodo;Nroasien');
  asientos := datosdb.openDB('asientx.DB', '', 'Idasiento');
end;

destructor TTldiarioauxAuxiliar.Destroy;
begin
  inherited Destroy;
end;

procedure TTldiarioauxAuxiliar.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  per.conectar;
  if not cabasien.Active then cabasien.Open;
  if not asientos.Active then asientos.Open;
  planctas.conectar;
  planctas.FiltrarCtasImputables;
end;

procedure TTldiarioauxAuxiliar.conectar(sesion, privatedir: string);
// Objetivo...: Abrir tablas de persistencia
begin
  per.conectar(sesion, privatedir);
  cabasien  := datosdb.openDB('cabasien.DB', 'Periodo;Nroasien', sesion, privatedir);
  asientos  := datosdb.openDB('asientos.DB', '', 'Idasiento', sesion, privatedir);
  if not cabasien.Active then cabasien.Open;
  if not asientos.Active then asientos.Open;
  planctas.conectar(sesion, privatedir);
  planctas.FiltrarCtasImputables;
end;

procedure TTldiarioauxAuxiliar.CambiarVia(xvia: string);
// Objetivo...: Determinar características multiempresa
begin
  cabasien := nil; asientos := nil;         // Necesitamos definirla de nuevo, para soporte de múltiples Vías
  xsesion := dbs.P.SessionName; xprivatedir := dbs.P.PrivateDir; // Valores Directorios Mútiples - Características Multiempresa
  conectar(xsesion, xprivatedir);
end;

procedure TTldiarioauxAuxiliar.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  datosdb.closeDB(asientos);
  datosdb.closeDB(cabasien);
  planctas.DesactivarFiltro;
  planctas.desconectar;
end;

{===============================================================================}

function ldiarioaux: TTldiarioauxAuxiliar;
begin
  if xldiarioaux = nil then
    xldiarioaux := TTldiarioauxAuxiliar.Create('', '', '', '', '', '', '', 0);
  Result := xldiarioaux;
end;

{===============================================================================}

initialization

finalization
  xldiarioaux.Free;

end.