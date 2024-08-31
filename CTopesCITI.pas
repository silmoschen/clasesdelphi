unit CTopesCITI;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CIDBFM, Contnrs;

type

TTopesCITI = class
  Codcomp, Periodo, Operador: string; Tope: real;
  topes: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xcodcomp, xperiodo: String): boolean;
  procedure   Registrar(xcodcomp, xperiodo, xoperador: String; xmonto: Real);
  procedure   Borrar(xcodcomp, xperiodo: String);
  procedure   getDatos(xcodcomp, xperiodo: String);

  function    getTopes(xcodcomp: string): TObjectList;
  function    getTope(xcodcomp, xperiodo: string): real;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function topeciti: TTopesCITI;

implementation

var
  xtopeciti: TTopesCITI = nil;

constructor TTopesCITI.Create;
begin
  topes := datosdb.openDB('topesCITI', '');
end;

destructor TTopesCITI.Destroy;
begin
  inherited Destroy;
end;

function  TTopesCITI.Buscar(xcodcomp, xperiodo: String): boolean;
// Objetivo...: buscar una instancia
begin
  result := datosdb.Buscar(topes, 'codcomp', 'periodo', xcodcomp, xperiodo);
end;

procedure TTopesCITI.Registrar(xcodcomp, xperiodo, xoperador: String; xmonto: Real);
// Objetivo...: registrar una instancia
begin
  if Buscar(xcodcomp, utiles.getPeriodoAAAAMM(xperiodo)) then topes.Edit else topes.Append;
  topes.FieldByName('codcomp').AsString  := xcodcomp;
  topes.FieldByName('periodo').AsString  := utiles.getPeriodoAAAAMM(xperiodo);
  topes.FieldByName('operador').AsString := xoperador;
  topes.FieldByName('tope').AsFloat      := xmonto;
  try
    topes.Post
  except
    topes.Cancel
  end;
  datosdb.closeDB(topes); topes.Open;
end;

procedure TTopesCITI.Borrar(xcodcomp, xperiodo: String);
// Objetivo...: borrar una instancia
begin
  if Buscar(xcodcomp, utiles.getPeriodoAAAAMM(xperiodo)) then begin
    topes.Delete;
    datosdb.closeDB(topes); topes.Open;
  end;
end;

procedure TTopesCITI.getDatos(xcodcomp, xperiodo: String);
// Objetivo...: recuperar una instancia
begin
  if Buscar(xcodcomp, utiles.getPeriodoAAAAMM(xperiodo)) then begin
    codcomp  := topes.FieldByName('codcomp').AsString;
    operador := topes.FieldByName('operador').AsString;
    periodo  := utiles.getPeriodoMMAAAA(topes.FieldByName('periodo').AsString);
    tope     := topes.FieldByName('tope').AsFloat;
  end else begin
    codcomp := ''; periodo := ''; tope := 0; operador := '';
  end;
end;

function TTopesCITI.getTopes(xcodcomp: string): TObjectList;
// Objetivo...: devolver una lista con los periodos
var
  l: TObjectList;
  objeto: TTopesCITI;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(topes, 'codcomp = ' + '''' + xcodcomp + '''');
  topes.First;
  while not topes.Eof do begin
    objeto := TTopesCITI.Create;
    objeto.codcomp  := topes.FieldByName('codcomp').AsString;
    objeto.operador := topes.FieldByName('operador').AsString;
    objeto.periodo  := utiles.getPeriodoMMAAAA(topes.FieldByName('periodo').AsString);
    objeto.tope     := topes.FieldByName('tope').AsFloat;
    l.Add(objeto);
    topes.Next;
  end;
  datosdb.QuitarFiltro(topes);
  result := l;
end;

function  TTopesCITI.getTope(xcodcomp, xperiodo: string): real;
// Objetivo...: cerrar tablas de persistencia
var
  t: real;
begin
  t := 0;
  datosdb.Filtrar(topes, 'codcomp = ' + '''' + xcodcomp + '''');
  topes.First;
  while not topes.Eof do begin
    t        := topes.FieldByName('tope').AsFloat;
    operador := topes.FieldByName('operador').AsString;
    if (topes.FieldByName('periodo').AsString >= utiles.getPeriodoAAAAMM(xperiodo)) then break;
    topes.Next;
  end;
  datosdb.QuitarFiltro(topes);
  result := t;
end;

procedure TTopesCITI.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not topes.Active then topes.Open;
  end;
  Inc(conexiones);
end;

procedure TTopesCITI.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(topes);
  end;
end;

{===============================================================================}

function topeciti: TTopesCITI;
begin
  if xtopeciti = nil then
    xtopeciti := TTopesCITI.Create;
  Result := xtopeciti;
end;

{===============================================================================}

initialization

finalization
  xtopeciti.Free;

end.
