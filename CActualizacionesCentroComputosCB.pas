unit CActualizacionesCentroComputosCB;

interface

uses CActualizaciones, CBDT, SysUtils, DB, DBTables, CIDBFM, CUtiles, CUtilidadesArchivos, Classes,
     Forms;

type

TTActualizacionesCentroBioq = class(TTActualizaciones)
  upgrade: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  destroy; override;

  procedure   Version(xversion: String);
  procedure   ActualizarApFijos;
 private
  { Declaraciones Privadas }
  tabla, tabla1: TTable;
  items: Integer;
  idanter: array[1..5] of String;
  lista: TStringList;
  control: Boolean;
  procedure ActualizarValoresObrasSociales(xtablaobsocial: String);
  procedure ActualizarRetIvaOS;
  procedure ActualizarObrasSocialesVesr30015;
  procedure ActualizarObrasSocialesVesr30050;
end;

function actualizaciones: TTActualizacionesCentroBioq;

implementation

var
  xactualizaciones: TTActualizacionesCentroBioq = nil;

procedure TTActualizacionesCentroBioq.Version(xversion: String);
var
  i: Integer;
begin
  if xversion = '1.0.01' then
   if not ActualizacionRealizada(xversion) then Begin
     if dbs.BaseClientServ = 'S' then Begin
       datosdb.tranSQL('DROP INDEX DETFACT_RESUMENPROF');
       datosdb.tranSQL('CREATE INDEX DETFACT_RESUMENPROF ON detfact(Periodo, Idprof, Codos, Orden, Items)');
     end;
     datosdb.tranSQL(dbs.DirSistema + '\archdat', 'DROP INDEX detfact.DETFACT_RESUMENPROF');
     datosdb.tranSQL(dbs.DirSistema + '\archdat', 'CREATE INDEX DETFACT_RESUMENPROF ON detfact(Periodo, Idprof, Codos, Orden, Items)');
     datosdb.tranSQL(dbs.DirSistema + '\estructu', 'DROP INDEX detfact.DETFACT_RESUMENPROF');
     datosdb.tranSQL(dbs.DirSistema + '\estructu', 'CREATE INDEX DETFACT_RESUMENPROF ON detfact(Periodo, Idprof, Codos, Orden, Items)');
     datosdb.tranSQL(dbs.DirSistema + '\exportar', 'DROP INDEX detfact.DETFACT_RESUMENPROF');
     datosdb.tranSQL(dbs.DirSistema + '\exportar', 'CREATE INDEX DETFACT_RESUMENPROF ON detfact(Periodo, Idprof, Codos, Orden, Items)');
     datosdb.tranSQL(dbs.DirSistema + '\work',     'DROP INDEX detfact.DETFACT_RESUMENPROF');
     datosdb.tranSQL(dbs.DirSistema + '\work',     'CREATE INDEX DETFACT_RESUMENPROF ON detfact(Periodo, Idprof, Codos, Orden, Items)');

     GuardarRevision(xversion);
   end;

  if xversion = '1.10.00' then
   if not ActualizacionRealizada(xversion) then Begin
     if dbs.BaseClientServ = 'S' then Begin
       if Not datosdb.verificarSiExisteCampo('profesih', 'AjusteDC', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE profesih ADD AjusteDC CHAR(1)');
     end else Begin
       if Not datosdb.verificarSiExisteCampo('profesih', 'AjusteDC', dbs.DirSistema + '\archdat') then datosdb.tranSQL(dbs.DirSistema + '\archdat', 'ALTER TABLE profesih ADD AjusteDC CHAR(1)');
     end;

     GuardarRevision(xversion);
   end;
   if xversion = '1.50.00' then
    if not ActualizacionRealizada(xversion) then Begin
     if dbs.BaseClientServ = 'S' then Begin
       if Not datosdb.verificarSiExisteCampo('profesih', 'codfact', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE profesih ADD Codfact CHAR(6)');
     end else Begin
       if Not datosdb.verificarSiExisteCampo('profesih', 'codfact', dbs.DirSistema + '\archdat') then datosdb.tranSQL(dbs.DirSistema + '\archdat', 'ALTER TABLE profesih ADD Codfact CHAR(6)');
     end;
     GuardarRevision(xversion);
    end;
   if xversion = '1.50.01' then
    if not ActualizacionRealizada(xversion) then Begin
     if dbs.BaseClientServ = 'S' then Begin
       if Not datosdb.verificarSiExisteCampo('profesih', 'ajustedc', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE profesih ADD Ajustedc CHAR(1)');
     end else Begin
       if Not datosdb.verificarSiExisteCampo('profesih', 'ajustedc', dbs.DirSistema + '\archdat') then datosdb.tranSQL(dbs.DirSistema + '\archdat', 'ALTER TABLE profesih ADD Ajustedc CHAR(1)');
     end;
     GuardarRevision(xversion);
    end;

   if xversion = '2.00.00' then
    if not ActualizacionRealizada(xversion) then Begin
     if not DirectoryExists(dbs.DirSistema + '\exportar\attach') then utilesarchivos.CrearDirectorio(dbs.DirSistema + '\exportar\attach');
     if not datosdb.verificarSiExisteCampo('contacth', 'ciudad', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE contacth ADD Ciudad CHAR(25)');
     if not datosdb.verificarSiExisteCampo('contacth', 'localidad', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE contacth ADD Localidad CHAR(25)');
     GuardarRevision(xversion);
    end;

   if xversion = '2.00.01' then
    if not ActualizacionRealizada(xversion) then Begin
     ActualizarValoresObrasSociales('obsocial032003');
     GuardarRevision(xversion);
    end;

   if xversion = '2.00.10' then
    if not ActualizacionRealizada(xversion) then Begin
     if Not datosdb.verificarSiExisteCampo('paciente', 'Nrodoc', dbs.DirSistema + '\work')  then datosdb.tranSQL(dbs.DirSistema + '\work', 'ALTER TABLE paciente ADD Nrodoc CHAR(8)');
     if Not datosdb.verificarSiExisteIndice('paciente', 'Nrodoc', dbs.DirSistema + '\work') then datosdb.tranSQL(dbs.DirSistema + '\work', 'CREATE INDEX paciente_Doc ON paciente(Nrodoc)');
     if Not datosdb.verificarSiExisteCampo('paciente', 'Nrodoc', dbs.DirSistema + '\archdat')  then datosdb.tranSQL(dbs.DirSistema + '\archdat', 'ALTER TABLE paciente ADD Nrodoc CHAR(8)');
     if Not datosdb.verificarSiExisteIndice('paciente', 'Nrodoc', dbs.DirSistema + '\archdat') then datosdb.tranSQL(dbs.DirSistema + '\archdat', 'CREATE INDEX paciente_Doc ON paciente(Nrodoc)');
     GuardarRevision(xversion);
    end;

   if xversion = '2.00.15' then
    if not ActualizacionRealizada(xversion) then Begin
     if dbs.BaseClientServ = 'S' then Begin
       if Not datosdb.verificarSiExisteCampo('obsocial', 'capitada', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE obsocial ADD Capitada CHAR(1)');
     end else Begin
       if Not datosdb.verificarSiExisteCampo('obsocial', 'capitada', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'ALTER TABLE obsocial ADD Capitada CHAR(1)');
     end;
     GuardarRevision(xversion);
    end;

   if xversion = '2.50.00' then
    if not ActualizacionRealizada(xversion) then Begin
     if dbs.BaseClientServ = 'S' then Begin
       if Not datosdb.verificarSiExisteCampo('obsocial', 'Noimport', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE obsocial ADD Noimport CHAR(1)');
     end else Begin
       if Not datosdb.verificarSiExisteCampo('obsocial', 'Noimport', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'ALTER TABLE obsocial ADD Noimport CHAR(1)');
     end;
     GuardarRevision(xversion);
    end;

   if xversion = '3.00.00' then Begin
    if not ActualizacionRealizada(xversion) then Begin
     if dbs.BaseClientServ = 'S' then Begin
       if Not datosdb.verificarSiExisteCampo('obsocial', 'retencioniva', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE obsocial ADD retencioniva FLOAT');
       if Not datosdb.verificarSiExisteCampo('profesih', 'retieneiva', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE profesih ADD retieneiva CHAR(1)');
       if Not datosdb.verificarSiExisteCampo('profesih', 'nivel2', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE profesih ADD nivel2 CHAR(1)');
       if Not datosdb.verificarSiExisteCampo('paciente', 'Gravadoiva', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE paciente ADD Gravadoiva CHAR(1)');
     end else Begin
       if Not datosdb.verificarSiExisteCampo('obsocial', 'retencioniva', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'ALTER TABLE obsocial ADD retencioniva NUMERIC');
       if Not datosdb.verificarSiExisteCampo('profesih', 'retieneiva', dbs.DirSistema + '\archdat') then datosdb.tranSQL(dbs.DirSistema + '\archdat', 'ALTER TABLE profesih ADD retieneiva CHAR(1)');
       if Not datosdb.verificarSiExisteCampo('profesih', 'nivel2', dbs.DirSistema + '\archdat') then datosdb.tranSQL(dbs.DirSistema + '\archdat', 'ALTER TABLE profesih ADD nivel2 CHAR(1)');
       if Not datosdb.verificarSiExisteCampo('paciente', 'Gravadoiva', dbs.DirSistema + '\archdat') then datosdb.tranSQL(dbs.DirSistema + '\archdat', 'ALTER TABLE paciente ADD Gravadoiva CHAR(1)');
     end;
     if Not datosdb.verificarSiExisteCampo('paciente', 'Gravadoiva', dbs.DirSistema + '\work') then datosdb.tranSQL(dbs.DirSistema + '\work', 'ALTER TABLE paciente ADD Gravadoiva CHAR(1)');
     GuardarRevision(xversion);
    end;
   end;

   if xversion = '3.00.10' then
    if not ActualizacionRealizada(xversion) then Begin
      ActualizarRetIvaOS;
      GuardarRevision(xversion);
    end;

   if xversion = '3.00.20' then
    if not ActualizacionRealizada(xversion) then Begin
      if Not datosdb.verificarSiExisteCampo('paciente', 'gravadoiva', dbs.DirSistema + '\exportar') then datosdb.tranSQL(dbs.DirSistema + '\exportar', 'ALTER TABLE paciente ADD gravadoiva CHAR(1)');
      if Not datosdb.verificarSiExisteCampo('paciente', 'nrodoc', dbs.DirSistema + '\exportar') then datosdb.tranSQL(dbs.DirSistema + '\exportar', 'ALTER TABLE paciente ADD nrodoc CHAR(8)');
      //ActualizarObrasSocialesVesr30015;
      //ActualizarRetIvaOS;
      GuardarRevision(xversion);
    end;

   if xversion = '3.00.50' then
    if not ActualizacionRealizada(xversion) then Begin
      //ActualizarObrasSocialesVesr30050;
      GuardarRevision(xversion);
      if dbs.BaseClientServ = 'N' then
        if Not datosdb.verificarSiExisteCampo('paciente', 'exportar', dbs.DirSistema + '\archdat') then datosdb.tranSQL(dbs.DirSistema + '\archdat', 'ALTER TABLE paciente ADD exportar CHAR(1)');
      if dbs.BaseClientServ = 'S' then
        if Not datosdb.verificarSiExisteCampo('paciente', 'exportar', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE paciente ADD exportar CHAR(1)');
    end;

   if xversion = '3.01.00' then
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ = 'S' then Begin
        if not datosdb.verificarSiExisteTabla('obsocial_posiva') then datosdb.tranSQL(dbs.baseDat, 'create table obsocial_posiva (codos char(6) not null, periodo char(7) not null, retieneiva real, primary key(codos, periodo))');
      end else Begin
        if not FileExists(dbs.DirSistema + '\archdat\obsocial_posiva.db') then datosdb.tranSQL(dbs.DirSistema + '\archdat', 'create table obsocial_posiva (codos char(6), periodo char(7), retieneiva numeric, primary key(codos, periodo))');
      end;
      GuardarRevision(xversion);
    end;

   if xversion = '3.01.05' then
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ = 'S' then Begin
        if not datosdb.verificarSiExisteCampo('obsocial', 'retieneiva', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'alter table obsocial add retieneiva varchar(1)');
        tabla := datosdb.openDB('obsocial', '', '', dbs.baseDat);
      end else Begin
        if not datosdb.verificarSiExisteCampo('obsocial', 'retieneiva', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'alter table obsocial add retieneiva char(1)');
        tabla := datosdb.openDB('obsocial', '', '', dbs.DirSistema + '\arch');
      end;

      tabla.Open;
      while not tabla.Eof do Begin
        tabla.Edit;
        if tabla.FieldByName('retencioniva').AsFloat > 0 then tabla.FieldByName('retieneiva').AsString := 'S' else
          tabla.FieldByName('retieneiva').AsString := 'N';
        try
          tabla.Post
         except
          tabla.Cancel
        end;
        datosdb.refrescar(tabla);
        tabla.Next;
      end;
      datosdb.closeDB(tabla);
      GuardarRevision(xversion);
    end;

   if xversion = '3.01.10' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      // Almacenanos y regeneramos la tabla
      if dbs.BaseClientServ = 'S' then tabla := datosdb.openDB('apfijos', '', '', dbs.baseDat) else tabla := datosdb.openDB('apfijos', '', '', dbs.DirSistema + '\arch');
      tabla.Open;
      lista := TStringList.Create;
      tabla.First;
      while not tabla.Eof do Begin
        lista.Add(tabla.FieldByName('codos').AsString + tabla.FieldByName('codanalisis').AsString + tabla.FieldByName('importe').AsString);
        tabla.Next;
      end;
      datosdb.closeDB(tabla);

      lista.SaveToFile(dbs.DirSistema + '\upgrades\apfijos.lst');

      if dbs.BaseClientServ = 'S' then Begin
        datosdb.tranSQL(dbs.baseDat, 'drop table apfijos');
        datosdb.tranSQL(dbs.baseDat, 'create table apfijos (codos varchar(6) not null, items varchar(3) not null, codanalisis varchar(4) not null, periodo varchar(7), importe real, primary key(codos, items))');
      end else Begin
        datosdb.tranSQL(dbs.DirSistema + '\arch', 'drop table apfijos');
        datosdb.tranSQL(dbs.DirSistema + '\arch', 'create table apfijos (codos char(6), items char(3), codanalisis char(4), periodo char(7), importe numeric, primary key(codos, items))');
      end;

      if dbs.BaseClientServ = 'S' then Begin
        if Not datosdb.verificarSiExisteIndice('apfijos', 'apfijos_cod', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'CREATE INDEX apfijos_codan ON apfijos(codos, codanalisis)');
      end else Begin
        if Not datosdb.verificarSiExisteIndice('apfijos', 'apfijos_cod', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'CREATE INDEX apfijos_codan ON apfijos(codos, codanalisis)');
      end;

      if dbs.BaseClientServ <> 'S' then ActualizarApFijos;

      GuardarRevision(xversion);
    end;
   end;

   if xversion = '3.01.15' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ = 'S' then Begin
        if not datosdb.verificarSiExisteCampo('obsociales_aranceles', 'tope', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'alter table obsociales_aranceles add tope varchar(1)');
        datosdb.tranSQL(dbs.baseDat, 'update obsociales_aranceles set tope = ' + '''' + 'N' + '''');
      end else Begin
        if not datosdb.verificarSiExisteCampo('obsociales_aranceles', 'tope', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'alter table obsociales_aranceles add tope char(1)');
        datosdb.tranSQL(dbs.DirSistema + '\arch', 'update obsociales_aranceles set tope = ' + '''' + 'N' + '''');
      end;
    end;

    GuardarRevision(xversion);
   end;

   if xversion = '3.01.17' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ = 'S' then Begin
        if not datosdb.verificarSiExisteCampo('retenciones', 'retliq', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'alter table retenciones add retliq varchar(1)');
        datosdb.tranSQL(dbs.baseDat, 'update retenciones set retliq = ' + '''' + 'N' + '''');
      end else Begin
        if not datosdb.verificarSiExisteCampo('retenciones', 'retliq', dbs.DirSistema + '\archdat') then datosdb.tranSQL(dbs.DirSistema + '\archdat', 'alter table retenciones add retliq char(1)');
        datosdb.tranSQL(dbs.DirSistema + '\archdat', 'update retenciones set retliq = ' + '''' + 'N' + '''');
      end;
    end;

    GuardarRevision(xversion);
   end;

   if xversion = '3.01.18' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ = 'S' then Begin
        if not datosdb.verificarSiExisteCampo('escalaretenciones', 'exedente', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'alter table escalaretenciones add exedente real');
        if not datosdb.verificarSiExisteCampo('escalaretenciones', 'retfija', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'alter table escalaretenciones add retfija real');
      end else Begin
        if not datosdb.verificarSiExisteCampo('escalaretenciones', 'exedente', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'alter table escalaretenciones add exedente numeric');
        if not datosdb.verificarSiExisteCampo('escalaretenciones', 'retfija', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'alter table escalaretenciones add retfija numeric');
      end;
    end;

    GuardarRevision(xversion);
   end;

   if xversion = '3.01.19' then Begin   // Solo para Versiones de Laboratorios
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ = 'S' then Begin
        if not datosdb.verificarSiExisteCampo('totalesos', 'nombre', dbs.baseDat) then datosdb.tranSQL(dbs.TDB1.DatabaseName, 'alter table totalesos add nombre varchar(60)');
        if not datosdb.verificarSiExisteCampo('totalesos', 'tipoing', dbs.baseDat) then datosdb.tranSQL(dbs.TDB1.DatabaseName, 'alter table totalesos add tipoing Integer');
      end else Begin
        if not datosdb.verificarSiExisteCampo('totalesos', 'nombre', dbs.DirSistema + '\archdat') then datosdb.tranSQL(dbs.DirSistema + '\archdat', 'alter table totalesos add nombre char(60)');
        if not datosdb.verificarSiExisteCampo('totalesos', 'tipoing', dbs.DirSistema + '\archdat') then datosdb.tranSQL(dbs.DirSistema + '\archdat', 'alter table totalesos add tipoing integer');
      end;
    end;

    GuardarRevision(xversion);
   end;

   if xversion = '3.05.00' then Begin
    if not ActualizacionRealizada(xversion) then Begin

      control := True;
      // Nuevo Nomenclador
      if dbs.BaseClientServ = 'S' then Begin
        if not datosdb.verificarSiExisteTabla('NBU') then Begin
          datosdb.tranSQL(dbs.baseDat, 'create table NBU (codigo varchar(6) not null, descrip varchar(90), unidad real, primary key(codigo))');
          datosdb.tranSQL(dbs.baseDat, 'CREATE INDEX NBU_DESCRIP ON NBU(descrip)');
          control := False;
        end;
      end else Begin
        if not datosdb.verificarSiExisteTabla('NBU') then Begin
          datosdb.tranSQL(dbs.DirSistema + '\arch', 'create table NBU (codigo char(6), descrip char(90), unidad numeric, primary key(codigo))');
          datosdb.tranSQL(dbs.DirSistema + '\arch', 'CREATE INDEX NBU_DESCRIP ON NBU(descrip)');
          control := False;
        end;
      end;

      if dbs.BaseClientServ = 'S' then tabla := datosdb.openDB('nbu', '', '', dbs.baseDat) else
        tabla := datosdb.openDB('nbu', '', '', dbs.DirSistema + '\arch');


      // Gestionamos los datos
      if (FileExists(dbs.DirSistema + '\upgrades\vers30500\nbu.db')) and (control) then Begin
        tabla1 := datosdb.openDB('nbu', '', '', dbs.DirSistema + '\upgrades\vers30500');
        tabla.Open; tabla1.Open;
        while not tabla1.Eof do Begin
          if tabla.FindKey([tabla1.FieldByName('codigo').AsString]) then tabla.Edit else tabla.Append;
          tabla.FieldByName('codigo').AsString  := tabla1.FieldByName('codigo').AsString;
          tabla.FieldByName('descrip').AsString := tabla1.FieldByName('descrip').AsString;
          tabla.FieldByName('unidad').AsFloat   := tabla1.FieldByName('unidad').AsFloat;
          try
            tabla.Post
           except
            tabla.Cancel
          end;
          tabla1.Next;
        end;

        datosdb.closeDB(tabla); datosdb.closeDB(tabla1);
      end;

      // Ajustes Obra Social
      if dbs.BaseClientServ = 'S' then Begin
        if not datosdb.verificarSiExisteCampo('obsocial', 'factnbu', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'alter table obsocial add factnbu varchar(1)');
        if not datosdb.verificarSiExisteCampo('obsocial', 'pernbu', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'alter table obsocial add pernbu varchar(7)');
      end;
      if dbs.BaseClientServ = 'N' then Begin
        if not datosdb.verificarSiExisteCampo('obsocial', 'factnbu', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'alter table obsocial add factnbu char(1)');
        if not datosdb.verificarSiExisteCampo('obsocial', 'pernbu', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'alter table obsocial add pernbu varchar(7)');
      end;

      if dbs.BaseClientServ = 'S' then tabla := datosdb.openDB('obsocial', '', '', dbs.baseDat) else
        tabla := datosdb.openDB('obsocial', '', '', dbs.DirSistema + '\arch');

      // Exportaciones
      if (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbcentrobioq.exe') then Begin
        if not datosdb.verificarSiExisteCampo('obsocial', 'factnbu', dbs.DirSistema + '\work\actonline') then datosdb.tranSQL(dbs.DirSistema + '\work\actonline', 'alter table obsocial add factnbu char(1)');
        if not datosdb.verificarSiExisteCampo('obsocial', 'pernbu', dbs.DirSistema + '\work\actonline') then datosdb.tranSQL(dbs.DirSistema + '\work\actonline', 'alter table obsocial add pernbu varchar(7)');
      end;

      // Creamos tabla para aranceles
      if dbs.BaseClientServ = 'S' then Begin
        if not datosdb.verificarSiExisteTabla('arancelesnbu') then Begin
          datosdb.tranSQL(dbs.baseDat, 'create table arancelesNBU (codos varchar(6) not null, periodo varchar(7) not null, valor real, primary key(codos, periodo))');
        end;
      end else Begin
        if not datosdb.verificarSiExisteTabla('arancelesnbu') then Begin
          datosdb.tranSQL(dbs.DirSistema + '\arch', 'create table arancelesNBU (codos char(6), periodo char(7), valor numeric, primary key(codos, periodo))');
        end;
      end;

      // Aranceles para Exportar
      if (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbcentrobioq.exe') or (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbcentrobioq1.exe') then Begin
        if not FileExists(dbs.DirSistema + '\work\actonline\arancelesNBU.db') then Begin
          datosdb.tranSQL(dbs.DirSistema + '\work\actonline', 'create table arancelesNBU (codos char(6), periodo char(7), valor numeric, primary key(codos, periodo))');
        end;
      end;

    end;

    GuardarRevision(xversion);
   end;

   if xversion = '3.05.01' then
    if not ActualizacionRealizada(xversion) then Begin
     if dbs.BaseClientServ = 'S' then Begin
       if Not datosdb.verificarSiExisteCampo('retenciones', 'honorarios', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE retenciones ADD honorarios CHAR(1)');
     end else Begin
       if Not datosdb.verificarSiExisteCampo('retenciones', 'honorarios', dbs.DirSistema + '\archdat') then datosdb.tranSQL(dbs.DirSistema + '\archdat', 'ALTER TABLE retenciones ADD honorarios CHAR(1)');
     end;
     GuardarRevision(xversion);
    end;

   if xversion = '3.05.07' then Begin
    if not ActualizacionRealizada(xversion) then Begin
     if dbs.BaseClientServ = 'S' then Begin
       if datosdb.verificarSiExisteTabla('DEB_TEMP') then datosdb.tranSQL('drop table deb_temp');
       datosdb.tranSQL('create table deb_temp (items varchar(4) not null, idprof varchar(6) not null, per_inicio varchar(7) not null, per_final varchar(7), monton real, montod real, primary key (items, idprof, per_inicio))');
       tabla1 := datosdb.openDB('deb_temp', '');
       tabla  := datosdb.openDB('debindividuales', '');
       tabla.Open; tabla1.Open;
       tabla.First;
       while not tabla.Eof do Begin
         if datosdb.Buscar(tabla1, 'items', 'idprof', 'per_inicio', tabla.FieldByName('items').AsString, tabla.FieldByName('idprof').AsString, tabla.FieldByName('per_inicio').AsString) then tabla1.Edit else tabla1.Append;
         tabla1.FieldByName('items').AsString      := tabla.FieldByName('items').AsString;
         tabla1.FieldByName('idprof').AsString     := tabla.FieldByName('idprof').AsString;
         tabla1.FieldByName('per_inicio').AsString := tabla.FieldByName('per_inicio').AsString;
         tabla1.FieldByName('per_final').AsString  := tabla.FieldByName('per_final').AsString;
         tabla1.FieldByName('monton').AsFloat      := tabla.FieldByName('monton').AsFloat;
         tabla1.FieldByName('montod').AsFloat      := tabla.FieldByName('montod').AsFloat;
         try
           tabla1.Post
          except
           tabla1.Cancel
         end;
         datosdb.refrescar(tabla1);
         tabla.Next;
       end;
       datosdb.closeDB(tabla); datosdb.closeDB(tabla1);

       //-----------------------------------------------------------------------

       if datosdb.verificarSiExisteTabla('DEBINDIVIDUALES') then datosdb.tranSQL('drop table debindividuales');
       datosdb.tranSQL('create table debindividuales (items varchar(4) not null, idprof varchar(6) not null, per_inicio varchar(7) not null, per_final varchar(7), monton real, montod real, primary key (items, idprof, per_inicio))');
       tabla1 := datosdb.openDB('debindividuales', '');
       tabla  := datosdb.openDB('deb_temp', '');
       tabla.Open; tabla1.Open;
       tabla.First;
       while not tabla.Eof do Begin
         tabla1.Append;
         tabla1.FieldByName('items').AsString      := tabla.FieldByName('items').AsString;
         tabla1.FieldByName('idprof').AsString     := tabla.FieldByName('idprof').AsString;
         tabla1.FieldByName('per_inicio').AsString := tabla.FieldByName('per_inicio').AsString;
         tabla1.FieldByName('per_final').AsString  := tabla.FieldByName('per_final').AsString;
         tabla1.FieldByName('monton').AsFloat      := tabla.FieldByName('monton').AsFloat;
         tabla1.FieldByName('montod').AsFloat      := tabla.FieldByName('montod').AsFloat;
         try
           tabla1.Post
          except
           tabla1.Cancel
         end;
         datosdb.refrescar(tabla1);
         tabla.Next;
       end;
       datosdb.closeDB(tabla); datosdb.closeDB(tabla1);

       datosdb.tranSQL('drop table deb_temp');

     end else Begin

       if datosdb.verificarSiExisteTabla('DEB_TEMP') then datosdb.tranSQL('drop table deb_temp');
       datosdb.tranSQL('create table deb_temp (items char(4), idprof char(6), per_inicio char(7), per_final char(7), monton numeric, montod numeric, primary key (items, idprof, per_inicio))');
       tabla1 := datosdb.openDB('deb_temp', '');
       tabla  := datosdb.openDB('debindividuales', '', '', dbs.DirSistema + '\archdat');
       tabla.Open; tabla1.Open;
       tabla.First;
       while not tabla.Eof do Begin
         if datosdb.Buscar(tabla1, 'items', 'idprof', 'per_inicio', tabla.FieldByName('items').AsString, tabla.FieldByName('idprof').AsString, tabla.FieldByName('per_inicio').AsString) then tabla1.Edit else tabla1.Append;
         tabla1.FieldByName('items').AsString      := tabla.FieldByName('items').AsString;
         tabla1.FieldByName('idprof').AsString     := tabla.FieldByName('idprof').AsString;
         tabla1.FieldByName('per_inicio').AsString := tabla.FieldByName('per_inicio').AsString;
         tabla1.FieldByName('per_final').AsString  := tabla.FieldByName('per_final').AsString;
         tabla1.FieldByName('monton').AsFloat      := tabla.FieldByName('monton').AsFloat;
         tabla1.FieldByName('montod').AsFloat      := tabla.FieldByName('montod').AsFloat;
         try
           tabla1.Post
          except
           tabla1.Cancel
         end;
         datosdb.refrescar(tabla1);
         tabla.Next;
       end;
       datosdb.closeDB(tabla); datosdb.closeDB(tabla1);

       //-----------------------------------------------------------------------

       if FileExists(dbs.DirSistema + '\archdat\debindividuales.db') then datosdb.tranSQL(dbs.DirSistema + '\archdat', 'drop table debindividuales');
       datosdb.tranSQL(dbs.DirSistema + '\archdat', 'create table debindividuales (items char(4), idprof char(6), per_inicio char(7), per_final char(7), monton numeric, montod numeric, primary key (items, idprof, per_inicio))');
       tabla1 := datosdb.openDB('debindividuales', '', '', dbs.DirSistema + '\archdat\');
       tabla  := datosdb.openDB('deb_temp', '');
       tabla.Open; tabla1.Open;
       tabla.First;
       while not tabla.Eof do Begin
         tabla1.Append;
         tabla1.FieldByName('items').AsString      := tabla.FieldByName('items').AsString;
         tabla1.FieldByName('idprof').AsString     := tabla.FieldByName('idprof').AsString;
         tabla1.FieldByName('per_inicio').AsString := tabla.FieldByName('per_inicio').AsString;
         tabla1.FieldByName('per_final').AsString  := tabla.FieldByName('per_final').AsString;
         tabla1.FieldByName('monton').AsFloat      := tabla.FieldByName('monton').AsFloat;
         tabla1.FieldByName('montod').AsFloat      := tabla.FieldByName('montod').AsFloat;
         try
           tabla1.Post
          except
           tabla1.Cancel
         end;
         datosdb.refrescar(tabla1);
         tabla.Next;
       end;
       datosdb.closeDB(tabla); datosdb.closeDB(tabla1);

       datosdb.tranSQL('drop table deb_temp');

     end;
     GuardarRevision(xversion);
    end;
  end;

  if xversion = '3.05.09' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ = 'S' then Begin
        if not datosdb.verificarSiExisteCampo('NBU', 'codnnn', dbs.baseDat) then Begin
          datosdb.tranSQL(dbs.baseDat, 'alter table NBU add CODNNN varchar(4)');
          datosdb.tranSQL(dbs.baseDat, 'create index NBU_CODNNN ON NBU(CODNNN)');
        end
      end else Begin
        if not datosdb.verificarSiExisteCampo('NBU', 'codnnn', dbs.DirSistema + '\arch') then Begin
          datosdb.tranSQL(dbs.DirSistema + '\arch', 'alter table NBU add CODNNN varchar(4)');
          datosdb.tranSQL(dbs.DirSistema + '\arch', 'create index NBU_CODNNN ON NBU(CODNNN)');
        end;
      end;
      GuardarRevision(xversion);
    end;
  end;

  if xversion = '3.05.10' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ = 'S' then Begin
        if not datosdb.verificarSiExisteTabla('apfijosNBU') then datosdb.tranSQL(dbs.baseDat, 'create table apfijosNBU (codos varchar(6) not null, items varchar(3) not null, codanalisis varchar(6) not null, periodo varchar(7), importe real, primary key(codos, items))');
      end else Begin
        if not datosdb.verificarSiExisteTabla('apfijosNBU') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'create table apfijosNBU (codos char(6), items char(3), codanalisis char(6), periodo char(7), importe numeric, primary key(codos, items))');
      end;

      if dbs.BaseClientServ = 'S' then Begin
        if Not datosdb.verificarSiExisteIndice('apfijosNBU', 'apfijos_cod', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'CREATE INDEX apfijos_cod ON apfijosNBU(codos, codanalisis)');
      end else Begin
        if Not datosdb.verificarSiExisteIndice('apfijosNBU', 'apfijos_cod', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'CREATE INDEX apfijos_cod ON apfijosNBU(codos, codanalisis)');
      end;

      GuardarRevision(xversion);
    end;
  end;

  if xversion = '3.05.11' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ = 'S' then Begin
        if not datosdb.verificarSiExisteTabla('codigosNBU') then datosdb.tranSQL(dbs.baseDat, 'create table codigosNBU (items varchar(3) not null, codigo varchar(6) not null, estado varchar(1) not null, primary key(items, codigo, estado))');
      end else Begin
        if not datosdb.verificarSiExisteTabla('codigosNBU') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'create table codigosNBU (items char(3), codigo char(6), estado char(1), primary key(items, codigo, estado))');
      end;

      if dbs.BaseClientServ = 'S' then Begin
        if Not datosdb.verificarSiExisteIndice('codigosNBU', 'codigo_nbu', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'CREATE INDEX codigo_nbu ON codigosNBU(codigo)');
      end else Begin
        if Not datosdb.verificarSiExisteIndice('codigosNBU', 'codigo_nbu', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'CREATE INDEX codigo_nbu ON codigosNBU(codigo)');
      end;

      GuardarRevision(xversion);
    end;
  end;

  if xversion = '3.05.15' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if not FileExists(dbs.DirSistema + '\work\actonline\apfijosNBU.db') then
        datosdb.tranSQL(dbs.DirSistema + '\work\actonline', 'create table apfijosNBU (codos char(6), items char(3), codanalisis char(6), importe numeric, periodo char(7), primary key(codos, items))');
      if not FileExists(dbs.DirSistema + '\work\actonline\arancelesNBU.db') then
        datosdb.tranSQL(dbs.DirSistema + '\work\actonline', 'create table arancelesNBU (codos char(6), periodo char(7), valor numeric, primary key(codos, periodo))');

      GuardarRevision(xversion);
    end;
  end;

  if xversion = '3.05.17' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ <> 'S' then Begin
        if not datosdb.verificarSiExisteCampo('apfijos', 'perhasta', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'alter table apfijos add perhasta char(7)');
        if not datosdb.verificarSiExisteCampo('apfijosNBU', 'perhasta', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'alter table apfijosNBU add perhasta char(7)');
      end else Begin
        if not datosdb.verificarSiExisteCampo('apfijos', 'perhasta', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'alter table apfijos add perhasta varchar(7)');
        if not datosdb.verificarSiExisteCampo('apfijosNBU', 'perhasta', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'alter table apfijosNBU add perhasta varchar(7)');
      end;

      GuardarRevision(xversion);
    end;
  end;

  if xversion = '3.05.18' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteCampo('apfijos', 'perhasta', dbs.DirSistema + '\work\actonline') then datosdb.tranSQL(dbs.DirSistema + '\work\actonline', 'alter table apfijos add perhasta char(7)');
      if not datosdb.verificarSiExisteCampo('apfijosNBU', 'perhasta', dbs.DirSistema + '\work\actonline') then datosdb.tranSQL(dbs.DirSistema + '\work\actonline', 'alter table apfijosNBU add perhasta char(7)');
      GuardarRevision(xversion);
    end;
  end;

  if xversion = '3.05.20' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ = 'S' then Begin
        if not datosdb.verificarSiExisteTabla('AranNBU') then datosdb.tranSQL(dbs.baseDat, 'create table AranNBU (codos varchar(6) not null, items varchar(3) not null, codigo varchar(6) not null, unidad real, perdesde varchar(7), perhasta varchar(7), primary key(codos, items))');
      end else Begin
        if not datosdb.verificarSiExisteTabla('AranNBU') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'create table AranNBU (codos char(6), items char(3), codigo char(6), unidad numeric, perdesde char(7), perhasta char(7), primary key(codos, items))');
      end;

      if not DirectoryExists(dbs.DirSistema + '\work\actonline\') then
        utilesarchivos.CrearDirectorio(dbs.DirSistema + '\work\actonline\');

      if not FileExists(dbs.DirSistema + '\work\actonline\aranNBU.db') then
        datosdb.tranSQL(dbs.DirSistema + '\work\actonline', 'create table AranNBU (codos char(6), items char(3), codigo char(6), unidad numeric, perdesde char(7), perhasta char(7), primary key(codos, items))');

      if dbs.BaseClientServ = 'S' then reinicia := True;
      GuardarRevision(xversion);
    end;
  end;

  if xversion = '3.05.50' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ = 'S' then Begin
        if not datosdb.verificarSiExisteTabla('nbu_nnn') then datosdb.tranSQL(dbs.baseDat, 'create table nbu_nnn (codigo varchar(6) not null, codnnn varchar(4) not null, primary key(codigo, codnnn))');
      end else Begin
        if not datosdb.verificarSiExisteTabla('nbu_nnn') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'create table nbu_nnn (codigo char(6), codnnn char(4), primary key(codigo, codnnn))');
      end;

      if dbs.BaseClientServ = 'S' then  reinicia := True;
      GuardarRevision(xversion);
    end;
  end;

  if xversion = '3.05.70' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ = 'S' then Begin
        if Not datosdb.verificarSiExisteIndice('nbu_nnn', 'NBU_NNN_CODNNN', dbs.BaseDat) then datosdb.tranSQL(dbs.BaseDat, 'CREATE INDEX NBU_NNN_CODNNN ON nbu_nnn(codnnn)');
      end else Begin
        if Not datosdb.verificarSiExisteIndice('nbu_nnn', 'NBU_NNN_CODNNN', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'CREATE INDEX NBU_NNN_CODNNN ON nbu_nnn(codnnn)');
      end;

      GuardarRevision(xversion);
    end;
  end;

  if xversion = '3.06.001' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ = 'S' then Begin
        if not datosdb.verificarSiExisteTabla('posiva_prof') then Begin
          datosdb.tranSQL(dbs.baseDat, 'create table posiva_prof (idprof varchar(6) not null, periodo varchar(6) not null, retieneiva varchar(1), ajustedc varchar(1), primary key(idprof, periodo))');
        end;
      end else Begin
        if not datosdb.verificarSiExisteTabla('posiva_prof') then Begin
          datosdb.tranSQL(dbs.DirSistema + '\arch', 'create table posiva_prof (idprof char(6), periodo char(6), retieneiva char(1), ajustedc char(1), primary key(idprof, periodo))');
        end;
      end;

      if dbs.BaseClientServ = 'S' then reinicia := True;
      GuardarRevision(xversion);
    end;
  end;

  if xversion = '3.06.002' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ = 'S' then Begin
        tabla  := datosdb.openDB('profesih', '', '', dbs.baseDat);
        tabla1 := datosdb.openDB('posiva_prof', '', '', dbs.baseDat);
      end;
      if dbs.BaseClientServ = 'N' then Begin
        tabla  := datosdb.openDB('profesih', '', '', dbs.DirSistema + '\archdat');
        tabla1 := datosdb.openDB('posiva_prof', '', '', dbs.DirSistema + '\arch');
      end;

      tabla.Open; tabla1.Open;
      while not tabla.Eof do Begin
        if not datosdb.Buscar(tabla1, 'idprof', 'periodo', tabla.FieldByName('idprof').AsString, '012000') then Begin
          tabla1.Append;
          tabla1.FieldByName('idprof').AsString     := tabla.FieldByName('idprof').AsString;
          tabla1.FieldByName('periodo').AsString    := '012000';
          tabla1.FieldByName('retieneiva').AsString := tabla.FieldByName('retieneiva').AsString;
          tabla1.FieldByName('ajustedc').AsString   := tabla.FieldByName('ajustedc').AsString;
          try
            tabla1.Post
           except
            tabla1.Cancel
          end;
        end;
        tabla.Next;
      end;
      datosdb.closeDB(tabla); datosdb.closeDB(tabla);

      GuardarRevision(xversion);
    end;
  end;

  if xversion = '3.06.007' then Begin
    if not ActualizacionRealizada(xversion) then Begin
     if dbs.BaseClientServ = 'S' then Begin
       if Not datosdb.verificarSiExisteCampo('obsocial', 'baja', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE obsocial ADD baja CHAR(8)');
     end else Begin
       if Not datosdb.verificarSiExisteCampo('obsocial', 'baja', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'ALTER TABLE obsocial ADD baja CHAR(8)');
     end;
     if FileExists(dbs.DirSistema + '\work\actonline\obsocial.db') then
       if Not datosdb.verificarSiExisteCampo('obsocial', 'baja', dbs.DirSistema + '\work\actonline\') then datosdb.tranSQL(dbs.DirSistema + '\work\actonline', 'ALTER TABLE obsocial ADD baja CHAR(8)');
     GuardarRevision(xversion);
     if dbs.BaseClientServ = 'S' then reinicia := True;
    end;
  end;

  if xversion = '3.07.009' then Begin
    if not ActualizacionRealizada(xversion) then Begin
     if dbs.BaseClientServ = 'S' then Begin
       if Not datosdb.verificarSiExisteCampo('nbu', 'especial', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE nbu ADD especial CHAR(1)');
       if Not datosdb.verificarSiExisteCampo('nbu', 'unidades', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE nbu ADD unidades REAL');
     end else Begin
       if Not datosdb.verificarSiExisteCampo('nbu', 'especial', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'ALTER TABLE nbu ADD especial CHAR(1)');
       if Not datosdb.verificarSiExisteCampo('nbu', 'unidades', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'ALTER TABLE nbu ADD unidades NUMERIC');
     end;
     GuardarRevision(xversion);
     if dbs.BaseClientServ = 'S' then reinicia := True;
    end;
  end;

  if xversion = '3.07.015' then Begin
    if not ActualizacionRealizada(xversion) then Begin
     if dbs.BaseClientServ = 'S' then Begin
       if Not datosdb.verificarSiExisteCampo('arancelesnbu', 'valordif', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE arancelesnbu ADD valordif REAL');
     end else Begin
       if Not datosdb.verificarSiExisteCampo('arancelesnbu', 'valordif', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'ALTER TABLE arancelesnbu ADD valordif NUMERIC');
     end;
     GuardarRevision(xversion);
     if dbs.BaseClientServ = 'S' then reinicia := True;
    end;
  end;

  if xversion = '4.01.001' then Begin
    if Not datosdb.verificarSiExisteCampo('detfact', 'ref1', dbs.DirSistema + '\exportar') then datosdb.tranSQL(dbs.DirSistema + '\exportar', 'ALTER TABLE detfact ADD ref1 char(10)');
    if Not datosdb.verificarSiExisteCampo('detfact', 'ref1', dbs.DirSistema + '\work\factNBU') then datosdb.tranSQL(dbs.DirSistema + '\work\factNBU', 'ALTER TABLE detfact ADD ref1 char(10)');
    GuardarRevision(xversion);
  End;

  if xversion = '4.01.005' then Begin
    if Not datosdb.verificarSiExisteCampo('obsocial', 'ruptura_orden', dbs.baseDat) then datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE obsocial ADD RUPTURA_ORDEN INTEGER');
    GuardarRevision(xversion);
  End;


end;

//==============================================================================

procedure TTActualizacionesCentroBioq.ActualizarValoresObrasSociales(xtablaobsocial: String);
var
  i: Integer; Existe: Boolean;
  tupg: TTable;
begin
  if FileExists(dbs.DirSistema + '\upgrades\' + xtablaobsocial + '.db') then Begin
    tact := datosdb.openDB('obsocial', 'Codos', '', '', dbs.DirSistema + '\arch');
    tupg := datosdb.openDB(xtablaobsocial, 'Codos', '', '', dbs.DirSistema + '\upgrades');
    tupg.Open; tact.Open;
    while not tupg.EOF do Begin
      if tact.FindKey([tupg.FieldByName('codos').AsString]) then tact.Edit else tact.Append;
      For i := 1 to tupg.FieldDefs.Count do tact.Fields[i-1].Value := tupg.Fields[i-1].Value;
      try
        tact.Post
       except
        tact.Cancel
      end;
      tupg.Next;
    end;
    datosdb.closeDB(tact); datosdb.closeDB(tupg);
  end;
end;

procedure TTActualizacionesCentroBioq.ActualizarRetIvaOS;
var
  tabla: TTable;
Begin
  if dbs.BaseClientServ = 'S' then upgrade := datosdb.openDB('obsocial', '', '', dbs.baseDat) else upgrade := datosdb.openDB('obsocial', '', '', dbs.DirSistema + '\arch');
  tabla := datosdb.openDB('obsocial', '', '', dbs.DirSistema + '\upgrades\vers30010');
  upgrade.Open; tabla.Open;
  while not tabla.Eof do Begin
    if upgrade.FindKey([tabla.FieldByName('codos').AsString]) then Begin
      upgrade.Edit;
      upgrade.FieldByName('retencioniva').AsFloat := tabla.FieldByName('retencioniva').AsFloat;
      try
        upgrade.Post
       except
        upgrade.Cancel
      end;
    end;
    tabla.Next;
  end;
  datosdb.closeDB(tabla);
  datosdb.closeDB(upgrade);
end;

procedure TTActualizacionesCentroBioq.ActualizarObrasSocialesVesr30015;
var
  tabla: TTable;
Begin
  if dbs.BaseClientServ = 'S' then upgrade := datosdb.openDB('obsocial', '', '', dbs.baseDat) else upgrade := datosdb.openDB('obsocial', '', '', dbs.DirSistema + '\arch');
  tabla := datosdb.openDB('obsocial', '', '', dbs.DirSistema + '\upgrades\vers30010\vers30011');
  upgrade.Open; tabla.Open;
  while not tabla.Eof do Begin
    if upgrade.FindKey([tabla.FieldByName('codos').AsString]) then upgrade.Edit else upgrade.Append;
    upgrade.FieldByName('codos').AsString       := tabla.FieldByName('codos').AsString;
    upgrade.FieldByName('nombre').AsString      := tabla.FieldByName('nombre').AsString;
    upgrade.FieldByName('nombrec').AsString     := tabla.FieldByName('nombrec').AsString;
    upgrade.FieldByName('direccion').AsString   := tabla.FieldByName('direccion').AsString;
    upgrade.FieldByName('localidad').AsString   := tabla.FieldByName('localidad').AsString;
    upgrade.FieldByName('codpos').AsString      := tabla.FieldByName('codpos').AsString;
    upgrade.FieldByName('ub').AsFloat           := tabla.FieldByName('ub').AsFloat;
    upgrade.FieldByName('ug').AsFloat           := tabla.FieldByName('ug').AsFloat;
    upgrade.FieldByName('rieub').AsFloat        := tabla.FieldByName('rieub').AsFloat;
    upgrade.FieldByName('rieug').AsFloat        := tabla.FieldByName('rieug').AsFloat;
    upgrade.FieldByName('porcentaje').AsFloat   := tabla.FieldByName('porcentaje').AsFloat;
    upgrade.FieldByName('codpfis').AsString     := tabla.FieldByName('codpfis').AsString;
    upgrade.FieldByName('nrocuit').AsString     := tabla.FieldByName('nrocuit').AsString;
    upgrade.FieldByName('categoria').AsString   := tabla.FieldByName('categoria').AsString;
    upgrade.FieldByName('tope').AsString        := tabla.FieldByName('tope').AsString;
    upgrade.FieldByName('topemin').AsFloat      := tabla.FieldByName('topemin').AsFloat;
    upgrade.FieldByName('topemax').AsFloat      := tabla.FieldByName('topemax').AsFloat;
    upgrade.FieldByName('capitada').AsString    := tabla.FieldByName('capitada').AsString;
    upgrade.FieldByName('noimport').AsString    := tabla.FieldByName('noimport').AsString;
    upgrade.FieldByName('retencioniva').AsFloat := tabla.FieldByName('retencioniva').AsFloat;
    try
      upgrade.Post
     except
      upgrade.Cancel
    end;
    tabla.Next;
  end;
  datosdb.closeDB(tabla);
  datosdb.closeDB(upgrade);

  tabla := Nil; upgrade := Nil;
  if dbs.BaseClientServ = 'S' then upgrade := datosdb.openDB('apfijos', '', '', dbs.baseDat) else upgrade := datosdb.openDB('apfijos', '', '', dbs.DirSistema + '\arch');
  tabla := datosdb.openDB('apfijos', '', '', dbs.DirSistema + '\upgrades\vers30010\vers30011');
  upgrade.Open; tabla.Open;
  if upgrade.IndexFieldNames <> 'codos;codanalisis' then upgrade.IndexFieldNames := 'codos;codanalisis';
  while not tabla.Eof do Begin
    if datosdb.Buscar(upgrade, 'codos', 'codanalisis', tabla.FieldByName('codos').AsString, tabla.FieldByName('codanalisis').AsString) then upgrade.Edit else upgrade.Append;
    upgrade.FieldByName('codos').AsString       := tabla.FieldByName('codos').AsString;
    upgrade.FieldByName('codanalisis').AsString := tabla.FieldByName('codanalisis').AsString;
    upgrade.FieldByName('importe').AsFloat      := tabla.FieldByName('importe').AsFloat;
    try
      upgrade.Post
     except
      upgrade.Cancel
    end;
    tabla.Next;
  end;
  datosdb.closeDB(tabla);
  datosdb.closeDB(upgrade);
end;

procedure TTActualizacionesCentroBioq.ActualizarObrasSocialesVesr30050;
var
  tabla: TTable;
Begin
  if dbs.BaseClientServ = 'S' then upgrade := datosdb.openDB('obsocial', '', '', dbs.baseDat) else upgrade := datosdb.openDB('obsocial', '', '', dbs.DirSistema + '\arch');
  tabla := datosdb.openDB('obsociales', '', '', dbs.DirSistema + '\upgrades\vers30050');
  upgrade.Open; tabla.Open;
  while not tabla.Eof do Begin
    if upgrade.FindKey([tabla.FieldByName('codos').AsString]) then upgrade.Edit else upgrade.Append;
    upgrade.FieldByName('codos').AsString       := tabla.FieldByName('codos').AsString;
    upgrade.FieldByName('nombre').AsString      := tabla.FieldByName('nombre').AsString;
    upgrade.FieldByName('nombrec').AsString     := tabla.FieldByName('nombrec').AsString;
    upgrade.FieldByName('direccion').AsString   := tabla.FieldByName('direccion').AsString;
    upgrade.FieldByName('localidad').AsString   := tabla.FieldByName('localidad').AsString;
    upgrade.FieldByName('codpos').AsString      := tabla.FieldByName('codpos').AsString;
    upgrade.FieldByName('ub').AsFloat           := tabla.FieldByName('ub').AsFloat;
    upgrade.FieldByName('ug').AsFloat           := tabla.FieldByName('ug').AsFloat;
    upgrade.FieldByName('rieub').AsFloat        := tabla.FieldByName('rieub').AsFloat;
    upgrade.FieldByName('rieug').AsFloat        := tabla.FieldByName('rieug').AsFloat;
    upgrade.FieldByName('nrocuit').AsString     := tabla.FieldByName('nrocuit').AsString;
    upgrade.FieldByName('categoria').AsString   := tabla.FieldByName('categoria').AsString;
    try
      upgrade.Post
     except
      upgrade.Cancel
    end;
    tabla.Next;
  end;
  datosdb.closeDB(tabla);
  datosdb.closeDB(upgrade);

  if dbs.BaseClientServ = 'S' then upgrade := datosdb.openDB('obsociales_aranceles', '', '', dbs.baseDat) else upgrade := datosdb.openDB('obsociales_aranceles', '', '', dbs.DirSistema + '\arch');
  tabla := datosdb.openDB('aranceles', '', '', dbs.DirSistema + '\upgrades\vers30050');
  upgrade.Open; tabla.Open;
  while not tabla.Eof do Begin
    if datosdb.Buscar(upgrade, 'periodo', 'codos', tabla.FieldByName('periodo').AsString, tabla.FieldByName('codos').AsString) then upgrade.Edit else upgrade.Append;
    upgrade.FieldByName('periodo').AsString := tabla.FieldByName('periodo').AsString;
    upgrade.FieldByName('codos').AsString   := tabla.FieldByName('codos').AsString;
    upgrade.FieldByName('ub').AsFloat       := tabla.FieldByName('ub').AsFloat;
    upgrade.FieldByName('ug').AsFloat       := tabla.FieldByName('ug').AsFloat;
    upgrade.FieldByName('rieub').AsFloat    := tabla.FieldByName('rieub').AsFloat;
    upgrade.FieldByName('rieug').AsFloat    := tabla.FieldByName('rieug').AsFloat;
    try
      upgrade.Post
     except
      upgrade.Cancel
    end;
    tabla.Next;
  end;
  datosdb.closeDB(tabla);
  datosdb.closeDB(upgrade);
end;

procedure TTActualizacionesCentroBioq.ActualizarApFijos;
var
  tabla: TTable;
  i: Integer;
Begin
  lista := TStringList.Create;
  lista.LoadFromFile(dbs.DirSistema + '\upgrades\apfijos.lst');
  if dbs.BaseClientServ = 'S' then tabla := datosdb.openDB('apfijos', '', '', dbs.baseDat) else tabla := datosdb.openDB('apfijos', '', '', dbs.DirSistema + '\arch');
    tabla.Open; items := 0;
    For i := 1 to lista.Count do Begin
      if Copy(lista.Strings[i-1], 1, 6) <> idanter[1] then Begin
        items := 0;
        idanter[1] := Copy(lista.Strings[i-1], 1, 6);
      end;
      Inc(items);
      if datosdb.Buscar(tabla, 'codos', 'items', Copy(lista.Strings[i-1], 1, 6), utiles.sLlenarIzquierda(IntToStr(items), 3, '0')) then tabla.Edit else tabla.Append;
      tabla.FieldByName('codos').AsString       := Copy(lista.Strings[i-1], 1, 6);
      tabla.FieldByName('items').AsString       := utiles.sLlenarIzquierda(IntToStr(items), 3, '0');
      tabla.FieldByName('codanalisis').AsString := Copy(lista.Strings[i-1], 7, 4);
      tabla.FieldByName('importe').AsString     := Trim(Copy(lista.Strings[i-1], 11, 10));
      try
        tabla.Post
       except
        tabla.Cancel
      end;
      datosdb.refrescar(tabla);
    end;
    datosdb.closeDB(tabla);
end;

constructor TTActualizacionesCentroBioq.Create;
begin
  inherited Create;
  if not FileExists(dbs.DirSistema + '\arch\upgrade.db') then
    datosdb.tranSQL(dbs.DirSistema + '\arch\', 'CREATE TABLE upgrade (Version CHAR(15), Actualizado CHAR(1), Fecha CHAR(10), PRIMARY KEY(version))');
  // Generamos una instancia para la tabla de actualizaciones
  upgradevers := datosdb.openDB('upgrade', 'Version', '', dbs.DirSistema + '\arch\');
  reinicia    := False;
end;

destructor TTActualizacionesCentroBioq.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function actualizaciones: TTActualizacionesCentroBioq;
begin
  if xactualizaciones = nil then
    xactualizaciones := TTActualizacionesCentroBioq.Create;
  Result := xactualizaciones;
end;

{===============================================================================}

initialization

finalization
  xactualizaciones.Free;

end.
