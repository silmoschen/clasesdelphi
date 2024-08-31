unit CCInscr;

interface

uses SysUtils, DB, DBTables, CBDT, CCtactes, CAlumno, CDefcurs, CListar, CUtiles, CIDBFM;

type

TTCInscriptos = class(TTCtacte)            // Superclase
 public
  { Declaraciones Públicas }
  constructor Create(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xtm, xfecha, xfealta, xobs, xconcepto: string; ximporte: real);
  destructor  Destroy; override;

  function    Verifalumno(xcodcli: string): boolean;
  function    VerifMovimiento(xcodcurso: string): boolean;
  function    getalumno(xcodcli: string): string;
  function    getTalumno: TTable;
  function    getSaldo(xid, xfecha: string): real;
  function    getUltimoPago: string;

  procedure   GrabarTran(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto: string; ximporte, xentrega, xcuota: real);
  procedure   GrabarPago(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto: string; ximporte, xentrega, xcuota, xrecargo: real; ftc, fti, fsu, fnu, fit: string);
  function    GrabarFact(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm: string; ximporte, xentrega: real): boolean;
  procedure   MarcarCuotaPaga(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string; ximporte, xcuota: real);
  procedure   BorrarDet(xclavecta, xidtitular: string);
  procedure   BorrarPago(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string);
  function    getPagos(xclavecta, xidtitular: string): TQuery;
  function    getRecibos(xclavecta, xidtitular: string): TQuery;
  function    RecalcularEntregas(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string): real;
  procedure   Depurar(fecha: string);
  procedure   conectar;
  procedure   desconectar;

  function    getFactventa(xidc, xtipo, xsucursal, xnumero: string): TQuery;
  procedure   rListar(xidtitular, xidcurso, iniciar, finalizar: string; salida: char);
  procedure   rListarPlan(xidtitular, xidcurso, iniciar, finalizar: string; salida: char);
  procedure   ListarVencimientos(fecha: string; salida: char);
  procedure   ListPlanillaSaldos(fecha: string; salida: char);
  procedure   rListarRes(xidtitular, iniciar, finalizar: string; salida: char);
  function    getMcctcl: TQuery; overload;
  function    getMcctcl(xt: string): TQuery; overload;
  function    getMcctcl(xt, xc: string): TQuery; overload;
  function    getCantidadAlumnos(xidalumno: string): integer;
  function    getCantidadCursos(xidcurso: string): integer;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  importe_cuota: real;
  TSQL: TQuery;
  ultimoPago: string;
  procedure tot_deuda(salida: char);
  procedure TitulosResctas(salida: char);
  procedure BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
  procedure rSubtotales(salida: char);
  procedure rSubtotales1(salida: char; t: string);
  procedure ObtenerSaldo(xidtitular: string);
  procedure rList_Linea(salida: char);
  procedure cList_Linea(salida: char);
  procedure List_LineaPlan(salida: char);
end;

function ccins: TTCInscriptos;

implementation

var
  xctactecl: TTCInscriptos = nil;

constructor TTCInscriptos.Create(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xtm, xfecha, xfealta, xobs, xconcepto: string; ximporte: real);
begin
  inherited Create(xperiodo, xclavecta, xidtitular, '', xidc, xtipo, xsucursal, xnumero, xtm, xfecha, xfealta, xobs, xconcepto, ximporte);

  tabla2 := datosdb.openDB('ctactecf.DB', 'Idcompr;Tipo;Sucursal;Numero');
  tabla3 := datosdb.openDB('ctactecl.DB', 'Idtitular;Clavecta;Idcompr;Tipo;Sucursal;Numero;Items');
end;

destructor TTCInscriptos.Destroy;
begin
  desconectar;
  inherited Destroy;
end;

//------------------------------------------------------------------------------

function TTCInscriptos.Verifalumno(xcodcli: string): boolean;
// Objetivo...: Verificamos que el proveedor ingresado Exista
begin
  if alumno.Buscar(xcodcli) then Result := True else Result := False;
end;

function TTCInscriptos.getalumno(xcodcli: string): string;
// Objetivo...: Recuperamos el alumno titular de la Cuenta
begin
  alumno.getDatos(xcodcli);
  Result := alumno.getNombre;
end;

function TTCInscriptos.getTalumno: TTable;
// Objetivo...: Retornamos la tabla de alumno
begin
  Result := alumno.tperso;
end;

function TTCInscriptos.getUltimoPago: string;
// Objetivo...: retornar la fecha del último pago efectuado
begin
  Result := utiles.sFormatoFecha(ultimopago);
end;

function TTCInscriptos.getSaldo(xid, xfecha: string): real;
// Objetivo...: devolver el saldo de la cuenta de un alumno
begin
  TSQL := datosdb.tranSQL('SELECT ctactecl.tipo, ctactecl.fecha, ctactecl.idtitular, ctactecl.clavecta, ctactecl.DC, ctactecl.Items, ctactecl.importe FROM ctactecl WHERE fecha <= ' + '''' + utiles.sExprFecha(xfecha) + '''');
  ObtenerSaldo(xid);
  Result := td - th;
end;

function TTCInscriptos.getFactventa(xidc, xtipo, xsucursal, xnumero: string): TQuery;
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
      Result  := getPlan(clavecta, idtitular, xidc, xtipo, xsucursal, xnumero);
    end
  else
    begin
      TransferirDatos(False);
      Result := nil;
    end;
end;

procedure TTCInscriptos.GrabarTran(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto: string; ximporte, xentrega, xcuota: real);
// Objetivo...: Grabar los movimientos Generados a partir de los planes, cobros/o pagos efectuados
begin
  if xitems = '-1' then GrabarFact(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm, ximporte, xentrega);
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then
    begin
      if xitems > '000' then tabla3.Edit;
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

procedure TTCInscriptos.BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
// Objetivo...: Eliminar detalle del comprobante
begin
  datosdb.tranSQL('DELETE FROM ctactecl WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''' +
                    ' AND idcompr = ' + '''' + xidc + '''' + ' AND tipo = ' + '''' + xtipo + '''' + ' AND sucursal = ' + '''' + xsucursal + '''' + ' AND numero = ' + '''' + xnumero + '''');
end;

procedure TTCInscriptos.BorrarDet(xclavecta, xidtitular: string);
// Objetivo...: Eliminar un comprobante - detalle y relaciones
begin
  datosdb.tranSQL('DELETE FROM ctactecf WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''');
  datosdb.tranSQL('DELETE FROM ctactecl WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''');
  getDatos(tabla2.FieldByName('clavecta').AsString, tabla2.FieldByName('idtitular').AsString, tabla2.FieldByName('idcompr').AsString, tabla2.FieldByName('tipo').AsString, tabla2.FieldByName('sucursal').AsString, tabla2.FieldByName('numero').AsString, tabla2.FieldByName('DC').AsString);
end;

procedure TTCInscriptos.GrabarPago(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xtm, xconcepto: string; ximporte, xentrega, xcuota, xrecargo: real; ftc, fti, fsu, fnu, fit: string);
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
    // Si el monto ingresado es igual al de la Cuota, marcamos la misma como paga
    MarcarCuotaPaga(xperiodo, xclavecta, xidtitular, ftc, fti, fsu, fnu, xitems, ximporte, xcuota);
  except
    tabla3.Cancel;
  end;
  importe_cuota := ximporte;
  tabla3.Filtered := True;
end;

procedure TTCInscriptos.MarcarCuotaPaga(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string; ximporte, xcuota: real);
// Objetivo...: Marcar una cuota como paga
var
  importe_cuota: real;
begin
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then
   begin
     importe_cuota := ximporte;
     tabla3.Edit;
     importe_cuota := RecalcularEntregas(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems); // Determino si el pago fue total o parcial
     if importe_cuota = tabla3.FieldByName('importe').AsFloat then tabla3.FieldByName('estado').AsString := 'P' else tabla3.FieldByName('estado').AsString := 'I';
     tabla3.FieldByName('entrega').AsFloat := importe_cuota;
     try
       tabla3.Post;
     except
       tabla3.Cancel;
     end;
   end;
end;

function TTCInscriptos.RecalcularEntregas(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string): real;
// Objetivo...: obtener el total pagado para una factura
begin
  datosdb.tranSQL('SELECT SUM(importe) FROM ctactecl WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''' +
                  ' AND xc = ' + '''' + xidc + '''' + ' AND xt = ' + '''' + xtipo + '''' + ' AND xs = ' + '''' + xsucursal + '''' + ' AND xn = ' + '''' + xnumero + '''' + ' AND items = ' + '''' + xitems + '''');
  datosdb.setSQL.Open;
  Result := datosdb.setSQL.Fields[0].AsFloat;
end;

procedure TTCInscriptos.BorrarPago(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string);
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
     montocuota := RecalcularEntregas(xperiodo, xclavecta, xidtitular, xxc, xxt, xxs, xxn, xitems);

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

function TTCInscriptos.GrabarFact(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm: string; ximporte, xentrega: real): boolean;
// Objetivo...: Grabar una Factura
begin
  if datosdb.Buscar(tabla2, 'idcompr', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero) then tabla2.Edit else tabla2.Append;
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

function TTCInscriptos.getPagos(xclavecta, xidtitular: string): TQuery;
// Objetivo...: Devolver un Set de las Cuentas Corrientes Disponibles para un titular
begin
  Result := datosdb.tranSQL('SELECT * FROM ctactecl WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''' + ' ORDER BY fecha');
end;

function TTCInscriptos.getRecibos(xclavecta, xidtitular: string): TQuery;
// Objetivo...: Devolver un Set de los Recibos Ingresados
begin
  Result := datosdb.tranSQL('SELECT * FROM ctactecl WHERE clavecta = ' + '''' + xclavecta + '''' + ' AND idtitular = ' + '''' + xidtitular + '''' + ' AND estado = ' + '''' + 'R' + '''' + ' ORDER BY fecha');
end;

procedure TTCInscriptos.Depurar(fecha: string);
// Objetivo...: depurar los movimientos de cuenta corriente
var
  r: TQuery;
  xco, xti, xsu, xnu, xtt, xcl: string;
begin
  // Aislamos los comprobantes cancelados - Cuotas Pagas
  r := datosdb.tranSQL('SELECT * FROM ctactecl WHERE estado = ' + '''' + 'P' + '''' + ' AND fecha < ' + '''' + utiles.sExprFecha(fecha) + '''');
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

function TTCInscriptos.getCantidadAlumnos(xidalumno: string): integer;
// Objetivo...: Devolver la cantidad de alumnos para un curso
begin
  datosdb.tranSQL('SELECT * FROM inscrip WHERE idalumno = ' + '''' + xidalumno + '''');
  datosdb.setSQL.Open;
  Result := datosdb.setSQL.RecordCount;
  datosdb.setSQL.Close;
end;

function TTCInscriptos.getCantidadCursos(xidcurso: string): integer;
// Objetivo...: Devolver la cantidad de alumnos para un curso
begin
  datosdb.tranSQL('SELECT * FROM inscrip WHERE codcurso = ' + '''' + xidcurso + '''');
  datosdb.setSQL.Open;
  Result := datosdb.setSQL.RecordCount;
  datosdb.setSQL.Close;
end;

function TTCInscriptos.VerifMovimiento(xcodcurso: string): boolean;
// Objetivo...: Verificar si existen movimientos para un curso dado
begin
  Result := True;
  tabla3.First;
  while not tabla3.EOF do
    begin
      if tabla3.FieldByName('clavecta').AsString = xcodcurso then
        begin
          Result := False;
          Break;
        end;
      tabla3.Next;
    end;
end;

procedure TTCInscriptos.rSubtotales(salida: char);
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

procedure TTCInscriptos.TitulosResctas(salida: char);
// Objetivo...: Titulos del resumen de cuentas corrientes de Proveedores
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Resumen de Cuentas Corrientes de alumno', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(17, List.lineactual, 'Comprobante                   Concepto Operación', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Debe', 3, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'Haber', 4, 'Arial, cursiva, 8');
  List.Titulo(95, List.lineactual, 'Saldo', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTCInscriptos.rListarRes(xidtitular, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de alumno con ruptura por alumno
var
  indice, claveanterior: string;
begin
  indice := tabla3.IndexFieldNames;

  TitulosResctas(salida);

  tabla3.IndexName := 'Listado';

  saldo := 0; saldoanter := 0; td := 0; th := 0; idant := ''; clant := '';

  tabla3.First;
  claveanterior := tabla3.FieldByName('clavecta').AsString;
  while not tabla3.EOF do
    begin
      if (tabla3.FieldByName('idtitular').AsString = xidtitular) then
        begin
          if (tabla3.FieldByName('items').AsString > '-1') and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then {(Length(Trim(tabla3.FieldByName('XN').AsString)) > 0) or (tabla3.FieldByName('tipo').AsString = 'I') then}
            begin
              if tabla3.FieldByName('DC').AsString = '1' then saldo := saldo + tabla3.FieldByName('importe').AsFloat;
              if tabla3.FieldByName('DC').AsString = '2' then saldo := saldo - tabla3.FieldByName('importe').AsFloat;
            end;
          if ((tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar))) then
            if tabla3.FieldByName('items').AsString > '-1' then cList_Linea(salida);
        end;

      claveanterior := tabla3.FieldByName('clavecta').AsString;
      tabla3.Next;
    end;

  if td + th <> 0 then rSubtotales(salida);

  List.FinList;

  tabla3.IndexFieldNames := indice;
end;

procedure TTCInscriptos.cList_linea(salida: char);
// Objetivo...: Listar una Línea ruptura por alumno
begin
  if tabla3.FieldByName('DC').AsString = '1' then td := td + tabla3.FieldByName('importe').AsFloat;
  if tabla3.FieldByName('DC').AsString = '2' then th := th + tabla3.FieldByName('importe').AsFloat;

  if tabla3.FieldByName('idtitular').AsString <> idant then
    begin
      // Subtotal
      if idant <> '' then rSubtotales(salida);

      alumno.getDatos(tabla3.FieldByName('idtitular').AsString);
      defcurso.getDatos(tabla3.FieldByName('clavecta').AsString);
      if tabla3.FieldByName('idtitular').AsString <> idant then List.Linea(0, 0, 'Alumno: ' + tabla3.FieldByName('idtitular').AsString + '-' + alumno.getNombre, 1, 'Arial, negrita, 11', salida, 'N') else List.Linea(0, 0, ' ', 1, 'Arial, negrita, 11', salida, 'N');
      List.Linea(57, list.lineactual, 'Curso: ' + tabla3.FieldByName('clavecta').AsString + '-' + defcurso.getCurso, 2, 'Arial, negrita, 11', salida, 'S');
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

procedure TTCInscriptos.rListar(xidtitular, xidcurso, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de alumno con ruptura por cuenta
var
  indice: string;
begin
  indice := tabla3.IndexFieldNames;

  TitulosResctas(salida);

  tabla3.IndexName := 'Listado';

  saldo := 0; td := 0; th := 0; idant := ''; clant := '';

  tabla3.First;
  while not tabla3.EOF do
    begin
      if (tabla3.FieldByName('idtitular').AsString = xidtitular) and (tabla3.FieldByName('clavecta').AsString = xidcurso) then
        begin
          if (tabla3.FieldByName('items').AsString > '-1') and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then {(Length(Trim(tabla3.FieldByName('XN').AsString)) > 0) or (tabla3.FieldByName('tipo').AsString = 'I') then}
            begin
              if tabla3.FieldByName('DC').AsString = '1' then saldo := saldo + tabla3.FieldByName('importe').AsFloat;
              if tabla3.FieldByName('DC').AsString = '2' then saldo := saldo - tabla3.FieldByName('importe').AsFloat;
            end;
          if ((tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar))) then
            if tabla3.FieldByName('items').AsString > '-1' then rList_Linea(salida);
        end;

      tabla3.Next;
    end;

  if td + th <> 0 then rSubtotales(salida);

  List.FinList;

  tabla3.IndexFieldNames := indice;
end;

procedure TTCInscriptos.rList_linea(salida: char);
// Objetivo...: Listar una Línea ruptura por alumno
begin
  if tabla3.FieldByName('DC').AsString = '1' then td := td + tabla3.FieldByName('importe').AsFloat;
  if tabla3.FieldByName('DC').AsString = '2' then th := th + tabla3.FieldByName('importe').AsFloat;

  if (tabla3.FieldByName('idtitular').AsString <> idant) or (tabla3.FieldByName('clavecta').AsString <> clant) then
    begin
      // Subtotal
      if idant <> '' then rSubtotales(salida);

      alumno.getDatos(tabla3.FieldByName('idtitular').AsString);
      defcurso.getDatos(tabla3.FieldByName('clavecta').AsString);
      if tabla3.FieldByName('idtitular').AsString <> idant then List.Linea(0, 0, 'Alumno: ' + tabla3.FieldByName('idtitular').AsString + '-' + alumno.getNombre, 1, 'Arial, negrita, 11', salida, 'N') else List.Linea(0, 0, ' ', 1, 'Arial, negrita, 11', salida, 'N');
      List.Linea(57, list.lineactual, 'Curso: ' + tabla3.FieldByName('clavecta').AsString + '-' + defcurso.getCurso, 2, 'Arial, negrita, 11', salida, 'S');
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

procedure TTCInscriptos.rListarPlan(xidtitular, xidcurso, iniciar, finalizar: string; salida: char);
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

  saldo := 0; td := 0; th := 0; idant := ''; clant := ''; t := ''; total := 0; recar := 0; saldoanter := 0;

  tabla3.First;

  while not tabla3.EOF do
    begin
      if (tabla3.FieldByName('idtitular').AsString = xidtitular) and (tabla3.FieldByName('clavecta').AsString = xidcurso) then
        begin
         if Length(trim(t)) = 0 then t := tabla3.FieldByName('DC').AsString;
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

    List.FinList;

    tabla3.IndexFieldNames := indice;
end;

procedure TTCInscriptos.List_LineaPlan(salida: char);
// Objetivo...: Listar una Línea
begin
  if (tabla3.FieldByName('idtitular').AsString <> idant) or (tabla3.FieldByName('clavecta').AsString <> clant) then
    begin
      // Subtotal
      if idant <> '' then rSubtotales(salida);
      alumno.getDatos(tabla3.FieldByName('idtitular').AsString);
      defcurso.getDatos(tabla3.FieldByName('clavecta').AsString);
      List.Linea(0, 0, 'Alumno: ' + tabla3.FieldByName('idtitular').AsString + '-' + alumno.getNombre, 1, 'Arial, negrita, 11', salida, 'N');
      List.Linea(57, list.lineactual, 'Curso: ' + tabla3.FieldByName('clavecta').AsString + '-' + defcurso.getCurso, 2, 'Arial, negrita, 11', salida, 'S');
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

procedure TTCInscriptos.rSubtotales1(salida: char; t: string);
// Objetivo...: Emitir Subtotales
var
  l: string;
begin
  if t <= '1' then l := 'Total de cuotas ......:' else l := 'Total Pagado .....:';
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

procedure TTCInscriptos.tot_deuda(salida: char);
// Objetivo...: subtotalizar una deuda para un alumno
begin
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
  List.derecha(95, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total Deuda .....: ', 1, 'Arial, negrita, 8', salida, 'S');
  List.importe(95, list.lineactual, '', total, 2, 'Arial, negrita, 8');
  List.Linea(100, List.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  total := 0;
end;

procedure TTCInscriptos.ListarVencimientos(fecha: string; salida: char);
// Objetivo...: Listar los vencimientos de Cuentas Corrientes
var
  pr, clant: string;
begin
  TSQL := datosdb.tranSQL('SELECT * FROM ctactecl WHERE fecha <= ' + '''' + utiles.sExprFecha(fecha) + '''' + ' AND estado = ' + '''' + 'I' + '''' + ' AND items >= ' + '''' + '000' + '''' + ' ORDER BY fecha');

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Listado de Venciemientos de Pagos de alumno', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Vencimientos al ' + fecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, List.lineactual, 'Cód. Id.', 2, 'Arial, cursiva, 8');
  List.Titulo(20, List.lineactual, 'Nombre', 3, 'Arial, cursiva, 8');
  List.Titulo(60, List.lineactual, 'Domicilio', 4, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Monto', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  recar := 0; total := 0;

  TSQL.Open;
  alumno.tperso.First;
  while not alumno.tperso.EOF do
    begin
      if alumno.tperso.FieldByName('sel').AsString = 'X' then
        begin
          TSQL.First;
          clant := alumno.tperso.FieldByName('idalumno').AsString; //TSQL.FieldByName('idtitular').AsString;
          while not TSQL.EOF do
            begin
              if alumno.tperso.FieldByName('idalumno').AsString = TSQL.FieldByName('idtitular').AsString then
                begin
                  pr := alumno.tperso.FieldByName('nombre').AsString;

                  if TSQL.FieldByName('idtitular').AsString <> clant then tot_deuda(salida);

                  List.Linea(0, 0, utiles.sFormatoFecha(TSQL.FieldByName('fecha').AsString) + '  ' + TSQL.FieldByName('idtitular').AsString + '-' + TSQL.FieldByName('clavecta').AsString, 1, 'Arial, normal, 8', salida, 'N');
                  List.Linea(20, list.lineactual, pr, 2, 'Arial, normal, 8', salida, 'N');
                  List.Linea(60, list.lineactual, alumno.tperso.FieldByName('domicilio').AsString, 3, 'Arial, normal, 8', salida, 'N');
                  List.importe(95, list.lineactual, '', (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat), 4, 'Arial, normal, 8');
                  List.Linea(98, List.lineactual, ' ', 5, 'Arial, normal, 8', salida, 'S');
                  recar := recar + (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat);
                  total := total + (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat);
                  clant := TSQL.FieldByName('idtitular').AsString;
                end;
              TSQL.Next;
            end;
        end;
      alumno.tperso.Next;
    end;

    tot_deuda(salida);

    // Listamos un total general de deudas
    List.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
    List.Linea(0, 0, 'Monto total de vencimientos .....:    ' +  utiles.FormatearNumero(FloatToStr(recar)), 1, 'Arial, normal, 10', salida, 'S');

    List.FinList;
end;

procedure TTCInscriptos.ObtenerSaldo(xidtitular: string);
// Objetivo...: Calcular el saldo para una cuenta dada
begin
  td := 0; th := 0;
  TSQL.Open; TSQL.First;
  while not TSQL.EOF do
    begin
      if (TSQL.FieldByName('idtitular').AsString = xidtitular) then
        begin
          if (TSQL.FieldByName('items').AsString > '-1')  and (TSQL.FieldByName('DC').AsString = '1') then td := td + TSQL.FieldByName('importe').AsFloat;
          if TSQL.FieldByName('DC').AsString = '2' then
            begin
              ultimopago := TSQL.FieldByName('fecha').AsString;
              th := th + TSQL.FieldByName('importe').AsFloat;
            end;
        end;
      TSQL.Next;
    end;
end;

procedure TTCInscriptos.ListPlanillaSaldos(fecha: string; salida: char);
// Objetivo...: Listar saldos individuales por cuenta
var
  clant: string;
begin
  TSQL := datosdb.tranSQL('SELECT ctactecl.tipo, ctactecl.fecha, ctactecl.idtitular, ctactecl.clavecta, ctactecl.DC, ctactecl.Items, ctactecl.importe FROM ctactecl WHERE fecha <= ' + '''' + utiles.sExprFecha(fecha) + '''');

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Planilla de Saldos de alumno', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Saldos al ' + fecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.       Alumno', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Dirección', 2, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Saldo', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  total := 0;
  alumno.tperso.First;
  while not alumno.tperso.EOF do
    begin
      if alumno.tperso.FieldByName('sel').AsString = 'X' then
        begin
          ObtenerSaldo(alumno.tperso.FieldByName('idalumno').AsString);

          List.Linea(0, 0, alumno.tperso.FieldByName('idalumno').AsString + '  ' + alumno.tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
          List.Linea(40, list.Lineactual, alumno.tperso.FieldByName('domicilio').AsString, 2, 'Arial, normal, 8', salida, 'N');
          List.importe(95, list.lineactual, '', td - th, 3, 'Arial, normal, 8');
          List.Linea(98, List.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
          total := total + (td - th);
        end;
      alumno.tperso.Next;
    end;

    TSQL.Close;

    list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
    list.derecha(95, list.lineactual, '##############', '--------------', 2, 'Arial, normal, 8');
    list.Linea(0, 0, 'Total ........: ', 1, 'Arial, normal, 8', salida, 'N');
    list.importe(95, list.lineactual, '', total, 2, 'Arial, normal, 8');
    list.Linea(98, list.lineactual, '  ', 3, 'Arial, normal, 8', salida, 'S');

    List.FinList;

    alumno.desconectar;
    alumno.conectar;
end;

function TTCInscriptos.getMcctcl: TQuery;
// Objetivo...: Devolver un set con los registros registrados
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.idtitular, ctactecl.clavecta, ctactecl.idcompr AS IDC, ctactecl.tipo AS Tipo, ctactecl.sucursal AS Sucur, ctactecl.numero AS Numero, alumno.nombre, ctactecl.concepto AS Concepto, ctactecl.importe AS Importe ' +
               'FROM ctactecl, alumno WHERE ctactecl.idtitular = alumno.codcli AND ctactecl.items = ' + '''' + '-1' + '''' + ' ORDER BY ctactecl.fecha');
end;

function TTCInscriptos.getMcctcl(xt: string): TQuery;
// Objetivo...: Devolver un set con los registros registrados
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.idtitular, ctactecl.clavecta, ctactecl.idcompr AS IDC, ctactecl.tipo AS Tipo, ctactecl.sucursal, ctactecl.numero AS Numero, ctactecl.DC, alumnos.nombre, ctactecl.concepto AS Concepto, ctactecl.importe AS Importe, ' +
               ' ctactecl.items, ctactecl.estado, ctactecl.entrega FROM ctactecl, alumnos WHERE ctactecl.idtitular = alumnos.idalumno ' +
               ' AND ctactecl.idtitular = ' + '''' + xt + '''' + ' ORDER BY ctactecl.fecha');
end;

function TTCInscriptos.getMcctcl(xt, xc: string): TQuery;
// Objetivo...: Devolver un set con el registro de pago de un alumno y un curso dado
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.idtitular, ctactecl.clavecta, ctactecl.idcompr AS IDC, ctactecl.tipo AS Tipo, ctactecl.sucursal, ctactecl.numero AS Numero, ctactecl.DC, alumnos.nombre, ctactecl.concepto AS Concepto, ctactecl.importe AS Importe, ' +
               ' ctactecl.items, ctactecl.estado, ctactecl.entrega FROM ctactecl, alumnos WHERE ctactecl.idtitular = alumnos.idalumno ' +
               ' AND ctactecl.idtitular = ' + '''' + xt + '''' +  ' AND ctactecl.clavecta = ' + '''' + xc + '''' + ' ORDER BY ctactecl.fecha');
end;

procedure TTCInscriptos.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    alumno.conectar;
    defcurso.conectar;
    if not tabla3.Active then
      begin
        tabla3.Open;
        tabla3.FieldByName('periodo').Visible := False; tabla3.FieldByName('idtitular').Visible := False; tabla3.FieldByName('clavecta').Visible := False;
      end;
    if not tabla2.Active then tabla2.Open;
  end;
  Inc(conexiones);
end;

procedure TTCInscriptos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    alumno.desconectar;
    defcurso.desconectar;
    datosdb.closeDB(tabla2);
    datosdb.closeDB(tabla3);
  end;
end;

{===============================================================================}

function ccins: TTCInscriptos;
begin
  if xctactecl = nil then
    xctactecl := TTCInscriptos.Create('', '', '', '', '', '', '', '', '', '', '', '', 0);
  Result := xctactecl;
end;

{===============================================================================}

initialization

finalization
  xctactecl.Free;

end.
