unit CCTipoMovIVA;

interface

uses SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM;

type

TTipoMovIVA = class(TObject)            // Superclase
  Codmov, Descrip, CV: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Registrar(xcodmov, xdescrip, xcv: string);
  procedure   Borrar(xcodmov: string);
  function    Buscar(xcodmov: string): boolean;
  procedure   getDatos(xcodmov: string);

  procedure   BuscarPorId(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);

  procedure   FiltrarMovimientosCompras;
  procedure   FiltrarMovimientosVentas;
  procedure   QuitarFiltro;

  function    setMovimientosCompras: TQuery;
  function    setMovimientosVentas: TQuery;

  procedure   Via(xvia: string);
  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure DescripCol;
end;

function tipomovimiento: TTipoMovIVA;

implementation

var
  xtipomovimiento: TTipoMovIVA = nil;

constructor TTipoMovIVA.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('tipomov', '');
end;

destructor TTipoMovIVA.Destroy;
begin
  inherited Destroy;
end;

procedure TTipoMovIVA.Registrar(xcodmov, xdescrip, xcv: string);
// Objetivo...: Grabar Atributos del Objeto
var
  filtro: boolean;
begin
  filtro := False;
  if tabla.Filtered then Begin
    filtro := tabla.Filtered; tabla.Filtered := False;
  end;
  if Buscar(xcodmov) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codmov').AsString       := xcodmov;
  tabla.FieldByName('descrip').AsString      := xdescrip;
  tabla.FieldByName('cv').AsString           := xcv;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
  if filtro then tabla.Filtered := filtro;
  datosdb.refrescar(tabla);
end;

procedure TTipoMovIVA.Borrar(xcodmov: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodmov) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('codmov').Value);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
  datosdb.refrescar(tabla);
end;

function TTipoMovIVA.Buscar(xcodmov: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'Codmov' then tabla.IndexFieldNames := 'Codmov';
  if tabla.FindKey([xcodmov]) then Result := True else Result := False;
end;

procedure  TTipoMovIVA.getDatos(xcodmov: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if conexiones = 0 then conectar;
  tabla.Refresh;
  if Buscar(xcodmov) then begin
    codmov  := tabla.FieldByName('codmov').AsString;
    descrip := tabla.FieldByName('descrip').AsString;
    cv      := tabla.FieldByName('cv').AsString;
  end else begin
    codmov := ''; descrip := ''; cv := '';
  end;
end;

procedure TTipoMovIVA.FiltrarMovimientosCompras;
begin
  datosdb.Filtrar(tabla, 'cv = ' + '''' + 'C' + '''');
end;

procedure TTipoMovIVA.FiltrarMovimientosVentas;
begin
  datosdb.Filtrar(tabla, 'cv = ' + '''' + 'V' + '''');
end;

procedure TTipoMovIVA.QuitarFiltro;
begin
  datosdb.QuitarFiltro(tabla);
end;

function TTipoMovIVA.setMovimientosCompras: TQuery;
// Objetivo...: devolver un set con los movimientos de compras
begin
  Result := datosdb.tranSQL('select * from ' + tabla.TableName + ' where cv = ' + '''' + 'C' + '''' + ' order by descrip');
end;

function TTipoMovIVA.setMovimientosVentas: TQuery;
// Objetivo...: devolver un set con los movimientos de ventas
begin
  Result := datosdb.tranSQL('select * from ' + tabla.TableName + ' where cv = ' + '''' + 'V' + '''' + ' order by descrip');
end;

procedure TTipoMovIVA.Via(xvia: string);
// Objetivo...: conectar tablas de persistencia
begin
  if not datosdb.verificarSiExisteCampo('compnet', 'combustible', dbs.dirSistema + '\' + xvia) then datosdb.tranSQL(dbs.dirSistema + '\' + xvia, 'alter table compnet add combustible char(1)');
  tabla := nil; tabla := datosdb.openDB('compnet', 'codmov', '', dbs.dirSistema + '\' + xvia);
  conexiones := 0; conectar;
end;

procedure TTipoMovIVA.BuscarPorId(xexpr: string);
begin
  if tabla.IndexFieldNames <> 'Codmov' then tabla.IndexFieldNames := 'Codmov';
  tabla.FindNearest([xexpr]);
end;

procedure TTipoMovIVA.BuscarPorNombre(xexpr: string);
begin
  if tabla.IndexFieldNames <> 'Descrip' then tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTipoMovIVA.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
  DescripCol;
end;

procedure TTipoMovIVA.DescripCol;
// Objetivo...: leyendas
begin
  tabla.FieldByName('codmov').DisplayLabel := 'Cód'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción'; tabla.FieldByName('cv').DisplayLabel := 'C/V';
end;

procedure TTipoMovIVA.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function tipomovimiento: TTipoMovIVA;
begin
  if xtipomovimiento = nil then
    xtipomovimiento := TTipoMovIVA.Create;
  Result := xtipomovimiento;
end;

{===============================================================================}

initialization

finalization
  xtipomovimiento.Free;

end.