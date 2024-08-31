unit CPadresFoot;

interface

uses CPersona, CBDT, SysUtils, DB, DBTables, CUtiles, CIDBFM, CListar;

type

TTPadres = class(TTPersona)          // Clase TVendedor Heredada de Persona
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodigo, xnombre, xdomicilio: String);
  function    Borrar(xcodigo: string): String;
  function    Buscar(xcodigo: string): Boolean;
  function    BuscarPorCodigo(xexpr: string): Boolean;
  function    BuscarPorNombre(xexpr: string): Boolean;
  procedure   getDatos(xcodigo: string);

  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);

  procedure   desconectar;
  procedure   conectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure List_linea(salida: char);
end;

function padre: TTPadres;

implementation

var
  xpadre: TTPadres = nil;

constructor TTPadres.Create;
// Vendedor - Heredada de Persona
begin
  inherited Create('', '', '', '', '');
  tperso := datosdb.openDB('padres', '');
end;

destructor TTPadres.Destroy;
begin
  inherited Destroy;
end;

procedure TTPadres.Grabar(xcodigo, xnombre, xdomicilio: String);
// Objetivo...: Grabar Atributos de Vendedores
begin
  if tperso.IndexFieldNames <> 'Id' then tperso.IndexFieldNames := 'Id';
  inherited Grabar(xcodigo, xnombre, xdomicilio, '', '');
end;

procedure  TTPadres.getDatos(xcodigo: string);
// Objetivo...: Obtener/Inicializar los Atributos para un objeto Vendedor
begin
  if tperso.IndexFieldNames <> 'Id' then tperso.IndexFieldNames := 'Id';
  inherited getDatos(xcodigo);  // Heredamos de la Superclase
end;

function TTPadres.Borrar(xcodigo: string): string;
// Objetivo...: Eliminar un Instancia de Vendedor
begin
  if tperso.IndexFieldNames <> 'Id' then tperso.IndexFieldNames := 'Id';
  inherited Borrar(xcodigo);  // Metodo de la Superclase Persona
end;

function TTPadres.Buscar(xcodigo: string): boolean;
// Objetivo...: Verificar si Existe el Cliente
begin
  if tperso.IndexFieldNames <> 'Id' then tperso.IndexFieldNames := 'Id';
  inherited Buscar(xcodigo);  // Método de la Superclase (Sincroniza los Valores de las Tablas)
end;

function TTPadres.BuscarPorCodigo(xexpr: string): boolean;
// Objetivo...: Buscar un cliente por codigo
begin
  if tperso.IndexFieldNames <> 'Id' then tperso.IndexFieldNames := 'Id';
  tperso.FindNearest([xexpr]);
end;

function TTPadres.BuscarPorNombre(xexpr: string): boolean;
// Objetivo...: Buscar un cliente por nombre
begin
  if tperso.IndexFieldNames <> 'Nombre' then tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

procedure TTPadres.conectar;
// Objetivo...: Abrir las tablas de persistencia
begin
  if conexiones = 0 then
    if not tperso.Active then tperso.Open;
  tperso.FieldByName('Id').DisplayLabel := 'Cód.'; tperso.FieldByName('Nombre').DisplayLabel := 'Nombre';
  tperso.FieldByName('direccion').DisplayLabel := 'Dirección';
  Inc(conexiones);
end;

procedure TTPadres.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  List.Linea(0, 0, tperso.FieldByName('id').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(40, List.lineactual, tperso.FieldByName('direccion').AsString, 2, 'Arial, normal, 8', salida, 'S');
end;

procedure TTPadres.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Padres', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.      Nombre del Padre', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('id').AsString >= iniciar) and (tperso.FieldByName('id').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('id').AsString < iniciar) or (tperso.FieldByName('id').AsString > finalizar) then List_linea(salida);
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

procedure TTPadres.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tperso);
end;

{===============================================================================}

function padre: TTPadres;
begin
  if xpadre = nil then
    xpadre := TTPadres.Create;
  Result := xpadre;
end;

{===============================================================================}

initialization

finalization
  xpadre.Free;

end.