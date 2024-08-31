unit CClienteCCE;

interface

uses CPersona, CBDT, SysUtils, DB, DBTables, CUtiles, CIDBFM, Classes, CListar, CCodPost,
     CTPFiscal, CCuotasSocietariasCCE, CServers2000_Excel;

type

TTCliente = class(TTPersona)
  Codpfis, Nrocuit, Nroplanta, Socio, Telefono, Email, Idcategoria, Categ: string;
  Monto: Real;
  tabla2: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xcodigo: string): Boolean;
  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xcodpfis, xnrocuit, xnroplanta, xsocio, xtelefono, xemail, xidcategoria: string);
  procedure   Borrar(xcodigo: string);
  procedure   getDatos(xcodigo: string);

  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; xsalida: char);
  function    setClientesAlf: TQuery;
  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);

  function    BuscarCUIT(xnrocuit: String): Boolean;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones, c1: shortint;
  l1: String;
end;

function cliente: TTCliente;

implementation

var
  xcliente: TTCliente = nil;

constructor TTCliente.Create;
begin
  inherited Create('', '', '', '', '');
  tperso        := datosdb.openDB('clientes', '');
  tabla2        := datosdb.openDB('clienteh', '');
end;

destructor TTCliente.Destroy;
begin
  inherited Destroy;
end;

procedure TTCliente.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xcodpfis, xnrocuit, xnroplanta, xsocio, xtelefono, xemail, xidcategoria: string);
begin
  inherited Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden);
  if tabla2.FindKey([xcodigo]) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('codcli').AsString      := xcodigo;
  tabla2.FieldByName('codpfis').AsString     := xcodpfis;
  tabla2.FieldByName('nrocuit').AsString     := xnrocuit;
  tabla2.FieldByName('nroplanta').AsString   := xnroplanta;
  tabla2.FieldByName('socio').AsString       := xsocio;
  tabla2.FieldByName('telefono').AsString    := xtelefono;
  tabla2.FieldByName('email').AsString       := xemail;
  tabla2.FieldByName('idcategoria').AsString := xidcategoria;
  try
    tabla2.Post
   except
    tabla2.Cancel
  end;
  datosdb.refrescar(tabla2);
end;

procedure TTCliente.getDatos(xcodigo: string);
begin
  if Buscar(xcodigo) then Begin
    codpfis     := tabla2.FieldByName('codpfis').AsString;
    nrocuit     := tabla2.FieldByName('nrocuit').AsString;
    nroplanta   := tabla2.FieldByName('nroplanta').AsString;
    socio       := tabla2.FieldByName('socio').AsString;
    telefono    := tabla2.FieldByName('telefono').AsString;
    email       := tabla2.FieldByName('email').AsString;
    idcategoria := tabla2.FieldByName('idcategoria').AsString;
  end else Begin
    codpfis := ''; nrocuit := ''; nroplanta := ''; socio := ''; telefono := ''; email := ''; idcategoria := '';
  end;
  categoria.getDatos(idcategoria);
  categ := categoria.categoria;
  monto := categoria.Monto;
  inherited getDatos(xcodigo);
end;

procedure TTCliente.Borrar(xcodigo: string);
// Objetivo...: Eliminar un Instancia de Vendedor
begin
  try
    if Buscar(xcodigo) then
      begin
        inherited Borrar(xcodigo);  // Metodo de la Superclase Persona
        tabla2.Delete;
        getDatos(tabla2.FieldByName('codcli').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
      end;
  except
  end;
end;

function TTCliente.Buscar(xcodigo: string): Boolean;
// Objetivo...: Verificar si Existe el Vendedor
begin
  if not (tperso.Active) or not (tabla2.Active) then conectar;
  if tperso.IndexFieldNames <> 'Codcli' then tperso.IndexFieldNames := 'Codcli';
  inherited Buscar(xcodigo);  // Método de la Superclase (Sincroniza los Valores de las Tablas)
  Result := tabla2.FindKey([xcodigo]);
end;

procedure TTCliente.Listar(orden, iniciar, finalizar, ent_excl: string; xsalida: char);
// Objetivo...: Listar Datos de Provincias
  procedure List_linea(salida: char);
  // Objetivo...: Listar una Línea
  begin
    if cpost.Buscar(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString) then cpost.getDatos(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString);
    tabla2.FindKey([tperso.FieldByName('codcli').AsString]);   // Sincronizamos las tablas
    if (salida = 'P') or (salida = 'I') then Begin
      List.Linea(0, 0, tperso.FieldByName('codcli').AsString + '  ' + tperso.Fields[1].AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(37, List.lineactual, tperso.Fields[2].AsString, 2, 'Arial, normal, 8', salida, 'N');
      List.Linea(60, List.lineactual, tabla2.FieldByName('nrocuit').AsString, 3, 'Arial, normal, 8', salida, 'N');
      List.Linea(72, List.lineactual, tperso.FieldByName('cp').AsString + ' ' + tperso.FieldByName('orden').AsString + '  ' + cpost.Localidad, 4, 'Arial, normal, 8', salida, 'N');
      List.Linea(97, List.lineactual, tabla2.FieldByName('codpfis').AsString, 5, 'Arial, normal, 8', salida, 'S');
    End;
    if (salida = 'X') then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, tperso.FieldByName('codcli').AsString, 'Arial, normal, 8');
      excel.setString('b' + l1, 'b' + l1, tperso.Fields[1].AsString, 'Arial, normal, 8');
      excel.setString('c' + l1, 'c' + l1, tperso.Fields[2].AsString, 'Arial, normal, 8');
      excel.setString('d' + l1, 'd' + l1, tabla2.FieldByName('nrocuit').AsString, 'Arial, normal, 8');
      excel.setString('e' + l1, 'e' + l1, cpost.localidad, 'Arial, normal, 8');
      excel.setString('f' + l1, 'f' + l1, tabla2.FieldByName('codpfis').AsString, 'Arial, normal, 8');
      excel.setString('g' + l1, 'g' + l1, tabla2.FieldByName('telefono').AsString, 'Arial, normal, 8');
      excel.setString('h' + l1, 'h' + l1, tabla2.FieldByName('email').AsString, 'Arial, normal, 8');
      excel.setString('i' + l1, 'i' + l1, tabla2.FieldByName('nroplanta').AsString, 'Arial, normal, 8');
      excel.setString('j' + l1, 'j' + l1, tabla2.FieldByName('idcategoria').AsString, 'Arial, normal, 8');
    End;

  end;

var
  salida: Char;
begin
  salida := xsalida;
  if salida = 'I' then
    if list.ImpresionModoTexto then salida := 'T';

  if orden = 'A' then tperso.IndexFieldNames := 'Nombre';

  if (salida = 'P') or (salida = 'I') then Begin
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Listado de Clientes', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Cód.  Razón Social', 1, 'Arial, cursiva, 8');
    List.Titulo(37, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
    List.Titulo(61, List.lineactual, 'Nº C.U.I.T.', 3, 'Arial, cursiva, 8');
    List.Titulo(72, List.lineactual, 'CP  Orden   Localidad', 4, 'Arial, cursiva, 8');
    List.Titulo(96, List.lineactual, 'I.V.A.', 5, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
  if (salida = 'X') then Begin
    c1 := 0;
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Listado de Clientes', 'Arial, negrita, 14');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Cód.', 'Arial, normal, 8');
    excel.setString('b' + l1, 'b' + l1, 'Razón Social', 'Arial, normal, 8');
    excel.setString('c' + l1, 'c' + l1, 'Domicilio', 'Arial, normal, 8');
    excel.setString('d' + l1, 'd' + l1, 'C.U.I.T.', 'Arial, normal, 8');
    excel.setString('e' + l1, 'e' + l1, 'Localidad', 'Arial, normal, 8');
    excel.setString('f' + l1, 'f' + l1, 'IVA', 'Arial, normal, 8');
    excel.setString('g' + l1, 'g' + l1, 'Teléfono', 'Arial, normal, 8');
    excel.setString('h' + l1, 'h' + l1, 'Email', 'Arial, normal, 8');
    excel.setString('i' + l1, 'i' + l1, 'Nro. Planta', 'Arial, normal, 8');
    excel.setString('j' + l1, 'j' + l1, 'Id.Cat.', 'Arial, normal, 8');
    excel.FijarAnchoColumna('a1', 'a1', 5);
    excel.FijarAnchoColumna('b1', 'b1', 25);
    excel.FijarAnchoColumna('c1', 'c1', 25);
    excel.FijarAnchoColumna('d1', 'd1', 12);
    excel.FijarAnchoColumna('e1', 'e1', 20);
    excel.FijarAnchoColumna('g1', 'g1', 20);
    excel.FijarAnchoColumna('h1', 'h1', 20);
  End;

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

    if (salida = 'P') or (salida = 'I') then List.FinList;
    if (salida = 'X') then Begin
      excel.setString('b1', 'b1', '', 'Arial, normal, 11');
      excel.Visulizar;
    End;

    tperso.IndexFieldNames := 'Codcli';
    tperso.First;
end;

function TTCliente.setClientesAlf: TQuery;
// Objetivo...: Devolver un set de registros con los clientes ordenados alfabeticamente
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tperso.TableName + ' ORDER BY nombre');
end;

procedure TTCliente.BuscarPorCodigo(xexpr: string);
// Objetivo...: buscar cliente por código
begin
  if tperso.IndexFieldNames <> 'Codcli' then tperso.IndexFieldNames := 'Codcli';
  tperso.FindNearest([xexpr]);
end;

procedure TTCliente.BuscarPorNombre(xexpr: string);
// Objetivo...: buscar por nombre
begin
  if tperso.IndexFieldNames <> 'Nombre' then tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

function  TTCliente.BuscarCUIT(xnrocuit: String): Boolean;
// Objetivo...: Buscar Instancia
begin
  tabla2.IndexFieldNames := 'nrocuit';
  Result := tabla2.FindKey([xnrocuit]);
  tabla2.IndexFieldNames := 'codcli';
end;

procedure TTCliente.conectar;
// Objetivo...: Abrir las tablas de persistencia
begin
  tcpfiscal.conectar;
  cpost.conectar;
  categoria.conectar;
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    if not tabla2.Active then tabla2.Open;
  end;
  Inc(conexiones);

  tperso.FieldByName('codcli').DisplayLabel := 'Código'; tperso.FieldByName('nombre').DisplayLabel := 'Nombre o Razón Social';
  tperso.FieldByName('domicilio').DisplayLabel := 'Dirección'; tperso.FieldByName('cp').DisplayLabel := 'Cód.Post.';
  tperso.FieldByName('orden').DisplayLabel := 'Orden';
end;

procedure TTCliente.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tabla2);
  end;
  tcpfiscal.desconectar;
  cpost.desconectar;
  categoria.desconectar;
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