unit CDistribucionCobrosCCE;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes, Contnrs,
     CFacturasCCE_Cuotas, CFacturasCCE_Forms, CBancos, CCajaCCExterior,
     CClienteCCE;

type

TTDistribucion = class
  Idc, Tipo, Sucursal, Numero, Items, Nrocheque, Fecha, Entidad, Tipomov, FechaCheque, Codbanco, Filial, Propio, FactExento, Codmovcaja: String;
  Efectivo, Cheques, Transferencia, Retencion1, Retencion2, Monto: Real;
  distribucion, cheque, refdist, refcobros: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    BuscarDist(xidc, xtipo, xsucursal, xnumero: String): Boolean;
  procedure   RegistrarDist(xidc, xtipo, xsucursal, xnumero, xentidad, xfecha, xtipomov, xreferencia, xfactexento, xcodmovcaja: String; xefectivo, xcheques, xtransferencia: Real);
  procedure   getDatosDist(xidc, xtipo, xsucursal, xnumero: String); overload;
  procedure   BorrarDist(xidc, xtipo, xsucursal, xnumero: String); overload;
  procedure   BorrarDist(xreferencia: String); overload;
  procedure   getDatosDist(xreferencia: String); overload;

  function    BuscarCheque(xidc, xtipo, xsucursal, xnumero, xitems: String): Boolean;
  procedure   RegistrarCheque(xidc, xtipo, xsucursal, xnumero, xitems, xnrocheque, xfechacheque, xcodbanco, xfilial, xpropio, xreferencia: String; xmonto: Real; xcantitems: Integer);
  function    setDatosCheque(xidc, xtipo, xsucursal, xnumero: String): TObjectList;
  function    setDatosChequeReferencia(xreferencia: String): TObjectList;
  function    setDatosChequeContado(xidc, xtipo, xsucursal, xnumero: String): TObjectList;
  procedure   BorrarCheque(xidc, xtipo, xsucursal, xnumero: String); overload;
  procedure   BorrarCheque(xreferencia: String); overload;

  function    BuscarRefDist(xidc, xtipo, xsucursal, xnumero: String): Boolean;
  procedure   RegistrarRefDist(xidc, xtipo, xsucursal, xnumero, xreferencia: String);
  procedure   BorrarRefDist(xidc, xtipo, xsucursal, xnumero: String); overload;
  procedure   BorrarRefDist(xreferencia: String); overload;

  function    BuscarRefDistCobro(xreferencia: String): Boolean;
  procedure   RegistrarRefDistCobro(xreferencia, xfecha: String; xefectivo, xcheques, xretencion1, xretencion2: Real);
  procedure   BorrarRefDistCobro(xreferencia: String);
  procedure   getDatosRefDistCobro(xreferencia: String);

  procedure   ListarCobros(xdesde, xhasta: String; salida: char);
  procedure   ListarCheques(xdesde, xhasta: String; xbancos: TStringList; salida: char);
  procedure   ListarRetenciones(xdesde, xhasta: String; salida: char);

  procedure   TransferirOperacionesACaja(xdesde, xhasta: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  idregistro, iitems, tmov: String;
  transfiere: Boolean;
  it: Integer;
end;

function distribucion: TTDistribucion;

implementation

var
  xdistribucion: TTDistribucion = nil;

constructor TTDistribucion.Create;
begin
  distribucion := datosdb.openDB('distribucion', '');
  cheque       := datosdb.openDB('cheques', '');
  refdist      := datosdb.openDB('refdist', '');
  refcobros    := datosdb.openDB('refcobros', '');
end;

destructor TTDistribucion.Destroy;
begin
  inherited Destroy;
end;

function TTDistribucion.BuscarDist(xidc, xtipo, xsucursal, xnumero: String): Boolean;
// Objetivo...: Buscar una Instancia
begin
  Result := datosdb.Buscar(distribucion, 'idc', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero);
end;

procedure TTDistribucion.RegistrarDist(xidc, xtipo, xsucursal, xnumero, xentidad, xfecha, xtipomov, xreferencia, xfactexento, xcodmovcaja: String; xefectivo, xcheques, xtransferencia: Real);
// Objetivo...: Registrar una Instancia
begin
  if BuscarDist(xidc, xtipo, xsucursal, xnumero) then distribucion.Edit else distribucion.Append;
  distribucion.FieldByName('idc').AsString          := xidc;
  distribucion.FieldByName('tipo').AsString         := xtipo;
  distribucion.FieldByName('sucursal').AsString     := xsucursal;
  distribucion.FieldByName('numero').AsString       := xnumero;
  distribucion.FieldByName('entidad').AsString      := xentidad;
  distribucion.FieldByName('fecha').AsString        := utiles.sExprFecha2000(xfecha);
  distribucion.FieldByName('tipomov').AsString      := xtipomov;
  distribucion.FieldByName('referencia').AsString   := xreferencia;
  distribucion.FieldByName('factexento').AsString   := xfactexento;
  distribucion.FieldByName('codmovcaja').AsString   := xcodmovcaja;
  distribucion.FieldByName('efectivo').AsFloat      := xefectivo;
  distribucion.FieldByName('cheques').AsFloat       := xcheques;
  distribucion.FieldByName('transferencia').AsFloat := xtransferencia;
  try
    distribucion.Post
   except
    distribucion.Cancel
  end;
  datosdb.closeDB(distribucion); distribucion.Open;
end;

procedure TTDistribucion.getDatosDist(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: Recuperar una Instancia
begin
  if BuscarDist(xidc, xtipo, xsucursal, xnumero) then Begin
    idc           := distribucion.FieldByName('idc').AsString;
    tipo          := distribucion.FieldByName('tipo').AsString;
    sucursal      := distribucion.FieldByName('sucursal').AsString;
    numero        := distribucion.FieldByName('numero').AsString;
    fecha         := utiles.sFormatoFecha(distribucion.FieldByName('fecha').AsString);
    tipomov       := distribucion.FieldByName('tipomov').AsString;
    factexento    := distribucion.FieldByName('factexento').AsString;
    codmovcaja    := distribucion.FieldByName('codmovcaja').AsString;
    efectivo      := distribucion.FieldByName('efectivo').AsFloat;
    cheques       := distribucion.FieldByName('cheques').AsFloat;
    transferencia := distribucion.FieldByName('transferencia').AsFloat;
  end else Begin
    idc := ''; tipo := ''; sucursal := ''; numero := ''; fecha := ''; tipomov := ''; efectivo := 0; cheques := 0; transferencia := 0;
    factexento := 'N'; codmovcaja := '';
  end;
end;

procedure TTDistribucion.getDatosDist(xreferencia: String);
// Objetivo...: Recuperar una Instancia
begin
  distribucion.IndexFieldNames := 'referencia';
  if distribucion.FindKey([xreferencia]) then Begin
    idc      := distribucion.FieldByName('idc').AsString;
    tipo     := distribucion.FieldByName('tipo').AsString;
    sucursal := distribucion.FieldByName('sucursal').AsString;
    numero   := distribucion.FieldByName('numero').AsString;
    Entidad  := distribucion.FieldByName('entidad').AsString;
    fecha    := utiles.sFormatoFecha(distribucion.FieldByName('fecha').AsString);
    tipomov  := distribucion.FieldByName('tipomov').AsString;
    efectivo := distribucion.FieldByName('efectivo').AsFloat;
    cheques  := distribucion.FieldByName('cheques').AsFloat;
  end else Begin
    idc := ''; tipo := ''; sucursal := ''; numero := ''; fecha := ''; tipomov := '';
    entidad := ''; efectivo := 0; cheques := 0;
  end;
  distribucion.IndexFieldNames := 'idc;tipo;sucursal;numero';
end;

procedure TTDistribucion.BorrarDist(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: Borrar una Instancia
begin
  if BuscarDist(xidc, xtipo, xsucursal, xnumero) then Begin
    BorrarCheque(xidc, xtipo, xsucursal, xnumero);
    BorrarRefDist(xidc, xtipo, xsucursal, xnumero);
    distribucion.Delete;
    datosdb.closeDB(distribucion); distribucion.Open;
  end;
end;

procedure TTDistribucion.BorrarDist(xreferencia: String);
// Objetivo...: Borrar una Instancia
begin
  datosdb.tranSQL('delete from ' + distribucion.TableName + ' where referencia = ' + '''' + xreferencia + '''');
  datosdb.closeDB(distribucion); distribucion.Open;
end;

function  TTDistribucion.BuscarCheque(xidc, xtipo, xsucursal, xnumero, xitems: String): Boolean;
// Objetivo...: Buscar una Instancia
begin
  Result := datosdb.Buscar(cheque, 'idc', 'tipo', 'sucursal', 'numero', 'items', xidc, xtipo, xsucursal, xnumero, xitems);
end;

procedure TTDistribucion.RegistrarCheque(xidc, xtipo, xsucursal, xnumero, xitems, xnrocheque, xfechacheque, xcodbanco, xfilial, xpropio, xreferencia: String; xmonto: Real; xcantitems: Integer);
// Objetivo...: Registrar una Instancia
begin
  if BuscarCheque(xidc, xtipo, xsucursal, xnumero, xitems) then cheque.Edit else cheque.Append;
  cheque.FieldByName('idc').AsString        := xidc;
  cheque.FieldByName('tipo').AsString       := xtipo;
  cheque.FieldByName('sucursal').AsString   := xsucursal;
  cheque.FieldByName('numero').AsString     := xnumero;
  cheque.FieldByName('items').AsString      := xitems;
  cheque.FieldByName('nrocheque').AsString  := xnrocheque;
  cheque.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfechacheque);
  cheque.FieldByName('codbanco').AsString   := xcodbanco;
  cheque.FieldByName('filial').AsString     := xfilial;
  cheque.FieldByName('propio').AsString     := xpropio;
  cheque.FieldByName('referencia').AsString := xreferencia;
  cheque.FieldByName('monto').AsFloat       := xmonto;
  try
    cheque.Post
   except
    cheque.Cancel
  end;

  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    datosdb.tranSQL('delete from ' + cheque.TableName + ' where idc = ' + '''' + xidc + '''' + ' and tipo = ' + '''' + xtipo + '''' + ' and sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(cheque); cheque.Open;
  end;
end;

function  TTDistribucion.setDatosCheque(xidc, xtipo, xsucursal, xnumero: String): TObjectList;
// Objetivo...: Recuperar una Instancia
var
  l: TObjectList;
  objeto: TTDistribucion;
begin
  l := TObjectList.Create;
  if BuscarCheque(xidc, xtipo, xsucursal, xnumero, '01') then Begin
    while not cheque.Eof do Begin
      if (cheque.FieldByName('idc').AsString <> xidc) or (cheque.FieldByName('tipo').AsString <> xtipo) or (cheque.FieldByName('sucursal').AsString <> xsucursal) or (cheque.FieldByName('numero').AsString <> xnumero) then Break;
      //l.Add(cheque.FieldByName('items').AsString + cheque.FieldByName('nrocheque').AsString + ';1' + utiles.sFormatoFecha(cheque.FieldByName('fecha').AsString) + cheque.FieldByName('codbanco').AsString + cheque.FieldByName('filial').AsString + ';2' + cheque.FieldByName('propio').AsString + utiles.FormatearNumero(cheque.FieldByName('monto').AsString));
      objeto             := TTDistribucion.Create;
      objeto.Items       := cheque.FieldByName('items').AsString;
      objeto.Nrocheque   := cheque.FieldByName('nrocheque').AsString;
      objeto.FechaCheque := utiles.sFormatoFecha(cheque.FieldByName('fecha').AsString);
      objeto.Codbanco    := cheque.FieldByName('codbanco').AsString;
      objeto.Filial      := cheque.FieldByName('filial').AsString;
      objeto.Propio      := cheque.FieldByName('propio').AsString;
      objeto.Monto       := cheque.FieldByName('monto').AsFloat;
      l.Add(objeto);
      cheque.Next;
    end;
  end;
  Result := l;
end;

function  TTDistribucion.setDatosChequeReferencia(xreferencia: String): TObjectList;
// Objetivo...: Recuperar una Instancia
var
  l: TObjectList;
  objeto: TTDistribucion;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(cheque, 'referencia = ' + '''' + xreferencia + '''');
  cheque.First;
  while not cheque.Eof do Begin
    objeto             := TTDistribucion.Create;
    objeto.items       := cheque.FieldByName('items').AsString;
    objeto.Nrocheque   := cheque.FieldByName('nrocheque').AsString;
    objeto.FechaCheque := utiles.sFormatoFecha(cheque.FieldByName('fecha').AsString);
    objeto.Codbanco    := cheque.FieldByName('codbanco').AsString;
    objeto.Filial      := cheque.FieldByName('filial').AsString;
    objeto.Propio      := cheque.FieldByName('propio').AsString;
    objeto.Monto       := cheque.FieldByName('monto').AsFloat;
    l.Add(objeto);
    cheque.Next;
  end;
  datosdb.QuitarFiltro(cheque);
  Result := l;
end;

function TTDistribucion.setDatosChequeContado(xidc, xtipo, xsucursal, xnumero: String): TObjectList;
// Objetivo...: Recuperar una Instancia de cheques de contado
var
  l: TObjectList;
  objeto: TTDistribucion;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(cheque, 'idc = ' + '''' + xidc + '''' + ' and tipo = ' + '''' + xtipo + '''' + ' and sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''');
  cheque.First;
  while not cheque.Eof do Begin
    //l.Add(cheque.FieldByName('items').AsString + cheque.FieldByName('nrocheque').AsString + ';1' + utiles.sFormatoFecha(cheque.FieldByName('fecha').AsString) + cheque.FieldByName('codbanco').AsString + cheque.FieldByName('filial').AsString + ';2' + cheque.FieldByName('propio').AsString + utiles.FormatearNumero(cheque.FieldByName('monto').AsString));
    objeto           := TTDistribucion.Create;
    objeto           := TTDistribucion.Create;
    objeto.items     := cheque.FieldByName('items').AsString;
    objeto.Nrocheque := cheque.FieldByName('nrocheque').AsString;
    objeto.Fecha     := utiles.sFormatoFecha(cheque.FieldByName('fecha').AsString);
    objeto.Codbanco  := cheque.FieldByName('codbanco').AsString;
    objeto.Filial    := cheque.FieldByName('filial').AsString;
    objeto.Propio    := cheque.FieldByName('propio').AsString;
    objeto.Monto     := cheque.FieldByName('monto').AsFloat;
    l.Add(objeto);
    cheque.Next;
  end;
  datosdb.QuitarFiltro(cheque);
  Result := l;
end;

procedure TTDistribucion.BorrarCheque(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: Borrar una Instancia
begin
  datosdb.tranSQL('delete from ' + cheque.TableName + ' where idc = ' + '''' + xidc + '''' + ' and tipo = ' + '''' + xtipo + '''' + ' and sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''');
  datosdb.closeDB(cheque); cheque.Open;
end;

procedure TTDistribucion.BorrarCheque(xreferencia: String);
// Objetivo...: Borrar una Instancia
begin
  datosdb.tranSQL('delete from ' + cheque.TableName + ' where referencia = ' + '''' + xreferencia + '''');
  datosdb.closeDB(cheque); cheque.Open;
end;

function  TTDistribucion.BuscarRefDist(xidc, xtipo, xsucursal, xnumero: String): Boolean;
// Objetivo...: buscar instancia
begin
  Result := datosdb.Buscar(refdist, 'idc', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero);
end;

procedure TTDistribucion.RegistrarRefDist(xidc, xtipo, xsucursal, xnumero, xreferencia: String);
// Objetivo...: registrar instancia
begin
  if BuscarRefDist(xidc, xtipo, xsucursal, xnumero) then refdist.Edit else refdist.Append;
  refdist.FieldByName('idc').AsString         := xidc;
  refdist.FieldByName('tipo').AsString        := xtipo;
  refdist.FieldByName('sucursal').AsString    := xsucursal;
  refdist.FieldByName('numero').AsString      := xnumero;
  refdist.FieldByName('referencia').AsString  := xreferencia;
  try
    refdist.Post
   except
    refdist.Cancel
  end;
  datosdb.closeDB(refdist); refdist.Open;
end;

procedure TTDistribucion.BorrarRefDist(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: borrar instancia
begin
  if BuscarRefDist(xidc, xtipo, xsucursal, xnumero) then Begin
    refdist.Delete;
    datosdb.closeDB(refdist); refdist.Open;
  end;
end;

procedure TTDistribucion.BorrarRefDist(xreferencia: String);
// Objetivo...: Borrar una Instancia
begin
  datosdb.tranSQL('delete from ' + refdist.TableName + ' where referencia = ' + '''' + xreferencia + '''');
  datosdb.closeDB(refdist); refdist.Open;
end;

function TTDistribucion.BuscarRefDistCobro(xreferencia: String): Boolean;
// Objetivo...: buscar instancia
begin
  Result := refcobros.FindKey([xreferencia]);
end;

procedure TTDistribucion.RegistrarRefDistCobro(xreferencia, xfecha: String; xefectivo, xcheques, xretencion1, xretencion2: Real);
// Objetivo...: registrar instancia
begin
  if BuscarRefDistCobro(xreferencia) then refcobros.Edit else refcobros.Append;
  refcobros.FieldByName('referencia').AsString := xreferencia;
  refcobros.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfecha);
  refcobros.FieldByName('efectivo').AsFloat    := xefectivo;
  refcobros.FieldByName('cheques').AsFloat     := xcheques;
  refcobros.FieldByName('retencion1').AsFloat  := xretencion1;
  refcobros.FieldByName('retencion2').AsFloat  := xretencion2;
  try
    refcobros.Post
   except
    refcobros.Cancel
  end;
  datosdb.closeDB(refcobros); refcobros.Open;
end;

procedure TTDistribucion.BorrarRefDistCobro(xreferencia: String);
// Objetivo...: borrar instancia
begin
  if BuscarRefDistCobro(xreferencia) then Begin
    refcobros.Delete;
    datosdb.closeDB(refcobros); refcobros.Open;
  end;
end;

procedure TTDistribucion.getDatosRefDistCobro(xreferencia: String);
// Objetivo...: recuperar instancia
begin
  if BuscarRefDistCobro(xreferencia) then Begin
    efectivo   := refcobros.FieldByName('efectivo').AsFloat;
    cheques    := refcobros.FieldByName('cheques').AsFloat;
    retencion1 := refcobros.FieldByName('retencion1').AsFloat;
    retencion2 := refcobros.FieldByName('retencion2').AsFloat;
  end else Begin
    efectivo := 0; cheques := 0; retencion1 := 0; retencion2 := 0;
  end;
end;

procedure TTDistribucion.ListarCobros(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Operaciones de control
var
  l: TObjectList;
  objeto: TTDistribucion;
  objfac: TTFactura_Formularios;
  objcuo: TTFactura_Cuotas;
  total, total1, totdist: Real;
  i: Integer;

  procedure DetalleDist(xtotdist: Real);
  var
    ireg, irr: String;
  Begin
    getDatosRefDistCobro(distribucion.FieldByName('referencia').AsString);
    list.Linea(0, 0, 'Subtotal: ', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(30, list.Lineactual, '', xtotdist, 2, 'Arial, negrita, 9');

    list.Linea(32, list.Lineactual, 'Efectivo: ', 3, 'Arial, negrita, 9', salida, 'N');
    list.importe(62, list.Lineactual, '', distribucion.FieldByName('efectivo').AsFloat, 4, 'Arial, negrita, 9');
    list.Linea(64, list.Lineactual, 'Cheques: ', 5, 'Arial, negrita, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', distribucion.FieldByName('cheques').AsFloat, 6, 'Arial, negrita, 9');
    list.Linea(96, list.Lineactual, '', 7, 'Arial, negrita, 9', salida, 'S');

    list.Linea(0, 0, 'Ret. I.V.A.: ', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(30, list.Lineactual, '', retencion1, 2, 'Arial, negrita, 9');
    list.Linea(32, list.Lineactual, 'Ret. Cont.: ', 3, 'Arial, negrita, 9', salida, 'N');
    list.importe(65, list.Lineactual, '', retencion2, 4, 'Arial, negrita, 9');
    list.Linea(96, list.Lineactual, '', 5, 'Arial, negrita, 9', salida, 'S');
    totdist := 0;

    if (factura.Estado <> 'C') and (factform.Estado <> 'C') then total1 := total1 + (retencion1 + retencion2);

    if (salida = 'N') and (distribucion.FieldByName('efectivo').AsFloat <> 0) then Begin    // Transferimos Movimientos a Caja
      if (factura.Estado <> 'C') and (factform.Estado <> 'C') then Begin
         if Length(Trim(iitems)) = 0 then it := 0;

         if it = 99 then Begin
           idregistro := utiles.setIdRegistroFecha;
           it         := 0;
         end;

         Inc(it);
         iitems     := utiles.sLlenarIzquierda(IntToStr(it), 2, '0');
         irr        := idregistro + iitems;

         ireg       := caja.setIdRegistro('1', distribucion.FieldByName('idc').AsString, distribucion.FieldByName('tipo').AsString,
                                               distribucion.FieldByName('sucursal').AsString, distribucion.FieldByName('numero').AsString);

         if Length(Trim(ireg)) = 0 then ireg := irr;  // Si No Existe el Id. lo generamos

         if tmov = 'C' then Begin  // Cuotas Societarias
           factura.getDatosMovCajaCuotas;
           caja.Registrar(ireg, utiles.sFormatoFecha(distribucion.FieldByName('fecha').AsString), '1', distribucion.FieldByName('idc').AsString, distribucion.FieldByName('tipo').AsString,
                          distribucion.FieldByName('sucursal').AsString, distribucion.FieldByName('numero').AsString, factura.codmovcajacuotas,
                          'Ing. por Cuotas Socientarias s/c ' + distribucion.FieldByName('tipo').AsString + ' ' + distribucion.FieldByName('sucursal').AsString + '-' + distribucion.FieldByName('numero').AsString,
                          'A', distribucion.FieldByName('efectivo').AsFloat, True);

         end;
         if tmov = 'F' then Begin  // Venta de Formularios
           factform.getDatosMovCajaForms;
           caja.Registrar(ireg, utiles.sFormatoFecha(distribucion.FieldByName('fecha').AsString), '1', distribucion.FieldByName('idc').AsString, distribucion.FieldByName('tipo').AsString,
                          distribucion.FieldByName('sucursal').AsString, distribucion.FieldByName('numero').AsString, factform.codmovcajaforms,
                          'Ing. por Vta. Formularios s/c ' + distribucion.FieldByName('tipo').AsString + ' ' + distribucion.FieldByName('sucursal').AsString + '-' + distribucion.FieldByName('numero').AsString,
                          'A', distribucion.FieldByName('efectivo').AsFloat, True);

         end;

      end;
    end;

  end;

  procedure DetalleCheques(xtipomov: Integer);
  var
    i: Integer;
  Begin

    if xtipomov = 1 then l := setDatosChequeContado(distribucion.FieldByName('idc').AsString, distribucion.FieldByName('tipo').AsString, distribucion.FieldByName('sucursal').AsString, distribucion.FieldByName('numero').AsString);
    if xtipomov = 2 then l := setDatosChequeReferencia(distribucion.FieldByName('referencia').AsString);

    For i := 1 to l.Count do Begin
      objeto := TTDistribucion(l.Items[i-1]);
      entbcos.getDatos(objeto.Codbanco);

      if i = 1 then list.Linea(0, 0, 'Cheques:', 1, 'Arial, normal, 8', salida, 'N') else
        list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(8, list.Lineactual, objeto.Nrocheque, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(18, list.Lineactual, objeto.Fecha, 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(26, list.Lineactual, objeto.Codbanco + '  ' + entbcos.descrip, 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(60, list.Lineactual, objeto.Filial, 5, 'Arial, normal, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', objeto.Monto, 6, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S');
    end;

    if l <> Nil then
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

    l.Free; l := Nil;
  end;

Begin
  factura.conectar;
  factform.conectar;
  entbcos.conectar;

  list.m := 0; list.altopag := 0;
  List.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Control de Cobros Efectuados en el Lapso: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Comprobante', 1, 'Arial, cursiva, 9');
  List.Titulo(18, List.lineactual, 'Fecha', 2, 'Arial, cursiva, 9');
  List.Titulo(26, List.lineactual, 'Cliente', 3, 'Arial, cursiva, 9');
  List.Titulo(75, List.lineactual, 'T.Op.', 4, 'Arial, cursiva, 9');
  List.Titulo(87, List.lineactual, 'Tot.Fact.', 5, 'Arial, cursiva, 9');
  List.Titulo(94, List.lineactual, 'Est.', 6, 'Arial, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, '***  Cobros Efectuados en Operaciones de Contado  ***', 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  total := 0; total1 := 0;
  datosdb.Filtrar(distribucion, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and tipomov =  ' + '''' + '1' + '''');
  distribucion.First;
  while not distribucion.Eof do Begin
    if factura.BuscarFact(distribucion.FieldByName('idc').AsString, distribucion.FieldByName('tipo').AsString, distribucion.FieldByName('sucursal').AsString, distribucion.FieldByName('numero').AsString) then Begin
      factura.getDatosFact(distribucion.FieldByName('idc').AsString, distribucion.FieldByName('tipo').AsString, distribucion.FieldByName('sucursal').AsString, distribucion.FieldByName('numero').AsString);
      list.Linea(0, 0, factura.Tipo + ' ' + factura.Sucursal + '-' + factura.Numero, 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(18, list.Lineactual, factura.Fecha, 2, 'Arial, normal, 9', salida, 'N');
      list.Linea(26, list.Lineactual, Copy(factura.setNombreentidad(distribucion.FieldByName('entidad').AsString), 1, 40), 3, 'Arial, normal, 9', salida, 'N');
      list.Linea(75, list.Lineactual, 'Cuota', 4, 'Arial, normal, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', factura.Subtotal + factura.iva, 5, 'Arial, normal, 9');
      list.Linea(95, list.Lineactual, factura.Estado, 6, 'Arial, normal, 9', salida, 'S');
      if factura.Estado <> 'C' then Begin
        total   := total + (factura.Subtotal + factura.Iva);
        totdist := totdist + (factura.Subtotal + factura.Iva);
      end;
      tmov := 'C';
    end;
    if factform.BuscarFact(distribucion.FieldByName('idc').AsString, distribucion.FieldByName('tipo').AsString, distribucion.FieldByName('sucursal').AsString, distribucion.FieldByName('numero').AsString) then Begin
      factform.getDatosFact(distribucion.FieldByName('idc').AsString, distribucion.FieldByName('tipo').AsString, distribucion.FieldByName('sucursal').AsString, distribucion.FieldByName('numero').AsString);
      list.Linea(0, 0, factform.Tipo + ' ' + factform.Sucursal + '-' + factform.Numero, 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(18, list.Lineactual, factform.Fecha, 2, 'Arial, normal, 9', salida, 'N');
      list.Linea(26, list.Lineactual, Copy(factform.setNombreentidad(distribucion.FieldByName('entidad').AsString), 1, 40), 3, 'Arial, normal, 9', salida, 'N');
      list.Linea(75, list.Lineactual, 'Form.', 4, 'Arial, normal, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', factform.Subtotal + factform.iva, 5, 'Arial, normal, 9');
      list.Linea(95, list.Lineactual, factform.Estado, 6, 'Arial, normal, 9', salida, 'S');
      if factform.Estado <> 'C' then Begin
        total   := total + (factform.Subtotal + factform.Iva);
        totdist := totdist + (factform.Subtotal + factform.Iva);
      end;
      tmov := 'F';
    end;

    DetalleDist(totdist);
    DetalleCheques(1);

    distribucion.Next;
  end;
  datosdb.QuitarFiltro(distribucion);

  if total > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
    list.Derecha(95, list.Lineactual, '', '---------------------------------', 2, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 9', salida, 'S');
    list.Linea(0, 0, 'Subtotal Contado:', 1, 'Arial, negrita, 9', salida, 'N');
    list.Importe(95, list.Lineactual, '', total, 2, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
  end;

  total1 := total1 + total;

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, '***  Cobros Efectuados en Operaciones de Cuenta Corriente  ***', 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  total := 0;
  datosdb.Filtrar(distribucion, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and tipomov =  ' + '''' + '2' + '''');
  distribucion.First;
  while not distribucion.Eof do Begin

    l := factform.setFacturasPorReferencia(distribucion.FieldByName('referencia').AsString);
    For i := 1 to l.Count do Begin
      objfac := TTFactura_Formularios(l.Items[i-1]);

      list.Linea(0, 0, objfac.Tipo + '  ' + objfac.Sucursal + '  ' + objfac.Numero, 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(18, list.Lineactual, objfac.Fecha, 2, 'Arial, normal, 9', salida, 'N');
      list.Linea(26, list.Lineactual, objfac.Entidad + '  ' + Copy(factura.setNombreEntidad(objfac.Entidad), 1, 40), 3, 'Arial, normal, 9', salida, 'N');
      list.Linea(75, list.Lineactual, 'Form.', 4, 'Arial, normal, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', objfac.Subtotal, 5, 'Arial, normal, 9');
      list.Linea(95, list.Lineactual, '', 6, 'Arial, normal, 9', salida, 'S');
      total   := total + objfac.Subtotal;
      totdist := totdist + objfac.Subtotal;
      tmov := 'F';
    end;
    l.Free; l := Nil;

    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

    l := factura.setFacturasPorReferencia(distribucion.FieldByName('referencia').AsString);
    For i := 1 to l.Count do Begin
      objcuo := TTFactura_Cuotas(l.Items[i-1]);
      list.Linea(0, 0, objcuo.Tipo + '  ' + objcuo.Sucursal + '  ' + objcuo.Numero, 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(18, list.Lineactual, objcuo.Fecha, 2, 'Arial, normal, 9', salida, 'N');
      list.Linea(26, list.Lineactual, objcuo.Entidad + '  ' + Copy(factura.setNombreEntidad(objcuo.Entidad), 1, 40), 3, 'Arial, normal, 9', salida, 'N');
      list.Linea(75, list.Lineactual, 'Cuota', 4, 'Arial, normal, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', objcuo.Subtotal, 5, 'Arial, normal, 9');
      list.Linea(95, list.Lineactual, '', 6, 'Arial, normal, 9', salida, 'S');
      total   := total + objcuo.Subtotal;
      totdist := totdist + objcuo.Subtotal;
      tmov := 'C';
    end;
    l.Free; l := Nil;

    DetalleDist(totdist);
    DetalleCheques(2);

    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

    distribucion.Next;
  end;
  datosdb.QuitarFiltro(distribucion);

  if total > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
    list.Derecha(95, list.Lineactual, '', '---------------------------------', 2, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 9', salida, 'S');
    list.Linea(0, 0, 'Subtotal Cuenta Corriente:', 1, 'Arial, negrita, 9', salida, 'N');
    list.Importe(95, list.Lineactual, '', total, 2, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
  end;

  total1 := total1 + total;

  if total1 > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
    list.Derecha(95, list.Lineactual, '', '---------------------------------', 2, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 9', salida, 'S');
    list.Linea(0, 0, 'Total General:', 1, 'Arial, negrita, 9', salida, 'N');
    list.Importe(95, list.Lineactual, '', total1, 2, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
  end else
    list.Linea(0, 0, 'No hay Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');

  factura.desconectar;
  factform.desconectar;
  entbcos.desconectar;

  if salida <> 'N' then list.FinList;
end;

procedure TTDistribucion.ListarCheques(xdesde, xhasta: String; xbancos: TStringList; salida: char);
// Objetivo...: listar cheques por Banco
var
  idanter: String;
  total1, total2: Real;

  procedure Subtotal;
  Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', total1, 2, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
    total2 := total2 + total1;
    total1 := 0;
  end;

Begin
  list.m := 0; list.altopag := 0;
  List.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Cheques Recibidos en el Lapso: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Nro.Cheque', 1, 'Arial, cursiva, 9');
  List.Titulo(18, List.lineactual, 'Fecha', 2, 'Arial, cursiva, 9');
  List.Titulo(26, List.lineactual, 'Filial', 3, 'Arial, cursiva, 9');
  List.Titulo(75, List.lineactual, 'Propio', 4, 'Arial, cursiva, 9');
  List.Titulo(87, List.lineactual, 'Monto', 5, 'Arial, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  cheque.IndexFieldNames := 'codbanco;fecha';
  datosdb.Filtrar(cheque, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  cheque.First;

  entbcos.conectar;
  total1 := 0; total2 := 0;
  while not cheque.Eof do Begin
    if utiles.verificarItemsLista(xbancos, cheque.FieldByName('codbanco').AsString) then Begin
      if cheque.FieldByName('codbanco').AsString <> idanter then Begin
        if total1 <> 0 then Subtotal;
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        entbcos.getDatos(cheque.FieldByName('codbanco').AsString);
        list.Linea(0, 0, 'Banco: ' + entbcos.codbanco + '  ' + entbcos.descrip, 1, 'Arial, negrita, 9', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        idanter := cheque.FieldByName('codbanco').AsString;
      end;
      list.Linea(0, 0, cheque.FieldByName('nrocheque').AsString, 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(18, list.Lineactual, utiles.sFormatoFecha(cheque.FieldByName('fecha').AsString), 2, 'Arial, normal, 9', salida, 'N');
      list.Linea(26, list.Lineactual, cheque.FieldByName('filial').AsString, 3, 'Arial, normal, 9', salida, 'N');
      list.Linea(75, list.Lineactual, cheque.FieldByName('propio').AsString, 4, 'Arial, normal, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', cheque.FieldByName('monto').AsFloat, 5, 'Arial, normal, 9');
      list.Linea(95, list.Lineactual, '', 6, 'Arial, normal, 9', salida, 'S');
      total1 := total1 + cheque.FieldByName('monto').AsFloat;
    end;
    cheque.Next;
  end;

  if total1 <> 0 then Subtotal;
  if total2 <> 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'TOTAL GENERAL:', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', total2, 2, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
  end else
    list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');

  datosdb.QuitarFiltro(cheque);
  cheque.IndexFieldNames := 'idc;tipo;sucursal;numero;items';
  entbcos.desconectar;

  list.FinList;
end;

procedure TTDistribucion.ListarRetenciones(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Operaciones de control
var
  t1, t2: Real;
Begin
  list.m := 0; list.altopag := 0;
  List.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Informe de Retenciones por Cobros - Lapso: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, List.lineactual, 'Razón Social', 2, 'Arial, cursiva, 8');
  List.Titulo(73, List.lineactual, 'Ret. I.V.A.', 3, 'Arial, cursiva, 8');
  List.Titulo(87, List.lineactual, 'Ret. C.Patr.', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  datosdb.Filtrar(refcobros, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  refcobros.First; t1 := 0; t2 := 0;
  while not refcobros.Eof do Begin
    if (refcobros.FieldByName('retencion1').AsFloat + refcobros.FieldByName('retencion2').AsFloat <> 0) then Begin
      getDatosRefDistCobro(refcobros.FieldByName('referencia').AsString);
      getDatosDist(refcobros.FieldByName('referencia').AsString);
      cliente.getDatos(Entidad);
      list.Linea(0, 0, utiles.sFormatoFecha(refcobros.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(8, list.Lineactual, Entidad + '  ' + cliente.nombre, 2, 'Arial, normal, 8', salida, 'N');
      list.importe(80, list.Lineactual, '', refcobros.FieldByName('retencion1').AsFloat, 3, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', refcobros.FieldByName('retencion2').AsFloat, 4, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
      t1 := t1 + refcobros.FieldByName('retencion1').AsFloat;
      t2 := t2 + refcobros.FieldByName('retencion2').AsFloat;
    end;
    refcobros.Next;
  end;

  if (t1+t2 <> 0) then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Total de Retenciones:', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(80, list.Lineactual, '', t1, 2, 'Arial, negrita, 9');
    list.importe(95, list.Lineactual, '', t2, 3, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
  end else
    list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');

  datosdb.QuitarFiltro(refcobros);

  list.FinList;
end;

procedure TTDistribucion.TransferirOperacionesACaja(xdesde, xhasta: String);
// Objetivo...: a partir del informe con la distribucion tomos los montos que
// corresponden al efectivo y los transfiero a caja
Begin
  caja.conectar;
  idregistro := utiles.setIdRegistroFecha;
  iitems     := '';
  transfiere := True;
  ListarCobros(xdesde, xhasta, 'N');
  transfiere := False;
  caja.ReCalcularSaldo;
  caja.desconectar;
  list.m := 0; list.altopag := 0;
  list.Setear('P');
end;

procedure TTDistribucion.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not distribucion.Active then distribucion.Open;
    if not cheque.Active then cheque.Open;
    if not refdist.Active then refdist.Open;
    if not refcobros.Active then refcobros.Open;
  end;
  Inc(conexiones);
end;

procedure TTDistribucion.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(distribucion);
    datosdb.closeDB(cheque);
    datosdb.closeDB(refdist);
    datosdb.closeDB(refcobros);
  end;
end;

{===============================================================================}

function distribucion: TTDistribucion;
begin
  if xdistribucion = nil then
    xdistribucion := TTDistribucion.Create;
  Result := xdistribucion;
end;

{===============================================================================}

initialization

finalization
  xdistribucion.Free;

end.
