unit CEntidadesQueDerivanFabrissin;

interface

uses SysUtils, DB, DBTables, CIDBFM, CListar, CUtiles, CBDT;

type

TTEntidadesQueDerivan = class(TObject)            // Superclase
  Identidad, Descrip: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xIdentidad, xDescrip: string);
  procedure   Borrar(xIdentidad: string);
  function    Buscar(xIdentidad: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xIdentidad: string);
  function    setEntidades: TQuery;
  function    setEntidadesAlf: TQuery;
  procedure   BuscarPorCodigo(xexp: string);
  procedure   BuscarPorNombre(xexp: string);

  procedure   conectar;
  procedure   desconectar;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function entidadderivadora: TTEntidadesQueDerivan;

implementation

var
  xentidadderivadora: TTEntidadesQueDerivan = nil;

constructor TTEntidadesQueDerivan.Create;
begin
  inherited create;
  if dbs.BaseClientServ = 'N' then tabla := datosdb.openDB('entderiva', 'Identidad');
  if dbs.BaseClientServ = 'S' then tabla := datosdb.openDB('entderiva', '', '', dbs.baseDat_N);
end;

destructor TTEntidadesQueDerivan.Destroy;
begin
  inherited Destroy;
end;

procedure TTEntidadesQueDerivan.Grabar(xIdentidad, xdescrip: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xIdentidad) then tabla.Edit else tabla.Append;
  tabla.FieldByName('Identidad').Value := xIdentidad;
  tabla.FieldByName('descrip').Value   := TrimLeft(xdescrip);
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTEntidadesQueDerivan.Borrar(xIdentidad: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xIdentidad) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('Identidad').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTEntidadesQueDerivan.Buscar(xIdentidad: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then tabla.Open;
  if tabla.IndexFieldNames <> 'Identidad' then tabla.IndexFieldNames := 'Identidad';
  if tabla.FindKey([xIdentidad]) then Result := True else Result := False;
end;

procedure  TTEntidadesQueDerivan.getDatos(xIdentidad: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if tabla.IndexFieldNames <> 'Identidad' then tabla.IndexFieldNames := 'Identidad';
  if Buscar(xIdentidad) then
    begin
      Identidad  := tabla.FieldByName('Identidad').Value;
      descrip   := tabla.FieldByName('descrip').Value;
    end
   else
    begin
      Identidad := ''; descrip := '';
    end;
end;

function TTEntidadesQueDerivan.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  if tabla.IndexFieldNames <> 'Identidad' then tabla.IndexFieldNames := 'Identidad';
  tabla.Last;
  if Length(Trim(tabla.FieldByName('Identidad').AsString)) > 0 then Result := utiles.sLLenarIzquierda(IntToStr(tabla.FieldByName('Identidad').AsInteger + 1), 3, '0') else Result := '001';
end;

function TTEntidadesQueDerivan.setEntidades: TQuery;
// Objetivo...: retornar un set de obsocials
begin
  Result := datosdb.tranSQL(tabla.DatabaseName, 'SELECT Identidad, descrip FROM entidades');
end;

function TTEntidadesQueDerivan.setEntidadesAlf: TQuery;
// Objetivo...: retornar un set de obsocials
begin
  Result := datosdb.tranSQL(tabla.DatabaseName, 'SELECT Identidad, descrip FROM entidades ORDER BY descrip');
end;

procedure TTEntidadesQueDerivan.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Entidades para Derivación de Análisis', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(3) +  'Entidad', 1, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('Identidad').AsString >= iniciar) and (tabla.FieldByName('Identidad').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('Identidad').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('Identidad').AsString < iniciar) or (tabla.FieldByName('Identidad').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('Identidad').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString >= iniciar) and (tabla.FieldByName('descrip').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('Identidad').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString < iniciar) or (tabla.FieldByName('descrip').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('Identidad').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTEntidadesQueDerivan.BuscarPorCodigo(xexp: string);
begin
  tabla.IndexFieldNames := 'Identidad';
  tabla.FindNearest([xexp]);
end;

procedure TTEntidadesQueDerivan.BuscarPorNombre(xexp: string);
begin
  tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexp]);
end;

procedure TTEntidadesQueDerivan.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('Identidad').DisplayLabel := 'Cód.'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción';
  end;
  Inc(conexiones);
end;

procedure TTEntidadesQueDerivan.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function entidadderivadora: TTEntidadesQueDerivan;
begin
  if xentidadderivadora = nil then
    xentidadderivadora := TTEntidadesQueDerivan.Create;
  Result := xentidadderivadora;
end;

{===============================================================================}

initialization

finalization
  xentidadderivadora.Free;

end.
