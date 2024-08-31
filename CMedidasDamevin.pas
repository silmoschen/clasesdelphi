unit CMedidasDamevin;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar;

type

TTMedidas = class(TObject)
  idmedida, Descrip: string; precio: real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xidmedida, xDescrip: string; xprecio: real);
  procedure   Borrar(xidmedida: string);
  function    Buscar(xidmedida: string): boolean;
  procedure   getDatos(xidmedida: string);
  function    setMedidas: TQuery;
  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorId(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  procedure   ListLinea(salida: char);
  { Declaraciones Privadas }
end;

function medida: TTMedidas;

implementation

var
  xcomprob: TTMedidas = nil;

constructor TTMedidas.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('medidas', 'idmedida');
end;

destructor TTMedidas.Destroy;
begin
  inherited Destroy;
end;

procedure TTMedidas.Grabar(xidmedida, xdescrip: string; xprecio: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidmedida) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idmedida').AsString := xidmedida;
  tabla.FieldByName('descrip').AsString  := xdescrip;
  tabla.FieldByName('precio').AsFloat    := xprecio;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
end;

procedure TTMedidas.Borrar(xidmedida: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xidmedida) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('idmedida').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTMedidas.Buscar(xidmedida: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'idmedida' then tabla.IndexFieldNames := 'idmedida';
  if tabla.FindKey([xidmedida]) then Result := True else Result := False;
end;

procedure  TTMedidas.getDatos(xidmedida: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xidmedida) then
    begin
      idmedida := tabla.FieldByName('idmedida').AsString;
      descrip  := tabla.FieldByName('descrip').AsString;
      precio   := tabla.FieldByName('precio').AsFloat;
    end
   else
    begin
      idmedida := ''; descrip := ''; precio := 0;
    end;
end;

function TTMedidas.setMedidas: TQuery;
// Objetivo...: devolver un set con los sabores disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName);
end;

function TTMedidas.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Result := IntToStr(StrToInt(tabla.FieldByName('idmedida').AsString) + 1);
end;

procedure TTMedidas.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Medidas', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.  Medida/Peso', 1, 'Courier New, cursiva, 9');
  List.Titulo(79, list.Lineactual, 'Precio', 2, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('idmedida').AsString >= iniciar) and (tabla.FieldByName('idmedida').AsString <= finalizar) then ListLinea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('idmedida').AsString < iniciar) or (tabla.FieldByName('idmedida').AsString > finalizar) then ListLinea(salida);
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

procedure TTMedidas.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('idmedida').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
  List.importe(85, list.Lineactual, '', tabla.FieldByName('precio').AsFloat, 2, 'Courier New, normal, 9');
  List.Linea(90, list.Lineactual, ' ', 3, 'Courier New, normal, 9', salida, 'S');
end;

procedure TTMedidas.BuscarPorDescrip(xexpr: string);
begin
  tabla.IndexName := 'Medidas_Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTMedidas.BuscarPorId(xexpr: string);
begin
  tabla.IndexFieldNames := 'idmedida';
  tabla.FindNearest([xexpr]);
end;

procedure TTMedidas.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then
    if not tabla.Active then tabla.Open;
  tabla.FieldByName('idmedida').DisplayLabel := 'Id. Medida'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción'; tabla.FieldByName('precio').DisplayLabel := 'Precio';
  Inc(conexiones);
end;

procedure TTMedidas.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function medida: TTMedidas;
begin
  if xcomprob = nil then
    xcomprob := TTMedidas.Create;
  Result := xcomprob;
end;

{===============================================================================}

initialization

finalization
  xcomprob.Free;

end.
