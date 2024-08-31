unit CIvacompra;

interface

uses CIva, CProve, CEmpresas, CTablaIva, SysUtils, DB, DBTables, CBDT, CUtiles,
     CListar, Listado, CIDBFM, CCNetos, CUtilidadesArchivos, CServers2000_Excel;

type

TTIvacompra = class(TTIva)
  retencion, importe: Real;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
  procedure   ListarLibroIVA_Compras(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro: string);
  procedure   List_InfAnual(desdef, hastaf: string; salida: char);
  procedure   List_Netodiscr(df, hf: string; salida: char);
  procedure   List_Codpfis(df, hf: string; salida: char);
  function    setIvaFechaRecep(xdf, xhf: string): TQuery;
  procedure   CalcularIva(xneto, xtotal: real; xcondfisc: string);
  procedure   getDatos(xidcompr, xtipo, xsucursal, xnumero, xcuit: string);

  procedure   Via(xvia: string);
  procedure   ExportarIVA(xvia, xdfecha, xhfecha, xdrive, xtipo_fecha: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  fila, ffi: Integer; ff: String;
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

// ------- Gestión de Informes -------------

procedure TTIvaCompra.Titulo(salida: char; mes: string);
{Objetivo....: Emitir los Títulos del Listado}
begin
  if (salida = 'I') or (salida = 'P') then Begin
    Inc(pag);
    ListDatosEmpresa(salida);
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    list.Titulo(espacios, list.Lineactual, 'Libro I.V.A. Compras     -     ' + meses[StrToInt(Copy(mes, 1, 2))] + '  de  ' + Copy(mes, 4, 4), 2, 'Arial, negrita, 14');
    list.Titulo(0, 0, '', 1, 'Times New Roman, normal, 8');
    list.Titulo(95, list.Lineactual, 'Hoja Nº: #pagina', 2, 'Times New Roman, normal, 8');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 11'); list.Titulo(espacios, list.Lineactual, list.linealargopagina(tipolist), 2, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ',1 , 'Arial, normal, 4');
    // 1º Línea de Títulos
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8'); list.Titulo(espacios, list.Lineactual, 'Fecha',2 , 'Arial, cursiva, 8');
    list.Titulo(17, list.lineactual, 'Comprobante' + utiles.espacios(18) + 'Proveedor',3 , 'Arial, cursiva, 8');
    list.Titulo(70, list.lineactual, 'C.U.I.T. Nº' + utiles.espacios(6) + 'IVA',4 , 'Arial, cursiva, 8');
    list.Titulo(89, list.lineactual, 'Neto',5 , 'Arial, cursiva, 8');
    list.Titulo(94, list.lineactual, 'Operaciones',6 , 'Arial, cursiva, 8');
    list.Titulo(106, list.lineactual, 'Conceptos',7 , 'Arial, cursiva, 8');
    list.Titulo(120, list.lineactual, 'I.V.A.',8 , 'Arial, cursiva, 8');
    list.Titulo(129, list.lineactual, 'I.V.A.',9 , 'Arial, cursiva, 8');
    list.Titulo(136, list.lineactual, 'Créd. p/Re.',10 , 'Arial, cursiva, 8');
    list.Titulo(145, list.lineactual, 'Combustibl.',11 , 'Arial, cursiva, 8');
    list.Titulo(158, list.lineactual, 'Total',12 , 'Arial, cursiva, 8');
    list.Titulo(167, list.lineactual, 'Ret.',13 , 'Arial, cursiva, 8');
    // 2º Línea de Títulos
    list.Titulo(0, 0, ' ',1 , 'Arial, cursiva, 8');
    list.Titulo(97, list.lineactual, 'Exentas',2 , 'Arial, cursiva, 8');
    list.Titulo(107, list.lineactual, 'No Grav.',3 , 'Arial, cursiva, 8');
    list.Titulo(118, list.lineactual, 'Normal',4 , 'Arial, cursiva, 8');
    list.Titulo(127, list.lineactual, 'Recargo',5 , 'Arial, cursiva, 8');
    list.Titulo(139, list.lineactual, 'Varias',6 , 'Arial, cursiva, 8');
    list.Titulo(147, list.lineactual, 'Líquidos',7 , 'Arial, cursiva, 8');
    list.Titulo(155, list.lineactual, 'Operación',8 , 'Arial, cursiva, 8');
    list.Titulo(166, list.lineactual, 'Comb.',9 , 'Arial, cursiva, 8');

    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 11'); list.Titulo(espacios, list.Lineactual, list.linealargopagina(tipolist), 2, 'Arial, normal, 11');
    list.Titulo(0, 0, '  ', 1, 'Arial, negrita, 8');

    if totTotOper > 0 then Begin
      Transporte(utiles.espacios(20) + 'Transporte ....: ', tipolist);
      list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    end;
  end;
  if salida = 'T' then titulosTxt;

  if salida = 'X' then Begin
    ListDatosEmpresa(salida);
    Inc(fila); ff := Trim(IntToStr(fila));
    excel.setString('a' + ff, 'a' + ff, empresaRsocial, 'Arial, normal, 7');
    if empresa.Rsocial2 <> '' then Begin
      Inc(fila); ff := Trim(IntToStr(fila));
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 7');
      excel.setString('a' + ff, 'a' + ff, empresaRsocial2, 'Arial, normal, 7');
    end;
    Inc(fila); ff := Trim(IntToStr(fila));
    excel.setString('a' + ff, 'a' + ff, empresaCuit, 'Arial, normal, 7');
    Inc(fila); ff := Trim(IntToStr(fila));
    excel.setString('a' + ff, 'a' + ff, empresaDireccion, 'Arial, normal, 7');

    Inc(fila); ff := Trim(IntToStr(fila));
    excel.setString('a' + ff, 'a' + ff, 'Libro I.V.A. Compras     -     ' + meses[StrToInt(Copy(mes, 1, 2))] + '  de  ' + Copy(mes, 4, 4), 'Arial, negrita, 12');
    // 1º Línea de Títulos
    Inc(fila); ff := Trim(IntToStr(fila));
    excel.setString('a' + ff, 'a' + ff, 'Fecha', 'Arial, normal, 8');
    excel.setString('b' + ff, 'b' + ff, 'Comprobante', 'Arial, normal, 8');
    excel.setString('c' + ff, 'c' + ff, 'Proveedor', 'Arial, normal, 8');
    excel.setString('d' + ff, 'd' + ff, 'C.U.I.T.', 'Arial, normal, 8');
    excel.setString('e' + ff, 'e' + ff, 'IVA', 'Arial, normal, 8');
    excel.Alinear('f' + ff, 'f' + ff, 'D');
    excel.setString('f' + ff, 'f' + ff, 'Neto', 'Arial, normal, 8');
    excel.Alinear('g' + ff, 'g' + ff, 'D');
    excel.setString('g' + ff, 'g' + ff, 'Operaciones', 'Arial, normal, 8');
    excel.Alinear('h' + ff, 'h' + ff, 'D');
    excel.setString('h' + ff, 'h' + ff, 'Conceptos', 'Arial, normal, 8');
    excel.Alinear('i' + ff, 'i' + ff, 'D');
    excel.setString('i' + ff, 'i' + ff, 'I.V.A.', 'Arial, normal, 8');
    excel.Alinear('j' + ff, 'j' + ff, 'D');
    excel.setString('j' + ff, 'j' + ff, 'I.V.A.', 'Arial, normal, 8');
    excel.Alinear('k' + ff, 'k' + ff, 'D');
    excel.setString('k' + ff, 'k' + ff, 'Créd. p/Rec.', 'Arial, normal, 8');
    excel.Alinear('l' + ff, 'l' + ff, 'D');
    excel.setString('l' + ff, 'l' + ff, 'Combustible', 'Arial, normal, 8');
    excel.Alinear('m' + ff, 'm' + ff, 'D');
    excel.setString('m' + ff, 'm' + ff, 'Total', 'Arial, normal, 8');
    excel.Alinear('n' + ff, 'n' + ff, 'D');
    excel.setString('n' + ff, 'n' + ff, 'Ret.', 'Arial, normal, 8');
    // 2º Línea de Títulos
    Inc(fila); ff := Trim(IntToStr(fila));
    excel.Alinear('g' + ff, 'g' + ff, 'D');
    excel.setString('g' + ff, 'g' + ff, 'Exentas', 'Arial, normal, 8');
    excel.Alinear('h' + ff, 'h' + ff, 'D');
    excel.setString('h' + ff, 'h' + ff, 'No Grav.', 'Arial, normal, 8');
    excel.Alinear('i' + ff, 'i' + ff, 'D');
    excel.setString('i' + ff, 'i' + ff, 'Normal', 'Arial, normal, 8');
    excel.Alinear('j' + ff, 'j' + ff, 'D');
    excel.setString('j' + ff, 'j' + ff, 'Recargo', 'Arial, normal, 8');
    excel.Alinear('k' + ff, 'k' + ff, 'D');
    excel.setString('k' + ff, 'k' + ff, 'Varias', 'Arial, normal, 8');
    excel.Alinear('l' + ff, 'l' + ff, 'D');
    excel.setString('l' + ff, 'l' + ff, 'Líquidos', 'Arial, normal, 8');
    excel.Alinear('m' + ff, 'm' + ff, 'D');
    excel.setString('m' + ff, 'm' + ff, 'Operación', 'Arial, normal, 8');
    excel.Alinear('n' + ff, 'n' + ff, 'D');
    excel.setString('n' + ff, 'n' + ff, 'Comb.', 'Arial, normal, 8');

    excel.FijarAnchoColumna('a' + ff, 'a' + ff, 8);
    excel.FijarAnchoColumna('b' + ff, 'b' + ff, 16);
    excel.FijarAnchoColumna('c' + ff, 'c' + ff, 30);
    excel.FijarAnchoColumna('d' + ff, 'd' + ff, 14);
    excel.FijarAnchoColumna('e' + ff, 'e' + ff, 3);

    ffi := fila + 1;
  end;

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
  list.LineaTxt('Libro I.V.A. Compras  -  ' + meses[StrToInt(Copy(xmes, 1, 2))] + '  de  ' + Copy(xmes, 4, 4), true);
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
  i, f: integer;
begin
  if (salida = 'P') or (salida = 'I') then Begin
   if Trim(leyenda) = 'Subtotales:' then
     begin
       if not infresumido then Begin
         list.CompletarPagina;     // Rellenamos la Página
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
  if salida = 'X' then Begin
    if Trim(leyenda) = 'Subtotales:' then Begin
      f := fila;
      Inc(fila); ff := Trim(IntToStr(fila));
      excel.setString('a' + ff, 'a' + ff, leyenda, 'Arial, negrita, 8');
      excel.setFormulaArray('f' + ff, 'f' + ff, '=suma(' + 'f' + IntToStr(ffi) + '..' + 'f' + IntToStr(f) + ')', 'Arial, negrita, 8');
      excel.setFormulaArray('g' + ff, 'g' + ff, '=suma(' + 'g' + IntToStr(ffi) + '..' + 'g' + IntToStr(f) + ')', 'Arial, negrita, 8');
      excel.setFormulaArray('h' + ff, 'h' + ff, '=suma(' + 'h' + IntToStr(ffi) + '..' + 'h' + IntToStr(f) + ')', 'Arial, negrita, 8');
      excel.setFormulaArray('i' + ff, 'i' + ff, '=suma(' + 'i' + IntToStr(ffi) + '..' + 'i' + IntToStr(f) + ')', 'Arial, negrita, 8');
      excel.setFormulaArray('j' + ff, 'j' + ff, '=suma(' + 'j' + IntToStr(ffi) + '..' + 'j' + IntToStr(f) + ')', 'Arial, negrita, 8');
      excel.setFormulaArray('k' + ff, 'k' + ff, '=suma(' + 'k' + IntToStr(ffi) + '..' + 'k' + IntToStr(f) + ')', 'Arial, negrita, 8');
      excel.setFormulaArray('l' + ff, 'l' + ff, '=suma(' + 'l' + IntToStr(ffi) + '..' + 'l' + IntToStr(f) + ')', 'Arial, negrita, 8');
      excel.setFormulaArray('m' + ff, 'm' + ff, '=suma(' + 'm' + IntToStr(ffi) + '..' + 'm' + IntToStr(f) + ')', 'Arial, negrita, 8');
      excel.setFormulaArray('n' + ff, 'n' + ff, '=suma(' + 'n' + IntToStr(ffi) + '..' + 'n' + IntToStr(f) + ')', 'Arial, negrita, 8');
      excel.setString('c1', 'c1', '');
    end;
  end;
end;

procedure TTIvaCompra.LineaIva(salida: char);
// Objetivo...: Imprimir una Línea de Detalle
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
   end;
  end;
  if salida = 'T' then Begin
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

  if (salida = 'P') or (salida = 'I') then Begin
    if list.SaltoPagina then Begin
      list.PrintLn(0, 0, ' ', 1, 'Arial, normal, 11');
      list.PrintLn(espacios, list.Lineactual, list.linealargopagina(salida), 2, 'Arial, normal, 11');
      Transporte('Transporte ...:', salida);
      list.IniciarNuevaPagina;
      Transporte('Transporte ...:', salida);
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    end
  end;
  if salida = 'T' then Begin
    // Salto para los archivos de texto
    if lineasimpresas > (empresa.lineas - 3) then Begin
      Transporte('Transporte ...:', salida);
      list.LineaTxt(CHR(12), True);  // Salto
      titulosTxt;
    end;
  end;
  if salida = 'X' then Begin
    Inc(fila); ff := Trim(IntToStr(fila));
    excel.setString('a' + ff, 'a' + ff, utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString), 'Arial, normal, 8');
    excel.setString('b' + ff, 'b' + ff, tiva.FieldByName('idcompr').AsString + ' ' + tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString, 'Arial, normal, 8');
    excel.setString('c' + ff, 'c' + ff, Copy(tiva.FieldByName('rsocial').AsString, 1, 25), 'Arial, normal, 8');
    excel.setString('d' + ff, 'd' + ff, tiva.FieldByName('cuit').AsString, 'Arial, normal, 8');
    excel.setString('e' + ff, 'e' + ff, tiva.FieldByName('codiva').AsString, 'Arial, normal, 8');
    excel.setReal('f' + ff, 'f' + ff, tiva.FieldByName('Nettot').AsFloat, 'Arial, normal, 8');
    excel.setReal('g' + ff, 'g' + ff, tiva.FieldByName('Opexenta').AsFloat, 'Arial, normal, 8');
    excel.setReal('h' + ff, 'h' + ff, tiva.FieldByName('Connograv').AsFloat, 'Arial, normal, 8');
    excel.setReal('i' + ff, 'i' + ff, tiva.FieldByName('Iva').AsFloat, 'Arial, normal, 8');
    excel.setReal('j' + ff, 'j' + ff, tiva.FieldByName('Ivarec').AsFloat, 'Arial, normal, 8');
    excel.setReal('k' + ff, 'k' + ff, tiva.FieldByName('Cdfiscal').AsFloat, 'Arial, normal, 8');
    excel.setReal('l' + ff, 'l' + ff, tiva.FieldByName('Percep1').AsFloat, 'Arial, normal, 8');
    excel.setReal('m' + ff, 'm' + ff, tiva.FieldByName('Totoper').AsFloat, 'Arial, normal, 8');
    excel.setReal('n' + ff, 'n' + ff, tiva.FieldByName('retencion').AsFloat, 'Arial, normal, 8');
  end;
end;

{Objetivo...: Cuerpo de Emisión}
procedure TTIvaCompra.ListarLibroIVA_Compras(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro: string);
var
  i: string;
begin
  if salida = 'T' then if inf_iniciado then list.LineaTxt(CHR(12), True);
  if not (inf_iniciado) and (salida <> 'X') then
    if salida = 'I' then IniciarInfSubtotales(salida, 3) else IniciarInforme(salida);

  xmes        := mes;
  pag         := pag_inicial;
  list.pagina := pag_inicial;
  fila        := 0;

  // Datos para Iniciar Reporte
  if salida <> 'X' then list.IniciarTitulos;
  if (salida = 'P') or (salida = 'I') then list.ImprimirHorizontal;
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

  i := tiva.IndexFieldNames;
  tiva.IndexName := 'Fecha';
  tiva.First;

  while not tiva.EOF do
    begin
      if t_filtro = '1' then     // Filtro por Fecha de Emisión
        if (tiva.FieldByName('fecha').AsString >= p1) and (tiva.FieldByName('fecha').AsString <= p2) then LineaIva(salida);
      if t_filtro = '2' then     // Filtro por Código de Movimiento
        if ((tiva.FieldByName('fecha').AsString >= p1) and (tiva.FieldByName('fecha').AsString <= p2)) and (tiva.FieldByName('codmov').AsString = p3) then LineaIva(salida);
      if t_filtro = '3' then     // Filtro por Tipo de Comprobante
        if ((tiva.FieldByName('fecha').AsString >= p1) and (tiva.FieldByName('fecha').AsString <= p2)) and (tiva.FieldByName('idcompr').AsString = p3) then LineaIva(salida);
      if t_filtro = '4' then     // Filtro por Proveedor
        if ((tiva.FieldByName('fecha').AsString >= p1) and (tiva.FieldByName('fecha').AsString <= p2)) and (tiva.FieldByName('clipro').AsString = p3) then LineaIva(salida);
      if t_filtro = '5' then     // Filtro por Fecha de Recepción
        if (tiva.FieldByName('ferecep').AsString >= p1) and (tiva.FieldByName('ferecep').AsString <= p2) then LineaIva(salida);
      tiva.Next;
    end;

  if (totTotOper = 0) and not (infresumido) then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'N');
      list.Linea(espacios, list.Lineactual, 'Sin Movimientos', 2, 'Arial, normal, 10', salida, 'S');
    end;
  end;
  Transporte('Subtotales:', salida);

  tiva.IndexFieldNames := i;
  if (salida = 'P') or (salida = 'I') then pag := list.pagina;
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
  TSQL := datosdb.tranSQL(path, 'SELECT * FROM ivacompr WHERE fecha >= ' + '''' + utiles.sExprFecha(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(hf) + '''' + ' ORDER BY codiva');
  ListCodpfis('I.V.A. Discriminado en Compras', salida);
end;

procedure TTIvacompra.List_InfAnual(desdef, hastaf: string; salida: char);
// Objetivo...: Presentar Informe Anual
begin
  // Inicializamos las variables
  totNettot := 0; totOpexenta := 0; totConnograv := 0; totIva := 0; totIvarec := 0; totPercepcion := 0; totPergan := 0; totTotOper := 0; totCdfiscal := 0;
  tctotNettot := 0; tctotOpexenta :=0; tctotConnograv := 0; tctotIva := 0; tctotIvarec := 0; tctotPercep1 := 0; tctotCdfiscal := 0; tctotPercep2 := 0; tctotTotOper := 0;  // Totales Anuales
  TSQL := datosdb.tranSQL(path, 'SELECT * FROM ivacompr WHERE ferecep >= ' + '''' + utiles.sExprFecha(desdef) + '''' + ' AND ferecep <= ' + '''' + utiles.sExprFecha(hastaf) + '''' + ' ORDER BY ferecep');
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
  end else Begin
    retencion := 0; importe := 0;
  end;
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
end;

procedure TTIvacompra.ExportarIVA(xvia, xdfecha, xhfecha, xdrive, xtipo_fecha: String);
// Objetivo...: Exportar Datos I.V.A.
var
  exp_iva: TTable;
  e: Boolean;
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
      try
        exp_iva.Post
       except
        exp_iva.Cancel
      end;
    end;
    tiva.Next;
  end;
  tiva.Close; exp_iva.Close;

  utilesarchivos.CopiarArchivos(dbs.DirSistema + '\exportar', 'ivacompr.*', xdrive + ':');
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
