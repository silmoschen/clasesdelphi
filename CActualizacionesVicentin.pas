unit CActualizacionesVicentin;

interface

uses CActualizaciones, CBDT, SysUtils, DB, DBTables, CIDBFM, CUtiles;

type

TTActualizacionesVicentin = class(TTActualizaciones)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  destroy; override;

  procedure   Version(xversion: String);
 private
   tabla: TTable;
  { Declaraciones Privadas }
end;

function actualizaciones: TTActualizacionesVicentin;

implementation

var
  xactualizaciones: TTActualizacionesVicentin = nil;

procedure TTActualizacionesVicentin.Version(xversion: String);
var
  existe: Boolean;
begin
  if xversion = '1.00.01' then Begin
   if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
     existe := False;
     if dbs.BaseClientServ = 'N' then existe := datosdb.verificarSiExisteCampo('historiadiet_paciente', 'iddiag', dbs.DirSistema + '\arch\');
     if dbs.BaseClientServ = 'S' then existe := datosdb.verificarSiExisteCampo('historiadiet_paciente', 'iddiag', dbs.baseDat);
     if not existe then Begin
       if dbs.BaseClientServ = 'N' then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE historiadiet_paciente ADD iddiag CHAR(3)') else
         datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE historiadiet_paciente ADD iddiag VARCHAR(3)');
     end;
     existe := False;
     if dbs.BaseClientServ = 'N' then existe := datosdb.verificarSiExisteCampo('historiadiet_paciente', 'atencion', dbs.DirSistema + '\arch\');
     if dbs.BaseClientServ = 'S' then existe := datosdb.verificarSiExisteCampo('historiadiet_paciente', 'atencion', dbs.baseDat);
     if not existe then Begin
       if dbs.BaseClientServ = 'N' then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE historiadiet_paciente ADD atencion CHAR(3)') else
         datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE historiadiet_paciente ADD atencion VARCHAR(3)');
     end;
     existe := False;
     if dbs.BaseClientServ = 'N' then existe := datosdb.verificarSiExisteCampo('turnos', 'opcion', dbs.DirSistema + '\arch\');
     if dbs.BaseClientServ = 'S' then existe := datosdb.verificarSiExisteCampo('turnos', 'opcion', dbs.baseDat);
     if not existe then Begin
       if dbs.BaseClientServ = 'N' then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE turnos ADD opcion CHAR(1), ADD telefono CHAR(30), ADD debe NUMERIC') else
         datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE turnos ADD opcion VARCHAR(1), ADD telefono VARCHAR(30), ADD debe REAL');
     end;
     existe := False;
     if dbs.BaseClientServ = 'N' then existe := datosdb.verificarSiExisteCampo('anamnesis', 'orden', dbs.DirSistema + '\arch\');
     if dbs.BaseClientServ = 'S' then existe := datosdb.verificarSiExisteCampo('anamnesis', 'orden', dbs.baseDat);
     if not existe then Begin
       if dbs.BaseClientServ = 'N' then Begin
         datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE anamnesis ADD orden CHAR(3)');
         datosdb.tranSQL(dbs.DirSistema + '\arch\', 'CREATE INDEX anamnesis_orden ON anamnesis(orden)');
         tabla := datosdb.openDB('anamnesis', '', '', dbs.DirSistema + '\arch\');
       end else Begin
         datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE anamnesis ADD orden VARCHAR(3)');
         datosdb.tranSQL(dbs.BaseDat, 'CREATE INDEX anamnesis_orden ON anamnesis(orden)');
         tabla := datosdb.openDB('anamnesis', '', '', dbs.baseDat);
       end;

       tabla.Open;
       while not tabla.Eof do Begin
         tabla.Edit;
         tabla.FieldByName('orden').AsString := tabla.FieldByName('items').AsString;
         try
           tabla.Post
          except
           tabla.Cancel
         end;
         tabla.Next;
       end;
       datosdb.closeDB(tabla);
     end;
     GuardarRevision(xversion);
   end;
  end;

   if xversion = '1.00.05' then Begin
     if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
       existe := False;
       if dbs.BaseClientServ = 'N' then existe := datosdb.verificarSiExisteCampo('historiadiet_paciente', 'dhc', dbs.DirSistema + '\arch\');
       if dbs.BaseClientServ = 'S' then existe := datosdb.verificarSiExisteCampo('historiadiet_paciente', 'hdc', dbs.baseDat);
       if not existe then Begin
         if dbs.BaseClientServ = 'N' then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE historiadiet_paciente ADD hdc numeric, ADD prot numeric, ADD grasas numeric') else
           datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE historiadiet_paciente ADD grasas real, ADD prot real, ADD grasas real');
       end;
       GuardarRevision(xversion);
     end;
   end;

   if xversion = '1.00.10' then Begin
     if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
       existe := False;
       if dbs.BaseClientServ = 'N' then existe := datosdb.verificarSiExisteCampo('turnos', 'tt', dbs.DirSistema + '\arch\');
       if dbs.BaseClientServ = 'S' then existe := datosdb.verificarSiExisteCampo('turnos', 'tt', dbs.baseDat);
       if not existe then Begin
         if dbs.BaseClientServ = 'N' then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE turnos ADD tt CHAR(1)') else
           datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE turnos ADD tt VARCHAR(1)');
       end;
       GuardarRevision(xversion);
     end;
   end;

   if xversion = '1.00.20' then Begin
     if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
       existe := False;
       if dbs.BaseClientServ = 'N' then existe := datosdb.verificarSiExisteCampo('historiadiet_paciente', 'PesoTeorico', dbs.DirSistema + '\arch\');
       if dbs.BaseClientServ = 'S' then existe := datosdb.verificarSiExisteCampo('historiadiet_paciente', 'PesoTeorico', dbs.baseDat);
       if not existe then Begin
         if dbs.BaseClientServ = 'N' then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE historiadiet_paciente ADD PesoTeorico Numeric, ADD Sob1 Numeric, ADD Sob2 Numeric, ADD Sob3 Numeric)') else
           datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE historiadiet_paciente ADD PesoTeorico Real, ADD Sob1 Real, ADD Sob2 Real, ADD Sob3 Real');
       end;
       GuardarRevision(xversion);
     end;
   end;

   if xversion = '1.01.00' then Begin
     if not ActualizacionRealizada(xversion) then Begin
       existe := False;
       if dbs.BaseClientServ = 'N' then existe := datosdb.verificarSiExisteCampo('consultas_pacientes', 'Idatencion', dbs.DirSistema + '\arch\');
       if dbs.BaseClientServ = 'S' then existe := datosdb.verificarSiExisteCampo('consultas_pacientes', 'Idatencion', dbs.baseDat);
       if not existe then Begin
         if dbs.BaseClientServ = 'N' then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE consultas_pacientes ADD Idatencion CHAR(3), ADD ADD hora CHAR(8)') else
           datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE consultas_pacientes ADD Idatencion VARCHAR(3), ADD hora VARCHAR(8)');
       end;
       GuardarRevision(xversion);
     end;
   end;

   if xversion = '1.01.05' then Begin
     if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
       existe := False;
       if dbs.BaseClientServ = 'N' then existe := datosdb.verificarSiExisteCampo('turnos', 'atencion', dbs.DirSistema + '\arch\');
       if dbs.BaseClientServ = 'S' then existe := datosdb.verificarSiExisteCampo('turnos', 'atencion', dbs.baseDat);
       if not existe then Begin
         if dbs.BaseClientServ = 'N' then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE turnos ADD atencion CHAR(3)') else
           datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE turnos ADD atencion VARCHAR(3)');
       end;
       existe := False;
       GuardarRevision(xversion);
     end;
   end;

   if xversion = '1.01.09' then Begin
     if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
       existe := False;
       if dbs.BaseClientServ = 'N' then existe := datosdb.verificarSiExisteCampo('consultas_pacientes', 'adeuda', dbs.DirSistema + '\arch\');
       if dbs.BaseClientServ = 'S' then existe := datosdb.verificarSiExisteCampo('consultas_pacientes', 'adeuda', dbs.baseDat);
       if not existe then Begin
         if dbs.BaseClientServ = 'N' then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE consultas_pacientes ADD adeuda CHAR(1)') else
           datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE consultas_pacientes ADD adeuda VARCHAR(1)');
       end;

       if dbs.BaseClientServ = 'N' then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'UPDATE consultas_pacientes SET adeuda = ' + '''' + 'N' + '''' + ' WHERE adeuda = ' + '''' + '''') else
         datosdb.tranSQL(dbs.baseDat, 'UPDATE consultas_pacientes SET adeuda = ' + '''' + 'N' + '''' + ' WHERE adeuda = ' + '''' + '''');
       existe := False;
       GuardarRevision(xversion);
     end;
   end;

   if xversion = '1.01.10' then Begin
     if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
       if dbs.BaseClientServ = 'N' then tabla := datosdb.openDB('consultas_pacientes', '', '', dbs.DirSistema + '\arch\');
       if dbs.BaseClientServ = 'S' then tabla := datosdb.openDB('consultas_pacientes', '', '', dbs.baseDat);
       tabla.Open;
       while not tabla.Eof do Begin
         if Length(Trim(tabla.FieldByName('adeuda').AsString)) = 0 then Begin
           tabla.Edit;
           tabla.FieldByName('adeuda').AsString := 'N';
           try
             tabla.Post
            except
             tabla.Cancel
           end;
         end;
         tabla.Next;
       end;
       datosdb.closeDB(tabla);

       GuardarRevision(xversion);
     end;
   end;

   if xversion = '1.01.20' then Begin
     if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
       if dbs.BaseClientServ = 'N' then tabla := datosdb.openDB('consultas_pacientes', '', '', dbs.DirSistema + '\arch\');
       if dbs.BaseClientServ = 'S' then tabla := datosdb.openDB('consultas_pacientes', '', '', dbs.baseDat);
       if dbs.BaseClientServ = 'N' then Begin
         if not datosdb.verificarSiExisteCampo('consultas_pacientes', 'afavor', dbs.DirSistema + '\arch\') then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE consultas_pacientes ADD afavor numeric');
         if not datosdb.verificarSiExisteIndice('consultas_pacientes', 'afavor', dbs.DirSistema + '\arch\') then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'CREATE INDEX consultaspac_nombre ON consultas_pacientes(nombre)');
       end else Begin
         if not datosdb.verificarSiExisteCampo('consultas_pacientes', 'afavor', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE consultas_pacientes ADD afavor real');
         if not datosdb.verificarSiExisteIndice('consultas_pacientes', 'afavor', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'CREATE INDEX consultaspac_nombre ON consultas_pacientes(nombre)');
       end;

       GuardarRevision(xversion);
     end;
   end;

   if xversion = '1.01.21' then Begin
     if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
       if dbs.BaseClientServ = 'N' then tabla := datosdb.openDB('consultas_pacientes', '', '', dbs.DirSistema + '\arch\');
       if dbs.BaseClientServ = 'S' then tabla := datosdb.openDB('consultas_pacientes', '', '', dbs.baseDat);
       tabla.Open;
       while not tabla.Eof do Begin
         if (Length(Trim(tabla.FieldByName('idatencion').AsString)) = 0) or (Length(Trim(tabla.FieldByName('hora').AsString)) < 8) then Begin
           tabla.Edit;
           tabla.FieldByName('idatencion').AsString := '001';
           if Length(Trim(tabla.FieldByName('hora').AsString)) < 8 then tabla.FieldByName('hora').AsString := '10:00:00';
           try
             tabla.Post
            except
             tabla.Cancel
           end;
         end;
         tabla.Next;
       end;
       datosdb.closeDB(tabla);

       GuardarRevision(xversion);
     end;
   end;

   if xversion = '1.01.25' then Begin
     if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
       if dbs.BaseClientServ = 'N' then Begin
         if not datosdb.verificarSiExisteIndice('consultas_pacientes', 'cons_pac', dbs.DirSistema + '\arch\') then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'CREATE INDEX cons_pac ON consultas_pacientes(codpac)');
       end else Begin
         if not datosdb.verificarSiExisteIndice('consultas_pacientes', 'cons_pac', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'CREATE INDEX cons_pac ON consultas_pacientes(codpac)');
       end;

       GuardarRevision(xversion);
     end;
   end;

end;

constructor TTActualizacionesVicentin.Create;
begin
  if not FileExists(dbs.DirSistema + '\arch\upgrade.db') then
    datosdb.tranSQL(dbs.DirSistema + '\arch\', 'CREATE TABLE upgrade (Version CHAR(15), Actualizado CHAR(1), Fecha CHAR(10), PRIMARY KEY(version))');
  // Generamos una instancia para la tabla de actualizaciones
  upgradevers := datosdb.openDB('upgrade', 'Version', '', dbs.DirSistema + '\arch\');
  inherited Create;
end;

destructor TTActualizacionesVicentin.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function actualizaciones: TTActualizacionesVicentin;
begin
  if xactualizaciones = nil then
    xactualizaciones := TTActualizacionesVicentin.Create;
  Result := xactualizaciones;
end;

{===============================================================================}

initialization

finalization
  xactualizaciones.Free;

end.
