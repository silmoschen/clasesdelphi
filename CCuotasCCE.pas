unit CCuotasCCE;

interface

uses CClienteCCE, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes,
     CParametrosEmpresa, CFacturasCCE_Cuotas;

type

TTCuotas = class
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xperiodo, xcodcli, xitems: String): Boolean;
  procedure   RegistrarPlan(xperiodo, xcodcli, xitems, xconcepto: String; xmonto: Real);
  procedure   Borrar(xperiodo, xcodcli: String);
  function    setCuotasImpagas(xperiodo, xcodcli: String): TStringList;
  function    setCuotasPagas(xperiodo, xcodcli: String): TStringList;

  procedure   RegistrarPago(xperiodo, xcodcli, xitems, xfecha: String; xrecargo: Real);
  procedure   AnularPago(xperiodo, xcodcli, xitems: String);

  procedure   AjustarMonto(xperiodo, xcodcli, xitems: String; xmonto: real);

  procedure   ListarDetalleCobros(xdfecha, xhfecha: String; titSel: TStringList; salida: Char);
  procedure   InformeEstadoCuotas(xfdesde, xfhasta: String; titSel: TStringList; salida: char);
  procedure   ListarCuotasImpagas(xfdesde, xfhasta, xmeses: String; titSel: TStringList; salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones, difanios: shortint;
  lista, detalle: TStringList;
  totales: array[1..50] of Real;
  meses: array[1..12] of String;
  idanter, idanter1: String;
  l: Boolean;
  Tiporec, Sucrec, Numrec: String;
  cantt: Integer;
  function  setCuotas(xperiodo, xcodcli: String; xestado: String): TStringList;
  procedure TotCobros(salida: char);
  procedure Linea(xidanter: String; xmi: Integer; salida: Char);
  procedure TotalesFinales(salida: char);
  procedure listLineaAtrazos(xidtitular: String; salida: char);
end;

function cuota: TTCuotas;

implementation

var
  xcuota: TTCuotas = nil;

constructor TTCuotas.Create;
begin
  tabla := datosdb.openDB('cuotas', '');
end;

destructor TTCuotas.Destroy;
begin
  inherited Destroy;
end;

function  TTCuotas.Buscar(xperiodo, xcodcli, xitems: String): Boolean;
// Objetivo...: Buscar Instancia
Begin
  Result := datosdb.Buscar(tabla, 'periodo', 'codcli', 'items', xperiodo, xcodcli, xitems);
end;

procedure TTCuotas.RegistrarPlan(xperiodo, xcodcli, xitems, xconcepto: String; xmonto: Real);
// Objetivo...: Registrar Instancia
Begin
  if Buscar(xperiodo, xcodcli, xitems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('periodo').AsString  := xperiodo;
  tabla.FieldByName('codcli').AsString   := xcodcli;
  tabla.FieldByName('items').AsString    := xitems;
  tabla.FieldByName('concepto').AsString := xconcepto;
  tabla.FieldByName('monto').AsFloat     := xmonto;
  tabla.FieldByName('estado').AsString   := 'I';
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTCuotas.AjustarMonto(xperiodo, xcodcli, xitems: String; xmonto: real);
// Objetivo...: Ajustar Monto
Begin
  if Buscar(xperiodo, xcodcli, xitems) then begin
    tabla.Edit;
    tabla.FieldByName('monto').AsFloat := xmonto;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTCuotas.Borrar(xperiodo, xcodcli: String);
// Objetivo...: Borrar una Instancia
Begin
  datosdb.tranSQL('delete from ' + tabla.TableName + ' where periodo = ' + '''' + xperiodo + '''' + ' and codcli = ' + '''' + xcodcli + '''');
end;

function  TTCuotas.setCuotas(xperiodo, xcodcli, xestado: String): TStringList;
// Objetivo...: Recuperar Cuotas Imapagas
Begin
  lista := TStringList.Create;
  datosdb.Filtrar(tabla, 'periodo = ' + '''' + xperiodo + '''' + ' and codcli = ' + '''' + xcodcli + '''' + ' and estado = ' + '''' + xestado + '''');
  tabla.First;
  while not tabla.Eof do Begin
    lista.Add(tabla.FieldByName('items').AsString + tabla.FieldByName('concepto').AsString + ';1' + utiles.FormatearNumero(tabla.FieldByName('monto').AsString) + ';2' + tabla.FieldByName('estado').AsString +
      utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString) + utiles.FormatearNumero(tabla.FieldByName('recargo').AsString));
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);
  Result := lista;
end;

function  TTCuotas.setCuotasImpagas(xperiodo, xcodcli: String): TStringList;
// Objetivo...: Recuperar Cuotas Imapagas
Begin
  Result := setCuotas(xperiodo, xcodcli, 'I');
end;

function  TTCuotas.setCuotasPagas(xperiodo, xcodcli: String): TStringList;
// Objetivo...: Recuperar Cuotas Pagas
Begin
  Result := setCuotas(xperiodo, xcodcli, 'P');
end;

procedure TTCuotas.RegistrarPago(xperiodo, xcodcli, xitems, xfecha: String; xrecargo: Real);
// Objetivo...: cerrar tablas de persistencia
begin
  if Buscar(xperiodo, xcodcli, xitems) then Begin
    tabla.Edit;
    tabla.FieldByName('fecha').AsString  := utiles.sExprFecha2000(xfecha);
    tabla.FieldByName('recargo').AsFloat := xrecargo;
    tabla.FieldByName('estado').AsString := 'P';
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTCuotas.AnularPago(xperiodo, xcodcli, xitems: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if Buscar(xperiodo, xcodcli, xitems) then Begin
    tabla.Edit;
    tabla.FieldByName('fecha').AsString  := '';
    tabla.FieldByName('recargo').AsFloat := 0;
    tabla.FieldByName('estado').AsString := 'I';
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

//------------------------------------------------------------------------------

procedure TTCuotas.ListarDetalleCobros(xdfecha, xhfecha: String; titSel: TStringList; salida: Char);
// Objetivo...: Listar Detalle de Cobros
var
  i, anioini: Integer;
  f, z: String;
Begin
  if salida <> 'T' then Begin
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, empresa.RSocial, 1, 'Arial, normal, 12');
    List.Titulo(0, 0, 'Informe Detallado de Cuotas Societarias', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Mes          F.Cobro', 1, 'Arial, cursiva, 8');
    List.Titulo(15, List.lineactual, 'Comprobante', 2, 'Arial, cursiva, 8');
    List.Titulo(30, List.lineactual, 'Concepto', 3, 'Arial, cursiva, 8');
    List.Titulo(55, List.lineactual, 'Recibo', 4, 'Arial, cursiva, 8');
    List.Titulo(71, List.lineactual, 'Monto', 5, 'Arial, cursiva, 8');
    List.Titulo(85, List.lineactual, 'Recargo', 6, 'Arial, cursiva, 8');
    List.Titulo(96, List.lineactual, 'E', 7, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end else Begin
    list.LineaTxt('', True);
    List.LineaTxt(empresa.RSocial, True);
    list.LineaTxt('Informe Detallado de Aportes', True);
    list.LineaTxt('', True);
    list.LineaTxt('Mes      F.Cobro   Concepto                       Recibo       Monto  Recargo E', True);
    list.LineaTxt('-------------------------------------------------------------------------------', True);
    list.LineaTxt('', True);
  end;

  totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0; totales[8] := 0;
  idanter := ''; l := False;
  factura.conectar;

  difanios := StrToInt(Copy(utiles.sExprFecha2000(xhfecha), 1, 4)) - StrToInt(Copy(utiles.sExprFecha2000(xdfecha), 1, 4));
  anioini  := StrToInt(Copy(utiles.sExprFecha2000(xdfecha), 1, 4));

  for i := 1 to difanios + 1 do Begin

    datosdb.Filtrar(tabla, 'periodo = ' + IntToStr(anioini));

    if i > 1 then
      if salida <> 'T' then list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S') else list.LineaTxt('', True);

    if salida <> 'T' then Begin
      list.Linea(0, 0, 'Año: ' + IntToStr(anioini), 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    end else Begin
      list.LineaTxt('Año: ' + IntToStr(anioini), True);
      list.LineaTxt('', True);
    end;

    tabla.First;
    while not tabla.Eof do Begin
      if (StrToInt(tabla.FieldByName('periodo').AsString + tabla.FieldByName('items').AsString) >= StrToInt(Copy(utiles.sExprFecha2000(xdfecha), 1, 4) + Copy(xdfecha, 4, 2))) and (StrToInt(tabla.FieldByName('periodo').AsString + tabla.FieldByName('items').AsString) <= StrToInt(Copy(utiles.sExprFecha2000(xhfecha), 1, 4) + Copy(xhfecha, 4, 2))) and (utiles.verificarItemsLista(titSel, tabla.FieldByName('codcli').AsString)) then Begin
        if tabla.FieldByName('codcli').AsString <> idanter then Begin
          TotCobros(salida);
          if l then
            if salida <> 'T' then list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S') else list.LineaTxt('', True);
          cliente.getDatos(tabla.FieldByName('codcli').AsString);
          if salida <> 'T' then Begin
            list.Linea(0, 0, cliente.Nombre, 1, 'Arial, negrita, 9', salida, 'N');
            list.Linea(50, list.Lineactual, cliente.domicilio, 2, 'Arial, negrita, 9', salida, 'S');
            list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
          end else Begin
            list.LineaTxt(Copy(cliente.Nombre, 1, 30) + utiles.espacios(31 - (Length(TrimRight(Copy(cliente.Nombre, 1, 30))))), False);
            list.LineaTxt(Copy(cliente.domicilio, 1, 30) + utiles.espacios(31 - (Length(TrimRight(Copy(cliente.domicilio, 1, 30))))), True);
            list.LineaTxt('', True);
          end;
          idanter := tabla.FieldByName('codcli').AsString;
        end;

        z := utiles.sLlenarIzquierda (Copy(tabla.FieldByName('fecha').AsString, 1, 4) + tabla.FieldByName('codcli').AsString + tabla.FieldByName('items').AsString, 11, '0');

        if salida <> 'T' then Begin
          list.Linea(0, 0, tabla.FieldByName('items').AsString + '/' + tabla.FieldByName('periodo').AsString + '   ' + utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
          if tabla.FieldByName('estado').AsString = 'P' then
            list.Linea(15, list.Lineactual, factura.setComprobante(tabla.FieldByName('periodo').AsString, tabla.FieldByName('items').AsString, tabla.FieldByName('codcli').AsString), 2, 'Arial, normal, 8', salida, 'N')
          else
            list.Linea(15, list.Lineactual, '', 2, 'Arial, normal, 8', salida, 'N');
          list.Linea(30, list.Lineactual, tabla.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'N');
          list.Linea(55, list.Lineactual, Tiporec + ' ' + Sucrec + Numrec, 4, 'Arial, normal, 8', salida, 'N');
          list.Importe(75, list.Lineactual, '', tabla.FieldByName('monto').AsFloat, 5, 'Arial, normal, 8');
          list.Importe(90, list.Lineactual, '', tabla.FieldByName('recargo').AsFloat, 6, 'Arial, normal, 8');
          list.Linea(96, list.Lineactual, tabla.FieldByName('estado').AsString, 7, 'Arial, normal, 8', salida, 'S');
        end else Begin
          if Length(Trim(tabla.FieldByName('fecha').AsString)) = 8 then f := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString) else f := '        ';
          list.LineaTxt(tabla.FieldByName('items').AsString + '/' + tabla.FieldByName('periodo').AsString + '  ' + f + '  ', False);
          list.LineaTxt(Copy(tabla.FieldByName('concepto').AsString, 1, 30) + utiles.espacios(31 - (Length(TrimRight(Copy(tabla.FieldByName('concepto').AsString, 1, 30))))), False);
          list.LineaTxt(Tiporec + ' ' + Sucrec + Numrec + utiles.espacios(16 - (Length(TrimRight(Tiporec + ' ' + Sucrec + Numrec)))), False);
          list.ImporteTxt(tabla.FieldByName('monto').AsFloat, 9, 2, False);
          list.ImporteTxt(tabla.FieldByName('recargo').AsFloat, 9, 2, False);
          list.LineaTxt(' ' + tabla.FieldByName('estado').AsString, True);
        end;
        totales[1] := totales[1] + 1;
        if Length(Trim(tabla.FieldByName('fecha').AsString)) > 0 then totales[2] := totales[2] + 1 else
          totales[8] := totales[8] + cliente.Monto;
        totales[3] := totales[3] + tabla.FieldByName('monto').AsFloat;
        totales[4] := totales[4] + tabla.FieldByName('recargo').AsFloat;
        totales[6] := totales[6] + tabla.FieldByName('monto').AsFloat;
        totales[7] := totales[7] + tabla.FieldByName('recargo').AsFloat;
        l := True;
      end;
      tabla.Next;
    end;
    TotCobros(salida);

    datosdb.QuitarFiltro(tabla);
    Inc(anioini);
  end;

  if totales[6] + totales[8] > 0 then Begin
    if salida <> 'T' then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, 'Total Pagos:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(25, list.Lineactual, '', totales[6], 2, 'Arial, negrita, 9');
      list.Linea(35, list.Lineactual, 'Recargos:', 3, 'Arial, negrita, 9', salida, 'N');
      list.importe(60, list.Lineactual, '', totales[7], 4, 'Arial, negrita, 9');
      list.Linea(65, list.Lineactual, 'Total Deuda:', 5, 'Arial, negrita, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', totales[8], 6, 'Arial, negrita, 9');
      list.Linea(95, list.Lineactual, '', 7, 'Arial, negrita, 9', salida, 'S');
    end else Begin
      list.LineaTxt(' ', True);
      list.LineaTxt('Tot.Pagos:' + utiles.espacios(20 - (Length('Tot.Pagos:'))), False);
      list.importeTxt(totales[6], 10, 2, False);
      list.LineaTxt(' Recargos:', False);
      list.importeTxt(totales[7], 10, 2, True);
      list.LineaTxt(' Tot.Deuda:', False);
      list.importeTxt(totales[8], 10, 2, True);
      list.LineaTxt('', False);
    end;
  end;

  factura.desconectar;

  if l then Begin
    if salida <> 'T' then list.FinList;
  end else utiles.msgError('No Existen Datos para Listar ...!');
  if salida = 'T' then list.FinalizarExportacion;
end;

procedure TTCuotas.TotCobros(salida: char);
// Objetivo...: Tot. Informe
begin
  if totales[1] > 0 then Begin
    if salida <> 'T' then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, 'Cuotas:   ' + utiles.FormatearNumero(FloatToStr(totales[1]), '####') + '          Pagadas:   ' + utiles.FormatearNumero(FloatToStr(totales[2]), '####'), 1, 'Arial, negrita, 8', salida, 'N');
      list.Linea(50, list.Lineactual, 'Tot. Pago:', 2, 'Arial, negrita, 8', salida, 'N');
      list.importe(70, list.Lineactual, '', totales[3], 3, 'Arial, negrita, 8');
      list.Linea(72, list.Lineactual, 'Recargos:', 4, 'Arial, negrita, 8', salida, 'N');
      list.importe(94, list.Lineactual, '', totales[4], 5, 'Arial, negrita, 8');
      list.Linea(95, list.Lineactual, '', 6, 'Arial, negrita, 8', salida, 'S');
    end else Begin
      list.LineaTxt(' ', True);
      list.LineaTxt('Cuotas:   ' + utiles.FormatearNumero(FloatToStr(totales[1]), '####') + '         Pagadas:   ' + utiles.FormatearNumero(FloatToStr(totales[2]), '####') + '  ', False);
      list.LineaTxt(' Tot. Pago:', False);
      list.importeTxt(totales[3], 10, 2, False);
      list.LineaTxt('    Recargos:', False);
      list.importeTxt(totales[4], 10, 2, True);
      list.LineaTxt('', True);
    end;
    totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0;
  end;
end;

procedure TTCuotas.InformeEstadoCuotas(xfdesde, xfhasta: String; titSel: TStringList; salida: char);
var
  m: array[1..12] of String;
  xidanter: String;
  j, mi, mf, i, anioini, k: Integer;
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
  list.Titulo(0, 0, 'Informe Cobro de Cuotas Societarias entre ' + xfdesde + ' y ' + xfhasta, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

  list.Titulo(0, 0, 'Razón Social', 1, 'Arial, cursiva, 8');
  list.Titulo(34, list.Lineactual, m[1], 2, 'Arial, cursiva, 8');
  list.Titulo(39, list.Lineactual, m[2], 3, 'Arial, cursiva, 8');
  list.Titulo(44, list.Lineactual, m[3], 4, 'Arial, cursiva, 8');
  list.Titulo(49, list.Lineactual, m[4], 5, 'Arial, cursiva, 8');
  list.Titulo(54, list.Lineactual, m[5], 6, 'Arial, cursiva, 8');
  list.Titulo(59, list.Lineactual, m[6], 7, 'Arial, cursiva, 8');
  list.Titulo(64, list.Lineactual, m[7], 8, 'Arial, cursiva, 8');
  list.Titulo(69, list.Lineactual, m[8], 9, 'Arial, cursiva, 8');
  list.Titulo(74, list.Lineactual, m[9], 10, 'Arial, cursiva, 8');
  list.Titulo(79, list.Lineactual, m[10], 11, 'Arial, cursiva, 8');
  list.Titulo(84, list.Lineactual, m[11], 12, 'Arial, cursiva, 8');
  list.Titulo(89, list.Lineactual, m[12] + '          Total', 13, 'Arial, cursiva, 8');

  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

  tabla.IndexFieldNames := 'Codcli;Periodo;Items';

  difanios := StrToInt(Copy(utiles.sExprFecha2000(xfhasta), 1, 4)) - StrToInt(Copy(utiles.sExprFecha2000(xfdesde), 1, 4));
  anioini  := StrToInt(Copy(utiles.sExprFecha2000(xfdesde), 1, 4));

  for k := 1 to difanios + 1 do Begin

    if k > 1 then list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Año: ' + IntToStr(anioini), 1, 'Arial, normal, 10', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');

    datosdb.Filtrar(tabla, 'periodo = ' + IntToStr(anioini));

    tabla.First; xidanter := ''; l := False;
    For i := 1 to 12 do meses[i] := '0';
    while not tabla.Eof do Begin
      if (StrToInt(tabla.FieldByName('periodo').AsString + tabla.FieldByName('items').AsString) >= StrToInt(Copy(utiles.sExprFecha2000(xfdesde), 1, 4) + Copy(xfdesde, 4, 2))) and (StrToInt(tabla.FieldByName('periodo').AsString + tabla.FieldByName('items').AsString) <= StrToInt(Copy(utiles.sExprFecha2000(xfhasta), 1, 4) + Copy(xfhasta, 4, 2))) and (utiles.verificarItemsLista(titSel, tabla.FieldByName('codcli').AsString)) then Begin
        if Length(Trim(xidanter)) = 0 then xidanter := tabla.FieldByName('codcli').AsString;
        if tabla.FieldByName('codcli').AsString <> xidanter then Begin
          linea(xidanter, mi, salida);
          xidanter := tabla.FieldByName('codcli').AsString;
          For i := 1 to 12 do meses[i] := '0';
        end;
        if tabla.FieldByName('estado').AsString = 'P' then Begin
          meses[StrToInt(tabla.FieldByName('items').AsString)] := Copy(tabla.FieldByName('fecha').AsString, 7, 2) + '/' + Copy(tabla.FieldByName('fecha').AsString, 5, 2); //utiles.FormatearNumero(tabla.FieldByName('monto').AsString);
          totales[2] := totales[2] + tabla.FieldByName('monto').AsFloat;
          totales[4] := totales[4] + tabla.FieldByName('monto').AsFloat;
        end;
        if tabla.FieldByName('estado').AsString > '' then totales[3] := totales[3] + 1;

      end;

      tabla.Next;
    end;

    linea(xidanter, mi, salida);

    datosdb.QuitarFiltro(tabla);
    Inc(anioini);
  end;

  tabla.IndexFieldNames := 'Periodo;Codcli;Items';

  if not l then list.Linea(0, 0, 'No existen datos para listar', 1, 'Arial, normal, 9', salida, 'S') else TotalesFinales(salida);
  list.FinList;
end;

procedure TTCuotas.Linea(xidanter: String; xmi: Integer; salida: Char);
var
  i, j, q: Integer;
Begin
  cliente.getDatos(xidanter);
  list.Linea(0, 0, Copy(cliente.nombre, 1, 35), 1, 'Arial, normal, 8', salida, 'N');
  j := 35; q := 1;
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
  list.importe(99, list.Lineactual, '', totales[4],q ,'Arial, negrita, 8');
  Inc(q);
  list.Linea(99, list.Lineactual, '',q ,'Arial, negrita, 8', salida, 'S');

  totales[1] := totales[1] + 1;
  totales[4] := 0;

  l := True;
end;

procedure  TTCuotas.TotalesFinales(salida: char);
// Objetivo...: Totales estadísticos
Begin
  list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
  list.Linea(0, 0, 'Cantidad de aportes:', 1, 'Arial, negrita, 9', salida, 'N');
  list.Importe(99, list.Lineactual, '#####', totales[1], 2, 'Arial, negrita, 9');
  list.Linea(99, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
  list.Linea(0, 0, 'Monto Total Cobrado:', 1, 'Arial, negrita, 9', salida, 'N');
  list.Importe(99, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 9');
  list.Linea(99, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
end;

procedure TTCuotas.ListarCuotasImpagas(xfdesde, xfhasta, xmeses: String; titSel: TStringList; salida: char);
// Objetivo...: Listar Cuotas atrazadas
var
  per: String;
Begin
  totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0;
  if salida <> 'T' then Begin
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, empresa.RSocial, 1, 'Arial, normal, 12');
    List.Titulo(0, 0, 'Informe de Cuotas Societarias Atrasados al ' + xfdesde, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Entidad', 1, 'Arial, cursiva, 8');
    List.Titulo(27, List.lineactual, 'Cuotas Adeudadas', 2, 'Arial, cursiva, 8');
    List.Titulo(88, List.lineactual, 'Cant.', 3, 'Arial, cursiva, 8');
    List.Titulo(94, List.lineactual, 'Monto', 4, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end else Begin
    List.LineaTxt(' ', True);
    List.LineaTxt(empresa.RSocial, True);
    List.LineaTxt('Informe de Aportes Atrazados al ' + xfdesde, True);
    List.LineaTxt(' ', True);
    List.LineaTxt('Municipalidad o Comuna         Cuotas Atrazadas                Cant.     Monto', True);
    List.LineaTxt('------------------------------------------------------------------------------', True);
    List.LineaTxt(' ', True);
  end;

  per := utiles.RestarPeriodo(xfdesde, xmeses);
  tabla.IndexFieldNames := 'Codcli;Periodo;Items';
  tabla.First; idanter := ''; l := False; totales[4] := 0; idanter1 := '';
  detalle := TStringList.Create;
  while not tabla.Eof do Begin
    if (tabla.FieldByName('periodo').AsString + tabla.FieldByName('items').AsString <= Copy(xfdesde, 4, 4) + Copy(xfdesde, 1, 2)) and (tabla.FieldByName('estado').AsString = 'I') and (utiles.verificarItemsLista(titSel, tabla.FieldByName('codcli').AsString)) and (tabla.FieldByName('periodo').AsString + tabla.FieldByName('items').AsString <= Copy(utiles.sExprFecha2000(xfhasta), 1, 6)) then Begin
      if tabla.FieldByName('codcli').AsString <> idanter then listLineaAtrazos(idanter, salida);
      detalle.Add(tabla.FieldByName('items').AsString + '/' + Copy(tabla.FieldByName('periodo').AsString, 3, 2));
      cliente.getDatos(tabla.FieldByName('codcli').AsString);
      totales[1] := totales[1] + 1;
      totales[2] := totales[2] + cliente.Monto;
      idanter := tabla.FieldByName('codcli').AsString;
    end;
    tabla.Next;
  end;

  tabla.IndexFieldNames := 'Periodo;Codcli;Items';

  listLineaAtrazos(idanter, salida);

  if l then Begin
    if salida <> 'T' then Begin
      list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, 'Total Cobros Atrazados:', 1, 'Arial, negrita, 9', salida, 'N');
      list.Importe(99, list.Lineactual, '', totales[3], 2, 'Arial, negrita, 9');
      list.Linea(99, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
    end else Begin
      list.LineaTxt('', True);
      list.LineaTxt('Total Cobros Atrazados:' + utiles.espacios(66 - (Length('Total Cobros Atrazados:'))), False);
      list.ImporteTxt(totales[3], 12, 2, True);
      list.LineaTxt('', True);
    end;
  end else
    if salida <> 'T' then list.Linea(0, 0, 'No Presenta Cuotas Impagas', 1, 'Arial, normal, 9', salida, 'S') else list.LineaTxt('No Presenta Cuotas Impagas', True);

  if salida = 'T' then list.FinalizarExportacion else list.FinList;
end;

procedure TTCuotas.listLineaAtrazos(xidtitular: String; salida: char);
var
  i, j, k, m, it: Integer;
Begin
  if salida <> 'T' then it := 10 else it := 6;

  if totales[1] > 0 then Begin
    if idanter1 <> xidtitular then Begin
      cliente.getDatos(xidtitular);
      if salida <> 'T' then list.Linea(0, 0, Copy(cliente.nombre, 1, 27), 1, 'Arial, normal, 8', salida, 'N') else list.LineaTxt(Copy(cliente.Nombre, 1, 27) + utiles.espacios(28 - (Length(TrimRight(Copy(cliente.Nombre, 1, 27))))), False);
    end else
      if salida <> 'T' then list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');// else list.LineaTxt(utiles.espacios(28), False);

    j := 21; k := 1; m := 0;
    for i := 1 to detalle.Count do Begin
      Inc(m);
      if m > it then Begin
        if salida <> 'T' then Begin
          list.Linea(99, list.Lineactual, '', k + 1, 'Arial, normal, 8', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
        end else Begin
          list.LineaTxt('', True);
          list.LineaTxt(utiles.espacios(28), False);
        end;
        j := 21; k := 1; m := 1;
      end;
      j := j + 6;
      k := k + 1;
      if salida <> 'T' then list.Linea(j, list.Lineactual, detalle.Strings[i-1], k, 'Arial, normal, 8', salida, 'N') else list.LineaTxt(detalle.Strings[i-1] + ' ', False);
    end;

    if salida <> 'T' then Begin
      list.importe(92, list.Lineactual, '00', totales[1], k + 1, 'Arial, normal, 8');
      list.importe(99, list.Lineactual, '', totales[2], k + 2, 'Arial, normal, 8');
      list.Linea(99, list.Lineactual, '', k + 3, 'Arial, normal, 8', salida, 'S');
    end else Begin
      list.LineaTxt('  ', False);
      list.importeTxt(totales[1], 2, 0, False);
      list.importeTxt(totales[2], 10, 2, True);
    end;
    totales[3] := totales[3] + totales[2];
    l := True;
    idanter1 := xidtitular;
    if salida <> 'T' then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S') else list.LineaTxt('', True);
  end;
  detalle.Clear;
  totales[1] := 0;
  totales[2] := 0;
end;


//------------------------------------------------------------------------------

procedure TTCuotas.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  cliente.conectar;
  empresa.conectar;
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
end;

procedure TTCuotas.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  cliente.desconectar;
  empresa.desconectar;
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function cuota: TTCuotas;
begin
  if xcuota = nil then
    xcuota := TTCuotas.Create;
  Result := xcuota;
end;

{===============================================================================}

initialization

finalization
  xcuota.Free;

end.
