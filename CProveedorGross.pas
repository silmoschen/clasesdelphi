unit CProveedorGross;

interface

uses CPersona, CTPFiscal, CCodPost, CListar, CUtiles, SysUtils, DB, DBTables, CBDT, CIDBFM;

type

TTProveedor = class(TTPersona)
  telefono, nrocuit, codpfis, email: string;
  tprove: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;
  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono, xnrocuit, xcodpfis, xemail: string);
  function    Borrar(xcodigo: string): string;
  function    Buscar(xcodigo: string): boolean;
  procedure   getDatos(xcodigo: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  function    setProveedoresAlf: TQuery;
  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint; path: string;
  procedure   List_linea(salida: char);
end;

function proveedor: TTProveedor;

implementation

var
  xproveedor: TTProveedor = nil;

constructor TTProveedor.Create;
// Vendedor - Heredada de Persona
begin
  inherited Create('','', '', '', '');
  tperso := datosdb.openDB('provedor', 'codprov');
  tprove := datosdb.openDB('provedoh', 'codprov');
end;

destructor TTProveedor.Destroy;
begin
  inherited Destroy;
end;

procedure TTProveedor.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono, xnrocuit, xcodpfis, xemail: string);
// Objetivo...: Grabar Atributos del Proveedor
begin
  if Buscar(xcodigo) then tprove.Edit else tprove.Append;
  tprove.FieldByName('codprov').AsString := xcodigo;
  if Length(trim(xtelefono)) > 0 then tprove.FieldByName('telefono').AsString := xtelefono;
  if Length(trim(xemail))    > 0 then tprove.FieldByName('email').AsString    := xemail;
  tprove.FieldByName('nrocuit').AsString := xnrocuit;
  tprove.FieldByName('codpfis').AsString := xcodpfis;
  tprove.Post;
  inherited Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden);
end;

procedure  TTProveedor.getDatos(xcodigo: string);
// Objetivo...: Obtener/Inicializar los Atributos para un objeto Proveedor
begin
  if Buscar(xcodigo) then Begin
    telefono := tprove.FieldByName('telefono').AsString;
    nrocuit  := tprove.FieldByName('nrocuit').AsString;
    codpfis  := tprove.FieldByName('codpfis').AsString;
    email    := tprove.FieldByName('email').AsString;
  end else Begin
    telefono := ''; nrocuit := ''; codpfis := ''; email := '';
  end;
  inherited getDatos(xcodigo);
end;

function TTProveedor.Borrar(xcodigo: string): string;
// Objetivo...: Eliminar un Instancia de Proveedor
begin
  if Buscar(xcodigo) then Begin
    inherited Borrar(xcodigo);  // Metodo de la Superclase Persona
    tprove.Delete;
    getDatos(tprove.FieldByName('codprov').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTProveedor.Buscar(xcodigo: string): boolean;
// Objetivo...: Verificar si Existe el Proveedor
begin
  if not (tperso.Active) or not (tprove.Active) then conectar;
  if tperso.IndexFieldNames <> 'Codprov' then tperso.IndexFieldNames := 'Codprov';
  inherited Buscar(xcodigo);
  if tprove.FindKey([xcodigo]) then Result := True else Result := False;
end;

procedure TTProveedor.List_linea(salida: char);
// Objetivo...: Listar una L�nea
begin
  if cpost.Buscar(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString) then cpost.getDatos(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString);
  tprove.FindKey([tperso.FieldByName('codprov').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('codprov').AsString + '  ' + tperso.FieldByName('rsocial').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(37, List.lineactual, tperso.Fields[2].AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(60, List.lineactual, tprove.FieldByName('nrocuit').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(74, List.lineactual, tperso.FieldByName('cp').AsString + ' ' + tperso.FieldByName('orden').AsString + '  ' + cpost.Localidad, 4, 'Arial, normal, 8', salida, 'N');
  List.Linea(100, List.lineactual, tprove.FieldByName('codpfis').AsString, 5, 'Arial, normal, 8', salida, 'S');
end;

procedure TTProveedor.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Proveedores', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'C�d.  Raz�n Social', 1, 'Arial, cursiva, 8');
  List.Titulo(37, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(61, List.lineactual, 'N� C.U.I.T.', 3, 'Arial, cursiva, 8');
  List.Titulo(74, List.lineactual, 'CP  Orden   Localidad', 4, 'Arial, cursiva, 8');
  List.Titulo(100, List.lineactual, 'IVA', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por C�digo
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('codprov').AsString >= iniciar) and (tperso.FieldByName('codprov').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('codprov').AsString < iniciar) or (tperso.FieldByName('codprov').AsString > finalizar) then List_linea(salida);
      // Ordenado Alfab�ticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.FieldByName('rsocial').AsString >= iniciar) and (tperso.FieldByName('rsocial').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.FieldByName('rsocial').AsString < iniciar) or (tperso.FieldByName('rsocial').AsString > finalizar) then List_linea(salida);

      tperso.Next;
    end;
    List.FinList;

    tperso.IndexFieldNames := tperso.IndexFieldNames;
    tperso.First;
end;

function TTProveedor.setProveedoresAlf: TQuery;
// Objetivo...: Devolver un set de proveedores ordenados alfabeticamente
begin
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + tperso.TableName + ' ORDER BY rsocial');
end;

procedure TTProveedor.BuscarPorCodigo(xexpr: string);
begin
  tperso.IndexFieldNames := 'Codprov';
  tperso.FindNearest([xexpr]);
end;

procedure TTProveedor.BuscarPorNombre(xexpr: string);
begin
  tperso.IndexFieldNames := 'Rsocial';
  tperso.FindNearest([xexpr]);
end;

procedure TTProveedor.conectar;
// Objetivo...: conectar tablas de persistencia - soporte multiempresa
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    tperso.FieldByName('codprov').DisplayLabel := 'C�d.'; tperso.FieldByName('rsocial').DisplayLabel := 'Raz�n Social'; tperso.FieldByName('cp').DisplayLabel := 'C.Post.';
    if not tprove.Active then tprove.Open;
  end;
  Inc(conexiones);
end;

procedure TTProveedor.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tprove);
  end;
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
