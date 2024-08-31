unit CActualizacionesADR;

interface

uses CActualizaciones, CBDT, SysUtils, DB, DBTables, CIDBFM, CUtiles;

type

TTActualizacionesADR = class(TTActualizaciones)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  destroy; override;

  procedure   Version(xversion: String);
 private
  { Declaraciones Privadas }
end;

function actualizaciones: TTActualizacionesADR;

implementation

var
  xactualizaciones: TTActualizacionesADR = nil;

procedure TTActualizacionesADR.Version(xversion: String);
begin
  if xversion = '2.00.000' then Begin
   if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
     if not datosdb.verificarSiExisteTabla('CODIGOBARRAS') then Begin
       //datosdb.tranSQL(dbs.baseDat, 'CREATE TABLE CODIGOBARRAS (activar integer not null, primary key(activar))');
     end;
     GuardarRevision(xversion);
   end;
  end;

  if xversion = '2.00.050' then Begin
    if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
      if not datosdb.verificarSiExisteCampo('creditos_det', 'nrotrans', dbs.baseDat) then
         datosdb.tranSQL(dbs.baseDat, 'alter table creditos_det add nrotrans varchar(20)');
      if not datosdb.verificarSiExisteCampo('creditos_detrefinanciados', 'nrotrans', dbs.baseDat) then
         datosdb.tranSQL(dbs.baseDat, 'alter table creditos_detrefinanciados add nrotrans varchar(20)');
      if not datosdb.verificarSiExisteCampo('creditos_detrefcuotas', 'nrotrans', dbs.baseDat) then
         datosdb.tranSQL(dbs.baseDat, 'alter table creditos_detrefcuotas add nrotrans varchar(20)');

      if not datosdb.verificarSiExisteCampo('creditos_detwork', 'nrotrans', dbs.baseDat) then
         datosdb.tranSQL(dbs.baseDat, 'alter table creditos_detwork add nrotrans varchar(20)');
      if not datosdb.verificarSiExisteCampo('creditos_detwork_ref', 'nrotrans', dbs.baseDat) then
         datosdb.tranSQL(dbs.baseDat, 'alter table creditos_detwork_ref add nrotrans varchar(20)');
      if not datosdb.verificarSiExisteCampo('creditos_detwork_refcuotas', 'nrotrans', dbs.baseDat) then
         datosdb.tranSQL(dbs.baseDat, 'alter table creditos_detwork_refcuotas add nrotrans varchar(20)');

      if not datosdb.verificarSiExisteCampo('boletas_work', 'nrotrans', dbs.baseDat) then
         datosdb.tranSQL(dbs.baseDat, 'alter table boletas_work add nrotrans varchar(20)');

      if not datosdb.verificarSiExisteCampo('creditos_det_cb', 'transf', dbs.baseDat) then
         datosdb.tranSQL(dbs.baseDat, 'alter table creditos_det_cb add transf varchar(1)');

      GuardarRevision(xversion);
    end;
  end;

  if xversion = '2.00.080' then Begin
   if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
     if not datosdb.verificarSiExisteTabla('GARANTIAS') then Begin
       datosdb.tranSQL(dbs.baseDat, 'CREATE TABLE GARANTIAS (codprest varchar(5) not null, expediente varchar(4) not null, items varchar(3) not null, tipo varchar(1) not null, observac varchar(80), alta varchar(8), vence varchar(8), primary key(codprest, expediente, items))');
     end;
     if not datosdb.verificarSiExisteTabla('GARANTIAS_HIST') then Begin
       datosdb.tranSQL(dbs.baseDat, 'CREATE TABLE GARANTIAS_HIST (codprest varchar(5) not null, expediente varchar(4) not null, items varchar(3) not null, tipo varchar(1) not null, observac varchar(80), alta varchar(8), vence varchar(8), primary key(codprest, expediente, items))');
     end;
     GuardarRevision(xversion);
   end;
  end;

end;

constructor TTActualizacionesADR.Create;
begin
  inherited Create;
  upgradevers := datosdb.openDB('upgrade', '');
end;

destructor TTActualizacionesADR.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function actualizaciones: TTActualizacionesADR;
begin
  if xactualizaciones = nil then
    xactualizaciones := TTActualizacionesADR.Create;
  Result := xactualizaciones;
end;

{===============================================================================}

initialization

finalization
  xactualizaciones.Free;

end.
