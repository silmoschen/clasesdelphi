unit CDTotVenNorm;

interface

uses CDTotFact, CccteclEspecial, CFactVentaEspecial, CFactCheV, SysUtils, DB, DBTables, CUtiles, CIDBFM;

type

TTCTotFact = class(TTCDTotFact)
 public
  { Declaraciones Públicas }
  constructor Create(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta: string; xmonto1, xmonto2, xmonto3, xmonto4, xmonto5: real);
  destructor  Destroy; override;

  procedure   Depurar(xtipoOperacion: string);
 private
  { Declaraciones Privadas }
end;

function vtotfactesp: TTCTotFact;

implementation

var
  xvtotfact: TTCTotFact = nil;

constructor TTCTotFact.Create(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta: string; xmonto1, xmonto2, xmonto3, xmonto4, xmonto5: real);
begin
  inherited Create;
  tabla := datosdb.openDB('distvent1', 'idc;tipo;sucursal;numero;cuit');
end;

destructor TTCTotFact.Destroy;
begin
  inherited Destroy;
end;

procedure TTCTotFact.Depurar(xtipoOperacion: string);
// Objetivo...: Verificar y eliminar las instancias sin conexión
var
  r: TQuery;
begin
  inherited conectar;
  r := setTransaccionesReg;
  r.Open; r.First;
  while not r.EOF do Begin
    //--------------------------------------------------------------------------
    // Testeo Operaciones en c/c clientes
    if xtipoOperacion = 'C' then     // CUENTAS CORRIENTES CLIENTES
     if r.FieldByName('tipoper').AsString = xtipoOperacion then
     if not cccle.BuscarRecibo(r.FieldByName('idc').AsString, r.FieldByName('tipo').AsString, r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString) then Begin
       // Si la instancia no existe, eliminamos la dependencias - 1º Caja
       BorrarInstanciaCaja(r.FieldByName('periodo').AsString, r.FieldByName('nroplanilla').AsString, r.FieldByName('codcta').AsString, r.FieldByName('nroitems').AsString, r.FieldByName('tipomov').AsString); // Movimientos de Caja

       // 2 º Cheques recibidos como parte de pago
       refercfv.Borrar(r.FieldByName('idc').AsString, r.FieldByName('tipo').AsString, r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString, r.FieldByName('cuit').AsString);

       tabla.Delete;  // Instancia propia de la clase
     end;

    //--------------------------------------------------------------------------
    // Testeo Operaciones de Facturación
    if xtipoOperacion = 'V' then     // FACTURACIÓN
     if r.FieldByName('tipoper').AsString = xtipoOperacion then
     if not factvtaesp.BuscarCab(r.FieldByName('idc').AsString, r.FieldByName('tipo').AsString, r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString) then Begin
       // Si la instancia no existe, eliminamos la dependencias - 1º Caja
       BorrarInstanciaCaja(r.FieldByName('periodo').AsString, r.FieldByName('nroplanilla').AsString, r.FieldByName('codcta').AsString, r.FieldByName('nroitems').AsString, r.FieldByName('tipomov').AsString); // Movimientos de Caja

       // 2 º Cheques recibidos como parte de pago
       refercfv.Borrar(r.FieldByName('idc').AsString, r.FieldByName('tipo').AsString, r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString, r.FieldByName('cuit').AsString);

       tabla.Delete;  // Instancia propia de la clase
     end;
    //--------------------------------------------------------------------------

    r.Next;
  end;
  r.Close; r.Free;
  inherited desconectar;
end;

{===============================================================================}

function vtotfactesp: TTCTotFact;
begin
  if xvtotfact = nil then
    xvtotfact := TTCTotFact.Create('', '', '', '', '', '', 0, 0, 0, 0, 0);
  Result := xvtotfact;
end;

{===============================================================================}

initialization

finalization
  xvtotfact.Free;

end.