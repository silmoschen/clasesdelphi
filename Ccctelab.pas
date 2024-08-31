unit Ccctelab;

interface

uses SysUtils, DB, DBTables, CBDT, CCtactes, Cpaciente, CListar, CUtiles, CIDBFM, CAdmNumCompr;

type

TTCtaCteLab = class(TTCtacte)            // Superclase
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Verifpaciente(xcodcli: string): boolean;
  function    getPaciente(xcodcli: string): string;
  function    getDireccion(xcodcli: string): string;

  procedure   RecalcularEntregasRecibos(xclavecta, xidtitular: string);
  function    getMontoSolicitud: real;
  function    getMontoEntregas: real;
  procedure   GrabarTran(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto: string; ximporte, xentrega, xcuota: real);
  procedure   GrabarPago(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto: string; ximporte, xentrega, xcuota, xrecargo: real; ftc, fti, fsu, fnu, fit: string);
  procedure   GrabarFact(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm: string; ximporte, xentrega: real);
  procedure   BorrarPago(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string);
  procedure   BorrarComprobante(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
  function    getPagos(xclavecta, xidtitular: string): TQuery;
  function    getRecibos(xclavecta, xidtitular: string): TQuery;
  procedure   Depurar(fecha: string);

  function    getFactventa(xidc, xtipo, xsucursal, xnumero: string): TQuery;
  procedure   rListar(xcodpac, xnrosol, iniciar, finalizar: string; salida: char);
  procedure   rListarPlan(xcodpac, xnrosol, iniciar, finalizar: string; salida: char);
  procedure   rSubtotales(salida: char);
  procedure   rSubtotales1(salida: char; t: string);
  procedure   ListarVencimientos(fecha: string; salida: char);
  procedure   ListPlanillaSaldos(fecha: string; salida: char);
  procedure   rListarRes(xcodpac, iniciar, finalizar: string; salida: char);
  function    getMcctcl: TQuery; overload;
  function    getMcctcl(xt: string): TQuery; overload;
  function    getMcctcl(xt, xc: string): TQuery; overload;
  function    EstsqlSaldosCobrar(fecha1, fecha2: string): TQuery;         // SQL Estadísticas
  function    EstsqlCobrosEfectuados(fecha1, fecha2: string): TQuery;
  function    EstsqlCuotasVencidas(fecha1, fecha2: string): TQuery;
  function    AuditoriaSolicitudesEmitidas(fecha: string): TQuery;  // SQL Auditoría
  function    AuditoriaRecaudacionesCobros(fecha: string): TQuery;
  procedure   ActualizarUltimoReciboImpreso(xnumero: string);
  function    verificarSiLaCuentaEstaSaldada(xnrosolicitud, xcodpac: string): boolean;
  procedure   reparar;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  importe_cuota, totsolicitud, totrecibos: real;
  procedure   MarcarCuotaPaga(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string; ximporte, xcuota: real);
  function    RecalcularEntregas(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string): real;
  procedure   tot_deuda(salida: char);
  procedure   cList_linea(salida: char);
  procedure   TitulosResctas(salida: char);
  procedure   rList_Linea(salida: char);
  procedure   List_LineaPlan(salida: char);
  procedure   ObtenerSaldo(xidtitular: string);
  procedure   BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
end;

function cclab: TTCtaCteLab;

implementation

var
  xctactelab: TTCtaCteLab = nil;

constructor TTCtaCteLab.Create;
begin
  inherited Create;
  tabla1 := datosdb.openDB('cctcl', 'Idtitular;Clavecta');
  tabla2 := datosdb.openDB('ctactecf', 'Idcompr;Tipo;Sucursal;Numero');
  tabla3 := datosdb.openDB('ctactecl', 'Idtitular;Clavecta;Idcompr;Tipo;Sucursal;Numero;Items');
end;

destructor TTCtaCteLab.Destroy;
begin
  inherited Destroy;
end;

function TTCtaCteLab.Verifpaciente(xcodcli: string): boolean;
// Objetivo...: Verificamos que el proveedor ingresado Exista
begin
  if paciente.Buscar(xcodcli) then Result := True else Result := False;
end;

function TTCtaCteLab.getpaciente(xcodcli: string): string;
// Objetivo...: Recuperamos el paciente titular de la Cuenta
begin
  paciente.getDatos(xcodcli);
  Result := paciente.Nombre;
end;

function TTCtaCteLab.getDireccion(xcodcli: string): string;
// Objetivo...: Recuperamos la Direccion
begin
  paciente.getDatos(xcodcli);
  Result := paciente.Domicilio;
end;

function TTCtaCteLab.getFactventa(xidc, xtipo, xsucursal, xnumero: string): TQuery;
// Objetivo...: Buscar un comprobante Registrado con el Id de Ventas
begin
  tabla2.Refresh;
  if datosdb.Buscar(tabla2, 'idcompr', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero) then Begin
    TransferirDatos(True);
    // Atributos NO Heredados o  Sobrecargados
    clavecta  := tabla2.FieldByName('clavecta').AsString;
    idtitular := tabla2.FieldByName('idtitular').AsString;
    fecha     := tabla2.FieldByName('fecha').AsString;
    importe   := tabla2.FieldByName('importe').AsFloat;
    entrega   := tabla2.FieldByName('entrega').AsFloat;
    // Filtramos el Plan
    Result  := getPlan(clavecta, idtitular, xidc, xtipo, xsucursal, xnumero);
  end else Begin
    TransferirDatos(False);
    Result := nil;
  end;
end;

procedure TTCtaCteLab.GrabarTran(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto: string; ximporte, xentrega, xcuota: real);
// Objetivo...: Grabar los movimientos Generados a partir de los planes, cobros/o pagos efectuados
begin
  if xitems = '-1' then GrabarFact(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm, ximporte, xentrega);
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then Begin
    if xitems = '-1' then Begin
      datosdb.tranSQL('DELETE FROM ' + tabla3.TableName + ' WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''' + ' AND idcompr = ' + '''' + xidc + '''' + ' AND tipo = ' + '''' + xtipo + '''' +
                      ' AND numero = ' + '''' + xnumero + '''');
      tabla3.Append;  // Anulamos el plan anterior
    end else
      tabla3.Edit;
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
  if xitems = '0' then begin
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
  datosdb.refrescar(tabla3);
end;

procedure TTCtaCteLab.BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
// Objetivo...: Eliminar detalle del comprobante
var
  i: integer; xit: string;
begin
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, '-1')  then tabla3.Delete;
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, '0') then tabla3.Delete;
  // Borramos las cuotas
  For i := 1 to 999 do Begin
    xit := utiles.sLlenarIzquierda(IntToStr(i), 3, '0');
    if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xit) then tabla3.Delete else Break;
  end;
  // Borramos los recibos
  datosdb.tranSQL('DELETE FROM ctactecl WHERE clavecta = ' + '"' + xclavecta + '"' + ' AND idtitular = ' + '"' + xidtitular + '"' + ' AND XT = ' + '"' + xtipo + '"' + ' AND XS = ' + '"' + xsucursal + '"' + ' AND XN = ' + '"' + xnumero + '"');
end;

procedure TTCtaCteLab.BorrarComprobante(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
// Objetivo...: Eliminar un comprobante - detalle y relaciones
begin
  // Borramos los datos de la Factura
  datosdb.tranSQL('DELETE FROM ctactecf WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''' +
                  ' AND idcompr = ' + '''' + xidc + '''' + ' AND tipo = ' + '''' + xtipo + '''' + ' AND sucursal = ' + '''' + xsucursal + '''' + ' AND numero = ' + '''' + xnumero + '''');
  // Borramos los datos del recibo
  BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero);
  if tabla2.Active then getDatos(tabla2.FieldByName('clavecta').AsString, tabla2.FieldByName('idtitular').AsString, tabla2.FieldByName('idcompr').AsString, tabla2.FieldByName('tipo').AsString, tabla2.FieldByName('sucursal').AsString, tabla2.FieldByName('numero').AsString, tabla2.FieldByName('DC').AsString);
end;

procedure TTCtaCteLab.GrabarPago(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto: string; ximporte, xentrega, xcuota, xrecargo: real; ftc, fti, fsu, fnu, fit: string);
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
    tabla3.Post;
    datosdb.refrescar(tabla3); 
    // Si el monto ingresado es igual al de la Cuota, marcamos la misma como paga
    MarcarCuotaPaga(xclavecta, xidtitular, ftc, fti, fsu, fnu, xitems, ximporte, xcuota);
  except
    tabla3.Cancel;
  end;
  importe_cuota := ximporte;
  tabla3.Filtered := True;
end;

procedure TTCtaCteLab.MarcarCuotaPaga(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string; ximporte, xcuota: real);
// Objetivo...: Marcar una cuota como paga
begin
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then begin
    importe_cuota := ximporte;
    importe_cuota := RecalcularEntregas(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems); // Determino si el pago fue total o parcial
    Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems);
    tabla3.Edit;
    if importe_cuota = tabla3.FieldByName('importe').AsFloat then tabla3.FieldByName('estado').AsString := 'P' else tabla3.FieldByName('estado').AsString := 'I';
    tabla3.FieldByName('entrega').AsFloat := importe_cuota;
    try
      tabla3.Post;
    except
      tabla3.Cancel;
    end;
  end;
end;

function TTCtaCteLab.RecalcularEntregas(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string): real;
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

procedure TTCtaCteLab.BorrarPago(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string);
// Objetivo...: Marcar una cuota como paga
var
  xxc, xxt, xxs, xxn: string;
  montocuota: real;
begin
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then begin
    // 1º Quitamos la Marca a la cuota Paga
    xxc := tabla3.FieldByName('XC').AsString;
    xxt := tabla3.FieldByName('XT').AsString;
    xxs := tabla3.FieldByName('XS').AsString;
    xxn := tabla3.FieldByName('XN').AsString;
     // Borramos el registro
    if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then tabla3.Delete;
     // Recalculamos las cuotas
    montocuota := RecalcularEntregas(xclavecta, xidtitular, xxc, xxt, xxs, xxn, xitems);

    if Buscar(xclavecta, xidtitular, xxc, xxt, xxs, xxn, xitems) then  begin
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

procedure TTCtaCteLab.GrabarFact(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm: string; ximporte, xentrega: real);
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
  try
    tabla2.Post;
  except
    tabla2.Cancel;
  end;
end;

function TTCtaCteLab.getPagos(xclavecta, xidtitular: string): TQuery;
// Objetivo...: Devolver un Set de las Cuentas Corrientes Disponibles para un titular
begin
  Result := datosdb.tranSQL('SELECT * FROM ctactecl WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''' + ' ORDER BY fecha, items');
end;

function TTCtaCteLab.getRecibos(xclavecta, xidtitular: string): TQuery;
// Objetivo...: Devolver un Set de los Recibos Ingresados
begin
  Result := datosdb.tranSQL('SELECT * FROM ctactecl WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''' + ' AND estado = ' + '''' + 'R' + '''' + ' ORDER BY fecha, items');
end;

procedure TTCtaCteLab.RecalcularEntregasRecibos(xclavecta, xidtitular: string);
// Objetivo...: retornar el total de la solicitud
var
  r: TQuery;
begin
  totsolicitud := 0; totrecibos := 0;
  r := getPagos(xclavecta, xidtitular);
  r.Open; r.First;
  while not r.EOF do begin
    if r.FieldByName('items').AsString = '-1' then totsolicitud := r.FieldByName('importe').AsFloat;
    if r.FieldByName('DC').AsString = '2'     then totrecibos := totrecibos + r.FieldByName('importe').AsFloat;
    r.Next;
  end;
  r.Close; r.Free;
end;

function TTCtaCteLab.getMontoSolicitud: real;
// Objetivo...: retornar el total de la solicitud
begin
  Result := totsolicitud;
end;

function TTCtaCteLab.getMontoEntregas: real;
// Objetivo...: retornar el total de la solicitud
begin
  Result := totrecibos;
end;

procedure TTCtaCteLab.Depurar(fecha: string);
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

  while not r.EOF do begin    // Procesamos el Set de Comprobantes Listos para Depurar
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

procedure TTCtaCteLab.rList_linea(salida: char);
// Objetivo...: Listar una Línea - ruptura por cuenta
var
  pr: string;
begin
  if tabla3.FieldByName('DC').AsString = '1' then td := td + tabla3.FieldByName('importe').AsFloat;
  if tabla3.FieldByName('DC').AsString = '2' then th := th + tabla3.FieldByName('importe').AsFloat;

  if (tabla3.FieldByName('idtitular').AsString <> idant) or (tabla3.FieldByName('clavecta').AsString <> clant) then begin
    // Subtotal
    if idant <> '' then rSubtotales(salida);

    paciente.Buscar(tabla3.FieldByName('idtitular').AsString);
    pr := paciente.tperso.FieldByName('nombre').AsString;
    List.Linea(0, 0, 'Paciente: ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
    List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    List.Linea(0, 0, utiles.espacios(140) + 'Saldo Anterior: ', 1, 'Arial, negrita, 8', salida, 'S');
    if tabla3.FieldByName('DC').AsString = '1' then saldoanter := saldo - tabla3.FieldByName('importe').AsFloat else saldoanter := saldo + tabla3.FieldByName('importe').AsFloat;
    List.importe(100, list.lineactual, '', saldoanter, 2, 'Arial, negrita, 8');
    List.Linea(101, list.lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');
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

procedure TTCtaCteLab.rSubtotales(salida: char);
// Objetivo...: Emitir Subtotales
begin
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
  List.derecha(70, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.derecha(85, list.lineactual, '', '--------------', 3, 'Arial, normal, 8');
  List.derecha(100, list.lineactual, '', '--------------', 4, 'Arial, normal, 8');
  List.Linea(101, list.lineactual, ' ', 5, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(70, list.lineactual, '', td, 2, 'Arial, normal, 8');
  List.importe(85, list.lineactual, '', th, 3, 'Arial, normal, 8');
  List.importe(100, list.lineactual, '', saldo, 4, 'Arial, normal, 8');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
  saldo := 0; td := 0; th := 0;
end;

procedure TTCtaCteLab.rSubtotales1(salida: char; t: string);
// Objetivo...: Emitir Subtotales
var
  l: string;
begin
  if t = '1' then l := 'Total Deuda:' else l := 'Total Abonado:';
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
  List.derecha(70, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.derecha(85, list.lineactual, '', '--------------', 3, 'Arial, normal, 8');
  List.Linea(99, list.lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, l, 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(70, list.lineactual, '', total, 2, 'Arial, negrita, 8');
  List.importe(85, list.lineactual, '', recar, 3, 'Arial, negrita, 8');
  List.Linea(90, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
  if iss then Begin
    List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    List.Linea(0, 0, 'Saldo Actual:', 1, 'Arial, negrita, 8', salida, 'N');
    List.importe(30, list.lineactual, '', td - th, 2, 'Arial, negrita, 8');
  end;
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
end;

procedure TTCtaCteLab.TitulosResctas(salida: char);
// Objetivo...: Titulos del resumen de cuentas corrientes de Proveedores
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Resumen de Cuenta', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(17, List.lineactual, 'Comprobante                   Concepto Operación', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Debe', 3, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'Haber', 4, 'Arial, cursiva, 8');
  List.Titulo(95, List.lineactual, 'Saldo', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTCtaCteLab.rListar(xcodpac, xnrosol, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de pacientes con ruptura por cuenta
var
  indice: string;
begin
  indice := tabla3.IndexFieldNames;

  TitulosResctas(salida);

  tabla3.IndexName := 'Listado';

  saldo := 0; td := 0; th := 0; idant := ''; clant := '';

  tabla3.First;
  while not tabla3.EOF do begin
    if (tabla3.FieldByName('idtitular').AsString = xcodpac) and (tabla3.FieldByName('clavecta').AsString = xnrosol) then begin
      if (Length(Trim(tabla3.FieldByName('XN').AsString)) > 0) or (tabla3.FieldByName('tipo').AsString = 'I') then begin
        if tabla3.FieldByName('DC').AsString = '1' then saldo := saldo + tabla3.FieldByName('importe').AsFloat;
        if tabla3.FieldByName('DC').AsString = '2' then saldo := saldo - tabla3.FieldByName('importe').AsFloat;
      end;
      if (tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then
        if (Length(Trim(tabla3.FieldByName('XN').AsString)) > 0) or (tabla3.FieldByName('tipo').AsString = 'I') then rList_Linea(salida);
    end;

    tabla3.Next;
  end;

  if td + th <> 0 then rSubtotales(salida);

  List.FinList;

  tabla3.IndexFieldNames := indice;
end;

procedure TTCtaCteLab.rListarRes(xcodpac, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de pacientes con ruptura por paciente
var
  indice, idant: string;
begin
  indice := tabla3.IndexFieldNames;

  TitulosResctas(salida);

  tabla3.IndexName := 'Listado';

  idant := ''; clant := ''; saldo := 0; saldoanter := 0; td := 0; th := 0;

  tabla3.First;
  while not tabla3.EOF do begin
    if (tabla3.FieldByName('idtitular').AsString = xcodpac) then begin
      if (tabla3.FieldByName('DC').AsString = '1') and (tabla3.FieldByName('items').AsString < '001') then saldo := saldo + tabla3.FieldByName('importe').AsFloat;
      if tabla3.FieldByName('DC').AsString = '2' then saldo := saldo - tabla3.FieldByName('importe').AsFloat;
      if (tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then
      if (Length(Trim(tabla3.FieldByName('XN').AsString)) > 0) or (tabla3.FieldByName('tipo').AsString = 'I') then cList_Linea(salida);
    end;

    tabla3.Next;
  end;

  if td + th <> 0 then rSubtotales(salida);

  List.FinList;

  tabla3.IndexFieldNames := indice;
end;

procedure TTCtaCteLab.cList_linea(salida: char);
// Objetivo...: Listar una Línea - ruptura por paciente
var
  pr: string;
begin
  if tabla3.FieldByName('DC').AsString = '1' then td := td + tabla3.FieldByName('importe').AsFloat;
  if tabla3.FieldByName('DC').AsString = '2' then th := th + tabla3.FieldByName('importe').AsFloat;

  if tabla3.FieldByName('idtitular').AsString <> clant then begin
    // Subtotal
    if clant <> '' then rSubtotales(salida);

    paciente.Buscar(tabla3.FieldByName('idtitular').AsString);
    pr := paciente.tperso.FieldByName('nombre').AsString;
    List.Linea(0, 0, 'Paciente: ' + tabla3.FieldByName('idtitular').AsString + '-   ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
    List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    List.Linea(0, 0, utiles.espacios(140) + 'Saldo Anterior:', 1, 'Arial, cursiva, 8', salida, 'S');
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

procedure TTCtaCteLab.rListarPlan(xcodpac, xnrosol, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de Proveedores Definidas
var
  indice, t: string;
begin
  indice := tabla3.IndexFieldNames;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Detalle de Pagos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(17, List.lineactual, 'Compr/Sol.     Concepto Operación', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Monto', 3, 'Arial, cursiva, 8');
  List.Titulo(89, List.lineactual, 'Recargo', 4, 'Arial, cursiva, 8');
  List.Titulo(97, List.lineactual, 'Est.', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla3.IndexName := 'Listplan';

  saldo := 0; td := 0; th := 0; idant := ''; clant := ''; total := 0; recar := 0; saldoanter := 0;

  tabla3.First;

  t := tabla3.FieldByName('DC').AsString;

  while not tabla3.EOF do begin
    if (tabla3.FieldByName('idtitular').AsString = xcodpac) and (tabla3.FieldByName('clavecta').AsString = xnrosol) then begin
      if tabla3.FieldByName('DC').AsString <> t then begin
        rSubtotales1(salida, t);
        List.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
        total := 0;
      end;
      if tabla3.FieldByName('DC').AsString = '1' then iss := False else iss := True;
      if (tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then
      if ((tabla3.FieldByName('items').AsString > '000') or (tabla3.FieldByName('items').AsString = '000')) or (tabla3.FieldByName('tipo').AsString = 'I') then List_LineaPlan(salida);

      if ((tabla3.FieldByName('items').AsString > '000') or (tabla3.FieldByName('items').AsString = '000')) or (tabla3.FieldByName('estado').AsString = 'R') then begin  // Saldos y Totales
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
    if t = '1' then begin
      rSubtotales1(salida, '1');
      iss := True;
      rSubtotales1(salida, '2');
    end else
      rSubtotales1(salida, '2');

  List.FinList;

  tabla3.IndexFieldNames := indice;
end;

procedure TTCtaCteLab.List_LineaPlan(salida: char);
// Objetivo...: Listar una Línea
var
  pr: string;
begin
  if (tabla3.FieldByName('idtitular').AsString <> idant) or (tabla3.FieldByName('clavecta').AsString <> clant) then begin
    // Subtotal
    if idant <> '' then rSubtotales(salida);
    paciente.Buscar(tabla3.FieldByName('idtitular').AsString);
    pr := paciente.tperso.FieldByName('nombre').AsString;
    List.Linea(0, 0, 'Paciente: ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
    List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    List.Linea(0, 0, utiles.espacios(140) + 'Saldo Anterior: ', 1, 'Arial, cursiva, 8', salida, 'S');
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

procedure TTCtaCteLab.tot_deuda(salida: char);
// Objetivo...: subtotalizar una deuda para un paciente
begin
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
  List.derecha(90, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total Abonado: ', 1, 'Arial, negrita, 8', salida, 'S');
  List.importe(90, list.lineactual, '', total, 2, 'Arial, negrita, 8');
  List.Linea(95, List.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  total := 0;
end;

procedure TTCtaCteLab.ListarVencimientos(fecha: string; salida: char);
// Objetivo...: Listar los vencimientos de Cuentas Corrientes
var
  pr, clant: string;
  r: TQuery;
begin
  TSQL := datosdb.tranSQL('SELECT * FROM ctactecl WHERE fecha <= ' + '''' + utiles.sExprFecha(fecha) + '''' + ' AND estado = ' + '''' + 'I' + '''' + ' AND items >= ' + '''' + '000' + '''' + ' ORDER BY fecha');

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Listado de Venciemientos de Pagos de pacientes', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Vencimientos al ' + fecha, 1, 'Arial, cursiva, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, List.lineactual, 'Cód. Paciente', 2, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Domicilio', 3, 'Arial, cursiva, 8');
  List.Titulo(85, List.lineactual, 'Monto', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  recar := 0; total := 0;

  TSQL.Open;
  r := paciente.setPacientes;
  r.Open; r.First;
  while not r.EOF do begin
    TSQL.First;
    clant := r.FieldByName('codpac').AsString; //TSQL.FieldByName('idtitular').AsString;
    while not TSQL.EOF do begin
      if r.FieldByName('codpac').AsString = TSQL.FieldByName('idtitular').AsString then begin
        paciente.getDatos(TSQL.FieldByName('idtitular').AsString);
        pr := paciente.Nombre;

        if TSQL.FieldByName('idtitular').AsString <> clant then tot_deuda(salida);

        if TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat <> 0 then begin
          List.Linea(0, 0, utiles.sFormatoFecha(TSQL.FieldByName('fecha').AsString) + '  ' + TSQL.FieldByName('idtitular').AsString + '  ' + pr, 1, 'Arial, normal, 8', salida, 'N');
          List.Linea(40, list.lineactual, paciente.Domicilio, 2, 'Arial, normal, 8', salida, 'N');
          List.importe(90, list.lineactual, '', (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat), 3, 'Arial, normal, 8');
          List.Linea(95, List.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
          recar := recar + (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat);
          total := total + (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat);
        end;
      end;
      clant := TSQL.FieldByName('idtitular').AsString;
      TSQL.Next
     end;

     r.Next;
   end;

   tot_deuda(salida);

   // Listamos un total general de deudas
   List.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
   List.Linea(0, 0, 'Monto total de vencimientos:    ' +  utiles.FormatearNumero(FloatToStr(recar)), 1, 'Arial, normal, 10', salida, 'S');

   List.FinList;
end;

procedure TTCtaCteLab.ObtenerSaldo(xidtitular: string);
// Objetivo...: Calcular el saldo para una cuenta dada
begin
  td := 0; th := 0;
  TSQL.Open; TSQL.First;
  while not TSQL.EOF do begin
    if TSQL.FieldByName('idtitular').AsString = xidtitular then begin
      if (TSQL.FieldByName('items').AsString = '-1') or (TSQL.FieldByName('tipo').AsString = 'I') then td := td + TSQL.FieldByName('importe').AsFloat;
      if TSQL.FieldByName('DC').AsString = '2' then th := th + TSQL.FieldByName('importe').AsFloat;
    end;
    TSQL.Next;
  end;
end;

procedure TTCtaCteLab.ListPlanillaSaldos(fecha: string; salida: char);
// Objetivo...: Listar saldos individuales por cuenta
var
  pr, dom: string;
  r: TQuery;
begin
  TSQL := datosdb.tranSQL('SELECT ctactecl.tipo, ctactecl.fecha, ctactecl.idtitular, ctactecl.clavecta, ctactecl.DC, ctactecl.Items, ctactecl.importe FROM ctactecl WHERE fecha <= ' + '''' + utiles.sExprFecha(fecha) + '''');

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Planilla de Saldos de Pacientes', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Saldos al ' + fecha, 1, 'Arial, cursiva, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.      Paciente', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(83, List.lineactual, 'Saldo', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  total := 0;
  r := paciente.setPacientesAlf;
  r.Open; r.First;
  while not r.EOF do begin
    ObtenerSaldo(r.FieldByName('codpac').AsString);
    if td - th <> 0 then Begin
      paciente.getDatos(r.FieldByName('codpac').AsString);
      pr  := paciente.nombre;
      dom := paciente.domicilio;

      List.Linea(0, 0, r.FieldByName('codpac').AsString + '  ' + pr, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(40, list.lineactual, dom, 2, 'Arial, normal, 8', salida, 'N');
      List.importe(90, list.lineactual, '', td - th, 3, 'Arial, normal, 8');
      List.Linea(90, List.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + (td - th);
    end;
    r.Next;
  end;

  TSQL.Close;

  list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
  list.derecha(90, list.lineactual, '#################', '-----------------', 2, 'Arial, normal, 8');
  list.Linea(0, 0, 'Total: ', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(90, list.lineactual, '', total, 2, 'Arial, negrita, 8');
  list.Linea(92, list.lineactual, '  ', 3, 'Arial, negrita, 8', salida, 'S');

  List.FinList;
end;

function TTCtaCteLab.getMcctcl: TQuery;
// Objetivo...: Devolver un set con los registros registrados
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.idcompr AS IDC, ctactecl.tipo AS Tipo, ctactecl.sucursal AS Sucur, ctactecl.numero AS Numero, ctactecl.idtitular AS Cod, ctactecl.clavecta AS Cta, pacientes.nombre, ctactecl.concepto AS Concepto, ' +
                            ' ctactecl.importe AS Importe FROM ctactecl, pacientes WHERE ctactecl.idtitular = pacientes.codcli AND ctactecl.items = ' + '''' + '-1' + '''' + ' ORDER BY ctactecl.fecha');
end;

function TTCtaCteLab.getMcctcl(xt, xc: string): TQuery;
// Objetivo...: Devolver un set con los registros registrados
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.idcompr AS IDC, ctactecl.tipo AS Tipo, ctactecl.sucursal, ctactecl.numero AS Numero, ctactecl.DC, ctactecl.idtitular AS Cod, ctactecl.clavecta AS Cta, paciente.nombre, ctactecl.concepto AS Concepto, ' +
               'ctactecl.importe AS Importe FROM ctactecl, paciente WHERE ctactecl.idtitular = paciente.codpac AND ctactecl.idtitular = ' + '''' + xt + '''' + ' AND ctactecl.clavecta = ' + '''' + xc + '''' + ' ORDER BY ctactecl.fecha');
end;

function TTCtaCteLab.getMcctcl(xt: string): TQuery;
// Objetivo...: Devolver un set con los registros registrados
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.idcompr AS IDC, ctactecl.tipo AS Tipo, ctactecl.sucursal, ctactecl.numero AS Numero, ctactecl.DC, ctactecl.idtitular AS Cod, ctactecl.clavecta AS Cta, paciente.nombre, ctactecl.concepto AS Concepto, ' +
               'ctactecl.importe AS Importe, ctactecl.items FROM ctactecl, paciente WHERE ctactecl.idtitular = paciente.codpac AND ctactecl.idtitular = ' + '''' + xt + '''' + ' ORDER BY ctactecl.fecha');
end;

// Consultas para Estadísticas

function TTCtaCteLab.EstsqlSaldosCobrar(fecha1, fecha2: string): TQuery;
// Objetivo...: Generar Transacción SQL para determinar Saldos a Cobrar de c/c
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, paciente.nombre, ctactecl.importe, ctactecl.entrega '
           +'FROM ctactecl, paciente WHERE ctactecl.idtitular = paciente.codpac AND ctactecl.fecha >= ' + '"' + fecha1 + '"' + ' AND ctactecl.fecha <= ' + '"' + fecha2 + '"'
           +' AND ctactecl.items = ' + '"' + '001' + '"' + ' AND ctactecl.estado = ' + '"' + 'I' + '"' + ' ORDER BY fecha');
end;

function TTCtaCteLab.EstsqlCobrosEfectuados(fecha1, fecha2: string): TQuery;
// Objetivo...: Generar Transacción SQL para determinar Cobros Efectuados de c/c
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, paciente.nombre, ctactecl.importe, ctactecl.recargo '
           + ' FROM ctactecl, paciente WHERE ctactecl.idtitular = paciente.codpac AND ctactecl.fecha >= ' + '''' + fecha1 + '''' + ' AND ctactecl.fecha <= ' + '''' + fecha2 + '''' + ' AND dc = ' + '''' + '2' + '''' + ' ORDER BY fecha');
end;

function TTCtaCteLab.EstsqlCuotasVencidas(fecha1, fecha2: string): TQuery;
// Objetivo...: Generar Transacción SQL para determinar Cobros Efectuados de c/c
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, paciente.nombre, ctactecl.importe, ctactecl.entrega '
                          + 'FROM ctactecl, paciente WHERE ctactecl.idtitular = paciente.codpac AND ctactecl.fecha < ' + '''' + fecha1 + ''''
                          + ' AND estado = ' + '''' + 'I' + '''' + ' AND dc = ' + '''' + '1' + '''' + ' AND items = ' + '''' + '-1' + '''' + ' ORDER BY fecha');
end;

function TTCtaCteLab.AuditoriaSolicitudesEmitidas(fecha: string): TQuery;  // SQL Auditoría
// Objetivo...: Generar TransacSQL para auditoría de facturas emitidas
begin
  Result := datosdb.tranSQL('SELECT ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, paciente.nombre, ctactecl.importe '
                            + ' FROM ctactecl, paciente WHERE ctactecl.idtitular = paciente.codpac AND ctactecl.fecha = ' + '''' + fecha + '''' + ' AND items >= ' + '''' + '000' + '''' + ' AND DC = ' + '"' + '1' + '"');
end;

function TTCtaCteLab.AuditoriaRecaudacionesCobros(fecha: string): TQuery;
// Objetivo...: Generar TransacSQL para auditoría de cobros efectuados
begin
  Result := datosdb.tranSQL('SELECT ctactecl.tipo, ctactecl.sucursal, ctactecl.numero, ctactecl.concepto, ctactecl.idtitular, ctactecl.clavecta, paciente.nombre, ctactecl.importe '
                           +'FROM ctactecl, paciente WHERE ctactecl.idtitular = paciente.codpac AND ctactecl.fecha = ' + '''' + fecha + '''' + ' AND dc = ' + '''' + '2' + '''' + ' AND importe <> 0');
end;

procedure TTCtaCteLab.reparar;
// Objetivo...: reparar datos
begin
  datosdb.tranSQL('DELETE FROM ' + tabla3.TableName + ' WHERE importe = 0');
end;

function TTCtaCteLab.verificarSiLaCuentaEstaSaldada(xnrosolicitud, xcodpac: string): boolean;
// Objetivo...: averiguar si la cuenta esta o no saldada, a partir del recuento entre la deuda y lo aportado
begin
  RecalcularEntregasRecibos(xnrosolicitud, xcodpac);
  if (getMontoSolicitud - getMontoEntregas) = 0 then Result := True else Result := False;
end;

procedure TTCtaCteLab.ActualizarUltimoReciboImpreso(xnumero: string);
// Objetivo...: Actualizar el número del último recibo impreso
begin
  administNum.ActNuemeroActualNF(xnumero);
end;

procedure TTCtaCteLab.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    paciente.conectar;
    if not tabla1.Active then tabla1.Open;
    tabla1.FieldByName('fealta').Visible := False; tabla1.FieldByName('clave').Visible := False; tabla1.FieldByName('sel').Visible := False; tabla1.FieldByName('obs').Visible := False;
    tabla1.FieldByName('idtitular').DisplayLabel := 'Titular'; tabla1.FieldByName('clavecta').DisplayLabel := 'Cta.'; tabla1.FieldByName('obs').DisplayLabel := 'Observaciones';
    if not tabla3.Active then tabla3.Open;
    tabla3.FieldByName('periodo').Visible := False; tabla3.FieldByName('idtitular').Visible := False; tabla3.FieldByName('clavecta').Visible := False;
    if not tabla2.Active then tabla2.Open;
  end;
  Inc(conexiones);
end;

procedure TTCtaCteLab.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    paciente.desconectar;
    datosdb.closeDB(tabla1);
    datosdb.closeDB(tabla2);
    datosdb.closeDB(tabla3);
  end;
end;

{===============================================================================}

function cclab: TTCtaCteLab;
begin
  if xctactelab = nil then
    xctactelab := TTCtaCteLab.Create;
  Result := xctactelab;
end;

{===============================================================================}

initialization

finalization
  xctactelab.Free;

end.
