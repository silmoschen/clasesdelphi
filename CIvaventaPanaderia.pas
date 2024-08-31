unit CIvaventaPanaderia;

interface

uses CIvaVenta, CTablaIva, Cliengar, CCliente, CCNetos, SysUtils, DB, DBTables, CBDT, CUtiles, CListar, Listado, CEmpresas, CIDBFM;

type

TTivaventaPanaderia = class(TTIvaVenta)
 public
  { Declaraciones Públicas }
  iva1, iva2: Real;
  alicuota: TTable;
  constructor Create;
  destructor  Destroy; override;
  procedure   Titulo(tipolistado: char; mes: string); override;

  procedure   RegistrarNetos(xidcompr, xtipo, xsucursal, xnumero, xcuit, xcodmov, xcoditems, xfecha, xitems: string; xNettot, xIvari, xIvarec, xiva1, xiva2: real);
  procedure   ListarLibroIVA_Ventas(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro: string);
  function    BuscarAlicuota(xidc, xtipo, xsucursal, xnumero: String): Boolean;
  procedure   RegistrarAlicuota(xidc, xtipo, xsucursal, xnumero: String; xiva1, xiva2: Real);
  procedure   getDatosAlicuota(xidc, xtipo, xsucursal, xnumero: String);
  procedure   BorrarAlicuota(xidc, xtipo, xsucursal, xnumero: String);

  procedure   conectar;
  procedure   desconectar;
 protected
  { Declaraciones Protegidas }
  conexiones, tc: shortint;
  l1, l2: string;
  tiva1, tiva2: Real;
  procedure   LineaIva(salida: char); override;
  procedure   Transporte(leyenda: string; salida: char); override;
  procedure   TitulosTxt; override;
end;

function ivav: TTivaventaPanaderia;

implementation

var
  xivav: TTivaventaPanaderia = nil;

constructor TTivaventaPanaderia.Create;
begin
  inherited Create;
  alicuota := datosdb.openDB('ivadiferencial', '');
end;

destructor TTivaventaPanaderia.Destroy;
begin
  inherited Destroy;
end;

procedure TTivaventaPanaderia.RegistrarNetos(xidcompr, xtipo, xsucursal, xnumero, xcuit, xcodmov, xcoditems, xfecha, xitems: string; xNettot, xIvari, xIvarec, xiva1, xiva2: real);
// Objetivo...: Grabar una Línea de detalle para un movimiento de IVA
var
  t: string;
begin
  t := iiva.TableName;
  if (xcoditems = '001') and (iva_existe) then BorrarItems(xidcompr, xtipo, xsucursal, xnumero, xcuit);
  if BuscarItems(xidcompr, xtipo, xsucursal, xnumero, xcuit, xcodmov, xcoditems) then iiva.Edit else iiva.Append;
  iiva.FieldByName('idcompr').AsString  := xidcompr;
  iiva.FieldByName('tipo').AsString     := xtipo;
  iiva.FieldByName('sucursal').AsString := xsucursal;
  iiva.FieldByName('numero').AsString   := xnumero;
  iiva.FieldByName('cuit').AsString     := xcuit;
  iiva.FieldByName('codmov').AsString   := xcodmov;
  iiva.FieldByName('coditems').AsString := xcoditems;
  iiva.FieldByName('items').AsString    := xitems;
  iiva.FieldByName('fecha').AsString    := utiles.sExprFecha(xfecha);
  iiva.FieldByName('nettot').AsFloat    := xnettot;
  iiva.FieldByName('iva').AsFloat       := xIvari;
  iiva.FieldByName('ivarec').AsFloat    := xIvarec;
  iiva.FieldByName('iva1').AsFloat      := xIva1;
  iiva.FieldByName('iva2').AsFloat      := xIva2;
  try
    iiva.Post;
   except
    iiva.Cancel;
  end;
end;

// ------- Gestión de Informes -------------

procedure TTivaventaPanaderia.Titulo(tipolistado: char; mes: string);
{Objetivo....: Emitir los Títulos del Listado}
begin
  l1 := 'Débito'; l2 := 'Res. Varias';
  empresa.getDatos('0000');
  if (tipolistado = 'P') or (tipolistado = 'I') then Begin
    Inc(pag);
    //ListDatosEmpresa(tipolistado);
    list.Titulo(0, 0, 'Libro I.V.A. Ventas      -     ' + meses[StrToInt(Copy(mes, 1, 2))] + '  de  ' + Copy(mes, 4, 4), 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, utiles.espacios(394) + 'Hoja Nº: #pagina', 1, 'Times New Roman, ninguno, 8');
    list.Titulo(0, 0, list.linealargopagina(tipolistado), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ',1 , 'Arial, normal, 4');
    // 1º Línea de Títulos
    list.Titulo(0, 0, 'Fecha',1 , 'Arial, cursiva, 8');
    list.Titulo(12, list.lineactual, 'Comprobante' + utiles.espacios(18) + 'Cliente',2 , 'Arial, cursiva, 8');
    list.Titulo(63, list.lineactual, 'C.U.I.T. Nº' + utiles.espacios(6) + 'IVA',3 , 'Arial, cursiva, 8');
    list.Titulo(87, list.lineactual, ' Neto',4 , 'Arial, cursiva, 8');
    list.Titulo(92, list.lineactual, 'Operaciones',5 , 'Arial, cursiva, 8');
    list.Titulo(102, list.lineactual, 'Conceptos',6 , 'Arial, cursiva, 8');
    list.Titulo(114, list.lineactual, 'I.V.A.',7 , 'Arial, cursiva, 8');
    list.Titulo(123, list.lineactual, 'I.V.A.',8 , 'Arial, cursiva, 8');
    list.Titulo(132, list.lineactual, 'Percep.', 9, 'Arial, cursiva, 8');
    list.Titulo(140, list.lineactual, 'Retenc.', 10, 'Arial, cursiva, 8');
    list.Titulo(150, list.lineactual, 'Total',11 , 'Arial, cursiva, 8');
    list.Titulo(156, list.lineactual, l1,12 , 'Arial, cursiva, 8');
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

    list.Titulo(0, 0, list.linealargopagina(tipolistado), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, '  ', 1, 'Arial, negrita, 8');

    if totTotOper > 0 then Begin
      Transporte(utiles.espacios(20) + 'Transporte ....: ', tipolist);
      list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    end;
  end else Begin
    SaltoManual := True;
    titulosTxt;
  end;
  list.tipolist := tipolistado;
end;

procedure TTivaventaPanaderia.TitulosTxt;
// Objetivo...: Gestionar titulos para listado de archivos de texto
var
  i: integer;
begin
  Inc(pag);
  list.LineaTxt(CHR(18), true);
  For i := 1 to empresa.margenes do list.LineaTxt('  ', true);
  list.LineaTxt(empresa.Nombre, true);
  if empresa.Rsocial2 <> '' then Begin
    list.LineaTxt(empresa.Rsocial2, true);
    Inc(lineasimpresas);
  end;
  list.LineaTxt(empresa.Nrocuit, true);
  list.LineaTxt(empresa.Domicilio, true);
  list.LineaTxt('  ', true);
  list.LineaTxt('Libro I.V.A. Ventas  -  ' + meses[StrToInt(Copy(xmes, 1, 2))] + '  de  ' + Copy(xmes, 4, 4), true);
  list.LineaTxt(utiles.espacios(65) + 'Hoja Nro.: ' + utiles.sLlenarIzquierda((FloatToStr(pag)), 4, '0'), true);
  list.LineaTxt(CHR(15), true);
  list.LineaTxt(utiles.sLLenarIzquierda(lin, 137, CHR(196)), true);
  list.LineaTxt('  ', true);
  list.LineaTxt('Fecha    Comprobante     Cliente                         C.U.I.T.     IVA      Neto Conceptos    Oper.   I.V.A.  I.V.A.    Total   Debito', true);
  list.LineaTxt('                                                                                     No Grav.  Exentas   Normal Recargo Operacion Re.Var.', true);
  list.LineaTxt(utiles.sLLenarIzquierda(lin, 137, CHR(196)), true);
  lineasimpresas := 13 + empresa.margenes;
end;

procedure TTivaventaPanaderia.Transporte(leyenda: string; salida: char);
{Objetivo...: Transporte del Asiento Contable}
var
  i: integer;
begin
  if (salida = 'P') or (salida = 'I') then Begin
   if Trim(leyenda) = 'Subtotales:' then Begin
     list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
     list.Linea(0, 0, 'Total I.V.A. Alicuota Normal: ', 1, 'Arial, negrita, 8', salida, 'N');
     list.importe(50, list.lineactual, '', tiva1, 2, 'Arial, negrita, 8');
     list.Linea(60, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
     list.Linea(0, 0, 'Total I.V.A. Alicuota Diferencial: ', 1, 'Arial, negrita, 8', salida, 'N');
     list.importe(50, list.lineactual, '', tiva2, 2, 'Arial, negrita, 8');
     list.Linea(60, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
   end;

   if Trim(leyenda) = 'Subtotales:' then Begin
     if not infresumido then Begin
       list.CompletarPagina;     // Rellenamos la Página
       list.PrintLn(0, 0, list.linealargopagina(tipolist), 1, 'Arial, normal, 11');
     end;
   end;
   list.Linea(0, 0, leyenda, 1, 'Arial, negrita, 8', salida, 'N');
   list.importe(91, list.lineactual,  '', totNettot, 2, 'Arial, negrita, 8');
   list.importe(100, list.lineactual, '', totOpexenta, 3, 'Arial, negrita, 8');
   list.importe(109, list.lineactual, '', totConnograv, 4, 'Arial, negrita, 8');
   list.importe(118, list.lineactual, '', totIva, 5, 'Arial, negrita, 8');
   list.importe(127, list.lineactual, '', totIvarec, 6, 'Arial, negrita, 8');
   list.importe(136, list.lineactual, '', totPercepcion, 7, 'Arial, negrita, 8');
   list.importe(143, list.lineactual, '', totPergan, 8, 'Arial, negrita, 8');
   list.importe(152, list.lineactual, '', totTotoper, 9, 'Arial, negrita, 8');
   list.importe(163, list.lineactual, '', totCdfiscal, 10, 'Arial, negrita, 8');
  end;
  if salida = 'T' then Begin
   if Trim(leyenda) = 'Subtotales:' then Begin
     list.LineaTxt(utiles.StringLongitudFija('Total I.V.A. Alicuota Normal: ', 50), False);
     list.ImporteTxt(tiva1, 9, 2, True);
     Inc(lineasimpresas); SaltoTxt(salida);
     list.LineaTxt(utiles.StringLongitudFija('Total I.V.A. Alicuota Diferencial: ', 50), False);
     list.ImporteTxt(tiva2, 9, 2, True);
     Inc(lineasimpresas); SaltoTxt(salida);
   end;
   if Trim(leyenda) = 'Subtotales:' then  // completamos
     For i := lineasimpresas to (empresa.lineas - 2) do list.LineaTxt(' ', True);
   list.LineaTxt(utiles.sLLenarIzquierda(lin, 137, CHR(196)), True);
   nombre := leyenda + utiles.espacios(50 - Length(Trim(leyenda)));
   list.LineaTxt(nombre, False);
   list.ImporteTxt(totNettot, 9, 2, False);
   list.ImporteTxt(totConnograv, 9, 2, False);
   list.ImporteTxt(totOpexenta, 9, 2, False);
   list.ImporteTxt(totIva, 9, 2, False);
   list.ImporteTxt(totIvarec, 9, 2, False);
   list.ImporteTxt(totTotOper, 9, 2, False);
   list.ImporteTxt(totCDFiscal, 9, 2, True);
  end;
end;

procedure TTivaventaPanaderia.LineaIva(salida: char);
// Objetivo...: Imprimir una Línea de Detalle
begin
  if (salida = 'P') or (salida = 'I') then Begin
   if not infresumido then Begin
    if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> 'N' then Begin
      list.Linea(0, 0, utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(9, list.lineactual, tiva.FieldByName('idcompr').AsString , 2, 'Arial, normal, 8', salida, 'N');
      if tiva.FieldByName('tipomov').AsString <> 'X' then list.Linea(12, list.lineactual, tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + '  ' + tiva.FieldByName('rsocial').AsString, 3, 'Arial, normal, 8', salida, 'N') else
        list.Linea(12, list.lineactual, tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + '  ' + 'A N U L A D A' , 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(62, list.lineactual, tiva.FieldByName('cuit').AsString, 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(73, list.lineactual, tiva.FieldByName('codiva').AsString, 5, 'Arial, normal, 8', salida, 'N');
    end else Begin
      list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(9, list.lineactual, ' ', 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(12, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(62, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(73, list.lineactual, ' ', 5, 'Arial, normal, 8', salida, 'N');
    end;

    list.importe(91,  list.lineactual, '', tiva.FieldByName('Nettot').AsFloat, 6, 'Arial, normal, 8');
    list.importe(100, list.lineactual, '', tiva.FieldByName('Opexenta').AsFloat, 7, 'Arial, normal, 8');
    list.importe(109, list.lineactual, '', tiva.FieldByName('Connograv').AsFloat, 8, 'Arial, normal, 8');
    list.importe(118, list.lineactual, '', tiva.FieldByName('Iva').AsFloat, 9, 'Arial, normal, 8');
    list.importe(127, list.lineactual, '', tiva.FieldByName('Ivarec').AsFloat, 10, 'Arial, normal, 8');
    list.importe(136, list.lineactual, '', tiva.FieldByName('Percep2').AsFloat, 11, 'Arial, normal, 8');
    list.importe(145, list.lineactual, '', tiva.FieldByName('Percep1').AsFloat, 12, 'Arial, normal, 8');
    list.importe(154, list.lineactual, '', tiva.FieldByName('Totoper').AsFloat, 13, 'Arial, normal, 8');
    list.importe(163, list.lineactual, '', tiva.FieldByName('Cdfiscal').AsFloat, 14, 'Arial, normal, 8');
    list.Linea(163, list.lineactual, ' ', 15, 'Arial, normal, 8', salida, 'S');
   end;
  end;
  if salida = 'T' then Begin
    if tiva.FieldByName('tipomov').AsString <> 'X' then nombre := tiva.FieldByName('rsocial').AsString + utiles.espacios(31 - Length(Trim(tiva.FieldByName('rsocial').AsString))) else nombre := 'A N U L A D A' + utiles.espacios(31 - Length(Trim('A N U L A D A')));
    if Copy(tiva.FieldByName('sucursal').AsString, 1, 1) <> 'N' then list.LineaTxt(utiles.sFormatoFecha(tiva.FieldByName('fecha').AsString) + ' ' + tiva.FieldByName('tipo').AsString + ' ' + tiva.FieldByName('sucursal').AsString + '-' + tiva.FieldByName('numero').AsString + ' ' + nombre + ' ' + tiva.FieldByName('cuit').AsString + ' ' + tiva.FieldByName('codiva').AsString + ' ', False) else
      list.LineaTxt('                                                                          ', False);

    list.ImporteTxt(tiva.FieldByName('Nettot').AsFloat, 9, 2, False);
    list.ImporteTxt(tiva.FieldByName('Connograv').AsFloat, 9, 2, False);
    list.ImporteTxt(tiva.FieldByName('Opexenta').AsFloat, 9, 2, False);
    list.ImporteTxt(tiva.FieldByName('Iva').AsFloat, 9, 2, False);
    list.ImporteTxt(tiva.FieldByName('Ivarec').AsFloat, 9, 2, False);
    list.ImporteTxt(tiva.FieldByName('Totoper').AsFloat, 9, 2, False);
    list.ImporteTxt(tiva.FieldByName('CDfiscal').AsFloat, 9, 2, True);
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

    getDatosAlicuota(tiva.FieldByName('idcompr').AsString, tiva.FieldByName('tipo').AsString, tiva.FieldByName('sucursal').AsString, tiva.FieldByName('numero').AsString);
    tiva1 := tiva1 + iva1;
    tiva2 := tiva2 + iva2;
  end;

  if salida <> 'T' then Begin
    if list.SaltoPagina then Begin
      list.PrintLn(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
      Transporte('Transporte ...:', salida);
      list.IniciarNuevaPagina;
      Transporte('Transporte ...:', salida);
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    end
  end else Begin
    // Salto para los archivos de texto
    {if lineasimpresas > (empresa.lineas - 3) then Begin
      Transporte('Transporte ...:', salida);
      list.LineaTxt(CHR(12), True);  // Salto
      TitulosTxt;
    end;}
    inherited SaltoTxt(salida);
  end;
end;

function  TTivaventaPanaderia.BuscarAlicuota(xidc, xtipo, xsucursal, xnumero: String): Boolean;
// Objetivo...: Buscar una Instancia
Begin
  Result := datosdb.Buscar(alicuota, 'idc', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero);
end;

procedure TTivaventaPanaderia.ListarLibroIVA_Ventas(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro: string);
// Objetivo...: Listar Libro I.V.A.
Begin
  tiva1 := 0; tiva2 := 0;
  inherited ListarLibroIVA_Ventas(salida, pag_inicial, mes, p1, p2, p3, t_filtro);
end;

procedure TTivaventaPanaderia.RegistrarAlicuota(xidc, xtipo, xsucursal, xnumero: String; xiva1, xiva2: Real);
// Objetivo...: Registrar una Instancia
Begin
  if BuscarAlicuota(xidc, xtipo, xsucursal, xnumero) then alicuota.Edit else alicuota.Append;
  alicuota.FieldByName('idc').AsString      := xidc;
  alicuota.FieldByName('tipo').AsString     := xtipo;
  alicuota.FieldByName('sucursal').AsString := xsucursal;
  alicuota.FieldByName('numero').AsString   := xnumero;
  alicuota.FieldByName('iva1').AsFloat      := xiva1;
  alicuota.FieldByName('iva2').AsFloat      := xiva2;
  try
    alicuota.Post
   except
    alicuota.Cancel
  end;
  datosdb.closeDB(alicuota); alicuota.Open;
end;

procedure TTivaventaPanaderia.getDatosAlicuota(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: recuperar una Instancia
Begin
  if BuscarAlicuota(xidc, xtipo, xsucursal, xnumero) then Begin
    iva1 := alicuota.FieldByName('iva1').AsFloat;
    iva2 := alicuota.FieldByName('iva2').AsFloat;
  end else Begin
    iva1 := 0; iva2 := 0;
  end;
end;

procedure TTivaventaPanaderia.BorrarAlicuota(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: Borrar una Instancia
Begin
  datosdb.tranSQL(alicuota.DatabaseName, 'delete from ' + alicuota.TableName + ' where idc = ' + '''' +  xidc + '''' + ' and tipo = ' + '''' +  xtipo + '''' + ' and sucursal = ' + '''' +  xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''');
  datosdb.closeDB(alicuota); alicuota.Open;
end;

procedure TTivaventaPanaderia.conectar;
Begin
  inherited conectar;
  if conexiones = 0 then Begin
    if not alicuota.Active then alicuota.Open;
  end;
  Inc(conexiones);
end;

procedure TTivaventaPanaderia.desconectar;
Begin
  inherited desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(alicuota);
  end;
end;


{===============================================================================}

function ivav: TTivaventaPanaderia;
begin
  if xivav = nil then
    xivav := TTivaventaPanaderia.Create;
  Result := xivav;
end;

{===============================================================================}

initialization

finalization
  xivav.Free;

end.
