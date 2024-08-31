unit CDepSoc;

interface

uses SysUtils, DB, DBTables, CUtiles, CIDBFM;

type

TTDepositoSocios = class(TObject)
  codsocio, periodo, fecha: string; deposito: real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xcodsocio, xperiodo, xfecha: string; xdeposito: real);
  destructor  Destroy; override;

  function  getFecha: string;
  function  getDeposito: real;

  function  Buscar(xcodsocio, xperiodo: string): boolean;
  procedure Grabar(xcodsocio, xperiodo, xfecha: string; xdeposito: real);
  procedure Borrar(xcodsocio, xperiodo: string);
  procedure getDatos(xcodsocio, xperiodo: string);
  function  getTotalDepositado(xcodsocio: string): real; overload;
  function  getTotalDepositado: real; overload;
  function  EstSqlDepSocios(f1, f2: string): TQuery;
  function  AuditoriaDepositos(xf: string): TQuery;

  procedure conectar;
  procedure desconectar;
 private
  { Declaraciones Privadas }
end;

function depsocios: TTDepositoSocios;

implementation

var
  xdepsocios: TTDepositoSocios = nil;

constructor TTDepositoSocios.Create(xcodsocio, xperiodo, xfecha: string; xdeposito: real);
begin
  inherited Create;
  codsocio := xcodsocio;
  periodo  := xperiodo;
  fecha    := xfecha;
  deposito := xdeposito;

  tabla := datosdb.openDB('deposito', 'codsocio;periodo');
end;

destructor TTDepositoSocios.Destroy;
begin
  inherited Destroy;
end;

function TTDepositoSocios.getFecha: string;
begin
  Result := fecha;
end;

function TTDepositoSocios.getDeposito: real;
begin
  Result := deposito;
end;

function TTDepositoSocios.Buscar(xcodsocio, xperiodo: string): boolean;
// Objetivo...: Buscar una instacia del objeto
begin
  Result := datosdb.Buscar(tabla, 'codsocio', 'periodo', xcodsocio, xperiodo);
end;

procedure TTDepositoSocios.Grabar(xcodsocio, xperiodo, xfecha: string; xdeposito: real);
// Objetivo...: Grabar atributos
begin
  if Buscar(xcodsocio, xperiodo) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codsocio').AsString := xcodsocio;
  tabla.FieldByName('periodo').AsString  := xperiodo;
  tabla.FieldByName('fecha').AsString    := utiles.sExprFecha(xfecha);
  tabla.FieldByName('deposito').AsFloat  := xdeposito;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTDepositoSocios.Borrar(xcodsocio, xperiodo: string);
// Objetivos...: Borrar una instacia del objeto
begin
  if Buscar(xcodsocio, xperiodo) then tabla.Delete;
end;

procedure TTDepositoSocios.getDatos(xcodsocio, xperiodo: string);
// Objetivo...: Actualizar instacias
begin
  if Buscar(xcodsocio, xperiodo) then
    begin
      fecha    := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
      deposito := tabla.FieldByName('deposito').AsFloat;
    end
  else
    begin
      fecha := ''; deposito := 0;
    end;
end;

function TTDepositoSocios.getTotalDepositado(xcodsocio: string): real;
// Objetivo...: retornar total deposito para un socio determinado
var
  r: TQuery;
begin
  r := datosdb.tranSQL('SELECT SUM(deposito) FROM deposito WHERE codsocio = ' + '''' + xcodsocio + '''');
  r.Open;
  Result := r.Fields[0].AsFloat;
  r.Close; r.Free;
end;

function TTDepositoSocios.getTotalDepositado: real;
// Objetivo...: retornar total deposito para un socio determinado
var
  r: TQuery;
begin
  r := datosdb.tranSQL('SELECT SUM (deposito) FROM deposito');
  r.Open;
  Result := r.Fields[0].AsFloat;
  r.Close; r.Free;
end;

function  TTDepositoSocios.EstSqlDepSocios(f1, f2: string): TQuery;
// Objetivo...: Seleccionar los depositos efectuados en el periodo dado
begin
  Result := datosdb.tranSQL('SELECT deposito.codsocio, deposito.fecha, deposito.deposito, soctit.nombre FROM deposito, soctit WHERE deposito.codsocio = soctit.codsocio AND fecha >= ' + '''' + f1 + '''' + ' AND fecha <= ' + '''' + f2 + '''' + ' ORDER BY fecha');
end;

function  TTDepositoSocios.AuditoriaDepositos(xf: string): TQuery;
// Objetivo...: Seleccionar los depositos efectuados en el periodo dado
begin
  Result := datosdb.tranSQL('SELECT deposito.codsocio, deposito.fecha, deposito.deposito, soctit.nombre FROM deposito, soctit WHERE deposito.codsocio = soctit.codsocio AND fecha = ' + '''' + xf + '''' + ' ORDER BY fecha');
end;

procedure TTDepositoSocios.conectar;
begin
  if not tabla.Active then tabla.Open;
  tabla.FieldByName('fecha').Visible := False;
end;

procedure TTDepositoSocios.desconectar;
begin
  if tabla.Active then tabla.Close;
end;

{===============================================================================}

function depsocios: TTDepositoSocios;
begin
  if xdepsocios = nil then
    xdepsocios := TTDepositoSocios.Create('', '', '', 0);
  Result := xdepsocios;
end;

{===============================================================================}

initialization

finalization
  xdepsocios.Free;

end.