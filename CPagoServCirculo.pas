unit CPagoServCirculo;

interface

uses CSocAdherente, SysUtils, DB, DBTables, CBDT, CIDBFM, CListar, CUtiles, CCatComerciosCirculo, Comercios, Classes, CServers2000_Excel;

const cantitems = 9;

type

TTPagoServicios = class(TObject)            // Superclase
  items, subitems, codsocio, fecha, fepago, concepto, codoper, nrocuotas, tipoServ, Linea1, Linea2, periodo, DC, Debitar, idcategoria, Margen, items1, subitems1, transac, ttiposerv: string;
  coditems, descrip, institucion, dirtel: string;
  importe, porcentaje, porc, saldo, debito, bsas, efectivo, tsaldoanter, MontoFijo, MontoFijoNS: real;
  tserv, tabla, ctrlInf, distPagos, ItemsFijos, correlatividad, tservhist, refitems, transferencias: TTable; r, s: TQuery;
  ExportarDatos, ExisteMovimiento: Boolean;
  Informe: String; Copias, Ruptura, HojasTroq, LineasSep, LineasPag, notafinal, MargenIzq, sepOrdenes: ShortInt;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    getConcepto(xitreg: string): string;

  function    Buscar(xitems, xsubitems: string): boolean;
  procedure   Grabar(xitems, xsubitems, xcodsocio, xOSFA, xfecha, xfepago, xconcepto, xcodoper, xtiposerv, xnrocuotas, xdc: string; ximporte: real);
  procedure   GrabarCredito(xitems, xsubitems, xcodsocio, xOSFA, xfecha, xfepago, xconcepto, xcodoper, xtiposerv, xnrocuotas, xdc: string; ximporte: real);
  procedure   Borrar(xitems, xtipomov, xtipooperacion: string); overload;
  procedure   BorrarItems(xitems, xsubitems: string); overload;
  procedure   getDatos(xitems, xsubitems: string);
  function    NuevoItems: string;
  function    AuditoriaServicios(xfecha: string): TQuery;
  procedure   FiltrarPorSocio(xcodsocio: string);
  procedure   FiltrarPorServicio(xcodser: string);
  procedure   Filtrar;
  procedure   QuitarFiltro;

  procedure   ListarInfSocioPorServicios(xdfecha, xhfecha, xts, xactretiro: String; listSocios: TStringList; discriminaDB: Char; xruptura: Boolean; salida: Char); overload;
  procedure   ListarInfSocioPorServicios(xdfecha, xhfecha, xts, xactretiro: String; listSocios: TStringList; discriminaDB: Char; xruptura: Boolean; salida: Char; xtiempo: Integer); overload;
  procedure   ListarResumenPorSocio(xdfecha, xhfecha, xts, xtiposer, xact_retiro, xsubtitulo: String; xruptura: Boolean; listSocios: TStringList; salida: Char);
  procedure   ListarPorComercio(xdfecha, xhfecha: String; listComercios: TStringList; salida: Char);
  procedure   ListarResumenPorComercio(xdfecha, xhfecha: String; listComercios: TStringList; salida: Char);
  procedure   ListarResumenCatPorComercio(xdfecha, xhfecha: String; listComercios: TStringList; salida: Char);
  procedure   ListarInfSocioTabular(xdfecha, xhfecha, xosfa: String; listSocios: TStringList; salida: Char);
  procedure   ListarControlesDiarios(xdfecha, xhfecha: String; salida: Char);
  procedure   ListarSaldosAdeudados(xdfecha, xhfecha: String; listSocios: TStringList; salida: char);
  procedure   ListarTotalesPorCategorias(xdfecha, xhfecha: String; listCategorias: TStringList; salida: char);

  procedure   GrabarItems(xcoditems, xdescrip, xdebitar, xidcategoria: string; xporcentaje, xmontoFijo, xmontoFijoNs: real);
  procedure   BorrarItems(xcoditems: string); overload;
  function    BuscarItems(xcoditems: string): boolean;
  function    Nuevo: string;
  procedure   getDatosItems(xcoditems: string);
  procedure   ListarItems(orden, iniciar, finalizar, ent_excl: string; salida: char);
  function    setItemsReg: TQuery;
  function    setComercios: TQuery;
  function    setItemsMontoFijo: TQuery;
  function    setSociosConMovimientos(xdfecha, xhfecha: String): TQuery;
  function    setSociosConMovimientos_EnActividad(xdfecha, xhfecha: String): TQuery;
  function    setSociosConMovimientos_Retirados(xdfecha, xhfecha: String): TQuery;
  function    setMontoServicios(xdf, xhf, xcodsocio: String): Real;
  function    setMontoPagado: Real;
  procedure   EstablecerSaldo(xitems, xsubitems, xcodsocio, xosfa, xfecha, xfepago, xtipomov, xtiposerv, xconcepto: String; ximporte, xpago: Real);
  function    setMovimientosCancelaciones(xcodmov, xdesdeitems, xhastaitems: String): TQuery;

  function    setOperacionesSocio(xcodsocio: String): TQuery;
  function    setOperacionesFecha(xdfecha, xhfecha: String): TQuery;
  function    setOperacionesComercio(xitems: String): TQuery;

  procedure   CambiarNumeroOSFA(xcodsocio, xosfa: String);

  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorDescrip(xexpr: string);

  procedure   GuardarConfigInforme(xInforme: String; xCopias, xLineasImp, xRuptura, xHojasTroq, xLineasSep, xNotaFinal: ShortInt);
  procedure   getDatosInf(xinforme: String);

  procedure   Exportar(xarchivo: String);
  procedure   ExportarExcel2000;

  function    setConsumoMes(xcodsocio, xfecha: String): Real;
  function    setConsumoMesPenias(xcodsocio, xfecha: String): Real;

  function    setDatosDepurar(xfecha: String): TQuery;
  procedure   DepurarOrden(xitems, xsubitems, xfecha: String);

  procedure   ImprimirOrden(xitems: String);

  procedure   FijarImputacionFija(xid, xitems: String);
  function    ItemsFijoGastos(xid: String): String;
  function    setMontoFijo(xcod: String): Real;
  function    setMontoFijoNS(xcod: String): Real;

  function    setNumeroSiguiente(xidcor: String): String;
  procedure   RegistrarNumeroCorrelativo(xidcor, xnumero, xmargen: String; xforzarNro: Boolean);
  function    verificarSiLaOrdenEstaImpresa(xitems: String): Boolean;

  function    verificarItems(xitems, xsubitems, xtipomov: String): Boolean;
  function    BorrarCredito(xitems, xsubitems, xtipomov: String): Boolean;

  function    verificarSiElSocioTieneOperaciones(xcodsocio: String): Boolean;
  procedure   EstablecerTiempoConsulta(xtiempo: Integer);

  function    setMontoTotalConsumido(xdfecha, xhfecha, xcodsocio: String): Real;
  function    setSaldoMes(xdfecha, xhfecha, xcodsocio: String): Real;

  function    BuscarReferencia(xitems, xsubitems: String): Boolean;
  procedure   RegistrarReferencia(xitems, xsubitems, xitems1, xsubitems1: String);
  procedure   BorrarReferencia(xitems, xsubitems: String);
  procedure   getDatosReferencia(xitems, xsubitems: String);

  function    BuscarTransferencia(xperiodo, xcodsocio: String): Boolean;
  procedure   RegistrarTransferencia(xperiodo, xcodsocio, xtransac, xtiposerv: String);
  procedure   BorrarTransferencia(xperiodo, xcodsocio: String);
  procedure   getDatosTransferencia(xperiodo, xcodsocio: String);

  procedure   conectar;
  procedure   desconectar;
  procedure   ConectarHistorico;
  procedure   desConectarHistorico;
 private
  { Declaraciones Privadas }
  ting, tegr, total: real; i: integer; idanter, idanter1: string; lineas: ShortInt; lin, chr15, chr18, ffila: String;
  totales: array[1..cantitems] of real;
  conexiones: shortint; ExistenDatos: Boolean; pag, fila: Integer;
  rsql: TQuery; listardatos, tt, existmov: Boolean;
  recargos: Real;
  procedure   ListarPorSocio(xdfecha, xhfecha, xosfa, xcodsocio, xts, xactretiro: String; discriminaDB: Char; xruptura: Boolean; salida: Char);
  procedure   IniciarListado(salida: char);
  procedure   Titulo(salida: char; t: string);
  procedure   ListLineaItems(salida: char);
  procedure   ListarLineaServicios(xts, xactretiro: String; xruptura: Boolean; salida: Char); overload;
  procedure   ListarLineaServicios(xts, xactretiro, xtiposerv: String; xruptura: Boolean; salida: Char); overload;

  procedure   ListarTotalSocio(xtiposer: String; xruptura: Boolean; salida: Char);

  procedure   ListarLineaComercio(salida: Char);
  procedure   SubtotalSocio(xleyenda: String; xting: Real; xruptura: Boolean; salida: Char);
  procedure   RupturaSocios(xtiposerv: String; salida: Char);
  procedure   SubtotalComercio(salida: Char);
  procedure   LineaSocioTab(salida: char);
  procedure   LineaCategorias(xdfecha, xhfecha, xidcategoria: String; salida: Char);

  procedure   ListTotalComercio(salida: char);

  procedure   ImprimirNotaFinal(salida: char);
  procedure   DetalleDebitos(xdfecha, xhfecha: String; listComercios: TStringList; salida: char);
  procedure   TotalCategoria(salida: char);
  procedure   ListLineaCatComercio(salida: Char);

  procedure   ListLineaCat(xidanter: String; salida: Char);

  procedure   IniciarArreglos;

  { Gestion para Impresiones en Modo Texto }
  function    ControlarSalto: Boolean;
  procedure   Titulo1;
  procedure   Titulo2(xtiposer: String);
  procedure   Titulo3;
  procedure   Titulo4;
  procedure   Titulo5;
  procedure   Titulo6(xdfecha, xhfecha: String);
  procedure   Titulo7;
  procedure   Titulo8;
  procedure   ListarOrden(xitems, xform: String);
end;

function pagoserv: TTPagoServicios;

implementation

var
  xpagoserv: TTPagoServicios = nil;

constructor TTPagoServicios.Create;
begin
  inherited Create;
  tserv          := datosdb.openDB('serviciosCirculo', 'Items;Subitems');
  tabla          := datosdb.openDB('comercios', 'coditems');
  ctrlInf        := datosdb.openDB('ctrlInformes', '');
  distPagos      := datosdb.openDB('distPagos', '');
  ItemsFijos     := datosdb.openDB('ItemsFijos', '');
  correlatividad := datosdb.openDB('correlatividad', '');
  tservhist      := datosdb.openDB('serviciosCirculoHistorico', '');
  refitems       := datosdb.openDB('refitems', '');
  transferencias := datosdb.openDB('transferencias', '');
  LineasPag      := 65;
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

procedure TTPagoServicios.Grabar(xitems, xsubitems, xcodsocio, xOSFA, xfecha, xfepago, xconcepto, xcodoper, xtiposerv, xnrocuotas, xdc: string; ximporte: real);
// Objetivo...: Guardar atributos del objeto en tserv de Persistencia
var
  subit: String; Nuevo: Boolean;
begin
  tserv.Filtered := False; Nuevo := False;
  subit := xsubitems;
  if (xsubitems < '30') or (xsubitems > '49') then
    if xdc <> '1' then subit := xsubitems else subit := '00';

  if (xsubitems = '30') and (xdc = '1') then subit := '00';

  if Buscar(xitems, subit) then tserv.Edit else Begin
    tserv.Append;
    Nuevo := True;
  end;
  tserv.FieldByName('items').AsString     := xitems;
  tserv.FieldByName('subitems').AsString  := subit;
  tserv.FieldByName('codsocio').AsString  := xcodsocio;
  tserv.FieldByName('osfa').AsString      := xOSFA;
  tserv.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  tserv.FieldByName('fepago').AsString    := utiles.sExprFecha2000(xfepago);
  tserv.FieldByName('concepto').AsString  := xconcepto;
  tserv.FieldByName('codoper').AsString   := xcodoper;
  tserv.FieldByName('importe').AsFloat    := ximporte;
  tserv.FieldByName('tiposerv').AsString  := xtiposerv;
  tserv.FieldByName('nrocuotas').AsString := xnrocuotas;
  tserv.FieldByName('tipomov').AsString   := xdc;
  if Nuevo then tserv.FieldByName('fechareg').AsString := utiles.sExprFecha2000(utiles.setFechaActual);
  try
    tserv.Post;
  except
    tserv.Cancel
  end;
  tserv.Filtered := True;
  datosdb.closeDB(tserv); tserv.Open;
  ExisteMovimiento := False;
end;

procedure TTPagoServicios.GrabarCredito(xitems, xsubitems, xcodsocio, xOSFA, xfecha, xfepago, xconcepto, xcodoper, xtiposerv, xnrocuotas, xdc: string; ximporte: real);
// Objetivo...: Guardar atributos del objeto en tserv de Persistencia
var
  Nuevo: Boolean;
begin
  tserv.Filtered := False;
  if Buscar(xitems, xsubitems) then tserv.Edit else Begin
    tserv.Append;
    Nuevo := True;
  end;
  tserv.FieldByName('items').AsString     := xitems;
  tserv.FieldByName('subitems').AsString  := xsubitems;
  tserv.FieldByName('codsocio').AsString  := xcodsocio;
  tserv.FieldByName('osfa').AsString      := xOSFA;
  tserv.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  tserv.FieldByName('fepago').AsString    := utiles.sExprFecha2000(xfepago);
  tserv.FieldByName('concepto').AsString  := xconcepto;
  tserv.FieldByName('codoper').AsString   := xcodoper;
  tserv.FieldByName('importe').AsFloat    := ximporte;
  tserv.FieldByName('tiposerv').AsString  := xtiposerv;
  tserv.FieldByName('nrocuotas').AsString := xnrocuotas;
  tserv.FieldByName('tipomov').AsString   := xdc;
  if Nuevo then tserv.FieldByName('fechareg').AsString := utiles.sExprFecha2000(utiles.setFechaActual);
  try
    tserv.Post;
  except
    tserv.Cancel
  end;
  tserv.Filtered := True;
  datosdb.closeDB(tserv); tserv.Open;
end;

procedure TTPagoServicios.Borrar(xitems, xtipomov, xtipooperacion: string);
// Objetivo...: Eliminar un Objeto
begin
  tserv.Filtered := False;
  if xtipooperacion = 'Orden' then Begin
    datosdb.tranSQL('DELETE FROM serviciosCirculo WHERE items = ' + '"' + xitems + '"' + ' AND tipomov = ' + '"' + xtipomov + '"' + ' and subitems < ' + '"' + '30' + '"');
    datosdb.tranSQL('DELETE FROM serviciosCirculo WHERE items = ' + '"' + xitems + '"' + ' AND tipomov = ' + '"' + xtipomov + '"' + ' and subitems = ' + '"' + '50' + '"');
  end;
  if xtipooperacion = 'Otras' then Begin
    datosdb.tranSQL('DELETE FROM serviciosCirculo WHERE items = ' + '"' + xitems + '"' + ' AND tipomov = ' + '"' + xtipomov + '"' + ' and subitems >= ' + '"' + '30' + '"' + ' and subitems < ' + '"' + '50' + '"');
    datosdb.tranSQL('DELETE FROM serviciosCirculo WHERE items = ' + '"' + xitems + '"' + ' AND tipomov = ' + '"' + xtipomov + '"' + ' and subitems = ' + '"' + '00' + '"');
  end;
  if xtipooperacion = 'Otras-Imput' then Begin
    datosdb.tranSQL('DELETE FROM serviciosCirculo WHERE items = ' + '"' + xitems + '"' + ' AND tipomov = ' + '"' + xtipomov + '"');
    datosdb.tranSQL('DELETE FROM serviciosCirculo WHERE items = ' + '"' + xitems + '"' + ' AND tipomov = ' + '"' + xtipomov + '"');
  end;
  datosdb.refrescar(tserv);
  tserv.Filtered := True;
  getDatos(tserv.FieldByName('items').AsString, tserv.FieldByName('subitems').AsString);
  if datosdb.Buscar(distpagos, 'Items', 'Subitems', xitems, '-0') then distpagos.Delete;
end;

procedure TTPagoServicios.BorrarItems(xitems, xsubitems: string);
// Objetivo...: Eliminar un Objeto
var
  f: Boolean;
begin
  f              := tserv.Filtered;
  tserv.Filtered := False;
  if Buscar(xitems, xsubitems) then Begin
    tserv.Delete;
    datosdb.refrescar(tserv);
  end;
  tserv.Filtered := f;
end;

function TTPagoServicios.Buscar(xitems, xsubitems: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  ExisteMovimiento := datosdb.Buscar(tserv, 'items', 'subitems', xitems, xsubitems);
  Result := ExisteMovimiento;
end;

procedure  TTPagoServicios.getDatos(xitems, xsubitems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xitems, xsubitems) then Begin
    items     := tserv.FieldByName('items').AsString;
    subitems  := tserv.FieldByName('subitems').AsString;
    codsocio  := tserv.FieldByName('codsocio').AsString;
    fecha     := utiles.sFormatoFecha(tserv.FieldByName('fecha').AsString);
    fepago    := utiles.sFormatoFecha(tserv.FieldByName('fepago').AsString);
    concepto  := tserv.FieldByName('concepto').AsString;
    codoper   := tserv.FieldByName('codoper').AsString;
    nrocuotas := tserv.FieldByName('nrocuotas').AsString;
    importe   := tserv.FieldByName('importe').AsFloat;
    tipoServ  := tserv.FieldByName('tipoServ').AsString;
    DC        := tserv.FieldByName('tipomov').AsString;
  end else Begin
    items := ''; codsocio := ''; fecha := ''; fepago := ''; concepto := ''; importe := 0; codoper := ''; nrocuotas := '1'; subitems := '01'; tipoServ := ''; DC := '2';
  end;
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
  list.Setear(salida);
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
  while not tserv.BOF do Begin
    if (Length(Trim(tserv.FieldByName('items').AsString)) > 0) and (tserv.FieldByName('tipomov').AsString = '2') then i := tserv.FieldByName('items').AsInteger;
    if tserv.FieldByName('subitems').AsString > '00' then Break;
    tserv.Prior;
  end;
  Inc(i); Result := IntToStr(i);
  if f then tserv.Filtered := True;
end;

function TTPagoServicios.AuditoriaServicios(xfecha: string): TQuery;
// Objetivo...: devolver un set con los servicios pagados en un día
begin
  Result := datosdb.tranSQL('SELECT servicios.codsocio, servicios.fecha, servicios.pdfecha, servicios.phfecha, servicios.concepto, servicios.importe, socios.nombre FROM servicios, socios WHERE ' +
                            ' servicios.codsocio = socios.codsocio AND fecha = ' + '''' + xfecha + '''');
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

procedure TTPagoServicios.Filtrar;
// Objetivo...: Filtrar
begin
  datosdb.Filtrar(tserv, 'tipomov = 2');
end;

{ **************************************************************************** }
// Gestión de Informes
{ **************************************************************************** }

function TTPagoServicios.ControlarSalto: boolean;
// Objetivo...: salto de linea para las impresiones basadas en texto
var
  i: Integer;
begin
  Result := False;
  if not ExportarDatos then Begin
    if lineas > LineasPag then Begin
      if LineasSep > 0 then
        For i := 1 to LineasSep do list.LineaTxt('  ', True)
      else
        list.LineaTxt(CHR(12), True);
      Result := True;
    end;
  end;
end;

procedure TTPagoServicios.ListarPorSocio(xdfecha, xhfecha, xosfa, xcodsocio, xts, xactretiro: String; discriminaDB: Char; xruptura: Boolean; salida: Char);
var
  recargo: Real;
begin
  ting := 0; total := 0; saldo := 0; debito := 0; bsas := 0; idanter := ''; idanter1 := ''; ExistenDatos := False;
  datosdb.Filtrar(rsql, 'codsocio = ' + xcodsocio);
  rsql.First;
  if discriminaDB = '0' then Begin
    while not rsql.EOF do Begin
      if rsql.FieldByName('tipomov').AsInteger =  1 then
        if Buscar(rsql.FieldByName('items').AsString, '50') then recargo := tserv.FieldByName('importe').AsFloat else recargo := 0;
      if rsql.FieldByName('tipomov').AsInteger = 1 then saldo := saldo + rsql.FieldByName('importe').AsFloat else saldo := saldo - rsql.FieldByName('importe').AsFloat;
      if Length(Trim(xosfa)) = 0 then if (rsql.FieldByName('fepago').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fepago').AsString <= utiles.sExprFecha2000(xhfecha)) and (Copy(rsql.FieldByName('subitems').AsString, 1, 1) <> '-') then ListarLineaServicios(xts, xactretiro, xruptura, salida);
      if Length(Trim(xosfa)) > 0 then if (rsql.FieldByName('fepago').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fepago').AsString <= utiles.sExprFecha2000(xhfecha)) and (Copy(rsql.FieldByName('subitems').AsString, 1, 1) <> '-') and (Trim(rsql.FieldByName('osfa').AsString) = Trim(xosfa)) then ListarLineaServicios(xts, xactretiro, xruptura, salida);
      if Length(Trim(xosfa)) = 0 then if (rsql.FieldByName('fepago').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fepago').AsString <= utiles.sExprFecha2000(xhfecha)) and (Copy(rsql.FieldByName('subitems').AsString, 1, 1) = '-') then debito := debito + rsql.FieldByName('importe').AsFloat;
      if Length(Trim(xosfa)) > 0 then if (rsql.FieldByName('fepago').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fepago').AsString <= utiles.sExprFecha2000(xhfecha)) and (Copy(rsql.FieldByName('subitems').AsString, 1, 1) = '-') and (Trim(rsql.FieldByName('osfa').AsString) = Trim(xosfa)) then Begin
        debito := debito + (rsql.FieldByName('importe').AsFloat + recargo);
        bsas   := bsas   + rsql.FieldByName('importe').AsFloat;
      end;
      rsql.Next;
    end;
  end else Begin
    rsql.First; ting := 0; debito := 0;
    if (discriminaDB = '1') or (discriminaDB = '2') then Begin  // Debito Automatico
      while not rsql.EOF do Begin
        if Length(Trim(xosfa)) = 0 then if (rsql.FieldByName('fepago').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fepago').AsString <= utiles.sExprFecha2000(xhfecha)) and (rsql.FieldByName('tiposerv').AsString = 'D') and (Copy(rsql.FieldByName('subitems').AsString, 1, 1) <> '-') then ListarLineaServicios(xts, xactretiro, 'D', xruptura, salida);
        if Length(Trim(xosfa)) > 0 then if (rsql.FieldByName('fepago').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fepago').AsString <= utiles.sExprFecha2000(xhfecha)) and (rsql.FieldByName('osfa').AsString = xosfa) and (rsql.FieldByName('tiposerv').AsString = 'D') and (Copy(rsql.FieldByName('subitems').AsString, 1, 1) <> '-') then ListarLineaServicios(xts, xactretiro, 'D', xruptura, salida);
        if Length(Trim(xosfa)) > 0 then if (rsql.FieldByName('fepago').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fepago').AsString <= utiles.sExprFecha2000(xhfecha)) and (Copy(rsql.FieldByName('subitems').AsString, 1, 1) = '-') and (Trim(rsql.FieldByName('osfa').AsString) = Trim(xosfa)) then Begin
          debito := debito + (rsql.FieldByName('importe').AsFloat + recargo);
          if rsql.FieldByName('tiposerv').AsString = 'D' then bsas   := bsas + (rsql.FieldByName('importe').AsFloat + recargo);
        end;
        if rsql.FieldByName('tiposerv').AsString = 'Z' then
          if Buscar(rsql.FieldByName('items').AsString, '01') then
             if tserv.FieldByName('tiposerv').AsString = 'D' then ListarLineaServicios(xts, xactretiro, 'B', xruptura, salida);
        rsql.Next;
      end;

      rsql.First; ting := 0; debito := 0;   // Buenos Aires
      while not rsql.EOF do Begin
        if Length(Trim(xosfa)) = 0 then if (rsql.FieldByName('fepago').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fepago').AsString <= utiles.sExprFecha2000(xhfecha)) and (rsql.FieldByName('tiposerv').AsString = 'B') and (Copy(rsql.FieldByName('subitems').AsString, 1, 1) <> '-') then ListarLineaServicios(xts, xactretiro, 'B', xruptura, salida);
        if Length(Trim(xosfa)) > 0 then if (rsql.FieldByName('fepago').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fepago').AsString <= utiles.sExprFecha2000(xhfecha)) and (rsql.FieldByName('osfa').AsString = xosfa) and (rsql.FieldByName('tiposerv').AsString = 'B') and (Copy(rsql.FieldByName('subitems').AsString, 1, 1) <> '-') then ListarLineaServicios(xts, xactretiro, 'B', xruptura, salida);
        if Length(Trim(xosfa)) > 0 then if (rsql.FieldByName('fepago').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fepago').AsString <= utiles.sExprFecha2000(xhfecha)) and (Copy(rsql.FieldByName('subitems').AsString, 1, 1) = '-') and (Trim(rsql.FieldByName('osfa').AsString) = Trim(xosfa)) then Begin
          debito := debito + (rsql.FieldByName('importe').AsFloat + recargo);
          if rsql.FieldByName('tiposerv').AsString = 'B' then bsas := bsas + (rsql.FieldByName('importe').AsFloat + recargo);
        end;
        if rsql.FieldByName('tiposerv').AsString = 'Z' then
          if Buscar(rsql.FieldByName('items').AsString, '01') then
            if tserv.FieldByName('tiposerv').AsString = 'B' then ListarLineaServicios(xts, xactretiro, 'B', xruptura, salida);
        rsql.Next;
      end;

      if (discriminaDB = '2') then Begin
        rsql.First; ting := 0; debito := 0;  // Ninguno
        while not rsql.EOF do Begin
          if Length(Trim(xosfa)) = 0 then if (rsql.FieldByName('fepago').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fepago').AsString <= utiles.sExprFecha2000(xhfecha)) and (rsql.FieldByName('tiposerv').AsString = 'N') and (Copy(rsql.FieldByName('subitems').AsString, 1, 1) <> '-') then ListarLineaServicios(xts, xactretiro, 'N', xruptura, salida);
          if Length(Trim(xosfa)) > 0 then if (rsql.FieldByName('fepago').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fepago').AsString <= utiles.sExprFecha2000(xhfecha)) and (rsql.FieldByName('osfa').AsString = xosfa) and (rsql.FieldByName('tiposerv').AsString = 'N') and (Copy(rsql.FieldByName('subitems').AsString, 1, 1) <> '-') then ListarLineaServicios(xts, xactretiro, 'N', xruptura, salida);
          if Length(Trim(xosfa)) > 0 then if (rsql.FieldByName('fepago').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fepago').AsString <= utiles.sExprFecha2000(xhfecha)) and (Copy(rsql.FieldByName('subitems').AsString, 1, 1) = '-') and (Trim(rsql.FieldByName('osfa').AsString) = Trim(xosfa)) then Begin
            debito := debito + (rsql.FieldByName('importe').AsFloat + recargo);
            if rsql.FieldByName('tiposerv').AsString = 'N' then bsas   := bsas   + (rsql.FieldByName('importe').AsFloat + recargo);
          end;
          if rsql.FieldByName('tiposerv').AsString = 'Z' then
           if Buscar(rsql.FieldByName('items').AsString, '01') then
             if tserv.FieldByName('tiposerv').AsString = 'N' then ListarLineaServicios(xts, xactretiro, 'B', xruptura, salida);
         rsql.Next;
        end;
      end;

    end;
  end;

  rsql.Filtered := False;

  if discriminaDB = '0' then SubtotalSocio('TOTAL:', ting, xruptura, salida) else SubtotalSocio('TOTAL:', total, xruptura, salida);
end;

procedure TTPagoServicios.ListarLineaServicios(xts, xactretiro: String; xruptura: Boolean; salida: Char);
var
  l: Boolean;
  subit: String;
begin
  socioadherente.getDatos(rsql.FieldByName('codsocio').AsString);
  l := False;
  if Length(Trim(xts)) = 0 then l := True else
    if rsql.FieldByName('tiposerv').AsString = xts then l := True;
  if l then
    if Length(Trim(xactretiro)) = 0 then l := True else
      if socioadherente.actretiro = xactretiro then l := True;

  if l then Begin
    if rsql.FieldByName('osfa').AsString <> idanter then Begin
      if ting > 0 then Begin
        SubtotalSocio('Subtotal:', ting, xruptura, salida);
        if xruptura then ImprimirNotaFinal(salida);
      end;

      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, 'Socio: ' + socioadherente.OSFA + '  ' + socioadherente.nombre, 1, 'Arial, negrita, 9', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      end;
      if salida = 'T' then Begin
        list.LineaTxt(CHR(18) + 'Socio: ' + socioadherente.OSFA + '  ' + socioadherente.nombre, True); if ControlarSalto then titulo1; Inc(lineas);
        list.LineaTxt(CHR(15), True); if ControlarSalto then titulo1; Inc(lineas);
      end;
      if salida = 'X' then Begin
        Inc(fila); ffila := IntToStr(fila);
        excel.setString('A' + ffila, 'A' + ffila, 'Socio: ' + socioadherente.OSFA + '  ' + socioadherente.nombre, 'Arial, negrita, 9');
      end;
    end;

    getDatosItems(rsql.FieldByName('codoper').AsString);
    if (rsql.FieldByName('subitems').AsString < '30') or (rsql.FieldByName('subitems').AsString = '50') then subit := rsql.FieldByName('subitems').AsString else
      subit := utiles.sLlenarIzquierda(IntToStr(rsql.FieldByName('subitems').AsInteger - 29), 2, '0');
    if (rsql.FieldByName('subitems').AsString > '50') then subit := utiles.sLlenarIzquierda(IntToStr(rsql.FieldByName('subitems').AsInteger - 54), 2, '0');
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, rsql.FieldByName('items').AsString + '  ' + utiles.sFormatoFecha(rsql.FieldByName('fecha').AsString) + '  ' + utiles.sFormatoFecha(rsql.FieldByName('fepago').AsString) + '  ' + subit + '-' + utiles.sLLenarIzquierda(rsql.FieldByName('nrocuotas').AsString, 2, '0') + '  ' + Descrip, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(60, list.Lineactual, rsql.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
      if rsql.FieldByName('tipomov').AsInteger = 2 then list.importe(95, list.Lineactual, '', rsql.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8') else list.importe(95, list.Lineactual, '', rsql.FieldByName('importe').AsFloat * (-1), 3, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
    end;
    if salida = 'T' then Begin
      list.LineaTxt(rsql.FieldByName('items').AsString + '  ' + utiles.sFormatoFecha(rsql.FieldByName('fecha').AsString) + '  ' + utiles.sFormatoFecha(rsql.FieldByName('fepago').AsString) + '  ' + subit + '-' + utiles.sLLenarIzquierda(rsql.FieldByName('nrocuotas').AsString, 2, '0') + ' ' + Descrip + utiles.espacios(30 - Length(TrimRight(descrip))) + '  ' + rsql.FieldByName('concepto').AsString + utiles.espacios(50 - Length(TrimRight(rsql.FieldByName('concepto').AsString))), False);
      if rsql.FieldByName('tipomov').AsInteger = 2 then list.ImporteTxt(rsql.FieldByName('importe').AsFloat, 12, 2, True) else list.ImporteTxt(rsql.FieldByName('importe').AsFloat * (-1), 12, 2, True); if controlarSalto then Titulo1; Inc(lineas);
    end;
    if salida = 'X' then Begin
      Inc(fila); ffila := IntToStr(fila);
      excel.setString('A' + ffila, 'A' + ffila, rsql.FieldByName('codoper').AsString, 'Arial, normal, 8');
      excel.setString('B' + ffila, 'C' + ffila, '''' + subit + '-' + utiles.sLLenarIzquierda(rsql.FieldByName('nrocuotas').AsString, 2, '0'), 'Arial, normal, 8');
      excel.setString('C' + ffila, 'C' + ffila, Descrip, 'Arial, normal, 8');
      excel.setReal('D' + ffila, 'D' + ffila, rsql.FieldByName('importe').AsFloat, 'Arial, normal, 8');
    end;
    idanter := rsql.FieldByName('osfa').AsString;
    if rsql.FieldByName('tipomov').AsString = '2' then ting := ting  + rsql.FieldByName('importe').AsFloat else ting := ting - rsql.FieldByName('importe').AsFloat;
    ExistenDatos := True;
  end;
end;

procedure TTPagoServicios.ListarLineaServicios(xts, xactretiro, xtiposerv: String; xruptura: Boolean; salida: Char);
var
  l: Boolean;
  subit: String;
begin
  if xtiposerv = 'D' then listardatos := True;
  socioadherente.getDatos(rsql.FieldByName('codsocio').AsString);

  l := False;
  if Length(Trim(xts)) = 0 then l := True else
    if rsql.FieldByName('tiposerv').AsString = xts then l := True;
  if l then
    if Length(Trim(xactretiro)) = 0 then l := True else
      if socioadherente.actretiro = xactretiro then l := True;

  if l then Begin
    if rsql.FieldByName('osfa').AsString <> idanter then Begin
      if ting > 0 then Begin
        SubtotalSocio('Subtotal:', ting, xruptura, salida);
      end;
      if salida <> 'T' then Begin
        list.Linea(0, 0, 'Socio: ' + socioadherente.OSFA + '  ' + socioadherente.nombre, 1, 'Arial, negrita, 12', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      end else Begin
        list.LineaTxt(CHR(18) + 'Socio: ' + socioadherente.OSFA + '  ' + socioadherente.nombre + CHR(15), True); if ControlarSalto then titulo1; Inc(lineas);
      end;
    end;

    if (ting = 0) and (rsql.FieldByName('tiposerv').AsString <> idanter1) then RupturaSocios(xtiposerv, salida);

    getDatosItems(rsql.FieldByName('codoper').AsString);
    if (rsql.FieldByName('subitems').AsString < '30') or (rsql.FieldByName('subitems').AsString = '50') then subit := rsql.FieldByName('subitems').AsString else
      subit := utiles.sLlenarIzquierda(IntToStr(rsql.FieldByName('subitems').AsInteger - 29), 2, '0');
    if (rsql.FieldByName('subitems').AsString > '50') then subit := utiles.sLlenarIzquierda(IntToStr(rsql.FieldByName('subitems').AsInteger - 54), 2, '0');
    if salida <> 'T' then Begin
      list.Linea(0, 0, rsql.FieldByName('items').AsString + '  ' + utiles.sFormatoFecha(rsql.FieldByName('fecha').AsString) + '  ' + utiles.sFormatoFecha(rsql.FieldByName('fepago').AsString) + '  ' + subit + '-' + utiles.sLLenarIzquierda(rsql.FieldByName('nrocuotas').AsString, 2, '0') + '  ' + Descrip, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(60, list.Lineactual, rsql.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
      if xtiposerv <> 'D' then Begin
        if rsql.FieldByName('tipomov').AsString = '2' then list.importe(95, list.Lineactual, '', rsql.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8') else list.importe(95, list.Lineactual, '', rsql.FieldByName('importe').AsFloat * (-1), 3, 'Arial, normal, 8');
      end else
        list.importe(95, list.Lineactual, '', 0, 3, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
    end else Begin
      list.LineaTxt(rsql.FieldByName('items').AsString + '  ' + utiles.sFormatoFecha(rsql.FieldByName('fecha').AsString) + '  ' + utiles.sFormatoFecha(rsql.FieldByName('fepago').AsString) + '  ' + subit + '-' + utiles.sLLenarIzquierda(rsql.FieldByName('nrocuotas').AsString, 2, '0') + ' ' + Descrip + utiles.espacios(30 - Length(TrimRight(descrip))) + '  ' + rsql.FieldByName('concepto').AsString + utiles.espacios(50 - Length(TrimRight(rsql.FieldByName('concepto').AsString))), False);
      if xtiposerv <> 'D' then Begin
        if rsql.FieldByName('tipomov').AsString = '2' then list.ImporteTxt(rsql.FieldByName('importe').AsFloat, 12, 2, True) else list.ImporteTxt(rsql.FieldByName('importe').AsFloat * (-1), 12, 2, True);
      end else
        list.ImporteTxt(0, 12, 2, True);
      if controlarSalto then Titulo1; Inc(lineas);
    end;
    idanter := rsql.FieldByName('osfa').AsString;
    if xtiposerv <> 'D' then Begin
      if rsql.FieldByName('tipomov').AsString = '2' then ting := ting  + rsql.FieldByName('importe').AsFloat else ting := ting - rsql.FieldByName('importe').AsFloat;
      if rsql.FieldByName('tipomov').AsString = '2' then total := total + rsql.FieldByName('importe').AsFloat else total := total  - rsql.FieldByName('importe').AsFloat;
    end;

    idanter1 := rsql.FieldByName('tiposerv').AsString;
    ExistenDatos := True;
  end;
end;

procedure TTPagoServicios.RupturaSocios(xtiposerv: String; salida: Char);
begin
  if (ting = 0) and (xtiposerv = 'D') then
  if salida <> 'T' then Begin
    list.Linea(0, 0, 'Pago Anticipado', 1, 'Arial, negrita, 10', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  end else Begin
    list.LineaTxt(CHR(18) + ' ', True);  if ControlarSalto then titulo1; Inc(lineas);
    list.LineaTxt(CHR(18) + 'Pago Anticipado' + CHR(15), True);  if ControlarSalto then titulo1; Inc(lineas);
  end;
  if (ting = 0) and (xtiposerv = 'B') then
  if salida <> 'T' then Begin
    list.Linea(0, 0, 'Buenos Aires', 1, 'Arial, negrita, 10', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  end else Begin
    list.LineaTxt(CHR(18) + ' ', True);  if ControlarSalto then titulo1; Inc(lineas);
    list.LineaTxt(CHR(18) + 'Buenos Aires' + CHR(15), True); if ControlarSalto then titulo1; Inc(lineas);
  end;
  if (ting = 0) and (xtiposerv = 'N') then
  if salida <> 'T' then Begin
    list.Linea(0, 0, 'Efectivo Circulo', 1, 'Arial, negrita, 10', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  end else Begin
    list.LineaTxt(CHR(18) + ' ', True);  if ControlarSalto then titulo1; Inc(lineas);
    list.LineaTxt(CHR(18) + 'Efectivo Circulo' + CHR(15), True); if ControlarSalto then titulo1; Inc(lineas);
  end;
end;

procedure TTPagoServicios.SubtotalSocio(xleyenda: String; xting: real; xruptura: Boolean; salida: Char);
begin
  if (xting >= 0) or (listardatos) then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(22, list.Lineactual, '', xting, 2, 'Arial, negrita, 9');
      list.Linea(30, list.Lineactual, 'Saldo Ant.:', 3, 'Arial, negrita, 9', salida, 'N');
      if xleyenda <> 'TOTAL:' then list.importe(53, list.Lineactual, '', debito, 4, 'Arial, negrita, 9') else list.importe(53, list.Lineactual, '', bsas, 4, 'Arial, negrita, 9');
      list.Linea(70, list.Lineactual, 'Tot. Adeudado:', 5, 'Arial, negrita, 9', salida, 'N');
      if xleyenda <> 'TOTAL:' then list.importe(95, list.Lineactual, '', xting + debito, 6, 'Arial, negrita, 9') else list.importe(95, list.Lineactual, '', xting + bsas + recargos, 6, 'Arial, negrita, 9');
      list.Linea(96, list.lineactual, ' ', 7, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
    end;
    if salida = 'T' then Begin
      list.LineaTxt(' ', True); if ControlarSalto then titulo1; Inc(lineas);
      list.LineaTxt(CHR(18) + 'Subtotal: ', False);
      list.ImporteTxt(xting, 12, 2, False);
      list.LineaTxt('   Saldo Ant.: ', False);
      if xleyenda <> 'TOTAL:' then list.ImporteTxt(debito, 12, 2, False) else list.ImporteTxt(bsas, 12, 2, False);
      list.LineaTxt('   Total Adeudado: ', False);
      if xleyenda <> 'TOTAL:' then list.ImporteTxt(xting + debito, 12, 2, True) else list.ImporteTxt(xting + bsas + recargos, 12, 2, True); if ControlarSalto then titulo1; Inc(lineas);
      list.LineaTxt(CHR(18) + utiles.sLlenarIzquierda(lin, 80, '-'), True); if ControlarSalto then titulo1; Inc(lineas);
    end;
    if (salida = 'X') and (xting + debito > 0) then Begin
      Inc(fila); ffila := IntToStr(fila);
      excel.setString('C' + ffila, 'C' + ffila, 'Total Adeudado:', 'Arial, negrita, 9');
      excel.setReal('D' + ffila, 'D' + ffila, xting + debito, 'Arial, negrita, 9');
      Inc(fila);
    end;
  end;

  ting := 0; debito := 0; recargos := 0; listardatos := False;
end;

procedure TTPagoServicios.Titulo1;
begin
  Inc(pag);
  list.LineaTxt(CHR(18), True);
  list.LineaTxt(institucion + utiles.espacios(70 - Length(TrimRight(institucion))) +  'Hoja ' + utiles.sLlenarIzquierda(IntToStr(pag), 4, '0'), True);
  list.LineaTxt(dirtel, True);
  list.LineaTxt('Informe de Operaciones por Socio', True);
  list.LineaTxt('Periodo: ' + periodo, True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-') + CHR(15), True);
  list.LineaTxt('Nro.Orden F. Op.    Fe. Pago  Cuota Comercio                        Observaciones                                          Importe' + CHR(18), True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  list.LineaTxt(CHR(15), True);
  lineas := 9;
end;

procedure TTPagoServicios.ListarInfSocioPorServicios(xdfecha, xhfecha, xts, xactretiro: String; listSocios: TStringList; discriminaDB: Char; xruptura: Boolean; salida: Char; xtiempo: Integer);
Begin
  list.EstablecerTiempoConsulta(xtiempo);
  ListarInfSocioPorServicios(xdfecha, xhfecha, xts, xactretiro, listSocios, discriminaDB, xruptura, salida);
end;

procedure TTPagoServicios.ListarInfSocioPorServicios(xdfecha, xhfecha, xts, xactretiro: String; listSocios: TStringList; discriminaDB: Char; xruptura: Boolean; salida: Char);
var
  Filtro: String; i, j: integer; InfIni: Boolean;
begin
  list.Setear(salida);
  IniciarArreglos;
  pag := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, institucion, 1, 'Arial, negrita, 12');
    list.Titulo(0, 0, dirtel, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, 'Informe de Operaciones por Socio', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, 'Período: ' + periodo, 1, 'Arial, normal, 10');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Nº Orden     F. Oper. F. Pago   Cuota   Comercio', 1, 'Arial, cursiva, 8');
    list.Titulo(60, list.Lineactual, 'Observaciones', 2, 'Arial, cursiva, 8');
    list.Titulo(89, list.Lineactual, 'Importe', 3, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 4');
  end;
  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto;
    titulo1;
  end;
  if salida = 'X' then Begin
    excel.setString('A1', 'A1', institucion, 'Arial, negrita, 12');
    excel.setString('A2', 'A2', dirtel, 'Arial, negrita, 10');
    excel.setString('A3', 'A3', 'Informe de Operaciones por Socio', 'Arial, negrita, 12');
    excel.setString('A4', 'A4', 'Período: ' + xdfecha + ' - ' + xhfecha, 'Arial, negrita, 10');
    excel.setString('A5', 'A5', '', 'Arial, negrita, 10');
    excel.setString('A6', 'A6', 'CC', 'Arial, negrita, 9');
    excel.setString('B6', 'B6', 'Cuota', 'Arial, negrita, 9');
    excel.setString('C6', 'C6', 'Comercio', 'Arial, negrita, 9');
    excel.setString('D6', 'D6', 'Importe', 'Arial, negrita, 9');
    excel.setString('E6', 'E6', 'Saldo', 'Arial, negrita, 9');
    fila := 6;
    excel.FijarAnchoColumna('A1', 'A1', 7);
    excel.FijarAnchoColumna('B1', 'B1', 6);
    excel.FijarAnchoColumna('C1', 'C1', 22);
    excel.FijarAnchoColumna('D1', 'D1', 8);
    excel.FijarAnchoColumna('E1', 'E1', 8);
  end;

  Filtro := tserv.Filter; tserv.Filtered := False;

  rsql := datosdb.tranSQL('select *  from ' + tserv.TableName + ' where fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by fepago, subitems');
  rsql.Open;
  For i := 1 to listSocios.Count do Begin   // Recorremos el arreglo y vamos listando
    if Length(Trim(listSocios.Strings[i-1])) = 0 then Break;
    socioadherente.getDatos(listSocios.Strings[i-1]);
    if (xruptura) and (InfIni) then Begin
      ImprimirNotaFinal(salida);
      if salida <> 'T' then Begin
        list.CompletarPagina;
        list.ListTitulos;
      end else Begin
        For j := lineas to LineasPag do list.LineaTxt(' ', True);
        Titulo1;
      end;
    end;

    InfIni := True;
    ListarPorSocio(xdfecha, xhfecha, socioadherente.OSFA, listSocios.Strings[i-1], xts, xactretiro, discriminaDB, xruptura, salida);
  end;

  if not ExistenDatos then list.Linea(0, 0, 'No Existen Datos para Listar', 1, 'Arial, normal, 9', salida, 'S') else ImprimirNotaFinal(salida);
  if (salida = 'P') or (salida = 'I') then list.FinList;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
  if salida = 'X' then Begin
    excel.setString('F1', 'F1', '');
    excel.Visulizar;
  end;

  rsql.Close; rsql.Free;

  datosdb.QuitarFiltro(tserv);
  datosdb.Filtrar(tserv, Filtro);
end;

{*******************************************************************************}

procedure TTPagoServicios.ListarResumenPorSocio(xdfecha, xhfecha, xts, xtiposer, xact_retiro, xsubtitulo: String; xruptura: Boolean; listSocios: TStringList; salida: Char);
var
  l, z: Boolean; i: Integer;
  recargo: Real;
begin
  list.Setear(salida); 
  IniciarArreglos;
  pag := 0; tt := False;
  if salida <> 'T' then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, institucion, 1, 'Arial, negrita, 12');
    list.Titulo(0, 0, dirtel, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, 'Informe de Totales por Socio - ' + xtiposer, 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, 'Período: ' + periodo, 1, 'Arial, normal, 10');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'OSFA', 1, 'Arial, cursiva, 8');
    list.Titulo(20, list.Lineactual, 'Socio', 2, 'Arial, cursiva, 8');
    list.Titulo(89, list.Lineactual, 'Importe', 3, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 4');
  end else Begin
    if not ExportarDatos then list.IniciarImpresionModoTexto;
    if Length(Trim(xsubtitulo)) = 0 then periodo := xdfecha + ' - ' + xhfecha else periodo := xsubtitulo;
    titulo2(xtiposer);
  end;
  rsql := datosdb.tranSQL('select * from ' + tserv.TableName + ' where fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"');
  rsql.Open;

  ting := 0; total := 0; idanter := ''; ExistenDatos := False;
  For i := 1 to listSocios.Count do Begin
    if Length(Trim(listSocios.Strings[i-1])) = 0 then Break;

    socioadherente.getDatos(listSocios.Strings[i-1]);

    z := False;
    if Length(Trim(xact_retiro)) = 0 then z := True else
      if socioadherente.actretiro = xact_retiro then z := True;

    if z then Begin

      datosdb.Filtrar(rsql, 'codsocio = ' + listSocios.Strings[i-1]);

      idanter := rsql.FieldByName('osfa').AsString;
      while not rsql.EOF do Begin
        l := False;
        if Length(Trim(xts)) = 0 then l := True else Begin
          if Length(Trim(xts)) = 1 then
            if (rsql.FieldByName('tiposerv').AsString = xts) {or (rsql.FieldByName('tiposerv').AsString = 'Z')} then l := True;
          if Length(Trim(xts)) > 1 then
            if (rsql.FieldByName('tiposerv').AsString = Copy(xts, 1, 2)) or (rsql.FieldByName('tiposerv').AsString = Copy(xts, 3, 2)) {or (rsql.FieldByName('tiposerv').AsString = 'Z')} then l := True;
        end;
        if l then Begin
          if rsql.FieldByName('tipomov').AsInteger = 2 then Begin
            ting := ting + rsql.FieldByName('importe').AsFloat;
          end else Begin
            if Copy(rsql.FieldByName('subitems').AsString, 1, 1) <> '-' then ting := ting - rsql.FieldByName('importe').AsFloat else ting := ting + rsql.FieldByName('importe').AsFloat;
          end;
          idanter  := rsql.FieldByName('osfa').AsString;
          idanter1 := rsql.FieldByName('codsocio').AsString;
        end;

        if (rsql.FieldByName('tiposerv').AsString = 'Z') then
          if Buscar(rsql.FieldByName('items').AsString, '01') then
            if tserv.FieldByName('tiposerv').AsString = xts then ting := ting + rsql.FieldByName('importe').AsFloat;
               
        rsql.Next;
      end;

      rsql.Filtered := False;

      ListarTotalSocio(xtiposer, xruptura, salida);
      ImprimirNotaFinal(salida);
      if xruptura then list.CompletarPagina;
    end;
  end;

  rsql.Close; rsql.Free;

  if ExistenDatos then
      if salida <> 'T' then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Total General Socios:  ', 1, 'Arial, negrita, 9', salida, 'S');
      list.importe(95, list.Lineactual, '', total, 2, 'Arial, negrita, 9');
      list.Linea(97, list.Lineactual, ' ', 3, 'Arial, negrita, 9', salida, 'S');
    end else Begin
      list.LineaTxt(' ', True); if ControlarSalto then titulo2(xtiposer); Inc(lineas);
      if not ExportarDatos then list.LineaTxt('Total General Socios:                            ', False) else list.LineaTxt('Total General Socios:                              ', False);
      list.ImporteTxt(total, 15, 2, True);
    end;

  if not ExportarDatos then Begin
    if not ExistenDatos then list.Linea(0, 0, 'No Existen Datos para Listar', 1, 'Arial, normal, 9', salida, 'S') else  ImprimirNotaFinal(salida);
    if salida <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
  end else Begin
    list.FinalizarExportacion;
    ExportarDatos := False;
  end;
end;

procedure TTPagoServicios.ListarTotalSocio(xtiposer: String; xruptura: Boolean; salida: Char);
var
  dc: String;
begin
  socioadherente.getDatos(idanter1);
  if ting > 0 then Begin
    if salida <> 'T' then Begin
      if (socioadherente.actretiro = 'R') and not (tt) then Begin
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        tt := True;
      end;
      if socioadherente.actretiro <> 'R' then dc := socioadherente.OSFA else dc := socioadherente.nrodoc;
      list.Linea(0, 0, dc, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(20, list.Lineactual, socioadherente.nombre, 2, 'Arial, normal, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', ting, 3, 'Arial, negrita, 8');
      list.Linea(96, list.Lineactual, ' ', 4, 'Arial, negrita, 9', salida, 'S');
    end else Begin
      if (socioadherente.actretiro = 'R') and not (tt) then Begin
        list.LineaTxt(' ', True);
        tt := True;
      end;
      if socioadherente.actretiro <> 'R' then dc := socioadherente.OSFA else dc := socioadherente.nrodoc;
      if not ExportarDatos then list.LineaTxt(dc + utiles.espacios(10 - Length(TrimRight(dc))) + socioadherente.nombre + utiles.espacios(40 - Length(TrimRight(socioadherente.Nombre))), False) else list.LineaTxt(dc + utiles.espacios(10 - Length(TrimRight(dc))) + '  ' + socioadherente.nombre + utiles.espacios(40 - Length(TrimRight(socioadherente.Nombre))), False);
      list.ImporteTxt(ting, 14, 2, True); if ControlarSalto then titulo2(xtiposer); Inc(lineas);
    end;
  end;

  total := total + ting;
  ting := 0; ExistenDatos := True;
end;

procedure TTPagoServicios.Titulo2(xtiposer: String);
begin
  Inc(pag); chr15 := ''; chr18 := '';
  if not ExportarDatos then Begin
    list.LineaTxt(CHR(18), True);
    chr15 := chr(15);
    chr18 := chr(18);
  end;
  if not ExportarDatos then list.LineaTxt(institucion + utiles.espacios(70 - Length(TrimRight(institucion))) +  'Hoja ' + utiles.sLlenarIzquierda(IntToStr(pag), 4, '0'), True) else list.LineaTxt(institucion + utiles.espacios(70 - Length(TrimRight(institucion))), True);
  list.LineaTxt(dirtel, True);
  list.LineaTxt('Informe de Totales por Socio - ' + xtiposer, True);
  list.LineaTxt('Periodo: ' + periodo + chr15 + '         Impreso: ' + utiles.setFechaActual + '  ' + utiles.setHoraActual24 + chr18, True);
  if not ExportarDatos then list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  if not ExportarDatos then list.LineaTxt('OSFA        Socio                                          Importe', True) else list.LineaTxt('OSFA        Socio                                          Importe', True);
  if not ExportarDatos then list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  if not ExportarDatos then list.LineaTxt(' ', True) else list.LineaTxt(' ', True);
  lineas := 9;
end;

{*******************************************************************************}

procedure TTPagoServicios.ListarPorComercio(xdfecha, xhfecha: String; listComercios: TStringList; salida: Char);
var
  i: Integer;
begin
  list.Setear(salida);
  IniciarArreglos;
  pag := 0;
  if salida <> 'T' then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, institucion, 1, 'Arial, negrita, 12');
    list.Titulo(0, 0, dirtel, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, 'Informe de Operaciones por Comercio', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, 'Período: ' + periodo, 1, 'Arial, normal, 10');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Nº Orden     Fecha   Cuota', 1, 'Arial, cursiva, 8');
    list.Titulo(25, list.Lineactual, 'Socio', 2, 'Arial, cursiva, 8');
    list.Titulo(65, list.Lineactual, 'Observaciones', 3, 'Arial, cursiva, 8');
    list.Titulo(90, list.Lineactual, 'Importe', 4, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 4');
  end else Begin
    list.IniciarImpresionModoTexto;
    titulo3;
  end;

  ting := 0; total := 0; totales[1] := 0; totales[2] := 0; totales[3] := 0; idanter := ''; ExistenDatos := False;

  tserv.Filtered  := False;
  for i := 1 to listComercios.Count do Begin

    if Length(Trim(listComercios.Strings[i-1])) = 0 then Break;

    rsql := datosdb.tranSQL('select * from ' + tserv.TableName + ' where codoper = ' + '"' + listComercios.Strings[i-1] + '"' + ' and fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by items, subitems');
    rsql.Open;

    if rsql.RecordCount > 0 then Begin
      getDatosItems(rsql.FieldByName('codoper').AsString);  // Sincronizamos con el nuevo comercio
      if salida <> 'T' then Begin
        list.Linea(0, 0, rsql.FieldByName('codoper').AsString + '  ' + Descrip, 1, 'Arial, negrita, 9', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      end else Begin
        list.LineaTxt(CHR(18) + rsql.FieldByName('codoper').AsString + '  ' + Descrip, True); if ControlarSalto then titulo3; Inc(lineas);
        list.LineaTxt(CHR(15), True); if ControlarSalto then titulo3; Inc(lineas);
      end;

      while not rsql.EOF do Begin
        if (Copy(rsql.FieldByName('subitems').AsString, 1, 1) <> '-') then ListarLineaComercio(salida);
        rsql.Next;
      end;

      SubtotalComercio(salida);
    end;

    rsql.Close; rsql.Free;
  end;

  if salida <> 'T' then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Subtotal: ', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(20, list.Lineactual, '', total, 3, 'Arial, negrita, 8');
    list.Linea(25, list.Lineactual, 'Descuento: ', 4, 'Arial, negrita, 8', salida, 'N');
    list.importe(45, list.Lineactual, '', total - totales[1], 5, 'Arial, negrita, 8');
    list.Linea(50, list.Lineactual, 'Debitos: ', 6, 'Arial, negrita, 8', salida, 'N');
    list.importe(70, list.Lineactual, '', totales[3] * (-1), 7, 'Arial, negrita, 8');
    list.Linea(75, list.Lineactual, 'Total: ', 8, 'Arial, negrita, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[1] - totales[3], 9, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, ' ', 8, 'Arial, normal, 10', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  end else Begin
    list.LineaTxt('   ', True); if ControlarSalto then titulo3; Inc(lineas);
    list.LineaTxt(CHR(15) + '  Subtotal:  ', False);
    list.ImporteTxt(total, 12, 2, False);
    list.LineaTxt('  Descuento: ', False);
    list.ImporteTxt(total - totales[1], 12, 2, False);
    list.LineaTxt('  Debitos: ', False);
    list.ImporteTxt(totales[3] * (-1), 12, 2, False);
    list.LineaTxt('        Total: ', False);
    list.ImporteTxt(totales[1] - totales[3], 12, 2, True); if ControlarSalto then titulo3; Inc(lineas);
    list.LineaTxt(CHR(18) + utiles.sLlenarIzquierda(lin, 80, '-'), True); if ControlarSalto then titulo3; Inc(lineas);
    list.LineaTxt(' ', True); if ControlarSalto then titulo3; Inc(lineas);
  end;

  tserv.Filtered        := True;
  if not ExistenDatos then list.Linea(0, 0, 'No Existen Datos para Listar', 1, 'Arial, normal, 9', salida, 'S') else  ImprimirNotaFinal(salida);
  if salida <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
end;

procedure TTPagoServicios.ListarLineaComercio(salida: Char);
var
  subit: String;
begin
  socioadherente.getDatos(rsql.FieldByName('codsocio').AsString);
  if (rsql.FieldByName('subitems').AsString < '30') or (rsql.FieldByName('subitems').AsString = '50') then subit := rsql.FieldByName('subitems').AsString else
    subit := utiles.sLlenarIzquierda(IntToStr(rsql.FieldByName('subitems').AsInteger - 29), 2, '0');
  if salida <> 'T' then Begin
    list.Linea(0, 0, rsql.FieldByName('items').AsString + '  ' + utiles.sFormatoFecha(rsql.FieldByName('fepago').AsString) + '  ' + subit + '-' + utiles.sLLenarIzquierda(rsql.FieldByName('nrocuotas').AsString, 2, '0'), 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(25, list.Lineactual, socioadherente.nombre, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(65, list.Lineactual, rsql.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'N');
    if rsql.FieldByName('tipomov').AsInteger = 2 then list.importe(95, list.Lineactual, '', rsql.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8') else list.importe(95, list.Lineactual, '', rsql.FieldByName('importe').AsFloat * (-1), 4, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, ' ', 5, 'Arial, normal, 8', salida, 'S');
  end else Begin
    list.LineaTxt(rsql.FieldByName('items').AsString + '  ' + utiles.sFormatoFecha(rsql.FieldByName('fepago').AsString) + '  ' + subit + '-' + utiles.sLLenarIzquierda(rsql.FieldByName('nrocuotas').AsString, 2, '0') + '  ' + socioadherente.nombre + utiles.espacios(30 - Length(TrimRight(socioadherente.nombre))) + '  ' + rsql.FieldByName('concepto').AsString + utiles.espacios(30 - Length(TrimRight(rsql.FieldByName('concepto').AsString))), False);
    if rsql.FieldByName('tipomov').AsInteger = 2 then list.ImporteTxt(rsql.FieldByName('importe').AsFloat, 12, 2, True) else list.ImporteTxt(rsql.FieldByName('importe').AsFloat * (-1), 12, 2, True); if ControlarSalto then titulo3; Inc(lineas);
  end;
  porc    := porcentaje;
  if rsql.FieldByName('tipomov').AsString = '2' then ting := ting + rsql.FieldByName('importe').AsFloat;
  if rsql.FieldByName('tipomov').AsString = '1' then totales[2] := totales[2] + rsql.FieldByName('importe').AsFloat;
  ExistenDatos := True;
end;

procedure TTPagoServicios.SubtotalComercio(salida: Char);
begin
  if ting > 0 then Begin
    if salida <> 'T' then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'Subtotal: ', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(20, list.Lineactual, '', ting, 3, 'Arial, negrita, 9');
      list.Linea(25, list.Lineactual, 'Descuento: ', 4, 'Arial, negrita, 9', salida, 'N');
      if Debitar = 'N' then list.importe(45, list.Lineactual, '', ting * (porc * 0.01), 5, 'Arial, negrita, 9');
      if Debitar = 'S' then list.importe(45, list.Lineactual, '', (ting - totales[2]) * (porc * 0.01), 5, 'Arial, negrita, 9');
      list.Linea(50, list.Lineactual, 'Debitos: ', 6, 'Arial, negrita, 9', salida, 'N');
      list.importe(70, list.Lineactual, '', totales[2] * (-1), 7, 'Arial, negrita, 9');
      list.Linea(75, list.Lineactual, 'Total: ', 8, 'Arial, negrita, 9', salida, 'N');
      if Debitar = 'N' then list.importe(95, list.Lineactual, '', ting - (ting * (porc * 0.01)), 9, 'Arial, negrita, 9');
      if Debitar = 'S' then list.importe(95, list.Lineactual, '', (ting - totales[2]) - ((ting - totales[2]) * (porc * 0.01)), 9, 'Arial, negrita, 9');
      list.Linea(96, list.Lineactual, ' ', 10, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    end else Begin
      list.LineaTxt('   ', True); if ControlarSalto then titulo3; Inc(lineas);
      list.LineaTxt(CHR(15) + '  Subtotal:  ', False);
      list.ImporteTxt(ting, 12, 2, False);
      list.LineaTxt('  Descuento: ', False);
      if Debitar = 'N' then list.ImporteTxt(ting * (porc * 0.01), 12, 2, False);
      if Debitar = 'S' then list.ImporteTxt((ting - totales[2]) * (porc * 0.01), 12, 2, False);
      list.LineaTxt('  Debitos: ', False);
      list.ImporteTxt(totales[2] * (-1), 12, 2, False);
      list.LineaTxt('        Total: ', False);
      if Debitar = 'N' then list.ImporteTxt(ting - (ting * (porc * 0.01)), 12, 2, True); if ControlarSalto then titulo3; Inc(lineas);
      if Debitar = 'S' then list.ImporteTxt((ting - totales[2]) - ((ting - totales[2]) * (porc * 0.01)), 12, 2, True); if ControlarSalto then titulo3; Inc(lineas);
      list.LineaTxt(CHR(18) + utiles.sLlenarIzquierda(lin, 80, '-'), True); if ControlarSalto then titulo3; Inc(lineas);
      list.LineaTxt(' ', True); if ControlarSalto then titulo3; Inc(lineas);
    end;
  end;
  total  := total  + ting;
  totales[3] := totales[3] + totales[2];
  if Debitar = 'N' then totales[1] := totales[1] + (ting - (ting * (porc * 0.01)));
  if Debitar = 'S' then totales[1] := totales[1] + (ting - ((ting - totales[2]) * (porc * 0.01)));
  ting   := 0; totales[2] := 0;
end;

procedure TTPagoServicios.Titulo3;
begin
  Inc(pag);
  list.LineaTxt(CHR(18), True);
  list.LineaTxt(institucion + utiles.espacios(70 - Length(TrimRight(institucion))) +  'Hoja ' + utiles.sLlenarIzquierda(IntToStr(pag), 4, '0'), True);
  list.LineaTxt(dirtel, True);
  list.LineaTxt('Informe de Operaciones por Socio', True);
  list.LineaTxt('Periodo: ' + periodo, True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-') + CHR(15), True);
  list.LineaTxt('Nro.Ord.  Fecha     Cuota  Nombre del Socio               Observaciones                       Importe' + CHR(18), True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  list.LineaTxt(CHR(15), True);
  lineas := 9;
end;

{===============================================================================}

procedure TTPagoServicios.ListarResumenPorComercio(xdfecha, xhfecha: String; listComercios: TStringList; salida: Char);
var
  i: Integer;
begin
  list.Setear(salida); 
  IniciarArreglos;
  pag := 0;
  if salida <> 'T' then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, institucion, 1, 'Arial, negrita, 12');
    list.Titulo(0, 0, dirtel, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, 'Resumen de Operaciones por Comercio', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, 'Período: ' + periodo, 1, 'Arial, normal, 10');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Comercio/Empresa', 1, 'Arial, cursiva, 8');
    list.Titulo(55, list.Lineactual, 'Importe', 2, 'Arial, cursiva, 8');
    list.Titulo(64, list.Lineactual, 'Descuento', 3, 'Arial, cursiva, 8');
    list.Titulo(78, list.Lineactual, 'Débitos', 4, 'Arial, cursiva, 8');
    list.Titulo(86, list.Lineactual, 'Neto a Pagar', 5, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 4');
  end else Begin
    list.IniciarImpresionModoTexto;
    titulo4;
  end;

  tserv.Filtered := False;
  ting := 0; total := 0; totales[1] := 0; totales[2] := 0; totales[3] := 0; idanter := ''; ExistenDatos := False; idanter := '';
  for i := 1 to listComercios.Count do Begin
    if Length(Trim(listComercios.Strings[i-1])) = 0 then Break;

    rsql := datosdb.tranSQL('select * from ' + tserv.TableName + ' where codoper = ' + '"' + listComercios.Strings[i-1] + '"' + ' and fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by codoper, items, subitems');
    rsql.Open;

    if rsql.RecordCount > 0 then Begin
      idanter := rsql.FieldByName('codoper').AsString;
      while not rsql.EOF do Begin
        if (Copy(rsql.FieldByName('subitems').AsString, 1, 2) <> '-') then Begin
          if rsql.FieldByName('tipomov').AsString = '2' then ting := ting + rsql.FieldByName('importe').AsFloat;
          if rsql.FieldByName('tipomov').AsString = '1' then totales[2] := totales[2] + rsql.FieldByName('importe').AsFloat;
        end;
        rsql.Next;
      end;
      if ting + totales[2] <> 0 then ListTotalComercio(salida);
    end;

    rsql.Close; rsql.Free;
  end;

  if salida <> 'T' then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Total General:  ', 1, 'Arial, negrita, 9', salida, 'N');
    list.Importe(60, list.Lineactual, '', total, 2, 'Arial, negrita, 9');
    list.Importe(72, list.Lineactual, '', totales[1], 3, 'Arial, negrita, 9');
    list.Importe(84, list.Lineactual, '', totales[3], 4, 'Arial, negrita, 9');
    list.Importe(96, list.Lineactual, '', total - totales[1] - totales[3], 5, 'Arial, negrita, 9');
    list.Linea(98, list.Lineactual, ' ', 6, 'Arial, negrita, 9', salida, 'S');
  end else Begin
    list.LineaTxt(' ', True);  if ControlarSalto then titulo4; Inc(lineas);
    list.LineaTxt('Total General:                      ', False);
    list.ImporteTxt(total, 11, 2, False);
    list.ImporteTxt(totales[1], 11, 2, False);
    list.ImporteTxt(totales[3], 11, 2, False);
    list.ImporteTxt(total - totales[1] - totales[3], 11, 2, True); if ControlarSalto then titulo4; Inc(lineas);
  end;

  DetalleDebitos(xdfecha, xhfecha, listComercios, salida);
  if not ExistenDatos then list.Linea(0, 0, 'No Existen Datos para Listar', 1, 'Arial, normal, 9', salida, 'S') else  ImprimirNotaFinal(salida);
  if salida <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
end;

procedure TTPagoServicios.DetalleDebitos(xdfecha, xhfecha: String; listComercios: TStringList; salida: char);
begin
  // Detalle de los Debitos
  if salida <> 'T' then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Detalle de Débitos', 1, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  end else Begin
    list.LineaTxt(CHR(18), True); if ControlarSalto then titulo4; Inc(lineas);
    list.LineaTxt(CHR(18) + 'Detalle de Debitos', True); if ControlarSalto then titulo4; Inc(lineas);
    list.LineaTxt(CHR(15), True); if ControlarSalto then titulo4; Inc(lineas);
  end;

  rsql := datosdb.tranSQL('select * from ' + tserv.TableName + ' where fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by items, subitems');
  rsql.Open; ting := 0;
  while not rsql.EOF do Begin
    if Copy(rsql.FieldByName('subitems').AsString, 1, 2) <> '-' then Begin
      if (utiles.verificarItemsLista(listComercios, rsql.FieldByName('codoper').AsString)) then Begin
        if rsql.FieldByName('tipomov').AsString = '1' then Begin
          socioadherente.getDatos(rsql.FieldByName('codsocio').AsString);
          getDatosItems(rsql.FieldByName('codoper').AsString);
          if salida <> 'T' then Begin
            list.Linea(0, 0, rsql.FieldByName('items').AsString, 1, 'Arial, normal, 8', salida, 'N');
            list.Linea(8, list.Lineactual, utiles.sFormatoFecha(rsql.FieldByName('fecha').AsString) + '  ' + socioadherente.Nombre, 2, 'Arial, normal, 8', salida, 'N');
            list.Linea(40, list.Lineactual, descrip, 3, 'Arial, normal, 8', salida, 'N');
            list.importe(95, list.Lineactual, '', rsql.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8');
            list.Linea(96, list.Lineactual, ' ', 5, 'Arial, normal, 8', salida, 'S');
          end else Begin
            list.LineaTxt(CHR(15) + rsql.FieldByName('items').AsString + ' ' + utiles.sFormatoFecha(rsql.FieldByName('fecha').AsString) + ' ' + socioadherente.Nombre + utiles.espacios(35 - Length(TrimRight(socioadherente.Nombre)))+ descrip + utiles.espacios(32 - Length(TrimRight(descrip))), False);
            list.ImporteTxt(rsql.FieldByName('importe').AsFloat, 12, 2, True);  if ControlarSalto then titulo4; Inc(lineas);
          end;

          ting := ting + rsql.FieldByName('importe').AsFloat;
        end;
      end;
    end;
    rsql.Next;
  end;
  rsql.Close; rsql.Free;

  if salida <> 'T' then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, 'Total Débitos', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', ting, 2, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  end else Begin
    list.LineaTxt(CHR(15), True); if ControlarSalto then titulo4; Inc(lineas);
    list.LineaTxt(CHR(15) + 'Total Debitos:                                                                       ', False); if ControlarSalto then titulo4; Inc(lineas);
    list.ImporteTxt(ting, 12, 2, True);
  end;

  tserv.Filtered        := True;
end;

procedure TTPagoServicios.ListTotalComercio(salida: char);
// Objetivo...: Listar total por comercio
begin
  getDatosItems(idanter);
  if salida <> 'T' then Begin
    list.Linea(0, 0, Idanter + '  ' + Descrip, 1, 'Arial, normal, 8', salida, 'N');
    list.Importe(60, list.Lineactual, '', ting, 2, 'Arial, normal, 8');
    if Debitar = 'N' then list.Importe(72, list.Lineactual, '', ting * (porcentaje * 0.01), 3, 'Arial, normal, 8');
    if Debitar = 'S' then list.Importe(72, list.Lineactual, '', (ting - totales[2]) * (porcentaje * 0.01), 3, 'Arial, normal, 8');
    list.Importe(84, list.Lineactual, '', totales[2], 4, 'Arial, normal, 8');
    if Debitar = 'N' then  list.Importe(96, list.Lineactual, '', ting - (ting * (porcentaje * 0.01)), 5, 'Arial, normal, 8');
    if Debitar = 'S' then  list.Importe(96, list.Lineactual, '', (ting - totales[2]) - ((ting - totales[2]) * (porcentaje * 0.01)), 5, 'Arial, normal, 8');
    list.Linea(97, list.Lineactual, ' ', 6, 'Arial, normal, 8', salida, 'S');
  end else Begin
    list.LineaTxt(idanter + '  ' + descrip + utiles.espacios(31 - Length(TrimRight(descrip))), False);
    list.ImporteTxt(ting, 11, 2, False);
    if Debitar = 'N' then list.ImporteTxt(ting * (porcentaje * 0.01), 11, 2, False);
    if Debitar = 'S' then list.ImporteTxt((ting - totales[2]) * (porcentaje * 0.01), 11, 2, False);
    list.ImporteTxt(totales[2], 11, 2, False);
    if Debitar = 'N' then list.ImporteTxt(ting - (ting * (porcentaje * 0.01)), 11, 2, True);
    if Debitar = 'S' then list.ImporteTxt((ting - totales[2]) - ((ting - totales[2]) * (porcentaje * 0.01)), 11, 2, True);
    if ControlarSalto then titulo4; Inc(lineas);
  end;
  total  := total  + ting;
  totales[3] := totales[3] + totales[2];
  if Debitar = 'N' then totales[1] := totales[1] + (ting * (porcentaje * 0.01));
  if Debitar = 'S' then totales[1] := totales[1] + ((ting - totales[2]) * (porcentaje * 0.01));
  ting   := 0; totales[2] := 0; ExistenDatos := True;
end;

procedure TTPagoServicios.Titulo4;
begin
  Inc(pag);
  list.LineaTxt(CHR(18), True);
  list.LineaTxt(institucion + utiles.espacios(70 - Length(TrimRight(institucion))) +  'Hoja ' + utiles.sLlenarIzquierda(IntToStr(pag), 4, '0'), True);
  list.LineaTxt(dirtel, True);
  list.LineaTxt('Resumen de Operaciones por Comercio', True);
  list.LineaTxt('Periodo: ' + periodo + chr15 + '         Impreso: ' + utiles.setFechaActual + '  ' + utiles.setHoraActual24 + chr18, True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  list.LineaTxt('Comercio/Empresa                        Importe  Descuento    Debitos   Imp.Neto' + CHR(18), True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  lineas := 9;
end;

{===============================================================================}

procedure TTPagoServicios.ListarResumenCatPorComercio(xdfecha, xhfecha: String; listComercios: TStringList; salida: Char);
var
  r: TQuery;
  recargo: Real;
begin
  list.Setear(salida); 
  IniciarArreglos;
  pag := 0;
  if salida <> 'T' then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, institucion, 1, 'Arial, negrita, 12');
    list.Titulo(0, 0, dirtel, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, 'Resumen de Operaciones por Comercio', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, 'Período: ' + periodo, 1, 'Arial, normal, 10');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Comercio/Empresa', 1, 'Arial, cursiva, 8');
    list.Titulo(55, list.Lineactual, 'Importe', 2, 'Arial, cursiva, 8');
    list.Titulo(64, list.Lineactual, 'Descuento', 3, 'Arial, cursiva, 8');
    list.Titulo(78, list.Lineactual, 'Débitos', 4, 'Arial, cursiva, 8');
    list.Titulo(86, list.Lineactual, 'Neto a Pagar', 5, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 4');
  end else Begin
    list.IniciarImpresionModoTexto;
    titulo4;
  end;

  ting := 0; total := 0; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0; totales[8] := 0; totales[9] := 0; idanter := ''; ExistenDatos := False;
  rsql := datosdb.tranSQL('select * from ' + tserv.TableName + ' where fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by codoper, items, subitems');
  rsql.Open;

  r := catcom.setCategorias;
  r.Open;

  while not r.EOF do Begin
    rsql.First; ting := 0; total := 0; recargo := 0;

    idanter := rsql.FieldByName('codoper').AsString;
    while not rsql.EOF do Begin
      if Copy(rsql.FieldByName('subitems').AsString, 1, 2) <> '-' then Begin
        socioadherente.getDatos(rsql.FieldByName('codsocio').AsString);
        getDatosItems(rsql.FieldByName('codoper').AsString);

        if r.FieldByName('idcategoria').AsString = idcategoria then Begin
          ExistenDatos := True;
          if (total = 0) and (r.FieldByName('idcategoria').AsString <> idanter1) then Begin
            if salida <> 'T' then Begin
              list.Linea(0, 0, r.FieldByName('categoria').AsString, 1, 'Arial, negrita, 9', salida, 'S');
              list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
            end else Begin
              list.LineaTxt(r.FieldByName('categoria').AsString, True); if ControlarSalto then titulo4; Inc(lineas);
              list.LineaTxt(' ', True); if ControlarSalto then titulo4; Inc(lineas);
            end;
          end;
          idanter1 := r.FieldByName('idcategoria').AsString;

          if (rsql.FieldByName('codoper').AsString <> idanter) and (ting <> 0) then ListLineaCatComercio(salida);
          idanter := rsql.FieldByName('codoper').AsString;

          if rsql.FieldByName('tipomov').AsString = '1' then totales[2] := totales[2] + rsql.FieldByName('importe').AsFloat;

          if rsql.FieldByName('tipomov').AsString = '2' then Begin
            ting := ting + (rsql.FieldByName('importe').AsFloat + recargo);
            total := total + (rsql.FieldByName('importe').AsFloat + recargo);
          end;
        end;
      end;
      rsql.Next;
    end;

    if ting > 0  then ListLineaCatComercio(salida);
    if total > 0 then TotalCategoria(salida);

    r.Next;
  end;

  r.Close; r.Free;
  rsql.Close; rsql.Free;

  if ExistenDatos then
    if salida <> 'T' then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
      list.derecha(96, list.Lineactual, '', '----------------------------------------------------------------------------', 2, 'Arial, negrita, 8');
      list.Linea(97, list.Lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, 'Total General:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(60, list.Lineactual, '', totales[6], 2, 'Arial, negrita, 8');
      list.importe(72, list.Lineactual, '', totales[7], 3, 'Arial, negrita, 8');
      list.importe(84, list.Lineactual, '', totales[8], 4, 'Arial, negrita, 8');
      list.importe(95, list.Lineactual, '', totales[9], 5, 'Arial, negrita, 8');
      list.Linea(97, list.Lineactual, ' ', 6, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    end else Begin
      list.LineaTxt(' ', True); if ControlarSalto then titulo4; Inc(lineas);
      list.LineaTxt('Total General:                    ', False);
      list.ImporteTxt(totales[6], 11, 2, False);
      list.ImporteTxt(totales[7], 11, 2, False);
      list.ImporteTxt(totales[8], 11, 2, False);
      list.ImporteTxt(totales[9], 11, 2, True);
    end;

  DetalleDebitos(xdfecha, xhfecha, listComercios, salida);

  if not ExistenDatos then list.Linea(0, 0, 'No Existen Datos para Listar', 1, 'Arial, normal, 9', salida, 'S') else  ImprimirNotaFinal(salida);
  datosdb.QuitarFiltro(tserv);
  if salida <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
end;

procedure TTPagoServicios.ListLineaCatComercio(salida: Char);
// Objetivo...: Listar Linea de categorias por comercio
begin
  getDatosItems(idanter);
  if salida <> 'T' then Begin
    list.Linea(0, 0, '   ' + idanter + '  ' + descrip, 1, 'Arial, normal, 8', salida, 'N');
    list.importe(60, list.Lineactual, '', ting, 2, 'Arial, normal, 8');
    if Debitar = 'N' then list.Importe(72, list.Lineactual, '', ting * (porcentaje * 0.01), 3, 'Arial, normal, 8');
    if Debitar = 'S' then list.Importe(72, list.Lineactual, '', (ting - totales[2]) * (porcentaje * 0.01), 3, 'Arial, normal, 8');
    list.Importe(84, list.Lineactual, '', totales[2], 4, 'Arial, normal, 8');
    if catcom.DesRet <> 'S' then Begin
      if Debitar = 'N' then  list.Importe(96, list.Lineactual, '', ting - (ting * (porcentaje * 0.01)), 5, 'Arial, normal, 8');
      if Debitar = 'S' then  list.Importe(96, list.Lineactual, '', (ting - totales[2]) - ((ting - totales[2]) * (porcentaje * 0.01)), 6, 'Arial, normal, 8');
    end else Begin
      if Debitar = 'N' then  list.Importe(96, list.Lineactual, '', ting - (ting * (porcentaje * 0.01)), 5, 'Arial, normal, 8');
      if Debitar = 'S' then  list.Importe(96, list.Lineactual, '', (ting - totales[2]), 6, 'Arial, normal, 8');
    end;
    list.Linea(97, list.Lineactual, ' ', 7, 'Arial, normal, 8', salida, 'S');
  end else Begin
    list.LineaTxt(idanter + ' ' + Copy(descrip, 1, 29) + utiles.espacios(30 - Length(TrimRight(Copy(descrip, 1, 29)))), False);
    list.ImporteTxt(ting, 11, 2, False);
    if Debitar = 'N' then list.ImporteTxt(ting * (porcentaje * 0.01), 11, 2, False);
    if Debitar = 'S' then list.ImporteTxt((ting - totales[2]) * (porcentaje * 0.01), 11, 2, False);
    list.ImporteTxt(totales[2], 11, 2, False);
    if catcom.DesRet <> 'S' then Begin
      if Debitar = 'N' then  list.ImporteTxt(ting - (ting * (porcentaje * 0.01)), 11, 2, True);
      if Debitar = 'S' then  list.ImporteTxt((ting - totales[2]) - ((ting - totales[2]) * (porcentaje * 0.01)), 11, 2, True);
    end else Begin
      if Debitar = 'N' then  list.ImporteTxt(ting - (ting * (porcentaje * 0.01)), 11, 2, True);
      if Debitar = 'S' then  list.ImporteTxt(ting - totales[2], 11, 2, True);
    end;
    if ControlarSalto then titulo4; Inc(lineas);
  end;

  // Totales Ruptura
  if Debitar = 'N' then totales[3] := totales[3] + (ting - (ting * (porcentaje * 0.01)));
  if Debitar = 'S' then totales[3] := totales[3] + (ting - totales[2]) - ((ting - totales[2]) * (porcentaje * 0.01));
  if Debitar = 'N' then totales[4] := totales[4] + (ting * (porcentaje * 0.01));
  if Debitar = 'S' then totales[4] := totales[4] + ((ting - totales[2]) * (porcentaje * 0.01));
  totales[5] := totales[5] + totales[2];

  ting := 0; totales[2] := 0;
end;

procedure TTPagoServicios.TotalCategoria(salida: char);
begin
  if salida <> 'T' then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
    list.derecha(96, list.Lineactual, '', '----------------------------------------------------------------------------', 2, 'Arial, negrita, 8');
    list.Linea(97, list.Lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(60, list.Lineactual, '', total, 2, 'Arial, negrita, 8');
    list.importe(72, list.Lineactual, '', totales[4], 3, 'Arial, negrita, 8');
    list.Importe(84, list.Lineactual, '', totales[5], 6, 'Arial, negrita, 8');
    list.Importe(96, list.Lineactual, '', totales[3], 7, 'Arial, negrita, 8');
    list.Linea(97, list.Lineactual, ' ', 9, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  end else Begin
    list.LineaTxt(' ', True);  if ControlarSalto then titulo4; Inc(lineas);
    list.LineaTxt('                                   ---------------------------------------------', True);  if ControlarSalto then titulo4; Inc(lineas);
    list.LineaTxt('Subtotal:                         ', False);
    list.ImporteTxt(total, 11, 2, False);
    list.ImporteTxt(totales[4], 11, 2, False);
    list.ImporteTxt(totales[5], 11, 2, False);
    list.ImporteTxt(totales[3], 11, 2, True); if ControlarSalto then titulo4; Inc(lineas);
    list.LineaTxt(' ', True);  if ControlarSalto then titulo4; Inc(lineas);
  end;
  // Totales Finales
  totales[6] := totales[6] + total;
  totales[7] := totales[7] + totales[4];
  totales[8] := totales[8] + totales[5];
  totales[9] := totales[9] + totales[3];

  totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0;
  ting  := 0;  ExistenDatos := True;  total := 0;
end;

//------------------------------------------------------------------------------

procedure TTPagoServicios.ListarInfSocioTabular(xdfecha, xhfecha, xosfa: String; listSocios: TStringList; salida: Char);
var
  l: Boolean;
begin
  list.Setear(salida); 
  IniciarArreglos;
  pag := 0;
  if salida <> 'T' then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, institucion, 1, 'Arial, negrita, 12');
    list.Titulo(0, 0, dirtel, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, 'Totales de Socios Por Categorías', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, 'Período: ' + periodo, 1, 'Arial, normal, 10');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'OSFA', 1, 'Arial, cursiva, 8');
    list.Titulo(10, list.Lineactual, 'Socio', 2, 'Arial, cursiva, 8');
    list.Titulo(38, list.Lineactual, 'Pago Anticipado', 3, 'Arial, cursiva, 8');
    list.Titulo(55, list.Lineactual, 'Buenos Aires', 4, 'Arial, cursiva, 8');
    list.Titulo(69, list.Lineactual, 'Efectivo Circulo', 5, 'Arial, cursiva, 8');
    list.Titulo(91, list.Lineactual, 'Total', 6, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 4');
  end else Begin
    list.IniciarImpresionModoTexto;
    titulo5;
  end;

  ting := 0; total := 0; totales[1] := 0; totales[2] := 0; totales[3] := 0; tegr := 0; idanter := ''; idanter1 := ''; ExistenDatos := False;
  tserv.Filtered := False;
  rsql := datosdb.tranSQL('select * from ' + tserv.TableName + ' where fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by osfa, fepago');
  rsql.Open;
  //utiles.msgError('select * from ' + tserv.TableName + ' where fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by osfa, fepago');
  while not rsql.EOF do Begin
    if (rsql.FieldByName('fepago').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fepago').AsString <= utiles.sExprFecha2000(xhfecha)) and  utiles.verificarItemsLista(listSocios, rsql.FieldByName('codsocio').AsString) then Begin
      l := False;
      if Length(Trim(xosfa)) = 0 then l := True else
        if rsql.FieldByName('osfa').AsString = xosfa then l := True;
      if l then Begin
        if (ting + total + totales[1]) = 0 then idanter := rsql.FieldByName('codsocio').AsString;
        if rsql.FieldByName('osfa').AsString <> idanter then Begin
          if (ting + total + totales[1]) <> 0 then LineaSocioTab(salida);
          ting := 0; total := 0; totales[1] := 0;
          idanter  := rsql.FieldByName('osfa').AsString;
          idanter1 := rsql.FieldByName('codsocio').AsString;
        end;

        if rsql.FieldByName('tiposerv').AsString = 'D' then Begin
          if rsql.FieldByName('tipomov').AsString = '2' then ting := ting + rsql.FieldByName('importe').AsFloat else
            if Copy(rsql.FieldByName('Subitems').AsString, 1, 1) <> '-' then ting := ting - rsql.FieldByName('importe').AsFloat else ting := ting + rsql.FieldByName('importe').AsFloat;
        end;
        if rsql.FieldByName('tiposerv').AsString = 'B' then Begin
          if rsql.FieldByName('tipomov').AsString = '2' then total := total + rsql.FieldByName('importe').AsFloat else
            if Copy(rsql.FieldByName('Subitems').AsString, 1, 1) <> '-' then total := total - rsql.FieldByName('importe').AsFloat else total := total + rsql.FieldByName('importe').AsFloat;
        end;
        if rsql.FieldByName('tiposerv').AsString = 'N' then Begin
          if rsql.FieldByName('tipomov').AsString = '2' then totales[1] := totales[1] + rsql.FieldByName('importe').AsFloat else
            if Copy(rsql.FieldByName('Subitems').AsString, 1, 1) <> '-' then totales[1] := totales[1] - rsql.FieldByName('importe').AsFloat else totales[1] := totales[1] + rsql.FieldByName('importe').AsFloat;
        end;

        if rsql.FieldByName('tiposerv').AsString = 'Z' then Begin
          if Buscar(rsql.FieldByName('items').AsString, '01') then Begin
            if tserv.FieldByName('tiposerv').AsString = 'D' then ting := ting + rsql.FieldByName('importe').AsFloat;
            if tserv.FieldByName('tiposerv').AsString = 'B' then total := total + rsql.FieldByName('importe').AsFloat;
            if tserv.FieldByName('tiposerv').AsString = 'N' then totales[1] := totales[1] + rsql.FieldByName('importe').AsFloat;
          end;
        end;
      end;
    end;
    rsql.Next;
  end;

  rsql.Close; rsql.Free;

  LineaSocioTab(salida);

  // Totales Finales
  if salida <> 'T' then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
    list.derecha(50, list.Lineactual, '', '---------------------', 2, 'Arial, normal, 8');
    list.derecha(65, list.Lineactual, '', '---------------------', 3, 'Arial, normal, 8');
    list.derecha(80, list.Lineactual, '', '---------------------', 4, 'Arial, normal, 8');
    list.derecha(95, list.Lineactual, '', '---------------------', 5, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, ' ', 6, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Total General:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(50, list.Lineactual, '', tegr, 2, 'Arial, negrita, 8');
    list.importe(65, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 8');
    list.importe(80, list.Lineactual, '', totales[3], 4, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '',  (totales[2] + totales[3]) - tegr, 5, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, ' ',6, 'Arial, negrita, 8', salida, 'S');
  end else Begin
    list.LineaTxt(utiles.espacios(56), False);
    list.LineaTxt('---------- ---------- ---------- ----------', True); if ControlarSalto then titulo5; Inc(lineas);
    list.LineaTxt('Totales Generales:' + utiles.espacios(37), False);
    list.ImporteTxt(tegr, 11, 2, False);
    list.ImporteTxt(totales[2], 11, 2, False);
    list.ImporteTxt(totales[3], 11, 2, False);
    list.ImporteTxt((totales[2] + totales[3]) - tegr, 11, 2, True);
  end;

  if salida <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
  tserv.IndexFieldNames := 'Items;Subitems';
  tserv.Filtered := True;
end;

procedure TTPagoServicios.LineaSocioTab(salida: char);
begin
  socioadherente.getDatos(idanter1);
  if salida <> 'T' then Begin
    list.Linea(0, 0, socioadherente.OSFA, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, socioadherente.nombre, 2, 'Arial, normal, 8', salida, 'N');
    list.importe(50, list.Lineactual, '', ting, 3, 'Arial, normal, 8');
    list.importe(65, list.Lineactual, '', total, 4, 'Arial, normal, 8');
    list.importe(80, list.Lineactual, '', totales[1], 5, 'Arial, normal, 8');
    list.importe(95, list.Lineactual, '', total + totales[1], 6, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, ' ', 7, 'Arial, normal, 8', salida, 'S');
  end else Begin
    list.LineaTxt(socioadherente.OSFA + utiles.espacios(15 - Length(TrimRight(socioadherente.OSFA))), False);
    list.LineaTxt(socioadherente.nombre + utiles.espacios(40 - Length(TrimRight(socioadherente.nombre))), False);
    list.ImporteTxt(ting, 11, 2, False);
    list.ImporteTxt(total, 11, 2, False);
    list.ImporteTxt(totales[1], 11, 2, False);
    list.ImporteTxt(total + totales[1], 11, 2, True);
    if ControlarSalto then titulo5; Inc(lineas);
  end;
  tegr   := tegr   + ting;
  totales[2] := totales[2] + total;
  totales[3] := totales[3] + totales[1];
end;

procedure TTPagoServicios.Titulo5;
begin
  Inc(pag);
  list.LineaTxt(CHR(18), True);
  list.LineaTxt(institucion + utiles.espacios(70 - Length(TrimRight(institucion))) +  'Hoja ' + utiles.sLlenarIzquierda(IntToStr(pag), 4, '0'), True);
  list.LineaTxt(dirtel, True);
  list.LineaTxt('Totales de Socios Por Categorias', True);
  list.LineaTxt('Periodo: ' + periodo, True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-') + CHR(15), True);
  list.LineaTxt('OSFA           Socio                                   Pago Antic.   Bs.Aires Ef.Circulo      TOTAL' + CHR(18), True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-') + CHR(15), True);
  lineas := 9;
end;

procedure TTPagoServicios.ListarControlesDiarios(xdfecha, xhfecha: String; salida: Char);
var
  l: Boolean;
begin
  list.Setear(salida);
  IniciarArreglos;
  pag := 0;
  if salida <> 'T' then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, institucion, 1, 'Arial, negrita, 12');
    list.Titulo(0, 0, dirtel, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, 'Control de Ingresos', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, 'Período: ' + periodo + '    Fecha: ' + xdfecha + ' - ' + xhfecha, 1, 'Arial, normal, 10');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Nº Orden', 1, 'Arial, cursiva, 8');
    list.Titulo(10, list.Lineactual, 'Socio', 2, 'Arial, cursiva, 8');
    list.Titulo(47, list.Lineactual, 'Comercio', 3, 'Arial, cursiva, 8');
    list.Titulo(72, list.Lineactual, 'Cant.Cuotas', 4, 'Arial, cursiva, 8');
    list.Titulo(90, list.Lineactual, 'Importe', 5, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 4');
  end else Begin
    list.IniciarImpresionModoTexto;
    titulo6(xdfecha, xhfecha);
  end;

  ting := 0; ExistenDatos := False;
  tserv.Filtered := False;

  rsql := datosdb.tranSQL('select * from ' + tserv.TableName + ' where fechareg >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fechareg <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by osfa, fepago');
  rsql.Open;

  while not rsql.EOF do Begin
    l := False;
    socioadherente.getDatos(rsql.FieldByName('codsocio').AsString);
    getDatosItems(rsql.FieldByName('codoper').AsString);
    if salida <> 'T' then Begin
      list.Linea(0, 0, rsql.FieldByName('items').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(10, list.Lineactual, socioadherente.Nombre, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(47, list.Lineactual, Descrip, 3, 'Arial, normal, 8', salida, 'N');
      list.importe(80, list.Lineactual, '###', rsql.FieldByName('nrocuotas').AsInteger, 4, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', rsql.FieldByName('importe').AsFloat * rsql.FieldByName('nrocuotas').AsFloat, 5, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, ' ', 6, 'Arial, normal, 8', salida, 'S');
    end else Begin
      list.LineaTxt(rsql.FieldByName('items').AsString + ' ', False);
      list.LineaTxt(socioadherente.Nombre + utiles.espacios(32 - Length(TrimRight(socioadherente.Nombre))), False);
      list.LineaTxt(Descrip + utiles.espacios(32 - Length(TrimRight(Descrip))), False);
      list.ImporteTxt(rsql.FieldByName('nrocuotas').AsInteger, 3, 0, False);
      list.ImporteTxt(rsql.FieldByName('importe').AsFloat * rsql.FieldByName('nrocuotas').AsFloat, 12, 2, True);
      if ControlarSalto then titulo6(xdfecha, xhfecha); Inc(lineas);
    end;
    if rsql.FieldByName('tipomov').AsString = '2' then ting := ting + (rsql.FieldByName('importe').AsFloat * rsql.FieldByName('nrocuotas').AsFloat) else ting := ting + rsql.FieldByName('importe').AsFloat;
    rsql.Next;
  end;

  if salida <> 'T' then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
    list.derecha(95, list.Lineactual, '', '------------------------', 2, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Total Operaciones:', 1, 'Arial, normal, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', ting, 2, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
  end else Begin
    list.LineaTxt(utiles.espacios(68) + '--------------------', True);
    list.LineaTxt('Subtotal:' + utiles.espacios(67), False);
    list.importeTxt(ting, 12, 2, True);
  end;

  if salida <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
  tserv.Filtered := True;
end;

procedure TTPagoServicios.Titulo6(xdfecha, xhfecha: String);
begin
  Inc(pag);
  list.LineaTxt(CHR(18), True);
  list.LineaTxt(institucion + utiles.espacios(70 - Length(TrimRight(institucion))) +  'Hoja ' + utiles.sLlenarIzquierda(IntToStr(pag), 4, '0'), True);
  list.LineaTxt(dirtel, True);
  list.LineaTxt('Control de Ingresos', True);
  list.LineaTxt('Periodo: ' + periodo + '    Fecha: ' + xdfecha + ' - ' + xhfecha , True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-') + CHR(15), True);
  list.LineaTxt('Nro.Or.  Socio                           Comercio                  Cant.Cuotas   Importe' + CHR(18), True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-') + CHR(15), True);
  lineas := 9;
end;

procedure TTPagoServicios.ListarSaldosAdeudados(xdfecha, xhfecha: String; listSocios: TStringList; salida: char);
var
  r: TQuery; i: Real;
Begin
  pag := 0;
  if salida <> 'T' then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, institucion, 1, 'Arial, negrita, 12');
    list.Titulo(0, 0, dirtel, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, 'Informe de Control de Saldos', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, 'Período: ' + periodo + '    Fecha: ' + xdfecha + ' - ' + xhfecha, 1, 'Arial, normal, 10');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'OSFA', 1, 'Arial, cursiva, 8');
    list.Titulo(10, list.Lineactual, 'Socio', 2, 'Arial, cursiva, 8');
    list.Titulo(61, list.Lineactual, 'Total', 3, 'Arial, cursiva, 8');
    list.Titulo(73, list.Lineactual, 'Saldo Ant.', 4, 'Arial, cursiva, 8');
    list.Titulo(90, list.Lineactual, 'Saldo Act.', 5, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 4');
  end else Begin
    list.IniciarImpresionModoTexto;
    titulo7;
  end;

  r := datosdb.tranSQL('SELECT * FROM ' + tserv.TableName + ' WHERE fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' AND fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' AND subitems = ' + '"' + '-0' + '"');
  r.Open;

  while not r.EOF do Begin
    if utiles.verificarItemsLista(listSocios, r.FieldByName('codsocio').AsString) then Begin
      socioadherente.getDatos(r.FieldByName('codsocio').AsString);
      i := pagoserv.setMontoServicios(xdfecha, xhfecha, r.FieldByName('codsocio').AsString);
      if salida <> 'T' then Begin
        list.Linea(0, 0, r.FieldByName('OSFA').AsString + '  ' + socioadherente.Nombre, 1, 'Arial, normal, 8', salida, 'N');
        list.importe(65, list.Lineactual, '', i, 2, 'Arial, normal, 8');
        list.importe(80, list.Lineactual, '', r.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
        list.importe(97, list.Lineactual, '', (r.FieldByName('importe').AsFloat + i) , 4, 'Arial, normal, 8');
        list.Linea(98, list.Lineactual, ' ', 5, 'Arial, normal, 8', salida, 'S');
      end else Begin
        list.LineaTxt(r.FieldByName('OSFA').AsString + utiles.espacios(11 - Length(TrimRight(r.FieldByName('OSFA').AsString))), False);
        list.LineaTxt(socioadherente.Nombre + utiles.espacios(34 - Length(TrimRight(socioadherente.Nombre))), False);
        list.ImporteTxt(i, 10, 2, False);
        list.ImporteTxt(r.FieldByName('importe').AsFloat, 11, 2, False);
        list.ImporteTxt(r.FieldByName('importe').AsFloat + i, 12, 2, True);
        if ControlarSalto then titulo7; Inc(lineas);
      end;
    end;
    r.Next;
  end;

  r.Close; r.Free;

  if i > 0 then
    if salida <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
end;

procedure TTPagoServicios.Titulo7;
begin
  Inc(pag);
  list.LineaTxt(CHR(18), True);
  list.LineaTxt(institucion + utiles.espacios(70 - Length(TrimRight(institucion))) +  'Hoja ' + utiles.sLlenarIzquierda(IntToStr(pag), 4, '0'), True);
  list.LineaTxt(dirtel, True);
  list.LineaTxt('Informe de Control de Saldos', True);
  list.LineaTxt('Periodo: ' + periodo, True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-') + CHR(15), True);
  list.LineaTxt('OSFA       Socio                              Tot.Pagar Saldo Ant.  Saldo Act.' + CHR(18), True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  lineas := 9;
end;

procedure TTPagoServicios.Titulo8;
begin
  Inc(pag);
  list.LineaTxt(CHR(18), True);
  list.LineaTxt(institucion + utiles.espacios(70 - Length(TrimRight(institucion))) +  'Hoja ' + utiles.sLlenarIzquierda(IntToStr(pag), 4, '0'), True);
  list.LineaTxt(dirtel, True);
  list.LineaTxt('Informe de Totales Por Categorias', True);
  list.LineaTxt('Periodo: ' + periodo, True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  list.LineaTxt('OSFA       Socio                                                        Importe', True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  lineas := 9;
end;

procedure TTPagoServicios.ListarTotalesPorCategorias(xdfecha, xhfecha: String; listCategorias: TStringList; salida: char);
// Objetivo...: Listar Movimientos por Categoría
var
  r: TQuery;
Begin
  list.Setear(salida);
  pag := 0; ExistenDatos := False; idanter1 := '';
  if (salida = 'P') or (salida = 'I') then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, institucion, 1, 'Arial, negrita, 12');
    list.Titulo(0, 0, dirtel, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, 'Informe de Totales Por Categorías', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, 'Período: ' + periodo + '    Fecha: ' + xdfecha + ' - ' + xhfecha, 1, 'Arial, normal, 10');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'OSFA', 1, 'Arial, cursiva, 8');
    list.Titulo(10, list.Lineactual, 'Socio', 2, 'Arial, cursiva, 8');
    list.Titulo(45, list.Lineactual, {'Compra  Cancelación'}'', 3, 'Arial, cursiva, 8');
    list.Titulo(90, list.Lineactual, 'Importe', 4, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 4');
  end;
  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto;
    titulo8;
  end;

  if salida = 'X' then Begin
    excel.setString('A1', 'A1', institucion, 'Arial, negrita, 12');
    excel.setString('A2', 'A2', dirtel, 'Arial, negrita, 10');
    excel.setString('A3', 'A3', 'Informe de Totales Por Categorías', 'Arial, negrita, 12');
    excel.setString('A4', 'A4', 'Período: ' + xdfecha + ' - ' + xhfecha, 'Arial, negrita, 10');
    excel.setString('A5', 'A5', '', 'Arial, negrita, 10');
    excel.setString('A6', 'A6', 'OSFA', 'Arial, negrita, 9');
    excel.setString('B6', 'B6', 'Socio', 'Arial, negrita, 9');
    excel.setString('C6', 'C6', 'Importe', 'Arial, negrita, 9');
    fila := 6;
    excel.FijarAnchoColumna('A1', 'A1', 10);
    excel.FijarAnchoColumna('B1', 'B1', 40);
    excel.FijarAnchoColumna('C1', 'C1', 17);
  end;

  r := catcom.setCategorias;
  r.Open; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[7] := 0; totales[8] := 0;
  while not r.Eof do Begin
    if utiles.verificarItemsLista(listCategorias, r.FieldByName('idcategoria').AsString) then LineaCategorias(xdfecha, xhfecha, r.FieldByName('idcategoria').AsString, salida);
    r.Next;
  end;
  r.Close; r. Free;

  if salida <> 'T' then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Total General:', 1, 'Arial, negrita, 8', salida, 'N');
    list.Importe(95, list.Lineactual, '', totales[2] - (totales[7] - totales[8]) - totales[3], 2, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  end else Begin
    list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
    list.LineaTxt('Total General:                     ' + utiles.espacios(33), False);
    list.ImporteTxt(totales[2] - (totales[7] - totales[8]) - totales[3], 11, 2, True);
    if ControlarSalto then titulo8; Inc(lineas);
  end;

  if not ExistenDatos then list.Linea(0, 0, 'No existen datos para Listar', 1, 'Arial, normal, 9', salida, 'S');
  if (salida = 'P') or (salida = 'I') then list.FinList;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
  if salida = 'X' then Begin
    excel.setString('A5', 'A5', '');
    excel.Visulizar;
  end;
  ExistenDatos := False;
end;

procedure TTPagoServicios.LineaCategorias(xdfecha, xhfecha, xidcategoria: String; salida: Char);
var
  l: Boolean;
  recargo: Real;
Begin
  rsql := datosdb.tranSQL('select *  from ' + tserv.TableName + ' where fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by osfa, fepago');
  rsql.Open;
  rsql.First; totales[4] := 0; totales[5] := 0; totales[6] := 0; totales[9] := 0;
  idanter := rsql.FieldByName('codsocio').AsString;

  while not rsql.Eof do Begin
    getDatosItems(rsql.FieldByName('codoper').AsString);
    if idcategoria = xidcategoria then Begin
      if not l then Begin
        catcom.getDatos(xidcategoria);
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, 'Categoría: ' + xidcategoria + '  ' + catcom.categoria, 1, 'Arial, negrita, 9', salida, 'S');
          list.Linea(0, 0, '  ', 1, 'Arial, negrita, 5', salida, 'S');
        end;
        if salida = 'T' then Begin
          list.LineaTxt('Categoria: ' + xidcategoria + '  ' + catcom.categoria, True); if ControlarSalto then titulo8; Inc(lineas);
          list.LineaTxt('  ', True); if ControlarSalto then titulo8; Inc(lineas);
        end;
        if salida = 'X' then Begin
          Inc(fila); ffila := IntToStr(fila);
          excel.setString('A' + ffila, 'A' + ffila, 'Categoría: ' + xidcategoria + '  ' + catcom.categoria, 'Arial, negrita, 9');
          idanter1 := IntToStr(fila + 1);
        end;
        l := True;
      end;

      if (rsql.FieldByName('codsocio').AsString <> idanter) and (totales[2] <> 0) then Begin
        listLineaCat(idanter, salida);
        idanter := rsql.FieldByName('codsocio').AsString;
      end;

      if rsql.FieldByName('tipomov').AsInteger =  1 then
        if Buscar(rsql.FieldByName('items').AsString, '50') then recargo := tserv.FieldByName('importe').AsFloat else recargo := 0;

      if rsql.FieldByName('tipomov').AsString = '2' then Begin
        totales[9] := totales[9] + (rsql.FieldByName('importe').AsFloat + recargo);
        totales[1] := totales[1] + (rsql.FieldByName('importe').AsFloat + recargo);
        totales[2] := totales[2] + (rsql.FieldByName('importe').AsFloat + recargo);
        totales[5] := totales[5] + ((rsql.FieldByName('importe').AsFloat + recargo) * (porcentaje * 0.01));
        totales[7] := totales[7] + ((rsql.FieldByName('importe').AsFloat + recargo) * (porcentaje * 0.01));
      end;

      if rsql.FieldByName('tipomov').AsString = '1' then Begin
        totales[3] := totales[3] + (rsql.FieldByName('importe').AsFloat + recargo);
        totales[4] := totales[4] + (rsql.FieldByName('importe').AsFloat + recargo);
        totales[6] := totales[6] + ((rsql.FieldByName('importe').AsFloat + recargo) * (porcentaje * 0.01));
        totales[8] := totales[8] + ((rsql.FieldByName('importe').AsFloat + recargo) * (porcentaje * 0.01));
      end;
    end;
    rsql.Next;
  end;

  rsql.Close; rsql.Free;

  listLineaCat(idanter, salida);

  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.Importe(95, list.Lineactual, '', totales[1] - (totales[5] - totales[6]) - totales[4], 2, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  end;
  if salida = 'T' then Begin
    list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
    list.LineaTxt('Subtotal:' + utiles.espacios(59), False);
    list.ImporteTxt(totales[1] - (totales[5] - totales[6]) - totales[4], 11, 2, True);
    list.LineaTxt(' ', True);
    if ControlarSalto then titulo8; Inc(lineas);
  end;
  if salida = 'X' then Begin
    Inc(fila); ffila := IntToStr(fila);
    excel.setString('A' + ffila, 'A' + ffila, 'Subtotal:', 'Arial, negrita, 9');
    excel.setFormulaArray('C' + ffila, 'C' + ffila, '=suma(' + 'C' + idanter1 + ':' + 'C' + IntToStr(fila-1) + ')', 'Arial, negrita, 9');
  end;
  totales[1] := 0; totales[4] := 0;
end;

procedure TTPagoServicios.ListLineaCat(xidanter: String; salida: Char);
Begin
  socioadherente.getDatos(xidanter);
  ExistenDatos := True;
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, '''' + socioadherente.OSFA, 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(7, list.Lineactual, socioadherente.nombre, 2, 'Arial, normal, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[9], 3, 'Arial, normal, 9');
    list.Linea(96, list.Lineactual, ' ', 4, 'Arial, normal, 9', salida, 'S');
  end;
  if salida = 'T' then Begin
    list.LineaTxt(socioadherente.OSFA + utiles.espacios(11 - Length(TrimRight(tserv.FieldByName('OSFA').AsString))), False);
    list.LineaTxt(Copy(socioadherente.Nombre, 1, 30) + utiles.espacios(34 - Length(TrimRight(Copy(socioadherente.Nombre, 1, 30)))), False);
    list.LineaTxt('                      ', False);
    list.ImporteTxt(totales[9], 12, 2, True);
    if ControlarSalto then titulo8; Inc(lineas);
  end;
  if salida = 'X' then Begin
    Inc(fila); ffila := IntToStr(fila);
    excel.setString('A' + ffila, 'A' + ffila, socioadherente.OSFA, 'Arial, normal, 8');
    excel.setString('B' + ffila, 'B' + ffila, socioadherente.nombre, 'Arial, normal, 8');
    excel.setReal('C' + ffila, 'C' + ffila, totales[9], 'Arial, normal, 8');
  end;
  totales[9] := 0;
end;

{ ***************************************************************************** }

procedure TTPagoServicios.GrabarItems(xcoditems, xdescrip, xdebitar, xidcategoria: string; xporcentaje, xmontoFijo, xmontoFijoNS: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if BuscarItems(xcoditems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('coditems').AsString    := xcoditems;
  tabla.FieldByName('descrip').AsString     := xdescrip;
  tabla.FieldByName('debita').AsString      := xdebitar;
  tabla.FieldByName('idcategoria').AsString := xidcategoria;
  tabla.FieldByName('porcentaje').AsFloat   := xporcentaje;
  tabla.FieldByName('montoFijo').AsFloat    := xmontoFijo;
  tabla.FieldByName('montoFijoNS').AsFloat  := xmontoFijoNS;
  try
    tabla.Post;
    except
    tabla.Cancel
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTPagoServicios.BorrarItems(xcoditems: string);
// Objetivo...: Eliminar un Objeto
begin
  if BuscarItems(xcoditems) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('coditems').AsString, '');  // Fijamos los Atributos Siguientes al Objeto Borrado
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
  if BuscarItems(xcoditems) then Begin
    coditems    := tabla.FieldByName('coditems').AsString;
    descrip     := tabla.FieldByName('descrip').AsString;
    debitar     := tabla.FieldByName('debita').AsString;
    idcategoria := tabla.FieldByName('idcategoria').AsString;
    porcentaje  := tabla.FieldByName('porcentaje').AsFloat;
    montoFijo   := tabla.FieldByName('montoFijo').AsFloat;
    montoFijoNS := tabla.FieldByName('montoFijoNS').AsFloat;
   end else Begin
    coditems := ''; descrip := ''; debitar := ''; porcentaje := 0; idcategoria := ''; montoFijo := 0; MontoFijoNS := 0;
  end;
  catcom.getDatos(idcategoria);
end;

function TTPagoServicios.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  if tabla.IndexFieldNames <> 'Coditems' then tabla.IndexFieldNames := 'Coditems';
  tabla.Last;
  if tabla.RecordCount > 0 then Result := IntToStr(tabla.FieldByName('coditems').AsInteger + 1) else Result := '1';
end;

procedure TTPagoServicios.ListarItems(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Comercios
begin
  if orden = 'A' then tabla.IndexFieldNames := 'descrip';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Entidades Imput. de Servicios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(3) +  'Descripción', 1, 'Arial, cursiva, 8');
  List.Titulo(45, list.Lineactual, 'Categoría', 2, 'Arial, cursiva, 8');
  List.Titulo(79, list.Lineactual, 'Porcentaje Dto.', 3, 'Arial, cursiva, 8');
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
  catcom.getDatos(tabla.FieldByName('idcategoria').AsString);
  List.Linea(0, 0, tabla.FieldByName('coditems').AsString + '    ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(45, list.Lineactual, catcom.Categoria, 2, 'Arial, normal, 8', salida, 'N');
  List.importe(90, list.lineactual, '', tabla.FieldByName('porcentaje').AsFloat, 3, 'Arial, normal, 8');
  List.Linea(97, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
end;

function TTPagoServicios.setItemsReg: TQuery;
// Objetivo...: Devolver un set de registro con los items
begin
  Result := datosdb.tranSQL('SELECT * FROM itregis');
end;

function TTPagoServicios.setComercios: TQuery;
// Objetivo...: Devolver un set de registro con los comercios
begin
  Result := datosdb.tranSQL('SELECT coditems, descrip FROM comercios ORDER BY descrip');
end;

function TTPagoServicios.setItemsMontoFijo: TQuery;
// Objetivo...: Devolver un set de registros con monto fijo
begin
  Result := datosdb.tranSQL('SELECT coditems, descrip FROM comercios WHERE montoFijo > 0 ORDER BY descrip');
end;

function TTPagoServicios.setSociosConMovimientos(xdfecha, xhfecha: String): TQuery;
// Objetivo...: Devolver aquellos socios con movimientos en el periodo
begin
  if Lowercase(tserv.TableName) = 'servicioscirculo' then Result := datosdb.tranSQL('SELECT DISTINCT serviciosCirculo.codsocio, serviciosCirculo.osfa, socios.nombre FROM serviciosCirculo, socios WHERE serviciosCirculo.codsocio = socios.codsocio AND fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' AND fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' ORDER BY Nombre') else
    Result := datosdb.tranSQL('SELECT DISTINCT serviciosCirculoHistorico.codsocio, serviciosCirculoHistorico.osfa, socios.nombre FROM serviciosCirculoHistorico, socios WHERE serviciosCirculoHistorico.codsocio = socios.codsocio AND fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' AND fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' ORDER BY Nombre')
end;

function TTPagoServicios.setSociosConMovimientos_EnActividad(xdfecha, xhfecha: String): TQuery;
// Objetivo...: Devolver aquellos socios con movimientos en el periodo
begin
  Result := datosdb.tranSQL('SELECT DISTINCT serviciosCirculo.codsocio, serviciosCirculo.osfa FROM serviciosCirculo WHERE fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' AND fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' ORDER BY osfa');
end;

function TTPagoServicios.setSociosConMovimientos_Retirados(xdfecha, xhfecha: String): TQuery;
// Objetivo...: Devolver aquellos socios con movimientos en el periodo
begin
  Result := datosdb.tranSQL('SELECT DISTINCT serviciosCirculo.codsocio, serviciosCirculo.osfa, socioh.Nrodoc FROM serviciosCirculo, socioh WHERE serviciosCirculo.codsocio = socioh.codsocio AND fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' AND fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' ORDER BY nrodoc');
end;

function TTPagoServicios.setMontoServicios(xdf, xhf, xcodsocio: String): Real;
var
  f: Boolean;
begin
  f := tserv.Filtered; tserv.Filtered := False;
  tserv.First; ting := 0; tegr := 0; tsaldoanter := 0;
  while not tserv.EOF do Begin
    if ((tserv.FieldByName('fepago').AsString >= utiles.sExprFecha2000(xdf)) and (tserv.FieldByName('fepago').AsString <= utiles.sExprFecha2000(xhf))) and (tserv.FieldByName('codsocio').AsString = xcodsocio) and (tserv.FieldByName('subitems').AsString <> '-0') then Begin
      if tserv.FieldByName('tipomov').AsInteger  = 2  then ting := ting + tserv.FieldByName('importe').AsFloat;
      if tserv.FieldByName('tipomov').AsInteger  = 1  then tegr := tegr + tserv.FieldByName('importe').AsFloat;
    end;

    // Obtenemos el saldo pendiente del mes anterior
    if ((tserv.FieldByName('fepago').AsString >= utiles.sExprFecha2000(xdf)) and (tserv.FieldByName('fepago').AsString <= utiles.sExprFecha2000(xhf))) and (tserv.FieldByName('codsocio').AsString = xcodsocio) and (tserv.FieldByName('subitems').AsString = '-0') and (tserv.FieldByName('tipomov').AsString = '1') then tsaldoanter := tsaldoanter + tserv.FieldByName('importe').AsFloat;

    // Entrega efectuada en el período
    if (tserv.FieldByName('codsocio').AsString = xcodsocio) and (tserv.FieldByName('tipomov').AsInteger = 1) and (Copy(tserv.FieldByName('fecha').AsString, 1, 6) = Copy(utiles.sExprFecha2000(xdf), 1, 6)) then Begin
      tiposerv := tserv.FieldByName('tiposerv').AsString;
      fepago   := utiles.sFormatoFecha(tserv.FieldByName('fepago').AsString);
      concepto := tserv.FieldByName('concepto').AsString;
      // Extraemos la distribucion de pagos
      if datosdb.Buscar(distPagos, 'Items', 'Subitems', tserv.FieldByName('items').AsString, tserv.FieldByName('subitems').AsString) then debito := distPagos.FieldByName('importe').AsFloat else debito := 0;
    end;
    tserv.Next;
  end;
  tserv.Filtered := f;
  Result := ting;
end;

function TTPagoServicios.setMontoPagado: Real;
begin
  Result := tegr;
end;

procedure TTPagoServicios.EstablecerSaldo(xitems, xsubitems, xcodsocio, xosfa, xfecha, xfepago, xtipomov, xtiposerv, xconcepto: String; ximporte, xpago: Real);
var
  f: Boolean;
begin
  f := tserv.Filtered;
  if f then tserv.Filtered := False;
  if Buscar(xitems, xsubitems) then tserv.Edit else tserv.Append;
  tserv.FieldByName('items').AsString    := xitems;
  tserv.FieldByName('subitems').AsString := xsubitems;
  tserv.FieldByName('codsocio').AsString := xcodsocio;
  tserv.FieldByName('osfa').AsString     := xosfa;
  if xtipomov = '1' then
    if Length(Trim(xtipomov)) = 0 then tserv.FieldByName('concepto').AsString := 'Pago de la cuenta' else tserv.FieldByName('concepto').AsString := xconcepto;
  if xtipomov = '0' then tserv.FieldByName('concepto').AsString := 'Saldo Inicial';
  tserv.FieldByName('fecha').AsString    := utiles.sExprFecha2000(xfecha);
  tserv.FieldByName('fepago').AsString   := utiles.sExprFecha2000(xfepago);
  tserv.FieldByName('importe').AsFloat   := ximporte - xpago;
  tserv.FieldByName('tipomov').AsString  := xtipomov;
  tserv.FieldByName('tiposerv').AsString := xtiposerv;
  try
    tserv.Post;
   except
    tserv.Cancel
  end;
  datosdb.refrescar(tserv); 
  tserv.Filtered := f;
  // Guardamos el Pago
  if datosdb.Buscar(distPagos, 'Items', 'Subitems', xitems, xsubitems) then distPagos.Edit else distPagos.Append;
  distPagos.FieldByName('Items').AsString    := xitems;
  distPagos.FieldByName('subitems').AsString := xsubitems;
  distPagos.FieldByName('tiposerv').AsString := xtiposerv;
  distPagos.FieldByName('importe').AsFloat   := xpago;
  try
    distpagos.Post
   except
    distpagos.Cancel
  end;
end;

procedure TTPagoServicios.CambiarNumeroOSFA(xcodsocio, xosfa: String);
begin
  datosdb.tranSQL('UPDATE servicioscirculo SET OSFA = ' + '"' + xosfa + '"' + ' WHERE codsocio = ' + '"' + xcodsocio + '"');
end;

function TTPagoServicios.setMovimientosCancelaciones(xcodmov, xdesdeitems, xhastaitems: String): TQuery;
Begin
  Result := datosdb.tranSQL('SELECT items, subitems, fecha, codsocio, importe, codoper FROM ' + tserv.TableName + ' WHERE codoper = ' + '"' + xcodmov + '"' + ' AND subitems >= ' + '"' + xdesdeitems + '"' + ' and subitems <= ' + '"' + xhastaitems + '"' + ' ORDER BY codsocio, items, subitems');
end;

function TTPagoServicios.setOperacionesSocio(xcodsocio: String): TQuery;
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tserv.TableName + ' WHERE codsocio = ' + '"' + xcodsocio + '"' + ' AND subitems = ' + '"' + '01' + '"' + ' or subitems = ' + '"' + '30' + '"' + ' ORDER BY fepago');
end;

function TTPagoServicios.setOperacionesFecha(xdfecha, xhfecha: String): TQuery;
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tserv.TableName + ' WHERE fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' AND fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' AND subitems = ' + '"' + '01' + '"' + ' ORDER BY fepago');
end;

function TTPagoServicios.setOperacionesComercio(xitems: String): TQuery;
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tserv.TableName + ' WHERE codoper = ' + '"' + xitems + '"' + ' AND subitems <= ' + '"' + '01' + '"' + ' ORDER BY fepago');
end;

procedure TTPagoServicios.BuscarPorCodigo(xexpr: string);
begin
  if tabla.IndexFieldNames <> 'Coditems' then tabla.IndexFieldNames := 'Coditems';
  tabla.FindNearest([xexpr]);
end;

procedure TTPagoServicios.BuscarPorDescrip(xexpr: string);
begin
  if tabla.IndexFieldNames <> 'Descrip' then tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTPagoServicios.Exportar(xarchivo: String);
begin
  ExportarDatos := True;
  list.ExportarInforme(xarchivo);
end;

procedure TTPagoServicios.ExportarExcel2000;
var
  archivo: TextFile;
  linea, j, p, u: String; i: Integer;
Begin
  AssignFile(archivo, dbs.DirSistema + '\export_excel.txt');
  Reset(archivo);
  i := 0; p := '';
  while not eof(archivo) do Begin
    ReadLn(archivo, linea);
    if Length(Trim(linea)) > 0 then Begin
      Inc(i); j := IntToStr(i);
      // Titulos
      if LowerCase(Copy(linea, 1, 7)) = 'informe' then Begin
        excel.setString('A' + j, 'A' + j, UpperCase(linea), 'Arial, negrita, 12');
        excel.FijarAnchoColumna('A1', 'A1', 15);   // Fijamos el ancho de la columna OSFA
        excel.Alinear('A1', 'A1', 'I');            // Fijamos alineación
        excel.FijarAnchoColumna('B1', 'B1', 35);   // Fijamos el ancho de la columna Nombre
        excel.FijarAnchoColumna('C1', 'C1', 15);   // Fijamos el ancho de la columna Monto
      end;
      if LowerCase(Copy(linea, 1, 3)) = 'per' then Begin
        excel.setString('A' + j, 'A' + j, UpperCase(linea), 'Arial, negrita, 10');
        Inc(i); j := IntToStr(i);
      end;
      // Titulos de Columnas
      if LowerCase(Copy(linea, 1, 4)) = 'osfa' then Begin
        excel.setString('A' + j, 'A' + j, UpperCase(Copy(linea, 1, 4)), 'Arial, negrita, 10');
        excel.setString('B' + j, 'B' + j, UpperCase(Copy(linea, 12, 20)), 'Arial, negrita, 10');
        excel.setString('C' + j, 'C' + j, UpperCase(Copy(linea, 60, 10)), 'Arial, negrita, 10');
        excel.Alinear('C' + j, 'C' + j, 'D');
      end;
      // Detalle
      if (LowerCase(Copy(linea, 1, 1)) >= '0') and (LowerCase(Copy(linea, 1, 1)) <= '9') then Begin
        excel.setString('A' + j, 'A' + j, '''' + Trim(Copy(linea, 1, 10)));
        excel.setString('B' + j, 'B' + j, UpperCase(Copy(linea, 13, 30)));
        excel.setReal('C' + j, 'C' + j,  StrToFloat(utiles.FormatearNumero(Trim(Copy(linea, 57, 15)))));
        if Length(Trim(p)) = 0 then p := 'C' + j;
      end;
    end;
  end;
  closeFile(archivo);
  Inc(i); j := IntToStr(i);
  excel.setString('A' + j, 'A' + j, '');
  Inc(i); j := IntToStr(i);
  excel.setString('A' + j, 'A' + j, 'TOTAL GENERAL DE SOCIOS:', 'Arial, negrita, 10');
  excel.setFormulaArray('C' + j, 'C' + j, '=SUMA(' + p + ':' + 'C' + IntToStr(i-3) + ')', 'Arial, negrita, 10');
  excel.Visulizar;
end;

function TTPagoServicios.setConsumoMes(xcodsocio, xfecha: String): Real;
var
  ff, f1, f2, indice, it, su: String;
  total: Real;
Begin
  it := tserv.FieldByName('items').AsString; su := tserv.FieldByName('subitems').AsString;
  indice := tserv.IndexFieldNames;
  ff := xfecha;
  f1 := Copy(utiles.sExprFecha2000(ff), 1, 6) + '01';
  f2 := Copy(utiles.sExprFecha2000(ff), 1, 6) + utiles.ultFechaMes(Copy(f1, 5, 2), Copy(f1, 1, 6) + Copy(f1, 1, 4));

  total := 0;
  tserv.IndexFieldNames := 'codsocio';
  if tserv.FindKey([xcodsocio]) then Begin
    while not tserv.Eof do Begin
      if Trim(tserv.FieldByName('codsocio').AsString) <> Trim(xcodsocio) then Break;
      if (tserv.FieldByName('fepago').AsString >= f1) and (tserv.FieldByName('fepago').AsString <= f2) and (tserv.FieldByName('tipomov').AsInteger = 2) and ((tserv.FieldByName('subitems').AsString < '30') or (tserv.FieldByName('subitems').AsString > '49')) then
        total := total + tserv.FieldByName('importe').AsFloat;
      tserv.Next;
    end;
  end;

  tserv.IndexFieldNames := indice;
  Buscar(it, su);
  Result := total;
end;

function TTPagoServicios.setConsumoMesPenias(xcodsocio, xfecha: String): Real;
var
  ff, f1, f2, indice, it, su: String;
  total: Real;
Begin
  it := tserv.FieldByName('items').AsString; su := tserv.FieldByName('subitems').AsString;
  indice := tserv.IndexFieldNames;
  ff := xfecha;
  f1 := Copy(utiles.sExprFecha2000(ff), 1, 6) + '01';
  f2 := Copy(utiles.sExprFecha2000(ff), 1, 6) + utiles.ultFechaMes(Copy(f1, 5, 2), Copy(f1, 1, 6) + Copy(f1, 1, 4));

  total := 0;
  tserv.IndexFieldNames := 'codsocio';
  if tserv.FindKey([xcodsocio]) then Begin
    while not tserv.Eof do Begin
      if Trim(tserv.FieldByName('codsocio').AsString) <> Trim(xcodsocio) then Break;
      if (tserv.FieldByName('fepago').AsString >= f1) and (tserv.FieldByName('fepago').AsString <= f2) and (tserv.FieldByName('tipomov').AsInteger = 2) and ((tserv.FieldByName('subitems').AsString >= '30') and (tserv.FieldByName('subitems').AsString <= '49')) then
        total := total + tserv.FieldByName('importe').AsFloat;
      tserv.Next;
    end;
  end;

  tserv.IndexFieldNames := indice;
  Buscar(it, su);
  Result := total;
end;

procedure TTPagoServicios.GuardarConfigInforme(xInforme: String; xCopias, xLineasImp, xRuptura, xHojasTroq, xLineasSep, xNotaFinal: ShortInt);
// Objetivo...: Guardar datos informe
begin
  if ctrlInf.FindKey([xInforme]) then ctrlInf.Edit else ctrlInf.Append;
  ctrlInf.FieldByName('informe').AsString    := xInforme;
  ctrlInf.FieldByName('copias').AsInteger    := xCopias;
  ctrlInf.FieldByName('lineasImp').AsInteger := xlineasimp;
  ctrlInf.FieldByName('ruptura').AsInteger   := xruptura;
  ctrlInf.FieldByName('hojastroq').AsInteger := xhojastroq;
  ctrlInf.FieldByName('lineassep').AsInteger := xlineassep;
  ctrlInf.FieldByName('notafinal').AsInteger := xnotafinal;
  try
    ctrlInf.Post
   except
    ctrlInf.Cancel
  end;
  getDatosInf(xinforme);
end;

procedure TTPagoServicios.getDatosInf(xinforme: String);
begin
  if ctrlInf.FindKey([xInforme]) then Begin
    informe   := ctrlInf.FieldByName('informe').AsString;
    copias    := ctrlInf.FieldByName('copias').AsInteger;
    lineasPag := ctrlInf.FieldByName('lineasimp').AsInteger;
    ruptura   := ctrlInf.FieldByName('ruptura').AsInteger;
    hojastroq := ctrlInf.FieldByName('hojastroq').AsInteger;
    lineassep := ctrlInf.FieldByName('lineassep').AsInteger;
    notafinal := ctrlInf.FieldByName('notafinal').AsInteger;
  end else Begin
    informe := ''; lineasPag := 65; copias := 1; ruptura := 0; hojastroq := 0; lineassep := 5; notafinal := 0;
  end;
end;

procedure TTPagoServicios.ImprimirNotaFinal(salida: char);
begin
  if notafinal = 1 then
    if salida <> 'T' then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, linea1, 1, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, linea2, 1, 'Arial, normal, 9', salida, 'S');
    end else Begin
      list.LineaTxt(' ', True);
      list.LineaTxt(linea1, True); if ControlarSalto then titulo1; Inc(lineas);
      list.LineaTxt(linea2, True);
    end;
end;

function  TTPagoServicios.setDatosDepurar(xfecha: String): TQuery;
// Objetivo...: Devolver un set con los datos en condiciones de depurar
Begin
  Result := datosdb.tranSQL('select items, subitems, codsocio, osfa, fecha, fepago, importe, nrocuotas from ' + tserv.TableName + ' where fepago <= ' + '"' + utiles.sExprFecha2000(xfecha) + '"');
end;

procedure TTPagoServicios.DepurarOrden(xitems, xsubitems, xfecha: String);
// Objetivo...: Eliminar Definitivamente una orden
Begin
  tservhist.Open;
  if Buscar(xitems, xsubitems) then Begin
    while not tserv.Eof do Begin
      if tserv.FieldByName('items').AsString <> xitems then Break;
      if datosdb.Buscar(tservhist, 'Items', 'Subitems', 'Fechadep', tserv.FieldByName('items').AsString, tserv.FieldByName('subitems').AsString, utiles.sExprFecha2000(xfecha)) then tservhist.Edit else tservhist.Append;
      tservhist.FieldByName('items').AsString     := tserv.FieldByName('items').AsString;
      tservhist.FieldByName('subitems').AsString  := tserv.FieldByName('subitems').AsString;
      tservhist.FieldByName('fechadep').AsString  := utiles.sExprFecha2000(xfecha);
      tservhist.FieldByName('codsocio').AsString  := tserv.FieldByName('codsocio').AsString;
      tservhist.FieldByName('osfa').AsString      := tserv.FieldByName('osfa').AsString;
      tservhist.FieldByName('fecha').AsString     := tserv.FieldByName('fecha').AsString;
      tservhist.FieldByName('fepago').AsString    := tserv.FieldByName('fepago').AsString;
      tservhist.FieldByName('importe').AsFloat    := tserv.FieldByName('importe').AsFloat;
      tservhist.FieldByName('codoper').AsString   := tserv.FieldByName('codoper').AsString;
      tservhist.FieldByName('concepto').AsString  := tserv.FieldByName('concepto').AsString;
      tservhist.FieldByName('tiposerv').AsString  := tserv.FieldByName('tiposerv').AsString;
      tservhist.FieldByName('nrocuotas').AsString := tserv.FieldByName('nrocuotas').AsString;
      tservhist.FieldByName('tipomov').AsString   := tserv.FieldByName('tipomov').AsString;
      tservhist.FieldByName('fechareg').AsString  := tserv.FieldByName('fechareg').AsString;
      tservhist.FieldByName('entrega').AsString   := tserv.FieldByName('entrega').AsString;
      tservhist.FieldByName('impreso').AsString   := tserv.FieldByName('impreso').AsString;
      try
        tservhist.Post
       except
        tservhist.Cancel
      end;
      tserv.Next;
    end;
  end;
  datosdb.closeDB(tservhist);

  datosdb.tranSQL('delete from ' + tserv.TableName + ' where items = ' + '"' + xitems + '"');
  datosdb.refrescar(tserv);
end;

procedure TTPagoServicios.IniciarArreglos;
// Objetivo...: Iniciar Arreglos
var
  i: Integer;
begin
  for i := 1 to cantitems do totales[i] := 0;
end;

procedure TTPagoServicios.ImprimirOrden(xitems: String);
// Objetivo...: Imprimir Orden
var
  i: Integer;
Begin
  list.IniciarImpresionModoTexto;
  ListarOrden(xitems, 'Original');
  for i := 1 to sepOrdenes do list.LineaTxt('', True);
  ListarOrden(xitems, 'Duplicado');
  list.FinalizarImpresionModoTexto(1);
  // Marcamos la Orden como impresa
  if Buscar(xitems, '01') then Begin
    tserv.Edit;
    tserv.FieldByName('impreso').AsString := 'S';
    try
      tserv.Post
     except
      tserv.Cancel
    end;
    datosdb.closeDB(tserv); tserv.Open;
  end;
end;

procedure TTPagoServicios.ListarOrden(xitems, xform: String);
// Objetivo...: Imprimir Orden
var
  i, m: Integer;
  l1, l2: array[1..7] of String;
  t: String;
Begin
  m := MargenIzq;
  if Length(Trim(margen)) > 0 then MargenIzq := StrToInt(Margen);
  for i := 1 to 5 do Begin
    l1[i] := utiles.espacios(8);
    l2[i] := '  ' + utiles.espacios(12);
  end;
  getDatos(xitems, '01');
  i := 0;
  while not tserv.Eof do Begin
    if tserv.FieldByName('items').AsString <> xitems then Break;
    if tserv.FieldByName('subitems').AsString < '30' then Begin
      Inc(i);
      l1[i] := utiles.setMes(StrToInt(Copy(utiles.RestarMeses(utiles.sFormatoFecha(tserv.FieldByName('fepago').AsString), '1'), 4, 2)));
      l2[i] := '$ ' + utiles.FormatearNumero(tserv.FieldByName('importe').AsString);
    end;
    tserv.Next;
  end;
  getDatos(xitems, '01');

  socioadherente.getDatos(codsocio);
  getDatosItems(codoper);
  totales[1] := Importe * StrToFloat(nrocuotas);
  list.LineaTxt(chr(18), True);
  list.LineaTxt(utiles.espacios(MargenIzq) + 'Circulo de Suboficiales de      ORDEN DE COMPRA        Nro. ' + xitems, True);
  list.LineaTxt(utiles.espacios(MargenIzq) + '   la Fuerza Aerea              ----- -- ------', True);
  list.LineaTxt(utiles.espacios(MargenIzq) + '  Asociacion Mutual             ' + xform, True);
  list.LineaTxt(utiles.espacios(MargenIzq) + '"' + 'Regional Reconquista' + '"', True);
  list.LineaTxt('', True);
  list.LineaTxt(utiles.espacios(MargenIzq) + 'Por la presente autorizamos al Asociado ' + socioadherente.nombre, True);
  list.LineaTxt(utiles.espacios(MargenIzq) + 'a retirar mercaderia de la casa ' + descrip, True);
  list.LineaTxt(utiles.espacios(MargenIzq) + 'por valor de $ ' + utiles.xIntToLletras(StrToInt(Copy(utiles.FormatearNumero(FloatToStr(totales[1])), 1, Length(Trim(utiles.FormatearNumero(FloatToStr(totales[1])))) - 3))) + ' con ' + Copy(utiles.FormatearNumero(FloatToStr(totales[1])), Length(Trim(utiles.FormatearNumero(FloatToStr(totales[1])))) - 1, 2) + ' ctvos. amortizables.', True);
  if {(Copy(Fecha, 4, 2) = '11') or} (Copy(Fecha, 4, 2) = '12') then list.LineaTxt(utiles.espacios(MargenIzq) + 'en ' + nrocuotas + ' cuotas iguales, mensuales y consecutivas a partir de ' + utiles.setMes(StrToInt(Copy(utiles.FechaSumarMeses(utiles.sFormatoFecha(tserv.FieldByName('fecha').AsString), '10', 1), 4, 2))) + ' de ' + IntToStr(StrToInt(Copy(utiles.sExprFecha2000(utiles.setFechaActual), 1, 4)) + 1) + '.-', True) else
    list.LineaTxt(utiles.espacios(MargenIzq) + 'en ' + nrocuotas + ' cuotas iguales, mensuales y consecutivas a partir de ' + utiles.setMes(StrToInt(Copy(utiles.FechaSumarMeses(utiles.sFormatoFecha(tserv.FieldByName('fecha').AsString), '10', 1), 4, 2))) + ' de ' + Copy(utiles.sExprFecha2000(utiles.setFechaActual), 1, 4) + '.-', True);
//  utiles.msgError(Copy(utiles.sExprFecha2000(utiles.setFechaActual), 1, 4));
  list.LineaTxt(utiles.espacios(MargenIzq) + 'Autorizo a descontar de mis haberes.', True);
  list.LineaTxt('', True);
  list.LineaTxt(utiles.espacios(MargenIzq) + '                                   Reconquista, ' + Copy(fecha, 1, 2) + ' de ' + utiles.setMes(StrToInt(Copy(fecha, 4, 2))) + ' de ' + Copy(utiles.sExprFecha2000(fecha), 1, 4) + '.-', True);
  for i := 1 to 5 do list.LineaTxt('', True);
  list.LineaTxt(utiles.espacios(MargenIzq) + '------------------------                                ------------------------', True);
  list.LineaTxt(utiles.espacios(MargenIzq) + '      Solicitante', True);
  for i := 1 to 3 do list.LineaTxt('', True);
  list.LineaTxt(utiles.espacios(MargenIzq) + '--------------------------------------------------------------------------------', True);
  list.LineaTxt(utiles.espacios(MargenIzq) + chr(15), False);
  for i := 7 downto 1 do list.LineaTxt('Nro. ' + items + ' ' + '!', False);
  list.LineaTxt('', True);
  list.LineaTxt(utiles.espacios(MargenIzq), False);
  for i := 7 downto 1 do Begin
    if (i = 1) or (i = 3) or (i = 6) then t := 'ra.' else t := 'ta.';
    if i = 2 then t := 'da.';
    if i = 7 then t := 'ma.';
    list.LineaTxt('  ' + IntToStr(i) + t + ' Cuota  ' + '!', False);
  end;
  list.LineaTxt('', True);
  list.LineaTxt(utiles.espacios(MargenIzq), False);
  for i := 7 downto 1 do list.LineaTxt('  ' + l1[i] + utiles.espacios(12 - Length(l1[i])) + '!', False);
  list.LineaTxt('', True);
  list.LineaTxt(utiles.espacios(MargenIzq), False);
  for i := 7 downto 1 do
    if Length(Trim(l2[i])) = 1 then list.LineaTxt(l2[i] + '!', False) else list.LineaTxt(l2[i] + utiles.espacios(14 - Length(l2[i])) + '!', False);
  list.LineaTxt('', True);
  list.LineaTxt(utiles.espacios(MargenIzq) + chr(18) + '--------------------------------------------------------------------------------', True);
  MargenIzq := m;
end;

procedure TTPagoServicios.FijarImputacionFija(xid, xitems: String);
// Objetivo...: Items de Imputación Fija
Begin
  if itemsFijos.FindKey([xid]) then itemsFijos.Edit else itemsFijos.Append;
  itemsFijos.FieldByName('items').AsString  := xid;
  itemsFijos.FieldByName('cuenta').AsString := xitems;
  try
    itemsFijos.Post
   except
    itemsFijos.Cancel
  end;
  datosdb.refrescar(itemsFijos);
end;

function TTPagoServicios.ItemsFijoGastos(xid: String): String;
// Objetivo...: Devolver Items de Imputación Fija
Begin
  if itemsFijos.FindKey([xid]) then Result := itemsFijos.FieldByName('cuenta').AsString else Result := '';
end;

function TTPagoServicios.setMontoFijo(xcod: String): Real;
// Objetivo...: Listar Monto Gasto Fijo
Begin
  if BuscarItems(xcod) then Result := tabla.FieldByName('montoFijo').AsFloat else Result := 0;
end;

function TTPagoServicios.setMontoFijoNS(xcod: String): Real;
// Objetivo...: Listar Monto Gasto Fijo
Begin
  if BuscarItems(xcod) then Result := tabla.FieldByName('montoFijoNS').AsFloat else Result := 0;
end;

function  TTPagoServicios.setNumeroSiguiente(xidcor: String): String;
// Objetivo...: devolver número siguiente
Begin
  if correlatividad.FindKey([xidcor]) then Begin
    Margen := correlatividad.FieldByName('margen').AsString;
    Result := IntToStr(correlatividad.FieldByName('numero').AsInteger + 1);
  end else Result := '1';
end;

procedure TTPagoServicios.RegistrarNumeroCorrelativo(xidcor, xnumero, xmargen: String; xforzarNro: Boolean);
// Objetivo...: devolver número siguiente
Begin
  if correlatividad.FindKey([xidcor]) then correlatividad.Edit else correlatividad.Append;
  correlatividad.FieldByName('id').AsString     := xidcor;
  if (xnumero > utiles.sLlenarIzquierda(correlatividad.FieldByName('numero').AsString, 8, '0')) and not (xforzarNro) then correlatividad.FieldByName('numero').AsString := xnumero;
  if xforzarNro then correlatividad.FieldByName('numero').AsString := xnumero;
  if Length(Trim(xmargen)) > 0 then
    correlatividad.FieldByName('margen').AsString := xmargen;
  try
    correlatividad.Post
   except
    correlatividad.Cancel
  end;
  datosdb.closedb(correlatividad); correlatividad.Open;
end;

function  TTPagoServicios.verificarSiLaOrdenEstaImpresa(xitems: String): Boolean;
// Objetivo...: Verificar si la orden está impresa
Begin
  Result := False;
  if Buscar(xitems, '01') then
    if tserv.FieldByName('impreso').AsString = 'S' then Result := True;
end;

function  TTPagoServicios.verificarItems(xitems, xsubitems, xtipomov: String): Boolean;
// Objetivo...: Verificar Items + tipomov
Begin
  Result := False;
  rsql := datosdb.tranSQL('select fepago from servicioscirculo where items = ' + '"' + xitems + '"' + ' and subitems = ' + '"' + xsubitems + '"' + ' and tipomov = ' + '"' + xtipomov + '"');
  rsql.Open;
  if rsql.RecordCount > 0 then Begin
    fepago := utiles.sFormatoFecha(rsql.FieldByName('fepago').AsString);
    Result := True;
  end;
  rsql.Close; rsql.Free;
end;

function  TTPagoServicios.BorrarCredito(xitems, xsubitems, xtipomov: String): Boolean;
// Objetivo...: Borrar Crédito
Begin
  datosdb.tranSQL('delete from servicioscirculo where items = ' + '"' + xitems + '"' + ' and subitems = ' + '"' + xsubitems + '"' + ' and tipomov = ' + '"' + xtipomov + '"');
end;

function  TTPagoServicios.verificarSiElSocioTieneOperaciones(xcodsocio: String): Boolean;
// Objetivo...: Verificar que el socio tenga operaciones
Begin
  rsql := datosdb.tranSQL('select codsocio from servicioscirculo where codsocio = ' + '"' + xcodsocio + '"');
  rsql.Open;
  if rsql.RecordCount > 0 then Result := True else Result := False;
  rsql.Close;
end;

procedure TTPagoServicios.EstablecerTiempoConsulta(xtiempo: Integer);
Begin
  list.EstablecerTiempoConsulta(xtiempo);
end;

function TTPagoServicios.setMontoTotalConsumido(xdfecha, xhfecha, xcodsocio: String): Real;
var
  rsql: TQuery;
  tot: Real;
Begin
  rsql := datosdb.tranSQL('select fepago, subitems, codsocio, importe, tipomov from ' + tserv.TableName + ' where fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' and codsocio = ' + '"' + xcodsocio + '"' + ' order by fepago, subitems');
  rsql.Open; tot := 0;
  while not rsql.Eof do Begin
    if rsql.FieldByName('tipomov').AsInteger = 2 then tot := tot + rsql.FieldByName('importe').AsFloat;
    rsql.Next;
  end;
  rsql.Close; rsql.Free;
  Result := tot;
end;

function TTPagoServicios.setSaldoMes(xdfecha, xhfecha, xcodsocio: String): Real;
var
  rsql: TQuery;
  tot: Real;
Begin
  rsql := datosdb.tranSQL('select fepago, subitems, codsocio, importe, tipomov from ' + tserv.TableName + ' where fepago >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fepago <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' and codsocio = ' + '"' + xcodsocio + '"' + ' order by fepago, subitems');
  rsql.Open; tot := 0;
  while not rsql.Eof do Begin
    if rsql.FieldByName('tipomov').AsInteger = 1 then tot := tot - rsql.FieldByName('importe').AsFloat;
    if rsql.FieldByName('tipomov').AsInteger = 2 then tot := tot + rsql.FieldByName('importe').AsFloat;
    rsql.Next;
  end;
  rsql.Close; rsql.Free;
  Result := tot;
end;

function  TTPagoServicios.BuscarReferencia(xitems, xsubitems: String): Boolean;
Begin
  Result := datosdb.Buscar(refitems, 'items1', 'subitems1', xitems, xsubitems);
end;

procedure TTPagoServicios.RegistrarReferencia(xitems, xsubitems, xitems1, xsubitems1: String);
Begin
  if BuscarReferencia(xitems, xsubitems) then refitems.Edit else refitems.Append;
  refitems.FieldByName('items1').AsString     := xitems;
  refitems.FieldByName('subitems1').AsString  := xsubitems;
  refitems.FieldByName('items2').AsString    := xitems1;
  refitems.FieldByName('subitems2').AsString := xsubitems1;
  try
    refitems.Post
   except
    refitems.Cancel
  end;
  datosdb.closeDB(refitems); refitems.Open;
end;

procedure TTPagoServicios.BorrarReferencia(xitems, xsubitems: String);
Begin
  if BuscarReferencia(xitems, xsubitems) then refitems.Delete;
  datosdb.closeDB(refitems); refitems.Open;
end;

procedure TTPagoServicios.getDatosReferencia(xitems, xsubitems: String);
Begin
  if BuscarReferencia(xitems, xsubitems) then Begin
    items1    := refitems.FieldByName('items2').AsString;
    subitems1 := refitems.FieldByName('subitems2').AsString;
  end else Begin
    items1 := ''; subitems1 := '';
  end;
end;

function  TTPagoServicios.BuscarTransferencia(xperiodo, xcodsocio: String): Boolean;
// Objetivo...: Abrir tservs de persistencia
begin
  Result := datosdb.Buscar(transferencias, 'periodo', 'codsocio', xperiodo, xcodsocio);
end;

procedure TTPagoServicios.RegistrarTransferencia(xperiodo, xcodsocio, xtransac, xtiposerv: String);
// Objetivo...: Buscar Instancia
begin
  if BuscarTransferencia(xperiodo, xcodsocio) then transferencias.Edit else transferencias.Append;
  transferencias.FieldByName('periodo').AsString  := xperiodo;
  transferencias.FieldByName('codsocio').AsString := xcodsocio;
  transferencias.FieldByName('transac').AsString  := xtransac;
  transferencias.FieldByName('tiposerv').AsString := xtiposerv;
  try
    transferencias.Post
   except
    transferencias.Cancel
  end;
  datosdb.closeDB(transferencias); transferencias.Open;
end;

procedure TTPagoServicios.BorrarTransferencia(xperiodo, xcodsocio: String);
// Objetivo...: Abrir tservs de persistencia
begin
  if BuscarTransferencia(xperiodo, xcodsocio) then transferencias.Delete;
  datosdb.closeDB(transferencias); transferencias.Open;
end;

procedure TTPagoServicios.getDatosTransferencia(xperiodo, xcodsocio: String);
// Objetivo...: Abrir tservs de persistencia
begin
  if BuscarTransferencia(xperiodo, xcodsocio) then Begin
     transac   := transferencias.FieldByName('transac').AsString;
     ttiposerv := transferencias.FieldByName('tiposerv').AsString;
  end else Begin
     transac := ''; ttiposerv := '';
  end;
  if Length(Trim(ttiposerv)) = 0 then ttiposerv := 'N';
end;

procedure TTPagoServicios.conectar;
// Objetivo...: Abrir tservs de persistencia
begin
  catcom.conectar;
  if conexiones = 0 then Begin
    if not tserv.Active then tserv.Open;
    if not tabla.Active then tabla.Open;
    if not ctrlInf.Active then ctrlInf.Open;
    if not distPagos.Active then distPagos.Open;
    if not ItemsFijos.Active then ItemsFijos.Open;
    if not correlatividad.Active then correlatividad.Open;
    if not refitems.Active then refitems.Open;
    if not transferencias.Active then transferencias.Open;
    tabla.FieldByName('coditems').DisplayLabel := 'Cód.'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción'; tabla.FieldByName('debita').DisplayLabel := 'DI'; tabla.FieldByName('idcategoria').DisplayLabel := 'Id.Cat.';
    tabla.FieldByName('montoFijo').DisplayLabel := 'Monto Fijo Socios'; tabla.FieldByName('montoFijoNS').DisplayLabel := 'M.F. No Socios '; tabla.FieldByName('porcentaje').DisplayLabel := 'Porcentaje';
    tserv.FieldByName('codsocio').Visible := False; tserv.FieldByName('fecha').Visible := False;
  end;
  Filtrar;
  tserv.Last;
  socioadherente.conectar;
  Inc(conexiones);
end;

procedure TTPagoServicios.desconectar;
// Objetivo...: cerrar tservs de persistencia
begin
  catcom.desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tserv);
    datosdb.closeDB(tabla);
    datosdb.closeDB(ctrlInf);
    datosdb.closeDB(distPagos);
    datosdb.closeDB(ItemsFijos);
    datosdb.closeDB(correlatividad);
    datosdb.closeDB(refitems);
    datosdb.closeDB(transferencias);
  end;
  socioadherente.desconectar;
end;

procedure TTPagoServicios.conectarHistorico;
// Objetivo...: Abrir tservs de persistencia
begin
  datosdb.closeDB(tserv); tserv := nil;
  tserv := datosdb.openDB('serviciosCirculoHistorico', 'items;subitems');
  tserv.Open;
end;

procedure TTPagoServicios.desconectarHistorico;
// Objetivo...: Abrir tservs de persistencia
begin
  datosdb.closeDB(tserv); tserv := nil;
  tserv := datosdb.openDB('serviciosCirculo', 'items;subitems');
  tserv.Open;
end;

{===============================================================================}

function pagoserv: TTPagoServicios;
begin
  if xpagoserv = nil then
    xpagoserv := TTPagoServicios.Create;
  Result := xpagoserv;
end;

{===============================================================================}

initialization

finalization
  xpagoserv.Free;

end.
