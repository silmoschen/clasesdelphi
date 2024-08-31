unit CCuentasBancariasCont_ADR;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes, CPlanctasAsociacion;

type

TTctactebcos = class
  ctasctes_creditos: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   IniciarCuentas;
  function    BuscarCuenta(xcodcta: String): Boolean;
  procedure   RegistrarCuenta(xcodcta: String);
  procedure   RegistrarDigitoBancario(xcodcta, xdigito, xidcredito: String);
  function    setCuentas: TStringList;
  function    getCuenta(xdigito: String): String;
  function    BuscarDigito(xdigito: String): Boolean;
  function    setDigitoCtaBcaria(xidcredito: String): String;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function ctactebcos: TTctactebcos;

implementation

var
  xctactebcos: TTctactebcos = nil;

constructor TTctactebcos.Create;
begin
  ctasctes_creditos := datosdb.openDB('ctasbcarias_creditos', '');
end;

destructor TTctactebcos.Destroy;
begin
  inherited Destroy;
end;

procedure TTctactebcos.IniciarCuentas;
// objetivo...: Iniciar Cuentas
Begin
  datosdb.tranSQL('delete from ' + ctasctes_creditos.TableName);
  datosdb.closedb(ctasctes_creditos); ctasctes_creditos.Open;
end;

function TTctactebcos.BuscarCuenta(xcodcta: String): Boolean;
// objetivo...: Registrar cuentas
Begin
  Result := ctasctes_creditos.FindKey([xcodcta]);
end;

procedure TTctactebcos.RegistrarCuenta(xcodcta: String);
// objetivo...: Registrar cuentas
Begin
  if ctasctes_creditos.FindKey([xcodcta]) then ctasctes_creditos.Edit else ctasctes_creditos.Append;
  ctasctes_creditos.FieldByName('codcta').AsString := xcodcta;
  try
    ctasctes_creditos.Post
   except
    ctasctes_creditos.Cancel
  end;
  datosdb.refrescar(ctasctes_creditos);
end;

procedure TTctactebcos.RegistrarDigitoBancario(xcodcta, xdigito, xidcredito: String);
// objetivo...: Registrar cuentas
Begin
  if ctasctes_creditos.FindKey([xcodcta]) then ctasctes_creditos.Edit else ctasctes_creditos.Append;
  ctasctes_creditos.FieldByName('digito').AsString    := xdigito;
  ctasctes_creditos.FieldByName('idcredito').AsString := xidcredito;
  try
    ctasctes_creditos.Post
   except
    ctasctes_creditos.Cancel
  end;
  datosdb.refrescar(ctasctes_creditos);
end;

function  TTctactebcos.setDigitoCtaBcaria(xidcredito: String): String;
// objetivo...: Recuperar instancias
Begin
  Result := '';
  ctasctes_creditos.First;
  while not ctasctes_creditos.Eof do Begin
    if ctasctes_creditos.FieldByName('idcredito').AsString = xidcredito then Begin
      Result := ctasctes_creditos.FieldByName('digito').AsString;
      Break;
    end;
    ctasctes_creditos.Next;
  end;
end;

function  TTctactebcos.setCuentas: TStringList;
// objetivo...: Recuperar instancias
var
  l: TStringList;
Begin
  l := TStringList.Create;

  ctasctes_creditos.First;
  while not ctasctes_creditos.Eof do Begin
    l.Add(ctasctes_creditos.FieldByName('codcta').AsString + ctasctes_creditos.FieldByName('digito').AsString + ctasctes_creditos.FieldByName('idcredito').AsString);
    ctasctes_creditos.Next;
  end;

  Result := l;
end;

function  TTctactebcos.BuscarDigito(xdigito: String): Boolean;
// objetivo...: Buscar una cuenta por su codigo abreviado
Begin
  Result := False;
  ctasctes_creditos.First;
  while not ctasctes_creditos.Eof do Begin
    if ctasctes_creditos.FieldByName('digito').AsString = xdigito then Begin
      Result := True;
      Break;
    end;
    ctasctes_creditos.Next;
  end;
end;

function  TTctactebcos.getCuenta(xdigito: String): String;
// objetivo...: Devolver Cuenta
Begin
  Result := '';
  ctasctes_creditos.First;
  while not ctasctes_creditos.Eof do Begin
    if ctasctes_creditos.FieldByName('digito').AsString = xdigito then Begin
      planctas.getDatos(ctasctes_creditos.FieldByName('codcta').AsString);
      Result := planctas.cuenta;
      Break;
    end;
    ctasctes_creditos.Next;
  end;
end;

procedure TTctactebcos.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  planctas.conectar;
  if conexiones = 0 then Begin
    if not ctasctes_creditos.Active then ctasctes_creditos.Open;
  end;
  Inc(conexiones);

  // Chequeo de estructuras
  if not datosdb.verificarSiExisteCampo(ctasctes_creditos, 'digito') then Begin
    ctasctes_creditos.Close;
    datosdb.tranSQL('alter table ' + ctasctes_creditos.TableName + ' add digito varchar(2)');
    ctasctes_creditos.Open;
  end;
end;

procedure TTctactebcos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(ctasctes_creditos);
  end;
  planctas.desconectar;
end;

{===============================================================================}

function ctactebcos: TTctactebcos;
begin
  if xctactebcos = nil then
    xctactebcos := TTctactebcos.Create;
  Result := xctactebcos;
end;

{===============================================================================}

initialization

finalization
  xctactebcos.Free;

end.
