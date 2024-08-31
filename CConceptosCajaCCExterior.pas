unit CConceptosCajaCCExterior;

interface

uses SysUtils, CListar, DB, DBTables, CUtiles, CIDBFM;

type

TTConceptoCaja = class(TObject)            // Superclase
  idconcepto, concepto, codcta, tipomov: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xidconcepto, xconcepto, xcodcta, xtipomov: string);
  procedure   Borrar(xidconcepto: string);
  function    Buscar(xidconcepto: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xidconcepto: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorCodigo(xcodigo: string);
  procedure   BuscarPorNombre(xconcepto: string);
  function    setConceptos: TQuery;
  function    setConceptosIngresos: TQuery;
  function    setConceptosEgresos: TQuery;

  procedure   FiltrarConceptosIngreso;
  procedure   FiltrarConceptosEgreso;
  procedure   QuitarFiltro;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  { Declaraciones Privadas }
end;

function conccaja: TTConceptoCaja;

implementation

var
  xconceptocaja: TTConceptoCaja = nil;

constructor TTConceptoCaja.Create;
begin
  inherited Create;
  tabla    := datosdb.openDB('conceptos_caja', '');
end;

destructor TTConceptoCaja.Destroy;
begin
  inherited Destroy;
end;

procedure TTConceptoCaja.Grabar(xidconcepto, xconcepto, xcodcta, xtipomov: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidconcepto) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idconcepto').AsString := xidconcepto;
  tabla.FieldByName('descrip').AsString    := xconcepto;
  tabla.FieldByName('codcta').AsString     := xcodcta;
  tabla.FieldByName('tipomov').AsString    := xtipomov;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
  datosdb.refrescar(tabla);
end;

procedure TTConceptoCaja.Borrar(xidconcepto: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xidconcepto) then
    begin
      tabla.Delete;
      datosdb.refrescar(tabla);
      getDatos(tabla.FieldByName('idconcepto').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTConceptoCaja.Buscar(xidconcepto: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then tabla.Open;
  if tabla.IndexFieldNames <> 'idconcepto' then tabla.IndexFieldNames := 'idconcepto';
  if tabla.FindKey([xidconcepto]) then Result := True else Result := False;
end;

procedure  TTConceptoCaja.getDatos(xidconcepto: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xidconcepto) then
    begin
      idconcepto := tabla.FieldByName('idconcepto').AsString;
      concepto   := tabla.FieldByName('descrip').AsString;
      codcta     := tabla.FieldByName('codcta').AsString;
      tipomov    := tabla.FieldByName('tipomov').AsString;
    end
   else
    begin
      idconcepto := ''; concepto := ''; codcta := ''; tipomov := '';
    end;
end;

function TTConceptoCaja.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
var
  indice: String;
  filtro: Boolean;
begin
  filtro := tabla.Filtered;
  tabla.Filtered := False;
  indice := tabla.IndexFieldNames;
  tabla.IndexFieldNames := 'idconcepto';
  tabla.Refresh; tabla.Last;
  if Length(Trim(tabla.FieldByName('idconcepto').AsString)) > 0 then Result := IntToStr(tabla.FieldByName('idconcepto').AsInteger + 1) else Result := '1';
  tabla.IndexFieldNames := indice;
  tabla.Filtered := filtro;
end;

function TTConceptoCaja.setConceptos: TQuery;
// Objetivo...: devolver un set con los conceptos existentes
begin
  Result := datosdb.tranSQL('SELECT idconcepto, descrip, codcta FROM conceptos_caja ORDER BY descrip');
end;

function TTConceptoCaja.setConceptosIngresos: TQuery;
// Objetivo...: devolver un set con los conceptos existentes
begin
  Result := datosdb.tranSQL('SELECT idconcepto, descrip, codcta FROM conceptos_caja WHERE tipomov = 1 ORDER BY descrip');
end;

function TTConceptoCaja.setConceptosEgresos: TQuery;
// Objetivo...: devolver un set con los conceptos existentes
begin
  Result := datosdb.tranSQL('SELECT idconcepto, descrip, codcta FROM conceptos_caja WHERE tipomov = 2 ORDER BY descrip');
end;

procedure TTConceptoCaja.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias

procedure ListarLinea(salida: char);
Begin
  List.Linea(0, 0, tabla.FieldByName('idconcepto').AsString + '     ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(85, list.Lineactual, tabla.FieldByName('codcta').AsString, 2, 'Arial, normal, 8', salida, 'S');
end;

begin
  if orden = 'A' then tabla.IndexFieldNames := 'descrip';

  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Conceptos Imputación Caja', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(3) +  'Concepto', 1, 'Arial, cursiva, 8');
  List.Titulo(85, list.Lineactual, 'Cód.Cta.', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('idconcepto').AsString >= iniciar) and (tabla.FieldByName('idconcepto').AsString <= finalizar) then ListarLinea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('idconcepto').AsString < iniciar) or (tabla.FieldByName('idconcepto').AsString > finalizar) then ListarLinea(salida);
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

procedure TTConceptoCaja.BuscarPorCodigo(xcodigo: string);
begin
  if tabla.IndexFieldNames <> 'idconcepto' then tabla.IndexFieldNames := 'idconcepto';
  tabla.FindNearest([xcodigo]);
end;

procedure TTConceptoCaja.BuscarPorNombre(xconcepto: string);
begin
  if tabla.IndexName <> 'descrip' then tabla.IndexFieldNames := 'descrip';
  tabla.FindNearest([xconcepto]);
end;

procedure TTConceptoCaja.FiltrarConceptosIngreso;
Begin
  datosdb.Filtrar(tabla, 'tipomov = 1');
end;

procedure TTConceptoCaja.FiltrarConceptosEgreso;
Begin
  datosdb.Filtrar(tabla, 'tipomov = 2');
end;

procedure TTConceptoCaja.QuitarFiltro;
// Objetivo...: quitar filtro
begin
  datosdb.QuitarFiltro(tabla); 
end;

procedure TTConceptoCaja.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('idconcepto').DisplayLabel := 'Cód.'; tabla.FieldByName('descrip').DisplayLabel := 'Concepto';
    tabla.FieldByName('codcta').DisplayLabel := 'Cód.Cta.'; tabla.FieldByName('tipomov').DisplayLabel := 'T.Mov.';
  end;
  Inc(conexiones);
end;

procedure TTConceptoCaja.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones < 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function conccaja: TTConceptoCaja;
begin
  if xconceptocaja = nil then
    xconceptocaja := TTConceptoCaja.Create;
  Result := xconceptocaja;
end;

{===============================================================================}

initialization

finalization
  xconceptocaja.Free;

end.
