unit CLimitesCreditos_Circulo;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTLimiteCreditos = class
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

function limitecredito: TTLimiteCreditos;

implementation

var
  xlimitecredito: TTLimiteCreditos = nil;

constructor TTLimiteCreditos.Create;
begin
  tabla := datosdb.openDB('limitecreditos', '');
end;

destructor TTLimiteCreditos.Destroy;
begin
  inherited Destroy;
end;

function  TTLimiteCreditos.Buscar(xidcategoria: String): Boolean;
// Objetivo...: Buscar la Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'idcategoria' then tabla.IndexFieldNames := 'idcategoria';
  Result := tabla.FindKey([xidcategoria]);
end;

procedure TTLimiteCreditos.Registrar(xidcategoria, xdescrip: String; xlimite: Real);
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

procedure TTLimiteCreditos.Borrar(xidcategoria: String);
// Objetivo...: Borrar una Instancia del Objeto
Begin
  if Buscar(xidcategoria) then Begin
    tabla.Delete;
    datosdb.refrescar(tabla);
  end;
end;

procedure TTLimiteCreditos.getDatos(xidcategoria: String);
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

function  TTLimiteCreditos.Nuevo: String;
// Objetivo...: Crear una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'idcategoria' then tabla.IndexFieldNames := 'idcategoria';
  if tabla.RecordCount = 0 then Result := '1' else Begin
    tabla.Last;
    Result := IntToStr(tabla.FieldByName('idcategoria').AsInteger + 1);
  end;
end;

procedure TTLimiteCreditos.BuscarPorId(xexpresion: String);
// Objetivo...: Buscar una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'idcategoria' then tabla.IndexFieldNames := 'idcategoria';
  tabla.FindNearest([xexpresion]);
end;

procedure TTLimiteCreditos.BuscarPorDescrip(xexpresion: String);
// Objetivo...: Buscar una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'categoria' then tabla.IndexFieldNames := 'categoria';
  tabla.FindNearest([xexpresion]);
end;

procedure TTLimiteCreditos.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('idcategoria').DisplayLabel := 'Id.'; tabla.FieldByName('categoria').DisplayLabel := 'Categoría'; tabla.FieldByName('limite').DisplayLabel := 'Limite del Crédito';
  end;
  Inc(conexiones);
end;

procedure TTLimiteCreditos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function limitecredito: TTLimiteCreditos;
begin
  if xlimitecredito = nil then
    xlimitecredito := TTLimiteCreditos.Create;
  Result := xlimitecredito;
end;

{===============================================================================}

initialization

finalization
  xlimitecredito.Free;

end.
