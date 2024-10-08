unit CUsuario;

interface

uses SysUtils, DB, DBTables, CUtiles, CIDBFM, CBDT;

type

TTUsuario = class(TObject)            // Superclase
  usuario, clave, dominio, nombre, descripcion, alias: string; estado: shortint;
  tabla: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;
  function    getPassword(xusuario: string): string; overload;
  function    getUsuarios: TQuery;

  procedure   Grabar(xusuario, xpassword, xdominio, xnombre, xdescripcion: string);
  function    Borrar(xusuario, xpassword: string): boolean;
  function    Buscar(xusuario: string): boolean; overload;
  function    Buscar(xusuario, xpassword: string): boolean; overload;
  procedure   getDatos(xusuario, xpassword: string);
  procedure   ActivarCuenta(xusuario, xpassword: string);
  procedure   DesactivarCuenta(xusuario, xpassword: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  procedure   ADCuenta(xusuario, xpassword: string; xt: byte);
end;

function usuario: TTUsuario;

implementation

var
  xusuario: TTUsuario = nil;

constructor TTUsuario.Create;
begin
  inherited Create;
  if dbs.BaseClientServ = 'N' then tabla := datosdb.openDB('usuarios', 'usuario;clave', '', dbs.dirSistema + '\arch') else tabla := datosdb.openDB('usuarios', 'usuario;clave');
  conectar;
end;

destructor TTUsuario.Destroy;
begin
  inherited Destroy;
end;

function TTUsuario.getPassword(xusuario: string): string;
begin
  Result := '-';
  tabla.First;
  while not tabla.EOF do Begin
    if tabla.FieldByName('usuario').AsString = xusuario then Begin
      if Length(Trim(tabla.FieldByName('clave').AsString)) > 0 then Result := tabla.FieldByName('clave').AsString else Result := '-';
      Break;
    end;
    tabla.Next;
  end;
end;

procedure TTUsuario.Grabar(xusuario, xpassword, xdominio, xnombre, xdescripcion: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xusuario) then tabla.Edit else tabla.Append;
  tabla.FieldByName('usuario').AsString     := TrimLeft(xusuario);
  if Length(Trim(xpassword)) > 0 then tabla.FieldByName('clave').AsString := xpassword else tabla.FieldByName('clave').AsString := '-';
  tabla.FieldByName('perfil').AsString      := TrimLeft(xdominio);
  tabla.FieldByName('nombre').AsString      := TrimLeft(xnombre);
  tabla.FieldByName('descripcion').AsString := TrimLeft(xdescripcion);
  try
    tabla.Post
  except
    tabla.Cancel
  end;
end;

function TTUsuario.Borrar(xusuario, xpassword: string): boolean;
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xusuario) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('usuario').AsString, tabla.FieldByName('clave').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    Result := True;
  end else
    Result := False;
end;

function TTUsuario.Buscar(xusuario: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  Result := False;
  tabla.First;
  while not tabla.EOF do Begin
    if lowercase(tabla.FieldByName('usuario').AsString) = lowercase(xusuario) then Begin
      Result := True;
      Break;
    end;
    tabla.Next;
  end;
end;

function TTUsuario.Buscar(xusuario, xpassword: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
var
  c: String;
begin
  if Length(Trim(xpassword)) = 0 then c := '-' else c := xpassword;
  if datosdb.Buscar(tabla, 'usuario', 'clave', xusuario, c) then Begin
    usuario := xusuario;
    Result  := True;
  end else
    Result := False;
end;

procedure  TTUsuario.getDatos(xusuario, xpassword: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xusuario) then Begin
    usuario     := tabla.FieldByName('usuario').AsString;
    clave       := tabla.FieldByName('clave').AsString;
    dominio     := tabla.FieldByName('perfil').AsString;
    nombre      := tabla.FieldByName('nombre').AsString;
    descripcion := tabla.FieldByName('descripcion').AsString;
    estado      := tabla.FieldByName('estado').AsInteger;
  end else begin
    usuario := ''; clave := ''; dominio := ''; nombre := ''; descripcion := ''; estado := 0;
  end;
end;

procedure TTUsuario.ADCuenta(xusuario, xpassword: string; xt: byte);
// Objetivo...: Activar/Desactivar una cuenta
begin
  if Buscar(xusuario, xpassword) then Begin
    tabla.Edit;
    tabla.FieldByName('estado').AsInteger := xt;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
  end;
end;

function TTUsuario.getUsuarios: TQuery;
begin
  Result := datosdb.tranSQL('SELECT * FROM usuarios');
end;

procedure TTUsuario.ActivarCuenta(xusuario, xpassword: string);
begin
  ADCuenta(xusuario, xpassword, 1);
end;

procedure TTUsuario.DesactivarCuenta(xusuario, xpassword: string);
begin
  ADCuenta(xusuario, xpassword, 0);
end;

procedure TTUsuario.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if not tabla.Active then tabla.Open;
end;

procedure TTUsuario.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  datosdb.closeDB(tabla);
end;

{===============================================================================}

function usuario: TTUsuario;
begin
  if xusuario = nil then
    xusuario := TTUsuario.Create;
  Result := xusuario;
end;

{===============================================================================}

initialization

finalization
  xusuario.Free;

end.
