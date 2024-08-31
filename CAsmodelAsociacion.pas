unit CAsmodelAsociacion;

interface

uses CContabilidadAsociacion, CPlanctasAsociacion, SysUtils, CListar,
     DBTables, CBDT, CUtiles, CIDBFM, CLibContAsociacion;

type

TTAsmod = class(TTLibrosCont)
  codasiento, descrip: string;        // Cabecera
  nromovi, codcta, dh, concepto, cuenta: string;   // Asiento
  asienmod, cabasmod: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Nuevo: String;
  function    Buscar(xcodasiento: string): boolean; overload;
  function    Buscar(xcodasiento, xnromovi: string): boolean; overload;
  procedure   Grabar(xcodasiento, xdescrip: string); overload;
  procedure   Grabar(xcodasiento, xnromovi, xcodcta, xdh, xconcepto: string); overload;
  procedure   Borrar(xcodasiento: string);
  procedure   getDatos(xcodasiento: string);
  function    setItems(xcodasiento: string): TQuery; overload;
  function    setAsientosModelo: TQuery; overload;
  function    setAsientosModelo(xcodasiento: string): TQuery; overload;

  procedure   BuscarPorCodigo(xexpresion: String);
  procedure   BuscarPorDescrip(xexpresion: String);

  procedure   Via(xvia: string);
  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
 protected
  { Declaraciones Protegidas }
   procedure   BorrarItems(xcodasiento: string);
end;

function asienmod: TTAsmod;

implementation

var
  xasienmod: TTAsmod = nil;

constructor TTAsmod.Create;
begin
  inherited Create;
  cabasmod   := datosdb.openDB('cabasmod', 'Codasiento', '', contabilidad.dbcc);
  asienmod   := datosdb.openDB('asienmod', 'Codasiento;Nromovi', '', contabilidad.dbcc);
  dbconexion := contabilidad.dbcc;
end;

destructor TTAsmod.Destroy;
begin
  inherited Destroy;
end;

function TTAsmod.Nuevo: String;
Begin
  if cabasmod.IndexFieldNames <> 'codasiento' then cabasmod.IndexFieldNames := 'codasiento';
  if cabasmod.RecordCount = 0 then Result := '1' else Begin
    cabasmod.Last;
    Result := IntToStr(cabasmod.FieldByName('codasiento').AsInteger + 1);
  end;
end;

function TTAsmod.Buscar(xcodasiento: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if cabasmod.IndexFieldNames <> 'codasiento' then cabasmod.IndexFieldNames := 'codasiento';
  if cabasmod.FindKey([xcodasiento]) then Result := True else Result := False;
end;

function TTAsmod.Buscar(xcodasiento, xnromovi: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  Result := datosdb.Buscar(asienmod, 'codasiento', 'nromovi', xcodasiento, xnromovi);
end;

procedure TTAsmod.Grabar(xcodasiento, xdescrip: string);
// Objetivo...: Grabar Atributos del Objeto - identificación del asiento modelo
begin
  if Buscar(xcodasiento) then cabasmod.Edit else cabasmod.Append;
  cabasmod.FieldByName('codasiento').AsString := xcodasiento;
  cabasmod.FieldByName('descrip').AsString    := xdescrip;
  try
    cabasmod.Post;
  except
    cabasmod.Cancel;
  end;
  datosdb.closeDB(cabasmod); cabasmod.Open;
end;

procedure TTAsmod.Grabar(xcodasiento, xnromovi, xcodcta, xdh, xconcepto: string);
// Objetivo...: Grabar Atributos del Objeto - cabecera de asientos
begin
  if xnromovi = '001' then
    if Buscar(xcodasiento, '001') then BorrarItems(xcodasiento);
  if Buscar(xcodasiento, xnromovi) then asienmod.Edit else asienmod.Append;
  asienmod.FieldByName('codasiento').AsString := xcodasiento;
  asienmod.FieldByName('nromovi').AsString    := xnromovi;
  asienmod.FieldByName('codcta').AsString     := xcodcta;
  asienmod.FieldByName('dh').AsString         := xdh;
  asienmod.FieldByName('concepto').AsString   := xconcepto;
  try
    asienmod.Post;
  except
    asienmod.Cancel;
  end;
  datosdb.closeDB(asienmod); asienmod.Open;
end;

procedure TTAsmod.Borrar(xcodasiento: string);
// Objetivo...: Borrar asiento - baja total
begin
  if Buscar(xcodasiento) then
    begin
      cabasmod.Delete;
      BorrarItems(xcodasiento);
      datosdb.closeDB(cabasmod); cabasmod.Open;
    end;
end;

procedure TTAsmod.BorrarItems(xcodasiento: string);
// Objetivo...: Borrar asiento - cuentas
begin
  datosdb.tranSQL(dbconexion, 'DELETE FROM asienmod WHERE codasiento = ' + '''' + xcodasiento + '''');
  datosdb.closeDB(asienmod); asienmod.Open;
end;

function TTAsmod.setItems(xcodasiento: string): TQuery;
// Objetivo...: devolver un set con los registros del asiento
begin
  Result := datosdb.tranSQL(dbconexion, 'SELECT * FROM asienmod WHERE codasiento = ' + '''' + xcodasiento + '''');
end;

function TTAsmod.setAsientosModelo: TQuery;
// Objetivo...: Devolver un set con los Asientos Definidos
begin
  Result := datosdb.tranSQL(dbconexion, 'SELECT * FROM cabasmod');
end;

function TTAsmod.setAsientosModelo(xcodasiento: string): TQuery;
// Objetivo...: Devolver los datos de un Asiento
begin
  Result := datosdb.tranSQL(dbconexion, 'SELECT * FROM cabasmod WHERE codasiento = ' + '''' + xcodasiento + '''');
end;

procedure TTAsmod.getDatos(xcodasiento: string);
// Objetivos...: Actualizar los atributos para un objeto dado
begin
  cabasmod.Refresh; asienmod.Refresh;
  if Buscar(xcodasiento) then
    begin
      codasiento := cabasmod.FieldByName('codasiento').AsString;
      descrip    := cabasmod.FieldByName('descrip').AsString;
      setItems(xcodasiento);
    end
  else
    begin
      codasiento := ''; descrip := ''; nromovi := ''; codcta := ''; dh := ''; concepto := '';
    end;
end;

procedure TTAsmod.BuscarPorCodigo(xexpresion: String);
// Objetivo...: Buscar por código
begin
  if cabasmod.IndexFieldNames <> 'codasiento' then cabasmod.IndexFieldNames := 'codasiento';
  cabasmod.FindNearest([xexpresion]);
end;

procedure TTAsmod.BuscarPorDescrip(xexpresion: String);
// Objetivo...: Buscar por descripción
begin
  if cabasmod.IndexFieldNames <> 'descrip' then cabasmod.IndexFieldNames := 'descrip';
  cabasmod.FindNearest([xexpresion]);
end;

procedure TTAsmod.Via(xvia: string);
// Objetivo...: Abrir tablas de persistencia en un directorio X
begin
//  planctas.Via(xvia); planctas.FiltrarCtasImputables;
  cabasmod := nil; asienmod := nil;
  cabasmod := datosdb.openDB('cabasmod', 'Codasiento', '', dbs.dirSistema + xvia);
  asienmod := datosdb.openDB('asienmod', 'Codasiento;Nromovi', '', dbs.dirSistema + xvia);
  conectar;
end;

procedure TTAsmod.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not cabasmod.Active then cabasmod.Open;
    cabasmod.FieldByName('codasiento').DisplayLabel := 'Cód.'; cabasmod.FieldByName('descrip').DisplayLabel := 'Descripción';
    if not asienmod.Active then asienmod.Open;
    planctas.conectar;
    planctas.FiltrarCtasImputables;
  end;
  Inc(conexiones);
end;

procedure TTAsmod.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(cabasmod);
    datosdb.closeDB(asienmod);
    planctas.DesactivarFiltro;
    planctas.desconectar;
  end;
end;

{===============================================================================}

function asienmod: TTAsmod;
begin
  if xasienmod = nil then
    xasienmod := TTAsmod.Create;
  Result := xasienmod;
end;

{===============================================================================}

initialization

finalization
  xasienmod.Free;

end.