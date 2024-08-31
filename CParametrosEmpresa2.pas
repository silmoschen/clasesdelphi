unit CParametrosEmpresa2;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTParametrosEmpresa = class
  Id, RSocial, Direccion, Telefono, Cuit, Email, ServerSmtp, PuertoSmtp, Opcion: String;
  tabla, param: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Registrar(xid, xrsocial , xdireccion, xtelefono, xcuit, xemail, xserversmtp, xpuertosmtp: String);
  procedure   getDatos(xid: String);

  procedure   RegistrarPG(xid, xopcion: String);
  procedure   getDatosPG(xid: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function empresa: TTParametrosEmpresa;

implementation

var
  xempresa: TTParametrosEmpresa = nil;

constructor TTParametrosEmpresa.Create;
begin
  tabla := datosdb.openDB('datosEmpresa', '');
  param := datosdb.openDB('par_gen', '');
end;

destructor TTParametrosEmpresa.Destroy;
begin
  inherited Destroy;
end;

procedure TTParametrosEmpresa.Registrar(xid, xrsocial , xdireccion, xtelefono, xcuit, xemail, xserversmtp, xpuertosmtp: String);
// Objetivo...: Registrar datos empresa
Begin
  if tabla.FindKey([xid]) then tabla.Edit else tabla.Append;
  tabla.FieldByName('id').AsString         := xid;
  tabla.FieldByName('rsocial').AsString    := xrsocial;
  tabla.FieldByName('direccion').AsString  := xdireccion;
  tabla.FieldByName('telefono').AsString   := xtelefono;
  tabla.FieldByName('cuit').AsString       := xcuit;
  tabla.FieldByName('email').AsString      := xemail;
  tabla.FieldByName('serversmtp').AsString := xserversmtp;
  tabla.FieldByName('puertosmtp').AsString := xpuertosmtp;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
end;

procedure TTParametrosEmpresa.getDatos(xid: String);
// Objetivo...: Registrar datos empresa
Begin
  if tabla.FindKey([xid]) then Begin
    id         := tabla.FieldByName('id').AsString;
    rsocial    := tabla.FieldByName('rsocial').AsString;
    direccion  := tabla.FieldByName('direccion').AsString;
    telefono   := tabla.FieldByName('telefono').AsString;
    cuit       := tabla.FieldByName('cuit').AsString;
    email      := tabla.FieldByName('email').AsString;
    serversmtp := tabla.FieldByName('serversmtp').AsString;
    puertosmtp := tabla.FieldByName('puertosmtp').AsString;
  end else Begin
    id := ''; rsocial := ''; direccion := ''; telefono := ''; cuit := ''; email := ''; serversmtp := ''; puertosmtp := '25';
  end;
end;

procedure TTParametrosEmpresa.RegistrarPG(xid, xopcion: String);
// Objetivo...: registrar parámetros generales
begin
  if param.FindKey([xid]) then param.Edit else param.Append;
  param.FieldByName('id').AsString     := xid;
  param.FieldByName('opcion').AsString := xopcion;
  try
    param.Post
   except
    param.Cancel
  end;
  datosdb.refrescar(param);
end;

procedure TTParametrosEmpresa.getDatosPG(xid: String);
// Objetivo...: recuperar instancia
begin
  if param.FindKey([xid]) then Begin
    id     := param.FieldByName('id').AsString;
    opcion := param.FieldByName('opcion').AsString;
  end else Begin
    id := ''; opcion := '';
  end;
end;

procedure TTParametrosEmpresa.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    if not param.Active then param.Open;
    getDatos('01');  // Datos por defecto
    getDatosPG('001');  // Datos por defecto
  end;
  Inc(conexiones);
end;

procedure TTParametrosEmpresa.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(param);
  end;
end;

{===============================================================================}

function empresa: TTParametrosEmpresa;
begin
  if xempresa = nil then
    xempresa := TTParametrosEmpresa.Create;
  Result := xempresa;
end;

{===============================================================================}

initialization

finalization
  xempresa.Free;

end.
