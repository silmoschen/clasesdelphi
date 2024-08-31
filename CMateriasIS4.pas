unit CMateriasIS4;

interface

uses CCarrerasIS4, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Contnrs;

type

TTMaterias = class
  Idcarrera, Idmateria, Materia, Curso, Anualcuat: String;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xidcarrera, xidmateria: String): Boolean;
  procedure   Registrar(xidcarrera, xidmateria, xmateria, xcurso, xanualcuat: String);
  procedure   Borrar(xidcarrera, xidmateria: String);
  procedure   getDatos(xidcarrera, xidmateria: String);

  function    setMaterias(xidcarrera: String): TObjectList;
  function    setMateriasAlf(xidcarrera: String): TObjectList;

  procedure   Listar(xidcarrera: String; salida: char);

  procedure   Exportar(xidcarrera: String);
  procedure   Importar;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function materia: TTMaterias;

implementation

var
  xmateria: TTMaterias = nil;

constructor TTMaterias.Create;
begin
  tabla := datosdb.openDB('materias', '');
end;

destructor TTMaterias.Destroy;
begin
  inherited Destroy;
end;

function  TTMaterias.Buscar(xidcarrera, xidmateria: String): Boolean;
// Objetivo...: recuperar una instancia
begin
  if tabla.IndexFieldNames <> 'Idcarrera;Idmateria' then tabla.IndexFieldNames := 'Idcarrera;Idmateria';
  Result := datosdb.Buscar(tabla, 'Idcarrera', 'Idmateria', xidcarrera, xidmateria);
end;

procedure TTMaterias.Registrar(xidcarrera, xidmateria, xmateria, xcurso, xanualcuat: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if Buscar(xidcarrera, xidmateria) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idcarrera').AsString := xidcarrera;
  tabla.FieldByName('idmateria').AsString := xidmateria;
  tabla.FieldByName('materia').AsString   := xmateria;
  tabla.FieldByName('curso').AsString     := xcurso;
  tabla.FieldByName('anualcuat').AsString := xanualcuat;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTMaterias.Borrar(xidcarrera, xidmateria: String);
// Objetivo...: borrar una instancia
begin
  if Buscar(xidcarrera, xidmateria) then Begin
    tabla.Delete;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTMaterias.getDatos(xidcarrera, xidmateria: String);
// Objetivo...: cargar una instancia
begin
  if Buscar(xidcarrera, xidmateria) then Begin
    Idcarrera := tabla.FieldByName('idcarrera').AsString;
    Idmateria := tabla.FieldByName('idmateria').AsString;
    Materia   := tabla.FieldByName('materia').AsString;
    Curso     := tabla.FieldByName('curso').AsString;
    Anualcuat := tabla.FieldByName('anualcuat').AsString;
  end else Begin
    Idcarrera := ''; Idmateria := ''; Materia := ''; Curso := ''; Anualcuat := '';
  end;
end;

function  TTMaterias.setMaterias(xidcarrera: String): TObjectList;
// Objetivo...: devolver set de materias para una carrera
var
  l: TObjectList;
  objeto: TTMaterias;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(tabla, 'idcarrera = ' + '''' + xidcarrera + '''');
  tabla.IndexFieldNames := 'Idcarrera;Curso;Idmateria';
  tabla.First;
  while not tabla.Eof do Begin
    objeto := TTMaterias.Create;
    objeto.Idcarrera := tabla.FieldByName('idcarrera').AsString;
    objeto.Idmateria := tabla.FieldByName('idmateria').AsString;
    objeto.Materia   := tabla.FieldByName('materia').AsString;
    objeto.Curso     := tabla.FieldByName('curso').AsString;
    objeto.Anualcuat := tabla.FieldByName('anualcuat').AsString;
    l.Add(objeto);
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);
  tabla.IndexFieldNames := 'Idcarrera;Idmateria';
  
  Result := l;
end;

function  TTMaterias.setMateriasAlf(xidcarrera: String): TObjectList;
// Objetivo...: devolver set de materias para una carrera
var
  l: TObjectList;
  objeto: TTMaterias;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(tabla, 'idcarrera = ' + '''' + xidcarrera + '''');
  tabla.IndexFieldNames := 'Idcarrera;Curso;Materia';
  tabla.First;
  while not tabla.Eof do Begin
    objeto := TTMaterias.Create;
    objeto.Idcarrera := tabla.FieldByName('idcarrera').AsString;
    objeto.Idmateria := tabla.FieldByName('idmateria').AsString;
    objeto.Materia   := tabla.FieldByName('materia').AsString;
    objeto.Curso     := tabla.FieldByName('curso').AsString;
    objeto.Anualcuat := tabla.FieldByName('anualcuat').AsString;
    l.Add(objeto);
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);
  tabla.IndexFieldNames := 'Idcarrera;Idmateria';

  Result := l;
end;

procedure TTMaterias.Listar(xidcarrera: String; salida: char);
// Objetivo...: listar datos
var
  idanter: String;
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Materias por Carrera', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, '  Cód.' + utiles.espacios(3) +  'Materia', 1, 'Arial, normal, 8');
  List.Titulo(80, list.Lineactual, 'Curso', 2, 'Arial, normal, 8');
  List.Titulo(90, list.Lineactual, 'An/Cuat.', 3, 'Arial, normal, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.IndexFieldNames := 'idcarrera;curso;idmateria';
  if Length(Trim(xidcarrera)) > 0 then datosdb.Filtrar(tabla, 'idcarrera = ' + '''' + xidcarrera + '''');
  tabla.First;
  while not tabla.Eof do Begin
    if tabla.FieldByName('idcarrera').AsString <> idanter then Begin
      carrera.getDatos(tabla.FieldByName('idcarrera').AsString);
      if idanter <> '' then list.Linea(0, 0, '', 1, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, 'Carrera: ' + carrera.Idcarrera + ' - ' + carrera.Carrera, 1, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      idanter := tabla.FieldByName('idcarrera').AsString;
    end;

    list.Linea(0, 0, '  ' + tabla.FieldByName('idmateria').AsString + '  ' + tabla.FieldByName('materia').AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(80, list.Lineactual, tabla.FieldByName('curso').AsString, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(90, list.Lineactual, tabla.FieldByName('anualcuat').AsString, 3, 'Arial, normal, 8', salida, 'S');

    tabla.Next;
  end;

  datosdb.QuitarFiltro(tabla);
  tabla.IndexFieldNames := 'idcarrera;idmateria';

  list.FinList;
end;

procedure TTMaterias.Exportar(xidcarrera: String);
// Objetivo...: Exportar Materias
var
  exp_tabla: TTable;
Begin
  exp_tabla := datosdb.openDB('materias', '', '', dbs.DirSistema + '\exportar\escalafon\work');
  exp_tabla.Open;

  datosdb.Filtrar(tabla, 'idcarrera = ' + '''' + xidcarrera + '''');
  tabla.First;
  while not tabla.Eof do Begin
    if datosdb.Buscar(exp_tabla, 'Idcarrera', 'Idmateria', tabla.FieldByName('idcarrera').AsString, tabla.FieldByName('idmateria').AsString) then exp_tabla.Edit else exp_tabla.Append;
    exp_tabla.FieldByName('idcarrera').AsString := tabla.FieldByName('idcarrera').AsString;
    exp_tabla.FieldByName('idmateria').AsString := tabla.FieldByName('idmateria').AsString;
    exp_tabla.FieldByName('materia').AsString   := tabla.FieldByName('materia').AsString;
    exp_tabla.FieldByName('curso').AsString     := tabla.FieldByName('curso').AsString;
    exp_tabla.FieldByName('anualcuat').AsString := tabla.FieldByName('anualcuat').AsString;
    try
      exp_tabla.Post
     except
      exp_tabla.Cancel
    end;
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);
  datosdb.closeDB(exp_tabla);
end;

procedure TTMaterias.Importar;
// Objetivo...: Importar Materias
var
  exp_tabla: TTable;
Begin
  exp_tabla := datosdb.openDB('materias', '', '', dbs.DirSistema + '\importar\escalafon\work');
  exp_tabla.Open;
  exp_tabla.First;
  while not exp_tabla.Eof do Begin
    if datosdb.Buscar(tabla, 'Idcarrera', 'Idmateria', exp_tabla.FieldByName('idcarrera').AsString, exp_tabla.FieldByName('idmateria').AsString) then tabla.Edit else tabla.Append;
    tabla.FieldByName('idcarrera').AsString := exp_tabla.FieldByName('idcarrera').AsString;
    tabla.FieldByName('idmateria').AsString := exp_tabla.FieldByName('idmateria').AsString;
    tabla.FieldByName('materia').AsString   := exp_tabla.FieldByName('materia').AsString;
    tabla.FieldByName('curso').AsString     := exp_tabla.FieldByName('curso').AsString;
    tabla.FieldByName('anualcuat').AsString := exp_tabla.FieldByName('anualcuat').AsString;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    exp_tabla.Next;
  end;
  datosdb.closeDB(exp_tabla);
end;

procedure TTMaterias.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  carrera.conectar;
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
end;

procedure TTMaterias.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  carrera.desconectar;
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function materia: TTMaterias;
begin
  if xmateria = nil then
    xmateria := TTMaterias.Create;
  Result := xmateria;
end;

{===============================================================================}

initialization

finalization
  xmateria.Free;

end.
