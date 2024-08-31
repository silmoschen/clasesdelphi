unit CProductosDamevin;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar;

type

TTProductos = class(TObject)
  idproducto, idvariante, Descrip, Desvariant: string; precio, preunit: real;
  tabla, variante: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xidproducto, xDescrip: string; xprecio: real); overload;
  procedure   Grabar(xidproducto, xidvariante, xDescrip: string; xpreunit: real); overload;
  procedure   Borrar(xidproducto: string); overload;
  procedure   Borrar(xidproducto, xidvariante: string); overload;
  function    Buscar(xidproducto: string): boolean; overload;
  function    Buscar(xidproducto, xidvariante: string): boolean; overload;
  procedure   getDatos(xidproducto: string); overload;
  procedure   getDatos(xidproducto, xidvariante: string); overload;
  function    setproductos: TQuery;
  function    setVariantes: TQuery;
  procedure   FiltrarVariantes;
  procedure   BuscarPorId(xexpr: string);
  procedure   BuscarPorDescrip(xexpr: string);

  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint; r: TQuery;
  procedure   ListarLinea(salida: char);
  { Declaraciones Privadas }
end;

function producto: TTProductos;

implementation

var
  xcomprob: TTProductos = nil;

constructor TTProductos.Create;
begin
  inherited Create;
  tabla    := datosdb.openDB('productos', 'idproducto');
  variante := datosdb.openDB('varprod', 'idproducto;idvariante');
end;

destructor TTProductos.Destroy;
begin
  inherited Destroy;
end;

procedure TTProductos.Grabar(xidproducto, xdescrip: string; xprecio: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidproducto) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idproducto').AsString := xidproducto;
  tabla.FieldByName('descrip').AsString    := xdescrip;
  tabla.FieldByName('precio').AsFloat      := xprecio;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
end;

procedure TTProductos.Grabar(xidproducto, xidvariante, xdescrip: string; xpreunit: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidproducto, xidvariante) then variante.Edit else variante.Append;
  variante.FieldByName('idproducto').AsString := xidproducto;
  variante.FieldByName('idvariante').AsString := xidvariante;
  variante.FieldByName('descrip').AsString    := xdescrip;
  variante.FieldByName('precio').AsFloat      := xpreunit;
  try
    variante.Post
  except
    variante.Cancel
  end;
end;

procedure TTProductos.Borrar(xidproducto: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xidproducto) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('idproducto').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

procedure TTProductos.Borrar(xidproducto, xidvariante: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xidproducto, xidvariante) then
    begin
      variante.Delete;
      getDatos(variante.FieldByName('idproducto').AsString, variante.FieldByName('idvariante').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTProductos.Buscar(xidproducto: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'Idproducto' then tabla.IndexFieldNames := 'Idproducto';
  if tabla.FindKey([xidproducto]) then Result := True else Result := False;
end;

function TTProductos.Buscar(xidproducto, xidvariante: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  Result := datosdb.Buscar(variante, 'idproducto', 'idvariante', xidproducto, xidvariante);
end;

procedure  TTProductos.getDatos(xidproducto: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xidproducto) then
    begin
      idproducto := tabla.FieldByName('idproducto').AsString;
      descrip    := tabla.FieldByName('descrip').AsString;
      precio     := tabla.FieldByName('precio').AsFloat;
    end
   else
    begin
      idproducto := xidproducto; descrip := ''; precio := 0;
    end;
end;

procedure  TTProductos.getDatos(xidproducto, xidvariante: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  variante.Refresh;
  if Buscar(xidproducto, xidvariante) then
    begin
      idproducto := variante.FieldByName('idproducto').AsString;
      idvariante := variante.FieldByName('idvariante').AsString;
      desvariant := variante.FieldByName('descrip').AsString;
      preunit    := variante.FieldByName('precio').AsFloat;
    end
   else
    begin
      idproducto := ''; idvariante := ''; desvariant := ''; preunit := 0;
    end;
end;

function TTProductos.setproductos: TQuery;
// Objetivo...: devolver un set con los sabores disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY descrip');
end;

function TTProductos.setVariantes: TQuery;
// Objetivo...: devolver un set con los sabores disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + variante.TableName + ' ORDER BY idproducto, idvariante');
end;

function TTProductos.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Result := IntToStr(StrToInt(tabla.FieldByName('idproducto').AsString) + 1);
end;

procedure TTProductos.FiltrarVariantes;
// Objetivo...: Filtrar Variantes
begin
  datosdb.Filtrar(variante, 'Idproducto = ' + '''' + idproducto + '''');
end;

procedure TTProductos.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  r := setVariantes; r.Open;
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado Tabla de productos ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.  Producto', 1, 'Courier New, cursiva, 9');
  List.Titulo(79, list.Lineactual, 'Precio', 2, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('idproducto').AsString >= iniciar) and (tabla.FieldByName('idproducto').AsString <= finalizar) then ListarLinea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('idproducto').AsString < iniciar) or (tabla.FieldByName('idproducto').AsString > finalizar) then ListarLinea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString >= iniciar) and (tabla.FieldByName('descrip').AsString <= finalizar) then ListarLinea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString < iniciar) or (tabla.FieldByName('descrip').AsString > finalizar) then ListarLinea(salida);

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First; r.Close;
end;

procedure TTProductos.ListarLinea(salida: char);
var
  t: boolean;
begin
  r.First; t := False;
  List.Linea(0, 0, tabla.FieldByName('idproducto').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, negrita, 10', salida, 'S');
  List.importe(85, list.Lineactual, '', tabla.FieldByName('precio').AsFloat, 2, 'Courier New, negrita, 10');
  List.Linea(90, list.Lineactual, ' ', 3, 'Courier New, negrita, 10', salida, 'S');
  while not r.EOF do Begin
    if r.FieldByName('idproducto').AsString = tabla.FieldByName('idproducto').AsString then Begin
      List.Linea(0, 0, '           ' + r.FieldByName('idvariante').AsString + '   ' + r.FieldByName('descrip').AsString, 1, 'Courier New, normal, 8', salida, 'S');
      List.importe(90, list.Lineactual, '', r.FieldByName('precio').AsFloat, 2, 'Courier New, normal, 8');
      List.Linea(90, list.Lineactual, ' ', 3, 'Courier New, normal, 8', salida, 'S');
      t := True;
    end;
    r.Next;
  end;
  if t then List.Linea(0, 0, '  ', 1, 'Courier New, normal, 8', salida, 'S');
end;

procedure TTProductos.BuscarPorId(xexpr: string);
begin
  tabla.IndexFieldNames := 'Idproducto';
  tabla.FindNearest([xexpr]);
end;

procedure TTProductos.BuscarPorDescrip(xexpr: string);
begin
  tabla.IndexName := 'Productos_Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTProductos.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('idproducto').DisplayLabel := 'Id. producto'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción'; tabla.FieldByName('precio').DisplayLabel := 'Precio';
    if not variante.Active then variante.Open;
    variante.FieldByName('idproducto').Visible := False; variante.FieldByName('idvariante').DisplayLabel := 'Id';
    variante.FieldByName('idvariante').DisplayLabel := 'Id.'; variante.FieldByName('descrip').DisplayLabel := 'Descripción'; variante.FieldByName('precio').DisplayLabel := 'Precio';
  end;
  Inc(conexiones);
end;

procedure TTProductos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(variante);
  end;
end;

{===============================================================================}

function producto: TTProductos;
begin
  if xcomprob = nil then
    xcomprob := TTProductos.Create;
  Result := xcomprob;
end;

{===============================================================================}

initialization

finalization
  xcomprob.Free;

end.
