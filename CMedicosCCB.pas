unit CMedicosCCB;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar;

type

TTMedicos = class(TObject)
  Idprof, Nombre: string;
  Inactivo: boolean;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xIdprof, xNombre: string; xinactivo: boolean);
  procedure   Borrar(xIdprof: string);
  function    Buscar(xIdprof: string): boolean;
  procedure   getDatos(xIdprof: string);
  function    setMedicosAlf: TQuery;
  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  function    BuscarPorNombre(xexpr: string): Boolean;
  procedure   BuscarPorId(xexpr: string);
  function    ExistenProfIgualNombre(xexpr: String): Boolean;
  procedure   FiltrarActivos;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  conexion: String;
  procedure   ListLinea(salida: char);
  { Declaraciones Privadas }
end;

function medico: TTMedicos;

implementation

var
  xNombre: TTMedicos = nil;

constructor TTMedicos.Create;
begin
  inherited Create;
  dbs.getParametrosDB1;     // Base de datos adicional 1
  if Length(Trim(dbs.db1)) > 0 then Begin
    dbs.NuevaBaseDeDatos(dbs.db1, dbs.us1, dbs.pa1);
    conexion := dbs.baseDat_N;
  end else
    conexion := dbs.DirSistema + '\auditoria';

  tabla := datosdb.openDB('Medicos', 'Idprof', '', conexion);
end;

destructor TTMedicos.Destroy;
begin
  inherited Destroy;
end;

procedure TTMedicos.FiltrarActivos;
begin
  datosdb.Filtrar(tabla, 'inactivo = null');
end;

procedure TTMedicos.Grabar(xIdprof, xNombre: string; xinactivo: boolean);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xIdprof) then tabla.Edit else tabla.Append;
  tabla.FieldByName('Idprof').AsString      := xIdprof;
  tabla.FieldByName('Nombre').AsString      := xNombre;
  if (xinactivo) then tabla.FieldByName('Inactivo').AsInteger := 1 else tabla.FieldByName('Inactivo').Clear;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTMedicos.Borrar(xIdprof: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xIdprof) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('Idprof').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTMedicos.Buscar(xIdprof: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'Idprof' then tabla.IndexFieldNames := 'Idprof';
  if tabla.FindKey([xIdprof]) then Result := True else Result := False;
end;

procedure  TTMedicos.getDatos(xIdprof: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xIdprof) then Begin
    Idprof      := tabla.FieldByName('Idprof').AsString;
    Nombre      := tabla.FieldByName('Nombre').AsString;
    Inactivo    := false;
    if tabla.FieldByName('Inactivo').AsInteger = 1 then Inactivo := true;
  end else Begin
    Idprof := ''; Nombre := ''; Inactivo := false;
  end;
end;

function TTMedicos.setMedicosAlf: TQuery;
// Objetivo...: devolver un set con los Nombres disponibles
begin
  Result := datosdb.tranSQL(conexion, 'SELECT * FROM ' + tabla.TableName + ' ORDER BY Nombre');
end;

function TTMedicos.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.IndexFieldNames := 'Idprof';
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Begin
    if tabla.FieldByName('Idprof').AsString = '9999' then tabla.Prior;
    Result := IntToStr(StrToInt(tabla.FieldByName('Idprof').AsString) + 1);
  end;
end;

procedure TTMedicos.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
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

procedure TTMedicos.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('Idprof').AsString + '   ' + tabla.FieldByName('Nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(95, list.lineactual, ' ', 2, 'Arial, normal, 8', salida, 'S');
end;

function TTMedicos.BuscarPorNombre(xexpr: string): Boolean;
// Objetivo...: Buscar Médico por nombre
begin
  if tabla.IndexFieldNames <> 'Nombre' then tabla.IndexFieldNames := 'Nombre';
  tabla.FindNearest([xexpr]);
  if UpperCase(Copy(tabla.FieldByName('nombre').AsString, 1, Length(xexpr))) = UpperCase(xexpr) then Result := True else Result := False; 
end;

procedure TTMedicos.BuscarPorId(xexpr: string);
begin
  if tabla.IndexFieldNames <> 'Idprof' then tabla.IndexFieldNames := 'Idprof';
  tabla.FindNearest([xexpr]);
end;

function TTMedicos.ExistenProfIgualNombre(xexpr: String): Boolean;
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

procedure TTMedicos.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('Idprof').DisplayLabel := 'Id.'; tabla.FieldByName('Nombre').DisplayLabel := 'Nombre del Profesional'; tabla.FieldByName('codigo').Visible := False;
    tabla.FieldByName('inactivo').DisplayLabel := 'Inactivo';
  end;
  Inc(conexiones);
end;

procedure TTMedicos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function medico: TTMedicos;
begin
  if xNombre = nil then
    xNombre := TTMedicos.Create;
  Result := xNombre;
end;

{===============================================================================}

initialization

finalization
  xNombre.Free;

end.
