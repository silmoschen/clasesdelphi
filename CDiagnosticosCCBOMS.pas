unit CDiagnosticosCCBOMS;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar;

type

TTDiagnosticosOMS = class(TObject)
  Codigo, Clave, Orden, Indice, Descrip, Codrap: string; OMS: Boolean;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodigo, xclave, xorden, xindice, xdescrip, xcodrap: string; xoms: Boolean);
  procedure   Borrar(xcodigo: string);
  function    Buscar(xcodigo: string): boolean;
  function    BuscarCodRap(xcodrap: string): boolean;
  procedure   getDatos(xcodigo: string);
  procedure   getDatosCodRap(xcodrap: string);
  function    setDescripes: TQuery;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorId(xexpr: string);
  procedure   BuscarPorCodRap(xexpr: string);
  function    VerificarCodigoImputable(xcodigo: string): Boolean;
  procedure   FiltrarCodigosImputables;
  procedure   QuitarFiltro;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  conexion: String;
  procedure   ListLinea(salida: char);
  { Declaraciones Privadas }
end;

function diagnosticooms: TTDiagnosticosOMS;

implementation

var
  xdiagnosticooms: TTDiagnosticosOMS = nil;

constructor TTDiagnosticosOMS.Create;
begin
  inherited Create;
  dbs.getParametrosDB1;     // Base de datos adicional 1
  if Length(Trim(dbs.db1)) > 0 then Begin
    dbs.NuevaBaseDeDatos(dbs.db1, dbs.us1, dbs.pa1);
    conexion := dbs.baseDat_N;
  end else
    conexion := dbs.DirSistema + '\auditoria';

  tabla := datosdb.openDB('Diagnosticos_oms', 'oms_cod', '', conexion);
end;

destructor TTDiagnosticosOMS.Destroy;
begin
  inherited Destroy;
end;

procedure TTDiagnosticosOMS.Grabar(xcodigo, xclave, xorden, xindice, xdescrip, xcodrap: string; xoms: Boolean);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodigo) then tabla.Edit else tabla.Append;
  tabla.FieldByName('oms_cod').AsString := xcodigo;
  tabla.FieldByName('clave').AsString   := xclave;
  tabla.FieldByName('orden').AsString   := xorden;
  tabla.FieldByName('indice').AsString  := xindice;
  tabla.FieldByName('Descrip').AsString := xdescrip;
  tabla.FieldByName('codrap').AsString  := xcodrap;
  tabla.FieldByName('oms').AsBoolean    := xoms;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
  datosdb.refrescar(tabla);
end;

procedure TTDiagnosticosOMS.Borrar(xcodigo: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodigo) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('oms_cod').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTDiagnosticosOMS.Buscar(xcodigo: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'oms_cod' then tabla.IndexFieldNames := 'oms_cod';
  if tabla.FindKey([xcodigo]) then Result := True else Result := False;
end;

function   TTDiagnosticosOMS.BuscarCodRap(xcodrap: string): boolean;
// Objetivo...: Retornar/Iniciar Atributos
begin
  if tabla.IndexFieldNames <> 'codrap' then tabla.IndexFieldNames := 'codrap';
  if tabla.FindKey([xcodrap]) then Result := True else Result := False;
end;

procedure   TTDiagnosticosOMS.getDatosCodRap(xcodrap: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if tabla.IndexFieldNames <> 'codrap' then tabla.IndexFieldNames := 'codrap';
  if tabla.FindKey([xcodrap]) then getDatos(tabla.FieldByName('oms_cod').AsString) else getDatos('XX');
end;

procedure  TTDiagnosticosOMS.getDatos(xcodigo: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xcodigo) then Begin
    codigo  := tabla.FieldByName('oms_cod').AsString;
    clave   := tabla.FieldByName('clave').AsString;
    orden   := tabla.FieldByName('orden').AsString;
    indice  := tabla.FieldByName('indice').AsString;
    descrip := tabla.FieldByName('descrip').AsString;
    codrap  := tabla.FieldByName('codrap').AsString;
    oms     := tabla.FieldByName('oms').AsBoolean;
  end else Begin
    codigo := ''; clave := ''; orden := ''; indice := ''; descrip := ''; oms := False; codrap := '';
  end;
end;

function TTDiagnosticosOMS.setDescripes: TQuery;
// Objetivo...: devolver un set con los Descripes disponibles
begin
  Result := datosdb.tranSQL(conexion, 'SELECT * FROM ' + tabla.TableName + ' ORDER BY Descrip');
end;

procedure TTDiagnosticosOMS.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Diagnósticos O.M.S.', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Código', 1, 'Arial, cursiva, 8');
  List.Titulo(6, list.Lineactual, 'Clave', 2, 'Arial, cursiva, 8');
  List.Titulo(11, list.Lineactual, 'Or.', 3, 'Arial, cursiva, 8');
  List.Titulo(15, list.Lineactual, 'Ind.', 4, 'Arial, cursiva, 8');
  List.Titulo(22, list.Lineactual, 'Descripción', 5, 'Arial, cursiva, 8');
  List.Titulo(90, list.Lineactual, 'Cód.Ráp.', 6, 'Arial, cursiva, 8');
  List.Titulo(95, list.Lineactual, 'OMS', 7, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do Begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('oms_cod').AsString >= iniciar) and (tabla.FieldByName('oms_cod').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('oms_cod').AsString < iniciar) or (tabla.FieldByName('oms_cod').AsString > finalizar) then ListLinea(salida);
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

procedure TTDiagnosticosOMS.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('oms_cod').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(6, list.Lineactual, tabla.FieldByName('clave').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(11, list.Lineactual, tabla.FieldByName('orden').AsString, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(15, list.Lineactual, tabla.FieldByName('Indice').AsString, 4, 'Arial, normal, 8', salida, 'N');
  List.Linea(22, list.Lineactual, tabla.FieldByName('descrip').AsString, 5, 'Arial, normal, 8', salida, 'N');
  List.Linea(90, list.Lineactual, tabla.FieldByName('codrap').AsString, 6, 'Arial, normal, 8', salida, 'N');
  if tabla.FieldByName('oms').AsBoolean then List.Linea(95, list.lineactual, 'True', 7, 'Arial, normal, 8', salida, 'S') else
    List.Linea(95, list.lineactual, 'False', 7, 'Arial, normal, 8', salida, 'S');
end;

procedure TTDiagnosticosOMS.BuscarPorDescrip(xexpr: string);
begin
  tabla.IndexFieldNames := 'Descrip';
  if Length(Trim(xexpr)) > 0 then tabla.FindNearest([xexpr]);
end;

procedure TTDiagnosticosOMS.BuscarPorId(xexpr: string);
begin
  tabla.IndexFieldNames := 'oms_cod';
  tabla.FindNearest([xexpr]);
end;

procedure TTDiagnosticosOMS.BuscarPorCodrap(xexpr: string);
begin
  tabla.IndexFieldNames := 'codrap';
  tabla.FindNearest([xexpr]);
end;

function  TTDiagnosticosOMS.VerificarCodigoImputable(xcodigo: string): Boolean;
// Objetivo...: Verificar si el código es imputable
Begin
  Result := False;
  if Buscar(xcodigo) then
    if Length(Trim(tabla.FieldByName('orden').AsString)) > 0 then Result := True;
end;

procedure TTDiagnosticosOMS.FiltrarCodigosImputables;
Begin
  datosdb.Filtrar(tabla, 'orden >= ' + '''' + '0' + '''');
end;

procedure TTDiagnosticosOMS.QuitarFiltro;
Begin
  datosdb.QuitarFiltro(tabla);
end;

procedure TTDiagnosticosOMS.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('oms_cod').DisplayLabel := 'Código'; tabla.FieldByName('Descrip').DisplayLabel := 'Descripción';
    tabla.FieldByName('clave').DisplayLabel := 'Clave'; tabla.FieldByName('orden').DisplayLabel := 'Orden'; tabla.FieldByName('indice').DisplayLabel := 'Indice';
    tabla.FieldByName('Codrap').DisplayLabel := 'Cód.Rápido';
  end;
  Inc(conexiones);
end;

procedure TTDiagnosticosOMS.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function diagnosticooms: TTDiagnosticosOMS;
begin
  if xDiagnosticooms = nil then
    xDiagnosticooms := TTDiagnosticosOMS.Create;
  Result := xDiagnosticooms;
end;

{===============================================================================}

initialization

finalization
  xDiagnosticooms.Free;

end.
