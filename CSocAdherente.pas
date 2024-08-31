unit CSocAdherente;

interface

uses CBDT, CSocio, CCatSoc, COperacion, CCodpost, CLimitesCreditos_Circulo, CLimitesCreditos_Penias,
     SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM;

type

TTSocioAdherente = class(TTSocio)
  categoria, OSFA, descripcategoria, nombrecategoria, sel, actretiro, nrocta, tiposerv, Limite_Credito, Limite_Penia: string;
  MontoLimiteDelCredito, MontoLimitePenia: Real;
  existe: Boolean;
  tabla3: TTable;
  r     : TQuery;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xcodigo: string): boolean;
  function    BuscarOSFA(xosfa: string): boolean;
  function    BuscarNroDoc(xnrodoc: string): Boolean;
  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xnrodoc, xcatsocio, xcategoria, xosfa, xtelefono, xactretiro, xnrocta, xtiposerv, xidlimitecredito, xlimitep: string);
  procedure   Borrar(xcodigo: string);
  procedure   getDatos(xcodigo: string);
  procedure   ListarCat(orden, iniciar, finalizar, ent_excl: string; salida: char);
  function    setSociosSel: TQuery;
  function    setSocNoSocSel: TQuery;
  function    setSocios: TQuery; override;
  function    setSociosAlf: TQuery;
  function    verifCategoria(xcatsocio: string): boolean;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida, tipolist: char);
  procedure   ListarInformeCompacto(orden, iniciar, finalizar, ent_excl: string; salida, tipolist: char);
  function    OSFASiguiente: string;
  function    OSFAAnterior: string;

  procedure   AjustarCategoria(xcodigo, xcategoria: String);
  function    setCategoria(xcodigo: String): String;

  procedure   AjustarPenia(xcodigo, xcategoria: String);
  function    setPenia(xcodigo: String): String;

  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  idanter: string; conexiones: ShortInt;
  procedure   Listlinea(salida: char);
  procedure   VerificarLinea(salida, tl: char);
  procedure   ListLineaC(salida: char);
end;

function socioadherente: TTSocioAdherente;

implementation

var
  xsocioadherente: TTSocioAdherente = nil;

constructor TTSocioAdherente.Create;
// Vendedor - Heredada de Persona
begin
  inherited Create('', '', '', '', '', '', '', '');
  tperso    := datosdb.openDB('socios',  'Codsocio');
  tabla2    := datosdb.openDB('socioh',  'Codsocio');
  tabla3    := datosdb.openDB('socioh1', 'Codsocio');
end;

destructor TTSocioAdherente.Destroy;
begin
  inherited Destroy;
end;

function TTSocioAdherente.Buscar(xcodigo: string): boolean;
// Objetivo...: Buscar una instancia de la clase
begin
  if socioadherente.tperso.IndexFieldNames <> 'Codsocio' then socioadherente.tperso.IndexFieldNames := 'Codsocio';
  Existe := False;
  if Length(Trim(xcodigo)) = 4 then if tabla3.FindKey([xcodigo]) then Existe := True;   // Busqueda por id de socio
  if Length(Trim(xcodigo)) = 6 then Existe := BuscarOSFA(xcodigo);  // Busqueda por OSFA
  inherited Buscar(tabla3.FieldByName('codsocio').AsString);
  Result := existe;
end;

function TTSocioAdherente.BuscarOSFA(xosfa: string): boolean;
// Objetivo...: Buscar una instancia de la clase
var
  osf: string;
begin
  osf := utiles.sLlenarDerecha(xosfa, 6, ' ');
  tabla3.IndexName       := 'OSFA';
  if tabla3.FindKey([osf]) then Result := True else Result := False;
  codigo                 := tabla3.FieldByName('codsocio').AsString;
  tabla3.IndexFieldNames := 'codsocio';
end;

function  TTSocioAdherente.BuscarNroDoc(xnrodoc: string): Boolean;
// Objetivo...: Buscar Por Nro. Documento
Begin
  tabla2.IndexFieldNames := 'Nrodoc';
  if tabla2.FindKey([xnrodoc]) then Result := True else Result := False;
  tabla2.IndexFieldNames := 'Codsocio';
  if Result then getDatos(tabla2.FieldByName('codsocio').AsString);
end;

procedure TTSocioAdherente.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xnrodoc, xcatsocio, xcategoria, xosfa, xtelefono, xactretiro, xnrocta, xtiposerv, xidlimitecredito, xlimitep: string);
// Objetivo...: Grabar instancia de la clase
begin
  inherited Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xnrodoc, xcatsocio, xtelefono);
  if Buscar(xcodigo) then tabla3.Edit else tabla3.Append;
  tabla3.FieldByName('codsocio').AsString  := xcodigo;
  tabla3.FieldByName('categoria').AsString := xcategoria;
  tabla3.FieldByName('OSFA').AsString      := xOSFA;
  tabla3.FieldByName('actretiro').AsString := xactretiro;
  tabla3.FieldByName('nrocta').AsString    := xnrocta;
  tabla3.FieldByName('tiposerv').AsString  := xtiposerv;
  tabla3.FieldByName('catlimite').AsString := xidlimitecredito;
  tabla3.FieldByName('limitep').AsString   := xlimitep;
  try
    tabla3.Post
   except
    tabla3.Cancel
  end;
end;

procedure TTSocioAdherente.Borrar(xcodigo: string);
// Objetivo...: Borrar una instancia
begin
  if Buscar(xcodigo) then begin
    inherited Borrar(xcodigo);
    tabla3.Delete;
    getDatos(tabla3.FieldByName('codsocio').AsString);
  end;
end;

procedure TTSocioAdherente.getDatos(xcodigo: string);
// Objetivo...: Devolver los atributos de una instancia
begin
  if Buscar(xcodigo) then begin
    categoria        := tabla3.FieldByName('categoria').AsString;
    osfa             := tabla3.FieldByName('osfa').AsString;
    catsoc.getDatos(categoria);
    descripcategoria := catsoc.categoria;
    nombrecategoria  := catsoc.descrip;
    actretiro        := tabla3.FieldByName('actretiro').AsString;
    nrocta           := tabla3.FieldByName('nrocta').AsString;
    tiposerv         := tabla3.FieldByName('tiposerv').AsString;
    limite_credito   := tabla3.FieldByName('catlimite').AsString;
    limite_penia     := tabla3.FieldByName('limitep').AsString;
    limitecredito.getDatos(limite_credito);
    MontoLimiteDelCredito := limitecredito.Limite;
    limitepenia.getDatos(limite_penia);
    MontoLimitePenia      := limitepenia.Limite;
  end else begin
    categoria := ''; osfa := ''; descripcategoria := ''; nombrecategoria := ''; actretiro := ''; tiposerv := ''; nrocta := ''; limite_credito := ''; MontoLimiteDelCredito := 0; limite_penia := ''; MontoLimitePenia := 0;
  end;
  inherited getDatos(xcodigo);
end;

procedure TTSocioAdherente.VerificarLinea(salida, tl: char);
// Objetivo...: Verificar si la linea a listar es válida - Filtro Socios/No Socios
begin
  if tl = 'T' then inherited List_linea(salida) else
    if tabla2.FieldByName('socio').AsString = tl then List_linea(salida);
end;

procedure TTSocioAdherente.Listar(orden, iniciar, finalizar, ent_excl: string; salida, tipolist: char);
// Objetivo...: Listar Datos de Provincias
begin
  list.Setear(salida);
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;
  inherited list_Tit(salida);

  tperso.First;
  while not tperso.EOF do begin
    if tipolist <> 'T' then tabla2.FindKey([tperso.FieldByName('codsocio').AsString]); // Si hay Filtro Socio/No Socio
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tperso.FieldByName('codsocio').AsString >= iniciar) and (tperso.FieldByName('codsocio').AsString <= finalizar) then VerificarLinea(salida, tipolist);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tperso.FieldByName('codsocio').AsString < iniciar) or (tperso.FieldByName('codsocio').AsString > finalizar) then VerificarLinea(salida, tipolist);
    // Ordenado Alfabéticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tperso.FieldByName('nombre').AsString >= iniciar) and (tperso.FieldByName('nombre').AsString <= finalizar) then VerificarLinea(salida, tipolist);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tperso.FieldByName('nombre').AsString < iniciar) or (tperso.FieldByName('nombre').AsString > finalizar) then VerificarLinea(salida, tipolist);

    tperso.Next;
  end;
  List.FinList;

  tperso.IndexFieldNames := tperso.IndexFieldNames;
  tperso.First;
end;

function TTSocioAdherente.verifCategoria(xcatsocio: string): boolean;
// Objetivo...: Verificar si existe la categoria como atributo para algun socio
var
  fop: boolean;
begin
  fop := False;
  if not tabla3.Active then begin
    fop := True;
    tabla3.Open;
  end;
  Result := False;
  tabla3.First;
  while not tabla3.EOF do begin
    if tabla3.FieldByName('categoria').AsString = xcatsocio then begin
      Result := True;
      Break;
    end;
    tabla3.Next;
  end;
  if fop then tabla3.Close;
end;

procedure TTSocioAdherente.Listlinea(salida: char);
// Objetivo...: Listar una Línea
begin
  if r.FieldByName('categoria').AsString <> idanter then  begin
    if Length(trim(idanter)) > 0 then List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
    List.Linea(0, 0, r.FieldByName('cats').AsString + '  ' + r.FieldByName('descrip').AsString, 1, 'Arial, negrita, 9', salida, 'S');
    List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
  end;
  if cpost.Buscar(r.FieldByName('cp').AsString, r.FieldByName('orden').AsString) then cpost.getDatos(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString);
  tabla2.FindKey([r.FieldByName('codsocio').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, '     ' + r.FieldByName('OSFA').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(9,  List.lineactual, r.FieldByName('nombre').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(38, List.lineactual, r.FieldByName('domicilio').AsString, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(63, List.lineactual, r.FieldByName('cp').AsString + ' ' + r.FieldByName('orden').AsString + '  ' + cpost.Localidad, 4, 'Arial, normal, 8', salida, 'N');
  List.Linea(87, List.lineactual, tabla2.FieldByName('nrodoc').AsString, 5, 'Arial, normal, 8', salida, 'N');
  List.Linea(96, List.lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
end;

procedure TTSocioAdherente.ListarCat(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar socios adherentes por Categorías
begin
  r := datosdb.tranSQL('SELECT socios.codsocio, socios.nombre, socios.domicilio, socios.cp, socios.orden, socioh.nrodoc, socioh.codoper, socioh.socio, socioh1.categoria, socioh1.OSFA, catsoc.codcat, catsoc.categoria AS cats, catsoc.descrip ' +
                       ' FROM socios, socioh, socioh1, catsoc ' + ' WHERE socios.codsocio = socioh.codsocio AND socios.codsocio = socioh1.codsocio AND socioh1.categoria = catsoc.codcat ' +
                       ' ORDER BY codcat, OSFA');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Socios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, '     OSFA', 1, 'Arial, cursiva, 8');
  List.Titulo(9, list.lineactual, 'Razón Social', 2, 'Arial, cursiva, 8');
  List.Titulo(38, List.lineactual, 'Domicilio', 3, 'Arial, cursiva, 8');
  List.Titulo(63, List.lineactual, 'CP  Orden   Localidad', 4, 'Arial, cursiva, 8');
  List.Titulo(87, List.lineactual, 'Nro.Doc.', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  r.Open; r.First; idanter := '';
  while not r.EOF do begin
    if (ent_excl = 'E') and (orden = 'C') then
      if (r.FieldByName('cats').AsString >= iniciar) and (r.FieldByName('cats').AsString <= finalizar) then listLinea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (r.FieldByName('cats').AsString < iniciar) or (r.FieldByName('cats').AsString > finalizar) then listLinea(salida);
    idanter := r.FieldByName('categoria').AsString;
    r.Next;
  end;
  r.Close; r.Free;

  List.FinList;
end;

procedure TTSocioAdherente.ListarInformeCompacto(orden, iniciar, finalizar, ent_excl: string; salida, tipolist: char);
// Objetivo...: Listar Datos de Socios en forma compacta
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Socios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'OSFA', 1, 'Arial, cursiva, 8');
  List.Titulo(12, List.lineactual, 'Nombre del Socio', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do Begin
    tabla2.FindKey([tperso.FieldByName('codsocio').AsString]);   // Sincronizamos las tablas
    tabla3.FindKey([tperso.FieldByName('codsocio').AsString]);   // Sincronizamos las tablas
    if tipolist <> 'T' then tabla2.FindKey([tperso.FieldByName('codsocio').AsString]); // Si hay Filtro Socio/No Socio
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla3.FieldByName('osfa').AsString >= iniciar) and (tabla3.FieldByName('osfa').AsString <= finalizar) then ListLineaC(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla3.FieldByName('osfa').AsString < iniciar) or (tabla3.FieldByName('osfa').AsString > finalizar) then ListLineaC(salida);
    // Ordenado Alfabéticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tperso.FieldByName('nombre').AsString >= iniciar) and (tperso.FieldByName('nombre').AsString <= finalizar) then ListLineaC(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tperso.FieldByName('nombre').AsString < iniciar) or (tperso.FieldByName('nombre').AsString > finalizar) then ListLineaC(salida);

    tperso.Next;
  end;
  List.FinList;

  tperso.IndexFieldNames := tperso.IndexFieldNames;
  tperso.First;
end;

procedure TTSocioAdherente.ListLineaC(salida: char);
// Objetivo...: Listar una Línea
begin
  List.Linea(0, 0, tabla3.FieldByName('OSFA').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(12,  List.lineactual, tperso.FieldByName('nombre').AsString, 2, 'Arial, normal, 8', salida, 'S');
end;


function TTSocioAdherente.setSociosSel: TQuery;
// Objetivo...: Retornar un set de registros con los socios seleccionados
begin
  Result := datosdb.tranSQL('SELECT codsocio, nombre, sel FROM socios, socioh1 WHERE socios.codsocio = socioh1.codsocio AND socios.sel = ' + '''' + 'X' + '''');
end;

function TTSocioAdherente.setSocNoSocSel: TQuery;
// Objetivo...: Retornar un set de registros con los socios/no socios seleccionados
begin
  Result := datosdb.tranSQL('SELECT codsocio, nombre, sel FROM socios WHERE socios.sel = ' + '''' + 'X' + '''');
end;

function TTSocioAdherente.setSocios: TQuery;
// Objetivo...: Retornar un set de registros de socios
begin
  Result := datosdb.tranSQL('SELECT socios.codsocio, socios.nombre, socioh1.OSFA, socioh1.categoria FROM socios, socioh1 WHERE socios.codsocio = socioh1.codsocio ORDER BY categoria, OSFA');
end;

function TTSocioAdherente.setSociosAlf: TQuery;
// Objetivo...: Retornar un set de registros de socios ordenados por nombre
begin
  Result := datosdb.tranSQL('SELECT socios.codsocio, socios.nombre FROM socios ORDER BY nombre');
end;

function TTSocioAdherente.OSFASiguiente: string;
// Objetivo...: Devolver el número de OSFA Siguiente
begin
  tabla3.IndexName       := 'Catosfa';
  tabla3.Next;
  if tabla3.EOF then tabla3.Last;
  codigo := tabla3.FieldByName('codsocio').AsString;
  Result := tabla3.FieldByName('OSFA').AsString;
  tabla3.IndexFieldNames := 'codsocio';
end;

function TTSocioAdherente.OSFAAnterior: string;
// Objetivo...: Devolver el número de OSFA Anterior
begin
  tabla3.IndexName       := 'Catosfa';
  tabla3.Prior;
  if tabla3.EOF then tabla3.First;
  codigo := tabla3.FieldByName('codsocio').AsString;
  Result := tabla3.FieldByName('OSFA').AsString;
  tabla3.IndexFieldNames := 'codsocio';
end;

procedure TTSocioAdherente.BuscarPorNombre(xexpr: string);
begin
  if socioadherente.tperso.IndexFieldNames <> 'Nombre' then socioadherente.tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

procedure TTSocioAdherente.BuscarPorCodigo(xexpr: string);
begin
  if socioadherente.tperso.IndexFieldNames <> 'Codsocio' then socioadherente.tperso.IndexFieldNames := 'Codsocio';
  tperso.FindNearest([xexpr]);
end;

function  TTSocioAdherente.setCategoria(xcodigo: String): String;
// Objetivo...: Recuperar Categoría
Begin
  if tabla3.FindKey([xcodigo]) then Result := tabla3.FieldByName('catlimite').AsString else Result := '';
end;

procedure TTSocioAdherente.AjustarCategoria(xcodigo, xcategoria: String);
// Objetivo...: Ajustar Categoria del Socio
Begin
  if Buscar(xcodigo) then Begin
    tabla3.Edit;
    tabla3.FieldByName('catlimite').AsString := xcategoria;
    try
      tabla3.Post
     except
      tabla3.Cancel
    end;
    datosdb.refrescar(tabla3);
  end;
end;

function  TTSocioAdherente.setPenia(xcodigo: String): String;
// Objetivo...: Recuperar Penia
Begin
  if tabla3.FindKey([xcodigo]) then Result := tabla3.FieldByName('limitep').AsString else Result := '';
end;

procedure TTSocioAdherente.AjustarPenia(xcodigo, xcategoria: String);
// Objetivo...: Ajustar Penia del Socio
Begin
  if Buscar(xcodigo) then Begin
    tabla3.Edit;
    tabla3.FieldByName('limitep').AsString := xcategoria;
    try
      tabla3.Post
     except
      tabla3.Cancel
    end;
    datosdb.refrescar(tabla3);
  end;
end;

procedure TTSocioAdherente.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    if not tabla2.Active then tabla2.Open;
    if not tabla3.Active then tabla3.Open;
    tperso.FieldByName('codsocio').DisplayLabel := 'Cód.'; tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False;
    tperso.FieldByName('nombre').DisplayLabel := 'Nombre'; tperso.FieldByName('domicilio').DisplayLabel := 'Dirección';
  end;
  Inc(conexiones);
  cpost.conectar;
  catsoc.conectar;
  limitecredito.conectar;
  limitepenia.conectar;
end;

procedure TTSocioAdherente.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tabla2);
    datosdb.closeDB(tabla3);
  end;
  cpost.desconectar;
  catsoc.desconectar;
  limitecredito.desconectar;
  limitepenia.desconectar;
end;

{===============================================================================}

function socioadherente: TTSocioAdherente;
begin
  if xsocioadherente = nil then
    xsocioadherente := TTSocioAdherente.Create;
  Result := xsocioadherente;
end;

{===============================================================================}

initialization

finalization
  xsocioadherente.Free;

end.
