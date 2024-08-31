unit CIvaventa_Gasparutti;

interface

uses CIva_Gasparutti, CTablaIva, CCliente, CCNetos, SysUtils, DB, DBTables, CBDT, CUtiles, CListar, Listado, CEmpresas, CIDBFM;

type
TTivaventa = class(TTIva)
  anulado: Boolean;
  Nettot1: Real;
  ultimonro: String;
  ivacon: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
  function    Buscar(xidcompr, xtipo, xsucursal, xnumero: string): boolean; overload;
  procedure   Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xtipomov, xultimonro: string;
                     xnettot, xnettot1, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real); overload;
  procedure   getDatos(xidcompr, xtipo, xsucursal, xnumero: string);
  procedure   Borrar(xidcompr, xtipo, xsucursal, xnumero: string); overload;
  procedure   ListarLibroIVA_Ventas(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro: string);
  procedure   Titulo(tipolistado: char; mes: string); virtual;
  procedure   List_Netodiscr(df, hf: string; salida: char); overload;
  procedure   List_Codpfis(df, hf: string; salida: char);
  function    setMovimientosMultiplesNetos: TQuery;
  procedure   verificarTipoDeMovimiento(xtipomov: string);
  procedure   AnularComprobante(xidcompr, xtipo, xsucursal, xnumero: string);

  { Comprobantes consecutivos }
  function    BuscarFactura(xitems, xidcompr, xtipo, xsucursal, xnumero: String): Boolean;
  procedure   GrabarFacturasConsecutivas(xitems, xidcompr, xtipo, xsucursal, xnumero: String; xnettot, xnettot1, xopexentas, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: Real; xcantitems: Integer);
  function    setFacturasConsecutivas: TQuery;

  procedure   Via(xvia: string);
  procedure   Parche;
  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  tc: shortint; SaltoManual: Boolean; l1, l2: string;
  totNettot1: Real;
  procedure   LineaIva(salida: char);
  procedure   Transporte(leyenda: string; salida: char);
  procedure   TitulosTxt;
  procedure   SaltoTxt(salida: Char);
  procedure   BorrarFacturas;
end;

function ivav: TTivaventa;

implementation

var
  xivav: TTivaventa = nil;

constructor TTivaventa.Create;
begin
  inherited Create;
  tiva   := datosdb.openDB('ivaventa', 'Idcompr;Tipo;Sucursal;Numero');
  iiva   := datosdb.openDB('netdisve', 'Idcompr;Tipo;Sucursal;Numero;Cuit;Codmov;CodItems');
  ivacon := datosdb.openDB('ivaventas_cons', '');
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

procedure TTIvaventa.Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xtipomov, xultimonro: string;
                            xnettot, xnettot1, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real);
// Objetivo...: Grabar Atributos del Objeto
var
  f: boolean;
begin
  f := tiva.Filtered;
  if f then tiva.Filtered := False;
  if Buscar(xidcompr, xtipo, xsucursal, xnumero) then datosdb.tranSQL(path, 'DELETE FROM ivaventa WHERE idcompr = ' + '"' + xidcompr + '"' + ' AND tipo = ' + '"' + xtipo + '"' + ' AND numero = ' + '"' + xnumero + '"' + ' AND rsocial = ' + '"' + 'NNNTX' + xsucursal + '"');
  if Buscar(xidcompr, xtipo, xsucursal, xnumero) then tiva.Edit else tiva.Append;
  inherited Act_atributos(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper);
  tiva.Edit;
  tiva.FieldByName('tipomov').AsString   := xtipomov;
  tiva.FieldByName('ultimonro').AsString := xultimonro;
  tiva.FieldByName('nettot1').AsFloat    := xnettot1;
  try
    tiva.Post;
   except
    tiva.Cancel;
  end;
  if f then tiva.Filtered := True;
  if tiva.FieldByName('tipomov').AsString = 'X' then anulado := True else anulado := False;
end;

procedure TTIvaventa.Borrar(xidcompr, xtipo, xsucursal, xnumero: string);
// Objetivo...: Eliminar un Objeto
var
  t, c, m: string;   // Identifica netdisco o netdisve
begin
  t := string(iiva.TableName);
  if Buscar(xidcompr, xtipo, xsucursal, xnumero) then Begin
    c := tiva.FieldByName('cuit').AsString;
    m := tiva.FieldByName('tipomov').AsString;

    if tiva.FieldByName('tipomov').AsString = 'C' then Begin  // Significa que hay facturas consecutivas
      idcompr   := xidcompr;
      tipo      := xtipo;
      sucursal  := xsucursal;
      numero    := xnumero;
      ultimonro := tiva.FieldByName('ultimonro').AsString;
      BorrarFacturas;
    end;

    tiva.Delete;  // Movimiento maestro
    if m = '-' then datosdb.tranSQL(path, 'DELETE FROM ivaventa WHERE idcompr = ' + '"' + xidcompr + '"' + ' AND tipo = ' + '"' + xtipo + '"' + ' AND numero = ' + '"' + xnumero + '"' + ' AND rsocial = ' + '"' + 'NNNTX' + xsucursal + '"');
    verificarTipoDeMovimiento('');
    getDatos(tiva.FieldByName('idcompr').AsString, tiva.FieldByName('tipo').AsString, tiva.FieldByName('sucursal').AsString, tiva.FieldByName('numero').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

procedure TTIvaventa.getDatos(xidcompr, xtipo, xsucursal, xnumero: string);
// Retorno los atributos
begin
  if Buscar(xidcompr, xtipo, xsucursal, xnumero) then Begin
    trans_datos;
    if tiva.FieldByName('tipomov').AsString = 'X' then anulado := True else anulado := False;
    Nettot1   := tiva.FieldByName('nettot1').AsFloat;
    ultimonro := tiva.FieldByName('ultimonro').AsString;
  end else Begin
    iniciar_datos;
    Nettot1 := 0; ultimonro := '';
  end;
end;

// ------- Gestión de Informes -------------

procedure TTIvaVenta.Titulo(tipolistado: char; mes: string);
{Objetivo....: Emitir los Títulos del Listado}
begin
  if (tipolistado = 'P') or (tipolistado = 'I') then Begin
    Inc(pag);
    ListDatosEmpresa(tipolistado);
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14'); list.Titulo(espacios, list.Lineactual, 'Libro I.V.A. Ventas      -     ' + meses[StrToInt(Copy(mes, 1, 2))] + '  de  ' + Copy(mes, 4, 4), 2, 'Arial, negrita, 14');
    list.Titulo(0, 0, utiles.espacios(404) + 'Hoja Nº: #pagina', 1, 'Times New Roman, ninguno, 8');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8'); list.Titulo(espacios, list.Lineactual, list.linealargopagina(tipolistado), 2, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ',1 , 'Arial, normal, 4');
    // 1º Línea de Títulos
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8'); list.Titulo(espacios, list.Lineactual, 'Fecha',2 , 'Arial, cursiva, 8');
    list.Titulo(17, list.lineactual, 'Comprobante' + utiles.espacios(17) + 'Cliente',3 , 'Arial, cursiva, 8');
    list.Titulo(58, list.lineactual, 'C.U.I.T. Nº' + utiles.espacios(10) + 'IVA',4 , 'Arial, cursiva, 8');
    list.Titulo(77, list.lineactual, ' Neto1',5 , 'Arial, cursiva, 8');
    list.Titulo(86, list.lineactual, ' Neto2',6 , 'Arial, cursiva, 8');
    list.Titulo(92, list.lineactual, 'Operaciones',7 , 'Arial, cursiva, 8');
    list.Titulo(102, list.lineactual, 'Conceptos',8 , 'Arial, cursiva, 8');
    list.Titulo(114, list.lineactual, 'I.V.A.',9 , 'Arial, cursiva, 8');
    list.Titulo(123, list.lineactual, 'I.V.A.',10 , 'Arial, cursiva, 8');
    list.Titulo(132, list.lineactual, 'Percep.', 11, 'Arial, cursiva, 8');
    list.Titulo(140, list.lineactual, 'Retenc.', 12, 'Arial, cursiva, 8');
    list.Titulo(150, list.lineactual, 'Total',13 , 'Arial, cursiva, 8');
    list.Titulo(156, list.lineactual, l1,14 , 'Arial, cursiva, 8');

    // 2º Línea de Títulos
    list.Titulo(0, 0, ' ',1 , 'Arial, cursiva, 8');
    list.Titulo(95, list.lineactual, 'Exentas',2 , 'Arial, cursiva, 8');
    list.Titulo(103, list.lineactual, 'No Grav.',3 , 'Arial, cursiva, 8');
    list.Titulo(113, list.lineactual, 'Normal',4 , 'Arial, cursiva, 8');
    list.Titulo(121, list.lineactual, 'Recargo', 5, 'Arial, cursiva, 8');
    list.Titulo(130, list.lineactual, 'Ing. Brutos',6 , 'Arial, cursiva, 8');
    list.Titulo(141, list.lineactual, 'I.V.A.',7 , 'Arial, cursiva, 8');
    list.Titulo(147, list.lineactual, 'Operación',8 , 'Arial, cursiva, 8');
    list.Titulo(156, list.lineactual, l2, 9, 'Arial, cursiva, 8');

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
  list.LineaTxt('Fecha    Comprobante            Cliente                            C.U.I.T. N' + CHR(167) + '  IVA       Neto1      Neto2 Operaciones Conceptos      I.V.A.    I.V.A.    Percep.     Retenc.       Total Debito Res.', True);
  list.LineaTxt('                                                                                                              Exentas  No Grav.      Normal   Recargo Ing.Brutos      I.V.A.   Operacion      Varias', True);

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
   list.importe(82, list.lineactual,  '', totNettot, 3, 'Arial, negrita, 8');
   list.importe(91, list.lineactual,  '', totNettot1, 4, 'Arial, negrita, 8');
   list.importe(100, list.lineactual, '', totOpexenta, 5, 'Arial, negrita, 8');
   list.importe(109, list.lineactual, '', totConnograv, 6, 'Arial, negrita, 8');
   list.importe(118, list.lineactual, '', totIva, 7, 'Arial, negrita, 8');
   list.importe(127, list.lineactual, '', totIvarec, 8, 'Arial, negrita, 8');
   list.importe(136, list.lineactual, '', totPercepcion, 9, 'Arial, negrita, 8');
   list.importe(143, list.lineactual, '', totPergan, 10, 'Arial, negrita, 8');
   list.importe(152, list.lineactual, '', totTotoper, 11, 'Arial, negrita, 8');
   list.importe(163, list.lineactual, '', totCdfiscal, 12, 'Arial, negrita, 8');
   list.PrintLn(0, 0, ' ', 1, 'Arial, normal, 11');
   list.PrintLn(espacios, list.Lineactual, list.linealargopagina(tipolist), 2, 'Arial, normal, 11');
  end;

  if salida = 'T' then Begin
   if Trim(leyenda) = 'Subtotales:' then  // completamos
     For i := lineasimpresas to (empresa.lineas - 2) do List.LineaTxt(' ', True);

   List.LineaTxt(utiles.sLLenarIzquierda(lin, 200, CHR(196)), True);
   nombre := leyenda + utiles.espacios(83 - Length(Trim(leyenda)));
   List.LineaTxt(nombre, False);
   List.ImporteTxt(totNettot, 11, 2, False);
   List.ImporteTxt(totNettot1, 11, 2, False);
   List.ImporteTxt(totOpexenta, 11, 2, False);
   List.ImporteTxt(totConnograv, 11, 2, False);
   List.ImporteTxt(totIva, 11, 2, False);
   List.ImporteTxt(totIvarec, 11, 2, False);
   List.ImporteTxt(totPercepcion, 11, 2, False);
   List.ImporteTxt(totPergan, 11, 2, False);
   List.ImporteTxt(totTotoper, 13, 2, False);
   List.ImporteTxt(totCDfiscal, 11, 2, True);
  end;
end;

procedure TTIvaVenta.LineaIva(salida: char);
// Objetivo...: Imprimir una Línea de Detalle
var fuente: String;
begin
  if (salida = 'P') or (salida = 'I') then Begin
   fuente := 'Arial, normal, 8';
   if (salida = 'P') and (tiva.FieldByName('tipomov').AsString = 'C') then fuente := 'Arial, normal, 8, clNavy';
   if not infresumido then Begin
    if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> 'N' then Begin
      list.Linea(0, 0, ' ', 1, fuente, salida, 'N');
      list.Linea(espacios, list.Lineactual, utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString), 2, fuente, salida, 'N');
      list.Linea(17, list.lineactual, tiva.FieldByName('idcompr').AsString , 3, fuente, salida, 'N');
      if tiva.FieldByName('tipomov').AsString = 'X' then list.Linea(20, list.lineactual, tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + '  ' + 'A N U L A D A' , 4, fuente, salida, 'N') else
        if tiva.FieldByName('tipomov').AsString = 'C' then list.Linea(20, list.lineactual, tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + '/' + tiva.FieldByName('ultimonro').AsString + '  ' + Copy(tiva.FieldByName('rsocial').AsString, 1, 17), 4, fuente, salida, 'N') else
          list.Linea(20, list.lineactual, tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + '  ' + Copy(tiva.FieldByName('rsocial').AsString, 1, 25) , 4, fuente, salida, 'N');
      list.Linea(58, list.lineactual, tiva.FieldByName('cuit').AsString, 5, fuente, salida, 'N');
      list.Linea(70, list.lineactual, tiva.FieldByName('codiva').AsString, 6, fuente, salida, 'N');
    end else Begin
      list.Linea(0, 0, '  ', 1, fuente, salida, 'N');
      list.Linea(17, list.lineactual, ' ', 2, fuente, salida, 'N');
      list.Linea(20, list.lineactual, ' ', 3, fuente, salida, 'N');
      list.Linea(65, list.lineactual, ' ', 4, fuente, salida, 'N');
      list.Linea(70, list.lineactual, ' ', 5, fuente, salida, 'N');
      list.Linea(74, list.lineactual, ' ', 6, fuente, salida, 'N');
    end;
    list.importe(82,  list.lineactual, '', tiva.FieldByName('Nettot').AsFloat, 7, fuente);
    list.importe(91,  list.lineactual, '', tiva.FieldByName('Nettot1').AsFloat, 8, fuente);
    list.importe(100, list.lineactual, '', tiva.FieldByName('Opexenta').AsFloat, 9, fuente);
    list.importe(109, list.lineactual, '', tiva.FieldByName('Connograv').AsFloat, 10, fuente);
    list.importe(118, list.lineactual, '', tiva.FieldByName('Iva').AsFloat, 11, fuente);
    list.importe(127, list.lineactual, '', tiva.FieldByName('Ivarec').AsFloat, 12, fuente);
    list.importe(136, list.lineactual, '', tiva.FieldByName('Percep2').AsFloat, 13, fuente);
    list.importe(145, list.lineactual, '', tiva.FieldByName('Percep1').AsFloat, 14, fuente);
    list.importe(154, list.lineactual, '', tiva.FieldByName('Totoper').AsFloat, 15, fuente);
    list.importe(163, list.lineactual, '', tiva.FieldByName('Cdfiscal').AsFloat, 16, fuente);
    list.Linea(164, list.lineactual, ' ', 17, fuente, salida, 'S');
   end;
  end else Begin
    if tiva.FieldByName('tipomov').AsString = 'X' then nombre := tiva.FieldByName('numero').AsString + 'A N U L A D A ' + utiles.espacios(40 - Length(Trim('A N U L A D A'))) else nombre := tiva.FieldByName('numero').AsString + ' ' + tiva.FieldByName('rsocial').AsString + utiles.espacios(40 - Length(Trim(tiva.FieldByName('rsocial').AsString))) + ' ';
    if tiva.FieldByName('tipomov').AsString = 'C' then nombre := tiva.FieldByName('numero').AsString + '/' + tiva.FieldByName('ultimonro').AsString + ' ' + Copy(tiva.FieldByName('rsocial').AsString, 1, 15) + utiles.espacios(31 - Length(Trim(Copy(tiva.FieldByName('rsocial').AsString, 1, 15)))) + ' ';
    if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> 'N' then list.LineaTxt(utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString) + ' ' + tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + nombre + ' ' + tiva.FieldByName('cuit').AsString + ' ' + tiva.FieldByName('codiva').AsString + ' ', False) else
      list.LineaTxt('                                                                                       ', False);
    list.ImporteTxt(tiva.FieldByName('Nettot').AsFloat, 11, 2, False);
    list.ImporteTxt(tiva.FieldByName('Nettot1').AsFloat, 11, 2, False);
    list.ImporteTxt(tiva.FieldByName('Opexenta').AsFloat, 11, 2, False);
    list.ImporteTxt(tiva.FieldByName('connograv').AsFloat, 11, 2, False);
    list.ImporteTxt(tiva.FieldByName('Iva').AsFloat, 11, 2, False);
    list.ImporteTxt(tiva.FieldByName('Ivarec').AsFloat, 11, 2, False);
    list.ImporteTxt(tiva.FieldByName('Percep2').AsFloat, 11, 2, False);
    list.ImporteTxt(tiva.FieldByName('Percep1').AsFloat, 11, 2, False);
    list.ImporteTxt(tiva.FieldByName('Totoper').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Cdfiscal').AsFloat, 11, 2, True);
    Inc(lineasimpresas);
  end;

  //Subtotales
  if tiva.FieldByName('tipomov').AsString <> 'X' then Begin   // Si el comprobante no esta anulado
    totNettot     := totNettot     + tiva.FieldByName('Nettot').AsFloat;
    totNettot1    := totNettot1    + tiva.FieldByName('Nettot1').AsFloat;
    totOpexenta   := totOpexenta   + tiva.FieldByName('Opexenta').AsFloat;
    totConnograv  := totConnograv  + tiva.FieldByName('Connograv').AsFloat;
    totIva        := totIva        + tiva.FieldByName('Iva').AsFloat;
    totIvarec     := totIvarec     + tiva.FieldByName('Ivarec').AsFloat;
    totPercepcion := totPercepcion + tiva.FieldByName('Percep2').AsFloat;
    totPergan     := totPergan     + tiva.FieldByName('Percep1').AsFloat;
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

  totNettot := 0; totOpexenta := 0; totConnograv := 0; totIva := 0; totIvarec := 0; totPercepcion := 0; totPergan := 0; totTotOper := 0; totCDfiscal := 0;
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
  TSQL := datosdb.tranSQL(path, 'SELECT * FROM ivaventa WHERE fecha >= ' + '''' + utiles.sExprFecha(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(hf) + '''' + ' AND tipomov <> ' + '"' + 'X' + '"' + ' ORDER BY codmov');
  inherited Listar_NetoDiscr('Netos Discriminados en Ventas', salida);
end;

procedure TTIvaventa.List_Codpfis(df, hf: string; salida: char);
// Objetivo...: Emitir Informe Resumen discrimindo por Netos
begin
  TSQL := datosdb.tranSQL(path, 'SELECT * FROM ivaventa WHERE fecha >= ' + '''' + utiles.sExprFecha(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(hf) + '''' + ' AND tipomov <> ' + '"' + 'X' + '"' + ' ORDER BY codiva');
  ListCodpfis('I.V.A. Discriminado en Ventas', salida);
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
      if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> 'N' then Break;
      tiva.Prior;
    end;
  end;
  if xtipomov = 'adelante' then Begin
    while not tiva.EOF do Begin
      if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> 'N' then Break;
      tiva.Next;
    end;
  end;
  if xtipomov = '' then Begin
    while not tiva.EOF do Begin
      if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> 'N' then Break;
      tiva.Next;
    end;
    if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) = 'N' then Begin
      while not tiva.BOF do Begin
        if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> 'N' then Break;
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
  tiva := nil; iiva := nil; ivacon := nil;
  tiva   := datosdb.openDB('ivaventa', 'Idcompr;Tipo;Sucursal;Numero', '', dbs.dirSistema + '\' + xvia);
  iiva   := datosdb.openDB('netdisve', 'Idcompr;Tipo;Sucursal;Numero;Cuit;Codmov;CodItems', '', dbs.dirSistema + '\' + xvia);
  ivacon := datosdb.openDB('ivaventas_cons', '', '', dbs.dirSistema + '\' + xvia);
  cliente.Via(xvia);
  inherited Via(xvia);
  tc := 1;
  path := dbs.dirSistema + '\' + xvia;
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

function TTIvaventa.BuscarFactura(xitems, xidcompr, xtipo, xsucursal, xnumero: String): Boolean;
// Objetivo...: Retornar resultado
Begin
  Result := datosdb.Buscar(ivacon, 'Items', 'Idcompr', 'Tipo', 'Sucursal', 'Numero', xitems, xidcompr, xtipo, xsucursal, xnumero);
end;

procedure TTIvaventa.GrabarFacturasConsecutivas(xitems, xidcompr, xtipo, xsucursal, xnumero: String; xnettot, xnettot1, xopexentas, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: Real; xcantitems: Integer);
// Objetivo...: Guardar el detalle de Facturas consecutivas
Begin
  if xitems = '001' then datosdb.tranSQL(path, 'DELETE FROM ivaventas_cons WHERE items > ' + '"' + xitems + '"');
  if BuscarFactura(xitems, xidcompr, xtipo, xsucursal, xnumero) then ivacon.Edit else ivacon.Append;
  ivacon.FieldByName('items').AsString    := xitems;
  ivacon.FieldByName('idcompr').AsString  := xidcompr;
  ivacon.FieldByName('tipo').AsString     := xtipo;
  ivacon.FieldByName('sucursal').AsString := xsucursal;
  ivacon.FieldByName('numero').AsString   := xnumero;
  ivacon.FieldByName('nettot').AsFloat    := xnettot;
  ivacon.FieldByName('nettot1').AsFloat   := xnettot1;
  ivacon.FieldByName('opexenta').AsFloat  := xopexentas;
  ivacon.FieldByName('connograv').AsFloat := xconnograv;
  ivacon.FieldByName('iva').AsFloat       := xiva;
  ivacon.FieldByName('ivarec').AsFloat    := xivarec;
  ivacon.FieldByName('percep1').AsFloat   := xpercep1;
  ivacon.FieldByName('percep2').AsFloat   := xpercep2;
  ivacon.FieldByName('cdfiscal').AsFloat  := xcdfiscal;
  ivacon.FieldByName('totoper').AsFloat   := xtotoper;
  try
    ivacon.Post
   except
    ivacon.Cancel
  end;
end;

function TTIvaventa.setFacturasConsecutivas: TQuery;
// Objetivo...: Devolver las Facturas que se cargaron como consecutivas
Begin
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + ivacon.TableName + ' WHERE tipo = ' + '"' + tipo + '"' + ' AND idcompr = ' + '"' + idcompr + '"' + ' AND sucursal = ' + '"' + sucursal + '"' + ' AND numero >= ' + '"' + numero + '"' + ' AND numero <= ' + '"' + ultimonro + '"');
end;

procedure TTIvaventa.BorrarFacturas;
// Objetivo...: Borrar Factura
Begin
  datosdb.tranSQL(path, 'DELETE FROM ' + ivacon.TableName + ' WHERE tipo = ' + '"' + tipo + '"' + ' AND idcompr = ' + '"' + idcompr + '"' + ' AND sucursal = ' + '"' + sucursal + '"' + ' AND numero >= ' + '"' + numero + '"' + ' AND numero <= ' + '"' + ultimonro + '"');
end;

procedure TTIvaventa.conectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if tc = 0 then cliente.conectar else cliente.conectar;
  inherited conectar;
end;

procedure TTivaventa.desconectar;
//Objetivo...: desconectar tablas de persistencia
begin
  if tc = 0 then cliente.desconectar else cliente.desconectar;
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
