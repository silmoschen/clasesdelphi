unit CTarifasMagni;

interface

uses SysUtils, CListar, DB, DBTables, CUtiles, CIDBFM, Classes;

type

TTarifas = class(TObject)            // Superclase
  Items, Descrip, Diaria: string; Monto: Real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xitems, xdescrip, xdiaria: string; xmonto: Real);
  procedure   Borrar(xitems: string);
  function    Buscar(xitems: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xitems: string);

  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorCodigo(xcodigo: string);
  procedure   BuscarPorNombre(xdescrip: string);

  function    setTarifas: TStringList;
  function    setTarifaDiaria(xitems: String): Boolean;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  procedure   ListarLinea(salida: char);
  { Declaraciones Privadas }
end;

function tarifas: TTarifas;

implementation

var
  xtarifas: TTarifas = nil;

constructor TTarifas.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('tarifas', '');
end;

destructor TTarifas.Destroy;
begin
  inherited Destroy;
end;

procedure TTarifas.Grabar(xitems, xdescrip, xdiaria: string; xmonto: Real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xitems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('items').AsString   := xitems;
  tabla.FieldByName('descrip').AsString := xdescrip;
  tabla.FieldByName('diaria').AsString  := xdiaria;
  tabla.FieldByName('monto').AsFloat    := xmonto;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
  datosdb.refrescar(tabla);
end;

procedure TTarifas.Borrar(xitems: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xitems) then begin
    tabla.Delete;
    getDatos(tabla.FieldByName('items').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTarifas.Buscar(xitems: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'Items' then tabla.IndexFieldNames := 'Items';
  if tabla.FindKey([xitems]) then Result := True else Result := False;
end;

procedure  TTarifas.getDatos(xitems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xitems) then begin
    Items   := tabla.FieldByName('items').AsString;
    Descrip := tabla.FieldByName('descrip').AsString;
    Diaria  := tabla.FieldByName('diaria').AsString;
    monto   := tabla.FieldByName('monto').AsFloat;
  end else begin
    items := ''; descrip := ''; monto := 0; diaria := '';
  end;
end;

function TTarifas.Nuevo: string;
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

procedure TTarifas.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tabla.IndexFieldNames := 'Descrip';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Precios de Tarifas', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Items         Descripción', 1, 'Arial, cursiva, 8');
  List.Titulo(75, list.Lineactual, 'Monto', 2, 'Arial, cursiva, 8');
  List.Titulo(89, list.Lineactual, 'TD', 3, 'Arial, cursiva, 8');
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

procedure TTarifas.ListarLinea(salida: char);
Begin
  List.Linea(0, 0, tabla.FieldByName('items').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.importe(80, list.Lineactual, '', tabla.FieldByName('monto').AsFloat, 2, 'Arial, normal, 8');
  List.Linea(90, list.Lineactual, tabla.FieldByName('diaria').AsString, 3, 'Arial, normal, 8', salida, 'S');
end;

procedure TTarifas.BuscarPorCodigo(xcodigo: string);
begin
  if tabla.IndexFieldNames <> 'Items' then tabla.IndexFieldNames := 'Items';
  tabla.FindNearest([xcodigo]);
end;

procedure TTarifas.BuscarPorNombre(xdescrip: string);
begin
  if tabla.IndexName <> 'Descrip' then tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xdescrip]);
end;

function  TTarifas.setTarifas: TStringList;
// Objetivo...: devolver un set con las tarifas
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if tabla.IndexName <> 'Descrip' then tabla.IndexFieldNames := 'Descrip';
  tabla.First;
  while not tabla.Eof do Begin
    l.Add(tabla.FieldByName('items').AsString + tabla.FieldByName('descrip').AsString + ';1' + tabla.FieldByName('monto').AsString + ';2' + tabla.FieldByName('diaria').AsString);
    tabla.Next;
  end;
  Result := l;
  tabla.IndexFieldNames := 'Items';
end;

function TTarifas.setTarifaDiaria(xitems: String): Boolean;
// Objetivo...: conectar tablas de persistencia
begin
  Result := False;
  if Buscar(xitems) then
    if tabla.FieldByName('diaria').AsString = 'S' then Result := True else Result := False;
end;

procedure TTarifas.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('items').DisplayLabel := 'Items'; tabla.FieldByName('Descrip').DisplayLabel := 'Descripción'; tabla.FieldByName('monto').DisplayLabel := 'Monto';
  end;
  Inc(conexiones);
end;

procedure TTarifas.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones < 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function tarifas: TTarifas;
begin
  if xtarifas = nil then
    xtarifas := TTarifas.Create;
  Result := xtarifas;
end;

{===============================================================================}

initialization

finalization
  xtarifas.Free;

end.
