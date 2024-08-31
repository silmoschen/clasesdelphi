unit CAjustesIndivCentroBioq;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar, CUsuario;

type

TTAjustesIndividuales = class(TObject)
  Items, Descrip: String; Importe: Real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xitems, xDescrip: String; xImporte: Real);
  procedure   Borrar(xitems: string);
  function    Buscar(xitems: string): boolean;
  procedure   getDatos(xitems: string);
  function    setItems: TQuery;
  function    Nuevo: String;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorItems(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  DBConexion: String;
  procedure   ListLinea(salida: char);
  { Declaraciones Privadas }
end;

function ajustesindiv: TTAjustesIndividuales;

implementation

var
  xajustesindiv: TTAjustesIndividuales = nil;

constructor TTAjustesIndividuales.Create;
begin
  inherited Create;
  if dbs.BaseClientServ = 'N' then DBConexion := dbs.DirSistema + '\archdat' else DBConexion := dbs.baseDat;
  tabla := datosdb.openDB('ajustesindi', 'Items',  '', DBConexion);
end;

destructor TTAjustesIndividuales.Destroy;
begin
  inherited Destroy;
end;

procedure TTAjustesIndividuales.Grabar(xItems, xDescrip: String; xImporte: Real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xItems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('Items').AsString   := xItems;
  tabla.FieldByName('Descrip').AsString := xDescrip;
  tabla.FieldByName('Importe').AsFloat  := xImporte;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
end;

procedure TTAjustesIndividuales.Borrar(xItems: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xItems) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('Items').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTAjustesIndividuales.Buscar(xItems: string): Boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'Items' then tabla.IndexFieldNames := 'Items';
  if tabla.FindKey([xitems]) then Result := True else Result := False;
end;

procedure  TTAjustesIndividuales.getDatos(xitems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xitems) then Begin
    items   := tabla.FieldByName('items').AsString;
    descrip := tabla.FieldByName('descrip').AsString;
    Importe := tabla.FieldByName('Importe').AsFloat;
  end else Begin
    items := ''; descrip := ''; Importe := 0;
  end;
end;

function TTAjustesIndividuales.setItems: TQuery;
// Objetivo...: devolver un set con los items disponibles
begin
  Result := datosdb.tranSQL(DBConexion, 'SELECT * FROM ' + tabla.TableName + ' ORDER BY Descrip');
end;

function TTAjustesIndividuales.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Result := IntToStr(StrToInt(tabla.FieldByName('items').AsString) + 1);
end;

procedure TTAjustesIndividuales.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Tabla de ajustesindiv', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Items    Descripción', 1, 'Arial, cursiva, 8');
  List.Titulo(84, 0, 'Importe Fijo', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('items').AsString >= iniciar) and (tabla.FieldByName('items').AsString <= finalizar) then ListLinea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('items').AsString < iniciar) or (tabla.FieldByName('items').AsString > finalizar) then ListLinea(salida);
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

procedure TTAjustesIndividuales.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('items').AsString + '         ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Importe(90, List.lineactual, '', tabla.FieldByName('Importe').AsFloat, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
end;

procedure TTAjustesIndividuales.BuscarPorDescrip(xexpr: string);
begin
  tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTAjustesIndividuales.BuscarPorItems(xexpr: string);
begin
  tabla.IndexFieldNames := 'items';
  tabla.FindNearest([xexpr]);
end;

procedure TTAjustesIndividuales.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('items').DisplayLabel := 'Items'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción'; tabla.FieldByName('Importe').DisplayLabel := 'Importe';
  end;
  Inc(conexiones);
end;

procedure TTAjustesIndividuales.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function ajustesindiv: TTAjustesIndividuales;
begin
  if xajustesindiv = nil then
    xajustesindiv := TTAjustesIndividuales.Create;
  Result := xajustesindiv;
end;

{===============================================================================}

initialization

finalization
  xajustesindiv.Free;

end.
