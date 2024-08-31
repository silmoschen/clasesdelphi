unit CControlVentas_Gross;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CUtilidadesArchivos;

type

TTControlVentas = class
  control, obs: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xperiodo, xdia, xitems: String): Boolean;
  function    BuscarObs(xperiodo, xdia, xitems: String): Boolean;
  procedure   Registrar(xperiodo, xdia, xitems: String; xhmaniana, xhtarde, xvmaniana, xvtarde: Real);
  procedure   Borrar(xperiodo, xdia, xitems: String);
  procedure   RegistrarObservacion(xperiodo, xdia, xitems, xobservacion: String);
  function    getObservacion(xperiodo, xdia, xitems: String): String;
  function    setIngresos(xperiodo: String): TQuery;

  procedure   conectar(xperiodo: String);
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  directorio: String;
  conexiones: shortint;
end;

function controlvtas: TTControlVentas;

implementation

var
  xcontrolvtas: TTControlVentas = nil;

constructor TTControlVentas.Create;
begin

end;

destructor TTControlVentas.Destroy;
begin
  inherited Destroy;
end;

function  TTControlVentas.Buscar(xperiodo, xdia, xitems: String): Boolean;
// Objetivo...: Buscar Items
Begin
  Result := datosdb.Buscar(control, 'periodo', 'dia', 'items', xperiodo, xdia, xitems);
end;

function  TTControlVentas.BuscarObs(xperiodo, xdia, xitems: String): Boolean;
// Objetivo...: Buscar Items
Begin
  Result := datosdb.Buscar(obs, 'periodo', 'dia', 'items', xperiodo, xdia, xitems);
end;

procedure TTControlVentas.Registrar(xperiodo, xdia, xitems: String; xhmaniana, xhtarde, xvmaniana, xvtarde: Real);
// Objetivo...: Registrar Items
Begin
  if Buscar(xperiodo, xdia, xitems) then control.Edit else control.Append;
  control.FieldByName('periodo').AsString := xperiodo;
  control.FieldByName('dia').AsString     := xdia;
  control.FieldByName('items').AsString   := xitems;
  control.FieldByName('hm').AsFloat       := xhmaniana;
  control.FieldByName('ht').AsFloat       := xhtarde;
  control.FieldByName('vm').AsFloat       := xvmaniana;
  control.FieldByName('vt').AsFloat       := xvtarde;
  try
    control.Post
   except
    control.Cancel
  end;
end;

procedure TTControlVentas.Borrar(xperiodo, xdia, xitems: String);
// Objetivo...: Borrar Items
Begin
  if Buscar(xperiodo, xdia, xitems) then control.Delete;
end;

procedure TTControlVentas.RegistrarObservacion(xperiodo, xdia, xitems, xobservacion: String);
// Objetivo...: Borrar Items
Begin
  obs.Open;
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
  datosdb.closeDB(obs);

  if Buscar(xperiodo, xdia, xitems) then Begin
    control.Edit;
    if Length(Trim(xobservacion)) > 0 then control.FieldByName('tob').AsString := '*' else control.FieldByName('tob').AsString := '';
    try
      control.Post
     except
      control.Cancel
    end;
  end;
end;

function  TTControlVentas.getObservacion(xperiodo, xdia, xitems: String): String;
// Objetivo...: Borrar Items
Begin
  obs.Open;
  if BuscarObs(xperiodo, xdia, xitems) then Result := obs.FieldByName('obs').AsString else Result := '';
  datosdb.closeDB(obs);
end;

function  TTControlVentas.setIngresos(xperiodo: String): TQuery;
// Objetivo...: Movimientos del periodo
Begin
  Result := datosdb.tranSQL(directorio, 'select periodo, dia, items, vm, vt, hm, ht, tob from ventas where periodo = ' + '"' + xperiodo + '"' + ' order by dia, items');
end;

procedure TTControlVentas.conectar(xperiodo: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Begin
    conexiones := 1;
    desconectar;
  end;

  if utiles.verificarPeriodo(xperiodo, 'Periodo Incorrecto ...!') then Begin
    directorio := dbs.DirSistema + '\controles\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
    if not DirectoryExists(directorio) then utilesarchivos.CrearDirectorio(directorio);
    if not FileExists(directorio + '\ventas.db') then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\controles', 'v*.*', directorio);

    control := datosdb.openDB('ventas', '', '', directorio);
    obs     := datosdb.openDB('vtasobs', '', '', directorio);

    if conexiones = 0 then Begin
      if not control.Active then control.Open;
    end;
    Inc(conexiones);
  end;
end;

procedure TTControlVentas.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(control);
  end;
end;

{===============================================================================}

function controlvtas: TTControlVentas;
begin
  if xcontrolvtas = nil then
    xcontrolvtas := TTControlVentas.Create;
  Result := xcontrolvtas;
end;

{===============================================================================}

initialization

finalization
  xcontrolvtas.Free;

end.
