unit CAlumnosFoot;

interface

uses CPersona, CBDT, SysUtils, DB, DBTables, CUtiles, CIDBFM, CListar,
     CPadresFoot, CMadresFoot, CCodpost;

type

TTAlumno = class(TTPersona)          // Clase TVendedor Heredada de Persona
  Fechanac, Dni, Telefono, Idpadre, Idmadre: String;
  Peso, Estatura: Real;
  Puesto: Integer;
  Derivacion, Observacion, Activo: String;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcodpost, xorden, xdni, xfechanac, xtelefono, xidpadre, xidmadre: String; xpeso, xestatura: Real; xpuesto: Integer; xderivacion, xobservacion, xactivo: String);
  function    Borrar(xcodigo: string): String;
  function    Buscar(xcodigo: string): Boolean;
  function    BuscarPorCodigo(xexpr: string): Boolean;
  function    BuscarPorNombre(xexpr: string): Boolean;
  procedure   getDatos(xcodigo: string);

  function    setAlumnosAlf: TQuery;

  procedure   Listar(orden, iniciar, finalizar, ent_excl, xtiposal: string; salida: char);

  procedure   desconectar;
  procedure   conectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure List_linea(xtiposal: String; salida: char);
end;

function alumno: TTAlumno;

implementation

var
  xalumno: TTAlumno = nil;

constructor TTAlumno.Create;
// Vendedor - Heredada de Persona
begin
  inherited Create('', '', '', '', '');
  tperso := datosdb.openDB('alumnos', '');
  tabla  := datosdb.openDB('alumnosh', '');
end;

destructor TTAlumno.Destroy;
begin
  inherited Destroy;
end;

procedure TTAlumno.Grabar(xcodigo, xnombre, xdomicilio, xcodpost, xorden, xdni, xfechanac, xtelefono, xidpadre, xidmadre: String; xpeso, xestatura: Real; xpuesto: Integer; xderivacion, xobservacion, xactivo: String);
// Objetivo...: Grabar Atributos de Vendedores
begin
  if tperso.IndexFieldNames <> 'Id' then tperso.IndexFieldNames := 'Id';
  inherited Grabar(xcodigo, xnombre, xdomicilio, xcodpost, xorden);
  if Buscar(xcodigo) then tabla.Edit else tabla.Append;
  tabla.FieldByName('id').AsString          := xcodigo;
  tabla.FieldByName('dni').AsString         := xdni;
  tabla.FieldByName('fechanac').AsString    := utiles.sExprFecha2000(xfechanac);
  tabla.FieldByName('telefono').AsString    := xtelefono;
  tabla.FieldByName('idpadre').AsString     := xidpadre;
  tabla.FieldByName('idmadre').AsString     := xidmadre;
  tabla.FieldByName('peso').AsFloat         := xpeso;
  tabla.FieldByName('estatura').AsFloat     := xestatura;
  tabla.FieldByName('puesto').AsInteger     := xpuesto;
  tabla.FieldByName('derivacion').AsString  := xderivacion;
  tabla.FieldByName('observacion').AsString := xobservacion;
  tabla.FieldByName('activo').AsString      := xactivo;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.refrescar(tabla);
  datosdb.refrescar(tperso);
end;

procedure  TTAlumno.getDatos(xcodigo: string);
// Objetivo...: Obtener/Inicializar los Atributos para un objeto Vendedor
begin
  if tperso.IndexFieldNames <> 'Id' then tperso.IndexFieldNames := 'Id';
  inherited getDatos(xcodigo);  // Heredamos de la Superclase
  if Buscar(xcodigo) then Begin
    dni         := tabla.FieldByName('dni').AsString;
    fechanac    := utiles.sFormatoFecha(tabla.FieldByName('fechanac').AsString);
    telefono    := tabla.FieldByName('telefono').AsString;
    idpadre     := tabla.FieldByName('idpadre').AsString;
    idmadre     := tabla.FieldByName('idmadre').AsString;
    Peso        := tabla.FieldByName('peso').AsFloat;
    estatura    := tabla.FieldByName('estatura').AsFloat;
    puesto      := tabla.FieldByName('puesto').AsInteger;
    derivacion  := tabla.FieldByName('derivacion').AsString;
    observacion := tabla.FieldByName('observacion').AsString;
    activo      := tabla.FieldByName('activo').AsString;
  end else Begin
    dni := ''; fechanac := ''; telefono := ''; idpadre := ''; idmadre := ''; peso := 0; estatura := 0; puesto := 0; derivacion := ''; observacion := ''; activo := '';
  end;
end;

function TTAlumno.Borrar(xcodigo: string): string;
// Objetivo...: Eliminar un Instancia de Vendedor
begin
  if tperso.IndexFieldNames <> 'Id' then tperso.IndexFieldNames := 'Id';
  inherited Borrar(xcodigo);  // Metodo de la Superclase Persona
  if Buscar(xcodigo) then tabla.Delete;
  datosdb.refrescar(tabla);
  datosdb.refrescar(tperso);
end;

function TTAlumno.Buscar(xcodigo: string): Boolean;
// Objetivo...: Verificar si Existe el Cliente
begin
  if tperso.IndexFieldNames <> 'Id' then tperso.IndexFieldNames := 'Id';
  if tabla.IndexFieldNames <> 'Id' then tabla.IndexFieldNames := 'Id';
  if tabla.FindKey([xcodigo]) then Begin
    inherited Buscar(xcodigo);  // Método de la Superclase (Sincroniza los Valores de las Tablas)
    Result := True;
  end else
    Result := False;
end;

function TTAlumno.BuscarPorCodigo(xexpr: string): boolean;
// Objetivo...: Buscar un cliente por codigo
begin
  if tperso.IndexFieldNames <> 'Id' then tperso.IndexFieldNames := 'Id';
  tperso.FindNearest([xexpr]);
end;

function TTAlumno.BuscarPorNombre(xexpr: string): boolean;
// Objetivo...: Buscar un cliente por nombre
begin
  if tperso.IndexFieldNames <> 'Nombre' then tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

function  TTAlumno.setAlumnosAlf: TQuery;
// Objetivo...: Obtener Nómina de Alumnos
begin
  Result := datosdb.tranSQL('select id, nombre from alumnos order by nombre'); 
end;

procedure TTAlumno.List_linea(xtiposal: String; salida: char);
// Objetivo...: Listar una Línea
var
  l: Boolean;
begin
  tabla.FindKey([tperso.FieldByName('id').AsString]);
  l := False;
  if xtiposal = 'T' then l := True;
  if xtiposal = 'A' then
    if tabla.FieldByName('activo').AsString = 'S' then l := True;
  if xtiposal = 'I' then
    if tabla.FieldByName('activo').AsString = 'N' then l := True;
  if l then Begin
    cpost.getDatos(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString);
    List.Linea(0, 0, tperso.FieldByName('id').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
    List.Linea(40, List.lineactual, tperso.FieldByName('direccion').AsString, 2, 'Arial, normal, 8', salida, 'N');
    List.Linea(70, List.lineactual, cpost.localidad, 3, 'Arial, normal, 8', salida, 'S');
  end;
end;

procedure TTAlumno.Listar(orden, iniciar, finalizar, ent_excl, xtiposal: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Alumnos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.      Nombre del Alumno', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Dirección', 2, 'Arial, cursiva, 8');
  List.Titulo(70, List.lineactual, 'Localidad', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('id').AsString >= iniciar) and (tperso.FieldByName('id').AsString <= finalizar) then List_linea(xtiposal, salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('id').AsString < iniciar) or (tperso.FieldByName('id').AsString > finalizar) then List_linea(xtiposal, salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString >= iniciar) and (tperso.FieldByName('nombre').AsString <= finalizar) then List_linea(xtiposal, salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString < iniciar) or (tperso.FieldByName('nombre').AsString > finalizar) then List_linea(xtiposal, salida);

      tperso.Next;
    end;

  List.FinList;

  tperso.IndexFieldNames := tperso.IndexFieldNames;
  tperso.First;
end;

procedure TTAlumno.conectar;
// Objetivo...: Abrir las tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    if not tabla.Active then tabla.Open;
  end;
  tperso.FieldByName('Id').DisplayLabel := 'Cód.'; tperso.FieldByName('Nombre').DisplayLabel := 'Nombre';
  tperso.FieldByName('direccion').DisplayLabel := 'Dirección';
  Inc(conexiones);
  padre.conectar;
  madre.conectar;
  cpost.conectar;
end;

procedure TTAlumno.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tabla);
  end;
  padre.desconectar;
  madre.desconectar;
  cpost.desconectar;
end;

{===============================================================================}

function alumno: TTAlumno;
begin
  if xalumno = nil then
    xalumno := TTAlumno.Create;
  Result := xalumno;
end;

{===============================================================================}

initialization

finalization
  xalumno.Free;

end.