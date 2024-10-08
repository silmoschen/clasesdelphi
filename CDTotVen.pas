unit CDTotVen;

interface

uses CDTotFact, CccteclSimple, CFactVentaNormal, CFactCheV, SysUtils, DB, DBTables, CUtiles, CIDBFM;

type

TTCTotFact = class(TTCDTotFact)
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Depurar(xtipoOperacion: string);
 private
  { Declaraciones Privadas }
end;

function vtotfact: TTCTotFact;

implementation

var
  xvtotfact: TTCTotFact = nil;

constructor TTCTotFact.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('distvent', 'idc;tipo;sucursal;numero;cuit');
end;

destructor TTCTotFact.Destroy;
begin
  inherited Destroy;
end;

procedure TTCTotFact.Depurar(xtipoOperacion: string);
// Objetivo...: Verificar y eliminar las instancias sin conexi�n
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
     if not cccls.BuscarRecibo(r.FieldByName('idc').AsString, r.FieldByName('tipo').AsString, r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString) then Begin
       // Si la instancia no existe, eliminamos la dependencias - 1� Caja
       BorrarInstanciaCaja(r.FieldByName('periodo').AsString, r.FieldByName('nroplanilla').AsString, r.FieldByName('codcta').AsString, r.FieldByName('nroitems').AsString, r.FieldByName('tipomov').AsString); // Movimientos de Caja

       // 2 � Cheques recibidos como parte de pago
       refercfv.Borrar(r.FieldByName('idc').AsString, r.FieldByName('tipo').AsString, r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString, r.FieldByName('cuit').AsString);

       tabla.Delete;  // Instancia propia de la clase
     end;

    //--------------------------------------------------------------------------
    // Testeo Operaciones de Facturaci�n
    if xtipoOperacion = 'V' then     // FACTURACI�N
     if r.FieldByName('tipoper').AsString = xtipoOperacion then
     if not factventa.BuscarCab(r.FieldByName('idc').AsString, r.FieldByName('tipo').AsString, r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString) then Begin
       // Si la instancia no existe, eliminamos la dependencias - 1� Caja
       BorrarInstanciaCaja(r.FieldByName('periodo').AsString, r.FieldByName('nroplanilla').AsString, r.FieldByName('codcta').AsString, r.FieldByName('nroitems').AsString, r.FieldByName('tipomov').AsString); // Movimientos de Caja

       // 2 � Cheques recibidos como parte de pago
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

function vtotfact: TTCTotFact;
begin
  if xvtotfact = nil then
    xvtotfact := TTCTotFact.Create;
  Result := xvtotfact;
end;

{===============================================================================}

initialization

finalization
  xvtotfact.Free;

end.