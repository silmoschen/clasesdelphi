unit CNomeclatura_Vicentin;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes;

type

TTNomeclatura = class
  Items, Descrip, Minimo, Maximo: String;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xitems: String): Boolean;
  procedure   Registrar(xitems, xdescrip, xminimo, xmaximo: String);
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

function anamnesis: TTNomeclatura;

implementation

var
  xanamnesis: TTNomeclatura = nil;

constructor TTNomeclatura.Create;
begin
  tabla := datosdb.openDB('nomeclatura', '');
end;

destructor TTNomeclatura.Destroy;
begin
  inherited Destroy;
end;

function  TTNomeclatura.Buscar(xitems: String): Boolean;
// Objetivo...: Buscar la Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'items' then tabla.IndexFieldNames := 'items';
  Result := tabla.FindKey([xitems]);
end;

procedure TTNomeclatura.Registrar(xitems, xdescrip, xminimo, xmaximo: String);
// Objetivo...: Registrar una Instancia del Objeto
Begin
  if Buscar(xitems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('items').AsString    := xitems;
  tabla.FieldByName('descrip').AsString  := xdescrip;
  tabla.FieldByName('minimo').AsString   := xminimo;
  tabla.FieldByName('maximo').AsString   := xmaximo;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closedb(tabla); tabla.Open;
end;

procedure TTNomeclatura.Borrar(xitems: String);
// Objetivo...: Borrar una Instancia del Objeto
Begin
  if Buscar(xitems) then Begin
    tabla.Delete;
    datosdb.closedb(tabla); tabla.Open;
  end;
end;

procedure TTNomeclatura.getDatos(xitems: String);
// Objetivo...: Cargar una Instancia del Objeto
Begin
  if Buscar(xitems) then Begin
    items    := tabla.FieldByName('items').AsString;
    Descrip  := tabla.FieldByName('descrip').AsString;
    Minimo   := tabla.FieldByName('minimo').AsString;
    Maximo   := tabla.FieldByName('maximo').AsString;
  end else Begin
    items := ''; Descrip := ''; minimo := ''; maximo := '';
  end;
end;

function  TTNomeclatura.Nuevo: String;
// Objetivo...: Crear una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'items' then tabla.IndexFieldNames := 'items';
  if tabla.RecordCount = 0 then Result := '1' else Begin
    tabla.Last;
    Result := IntToStr(tabla.FieldByName('items').AsInteger + 1);
  end;
end;

function  TTNomeclatura.setItems: TStringList;
// Objetivo...: devolver los objetos
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if tabla.IndexFieldNames <> 'items' then tabla.IndexFieldNames := 'items';
  tabla.First;
  while not tabla.Eof do Begin
    l.Add(tabla.FieldByName('items').AsString + tabla.FieldByName('descrip').AsString + tabla.FieldByName('minimo').AsString + tabla.FieldByName('maximo').AsString);
    tabla.Next;
  end;
  Result := l;
end;

procedure TTNomeclatura.BuscarPorId(xexpresion: String);
// Objetivo...: Buscar una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'items' then tabla.IndexFieldNames := 'items';
  tabla.FindNearest([xexpresion]);
end;

procedure TTNomeclatura.BuscarPorDescrip(xexpresion: String);
// Objetivo...: Buscar una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'descrip' then tabla.IndexFieldNames := 'descrip';
  tabla.FindNearest([xexpresion]);
end;

procedure TTNomeclatura.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('items').DisplayLabel := 'Id.'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción del Items';
  end;
  Inc(conexiones);
end;

procedure TTNomeclatura.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function anamnesis: TTNomeclatura;
begin
  if xanamnesis = nil then
    xanamnesis := TTNomeclatura.Create;
  Result := xanamnesis;
end;

{===============================================================================}

initialization

finalization
  xanamnesis.Free;

end.
