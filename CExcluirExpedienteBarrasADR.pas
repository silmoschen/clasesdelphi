unit CExcluirExpedienteBarrasADR;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CAdmNumCompr;

type

TTExcluirExpedientes = class
  Ente, Intervalo, CodNum: String;
  excluir, parametros: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    BuscarItems(xitems: String): Boolean;
  procedure   RegistrarItems(xitems, xente, xintervalo, xcodnum: String);
  procedure   BorrarItems(xitems: String);
  procedure   getDatosItems(xitems: String);

  function    BuscarExpediente(xcodprest, xexpediente: String): Boolean;
  procedure   RegistrarExpediente(xcodprest, xexpediente, xestado: String);
  procedure   BorrarExpediente(xcodprest, xexpediente: String);
  function    setExcluye(xcodprest, xexpediente: String): Boolean;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function excluirexpedientes: TTExcluirExpedientes;

implementation

var
  xexcluirexpedientes: TTExcluirExpedientes = nil;

constructor TTExcluirExpedientes.Create;
begin
  excluir    := datosdb.openDB('exlcuirexptes_barras', '');
  parametros := datosdb.openDB('parametros_barras', '');
end;

destructor TTExcluirExpedientes.Destroy;
begin
  inherited Destroy;
end;

function  TTExcluirExpedientes.BuscarItems(xitems: String): Boolean;
// Objetivo...: recuperar instancia
begin
  Result := parametros.FindKey([xitems]);
end;

procedure TTExcluirExpedientes.RegistrarItems(xitems, xente, xintervalo, xcodnum: String);
// Objetivo...: registrar instancia
begin
  if BuscarItems(xitems) then parametros.Edit else parametros.Append;
  parametros.FieldByName('items').AsString     := xitems;
  parametros.FieldByName('ente').AsString      := xente;
  parametros.FieldByName('intervalo').AsString := xintervalo;
  parametros.FieldByName('codnum').AsString    := xcodnum;
  try
    parametros.Post
   except
    parametros.Cancel
  end;
  datosdb.refrescar(parametros);
end;

procedure TTExcluirExpedientes.BorrarItems(xitems: String);
// Objetivo...: borrar instancia
begin
  if BuscarItems(xitems) then parametros.Delete;
  datosdb.refrescar(parametros);
end;

procedure TTExcluirExpedientes.getDatosItems(xitems: String);
// Objetivo...: cargar instancia
begin
  if BuscarItems(xitems) then Begin
    ente      := parametros.FieldByName('ente').AsString;
    intervalo := parametros.FieldByName('intervalo').AsString;
    codnum    := parametros.FieldByName('codnum').AsString;
  end else Begin
    ente := ''; intervalo := ''; codnum := '';
  end;
end;

function  TTExcluirExpedientes.BuscarExpediente(xcodprest, xexpediente: String): Boolean;
// Objetivo...: buscar instancia
begin
  Result := datosdb.Buscar(excluir, 'codprest', 'expediente', xcodprest, xexpediente);
end;

procedure TTExcluirExpedientes.RegistrarExpediente(xcodprest, xexpediente, xestado: String);
// Objetivo...: recuperar instancia
begin
  if xestado = 'S' then Begin
    if BuscarExpediente(xcodprest, xexpediente) then excluir.Edit else excluir.Append;
    excluir.FieldByName('codprest').AsString   := xcodprest;
    excluir.FieldByName('expediente').AsString := xexpediente;
    try
      excluir.Post
     except
      excluir.Cancel
    end;
    datosdb.refrescar(excluir);
  end else
    BorrarExpediente(xcodprest, xexpediente);
end;

procedure TTExcluirExpedientes.BorrarExpediente(xcodprest, xexpediente: String);
// Objetivo...: recuperar instancia
begin
  if BuscarExpediente(xcodprest, xexpediente) then Begin
    excluir.Delete;
    datosdb.refrescar(excluir);
  end;
end;

function  TTExcluirExpedientes.setExcluye(xcodprest, xexpediente: String): Boolean;
// Objetivo...: recuperar instancia
begin
  Result := BuscarExpediente(xcodprest, xexpediente);
end;

procedure TTExcluirExpedientes.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not excluir.Active then excluir.Open;
    if not parametros.Active then parametros.Open;
  end;
  Inc(conexiones);
  administNum.conectar;
end;

procedure TTExcluirExpedientes.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(excluir);
    datosdb.closeDB(parametros);
  end;
  administNum.desconectar;
end;

{===============================================================================}

function excluirexpedientes: TTExcluirExpedientes;
begin
  if xexcluirexpedientes = nil then
    xexcluirexpedientes := TTExcluirExpedientes.Create;
  Result := xexcluirexpedientes;
end;

{===============================================================================}

initialization

finalization
  xexcluirexpedientes.Free;

end.
