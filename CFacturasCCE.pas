unit CFacturasCCE;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes, CCIvaVentasCCE,
     CClienteCCE, Contnrs, CTablaiva, CCNetos, CComprob;

type

TTFactura = class
  Idc, Tipo, Sucursal, Numero, Entidad, Fecha, Tipomov, Nroremito, Estado, Condicion, Referencia, Cobrado,
  Items, Codart, Descrip, DetItems: String;
  MontoCheque, Subtotal, Percep, Iva, Impuesto, Costo, Monto, Cantidad, Ivadet: Real;
  Id, Cabecera, Detalle, Pie: String;
  Lineasdet, Lineassep: Integer;
  cabfact, detfact, observac, modeloImp, mov_modulos: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    BuscarFact(xidc, xtipo, xsucursal, xnumero: String): Boolean; overload;
  function    BuscarFact(xidc, xtipo, xsucursal, xnumero, xcodigo: String): Boolean; overload;
  function    BuscarDetFact(xidc, xtipo, xsucursal, xnumero, xitems: String): Boolean; overload;
  function    BuscarDetFact(xidc, xtipo, xsucursal, xnumero, xcodigo, xitems: String): Boolean; overload;
  procedure   RegistrarFact(xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xconcepto, xcodcli, xcondicion, xnroremito, xcodart, xcodmov, xdetalle: String; xcantidad, xmonto, xiva_items, xsubtotal, xpercep, xiva, ximpuestos, xexentas, xtasaiva, xtasaivani, xconnograv, xneto: Real; xcantitems: Integer; xiva_exento: Boolean); overload;
  procedure   RegistrarFact(xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xconcepto, xcodcli, xcondicion, xnroremito, xcodart, xcodmov, xdetalle, xcuota: String; xcantidad, xmonto, xiva_items, xsubtotal, xpercep, xiva, ximpuestos, xexentas, xtasaiva, xtasaivani, xconnograv, xneto: Real; xcantitems: Integer; xiva_exento: Boolean); overload;
  procedure   RegistrarFactura(xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xconcepto, xcodcli, xcondicion, xnroremito, xcodart, xcodmov, xdetalle: String; xcantidad, xmonto, xiva_items, xsubtotal, xpercep, xiva, ximpuestos, xexentas, xtasaiva, xtasaivani, xconnograv, xneto, xcosto, xcostototal: Real; xcantitems: Integer; xiva_exento: Boolean);
  function    setDatosFact(xidc, xtipo, xsucursal, xnumero: String): TStringList;
  function    setItemsFact(xidc, xtipo, xsucursal, xnumero: String): TObjectList; overload;
  function    setItemsFact(xidc, xtipo, xsucursal, xnumero, xcodcli: String): TObjectList; overload;
  procedure   getDatosFact(xidc, xtipo, xsucursal, xnumero: String);
  procedure   BorrarFact(xidc, xtipo, xsucursal, xnumero: String);

  procedure   RegistrarFormato(xid, xcabecera, xdetalle, xpie: String; xlineasdet, xlineassep: Integer);
  procedure   getDatosFormato(xid: String);

  function    VerificarFacturaAnulada(xidc, xtipo, xsucursal, xnumero: String): Boolean;
  procedure   AnularFactura(xidc, xtipo, xsucursal, xnumero: String; xtipomov: Boolean);

  function    BuscarObservacion(xidc, xtipo, xsucursal, xnumero: String): Boolean;
  procedure   RegistrarObservacion(xidc, xtipo, xsucursal, xnumero, xobservacion: String);
  procedure   BorrarObservacion(xidc, xtipo, xsucursal, xnumero: String);
  function    setObservacion(xidc, xtipo, xsucursal, xnumero: String): String;
  function    setLineasObservacion(xidc, xtipo, xsucursal, xnumero: String): TStringList;

  procedure   ListarFacturas(xdesde, xhasta, xsubtitulo: String; salida: char); overload;
  procedure   ListarFacturas(xdesde, xhasta, xsubtitulo, xcodcli: String; salida: char); overload;
  procedure   ListarMontosFacturas(xdesde, xhasta, xsubtitulo: String; salida: char);
  procedure   ListarDetalleFacturas(xlista: TStringList; xcodcli, xsubtitulo, xdesde, xhasta: String; salida: char);
  procedure   ListarTotalFinal(salida: char);

  function    setFacturasFecha(xdesde, xhasta: String): TQuery;
  function    setFacturasCliente(xcodcli: String): TQuery;
  function    setFacturasNumero(xidc, xtipo, xsucursal, xnumero: String): TQuery;

  function    setFacturasImpagas(xdesde, xhasta, xcodcli: String): TObjectList;
  function    setFacturasPagas(xdesde, xhasta, xcodcli: String): TObjectList;
  function    setFacturasPorReferencia(xreferencia: String): TObjectList;
  procedure   getFacturasPorReferencia(xreferencia: String);
  function    setFacturas(xdesde, xhasta: String): TObjectList;

  procedure   CancelarFactura(xidc, xtipo, xsucursal, xnumero, xfecha: String);
  procedure   ReactivarFactura(xidc, xtipo, xsucursal, xnumero: String);

  procedure   GuardarReferenciaCobroLote(xidc, xtipo, xsucursal, xnumero, xreferencia: String);
  procedure   BorrarReferenciaCobroLote(xidc, xtipo, xsucursal, xnumero: String);

  function    setNombreentidad(xcodigo: String): String; virtual;

  procedure   PresentarInforme;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  c: Boolean;
 protected
  { Declaraciones Protegidas }
  conexiones: shortint;
  total, totfinal: Real;
  iniList: Boolean;
end;

implementation

var
  xfactura: TTFactura = nil;

constructor TTFactura.Create;
begin
end;

destructor TTFactura.Destroy;
begin
  inherited Destroy;
end;

function  TTFactura.BuscarFact(xidc, xtipo, xsucursal, xnumero: String): Boolean;
// Objetivo...: Buscar una Instancia
begin
  if cabfact.IndexFieldNames <> 'idc;tipo;sucursal;numero' then cabfact.IndexFieldNames := 'idc;tipo;sucursal;numero';
  Result := datosdb.Buscar(cabfact, 'idc', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero);
end;

function  TTFactura.BuscarFact(xidc, xtipo, xsucursal, xnumero, xcodigo: String): Boolean;
// Objetivo...: Buscar una Instancia
begin
  if cabfact.IndexFieldNames <> 'idc;tipo;sucursal;numero;codcli' then cabfact.IndexFieldNames := 'idc;tipo;sucursal;numero;codcli';
  Result := datosdb.Buscar(cabfact, 'idc', 'tipo', 'sucursal', 'numero', 'codcli', xidc, xtipo, xsucursal, xnumero, xcodigo);
end;

function  TTFactura.BuscarDetFact(xidc, xtipo, xsucursal, xnumero, xitems: String): Boolean;
// Objetivo...: Buscar una Instancia
begin
  Result := datosdb.Buscar(detfact, 'idc', 'tipo', 'sucursal', 'numero', 'items', xidc, xtipo, xsucursal, xnumero, xitems);
end;

function  TTFactura.BuscarDetFact(xidc, xtipo, xsucursal, xnumero, xcodigo, xitems: String): Boolean;
// Objetivo...: Buscar una Instancia
begin
utiles.msgerror(xidc + xtipo + xsucursal + xnumero + xcodigo + xitems);
  detfact.IndexFieldNames := 'idc;tipo;sucursal;numero;codcli;items';
  Result := datosdb.Buscar(detfact, 'idc', 'tipo', 'sucursal', 'numero', 'codcli', 'items', xidc, xtipo, xsucursal, xnumero, xcodigo, xitems);
  if (Result) then utiles.msgerror(xidc + xtipo + xsucursal + xnumero + xcodigo + xitems);
  
  end;

procedure TTFactura.RegistrarFact(xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xconcepto, xcodcli, xcondicion, xnroremito, xcodart, xcodmov, xdetalle: String; xcantidad, xmonto, xiva_items, xsubtotal, xpercep, xiva, ximpuestos, xexentas, xtasaiva, xtasaivani, xconnograv, xneto: Real; xcantitems: Integer; xiva_exento: Boolean);
// Objetivo...: Registrar una Instancia
var
  vinst: Boolean;
  total: real;
begin
  if xitems = '01' then Begin
    vinst := BuscarFact(xidc, xtipo, xsucursal, xnumero);
    if vinst then cabfact.Edit else cabfact.Append;
    cabfact.FieldByName('idc').AsString       := xidc;
    cabfact.FieldByName('tipo').AsString      := xtipo;
    cabfact.FieldByName('sucursal').AsString  := xsucursal;
    cabfact.FieldByName('numero').AsString    := xnumero;
    cabfact.FieldByName('codcli').AsString    := xcodcli;
    cabfact.FieldByName('condicion').AsString := xcondicion;
    cabfact.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
    cabfact.FieldByName('nroremito').AsString := xnroremito;
    cabfact.FieldByName('subtotal').AsFloat   := xsubtotal;
    cabfact.FieldByName('percep').AsFloat     := xpercep;
    cabfact.FieldByName('iva').AsFloat        := xiva;
    cabfact.FieldByName('impuesto').AsFloat   := ximpuestos;
    try
      cabfact.Post
     except
      cabfact.Cancel
    end;

    if vinst then ivav.Borrar(xidc, xtipo, xsucursal, xnumero);

    cliente.getDatos(xcodcli);
    if not xiva_exento then Begin
      ivav.Registrar(xidc, xtipo, xsucursal, xnumero, xcodcli, cliente.nombre, cliente.Nrocuit, cliente.Codpfis, xfecha, xfecha, xcodmov, 'M', 'Venta s/Fact. ' + xtipo + ' ' + xsucursal + '-' + xnumero, cliente.codprovin, xcondicion,
                   xneto, xconnograv, xexentas, xtasaiva, xtasaivani, xiva, 0, ximpuestos, xpercep, 0, 0, 0, 0, 0, {xsubtotal} xneto + xconnograv + xexentas + xiva + ximpuestos + xpercep, 0);
    end else Begin
      total := xsubtotal;
      // Tomamos el Subtotal como exento
      netos.getDatos(xcodmov);
      tabliva.getDatos(netos.codiva);
      //utiles.msgError(netos.codiva + ' ' + floattostr(tabliva.coeinverso));
      if (tabliva.coeinverso > 0) then begin // Recalculamos la Facturas B 10/2013
        ivav.CalcularIva(xsubtotal, xcodmov);
        xsubtotal := ivav.Neto;
        xiva := ivav.Ivari;
      end;

      ivav.Registrar(xidc, xtipo, xsucursal, xnumero, xcodcli, cliente.nombre, cliente.Nrocuit, cliente.Codpfis, xfecha, xfecha, xcodmov, 'M', 'Venta s/Fact. ' + xtipo + ' ' + xsucursal + '-' + xnumero, cliente.codprovin, xcondicion,
                     0, 0, xsubtotal, 0, 0, xiva, 0, ximpuestos, xpercep, 0, 0, 0, 0, 0, total, 0);
    end;

  end;

  if BuscarDetFact(xidc, xtipo, xsucursal, xnumero, xitems) then detfact.Edit else detfact.Append;
  detfact.FieldByName('idc').AsString      := xidc;
  detfact.FieldByName('tipo').AsString     := xtipo;
  detfact.FieldByName('sucursal').AsString := xsucursal;
  detfact.FieldByName('numero').AsString   := xnumero;
  detfact.FieldByName('items').AsString    := xitems;
  detfact.FieldByName('descrip').AsString  := xconcepto;
  detfact.FieldByName('cantidad').AsFloat  := xcantidad;
  detfact.FieldByName('codart').AsString   := xcodart;
  detfact.FieldByName('detalle').AsString  := xdetalle;
  detfact.FieldByName('fecha').AsString    := utiles.sExprFecha2000(xfecha);
  detfact.FieldByName('monto').AsFloat     := xmonto;
  detfact.FieldByName('iva').AsFloat       := xiva_items;
  try
    detfact.Post
   except
    detfact.Cancel
  end;

  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    datosdb.tranSQL('delete from ' + detfact.TableName + ' where idc = ' + '''' + xidc + '''' + ' and tipo = ' + '''' + xtipo + '''' + ' and sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(detfact); detfact.Open;
  end;
end;

procedure TTFactura.RegistrarFact(xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xconcepto, xcodcli, xcondicion, xnroremito, xcodart, xcodmov, xdetalle, xcuota: String; xcantidad, xmonto, xiva_items, xsubtotal, xpercep, xiva, ximpuestos, xexentas, xtasaiva, xtasaivani, xconnograv, xneto: Real; xcantitems: Integer; xiva_exento: Boolean);
// Objetivo...: Registrar una Instancia
var
  vinst: Boolean;
begin
  if xitems = '01' then Begin
    vinst := BuscarFact(xidc, xtipo, xsucursal, xnumero);
    if vinst then cabfact.Edit else cabfact.Append;
    cabfact.FieldByName('idc').AsString       := xidc;
    cabfact.FieldByName('tipo').AsString      := xtipo;
    cabfact.FieldByName('sucursal').AsString  := xsucursal;
    cabfact.FieldByName('numero').AsString    := xnumero;
    cabfact.FieldByName('codcli').AsString    := xcodcli;
    cabfact.FieldByName('condicion').AsString := xcondicion;
    cabfact.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
    cabfact.FieldByName('nroremito').AsString := xnroremito;
    cabfact.FieldByName('subtotal').AsFloat   := xsubtotal;
    cabfact.FieldByName('percep').AsFloat     := xpercep;
    cabfact.FieldByName('iva').AsFloat        := xiva;
    cabfact.FieldByName('impuesto').AsFloat   := ximpuestos;
    try
      cabfact.Post
     except
      cabfact.Cancel
    end;

    if vinst then ivav.Borrar(xidc, xtipo, xsucursal, xnumero);

    cliente.getDatos(xcodcli);
    if not xiva_exento then Begin
      ivav.Registrar(xidc, xtipo, xsucursal, xnumero, xcodcli, cliente.nombre, cliente.Nrocuit, cliente.Codpfis, xfecha, xfecha, xcodmov, 'M', 'Venta s/Fact. ' + xtipo + ' ' + xsucursal + '-' + xnumero, cliente.codprovin, xcondicion,
                   xneto, xconnograv, xexentas, xtasaiva, xtasaivani, xiva, 0, ximpuestos, xpercep, 0, 0, 0, 0, 0, xsubtotal + xexentas + xiva + ximpuestos + xpercep, 0);
    end else Begin
      // Tomamos el Subtotal como exento
      ivav.Registrar(xidc, xtipo, xsucursal, xnumero, xcodcli, cliente.nombre, cliente.Nrocuit, cliente.Codpfis, xfecha, xfecha, xcodmov, 'M', 'Venta s/Fact. ' + xtipo + ' ' + xsucursal + '-' + xnumero, cliente.codprovin, xcondicion,
                     0, 0, xsubtotal, xtasaiva, xtasaivani, xiva, 0, ximpuestos, xpercep, 0, 0, 0, 0, 0, xsubtotal, 0);
    end;

  end;

  if BuscarDetFact(xidc, xtipo, xsucursal, xnumero, xitems) then detfact.Edit else detfact.Append;
  detfact.FieldByName('idc').AsString      := xidc;
  detfact.FieldByName('tipo').AsString     := xtipo;
  detfact.FieldByName('sucursal').AsString := xsucursal;
  detfact.FieldByName('numero').AsString   := xnumero;
  detfact.FieldByName('items').AsString    := xitems;
  detfact.FieldByName('descrip').AsString  := xconcepto;
  detfact.FieldByName('cuota').AsString    := xcuota;
  detfact.FieldByName('periodo').AsString  := Copy(utiles.sExprFecha2000(xfecha), 1, 4);
  detfact.FieldByName('cantidad').AsFloat  := xcantidad;
  detfact.FieldByName('codart').AsString   := xcodart;
  detfact.FieldByName('detalle').AsString  := xdetalle;
  detfact.FieldByName('fecha').AsString    := utiles.sExprFecha2000(xfecha);
  detfact.FieldByName('monto').AsFloat     := xmonto;
  detfact.FieldByName('iva').AsFloat       := xiva_items;
  try
    detfact.Post
   except
    detfact.Cancel
  end;

  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    datosdb.tranSQL('delete from ' + detfact.TableName + ' where idc = ' + '''' + xidc + '''' + ' and tipo = ' + '''' + xtipo + '''' + ' and sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(detfact); detfact.Open;
  end;
end;

procedure TTFactura.RegistrarFactura(xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xconcepto, xcodcli, xcondicion, xnroremito, xcodart, xcodmov, xdetalle: String; xcantidad, xmonto, xiva_items, xsubtotal, xpercep, xiva, ximpuestos, xexentas, xtasaiva, xtasaivani, xconnograv, xneto, xcosto, xcostototal: Real; xcantitems: Integer; xiva_exento: Boolean);
// Objetivo...: Registrar una Instancia
var
  vinst: Boolean;
  total: real;
begin
  if xitems = '01' then Begin
    vinst := BuscarFact(xidc, xtipo, xsucursal, xnumero);
    if vinst then cabfact.Edit else cabfact.Append;
    cabfact.FieldByName('idc').AsString       := xidc;
    cabfact.FieldByName('tipo').AsString      := xtipo;
    cabfact.FieldByName('sucursal').AsString  := xsucursal;
    cabfact.FieldByName('numero').AsString    := xnumero;
    cabfact.FieldByName('codcli').AsString    := xcodcli;
    cabfact.FieldByName('condicion').AsString := xcondicion;
    cabfact.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
    cabfact.FieldByName('nroremito').AsString := xnroremito;
    cabfact.FieldByName('subtotal').AsFloat   := xsubtotal;
    cabfact.FieldByName('percep').AsFloat     := xpercep;
    cabfact.FieldByName('iva').AsFloat        := xiva;
    cabfact.FieldByName('impuesto').AsFloat   := ximpuestos;
    cabfact.FieldByName('costo').AsFloat      := xcostototal;
    try
      cabfact.Post
     except
      cabfact.Cancel
    end;

    if vinst then ivav.Borrar(xidc, xtipo, xsucursal, xnumero);

    comprobante.getDatos(xidc);

    cliente.getDatos(xcodcli);
    if not xiva_exento then Begin
      total := xsubtotal;
      // Tomamos el Subtotal como exento
      netos.getDatos(xcodmov);
      tabliva.getDatos(netos.codiva);
      if (tabliva.coeinverso > 0) then begin // Recalculamos la Facturas B 10/2013
        ivav.CalcularIva(xsubtotal, xcodmov);
        xneto := ivav.Neto;
        xiva := ivav.MontoIva;
      end;

      if not (comprobante.ExcluirIVA) then
        ivav.Registrar(xidc, xtipo, xsucursal, xnumero, xcodcli, cliente.nombre, cliente.Nrocuit, cliente.Codpfis, xfecha, xfecha, xcodmov, 'M', 'Venta s/Fact. ' + xtipo + ' ' + xsucursal + '-' + xnumero, cliente.codprovin, xcondicion,
                   xneto, xconnograv, xexentas, xtasaiva, xtasaivani, xiva, 0, ximpuestos, xpercep, 0, 0, 0, 0, 0, {xsubtotal} xneto + xconnograv + xexentas + xiva + ximpuestos + xpercep, 0);
    end else Begin
      // Tomamos el Subtotal como exento
      if not (comprobante.ExcluirIVA) then
        ivav.Registrar(xidc, xtipo, xsucursal, xnumero, xcodcli, cliente.nombre, cliente.Nrocuit, cliente.Codpfis, xfecha, xfecha, xcodmov, 'M', 'Venta s/Fact. ' + xtipo + ' ' + xsucursal + '-' + xnumero, cliente.codprovin, xcondicion,
                     0, 0, xsubtotal, 0, 0, xiva, 0, ximpuestos, xpercep, 0, 0, 0, 0, 0, xsubtotal, 0);
    end;

  end;

  if BuscarDetFact(xidc, xtipo, xsucursal, xnumero, xitems) then detfact.Edit else detfact.Append;
  detfact.FieldByName('idc').AsString      := xidc;
  detfact.FieldByName('tipo').AsString     := xtipo;
  detfact.FieldByName('sucursal').AsString := xsucursal;
  detfact.FieldByName('numero').AsString   := xnumero;
  detfact.FieldByName('items').AsString    := xitems;
  detfact.FieldByName('descrip').AsString  := xconcepto;
  detfact.FieldByName('cantidad').AsFloat  := xcantidad;
  detfact.FieldByName('codart').AsString   := xcodart;
  detfact.FieldByName('detalle').AsString  := xdetalle;
  detfact.FieldByName('fecha').AsString    := utiles.sExprFecha2000(xfecha);
  detfact.FieldByName('monto').AsFloat     := xmonto;
  detfact.FieldByName('iva').AsFloat       := xiva_items;
  detfact.FieldByName('costo').AsFloat     := xcosto;
  try
    detfact.Post
   except
    detfact.Cancel
  end;

  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    datosdb.tranSQL('delete from ' + detfact.TableName + ' where idc = ' + '''' + xidc + '''' + ' and tipo = ' + '''' + xtipo + '''' + ' and sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(detfact); detfact.Open;
  end;
end;


function  TTFactura.setDatosFact(xidc, xtipo, xsucursal, xnumero: String): TStringList;
// Objetivo...: Recuperar una Instancia
var
  l: TStringList;
begin
  l := TStringList.Create;
  if BuscarDetFact(xidc, xtipo, xsucursal, xnumero, '01') then Begin
    while not detfact.Eof do Begin
      if (detfact.FieldByName('idc').AsString <> xidc) or (detfact.FieldByName('tipo').AsString <> xtipo) or (detfact.FieldByName('sucursal').AsString <> xsucursal) or (detfact.FieldByName('numero').AsString <> xnumero) then Break;
      l.Add(detfact.FieldByName('items').AsString + detfact.FieldByName('codart').AsString + detfact.FieldByName('descrip').AsString + ';1' + utiles.FormatearNumero(detfact.FieldByName('monto').AsString) + ';2' + utiles.FormatearNumero(detfact.FieldByName('cantidad').AsString) + ';3' + utiles.FormatearNumero(detfact.FieldByName('iva').AsString) + ';4' + detfact.FieldByName('descrip').Text);
      detfact.Next;
    end;
  end;
  Result := l;
end;

function TTFactura.setItemsFact(xidc, xtipo, xsucursal, xnumero: String): TObjectList;
// Objetivo...: Recuperar los Items de un Comprobante
var
  l: TObjectList;
  objeto: TTFactura;
Begin
  l := TObjectList.Create;
  if BuscarDetFact(xidc, xtipo, xsucursal, xnumero, '01') then Begin
    while not detfact.Eof do Begin
      if (detfact.FieldByName('idc').AsString <> xidc) or (detfact.FieldByName('tipo').AsString <> xtipo) or (detfact.FieldByName('sucursal').AsString <> xsucursal) or (detfact.FieldByName('numero').AsString <> xnumero) then Break;
      objeto          := TTFactura.Create;
      objeto.Items    := detfact.FieldByName('items').AsString;
      objeto.Codart   := detfact.FieldByName('codart').AsString;
      objeto.Descrip  := detfact.FieldByName('descrip').AsString;
      objeto.Monto    := detfact.FieldByName('monto').AsFloat;
      objeto.Cantidad := detfact.FieldByName('cantidad').AsFloat;
      objeto.Ivadet   := detfact.FieldByName('iva').AsFloat;
      objeto.descrip  := detfact.FieldByName('descrip').AsString;
      objeto.detitems := detfact.FieldByName('detalle').AsString;
      if c then objeto.Costo := detfact.FieldByName('costo').AsFloat else objeto.Costo := 0;
      l.Add(objeto);
      detfact.Next;
    end;
  end;

  Result := l;
end;

function TTFactura.setItemsFact(xidc, xtipo, xsucursal, xnumero, xcodcli: String): TObjectList;
// Objetivo...: Recuperar los Items de un Comprobante
var
  l: TObjectList;
  objeto: TTFactura;
Begin
  l := TObjectList.Create;
  if BuscarDetFact(xidc, xtipo, xsucursal, xnumero, xcodcli, '01') then Begin
    utiles.msgError('sss');
    while not detfact.Eof do Begin
      if (detfact.FieldByName('idc').AsString <> xidc) or (detfact.FieldByName('tipo').AsString <> xtipo) or (detfact.FieldByName('sucursal').AsString <> xsucursal) or (detfact.FieldByName('numero').AsString <> xnumero) then Break;
      objeto          := TTFactura.Create;
      objeto.Items    := detfact.FieldByName('items').AsString;
      objeto.Codart   := detfact.FieldByName('codart').AsString;
      objeto.Descrip  := detfact.FieldByName('descrip').AsString;
      objeto.Monto    := detfact.FieldByName('monto').AsFloat;
      objeto.Cantidad := detfact.FieldByName('cantidad').AsFloat;
      objeto.Ivadet   := detfact.FieldByName('iva').AsFloat;
      objeto.descrip  := detfact.FieldByName('descrip').AsString;
      objeto.detitems := detfact.FieldByName('detalle').AsString;
      if c then objeto.Costo := detfact.FieldByName('costo').AsFloat else objeto.Costo := 0;
      l.Add(objeto);
      detfact.Next;
    end;
  end;

  Result := l;
end;

procedure TTFactura.getDatosFact(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: Recuperar una Instancia de Facturacion
begin
  if BuscarFact(xidc, xtipo, xsucursal, xnumero) then Begin
    idc       := cabfact.FieldByName('idc').AsString;
    tipo      := cabfact.FieldByName('tipo').AsString;
    sucursal  := cabfact.FieldByName('sucursal').AsString;
    numero    := cabfact.FieldByName('numero').AsString;
    entidad   := cabfact.FieldByName('codcli').AsString;
    fecha     := utiles.sFormatoFecha(cabfact.FieldByName('fecha').AsString);
    nroremito := cabfact.FieldByName('nroremito').AsString;
    tipomov   := cabfact.FieldByName('tipomov').AsString;
    condicion := cabfact.FieldByName('condicion').AsString;
    Subtotal  := cabfact.FieldByName('subtotal').AsFloat;
    Percep    := cabfact.FieldByName('percep').AsFloat;
    Iva       := cabfact.FieldByName('iva').AsFloat;
    Impuesto  := cabfact.FieldByName('impuesto').AsFloat;
    estado    := cabfact.FieldByName('estado').AsString;
  end else Begin
    idc       := '';
    tipo      := '';
    sucursal  := '';
    numero    := '';
    entidad   := '';
    fecha     := '';
    nroremito := '';
    tipomov   := '';
    condicion := '';
    Subtotal  := 0;
    Percep    := 0;
    Iva       := 0;
    Impuesto  := 0;
    estado    := '';
  end;
end;

procedure TTFactura.BorrarFact(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: Borrar una Instancia
begin
  if BuscarFact(xidc, xtipo, xsucursal, xnumero) then cabfact.Delete;
  datosdb.tranSQL('delete from ' + detfact.TableName + ' where idc = ' + '''' + xidc + '''' + ' and tipo = ' + '''' + xtipo + '''' + ' and sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''');
  datosdb.closeDB(cabfact); cabfact.Open;
  datosdb.closeDB(detfact); detfact.Open;
  ivav.Borrar(xidc, xtipo, xsucursal, xnumero);
end;

procedure TTFactura.RegistrarFormato(xid, xcabecera, xdetalle, xpie: String; xlineasdet, xlineassep: Integer);
// Objetivo...: Registrar Formato Impresion
begin
  if modeloImp.FindKey([xid]) then modeloImp.Edit else modeloImp.Append;
  modeloImp.FieldByName('id').AsString         := xid;
  modeloImp.FieldByName('cabecera').AsString   := xcabecera;
  modeloImp.FieldByName('detalle').AsString    := xdetalle;
  modeloImp.FieldByName('pie').AsString        := xpie;
  modeloImp.FieldByName('lineasdet').AsInteger := xlineasdet;
  modeloImp.FieldByName('lineassep').AsInteger := xlineassep;
  try
    modeloImp.Post
   except
    modeloImp.Cancel
  end;
  datosdb.closeDB(modeloImp); modeloImp.Open;
end;

procedure TTFactura.getDatosFormato(xid: String);
// Objetivo...: Recuperar Instancia Formato Impresion
begin
  if modeloImp.FindKey([xid]) then Begin
    id        := modeloImp.FieldByName('id').AsString;
    cabecera  := modeloImp.FieldByName('cabecera').AsString;
    detalle   := modeloImp.FieldByName('detalle').AsString;
    pie       := modeloImp.FieldByName('pie').AsString;
    lineasdet := modeloImp.FieldByName('lineasdet').AsInteger;
    lineassep := modeloImp.FieldByName('lineassep').AsInteger;
  end else Begin
    id := ''; cabecera := ''; detalle := ''; pie := ''; lineasdet := 10; lineassep := 5;
  end;
end;

function  TTFactura.VerificarFacturaAnulada(xidc, xtipo, xsucursal, xnumero: String): Boolean;
// Objetivo...: verificar estado de la factura
begin
  if not BuscarFact(xidc, xtipo, xsucursal, xnumero) then Result := False else Begin
    if cabfact.FieldByName('estado').AsString = 'C' then Result := True else Result := False;
  end;
end;

procedure TTFactura.AnularFactura(xidc, xtipo, xsucursal, xnumero: String; xtipomov: Boolean);
// Objetivo...: grabar estado de factura
begin
  if BuscarFact(xidc, xtipo, xsucursal, xnumero) then Begin
    cabfact.Edit;
    if xtipomov then cabfact.FieldByName('estado').AsString := 'C' else cabfact.FieldByName('estado').AsString := '';
    try
      cabfact.Post
     except
      cabfact.Cancel
    end;

    if xtipomov then ivav.AnularComprobante(xidc, xtipo, xsucursal, xnumero, cabfact.FieldByName('codcli').AsString) else
      ivav.ReactivarComprobante(xidc, xtipo, xsucursal, xnumero, cabfact.FieldByName('codcli').AsString);

    datosdb.closeDB(cabfact); cabfact.Open;
  end;
end;

function  TTFactura.BuscarObservacion(xidc, xtipo, xsucursal, xnumero: String): Boolean;
// Objetivo...: Buscar Instancia
begin
  Result := datosdb.Buscar(observac, 'idc', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero);
end;

procedure TTFactura.RegistrarObservacion(xidc, xtipo, xsucursal, xnumero, xobservacion: String);
// Objetivo...: Registrar Instancia
begin
  if BuscarObservacion(xidc, xtipo, xsucursal, xnumero) then observac.Edit else observac.Append;
  observac.FieldByName('idc').AsString      := xidc;
  observac.FieldByName('tipo').AsString     := xtipo;
  observac.FieldByName('sucursal').AsString := xsucursal;
  observac.FieldByName('numero').AsString   := xnumero;
  observac.FieldByName('observac').AsString := xobservacion;
  try
    observac.Post
   except
    observac.Cancel
  end;
  datosdb.closeDB(observac); observac.Open;
end;

procedure TTFactura.BorrarObservacion(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: Borrar Instancia
begin
  if BuscarObservacion(xidc, xtipo, xsucursal, xnumero) then Begin
    observac.Delete;
    datosdb.closeDB(observac); observac.Open;
  end;
end;

function  TTFactura.setObservacion(xidc, xtipo, xsucursal, xnumero: String): String;
// Objetivo...: Retornar Instancia
begin
  if BuscarObservacion(xidc, xtipo, xsucursal, xnumero) then Result := observac.FieldByName('observac').AsString else Result := '';
end;

function  TTFactura.setLineasObservacion(xidc, xtipo, xsucursal, xnumero: String): TStringList;
// Objetivo...: Retornar las Lineas de las Observaciones
Begin
  list.IniciarMemoImpresiones(observac, 'observac', 550);
  if BuscarObservacion(xidc, xtipo, xsucursal, xnumero) then Begin
    Result := list.setContenidoMemo;
    list.LiberarMemoImpresiones;
  end else
    Result := list.setContenidoMemo;
end;

procedure TTFactura.ListarFacturas(xdesde, xhasta, xsubtitulo: String; salida: char);
// Objetivo...: Listar Operaciones de control
var
  total, total1, total2, total3: Real;
  l: Boolean;

  procedure ListarLinea(xtipomov: String; salida: char);
  Begin
    if cabfact.FieldByName('condicion').AsString = xtipomov then Begin
      if not (l) and (xtipomov = '1') then Begin
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, '***  Operaciones de Contado ***', 1, 'Arial, normal, 11', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      end;
      if not (l) and (xtipomov = '2') then Begin
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, '***  Operaciones en Cuenta Corriente ***', 1, 'Arial, normal, 11', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      end;
      list.Linea(0, 0, cabfact.FieldByName('tipo').AsString + ' ' + cabfact.FieldByName('sucursal').AsString + '-' + cabfact.FieldByName('numero').AsString, 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(18, list.Lineactual, utiles.sFormatoFecha(cabfact.FieldByName('fecha').AsString), 2, 'Arial, normal, 9', salida, 'N');
      list.Linea(26, list.Lineactual, setNombreentidad(cabfact.FieldByName('codcli').AsString), 3, 'Arial, normal, 9', salida, 'N');
      if cabfact.FieldByName('condicion').AsString = '1' then list.Linea(65, list.Lineactual, 'Cont.', 4, 'Arial, normal, 9', salida, 'N') else
        list.Linea(65, list.Lineactual, 'Cta.Cte.', 4, 'Arial, normal, 9', salida, 'N');
      if c then list.importe(80, list.Lineactual, '', cabfact.FieldByName('costo').AsFloat, 5, 'Arial, normal, 9') else
        list.importe(80, list.Lineactual, '', 0, 5, 'Arial, normal, 9');
      list.importe(95, list.Lineactual, '', cabfact.FieldByName('subtotal').AsFloat + cabfact.FieldByName('iva').AsFloat, 6, 'Arial, normal, 9');
      list.Linea(95, list.Lineactual, cabfact.FieldByName('estado').AsString, 7, 'Arial, normal, 9', salida, 'S');
      if cabfact.FieldByName('estado').AsString <> 'C' then
        total := total + (cabfact.FieldByName('subtotal').AsFloat + cabfact.FieldByName('iva').AsFloat);
      if cabfact.FieldByName('estado').AsString <> 'C' then
        total1 := total1 + (cabfact.FieldByName('subtotal').AsFloat + cabfact.FieldByName('iva').AsFloat);
      if c then
        if cabfact.FieldByName('estado').AsString <> 'C' then
          total2 := total2 + cabfact.FieldByName('costo').AsFloat;

      l := True;
    end;
  end;

  procedure ListarSubtotal(salida: char);
  Begin
    if total > 0 then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.Derecha(95, list.Lineactual, '', '---------------------------------------------------', 2, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, 'Subtotal Facturado:', 1, 'Arial, negrita, 9', salida, 'N');
      list.Importe(80, list.Lineactual, '', total2, 2, 'Arial, negrita, 9');
      list.Importe(95, list.Lineactual, '', total, 3, 'Arial, negrita, 9');
      list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      total3 := total3 + total2;
      total2 := 0;
    end;
  end;

Begin
  if list.m = 0 then Begin
    List.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Control de Operaciones Lapso: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Comprobante', 1, 'Arial, cursiva, 9');
    List.Titulo(18, List.lineactual, 'Fecha', 2, 'Arial, cursiva, 9');
    List.Titulo(26, List.lineactual, 'Cliente', 3, 'Arial, cursiva, 9');
    List.Titulo(65, List.lineactual, 'T.Op.', 4, 'Arial, cursiva, 9');
    List.Titulo(74, List.lineactual, 'Costo', 5, 'Arial, cursiva, 9');
    List.Titulo(87, List.lineactual, 'Tot.Fact.', 6, 'Arial, cursiva, 9');
    List.Titulo(94, List.lineactual, 'Est.', 7, 'Arial, cursiva, 9');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  end;

  if list.m > 0 then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, xsubtitulo, 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  total := 0; total1 := 0; total2 := 0; total3 := 0;
  cabfact.IndexFieldNames := 'Fecha';
  datosdb.Filtrar(cabfact, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  cabfact.First; l := False;
  while not cabfact.Eof do Begin
    if cabfact.FieldByName('condicion').AsString = '1' then ListarLinea('1', salida);
    cabfact.Next;
  end;
  ListarSubtotal(salida);

  cabfact.First; l := False; total := 0;
  while not cabfact.Eof do Begin
    if cabfact.FieldByName('condicion').AsString = '2' then ListarLinea('2', salida);
    cabfact.Next;
  end;
  ListarSubtotal(salida);

  datosdb.QuitarFiltro(cabfact);
  cabfact.IndexFieldNames := 'Idc;Tipo;Sucursal;Numero';

  if total1 > 0 then Begin
    list.Linea(0, 0, 'Total Facturado:', 1, 'Arial, negrita, 9', salida, 'N');
    list.Importe(80, list.Lineactual, '', total3, 2, 'Arial, negrita, 9');
    list.Importe(95, list.Lineactual, '', total1, 3, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
  end else
    list.Linea(0, 0, 'No hay Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');
end;

procedure TTFactura.ListarFacturas(xdesde, xhasta, xsubtitulo, xcodcli: String; salida: char);
//procedure TTFactura.ListarFacturas(xdesde, xhasta, xsubtitulo: String; salida: char);
// Objetivo...: Listar Inf. Estadísticos
var
  total1, total2, ta, tf: Real;
  l: Boolean;

  procedure ListarLinea(salida: char);
  Begin
    ta := 0; tf := 0;
    list.Linea(0, 0, cabfact.FieldByName('tipo').AsString + ' ' + cabfact.FieldByName('sucursal').AsString + '-' + cabfact.FieldByName('numero').AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(15, list.Lineactual, utiles.sFormatoFecha(cabfact.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(22, list.Lineactual, Copy(setNombreentidad(cabfact.FieldByName('codcli').AsString), 1, 35), 3, 'Arial, normal, 8', salida, 'N');
    if cabfact.FieldByName('condicion').AsString = '1' then list.Linea(57, list.Lineactual, 'Cont.', 4, 'Arial, normal, 8', salida, 'N') else
      list.Linea(57, list.Lineactual, 'Cta.Cte.', 4, 'Arial, normal, 8', salida, 'N');

    if BuscarDetFact(cabfact.FieldByName('idc').AsString, cabfact.FieldByName('tipo').AsString, cabfact.FieldByName('sucursal').AsString, cabfact.FieldByName('numero').AsString, '01') then Begin
      while not detfact.Eof do Begin
        if (cabfact.FieldByName('tipo').AsString <> detfact.FieldByName('tipo').AsString) or (cabfact.FieldByName('sucursal').AsString <> detfact.FieldByName('sucursal').AsString) or (cabfact.FieldByName('numero').AsString <> detfact.FieldByName('numero').AsString) then Break;
        if (detfact.FieldByName('iva').AsFloat <> 0) then ta := ta + (detfact.FieldByName('cantidad').AsFloat * detfact.FieldByName('monto').AsFloat);
        if (detfact.FieldByName('iva').AsFloat = 0) then tf := tf + (detfact.FieldByName('cantidad').AsFloat * detfact.FieldByName('monto').AsFloat);
        detfact.Next;
      end;
    end;

    list.importe(79, list.Lineactual, '', ta, 5, 'Arial, normal, 8');
    list.importe(94, list.Lineactual, '', tf, 6, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, cabfact.FieldByName('estado').AsString, 7, 'Arial, normal, 8', salida, 'S');
    if cabfact.FieldByName('estado').AsString <> 'C' then Begin
      total1 := total1 + ta;
      total2 := total2 + tf;
    end;
    l := True;
  end;

Begin
  List.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, xsubtitulo + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Comprobante', 1, 'Arial, cursiva, 8');
  List.Titulo(15, List.lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
  List.Titulo(22, List.lineactual, 'Cliente', 3, 'Arial, cursiva, 8');
  List.Titulo(57, List.lineactual, 'T.Op.', 4, 'Arial, cursiva, 8');
  List.Titulo(73, List.lineactual, 'Tot.Form.', 5, 'Arial, cursiva, 8');
  List.Titulo(87, List.lineactual, 'Tot.Aran.', 6, 'Arial, cursiva, 8');
  List.Titulo(95, List.lineactual, 'E', 7, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  total1 := 0; total2 := 0;
  cabfact.IndexFieldNames := 'Fecha';
  datosdb.Filtrar(cabfact, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and codcli = ' + '''' + xcodcli + '''');
  cabfact.First; l := False;
  while not cabfact.Eof do Begin
    ListarLinea(salida);
    cabfact.Next;
  end;

  datosdb.QuitarFiltro(cabfact);
  cabfact.IndexFieldNames := 'Idc;Tipo;Sucursal;Numero';

  if total1 + total2 <> 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Total Operaciones:', 1, 'Arial, negrita, 8', salida, 'N');
    list.Importe(79, list.Lineactual, '', total1, 2, 'Arial, negrita, 8');
    list.Importe(94, list.Lineactual, '', total2, 3, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, 'Total General:', 1, 'Arial, negrita, 8', salida, 'N');
    list.Importe(94, list.Lineactual, '', total1 + total2, 2, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  end else
    list.Linea(0, 0, 'No hay Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');

  list.FinList;
end;

procedure TTFactura.ListarMontosFacturas(xdesde, xhasta, xsubtitulo: String; salida: char);
// Objetivo...: Listar Montos en Operaciones de control
var
  total, total1: Real;
  totales: array[1..5] of Real;
  l: Boolean;

  procedure ListarLinea(xtipomov: String; salida: char);
  Begin
    if cabfact.FieldByName('condicion').AsString = xtipomov then Begin
      ivav.getDatos(cabfact.FieldByName('idc').AsString, cabfact.FieldByName('tipo').AsString, cabfact.FieldByName('sucursal').AsString, cabfact.FieldByName('numero').AsString);
      if not (l) and (xtipomov = '1') then Begin
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, '***  Operaciones de Contado ***', 1, 'Arial, normal, 11', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      end;
      if not (l) and (xtipomov = '2') then Begin
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, '***  Operaciones en Cuenta Corriente ***', 1, 'Arial, normal, 11', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      end;
      list.Linea(0, 0, cabfact.FieldByName('tipo').AsString + ' ' + cabfact.FieldByName('sucursal').AsString + '-' + cabfact.FieldByName('numero').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(15, list.Lineactual, utiles.sFormatoFecha(cabfact.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(22, list.Lineactual, Copy(setNombreentidad(cabfact.FieldByName('codcli').AsString), 1, 25), 3, 'Arial, normal, 8', salida, 'N');
      list.importe(55, list.Lineactual, '', cabfact.FieldByName('subtotal').AsFloat + cabfact.FieldByName('iva').AsFloat, 4, 'Arial, normal, 8');
      list.importe(63, list.Lineactual, '', ivav.Neto, 5, 'Arial, normal, 8');
      list.importe(71, list.Lineactual, '', ivav.Connograv, 6, 'Arial, normal, 8');
      list.importe(79, list.Lineactual, '', ivav.Exentas, 7, 'Arial, normal, 8');
      list.importe(87, list.Lineactual, '', ivav.Ivari, 8, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', ivav.Total, 9, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, cabfact.FieldByName('estado').AsString, 10, 'Arial, normal, 8', salida, 'S');
      if cabfact.FieldByName('estado').AsString <> 'C' then
        total := total + (cabfact.FieldByName('subtotal').AsFloat + cabfact.FieldByName('iva').AsFloat);
      if cabfact.FieldByName('estado').AsString <> 'C' then
        total1 := total1 + (cabfact.FieldByName('subtotal').AsFloat + cabfact.FieldByName('iva').AsFloat);
      totales[1] := totales[1] + ivav.Neto;
      totales[2] := totales[2] + ivav.Connograv;
      totales[3] := totales[3] + ivav.Exentas;
      totales[4] := totales[4] + ivav.Ivari;
      totales[5] := totales[5] + ivav.Total;
      l := True;
    end;
  end;

  procedure ListarSubtotal(salida: char);
  Begin
    if total > 0 then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.Derecha(95, list.Lineactual, '', '------------------------------------------------------------------------------------------', 2, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'Subtotal Operaciones:', 1, 'Arial, negrita, 8', salida, 'N');
      list.Importe(55, list.Lineactual, '', total, 2, 'Arial, negrita, 8');
      list.Importe(63, list.Lineactual, '', totales[1], 3, 'Arial, negrita, 8');
      list.Importe(71, list.Lineactual, '', totales[2], 4, 'Arial, negrita, 8');
      list.Importe(79, list.Lineactual, '', totales[3], 5, 'Arial, negrita, 8');
      list.Importe(87, list.Lineactual, '', totales[4], 6, 'Arial, negrita, 8');
      list.Importe(95, list.Lineactual, '', totales[5], 7, 'Arial, negrita, 8');
      list.Linea(96, list.Lineactual, '', 8, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end;
  end;

Begin
  if list.m = 0 then Begin
    List.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Montos Discriminados por Operación Lapso: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Comprobante', 1, 'Arial, cursiva, 8');
    List.Titulo(15, List.lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(22, List.lineactual, 'Cliente', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'T.Fact.', 4, 'Arial, cursiva, 8');
    List.Titulo(59, List.lineactual, 'Neto', 5, 'Arial, cursiva, 8');
    List.Titulo(64, List.lineactual, 'CN Grav.', 6, 'Arial, cursiva, 8');
    List.Titulo(73, List.lineactual, 'Exentas', 7, 'Arial, cursiva, 8');
    List.Titulo(82, List.lineactual, 'IVA RI', 8, 'Arial, cursiva, 8');
    List.Titulo(89, List.lineactual, 'TF IVA', 9, 'Arial, cursiva, 8');
    List.Titulo(96, List.lineactual, 'E', 10, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  end;

  if list.m > 0 then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, xsubtitulo, 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  total := 0; total1 := 0; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0;
  cabfact.IndexFieldNames := 'Fecha';
  datosdb.Filtrar(cabfact, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  cabfact.First; l := False;
  while not cabfact.Eof do Begin
    if cabfact.FieldByName('condicion').AsString = '1' then ListarLinea('1', salida);
    cabfact.Next;
  end;
  ListarSubtotal(salida);

  cabfact.First; l := False; total := 0;
  while not cabfact.Eof do Begin
    if cabfact.FieldByName('condicion').AsString = '2' then ListarLinea('2', salida);
    cabfact.Next;
  end;
  ListarSubtotal(salida);

  datosdb.QuitarFiltro(cabfact);
  cabfact.IndexFieldNames := 'Idc;Tipo;Sucursal;Numero';

  if total1 = 0 then
    list.Linea(0, 0, 'No hay Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');
end;

procedure TTFactura.ListarDetalleFacturas(xlista: TStringList; xcodcli, xsubtitulo, xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Montos en Operaciones de control
var
  total: Real;
  l: Boolean;

  procedure ListarLinea(salida: char);
  Begin
    list.Linea(0, 0, cabfact.FieldByName('tipo').AsString + ' ' + cabfact.FieldByName('sucursal').AsString + '-' + cabfact.FieldByName('numero').AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(15, list.Lineactual, utiles.sFormatoFecha(cabfact.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(22, list.Lineactual, Copy(setNombreentidad(cabfact.FieldByName('codcli').AsString), 1, 55), 3, 'Arial, normal, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', cabfact.FieldByName('subtotal').AsFloat + cabfact.FieldByName('iva').AsFloat, 4, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, cabfact.FieldByName('estado').AsString, 5, 'Arial, normal, 8', salida, 'S');
    if cabfact.FieldByName('estado').AsString <> 'C' then
      total := total + (cabfact.FieldByName('subtotal').AsFloat + cabfact.FieldByName('iva').AsFloat);
    l := True;
  end;

  procedure ListarSubtotal(salida: char);
  Begin
    if total > 0 then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.Derecha(95, list.Lineactual, '', '------------------------------------', 2, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'Subtotal Operaciones:', 1, 'Arial, negrita, 8', salida, 'N');
      list.Importe(95, list.Lineactual, '', total, 2, 'Arial, negrita, 8');
      list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end;
    totfinal := totfinal + total;
  end;

Begin
  if list.m = 0 then Begin
    List.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Montos a Cobrar por Operaciones en Cuenta Corriente', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Comprobante', 1, 'Arial, cursiva, 8');
    List.Titulo(15, List.lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(22, List.lineactual, 'Cliente', 3, 'Arial, cursiva, 8');
    List.Titulo(89, List.lineactual, 'T.Fact.', 4, 'Arial, cursiva, 8');
    List.Titulo(96, List.lineactual, 'E', 5, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  end;

  if list.m > 0 then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, xsubtitulo, 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  total := 0;
  cabfact.IndexFieldNames := 'Fecha';
  datosdb.Filtrar(cabfact, 'codcli = ' + '''' + xcodcli + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  cabfact.First; l := False;
  while not cabfact.Eof do Begin
    if utiles.verificarItemsLista(xlista, cabfact.FieldByName('idc').AsString + cabfact.FieldByName('tipo').AsString + cabfact.FieldByName('sucursal').AsString + cabfact.FieldByName('numero').AsString) then
      if Length(Trim(cabfact.FieldByName('cobrado').AsString)) = 0 then ListarLinea(salida);
    cabfact.Next;
  end;
  ListarSubtotal(salida);

  datosdb.QuitarFiltro(cabfact);
  cabfact.IndexFieldNames := 'Idc;Tipo;Sucursal;Numero';

  if total = 0 then
    list.Linea(0, 0, 'No hay Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');
end;

procedure TTFactura.ListarTotalFinal(salida: char);
Begin
  if totfinal > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Total General:', 1, 'Arial, negrita, 8', salida, 'N');
    list.Importe(95, list.Lineactual, '', totfinal, 2, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;
  totfinal := 0;
end;

function  TTFactura.setNombreentidad(xcodigo: String): String;
// Objetivo...: funcion generica
Begin
  Result := '';
end;

function  TTFactura.setFacturasImpagas(xdesde, xhasta, xcodcli: String): TObjectList;
// Objetivo...: Recuperar Las Facturas Impagas
var
  l: TObjectList;
  objeto: TTFactura;
Begin
  l := TObjectList.Create;
  datosdb.Filtrar(cabfact, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and condicion = ' + '''' + '2' + '''' + ' and codcli = ' + '''' + xcodcli + '''');
  cabfact.First;
  while not cabfact.Eof do Begin
    if (Length(Trim(cabfact.FieldByName('cobrado').AsString)) < 8) and (cabfact.FieldByName('estado').AsString <> 'C') then Begin
      objeto            := TTFactura.Create;
      objeto.Idc        := cabfact.FieldByName('idc').AsString;
      objeto.Tipo       := cabfact.FieldByName('tipo').AsString;
      objeto.Sucursal   := cabfact.FieldByName('sucursal').AsString;
      objeto.Numero     := cabfact.FieldByName('numero').AsString;
      objeto.Entidad    := cabfact.FieldByName('codcli').AsString;
      objeto.Subtotal   := cabfact.FieldByName('subtotal').AsFloat + cabfact.FieldByName('iva').AsFloat;
      objeto.Referencia := cabfact.FieldByName('referencia').AsString;
      objeto.Fecha      := utiles.sFormatoFecha(cabfact.FieldByName('fecha').AsString);
      l.Add(objeto);
    end;
    cabfact.Next;
  end;
  datosdb.QuitarFiltro(cabfact);

  Result :=  l;
end;

function  TTFactura.setFacturasFecha(xdesde, xhasta: String): TQuery;
// Objetivo...: Devolver un set de comprobantes
Begin
  Result := datosdb.tranSQL('select * from ' + cabfact.TableName + ' where fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' order by fecha');
end;

function  TTFactura.setFacturasCliente(xcodcli: String): TQuery;
// Objetivo...: Devolver un set de comprobantes
Begin
  Result := datosdb.tranSQL('select * from ' + cabfact.TableName + ' where codcli = ' + '''' + xcodcli + '''' + ' order by fecha');
end;

function  TTFactura.setFacturasNumero(xidc, xtipo, xsucursal, xnumero: String): TQuery;
// Objetivo...: Devolver un set de comprobantes
Begin
  Result := datosdb.tranSQL('select * from ' + cabfact.TableName + ' where idc = ' + '''' + xidc + '''' + ' and tipo = ' + '''' + xtipo + '''' + ' and sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''');
end;

function  TTFactura.setFacturasPagas(xdesde, xhasta, xcodcli: String): TObjectList;
// Objetivo...: Recuperar Las Facturas Impagas
var
  l: TObjectList;
  objeto: TTFactura;
Begin
  l := TObjectList.Create;
  datosdb.Filtrar(cabfact, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and condicion = ' + '''' + '2' + '''' + ' and codcli = ' + '''' + xcodcli + '''');
  cabfact.First;
  while not cabfact.Eof do Begin
    if (Length(Trim(cabfact.FieldByName('cobrado').AsString)) = 8) then Begin
      objeto            := TTFactura.Create;
      objeto.Idc        := cabfact.FieldByName('idc').AsString;
      objeto.Tipo       := cabfact.FieldByName('tipo').AsString;
      objeto.Sucursal   := cabfact.FieldByName('sucursal').AsString;
      objeto.Numero     := cabfact.FieldByName('numero').AsString;
      objeto.Entidad    := cabfact.FieldByName('codcli').AsString;
      objeto.Subtotal   := cabfact.FieldByName('subtotal').AsFloat + cabfact.FieldByName('iva').AsFloat;
      objeto.Referencia := cabfact.FieldByName('referencia').AsString;
      objeto.Fecha      := utiles.sFormatoFecha(cabfact.FieldByName('fecha').AsString);
      l.Add(objeto);
    end;
    cabfact.Next;
      //l.Add(cabfact.FieldByName('idc').AsString + ';1' + cabfact.FieldByName('tipo').AsString + ';2' + cabfact.FieldByName('sucursal').AsString + cabfact.FieldByName('numero').AsString + cabfact.FieldByName('codcli').AsString + utiles.FormatearNumero(FloatToStr (cabfact.FieldByName('subtotal').AsFloat + cabfact.FieldByName('iva').AsFloat )) + ';3' + cabfact.FieldByName('referencia').AsString);
  end;
  datosdb.QuitarFiltro(cabfact);

  Result :=  l;
end;

procedure TTFactura.CancelarFactura(xidc, xtipo, xsucursal, xnumero, xfecha: String);
// Objetivo...: Cancelar Factura
Begin
  if BuscarFact(xidc, xtipo, xsucursal, xnumero) then Begin
    cabfact.Edit;
    cabfact.FieldByName('cobrado').AsString := utiles.sExprFecha2000(xfecha);
    try
      cabfact.Post
     except
      cabfact.Cancel
    end;
    datosdb.closeDB(cabfact); cabfact.Open;
  end;
end;

function  TTFactura.setFacturasPorReferencia(xreferencia: String): TObjectList;
// Objetivo...: Recuperar Las Facturas Impagas
var
  l: TObjectList;
  objeto: TTFactura;
Begin
  l := TObjectList.Create;
  datosdb.Filtrar(cabfact, 'referencia = ' + '''' + xreferencia + '''');
  cabfact.First;
  while not cabfact.Eof do Begin
    if Length(Trim(cabfact.FieldByName('cobrado').AsString)) = 8 then Begin
      objeto            := TTFactura.Create;
      objeto.Idc        := cabfact.FieldByName('idc').AsString;
      objeto.Tipo       := cabfact.FieldByName('tipo').AsString;
      objeto.Sucursal   := cabfact.FieldByName('sucursal').AsString;
      objeto.Numero     := cabfact.FieldByName('numero').AsString;
      objeto.Entidad    := cabfact.FieldByName('codcli').AsString;
      objeto.Subtotal   := cabfact.FieldByName('subtotal').AsFloat + cabfact.FieldByName('iva').AsFloat;
      objeto.Referencia := cabfact.FieldByName('referencia').AsString;
      objeto.Fecha      := utiles.sFormatoFecha(cabfact.FieldByName('fecha').AsString);
      l.Add(objeto);
    end;
    cabfact.Next;
  end;
  datosdb.QuitarFiltro(cabfact);

  Result :=  l;
end;

procedure TTFactura.getFacturasPorReferencia(xreferencia: String);
// Objetivo...: Recuperar Factura por Referencia
Begin
  cabfact.IndexFieldNames := 'Referencia';
  cabfact.FindKey([xreferencia]);
  getDatosFact(cabfact.FieldByName('idc').AsString, cabfact.FieldByName('tipo').AsString, cabfact.FieldByName('sucursal').AsString, cabfact.FieldByName('numero').AsString);
end;

function  TTFactura.setFacturas(xdesde, xhasta: String): TObjectList;
// Objetivo...: Recuperar Las Facturas Impagas
var
  l: TObjectList;
  objeto: TTFactura;
Begin
  l := TObjectList.Create;
  datosdb.Filtrar(cabfact, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and condicion = ' + '''' + '2' + '''');
  cabfact.First;
  while not cabfact.Eof do Begin
    objeto            := TTFactura.Create;
    objeto.Fecha      := utiles.sFormatoFecha(cabfact.FieldByName('fecha').AsString);
    objeto.Idc        := cabfact.FieldByName('idc').AsString;
    objeto.Tipo       := cabfact.FieldByName('tipo').AsString;
    objeto.Sucursal   := cabfact.FieldByName('sucursal').AsString;
    objeto.Numero     := cabfact.FieldByName('numero').AsString;
    objeto.Entidad    := cabfact.FieldByName('codcli').AsString;
    objeto.Subtotal   := cabfact.FieldByName('subtotal').AsFloat + cabfact.FieldByName('iva').AsFloat;
    objeto.Referencia := cabfact.FieldByName('referencia').AsString;
    objeto.Cobrado    := utiles.sFormatoFecha(cabfact.FieldByName('cobrado').AsString);
    l.Add(objeto);
    cabfact.Next; 
  end;
  datosdb.QuitarFiltro(cabfact);

  Result :=  l;
end;

procedure TTFactura.ReactivarFactura(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: Cancelar Factura
Begin
  if BuscarFact(xidc, xtipo, xsucursal, xnumero) then Begin
    cabfact.Edit;
    cabfact.FieldByName('cobrado').AsString    := '';
    cabfact.FieldByName('referencia').AsString := '';
    try
      cabfact.Post
     except
      cabfact.Cancel
    end;
    datosdb.closeDB(cabfact); cabfact.Open;
  end;
end;

procedure TTFactura.PresentarInforme;
// Objetivo...: Presentar Informe
begin
  list.FinList;
  iniList := False;
  list.m := 0;
end;

procedure TTFactura.GuardarReferenciaCobroLote(xidc, xtipo, xsucursal, xnumero, xreferencia: String);
// Objetivo...: guardar referencia cobro en lote
begin
  if BuscarFact(xidc, xtipo, xsucursal, xnumero) then Begin
    cabfact.Edit;
    cabfact.FieldByName('referencia').AsString := xreferencia;
    try
      cabfact.Post
     except
      cabfact.Cancel
    end;
    datosdb.closeDB(cabfact); cabfact.Open;
  end;
end;

procedure TTFactura.BorrarReferenciaCobroLote(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: guardar referencia cobro en lote
begin
  if BuscarFact(xidc, xtipo, xsucursal, xnumero) then Begin
    cabfact.Delete;
    datosdb.closeDB(cabfact); cabfact.Open;
  end;
end;

procedure TTFactura.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  ivav.conectar;
  if conexiones = 0 then Begin
    if not cabfact.Active then cabfact.Open;
    if not detfact.Active then detfact.Open;
    if not observac.Active then observac.Open;
    if not modeloImp.Active then modeloImp.Open;
    if not mov_modulos.Active then mov_modulos.Open;
  end;
  c := False;
  if (datosdb.verificarSiExisteCampo(detfact, 'costo')) and datosdb.verificarSiExisteCampo(cabfact, 'costo') then c := True;
  Inc(conexiones);
end;

procedure TTFactura.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  ivav.desconectar;
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(cabfact);
    datosdb.closeDB(detfact);
    datosdb.closeDB(observac);
    datosdb.closeDB(modeloImp);
    datosdb.closeDB(mov_modulos);
  end;
end;

end.
