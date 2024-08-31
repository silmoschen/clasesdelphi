unit CCorreoSaliente;

interface

uses CBDT, SysUtils, DB, DBTables, CUtiles, CIDBFM;

type

TTCorreoSaliente = class(TObject)
  fechahora, para, cc, bcc, asunto, estado, ctaenvio, mensaje: string;       // Atributos para manejar mensajes
  cuenta, host, usuario, LocalUsuario, LocalMail: string; // Atributos para manejar Cuentas SMTP
  puerto, tipoCta: shortint;
  tabla, attach, ctasSMTP: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xfechahora: string): boolean;
  function    BuscarCuentaSMTP(xcuenta: string): boolean;
  procedure   Grabar(xfechahora, xpara, xcc, xbcc, xasunto, xctaenvio, xmensaje: string);
  procedure   GrabarAttach(xattach: string);
  procedure   GuardarCuentaSMTP(xcuenta, xhost, xusuario, xLocalUsuario, xLocalMail: string; xpuerto, xTipoCta: shortint);
  procedure   Borrar(xfechahora: string);
  procedure   BorrarCuentaSMTP(xcuenta: string);
  procedure   getDatos(xfechahora: string);
  procedure   getDatosCuentaSMTP(xcuenta: string);
  function    setMensajesPendientes: TQuery;
  function    setAttach: TQuery;
  function    setCuentasSMTP: TQuery;
  procedure   MarcarMensajeEnviado;
  function    verificarMensajesAEnviar: boolean;
  function    getCantMensPendientes: integer;
  function    setMensajes: TQuery;

  procedure   Editar;
  procedure   Guardar;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  flags: boolean;
end;

function mailsaliente: TTCorreoSaliente;

implementation

var
  xmailsaliente: TTCorreoSaliente = nil;

constructor TTCorreoSaliente.Create;
begin
  inherited Create;
  tabla   := datosdb.openDB('mailsaliente', 'fechahora');
  attach  := datosdb.openDB('attach', 'fechahora');
  ctasSMTP := datosdb.openDB('cuentasSMTP', 'cuenta');
end;

destructor TTCorreoSaliente.Destroy;
begin
  inherited Destroy;
end;

function  TTCorreoSaliente.Buscar(xfechahora: string): boolean;
// Objetivo...: Buscar una instancia
begin
  if tabla.FindKey([xfechahora]) then Result := True else Result := False;
end;

procedure TTCorreoSaliente.Grabar(xfechahora, xpara, xcc, xbcc, xasunto, xctaenvio, xmensaje: string);
// Objetivo...: Almacenar una instacia de la clase
begin
  if Buscar(xfechahora) then tabla.Edit else tabla.Append;
  tabla.FieldByName('fechahora').AsString := xfechahora;
  tabla.FieldByName('para').AsString      := xpara;
  tabla.FieldByName('cc').AsString        := xcc;
  tabla.FieldByName('bcc').AsString       := xbcc;
  tabla.FieldByName('asunto').AsString    := xasunto;
  tabla.FieldByName('ctaenvio').AsString  := xctaenvio;
  tabla.FieldByName('mensaje').AsString   := xmensaje;
  tabla.FieldByName('estado').AsString    := 'P';
  try
    tabla.Post
  except
    tabla.Cancel
  end;
  fechahora := xfechahora;
  if flags then datosdb.tranSQL('DELETE FROM ' + attach.TableName + ' WHERE fechahora = ' + '"' + xfechahora + '"');
  flags := True;
end;

procedure TTCorreoSaliente.Borrar(xfechahora: string);
// Objetivo...: Eliminar una instancia
begin
  if Buscar(xfechahora) then
    begin
      tabla.Delete;
      datosdb.tranSQL('DELETE FROM ' + attach.TableName + ' WHERE fechahora = ' + '"' + xfechahora + '"');
      getDatos(tabla.FieldByName('fechahora').AsString);
    end;
end;

procedure TTCorreoSaliente.getDatos(xfechahora: string);
// Objetivo...: Cargar/iniciar los atributos para una instancia
begin
  tabla.Refresh;
  if Buscar(xfechahora) then
    begin
      fechahora := tabla.FieldByName('fechahora').AsString;
      para      := tabla.FieldByName('para').AsString;
      cc        := tabla.FieldByName('cc').AsString;
      bcc       := tabla.FieldByName('bcc').AsString;
      asunto    := tabla.FieldByName('asunto').AsString;
      estado    := tabla.FieldByName('estado').AsString;
      ctaenvio  := tabla.FieldByName('ctaenvio').AsString;
      mensaje   := tabla.FieldByName('mensaje').AsString;
    end
  else
    begin
      fechahora := ''; para := ''; cc := ''; bcc := ''; asunto := ''; estado := ''; ctaenvio := ''; mensaje := '';
    end;
end;

function TTCorreoSaliente.setMensajesPendientes: TQuery;
// Objetivo...: devolver un set con los mensajes pendientes
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' WHERE estado = ' + '"' + 'P' + '"');
end;

function TTCorreoSaliente.setMensajes: TQuery;
// Objetivo...: devolver un set con los mensajes pendientes
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName);
end;

function TTCorreoSaliente.setAttach: TQuery;
// Objetivo...: devolver un set con los archivos adjuntos del mensaje actual
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + attach.TableName + ' WHERE fechahora = ' + '"' + fechahora + '"');
end;

procedure TTCorreoSaliente.MarcarMensajeEnviado;
// Objetivo...: Marcar un mensaje que ya fue enviado
begin
  if Buscar(fechahora) then Begin
    tabla.Edit;
    tabla.FieldByName('estado').AsString := 'E';
    try
      tabla.Post
    except
      tabla.Cancel
    end;
  end;
end;

procedure TTCorreoSaliente.GrabarAttach(xattach: string);
// Objetivo...: Guardar attach (lista de archivos adjuntos)
begin
  if datosdb.Buscar(attach, 'fechahora', 'attach', fechahora, xattach) then attach.Edit else attach.Append;
  attach.FieldByName('fechahora').AsString := fechahora;
  attach.FieldByName('attach').AsString    := xattach;
  try
    attach.Post
  except
    attach.Cancel
  end;
  flags := False;
end;

function TTCorreoSaliente.verificarMensajesAEnviar: boolean;
// Objetivo...: verificar si existen mensajes por enviar
begin
  Result := False;
  if tabla.Active then Begin
    tabla.First;
    while not tabla.EOF do Begin
      if tabla.FieldByName('estado').AsString = 'P' then Begin
        Result := True;
        Break;
      end;
      tabla.Next;
    end;
  end;
end;

procedure TTCorreoSaliente.Editar;
// Objetivo...: cerrar tablas de persistencia
begin
  tabla.Edit;
end;

function TTCorreoSaliente.getCantMensPendientes: integer;
// Objetivo...: Informar la cantidad de mensajes pendientes de envio
var
  i: integer;
begin
  tabla.First; i := 0;
  while not tabla.EOF do Begin
    if tabla.FieldByName('estado').AsString = 'P' then Inc(i);
    tabla.Next;
  end;
  Result := i;
end;

procedure TTCorreoSaliente.Guardar;
// Objetivo...: cerrar tablas de persistencia
begin
  try
    tabla.Post
  except
    tabla.Cancel
  end;
end;

{********** Definición de cuenras SMTP ****************}

function  TTCorreoSaliente.BuscarCuentaSMTP(xcuenta: string): boolean;
// Objetivo...: Buscar una instancia
begin
  if ctasSMTP.FindKey([xcuenta]) then Result := True else Result := False;
end;

procedure TTCorreoSaliente.GuardarCuentaSMTP(xcuenta, xhost, xusuario, xLocalUsuario, xLocalMail: string; xpuerto, xTipoCta: shortint);
// Objetivo...: Almacenar una instacia de la clase
begin
  if BuscarCuentaSMTP(xcuenta) then ctasSMTP.Edit else ctasSMTP.Append;
  ctasSMTP.FieldByName('cuenta').AsString       := xcuenta;
  ctasSMTP.FieldByName('host').AsString         := xhost;
  ctasSMTP.FieldByName('usuario').AsString      := xusuario;
  ctasSMTP.FieldByName('LocalUsuario').AsString := xLocalUsuario;
  ctasSMTP.FieldByName('LocalMail').AsString    := xLocalMail;
  ctasSMTP.FieldByName('puerto').AsInteger      := xPuerto;
  ctasSMTP.FieldByName('tipoCta').AsInteger     := xTipoCta;
  try
    ctasSMTP.Post
  except
    ctasSMTP.Cancel
  end;
end;

procedure TTCorreoSaliente.BorrarCuentaSMTP(xcuenta: string);
// Objetivo...: Eliminar una instancia
begin
  if BuscarCuentaSMTP(xcuenta) then
    begin
      ctasSMTP.Delete;
      getDatosCuentaSMTP(ctasSMTP.FieldByName('cuenta').AsString);
    end;
end;

procedure TTCorreoSaliente.getDatosCuentaSMTP(xcuenta: string);
// Objetivo...: Cargar/iniciar los atributos para una instancia
begin
  ctasSMTP.Refresh;
  if BuscarCuentaSMTP(xcuenta) then
    begin
      cuenta       := ctasSMTP.FieldByName('cuenta').AsString;
      host         := ctasSMTP.FieldByName('host').AsString;
      usuario      := ctasSMTP.FieldByName('usuario').AsString;
      LocalMail    := ctasSMTP.FieldByName('localmail').AsString;
      LocalUsuario := ctasSMTP.FieldByName('LocalUsuario').AsString;
      puerto       := ctasSMTP.FieldByName('puerto').AsInteger;
      tipocta      := ctasSMTP.FieldByName('tipocta').AsInteger;
    end
  else
    begin
      cuenta := ''; host := ''; usuario := ''; LocalMail := ''; LocalUsuario := ''; puerto := 25; tipocta := 0;
    end;
end;

function TTCorreoSaliente.setCuentasSMTP: TQuery;
// Objetivo...: devolver un set con las cuentas definidas
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + ctasSMTP.TableName);
end;

procedure TTCorreoSaliente.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    if not attach.Active then attach.Open;
    if not ctasSMTP.Active then ctasSMTP.Open;
  end;
  Inc(conexiones);
end;

procedure TTCorreoSaliente.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(attach);
    datosdb.closeDB(ctasSMTP);
  end;
end;

{===============================================================================}

function mailsaliente: TTCorreoSaliente;
begin
  if xmailsaliente = nil then
    xmailsaliente := TTCorreoSaliente.Create;
  Result := xmailsaliente;
end;

{===============================================================================}

initialization

finalization
  xmailsaliente.Free;

end.
