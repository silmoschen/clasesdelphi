unit CArtic;

interface

uses SysUtils, DB, DBTables, CListar, CUtiles, CIDBFM, CBDT;

type

TTArticulos = class(TObject)            // Superclase
  codart, descrip, codrubro, desrubro, codmarca, codmedida, un_bulto, cant_bulto, cant_sueltas, nropartida, compuesto, graviva: string;
  desmarca, desmedida: string;
  puntorep, stock, porcentaje: real;
  ArticuloEncontrado: Boolean;
  tabla, trubro, tmarca, tmedida: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xcodart, xdescrip, xcodrubro, xcodmarca, xcodmedida, xun_bulto, xcant_bulto, xcant_sueltas, xnropartida, xcompuesto, xgraviva: string; xpuntorep: real);
  destructor  Destroy; override;

  procedure   Grabar(xcodart, xdescrip, xcodrubro, xcodmarca, xcodmedida, xun_bulto, xcant_bulto, xcant_sueltas, xnropartida, xcompuesto, xgraviva: string; xpuntorep: real);
  procedure   Borrar(xcodart: string);
  function    Buscar(xcodart: string): boolean;
  function    BuscarPorDescripcion(xdescrip: string): string;
  function    Nuevo: string;
  procedure   getDatos(xcodart: string);
  procedure   ActualizarStock(xcodart: string; st: real);

  procedure   FiltrarRubros(xcodrubro: string);
  procedure   FiltrarMarcas(xcodmarca: string);
  procedure   DesactivarFiltro;
  function    setArticulos(xidrubro: String): TQuery; overload;
  function    setArticulos(xidrubro, xcodmarca: String): TQuery; overload;

  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   Listar_r(orden, iniciar, finalizar, ent_excl: string; salida: char);                // Listado de Artículos
  procedure   Listar_m(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   Listar_er(orden, iniciar, finalizar, ent_excl: string; salida: char; excluir: Boolean);      // Listado de Stock
  procedure   Listar_em(orden, iniciar, finalizar, ent_excl: string; salida: Char; excluir: Boolean);
  procedure   Listar_stockr(orden, iniciar, finalizar, ent_excl: string; salida, excluir: char);  // Listado de Stock Bajo Mínimo
  procedure   Listar_stockm(orden, iniciar, finalizar, ent_excl: string; salida, excluir: char);
  //----------------------------------------------------------------------------
  // Tratamiento de rubros
  procedure   GrabarRubro(xcodrubro, xDescrip: string; xPorcentaje: real);
  procedure   BorrarRubro(xcodrubro: string);
  function    BuscarRubro(xcodrubro: string): boolean;
  function    NuevoRubro: string;
  procedure   getDatosRubro(xcodrubro: string); virtual;
  function    setRubros: TQuery;
  function    setRubrosAlf: TQuery;
  procedure   BuscarPorCodart(xexpr: string);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorCodRubro(xexpr: string);
  procedure   BuscarPorDescripRubro(xexpr: string);
  procedure   EstablecerPorcentaje(xporcentaje: real);

  procedure   conectarRubro;
  procedure   desconectarRubro;
  procedure   ListarRubro(orden, iniciar, finalizar, ent_excl: string; salida: char);
  //----------------------------------------------------------------------------
  // Tratamiento de Marcas
  procedure   GrabarMarca(xcodmarca, xDescrip: string);
  procedure   BorrarMarca(xcodmarca: string);
  function    BuscarMarca(xcodmarca: string): boolean;
  function    NuevaMarca: string;
  procedure   getDatosMarca(xcodmarca: string);
  function    setMarcas: TQuery;
  function    setMarcasAlf: TQuery;
  procedure   ListarMarca(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorCodMarca(xexpr: string);
  procedure   BuscarPorDescripMarca(xexpr: string);

  procedure   conectarMarca;
  procedure   desconectarMarca;
  //----------------------------------------------------------------------------
  procedure   GrabarMedida(xcodmedida, xDescrip: string);
  procedure   BorrarMedida(xcodmedida: string);
  function    BuscarMedida(xcodmedida: string): boolean;
  function    NuevaMedida: string;
  procedure   getDatosMedida(xcodmedida: string);
  procedure   BuscarPorCodMedida(xexpr: string);
  procedure   BuscarPorDescripMedida(xexpr: string);
  procedure   ListarMedida(orden, iniciar, finalizar, ent_excl: string; salida: char);

  procedure   conectarMedida;
  procedure   desconectarMedida;
  //----------------------------------------------------------------------------
  // Control/Ajuste del stock
  procedure   AjustarStock(xcodart: String; xcantidad: Real);
  //----------------------------------------------------------------------------
  function    intervalorefresco: integer;
  procedure   refrescar;
  procedure   vaciarBuffer;
  procedure   conectar;
  procedure   desconectar;
  procedure   setColumnas;
 private
  { Declaraciones Privadas }
  conexiones, conexrubro, conexmarca, conexmedidas: shortint;
  idanterior, dm: string; ExistenDatos: Boolean;
  procedure Listar_linea(salida: char);
  procedure Linea_rubro(salida: char);
  procedure Linea_marca(salida: char);
  procedure Linea_existrubro(salida: char; excluir: Boolean);
  procedure Linea_existmarca(salida: char; excluir: Boolean);
  procedure Titulos(salida: char);
  procedure TitulosExist(salida: char);
  procedure TitulosStockMin(salida: char);
  procedure Linea_stockr(salida: char);
  procedure Linea_stockm(salida: char);
  procedure LineaStock(salida: Char);
 protected
  { Declaraciones Protegidas }
  r, rsql: TQuery;
end;

function artic: TTArticulos;

implementation

var
  xartic: TTArticulos = nil;

//------------------------------------------------------------------------------

constructor TTArticulos.Create(xcodart, xdescrip, xcodrubro, xcodmarca, xcodmedida, xun_bulto, xcant_bulto, xcant_sueltas, xnropartida, xcompuesto, xgraviva: string; xpuntorep: real);
begin
  inherited Create;
  trubro  := datosdb.openDB('rubros', 'codrubro');
  tmarca  := datosdb.openDB('marcas', 'codmarca');
  tmedida := datosdb.openDB('medidas', 'codmedida');
  conexiones := 0; conexrubro := 0; conexmarca := 0; conexmedidas := 0;
end;

destructor TTArticulos.Destroy;
begin
  inherited Destroy;
end;

procedure TTArticulos.Grabar(xcodart, xdescrip, xcodrubro, xcodmarca, xcodmedida, xun_bulto, xcant_bulto, xcant_sueltas, xnropartida, xcompuesto, xgraviva: string; xpuntorep: real);
// Objetivo...: Grabar Atributos de Vendedores
begin
  if Buscar(xcodart) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codart').AsString        := xcodart;
  tabla.FieldByName('articulo').AsString      := xdescrip;
  tabla.FieldByName('codrubro').AsString      := xcodrubro;
  tabla.FieldByName('codmarca').AsString      := xcodmarca;
  tabla.FieldByName('codmedida').AsString     := xcodmedida;
  tabla.FieldByName('unidadesbulto').AsString := xun_bulto;
  tabla.FieldByName('cantidadbulto').AsString := xcant_bulto;
  tabla.FieldByName('cantsueltas').AsString   := xcant_sueltas;
  tabla.FieldByName('nropartida').AsString    := xnropartida;
  tabla.FieldByName('compuesto').AsString     := xcompuesto;
  tabla.FieldByName('Graviva').AsString       := xgraviva;
  tabla.FieldByName('Puntorep').AsFloat       := xpuntorep;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTArticulos.getDatos(xcodart: string);
// Objetivo...: Cargar/Inicializar los Atributos de la Superclase
begin
  if Buscar(xcodart) then
    begin
      codart       := tabla.FieldByName('codart').AsString;
      descrip      := tabla.FieldByName('articulo').AsString;
      codrubro     := tabla.FieldByName('codrubro').AsString;
      codmarca     := tabla.FieldByName('codmarca').AsString;
      codmedida    := tabla.FieldByName('codmedida').AsString;
      un_bulto     := tabla.FieldByName('unidadesbulto').AsString;
      cant_bulto   := tabla.FieldByName('cantidadbulto').AsString;
      cant_sueltas := tabla.FieldByName('cantsueltas').AsString;
      nropartida   := tabla.FieldByName('nropartida').AsString;
      compuesto    := tabla.FieldByName('compuesto').AsString;
      graviva      := tabla.FieldByName('Graviva').AsString;
      puntorep     := tabla.FieldByName('Puntorep').AsFloat;
      stock        := tabla.FieldByName('stock').AsFloat;
      getDatosRubro(codrubro);
      getDatosMarca(codmarca);
      getDatosMedida(codmedida);
    end
   else
    begin
      codart := ''; descrip := ''; codrubro := ''; codmarca := ''; codmedida := ''; un_bulto := ''; cant_bulto := ''; cant_sueltas := ''; nropartida := ''; compuesto := ''; graviva := ''; puntorep := 0;
    end;
end;

function  TTArticulos.Buscar(xcodart: string): boolean;
// Objetivo...: Verificar si Existe el Arítuculo Buscado
begin
  if not tabla.Active then tabla.Open;
  if tabla.IndexFieldNames <> 'Codart' then tabla.IndexFieldNames := 'Codart';
  ArticuloEncontrado := tabla.FindKey([Trim(xcodart)]);
  Result := ArticuloEncontrado;
end;

function TTArticulos.BuscarPorDescripcion(xdescrip: string): string;
// Objetivo...: Búsqueda contextual por artículo
var
  i: string;
begin
  if LowerCase(tabla.IndexName) <> 'articulo' then Begin
    tabla.IndexName := 'articulo';
    i := tabla.IndexFieldNames;
  end;
  tabla.FindNearest([xdescrip]);
  if LowerCase(tabla.IndexName) <> 'articulo' then tabla.IndexFieldNames := i;
  Result := tabla.FieldByName('articulo').AsString;
end;

procedure TTArticulos.Borrar(xcodart: string);
// Objetivo...: Eliminar un Instancia de articulo
begin
  if Buscar(xcodart) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('codart').AsString);
    end;
end;

function TTArticulos.Nuevo: string;
// Objetivo...: Crear un Nuevo articículo
begin
  tabla.Filtered := False;
  if tabla.IndexFieldNames <> 'Codart' then tabla.IndexFieldNames := 'Codart';
  tabla.Last;
  if Length(trim(tabla.Fields[0].AsString)) > 0 then Result := IntToStr(tabla.Fields[0].AsInteger + 1) else Result := '1';
end;

{******************************************************************************}

procedure TTArticulos.ActualizarStock(xcodart: string; st: real);
// Objetivo...: actualizar stock
begin
  if Buscar(xcodart) then
    begin
      tabla.Edit;
      tabla.FieldByName('stock').AsFloat := st;
      try
        tabla.Post;
      except
        tabla.Cancel;
      end;
      datosdb.closeDB(tabla); tabla.Open;
      setColumnas;
      Buscar(xcodart);
    end;
end;

procedure TTArticulos.Titulos(salida: char);
// Objetivo...: Listar Línea de Datos
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Artículos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Código', 1, 'Courier New, cursiva, 8');
  List.Titulo(18, List.lineactual, 'Descripción', 2, 'Courier New, cursiva, 8');
  List.Titulo(45, List.lineactual, 'Medida', 3, 'Courier New, cursiva, 8');
  List.Titulo(67, List.lineactual, dm, 4, 'Courier New, cursiva, 8');
  List.Titulo(89, List.lineactual, 'Un. Bulto', 5, 'Courier New, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTArticulos.Listar_linea(salida: char);
// Objetivo...: Listar Línea de Datos
begin
  getDatosMedida(tabla.FieldByName('codmedida').AsString);
  getDatosMarca(tabla.FieldByName('codmarca').AsString);
  List.Linea(0, 0, tabla.FieldByName('codart').AsString, 1, 'Courier New, normal, 8', salida, 'N');
  List.Linea(18, List.lineactual, tabla.FieldByName('articulo').AsString, 2, 'Courier New, normal, 8', salida, 'N');
  List.Linea(45, List.lineactual, Desmedida, 3, 'Courier New, normal, 8', salida, 'N');
  List.Linea(67, List.lineactual, Desmarca, 4, 'Courier New, normal, 8', salida, 'N');
  List.Linea(89, List.lineactual, tabla.FieldByName('unidadesBulto').AsString, 5, 'Courier New, normal, 8', salida, 'S');
end;

procedure TTArticulos.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de articículos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  dm := 'Marca';
  Titulos(salida);

  tabla.First; ExistenDatos := False;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('codart').AsString >= iniciar) and (tabla.FieldByName('codart').AsString <= finalizar) then Listar_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('codart').AsString < iniciar) or (tabla.FieldByName('codart').AsString > finalizar) then Listar_Linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('articulo').AsString >= iniciar) and (tabla.FieldByName('articulo').AsString <= finalizar) then Listar_Linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('articulo').AsString < iniciar) or (tabla.FieldByName('articulo').AsString > finalizar) then Listar_Linea(salida);

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTArticulos.Listar_r(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar articulos con Nivel de Ruptura por Rubro
begin
  r := datosdb.tranSQL('SELECT codart, articulo, codrubro, codmarca, codmedida, unidadesbulto FROM articulo WHERE codrubro >= ' + '''' + iniciar + '''' + ' AND codrubro <= ' + '''' + finalizar + '''' + ' ORDER BY codrubro');

  dm := 'Marca'; idanterior := '';
  Titulos(salida);

  r.Open; r.First;
  while not r.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (r.FieldByName('codrubro').AsString >= iniciar) and (r.FieldByName('codrubro').AsString <= finalizar) then Linea_rubro(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (r.FieldByName('codrubro').AsString < iniciar) or (r.FieldByName('codrubro').AsString > finalizar) then Linea_rubro(salida);

      r.Next;
    end;
    r.Close;

    List.FinList;
end;

procedure TTArticulos.Listar_m(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar articulos con Nivel de Ruptura por Marca
begin
  r := datosdb.tranSQL('SELECT codart, articulo, codrubro, codmedida, codmarca, unidadesbulto FROM articulo WHERE codmarca >= ' + '''' + iniciar + '''' + ' AND codmarca <= ' + '''' + finalizar + '''' + ' ORDER BY codmarca');

  dm := ''; idanterior := '';
  Titulos(salida);

  r.Open; r.First;
  while not r.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (r.FieldByName('codmarca').AsString >= iniciar) and (r.FieldByName('codmarca').AsString <= finalizar) then Linea_marca(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (r.FieldByName('codmarca').AsString < iniciar) or (r.FieldByName('codmarca').AsString > finalizar) then Linea_marca(salida);

      r.Next;
    end;
  r.Close;

  List.FinList;
end;

// Subrrutinas de Impresión
procedure TTArticulos.Linea_rubro(salida: char);
// Objetivo...: Emitir una línea de Impresión de articículo
begin
  if r.FieldByName('codrubro').AsString <> idanterior then
    begin
      getDatosRubro(r.FieldByName('codrubro').AsString);
      if Length(trim(idanterior)) > 0 then List.Linea(0, 0, ' ', 1, 'Courier New, normal, 8', salida, 'S');
      List.Linea(0, 0, r.FieldByName('codrubro').AsString + ' ' + Desrubro, 1, 'Arial, negrita, 12', salida, 'N');
      List.Linea(0, 0, ' ', 1, 'Courier New, normal, 5', salida, 'S');
    end;
  getDatosMedida(r.FieldByName('codmedida').AsString);
  getDatosMarca(r.FieldByName('codmarca').AsString);
  List.Linea(0, 0, r.FieldByName('codart').AsString, 1, 'Courier New, normal, 8', salida, 'N');
  List.Linea(18, List.lineactual, r.FieldByName('articulo').AsString, 2, 'Courier New, normal, 8', salida, 'N');
  List.Linea(45, List.lineactual, Desmedida, 3, 'Courier New, normal, 8', salida, 'N');
  List.Linea(67, List.lineactual, Desmarca, 4, 'Courier New, normal, 8', salida, 'N');
  List.Linea(89, List.lineactual, r.FieldByName('unidadesBulto').AsString, 5, 'Courier New, normal, 8', salida, 'S');
  idanterior := r.FieldByName('codrubro').AsString;
end;

procedure TTArticulos.Linea_marca(salida: char);
// Objetivo...: Emitir una línea de Impresión de articículo
begin
  if r.FieldByName('codmarca').AsString <> idanterior then
    begin
      getDatosMarca(r.FieldByName('codmarca').AsString);
      if Length(trim(idanterior)) > 0 then List.Linea(0, 0, ' ', 1, 'Courier New, normal, 8', salida, 'S');
      List.Linea(0, 0, r.FieldByName('codmarca').AsString + ' ' + Desmarca, 1, 'Arial, negrita, 12', salida, 'N');
      List.Linea(0, 0, ' ', 1, 'Courier New, normal, 5', salida, 'S');
    end;
  getDatosMedida(r.FieldByName('codmedida').AsString);
  List.Linea(0, 0, r.FieldByName('codart').AsString, 1, 'Courier New, normal, 8', salida, 'N');
  List.Linea(18, List.lineactual, r.FieldByName('articulo').AsString, 2, 'Courier New, normal, 8', salida, 'N');
  List.Linea(45, List.lineactual, Desmedida, 3, 'Courier New, normal, 8', salida, 'N');
  List.Linea(89, List.lineactual, r.FieldByName('unidadesBulto').AsString, 4, 'Courier New, normal, 8', salida, 'S');
  idanterior := r.FieldByName('codmarca').AsString;
end;

// Listados de Existencias
procedure TTArticulos.Listar_er(orden, iniciar, finalizar, ent_excl: string; salida: char; excluir: Boolean);
// Objetivo...: Listar existencias con Nivel de Ruptura por Rubro
begin
  if orden = 'C' then r := datosdb.tranSQL('SELECT codrubro, descrip FROM rubros ORDER BY codrubro') else r := datosdb.tranSQL('SELECT codrubro, descrip FROM rubros ORDER BY descrip');

  TitulosExist(salida);

  r.Open; r.First;
  while not r.EOF do Begin
    getDatosRubro(r.FieldByName('codrubro').AsString);
    if (ent_excl = 'E') and (orden = 'C') then
      if (r.FieldByName('codrubro').AsString >= iniciar) and (r.FieldByName('codrubro').AsString <= finalizar) then Linea_existrubro(salida, excluir);
    if (ent_excl = 'X') and (orden = 'C') then
      if (r.FieldByName('codrubro').AsString < iniciar) or (r.FieldByName('codrubro').AsString > finalizar) then Linea_existrubro(salida, excluir);
    if (ent_excl = 'E') and (orden = 'A') then
      if (r.FieldByName('descrip').AsString >= iniciar) and (r.FieldByName('descrip').AsString <= finalizar) then Linea_existrubro(salida, excluir);
    if (ent_excl = 'X') and (orden = 'A') then
      if (r.FieldByName('descrip').AsString < iniciar) or (r.FieldByName('descrip').AsString > finalizar) then Linea_existrubro(salida, excluir);

    r.Next;
  end;
  r.Close; r.Free;

  trubro.First;

  List.FinList;
end;

procedure TTArticulos.Linea_existrubro(salida: char; excluir: Boolean);
// Objetivo...: Linea de impresión de existencias
var
  l, s: Boolean;
begin
  rsql := datosdb.tranSQL('SELECT codart, articulo, stock, codrubro, codmarca FROM ' + tabla.TableName + ' WHERE codrubro = ' + '"' + codrubro + '"' + ' ORDER BY articulo, codmarca');
  rsql.Open; idanterior := '';
  if rsql.RecordCount > 0 then Begin
    rsql.First;
    while not rsql.Eof do Begin
      l := False;
      if Not excluir then l := True;
      if excluir then
        if rsql.FieldByName('stock').AsFloat > 0 then l := True;
      if l then Begin
        if not s then Begin
          List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
          List.Linea(0, 0, Codrubro + ' ' + Desrubro, 1, 'Arial, negrita, 12', salida, 'N');
          List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
          s := True;
        end;
        LineaStock(salida);
      end;
      rsql.Next;
    end;
  end;
  rsql.Close; rsql.Free;
end;

procedure TTArticulos.LineaStock(salida: Char);
// Objetivo...: Listar existencias con Nivel de Ruptura por Marca
begin
  if rsql.FieldByName('codmarca').AsString <> idanterior then List.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  List.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(4, List.lineactual, rsql.FieldByName('codart').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(18, List.lineactual, rsql.FieldByName('articulo').AsString, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(50, List.lineactual, '.....................................................................................', 4, 'Arial, normal, 8', salida, 'N');
  List.importe(95, List.lineactual, '', rsql.FieldByName('stock').AsFloat, 5, 'Arial, normal, 8');
  List.Linea(97, List.lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
  idanterior := rsql.FieldByName('codmarca').AsString;
end;

procedure TTArticulos.Listar_em(orden, iniciar, finalizar, ent_excl: string; salida: Char; excluir: Boolean);
// Objetivo...: Listar existencias con Nivel de Ruptura por Marca
begin
  if orden = 'C' then r := datosdb.tranSQL('SELECT codmarca, descrip FROM marcas ORDER BY codmarca') else r := datosdb.tranSQL('SELECT codmarca, descrip FROM marcas ORDER BY descrip');

  TitulosExist(salida);

  r.Open; r.First;
  while not r.EOF do Begin
    getDatosMarca(r.FieldByName('codmarca').AsString);
    if (ent_excl = 'E') and (orden = 'C') then
      if (r.FieldByName('codmarca').AsString >= iniciar) and (r.FieldByName('codmarca').AsString <= finalizar) then Linea_existmarca(salida, excluir);
    if (ent_excl = 'X') and (orden = 'C') then
      if (r.FieldByName('codmarca').AsString < iniciar) or (r.FieldByName('codmarca').AsString > finalizar) then Linea_existmarca(salida, excluir);
    if (ent_excl = 'E') and (orden = 'A') then
      if (r.FieldByName('descrip').AsString >= iniciar) and (r.FieldByName('descrip').AsString <= finalizar) then Linea_existmarca(salida, excluir);
    if (ent_excl = 'X') and (orden = 'A') then
      if (r.FieldByName('descrip').AsString < iniciar) or (r.FieldByName('descrip').AsString > finalizar) then Linea_existmarca(salida, excluir);

    r.Next;
  end;
  r.Close; r.Free;

  tmarca.First;

  List.FinList;
end;

procedure TTArticulos.Linea_existmarca(salida: char; excluir: Boolean);
// Objetivo...: Linea de impresión de existencias
var
  l, s: Boolean;
begin
  rsql := datosdb.tranSQL('SELECT codart, articulo, stock, codmarca FROM ' + tabla.TableName + ' WHERE codmarca = ' + '"' + codmarca + '"' + ' ORDER BY articulo');
  rsql.Open;
  if rsql.RecordCount > 0 then Begin
    rsql.First;
    while not rsql.Eof do Begin
      l := False;
      if Not excluir then l := True;
      if excluir then
        if rsql.FieldByName('stock').AsFloat > 0 then l := True;
      if l then Begin
        if not s then Begin
          List.Linea(0, 0, ' ', 1, 'Courier New, normal, 8', salida, 'S');
          List.Linea(0, 0, codmarca + ' ' + Desmarca, 1, 'Arial, negrita, 12', salida, 'N');
          List.Linea(0, 0, ' ', 1, 'Courier New, normal, 5', salida, 'S');
          s := True;
        end;
        LineaStock(salida);
      end;
      rsql.Next;
    end;
  end;
  rsql.Close; rsql.Free;
end;

procedure TTArticulos.TitulosExist(salida: char);
// Objetivo...: Listar Titulos listados de Existencia
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Existencias', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Código', 1, 'Arial, cursiva, 8');
  List.Titulo(18, List.lineactual, 'Descripción', 2, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Stock', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTArticulos.Listar_stockr(orden, iniciar, finalizar, ent_excl: string; salida, excluir: char);
// Objetivo...: Listado de Stock Bajo Mínimo con Nivel de ruptura por rubro
var
  l: boolean;
begin
  r := datosdb.tranSQL('SELECT codart, articulo, codrubro, puntorep, codmedida, unidadesbulto, stock FROM articulo WHERE codrubro >= ' + '''' + iniciar + '''' + ' AND codrubro <= ' + '''' + finalizar + '''' + '  AND stock < puntorep ORDER BY codrubro');

  idanterior := '';
  TitulosStockMin(salida);

  r.Open; r.First;
  while not r.EOF do
    begin
      l := False;
      if excluir = 'N' then l := True;
      if (excluir = 'S') and (r.FieldByName('stock').AsFloat > 0) then l := True;
      if l then
        begin
          if (ent_excl = 'E') and (orden = 'C') and (l) then
            if (r.FieldByName('codrubro').AsString >= iniciar) and (r.FieldByName('codrubro').AsString <= finalizar) then Linea_stockr(salida);
          if (ent_excl = 'X') and (orden = 'C') and (l) then
            if (r.FieldByName('codrubro').AsString < iniciar) or (r.FieldByName('codrubro').AsString > finalizar) then Linea_stockr(salida);
        end;
      r.Next;
    end;
    r.Close; r.Free;



    List.FinList;
end;

procedure TTArticulos.Listar_stockm(orden, iniciar, finalizar, ent_excl: string; salida, excluir: char);
// Objetivo...: Listado de Stock Bajo Mínimo con Nivel de ruptura por Marca
var
  l: boolean;
begin
  r := datosdb.tranSQL('SELECT codart, articulo, codmarca, puntorep, codmedida, unidadesbulto, stock FROM articulo WHERE codmarca >= ' + '''' + iniciar + '''' + ' AND codmarca <= ' + '''' + finalizar + '''' + '  AND stock < puntorep ORDER BY codrubro');

  idanterior := '';
  TitulosStockMin(salida);

  r.Open; r.First;
  while not r.EOF do
    begin
      l := False;
      if excluir = 'N' then l := True;
      if (excluir = 'S') and (r.FieldByName('stock').AsFloat > 0) then l := True;
      if l then
        begin
          if (ent_excl = 'E') and (orden = 'C') and (l) then
            if (r.FieldByName('codmarca').AsString >= iniciar) and (r.FieldByName('codmarca').AsString <= finalizar) then Linea_stockm(salida);
          if (ent_excl = 'X') and (orden = 'C') and (l) then
            if (r.FieldByName('codmarca').AsString < iniciar) or (r.FieldByName('codmarca').AsString > finalizar) then Linea_stockm(salida);
        end;
      r.Next;
    end;
    r.Close;

    List.FinList;
end;

procedure TTArticulos.Linea_stockr(salida: char);
// Objetivo...: Linea de impresión de existencias bajo mínimo por rubro
begin
  if r.FieldByName('codrubro').AsString <> idanterior then
    begin
      getDatosRubro(r.FieldByName('codrubro').AsString);
      if Length(trim(idanterior)) > 0 then List.Linea(0, 0, ' ', 1, 'Courier New, normal, 8', salida, 'S');
      List.Linea(0, 0, r.FieldByName('codrubro').AsString + ' ' + Desrubro, 1, 'Arial, negrita, 12', salida, 'N');
      List.Linea(0, 0, ' ', 1, 'Courier New, normal, 5', salida, 'S');
    end;
  List.Linea(0, 0, '         ' + r.FieldByName('codart').AsString, 1, 'Courier New, normal, 8', salida, 'N');
  List.Linea(18, List.lineactual, r.FieldByName('articulo').AsString, 2, 'Courier New, normal, 8', salida, 'N');
  List.importe(80, List.lineactual, '', r.FieldByName('puntorep').AsFloat, 3, 'Courier New, normal, 8');
  List.importe(95, List.lineactual, '', r.FieldByName('stock').AsFloat, 4, 'Courier New, normal, 8');
  List.Linea(97, List.lineactual, '', 5, 'Courier New, normal, 8', salida, 'S');
  idanterior := r.FieldByName('codrubro').AsString;
end;

procedure TTArticulos.Linea_stockm(salida: char);
// Objetivo...: Linea de impresión de existencias bajo mínimo por marca
begin
  if r.FieldByName('codmarca').AsString <> idanterior then
    begin
      getDatosMarca(r.FieldByName('codmarca').AsString);
      if Length(trim(idanterior)) > 0 then List.Linea(0, 0, ' ', 1, 'Courier New, normal, 8', salida, 'S');
      List.Linea(0, 0, r.FieldByName('codmarca').AsString + ' ' + Desmarca, 1, 'Arial, negrita, 12', salida, 'N');
      List.Linea(0, 0, ' ', 1, 'Courier New, normal, 5', salida, 'S');
    end;
  List.Linea(0, 0, r.FieldByName('codart').AsString, 1, 'Courier New, normal, 8', salida, 'N');
  List.Linea(18, List.lineactual, r.FieldByName('articulo').AsString, 2, 'Courier New, normal, 8', salida, 'N');
  List.importe(80, List.lineactual, '', r.FieldByName('puntorep').AsFloat, 3, 'Courier New, normal, 8');
  List.importe(95, List.lineactual, '', r.FieldByName('stock').AsFloat, 4, 'Courier New, normal, 8');
  List.Linea(97, List.lineactual, '', 5, 'Courier New, normal, 8', salida, 'S');
  idanterior := r.FieldByName('codrubro').AsString;
end;

procedure TTArticulos.TitulosStockMin(salida: char);
// Objetivo...: Listar Titulos listados de Stock Bajo Mínimo
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Stock Bajo Mínimo', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Código', 1, 'Courier New, cursiva, 8');
  List.Titulo(18, List.lineactual, 'Descripción', 2, 'Courier New, cursiva, 8');
  List.Titulo(70, List.lineactual, 'Punto Rep.', 3, 'Courier New, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Stock', 4, 'Courier New, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTArticulos.FiltrarRubros(xcodrubro: string);
// Objetivo...: Filtrar rubros
begin
  datosdb.Filtrar(tabla, 'Codrubro = ' + '''' + xcodrubro + '''');
end;

procedure TTArticulos.FiltrarMarcas(xcodmarca: string);
// Objetivo...: Filtrar rubros
begin
  datosdb.Filtrar(tabla, 'Codmarca = ' + '''' + xcodmarca + '''');
end;

procedure TTArticulos.DesactivarFiltro;
// Objetivo...: Quitar Filtros
begin
  tabla.Filtered := False;
end;

function TTArticulos.setArticulos(xidrubro: String): TQuery;
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' WHERE Codrubro = ' + '"' + xidrubro + '"');
end;

function TTArticulos.setArticulos(xidrubro, xcodmarca: String): TQuery;
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' WHERE Codrubro = ' + '"' + xidrubro + '"' + ' AND codmarca = ' + '"' + xcodmarca + '"');
end;
//------------------------------------------------------------------------------
// Tratamiento de los rubros
procedure TTArticulos.GrabarRubro(xcodrubro, xdescrip: string; xporcentaje: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if BuscarRubro(xcodrubro) then trubro.Edit else trubro.Append;
  trubro.FieldByName('codrubro').AsString  := xcodrubro;
  trubro.FieldByName('descrip').AsString   := xdescrip;
  trubro.FieldByName('porcentaje').AsFloat := xporcentaje;
  try
    trubro.Post
  except
    trubro.Cancel
  end;
end;

procedure TTArticulos.BorrarRubro(xcodrubro: string);
// Objetivo...: Eliminar un Objeto
begin
  if BuscarRubro(xcodrubro) then
    begin
      trubro.Delete;
      getDatosRubro(trubro.FieldByName('codrubro').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTArticulos.BuscarRubro(xcodrubro: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if trubro.IndexFieldNames <> 'codrubro' then trubro.IndexFieldNames := 'codrubro';
  if trubro.FindKey([xcodrubro]) then Result := True else Result := False;
end;

procedure  TTArticulos.getDatosRubro(xcodrubro: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if BuscarRubro(xcodrubro) then Begin
    codrubro   := trubro.FieldByName('codrubro').AsString;
    desrubro   := trubro.FieldByName('descrip').AsString;
    porcentaje := trubro.FieldByName('porcentaje').AsFloat;
  end else Begin
    codrubro := ''; desrubro := ''; porcentaje := 0;
  end;
end;

function TTArticulos.NuevoRubro: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  if trubro.IndexFieldNames <> 'Codrubro' then trubro.IndexFieldNames := 'Codrubro';
  if (trubro.EOF) or (trubro.BOF) then Result := '1' else Begin
    trubro.Last;
    Result := utiles.sLLenarIzquierda(IntToStr(trubro.FieldByName('codrubro').AsInteger + 1), 4, '0');
  end;
end;

function TTArticulos.setRubros: TQuery;
// Objetivo...: retornar un set de rubros
begin
  Result := datosdb.tranSQL('SELECT codrubro, descrip FROM rubros');
end;

function TTArticulos.setRubrosAlf: TQuery;
// Objetivo...: retornar un set de rubros
begin
  Result := datosdb.tranSQL('SELECT codrubro, descrip FROM rubros ORDER BY descrip');
end;

procedure TTArticulos.ListarRubro(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then trubro.IndexName := trubro.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Rubros', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(4) +  'Rubro', 1, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  trubro.First;
  while not trubro.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (trubro.FieldByName('codrubro').AsString >= iniciar) and (trubro.FieldByName('codrubro').AsString <= finalizar) then List.Linea(0, 0, trubro.FieldByName('codrubro').AsString + '   ' + trubro.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'C') then
        if (trubro.FieldByName('codrubro').AsString < iniciar) or (trubro.FieldByName('codrubro').AsString > finalizar) then List.Linea(0, 0, trubro.FieldByName('codrubro').AsString + '   ' + trubro.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (trubro.FieldByName('descrip').AsString >= iniciar) and (trubro.FieldByName('descrip').AsString <= finalizar) then List.Linea(0, 0, trubro.FieldByName('codrubro').AsString + '   ' + trubro.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'A') then
        if (trubro.FieldByName('descrip').AsString < iniciar) or (trubro.FieldByName('descrip').AsString > finalizar) then List.Linea(0, 0, trubro.FieldByName('codrubro').AsString + '   ' + trubro.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');

      trubro.Next;
    end;
    List.FinList;

    trubro.IndexFieldNames := trubro.IndexFieldNames;
    trubro.First;
end;

procedure TTArticulos.BuscarPorCodRubro(xexpr: string);
begin
  if trubro.IndexFieldNames <> 'Codrubro' then trubro.IndexFieldNames := 'Codrubro';
  trubro.FindNearest([xexpr]);
end;

procedure TTArticulos.BuscarPorDescripRubro(xexpr: string);
begin
  if trubro.IndexFieldNames <> 'Descrip' then trubro.IndexFieldNames := 'Descrip';
  trubro.FindNearest([xexpr]);
end;

procedure TTArticulos.EstablecerPorcentaje(xporcentaje: real);
begin
  trubro.Edit;
  trubro.FieldByName('porcentaje').AsFloat := xporcentaje;
  try
    trubro.Post
   except
    trubro.Cancel
  end;
end;

procedure TTArticulos.conectarRubro;
// Objetivo...: conectar trubros de persistencia
begin
  if conexrubro = 0 then Begin
    if not trubro.Active then trubro.Open;
    trubro.FieldByName('codrubro').DisplayLabel := 'Cód.'; trubro.FieldByName('descrip').DisplayLabel := 'Descripción'; trubro.FieldByName('porcentaje').EditMask := '##.##'; trubro.FieldByName('porcentaje').DisplayLabel := 'Porcentaje';
  end;
  Inc(conexrubro);
end;

procedure TTArticulos.desconectarRubro;
// Objetivo...: desconectar trubros de persistencia
begin
  if conexrubro > 0 then Dec(conexrubro);
  if conexrubro = 0 then datosdb.closeDB(trubro);
end;
//------------------------------------------------------------------------------
procedure TTArticulos.GrabarMarca(xcodmarca, xdescrip: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if BuscarMarca(xcodmarca) then tmarca.Edit else tmarca.Append;
  tmarca.FieldByName('codmarca').AsString := xcodmarca;
  tmarca.FieldByName('descrip').AsString  := xdescrip;
  try
    tmarca.Post;
  except
    tmarca.Cancel;
  end;
end;

procedure TTArticulos.BorrarMarca(xcodmarca: string);
// Objetivo...: Eliminar un Objeto
begin
  if BuscarMarca(xcodmarca) then
    begin
      tmarca.Delete;
      getDatosMarca(tmarca.FieldByName('codmarca').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTArticulos.BuscarMarca(xcodmarca: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tmarca.IndexFieldNames <> 'codmarca' then tmarca.IndexFieldNames := 'codmarca';
  if tmarca.FindKey([xcodmarca]) then Result := True else Result := False;
end;

procedure  TTArticulos.getDatosMarca(xcodmarca: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if BuscarMarca(xcodmarca) then
    begin
      codmarca  := tmarca.FieldByName('codmarca').AsString;
      desmarca  := tmarca.FieldByName('descrip').AsString;
    end
   else
    begin
      codmarca := ''; desmarca := '';
    end;
end;

function TTArticulos.NuevaMarca: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  if tmarca.IndexFieldNames <> 'Codmarca' then tmarca.IndexFieldNames := 'Codmarca';
  if (tmarca.EOF) or (tmarca.BOF) then Result := '1' else Begin
    tmarca.Last;
    Result := IntToStr(tmarca.FieldByName('codmarca').AsInteger + 1);
  end;
end;

function TTArticulos.setMarcas: TQuery;
// Objetivo...: retornar un subset de marcas
begin
  Result := datosdb.tranSQL('SELECT codmarca, descrip FROM marcas');
end;

function TTArticulos.setMarcasAlf: TQuery;
// Objetivo...: retornar un subset de marcas ordenadas alfabeticamente
begin
  Result := datosdb.tranSQL('SELECT codmarca, descrip FROM marcas ORDER BY descrip');
end;

procedure TTArticulos.ListarMarca(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tmarca.IndexName := tmarca.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Marcas', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(4) +  'Marca', 1, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tmarca.First;
  while not tmarca.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tmarca.FieldByName('codmarca').AsString >= iniciar) and (tmarca.FieldByName('codmarca').AsString <= finalizar) then List.Linea(0, 0, tmarca.FieldByName('codmarca').AsString + '   ' + tmarca.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'C') then
        if (tmarca.FieldByName('codmarca').AsString < iniciar) or (tmarca.FieldByName('codmarca').AsString > finalizar) then List.Linea(0, 0, tmarca.FieldByName('codmarca').AsString + '   ' + tmarca.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tmarca.FieldByName('descrip').AsString >= iniciar) and (tmarca.FieldByName('descrip').AsString <= finalizar) then List.Linea(0, 0, tmarca.FieldByName('codmarca').AsString + '   ' + tmarca.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'A') then
        if (tmarca.FieldByName('descrip').AsString < iniciar) or (tmarca.FieldByName('descrip').AsString > finalizar) then List.Linea(0, 0, tmarca.FieldByName('codmarca').AsString + '   ' + tmarca.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');

      tmarca.Next;
    end;
    List.FinList;

    tmarca.IndexFieldNames := tmarca.IndexFieldNames;
    tmarca.First;
end;

procedure TTArticulos.BuscarPorCodMarca(xexpr: string);
begin
  if tmarca.IndexFieldNames <> 'Codmarca' then tmarca.IndexFieldNames := 'Codmarca';
  tmarca.FindNearest([xexpr]);
end;

procedure TTArticulos.BuscarPorDescripMarca(xexpr: string);
begin
  if tmarca.IndexFieldNames <> 'Descrip' then tmarca.IndexFieldNames := 'Descrip';
  tmarca.FindNearest([xexpr]);
end;

procedure TTArticulos.conectarMarca;
// Objetivo...: conectar tmarcas de persistencia
begin
  if conexmarca = 0 then Begin
    if not tmarca.Active then tmarca.Open;
    tmarca.FieldByName('codmarca').DisplayLabel := 'Cód.'; tmarca.FieldByName('descrip').DisplayLabel := 'Descripción';
  end;
  Inc(conexmarca);
end;

procedure TTArticulos.desconectarMarca;
// Objetivo...: desconectar tmarcas de persistencia
begin
  if conexmarca > 0 then Dec(conexmarca);
  if conexmarca = 0 then datosdb.closeDB(tmarca);
end;

//------------------------------------------------------------------------------
// Tratamiento de Medidas
procedure TTArticulos.GrabarMedida(xcodmedida, xdescrip: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if BuscarMedida(xcodmedida) then tmedida.Edit else tmedida.Append;
  tmedida.FieldByName('codmedida').AsString := xcodmedida;
  tmedida.FieldByName('descrip').AsString   := xdescrip;
  try
    tmedida.Post
  except
    tmedida.Cancel
  end;
end;

procedure TTArticulos.BorrarMedida(xcodmedida: string);
// Objetivo...: Eliminar un Objeto
begin
  if BuscarMedida(xcodmedida) then
    begin
      tmedida.Delete;
      getDatosMedida(tmedida.FieldByName('codmedida').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTArticulos.BuscarMedida(xcodmedida: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tmedida.IndexFieldNames <> 'codmedida' then tmedida.IndexFieldNames := 'codmedida';
  if tmedida.FindKey([xcodmedida]) then Result := True else Result := False;
end;

procedure  TTArticulos.getDatosMedida(xcodmedida: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if BuscarMedida(xcodmedida) then
    begin
      codmedida := tmedida.FieldByName('codmedida').AsString;
      desmedida := tmedida.FieldByName('descrip').AsString;
    end
   else
    begin
      codmedida := ''; desmedida := '';
    end;
end;

function TTArticulos.NuevaMedida: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  if tmedida.IndexFieldNames <> 'codmedida' then tmedida.IndexFieldNames := 'codmedida';
  if (tmedida.EOF) or (tmedida.BOF) then Result := '1' else Begin
    tmedida.Last;
    Result := IntToStr(tmedida.FieldByName('codmedida').AsInteger + 1);
  end;
end;

procedure TTArticulos.conectarMedida;
// Objetivo...: conectar tmedidas de persistencia
begin
  if conexmedidas = 0 then Begin
    if not tmedida.Active then tmedida.Open;
    tmedida.FieldByName('codmedida').DisplayLabel := 'Cód.'; tmedida.FieldByName('descrip').DisplayLabel := 'Descripción';
  end;
  Inc(conexmedidas);
end;

procedure TTArticulos.BuscarPorCodMedida(xexpr: string);
begin
  if tmedida.IndexFieldNames <> 'codmedida' then tmedida.IndexFieldNames := 'codmedida';
  tmedida.FindNearest([xexpr]);
end;

procedure TTArticulos.BuscarPorDescripMedida(xexpr: string);
begin
  if tmedida.IndexName <> 'Descrip' then tmedida.IndexName := 'Descrip';
  tmedida.FindNearest([xexpr]);
end;

procedure TTArticulos.desconectarMedida;
// Objetivo...: desconectar tmedidas de persistencia
begin
  if conexmedidas > 0 then Dec(conexmedidas);
  if conexmedidas = 0 then datosdb.closeDB(tmedida);
end;

procedure TTArticulos.ListarMedida(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tmedida.IndexName := tmedida.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Medidas', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(4) +  'Medida', 1, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tmedida.First;
  while not tmedida.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tmedida.FieldByName('codmedida').AsString >= iniciar) and (tmedida.FieldByName('codmedida').AsString <= finalizar) then List.Linea(0, 0, tmedida.FieldByName('codmedida').AsString + '   ' + tmedida.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'C') then
        if (tmedida.FieldByName('codmedida').AsString < iniciar) or (tmedida.FieldByName('codmedida').AsString > finalizar) then List.Linea(0, 0, tmedida.FieldByName('codmedia').AsString + '   ' + tmedida.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tmedida.FieldByName('descrip').AsString >= iniciar) and (tmedida.FieldByName('descrip').AsString <= finalizar) then List.Linea(0, 0, tmedida.FieldByName('codmedida').AsString + '   ' + tmedida.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'A') then
        if (tmedida.FieldByName('descrip').AsString < iniciar) or (tmedida.FieldByName('descrip').AsString > finalizar) then List.Linea(0, 0, tmedida.FieldByName('codmedida').AsString + '   ' + tmedida.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');

      tmedida.Next;
    end;
    List.FinList;

    tmedida.IndexFieldNames := tmedida.IndexFieldNames;
    tmedida.First;
end;
//------------------------------------------------------------------------------

procedure TTArticulos.AjustarStock(xcodart: String; xcantidad: Real);
Begin
  if Buscar(xcodart) then Begin
    tabla.Edit;
    tabla.FieldByName('stock').AsFloat := xcantidad;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
  end;
end;

//------------------------------------------------------------------------------
function TTArticulos.intervalorefresco: integer;
// Objetivo...: Devolver el intervalo de refresco
begin
  Result := datosdb.intervalorefresco;
end;

procedure TTArticulos.refrescar;
// Objetivo...: Refrescar Datos
begin
  datosdb.refrescar(tabla);
end;

procedure TTArticulos.vaciarBuffer;
// Objetivo...: escribir los datos en disco para vaciar Buffer
begin
  datosdb.vaciarBuffer(tabla);
end;

procedure TTArticulos.BuscarPorCodart(xexpr: string);
// Objetivo...: buscar por código
begin
  if tabla.IndexFieldNames <> 'Codart' then tabla.IndexFieldNames := 'Codart';
  tabla.FindNearest([xexpr]);
end;

procedure TTArticulos.BuscarPorDescrip(xexpr: string);
// Objetivo...: buscar por código de artículo
begin
  if tabla.IndexName <> 'Articulo' then tabla.IndexName := 'Articulo';
  tabla.FindNearest([xexpr]);
end;

procedure TTArticulos.setColumnas;
// Objetivo...: conectar tablas de persistencia
var
  i: integer;
Begin
  For i := 1 to tabla.FieldCount do  // Habilitamos los campos que estarán visibles
    if i > 2 then tabla.Fields[i-1].Visible := False;
    tabla.FieldByName('codart').DisplayLabel := 'Cód. del Artículo'; tabla.FieldByName('articulo').DisplayLabel := 'Descripción del Articulo'; tabla.FieldByName('articulo').DisplayWidth := tabla.FieldByName('articulo').DisplayWidth + (tabla.FieldByName('articulo').DisplayWidth div 2);
end;

procedure TTArticulos.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then Begin
      tabla.Open;
      setColumnas;
    end;
  end;
  Inc(conexiones);
  conectarRubro;
  conectarMarca;
  conectarMedida;
end;

procedure TTArticulos.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
  desconectarRubro;
  desconectarMarca;
  desconectarMedida;
end;

{===============================================================================}

function artic: TTArticulos;
begin
  if xartic = nil then
    xartic := TTArticulos.Create('', '', '', '', '', '', '', '', '', '', '', 0);
  Result := xartic;
end;

{===============================================================================}

initialization

finalization
  xartic.Free;

end.
