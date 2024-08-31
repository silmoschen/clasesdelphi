unit CControlHorarios_Gross;

interface

uses CEmpleados_Gross, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CUtilidadesArchivos;

type

TTControlHorarios = class
  control: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xperiodo, xnrolegajo, xdia, xitems: String): Boolean;
  procedure   Registrar(xperiodo, xnrolegajo, xdia, xitems, xdh, xhh, xdht, xhht, xconcepto: String);
  procedure   Borrar(xperiodo, xnrolegajo, xdia, xitems: String);
  function    setHorasTrabajadas(xperiodo, xnrolegajo: String): TQuery;

  procedure   conectar(xperiodo: String);
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  directorio: String;
  conexiones: shortint;
end;

function controlh: TTControlHorarios;

implementation

var
  xcontrolh: TTControlHorarios = nil;

constructor TTControlHorarios.Create;
begin
end;

destructor TTControlHorarios.Destroy;
begin
  inherited Destroy;
end;

function  TTControlHorarios.Buscar(xperiodo, xnrolegajo, xdia, xitems: String): Boolean;
// Objetivo...: Buscar Items
Begin
  Result := datosdb.Buscar(control, 'periodo', 'nrolegajo', 'dia', 'items', xperiodo, xnrolegajo, xdia, xitems);
end;

procedure TTControlHorarios.Registrar(xperiodo, xnrolegajo, xdia, xitems, xdh, xhh, xdht, xhht, xconcepto: String);
// Objetivo...: Registrar Items
Begin
  if Buscar(xperiodo, xnrolegajo, xdia, xitems) then control.Edit else control.Append;
  control.FieldByName('periodo').AsString    := xperiodo;
  control.FieldByName('nrolegajo').AsString  := xnrolegajo;
  control.FieldByName('dia').AsString        := xdia;
  control.FieldByName('items').AsString      := xitems;
  control.FieldByName('dh').AsString         := xdh;
  control.FieldByName('hh').AsString         := xhh;
  control.FieldByName('dht').AsString        := xdht;
  control.FieldByName('hht').AsString        := xhht;
  control.FieldByName('concepto').AsString   := xconcepto;
  try
    control.Post
   except
    control.Cancel
  end;
end;

procedure TTControlHorarios.Borrar(xperiodo, xnrolegajo, xdia, xitems: String);
// Objetivo...: Borrar Items
Begin
  if Buscar(xperiodo, xnrolegajo, xdia, xitems) then control.Delete;
end;

function  TTControlHorarios.setHorasTrabajadas(xperiodo, xnrolegajo: String): TQuery;
// Objetivo...: Movimientos del periodo
Begin
  Result := datosdb.tranSQL(directorio, 'select * from controlhoras where periodo = ' + '"' + xperiodo + '"' + ' and nrolegajo = ' + '"' + xnrolegajo + '"' + ' order by dia, items');
end;

procedure TTControlHorarios.conectar(xperiodo: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Begin
    conexiones := 1;
    desconectar;
  end;

  if utiles.verificarPeriodo(xperiodo, 'Periodo Incorrecto ...!') then Begin
    directorio := dbs.DirSistema + '\controles\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
    if not DirectoryExists(directorio) then utilesarchivos.CrearDirectorio(directorio);
    if not FileExists(directorio + '\controlhoras.db') then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\controles', 'controlhoras.*', directorio);

    control := datosdb.openDB('controlhoras', '', '', directorio);

    if conexiones = 0 then Begin
      if not control.Active then control.Open;
    end;
    Inc(conexiones);
  end;
  empleado.conectar;
end;

procedure TTControlHorarios.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(control);
  end;
  empleado.desconectar;
end;

{===============================================================================}

function controlh: TTControlHorarios;
begin
  if xcontrolh = nil then
    xcontrolh := TTControlHorarios.Create;
  Result := xcontrolh;
end;

{===============================================================================}

initialization

finalization
  xcontrolh.Free;

end.
