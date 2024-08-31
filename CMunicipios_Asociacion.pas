unit CMunicipios_Asociacion;

interface

uses CPersona, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTMunicipios = class(TTPersona)
  Telefono, Email, Categoria, Cuit, Codpfis: String; Tarifa, TarifaMunicipios, TarifaComunas: Real;
  tabla2, tarifas: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xcodigo: String): Boolean;
  procedure   Guardar(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono, xemail, xcategoria: string);
  procedure   Borrar(xcodigo: string);
  procedure   getDatos(xcodigo: string);
  function    setmunicipios: TQuery;
  function    setmunicipiosAlf: TQuery;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);

  procedure   FijarTarifas(xmunicipalidad, xcomuna: Real);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   List_linea(salida: char);
end;

function municipio: TTMunicipios;

implementation

var
  xmunicipio: TTMunicipios = nil;

constructor TTMunicipios.Create;
begin
  inherited Create('', '', '', '', ''); // Hereda de Persona
  tperso   := datosdb.openDB('municipios', '');
  tabla2   := datosdb.openDB('municipioh', '');
  tarifas  := datosdb.openDB('tarifas_municipios', '');
  Codpfis  := 'EXE';
end;

destructor TTMunicipios.Destroy;
begin
  inherited Destroy;
end;

function  TTMunicipios.Buscar(xcodigo: string): boolean;
// Objetivo...: Buscar una instancia
begin
  if tperso.IndexFieldNames <> 'Id' then tperso.IndexFieldNames := 'Id';
  if tabla2.FindKey([xcodigo]) then Begin
    inherited Buscar(xcodigo);
    Result := True;
  end else
    Result := False;
end;

procedure TTMunicipios.Guardar(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono, xemail, xcategoria: String);
// Objetivo...: Almacenar una instacia de la clase
begin
  if Buscar(xcodigo) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('Id').AsString   := xcodigo;
  tabla2.FieldByName('telefono').AsString   := xtelefono;
  tabla2.FieldByName('email').AsString      := xemail;
  tabla2.FieldByName('categoria').AsString  := xcategoria;
  try
    tabla2.Post
  except
    tabla2.Cancel
  end;
  inherited Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden);
end;

procedure TTMunicipios.Borrar(xcodigo: string);
// Objetivo...: Eliminar una instancia
begin
  if Buscar(xcodigo) then Begin
    tabla2.Delete;
    inherited Borrar(xcodigo);
    getDatos(tabla2.FieldByName('Id').AsString);
  end;
end;

procedure TTMunicipios.getDatos(xcodigo: string);
// Objetivo...: Cargar/iniciar los atributos para una instancia
begin
  if Buscar(xcodigo) then Begin
    telefono  := tabla2.FieldByName('telefono').AsString;
    email     := tabla2.FieldByName('email').AsString;
    categoria := tabla2.FieldByName('categoria').AsString;
    if categoria = 'M' then Tarifa := TarifaMunicipios else Tarifa := TarifaComunas;
  end else Begin
    telefono := ''; email := ''; categoria := ''; Tarifa := 0;
  end;
  inherited getDatos(xcodigo);
end;

function TTMunicipios.setmunicipios: TQuery;
// Objetivo...: cerrar tablas de persistencia
begin
  Result := datosdb.tranSQL('SELECT * FROM municipios');
end;

function TTMunicipios.setmunicipiosAlf: TQuery;
// Objetivo...: cerrar tablas de persistencia
begin
  Result := datosdb.tranSQL('SELECT * FROM municipios ORDER BY nombre');
end;

procedure TTMunicipios.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  tabla2.FindKey([tperso.FieldByName('Id').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('Id').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(40, List.lineactual, tperso.FieldByName('direccion').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(65, List.lineactual, tabla2.FieldByName('telefono').AsString, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(80, List.lineactual, tabla2.FieldByName('email').AsString, 5, 'Arial, normal, 8', salida, 'S');
end;

procedure TTMunicipios.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listado de la clase
begin
  if orden = 'A' then tperso.IndexFieldNames := 'Nombre';
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de municipios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Código  Municipio/Comuna', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Dirección', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Teléfono', 4, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'Email', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  tperso.First;
  while not tperso.EOF do Begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tperso.FieldByName('Id').AsString >= iniciar) and (tperso.FieldByName('Id').AsString <= finalizar) then List_linea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tperso.FieldByName('Id').AsString < iniciar) or (tperso.FieldByName('Id').AsString > finalizar) then List_linea(salida);
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

procedure TTMunicipios.BuscarPorCodigo(xexpr: string);
// Objetivo...: buscar por código
begin
  tperso.IndexFieldNames := 'Id';
  tperso.FindNearest([xexpr]);
end;

procedure TTMunicipios.BuscarPorNombre(xexpr: string);
// Objetivo...: buscar por nombre
begin
  tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

procedure TTMunicipios.FijarTarifas(xmunicipalidad, xcomuna: Real);
// Objetivo...: Fijar Montos
Begin
  if tarifas.RecordCount = 0 then tarifas.Append else tarifas.Edit;
  tarifas.FieldByName('municipio').AsFloat := xmunicipalidad;
  tarifas.FieldByName('comuna').AsFloat    := xcomuna;
  try
    tarifas.Post
   except
    tarifas.Cancel
  end;
  TarifaMunicipios := xmunicipalidad;
  TarifaComunas    := xcomuna;
end;

procedure TTMunicipios.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    tperso.FieldByName('Id').DisplayLabel := 'Cód.'; tperso.FieldByName('nombre').DisplayLabel := 'Nombre del Municipio ó Comuna'; tperso.FieldByName('direccion').DisplayLabel := 'Dirección';
    tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False;
    if not tabla2.Active then tabla2.Open;

    if not tarifas.Active then tarifas.Open;
    TarifaMunicipios := tarifas.FieldByName('municipio').AsFloat;
    TarifaComunas    := tarifas.FieldByName('comuna').AsFloat;
  end;
  Inc(conexiones);
end;

procedure TTMunicipios.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tabla2);
    datosdb.closeDB(tarifas);
  end;
end;

{===============================================================================}

function municipio: TTMunicipios;
begin
  if xmunicipio = nil then
    xmunicipio := TTMunicipios.Create;
  Result := xmunicipio;
end;

{===============================================================================}

initialization

finalization
  xmunicipio.Free;

end.
