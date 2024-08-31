unit CSociosCIC;

interface

uses CPersona, CBDT, SysUtils, DB, DBTables, CUtiles, CIDBFM, Classes, CListar, CCodPost,
     CTPFiscal;

type

TTSocio = class(TTPersona)
  Codpfis, Nrocuit, Telefono, Email, Rubro: string;
  Monto: Real;
  tabla2: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xcodigo: string): Boolean;
  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xcodpfis, xnrocuit, xtelefono, xemail, xrubro: String);
  procedure   Borrar(xcodigo: string);
  procedure   getDatos(xcodigo: string);

  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; xsalida: char);
  function    setClientesAlf: TQuery;
  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function socio: TTSocio;

implementation

var
  xsocio: TTSocio = nil;

constructor TTSocio.Create;
begin
  inherited Create('', '', '', '', '');
  tperso        := datosdb.openDB('socios', '');
  tabla2        := datosdb.openDB('sociosh', '');
end;

destructor TTSocio.Destroy;
begin
  inherited Destroy;
end;

procedure TTSocio.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xcodpfis, xnrocuit, xtelefono, xemail, xrubro: String);
begin
  inherited Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden);
  if tabla2.FindKey([xcodigo]) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('idsocio').AsString     := xcodigo;
  tabla2.FieldByName('codpfis').AsString     := xcodpfis;
  tabla2.FieldByName('nrocuit').AsString     := xnrocuit;
  tabla2.FieldByName('telefono').AsString    := xtelefono;
  tabla2.FieldByName('email').AsString       := xemail;
  tabla2.FieldByName('rubro').AsString       := xrubro;
  try
    tabla2.Post
   except
    tabla2.Cancel
  end;
  datosdb.refrescar(tabla2);
end;

procedure TTSocio.getDatos(xcodigo: string);
begin
  if Buscar(xcodigo) then Begin
    codpfis     := tabla2.FieldByName('codpfis').AsString;
    nrocuit     := tabla2.FieldByName('nrocuit').AsString;
    telefono    := tabla2.FieldByName('telefono').AsString;
    email       := tabla2.FieldByName('email').AsString;
    rubro       := tabla2.FieldByName('rubro').AsString;
  end else Begin
    codpfis := ''; nrocuit := ''; telefono := ''; email := ''; rubro := '';
  end;
  inherited getDatos(xcodigo);
end;

procedure TTSocio.Borrar(xcodigo: string);
// Objetivo...: Eliminar un Instancia de Vendedor
begin
  try
    if Buscar(xcodigo) then
      begin
        inherited Borrar(xcodigo);  // Metodo de la Superclase Persona
        tabla2.Delete;
        getDatos(tabla2.FieldByName('idsocio').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
      end;
  except
  end;
end;

function TTSocio.Buscar(xcodigo: string): Boolean;
// Objetivo...: Verificar si Existe el Vendedor
begin
  if not (tperso.Active) or not (tabla2.Active) then conectar;
  if tperso.IndexFieldNames <> 'Idsocio' then tperso.IndexFieldNames := 'Idsocio';
  inherited Buscar(xcodigo);  // Método de la Superclase (Sincroniza los Valores de las Tablas)
  Result := tabla2.FindKey([xcodigo]);
end;

procedure TTSocio.Listar(orden, iniciar, finalizar, ent_excl: string; xsalida: char);
// Objetivo...: Listar Datos de Provincias
  procedure List_linea(salida: char);
  // Objetivo...: Listar una Línea
  begin
    if cpost.Buscar(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString) then cpost.getDatos(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString);
    tabla2.FindKey([tperso.FieldByName('idsocio').AsString]);   // Sincronizamos las tablas
    List.Linea(0, 0, tperso.FieldByName('idsocio').AsString + '  ' + tperso.Fields[1].AsString, 1, 'Arial, normal, 8', salida, 'N');
    List.Linea(37, List.lineactual, tperso.Fields[2].AsString, 2, 'Arial, normal, 8', salida, 'N');
    List.Linea(60, List.lineactual, tabla2.FieldByName('nrocuit').AsString, 3, 'Arial, normal, 8', salida, 'N');
    List.Linea(72, List.lineactual, tperso.FieldByName('cp').AsString + ' ' + tperso.FieldByName('orden').AsString + '  ' + cpost.Localidad, 4, 'Arial, normal, 8', salida, 'N');
    List.Linea(97, List.lineactual, tabla2.FieldByName('codpfis').AsString, 5, 'Arial, normal, 8', salida, 'S');
  end;

var
  salida: Char;
begin
  salida := xsalida;
  if salida = 'I' then
    if list.ImpresionModoTexto then salida := 'T';

  if orden = 'A' then tperso.IndexFieldNames := 'Nombre';

  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Socios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.  Razón Social', 1, 'Arial, cursiva, 8');
  List.Titulo(37, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(61, List.lineactual, 'Nº C.U.I.T.', 3, 'Arial, cursiva, 8');
  List.Titulo(72, List.lineactual, 'CP  Orden   Localidad', 4, 'Arial, cursiva, 8');
  List.Titulo(96, List.lineactual, 'I.V.A.', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('idsocio').AsString >= iniciar) and (tperso.FieldByName('idsocio').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('idsocio').AsString < iniciar) or (tperso.FieldByName('idsocio').AsString > finalizar) then List_linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.Fields[1].AsString >= iniciar) and (tperso.Fields[1].AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.Fields[1].AsString < iniciar) or (tperso.Fields[1].AsString > finalizar) then List_linea(salida);

      tperso.Next;
    end;

    List.FinList;

    tperso.IndexFieldNames := 'idsocio';
    tperso.First;
end;

function TTSocio.setClientesAlf: TQuery;
// Objetivo...: Devolver un set de registros con los clientes ordenados alfabeticamente
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tperso.TableName + ' ORDER BY nombre');
end;

procedure TTSocio.BuscarPorCodigo(xexpr: string);
// Objetivo...: buscar cliente por código
begin
  if tperso.IndexFieldNames <> 'idsocio' then tperso.IndexFieldNames := 'idsocio';
  tperso.FindNearest([xexpr]);
end;

procedure TTSocio.BuscarPorNombre(xexpr: string);
// Objetivo...: buscar por nombre
begin
  if tperso.IndexFieldNames <> 'Nombre' then tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

procedure TTSocio.conectar;
// Objetivo...: Abrir las tablas de persistencia
begin
  tcpfiscal.conectar;
  cpost.conectar;
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    if not tabla2.Active then tabla2.Open;
  end;
  Inc(conexiones);

  tperso.FieldByName('idsocio').DisplayLabel := 'Código'; tperso.FieldByName('nombre').DisplayLabel := 'Nombre o Razón Social';
  tperso.FieldByName('domicilio').DisplayLabel := 'Dirección'; tperso.FieldByName('cp').DisplayLabel := 'Cód.Post.';
  tperso.FieldByName('orden').DisplayLabel := 'Orden';
end;

procedure TTSocio.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tabla2);
  end;
  tcpfiscal.desconectar;
  cpost.desconectar;
end;

{===============================================================================}

function socio: TTSocio;
begin
  if xsocio = nil then
    xsocio := TTSocio.Create;
  Result := xsocio;
end;

{===============================================================================}

initialization

finalization
  xsocio.Free;

end.