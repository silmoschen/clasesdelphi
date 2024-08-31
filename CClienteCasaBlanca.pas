unit CClienteCasaBlanca;

interface

uses CBDT, CPersona, SysUtils, DB, DBTables, CUtiles, CIDBFM, CListar;

type

TTClientes = class(TTPersona)
  Nrodoc, Telefono, Email: string;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodigo, xnombre, xdomicilio, xnrodoc, xtelefono, xemail: string);
  function    Borrar(xcodigo: string): string;
  function    Buscar(xcodigo: string): boolean;
  procedure   getDatos(xcodigo: string);

  procedure   BuscarPorCodigo(xcodigo: String);
  procedure   BuscarPorNombre(xnombre: String);
  procedure   BuscarPorDireccion(xdireccion: String);
  procedure   BuscarPorDocumento(xnrodoc: String);
  procedure   BuscarPorTelefono(xnrotel: String);

  procedure  Listar(orden, iniciar, finalizar, ent_excl: string; xsalida: char);

  procedure   desconectar;
  procedure   conectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure List_linea(salida: char);
end;

function cliente: TTClientes;

implementation

var
  xcliente: TTClientes = nil;

constructor TTClientes.Create;
begin
  tperso := datosdb.openDB('clientes', 'Codcli');
end;

destructor TTClientes.Destroy;
begin
  inherited Destroy;
end;

procedure TTClientes.Grabar(xcodigo, xnombre, xdomicilio, xnrodoc, xtelefono, xemail: string);
// Objetivo...: Grabar Atributos de Vendedores
begin
  inherited Grabar(xcodigo, xnombre, xdomicilio, '', '');
  tperso.Edit;
  tperso.FieldByName('nrodoc').AsString   := xnrodoc;
  tperso.FieldByName('telefono').AsString := xtelefono;
  tperso.FieldByName('email').AsString    := xemail;
  try
    tperso.Post;
  except
    tperso.Cancel;
  end;
end;

procedure  TTClientes.getDatos(xcodigo: string);
// Objetivo...: Obtener/Inicializar los Atributos
begin
  if Buscar(xcodigo) then begin
    nrodoc   := tperso.FieldByName('nrodoc').AsString;
    telefono := tperso.FieldByName('telefono').AsString;
    email    := tperso.FieldByName('email').AsString;
  end else begin
    nrodoc := ''; telefono := ''; email := '';
  end;
  inherited getDatos(xcodigo);
end;

function TTClientes.Borrar(xcodigo: string): string;
// Objetivo...: Eliminar un Instancia de Vendedor
begin
  inherited Borrar(xcodigo);
  getDatos(tperso.FieldByName('codcli').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
end;

function TTClientes.Buscar(xcodigo: string): boolean;
// Objetivo...: Verificar si Existe el Cliente
begin
  if tperso.IndexFieldNames <> 'codcli' then tperso.IndexFieldNames := 'codcli';
  Result := inherited Buscar(xcodigo);  // Método de la Superclase (Sincroniza los Valores de las Tablas)
end;

procedure TTClientes.BuscarPorCodigo(xcodigo: String);
// Objetivo...: Buscar por codigo
Begin
  if tperso.IndexFieldNames <> 'Codcli' then tperso.IndexFieldNames := 'Codcli';
  tperso.FindNearest([xcodigo]);
end;

procedure TTClientes.BuscarPorNombre(xnombre: String);
// Objetivo...: Buscar por nombre
Begin
  if tperso.IndexFieldNames <> 'Nombre' then tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xnombre]);
end;

procedure TTClientes.BuscarPorDireccion(xdireccion: String);
// Objetivo...: Buscar por codigo
Begin
  if tperso.IndexFieldNames <> 'Direccion' then tperso.IndexFieldNames := 'Direccion';
  tperso.FindNearest([xdireccion]);
end;

procedure TTClientes.BuscarPorDocumento(xnrodoc: String);
// Objetivo...: Buscar por codigo
Begin
  if tperso.IndexFieldNames <> 'Nrodoc' then tperso.IndexFieldNames := 'Nrodoc';
  tperso.FindNearest([xnrodoc]);
end;

procedure TTClientes.BuscarPorTelefono(xnrotel: String);
// Objetivo...: Buscar por codigo
Begin
  if tperso.IndexFieldNames <> 'Telefono' then tperso.IndexFieldNames := 'Telefono';
  tperso.FindNearest([xnrotel]);
end;

procedure TTClientes.Listar(orden, iniciar, finalizar, ent_excl: string; xsalida: char);
// Objetivo...: Listar Datos de Provincias
var
  salida: Char;
begin
  salida := xsalida;

  if orden = 'A' then tperso.IndexFieldNames := 'Nombre';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Clientes', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.  Razón Social', 1, 'Arial, cursiva, 8');
  List.Titulo(35, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(60, List.lineactual, 'Nro. Doc.', 3, 'Arial, cursiva, 8');
  List.Titulo(70, List.lineactual, 'Teléfono', 4, 'Arial, cursiva, 8');
  List.Titulo(85, List.lineactual, 'Email', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('codcli').AsString >= iniciar) and (tperso.FieldByName('codcli').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('codcli').AsString < iniciar) or (tperso.FieldByName('codcli').AsString > finalizar) then List_linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.Fields[1].AsString >= iniciar) and (tperso.Fields[1].AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.Fields[1].AsString < iniciar) or (tperso.Fields[1].AsString > finalizar) then List_linea(salida);

      tperso.Next;
    end;

    List.FinList;

    tperso.IndexFieldNames := 'Codcli';
    tperso.First;
end;

procedure TTClientes.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  List.Linea(0, 0, tperso.FieldByName('codcli').AsString + '  ' + tperso.Fields[1].AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(35, List.lineactual, tperso.Fields[2].AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(60, List.lineactual, tperso.FieldByName('nrodoc').AsString, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(70, List.lineactual, tperso.FieldByName('telefono').AsString, 4, 'Arial, normal, 8', salida, 'N');
  List.Linea(85, List.lineactual, tperso.FieldByName('email').AsString, 5, 'Arial, normal, 8', salida, 'S');
end;

procedure TTClientes.conectar;
// Objetivo...: Abrir las tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    tperso.FieldByName('codcli').DisplayLabel := 'Cód.'; tperso.FieldByName('nombre').DisplayLabel := 'Nombre del Cliente'; tperso.FieldByName('nrodoc').DisplayLabel := 'Nro. Doc.'; tperso.FieldByName('direccion').DisplayLabel := 'Dirección';
    tperso.FieldByName('telefono').DisplayLabel := 'Teléfono'; tperso.FieldByName('email').DisplayLabel := 'Email';
    tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False;
  end;
  Inc(conexiones);
end;

procedure TTClientes.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
  end;
end;

{===============================================================================}

function cliente: TTClientes;
begin
  if xcliente = nil then
    xcliente := TTClientes.Create;
  Result := xcliente;
end;

{===============================================================================}

initialization

finalization
  xcliente.Free;

end.