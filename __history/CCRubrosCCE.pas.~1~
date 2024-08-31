unit CCRubrosCCE;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar, Forms;

type

TTRubros = class(TObject)
  Idrubro, Descrip: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xidrubro, xdescrip: string);
  procedure   Borrar(xidrubro: string);
  function    Buscar(xidrubro: string): boolean;
  procedure   getDatos(xidrubro: string);
  function    setRubros: TQuery;
  function    setRubrosAlf: TQuery;
  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorcategoria(xexpr: string);
  procedure   BuscarPorId(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  dbconexion: String;
  procedure   ListLinea(salida: char);
  { Declaraciones Privadas }
end;

function rubro: TTRubros;

implementation

var
  xrubro_cuot: TTRubros = nil;

constructor TTRubros.Create;
begin
  tabla := datosdb.openDB('rubros', '');
end;

destructor TTRubros.Destroy;
begin
  inherited Destroy;
end;

procedure TTRubros.Grabar(xidrubro, xdescrip: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidrubro) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idrubro').AsString := xidrubro;
  tabla.FieldByName('descrip').AsString := xdescrip;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
end;

procedure TTRubros.Borrar(xidrubro: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xidrubro) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('idrubro').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTRubros.Buscar(xidrubro: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then tabla.Open;
  tabla.Refresh;
  if tabla.IndexFieldNames <> 'idrubro' then tabla.IndexFieldNames := 'idrubro';
  if tabla.FindKey([xidrubro]) then Result := True else Result := False;
end;

procedure  TTRubros.getDatos(xidrubro: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xidrubro) then Begin
    idrubro := tabla.FieldByName('idrubro').AsString;
    descrip := tabla.FieldByName('descrip').AsString;
  end else Begin
    idrubro := ''; descrip := '';
  end;
end;

function TTRubros.setRubros: TQuery;
// Objetivo...: devolver un set con los categoriaes disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY idrubro');
end;

function TTRubros.setRubrosAlf: TQuery;
// Objetivo...: devolver un set con los categoriaes disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY descrip');
end;

function TTRubros.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Result := IntToStr(StrToInt(tabla.FieldByName('idrubro').AsString) + 1);
end;

procedure TTRubros.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Rubros', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.  Rubro', 1, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('idrubro').AsString >= iniciar) and (tabla.FieldByName('idrubro').AsString <= finalizar) then ListLinea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('idrubro').AsString < iniciar) or (tabla.FieldByName('idrubro').AsString > finalizar) then ListLinea(salida);
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

procedure TTRubros.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('idrubro').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
end;

procedure TTRubros.BuscarPorcategoria(xexpr: string);
begin
  tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTRubros.BuscarPorId(xexpr: string);
begin
  tabla.IndexFieldNames := 'idrubro';
  tabla.FindNearest([xexpr]);
end;

procedure TTRubros.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('idrubro').DisplayLabel := 'Id.'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción';
  end;
  Inc(conexiones);
end;

procedure TTRubros.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function rubro: TTRubros;
begin
  if xrubro_cuot = nil then
    xrubro_cuot := TTRubros.Create;
  Result := xrubro_cuot;
end;

{===============================================================================}

initialization

finalization
  xrubro_cuot.Free;

end.
