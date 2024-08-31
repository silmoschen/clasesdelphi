unit CEEstRes;

interface

uses CEstFin, CPlanctas, SysUtils, DB, DBTables, CBDT, CIDBFM;

type

TTEEstRes = class(TTEstadosContables)    // Superclase
  ctaingreso, ctaegreso, digctaingr, digctaegr: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xctaingreso, xctaegreso, xdigctaingr, xdigctaegr: string);
  procedure   getDatos;

  procedure   Via(xvia: string);
  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function ctestres: TTEEstRes;

implementation

var
  xctestres: TTEEstRes = nil;

constructor TTEEstRes.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('ctaemier', '');
end;

destructor TTEEstRes.Destroy;
begin
  inherited Destroy;
end;

procedure TTEEstRes.Grabar(xctaingreso, xctaegreso, xdigctaingr, xdigctaegr: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if tabla.RecordCount > 0 then tabla.Edit else tabla.Append;
  tabla.FieldByName('ctaingreso').AsString := xctaingreso;
  tabla.FieldByName('ctaegreso').AsString  := xctaegreso;
  tabla.FieldByName('digctaingr').AsString := xdigctaingr;
  tabla.FieldByName('digctaegr').AsString  := xdigctaegr;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure  TTEEstRes.getDatos;
// Objetivo...: Retornar/Iniciar Atributos
begin
  ctaingreso := tabla.FieldByName('ctaingreso').AsString;
  ctaegreso  := tabla.FieldByName('ctaegreso').AsString;
  digctaingr := tabla.FieldByName('digctaingr').AsString;
  digctaegr  := tabla.FieldByName('digctaegr').AsString;
end;

procedure TTEEstRes.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    inherited conectar;
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
end;

procedure TTEEstRes.Via(xvia: string);
// Objetivo...: Abrir tablas de persistencia para un directorio X
begin
  inherited Via(xvia);
  tabla := nil;
  tabla := datosdb.openDB('ctaemier', '', dbconexion);
  conectar;
end;

procedure TTEEstRes.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    inherited desconectar;
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function ctestres: TTEEstRes;
begin
  if xctestres = nil then
    xctestres := TTEEstRes.Create;
  Result := xctestres;
end;

{===============================================================================}

initialization

finalization
  xctestres.Free;

end.
