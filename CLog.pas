unit CLog;

interface

uses SysUtils, DB, DBTables, CUtiles, CIDBFM, CBDT;

type

TTLoger = class(TObject)            // Superclase
  log, fecha, hora: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xlog, xfecha, xhora: string);
  destructor  Destroy; override;

  procedure   Grabar(xlog, xfecha, xhora: string);
  procedure   Borrar;
  function    Ingresos: Integer;

  function    setLogs: TQuery;
  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  function Buscar(xlog, xfecha, xhora: string): boolean;
end;

function log: TTLoger;

implementation

var
  xlog: TTLoger = nil;

constructor TTLoger.Create(xlog, xfecha, xhora: string);
begin
  inherited Create;
  log     := xlog;
  fecha   := xfecha;
  hora    := xhora;

  if tabla = nil then
    begin
      tabla := TTable.Create(nil);
      tabla.TableName := 'logs.DB'; tabla.IndexDefs.Update;
      tabla.IndexFieldNames := 'usuario;fecha;hora';  // Indice primario
    end;
end;

destructor TTLoger.Destroy;
begin
  inherited Destroy;
end;

procedure TTLoger.Grabar(xlog, xfecha, xhora: string);
// Objetivo...: Grabar Atributos del Objeto
var
  f: string;
begin
  f := utiles.sExprFecha(xfecha);
  f := utiles.sFormatoFecha(f);
  if Buscar(xlog, xfecha, xhora) then tabla.Edit else tabla.Append;
  tabla.FieldByName('usuario').AsString := xlog;
  tabla.FieldByName('fecha').AsString   := f;
  tabla.FieldByName('hora').AsString    := xhora;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

function TTLoger.Buscar(xlog, xfecha, xhora: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if datosdb.Buscar(tabla, 'usuario', 'fecha', 'hora', xlog, xfecha, xhora) then Result := True else Result := False;
end;

function TTLoger.setLogs: TQuery;
// Objetivo...: devolver un subset con los ingresos registrados
var
  rSQL: TQuery;
begin
  rSQL := TQuery.Create(nil);
  rSQL.SQL.Clear; rSQL.SQL.Add('SELECT usuario AS Usuario, fecha AS Fecha, hora AS Hora FROM logs ORDER BY fecha');
  rSQL.ExecSQL;
  Result := rSQL;
end;

procedure TTLoger.Borrar;
begin
  datosdb.tranSQL(dbs.dirSistema, 'DELETE FROM logs');
end;

function  TTLoger.Ingresos: Integer;
begin
  tabla.Open;
  Result := tabla.RecordCount;
  tabla.Close;
end;

procedure TTLoger.conectar;
// Objetivo...: conectar tablas
begin
  if not tabla.Active then tabla.Open;
end;

procedure TTLoger.desconectar;
// Objetivo...: desconectar tablas
begin
  tabla.Refresh;
  if tabla.Active then tabla.Close;
end;


{===============================================================================}

function log: TTLoger;
begin
  if xlog = nil then
    xlog := TTLoger.Create('', '', '');
  Result := xlog;
end;

{===============================================================================}

initialization

finalization
  xlog.Free;

end.
