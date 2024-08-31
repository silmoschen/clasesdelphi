unit CIvacompraGross;

interface

uses CIva, CProveedorGross, CTablaIva, SysUtils, DB, DBTables, CBDT, CUtiles, CListar, Listado, CIDBFM, CCNetos, CEmpresas;

type

TTIvacompra = class(TTIva)
  retencion, importe: Real;
  lineassep: Integer;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;
  procedure   ListarLibroIVA_Compras(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro: string);
  procedure   List_InfAnual(desdef, hastaf: string; salida: char);
  procedure   List_Netodiscr(df, hf: string; salida: char);
  procedure   List_Codpfis(df, hf: string; salida: char);
  function    setIvaFechaRecep(xdf, xhf: string): TQuery;
  procedure   CalcularIva(xneto, xtotal: real; xcondfisc: string);
  procedure   getDatos(xidcompr, xtipo, xsucursal, xnumero, xcuit: string);

  procedure   EstablecerDatosEncabezazoInformes(xrsocial, xcuit, xdireccion, xdiscr_iva: String; xmodotexto, xmargen, xlineas, xseparacion: Integer);
  procedure   getDatosEncabezadoInformes;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  saltoManual: Boolean;
  procedure   Titulo(salida: char; mes: string);
  procedure   LineaIva(salida: char);
  procedure   Transporte(leyenda: string; salida: char);

  procedure   titulosTxt;
  procedure   SaltoTxt(salida: Char);
end;

function ivac: TTIvacompra;

implementation

var
  xivac: TTIvacompra = nil;

constructor TTIvacompra.Create;
begin
  inherited Create;
  tiva := datosdb.openDB('ivacompr', 'Idcompr;Tipo;Sucursal;Numero;Cuit');
  iiva := datosdb.openDB('netdisco', 'Idcompr;Tipo;Sucursal;Numero;Cuit;Codmov;CodItems');
  Modulo := 'C';
end;

destructor TTIvacompra.Destroy;
begin
  inherited Destroy;
end;

// ------- Gesti�n de Informes -------------

procedure TTIvaCompra.Titulo(salida: char; mes: string);
{Objetivo....: Emitir los T�tulos del Listado}
begin
  if (salida = 'I') or (salida = 'P') then Begin
    Inc(pag);
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');

    list.Titulo(0, 0, '                       ' + empresaRsocial, 1, 'Arial, normal, 7');
    list.Titulo(0, 0, '                       ' + empresaCuit, 1, 'Arial, normal, 7');
    list.Titulo(0, 0, '                       ' + empresaDireccion, 1, 'Arial, normal, 7');
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    list.Titulo(espacios, list.Lineactual, 'Libro I.V.A. Compras     -     ' + meses[StrToInt(Copy(mes, 1, 2))] + '  de  ' + Copy(mes, 4, 4), 2, 'Arial, negrita, 14');
    list.Titulo(0, 0, utiles.espacios(404) + 'Hoja N�: #pagina', 1, 'Times New Roman, ninguno, 8');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 11'); list.Titulo(espacios, list.Lineactual, list.linealargopagina(tipolist), 2, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ',1 , 'Arial, normal, 4');
    // 1� L�nea de T�tulos
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8'); list.Titulo(espacios, list.Lineactual, 'Fecha',2 , 'Arial, cursiva, 8');
    list.Titulo(17, list.lineactual, 'Comprobante' + utiles.espacios(18) + 'Proveedor',3 , 'Arial, cursiva, 8');
    list.Titulo(68, list.lineactual, 'C.U.I.T. N�  IVA',4 , 'Arial, cursiva, 8');
    list.Titulo(87, list.lineactual, 'Neto',5 , 'Arial, cursiva, 8');
    list.Titulo(98, list.lineactual, 'I.V.A.',6 , 'Arial, cursiva, 8');
    list.Titulo(107, list.lineactual, 'I.V.A.',7 , 'Arial, cursiva, 8');
    list.Titulo(115, list.lineactual, 'Percep.',8 , 'Arial, cursiva, 8');
    list.Titulo(127, list.lineactual, 'Total',9 , 'Arial, cursiva, 8');
    // 2� L�nea de T�tulos
    list.Titulo(0, 0, ' ',1 , 'Arial, cursiva, 8');
    list.Titulo(99, list.lineactual, 'R.I.',2 , 'Arial, cursiva, 8');
    list.Titulo(107, list.lineactual, 'R.N.I.',3 , 'Arial, cursiva, 8');
    list.Titulo(127, list.lineactual, 'Fact.',4 , 'Arial, cursiva, 8');

    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 11'); list.Titulo(espacios, list.Lineactual, list.linealargopagina(tipolist), 2, 'Arial, normal, 11');
    list.Titulo(0, 0, '  ', 1, 'Arial, negrita, 8');

    if totTotOper > 0 then Begin
      Transporte(utiles.espacios(20) + 'Transporte ....: ', tipolist);
      list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    end;
  end else
    titulosTxt;
  list.tipolist := salida;
end;

procedure TTIvacompra.TitulosTxt;
// Objetivo...: Gestionar titulos para listado de archivos de texto
var
  i: integer;
begin
  {Inc(pag);
  list.LineaTxt(CHR(18), true);
  For i := 1 to empresa.margenes do list.LineaTxt('  ', True);
  list.LineaTxt(empresaRsocial, true);
  list.LineaTxt(empresaCuit, true);
  list.LineaTxt(empresaDireccion, true);
  list.LineaTxt(' ', true);}
  Inc(pag);
  list.LineaTxt(CHR(18), True);
  For i := 1 to empresa.margenes do list.LineaTxt(' ', True);
  list.LineaTxt(empresaRsocial, True);
  if empresa.Rsocial2 <> '' then list.LineaTxt(empresa.Rsocial2, True);
  list.LineaTxt(empresaCuit, True);
  list.LineaTxt(empresaDireccion, True);
  list.LineaTxt('  ', True);
  list.LineaTxt('Libro I.V.A. Compras  -  ' + meses[StrToInt(Copy(xmes, 1, 2))] + '  de  ' + Copy(xmes, 4, 4), true);
  list.LineaTxt(utiles.espacios(88) + 'Hoja Nro.: ' + utiles.sLlenarIzquierda((FloatToStr(pag)), 4, '0'), true);
  list.LineaTxt(CHR(15), true);
  list.LineaTxt(utiles.sLLenarIzquierda(lin, 133, '-'), True);
  list.LineaTxt('  ', true);
  list.LineaTxt('Fecha    Comprobante     Proveedor                            C.U.I.T.    IVA      Neto   I.V.A.   I.V.A.  Percep.    Total', true);
  list.LineaTxt('                                                                                          Normal  Recargo         Operacion', true);
  list.LineaTxt(utiles.sLLenarIzquierda(lin, 133, '-'), True);
  lineasimpresas := 16;
end;

procedure TTIvaCompra.Transporte(leyenda: string; salida: char);
{Objetivo...: Transporte del Asiento Contable}
var
  i: integer;
begin
  if (salida = 'P') or (salida = 'I') then Begin
   if Trim(leyenda) = 'Subtotales:' then Begin
     if not infresumido then Begin
       list.CompletarPagina;     // Rellenamos la P�gina
       list.PrintLn(0, 0, ' ', 1, 'Arial, normal, 11');
       list.PrintLn(espacios, list.Lineactual, list.linealargopagina(salida), 2, 'Arial, normal, 11');
     end;
   end;
   list.PrintLn(0, 0, ' ', 1, 'Arial, negrita, 8');
   list.PrintLn(espacios, list.Lineactual, leyenda, 2, 'Arial, negrita, 8');

   list.importe(93, list.lineactual,  '', totNettot, 3, 'Arial, negrita, 8');
   list.importe(101, list.lineactual, '', totIva, 4, 'Arial, negrita, 8');
   list.importe(111, list.lineactual, '', totIvarec, 5, 'Arial, negrita, 8');
   list.importe(121, list.lineactual, '', totPercepcion, 6, 'Arial, negrita, 8');
   list.importe(131, list.lineactual, '', totTotoper, 7, 'Arial, negrita, 8');
   list.PrintLn(0, 0, ' ', 1, 'Arial, normal, 11');
   list.PrintLn(espacios, list.Lineactual, list.linealargopagina(salida), 2, 'Arial, normal, 11');
  end;
  if salida = 'T' then Begin
   if Trim(leyenda) = 'Subtotales:' then  // completamos
     For i := lineasimpresas to (lineas - 2) do list.LineaTxt(' ', true);

   list.LineaTxt(utiles.sLLenarIzquierda(lin, 133, '-'), True);
   nombre := leyenda + utiles.espacios(78 - Length(Trim(leyenda)));
   list.LineaTxt(nombre, False);
   list.ImporteTxt(totNettot, 9, 2, False);
   list.ImporteTxt(totIva, 9, 2, False);
   list.ImporteTxt(totIvarec, 9, 2, False);
   list.ImporteTxt(totPercepcion, 9, 2, False);
   list.ImporteTxt(totTotoper, 9, 2, True);
  end;
end;

procedure TTIvaCompra.LineaIva(salida: char);
// Objetivo...: Imprimir una L�nea de Detalle
var
  nrocuit: String;
begin
  if (salida = 'P') or (salida = 'I') then Begin
   if not infresumido then Begin
    if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> 'N' then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(espacios, list.Lineactual, utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(17, list.lineactual, tiva.FieldByName('idcompr').AsString , 3, 'Arial, normal, 8', salida, 'N');
      if tiva.FieldByName('tipomov').AsString = 'X' then list.Linea(20, list.lineactual, tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + '  ' + 'A N U L A D A' , 4, 'Arial, normal, 8', salida, 'N') else
        list.Linea(20, list.lineactual, tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + '  ' + Copy(tiva.FieldByName('rsocial').AsString, 1, 25) , 4, 'Arial, normal, 8', salida, 'N');
      if Length(Trim(tiva.FieldByName('cuit').AsString)) = 13 then list.Linea(65, list.lineactual, tiva.FieldByName('cuit').AsString, 5, 'Arial, normal, 8', salida, 'N') else list.Linea(65, list.lineactual, '00-00000000-0', 5, 'Arial, normal, 8', salida, 'N');
      list.Linea(77, list.lineactual, tiva.FieldByName('codiva').AsString, 6, 'Arial, normal, 8', salida, 'N');
    end else Begin
      list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(17, list.lineactual, ' ', 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(20, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(65, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(77, list.lineactual, ' ', 5, 'Arial, normal, 8', salida, 'N');
      list.Linea(80, list.lineactual, ' ', 6, 'Arial, normal, 8', salida, 'N');
    end;

    list.importe(91,  list.lineactual, '', tiva.FieldByName('Nettot').AsFloat, 7, 'Arial, normal, 8');
    list.importe(101,  list.lineactual, '', tiva.FieldByName('iva').AsFloat, 8, 'Arial, normal, 8');
    list.importe(111,  list.lineactual, '', tiva.FieldByName('ivarec').AsFloat, 9, 'Arial, normal, 8');
    list.importe(121,  list.lineactual, '', tiva.FieldByName('percep1').AsFloat, 10, 'Arial, normal, 8');
    list.importe(131, list.lineactual, '', tiva.FieldByName('Totoper').AsFloat, 11, 'Arial, normal, 8');
    list.Linea(132, list.lineactual, ' ', 12, 'Arial, normal, 8', salida, 'S');
   end;
  end else Begin
    if Length(Trim(tiva.FieldByName('cuit').AsString)) = 13 then nrocuit := tiva.FieldByName('cuit').AsString else nrocuit := '00-00000000-0';
    if tiva.FieldByName('tipomov').AsString = 'X' then nombre := 'A N U L A D A' + utiles.espacios(35 - Length(Trim('A N U L A D A'))) else nombre := tiva.FieldByName('rsocial').AsString + utiles.espacios(35 - Length(Trim(tiva.FieldByName('rsocial').AsString)));
    if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> 'N' then list.LineaTxt(utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString) + ' ' + tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + ' ' + nombre + ' ' + nrocuit + ' ' + tiva.FieldByName('codiva').AsString + ' ', False) else
      list.LineaTxt('                                                                              ', False);
    list.ImporteTxt(tiva.FieldByName('Nettot').AsFloat, 9, 2, False);
    list.ImporteTxt(tiva.FieldByName('iva').AsFloat, 9, 2, False);
    list.ImporteTxt(tiva.FieldByName('ivarec').AsFloat, 9, 2, False);
    list.ImporteTxt(tiva.FieldByName('percep1').AsFloat, 9, 2, False);
    list.ImporteTxt(tiva.FieldByName('totoper').AsFloat, 9, 2, True);
    Inc(lineasimpresas);
  end;

  //Subtotales
  if tiva.FieldByName('tipomov').AsString <> 'X' then Begin   // Si el comprobante no esta anulado
    totNettot     := totNettot     + tiva.FieldByName('Nettot').AsFloat;
    totIva        := totIva        + tiva.FieldByName('iva').AsFloat;
    totIvarec     := totIvarec     + tiva.FieldByName('ivarec').AsFloat;
    totPercepcion := totPercepcion + tiva.FieldByName('percep1').AsFloat;
    totTotOper    := totTotOper    + tiva.FieldByName('totoper').AsFloat;
  end;

  if salida <> 'T' then Begin
    if list.SaltoPagina then Begin
      list.PrintLn(0, 0, ' ', 1, 'Arial, normal, 11');
      list.PrintLn(espacios, list.Lineactual, list.linealargopagina(salida), 2, 'Arial, normal, 11');
      Transporte('Transporte ...:', salida);
      list.IniciarNuevaPagina;
      Transporte('Transporte ...:', salida);
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    end
  end else SaltoTxt(salida);
end;

procedure TTIvaCompra.SaltoTxt(salida: Char);
// Objetivo...: salto de p�gina archivos impresion en modo texto
var
  i: Integer;
begin
  if lineassep > 0 then SaltoManual := True else SaltoManual := False;
  if lineasimpresas > lineas then Begin
    Transporte('Transporte ...:', salida);
    if not SaltoManual then list.LineaTxt(CHR(12), True) else
      For i := 1 to LineasFinal do list.LineaTxt(' ', True);  // Salto
      For i := 1 to lineassep do list.LineaTxt(' ', True);  // Avance a la proxima hoja
    titulosTxt;
  end;
end;

{bjetivo...: Cuerpo de Emisi�n}
procedure TTIvaCompra.ListarLibroIVA_Compras(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro: string);
var
  i: string;
begin
  getDatosEncabezadoInformes;
  if salida = 'T' then if inf_iniciado then list.LineaTxt(CHR(12), True);
  if not inf_iniciado then
    if salida = 'I' then IniciarInfSubtotales(salida, 3) else IniciarInforme(salida);

  xmes        := mes;
  pag         := pag_inicial;
  list.pagina := pag_inicial;

  // Datos para Iniciar Reporte
  list.IniciarTitulos;
  if salida <> 'T' then list.ImprimirHorizontal;
  if not infresumido then Titulo(salida, mes);
  if (infresumido) and not (iva_existe) then Titulo(salida, mes);
  if (salida = 'P') or (salida = 'I') then Begin
   if (infresumido) and (iva_existe) then Begin // Datos del contribuyente
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, empresaRsocial, 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, empresaCuit, 1, 'Arial, normal, 7', salida, 'S');
    list.Linea(0, 0, empresaDireccion, 1, 'Arial, normal, 7', salida, 'S');
   end;
  end;

  iva_existe := True;

  if (salida = 'P') and (list.altopag > 0) then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      if not infresumido  then list.PrintLn(0, 0, utiles.espacios(20) + '............. Nuevo Contributente .............', 1, 'Arial, cursiva, 7');
      if not inf_iniciado then Titulo(salida, mes) else list.IniciarNuevaPagina;
    end;
  end;
  if ((salida = 'I') and (list.altopag > 0)) and not (infresumido) then reporte.NuevaPagina;

  inf_iniciado := True;
  totNettot := 0; totOpexenta := 0; totConnograv := 0; totIva := 0; totIvarec := 0; totPercepcion := 0; totPergan := 0; totTotOper := 0; totRetencion := 0;

  i := tiva.IndexFieldNames;
  tiva.IndexName := 'Fecha';
  tiva.First;

  while not tiva.EOF do Begin
    if t_filtro = '1' then     // Filtro por Fecha de Emisi�n
      if (tiva.FieldByName('fecha').AsString >= p1) and (tiva.FieldByName('fecha').AsString <= p2) then LineaIva(salida);
    if t_filtro = '2' then     // Filtro por C�digo de Movimiento
      if ((tiva.FieldByName('fecha').AsString >= p1) and (tiva.FieldByName('fecha').AsString <= p2)) and (tiva.FieldByName('codmov').AsString = p3) then LineaIva(salida);
    if t_filtro = '3' then     // Filtro por Tipo de Comprobante
      if ((tiva.FieldByName('fecha').AsString >= p1) and (tiva.FieldByName('fecha').AsString <= p2)) and (tiva.FieldByName('idcompr').AsString = p3) then LineaIva(salida);
    if t_filtro = '4' then     // Filtro por Proveedor
      if ((tiva.FieldByName('fecha').AsString >= p1) and (tiva.FieldByName('fecha').AsString <= p2)) and (tiva.FieldByName('clipro').AsString = p3) then LineaIva(salida);
    if t_filtro = '5' then     // Filtro por Fecha de Recepci�n
      if (tiva.FieldByName('ferecep').AsString >= p1) and (tiva.FieldByName('ferecep').AsString <= p2) then LineaIva(salida);
    tiva.Next;
  end;

  if (totTotOper = 0) and not (infresumido) then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'N');
    list.Linea(espacios, list.Lineactual, 'Sin Movimientos', 2, 'Arial, normal, 10', salida, 'S');
  end;
  Transporte('Subtotales:', salida);

  tiva.IndexFieldNames := i;
  if salida <> 'T' then pag := list.pagina;
end;

procedure TTIvacompra.List_Netodiscr(df, hf: string; salida: char);
// Objetivo...: Emitir Informe Resumen discrimindo por Netos
begin
  TSQL := datosdb.tranSQL(path, 'SELECT * FROM ivacompr WHERE fecha >= ' + '''' + df + '''' + ' AND fecha <= ' + '''' + hf + '''' + ' ORDER BY codmov');
  Listar_NetoDiscr('Netos Discriminados en Compras', salida);
end;

procedure TTIvacompra.List_Codpfis(df, hf: string; salida: char);
// Objetivo...: Emitir Informe Resumen discrimindo por Netos
begin
  TSQL := datosdb.tranSQL(path, 'SELECT * FROM ivacompr WHERE fecha >= ' + '''' + utiles.sExprFecha2000(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha2000(hf) + '''' + ' ORDER BY codiva');
  ListCodpfis('I.V.A. Discriminado en Compras', salida);
end;

procedure TTIvacompra.List_InfAnual(desdef, hastaf: string; salida: char);
// Objetivo...: Presentar Informe Anual
begin
  // Inicializamos las variables
  totNettot := 0; totOpexenta := 0; totConnograv := 0; totIva := 0; totIvarec := 0; totPercepcion := 0; totPergan := 0; totTotOper := 0; totCdfiscal := 0;
  tctotNettot := 0; tctotOpexenta :=0; tctotConnograv := 0; tctotIva := 0; tctotIvarec := 0; tctotPercep1 := 0; tctotCdfiscal := 0; tctotPercep2 := 0; tctotTotOper := 0;  // Totales Anuales
  TSQL := datosdb.tranSQL(path, 'SELECT * FROM ivacompr WHERE ferecep >= ' + '''' + utiles.sExprFecha2000(desdef) + '''' + ' AND ferecep <= ' + '''' + utiles.sExprFecha2000(hastaf) + '''' + ' ORDER BY ferecep');
  IniciarInforme(salida);
end;

function TTIvacompra.setIvaFechaRecep(xdf, xhf: string): TQuery;
// Objetivo...: retornar un subset con los movimientos de I.V.A. para un periodo dado
begin
  Result := datosdb.tranSQL(path, 'SELECT fecha, ferecep, nettot, opexenta, connograv, iva, ivarec, percep1, percep2, cdfiscal, totoper FROM ' + tiva.TableName +  ' WHERE ferecep >= ' + '''' + xdf + '''' + ' AND ferecep <= ' + '''' + xhf + '''' + ' ORDER BY fecha');
end;

procedure TTIvaCompra.CalcularIva(xneto, xtotal: real; xcondfisc: string);
//Objetivo...: Clacular I.V.A
begin
  ivari := xneto * (tabliva.ivari * 0.01);
  if (tabliva.AV = 'N') and (tabliva.ivarni > 0) then Begin   // El proveedor no tiene fac. de retener I.V.A.
    ivari := 0; ivarni := 0;
  end;
  if (tabliva.coeinverso > 0) and (xtotal > 0) then ivari := neto * (tabliva.ivari * 0.01);
end;

procedure TTIvacompra.getDatos(xidcompr, xtipo, xsucursal, xnumero, xcuit: string);
// Objetivo...: Cargar atributos del objeto
begin
  inherited getDatos(xidcompr, xtipo, xsucursal, xnumero, xcuit);
  if totoper <> 0 then Begin
    retencion := tiva.FieldByName('retencion').AsFloat;
    importe   := tiva.FieldByName('importe').AsFloat;
  end else Begin
    retencion := 0; importe := 0;
  end;
end;

procedure TTIvacompra.EstablecerDatosEncabezazoInformes(xrsocial, xcuit, xdireccion, xdiscr_iva: String; xmodotexto, xmargen, xlineas, xseparacion: Integer);
// Objetivo...: Para Empresas Indivduales, Datos de la configuraci�n de informes
Begin
  AssignFile(archivo, dbs.DirSistema + '\encLibros.ini');
  rewrite(archivo);
  WriteLn(archivo, xrsocial);
  WriteLn(archivo, xcuit);
  WriteLn(archivo, xdireccion);
  WriteLn(archivo, xmargen);
  WriteLn(archivo, xlineas);
  WriteLn(archivo, xmodotexto);
  WriteLn(archivo, xdiscr_iva);
  WriteLn(archivo, xseparacion);
  closeFile(archivo);
  empresaRsocial   := xrsocial;
  empresaCuit      := xcuit;
  empresaDireccion := xdireccion;
  Lineas           := xlineas;
  Margen           := xmargen;
  ImprModoTexto    := xmodotexto;
  lineassep        := xseparacion;
end;

procedure TTIvacompra.getDatosEncabezadoInformes;
Begin
  if FileExists(dbs.DirSistema + '\encLibros.ini') then Begin
    AssignFile(archivo, dbs.DirSistema + '\encLibros.ini');
    reset(archivo);
    ReadLn(archivo, empresaRsocial);
    ReadLn(archivo, empresaCuit);
    ReadLn(archivo, empresaDireccion);
    ReadLn(archivo, Lineas);
    ReadLn(archivo, Margen);
    ReadLn(archivo, ImprModoTexto);
    ReadLn(archivo, discriminaIVA);
    ReadLn(archivo, lineassep);
    closeFile(archivo);
  end;
end;

procedure TTIvacompra.conectar;
// Objetivo...: desconectar tablas de persistencia
begin
  inherited conectar;
  if conexiones = 0 then proveedor.conectar;
  Inc(conexiones);
end;

procedure TTIvacompra.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  inherited desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then proveedor.desconectar;
end;
{===============================================================================}

function ivac: TTIvacompra;
begin
  if xivac = nil then
    xivac := TTIvacompra.Create;
  Result := xivac;
end;

{===============================================================================}

initialization

finalization
  xivac.Free;

end.
