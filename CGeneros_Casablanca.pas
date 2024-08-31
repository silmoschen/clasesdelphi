unit CGeneros_Casablanca;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTGeneros = class
  Idgenero, Descrip: String;
  Precio: Real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xidgenero: String): Boolean;
  procedure   Registrar(xidgenero, xdescrip: String; xprecio: Real);
  procedure   Borrar(xidgenero: String);
  procedure   getDatos(xidgenero: String);
  function    Nuevo: String;
  procedure   BuscarPorId(xexpresion: String);
  procedure   BuscarPorDescrip(xexpresion: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function genero: TTGeneros;

implementation

var
  xgenero: TTGeneros = nil;

constructor TTGeneros.Create;
begin
  tabla := datosdb.openDB('generos', '');
end;

destructor TTGeneros.Destroy;
begin
  inherited Destroy;
end;

function  TTGeneros.Buscar(xidgenero: String): Boolean;
// Objetivo...: Buscar la Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'idgenero' then tabla.IndexFieldNames := 'idgenero';
  Result := tabla.FindKey([xidgenero]);
end;

procedure TTGeneros.Registrar(xidgenero, xdescrip: String; xprecio: Real);
// Objetivo...: Registrar una Instancia del Objeto
Begin
  if Buscar(xidgenero) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idgenero').AsString := xidgenero;
  tabla.FieldByName('descrip').AsString  := xdescrip;
  tabla.FieldByName('precio').AsFloat    := xprecio;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.refrescar(tabla);
end;

procedure TTGeneros.Borrar(xidgenero: String);
// Objetivo...: Borrar una Instancia del Objeto
Begin
  if Buscar(xidgenero) then Begin
    tabla.Delete;
    datosdb.refrescar(tabla);
  end;
end;

procedure TTGeneros.getDatos(xidgenero: String);
// Objetivo...: Cargar una Instancia del Objeto
Begin
  if Buscar(xidgenero) then Begin
    idgenero := tabla.FieldByName('idgenero').AsString;
    Descrip  := tabla.FieldByName('descrip').AsString;
    precio   := tabla.FieldByName('precio').AsFloat;
  end else Begin
    idgenero := ''; Descrip := ''; precio := 0;
  end;
end;

function  TTGeneros.Nuevo: String;
// Objetivo...: Crear una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'idgenero' then tabla.IndexFieldNames := 'idgenero';
  if tabla.RecordCount = 0 then Result := '1' else Begin
    tabla.Last;
    Result := IntToStr(tabla.FieldByName('idgenero').AsInteger + 1);
  end;
end;

procedure TTGeneros.BuscarPorId(xexpresion: String);
// Objetivo...: Buscar una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'idgenero' then tabla.IndexFieldNames := 'idgenero';
  tabla.FindNearest([xexpresion]);
end;

procedure TTGeneros.BuscarPorDescrip(xexpresion: String);
// Objetivo...: Buscar una Instancia del Objeto
Begin
  if tabla.IndexFieldNames <> 'descrip' then tabla.IndexFieldNames := 'descrip';
  tabla.FindNearest([xexpresion]);
end;

procedure TTGeneros.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('idgenero').DisplayLabel := 'Id.'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción'; tabla.FieldByName('precio').DisplayLabel := 'Alquiler';
  end;
  Inc(conexiones);
end;

procedure TTGeneros.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function genero: TTGeneros;
begin
  if xgenero = nil then
    xgenero := TTGeneros.Create;
  Result := xgenero;
end;

{===============================================================================}

initialization

finalization
  xgenero.Free;

end.
