unit CActualizacionesConsorcio;

interface

uses CActualizaciones, CBDT, SysUtils, DB, DBTables, CIDBFM, CUtiles;

type

TTActualizacionesCirculo = class(TTActualizaciones)
  upgrade: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  destroy; override;

  procedure   Version(xversion: String);
 private
  { Declaraciones Privadas }
end;

function actualizaciones: TTActualizacionesCirculo;

implementation

var
  xactualizaciones: TTActualizacionesCirculo = nil;

procedure TTActualizacionesCirculo.Version(xversion: String);
begin
  if xversion = '1.0.05' then
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteCampo('propietarioh', 'activo', dbs.DirSistema + '\arch\') then Begin
        datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE propietarioh ADD activo CHAR(1)');
        datosdb.tranSQL(dbs.DirSistema + '\arch\', 'UPDATE propietarioh SET activo = ' + '"' + 'S' + '"');
      end;
      GuardarRevision(xversion);
    end;
end;

constructor TTActualizacionesCirculo.Create;
begin
  inherited Create;
  upgradevers := datosdb.openDB('upgrade', ''); 
end;

destructor TTActualizacionesCirculo.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function actualizaciones: TTActualizacionesCirculo;
begin
  if xactualizaciones = nil then
    xactualizaciones := TTActualizacionesCirculo.Create;
  Result := xactualizaciones;
end;

{===============================================================================}

initialization

finalization
  xactualizaciones.Free;

end.
