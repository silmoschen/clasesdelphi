unit CControlCompras_Gross;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CUtilidadesArchivos;

type

TTControlCompras = class
  control, obs: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xperiodo, xdia, xitems: String): Boolean;
  function    BuscarObs(xperiodo, xdia, xitems: String): Boolean;
  procedure   Registrar(xperiodo, xdia, xitems, xlaboratorio, xconcepto: String; xmonto1, xmonto2: Real);
  procedure   Borrar(xperiodo, xdia, xitems: String);
  procedure   RegistrarObservacion(xperiodo, xdia, xitems, xobservacion: String);
  function    getObservacion(xperiodo, xdia, xitems: String): String;
  function    setCompras(xperiodo: String): TQuery;

  procedure   conectar(xperiodo: String);
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  directorio: String;
  conexiones: shortint;
end;

function controlcom: TTControlCompras;

implementation

var
  xcontrolcom: TTControlCompras = nil;

constructor TTControlCompras.Create;
begin
end;

destructor TTControlCompras.Destroy;
begin
  inherited Destroy;
end;

function  TTControlCompras.Buscar(xperiodo, xdia, xitems: String): Boolean;
// Objetivo...: Buscar Items
Begin
  Result := datosdb.Buscar(control, 'periodo', 'dia', 'items', xperiodo, xdia, xitems);
end;

function  TTControlCompras.BuscarObs(xperiodo, xdia, xitems: String): Boolean;
// Objetivo...: Buscar Items
Begin
  Result := datosdb.Buscar(obs, 'periodo', 'dia', 'items', xperiodo, xdia, xitems);
end;

procedure TTControlCompras.Registrar(xperiodo, xdia, xitems, xlaboratorio, xconcepto: String; xmonto1, xmonto2: Real);
// Objetivo...: Registrar Items
Begin
  if Buscar(xperiodo, xdia, xitems) then control.Edit else control.Append;
  control.FieldByName('periodo').AsString     := xperiodo;
  control.FieldByName('dia').AsString         := xdia;
  control.FieldByName('items').AsString       := xitems;
  control.FieldByName('laboratorio').AsString := xlaboratorio;
  control.FieldByName('concepto').AsString    := xconcepto;
  control.FieldByName('monto1').AsFloat       := xmonto1;
  control.FieldByName('monto2').AsFloat       := xmonto2;
  try
    control.Post
   except
    control.Cancel
  end;
end;

procedure TTControlCompras.Borrar(xperiodo, xdia, xitems: String);
// Objetivo...: Borrar Items
Begin
  if Buscar(xperiodo, xdia, xitems) then control.Delete;
end;

procedure TTControlCompras.RegistrarObservacion(xperiodo, xdia, xitems, xobservacion: String);
// Objetivo...: Borrar Items
Begin
  obs.Open;
  if Length(Trim(xobservacion)) > 0 then Begin
    if BuscarObs(xperiodo, xdia, xitems) then obs.Edit else obs.Append;
    obs.FieldByName('periodo').AsString := xperiodo;
    obs.FieldByName('dia').AsString     := xdia;
    obs.FieldByName('items').AsString   := xitems;
    obs.FieldByName('obs').AsString     := xobservacion;
    try
      obs.Post
     except
      obs.Cancel
    end;
  end else
    if BuscarObs(xperiodo, xdia, xitems) then obs.Delete;
  datosdb.closeDB(obs);

  if Buscar(xperiodo, xdia, xitems) then control.Edit else control.Append;
  control.FieldByName('periodo').AsString     := xperiodo;
  control.FieldByName('dia').AsString         := xdia;
  control.FieldByName('items').AsString       := xitems;
  if Length(Trim(xobservacion)) > 0 then control.FieldByName('tob').AsString := '*' else control.FieldByName('tob').AsString := '';
  try
    control.Post
   except
    control.Cancel
  end;
end;

function  TTControlCompras.getObservacion(xperiodo, xdia, xitems: String): String;
// Objetivo...: Borrar Items
Begin
  obs.Open;
  if BuscarObs(xperiodo, xdia, xitems) then Result := obs.FieldByName('obs').AsString else Result := '';
  datosdb.closeDB(obs);
end;

function  TTControlCompras.setCompras(xperiodo: String): TQuery;
// Objetivo...: Movimientos del periodo
Begin
  Result := datosdb.tranSQL(directorio, 'select periodo, dia, items, laboratorio, concepto, monto1, monto2, tob from compras where periodo = ' + '"' + xperiodo + '"' + ' order by dia, items');
end;

procedure TTControlCompras.conectar(xperiodo: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Begin
    conexiones := 1;
    desconectar;
  end;

  if utiles.verificarPeriodo(xperiodo, 'Periodo Incorrecto ...!') then Begin
    directorio := dbs.DirSistema + '\controles\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
    if not DirectoryExists(directorio) then utilesarchivos.CrearDirectorio(directorio);
    if not FileExists(directorio + '\compras.db') then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\controles', 'compras.*', directorio);
    if not FileExists(directorio + '\compobs.db') then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\controles', 'compobs.*', directorio);

    control := datosdb.openDB('compras', '', '', directorio);
    obs     := datosdb.openDB('compobs', '', '', directorio);

    if conexiones = 0 then Begin
      if not control.Active then control.Open;
    end;
    Inc(conexiones);
  end;

  Inc(conexiones);
end;

procedure TTControlCompras.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(control);
  end;
end;

{===============================================================================}

function controlcom: TTControlCompras;
begin
  if xcontrolcom = nil then
    xcontrolcom := TTControlCompras.Create;
  Result := xcontrolcom;
end;

{===============================================================================}

initialization

finalization
  xcontrolcom.Free;

end.
