unit CTarjetasCredito_Gross;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTarjeta = class
  Id, Tarjeta: String;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xid: String): Boolean;
  procedure   Registrar(xid, xtarjeta: String);
  procedure   Borrar(xid: String);
  procedure   getDatos(xid: String);
  function    Nueva: String;

  procedure   BuscarPorId(xexpr: String);
  procedure   BuscarPorDescrip(xexpr: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function tarjeta: TTarjeta;

implementation

var
  xtarjeta: TTarjeta = nil;

constructor TTarjeta.Create;
begin
  tabla := datosdb.openDB('tarjetas', '', '');
end;

destructor TTarjeta.Destroy;
begin
  inherited Destroy;
end;

function  TTarjeta.Buscar(xid: String): Boolean;
Begin
  if tabla.IndexFieldNames <> 'Id' then tabla.IndexFieldNames := 'Id';
  Result := tabla.FindKey([xid]);
end;

procedure TTarjeta.Registrar(xid, xtarjeta: String);
Begin
  if Buscar(xid) then tabla.Edit else tabla.Append;
  tabla.FieldByName('id').AsString      := xid;
  tabla.FieldByName('tarjeta').AsString := xtarjeta;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.refrescar(tabla);
end;

procedure TTarjeta.Borrar(xid: String);
Begin
  if Buscar(xid) then tabla.Delete;
end;

procedure TTarjeta.getDatos(xid: String);
Begin
  if Buscar(xid) then Begin
    Id      := tabla.FieldByName('id').AsString;
    Tarjeta := tabla.FieldByName('tarjeta').AsString;
  end else Begin
    Id := ''; Tarjeta := '';
  end;
end;

function  TTarjeta.Nueva: String;
Begin
  if tabla.IndexFieldNames <> 'Id' then tabla.IndexFieldNames := 'Id';
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '001' else Result := utiles.sLlenarIzquierda(IntToStr(tabla.FieldByName('id').AsInteger + 1), 3, '0');
end;

procedure TTarjeta.BuscarPorId(xexpr: String);
Begin
  if tabla.IndexFieldNames <> 'Id' then tabla.IndexFieldNames := 'Id';
  tabla.FindNearest([xexpr]);
end;

procedure TTarjeta.BuscarPorDescrip(xexpr: String);
Begin
  if tabla.IndexFieldNames <> 'Tarjeta' then tabla.IndexFieldNames := 'Tarjeta';
  tabla.FindNearest([xexpr]);
end;

procedure TTarjeta.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
end;

procedure TTarjeta.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function tarjeta: TTarjeta;
begin
  if xtarjeta = nil then
    xtarjeta := TTarjeta.Create;
  Result := xtarjeta;
end;

{===============================================================================}

initialization

finalization
  xtarjeta.Free;

end.
