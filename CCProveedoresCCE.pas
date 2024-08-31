unit CCProveedoresCCE;

interface

uses CPersona, CBDT, SysUtils, DB, DBTables, CUtiles, CIDBFM, Classes, CListar, CCodPost,
     CTPFiscal;

type

TTProveedor = class(TTPersona)
  Codpfis, Nrocuit, Telefono, Email: string;
  tabla2: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xcodigo: string): Boolean;
  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xcodpfis, xnrocuit, xtelefono, xemail: string);
  procedure   Borrar(xcodigo: string);
  procedure   getDatos(xcodigo: string);

  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; xsalida: char);
  function    setClientesAlf: TQuery;
  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);

  procedure   desconectar;
  procedure   conectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  Existe: Boolean;
end;

function proveedor: TTProveedor;

implementation

var
  xproveedor: TTProveedor = nil;

constructor TTProveedor.Create;
begin
  inherited Create('', '', '', '', '');
  tperso        := datosdb.openDB('proveedores', '');
  tabla2        := datosdb.openDB('proveedoresh', '');
end;

destructor TTProveedor.Destroy;
begin
  inherited Destroy;
end;

procedure TTProveedor.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xcodpfis, xnrocuit, xtelefono, xemail: string);
begin
  inherited Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden);
  if tabla2.FindKey([xcodigo]) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('codprov').AsString      := xcodigo;
  tabla2.FieldByName('codpfis').AsString     := xcodpfis;
  tabla2.FieldByName('nrocuit').AsString     := xnrocuit;
  tabla2.FieldByName('telefono').AsString    := xtelefono;
  tabla2.FieldByName('email').AsString       := xemail;
  try
    tabla2.Post
   except
    tabla2.Cancel
  end;
  datosdb.refrescar(tabla2);
end;

procedure TTProveedor.getDatos(xcodigo: string);
begin
  if Buscar(xcodigo) then Begin
    codpfis     := tabla2.FieldByName('codpfis').AsString;
    nrocuit     := tabla2.FieldByName('nrocuit').AsString;
    telefono    := tabla2.FieldByName('telefono').AsString;
    email       := tabla2.FieldByName('email').AsString;
  end else Begin
    codpfis := ''; nrocuit := ''; telefono := ''; email := '';
  end;
  inherited getDatos(xcodigo);
end;

procedure TTProveedor.Borrar(xcodigo: string);
// Objetivo...: Eliminar un Instancia de Vendedor
begin
  try
    if Buscar(xcodigo) then
      begin
        inherited Borrar(xcodigo);  // Metodo de la Superclase Persona
        tabla2.Delete;
        getDatos(tabla2.FieldByName('codprov').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
      end;
  except
  end;
end;

function TTProveedor.Buscar(xcodigo: string): Boolean;
// Objetivo...: Verificar si Existe el Vendedor
begin
  if not (tperso.Active) or not (tabla2.Active) then conectar;
  if tperso.IndexFieldNames <> 'codprov' then tperso.IndexFieldNames := 'codprov';
  inherited Buscar(xcodigo);  // Método de la Superclase (Sincroniza los Valores de las Tablas)
  Result := tabla2.FindKey([xcodigo]);
end;

procedure TTProveedor.Listar(orden, iniciar, finalizar, ent_excl: string; xsalida: char);
// Objetivo...: Listar Datos de Provincias
  procedure List_linea(salida: char);
  // Objetivo...: Listar una Línea
  begin
    if cpost.Buscar(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString) then cpost.getDatos(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString);
    tabla2.FindKey([tperso.FieldByName('codprov').AsString]);   // Sincronizamos las tablas
    List.Linea(0, 0, tperso.FieldByName('codprov').AsString + '  ' + tperso.Fields[1].AsString, 1, 'Arial, normal, 8', salida, 'N');
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

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Proveedores', 1, 'Arial, negrita, 14');
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
        if (tperso.FieldByName('codprov').AsString >= iniciar) and (tperso.FieldByName('codprov').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('codprov').AsString < iniciar) or (tperso.FieldByName('codprov').AsString > finalizar) then List_linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.Fields[1].AsString >= iniciar) and (tperso.Fields[1].AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.Fields[1].AsString < iniciar) or (tperso.Fields[1].AsString > finalizar) then List_linea(salida);

      tperso.Next;
    end;

    List.FinList;

    tperso.IndexFieldNames := 'codprov';
    tperso.First;
end;

function TTProveedor.setClientesAlf: TQuery;
// Objetivo...: Devolver un set de registros con los clientes ordenados alfabeticamente
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tperso.TableName + ' ORDER BY nombre');
end;

procedure TTProveedor.BuscarPorCodigo(xexpr: string);
// Objetivo...: buscar cliente por código
begin
  if tperso.IndexFieldNames <> 'codprov' then tperso.IndexFieldNames := 'codprov';
  tperso.FindNearest([xexpr]);
end;

procedure TTProveedor.BuscarPorNombre(xexpr: string);
// Objetivo...: buscar por nombre
begin
  if tperso.IndexFieldNames <> 'Nombre' then tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

procedure TTProveedor.conectar;
// Objetivo...: Abrir las tablas de persistencia
begin
  tcpfiscal.conectar;
  cpost.conectar;
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    if not tabla2.Active then tabla2.Open;
  end;
  Inc(conexiones);

  tperso.FieldByName('codprov').DisplayLabel := 'Código'; tperso.FieldByName('nombre').DisplayLabel := 'Nombre o Razón Social';
  tperso.FieldByName('domicilio').DisplayLabel := 'Dirección'; tperso.FieldByName('cp').DisplayLabel := 'Cód.Post.';
  tperso.FieldByName('orden').DisplayLabel := 'Orden';
end;

procedure TTProveedor.desconectar;
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

function proveedor: TTProveedor;
begin
  if xproveedor = nil then
    xproveedor := TTProveedor.Create;
  Result := xproveedor;
end;

{===============================================================================}

initialization

finalization
  xproveedor.Free;

end.