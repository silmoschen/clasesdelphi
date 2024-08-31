unit CIvaventa_Borda;

interface

uses CIvaBorda, CTablaIva, CCliente, CCNetos, SysUtils, DB, DBTables, CBDT,
     CUtiles, CListar, Listado, CEmpresas, CIDBFM, CUtilidadesArchivos;

type

TTivaventa = class(TTIva)
  anulado: Boolean; Control: String;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
  function    Buscar(xidcompr, xtipo, xsucursal, xnumero: string): boolean; overload;
  procedure   Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov: string;
                     xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real); overload;
  procedure   Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xtipomov: string;
                     xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real); overload;
  procedure   Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xtipomov: string;
                            xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real; xitems: Integer); overload;
  procedure   Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xtipomov: string;
                     xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real; xcontrol: String); overload;
  procedure   getDatos(xidcompr, xtipo, xsucursal, xnumero: string);
  procedure   Borrar(xidcompr, xtipo, xsucursal, xnumero: string); overload;
  procedure   ListarLibroIVA_Ventas(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro: string);
  procedure   Titulo(tipolistado: char; mes: string);
  procedure   List_Netodiscr(df, hf: string; salida: char);
  procedure   List_Codpfis(df, hf: string; salida: char);
  function    setMovimientosMultiplesNetos: TQuery;
  procedure   verificarTipoDeMovimiento(xtipomov: string);
  procedure   AnularComprobante(xidcompr, xtipo, xsucursal, xnumero: string);
  procedure   List_Comprobante(df, hf: string; salida: char);

  procedure   ExportarIVA(xvia, xdfecha, xhfecha, xdrive, xdir, xtipo_fecha: String);
  procedure   ProcesarDatosImportados(xvia: String);

  procedure   Via(xvia: string);
  procedure   Parche;
  procedure   conectar;
  procedure   desconectar;
 protected
  { Declaraciones Protegidas }
  tc: shortint; SaltoManual: Boolean; l1, l2: string;
  ttv: array[1..3] of Real;
  procedure   LineaIva(salida: char); virtual;
  procedure   Transporte(leyenda: string; salida: char); virtual;
  procedure   TitulosTxt; virtual;
  procedure   SaltoTxt(salida: Char);
end;

function ivav: TTivaventa;

implementation

var
  xivav: TTivaventa = nil;

constructor TTivaventa.Create;
begin
  inherited Create;
  tiva := datosdb.openDB('ivaventa', 'Idcompr;Tipo;Sucursal;Numero');
  iiva := datosdb.openDB('netdisve', 'Idcompr;Tipo;Sucursal;Numero;Cuit;Codmov;CodItems');
end;

destructor TTivaventa.Destroy;
begin
  inherited Destroy;
end;

function   TTivaventa.Buscar(xidcompr, xtipo, xsucursal, xnumero: string): boolean;
// Objetivo...: sobreescribir el método de busqueda de la superclase
begin
  iva_existe := datosdb.Buscar(tiva, 'idcompr', 'tipo', 'sucursal', 'numero', xidcompr, xtipo, xsucursal, xnumero);
  if iva_existe then trans_datos else iniciar_datos;
  Result     := iva_existe;
end;

procedure TTIvaventa.Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov: string;
                            xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidcompr, xtipo, xsucursal, xnumero) then tiva.Edit else tiva.Append;
  inherited Act_atributos(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper);
end;

procedure TTIvaventa.Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xtipomov: string;
                            xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidcompr, xtipo, xsucursal, xnumero) then datosdb.tranSQL(path, 'DELETE FROM ivaventa WHERE idcompr = ' + '"' + xidcompr + '"' + ' AND tipo = ' + '"' + xtipo + '"' + ' AND numero = ' + '"' + xnumero + '"' + ' AND rsocial = ' + '"' + 'NNNTX' + xsucursal + '"');
  if Buscar(xidcompr, xtipo, xsucursal, xnumero) then tiva.Edit else tiva.Append;
  inherited Act_atributos(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper);
  tiva.Edit;
  tiva.FieldByName('tipomov').AsString   := xtipomov;
  try
    tiva.Post;
   except
    tiva.Cancel;
  end;
  if tiva.FieldByName('tipomov').AsString = 'X' then anulado := True else anulado := False;
end;

procedure TTIvaventa.Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xtipomov: string;
                            xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real; xitems: Integer);
// Objetivo...: Grabar Atributos del Objeto; cuando se trata de multiples netos
begin
  if xitems = 1 then Borrar(xidcompr, xtipo, xsucursal, xnumero);
  Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xtipomov, xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper);
end;

procedure TTIvaventa.Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xtipomov: string;
                     xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real; xcontrol: String);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidcompr, xtipo, xsucursal, xnumero) then tiva.Edit else tiva.Append;
  inherited Act_atributos(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper);
  tiva.Edit;
  tiva.FieldByName('control').AsString   := xcontrol;
  try
    tiva.Post;
   except
    tiva.Cancel;
  end;
end;


procedure TTIvaventa.Borrar(xidcompr, xtipo, xsucursal, xnumero: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xidcompr, xtipo, xsucursal, xnumero) then Begin
    datosdb.tranSQL(path, 'DELETE FROM ivaventa WHERE idcompr = ' + '"' + xidcompr + '"' + ' AND tipo = ' + '"' + xtipo + '"' + ' AND sucursal = ' + '"' + xsucursal + '"' + ' AND numero = ' + '"' + xnumero + '"');
    datosdb.tranSQL(path, 'DELETE FROM ivaventa WHERE idcompr = ' + '"' + xidcompr + '"' + ' AND tipo = ' + '"' + xtipo + '"' + ' AND sucursal = ' + '"' + '-001' + '"' + ' AND numero = ' + '"' + xnumero + '"');
  end;
end;

procedure TTIvaventa.getDatos(xidcompr, xtipo, xsucursal, xnumero: string);
// Retorno los atributos
begin
  if Buscar(xidcompr, xtipo, xsucursal, xnumero) then trans_datos else iniciar_datos;
  //if datosdb.Buscar(tiva, 'idcompr', 'tipo', 'sucursal', 'numero', xidcompr, xtipo, xsucursal, xnumero) then trans_datos else iniciar_datos;
  if tiva.FieldByName('tipomov').AsString = 'X' then anulado := True else anulado := False;
  control := tiva.FieldByName('control').AsString;
end;

// ------- Gestión de Informes -------------

procedure TTIvaVenta.Titulo(tipolistado: char; mes: string);
{Objetivo....: Emitir los Títulos del Listado}
begin
  if (tipolistado = 'P') or (tipolistado = 'I') then Begin
    Inc(pag);
    ListDatosEmpresa(tipolistado);
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14'); list.Titulo(espacios, list.Lineactual, 'Libro I.V.A. Ventas      -     ' + meses[StrToInt(Copy(mes, 1, 2))] + '  de  ' + Copy(mes, 4, 4), 2, 'Arial, negrita, 14');
    list.Titulo(0, 0, utiles.espacios(350) + 'Hoja Nº: #pagina' + '         ', 1, 'Times New Roman, ninguno, 8');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8'); list.Titulo(espacios, list.Lineactual, list.linealargopagina(tipolistado), 2, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ',1 , 'Arial, normal, 4');
    // 1º Línea de Títulos
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8'); list.Titulo(espacios, list.Lineactual, 'Fecha',2 , 'Arial, cursiva, 8');
    list.Titulo(17, list.lineactual, 'Comprobante' + utiles.espacios(22) + 'Cliente',3 , 'Arial, cursiva, 8');
    list.Titulo(65, list.lineactual, 'C.U.I.T. Nº' + utiles.espacios(10) + 'IVA',4 , 'Arial, cursiva, 8');
    list.Titulo(86, list.lineactual, 'Neto 1',5 , 'Arial, cursiva, 8');
    list.Titulo(95, list.lineactual, 'Neto 2',6 , 'Arial, cursiva, 8');
    list.Titulo(100, list.lineactual, 'Operaciones',7 , 'Arial, cursiva, 8');
    list.Titulo(111, list.lineactual, 'Conceptos',8 , 'Arial, cursiva, 8');
    list.Titulo(123, list.lineactual, 'I.V.A.',9 , 'Arial, cursiva, 8');
    list.Titulo(132, list.lineactual, 'I.V.A.', 10, 'Arial, cursiva, 8');
    list.Titulo(140, list.lineactual, 'Retenc.', 11, 'Arial, cursiva, 8');
    list.Titulo(148, list.lineactual, 'Retenc.',12 , 'Arial, cursiva, 8');
    list.Titulo(159, list.lineactual, 'Total',13 , 'Arial, cursiva, 8');
    // 2º Línea de Títulos
    list.Titulo(0, 0, ' ',1 , 'Arial, cursiva, 8');
    list.Titulo(103, list.lineactual, 'Exentas', 2, 'Arial, cursiva, 8');
    list.Titulo(112, list.lineactual, 'No Grav.', 3, 'Arial, cursiva, 8');
    list.Titulo(131, list.lineactual, 'Recargo', 4, 'Arial, cursiva, 8');
    list.Titulo(140, list.lineactual, 'Varias', 5, 'Arial, cursiva, 8');
    list.Titulo(148, list.lineactual, 'Ganan.', 6, 'Arial, cursiva, 8');
    list.Titulo(156, list.lineactual, 'Operación', 7, 'Arial, cursiva, 8');

    list.Titulo(0, 0, ' ',1 , 'Arial, cursiva, 11'); list.Titulo(espacios, list.Lineactual, list.linealargopagina(tipolistado), 2, 'Arial, normal, 11');
    list.Titulo(0, 0, '  ', 1, 'Arial, negrita, 8');

    if totTotOper > 0 then Begin
      Transporte(utiles.espacios(20) + 'Transporte ....: ', tipolist);
      list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    end;
  end else
    titulosTxt;
    list.tipolist := tipolistado;
end;

procedure TTIvaventa.TitulosTxt;
// Objetivo...: Gestionar titulos para listado de archivos de texto
var
  i: integer;
begin
  Inc(pag);
  list.LineaTxt(CHR(18), True);
  For i := 1 to empresa.margenes do list.LineaTxt(' ', True);
  list.LineaTxt(empresa.Nombre, True);
  if empresa.Rsocial2 <> '' then list.LineaTxt(empresa.Rsocial2, True);
  list.LineaTxt(empresa.Nrocuit, True);
  list.LineaTxt(empresa.Domicilio, True);
  list.LineaTxt('  ', True);
  list.LineaTxt('Libro I.V.A. Ventas  -  ' + meses[StrToInt(Copy(xmes, 1, 2))] + '  de  ' + Copy(xmes, 4, 4), True);
  list.LineaTxt(utiles.espacios(90) + 'Hoja N' + CHR(167) + ': ' + utiles.sLlenarIzquierda((FloatToStr(pag)), 4, '0'), True);
  list.LineaTxt(CHR(15), True);
  list.LineaTxt(utiles.sLLenarIzquierda(lin, 200, CHR(196)), True);
  list.LineaTxt('  ', True);
  list.LineaTxt('Fecha    Comprobante        Cliente                              C.U.I.T. N' + CHR(167) + '  IVA         Neto   Operaciones    Conceptos       I.V.A.       I.V.A.       Percep.     Retenc.        Total  Debito Res.', True);
  list.LineaTxt('                                                                                                     Exentas     No Grav.       Normal      Recargo   Ing. Brutos      I.V.A.    Operacion       Varias', True);
  list.LineaTxt(utiles.sLLenarIzquierda(lin, 200, CHR(196)), True);
  lineasimpresas := 7 + empresa.margenes;
end;

procedure TTIvaVenta.Transporte(leyenda: string; salida: char);
{Objetivo...: Transporte del Asiento Contable}
var
  i: integer;
begin
  if (salida = 'P') or (salida = 'I') then Begin
   if Trim(leyenda) = 'Subtotales:' then Begin
     if not infresumido then Begin
       list.CompletarPagina;     // Rellenamos la Página
       list.PrintLn(0, 0, ' ', 1, 'Arial, normal, 11');
       list.PrintLn(espacios, list.Lineactual, list.linealargopagina(tipolist), 2, 'Arial, normal, 11');
     end;
   end;
   list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
   list.Linea(espacios, list.Lineactual, leyenda, 2, 'Arial, negrita, 8', salida, 'N');
   list.importe(91, list.lineactual,  '', totNettot, 3, 'Arial, negrita, 8');
   list.importe(100, list.lineactual, '', totNeto2, 4, 'Arial, negrita, 8');
   list.importe(109, list.lineactual, '', totOpexenta, 5, 'Arial, negrita, 8');
   list.importe(118, list.lineactual, '', totConnograv, 6, 'Arial, negrita, 8');
   list.importe(127, list.lineactual, '', totIva, 7, 'Arial, negrita, 8');
   list.importe(136, list.lineactual, '', totIvarec, 8, 'Arial, negrita, 8');
   list.importe(143, list.lineactual, '', totPercepcion, 9, 'Arial, negrita, 8');
   list.importe(152, list.lineactual, '', totCdfiscal {totPergan}, 10, 'Arial, negrita, 8');
   list.importe(163, list.lineactual, '', totTotoper, 11, 'Arial, negrita, 8');
   list.PrintLn(0, 0, ' ', 1, 'Arial, normal, 11');
   list.PrintLn(espacios, list.Lineactual, list.linealargopagina(tipolist), 2, 'Arial, normal, 11');
  end;

  if salida = 'T' then Begin
   if Trim(leyenda) = 'Subtotales:' then  // completamos
     For i := lineasimpresas to (empresa.lineas - 2) do List.LineaTxt(' ', True);

   List.LineaTxt(utiles.sLLenarIzquierda(lin, 200, CHR(196)), True);
   nombre := leyenda + utiles.espacios(83 - Length(Trim(leyenda)));
   List.LineaTxt(nombre, False);
   List.ImporteTxt(totNettot, 13, 2, False);
   List.ImporteTxt(totOpexenta, 13, 2, False);
   List.ImporteTxt(totConnograv, 13, 2, False);
   List.ImporteTxt(totIva, 13, 2, False);
   List.ImporteTxt(totIvarec, 13, 2, False);
   List.ImporteTxt(totPercepcion, 13, 2, False);
   List.ImporteTxt(totPergan, 13, 2, False);
   List.ImporteTxt(totTotoper, 13, 2, False);
   List.ImporteTxt(totCDfiscal, 13, 2, True);
  end;
end;

procedure TTIvaVenta.LineaIva(salida: char);
// Objetivo...: Imprimir una Línea de Detalle
begin
  if (salida = 'P') or (salida = 'I') then Begin
   if not infresumido then Begin
    ttv[1] := ttv[1] + tiva.FieldByName('iva').AsFloat;
    ttv[2] := ttv[2] + tiva.FieldByName('ivarec').AsFloat;
    ttv[3] := ttv[3] + tiva.FieldByName('totoper').AsFloat;

    if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> '-' then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(espacios, list.Lineactual, utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(17, list.lineactual, tiva.FieldByName('idcompr').AsString , 3, 'Arial, normal, 8', salida, 'N');
      if tiva.FieldByName('tipomov').AsString = 'X' then list.Linea(20, list.lineactual, tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + '  ' + 'A N U L A D A' , 4, 'Arial, normal, 8', salida, 'N') else
        list.Linea(20, list.lineactual, tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + '  ' + Copy(tiva.FieldByName('rsocial').AsString, 1, 25) , 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(65, list.lineactual, tiva.FieldByName('cuit').AsString, 5, 'Arial, normal, 8', salida, 'N');
      list.Linea(77, list.lineactual, tiva.FieldByName('codiva').AsString, 6, 'Arial, normal, 8', salida, 'N');

      netos.getDatos(tiva.FieldByName('codmov').AsString);
      tabliva.getDatos(netos.codiva);

      if tabliva.Ncol = '1' then Begin
        list.importe(91,  list.lineactual, '', tiva.FieldByName('Nettot').AsFloat, 7, 'Arial, normal, 8');
        list.importe(100, list.lineactual, '', Neto2, 8, 'Arial, normal, 8');
        totNettot := totNettot + tiva.FieldByName('Nettot').AsFloat;
      end;
      if tabliva.Ncol = '2' then Begin
        Neto2 := tiva.FieldByName('Nettot').AsFloat;
        list.importe(91,  list.lineactual, '', 0, 7, 'Arial, normal, 8');
        list.importe(100, list.lineactual, '', Neto2, 8, 'Arial, normal, 8');
        totNeto2 := totNeto2 + Neto2;
      end;
      list.importe(109, list.lineactual, '', tiva.FieldByName('Opexenta').AsFloat, 9, 'Arial, normal, 8');
      list.importe(118, list.lineactual, '', tiva.FieldByName('Connograv').AsFloat, 10, 'Arial, normal, 8');
      list.importe(127, list.lineactual, '', ttv[1], 11, 'Arial, normal, 8');
      list.importe(136, list.lineactual, '', ttv[2], 12, 'Arial, normal, 8');
      list.importe(145, list.lineactual, '', tiva.FieldByName('Percep1').AsFloat, 13, 'Arial, normal, 8');
      list.importe(154, list.lineactual, '', tiva.FieldByName('cdfiscal').AsFloat {tiva.FieldByName('Percep2').AsFloat}, 14, 'Arial, normal, 8');
      list.importe(163, list.lineactual, '', ttv[3], 15, 'Arial, normal, 8');
      list.Linea(164, list.lineactual, ' ', 16, 'Arial, normal, 8', salida, 'S');
      ttv[1] := 0; ttv[2] := 0; ttv[3] := 0;
    end;
   end;
  end else Begin
    if tiva.FieldByName('tipomov').AsString = 'X' then nombre := 'A N U L A D A' + utiles.espacios(36 - Length(Trim('A N U L A D A'))) else nombre := tiva.FieldByName('rsocial').AsString + utiles.espacios(36 - Length(Trim(tiva.FieldByName('rsocial').AsString)));
    if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> 'N' then list.LineaTxt(utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString) + ' ' + tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('control').AsString + '/' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + ' ' + nombre + ' ' + tiva.FieldByName('cuit').AsString + ' ' + tiva.FieldByName('codiva').AsString + ' ', False) else
      list.LineaTxt('                                                                                   ', False);
    list.ImporteTxt(tiva.FieldByName('Nettot').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Opexenta').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Connograv').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Iva').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Ivarec').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Percep1').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Percep2').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Totoper').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Cdfiscal').AsFloat, 13, 2, True);
    Inc(lineasimpresas);
  end;

  if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) = '-' then Begin
    Neto2 := tiva.FieldByName('Nettot').AsFloat;
    totNeto2 := totNeto2 + Neto2;
  end else
    Neto2 := 0;

  //Subtotales
  if tiva.FieldByName('tipomov').AsString <> 'X' then Begin   // Si el comprobante no esta anulado
    totOpexenta   := totOpexenta   + tiva.FieldByName('Opexenta').AsFloat;
    totConnograv  := totConnograv  + tiva.FieldByName('Connograv').AsFloat;
    totIva        := totIva        + tiva.FieldByName('Iva').AsFloat;
    totIvarec     := totIvarec     + tiva.FieldByName('Ivarec').AsFloat;
    totPercepcion := totPercepcion + tiva.FieldByName('Percep1').AsFloat;
    totPergan     := totPergan     + tiva.FieldByName('Percep2').AsFloat;
    totTotoper    := totTotoper    + tiva.FieldByName('Totoper').AsFloat;
    totCdfiscal   := totCdfiscal   + tiva.FieldByName('Cdfiscal').AsFloat;
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

{Objetivo...: Cuerpo de Emisión}
procedure TTIvaVenta.ListarLibroIVA_Ventas(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro: string);
var
  i: string;
begin
  if salida = 'T' then if inf_iniciado then list.LineaTxt(CHR(12), True);
  if not inf_iniciado then
    if salida = 'I' then IniciarInfSubtotales(salida, 3) else IniciarInforme(salida);

  // Leyenda de acuerdo a la Condición del contribuyente
  if empresa.Catempr = 1 then Begin
    l1 := 'Débito Res.'; l2 := '       Varias';
  end else Begin
    l1 := '   Retención'; l2 := 'Ganancias';
  end;

  xmes        := mes;
  pag         := pag_inicial;
  list.pagina := pag_inicial;

  totNettot := 0; totOpexenta := 0; totConnograv := 0; totIva := 0; totIvarec := 0; totPercepcion := 0; totPergan := 0; totTotOper := 0; totCDfiscal := 0; totNeto2 := 0;
  // Datos para Iniciar Reporte
  if salida <> 'T' then list.ImprimirHorizontal;
  list.IniciarTitulos;
  if not infresumido then Titulo(salida, mes);
  if (infresumido) and not (iva_existe) then Titulo(salida, mes);
  if (infresumido) and (iva_existe) then Begin // Datos del contribuyente
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, utiles.espacios(espacios) + empresa.Nombre, 1, 'Arial, normal, 8', salida, 'S');
    if empresa.Rsocial2 <> '' then list.Linea(0, 0, utiles.espacios(espacios) + empresa.Rsocial2, 1, 'Arial, normal, 7', salida, 'S');
    list.Linea(0, 0, utiles.espacios(espacios) + empresa.Nrocuit, 1, 'Arial, normal, 7', salida, 'S');
    list.Linea(0, 0, utiles.espacios(espacios) + empresa.Domicilio, 1, 'Arial, normal, 7', salida, 'S');
  end;
  iva_existe := True;

  if (salida = 'P') and (list.altopag > 0) then Begin
    if not infresumido then list.PrintLn(0, 0, utiles.espacios(20) + '............. Nuevo Contributente .............', 1, 'Arial, cursiva, 7');
    if not inf_iniciado then Titulo(salida, mes) else list.IniciarNuevaPagina;
  end;
  if ((salida = 'I') and (list.altopag > 0)) and not (infresumido) then reporte.NuevaPagina;

  inf_iniciado := True;

  i := tiva.IndexFieldNames;
  tiva.IndexName := 'ListLibro';
  tiva.First;
  while not tiva.EOF do Begin
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
    list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
    list.Linea(espacios, list.Lineactual, 'Sin Movimientos', 2, 'Arial, normal, 10', salida, 'S');
  end;
  Transporte('Subtotales:', salida);

  tiva.IndexFieldNames := i;
end;

procedure TTIvaventa.List_Netodiscr(df, hf: string; salida: char);
// Objetivo...: Emitir Informe Resumen discrimindo por Netos
begin
  TSQL := datosdb.tranSQL(path, 'SELECT * FROM ivaventa WHERE fecha >= ' + '''' + utiles.sExprFecha2000(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha2000(hf) + '''' + ' ORDER BY codmov');
  Listar_NetoDiscr('Netos Discriminados en Ventas', salida);
end;

procedure TTIvaventa.List_Codpfis(df, hf: string; salida: char);
// Objetivo...: Emitir Informe Resumen discrimindo por Netos
begin
  TSQL := datosdb.tranSQL(path, 'SELECT * FROM ivaventa WHERE fecha >= ' + '''' + utiles.sExprFecha2000(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha2000(hf) + '''' + ' ORDER BY codiva');
  ListCodpfis('I.V.A. Discriminado en Ventas', salida);
end;

procedure TTIvaventa.List_Comprobante(df, hf: string; salida: char);
// Objetivo...: Emitir Informe Resumen discrimindo por Netos
begin
  TSQL := datosdb.tranSQL(path, 'SELECT * FROM ivaventa WHERE fecha >= ' + '''' + utiles.sExprFecha2000(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha2000(hf) + '''' + ' ORDER BY idcompr');
  ListComprobante('I.V.A. Ventas Discriminado por Comprobante - Lapso: ' + df + ' al ' + hf, salida);
end;

procedure TTIvaVenta.Parche;
begin
  tiva.Open; tiva.First;
  while not tiva.EOF do Begin
    if Length(Trim(tiva.FieldByName('ferecep').AsString)) < 8 then Begin
      tiva.Edit;
      tiva.FieldByName('ferecep').AsString := tiva.FieldByName('fecha').AsString;
      try
        tiva.Post
      except
        tiva.Cancel
      end;
    end;
    tiva.Next;
  end;
  tiva.Close;
end;

function TTIvaventa.setMovimientosMultiplesNetos: TQuery;
// Objetivo...: Devolver un set con los regitros de los netos, cuando hay varios
begin
  Result := datosdb.tranSQL(path, 'SELECT ivaventa.codmov, ivaventa.Rsocial, ivaventa.nettot, ivaventa.iva, ivaventa.ivarec FROM ivaventa WHERE idcompr = ' + '"' + idcompr + '"' + ' AND tipo = ' + '"' + tipo + '"' + ' AND numero = ' + '"' + numero + '"');
end;

procedure TTIvaventa.verificarTipoDeMovimiento(xtipomov: string);
// Objetivo...: verificar que el movimiento actual no sea uno de multiples netos
begin
  if xtipomov = 'atras' then Begin
    while not tiva.BOF do Begin
      if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> '-' then Break;
      tiva.Prior;
    end;
  end;
  if xtipomov = 'adelante' then Begin
    while not tiva.EOF do Begin
      if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> '-' then Break;
      tiva.Next;
    end;
  end;
  if xtipomov = '' then Begin
    while not tiva.EOF do Begin
      if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> '-' then Break;
      tiva.Next;
    end;
    if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) = '-' then Begin
      while not tiva.BOF do Begin
        if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> '-' then Break;
        tiva.Prior;
      end;
    end;
  end;
end;

procedure TTIvaventa.AnularComprobante(xidcompr, xtipo, xsucursal, xnumero: string);
begin
  if Buscar(xidcompr, xtipo, xsucursal, xnumero) then Begin
    tiva.Edit;
    if tiva.FieldByName('tipomov').AsString <> 'X' then tiva.FieldByName('tipomov').AsString := 'X' else tiva.FieldByName('tipomov').AsString := '';
    try
      tiva.Post
     except
      tiva.Cancel
    end;
  end;
  if tiva.FieldByName('tipomov').AsString <> 'X' then anulado := False else anulado := True;
end;

procedure TTIvaventa.Via(xvia: string);
// Objetivo...: conectar tablas de persistencia a un directorio de trabajo X
begin
  tiva := nil; iiva := nil;
  tiva := datosdb.openDB('ivaventa', 'Idcompr;Tipo;Sucursal;Numero', '', dbs.dirSistema + '\' + xvia);
  iiva := datosdb.openDB('netdisve', 'Idcompr;Tipo;Sucursal;Numero;Cuit;Codmov;CodItems', '', dbs.dirSistema + '\' + xvia);
  cliente.Via(xvia);
  inherited Via(xvia);
  tc := 1;
  path := dbs.dirSistema + '\' + xvia;
  // Controlar verificar si se creo el campo de control
  tiva.Open;
  if not datosdb.verificarSiExisteCampo(tiva, 'control') then Begin
    tiva.Close;
    datosdb.tranSQL(path, 'alter table ivaventa add control char(2)');
    datosdb.tranSQL(path, 'update ivaventa set control = ' + '"' + '00' + '"');
    tiva.Open;
  end;
  tiva.Close;
end;

procedure TTIvaventa.ExportarIVA(xvia, xdfecha, xhfecha, xdrive, xdir, xtipo_fecha: String);
// Objetivo...: Exportar Datos I.V.A.
var
  exp_iva: TTable;
  e: Boolean;
  d: String;
Begin
  Via(xvia);
  utilesarchivos.CopiarArchivos(dbs.DirSistema + '\estructu\soporte_mag', 'ivaventa.*', dbs.DirSistema + '\exportar');
  exp_iva := datosdb.openDB('ivaventa.dbf', '', '', dbs.DirSistema + '\exportar');
  tiva.Open; exp_iva.Open;
  tiva.IndexFieldNames := 'Fecha';
  while not tiva.Eof do Begin
    e := False;
    if xtipo_fecha = 'E' then
      if (tiva.FieldByName('fecha').AsString >= utiles.sExprFecha2000(xdfecha)) and (tiva.FieldByName('fecha').AsString <= utiles.sExprFecha2000(xhfecha)) then e := True;
    if xtipo_fecha = 'R' then
      if (tiva.FieldByName('ferecep').AsString >= utiles.sExprFecha2000(xdfecha)) and (tiva.FieldByName('ferecep').AsString <= utiles.sExprFecha2000(xhfecha)) then e := True;
    if e then Begin
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
      exp_iva.FieldByName('cdfiscal').AsFloat   := tiva.FieldByName('cdfiscal').AsFloat;
      exp_iva.FieldByName('tipomov').AsString   := tiva.FieldByName('tipomov').AsString;
      exp_iva.FieldByName('control').AsString   := tiva.FieldByName('control').AsString;
      try
        exp_iva.Post
       except
        exp_iva.Cancel
      end;
    end;
    tiva.Next;
  end;
  tiva.Close; exp_iva.Close;

  if Length(Trim(xdrive)) > 0 then
    if xdrive <> 'z' then Begin
      if Length(Trim(xdrive)) = 1 then d := xdrive + ':' else d := xdrive;
      utilesarchivos.CopiarArchivos(dbs.DirSistema + '\exportar', 'ivaventa.*', d);
    end;
  if Length(Trim(xdir)) > 0 then Begin
    utilesarchivos.CrearDirectorio(xdir);
    utilesarchivos.CopiarArchivos(dbs.DirSistema + '\exportar', 'ivaventa.*', xdir);
  end;
end;

procedure TTIvaventa.ProcesarDatosImportados(xvia: String);
// Objetivo...: Importar Datos
var
  t1: TTable;
Begin
  Via(xvia);
  conectar;

  t1 := datosdb.openDB('ivaventa', '', '', dbs.DirSistema + '\_importar\iva');
  t1.Open;
  while not t1.Eof do Begin
    Grabar(t1.FieldByName('idcompr').AsString, t1.FieldByName('tipo').AsString, t1.FieldByName('sucursal').AsString, t1.FieldByName('numero').AsString, t1.FieldByName('cuit').AsString, t1.FieldByName('clipro').AsString, t1.FieldByName('rsocial').AsString,
           t1.FieldByName('codiva').AsString, t1.FieldByName('concepto').AsString, utiles.sFormatoFecha(t1.FieldByName('fecha').AsString), utiles.sFormatoFecha(t1.FieldByName('ferecep').AsString), t1.FieldByName('codprovin').AsString, t1.FieldByName('codmov').AsString, t1.FieldByName('tipomov').AsString,
           t1.FieldByName('nettot').AsFloat, t1.FieldByName('opexenta').AsFloat, t1.FieldByName('connograv').AsFloat, t1.FieldByName('iva').AsFloat, t1.FieldByName('ivarec').AsFloat, t1.FieldByName('percep1').AsFloat, t1.FieldByName('percep2').AsFloat,
           t1.FieldByName('cdfiscal').AsFloat, t1.FieldByName('totoper').AsFloat, t1.FieldByName('control').AsString);
    t1.Next;
  end;
  datosdb.closeDB(t1);

  t1 := datosdb.openDB('netdisve', '', '', dbs.DirSistema + '\_importar\iva');
  t1.Open;
  while not t1.Eof do Begin
    Grabar(t1.FieldByName('idcompr').AsString, t1.FieldByName('tipo').AsString, t1.FieldByName('sucursal').AsString, t1.FieldByName('numero').AsString, t1.FieldByName('cuit').AsString, t1.FieldByName('codmov').AsString, t1.FieldByName('coditems').AsString,
           utiles.sFormatoFecha(t1.FieldByName('fecha').AsString), t1.FieldByName('items').AsString, t1.FieldByName('nettot').AsFloat, t1.FieldByName('iva').AsFloat, t1.FieldByName('ivarec').AsFloat);

    t1.Next;
  end;

  datosdb.closeDB(t1);
  desconectar;
end;

procedure TTIvaventa.SaltoTxt(salida: Char);
// Objetivo...: salto de página archivos impresion en modo texto
var
  i: Integer;
begin
  if lineasimpresas > (empresa.lineas - 3) then Begin
    Transporte('Transporte ...:', salida);
    if not SaltoManual then list.LineaTxt(CHR(12), True) else
      For i := 1 to LineasFinal do list.LineaTxt(' ', True);  // Salto
    titulosTxt;
  end;
end;

procedure TTIvaventa.conectar;
// Objetivo...: desconectar tablas de persistencia
begin
  cliente.conectar;
  inherited conectar;
end;

procedure TTivaventa.desconectar;
//Objetivo...: desconectar tablas de persistencia
begin
  cliente.desconectar;
  inherited desconectar;
end;

{===============================================================================}

function ivav: TTivaventa;
begin
  if xivav = nil then
    xivav := TTivaventa.Create;
  Result := xivav;
end;

{===============================================================================}

initialization

finalization
  xivav.Free;

end.
