unit CCInscr1;

interface

uses SysUtils, DB, DBTables, CBDT, CCtactes, CAlumno, CDefcurs, CListar, CUtiles, CIDBFM;

type

TTCInscriptos = class(TTCtacte)            // Superclase
 public
  { Declaraciones Públicas }
  constructor Create(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xtm, xfecha, xfealta, xobs, xconcepto: string; ximporte: real);
  destructor  Destroy; override;

  function    Verifalumno(xcodcli: string): boolean;
  function    getalumno(xcodcli: string): string;
  function    getTalumno: TTable;

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
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   rListar(iniciar, finalizar: string; salida: char);
  procedure   rListarPlan(iniciar, finalizar: string; salida: char);
  procedure   rSubtotales(salida: char);
  procedure   rSubtotales1(salida: char; t: string);
  procedure   ObtenerSaldo(xidtitular, xclavecta: string);
  procedure   rList_Linea(salida: char);
  procedure   List_LineaPlan(salida: char);
  procedure   ListarVencimientos(fecha: string; salida: char);
  procedure   ListPlanillaSaldos(fecha: string; salida: char);
  procedure   rListarRes(iniciar, finalizar: string; salida: char);
  function    getMcctcl: TQuery; overload;
  function    getMcctcl(xt, xc: string): TQuery; overload;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  iss, s_dep: boolean;
  importe_cuota: real;
  procedure dep_cctcl;
  procedure tot_deuda(salida: char);
  procedure List_linea(salida: char);
  procedure TitulosResctas(salida: char);
  procedure BorrarDetalle(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
end;

function ccins: TTCInscriptos;

implementation

var
  xctactecl: TTCInscriptos = nil;

constructor TTCInscriptos.Create(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xtm, xfecha, xfealta, xobs, xconcepto: string; ximporte: real);
begin
  inherited Create(xperiodo, xclavecta, xidtitular, '', xidc, xtipo, xsucursal, xnumero, xtm, xfecha, xfealta, xobs, xconcepto, ximporte);

  tabla1 := datosdb.openDB('cctcl.DB', 'Idtitular;Clavecta');
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

procedure TTCInscriptos.dep_cctcl;
// Objetivo...: Determinar y Eliminar las operaciones
var
  xco, xti, xsu, xnu, xtt, xcl: string;
  monto1, monto2: real;
begin
  s_dep := False;
  // Extraemos la información del comprobante
  xco := tabla3.FieldByName('idcompr').AsString;
  xti := tabla3.FieldByName('tipo').AsString;
  xsu := tabla3.FieldByName('sucursal').AsString;
  xnu := tabla3.FieldByName('numero').AsString;
  xtt := tabla3.FieldByName('idtitular').AsString;
  xcl := tabla3.FieldByName('clavecta').AsString;
  // Obtenemos los montos - pagados y el total facturado para verificar si se puede dar de baja
  monto1 := tabla3.FieldByName('importe').AsFloat;

  datosdb.tranSQL('SELECT SUM(importe) FROM ctactecl WHERE XC = ' + '''' + xco + '''' + ' AND XT = ' + '''' + xti + '''' + ' AND XS = ' + '''' + xsu + '''' + ' AND XN = ' + '''' + xnu + '''' + ' AND idtitular = ' + '''' + xtt + '''' + ' AND clavecta = ' + '''' + xcl + '''' + ' AND DC = ' + '''' + '2' + '''');
  monto2 := datosdb.setSQL.Fields[0].AsFloat;

  if monto1 = monto2 then      // Si son iguales quiere decir que la cuenta está saldada
    begin
      // Eliminamos recibo y entrega inicial
      datosdb.tranSQL('DELETE FROM ctactecl WHERE XC = ' + '''' + xco + '''' + ' AND XT = ' + '''' + xti + '''' + ' AND XS = ' + '''' + xsu + '''' + ' AND XN = ' + '''' + xnu + '''' + ' AND idtitular = ' + '''' + xtt + '''' + ' AND clavecta = ' + '''' + xcl + '''' + ' AND DC = ' + '''' + '2' + '''');
      // Eliminamos Factura
      datosdb.tranSQL('DELETE FROM ctactecl WHERE idcompr = ' + '''' + xco + '''' + ' AND tipo = ' + '''' + xti + '''' + ' AND sucursal = ' + '''' + xsu + '''' + ' AND numero = ' + '''' + xnu + '''' + ' AND idtitular = ' + '''' + xtt + '''' + ' AND clavecta = ' + '''' + xcl + '''' + ' AND DC = ' + '''' + '1' + '''');
      // Eliminamos los saldos iniciales Pagados
      datosdb.tranSQL('DELETE FROM ctactecl WHERE idtitular = ' + '''' + xtt + '''' + ' AND clavecta = ' + '''' + xcl + '''' + ' AND estado = ' + '''' + 'P' + '''' + ' AND idcompr = ' + '''' + 'SIN' + '''');
      s_dep := True;
    end;
end;

procedure TTCInscriptos.Depurar(fecha: string);
// Objetivo...: depurar los movimientos de cuenta corriente
begin
  tabla3.First;
  while not tabla3.EOF do
    begin
      if (tabla3.FieldByName('XN').AsString = 'FACT.ORI') and (tabla3.FieldByName('fecha').AsString < utiles.sExprFecha(fecha)) then
        begin
          dep_cctcl;
          if s_dep then tabla3.First;    // Recomenzamos el proceso
          if not s_dep then tabla3.Next;
        end
      else
        tabla3.Next;

      if tabla3.EOF then Break;   // interrumpimos
    end;
end;

procedure TTCInscriptos.List_linea(salida: char);
// Objetivo...: Listar una Línea
var
  pr: string;
begin
  alumno.Buscar(tabla1.FieldByName('idtitular').AsString);
  if tabla1.FieldByName('idtitular').AsString <> idant then pr := alumno.tperso.FieldByName('nombre').AsString else pr := ' ';
  List.Linea(0, 0, tabla1.FieldByName('idtitular').AsString + ' ' + tabla1.FieldByName('clavecta').AsString + '    ' + pr, 1, 'Courier New, normal, 8', salida, 'N');
  List.Linea(57, List.lineactual, tabla1.FieldByName('obs').AsString, 2, 'Courier New, normal, 8', salida, 'N');
  List.Linea(90, List.lineactual, utiles.sFormatoFecha(tabla1.FieldByName('fealta').AsString), 3, 'Courier New, normal, 8', salida, 'S');
  idant := tabla1.FieldByName('idtitular').AsString;
end;

procedure TTCInscriptos.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de alumnoes Definidas
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Listado de Cuentas Corrientes de alumno', 1, 'Arial, negrita, 14');
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

procedure TTCInscriptos.rList_linea(salida: char);
// Objetivo...: Listar una Línea
var
  pr: string;
begin
  if tabla3.FieldByName('DC').AsString = '1' then td := td + tabla3.FieldByName('importe').AsFloat;
  if tabla3.FieldByName('DC').AsString = '2' then th := th + tabla3.FieldByName('importe').AsFloat;

  if (tabla3.FieldByName('idtitular').AsString <> idant) or (tabla3.FieldByName('clavecta').AsString <> clant) then
    begin
      // Subtotal
      if idant <> '' then rSubtotales(salida);

      alumno.Buscar(tabla3.FieldByName('idtitular').AsString);
      pr := alumno.tperso.FieldByName('nombre').AsString;
      List.Linea(0, 0, 'Cuenta: ' + tabla3.FieldByName('idtitular').AsString + '-' + tabla3.FieldByName('clavecta').AsString + '    ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      List.Linea(0, 0, utiles.espacios(140) + 'Saldo Anterior ....: ', 1, 'Arial, cursiva, 8', salida, 'S');
      if tabla3.FieldByName('DC').AsString = '1' then saldoanterior := saldo - tabla3.FieldByName('importe').AsFloat else saldoanterior := saldo + tabla3.FieldByName('importe').AsFloat;
      List.importe(100, list.lineactual, '', saldoanterior, 2, 'Arial, cursiva, 8');
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

procedure TTCInscriptos.List_LineaPlan(salida: char);
// Objetivo...: Listar una Línea
var
  pr: string;
begin
  total := total + tabla3.FieldByName('importe').AsFloat;
  recar := recar + tabla3.FieldByName('recargo').AsFloat;
  if tabla3.FieldByName('DC').AsString = '1' then td := td + tabla3.FieldByName('importe').AsFloat;
  if tabla3.FieldByName('DC').AsString = '2' then th := th + tabla3.FieldByName('importe').AsFloat;

  if (tabla3.FieldByName('idtitular').AsString <> idant) or (tabla3.FieldByName('clavecta').AsString <> clant) then
    begin
      // Subtotal
      if idant <> '' then rSubtotales(salida);
      alumno.Buscar(tabla3.FieldByName('idtitular').AsString);
      pr := alumno.tperso.FieldByName('nombre').AsString;
      List.Linea(0, 0, 'Cuenta: ' + tabla3.FieldByName('idtitular').AsString + '-' + tabla3.FieldByName('clavecta').AsString + '    ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      List.Linea(0, 0, utiles.espacios(140) + 'Saldo Anterior ....: ', 1, 'Arial, cursiva, 8', salida, 'S');
      List.importe(95, list.lineactual, '', saldoanterior, 2, 'Arial, cursiva, 8');
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

procedure TTCInscriptos.rSubtotales1(salida: char; t: string);
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

procedure TTCInscriptos.rListar(iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de alumno con ruptura por cuenta
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
                   if ((tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) and ((Length(Trim(tabla3.FieldByName('XN').AsString)) > 0))) or (tabla3.FieldByName('tipo').AsString = 'I') then rList_Linea(salida);
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

procedure TTCInscriptos.rListarRes(iniciar, finalizar: string; salida: char);
// Objetivo...: Listar Cuentas Corrientes de alumno con ruptura por alumno
var
  indice, claveanterior: string;
begin
  indice := tabla3.IndexFieldNames;

  TitulosResctas(salida);

  tabla3.IndexName := 'Listado';

  tabla1.First;
  while not tabla1.EOF do
    begin
      if (tabla1.FieldByName('sel').AsString = 'X') and (tabla1.FieldByName('sel').AsString <> claveanterior) then
        begin
           saldo := 0; saldoanterior := 0; td := 0; th := 0; idant := ''; clant := '';

           tabla3.First;
           while not tabla3.EOF do
             begin
               if (tabla3.FieldByName('idtitular').AsString = tabla1.FieldByName('idtitular').AsString) then
                 begin
                   if (tabla3.FieldByName('DC').AsString = '1') and (tabla3.FieldByName('items').AsString = '-1') then saldo := saldo + tabla3.FieldByName('importe').AsFloat;
                   if tabla3.FieldByName('DC').AsString = '2' then saldo := saldo - tabla3.FieldByName('importe').AsFloat;
                   if ((tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) and ((Length(Trim(tabla3.FieldByName('XN').AsString)) > 0))) or (tabla3.FieldByName('tipo').AsString = 'I') then rList_Linea(salida);
                 end;

               tabla3.Next;
             end;

           if td + th <> 0 then rSubtotales(salida);

        end;

      claveanterior := tabla1.FieldByName('idtitular').AsString;
      tabla1.Next;
    end;

    List.FinList;

    tabla3.IndexFieldNames := indice;
end;

procedure TTCInscriptos.rListarPlan(iniciar, finalizar: string; salida: char);
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
           saldo := 0; td := 0; th := 0; idant := ''; clant := ''; total := 0; recar := 0; saldoanterior := 0;

           tabla3.First;
           t := tabla3.FieldByName('DC').AsString;

           while not tabla3.EOF do
             begin
               if (tabla3.FieldByName('idtitular').AsString = tabla1.FieldByName('idtitular').AsString) and (tabla3.FieldByName('clavecta').AsString = tabla1.FieldByName('clavecta').AsString) then
                 begin
                   if tabla3.FieldByName('items').AsString > '000' then
                     begin   // Totales - Debe y Haber
//                       if tabla3.FieldByName('DC').AsString = '1' then td := td + tabla3.FieldByName('importe').AsFloat;
//                       if tabla3.FieldByName('DC').AsString = '2' then th := th + tabla3.FieldByName('importe').AsFloat;
                     end;
                 if tabla3.FieldByName('DC').AsString <> t then
                     begin
                       rSubtotales1(salida, t);
                       List.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
                       total := 0;
                     end;
                   if tabla3.FieldByName('DC').AsString = '1' then iss := False else iss := True;
                   if (tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then
                     if ((tabla3.FieldByName('items').AsString > '000') or (tabla3.FieldByName('items').AsString = '000')) or (tabla3.FieldByName('tipo').AsString = 'I') then List_LineaPlan(salida);
                   saldoanterior := td - th;
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

procedure TTCInscriptos.tot_deuda(salida: char);
// Objetivo...: subtotalizar una deuda para un alumno
begin
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
  List.derecha(90, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total Deuda .....: ', 1, 'Arial, negrita, 8', salida, 'S');
  List.importe(90, list.lineactual, '', total, 2, 'Arial, negrita, 8');
  List.Linea(95, List.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
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
                  alumno.getDatos(TSQL.FieldByName('idtitular').AsString);
                  pr := alumno.getNombre;

                  if TSQL.FieldByName('idtitular').AsString <> clant then tot_deuda(salida);

                  List.Linea(0, 0, utiles.sFormatoFecha(TSQL.FieldByName('fecha').AsString) + '  ' + TSQL.FieldByName('idtitular').AsString + '-' + TSQL.FieldByName('clavecta').AsString + '  ' + pr, 1, 'Arial, normal, 8', salida, 'N');
                  List.Linea(40, list.lineactual, alumno.getDomicilio, 2, 'Arial, normal, 8', salida, 'N');
                  List.importe(90, list.lineactual, '', (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat), 3, 'Arial, normal, 8');
                  List.Linea(95, List.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
                  recar := recar + (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat);
                  total := total + (TSQL.FieldByName('importe').AsFloat - TSQL.FieldByName('entrega').AsFloat);
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

procedure TTCInscriptos.ObtenerSaldo(xidtitular, xclavecta: string);
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

procedure TTCInscriptos.ListPlanillaSaldos(fecha: string; salida: char);
// Objetivo...: Listar saldos individuales por cuenta
var
  pr, clant: string;
begin
  TSQL := datosdb.tranSQL('SELECT ctactecl.tipo, ctactecl.fecha, ctactecl.idtitular, ctactecl.clavecta, ctactecl.DC, ctactecl.Items, ctactecl.importe FROM ctactecl WHERE fecha <= ' + '''' + utiles.sExprFecha(fecha) + '''');

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Planilla de Saldos de alumno', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Saldos al ' + fecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cuenta     Titular', 1, 'Arial, cursiva, 8');
  List.Titulo(87, List.lineactual, 'Saldo', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  total := 0;
  tabla1.First;
  while not tabla1.EOF do
    begin
      if tabla1.FieldByName('sel').AsString = 'X' then
        begin
          ObtenerSaldo(tabla1.FieldByName('idtitular').AsString, tabla1.FieldByName('clavecta').AsString);
          alumno.Buscar(tabla1.FieldByName('idtitular').AsString);
          pr := alumno.tperso.FieldByName('nombre').AsString;

          List.Linea(0, 0, tabla1.FieldByName('idtitular').AsString + '  ' + tabla1.FieldByName('clavecta').AsString + '  ' + pr, 1, 'Arial, normal, 8', salida, 'N');
          List.importe(90, list.lineactual, '', td - th, 2, 'Arial, normal, 8');
          List.Linea(90, List.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
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

function TTCInscriptos.getMcctcl: TQuery;
// Objetivo...: Devolver un set con los registros registrados
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.idtitular, ctactecl.clavecta, ctactecl.idcompr AS IDC, ctactecl.tipo AS Tipo, ctactecl.sucursal AS Sucur, ctactecl.numero AS Numero, alumno.nombre, ctactecl.concepto AS Concepto, ctactecl.importe AS Importe ' +
               'FROM ctactecl, alumno WHERE ctactecl.idtitular = alumno.codcli AND ctactecl.items = ' + '''' + '-1' + '''' + ' ORDER BY ctactecl.fecha');
end;

function TTCInscriptos.getMcctcl(xt, xc: string): TQuery;
// Objetivo...: Devolver un set con el registro de pago de un alumno y un curso dado
begin
  Result := datosdb.tranSQL('SELECT ctactecl.fecha, ctactecl.idtitular, ctactecl.clavecta, ctactecl.idcompr AS IDC, ctactecl.tipo AS Tipo, ctactecl.sucursal, ctactecl.numero AS Numero, ctactecl.DC, alumnos.nombre, ctactecl.concepto AS Concepto, ctactecl.importe AS Importe, ' +
               ' ctactecl.items, ctactecl.estado, ctactecl.entrega FROM ctactecl, alumnos WHERE ctactecl.idtitular = alumnos.idalumno ' +
               ' AND ctactecl.idtitular = ' + '''' + xt + '''' + ' AND ctactecl.clavecta = ' + '''' + xc + '''' +
               ' ORDER BY ctactecl.fecha');
end;

procedure TTCInscriptos.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    alumno.conectar;
    defcurso.conectar;
    if not tabla1.Active then
      begin
        tabla1.Open;
        tabla1.FieldByName('fealta').Visible := False; tabla1.FieldByName('clave').Visible := False; tabla1.FieldByName('sel').Visible := False;
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

procedure TTCInscriptos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    alumno.desconectar;
    defcurso.desconectar;
    datosdb.closeDB(tabla1);
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
