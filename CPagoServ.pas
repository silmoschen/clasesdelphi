unit CPagoServ;

interface

uses CSocAdherente, SysUtils, DB, DBTables, CBDT, CIDBFM, CListar, CUtiles;

type

TTPagoServicios = class(TObject)            // Superclase
  items, codsocio, fecha, concepto, codoper, pdfecha, phfecha: string;
  coditems, categoria, descrip, sel: string;
  importe: real;
  tserv, tabla: TTable; r, s: TQuery;
 public
  { Declaraciones Públicas }
  constructor Create(xitems, xcodsocio, xfecha, xconcepto, xcodoper, xpdfecha, xphfecha: string; ximporte: real);
  destructor  Destroy; override;

  function    getConcepto(xitreg: string): string;

  function    Buscar(xitems: string): boolean;
  procedure   Grabar(xitems, xcodsocio, xfecha, xconcepto, xcodoper, xpdfecha, xphfecha, xtiposerv: string; ximporte: real);
  procedure   Borrar(xitems: string); overload;
  procedure   Borrar(xcodoper, xdf, xhf: string); overload;
  procedure   BorrarPorSocio(xcodsocio, xdf, xhf: string);
  procedure   getDatos(xitems: string);
  function    NuevoItems: string;
  procedure   Listar(f1, f2: string; salida, saltopag: char);
  procedure   ListarPorServicio(f1, f2: string; salida, saltopag: char);
  procedure   ListarServiciosAcumulados(f1, f2: string; salida: char);
  function    AuditoriaServicios(xfecha: string): TQuery;
  procedure   Depurar(xfecha: string);
  function    getServiciosPagos: TQuery; overload;
  function    getServiciosPagos(xdf, xhf: string): TQuery; overload;
  function    getServiciosPagos1: TQuery;
  function    setServiciosFijos(xcodoper, xdf, xhf: string): TQuery;
  procedure   FiltrarPorSocio(xcodsocio: string);
  procedure   FiltrarPorServicio(xcodser: string);
  function    ItemsSocio(xcodsocio, xdf, xhf: string): TQuery;
  procedure   QuitarFiltro;

  procedure   GrabarItems(xcoditems, xcategoria, xdescrip: string; ximporte: real);
  procedure   BorrarItems(xcoditems: string);
  function    BuscarItems(xcoditems: string): boolean;
  function    Nuevo: string;
  procedure   getDatosItems(xcoditems: string);
  procedure   ListarItems(orden, iniciar, finalizar, ent_excl: string; salida: char);
  function    setItemsReg: TQuery;
  procedure   renumerarItems;

  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorDescrip(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  ting: real; i: integer; idanter: string;
  conexiones: shortint;
  procedure   IniciarListado(salida: char);
  procedure   ListLinea(salida, saltopag: char);
  procedure   ListLinea1(salida, saltopag: char);
  procedure   Subtotal(salida: char);
  procedure   SubtotalServicio(salida: char);
  procedure   SubtotalServ(salida: char);
  procedure   Titulo(salida: char; t: string);
  function    totservicioSocio(xcodsocio, xf1, xf2: string): real;
  procedure   ListLineaItems(salida: char);
end;

function pagoserv: TTPagoServicios;

implementation

var
  xpagoserv: TTPagoServicios = nil;

constructor TTPagoServicios.Create(xitems, xcodsocio, xfecha, xconcepto, xcodoper, xpdfecha, xphfecha: string; ximporte: real);
begin
  inherited Create;
  items    := xitems;
  codsocio := xcodsocio;
  fecha    := xfecha;
  concepto := xconcepto;
  codoper  := xcodoper;
  pdfecha  := xpdfecha;
  phfecha  := xphfecha;
  importe  := ximporte;

  tserv := datosdb.openDB('servicios', 'Items');
  tabla := datosdb.openDB('itregis', 'coditems');
end;

destructor TTPagoServicios.Destroy;
begin
  inherited Destroy;
end;

function TTPagoServicios.getConcepto(xitreg: string): string;
begin
  getDatosItems(xitreg);
  Result := Descrip;
end;

procedure TTPagoServicios.Grabar(xitems, xcodsocio, xfecha, xconcepto, xcodoper, xpdfecha, xphfecha, xtiposerv: string; ximporte: real);
// Objetivo...: Guardar atributos del objeto en tserv de Persistencia
begin
  if Buscar(xitems) then tserv.Edit else tserv.Append;
  tserv.FieldByName('items').AsString    := xitems;
  tserv.FieldByName('codsocio').AsString := xcodsocio;
  tserv.FieldByName('fecha').AsString    := utiles.sExprFecha(xfecha);
  tserv.FieldByName('concepto').AsString := xconcepto;
  tserv.FieldByName('codoper').AsString  := xcodoper;
  tserv.FieldByName('pdfecha').AsString  := utiles.sExprFecha(xpdfecha);
  tserv.FieldByName('phfecha').AsString  := utiles.sExprFecha(xphfecha);
  tserv.FieldByName('importe').AsFloat   := ximporte;
  tserv.FieldByName('tiposerv').AsString := xtiposerv;
  try
    tserv.Post;
  except
    tserv.Cancel;
  end;
end;

procedure TTPagoServicios.Depurar(xfecha: string);
// Objetivo...: Depurar Información cuotas registradas
begin
  datosdb.tranSQL('DELETE FROM ' + tserv.TableName + ' WHERE fecha < ' + '''' + utiles.sExprFecha(xfecha) + '''');
  conectar;
  renumerarItems;
  desconectar;
end;

procedure TTPagoServicios.Borrar(xitems: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xitems) then
    begin
      tserv.Delete;
      renumerarItems;
      getDatos(xitems);
    end;
end;

procedure TTPagoServicios.Borrar(xcodoper, xdf, xhf: string);
// Objetivo...: Borrar Items para una operacion y lapso asociado
begin
  datosdb.tranSQL('DELETE FROM servicios WHERE codoper = ' + '''' + xcodoper + '''' + ' AND fecha >= ' + '''' + utiles.sExprFecha(xdf) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(xhf) + '''' + ' AND tiposerv = ' + '''' + 'A' + '''');
  renumerarItems;
end;

procedure TTPagoServicios.BorrarPorSocio(xcodsocio, xdf, xhf: string);
// Objetivo...: Borrar Items para un socio y lapso asociado
begin
  datosdb.tranSQL('DELETE FROM servicios WHERE codsocio = ' + '''' + xcodsocio + '''' + ' AND fecha >= ' + '''' + utiles.sExprFecha(xdf) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(xhf) + '''' + ' AND tiposerv = ' + '''' + 'A' + '''');
  renumerarItems;
end;

function TTPagoServicios.Buscar(xitems: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tserv.FindKey([xitems]) then Result := True else Result := False;
end;

procedure  TTPagoServicios.getDatos(xitems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xitems) then
    begin
      items     := tserv.FieldByName('items').AsString;
      codsocio  := tserv.FieldByName('codsocio').AsString;
      fecha     := utiles.sFormatoFecha(tserv.FieldByName('fecha').AsString);
      concepto  := tserv.FieldByName('concepto').AsString;
      codoper   := tserv.FieldByName('codoper').AsString;
      pdfecha   := utiles.sFormatoFecha(tserv.FieldByName('pdfecha').AsString);
      phfecha   := utiles.sFormatoFecha(tserv.FieldByName('phfecha').AsString);
      importe   := tserv.FieldByName('importe').AsFloat;
    end
   else
    begin
      items := ''; codsocio := ''; fecha := ''; concepto := ''; importe := 0; codoper := ''; pdfecha := ''; phfecha := '';
    end;
end;

function TTPagoServicios.getServiciosPagos: TQuery;
// Objetivo...: Devolver un Set con los Servicios Pagos
begin
  Result := datosdb.tranSQL('SELECT servicios.codsocio, socioh1.categoria, socioh1.OSFA, servicios.fecha, servicios.pdfecha, servicios.phfecha, servicios.importe, servicios.codoper, servicios.concepto, itregis.categoria AS cat ' +
                            ' FROM servicios, socioh1, itregis WHERE servicios.codsocio = socioh1.codsocio AND servicios.codoper = itregis.coditems ORDER BY categoria, cat, OSFA, fecha');
end;

function TTPagoServicios.getServiciosPagos(xdf, xhf: string): TQuery;
// Objetivo...: Devolver un Set con los Servicios Pagos
begin
  Result := datosdb.tranSQL('SELECT servicios.items, servicios.codsocio, servicios.fecha, servicios.pdfecha, servicios.phfecha, servicios.importe, servicios.codoper, servicios.concepto FROM servicios ' +
                            ' WHERE fecha >= ' + '''' + utiles.sExprFecha(xdf) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(xhf) + '''' + ' ORDER BY codsocio, fecha');
end;

function TTPagoServicios.getServiciosPagos1: TQuery;
// Objetivo...: Devolver un Set con los Servicios Pagos Ordenados por Tipo de Servicio
begin
  Result := datosdb.tranSQL('SELECT servicios.codsocio, servicios.fecha, servicios.pdfecha, servicios.phfecha, servicios.importe, servicios.codoper, servicios.concepto, socioh1.categoria, socioh1.OSFA FROM servicios, socioh1 ' +
                            ' WHERE servicios.codsocio = socioh1.codsocio ORDER BY codoper, categoria, OSFA, fecha');
end;

function  TTPagoServicios.setServiciosFijos(xcodoper, xdf, xhf: string): TQuery;
// Objetivo...: Devolver un set con los items registrados en un rango - de manera automática
begin
  Result := datosdb.tranSQL('SELECT servicios.items, servicios.codsocio, servicios.fecha, servicios.pdfecha, servicios.phfecha, servicios.importe, servicios.codoper, servicios.concepto FROM servicios ' +
                            ' WHERE fecha >= ' + '''' + utiles.sExprFecha(xdf) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(xhf) + '''' + ' AND codoper = ' + '''' + xcodoper + '''' + ' AND tiposerv = ' + '''' + 'A' + '''' +
                            ' ORDER BY codsocio, fecha');
end;

function  TTPagoServicios.ItemsSocio(xcodsocio, xdf, xhf: string): TQuery;
// Objetivo...: devolver un set para un socio en el período indicado
begin
  Result := datosdb.tranSQL('SELECT servicios.* FROM servicios WHERE codsocio = ' + '''' + xcodsocio + '''' + ' AND fecha >= ' + '''' + utiles.sExprFecha(xdf) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(xhf) + '''' + ' AND tiposerv = ' + '''' + 'A' + '''');
end;

procedure TTPagoServicios.IniciarListado(salida: char);
// Objetivo...: Iniciar Informe
begin
 list.Setear(salida);     // Iniciar Listado
 list.altopag := 0; list.m := 0;
 list.FijarSaltoManual;
end;

procedure TTPagoServicios.Titulo(salida: char; t: string);
// Objetivo...: Titulo del informe
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Informe de Servicios Pagos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha       Lapso', 1, 'Arial, cursiva, 8');
  List.Titulo(25, list.lineactual, t, 2, 'Arial, cursiva, 8');
  List.Titulo(67, list.lineactual, 'Concepto', 3, 'Arial, cursiva, 8');
  List.Titulo(94, list.lineactual, 'Importe', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTPagoServicios.Listar(f1, f2: string; salida, saltopag: char);
// Objetivo...: Informe de Cuotas Pagas
begin
  IniciarListado(salida);
  titulo(salida, 'Tipo/Operación');

  r := getServiciosPagos;

  r.Open; r.First; ting := 0; idanter := '';
  while not r.EOF do
    begin
      if (r.FieldByName('fecha').AsString >= utiles.sExprFecha(f1)) and (r.FieldByName('fecha').AsString <= utiles.sExprFecha(f2)) then ListLinea(salida, saltopag);
      r.Next;
    end;

  SubtotalServicio(salida);
  if saltopag = 'S' then Begin
    list.CompletarPagina;
    list.PrintLn(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
  end;
  r.Close;

  List.FinList;
end;

procedure TTPagoServicios.ListLinea(salida, saltopag: char);
// Objetivo...: Emitir una Linea de detalle
begin
  socioadherente.getDatos(r.FieldByName('codsocio').AsString);
  if socioadherente.sel = 'X' then Begin  // Si el socio está seleccionado
    if list.SaltoPagina then // Controlamos el alto de la Página
      begin
        list.PrintLn(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
        list.IniciarNuevaPagina;
      end;
    if r.FieldByName('OSFA').AsString <> idanter then
      begin
        if ting <> 0 then SubtotalServicio(salida);
          if (saltopag = 'S') and (ting <> 0) then Begin
            list.CompletarPagina;
            list.PrintLn(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
            list.IniciarNuevaPagina;
            ting := 0;
          end;
      list.Linea(0, 0, 'Socio:  ' + socioadherente.descripcategoria + '  ' + socioadherente.OSFA + '  ' + socioadherente.Nombre, 1, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      idanter := r.FieldByName('OSFA').AsString;
    end;
    getDatosItems(r.FieldByName('codoper').AsString);
    list.Linea(0, 0, utiles.sFormatoFecha(r.FieldByName('fecha').AsString) + '  ' + utiles.sFormatoFecha(r.FieldByName('pdfecha').AsString) + ' - ' + utiles.sFormatoFecha(r.FieldByName('phfecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(25, list.Lineactual, r.FieldByName('codoper').AsString + '-' + Descrip, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(67, list.Lineactual, r.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'N');
    list.importe(99, list.lineactual, '', r.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8');
    list.Linea(99, list.Lineactual, ' ', 5, 'Arial, normal, 8', salida, 'S');
    ting := ting + r.FieldByName('importe').AsFloat;
  end;
end;

procedure TTPagoServicios.SubtotalServicio(salida: char);
// Objetivo...: Subtotal por servicio
begin
  list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(99, list.lineactual, '', '-------------------', 2, 'Arial, normal, 8');
  list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
  list.importe(99, list.lineactual, '', ting, 2, 'Arial, normal, 8');
  list.Linea(99, list.lineactual, '  ', 3, 'Arial, normal, 8', salida, 'S');
end;

procedure TTPagoServicios.ListarPorServicio(f1, f2: string; salida, saltopag: char);
// Objetivo...: Informe de Servicios discriminado por tipo de servicio
begin
  IniciarListado(salida);
  titulo(salida, 'Grado/OSFA/Socio');
  r := getServiciosPagos1;

  r.Open; r.First; ting := 0; idanter := '';
  while not r.EOF do
    begin
      if (r.FieldByName('fecha').AsString >= utiles.sExprFecha(f1)) and (r.FieldByName('fecha').AsString <= utiles.sExprFecha(f2)) then ListLinea1(salida, saltopag);
      r.Next;
    end;

  SubtotalServ(salida);
  if saltopag = 'S' then Begin
    list.CompletarPagina;
    list.PrintLn(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
  end;
  r.Close;

  List.FinList;
end;

procedure TTPagoServicios.ListLinea1(salida, saltopag: char);
// Objetivo...: Emitir una Linea de detalle
begin
 getDatosItems(r.FieldByName('codoper').AsString);
 if sel = 'X' then Begin // Listamos los items seleccionados
  if list.SaltoPagina then        // Controlamos el alto de la Página
    begin
      list.PrintLn(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
      list.IniciarNuevaPagina;
    end;
  if r.FieldByName('codoper').AsString <> idanter then
    begin
      if ting <> 0 then SubtotalServ(salida);
      if (saltopag = 'S') and (ting <> 0) then Begin
        list.CompletarPagina;
        list.PrintLn(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
        list.IniciarNuevaPagina;
        ting := 0;
      end;
    list.Linea(0, 0, 'Servicio:  ' + r.FieldByName('codoper').AsString + '  ' + getConcepto(r.FieldByName('codoper').AsString), 1, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    idanter := r.FieldByName('codoper').AsString;
  end;
  socioadherente.getDatos(r.FieldByName('codsocio').AsString);
  list.Linea(0, 0, utiles.sFormatoFecha(r.FieldByName('fecha').AsString) + '  ' + utiles.sFormatoFecha(r.FieldByName('pdfecha').AsString) + ' - ' + utiles.sFormatoFecha(r.FieldByName('phfecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(25, list.Lineactual, socioadherente.descripcategoria, 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(31, list.Lineactual, socioadherente.OSFA + '  ' + socioadherente.Nombre, 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(67, list.Lineactual, r.FieldByName('concepto').AsString, 4, 'Arial, normal, 8', salida, 'N');
  list.importe(99, list.lineactual, '', r.FieldByName('importe').AsFloat, 5, 'Arial, normal, 8');
  list.Linea(99, list.Lineactual, ' ', 6, 'Arial, normal, 8', salida, 'S');
  ting := ting + r.FieldByName('importe').AsFloat;
 end;
end;

procedure TTPagoServicios.SubtotalServ(salida: char);
// Objetivo...: Subtotales de servicio
begin
  list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(99, list.lineactual, '', '-------------------', 2, 'Arial, normal, 8');
  list.Linea(0, 0, '  ', 1, 'Arial, normal, 10', salida, 'S');
  list.importe(99, list.lineactual, '', ting, 2, 'Arial, normal, 8');
  list.Linea(99, list.lineactual, '  ', 3, 'Arial, normal, 8', salida, 'S');

  list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Recibi conforme la suma de   ' + utiles.FormatearNumero(FloatToStr(ting)) + ' pesos.', 1, 'Arial, cursiva, 9', salida, 'N');
  list.Linea(0, 0, '  ', 1, 'Arial, normal, 32', salida, 'S');
  list.Linea(0, 0, '-----------------------------------------------------------' + utiles.espacios(60) + '-----------------------------------------------------------', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, utiles.espacios(30) + 'Firma' + utiles.espacios(130) + 'Aclaración', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '  ', 12, 'Arial, normal, 16', salida, 'S');
end;

procedure TTPagoServicios.ListarServiciosAcumulados(f1, f2: string; salida: char);
// Objetivo...: Informe de Servicios discriminado por tipo de servicio
var
  totservicios: real;
begin
  //IniciarListado(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Informe de Servicios Pagos Disc. por Socios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, '  Grado', 1, 'Arial, cursiva, 10');
  List.Titulo(10, list.lineactual, 'O.S.F.A.', 2, 'Arial, cursiva, 10');
  List.Titulo(20, list.lineactual, 'Socio', 3, 'Arial, cursiva, 10');
  List.Titulo(60, list.lineactual, 'Importe', 4, 'Arial, cursiva, 10');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  r := socioadherente.setSocios;

  r.Open; r.First; ting := 0;
  while not r.EOF do
    begin
      totservicios := totservicioSocio(r.FieldByName('codsocio').AsString, f1, f2);
      ting         := ting + totservicios;
      if totservicios > 0 then
        begin
          socioadherente.getDatos(r.FieldByName('codsocio').AsString);
          list.Linea(0, 0, '   ' + socioadherente.descripcategoria, 1, 'Arial, normal, 10', salida, 'N');
          list.Linea(10, list.lineactual, socioadherente.OSFA, 2, 'Arial, normal, 10', salida, 'N');
          list.Linea(20, list.lineactual, socioadherente.Nombre, 3, 'Arial, normal, 10', salida, 'N');
          list.importe(65, list.lineactual, '', totservicios, 4, 'Arial, normal, 10');
          list.Linea(70, list.Lineactual, ' ', 5, 'Arial, normal, 10', salida, 'S');
        end;
      r.Next;
    end;

  Subtotal(salida);
  r.Close;

  List.FinList;
end;

procedure TTPagoServicios.Subtotal(salida: char);
// Objetivo...: Emitir una Linea de detalle
begin
  list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(65, list.lineactual, '', '-------------------', 2, 'Arial, normal, 10');
  list.Linea(0, 0, '  ', 1, 'Arial, normal, 10', salida, 'S');
  list.importe(65, list.lineactual, '', ting, 2, 'Arial, normal, 10');
  list.Linea(66, list.lineactual, '  ', 3, 'Arial, normal, 10', salida, 'S');
end;

function  TTPagoServicios.totservicioSocio(xcodsocio, xf1, xf2: string): real;
// Objetivo...: Obtener total de servicios por Socio
var
  tot: real;
begin
  tot := 0;
  tserv.First;
  while not tserv.EOF do
    begin
      if (tserv.FieldByName('codsocio').AsString = xcodsocio) and (tserv.FieldByName('fecha').AsString >= utiles.sExprFecha(xf1)) and (tserv.FieldByName('fecha').AsString <= utiles.sExprFecha(xf2)) then tot := tot + tserv.FieldByName('importe').AsFloat;
      tserv.Next;
    end;
  Result := tot;
end;

function TTPagoServicios.NuevoItems: string;
// Objetivo...: Generar un Nuevo Items
var
  f: boolean;
begin
  if tserv.Filtered then Begin
    f := True;
    tserv.Filtered := False;
   end
  else f := False;
  i := 0;
  tserv.Last;  // Extraemos el ultimo items
  if Length(Trim(tserv.FieldByName('items').AsString)) > 0 then i := tserv.FieldByName('items').AsInteger;
  Inc(i); Result := IntToStr(i);
  if f then tserv.Filtered := True;
end;

function TTPagoServicios.AuditoriaServicios(xfecha: string): TQuery;
// Objetivo...: devolver un set con los servicios pagados en un día
begin
  Result := datosdb.tranSQL('SELECT servicios.codsocio, servicios.fecha, servicios.pdfecha, servicios.phfecha, servicios.concepto, servicios.importe, socios.nombre FROM servicios, socios WHERE ' +
                            ' servicios.codsocio = socios.codsocio AND fecha = ' + '''' + xfecha + '''');
end;

procedure TTPagoServicios.renumerarItems;
// Objetivo...: Renumerar Items, para quitar espacios vacíos
var
  i: integer; f: boolean;
begin
  if tserv.Filtered then Begin
    f := True;
    tserv.Filtered := False;
   end
  else f := False;
  tserv.First; i := 0;
  while not tserv.EOF do
    begin
      Inc(i);
      tserv.Edit;
      tserv.FieldByName('items').AsString := utiles.sLlenarIzquierda(IntToStr(i), 8, '0');
      try
        tserv.Post;
      except
        tserv.Cancel;
      end;
      tserv.Next;
    end;
  if f then tserv.Filtered := True;
end;

procedure TTPagoServicios.FiltrarPorSocio(xcodsocio: string);
// Objetivo...: Abrir tservs de persistencia
begin
  datosdb.Filtrar(tserv, 'codsocio = ' + '''' + xcodsocio + '''');
end;

procedure TTPagoServicios.FiltrarPorServicio(xcodser: string);
// Objetivo...: Abrir tservs de persistencia
begin
  datosdb.Filtrar(tserv, 'codoper = ' + '''' + xcodser + '''');
end;

procedure TTPagoServicios.QuitarFiltro;
// Objetivo...: Abrir tservs de persistencia
begin
  tserv.Filtered := False;
end;

procedure TTPagoServicios.GrabarItems(xcoditems, xcategoria, xdescrip: string; ximporte: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if BuscarItems(xcoditems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('coditems').AsString  := xcoditems;
  tabla.FieldByName('categoria').AsString := xcategoria;
  tabla.FieldByName('descrip').AsString   := xdescrip;
  tabla.FieldByName('importe').AsFloat    := ximporte;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTPagoServicios.BorrarItems(xcoditems: string);
// Objetivo...: Eliminar un Objeto
begin
  if BuscarItems(xcoditems) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('coditems').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTPagoServicios.BuscarItems(xcoditems: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'Coditems' then tabla.IndexFieldNames := 'Coditems';
  if tabla.FindKey([xcoditems]) then Result := True else Result := False;
end;

procedure  TTPagoServicios.getDatosItems(xcoditems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if BuscarItems(xcoditems) then
    begin
      coditems  := tabla.FieldByName('coditems').AsString;
      categoria := tabla.FieldByName('categoria').AsString;
      descrip   := tabla.FieldByName('descrip').AsString;
      importe   := tabla.FieldByName('importe').AsFloat;
      sel       := tabla.FieldByName('sel').AsString;
    end
   else
    begin
      coditems := ''; descrip := ''; importe := 0; sel := ''; categoria := '';
    end;
end;

function TTPagoServicios.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  tabla.Last;
  if tabla.RecordCount > 0 then Result := IntToStr(tabla.FieldByName('coditems').AsInteger + 1) else Result := '1';
end;

procedure TTPagoServicios.ListarItems(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Items Registrables Imput. de Servicios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(3) +  'Descripción', 1, 'Courier New, cursiva, 9');
  List.Titulo(81, list.Lineactual, 'Imp.Pred.', 2, 'Courier New, cursiva, 9');
  List.Titulo(97, list.Lineactual, 'Categoría', 3, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('coditems').AsString >= iniciar) and (tabla.FieldByName('coditems').AsString <= finalizar) then ListLineaItems(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('codprovin').AsString < iniciar) or (tabla.FieldByName('coditems').AsString > finalizar) then ListLineaItems(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString >= iniciar) and (tabla.FieldByName('descrip').AsString <= finalizar) then ListLineaItems(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString < iniciar) or (tabla.FieldByName('descrip').AsString > finalizar) then ListLineaItems(salida);

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTPagoServicios.ListLineaItems(salida: char);
// Objetivo...: Linea de detalle
begin
  List.Linea(0, 0, tabla.FieldByName('coditems').AsString + '    ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'N');
  List.importe(90, list.lineactual, '', tabla.FieldByName('importe').AsFloat, 2, 'Cuorier New, normal, 9');
  List.Linea(97, list.lineactual, tabla.FieldByName('categoria').AsString, 3, 'Courier New, normal, 9', salida, 'S');
end;

function TTPagoServicios.setItemsReg: TQuery;
// Objetivo...: Devolver un set de registro con los items
begin
  Result := datosdb.tranSQL('SELECT * FROM itregis');
end;

procedure TTPagoServicios.BuscarPorCodigo(xexpr: string);
begin
  if tabla.IndexName <> 'Descrip' then tabla.IndexName := 'Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTPagoServicios.BuscarPorDescrip(xexpr: string);
begin
  if tabla.IndexFieldNames <> 'Coditems' then tabla.IndexFieldNames := 'Coditems';
  tabla.FindNearest([xexpr]);
end;

procedure TTPagoServicios.conectar;
// Objetivo...: Abrir tservs de persistencia
begin
  if conexiones = 0 then Begin
    if not tserv.Active then tserv.Open;
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('coditems').DisplayLabel := 'Cód.'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción'; tabla.FieldByName('sel').Visible := False;
    tserv.FieldByName('codsocio').Visible := False; tserv.FieldByName('fecha').Visible := False; tserv.FieldByName('pdfecha').Visible := False; tserv.FieldByName('phfecha').Visible := False;
    socioadherente.conectar;
  end;
  Inc(conexiones);
end;

procedure TTPagoServicios.desconectar;
// Objetivo...: cerrar tservs de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tserv);
    datosdb.closeDB(tabla);
    socioadherente.desconectar;
  end;
end;

{===============================================================================}

function pagoserv: TTPagoServicios;
begin
  if xpagoserv = nil then
    xpagoserv := TTPagoServicios.Create('', '', '', '', '', '', '', 0);
  Result := xpagoserv;
end;

{===============================================================================}

initialization

finalization
  xpagoserv.Free;

end.
