unit CMotivosConsulta_Vicentin;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes;

type

TTMotivoConsulta = class
  Items, Descrip: String; Monto: Real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xitems: String): Boolean;
  procedure   Registrar(xitems, xdescrip: String; xmonto: Real);
  procedure   Borrar(xitems: String);
  procedure   getDatos(xitems: String);
  function    Nuevo: String;
  function    setItems: TStringList;

  procedure   BuscarPorId(xexpresion: String);
  procedure   BuscarPorDescrip(xexpresion: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function motivocons: TTMotivoConsulta;

implementation

var
  xmotivocons: TTMotivoConsulta = nil;

constructor TTMotivoConsulta.Create;
begin
  tabla := datosdb.openDB('motivos_consulta', '');
end;

destructor TTMotivoConsulta.Destroy;
begin
  inherited Destroy;
end;

function  TTMotivoConsulta.Buscar(xitems: String): Boolean;
// Objetivo...: Buscar la Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'items' then tabla.IndexFieldNames := 'items';
  Result := tabla.FindKey([xitems]);
end;

procedure TTMotivoConsulta.Registrar(xitems, xdescrip: String; xmonto: Real);
// Objetivo...: Registrar una Instancia del Objeto
Begin
  if Buscar(xitems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('items').AsString    := xitems;
  tabla.FieldByName('descrip').AsString  := xdescrip;
  tabla.FieldByName('monto').AsFloat     := xmonto;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.refrescar(tabla);
end;

procedure TTMotivoConsulta.Borrar(xitems: String);
// Objetivo...: Borrar una Instancia del Objeto
Begin
  if Buscar(xitems) then Begin
    tabla.Delete;
    datosdb.refrescar(tabla);
  end;
end;

procedure TTMotivoConsulta.getDatos(xitems: String);
// Objetivo...: Cargar una Instancia del Objeto
Begin
  if Buscar(xitems) then Begin
    items    := tabla.FieldByName('items').AsString;
    Descrip  := tabla.FieldByName('descrip').AsString;
    Monto    := tabla.FieldByName('monto').AsFloat;
  end else Begin
    items := ''; Descrip := ''; Monto := 0;
  end;
end;

function  TTMotivoConsulta.Nuevo: String;
// Objetivo...: Crear una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'items' then tabla.IndexFieldNames := 'items';
  if tabla.RecordCount = 0 then Result := '1' else Begin
    tabla.Last;
    Result := IntToStr(tabla.FieldByName('items').AsInteger + 1);
  end;
end;

function  TTMotivoConsulta.setItems: TStringList;
// Objetivo...: devolver los objetos
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if tabla.IndexFieldNames <> 'items' then tabla.IndexFieldNames := 'items';
  tabla.First;
  while not tabla.Eof do Begin
    l.Add(tabla.FieldByName('items').AsString + tabla.FieldByName('descrip').AsString);
    tabla.Next;
  end;
  Result := l;
end;

procedure TTMotivoConsulta.BuscarPorId(xexpresion: String);
// Objetivo...: Buscar una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'items' then tabla.IndexFieldNames := 'items';
  tabla.FindNearest([xexpresion]);
end;

procedure TTMotivoConsulta.BuscarPorDescrip(xexpresion: String);
// Objetivo...: Buscar una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'descrip' then tabla.IndexFieldNames := 'descrip';
  tabla.FindNearest([xexpresion]);
end;

procedure TTMotivoConsulta.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('items').DisplayLabel := 'Id.'; tabla.FieldByName('descrip').DisplayLabel := 'Motivo de la Consulta'; tabla.FieldByName('monto').DisplayLabel := 'Monto';
  end;
  Inc(conexiones);
end;

procedure TTMotivoConsulta.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function motivocons: TTMotivoConsulta;
begin
  if xmotivocons = nil then
    xmotivocons := TTMotivoConsulta.Create;
  Result := xmotivocons;
end;

{===============================================================================}

initialization

finalization
  xmotivocons.Free;

end.
