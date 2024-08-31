unit CSocio;

interface

uses CPersona, COperacion, CCodpost, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM;

type

TTSocio = class(TTPersona) // Clase TSocio Heredada de Persona
  nrodoc, catsocio, telefono: string;
  tabla2 : TTable;         // Tablas para la Persistencia de Objetos
 public
  { Declaraciones Públicas }
  constructor Create(xcodigo, xnombre, xdomicilio, xcp, xorden, xnrodoc, xcatsocio, xtelefono: string);
  destructor  Destroy; override;

  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xnrodoc, xcatsocio, xtelefono: string);
  procedure   Borrar(cod: string);
  function    Buscar(cod: string): boolean;

  procedure   getDatos(cod: string);

  function    getNrodoc: string;
  function    getCatsocio: string;
  function    getOperacion(xcodoper: string): string;
  function    setSocios: TQuery; virtual;

  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
 private
  { Declaraciones Privadas }
 protected
  { Declaraciones Protegidas }
  procedure   list_Tit(salida: char);
  procedure   List_linea(salida: char);
end;

function socio: TTSocio;

implementation

var
  xsocio: TTSocio = nil;

constructor TTSocio.Create(xcodigo, xnombre, xdomicilio, xcp, xorden, xnrodoc, xcatsocio, xtelefono: string);
// Vendedor - Heredada de Persona
begin
  inherited Create(xcodigo, xnombre, xdomicilio, xcp, xorden);
  nrodoc   := xnrodoc;
  catsocio := xcatsocio;
  telefono := xtelefono;
end;

destructor TTSocio.Destroy;
begin
  inherited Destroy;
end;

function TTSocio.getNrodoc: string;
begin
  Result := nrodoc;
end;

function TTSocio.getCatsocio: string;
begin
  Result := catsocio;
end;

function TTSocio.getOperacion(xcodoper: string): string;
// Objetivo...: retornar el código de operacion especificado
begin
  operacion.getDatos(xcodoper);
  Result := operacion.getDescrip;
end;

procedure TTSocio.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xnrodoc, xcatsocio, xtelefono: string);
// Objetivo...: Grabar Atributos de Vendedores
begin
  if Buscar(xcodigo) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('codsocio').AsString := xcodigo;
  tabla2.FieldByName('nrodoc').AsString   := xnrodoc;
  tabla2.FieldByName('socio').AsString    := xcatsocio;
  tabla2.FieldByName('telefono').AsString := xtelefono;
  tabla2.Post;
  // Actualizamos los Atributos de la Clase Persona
  inherited Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden);  //* Metodo de la Superclase
end;

procedure  TTSocio.getDatos(cod: string);
// Objetivo...: Obtener/Inicializar los Atributos para un objeto Vendedor
begin
  inherited getDatos(cod);  // Heredamos de la Superclase
  if Buscar(cod) then begin
    nrodoc   := tabla2.FieldByName('nrodoc').AsString;
    catsocio := tabla2.FieldByName('socio').AsString;
    telefono := tabla2.FieldByName('telefono').AsString;
  end else begin
    nrodoc := ''; catsocio := ''; telefono := '';
  end;
end;

procedure TTSocio.Borrar(cod: string);
// Objetivo...: Eliminar un Instancia de Vendedor
begin
  if Buscar(cod) then  begin
    inherited Borrar(cod);  // Metodo de la Superclase Persona
    tabla2.Delete;
  end;
end;

function TTSocio.Buscar(cod: string): boolean;
// Objetivo...: Verificar si Existe el Vendedor
begin
 if tabla2.FindKey([cod]) then Result := True else Result := False;
 inherited Buscar(cod);  // Método de la Superclase (Sincroniza los Valores de las Tablas)
end;

function TTSocio.setSocios: TQuery;
// Objetivo...: retornar un set de registros con los datos de los socios
begin
  Result := datosdb.tranSQL('SELECT codsocio, nombre FROM ' + tperso.TableName + '  ORDER BY nombre');
end;

procedure TTSocio.List_Tit(salida: char);
// Objetivo...: Listar una Línea
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Socios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.  Razón Social', 1, 'Arial, cursiva, 8');
  List.Titulo(38, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(63, List.lineactual, 'CP  Orden   Localidad', 3, 'Arial, cursiva, 8');
  List.Titulo(87, List.lineactual, 'Nro.Doc.', 4, 'Arial, cursiva, 8');
  List.Titulo(96, List.lineactual, 'T.Oper.', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTSocio.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  if cpost.Buscar(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString) then cpost.getDatos(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString);
  tabla2.FindKey([tperso.FieldByName('codsocio').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('codsocio').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(38, List.lineactual, tperso.FieldByName('domicilio').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(63, List.lineactual, tperso.FieldByName('cp').AsString + ' ' + tperso.FieldByName('orden').AsString + '  ' + cpost.Localidad, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(87, List.lineactual, tabla2.FieldByName('nrodoc').AsString, 4, 'Arial, normal, 8', salida, 'N');
  List.Linea(96, List.lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
end;

procedure TTSocio.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;
  list_Tit(salida);

  tperso.First;
  while not tperso.EOF do begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tperso.FieldByName('codsocio').AsString >= iniciar) and (tperso.FieldByName('codsocio').AsString <= finalizar) then List_linea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tperso.FieldByName('codsocio').AsString < iniciar) or (tperso.FieldByName('codsocio').AsString > finalizar) then List_linea(salida);
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

function socio: TTSocio;
begin
  if xsocio = nil then
    xsocio := TTSocio.Create('', '', '', '', '', '', '', '');
  Result := xsocio;
end;

{===============================================================================}

initialization

finalization
  xsocio.Free;

end.
