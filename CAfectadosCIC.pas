unit CAfectadosCIC;

interface

uses CPersona, CBDT, SysUtils, DB, DBTables, CUtiles, CIDBFM, Classes, CListar;

type

TTAfectado = class(TTPersona)
  Telefono, Domlaboral: string;
  tabla2: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xnrodoc: string): Boolean;
  procedure   Grabar(xnrodoc, xnombre, xdomicilio, xcp, xorden, xtelefono, xdomlaboral: String);
  procedure   Borrar(xnrodoc: string);
  procedure   getDatos(xnrodoc: string);

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

function afectado: TTAfectado;

implementation

var
  xafectado: TTAfectado = nil;

constructor TTAfectado.Create;
begin
  inherited Create('', '', '', '', '');
  tperso        := datosdb.openDB('afectado', '');
  tabla2        := datosdb.openDB('afectadoh', '');
end;

destructor TTAfectado.Destroy;
begin
  inherited Destroy;
end;

procedure TTAfectado.Grabar(xnrodoc, xnombre, xdomicilio, xcp, xorden, xtelefono, xdomlaboral: String);
begin
  inherited Grabar(xnrodoc, xnombre, xdomicilio, xcp, xorden);
  if tabla2.FindKey([xnrodoc]) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('nrodoc').AsString      := xnrodoc;
  tabla2.FieldByName('telefono').AsString    := xtelefono;
  tabla2.FieldByName('domlaboral').AsString  := xdomlaboral;
  try
    tabla2.Post
   except
    tabla2.Cancel
  end;
  datosdb.refrescar(tabla2);
end;

procedure TTAfectado.getDatos(xnrodoc: string);
begin
  if Buscar(xnrodoc) then Begin
    domlaboral  := tabla2.FieldByName('domlaboral').AsString;
    telefono    := tabla2.FieldByName('telefono').AsString;
  end else Begin
    telefono := ''; domlaboral := '';
  end;
  inherited getDatos(xnrodoc);
end;

procedure TTAfectado.Borrar(xnrodoc: string);
// Objetivo...: Eliminar un Instancia de Vendedor
begin
  try
    if Buscar(xnrodoc) then
      begin
        inherited Borrar(xnrodoc);  // Metodo de la Superclase Persona
        tabla2.Delete;
        getDatos(tabla2.FieldByName('nrodoc').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
      end;
  except
  end;
end;

function TTAfectado.Buscar(xnrodoc: string): Boolean;
// Objetivo...: Verificar si Existe el Vendedor
begin
  if not (tperso.Active) or not (tabla2.Active) then conectar;
  if tperso.IndexFieldNames <> 'Nrodoc' then tperso.IndexFieldNames := 'Nrodoc';
  inherited Buscar(xnrodoc);  // Método de la Superclase (Sincroniza los Valores de las Tablas)
  Result := tabla2.FindKey([xnrodoc]);
end;

procedure TTAfectado.Listar(orden, iniciar, finalizar, ent_excl: string; xsalida: char);
// Objetivo...: Listar Datos de Provincias
  procedure List_linea(salida: char);
  // Objetivo...: Listar una Línea
  begin
    tabla2.FindKey([tperso.FieldByName('nrodoc').AsString]);   // Sincronizamos las tablas
    List.Linea(0, 0, tperso.FieldByName('nrodoc').AsString + '  ' + tperso.Fields[1].AsString, 1, 'Arial, normal, 8', salida, 'N');
    List.Linea(37, List.lineactual, tperso.Fields[2].AsString, 2, 'Arial, normal, 8', salida, 'N');
    List.Linea(61, List.lineactual, tabla2.FieldByName('telefono').AsString, 3, 'Arial, normal, 8', salida, 'N');
    List.Linea(77, List.lineactual, tabla2.FieldByName('domlaboral').AsString, 4, 'Arial, normal, 8', salida, 'S');
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
  List.Titulo(0, 0, ' Listado de Afectados', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Documento   Nombre', 1, 'Arial, cursiva, 8');
  List.Titulo(37, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(61, List.lineactual, 'Dom. Laboral', 3, 'Arial, cursiva, 8');
  List.Titulo(77, List.lineactual, 'Telefono', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('nrodoc').AsString >= iniciar) and (tperso.FieldByName('nrodoc').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('nrodoc').AsString < iniciar) or (tperso.FieldByName('nrodoc').AsString > finalizar) then List_linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.Fields[1].AsString >= iniciar) and (tperso.Fields[1].AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.Fields[1].AsString < iniciar) or (tperso.Fields[1].AsString > finalizar) then List_linea(salida);

      tperso.Next;
    end;

    List.FinList;

    tperso.IndexFieldNames := 'nrodoc';
    tperso.First;
end;

function TTAfectado.setClientesAlf: TQuery;
// Objetivo...: Devolver un set de registros con los clientes ordenados alfabeticamente
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tperso.TableName + ' ORDER BY nombre');
end;

procedure TTAfectado.BuscarPorCodigo(xexpr: string);
// Objetivo...: buscar cliente por código
begin
  if tperso.IndexFieldNames <> 'nrodoc' then tperso.IndexFieldNames := 'nrodoc';
  tperso.FindNearest([xexpr]);
end;

procedure TTAfectado.BuscarPorNombre(xexpr: string);
// Objetivo...: buscar por nombre
begin
  if tperso.IndexFieldNames <> 'Nombre' then tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

procedure TTAfectado.conectar;
// Objetivo...: Abrir las tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    if not tabla2.Active then tabla2.Open;
  end;
  Inc(conexiones);

  tperso.FieldByName('nrodoc').DisplayLabel := 'Documento'; tperso.FieldByName('nombre').DisplayLabel := 'Nombre o Razón Social';
  tperso.FieldByName('domicilio').DisplayLabel := 'Dirección'; tperso.FieldByName('cp').DisplayLabel := 'Cód.Post.';
  tperso.FieldByName('orden').DisplayLabel := 'Orden';
end;

procedure TTAfectado.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tabla2);
  end;
end;

{===============================================================================}

function afectado: TTAfectado;
begin
  if xafectado = nil then
    xafectado := TTAfectado.Create;
  Result := xafectado;
end;

{===============================================================================}

initialization

finalization
  xafectado.Free;

end.