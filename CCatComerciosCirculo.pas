unit CCatComerciosCirculo;

interface

uses SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM;

type

TTCatComercios = class(TObject)
  Idcategoria, Categoria, DesRet: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;

  procedure   Grabar(xidcategoria, xcategoria, xdesret: string);
  procedure   Borrar(xidcategoria: string);
  function    Buscar(xidcategoria: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xidcategoria: string);
  function    setCategorias: TQuery;

  procedure   BuscarPorId(xexpr: String);
  procedure   BuscarPorNombre(xexpr: String);

  procedure   conectar;
  procedure   desconectar;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure linea(salida: char);
end;

function catcom: TTCatComercios;

implementation

var
  xcatcom: TTCatComercios = nil;

constructor TTCatComercios.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('catcom', 'idcategoria');
end;

destructor TTCatComercios.Destroy;
begin
  inherited Destroy;
end;

procedure TTCatComercios.Grabar(xidcategoria, xcategoria, xdesret: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidcategoria) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idcategoria').AsString := xidcategoria;
  tabla.FieldByName('categoria').AsString   := xcategoria;
  tabla.FieldByName('retdes').AsString      := xdesret;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTCatComercios.Borrar(xidcategoria: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xidcategoria) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('idcategoria').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTCatComercios.Buscar(xidcategoria: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'idcategoria' then tabla.IndexFieldNames := 'idcategoria';
  if tabla.FindKey([xidcategoria]) then Result := True else Result := False;
end;

procedure  TTCatComercios.getDatos(xidcategoria: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xidcategoria) then Begin
    idcategoria := tabla.FieldByName('idcategoria').AsString;
    categoria   := tabla.FieldByName('categoria').AsString;
    desret      := tabla.FieldByName('retdes').AsString;
  end else Begin
    idcategoria := ''; categoria := ''; desret := 'N';
  end;
end;

function TTCatComercios.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  if tabla.IndexFieldNames <> 'idcategoria' then tabla.IndexFieldNames := 'idcategoria';
  tabla.Refresh; tabla.Last;
  if tabla.RecordCount > 0 then Result := IntToStr(tabla.FieldByName('idcategoria').AsInteger + 1) else Result := '1';
end;

function TTCatComercios.setCategorias: TQuery;
// Objetivo...: devolver un set de registros con las distintas categorías
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY categoria');
end;

procedure TTCatComercios.BuscarPorId(xexpr: String);
begin
  if tabla.IndexFieldNames <> 'idcategoria' then tabla.IndexFieldNames := 'idcategoria';
  tabla.FindNearest([xexpr]);
end;

procedure TTCatComercios.BuscarPorNombre(xexpr: String);
begin
  if tabla.IndexFieldNames <> 'categoria' then tabla.IndexFieldNames := 'Categoria';
  tabla.FindNearest([xexpr]);
end;

procedure TTCatComercios.linea(salida: char);
// Objetivo...: Emitir una Línea de detalle
begin
  List.Linea(0, 0, tabla.FieldByName('idcategoria').AsString + '     ' + tabla.FieldByName('categoria').AsString, 1, 'Courier New, normal, 9', salida, 'S');
end;

procedure TTCatComercios.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tabla.IndexFieldNames := 'Categoria';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Categorías de Comercios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.   Categoría Comercio', 1, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('idcategoria').AsString >= iniciar) and (tabla.FieldByName('idcategoria').AsString <= finalizar) then linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('codprovin').AsString < iniciar) or (tabla.FieldByName('idcategoria').AsString > finalizar) then linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('categoria').AsString >= iniciar) and (tabla.FieldByName('categoria').AsString <= finalizar) then linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('categoria').AsString < iniciar) or (tabla.FieldByName('categoria').AsString > finalizar) then linea(salida);

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTCatComercios.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('idcategoria').DisplayLabel := 'Cód.'; tabla.FieldByName('categoria').DisplayLabel := 'Descripción'; tabla.FieldByName('retdes').DisplayLabel := 'NRD';
  end;
  Inc(conexiones);
end;

procedure TTCatComercios.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function catcom: TTCatComercios;
begin
  if xcatcom = nil then
    xcatcom := TTCatComercios.Create;
  Result := xcatcom;
end;

{===============================================================================}

initialization

finalization
  xcatcom.Free;

end.
