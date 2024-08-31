unit CProvin;

interface

uses CSHMC, SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM;

type

TTProvincia = class(TTCSHMC)
  codprovin, Provincia: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xcodprovin, xprovincia: string);

  procedure   Grabar(xcodprovin, xProvincia: string);
  procedure   Borrar(xcodprovin: string);
  function    Buscar(xcodprovin: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xcodprovin: string);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorCodigo(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function provincia: TTProvincia;

implementation

var
  xprovincia: TTProvincia = nil;

constructor TTProvincia.Create(xcodprovin, xprovincia: string);
begin
  inherited Create;
  codprovin := xcodprovin;
  provincia := xprovincia;

  tabla := datosdb.openDB('provinci', 'codprovin');
end;

destructor TTProvincia.Destroy;
begin
  inherited Destroy;
end;

procedure TTProvincia.Grabar(xcodprovin, xprovincia: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodprovin) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codprovin').Value := xcodprovin;
  tabla.FieldByName('provincia').Value := xprovincia;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTProvincia.Borrar(xcodprovin: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodprovin) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('codprovin').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTProvincia.Buscar(xcodprovin: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then tabla.Open;
  tabla.IndexFieldNames := 'codprovin';
  if tabla.FindKey([xcodprovin]) then Result := True else Result := False;
end;

procedure  TTProvincia.getDatos(xcodprovin: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcodprovin) then
    begin
      codprovin := tabla.FieldByName('codprovin').AsString;
      provincia := tabla.FieldByName('provincia').AsString;
    end
   else
    begin
      codprovin := ''; provincia := '';
    end;
end;

function TTProvincia.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  tabla.Refresh; tabla.Last;
  Result := IntToStr(tabla.FieldByName('codprovin').AsInteger + 1);
end;

procedure TTProvincia.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Provincias', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(3) +  'Provincia', 1, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('codprovin').AsString >= iniciar) and (tabla.FieldByName('codprovin').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('codprovin').AsString + '     ' + tabla.FieldByName('Provincia').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('codprovin').AsString < iniciar) or (tabla.FieldByName('codprovin').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('codprovin').AsString + '     ' + tabla.FieldByName('Provincia').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('provincia').AsString >= iniciar) and (tabla.FieldByName('provincia').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('codprovin').AsString + '     ' + tabla.FieldByName('Provincia').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('provincia').AsString < iniciar) or (tabla.FieldByName('provincia').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('codprovin').AsString + '     ' + tabla.FieldByName('Provincia').AsString, 1, 'Courier New, normal, 9', salida, 'S');

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTProvincia.BuscarPorDescrip(xexpr: string);
begin
  tabla.IndexName := 'provincia';
  tabla.FindNearest([xexpr]);
end;

procedure TTProvincia.BuscarPorCodigo(xexpr: string);
begin
  tabla.IndexFieldNames := 'codprovin';
  tabla.FindNearest([xexpr]);
end;

procedure TTProvincia.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('codprovin').DisplayLabel := 'Cód.'; tabla.FieldByName('provincia').DisplayLabel := 'Provincia';
  end;
  Inc(conexiones);
end;

procedure TTProvincia.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function provincia: TTProvincia;
begin
  if xprovincia = nil then
    xprovincia := TTProvincia.Create('', '');
  Result := xprovincia;
end;

{===============================================================================}

initialization

finalization
  xprovincia.Free;

end.
