unit Ccctsoc;

interface

uses SysUtils, DB, DBTables, CBDT, CCtactes, CSocAdherente, CListar, CUtiles, CIDBFM;

type

TTCtacteSoc = class(TTCtacte)            // Superclase
  codsocio: string; interes: real;
 public
  { Declaraciones Públicas }
  constructor Create(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xtm, xfecha, xfealta, xobs, xconcepto, xcodsocio: string; ximporte: real);
  destructor  Destroy; override;

  function    VerifCliente(xcodsocio: string): boolean;
  function    getCliente(xcodsocio: string): string;
  function    getDireccion(xcodsocio: string): string;
  function    getCodsocio: string;
  function    getInteres: real;
  function    getTcliente: TTable;

  procedure   GrabarTran(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto, xcodsocio: string; ximporte, xentrega, xcuota, xinteres: real);
  procedure   GrabarPago(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto, xcodsocio: string; ximporte, xentrega, xcuota, xinteres, xrecargo: real; ftc, fti, fsu, fnu, fit: string);
  procedure   GrabarFact(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm: string; ximporte, xentrega: real);

  procedure   BorrarPago(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string);
  procedure   BorrarComprobante(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
  function    getPagos(xclavecta, xidtitular: string): TQuery;
  function    getRecibos(xclavecta, xidtitular: string): TQuery; overload;
  function    getRecibos(xidtitular: string): TQuery; overload;
  function    setCuotas(xidtitular: string): TQuery;
  procedure   getDatosFactReci(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
  procedure   Depurar(fecha: string);
  function    getFactventa(xidc, xtipo, xsucursal, xnumero: string): TQuery;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   rListar(iniciar, finalizar: string; salida: char);
  procedure   rListarPlan(iniciar, finalizar: string; salida: char);
  procedure   rSubtotales(salida: char);
  procedure   rSubtotales1(salida: char; t: string);
  procedure   rList_Linea(salida: char);
  procedure   List_LineaPlan(salida: char);
  procedure   ListarVencimientos(fecha: string; salida: char);
  procedure   ListPlanillaSaldos(fecha: string; salida: char);
  procedure   rListarRes(iniciar, finalizar: string; salida: char);
  procedure   CalcularCapital(xcodsocio, xfecha: string);
  function    getCreditosaCobrar: real;
  function    getInteresesCobrar: real;
  function    getInteresesProyectados: real;
  function    getTotRecargos: real;
  function    getMcctcl: TQuery; overload;
  function    getMcctcl(xt, xc: string): TQuery; overload;
  function    EstsqlSaldosCobrar(fecha1, fecha2: string): TQuery;  // Estadísticas
  function    EstsqlCobrosEfectuados(fecha1, fecha2: string): TQuery;
  function    EstsqlCuotasVencidas(fecha1, fecha2: string): TQuery;
  function    AuditoriaFacturasEmitidas(fecha: string): TQuery;  // SQL Auditoría
  function    AuditoriaRecaudacionesCobros(fecha: string): TQuery;
  function    setVencimientos(fecha: string): TQuery;
  function    setSocio(xcodsocio: string): boolean;
  procedure   ListarFichaPlanPagos(xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero, xinicio, xfin: string; salida: char);
  procedure   rListarResumenSocio(xidtitular, iniciar, finalizar: string; salida: char);
  procedure   ListarPlanPagos(iniciar, finalizar: string; salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  importe_cuota, totin, totrecargos, intproy: real;
  procedure   MarcarCuotaPaga(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string; ximporte, xcuota: real);
  function    RecalcularEntregas(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string): real;
  procedure   ObtenerSaldo(xidtitular, xclavecta: string);
  procedure   tot_deuda(salida: char);
  procedure   List_linea(salida: char);
  procedure   cList_linea(salida: char);
  procedure   TitulosResctas(salida: char);
  procedure   BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
  procedure   ListTitFichaPagos(salida: char);
  procedure   rListarResSocio(xidtitular, iniciar, finalizar: string; salida: char);
end;

function ccsoc: TTCtacteSoc;

implementation

var
  xctactecl: TTCtacteSoc = nil;

constructor TTCtacteSoc.Create(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xtm, xfecha, xfealta, xobs, xconcepto, xcodsocio: string; ximporte: real);
begin
  inherited Create; ///(xclavecta, xidtitular, '', xidc, xtipo, xsucursal, xnumero, xtm, xfecha, xfealta, xobs, xconcepto, ximporte);

  tabla1 := datosdb.openDB('cctcl', 'Idtitular;Clavecta');
  tabla2 := datosdb.openDB('ctactecf', 'Idcompr;Tipo;Sucursal;Numero');
  tabla3 := datosdb.openDB('ctactecl', 'Idtitular;Clavecta;Idcompr;Tipo;Sucursal;Numero;Items');
end;

destructor TTCtacteSoc.Destroy;
begin
  desconectar;
  inherited Destroy;
end;

function TTCtacteSoc.VerifCliente(xcodsocio: string): boolean;
// Objetivo...: Verificamos que el proveedor ingresado Exista
begin
  if socioadherente.Buscar(xcodsocio) then Result := True else Result := False;
end;

function TTCtacteSoc.getCliente(xcodsocio: string): string;
begin
  socioadherente.getDatos(xcodsocio);
  Result := socioadherente.Nombre;
end;

function TTCtacteSoc.getDireccion(xcodsocio: string): string;
begin
  socioadherente.getDatos(xcodsocio);
  Result := socioadherente.Domicilio;
end;

function TTCtacteSoc.getCodSocio: string;
begin
  Result := codsocio;
end;

function TTCtacteSoc.getInteres: real;
begin
  Result := interes;
end;

function TTCtacteSoc.getTcliente: TTable;
begin
  Result := socioadherente.tperso;
end;

procedure TTCtacteSoc.getDatosFactReci(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
// Objetivo...: Buscar un comprobante Registrado con el Id de Ventas
begin
  if inherited BuscarFR(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero) then
    begin
      inherited getDatosFactReci(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero);
      codsocio := tabla3.FieldByName('codsocio').AsString;
      interes  := tabla3.FieldByName('interes').AsFloat;
    end
  else
    begin
      codsocio := ''; interes := 0;
    end;
end;

function TTCtacteSoc.getFactventa(xidc, xtipo, xsucursal, xnumero: string): TQuery;
// Objetivo...: Buscar un comprobante Registrado con el Id de Ventas
begin
  if datosdb.Buscar(tabla2, 'idcompr', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero) then
    begin
      TransferirDatos(True);
      // Atributos NO Heredados o  Sobrecargados
      clavecta  := tabla2.FieldByName('clavecta').AsString;
      idtitular := tabla2.FieldByName('idtitular').AsString;
      fecha     := tabla2.FieldByName('fecha').AsString;
      importe   := tabla2.FieldByName('importe').AsFloat;
      entrega   := tabla2.FieldByName('entrega').AsFloat;
      // Filtramos el Plan
      getDatosFactReci(clavecta, idtitular, xidc, xtipo, xsucursal, xnumero);
      Result  := getPlan(clavecta, idtitular, xidc, xtipo, xsucursal, xnumero);
    end
  else
    begin
      codsocio := ''; interes := 0;
      TransferirDatos(False);
      Result := nil;
    end;
end;

procedure TTCtacteSoc.GrabarTran(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto, xcodsocio: string; ximporte, xentrega, xcuota, xinteres: real);
// Objetivo...: Grabar los movimientos Generados a partir de los planes, cobros/o pagos efectuados
begin
  if xitems = '-1' then GrabarFact(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm, ximporte, xentrega);
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then
    begin
      if xitems = '000' then tabla3.Edit;
      if xitems = '-1' then  // Si existia ya el plan cargado lo anulamos
        begin
          BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal,xnumero);
          tabla3.Append;
        end
    end
      else
        tabla3.Append;
   tabla3.FieldByName('periodo').AsString   := xperiodo;
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
   tabla3.FieldByName('codsocio').AsString  := xcodsocio;
   tabla3.FieldByName('interes').AsFloat    := xinteres;
   if (xitems = '-1') or (xidc = 'SIN') then tabla3.FieldByName('XN').AsString := 'FACT.ORIG.';
   if xitems = '0' then
     begin
       tabla3.FieldByName('XC').AsString     := xidc;
       tabla3.FieldByName('XT').AsString     := xtipo;
       tabla3.FieldByName('XS').AsString     := xsucursal;
       tabla3.FieldByName('XN').AsString     := xnumero;
       tabla3.FieldByName('estado').AsString := 'E';
     end;
   try
     tabla3.Post;
   except
     tabla3.Cancel;
   end;
end;

procedure TTCtacteSoc.BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
// Objetivo...: Eliminar detalle del comprobante
begin
  datosdb.tranSQL('DELETE FROM ctactecl WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''' +
                    ' AND idcompr = ' + '''' + xidc + '''' + ' AND tipo = ' + '''' + xtipo + '''' + ' AND sucursal = ' + '''' + xsucursal + '''' + ' AND numero = ' + '''' + xnumero + '''');
end;

procedure TTCtacteSoc.BorrarComprobante(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
// Objetivo...: Eliminar un comprobante - detalle y relaciones
begin
  datosdb.tranSQL('DELETE FROM ctactecf WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''' +
                  ' AND idcompr = ' + '''' + xidc + '''' + ' AND tipo = ' + '''' + xtipo + '''' + ' AND sucursal = ' + '''' + xsucursal + '''' + ' AND numero = ' + '''' + xnumero + '''');
  BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero);
  // Actualizamos los atributos
  getDatos(tabla2.FieldByName('clavecta').AsString, tabla2.FieldByName('idtitular').AsString, tabla2.FieldByName('idcompr').AsString, tabla2.FieldByName('tipo').AsString, tabla2.FieldByName('sucursal').AsString, tabla2.FieldByName('numero').AsString, tabla2.FieldByName('DC').AsString);
end;

procedure TTCtacteSoc.GrabarPago(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto, xcodsocio: string; ximporte, xentrega, xcuota, xinteres, xrecargo: real; ftc, fti, fsu, fnu, fit: string);
// Objetivo...: Grabar los movimientos Generados a partir de los planes, cobros/o pagos efectuados
begin
  tabla3.Filtered := False;
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then tabla3.Edit else tabla3.Append;
  tabla3.FieldByName('periodo').AsString   := xperiodo;
  tabla3.FieldByName('clavecta').AsString  := xclavecta;
  tabla3.FieldByName('idtitular').AsString := xidtitular;
  tabla3.FieldByName('idcompr').AsString   := xidc;
  tabla3.FieldByName('tipo').AsString      := xtipo;
  tabla3.FieldByName('sucursal').AsString  := xsucursal;
  tabla3.FieldByName('numero').AsString    := xnumero;
  tabla3.FieldByName('items').AsString     := xitems;
  tabla3.FieldByName('fecha').AsString     := utiles.sExprFecha(xfecha);
  tabla3.FieldByName('importe').AsFloat    := ximporte;
  tabla3.FieldByName('interes').AsFloat    := xinteres;
  tabla3.FieldByName('recargo').AsFloat    := xrecargo;
  tabla3.FieldByName('DC').AsInteger       := StrToInt(xtm);
  tabla3.FieldByName('concepto').AsString  := xconcepto;
  tabla3.FieldByName('estado').AsString    := 'R';
  tabla3.FieldByName('codsocio').AsString  := xcodsocio;
  // Datos de la cuota/factura a la que imputa

  tabla3.FieldByName('XC').AsString        := ftc;
  tabla3.FieldByName('XT').AsString        := fti;
  tabla3.FieldByName('XS').AsString        := fsu;
  tabla3.FieldByName('XN').AsString        := fnu;
  try
    tabla3.Post;
    // Si el monto ingresado es igual al de la Cuota, marcamos la misma como paga
    MarcarCuotaPaga(xclavecta, xidtitular, ftc, fti, fsu, fnu, xitems, ximporte, xcuota);
  except
    tabla3.Cancel;
  end;
  importe_cuota := ximporte;
  tabla3.Filtered := True;
end;

procedure TTCtacteSoc.MarcarCuotaPaga(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string; ximporte, xcuota: real);
// Objetivo...: Marcar una cuota como paga
begin
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then
   begin
     importe_cuota := ximporte;
     importe_cuota := RecalcularEntregas(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems); // Determino si el pago fue total o parcial
     Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems);
     tabla3.Edit;
     if importe_cuota = tabla3.FieldByName('importe').AsFloat +  tabla3.FieldByName('interes').AsFloat then tabla3.FieldByName('estado').AsString := 'P' else tabla3.FieldByName('estado').AsString := 'I';
     tabla3.FieldByName('entrega').AsFloat := importe_cuota;
     try
       tabla3.Post;
     except
       tabla3.Cancel;
     end;
   end;
end;

function TTCtacteSoc.RecalcularEntregas(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string): real;
// Objetivo...: obtener el total pagado para una factura
var
  total: real;
begin
  total := 0;
  tabla3.IndexName := 'actcuotas';
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

procedure TTCtacteSoc.BorrarPago(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string);
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
           tabla3.Post;
         except
           tabla3.Cancel;
         end;
       end;
   end;
end;

procedure TTCtacteSoc.GrabarFact(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm: string; ximporte, xentrega: real);
// Objetivo...: Grabar una Factura
begin
  if BuscarFR(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('periodo').AsString   := xperiodo;
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
  try
    tabla2.Post;
  except
    tabla2.Cancel;
  end;
end;

function TTCtacteSoc.getPagos(xclavecta, xidtitular: string): TQuery;
// Objetivo...: Devolver un Set de las Cuentas Corrientes Disponibles para un titular
begin
  Result := datosdb.tranSQL('SELECT * FROM ctactecl WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''' + ' ORDER BY fecha, items');
end;

function TTCtacteSoc.getRecibos(xclavecta, xidtitular: string): TQuery;
// Objetivo...: Devolver un Set de los Recibos Ingresados
begin
  Result := datosdb.tranSQL('SELECT * FROM ctactecl WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''' + ' AND estado = ' + '''' + 'R' + '''' + ' ORDER BY fecha, items');
end;

function TTCtacteSoc.setCuotas(xidtitular: string): TQuery;
// Objetivo...: Devolver las cuotas para un socio dado
begin
  Result := datosdb.tranSQL('SELECT * FROM ctactecl WHERE idtitular = ' + '''' + xidtitular + '''' + ' AND items >= ' + '''' + '001' + '''' + ' ORDER BY fecha, items');
end;

function TTCtacteSoc.getRecibos(xidtitular: string): TQuery;
// Objetivo...: Devolver un Set de los Recibos Ingresados para un Socio Dado
begin
  Result := datosdb.tranSQL('SELECT * FROM ctactecl WHERE idtitular = ' + '''' + xidtitular + '''' + ' AND estado = ' + '''' + 'R' + '''' + ' ORDER BY fecha, items');
end;

function TTCtacteSoc.setVencimientos(fecha: string): TQuery;
// Objetivo...: Retornar un subset de registro con los pagos vencidos
begin
  Result := datosdb.tranSQL('SELECT * FROM ctactecl WHERE fecha <= ' + '''' + utiles.sExprFecha(fecha) + '''' + ' AND estado = ' + '''' + 'I' + '''' + ' AND items >= ' + '''' + '000' + '''' + ' ORDER BY fecha');
end;

procedure TTCtacteSoc.Depurar(fecha: string);
// Objetivo...: depurar los movimientos de cuenta corriente
var
  r: TQuery;
  xco, xti, xsu, xnu, xtt, xcl: string;
begin
  // Aislamos los comprobantes cancelados
  r := datosdb.tranSQL('SELECT * FROM ctactecl WHERE estado = ' + '''' + 'P' + '''' + ' AND fecha < ' + '''' + utiles.sExprFecha(fecha) + '''');
  // Filtramos aquellos que resulten ser Facturas o Saldos iniciales
  datosdb.Filtrar(r, 'XN = ' + '''' + 'FACT.ORI' + '''' + ' OR items = ' + '''' + '000' + '''');
  r.Open; r.First;

  while not r.EOF do     // Procesamos el Set de Comprobantes Listos para Depurar
    begin
      // Extraemos la información del comprobante
      xco := r.FieldByName('idcompr').AsString;
      xti := r.FieldByName('tipo').AsString;
      xsu := r.FieldByName('sucursal').AsString;
      xnu := r.FieldByName('numero').AsString;
      xtt := r.FieldByName('idtitular').AsString;
      xcl := r.FieldByName('clavecta').AsString;

      // Eliminamos recibo y entrega inicial
      datosdb.tranSQL('DELETE FROM ctactecl WHERE XC = ' + '''' + xco + '''' + ' AND XT = ' + '''' + xti + '''' + ' AND XS = ' + '''' + xsu + '''' + ' AND XN = ' + '''' + xnu + '''' + ' AND idtitular = ' + '''' + xtt + '''' + ' AND clavecta = ' + '''' + xcl + '''' + ' AND DC = ' + '''' + '2' + '''');
      // Eliminamos Factura
      datosdb.tranSQL('DELETE FROM ctactecl WHERE idcompr = ' + '''' + xco + '''' + ' AND tipo = ' + '''' + xti + '''' + ' AND sucursal = ' + '''' + xsu + '''' + ' AND numero = ' + '''' + xnu + '''' + ' AND idtitular = ' + '''' + xtt + '''' + ' AND clavecta = ' + '''' + xcl + '''' + ' AND DC = ' + '''' + '1' + '''');
      // Eliminamos los saldos iniciales Pagados
      datosdb.tranSQL('DELETE FROM ctactecl WHERE idtitular = ' + '''' + xtt + '''' + ' AND clavecta = ' + '''' + xcl + '''' + ' AND estado = ' + '''' + 'P' + '''' + ' AND idcompr = ' + '''' + 'SIN' + '''');
       // Eliminamos las Facturas canceladas
      datosdb.tranSQL('DELETE FROM ctactecf WHERE idcompr = ' + '''' + xco + '''' + ' AND tipo = ' + '''' + xti + '''' + ' AND sucursal = ' + '''' + xsu + '''' + ' AND numero = ' + '''' + xnu + '''' + ' AND idtitular = ' + '''' + xtt + '''' + ' AND clavecta = ' + '''' + xcl + '''' + ' AND DC = ' + '''' + '1' + '''');

      r.Next;
  end;

  r.Close; r.Free;
end;

function TTCtacteSoc.setSocio(xcodsocio: string): boolean;
// Objetivo...: verificar si existe un socio en una cuenta corriente
var
  opt: boolean;
begin
  Result := False; opt := False;
  if not tabla2.Active then
    begin
      opt := True;
      tabla2.Open;
    end;
  tabla2.First;
  while not tabla2.EOF do
    begin
      if tabla2.FieldByName('idtitular').AsString = xcodsocio then
        begin
          Result := True;
          Break;
        end;
       tabla2.Next;
    end;
  if opt then tabla2.Close;
end;

procedure TTCtacteSoc.List_linea(salida: char);
// Objetivo...: Listar una Línea
var
  pr: string;
begin
  socioadherente.Buscar(tabla1.FieldByName('idtitular').AsString);
  if tabla1.FieldByName('idtitular').AsString <> idant then pr := socioadherente.tperso.FieldByName('nombre').AsString else pr := ' ';
  List.Linea(0, 0, tabla1.FieldByName('idtitular').AsString + ' ' + tabla1.FieldByName('clavecta').AsString + '    ' + pr, 1, 'Courier New, normal, 8', salida, 'N');
  List.Linea(57, List.lineactual, tabla1.FieldByName('obs').AsString, 2, 'Courier New, normal, 8', salida, 'N');
  List.Linea(90, List.lineactual, utiles.sFormatoFecha(tabla1.FieldByName('fealta').AsString), 3, 'Courier New, normal, 8', salida, 'S');
  idant := tabla1.FieldByName('idtitular').AsString;
end;

procedure TTCtacteSoc.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de clientees Definidas
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Listado de Créditos Definidos/Otorgados', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cuenta       Titular', 1, 'Courier New, cursiva, 8');
  List.Titulo(57, List.lineactual, 'Observaciones', 2, 'Courier New, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Fe. Alta', 3, 'Courier New, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla1.First;
  while not tabla1.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla1.FieldByName('idtitular').AsString >= iniciar) and (tabla1.FieldByName('idtitular').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla1.FieldByName('idtitular').AsString < iniciar) or (tabla1.FieldByName('idtitular').AsString > finalizar) then List_linea(salida);

      tabla1.Next;
    end;
    List.FinList;

    tabla1.First;
end;

procedure TTCtacteSoc.rList_linea(salida: char);
// Objetivo...: Listar una Línea - ruptura por cuenta
var
  pr: string;
begin
  if tabla3.FieldByName('DC').AsString = '1' then td := td + tabla3.FieldByName('importe').AsFloat;
  if tabla3.FieldByName('DC').AsString = '2' then th := th + tabla3.FieldByName('importe').AsFloat;

  if (tabla3.FieldByName('idtitular').AsString <> idant) or (tabla3.FieldByName('clavecta').AsString <> clant) then
    begin
      // Subtotal
      if idant <> '' then rSubtotales(salida);

      socioadherente.Buscar(tabla3.FieldByName('idtitular').AsString);
      pr := socioadherente.tperso.FieldByName('nombre').AsString;
      List.Linea(0, 0, 'Cuenta: ' + tabla3.FieldByName('idtitular').AsString + '-' + tabla3.FieldByName('clavecta').AsString + '    ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      List.Linea(0, 0, utiles.espacios(140) + 'Saldo Anterior ....: ', 1, 'Arial, cursiva, 8', salida, 'S');
      if tabla3.FieldByName('DC').AsString = '1' then saldoanter := saldo - tabla3.FieldByName('importe').AsFloat else saldoanter := saldo + tabla3.FieldByName('importe').AsFloat;
      List.importe(100, list.lineactual, '', saldoanter, 2, 'Arial, cursiva, 8');
      List.Linea(101, list.lineactual, ' ', 3, 'Arial, cursiva, 8', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    end;
  List.Linea(0, 0, utiles.sFormatoFecha(tabla3.FieldByName('fecha').AsString) + ' ' + tabla3.FieldByName('idcompr').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(17, List.lineactual, tabla3.FieldByName('tipo').AsString + ' ' + tabla3.FieldByName('sucursal').AsString + ' ' + tabla3.FieldByName('numero').AsString + '   ' + tabla3.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
  if tabla3.FieldByName('DC').AsString = '1' then List.importe(70, list.lineactual, '', tabla3.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
  if tabla3.FieldByName('DC').AsString = '2' then List.importe(85, list.lineactual, '', tabla3.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8');
  List.importe(100, list.lineactual, '', saldo, 5, 'Arial, normal, 8');
  List.Linea(101, List.lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
  idant := tabla3.FieldByName('idtitular').AsString;
  clant := tabla3.FieldByName('clavecta').AsString;
end;

procedure TTCtacteSoc.rSubtotales(salida: char);
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

procedure TTCtacteSoc.TitulosResctas(salida: char);
// Objetivo...: Titulos del resumen de cuentas corrientes de Proveedores
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Resumen de Créditos de Socios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(17, List.lineactual, 'Comprobante                   Concepto Operación', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Debe', 3, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'Haber', 4, 'Arial, cursiva, 8');
  List.Titulo(95, List.lineactual, 'Saldo', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTCtacteSoc.rListar(iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de socios con ruptura por cuenta
var
  indice: string;
begin
  indice := tabla3.IndexFieldNames;

  TitulosResctas(salida);

  tabla3.IndexName := 'Listado';

  tabla1.First;
  while not tabla1.EOF do
    begin
      if tabla1.FieldByName('sel').AsString = 'X' then
        begin
           saldo := 0; td := 0; th := 0; idant := ''; clant := '';

           tabla3.First;
           while not tabla3.EOF do
             begin
               if (tabla3.FieldByName('idtitular').AsString = tabla1.FieldByName('idtitular').AsString) and (tabla3.FieldByName('clavecta').AsString = tabla1.FieldByName('clavecta').AsString) then
                 begin
                   if (Length(Trim(tabla3.FieldByName('XN').AsString)) > 0) or (tabla3.FieldByName('tipo').AsString = 'I') then
                     begin
                       if tabla3.FieldByName('DC').AsString = '1' then saldo := saldo + tabla3.FieldByName('importe').AsFloat;
                       if tabla3.FieldByName('DC').AsString = '2' then saldo := saldo - tabla3.FieldByName('importe').AsFloat;
                     end;
                   if (tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then
                     if (Length(Trim(tabla3.FieldByName('XN').AsString)) > 0) or (tabla3.FieldByName('tipo').AsString = 'I') then rList_Linea(salida);
               end;

               tabla3.Next;
             end;

           if td + th <> 0 then rSubtotales(salida);

        end;
      tabla1.Next;
    end;

    List.FinList;

    tabla3.IndexFieldNames := indice;
end;

procedure TTCtacteSoc.rListarRes(iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de socios con ruptura por socio
var
  indice, idant: string;
begin
  indice := tabla3.IndexFieldNames;
  TitulosResctas(salida);
  tabla3.IndexName := 'Listado';
  tabla1.First; idant := ''; clant := '';
  while not tabla1.EOF do
    begin
      if (tabla1.FieldByName('sel').AsString = 'X') and (tabla1.FieldByName('idtitular').AsString <> idant) then
        begin
          saldo := 0; saldoanter := 0; td := 0; th := 0;
          rListarResSocio(tabla1.FieldByName('idtitular').AsString, iniciar, finalizar, salida);
          idant := tabla1.FieldByName('idtitular').AsString;
        end;
      tabla1.Next;
    end;
  List.FinList;
  tabla3.IndexFieldNames := indice;
end;

procedure TTCtacteSoc.rListarResumenSocio(xidtitular, iniciar, finalizar: string; salida: char);
var
  indice: string;
begin
  indice := tabla3.IndexFieldNames;
  TitulosResctas(salida);
  tabla3.IndexName := 'Listado';
  rListarResSocio(xidtitular, iniciar, finalizar, salida);
  list.FinList;
  tabla3.IndexFieldNames := indice;
end;

procedure TTCtacteSoc.rListarResSocio(xidtitular, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de socios con ruptura por socio
begin
   saldo := 0; saldoanter := 0; td := 0; th := 0;

   tabla3.First;
   while not tabla3.EOF do Begin
     if tabla3.FieldByName('idtitular').AsString = xidtitular then Begin
       if (tabla3.FieldByName('DC').AsString = '1') and (tabla3.FieldByName('items').AsString < '001') then saldo := saldo + tabla3.FieldByName('importe').AsFloat;
       if tabla3.FieldByName('DC').AsString = '2' then saldo := saldo - tabla3.FieldByName('importe').AsFloat;
       if (tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then
         if (Length(Trim(tabla3.FieldByName('XN').AsString)) > 0) or (tabla3.FieldByName('tipo').AsString = 'I') then cList_Linea(salida);
     end;

     tabla3.Next;
   end;

   if td + th <> 0 then rSubtotales(salida);
end;

procedure TTCtacteSoc.cList_linea(salida: char);
// Objetivo...: Listar una Línea - ruptura por cliente
var
  pr: string;
begin
  if tabla3.FieldByName('DC').AsString = '1' then td := td + tabla3.FieldByName('importe').AsFloat;
  if tabla3.FieldByName('DC').AsString = '2' then th := th + tabla3.FieldByName('importe').AsFloat;

  if tabla3.FieldByName('idtitular').AsString <> clant then
    begin
      // Subtotal
      if clant <> '' then rSubtotales(salida);

      socioadherente.Buscar(tabla3.FieldByName('idtitular').AsString);
      pr := socioadherente.tperso.FieldByName('nombre').AsString;
      List.Linea(0, 0, 'Cliente: ' + tabla3.FieldByName('idtitular').AsString + '-   ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      List.Linea(0, 0, utiles.espacios(140) + 'Saldo Anterior ....: ', 1, 'Arial, cursiva, 8', salida, 'S');
      if tabla3.FieldByName('DC').AsString = '1' then saldoanter := saldo - tabla3.FieldByName('importe').AsFloat else saldoanter := saldo + tabla3.FieldByName('importe').AsFloat;
      List.importe(100, list.lineactual, '', saldoanter, 2, 'Arial, cursiva, 8');
      List.Linea(101, list.lineactual, ' ', 3, 'Arial, cursiva, 8', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    end;
  List.Linea(0, 0, utiles.sFormatoFecha(tabla3.FieldByName('fecha').AsString) + ' ' + tabla3.FieldByName('idcompr').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(17, List.lineactual, tabla3.FieldByName('tipo').AsString + ' ' + tabla3.FieldByName('sucursal').AsString + ' ' + tabla3.FieldByName('numero').AsString + '   ' + tabla3.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
  if tabla3.FieldByName('DC').AsString = '1' then List.importe(70, list.lineactual, '', tabla3.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
  if tabla3.FieldByName('DC').AsString = '2' then List.importe(85, list.lineactual, '', tabla3.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8');
  List.importe(100, list.lineactual, '', saldo, 5, 'Arial, normal, 8');
  List.Linea(101, List.lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
  clant := tabla3.FieldByName('idtitular').AsString;
end;

procedure TTCtacteSoc.ListTitFichaPagos(salida: char);
// Objetivo...: Listar Cuentas Corrientes de Proveedores Definidas
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Informe Estado de Créditos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(17, List.lineactual, 'Comprobante    Concepto operación', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Monto', 3, 'Arial, cursiva, 8');
  List.Titulo(89, List.lineactual, 'Rec/Int', 4, 'Arial, cursiva, 8');
  List.Titulo(97, List.lineactual, 'Est.', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTCtacteSoc.rListarPlan(iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de Proveedores Definidas
var
  t: string;
begin
  saldo := 0; td := 0; th := 0; totin := 0; idant := ''; clant := ''; total := 0; recar := 0; saldoanter := 0;
  t := tabla3.FieldByName('DC').AsString;

  while not tabla3.EOF do Begin
    if (tabla3.FieldByName('idtitular').AsString = tabla1.FieldByName('idtitular').AsString) and (tabla3.FieldByName('clavecta').AsString = tabla1.FieldByName('clavecta').AsString) then Begin
      if tabla3.FieldByName('DC').AsString <> t then Begin
        rSubtotales1(salida, t);
        List.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
        total := 0;
      end;
      if tabla3.FieldByName('DC').AsString = '1' then iss := False else iss := True;
      if (tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then
        if ((tabla3.FieldByName('items').AsString > '000') or (tabla3.FieldByName('items').AsString = '000')) or (tabla3.FieldByName('tipo').AsString = 'I') then List_LineaPlan(salida);
          if ((tabla3.FieldByName('items').AsString > '000') or (tabla3.FieldByName('items').AsString = '000')) or (tabla3.FieldByName('estado').AsString = 'R') then Begin  // Saldos y Totales
            if tabla3.FieldByName('DC').AsString = '1' then td := td + tabla3.FieldByName('importe').AsFloat;
            if tabla3.FieldByName('DC').AsString = '2' then th := th + tabla3.FieldByName('importe').AsFloat;
            total := total + tabla3.FieldByName('importe').AsFloat;
            recar := recar + tabla3.FieldByName('recargo').AsFloat;
            if tabla3.FieldByName('DC').AsString = '1' then totin := totin + tabla3.FieldByName('interes').AsFloat;
          end;

      saldoanter := td - th;
      t := tabla3.FieldByName('DC').AsString;
      end;

    tabla3.Next;
  end;

  if (td + th) <> 0 then
    if t = '1' then Begin
      rSubtotales1(salida, '1');
      iss := True;
      rSubtotales1(salida, '2');
     end
    else
     rSubtotales1(salida, '2');
end;

procedure TTCtacteSoc.List_LineaPlan(salida: char);
// Objetivo...: Listar una Línea
var
  pr    : string;
  recint: real;
begin
  if tabla3.FieldByName('DC').AsString = '1' then recint := tabla3.FieldByName('interes').AsFloat else recint := tabla3.FieldByName('recargo').AsFloat;
  if (tabla3.FieldByName('idtitular').AsString <> idant) or (tabla3.FieldByName('clavecta').AsString <> clant) then
    begin
      existenMov := True;
      // Subtotal
      if idant <> '' then rSubtotales(salida);
      socioadherente.Buscar(tabla3.FieldByName('idtitular').AsString);
      pr := socioadherente.tperso.FieldByName('nombre').AsString;
      List.Linea(0, 0, 'Cuenta: ' + tabla3.FieldByName('idtitular').AsString + '-' + tabla3.FieldByName('clavecta').AsString + '    ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      List.Linea(0, 0, utiles.espacios(140) + 'Saldo Anterior ....: ', 1, 'Arial, cursiva, 8', salida, 'S');
      List.importe(95, list.lineactual, '', saldoanter, 2, 'Arial, cursiva, 8');
      List.Linea(98, list.lineactual, ' ', 3, 'Arial, cursiva, 8', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    end;
    List.Linea(0, 0, utiles.sFormatoFecha(tabla3.FieldByName('fecha').AsString) + ' ' + tabla3.FieldByName('idcompr').AsString, 1, 'Arial, normal, 8', salida, 'N');
    List.Linea(17, List.lineactual, tabla3.FieldByName('tipo').AsString + ' ' + tabla3.FieldByName('sucursal').AsString + ' ' + tabla3.FieldByName('numero').AsString + '   ' + tabla3.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
    List.importe(70, list.lineactual, '', tabla3.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
    List.importe(95, list.lineactual, '', recint, 4, 'Arial, normal, 8');
    if tabla3.FieldByName('DC').AsString = '1' then List.Linea(98, List.lineactual, tabla3.FieldByName('estado').AsString, 5, 'Arial, normal, 7', salida, 'S') else List.Linea(98, List.lineactual, ' ', 5, 'Arial, normal, 8', salida, 'S');
    idant := tabla3.FieldByName('idtitular').AsString;
    clant := tabla3.FieldByName('clavecta').AsString;
end;

procedure TTCtacteSoc.ListarPlanPagos(iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Ficha de Cuentas Corrientes Seleccionadas
var
  ind: string;
begin
  ind := tabla3.IndexFieldNames;
  ListTitFichaPagos(salida);
  tabla1.First; existenMov := False;
  while not tabla1.EOF do Begin
    if tabla1.FieldByName('sel').AsString = 'X' then Begin
      tabla3.IndexName := 'Idcta';
      datosdb.Buscar(tabla3, 'idtitular', 'clavecta', tabla1.FieldByName('idtitular').AsString, tabla1.FieldByName('clavecta').AsString);
      tabla3.IndexName := 'Listplan';
      rListarPlan(iniciar, finalizar, salida);
    end;
    tabla1.Next;
  end;
  if not existenMov then utiles.msgError('Cuentas sin Operaciones ...!') else List.FinList;
  tabla3.IndexFieldNames := ind;
end;

procedure TTCtacteSoc.ListarFichaPlanPagos(xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero, xinicio, xfin: string; salida: char);
// Objetivo...: Listar Ficha con el Formato de la cuenta corriente - como para registrar los pagos
var
  indice: string;
begin
  // Buscamos la Ficha correspondiente
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, '-1') then Begin
    indice := tabla3.IndexFieldNames;
    list.Setear(salida);
    ListTitFichaPagos(salida);
    tabla3.IndexName := 'ListPlan';
    rListarPlan(xinicio, xfin, salida);
    tabla3.IndexFieldNames := indice;
   end
  else
   if not existenMov then utiles.msgError('Cuentas sin Operaciones ...!') else List.FinList;
end;

procedure TTCtacteSoc.tot_deuda(salida: char);
// Objetivo...: subtotalizar una deuda para un cliente
begin
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
  List.derecha(90, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total Deuda .....: ', 1, 'Arial, negrita, 8', salida, 'S');
  List.importe(90, list.lineactual, '', total, 2, 'Arial, negrita, 8');
  List.Linea(95, List.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  total := 0;
end;

procedure TTCtacteSoc.rSubtotales1(salida: char; t: string);
// Objetivo...: Emitir Subtotales
var
  l: string;
begin
  if t = '1' then l := 'Total de cuotas ......:' else l := 'Total Pagado .....:';
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
  List.derecha(70, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.derecha(95, list.lineactual, '', '--------------', 3, 'Arial, normal, 8');
  List.Linea(101, list.lineactual, ' ', 5, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, l, 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(70, list.lineactual, '', total, 2, 'Arial, normal, 8');
  if t = '1' then List.importe(95, list.lineactual, '', totin, 3, 'Arial, normal, 8') else List.importe(95, list.lineactual, '', recar, 3, 'Arial, normal, 8');
  if iss then
    begin
      List.Linea(0, 0, 'Saldo Actual ......:', 1, 'Arial, negrita, 8', salida, 'N');
      List.importe(30, list.lineactual, '', td + totin - th, 2, 'Arial, negrita, 8');
    end;
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
end;

procedure TTCtacteSoc.ListarVencimientos(fecha: string; salida: char);
// Objetivo...: Listar los vencimientos de Cuentas Corrientes
var
  pr, clant: string;
begin
  TSQL := setVencimientos(fecha);

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Venciemientos de Cuotas de Créditos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Vencimientos al ' + fecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, List.lineactual, 'Cuenta    Titular', 2, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Domicilio', 3, 'Arial, cursiva, 8');
  List.Titulo(85, List.lineactual, 'Monto', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  recar := 0; total := 0;

  TSQL.Open;
  tabla1.First;
  while not tabla1.EOF do
    begin
      if tabla1.FieldByName('sel').AsString = 'X' then
        begin
          TSQL.First;
          clant := tabla1.FieldByName('idtitular').AsString; //TSQL.FieldByName('idtitular').AsString;
          while not TSQL.EOF do
            begin
              if tabla1.FieldByName('idtitular').AsString = TSQL.FieldByName('idtitular').AsString then
                begin
                  socioadherente.getDatos(TSQL.FieldByName('idtitular').AsString);
                  pr := socioadherente.Nombre;

                  if TSQL.FieldByName('idtitular').AsString <> clant then tot_deuda(salida);

                  if TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat <> 0 then
                    begin
                      List.Linea(0, 0, utiles.sFormatoFecha(TSQL.FieldByName('fecha').AsString) + '  ' + TSQL.FieldByName('idtitular').AsString + '-' + TSQL.FieldByName('clavecta').AsString + '  ' + pr, 1, 'Arial, normal, 8', salida, 'N');
                      List.Linea(40, list.lineactual, socioadherente.Domicilio, 2, 'Arial, normal, 8', salida, 'N');
                      List.importe(90, list.lineactual, '', (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat), 3, 'Arial, normal, 8');
                      List.Linea(95, List.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
                      recar := recar + (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat);
                      total := total + (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat);
                    end;

                  clant := TSQL.FieldByName('idtitular').AsString;
                end;
              TSQL.Next;
            end;
        end;
      tabla1.Next;
    end;

    tot_deuda(salida);

    // Listamos un total general de deudas
    List.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
    List.Linea(0, 0, 'Monto total de vencimientos .....:    ' +  utiles.FormatearNumero(FloatToStr(recar)), 1, 'Arial, normal, 10', salida, 'S');

    List.FinList;
end;

procedure TTCtacteSoc.ObtenerSaldo(xidtitular, xclavecta: string);
// Objetivo...: Calcular el saldo para una cuenta dada
begin
  td := 0; th := 0;
  TSQL.Open; TSQL.First;
  while not TSQL.EOF do
    begin
      if (TSQL.FieldByName('idtitular').AsString = xidtitular) and (TSQL.FieldByName('clavecta').AsString = xclavecta) then
        begin
          if (TSQL.FieldByName('items').AsString <= '000') or (TSQL.FieldByName('tipo').AsString = 'I') then td := td + TSQL.FieldByName('importe').AsFloat;
          if TSQL.FieldByName('DC').AsString = '2' then th := th + TSQL.FieldByName('importe').AsFloat;
        end;
      TSQL.Next;
    end;
end;

procedure TTCtacteSoc.ListPlanillaSaldos(fecha: string; salida: char);
// Objetivo...: Listar saldos individuales por cuenta
var
  r: TQuery;
begin
  TSQL := datosdb.tranSQL('SELECT ctactecl.tipo, ctactecl.fecha, ctactecl.idtitular, ctactecl.clavecta, ctactecl.DC, ctactecl.Items, ctactecl.importe FROM ctactecl WHERE fecha <= ' + '''' + utiles.sExprFecha(fecha) + '''');
  //r    := setCtasCtesSel;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Planilla de Saldos de socios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Saldos al ' + fecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cuenta     Titular', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(83, List.lineactual, 'Saldo', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  total := 0;
  r.Open; r.First;
  while not r.EOF do
    begin
      ObtenerSaldo(r.FieldByName('idtitular').AsString, r.FieldByName('clavecta').AsString);
      socioadherente.getDatos(r.FieldByName('idtitular').AsString);
      List.Linea(0, 0, r.FieldByName('idtitular').AsString + '  ' + r.FieldByName('clavecta').AsString + '  ' + socioadherente.nombre, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(40, list.lineactual, socioadherente.domicilio, 2, 'Arial, normal, 8', salida, 'N');
      List.importe(90, list.lineactual, '', td - th, 3, 'Arial, normal, 8');
      List.Linea(90, List.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + (td - th);
      r.Next;
    end;

    TSQL.Close;
    r.Close; r.Free;

    list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
    list.derecha(90, list.lineactual, '##############', '--------------', 2, 'Arial, normal, 8');
    list.Linea(0, 0, 'Total ........: ', 1, 'Arial, normal, 8', salida, 'N');
    list.importe(90, list.lineactual, '', total, 2, 'Arial, normal, 8');
    list.Linea(92, list.lineactual, '  ', 3, 'Arial, normal, 8', salida, 'S');

    List.FinList;
end;

procedure TTCtacteSoc.CalcularCapital(xcodsocio, xfecha: string);
begin
  td := 0; th := 0; totrecargos := 0; intproy := 0;  // td - Capital Prestado / th - Intereses / intproy - Intereses Proyectados
  tabla3.First;
  while not tabla3.EOF do
    begin
      if tabla3.FieldByName('codsocio').AsString = xcodsocio then
        begin
          if tabla3.FieldByName('items').AsString > '000' then
            if tabla3.FieldByName('DC').AsString = '1' then td := td + tabla3.FieldByName('importe').AsFloat else
              if tabla3.FieldByName('DC').AsString = '2' then td := td - (tabla3.FieldByName('importe').AsFloat - tabla3.FieldByName('interes').AsFloat);
          if (tabla3.FieldByName('items').AsString > '000') and (tabla3.FieldByName('DC').AsString = '2') then th := th + tabla3.FieldByName('interes').AsFloat;
          if (tabla3.FieldByName('items').AsString > '000') and (tabla3.FieldByName('DC').AsString = '2') then totrecargos := totrecargos + tabla3.FieldByName('recargo').AsFloat;
          if Length(Trim(xfecha)) = 8 then
            if (tabla3.FieldByName('items').AsString > '000') and (tabla3.FieldByName('DC').AsString = '1') and (tabla3.FieldByName('estado').AsString = 'I') and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(xfecha)) then intproy := intproy + tabla3.FieldByName('interes').AsFloat;
        end;
      tabla3.Next;
    end;
end;

function TTCtacteSoc.getCreditosaCobrar: real;
// Objetivo...: Devuelve el capital prestado
begin
  Result := td;
end;

function TTCtacteSoc.getInteresesCobrar: real;
// Objetivo...: devuelve el capital a cobrar
begin
  Result := th;
end;

function TTCtacteSoc.getTotRecargos: real;
// Objetivo...: devuelve los recargos por cuotas atrasadas
begin
  Result := totrecargos;
end;

function TTCtacteSoc.getInteresesProyectados: real;
// Objetivo...: devuelve los intereses proyectados
begin
  Result := intproy;
end;

function TTCtacteSoc.getMcctcl: TQuery;
// Objetivo...: Devolver un set con los registros registrados
begin
  Result := datosdb.tranSQL('SELECT ctactecl.idcompr AS IDC, ctactecl.tipo AS Tipo, ctactecl.sucursal AS Sucur, ctactecl.numero AS Numero, ctactecl.idtitular AS Cod, ctactecl.clavecta AS Cta, socios.nombre, ctactecl.concepto AS Concepto, ctactecl.importe AS Importe, ctactecl.fecha ' +
               'FROM ctactecl, socios WHERE ctactecl.idtitular = socios.codsocio AND ctactecl.items = ' + '''' + '-1' + '''' + ' ORDER BY ctactecl.fecha');
end;

function TTCtacteSoc.getMcctcl(xt, xc: string): TQuery;
// Objetivo...: Devolver un set con los registros registrados
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.idcompr AS IDC, ctactecl.tipo AS Tipo, ctactecl.sucursal, ctactecl.numero AS Numero, ctactecl.DC, ctactecl.idtitular AS Cod, ctactecl.clavecta AS Cta, socios.nombre, ctactecl.concepto AS Concepto, ' +
               'ctactecl.importe AS Importe, ctactecl.interes ' +
               'FROM ctactecl, socios WHERE ctactecl.idtitular = socios.codsocio ' + //AND ctactecl.items = ' + '''' + '-1' + '''' +
               ' AND ctactecl.idtitular = ' + '''' + xt + '''' + ' AND ctactecl.clavecta = ' + '''' + xc + '''' +
               ' ORDER BY ctactecl.fecha');
end;

function TTCtacteSoc.EstsqlSaldosCobrar(fecha1, fecha2: string): TQuery;
// Objetivo...: Generar Transacción SQL para determinar Saldos a Cobrar de c/c
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, socios.nombre, ctactecl.importe, ctactecl.entrega '
           +'FROM ctactecl, socios WHERE ctactecl.idtitular = socios.codsocio AND ctactecl.fecha >= ' + '''' + fecha1 + '''' + ' AND ctactecl.fecha <= ' + '''' + fecha2 + ''''
           +' AND ctactecl.items > ' + '''' + '000' + '''' + ' AND ctactecl.estado = ' + '''' + 'I' + '''');
end;

function TTCtacteSoc.EstsqlCobrosEfectuados(fecha1, fecha2: string): TQuery;
// Objetivo...: Generar Transacción SQL para determinar Cobros Efectuados de c/c
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, socios.nombre, ctactecl.importe '
           +'FROM ctactecl, socios WHERE ctactecl.idtitular = socios.codsocio AND ctactecl.fecha >= ' + '''' + fecha1 + '''' + ' AND ctactecl.fecha <= ' + '''' + fecha2 + '''' + ' AND dc = ' + '''' + '2' + '''');
end;

function TTCtacteSoc.EstsqlCuotasVencidas(fecha1, fecha2: string): TQuery;
// Objetivo...: Generar Transacción SQL para determinar Cobros Efectuados de c/c
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, socios.nombre, ctactecl.importe, ctactecl.entrega '
                          + 'FROM ctactecl, socios WHERE ctactecl.idtitular = socios.codsocio AND ctactecl.fecha < ' + '''' + fecha1 + ''''
                          + ' AND estado = ' + '''' + 'I' + '''' + ' AND dc = ' + '''' + '1' + '''' + ' AND items >= ' + '''' + '000' + '''');
end;

function TTCtacteSoc.AuditoriaFacturasEmitidas(fecha: string): TQuery;  // SQL Auditoría
// Objetivo...: Generar TransacSQL para auditoría de facturas emitidas
begin
  Result := datosdb.tranSQL('SELECT ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, socios.nombre, ctactecl.importe '
                            +'FROM ctactecl, socios WHERE ctactecl.idtitular = socios.codsocio AND ctactecl.fecha = ' + '''' + fecha + '''' + ' AND items = ' + '''' + '-1' + '''');
end;

function TTCtacteSoc.AuditoriaRecaudacionesCobros(fecha: string): TQuery;
// Objetivo...: Generar TransacSQL para auditoría de cobros efectuados
begin
  Result := datosdb.tranSQL('SELECT ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, socios.nombre, ctactecl.importe '
                           +'FROM ctactecl, socios WHERE ctactecl.idtitular = socios.codsocio AND ctactecl.fecha = ' + '''' + fecha + '''' + ' AND dc = ' + '''' + '2' + '''');
end;

procedure TTCtacteSoc.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    socioadherente.conectar;
    if not tabla1.Active then
      begin
        tabla1.Open;
        tabla1.FieldByName('fealta').Visible := False; tabla1.FieldByName('clave').Visible := False; tabla1.FieldByName('sel').Visible := False; tabla1.FieldByName('obs').Visible := False;
        tabla1.FieldByName('idtitular').DisplayLabel := 'Titular'; tabla1.FieldByName('clavecta').DisplayLabel := 'Cta.'; tabla1.FieldByName('obs').DisplayLabel := 'Observaciones';
      end;
    if not tabla3.Active then
      begin
        tabla3.Open;
        tabla3.FieldByName('periodo').Visible := False; tabla3.FieldByName('idtitular').Visible := False; tabla3.FieldByName('clavecta').Visible := False;
      end;
    if not tabla2.Active then tabla2.Open;
  end;
  Inc(conexiones);
end;

procedure TTCtacteSoc.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    socioadherente.desconectar;
    datosdb.closeDB(tabla1);
    datosdb.closeDB(tabla2);
    datosdb.closeDB(tabla3);
  end;
end;

{===============================================================================}

function ccsoc: TTCtacteSoc;
begin
  if xctactecl = nil then
    xctactecl := TTCtacteSoc.Create('', '', '', '', '', '', '', '', '', '', '', '', '', 0);
  Result := xctactecl;
end;

{===============================================================================}

initialization

finalization
  xctactecl.Free;

end.
