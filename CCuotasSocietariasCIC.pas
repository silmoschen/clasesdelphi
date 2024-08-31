unit CCuotasSocietariasCIC;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar, Forms,
     CConceptosCajaCCExterior, Contnrs, CAsociarComprobante;

type

TTCategorias = class(TObject)
  Idcategoria, Categoria, Codcaja, Periodo, CodNum: string; Monto: Real;
  tabla, percat: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xidcategoria, xCategoria, xcodcaja, xcodnum: string; xmonto: real);
  procedure   Borrar(xidcategoria: string);
  function    Buscar(xidcategoria: string): boolean;
  procedure   getDatos(xidcategoria: string);
  function    setcategoriaes: TQuery;
  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorcategoria(xexpr: string);
  procedure   BuscarPorId(xexpr: string);

  function    BuscarPeriodo(xidcategoria, xperiodo: String): Boolean;
  procedure   RegistrarPeriodo(xidcategoria, xperiodo: String; xmonto: Real);
  procedure   BorrarPeriodo(xidcategoria, xperiodo: String);
  procedure   getDatosPeriodo(xidcategoria, xperiodo: String);
  function    setMontosCategoria(xidcategoria: String): TObjectList;
  procedure   BuscarUltimoPeriodo(xidcategoria: String);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  procedure   ListLinea(salida: char);
  { Declaraciones Privadas }
end;

function categoria: TTCategorias;

implementation

var
  xcategoria_cuot: TTCategorias = nil;

constructor TTCategorias.Create;
begin
  tabla    := datosdb.openDB('categorias', '');
  percat   := datosdb.openDB('per_cat', '');
end;

destructor TTCategorias.Destroy;
begin
  inherited Destroy;
end;

procedure TTCategorias.Grabar(xidcategoria, xCategoria, xcodcaja, xcodnum: string; xmonto: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidcategoria) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idcategoria').AsString := xidcategoria;
  tabla.FieldByName('categoria').AsString   := xCategoria;
  tabla.FieldByName('codcaja').AsString     := xcodcaja;
  tabla.FieldByName('codnum').AsString      := xcodnum;
  tabla.FieldByName('monto').AsFloat        := xmonto;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
  datosdb.refrescar(tabla);
end;

procedure TTCategorias.Borrar(xidcategoria: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xidcategoria) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('idcategoria').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTCategorias.Buscar(xidcategoria: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then tabla.Open;
  tabla.Refresh;
  if tabla.IndexFieldNames <> 'Idcategoria' then tabla.IndexFieldNames := 'Idcategoria';
  if tabla.FindKey([xidcategoria]) then Result := True else Result := False;
end;

procedure  TTCategorias.getDatos(xidcategoria: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xidcategoria) then Begin
    idcategoria := tabla.FieldByName('idcategoria').AsString;
    Categoria   := tabla.FieldByName('categoria').AsString;
    Codcaja     := tabla.FieldByName('codcaja').AsString;
    CodNum      := tabla.FieldByName('codnum').AsString;
    Monto       := tabla.FieldByName('monto').AsFloat;
  end else Begin
    idcategoria := ''; categoria := ''; codcaja := ''; codnum := ''; monto := 0;
  end;
end;

function TTCategorias.setcategoriaes: TQuery;
// Objetivo...: devolver un set con los categoriaes disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY categoria');
end;

function TTCategorias.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Result := IntToStr(StrToInt(tabla.FieldByName('idcategoria').AsString) + 1);
end;

procedure TTCategorias.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Categorías', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.  Categoría', 1, 'Courier New, cursiva, 9');
  List.Titulo(64, 0, 'Monto', 2, 'Courier New, cursiva, 9');
  List.Titulo(71, 0, 'Movimiento de Caja', 3, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('idcategoria').AsString >= iniciar) and (tabla.FieldByName('idcategoria').AsString <= finalizar) then ListLinea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('idcategoria').AsString < iniciar) or (tabla.FieldByName('idcategoria').AsString > finalizar) then ListLinea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('categoria').AsString >= iniciar) and (tabla.FieldByName('categoria').AsString <= finalizar) then ListLinea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('categoria').AsString < iniciar) or (tabla.FieldByName('categoria').AsString > finalizar) then ListLinea(salida);

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTCategorias.ListLinea(salida: char);
begin
  conccaja.getDatos(tabla.FieldByName('codcaja').AsString);
  List.Linea(0, 0, tabla.FieldByName('idcategoria').AsString + '   ' + tabla.FieldByName('categoria').AsString, 1, 'Courier New, normal, 9', salida, 'N');
  List.importe(70, List.lineactual, '', tabla.FieldByName('monto').AsFloat, 2, 'Courier New, normal, 9');
  List.Linea(71, list.lineactual, conccaja.concepto, 3, 'Courier New, normal, 9', salida, 'S');
end;

procedure TTCategorias.BuscarPorcategoria(xexpr: string);
begin
  tabla.IndexFieldNames := 'Categoria';
  tabla.FindNearest([xexpr]);
end;

procedure TTCategorias.BuscarPorId(xexpr: string);
begin
  tabla.IndexFieldNames := 'idcategoria';
  tabla.FindNearest([xexpr]);
end;

function  TTCategorias.BuscarPeriodo(xidcategoria, xperiodo: String): Boolean;
// Objetivo...: Buscar Instancia
begin
  Result := datosdb.Buscar(percat, 'idcategoria', 'periodo', xidcategoria, utiles.PeriodoSinSeparador(xperiodo));
end;

procedure TTCategorias.RegistrarPeriodo(xidcategoria, xperiodo: String; xmonto: Real);
// Objetivo...: Registrar Instancia
begin
  if BuscarPeriodo(xidcategoria, xperiodo) then percat.Edit else percat.Append;
  percat.FieldByName('idcategoria').AsString := xidcategoria;
  percat.FieldByName('periodo').AsString     := utiles.PeriodoSinSeparador(xperiodo);
  percat.FieldByName('monto').AsFloat        := xmonto;
  try
    percat.Post
   except
    percat.Cancel
  end;
  datosdb.closeDB(percat); percat.Open;
end;

procedure TTCategorias.BorrarPeriodo(xidcategoria, xperiodo: String);
// Objetivo...: Borrar Instancia
begin
  if BuscarPeriodo(xidcategoria, xperiodo) then Begin
    percat.Delete;
    datosdb.closeDB(percat); percat.Open;
  end;
end;

procedure TTCategorias.getDatosPeriodo(xidcategoria, xperiodo: String);
// Objetivo...: Buscar Instancia
begin
  if BuscarPeriodo(xidcategoria, xperiodo) then Begin
    Monto := percat.FieldByName('monto').AsFloat;
  end else Begin
    Monto := 0;
  end;
end;

function  TTCategorias.setMontosCategoria(xidcategoria: String): TObjectList;
// Objetivo...: Devolver Movimientos del día
var
  l: TObjectList;
  objeto: TTCategorias;
Begin
  l := TObjectList.Create;
  datosdb.Filtrar(percat, 'idcategoria = ' + '''' + xidcategoria + '''');
  percat.First;
  while not percat.Eof do Begin
    objeto := TTCategorias.Create;
    objeto.idcategoria := percat.FieldByName('idcategoria').AsString;
    objeto.periodo     := Copy(percat.FieldByName('periodo').AsString, 1, 2) + '/' + Copy(percat.FieldByName('periodo').AsString, 3, 4);
    objeto.Monto       := percat.FieldByName('monto').AsFloat;
    l.Add(objeto);
    percat.Next;
  end;
  datosdb.QuitarFiltro(percat);

  Result := l;
end;

procedure TTCategorias.BuscarUltimoPeriodo(xidcategoria: String);
// Objetivo...: Buscar Ultimo Periodo
begin
  datosdb.Filtrar(percat, 'idcategoria = ' + '''' + xidcategoria + '''');
  percat.Last;
  Periodo := Copy(percat.FieldByName('periodo').AsString, 1, 2) + '/' + Copy(percat.FieldByName('periodo').AsString, 3, 4);
  Monto   := percat.FieldByName('monto').AsFloat;
  datosdb.QuitarFiltro(percat);
end;

procedure TTCategorias.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  conccaja.conectar;
  asociarcompr.conectar;
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('idcategoria').DisplayLabel := 'Id.'; tabla.FieldByName('categoria').DisplayLabel := 'Categoría';
    tabla.FieldByName('monto').DisplayLabel := 'Monto'; tabla.FieldByName('codcaja').DisplayLabel := 'Cód. Caja';
    tabla.FieldByName('codnum').DisplayLabel := 'Cód. Num.';
    if not percat.Active then percat.Open;
  end;
  Inc(conexiones);

  // Fijamos las categorias iniciales
  if percat.RecordCount = 0 then Begin
    tabla.First;
    while not tabla.Eof do Begin
      RegistrarPeriodo(tabla.FieldByName('idcategoria').AsString, '01/2007', tabla.FieldByName('monto').AsFloat);
      tabla.Next;
    end;
  end;
end;

procedure TTCategorias.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  conccaja.desconectar;
  asociarcompr.desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(percat);
  end;
end;

{===============================================================================}

function categoria: TTCategorias;
begin
  if xcategoria_cuot = nil then
    xcategoria_cuot := TTCategorias.Create;
  Result := xcategoria_cuot;
end;

{===============================================================================}

initialization

finalization
  xcategoria_cuot.Free;

end.
