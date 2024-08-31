unit CInfFinalSoc;

interface

uses CPagoServ, Ccctsoc, CTInteres, CFondoG, CConceRS, CSocAdherente, SysUtils, DB, DBTables, CBDT, CIDBFM, CListar, CUtiles;

type

TTInfFinal= class(TObject)
  df, hf, de, pe: string;
  r: TQuery;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   setInf(xdf, xhf, xdetallar, xperiodo: string);
  procedure   Listar(xcodsocio: string; salida: char);
  procedure   listTitulos(salida: char);
  procedure   NuavaPagina;
 private
  { Declaraciones Privadas }
  procedure   listDetServ(salida: char; xcodsocio: string);
  procedure   listDetVtos(salida: char; xcodsocio: string);
end;

function inffinal: TTinffinal;

implementation

var
  xinffinal: TTInfFinal= nil;

constructor TTinffinal.Create;
begin
  inherited Create;
end;

destructor TTinffinal.Destroy;
begin
  inherited Destroy;
end;

procedure TTinffinal.setInf(xdf, xhf, xdetallar, xperiodo: string);
// Objetivo...: Fijar el rango para el cálculo
begin
  df := xdf;
  hf := xhf;
  de := xdetallar;
  pe := xperiodo;
end;

procedure TTinffinal.Listar(xcodsocio: string; salida: char);
// Objetivo...: Generar Informe
var
  total: array[1..6] of real;
  cuotasimpagas: integer;
begin
  listTitulos(salida);
  pagoserv.conectar;

  socioadherente.getDatos(xcodsocio);
  list.Linea(0, 0, 'Socio: ' + socioadherente.Codigo + '  ' + socioadherente.Nombre, 1, 'Arial, negrita, 9', salida, 'N');
  list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');

  r := pagoserv.getServiciosPagos(df, hf);  // SERVICIOS
  r.Open; r.First;
  while not r.EOF do
    begin
      if r.FieldByName('codsocio').AsString = xcodsocio then total[1] := total[1] + r.FieldByName('importe').AsFloat;
      r.Next;
    end;

  list.Linea(0, 0, 'Servicios .................: ', 1, 'Courier New, negrita, 10', salida, 'N');
  list.importe(70, list.lineactual, '', total[1], 2, 'Arial, negrita, 10');
  list.Linea(70, list.Lineactual, ' ', 3, 'Courier New, negrita, 10', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Courier New, negrita, 5', salida, 'S');
  if de = 'S' then
    begin
      listDetServ(salida, xcodsocio);
      if total[1] <> 0 then list.Linea(0, 0, ' ', 1, 'Arial, negrita, 10', salida, 'S');
    end;
  r.Close;

  r := ccsoc.setCuotas(xcodsocio);  // CREDITOS
  r.Open; r.First;
  while not r.EOF do
    begin
      if (r.FieldByName('fecha').AsString <= utiles.sExprFecha(hf)) and (r.FieldByName('items').AsString >= '001') and (r.FieldByName('DC').AsString = '1') and (r.FieldByName('estado').AsString = 'I') then total[2] := total[2] + (r.FieldByName('importe').AsFloat + r.FieldByName('interes').AsFloat);  // Cuotas hacia atrás
      if (Copy(r.FieldByName('fecha').AsString, 5, 2) = Copy(hf, 4, 2)) and (r.FieldByName('items').AsString >= '001') and (r.FieldByName('DC').AsString = '1') then total[2] := total[2] + (r.FieldByName('importe').AsFloat + r.FieldByName('interes').AsFloat);
      if (r.FieldByName('fecha').AsString <= utiles.sExprFecha(hf)) and (r.FieldByName('DC').AsString = '2') then total[3] := total[3] + r.FieldByName('importe').AsFloat;  // PAGOS
      r.Next;
    end;

  list.Linea(0, 0, 'A.A.R. ....................: ', 1, 'Courier New, negrita, 10', salida, 'N');
  list.importe(70, list.lineactual, '', total[2], 2, 'Arial, negrita, 10');
  list.Linea(70, list.Lineactual, ' ', 3, 'Courier New, negrita, 10', salida, 'S');
  list.Linea(0, 0, 'Entregas/Pagos ............: ', 1, 'Courier New, negrita, 10', salida, 'N');
  list.importe(70, list.lineactual, '', total[3], 2, 'Arial, negrita, 10');
  list.Linea(70, list.Lineactual, ' ', 3, 'Courier New, negrita, 10', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Courier New, negrita, 5', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Courier New, negrita, 10', salida, 'S');
  list.derecha(70, list.lineactual, '', '--------------------', 2, 'Courier New, negrita, 10');
  list.Linea(0, 0, 'Saldo a Pagar A.A.R. ......: ', 1, 'Courier New, negrita, 10', salida, 'N');
  list.importe(70, list.lineactual, '', total[2] - total[3], 2, 'Arial, negrita, 10');
  list.Linea(0, 0, ' ', 1, 'Courier New, negrita, 5', salida, 'S');

  if de = 'S' then
    begin
      listDetVtos(salida, xcodsocio);
      if total[3] <> 0 then list.Linea(0, 0, ' ', 1, 'Arial, negrita, 10', salida, 'S');
    end;
  r.Close;

  // CUOTA SOCIETARIA
  if socioadherente.getCatsocio = 'S' then
    begin
      fondog.conectar;
      utiles.calc_antiguedad(fondog.getUltimaCuotaPaga(xcodsocio), utiles.sExprFecha(hf));  // Calculamos la cantidad de cuotas impagas
      cuotasimpagas := utiles.getMeses;  // Cant. de meses de cuotas impagas

      interes.conectar;
      interes.getDatos('C');
      list.Linea(0, 0, 'Cuota Societaria(Monto) ...: ', 1, 'Courier New, negrita, 10', salida, 'N');
      list.importe(70, list.lineactual, '', interes.getInteres * (cuotasimpagas), 2, 'Arial, negrita, 10');
      list.Linea(70, list.Lineactual, ' ', 3, 'Courier New, negrita, 10', salida, 'S');

      fondog.getDatos(xcodsocio, pe);  // Verificamos si la Cuota para el período en curso fue Liquidada
      total[5] := fondog.Importe;
      list.Linea(0, 0, 'Cuota Societaria(Pago) ....: ', 1, 'Courier New, negrita, 10', salida, 'N');
      list.importe(70, list.lineactual, '', total[5], 2, 'Arial, negrita, 10');
      list.Linea(80, list.Lineactual, 'Cuotas Impagas :    ' + IntToStr(cuotasimpagas), 3, 'Courier New, normal, 8', salida, 'S');

      list.Linea(0, 0, ' ', 1, 'Courier New, negrita, 10', salida, 'S');
      list.derecha(70, list.lineactual, '', '--------------------', 2, 'Courier New, negrita, 10');
      list.Linea(0, 0, 'Saldo Cuota ...............: ', 1, 'Courier New, negrita, 10', salida, 'N');
      total[6] := (interes.getInteres * (cuotasimpagas)) - total[5];
      list.importe(70, list.lineactual, '', total[6], 2, 'Arial, negrita, 10');

      interes.desconectar;
    end;

  list.Linea(0, 0, ' ', 1, 'Courier New, normal, 5', salida, 'S');
  list.Linea(0, 0, 'TOTAL A PAGAR .............: ', 1, 'Courier New, negrita, 10', salida, 'N');
  list.importe(70, list.lineactual, '', total[1] + (total[2] - total[3]) + total[6], 2, 'Arial, negrita, 10');
  list.Linea(70, list.Lineactual, ' ', 3, 'Courier New, negrita, 10', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Courier New, normal, 14', salida, 'S');
  pagoserv.desconectar;

  r.Close;
end;

procedure TTinffinal.listTitulos(salida: char);
// Objetivo...: Listar titulos
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Resumen de Servicios y Créditos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTinffinal.listDetServ(salida: char; xcodsocio: string);
// Objetivo...: Listar Items de Servicios Registrados
begin
  r.First;
  while not r.EOF do
    begin
      if r.FieldByName('codsocio').AsString = xcodsocio then
        begin
          list.Linea(0, 0, '     ' + utiles.sFormatoFecha(r.FieldByName('fecha').AsString) + '  ' + r.FieldByName('codoper').AsString + '-' + pagoserv.getConcepto(r.FieldByName('codoper').AsString), 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(50, list.lineactual, r.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
          list.importe(95, list.lineactual, '', r.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
          list.Linea(97, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
        end;
      r.Next;
    end;
end;

procedure TTinffinal.listDetVtos(salida: char; xcodsocio: string);
// Objetivo...: Listard detalle de Vencimientos
begin
  list.Linea(0, 0, '   Cuotas del mes', 1, 'Arial, cursiva, 8', salida, 'S');
  r.First;   // Cuotas a Pagar
  while not r.EOF do
    begin
      if ((r.FieldByName('fecha').AsString < utiles.sExprFecha(hf)) and (r.FieldByName('items').AsString >= '001') and (r.FieldByName('DC').AsString = '1') and (r.FieldByName('estado').AsString = 'I')) or ((Copy(r.FieldByName('fecha').AsString, 5, 2) = Copy(hf, 4, 2)) and (r.FieldByName('items').AsString >= '001') and (r.FieldByName('DC').AsString = '1')) then
        begin
          list.Linea(0, 0, '     ' + utiles.sFormatoFecha(r.FieldByName('fecha').AsString) + '  ' + r.FieldByName('clavecta').AsString + '  ' + ccsoc.getObs(r.FieldByName('codsocio').AsString, r.FieldByName('clavecta').AsString), 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(50, list.lineactual, r.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
          list.importe(95, list.lineactual, '',  r.FieldByName('importe').AsFloat + r.FieldByName('interes').AsFloat, 3, 'Arial, normal, 8');
          list.Linea(97, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
        end;
      r.Next;
    end;

  list.Linea(0, 0, '   ', 1, 'Arial, cursiva, 8', salida, 'S');
  list.Linea(0, 0, '   Entregas Efectuadas', 1, 'Arial, cursiva, 8', salida, 'S');
  r.First;   // Cuotas a Pagar
  while not r.EOF do
    begin
      if ((r.FieldByName('fecha').AsString >= utiles.sExprFecha(df)) and (r.FieldByName('fecha').AsString <= utiles.sExprFecha(hf))) and (r.FieldByName('items').AsString >= '001') and (r.FieldByName('DC').AsString = '2') and (r.FieldByName('estado').AsString = 'R') then
        begin
          list.Linea(0, 0, '     ' + utiles.sFormatoFecha(r.FieldByName('fecha').AsString) + '  ' + r.FieldByName('clavecta').AsString + '  ' + ccsoc.getObs(r.FieldByName('codsocio').AsString, r.FieldByName('clavecta').AsString), 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(50, list.lineactual, r.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
          list.importe(85, list.lineactual, '',  (r.FieldByName('importe').AsFloat - r.FieldByName('entrega').AsFloat), 3, 'Arial, normal, 8');
          list.Linea(87, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
        end;
      r.Next;
    end;
end;

procedure TTinffinal.NuavaPagina;
// Objetivo...: Avanzar una Página
begin
  list.CompletarPagina;
  list.IniciarNuevaPagina;
end;

{===============================================================================}

function inffinal: TTinffinal;
begin
  if xinffinal = nil then
    xinffinal := TTinffinal.Create;
  Result := xinffinal;
end;

{===============================================================================}

initialization

finalization
  xinffinal.Free;

end.