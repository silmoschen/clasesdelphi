unit Ccctecl;

interface

uses SysUtils, DB, DBTables, CBDT, CCtactes, Cliengar, CGarante, CComregi, CListar, CUtiles, CIDBFM, CAdmNumCompr, contenedorMemo, Forms;

const
  meses: array[1..12] of string = ('enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'setiembre', 'octubre', 'noviembre', 'diciembre');

type

TTCtactecl = class(TTCtacte)
  impEnt: real; ExisteComprobante: boolean;
  idcarta: shortint; cabecera, cuerpo, fe, fc: string;
  modeloc, enviocartas, enviocobrador, morosos: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    VerifCliente(xcodcli: string): boolean; virtual;
  function    getCliente(xcodcli: string): string; virtual;
  function    getGarante: string;
  function    getDireccion(xcodcli: string): string;
  function    getConcepto(xidtitular, xclavecta: String): String;

  function    BuscarRecibo(xidcompr, xtipo, xsucursal, xnumero: string): boolean;
  procedure   GrabarTran(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto: string; ximporte, xentrega, xImporteEnt, xcuota: real);
  procedure   GrabarPago(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto: string; ximporte, xentrega, xcuota, xrecargo: real; ftc, fti, fsu, fnu, fit: string);
  procedure   BorrarPago(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string);
  procedure   BorrarComprobante(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
  function    getPagos(xclavecta, xidtitular: string): TQuery;
  function    getRecibos(xclavecta, xidtitular: string): TQuery;
  procedure   getDatosFactura(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
  procedure   Depurar(fecha: string);
  procedure   DepurarInf(fecha, xco, xti, xsu, xnu, xtt, xcl: string);

  function    getFactventa(xidc, xtipo, xsucursal, xnumero: string): TQuery;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   rListar(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
  procedure   rListarPlan(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
  procedure   rSubtotales(salida: char);
  procedure   rSubtotales1(salida: char; t: string);
  procedure   ObtenerSaldo(xidtitular, xclavecta: string);
  procedure   rList_Linea(salida: char);
  procedure   ListarVencimientos(xidtitular, xclavecta, fecha, xcriterio: string; salida: char; cantcuotas: integer; xinteres: real; listresumido: boolean);
  procedure   ListPlanillaSaldos(xidtitular, xclavecta, fecha: string; ListCtasSaldadas: Boolean; salida: char); virtual;
  procedure   rListarRes(xidtitular, iniciar, finalizar: string; salida: char);
  function    getMcctcl: TQuery; overload;
  function    getMcctcl(xt, xc: string): TQuery; overload;
  function    EstsqlSaldosCobrar(fecha1, fecha2: string): TQuery;         // SQL Estadísticas
  function    EstsqlCobrosEfectuados(fecha1, fecha2: string): TQuery;
  function    EstsqlCuotasVencidas(fecha1, fecha2: string): TQuery;
  function    AuditoriaFacturasEmitidas(fecha: string): TQuery;  // SQL Auditoría
  function    AuditoriaRecaudacionesCobros(fecha: string): TQuery;
  procedure   ListarFichaPlanPagos(xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero: string; salida: char); virtual;
  procedure   ActualizarUltimoReciboImpreso(xnumero: string);
  procedure   ListarEstadoCuentas(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
  procedure   ListarAntecedentes(xidtitular, xnombre, listresumen: string; salida: char);
  procedure   ModificarTitular(xidtitular, xnombre: string);

  // Tratamiento de cobradores
  procedure   MarcarEnvioCartaCobrador(xidtitular, xclavecta, xfecha: string);
  procedure   BorrarCartasEnviadas(xdfecha, xhfecha: string; xtipo: shortint);
  function    setCartasEnviadasCobrar: TQuery;
  procedure   BorrarCartaCobrador(xidtitular, xclavecta, xfecha: string);

  // Tratamiento de cartas enviadas
  function    setCartasEnviadas: TQuery;
  procedure   BorrarCartaEnviada(xidtitular, xclavecta, xidcarta, xfecha: string);

  // Tratamiento de deudores
  procedure   DeterminacionDeMorosos(xfecha, xmeses: string);
  procedure   ListarMorosos(salida: char);
  procedure   ListarMorosos_DetalleCuotasAtrasadas(xidtitular: String; salida: char);
  procedure   ListarmorososQuePagaron(xdfecha, xhfecha: string; salida: char);
  procedure   TransferirAlFicheroDeMorosos(xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero: string; ximporte: real);
  procedure   MarcarPagoMoroso(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string);

  procedure   conectar;
  procedure   desconectar;

  // Tratamiento de Cartas en formatos preimpresos
  procedure   GuardarFormatoCartas(xidcarta: shortint; xcabecera, xcuerpo, xfe, xfc: string);
  procedure   getDatosFormatoCartas(xidcarta: shortint);
  procedure   BorrarDatosFormatoCartas;
  procedure   ListarCartas(xidcarta: shortint; xidtitular, xclavecta, fecha, xcriterio: string; salida: char; cantcuotas: integer; xinteres: real);
  procedure   conectarCartas;
  procedure   desconectarCartas;
 protected
  { Declaraciones Protegidas }
  TSQL: TQuery; listdat: boolean;
  rsCliente, domCliente, rsLocalidad, rsProvincia, rsCodpfis, rsNrocuit, listconcepto, pr, dom, docc: string;
  function    ExtraerSaldos(xfecha: string): TQuery;
  procedure   titulosPS(xfecha: String; salida: char);
  procedure   totalPS(salida: char); override;
  procedure   listRecibo(xconcepto: string; ximporte: real; salida: char);
  procedure   tituloVencimientos(xfecha: string; salida: char; xresumido: boolean);
  procedure   GenerarFichaPago(xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero: string; salida: char);
  procedure   List_LineaPlan(salida: char);
  procedure   ListDatosCliente(salida: char); virtual;
  function    DatosClientePS(xcodcli, xclavecta: string): string; virtual;
  procedure   DatosClienteVenc(xcodcli: string); virtual;
  function    setOperacionesTransHist(xidtitular: string): TQuery; virtual;
  function    setOperacionesTrans(xidtitular: string): TQuery; virtual;
  procedure   DatosCliente; virtual;

  // Gestion de notificaciones - cartas judiciales y extrajudiciales
  procedure   ListClientesRecibieronCarta(xdf, xhf: string; salida: char);
  procedure   ListClientesQuePagaron(xdf, xhf: string; salida: char);
  function    DeterminacionDeMorososQuePagaron(xdfecha, xhfecha: string): TQuery;

  // Gestion de pagos por cobrador
  procedure   ListClientesVistadosPorCobrador(xdf, xhf: string; salida: char);
  procedure   ListClientesVistadosQuePagaron(xdf, xhf: string; salida: char);
 private
  { Declaraciones Privadas }
  cuotaspendientes: Integer;
  importe_cuota: real; cuotasok: boolean;
  conexiones, conexion1, max: shortint;
  loc: string;
  fpr: array[1..50, 1..2] of string;
  fim: array[1..50, 1..2] of real;
  archtxt: Text;
  function    RecalcularEntregas(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string): real;
  procedure   GrabarFact(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm: string; ximporte, xentrega, xImporteEnt: real);
  procedure   MarcarCuotaPaga(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string; ximporte, xcuota: real);
  procedure   List_linea(salida: char);
  procedure   cList_linea(salida: char);
  procedure   TitulosResctas(salida: char);
  procedure   BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
  procedure   ListarPlanDePagos(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
  procedure   ListTitFicha(salida: char);
  procedure   ListTitFichaPagos(salida: char);
  procedure   ListarResumen(xidtitular, iniciar, finalizar: string; salida: char);
  procedure   ListarResumenCuenta(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
  procedure   LisMov(listresumen: string; salida: char);
  procedure   tot_deuda(salida: char; listresumen: boolean);
  procedure   ListCuotasImp(xcantcuotas: integer; xfecha: string; salida: char; listresumen: boolean);
  procedure   ListTexto(xidcarta: shortint; campo, xnombre, xdomicilio, xlocalidad: string; salida: char);
  procedure   ListCuerpo(xidcarta: shortint; campo: string; ximporte, xpago: real; salida: char);
  procedure   ListarRecibo(xconcepto: string; ximporte: real; salida: char);
  // Tratamiento de deudores
  function    CuotasDeMorosos: TQuery; overload;
  function    CuotasDeMorosos(xidtitular: String): TQuery; overload;
  procedure   ListarLineaMorosos(salida: char);
  procedure   SubtotalDetalle(salida: char);
  function    MorososQueHanCanceladoDeuda(xdfecha, xhfecha: string): TQuery;
end;

function cccl: TTCtactecl;

implementation

var
  xctactecl: TTCtactecl = nil;

constructor TTCtactecl.Create;
begin
  inherited Create;
  conexiones := 0;
  modeloc       := datosdb.openDB('modcarta', 'Idcarta');
  enviocartas   := datosdb.openDB('enviocartas', 'Idtitular;Clavecta;Idcarta');
  enviocobrador := datosdb.openDB('enviocobrador', 'Idtitular;Clavecta');
end;

destructor TTCtactecl.Destroy;
begin
  inherited Destroy;
end;

function TTCtactecl.VerifCliente(xcodcli: string): boolean;
// Objetivo...: Verificamos que el proveedor ingresado Exista
begin
  if clientegar.Buscar(xcodcli) then Result := True else Result := False;
end;

function TTCtactecl.getCliente(xcodcli: string): string;
// Objetivo...: Recuperamos el Cliente titular de la Cuenta
begin
  clientegar.getDatos(xcodcli);
  Result := clientegar.Nombre;
end;

function TTCtactecl.getGarante: string;
// Objetivo...: Recuperamos el Cliente titular de la Cuenta
begin
  if Length(Trim(clientegar.docgarante)) > 0 then Result := garante.getNombre(clientegar.docgarante) else Result := '';
end;

function TTCtactecl.getDireccion(xcodcli: string): string;
// Objetivo...: Recuperamos la Direccion
begin
  clientegar.getDatos(xcodcli);
  Result := clientegar.Domicilio;
end;

function TTCtactecl.getConcepto(xidtitular, xclavecta: String): String;
// Objetivo...: Devolver el concepto de la ctacte
var
  r: TQuery;
Begin
  r := datosdb.tranSQL('select concepto from ' + tabla3.TableName + ' where idtitular = ' + '"' + xidtitular + '"' + ' and clavecta = ' + '"' + xclavecta + '"' + ' and items = ' + '"' + '-1' + '"');
  r.Open;
  Result := r.FieldByName('concepto').AsString;
  r.Close; r.Free;
end;

function TTCtactecl.getFactventa(xidc, xtipo, xsucursal, xnumero: string): TQuery;
// Objetivo...: Buscar un comprobante Registrado con el Id de Ventas
begin
  if datosdb.Buscar(tabla2, 'idcompr', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero) then
    begin
      TransferirDatos(True);
      // Atributos NO Heredados o  Sobrecargados
      clavecta  := tabla2.FieldByName('clavecta').AsString;
      idtitular := tabla2.FieldByName('idtitular').AsString;
      fecha     := utiles.sFormatoFecha(tabla2.FieldByName('fecha').AsString);
      importe   := tabla2.FieldByName('importe').AsFloat;
      entrega   := tabla2.FieldByName('entrega').AsFloat;
      impEnt    := tabla2.FieldByName('impEnt').AsFloat;
      // Filtramos el Plan
      Result  := getPlan(clavecta, idtitular, xidc, xtipo, xsucursal, xnumero);
      ExisteComprobante := True;
    end
  else
    begin
      TransferirDatos(False);
      ExisteComprobante := False;
      impEnt := 0;
      Result := nil;
    end;
end;

procedure TTCtactecl.getDatosFactura(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
// Objetivo...: Atributos de la Fact. que genero la operacion
begin
  inherited getMovimiento(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, '-1');
end;

function TTCtactecl.BuscarRecibo(xidcompr, xtipo, xsucursal, xnumero: string): boolean;
// Objetivo...: Verificar la existencia de un recibo
var
  i: string;
begin
  i := tabla3.IndexFieldNames;
  tabla3.IndexFieldNames := 'idcompr;tipo;sucursal;numero';
  if datosdb.Buscar(tabla3, 'idcompr', 'tipo', 'sucursal', 'numero', xidcompr, xtipo, xsucursal, xnumero) then Begin
    clavecta  := tabla3.FieldByName('clavecta').AsString;
    idtitular := tabla3.FieldByName('idtitular').AsString;
    Result := True;
   end
  else
    Result := False;
  tabla3.IndexFieldNames := i;
end;

procedure TTCtactecl.GrabarTran(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto: string; ximporte, xentrega, xImporteEnt, xcuota: real);
// Objetivo...: Grabar los movimientos Generados a partir de los planes, cobros/o pagos efectuados
begin
  existenMov := False;
  if xitems = '-1' then Begin
    GrabarFact(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm, ximporte, xentrega, xImporteEnt);
    if Buscar(xclavecta, xidtitular) then Begin     { Regrabamos el concepto en la Ficha }
      tabla1.Edit;
      tabla1.FieldByName('obs').AsString := xconcepto;
      try
        tabla1.Post
       except
        tabla1.Cancel
      end;
    end;
  end;
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then Begin
    existenMov := True;
    if xitems = '000' then tabla3.Edit;
    if xitems = '-1' then Begin // Si existia ya el plan cargado lo anulamos
      BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal,xnumero);
      tabla3.Append;
  end
    end else
      tabla3.Append;
   tabla3.FieldByName('clavecta').AsString  := xclavecta;
   tabla3.FieldByName('idtitular').AsString := xidtitular;
   tabla3.FieldByName('idcompr').AsString   := xidc;
   tabla3.FieldByName('tipo').AsString      := xtipo;
   tabla3.FieldByName('sucursal').AsString  := xsucursal;
   tabla3.FieldByName('numero').AsString    := xnumero;
   tabla3.FieldByName('items').AsString     := xitems;
   tabla3.FieldByName('fecha').AsString     := utiles.sExprFecha(xfecha);
   tabla3.FieldByName('importe').AsFloat    := ximporte;
   tabla3.FieldByName('DC').AsInteger       := StrToInt(xtm);
   tabla3.FieldByName('concepto').AsString  := xconcepto;
   tabla3.FieldByName('estado').AsString    := 'I';
   if (xitems = '-1') or (xidc = 'SIN') then tabla3.FieldByName('XN').AsString := 'FACT.ORIG.';
   if xitems = '0' then Begin
     tabla3.FieldByName('XC').AsString     := xidc;
     tabla3.FieldByName('XT').AsString     := xtipo;
     tabla3.FieldByName('XS').AsString     := xsucursal;
     tabla3.FieldByName('XN').AsString     := xnumero;
     tabla3.FieldByName('estado').AsString := 'E';
   end;
   try
     tabla3.Post; tabla3.Refresh;
   except
     tabla3.Cancel;
   end;
end;

procedure TTCtactecl.BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
// Objetivo...: Eliminar detalle del comprobante
var
  i: integer; xit: string;
begin
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, '-1')  then tabla3.Delete;
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, '0') then tabla3.Delete;
  For i := 1 to 999 do Begin
    xit := utiles.sLlenarIzquierda(IntToStr(i), 3, '0');
    if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xit) then tabla3.Delete else Break;
  end;
end;

procedure TTCtactecl.BorrarComprobante(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
// Objetivo...: Eliminar un comprobante - detalle y relaciones
begin
  if datosdb.Buscar(tabla2, 'idcompr', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero) then tabla2.Delete;
  BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero);
  // Actualizamos los atributos
  if tabla2.Active then getDatos(tabla2.FieldByName('clavecta').AsString, tabla2.FieldByName('idtitular').AsString, tabla2.FieldByName('idcompr').AsString, tabla2.FieldByName('tipo').AsString, tabla2.FieldByName('sucursal').AsString, tabla2.FieldByName('numero').AsString, tabla2.FieldByName('DC').AsString);
end;

procedure TTCtactecl.GrabarPago(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto: string; ximporte, xentrega, xcuota, xrecargo: real; ftc, fti, fsu, fnu, fit: string);
// Objetivo...: Grabar los movimientos Generados a partir de los planes, cobros/o pagos efectuados
var
  f: boolean;
begin
  f := tabla3.Filtered;
  if tabla3.Filtered then tabla3.Filtered := False;
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then tabla3.Edit else tabla3.Append;
  tabla3.FieldByName('clavecta').AsString  := xclavecta;
  tabla3.FieldByName('idtitular').AsString := xidtitular;
  tabla3.FieldByName('idcompr').AsString   := xidc;
  tabla3.FieldByName('tipo').AsString      := xtipo;
  tabla3.FieldByName('sucursal').AsString  := xsucursal;
  tabla3.FieldByName('numero').AsString    := xnumero;
  tabla3.FieldByName('items').AsString     := xitems;
  tabla3.FieldByName('fecha').AsString     := utiles.sExprFecha(xfecha);
  tabla3.FieldByName('importe').AsFloat    := ximporte;
  tabla3.FieldByName('recargo').AsFloat    := xrecargo;
  tabla3.FieldByName('DC').AsInteger       := StrToInt(xtm);
  tabla3.FieldByName('concepto').AsString  := xconcepto;
  tabla3.FieldByName('estado').AsString    := 'R';
  tabla3.FieldByName('fepago').AsString    := utiles.sExprFecha(DateToStr(Now));
  // Datos de la cuota/factura a la que imputa

  tabla3.FieldByName('XC').AsString        := ftc;
  tabla3.FieldByName('XT').AsString        := fti;
  tabla3.FieldByName('XS').AsString        := fsu;
  tabla3.FieldByName('XN').AsString        := fnu;
  try
    tabla3.Post; tabla3.Refresh;
    // Si el monto ingresado es igual al de la Cuota, marcamos la misma como paga
    MarcarCuotaPaga(xclavecta, xidtitular, ftc, fti, fsu, fnu, xitems, ximporte, xcuota);
  except
    tabla3.Cancel;
  end;
  importe_cuota := ximporte;
  if f then tabla3.Filtered := True;
  // Atributos del movimiento
  clavecta := xclavecta; idtitular := xidtitular; idc := xidc;  tipo := xtipo; sucursal := xsucursal; numero := xnumero; items := xitems;
end;

procedure TTCtactecl.MarcarCuotaPaga(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string; ximporte, xcuota: real);
// Objetivo...: Marcar una cuota como paga
begin
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then Begin
    importe_cuota := ximporte;
    importe_cuota := RecalcularEntregas(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems); // Determino si el pago fue total o parcial
    Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems);
    tabla3.Edit;
    if importe_cuota = tabla3.FieldByName('importe').AsFloat then tabla3.FieldByName('estado').AsString := 'P' else tabla3.FieldByName('estado').AsString := 'I';
    tabla3.FieldByName('entrega').AsFloat := importe_cuota;
    tabla3.FieldByName('fepago').AsString := utiles.sExprFecha(DateToStr(Now));
    try
      tabla3.Post; tabla3.Refresh;
    except
      tabla3.Cancel;
    end;
  end;
end;

function TTCtactecl.RecalcularEntregas(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string): real;
// Objetivo...: obtener el total pagado para una factura
var
  total: real;
begin
  total := 0;
  tabla3.IndexFieldNames := 'idtitular;clavecta;XC;XT;XS;XN;items';
  if datosdb.Buscar(tabla3, 'idtitular', 'clavecta', 'XC', 'XT', 'XS', 'XN', 'items', xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero, xitems) then Begin
    while not tabla3.EOF do Begin
      if (tabla3.FieldByName('idtitular').AsString = xidtitular) and (tabla3.FieldByName('clavecta').AsString = xclavecta) and (tabla3.FieldByName('xc').AsString = xidc) and
         (tabla3.FieldByName('xt').AsString = xtipo) and (tabla3.FieldByName('xs').AsString = xsucursal) and (tabla3.FieldByName('xn').AsString = xnumero) and (tabla3.FieldByName('items').AsString = xitems) then
         total := total + tabla3.FieldByName('importe').AsFloat else Break;
      tabla3.Next;
    end;
  end;
  tabla3.IndexFieldNames := 'Idtitular;Clavecta;Idcompr;Tipo;Sucursal;Numero;Items';
  Result := total;
end;

procedure TTCtactecl.BorrarPago(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string);
// Objetivo...: Marcar una cuota como paga
var
  xxc, xxt, xxs, xxn: string;
  montocuota: real;
begin
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then
   begin
     // 1º Quitamos la Marca a la cuota Paga
     xxc := tabla3.FieldByName('XC').AsString;
     xxt := tabla3.FieldByName('XT').AsString;
     xxs := tabla3.FieldByName('XS').AsString;
     xxn := tabla3.FieldByName('XN').AsString;

     // Borramos el registro
     if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then tabla3.Delete;

     // Recalculamos las cuotas
     montocuota := RecalcularEntregas(xclavecta, xidtitular, xxc, xxt, xxs, xxn, xitems);

     if Buscar(xclavecta, xidtitular, xxc, xxt, xxs, xxn, xitems) then
       begin
         tabla3.Edit;
         tabla3.FieldByName('estado').AsString := 'I';   // Modificamos la marca
         tabla3.FieldByName('entrega').AsFloat := montocuota; // Grabamos el saldo de la cuota
         try
           tabla3.Post; tabla3.Refresh;
         except
           tabla3.Cancel;
         end;
       end;
   end;
end;

procedure TTCtactecl.GrabarFact(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm: string; ximporte, xentrega, xImporteEnt: real);
// Objetivo...: Grabar una Factura
begin
  if datosdb.Buscar(tabla2, 'idcompr', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('clavecta').AsString  := xclavecta;
  tabla2.FieldByName('idtitular').AsString := xidtitular;
  tabla2.FieldByName('idcompr').AsString   := xidc;
  tabla2.FieldByName('tipo').AsString      := xtipo;
  tabla2.FieldByName('sucursal').AsString  := xsucursal;
  tabla2.FieldByName('numero').AsString    := xnumero;
  tabla2.FieldByName('DC').AsString        := xtm;
  tabla2.FieldByName('fecha').AsString     := utiles.sExprFecha(xfecha);
  tabla2.FieldByName('importe').AsFloat    := ximporte;
  tabla2.FieldByName('entrega').AsFloat    := xentrega;
  tabla2.FieldByName('ImpEnt').AsFloat     := ximporteEnt;
  try
    tabla2.Post; tabla2.Refresh;
  except
    tabla2.Cancel;
  end;
end;

function TTCtactecl.getPagos(xclavecta, xidtitular: string): TQuery;
// Objetivo...: Devolver un Set de las Cuentas Corrientes Disponibles para un titular
begin
  Result := datosdb.tranSQL('SELECT items, fecha, concepto, importe, recargo, estado, entrega, moroso, idcompr, tipo, sucursal, numero, dc FROM ' +  tabla3.TableName + ' WHERE clavecta = ' + '"' + xclavecta + '"' + ' AND idtitular = ' + '"' + xidtitular + '"' + ' ORDER BY items');
end;

function TTCtactecl.getRecibos(xclavecta, xidtitular: string): TQuery;
// Objetivo...: Devolver un Set de los Recibos Ingresados
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla3.TableName + ' WHERE clavecta = ' + '"' + xclavecta + '"' + ' AND idtitular = ' + '"' + xidtitular + '"' + ' AND estado = ' + '"' + 'R' + '"' + ' ORDER BY items');
end;

procedure TTCtactecl.Depurar(fecha: string);
// Objetivo...: depurar los movimientos de cuenta corriente
var
  r: TQuery;
begin
  // Aislamos los comprobantes cancelados
  r := datosdb.tranSQL('SELECT * FROM ' + tabla3.TableName + ' WHERE estado = ' + '"' + 'P' + '"' + ' AND fecha < ' + '"' + utiles.sExprFecha(fecha) + '"');
  // Filtramos aquellos que resulten ser Facturas o Saldos iniciales
  datosdb.Filtrar(r, 'XN = ' + '"' + 'FACT.ORI' + '"' + ' OR items = ' + '"' + '000' + '"');
  r.Open; r.First;

  while not r.EOF do Begin    // Procesamos el Set de Comprobantes Listos para Depurar
    // Extraemos la información del comprobante
    DepurarInf(fecha, r.FieldByName('idcompr').AsString, r.FieldByName('tipo').AsString, r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString, r.FieldByName('idtitular').AsString, r.FieldByName('clavecta').AsString);
    r.Next;
  end;

  r.Close; r.Free;
end;

procedure TTCtactecl.DepurarInf(fecha, xco, xti, xsu, xnu, xtt, xcl: string);
// Objetivo...: Realizar tarea de depuración
begin
  // Eliminamos recibo y entrega inicial
  datosdb.tranSQL('DELETE FROM ' + tabla3.TableName + ' WHERE XC = ' + '"' + xco + '"' + ' AND XT = ' + '"' + xti + '"' + ' AND XS = ' + '"' + xsu + '"' + ' AND XN = ' + '"' + xnu + '"' + ' AND idtitular = ' + '"' + xtt + '"' + ' AND clavecta = ' + '"' + xcl + '"' + ' AND DC = ' + '"' + '2' + '"');
  // Eliminamos Factura
  datosdb.tranSQL('DELETE FROM ' + tabla3.TableName + ' WHERE idcompr = ' + '"' + xco + '"' + ' AND tipo = ' + '"' + xti + '"' + ' AND sucursal = ' + '"' + xsu + '"' + ' AND numero = ' + '"' + xnu + '"' + ' AND idtitular = ' + '"' + xtt + '"' + ' AND clavecta = ' + '"' + xcl + '"' + ' AND DC = ' + '"' + '1' + '"');
  // Eliminamos los saldos iniciales Pagados
  datosdb.tranSQL('DELETE FROM ' + tabla3.TableName + ' WHERE idtitular = ' + '"' + xtt + '"' + ' AND clavecta = ' + '"' + xcl + '"' + ' AND estado = ' + '"' + 'P' + '"' + ' AND idcompr = ' + '"' + 'SIN' + '"');
  // Eliminamos las Facturas canceladas
  if datosdb.Buscar(tabla2, 'idcompr', 'tipo', 'sucursal', 'numero', xco, xti, xsu, xnu) then tabla2.Delete;
  // Eliminamos la Ficha
  Borrar(xcl, xtt);
end;

procedure TTCtactecl.List_linea(salida: char);
// Objetivo...: Listar una Línea
var
  pr: string;
begin
  clientegar.getDatos(tabla1.FieldByName('idtitular').AsString);
  if clientegar.codigo <> idant then pr := clientegar.nombre else pr := ' ';
  List.Linea(0, 0, tabla1.FieldByName('idtitular').AsString + ' ' + tabla1.FieldByName('clavecta').AsString + '    ' + pr, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(57, List.lineactual, tabla1.FieldByName('obs').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(90, List.lineactual, utiles.sFormatoFecha(tabla1.FieldByName('fealta').AsString), 3, 'Arial, normal, 8', salida, 'S');
  idant := tabla1.FieldByName('idtitular').AsString;
  total := total + 1;
end;

procedure TTCtactecl.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de clientees Definidas
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Listado de Cuentas Corrientes de Clientes', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cuenta       Titular', 1, 'Arial, cursiva, 8');
  List.Titulo(57, List.lineactual, 'Observaciones', 2, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Fe. Alta', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla1.First; total := 0;
  while not tabla1.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla1.FieldByName('idtitular').AsString >= iniciar) and (tabla1.FieldByName('idtitular').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla1.FieldByName('idtitular').AsString < iniciar) or (tabla1.FieldByName('idtitular').AsString > finalizar) then List_linea(salida);

      tabla1.Next;
    end;

    List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
    List.Linea(0, 0, 'Cantidad de cuentas listadas :  ' + FloatToStr(total), 1, 'Arial, normal, 8', salida, 'S');
    List.FinList;

    tabla1.First;
end;

procedure TTCtactecl.rList_linea(salida: char);
// Objetivo...: Listar una Línea - ruptura por cuenta
var
  pr: string;
begin
  if tsql.FieldByName('DC').AsString = '1' then td := td + tsql.FieldByName('importe').AsFloat;
  if tsql.FieldByName('DC').AsString = '2' then th := th + tsql.FieldByName('importe').AsFloat;

  if (tsql.FieldByName('idtitular').AsString <> idant) or (tsql.FieldByName('clavecta').AsString <> clant) then
    begin
      // Subtotal
      if idant <> '' then rSubtotales(salida);

      clientegar.Buscar(tsql.FieldByName('idtitular').AsString);
      pr := clientegar.tperso.FieldByName('nombre').AsString;
      List.Linea(0, 0, 'Cuenta: ' + tsql.FieldByName('idtitular').AsString + '-' + tsql.FieldByName('clavecta').AsString + '    ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      List.Linea(0, 0, utiles.espacios(140) + 'Saldo Anterior ....: ', 1, 'Arial, cursiva, 8', salida, 'S');
      if tsql.FieldByName('DC').AsString = '1' then saldoanter := saldo - tsql.FieldByName('importe').AsFloat else saldoanter := saldo + tsql.FieldByName('importe').AsFloat;
      List.importe(100, list.lineactual, '', saldoanter, 2, 'Arial, cursiva, 8');
      List.Linea(101, list.lineactual, ' ', 3, 'Arial, cursiva, 8', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      existenMov := True;
    end;
  List.Linea(0, 0, utiles.sFormatoFecha(tsql.FieldByName('fecha').AsString) + ' ' + tsql.FieldByName('idcompr').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(17, List.lineactual, tsql.FieldByName('tipo').AsString + ' ' + tsql.FieldByName('sucursal').AsString + ' ' + tsql.FieldByName('numero').AsString + '   ' + tsql.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
  if tsql.FieldByName('DC').AsString = '1' then List.importe(70, list.lineactual, '', tsql.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
  if tsql.FieldByName('DC').AsString = '2' then List.importe(85, list.lineactual, '', tsql.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8');
  List.importe(100, list.lineactual, '', saldo, 5, 'Arial, normal, 8');
  List.Linea(101, List.lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
  idant := tsql.FieldByName('idtitular').AsString;
  clant := tsql.FieldByName('clavecta').AsString;
end;

procedure TTCtactecl.rSubtotales(salida: char);
// Objetivo...: Emitir Subtotales
begin
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
  List.derecha(70, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.derecha(85, list.lineactual, '', '--------------', 3, 'Arial, normal, 8');
  List.derecha(100, list.lineactual, '', '--------------', 4, 'Arial, normal, 8');
  List.Linea(101, list.lineactual, ' ', 5, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, 'Subtotal Cuenta ..........: ', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(70, list.lineactual, '', td, 2, 'Arial, normal, 8');
  List.importe(85, list.lineactual, '', th, 3, 'Arial, normal, 8');
  List.importe(100, list.lineactual, '', {td - th + saldoanterior}saldo, 4, 'Arial, normal, 8');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
  saldo := 0; td := 0; th := 0;
end;

procedure TTCtactecl.rSubtotales1(salida: char; t: string);
// Objetivo...: Emitir Subtotales
var
  l: string;
begin
  if t = '1' then l := 'Total de cuotas ......:' else l := 'Total Pagado .....:';
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
  List.derecha(70, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.derecha(85, list.lineactual, '', '--------------', 3, 'Arial, normal, 8');
  List.Linea(101, list.lineactual, ' ', 5, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, l, 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(70, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.importe(85, list.lineactual, '', recar, 3, 'Arial, normal, 8');
  if iss then
    begin
      List.Linea(0, 0, 'Saldo Actual ......:', 1, 'Arial, negrita, 8', salida, 'N');
      List.importe(30, list.lineactual, '', td - th, 2, 'Arial, negrita, 8');
    end;
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
end;

procedure TTCtactecl.TitulosResctas(salida: char);
// Objetivo...: Titulos del resumen de cuentas corrientes de Proveedores
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Resumen de Cuentas Corrientes de Clientes', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(17, List.lineactual, 'Comprobante                   Concepto Operación', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Debe', 3, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'Haber', 4, 'Arial, cursiva, 8');
  List.Titulo(95, List.lineactual, 'Saldo', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTCtactecl.ListarEstadoCuentas(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar las Cuentas Corrientes de un cliente en partiular
begin
  indice := tabla3.IndexFieldNames; total := 0; recar := 0;
  TitulosResctas(salida);
  tabla3.IndexName := 'Idcta';
  datosdb.Buscar(tabla3, 'idtitular', 'clavecta', xidtitular, xclavecta);
  tabla3.IndexName := 'Listado';
  ListarResumenCuenta(xidtitular, xclavecta, iniciar, finalizar, salida);

  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
  List.derecha(70, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.derecha(85, list.lineactual, '', '--------------', 3, 'Arial, normal, 8');
  List.derecha(100, list.lineactual, '', '--------------', 4, 'Arial, normal, 8');
  List.Linea(101, list.lineactual, ' ', 5, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, 'Total General  ..............: ', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(70, list.lineactual, '', total, 2, 'Arial, negrita, 8');
  List.importe(85, list.lineactual, '', recar, 3, 'Arial, negrita, 8');
  List.importe(100, list.lineactual, '', total - recar, 4, 'Arial, negrita, 8');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
  tabla3.IndexFieldNames := indice;
end;

procedure TTCtactecl.rListar(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de Clientes con ruptura por cuenta
begin
  if not listiniciado then Begin
    indice := tabla3.IndexFieldNames;
    TitulosResctas(salida);
    existenMov   := False;
    listiniciado := True;
  end;
  tsql := datosdb.tranSQL('SELECT * FROM ' + tabla3.TableName + ' WHERE idtitular = ' + '"' + xidtitular + '"' + ' AND clavecta = ' + '"' + xclavecta + '"' + ' ORDER BY Fecha, DC');
  ListarResumenCuenta(xidtitular, xclavecta, iniciar, finalizar, salida);
end;

procedure TTCtactecl.ListarResumenCuenta(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de Clientes con ruptura por cuenta
begin
  saldo := 0; td := 0; th := 0; idant := ''; clant := '';
  tsql.Open;

  while not tsql.EOF do Begin
    if (tsql.FieldByName('idtitular').AsString = xidtitular) and (tsql.FieldByName('clavecta').AsString = xclavecta) then Begin
      if (Length(Trim(tsql.FieldByName('XN').AsString)) > 0) or (tsql.FieldByName('tipo').AsString = 'I') then Begin
        if tsql.FieldByName('DC').AsString = '1' then Begin
          saldo := saldo + tsql.FieldByName('importe').AsFloat;
          total := total + tsql.FieldByName('importe').AsFloat;
        end;
        if tsql.FieldByName('DC').AsString = '2' then Begin
          saldo := saldo - tsql.FieldByName('importe').AsFloat;
          recar := recar + tsql.FieldByName('importe').AsFloat;
        end;
      end;
      if (tsql.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tsql.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then
      if (Length(Trim(tsql.FieldByName('XN').AsString)) > 0) or (tsql.FieldByName('tipo').AsString = 'I') then rList_Linea(salida);
    end;
    tsql.Next;
    if (tsql.FieldByName('idtitular').AsString <> xidtitular) or (tsql.FieldByName('clavecta').AsString <> xclavecta) then Break;
  end;
  if td + th <> 0 then rSubtotales(salida);

  tsql.Close; tsql.Free;
end;

procedure TTCtactecl.rListarRes(xidtitular, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de Clientes con ruptura por cliente
begin
  if not listiniciado then Begin
    TitulosResctas(salida);
    idant := ''; clant := '';
  end;
  ListarResumen(xidtitular, iniciar, finalizar, salida);
end;

procedure TTCtactecl.ListarResumen(xidtitular, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar una cuenta con ruptura por cliente
begin
  saldo := 0; saldoanter := 0; td := 0; th := 0;

  tsql := datosdb.tranSQL('SELECT * FROM ' + tabla3.TableName + ' WHERE idtitular = ' + '"' + xidtitular + '"' + ' ORDER BY idtitular, clavecta, fecha, DC');

  tsql.Open; tsql.First;
  while not tsql.EOF do Begin
    if (tsql.FieldByName('idtitular').AsString = xidtitular) then Begin
      if (tsql.FieldByName('DC').AsString = '1') and (tsql.FieldByName('items').AsString < '001') then saldo := saldo + tsql.FieldByName('importe').AsFloat;
      if tsql.FieldByName('DC').AsString = '2' then saldo := saldo - tsql.FieldByName('importe').AsFloat;
      if (tsql.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tsql.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then
      if (Length(Trim(tsql.FieldByName('XN').AsString)) > 0) or (tsql.FieldByName('tipo').AsString = 'I') then cList_Linea(salida);
    end;
    tsql.Next;
  end;
  if td + th <> 0 then rSubtotales(salida);

  tsql.Close; tsql.Free;
end;

procedure TTCtactecl.cList_linea(salida: char);
// Objetivo...: Listar una Línea - ruptura por cliente
var
  pr: string;
begin
  if tsql.FieldByName('DC').AsString = '1' then td := td + tsql.FieldByName('importe').AsFloat;
  if tsql.FieldByName('DC').AsString = '2' then th := th + tsql.FieldByName('importe').AsFloat;

  if tsql.FieldByName('idtitular').AsString <> clant then
    begin
      // Subtotal
      if clant <> '' then rSubtotales(salida);
      clientegar.Buscar(tsql.FieldByName('idtitular').AsString);
      pr := clientegar.tperso.FieldByName('nombre').AsString;
      List.Linea(0, 0, 'Cliente: ' + tsql.FieldByName('idtitular').AsString + '-   ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      List.Linea(0, 0, utiles.espacios(140) + 'Saldo Anterior ....: ', 1, 'Arial, cursiva, 8', salida, 'S');
      if tsql.FieldByName('DC').AsString = '1' then saldoanter := saldo - tsql.FieldByName('importe').AsFloat else saldoanter := saldo + tsql.FieldByName('importe').AsFloat;
      List.importe(100, list.lineactual, '', saldoanter, 2, 'Arial, cursiva, 8');
      List.Linea(101, list.lineactual, ' ', 3, 'Arial, cursiva, 8', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    end;
  List.Linea(0, 0, utiles.sFormatoFecha(tsql.FieldByName('fecha').AsString) + ' ' + tsql.FieldByName('idcompr').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(17, List.lineactual, tsql.FieldByName('tipo').AsString + ' ' + tsql.FieldByName('sucursal').AsString + ' ' + tsql.FieldByName('numero').AsString + '   ' + tsql.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
  if tsql.FieldByName('DC').AsString = '1' then List.importe(70, list.lineactual, '', tsql.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
  if tsql.FieldByName('DC').AsString = '2' then List.importe(85, list.lineactual, '', tsql.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8');
  List.importe(100, list.lineactual, '', saldo, 5, 'Arial, normal, 8');
  List.Linea(101, List.lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
  clant := tsql.FieldByName('idtitular').AsString;
end;

procedure TTCtactecl.rListarPlan(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Ficha de Cuentas Corrientes Seleccionadas
begin
  if not listiniciado then Begin   // Definimos los parámetros
    indice := tabla3.IndexFieldNames;
    ListTitFicha(salida);
    existenMov   := False;
    listiniciado := True;
  end;
  tsql := datosdb.tranSQL('SELECT * FROM ' + tabla3.TableName + ' WHERE idtitular = ' + '"' + xidtitular + '"' + ' AND clavecta = ' + '"' + xclavecta + '"' + ' ORDER BY Idtitular, Clavecta, DC, Fecha');
  ListarPlanDePagos(xidtitular, xclavecta, iniciar, finalizar, salida);
end;

procedure TTCtactecl.ListTitFicha(salida: char);
// Objetivo...: Listar Titulos Ficha de Cuenta Corriente
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Ficha de Cuenta Corriente', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(17, List.lineactual, 'Comprobante    Concepto operación', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Monto', 3, 'Arial, cursiva, 8');
  List.Titulo(89, List.lineactual, 'Recargo', 4, 'Arial, cursiva, 8');
  List.Titulo(97, List.lineactual, 'Est.', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTCtactecl.ListarPlanDePagos(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar una Ficha de Cuentas Corrientes
var
  t: string;
begin
  tsql.Open;
  saldo := 0; td := 0; th := 0; idant := ''; clant := ''; total := 0; recar := 0; saldoanter := 0; t:= '';
  t := tsql.FieldByName('DC').AsString;

  while not tsql.EOF do Begin
    if (tsql.FieldByName('idtitular').AsString = xidtitular) and (tsql.FieldByName('clavecta').AsString = xclavecta) then Begin
      if tsql.FieldByName('DC').AsString <> t then Begin
        rSubtotales1(salida, t);
        List.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
        total := 0;
      end;
      if tsql.FieldByName('DC').AsString = '1' then iss := False else iss := True;
      if (tsql.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tsql.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then
      if ((tsql.FieldByName('items').AsString > '000') or (tsql.FieldByName('items').AsString = '000')) or (tsql.FieldByName('tipo').AsString = 'I') then List_LineaPlan(salida);

      if ((tsql.FieldByName('items').AsString > '000') or (tsql.FieldByName('items').AsString = '000')) or (tsql.FieldByName('estado').AsString = 'R') then Begin  // Saldos y Totales
        if tsql.FieldByName('DC').AsString = '1' then td := td + tsql.FieldByName('importe').AsFloat;
        if tsql.FieldByName('DC').AsString = '2' then th := th + tsql.FieldByName('importe').AsFloat;
        total := total + tsql.FieldByName('importe').AsFloat;
        recar := recar + tsql.FieldByName('recargo').AsFloat;
        existenMov := True;
      end;

      saldoanter := td - th;
      t := tsql.FieldByName('DC').AsString;
    end;
    tsql.Next;
    if (tsql.FieldByName('idtitular').AsString <> xidtitular) or (tsql.FieldByName('clavecta').AsString <> xclavecta) then Break;
  end;

  if (td + th) <> 0 then
    if t = '1' then begin
      rSubtotales1(salida, '1');
      iss := True;
      rSubtotales1(salida, '2');
    end else
      rSubtotales1(salida, '2');
      
  tsql.Close; tsql.Free;
end;

procedure TTCtactecl.List_LineaPlan(salida: char);
// Objetivo...: Listar una Línea
var
  concepto: string;
begin
  if tsql.FieldByName('concepto').AsString <> listconcepto then concepto := tsql.FieldByName('concepto').AsString else concepto := '  "';
  if (tsql.FieldByName('idtitular').AsString <> idant) or (tsql.FieldByName('clavecta').AsString <> clant) then ListDatosCliente(salida);
  List.Linea(0, 0, utiles.sFormatoFecha(tsql.FieldByName('fecha').AsString) + ' ' + tsql.FieldByName('idcompr').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(17, List.lineactual, tsql.FieldByName('tipo').AsString + ' ' + tsql.FieldByName('sucursal').AsString + ' ' + tsql.FieldByName('numero').AsString + '   ' + concepto{tsql.FieldByName('concepto').AsString}, 2, 'Arial, normal, 8', salida, 'S');
  List.importe(70, list.lineactual, '', tsql.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
  List.importe(95, list.lineactual, '', tsql.FieldByName('recargo').AsFloat, 4, 'Arial, normal, 8');
  if tsql.FieldByName('DC').AsString = '1' then List.Linea(98, List.lineactual, tsql.FieldByName('estado').AsString, 5, 'Arial, normal, 7', salida, 'S') else List.Linea(98, List.lineactual, ' ', 5, 'Arial, normal, 8', salida, 'S');
  idant := tsql.FieldByName('idtitular').AsString;
  clant := tsql.FieldByName('clavecta').AsString;
  listconcepto := tsql.FieldByName('concepto').AsString;
end;

procedure TTCtactecl.ListDatosCliente(salida: char);
// Objetivo...: subtotalizar una deuda para un cliente
var
  pr: string;
begin
  // Subtotal
  if idant <> '' then rSubtotales(salida);
  clientegar.Buscar(tsql.FieldByName('idtitular').AsString);
  pr := clientegar.tperso.FieldByName('nombre').AsString;
  List.Linea(0, 0, 'Cuenta: ' + tsql.FieldByName('idtitular').AsString + '-' + tsql.FieldByName('clavecta').AsString + '    ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  List.Linea(0, 0, utiles.espacios(140) + 'Saldo Anterior ....: ', 1, 'Arial, cursiva, 8', salida, 'S');
  List.importe(95, list.lineactual, '', saldoanter, 2, 'Arial, cursiva, 8');
  List.Linea(98, list.lineactual, ' ', 3, 'Arial, cursiva, 8', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
end;

procedure TTCtactecl.ListarFichaPlanPagos(xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero: string; salida: char);
// Objetivo...: Listar Ficha con el Formato de la cuenta corriente - como para registrar los pagos
begin
  // Buscamos la Ficha correspondiente
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, '-1') then Begin
    indice := tabla3.IndexFieldNames;
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 10');
    ListTitFichaPagos(salida);
    GenerarFichaPago(xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero, salida);
    tabla3.IndexFieldNames := indice;
   end
  else
   if not existenMov then utiles.msgError('Cuentas sin Operaciones ...!') else List.FinList;
end;

procedure TTCtactecl.ListTitFichaPagos(salida: char);
// Objetivo...: Listar Titulos Ficha de Cuenta Corriente para los Pagos
begin
  garante.conectar;
  clientegar.getDatos(tabla3.FieldByName('idtitular').AsString);
  garante.getDatos(clientegar.docgarante);

  List.Linea(0, 0, 'Titular', 1, 'Arial, negrita, 11', salida, 'N');
  List.Linea(12, list.Lineactual, ':  ' + tabla3.FieldByName('idtitular').AsString + '-' + tabla3.FieldByName('clavecta').AsString + ' ' + clientegar.nombre, 2, 'Arial, negrita, 10', salida, 'N');
  List.Linea(49, list.Lineactual, 'Garante: ', 3, 'Arial, negrita, 10', salida, 'N');
  List.Linea(60, list.Lineactual, ':  ' + garante.nombre, 4, 'Arial, negrita, 10', salida, 'S');

  List.Linea(0, 0, 'Domicilio', 1, 'Arial, negrita, 10', salida, 'N');
  List.Linea(12, list.Lineactual, ':  ' + clientegar.domicilio, 2, 'Arial, negrita, 10', salida, 'N');
  List.Linea(49, list.Lineactual, 'Domicilio', 3, 'Arial, negrita, 10', salida, 'N');
  List.Linea(60, list.Lineactual, ':  ' + garante.domicilio, 4, 'Arial, negrita, 10', salida, 'S');

  List.Linea(0, 0, 'Localidad', 1, 'Arial, negrita, 10', salida, 'N');
  List.Linea(12, list.Lineactual, ':  ' + clientegar.Localidad, 2, 'Arial, negrita, 10', salida, 'N');
  List.Linea(49, list.Lineactual, 'Localidad', 3, 'Arial, negrita, 10', salida, 'N');
  List.Linea(60, list.Lineactual, ':  ' + garante.Localidad, 4, 'Arial, negrita, 10', salida, 'S');

  List.Linea(0, 0, 'Documento', 1, 'Arial, negrita, 10', salida, 'N');
  List.Linea(12, list.Lineactual, ':  ' + clientegar.nrodoc, 2, 'Arial, negrita, 10', salida, 'N');
  List.Linea(49, list.Lineactual, 'Documento', 3, 'Arial, negrita, 10', salida, 'N');
  List.Linea(60, list.Lineactual, ':  ' + garante.codigo, 4, 'Arial, negrita, 10', salida, 'S');

  List.Linea(24, list.Lineactual, 'Tel.:  ', 5, 'Arial, normal, 10', salida, 'N');
  List.Linea(29, list.Lineactual, clientegar.telcom, 6, 'Arial, negrita, 10', salida, 'N');
  List.Linea(72, list.Lineactual, 'Tel.:  ', 7, 'Arial, nomal, 10', salida, 'S');

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 10', salida, 'S');

  List.Linea(0, 0, 'Fecha', 1, 'Arial, cursiva, 8', salida, 'N');
  List.Linea(9, List.lineactual, 'Concepto', 2, 'Arial, cursiva, 8', salida, 'N');
  List.Linea(37, List.lineactual, 'Comprobante', 3, 'Arial, cursiva, 8', salida, 'N');
  List.Linea(55, List.lineactual, 'Debe', 4, 'Arial, cursiva, 8', salida, 'N');
  List.Linea(70, List.lineactual, 'Haber', 5, 'Arial, cursiva, 8', salida, 'N');
  List.Linea(85, List.lineactual, 'Saldo', 6, 'Arial, cursiva, 8', salida, 'S');

  List.Linea(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
  garante.desconectar;
end;

procedure TTCtactecl.GenerarFichaPago(xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero: string; salida: char);
// Objetivo...: Generar Ficha de cta. cte.
var
  cantLineas, numLin: integer;
  control: array[1..4] of string;
begin
  cantLineas := 0; td := 0; th := 0; entrega := 0; numLin := 13;
  list.NoImprimirPieDePagina;
  List.Linea(0, 0, utiles.sFormatoFecha(tabla3.FieldByName('fecha').AsString), 1, 'Arial, negrita, 8', salida, 'N');
  List.Linea(9, list.lineactual, tabla3.FieldByName('concepto').AsString, 2, 'Arial, negrita, 8', salida, 'N');
  List.Linea(37, list.lineactual, tabla3.FieldByName('numero').AsString, 3, 'Arial, negrita, 8', salida, 'N');
  List.importe(60, list.lineactual, '', tabla3.FieldByName('importe').AsFloat, 4, 'Arial, negrita, 8');
  td      := tabla3.FieldByName('importe').AsFloat; // Total Facturado
  entrega := tabla2.FieldByName('impEnt').AsFloat;  // Importe de la Entrega
  control[1] := tabla3.FieldByName('idcompr').AsString; control[2] := tabla3.FieldByName('tipo').AsString;
  control[3] := tabla3.FieldByName('sucursal').AsString; control[4] := tabla3.FieldByName('numero').AsString;
  // Buscamos la Entrega inicial
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, '0') then th := tabla3.FieldByName('importe').AsFloat; // Entrega inicial
  List.importe(75, list.lineactual, '', th, 5, 'Arial, negrita, 8');
  List.importe(90, list.lineactual, '', td - th, 6, 'Arial, negrita, 8');
  // Verificamos si existe entrega de la entrega
  if entrega > 0 then Begin
    List.Linea(0, 0, '  ', 1, 'Arial, cursiva, 5', salida, 'S');
    List.Linea(0, 0, '                  Saldo de la Entrega :', 1, 'Arial, cursiva, 8', salida, 'N');
    List.importe(44, list.lineactual, '',th - entrega, 2, 'Arial, cursiva, 8');
    numLin := 13;
  end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');

  Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, '001');

  while not tabla3.EOF do
    begin
      if (tabla3.FieldByName('idtitular').AsString = xidtitular) and (tabla3.FieldByName('clavecta').AsString = xclavecta) and (tabla3.FieldByName('DC').AsString = '1') then Begin
        List.Linea(0, 0, '----/----/----', 1, 'Arial, normal, 9', salida, 'N');
        List.Linea(11, list.lineactual, IntToStr(tabla3.FieldByName('items').AsInteger) + 'º', 2, 'Arial, normal, 9', salida, 'N');
        List.Linea(14, list.lineactual, utiles.sFormatoFecha(tabla3.FieldByName('fecha').AsString) + ' ......................................................', 3, 'Arial, normal, 9', salida, 'N');
        List.importe(55, list.lineactual, '', tabla3.FieldByName('importe').AsFloat, 4, 'Arial, normal, 9');
        List.Linea(58, list.lineactual, '...........................................................................', 5, 'Arial, normal, 9', salida, 'N');
        List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        Inc(cantLineas);
        if cantLineas > numLin then Begin
          if salida = 'P' then Begin
            List.Linea(0, 0, ' ', 1, 'Arial, normal, 14', salida, 'S');
            List.Linea(0, 0, ' ', 1, 'Arial, normal, 14', salida, 'S');
            List.Linea(0, 0, ' ', 1, 'Arial, normal, 14', salida, 'S');
            List.Linea(0, 0, ' ', 1, 'Arial, normal, 14', salida, 'S');
            ListTitFichaPagos(salida);
          end;
         if salida = 'I' then Begin
          list.FinList;
          utiles.msgError('Inserte una Nueva Ficha ...!');
          list.Setear(salida);
          List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
          List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 10');
          ListTitFichaPagos(salida);
         end;
         cantLineas := 0;
        end;
      end;
      tabla3.Next;

      if (tabla3.FieldByName('idcompr').AsString <> control[1]) or (tabla3.FieldByName('tipo').AsString <> control[2]) or
        (tabla3.FieldByName('sucursal').AsString <> control[3]) or (tabla3.FieldByName('numero').AsString <> control[4]) then Break;
    end;

    list.FinList;
end;

procedure TTCtactecl.tituloVencimientos(xfecha: string; salida: char; xresumido: boolean);
// Objetivo...: Título del listado
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Listado de Venciemientos de Pagos de Clientes', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Vencimientos al ' + xfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, List.lineactual, 'Cuenta    Titular', 2, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Domicilio', 3, 'Arial, cursiva, 8');
  if not xresumido then Begin
    List.Titulo(85, List.lineactual, 'Monto', 4, 'Arial, cursiva, 8');
    List.Titulo(95, List.lineactual, '% Int.', 6, 'Arial, cursiva, 8');
  end
  else Begin
    List.Titulo(65, List.lineactual, 'Monto', 4, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, ' Interés', 5, 'Arial, cursiva, 8');
    List.Titulo(90, List.lineactual, 'Tot.Deuda', 6, 'Arial, cursiva, 8');
  end;
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTCtactecl.ListarVencimientos(xidtitular, xclavecta, fecha, xcriterio: string; salida: char; cantcuotas: integer; xinteres: real; listresumido: boolean);
// Objetivo...: Listar los vencimientos de Cuentas Corrientes
var
  nombre, domicilio, doc, idlist, cllist, cconcepto: string; mesesimpagos: integer;
begin
  mesesimpagos := 0;
  if not listiniciado then Begin
    tituloVencimientos(fecha, salida, listresumido);
    TSQL := TQuery.Create(nil);
    TSQL := datosdb.tranSQL('SELECT * FROM ' + tabla3.TableName + ' WHERE fecha <= ' + '"' + utiles.sExprFecha(fecha) + '"' + ' AND estado = ' + '"' + 'I' + '"' + ' AND items >= ' + '"' + '000' + '"' + ' ORDER BY idtitular, clavecta, fecha');
    recar := 0; total := 0; saldoanter := 0; idant := ''; listdat := False;
    TSQL.Open;
    max := 0; cuotasok := False;
    listiniciado    := True; existenMov := False;
    tipototal       := 'total_vtos';
    tipodispositivo := salida;
  end;

  if cantcuotas = 0 then cuotasok := True else Begin  // Contamos la cantidad de cuotas para determinar si listamos o no
    TSQL.First; max := 0;
    while not TSQL.EOF do Begin
      if (TSQL.FieldByName('idtitular').AsString = xidtitular) and (TSQL.FieldByName('clavecta').AsString = xclavecta) and (TSQL.FieldByName('estado').AsString = 'I') and (TSQL.FieldByName('items').AsString >= '001') then Inc(max);
      TSQL.Next;
    end;

    if xcriterio = '>=' then Begin
      if max >= cantcuotas then cuotasok := True else cuotasok := False;
    end else if xcriterio = '=' then Begin
      if max = cantcuotas then cuotasok := True else cuotasok := False;
    end;
  end;

  if cuotasok then Begin
    listdat := False;
    TSQL.First; max := 0;
    clant := xidtitular;
    while not TSQL.EOF do Begin
      if (xidtitular = TSQL.FieldByName('idtitular').AsString) and (xclavecta = TSQL.FieldByName('clavecta').AsString) then Begin
        DatosClienteVenc(TSQL.FieldByName('idtitular').AsString);
        nombre := ''; domicilio := ''; cconcepto := '';

        if (idlist <> TSQL.FieldByName('idtitular').AsString) or (cllist <> TSQL.FieldByName('clavecta').AsString) then Begin
          ListCuotasImp(max, fecha, salida, listresumido);
          nombre    := TSQL.FieldByName('idtitular').AsString + '-' + TSQL.FieldByName('clavecta').AsString + '  ' + pr;
          domicilio := dom; doc := docc;
          cconcepto := TSQL.FieldByName('concepto').AsString + '   seg. Fact. Nº ' + TSQL.FieldByName('tipo').AsString + '  ' + TSQL.FieldByName('sucursal').AsString + '-' + TSQL.FieldByName('numero').AsString;
          if total > 0 then List.Linea(0, 0, ' ', 1, 'Arial, cursiva, 5', salida, 'S');
          List.Linea(0, 0, nombre, 1, 'Arial, negrita, 10', salida, 'N');
          List.Linea(40, list.lineactual, doc, 2, 'Arial, negrita, 10', salida, 'N');
          List.Linea(75, list.lineactual, domicilio, 3, 'Arial, negrita, 10', salida, 'S');
          if not listresumido then List.Linea(0, 0, ' ', 1, 'Arial, cursiva, 5', salida, 'S');
          listdat := True; existenMov := True;
        end;

        if TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat <> 0 then Begin
          // Obtenemos la cantidad de meses impagos
          utiles.calc_antiguedad(TSQL.FieldByName('fecha').AsString, utiles.sExprFecha(fecha));
          mesesimpagos := utiles.getMeses + 1;
          if not listresumido then Begin
            List.Linea(0, 0, utiles.sFormatoFecha(TSQL.FieldByName('fecha').AsString) + '  ' + cconcepto, 1, 'Arial, normal, 8', salida, 'N');
            List.importe(80, list.lineactual, '', (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat), 2, 'Arial, normal, 8');
            List.importe(93, list.lineactual, '', (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat) * ((xinteres * 0.01) * (mesesimpagos)), 3, 'Arial, normal, 8');
            List.Linea(95, List.lineactual, FloatToStr(mesesimpagos * xinteres) + '%', 4, 'Arial, normal, 8', salida, 'S');
          end;
          if xinteres > 0 then saldoanter := saldoanter + ((TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat) * ((xinteres * 0.01)) * (mesesimpagos)); // Intereses
          recar := recar + ((TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat) + (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat) * ((xinteres * 0.01) * (mesesimpagos)));
          total := total + (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat);
          Inc(max);
        end;
      end;

      idlist    := TSQL.FieldByName('idtitular').AsString;
      cllist    := TSQL.FieldByName('clavecta').AsString;
      TSQL.Next;
    end;

    ListCuotasImp(max, fecha, salida, listresumido);
    if listdat then tot_deuda(salida, listresumido);
  end;
end;

procedure TTCtactecl.DatosClienteVenc(xcodcli: string);
// Objetivo...: Calcular el saldo para una cuenta dada
begin
  clientegar.getDatos(TSQL.FieldByName('idtitular').AsString);
  pr   := clientegar.Nombre;
  dom  := clientegar.domicilio;
  loc  := clientegar.localidad;
  docc := 'Doc. Nº: ' + clientegar.nrodoc;
end;

procedure TTCtactecl.tot_deuda(salida: char; listresumen: boolean);
// Objetivo...: subtotalizar una deuda para un cliente
begin
  if not listresumen then Begin
    List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
    List.derecha(80, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
    List.Linea(0, 0, 'Deuda', 1, 'Arial, negrita, 8', salida, 'S');
    List.importe(80, list.lineactual, '', total, 2, 'Arial, negrita, 8');
    List.Linea(97, List.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
    List.Linea(0, 0, 'Intereses', 1, 'Arial, negrita, 8', salida, 'S');
    List.importe(80, list.lineactual, '', saldoanter, 2, 'Arial, negrita, 8');
    List.Linea(97, List.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
    List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
    List.derecha(80, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
    List.Linea(0, 0, 'Total Deuda', 1, 'Arial, negrita, 8', salida, 'S');
    List.importe(80, list.lineactual, '', total + saldoanter, 2, 'Arial, negrita, 8');
    List.Linea(97, List.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
    List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
  end else Begin
    List.importe(70, list.lineactual, '', total, 2, 'Arial, negrita, 9, clNavy');
    List.importe(84, list.lineactual, '', saldoanter, 3, 'Arial, negrita, 9, clNavy');
    List.importe(98, list.lineactual, '', total + saldoanter, 4, 'Arial, negrita, 9, clNavy');
    List.Linea(99, List.lineactual, ' ', 5, 'Arial, normal, 8, clNavy', salida, 'S');
    if listresumen then List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  end;
  total := 0; saldoanter := 0; max := 0;
end;

procedure TTCtactecl.ListCuotasImp(xcantcuotas: integer; xfecha: string; salida: char; listresumen: boolean);
// Objetivo...: Listar las cuotas impagas en c/c
begin
  if xcantcuotas > 0 then Begin     // Listamos la cantidad de cuotas impagas
    if not listresumen then List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    if xcantcuotas > 5 then List.Linea(0, 0, 'Cuotas impagas al ' +  xfecha + ':     ' + IntToStr(xcantcuotas), 1, 'Arial, negrita, 10, clRed', salida, 'N') else List.Linea(0, 0, 'Cuotas impagas al ' +  xfecha + ':     ' + IntToStr(xcantcuotas), 1, 'Arial, negrita, 10, clGreen', salida, 'N');
    if not listresumen then List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  end;
end;

procedure TTCtactecl.ObtenerSaldo(xidtitular, xclavecta: string);
// Objetivo...: Calcular el saldo para una cuenta dada
begin
  td := 0; th := 0;
  TSQL.Open; TSQL.First;
  while not TSQL.EOF do
    begin
      if (TSQL.FieldByName('idtitular').AsString = xidtitular) and (TSQL.FieldByName('clavecta').AsString = xclavecta) then
        begin
          if (TSQL.FieldByName('items').AsString = '-1') or (TSQL.FieldByName('tipo').AsString = 'I') then td := td + TSQL.FieldByName('importe').AsFloat;
          if TSQL.FieldByName('DC').AsString = '2' then th := th + TSQL.FieldByName('importe').AsFloat;
        end;
      TSQL.Next;
    end;
end;

function TTCtactecl.ExtraerSaldos(xfecha: string): TQuery;
// Objetivo...: Extraer los los movimientos de c/c
begin
  Result := datosdb.tranSQL('SELECT tipo, fecha, idtitular, clavecta, DC, Items, importe FROM ' + tabla3.TableName + ' WHERE fecha <= ' + '"' + utiles.sExprFecha(xfecha) + '"');
end;

procedure TTCtactecl.titulosPS(xfecha: String; salida: char);
// Objetivo...: Listar títulos Planilla de Saldos
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Planilla de Saldos de Clientes al  ' + xfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cuenta     Titular', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(83, List.lineactual, 'Saldo', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTCtactecl.totalPS(salida: char);
// Objetivo...: Listar títulos Planilla de Saldos
begin
  list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
  list.derecha(90, list.lineactual, '##############', '--------------', 2, 'Arial, normal, 8');
  list.Linea(0, 0, 'Total ........: ', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(90, list.lineactual, '', total, 2, 'Arial, negrita, 8');
  list.Linea(92, list.lineactual, '  ', 3, 'Arial, negrita, 8', salida, 'S');
end;

procedure TTCtactecl.ListPlanillaSaldos(xidtitular, xclavecta, fecha: string; ListCtasSaldadas: Boolean; salida: char);
// Objetivo...: Listar saldos individuales por cuenta
var
  l: array[1..4] of string; lc: Boolean;
begin
  if not listiniciado then Begin
    titulosPS(fecha, salida);
    total := 0; idant := ''; tipototal := 'planilla_saldos';
    listiniciado := True;
    tipodispositivo := salida;
  end;

  TSQL := datosdb.tranSQL('SELECT tipo, fecha, idtitular, clavecta, DC, Items, importe FROM ' + tabla3.TableName + ' WHERE idtitular = ' + '"' + xidtitular + '"' + ' and fecha <= ' + '"' + utiles.sExprFecha(fecha) + '"');
  ObtenerSaldo(xidtitular, xclavecta);

  {//if idant <> xidtitular then Begin
    clant := DatosClientePS(xidtitular, xclavecta);
    l[1]  := xidtitular; l[2] := xclavecta;
    max   := pos('___', clant);
    l[3]  := Copy(clant, 1, max - 1);
    l[4]  := Copy(clant, max + 3, 35);
    idant := xidtitular;
  //end else Begin
    //l[1] := ''; l[2] := ''; l[3] := ''; l[4] := '';
  //end;}
  clant := DatosClientePS(xidtitular, xclavecta);
  l[1]  := xidtitular; l[2] := xclavecta;
  max   := pos('___', clant);
  l[3]  := Copy(clant, 1, max - 1);
  l[4]  := Copy(clant, max + 3, 35);
  idant := xidtitular;

  if Not ListCtasSaldadas then
    if td - th <> 0 then lc := True;

  if ListCtasSaldadas then
    if td - th = 0 then lc := True;

  if lc then Begin
    List.Linea(0, 0, l[1] + '  ' + l[2] + '  ' + l[3], 1, 'Arial, normal, 8', salida, 'N');
    List.Linea(40, list.lineactual, l[4], 2, 'Arial, normal, 8', salida, 'N');
    List.importe(90, list.lineactual, '', td - th, 3, 'Arial, normal, 8');
    List.Linea(90, List.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
    total := total + (td - th);
    if total <> 0 then existenMov := True;
  end;
  TSQL.Close; TSQL.Free;
end;

function TTCtactecl.DatosClientePS(xcodcli, xclavecta: string): string;
// Objetivo...: Listar los datos del cliente
begin
  clientegar.getDatos(xcodcli);
  Result :=   clientegar.nombre + '___' + clientegar.domicilio;
end;

function TTCtactecl.getMcctcl: TQuery;
// Objetivo...: Devolver un set con los registros registrados
begin
  Result := datosdb.tranSQL('SELECT fecha, idcompr AS IDC, tipo AS Tipo, sucursal AS Sucur, numero AS Numero, idtitular AS Cod, clavecta AS Cta, ctactecl.concepto AS Concepto, ctactecl.importe AS Importe FROM ' + tabla3.TableName + ' ctactecl WHERE ctactecl.items = ' + '"' + '-1' + '"' + ' ORDER BY ctactecl.fecha');
end;

function TTCtactecl.getMcctcl(xt, xc: string): TQuery;
// Objetivo...: Devolver un set con los registros registrados
begin
  Result := datosdb.tranSQL('SELECT fecha, idcompr AS IDC, tipo AS Tipo, sucursal, numero AS Numero, DC, idtitular AS Cod, clavecta AS Cta, ctactecl.concepto AS Concepto, ' +
               'ctactecl.importe AS Importe FROM ' + tabla3.TableName + ' WHERE ctactecl.idtitular = ' + '"' + xt + '"' + ' AND ctactecl.clavecta = ' + '"' + xc + '"' + ' ORDER BY fecha');
end;

// Consultas para Estadísticas

function TTCtactecl.EstsqlSaldosCobrar(fecha1, fecha2: string): TQuery;
// Objetivo...: Generar Transacción SQL para determinar Saldos a Cobrar de c/c
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, clientes.nombre, ctactecl.importe, ctactecl.entrega '
           +'FROM ctactecl, clientes WHERE ctactecl.idtitular = clientes.codcli AND ctactecl.fecha >= ' + '"' + fecha1 + '"' + ' AND ctactecl.fecha <= ' + '"' + fecha2 + '"'
           +' AND ctactecl.items > ' + '"' + '000' + '"' + ' AND ctactecl.estado = ' + '"' + 'I' + '"');
end;

function TTCtactecl.EstsqlCobrosEfectuados(fecha1, fecha2: string): TQuery;
// Objetivo...: Generar Transacción SQL para determinar Cobros Efectuados de c/c
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, clientes.nombre, ctactecl.importe, ctactecl.recargo '
           +'FROM ctactecl, clientes WHERE ctactecl.idtitular = clientes.codcli AND ctactecl.fecha >= ' + '"' + fecha1 + '"' + ' AND ctactecl.fecha <= ' + '"' + fecha2 + '"' + ' AND dc = ' + '"' + '2' + '"');
end;

function TTCtactecl.EstsqlCuotasVencidas(fecha1, fecha2: string): TQuery;
// Objetivo...: Generar Transacción SQL para determinar Cobros Efectuados de c/c
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, clientes.nombre, ctactecl.importe, ctactecl.entrega '
                          + 'FROM ctactecl, clientes WHERE ctactecl.idtitular = clientes.codcli AND ctactecl.fecha < ' + '"' + fecha1 + '"'
                          + ' AND estado = ' + '"' + 'I' + '"' + ' AND dc = ' + '"' + '1' + '"' + ' AND items >= ' + '"' + '000' + '"');
end;

function TTCtactecl.AuditoriaFacturasEmitidas(fecha: string): TQuery;  // SQL Auditoría
// Objetivo...: Generar TransacSQL para auditoría de facturas emitidas
begin
  Result := datosdb.tranSQL('SELECT ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, clientes.nombre, ctactecl.importe '
                            +'FROM ctactecl, clientes WHERE ctactecl.idtitular = clientes.codcli AND ctactecl.fecha = ' + '"' + fecha + '"' + ' AND items = ' + '"' + '-1' + '"');
end;

function TTCtactecl.AuditoriaRecaudacionesCobros(fecha: string): TQuery;
// Objetivo...: Generar TransacSQL para auditoría de cobros efectuados
begin
  Result := datosdb.tranSQL('SELECT ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, clientes.nombre, ctactecl.importe '
                           +'FROM ctactecl, clientes WHERE ctactecl.idtitular = clientes.codcli AND ctactecl.fecha = ' + '"' + fecha + '"' + ' AND dc = ' + '"' + '2' + '"');
end;

procedure TTCtactecl.listRecibo(xconcepto: string; ximporte: real; salida: char);
// Objetivo...: Listar cabecera de recibo
var
  ln: integer;
begin
  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then Begin
      list.ResolucionImpresora(administNum.NResolucion);  // Extraemos la resolución definida para el comprobante
      list.NoImprimirPieDePagina;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    end;
    listdat := True;    // Flag para que en la 2º imopresion no vuelva a setear

    ListarRecibo(xconcepto, ximporte, salida);
  end;

  if salida = 'T' then Begin  // Trabajo en modo texto
     AssignFile(archtxt, 'list.txt');
     Rewrite(archtxt);

     For ln := 1 to 6 do WriteLn(archtxt, ' ');
     compregis.getDatos(tabla3.FieldByName('idcompr').AsString);
     WriteLn(archtxt, utiles.espacios(45) + 'Fecha: ' + utiles.sFormatoFecha(tabla3.FieldByName('fecha').AsString));
     WriteLn(archtxt, utiles.espacios(45) +  tabla3.FieldByName('tipo').AsString + '   ' + compregis.descrip);
     WriteLn(archtxt, utiles.espacios(45) +  'N' + CHR(167)+ ' ' + tabla3.FieldByName('sucursal').AsString + '  -  ' + tabla3.FieldByName('numero').AsString);

     For ln := 1 to 7 do WriteLn(archtxt, '  ');
     WriteLn(archtxt, 'Se' + CHR(164) + 'or(es):    ' + rsCliente);
     WriteLn(archtxt, '  ');
     WriteLn(archtxt, 'Domicilio:    ' + domCliente);

     For ln := 1 to 2 do WriteLn(archtxt, ' ');
     WriteLn(archtxt, 'Recibimos la suma de:  ' + utiles.xIntToLletras(tabla3.FieldByName('importe').AsInteger) + ' C/ ' + Copy(utiles.FormatearNumero(tabla3.FieldByName('importe').AsString), Length(utiles.FormatearNumero(tabla3.FieldByName('importe').AsString)) - 1, 2));
     WriteLn(archtxt, '  ');
     WriteLn(archtxt, 'En concepto de: ' + tabla3.FieldByName('concepto').AsString);
     WriteLn(archtxt, '  ');

     ln := Pos('º', tabla3.FieldByName('concepto').AsString);
     if ln > 0 then WriteLn(archtxt, 'Cuota N' + CHR(167) + ':  ' + Copy(tabla3.FieldByName('concepto').AsString, 1, ln-1) + CHR(167) + Copy(tabla3.FieldByName('concepto').AsString, ln + 1, Length(Trim(tabla3.FieldByName('concepto').AsString)) - ln + 1)               + '             ' + 'Factura N' + CHR(167) +  ': ' + tabla3.FieldByName('xn').AsString + '                ' + 'Son $ ' + utiles.FormatearNumero(tabla3.FieldByName('importe').AsString)) else
       WriteLn(archtxt, 'Cuota N' + CHR(167) + ':  ' + tabla3.FieldByName('items').AsString + '             ' + 'Factura N' + CHR(167) +  ': ' + tabla3.FieldByName('xn').AsString + '                ' + 'Son $ ' + utiles.FormatearNumero(tabla3.FieldByName('importe').AsString));

     For ln := 1 to 5 do WriteLn(archtxt, ' ');
     WriteLn(archtxt, 'Firma ............................................');
     CloseFile(archtxt);
  end;
end;

procedure TTCtactecl.ListarRecibo(xconcepto: string; ximporte: real; salida: char);
// Objetivo...: Listar Observaciones de Solicitud
const
  c: string = '           ';
var
  xi: integer; il: string; xr: real;
begin
  fe := modeloc.FieldByName('fe').AsString;
  list.IniciarMemoImpresiones(modeloc, 'cuerpo', 1000);
  // Remplazamos las etiquetas
  list.RemplazarEtiquetasEnMemo('#fecha', utiles.sFormatoFecha(tabla3.FieldByName('fecha').AsString));
  list.RemplazarEtiquetasEnMemo('#recibo', tabla3.FieldByName('tipo').AsString + '   ' + administNum.NFExpendio + '-' + utiles.sLlenarIzquierda(administNum.NFnroactual, 8, '0'));
  list.RemplazarEtiquetasEnMemo('#cliente', idtitular + '-' + clavecta + '    ' + rsCliente);
  list.RemplazarEtiquetasEnMemo('#domicilio', domCliente);
  list.RemplazarEtiquetasEnMemo('#localidad', rsLocalidad);
  list.RemplazarEtiquetasEnMemo('#provincia', rsProvincia);
  list.RemplazarEtiquetasEnMemo('#codpfis', rsCodpfis);
  list.RemplazarEtiquetasEnMemo('#cuit', rsNrocuit);
  xr := Int(ximporte); xi := StrToInt(FloatToStr(xr)); il := utiles.FormatearNumero(FloatToStr(ximporte));
  list.RemplazarEtiquetasEnMemo('#importe-en-letras', utiles.xIntToLletras(xi) + ' C/ ' + Copy(il, Length(Trim(il)) - 1, 2));
  list.RemplazarEtiquetasEnMemo('#concepto', xconcepto);
  list.RemplazarEtiquetasEnMemo('#cuota', tabla3.FieldByName('items').AsString);
  list.RemplazarEtiquetasEnMemo('#factura', tabla3.FieldByName('xt').AsString + '  ' + tabla3.FieldByName('xs').AsString + '-' + tabla3.FieldByName('xn').AsString);
  list.RemplazarEtiquetasEnMemo('#importe', utiles.FormatearNumero(FloatToStr(ximporte)));

  list.ListMemo('', fe, 0, salida, nil, 1000);   // Imprimir la Plantilla
end;

procedure TTCtactecl.ActualizarUltimoReciboImpreso(xnumero: string);
// Objetivo...: Actualizar el número del último recibo impreso
begin
  administNum.ActNuemeroActualNF(xnumero);
end;

procedure TTCtactecl.ListarAntecedentes(xidtitular, xnombre, listresumen: string; salida: char);
// Objetivo...: Listar Antecedentes de un cliente
var
  idanter: string;
  i, j: integer;
begin
  i := 0; j := 0; max := 0; td := 0; th := 0;
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  list.Titulo(0, 0, 'Operaciones Efectuadas por: ' + xidtitular + '-' + xnombre, 1, 'Arial, negrita, 12');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  list.Titulo(0, 0, '      Fecha Vto.   Fecha Pago  Cuota                        Monto Cuota          Entrega/Pago             Saldo Cuota', 1, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');

  // Consultas al Histórico
  TSQL := TQuery.Create(nil);
  TSQL := setOperacionesTransHist(xidtitular);
  TSQL.Open; TSQL.First;
  while not TSQL.EOF do Begin
    if TSQL.FieldByName('clavecta').AsString <> idanter then Begin
      if max > 0 then LisMov(listresumen, salida);
      // Listamos la Factura
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      if TSQL.FieldByName('items').AsString = '-1' then Begin
        list.Linea(0, 0, 'Comprobante: ' + TSQL.FieldByName('idcompr').AsString + ' ' + TSQL.FieldByName('tipo').AsString + ' ' + TSQL.FieldByName('sucursal').AsString + '-' + TSQL.FieldByName('numero').AsString + '   Fecha: ' + utiles.sFormatoFecha(TSQL.FieldByName('fecha').AsString) + utiles.espacios(8) +
          ' Concepto: ' + TSQL.FieldByName('concepto').AsString, 1, 'Arial, cursiva, 8', salida, 'N');
        list.Linea(80, list.Lineactual, '*** C A N C E L A D O ***', 2, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      end;
      i := 0; j := 0; cuotaspendientes := 0;
     end
    else Begin
      if (TSQL.FieldByName('DC').AsString = '1') and (TSQL.FieldByName('items').AsString >= '001') then Begin
        Inc(i);
        fpr[i, 1] := TSQL.FieldByName('fecha').AsString;  // Fecha vencimiento cuota
        fim[i, 1] := TSQL.FieldByName('importe').AsFloat; // Monto vencimiento cuota
      end;
      if (TSQL.FieldByName('DC').AsString = '2') and (TSQL.FieldByName('items').AsString >= '001') then Begin
        Inc(j);
        fpr[j, 2] := TSQL.FieldByName('fecha').AsString;  // Fecha de Pago
        fim[j, 2] := TSQL.FieldByName('importe').AsFloat; // Monto vencimiento cuota
      end;
    end;
    if j >= i then max := j else max := i;

    idanter := TSQL.FieldByName('clavecta').AsString;
    TSQL.Next;
  end;
  TSQL.Close; TSQL.Free;
  LisMov(listresumen, salida);

  if max > 0 then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, negrita, 11', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  end;

  // Consultas a las cuentas actuales
  i := 0; j := 0; max := 0; idanter := '';
  TSQL := TQuery.Create(nil);
  TSQL := setOperacionesTrans(xidtitular);
  TSQL.Open; TSQL.First;
  while not TSQL.EOF do Begin
    if TSQL.FieldByName('clavecta').AsString <> idanter then Begin
      if max > 0 then LisMov(listresumen, salida);
      // Listamos la Factura
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      if TSQL.FieldByName('items').AsString = '-1' then Begin
        list.Linea(0, 0, 'Comprobante: ' + TSQL.FieldByName('idcompr').AsString + ' ' + TSQL.FieldByName('tipo').AsString + ' ' + TSQL.FieldByName('sucursal').AsString + '-' + TSQL.FieldByName('numero').AsString + '   Fecha: ' + utiles.sFormatoFecha(TSQL.FieldByName('fecha').AsString) + utiles.espacios(5) +
          ' Concepto: ' + TSQL.FieldByName('concepto').AsString, 1, 'Arial, cursiva, 8', salida, 'S');

        list.importe(80, list.Lineactual, '', TSQL.FieldByName('importe').AsFloat, 2, 'Arial, normal, 8');
        list.importe(95, list.Lineactual, '', TSQL.FieldByName('entrega').AsFloat, 3, 'Arial, normal, 8');

        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        importe_cuota := TSQL.FieldByName('importe').AsFloat;
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      end;
      i := 0; j := 0;
     end
    else Begin
      if (TSQL.FieldByName('DC').AsString = '1') and (TSQL.FieldByName('items').AsString >= '001') then Begin
        Inc(i);
        fpr[i, 1] := TSQL.FieldByName('fecha').AsString;  // Fecha vencimiento cuota
        fim[i, 1] := TSQL.FieldByName('importe').AsFloat; // Monto vencimiento cuota
        td := td + TSQL.FieldByName('importe').AsFloat;
        Inc(cuotaspendientes);                            // Para determinar las cuotas pendientes
      end;
      if (TSQL.FieldByName('DC').AsString = '2') and (TSQL.FieldByName('items').AsString >= '001') then Begin
        Inc(j);
        fpr[j, 2] := TSQL.FieldByName('fecha').AsString;  // Fecha de Pago
        fim[j, 2] := TSQL.FieldByName('importe').AsFloat; // Monto vencimiento cuota
        th := th + TSQL.FieldByName('importe').AsFloat;
        Dec(cuotaspendientes);                            // Para determinar las cuotas pendientes
      end;
    end;
    if j >= i then max := j else max := i;

    if TSQL.FieldByName('items').AsString = '0' then Begin
      list.Linea(0, 0, 'Tot.Fact/Entrega/Saldo ....: ', 1, 'Arial, negrita, 8', salida, 'S');
      list.importe(42, list.Lineactual, '', importe_cuota, 2, 'Arial, negrita, 8');
      list.importe(55, list.Lineactual, '', TSQL.FieldByName('importe').AsFloat, 3, 'Arial, negrita, 8');
      list.importe(70, list.Lineactual, '', importe_cuota - TSQL.FieldByName('importe').AsFloat, 4, 'Arial, negrita, 8');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    end;

    idanter := TSQL.FieldByName('clavecta').AsString;
    TSQL.Next;
  end;
  TSQL.Close; TSQL.Free;

  LisMov(listresumen, salida);

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, negrita, 11', salida, 'S');

  if td + th <> 0 then Begin
    List.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Débitos :', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(20, list.Lineactual, '', td, 2, 'Arial, negrita, 9');
    list.Linea(30, list.Lineactual, 'Pagos :', 3, 'Arial, negrita, 9', salida, 'N');
    list.importe(45, list.Lineactual, '', th, 4, 'Arial, negrita, 9');
    list.Linea(55, list.Lineactual, 'Saldo :', 5, 'Arial, negrita, 9', salida, 'N');
    list.importe(75, list.Lineactual, '', td - th, 6, 'Arial, negrita, 9');
    list.Linea(77, list.Lineactual, 'Cuotas Pendientes: ' + IntToStr(cuotaspendientes), 7, 'Arial, negrita, 9', salida, 'S');
  end else Begin
    List.Linea(0, 0, 'La cuenta no presenta antecedentes', 1, 'Arial, normal, 10', salida, 'S');
  end;
  list.FinList;
end;

procedure TTCtactecl.LisMov(listresumen: string; salida: char);
// Objetivo...: Listar Movimientos
var
  i: integer;
begin
  if listresumen = 'N' then
   For i := 1 to max do Begin
    List.Linea(0, 0, '        ' + utiles.sFormatoFecha(fpr[i, 1]), 1, 'Arial, normal, 8', salida, 'N');
    List.Linea(12, list.Lineactual, utiles.sFormatoFecha(fpr[i, 2]), 2, 'Arial, normal, 8', salida, 'N');
    List.Linea(22, list.Lineactual, utiles.sLlenarIzquierda(IntToStr(i), 3, '0'), 3, 'Arial, normal, 8', salida, 'N');
    list.importe(42, list.Lineactual, '', fim[i, 1], 4, 'Arial, normal, 8');
    list.importe(55, list.Lineactual, '', fim[i, 2], 5, 'Arial, normal, 8');
    list.importe(70, list.Lineactual, '', fim[i, 1] - fim[i, 2], 6, 'Arial, normal, 8');
    list.Linea(99, list.Lineactual, ' ', 7, 'Arial, normal, 8', salida, 'S');
   end;
  // Iniciamos los arrays
  For i := 1 to 50 do Begin
    fpr[i, 1] := ''; fpr[i, 2] := '';
    fim[i, 1] := 0;  fim[i, 2] := 0;
  end;
end;

function TTCtactecl.setOperacionesTransHist(xidtitular: string): TQuery;
// Objetivo...: devlver los movimientos del histórico para un cliente especifico
begin
  IniciarTablasObj;
  Result := datosdb.tranSQL(htabla3.DatabaseName, 'SELECT * FROM ' + htabla3.TableName + ' WHERE idtitular = ' + '"' + xidtitular + '"' + ' ORDER BY clavecta, fecha, DC');
  CerrarTablasObj;
end;

function TTCtactecl.setOperacionesTrans(xidtitular: string): TQuery;
// Objetivo...: devlver los movimientos actuales para un cliente especifico
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla3.TableName + ' WHERE idtitular = ' + '"' + xidtitular + '"' + ' ORDER BY clavecta, fecha, DC');
end;

procedure TTCtactecl.DatosCliente;
begin
  rsCliente := '';
end;

procedure TTCtactecl.ListClientesRecibieronCarta(xdf, xhf: string; salida: char);
// Objetivo...: Listar aquellos clientes que recibieron cartas
const
  t: array[1..2] of string = ('Aviso', 'Extrajudicial');
begin
  TSQL.Open; listdat := False;
  if TSQL.RecordCount > 0 then Begin
    List.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Listado de Clientes Notificados', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Cuenta        Cliente', 1, 'Arial, cursiva, 8');
    List.Titulo(35, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
    List.Titulo(65, List.lineactual, 'Envío', 3, 'Arial, cursiva, 8');
    List.Titulo(80, List.lineactual, 'Carácter', 4, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
  while not TSQL.EOF do Begin
    listdat := True;
    if idant <> TSQL.FieldByName('nombre').AsString then clant := TSQL.FieldByName('nombre').AsString else clant := '';
    list.Linea(0, 0, TSQL.FieldByName('codcli').AsString + '-' + TSQL.FieldByName('clavecta').AsString + '  ' + clant, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(35, list.Lineactual, TSQL.FieldByName('domicilio').AsString, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(65, list.Lineactual, utiles.sFormatoFecha(TSQL.FieldByName('fecha').AsString), 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(80, list.Lineactual, t[TSQL.FieldByName('idcarta').AsInteger], 4, 'Arial, normal, 8', salida, 'S');
    idant := TSQL.FieldByName('nombre').AsString;
    TSQL.Next;
  end;
  TSQL.Close;

  if listdat then list.FinList else utiles.msgError('No Existen datos para Listar ...!');
end;

procedure TTCtactecl.ListClientesQuePagaron(xdf, xhf: string; salida: char);
// Objetivo...: Listar aquellos clientes que recibieron carta y que vinieron a pagar
var
  xidt, xcla, xnum: string;
begin
  TSQL.Open; listdat := False; importe_cuota := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Listado de Clientes que Pagaron', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cuenta      Cliente', 1, 'Arial, cursiva, 8');
  List.Titulo(35, List.lineactual, 'Fecha Pago  Fecha Int.', 2, 'Arial, cursiva, 8');
  List.Titulo(74, List.lineactual, 'Importe', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  while not TSQL.EOF do Begin
    if (TSQL.FieldByName('idtitular').AsString <>  xidt) or (TSQL.FieldByName('clavecta').AsString <> xcla) or (TSQL.FieldByName('numero').AsString <> xnum) then Begin
      list.Linea(0, 0, TSQL.FieldByName('idtitular').AsString + '-' + TSQL.FieldByName('clavecta').AsString + '  ' + TSQL.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(35, list.Lineactual, loc + '  ' + utiles.sFormatoFecha(TSQL.FieldByName('fechavto').AsString) + '       ' + utiles.sFormatoFecha(TSQL.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
      list.importe(80, list.Lineactual, '', TSQL.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
      list.Linea(85, list.Lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      listdat := True;
      importe_cuota := importe_cuota + TSQL.FieldByName('importe').AsFloat;
    end;
    xidt := TSQL.FieldByName('idtitular').AsString; xcla := TSQL.FieldByName('clavecta').AsString; xnum := TSQL.FieldByName('numero').AsString;
    TSQL.Next;
  end;
  TSQL.Close;

  if not listdat then    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  if listdat then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'N');
    list.derecha(75, list.Lineactual, '', '--------------------', 2, 'Arial, normal, 8');
    list.Linea(0, 0, 'Total pagos de clientes:', 1, 'Arial, normal, 8', salida, 'N');
    list.importe(80, list.Lineactual, '', importe_cuota, 2, 'Arial, normal, 8');
    list.FinList;
  end else utiles.msgError('No Existen datos para Listar ...!');
end;

procedure TTCtactecl.BorrarCartasEnviadas(xdfecha, xhfecha: string; xtipo: shortint);
begin
 if xtipo = 0 then datosdb.tranSQL('DELETE FROM ' + enviocartas.TableName + ' WHERE fecha <= ' + '"' + utiles.sExprFecha(xdfecha) + '"' + ' AND fecha <= ' + '"' + utiles.sExprFecha(xhfecha) + '"');
 if xtipo = 1 then datosdb.tranSQL('DELETE FROM ' + enviocartas.TableName + ' WHERE fecha <= ' + '"' + utiles.sExprFecha(xdfecha) + '"' + ' AND fecha <= ' + '"' + utiles.sExprFecha(xhfecha) + '"' + ' AND idcarta = ' + IntToStr(xtipo));
 if xtipo = 2 then datosdb.tranSQL('DELETE FROM ' + enviocartas.TableName + ' WHERE fecha <= ' + '"' + utiles.sExprFecha(xdfecha) + '"' + ' AND fecha <= ' + '"' + utiles.sExprFecha(xhfecha) + '"' + ' AND idcarta = ' + IntToStr(xtipo));
end;

function TTCtactecl.setCartasEnviadas: TQuery;
begin
  Result := datosdb.tranSQL('SELECT ' + enviocartas.TableName + '.*, ' + tabla1.TableName + '.* ' + ' FROM ' + enviocartas.TableName + ', ' + tabla1.TableName + ' WHERE ' + enviocartas.TableName + '.idtitular = ' + tabla1.TableName + '.idtitular AND ' + enviocartas.TableName + '.clavecta = ' + tabla1.TableName + '.clavecta' + ' ORDER BY ' + enviocartas.TableName + '.Fecha, ' + tabla1.TableName + '.idtitular, ' + tabla1.TableName + '.clavecta');
end;

procedure TTCtactecl.BorrarCartaEnviada(xidtitular, xclavecta, xidcarta, xfecha: string);
begin
  enviocartas.Open;
  datosdb.tranSQL('DELETE FROM ' + enviocartas.TableName + ' WHERE Idtitular = ' + '"' + xidtitular + '"' + ' AND Clavecta = ' + '"' + xclavecta + '"' + ' AND Idcarta = ' + '"' + xidcarta + '"' + ' AND fecha = ' + '"' + utiles.sExprFecha(xfecha) + '"');
  enviocartas.Close;
end;

procedure TTCtactecl.MarcarEnvioCartaCobrador(xidtitular, xclavecta, xfecha: string);
// Objetivo...: Marcar los clientes que fueron visitados por el cobrador
begin
  enviocobrador.Open;
  if datosdb.Buscar(enviocobrador, 'idtitular', 'clavecta', xidtitular, xclavecta) then enviocobrador.Edit else enviocobrador.Append;
  enviocobrador.FieldByName('idtitular').AsString := xidtitular;
  enviocobrador.FieldByName('clavecta').AsString  := xclavecta;
  enviocobrador.FieldByName('fecha').AsString     := utiles.sExprFecha(xfecha);
  try
    enviocobrador.Post
  except
    enviocobrador.Cancel
  end;
end;

function TTCtactecl.setCartasEnviadasCobrar: TQuery;
begin
  enviocobrador.Open;
  Result := datosdb.tranSQL('SELECT ' + enviocobrador.TableName + '.*, ' + tabla1.TableName + '.* ' + ' FROM ' + enviocobrador.TableName + ', ' + tabla1.TableName + ' WHERE ' + enviocobrador.TableName + '.idtitular = ' + tabla1.TableName + '.idtitular' +
                            ' AND ' + enviocobrador.TableName + '.clavecta = ' + tabla1.TableName + '.clavecta ' + ' ORDER BY fecha');
  enviocobrador.Close;
end;

procedure TTCtactecl.BorrarCartaCobrador(xidtitular, xclavecta, xfecha: string);
begin
  enviocobrador.Open;
  datosdb.tranSQL('DELETE FROM ' + enviocobrador.TableName + ' WHERE Idtitular = ' + '"' + xidtitular + '"' + ' AND Clavecta = ' + '"' + xclavecta + '"' + ' AND fecha = ' + '"' + utiles.sExprFecha(xfecha) + '"');
  enviocobrador.Close;
end;

procedure TTCtactecl.ListClientesVistadosPorCobrador(xdf, xhf: string; salida: char);
// Objetivo...: Listar aquellos clientes que recibieron carta y que vinieron a pagar
begin
  TSQL.Open; listdat := False;
  List.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Listado de Clientes Vistados por el Cobrador', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cuenta      Cliente', 1, 'Arial, cursiva, 8');
  List.Titulo(70, List.lineactual, 'Fecha Envío', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  while not TSQL.EOF do Begin
    list.Linea(0, 0, TSQL.FieldByName('idtitular').AsString + '-' + TSQL.FieldByName('clavecta').AsString + '  ' + TSQL.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(70, list.Lineactual, utiles.sFormatoFecha(TSQL.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'S');
    listdat := True;
    TSQL.Next;
  end;
  TSQL.Close;

  if not listdat then    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  if listdat then list.FinList else utiles.msgError('No Existen datos para Listar ...!');
end;

procedure TTCtactecl.ListClientesVistadosQuePagaron(xdf, xhf: string; salida: char);
// Objetivo...: Listar aquellos clientes visitados por el cobrador que pagaron
begin
  TSQL.Open; listdat := False; pr  := TSQL.FieldByName('idtitular').AsString; importe_cuota := 0; clant := '';
  List.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Listado de Clientes Vistados que Pagaron', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cuenta      Cliente', 1, 'Arial, cursiva, 8');
  List.Titulo(60, List.lineactual, 'F. Envío   Fe. Pago', 2, 'Arial, cursiva, 8');
  List.Titulo(85, List.lineactual, 'Importe', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  while not TSQL.EOF do Begin
    if TSQL.FieldByName('idtitular').AsString <> pr then list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    if (TSQL.FieldByName('idtitular').AsString <> pr) or (TSQL.FieldByName('clavecta').AsString <> clant) then list.Linea(0, 0, TSQL.FieldByName('idtitular').AsString + '-' + TSQL.FieldByName('clavecta').AsString + '  ' + TSQL.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N') else
      list.Linea(0, 0, TSQL.FieldByName('idtitular').AsString + '-' + TSQL.FieldByName('clavecta').AsString + '  ', 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(60, list.Lineactual, utiles.sFormatoFecha(TSQL.FieldByName('fecha').AsString) + '    ' + utiles.sFormatoFecha(TSQL.FieldByName('fechavto').AsString), 2, 'Arial, normal, 8', salida, 'S');
    list.importe(90, list.Lineactual, '', TSQL.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
    list.Linea(93, list.Lineactual, '  ', 4, 'Arial, normal, 8', salida, 'S');
    listdat := True;
    pr    := TSQL.FieldByName('idtitular').AsString;
    clant := TSQL.FieldByName('clavecta').AsString;
    importe_cuota := importe_cuota + TSQL.FieldByName('importe').AsFloat;
    TSQL.Next;
  end;
  TSQL.Close;

  if not listdat then    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S') else Begin
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
    list.derecha(90, list.lineactual, '', '-------------------', 2, 'Arial, normal, 8');
    list.Linea(0, 0, 'Total de recaudación:', 1, 'Arial, normal, 8', salida, 'N');
    list.importe(90, list.lineactual, '', importe_cuota, 2, 'Arial, normal, 8');
  end;

  if listdat then list.FinList else utiles.msgError('No Existen datos para Listar ...!');
end;

//------------------------------------------------------------------------------

procedure TTCtactecl.ModificarTitular(xidtitular, xnombre: string);
begin
 datosdb.tranSQL('UPDATE ' + tabla1.TableName + ' SET nombre = ' + '"' + xnombre + '"' + ' WHERE idtitular = ' + '"' + xidtitular + '"');
end;

procedure TTCtactecl.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla1.Active then Begin
      tabla1.Open;
      tabla1.FieldByName('fealta').Visible := False; tabla1.FieldByName('clave').Visible := False; tabla1.FieldByName('sel').Visible := False;
      tabla1.FieldByName('idtitular').DisplayLabel := 'Titular'; tabla1.FieldByName('clavecta').DisplayLabel := 'Cta.'; tabla1.FieldByName('obs').DisplayLabel := 'Observaciones'; tabla1.FieldByName('nombre').DisplayLabel := 'Nombre';
    end;
    if not tabla3.Active then Begin
      tabla3.Open;
      tabla3.FieldByName('idtitular').Visible := False; tabla3.FieldByName('clavecta').Visible := False;
    end;
    if not tabla2.Active then tabla2.Open;
  end;
  administNum.conectar;
  Inc(conexiones);
end;

procedure TTCtactecl.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla1);
    datosdb.closeDB(tabla2);
    datosdb.closeDB(tabla3);
  end;
  administNum.desconectar;
end;

//------------------------------------------------------------------------------
// Manejo de Modelos de cartas preimpresos
procedure TTCtactecl.GuardarFormatoCartas(xidcarta: shortint; xcabecera, xcuerpo, xfe, xfc: string);
begin
  if not modeloc.FindKey([xidcarta]) then modeloc.Append else modeloc.Edit;
  modeloc.FieldByName('idcarta').AsInteger   := xidcarta;
  modeloc.FieldByName('encabezado').AsString := xcabecera;
  modeloc.FieldByName('cuerpo').AsString     := xcuerpo;
  modeloc.FieldByName('fe').AsString         := xfe;
  modeloc.FieldByName('fc').AsString         := xfc;
  try
    modeloc.Post
  except
    modeloc.Cancel
  end;
end;

procedure TTCtactecl.BorrarDatosFormatoCartas;
begin
  if modeloc.FindKey([idcarta]) then modeloc.Delete;
end;

procedure TTCtactecl.getDatosFormatoCartas(xidcarta: shortint);
begin
  if modeloc.FindKey([xidcarta]) then Begin
    cabecera := modeloc.FieldByName('encabezado').AsString;
    cuerpo   := modeloc.FieldByName('cuerpo').AsString;
    fc       := modeloc.FieldByName('fc').AsString;
    fe       := modeloc.FieldByName('fe').AsString;
  end else Begin
    idcarta := xidcarta; cabecera := ''; cuerpo := ''; fe := ''; fc := '';
  end;
end;

procedure TTCtactecl.ListarCartas(xidcarta: shortint; xidtitular, xclavecta, fecha, xcriterio: string; salida: char; cantcuotas: integer; xinteres: real);
// Objetivo...: Listar los vencimientos de Cuentas Corrientes
var
  nombre, domicilio, doc, idlist, cllist, cconcepto: string; mesesimpagos: integer;
begin
  mesesimpagos := 0;
  TSQL := datosdb.tranSQL('SELECT * FROM ' + tabla3.TableName + ' WHERE fecha <= ' + '"' + utiles.sExprFecha(fecha) + '"' + ' AND estado = ' + '"' + 'I' + '"' + ' AND items >= ' + '"' + '000' + '"' + ' ORDER BY idtitular, clavecta, fecha');
  recar := 0; total := 0; saldoanter := 0; idant := ''; listdat := False;
  TSQL.Open;
  max := 0; cuotasok := False;

  if not listiniciado then Begin   // Definimos los parámetros
    List.Setear(salida);
    List.Titulo(0, 0, '  ', 1, 'Arial, normal, 10');
    List.Titulo(0, 0, '  ', 1, 'Arial, normal, 10');
    List.Titulo(0, 0, '  ', 1, 'Arial, normal, 10');
    existenMov   := False;
    listiniciado := True;
  end;
  List.NoImprimirPieDePagina;

  if cantcuotas = 0 then cuotasok := True else Begin  // Contamos la cantidad de cuotas para determinar si listamos o no
    TSQL.First; max := 0;
    while not TSQL.EOF do Begin
      if (TSQL.FieldByName('idtitular').AsString = xidtitular) and (TSQL.FieldByName('clavecta').AsString = xclavecta) and (TSQL.FieldByName('estado').AsString = 'I') and (TSQL.FieldByName('items').AsString >= '001') then Inc(max);
      TSQL.Next;
    end;

    if xcriterio = '>=' then Begin
      if max >= cantcuotas then cuotasok := True else cuotasok := False;
    end else if xcriterio = '=' then Begin
      if max = cantcuotas then cuotasok := True else cuotasok := False;
    end;
  end;

  if cuotasok then Begin
    listdat := False;
    TSQL.First; max := 0;
    clant := xidtitular;
    while not TSQL.EOF do Begin
      if (xidtitular = TSQL.FieldByName('idtitular').AsString) and (xclavecta = TSQL.FieldByName('clavecta').AsString) then Begin
        DatosClienteVenc(TSQL.FieldByName('idtitular').AsString);

        if (idlist <> TSQL.FieldByName('idtitular').AsString) or (cllist <> TSQL.FieldByName('clavecta').AsString) then Begin
          nombre    := pr;
          domicilio := dom; doc := docc;
          cconcepto := TSQL.FieldByName('concepto').AsString;

          if total > 0 then List.Linea(0, 0, ' ', 1, 'Arial, cursiva, 5', salida, 'S');
          listdat := True; existenMov := True;
        end;

        if TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat <> 0 then Begin
          // Obtenemos la cantidad de meses impagos
          utiles.calc_antiguedad(TSQL.FieldByName('fecha').AsString, utiles.sExprFecha(fecha));
          mesesimpagos := utiles.getMeses + 1;
        end;
        if xinteres > 0 then saldoanter := saldoanter + ((TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat) * ((xinteres * 0.01)) * (mesesimpagos)); // Intereses
        recar := recar + ((TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat) + (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat) * ((xinteres * 0.01) * (mesesimpagos)));
        total := total + (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat);
        Inc(max);
      end;

      idlist    := TSQL.FieldByName('idtitular').AsString;
      cllist    := TSQL.FieldByName('clavecta').AsString;
      TSQL.Next;
    end;

    conectarCartas;
    // Armamos las cartas
    modeloc.FindKey([xidcarta]);
    getDatosFormatoCartas(xidcarta);
    ListTexto(xidcarta, 'encabezado', nombre, domicilio, loc, salida);
    ListCuerpo(xidcarta, 'cuerpo', total, 0, salida);
    desconectarCartas;

    // Registramos el envio de la carta
    enviocartas.Open;
    enviocartas.IndexFieldNames := 'Idtitular;Clavecta;Idcarta;Fecha';
    if datosdb.Buscar(enviocartas, 'Idtitular', 'Clavecta', 'Idcarta', 'Fecha', xidtitular, xclavecta, IntToStr(xidcarta), utiles.sExprFecha(DateToStr(Now))) then enviocartas.Edit else enviocartas.Append;
    enviocartas.FieldByName('idtitular').AsString := xidtitular;
    enviocartas.FieldByName('clavecta').AsString  := xclavecta;
    enviocartas.FieldByName('idcarta').AsString   := IntToStr(xidcarta);
    enviocartas.FieldByName('fecha').AsString     := utiles.sExprFecha(DateToStr(Now));
    try
      enviocartas.Post
    except
      enviocartas.Cancel
    end;
    enviocartas.Close;
  end;
end;

procedure TTCtactecl.ListTexto(xidcarta: shortint; campo, xnombre, xdomicilio, xlocalidad: string; salida: char);
const
  c: string = '          ';
var
  lineas, i, j, l: integer; f, it, fec: string;
  SelPos: Integer;
begin
  { Cabecera }
  // Cargamos el memo
  fmGMemo.Texto.Lines.Clear;
  fmGMemo.Texto.Text := modeloc.FieldByName(campo).AsString;
  // S U S T I T U C I O  N E S
  SelPos := Pos('#nombre', fmGMemo.Texto.Lines.Text);
  if SelPos > 0 then Begin
    fmGMemo.Texto.SelStart := SelPos - 1;
    fmGMemo.Texto.SelLength := Length('#nombre');
    { Replace selected text with ReplaceText }
    fmGMemo.Texto.SelText := xnombre;
  end;

  SelPos := Pos('#domicilio', fmGMemo.Texto.Lines.Text);
  if SelPos > 0 then Begin
    fmGMemo.Texto.SelStart := SelPos - 1;
    fmGMemo.Texto.SelLength := Length('#domicilio');
    { Replace selected text with ReplaceText }
    fmGMemo.Texto.SelText := xdomicilio;
  end;

  SelPos := Pos('#localidad', fmGMemo.Texto.Lines.Text);
  if SelPos > 0 then Begin
    fmGMemo.Texto.SelStart := SelPos - 1;
    fmGMemo.Texto.SelLength := Length('#localidad');
    { Replace selected text with ReplaceText }
    fmGMemo.Texto.SelText := xlocalidad;
  end;

  SelPos := Pos('#fecha', fmGMemo.Texto.Lines.Text);
  if SelPos > 0 then Begin
    fmGMemo.Texto.SelStart := SelPos - 1;
    fmGMemo.Texto.SelLength := Length('#fecha');
    { Replace selected text with ReplaceText }
    fec := utiles.sExprFecha(DateToStr(now));
    fmGMemo.Texto.SelText := Copy(fec, 7, 2) + ' de ' + meses[StrToInt(Copy(fec, 5, 2))] + ' ' + Copy(fec, 1, 4);
  end;
  //----------------------------------------------------------------------------
  lineas := fmGMemo.Texto.Lines.Count;
  l := 0;

  For i := 1 to lineas do Begin
    Inc(l);
    it := utiles.sLlenarIzquierda(IntToStr(i), 2, '0');
    if Length(Trim(fe)) = 0 then f := 'Arial, negrita, 11' else f := fe;
    j := pos('.', fmGMemo.Texto.Lines[i-1]);
    if UpperCase(Copy(fmGMemo.Texto.Lines[i-1], Length(fmGMemo.Texto.Lines[i-1]) - 1, 1)) < 'a' then j := Length(fmGMemo.Texto.Lines[i-1]);
    if j = 0 then List.Linea(0, 0, c + fmGMemo.Texto.Lines[i-1], 1, f, salida, 'S') else Begin
      if UpperCase(Copy(fmGMemo.Texto.Lines[i-1], j + 1, 1)) < 'a' then List.Linea(0, 0, c + Copy(fmGMemo.Texto.Lines[i-1], 1, (Length(fmGMemo.Texto.Lines[i-1]) {- 2})), 1, f, salida, 'N') else
      List.Linea(0, 0, c + fmGMemo.Texto.Lines[i-1], 1, f, salida, 'N');
    end;
  end;

  if lineas > 0 then List.Linea(0, 0, ' ', 1, 'Times New Roman, normal, 5', salida, 'S');
end;

procedure TTCtactecl.ListCuerpo(xidcarta: shortint; campo: string; ximporte, xpago: real; salida: char);
const
  c: string = '          ';
var
  lineas, i, j, l: integer; f, it, fe: string;
  SelPos: Integer;
begin
  // Cargamos el memo
  fmGMemo.Texto.Lines.Clear;
  fmGMemo.Texto.Text := modeloc.FieldByName(campo).AsString;
  // S U S T I T U C I O  N E S
  SelPos := Pos('#fecha', fmGMemo.Texto.Lines.Text);
  if SelPos > 0 then Begin
    fmGMemo.Texto.SelStart := SelPos - 1;
    fmGMemo.Texto.SelLength := Length('#fecha');
    { Replace selected text with ReplaceText }
    fe := utiles.sExprFecha(DateToStr(now));
    fmGMemo.Texto.SelText := Copy(fe, 7, 2) + ' de ' + meses[StrToInt(Copy(fe, 5, 2))] + ' ' + Copy(fe, 1, 4);
  end;

  SelPos := Pos('#importe', fmGMemo.Texto.Lines.Text);
  if SelPos > 0 then Begin
    fmGMemo.Texto.SelStart := SelPos - 1;
    fmGMemo.Texto.SelLength := Length('#importe');
    { Replace selected text with ReplaceText }
    fmGMemo.Texto.SelText := utiles.FormatearNumero(FloatToStr(ximporte));
  end;

  SelPos := Pos('#pago', fmGMemo.Texto.Lines.Text);
  if SelPos > 0 then Begin
    fmGMemo.Texto.SelStart := SelPos - 1;
    fmGMemo.Texto.SelLength := Length('#pago');
    { Replace selected text with ReplaceText }
    fmGMemo.Texto.SelText := utiles.FormatearNumero(FloatToStr(xpago));
  end;

  SelPos := Pos('#saldo', fmGMemo.Texto.Lines.Text);
  if SelPos > 0 then Begin
    fmGMemo.Texto.SelStart := SelPos - 1;
    fmGMemo.Texto.SelLength := Length('#saldo');
    { Replace selected text with ReplaceText }
    fmGMemo.Texto.SelText := utiles.FormatearNumero(FloatToStr((ximporte - xpago)));
  end;

  SelPos := Pos('#imp-en-letras', fmGMemo.Texto.Lines.Text);
  if SelPos > 0 then Begin
    fmGMemo.Texto.SelStart := SelPos - 1;
    fmGMemo.Texto.SelLength := Length('#imp-en-letras');
    { Replace selected text with ReplaceText }
    fmGMemo.Texto.SelText := utiles.xIntToLletras(StrToInt(FloatToStr(ximporte))) + ' C/ ' + Copy(utiles.FormatearNumero(FloatToStr(ximporte)), Length(utiles.FormatearNumero(FloatToStr(ximporte))) - 1, 2);
  end;

  SelPos := Pos('#intereses', fmGMemo.Texto.Lines.Text);
  if SelPos > 0 then Begin
    fmGMemo.Texto.SelStart := SelPos - 1;
    fmGMemo.Texto.SelLength := Length('#intereses');
    { Replace selected text with ReplaceText }
    fmGMemo.Texto.SelText := utiles.FormatearNumero(FloatToStr(saldoanter));
  end;

  SelPos := Pos('#total', fmGMemo.Texto.Lines.Text);
  if SelPos > 0 then Begin
    fmGMemo.Texto.SelStart := SelPos - 1;
    fmGMemo.Texto.SelLength := Length('#total');
    { Replace selected text with ReplaceText }
    fmGMemo.Texto.SelText := utiles.FormatearNumero(FloatToStr(saldoanter + ximporte));
  end;
  //----------------------------------------------------------------------------
  lineas := fmGMemo.Texto.Lines.Count;
  l := 0;

  For i := 1 to lineas do Begin
    Inc(l);
    it := utiles.sLlenarIzquierda(IntToStr(i), 2, '0');
    if Length(Trim(fc)) = 0 then f := 'Arial, normal, 10' else f := fc;
    j := pos('.', fmGMemo.Texto.Lines[i-1]);
    if UpperCase(Copy(fmGMemo.Texto.Lines[i-1], Length(fmGMemo.Texto.Lines[i-1]) - 1, 1)) < 'a' then j := Length(fmGMemo.Texto.Lines[i-1]);
    if j = 0 then List.Linea(0, 0, c + fmGMemo.Texto.Lines[i-1], 1, f, salida, 'S') else Begin
      if UpperCase(Copy(fmGMemo.Texto.Lines[i-1], j + 1, 1)) < 'a' then List.Linea(0, 0, c + Copy(fmGMemo.Texto.Lines[i-1], 1, (Length(fmGMemo.Texto.Lines[i-1]) {- 2})), 1, f, salida, 'N') else
      List.Linea(0, 0, c + fmGMemo.Texto.Lines[i-1], 1, f, salida, 'N');
    end;
  end;

  if lineas > 0 then List.Linea(0, 0, ' ', 1, 'Times New Roman, normal, 5', salida, 'S');
end;

procedure TTCtactecl.conectarCartas;
begin
  if conexion1 = 0 then
    if not modeloc.Active then modeloc.Open;
  Inc(conexion1);
end;

procedure TTCtactecl.desconectarCartas;
begin
  if conexion1 > 0 then Dec(conexion1);
  if conexion1 = 0 then
    if modeloc.Active then modeloc.Close;
end;

{ Tratamiento de Deudores }
procedure TTCtactecl.DeterminacionDeMorosos(xfecha, xmeses: string);
// Objetivo...: Marcar las cuotas atrasadas para la categoria Morosos
begin
  datosdb.tranSQL('UPDATE ' + tabla3.TableName + ' SET moroso = ' + '"' + ' ' + '"');
  datosdb.tranSQL('UPDATE ' + tabla3.TableName + ' SET moroso = ' + '"' + '*' + '"' + ' WHERE fecha <= ' + '"' + utiles.sExprFecha(utiles.RestarMeses(xfecha, xmeses)) + '"' + ' AND estado = ' + '"' + 'I' + '"' + ' OR estado = ' + '"' + 'R' + '"' + ' AND items >= ' + '"' + '001' + '"' + ' AND DC = ' + '"' + '1' + '"');
end;

function TTCtactecl.DeterminacionDeMorososQuePagaron(xdfecha, xhfecha: string): TQuery;
// Objetivo...: Determinar aquellos morosos que pagaron
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla3.TableName + ' WHERE moroso = ' + '"' + 'M' + '"' + ' AND fepago >= ' + '"' + utiles.sExprFecha(xdfecha) + '"' + ' AND fepago <= ' + '"' + utiles.sExprFecha(xhfecha) + '"' + ' ORDER BY idtitular, clavecta, fecha, items');
end;

function TTCtactecl.CuotasDeMorosos: TQuery;
// Objetivo...: Devolver aquellos movimientos que estan marcados como morosos
begin
  Result := datosdb.tranSQL('SELECT ' + tabla3.TableName + '.Idtitular, ' + tabla3.TableName + '.Clavecta, ' + tabla3.TableName + '.Importe, ' + tabla3.TableName + '.Moroso, ' + tabla3.TableName + '.Fecha, ' + tabla3.TableName + '.Entrega, ' + tabla1.TableName + '.Nombre FROM ' + tabla3.TableName + ',' + tabla1.TableName + ' WHERE ' + tabla3.TableName + '.Idtitular = ' + tabla1.TableName + '.Idtitular ' +
            ' AND ' + tabla3.TableName + '.Clavecta = ' + tabla1.TableName + '.Clavecta ' + ' AND moroso = ' + '"' + '*' + '"' + ' AND items >= ' + '"' + '001' + '"' + ' AND estado = ' + '"' + 'I' + '"' + ' ORDER BY ' + tabla1.TableName + '.Nombre, ' + tabla3.TableName + '.Clavecta, ' + tabla3.TableName + '.Fecha');
end;

function TTCtactecl.CuotasDeMorosos(xidtitular: String): TQuery;
// Objetivo...: Devolver aquellos movimientos que estan marcados como morosos
begin
  Result := datosdb.tranSQL('SELECT ' + tabla3.TableName + '.Idtitular, ' + tabla3.TableName + '.Clavecta, ' + tabla3.TableName + '.Concepto, ' + tabla3.TableName + '.Importe, ' + tabla3.TableName + '.Moroso, ' + tabla3.TableName + '.Fecha, ' + tabla1.TableName + '.Nombre, ' + tabla3.TableName + '.items, ' + tabla3.TableName + '.entrega, ' + tabla3.TableName + '.idcompr, ' + tabla3.TableName + '.tipo, ' + tabla3.TableName + '.sucursal, ' + tabla3.TableName + '.numero ' +
                            ' FROM ' + tabla3.TableName + ',' + tabla1.TableName + ' WHERE ' + tabla3.TableName + '.Idtitular = ' + tabla1.TableName + '.Idtitular ' + ' AND ' + tabla3.TableName + '.Clavecta = ' + tabla1.TableName + '.Clavecta ' +
                            ' AND moroso = ' + '"' + '*' + '"' + ' AND items >= ' + '"' + '-1' + '"' + ' AND estado = ' + '"' + 'I' + '"' + ' AND ' + tabla3.TableName + '.idtitular = ' + '"' + xidtitular + '"' + ' ORDER BY ' + tabla3.TableName + '.clavecta, ' + tabla3.TableName + '.items');
end;

function TTCtactecl.MorososQueHanCanceladoDeuda(xdfecha, xhfecha: string): TQuery;
// Objetivo...: Morosos que han cancelado deuda
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + morosos.TableName + ' WHERE fecha >= ' + '"' + utiles.sExprFecha(xdfecha) + '"' + ' AND fecha <= ' + '"' + utiles.sExprFecha(xhfecha) + '"' + ' ORDER BY idtitular, clavecta, fecha');
end;

procedure TTCtactecl.ListarMorosos(salida: char);
// Objetivo...: Listar Deudores Morosos
var
  r: TQuery;
begin
  r := CuotasDeMorosos; r.Open; r.First; importe_cuota := 0; total := 0; saldoanter := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Listado de Morosos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id. Titular  Cliente', 1, 'Arial, cursiva, 8');
  List.Titulo(35, List.lineactual, 'Dirección', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Doc./CUIT', 3, 'Arial, cursiva, 8');
  List.Titulo(74, List.lineactual, 'Fe.Vto', 4, 'Arial, cursiva, 8');
  List.Titulo(84, List.lineactual, 'Cuotas.', 5, 'Arial, cursiva, 8');
  List.Titulo(93, List.lineactual, 'Importe', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  idtitular := r.FieldByName('idtitular').AsString;
  while not r.EOF do Begin
    dom := utiles.sFormatoFecha(r.FieldByName('fecha').AsString);
    if r.FieldByName('idtitular').AsString <> idtitular then ListarLineaMorosos(salida);
    idtitular := r.FieldByName('idtitular').AsString;
    importe_cuota := importe_cuota + (r.FieldByName('importe').AsFloat - r.FieldByName('entrega').AsFloat);
    saldoanter    := saldoanter    + (r.FieldByName('importe').AsFloat - r.FieldByName('entrega').AsFloat);
    total         := total + 1;
    r.Next;
  end;
  ListarLineaMorosos(salida);

  list.Linea(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, 'Total General .......: ', 1, 'Arial, normal, 8', salida, 'S');
  list.importe(98, list.Lineactual, '', saldoanter, 2, 'Arial, negrita, 8');
  list.Linea(99, list.Lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');

  r.Close; r.Free;

  list.FinList;
end;

procedure TTCtactecl.ListarLineaMorosos(salida: char);
// Objetivo...: Listar Deudores Morosos
begin
  DatosCliente;
  list.Linea(0, 0, idtitular + '  ' + rsCliente, 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(35, list.Lineactual, domcliente, 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(65, list.Lineactual, docc, 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(74, list.Lineactual, dom, 4, 'Arial, normal, 8', salida, 'N');
  list.importe(87, list.Lineactual, '###', total, 5, 'Arial, normal, 8');
  list.importe(98, list.Lineactual, '', importe_cuota, 6, 'Arial, normal, 8');
  list.Linea(99, list.Lineactual, ' ', 7, 'Arial, normal, 8', salida, 'S');
  importe_cuota := 0; total := 0;
end;

procedure TTCtactecl.ListarMorosos_DetalleCuotasAtrasadas(xidtitular: string; salida: char);
// Objetivo...: Listar Deudores Morosos
var
  r: TQuery;
begin
  r := CuotasDeMorosos(xidtitular); r.Open; r.First; importe_cuota := 0; total := 0; saldoanter := 0; clavecta := '';
  List.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Detalle de Cuotas Atrazadas de Morosos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cuenta Items Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(62, List.lineactual, 'Importe', 2, 'Arial, cursiva, 8');
  List.Titulo(72, List.lineactual, 'Entrega', 3, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Saldo', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  while not r.EOF do Begin
    if r.FieldByName('idtitular').AsString <> idtitular then Begin
      if total <> 0 then SubtotalDetalle(salida);
      idtitular := r.FieldByName('idtitular').AsString;
      DatosCliente;
      if r.FieldByName('items').AsString = '-1' then getDatos(r.FieldByName('clavecta').AsString, r.FieldByName('idtitular').AsString, r.FieldByName('idcompr').AsString, r.FieldByName('tipo').AsString, r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString, '-1');
      list.Linea(0, 0, idtitular + '  ' + rsCliente, 1, 'Arial, negrita, 8', salida, 'N');
      list.Linea(32, list.Lineactual, domcliente, 2, 'Arial, negrita, 8', salida, 'N');
      list.Linea(62, list.Lineactual, tabla3.FieldByName('concepto').AsString, 3, 'Arial, negrita, 8', salida, 'N');
      list.Linea(82, list.Lineactual, tabla3.FieldByName('idcompr').AsString + ' ' + tabla3.FieldByName('tipo').AsString + ' ' + tabla3.FieldByName('sucursal').AsString + '-' + tabla3.FieldByName('numero').AsString, 4, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    end;
    if (r.FieldByName('clavecta').AsString <> clavecta) and (total <> 0) then Begin
      if total <> 0 then SubtotalDetalle(salida);
      if r.FieldByName('items').AsString = '-1' then getDatos(r.FieldByName('clavecta').AsString, r.FieldByName('idtitular').AsString, r.FieldByName('idcompr').AsString, r.FieldByName('tipo').AsString, r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString, '-1');
      concepto := r.FieldByName('concepto').AsString;
      list.Linea(0, 0, '  ', 1, 'Arial, negrita, 8', salida, 'N');
      list.Linea(32, list.Lineactual, ' ', 2, 'Arial, negrita, 8', salida, 'N');
      list.Linea(62, list.Lineactual, tabla3.FieldByName('concepto').AsString, 3, 'Arial, negrita, 8', salida, 'N');
      list.Linea(82, list.Lineactual, tabla3.FieldByName('idcompr').AsString + ' ' + tabla3.FieldByName('tipo').AsString + ' ' + tabla3.FieldByName('sucursal').AsString + '-' + tabla3.FieldByName('numero').AsString, 4, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    end;
    // Detalle
    if r.FieldByName('items').AsString >= '001' then Begin
      list.Linea(0, 0, r.FieldByName('clavecta').AsString + '  ' + r.FieldByName('items').AsString + '  ' + utiles.sFormatoFecha(r.FieldByName('fecha').AsString) + '  ' + concepto, 1, 'Arial, normal, 8', salida, 'N');
      list.importe(65, list.Lineactual, '', r.FieldByName('importe').AsFloat, 2, 'Arial, normal, 8');
      list.importe(75, list.Lineactual, '', r.FieldByName('entrega').AsFloat, 3, 'Arial, normal, 8');
      list.importe(90, list.Lineactual, '', r.FieldByName('importe').AsFloat - r.FieldByName('entrega').AsFloat, 4, 'Arial, normal, 8');
      list.Linea(92, list.Lineactual, ' ', 5, 'Arial, normal, 8', salida, 'S');

      total         := total         + r.FieldByName('importe').AsFloat;
      importe_cuota := importe_cuota + (r.FieldByName('importe').AsFloat - r.FieldByName('entrega').AsFloat);
      saldoanter    := saldoanter    + r.FieldByName('entrega').AsFloat;
      concepto      := '';
    end;
    idtitular  := r.FieldByName('idtitular').AsString;
    clavecta   := r.FieldByName('clavecta').AsString;
    r.Next;
  end;
  if total <> 0 then SubtotalDetalle(salida);

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(0, 0, 'Total General .......: ', 1, 'Arial, negrita, 8', salida, 'S');
  list.importe(90, list.Lineactual, '', importe_cuota, 2, 'Arial, negrita, 8');
  list.Linea(92, list.Lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');

  r.Close; r.Free;

  if importe_cuota = 0 then list.Linea(0, 0, 'No existen datos para Listar ...!', 1, 'Arial, normal, 8', salida, 'N');
  list.FinList;
end;

procedure TTCtactecl.SubtotalDetalle(salida: char);
// Objetivo...: Subtotal por cuenta
begin
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(92, list.Lineactual, '', '----------------------------------------------------------', 2, 'Arial, normal, 9');
  list.Linea(0, 0, 'Subtotales .......: ', 1, 'Arial, negrita, 8', salida, 'S');
  list.importe(65, list.Lineactual, '', total, 2, 'Arial, negrita, 8');
  list.importe(75, list.Lineactual, '', saldoanter, 3, 'Arial, negrita, 8');
  list.importe(90, list.Lineactual, '', total - saldoanter, 4, 'Arial, negrita, 8');
  list.Linea(92, list.Lineactual, ' ', 5, 'Arial, negrita, 8', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  total := 0; saldoanter := 0;
end;

procedure TTCtactecl.ListarmorososQuePagaron(xdfecha, xhfecha: string; salida: char);
// Objetivo...: Presentar nómina de morosos que pagaron
var
  r: TQuery;
begin
  r := DeterminacionDeMorososQuePagaron(xdfecha, xhfecha);
  r.Open; r.First; importe_cuota := 0; total := 0; idtitular := '';
  List.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Nómina de Morosos que Pagaron', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.  Cliente', 1, 'Arial, cursiva, 8');
  List.Titulo(35, List.lineactual, 'Dirección', 2, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'Entrega', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  while not r.EOF do Begin
    if r.FieldByName('idtitular').AsString <> idtitular then Begin
      idtitular := r.FieldByName('idtitular').AsString;
      DatosCliente;
      list.Linea(0, 0, idtitular + '  ' + rsCliente, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(35, list.Lineactual, domCliente, 2, 'Arial, normal, 8', salida, 'N');
      importe_cuota := 0; total := 0;
    end else Begin
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(35, list.Lineactual, ' ', 2, 'Arial, normal, 8', salida, 'N');
    end;

    importe_cuota := r.FieldByName('importe').AsFloat;
    list.importe(85, list.Lineactual, '', importe_cuota, 3, loc);
    list.Linea(98, list.Lineactual, ' ', 4, loc, salida, 'S');

    idtitular := r.FieldByName('idtitular').AsString;
    r.Next;
  end;
  r.Close;

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, 'Deudores que han cancelado la Deuda', 1, 'Arial, negrita, 12', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 10', salida, 'S');

  // Morosos que han cancelado la Ficha
  r := MorososQueHanCanceladoDeuda(xdfecha, xhfecha);
  r.Open; r.First;
  while not r.EOF do Begin
    idtitular := r.FieldByName('idtitular').AsString;
    DatosCliente;
    list.Linea(0, 0, idtitular + '  ' + rsCliente, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(35, list.Lineactual, domCliente, 2, 'Arial, normal, 8', salida, 'N');
    list.importe(85, list.Lineactual, '', r.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
    list.Linea(98, list.Lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
    saldoanter := saldoanter + r.FieldByName('importe').AsFloat;
    r.Next;
  end;
  r.Close; r.Free;

  if importe_cuota + total + saldoanter <> 0 then list.FinList else utiles.msgError('No Existen Datos para Listar ...!');
end;

procedure TTCtactecl.TransferirAlFicheroDeMorosos(xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero: string; ximporte: real);
// Objetivo...: Transferir al fichero de morosos las cuentas saldadas
begin
  morosos.Open;
  if datosdb.Buscar(morosos, 'idtitular', 'clavecta', 'idc', 'tipo', 'sucursal', 'numero', xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero) then morosos.Edit else morosos.Append;
  morosos.FieldByName('idtitular').AsString := xidtitular;
  morosos.FieldByName('clavecta').AsString  := xclavecta;
  morosos.FieldByName('idc').AsString       := xidc;
  morosos.FieldByName('tipo').AsString      := xtipo;
  morosos.FieldByName('sucursal').AsString  := xsucursal;
  morosos.FieldByName('numero').AsString    := xnumero;
  morosos.FieldByName('fecha').AsString     := utiles.sExprFecha(DateToStr(Now));
  morosos.FieldByName('importe').AsFloat    := ximporte;
  try
    morosos.Post
  except
    morosos.Cancel
  end;
  morosos.Close;
end;

procedure TTCtactecl.MarcarPagoMoroso(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string);
begin
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then Begin
    tabla3.Edit;
    tabla3.FieldByName('moroso').AsString := 'M';
    try
      tabla3.Post
     except
      tabla3.Cancel
    end;
  end;
end;

{===============================================================================}

function cccl: TTCtactecl;
begin
  if xctactecl = nil then
    xctactecl := TTCtactecl.Create;
  Result := xctactecl;
end;

{===============================================================================}

initialization

finalization
  xctactecl.Free;

end.
