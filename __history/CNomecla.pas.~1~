unit CNomecla;

interface

uses SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM, Classes;

type

TTNomeclatura = class(TObject)
  codigo, descrip, codfact, RIE, cftoma, quimica, Id: string; gastos, ub: real;
  tabla, indicaciones: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodigo, xcodfact, xdescrip, xcftoma: string; xgastos, xub: real);
  procedure   EstablecerRIE(xcodigo: string);
  procedure   Borrar(xcodigo: string);
  function    Buscar(xcodigo: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xcodigo: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  function    setNomeclatura: TQuery;
  function    setNomeclaturaAlf: TQuery;
  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);
  procedure   QuitarRIE(xcodigo: string);
  procedure   FijarComoAnalisisQuimica;

  function    BuscarIndicacion(xcodigo: String): Boolean;
  procedure   RegistrarIndicacion(xcodigo, xdescrip: String);
  procedure   BorrarIndicacion(xcodigo: String);
  function    setIndicaciones: TQuery;
  function    ListarIndicaciones(lista: TStringList; lineas_sep, ancho: Integer; salida: char): Boolean;

  procedure   ImportarNomecladorXML;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: integer;
  texport: TTable;
  procedure   ListLinea(salida: char);
end;

function nomeclatura: TTNomeclatura;

implementation

var
  xnomeclatura: TTNomeclatura = nil;

constructor TTNomeclatura.Create;
begin
  inherited Create;
  tabla        := datosdb.openDB('nomeclad', 'Codigo');
  if (dbs.BaseClientServ = 'N') or (Length(Trim(dbs.baseDat_N)) = 0) then indicaciones := datosdb.openDB('indicaciones', '') else
    indicaciones := datosdb.openDB('indicaciones', '', '', dbs.baseDat_N);
end;

destructor TTNomeclatura.Destroy;
begin
  inherited Destroy;
end;

function TTNomeclatura.Buscar(xcodigo: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then tabla.Open;
  if tabla.IndexFieldNames <> 'Codigo' then tabla.IndexFieldNames := 'Codigo';
  if tabla.FindKey([xcodigo]) then Result := True else Result := False;
end;

procedure TTNomeclatura.Grabar(xcodigo, xcodfact, xdescrip, xcftoma: string; xgastos, xub: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodigo) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codigo').AsString  := xcodigo;
  tabla.FieldByName('codfact').AsString := xcodfact;
  tabla.FieldByName('descrip').AsString := xdescrip;
  tabla.FieldByName('cftoma').AsString  := xcftoma;
  tabla.FieldByName('gastos').AsFloat   := xgastos;
  tabla.FieldByName('ub').AsFloat       := xub;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
  datosdb.refrescar(tabla);
end;

procedure TTNomeclatura.EstablecerRIE(xcodigo: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodigo) then Begin
    tabla.Edit;
    tabla.FieldByName('RIE').AsString  := '*';
    try
      tabla.Post;
     except
      tabla.Cancel;
    end;
  end;
end;

procedure TTNomeclatura.Borrar(xcodigo: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodigo) then begin
    tabla.Delete;
    getDatos(tabla.FieldByName('codigo').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

procedure  TTNomeclatura.getDatos(xcodigo: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcodigo) then begin
    codigo  := tabla.FieldByName('codigo').AsString;
    descrip := tabla.FieldByName('descrip').AsString;
    cftoma  := tabla.FieldByName('cftoma').AsString;
    codfact := tabla.FieldByName('codfact').AsString;
    RIE     := tabla.FieldByName('RIE').AsString;
    gastos  := tabla.FieldByName('gastos').AsFloat;
    ub      := tabla.FieldByName('ub').AsFloat;
    quimica := tabla.FieldByName('quimica').AsString;
  end else begin
    codigo := ''; descrip := ''; codfact := ''; cftoma := ''; gastos := 0; ub := 0; RIE := ''; quimica := '';
  end;
end;

function TTNomeclatura.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  tabla.Last;
  if tabla.RecordCount > 0 then Result := IntToStr(tabla.FieldByName('codigo').AsInteger + 1) else Result := '1';
end;

procedure TTNomeclatura.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tabla.IndexFieldNames := 'Descrip';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado del Nomeclador Nacional Valorizado', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(3) +  'Descripción', 1, 'Arial, cursiva, 8');
  List.Titulo(67, list.Lineactual, 'U.G.', 2, 'Arial, cursiva, 8');
  List.Titulo(82, list.Lineactual, 'U.B.', 3, 'Arial, cursiva, 8');
  List.Titulo(87, list.Lineactual, 'Cód.Fact.', 4, 'Arial, cursiva, 8');
  List.Titulo(96, list.Lineactual, 'RIE', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
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

procedure TTNomeclatura.ListLinea(salida: char);
// Objetivo...: Linea de detalle
begin
  List.Linea(0, 0, tabla.FieldByName('codigo').AsString + '    ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.importe(70, list.lineactual, '', tabla.FieldByName('gastos').AsFloat, 2, 'Arial, normal, 8');
  List.importe(85, list.lineactual, '', tabla.FieldByName('ub').AsFloat, 3, 'Arial, normal, 8');
  List.Linea(87, list.lineactual, tabla.FieldByName('codfact').AsString, 4, 'Courier New, normal, 9', salida, 'N');
  List.Linea(97, list.lineactual, tabla.FieldByName('RIE').AsString, 5, 'Courier New, normal, 9', salida, 'S');
end;

function TTNomeclatura.setNomeclatura: TQuery;
// Objetivo...: Devolver un set de registro con los items
begin
  Result := datosdb.tranSQL(tabla.DataBaseName, 'SELECT * FROM nomeclad');
end;

function TTNomeclatura.setNomeclaturaAlf: TQuery;
// Objetivo...: Devolver un set de registro con los items
begin
  Result := datosdb.tranSQL(tabla.DataBaseName, 'SELECT * FROM nomeclad ORDER BY descrip');
end;

procedure TTNomeclatura.BuscarPorCodigo(xexpr: string);
begin
  if not tabla.Active then tabla.Open;
  if tabla.IndexFieldNames <> 'Codigo' then tabla.IndexFieldNames := 'Codigo';
  tabla.FindNearest([xexpr]);
end;

procedure TTNomeclatura.BuscarPorNombre(xexpr: string);
begin
  if not tabla.Active then tabla.Open;
  if tabla.IndexFieldNames <> 'Descrip' then tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTNomeclatura.QuitarRIE(xcodigo: string);
begin
  if Buscar(xcodigo) then Begin
    tabla.Edit;
    tabla.FieldByName('RIE').AsString  := ' ';
    tabla.FieldByName('UGRIE').AsFloat := 0;
    tabla.FieldByName('UBRIE').AsFloat := 0;
    try
      tabla.Post
    except
      tabla.Cancel
    end;
  end;
end;

procedure TTNomeclatura.FijarComoAnalisisQuimica;
// Objetivo...: marcar/desmarcar análisis de quimica  - Para calcular las hojas de trabajo
begin
  tabla.Edit;
  if tabla.FieldByName('quimica').AsString = '*' then tabla.FieldByName('quimica').AsString := '' else tabla.FieldByName('quimica').AsString := '*';
  try
    tabla.Post
  except
    tabla.Cancel
  end;
end;

function  TTNomeclatura.BuscarIndicacion(xcodigo: String): Boolean;
Begin
  Result := indicaciones.FindKey([xcodigo]);
end;

procedure TTNomeclatura.RegistrarIndicacion(xcodigo, xdescrip: String);
Begin
  if Length(Trim(xcodigo)) = 0 then id := Trim(utiles.sExprFecha2000(utiles.setFechaActual) + Copy(utiles.setHoraActual24, 1, 2) + Copy(utiles.setHoraActual24, 4, 2) + Copy(utiles.setHoraActual24, 7, 2)) else id := xcodigo;
  if not BuscarIndicacion(id) then indicaciones.Append else indicaciones.Edit;
  indicaciones.FieldByName('codigo').AsString  := id;
  indicaciones.FieldByName('descrip').AsString := xdescrip;
  try
    indicaciones.Post
   except
    indicaciones.Cancel
  end;
  datosdb.refrescar(indicaciones);
end;

procedure TTNomeclatura.BorrarIndicacion(xcodigo: String);
Begin
  if BuscarIndicacion(xcodigo) then indicaciones.Delete;
  datosdb.refrescar(indicaciones);
end;

function TTNomeclatura.setIndicaciones: TQuery;
Begin
  Result := datosdb.tranSQL(indicaciones.DataBaseName, 'select * from indicaciones order by descrip');
end;

function TTNomeclatura.ListarIndicaciones(lista: TStringList; lineas_sep, ancho: Integer; salida: char): Boolean;
// Objetivo...: Abrir tablas de persistencia
var
  i: Integer;
begin
  Result := False;
  if lista.Count > 0 then Begin
    list.largoImpresionMemo := ancho;
    list.NoImprimirPieDePagina;
    list.ListarRichEdit_Titulo(dbs.DirSistema + '\indicaciones\titulo_indicaciones.rtf', lineas_sep, salida);
    for i := 1 to lista.Count do
      list.ListarRichEdit(dbs.DirSistema + '\indicaciones\' + lista.Strings[i-1] + '.rtf', lineas_sep, salida);
    list.FinList;
    Result := True;
  end else
    utiles.msgError('No hay Indicaciones Seleccionadas ...!');
end;

procedure TTNomeclatura.ImportarNomecladorXML;
// Objetivo...: Actualizar Datos a partir de una Fuente XML
Begin
  texport := datosdb.openDB('nomeclad', '', '', dbs.DirSistema + '\actualizaciones_online\download\estructu');
  texport.Open;

  while not texport.Eof do Begin
    if Buscar(texport.FieldByName('codigo').AsString) then tabla.Edit else tabla.Append;
    tabla.FieldByName('codigo').AsString  := texport.FieldByName('codigo').AsString;
    tabla.FieldByName('descrip').AsString := texport.FieldByName('descrip').AsString;
    tabla.FieldByName('gastos').AsString  := texport.FieldByName('gastos').AsString;
    tabla.FieldByName('ub').AsString      := texport.FieldByName('ub').AsString;
    tabla.FieldByName('codfact').AsString := texport.FieldByName('codfact').AsString;
    tabla.FieldByName('rie').AsString     := texport.FieldByName('rie').AsString;
    tabla.FieldByName('ugrie').AsString   := texport.FieldByName('ugrie').AsString;
    tabla.FieldByName('ubrie').AsString   := texport.FieldByName('ubrie').AsString;
    tabla.FieldByName('cftoma').AsString  := texport.FieldByName('cftoma').AsString;
    tabla.FieldByName('quimica').AsString := texport.FieldByName('quimica').AsString;
    tabla.FieldByName('cf').AsString      := texport.FieldByName('cf').AsString;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    texport.Next;
  end;

  datosdb.closedb(texport);
end;

procedure TTNomeclatura.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('codigo').DisplayLabel := 'Cód.'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción'; tabla.FieldByName('descrip').DisplayWidth := 45; tabla.FieldByName('ub').DisplayLabel := 'U.B.'; tabla.FieldByName('codfact').DisplayLabel := 'Cód.Fact.'; tabla.FieldByName('quimica').DisplayLabel := 'CQ';
    tabla.FieldByName('gastos').DisplayLabel := 'U.G.'; tabla.FieldByName('cftoma').DisplayLabel := 'CF Toma';
    tabla.FieldByName('ubrie').Visible := False; tabla.FieldByName('ugrie').Visible := False; tabla.FieldByName('rie').Visible := False;
    if not indicaciones.Active then indicaciones.Open;
  end;
  Inc(conexiones);
end;

procedure TTNomeclatura.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(indicaciones);
  end;
end;

{===============================================================================}

function nomeclatura: TTNomeclatura;
begin
  if xnomeclatura = nil then
    xnomeclatura := TTNomeclatura.Create;
  Result := xnomeclatura;
end;

{===============================================================================}

initialization

finalization
  xnomeclatura.Free;

end.
