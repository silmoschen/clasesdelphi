unit CArticulosCCE;

interface

uses CCRubrosCCE, SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar, Forms;

type

TTArticulos = class(TObject)
  Codart, Descrip, Idrubro, Retiva: string; Precio, PrecioNS, Costo, CostoNS: Real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodart, xdescrip, xidrubro, xretiva: string; xprecio, xprecions, xcosto, xcostons: real);
  procedure   Borrar(xcodart: string);
  function    Buscar(xcodart: string): boolean;
  procedure   getDatos(xcodart: string);
  function    setArticulos: TQuery;
  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorId(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  procedure   ListLinea(xidrubro, xorden: String; salida: char);
  procedure   Enccol;
  { Declaraciones Privadas }
end;

function articulo: TTArticulos;

implementation

var
  xarticulo: TTArticulos = nil;

constructor TTArticulos.Create;
begin
  tabla := datosdb.openDB('articulos', '');
end;

destructor TTArticulos.Destroy;
begin
  inherited Destroy;
end;

procedure TTArticulos.Grabar(xcodart, xdescrip, xidrubro, xretiva: string; xprecio, xprecions, xcosto, xcostons: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodart) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codart').AsString   := xcodart;
  tabla.FieldByName('descrip').AsString  := xdescrip;
  tabla.FieldByName('idrubro').AsString  := xidrubro;
  tabla.FieldByName('retiva').AsString   := xretiva;
  tabla.FieldByName('precio').AsFloat    := xprecio;
  tabla.FieldByName('precions').AsFloat  := xprecions;
  tabla.FieldByName('costo').AsFloat     := xcosto;
  tabla.FieldByName('costons').AsFloat   := xcostons;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
end;

procedure TTArticulos.Borrar(xcodart: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodart) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('codart').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTArticulos.Buscar(xcodart: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then Begin
    tabla.Open;
    Enccol;
  end;
  tabla.Refresh;
  if tabla.IndexFieldNames <> 'Codart' then tabla.IndexFieldNames := 'Codart';
  if tabla.FindKey([xcodart]) then Result := True else Result := False;
end;

procedure  TTArticulos.getDatos(xcodart: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcodart) then Begin
    codart   := tabla.FieldByName('codart').AsString;
    descrip  := tabla.FieldByName('descrip').AsString;
    idrubro  := tabla.FieldByName('idrubro').AsString;
    retiva   := tabla.FieldByName('retiva').AsString;
    Precio   := tabla.FieldByName('precio').AsFloat;
    Precions := tabla.FieldByName('precions').AsFloat;
    Costo    := tabla.FieldByName('costo').AsFloat;
    CostoNS  := tabla.FieldByName('costons').AsFloat;
  end else Begin
    codart := ''; descrip := ''; idrubro := ''; precio := 0; retiva := ''; precions := 0; costo := 0; costons := 0;
  end;
end;

function TTArticulos.setArticulos: TQuery;
// Objetivo...: devolver un set con los categoriaes disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY descrip');
end;

function TTArticulos.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  if tabla.IndexFieldNames <> 'Codart' then tabla.IndexFieldNames := 'Codart';
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Result := IntToStr(StrToInt(tabla.FieldByName('codart').AsString) + 1);
end;

procedure TTArticulos.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
var
  r: TQuery;
begin
  if orden = 'A' then r := rubro.setRubrosAlf else r := rubro.setRubros;
  if orden = 'A' then tabla.IndexFieldNames := 'descrip' else tabla.IndexFieldNames := 'codart';
  r.Open;

  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Artículos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, '     Cód.  Artículo', 1, 'Arial, cursiva, 8');
  List.Titulo(55, list.Lineactual, 'Precio', 2, 'Arial, cursiva, 8');
  List.Titulo(62, list.Lineactual, 'Precio NS', 3, 'Arial, cursiva, 8');
  List.Titulo(75, list.Lineactual, 'P. Costo', 4, 'Arial, cursiva, 8');
  List.Titulo(84, list.Lineactual, 'P. Costo NS', 5, 'Arial, cursiva, 8');
  List.Titulo(95, list.Lineactual, 'RI', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  r.First;
  while not r.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (r.FieldByName('idrubro').AsString >= iniciar) and (r.FieldByName('idrubro').AsString <= finalizar) then ListLinea(r.FieldByName('idrubro').AsString, orden, salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (r.FieldByName('idrubro').AsString < iniciar) or (r.FieldByName('idrubro').AsString > finalizar) then ListLinea(r.FieldByName('idrubro').AsString, orden, salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (r.FieldByName('descrip').AsString >= iniciar) and (r.FieldByName('descrip').AsString <= finalizar) then ListLinea(r.FieldByName('idrubro').AsString, orden, salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (r.FieldByName('descrip').AsString < iniciar) or (r.FieldByName('descrip').AsString > finalizar) then ListLinea(r.FieldByName('idrubro').AsString, orden, salida);

      r.Next;
    end;

  tabla.IndexFieldNames := 'codart';
  List.FinList;
end;

procedure TTArticulos.ListLinea(xidrubro, xorden: String; salida: char);
begin
  rubro.getDatos(xidrubro);
  List.Linea(0, 0, 'Rubro:  ' +  xidrubro + '  ' + rubro.Descrip, 1, 'Arial, negrita, 9', salida, 'S');
  datosdb.Filtrar(tabla, 'idrubro = ' + '''' + xidrubro + '''');
  tabla.First;
  while not tabla.Eof do Begin
    List.Linea(0, 0, '     ' + tabla.FieldByName('codart').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
    List.importe(60, List.lineactual, '', tabla.FieldByName('precio').AsFloat, 2, 'Arial, normal, 8');
    List.importe(70, List.lineactual, '', tabla.FieldByName('precions').AsFloat, 3, 'Arial, normal, 8');
    List.importe(82, List.lineactual, '', tabla.FieldByName('costo').AsFloat, 4, 'Arial, normal, 8');
    List.importe(94, List.lineactual, '', tabla.FieldByName('costons').AsFloat, 5, 'Arial, normal, 8');
    List.Linea(95, list.lineactual, tabla.FieldByName('retiva').AsString, 6, 'Arial, normal, 8', salida, 'S');
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);
  List.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
end;

procedure TTArticulos.BuscarPorDescrip(xexpr: string);
begin
  tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTArticulos.BuscarPorId(xexpr: string);
begin
  tabla.IndexFieldNames := 'Codart';
  tabla.FindNearest([xexpr]);
end;

procedure TTArticulos.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  rubro.conectar;
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    Enccol;
  end;
  Inc(conexiones);
end;

procedure TTArticulos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  rubro.desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

procedure TTArticulos.Enccol;
// Objetivo...: cerrar tablas de persistencia
begin
  tabla.FieldByName('codart').DisplayLabel := 'Cód.'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción';
  tabla.FieldByName('idrubro').DisplayLabel := 'Id.Rubro'; tabla.FieldByName('precio').DisplayLabel := 'Precio';
  tabla.FieldByName('precions').DisplayLabel := 'Precio NS'; tabla.FieldByName('retiva').DisplayLabel := 'Ret. I.V.A.';
  tabla.FieldByName('costo').DisplayLabel := 'P. Costo'; tabla.FieldByName('costons').DisplayLabel := 'P. Costo NS';
end;

{===============================================================================}

function articulo: TTArticulos;
begin
  if xarticulo = nil then
    xarticulo := TTArticulos.Create;
  Result := xarticulo;
end;

{===============================================================================}

initialization

finalization
  xarticulo.Free;

end.
