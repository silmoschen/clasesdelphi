unit CIndices_Asociacion;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar, Printers;

type

TTIndicesCreditos = class(TObject)
  Items, Descrip, Anio: String;
  Indice, Promedio: Real;
  tabla, indices, indicesun: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xItems, xDescrip: String); overload;
  procedure   Borrar(xItems: string);
  function    Buscar(xItems: string): Boolean;
  procedure   getDatos(xItems: string);
  function    setCategorias: TQuery;
  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   ListarIndices(orden, iniciar, finalizar, ent_excl, xanio: string; salida: char);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorId(xexpr: string);

  procedure   Grabar(xAnio, xItems, xmes: String; xPromedio: Real); overload;
  function    setItems(xanio: String): TQuery;
  function    setIndices(xanio: String): TQuery;
  function    setIndice(xAnio, xItems, xmes: String): Real;

  procedure   GrabarIndices(xAnio, xmes: String; xIndice: Real);
  procedure   getIndices(xAnio, xMes: String);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  procedure   ListLinea(salida: char);
  procedure   ListLineaIndices(xanio: String; salida: char);
  { Declaraciones Privadas }
end;

function indice: TTIndicesCreditos;

implementation

var
  xindice: TTIndicesCreditos = nil;

constructor TTIndicesCreditos.Create;
begin
  inherited Create;
  tabla     := datosdb.openDB('indices', 'Items');
  indices   := datosdb.openDB('indices_valores', '');
  indicesun := datosdb.openDB('indices_unidades', '');
end;

destructor TTIndicesCreditos.Destroy;
begin
  inherited Destroy;
end;

procedure TTIndicesCreditos.Grabar(xItems, xDescrip: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xItems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('Items').AsString   := xItems;
  tabla.FieldByName('Descrip').AsString := xDescrip;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
end;

procedure TTIndicesCreditos.Grabar(xAnio, xItems, xmes: String; xPromedio: Real);
// Objetivo...: Guardar los Indices
Begin
  if datosdb.Buscar(indices, 'Anio', 'Items', 'Mes', xanio, xitems, xmes) then indices.Edit else indices.Append;
  indices.FieldByName('anio').AsString      := xanio;
  indices.FieldByName('items').AsString     := xitems;
  indices.FieldByName('mes').AsString       := xmes;
  indices.FieldByName('cotizacion').AsFloat := xpromedio;
  try
    indices.Post
   except
    indices.Cancel
  end;
end;

procedure TTIndicesCreditos.Borrar(xItems: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xItems) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('Items').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    datosdb.tranSQL('DELETE FROM indices WHERE items = ' + '"' + xitems + '"');
  end;
end;

function TTIndicesCreditos.Buscar(xItems: string): Boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'Items' then tabla.IndexFieldNames := 'Items';
  if tabla.FindKey([xItems]) then Result := True else Result := False;
end;

procedure  TTIndicesCreditos.getDatos(xItems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xItems) then Begin
    Items   := tabla.FieldByName('Items').AsString;
    Descrip := tabla.FieldByName('Descrip').AsString;
  end else Begin
    Items := ''; Descrip := '';
  end;
end;

function TTIndicesCreditos.setCategorias: TQuery;
// Objetivo...: devolver un set con los categoriaes disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY descrip');
end;

function TTIndicesCreditos.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Result := IntToStr(StrToInt(tabla.FieldByName('Items').AsString) + 1);
end;

procedure TTIndicesCreditos.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexFieldNames := 'Descrip';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado Items Indices de Liquidación', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Items Descripción', 1, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do Begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('Items').AsString >= iniciar) and (tabla.FieldByName('Items').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('Items').AsString < iniciar) or (tabla.FieldByName('Items').AsString > finalizar) then ListLinea(salida);
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

procedure TTIndicesCreditos.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('Items').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'S');
end;

procedure TTIndicesCreditos.ListarIndices(orden, iniciar, finalizar, ent_excl, xanio: string; salida: char);
// Objetivo...: Listar colección de objetos
var
  r: TQuery; i, j: Integer;
begin
  list.ImprimirHorizontal;
  if orden = 'A' then tabla.IndexFieldNames := 'Descrip';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Informe de Cotización de Items e Indices de Liquidación - Año: ' + Copy(utiles.setPeriodoActual, 4, 4), 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Items Descripción', 1, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do Begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('Items').AsString >= iniciar) and (tabla.FieldByName('Items').AsString <= finalizar) then ListLineaIndices(xanio, salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('Items').AsString < iniciar) or (tabla.FieldByName('Items').AsString > finalizar) then ListLineaIndices(xanio, salida);
      // Ordenado Alfabéticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tabla.FieldByName('categoria').AsString >= iniciar) and (tabla.FieldByName('categoria').AsString <= finalizar) then ListLineaIndices(xanio, salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('categoria').AsString < iniciar) or (tabla.FieldByName('categoria').AsString > finalizar) then ListLineaIndices(xanio, salida);

    tabla.Next;
  end;

  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'I N D I C E', 1, 'Arial, normal, 8', salida, 'N');
  r := setIndices(xanio);
  r.Open; i := 1; j := 25;
  while not r.Eof do Begin
    Inc(i);
    j := j + 10;
    list.importe(j, list.Lineactual, '0.000000000', r.FieldByName('Indice').AsFloat, i, 'Arial, normal, 8');
    r.Next;
  end;
  list.Linea(j+8, list.Lineactual, '', i+1, 'Arial, normal, 8', salida, 'S');
  r.Close; r.Free;

  List.FinList;
  tabla.IndexFieldNames := tabla.IndexFieldNames;
  tabla.First;
  list.ImprimirVetical;
end;

procedure TTIndicesCreditos.ListLineaIndices(xanio: String; salida: char);
var
  r: TQuery; i, j: Integer;
begin
  List.Linea(0, 0, tabla.FieldByName('Items').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
  r := setItems(xanio);
  r.Open; i := 1; j := 25;
  while not r.Eof do Begin
    Inc(i);
    j := j + 10;
    list.importe(j, list.Lineactual, '', r.FieldByName('cotizacion').AsFloat, i, 'Arial, normal, 8');
    r.Next;
  end;
  list.Linea(j+8, list.Lineactual, '', i+1, 'Arial, normal, 8', salida, 'S');
  r.Close; r.Free;
end;

procedure TTIndicesCreditos.BuscarPorDescrip(xexpr: string);
begin
  tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTIndicesCreditos.BuscarPorId(xexpr: string);
begin
  tabla.IndexFieldNames := 'Items';
  tabla.FindNearest([xexpr]);
end;

function  TTIndicesCreditos.setItems(xanio: String): TQuery;
// Objetivo...: Devolver Items Indices
Begin
  Result := datosdb.tranSQL('SELECT * FROM indices_valores WHERE anio = ' + '"' + xanio + '"' + ' AND items = ' + '"' + tabla.FieldByName('items').AsString + '"' + ' ORDER BY mes')
end;

procedure TTIndicesCreditos.GrabarIndices(xAnio, xmes: String; xIndice: Real);
// Objetivo...: Guardar Indices
Begin
  if datosdb.Buscar(indicesun, 'Anio', 'Mes', xanio, xmes) then indicesun.Edit else indicesun.Append;
  indicesun.FieldByName('anio').AsString  := xanio;
  indicesun.FieldByName('mes').AsString   := xmes;
  indicesun.FieldByName('indice').AsFloat := xindice;
  try
    indicesun.Post
   except
    indicesun.Cancel
  end;
end;

procedure TTIndicesCreditos.getIndices(xAnio, xMes: String);
// Objetivo...: Devolver Indices
Begin
  if datosdb.Buscar(indicesun, 'Anio', 'Mes', xanio, xmes) then Begin
    Indice := indicesun.FieldByName('indice').AsFloat;
  end else Begin
    Indice := 0; Promedio := 0;
  end;
end;

function  TTIndicesCreditos.setIndices(xanio: String): TQuery;
// Objetivo...: Devolver Items Indices
Begin
  Result := datosdb.tranSQL('SELECT * FROM indices_unidades WHERE anio = ' + '"' + xanio + '"' + ' ORDER BY mes')
end;

function  TTIndicesCreditos.setIndice(xAnio, xItems, xmes: String): Real;
// Objetivo...: Devolver el valor del indice
Begin
  if datosdb.Buscar(indices, 'Anio', 'Items', 'Mes', xanio, xitems, xmes) then Result := indices.FieldByName('cotizacion').AsFloat else Result := 0;
end;

procedure TTIndicesCreditos.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('Items').DisplayLabel := 'Items'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción';
    if not indices.Active then indices.Open;
    if not indicesun.Active then indicesun.Open;
  end;
  Inc(conexiones);
end;

procedure TTIndicesCreditos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(indices);
    datosdb.closeDB(indicesun);
  end;
end;

{===============================================================================}

function indice: TTIndicesCreditos;
begin
  if xindice = nil then
    xindice := TTIndicesCreditos.Create;
  Result := xindice;
end;

{===============================================================================}

initialization

finalization
  xindice.Free;

end.
