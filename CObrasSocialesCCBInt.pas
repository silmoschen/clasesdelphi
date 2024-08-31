unit CObrasSocialesCCBInt;

interface

uses SysUtils, DB, DBTables, CIDBFM, CListar, CUtiles, CNomeclaCCB, CUsuario,
     CBDT, Classes, Forms, CUtilidadesArchivos, CNBU, CObrasSocialesCCB;

type

TTObraSocialInt = class(TTObraSocial)            // Superclase
 public
  { Declaraciones Públicas }
  constructor Create; override;
  destructor  Destroy; override;

 private
  { Declaraciones Privadas }
end;

function obsocial: TTObraSocialInt;

implementation

var
  xobsocial: TTObraSocialInt = nil;

constructor TTObraSocialInt.Create;
begin
  //inherited create;

  if dbs.TDB <> Nil then Begin  // Prevención para los servicios CGI
    if dbs.BaseClientServ = 'N' then DBConexion := dbs.DirSistema + '\archdat' else DBConexion := dbs.TDB1.DatabaseName;
    if dbs.BaseClientServ = 'S' then Begin
      tabla        := datosdb.openDB('obsocial', 'Codos', '', '', dbconexion);
      apfijos      := datosdb.openDB('apfijos', '', '', dbconexion);
      aranceles    := datosdb.openDB('obsociales_aranceles', '', '', dbconexion);
      retiva       := datosdb.openDB('obsocial_posiva', '', '', dbconexion);
      apfijosNBU   := datosdb.openDB('apfijosNBU', '', '', dbconexion);
      arancelesNBU := datosdb.openDB('arancelesNBU', '', '', dbconexion);
      arannbu      := datosdb.openDB('arannbu', '', '', dbconexion);
    end else Begin
      if Length(Trim(dbs.baseDat)) > 0 then Begin
        tabla        := datosdb.openDB('obsocial', 'Codos', '', dbs.baseDat);
        apfijos      := datosdb.openDB('apfijos', '', '', dbs.baseDat);
        aranceles    := datosdb.openDB('obsociales_aranceles', '', '', dbs.baseDat);
        retiva       := datosdb.openDB('obsocial_posiva', '', '', dbs.DirSistema + '\archdat');
        apfijosNBU   := datosdb.openDB('apfijosNBU', '', '', dbs.baseDat);
        arancelesNBU := datosdb.openDB('arancelesNBU', '', '', dbs.baseDat); 
        arannbu      := datosdb.openDB('arannbu', '', '', dbs.baseDat);
      end;
    end;
  end;
end;

destructor TTObraSocialInt.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function obsocial: TTObraSocialInt;
begin
  if xobsocial = nil then
    xobsocial := TTObraSocialInt.Create;
  Result := xobsocial;
end;

{===============================================================================}

initialization

finalization
  xobsocial.Free;

end.
