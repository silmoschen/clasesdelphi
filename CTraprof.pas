unit CTraprof;

interface

uses SysUtils, DB, DBTables, CBDT, CProfesor, CDefcurs, CListar, CUtiles, CIDBFM;

type

TTHsProfesores = class(TObject)            // Superclase
   periodo, nrolegajo, codcurso, fecha, hinicio, hfinal: string;
   tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xperiodo, xnrolegajo, xcodcurso, xfecha, xhinicio, xhfinal: string);
  destructor  Destroy; override;

  function    getPeriodo: string;
  function    getCodcurso: string;
  function    getFecha: string;
  function    getHinicio: string;
  function    getHfinal: string;

  function    Buscar(xperiodo, xnrolegajo, xcodcurso, xfecha: string): boolean;
  procedure   Grabar(xperiodo, xnrolegajo, xcodcurso, xfecha, xhinicio, xhfinal: string);
  procedure   Borrar(xnrolegajo, xcodcurso, xfecha: string);
  procedure   getDatos(xperiodo, xnrolegajo, xcodcurso, xfecha: string);
  function    setItems(xcodcurso, xnrolegajo, xperiodo: string): TQuery; overload;
  function    setItems(xnrolegajo, xcodcurso: string): TQuery; overload;
  function    setHstrabajadas(xdf, xhf: string): TQuery;

  procedure   conectar;
  procedure   desconectar;

 private
  { Declaraciones Privadas }
end;

function hstrabprof: TTHsProfesores;

implementation

var
  xhstrabprof: TTHsProfesores = nil;

constructor TTHsProfesores.Create(xperiodo, xnrolegajo, xcodcurso, xfecha, xhinicio, xhfinal: string);
begin
  inherited Create;
  periodo   := xperiodo;
  nrolegajo := xnrolegajo;
  codcurso  := xcodcurso;
  fecha     := xfecha;
  hinicio   := xhinicio;
  hfinal    := xhfinal;

  tabla := datosdb.openDB('trabprof.DB', 'Periodo;Nrolegajo;Codcurso;Fecha');
end;

destructor TTHsProfesores.Destroy;
begin
  inherited Destroy;
end;

function TTHsProfesores.getPeriodo: string;
begin
  Result := periodo;
end;

function TTHsProfesores.getCodcurso: string;
begin
  Result := codcurso;
end;

function TTHsProfesores.getFecha: string;
begin
  Result := utiles.sFormatoFecha(fecha);
end;

function TTHsProfesores.getHinicio: string;
begin
  Result := hinicio;
end;

function TTHsProfesores.getHfinal: string;
begin
  Result := hfinal;
end;

function TTHsProfesores.Buscar(xperiodo, xnrolegajo, xcodcurso, xfecha: string): boolean;
begin
  Result := datosdb.Buscar(tabla, 'periodo', 'nrolegajo', 'codcurso', 'fecha', xperiodo, xnrolegajo, xcodcurso, utiles.sExprFecha(xfecha));
end;

procedure TTHsProfesores.Grabar(xperiodo, xnrolegajo, xcodcurso, xfecha, xhinicio, xhfinal: string);
// Objetivo...: Peristir objetos
begin
  if Buscar(xperiodo, xnrolegajo, xcodcurso, xfecha) then tabla.Edit else tabla.Append;
  tabla.FieldByName('periodo').AsString   := xperiodo;
  tabla.FieldByName('nrolegajo').AsString := xnrolegajo;
  tabla.FieldByName('codcurso').AsString  := xcodcurso;
  tabla.FieldByName('fecha').AsString     := utiles.sExprFecha(xfecha);
  tabla.FieldByName('hinicio').AsString   := xhinicio;
  tabla.FieldByName('hfinal').AsString    := xhfinal;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTHsProfesores.getDatos(xperiodo, xnrolegajo, xcodcurso, xfecha: string);
// Objetivo...: recuperar los atributos de un objeto dado
begin
  if Buscar(xperiodo, xnrolegajo, xcodcurso, xfecha) then
    begin
      periodo   := tabla.FieldByName('periodo').AsString;
      codcurso  := tabla.FieldByName('codcurso').AsString;
      nrolegajo := tabla.FieldByName('xnrolegajo').AsString;
      fecha     := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
      hinicio   := tabla.FieldByName('hhinicio').AsString;
      hfinal    := tabla.FieldByName('hhfinal').AsString;
    end
  else
    begin
      periodo := ''; nrolegajo := ''; codcurso := ''; fecha := ''; hinicio := ''; hfinal := '';
    end;
end;

procedure TTHsProfesores.Borrar(xnrolegajo, xcodcurso, xfecha: string);
// Objetivo...: Borrar un objeto
begin
  datosDB.tranSQL('DELETE FROM trabprof WHERE nrolegajo = ' + '''' + xnrolegajo + '''' + ' AND codcurso = ' + '''' + xcodcurso + '''' + ' AND fecha = ' + '''' + utiles.sExprFecha(xfecha) + '''');
end;

function TTHsProfesores.setItems(xcodcurso, xnrolegajo, xperiodo: string): TQuery;
// Objetivo...: devolver un set con los items de un profesor en un período
begin
  Result := datosdb.tranSQL('SELECT trabprof.nrolegajo, trabprof.fecha, trabprof.hinicio, trabprof.hfinal, cursos.descrip, trabprof.periodo FROM trabprof, defcurso, cursos ' +
                            'WHERE trabprof.codcurso = ' + '''' + xcodcurso + '''' + ' AND trabprof.periodo = ' + '''' + xperiodo + '''' +
                            ' AND trabprof.nrolegajo = ' + '''' + xnrolegajo + '''' + ' AND trabprof.codcurso = defcurso.codcurso AND defcurso.idcurso = cursos.idcurso ORDER BY trabprof.fecha, trabprof.nrolegajo');
end;

function TTHsProfesores.setItems(xnrolegajo, xcodcurso: string): TQuery;
// Objetivo...: devolver un set con los items de un profesor en un período
begin
  Result := datosdb.tranSQL('SELECT trabprof.fecha, trabprof.hinicio, trabprof.hfinal, cursos.descrip, trabprof.periodo FROM trabprof, defcurso, cursos '+
                            'WHERE trabprof.nrolegajo = ' + '''' + xnrolegajo + '''' + ' AND trabprof.codcurso = ' + '''' + xcodcurso + '''' +
                            ' AND trabprof.codcurso = defcurso.codcurso AND defcurso.idcurso = cursos.idcurso ORDER BY trabprof.fecha');
end;

function TTHsProfesores.setHstrabajadas(xdf, xhf: string): TQuery;
// Objetivo...: devolver un set con los items de un profesor en un período
begin
  Result := datosdb.tranSQL('SELECT trabprof.nrolegajo, trabprof.fecha, trabprof.hinicio, trabprof.hfinal, cursos.descrip, trabprof.periodo, dias.inicio, dias.fin, trabprof.codcurso FROM trabprof, defcurso, cursos, dias '+
                            'WHERE trabprof.fecha >= ' + '''' + utiles.sExprFecha(xdf) + '''' + ' AND trabprof.fecha <= ' + '''' + utiles.sExprFecha(xhf) + '''' +
                            ' AND trabprof.codcurso = defcurso.codcurso AND defcurso.idcurso = cursos.idcurso AND defcurso.iddias = dias.iddias ORDER BY trabprof.fecha');
end;

procedure TTHsProfesores.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if not tabla.Active then tabla.Open;
  profesor.conectar;
  defcurso.conectar;
end;

procedure TTHsProfesores.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if tabla.Active then tabla.Close;
  profesor.desconectar;
  defcurso.desconectar;
end;

{===============================================================================}

function hstrabprof: TTHsProfesores;
begin
  if xhstrabprof = nil then
    xhstrabprof := TTHsProfesores.Create('', '', '', '', '', '');
  Result := xhstrabprof;
end;

{===============================================================================}

initialization

finalization
  xhstrabprof.Free;

end.
