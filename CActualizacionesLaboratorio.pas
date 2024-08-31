unit CActualizacionesLaboratorio;

interface

uses CActualizaciones, CBDT, SysUtils, DB, DBTables, CIDBFM, CUtiles, CUtilidadesArchivos,  Classes;

type

TTActualizacionesLaboratorio = class(TTActualizaciones)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Version(xversion: String);
 private
  { Declaraciones Privadas }
  tabla: TTable;
  lista: TStringList;
  procedure ActualizarValoresNomeclador(xtablanomeclador: String);
  procedure ActualizarValoresObrasSociales(xtablaobsocial: String);
  procedure ActualizarObrasSocialesVesr2700;
  procedure verificarEstructuraOS;
  procedure ActualizarApFijos;
  procedure Actualizar300000;
end;

function actualizaciones: TTActualizacionesLaboratorio;

implementation

var
  xactualizaciones: TTActualizacionesLaboratorio = nil;

procedure TTActualizacionesLaboratorio.Version(xversion: String);
begin
  if not datosdb.verificarSiExisteCampo('ctrlprn', 'ModoTexto', dbs.DirSistema) then;

  if xversion = '1.0.00' then Begin
    // Actualizamos la tabla upgrade
    if upgradevers = Nil then Begin
      upgradevers := datosdb.openDB('upgradeLab', 'Version', '', dbs.DirSistema + '\arch\');
      upgradevers.Open;
      if upgradevers.FieldCount = 2 then Begin
        datosdb.closeDB(upgradevers);
        if not datosdb.verificarSiExisteCampo('upgradeLab', 'fecha', dbs.DirSistema + '\arch\') then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE upgradeLab ADD Fecha CHAR(10)');
        upgradevers := datosdb.openDB('upgradeLab', 'Version', '', dbs.DirSistema + '\arch\');
        upgradevers.Open;
      end;
      upgradevers.Close;
    end;
  end;

  if xversion = '1.0.01' then Begin
   if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
     if dbs.BaseClientServ = 'N' then Begin
     datosdb.tranSQL(dbs.DirSistema + '\arch\', 'DROP TABLE estadistica');
     datosdb.tranSQL(dbs.DirSistema + '\arch\', 'CREATE TABLE estadistica (Items INTEGER, Dato CHAR(60), Valor NUMERIC, PRIMARY KEY(Items))');
     datosdb.tranSQL(dbs.DirSistema + '\arch\', 'UPDATE usuarios SET clave = ' + '"' + '-' + '"' + ' WHERE clave = ' + '"' + '' + '"');
     end;
     GuardarRevision(xversion);
   end;
  end;

  if xversion = '1.1.01' then Begin
   if not ActualizacionRealizada(xversion) then Begin  // En esta version se regenera la tabla de Estadísticas
     if dbs.BaseClientServ = 'N' then Begin
     // Agrega dos campos a la tabla ctrlprn
     if not datosdb.verificarSiExisteCampo('ctrlprn', 'ModoTexto', dbs.DirSistema) then datosdb.tranSQL(dbs.DirSistema, 'ALTER TABLE ctrlprn ADD ModoTexto SMALLINT, ADD AltoPag SMALLINT');
     // Agrega dos campos a la tabla obsocial
     if not datosdb.verificarSiExisteCampo('obsocial', 'Codpfis', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE obsocial ADD codpfis CHAR(3), ADD nrocuit CHAR(13), ADD Categoria CHAR(1)');
     // Agrega dos campos a la tabla nomeclador
     if not datosdb.verificarSiExisteCampo('nomeclad', 'CF', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE nomeclad ADD CF CHAR(1)');

     // Agrega dos campos a la tabla detpres
     if not datosdb.verificarSiExisteCampo('detpres', 'Descrip', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE detpres ADD descrip CHAR(40)');
     if not datosdb.verificarSiExisteCampo('obsocial', 'Tope', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE obsocial ADD Tope CHAR(1), ADD Topemax NUMERIC, ADD Topemin NUMERIC');

     verificarEstructuraOS;
     ActualizarValoresNomeclador('nomeclad');
     ActualizarValoresObrasSociales('obsocial');
     end;

     GuardarRevision(xversion);
   end;
  end;

  if xversion = '1.5.00' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ = 'N' then Begin
        verificarEstructuraOS;
        ActualizarValoresNomeclador('nomeclad092002');
        ActualizarValoresObrasSociales('obsocial092002');
      end;
      GuardarRevision(xversion);
    end;
  end;

  if xversion = '1.9.00' then Begin
    if dbs.BaseClientServ = 'N' then Begin
      datosdb.tranSQL(dbs.DirSistema + '\arch\', 'DROP TABLE estadistica');
      datosdb.tranSQL(dbs.DirSistema + '\arch\', 'CREATE TABLE estadistica (Items INTEGER, Dato CHAR(60), Valor NUMERIC, PRIMARY KEY(Items))');
      if not datosdb.verificarSiExisteCampo('detpres', 'Cftoma', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE detpres ADD Cftoma NUMERIC');
    end;

    if dbs.BaseClientServ = 'N' then Begin
      if not ActualizacionRealizada(xversion) then Begin
        if datosdb.verificarSiExisteIndice('obsocial', 'Nombre', dbs.DirSistema + '\arch\') then datosdb.tranSQL(dbs.DirSistema + '\arch',  'DROP INDEX obsocial.Nombre');
        if datosdb.verificarSiExisteIndice('obsocial', 'OBSOCIAL_NOMBRE', dbs.DirSistema + '\arch\') then datosdb.tranSQL(dbs.DirSistema + '\arch',  'DROP INDEX obsocial.OBSOCIAL_NOMBRE');
        datosdb.tranSQL(dbs.DirSistema + '\arch',  'CREATE INDEX OBSOCIAL_NOMBRE ON obsocial(Nombre)');
      end;
    end;

    GuardarRevision(xversion);
  end;

  if xversion = '2.0.00' then Begin
    if not datosdb.verificarSiExisteIndice('solicitud', 'Codpac', dbs.DirSistema + '\arch\') then datosdb.tranSQL(dbs.DirSistema + '\arch',  'CREATE INDEX solicitud_pac ON solicitud(Codpac)');
    GuardarRevision(xversion);
  end;

  if xversion = '2.0.10' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteCampo('comregis', 'codmov_vtas', dbs.DirSistema + '\arch\') then datosdb.tranSQL(dbs.DirSistema + '\arch',  'ALTER TABLE comregis ADD codmov_vtas CHAR(3)');
      if not datosdb.verificarSiExisteCampo('comregis', 'codmov_com', dbs.DirSistema + '\arch\') then datosdb.tranSQL(dbs.DirSistema + '\arch',  'ALTER TABLE comregis ADD codmov_com CHAR(3)');
      if not datosdb.verificarSiExisteCampo('comregis', 'factura_vtas', dbs.DirSistema + '\arch\') then datosdb.tranSQL(dbs.DirSistema + '\arch',  'ALTER TABLE comregis ADD factura_vtas CHAR(1)');
      if not datosdb.verificarSiExisteCampo('comregis', 'factura_com', dbs.DirSistema + '\arch\') then datosdb.tranSQL(dbs.DirSistema + '\arch',  'ALTER TABLE comregis ADD factura_com CHAR(1)');
      if not datosdb.verificarSiExisteCampo('comregis', 'codnum', dbs.DirSistema + '\arch\') then datosdb.tranSQL(dbs.DirSistema + '\arch',  'ALTER TABLE comregis ADD codnum CHAR(2)');
      GuardarRevision(xversion);
    end;
  end;

  if xversion = '2.5.00' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if datosdb.verificarSiExisteIndice('nomeclad', 'nomeclad_descrip', dbs.DirSistema + '\arch\') then Begin
        datosdb.tranSQL(dbs.DirSistema + '\arch',  'DROP INDEX nomeclad.nomeclad_descrip');
        datosdb.tranSQL(dbs.DirSistema + '\arch',  'CREATE INDEX nomeclad_descrip ON nomeclad(Descrip)');
      end;
      if datosdb.verificarSiExisteIndice('nomeclad', 'nomecla_descrip', dbs.DirSistema + '\arch\') then Begin
        datosdb.tranSQL(dbs.DirSistema + '\arch',  'DROP INDEX nomeclad.nomecla_descrip');
        datosdb.tranSQL(dbs.DirSistema + '\arch',  'CREATE INDEX nomecla_descrip ON nomeclad(Descrip)');
      end;
      GuardarRevision(xversion);
    end;
  end;

  if xversion = '2.7.00' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      verificarEstructuraOS;
      ActualizarObrasSocialesVesr2700;
      GuardarRevision(xversion);
    end;
  end;

  if xversion = '2.9.00' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if not FileExists(dbs.DirSistema + '\arch\entidadesderivadoras.db') then Begin
        datosdb.tranSQL(dbs.DirSistema + '\arch\', 'CREATE TABLE entidadesderivadoras(identidad char(3), descrip CHAR(40), PRIMARY KEY(identidad))');
        datosdb.tranSQL(dbs.DirSistema + '\arch',  'CREATE INDEX entidad_descrip ON entidadesderivadoras(Descrip)');
      end;
      if not datosdb.verificarSiExisteCampo('solicitud', 'entidadderiv', dbs.DirSistema + '\arch\') then Begin
        datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE solicitud ADD entidadderiv char(3)');
        datosdb.tranSQL(dbs.DirSistema + '\arch\', 'UPDATE solicitud SET entidadderiv = ' + '"' + '000' + '"' + ' WHERE entidadderiv <= ' + '''' + ' ' + '''');
      end;
      GuardarRevision(xversion);
    end;
  end;

  if xversion = '2.9.50' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteCampo('apfijos', 'items', dbs.DirSistema + '\arch') then Begin
        // Almacenanos y regeneramos la tabla
        tabla := datosdb.openDB('apfijos', '', '', dbs.DirSistema + '\arch');
        tabla.Open;
        lista := TStringList.Create;
        tabla.First;
        while not tabla.Eof do Begin
          lista.Add(tabla.FieldByName('codos').AsString + tabla.FieldByName('codanalisis').AsString + tabla.FieldByName('importe').AsString);
          tabla.Next;
        end;
        datosdb.closeDB(tabla);

        lista.SaveToFile(dbs.DirSistema + '\upgrades\apfijos.lst');

        datosdb.tranSQL(dbs.DirSistema + '\arch', 'drop table apfijos');
        datosdb.tranSQL(dbs.DirSistema + '\arch', 'create table apfijos (codos char(6), items char(3), codanalisis char(4), periodo char(7), importe numeric, primary key(codos, items))');

        if Not datosdb.verificarSiExisteIndice('apfijos', 'apfijos_cod', dbs.DirSistema + '\arch') then datosdb.tranSQL(dbs.DirSistema + '\arch', 'CREATE INDEX apfijos_cod ON apfijos(codos, codanalisis)');

        if dbs.BaseClientServ <> 'S' then ActualizarApFijos;
      end;

      if not datosdb.verificarSiExisteCampo('solicitud', 'entidadderiv', dbs.DirSistema + '\historico') then
        datosdb.tranSQL(dbs.DirSistema + '\historico', 'alter table solicitud add entidadderiv char(3)');
    end;
    GuardarRevision(xversion);
  end;

  if xversion = '3.00.00' then Begin
     if not ActualizacionRealizada(xversion) then Begin
       if dbs.BaseClientServ <> 'S' then Begin
         if not datosdb.verificarSiExisteCampo('plantan', 'formula', dbs.DirSistema + '\arch\') then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE plantan ADD formula char(60)');
         if not datosdb.verificarSiExisteCampo('movpagos', 'bloqueo', dbs.DirSistema + '\arch\') then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE movpagos ADD bloqueo char(1)');
       end;
       if dbs.BaseClientServ = 'S' then Begin
         if not datosdb.verificarSiExisteCampo('plantan', 'formula', dbs.BaseDat) then datosdb.tranSQL(dbs.BaseDat, 'ALTER TABLE plantan ADD formula varchar(60)');
         if not datosdb.verificarSiExisteCampo('movpagos', 'bloqueo', dbs.BaseDat) then datosdb.tranSQL(dbs.BaseDat, 'ALTER TABLE movpagos ADD bloqueo varchar(1)');
       end;
       GuardarRevision(xversion);
     end;
  end;

  if xversion = '3.01.05' then Begin
     if not ActualizacionRealizada(xversion) then Begin
       if dbs.BaseClientServ <> 'S' then Begin
         if not datosdb.verificarSiExisteCampo('pacienth', 'compcel', dbs.DirSistema + '\arch\') then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE pacienth ADD compcel char(30)');
         if not datosdb.verificarSiExisteCampo('pacienth', 'email', dbs.DirSistema + '\arch\') then datosdb.tranSQL(dbs.DirSistema + '\arch\', 'ALTER TABLE pacienth ADD email char(60)');
       end;
       if dbs.BaseClientServ = 'S' then Begin
         if not datosdb.verificarSiExisteCampo('pacienth', 'compcel', dbs.baseDat_N) then datosdb.tranSQL(dbs.baseDat_N, 'ALTER TABLE pacienth ADD compcel varchar(30)');
         if not datosdb.verificarSiExisteCampo('pacienth', 'email', dbs.baseDat_N) then datosdb.tranSQL(dbs.baseDat_N, 'ALTER TABLE pacienth ADD email varchar(60)');
       end;
       GuardarRevision(xversion);
     end;
  end;

  if xversion = '3.01.050' then Begin
     if not ActualizacionRealizada(xversion) then Begin
       Actualizar300000;
       GuardarRevision(xversion);
     end;
  end;

  if xversion = '3.01.060' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ <> 'S' then Begin
        if not datosdb.verificarSiExisteIndice('resultado', 'resultado_res', dbs.DirSistema + '\arch\') then Begin
          datosdb.tranSQL(dbs.DirSistema + '\arch', 'CREATE INDEX resultado_res ON resultado(nrosolicitud,nroanalisis,items)');
        end;
      end;
      if dbs.BaseClientServ = 'S' then Begin
        if datosdb.verificarSiExisteIndice('resultado', 'resultado_res',  dbs.baseDat_N) then Begin
          datosdb.tranSQL(dbs.baseDat_N, 'CREATE INDEX resultado_res ON resultado(nrosolicitud,nroanalisis,items)');
        end;
      end;
      GuardarRevision(xversion);
    end;
  end;

  if xversion = '3.01.080' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if dbs.BaseClientServ = 'S' then Begin
        if not (datosdb.verificarSiExisteTabla('fotologo', dbs.TDB1)) then
          datosdb.tranSQL(dbs.baseDat_N, 'create table fotologo (id integer not null, foto varchar(120), t1 varchar(100), t2 varchar(100), t3 varchar(100), t4 varchar(100), primary key(id))');
      End;
      if dbs.BaseClientServ <> 'S' then Begin
        if not (datosdb.verificarSiExisteTabla('fotologo')) then
          datosdb.tranSQL(dbs.DirSistema + '\arch', 'create table fotologo (id integer, foto char(120), t1 char(100), t2 char(100), t3 char(100), t4 char(100), primary key(id))');
      End;
      GuardarRevision(xversion);
    End;
  End;

end;

procedure TTActualizacionesLaboratorio.verificarEstructuraOS;
begin
  if dbs.BaseClientServ <> 'S' then Begin
  if not datosdb.verificarSiExisteCampo('obsocial', 'retencioniva', dir) then datosdb.tranSQL(dir, 'ALTER TABLE obsocial ADD retencioniva NUMERIC');
  if not datosdb.verificarSiExisteCampo('obsocial', 'codpfis', dir) then datosdb.tranSQL(dir, 'ALTER TABLE obsocial ADD codpfis CHAR(1)');
  if not datosdb.verificarSiExisteCampo('obsocial', 'nrocuit', dir) then datosdb.tranSQL(dir, 'ALTER TABLE obsocial ADD nrocuit CHAR(13)');
  if not datosdb.verificarSiExisteCampo('obsocial', 'categoria', dir) then datosdb.tranSQL(dir, 'ALTER TABLE obsocial ADD categoria CHAR(1)');
  if not datosdb.verificarSiExisteCampo('obsocial', 'porcentaje', dir) then datosdb.tranSQL(dir, 'ALTER TABLE obsocial ADD porcentaje NUMERIC');
  end;
end;

procedure TTActualizacionesLaboratorio.ActualizarValoresObrasSociales(xtablaobsocial: String);
var
  i: Integer; Existe: Boolean;
  tabla: TTable;
begin
  upgrade := datosdb.openDB('obsocial', 'Codos', '', '', dbs.DirSistema + '\arch');
  tabla   := datosdb.openDB(xtablaobsocial, 'Codos', '', '', dbs.DirSistema + '\upgrades');
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
    upgrade.FieldByName('retencioniva').AsFloat := tabla.FieldByName('retencioniva').AsFloat;
    try
      upgrade.Post
     except
      upgrade.Cancel
    end;
    tabla.Next;
  end;
  datosdb.closeDB(tabla); datosdb.closeDB(upgrade);
end;

procedure TTActualizacionesLaboratorio.ActualizarValoresNomeclador(xtablanomeclador: String);
var
  i: Integer; Existe: Boolean;
  tupg: TTable;
begin
  tact := datosdb.openDB('nomeclad', 'Codigo', '', '', dbs.DirSistema + '\arch');
  tupg := datosdb.openDB(xtablanomeclador, 'Codigo', '', '', dbs.DirSistema + '\upgrades');
  tupg.Open; tact.Open;
  while not tupg.EOF do Begin
     Existe := tact.FindKey([tupg.FieldByName('codigo').AsString]);
     if not Existe then Begin
       tact.Append;
       For i := 1 to tupg.FieldDefs.Count do Begin
         if i <= tact.FieldDefs.Count then tact.Fields[i-1].Value := tupg.Fields[i-1].Value;
       end;
       try
         tact.Post
        except
         tact.Cancel
       end;
     end else Begin
       tact.Edit;
       // Los campos que se actualizan son, U. gastos, U. Bioq, RIE, ub rie, ug rie
       For i := 1 to tupg.FieldDefs.Count do
         if (i = 3) or (i = 4) or (i = 6) or (i = 7) or (i = 8) then tact.Fields[i-1].Value := tupg.Fields[i-1].Value;
       try
         tact.Post
        except
         tact.Cancel
       end;
     end;
     tupg.Next;
   end;
   datosdb.closeDB(tact); datosdb.closeDB(tupg);
end;

procedure TTActualizacionesLaboratorio.ActualizarObrasSocialesVesr2700;
var
  tabla: TTable;
Begin
  upgrade := datosdb.openDB('obsocial', '', '', dir);
  tabla := datosdb.openDB('obsocial', '', '', dbs.DirSistema + '\upgrades\vers2700');
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
  tabla := datosdb.openDB('apfijos', '', '', dbs.DirSistema + '\upgrades\vers2700');
  upgrade.Open; tabla.Open;
  if not datosdb.verificarSiExisteCampo(upgrade, 'items') then Begin
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
  end;
  datosdb.closeDB(tabla);
  datosdb.closeDB(upgrade);
end;

procedure TTActualizacionesLaboratorio.ActualizarApFijos;
var
  tabla: TTable;
  i, items: Integer;
  idanter: array[1..1] of String;
Begin
  lista := TStringList.Create;
  lista.LoadFromFile(dbs.DirSistema + '\upgrades\apfijos.lst');
  tabla := datosdb.openDB('apfijos', '', '', dbs.DirSistema + '\arch');
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

constructor TTActualizacionesLaboratorio.Create;
begin
  inherited Create;
  if dbs.BaseClientServ = 'S' then dir := dbs.baseDat_N else dir := dbs.DirSistema + '\arch';
  dir := dbs.DirSistema + '\arch';
  if not FileExists(dbs.DirSistema + '\arch\upgradeLab.db') then
    datosdb.tranSQL(dbs.DirSistema + '\arch\', 'CREATE TABLE upgradeLab (Version CHAR(15), Actualizado CHAR(1), Fecha CHAR(10), PRIMARY KEY(version))');
  upgradevers := datosdb.openDB('upgradeLab', 'version', '', dir);
end;

//------------------------------------------------------------------------------
procedure TTActualizacionesLaboratorio.Actualizar300000;
// Objetivo...: Cambiar los campos a 6 digitos
var
  t: TTable;
  f: String;
Begin
  if dbs.BaseClientServ = 'N' then Begin
    utiles.msgError('El Sistema Procesara Nuevas Actualizaciones. El Proceso puede tardar Varios Minutos, por favor, Espere.');

    if not DirectoryExists(dbs.DirSistema + '\upgrade\ver300000\work') then utilesarchivos.CrearDirectorio(dbs.DirSistema + '\upgrade\ver300000\work');
    utilesarchivos.CopiarArchivos(dbs.DirSistema + '\upgrade\ver300000', '*.*', dbs.DirSistema + '\upgrade\ver300000\work');

    tabla := datosdb.openDB('solicitud', '');
    t     := datosdb.openDB('solicitud', '', '', dbs.DirSistema + '\upgrade\ver300000\work');
    tabla.Open; t.Open;
    while not tabla.Eof do Begin
      if t.FindKey([tabla.FieldByName('nrosolicitud').AsString]) then t.Edit else t.Append;
      t.FieldByName('nrosolicitud').AsString  := tabla.FieldByName('nrosolicitud').AsString;
      t.FieldByName('protocolo').AsString     := tabla.FieldByName('protocolo').AsString;
      if (Copy(tabla.FieldByName('fecha').AsString, 1, 4) <= '2000') or (Copy(tabla.FieldByName('fecha').AsString, 1, 4) >= '2020') then Begin
        f := '2008' + Copy(tabla.FieldByName('fecha').AsString, 5, 4);
        t.FieldByName('fecha').AsString         := f;
      end else
        t.FieldByName('fecha').AsString         := tabla.FieldByName('fecha').AsString;
      t.FieldByName('hora').AsString          := tabla.FieldByName('hora').AsString;
      t.FieldByName('codpac').AsString        := utiles.sLlenarIzquierda(tabla.FieldByName('codpac').AsString, 6, '0');
      t.FieldByName('codprof').AsString       := tabla.FieldByName('codprof').AsString;
      t.FieldByName('codos').AsString         := tabla.FieldByName('codos').AsString;
      t.FieldByName('observaciones').AsString := tabla.FieldByName('observaciones').AsString;
      t.FieldByName('entorden').AsString      := tabla.FieldByName('entorden').AsString;
      t.FieldByName('abona').AsString         := tabla.FieldByName('abona').AsString;
      t.FieldByName('total').AsFloat          := tabla.FieldByName('total').AsFloat;
      t.FieldByName('entrega').AsFloat        := tabla.FieldByName('entrega').AsFloat;
      //t.FieldByName('retiraent').AsString     := tabla.FieldByName('retiraent').AsString;
      t.FieldByName('retirafecha').AsString   := tabla.FieldByName('retirafecha').AsString;
      t.FieldByName('retirahora').AsString    := tabla.FieldByName('retirahora').AsString;
      t.FieldByName('entidadderiv').AsString  := tabla.FieldByName('entidadderiv').AsString;
      try
        t.Post
       except
        t.Cancel
      end;
      tabla.Next;
    end;
    datosdb.closeDB(tabla); datosdb.closeDB(t);

    tabla := datosdb.openDB('pacobsoc', '');
    t     := datosdb.openDB('pacobsoc', '', '', dbs.DirSistema + '\upgrade\ver300000\work');
    tabla.Open; t.Open;
    while not tabla.Eof do Begin
      if datosdb.Buscar(t, 'codpac', 'codos', utiles.sLlenarIzquierda(tabla.FieldByName('codpac').AsString, 6, '0'), tabla.FieldByName('codos').AsString) then t.Edit else t.Append;
      t.FieldByName('codpac').AsString        := utiles.sLlenarIzquierda(tabla.FieldByName('codpac').AsString, 6, '0');
      t.FieldByName('codos1').AsString        := tabla.FieldByName('codos1').AsString;
      t.FieldByName('codos').AsString         := tabla.FieldByName('codos').AsString;
      try
        t.Post
       except
        t.Cancel
      end;
      tabla.Next;
    end;
    datosdb.closeDB(tabla); datosdb.closeDB(t);

    {tabla := datosdb.openDB('pacobs', '');
    t     := datosdb.openDB('pacobs', '', '', dbs.DirSistema + '\upgrade\ver300000\work');
    tabla.Open; t.Open;
    while not tabla.Eof do Begin
      if datosdb.Buscar(t, 'codpac', 'codos', utiles.sLlenarIzquierda(tabla.FieldByName('codpac').AsString, 6, '0'), tabla.FieldByName('codos').AsString) then t.Edit else t.Append;
      t.FieldByName('codpac').AsString        := utiles.sLlenarIzquierda(tabla.FieldByName('codpac').AsString, 6, '0');
      t.FieldByName('codos1').AsString        := tabla.FieldByName('codos1').AsString;
      t.FieldByName('codos').AsString         := tabla.FieldByName('codos').AsString;
      try
        t.Post
       except
        t.Cancel
      end;
      tabla.Next;
    end;
    datosdb.closeDB(tabla); datosdb.closeDB(t);}

    tabla := datosdb.openDB('pacobsoc', '');
    t     := datosdb.openDB('pacobsoc', '', '', dbs.DirSistema + '\upgrade\ver300000\work');
    tabla.Open; t.Open;
    while not tabla.Eof do Begin
      if datosdb.Buscar(t, 'codpac', 'codos', utiles.sLlenarIzquierda(tabla.FieldByName('codpac').AsString, 6, '0'), tabla.FieldByName('codos').AsString) then t.Edit else t.Append;
      t.FieldByName('codpac').AsString        := utiles.sLlenarIzquierda(tabla.FieldByName('codpac').AsString, 6, '0');
      t.FieldByName('codos1').AsString        := tabla.FieldByName('codos1').AsString;
      t.FieldByName('codos').AsString         := tabla.FieldByName('codos').AsString;
      try
        t.Post
       except
        t.Cancel
      end;
      tabla.Next;
    end;
    datosdb.closeDB(tabla); datosdb.closeDB(t);

    tabla := datosdb.openDB('pacienth', '');
    t     := datosdb.openDB('pacienth', '', '', dbs.DirSistema + '\upgrade\ver300000\work');
    tabla.Open; t.Open;
    while not tabla.Eof do Begin
      if t.FindKey([utiles.sLlenarIzquierda(tabla.FieldByName('codpac').AsString, 6, '0')]) then t.Edit else t.Append;
      t.FieldByName('codpac').AsString   := utiles.sLlenarIzquierda(tabla.FieldByName('codpac').AsString, 6, '0');
      t.FieldByName('fenac').AsString    := tabla.FieldByName('fenac').AsString;
      t.FieldByName('osocial').AsString  := tabla.FieldByName('osocial').AsString;
      t.FieldByName('telefono').AsString := tabla.FieldByName('telefono').AsString;
      t.FieldByName('sexo').AsString     := tabla.FieldByName('sexo').AsString;
      //t.FieldByName('compcel').AsString  := tabla.FieldByName('compcel').AsString;
      //t.FieldByName('email').AsString    := tabla.FieldByName('email').AsString;
      try
        t.Post
       except
        t.Cancel
      end;
      tabla.Next;
    end;
    datosdb.closeDB(tabla); datosdb.closeDB(t);

    tabla := datosdb.openDB('pacientefoto', '');
    t     := datosdb.openDB('pacientefoto', '', '', dbs.DirSistema + '\upgrade\ver300000\work');
    tabla.Open; t.Open;
    while not tabla.Eof do Begin
      if t.FindKey([utiles.sLlenarIzquierda(tabla.FieldByName('codpac').AsString, 6, '0')]) then t.Edit else t.Append;
      t.FieldByName('codpac').AsString   := utiles.sLlenarIzquierda(tabla.FieldByName('codpac').AsString, 6, '0');
      t.FieldByName('foto').Value        := tabla.FieldByName('foto').Value;
      try
        t.Post
       except
        t.Cancel
      end;
      tabla.Next;
    end;
    datosdb.closeDB(tabla); datosdb.closeDB(t);

    tabla := datosdb.openDB('paciente', '');
    t     := datosdb.openDB('paciente', '', '', dbs.DirSistema + '\upgrade\ver300000\work');
    tabla.Open; t.Open;
    while not tabla.Eof do Begin
      if t.FindKey([utiles.sLlenarIzquierda(tabla.FieldByName('codpac').AsString, 6, '0')]) then t.Edit else t.Append;
      t.FieldByName('codpac').AsString := utiles.sLlenarIzquierda(tabla.FieldByName('codpac').AsString, 6, '0');
      t.FieldByName('nombre').AsString := tabla.FieldByName('nombre').AsString;
      t.FieldByName('cp').AsString     := tabla.FieldByName('cp').AsString;
      t.FieldByName('orden').AsString  := tabla.FieldByName('orden').AsString;
      try
        t.Post
       except
        t.Cancel
      end;
      tabla.Next;
    end;
    datosdb.closeDB(tabla); datosdb.closeDB(t);

    tabla := datosdb.openDB('movpagos', '');
    t     := datosdb.openDB('movpagos', '', '', dbs.DirSistema + '\upgrade\ver300000\work');
    tabla.Open; t.Open;
    while not tabla.Eof do Begin
      if datosdb.Buscar(t, 'protocolo', 'items', tabla.FieldByName('protocolo').AsString, tabla.FieldByName('items').AsString) then t.Edit else t.Append;
      t.FieldByName('protocolo').AsString     := tabla.FieldByName('protocolo').AsString;
      t.FieldByName('items').AsString         := tabla.FieldByName('items').AsString;
      if (Copy(tabla.FieldByName('fecha').AsString, 1, 4) <= '2000') or (Copy(tabla.FieldByName('fecha').AsString, 1, 4) >= '2020') then Begin
        f := '2008' + Copy(tabla.FieldByName('fecha').AsString, 5, 4);
        t.FieldByName('fecha').AsString         := f;
      end else
        t.FieldByName('fecha').AsString         := tabla.FieldByName('fecha').AsString;
      t.FieldByName('codpac').AsString        := utiles.sLlenarIzquierda(tabla.FieldByName('codpac').AsString, 6, '0');
      t.FieldByName('concepto').AsString      := tabla.FieldByName('concepto').AsString;
      t.FieldByName('tipomov').AsString       := tabla.FieldByName('tipomov').AsString;
      t.FieldByName('monto').AsFloat          := tabla.FieldByName('monto').AsFloat;
      t.FieldByName('entrega').AsFloat        := tabla.FieldByName('entrega').AsFloat;
      t.FieldByName('saldo').AsFloat          := tabla.FieldByName('saldo').AsFloat;
      t.FieldByName('estado').AsString        := tabla.FieldByName('estado').AsString;
      t.FieldByName('devolucion').AsString    := tabla.FieldByName('devolucion').AsString;
      t.FieldByName('bloqueo').AsString       := tabla.FieldByName('bloqueo').AsString;
      try
        t.Post
       except
        t.Cancel
      end;
      tabla.Next;
    end;
    datosdb.closeDB(tabla); datosdb.closeDB(t);

    tabla := datosdb.openDB('presupuesto', '');
    t     := datosdb.openDB('presupuesto', '', '', dbs.DirSistema + '\upgrade\ver300000\work');
    tabla.Open; t.Open;
    while not tabla.Eof do Begin
      if t.FindKey([tabla.FieldByName('nropres').AsString]) then t.Edit else t.Append;
      t.FieldByName('nropres').AsString  := tabla.FieldByName('nropres').AsString;
      if (Copy(tabla.FieldByName('fecha').AsString, 1, 4) <= '2000') or (Copy(tabla.FieldByName('fecha').AsString, 1, 4) >= '2020') then Begin
        f := '2008' + Copy(tabla.FieldByName('fecha').AsString, 5, 4);
        t.FieldByName('fecha').AsString         := f;
      end else
        t.FieldByName('fecha').AsString         := tabla.FieldByName('fecha').AsString;
      t.FieldByName('hora').AsString          := tabla.FieldByName('hora').AsString;
      t.FieldByName('codpac').AsString        := utiles.sLlenarIzquierda(tabla.FieldByName('codpac').AsString, 6, '0');
      t.FieldByName('codprof').AsString       := tabla.FieldByName('codprof').AsString;
      t.FieldByName('codos1').AsString        := tabla.FieldByName('codos1').AsString;
      t.FieldByName('codos').AsString         := tabla.FieldByName('codos').AsString;
      t.FieldByName('observaciones').AsString := tabla.FieldByName('observaciones').AsString;
      t.FieldByName('entorden').AsString      := tabla.FieldByName('entorden').AsString;
      t.FieldByName('abona').AsString         := tabla.FieldByName('abona').AsString;
      t.FieldByName('total').AsFloat          := tabla.FieldByName('total').AsFloat;
      t.FieldByName('entrega').AsFloat        := tabla.FieldByName('entrega').AsFloat;
      t.FieldByName('retirafecha').AsString   := tabla.FieldByName('retirafecha').AsString;
      try
        t.Post
       except
        t.Cancel
      end;
      tabla.Next;
    end;
    datosdb.closeDB(tabla); datosdb.closeDB(t);

    // Copiamos las Estructuras Corregidas al Directorio de Trabajo
    utilesarchivos.CopiarArchivos(dbs.DirSistema + '\upgrade\ver300000\work', '*.*', dbs.DirSistema + '\arch')
  end;
end;

//------------------------------------------------------------------------------

destructor TTActualizacionesLaboratorio.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function actualizaciones: TTActualizacionesLaboratorio;
begin
  if xactualizaciones = nil then
    xactualizaciones := TTActualizacionesLaboratorio.Create;
  Result := xactualizaciones;
end;

{===============================================================================}

initialization

finalization
  xactualizaciones.Free;

end.
