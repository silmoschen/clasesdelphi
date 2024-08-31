unit CPrestatarios_Asociacion;

interface

uses CPersona, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CCodPost, CTPFiscal;

type

TTPrestatario = class(TTPersona)
  Telefono, Cuit, Nrodoc, Email, UltimoExpediente, Codpfis: String;
  tabla2: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xcodigo: String): Boolean;
  procedure   Guardar(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono, xcuit, xnrodoc, xemail, xexpediente, xcodpfis: string);
  procedure   Borrar(xcodigo: string);
  procedure   getDatos(xcodigo: string);
  function    setPrestatarios: TQuery;
  function    setPrestatariosAlf: TQuery;
  function    setPrestatariosLocalidad(xcp: String): TQuery;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);

  function    NuevoExpediente(xcodprest: String): String;
  procedure   GuardarNumeroExpediente(xcodprest, xexpediente: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   List_linea(salida: char);
end;

function prestatario: TTPrestatario;

implementation

var
  xprestatario: TTPrestatario = nil;

constructor TTPrestatario.Create;
begin
  inherited Create('', '', '', '', ''); // Hereda de Persona
  tperso   := datosdb.openDB('prestatarios', '');
  tabla2   := datosdb.openDB('prestatarioh', '');
end;

destructor TTPrestatario.Destroy;
begin
  inherited Destroy;
end;

function  TTPrestatario.Buscar(xcodigo: string): boolean;
// Objetivo...: Buscar una instancia
begin
  if tperso.IndexFieldNames <> 'codprest' then tperso.IndexFieldNames := 'codprest';
  if tabla2.FindKey([xcodigo]) then Begin
    inherited Buscar(xcodigo);
    Result := True;
  end else
    Result := False;
end;

procedure TTPrestatario.Guardar(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono, xcuit, xnrodoc, xemail, xexpediente, xcodpfis: String);
// Objetivo...: Almacenar una instacia de la clase
begin
  if Buscar(xcodigo) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('codprest').AsString   := xcodigo;
  tabla2.FieldByName('telefono').AsString   := xtelefono;
  tabla2.FieldByName('cuit').AsString       := TrimLeft(xcuit);
  tabla2.FieldByName('nrodoc').AsString     := TrimLeft(xnrodoc);
  tabla2.FieldByName('email').AsString      := xemail;
  if Length(Trim(xexpediente)) > 0 then tabla2.FieldByName('expediente').AsString := xexpediente else tabla2.FieldByName('expediente').AsString := '0';
  tabla2.FieldByName('codpfis').AsString    := xcodpfis;
  try
    tabla2.Post
  except
    tabla2.Cancel
  end;
  inherited Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden);
end;

procedure TTPrestatario.Borrar(xcodigo: string);
// Objetivo...: Eliminar una instancia
begin
  if Buscar(xcodigo) then Begin
    tabla2.Delete;
    inherited Borrar(xcodigo);
    getDatos(tabla2.FieldByName('codprest').AsString);
  end;
end;

procedure TTPrestatario.getDatos(xcodigo: string);
// Objetivo...: Cargar/iniciar los atributos para una instancia
begin
  if Buscar(xcodigo) then Begin
    cuit             := tabla2.FieldByName('cuit').AsString;
    telefono         := tabla2.FieldByName('telefono').AsString;
    nrodoc           := tabla2.FieldByName('nrodoc').AsString;
    email            := tabla2.FieldByName('email').AsString;
    UltimoExpediente := utiles.sLlenarIzquierda(tabla2.FieldByName('expediente').AsString, 4, '0');
    codpfis          := tabla2.FieldByName('codpfis').AsString;
  end else Begin
    cuit := ''; telefono := ''; email := ''; nrodoc := ''; UltimoExpediente := '0000'; codpfis := '';
  end;
  inherited getDatos(xcodigo);
end;

function TTPrestatario.setPrestatarios: TQuery;
// Objetivo...: cerrar tablas de persistencia
begin
  Result := datosdb.tranSQL('SELECT * FROM prestatarios');
end;

function TTPrestatario.setPrestatariosAlf: TQuery;
// Objetivo...: devolver prestatarios ordenados por nombre
begin
  Result := datosdb.tranSQL('SELECT * FROM prestatarios ORDER BY nombre');
end;

function TTPrestatario.setPrestatariosLocalidad(xcp: String): TQuery;
// Objetivo...: devolver sql con prestatarios ordenados por Localidad
begin
  Result := datosdb.tranSQL('SELECT * FROM prestatarios WHERE cp = ' + '"' + xcp + '"' + ' ORDER BY nombre');
end;

procedure TTPrestatario.List_linea(salida: char);
// Objetivo...: Listar una Línea
var
  anios: string;
begin
  anios := '';
  tabla2.FindKey([tperso.FieldByName('codprest').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('codprest').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(40, List.lineactual, Copy(tperso.FieldByName('direccion').AsString, 1, 25), 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(65, List.lineactual, Copy(tabla2.FieldByName('telefono').AsString, 1, 10), 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(75, List.lineactual, tabla2.FieldByName('cuit').AsString, 4, 'Arial, normal, 8', salida, 'N');
  List.Linea(87, List.lineactual, tabla2.FieldByName('email').AsString, 5, 'Arial, normal, 8', salida, 'S');
end;

procedure TTPrestatario.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listado de la clase
begin
  list.Setear(salida); 
  if orden = 'A' then tperso.IndexFieldNames := 'Nombre';
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Prestatarios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Código  Apellido y Nombre', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Dirección', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Teléfono', 4, 'Arial, cursiva, 8');
  List.Titulo(75, List.lineactual, 'C.U.I.T.', 5, 'Arial, cursiva, 8');
  List.Titulo(87, List.lineactual, 'Email', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  tperso.First;
  while not tperso.EOF do Begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tperso.FieldByName('codprest').AsString >= iniciar) and (tperso.FieldByName('codprest').AsString <= finalizar) then List_linea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tperso.FieldByName('codprest').AsString < iniciar) or (tperso.FieldByName('codprest').AsString > finalizar) then List_linea(salida);
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

procedure TTPrestatario.BuscarPorCodigo(xexpr: string);
// Objetivo...: buscar por código
begin
  tperso.IndexFieldNames := 'Codprest';
  tperso.FindNearest([xexpr]);
end;

procedure TTPrestatario.BuscarPorNombre(xexpr: string);
// Objetivo...: buscar por nombre
begin
  tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

function TTPrestatario.NuevoExpediente(xcodprest: String): String;
// Objetivo...: generar numero de expediente
var
  nro: String;
Begin
  nro := '1';
  UltimoExpediente := tabla2.FieldByName('expediente').AsString;
  if Buscar(xcodprest) then nro := IntToStr(StrToInt(tabla2.FieldByName('expediente').AsString) + 1);
  Result := utiles.sLlenarIzquierda(nro, 4, '0');
end;

procedure TTPrestatario.GuardarNumeroExpediente(xcodprest, xexpediente: String);
// Objetivo...: Guardar Número de Expediente
Begin
  if Buscar(xcodprest) then Begin
    tabla2.Edit;
    tabla2.FieldByName('expediente').AsString := xexpediente;
    try
      tabla2.Post
     except
      tabla2.Cancel
    end;
  end;
end;

procedure TTPrestatario.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  cpost.conectar;
  tcpfiscal.conectar;
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    tperso.FieldByName('codprest').DisplayLabel := 'Cód.'; tperso.FieldByName('nombre').DisplayLabel := 'Nombre del Prestatario'; tperso.FieldByName('direccion').DisplayLabel := 'Dirección';
    tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False;
    if not tabla2.Active then tabla2.Open;
  end;
  Inc(conexiones);
end;

procedure TTPrestatario.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tabla2);
  end;
  cpost.desconectar;
  tcpfiscal.desconectar;
end;

{===============================================================================}

function prestatario: TTPrestatario;
begin
  if xprestatario = nil then
    xprestatario := TTPrestatario.Create;
  Result := xprestatario;
end;

{===============================================================================}

initialization

finalization
  xprestatario.Free;

end.
