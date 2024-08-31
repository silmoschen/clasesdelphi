unit CCtaCteObrasSocialesCCB;

interface

uses CObrasSocialesCCB, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes, CBancosCentroBioq;

type

TTCtaCteCCB = class
  Codos, Sucursal, Numero, Fecha, Fechavto1, Fechavto2, Fechavtou, Concepto: String; Monto, Recargo1vto, Recargo2vto: Real;
  Codosp, Fechap, Sucursalp, Numerop, Conceptop: String; Montop: Real;
  ExisteFactura: Boolean;
  facturas, pagos, recibos, cheques: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  { Facturas }
  function    BuscarFactura(xcodos, xsucursal, xnumero: String): Boolean;
  procedure   RegistrarFactura(xcodos, xsucursal, xnumero, xfecha, xfechavto1, xfechavto2, xfechavtou, xconcepto: String; xmonto, xrecargovto1, xrecargovto2: Real);
  procedure   BorrarFactura(xcodos, xsucursal, xnumero: String);
  function    setFacturas(xcodos: String): TStringList;
  procedure   getDatos(xcodos, xsucursal, xnumero: String);

  { Pagos }
  function    BuscarPago(xcodos, xsucursal, xnumero: String): Boolean;
  procedure   RegistrarPago(xcodos, xsucursal, xnumero, xfecha, xconcepto: String; xpago: Real);
  procedure   getDatosPago(xcodos, xsucursal, xnumero: String);
  function    setPagos(xcodos: String): TStringList;

  { Recibos }
  function    BuscarRecibo(xsucursal, xnumero: String): Boolean;
  procedure   RegistrarRecibo(xsucursal, xnumero: String);
  procedure   BorrarRecibo(xsucursal, xnumero: String);
  function    NuevoRecibo(xsucursal: String): String;

  { Cheques }
  function    BuscarCheque(xsucursal, xnumero, xitems: String): Boolean;
  procedure   RegistrarCheques(xsucursal, xnumero, xitems, xnrocheque, xcodbanco, xfecha, xconcepto: String; xmonto: Real; xcantitems: Integer);
  procedure   BorrarCheques(xsucursal, xnumero: String);
  function    setCheques(xsucursal, xnumero: String): TStringList;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  base_datos: String;
end;

function ctacteccb: TTCtaCteCCB;

implementation

var
  xctacteccb: TTCtaCteCCB = nil;

constructor TTCtaCteCCB.Create;
begin
  if dbs.BaseClientServ = 'N' then base_datos := dbs.DirSistema + '\ctacte_obsocial' else base_datos := 'ctacte_obsocial';
  base_datos := dbs.DirSistema + '\ctacte_obsocial';

  facturas := datosdb.openDB('facturas', '', '', base_datos);
  pagos    := datosdb.openDB('pagos', '', '', base_datos);
  recibos  := datosdb.openDB('recibos', '', '', base_datos);
  cheques  := datosdb.openDB('cheques', '', '', base_datos);
end;

destructor TTCtaCteCCB.Destroy;
begin
  inherited Destroy;
end;

function  TTCtaCteCCB.BuscarFactura(xcodos, xsucursal, xnumero: String): Boolean;
Begin
  if facturas.IndexFieldNames <> 'codos;sucursal;numero' then facturas.IndexFieldNames := 'codos;sucursal;numero';
  ExisteFactura := datosdb.Buscar(facturas, 'codos', 'sucursal', 'numero', xcodos, xsucursal, xnumero);
  Result        := ExisteFactura;
end;

procedure TTCtaCteCCB.RegistrarFactura(xcodos, xsucursal, xnumero, xfecha, xfechavto1, xfechavto2, xfechavtou, xconcepto: String; xmonto, xrecargovto1, xrecargovto2: Real);
Begin
  if not BuscarFactura(xcodos, xsucursal, xnumero) then facturas.Append else facturas.Edit;
  facturas.FieldByName('codos').AsString      := xcodos;
  facturas.FieldByName('sucursal').AsString   := xsucursal;
  facturas.FieldByName('numero').AsString     := xnumero;
  facturas.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfecha);
  facturas.FieldByName('fechavto1').AsString  := utiles.sExprFecha2000(xfechavto1);
  facturas.FieldByName('fechavto2').AsString  := utiles.sExprFecha2000(xfechavto2);
  facturas.FieldByName('fechavtou').AsString  := utiles.sExprFecha2000(xfechavtou);
  facturas.FieldByName('concepto').AsString   := xconcepto;
  facturas.FieldByName('monto').AsFloat       := xmonto;
  facturas.FieldByName('recargovto1').AsFloat := xrecargovto1;
  facturas.FieldByName('recargovto2').AsFloat := xrecargovto2;
  try
    facturas.Post
   except
    facturas.Cancel
  end;
  datosdb.refrescar(facturas);
end;

procedure TTCtaCteCCB.BorrarFactura(xcodos, xsucursal, xnumero: String);
// Objetivo...: Borrar un Pago
Begin
  if BuscarFactura(xcodos, xsucursal, xnumero) then facturas.Delete;
  datosdb.refrescar(facturas);
end;

function  TTCtaCteCCB.setFacturas(xcodos: String): TStringList;
// Objetivo...: Devolver un StringList
var
  lista: TStringList;
Begin
  facturas.IndexFieldNames := 'Codos;fecha';
  datosdb.Filtrar(facturas, 'codos = ' + xcodos);
  facturas.First; lista := TStringList.Create;
  while not facturas.Eof do Begin
    lista.Add(utiles.sFormatoFecha(facturas.FieldByName('fecha').AsString) + facturas.FieldByName('sucursal').AsString + facturas.FieldByName('numero').AsString + utiles.FormatearNumero(facturas.FieldByName('monto').AsString) + ';1' + facturas.FieldByName('concepto').AsString + ';2' +
              utiles.sFormatoFecha(facturas.FieldByName('fechavto1').AsString) + utiles.sFormatoFecha(facturas.FieldByName('fechavto2').AsString) + utiles.sFormatoFecha(facturas.FieldByName('fechavtou').AsString) +
              utiles.FormatearNumero(facturas.FieldByName('recargovto1').AsString) + ';3' + utiles.FormatearNumero(facturas.FieldByName('recargovto2').AsString));
    facturas.Next;
    if lista.Count >= 300 then Break;
  end;
  datosdb.QuitarFiltro(facturas);
  Result := lista;
end;

procedure TTCtaCteCCB.getDatos(xcodos, xsucursal, xnumero: String);
// Objetivo...: Recuperar una instancia
Begin
  if BuscarFactura(xcodos, xsucursal, xnumero) then Begin
    Codos := xcodos;
    Sucursal    := xsucursal;
    Numero      := xnumero;
    Fecha       := utiles.sFormatoFecha(facturas.FieldByName('fecha').AsString);
    Fechavto1   := utiles.sFormatoFecha(facturas.FieldByName('fechavto1').AsString);
    Fechavto2   := utiles.sFormatoFecha(facturas.FieldByName('fechavto2').AsString);
    Fechavtou   := utiles.sFormatoFecha(facturas.FieldByName('fechavtou').AsString);
    Concepto    := facturas.FieldByName('concepto').AsString;
    Monto       := facturas.FieldByname('monto').AsFloat;
    Recargo1vto := facturas.FieldByname('recargovto1').AsFloat;
    Recargo2vto := facturas.FieldByname('recargovto2').AsFloat;
  end else Begin
    Codos := ''; Sucursal := ''; Numero := ''; Fecha := ''; fechavto1 := ''; Fechavto2 := ''; Fechavtou := ''; Concepto := ''; Monto := 0; Recargo1vto := 0; Recargo2vto := 0;
  end;
end;

function  TTCtaCteCCB.BuscarPago(xcodos, xsucursal, xnumero: String): Boolean;
// Objetivo...: Buscar Pago
Begin
  Result := datosdb.Buscar(pagos, 'codos', 'sucursal', 'numero', xcodos, xsucursal, xnumero);
end;

procedure TTCtaCteCCB.RegistrarPago(xcodos, xsucursal, xnumero, xfecha, xconcepto: String; xpago: Real);
// Objetivo...: Registrar Pago
Begin
  if BuscarPago(xcodos, xsucursal, xnumero) then pagos.Edit else pagos.Append;
  pagos.FieldByName('codos').AsString    := xcodos;
  pagos.FieldByName('sucursal').AsString := xsucursal;
  pagos.FieldByName('numero').AsString   := xnumero;
  pagos.FieldByName('fecha').AsString    := utiles.sExprFecha2000(xfecha);
  pagos.FieldByName('concepto').AsString := xconcepto;
  pagos.FieldByName('pago').AsFloat      := xpago;
  try
    pagos.Post
   except
    pagos.Cancel
  end;
  datosdb.refrescar(pagos);
  RegistrarRecibo(xsucursal, xnumero);
end;

procedure  TTCtaCteCCB.getDatosPago(xcodos, xsucursal, xnumero: String);
// Objetivo...: Recuperar un pago
Begin
  if BuscarPago(xcodos, xsucursal, xnumero) then Begin
    codosp    := xcodos;
    sucursalp := xsucursal;
    numerop   := xnumero;
    fechap    := utiles.sFormatoFecha(pagos.FieldByName('fecha').AsString);
    conceptop := pagos.FieldByName('concepto').AsString;
    montop    := pagos.FieldByName('pago').AsFloat;
  end else Begin
    codosp := ''; sucursalp := ''; numerop := ''; fechap := ''; conceptop := ''; montop := 0;
  end;
end;

function TTCtaCteCCB.setPagos(xcodos: String): TstringList;
// Objetivo...: Devolver una Lista con los Pagos
var
  l: TStringList;
Begin
  l := TStringList.Create;
  datosdb.Filtrar(pagos, 'codos = ' + xcodos);
  pagos.IndexFieldNames := 'codos;fecha';
  pagos.First;
  while not pagos.Eof do Begin
    l.Add(pagos.FieldByName('sucursal').AsString + pagos.FieldByName('numero').AsString + pagos.FieldByName('fecha').AsString + pagos.FieldByName('pago').AsString + ';1' + pagos.FieldByName('concepto').AsString);
    pagos.Next;
    if l.Count >= 300 then Break;
  end;
  datosdb.QuitarFiltro(pagos);
  pagos.IndexFieldNames := 'codos;sucursal;numero';
  Result := l;
end;

function  TTCtaCteCCB.BuscarRecibo(xsucursal, xnumero: String): Boolean;
// Objetivo...: Buscar Recibo
Begin
  if recibos.IndexFieldNames <> 'Sucursal;Numero' then recibos.IndexFieldNames := 'Sucursal;Numero';
  Result := datosdb.Buscar(recibos, 'sucursal', 'numero', xsucursal, xnumero);
end;

procedure TTCtaCteCCB.RegistrarRecibo(xsucursal, xnumero: String);
// Objetivo...: Registrar Recibo
Begin
  if not BuscarRecibo(xsucursal, xnumero) then Begin
    recibos.Append;
    recibos.FieldByName('sucursal').AsString := xsucursal;
    recibos.FieldByName('numero').AsString   := xnumero;
    try
      recibos.Post
     except
      recibos.Cancel
    end;
    datosdb.closeDB(recibos);
  end;
end;

procedure TTCtaCteCCB.BorrarRecibo(xsucursal, xnumero: String);
// Objetivo...: Borrar Recibo
Begin
  if BuscarRecibo(xsucursal, xnumero) then recibos.Delete;
end;

function  TTCtaCteCCB.NuevoRecibo(xsucursal: String): String;
// Objetivo...: Nuevo Recibo
Begin
  recibos.IndexFieldNames := 'numero';
  if Length(Trim(xsucursal)) > 0 then datosdb.Filtrar(recibos, 'sucursal = ' + xsucursal);
  recibos.Last;
  if recibos.RecordCount = 0 then Result := xsucursal + '00000001' else Result := xsucursal + utiles.sLlenarIzquierda(IntToStr(recibos.FieldByName('numero').AsInteger + 1), 8, '0');
  datosdb.QuitarFiltro(recibos);
  recibos.IndexFieldNames := 'Sucursal;Numero';
end;

function  TTCtaCteCCB.BuscarCheque(xsucursal, xnumero, xitems: String): Boolean;
// Objetivo...: Buscar Cheque
Begin
  Result := datosdb.Buscar(cheques, 'sucursal', 'numero', 'items', xsucursal, xnumero, xitems);
end;

procedure TTCtaCteCCB.RegistrarCheques(xsucursal, xnumero, xitems, xnrocheque, xcodbanco, xfecha, xconcepto: String; xmonto: Real; xcantitems: Integer);
// Objetivo...: Registrar Cheques
Begin
  if BuscarCheque(xsucursal, xnumero, xitems) then cheques.Edit else cheques.Append;
  cheques.FieldByName('sucursal').AsString  := xsucursal;
  cheques.FieldByName('numero').AsString    := xnumero;
  cheques.FieldByName('items').AsString     := xitems;
  cheques.FieldByName('nrocheque').AsString := xnrocheque;
  cheques.FieldByName('codbanco').AsString  := xcodbanco;
  cheques.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  cheques.FieldByName('concepto').AsString  := xconcepto;
  cheques.FieldByName('monto').AsFloat      := xmonto;
  try
    cheques.Post
   except
    cheques.Cancel
  end;
  if StrToInt(xitems) = xcantitems then datosdb.tranSQL(base_datos, 'delete from cheques where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"' + ' and items > ' + '"' + xitems + '"');
end;

procedure TTCtaCteCCB.BorrarCheques(xsucursal, xnumero: String);
// Objetivo...: Borrar Cheques
Begin
  datosdb.tranSQL(base_datos, 'delete from cheques where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"');
end;

function  TTCtaCteCCB.setCheques(xsucursal, xnumero: String): TStringList;
// Objetivo...: devolver una lista de cheques
var
  l: TStringList;
  n: String;
Begin
  BuscarCheque(xsucursal, xnumero, '01');
  n := cheques.FieldByName('numero').AsString;
  l := TStringList.Create;
  while not cheques.Eof do Begin
    l.Add(cheques.FieldByName('items').AsString + cheques.FieldByName('nrocheque').AsString + cheques.FieldByName('codbanco').AsString + utiles.sFormatoFecha(cheques.FieldByName('fecha').AsString) + cheques.FieldByName('monto').AsString + ';1' + cheques.FieldByName('concepto').AsString);
    cheques.Next;
    if cheques.FieldByName('numero').AsString <> n then Break;
  end;
  Result := l;
end;

procedure TTCtaCteCCB.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  obsocial.conectar;
  entbcos.conectar;
  if conexiones = 0 then Begin
    if not facturas.Active then facturas.Open;
    facturas.FieldByname('codos').Visible := False;
    facturas.FieldByName('sucursal').DisplayLabel := 'Suc.'; facturas.FieldByName('numero').DisplayLabel := 'Número'; facturas.FieldByName('monto').DisplayLabel := 'Monto Fact.'; facturas.FieldByName('concepto').DisplayLabel := 'Concepto Operación';
    if not pagos.Active then pagos.Open;
    if not recibos.Active then recibos.Open;
    if not cheques.Active then cheques.Open;
  end;
  Inc(conexiones);
end;

procedure TTCtaCteCCB.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  obsocial.desconectar;
  entbcos.desconectar;
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(facturas);
    datosdb.closeDB(pagos);
    datosdb.closeDB(recibos);
    datosdb.closeDB(cheques);
  end;
end;

{===============================================================================}

function ctacteccb: TTCtaCteCCB;
begin
  if xctacteccb = nil then
    xctacteccb := TTCtaCteCCB.Create;
  Result := xctacteccb;
end;

{===============================================================================}

initialization

finalization
  xctacteccb.Free;

end.
