unit CEmpresa;

interface

uses SysUtils, DB, DBTables, CUtiles, CIDBFM, CBDT;

type

TTEmpresa = class(TObject)            // Superclase
  rsocial, direccion, telefono, cuit, ptovta, tipo, inicioactividad: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xrsocial, xdireccion, xtelefono, xcuit, xptovta, xtipo, xinicioactividad: string);
  function    Buscar: boolean;
  procedure   getDatos;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
end;

function empresa: TTEmpresa;

implementation

var
  xempresa: TTEmpresa = nil;

constructor TTEmpresa.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('datosempresa', 'id');
  conectar;
end;

destructor TTEmpresa.Destroy;
begin
  inherited Destroy;
end;

procedure TTEmpresa.Grabar(xrsocial, xdireccion, xtelefono, xcuit, xptovta, xtipo, xinicioactividad: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar then tabla.Edit else tabla.Append;
  tabla.FieldByName('id').AsString              := '1';
  tabla.FieldByName('rsocial').AsString         := xrsocial;
  tabla.FieldByName('direccion').AsString       := xdireccion;
  tabla.FieldByName('telefono').AsString        := xtelefono;
  tabla.FieldByName('cuit').AsString            := xcuit;
  tabla.FieldByName('ptovta').AsString          := xptovta;
  tabla.FieldByName('tipo').AsString            := xtipo;
  tabla.FieldByName('inicioactividad').AsString := xinicioactividad;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
end;

function TTEmpresa.Buscar: boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  result := datosdb.Buscar(tabla, 'id', '1');
end;

procedure  TTEmpresa.getDatos;
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar then Begin
    rsocial         := tabla.FieldByName('rsocial').AsString;
    direccion       := tabla.FieldByName('direccion').AsString;
    telefono        := tabla.FieldByName('telefono').AsString;
    cuit            := tabla.FieldByName('cuit').AsString;
    ptovta          := tabla.FieldByName('ptovta').AsString;
    tipo            := tabla.FieldByName('tipo').AsString;
    inicioactividad := tabla.FieldByName('inicioactividad').AsString;
  end else begin
    rsocial := ''; direccion := ''; telefono := ''; cuit := ''; ptovta := ''; tipo := ''; inicioactividad := '';
  end;
end;

procedure TTEmpresa.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if not tabla.Active then tabla.Open;
end;

procedure TTEmpresa.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  datosdb.closeDB(tabla);
end;

{===============================================================================}

function empresa: TTEmpresa;
begin
  if xempresa = nil then
    xempresa := TTEmpresa.Create;
  Result := xempresa;
end;

{===============================================================================}

initialization

finalization
  xempresa.Free;

end.
