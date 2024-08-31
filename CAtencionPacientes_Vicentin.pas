unit CAtencionPacientes_Vicentin;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes;

type

TTAtencion = class
  Items, Descrip: String;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xitems: String): Boolean;
  procedure   Registrar(xitems, xdescrip: String);
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

function atencionpac: TTAtencion;

implementation

var
  xatencionpac: TTAtencion = nil;

constructor TTAtencion.Create;
begin
  tabla := datosdb.openDB('atencion', '');
end;

destructor TTAtencion.Destroy;
begin
  inherited Destroy;
end;

function  TTAtencion.Buscar(xitems: String): Boolean;
// Objetivo...: Buscar la Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'items' then tabla.IndexFieldNames := 'items';
  Result := tabla.FindKey([xitems]);
end;

procedure TTAtencion.Registrar(xitems, xdescrip: String);
// Objetivo...: Registrar una Instancia del Objeto
Begin
  if Buscar(xitems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('items').AsString    := xitems;
  tabla.FieldByName('descrip').AsString  := xdescrip;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closedb(tabla); tabla.Open;
end;

procedure TTAtencion.Borrar(xitems: String);
// Objetivo...: Borrar una Instancia del Objeto
Begin
  if Buscar(xitems) then Begin
    tabla.Delete;
    datosdb.closedb(tabla); tabla.Open;
  end;
end;

procedure TTAtencion.getDatos(xitems: String);
// Objetivo...: Cargar una Instancia del Objeto
Begin
  if Buscar(xitems) then Begin
    items    := tabla.FieldByName('items').AsString;
    Descrip  := tabla.FieldByName('descrip').AsString;
  end else Begin
    items := ''; Descrip := '';
  end;
end;

function  TTAtencion.Nuevo: String;
// Objetivo...: Crear una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'items' then tabla.IndexFieldNames := 'items';
  if tabla.RecordCount = 0 then Result := '1' else Begin
    tabla.Last;
    Result := IntToStr(tabla.FieldByName('items').AsInteger + 1);
  end;
end;

function  TTAtencion.setItems: TStringList;
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

procedure TTAtencion.BuscarPorId(xexpresion: String);
// Objetivo...: Buscar una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'items' then tabla.IndexFieldNames := 'items';
  tabla.FindNearest([xexpresion]);
end;

procedure TTAtencion.BuscarPorDescrip(xexpresion: String);
// Objetivo...: Buscar una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'descrip' then tabla.IndexFieldNames := 'descrip';
  tabla.FindNearest([xexpresion]);
end;

procedure TTAtencion.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('items').DisplayLabel := 'Id.'; tabla.FieldByName('descrip').DisplayLabel := 'Lugar de Atención';
  end;
  Inc(conexiones);
end;

procedure TTAtencion.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function atencionpac: TTAtencion;
begin
  if xatencionpac = nil then
    xatencionpac := TTAtencion.Create;
  Result := xatencionpac;
end;

{===============================================================================}

initialization

finalization
  xatencionpac.Free;

end.
