unit CItemsGastosFijosAsociacion;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar;

type

TTItemsGastosFijos = class(TObject)
  Items, Descrip: String; Monto: Real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Guardar(xitems, xdescrip: String; xmonto: Real);
  procedure   Borrar(xitems: string);
  function    Buscar(xitems: string): Boolean;
  procedure   getDatos(xitems: string);
  function    setItems: TQuery;
  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorId(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  procedure   ListLinea(salida: char);
  { Declaraciones Privadas }
end;

function gastosFijos: TTItemsGastosFijos;

implementation

var
  xgastosFijos: TTItemsGastosFijos = nil;

constructor TTItemsGastosFijos.Create;
begin
  inherited Create;
  tabla  := datosdb.openDB('itemsgastos', '');
end;

destructor TTItemsGastosFijos.Destroy;
begin
  inherited Destroy;
end;

procedure TTItemsGastosFijos.Guardar(xitems, xdescrip: String; xmonto: Real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xitems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('items').AsString   := xitems;
  tabla.FieldByName('descrip').AsString := xdescrip;
  tabla.FieldByName('monto').AsFloat    := xmonto;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
end;

procedure TTItemsGastosFijos.Borrar(xItems: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xItems) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('Items').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTItemsGastosFijos.Buscar(xItems: string): Boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'Items' then tabla.IndexFieldNames := 'Items';
  if tabla.FindKey([xItems]) then Result := True else Result := False;
end;

procedure  TTItemsGastosFijos.getDatos(xItems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xItems) then Begin
    Items   := tabla.FieldByName('Items').AsString;
    Descrip := tabla.FieldByName('Descrip').AsString;
    Monto   := tabla.FieldByName('monto').AsFloat;
  end else Begin
    Items := ''; Descrip := ''; Monto := 0;
  end;
end;

function TTItemsGastosFijos.setItems: TQuery;
// Objetivo...: devolver un set con los gastosFijoses disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY descrip');
end;

function TTItemsGastosFijos.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Result := IntToStr(StrToInt(tabla.FieldByName('Items').AsString) + 1);
end;

procedure TTItemsGastosFijos.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexFieldNames := 'Descrip';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado Items de Gastos Fijos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Items Descripción', 1, 'Arial, cursiva, 8');
  List.Titulo(80, list.Lineactual, 'Monto', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('Items').AsString >= iniciar) and (tabla.FieldByName('Items').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('Items').AsString < iniciar) or (tabla.FieldByName('Items').AsString > finalizar) then ListLinea(salida);
    // Ordenado Alfabéticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tabla.FieldByName('descrip').AsString >= iniciar) and (tabla.FieldByName('descrip').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('descrip').AsString < iniciar) or (tabla.FieldByName('descrip').AsString > finalizar) then ListLinea(salida);

    tabla.Next;
  end;
  List.FinList;

  tabla.IndexFieldNames := tabla.IndexFieldNames;
  tabla.First;
end;

procedure TTItemsGastosFijos.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('items').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Importe(85, list.Lineactual, '', tabla.FieldByName('monto').AsFloat, 2, 'Arial, normal, 8');
  List.Linea(86, list.Lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
end;

procedure TTItemsGastosFijos.BuscarPorDescrip(xexpr: string);
begin
  tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTItemsGastosFijos.BuscarPorId(xexpr: string);
begin
  tabla.IndexFieldNames := 'Items';
  tabla.FindNearest([xexpr]);
end;

procedure TTItemsGastosFijos.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('Items').DisplayLabel := 'Items'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción'; tabla.FieldByName('monto').DisplayLabel := 'Porcentaje';
  end;
  Inc(conexiones);
end;

procedure TTItemsGastosFijos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function gastosFijos: TTItemsGastosFijos;
begin
  if xgastosFijos = nil then
    xgastosFijos := TTItemsGastosFijos.Create;
  Result := xgastosFijos;
end;

{===============================================================================}

initialization

finalization
  xgastosFijos.Free;

end.
