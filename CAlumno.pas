unit CAlumno;

interface

uses CBDT, CPersona, CCodPost, CListar, DB, DBTables, CIDBFM, CUtiles;

type

TTAlumno = class(TTPersona)          // Clase TVendedor Heredada de Persona
  telefono, fechanac, ofenroladora, nrodoc: string;
  talumno: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xidalumno, xnombre, xdomicilio, xcp, xorden, xtelefono, xfechanac, xofenroladora, xnrodoc: string);
  destructor  Destroy; override;

  function    Buscar(xidalumno: string): boolean;
  procedure   getDatos(xidalumno: string);
  procedure   Grabar(xidalumno, xnombre, xdomicilio, xcp, xorden, xtelefono, xfechanac, xofenroladora, xnrodoc: string);
  procedure   Borrar(xidalumno: string);
  function    setAlumnos: TQuery;

  procedure   conectar;
  procedure   desconectar;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
 private
  { Declaraciones Privadas }
  procedure   List_linea(salida: char);
end;

function alumno: TTAlumno;

implementation

var
  xalumno: TTAlumno = nil;

constructor TTAlumno.Create(xidalumno, xnombre, xdomicilio, xcp, xorden, xtelefono, xfechanac, xofenroladora, xnrodoc: string);
// Vendedor - Heredada de Persona
begin
  inherited Create(xidalumno, xnombre, xdomicilio, xcp, xorden);  // Constructor de la Superclase
  telefono     := xtelefono;
  fechanac     := xfechanac;
  ofenroladora := xofenroladora;
  nrodoc       := xnrodoc;

  tperso  := datosdb.openDB('alumnos', 'Idalumno');
  talumno := datosdb.openDB('alumnoh', 'Idalumno');
end;

destructor TTAlumno.Destroy;
begin
  inherited Destroy;
end;

function TTAlumno.Buscar(xidalumno: string): boolean;
// Objetivo...: Buscar atributos en tablas de persistencia
begin
  if inherited Buscar(xidalumno) then
    begin
      if talumno.FindKey([xidalumno]) then Result := True;
    end
  else
    Result := False;
end;

procedure TTAlumno.getDatos(xidalumno: string);
// Objetivo...: actualizar los atributos de la clase a partir de la tabla de persistencia
begin
  talumno.Refresh;
  inherited getDatos(xidalumno);
  if Buscar(xidalumno) then
    begin
      telefono     := talumno.FieldByName('telefono').AsString;
      fechanac     := utiles.sFormatoFecha(talumno.FieldByName('fechanac').AsString);
      ofenroladora := talumno.FieldByName('ofenroladora').AsString;
      nrodoc       := talumno.FieldByName('nrodoc').AsString;
    end
  else
    begin
      telefono := ''; fechanac := ''; ofenroladora := ''; nrodoc := '';
    end;
end;

procedure TTAlumno.Grabar(xidalumno, xnombre, xdomicilio, xcp, xorden, xtelefono, xfechanac, xofenroladora, xnrodoc: string);
// Objetivo...: grabar atributos en tablas de persistencia
begin
  inherited Grabar(xidalumno, xnombre, xdomicilio, xcp, xorden);
  if Buscar(xidalumno) then talumno.Edit else talumno.Append;
  talumno.FieldByName('idalumno').AsString     := xidalumno;
  talumno.FieldByName('fechanac').AsString     := utiles.sExprFecha(xfechanac);
  talumno.FieldByName('ofenroladora').AsString := xofenroladora;
  talumno.FieldByName('nrodoc').AsString       := xnrodoc;
  talumno.FieldByName('telefono').AsString     := xtelefono;
  try
    talumno.Post;
  except
    talumno.cancel;
  end;
end;

procedure TTAlumno.Borrar(xidalumno: string);
// Objetivo...: Borrar una instancia de la clase - de las tablas de persistencia
begin
  if Buscar(xidalumno) then
    begin
      inherited Borrar(xidalumno);
      talumno.Delete;
      getDatos(tperso.FieldByName('idalumno').AsString);
    end;
end;

function TTAlumno.setAlumnos;
// Objetivo...: retornar un set de alumnos
begin
  Result := datosdb.tranSQL('SELECT * FROM alumnos ORDER BY nombre');
end;

procedure TTAlumno.conectar;
// Objetivo...: abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active  then tperso.Open;
    if not talumno.Active then talumno.Open;
    cpost.conectar;
  end;
  Inc(conexiones);
end;

procedure TTAlumno.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(talumno);
    cpost.desconectar;
  end;
end;

procedure TTAlumno.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  if cpost.Buscar(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString) then cpost.getDatos(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString);
  talumno.FindKey([tperso.FieldByName('idalumno').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('idalumno').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(40, List.lineactual, tperso.FieldByName('domicilio').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(67, List.lineactual, tperso.FieldByName('cp').AsString + ' ' + tperso.FieldByName('orden').AsString + '  ' + cpost.Localidad, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(87, List.lineactual, talumno.FieldByName('nrodoc').AsString, 4, 'Arial, normal, 8', salida, 'S');
end;

procedure TTAlumno.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de alumnos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.      Nombre', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(67, List.lineactual, 'CP Orden Localidad', 3, 'Arial, cursiva, 8');
  List.Titulo(87, List.lineactual, 'Nº Documento', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('idalumno').AsString >= iniciar) and (tperso.FieldByName('idalumno').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('idalumno').AsString < iniciar) or (tperso.FieldByName('idalumno').AsString > finalizar) then List_linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString >= iniciar) and (tperso.FieldByName('nombre').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString < iniciar) or (tperso.FieldByName('nombre').AsString > finalizar) then List_linea(salida);

      tperso.Next;
    end;
    List.FinList;

    tperso.IndexFieldNames := tperso.IndexFieldNames;
    tperso.First;
end;

{===============================================================================}

function alumno: TTAlumno;
begin
  if xalumno = nil then
    xalumno := TTAlumno.Create('', '', '', '', '', '', '', '', '');
  Result := xalumno;
end;

{===============================================================================}

initialization

finalization
  xalumno.Free;

end.