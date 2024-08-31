unit CExpensas_Prever;

interface

uses CtitularPreveer_Expensas, CBDT, SysUtils, DB, DBTables, CUtiles, CListar,
     CIDBFM, Classes;

const
  cantt = 5;

type

TTExpensas_Prever = class
  Periodo: String; MontoBase: Real;
 public
  { Declaraciones Públicas }
  expensas, montos: TTable;

  constructor Create;
  destructor  Destroy; override;

  function   Buscar(xanio, xidtitular, xmes: String): Boolean;
  procedure  GenerarPlanDePago(xanio, xidtitular, xmes: String);
  procedure  RegistrarPago(xanio, xidtitular, xmes, xfecha, xrecibo, xconcepto: String; xmonto, xrecargo: Real);
  procedure  AnularPago(xanio, xidtitular, xmes: String);
  procedure  BorrarPlanDePagos(xanio, xidtitular: String);

  function   setCuotasImpagas(xanio, xidtitular: String): TQuery;
  function   setCuotasPagas(xanio, xidtitular: String): TQuery;
  function   setPrimerMes(xanio, xidtitular: String): String;

  procedure  ListarDetalleCobros(xdfecha, xhfecha: String; titSel: array of String; salida: Char);
  procedure  InformeEstadoCuotas(xfdesde, xfhasta: String; titSel: Array of String; salida: char);
  procedure  ListarCuotasImpagas(xfecha, xmeses: String; titSel: Array of String; salida: char);

  function   verificarSiElTitularTieneOperaciones(xidtitular: String): Boolean;
  function   verificarSiElTitularTienePlan(xidtitular, xanio: String): Boolean;

  function   BuscarMonto(xperiodo: String): Boolean;
  procedure  RegistrarMonto(xperiodo: String; xmonto: Real);
  procedure  BorrarMonto(xperiodo: String);
  function   setMontos: TStringList;
  procedure  SincronizarMonto(xperiodo: String);

  procedure  conectar;
  procedure  desconectar;
 protected
  { Declaraciones Protegidas }
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  idanter, idanter1: String;
  totales: array [1..cantt] of Real;
  meses: array[1..12] of String;
  l: Boolean;
  lista: TStringList;
  procedure  TotCobros(salida: char);
  procedure  Linea(xidanter: String; xmi: Integer; salida: Char);
  procedure  TotalesFinales(salida: char);
  procedure  listLineaAtrazos(xidtitular, xdetalle: String; salida: char);
  function   setFechaPrimerPago(xidtitular: String): String;
end;

function expensa: TTExpensas_Prever;

implementation

var
  xexpensa: TTExpensas_Prever = nil;

constructor TTExpensas_Prever.Create;
begin
  expensas := datosdb.openDB('expensas', '');
  montos   := datosdb.openDB('montos', '');
end;

destructor TTExpensas_Prever.Destroy;
begin
  inherited Destroy;
end;

function   TTExpensas_Prever.Buscar(xanio, xidtitular, xmes: String): Boolean;
// Objetivo...: Buscar Reg. de Expensas
begin
  Result := datosdb.Buscar(expensas, 'Anio', 'Idtitular', 'Mes', xanio, xidtitular, xmes);
end;

procedure  TTExpensas_Prever.GenerarPlanDePago(xanio, xidtitular, xmes: String);
// Objetivo...: Registrar pago
begin
  if xmes = '01' then datosdb.tranSQL('DELETE FROM expensas WHERE anio = ' + '"' + xanio + '"' + ' AND idtitular = ' + '"' + xidtitular + '"');
  expensas.Append;
  expensas.FieldByName('anio').AsString      := xanio;
  expensas.FieldByName('idtitular').AsString := xidtitular;
  expensas.FieldByName('mes').AsString       := xmes;
  expensas.FieldByName('concepto').AsString  := 'Cuota mes de ' + utiles.setMes(StrToInt(xmes));
  expensas.FieldByName('estado').AsString    := 'I';
  try
    expensas.Post
   except
    expensas.Cancel
  end;
end;

procedure  TTExpensas_Prever.RegistrarPago(xanio, xidtitular, xmes, xfecha, xrecibo, xconcepto: String; xmonto, xrecargo: Real);
// Objetivo...: Registrar pago
begin
  if Buscar(xanio, xidtitular, xmes) then expensas.Edit else expensas.Append;
  expensas.FieldByName('anio').AsString      := xanio;
  expensas.FieldByName('idtitular').AsString := xidtitular;
  expensas.FieldByName('mes').AsString       := xmes;
  expensas.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  expensas.FieldByName('recibo').AsString    := xrecibo;
  expensas.FieldByName('concepto').AsString  := xconcepto;
  expensas.FieldByName('monto').AsFloat      := xmonto;
  expensas.FieldByName('recargo').AsFloat    := xrecargo;
  expensas.FieldByName('estado').AsString    := 'P';
  try
    expensas.Post
   except
    expensas.Cancel
  end;
end;

procedure TTExpensas_Prever.AnularPago(xanio, xidtitular, xmes: String);
// Objetivo...: Anular un pago efectuado
Begin
  if Buscar(xanio, xidtitular, xmes) then Begin
    expensas.Edit;
    expensas.FieldByName('fecha').AsString    := '';
    expensas.FieldByName('recibo').AsString   := '';
    expensas.FieldByName('concepto').AsString := 'Cuota Mes de ' + utiles.setMes(StrToInt(xmes));
    expensas.FieldByName('monto').AsFloat     := 0;
    expensas.FieldByName('recargo').AsFloat   := 0;
    expensas.FieldByName('estado').AsString   := 'I';
    try
      expensas.Post
     except
      expensas.Cancel
    end;
  end;
end;

procedure TTExpensas_Prever.BorrarPlanDePagos(xanio, xidtitular: String);
// Objetivo...: Dar de baja un plan completo
Begin
  datosdb.tranSQL('DELETE FROM expensas WHERE Anio = ' + '"' + xanio + '"' + ' AND Idtitular = ' + '"' + xidtitular + '"');
end;

function  TTExpensas_Prever.setCuotasImpagas(xanio, xidtitular: String): TQuery;
// Objetivo...: retornar cuotas impagas
Begin
  Result := datosdb.tranSQL('SELECT * FROM expensas WHERE Anio = ' + '"' + xanio + '"' + ' AND Idtitular = ' + '"' + xidtitular + '"' + ' AND estado = ' + '"' + 'I' + '"');
end;

function  TTExpensas_Prever.setCuotasPagas(xanio, xidtitular: String): TQuery;
// Objetivo...: retornar cuotas impagas
Begin
  Result := datosdb.tranSQL('SELECT * FROM expensas WHERE Anio = ' + '"' + xanio + '"' + ' AND Idtitular = ' + '"' + xidtitular + '"' + ' AND estado = ' + '"' + 'P' + '"');
end;

function TTExpensas_Prever.setPrimerMes(xanio, xidtitular: String): String;
// Objetivo...: Devolver el mes inicial
var
  r: TQuery;
Begin
  r := datosdb.tranSQL('SELECT * FROM expensas WHERE Anio = ' + '"' + xanio + '"' + ' AND Idtitular = ' + '"' + xidtitular + '"' + ' ORDER BY anio, mes');
  r.Open;
  if r.RecordCount > 0 then Result := r.FieldByName('mes').AsString else Result := '01';
  r.Close; r.Free;
end;

procedure TTExpensas_Prever.ListarDetalleCobros(xdfecha, xhfecha: String; titSel: array of String; salida: Char);
// Objetivo...: Listar Detalle de Cobros
Begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Informe Detallado de Cobros', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Mes          F.Cobro', 1, 'Arial, cursiva, 8');
  List.Titulo(25, List.lineactual, 'Concepto', 2, 'Arial, cursiva, 8');
  List.Titulo(60, List.lineactual, 'Recibo', 3, 'Arial, cursiva, 8');
  List.Titulo(71, List.lineactual, 'Monto', 4, 'Arial, cursiva, 8');
  List.Titulo(85, List.lineactual, 'Recargo', 5, 'Arial, cursiva, 8');
  List.Titulo(96, List.lineactual, 'E', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  expensas.First; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; idanter := ''; l := False;
  while not expensas.Eof do Begin
    if (StrToInt(expensas.FieldByName('anio').AsString + expensas.FieldByName('mes').AsString) >= StrToInt(Copy(utiles.sExprFecha2000(xdfecha), 1, 4) + Copy(xdfecha, 4, 2))) and (StrToInt(expensas.FieldByName('anio').AsString + expensas.FieldByName('mes').AsString) <= StrToInt(Copy(utiles.sExprFecha2000(xhfecha), 1, 4) + Copy(xhfecha, 4, 2))) and (utiles.verificarItemsEnLista(titSel, expensas.FieldByName('idtitular').AsString)) then Begin
      if expensas.FieldByName('idtitular').AsString <> idanter then Begin
        TotCobros(salida);
        titular.getDatos(expensas.FieldByName('idtitular').AsString);
        list.Linea(0, 0, titular.Nombre, 1, 'Arial, negrita, 9, clNavy', salida, 'N');
        list.Linea(50, list.Lineactual, titular.M + '  ' + titular.F + '  ' + titular.P, 2, 'Arial, negrita, 9, clNavy', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
        idanter := expensas.FieldByName('idtitular').AsString;
      end;

      list.Linea(0, 0, expensas.FieldByName('mes').AsString + '/' + expensas.FieldByName('anio').AsString + '   ' + utiles.sFormatoFecha(expensas.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(25, list.Lineactual, expensas.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(60, list.Lineactual, expensas.FieldByName('recibo').AsString, 3, 'Arial, normal, 8', salida, 'N');
      list.Importe(75, list.Lineactual, '', expensas.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
      list.Importe(90, list.Lineactual, '', expensas.FieldByName('recargo').AsFloat, 5, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, expensas.FieldByName('estado').AsString, 6, 'Arial, normal, 8', salida, 'S');
      totales[1] := totales[1] + 1;
      if Length(Trim(expensas.FieldByName('fecha').AsString)) > 0 then totales[2] := totales[2] + 1;
      totales[3] := totales[3] + expensas.FieldByName('monto').AsFloat;
      totales[4] := totales[4] + expensas.FieldByName('recargo').AsFloat;
      l := True;
    end;
    expensas.Next;
  end;
  TotCobros(salida);
  if l then list.FinList else utiles.msgError('No Existen Datos para Listar ...!');
end;

procedure TTExpensas_Prever.TotCobros(salida: char);
// Objetivo...: Tot. Informe
begin
  if totales[1] > 0 then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Cuotas: ' + utiles.FormatearNumero(FloatToStr(totales[1]), '####') + '          Pagadas: ' + utiles.FormatearNumero(FloatToStr(totales[2]), '####') + '                          Tot.Pago: ' + utiles.FormatearNumero(FloatToStr(totales[3])) + '          Tot.Recargos: ' + utiles.FormatearNumero(FloatToStr(totales[4])), 1, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0;
  end;
end;

procedure TTExpensas_Prever.InformeEstadoCuotas(xfdesde, xfhasta: String; titSel: Array of String; salida: char);
var
  m: array[1..12] of String;
  xidanter: String;
  j, mi, mf, i: Integer;
Begin
  for j := 1 to cantt do totales[j] := 0;
  mi := StrToInt(Copy(xfdesde, 4, 2));  // armar mes inicial
  For j := 1 to 12 do Begin
    case mi of
      1: m[j]  := 'E';
      2: m[j]  := 'F';
      3: m[j]  := 'M';
      4: m[j]  := 'A';
      5: m[j]  := 'M';
      6: m[j]  := 'J';
      7: m[j]  := 'J';
      8: m[j]  := 'A';
      9: m[j]  := 'S';
      10: m[j] := 'O';
      11: m[j] := 'N';
      12: m[j] := 'D';
    end;
    Inc(mi);
    if mi > 12 then mi := 1;
  end;

  mi := StrToInt(Copy(xfdesde, 4, 2));  // armar mes inicial
  mf := StrToInt(Copy(xfhasta, 4, 2));  // armar mes final

  list.Setear(salida);
  list.Titulo(0, 0, '', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Informe Cobro de Expensas entre ' + xfdesde + ' y ' + xfhasta, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

  list.Titulo(0, 0, 'Apellido y Nombre', 1, 'Arial, cursiva, 8');
  list.Titulo(30, list.Lineactual, 'Inicio', 2, 'Arial, cursiva, 8');
  list.Titulo(40, list.Lineactual, m[1], 7, 'Arial, cursiva, 8');
  list.Titulo(45, list.Lineactual, m[2], 8, 'Arial, cursiva, 8');
  list.Titulo(50, list.Lineactual, m[3], 9, 'Arial, cursiva, 8');
  list.Titulo(55, list.Lineactual, m[4], 10, 'Arial, cursiva, 8');
  list.Titulo(60, list.Lineactual, m[5], 11, 'Arial, cursiva, 8');
  list.Titulo(65, list.Lineactual, m[6], 12, 'Arial, cursiva, 8');
  list.Titulo(70, list.Lineactual, m[7], 13, 'Arial, cursiva, 8');
  list.Titulo(75, list.Lineactual, m[8], 14, 'Arial, cursiva, 8');
  list.Titulo(80, list.Lineactual, m[9], 15, 'Arial, cursiva, 8');
  list.Titulo(85, list.Lineactual, m[10], 16, 'Arial, cursiva, 8');
  list.Titulo(90, list.Lineactual, m[11], 17, 'Arial, cursiva, 8');
  list.Titulo(95, list.Lineactual, m[12], 18, 'Arial, cursiva, 8');

  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

  expensas.IndexName := 'expensa_atrazos';
  expensas.First; xidanter := ''; l := False;
  For i := 1 to 12 do meses[i] := '0';
  while not expensas.Eof do Begin
    if (StrToInt(expensas.FieldByName('anio').AsString + expensas.FieldByName('mes').AsString) >= StrToInt(Copy(utiles.sExprFecha2000(xfdesde), 1, 4) + Copy(xfdesde, 4, 2))) and (StrToInt(expensas.FieldByName('anio').AsString + expensas.FieldByName('mes').AsString) <= StrToInt(Copy(utiles.sExprFecha2000(xfhasta), 1, 4) + Copy(xfhasta, 4, 2))) and (utiles.verificarItemsEnLista(titSel, expensas.FieldByName('idtitular').AsString)) then Begin
      if Length(Trim(xidanter)) = 0 then xidanter := expensas.FieldByName('idtitular').AsString;
      if expensas.FieldByName('idtitular').AsString <> xidanter then Begin
        linea(xidanter, mi, salida);
        xidanter := expensas.FieldByName('idtitular').AsString;
        For i := 1 to 12 do meses[i] := '0';
      end;
      if expensas.FieldByName('estado').AsString = 'P' then Begin
        meses[StrToInt(expensas.FieldByName('mes').AsString)] := Copy(expensas.FieldByName('fecha').AsString, 7, 2) + '/' + Copy(expensas.FieldByName('fecha').AsString, 5, 2); //utiles.FormatearNumero(expensas.FieldByName('monto').AsString);
        totales[2] := totales[2] + expensas.FieldByName('monto').AsFloat;
      end;
      SincronizarMonto(expensas.FieldByName('mes').AsString + '/' + expensas.FieldByName('anio').AsString);
      if expensas.FieldByName('estado').AsString > '' then totales[3] := totales[3] + MontoBase;
    end;

    expensas.Next;
  end;

  linea(xidanter, mi, salida);

  expensas.IndexFieldNames := 'Anio;Idtitular;Mes';

  if not l then list.Linea(0, 0, 'No existen datos para listar', 1, 'Arial, normal, 9', salida, 'S') else TotalesFinales(salida);
  list.FinList;
end;

procedure TTExpensas_Prever.Linea(xidanter: String; xmi: Integer; salida: Char);
var
  i, j, q: Integer;
Begin
  titular.getDatos(xidanter);
  list.Linea(0, 0, titular.nombre, 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(30, list.Lineactual, setFechaPrimerPago(xidanter), 2, 'Arial, normal, 8, clBlack', salida, 'N');
  j := 41; q := 2;
  For i := xmi to 12 do Begin   // Desde el mes inicial hasta fin de año
    Inc(q);
    if meses[i] = '0' then list.Linea(j-3, list.Lineactual, '', q, 'Arial, normal, 8, clBlack', salida, 'N') else list.Linea(j-3, list.Lineactual, meses[i], q, 'Arial, normal, 8', salida, 'N');  //if meses[i] = '0' then list.Importe(j, list.Lineactual, '##,##', StrToFloat(meses[i]), q, 'Arial, normal, 8') else list.Importe(j, list.Lineactual, '', StrToFloat(meses[i]), q, 'Arial, normal, 8');
    j := j + 5;
  end;
  For i := 1 to xmi-1 do Begin   // Desde el mes inicial del año siguiente hasta el principio del primero
    Inc(q);
    if meses[i] = '0' then list.Linea(j-3, list.Lineactual, '', q, 'Arial, normal, 8, clBlack', salida, 'N') else list.Linea(j-3, list.Lineactual, meses[i], q, 'Arial, normal, 8', salida, 'N');  //if meses[i] = '0' then list.Importe(j, list.Lineactual, '##,##', StrToFloat(meses[i]), q, 'Arial, normal, 8') else list.Importe(j, list.Lineactual, '', StrToFloat(meses[i]), q, 'Arial, normal, 8');
    j := j + 5;
  end;

  Inc(q);
  list.Linea(j+3, list.Lineactual, '',q ,'Arial, normal, 8, clBlack', salida, 'S');

  totales[1] := totales[1] + 1;

  l := True;
end;

procedure  TTExpensas_Prever.TotalesFinales(salida: char);
// Objetivo...: Totales estadísticos
Begin
  if totales[2] <> 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, 'Cantidad de Expensas:', 1, 'Arial, negrita, 9', salida, 'N');
    list.Importe(50, list.Lineactual, '#####', totales[1], 2, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Monto Total Cobrado:', 1, 'Arial, negrita, 9', salida, 'N');
    list.Importe(50, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Monto Total Expensas:', 1, 'Arial, negrita, 9', salida, 'N');
    list.Importe(50, list.Lineactual, '', totales[3], 2, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Porcentaje de Cobros:', 1, 'Arial, negrita, 9', salida, 'N');
    list.Importe(50, list.Lineactual, '', (totales[2] * 100) / (totales[3]), 2, 'Arial, negrita, 9');
    list.Linea(51, list.Lineactual, '%', 3, 'Arial, negrita, 9', salida, 'S');
  end else
    list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');
end;

{*******************************************************************************}

procedure TTExpensas_Prever.ListarCuotasImpagas(xfecha, xmeses: String; titSel: Array of String; salida: char);
// Objetivo...: Listar Cuotas atrazadas
var
  per, detalle: String; i: Integer;
Begin
  for i := 1 to cantt do totales[i] := 0;
  list.Setear(salida); 
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Informe de Cuotas Atrazadas', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Titular', 1, 'Arial, cursiva, 8');
  List.Titulo(30, List.lineactual, 'Cuotas Adeudadas', 2, 'Arial, cursiva, 8');
  List.Titulo(89, List.lineactual, 'Tot.Deuda', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  per := utiles.RestarPeriodo(xfecha, xmeses);
  expensas.IndexFieldNames := 'Idtitular;Anio;Mes';
  expensas.First; idanter := ''; l := False;
  while not expensas.Eof do Begin
    if (expensas.FieldByName('anio').AsString + expensas.FieldByName('mes').AsString <= Copy(xfecha, 4, 4) + Copy(xfecha, 1, 2)) and (expensas.FieldByName('estado').AsString = 'I') and (utiles.verificarItemsEnLista(titSel, expensas.FieldByName('idtitular').AsString)) then Begin
      if totales[3] > 9 then Begin
        listLineaAtrazos(idanter, detalle, salida);
        detalle := ''; totales[1] := 0;
      end;
      if expensas.FieldByName('idtitular').AsString <> idanter then Begin
        listLineaAtrazos(idanter, detalle, salida);
        detalle := ''; totales[1] := 0;
      end;
      detalle := detalle + expensas.FieldByName('mes').AsString + '/' + Copy(expensas.FieldByName('anio').AsString, 3, 2) + ' - ';
      SincronizarMonto(expensas.FieldByName('mes').AsString + '/' + expensas.FieldByName('anio').AsString);
      totales[1] := totales[1] + MontoBase;
      totales[3] := totales[3] + MontoBase;
      idanter := expensas.FieldByName('idtitular').AsString;
    end;
    expensas.Next;
  end;

  expensas.IndexFieldNames := 'Anio;Idtitular;Mes';

  listLineaAtrazos(idanter, detalle, salida);

  if l then Begin
    list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, 'Total Cobros Atrazados:', 1, 'Arial, negrita, 9', salida, 'N');
    list.Importe(50, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
  end;

  if l then list.FinList else utiles.msgError('No Existen Datos para Listar ...!');
end;

procedure TTExpensas_Prever.listLineaAtrazos(xidtitular, xdetalle: String; salida: char);
Begin
  if totales[1] > 0 then Begin
    if idanter1 <> xidtitular then Begin
      titular.getDatos(xidtitular);
      list.Linea(0, 0, titular.nombre, 1, 'Arial, normal, 8', salida, 'N');
    end else list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(30, list.Lineactual, Copy(xdetalle, 1, Length(xdetalle) - 2), 2, 'Arial, normal, 8', salida, 'S');
    list.importe(97, list.Lineactual, '', totales[1], 3, 'Arial, normal, 8');
    list.Linea(98, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
    totales[2] := totales[2] + totales[1];
    totales[3] := 0;
    l := True;
    idanter1 := xidtitular;
  end;
end;

function TTExpensas_Prever.verificarSiElTitularTieneOperaciones(xidtitular: String): Boolean;
// Objetivo...: Verificar si el titular tiene o no operaciones registradas
var
  r: TQuery;
Begin
  r := datosdb.tranSQL('SELECT * FROM expensas WHERE Idtitular = ' + '"' + xidtitular + '"');
  r.Open;
  if r.RecordCount > 0 then Result := True else Result := False;
  r.Close; r.Free;
end;

function  TTExpensas_Prever.verificarSiElTitularTienePlan(xidtitular, xanio: String): Boolean;
// Objetivo...: verificar si el titular tiene el plan definido
Begin
  if expensas.IndexFieldNames <> 'Idtitular;Anio' then expensas.IndexFieldNames := 'Idtitular;Anio';
  Result := datosdb.Buscar(expensas, 'Idtitular', 'Anio', xidtitular, xanio);
  expensas.IndexFieldNames := 'Idtitular;Anio;Mes';
end;

function TTExpensas_Prever.setFechaPrimerPago(xidtitular: String): String;
// Objetivo...: Devolver primer pago efectuado
var
  r: TQuery;
Begin
  r := datosdb.tranSQL('SELECT * FROM expensas WHERE idtitular = ' + '"' +  xidtitular + '"' + ' ORDER BY anio, mes');
  r.Open;
  if r.RecordCount > 0 then Result := r.FieldByName('mes').AsString + '/' + r.FieldByName('anio').AsString else Result := '';
  r.Close; r.Free;
end;

function  TTExpensas_Prever.BuscarMonto(xperiodo: String): Boolean;
// Objetivo...: buscar monto
begin
  Result := montos.FindKey([xperiodo]);
end;

procedure TTExpensas_Prever.RegistrarMonto(xperiodo: String; xmonto: Real);
// Objetivo...: registrar monto
begin
  if BuscarMonto(xperiodo) then montos.Edit else montos.Append;
  montos.FieldByName('periodo').AsString := xperiodo;
  montos.FieldByName('monto').AsFloat    := xmonto;
  try
    montos.Post
   except
    montos.Cancel
  end;
  datosdb.refrescar(montos);
  lista := setMontos;
end;

procedure TTExpensas_Prever.BorrarMonto(xperiodo: String);
// Objetivo...: borrar monto
begin
  if BuscarMonto(xperiodo) then Begin
    montos.Delete;
    datosdb.refrescar(montos);
    lista := setMontos;
  end;
end;

function  TTExpensas_Prever.setMontos: TStringList;
// Objetivo...: Recuperar Montos
var
  l, l1, l2: TStringList;
  i: Integer;
Begin
  l  := TStringList.Create;
  l1 := TStringList.Create;
  l2 := TStringList.Create;
  i  := 0;
  montos.First;
  while not montos.Eof do Begin
    l.Add(montos.FieldByName('periodo').AsString + montos.FieldByName('monto').AsString);
    l1.Add(Copy(montos.FieldByName('periodo').AsString, 4, 4) + Copy(montos.FieldByName('periodo').AsString, 1, 2) + IntToStr(i));
    Inc(i);
    montos.Next;
  end;
  l1.Sort;
  for i := 1 to l1.Count do
    l2.Add(l.Strings[StrToInt(Trim(Copy(l1.Strings[i-1], 7, 3)))]);
  l1.Destroy; l.Destroy;
  Result := l2;
end;

procedure TTExpensas_Prever.SincronizarMonto(xperiodo: String);
// Objetivo...: Sincronizar Monto
var
  i: Integer;
  p: String;
Begin
  MontoBase := 0;
  For i := 1 to lista.Count do Begin
    MontoBase := StrToFloat(Trim(Copy(lista.Strings[i-1], 8, 12)));
    p := Copy(lista.Strings[i-1], 1, 7);
    if ( (Copy(p, 4, 4) + Copy(p, 1, 2)) ) >= ( (Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2)) ) then Break;
  end;
end;

procedure TTExpensas_Prever.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  titular.conectar;
  if conexiones = 0 then Begin
    if not expensas.Active then expensas.Open;
    if not montos.Active then montos.Open;
    lista := setMontos;
  end;
  Inc(conexiones);
end;

procedure TTExpensas_Prever.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  titular.desconectar;
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(expensas);
    datosdb.closeDB(montos);
  end;
end;

{===============================================================================}

function expensa: TTExpensas_Prever;
begin
  if xexpensa = nil then
    xexpensa := TTExpensas_Prever.Create;
  Result := xexpensa;
end;

{===============================================================================}

initialization

finalization
  xexpensa.Free;

end.
