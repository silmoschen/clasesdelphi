unit CIvacompra_Veuthey;

interface

uses CIva, CProve, CEmpresas, CTablaIva, SysUtils, DB, DBTables, CBDT, CUtiles,
     CListar, Listado, CIDBFM, CCNetos, CUtilidadesArchivos, CServers2000_Excel,
     Classes, CCTipoMovIVA;

type

TTIvacompra = class(TTIva)
  Bienuso: String;
  retencion, importe: Real;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;
  procedure   ListarLibroIVA_Compras(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro: string; xlista: TStringList);
  procedure   List_InfAnual(desdef, hastaf: string; salida: char);
  procedure   List_Netodiscr(df, hf: string; salida: char);
  procedure   List_Codpfis(df, hf: string; salida: char);
  function    setIvaFechaRecep(xdf, xhf: string): TQuery;
  procedure   CalcularIva(xneto, xtotal: real; xcondfisc: string);
  procedure   getDatos(xidcompr, xtipo, xsucursal, xnumero, xcuit: string);

  procedure   Via(xvia: string);
  procedure   Exportar(xvia, xdfecha, xhfecha, xmodo: String);
  procedure   ExportarIVA(xvia, xdfecha, xhfecha, xdrive, xdir, xtipo_fecha: String);
  procedure   ExportarIVAExcel(xvia, xdfecha, xhfecha, xtipo_fecha, xcont: String);
  procedure   ProcesarDatosImportados(xvia: String);

  procedure   ListarExportacionCITI(xdesde, xhasta: String; salida: char);
  procedure   IniciarExportacionCITI(xdesde, xhasta, xarchivo: String);
  procedure   ContinuarExportacionCITI(xdesde, xhasta, xarchivo: String);
  procedure   ExportarAlCITI2016(xdesde, xhasta, xidc, xtipo, xsucursal, xnumero, xtipo_comprobante, xcodcomprador, xcuit: String);
  procedure   FinalizarExportacionCITI;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  citi: TTable;
  tf: String;
  procedure   Titulo(salida: char; mes: string);
  procedure   LineaIva(salida: char);
  procedure   Transporte(leyenda: string; salida: char);

  procedure   titulosTxt;
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
end;

destructor TTIvacompra.Destroy;
begin
  inherited Destroy;
end;

// ------- Gesti�n de Informes -------------

procedure TTIvacompra.IniciarExportacionCITI(xdesde, xhasta, xarchivo: String);
// Objetivo...: Iniciar Exportacion al CITI
begin
  AssignFile(archivo, xarchivo);
  Rewrite(archivo);
  if not FileExists(tiva.DatabaseName + '\detcitiv.db') then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\estructu\citiventas', '*.*', tiva.DatabaseName);
  citi := datosdb.openDB('detcitiv', '', '', tiva.DatabaseName);
  datosdb.tranSQL(citi.DatabaseName, 'delete from ' + citi.TableName + ' where desde = ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and hasta = ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  AssignFile(alicuotas, copy(xarchivo, 1, 3) +  'alicuotas_' + trim(copy(xarchivo, 4, 20)));
  Rewrite(alicuotas);
end;

procedure TTIvacompra.ContinuarExportacionCITI(xdesde, xhasta, xarchivo: String);
// Objetivo...: Continuar Exportacion al CITI
begin
  AssignFile(archivo, xarchivo);
  Append(archivo);
  AssignFile(alicuotas, copy(xarchivo, 1, 3) +  'alicuotas_' + trim(copy(xarchivo, 4, 20)));
  Append(alicuotas);
end;

procedure TTIvacompra.ExportarAlCITI2016(xdesde, xhasta, xidc, xtipo, xsucursal, xnumero, xtipo_comprobante, xcodcomprador, xcuit: String);
// Objetivo...: Exportar comprobante al CITI
var
  n: array[1..5] of String;
  alic: string;
begin
  citi.Open;
  getDatos(xidc, xtipo, xsucursal, xnumero, xcuit);
  tabliva.getDatos(codiva);

  n[1] := utiles.sLlenarIzquierda(numero, 20, '0');

  Write(archivo, utiles.sExprFecha2000(fecha));
  Write(archivo, trim(xtipo_comprobante));
  if (Copy(sucursal, 1, 4) <> '0000') then n[3] := Copy(sucursal, 1, 4) else
    n[3] := '0001';

  Write(archivo, utiles.sLlenarIzquierda(n[3], 5, '0'));

  Write(archivo, n[1]);
  //Write(archivo, n[1]);

  // Nro despacho importaci�n
  Write(archivo, utiles.sLlenarIzquierda('', 16, ' '));

  if (xcodcomprador = '80') or (xcodcomprador = 'PT') then Write(archivo, '80');
  if (xcodcomprador = 'PR') then Write(archivo, trim(codprovin));

  n[2] := '00000000000';
  if (xcodcomprador = '80') or (xcodcomprador = 'PT') then begin
    if Length(Trim(cuit)) = 13 then
      n[2] := Copy(cuit, 1, 2) + Copy(cuit, 4, 8) + Copy(cuit, 13, 1)
  end;

  if (xcodcomprador = 'PR') then begin
     n[2] := '00000000000';
  end;

  n[2] := utiles.sLlenarIzquierda(n[2], 20, '0');

  Write(archivo, n[2]);

  Write(archivo, utiles.StringLongitudFija(rsocial, 29));

  //utiles.msgError(xtipo_comprobante + ' ' + floattostr(totoper) + '  ' + utiles.StringLongitudFija(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(totoper))), 14));

  // Total operacion
  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(totoper))), 15, '0'));
  if (trim(xtipo_comprobante) <> '082') then
    Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(connograv))), 15, '0'))
  else
    Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(0))), 15, '0'));
  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(0))), 15, '0'));
  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(opexenta))), 15, '0'));
  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(percep1))), 15, '0'));
  //Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(0))), 15, '0'));
  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(0))), 15, '0'));
  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(0))), 15, '0'));
  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(0))), 15, '0'));
  Write(archivo, 'PES');
  Write(archivo, '0001000000');
  if (trim(xtipo_comprobante) = '082') then Write(archivo, '0') else Write(archivo, '1');
  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(0))), 16, '0'));
  //WriteLn(archivo, utiles.sExprFecha2000(fecha));
  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(0))), 15, '0'));
  // 23. Cuit emisor
  Write(archivo, utiles.sLlenarIzquierda('', 11, '0'));
  // 24
  Write(archivo, utiles.StringLongitudFija('', 29));
  // 25
  WriteLn(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(0))), 15, '0'));

  // Alicuotas -     31/03/2017
  // 00100010000000000000000063400000000000100000005000000000002100
  // 00100001000000000000000006340000000001252090004000000000013147

  netos.getDatos(codmov);
  tabliva.getDatos(netos.codiva);
  if (tabliva.ivari = 0.00) then alic := '0003';
  if (tabliva.ivari = 10.50) then alic := '0004';
  if (tabliva.ivari = 21.00) then alic := '0005';
  if (tabliva.ivari = 27.00) then alic := '0006';
  if (tabliva.ivari = 5.00) then alic := '0008';
  if (tabliva.ivari = 2.50) then alic := '0009';

  Write(alicuotas, trim(xtipo_comprobante));
  Write(alicuotas, utiles.sLlenarIzquierda(n[3], 5, '0'));
  Write(alicuotas, n[1]);

  if (xcodcomprador = '80') or (xcodcomprador = 'PT') then Write(alicuotas, '80');
  if (xcodcomprador = 'PR') then Write(alicuotas, trim(codprovin));

  n[2] := '00000000000';
  if (xcodcomprador = '80') or (xcodcomprador = 'PT') then begin
    if Length(Trim(cuit)) = 13 then
      n[2] := Copy(cuit, 1, 2) + Copy(cuit, 4, 8) + Copy(cuit, 13, 1)
  end;

  if (xcodcomprador = 'PR') then begin
     n[2] := '00000000000';
  end;

  n[2] := utiles.sLlenarIzquierda(n[2], 20, '0');

  Write(alicuotas, n[2]);  

  Write(alicuotas, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(nettot))), 15, '0'));
  Write(alicuotas, alic);
  if (iva <> 0) then WriteLn(alicuotas, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(iva))), 15, '0')) else
    WriteLn(alicuotas, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(ivarec))), 15, '0'));

  if datosdb.Buscar(citi, 'desde', 'hasta', 'idc', 'tipo', 'sucursal', 'numero', utiles.sExprFecha2000(xdesde), utiles.sExprFecha2000(xhasta), xidc, xtipo, xsucursal, xnumero) then citi.Edit else citi.Append;
  citi.FieldByName('desde').AsString    := utiles.sExprFecha2000(xdesde);
  citi.FieldByName('hasta').AsString    := utiles.sExprFecha2000(xhasta);
  citi.FieldByName('idc').AsString      := xidc;
  citi.FieldByName('tipo').AsString     := xtipo;
  citi.FieldByName('sucursal').AsString := xsucursal;
  citi.FieldByName('numero').AsString   := xnumero;
  citi.FieldByName('fecha').AsString    := fecha;
  citi.FieldByName('ferecep').AsString  := ferecep;

  datosdb.closeDB(citi);
end;

procedure TTIvacompra.FinalizarExportacionCITI;
// Objetivo...: Finalizar Exportacion al CITI
begin
  closeFile(archivo);
  closeFile(alicuotas);
end;


procedure TTIvacompra.ListarExportacionCITI(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Items Exportados
var
  e: Integer;
begin
  e := espacios;
  espacios := 0;
  ListDatosEmpresa(salida);
  list.Titulo(0, 0, 'Informe de Control CITI Ventas - Lapso: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');
  list.Titulo(0, 0, ' Per�odo', 1, 'Arial, cursiva, 8');
  list.Titulo(20, list.lineactual, 'Comprobante' + utiles.espacios(22) + 'Cliente', 2, 'Arial, cursiva, 8');
  list.Titulo(50, list.lineactual, 'Nro. C.U.I.T. / Raz�n Social', 3, 'Arial, cursiva, 8');
  list.Titulo(0, 0, '     Tot.Oper. / Con.No Gra. /   Neto   /    I.V.A.   / Op. Exentas', 1, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

  totNettot := 0; totOpexenta := 0; totConnograv := 0; totIva := 0;

  citi.Open;
  datosdb.Filtrar(citi, 'desde = ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and hasta = ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  citi.First;
  while not citi.Eof do Begin
    getDatos(citi.FieldByName('idc').AsString, citi.FieldByName('tipo').AsString, citi.FieldByName('sucursal').AsString, citi.FieldByName('numero').AsString, citi.FieldByName('nrocuit').AsString);
    list.Linea(0, 0, utiles.sFormatoFecha(citi.FieldByName('desde').AsString) + ' - ' + utiles.sFormatoFecha(citi.FieldByName('hasta').AsString), 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(20, list.Lineactual, citi.FieldByName('idc').AsString, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(23, list.Lineactual, citi.FieldByName('tipo').AsString + '  ' + citi.FieldByName('sucursal').AsString + '-' + citi.FieldByName('numero').AsString, 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(50, list.Lineactual, cuit, 4, 'Arial, normal, 8', salida, 'N');
    list.Linea(63, list.Lineactual, rsocial, 5, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
    list.Importe(15, list.Lineactual, '', totoper, 2, 'Arial, normal, 8');
    list.Importe(25, list.Lineactual, '', connograv, 3, 'Arial, normal, 8');
    list.Importe(35, list.Lineactual, '', nettot, 4, 'Arial, normal, 8');
    list.Importe(45, list.Lineactual, '', iva, 5, 'Arial, normal, 8');
    list.Importe(55, list.Lineactual, '', opexenta, 6, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    totNettot    := totNettot    + nettot;
    totOpexenta  := totOpexenta  + Opexenta;
    totConnograv := totConnograv + connograv;
    totIva       := totIva       + iva;
    totTotoper   := totTotoper   + totoper;
    citi.Next;
  End;
  datosdb.closeDB(citi);

  if (totoper <> 0) then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'N');
    list.Linea(0, 0, 'Total:', 1, 'Arial, negrita, 8', salida, 'N');
    list.Importe(15, list.Lineactual, '', tottotoper, 2, 'Arial, negrita, 8');
    list.Importe(25, list.Lineactual, '', connograv, 3, 'Arial, negrita, 8');
    list.Importe(35, list.Lineactual, '', nettot, 4, 'Arial, negrita, 8');
    list.Importe(45, list.Lineactual, '', iva, 5, 'Arial, negrita, 8');
    list.Importe(55, list.Lineactual, '', opexenta, 6, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S');
  end else
    list.Linea(0, 0, 'No hay Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');

  espacios := e;

  list.FinList;
end;


procedure TTIvaCompra.Titulo(salida: char; mes: string);
{Objetivo....: Emitir los T�tulos del Listado}
begin
  if (salida = 'I') or (salida = 'P') then Begin
    Inc(pag);
    ListDatosEmpresa(salida);
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    list.Titulo(espacios, list.Lineactual, 'Libro I.V.A. Compras     -     ' + meses[StrToInt(Copy(mes, 1, 2))] + '  de  ' + Copy(mes, 4, 4), 2, 'Arial, negrita, 14');
    list.Titulo(0, 0, '', 1, 'Times New Roman, ninguno, 8');
    list.Titulo(95, list.Lineactual, 'Hoja N�: #pagina', 2, 'Times New Roman, ninguno, 8');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 11'); list.Titulo(espacios, list.Lineactual, list.linealargopagina(tipolist), 2, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ',1 , 'Arial, normal, 4');
    // 1� L�nea de T�tulos
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8'); list.Titulo(espacios, list.Lineactual, 'Fecha',2 , 'Arial, cursiva, 8');
    list.Titulo(17, list.lineactual, 'Comprobante' + utiles.espacios(18) + 'Proveedor',3 , 'Arial, cursiva, 8');
    list.Titulo(70, list.lineactual, 'C.U.I.T. N�' + utiles.espacios(6) + 'IVA',4 , 'Arial, cursiva, 8');
    list.Titulo(89, list.lineactual, 'Neto',5 , 'Arial, cursiva, 8');
    list.Titulo(94, list.lineactual, 'Operaciones',6 , 'Arial, cursiva, 8');
    list.Titulo(106, list.lineactual, 'Conceptos',7 , 'Arial, cursiva, 8');
    list.Titulo(120, list.lineactual, 'I.V.A.',8 , 'Arial, cursiva, 8');
    list.Titulo(129, list.lineactual, 'I.V.A.',9 , 'Arial, cursiva, 8');
    list.Titulo(136, list.lineactual, 'Cr�d. p/Re.',10 , 'Arial, cursiva, 8');
    list.Titulo(145, list.lineactual, 'Combustibl.',11 , 'Arial, cursiva, 8');
    list.Titulo(158, list.lineactual, 'Total',12 , 'Arial, cursiva, 8');
    list.Titulo(167, list.lineactual, 'Ret.',13 , 'Arial, cursiva, 8');
    // 2� L�nea de T�tulos
    list.Titulo(0, 0, ' ',1 , 'Arial, cursiva, 8');
    list.Titulo(97, list.lineactual, 'Exentas',2 , 'Arial, cursiva, 8');
    list.Titulo(107, list.lineactual, 'No Grav.',3 , 'Arial, cursiva, 8');
    list.Titulo(118, list.lineactual, 'Normal',4 , 'Arial, cursiva, 8');
    list.Titulo(127, list.lineactual, 'Recargo',5 , 'Arial, cursiva, 8');
    list.Titulo(139, list.lineactual, 'Varias',6 , 'Arial, cursiva, 8');
    list.Titulo(147, list.lineactual, 'L�quidos',7 , 'Arial, cursiva, 8');
    list.Titulo(155, list.lineactual, 'Operaci�n',8 , 'Arial, cursiva, 8');
    list.Titulo(166, list.lineactual, 'Comb.',9 , 'Arial, cursiva, 8');

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
  Inc(pag);
  list.LineaTxt(CHR(18), true);
  For i := 1 to empresa.margenes do list.LineaTxt('  ', True);
  list.LineaTxt(empresa.Nombre, true);
  if empresa.Rsocial2 <> '' then list.LineaTxt(empresa.Rsocial2, true);  //WriteLn(archivo, empresa.Rsocial2);


  list.LineaTxt(empresa.Nrocuit, true);
  list.LineaTxt(empresa.Domicilio, true);
  list.LineaTxt(' ', true);
  if tf <> '6' then
    list.LineaTxt('Libro I.V.A. Compras  -  ' + meses[StrToInt(Copy(xmes, 1, 2))] + '  de  ' + Copy(xmes, 4, 4), true)
  else
    list.LineaTxt('Libro I.V.A. Compras  -  ' + meses[StrToInt(Copy(xmes, 1, 2))] + '  de  ' + Copy(xmes, 4, 4) + ' - Bienes de Uso', true);
  list.LineaTxt(utiles.espacios(88) + 'Hoja Nro.: ' + utiles.sLlenarIzquierda((FloatToStr(pag)), 4, '0'), true);
  list.LineaTxt(CHR(15), true);
  list.LineaTxt(utiles.sLLenarIzquierda(lin, 190, CHR(196)), true);
  list.LineaTxt('  ', true);
  list.LineaTxt('Fecha    Comprobante     Proveedor                                C.U.I.T.    IVA         Neto  Operaciones   Conceptos      I.V.A.      I.V.A.  Cred.p/Re. Combustibl.     Total       Ret.', true);
  list.LineaTxt('                                                                                                    Exentas    No Grav.      Normal     Recargo      Varias    Liquidos   Operacion      Comb.', true);
  list.LineaTxt(utiles.sLLenarIzquierda(lin, 190, CHR(196)), true);
  lineasimpresas := 7 + empresa.margenes;
end;

procedure TTIvaCompra.Transporte(leyenda: string; salida: char);
{Objetivo...: Transporte del Asiento Contable}
var
  i: integer;
begin
  if (salida = 'P') or (salida = 'I') then Begin
   if Trim(leyenda) = 'Subtotales:' then
     begin
       if not infresumido then Begin
         list.CompletarPagina;     // Rellenamos la P�gina
         list.PrintLn(0, 0, ' ', 1, 'Arial, normal, 11');
         list.PrintLn(espacios, list.Lineactual, list.linealargopagina(salida), 2, 'Arial, normal, 11');
       end;
     end;
   list.PrintLn(0, 0, ' ', 1, 'Arial, negrita, 8');
   list.PrintLn(espacios, list.Lineactual, leyenda, 2, 'Arial, negrita, 8');
   list.importe(93, list.lineactual,  '', totNettot, 3, 'Arial, negrita, 8');
   list.importe(103, list.lineactual, '', totOpexenta, 4, 'Arial, negrita, 8');
   list.importe(113, list.lineactual, '', totConnograv, 5, 'Arial, negrita, 8');
   list.importe(123, list.lineactual, '', totIva, 6, 'Arial, negrita, 8');
   list.importe(133, list.lineactual, '', totIvarec, 7, 'Arial, negrita, 8');
   list.importe(143, list.lineactual, '', totPercepcion, 8, 'Arial, negrita, 8');
   list.importe(153, list.lineactual, '', totPergan, 9, 'Arial, negrita, 8');
   list.importe(163, list.lineactual, '', totTotoper, 10, 'Arial, negrita, 8');
   list.importe(172, list.lineactual, '', totRetencion, 11, 'Arial, negrita, 8');
   list.PrintLn(0, 0, ' ', 1, 'Arial, normal, 11');
   list.PrintLn(espacios, list.Lineactual, list.linealargopagina(salida), 2, 'Arial, normal, 11');
  end;
  if salida = 'T' then Begin
   if Trim(leyenda) = 'Subtotales:' then  // completamos
     For i := lineasimpresas to (empresa.lineas - 2) do list.LineaTxt(' ', true);

   list.LineaTxt(utiles.sLLenarIzquierda(lin, 190, CHR(196)), true);
   nombre := leyenda + utiles.espacios(83 - Length(Trim(leyenda)));
   list.LineaTxt(nombre, False);
   list.ImporteTxt(totNettot, 12, 2, False);
   list.ImporteTxt(totOpexenta, 12, 2, False);
   list.ImporteTxt(totConnograv, 12, 2, False);
   list.ImporteTxt(totIva, 12, 2, False);
   list.ImporteTxt(totIvarec, 12, 2, False);
   list.ImporteTxt(totPercepcion, 12, 2, False);
   list.ImporteTxt(totPergan, 12, 2, False);
   list.ImporteTxt(totTotoper, 12, 2, False);
   list.ImporteTxt(totRetencion, 11, 2, True);
  end;
end;

procedure TTIvaCompra.LineaIva(salida: char);
// Objetivo...: Imprimir una L�nea de Detalle
begin
  if (salida = 'P') or (salida = 'I') then Begin
   if not infresumido then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(espacios, list.Lineactual, utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(17, list.lineactual, tiva.FieldByName('idcompr').AsString , 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(20, list.lineactual, tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + '  ' + Copy(tiva.FieldByName('rsocial').AsString, 1, 25) , 4, 'Arial, normal, 8', salida, 'N');
    list.Linea(69, list.lineactual, tiva.FieldByName('cuit').AsString + '  ' + tiva.FieldByName('codiva').AsString, 5, 'Arial, normal, 8', salida, 'N');

    list.importe(93,  list.lineactual, '', tiva.FieldByName('Nettot').AsFloat, 6, 'Arial, normal, 8');
    list.importe(103, list.lineactual, '', tiva.FieldByName('Opexenta').AsFloat, 7, 'Arial, normal, 8');
    list.importe(113, list.lineactual, '', tiva.FieldByName('Connograv').AsFloat, 8, 'Arial, normal, 8');
    list.importe(123, list.lineactual, '', tiva.FieldByName('Iva').AsFloat, 9, 'Arial, normal, 8');
    list.importe(133, list.lineactual, '', tiva.FieldByName('Ivarec').AsFloat, 10, 'Arial, normal, 8');
    list.importe(143, list.lineactual, '', tiva.FieldByName('Cdfiscal').AsFloat, 11, 'Arial, normal, 8');
    list.importe(153, list.lineactual, '', tiva.FieldByName('Percep1').AsFloat, 12, 'Arial, normal, 8');
    list.importe(163, list.lineactual, '', tiva.FieldByName('Totoper').AsFloat, 13, 'Arial, normal, 8');
    list.importe(172, list.lineactual, '', tiva.FieldByName('retencion').AsFloat * tiva.FieldByName('importe').AsFloat, 14, 'Arial, normal, 8');
    list.Linea(172, list.lineactual, ' ', 15, 'Arial, normal, 8', salida, 'S');
   end
  end
  else Begin
    nombre := tiva.FieldByName('rsocial').AsString + utiles.espacios(40 - Length(Trim(tiva.FieldByName('rsocial').AsString)));
    list.LineaTxt(utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString) + ' ' + tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + ' ' + nombre + ' ' + tiva.FieldByName('cuit').AsString + ' ' + tiva.FieldByName('codiva').AsString + ' ', False);
    list.importeTxt(tiva.FieldByName('Nettot').AsFloat, 12, 2, False);
    list.importeTxt(tiva.FieldByName('Opexenta').AsFloat, 12, 2, False);
    list.importeTxt(tiva.FieldByName('Connograv').AsFloat, 12, 2, False);
    list.importeTxt(tiva.FieldByName('Iva').AsFloat, 12, 2, False);
    list.importeTxt(tiva.FieldByName('Ivarec').AsFloat, 12, 2, False);
    list.importeTxt(tiva.FieldByName('Cdfiscal').AsFloat, 12, 2, False);
    list.importeTxt(tiva.FieldByName('Percep1').AsFloat, 12, 2, False);
    list.importeTxt(tiva.FieldByName('Totoper').AsFloat, 12, 2, False);
    list.importeTxt(tiva.FieldByName('retencion').AsFloat * tiva.FieldByName('importe').AsFloat, 11, 2, True);
    Inc(lineasimpresas);
  end;

  //Subtotales
  totNettot     := totNettot     + tiva.FieldByName('Nettot').AsFloat;
  totOpexenta   := totOpexenta   + tiva.FieldByName('Opexenta').AsFloat;
  totConnograv  := totConnograv  + tiva.FieldByName('Connograv').AsFloat;
  totIva        := totIva        + tiva.FieldByName('Iva').AsFloat;
  totIvarec     := totIvarec     + tiva.FieldByName('Ivarec').AsFloat;
  totPercepcion := totPercepcion + tiva.FieldByName('Cdfiscal').AsFloat;
  totPergan     := totPergan     + tiva.FieldByName('Percep1').AsFloat;
  totTotoper    := totTotoper    + tiva.FieldByName('Totoper').AsFloat;
  totRetencion  := totRetencion  + (tiva.FieldByName('retencion').AsFloat * tiva.FieldByName('importe').AsFloat);

  if salida <> 'T' then Begin
    if list.SaltoPagina then Begin
      list.PrintLn(0, 0, ' ', 1, 'Arial, normal, 11');
      list.PrintLn(espacios, list.Lineactual, list.linealargopagina(salida), 2, 'Arial, normal, 11');
      Transporte('Transporte ...:', salida);
      list.IniciarNuevaPagina;
      Transporte('Transporte ...:', salida);
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    end
  end else Begin
    // Salto para los archivos de texto
    if lineasimpresas > (empresa.lineas - 3) then Begin
      Transporte('Transporte ...:', salida);
      list.LineaTxt(CHR(12), True);  // Salto
      titulosTxt;
    end;
  end;
end;

{Objetivo...: Cuerpo de Emisi�n}
procedure TTIvaCompra.ListarLibroIVA_Compras(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro: string; xlista: TStringList);
var
  i: string;
begin
  if salida = 'T' then if inf_iniciado then list.LineaTxt(CHR(12), True);
 if not inf_iniciado then
    if salida = 'I' then IniciarInfSubtotales(salida, 3) else IniciarInforme(salida);

  xmes        := mes;
  pag         := pag_inicial;
  list.pagina := pag_inicial;
  tf          := t_filtro;

  // Datos para Iniciar Reporte
  list.IniciarTitulos;
  if salida <> 'T' then list.ImprimirHorizontal;
  if not infresumido then Titulo(salida, mes);
  if (infresumido) and not (iva_existe) then Titulo(salida, mes);
  if (salida = 'P') or (salida = 'I') then Begin
   if (infresumido) and (iva_existe) then Begin // Datos del contribuyente
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, empresa.Nombre, 1, 'Arial, normal, 8', salida, 'S');
    if empresa.Rsocial2 <> '' then list.Linea(0, 0, empresa.Rsocial2, 1, 'Arial, normal, 7', salida, 'S');
    list.Linea(0, 0, empresa.Nrocuit, 1, 'Arial, normal, 7', salida, 'S');
    list.Linea(0, 0, empresa.Domicilio, 1, 'Arial, normal, 7', salida, 'S');
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

  if t_filtro = '6' then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0,  utiles.espacios(20) + ' *** Bienes de Uso ***', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0,  '', 1, 'Arial, normal, 5', salida, 'S');
    end;
    if salida = 'T' then Begin
      list.LineaTxt('   *** Bienes de Uso ***', True);
    end;
  end;

  if t_filtro = '7' then Begin
    tipomovimiento.getDatos(p3);
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0,  '              Categor�a de Mov.: ' + tipomovimiento.Codmov + ' - ' + tipomovimiento.Descrip, 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0,  '', 1, 'Arial, normal, 5', salida, 'S');
    end;
    if salida = 'T' then Begin
      list.LineaTxt('  Categor�a de Mov.: ' + tipomovimiento.Codmov + ' - ' + tipomovimiento.Descrip, True);
    end;
  end;
        
  i := tiva.IndexFieldNames;
  tiva.IndexName := 'Fecha';
  tiva.First;

  while not tiva.EOF do
    begin
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
      if t_filtro = '6' then     // Bienes de Uso
        if (tiva.FieldByName('ferecep').AsString >= p1) and (tiva.FieldByName('ferecep').AsString <= p2) and (tiva.FieldByName('bienuso').AsString = 'S') then LineaIva(salida);
      if t_filtro = '7' then     // Bienes de Uso
        if (tiva.FieldByName('ferecep').AsString >= p1) and (tiva.FieldByName('ferecep').AsString <= p2) and (tiva.FieldByName('idmov').AsString = p3) then LineaIva(salida);

      tiva.Next;
    end;

  if (totTotOper = 0) and not (infresumido) then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'N');
      list.Linea(espacios, list.Lineactual, 'Sin Movimientos', 2, 'Arial, normal, 10', salida, 'S');
    end;
    if salida = 'T' then
      list.LineaTxt(CHR(18) + 'Sin Movimientos' + CHR(15), True);
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
  inherited CalcularIva(xneto, xtotal, xcondfisc);
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
    Bienuso   := tiva.FieldByName('bienuso').AsString;
    Idmov     := tiva.FieldByName('idmov').AsString;
  end else Begin
    retencion := 0; importe := 0; Bienuso := ''; Idmov := '';
  end;
  if Length(Trim(bienuso)) = 0 then Bienuso := 'N';
end;

procedure TTIvacompra.Via(xvia: string);
// Objetivo...: conectar tablas de persistencia a un directorio de trabajo X
begin
  tiva := nil; iiva := nil;
  tiva := datosdb.openDB('ivacompr', 'Idcompr;Tipo;Sucursal;Numero;Cuit', '', dbs.dirSistema + '\' + xvia);
  iiva := datosdb.openDB('netdisco', 'Idcompr;Tipo;Sucursal;Numero;Cuit;Codmov;CodItems', '', dbs.dirSistema + '\' + xvia);
  proveedor.Via(xvia);
  inherited Via(xvia);
  path := dbs.dirSistema + '\' + xvia;
  if not datosdb.verificarSiExisteCampo('ivacompr', 'bienuso', path) then Begin
    tiva.Close;
    datosdb.tranSQL(tiva.DatabaseName, 'alter table ' + tiva.TableName + ' add bienuso char(1)');
    tiva.Open;
  end;
  if not datosdb.verificarSiExisteCampo('ivacompr', 'idmov', path) then Begin
    tiva.Close;
    datosdb.tranSQL(tiva.DatabaseName, 'alter table ' + tiva.TableName + ' add idmov char(3)');
    datosdb.tranSQL(tiva.DatabaseName, 'update ' + tiva.TableName + ' set idmov = ' + '''' + 'C00' + '''');
    tiva.Open;
  end;
  if not datosdb.verificarSiExisteIndice('ivacompr', 'ivac_tipomov', path) then Begin
    tiva.Close;
    datosdb.tranSQL(tiva.DatabaseName, 'create index ivac_tipomov on ' + tiva.TableName + '(idmov, fecha)');
    tiva.Open;
  end;
end;

procedure TTIvacompra.Exportar(xvia, xdfecha, xhfecha, xmodo: String);
// Objetivo...: Exportar Datos I.V.A.
var
  exp_iva: TTable;
  nvia: String;
Begin
  utilesarchivos.CopiarArchivos(dbs.DirSistema + '\estructu', 'ivacompr.*', dbs.DirSistema + '\_exportar\iva');
  utilesarchivos.CopiarArchivos(dbs.DirSistema + '\estructu', 'netdisco.*', dbs.DirSistema + '\_exportar\iva');
  nvia := Copy(xvia, 1, Length(xvia) - 4);
  if tiva.Active then datosdb.closeDB(tiva);
  if iiva.Active then datosdb.closeDB(iiva);
  tiva    := datosdb.openDB('ivacompr', '', '', nvia);
  iiva    := datosdb.openDB('netdisco', '', '', nvia);
  exp_iva := datosdb.openDB('ivacompr', '', '', dbs.DirSistema + '\_exportar\iva');
  eiva    := datosdb.openDB('netdisco', '', '', dbs.DirSistema + '\_exportar\iva');
  tiva.Open; exp_iva.Open; eiva.Open; iiva.Open;
  if xmodo = '1' then datosdb.Filtrar(tiva, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
  if xmodo = '2' then datosdb.Filtrar(tiva, 'ferecep >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and ferecep <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
  tiva.First;
  while not tiva.Eof do Begin
    if datosdb.Buscar(exp_iva, 'idcompr', 'tipo', 'sucursal', 'numero', tiva.FieldByName('idcompr').AsString, tiva.FieldByName('tipo').AsString, tiva.FieldByName('sucursal').AsString, tiva.FieldByName('numero').AsString) then exp_iva.Edit else exp_iva.Append;
    exp_iva.FieldByName('idcompr').AsString   := tiva.FieldByName('idcompr').AsString;
    exp_iva.FieldByName('tipo').AsString      := tiva.FieldByName('tipo').AsString;
    exp_iva.FieldByName('sucursal').AsString  := tiva.FieldByName('sucursal').AsString;
    exp_iva.FieldByName('numero').AsString    := tiva.FieldByName('numero').AsString;
    exp_iva.FieldByName('cuit').AsString      := tiva.FieldByName('cuit').AsString;
    exp_iva.FieldByName('clipro').AsString    := tiva.FieldByName('clipro').AsString;
    exp_iva.FieldByName('rsocial').AsString   := tiva.FieldByName('rsocial').AsString;
    exp_iva.FieldByName('codiva').AsString    := tiva.FieldByName('codiva').AsString;
    exp_iva.FieldByName('concepto').AsString  := tiva.FieldByName('concepto').AsString;
    exp_iva.FieldByName('fecha').AsString     := tiva.FieldByName('fecha').AsString;
    exp_iva.FieldByName('ferecep').AsString   := tiva.FieldByName('ferecep').AsString;
    exp_iva.FieldByName('codprovin').AsString := tiva.FieldByName('codprovin').AsString;
    exp_iva.FieldByName('codmov').AsString    := tiva.FieldByName('codmov').AsString;
    exp_iva.FieldByName('nettot').AsFloat     := tiva.FieldByName('nettot').AsFloat;
    exp_iva.FieldByName('opexenta').AsFloat   := tiva.FieldByName('opexenta').AsFloat;
    exp_iva.FieldByName('connograv').AsFloat  := tiva.FieldByName('connograv').AsFloat;
    exp_iva.FieldByName('iva').AsFloat        := tiva.FieldByName('iva').AsFloat;
    exp_iva.FieldByName('ivarec').AsFloat     := tiva.FieldByName('ivarec').AsFloat;
    exp_iva.FieldByName('percep1').AsFloat    := tiva.FieldByName('percep1').AsFloat;
    exp_iva.FieldByName('percep2').AsFloat    := tiva.FieldByName('percep2').AsFloat;
    exp_iva.FieldByName('cdfiscal').AsFloat   := tiva.FieldByName('cdfiscal').AsFloat;
    exp_iva.FieldByName('totoper').AsFloat    := tiva.FieldByName('totoper').AsFloat;
    exp_iva.FieldByName('tipomov').AsString   := tiva.FieldByName('tipomov').AsString;
    exp_iva.FieldByName('retencion').AsFloat  := tiva.FieldByName('retencion').AsFloat;
    exp_iva.FieldByName('importe').AsFloat    := tiva.FieldByName('importe').AsFloat;
    exp_iva.FieldByName('bienuso').AsString   := tiva.FieldByName('bienuso').AsString;
    exp_iva.FieldByName('idmov').AsString     := tiva.FieldByName('idmov').AsString;
    try
      exp_iva.Post
     except
      exp_iva.Cancel
    end;

    inherited Exportar(tiva.FieldByName('idcompr').AsString, tiva.FieldByName('tipo').AsString,
              tiva.FieldByName('sucursal').AsString, tiva.FieldByName('numero').AsString,
              tiva.FieldByName('cuit').AsString, tiva.FieldByName('codmov').AsString);

    tiva.Next;
  end;
  datosdb.QuitarFiltro(tiva);
  datosdb.closeDB(tiva); datosdb.closeDB(exp_iva); datosdb.closeDB(eiva); datosdb.closeDB(iiva);
end;

procedure TTIvacompra.ExportarIVA(xvia, xdfecha, xhfecha, xdrive, xdir, xtipo_fecha: String);
// Objetivo...: Exportar Datos I.V.A.
var
  exp_iva: TTable;
  e: Boolean;
  d: String;
Begin
  Via(xvia);
  utilesarchivos.CopiarArchivos(dbs.DirSistema + '\estructu\soporte_mag', 'ivacompr.*', dbs.DirSistema + '\exportar');
  exp_iva := datosdb.openDB('ivacompr.dbf', '', '', dbs.DirSistema + '\exportar');
  tiva.Open; exp_iva.Open;
  tiva.IndexFieldNames := 'Fecha';
  while not tiva.Eof do Begin
    e := False;
    if xtipo_fecha = 'E' then
      if (tiva.FieldByName('fecha').AsString >= utiles.sExprFecha2000(xdfecha)) and (tiva.FieldByName('fecha').AsString <= utiles.sExprFecha2000(xhfecha)) then e := True;
    if xtipo_fecha = 'R' then
      if (tiva.FieldByName('ferecep').AsString >= utiles.sExprFecha2000(xdfecha)) and (tiva.FieldByName('ferecep').AsString <= utiles.sExprFecha2000(xhfecha)) then e := True;
    if e then Begin
      if datosdb.Buscar(exp_iva, 'idcompr', 'tipo', 'sucursal', 'numero', 'cuit', tiva.FieldByName('idcompr').AsString, tiva.FieldByName('tipo').AsString, tiva.FieldByName('sucursal').AsString, tiva.FieldByName('numero').AsString, tiva.FieldByName('cuit').AsString) then exp_iva.Edit else exp_iva.Append;
      exp_iva.FieldByName('idcompr').AsString   := tiva.FieldByName('idcompr').AsString;
      exp_iva.FieldByName('tipo').AsString      := tiva.FieldByName('tipo').AsString;
      exp_iva.FieldByName('sucursal').AsString  := tiva.FieldByName('sucursal').AsString;
      exp_iva.FieldByName('numero').AsString    := tiva.FieldByName('numero').AsString;
      exp_iva.FieldByName('cuit').AsString      := tiva.FieldByName('cuit').AsString;
      exp_iva.FieldByName('clipro').AsString    := tiva.FieldByName('clipro').AsString;
      exp_iva.FieldByName('rsocial').AsString   := tiva.FieldByName('rsocial').AsString;
      exp_iva.FieldByName('codiva').AsString    := tiva.FieldByName('codiva').AsString;
      exp_iva.FieldByName('concepto').AsString  := tiva.FieldByName('concepto').AsString;
      exp_iva.FieldByName('fecha').AsString     := tiva.FieldByName('fecha').AsString;
      exp_iva.FieldByName('ferecep').AsString   := tiva.FieldByName('ferecep').AsString;
      exp_iva.FieldByName('codprovin').AsString := tiva.FieldByName('codprovin').AsString;
      exp_iva.FieldByName('codmov').AsString    := tiva.FieldByName('codmov').AsString;
      exp_iva.FieldByName('nettot').AsFloat     := tiva.FieldByName('nettot').AsFloat;
      exp_iva.FieldByName('opexenta').AsFloat   := tiva.FieldByName('opexenta').AsFloat;
      exp_iva.FieldByName('connograv').AsFloat  := tiva.FieldByName('connograv').AsFloat;
      exp_iva.FieldByName('iva').AsFloat        := tiva.FieldByName('iva').AsFloat;
      exp_iva.FieldByName('ivarec').AsFloat     := tiva.FieldByName('ivarec').AsFloat;
      exp_iva.FieldByName('percep1').AsFloat    := tiva.FieldByName('percep1').AsFloat;
      exp_iva.FieldByName('percep2').AsFloat    := tiva.FieldByName('percep2').AsFloat;
      exp_iva.FieldByName('cdfiscal').AsFloat   := tiva.FieldByName('cdfiscal').AsFloat;
      exp_iva.FieldByName('totoper').AsFloat    := tiva.FieldByName('totoper').AsFloat;
      exp_iva.FieldByName('tipomov').AsString   := tiva.FieldByName('tipomov').AsString;
      exp_iva.FieldByName('retencion').AsFloat  := tiva.FieldByName('retencion').AsFloat;
      exp_iva.FieldByName('importe').AsFloat    := tiva.FieldByName('importe').AsFloat;
      exp_iva.FieldByName('bienuso').AsString   := tiva.FieldByName('bienuso').AsString;
      exp_iva.FieldByName('idmov').AsString     := tiva.FieldByName('idmov').AsString;
      try
        exp_iva.Post
       except
        exp_iva.Cancel
      end;
    end;
    tiva.Next;
  end;
  tiva.Close; exp_iva.Close;

  if Length(Trim(xdrive)) > 0  then
    if xdrive <> 'z' then Begin
      if Length(Trim(xdrive)) = 1 then d := xdrive + ':' else d := xdrive;
      utilesarchivos.CopiarArchivos(dbs.DirSistema + '\exportar', 'ivacompr.*', d);
    end;
  if Length(Trim(xdir)) > 0 then Begin
    utilesarchivos.CrearDirectorio(xdir);
    utilesarchivos.CopiarArchivos(dbs.DirSistema + '\exportar', 'ivacompr.*', xdir);
  end;
end;

procedure TTIvacompra.ExportarIVAExcel(xvia, xdfecha, xhfecha, xtipo_fecha, xcont: String);
// Objetivo...: Exportar Datos I.V.A.
var
  i: Integer;
  e: Boolean;
  d, f: String;
Begin
  i := 0;
  tiva.IndexFieldNames := 'Fecha';

  excel.setString('A1', 'A1', 'Contribuyente: ' + xcont, 'Arial, negrita, 10');
  excel.setString('A2', 'A2', 'Libro I.V.A. Compras', 'Arial, negrita, 14');

  excel.setString('A3', 'A3', 'Fecha', 'Arial, normal, 9');
  excel.setString('B3', 'B3', 'Idc', 'Arial, normal, 9');
  excel.setString('C3', 'C3', 'Tipo', 'Arial, normal, 9');
  excel.setString('D3', 'D3', 'Sucursal', 'Arial, normal, 9');
  excel.setString('E3', 'E3', 'Numero', 'Arial, normal, 9');
  excel.setString('F3', 'F3', 'C�d.', 'Arial, normal, 9');
  excel.setString('G3', 'G3', 'Raz�n Social', 'Arial, normal, 9');
  excel.setString('H3', 'H3', 'CUIT', 'Arial, normal, 9');
  excel.setString('I3', 'I3', 'IVA', 'Arial, normal, 9');
  excel.setString('J3', 'J3', 'Concepto', 'Arial, normal, 9');
  excel.setString('K3', 'K3', 'Neto', 'Arial, normal, 9');
  excel.setString('L3', 'L3', 'Op.Exenta', 'Arial, normal, 9');
  excel.setString('M3', 'M3', 'Con.No.Grav.', 'Arial, normal, 9');
  excel.setString('N3', 'N3', 'I.V.A.', 'Arial, normal, 9');
  excel.setString('O3', 'O3', 'I.V.A. Rec.', 'Arial, normal, 9');
  excel.setString('P3', 'P3', 'Per. 1', 'Arial, normal, 9');
  excel.setString('Q3', 'Q3', 'Per. 2', 'Arial, normal, 9');
  excel.setString('R3', 'R3', 'C.Fiscal', 'Arial, normal, 9');
  excel.setString('S3', 'S3', 'Total', 'Arial, normal, 9');
  excel.setString('T3', 'T3', 'TM', 'Arial, normal, 9');
  excel.setString('U3', 'U3', 'Retenci�n', 'Arial, normal, 9');
  excel.setString('V3', 'V3', 'Importe', 'Arial, normal, 9');
  excel.FijarAnchoColumna('G3', 'G3', 40);
  excel.FijarAnchoColumna('H3', 'H3', 15);
  excel.FijarAnchoColumna('J3', 'J3', 35);
  excel.FijarAnchoColumna('B3', 'B3', 5);
  excel.FijarAnchoColumna('C3', 'C3', 5);
  excel.FijarAnchoColumna('F3', 'F3', 5);

  i := 3;

  tiva.First;
  while not tiva.Eof do Begin
    e := False;
    if xtipo_fecha = 'E' then
      if (tiva.FieldByName('fecha').AsString >= utiles.sExprFecha2000(xdfecha)) and (tiva.FieldByName('fecha').AsString <= utiles.sExprFecha2000(xhfecha)) then e := True;
    if xtipo_fecha = 'R' then
      if (tiva.FieldByName('ferecep').AsString >= utiles.sExprFecha2000(xdfecha)) and (tiva.FieldByName('ferecep').AsString <= utiles.sExprFecha2000(xhfecha)) then e := True;
    if e then Begin
      Inc(i); f := IntToStr(i);
      excel.Alinear('A' + f, 'A' + f, 'D');
      excel.setString('A' + f, 'A' + f, '''' + utiles.FechaCompleta(utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString)), 'Arial, normal, 9');
      excel.setString('B' + f, 'B' + f, tiva.FieldByName('idcompr').AsString, 'Arial, normal, 9');
      excel.setString('C' + f, 'C' + f, tiva.FieldByName('tipo').AsString, 'Arial, normal, 9');
      excel.setString('D' + f, 'D' + f, '''' + tiva.FieldByName('sucursal').AsString, 'Arial, normal, 9');
      excel.setString('E' + f, 'E' + f, '''' + tiva.FieldByName('numero').AsString, 'Arial, normal, 9');
      excel.setString('F' + f, 'F' + f, '''' + tiva.FieldByName('clipro').AsString, 'Arial, normal, 9');
      excel.setString('G' + f, 'G' + f, tiva.FieldByName('rsocial').AsString, 'Arial, normal, 9');
      excel.setString('H' + f, 'H' + f, tiva.FieldByName('cuit').AsString, 'Arial, normal, 9');
      excel.setString('I' + f, 'I' + f, tiva.FieldByName('codiva').AsString, 'Arial, normal, 9');
      excel.setString('J' + f, 'J' + f, tiva.FieldByName('concepto').AsString, 'Arial, normal, 9');
      excel.setReal('K' + f, 'K' + f, tiva.FieldByName('nettot').AsFloat, 'Arial, normal, 9');
      excel.setReal('L' + f, 'L' + f, tiva.FieldByName('opexenta').AsFloat, 'Arial, normal, 9');
      excel.setReal('M' + f, 'M' + f, tiva.FieldByName('connograv').AsFloat, 'Arial, normal, 9');
      excel.setReal('N' + f, 'N' + f, tiva.FieldByName('iva').AsFloat, 'Arial, normal, 9');
      excel.setReal('O' + f, 'O' + f, tiva.FieldByName('ivarec').AsFloat, 'Arial, normal, 9');
      excel.setReal('P' + f, 'P' + f, tiva.FieldByName('percep1').AsFloat, 'Arial, normal, 9');
      excel.setReal('Q' + f, 'Q' + f, tiva.FieldByName('percep2').AsFloat, 'Arial, normal, 9');
      excel.setReal('R' + f, 'R' + f, tiva.FieldByName('cdfiscal').AsFloat, 'Arial, normal, 9');
      excel.setReal('S' + f, 'S' + f, tiva.FieldByName('totoper').AsFloat, 'Arial, normal, 9');
      excel.setString('T' + f, 'T' + f, tiva.FieldByName('tipomov').AsString, 'Arial, normal, 9');
      excel.setReal('U' + f, 'U' + f, tiva.FieldByName('retencion').AsFloat, 'Arial, normal, 9');
      excel.setReal('V' + f, 'V' + f, tiva.FieldByName('importe').AsFloat, 'Arial, normal, 9');
    end;
    tiva.Next;
  end;
  tiva.Close;

  excel.setString('E2', 'E2', '', 'Arial, normal, 9');

  excel.Visulizar;
end;

procedure TTIvacompra.ProcesarDatosImportados(xvia: String);
// Objetivo...: Importar Datos
var
  t1: TTable;
Begin
  Via(xvia);
  conectar;

  t1 := datosdb.openDB('ivacompr', '', '', dbs.DirSistema + '\_importar\iva');
  t1.Open;
  while not t1.Eof do Begin
    Grabar(t1.FieldByName('idcompr').AsString, t1.FieldByName('tipo').AsString, t1.FieldByName('sucursal').AsString, t1.FieldByName('numero').AsString, t1.FieldByName('cuit').AsString, t1.FieldByName('clipro').AsString, t1.FieldByName('rsocial').AsString,
           t1.FieldByName('codiva').AsString, t1.FieldByName('concepto').AsString, utiles.sFormatoFecha(t1.FieldByName('fecha').AsString), utiles.sFormatoFecha(t1.FieldByName('ferecep').AsString), t1.FieldByName('codprovin').AsString, t1.FieldByName('codmov').AsString, t1.FieldByName('tipomov').AsString,
           t1.FieldByName('nettot').AsFloat, t1.FieldByName('opexenta').AsFloat, t1.FieldByName('connograv').AsFloat, t1.FieldByName('iva').AsFloat, t1.FieldByName('ivarec').AsFloat, t1.FieldByName('percep1').AsFloat, t1.FieldByName('percep2').AsFloat,
           t1.FieldByName('cdfiscal').AsFloat, t1.FieldByName('totoper').AsFloat);
    t1.Next;
  end;
  datosdb.closeDB(t1);

  t1 := datosdb.openDB('netdisco', '', '', dbs.DirSistema + '\_importar\iva');
  t1.Open;
  while not t1.Eof do Begin
    Grabar(t1.FieldByName('idcompr').AsString, t1.FieldByName('tipo').AsString, t1.FieldByName('sucursal').AsString, t1.FieldByName('numero').AsString, t1.FieldByName('cuit').AsString, t1.FieldByName('codmov').AsString, t1.FieldByName('coditems').AsString,
           utiles.sFormatoFecha(t1.FieldByName('fecha').AsString), t1.FieldByName('items').AsString, t1.FieldByName('nettot').AsFloat, t1.FieldByName('iva').AsFloat, t1.FieldByName('ivarec').AsFloat);

    t1.Next;
  end;

  datosdb.closeDB(t1);
  desconectar;
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
