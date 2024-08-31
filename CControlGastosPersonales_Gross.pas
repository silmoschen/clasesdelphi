unit CControlGastosPersonales_Gross;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CUtilidadesArchivos;

type

TTControlGastos = class
  control: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xperiodo, xdia, xitems: String): Boolean;
  procedure   Registrar(xperiodo, xdia, xitems, xconcepto: String; xmonto: Real);
  procedure   Borrar(xperiodo, xdia, xitems: String);
  function    setGastos(xperiodo: String): TQuery;

  procedure   conectar(xperiodo: String);
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  directorio: String;
  conexiones: shortint;
end;

function controlg: TTControlGastos;

implementation

var
  xcontrolg: TTControlGastos = nil;

constructor TTControlGastos.Create;
begin
end;

destructor TTControlGastos.Destroy;
begin
  inherited Destroy;
end;

function  TTControlGastos.Buscar(xperiodo, xdia, xitems: String): Boolean;
// Objetivo...: Buscar Items
Begin
  Result := datosdb.Buscar(control, 'periodo', 'dia', 'items', xperiodo, xdia, xitems);
end;

procedure TTControlGastos.Registrar(xperiodo, xdia, xitems, xconcepto: String; xmonto: Real);
// Objetivo...: Registrar Items
Begin
  if Buscar(xperiodo, xdia, xitems) then control.Edit else control.Append;
  control.FieldByName('periodo').AsString     := xperiodo;
  control.FieldByName('dia').AsString         := xdia;
  control.FieldByName('items').AsString       := xitems;
  control.FieldByName('concepto').AsString    := xconcepto;
  control.FieldByName('monto').AsFloat        := xmonto;
  try
    control.Post
   except
    control.Cancel
  end;
end;

procedure TTControlGastos.Borrar(xperiodo, xdia, xitems: String);
// Objetivo...: Borrar Items
Begin
  if Buscar(xperiodo, xdia, xitems) then control.Delete;
end;

function  TTControlGastos.setGastos(xperiodo: String): TQuery;
// Objetivo...: Movimientos del periodo
Begin
  Result := datosdb.tranSQL(directorio, 'select periodo, dia, items, concepto, monto from gastosper where periodo = ' + '"' + xperiodo + '"' + ' order by dia, items');
end;

procedure TTControlGastos.conectar(xperiodo: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Begin
    conexiones := 1;
    desconectar;
  end;

  if utiles.verificarPeriodo(xperiodo, 'Periodo Incorrecto ...!') then Begin
    directorio := dbs.DirSistema + '\controles\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
    if not DirectoryExists(directorio) then utilesarchivos.CrearDirectorio(directorio);
    if not FileExists(directorio + '\gastosper.db') then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\controles', 'gastosper.*', directorio);

    control := datosdb.openDB('gastosper', '', '', directorio);

    if conexiones = 0 then Begin
      if not control.Active then control.Open;
    end;
    Inc(conexiones);
  end;
end;

procedure TTControlGastos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(control);
  end;
end;

{===============================================================================}

function controlg: TTControlGastos;
begin
  if xcontrolg = nil then
    xcontrolg := TTControlGastos.Create;
  Result := xcontrolg;
end;

{===============================================================================}

initialization

finalization
  xcontrolg.Free;

end.
