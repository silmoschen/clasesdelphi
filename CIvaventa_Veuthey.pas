unit CIvaventa_Veuthey;

interface

uses CIva, CTablaIva, CCliente, CCNetos, SysUtils, DB, DBTables, CBDT,
     CUtiles, CListar, Listado, CEmpresas, CIDBFM, CUtilidadesArchivos,
     CServers2000_Excel, CCTipoMovIVA;

type

TTivaventa = class(TTIva)
  anulado: Boolean; Control, Bienuso, Nrocomphasta: String;
 public
  { Declaraciones P�blicas }
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
                     xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real; xcontrol, xbienuso, xidmov: String); overload;
  procedure   getDatos(xidcompr, xtipo, xsucursal, xnumero: string);
  procedure   Borrar(xidcompr, xtipo, xsucursal, xnumero: string); overload;
  procedure   ListarLibroIVA_Ventas(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro: string);
  procedure   Titulo(tipolistado: char; mes: string); virtual;
  procedure   List_Netodiscr(df, hf: string; salida: char);
  procedure   List_Codpfis(df, hf: string; salida: char);
  function    setMovimientosMultiplesNetos: TQuery;
  procedure   verificarTipoDeMovimiento(xtipomov: string);
  procedure   AnularComprobante(xidcompr, xtipo, xsucursal, xnumero: string);

  procedure   Exportar(xvia, xdfecha, xhfecha, xmodo: String);
  procedure   ExportarIVA(xvia, xdfecha, xhfecha, xdrive, xdir, xtipo_fecha: String);
  procedure   ExportarIVAExcel(xvia, xdfecha, xhfecha, xtipo_fecha, xcont: String);
  procedure   ProcesarDatosImportados(xvia: String);

  procedure   IniciarExportacionCITI(xdesde, xhasta, xarchivo: String);
  procedure   ContinuarExportacionCITI(xdesde, xhasta, xarchivo: String);
  procedure   ExportarAlCITI(xdesde, xhasta, xidc, xtipo, xsucursal, xnumero, xtipo_comprobante, xcodcomprador: String);
  procedure   ExportarAlCITI2016(xdesde, xhasta, xidc, xtipo, xsucursal, xnumero, xtipo_comprobante, xcodcomprador: String);
  procedure   FinalizarExportacionCITI;
  procedure   ListarExportacionCITI(xdesde, xhasta: String; salida: char);

  procedure   Via(xvia: string);
  procedure   Parche;
  procedure   conectar;
  procedure   desconectar;
 protected
  { Declaraciones Protegidas }
  tc: shortint; SaltoManual: Boolean; l1, l2: string;
  citi: TTable;
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
// Objetivo...: sobreescribir el m�todo de busqueda de la superclase
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
  datosdb.refrescar(tiva);
end;

procedure TTIvaventa.Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xtipomov: string;
                            xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real; xitems: Integer);
// Objetivo...: Grabar Atributos del Objeto; cuando se trata de multiples netos
begin
  if xitems = 1 then Borrar(xidcompr, xtipo, xsucursal, xnumero);
  Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xtipomov, xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper);
end;

procedure TTIvaventa.Grabar(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xtipomov: string;
                     xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper: real; xcontrol, xbienuso, xidmov: String);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidcompr, xtipo, xsucursal, xnumero) then tiva.Edit else tiva.Append;
  inherited Act_atributos(xidcompr, xtipo, xsucursal, xnumero, xcuit, xclipro, xrsocial, xcodiva, xconcepto, xferecep, xfecha, xcodprovin, xcodmov, xnettot, xopexenta, xconnograv, xiva, xivarec, xpercep1, xpercep2, xcdfiscal, xtotoper);
  tiva.Edit;
  tiva.FieldByName('control').AsString := xcontrol;
  tiva.FieldByName('bienuso').AsString := xbienuso;
  tiva.FieldByName('idmov').AsString   := xidmov;
  try
    tiva.Post;
   except
    tiva.Cancel;
  end;
  datosdb.refrescar(tiva);
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
    datosdb.closeDB(tiva); tiva.Open;
  end;
end;

procedure TTIvaventa.getDatos(xidcompr, xtipo, xsucursal, xnumero: string);
// Retorno los atributos
var
  l: Boolean;
begin
  l := Buscar(xidcompr, xtipo, xsucursal, xnumero);
  if l then trans_datos else iniciar_datos;
  if tiva.FieldByName('tipomov').AsString = 'X' then anulado := True else anulado := False;
  control := tiva.FieldByName('control').AsString;
  if l then Begin
    Bienuso   := tiva.FieldByName('bienuso').AsString;
    idmov     := tiva.FieldByName('idmov').AsString;
  end else Begin
    Bienuso   := 'N';
    idmov     := '';
  end;
  if Length(Trim(bienuso)) = 0 then Bienuso := 'N';
end;

// ------- Gesti�n de Informes -------------

procedure TTIvaVenta.Titulo(tipolistado: char; mes: string);
{Objetivo....: Emitir los T�tulos del Listado}
begin
  if (tipolistado = 'P') or (tipolistado = 'I') then Begin
    Inc(pag);
    ListDatosEmpresa(tipolistado);
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14'); list.Titulo(espacios, list.Lineactual, 'Libro I.V.A. Ventas      -     ' + meses[StrToInt(Copy(mes, 1, 2))] + '  de  ' + Copy(mes, 4, 4), 2, 'Arial, negrita, 14');
    list.Titulo(0, 0, '', 1, 'Times New Roman, ninguno, 8');
    list.Titulo(95, list.Lineactual, 'Hoja N�: #pagina', 2, 'Times New Roman, ninguno, 8');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8'); list.Titulo(espacios, list.Lineactual, list.linealargopagina(tipolistado), 2, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ',1 , 'Arial, normal, 4');
    // 1� L�nea de T�tulos
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8'); list.Titulo(espacios, list.Lineactual, 'Fecha',2 , 'Arial, cursiva, 8');
    list.Titulo(17, list.lineactual, 'Comprobante' + utiles.espacios(22) + 'Cliente',3 , 'Arial, cursiva, 8');
    list.Titulo(65, list.lineactual, 'C.U.I.T. N�' + utiles.espacios(10) + 'IVA',4 , 'Arial, cursiva, 8');
    list.Titulo(87, list.lineactual, ' Neto',5 , 'Arial, cursiva, 8');
    list.Titulo(92, list.lineactual, 'Operaciones',6 , 'Arial, cursiva, 8');
    list.Titulo(102, list.lineactual, 'Conceptos',7 , 'Arial, cursiva, 8');
    list.Titulo(114, list.lineactual, 'I.V.A.',8 , 'Arial, cursiva, 8');
    list.Titulo(123, list.lineactual, 'I.V.A.',9 , 'Arial, cursiva, 8');
    list.Titulo(132, list.lineactual, 'Percep.', 10, 'Arial, cursiva, 8');
    list.Titulo(140, list.lineactual, 'Retenc.', 11, 'Arial, cursiva, 8');
    list.Titulo(150, list.lineactual, 'Total',12 , 'Arial, cursiva, 8');
    list.Titulo(156, list.lineactual, l1,13 , 'Arial, cursiva, 8');

    // 2� L�nea de T�tulos
    list.Titulo(0, 0, ' ',1 , 'Arial, cursiva, 8');
    list.Titulo(95, list.lineactual, 'Exentas',2 , 'Arial, cursiva, 8');
    list.Titulo(103, list.lineactual, 'No Grav.',3 , 'Arial, cursiva, 8');
    list.Titulo(113, list.lineactual, 'Normal',4 , 'Arial, cursiva, 8');
    list.Titulo(121, list.lineactual, 'Recargo', 5, 'Arial, cursiva, 8');
    list.Titulo(130, list.lineactual, 'Ing. Brutos',6 , 'Arial, cursiva, 8');
    list.Titulo(141, list.lineactual, 'I.V.A.',7 , 'Arial, cursiva, 8');
    list.Titulo(147, list.lineactual, 'Operaci�n',8 , 'Arial, cursiva, 8');
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
       list.CompletarPagina;     // Rellenamos la P�gina
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
// Objetivo...: Imprimir una L�nea de Detalle
begin
  if (salida = 'P') or (salida = 'I') then Begin
   if not infresumido then Begin
    if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> 'N' then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(espacios, list.Lineactual, utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(17, list.lineactual, tiva.FieldByName('idcompr').AsString , 3, 'Arial, normal, 8', salida, 'N');
      if tiva.FieldByName('tipomov').AsString = 'X' then list.Linea(20, list.lineactual, tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + '  ' + 'A N U L A D A' , 4, 'Arial, normal, 8', salida, 'N') else
        list.Linea(20, list.lineactual, tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('control').AsString + '/' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + '  ' + Copy(tiva.FieldByName('rsocial').AsString, 1, 25) , 4, 'Arial, normal, 8', salida, 'N');
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
    if tiva.FieldByName('tipomov').AsString = 'X' then nombre := 'A N U L A D A' + utiles.espacios(36 - Length(Trim('A N U L A D A'))) else nombre := tiva.FieldByName('rsocial').AsString + utiles.espacios(36 - Length(Trim(tiva.FieldByName('rsocial').AsString)));
    if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> 'N' then list.LineaTxt(utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString) + ' ' + tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('control').AsString + '/' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + ' ' + nombre + ' ' + tiva.FieldByName('cuit').AsString + ' ' + tiva.FieldByName('codiva').AsString + ' ', False) else
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

{Objetivo...: Cuerpo de Emisi�n}
procedure TTIvaVenta.ListarLibroIVA_Ventas(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro: string);
var
  i: string;
begin
  if salida = 'T' then if inf_iniciado then list.LineaTxt(CHR(12), True);
  if not inf_iniciado then
    if salida = 'I' then IniciarInfSubtotales(salida, 3) else IniciarInforme(salida);

  // Leyenda de acuerdo a la Condici�n del contribuyente
  if empresa.Catempr = 1 then Begin
    l1 := 'D�bito Res.'; l2 := '       Varias';
  end else Begin
    l1 := '   Retenci�n'; l2 := 'Ganancias';
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
  tiva.IndexName := 'ListLibro';
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
    if t_filtro = '6' then     // Bienes de Uso
        if (tiva.FieldByName('ferecep').AsString >= p1) and (tiva.FieldByName('ferecep').AsString <= p2) and (tiva.FieldByName('bienuso').AsString = 'S') then LineaIva(salida);
    if t_filtro = '7' then     // Bienes de Uso
        if (tiva.FieldByName('ferecep').AsString >= p1) and (tiva.FieldByName('ferecep').AsString <= p2) and (tiva.FieldByName('idmov').AsString = p3) then LineaIva(salida);
    tiva.Next;
  end;

  if (totTotOper = 0) and not (infresumido) then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(espacios, list.Lineactual, 'Sin Movimientos', 2, 'Arial, normal, 10', salida, 'S');
    end;
    if salida = 'T' then
      list.LineaTxt(CHR(18) + 'Sin Movimientos' + CHR(15), True);
  end;
  Transporte('Subtotales:', salida);

  tiva.IndexFieldNames := i;
end;

procedure TTIvaventa.List_Netodiscr(df, hf: string; salida: char);
// Objetivo...: Emitir Informe Resumen discrimindo por Netos
begin
  TSQL := datosdb.tranSQL(path, 'SELECT * FROM ivaventa WHERE fecha >= ' + '''' + utiles.sExprFecha2000(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha2000(hf) + '''' + ' AND tipomov <> ' + '"' + 'X' + '"' + ' ORDER BY codmov');
  Listar_NetoDiscr('Netos Discriminados en Ventas', salida);
end;

procedure TTIvaventa.List_Codpfis(df, hf: string; salida: char);
// Objetivo...: Emitir Informe Resumen discrimindo por Netos
begin
  TSQL := datosdb.tranSQL(path, 'SELECT * FROM ivaventa WHERE fecha >= ' + '''' + utiles.sExprFecha2000(df) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha2000(hf) + '''' + ' AND tipomov <> ' + '"' + 'X' + '"' + ' ORDER BY codiva');
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
  datosdb.refrescar(tiva);
end;

procedure TTIvaventa.IniciarExportacionCITI(xdesde, xhasta, xarchivo: String);
// Objetivo...: Iniciar Exportacion al CITI
var
  p: integer;
begin
  AssignFile(archivo, xarchivo);
  Rewrite(archivo);
  if not FileExists(tiva.DatabaseName + '\detcitiv.db') then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\estructu\citiventas', '*.*', tiva.DatabaseName);
  citi := datosdb.openDB('detcitiv', '', '', tiva.DatabaseName);
  datosdb.tranSQL(citi.DatabaseName, 'delete from ' + citi.TableName + ' where desde = ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and hasta = ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  AssignFile(alicuotas, copy(xarchivo, 1, 3) +  'alicuotas_' + trim(copy(xarchivo, 4, 20)));
  Rewrite(alicuotas);
end;

procedure TTIvaventa.ContinuarExportacionCITI(xdesde, xhasta, xarchivo: String);
// Objetivo...: Continuar Exportacion al CITI
begin
  AssignFile(archivo, xarchivo);
  Append(archivo);
  AssignFile(alicuotas, copy(xarchivo, 1, 3) +  'alicuotas_' + trim(copy(xarchivo, 4, 20)));
  Append(alicuotas);
end;

procedure TTIvaventa.ExportarAlCITI2016(xdesde, xhasta, xidc, xtipo, xsucursal, xnumero, xtipo_comprobante, xcodcomprador: String);
// Objetivo...: Exportar comprobante al CITI
var
  n: array[1..5] of String;
  alic: string;
begin
  citi.Open;
  getDatos(xidc, xtipo, xsucursal, xnumero);
  tabliva.getDatos(codiva);

  n[1] := utiles.sLlenarIzquierda(numero, 20, '0');

  Write(archivo, utiles.sExprFecha2000(fecha));
  Write(archivo, trim(xtipo_comprobante));
  if (Copy(sucursal, 1, 4) <> '0000') then n[3] := Copy(sucursal, 1, 4) else
    n[3] := '0001';

  if (Copy(xsucursal, 1, 1) <> '0') then n[3] := '0' + Copy(xsucursal, 2, 3);

  Write(archivo, utiles.sLlenarIzquierda(n[3], 5, '0'));

  Write(archivo, n[1]);
  Write(archivo, n[1]);

  if (xcodcomprador = '80') or (xcodcomprador = 'PT') then Write(archivo, '080');
  if (xcodcomprador = '99') or (xcodcomprador = 'PT') then Write(archivo, '99');
  if (xcodcomprador = 'PR') then Write(archivo, trim(codprovin));

  n[2] := '00000000000';
  if (xcodcomprador = '80') or (xcodcomprador = 'PT') then begin
    if Length(Trim(cuit)) = 13 then
      n[2] := Copy(cuit, 1, 2) + Copy(cuit, 4, 8) + Copy(cuit, 13, 1)
  end;

  if (xcodcomprador = 'PR') then begin
     n[2] := '00000000000';
  end;

  n[2] := utiles.sLlenarIzquierda(n[2], 19, '0');

  if (xcodcomprador = '99') then begin
     n[2] := '00000000000000000000';
  end;


  Write(archivo, n[2]);

  Write(archivo, utiles.StringLongitudFija(rsocial, 29));

  //utiles.msgError(xtipo_comprobante + ' ' + floattostr(totoper) + '  ' + utiles.StringLongitudFija(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(totoper))), 14));

  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(totoper))), 15, '0'));
  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(connograv))), 15, '0'));
  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(0))), 15, '0'));
  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(opexenta))), 15, '0'));
  //Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(0))), 15, '0'));
  Write(archivo, '-' + utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(percep1))), 14, '0'));
  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(0))), 15, '0'));
  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(0))), 15, '0'));
  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(0))), 15, '0'));
  Write(archivo, 'PES');
  Write(archivo, '0001000000');
  Write(archivo, '1');
  Write(archivo, utiles.sLlenarIzquierda(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(0))), 16, '0'));
  if (xcodcomprador = '99') then WriteLn(archivo, '00000000')
    else  WriteLn(archivo, utiles.sExprFecha2000(fecha));


  // Alicuotas -     30/03/2017
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

procedure TTIvaventa.ExportarAlCITI(xdesde, xhasta, xidc, xtipo, xsucursal, xnumero, xtipo_comprobante, xcodcomprador: String);
// Objetivo...: Exportar comprobante al CITI
var
  n: array[1..5] of String;
begin
  citi.Open;
  getDatos(xidc, xtipo, xsucursal, xnumero);
  tabliva.getDatos(codiva);
  n[1] := utiles.sLlenarIzquierda(numero, 20, '0');
  Write(archivo, 1);
  Write(archivo, utiles.sExprFecha2000(fecha));
  Write(archivo, xtipo_comprobante);
  Write(archivo, ' ');
  if (Copy(sucursal, 1, 4) <> '0000') then Write(archivo, Copy(sucursal, 1, 4)) else
    Write(archivo, Copy('0001', 1, 4));
  Write(archivo, n[1]);
  Write(archivo, n[1]);

  if (xcodcomprador = '80') or (xcodcomprador = 'PT') then Write(archivo, '80');
  if (xcodcomprador = 'PR') then Write(archivo, trim(codprovin));

  if (xcodcomprador = '80') or (xcodcomprador = 'PT') then begin
    if Length(Trim(cuit)) = 13 then
      Write(archivo, Copy(cuit, 1, 2) + Copy(cuit, 4, 8) + Copy(cuit, 13, 1))
    else
      Write(archivo, '00000000000');
  end;

  if (xcodcomprador = 'PR') then begin
    Write(archivo, '00000000000');
  end;

  Write(archivo, utiles.StringLongitudFija(rsocial, 29));
  Write(archivo, utiles.StringLongitudFija(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(totoper))), 14));
  Write(archivo, utiles.StringLongitudFija(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(connograv))), 14));
  Write(archivo, utiles.StringLongitudFija(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(nettot))), 14));
  // Vemos si es o no exenta para determinar la alicuota
  if (nettot <> 0) then Write(archivo, Trim(utiles.StringLongitudFija(utiles.sLlenarDerecha(utiles.FormatearNumero(FloatToStr(tabliva.ivari), '####'), 4, '0'), 4))) else
    Write(archivo, Trim(utiles.StringLongitudFija(utiles.sLlenarDerecha(utiles.FormatearNumero(FloatToStr(0), '####'), 4, '0'), 4)));
  Write(archivo, utiles.StringLongitudFija(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(iva))), 13));
  Write(archivo, utiles.StringLongitudFija('', 14));
  Write(archivo, utiles.StringLongitudFija(utiles.StringQuitarCaracteresEnNumeros(utiles.FormatearNumero(FloatToStr(opexenta))), 14));
  Write(archivo, utiles.StringLongitudFija('', 15));
  Write(archivo, utiles.StringLongitudFija('', 15));
  Write(archivo, utiles.StringLongitudFija('', 15));
  Write(archivo, utiles.StringLongitudFija('', 15));
  Write(archivo, utiles.StringLongitudFija('', 11));
  Write(archivo, '1'); // Cantidad de Alicuotas del I.V.A
  Write(archivo, utiles.StringLongitudFija('', 15));
  Write(archivo, utiles.StringLongitudFija('', 15));
  Write(archivo, utiles.StringLongitudFija('', 15));
  Write(archivo, utiles.StringLongitudFija('', 15));
  Write(archivo, utiles.StringLongitudFija('', 23));
  Write(archivo, utiles.StringLongitudFija('', 17));
  {if (percep1 <> 0) then Begin
    Write(archivo, utiles.sExprFecha2000(fecha));  // Fecha pago retencion
    WriteLn(archivo, utiles.StringLongitudFija(utiles.FormatearNumero(FloatToStr(percep1)), 15));
  end else Begin}
    WriteLn(archivo, '00000000000000000000000');
  //End;

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

procedure TTIvaventa.FinalizarExportacionCITI;
// Objetivo...: Finalizar Exportacion al CITI
begin
  closeFile(archivo);
  closeFile(alicuotas);
end;

procedure TTIvaventa.ListarExportacionCITI(xdesde, xhasta: String; salida: char);
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
    getDatos(citi.FieldByName('idc').AsString, citi.FieldByName('tipo').AsString, citi.FieldByName('sucursal').AsString, citi.FieldByName('numero').AsString);
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
  if not datosdb.verificarSiExisteCampo(tiva, 'bienuso') then Begin
    tiva.Close;
    datosdb.tranSQL(tiva.DatabaseName, 'alter table ' + tiva.TableName + ' add bienuso char(1)');
    tiva.Open;
  end;
  if not datosdb.verificarSiExisteCampo('ivaventa', 'idmov', path) then Begin
    tiva.Close;
    datosdb.tranSQL(tiva.DatabaseName, 'alter table ' + tiva.TableName + ' add idmov char(3)');
    datosdb.tranSQL(tiva.DatabaseName, 'update ' + tiva.TableName + ' set idmov = ' + '''' + 'V00' + '''');
    tiva.Open;
  end;
  if not datosdb.verificarSiExisteIndice('ivaventa', 'ivaventa_idmov', path) then Begin
    tiva.Close;
    datosdb.tranSQL(tiva.DatabaseName, 'create index ivav_idmov on ' + tiva.TableName + '(idmov, fecha)');
    tiva.Open;
  end;
  tiva.Close;
end;

procedure TTIvaventa.Exportar(xvia, xdfecha, xhfecha, xmodo: String);
// Objetivo...: Exportar Datos I.V.A.
var
  exp_iva: TTable;
  nvia: String;
Begin
  nvia := Copy(xvia, 1, Length(xvia) - 4);
  utilesarchivos.CopiarArchivos(dbs.DirSistema + '\estructu', 'ivaventa.*', dbs.DirSistema + '\_exportar\iva');
  utilesarchivos.CopiarArchivos(dbs.DirSistema + '\estructu', 'netdisve.*', dbs.DirSistema + '\_exportar\iva');
  tiva := datosdb.openDB('ivaventa', 'Idcompr;Tipo;Sucursal;Numero', '', nvia);
  iiva := datosdb.openDB('netdisve', 'Idcompr;Tipo;Sucursal;Numero;Cuit;Codmov;CodItems', '', nvia);
  if tiva.Active then datosdb.closeDB(tiva);
  if iiva.Active then datosdb.closeDB(iiva);
  tiva    := datosdb.openDB('ivaventa', '', '', nvia);
  iiva    := datosdb.openDB('netdisve', '', '', nvia);
  exp_iva := datosdb.openDB('ivaventa', '', '', dbs.DirSistema + '\_exportar\iva');
  eiva    := datosdb.openDB('netdisve', '', '', dbs.DirSistema + '\_exportar\iva');
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
    exp_iva.FieldByName('cdfiscal').AsFloat   := tiva.FieldByName('cdfiscal').AsFloat;
    exp_iva.FieldByName('tipomov').AsString   := tiva.FieldByName('tipomov').AsString;
    exp_iva.FieldByName('control').AsString   := tiva.FieldByName('control').AsString;
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

procedure TTIvaventa.ExportarIVAExcel(xvia, xdfecha, xhfecha, xtipo_fecha, xcont: String);
// Objetivo...: Exportar Datos I.V.A.
var
  i: Integer;
  e: Boolean;
  d, f: String;
Begin
  i := 0;
  tiva.IndexFieldNames := 'Fecha';

  excel.setString('A1', 'A1', 'Contribuyente: ' + xcont, 'Arial, negrita, 10');
  excel.setString('A2', 'A2', 'Libro I.V.A. Ventas', 'Arial, negrita, 14');

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
  excel.setString('U3', 'U3', 'Control', 'Arial, normal, 9');
  excel.setString('V3', 'V3', 'Bienuso', 'Arial, normal, 9');
  excel.setString('W3', 'W3', 'Id.Mov', 'Arial, normal, 9');
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
      excel.Alinear('A' + f, 'J' + f, 'D');
      excel.setString('A' + f, 'J' + f, '''' + utiles.FechaCompleta(utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString)), 'Arial, normal, 9');
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
      excel.setString('U' + f, 'U' + f, tiva.FieldByName('control').AsString, 'Arial, normal, 9');
      excel.setString('V' + f, 'V' + f, tiva.FieldByName('bienuso').AsString, 'Arial, normal, 9');
      excel.setString('W' + f, 'W' + f, tiva.FieldByName('idmov').AsString, 'Arial, normal, 9');
    end;
    tiva.Next;
  end;
  tiva.Close;

  excel.setString('E2', 'E2', '', 'Arial, normal, 9');

  excel.Visulizar;
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
           t1.FieldByName('cdfiscal').AsFloat, t1.FieldByName('totoper').AsFloat, t1.FieldByName('control').AsString, t1.FieldByName('bienuso').AsString, t1.FieldByName('idmov').AsString);
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
// Objetivo...: salto de p�gina archivos impresion en modo texto
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
