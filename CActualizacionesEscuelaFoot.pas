unit CActualizacionesEscuelaFoot;

interface

uses CActualizaciones, CBDT, SysUtils, DB, DBTables, CIDBFM, CUtiles;

type

TTActualizacionesEscuelaFoot = class(TTActualizaciones)
  upgrade: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  destroy; override;

  procedure   Version(xversion: String);
 private
  { Declaraciones Privadas }
end;

function actualizaciones: TTActualizacionesEscuelaFoot;

implementation

var
  xactualizaciones: TTActualizacionesEscuelaFoot = nil;

procedure TTActualizacionesEscuelaFoot.Version(xversion: String);
begin
  if xversion = '1.00.05' then
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteCampo('alumnosh', 'peso', dbs.DirSistema + '\arch\') then
        datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE alumnosh ADD peso numeric');
      if not datosdb.verificarSiExisteCampo('alumnosh', 'estatura', dbs.DirSistema + '\arch\') then
        datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE alumnosh ADD estatura numeric');
      if not datosdb.verificarSiExisteCampo('alumnosh', 'puesto', dbs.DirSistema + '\arch\') then
        datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE alumnosh ADD puesto integer');
      if not datosdb.verificarSiExisteCampo('alumnosh', 'derivacion', dbs.DirSistema + '\arch\') then
        datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE alumnosh ADD derivacion char(50)');
      if not datosdb.verificarSiExisteCampo('alumnosh', 'observacion', dbs.DirSistema + '\arch\') then
        datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE alumnosh ADD observacion char(200)');
      if not datosdb.verificarSiExisteCampo('alumnosh', 'activo', dbs.DirSistema + '\arch\') then
        datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE alumnosh ADD activo char(1)');

      GuardarRevision(xversion);
    end;
end;

constructor TTActualizacionesEscuelaFoot.Create;
begin
  inherited Create;
  upgradevers := datosdb.openDB('upgrade', '');
end;

destructor TTActualizacionesEscuelaFoot.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function actualizaciones: TTActualizacionesEscuelaFoot;
begin
  if xactualizaciones = nil then
    xactualizaciones := TTActualizacionesEscuelaFoot.Create;
  Result := xactualizaciones;
end;

{===============================================================================}

initialization

finalization
  xactualizaciones.Free;

end.
