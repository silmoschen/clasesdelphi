unit CAsociarComprobante;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTAsociarComprobante = class
  Id, Idc, Tipo, CodNum: String;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xid: String): Boolean;
  procedure   Registrar(xid, xidc, xtipo, xcodnum: String);
  procedure   Borrar(xid: String);
  procedure   getDatos(xid: String);

  function    verificarCodigo(xcodnum: String): Boolean;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  tabla: TTable;
end;

function asociarcompr: TTAsociarComprobante;

implementation

var
  xasociarcompr: TTAsociarComprobante = nil;

constructor TTAsociarComprobante.Create;
begin
  tabla := datosdb.openDB('asociarcompr', '');
end;

destructor TTAsociarComprobante.Destroy;
begin
  inherited Destroy;
end;

function TTAsociarComprobante.Buscar(xid: String): Boolean;
// Objetivo...: recuperar una instancia
begin
  Result := tabla.FindKey([xid]);
end;

procedure TTAsociarComprobante.Registrar(xid, xidc, xtipo, xcodnum: String);
// Objetivo...: registrar una instancia
begin
  if Buscar(xid) then tabla.Edit else tabla.Append;
  tabla.FieldByName('id').AsString     := xid;
  tabla.FieldByName('idc').AsString    := xidc;
  tabla.FieldByName('tipo').AsString   := xtipo;
  tabla.FieldByName('codnum').AsString := xcodnum;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
  datosdb.refrescar(tabla);
end;

procedure TTAsociarComprobante.Borrar(xid: String);
// Objetivo...: borrar una instancia
begin
  if Buscar(xid) then Begin
    tabla.Delete;
    datosdb.refrescar(tabla);
  end;
end;

procedure TTAsociarComprobante.getDatos(xid: String);
// Objetivo...: recuperar una instancia
begin
  if Buscar(xid) then Begin
    id     := tabla.FieldByName('id').AsString;
    idc    := tabla.FieldByName('idc').AsString;
    tipo   := tabla.FieldByName('tipo').AsString;
    codnum := tabla.FieldByName('codnum').AsString;
  end else Begin
    id := ''; idc := ''; tipo := ''; codnum := '';
  End;
end;

function TTAsociarComprobante.verificarCodigo(xcodnum: String): Boolean;
// Objetivo...: recuperar una instancia
begin
  tabla.IndexFieldNames := 'codnum';
  if Buscar(xcodnum) then Begin
    id     := tabla.FieldByName('id').AsString;
    idc    := tabla.FieldByName('idc').AsString;
    tipo   := tabla.FieldByName('tipo').AsString;
    codnum := tabla.FieldByName('codnum').AsString;
    result := True;
  end else Begin
    id := ''; idc := ''; tipo := ''; codnum := '';
    result := False;
  End;
  tabla.IndexFieldNames := 'id';
end;

procedure TTAsociarComprobante.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
end;

procedure TTAsociarComprobante.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function asociarcompr: TTAsociarComprobante;
begin
  if xasociarcompr = nil then
    xasociarcompr := TTAsociarComprobante.Create;
  Result := xasociarcompr;
end;

{===============================================================================}

initialization

finalization
  xasociarcompr.Free;

end.
