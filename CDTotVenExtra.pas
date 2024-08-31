unit CDTotVenExtra;

interface

uses CDTotFact, CccteclExtra, CFactCheV, CFactVentaExtra, SysUtils, DB, DBTables, CUtiles, CIDBFM;

type

TTCTotFactExtra = class(TTCDTotFact)
 public
  { Declaraciones Públicas }
  constructor Create(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta: string; xmonto1, xmonto2, xmonto3, xmonto4, xmonto5: real);
  destructor  Destroy; override;

  procedure   Depurar(xtipoOperacion: string);
 private
  { Declaraciones Privadas }
end;

function vtotfactextra: TTCTotFactExtra;

implementation

var
  xvtotfactextra: TTCTotFactExtra = nil;

constructor TTCTotFactExtra.Create(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta: string; xmonto1, xmonto2, xmonto3, xmonto4, xmonto5: real);
begin
  inherited Create;
  tabla := datosdb.openDB('distvent2', 'idc;tipo;sucursal;numero;cuit');
end;

destructor TTCTotFactExtra.Destroy;
begin
  inherited Destroy;
end;

procedure TTCTotFactExtra.Depurar(xtipoOperacion: string);
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
     if not ccclextra.BuscarRecibo(r.FieldByName('idc').AsString, r.FieldByName('tipo').AsString, r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString) then Begin
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
     if not factvtaextra.BuscarCab(r.FieldByName('idc').AsString, r.FieldByName('tipo').AsString, r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString) then Begin
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

function vtotfactextra: TTCTotFactExtra;
begin
  if xvtotfactextra = nil then
    xvtotfactextra := TTCTotFactExtra.Create('', '', '', '', '', '', 0, 0, 0, 0, 0);
  Result := xvtotfactextra;
end;

{===============================================================================}

initialization

finalization
  xvtotfactextra.Free;

end.