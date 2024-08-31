unit CActualizacionesGross;

interface

uses CActualizaciones, CBDT, SysUtils, DB, DBTables, CIDBFM, CUtiles;

type

TTActualizacionesGross = class(TTActualizaciones)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  destroy; override;

  procedure   Version(xversion: String);
 private
  { Declaraciones Privadas }
end;

function actualizaciones: TTActualizacionesGross;

implementation

var
  xactualizaciones: TTActualizacionesGross = nil;

procedure TTActualizacionesGross.Version(xversion: String);
begin
  if xversion = '1.0.05' then
   if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
     datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE cabventa ADD ctacte CHAR(7)');
     GuardarRevision(xversion);
   end;
end;

constructor TTActualizacionesGross.Create;
begin
  inherited Create;
  upgradevers := datosdb.openDB('upgrade', 'Version', '', dbs.DirSistema + '\arch\');
end;

destructor TTActualizacionesGross.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function actualizaciones: TTActualizacionesGross;
begin
  if xactualizaciones = nil then
    xactualizaciones := TTActualizacionesGross.Create;
  Result := xactualizaciones;
end;

{===============================================================================}

initialization

finalization
  xactualizaciones.Free;

end.
