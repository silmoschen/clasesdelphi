unit CDTotFact;

interface

uses SysUtils, DB, DBTables, CUtiles, CIDBFM, CCaja;

type

TTCDTotFact = class(TObject)
  idc, tipo, sucursal, numero, cuit, clavecta, tipomov, fecha, periodo, nroplanilla, codcta, nroitems, idtit, tipoper: string;
  monto1, monto2, monto3, monto4, monto5: real;
  existf: boolean;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xidc, xtipo, xsucursal, xnumero, xcuit: string): boolean;
  procedure   Grabar(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta: string; xmonto1, xmonto2, xmonto3, xmonto4, xmonto5: real;
                     xfecha, xtipomov, xidtit, xtipoper, xconceptoCaja, xrsocial, xcodcta: string);
  procedure   Borrar(xidc, xtipo, xsucursal, xnumero, xcuit: string);
  procedure   getDatos(xidc, xtipo, xsucursal, xnumero, xcuit: string);
  function    setTransaccionesReg: TQuery;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
 protected
  { Declaraciones Protegidas }
  procedure BorrarInstanciaCaja(xperiodo, xnroplanilla, xcodcta, xnroitems, xtipomov: string);
end;

function dtotfact: TTCDTotFact;

implementation

var
  xdtotfact: TTCDTotFact = nil;

constructor TTCDTotFact.Create;
begin
  inherited Create;
end;

destructor TTCDTotFact.Destroy;
begin
  inherited Destroy;
end;

function TTCDTotFact.Buscar(xidc, xtipo, xsucursal, xnumero, xcuit: string): boolean;
// Objetivo...: Buscar objeto
begin
  existf := datosdb.Buscar(tabla, 'idc', 'tipo', 'sucursal', 'numero', 'cuit', xidc, xtipo, xsucursal, xnumero, xcuit);
  Result := existf;
end;

procedure TTCDTotFact.Grabar(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta: string; xmonto1, xmonto2, xmonto3, xmonto4, xmonto5: real;
                             xfecha, xtipomov, xidtit, xtipoper, xconceptoCaja, xrsocial, xcodcta: string);
// Objetivo...: Grabar atributos en tabla de Persistencia
var
 p, it, np: string;
begin
  if not Buscar(xidc, xtipo, xsucursal, xnumero, xcuit) then Begin
    p  := Copy(utiles.sExprFecha(xfecha), 5, 2) + '/' + Copy(utiles.sExprFecha(xfecha), 1, 4);
    it := utiles.sLlenarIzquierda(caja.NuevoItems(p), 5, '0');
    np := '-' + utiles.sLLenarIzquierda(Copy(xfecha, 1, 2), 3, '0');
  end else Begin
    p  := tabla.FieldByName('periodo').AsString;
    it := tabla.FieldByName('nroitems').AsString;
    np := tabla.FieldByName('nroplanilla').AsString;
  end;

  if Buscar(xidc, xtipo, xsucursal, xnumero, xcuit) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idc').AsString          := xidc;
  tabla.FieldByName('tipo').AsString         := xtipo;
  tabla.FieldByName('sucursal').AsString     := xsucursal;
  tabla.FieldByName('numero').AsString       := xnumero;
  tabla.FieldByName('cuit').AsString         := xcuit;
  tabla.FieldByName('clavecta').AsString     := xclavecta;
  tabla.FieldByName('monto1').AsFloat        := xMonto1;
  tabla.FieldByName('monto2').AsFloat        := xMonto2;
  tabla.FieldByName('monto3').AsFloat        := xMonto3;
  tabla.FieldByName('monto4').AsFloat        := xMonto4;
  tabla.FieldByName('monto5').AsFloat        := xMonto5;
  tabla.FieldByName('fecha').AsString        := utiles.sExprFecha(xfecha);
  tabla.FieldByName('tipomov').AsString      := xtipomov;
  tabla.FieldByName('periodo').AsString      := p;
  tabla.FieldByName('nroplanilla').AsString  := np;
  tabla.FieldByName('nroitems').AsString     := it;
  tabla.FieldByName('idtit').AsString        := xidtit;
  tabla.FieldByName('tipoper').AsString      := xtipoper;
  tabla.FieldByName('codcta').AsString       := xcodcta;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;

  if xMonto1 > 0 then caja.Grabar(p, np, '', it, xtipomov, xfecha, xconceptoCaja, xrsocial, xMonto1) else
    caja.Borrar(tabla.FieldByName('periodo').AsString, tabla.FieldByName('nroplanilla').AsString, tabla.FieldByName('codcta').AsString, tabla.FieldByName('nroitems').AsString, tabla.FieldByName('tipomov').AsString);
  datosdb.refrescar(tabla);
end;

procedure TTCDTotFact.Borrar(xidc, xtipo, xsucursal, xnumero, xcuit: string);
// Objetivo...: Borrar instancia
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xcuit) then Begin
    BorrarInstanciaCaja(tabla.FieldByName('periodo').AsString, tabla.FieldByName('nroplanilla').AsString, tabla.FieldByName('codcta').AsString, tabla.FieldByName('nroitems').AsString, tabla.FieldByName('tipomov').AsString);
    tabla.Delete;
  end;
end;

procedure TTCDTotFact.BorrarInstanciaCaja(xperiodo, xnroplanilla, xcodcta, xnroitems, xtipomov: string);
// Objetivo...: Borrar una instancia de la clase caja - instancia dependiente
begin
  caja.Borrar(xperiodo, xnroplanilla, xcodcta, xnroitems, xtipomov);
end;

procedure TTCDTotFact.getDatos(xidc, xtipo, xsucursal, xnumero, xcuit: string);
// Objetivo...: Cargar los atributos de un objeto
begin
  tabla.Refresh;
  if Buscar(xidc, xtipo, xsucursal, xnumero, xcuit) then Begin
    monto1      := tabla.FieldByName('monto1').AsFloat;
    monto2      := tabla.FieldByName('monto2').AsFloat;
    monto3      := tabla.FieldByName('monto3').AsFloat;
    monto4      := tabla.FieldByName('monto4').AsFloat;
    monto5      := tabla.FieldByName('monto5').AsFloat;
    clavecta    := tabla.FieldByName('clavecta').AsString;
    fecha       := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
    tipomov     := tabla.FieldByName('tipomov').AsString;
    periodo     := tabla.FieldByName('periodo').AsString;
    nroplanilla := tabla.FieldByName('nroplanilla').AsString;
    nroitems    := tabla.FieldByName('nroitems').AsString;
    idtit       := tabla.FieldByName('idtit').AsString;
    tipoper     := tabla.FieldByName('tipoper').AsString;
    codcta      := tabla.FieldByName('codcta').AsString;
  end else Begin
    monto1 := 0; monto2 := 0; monto3 := 0; monto4 := 0; monto5 := 0; clavecta := ''; tipomov := ''; periodo := ''; nroplanilla := ''; codcta := ''; nroitems := ''; idtit := ''; tipoper := ''; codcta := '';
  end;
end;

function TTCDTotFact.setTransaccionesReg: TQuery;
// Objetivo...: Devolver un set con las instancias registradas
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName);
end;

procedure TTCDTotFact.conectar;
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    caja.conectar;
  end;
  Inc(conexiones);
end;

procedure TTCDTotFact.desconectar;
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    caja.desconectar;
  end;
end;

{===============================================================================}

function dtotfact: TTCDTotFact;
begin
  if xdtotfact = nil then
    xdtotfact := TTCDTotFact.Create;
  Result := xdtotfact;
end;

{===============================================================================}

initialization

finalization
  xdtotfact.Free;

end.