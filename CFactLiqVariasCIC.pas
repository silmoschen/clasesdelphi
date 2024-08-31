unit CFactLiqVariasCIC;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CFactCIC,
     CCtaCteBancariaCCI, CCajaAhorroCCI;

type

TTFactLVCIC = class(TTFact)
  Fechadist, Codclidist, Codcta1, Codcta2, Codbco1, Codbco2: string;
  Efectivo, Cajaahorro, Ctacte: real;
  distribucion: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   EstablecerMovCaja(xcodmov: String);
  function    getMovCaja: String;
  function    verificarMovCaja: Boolean;

  function    BuscarDist(xidc, xtipo, xsucursal, xnumero: String): boolean;
  procedure   RegistrarDist(xidc, xtipo, xsucursal, xnumero, xfecha, xcodcli, xcodcta1, xcodbco1, xcodcta2, xcodbco2: String; xefectivo, xcajaahorro, xctacte: real);
  procedure   getDatosDist(xidc, xtipo, xsucursal, xnumero: String);
  procedure   BorrarDist(xidc, xtipo, xsucursal, xnumero: String);

  procedure   RegistrarTransacCtaCte(xidc, xtipo, xsucursal, xnumero, xtransaccion: String);
  procedure   AnularTransacCtaCte(xidc, xtipo, xsucursal, xnumero: String);
  function    getTransacCtaCte(xidc, xtipo, xsucursal, xnumero: String): string;

  procedure   conectar;
  procedure   desconectar;
 private
  movcaja: TTable;
  conexiones: Integer;
  { Declaraciones Privadas }
end;

function factlv: TTFactLVCIC;

implementation

var
  xfactlv: TTFactLVCIC = nil;

constructor TTFactLVCIC.Create;
begin
  cabfact      := datosdb.openDB('cabfact_liqv', '');
  detfact      := datosdb.openDB('detfact_liqv', '');
  movcaja      := datosdb.openDB('movcaja', '');
  distribucion := datosdb.openDB('distribucion', '');
end;

destructor TTFactLVCIC.Destroy;
begin
  inherited Destroy;
end;

procedure TTFactLVCIC.EstablecerMovCaja(xcodmov: String);
// Objetivo...: establecer movimiento de caja
begin
  if movcaja.FindKey(['01']) then movcaja.Edit else movcaja.Append;
  movcaja.FieldByName('items').AsString  := '01';
  movcaja.FieldByName('codmov').AsString := xcodmov;
  try
    movcaja.Post
   except
    movcaja.Cancel
  end;
  datosdb.closeDB(movcaja); movcaja.Open;
end;

function  TTFactLVCIC.getMovCaja: String;
// Objetivo...: recuperr movimiento de caja
begin
  if movcaja.FindKey(['01']) then Result := movcaja.FieldByName('codmov').AsString else Result := '';
end;

function  TTFactLVCIC.verificarMovCaja: Boolean;
// Objetivo...: comprobar movimiento de caja
begin
  if movcaja.FindKey(['01']) then Result := True else Result := False;
end;

function  TTFactLVCIC.BuscarDist(xidc, xtipo, xsucursal, xnumero: String): boolean;
// Objetivo...: Buscar Instancia
begin
  result := datosdb.Buscar(distribucion, 'idc', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero);
end;

procedure TTFactLVCIC.RegistrarDist(xidc, xtipo, xsucursal, xnumero, xfecha, xcodcli, xcodcta1, xcodbco1, xcodcta2, xcodbco2: String; xefectivo, xcajaahorro, xctacte: real);
// Objetivo...: Registrar instancia
begin
  if BuscarDist(xidc, xtipo, xsucursal, xnumero) then distribucion.Edit else distribucion.Append;
  distribucion.FieldByName('idc').AsString       := xidc;
  distribucion.FieldByName('tipo').AsString      := xtipo;
  distribucion.FieldByName('sucursal').AsString  := xsucursal;
  distribucion.FieldByName('numero').AsString    := xnumero;
  distribucion.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  distribucion.FieldByName('codcli').AsString    := xcodcli;
  distribucion.FieldByName('efectivo').AsFloat   := xefectivo;
  distribucion.FieldByName('cajaahorro').AsFloat := xcajaahorro;
  distribucion.FieldByName('ctacte').AsFloat     := xctacte;
  distribucion.FieldByName('codcta1').AsString   := xcodcta1;
  distribucion.FieldByName('codbco1').AsString   := xcodbco1;
  distribucion.FieldByName('codcta2').AsString   := xcodcta2;
  distribucion.FieldByName('codbco2').AsString   := xcodbco2;
  try
    distribucion.Post
  except
    distribucion.Cancel
  end;
  datosdb.closeDB(distribucion); distribucion.Open;
end;

procedure TTFactLVCIC.getDatosDist(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: Recuperar los datos de una instancia
begin
 if BuscarDist(xidc, xtipo, xsucursal, xnumero) then begin
   idc        := distribucion.FieldByName('idc').AsString;
   tipo       := distribucion.FieldByName('tipo').AsString;
   sucursal   := distribucion.FieldByName('sucursal').AsString;
   numero     := distribucion.FieldByName('numero').AsString;
   fechadist  := utiles.sFormatoFecha(distribucion.FieldByName('fecha').AsString);
   efectivo   := distribucion.FieldByName('efectivo').AsFloat;
   cajaahorro := distribucion.FieldByName('cajaahorro').AsFloat;
   ctacte     := distribucion.FieldByName('ctacte').AsFloat;
   codcta1    := distribucion.FieldByName('codcta1').AsString;
   codbco1    := distribucion.FieldByName('codbco1').AsString;
   codcta2    := distribucion.FieldByName('codcta2').AsString;
   codbco2    := distribucion.FieldByName('codbco2').AsString;
 end else begin
   fechadist := ''; codclidist := ''; efectivo := 0; cajaahorro := 0; ctacte := 0;
   codcta1 := ''; codbco1 := ''; codcta2 := ''; codbco2 := '';
 end;
end;

procedure TTFactLVCIC.BorrarDist(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: borrar una instancia
begin
  if BuscarDist(xidc, xtipo, xsucursal, xnumero) then begin
    distribucion.Delete;
    datosdb.closeDB(distribucion); distribucion.Open;
  end;
end;

procedure TTFactLVCIC.RegistrarTransacCtaCte(xidc, xtipo, xsucursal, xnumero, xtransaccion: String);
// Objetivo...: registrar transaccion en cta cte
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero) then begin
    cabfact.Edit;
    cabfact.FieldByName('transaccion').AsString := xtransaccion;
    cabfact.FieldByName('liquidado').AsString   := 'S';
    try
      cabfact.Post
    except
      cabfact.cancel
    end;
    datosdb.closeDB(cabfact); cabfact.Open;
  end;
end;

procedure TTFactLVCIC.AnularTransacCtaCte(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: anular transaccion en cta cte
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero) then begin
    cabfact.Edit;
    cabfact.FieldByName('transaccion').AsString := '';
    cabfact.FieldByName('liquidado').AsString   := 'N';
    try
      cabfact.Post
    except
      cabfact.cancel
    end;
    datosdb.closeDB(cabfact); cabfact.Open;
  end;
end;

function TTFactLVCIC.getTransacCtaCte(xidc, xtipo, xsucursal, xnumero: String): string;
// Objetivo...: devolver transaccion en cta cte
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero) then result := cabfact.FieldByName('transaccion').AsString else result := '';
end;

procedure TTFactLVCIC.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited conectar;
  ctactebanco.conectar;
  cajaahorrobanco.conectar;
  if conexiones = 0 then Begin
    if not movcaja.Active then movcaja.Open;
    if not distribucion.Active then distribucion.Open;
  end;
end;

procedure TTFactLVCIC.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
  ctactebanco.desconectar;
  cajaahorrobanco.desconectar;
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(movcaja);
    datosdb.closeDB(distribucion);
  end;
end;

{===============================================================================}

function factlv: TTFactLVCIC;
begin
  if xfactlv = nil then
    xfactlv := TTFactLVCIC.Create;
  Result := xfactlv;
end;

{===============================================================================}

initialization

finalization
  xfactlv.Free;

end.
