unit CActualizacionesISP4;

interface

uses CActualizaciones, CBDT, SysUtils, DB, DBTables, CIDBFM, CUtiles, Classes, CUtilidadesArchivos;

type

TTActualizacionesEscuelaFoot = class(TTActualizaciones)
  upgrade: TTable;
  ReiniciarAplicacion: Boolean;
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
var
  tabla: TTable;
begin
  if xversion = '1.00.05' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteCampo('inscriptos', 'abona', dbs.baseDat) then Begin
        datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE inscriptos ADD abona varchar(1)');
      end;
      GuardarRevision(xversion);
    end;
  end;

  if xversion = '1.00.020' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteTabla('desestimaciones') then Begin
        datosdb.tranSQL(dbs.baseDat, 'CREATE TABLE desestimaciones (periodo varchar(4) not null, nrodoc varchar(10) not null, idcarrera varchar(3) not null, idmateria varchar(3) not null, motivo varchar(80), primary key(periodo, nrodoc, idcarrera, idmateria))');
        ReiniciarAplicacion := True;
      end;
      if not datosdb.verificarSiExisteTabla('topesescalafon') then Begin
        datosdb.tranSQL(dbs.baseDat, 'CREATE TABLE topesescalafon (periodo varchar(4) not null, fecha varchar(8) not null, primary key(periodo))');
        ReiniciarAplicacion := True;
      end;
      if not datosdb.verificarSiExisteTabla('periodoescalafon') then Begin
        datosdb.tranSQL(dbs.baseDat, 'CREATE TABLE periodoescalafon (periodo varchar(4) not null, estado varchar(1), primary key(periodo))');
        ReiniciarAplicacion := True;
      end;
      if not datosdb.verificarSiExisteCampo('escalafon', 'requerido', dbs.baseDat) then Begin
        datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE escalafon ADD requerido varchar(1)');
        ReiniciarAplicacion := True;
      end;
      if not datosdb.verificarSiExisteTabla('escalafonalter') then Begin
        datosdb.tranSQL(dbs.baseDat, 'CREATE TABLE escalafonalter (periodo varchar(4) not null, nrodoc varchar(10) not null, idcarrera varchar(3) not null, primary key(periodo, nrodoc, idcarrera))');
        ReiniciarAplicacion := True;
      end;
      GuardarRevision(xversion);
    end;
  end;

  if xversion = '1.00.050' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteCampo('escalafon', 'abreviatura', dbs.baseDat) then Begin
        datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE escalafon ADD abreviatura varchar(6)');
        ReiniciarAplicacion := True;
      end;
      if not datosdb.verificarSiExisteCampo('itemsescalafon', 'agrupa', dbs.baseDat) then Begin
        datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE itemsescalafon ADD agrupa varchar(1)');
        ReiniciarAplicacion := True;
      end else Begin
        tabla := datosdb.openDB('itemsescalafon', '', '', dbs.baseDat);
        tabla.Open;
        while not tabla.Eof do Begin
          if Length(Trim(tabla.FieldByName('agrupa').AsString)) = 0 then Begin
            tabla.Edit;
            tabla.FieldByName('agrupa').AsString := 'N';
            try
              tabla.Post
             except
              tabla.Cancel
            end;
          end;
          tabla.Next
        end;
        datosdb.closeDB(tabla);
        GuardarRevision(xversion);
      end;
    end;
  end;

  if xversion = '1.00.070' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteCampo('itemsescalafon', 'disantiguedad', dbs.baseDat) then Begin
        datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE itemsescalafon ADD disantiguedad varchar(1)');
      end;
      if not datosdb.verificarSiExisteTabla('antiguedad_doc') then Begin
        datosdb.tranSQL(dbs.baseDat, 'CREATE TABLE antiguedad_doc (nrodoc varchar(10) not null, idcarrera varchar(3) not null, idmateria varchar(3) not null, desde varchar(8) not null, hasta varchar(8) not null, primary key(nrodoc, idcarrera, idmateria, desde))');
        ReiniciarAplicacion := True;
      end;
      GuardarRevision(xversion);
    end;
  end;

  if xversion = '1.00.080' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteIndice('antiguedad_doc', 'antiguedad_mov', dbs.baseDat) then
        datosdb.tranSQL(dbs.baseDat, 'CREATE INDEX antiguedad_mov ON antiguedad_doc(Nrodoc, Idcarrera, Idmateria)');
      GuardarRevision(xversion);
    end;
  end;

  if xversion = '1.00.085' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteCampo('escalafon', 'orden', dbs.baseDat) then Begin
        datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE escalafon ADD orden varchar(3)');
      end;
      ReiniciarAplicacion := True;
      GuardarRevision(xversion);
    end;
  end;

  if xversion = '1.00.086' then Begin
     if not ActualizacionRealizada(xversion) then Begin
       if datosdb.verificarSiExisteCampo('escalafon', 'orden', dbs.baseDat) then Begin
       if not datosdb.verificarSiExisteIndice('escalafon', 'escalafon_orden', dbs.baseDat) then
         datosdb.tranSQL(dbs.baseDat, 'CREATE INDEX escalafon_orden ON escalafon(Orden)');

         tabla := datosdb.openDB('escalafon', '');
         tabla.Open;
         while not tabla.Eof do Begin
           if tabla.FieldByName('orden').AsString = '' then Begin
             tabla.Edit;
             tabla.FieldByName('orden').AsString := tabla.FieldByName('items').AsString;
             try
               tabla.Post
              except
               tabla.Cancel
             end;
           end;
           tabla.Next;
         end;
        datosdb.closeDB(tabla);
       end;
       GuardarRevision(xversion);
     end;
   end;

   if xversion = '1.00.090' then Begin
     if not FileExists(dbs.DirSistema + '\exportar\escalafon\estructu\antiguedad_doc.db') then Begin
       datosdb.tranSQL(dbs.DirSistema + '\exportar\escalafon\estructu', 'CREATE TABLE antiguedad_doc (nrodoc char(10), idcarrera char(3), idmateria char(3), desde char(8), hasta char(8), primary key(nrodoc, idcarrera, idmateria, desde))');
       GuardarRevision(xversion);
     end;
   end;

   if xversion = '1.00.095' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteCampo('carreras', 'matcom', dbs.baseDat) then Begin
        datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE carreras ADD matcom varchar(1)');
      end;
      if not datosdb.verificarSiExisteTabla('excluiresc') then Begin
        datosdb.tranSQL(dbs.baseDat, 'CREATE TABLE excluiresc (periodo varchar(8) not null, nrodoc varchar(10) not null, idmateria varchar(3) not null, idcarrera varchar(3) not null, idcarreraex varchar(3) not null, primary key(periodo, nrodoc, idmateria, idcarrera, idcarreraex))');
      end;

      ReiniciarAplicacion := True;
      GuardarRevision(xversion);
    end;
   end;

   if xversion = '1.00.097' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteIndice('excluiresc', 'excluiresc_id', dbs.baseDat) then
        datosdb.tranSQL(dbs.baseDat, 'CREATE INDEX excluiresc_id ON excluiresc(periodo, nrodoc, idmateria, idcarrera)');
      GuardarRevision(xversion);
    end;
   end;

   if xversion = '2.00.000' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteCampo('inscripciondocente', 'estado', dbs.baseDat) then Begin
        datosdb.tranSQL(dbs.baseDat, 'ALTER TABLE inscripciondocente ADD estado varchar(1)');
      end;
      ReiniciarAplicacion := True;
      GuardarRevision(xversion);
    end;
   end;

   if xversion = '2.00.001' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      datosdb.tranSQL(dbs.baseDat, 'UPDATE inscripciondocente SET estado = ' + '''' + 'I' + '''');
      GuardarRevision(xversion);
    end;
   end;

   if xversion = '2.00.005' then Begin
    if not ActualizacionRealizada(xversion) then Begin
      if not datosdb.verificarSiExisteTabla('bloqueos_es') then Begin
        datosdb.tranSQL(dbs.baseDat, 'CREATE TABLE bloqueos_es (nrodoc varchar(10) not null, tipo varchar(3) not null, usuario varchar(20) not null, tarea varchar(50), primary key(nrodoc, tipo))');
        ReiniciarAplicacion := True;
      end;
      GuardarRevision(xversion);
    end;
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
