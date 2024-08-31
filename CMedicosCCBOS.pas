unit CMedicosCCBOS;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar;

type

TTMedicosOS = class(TObject)
  Codos, Idprof, Nombre: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodos, xIdprof, xNombre: string);
  procedure   Borrar(xcodos, xIdprof: string);
  function    Buscar(xcodos, xIdprof: string): boolean;
  procedure   getDatos(xcodos, xIdprof: string);
  function    setMedicosAlf: TQuery;
  function    getMedicos(xcodos: string): TQuery;
  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  function    BuscarPorNombre(xexpr: string): Boolean;
  procedure   BuscarPorId(xexpr: string);
  function    ExistenProfIgualNombre(xexpr: String): Boolean;

  procedure   Filtrar(xcodos: string);
  procedure   QuitarFiltro;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  conexion: String;
  procedure   ListLinea(salida: char);
  { Declaraciones Privadas }
end;

function medicoos: TTMedicosOS;

implementation

var
  xNombre: TTMedicosOS = nil;

constructor TTMedicosOS.Create;
begin
  inherited Create;
  dbs.getParametrosDB1;     // Base de datos adicional 1
  if Length(Trim(dbs.db1)) > 0 then Begin
    dbs.NuevaBaseDeDatos(dbs.db1, dbs.us1, dbs.pa1);
    conexion := dbs.baseDat_N;
  end else
    conexion := dbs.DirSistema + '\auditoria';

  tabla := datosdb.openDB('medicos_os', '', '', conexion);
end;

destructor TTMedicosOS.Destroy;
begin
  inherited Destroy;
end;

procedure TTMedicosOS.Grabar(xcodos, xIdprof, xNombre: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodos, xIdprof) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codos').AsString  := xcodos;
  tabla.FieldByName('Idprof').AsString := xIdprof;
  tabla.FieldByName('Nombre').AsString := xNombre;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
  datosdb.refrescar(tabla);
end;

procedure TTMedicosOS.Borrar(xcodos, xIdprof: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodos, xIdprof) then Begin
    tabla.Delete;
    datosdb.refrescar(tabla);
  end;
end;

function TTMedicosOS.Buscar(xcodos, xIdprof: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'CODOS;IDPROF' then tabla.IndexFieldNames := 'CODOS;IDPROF';
  result := datosdb.Buscar(tabla, 'CODOS', 'IDPROF', trim(xcodos), trim(xidprof));
end;

procedure  TTMedicosOS.getDatos(xcodos, xIdprof: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xcodos, xIdprof) then Begin
    codos       := tabla.FieldByName('codos').AsString;
    Idprof      := tabla.FieldByName('Idprof').AsString;
    Nombre      := tabla.FieldByName('Nombre').AsString;
  end else Begin
    codos := ''; Idprof := ''; Nombre := '';
  end;
end;

function TTMedicosOS.setMedicosAlf: TQuery;
// Objetivo...: devolver un set con los Nombres disponibles
begin
  Result := datosdb.tranSQL(conexion, 'SELECT * FROM ' + tabla.TableName + ' ORDER BY Nombre');
end;

function TTMedicosOS.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.IndexFieldNames := 'Idprof';
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Begin
    if tabla.FieldByName('Idprof').AsString = '9999' then tabla.Prior;
    Result := IntToStr(StrToInt(tabla.FieldByName('Idprof').AsString) + 1);
  end;
end;

procedure TTMedicosOS.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Médicos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.         Nombre del Profesional', 1, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do Begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('Idprof').AsString >= iniciar) and (tabla.FieldByName('Idprof').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('Idprof').AsString < iniciar) or (tabla.FieldByName('Idprof').AsString > finalizar) then ListLinea(salida);
    // Ordenado Alfabéticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tabla.FieldByName('Nombre').AsString >= iniciar) and (tabla.FieldByName('Nombre').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('Nombre').AsString < iniciar) or (tabla.FieldByName('Nombre').AsString > finalizar) then ListLinea(salida);

    tabla.Next;
  end;
  List.FinList;

  tabla.IndexFieldNames := tabla.IndexFieldNames;
  tabla.First;
end;

procedure TTMedicosOS.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('Idprof').AsString + '   ' + tabla.FieldByName('Nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(95, list.lineactual, ' ', 2, 'Arial, normal, 8', salida, 'S');
end;

function TTMedicosOS.BuscarPorNombre(xexpr: string): Boolean;
// Objetivo...: Buscar Médico por nombre
begin
  if tabla.IndexFieldNames <> 'Nombre' then tabla.IndexFieldNames := 'Nombre';
  tabla.FindNearest([xexpr]);
  if UpperCase(Copy(tabla.FieldByName('nombre').AsString, 1, Length(xexpr))) = UpperCase(xexpr) then Result := True else Result := False;
end;

procedure TTMedicosOS.BuscarPorId(xexpr: string);
begin
  if tabla.IndexFieldNames <> 'Idprof' then tabla.IndexFieldNames := 'Idprof';
  tabla.FindNearest([xexpr]);
end;

function TTMedicosOS.ExistenProfIgualNombre(xexpr: String): Boolean;
// Objetivo...: Verificar si existen dos medicos con el mismo nombre
begin
  Result := False;
  if Length(Trim(xexpr)) > 0 then Begin
    tabla.IndexFieldNames := 'Nombre';
    tabla.FindNearest([xexpr]);
    if UpperCase(Copy(tabla.FieldByName('nombre').AsString, 1, Length(Trim(xexpr)))) = UpperCase(xexpr) then Begin
      tabla.Next;
      if tabla.Eof then Result := False else Begin
        if UpperCase(Copy(tabla.FieldByName('nombre').AsString, 1, Length(Trim(xexpr)))) = UpperCase(xexpr) then Result := True;
        tabla.Prior;
      end;
    end;
  end;
end;

procedure   TTMedicosOS.Filtrar(xcodos: string);
begin
  datosdb.Filtrar(tabla, 'codos = ' + '''' + xcodos + '''');
end;

procedure   TTMedicosOS.QuitarFiltro;
begin
  datosdb.QuitarFiltro(tabla);
end;

function    TTMedicosOS.getMedicos(xcodos: string): TQuery;
begin
  result := datosdb.tranSQL('select * from ' + tabla.TableName + ' where codos = ' + '''' + xcodos + '''' + ' order by nombre');
end;

procedure TTMedicosOS.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    //tabla.FieldByName('Idprof').DisplayLabel := 'Id.'; tabla.FieldByName('Nombre').DisplayLabel := 'Nombre del Profesional'; tabla.FieldByName('codigo').Visible := False;
  end;
  Inc(conexiones);
end;

procedure TTMedicosOS.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function medicoos: TTMedicosOS;
begin
  if xNombre = nil then
    xNombre := TTMedicosOS.Create;
  Result := xNombre;
end;

{===============================================================================}

initialization

finalization
  xNombre.Free;

end.
