unit CActualizacionesPrever;

interface

uses CActualizaciones, CBDT, SysUtils, DB, DBTables, CIDBFM, CUtiles;

type

TTActualizacionesPrever = class(TTActualizaciones)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  destroy; override;

  procedure ActualizarIndicePlanes(xversion: String);
  procedure Anexarttp(xversion: String);
 private
  { Declaraciones Privadas }
end;

function actualizaciones: TTActualizacionesPrever;

implementation

var
  xactualizaciones: TTActualizacionesPrever = nil;

procedure TTActualizacionesPrever.ActualizarIndicePlanes(xversion: String);
// Objetivo...: Generar Indice en tabla
Begin
  if xversion = '1.0.00' then
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteIndice('expensas', 'expenas_verificarplan', dbs.DirSistema + '\arch') then
        datosdb.tranSQL(dbs.DirSistema + '\arch',  'CREATE INDEX expenas_verificarplan ON expensas(idtitular,anio)');
      GuardarRevision(xversion);
    end;
end;

procedure TTActualizacionesPrever.Anexarttp(xversion: String);
// Objetivo...: Anexar el campo ttp a titulares
Begin
  if xversion = '1.0.10' then
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteCampo('titularesh', 'ttp', dbs.DirSistema + '\sepelio') then Begin
        datosdb.tranSQL(dbs.DirSistema + '\sepelio',  'ALTER TABLE titularesh ADD ttp NUMERIC');
        datosdb.tranSQL(dbs.DirSistema + '\sepelio',  'UPDATE titularesh SET ttp = 0');
      end;
      GuardarRevision(xversion);
    end;
end;

constructor TTActualizacionesPrever.Create;
begin
  upgradevers := datosdb.openDB('upgrade', ''); 
end;

destructor TTActualizacionesPrever.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function actualizaciones: TTActualizacionesPrever;
begin
  if xactualizaciones = nil then
    xactualizaciones := TTActualizacionesPrever.Create;
  Result := xactualizaciones;
end;

{===============================================================================}

initialization

finalization
  xactualizaciones.Free;

end.
