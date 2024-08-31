unit CIvaventa;

interface

uses CIva, CTablaIva, Cliengar, CCliente, CCNetos, SysUtils, DB, DBTables, CBDT,
     CUtiles, CListar, Listado, CEmpresas, CIDBFM, CUtilidadesArchivos;

type

TTivaventa = class(TTIva)
  anulado: Boolean;
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
  procedure   Titulo(tipolistado: char; mes: string); virtual;
  procedure   List_Netodiscr(df, hf: string; salida: char);
  procedure   List_Codpfis(df, hf: string; salida: char);
  function    setMovimientosMultiplesNetos: TQuery;
  procedure   verificarTipoDeMovimiento(xtipomov: string);
  procedure   AnularComprobante(xidcompr, xtipo, xsucursal, xnumero: string);

  procedure   ExportarIVA(xvia, xdfecha, xhfecha, xdrive, xtipo_fecha: String);

  procedure   Via(xvia: string);
  procedure   Parche;
  procedure   conectar;
  procedure   desconectar;
 protected
  { Declaraciones Protegidas }
  tc: shortint; SaltoManual: Boolean; l1, l2: string;
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
  try
    tiva.Post;
   except
    tiva.Cancel;
  end;
  if f then tiva.Filtered := True;
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
var
  t, c, m: string;   // Identifica netdisco o netdisve
begin
  t := string(iiva.TableName);
  if Buscar(xidcompr, xtipo, xsucursal, xnumero) then Begin
    c := tiva.FieldByName('cuit').AsString;
    m := tiva.FieldByName('tipomov').AsString;
    tiva.Delete;  // Movimiento maestro
    if m = '-' then datosdb.tranSQL(path, 'DELETE FROM ivaventa WHERE idcompr = ' + '"' + xidcompr + '"' + ' AND tipo = ' + '"' + xtipo + '"' + ' AND numero = ' + '"' + xnumero + '"' + ' AND rsocial = ' + '"' + 'NNNTX' + xsucursal + '"');
    verificarTipoDeMovimiento('');
    getDatos(tiva.FieldByName('idcompr').AsString, tiva.FieldByName('tipo').AsString, tiva.FieldByName('sucursal').AsString, tiva.FieldByName('numero').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

procedure TTIvaventa.getDatos(xidcompr, xtipo, xsucursal, xnumero: string);
// Retorno los atributos
begin
  if Buscar(xidcompr, xtipo, xsucursal, xnumero) then trans_datos else iniciar_datos;
  if tiva.FieldByName('tipomov').AsString = 'X' then anulado := True else anulado := False;
end;

// ------- Gestión de Informes -------------

procedure TTIvaVenta.Titulo(tipolistado: char; mes: string);
{Objetivo....: Emitir los Títulos del Listado}
begin
  if (tipolistado = 'P') or (tipolistado = 'I') then Begin
    Inc(pag);
    //ListDatosEmpresa(tipolistado);
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14'); list.Titulo(espacios, list.Lineactual, 'Libro I.V.A. Ventas      -     ' + meses[StrToInt(Copy(mes, 1, 2))] + '  de  ' + Copy(mes, 4, 4), 2, 'Arial, negrita, 14');
    list.Titulo(0, 0, '', 1, 'Times New Roman, normal, 8');
    list.Titulo(95, list.Lineactual, 'Hoja Nº: #pagina', 2, 'Times New Roman, normal, 8');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8'); list.Titulo(espacios, list.Lineactual, list.linealargopagina(tipolistado), 2, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ',1 , 'Arial, normal, 4');
    // 1º Línea de Títulos
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8'); list.Titulo(espacios, list.Lineactual, 'Fecha',2 , 'Arial, cursiva, 8');
    list.Titulo(17, list.lineactual, 'Comprobante' + utiles.espacios(17) + 'Cliente',3 , 'Arial, cursiva, 8');
    list.Titulo(65, list.lineactual, 'C.U.I.T. Nº' + utiles.espacios(10) + 'IVA',4 , 'Arial, cursiva, 8');
    list.Titulo(87, list.lineactual, ' Neto',5 , 'Arial, cursiva, 8');
    list.Titulo(92, list.lineactual, 'Operaciones',6 , 'Arial, cursiva, 8');
    list.Titulo(102, list.lineactual, 'Conceptos',7 , 'Arial, cursiva, 8');
    list.Titulo(114, list.lineactual, 'I.V.A.',8 , 'Arial, cursiva, 8');
    list.Titulo(123, list.lineactual, 'I.V.A.',9 , 'Arial, cursiva, 8');
    list.Titulo(132, list.lineactual, 'Percep.', 10, 'Arial, cursiva, 8');
    list.Titulo(140, list.lineactual, 'Retenc.', 11, 'Arial, cursiva, 8');
    list.Titulo(150, list.lineactual, 'Total',12 , 'Arial, cursiva, 8');
    list.Titulo(156, list.lineactual, l1,13 , 'Arial, cursiva, 8');

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
  list.LineaTxt('Fecha    Comprobante     Cliente                                  C.U.I.T. N' + CHR(167) + '  IVA         Neto   Operaciones    Conceptos      I.V.A.        I.V.A.       Percep.     Retenc.        Total  Debito Res.', True);
  list.LineaTxt('                                                                                                      Exentas     No Grav.       Normal      Recargo   Ing. Brutos      I.V.A.    Operacion       Varias', True);
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
   list.importe(100, list.lineactual, '', totOpexenta, 4, 'Arial, negrita, 8');
   list.importe(109, list.lineactual, '', totConnograv, 5, 'Arial, negrita, 8');
   list.importe(118, list.lineactual, '', totIva, 6, 'Arial, negrita, 8');
   list.importe(127, list.lineactual, '', totIvarec, 7, 'Arial, negrita, 8');
   list.importe(136, list.lineactual, '', totPercepcion, 8, 'Arial, negrita, 8');
   list.importe(143, list.lineactual, '', totPergan, 9, 'Arial, negrita, 8');
   list.importe(152, list.lineactual, '', totTotoper, 10, 'Arial, negrita, 8');
   list.importe(163, list.lineactual, '', totCdfiscal, 11, 'Arial, negrita, 8');
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
    if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> 'N' then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(espacios, list.Lineactual, utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(17, list.lineactual, tiva.FieldByName('idcompr').AsString , 3, 'Arial, normal, 8', salida, 'N');
      if tiva.FieldByName('tipomov').AsString = 'X' then list.Linea(20, list.lineactual, tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + '  ' + 'A N U L A D A' , 4, 'Arial, normal, 8', salida, 'N') else
        list.Linea(20, list.lineactual, tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + '  ' + Copy(tiva.FieldByName('rsocial').AsString, 1, 25) , 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(65, list.lineactual, tiva.FieldByName('cuit').AsString, 5, 'Arial, normal, 8', salida, 'N');
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
    list.importe(100, list.lineactual, '', tiva.FieldByName('Opexenta').AsFloat, 8, 'Arial, normal, 8');
    list.importe(109, list.lineactual, '', tiva.FieldByName('Connograv').AsFloat, 9, 'Arial, normal, 8');
    list.importe(118, list.lineactual, '', tiva.FieldByName('Iva').AsFloat, 10, 'Arial, normal, 8');
    list.importe(127, list.lineactual, '', tiva.FieldByName('Ivarec').AsFloat, 11, 'Arial, normal, 8');
    list.importe(136, list.lineactual, '', tiva.FieldByName('Percep2').AsFloat, 12, 'Arial, normal, 8');
    list.importe(145, list.lineactual, '', tiva.FieldByName('Percep1').AsFloat, 13, 'Arial, normal, 8');
    list.importe(154, list.lineactual, '', tiva.FieldByName('Totoper').AsFloat, 14, 'Arial, normal, 8');
    list.importe(163, list.lineactual, '', tiva.FieldByName('Cdfiscal').AsFloat, 15, 'Arial, normal, 8');
    list.Linea(164, list.lineactual, ' ', 16, 'Arial, normal, 8', salida, 'S');
   end;
  end else Begin
    if tiva.FieldByName('tipomov').AsString = 'X' then nombre := 'A N U L A D A' + utiles.espacios(40 - Length(Trim('A N U L A D A'))) else nombre := tiva.FieldByName('rsocial').AsString + utiles.espacios(40 - Length(Trim(tiva.FieldByName('rsocial').AsString)));
     //if tiva.FieldByName('tipomov').AsString = 'A' then nombre := 'A N U L A D A' + utiles.espacios(40 - Length(Trim('A N U L A D A'))) else nombre := tiva.FieldByName('rsocial').AsString + utiles.espacios(40 - Length(Trim(tiva.FieldByName('rsocial').AsString)));
    if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> 'N' then list.LineaTxt(utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString) + ' ' + tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + ' ' + nombre + ' ' + tiva.FieldByName('cuit').AsString + ' ' + tiva.FieldByName('codiva').AsString + ' ', False) else
      list.LineaTxt('                                                                                   ', False);
    list.ImporteTxt(tiva.FieldByName('Nettot').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Opexenta').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Connograv').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Iva').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Ivarec').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Percep2').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Percep1').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Totoper').AsFloat, 13, 2, False);
    list.ImporteTxt(tiva.FieldByName('Cdfiscal').AsFloat, 13, 2, True);
    Inc(lineasimpresas);
  end;

  //Subtotales
  if tiva.FieldByName('tipomov').AsString <> 'X' then Begin   // Si el comprobante no esta anulado
    totNettot     := totNettot     + tiva.FieldByName('Nettot').AsFloat;
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
  Listar_NetoDiscr('Netos Discriminados en Ventas', salida);
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
  Result := datosdb.tranSQL(path, 'SELECT ivaventa.sucursal, ivaventa.codmov, ivaventa.Rsocial, ivaventa.nettot, ivaventa.iva, ivaventa.ivarec FROM ivaventa WHERE idcompr = ' + '"' + idcompr + '"' + ' AND tipo = ' + '"' + tipo + '"' + ' AND numero = ' + '"' + numero + '"');
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
  path := dbs.dirSistema + '\' + xvia;
  if not datosdb.verificarSiExisteCampo('ivaventa', 'control', path) then Begin
    datosdb.tranSQL(path, 'alter table ivaventa add control char(2)');
    datosdb.tranSQL(path, 'update ivaventa set control = ' + '"' + '00' + '"');
  end;
  tiva := nil; iiva := nil;
  tiva := datosdb.openDB('ivaventa', 'Idcompr;Tipo;Sucursal;Numero', '', dbs.dirSistema + '\' + xvia);
  iiva := datosdb.openDB('netdisve', 'Idcompr;Tipo;Sucursal;Numero;Cuit;Codmov;CodItems', '', dbs.dirSistema + '\' + xvia);
  cliente.Via(xvia);
  inherited Via(xvia);
  tc := 1;
  // Controlar verificar si se creo el campo de control
  {if not datosdb.verificarSiExisteCampo(tiva, 'control') then Begin
    tiva.Close;
    datosdb.tranSQL(path, 'alter table ivaventa add control char(2)');
    datosdb.tranSQL(path, 'update ivaventa set control = ' + '"' + '00' + '"');
    tiva.Open;
  end;}
end;

procedure TTIvaventa.ExportarIVA(xvia, xdfecha, xhfecha, xdrive, xtipo_fecha: String);
// Objetivo...: Exportar Datos I.V.A.
var
  exp_iva: TTable;
  e: Boolean;
Begin
  Via(xvia);
  exp_iva := datosdb.openDB('ivaventa', '', '', dbs.DirSistema + '\exportar');
  tiva.Open; exp_iva.Open;
  while not tiva.Eof do Begin
    e := False;
    if xtipo_fecha = 'E' then
      if (tiva.FieldByName('fecha').AsString >= utiles.sExprFecha2000(xdfecha)) and (tiva.FieldByName('fecha').AsString <= utiles.sExprFecha2000(xhfecha)) then e := True;
    if xtipo_fecha = 'R' then
      if (utiles.sExprFecha2000(tiva.FieldByName('ferecep').AsString) >= utiles.sExprFecha2000(xdfecha)) and (utiles.sExprFecha2000(tiva.FieldByName('ferecep').AsString) <= utiles.sExprFecha2000(xhfecha)) then e := True;
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
      try
        exp_iva.Post
       except
        exp_iva.Cancel
      end;
    end;
    tiva.Next;
  end;
  tiva.Close; exp_iva.Close;

  utilesarchivos.CopiarArchivos(dbs.DirSistema + '\exportar', 'ivaventa.*', xdrive + ':');
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
  if tc = 0 then clientegar.conectar else cliente.conectar;
  inherited conectar;
end;

procedure TTivaventa.desconectar;
//Objetivo...: desconectar tablas de persistencia
begin
  if tc = 0 then clientegar.desconectar else cliente.desconectar;
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
