unit CLimitesCreditos_Penias;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTLimitePenias = class
  Idcategoria, Descrip: String;
  Limite: Real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xidcategoria: String): Boolean;
  procedure   Registrar(xidcategoria, xdescrip: String; xlimite: Real);
  procedure   Borrar(xidcategoria: String);
  procedure   getDatos(xidcategoria: String);
  function    Nuevo: String;
  procedure   BuscarPorId(xexpresion: String);
  procedure   BuscarPorDescrip(xexpresion: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function limitepenia: TTLimitePenias;

implementation

var
  xlimitepenia: TTLimitePenias = nil;

constructor TTLimitePenias.Create;
begin
  tabla := datosdb.openDB('limitepenias', '');
end;

destructor TTLimitePenias.Destroy;
begin
  inherited Destroy;
end;

function  TTLimitePenias.Buscar(xidcategoria: String): Boolean;
// Objetivo...: Buscar la Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'idcategoria' then tabla.IndexFieldNames := 'idcategoria';
  Result := tabla.FindKey([xidcategoria]);
end;

procedure TTLimitePenias.Registrar(xidcategoria, xdescrip: String; xlimite: Real);
// Objetivo...: Registrar una Instancia del Objeto
Begin
  if Buscar(xidcategoria) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idcategoria').AsString := xidcategoria;
  tabla.FieldByName('categoria').AsString   := xdescrip;
  tabla.FieldByName('limite').AsFloat       := xlimite;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.refrescar(tabla);
end;

procedure TTLimitePenias.Borrar(xidcategoria: String);
// Objetivo...: Borrar una Instancia del Objeto
Begin
  if Buscar(xidcategoria) then Begin
    tabla.Delete;
    datosdb.refrescar(tabla);
  end;
end;

procedure TTLimitePenias.getDatos(xidcategoria: String);
// Objetivo...: Cargar una Instancia del Objeto
Begin
  if Buscar(xidcategoria) then Begin
    Idcategoria := tabla.FieldByName('idcategoria').AsString;
    Descrip     := tabla.FieldByName('categoria').AsString;
    Limite      := tabla.FieldByName('limite').AsFloat;
  end else Begin
    Idcategoria := ''; Descrip := ''; Limite := 0;
  end;
end;

function  TTLimitePenias.Nuevo: String;
// Objetivo...: Crear una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'idcategoria' then tabla.IndexFieldNames := 'idcategoria';
  if tabla.RecordCount = 0 then Result := '1' else Begin
    tabla.Last;
    Result := IntToStr(tabla.FieldByName('idcategoria').AsInteger + 1);
  end;
end;

procedure TTLimitePenias.BuscarPorId(xexpresion: String);
// Objetivo...: Buscar una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'idcategoria' then tabla.IndexFieldNames := 'idcategoria';
  tabla.FindNearest([xexpresion]);
end;

procedure TTLimitePenias.BuscarPorDescrip(xexpresion: String);
// Objetivo...: Buscar una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'categoria' then tabla.IndexFieldNames := 'categoria';
  tabla.FindNearest([xexpresion]);
end;

procedure TTLimitePenias.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('idcategoria').DisplayLabel := 'Id.'; tabla.FieldByName('categoria').DisplayLabel := 'Categoría'; tabla.FieldByName('limite').DisplayLabel := 'Limite del Crédito';
  end;
  Inc(conexiones);
end;

procedure TTLimitePenias.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function limitepenia: TTLimitePenias;
begin
  if xlimitepenia = nil then
    xlimitepenia := TTLimitePenias.Create;
  Result := xlimitepenia;
end;

{===============================================================================}

initialization

finalization
  xlimitepenia.Free;

end.
