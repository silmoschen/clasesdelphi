// Objetivo...: Clase que habilita/inhabilita el manejo de datos confidenciales
// Version....: 1.0
// Autor......: Silvio Moschen
// Heredada de: Superclase

unit CHabpw;

interface

uses CIDBFM, DB, DBTables, SysUtils;

type

TTHpw = class(TObject)          // Clase Base
  tabla: TTable;
  habilitado: boolean;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   habilitar;
  procedure   inhabilitar;
  function    getEstado: shortint;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
end;

function datospw: TTHpw;

implementation

var
  xdatospw: TTHpw = nil;

constructor TTHpw.Create;
begin
  inherited Create;
  tabla := TTable.Create(nil);
  tabla.TableName := 'habpass';
end;

destructor TTHpw.Destroy;
begin
  inherited Destroy;
end;

function TTHpw.getEstado: shortint;
// Objetivo...: retornar estado del la llave
begin
  if tabla.RecordCount = 0 then Result := 0 else Result := tabla.FieldByName('habilitarPw').AsInteger;
end;

procedure TTHpw.habilitar;
// Objetivo...: Habilitar manejo por clave
begin
  if tabla.RecordCount = 0 then tabla.Append else tabla.Edit;
  tabla.FieldByName('habilitarPw').AsInteger := 1;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTHpw.inhabilitar;
// Objetivo...: Habilitar manejo por clave
begin
  if tabla.RecordCount = 0 then tabla.Append else tabla.Edit;
  tabla.FieldByName('habilitarPw').AsInteger := 0;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTHpw.conectar;
begin
  if not tabla.Active then tabla.Open;
end;

procedure TTHpw.desconectar;
begin
  datosdb.closeDB(tabla);
end;

{===============================================================================}

function datospw: TTHpw;
begin
  if xdatospw = nil then
    xdatospw := TTHpw.Create;
  Result := xdatospw;
end;

{===============================================================================}

initialization

finalization
  xdatospw.Free;

end.