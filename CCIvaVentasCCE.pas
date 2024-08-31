unit CCIvaVentasCCE;

interface

uses CCIvaCCE, CClienteCCE, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM,
     Listado, Classes, CCNetos;

type

TTIvaVenta = class(TTIVACCE)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xidc, xtipo, xsucursal, xnumero: String): Boolean;
  procedure   getDatos(xidc, xtipo, xsucursal, xnumero: String); overload;
  procedure   Borrar(xidc, xtipo, xsucursal, xnumero: String);

  procedure   ListarLibro(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro, xrenglones: string); overload;
  procedure   ListarLibro(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro, xrenglones: string; xlista: TStringList); overload;
  function    setNumeroDePagina: Integer;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  lim, lineas: Integer;
  FinalizarPagina, OmitirTransporte: Boolean;
  procedure   Titulo(salida: char; mes: string);
  procedure   Transporte(leyenda: string; salida: char);
  procedure   LineaIva(salida: char);
  procedure   IniciarInfSubtotales(salida: char; LineasSubtotales: Integer);
  procedure   ControlarSalto;
end;

function ivav: TTIvaVenta;

implementation

var
  xivav: TTIvaVenta = nil;

constructor TTIvaVenta.Create;
begin
  tabla := datosdb.openDB('ivaventas', '');
end;

destructor TTIvaVenta.Destroy;
begin
  inherited Destroy;
end;

function  TTIvaVenta.Buscar(xidc, xtipo, xsucursal, xnumero: String): Boolean;
// Objetivo...: Buscar una Instancia
begin
  if tabla.IndexFieldNames <> 'idc;tipo;sucursal;numero' then tabla.IndexFieldNames := 'idc;tipo;sucursal;numero';
  Result := datosdb.Buscar(tabla, 'idc', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero);
end;

procedure  TTIvaVenta.getDatos(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: Recuperar una Instancia
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero) then inherited CargarInstancia else inherited IniciarInstancia;
end;

procedure  TTIvaVenta.Borrar(xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: Borrar una Instancia
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero) then inherited Borrar(xidc, xtipo, xsucursal, xnumero, tabla.FieldByName('entidad').AsString);
end;

//------------------------------------------------------------------------------

procedure TTIvaVenta.Titulo(salida: char; mes: string);
{Objetivo....: Emitir los Títulos del Listado}
begin
  ListDatosEmpresa(salida);
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  list.Titulo(espacios, list.Lineactual, 'Libro I.V.A. Ventas     -     ' + meses[StrToInt(Copy(mes, 1, 2))] + '  de  ' + Copy(mes, 4, 4), 2, 'Arial, negrita, 14');
  //list.Titulo(95, list.Lineactual, 'Hoja Nº: #pagina', 2, 'Times New Roman, ninguno, 8');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 11'); list.Titulo(espacios, list.Lineactual, list.linealargopagina(tipolist), 2, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ',1 , 'Arial, normal, 4');
  // 1º Línea de Títulos
  list.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
  list.Titulo(espacios, list.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
  list.Titulo(17, list.lineactual, 'Comprobante' + utiles.espacios(18) + 'Razón Social Cliente', 3, 'Arial, cursiva, 8');
  list.Titulo(70, list.lineactual, 'C.U.I.T. Nº' + utiles.espacios(6) + 'CI', 4, 'Arial, cursiva, 8');
  // 2º Línea de Títulos
  list.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
  list.Titulo(espacios, list.Lineactual, 'Base Gravada', 2, 'Arial, cursiva, 8');
  list.Titulo(15, list.lineactual, 'Con. No Grav.', 3, 'Arial, cursiva, 8');
  list.Titulo(30, list.lineactual, 'Ope. Exentas', 4, 'Arial, cursiva, 8');
  list.Titulo(50, list.lineactual, '% IVA', 5, 'Arial, cursiva, 8');
  list.Titulo(61, list.lineactual, 'D.F. - IVA', 6, 'Arial, cursiva, 8');
  list.Titulo(79, list.lineactual, '% RNI', 7, 'Arial, cursiva, 8');
  list.Titulo(92, list.lineactual, 'Sobretasa', 8, 'Arial, cursiva, 8');
  list.Titulo(103, list.lineactual, 'Otros Impuestos', 9, 'Arial, cursiva, 8');
  list.Titulo(121, list.lineactual, 'Imp. Internos', 10, 'Arial, cursiva, 8');
  list.Titulo(136, list.lineactual, 'Percepción', 11, 'Arial, cursiva, 8');
  list.Titulo(149, list.lineactual, 'Total Facturado', 12, 'Arial, cursiva, 8');
  list.Titulo(165, list.lineactual, 'Retención IVA', 13, 'Arial, cursiva, 8');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 11'); list.Titulo(espacios, list.Lineactual, list.linealargopagina(tipolist), 2, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Times New Roman, ninguno, 5');
  list.tipolist := salida;

  if totTotOper > 0 then Begin
    Transporte(utiles.espacios(20) + 'Transporte ....: ', tipolist);
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  end;
end;

procedure TTIvaVenta.Transporte(leyenda: string; salida: char);
// Objetivo...: Transporte Libro I.V.A.
procedure CompletarPagina;
var
  i: Integer;
Begin
  For i := lineas to lim do Begin
    //list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
    //list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  end;
end;

begin
  if Trim(leyenda) = 'Subtotales:' then begin
    if not infresumido then Begin
      if lim = 0 then list.CompletarPagina else CompletarPagina;     // Rellenamos la Página
      ControlarSalto;
      list.PrintLn(0, 0, ' ', 1, 'Arial, normal, 11');
      list.PrintLn(espacios, list.Lineactual, list.linealargopagina(salida), 2, 'Arial, normal, 11');
    end;
  end;
  list.PrintLn(0, 0, ' ', 1, 'Arial, negrita, 8');
  list.PrintLn(espacios, list.Lineactual, leyenda, 2, 'Arial, negrita, 8');
  list.PrintLn(0, 0, ' ', 1, 'Arial, negrita, 8');
  list.PrintLn(espacios, list.Lineactual, '', 2, 'Arial, negrita, 8');
  list.importe(10, list.lineactual, '', totNettot, 3, 'Arial, negrita, 8');
  list.importe(25, list.lineactual, '', totConnograv, 4, 'Arial, negrita, 8');
  list.importe(40, list.lineactual, '', totOpexenta, 5, 'Arial, negrita, 8');
  list.importe(85, list.lineactual, '', totIva, 6, 'Arial, negrita, 8');
  list.importe(100, list.lineactual, '', totSobretasa, 7, 'Arial, negrita, 8');
  list.importe(115, list.lineactual, '', totOtrosImp, 8, 'Arial, negrita, 8');
  list.importe(130, list.lineactual, '', totImpuestosint, 9, 'Arial, negrita, 8');
  list.importe(145, list.lineactual, '', totPercepcion, 10, 'Arial, negrita, 8');
  list.importe(160, list.lineactual, '', totTotoper, 11, 'Arial, negrita, 8');
  list.importe(175, list.lineactual, '', totRetencion, 12, 'Arial, negrita, 8');
end;

procedure TTIvaVenta.ControlarSalto;
Begin
  if lim > 0 then
    if lineas >= lim then Begin
      FinalizarPagina := True;
      lineas := 0;
    end;
end;

procedure TTIvaVenta.LineaIva(salida: char);
// Objetivo...: Imprimir una Línea de Detalle
begin
  if not infresumido then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(espacios, list.Lineactual, utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(17, list.lineactual, tabla.FieldByName('idc').AsString , 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(20, list.lineactual, tabla.FieldByName('tipo').AsString + ' ' + tabla.FieldByName('sucursal').AsString + '-' + tabla.FieldByName('numero').AsString + '  ' + Copy(tabla.FieldByName('nombre').AsString, 1, 25) , 4, 'Arial, normal, 8', salida, 'N');
    if tabla.FieldByName('anulado').AsString <> 'A' then list.Linea(69, list.lineactual, tabla.FieldByName('cuit').AsString + '  ' + tabla.FieldByName('codpfis').AsString, 5, 'Arial, normal, 8', salida, 'S') else
      list.Linea(69, list.lineactual, 'A N U L A D A', 5, 'Arial, normal, 8', salida, 'S');

    if ((list.SaltoPagina) or (FinalizarPagina)) and not (OmitirTransporte) then Begin
      list.PrintLn(0, 0, ' ', 1, 'Arial, normal, 11');
      list.PrintLn(espacios, list.Lineactual, list.linealargopagina(salida), 2, 'Arial, normal, 11');
      Transporte('Transporte ...:', salida);
      list.IniciarNuevaPagina;
      Transporte('Transporte ...:', salida);
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      FinalizarPagina := False;
    end;

    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
    list.importe(10,  list.lineactual, '', tabla.FieldByName('Neto').AsFloat, 2, 'Arial, normal, 8');
    list.importe(25, list.lineactual, '', tabla.FieldByName('Connograv').AsFloat, 3, 'Arial, normal, 8');
    list.importe(40, list.lineactual, '', tabla.FieldByName('Exentas').AsFloat, 4, 'Arial, normal, 8');
    list.importe(55, list.lineactual, '', tabla.FieldByName('Tasaiva').AsFloat, 5, 'Arial, normal, 8');
    list.importe(70, list.lineactual, '', tabla.FieldByName('Tasaivani').AsFloat, 6, 'Arial, normal, 8');
    list.importe(85, list.lineactual, '', tabla.FieldByName('Ivari').AsFloat, 7, 'Arial, normal, 8');
    list.importe(100, list.lineactual, '', tabla.FieldByName('sobretasa').AsFloat, 8, 'Arial, normal, 8');
    list.importe(115, list.lineactual, '', tabla.FieldByName('Otrosimp').AsFloat, 9, 'Arial, normal, 8');
    list.importe(130, list.lineactual, '', tabla.FieldByName('Impuestosint').AsFloat, 10, 'Arial, normal, 8');
    list.importe(145, list.lineactual, '', tabla.FieldByName('Percepcion').AsFloat, 11, 'Arial, normal, 8');
    list.importe(160, list.lineactual, '', tabla.FieldByName('Total').AsFloat, 12, 'Arial, normal, 8');
    list.importe(175, list.lineactual, '', tabla.FieldByName('retencion').AsFloat, 13, 'Arial, normal, 8');
    list.Linea(175, list.lineactual, '', 14, 'Arial, normal, 8', salida, 'S');
  end;

  //Subtotales
  if tabla.FieldByName('anulado').AsString <> 'A' then Begin
    totNettot       := totNettot       + utiles.setNro2Dec(tabla.FieldByName('Neto').AsFloat);
    totConnograv    := totConnograv    + utiles.setNro2Dec(tabla.FieldByName('Connograv').AsFloat);
    totOpexenta     := totOpexenta     + utiles.setNro2Dec(tabla.FieldByName('Exentas').AsFloat);
    totIva          := totIva          + utiles.setNro2Dec(tabla.FieldByName('Ivari').AsFloat);
    totSobretasa    := totSobretasa    + utiles.setNro2Dec(tabla.FieldByName('sobretasa').AsFloat);
    totOtrosImp     := totOtrosImp     + utiles.setNro2Dec(tabla.FieldByName('Otrosimp').AsFloat);
    totImpuestosint := totImpuestosInt + utiles.setNro2Dec(tabla.FieldByName('Impuestosint').AsFloat);
    totPercepcion   := totPercepcion   + utiles.setNro2Dec(tabla.FieldByName('Percepcion').AsFloat);
    totTotoper      := totTotoper      + utiles.setNro2Dec(tabla.FieldByName('total').AsFloat);
    totRetencion    := totRetencion    + utiles.setNro2Dec(tabla.FieldByName('retencion').AsFloat);
  end;

  Inc(lineas); ControlarSalto;

  if ((list.SaltoPagina) or (FinalizarPagina)) and not (OmitirTransporte) then Begin
    list.PrintLn(0, 0, ' ', 1, 'Arial, normal, 11');
    list.PrintLn(espacios, list.Lineactual, list.linealargopagina(salida), 2, 'Arial, normal, 11');
    Transporte('Transporte ...:', salida);
    list.IniciarNuevaPagina;
    Transporte('Transporte ...:', salida);
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    FinalizarPagina := False;
  end;
end;

procedure  TTIvaVenta.IniciarInfSubtotales(salida: char; LineasSubtotales: Integer);
begin
  IniciarInforme(salida);
end;

procedure TTIvaVenta.ListarLibro(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro, xrenglones: string);
var
  i: string;
begin
  lineas := 0; espacios := 4;
  if Length(Trim(xrenglones)) > 0 then lim := StrToInt(Trim(xrenglones)) else lim := 0;  // Salto de Hoja Manual
  totNettot := 0; totOpexenta := 0; totConnograv := 0; totIva := 0; totIvarec := 0; totPercepcion := 0; totPergan := 0; totTotOper := 0; totRetencion := 0;
  totImpuestosint := 0; totOtrosImp := 0; totSobretasa := 0; modulo := 'V';
  xmes        := mes;
  pag         := pag_inicial;
  list.pagina := pag_inicial;

  if salida = 'I' then list.ImprimirHorizontal;
  list.Setear(salida);
  Titulo(salida, mes);

  inf_iniciado := True;

  i := tabla.IndexFieldNames;
  tabla.IndexFieldNames := 'Fecha';
  tabla.First;

  while not tabla.EOF do Begin
    if t_filtro = '1' then     // Filtro por Fecha de Emisión
      if (tabla.FieldByName('fecha').AsString >= p1) and (tabla.FieldByName('fecha').AsString <= p2) then LineaIva(salida);
    if t_filtro = '2' then     // Filtro por Código de Movimiento
      if ((tabla.FieldByName('fecha').AsString >= p1) and (tabla.FieldByName('fecha').AsString <= p2)) and (tabla.FieldByName('codmov').AsString = p3) then LineaIva(salida);
    if t_filtro = '3' then     // Filtro por Tipo de Comprobante
      if ((tabla.FieldByName('fecha').AsString >= p1) and (tabla.FieldByName('fecha').AsString <= p2)) and (tabla.FieldByName('idc').AsString = p3) then LineaIva(salida);
    if t_filtro = '4' then     // Filtro por Proveedor
      if ((tabla.FieldByName('fecha').AsString >= p1) and (tabla.FieldByName('fecha').AsString <= p2)) and (tabla.FieldByName('entidad').AsString = p3) then LineaIva(salida);
    if t_filtro = '5' then     // Filtro por Fecha de Recepción
      if (tabla.FieldByName('fecharecep').AsString >= p1) and (tabla.FieldByName('fecharecep').AsString <= p2) then LineaIva(salida);
    tabla.Next;
  end;

  if (totTotOper = 0) and not (infresumido) then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'N');
    list.Linea(espacios, list.Lineactual, 'Sin Movimientos', 2, 'Arial, normal, 10', salida, 'S');
  end;
  Transporte('Subtotales:', salida);

  tabla.IndexFieldNames := i;
  if salida = 'I' then pag := list.pagina;
  UltimoNroPagina := pag;
end;

//------------------------------------------------------------------------------

procedure TTIvaVenta.ListarLibro(salida: char; pag_inicial: integer; mes, p1, p2, p3, t_filtro, xrenglones: string; xlista: TStringList);
var
  i: string;
  j: Integer;
  l, lm: Boolean;

  procedure Subtotalizar(salida: char);
  // Objetivo...: Transporte Libro I.V.A.
  begin
    if totTotoper <> 0 then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(espacios, list.Lineactual, list.linealargopagina(salida), 2, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
      list.Linea(espacios, list.Lineactual, 'Subtotal:', 2, 'Arial, negrita, 8', salida, 'N');
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
      list.Linea(espacios, list.Lineactual, '', 2, 'Arial, negrita, 8', salida, 'N');
      list.importe(10, list.lineactual, '', totNettot, 3, 'Arial, negrita, 8');
      list.importe(25, list.lineactual, '', totConnograv, 4, 'Arial, negrita, 8');
      list.importe(40, list.lineactual, '', totOpexenta, 5, 'Arial, negrita, 8');
      list.importe(85, list.lineactual, '', totIva, 6, 'Arial, negrita, 8');
      list.importe(100, list.lineactual, '', totSobretasa, 7, 'Arial, negrita, 8');
      list.importe(115, list.lineactual, '', totOtrosImp, 8, 'Arial, negrita, 8');
      list.importe(130, list.lineactual, '', totImpuestosint, 9, 'Arial, negrita, 8');
      list.importe(145, list.lineactual, '', totPercepcion, 10, 'Arial, negrita, 8');
      list.importe(160, list.lineactual, '', totTotoper, 11, 'Arial, negrita, 8');
      list.importe(175, list.lineactual, '', totRetencion, 12, 'Arial, negrita, 8');
      list.Linea(175, list.Lineactual, ' ', 13, 'Arial, negrita, 8', salida, 'S');
    end;
    totNettot := 0; totOpexenta := 0; totConnograv := 0; totIva := 0; totIvarec := 0; totPercepcion := 0; totPergan := 0; totTotOper := 0; totRetencion := 0;
    totImpuestosint := 0; totOtrosImp := 0; totSobretasa := 0; modulo := 'V';
  end;

begin
  lineas := 0; espacios := 4;
  if Length(Trim(xrenglones)) > 0 then lim := StrToInt(Trim(xrenglones)) else lim := 0;  // Salto de Hoja Manual
  totNettot := 0; totOpexenta := 0; totConnograv := 0; totIva := 0; totIvarec := 0; totPercepcion := 0; totPergan := 0; totTotOper := 0; totRetencion := 0;
  totImpuestosint := 0; totOtrosImp := 0; totSobretasa := 0; modulo := 'V';
  xmes             := mes;
  pag              := pag_inicial;
  list.pagina      := pag_inicial;
  OmitirTransporte := True;

  if salida = 'I' then list.ImprimirHorizontal;
  list.Setear(salida);
  Titulo(salida, mes);

  inf_iniciado := True;

  i := tabla.IndexFieldNames;
  tabla.IndexFieldNames := 'Fecha';
  tabla.First;

  for j := 1 to xlista.Count do Begin
    datosdb.Filtrar(tabla, 'codmov = ' + '''' + xlista.Strings[j-1] + '''' + ' and fecha >= ' + '''' + p1 + '''' + ' and fecha <= ' + '''' + p2 + '''');
    tabla.First; lm := False;

    while not tabla.EOF do Begin
      if t_filtro = '2' then     // Filtro por Código de Movimiento
        if not lm then Begin
          netos.getDatos(xlista.Strings[j-1]);
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          list.Linea(0, 0, '    Tipo de Movimiento: ' + netos.codmov + '-' + netos.descrip, 1, 'Arial, negrita, 10', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          lm := True;
        end;

        LineaIva(salida);
        l := True;
      tabla.Next;
    end;

    Subtotalizar(salida);

    datosdb.QuitarFiltro(tabla);
  end;

  Subtotalizar(salida);

  if not l then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'N');
    list.Linea(espacios, list.Lineactual, 'Sin Movimientos', 2, 'Arial, normal, 10', salida, 'S');
  end;

  tabla.IndexFieldNames := i;
  if salida = 'I' then pag := list.pagina;
  UltimoNroPagina  := pag;
  OmitirTransporte := False;
end;

//------------------------------------------------------------------------------

function  TTIvaVenta.setNumeroDePagina: Integer;
// Objetivo...: Retornar el Nro. de Página
Begin
  modulo := 'V';
  Result := inherited setNumeroDePagina;
end;

procedure TTIvaVenta.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  cliente.conectar;
  inherited conectar;
end;

procedure TTIvaVenta.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  cliente.desconectar;
  inherited desconectar;
end;

{===============================================================================}

function ivav: TTIvaVenta;
begin
  if xivav = nil then
    xivav := TTIvaVenta.Create;
  Result := xivav;
end;

{===============================================================================}

initialization

finalization
  xivav.Free;

end.
