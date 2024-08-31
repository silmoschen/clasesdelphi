unit CDiagnosticosCCB;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar, CDiagnosticosCCBOMS;

type

TTDiagnosticos = class(TObject)
  Items, Descrip, Codigo: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xItems, xDescrip, xcodigo: string);
  procedure   Borrar(xItems: string);
  function    Buscar(xItems: string): boolean;
  procedure   getDatos(xItems: string);
  function    setDescripes: TQuery;
  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorId(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  conexion: String;
  procedure   ListLinea(salida: char);
  { Declaraciones Privadas }
end;

function diagnostico: TTDiagnosticos;

implementation

var
  xdiagnostico: TTDiagnosticos = nil;

constructor TTDiagnosticos.Create;
begin
  inherited Create;
  dbs.getParametrosDB1;     // Base de datos adicional 1
  if Length(Trim(dbs.db1)) > 0 then Begin
    dbs.NuevaBaseDeDatos(dbs.db1, dbs.us1, dbs.pa1);
    conexion := dbs.baseDat_N;
  end else
    conexion := dbs.DirSistema + '\auditoria';

  tabla := datosdb.openDB('Diagnosticos', 'Items', '', conexion);
end;

destructor TTDiagnosticos.Destroy;
begin
  inherited Destroy;
end;

procedure TTDiagnosticos.Grabar(xItems, xDescrip, xcodigo: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xItems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('Items').AsString   := xItems;
  tabla.FieldByName('Descrip').AsString := xDescrip;
  tabla.FieldByName('codigo').AsString  := xcodigo;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTDiagnosticos.Borrar(xItems: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xItems) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('Items').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTDiagnosticos.Buscar(xItems: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'Items' then tabla.IndexFieldNames := 'Items';
  if tabla.FindKey([xItems]) then Result := True else Result := False;
end;

procedure  TTDiagnosticos.getDatos(xItems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xItems) then Begin
    Items   := tabla.FieldByName('Items').AsString;
    Descrip := tabla.FieldByName('Descrip').AsString;
    Codigo  := tabla.FieldByName('codigo').AsString;
  end else Begin
    Items := ''; Descrip := ''; codigo := '';
  end;
end;

function TTDiagnosticos.setDescripes: TQuery;
// Objetivo...: devolver un set con los Descripes disponibles
begin
  Result := datosdb.tranSQL(conexion, 'SELECT * FROM ' + tabla.TableName + ' ORDER BY Descrip');
end;

function TTDiagnosticos.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.IndexFieldNames := 'Items';
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Result := IntToStr(StrToInt(tabla.FieldByName('Items').AsString) + 1);
end;

procedure TTDiagnosticos.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  list.Setear(salida); 
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Diagnósticos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Items Descripción', 1, 'Arial, cursiva, 8');
  List.Titulo(88, list.Lineactual, 'Cód. O.M.S.', 2, 'Arial, cursiva, 8');
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
      if (tabla.FieldByName('Descrip').AsString >= iniciar) and (tabla.FieldByName('Descrip').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('Descrip').AsString < iniciar) or (tabla.FieldByName('Descrip').AsString > finalizar) then ListLinea(salida);

    tabla.Next;
  end;
  List.FinList;

  tabla.IndexFieldNames := tabla.IndexFieldNames;
  tabla.First;
end;

procedure TTDiagnosticos.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('Items').AsString + '   ' + tabla.FieldByName('Descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(95, list.lineactual, tabla.FieldByName('codigo').AsString, 2, 'Arial, normal, 8', salida, 'S');
end;

procedure TTDiagnosticos.BuscarPorDescrip(xexpr: string);
begin
  tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTDiagnosticos.BuscarPorId(xexpr: string);
begin
  tabla.IndexFieldNames := 'Items';
  tabla.FindNearest([xexpr]);
end;

procedure TTDiagnosticos.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('Items').DisplayLabel := 'Items'; tabla.FieldByName('Descrip').DisplayLabel := 'Descripción';
    tabla.FieldByName('codigo').DisplayLabel := 'Código';
  end;
  Inc(conexiones);
  diagnosticooms.conectar;
end;

procedure TTDiagnosticos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
  diagnosticooms.desconectar;
end;

{===============================================================================}

function diagnostico: TTDiagnosticos;
begin
  if xDiagnostico = nil then
    xDiagnostico := TTDiagnosticos.Create;
  Result := xDiagnostico;
end;

{===============================================================================}

initialization

finalization
  xDiagnostico.Free;

end.
