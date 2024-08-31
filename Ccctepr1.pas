unit Ccctepr1;

interface

uses SysUtils, DB, DBTables, CBDT, CCtactes, CProve, CListar, CUtiles, CIDBFM;

type

TTCtactepr1 = class(TTCtacte)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    VerifProveedor(xcodprov: string): boolean;
  function    getProveedor(xcodprov: string): string;
  function    getDireccion(xcodcli: string): string;

  procedure   GrabarTran(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto: string; ximporte, xentrega, xcuota: real);
  procedure   GrabarPago(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto: string; ximporte, xentrega, xcuota, xrecargo: real; ftc, fti, fsu, fnu, fit: string);
  procedure   GrabarFact(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm: string; ximporte, xentrega: real);
  procedure   MarcarCuotaPaga(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string; ximporte, xcuota: real);
  procedure   BorrarPago(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string);
  procedure   BorrarComprobante(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
  function    getPagos(xclavecta, xidtitular: string): TQuery;
  function    getRecibos(xclavecta, xidtitular: string): TQuery;
  function    setFact: TQuery;
  procedure   getDatosFactura(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
  function    RecalcularEntregas(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string): real;
  procedure   Depurar(fecha: string);
  function    getFactventa(xidc, xtipo, xsucursal, xnumero, xidtitular: string): TQuery;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   rListar(iniciar, finalizar: string; salida: char);
  procedure   rListarPlan(iniciar, finalizar: string; salida: char);
  procedure   ListarResumenCuenta(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
  procedure   rSubtotales(salida: char);
  procedure   rSubtotales1(salida: char; t: string);
  procedure   ObtenerSaldo(xidtitular, xclavecta: string);
  procedure   ListarVencimientos(fecha: string; salida: char);
  procedure   ListPlanillaSaldos(fecha: string; salida: char);
  procedure   rListarRes(iniciar, finalizar: string; salida: char);
  procedure   ListarResumenProveedor(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
  function    getMcctcl: TQuery; overload;
  function    getMcctcl(xt, xc: string): TQuery; overload;
  function    EstsqlSaldosCobrar(fecha1, fecha2: string): TQuery;         // SQL Estadísticas
  function    EstsqlCobrosEfectuados(fecha1, fecha2: string): TQuery;
  function    EstsqlCuotasVencidas(fecha1, fecha2: string): TQuery;
  function    AuditoriaFacturasEmitidas(fecha: string): TQuery;  // SQL Auditoría
  function    AuditoriaRecaudacionesCobros(fecha: string): TQuery;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  importe_cuota: real; t: TQuery;
  procedure   tot_deuda(salida: char);
  procedure   List_linea(salida: char);
  procedure   cList_linea(salida: char);
  procedure   rList_Linea(salida: char);
  procedure   List_LineaPlan(salida: char);
  procedure   TitulosResctas(salida: char);
  procedure   BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
  procedure   ListResumen(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
  procedure   ListResumenCuenta(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
end;

function ccpr1: TTCtactepr1;

implementation

var
  xccpr1: TTCtactepr1 = nil;

constructor TTCtactepr1.Create;
begin
  inherited Create;

  tabla1 := datosdb.openDB('cctpr', 'Idtitular;Clavecta');
  tabla2 := datosdb.openDB('ctactecp', 'Idcompr;Tipo;Sucursal;Numero;Idtitular');
  tabla3 := datosdb.openDB('ctactepr', 'Idtitular;Clavecta;Idcompr;Tipo;Sucursal;Numero;Items');
end;

destructor TTCtactepr1.Destroy;
begin
  desconectar;
  inherited Destroy;
end;

//------------------------------------------------------------------------------

function TTCtactepr1.VerifProveedor(xcodprov: string): boolean;
// Objetivo...: Verificamos que el proveedor ingresado Exista
begin
  if proveedor.Buscar(xcodprov) then Result := True else Result := False;
end;

function TTCtactepr1.getProveedor(xcodprov: string): string;
// Objetivo...: Recuperamos el Cliente titular de la Cuenta
begin
  proveedor.getDatos(xcodprov);
  Result := proveedor.Nombre;
end;

function TTCtactepr1.getDireccion(xcodcli: string): string;
// Objetivo...: Recuperamos la Direccion
begin
  proveedor.getDatos(xcodcli);
  Result := proveedor.Domicilio;
end;

function TTCtactepr1.getFactventa(xidc, xtipo, xsucursal, xnumero, xidtitular: string): TQuery;
// Objetivo...: Buscar un comprobante Registrado con el Id de Ventas
begin
  if datosdb.Buscar(tabla2, 'idcompr', 'tipo', 'sucursal', 'numero', 'idtitular', xidc, xtipo, xsucursal, xnumero, xidtitular) then
    begin
      TransferirDatos(True);
      // Atributos NO Heredados o  Sobrecargados
      clavecta  := tabla2.FieldByName('clavecta').AsString;
      idtitular := tabla2.FieldByName('idtitular').AsString;
      fecha     := utiles.sFormatoFecha(tabla2.FieldByName('fecha').AsString);
      importe   := tabla2.FieldByName('importe').AsFloat;
      entrega   := tabla2.FieldByName('entrega').AsFloat;
      // Filtramos el Plan
      Result  := getPlan(clavecta, idtitular, xidc, xtipo, xsucursal, xnumero);
    end
  else
    begin
      TransferirDatos(False);
      Result := nil;
    end;
end;

procedure TTCtactepr1.GrabarTran(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto: string; ximporte, xentrega, xcuota: real);
// Objetivo...: Grabar los movimientos Generados a partir de los planes, cobros/o pagos efectuados
begin
  if xitems = '-1' then GrabarFact(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm, ximporte, xentrega);
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then
    begin
      if xitems = '000' then tabla3.Edit;
      if xitems = '-1' then  // Si existia ya el plan cargado lo anulamos
        begin
          BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero);
          tabla3.Append;
        end
    end
      else
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
   if xitems = '0' then
     begin
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

procedure TTCtactepr1.BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
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

procedure TTCtactepr1.BorrarComprobante(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
// Objetivo...: Eliminar un comprobante - detalle y relaciones
begin
  try
    datosdb.tranSQL('DELETE FROM ctactecp WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''' +
                    ' AND idcompr = ' + '''' + xidc + '''' + ' AND tipo = ' + '''' + xtipo + '''' + ' AND sucursal = ' + '''' + xsucursal + '''' + ' AND numero = ' + '''' + xnumero + '''');
    BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero);
    // Actualizamos los atributos
    getDatos(tabla2.FieldByName('clavecta').AsString, tabla2.FieldByName('idtitular').AsString, tabla2.FieldByName('idcompr').AsString, tabla2.FieldByName('tipo').AsString, tabla2.FieldByName('sucursal').AsString, tabla2.FieldByName('numero').AsString, tabla2.FieldByName('DC').AsString);
   except
   end;
end;

procedure TTCtactepr1.GrabarPago(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto: string; ximporte, xentrega, xcuota, xrecargo: real; ftc, fti, fsu, fnu, fit: string);
// Objetivo...: Grabar los movimientos Generados a partir de los planes, cobros/o pagos efectuados
begin
  tabla3.Filtered := False;
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
  tabla3.Filtered := True;
end;

procedure TTCtactepr1.MarcarCuotaPaga(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string; ximporte, xcuota: real);
// Objetivo...: Marcar una cuota como paga
begin
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then
   begin
     importe_cuota := ximporte;
     tabla3.Edit;
     importe_cuota := RecalcularEntregas(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems); // Determino si el pago fue total o parcial
     if importe_cuota = tabla3.FieldByName('importe').AsFloat then tabla3.FieldByName('estado').AsString := 'P' else tabla3.FieldByName('estado').AsString := 'I';
     tabla3.FieldByName('entrega').AsFloat := importe_cuota;
     try
       tabla3.Post; tabla3.Refresh;
     except
       tabla3.Cancel;
     end;
   end;
end;

function TTCtactepr1.RecalcularEntregas(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string): real;
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

procedure TTCtactepr1.BorrarPago(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string);
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

procedure TTCtactepr1.GrabarFact(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm: string; ximporte, xentrega: real);
// Objetivo...: Grabar una Factura
begin
  if datosdb.Buscar(tabla2, 'idcompr', 'tipo', 'sucursal', 'numero', 'idtitular', xidc, xtipo, xsucursal, xnumero, xidtitular) then tabla2.Edit else tabla2.Append;
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
    tabla2.Post; tabla2.Refresh
  except
    tabla2.Cancel;
  end;
end;

function TTCtactepr1.getPagos(xclavecta, xidtitular: string): TQuery;
// Objetivo...: Devolver un Set de las Cuentas Corrientes Disponibles para un titular
begin
  Result := datosdb.tranSQL('SELECT * FROM ctactepr WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''' + ' ORDER BY fecha, items');
end;

function TTCtactepr1.getRecibos(xclavecta, xidtitular: string): TQuery;
// Objetivo...: Devolver un Set de los Recibos Ingresados
begin
  Result := datosdb.tranSQL('SELECT * FROM ctactepr WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''' + ' AND estado = ' + '''' + 'R' + '''' + ' ORDER BY fecha, items');
end;

procedure TTCtactepr1.Depurar(fecha: string);
// Objetivo...: depurar los movimientos de cuenta corriente
var
  r: TQuery;
  xco, xti, xsu, xnu, xtt, xcl: string;
begin
  // Aislamos los comprobantes cancelados
  r := datosdb.tranSQL('SELECT * FROM ctactepr WHERE estado = ' + '''' + 'P' + '''' + ' AND fecha < ' + '''' + utiles.sExprFecha(fecha) + '''');
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
      datosdb.tranSQL('DELETE FROM ctactepr WHERE XC = ' + '''' + xco + '''' + ' AND XT = ' + '''' + xti + '''' + ' AND XS = ' + '''' + xsu + '''' + ' AND XN = ' + '''' + xnu + '''' + ' AND idtitular = ' + '''' + xtt + '''' + ' AND clavecta = ' + '''' + xcl + '''' + ' AND DC = ' + '''' + '2' + '''');
      // Eliminamos Factura
      datosdb.tranSQL('DELETE FROM ctactepr WHERE idcompr = ' + '''' + xco + '''' + ' AND tipo = ' + '''' + xti + '''' + ' AND sucursal = ' + '''' + xsu + '''' + ' AND numero = ' + '''' + xnu + '''' + ' AND idtitular = ' + '''' + xtt + '''' + ' AND clavecta = ' + '''' + xcl + '''' + ' AND DC = ' + '''' + '1' + '''');
      // Eliminamos los saldos iniciales Pagados
      datosdb.tranSQL('DELETE FROM ctactepr WHERE idtitular = ' + '''' + xtt + '''' + ' AND clavecta = ' + '''' + xcl + '''' + ' AND estado = ' + '''' + 'P' + '''' + ' AND idcompr = ' + '''' + 'SIN' + '''');
       // Eliminamos las Facturas canceladas
      datosdb.tranSQL('DELETE FROM ctactecf WHERE idcompr = ' + '''' + xco + '''' + ' AND tipo = ' + '''' + xti + '''' + ' AND sucursal = ' + '''' + xsu + '''' + ' AND numero = ' + '''' + xnu + '''' + ' AND idtitular = ' + '''' + xtt + '''' + ' AND clavecta = ' + '''' + xcl + '''' + ' AND DC = ' + '''' + '1' + '''');

      r.Next;
  end;

  r.Close; r.Free;
end;

procedure TTCtactepr1.getDatosFactura(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
begin
  inherited getMovimiento(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, '-1');
end;

procedure TTCtactepr1.List_linea(salida: char);
// Objetivo...: Listar una Línea
var
  pr: string;
begin
  proveedor.getDatos(tabla1.FieldByName('idtitular').AsString);
  if tabla1.FieldByName('idtitular').AsString <> idant then pr := proveedor.Nombre else pr := ' ';
  List.Linea(0, 0, tabla1.FieldByName('idtitular').AsString + ' ' + tabla1.FieldByName('clavecta').AsString + '    ' + pr, 1, 'Courier New, normal, 8', salida, 'N');
  List.Linea(57, List.lineactual, tabla1.FieldByName('obs').AsString, 2, 'Courier New, normal, 8', salida, 'N');
  List.Linea(90, List.lineactual, utiles.sFormatoFecha(tabla1.FieldByName('fealta').AsString), 3, 'Courier New, normal, 8', salida, 'S');
  idant := tabla1.FieldByName('idtitular').AsString;
end;

procedure TTCtactepr1.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de proveedores Definidas
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Listado de Cuentas Corrientes de proveedors', 1, 'Arial, negrita, 14');
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

procedure TTCtactepr1.rList_linea(salida: char);
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

      proveedor.getDatos(tabla3.FieldByName('idtitular').AsString);
      pr := proveedor.Nombre;
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

procedure TTCtactepr1.rSubtotales(salida: char);
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

procedure TTCtactepr1.rSubtotales1(salida: char; t: string);
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

procedure TTCtactepr1.TitulosResctas(salida: char);
// Objetivo...: Titulos del resumen de cuentas corrientes de Proveedores
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Resumen de Cuentas Corrientes de Proveedores', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(17, List.lineactual, 'Comprobante                   Concepto Operación', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Debe', 3, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'Haber', 4, 'Arial, cursiva, 8');
  List.Titulo(95, List.lineactual, 'Saldo', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTCtactepr1.rListar(iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de proveedors con ruptura por cuenta
var
  indice: string; existemov: boolean;
begin
  indice := tabla3.IndexFieldNames;
  TitulosResctas(salida);

  t := TQuery.Create(nil);
  t.Open; t.First; existemov := False;

  while not t.EOF do Begin
    tabla3.IndexName := 'idcta';
    datosdb.Buscar(tabla3, 'idtitular', 'clavecta', t.FieldByName('idtitular').AsString, t.FieldByName('xclavecta').AsString);
    tabla3.IndexName := 'Listado';
    ListResumenCuenta(t.FieldByName('idtitular').AsString, t.FieldByName('xclavecta').AsString, iniciar, finalizar, salida);
    existemov := True;
    t.Next;
  end;
  t.Close; t.Free;

  if existemov then list.FinList else utiles.msgError('No existen datos para listar ...!');
  tabla3.IndexFieldNames := indice;
end;

procedure TTCtactepr1.ListarResumenCuenta(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar una cuenta especifica
var
  indice: string;
begin
  indice := tabla3.IndexFieldNames;
  TitulosResctas(salida);
  tabla1.First; idant := ''; clant := '';
  tabla3.IndexName := 'Idcta';
  datosdb.Buscar(tabla3, 'idtitular', 'clavecta', xidtitular, xclavecta);
  tabla3.IndexName := 'Listado';
  ListResumenCuenta(xidtitular, xclavecta, iniciar, finalizar, salida);
  List.FinList;
  tabla3.IndexFieldNames := indice;
end;

procedure TTCtactepr1.ListResumenCuenta(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de proveedors con ruptura por cuenta
begin
  while not tabla3.EOF do Begin
    if (tabla3.FieldByName('idtitular').AsString = xidtitular) and (tabla3.FieldByName('clavecta').AsString = xclavecta) then Begin
      if (Length(Trim(tabla3.FieldByName('XN').AsString)) > 0) or (tabla3.FieldByName('tipo').AsString = 'I') or (Length(Trim(tabla3.FieldByName('items').AsString)) = 0) then Begin
        if tabla3.FieldByName('DC').AsString = '1' then saldo := saldo + tabla3.FieldByName('importe').AsFloat;
        if tabla3.FieldByName('DC').AsString = '2' then saldo := saldo - tabla3.FieldByName('importe').AsFloat;
      end;
      if (tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then
        if (tabla3.FieldByName('items').AsString = '-1') or (tabla3.FieldByName('DC').AsString = '2') then rList_Linea(salida);
    end;
    tabla3.Next;
  end;

  if td + th <> 0 then rSubtotales(salida);
end;

procedure TTCtactepr1.rListarRes(iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de proveedors con ruptura por proveedor
var
  indice: string;
  existemov: boolean;
begin
  t := TQuery.Create(nil);
  t.Open; t.First;

  indice := tabla3.IndexFieldNames;
  TitulosResctas(salida);
  tabla1.First; idant := ''; clant := ''; existemov := False;
  while not t.EOF do Begin
    tabla3.IndexName := 'Idcta';
    datosdb.Buscar(tabla3, 'idtitular', 'clavecta', t.FieldByName('idtitular').AsString, t.FieldByName('clavecta').AsString);
    tabla3.IndexName := 'Listado';
    ListResumen(t.FieldByName('idtitular').AsString, t.FieldByName('clavecta').AsString, iniciar, finalizar, salida);
    existemov := True;
    t.Next;
  end;
  t.Close; t.Free;

  if existemov then List.FinList else utiles.msgError('No existen movimientos para listar');
  tabla3.IndexFieldNames := indice;
end;

procedure TTCtactepr1.ListarResumenProveedor(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar una cuenta especifica
var
  indice: string;
begin
  indice := tabla3.IndexFieldNames;
  TitulosResctas(salida);
  tabla1.First; idant := ''; clant := '';
  tabla3.IndexName := 'Idcta';
  datosdb.Buscar(tabla3, 'idtitular', 'clavecta', xidtitular, xclavecta);
  tabla3.IndexName := 'Listado';
  ListResumen(xidtitular, xclavecta, iniciar, finalizar, salida);
  List.FinList;
  tabla3.IndexFieldNames := indice;
end;

procedure TTCtactepr1.ListResumen(xidtitular, xclavecta, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de proveedors con ruptura por proveedor
begin
  saldo := 0; saldoanter := 0; td := 0; th := 0;
  while not tabla3.EOF do Begin
    if (tabla3.FieldByName('idtitular').AsString = tabla1.FieldByName('idtitular').AsString) then Begin
      if (tabla3.FieldByName('DC').AsString = '1') and (tabla3.FieldByName('items').AsString < '001') then saldo := saldo + tabla3.FieldByName('importe').AsFloat;
      if tabla3.FieldByName('DC').AsString = '2' then saldo := saldo - tabla3.FieldByName('importe').AsFloat;
      if (tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then
      if (Length(Trim(tabla3.FieldByName('XN').AsString)) > 0) or (tabla3.FieldByName('tipo').AsString = 'I') or (Length(Trim(tabla3.FieldByName('items').AsString)) = 0) then cList_Linea(salida);
    end;
    tabla3.Next;
    if (tabla3.FieldByName('idtitular').AsString <> tabla1.FieldByName('idtitular').AsString) then Break;
  end;

  if td + th <> 0 then rSubtotales(salida);

  idant := tabla1.FieldByName('idtitular').AsString;
end;

procedure TTCtactepr1.cList_linea(salida: char);
// Objetivo...: Listar una Línea - ruptura por proveedor
var
  pr: string;
begin
  if tabla3.FieldByName('DC').AsString = '1' then td := td + tabla3.FieldByName('importe').AsFloat;
  if tabla3.FieldByName('DC').AsString = '2' then th := th + tabla3.FieldByName('importe').AsFloat;

  if tabla3.FieldByName('idtitular').AsString <> clant then
    begin
      // Subtotal
      if clant <> '' then rSubtotales(salida);

      proveedor.getDatos(tabla3.FieldByName('idtitular').AsString);
      pr := proveedor.Nombre;
      List.Linea(0, 0, 'Proveedor: ' + tabla3.FieldByName('idtitular').AsString + '-   ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
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

procedure TTCtactepr1.rListarPlan(iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de Proveedores Definidas
var
  indice, t: string;
begin
  indice := tabla3.IndexFieldNames;

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

  tabla3.IndexName := 'Listplan';

  tabla1.First;
  while not tabla1.EOF do
    begin
      if tabla1.FieldByName('sel').AsString = 'X' then
        begin
           saldo := 0; td := 0; th := 0; idant := ''; clant := ''; total := 0; recar := 0; saldoanter := 0;

           tabla3.First;
           t := tabla3.FieldByName('DC').AsString;

           while not tabla3.EOF do
             begin
               if (tabla3.FieldByName('idtitular').AsString = tabla1.FieldByName('idtitular').AsString) and (tabla3.FieldByName('clavecta').AsString = tabla1.FieldByName('clavecta').AsString) then
                 begin
                   if tabla3.FieldByName('DC').AsString <> t then
                     begin
                       rSubtotales1(salida, t);
                       List.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
                       total := 0;
                     end;
                   if tabla3.FieldByName('DC').AsString = '1' then iss := False else iss := True;
                   if (tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then
                     if ((tabla3.FieldByName('items').AsString > '000') or (tabla3.FieldByName('items').AsString = '000')) or (tabla3.FieldByName('tipo').AsString = 'I') then List_LineaPlan(salida);

                   if ((tabla3.FieldByName('items').AsString > '000') or (tabla3.FieldByName('items').AsString = '000')) or (tabla3.FieldByName('estado').AsString = 'R') then
                     begin  // Saldos y Totales
                       if tabla3.FieldByName('DC').AsString = '1' then td := td + tabla3.FieldByName('importe').AsFloat;
                       if tabla3.FieldByName('DC').AsString = '2' then th := th + tabla3.FieldByName('importe').AsFloat;
                       total := total + tabla3.FieldByName('importe').AsFloat;
                       recar := recar + tabla3.FieldByName('recargo').AsFloat;
                     end;

                   saldoanter := td - th;
                   t := tabla3.FieldByName('DC').AsString;
                 end;

               tabla3.Next;
             end;

           if (td + th) <> 0 then
            if t = '1' then
             begin
               rSubtotales1(salida, '1');
               iss := True;
               rSubtotales1(salida, '2');
             end

            else
             rSubtotales1(salida, '2');
        end;
      tabla1.Next;
    end;

    List.FinList;

    tabla3.IndexFieldNames := indice;
end;

procedure TTCtactepr1.List_LineaPlan(salida: char);
// Objetivo...: Listar una Línea
var
  pr: string;
begin
  if (tabla3.FieldByName('idtitular').AsString <> idant) or (tabla3.FieldByName('clavecta').AsString <> clant) then
    begin
      // Subtotal
      if idant <> '' then rSubtotales(salida);
      proveedor.getDatos(tabla3.FieldByName('idtitular').AsString);
      pr := proveedor.Nombre;
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
    List.importe(95, list.lineactual, '', tabla3.FieldByName('recargo').AsFloat, 4, 'Arial, normal, 8');
    if tabla3.FieldByName('DC').AsString = '1' then List.Linea(98, List.lineactual, tabla3.FieldByName('estado').AsString, 5, 'Arial, normal, 7', salida, 'S') else List.Linea(98, List.lineactual, ' ', 5, 'Arial, normal, 8', salida, 'S');
    idant := tabla3.FieldByName('idtitular').AsString;
    clant := tabla3.FieldByName('clavecta').AsString;
end;

procedure TTCtactepr1.tot_deuda(salida: char);
// Objetivo...: subtotalizar una deuda para un proveedor
begin
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
  List.derecha(90, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total Deuda .....: ', 1, 'Arial, negrita, 8', salida, 'S');
  List.importe(90, list.lineactual, '', total, 2, 'Arial, negrita, 8');
  List.Linea(95, List.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  total := 0;
end;

procedure TTCtactepr1.ListarVencimientos(fecha: string; salida: char);
// Objetivo...: Listar los vencimientos de Cuentas Corrientes
var
  pr, clant: string;
begin
  TSQL := datosdb.tranSQL('SELECT * FROM ctactepr WHERE fecha <= ' + '''' + utiles.sExprFecha(fecha) + '''' + ' AND estado = ' + '''' + 'I' + '''' + ' AND items >= ' + '''' + '000' + '''' + ' ORDER BY fecha');

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Listado de Venciemientos de Pagos de proveedors', 1, 'Arial, negrita, 14');
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
                  proveedor.getDatos(TSQL.FieldByName('idtitular').AsString);
                  pr := proveedor.Nombre;

                  if TSQL.FieldByName('idtitular').AsString <> clant then tot_deuda(salida);

                  if TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat <> 0 then
                    begin
                      List.Linea(0, 0, utiles.sFormatoFecha(TSQL.FieldByName('fecha').AsString) + '  ' + TSQL.FieldByName('idtitular').AsString + '-' + TSQL.FieldByName('clavecta').AsString + '  ' + pr, 1, 'Arial, normal, 8', salida, 'N');
                      List.Linea(40, list.lineactual, proveedor.Domicilio, 2, 'Arial, normal, 8', salida, 'N');
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

procedure TTCtactepr1.ObtenerSaldo(xidtitular, xclavecta: string);
// Objetivo...: Calcular el saldo para una cuenta dada
begin
  td := 0; th := 0;
  TSQL.Open; TSQL.First;
  while not TSQL.EOF do
    begin
      if (TSQL.FieldByName('idtitular').AsString = xidtitular) and (TSQL.FieldByName('clavecta').AsString = xclavecta) then
        begin
          if (TSQL.FieldByName('items').AsString = '-1') or (TSQL.FieldByName('tipo').AsString = 'I') or ((Length(Trim(TSQL.FieldByName('items').AsString)) = 0) and (TSQL.FieldByName('DC').AsString = '1')) then td := td + TSQL.FieldByName('importe').AsFloat;
          if TSQL.FieldByName('DC').AsString = '2' then th := th + TSQL.FieldByName('importe').AsFloat;
        end;
      TSQL.Next;
    end;
end;

procedure TTCtactepr1.ListPlanillaSaldos(fecha: string; salida: char);
// Objetivo...: Listar saldos individuales por cuenta
var
  pr, dom: string;
begin
  TSQL := datosdb.tranSQL('SELECT ctactepr.tipo, ctactepr.fecha, ctactepr.idtitular, ctactepr.clavecta, ctactepr.DC, ctactepr.Items, ctactepr.importe FROM ctactepr WHERE fecha <= ' + '''' + utiles.sExprFecha(fecha) + '''');

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Planilla de Saldos de proveedors', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Saldos al ' + fecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cuenta     Titular', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(83, List.lineactual, 'Saldo', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  total := 0;
  tabla1.First;
  while not tabla1.EOF do
    begin
      if tabla1.FieldByName('sel').AsString = 'X' then
        begin
          ObtenerSaldo(tabla1.FieldByName('idtitular').AsString, tabla1.FieldByName('clavecta').AsString);
          proveedor.getDatos(tabla1.FieldByName('idtitular').AsString);
          pr  := proveedor.Nombre;
          dom := proveedor.Domicilio;

          List.Linea(0, 0, tabla1.FieldByName('idtitular').AsString + '  ' + tabla1.FieldByName('clavecta').AsString + '  ' + pr, 1, 'Arial, normal, 8', salida, 'N');
          List.Linea(40, list.lineactual, dom, 2, 'Arial, normal, 8', salida, 'N');
          List.importe(90, list.lineactual, '', td - th, 3, 'Arial, normal, 8');
          List.Linea(90, List.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
          total := total + (td - th);
        end;
      tabla1.Next;
    end;

    TSQL.Close;

    list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
    list.derecha(90, list.lineactual, '##############', '--------------', 2, 'Arial, normal, 8');
    list.Linea(0, 0, 'Total ........: ', 1, 'Arial, normal, 8', salida, 'N');
    list.importe(90, list.lineactual, '', total, 2, 'Arial, normal, 8');
    list.Linea(92, list.lineactual, '  ', 3, 'Arial, normal, 8', salida, 'S');

    List.FinList;
end;

function TTCtactepr1.getMcctcl: TQuery;
// Objetivo...: Devolver un set con los registros registrados
begin
  Result := datosdb.tranSQL('SELECT ctactepr.fecha, ctactepr.idcompr AS IDC, ctactepr.tipo AS Tipo, ctactepr.sucursal AS Sucur, ctactepr.numero AS Numero, ctactepr.idtitular AS Cod, ctactepr.clavecta AS Cta, proveedors.nombre, ctactepr.concepto AS Concepto, ' +
            ' ctactepr.importe AS Importe FROM ctactepr, proveedors WHERE ctactepr.idtitular = proveedors.codcli AND ctactepr.items = ' + '''' + '-1' + '''' + ' ORDER BY ctactepr.fecha');
end;

function TTCtactepr1.getMcctcl(xt, xc: string): TQuery;
// Objetivo...: Devolver un set con los registros registrados
begin
  Result := datosdb.tranSQL('SELECT ctactepr.fecha, ctactepr.idcompr AS IDC, ctactepr.tipo AS Tipo, ctactepr.sucursal, ctactepr.numero AS Numero, ctactepr.DCctactepr.idtitular AS Cod, ctactepr.clavecta AS Cta, proveedors.nombre, ctactepr.concepto AS Concepto, ' +
               'ctactepr.importe AS Importe ' +
               'FROM ctactepr, proveedors WHERE ctactepr.idtitular = proveedors.codcli ' + //AND ctactepr.items = ' + '''' + '-1' + '''' +
               ' AND ctactepr.idtitular = ' + '''' + xt + '''' + ' AND ctactepr.clavecta = ' + '''' + xc + '''' +
               ' ORDER BY ctactepr.fecha');
end;

// Consultas para Estadísticas

function TTCtactepr1.EstsqlSaldosCobrar(fecha1, fecha2: string): TQuery;
// Objetivo...: Generar Transacción SQL para determinar Saldos a Cobrar de c/c
begin
  Result := datosdb.tranSQL('SELECT ctactepr.fecha, ctactepr.tipo, ctactepr.sucursal, ctactepr.numero, ctactepr.concepto, ctactepr.idtitular, ctactepr.clavecta, proveedors.nombre, ctactepr.importe, ctactepr.entrega '
           +'FROM ctactepr, proveedors WHERE ctactepr.idtitular = proveedors.codcli AND ctactepr.fecha >= ' + '''' + fecha1 + '''' + ' AND ctactepr.fecha <= ' + '''' + fecha2 + ''''
           +' AND ctactepr.items > ' + '''' + '000' + '''' + ' AND ctactepr.estado = ' + '''' + 'I' + '''');
end;

function TTCtactepr1.EstsqlCobrosEfectuados(fecha1, fecha2: string): TQuery;
// Objetivo...: Generar Transacción SQL para determinar Cobros Efectuados de c/c
begin
  Result := datosdb.tranSQL('SELECT ctactepr.fecha, ctactepr.tipo, ctactepr.sucursal, ctactepr.numero, ctactepr.concepto, ctactepr.idtitular, ctactepr.clavecta, proveedors.nombre, ctactepr.importe '
           +'FROM ctactepr, proveedors WHERE ctactepr.idtitular = proveedors.codcli AND ctactepr.fecha >= ' + '''' + fecha1 + '''' + ' AND ctactepr.fecha <= ' + '''' + fecha2 + '''' + ' AND dc = ' + '''' + '2' + '''');
end;

function TTCtactepr1.EstsqlCuotasVencidas(fecha1, fecha2: string): TQuery;
// Objetivo...: Generar Transacción SQL para determinar Cobros Efectuados de c/c
begin
  Result := datosdb.tranSQL('SELECT ctactepr.fecha, ctactepr.tipo, ctactepr.sucursal, ctactepr.numero, ctactepr.concepto, ctactepr.idtitular, ctactepr.clavecta, proveedors.nombre, ctactepr.importe, ctactepr.entrega '
                          + 'FROM ctactepr, proveedors WHERE ctactepr.idtitular = proveedors.codcli AND ctactepr.fecha < ' + '''' + fecha1 + ''''
                          + ' AND estado = ' + '''' + 'I' + '''' + ' AND dc = ' + '''' + '1' + '''' + ' AND items >= ' + '''' + '000' + '''');
end;

function TTCtactepr1.AuditoriaFacturasEmitidas(fecha: string): TQuery;  // SQL Auditoría
// Objetivo...: Generar TransacSQL para auditoría de facturas emitidas
begin
  Result := datosdb.tranSQL('SELECT ctactepr.tipo, ctactepr.sucursal, ctactepr.numero, ctactepr.concepto, ctactepr.idtitular, ctactepr.clavecta, proveedors.nombre, ctactepr.importe '
                            +'FROM ctactepr, proveedors WHERE ctactepr.idtitular = proveedors.codcli AND ctactepr.fecha = ' + '''' + fecha + '''' + ' AND items = ' + '''' + '-1' + '''');
end;

function TTCtactepr1.AuditoriaRecaudacionesCobros(fecha: string): TQuery;
// Objetivo...: Generar TransacSQL para auditoría de cobros efectuados
begin
  Result := datosdb.tranSQL('SELECT ctactepr.tipo, ctactepr.sucursal, ctactepr.numero, ctactepr.concepto, ctactepr.idtitular, ctactepr.clavecta, proveedors.nombre, ctactepr.importe '
                           +'FROM ctactepr, proveedors WHERE ctactepr.idtitular = proveedors.codcli AND ctactepr.fecha = ' + '''' + fecha + '''' + ' AND dc = ' + '''' + '2' + '''');
end;

function TTCtactepr1.setFact: TQuery;
// Objetivo...: devolver un set con los comprobantes registrados
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla3.TableName);
end;

procedure TTCtactepr1.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    proveedor.conectar;
    if not tabla1.Active then
      begin
        tabla1.Open;
        tabla1.FieldByName('fealta').Visible := False; tabla1.FieldByName('clave').Visible := False; tabla1.FieldByName('sel').Visible := False; tabla1.FieldByName('obs').Visible := False;
        tabla1.FieldByName('idtitular').DisplayLabel := 'Titular'; tabla1.FieldByName('clavecta').DisplayLabel := 'Cta.'; tabla1.FieldByName('obs').DisplayLabel := 'Observaciones';
      end;
    if not tabla3.Active then
      begin
        tabla3.Open;
        tabla3.FieldByName('idtitular').Visible := False; tabla3.FieldByName('clavecta').Visible := False;
      end;
    if not tabla2.Active then tabla2.Open;
  end;
  Inc(conexiones);
end;

procedure TTCtactepr1.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    proveedor.desconectar;
    datosdb.closeDB(tabla1);
    datosdb.closeDB(tabla2);
    datosdb.closeDB(tabla3);
  end;
end;

{===============================================================================}

function ccpr1: TTCtactepr1;
begin
  if xccpr1 = nil then
    xccpr1 := TTCtactepr1.Create;
  Result := xccpr1;
end;

{===============================================================================}

initialization

finalization
  xccpr1.Free;

end.
