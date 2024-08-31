unit CActivid;

interface

uses SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM;

type

TTActividadesEconomicas = class(TObject)            // Superclase
  codactivi, descrip: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xcodactivi, xdescrip: string);
  destructor  Destroy; override;

  procedure   Grabar(xcodactivi, xDescrip: string);
  procedure   Borrar(xcodactivi: string);
  function    Buscar(xcodactivi: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xcodactivi: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorId(expresion: string);
  procedure   BuscarPorActividad(expresion: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function ActEcon: TTActividadesEconomicas;

implementation

var
  xActividadesEconomicas: TTActividadesEconomicas = nil;

constructor TTActividadesEconomicas.Create(xcodactivi, xDescrip: string);
begin
  inherited Create;
  codactivi := xcodactivi;
  Descrip   := xDescrip;

  tabla := datosdb.openDB('activida', 'codactivi');
end;

destructor TTActividadesEconomicas.Destroy;
begin
  inherited Destroy;
end;

procedure TTActividadesEconomicas.Grabar(xcodactivi, xDescrip: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodactivi) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codactivi').Value := xcodactivi;
  tabla.FieldByName('descrip').Value   := xDescrip;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTActividadesEconomicas.Borrar(xcodactivi: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodactivi) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('codactivi').Value);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTActividadesEconomicas.Buscar(xcodactivi: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'codactivi' then tabla.IndexFieldNames := 'codactivi';
  if tabla.FindKey([xcodactivi]) then Result := True else Result := False;
end;

procedure  TTActividadesEconomicas.getDatos(xcodactivi: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xcodactivi) then
    begin
      codactivi := tabla.FieldByName('codactivi').Value;
      Descrip   := tabla.FieldByName('Descrip').Value;
    end
   else
    begin
      codactivi := ''; Descrip := '';
    end;
end;

function TTActividadesEconomicas.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  tabla.Refresh; tabla.Last;
  Result := IntToStr(tabla.FieldByName('codactivi').AsInteger + 1);
end;

procedure TTActividadesEconomicas.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de descrips
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Actividades Económicas', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.Act.' + utiles.espacios(3) +  'Actividad', 1, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('codactivi').AsString >= iniciar) and (tabla.FieldByName('codactivi').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('codactivi').AsString + '     ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('codactivi').AsString < iniciar) or (tabla.FieldByName('codactivi').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('codactivi').AsString + '     ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString >= iniciar) and (tabla.FieldByName('descrip').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('codactivi').AsString + '     ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString < iniciar) or (tabla.FieldByName('descrip').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('codactivi').AsString + '     ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTActividadesEconomicas.BuscarPorId(expresion: string);
begin
  if tabla.IndexFieldNames <> 'codactivi' then tabla.IndexFieldNames := 'codactivi';
  tabla.FindNearest([expresion]);
end;

procedure TTActividadesEconomicas.BuscarPorActividad(expresion: string);
begin
  if tabla.IndexFieldNames <> 'descrip' then tabla.IndexFieldNames := 'descrip';
  tabla.FindNearest([expresion]);
end;

procedure TTActividadesEconomicas.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('codactivi').DisplayLabel := 'Cód'; tabla.FieldByName('descrip').DisplayLabel := 'Actividad';
  end;
  Inc(conexiones);
end;

procedure TTActividadesEconomicas.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones <= 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function ActEcon: TTActividadesEconomicas;
begin
  if xActividadesEconomicas = nil then
    xActividadesEconomicas := TTActividadesEconomicas.Create('', '');
  Result := xActividadesEconomicas;
end;

{===============================================================================}

initialization

finalization
  xActividadesEconomicas.Free;

end.
