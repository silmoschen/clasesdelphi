unit CDepenDGI;

interface

uses SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM;

type

TTDepenDGI = class(TObject)            // Superclase
  codDepenDGI, depen: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xcodDepenDGI, xdepen: string);
  destructor  Destroy; override;

  procedure   Grabar(xcodDepenDGI, xDepen: string);
  procedure   Borrar(xcodDepenDGI: string);
  function    Buscar(xcodDepenDGI: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xcodDepenDGI: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorId(expresion: string);
  procedure   BuscarPorDescrip(expresion: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function DepenDGI: TTDepenDGI;

implementation

var
  xDepenDGI: TTDepenDGI = nil;

constructor TTDepenDGI.Create(xcodDepenDGI, xDepen: string);
begin
  inherited Create;
  codDepenDGI := xcodDepenDGI;
  Depen     := xDepen;

  tabla := datosdb.openDB('dependgi', 'coddepdgi');
end;

destructor TTDepenDGI.Destroy;
begin
  inherited Destroy;
end;

procedure TTDepenDGI.Grabar(xcodDepenDGI, xDepen: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodDepenDGI) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codDepDGI').Value := xcodDepenDGI;
  tabla.FieldByName('depen').Value     := xDepen;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTDepenDGI.Borrar(xcodDepenDGI: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodDepenDGI) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('coddepDGI').Value);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTDepenDGI.Buscar(xcodDepenDGI: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'coddepdgi' then tabla.IndexFieldNames := 'coddepdgi';
  if tabla.FindKey([xcodDepenDGI]) then Result := True else Result := False;
end;

procedure  TTDepenDGI.getDatos(xcodDepenDGI: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcodDepenDGI) then
    begin
      codDepenDGI := tabla.FieldByName('coddepDGI').Value;
      Depen       := tabla.FieldByName('Depen').Value;
    end
   else
    begin
      codDepenDGI := ''; Depen := '';
    end;
end;

function TTDepenDGI.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  tabla.Last;
  Result := IntToStr(tabla.FieldByName('coddepDGI').AsInteger + 1);
end;

procedure TTDepenDGI.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de DepenDGIs
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Dependencias D.G.I.', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(5) +  'Dependencia', 1, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('codDepDGI').AsString >= iniciar) and (tabla.FieldByName('codDepDGI').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('codDepDGI').AsString + '     ' + tabla.FieldByName('Depen').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('codDepDGI').AsString < iniciar) or (tabla.FieldByName('codDepDGI').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('codDepDGI').AsString + '     ' + tabla.FieldByName('Depen').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('Depen').AsString >= iniciar) and (tabla.FieldByName('Depen').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('codDepDGI').AsString + '     ' + tabla.FieldByName('Depen').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('Depen').AsString < iniciar) or (tabla.FieldByName('Depen').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('codDep').AsString + '     ' + tabla.FieldByName('Depen').AsString, 1, 'Courier New, normal, 9', salida, 'S');

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTDepenDGI.BuscarPorId(expresion: string);
begin
  if tabla.IndexFieldNames <> 'coddepdgi' then tabla.IndexFieldNames := 'coddepdgi';
  tabla.FindNearest([expresion]);
end;

procedure TTDepenDGI.BuscarPorDescrip(expresion: string);
begin
  if tabla.IndexName <> 'Depen' then tabla.IndexName := 'Depen';
  tabla.FindNearest([expresion]);
end;

procedure TTDepenDGI.conectar;
// Objetivo...: concetar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('coddepdgi').DisplayLabel := 'Cód'; tabla.FieldByName('depen').DisplayLabel := 'Dependencia';
  end;
  Inc(conexiones);
end;

procedure TTDepenDGI.desconectar;
// Objetivo...: desconcetar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then
    datosdb.closeDB(tabla);
end;

{===============================================================================}

function DepenDGI: TTDepenDGI;
begin
  if xDepenDGI = nil then
    xDepenDGI := TTDepenDGI.Create('', '');
  Result := xDepenDGI;
end;

{===============================================================================}

initialization

finalization
  xDepenDGI.Free;

end.
