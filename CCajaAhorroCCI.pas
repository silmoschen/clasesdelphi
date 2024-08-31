unit CCajaAhorroCCI;

interface

uses CTransaccionesBancariasCIC, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTCajaAhorro = class(TTransaccionBancaria)
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

function cajaahorrobanco: TTCajaAhorro;

implementation

var
  xcajaahorrobanco: TTCajaAhorro = nil;

constructor TTCajaAhorro.Create;
begin
  tabla := datosdb.openDB('transaccajahorro', '');
end;

destructor TTCajaAhorro.Destroy;
begin
  inherited Destroy;
end;

procedure TTCajaAhorro.ListarTransacciones(xdesde, xhasta, xcuenta, xbanco: String; salida: char);
// Objetivo...: Listar Movimientos
begin
  inherited ListarTransacciones(xdesde, xhasta, xcuenta, xbanco, 'Operaciones en Caja de Ahorro', salida);
end;

procedure TTCajaAhorro.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited conectar;
  if conexiones = 0 then Begin
  end;
  Inc(conexiones);
end;

procedure TTCajaAhorro.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
  Dec(conexiones);
  if conexiones = 0 then Begin
  end;
end;

{===============================================================================}

function cajaahorrobanco: TTCajaAhorro;
begin
  if xcajaahorrobanco = nil then
    xcajaahorrobanco := TTCajaAhorro.Create;
  Result := xcajaahorrobanco;
end;

{===============================================================================}

initialization

finalization
  xcajaahorrobanco.Free;

end.
