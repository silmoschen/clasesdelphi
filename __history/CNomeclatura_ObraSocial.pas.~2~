unit CNomeclatura_ObraSocial;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CNomeclaCCB,
     CObrasSocialesCCB, CNBU, Forms;

type

TTNomeclaturaOS = class
  Codos, Codigo, Descrip, Codref, Especial: String; Nroaut: Integer;
  Unidad, Unidades: Real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xcodos, xcodigo: String): Boolean;
  procedure   Registrar(xcodos, xcodigo, xdescrip, xcodref: String; xnroaut: Integer; xunidad, xunidades: Real);
  procedure   Borrar(xcodos, xcodigo: String);
  procedure   getDatos(xcodos, xcodigo: String);

  procedure   BuscarPorCodigo(xcodos, xcodigo: String);
  procedure   BuscarPorDescrip(xdescrip: String);
  procedure   Filtrar(xcodos: String);
  procedure   QuitarFiltro;

  function    setCantidadDeterminacionesAutorizadas(xcodos, xcodigo: String): Integer;
  function    setDeterminacionNomeclaturaNacional(xcodos, xcodigo: String): String;
  function    setCodigoNomeclaturaNacional(xcodos, xcodigo: String): String;

  procedure   Listar(orden, iniciar, finalizar, ent_excl, xcodos: string; salida: char);

  function    setDeterminaciones(xcodos: string): TQuery;

  procedure   CopiarNBU(xcodos: string); overload;
  procedure   CopiarNBU(xdesde_codos, xa_codos: string); overload;
  procedure   BorrarNBU(xcodos: string);

  procedure   MarcarPracticaDiferencial(xcodos, xcodigo: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   ListLinea(salida: char);
end;

function nomeclaturaos: TTNomeclaturaOS;

implementation

var
  xnomeclaturaos: TTNomeclaturaOS = nil;

constructor TTNomeclaturaOS.Create;
begin
  inherited Create;

  if dbs.BaseClientServ = 'S' then begin
    if (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccb.exe') or                  // Motor de Persitencia para las versiones de Laboratorios Cliente-Servidor
       (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbc.exe') or
       (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbcretivac.exe') or
       (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftlabinter.exe') or
       (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbcretiva.exe') then Begin   // Motor de Persitencia para las versiones de Laboratorios
         tabla := datosdb.openDB('nomeclados', '', '', dbs.TDB1.DatabaseName)
       End
    else
      tabla := datosdb.openDB('nomeclados', '');
  end else
    tabla := datosdb.openDB('nomeclados', '', '', dbs.BaseDat);
end;

destructor TTNomeclaturaOS.Destroy;
begin
  inherited Destroy;
end;

function TTNomeclaturaOS.Buscar(xcodos, xcodigo: String): Boolean;
// Objetivo...: buscar una instancia
begin
  if tabla.IndexFieldNames <> 'codos;codigo' then tabla.IndexFieldNames := 'codos;codigo';
  Result := datosdb.Buscar(tabla, 'codos', 'codigo', xcodos, xcodigo);
end;

procedure TTNomeclaturaOS.Registrar(xcodos, xcodigo, xdescrip, xcodref: String; xnroaut: Integer; xunidad, xunidades: Real);
// Objetivo...: registrar una instancia
begin
  if Buscar(xcodos, xcodigo) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codos').AsString   := xcodos;
  tabla.FieldByName('codigo').AsString  := xcodigo;
  tabla.FieldByName('descrip').AsString := xdescrip;
  tabla.FieldByName('codref').AsString  := xcodref;
  tabla.FieldByName('nroaut').AsInteger := xnroaut;
  tabla.FieldByName('unidad').AsFloat   := xunidad;
  tabla.FieldByName('unidades').AsFloat := xunidades;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.refrescar(tabla);
end;

procedure TTNomeclaturaOS.Borrar(xcodos, xcodigo: String);
// Objetivo...: borrar una instancia
begin
  if Buscar(xcodos, xcodigo) then tabla.Delete;
  datosdb.refrescar(tabla);
end;

procedure TTNomeclaturaOS.getDatos(xcodos, xcodigo: String);
// Objetivo...: recuperar una instancia
begin
  if Buscar(xcodos, xcodigo) then Begin
    codos    := tabla.FieldByName('codos').AsString;
    codigo   := tabla.FieldByName('codigo').AsString;
    descrip  := tabla.FieldByName('descrip').AsString;
    codref   := tabla.FieldByName('codref').AsString;
    especial := tabla.FieldByName('especial').AsString;
    nroaut   := tabla.FieldByName('nroaut').AsInteger;
    unidad   := tabla.FieldByName('unidad').AsFloat;
    unidades := tabla.FieldByName('unidades').AsFloat;
  end else Begin
    codos := ''; codigo := ''; descrip := ''; codref := ''; nroaut := 0; unidad := 0; unidades := 0; especial := '';
  end;
end;

procedure TTNomeclaturaOS.BuscarPorCodigo(xcodos, xcodigo: String);
// Objetivo...: busqueda blanda por codigo
begin
  if tabla.IndexFieldNames <> 'codos;codigo' then tabla.IndexFieldNames := 'codos;codigo';
  datosdb.BuscarEnFormaContextual(tabla, 'codos', 'codigo', xcodos, xcodigo);
end;

procedure TTNomeclaturaOS.BuscarPorDescrip(xdescrip: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if tabla.IndexFieldNames <> 'descrip' then tabla.IndexFieldNames := 'descrip';
  tabla.FindNearest([xdescrip]);
end;

procedure TTNomeclaturaOS.Filtrar(xcodos: String);
// Objetivo...: cerrar tablas de persistencia
begin
  datosdb.Filtrar(tabla, 'codos = ' + '''' + xcodos + '''');
end;

procedure TTNomeclaturaOS.QuitarFiltro;
// Objetivo...: cerrar tablas de persistencia
begin
  datosdb.QuitarFiltro(tabla);
end;

procedure TTNomeclaturaOS.Listar(orden, iniciar, finalizar, ent_excl, xcodos: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  list.Setear(salida);
  obsocial.getDatos(xcodos);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado Nomeclaturas Obra Social: ' + obsocial.Nombre, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(3) +  'Descripción', 1, 'Arial, cursiva, 8');
  List.Titulo(56, list.Lineactual, 'Cant.Aut.Mes', 2, 'Arial, cursiva, 8');
  List.Titulo(67, list.Lineactual, 'Equivalencia Nomelcador Nacional', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do Begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('codigo').AsString >= iniciar) and (tabla.FieldByName('codigo').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('codigo').AsString < iniciar) or (tabla.FieldByName('codigo').AsString > finalizar) then ListLinea(salida);
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

procedure TTNomeclaturaOS.ListLinea(salida: char);
// Objetivo...: Linea de detalle
begin
  nomeclatura.getDatos(tabla.FieldByName('codref').AsString);
  List.Linea(0, 0, tabla.FieldByName('codigo').AsString + '    ' + Copy(tabla.FieldByName('descrip').AsString, 1, 60) , 1, 'Arial, normal, 8', salida, 'N');
  List.importe(65, list.lineactual, '#0', tabla.FieldByName('nroaut').AsFloat, 2, 'Arial, normal, 8');
  List.Linea(67, list.Lineactual, tabla.FieldByName('codref').AsString + '  ' + nomeclatura.descrip , 3, 'Arial, normal, 8', salida, 'S');
end;

function  TTNomeclaturaOS.setCantidadDeterminacionesAutorizadas(xcodos, xcodigo: String): Integer;
// Objetivo...: devolver las determinaciones por nomeclador nacional
begin
  tabla.IndexFieldNames := 'codos;codref';
  if datosdb.Buscar(tabla, 'codos', 'codref', xcodos, xcodigo) then Result := tabla.FieldByName('nroaut').AsInteger else Result := 0;
  tabla.IndexFieldNames := 'codos;codigo';
end;

function  TTNomeclaturaOS.setDeterminacionNomeclaturaNacional(xcodos, xcodigo: String): String;
// Objetivo...: devolver las determinaciones por nomeclador nacional
begin
  tabla.IndexFieldNames := 'codos;codref';
  if datosdb.Buscar(tabla, 'codos', 'codref', xcodos, xcodigo) then Result := tabla.FieldByName('descrip').AsString else Result := '';
  tabla.IndexFieldNames := 'codos;codigo';
end;

function  TTNomeclaturaOS.setCodigoNomeclaturaNacional(xcodos, xcodigo: String): String;
// Objetivo...: devolver las determinaciones por nomeclador nacional
begin
  tabla.IndexFieldNames := 'codos;codref';
  if datosdb.Buscar(tabla, 'codos', 'codref', xcodos, xcodigo) then Result := tabla.FieldByName('codigo').AsString else Result := '';
  tabla.IndexFieldNames := 'codos;codigo';
end;

function TTNomeclaturaOS.setDeterminaciones(xcodos: string): TQuery;
// Objetivo...: devolver un set con los Descripes disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' WHERE codos = ' + '''' + xcodos + '''' + ' ORDER BY Codigo');
end;

procedure TTNomeclaturaOS.CopiarNBU(xcodos: string);
// Objetivo...: realizar una copia del NBU
var
  r: TQuery;
begin
  tabla.Filtered := False;
  r := nbu.setDeterminaciones;
  r.Open;
  while not r.Eof do begin
    if Buscar(xcodos, r.FieldByName('codigo').AsString) then tabla.Edit else tabla.Append;
    tabla.FieldByName('codos').AsString   := xcodos;
    tabla.FieldByName('codigo').AsString  := r.FieldByName('codigo').AsString;
    tabla.FieldByName('descrip').AsString := r.FieldByName('descrip').AsString;
    tabla.FieldByName('codref').AsString  := r.FieldByName('codnnn').AsString;
    tabla.FieldByName('nroaut').AsInteger := 0;
    tabla.FieldByName('unidad').AsFloat   := r.FieldByName('unidad').AsFloat;
    tabla.FieldByName('unidades').AsFloat := r.FieldByName('unidades').AsFloat;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    r.Next;
  end;
  datosdb.refrescar(tabla);
  r.Close; r.Free;
  tabla.Filtered := true;
end;

procedure TTNomeclaturaOS.CopiarNBU(xdesde_codos, xa_codos: string);
// Objetivo...: realizar una copia del NBU
var
  r: TQuery;
begin
  tabla.Filtered := False;
  r := setDeterminaciones(xdesde_codos);
  r.Open;
  while not r.Eof do begin
    if Buscar(xa_codos, r.FieldByName('codigo').AsString) then tabla.Edit else tabla.Append;
    tabla.FieldByName('codos').AsString   := xa_codos;
    tabla.FieldByName('codigo').AsString  := r.FieldByName('codigo').AsString;
    tabla.FieldByName('descrip').AsString := r.FieldByName('descrip').AsString;
    tabla.FieldByName('codref').AsString  := r.FieldByName('codref').AsString;
    tabla.FieldByName('nroaut').AsInteger := r.FieldByName('nroaut').AsInteger;
    tabla.FieldByName('unidad').AsFloat   := r.FieldByName('unidad').AsFloat;
    tabla.FieldByName('unidades').AsFloat := r.FieldByName('unidades').AsFloat;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    r.Next;
  end;
  datosdb.refrescar(tabla);
  r.Close; r.Free;
  tabla.Filtered := true;
end;

procedure TTNomeclaturaOS.MarcarPracticaDiferencial(xcodos, xcodigo: string);
begin
  if Buscar(xcodos, xcodigo) then begin
    tabla.Edit;
    if (tabla.FieldByName('especial').AsString = '*') then
      tabla.FieldByName('especial').AsString := ''
    else
      tabla.FieldByName('especial').AsString := '*';
    try
      tabla.Post;
    except
      tabla.Cancel;
    end;
  end;
  datosdb.refrescar(tabla);
end;

procedure TTNomeclaturaOS.BorrarNBU(xcodos: string);
begin
  datosdb.tranSQL('delete from ' + tabla.TableName + ' where codos = ' + '''' + xcodos + '''');
  datosdb.closeDB(tabla); tabla.Open;  
end;

procedure TTNomeclaturaOS.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  if (tabla.Active) then begin
    tabla.FieldByName('codos').Visible := False;
    tabla.FieldByName('codigo').DisplayLabel := 'Código'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción'; tabla.FieldByName('codref').DisplayLabel := 'Cód.Ref'; tabla.FieldByName('nroaut').DisplayLabel := 'Nro.Aut.';
    tabla.FieldByName('descrip').DisplayWidth := 60;
  end;
  Inc(conexiones);
  nomeclatura.conectar;
  obsocial.conectar;
end;

procedure TTNomeclaturaOS.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
  nomeclatura.desconectar;
  obsocial.desconectar;
end;

{===============================================================================}

function nomeclaturaos: TTNomeclaturaOS;
begin
  if xnomeclaturaos = nil then
    xnomeclaturaos := TTNomeclaturaOS.Create;
  Result := xnomeclaturaos;
end;

{===============================================================================}

initialization

finalization
  xnomeclaturaos.Free;

end.
