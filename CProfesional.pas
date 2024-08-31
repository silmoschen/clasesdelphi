unit CProfesional;

interface

uses CPersona, CBDT, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM;

type

TTProfesional = class(TTPersona)
  nombres, email, telefono: string;
  tabla2: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create(xcodigo, xapellido, xdomicilio, xcp, xorden, xnombres, xemail, xtelefono: string);
  destructor  Destroy; override;

  function    Buscar(xcodigo: string): boolean;
  procedure   Grabar(xcodigo, xapellido, xdomicilio, xcp, xorden, xnombres, xemail, xtelefono: string);
  procedure   Borrar(xcodigo: string);
  procedure   getDatos(xcodigo: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  function    BuscarApellidoProfesional(xapellido: string): boolean;
  procedure   BuscarApellido(xapellido: string);
  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);
  function    ExistenProfIgualNombre(xexpr: String): Boolean;
  function    Nuevo: string;
  function    getProfesionales: TQuery;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   List_linea(salida: char);
  procedure   List_Tit(salida: char);
  procedure   Enccol;
end;

function profesional: TTProfesional;

implementation

var
  xprofesional: TTProfesional = nil;

constructor TTProfesional.Create(xcodigo, xapellido, xdomicilio, xcp, xorden, xnombres, xemail, xtelefono: string);
begin
  inherited Create(xcodigo, xapellido, xdomicilio, xcp, xorden); // Hereda de Persona
  if dbs.BaseClientServ = 'N' then Begin
    tperso := datosdb.openDB('profesio', 'Idprof');
    tabla2 := datosdb.openDB('profesih', 'Idprof');
  end;
  if dbs.BaseClientServ = 'S' then Begin
    tperso := datosdb.openDB('profesio', 'Idprof'); // dbs.baseDat_N);
    tabla2 := datosdb.openDB('profesih', 'Idprof'); // dbs.baseDat_N);
  end;
end;

destructor TTProfesional.Destroy;
begin
  inherited Destroy;
end;

function  TTProfesional.Buscar(xcodigo: string): boolean;
// Objetivo...: Buscar una instancia
begin
  if not tperso.Active then tperso.Open;
  if not tabla2.Active then Begin
    tabla2.Open;
    Enccol;
  end;
  if tperso.IndexFieldNames <> 'Idprof' then tperso.IndexFieldNames := 'Idprof';
  if tabla2.IndexFieldNames <> 'Idprof' then tabla2.IndexFieldNames := 'Idprof';
  if tabla2.FindKey([xcodigo]) then Begin
    inherited Buscar(xcodigo);
    Result := True;
  end else
    Result := False;
end;

procedure TTProfesional.Grabar(xcodigo, xapellido, xdomicilio, xcp, xorden, xnombres, xemail, xtelefono: string);
// Objetivo...: Almacenar una instacia de la clase
begin
  if Buscar(xcodigo) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('idprof').AsString   := xcodigo;
  tabla2.FieldByName('nombre').AsString   := TrimLeft(xnombres);
  tabla2.FieldByName('email').AsString    := TrimLeft(xemail);
  tabla2.FieldByName('telefono').AsString := TrimLeft(xtelefono);
  try
    tabla2.Post
  except
    tabla2.Cancel
  end;
  inherited Grabar(xcodigo, xapellido, xdomicilio, '', '');
end;

procedure TTProfesional.Borrar(xcodigo: string);
// Objetivo...: Eliminar una instancia
begin
  if Buscar(xcodigo) then Begin
    tabla2.Delete;
    inherited Borrar(xcodigo);
    getDatos(tabla2.FieldByName('idprof').AsString);
  end;
end;

procedure TTProfesional.getDatos(xcodigo: string);
// Objetivo...: Cargar/iniciar los atributos para una instancia
begin
  if Buscar(xcodigo) then
    begin
      email    := tabla2.FieldByName('email').AsString;
      telefono := tabla2.FieldByName('telefono').AsString;
      nombres  := tabla2.FieldByName('nombre').AsString;
    end
  else
    begin
      email := ''; nombres := ''; telefono := '';
    end;
  inherited getDatos(xcodigo);
end;

procedure TTProfesional.BuscarApellido(xapellido: string);
// Objetivo...: Busqueda contextual por apellido
begin
  tperso.IndexFieldNames := 'apellido';
  tperso.FindNearest([xapellido]);
  tperso.IndexFieldNames := 'idprof';
end;

function TTProfesional.BuscarApellidoProfesional(xapellido: string): boolean;
// Objetivo...: Busqueda del profesional por apellido
begin
  tperso.IndexFieldNames := 'apellido';
  if tperso.FindKey([xapellido]) then Result := True else Result := False;
  tperso.IndexFieldNames := 'idprof';
end;

procedure TTProfesional.List_Tit(salida: char);
// Objetivo...: Listar una L�nea
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Profesionales', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'C�d.  Apellido y Nombre', 1, 'Arial, cursiva, 8');
  List.Titulo(38, List.lineactual, 'Direcci�n', 2, 'Arial, cursiva, 8');
  List.Titulo(63, List.lineactual, 'Tel�fono', 3, 'Arial, cursiva, 8');
  List.Titulo(85, List.lineactual, 'E-mail', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTProfesional.List_linea(salida: char);
// Objetivo...: Listar una L�nea
begin
  if tabla2.IndexFieldNames <> 'Idprof' then tabla2.IndexFieldNames := 'Idprof'; 
  tabla2.FindKey([tperso.FieldByName('idprof').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('idprof').AsString + '  ' + tabla2.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(38, List.lineactual, tperso.FieldByName('domicilio').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(63, List.lineactual, tabla2.FieldByName('telefono').AsString, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(85, List.lineactual, tabla2.FieldByName('email').AsString, 4, 'Arial, normal, 8', salida, 'S');
end;

procedure TTProfesional.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listado de la clase
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;
  list_Tit(salida);

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por C�digo
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('idprof').AsString >= iniciar) and (tperso.FieldByName('idprof').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('idprof').AsString < iniciar) or (tperso.FieldByName('idprof').AsString > finalizar) then List_linea(salida);
      // Ordenado Alfab�ticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.FieldByName('apellido').AsString >= iniciar) and (tperso.FieldByName('apellido').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.FieldByName('apellido').AsString < iniciar) or (tperso.FieldByName('apellido').AsString > finalizar) then List_linea(salida);

      tperso.Next;
    end;
    List.FinList;

    tperso.IndexFieldNames := tperso.IndexFieldNames;
    tperso.First;
end;

procedure TTProfesional.BuscarPorCodigo(xexpr: string);
begin
  tabla2.IndexFieldNames := 'Idprof';
  tabla2.FindNearest([xexpr]);
end;

procedure TTProfesional.BuscarPorNombre(xexpr: string);
begin
  tabla2.IndexFieldNames := 'Nombre';
  tabla2.FindNearest([xexpr]);
end;

function TTProfesional.ExistenProfIgualNombre(xexpr: String): Boolean;
begin
  Result := False;
  if Length(Trim(xexpr)) > 0 then Begin
    tabla2.IndexFieldNames := 'Nombre';
    tabla2.FindNearest([xexpr]);
    if UpperCase(Copy(tabla2.FieldByName('nombre').AsString, 1, Length(Trim(xexpr)))) = UpperCase(xexpr) then Begin
      tabla2.Next;
      if UpperCase(Copy(tabla2.FieldByName('nombre').AsString, 1, Length(Trim(xexpr)))) = UpperCase(xexpr) then Result := True;
      tabla2.Prior;
    end;
  end;
end;

procedure TTProfesional.Enccol;
// Objetivo...: mostrar nombre de columnas
begin
  tperso.FieldByName('idprof').DisplayLabel := 'C�d.'; tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False;
  tabla2.FieldByName('idprof').DisplayLabel := 'C�d.'; tabla2.FieldByName('direccion').DisplayLabel := 'Direcci�n'; tabla2.FieldByName('especial').DisplayLabel := 'Especialidad'; tabla2.FieldByName('telefono').DisplayLabel := 'Tel�fono';
  tabla2.FieldByName('matricula').DisplayLabel := 'Matr�cula'; tabla2.FieldByName('categoria').DisplayLabel := 'Cat.'; tabla2.FieldByName('tipodoc').DisplayLabel := 'T.Doc.'; tabla2.FieldByName('numdoc').DisplayLabel := 'N� Documento';
  tabla2.FieldByName('nombre').DisplayLabel := 'Nombre del Profesional'; tabla2.FieldByName('email').DisplayLabel := 'Email';
end;

function TTProfesional.Nuevo: string;
// Objetivo...: Busqueda del profesional por apellido
var
  i: integer;
  r: TQuery;
begin
  r := datosdb.tranSQL(tperso.DatabaseName, 'select max(cast(idprof as integer)) from ' + tperso.TableName);
  r.open;
  i := r.Fields[0].AsInteger;
  r.close;

  i := i +1;   

  result := IntToStr(i);
end;

function  TTProfesional.getProfesionales: TQuery;
begin
  result := datosdb.tranSQL('select * from profesih');
end;

procedure TTProfesional.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    if not tabla2.Active then tabla2.Open;
    Enccol;
  end;
  Inc(conexiones);
end;

procedure TTProfesional.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tabla2);
  end;
end;

{===============================================================================}

function profesional: TTProfesional;
begin
  if xprofesional = nil then
    xprofesional := TTProfesional.Create('', '', '', '', '', '', '', '');
  Result := xprofesional;
end;

{===============================================================================}

initialization

finalization
  xprofesional.Free;

end.
