unit CCuotasCIC;

interface

uses CSociosCIC, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes,
     CParametrosEmpresa, Contnrs, CCuotasSocietariasCIC, CCtaCteBancariaCCI,
     CCajaAhorroCCI, CServers2000_Excel;

type

TTCuotas = class
  Periodo, Idsocio, nroplan, Idcategoria, Items, Concepto, Fecha, Estado, Tipo, Sucursal, Numero, FechaEmis, CC, CA, Entidad1, Entidad2: String;
  Monto, Recargo, Efectivo, CajaAhorro, CtaCte: Real;
  tabla: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xperiodo, xidsocio, xnroplan, xitems: String): Boolean;
  procedure   RegistrarPlan(xperiodo, xidsocio, xnroplan, xitems, xconcepto, xidcategoria: String; xmonto: Real);
  procedure   AjustarPlan(xperiodo, xidsocio, xnroplan, xitems, xidcat: String; xmonto: Real);
  procedure   Borrar(xperiodo, xidsocio, xnroplan: String);
  function    setCuotasImpagas(xperiodo, xidsocio, xnroplan: String): TObjectList;
  function    setCuotasPagas(xperiodo, xidsocio, xnroplan: String): TObjectList;
  function    setCuotasPendientes(xperiodo, xidsocio, xnroplan: String): TObjectList;
  function    setCuotasCanceladas(xperiodo, xidsocio, xnroplan: String): TObjectList;
  function    setPlan(xperiodo, xidsocio: String): String;
  procedure   getDatos(xperiodo, xidsocio, xnroplan: String);

  procedure   ImputarPago(xperiodo, xidsocio, xnroplan, xitems, xfecha, xtipo, xsucursal, xnumero: String; xrecargo: Real);
  procedure   RegistrarPago(xperiodo, xidsocio, xnroplan, xitems, xfecha, xcajaahorrobco, xctactebanco, xentidad1, xentidad2: String; xefectivo, xcajaahorro, xctacte: Real);
  procedure   AnularPago(xperiodo, xidsocio, xnroplan, xitems: String);
  procedure   CancelarPago(xperiodo, xidsocio, xnroplan, xitems: String);

  procedure   ListarDetalleCobros(xdfecha, xhfecha: String; titSel: TStringList; salida: Char);
  procedure   InformeEstadoCuotas(xfdesde, xfhasta: String; titSel: TStringList; salida: char);
  procedure   ListarCuotasImpagas(xfdesde, xfhasta, xmeses: String; titSel: TStringList; salida: char);

  function    VerificarSiTieneCuotasPagas(xperiodo, xidsocio, xplan: String): Boolean;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones, difanios: shortint;
  lista, detalle: TStringList;
  totales: array[1..50] of Real;
  meses: array[1..12] of String;
  col: array[1..12] of String;
  idanter, idanter1, Idcat: String;
  l: Boolean;
  Tiporec, Sucrec, Numrec, l1: String;
  cantt, c1: Integer;
  function  setCuotas(xperiodo, xidsocio, xnroplan: String; xestado: String): TObjectList;
  procedure TotCobros(salida: char);
  procedure Linea(xidanter: String; xmi: Integer; salida: Char);
  procedure TotalesFinales(salida: char);
  procedure listLineaAtrazos(xidtitular: String; salida: char);
end;

function cuota: TTCuotas;

implementation

var
  xcuota: TTCuotas = nil;

constructor TTCuotas.Create;
begin
  tabla := datosdb.openDB('cuotas', '');
end;

destructor TTCuotas.Destroy;
begin
  inherited Destroy;
end;

function  TTCuotas.Buscar(xperiodo, xidsocio, xnroplan, xitems: String): Boolean;
// Objetivo...: Buscar Instancia
Begin
  Result := datosdb.Buscar(tabla, 'periodo', 'idsocio', 'nroplan', 'items', xperiodo, xidsocio, xnroplan, xitems);
end;

procedure TTCuotas.RegistrarPlan(xperiodo, xidsocio, xnroplan, xitems, xconcepto, xidcategoria: String; xmonto: Real);
// Objetivo...: Registrar Instancia
Begin
  if Buscar(xperiodo, xidsocio, xnroplan, xitems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('periodo').AsString     := xperiodo;
  tabla.FieldByName('idsocio').AsString     := xidsocio;
  tabla.FieldByName('nroplan').AsString     := xnroplan;
  tabla.FieldByName('items').AsString       := xitems;
  tabla.FieldByName('concepto').AsString    := xconcepto;
  tabla.FieldByName('idcategoria').AsString := xidcategoria;
  tabla.FieldByName('monto').AsFloat        := xmonto;
  tabla.FieldByName('estado').AsString      := 'I';
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTCuotas.AjustarPlan(xperiodo, xidsocio, xnroplan, xitems, xidcat: String; xmonto: Real);
// Objetivo...: Registrar Instancia
Begin
  if Buscar(xperiodo, xidsocio, xnroplan, xitems) then Begin
    tabla.Edit;
    tabla.FieldByName('monto').AsFloat        := xmonto;
    tabla.FieldByName('idcategoria').AsString := xidcat;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTCuotas.Borrar(xperiodo, xidsocio, xnroplan: String);
// Objetivo...: Borrar una Instancia
Begin
  datosdb.tranSQL('delete from ' + tabla.TableName + ' where periodo = ' + '''' + xperiodo + '''' + ' and nroplan = ' + '''' + xnroplan + '''' + ' and idsocio = ' + '''' + xidsocio + '''');
end;

function  TTCuotas.setCuotas(xperiodo, xidsocio, xnroplan, xestado: String): TObjectList;
// Objetivo...: Recuperar Cuotas Imapagas
var
  l: TObjectList;
  objeto: TTCuotas;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(tabla, 'periodo = ' + '''' + xperiodo + '''' + ' and idsocio = ' + '''' + xidsocio + '''' + ' and nroplan = ' + '''' + xnroplan + '''' + ' and estado = ' + '''' + xestado + '''');
  tabla.First;
  while not tabla.Eof do Begin
    objeto := TTCuotas.Create;
    objeto.Periodo     := tabla.FieldByName('periodo').AsString;
    objeto.Idsocio     := tabla.FieldByName('idsocio').AsString;
    objeto.nroplan     := tabla.FieldByName('nroplan').AsString;
    objeto.Items       := tabla.FieldByName('items').AsString;
    objeto.Concepto    := tabla.FieldByName('concepto').AsString;
    objeto.Idcategoria := tabla.FieldByName('idcategoria').AsString;
    objeto.Fecha       := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
    objeto.FechaEmis   := utiles.sFormatoFecha(tabla.FieldByName('fechaemis').AsString);
    objeto.Estado      := tabla.FieldByName('estado').AsString;
    objeto.Monto       := tabla.FieldByName('monto').AsFloat;
    objeto.Recargo     := tabla.FieldByName('recargo').AsFloat;
    objeto.Tipo        := tabla.FieldByName('tipo').AsString;
    objeto.Sucursal    := tabla.FieldByName('sucursal').AsString;
    objeto.Numero      := tabla.FieldByName('numero').AsString;
    objeto.CC          := tabla.FieldByName('CC').AsString;
    objeto.CA          := tabla.FieldByName('CA').AsString;
    objeto.efectivo    := tabla.FieldByName('efectivo').AsFloat;
    objeto.ctacte      := tabla.FieldByName('ctacte').AsFloat;
    objeto.CajaAhorro  := tabla.FieldByName('cajaahorro').AsFloat;
    objeto.Entidad1    := tabla.FieldByName('entidad1').AsString;
    objeto.Entidad2    := tabla.FieldByName('entidad2').AsString;
    l.Add(objeto);
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);
  Result := l;
end;

function  TTCuotas.setCuotasImpagas(xperiodo, xidsocio, xnroplan: String): TObjectList;
// Objetivo...: Recuperar Cuotas Imapagas
Begin
  Result := setCuotas(xperiodo, xidsocio, xnroplan, 'I');
end;

function  TTCuotas.setCuotasPagas(xperiodo, xidsocio, xnroplan: String): TObjectList;
// Objetivo...: Recuperar Cuotas Pagas
Begin
  Result := setCuotas(xperiodo, xidsocio, xnroplan, 'P');
end;

function  TTCuotas.setCuotasPendientes(xperiodo, xidsocio, xnroplan: String): TObjectList;
// Objetivo...: Recuperar Cuotas Imapagas Pendientes
var
  l: TObjectList;
  objeto: TTCuotas;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(tabla, 'periodo = ' + '''' + xperiodo + '''' + ' and idsocio = ' + '''' + xidsocio + '''' + ' and nroplan = ' + '''' + xnroplan + '''' + ' and estado = ' + '''' + 'I' + '''');
  tabla.First;
  while not tabla.Eof do Begin
    if Length(Trim(tabla.FieldByName('numero').AsString)) > 0 then Begin
      objeto := TTCuotas.Create;
      objeto.Periodo     := tabla.FieldByName('periodo').AsString;
      objeto.Idsocio     := tabla.FieldByName('idsocio').AsString;
      objeto.nroplan     := tabla.FieldByName('nroplan').AsString;
      objeto.Items       := tabla.FieldByName('items').AsString;
      objeto.Concepto    := tabla.FieldByName('concepto').AsString;
      objeto.Idcategoria := tabla.FieldByName('idcategoria').AsString;
      objeto.Fecha       := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
      objeto.FechaEmis   := utiles.sFormatoFecha(tabla.FieldByName('fechaemis').AsString);
      objeto.Estado      := tabla.FieldByName('estado').AsString;
      objeto.Monto       := tabla.FieldByName('monto').AsFloat;
      objeto.Recargo     := tabla.FieldByName('recargo').AsFloat;
      objeto.Tipo        := tabla.FieldByName('tipo').AsString;
      objeto.Sucursal    := tabla.FieldByName('sucursal').AsString;
      objeto.Numero      := tabla.FieldByName('numero').AsString;
      objeto.CC          := tabla.FieldByName('CC').AsString;
      objeto.CA          := tabla.FieldByName('CA').AsString;
      objeto.efectivo    := tabla.FieldByName('efectivo').AsFloat;
      objeto.ctacte      := tabla.FieldByName('ctacte').AsFloat;
      objeto.CajaAhorro  := tabla.FieldByName('cajaahorro').AsFloat;
      objeto.Entidad1    := tabla.FieldByName('entidad1').AsString;
      objeto.Entidad2    := tabla.FieldByName('entidad2').AsString;
      l.Add(objeto);
    end;
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);
  Result := l;
end;

function  TTCuotas.setCuotasCanceladas(xperiodo, xidsocio, xnroplan: String): TObjectList;
// Objetivo...: Recuperar Cuotas Imapagas Pendientes
var
  l: TObjectList;
  objeto: TTCuotas;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(tabla, 'periodo = ' + '''' + xperiodo + '''' + ' and idsocio = ' + '''' + xidsocio + '''' + ' and nroplan = ' + '''' + xnroplan + '''' + ' and estado = ' + '''' + 'P' + '''');
  tabla.First;
  while not tabla.Eof do Begin
    if Length(Trim(tabla.FieldByName('numero').AsString)) > 0 then Begin
      objeto := TTCuotas.Create;
      objeto.Periodo     := tabla.FieldByName('periodo').AsString;
      objeto.Idsocio     := tabla.FieldByName('idsocio').AsString;
      objeto.nroplan     := tabla.FieldByName('nroplan').AsString;
      objeto.Items       := tabla.FieldByName('items').AsString;
      objeto.Concepto    := tabla.FieldByName('concepto').AsString;
      objeto.Idcategoria := tabla.FieldByName('idcategoria').AsString;
      objeto.Fecha       := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
      objeto.FechaEmis   := utiles.sFormatoFecha(tabla.FieldByName('fechaemis').AsString);
      objeto.Estado      := tabla.FieldByName('estado').AsString;
      objeto.Monto       := tabla.FieldByName('monto').AsFloat;
      objeto.Recargo     := tabla.FieldByName('recargo').AsFloat;
      objeto.Tipo        := tabla.FieldByName('tipo').AsString;
      objeto.Sucursal    := tabla.FieldByName('sucursal').AsString;
      objeto.Numero      := tabla.FieldByName('numero').AsString;
      objeto.CC          := tabla.FieldByName('CC').AsString;
      objeto.CA          := tabla.FieldByName('CA').AsString;
      objeto.efectivo    := tabla.FieldByName('efectivo').AsFloat;
      objeto.ctacte      := tabla.FieldByName('ctacte').AsFloat;
      objeto.CajaAhorro  := tabla.FieldByName('cajaahorro').AsFloat;
      objeto.Entidad1    := tabla.FieldByName('entidad1').AsString;
      objeto.Entidad2    := tabla.FieldByName('entidad2').AsString;
      l.Add(objeto);
    end;
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);
  Result := l;
end;

function  TTCuotas.setPlan(xperiodo, xidsocio: String): String;
// Objetivo...: cerrar tablas de persistencia
var
  np: String;
begin
  np := '000';
  datosdb.Filtrar(tabla, 'periodo = ' + '''' + xperiodo + '''' + ' and idsocio = ' + '''' + xidsocio + '''');
  tabla.First;
  while not tabla.Eof do Begin
    np := tabla.FieldByName('nroplan').AsString;
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);
  Result := utiles.sLlenarIzquierda(IntToStr ( StrToInt(np) + 0 ), 3, '0');
end;

procedure TTCuotas.getDatos(xperiodo, xidsocio, xnroplan: String);
// Objetivo...: cargar items
begin
  if Buscar(xperiodo, xidsocio, xnroplan, '12') then Begin
    Periodo     := Copy(tabla.FieldByName('periodo').AsString, 1, 2) + '/' + Copy(tabla.FieldByName('periodo').AsString, 3, 4);
    Idsocio     := tabla.FieldByName('idsocio').AsString;
    Nroplan     := tabla.FieldByName('nroplan').AsString;
    Items       := tabla.FieldByName('items').AsString;
    Idcategoria := tabla.FieldByName('idcategoria').AsString;
  end else Begin
    Periodo     := '';
    Idsocio     := '';
    Nroplan     := '';
    Items       := '';
    Idcategoria := '';
  end;
end;

procedure TTCuotas.ImputarPago(xperiodo, xidsocio, xnroplan, xitems, xfecha, xtipo, xsucursal, xnumero: String; xrecargo: Real);
// Objetivo...: imputar Pago
begin
  if Buscar(xperiodo, xidsocio, xnroplan, xitems) then Begin
    tabla.Edit;
    tabla.FieldByName('fechaemis').AsString := utiles.sExprFecha2000(xfecha);
    tabla.FieldByName('tipo').AsString      := xtipo;
    tabla.FieldByName('sucursal').AsString  := xsucursal;
    tabla.FieldByName('numero').AsString    := xnumero;
    tabla.FieldByName('recargo').AsFloat    := xrecargo;
    tabla.FieldByName('estado').AsString    := 'I';
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTCuotas.RegistrarPago(xperiodo, xidsocio, xnroplan, xitems, xfecha, xcajaahorrobco, xctactebanco, xentidad1, xentidad2: String; xefectivo, xcajaahorro, xctacte: Real);
// Objetivo...: Marcar como Pagado
begin
  if Buscar(xperiodo, xidsocio, xnroplan, xitems) then Begin
    tabla.Edit;
    tabla.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
    tabla.FieldByName('CA').AsString        := xcajaahorrobco;
    tabla.FieldByName('CC').AsString        := xctactebanco;
    tabla.FieldByName('efectivo').AsFloat   := xefectivo;
    tabla.FieldByName('ctacte').AsFloat     := xctacte;
    tabla.FieldByName('cajaahorro').AsFloat := xcajaahorro;
    tabla.FieldByName('entidad1').AsString  := xentidad1;
    tabla.FieldByName('entidad2').AsString  := xentidad2;
    tabla.FieldByName('estado').AsString    := 'P';
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTCuotas.AnularPago(xperiodo, xidsocio, xnroplan, xitems: String);
// Objetivo...: Anular pago
begin
  if Buscar(xperiodo, xidsocio, xnroplan, xitems) then Begin
    tabla.Edit;
    tabla.FieldByName('fecha').AsString     := '';
    tabla.FieldByName('tipo').AsString      := '';
    tabla.FieldByName('sucursal').AsString  := '';
    tabla.FieldByName('numero').AsString    := '';
    tabla.FieldByName('recargo').AsFloat    := 0;
    tabla.FieldByName('estado').AsString    := 'I';
    tabla.FieldByName('CA').AsString        := '';
    tabla.FieldByName('CC').AsString        := '';
    tabla.FieldByName('efectivo').AsFloat   := 0;
    tabla.FieldByName('ctacte').AsFloat     := 0;
    tabla.FieldByName('cajaahorro').AsFloat := 0;
    tabla.FieldByName('entidad1').AsString  := '';
    tabla.FieldByName('entidad2').AsString  := '';
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTCuotas.CancelarPago(xperiodo, xidsocio, xnroplan, xitems: String);
// Objetivo...: cancelar pago
begin
  if Buscar(xperiodo, xidsocio, xnroplan, xitems) then Begin
    tabla.Edit;
    tabla.FieldByName('fecha').AsString     := '';
    tabla.FieldByName('recargo').AsFloat    := 0;
    tabla.FieldByName('estado').AsString    := 'I';
    tabla.FieldByName('CA').AsString        := '';
    tabla.FieldByName('CC').AsString        := '';
    tabla.FieldByName('efectivo').AsFloat   := 0;
    tabla.FieldByName('ctacte').AsFloat     := 0;
    tabla.FieldByName('cajaahorro').AsFloat := 0;
    tabla.FieldByName('entidad1').AsString  := '';
    tabla.FieldByName('entidad2').AsString  := '';
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

//------------------------------------------------------------------------------

procedure TTCuotas.ListarDetalleCobros(xdfecha, xhfecha: String; titSel: TStringList; salida: Char);
// Objetivo...: Listar Detalle de Cobros
var
  i, anioini, aniofinal: Integer;
  f, z: String;
Begin
  list.Setear(salida);
  if salida <> 'T' then Begin
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, empresa.RSocial, 1, 'Arial, normal, 12');
    List.Titulo(0, 0, 'Informe Detallado de Cuotas Societarias', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Mes          F.Cobro', 1, 'Arial, cursiva, 8');
    List.Titulo(15, List.lineactual, 'Comprobante', 2, 'Arial, cursiva, 8');
    List.Titulo(30, List.lineactual, 'Concepto', 3, 'Arial, cursiva, 8');
    List.Titulo(55, List.lineactual, 'Recibo', 4, 'Arial, cursiva, 8');
    List.Titulo(71, List.lineactual, 'Monto', 5, 'Arial, cursiva, 8');
    List.Titulo(80, List.lineactual, 'Cobro', 6, 'Arial, cursiva, 8');
    List.Titulo(90, List.lineactual, 'E', 7, 'Arial, cursiva, 8');
    List.Titulo(92, List.lineactual, 'Transf.', 8, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end else Begin
    list.LineaTxt('', True);
    List.LineaTxt(empresa.RSocial, True);
    list.LineaTxt('Informe Detallado de Aportes', True);
    list.LineaTxt('', True);
    list.LineaTxt('Mes      F.Cobro   Concepto                       Recibo       Monto  Recargo E', True);
    list.LineaTxt('-------------------------------------------------------------------------------', True);
    list.LineaTxt('', True);
  end;

  totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0; totales[8] := 0;
  idanter := ''; l := False;

  difanios  := StrToInt(Copy(utiles.sExprFecha2000(xhfecha), 1, 4)) - StrToInt(Copy(utiles.sExprFecha2000(xdfecha), 1, 4));
  anioini   := StrToInt(Copy(utiles.sExprFecha2000(xdfecha), 1, 4));
  aniofinal := StrToInt(Copy(utiles.sExprFecha2000(xhfecha), 1, 4));

  tabla.IndexFieldNames := 'idsocio;periodo;items';

  for i := 1 to 1 { difanios + 1} do Begin

    datosdb.Filtrar(tabla, 'periodo >= ' + IntToStr(anioini) + ' and periodo <= ' + IntToStr(aniofinal));

    if i > 1 then
      if salida <> 'T' then list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S') else list.LineaTxt('', True);


    if i = 1 then Begin

    if salida <> 'T' then Begin
      list.Linea(0, 0, 'Per�odo: ' + IntToStr(anioini) + '-' + IntToStr(aniofinal), 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    end else Begin
      list.LineaTxt('Per�odo: ' + IntToStr(anioini) + '-' + IntToStr(aniofinal), True);
      list.LineaTxt('', True);
    end;

    End;

    tabla.First;
    while not tabla.Eof do Begin
      if (StrToInt(tabla.FieldByName('periodo').AsString + tabla.FieldByName('items').AsString) >= StrToInt(Copy(utiles.sExprFecha2000(xdfecha), 1, 4) + Copy(xdfecha, 4, 2))) and (StrToInt(tabla.FieldByName('periodo').AsString + tabla.FieldByName('items').AsString) <= StrToInt(Copy(utiles.sExprFecha2000(xhfecha), 1, 4) + Copy(xhfecha, 4, 2))) and (utiles.verificarItemsLista(titSel, tabla.FieldByName('idsocio').AsString)) then Begin
        if tabla.FieldByName('idsocio').AsString + tabla.FieldByName('nroplan').AsString <> idanter then Begin
          TotCobros(salida);
          if l then
            if salida <> 'T' then list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S') else list.LineaTxt('', True);
          socio.getDatos(tabla.FieldByName('idsocio').AsString);
          categoria.getDatos(tabla.FieldByName('idcategoria').AsString);
          if salida <> 'T' then Begin
            list.Linea(0, 0, 'Socio: ' + socio.Nombre, 1, 'Arial, negrita, 9', salida, 'N');
            list.Linea(50, list.Lineactual, socio.domicilio, 2, 'Arial, negrita, 9', salida, 'S');
            list.Linea(0, 0, 'Cat.: ' + categoria.Idcategoria + '-' + categoria.Categoria, 1, 'Arial, negrita, 9', salida, 'N');
            list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
          end else Begin
            list.LineaTxt(Copy(socio.Nombre, 1, 30) + utiles.espacios(31 - (Length(TrimRight(Copy(socio.Nombre, 1, 30))))), False);
            list.LineaTxt(Copy(socio.domicilio, 1, 30) + utiles.espacios(31 - (Length(TrimRight(Copy(socio.domicilio, 1, 30))))), True);
            list.LineaTxt('Cat.: ' + categoria.Idcategoria + '-' + categoria.Categoria, True);
            list.LineaTxt('', True);
          end;
          idanter := tabla.FieldByName('idsocio').AsString + tabla.FieldByName('nroplan').AsString;
        end;

        z := utiles.sLlenarIzquierda (Copy(tabla.FieldByName('fecha').AsString, 1, 4) + tabla.FieldByName('idsocio').AsString + tabla.FieldByName('items').AsString, 11, '0');

        if salida <> 'T' then Begin
          list.Linea(0, 0, tabla.FieldByName('items').AsString + '/' + tabla.FieldByName('periodo').AsString + '   ' + utiles.sFormatoFecha(tabla.FieldByName('fechaemis').AsString), 1, 'Arial, normal, 8', salida, 'N');
          if tabla.FieldByName('estado').AsString = 'P' then
            list.Linea(15, list.Lineactual, tabla.FieldByName('tipo').AsString + ' ' + tabla.FieldByName('sucursal').AsString + '-' + tabla.FieldByName('numero').AsString, 2, 'Arial, normal, 8', salida, 'N')
          else
            list.Linea(15, list.Lineactual, '', 2, 'Arial, normal, 8', salida, 'N');
          list.Linea(30, list.Lineactual, tabla.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'N');
          list.Linea(55, list.Lineactual, Tiporec + ' ' + Sucrec + Numrec, 4, 'Arial, normal, 8', salida, 'N');
          list.Importe(75, list.Lineactual, '', tabla.FieldByName('monto').AsFloat, 5, 'Arial, normal, 8');
          list.Linea(80, list.Lineactual, utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString), 6, 'Arial, normal, 8', salida, 'N');
          list.Linea(90, list.Lineactual, tabla.FieldByName('estado').AsString, 7, 'Arial, normal, 8', salida, 'N');
          if Length(Trim(tabla.FieldByName('CA').AsString)) > 0 then list.Linea(92, list.Lineactual, 'CA: ' + tabla.FieldByName('CA').AsString, 8, 'Arial, normal, 8', salida, 'S') else
            if Length(Trim(tabla.FieldByName('CC').AsString)) > 0 then list.Linea(92, list.Lineactual, 'CC: ' + tabla.FieldByName('CC').AsString, 8, 'Arial, normal, 8', salida, 'S') else
              list.Linea(92, list.Lineactual, '', 8, 'Arial, normal, 8', salida, 'S');
        end else Begin
          if Length(Trim(tabla.FieldByName('fecha').AsString)) = 8 then f := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString) else f := '        ';
          list.LineaTxt(tabla.FieldByName('items').AsString + '/' + tabla.FieldByName('periodo').AsString + '  ' + f + '  ', False);
          list.LineaTxt(Copy(tabla.FieldByName('concepto').AsString, 1, 30) + utiles.espacios(31 - (Length(TrimRight(Copy(tabla.FieldByName('concepto').AsString, 1, 30))))), False);
          list.LineaTxt(Tiporec + ' ' + Sucrec + Numrec + utiles.espacios(16 - (Length(TrimRight(Tiporec + ' ' + Sucrec + Numrec)))), False);
          list.ImporteTxt(tabla.FieldByName('monto').AsFloat, 9, 2, False);
          list.ImporteTxt(tabla.FieldByName('recargo').AsFloat, 9, 2, False);
          list.LineaTxt(' ' + tabla.FieldByName('estado').AsString, True);
        end;
        totales[1] := totales[1] + 1;
        if Length(Trim(tabla.FieldByName('fecha').AsString)) > 0 then totales[2] := totales[2] + 1 else
          totales[8] := totales[8] + tabla.FieldByName('monto').AsFloat;
        totales[3] := totales[3] + tabla.FieldByName('monto').AsFloat;
        totales[4] := totales[4] + tabla.FieldByName('recargo').AsFloat;
        totales[6] := totales[6] + tabla.FieldByName('monto').AsFloat;
        totales[7] := totales[7] + tabla.FieldByName('recargo').AsFloat;
        l := True;
      end;
      tabla.Next;
    end;
    TotCobros(salida);

    datosdb.QuitarFiltro(tabla);
    Inc(anioini);
  end;

  if totales[6] + totales[8] > 0 then Begin
    if salida <> 'T' then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, 'Total Pagos:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(25, list.Lineactual, '', totales[6], 2, 'Arial, negrita, 9');
      list.Linea(35, list.Lineactual, 'Recargos:', 3, 'Arial, negrita, 9', salida, 'N');
      list.importe(60, list.Lineactual, '', totales[7], 4, 'Arial, negrita, 9');
      list.Linea(65, list.Lineactual, 'Total Deuda:', 5, 'Arial, negrita, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', totales[8], 6, 'Arial, negrita, 9');
      list.Linea(95, list.Lineactual, '', 7, 'Arial, negrita, 9', salida, 'S');
    end else Begin
      list.LineaTxt(' ', True);
      list.LineaTxt('Tot.Pagos:' + utiles.espacios(20 - (Length('Tot.Pagos:'))), False);
      list.importeTxt(totales[6], 10, 2, False);
      list.LineaTxt(' Recargos:', False);
      list.importeTxt(totales[7], 10, 2, True);
      list.LineaTxt(' Tot.Deuda:', False);
      list.importeTxt(totales[8], 10, 2, True);
      list.LineaTxt('', False);
    end;
  end;

  tabla.IndexFieldNames := 'periodo;idsocio;nroplan;items';

  if l then Begin
    if salida <> 'T' then list.FinList;
  end else utiles.msgError('No Existen Datos para Listar ...!');
  if salida = 'T' then list.FinalizarExportacion;
end;

procedure TTCuotas.TotCobros(salida: char);
// Objetivo...: Tot. Informe
begin
  if totales[1] > 0 then Begin
    if salida <> 'T' then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, 'Cuotas:   ' + utiles.FormatearNumero(FloatToStr(totales[1]), '####') + '          Pagadas:   ' + utiles.FormatearNumero(FloatToStr(totales[2]), '####'), 1, 'Arial, negrita, 8', salida, 'N');
      list.Linea(50, list.Lineactual, 'Tot. Pago:', 2, 'Arial, negrita, 8', salida, 'N');
      list.importe(70, list.Lineactual, '', totales[3], 3, 'Arial, negrita, 8');
      list.Linea(72, list.Lineactual, 'Recargos:', 4, 'Arial, negrita, 8', salida, 'N');
      list.importe(94, list.Lineactual, '', totales[4], 5, 'Arial, negrita, 8');
      list.Linea(95, list.Lineactual, '', 6, 'Arial, negrita, 8', salida, 'S');
    end else Begin
      list.LineaTxt(' ', True);
      list.LineaTxt('Cuotas:   ' + utiles.FormatearNumero(FloatToStr(totales[1]), '####') + '         Pagadas:   ' + utiles.FormatearNumero(FloatToStr(totales[2]), '####') + '  ', False);
      list.LineaTxt(' Tot. Pago:', False);
      list.importeTxt(totales[3], 10, 2, False);
      list.LineaTxt('    Recargos:', False);
      list.importeTxt(totales[4], 10, 2, True);
      list.LineaTxt('', True);
    end;
    totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0;
  end;
end;

procedure TTCuotas.InformeEstadoCuotas(xfdesde, xfhasta: String; titSel: TStringList; salida: char);
var
  m: array[1..12] of String;
  xidanter: String;
  j, mi, mf, i, anioini, k: Integer;
Begin
  for j := 1 to cantt do totales[j] := 0;
  mi := StrToInt(Copy(xfdesde, 4, 2));  // armar mes inicial
  For j := 1 to 12 do Begin
    case mi of
      1: m[j]  := 'E';
      2: m[j]  := 'F';
      3: m[j]  := 'M';
      4: m[j]  := 'A';
      5: m[j]  := 'M';
      6: m[j]  := 'J';
      7: m[j]  := 'J';
      8: m[j]  := 'A';
      9: m[j]  := 'S';
      10: m[j] := 'O';
      11: m[j] := 'N';
      12: m[j] := 'D';
    end;
    Inc(mi);
    if mi > 12 then mi := 1;
  end;

  col[1] := 'b'; col[2] := 'c'; col[3] := 'd'; col[4] := 'e'; col[5] := 'f';
  col[6] := 'g'; col[7] := 'h'; col[8] := 'i'; col[9] := 'j'; col[10] := 'k';
  col[11] := 'l'; col[12] := 'm';

  mi := StrToInt(Copy(xfdesde, 4, 2));  // armar mes inicial
  mf := StrToInt(Copy(xfhasta, 4, 2));  // armar mes final

  if (salida <> 'X') then begin
  list.Setear(salida);
  list.Titulo(0, 0, '', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Informe Cobro de Cuotas Societarias Lapso: ' + xfdesde + ' - ' + xfhasta, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

  list.Titulo(0, 0, 'Raz�n Social', 1, 'Arial, cursiva, 8');
  list.Titulo(34, list.Lineactual, m[1], 2, 'Arial, cursiva, 8');
  list.Titulo(39, list.Lineactual, m[2], 3, 'Arial, cursiva, 8');
  list.Titulo(44, list.Lineactual, m[3], 4, 'Arial, cursiva, 8');
  list.Titulo(49, list.Lineactual, m[4], 5, 'Arial, cursiva, 8');
  list.Titulo(54, list.Lineactual, m[5], 6, 'Arial, cursiva, 8');
  list.Titulo(59, list.Lineactual, m[6], 7, 'Arial, cursiva, 8');
  list.Titulo(64, list.Lineactual, m[7], 8, 'Arial, cursiva, 8');
  list.Titulo(69, list.Lineactual, m[8], 9, 'Arial, cursiva, 8');
  list.Titulo(74, list.Lineactual, m[9], 10, 'Arial, cursiva, 8');
  list.Titulo(79, list.Lineactual, m[10], 11, 'Arial, cursiva, 8');
  list.Titulo(84, list.Lineactual, m[11], 12, 'Arial, cursiva, 8');
  list.Titulo(89, list.Lineactual, m[12] + '          Total', 13, 'Arial, cursiva, 8');

  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');
  end;
  if (salida = 'X') then begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('b' + l1, 'b' + l1, ' Informe Cobro de Cuotas Societarias Lapso: ' + xfdesde + ' - ' + xfhasta, 'Arial, negrita, 12');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Raz�n Social', 'Arial, normal, 8');
    excel.setString('b' + l1, 'b' + l1, m[1], 'Arial, normal, 8');
    excel.setString('c' + l1, 'c' + l1, m[2], 'Arial, normal, 8');
    excel.setString('d' + l1, 'd' + l1, m[3], 'Arial, normal, 8');
    excel.setString('e' + l1, 'e' + l1, m[4], 'Arial, normal, 8');
    excel.setString('f' + l1, 'f' + l1, m[5], 'Arial, normal, 8');
    excel.setString('g' + l1, 'g' + l1, m[6], 'Arial, normal, 8');
    excel.setString('h' + l1, 'h' + l1, m[7], 'Arial, normal, 8');
    excel.setString('i' + l1, 'i' + l1, m[8], 'Arial, normal, 8');
    excel.setString('j' + l1, 'j' + l1, m[9], 'Arial, normal, 8');
    excel.setString('k' + l1, 'k' + l1, m[10], 'Arial, normal, 8');
    excel.setString('l' + l1, 'l' + l1, m[11], 'Arial, normal, 8');
    excel.setString('m' + l1, 'm' + l1, m[12], 'Arial, normal, 8');
    excel.setString('n' + l1, 'n' + l1, 'Total', 'Arial, normal, 8');
    excel.FijarAnchoColumna('a' + l1, 'a' + l1, 37);
    excel.FijarAnchoColumna('b' + l1, 'b' + l1, 5);
    excel.FijarAnchoColumna('c' + l1, 'c' + l1, 5);
    excel.FijarAnchoColumna('d' + l1, 'd' + l1, 5);
    excel.FijarAnchoColumna('e' + l1, 'e' + l1, 5);
    excel.FijarAnchoColumna('f' + l1, 'f' + l1, 5);
    excel.FijarAnchoColumna('g' + l1, 'g' + l1, 5);
    excel.FijarAnchoColumna('h' + l1, 'h' + l1, 5);
    excel.FijarAnchoColumna('i' + l1, 'i' + l1, 5);
    excel.FijarAnchoColumna('j' + l1, 'j' + l1, 5);
    excel.FijarAnchoColumna('k' + l1, 'k' + l1, 5);
    excel.FijarAnchoColumna('l' + l1, 'l' + l1, 5);
    excel.FijarAnchoColumna('m' + l1, 'm' + l1, 5);
    excel.FijarAnchoColumna('n' + l1, 'n' + l1, 9);

  end;

  tabla.IndexFieldNames := 'Idsocio;Periodo;Nroplan;Items';

  difanios := StrToInt(Copy(utiles.sExprFecha2000(xfhasta), 1, 4)) - StrToInt(Copy(utiles.sExprFecha2000(xfdesde), 1, 4));
  anioini  := StrToInt(Copy(utiles.sExprFecha2000(xfdesde), 1, 4));

  for k := 1 to difanios + 1 do Begin

    if (salida <> 'X') then begin
      if k > 1 then list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, 'A�o: ' + IntToStr(anioini), 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    end;
    if (salida = 'X') then begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'A�o:  ' + IntToStr(anioini), 'Arial, negrita, 9');
    end;

    datosdb.Filtrar(tabla, 'periodo = ' + IntToStr(anioini));

    tabla.First; xidanter := ''; l := False; idcat := '';
    For i := 1 to 12 do meses[i] := '0';
    while not tabla.Eof do Begin
      if (StrToInt(tabla.FieldByName('periodo').AsString + tabla.FieldByName('items').AsString) >= StrToInt(Copy(utiles.sExprFecha2000(xfdesde), 1, 4) + Copy(xfdesde, 4, 2))) and (StrToInt(tabla.FieldByName('periodo').AsString + tabla.FieldByName('items').AsString) <= StrToInt(Copy(utiles.sExprFecha2000(xfhasta), 1, 4) + Copy(xfhasta, 4, 2))) and (utiles.verificarItemsLista(titSel, tabla.FieldByName('idsocio').AsString)) then Begin
        if Length(Trim(xidanter)) = 0 then xidanter := tabla.FieldByName('idsocio').AsString + tabla.FieldByName('nroplan').AsString;
        if tabla.FieldByName('idsocio').AsString + tabla.FieldByName('nroplan').AsString <> xidanter then Begin
          linea(xidanter, mi, salida);
          xidanter := tabla.FieldByName('idsocio').AsString + tabla.FieldByName('nroplan').AsString;
          For i := 1 to 12 do meses[i] := '0';
        end;
        if tabla.FieldByName('estado').AsString = 'P' then Begin
          meses[StrToInt(tabla.FieldByName('items').AsString)] := Copy(tabla.FieldByName('fecha').AsString, 7, 2) + '/' + Copy(tabla.FieldByName('fecha').AsString, 5, 2); //utiles.FormatearNumero(tabla.FieldByName('monto').AsString);
          totales[2] := totales[2] + tabla.FieldByName('monto').AsFloat;
          totales[4] := totales[4] + tabla.FieldByName('monto').AsFloat;
        end;
        if tabla.FieldByName('estado').AsString > '' then totales[3] := totales[3] + 1;
        idcat := tabla.FieldByName('idcategoria').AsString;

      end;

      tabla.Next;
    end;

    linea(xidanter, mi, salida);

    datosdb.QuitarFiltro(tabla);
    Inc(anioini);
  end;

  tabla.IndexFieldNames := 'Periodo;Idsocio;Nroplan;Items';

  if not l then list.Linea(0, 0, 'No existen datos para listar', 1, 'Arial, normal, 9', salida, 'S') else TotalesFinales(salida);
  if (salida <> 'X') then list.FinList;
  if (salida = 'X') then excel.Visulizar;
end;

procedure TTCuotas.Linea(xidanter: String; xmi: Integer; salida: Char);
var
  i, j, q: Integer;
Begin
  socio.getDatos(Copy(xidanter, 1, 6));
  if (salida <> 'X') then begin
    list.Linea(0, 0, Copy(socio.nombre, 1, 30), 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(28, list.Lineactual, idcat, 2, 'Arial, normal, 8', salida, 'N');
  end;
  if (salida = 'X') then begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, socio.nombre + '  -  ' + idcat, 'Arial, normal, 8');
  end;

  j := 35; q := 2;
  For i := xmi to 12 do Begin   // Desde el mes inicial hasta fin de a�o
    Inc(q);

    if (salida <> 'X') then begin
      if meses[i] = '0' then list.Linea(j-3, list.Lineactual, '', q, 'Arial, normal, 8, clBlack', salida, 'N') else list.Linea(j-3, list.Lineactual, meses[i], q, 'Arial, normal, 8', salida, 'N');  //if meses[i] = '0' then list.Importe(j, list.Lineactual, '##,##', StrToFloat(meses[i]), q, 'Arial, normal, 8') else list.Importe(j, list.Lineactual, '', StrToFloat(meses[i]), q, 'Arial, normal, 8');
    end;

    if (salida = 'X') then begin
      if (q-2 <= 12) then begin
      if meses[i] = '0' then
        excel.setString(col[q-2] + l1, col[q-2] + l1, '', 'Arial, normal, 8')
      else
        excel.setString(col[q-2] + l1, col[q-2] + l1, '''' + meses[i], 'Arial, normal, 8');
      end;
    end;

    j := j + 5;
  end;
  For i := 1 to xmi-1 do Begin   // Desde el mes inicial del a�o siguiente hasta el principio del primero
    Inc(q);

    if (salida <> 'X') then begin
      if meses[i] = '0' then list.Linea(j-3, list.Lineactual, '', q, 'Arial, normal, 8, clBlack', salida, 'N') else list.Linea(j-3, list.Lineactual, meses[i], q, 'Arial, normal, 8', salida, 'N');
    end;
    if (salida = 'X') then begin
      if (q <= 12) then begin
      if meses[i] = '0' then
        excel.setString(col[q-2] + l1, col[q-2] + l1, '', 'Arial, normal, 8')
      else
        excel.setString(col[q-2] + l1, col[q-2] + l1, '''' + meses[i], 'Arial, normal, 8');
      end;
    end;

    j := j + 5;
  end;

  Inc(q);
  if (salida <> 'X') then begin
    list.importe(99, list.Lineactual, '', totales[4], q,'Arial, negrita, 8');
  end;
  if (salida = 'X') then begin
    excel.setReal('n' + l1, 'n' + l1, totales[4], 'Arial, normal, 8');
  end;

  Inc(q);
  if (salida <> 'X') then begin
    list.Linea(99, list.Lineactual, '', q,'Arial, negrita, 8', salida, 'S');
  end;

  totales[1] := totales[1] + 1;
  totales[4] := 0;

  l := True;
end;

procedure  TTCuotas.TotalesFinales(salida: char);
// Objetivo...: Totales estad�sticos
Begin
  if (salida <> 'X') then begin
    list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, 'Cantidad de Aportes:', 1, 'Arial, negrita, 9', salida, 'N');
    list.Importe(99, list.Lineactual, '#####', totales[1], 2, 'Arial, negrita, 9');
    list.Linea(99, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Monto Total Cobrado:', 1, 'Arial, negrita, 9', salida, 'N');
    list.Importe(99, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 9');
    list.Linea(99, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
  end;
  if (salida = 'X') then begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Cantidad de Aportes:', 'Arial, negrita, 9');
    excel.setReal('n' + l1, 'n' + l1, totales[1], 'Arial, negrita, 9');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Monto Total Cobrado:', 'Arial, negrita, 9');
    excel.setReal('n' + l1, 'n' + l1, totales[2], 'Arial, negrita, 9');
  end;
  totales[1] := 0; totales[2] := 0;
end;

procedure TTCuotas.ListarCuotasImpagas(xfdesde, xfhasta, xmeses: String; titSel: TStringList; salida: char);
// Objetivo...: Listar Cuotas atrazadas
var
  per: String;
Begin
  list.Setear(salida);
  totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0;
  if salida <> 'T' then Begin
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, empresa.RSocial, 1, 'Arial, normal, 12');
    List.Titulo(0, 0, 'Informe de Cuotas Societarias Impagas al: ' + xfdesde, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Raz�n Social - Plan', 1, 'Arial, cursiva, 8');
    List.Titulo(27, List.lineactual, 'Cuotas Adeudadas', 2, 'Arial, cursiva, 8');
    List.Titulo(88, List.lineactual, 'Cant.', 3, 'Arial, cursiva, 8');
    List.Titulo(94, List.lineactual, 'Monto', 4, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end else Begin
    List.LineaTxt(' ', True);
    List.LineaTxt(empresa.RSocial, True);
    List.LineaTxt('Informe de Cuotas Societarias Impagas al: ' + xfdesde, True);
    List.LineaTxt(' ', True);
    List.LineaTxt('Raz�n Social - Plan            Cuotas Atrazadas                Cant.     Monto', True);
    List.LineaTxt('------------------------------------------------------------------------------', True);
    List.LineaTxt(' ', True);
  end;

  per := utiles.RestarPeriodo(xfdesde, xmeses);
  tabla.IndexFieldNames := 'Idsocio;Periodo;Nroplan;Items';
  tabla.First; idanter := ''; l := False; totales[4] := 0; idanter1 := ''; idcat := '';
  detalle := TStringList.Create;
  while not tabla.Eof do Begin
    if (tabla.FieldByName('periodo').AsString + tabla.FieldByName('items').AsString <= Copy(xfdesde, 4, 4) + Copy(xfdesde, 1, 2)) and (tabla.FieldByName('estado').AsString = 'I') and (utiles.verificarItemsLista(titSel, tabla.FieldByName('idsocio').AsString)) and (tabla.FieldByName('periodo').AsString + tabla.FieldByName('items').AsString <= Copy(utiles.sExprFecha2000(xfhasta), 1, 6)) then Begin
      if tabla.FieldByName('idsocio').AsString + tabla.FieldByName('nroplan').AsString <> idanter then listLineaAtrazos(idanter, salida);
      detalle.Add(tabla.FieldByName('items').AsString + '/' + Copy(tabla.FieldByName('periodo').AsString, 3, 2));
      socio.getDatos(tabla.FieldByName('idsocio').AsString);
      totales[1] := totales[1] + 1;
      totales[2] := totales[2] + tabla.FieldByName('monto').AsFloat;
      idcat   := tabla.FieldByName('idcategoria').AsString;
      idanter := tabla.FieldByName('idsocio').AsString + tabla.FieldByName('nroplan').AsString;
    end;
    tabla.Next;
  end;

  tabla.IndexFieldNames := 'Periodo;Idsocio;Nroplan;Items';

  listLineaAtrazos(idanter, salida);

  if l then Begin
    if salida <> 'T' then Begin
      list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, 'Total Cobros Atrazados:', 1, 'Arial, negrita, 9', salida, 'N');
      list.Importe(99, list.Lineactual, '', totales[3], 2, 'Arial, negrita, 9');
      list.Linea(99, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
    end else Begin
      list.LineaTxt('', True);
      list.LineaTxt('Total Cobros Atrazados:' + utiles.espacios(66 - (Length('Total Cobros Atrazados:'))), False);
      list.ImporteTxt(totales[3], 12, 2, True);
      list.LineaTxt('', True);
    end;
  end else
    if salida <> 'T' then list.Linea(0, 0, 'No Presenta Cuotas Impagas', 1, 'Arial, normal, 9', salida, 'S') else list.LineaTxt('No Presenta Cuotas Impagas', True);

  if salida = 'T' then list.FinalizarExportacion else list.FinList;
end;

procedure TTCuotas.listLineaAtrazos(xidtitular: String; salida: char);
var
  i, j, k, m, it: Integer;
Begin
  if salida <> 'T' then it := 10 else it := 6;

  if totales[1] > 0 then Begin
    if idanter1 <> xidtitular then Begin
      socio.getDatos(Copy(xidtitular, 1, 6));
      if salida <> 'T' then Begin
        list.Linea(0, 0, Copy(socio.nombre, 1, 20), 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(21, list.Lineactual, idcat, 2, 'Arial, normal, 8', salida, 'N');
      end
        else list.LineaTxt(Copy(socio.Nombre, 1, 27) + utiles.espacios(28 - (Length(TrimRight(Copy(socio.Nombre, 1, 27))))) + ' ' + idcat, False);
    end else
      if salida <> 'T' then list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');// else list.LineaTxt(utiles.espacios(28), False);

    j := 21; k := 2; m := 0;
    for i := 1 to detalle.Count do Begin
      Inc(m);
      if m > it then Begin
        if salida <> 'T' then Begin
          list.Linea(99, list.Lineactual, '', k + 1, 'Arial, normal, 8', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
        end else Begin
          list.LineaTxt('', True);
          list.LineaTxt(utiles.espacios(28), False);
        end;
        j := 21; k := 1; m := 1;
      end;
      j := j + 6;
      k := k + 1;
      if salida <> 'T' then list.Linea(j, list.Lineactual, detalle.Strings[i-1], k, 'Arial, normal, 8', salida, 'N') else list.LineaTxt(detalle.Strings[i-1] + ' ', False);
    end;

    if salida <> 'T' then Begin
      list.importe(92, list.Lineactual, '00', totales[1], k + 1, 'Arial, normal, 8');
      list.importe(99, list.Lineactual, '', totales[2], k + 2, 'Arial, normal, 8');
      list.Linea(99, list.Lineactual, '', k + 3, 'Arial, normal, 8', salida, 'S');
    end else Begin
      list.LineaTxt('  ', False);
      list.importeTxt(totales[1], 2, 0, False);
      list.importeTxt(totales[2], 10, 2, True);
    end;
    totales[3] := totales[3] + totales[2];
    l := True;
    idanter1 := xidtitular;
    //if salida <> 'T' then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S') else list.LineaTxt('', True);
  end;
  detalle.Clear;
  totales[1] := 0;
  totales[2] := 0;
end;

function  TTCuotas.VerificarSiTieneCuotasPagas(xperiodo, xidsocio, xplan: String): Boolean;
// Objetivo...: verificar si tiene cuotas impagas
begin
  Result := False;
  datosdb.Filtrar(tabla, 'periodo = ' + '''' + xperiodo + '''' + ' and idsocio = ' + '''' + xidsocio + '''' + ' and nroplan = ' + '''' + xplan + '''');
  tabla.First;
  while not tabla.Eof do Begin
    if tabla.FieldByName('estado').AsString = 'P' then Begin
      Result := True;
      Break;
    end;
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);
end;

//------------------------------------------------------------------------------

procedure TTCuotas.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  socio.conectar;
  empresa.conectar;
  categoria.conectar;
  ctactebanco.conectar;
  cajaahorrobanco.conectar;
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
end;

procedure TTCuotas.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  socio.desconectar;
  empresa.desconectar;
  categoria.desconectar;
  ctactebanco.desconectar;
  cajaahorrobanco.desconectar;
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function cuota: TTCuotas;
begin
  if xcuota = nil then
    xcuota := TTCuotas.Create;
  Result := xcuota;
end;

{===============================================================================}

initialization

finalization
  xcuota.Free;

end.
