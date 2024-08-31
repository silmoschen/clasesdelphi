unit CIva_InformeAnualBorda;

interface

uses CIvaBorda, CTablaIva, CCNetos, SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM, CProvin, CEmpresas, Classes;

const
  meses: array[1..12] of string = ('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'julio', 'Agosto', 'Setiembre', 'Octubre', 'Noviembre', 'Diciembre');
  elementos = 10;

type

TTIvaInfAnual = class(TTIva)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ListInfAnual(xperiodo, xdfr, xhfr: string; salida: char; xfecharecep: boolean);
 private
  { Declaraciones Privadas }
  totNeto2: Real;
  procedure PrepararCompras(xperiodo, xdfr, xhfr: string; salida: char; fecharecep: boolean);
  procedure PrepararVentas(xperiodo, xdfr, xhfr: string; salida: char; fecharecep: boolean);
  procedure Listar(salida: char);
  procedure transpMes(mesanter, operacion: string);
  procedure iniciarTot;
  procedure TOperacion(salida: char; movim: string);
  procedure ListTotal(xoperacion, salida: char);
  procedure ListResumen(xperiodo: string; salida: char);
  procedure Titulo(salida: char; movim, xperiodo: string);
end;

function iva: TTIvaInfAnual;

implementation

var
  xiva: TTIvaInfAnual = nil;

constructor TTIvaInfAnual.Create;
begin
  inherited Create;
end;

destructor TTIvaInfAnual.Destroy;
begin
  inherited Destroy;
end;

{ Resumen Anual I.V.A. }

procedure TTIvaInfAnual.Titulo(salida: char; movim, xperiodo: string);
{Objetivo....: Emitir los Títulos del Listado}
var
  i: integer;
begin
  pag := pag + 1;
  if (salida = 'P') or (salida = 'I') then Begin
    list.IniciarTitulos;
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, empresa.Nombre, 1, 'Arial, normal, 8', salida, 'S');
    if empresa.Rsocial2 <> '' then list.Linea(0, 0, empresa.Rsocial2, 1, 'Arial, normal, 7', salida, 'S');
    list.Linea(0, 0, empresa.Nrocuit, 1, 'Arial, normal, 7', salida, 'S');
    list.Linea(0, 0, empresa.Domicilio, 1, 'Arial, normal, 7', salida, 'S');
    list.Linea(0, 0, ' ',1 , 'Arial, normal, 7', salida, 'S');

    list.Linea(0, 0, 'Resumen Anual  -  ' + movim + '  -   Año: ' + xperiodo, 1, 'Arial, negrita, 14', salida, 'S');
    if movim = 'Compras' then list.titulo(0, 0, utiles.espacios(40) + 'Hoja Nº: ' + utiles.sLlenarIzquierda((FloatToStr(pag)), 4, '0'), 1, 'Times New Roman, ninguno, 8');
    list.Linea(0, 0, ' ',1 , 'Arial, normal, 7', salida, 'S');
  end else Begin
    list.LineaTxt(CHR(18), True);
    For i := 1 to empresa.margenes do list.LineaTxt('  ', True);
    list.LineaTxt(empresa.Nombre, True);
    if empresa.Rsocial2 <> '' then list.LineaTxt(empresa.Rsocial2, True);
    list.LineaTxt(empresa.Nrocuit, True);
    list.LineaTxt(empresa.Domicilio, True);
    list.LineaTxt('  ', True);
    list.LineaTxt('Resumen Anual  -  ' + movim + '  Anio: ' + xperiodo + CHR(15), True);
    if movim = 'Compras' then list.LineaTxt(utiles.espacios(40) + 'Hoja Nº: ' + utiles.sLlenarIzquierda((FloatToStr(pag)), 4, '0'), True);
    list.LineaTxt(' ', True);
  end;
end;

procedure TTIvaInfAnual.TOperacion(salida: char; movim: string);
{Objetivo....: Emitir los Titulos de compras y ventas}
begin
  if (salida = 'P') or (salida = 'I') then Begin
    if movim = 'Ventas' then Begin
      // 1º Línea
      list.linea(0, 0, 'Mes de' ,1 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(26,  list.lineactual, 'Neto 1' ,2 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(41,  list.lineactual, 'Neto 2' ,3 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(51,  list.lineactual, 'Operaciones' ,4 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(68,  list.lineactual, 'Conceptos' ,5 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(87,  list.lineactual, 'I.V.A.' ,6 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(101,  list.lineactual, 'I.V.A.' ,7 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(112, list.lineactual, 'Retenciones' ,8 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(127, list.lineactual, 'Retenciones' ,9 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(146, list.lineactual, 'Total' ,10 , 'Arial, cursiva, 8', salida, 'N');
      // 2º Línea
      list.linea(0, 0, 'Registro' ,1 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(54,  list.lineactual, 'Exentas' ,2 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(66,  list.lineactual, 'No Gravados' ,3 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(99,  list.lineactual, 'Recargo' ,4 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(116, list.lineactual, 'Varias' ,7 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(128, list.lineactual, 'Ing.Brutos' ,8 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(142, list.lineactual, 'Operación' ,9 , 'Arial, cursiva, 8', salida, 'S');
    end;
    if movim = 'Compras' then Begin
      // 1º Línea
      list.linea(0, 0, 'Mes de' ,1 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(26, list.lineactual, 'Neto' ,2 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(36, list.lineactual, 'Operaciones' ,3 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(52, list.lineactual, 'Conceptos' ,4 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(71, list.lineactual, 'I.V.A.' ,5 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(86, list.lineactual, 'I.V.A.' ,6 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(97, list.lineactual, 'Retenciones' ,7 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(112, list.lineactual, 'Retenciones',8 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(127, list.lineactual, 'Retenciones' ,9 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(146, list.lineactual, 'Total' ,10 , 'Arial, cursiva, 8', salida, 'S');
      // 2º Línea
      list.linea(0, 0, 'Registro' ,1 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(23, list.lineactual, 'Gravado' ,2 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(39, list.lineactual, 'Exentas' ,3 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(51, list.lineactual, 'No Gravados' ,4 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(69, list.lineactual, '' ,5 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(84, list.lineactual, 'Recargo' ,6 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(101, list.lineactual, 'Varias' ,7 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(113, list.lineactual, 'Ganancias' ,8 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(128, list.lineactual, 'Ing. Brutos' ,9 , 'Arial, cursiva, 8', salida, 'N');
      list.linea(143, list.lineactual, 'Operación' ,10 , 'Arial, cursiva, 8', salida, 'S');
    end;
    list.linea(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.linea(0, 0, '  ', 1, 'Arial, negrita, 8', salida, 'S');
  end else Begin
    list.LineaTxt(utiles.sLLenarIzquierda(lin, 190, CHR(196)), True);
    if movim = 'Ventas' then Begin
      // 1º Línea
      list.LineaTxt('Mes de', False);
      list.LineaTxt(utiles.espacios(63) + 'Neto  Operaciones    Conceptos       I.V.A.       I.V.A.  Retenciones   Percepci' + CHR(162) + 'n        Total  C.F. Resol.   Reintegros', True);
      // 2º Línea
      list.LineaTxt(utiles.espacios(66) + 'Gravado      Exentas  No Gravados       Normal      Recargo       I.V.A.  Ing. Brutos    Operacion       D.G.I.', True);
    end;
    if movim = 'Compras' then Begin
      // 1º Línea
      list.LineaTxt('Mes de', False);
      list.LineaTxt(utiles.espacios(63) + 'Neto  Operaciones    Conceptos       I.V.A.       I.V.A.  Cred. p/Res.  Combustib.        Total  C.F. Resol.       Reten.', True);
      // 2º Línea
      list.LineaTxt(utiles.espacios(66) + 'Gravado      Exentas  No Gravados       Normal      Recargo       Varias     Liquidos    Operacion       Varias     Combust.', True);
    end;
    list.LineaTxt(utiles.sLLenarIzquierda(lin, 190, CHR(196)), True);
  end;
end;

procedure TTIvaInfAnual.PrepararVentas(xperiodo, xdfr, xhfr: string; salida: char; fecharecep: boolean);
var
  r: TQuery;
begin
  iniciarTot;
  if fecharecep then r := datosdb.tranSQL(path, 'SELECT fecha, sucursal, ferecep, nettot, opexenta, connograv, iva, ivarec, percep1, percep2, cdfiscal, totoper, codmov FROM ivaventa WHERE ferecep >= ' + '"' + utiles.sExprFecha2000(xdfr) + '"' + ' AND ferecep <= ' + '"' + utiles.sExprFecha2000(xhfr) + '"' + ' ORDER BY ferecep')
     else r := datosdb.tranSQL(path, 'SELECT fecha, sucursal, ferecep, nettot, opexenta, connograv, iva, ivarec, percep1, percep2, cdfiscal, totoper, codmov FROM ivaventa WHERE fecha >= ' + '"' + utiles.sExprFecha2000(xdfr) + '"' + ' AND fecha <= ' + '"' + utiles.sExprFecha2000(xhfr) + '"' + ' ORDER BY fecha');
  r.Open; r.First;
  if not fecharecep then mesanter := Copy(r.FieldByName('fecha').AsString, 5, 2) else mesanter := Copy(r.FieldByName('ferecep').AsString, 5, 2);
  while not r.EOF do
    begin
      if not fecharecep then Begin   // Por fecha de emisión
        if Copy(r.FieldByName('fecha').AsString, 5, 2) <> mesanter then transpMes(mesanter, '1')
      end else Begin
        if Copy(r.FieldByName('ferecep').AsString, 5, 2) <> mesanter then transpMes(mesanter, '1');
      end;
      netos.getDatos(r.FieldByName('codmov').AsString);
      tabliva.getDatos(netos.codiva);
      if tabliva.Ncol = '1' then Begin
        if Copy(r.FieldByName('sucursal').AsString, 1, 1) <> '-' then totNettot := totNettot + r.FieldByName('Nettot').AsFloat else
          totNeto2 := totNeto2 + r.FieldByName('Nettot').AsFloat;
      end;
      if tabliva.Ncol = '2' then totNeto2 := totNeto2 + r.FieldByName('Nettot').AsFloat;
      totOpexenta   := totOpexenta   + r.FieldByName('opexenta').AsFloat;
      totConnograv  := totConnograv  + r.FieldByName('connograv').AsFloat;
      totIva        := totIva        + r.FieldByName('iva').AsFloat;
      totIvarec     := totIvarec     + r.FieldByName('ivarec').AsFloat;
      totPercepcion := totPercepcion + r.FieldByName('percep1').AsFloat;
      totPergan     := totPergan     + r.FieldByName('percep2').AsFloat;
      totTotOper    := totTotOper    + r.FieldByName('totoper').AsFloat;
      totCdfiscal   := totCdFiscal   + r.FieldByName('cdfiscal').AsFloat;
      if not fecharecep then mesanter := Copy(r.FieldByName('fecha').AsString, 5, 2) else mesanter := Copy(r.FieldByName('ferecep').AsString, 5, 2);
      r.Next;
    end;
  transpMes(mesanter, '1');
  r.Close; r.Free;
end;

procedure TTIvaInfAnual.PrepararCompras(xperiodo, xdfr, xhfr: string; salida: char; fecharecep: boolean);
var
  r: TQuery;
begin
  iniciarTot;
  if fecharecep then r := datosdb.tranSQL(path, 'SELECT fecha, ferecep, nettot, opexenta, connograv, iva, ivarec, percep1, percep2, cdfiscal, totoper, retencion, importe, retencionib FROM ivacompr WHERE ferecep >= ' + '"' + utiles.sExprFecha2000(xdfr) + '"' + ' AND ferecep <= ' + '"' + utiles.sExprFecha2000(xhfr) + '"' + ' ORDER BY ferecep')
     else r := datosdb.tranSQL(path, 'SELECT fecha, ferecep, nettot, opexenta, connograv, iva, ivarec, percep1, percep2, cdfiscal, totoper, retencion, importe, retencionib FROM ivacompr WHERE fecha >= ' + '"' + utiles.sExprFecha2000(xdfr) + '"' + ' AND fecha <= ' + '"' + utiles.sExprFecha2000(xhfr) + '"' + ' ORDER BY fecha');
  r.Open; r.First;
  if not fecharecep then mesanter := Copy(r.FieldByName('fecha').AsString, 5, 2) else mesanter := Copy(r.FieldByName('ferecep').AsString, 5, 2);
  while not r.EOF do
    begin
      if not fecharecep then Begin
        if Copy(r.FieldByName('fecha').AsString, 5, 2) <> mesanter then transpMes(mesanter, '2')
      end else Begin
        if Copy(r.FieldByName('ferecep').AsString, 5, 2) <> mesanter then transpMes(mesanter, '2')
      end;
      totNettot     := totNettot     + r.FieldByName('nettot').AsFloat;
      totOpexenta   := totOpexenta   + r.FieldByName('opexenta').AsFloat;
      totConnograv  := totConnograv  + r.FieldByName('connograv').AsFloat;
      totIva        := totIva        + r.FieldByName('iva').AsFloat;
      totIvarec     := totIvarec     + r.FieldByName('ivarec').AsFloat;
      totPercepcion := totPercepcion + r.FieldByName('Cdfiscal').AsFloat;
      totPergan     := totPergan     + r.FieldByName('Percep1').AsFloat;
      totTotOper    := totTotOper    + r.FieldByName('totoper').AsFloat;
      totCdfiscal   := totCdfiscal   + r.FieldByName('retencionIB').AsFloat;
      if not fecharecep then mesanter := Copy(r.FieldByName('fecha').AsString, 5, 2) else mesanter := Copy(r.FieldByName('ferecep').AsString, 5, 2);
      finales[5]    := finales[5]    + r.FieldByName('Percep1').AsFloat;
      r.Next;
    end;
  transpMes(mesanter, '2');
  r.Close; r.Free;
end;

procedure TTIvaInfAnual.transpMes(mesanter, operacion: string);
// Objetivo...: retener los resultados mensuales en un arreglo
begin
  if (operacion = '2') and (Length(trim(mesanter)) > 0) then
    begin
      ctotales[StrToInt(mesanter), 1] := totNettot;
      ctotales[StrToInt(mesanter), 2] := totOpexenta;
      ctotales[StrToInt(mesanter), 3] := totConnoGrav;
      ctotales[StrToInt(mesanter), 4] := totIva;
      ctotales[StrToInt(mesanter), 5] := totIvarec;
      ctotales[StrToInt(mesanter), 6] := totPercepcion;
      ctotales[StrToInt(mesanter), 7] := totPergan;
      ctotales[StrToInt(mesanter), 8] := totCdfiscal;
      ctotales[StrToInt(mesanter), 9] := totTotOper;
      ctotales[StrToInt(mesanter),10] := totRetencion;
    end;
  if (operacion = '1') and (Length(trim(mesanter)) > 0) then
    begin
      vtotales[StrToInt(mesanter), 1] := totNettot;
      vtotales[StrToInt(mesanter), 2] := totNeto2;
      vtotales[StrToInt(mesanter), 3] := totOpexenta;
      vtotales[StrToInt(mesanter), 4] := totConnoGrav;
      vtotales[StrToInt(mesanter), 5] := totIva;
      vtotales[StrToInt(mesanter), 6] := totIvarec;
      vtotales[StrToInt(mesanter), 7] := totPercepcion;
      vtotales[StrToInt(mesanter), 8] := totPergan;
      vtotales[StrToInt(mesanter), 9] := totTotOper;
    end;
  iniciarTot;
end;

procedure TTIvaInfAnual.iniciarTot;
// Objetivo...: inicilizar subtotales
begin
  totNettot := 0; totOpexenta := 0; totConnoGrav := 0; totIva := 0; totIvarec := 0; totPercepcion := 0; totPergan := 0; totTotOper := 0; totCdfiscal := 0; totRetencion := 0; totNeto2 := 0;
end;

procedure TTIvaInfAnual.Listar(salida: char);
// Objetivo...: Listar Ventas
var
  i: integer;
begin
  TOperacion(salida, 'Ventas');   // Ventas
  totNettot := 0; totOpexenta := 0; totConnograv := 0; totIva := 0; totIvarec := 0; totPercepcion := 0; totPergan := 0; totTotOper := 0; totCdfiscal := 0; totcReintegro := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    For i := 1 to 12 do Begin
      list.Linea(0, 0,  utiles.sLlenarIzquierda(IntToStr(i), 2, '0') + ' - ' + meses[i], 1, 'Arial, normal, 8', salida, 'N');
      list.importe(30,  list.lineactual, '', vtotales[i, 1], 2, 'Arial, normal, 8');
      list.importe(45,  list.lineactual, '', vtotales[i, 2], 3, 'Arial, normal, 8');
      list.importe(60,  list.lineactual, '', vtotales[i, 3], 4, 'Arial, normal, 8');
      list.importe(75,  list.lineactual, '', vtotales[i, 4], 5, 'Arial, normal, 8');
      list.importe(90,  list.lineactual, '', vtotales[i, 5], 6, 'Arial, normal, 8');
      list.importe(105, list.lineactual, '', vtotales[i, 6], 7, 'Arial, normal, 8');
      list.importe(120, list.lineactual, '', vtotales[i, 7], 8, 'Arial, normal, 8');
      list.importe(135, list.lineactual, '', vtotales[i, 8], 9, 'Arial, normal, 8');
      list.importe(150, list.lineactual, '', vtotales[i, 9], 10, 'Arial, normal, 8');
      totNettot    := totNettot    + vtotales[i, 1]; totOpexenta   := totOpexenta   + vtotales[i, 2];
      totConnograv := totConnograv + vtotales[i, 3]; totIva        := totIva        + vtotales[i, 4];
      totIvarec    := totIvarec    + vtotales[i, 5]; totPercepcion := totPercepcion + vtotales[i, 6];
      totPergan    := totPergan    + vtotales[i, 7]; totTotOper    := totTotOper    + vtotales[i, 8];
      totCdfiscal  := totCdfiscal  + vtotales[i, 9];
    end;
    ListTotal('V', salida);
    finales[1] := totIva + totIvarec; finales[3] := totPercepcion;

    totNettot := 0; totOpexenta := 0; totConnograv := 0; totIva := 0; totIvarec := 0; totPercepcion := 0; totPergan := 0; totTotOper := 0; totCdfiscal := 0; totRetencion := 0;
    list.linea(0, 0, 'Resumen Anual  -  Compras', 1, 'Arial, negrita, 14', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    TOperacion(salida, 'Compras');   // Compras
    For i := 1 to 12 do Begin
      list.Linea(0, 0,  utiles.sLlenarIzquierda(IntToStr(i), 2, '0') + ' - ' + meses[i], 1, 'Arial, normal, 8', salida, 'N');
      list.importe(30,  list.lineactual, '', ctotales[i, 1], 2, 'Arial, normal, 8');
      list.importe(45,  list.lineactual, '', ctotales[i, 2], 3, 'Arial, normal, 8');
      list.importe(60,  list.lineactual, '', ctotales[i, 3], 4, 'Arial, normal, 8');
      list.importe(75,  list.lineactual, '', ctotales[i, 4], 5, 'Arial, normal, 8');
      list.importe(90,  list.lineactual, '', ctotales[i, 5], 6, 'Arial, normal, 8');
      list.importe(105, list.lineactual, '', ctotales[i, 6], 7, 'Arial, normal, 8');
      list.importe(120, list.lineactual, '', ctotales[i, 7], 8, 'Arial, normal, 8');
      list.importe(135, list.lineactual, '', ctotales[i, 8], 9, 'Arial, normal, 8');
      list.importe(150, list.lineactual, '', ctotales[i, 9], 10, 'Arial, normal, 8');
      list.Linea(166, list.Lineactual, ' ', 11, 'Arial, normal, 8', salida, 'S');
      totNettot    := totNettot    + ctotales[i, 1]; totOpexenta   := totOpexenta   + ctotales[i, 2];
      totConnograv := totConnograv + ctotales[i, 3]; totIva        := totIva        + ctotales[i, 4];
      totIvarec    := totIvarec    + ctotales[i, 5]; totPercepcion := totPercepcion + ctotales[i, 6];
      totPergan    := totPergan    + ctotales[i, 7]; totTotOper    := totTotOper    + ctotales[i, 8];
      totCdfiscal  := totCdfiscal  + ctotales[i, 9]; totRetencion  := totRetencion  + ctotales[i, 10];
    end;
    ListTotal('C', salida);
    finales[2] := totIva; finales[3] := finales[3] + totPercepcion; finales[4] := totRetencion;

  end else Begin

    For i := 1 to 12 do Begin
      nombre := utiles.sLLenarIzquierda(IntToStr(i), 2, '0') + ' - ' + meses[i] + utiles.espacios(60 - Length(Trim(utiles.sLlenarIzquierda(IntToStr(i), 2, '0') + ' - ' + meses[i])));
      list.LineaTxt(nombre, False);

      list.ImporteTxt(vtotales[i, 1], 13, 2, False);
      list.ImporteTxt(vtotales[i, 2], 13, 2, False);
      list.ImporteTxt(vtotales[i, 3], 13, 2, False);
      list.ImporteTxt(vtotales[i, 4], 13, 2, False);
      list.ImporteTxt(vtotales[i, 5], 13, 2, False);
      list.ImporteTxt(vtotales[i, 6], 13, 2, False);
      list.ImporteTxt(vtotales[i, 7], 13, 2, False);
      list.ImporteTxt(vtotales[i, 8], 13, 2, False);
      if lista = Nil then list.ImporteTxt(vtotales[i, 9], 13, 2, True) else Begin
        list.ImporteTxt(vtotales[i, 9], 13, 2, False);
        list.ImporteTxt(StrToFloat(lista.Strings[i-1]), 13, 2, True);
        totcReintegro := totcReintegro + StrToFloat(lista.Strings[i-1]);
      end;

      totNettot    := totNettot    + vtotales[i, 1]; totOpexenta   := totOpexenta   + vtotales[i, 2];
      totConnograv := totConnograv + vtotales[i, 3]; totIva        := totIva        + vtotales[i, 4];
      totIvarec    := totIvarec    + vtotales[i, 5]; totPercepcion := totPercepcion + vtotales[i, 6];
      totPergan    := totPergan    + vtotales[i, 7]; totTotOper    := totTotOper    + vtotales[i, 8];
      totCdfiscal  := totCdfiscal  + vtotales[i, 9];
    end;
    ListTotal('V', salida);
    finales[1] := totIva + totIvarec; finales[3] := totPercepcion;
    totNettot := 0; totOpexenta := 0; totConnograv := 0; totIva := 0; totIvarec := 0; totPercepcion := 0; totPergan := 0; totTotOper := 0; totCdfiscal := 0; totRetencion := 0;

    list.LineaTxt(CHR(18), True);
    list.LineaTxt(' ', True);
    list.LineaTxt('Resumen Anual  -  Compras' + CHR(15), True);
    list.LineaTxt(' ', True);
    TOperacion(salida, 'Compras');   // Compras
    list.LineaTxt(' ', True);

    For i := 1 to 12 do Begin
      nombre := utiles.sLlenarIzquierda(IntToStr(i), 2, '0') + ' - ' + meses[i] + utiles.espacios(60 - Length(Trim(utiles.sLLenarIzquierda(IntToStr(i), 2, '0') + ' - ' + meses[i])));
      list.LineaTxt(nombre, False);
      list.ImporteTxt(ctotales[i, 1], 13, 2, False);
      list.ImporteTxt(ctotales[i, 2], 13, 2, False);
      list.ImporteTxt(ctotales[i, 3], 13, 2, False);
      list.ImporteTxt(ctotales[i, 4], 13, 2, False);
      list.ImporteTxt(ctotales[i, 5], 13, 2, False);
      list.ImporteTxt(ctotales[i, 6], 13, 2, False);
      list.ImporteTxt(ctotales[i, 7], 13, 2, False);
      list.ImporteTxt(ctotales[i, 8], 13, 2, False);
      list.ImporteTxt(ctotales[i, 9], 13, 2, False);
      list.ImporteTxt(ctotales[i,10], 13, 2, True);
      totNettot    := totNettot     + ctotales[i, 1]; totOpexenta   := totOpexenta   + ctotales[i, 2];
      totConnograv := totConnograv  + ctotales[i, 3]; totIva        := totIva        + ctotales[i, 4];
      totIvarec    := totIvarec     + ctotales[i, 5]; totPercepcion := totPercepcion + ctotales[i, 6];
      totPergan    := totPergan     + ctotales[i, 7]; totTotOper    := totTotOper    + ctotales[i, 8];
      totCdfiscal  := totCdfiscal   + ctotales[i, 9]; totRetencion  := totRetencion  + ctotales[i, 10]; //totcRetencion:= totcRetencion + ctotales[i, 10];
    end;
    finales[2] := totIva; finales[3] := finales[3] + totPercepcion; finales[4] := totRetencion;
    ListTotal('C', salida);
  end;
end;

procedure TTIvaInfAnual.ListInfAnual(xperiodo, xdfr, xhfr: string; salida: char; xfecharecep: boolean);
var
  i, j: integer;
begin
  For i := 1 to 12 do
    For j := 1 to elementos do Begin
      ctotales[i, j] := 0; vtotales[i, j] := 0;
    end;
  for i := 1 to elementos do finales[i] := 0;
  // Preparamos el rango de fechas
  list.tipolist := salida;
  df := '01/01/' + Copy(xperiodo, 3, 2); hf := '31/12/' + Copy(xperiodo, 3, 2);
  if not inf_iniciado then Begin
    IniciarInforme(salida);
    if salida = 'I' then list.ImprimirHorizontal;
  end else
    if salida <> 'T' then Begin
      if salida = 'I' then list.ImprimirHorizontal;
      list.IniciarNuevaPagina;
    end else
      if inf_iniciado then List.LineaTxt(CHR(12), True);
  inf_iniciado := True;
  titulo(salida, 'Ventas', xperiodo);
  PrepararVentas(xperiodo, df, hf, salida, xfecharecep);
  PrepararCompras(xperiodo, xdfr, xhfr, salida, xfecharecep);
  Listar(salida);
  ListResumen(xperiodo, salida);
  if salida <> 'T' then list.CompletarPagina;
end;

procedure TTIvaInfAnual.ListTotal(xoperacion, salida: char);
// Objetivo...: Listar Subtotales I.V.A.
begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0,  list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0,  'Subtotales .........:', 1, 'Arial, normal, 8', salida, 'N');
    list.importe(30,  list.lineactual, '', totNettot, 2, 'Arial, normal, 8');
    list.importe(45,  list.lineactual, '', totOpexenta, 3, 'Arial, normal, 8');
    list.importe(60,  list.lineactual, '', totConnograv, 4, 'Arial, normal, 8');
    list.importe(75,  list.lineactual, '', totIva, 5, 'Arial, normal, 8');
    list.importe(90,  list.lineactual, '', totIvarec, 6, 'Arial, normal, 8');
    list.importe(105, list.lineactual, '', totPercepcion, 7, 'Arial, normal, 8');
    list.importe(120, list.lineactual, '', totPergan, 8, 'Arial, normal, 8');
    list.importe(135, list.lineactual, '', totTotOper, 9, 'Arial, normal, 8');
    list.importe(150, list.lineactual, '', totCdfiscal, 10, 'Arial, normal, 8');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 10', salida, 'S');
  end;
  if salida = 'T' then Begin
    list.LineaTxt(utiles.sLLenarIzquierda(lin, 190, CHR(196)), True);
    nombre := 'Subtotales .........:' + utiles.espacios(60 - Length(Trim('Subtotales .........:')));
    list.LineaTxt(nombre, False);
    list.ImporteTxt(totNettot, 13, 2, False);
    list.ImporteTxt(totOpexenta, 13, 2, False);
    list.ImporteTxt(totConnograv, 13, 2, False);
    list.ImporteTxt(totIva, 13, 2, False);
    list.ImporteTxt(totIvarec, 13, 2, False);
    list.ImporteTxt(totPercepcion, 13, 2, False);
    list.ImporteTxt(totPergan, 13, 2, False);
    list.ImporteTxt(totTotOper, 13, 2, False);
    if xoperacion = 'C' then list.ImporteTxt(totCdfiscal, 13, 2, False) else list.ImporteTxt(totCdfiscal, 13, 2, False);
    if xoperacion = 'C' then list.ImporteTxt(totRetencion, 13, 2, True);
    if xoperacion = 'V' then list.ImporteTxt(totcReintegro, 13, 2, True);
  end;
end;

procedure TTIvaInfAnual.ListResumen(xperiodo: string; salida: char);
// Objetivo...: Resumen del Informe Anual
begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 12', salida, 'S');
    list.Linea(0, 0, 'Resultado para la Evaluación frente a D.G.I. ', 1,'Arial, normal, 12', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Débito Fiscal ..................: ', 1, 'Courier New, normal, 10', salida, 'N');
    list.importe(60,  list.lineactual, '', finales[1] * (-1), 2, 'Courier New, normal, 8');
    list.Linea(90, list.lineactual, ' ', 3, 'Courier New, normal, 10', salida, 'S');
    list.Linea(0, 0, 'Crédito Fiscal .................: ', 1, 'Courier New, normal, 10', salida, 'N');
    list.importe(60,  list.lineactual, '', finales[2], 2, 'Courier New, normal, 8');
    list.Linea(90, list.lineactual, ' ', 3, 'Courier New, normal, 10', salida, 'S');
    list.Linea(0, 0, 'Saldo Período Anterior .........: ', 1, 'Courier New, normal, 10', salida, 'S');
    list.importe(60,  list.lineactual, '', saldoanter, 2, 'Courier New, normal, 8');
    list.Linea(0, 0, 'Retenciones y Créditos .........: ', 1, 'Courier New, normal, 10', salida, 'N');
    list.importe(60,  list.lineactual, '', finales[3], 2, 'Courier New, normal, 8');
    list.Linea(90, list.lineactual, ' ', 3, 'Courier New, normal, 10', salida, 'S');
    list.Linea(0, 0, 'Reintegros I.V.A. ..............: ', 1, 'Courier New, normal, 10', salida, 'N');
    list.importe(60,  list.lineactual, '', totcReintegro * (-1), 2, 'Courier New, normal, 8');
    list.Linea(90, list.lineactual, ' ', 3, 'Courier New, normal, 10', salida, 'S');
    list.Linea(0, 0, 'Saldo ..........................: ', 1, 'Courier New, normal, 10', salida, 'N');
    list.importe(60,  list.lineactual, '', (finales[1] - (finales[2] + saldoanter + finales[3]) + totcReintegro) * (-1), 2, 'Courier New, normal, 8');
    list.linea(0, 0, list.linealargopagina(salida), 1, 'Corrier New, normal, 11', salida, 'N');
  end else Begin
    List.LineaTxt(' ', True);
    List.LineaTxt(CHR(18), True);
    List.LineaTxt('Resultado para la Evaluacion frente a D.G.I. ', True);
    List.LineaTxt(' ', True);
    nombre := 'Debito Fiscal ..................: ' + utiles.espacios(59 - Length(Trim('Débito Fiscal ..................: ')));
    List.LineaTxt(nombre, False);
    list.ImporteTxt(finales[1] * (-1), 13, 2, True);
    nombre := 'Credito Fiscal .................: ' + utiles.espacios(59 - Length(Trim('Crédito Fiscal .................: ')));
    List.LineaTxt(nombre, False);
    List.ImporteTxt(finales[2], 13, 2, True);
    nombre := 'Saldo Periodo Anterior .........: ' + utiles.espacios(59 - Length(Trim('Saldo Período Anterior .........: ')));
    List.LineaTxt(nombre, False);
    List.ImporteTxt(saldoanter, 13, 2, True);
    nombre := 'Retenciones y Creditos .........: ' + utiles.espacios(59 - Length(Trim('Retenciones y Créditos .........: ')));
    List.LineaTxt(nombre, False);
    List.ImporteTxt(finales[3], 13, 2, True);
    nombre := 'Reintegros I.V.A. ..............: ' + utiles.espacios(59 - Length(Trim('Reintegros I.V.A. ..............: ')));
    List.LineaTxt(nombre, False);
    List.ImporteTxt(totcReintegro * (-1), 13, 2, True);
    nombre := 'Saldo ..........................: ' + utiles.espacios(59 - Length(Trim('Saldo ..........................: ')));
    List.LineaTxt(nombre, False);
    List.ImporteTxt((finales[1] - (finales[2] + saldoanter + finales[3]) + totcReintegro) * (-1), 13, 2, True);
  end;
end;

{===============================================================================}

function iva: TTIvaInfAnual;
begin
  if xiva = nil then
    xiva := TTIvaInfAnual.Create;
  Result := xiva;
end;

{===============================================================================}

initialization

finalization
  xiva.Free;

end.
