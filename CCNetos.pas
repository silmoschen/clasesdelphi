unit CCNetos;

interface

uses SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM;

type

TTCNetos = class(TObject)            // Superclase
  codmov, descrip, codiva, combustible, Imputariva: string;
  tipomovi, tipoingreso: integer;
  retencion: real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodmov, xdescrip, xcodiva: string; xtipomovi, xtipoingreso: integer);
  procedure   GrabarRetencion(xcodmov: String; xretencion: real);
  procedure   ProrrateaCombustible(xcodmov: String; xprorrateo: Boolean);
  procedure   Borrar(xcodmov: string);
  function    Buscar(xcodmov: string): boolean;
  procedure   getDatos(xcodmov: string);
  procedure   getNetosCompras;
  procedure   getNetosVentas;
  function    setNetosCompras: TQuery;
  function    setNetosVentas: TQuery;
  procedure   QuitarFiltro;
  procedure   BuscarPorId(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);
  function    setTipoMovimiento(xcodiva: String; xcompra_venta: ShortInt): String;
  procedure   FijarSoloIva(xcodmov, xmodo: String);

  procedure   Via(xvia: string);
  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure DescripCol;
end;

function netos: TTCNetos;

implementation

var
  xnetos: TTCNetos = nil;

constructor TTCNetos.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('compnet', 'codmov');
end;

destructor TTCNetos.Destroy;
begin
  inherited Destroy;
end;

procedure TTCNetos.Grabar(xcodmov, xdescrip, xcodiva: string; xtipomovi, xtipoingreso: integer);
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
  tabla.FieldByName('codiva').AsString       := xcodiva;
  tabla.FieldByName('tipomovi').AsInteger    := xtipomovi;
  tabla.FieldByName('tipoingreso').AsInteger := xtipoingreso;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
  if filtro then tabla.Filtered := filtro;
  datosdb.refrescar(tabla);
end;

procedure TTCNetos.ProrrateaCombustible(xcodmov: String; xprorrateo: Boolean);
Begin
  if Buscar(xcodmov) then Begin
    tabla.Edit;
    if xprorrateo then tabla.FieldByName('combustible').AsString := 'S' else
      tabla.FieldByName('combustible').AsString := 'N';
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.refrescar(tabla);
  end;
end;

procedure TTCNetos.GrabarRetencion(xcodmov: String; xretencion: real);
var
  filtro: boolean;
begin
  filtro := False;
  if tabla.Filtered then Begin
    filtro := tabla.Filtered; tabla.Filtered := False;
  end;
  if Buscar(xcodmov) then Begin
    tabla.Edit;
    tabla.FieldByName('retencion').AsFloat := xretencion;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
  end;
  if filtro then tabla.Filtered := filtro;
  datosdb.refrescar(tabla);
end;

procedure TTCNetos.Borrar(xcodmov: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodmov) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('codmov').Value);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
  datosdb.refrescar(tabla);
end;

function TTCNetos.Buscar(xcodmov: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'Codmov' then tabla.IndexFieldNames := 'Codmov';
  if tabla.FindKey([xcodmov]) then Result := True else Result := False;
end;

procedure  TTCNetos.getDatos(xcodmov: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if conexiones = 0 then conectar;
  tabla.Refresh;
  if Buscar(xcodmov) then
    begin
      codmov      := tabla.FieldByName('codmov').AsString;
      descrip     := tabla.FieldByName('descrip').AsString;
      codiva      := tabla.FieldByName('codiva').AsString;
      tipomovi    := tabla.FieldByName('tipomovi').AsInteger;
      tipoingreso := tabla.FieldByName('tipoingreso').AsInteger;
      retencion   := tabla.FieldByName('retencion').AsFloat;
      if datosdb.verificarSiExisteCampo(tabla, 'combustible') then combustible := tabla.FieldByName('combustible').AsString;
      if datosdb.verificarSiExisteCampo(tabla, 'Imputariva') then Imputariva := tabla.FieldByName('Imputariva').AsString;
    end
   else
    begin
      codmov := ''; descrip := ''; codiva := ''; tipomovi := 0; tipoingreso := 0; retencion := 0; combustible := 'N'; Imputariva := 'N';
    end;
end;

procedure TTCNetos.getNetosCompras;
begin
  datosdb.Filtrar(tabla, 'Tipomovi = 1');
end;

procedure TTCNetos.getNetosVentas;
begin
  datosdb.Filtrar(tabla, 'Tipomovi = 2');
end;

function TTCNetos.setNetosCompras: TQuery;
// Objetivo...: Devolver Netos Compras
Begin
  Result := datosdb.tranSQL('select * from ' + tabla.TableName + ' where tipomovi = 1');
end;

function TTCNetos.setNetosVentas: TQuery;
// Objetivo...: Devolver Netos Ventas
Begin
  Result := datosdb.tranSQL('select * from ' + tabla.TableName + ' where tipomovi = 2');
end;

procedure TTCNetos.QuitarFiltro;
begin
  datosdb.QuitarFiltro(tabla);
end;

procedure TTCNetos.FijarSoloIva(xcodmov, xmodo: String);
// Objetivo...: Fijar condicion respecto al I.V.A.
begin
  if Buscar(xcodmov) then Begin
    tabla.Edit;
    tabla.FieldByName('Imputariva').AsString := xmodo;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.refrescar(tabla);
  end;
end;

procedure TTCNetos.Via(xvia: string);
// Objetivo...: conectar tablas de persistencia
begin
  if not datosdb.verificarSiExisteCampo('compnet', 'combustible', dbs.dirSistema + '\' + xvia) then datosdb.tranSQL(dbs.dirSistema + '\' + xvia, 'alter table compnet add combustible char(1)');
  tabla := nil; tabla := datosdb.openDB('compnet', 'codmov', '', dbs.dirSistema + '\' + xvia);
  conexiones := 0; conectar;
end;

procedure TTCNetos.BuscarPorId(xexpr: string);
begin
  if tabla.IndexFieldNames <> 'Codmov' then tabla.IndexFieldNames := 'Codmov';
  tabla.FindNearest([xexpr]);
end;

procedure TTCNetos.BuscarPorNombre(xexpr: string);
begin
  if tabla.IndexFieldNames <> 'Descrip' then tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexpr]);
end;

function  TTCNetos.setTipoMovimiento(xcodiva: String; xcompra_venta: ShortInt): String;
// Objetivo...: Asociar el tipo de movimiento de acuerdo a la condición de I.V.A.
Begin
  Result := '';
  tabla.First;
  while not tabla.Eof do Begin
    if (tabla.FieldByName('codiva').AsString = xcodiva) and (tabla.FieldByName('tipomovi').AsInteger = xcompra_venta) then Begin
      Result := tabla.FieldByName('codmov').AsString;
      Break;
    end;
    tabla.Next;
  end;
end;

procedure TTCNetos.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    if not datosdb.verificarSiExisteCampo(tabla, 'Imputariva') then Begin
      tabla.Close;
      datosdb.tranSQL(tabla.DatabaseName, 'alter table ' + tabla.TableName + ' add Imputariva char(1)');
      tabla.Open;
    end;
  end;
  Inc(conexiones);
  DescripCol;
end;

procedure TTCNetos.DescripCol;
// Objetivo...: leyendas
begin
  tabla.FieldByName('codmov').DisplayLabel := 'Cód'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción'; tabla.FieldByName('codiva').DisplayLabel := 'I.V.A.'; tabla.FieldByName('tipomovi').Visible := False; tabla.FieldByName('tipoingreso').Visible := False; tabla.FieldByName('retencion').DisplayLabel := 'Ret.Combust.';
  if datosdb.verificarSiExisteCampo(tabla, 'combustible') then tabla.FieldByName('combustible').DisplayLabel := 'Pro. Combustibles';
  if datosdb.verificarSiExisteCampo(tabla, 'Imputariva') then tabla.FieldByName('Imputariva').DisplayLabel := 'Imp. IVA';
end;

procedure TTCNetos.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function netos: TTCNetos;
begin
  if xnetos = nil then
    xnetos := TTCNetos.Create;
  Result := xnetos;
end;

{===============================================================================}

initialization

finalization
  xnetos.Free;

end.