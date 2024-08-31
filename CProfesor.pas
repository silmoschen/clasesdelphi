unit CProfesor;

interface

uses CBDT, CPersona, CCodPost, CListar, DB, DBTables, CIDBFM, CUtiles;

type

TTProfesor = class(TTPersona)          // Clase TVendedor Heredada de Persona
  telefono, fealta, especialidad: string;
  tprofesor: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xidprofesor, xnombre, xdomicilio, xcp, xorden, xtelefono, xfealta, xespecialidad: string);
  destructor  Destroy; override;

  function    getTelefono: string;
  function    getFealta: string;
  function    getEspecialidad: string;

  function    Buscar(xidprofesor: string): boolean;
  procedure   getDatos(xidprofesor: string);
  procedure   Grabar(xidprofesor, xnombre, xdomicilio, xcp, xorden, xtelefono, xfealta, xespecialidad: string);
  procedure   Borrar(xidprofesor: string);
  function    setProfesores: TQuery;

  procedure   conectar;
  procedure   desconectar;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
 private
  { Declaraciones Privadas }
  procedure list_linea(salida: char);
end;

function profesor: TTProfesor;

implementation

var
  xprofesor: TTProfesor = nil;

constructor TTProfesor.Create(xidprofesor, xnombre, xdomicilio, xcp, xorden, xtelefono, xfealta, xespecialidad: string);
// Vendedor - Heredada de Persona
begin
  inherited Create(xidprofesor, xnombre, xdomicilio, xcp, xorden); // Constructor de la superclase
  telefono     := xtelefono;
  fealta       := xfealta;
  especialidad := xespecialidad;

  tperso    := datosdb.openDB('profesor.DB', 'Nrolegajo');
  tprofesor := datosdb.openDB('profesoh.DB', 'Nrolegajo');
end;

function TTProfesor.getTelefono: string;
begin
  Result := telefono;
end;

function TTProfesor.getFealta: string;
begin
  Result := fealta;
end;

function TTProfesor.getEspecialidad: string;
begin
  Result := especialidad;
end;

function TTProfesor.Buscar(xidprofesor: string): boolean;
// Objetivo...: Buscar atributos en tablas de persistencia
begin
  Result := False;
  if inherited Buscar(xidprofesor) then
    begin
      if tprofesor.FindKey([xidprofesor]) then Result := True;
    end
end;

procedure TTProfesor.getDatos(xidprofesor: string);
// Objetivo...: actualizar los atributos de la clase a partir de la tabla de persistencia
begin
  inherited getDatos(xidprofesor);
  if Buscar(xidprofesor) then
    begin
      telefono     := tprofesor.FieldByName('telefono').AsString;
      fealta       := utiles.sFormatoFecha(tprofesor.FieldByName('fealta').AsString);
      especialidad := tprofesor.FieldByName('especialidad').AsString;
    end
  else
    begin
      telefono := ''; fealta := ''; especialidad := '';
    end;
end;

procedure TTProfesor.Grabar(xidprofesor, xnombre, xdomicilio, xcp, xorden, xtelefono, xfealta, xespecialidad: string);
// Objetivo...: grabar atributos en tablas de persistencia
begin
  inherited Grabar(xidprofesor, xnombre, xdomicilio, xcp, xorden);
  if Buscar(xidprofesor) then tprofesor.Edit else tprofesor.Append;
  tprofesor.FieldByName('nrolegajo').AsString    := xidprofesor;
  tprofesor.FieldByName('fealta').AsString       := utiles.sExprFecha(xfealta);
  tprofesor.FieldByName('especialidad').AsString := xespecialidad;
  tprofesor.FieldByName('telefono').AsString     := xtelefono;
  try
    tprofesor.Post;
  except
    tprofesor.cancel;
  end;
end;

procedure TTProfesor.Borrar(xidprofesor: string);
// Objetivo...: Borrar una instancia de la clase - de las tablas de persistencia
begin
  if Buscar(xidprofesor) then
    begin
      inherited Borrar(xidprofesor);
      tprofesor.Delete;
      getDatos(tperso.FieldByName('nrolegajo').AsString);
    end;
end;

destructor TTProfesor.Destroy;
begin
  inherited Destroy;
end;

function TTProfesor.setProfesores: TQuery;
// Objetivo...: devolver un set de profesores
begin
  Result := datosdb.tranSQL('SELECT * FROM profesor ORDER BY nombre');
end;

procedure TTProfesor.conectar;
// Objetivo...: abrir tablas de persistencia
begin
  if not tperso.Active  then tperso.Open;
  if not tprofesor.Active then tprofesor.Open;
  tperso.FieldByName('nrolegajo').DisplayLabel := 'NºLeg.';
  tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False;
  cpost.conectar;
end;

procedure TTProfesor.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  datosdb.closeDB(tperso);
  datosdb.closeDB(tprofesor);
  cpost.desconectar;
end;

procedure TTProfesor.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  if cpost.Buscar(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString) then cpost.getDatos(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString);
  tprofesor.FindKey([tperso.FieldByName('nrolegajo').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('nrolegajo').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(38, List.lineactual, tperso.FieldByName('domicilio').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(65, List.lineactual, tperso.FieldByName('cp').AsString + ' ' + tperso.FieldByName('orden').AsString + '  ' + cpost.Localidad, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(84, List.lineactual, tprofesor.FieldByName('especialidad').AsString, 4, 'Arial, normal, 8', salida, 'S');
end;

procedure TTProfesor.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Profesores', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'NºLeg.  Nombre', 1, 'Arial, cursiva, 8');
  List.Titulo(38, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'CP-Orden   Localidad', 3, 'Arial, cursiva, 8');
  List.Titulo(84, List.lineactual, 'Especialidad', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('nrolegajo').AsString >= iniciar) and (tperso.FieldByName('nrolegajo').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('nrolegajo').AsString < iniciar) or (tperso.FieldByName('nrolegajo').AsString > finalizar) then List_linea(salida);
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

function profesor: TTProfesor;
begin
  if xprofesor = nil then
    xprofesor := TTProfesor.Create('', '', '', '', '', '', '', '');
  Result := xprofesor;
end;

{===============================================================================}

initialization

finalization
  xprofesor.Free;

end.