{ Objetivo....: Gestionar los cálculos para Generar los Asientos
  de Rendución y Apertura}
unit CCieCont;

interface

uses CEstFin, CPeriodo, CtrlPer, CPlanctas, CLDiario, SysUtils, DB, DBTables, CBDT, CUtiles, CIDBFM;

type

TTCierreAperturaCont = class(TTEstadosContables)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   PrepararProceso(periodo: string);
  procedure   FinalizarProceso;
  procedure   AsientoCierreCuentasResultados(periodo, feapertura, fecierre: string);
  procedure   AsientoCierreCuentasPatrimoniales(periodo, feapertura, fecierre: string);
  procedure   AsientoDeApertura(periodoanterior, periodo, feapertura, fecierre: string);
  procedure   AnularCierre(xperiodo: string);
 private
  { Declaraciones Privadas }
  procedure   IniciarSaldos;
  procedure   GrabarMovimientoArray(periodo, numeroas, claveas, fecha, codcta, concepto: string; debe, haber: real; items: integer);
  procedure   GrabarMovimientoAsiento(periodo, numeroas, claveas, fecha, codcta, concepto: string; debe, haber: real);
  procedure   GrabarMoviApertura(periodo, claveas, codcta, fecha: string; importe: real);
 protected
  { Declaraciones Protegidas }
end;

function cieapcont: TTCierreAperturaCont;

implementation

var
  xcieapcont: TTCierreAperturaCont = nil;

constructor TTCierreAperturaCont.Create;
begin
  inherited Create;
end;

destructor TTCierreAperturaCont.Destroy;
begin
  inherited Destroy;
end;

procedure TTCierreAperturaCont.PrepararProceso(periodo: string);
// Objetivo...: Preparar el procesamiento de datos
begin
  estcont.Via(vialiq);
  cieapcont.Via(vialiq);
  //ldiario.Via(vialiq);

  planctas.getDatos;
  claveas  := 'AR' + Copy(periodo, 3, 2);
  AnularAsientos(periodo, claveas);
  claveas  := 'AS' + Copy(periodo, 3, 2);
  AnularAsientos(periodo, claveas);
  // Procesamos los Asientos Contables y retenemos los subtotales de cada cuenta
  estcont.PasesDiario_PlanDeCuentas('S', periodo);
end;

procedure TTCierreAperturaCont.FinalizarProceso;
// Objetivo...: Finalizar el procesamiento de datos
begin
  ldiario.desconectar;
  estcont.desconectar;
end;

procedure TTCierreAperturaCont.IniciarSaldos;
// Objetivo...: Inicalizar los saldos
begin
  datosdb.tranSQL(dbconexion, 'DELETE FROM plansaldo');
end;

procedure TTCierreAperturaCont.GrabarMovimientoArray(periodo, numeroas, claveas, fecha, codcta, concepto: string; debe, haber: real; items: integer);
//Grabamos desde el array, primero los movimientos del Debe, despues los del Haber
var
  j: integer;
begin
  //Movimientos del Debe
  For j := 1 to xindice do
    if (ttotdebe[j] - ttothaber[j]) < 0 then GrabarMovimientoAsiento(periodo, numeroas, claveas, fecha, cuenta[j], 'As. Ref. ' + planctas.getCuenta(cuenta[j]), ttotdebe[j], ttothaber[j]);
  //Movimientos del Haber
  For j := 1 to xindice do
    if (ttotdebe[j] - ttothaber[j]) > 0 then GrabarMovimientoAsiento(periodo, numeroas, claveas, fecha, cuenta[j], 'As. Ref. ' + planctas.getCuenta(cuenta[j]), ttotdebe[j], ttothaber[j]);
end;

procedure TTCierreAperturaCont.GrabarMovimientoAsiento(periodo, numeroas, claveas, fecha, codcta, concepto: string; debe, haber: real);
var
  mov, dh: string;
begin
  saldo := debe - haber;
  if saldo > 0 then dh := '1' else dh := '2';
  if saldo < 0 then saldo := saldo * (-1);
  Inc(nro_mov);
  mov := utiles.sLlenarIzquierda(IntToStr(nro_mov), 3, '0');

  ldiario.Grabar(periodo, numeroas, fecha, codcta, mov, concepto, dh, claveas, saldo);

  //Grabamos los saldos de las cuentas del ejercicio actual
  //en la tabla plansaldo para Generar luego, el asiento de apertura
  if (Copy(claveas, 1, 2) = 'AS') and (saldo <> 0) then
    begin
      if datosdb.Buscar(plansaldo, 'codcta', 'periodo', codcta, periodo) then plansaldo.Edit else plansaldo.Append;
      plansaldo.FieldByName('codcta').AsString  := codcta;
      plansaldo.FieldByName('periodo').AsString := periodo;
      plansaldo.FieldByName('importe').AsFloat  := debe - haber;
      try
        plansaldo.Post;
      except
        plansaldo.Cancel;
      end;
    end;
end;

procedure TTCierreAperturaCont.GrabarMoviApertura(periodo, claveas, codcta, fecha: string; importe: real);
var
  mov, dh: string;
begin
  if importe > 0 then
    begin
      dh := '1';
      totdebe := totdebe + importe;
      saldo   := importe;
    end
  else
    begin
      dh := '2';
      tothaber := tothaber + importe;
      saldo    := importe * (-1);
    end;

  Inc(nro_mov);
  mov := utiles.sLlenarIzquierda(IntToStr(nro_mov), 2, '0');

  // Cuenta de Equilibrio
  if plansaldo.FieldByName('codcta').AsString = planctas.Ctaresulta then
    if (totdebe - tothaber) < 0 then dh := '1' else dh := '2';
  ldiario.Grabar(periodo, '0001', fecha, codcta, mov, 'Asiento de Apertura', dh, claveas, saldo);
end;

//******************************************************************************
//GESTION DE ASIENTOS
//Asiento de Refundición de Cuentas de Resultados
procedure TTCierreAperturaCont.AsientoCierreCuentasResultados(periodo, feapertura, fecierre: string);
var
  r: TQuery;
begin
  IniciarArray;
  IniciarSaldos;
  claveas  := 'AR' + Copy(periodo, 3, 2);
  totdebe  := 0; tothaber := 0; xindice := 1;
  numeroas := ldiario.NuevoAsiento;
  estcont.TotalDiario(periodo, feapertura, fecierre, 'P');  // Subtotalizamos los movimientos del diario en el plan de cuentas
  //Recorremos el plan de Cuentas, obtenemos los Saldos de las Cuentas y Generamos el asiento
  r := planctas.setCuentas;
  r.Open; r.First;
  while not r.EOF do
    begin
      idanterior := r.FieldByName('codcta').AsString;
      if (r.FieldByName('imputable').AsString = 'S') and ((Copy(r.FieldByName('codcta').AsString, 1, 1) = planctas.Perdidas) or (Copy(r.FieldByName('codcta').AsString, 1, 1) = planctas.Ganancias)) then
        begin
          totdebe  := totdebe  + r.FieldByName('totaldebe').AsFloat;
          tothaber := tothaber + r.FieldByName('totalhaber').AsFloat;
          //Grabamos los movimientos en los Arrays correspondientes
          cuenta[xindice]    := idanterior;
          ttotdebe[xindice]  := r.FieldByName('totaldebe').AsFloat;
          ttothaber[xindice] := r.FieldByName('totalhaber').AsFloat;
          Inc(xindice);
        end;
        r.Next;
    end;
  //Grabamos los Movimientos Registrados en el array
  GrabarMovimientoArray(periodo, numeroas, claveas, fecierre, idanterior, 'As. Ref. ' + r.FieldByName('cuenta').AsString, r.FieldByName('totaldebe').AsFloat, r.FieldByName('totalhaber').AsFloat, xindice);
  //Grabamos la Cuenta que equilibra los datos
  GrabarMovimientoAsiento(periodo, numeroas, claveas, fecierre, planctas.Ctaresulta, 'Ref. Cuentas de Resultado', totdebe * (-1), tothaber * (-1));
  //Grabamos la Cabecera del Asiento
  ldiario.Grabar(periodo, numeroas, fecierre, 'As. Ref. Cuentas Resultados', claveas);
  r.Close; r.Free;
end;

//Asiento de Refundición de Cuentas Patrimoniales
procedure TTCierreAperturaCont.AsientoCierreCuentasPatrimoniales(periodo, feapertura, fecierre: string);
var
  r: TQuery;
begin
  IniciarArray;
  IniciarSaldos;
  claveas  := 'AS' + Copy(periodo, 3, 2);
  totdebe  := 0; tothaber := 0; xindice := 1;
  numeroas := ldiario.NuevoAsiento;
  estcont.TotalDiario(periodo, feapertura, fecierre, 'P');  // Subtotalizamos los movimientos del diario en el plan de cuentas
  //Recorremos el plan de Cuentas, obtenemos los Saldos de las Cuentas y Generamos el asiento
  r := planctas.setCuentas;
  r.Open; r.First;
  while not r.EOF do
    begin
      idanterior := r.FieldByName('codcta').AsString;
      if (r.FieldByName('imputable').AsString = 'S') and ((Copy(r.FieldByName('codcta').AsString, 1, 1) = planctas.Activo) or (Copy(r.FieldByName('codcta').AsString, 1, 1) = planctas.Pasivo)) then
        begin
          totdebe  := totdebe  + r.FieldByName('totaldebe').AsFloat;
          tothaber := tothaber + r.FieldByName('totalhaber').AsFloat;
          //Grabamos los movimientos en los Arrays correspondientes
          cuenta   [xindice] := idanterior;
          ttotdebe [xindice] := r.FieldByName('totaldebe').AsFloat;
          ttothaber[xindice] := r.FieldByName('totalhaber').AsFloat;
          Inc(xindice);
        end;
      r.Next;
    end;
  r.Close; r.Free;
  //Grabamos los Movimientos Registrados en el array
  GrabarMovimientoArray(periodo, numeroas, claveas, fecierre, idanterior, 'As. Ref. ' + planctas.planctas.FieldByName('cuenta').AsString, planctas.planctas.FieldByName('totaldebe').AsFloat, planctas.planctas.FieldByName('totalhaber').AsFloat, xindice);
  //Grabamos la Cuenta que equilibra los datos
  GrabarMovimientoAsiento(periodo, numeroas, claveas, fecierre, planctas.Ctaresulta, 'Ref. Cuentas Patrimoniales', totdebe * (-1), tothaber * (-1));
  //Grabamos la cabecera del asiento
  ldiario.Grabar(periodo, numeroas, fecierre, 'Ref. Cuentas Patrimoniales', claveas);
  estcont.TotalDiario(periodo, feapertura, fecierre, 'P');  // Subtotalizamos los Nuevos Valores
end;

//Asiento de Apertura de Libros
procedure TTCierreAperturaCont.AsientoDeApertura(periodoanterior, periodo, feapertura, fecierre: string);
begin
  nro_mov  := 0; totdebe := 0; tothaber := 0;
  ///apertura := true;
  IniciarArray;
  claveas  := 'AA' + Copy(periodo, 3, 2);
  AnularAsientos(periodo, claveas);
  plansaldo.First;
  while not plansaldo.EOF do
    begin
      if plansaldo.FieldByName('importe').AsFloat > 0 then
        if plansaldo.FieldByName('periodo').AsString = periodoanterior then GrabarMoviApertura(periodo, claveas, plansaldo.FieldByName('codcta').AsString, feapertura, plansaldo.FieldByName('importe').AsFloat);
      plansaldo.Next;
    end;
  plansaldo.First;
  while not plansaldo.EOF do
    begin
      if plansaldo.FieldByName('importe').AsFloat < 0 then
        if plansaldo.FieldByName('periodo').AsString = periodoanterior then GrabarMoviApertura(periodo, claveas, plansaldo.FieldByName('codcta').AsString, feapertura, plansaldo.FieldByName('importe').AsFloat);
      plansaldo.Next;
    end;
  //Grabamos la cabecera del asiento
  ldiario.Grabar(periodo, '0001', feapertura, 'Asiento de apertura', claveas);
  // Grabamos atributos de control para los casos de la anulación del cierre
  controlper.conectar;
  controlper.Grabar(periodo, periodoanterior);
  controlper.desconectar;
  // Desconectamos tablas de persistencia
  estcont.desconectar;
  cieapcont.desconectar;
  ldiario.desconectar;
end;

// Anular un Cierre de Ejercicio
procedure TTCierreAperturaCont.AnularCierre(xperiodo: string);
var
  xper: string;
begin
  controlper.conectar;
  controlper.getDatos(xperiodo);
  xper := Copy(controlper.getAnterior, 3, 2);
  datosdb.tranSQL(dbconexion, 'DELETE FROM cabasien WHERE periodo = ' + '''' + controlper.getAnterior + '''' + ' AND clave = ' + '''' + 'AA' + xper + '''');
  datosdb.tranSQL(dbconexion, 'DELETE FROM asientos WHERE periodo = ' + '''' + controlper.getAnterior + '''' + ' AND clave = ' + '''' + 'AA' + xper + '''');
  datosdb.tranSQL(dbconexion, 'DELETE FROM cabasien WHERE periodo = ' + '''' + xperiodo + '''' + ' AND clave = ' + '''' + 'AR' + Copy(xperiodo, 3, 2) + '''');
  datosdb.tranSQL(dbconexion, 'DELETE FROM asientos WHERE periodo = ' + '''' + xperiodo + '''' + ' AND clave = ' + '''' + 'AR' + Copy(xperiodo, 3, 2) + '''');
  datosdb.tranSQL(dbconexion, 'DELETE FROM cabasien WHERE periodo = ' + '''' + xperiodo + '''' + ' AND clave = ' + '''' + 'AS' + Copy(xperiodo, 3, 2) + '''');
  datosdb.tranSQL(dbconexion, 'DELETE FROM asientos WHERE periodo = ' + '''' + xperiodo + '''' + ' AND clave = ' + '''' + 'AS' + Copy(xperiodo, 3, 2) + '''');
  per.conectar;
  per.Re_abrir(xperiodo);
  per.Activar(xperiodo, 'S');
  per.Borrar(controlper.getAnterior);
  controlper.Borrar(xperiodo);
end;

{===============================================================================}

function cieapcont: TTCierreAperturaCont;
begin
  if xcieapcont = nil then
    xcieapcont := TTCierreAperturaCont.Create;
  Result := xcieapcont;
end;

{===============================================================================}

initialization

finalization
  xcieapcont.Free;

end.