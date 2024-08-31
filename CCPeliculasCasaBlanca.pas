unit CCPeliculasCasaBlanca;

interface

uses CGeneros_Casablanca, CBDT, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM;

type

TTPeliculas = class
  Codigo, Descrip, Idgenero, SinCar, Canjeable: String;
  Oferta: real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodigo, xdescrip, xidgenero, xsincargo:String; xoferta: Real);
  function    Borrar(xcodigo: string): string;
  function    Buscar(xcodigo: string): boolean;
  procedure   getDatos(xcodigo: string);
  function    Nuevo: String;

  function    setPeliculasAlf: TQuery;

  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; xsalida: char);
  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorDescrip(xexpr: string);

  procedure   EstabelecerCanje(xdesde, xhasta: String); overload;
  procedure   QuitarCanje;
  procedure   EstablecerCanje; overload;

  function    PrecioAlquiler(xcodigo: String): Real;
  procedure   AlquilarPelicula(xcodigo, xestado: String);
  function    verificarSiLaPeliculaEstaAlquilada(xcodigo: String): Boolean;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   List_linea(salida: char);
end;

function pelicula: TTPeliculas;

implementation

var
  xpelicula: TTPeliculas = nil;

constructor TTPeliculas.Create;
begin
  tabla := datosdb.openDB('peliculas', '');
end;

destructor TTPeliculas.Destroy;
begin
  inherited Destroy;
end;

procedure TTPeliculas.Grabar(xcodigo, xdescrip, xidgenero, xsincargo: string; xoferta: Real);
// Objetivo...: Grabar Atributos de Vendedores
begin
  if Buscar(xcodigo) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codigo').AsString   := xcodigo;
  tabla.FieldByName('descrip').AsString  := xdescrip;
  tabla.FieldByName('idgenero').AsString := xidgenero;
  tabla.FieldByName('oferta').AsFloat    := xoferta;
  tabla.FieldByName('sincargo').AsString := xsincargo;
  if Length(Trim(tabla.FieldByName('canjeable').AsString)) = 0 then tabla.FieldByName('canjeable').AsString := 'N';
  try
    tabla.Post;
   except
    tabla.Cancel
  end;
end;

procedure  TTPeliculas.getDatos(xcodigo: string);
// Objetivo...: Obtener/Inicializar los Atributos para un objeto Vendedor
begin
  if Buscar(xcodigo) then Begin
    codigo    := tabla.FieldByName('codigo').AsString;
    descrip   := tabla.FieldByName('descrip').AsString;
    idgenero  := tabla.FieldByName('idgenero').AsString;
    oferta    := tabla.FieldByName('oferta').AsFloat;
    sincar    := tabla.FieldByName('sincargo').AsString;
    Canjeable := tabla.FieldByName('canjeable').AsString;
  end else Begin
    codigo := ''; descrip := ''; idgenero := ''; oferta := 0; sincar := 'N'; Canjeable := 'N';
  end;
end;

function TTPeliculas.Nuevo: String;
// Objetivo...: Generar un nuevo genero
Begin
  if tabla.RecordCount = 0 then Result := '1' else Begin
    tabla.IndexFieldNames := 'codigo';
    tabla.Last;
    Result := IntToStr(tabla.FieldByName('codigo').AsInteger + 1);
  end;
end;

function TTPeliculas.Borrar(xcodigo: string): string;
// Objetivo...: Eliminar un Instancia de Vendedor
begin
  if Buscar(xcodigo) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('codigo').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTPeliculas.Buscar(xcodigo: string): boolean;
// Objetivo...: Verificar si Existe el Vendedor
begin
  if tabla.IndexFieldNames <> 'Codigo' then tabla.IndexFieldNames := 'Codigo';
  Result := tabla.FindKey([xcodigo]);
end;

procedure TTPeliculas.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  genero.getDatos(tabla.FieldByName('idgenero').AsString);
  List.Linea(0, 0, tabla.FieldByName('codigo').AsString + '  ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(60, List.lineactual, genero.Descrip, 2, 'Arial, normal, 8', salida, 'S');
end;

procedure TTPeliculas.Listar(orden, iniciar, finalizar, ent_excl: string; xsalida: char);
// Objetivo...: Listar Datos de Provincias
var
  salida: Char;
begin
  salida := xsalida;
  if orden = 'A' then tabla.IndexFieldNames := 'Descrip';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de peliculas', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Código  Nombre de la Película', 1, 'Arial, cursiva, 8');
  List.Titulo(60, List.lineactual, 'Genero', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('codigo').AsString >= iniciar) and (tabla.FieldByName('codigo').AsString <= finalizar) then List_linea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('codigo').AsString < iniciar) or (tabla.FieldByName('codigo').AsString > finalizar) then List_linea(salida);
    // Ordenado Alfabéticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tabla.Fields[1].AsString >= iniciar) and (tabla.Fields[1].AsString <= finalizar) then List_linea(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.Fields[1].AsString < iniciar) or (tabla.Fields[1].AsString > finalizar) then List_linea(salida);

    tabla.Next;
  end;

  tabla.IndexFieldNames := 'Codigo';
  tabla.First;

  list.FinList;
end;

function TTPeliculas.setPeliculasAlf: TQuery;
// Objetivo...: Devolver un set de registros con los peliculas ordenados alfabeticamente
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY descrip');
end;

procedure TTPeliculas.BuscarPorCodigo(xexpr: string);
// Objetivo...: buscar pelicula por código
begin
  if tabla.IndexFieldNames <> 'Codigo' then tabla.IndexFieldNames := 'Codigo';
  tabla.FindNearest([xexpr]);
end;

procedure TTPeliculas.BuscarPorDescrip(xexpr: string);
// Objetivo...: buscar por nombre
begin
  if tabla.IndexFieldNames <> 'Descrip' then tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTPeliculas.EstabelecerCanje(xdesde, xhasta: String);
// Objetivo...: Establecer canje en el rango
Begin
  datosdb.tranSQL('update ' + tabla.TableName + ' set canjeable = ' + '"' + 'S' + '"' + ' where codigo >= ' + '"' + xdesde + '"' + ' and codigo <= ' + '"' + xhasta + '"');
  datosdb.refrescar(tabla);
end;

procedure TTPeliculas.QuitarCanje;
// Objetivo...: Iniciar todas
Begin
  datosdb.tranSQL('update ' + tabla.TableName + ' set canjeable = ' + '"' + 'N' + '"');
  datosdb.refrescar(tabla);
end;

procedure TTPeliculas.EstablecerCanje;
// Objetivo...: Establecer canje en terminos individuales
Begin
  tabla.Edit;
  if tabla.FieldByName('canjeable').AsString <> 'S' then tabla.FieldByName('canjeable').AsString := 'S' else tabla.FieldByName('canjeable').AsString := 'N';
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.refrescar(tabla);
  tabla.Next;
  if tabla.Eof then tabla.Last;
end;

function  TTPeliculas.PrecioAlquiler(xcodigo: String): Real;
// Objetivo...: Determinar el Precio del Alquiler
Begin
  Result := 0;
  if Buscar(xcodigo) then Begin
    if tabla.FieldByName('oferta').AsFloat > 0 then Result := tabla.FieldByName('oferta').AsFloat else Begin
      genero.getDatos(tabla.FieldByName('idgenero').AsString);
      Result := genero.Precio;
    end;
    if tabla.FieldByName('sincargo').AsString = 'S' then Result := 0;
  end;
end;

procedure TTPeliculas.AlquilarPelicula(xcodigo, xestado: String);
// Objetivo...: Determinar si la Pelcicula esta o no alquilada
Begin
  if Buscar(xcodigo) then Begin
    tabla.Edit;
    tabla.FieldByName('alquilada').AsString := xestado;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.refrescar(tabla); 
  end;
end;

function TTPeliculas.verificarSiLaPeliculaEstaAlquilada(xcodigo: String): Boolean;
// Objetivo...: Determinar si la Pelcicula esta o no alquilada
Begin
  Result := False;
  if Buscar(xcodigo) then
    if tabla.FieldByName('alquilada').AsString = 'S' then Result := True else Result := False;
end;

procedure TTPeliculas.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('codigo').DisplayLabel := 'Código'; tabla.FieldByName('descrip').DisplayLabel := 'Nombre de la Película'; tabla.FieldByName('oferta').DisplayLabel := 'Oferta';
    tabla.FieldByName('sincargo').DisplayLabel := 'S/C'; tabla.FieldByName('canjeable').DisplayLabel := 'Canjeable';
    tabla.FieldByName('idgenero').Visible := False; tabla.FieldByName('alquilada').Visible := False; tabla.FieldByName('oferta').Visible := False;
  end;
  Inc(conexiones);
  genero.conectar;
end;

procedure TTPeliculas.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
  genero.desconectar;
end;

{===============================================================================}

function pelicula: TTPeliculas;
begin
  if xpelicula = nil then
    xpelicula := TTPeliculas.Create;
  Result := xpelicula;
end;

{===============================================================================}

initialization

finalization
  xpelicula.Free;

end.
