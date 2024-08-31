unit CExpiracion;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type
 expira = record
   fecha: String[8];
 end;
archivo = file of expira;

TTExpiracion = class
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

//  function    verificarExpiracion(xfecha: String): Boolean;

  private
   { Declaraciones Privadas }
end;

function expiracion: TTExpiracion;

implementation

var
  xexpiracion: TTExpiracion = nil;
  registro: archivo;
  elemento: expira;

constructor TTExpiracion.Create;
begin
  if not FileExists(dbs.DirSistema + '\registrodat.db') then Begin
    AssignFile(registro, dbs.DirSistema + '\registrodat.db');
    Rewrite(registro);
//    elemento.fecha := utiles.setFechaActual
  end;
end;

destructor TTExpiracion.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function expiracion: TTExpiracion;
begin
  if xexpiracion = nil then
    xexpiracion := TTExpiracion.Create;
  Result := xexpiracion;
end;

{===============================================================================}

initialization

finalization
  xexpiracion.Free;

end.
