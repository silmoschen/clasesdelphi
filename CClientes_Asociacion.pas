unit CClientes_Asociacion;

interface

uses CPersona, CBDT, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM, CObrasSociales;

type

TTCliente = class(TTPersona)
  Telefono, Cuit, Nrodoc, Email: String;
  tabla2: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xcodigo: String): Boolean;
  procedure   Guardar(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono, xcuit, xnrodoc, xemail: string);
  procedure   Borrar(xcodigo: string);
  procedure   getDatos(xcodigo: string);
  function    setClientes: TQuery;
  function    setClientesAlf: TQuery;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   List_linea(salida: char);
end;

function cliente: TTCliente;

implementation

var
  xcliente: TTCliente = nil;

constructor TTCliente.Create;
begin
  inherited Create('', '', '', '', ''); // Hereda de Persona
  tperso   := datosdb.openDB('clientes', '');
  tabla2   := datosdb.openDB('clienth', '');
end;

destructor TTCliente.Destroy;
begin
  inherited Destroy;
end;

function  TTCliente.Buscar(xcodigo: string): boolean;
// Objetivo...: Buscar una instancia
begin
  if tperso.IndexFieldNames <> 'codcli' then tperso.IndexFieldNames := 'codcli';
  if tabla2.FindKey([xcodigo]) then Begin
    inherited Buscar(xcodigo);
    Result := True;
  end else
    Result := False;
end;

procedure TTCliente.Guardar(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono, xcuit, xnrodoc, xemail: String);
// Objetivo...: Almacenar una instacia de la clase
begin
  if Buscar(xcodigo) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('codcli').AsString   := xcodigo;
  tabla2.FieldByName('telefono').AsString := xtelefono;
  tabla2.FieldByName('cuit').AsString     := TrimLeft(xcuit);
  tabla2.FieldByName('nrodoc').AsString   := TrimLeft(xnrodoc);
  tabla2.FieldByName('email').AsString    := xemail;
  try
    tabla2.Post
  except
    tabla2.Cancel
  end;
  inherited Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden);
end;

procedure TTCliente.Borrar(xcodigo: string);
// Objetivo...: Eliminar una instancia
begin
  if Buscar(xcodigo) then Begin
    tabla2.Delete;
    inherited Borrar(xcodigo);
    getDatos(tabla2.FieldByName('codpac').AsString);
  end;
end;

procedure TTCliente.getDatos(xcodigo: string);
// Objetivo...: Cargar/iniciar los atributos para una instancia
begin
  if Buscar(xcodigo) then Begin
    cuit     := tabla2.FieldByName('cuit').AsString;
    telefono := tabla2.FieldByName('telefono').AsString;
    nrodoc   := tabla2.FieldByName('nrodoc').AsString;
    email    := tabla2.FieldByName('email').AsString;
  end else Begin
    cuit := ''; telefono := ''; email := ''; nrodoc := '';
  end;
  inherited getDatos(xcodigo);
end;

function TTCliente.setClientes: TQuery;
// Objetivo...: cerrar tablas de persistencia
begin
  Result := datosdb.tranSQL('SELECT * FROM clientes');
end;

function TTCliente.setClientesAlf: TQuery;
// Objetivo...: cerrar tablas de persistencia
begin
  Result := datosdb.tranSQL('SELECT * FROM clientes ORDER BY nombre');
end;

procedure TTCliente.List_linea(salida: char);
// Objetivo...: Listar una Línea
var
  anios: string;
begin
  anios := '';
  tabla2.FindKey([tperso.FieldByName('codpac').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('codpac').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(40, List.lineactual, tperso.FieldByName('direccion').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(65, List.lineactual, tabla2.FieldByName('telefono').AsString, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(75, List.lineactual, tabla2.FieldByName('cuit').AsString, 4, 'Arial, normal, 8', salida, 'N');
  List.Linea(85, List.lineactual, tabla2.FieldByName('email').AsString, 5, 'Arial, normal, 8', salida, 'S');
end;

procedure TTCliente.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listado de la clase
begin
  if orden = 'A' then tperso.IndexFieldNames := 'Nombre';
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Clientes', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.      Apellido y Nombre', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Dirección', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Teléfono', 4, 'Arial, cursiva, 8');
  List.Titulo(75, List.lineactual, 'C.U.I.T.', 5, 'Arial, cursiva, 8');
  List.Titulo(85, List.lineactual, 'Email', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  tperso.First;
  while not tperso.EOF do Begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tperso.FieldByName('codpac').AsString >= iniciar) and (tperso.FieldByName('codpac').AsString <= finalizar) then List_linea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tperso.FieldByName('codpac').AsString < iniciar) or (tperso.FieldByName('codpac').AsString > finalizar) then List_linea(salida);
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

procedure TTCliente.BuscarPorCodigo(xexpr: string);
// Objetivo...: buscar por código
begin
  tperso.IndexFieldNames := 'Codcli';
  tperso.FindNearest([xexpr]);
end;

procedure TTCliente.BuscarPorNombre(xexpr: string);
// Objetivo...: buscar por nombre
begin
  tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

procedure TTCliente.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    tperso.FieldByName('codpac').DisplayLabel := 'Cód.'; tperso.FieldByName('nombre').DisplayLabel := 'Nombre del cliente'; tperso.FieldByName('direccion').DisplayLabel := 'Dirección';
    tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False;
    if not tabla2.Active then tabla2.Open;
    obsocial.conectar;
  end;
  Inc(conexiones);
end;

procedure TTCliente.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tabla2);
    obsocial.desconectar;
  end;
end;

{===============================================================================}

function cliente: TTCliente;
begin
  if xcliente = nil then
    xcliente := TTCliente.Create;
  Result := xcliente;
end;

{===============================================================================}

initialization

finalization
  xcliente.Free;

end.
