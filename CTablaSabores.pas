unit CTablaSabores;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar;

type

TTSabores = class(TObject)
  idsabor, Descrip: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xidsabor, xDescrip: string);
  procedure   Borrar(xidsabor: string);
  function    Buscar(xidsabor: string): boolean;
  procedure   getDatos(xidsabor: string);
  function    setSabores: TQuery;
  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorId(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  { Declaraciones Privadas }
end;

function sabor: TTSabores;

implementation

var
  xcomprob: TTSabores = nil;

constructor TTSabores.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('listsab', 'idsabor');
end;

destructor TTSabores.Destroy;
begin
  inherited Destroy;
end;

procedure TTSabores.Grabar(xidsabor, xdescrip: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidsabor) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idsabor').AsString := xidsabor;
  tabla.FieldByName('descrip').AsString := xdescrip;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTSabores.Borrar(xidsabor: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xidsabor) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('idsabor').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTSabores.Buscar(xidsabor: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'Idsabor' then tabla.IndexFieldNames := 'Idsabor';
  if tabla.FindKey([xidsabor]) then Result := True else Result := False;
end;

procedure  TTSabores.getDatos(xidsabor: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xidsabor) then
    begin
      idsabor  := tabla.FieldByName('idsabor').AsString;
      descrip  := tabla.FieldByName('descrip').AsString;
    end
   else
    begin
      idsabor := ''; descrip := '';
    end;
end;

function TTSabores.setSabores: TQuery;
// Objetivo...: devolver un set con los sabores disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY descrip');
end;

function TTSabores.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Result := IntToStr(StrToInt(tabla.FieldByName('idsabor').AsString) + 1);
end;

procedure TTSabores.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Sabores', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.  Sabor', 1, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('idsabor').AsString >= iniciar) and (tabla.FieldByName('idsabor').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('idsabor').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('idsabor').AsString < iniciar) or (tabla.FieldByName('idsabor').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('idsabor').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString >= iniciar) and (tabla.FieldByName('descrip').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('idsabor').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString < iniciar) or (tabla.FieldByName('descrip').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('idsabor').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTSabores.BuscarPorDescrip(xexpr: string);
begin
  tabla.IndexName   := 'Listsab_Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTSabores.BuscarPorId(xexpr: string);
begin
  tabla.IndexFieldNames := 'Idsabor';
  tabla.FindNearest([xexpr]);
end;

procedure TTSabores.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('idsabor').DisplayLabel := 'Id. sabor'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción';
  end;
  Inc(conexiones);
end;

procedure TTSabores.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function sabor: TTSabores;
begin
  if xcomprob = nil then
    xcomprob := TTSabores.Create;
  Result := xcomprob;
end;

{===============================================================================}

initialization

finalization
  xcomprob.Free;

end.
