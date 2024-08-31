unit CCBandejaSalida;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CListar, CUtiles;

type

TTBandeja = class(TObject)
  Para, Asunto, CC, CCO, Mensaje, Attach, Estado: String;
  mensajes: TTable;
 public
  { Public Declarations }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xidmensaje: String): Boolean;
  procedure   Registar(xpara, xasunto, xcc, xcco, xmensaje, xattach: String);
  procedure   Borrar(xidmensaje: String);
  procedure   getDatos(xidmensaje: String);

  function    setMensajesPendientesDeEnvio: TQuery;
  procedure   MarcarMensajeEnviado(xidmensaje: String);
  function    verificarSiExistenMensajesPendientesDeEnvio: Integer;

  procedure   conectar;
  procedure   desconectar;
 protected
  { Protected Declarations }
 private
  { Private Declarations }
  conexiones: Integer;
  DBConexion: String;
end;

function bandeja: TTBandeja;

implementation

var
  xbandeja: TTBandeja = nil;

constructor TTBandeja.Create;
begin
  inherited Create;
  if dbs.BaseClientServ = 'S' then DBConexion := dbs.baseDat else DBConexion := dbs.DirSistema + '\arch';
  mensajes := datosdb.openDB('bandejasal', '', '', DBConexion);
end;

destructor TTBandeja.Destroy;
begin
  inherited Destroy;
end;

function  TTBandeja.Buscar(xidmensaje: String): Boolean;
// Objetivo...: Buscar Mensaje
Begin
 Result := mensajes.FindKey([xidmensaje]);
end;

procedure TTBandeja.Registar(xpara, xasunto, xcc, xcco, xmensaje, xattach: String);
// Objetivo...: Registrar un Mensaje
var
  nm: String;
Begin
  nm := utiles.sExprFecha(utiles.setFechaActual) + utiles.setHoraActual24;
  if Buscar(nm) then mensajes.Edit else mensajes.Append;
  mensajes.FieldByName('idmensaje').AsString := nm;
  mensajes.FieldByName('para').AsString      := xpara;
  mensajes.FieldByName('asunto').AsString    := xasunto;
  mensajes.FieldByName('cc').AsString        := xcc;
  mensajes.FieldByName('cco').AsString       := xcco;
  mensajes.FieldByName('mensaje').AsString   := xmensaje;
  mensajes.FieldByName('attach').AsString    := xattach;
  mensajes.FieldByName('estado').AsString    := 'P';
  try
    mensajes.Post
   except
    mensajes.Cancel
  end;
end;

procedure TTBandeja.Borrar(xidmensaje: String);
// Ojetivo...: Eliminar un Mensaje
Begin
  if Buscar(xidmensaje) then mensajes.Delete;
end;

procedure TTBandeja.getDatos(xidmensaje: String);
// Objetivo...: Recuperar los datos del un Mensaje
Begin
  if Buscar(xidmensaje) then Begin
    asunto  := mensajes.FieldByName('asunto').AsString;
    cc      := mensajes.FieldByName('cc').AsString;
    cco     := mensajes.FieldByName('cco').AsString;
    mensaje := mensajes.FieldByName('mensaje').AsString;
    attach  := mensajes.FieldByName('attach').AsString;
    estado  := mensajes.FieldByName('estado').AsString;
  end else Begin
    asunto := ''; cc := ''; cco := ''; mensaje := ''; attach := ''; estado := '';
  end;
end;

procedure TTBandeja.MarcarMensajeEnviado(xidmensaje: String);
// Objetivo...: Marcar Mensaje como enviado
Begin
  if Buscar(xidmensaje) then Begin
    mensajes.Edit;
    mensajes.FieldByName('estado').AsString := 'D';
    try
      mensajes.Post
     except
      mensajes.Cancel
    end;
  end;
end;

function  TTBandeja.verificarSiExistenMensajesPendientesDeEnvio: Integer;
// Objetivo...: Enviar Mensaje
var
  r: TQuery;
Begin
  r := setMensajesPendientesDeEnvio;
  r.Open;
  Result := r.RecordCount;
  r.Close; r.Free;
end;

function  TTBandeja.setMensajesPendientesDeEnvio: TQuery;
// Objetivo...: Enviar Lista de Mensajes Pendientes de Envio
Begin
  Result := datosdb.tranSQL(DBConexion, 'SELECT * FROM ' + mensajes.TableName + ' WHERE estado = ' + '"' + 'P' + '"');
end;

procedure TTBandeja.conectar;
// Objetivo...: Conectar tablas de persistencia
Begin
  if conexiones = 0 then
    if not mensajes.Active then mensajes.Open;
  Inc(conexiones);
end;

procedure TTBandeja.desconectar;
// Objetivo...: desconectar tablas de persistencia
Begin
  Dec(conexiones);
  if conexiones = 0 then
    if mensajes.Active then mensajes.Close;
end;

{===============================================================================}

function bandeja: TTBandeja;
begin
  if xbandeja = nil then
    xbandeja := TTBandeja.Create;
  Result := xbandeja;
end;

{===============================================================================}

initialization

finalization
  xbandeja.Free;

end.
