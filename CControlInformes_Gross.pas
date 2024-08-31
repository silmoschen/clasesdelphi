unit CControlInformes_Gross;

interface

uses CControlCompras_Gross, CControlVentas_Gross, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM,
     CControlHorarios_Gross, CEmpleados_Gross, CControlGastosPersonales_Gross, CCobrosTarjetas_Gross,
     CClienteGross, CTarjetasCredito_Gross;

const
  cantitems = 10;

type

TTInformesControl = class
  largoobsven, largoobscom: Integer;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   InformeIngresosEgresos(xperiodo: String; salida: Char);
  procedure   InformeHorasExtrasPersonal(xperiodo: String; salida: Char);
  procedure   InformeGastosPersonales(xperiodo: String; salida: Char);
  procedure   InformeControlTarjetas(xperiodo: String; salida: char);

  procedure   PresentarInformes;
 private
  { Declaraciones Privadas }
  lini: Boolean;
  totales: array[1..cantitems] of Real;
  procedure totalTarjeta(salida: char);
end;

function infcontrol: TTInformesControl;

implementation

var
  xinfcontrol: TTInformesControl = nil;

constructor TTInformesControl.Create;
begin
  largoobsven := 200;
  largoobscom := 150;
end;

destructor TTInformesControl.Destroy;
begin
  inherited Destroy;
end;

procedure TTInformesControl.InformeIngresosEgresos(xperiodo: String; salida: Char);
// Objetivo.... Listar Ingresos/Egresos
var
  control: TQuery;
  i: Integer;
Begin
  if not lini then list.Setear(salida);
  lini := True;
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'Detalle Ingresos y Egresos - Período: ' + xperiodo, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 5');
  list.Titulo(0, 0, 'Día', 1, 'Arial, cursiva, 8');
  list.Titulo(5, list.Lineactual, 'Items', 2, 'Arial, cursiva, 8');
  list.Titulo(12, list.Lineactual, 'H. Mañana', 3, 'Arial, cursiva, 8');
  list.Titulo(26, list.Lineactual, 'Tarde', 4, 'Arial, cursiva, 8');
  list.Titulo(32, list.Lineactual, 'Vta.Mañana', 5, 'Arial, cursiva, 8');
  list.Titulo(45, list.Lineactual, 'Tarde', 6, 'Arial, cursiva, 8');
  list.Titulo(55, list.Lineactual, 'Observaciones', 7, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

  list.Linea(0, 0, 'Ingresos por Ventas y Honorarios', 1, 'Arial, negrita, 9', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  control := controlvtas.setIngresos(xperiodo);
  control.Open;

  for i := 1 to cantitems do totales[i] := 0;

  while not control.Eof do Begin
    if control.FieldByName('periodo').AsString <> xperiodo then Break;
    list.Linea(0, 0, control.FieldByName('dia').AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(5, list.Lineactual, control.FieldByName('items').AsString, 2, 'Arial, normal, 8', salida, 'N');
    if control.FieldByName('hm').AsFloat = 0 then list.importe(20, list.Lineactual, '####', control.FieldByName('hm').AsFloat, 3, 'Arial, normal, 8') else list.importe(20, list.Lineactual, '', control.FieldByName('hm').AsFloat, 3, 'Arial, normal, 8');
    if control.FieldByName('ht').AsFloat = 0 then list.importe(30, list.Lineactual, '####', control.FieldByName('ht').AsFloat, 4, 'Arial, normal, 8') else list.importe(30, list.Lineactual, '', control.FieldByName('ht').AsFloat, 4, 'Arial, normal, 8');
    if control.FieldByName('vm').AsFloat = 0 then list.importe(40, list.Lineactual, '####', control.FieldByName('vm').AsFloat, 5, 'Arial, normal, 8') else list.importe(40, list.Lineactual, '', control.FieldByName('vm').AsFloat, 5, 'Arial, normal, 8');
    if control.FieldByName('vt').AsFloat = 0 then list.importe(50, list.Lineactual, '####', control.FieldByName('vt').AsFloat, 6, 'Arial, normal, 8') else list.importe(50, list.Lineactual, '', control.FieldByName('vt').AsFloat, 6, 'Arial, normal, 8');
    controlvtas.BuscarObs(control.FieldByName('periodo').AsString, control.FieldByName('dia').AsString, control.FieldByName('items').AsString);
    if control.FieldByName('tob').AsString = '' then list.Linea(51, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S') else list.ListarMemo('obs', 'Arial, normal, 8', controlvtas.obs, largoobsven, 55, 7, salida);
    totales[1] := totales[1] + control.FieldByName('hm').AsFloat;
    totales[2] := totales[2] + control.FieldByName('ht').AsFloat;
    totales[3] := totales[3] + control.FieldByName('vm').AsFloat;
    totales[4] := totales[4] + control.FieldByName('vt').AsFloat;
    control.Next;
  end;
  control.Close; control.Free;

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(15, list.Lineactual, '--------------------------------------------------------------', 2, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Total Ing.:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(20, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
  list.importe(30, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 8');
  list.importe(40, list.Lineactual, '', totales[3], 4, 'Arial, negrita, 8');
  list.importe(50, list.Lineactual, '', totales[4], 5, 'Arial, negrita, 8');
  totales[6] := totales[1] + totales[2] + totales[3] + totales[4];
  list.importe(95, list.Lineactual, '', totales[6], 6, 'Arial, negrita, 8');

  list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');
  list.Linea(0, 0, 'Egresos por Compras y Gastos', 1, 'Arial, negrita, 9', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  control := controlcom.setCompras(xperiodo);
  control.Open;

  for i := 1 to 5 do totales[i] := 0;

  while not control.Eof do Begin
    if control.FieldByName('periodo').AsString <> xperiodo then Break;
    list.Linea(0, 0, control.FieldByName('dia').AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(5, list.Lineactual, control.FieldByName('items').AsString, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, control.FieldByName('laboratorio').AsString, 3, 'Arial, normal, 8', salida, 'N');
    if control.FieldByName('monto1').AsFloat = 0 then list.importe(50, list.Lineactual, '####', control.FieldByName('monto1').AsFloat, 4, 'Arial, normal, 8') else list.importe(40, list.Lineactual, '', control.FieldByName('monto1').AsFloat, 4, 'Arial, normal, 8');
    list.Linea(41, list.Lineactual, control.FieldByName('concepto').AsString, 5, 'Arial, normal, 8', salida, 'N');
    if control.FieldByName('monto2').AsFloat = 0 then list.importe(80, list.Lineactual, '####', control.FieldByName('monto2').AsFloat, 6, 'Arial, normal, 8') else list.importe(80, list.Lineactual, '', control.FieldByName('monto2').AsFloat, 6, 'Arial, normal, 8');
    controlcom.BuscarObs(control.FieldByName('periodo').AsString, control.FieldByName('dia').AsString, control.FieldByName('items').AsString);
    if control.FieldByName('tob').AsString = '' then list.Linea(81, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S') else list.ListarMemo('obs', 'Arial, normal, 8', controlcom.obs, largoobscom, 81, 7, salida);
    totales[1] := totales[1] + control.FieldByName('monto1').AsFloat;
    totales[2] := totales[2] + control.FieldByName('monto2').AsFloat;
    control.Next;
  end;
  control.Close; control.Free;

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(45, list.Lineactual, '--------------------------------------------------------------', 2, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Total Egr.:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(50, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
  list.importe(80, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 8');
  totales[7] := totales[1] + totales[2];
  list.importe(95, list.Lineactual, '', totales[7], 6, 'Arial, negrita, 8');

  list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');
  list.Linea(0, 0, 'Total Ingresos:', 1, 'Arial, negrita, 9', salida, 'N');
  list.importe(25, list.Lineactual, '', totales[6], 2, 'Arial, negrita, 9');
  list.Linea(33, list.Lineactual, 'Total Egresos:', 4, 'Arial, negrita, 9', salida, 'N');
  list.importe(58, list.Lineactual, '', totales[7], 5, 'Arial, negrita, 9');
  list.Linea(70, list.Lineactual, 'Utilidad:', 5, 'Arial, negrita, 9', salida, 'N');
  list.importe(95, list.Lineactual, '', totales[6] - totales[7], 6, 'Arial, negrita, 9');
  list.Linea(96, list.Lineactual, '', 7, 'Arial, negrita, 9', salida, 'S');

  list.CompletarPagina;
end;

procedure TTInformesControl.InformeHorasExtrasPersonal(xperiodo: String; salida: Char);
var
  control, r: TQuery;
  i, c: Integer;
  l: Boolean;
Begin
  if not lini then list.Setear(salida) else list.IniciarTitulos;
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'Horas Extras Personal - Período: ' + xperiodo, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 5');
  list.Titulo(0, 0, 'Día', 1, 'Arial, cursiva, 8');
  list.Titulo(5, list.Lineactual, 'Items', 2, 'Arial, cursiva, 8');
  list.Titulo(12, list.Lineactual, 'Entrada', 3, 'Arial, cursiva, 8');
  list.Titulo(20, list.Lineactual, 'Salida', 4, 'Arial, cursiva, 8');
  list.Titulo(28, list.Lineactual, 'Hs.Trab.', 5, 'Arial, cursiva, 8');
  list.Titulo(38, list.Lineactual, 'Entrada', 6, 'Arial, cursiva, 8');
  list.Titulo(46, list.Lineactual, 'Salida', 7, 'Arial, cursiva, 8');
  list.Titulo(54, list.Lineactual, 'Hs.Trab.', 8, 'Arial, cursiva, 8');
  list.Titulo(65, list.Lineactual, 'Observaciones', 9, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');
  if lini then list.ListTitulos;
  lini := True;

  r := empleado.setEmpleados;
  r.Open;
  while not r.Eof do Begin
    empleado.getDatos(r.FieldByName('nrolegajo').AsString);
    if totales[1] > 0 then list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, 'Empleado: ' + r.FieldByName('nrolegajo').AsString + ' ' + empleado.nombre, 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');

    control := controlh.setHorasTrabajadas(xperiodo, r.FieldByName('nrolegajo').AsString);
    control.Open;

    for i := 1 to cantitems do totales[i] := 0;

    while not control.Eof do Begin
      c := 0;
      if (Length(Trim(control.FieldByName('dh').AsString)) > 0) and (Length(Trim(control.FieldByName('hh').AsString)) > 0) then Begin
        list.Linea(0, 0, control.FieldByName('dia').AsString, 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(5, list.Lineactual, control.FieldByName('items').AsString, 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(12, list.Lineactual, control.FieldByName('dh').AsString, 3, 'Arial, normal, 8', salida, 'N');
        list.Linea(20, list.Lineactual, control.FieldByName('hh').AsString, 4, 'Arial, normal, 8', salida, 'N');
        if (Length(Trim(control.FieldByName('dh').AsString)) > 0) and (Length(Trim(control.FieldByName('hh').AsString)) > 0) then
          list.Linea(28, list.Lineactual, utiles.difHoras(control.FieldByName('dh').AsString, control.FieldByName('hh').AsString), 5, 'Arial, normal, 8', salida, 'N')
         else
          list.Linea(28, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'N');
        totales[1] := totales[1] + StrToInt(Copy(utiles.difHoras(control.FieldByName('dh').AsString, control.FieldByName('hh').AsString), 1, 2));
        totales[2] := totales[2] + StrToInt(Copy(utiles.difHoras(control.FieldByName('dh').AsString, control.FieldByName('hh').AsString), 4, 2));
        totales[3] := totales[3] + StrToInt(Copy(utiles.difHoras(control.FieldByName('dh').AsString, control.FieldByName('hh').AsString), 1, 2));
        totales[4] := totales[4] + StrToInt(Copy(utiles.difHoras(control.FieldByName('dh').AsString, control.FieldByName('hh').AsString), 4, 2));
        c := 5;
      end;
      if (Length(Trim(control.FieldByName('dht').AsString)) > 0) and (Length(Trim(control.FieldByName('hht').AsString)) > 0) then Begin
        if c = 0 then Begin
          list.Linea(0, 0, control.FieldByName('dia').AsString, 1, 'Arial, normal, 8', salida, 'N');
          c := 1;
        end;
        list.Linea(38, list.Lineactual, control.FieldByName('dht').AsString, c+1, 'Arial, normal, 8', salida, 'N');
        list.Linea(46, list.Lineactual, control.FieldByName('hht').AsString, c+2, 'Arial, normal, 8', salida, 'N');
        if (Length(Trim(control.FieldByName('dht').AsString)) > 0) and (Length(Trim(control.FieldByName('hht').AsString)) > 0) then
          list.Linea(54, list.Lineactual, utiles.difHoras(control.FieldByName('dht').AsString, control.FieldByName('hht').AsString), c+3, 'Arial, normal, 8', salida, 'N')
         else
          list.Linea(54, list.Lineactual, '', c+3, 'Arial, normal, 8', salida, 'N');
        totales[5] := totales[5] + StrToInt(Copy(utiles.difHoras(control.FieldByName('dht').AsString, control.FieldByName('hht').AsString), 1, 2));
        totales[6] := totales[6] + StrToInt(Copy(utiles.difHoras(control.FieldByName('dht').AsString, control.FieldByName('hht').AsString), 4, 2));
        totales[7] := totales[7] + StrToInt(Copy(utiles.difHoras(control.FieldByName('dht').AsString, control.FieldByName('hht').AsString), 1, 2));
        totales[8] := totales[8] + StrToInt(Copy(utiles.difHoras(control.FieldByName('dht').AsString, control.FieldByName('hht').AsString), 4, 2));
      end;
      if c = 0 then list.Linea(65, list.Lineactual, control.FieldByName('concepto').AsString, 6, 'Arial, normal, 8', salida, 'S') else
        list.Linea(65, list.Lineactual, control.FieldByName('concepto').AsString, c+4, 'Arial, normal, 8', salida, 'S');
      control.Next;
    end;
    control.Close; control.Free;

    list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'N');
    list.Linea(27, list.Lineactual, '----------', 2, 'Arial, negrita, 8', salida, 'N');
    list.Linea(53, list.Lineactual, '----------', 3, 'Arial, negrita, 8', salida, 'N');
    list.Linea(64, list.Lineactual, '----------', 4, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, 'Cantidad Horas Trabajadas:', 1, 'Arial, negrita, 8', salida, 'N');
    list.Linea(28, list.Lineactual, utiles.setEquivTotalHoras(FloatToStr(totales[1]) + ':' + FloatToStr(totales[2])), 2, 'Arial, negrita, 8', salida, 'N');
    list.Linea(54, list.Lineactual, utiles.setEquivTotalHoras(FloatToStr(totales[5]) + ':' + FloatToStr(totales[6])), 3, 'Arial, negrita, 8', salida, 'N');
    list.Linea(65, list.Lineactual, utiles.setEquivTotalHoras(FloatToStr(totales[1] + totales[5]) + ':' + FloatToStr(totales[2] + totales[6])), 4, 'Arial, negrita, 8', salida, 'S');

    r.Next;
  end;

  r.Close; r.Free;

  list.CompletarPagina;
end;

procedure TTInformesControl.InformeGastosPersonales(xperiodo: String; salida: Char);
// Objetivo...: Informe de Gastos Personales
var
  control: TQuery;
  i: Integer;
Begin
  if not lini then list.Setear(salida) else list.IniciarTitulos;
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'Informe de Gastos Personales - Período: ' + xperiodo, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 5');
  list.Titulo(0, 0, 'Día', 1, 'Arial, cursiva, 8');
  list.Titulo(5, list.Lineactual, 'Items', 2, 'Arial, cursiva, 8');
  list.Titulo(12, list.Lineactual, 'Concepto', 3, 'Arial, cursiva, 8');
  list.Titulo(85, list.Lineactual, 'Monto', 4, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');
  if lini then list.ListTitulos;
  lini := True;

  control := controlg.setGastos(xperiodo);
  control.Open;

  for i := 1 to cantitems do totales[i] := 0;

  while not control.Eof do Begin
    if control.FieldByName('periodo').AsString <> xperiodo then Break;
    if control.FieldByName('monto').AsFloat <> 0 then Begin
      list.Linea(0, 0, control.FieldByName('dia').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(5, list.Lineactual, control.FieldByName('items').AsString, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(12, list.Lineactual, control.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', control.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
      totales[1] := totales[1] + control.FieldByName('monto').AsFloat;
    end;
    control.Next;
  end;
  control.Close; control.Free;

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(87, list.Lineactual, '---------------', 2, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Total Gastos:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(95, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');

  list.CompletarPagina;
end;

procedure TTInformesControl.InformeControlTarjetas(xperiodo: String; salida: char);
var
  control: TQuery;
  i: Integer;
  idanter: String;
Begin
  if not lini then list.Setear(salida) else list.IniciarTitulos;
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'Informe Operaciones con Tarjetas de Crédito - Período: ' + xperiodo, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 5');
  list.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  list.Titulo(10, list.Lineactual, 'Cliente', 2, 'Arial, cursiva, 8');
  list.Titulo(85, list.Lineactual, 'Monto', 3, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');
  if lini then list.ListTitulos;
  lini := True;

  control := cobrostarj.setMovimientos(xperiodo);
  control.Open;

  for i := 1 to cantitems do totales[i] := 0;

  while not control.Eof do Begin
    if control.FieldByName('idtarjeta').AsString <> idanter then Begin
      totalTarjeta(salida);
      tarjeta.getDatos(control.FieldByName('idtarjeta').AsString);
      list.Linea(0, 0, 'Tarjeta: ' + tarjeta.Tarjeta, 1, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    end;
    cliente.getDatos(control.FieldByName('codcli').AsString);
    list.Linea(0, 0, utiles.sFormatoFecha(control.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, control.FieldByName('codcli').AsString + '  ' + cliente.nombre, 2, 'Arial, normal, 8', salida, 'N');
    list.importe(90, list.Lineactual, '', control.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8');
    list.Linea(92, list.Lineactual, control.FieldByName('estado').AsString, 4, 'Arial, normal, 8', salida, 'S');
    if control.FieldByName('estado').AsString = 'N' then totales[1] := totales[1] + control.FieldByName('monto').AsFloat else
      totales[2] := totales[2] + control.FieldByName('monto').AsFloat;
    idanter := control.FieldByName('idtarjeta').AsString;
    control.Next;
  end;
  control.Close; control.Free;

  totalTarjeta(salida);

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(82, list.Lineactual, '---------------', 2, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Total General Cobros:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(90, list.Lineactual, '', totales[3], 2, 'Arial, negrita, 8');
  list.Linea(95, list.Lineactual, '',31, 'Arial, negrita, 8', salida, 'S');
  list.Linea(0, 0, 'Pendientes General:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(90, list.Lineactual, '', totales[4], 2, 'Arial, negrita, 8');
  list.Linea(95, list.Lineactual, '',31, 'Arial, negrita, 8', salida, 'S');

  list.CompletarPagina;
end;

procedure TTInformesControl.totalTarjeta(salida: char);
Begin
  if totales[1] + totales[2] > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(82, list.Lineactual, '---------------', 2, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Total Cobros:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(90, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '',31, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, 'Pendientes:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(90, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '',31, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    totales[3] := totales[3] + totales[1];
    totales[4] := totales[4] + totales[2];
    totales[1] := 0; totales[2] := 0;
  end;
end;

procedure TTInformesControl.PresentarInformes;
Begin
  list.FinList;
  lini := False;
end;

{===============================================================================}

function infcontrol: TTInformesControl;
begin
  if xinfcontrol = nil then
    xinfcontrol := TTInformesControl.Create;
  Result := xinfcontrol;
end;

{===============================================================================}

initialization

finalization
  xinfcontrol.Free;

end.
