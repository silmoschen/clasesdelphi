unit CCAnamnesis_Vicentin;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes;

type

TTAnamnesis = class
  Items, Orden, Descrip: String;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xitems: String): Boolean;
  procedure   Registrar(xitems, xorden, xdescrip: String);
  procedure   Borrar(xitems: String);
  procedure   getDatos(xitems: String);
  function    Nuevo: String;
  function    setItems: TStringList;
  function    setItemsLista: TStringList;

  procedure   BuscarPorId(xexpresion: String);
  procedure   BuscarPorDescrip(xexpresion: String);
  procedure   BuscarPorOrden(xexpresion: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function anamnesis: TTAnamnesis;

implementation

var
  xanamnesis: TTAnamnesis = nil;

constructor TTAnamnesis.Create;
begin
  tabla := datosdb.openDB('anamnesis', '');
end;

destructor TTAnamnesis.Destroy;
begin
  inherited Destroy;
end;

function  TTAnamnesis.Buscar(xitems: String): Boolean;
// Objetivo...: Buscar la Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'items' then tabla.IndexFieldNames := 'items';
  Result := tabla.FindKey([xitems]);
end;

procedure TTAnamnesis.Registrar(xitems, xorden, xdescrip: String);
// Objetivo...: Registrar una Instancia del Objeto
Begin
  if Buscar(xitems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('items').AsString   := xitems;
  tabla.FieldByName('orden').AsString   := xorden;
  tabla.FieldByName('descrip').AsString := xdescrip;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.refrescar(tabla);
end;

procedure TTAnamnesis.Borrar(xitems: String);
// Objetivo...: Borrar una Instancia del Objeto
Begin
  if Buscar(xitems) then Begin
    tabla.Delete;
    datosdb.refrescar(tabla);
  end;
end;

procedure TTAnamnesis.getDatos(xitems: String);
// Objetivo...: Cargar una Instancia del Objeto
Begin
  if Buscar(xitems) then Begin
    items   := tabla.FieldByName('items').AsString;
    Descrip := tabla.FieldByName('descrip').AsString;
    Orden   := tabla.FieldByName('orden').AsString;
  end else Begin
    items := ''; Descrip := ''; Orden := '';
  end;
end;

function  TTAnamnesis.Nuevo: String;
// Objetivo...: Crear una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'items' then tabla.IndexFieldNames := 'items';
  if tabla.RecordCount = 0 then Result := '1' else Begin
    tabla.Last;
    Result := IntToStr(tabla.FieldByName('items').AsInteger + 1);
  end;
end;

function  TTAnamnesis.setItems: TStringList;
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

function  TTAnamnesis.setItemsLista: TStringList;
// Objetivo...: devolver los objetos
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if tabla.IndexFieldNames <> 'orden' then tabla.IndexFieldNames := 'orden';
  tabla.First;
  while not tabla.Eof do Begin
    l.Add(tabla.FieldByName('orden').AsString + tabla.FieldByName('items').AsString + tabla.FieldByName('descrip').AsString);
    tabla.Next;
  end;
  Result := l;
end;

procedure TTAnamnesis.BuscarPorId(xexpresion: String);
// Objetivo...: Buscar una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'items' then tabla.IndexFieldNames := 'items';
  tabla.FindNearest([xexpresion]);
end;

procedure TTAnamnesis.BuscarPorDescrip(xexpresion: String);
// Objetivo...: Buscar una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'descrip' then tabla.IndexFieldNames := 'descrip';
  tabla.FindNearest([xexpresion]);
end;

procedure TTAnamnesis.BuscarPorOrden(xexpresion: String);
// Objetivo...: Buscar una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'orden' then tabla.IndexFieldNames := 'orden';
  tabla.FindNearest([xexpresion]);
end;

procedure TTAnamnesis.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('items').DisplayLabel := 'Id.'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción del Items';
  end;
  Inc(conexiones);
end;

procedure TTAnamnesis.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function anamnesis: TTAnamnesis;
begin
  if xanamnesis = nil then
    xanamnesis := TTAnamnesis.Create;
  Result := xanamnesis;
end;

{===============================================================================}

initialization

finalization
  xanamnesis.Free;

end.
