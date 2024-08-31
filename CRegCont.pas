unit CRegCont;

interface

uses CPlanctas, CLibCont, CPeriodo, DB, DBTables, CBDT, CUtiles, CIDBFM, CListar;

const nroitems = 150;

type

TTRegCont = class(TTLibrosCont)
  cuenta      : array [1..nroitems] of string;
  ttotdebe    : array [1..nroitems] of real;
  ttothaber   : array [1..nroitems] of real;
  cabasien, asientos, ccostos, plansaldo: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Depurar(xperiodo: string);

  procedure   conectar;
  procedure   desconectar;
 private
   { Declaraciones Privadas }
   conexiones: shortint;
 protected
  { Declaraciones Protegidas }
  nro_mov, xindice: integer;
  claveas, numeroas, vialiq, path: string;
  procedure IniciarArray;
  procedure AnularAsientos(xperiodo, xclave: string);
end;

function regcont: TTRegCont;

implementation

var
  xregcont: TTRegCont = nil;

constructor TTRegCont.Create;
begin
  inherited Create;
  cabasien  := datosdb.openDB('cabasien', 'Periodo;Nroasien');
  asientos  := datosdb.openDB('asientos', '', 'Idasiento');
  ccostos   := datosdb.openDB('ccostos', 'Periodo;Nroasien;Codcta;Nromovi');
  plansaldo := datosdb.openDB('plansaldo', 'Codcta;Periodo');
end;

destructor TTRegCont.Destroy;
begin
  inherited Destroy;
end;

procedure TTRegCont.IniciarArray;
// Objetivo...: Iniciar los Arrays
var
  x: integer;
begin
  For x := 1 to nroitems do
    begin
      cuenta[x]  := ''; ttotdebe[x] := 0; ttothaber[x] := 0;
    end;
  nro_mov := 0;
end;

procedure TTRegCont.AnularAsientos(xperiodo, xclave: string);
// Objetivo...: Eliminación de asientos contables por período y clave
begin
  datosdb.tranSQL(path, 'DELETE FROM cabasien WHERE periodo = ' + '"' + xperiodo + '"' + ' AND clave = ' + '"' + xclave + '"');
  datosdb.tranSQL(path, 'DELETE FROM asientos WHERE periodo = ' + '"' + xperiodo + '"' + ' AND clave = ' + '"' + xclave + '"');
end;

procedure TTRegCont.Depurar(xperiodo: string);
// Objetivo...: Depurar Datos de un Período contable Cerrado
begin
  datosdb.tranSQL(path, 'DELETE FROM cabasien  WHERE periodo = ' + '''' + xperiodo + '''');
  datosdb.tranSQL(path, 'DELETE FROM asientos  WHERE periodo = ' + '''' + xperiodo + '''');
  datosdb.tranSQL(path, 'DELETE FROM ccostos   WHERE periodo = ' + '''' + xperiodo + '''');
  datosdb.tranSQL(path, 'DELETE FROM plansaldo WHERE periodo = ' + '''' + xperiodo + '''');
  datosdb.tranSQL(path, 'DELETE FROM periodo   WHERE periodo = ' + '''' + xperiodo + '''');
end;

procedure TTRegCont.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    per.conectar;
    if not cabasien.Active then cabasien.Open;
    if not asientos.Active then asientos.Open;
    if not ccostos.Active  then ccostos.Open;
    if not plansaldo.Active then plansaldo.Open;
    cabasien.FieldByName('periodo').Visible := False; cabasien.FieldByName('idasiento').Visible := False; cabasien.FieldByName('periodo').Visible := False; cabasien.FieldByName('fecha').Visible := False;
    cabasien.FieldByName('nroasien').DisplayLabel := 'Nº Asiento'; cabasien.FieldByName('observac').DisplayLabel := 'Observaciones';
    planctas.conectar;
    planctas.FiltrarCtasImputables;
  end;
  Inc(conexiones);
end;

procedure TTRegCont.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(asientos);
    datosdb.closeDB(plansaldo);
    datosdb.closeDB(ccostos);
    planctas.DesactivarFiltro;
    planctas.desconectar;
  end;
end;

{===============================================================================}

function regcont: TTRegCont;
begin
  if xregcont = nil then
    xregcont := TTRegCont.Create;
  Result := xregcont;
end;

{===============================================================================}

initialization

finalization
  xregcont.Free;

end.