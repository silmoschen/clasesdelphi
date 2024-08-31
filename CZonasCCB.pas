unit CZonasCCB;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar;

type

TTZonas = class(TObject)
  Idzona, Zona: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xIdzona, xZona: string);
  procedure   Borrar(xIdzona: string);
  function    Buscar(xIdzona: string): boolean;
  procedure   getDatos(xIdzona: string);
  function    setZonaes: TQuery;
  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorZona(xexpr: string);
  procedure   BuscarPorId(xexpr: string);

  procedure   ExportarZonasXML;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  conexion: String;
  procedure   ListLinea(salida: char);
  { Declaraciones Privadas }
end;

function zonas: TTZonas;

implementation

var
  xzona: TTZonas = nil;

constructor TTZonas.Create;
begin
  inherited Create;
  dbs.getParametrosDB1;     // Base de datos adicional 1
  if Length(Trim(dbs.db1)) > 0 then Begin
    dbs.NuevaBaseDeDatos(dbs.db1, dbs.us1, dbs.pa1);
    conexion := dbs.baseDat_N;
  end else
    conexion := dbs.DirSistema + '\auditoria';

  tabla := datosdb.openDB('Zonas', 'Idzona', '', conexion);
end;

destructor TTZonas.Destroy;
begin
  inherited Destroy;
end;

procedure TTZonas.Grabar(xIdzona, xZona: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xIdzona) then tabla.Edit else tabla.Append;
  tabla.FieldByName('Idzona').AsString := xIdzona;
  tabla.FieldByName('Zona').AsString   := xZona;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTZonas.Borrar(xIdzona: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xIdzona) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('Idzona').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTZonas.Buscar(xIdzona: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'Idzona' then tabla.IndexFieldNames := 'Idzona';
  if tabla.FindKey([xIdzona]) then Result := True else Result := False;
end;

procedure  TTZonas.getDatos(xIdzona: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xIdzona) then Begin
    Idzona := tabla.FieldByName('Idzona').AsString;
    Zona   := tabla.FieldByName('Zona').AsString;
  end else Begin
    Idzona := ''; Zona := '';
  end;
end;

function TTZonas.setZonaes: TQuery;
// Objetivo...: devolver un set con los Zonaes disponibles
begin
  Result := datosdb.tranSQL(conexion, 'SELECT * FROM ' + tabla.TableName + ' ORDER BY Zona');
end;

function TTZonas.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.IndexFieldNames := 'Idzona';
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Result := IntToStr(StrToInt(tabla.FieldByName('Idzona').AsString) + 1);
end;

procedure TTZonas.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Zonas', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.  Zona', 1, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do Begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('Idzona').AsString >= iniciar) and (tabla.FieldByName('Idzona').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('Idzona').AsString < iniciar) or (tabla.FieldByName('Idzona').AsString > finalizar) then ListLinea(salida);
    // Ordenado Alfabéticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tabla.FieldByName('Zona').AsString >= iniciar) and (tabla.FieldByName('Zona').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('Zona').AsString < iniciar) or (tabla.FieldByName('Zona').AsString > finalizar) then ListLinea(salida);

    tabla.Next;
  end;
  List.FinList;

  tabla.IndexFieldNames := tabla.IndexFieldNames;
  tabla.First;
end;

procedure TTZonas.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('Idzona').AsString + '   ' + tabla.FieldByName('Zona').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(95, list.lineactual, ' ', 2, 'Arial, normal, 8', salida, 'S');
end;

procedure TTZonas.BuscarPorZona(xexpr: string);
begin
  tabla.IndexFieldNames := 'Zona';
  tabla.FindNearest([xexpr]);
end;

procedure TTZonas.BuscarPorId(xexpr: string);
begin
  tabla.IndexFieldNames := 'Idzona';
  tabla.FindNearest([xexpr]);
end;

procedure TTZonas.ExportarZonasXML;
var
  archivo: TextFile;
Begin
  AssignFile(archivo, dbs.DirSistema + '\actualizaciones_online\upload\zonas.xml');
  Rewrite(archivo);

  WriteLn(archivo, '<zonas>');
  tabla.First;
  while not tabla.Eof do Begin
    WriteLn(archivo, '<registro>');
    WriteLn(archivo, '<idzona>' + tabla.FieldByName('Idzona').AsString + '</idzona>');
    WriteLn(archivo, '<zona>' + tabla.FieldByName('zona').AsString + '</zona>');
    WriteLn(archivo, '</registro>');
    tabla.Next;
  end;
  WriteLn(archivo, '</zonas>');
  closeFile(archivo);
end;

procedure TTZonas.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('Idzona').DisplayLabel := 'Id.'; tabla.FieldByName('Zona').DisplayLabel := 'Categoría'; 
  end;
  Inc(conexiones);
end;

procedure TTZonas.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function zonas: TTZonas;
begin
  if xzona = nil then
    xzona := TTZonas.Create;
  Result := xzona;
end;

{===============================================================================}

initialization

finalization
  xzona.Free;

end.
