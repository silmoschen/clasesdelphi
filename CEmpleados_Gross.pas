unit CEmpleados_Gross;

interface

uses CPersona, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTEmpleado = class(TTPersona)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xnrolegajo: String): Boolean;
  procedure   BuscarPorNombre(xexpr: String);
  procedure   BuscarPorCodigo(xexpr: String);
  function    setEmpleados: TQuery;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: Integer;
  directorio: String;
end;

function empleado: TTEmpleado;

implementation

var
  xempleado: TTEmpleado = nil;

constructor TTEmpleado.Create;
begin
  directorio := dbs.DirSistema + '\controles';
  tperso := datosdb.openDB('empleados', '', '', directorio);
end;

destructor TTEmpleado.Destroy;
begin
  inherited Destroy;
end;

function  TTEmpleado.Buscar(xnrolegajo: String): Boolean;
Begin
  if tperso.IndexFieldNames <> 'Nrolegajo' then tperso.IndexFieldNames := 'Nrolegajo';
  Result := inherited Buscar(xnrolegajo);
end;

procedure TTEmpleado.BuscarPorNombre(xexpr: String);
Begin
  if tperso.IndexFieldNames <> 'Nombre' then tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

procedure TTEmpleado.BuscarPorCodigo(xexpr: String);
Begin
  if tperso.IndexFieldNames <> 'Nrolegajo' then tperso.IndexFieldNames := 'Nrolegajo';
  tperso.FindNearest([xexpr]);
end;

function  TTEmpleado.setEmpleados: TQuery;
// Objetivo...: Retornar una Lista con los Empleados
Begin
  Result := datosdb.tranSQL(directorio, 'select * from empleados order by nombre');
end;

procedure TTEmpleado.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    tperso.Open;
    tperso.FieldByName('nrolegajo').DisplayLabel := 'Legajo'; tperso.FieldByName('nombre').DisplayLabel := 'Nombre del Empleado'; tperso.FieldByName('direccion').DisplayLabel := 'Dirección/Teléfono';
    tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False;
  end;
  Inc(conexiones);
end;

procedure TTEmpleado.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tperso);
end;

{===============================================================================}

function empleado: TTEmpleado;
begin
  if xempleado = nil then
    xempleado := TTEmpleado.Create;
  Result := xempleado;
end;

{===============================================================================}

initialization

finalization
  xempleado.Free;

end.
