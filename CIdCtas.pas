unit CIdctas;

interface

uses CBDT, CIDBFM, CPlanctasAsociacion, DB, DBTables, SysUtils;

type

TTIdctas = class(TObject)          // Clase Base
  idcta, codcta, concepto: string;
  idctas: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xidcta, xcodcta, xconcepto: string);
  destructor  Destroy; override;

  function    getIdcta: string;
  function    getCodcta: string; overload;
  function    getCodcta(xidcta: string): string; overload;
  function    getCuenta: string;
  function    getConcepto: string;

  procedure   Grabar(xidcta, xcodcta, xconcepto: string);
  procedure   Borrar;
  procedure   getDatos(xidcta: string);

  procedure   Via(xvia: string);
  procedure   conectar;
  procedure   desconectar;
 private
  cuenta, path: string;
  conexiones: shortint;
  { Declaraciones Privadas }
end;

function idctas: TTIdctas;

implementation

var
  xidctas: TTIdctas = nil;

constructor TTIdctas.Create(xidcta, xcodcta, xconcepto: string);
// Objetivo...: Contructor
begin
  inherited Create;
  idcta    := xidcta;
  codcta   := xcodcta;
  concepto := xconcepto;

  idctas := datosdb.openDB('idctas', 'idcta');
end;

destructor TTIdctas.Destroy;
// Objetivo...: destructor
begin
  inherited Destroy;
end;

function TTIdctas.getIdcta: string;
begin
  Result := idcta;
end;

function TTIdctas.getCodcta: string;
begin
  Result := codcta;
end;

function TTIdctas.getCodcta(xidcta: string): string;
begin
  conectar;
  getDatos(xidcta);
  Result := codcta;
end;

function TTIdctas.getCuenta: string;
begin
  Result := cuenta;
end;

function TTIdctas.getConcepto: string;
begin
  Result := concepto;
end;

procedure TTIdctas.Grabar(xidcta, xcodcta, xconcepto: string);
// Objetivo...: Grabar tablas de persistencia
begin
  if idctas.FindKey([xidcta]) then idctas.Edit else idctas.Append;
  idctas.FieldByName('idcta').AsString    := xidcta;
  idctas.FieldByName('codcta').AsString   := xcodcta;
  idctas.FieldByName('concepto').AsString := xconcepto;
  try
    idctas.Post;
  except
    idctas.Cancel;
  end;
end;

procedure TTIdctas.Borrar;
// Objetivo...: Redefinir las cuentas
begin
  datosdb.tranSQL(path, 'DELETE FROM idctas');
end;

procedure TTIdctas.getDatos(xidcta: string);
// Objetivo...: actualizar atributos
begin
  conectar;
  if idctas.FindKey([xidcta]) then
    begin
      codcta   := idctas.FieldByName('codcta').AsString;
      concepto := idctas.FieldByName('concepto').AsString;
      planctas.getDatos(codcta);
      cuenta   := planctas.Cuenta
    end
  else
    begin
      codcta := ''; cuenta := ''; concepto := '';
    end;
end;

procedure TTIdctas.conectar;
// Objetivo...: conectar tabla de persistencia
begin
  if conexiones = 0 then Begin
    if not idctas.Active then idctas.Open;
    planctas.conectar;
  end;
  Inc(conexiones);
end;

procedure TTIdctas.Via(xvia: string);
// Objetivo...: conectar tablas de persistencia
begin
  idctas := nil;
  idctas := datosdb.openDB('idctas', 'idcta', '', dbs.dirSistema + xvia);
  conexiones := 0; conectar; path := dbs.dirSistema + xvia;
end;

procedure TTIdctas.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    if idctas.Active then idctas.Close;
    planctas.DesactivarFiltro;
    planctas.desconectar;
  end;
end;

{===============================================================================}

function idctas: TTIdctas;
begin
  if xidctas = nil then
    xidctas := TTIdctas.Create('', '', '');
  Result := xidctas;
end;

{===============================================================================}

initialization

finalization
  xidctas.Free;

end.