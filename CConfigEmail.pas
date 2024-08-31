unit CConfigEmail;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CIDBFM;

type

TTEMail = class
  EMailLocal, SMTP: String;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Configurar(xemaillocal, xsmtp: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function configEmail: TTEMail;

implementation

var
  xconfigEmail: TTEMail = nil;

constructor TTEMail.Create;
begin
  tabla := datosdb.openDB('configEmail', '', '', dbs.DirSistema);
  conectar;
  if tabla.recordCount > 0 then Begin
    tabla.First;
    EMailLocal := tabla.FieldByName('email').AsString;
    SMTP       := tabla.FieldByName('smtp').AsString;
  end;
  desconectar;
end;

destructor TTEMail.Destroy;
begin
  inherited Destroy;
end;

procedure  TTEMail.Configurar(xemaillocal, xsmtp: String);
// Objetivo...: Configurar EMail
Begin
  tabla := datosdb.openDB('configEmail', '', '', dbs.DirSistema);
  conectar;
  if tabla.RecordCount = 0 then tabla.Append else tabla.Edit;
  tabla.FieldByName('email').AsString := xemaillocal;
  tabla.FieldByName('smtp').AsString  := xsmtp;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  tabla.First;
  EMailLocal := tabla.FieldByName('email').AsString;
  SMTP       := tabla.FieldByName('smtp').AsString;
  desconectar;
end;

procedure TTEMail.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    tabla.Open;
  end;
  Inc(conexiones);
end;

procedure TTEMail.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla); 
  end;
end;

{===============================================================================}

function configEmail: TTEMail;
begin
  if xconfigEmail = nil then
    xconfigEmail := TTEMail.Create;
  Result := xconfigEmail;
end;

{===============================================================================}

initialization

finalization
  xconfigEmail.Free;

end.
