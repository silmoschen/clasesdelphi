unit CItemsFacturacionMagni;

interface

uses SysUtils, CListar, DB, DBTables, CUtiles, CIDBFM;

type

TTItemsFacturacion = class(TObject)            // Superclase
  Items, Descrip: string; Monto: Real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xitems, xdescrip: string; xmonto: Real);
  procedure   Borrar(xitems: string);
  function    Buscar(xitems: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xitems: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorCodigo(xcodigo: string);
  procedure   BuscarPorNombre(xdescrip: string);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  procedure   ListarLinea(salida: char);
  { Declaraciones Privadas }
end;

function itemsfact: TTItemsFacturacion;

implementation

var
  xitemsfact: TTItemsFacturacion = nil;

constructor TTItemsFacturacion.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('itemsfact', '');
end;

destructor TTItemsFacturacion.Destroy;
begin
  inherited Destroy;
end;

procedure TTItemsFacturacion.Grabar(xitems, xdescrip: string; xmonto: Real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xitems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('items').AsString   := xitems;
  tabla.FieldByName('descrip').AsString := xdescrip;
  tabla.FieldByName('monto').AsFloat    := xmonto;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
  datosdb.refrescar(tabla);
end;

procedure TTItemsFacturacion.Borrar(xitems: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xitems) then begin
    tabla.Delete;
    getDatos(tabla.FieldByName('items').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTItemsFacturacion.Buscar(xitems: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'Items' then tabla.IndexFieldNames := 'Items';
  if tabla.FindKey([xitems]) then Result := True else Result := False;
end;

procedure  TTItemsFacturacion.getDatos(xitems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xitems) then begin
    Items   := tabla.FieldByName('items').AsString;
    Descrip := tabla.FieldByName('descrip').AsString;
    monto   := tabla.FieldByName('monto').AsFloat;
  end else begin
    items := ''; descrip := ''; monto := 0;
  end;
end;

function TTItemsFacturacion.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
var
  indice: String;
begin
  indice := tabla.IndexFieldNames;
  tabla.IndexFieldNames := 'Items';
  tabla.Refresh; tabla.Last;
  if Length(Trim(tabla.FieldByName('items').AsString)) > 0 then Result := IntToStr(tabla.FieldByName('items').AsInteger + 1) else Result := '1';
  tabla.IndexFieldNames := indice;
end;

procedure TTItemsFacturacion.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tabla.IndexFieldNames := 'Descrip';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Items Adicionales', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'It.  Descripción', 1, 'Arial, cursiva, 8');
  List.Titulo(75, list.Lineactual, 'Monto', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('items').AsString >= iniciar) and (tabla.FieldByName('items').AsString <= finalizar) then ListarLinea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('items').AsString < iniciar) or (tabla.FieldByName('items').AsString > finalizar) then ListarLinea(salida);
    // Ordenado Alfabéticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tabla.FieldByName('descrip').AsString >= iniciar) and (tabla.FieldByName('descrip').AsString <= finalizar) then ListarLinea(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('descrip').AsString < iniciar) or (tabla.FieldByName('descrip').AsString > finalizar) then ListarLinea(salida);

    tabla.Next;
  end;
  List.FinList;

  tabla.IndexFieldNames := tabla.IndexFieldNames;
  tabla.First;
end;

procedure TTItemsFacturacion.ListarLinea(salida: char);
Begin
  List.Linea(0, 0, tabla.FieldByName('items').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.importe(80, list.Lineactual, '', tabla.FieldByName('monto').AsFloat, 2, 'Arial, normal, 8');
  List.Linea(85, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
end;

procedure TTItemsFacturacion.BuscarPorCodigo(xcodigo: string);
begin
  if tabla.IndexFieldNames <> 'Items' then tabla.IndexFieldNames := 'Items';
  tabla.FindNearest([xcodigo]);
end;

procedure TTItemsFacturacion.BuscarPorNombre(xdescrip: string);
begin
  if tabla.IndexName <> 'Descrip' then tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xdescrip]);
end;

procedure TTItemsFacturacion.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('items').DisplayLabel := 'Items'; tabla.FieldByName('Descrip').DisplayLabel := 'Descripción'; tabla.FieldByName('monto').DisplayLabel := 'Monto';
  end;
  Inc(conexiones);
end;

procedure TTItemsFacturacion.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones < 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function itemsfact: TTItemsFacturacion;
begin
  if xitemsfact = nil then
    xitemsfact := TTItemsFacturacion.Create;
  Result := xitemsfact;
end;

{===============================================================================}

initialization

finalization
  xitemsfact.Free;

end.
