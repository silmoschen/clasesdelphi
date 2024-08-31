unit CConceptosCobrosCIC;

interface

uses SysUtils, CListar, DB, DBTables, CUtiles, CIDBFM;

type

TTConceptoCobros = class(TObject)            // Superclase
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
  procedure   BuscarPorCodigo(xitems: string);
  procedure   BuscarPorNombre(xdescrip: string);
  function    setConceptos: TQuery;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  procedure Enccol;
  { Declaraciones Privadas }
end;

function conceptoing: TTConceptoCobros;

implementation

var
  xconceptoing: TTConceptoCobros = nil;

constructor TTConceptoCobros.Create;
begin
  inherited Create;
  tabla    := datosdb.openDB('itemscobro', '');
end;

destructor TTConceptoCobros.Destroy;
begin
  inherited Destroy;
end;

procedure TTConceptoCobros.Grabar(xitems, xdescrip: string; xmonto: Real);
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

procedure TTConceptoCobros.Borrar(xitems: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xitems) then
    begin
      tabla.Delete;
      datosdb.refrescar(tabla);
      getDatos(tabla.FieldByName('items').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTConceptoCobros.Buscar(xitems: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then tabla.Open;
  if tabla.IndexFieldNames <> 'items' then tabla.IndexFieldNames := 'items';
  Result := tabla.FindKey([xitems]);
end;

procedure  TTConceptoCobros.getDatos(xitems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xitems) then
    begin
      items   := tabla.FieldByName('items').AsString;
      descrip := tabla.FieldByName('descrip').AsString;
      monto   := tabla.FieldByName('monto').AsFloat;
    end
   else
    begin
      items := ''; descrip := ''; monto := 0;
    end;
end;

function TTConceptoCobros.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
var
  indice: String;
  filtro: Boolean;
begin
  filtro := tabla.Filtered;
  tabla.Filtered := False;
  indice := tabla.IndexFieldNames;
  tabla.IndexFieldNames := 'items';
  tabla.Refresh; tabla.Last;
  if Length(Trim(tabla.FieldByName('items').AsString)) > 0 then Result := IntToStr(tabla.FieldByName('items').AsInteger + 1) else Result := '1';
  tabla.IndexFieldNames := indice;
  tabla.Filtered := filtro;
end;

function TTConceptoCobros.setConceptos: TQuery;
// Objetivo...: devolver un set con los conceptos existentes
begin
  Result := datosdb.tranSQL('SELECT items, descrip, monto FROM itemscobros ORDER BY descrip');
end;

procedure TTConceptoCobros.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias

procedure ListarLinea(salida: char);
Begin
  List.Linea(0, 0, tabla.FieldByName('items').AsString + '     ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Importe(90, list.Lineactual, '', tabla.FieldByName('monto').AsFloat, 2, 'Arial, normal, 8');
  List.Linea(90, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
end;

begin
  if orden = 'A' then tabla.IndexFieldNames := 'descrip';

  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Conceptos de Cobro', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(3) +  'Concepto', 1, 'Arial, cursiva, 8');
  List.Titulo(85, list.Lineactual, 'Monto', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
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

procedure TTConceptoCobros.BuscarPorCodigo(xitems: string);
begin
  if tabla.IndexFieldNames <> 'items' then tabla.IndexFieldNames := 'items';
  tabla.FindNearest([xitems]);
end;

procedure TTConceptoCobros.BuscarPorNombre(xdescrip: string);
begin
  if tabla.IndexName <> 'descrip' then tabla.IndexFieldNames := 'descrip';
  tabla.FindNearest([xdescrip]);
end;

procedure TTConceptoCobros.Enccol;
// Objetivo...: conectar tablas de persistencia
begin
  tabla.FieldByName('items').DisplayLabel := 'Cód.'; tabla.FieldByName('descrip').DisplayLabel := 'Concepto';
  tabla.FieldByName('monto').DisplayLabel := 'Monto';
end;

procedure TTConceptoCobros.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    Enccol;
  end;
  Inc(conexiones);
end;

procedure TTConceptoCobros.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones < 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function conceptoing: TTConceptoCobros;
begin
  if xconceptoing = nil then
    xconceptoing := TTConceptoCobros.Create;
  Result := xconceptoing;
end;

{===============================================================================}

initialization

finalization
  xconceptoing.Free;

end.
