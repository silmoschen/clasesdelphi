unit CCtaCteBancariaCCI;

interface

uses CTransaccionesBancariasCIC, CBDT, SysUtils, DBTables,
     CUtiles, CListar, CIDBFM, CCuentasBancariasCCE;

type

TTCtaCteBancaria = class(TTransaccionBancaria)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ListarTransacciones(xdesde, xhasta, xcuenta, xbanco: String; salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function ctactebanco: TTCtaCteBancaria;

implementation

var
  xctactebanco: TTCtaCteBancaria = nil;

constructor TTCtaCteBancaria.Create;
begin
  tabla := datosdb.openDB('transacctacte', '');
end;

destructor TTCtaCteBancaria.Destroy;
begin
  inherited Destroy;
end;

procedure TTCtaCteBancaria.ListarTransacciones(xdesde, xhasta, xcuenta, xbanco: String; salida: char);
// Objetivo...: Listar Movimientos
begin
  inherited ListarTransacciones(xdesde, xhasta, xcuenta, xbanco, 'Operaciones Cuenta Corriente Bancaria', salida);
end;

procedure TTCtaCteBancaria.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited conectar;
  if conexiones = 0 then Begin
  end;
  Inc(conexiones);
end;

procedure TTCtaCteBancaria.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
  Dec(conexiones);
  if conexiones = 0 then Begin
  end;
end;

{===============================================================================}

function ctactebanco: TTCtaCteBancaria;
begin
  if xctactebanco = nil then
    xctactebanco := TTCtaCteBancaria.Create;
  Result := xctactebanco;
end;

{===============================================================================}

initialization

finalization
  xctactebanco.Free;

end.
