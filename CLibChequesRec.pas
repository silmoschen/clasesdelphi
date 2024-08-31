// Objetivo...: Clase que retiene los cheques recibidos por pago; heredada de Libro de Bancos

unit CLibChequesRec;

interface

uses CLibroBcos, CBancos, SysUtils, DB, DBTables, CIDBFM;

type

TTChequesRecibidos = class(TTLBancos)
 public
  { Declaraciones Públicas }
  constructor Create(xcodbanco, xtcomprob, xtipomov, xfecha, xfecobro, xpagado, xconcepto, xtipoper: string; xmonto: real; xtipocheque: byte);
  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
end;

function cheqrec: TTChequesRecibidos;

implementation

var
  xcheqrec: TTChequesRecibidos = nil;

constructor TTChequesRecibidos.Create(xCodbanco, xTcomprob, xTipomov, xFecha, xFecobro, xPagado, xConcepto, xtipoper: string; xMonto: real; xtipocheque: byte);
begin
  inherited Create(xCodbanco, xTcomprob, xTipomov, xFecha, xFecobro, xPagado, xConcepto, xtipoper, xMonto, xtipocheque);
  tlbco := datosdb.openDB('chequesrec', 'Clavecta;Tcomprob;Tipomov'); // Sobrecargamos la tabla de persistencia
end;

destructor TTChequesRecibidos.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function cheqrec: TTChequesRecibidos;
begin
  if xcheqrec = nil then
    xcheqrec := TTChequesRecibidos.Create('', '', '', '', '', '', '', '', 0, 0);
  Result := xcheqrec;
end;

{===============================================================================}

initialization

finalization
  xcheqrec.Free;

end.
