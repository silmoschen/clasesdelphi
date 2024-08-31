unit CDefcurs;

interface

uses CBDT, CListar, DB, DBTables, CIDBFM, CUtiles, CCursos, CDias, CProfesor, CHorario, SysUtils;

type

TTDefcursos = class(TObject)          // Clase TVendedor Heredada de Persona
  codcurso, idcurso, nrolegajo, feinicio, fefinal, idhorario, iddias, observac, estado, fecierre, concepto: string;
  importe, valorhrprof: real;
  tdefcurso: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xcodcurso, xidcurso, xnrolegajo, xfeinicio, xfefinal, xiddias, xidhorario, xobservac: string; ximporte, xvalorhrprof: real);
  destructor  Destroy; override;

  function    getCodcurso: string;
  function    getCurso: string;
  function    getDescrip(cc: string): string;
  function    getIdcurso: string;
  function    getNrolegajo: string;
  function    getProfesor: string;
  function    getFeinicio: string;
  function    getFefinal: string;
  function    getObservac: string;
  function    getIddias: string;
  function    getDinicio: string;
  function    getDfinal: string;
  function    getIdhorario: string;
  function    getHinicio: string;
  function    getHfinal: string;
  function    getEstado: string;
  function    getImporte: real;
  function    getValorhrprof: real;
  function    getFecierre: string;
  function    getConcepto: string;

  function    Buscar(xcodcurso: string): boolean;
  procedure   getDatos(xcodcurso: string);
  procedure   Grabar(xcodcurso, xidcurso, xnrolegajo, xfeinicio, xfefinal, xiddias, xidhorario, xobservac: string; ximporte, xvalorhrprof: real);
  procedure   Borrar(xcodcurso: string);
  function    setDefcurso: TQuery;
   function    setDefcursosActivos: TQuery;
  function    setDefCursosCerrados(xnrolegajo: string): TQuery;
  function    setDefCursosBaja(xnrolegajo: string): TQuery;
  function    setCursosProf(xnrolegajo: string): TQuery;
  function    setRemplazos(xnrolegajo: string): TQuery;
  function    setCursosCerrados: TQuery;
  procedure   FiltrarCursosCerrados;
  procedure   FiltrarCursosBaja;
  procedure   QuitarFiltro;
  procedure   Cerrar(xcodcurso, xfecha, xconcepto: string);
  procedure   Baja(xcodcurso, xfecha, xconcepto: string);
  procedure   Abrir(xcodcurso: string);

  procedure   conectar;
  procedure   desconectar;

  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   ListarCursosCerrados(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   ListarCursosBaja(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   ListCursIni(iniciar: string; tf, salida: char);
 private
  { Declaraciones Privadas }
  procedure   List_tit(salida, tl: char);
  procedure   List_linea(salida, tl: char);
end;

function defcurso: TTDefcursos;

implementation

var
  xdefcurso: TTDefcursos = nil;

constructor TTDefcursos.Create(xcodcurso, xidcurso, xnrolegajo, xfeinicio, xfefinal, xiddias, xidhorario, xobservac: string; ximporte, xvalorhrprof: real);
// Vendedor - Heredada de Persona
begin
  inherited Create;
  codcurso    := xcodcurso;
  idcurso     := xidcurso;
  nrolegajo   := xnrolegajo;
  feinicio    := xfeinicio;
  fefinal     := xfefinal;
  observac    := xobservac;
  idhorario   := xidhorario;
  importe     := ximporte;
  iddias      := xiddias;
  valorhrprof := xvalorhrprof;

  tdefcurso := datosdb.openDB('defcurso.DB', 'Codcurso');
end;

destructor TTDefcursos.Destroy;
begin
  inherited Destroy;
end;

function TTDefcursos.getCodcurso: string;
begin
  Result := codcurso;
end;

function TTDefcursos.getDescrip(cc: string): string;
begin
  curso.getDatos(cc);
  Result := curso.getDescrip;
end;

function TTDefcursos.getCurso: string;
begin
  Result := getDescrip(idcurso);
end;

function TTDefcursos.getIdcurso: string;
begin
  Result := idcurso;
end;

function TTDefcursos.getNrolegajo: string;
begin
  Result := nrolegajo;
end;

function TTDefcursos.getProfesor: string;
begin
  profesor.getDatos(nrolegajo);
  Result := profesor.getNombre;
end;

function TTDefcursos.getFeinicio: string;
begin
  Result := feinicio;
end;

function TTDefcursos.getFefinal: string;
begin
  Result := fefinal;
end;

function TTDefcursos.getObservac: string;
begin
  Result := observac;
end;

function TTDefcursos.getIdhorario: string;
begin
  Result := idhorario;
end;

function TTDefcursos.getHinicio: string;
begin
  horario.getDatos(idhorario);
  Result := horario.getInicio;
end;

function TTDefcursos.getHfinal: string;
begin
  horario.getDatos(idhorario);
  Result := horario.getFin;
end;

function TTDefcursos.getIddias: string;
begin
  Result := iddias;
end;

function TTDefcursos.getEstado: string;
begin
  Result := estado;
end;

function TTDefcursos.getDinicio: string;
begin
  dias.getDatos(iddias);
  Result := dias.getInicio;
end;

function TTDefcursos.getDfinal: string;
begin
  dias.getDatos(iddias);
  Result := dias.getFin;
end;

function TTDefcursos.getImporte: real;
begin
  Result := importe;
end;

function TTDefcursos.getValorhrprof: real;
begin
  Result := valorhrprof;
end;

function TTDefcursos.getFecierre: string;
begin
  Result := fecierre;
end;

function TTDefcursos.getConcepto: string;
begin
  Result := concepto;
end;

function TTDefcursos.Buscar(xcodcurso: string): boolean;
// Objetivo...: Buscar atributos en tablas de persistencia
begin
  if tdefcurso.FindKey([xcodcurso]) then Result := True else Result := False;
end;

procedure TTDefcursos.getDatos(xcodcurso: string);
// Objetivo...: actualizar los atributos de la clase a partir de la tabla de persistencia
begin
  if Buscar(xcodcurso) then
    begin
      codcurso     := tdefcurso.FieldByName('codcurso').AsString;
      idcurso      := tdefcurso.FieldByName('idcurso').AsString;
      feinicio     := utiles.sFormatoFecha(tdefcurso.FieldByName('feinicio').AsString);
      fefinal      := utiles.sFormatoFecha(tdefcurso.FieldByName('fefinal').AsString);
      nrolegajo    := tdefcurso.FieldByName('nrolegajo').AsString;
      observac     := tdefcurso.FieldByName('observac').AsString;
      iddias       := tdefcurso.FieldByName('iddias').AsString;
      idhorario    := tdefcurso.FieldByName('idhorario').AsString;
      estado       := tdefcurso.FieldByName('estado').AsString;
      importe      := tdefcurso.FieldByName('importe').AsFloat;
      valorhrprof  := tdefcurso.FieldByName('valorhrprof').AsFloat;
      if Length(Trim(tdefcurso.FieldByName('fecierre').AsString)) = 8 then fecierre := utiles.sFormatoFecha(tdefcurso.FieldByName('fecierre').AsString) else fecierre := '  /  /  ';
      concepto     := tdefcurso.FieldByName('concepto').AsString;
    end
  else
    begin
      codcurso := ''; idcurso := ''; feinicio := ''; fefinal := ''; nrolegajo := ''; observac := ''; idhorario := ''; estado := ''; importe := 0; valorhrprof := 0; fecierre := ''; concepto := '';
    end;
end;

procedure TTDefcursos.Grabar(xcodcurso, xidcurso, xnrolegajo, xfeinicio, xfefinal, xiddias, xidhorario, xobservac: string; ximporte, xvalorhrprof: real);
// Objetivo...: grabar atributos en tablas de persistencia
begin
  if Buscar(xcodcurso) then tdefcurso.Edit else tdefcurso.Append;
  tdefcurso.FieldByName('codcurso').AsString     := xcodcurso;
  tdefcurso.FieldByName('idcurso').AsString      := xidcurso;
  tdefcurso.FieldByName('nrolegajo').AsString    := xnrolegajo;
  tdefcurso.FieldByName('feinicio').AsString     := utiles.sExprFecha(xfeinicio);
  tdefcurso.FieldByName('fefinal').AsString      := utiles.sExprFecha(xfefinal);
  tdefcurso.FieldByName('observac').AsString     := xobservac;
  tdefcurso.FieldByName('idhorario').AsString    := xidhorario;
  tdefcurso.FieldByName('iddias').AsString       := xiddias;
  tdefcurso.FieldByName('importe').AsFloat       := ximporte;
  tdefcurso.FieldByName('valorhrprof').AsFloat   := xvalorhrprof;
  if Length(trim(tdefcurso.FieldByName('estado').AsString)) = 0 then tdefcurso.FieldByName('estado').AsString := 'A';
  try
    tdefcurso.Post;
  except
    tdefcurso.Cancel;
  end;
end;

procedure TTDefcursos.Borrar(xcodcurso: string);
// Objetivo...: Borrar una instancia de la clase - de las tablas de persistencia
begin
  if Buscar(xcodcurso) then
    begin
      tdefcurso.Delete;
      getDatos(tdefcurso.FieldByName('codcurso').AsString);
    end;
end;

function TTDefcursos.setDefcurso: TQuery;
// Objetivo...: devolver un set de registros con los todos cursos definidos
begin
  Result := datosdb.tranSQL('SELECT defcurso.codcurso, defcurso.idcurso, cursos.descrip, profesor.nombre, horario.inicio, horario.fin, dias.inicio, dias.fin ' +
                            'FROM defcurso, profesor, cursos, horario, dias ' +
                            'WHERE defcurso.nrolegajo = profesor.nrolegajo AND defcurso.idcurso = cursos.idcurso AND defcurso.idhorario = horario.idhorario AND defcurso.iddias = dias.iddias ');
end;

function TTDefcursos.setDefcursosActivos: TQuery;
// Objetivo...: devolver un set de registros con los cursos Activos
begin
  Result := datosdb.tranSQL('SELECT defcurso.codcurso, defcurso.idcurso, cursos.descrip, profesor.nombre, horario.inicio, horario.fin, dias.inicio, dias.fin ' +
                            'FROM defcurso, profesor, cursos, horario, dias ' +
                            'WHERE defcurso.nrolegajo = profesor.nrolegajo AND defcurso.idcurso = cursos.idcurso AND defcurso.idhorario = horario.idhorario AND defcurso.iddias = dias.iddias ' +
                            ' AND estado = ' + '''' + 'A' + '''');
end;

function TTDefcursos.setDefCursosCerrados(xnrolegajo: string): TQuery;
// Objetivo...: devolver un set de registros con los cursos ya cerrados
begin
  Result := datosdb.tranSQL('SELECT defcurso.codcurso, defcurso.idcurso, cursos.descrip, horario.inicio, horario.fin, dias.inicio, dias.fin ' +
                            'FROM defcurso, profesor, cursos, horario, dias ' +
                            'WHERE defcurso.nrolegajo = ' + '''' + xnrolegajo + '''' + ' AND defcurso.nrolegajo = profesor.nrolegajo AND defcurso.idcurso = cursos.idcurso AND ' +
                            'defcurso.idhorario = horario.idhorario AND defcurso.iddias = dias.iddias AND estado = ' + '''' + 'C' + '''');
end;

function TTDefcursos.setDefCursosBaja(xnrolegajo: string): TQuery;
// Objetivo...: devolver un set de registros con los cursos reciclados
begin
  Result := datosdb.tranSQL('SELECT defcurso.codcurso, defcurso.idcurso, cursos.descrip, horario.inicio, horario.fin, dias.inicio, dias.fin ' +
                            'FROM defcurso, profesor, cursos, horario, dias ' +
                            'WHERE defcurso.nrolegajo = ' + '''' + xnrolegajo + '''' + ' AND defcurso.nrolegajo = profesor.nrolegajo AND defcurso.idcurso = cursos.idcurso AND ' +
                            'defcurso.idhorario = horario.idhorario AND defcurso.iddias = dias.iddias AND estado = ' + '''' + 'B' + '''');
end;

function TTDefcursos.setCursosProf(xnrolegajo: string): TQuery;
// Objetivo...: devolver un set de registros con los cursos definidos para un profesor
begin
  Result := datosdb.tranSQL('SELECT defcurso.codcurso, defcurso.idcurso, cursos.descrip, horario.inicio, horario.fin, dias.inicio, dias.fin ' +
                            'FROM defcurso, profesor, cursos, horario, dias ' +
                            'WHERE defcurso.nrolegajo = ' + '''' + xnrolegajo + '''' + ' AND defcurso.nrolegajo = profesor.nrolegajo AND defcurso.idcurso = cursos.idcurso AND ' +
                            'defcurso.idhorario = horario.idhorario AND defcurso.iddias = dias.iddias AND defcurso.estado = ' + '''' + 'A' + '''');
end;

function TTDefcursos.setRemplazos(xnrolegajo: string): TQuery;
// Objetivo...: devolver un set de registros con los cursos definidos que no corresponden a un profesor (reemplazos)
begin
  Result := datosdb.tranSQL('SELECT defcurso.codcurso, defcurso.idcurso, cursos.descrip, horario.inicio, horario.fin, dias.inicio, dias.fin ' +
                            'FROM defcurso, profesor, cursos, horario, dias ' +
                            'WHERE defcurso.nrolegajo <> ' + '''' + xnrolegajo + '''' + ' AND defcurso.nrolegajo = profesor.nrolegajo AND defcurso.idcurso = cursos.idcurso AND ' +
                            'defcurso.idhorario = horario.idhorario AND defcurso.iddias = dias.iddias AND defcurso.estado <> ' + '''' + 'C' + '''');
end;

function TTDefcursos.setCursosCerrados: TQuery;
// Objetivo...: devolver un set de registros con los cursos cerrados/finalizados o reciclados
begin
  Result := datosdb.tranSQL('SELECT * FROM defcurso WHERE estado = ' + '''' + 'C' + '''');
end;

procedure TTDefcursos.FiltrarCursosCerrados;
// Objetivo...: separar los cursos cerrados
begin
  datosdb.Filtrar(tdefcurso, 'estado = ' + '''' + 'C' + '''');
end;

procedure TTDefcursos.FiltrarCursosBaja;
// Objetivo...: separar los cursos dados de Baja
begin
  datosdb.Filtrar(tdefcurso, 'estado = ' + '''' + 'B' + '''');
end;

procedure TTDefcursos.QuitarFiltro;
// Objetivo...: desctivar Filtro
begin
  tdefcurso.Filtered := False;
  tdefcurso.Filter   := '';
end;

procedure TTDefcursos.Cerrar(xcodcurso, xfecha, xconcepto: string);
// Objetivo...: Marcar un curso como cerrado
begin
  if Buscar(xcodcurso) then
    begin
      tdefcurso.Edit;
      tdefcurso.FieldByName('estado').AsString   := 'C';
      tdefcurso.FieldByName('fecierre').AsString := utiles.sExprFecha(xfecha);
      tdefcurso.FieldByName('concepto').AsString := xconcepto;
      try
        tdefcurso.Post;
      except
        tdefcurso.Cancel;
      end;
    end;
end;

procedure TTDefcursos.Baja(xcodcurso, xfecha, xconcepto: string);
// Objetivo...: Marcar un curso como cerrado
begin
  if Buscar(xcodcurso) then
    begin
      tdefcurso.Edit;
      tdefcurso.FieldByName('estado').AsString   := 'B';
      tdefcurso.FieldByName('fecierre').AsString := utiles.sExprFecha(xfecha);
      tdefcurso.FieldByName('concepto').AsString := xconcepto;
      try
        tdefcurso.Post;
      except
        tdefcurso.Cancel;
      end;
    end;
end;

procedure TTDefcursos.Abrir(xcodcurso: string);
// Objetivo...: Abrir/Recuperar un curso
begin
  if Buscar(xcodcurso) then
    begin
      tdefcurso.Edit;
      tdefcurso.FieldByName('estado').AsString   := 'A';
      tdefcurso.FieldByName('fecierre').AsString := '';
      tdefcurso.FieldByName('concepto').AsString := '';
      try
        tdefcurso.Post;
      except
        tdefcurso.Cancel;
      end;
    end;
end;

procedure TTDefcursos.conectar;
// Objetivo...: abrir tablas de persistencia
begin
  horario.conectar;
  dias.conectar;
  profesor.conectar;
  if not tdefcurso.Active then tdefcurso.Open;
  tdefcurso.FieldByName('idcurso').Visible := False; tdefcurso.FieldByName('nrolegajo').Visible := False; tdefcurso.FieldByName('feinicio').Visible := False; tdefcurso.FieldByName('fefinal').Visible := False; tdefcurso.FieldByName('estado').Visible := False; tdefcurso.FieldByName('iddias').Visible := False;
  tdefcurso.FieldByName('idhorario').Visible := False; tdefcurso.FieldByName('valorhrprof').Visible := False;
  tdefcurso.FieldByName('codcurso').DisplayLabel := 'Cód.'; tdefcurso.FieldByName('observac').DisplayLabel := 'Observaciones';
end;

procedure TTDefcursos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  horario.desconectar;
  dias.desconectar;
  profesor.desconectar;
  datosdb.closeDB(tdefcurso);
end;

procedure TTDefcursos.List_linea(salida, tl: char);
// Objetivo...: Listar una Línea
begin
  horario.getDatos(tdefcurso.FieldByName('idhorario').AsString);
  curso.getDatos(tdefcurso.FieldByName('idcurso').AsString);
  List.Linea(0, 0, tdefcurso.FieldByName('codcurso').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(8, List.lineactual, tdefcurso.FieldByName('idcurso').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(14, List.lineactual, curso.Descrip, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(47, List.lineactual, utiles.sFormatoFecha(tdefcurso.FieldByName('feinicio').AsString) + ' - ' + utiles.sFormatoFecha(tdefcurso.FieldByName('fefinal').AsString), 4, 'Arial, normal, 8', salida, 'N');
  List.Linea(62, List.lineactual, tdefcurso.FieldByName('observac').AsString, 5, 'Arial, normal, 8', salida, 'N');
  List.Linea(88, List.lineactual, horario.getInicio + ' - ' + horario.getFin, 6, 'Arial, normal, 8', salida, 'N');

  if (tl > '1') and (tl < '5') then   // Lineas Extras
    List.Linea(100, List.lineactual, defcurso.getFecierre + '      ' + defcurso.getConcepto, 7, 'Arial, normal, 8', salida, 'S')
  else
    List.Linea(99, List.lineactual, tdefcurso.FieldByName('estado').AsString, 7, 'Arial, normal, 8', salida, 'S');
end;

procedure TTDefcursos.List_tit(salida, tl: char);
// Objetivo...: Listar Titulo del informe
var
  titulo: string;
begin
  if tl = '1' then titulo := ' Listado de Cursos Definidos';
  if tl = '2' then titulo := ' Listado de Cursos Cerrados';
  if tl = '3' then titulo := ' Listado de Cursos dados de Baja';
  if tl = '4' then titulo := ' Listado de Cursos Iniciados';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.', 1, 'Arial, cursiva, 8');
  List.Titulo(8, List.lineactual, 'Cód.', 2, 'Arial, cursiva, 8');
  List.Titulo(14, List.lineactual, 'Curso', 3, 'Arial, cursiva, 8');
  List.Titulo(47, List.lineactual, 'Inicio - Finalización', 4, 'Arial, cursiva, 8');
  List.Titulo(62, List.lineactual, 'Observaciones', 5, 'Arial, cursiva, 8');
  List.Titulo(88, List.lineactual, 'Horario', 6, 'Arial, cursiva, 8');
  if (tl > '1') and (tl < '5') then   // Lineas Extras
    List.Titulo(99, List.lineactual, 'Baja/Cierre     Concepto', 7, 'Arial, cursiva, 8')
  else
    List.Titulo(98, List.lineactual, 'Est.', 7, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTDefcursos.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  List_tit(salida, '1');

  tdefcurso.First;
  while not tdefcurso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tdefcurso.FieldByName('codcurso').AsString >= iniciar) and (tdefcurso.FieldByName('codcurso').AsString <= finalizar) then List_linea(salida, '1');
      if (ent_excl = 'X') and (orden = 'C') then
        if (tdefcurso.FieldByName('codcurso').AsString < iniciar) or (tdefcurso.FieldByName('codcurso').AsString > finalizar) then List_linea(salida, '1');

      tdefcurso.Next;
    end;
    List.FinList;

    tdefcurso.First;
end;

procedure TTDefcursos.ListarCursosCerrados(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  List_tit(salida, '2');

  tdefcurso.First;
  while not tdefcurso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tdefcurso.FieldByName('codcurso').AsString >= iniciar) and (tdefcurso.FieldByName('codcurso').AsString <= finalizar) then List_linea(salida, '2');
      if (ent_excl = 'X') and (orden = 'C') then
        if (tdefcurso.FieldByName('codcurso').AsString < iniciar) or (tdefcurso.FieldByName('codcurso').AsString > finalizar) then List_linea(salida, '2');

      tdefcurso.Next;
    end;
    List.FinList;

    tdefcurso.First;
end;

procedure TTDefcursos.ListarCursosBaja(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  List_tit(salida, '3');

  tdefcurso.First;
  while not tdefcurso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tdefcurso.FieldByName('codcurso').AsString >= iniciar) and (tdefcurso.FieldByName('codcurso').AsString <= finalizar) then List_linea(salida, '3');
      if (ent_excl = 'X') and (orden = 'C') then
        if (tdefcurso.FieldByName('codcurso').AsString < iniciar) or (tdefcurso.FieldByName('codcurso').AsString > finalizar) then List_linea(salida, '3');

      tdefcurso.Next;
    end;
    List.FinList;

    tdefcurso.First;
end;

procedure TTDefcursos.ListCursIni(iniciar: string; tf, salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  List_tit(salida, '4');

  tdefcurso.First;
  while not tdefcurso.EOF do
    begin
      // Ordenado por Código
      if tf = 'M' then
        if (tdefcurso.FieldByName('feinicio').AsString >= utiles.sExprFecha(iniciar)) then List_linea(salida, '4');
      if tf = 'I' then
        if (tdefcurso.FieldByName('feinicio').AsString = utiles.sExprFecha(iniciar)) then List_linea(salida, '4');
      tdefcurso.Next;
    end;
    List.FinList;

    tdefcurso.First;
end;

{===============================================================================}

function defcurso: TTDefcursos;
begin
  if xdefcurso = nil then
    xdefcurso := TTDefcursos.Create('', '', '', '', '', '', '', '', 0, 0);
  Result := xdefcurso;
end;

{===============================================================================}

initialization

finalization
  xdefcurso.Free;

end.