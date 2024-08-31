unit CActualizacionesCirculo;

interface

uses CActualizaciones, CBDT, SysUtils, DB, DBTables, CIDBFM, CUtiles;

type

TTActualizacionesCirculo = class(TTActualizaciones)
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
  if xversion = '1.0.01' then
   if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
     datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE socioh1 ADD Tiposerv CHAR(3), ADD Nrocta CHAR(4)');
     GuardarRevision(xversion);
   end;
  if xversion = '1.1.01' then
   if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
     datosdb.tranSQL(dbs.DirSistema + '\arch\', 'DROP   INDEX servicioscirculo.servicios_comercio');
     datosdb.tranSQL(dbs.DirSistema + '\arch\', 'CREATE INDEX servicios_comercio ON servicioscirculo(Codoper, items, subitems)');
     GuardarRevision(xversion);
   end;
  if xversion = '1.1.02' then
   if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
     datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE comercios ADD Debita CHAR(1)');
     GuardarRevision(xversion);
   end;
  if xversion = '1.1.05' then
   if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
     datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE servicioscirculo ADD Fechareg CHAR(8)');
     GuardarRevision(xversion);
   end;
  if xversion = '1.2.05' then
    if not ActualizacionRealizada(xversion) then Begin
      datosdb.tranSQL(dbs.DirSistema + '\arch\', 'CREATE TABLE catcom (Idcategoria CHAR(3), Categoria CHAR(35), PRIMARY KEY(Idcategoria))');
      datosdb.tranSQL(dbs.DirSistema + '\arch\', 'CREATE INDEX catcom_categoria ON catcom(Categoria)');
      datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE comercios ADD Idcategoria CHAR(3)');
      GuardarRevision(xversion);
    end;
  if xversion = '1.2.10' then
    if not ActualizacionRealizada(xversion) then Begin
      datosdb.tranSQL(dbs.DirSistema + '\arch\', 'CREATE INDEX Listcat ON comercios(Idcategoria, Coditems)');
      GuardarRevision(xversion);
    end;
  if xversion = '1.2.20' then
    if not ActualizacionRealizada(xversion) then Begin
      datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE servicioscirculo ADD Entrega NUMERIC');
      GuardarRevision(xversion);
    end;
  if xversion = '1.3.00' then
    if not ActualizacionRealizada(xversion) then Begin
      datosdb.tranSQL(dbs.DirSistema + '\arch\', 'CREATE TABLE distpagos (Items CHAR(8), Subitems CHAR(2), Debito NUMERIC, BsAs NUMERIC, Efectivo NUMERIC, PRIMARY KEY(Items, Subitems))');
      GuardarRevision(xversion);
    end;
  if xversion = '1.10.00' then
    if not ActualizacionRealizada(xversion) then Begin
      datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE catcom ADD retdes CHAR(1)');
      GuardarRevision(xversion);
    end;
  if xversion = '1.50.00' then
    if not ActualizacionRealizada(xversion) then Begin
      datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE correlatividad ADD margen CHAR(2)');
      GuardarRevision(xversion);
    end;
  if xversion = '1.07.00' then
    if not ActualizacionRealizada(xversion) then Begin
      datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE socioh1 ADD limitep CHAR(3)');
      GuardarRevision(xversion);
    end;
end;

constructor TTActualizacionesCirculo.Create;
begin
  if not FileExists(dbs.DirSistema + '\arch\upgrade.db') then
    datosdb.tranSQL(dbs.DirSistema + '\arch\', 'CREATE TABLE upgrade (Version CHAR(15), Actualizado CHAR(1), Fecha CHAR(10), PRIMARY KEY(version))');
  // Generamos una instancia para la tabla de actualizaciones
  upgradevers := datosdb.openDB('upgrade', 'Version', '', dbs.DirSistema + '\arch\');
  inherited Create;
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
