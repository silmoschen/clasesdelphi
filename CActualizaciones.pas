unit CActualizaciones;

interface

uses CBDT, SysUtils, DB, DBTables, CIDBFM, CUtiles;

type

TTActualizaciones = class(TObject)
  upgradevers: TTable;
  reinicia: Boolean;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    VerificarActualizacion(xversion: String): Boolean;
  procedure   BorrarHistorial;
  function    ReinicarAplicacion: Boolean;

  procedure   Conectar;
  procedure   Desconectar;
 private
  { Declaraciones Privadas }
 protected
  { Declaraciones Protegidas }
  tact, upgrade: TTable;
  dir: String;
  function    ActualizacionRealizada(xversion: String): Boolean;
  procedure   GuardarRevision(xversion: String);
end;

implementation

function TTActualizaciones.VerificarActualizacion(xversion: String): Boolean;
begin
  upgradevers.Open;
  Result := upgradevers.FindKey([xversion]);
  upgradevers.Close;
end;

procedure TTActualizaciones.BorrarHistorial;
begin
  datosdb.tranSQL(dir, 'DELETE FROM ' + upgradevers.TableName);
end;

function TTActualizaciones.ActualizacionRealizada(xversion: String): Boolean;
begin
  Result := False;
  upgradevers.Open;
  if upgradevers.FindKey([xversion]) then
    if upgradevers.FieldByName('actualizado').AsString = 'S' then Result := True;
  upgradevers.Close;
end;

procedure TTActualizaciones.GuardarRevision(xversion: String);
begin
  upgradevers.Open;
  if upgradevers.FindKey([xversion]) then upgradevers.Edit else upgradevers.Append;
  upgradevers.FieldByName('version').AsString     := xversion;
  upgradevers.FieldByName('actualizado').AsString := 'S';
  upgradevers.FieldByName('fecha').AsString       := utiles.setFechaActual;
  try
    upgradevers.Post
   except
    upgradevers.Cancel
  end;
  upgradevers.Close;
end;

function  TTActualizaciones.ReinicarAplicacion: Boolean;
// Objetivo...: determinar si reinicia o no
Begin
  Result := reinicia;
end;

procedure TTActualizaciones.Conectar;
Begin
  upgradevers.Open;
end;

procedure TTActualizaciones.Desconectar;
Begin
  upgradevers.Close;
end;

constructor TTActualizaciones.Create;
begin
  inherited Create;

  if not FileExists(dbs.DirSistema + '\arch\usuarios.db') then Begin  // Creamos el 1º Usuario
    datosdb.tranSQL(dbs.DirSistema + '\arch\', 'CREATE TABLE usuarios (usuario CHAR(20), clave CHAR(20), perfil CHAR(10), nombre CHAR(30), descripcion CHAR(30), Estado SMALLINT, PRIMARY KEY(usuario, clave))');
    datosdb.tranSQL(dbs.DirSistema + '\arch\', 'INSERT INTO usuarios (usuario) VALUES (' + '"' + 'Administrador' + '"' + ')');
  end;
end;

destructor TTActualizaciones.Destroy;
begin
  inherited Destroy;
end;

end.
