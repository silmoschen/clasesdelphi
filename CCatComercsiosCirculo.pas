unit CCatComercsiosCirculo;

interface

uses SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM;

type

TTCatSocios = class(TObject)
  codcat, categoria, descrip: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xcodcat, xcategoria, xdescrip: string);

  procedure   Grabar(xcodcat, xcategoria, xdescrip: string);
  procedure   Borrar(xcodcat: string);
  function    Buscar(xcodcat: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xcodcat: string);
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

function catsoc: TTCatSocios;

implementation

var
  xcatsoc: TTCatSocios = nil;

constructor TTCatSocios.Create(xcodcat, xcategoria, xdescrip: string);
begin
  inherited Create;
  codcat    := xcodcat;
  categoria := xcategoria;
  descrip   := xdescrip;

  tabla := datosdb.openDB('catsoc', 'codcat');
end;

destructor TTCatSocios.Destroy;
begin
  inherited Destroy;
end;

procedure TTCatSocios.Grabar(xcodcat, xcategoria, xdescrip: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodcat) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codcat').AsString    := xcodcat;
  tabla.FieldByName('categoria').AsString := xcategoria;
  tabla.FieldByName('descrip').AsString   := xdescrip;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTCatSocios.Borrar(xcodcat: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodcat) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('codcat').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTCatSocios.Buscar(xcodcat: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'codcat' then tabla.IndexFieldNames := 'codcat';
  if tabla.FindKey([xcodcat]) then Result := True else Result := False;
end;

procedure  TTCatSocios.getDatos(xcodcat: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xcodcat) then
    begin
      codcat    := tabla.FieldByName('codcat').AsString;
      categoria := tabla.FieldByName('categoria').AsString;
      descrip   := tabla.FieldByName('descrip').AsString;
    end
   else
    begin
      codcat := ''; descrip := ''; categoria := '';
    end;
end;

function TTCatSocios.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  if tabla.IndexFieldNames <> 'Codcat' then tabla.IndexFieldNames := 'Codcat';
  tabla.Refresh; tabla.Last;
  if tabla.RecordCount > 0 then Result := IntToStr(tabla.FieldByName('codcat').AsInteger + 1) else Result := '1';
end;

function TTCatSocios.setCategorias: TQuery;
// Objetivo...: devolver un set de registros con las distintas categorías
begin
  Result := datosdb.tranSQL('SELECT codcat, categoria, descrip FROM catsoc ORDER BY categoria');
end;

procedure TTCatSocios.BuscarPorId(xexpr: String);
begin
  if tabla.IndexFieldNames <> 'Codcat' then tabla.IndexFieldNames := 'Codcat';
  tabla.FindNearest([xexpr]);
end;

procedure TTCatSocios.BuscarPorNombre(xexpr: String);
begin
  if tabla.IndexName <> 'categoria' then tabla.IndexName := 'Categoria';
  tabla.FindNearest([xexpr]);
end;

procedure TTCatSocios.linea(salida: char);
// Objetivo...: Emitir una Línea de detalle
begin
  List.Linea(0, 0, tabla.FieldByName('codcat').AsString + '     ' + tabla.FieldByName('categoria').AsString, 1, 'Courier New, normal, 9', salida, 'N');
  List.Linea(40, list.lineactual, tabla.FieldByName('descrip').AsString, 2, 'Courier New, normal, 9', salida, 'S');
end;

procedure TTCatSocios.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Categorías de Socios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.   Categ.', 1, 'Courier New, cursiva, 9');
  List.Titulo(40, list.Lineactual, 'Descripción', 2, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('codcat').AsString >= iniciar) and (tabla.FieldByName('codcat').AsString <= finalizar) then linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('codprovin').AsString < iniciar) or (tabla.FieldByName('codcat').AsString > finalizar) then linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString >= iniciar) and (tabla.FieldByName('descrip').AsString <= finalizar) then linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString < iniciar) or (tabla.FieldByName('descrip').AsString > finalizar) then linea(salida);

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTCatSocios.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('codcat').DisplayLabel := 'Cód.'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción';
  end;
  Inc(conexiones);
end;

procedure TTCatSocios.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function catsoc: TTCatSocios;
begin
  if xcatsoc = nil then
    xcatsoc := TTCatSocios.Create('', '', '');
  Result := xcatsoc;
end;

{===============================================================================}

initialization

finalization
  xcatsoc.Free;

end.
