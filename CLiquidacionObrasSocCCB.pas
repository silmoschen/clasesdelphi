unit CLiquidacionObrasSocCCB;

interface

uses Windows, CObrasSocialesCCB, CFacturacionCCB, CProfesionalCCB, SysUtils, CListar, DB, DBTables, CBDT, CUtiles,
     CIDBFM, CTitulosAuditoria, CRetencionesCentroBioq, CUtilidadesArchivos, Classes, CBancos,
     CAjustesIndivCentroBioq, CBackup, CCoseguros, CAuditoriaCCB, CDebitosCreditosCentroBioq;

type

TTDistribucionObrasSociales = class(TObject)
  Periodo, Codos, PeriodoLiq, Idprof, Fecha, NroLiq, ConceptoSaldo, PeriodoGanancias, LiquidacionGanancias: String; Importe, Porcentaje: Real;
  ExisteLiquidacion, BecasGan, LiqIndi_Ganancias, verFormulaGanancias, LiquidarRetencionesSeparadas: Boolean;
  copias, salto, LineasPag, ExcluirObrasSocialesInscriptas, AplicarMinimoGanancias: ShortInt;
  exporta_web: boolean; tipoinf_web: string;
  cabajust, detajust, dcprof, ctrlImpr, montos, depositos, controlLiq, ganancias, subtotalesLiq, montosret: TTable;

  constructor Create;
  destructor  Destroy; override;

  { Distribuciones }
  function    Buscar(xperiodo, xcodos, xperliq: String): Boolean;
  procedure   getDatos(xperiodo, xcodos, xperliq: String);
  procedure   Borrar(xperiodo, xcodos, xperliq: String);
  procedure   GuardarLiquidacion(xperiodo, xcodos, xperiodoLiq, xfecha, xnroLiq: String; ximportetot, xporcentaje: Real);
  procedure   BorrarLiquidacionProfesional(xperiodo, xidprof: String);
  procedure   BorrarMovimientosPeriodoCompleto(xperiodo, xperliq: String);
  function    setLiquidaciones: TStringList;

  { Ajustes Individuales }
  procedure   GuardarAjustesIndividuales(xperiodo, xcodos, xidprof, xitems, xconcepto, xfecha, xprotegido, xperiodoLiq: String; ximporte: real; xCantidadItems: Integer);
  procedure   AjustarNumeroDeItems(xperiodo, xcodos: String; CantItems: Integer);
  function    setItemsAjustesIndividuales(xperiodo, xcodos: String): TQuery;
  function    setItemsAjustesIndividualesProfesional(xperiodo, xidprof: String): TQuery;
  function    setListaAjustesIndividualesProfesional(xperiodo, xidprof: String): TStringList;
  function    setListaAjustesIndividualesProfesionalRetiva(xperiodo, xidprof: String): TStringList;
  function    setListaAjustesIndividualesProfesionalExcluirRetiva(xperiodo, xidprof: String): TStringList;
  function    setItemsLiquidados(xperiodo: String): TStringList;

  { D�bitos/Cr�ditos Profesionales }
  procedure   GuardarDCProf(xperiodo, xidprof, xitems, xidajuste, xdescripaj: String; ximporteaj: Real; xCantidadItems: Integer; xtipomov: Char);
  procedure   BorrarDCProfFijos;
  procedure   BorrarDCProfManuales;
  procedure   BorrarDCProfExedentes(xitems: String);
  function    setItemsDCProf(xperiodo: String): TQuery; overload;
  function    setItemsDCProf(xperiodo, xidprof: String): TQuery; overload;
  function    setListaDCProf(xperiodo, xidprof: String): TStringList;

  { Informes }
  procedure   InfDistribucionProfesional(xperiodo, xperiodoLiq: String; listSel, listDist: TStringList; salida: Char; xobsocial_iva, xganancias, xrecmontos: Boolean; xretieneganancias: String);
  procedure   ConfigurarInforme(xreporte: String; xcopias, xsalto: ShortInt);
  procedure   getConfiguracionInforme(xreporte: String);
  procedure   ListarObrasSocialesLiquidadas(xlista: TStringList; xperiodo: String; salida: Char);
  procedure   ListarResumenLisquidacion(xperiodo: String; salida: char; xrecalcular_montos: Boolean);
  procedure   ListarResumenRetenciones(xperiodo: String; xlista: TStringList; salida: char);
  procedure   RecalcularDistribucionProfesional(xperiodo, xperiodoLiq: String; listSel, listDist: TStringList; xobsocial_iva, xganancias, xrecmontos: Boolean; xretieneganancias: String);
  procedure   ListarMontosRetGanancias(xperiodo: String; salida: char);

  { Manejo de Directorios }
  function    verificarPeriodo(xperiodo: String): Boolean;
  procedure   PrepararDirectorio(xperiodo: String);
  function    setNroDistribucion(xperiodo: String): String;

  procedure   InicializarMontos(xperiodo: String; xborrar_datos: Boolean);
  procedure   InicializarDepositos(xperiodo: String);
  procedure   RegistrarDeposito(xperiodo, xidprof, xcodbco, xfecha, xobservacion: String);
  procedure   BorrarDeposito(xidprof, xcodbco: String);
  function    setDepositos(xperiodo: String): TStringList;

  { Controles generales }
  function    BuscarControlLiq(xperiodo, xperiodoliq, xcodos: String): Boolean;
  procedure   GuardarControlLiq(xperiodo, xperiodoliq, xcodos: String; xporcentaje: Real);
  procedure   BorrarControlLiq(xperiodo, xperiodoliq, xcodos: String);
  function    verificarPeriodoLiq(xperiodoliq, xcodos: String): Real;

  procedure   ListarTotalesLiquidadosPeriodos(xdesde, xhasta: string; salida: char);

  procedure   RealizarBackupDatos;
  function    setBackup(xperiodo: String): TStringList;
  procedure   RealizarRestauracionLaboratorios(xarchivo: String);

  procedure   titulo1(xperiodo: String);
  procedure   titulo2(xperiodo: String);
  procedure   titulo3(xperiodo: String);
  procedure   titulo4(xperiodo: String);

  procedure   refrescar;
  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: integer;
  DBConexion, directorio, diractual, pergan: String;
  totales: array[1..15] of Real;
  pag, lineas: Integer; lin: String;
  totganancias, monto_g: Real;
  unifica_ganancias, unif_cuit, noListar, initxt: Boolean;
  lista1, lista2, lista3, lista4: TStringList;
  procedure   AjustarNroItemsDCProf(xperiodo, xidprof: String; xnroitems: Integer; xtipomov: Char);
  procedure   ListDistribucionProfesional(xperiodo, xperiodoLiq: String; listSel, listDist: TStringList; salida: Char; xobsocial_iva, xganancias: Boolean; xretieneganancias: String);
  procedure   TitulosIFD(salida: Char);
  procedure   lineaProfesional(xidprof, xperiodo: String; salida: char);
  function    ControlarSalto: boolean;
  procedure   RealizarSalto;
  procedure   SeleccionarPeriodo(xperiodo: String);
  procedure   InstanciarTablas(xperiodo: String);
  procedure   RegistrarTotal(xidprof, xitems, xnrodist: String; xmonto, xtotal: Real);
  procedure   ListarMontos(xfiltro, xperiodo: String; salida: char);
  procedure   ListItemsRetenciones(idanter, xperiodo: String; salida: char);
  procedure   ListItemsAjustes(idanter, xperiodo: String; salida: char);
  procedure   ListarTotalRetencion(xperiodo: String; salida: char);
  function    BuscarDeposito(xidprof, xcodbco: String): Boolean;
  procedure   RegistrarMontoParaGanancias(xidprof, xnrodist: String; xmonto: Real);
  function    setMontoParaGanancias(xidprof, xperiodo, xnroliq: String): Real;
  { Subtotales para Liquidar Ganancias }
  function    BuscarMontoGanancias(xidprof, xnroliq: String): Boolean;
  procedure   RegistrarMontoGanancias(xidprof, xnroliq: String; xmonto: Real);
  procedure   MarcarConsumoGanancias(xidprof, xnroliq, xconsumido: String);
  function    verificarConsumoGanancias(xidprof, xnroliq: String): Boolean;
end;

function distribucionos: TTDistribucionObrasSociales;

implementation

var
  xdistribucionos: TTDistribucionObrasSociales = nil;

constructor TTDistribucionObrasSociales.Create;
begin
  inherited Create;
  if dbs.BaseClientServ = 'S' then DBConexion := dbs.baseDat else DBConexion := dbs.DirSistema + '\archdat';
  ctrlImpr   := datosdb.openDB('ctrlImp', 'Reporte', '', DBConexion);
  controlLiq := datosdb.openDB('controlLiq', '', '', dbs.DirSistema + '\distribucion\control');
end;

destructor TTDistribucionObrasSociales.Destroy;
begin
  inherited Destroy;
end;

function  TTDistribucionObrasSociales.Buscar(xperiodo, xcodos, xperliq: String): Boolean;
// Objetivo...: Buscar Periodo
begin
  ExisteLiquidacion := False;
  PrepararDirectorio(xperiodo + NroLiq);
  if verificarPeriodo(xperiodo + NroLiq) then Begin
    PrepararDirectorio(xperiodo + NroLiq);
    if cabajust.IndexFieldNames <> 'Periodo;Codos;Perliq' then cabajust.IndexFieldNames := 'Periodo;Codos;Perliq';
    ExisteLiquidacion := datosdb.Buscar(cabajust, 'Periodo', 'Codos', 'Perliq', xperiodo, xcodos, xperliq);
  end;
  Result := ExisteLiquidacion;
end;

procedure TTDistribucionObrasSociales.GuardarLiquidacion(xperiodo, xcodos, xperiodoLiq, xfecha, xnroLiq: String; ximportetot, xporcentaje: Real);
// Objetivo...: Guardar Liquidaci�n
begin
  PrepararDirectorio(xperiodo + xnroLiq);
  if Buscar(xperiodo, xcodos, xperiodoLiq) then cabajust.Edit else cabajust.Append;
  cabajust.FieldByName('periodo').AsString   := xperiodo;
  cabajust.FieldByName('codos').AsString     := xcodos;
  cabajust.FieldByName('perLiq').AsString    := xperiodoLiq;
  cabajust.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  cabajust.FieldByName('importe').AsFloat    := ximportetot;
  cabajust.FieldByName('porcentaje').AsFloat := xporcentaje;
  try
    cabajust.Post
   except
    cabajust.Cancel
  end;
  ExisteLiquidacion := True;
  datosdb.refrescar(cabajust);
  GuardarControlLiq(xperiodo, xperiodoliq, xcodos, xporcentaje);
end;

procedure TTDistribucionObrasSociales.GuardarAjustesIndividuales(xperiodo, xcodos, xidprof, xitems, xconcepto, xfecha, xprotegido, xperiodoLiq: String; ximporte: real; xCantidadItems: Integer);
// Objetivo...: Guardar transaccion
begin
  if ximporte <> 0 then Begin
    if datosdb.Buscar(detajust, 'Periodo', 'Codos', 'Idprof', 'Items', xperiodo, xcodos, xidprof, xitems) then detajust.Edit else detajust.Append;
    detajust.FieldByName('Periodo').AsString   := xperiodo;
    detajust.FieldByName('Codos').AsString     := xcodos;
    detajust.FieldByName('Idprof').AsString    := xidprof;
    detajust.FieldByName('Items').AsString     := xitems;
    detajust.FieldByName('Concepto').AsString  := xconcepto;
    detajust.FieldByName('Perliq').AsString    := xperiodoliq;
    detajust.FieldByName('importe').AsFloat    := ximporte;
    detajust.FieldByName('Protegido').AsString := xprotegido;
    try
      detajust.Post
     except
      detajust.Cancel
    end;
    ExisteLiquidacion := True;
  end;

  if ximporte = 0 then   // Eliminamos la Redundancia
    if datosdb.Buscar(detajust, 'Periodo', 'Codos', 'Idprof', 'Items', xperiodo, xcodos, xidprof, xitems) then detajust.Delete;
end;

procedure TTDistribucionObrasSociales.AjustarNumeroDeItems(xperiodo, xcodos: String; CantItems: Integer);
begin
  datosdb.tranSQL(directorio, 'DELETE FROM ' + detajust.TableName + ' WHERE Periodo = ' + '"' + xperiodo + '"' + ' and Codos = ' + '"' + xcodos + '"' + ' and items >= ' + '"' + utiles.sLlenarIzquierda(IntToStr(cantitems), 3, '0') + '"');
  datosdb.refrescar(detajust);
end;

procedure TTDistribucionObrasSociales.getDatos(xperiodo, xcodos, xperliq: String);
// Objetivo...: Recuperar Datos
begin
  if Buscar(xperiodo, xcodos, xperliq) then Begin
    Periodo    := xperiodo;
    Codos      := xcodos;
    fecha      := utiles.sFormatoFecha(cabajust.FieldByName('Fecha').AsString);
    importe    := cabajust.FieldByName('importe').AsFloat;
    periodoLiq := cabajust.FieldByName('perLiq').AsString;
    porcentaje := cabajust.FieldByName('porcentaje').AsFloat;
  end else Begin
    periodo := ''; codos := ''; importe := 0; porcentaje := 0; fecha := utiles.setFechaActual; periodoLiq := '';
  end;
end;

procedure TTDistribucionObrasSociales.Borrar(xperiodo, xcodos, xperliq: String);
// Objetivo...: Borrar un items
begin
  if Buscar(xperiodo, xcodos, xperliq) then Begin
    cabajust.Delete;
    datosdb.refrescar(cabajust);
    BorrarControlLiq(xperiodo, xperliq, xcodos);
  end;
end;

procedure TTDistribucionObrasSociales.BorrarLiquidacionProfesional(xperiodo, xidprof: String);
// Objetivo...: Borrar Movimientos de una Obra Social
begin
  datosdb.tranSQL(directorio, 'DELETE FROM ' + detajust.TableName + ' WHERE perliq = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"');
  datosdb.tranSQL(directorio, 'DELETE FROM ' + dcprof.TableName   + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"');
end;

procedure TTDistribucionObrasSociales.BorrarMovimientosPeriodoCompleto(xperiodo, xperliq: String);
// Objetivo...: Borrar Movimientos de una Obra Social
begin
  datosdb.tranSQL(DBConexion, 'DELETE FROM ' + detajust.TableName + ' WHERE periodo = ' + '"' + xperiodo + '"');
  datosdb.tranSQL(DBConexion, 'DELETE FROM ' + cabajust.TableName + ' WHERE periodo = ' + '"' + xperiodo + '"');
  datosdb.tranSQL(DBConexion, 'DELETE FROM ' + dcprof.TableName   + ' WHERE periodo = ' + '"' + xperliq + '"');
  datosdb.tranSQL(DBConexion, 'DELETE FROM ' + detajust.TableName + ' WHERE periodo = ' + '"' + xperliq + '"');
end;

function TTDistribucionObrasSociales.setLiquidaciones: TStringList;
// Objetivo...: Listar Liquidaciones
var
  l: TStringList;
  t: Boolean;
Begin
  t := cabajust.Active;
  if not cabajust.Active then cabajust.Open;
  l := TStringList.Create;
  cabajust.First;
  while not cabajust.Eof do Begin
    l.Add(cabajust.FieldByName('codos').AsString + cabajust.FieldByName('perliq').AsString + cabajust.FieldByName('fecha').AsString + utiles.FormatearNumero(cabajust.FieldByName('importe').AsString) + ';1' + utiles.FormatearNumero(cabajust.FieldByName('porcentaje').AsString));
    cabajust.Next;
  end;
  cabajust.Active := t;
  Result := l;
end;

function TTDistribucionObrasSociales.setItemsAjustesIndividuales(xperiodo, xcodos: String): TQuery;
// Objetivo...: Devolver ajustes de una obra social
begin
  Result := datosdb.tranSQL(directorio, 'SELECT * FROM ' + detajust.TableName + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' AND codos = ' + '"' + xcodos + '"');
end;

function TTDistribucionObrasSociales.setItemsAjustesIndividualesProfesional(xperiodo, xidprof: String): TQuery;
// Objetivo...: Devolver Ajustes de un Profesional
begin
  Result := datosdb.tranSQL(directorio, 'SELECT * FROM ' + detajust.TableName + ' WHERE perliq = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"');
  datosdb.refrescar(detajust);
end;

function TTDistribucionObrasSociales.setListaAjustesIndividualesProfesional(xperiodo, xidprof: String): TStringList;
// Objetivo...: Devolver Ajustes de un Profesional
var
  l: TStringList;
  e: Boolean;
begin
  l := TStringList.Create;
  e := detajust.Active;
  if not detajust.Active then detajust.Open;
  datosdb.Filtrar(detajust, 'perliq = ' + '''' + xperiodo + '''' + ' AND idprof = ' + '''' + xidprof + '''');
  detajust.First;
  while not detajust.Eof do Begin
    l.Add(detajust.FieldByName('periodo').AsString + detajust.FieldByName('codos').AsString + detajust.FieldByName('idprof').AsString + detajust.FieldByName('items').AsString + detajust.FieldByName('perliq').AsString + detajust.FieldByName('concepto').AsString + ';1' + detajust.FieldByName('importe').AsString);
    detajust.Next;
  end;
  datosdb.QuitarFiltro(detajust);
  detajust.Active := e;
  Result := l;
end;

function TTDistribucionObrasSociales.setListaAjustesIndividualesProfesionalRetiva(xperiodo, xidprof: String): TStringList;
// Objetivo...: Devolver Ajustes de un Profesional
var
  l: TStringList;
  e: Boolean;
begin
  l := TStringList.Create;
  e := detajust.Active;
  if not detajust.Active then detajust.Open;
  datosdb.Filtrar(detajust, 'perliq = ' + '''' + xperiodo + '''' + ' AND idprof = ' + '''' + xidprof + '''');
  detajust.First;
  while not detajust.Eof do Begin
    obsocial.getDatos(detajust.FieldByName('codos').AsString);
    if obsocial.Retieneiva = 'S' then l.Add(detajust.FieldByName('periodo').AsString + detajust.FieldByName('codos').AsString + detajust.FieldByName('idprof').AsString + detajust.FieldByName('items').AsString + detajust.FieldByName('perliq').AsString + detajust.FieldByName('concepto').AsString + ';1' + detajust.FieldByName('importe').AsString);
    detajust.Next;
  end;
  datosdb.QuitarFiltro(detajust);
  detajust.Active := e;
  Result := l;
end;

function TTDistribucionObrasSociales.setListaAjustesIndividualesProfesionalExcluirRetiva(xperiodo, xidprof: String): TStringList;
// Objetivo...: Devolver Ajustes de un Profesional
var
  l: TStringList;
  e: Boolean;
begin
  l := TStringList.Create;
  e := detajust.Active;
  if not detajust.Active then detajust.Open;
  datosdb.Filtrar(detajust, 'perliq = ' + '''' + xperiodo + '''' + ' AND idprof = ' + '''' + xidprof + '''');
  detajust.First;
  while not detajust.Eof do Begin
    obsocial.getDatos(detajust.FieldByName('codos').AsString);
    if obsocial.Retieneiva = 'N' then l.Add(detajust.FieldByName('periodo').AsString + detajust.FieldByName('codos').AsString + detajust.FieldByName('idprof').AsString + detajust.FieldByName('items').AsString + detajust.FieldByName('perliq').AsString + detajust.FieldByName('concepto').AsString + ';1' + detajust.FieldByName('importe').AsString);
    detajust.Next;
  end;
  datosdb.QuitarFiltro(detajust);
  detajust.Active := e;
  Result := l;
end;

procedure TTDistribucionObrasSociales.InicializarMontos(xperiodo: String; xborrar_datos: Boolean);
// Objetivo...: Devolver Ajustes de un Periodo
begin
  if not FileExists(directorio + '\montos.db') then
    utilesarchivos.CopiarArchivos(dbs.DirSistema + '\workliq\inf', '*.*', directorio);
  if xborrar_datos then begin
    if (ExcluirObrasSocialesInscriptas = 2) then datosdb.tranSQL(directorio, 'delete from montos where items >= ' + '''' + 'S' + '''') else
      datosdb.tranSQL(directorio, 'delete from montos');
  end;
  montos := datosdb.openDB('montos', '', '', directorio);
end;

procedure TTDistribucionObrasSociales.InicializarDepositos(xperiodo: String);
// Objetivo...: Inicializar Depositos
begin
  PrepararDirectorio(xperiodo);
  if DirectoryExists(directorio) then Begin
    if not FileExists(directorio + '\depositos.db') then
      utilesarchivos.CopiarArchivos(dbs.DirSistema + '\workliq\depositos', '*.*', directorio);
    depositos := datosdb.openDB('depositos', '', '', directorio);
  end;
end;

function  TTDistribucionObrasSociales.BuscarDeposito(xidprof, xcodbco: String): Boolean;
// Objetivo...: Registrar Depositos
begin
  Result := datosdb.Buscar(depositos, 'idprof', 'codbco', xidprof, xcodbco);
end;

procedure TTDistribucionObrasSociales.RegistrarMontoParaGanancias(xidprof, xnrodist: String; xmonto: Real);
// Objetivo...: Registrar Monto para Ganancias
Begin
  if ganancias.FindKey([xidprof]) then ganancias.Edit else ganancias.Append;
  ganancias.FieldByName('idprof').AsString := xidprof;
  if xnrodist = '01' then ganancias.FieldByName('monto').AsFloat  := xmonto;
  if xnrodist = '02' then ganancias.FieldByName('monto1').AsFloat := xmonto;
  try
    ganancias.Post
   except
    ganancias.Cancel
  end;
  datosdb.refrescar(ganancias);
end;

function TTDistribucionObrasSociales.setMontoParaGanancias(xidprof, xperiodo, xnroliq: String): Real;
// Objetivo...: Retornar Monto para Ganancias
var
  datab, dir: String;
  estado: Boolean;
  l: TStringList;
  i, p: Integer;
  monto: Real;
Begin
  monto  := 0;
  datab  := ganancias.DatabaseName;
  estado := ganancias.Active;
  dir    := dbs.DirSistema + '\distribucion\Ganancias\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
  if (DirectoryExists(dir)) and (FileExists(dir + '\subtotganancias.db')) then Begin
    if ganancias.Active then ganancias.Close;
    ganancias := datosdb.openDB('subtotganancias', '', '', dir);
    ganancias.Open;
    if ganancias.FindKey([xidprof]) then monto := ganancias.FieldByName('monto').AsFloat else monto := 0;

    // Ahora Buscar los CUIT dependientes, para unificar el monto
    l := retenciones.setCuitProfesional(xidprof);
    For i := 1 to l.Count do Begin
      p := Pos(';1', l.Strings[i-1]);
      ganancias.First;
      while not ganancias.Eof do Begin
        if ganancias.FieldByName('idprof').AsString = Copy(l.Strings[i-1], p+2, 6) then monto := monto + ganancias.FieldByName('monto').AsFloat;
        ganancias.Next;
      end;
    end;

    ganancias.Close;
    ganancias := datosdb.openDB('subtotganancias', '', '', datab);
    ganancias.Active := estado;
  end;

  Result := monto;
end;

procedure TTDistribucionObrasSociales.RegistrarDeposito(xperiodo, xidprof, xcodbco, xfecha, xobservacion: String);
// Objetivo...: Registrar Depositos
begin
  InicializarDepositos(xperiodo);
  depositos.Open;
  if BuscarDeposito(xidprof, xcodbco) then depositos.Edit else depositos.Append;
  depositos.FieldByName('idprof').AsString      := xidprof;
  depositos.FieldByName('codbco').AsString      := xcodbco;
  depositos.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
  depositos.FieldByName('observacion').AsString := xobservacion;
  try
    depositos.Post
   except
    depositos.Cancel
  end;
  datosdb.closeDB(depositos);
end;

procedure TTDistribucionObrasSociales.BorrarDeposito(xidprof, xcodbco: String);
// Objetivo...: Borrar Depositos
begin
  depositos.Open;
  if BuscarDeposito(xidprof, xcodbco) then depositos.Delete;
  datosdb.closeDB(depositos);
end;

function  TTDistribucionObrasSociales.setDepositos(xperiodo: String): TStringList;
// Objetivo...: Inicializar Depositos
var
  l: TStringList;
begin
  InicializarDepositos(xperiodo);
  l := TStringList.Create;
  depositos.Open;
  while not depositos.Eof do Begin
    l.Add(depositos.FieldByName('idprof').AsString + depositos.FieldByName('codbco').AsString + utiles.sFormatoFecha(depositos.FieldByName('fecha').AsString) + depositos.FieldByName('observacion').AsString);
    depositos.Next;
  end;
  datosdb.closeDB(depositos);
  Result := l;
end;

function TTDistribucionObrasSociales.setItemsLiquidados(xperiodo: String): TStringList;
// Objetivo...: Devolver Ajustes de un Periodo
var
  l: TStringList;
  t: Boolean;
begin
  l := TStringList.Create;
  t := cabajust.Active;
  if not cabajust.Active then cabajust.Open;
  cabajust.First;
  while not cabajust.Eof do Begin
    l.Add(cabajust.FieldByName('periodo').AsString + cabajust.FieldByName('codos').AsString + cabajust.FieldByName('perliq').AsString + cabajust.FieldByName('importe').AsString + ';1' + cabajust.FieldByName('porcentaje').AsString + ';2' + cabajust.FieldByName('fecha').AsString);
    cabajust.Next;
  end;
  cabajust.Active := t;
  Result := l;
end;

{*******************************************************************************}

procedure TTDistribucionObrasSociales.GuardarDCProf(xperiodo, xidprof, xitems, xidajuste, xdescripaj: String; ximporteaj: Real; xCantidadItems: Integer; xtipomov: Char);
begin
  if ximporteaj <> 0 then Begin
    if datosdb.Buscar(dcprof, 'Periodo', 'Idprof', 'Items', xperiodo, xidprof, xitems) then dcprof.Edit else dcprof.Append;
    dcprof.FieldByName('Periodo').AsString   := xperiodo;
    dcprof.FieldByName('Idprof').AsString    := xidprof;
    dcprof.FieldByName('Items').AsString     := xitems;
    dcprof.FieldByName('Idajuste').AsString  := xidajuste;
    dcprof.FieldByName('Descripaj').AsString := xdescripaj;
    dcprof.FieldByName('Importeaj').AsFloat  := ximporteaj;
    dcprof.FieldByName('Tipomov').AsString   := xtipomov;
    try
      dcprof.Post
     except
      dcprof.Cancel
    end;
  end;
  if xCantidadItems > 0 then
    if StrToInt(xitems) = xCantidadItems then AjustarNroItemsDCProf(xperiodo, xidprof, xCantidadItems, xtipomov);
end;

procedure TTDistribucionObrasSociales.BorrarDCProfFijos;
// Objetivo...: Borrar Items Manuales
Begin
  datosdb.tranSQL(directorio, 'delete from ' + dcprof.TableName + ' where tipomov = ' + '"' + 'F' + '"');
end;

procedure TTDistribucionObrasSociales.BorrarDCProfManuales;
// Objetivo...: Borrar Items Manuales
Begin
  datosdb.tranSQL(directorio, 'delete from ' + dcprof.TableName + ' where tipomov = ' + '"' + 'M' + '"');
end;

procedure TTDistribucionObrasSociales.BorrarDCProfExedentes(xitems: String);
// Objetivo...: Borrar Exedentes
Begin
  datosdb.tranSQL(directorio, 'delete from ' + dcprof.TableName + ' where items > ' + '"' + xitems + '"');
end;

procedure TTDistribucionObrasSociales.AjustarNroItemsDCProf(xperiodo, xidprof: String; xnroitems: Integer; xtipomov: Char);
begin
  datosdb.tranSQL(directorio, 'DELETE FROM ' + dcprof.TableName + ' WHERE Periodo = ' + '"' + xperiodo + '"' + ' AND Idprof = ' + '"' + xidprof + '"' + ' AND Items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xnroitems), 3, '0') + '"' + ' AND tipomov = ' + '"' + xtipomov + '"');
  datosdb.refrescar(dcprof);
end;

function  TTDistribucionObrasSociales.setItemsDCProf(xperiodo: String): TQuery;
begin
  Result := datosdb.tranSQL(directorio, 'SELECT * FROM dcprofes WHERE Periodo = ' + '"' + xperiodo + '"' + ' ORDER BY Tipomov, Idprof, Items');
end;

function TTDistribucionObrasSociales.setListaDCProf(xperiodo, xidprof: String): TStringList;
var
  l: TStringList;
  e: Boolean;
Begin
  l := TStringList.Create; lista4.Clear;
  debitoscreditos.conectar;
  e := dcprof.Active;
  datosdb.Filtrar(dcprof, 'idprof = ' + '''' + xidprof + '''');
  if not dcprof.Active then dcprof.Open;
  dcprof.First;
  while not dcprof.Eof do Begin
    l.Add(dcprof.FieldByName('periodo').AsString + dcprof.FieldByName('idprof').AsString + dcprof.FieldByName('items').AsString + dcprof.FieldByName('descripaj').AsString + ';1' + dcprof.FieldByName('importeaj').AsString + ';2' + dcprof.FieldByName('tipomov').AsString);
    debitoscreditos.getDatos(dcprof.FieldByName('idajuste').AsString);
    if (dcprof.FieldByName('idajuste').AsString = '') or (dcprof.FieldByName('tipomov').AsString = 'M') then     
      lista4.Add('S')
    else
      lista4.Add(debitoscreditos.Liqsepa);
    dcprof.Next;
  end;
  datosdb.QuitarFiltro(dcprof);
  dcprof.Active := e;
  debitoscreditos.desconectar;
  Result := l;
end;

function  TTDistribucionObrasSociales.setItemsDCProf(xperiodo, xidprof: String): TQuery;
begin
  Result := datosdb.tranSQL(directorio, 'SELECT * FROM dcprofes WHERE Periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' ORDER BY Items');
end;

{*******************************************************************************}

procedure TTDistribucionObrasSociales.RecalcularDistribucionProfesional(xperiodo, xperiodoLiq: String; listSel, listDist: TStringList; xobsocial_iva, xganancias, xrecmontos: Boolean; xretieneganancias: String);
// Objetivo...: Recalcular Montos Distribucion a Profesionales
Begin
  noListar := True;
  InfDistribucionProfesional(xperiodo, xperiodoLiq, listSel, listDist, 'P', xobsocial_iva, xganancias, xrecmontos, xretieneganancias);
  noListar := False;
end;

procedure TTDistribucionObrasSociales.InfDistribucionProfesional(xperiodo, xperiodoLiq: String; listSel, listDist: TStringList; salida: Char; xobsocial_iva, xganancias, xrecmontos: Boolean; xretieneganancias: String);
// Objetivo...: Listar Informe Distribucion a Profesionales
var
  l, s: TStringList;
  i, j: Integer;
  archdest: string;

  procedure Terminar();
  begin
    if (salida = 'T') and (exporta_web) then begin
      if not (exporta_web) then RealizarSalto else list.FinalizarExportacion;
      archdest := copy(xperiodo, 1, 2) + copy(xperiodo, 4, 6) + '_' + listSel[i-1] + '_' + tipoinf_web + '.txt';
      CopyFile(PChar(dbs.DirSistema + '\list.txt'), PChar(dbs.DirSistema + '\export_reportes\web_distribucion\' + archdest), false);
    end;
  end;

Begin

  if (exporta_web) then begin
    salida := 'T';
    list.exportar_rep := true;
  end;

  diractual := ''; directorio := ''; unifica_ganancias := False; totganancias := 0;
  PrepararDirectorio(xperiodo);
  InicializarMontos(xperiodo, xrecmontos);
  montos.Open;

  montosret := datosdb.openDB('montosret', '', '', dbs.DirSistema + '\distribucion\dist' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 6));
  montosret.Open;

  InicializarDepositos(xperiodo);
  initxt := false;

  utilesarchivos.BorrarArchivos(dbs.DirSistema + '\export_reportes\web_distribucion', '*.txt');

  For i := 1 to listSel.Count do Begin
    l := retenciones.setCuitProfesional(listSel[i-1]);
    if (l.Count = 0) or not (xganancias) then Begin        // Significa que No estan Unificados los CUIT
      unifica_ganancias := False;
      s := TStringList.Create;
      s.Add(listSel[i-1]);
      ListDistribucionProfesional(xperiodo, xperiodoLiq, s, listDist, salida, xobsocial_iva, False, xretieneganancias);
      s.Destroy;

      Terminar();

    end else Begin

      unifica_ganancias := True;
      totganancias := 0;
      For j := 1 to l.Count do Begin     // Acumulamos los totales en los CUIT Unificados
        unif_cuit  := True;
        s := TStringList.Create;
        s.Add(Copy(l[j-1], 9, 6));
        ListDistribucionProfesional(xperiodo, xperiodoLiq, s, listDist, 'N', xobsocial_iva, xganancias, xretieneganancias);
        s.Destroy;
        unif_cuit  := False;
      end;

      // Ahora largamos la Liquidaci�n, con Ganancias Acumuladas
      s := TStringList.Create;
      s.Add(listSel[i-1]);
      ListDistribucionProfesional(xperiodo, xperiodoLiq, s, listDist, salida, xobsocial_iva, xganancias, xretieneganancias);
      s.Destroy;

      Terminar();

      if (salida = 'T') and (i < listSel.Count) then
        if not (exporta_web) then RealizarSalto;

    end;

    if (salida = 'P') and (i < listSel.Count) then list.CompletarPaginaConNumeracion;
  end;

  datosdb.closeDB(montos);
  datosdb.closeDB(montosret);
  lista3.Clear;

  if salida <> 'T' then
    if (salida = 'P') and not (noListar) then  list.FinList;

  if (salida = 'T') and not (noListar) and (exporta_web = false) then list.FinalizarImpresionModoTexto(1);

end;

procedure TTDistribucionObrasSociales.ListDistribucionProfesional(xperiodo, xperiodoLiq: String; listSel, listDist: TStringList; salida: Char; xobsocial_iva, xganancias: Boolean; xretieneganancias: String);
// Objetivo...: Listar Informe Distribucion a Profesionales - Obtener Resultados Intermedios
const
  filas  = 1500;  //1000
  filas1 = 1500;  //500
var
  i, j, k, m, n, o, z, p1, p2, p3, p4, it, ix, iz, im, cont, indice, indiceot, xxx, ncoss: Integer;
  l, f, listob, listret, zzt, encontroajuste, existe, liq_ganancias: Boolean;

  listP: array[1..filas, 1..8] of String;
  listA: array[1..filas, 1..8] of String;
  listU: array[1..filas, 1..1] of String;
  impOS: array[1..filas, 1..2] of String;
  porOS: array[1..filas, 1..4] of String;

  difOT1: array[1..filas1] of String; // Retiene los Ajustes
  difOT2: array[1..filas1] of String; // para liquidar items retenci�n del centro
  difOT3: array[1..filas1] of String;

  difUB: array[1..filas, 1..5] of String;

  tot: array[1..6] of Real;
  importe, totfinal, porc, porcentajeret, monto_ganancias, totf, montogan, totretiva,
  netofact, totfiva, totub, ajub, monto_ub, minimo_ganancias, tf1, tf2, tf3, coss, tcoss, montocos: Real;
  los, plq, lNeto, lub, lss, lcoseguroperiodo, lcosegurocodos, liqsepa1, liqsepa2: TStringList;
  peranter, formula_ganancias: String;
  rcos, rtcos: TQuery;

  {ExcluirObrasSocialesInscriptas:
    0. Liquidaci�n Convencional
    1. excluir de profesionales inscriptos
    2. solo afectar a los profesionales inscriptos en I.V.A.
  }

  procedure ListarRetencionesSeparadas(xidprof: string; salida: char);
  var
    t: integer;
    tsum: real;
  begin

    if (salida = 'P') or (salida = 'I') then begin
      list.CompletarPaginaConNumeracion;
      list.IniciarNuevaPagina;
    end;
    if (salida = 'T') then RealizarSalto;

    if (salida = 'P') or (salida = 'I') then begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, ' Liquidaci�n de Retenciones', 1, 'Arial, normal, 12', salida, 'N');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    end;

    tsum := 0;
    for t := 1 to liqsepa1.Count do begin
      if (salida = 'P') or (salida = 'I') then begin
        list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(50, list.Lineactual, liqsepa1.Strings[t-1], 2, 'Arial, normal, 8', salida, 'N');
        list.importe(97, list.Lineactual, '', StrToFloat(liqsepa2.Strings[t-1]), 3, 'Arial, normal, 8');
        list.Linea(97, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
      end;
      tsum := tsum + StrToFloat(liqsepa2.Strings[t-1]);
    end;

    totfinal := totfinal - tsum;

    if (salida = 'P') or (salida = 'I') then begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.Derecha(97, list.Lineactual, '', '------------------------', 2, 'Arial, normal, 8');
      list.Linea(98, list.Lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'Subtotal Retenciones:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(97, list.Lineactual, '', tsum, 2, 'Arial, negrita, 8');
      list.Linea(97, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');

      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
      list.Derecha(71, list.Lineactual, '', 'Neto Cobrar:', 2, 'Arial, negrita, 8');
      list.Importe(97, list.Lineactual, '', totfinal, 3, 'Arial, negrita, 8');
      list.Linea(98, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Son Pesos ' + utiles.xIntToLletras(StrToInt(Copy(utiles.FormatearNumero(FloatToStr(totfinal)), 1, Length(Trim(utiles.FormatearNumero(FloatToStr(totfinal)))) - 3))) + ' con ' + Copy(utiles.FormatearNumero(FloatToStr(totfinal)), Length(Trim(utiles.FormatearNumero(FloatToStr(totfinal)))) - 1, 2) + ' centavos.', 1, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    end;

    depositos.Open;
    datosdb.Filtrar(depositos, 'idprof = ' + '''' + xidprof + '''');
    while not depositos.Eof do Begin
      entbcos.getDatos(depositos.FieldByName('codbco').AsString);
      if (salida = 'P') or (salida = 'I') then
        list.Linea(0, 0, '     Acreditado en  ' + entbcos.descrip + ', fecha  ' + utiles.sFormatoFecha(depositos.FieldByName('fecha').AsString), 1, 'Arial, cursiva, 8', salida, 'S');
      if (salida = 'T') then
        list.LineaTxt(CHR(15) + 'Acreditado en  ' + entbcos.descrip + ', fecha  ' + utiles.sFormatoFecha(depositos.FieldByName('fecha').AsString) + CHR(18), True);
      if (length(trim(depositos.FieldByName('observacion').AsString)) > 0) then begin
         if (salida = 'P') or (salida = 'I') then
           list.Linea(0, 0, depositos.FieldByName('observacion').AsString, 1, 'Arial, negrita, 8', salida, 'S');
         if (salida = 'T') then
           list.LineaTxt(CHR(15) + depositos.FieldByName('observacion').AsString + CHR(18), True);
      end;

      depositos.Next;
    end;
    datosdb.QuitarFiltro(depositos);
    depositos.Close;
  end;

Begin
  if (exporta_web) and (salida <> 'N') then begin
    salida := 'T';   
    list.AnularCaracteresTexto;
    list.IniciarImpresionModoTexto;
  end;

  if (salida <> 'N') then Begin
    if (salida <> 'T') then list.CantidadDeCopias(copias);
    if (salida = 'T') and not (exporta_web) then Begin
      if not initxt then list.IniciarImpresionModoTexto;
      initxt := True;
    end;
    if (salida = 'I') then list.Setear(salida);      // 05/05/2011 - Seteo de la impresora
    list.altopag := 0; list.m := 0; list.IniciarTitulos;
    TitulosIFD(salida);
  end;
  list.pagina := 0;
  indice      := 0;
  indiceot    := 0;

  los := TStringList.Create;
  plq := TStringList.Create;
  lss := TStringList.Create;
  lcoseguroperiodo := TStringList.Create;
  lcosegurocodos := TStringList.Create;
  liqsepa1 := TStringList.Create;
  liqsepa2 := TStringList.Create;

  if listSel = Nil then utiles.msgError('No hay Profesional/Laboratorio Seleccionado ...!') else Begin

    datosdb.tranSQL(montosret.DatabaseName, 'delete from ' + montosret.TableName + ' where idprof = ' + '''' + listSel[i] + '''');
    datosdb.refrescar(montosret);

    For i := 0 to listSel.Count - 1 do Begin

      profesional.getDatos(listSel[i]);

      For k := 1 to filas {50} do begin
        For o := 1 to 8 do Begin
          listP[k, o] := ''; listA[k, o] := ''; impOS[k, 1] := ''; impOS[k, 2] := '';
        end;
        listP[k, 3] := '0'; listP[k, 6] := '0';
        if (k <= filas1) then begin
          difOT1[k] := '0'; difOT2[k] := '0'; //difOX6[k] := '0';
        end;
      end;

     if (totfinal <> 0) and (salto = 1) then Begin
       pag := 0;
       if salida <> 'N' then Begin
         if salida <> 'T' then list.IniciarNuevaPagina;
         if salida = 'T' then RealizarSalto;
       end;
     end;

     f := False; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totfinal := 0; totub := 0;
     if Length(Trim(listSel[i])) > 0 then Begin
     // Montos Facturados de cada obra social

     lineaProfesional(listSel[i], xperiodo, salida);

     lista1 := TStringList.Create;
     lista2 := TStringList.Create;

     totales[1] := 0; j := 0; l := False; m := 0; netofact := 0; totub := 0;
     lista1 := setItemsLiquidados(Copy(xperiodo, 1, 7));
     l := True;
     For it := 1 to lista1.Count do Begin
       p1 := Pos(';1', lista1.Strings[it-1]);
       p2 := Pos(';2', lista1.Strings[it-1]);

       if ExcluirObrasSocialesInscriptas = 0 then lista2 := facturacion.setListaTotalFacturadoProfesionales(Copy(lista1.Strings[it-1], 14, 7), listSel[i], Copy(lista1.Strings[it-1], 8, 6));
       if ExcluirObrasSocialesInscriptas = 1 then lista2 := facturacion.setListaTotalFacturadoProfesionalesExcluyendoObrasSocialesInscriptas(Copy(lista1.Strings[it-1], 14, 7), listSel[i]);
       if ExcluirObrasSocialesInscriptas = 2 then Begin
         lista2 := facturacion.setListaTotalFacturadoProfesionalesIncluyendoObrasSocialesInscriptas(Copy(lista1.Strings[it-1], 14, 7), listSel[i]);
         lNeto  := facturacion.setNetoFacturado;   // Para la deducci�n del I.V.A.
       end;
       lub := facturacion.setUBFacturadas;         // Unidades Honorarios

       //For ix := 1 to lista2.Count do list.Linea(0,0, lista1.strings[it-1] + '   ........   ' +  inttostr(lista2.count) + '           ' + lista2.Strings[ix-1], 1, 'Arial, normal, 8', salida, 'S');

       For ix := 1 to lista2.Count do Begin

         if not (l) then Begin
           if (salida = 'P') or (salida = 'I') then Begin
             list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
             list.Linea(0, 0, 'Facturaciones', 1, 'Arial, negrita, 8', salida, 'S');
             list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
           end;
           if salida = 'T' then Begin
             list.LineaTxt('Facturaciones' + CHR(15), True); Inc(lineas); if controlarSalto then TitulosIFD(salida);
             list.LineaTxt(' ', True); Inc(lineas); if controlarSalto then TitulosIFD(salida);
           end;
         end;

         if Copy(lista1.Strings[it-1], 8, 6) = Copy(lista2.Strings[ix-1], 14, 6) then Begin
           obsocial.getDatos(Copy(lista2.Strings[ix-1], 14, 6));

           listob := False;
           if xobsocial_iva then listob := True else
             if obsocial.retencioniva = 0 then listob := True;

           if listob then Begin
             if (length(trim(Copy(lista1.Strings[it-1], p1+2, (p2-2) - p1))) > 0) then
               porc := StrToFloat(Copy(lista1.Strings[it-1], p1+2, (p2-2) - p1))  //if Length(Trim(Copy(lista1.Strings[it-1], p1+2, (p2-2) - p1))) = 0 then utiles.msgError('e1');
             else
               porc := 0;
             if porc = 0 then porc := 100;

             if porc <> 100 then Begin
               Inc(z);
               porOS[z, 1] := Copy(lista2.Strings[ix-1], 14, 6);
               porOS[z, 2] := Trim(Copy(lista2.Strings[ix-1], 20, 15));
               porOS[z, 3] := Copy(lista2.Strings[ix-1], 1, 7);
               // Agregado el 22/10/2008
               porOS[z, 4] := Trim(Copy(lub.Strings[ix-1], 20, 15));
             end;

             // 03/04/2009 - Montos para la retencion del centro
             if (datosdb.Buscar(montosret, 'idprof', 'codos', 'periodo', listSel[i], Copy(lista2.Strings[ix-1], 14, 6), Copy(lista1.Strings[it-1], 14, 7))) then montosret.Edit else montosret.Append;
             montosret.FieldByName('idprof').AsString  := listSel[i];
             montosret.FieldByName('codos').AsString   := Copy(lista2.Strings[ix-1], 14, 6);
             montosret.FieldByName('periodo').AsString := Copy(lista1.Strings[it-1], 14, 7);
             montosret.FieldByName('monto').AsFloat    := StrToFloat(Trim(Copy(lista2.Strings[ix-1], 20, 15)));
             try
               montosret.post
              except
               montosret.cancel
             end;
             datosdb.refrescar(montosret);

             if not f then Begin

               // 28/04/2011 - periodo y codos para prorratear coseguros
               //lcosegurocodos.Add(Copy(lista2.Strings[ix-1], 14, 6));
               //lcoseguroperiodo.Add(Copy(lista1.Strings[it-1], 14, 7));

               f := True;
               if (salida = 'P') or (salida = 'I') then Begin
                 list.Linea(0, 0, Copy(lista2.Strings[ix-1], 14, 6) + '  ' + Copy(obsocial.nombre, 1, 25), 1, 'Arial, normal, 8', salida, 'N');
                 list.Linea(32, list.Lineactual, Copy(lista1.Strings[it-1], 14, 7), 2, 'Arial, normal, 8', salida, 'N');
                 if (Length(trim(Copy(lista2.Strings[ix-1], 20, 15))) > 0) then
                   list.importe(49, list.Lineactual, '',  StrToFloat(Trim(Copy(lista2.Strings[ix-1], 20, 15))), 3, 'Arial, normal, 8')
                 else
                   list.Linea(49, list.lineactual, '',3 , 'Arial, normal, 8', salida, 'N');
               end;
               if salida = 'T' then Begin
                 list.LineaTxt(CHR(15) + Copy(lista2.Strings[ix-1], 14, 6) + ' ' + Copy(obsocial.nombre, 1, 27) + utiles.espacios(28 - Length(TrimRight(Copy(obsocial.nombre, 1, 27)))), False);
                 list.LineaTxt(Copy(lista1.Strings[it-1], 14, 7), False);
                 list.ImporteTxt(StrToFloat(Trim(Copy(lista2.Strings[ix-1], 20, 15))), 10, 2, False);
               end;

             end else Begin

               // 28/04/2011 - periodo y codos para prorratear coseguros
               //lcosegurocodos.Add(Copy(lista2.Strings[ix-1], 14, 6));
               //lcoseguroperiodo.Add(Copy(lista1.Strings[it-1], 14, 7));

               f := False;
               if (salida = 'P') or (salida = 'I') then Begin
                 list.Linea(50, list.lineactual, Copy(lista2.Strings[ix-1], 14, 6) + '  ' + Copy(obsocial.nombre, 1, 25), 4, 'Arial, normal, 8', salida, 'N');
                 list.Linea(82, list.Lineactual, Copy(lista1.Strings[it-1], 14, 7), 5, 'Arial, normal, 8', salida, 'N');
                 if (length(Trim(Copy(lista2.Strings[ix-1], 20, 15))) > 0) then
                   list.importe(98, list.Lineactual, '',  StrToFloat(Trim(Copy(lista2.Strings[ix-1], 20, 15))), 6, 'Arial, normal, 8')
                 else
                   list.Linea(98, list.lineactual, '',6 , 'Arial, normal, 8', salida, 'N');
                 list.Linea(99, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S'); // if Length(trim(Trim(Copy(lista2.Strings[ix-1], 20, 15)))) = 0 then utiles.msgError('e3');
               end;
               if salida = 'T' then Begin
                 list.LineaTxt('  ' + Copy(lista2.Strings[ix-1], 14, 6) + ' ' + Copy(obsocial.nombre, 1, 27) + utiles.espacios(28 - Length(TrimRight(Copy(obsocial.nombre, 1, 27)))), False);
                 list.LineaTxt(Copy(lista1.Strings[it-1], 14, 7), False);
                 list.ImporteTxt(StrToFloat(Trim(Copy(lista2.Strings[ix-1], 20, 15))), 10, 2, True);
                 Inc(lineas); if controlarsalto then TitulosIFD(salida);
               end;
             end;

           end;

         end;

         if Copy(lista1.Strings[it-1], 8, 6) = Copy(lista2.Strings[ix-1], 14, 6) then Begin
           if listob then Begin
             if (length(Trim(Copy(lista2.Strings[ix-1], 20, 15))) > 0) then
               totales[1]  := totales[1] + StrToFloat(Trim(Copy(lista2.Strings[ix-1], 20, 15)));
             if (length(Trim(Copy(lub.Strings[ix-1], 20, 15)) ) > 0) then
               totub       := totub      + StrToFloat(Trim(Copy(lub.Strings[ix-1], 20, 15)));
             if ExcluirObrasSocialesInscriptas = 2 then begin
               //if (ix>10) then utiles.msgerror(inttostr(ix));
               if (ix-1) < lNeto.Count then   // 03/06/2009 -> desborde del indice en liq. de obras sociales exentas de ganancias
                 if (length(Trim(Copy(lNeto.Strings[ix-1], 20, 15))) > 0) then
                   if (ix-1) < lNeto.Count then netofact := netofact + StrToFloat(Trim(Copy(lNeto.Strings[ix-1], 20, 15)));
             end;
             los.Add(Copy(lista2.Strings[ix-1], 14, 6));
           end;
         end;

         if listob then Begin
           Inc(m);
           impOS[m, 1] := obsocial.codos;
           impOS[m, 2] := Trim(Copy(lista2.Strings[ix-1], 20, 15));
           plq.Add(Copy(lista1.Strings[it-1], 14, 7) + Copy(lista2.Strings[ix-1], 14, 6));
         end;

         l := True;
       end;
     end;

     iz := 0;

     if l then Begin
       For k := 1 to j do Begin
         if Length(Trim(listP[k, 1])) = 0 then Break;
         if utiles.verificarItemsLista(los, listP[k, 1]) then Begin
           if (salida = 'P') or (salida = 'I') then Begin
             list.Linea(0, 0, listP[k, 1] + '   ' + Copy(listP[k, 2], 1, 32), 1, 'Arial, normal, 8', salida, 'N');
             list.Linea(32, list.Lineactual, listP[k, 7], 2, 'Arial, normal, 8', salida, 'N');
             if listP[k, 3] = '' then listP[k, 3] := '0';
             list.importe(49, list.Lineactual, '', StrToFloat(listP[k, 3]), 3, 'Arial, normal, 8');
             if utiles.verificarItemsLista(los, listP[k, 4]) then Begin
               list.Linea(50, list.Lineactual, listP[k, 4] + '   ' + listP[k, 5], 4, 'Arial, normal, 8', salida, 'N');
               list.Linea(82, list.Lineactual, listP[k, 8], 5, 'Arial, normal, 8', salida, 'N');  // if Length(Trim(listP[k, 6])) = 0 then utiles.msgError('e4');
               if listP[k, 6] = '' then listP[k, 6] := '0';
               if StrToFloat(listP[k, 6]) <> 0 then Begin
                 list.importe(97, list.Lineactual, '', StrToFloat(listP[k, 6]), 6, 'Arial, normal, 8');
                 list.Linea(98, list.lineactual, ' ', 7, 'Arial, normal, 8', salida, 'S');
               end else
                 list.Linea(98, list.lineactual, ' ', 6, 'Arial, normal, 8', salida, 'S')
             end else
               list.Linea(98, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S')
           end;
           if salida = 'T' then Begin
             list.LineaTxt(listP[k, 1] + ' ' + Copy(listP[k, 2], 1, 27) + utiles.espacios(28 - Length(TrimRight(Copy(listP[k, 2], 1, 27)))), False);
             list.LineaTxt(listP[k, 7], False);
             list.ImporteTxt(StrToFloat(listP[k, 3]), 10, 2, False);
             if utiles.verificarItemsLista(los, listP[k, 4]) then Begin
               list.LineaTxt('  ' + listP[k, 4] + ' ' + Copy(listP[k, 5], 1, 27) + utiles.espacios(28 - Length(TrimRight(Copy(listP[k, 5], 1, 27)))), False);
               list.LineaTxt(listP[k, 8], False);
               if StrToFloat(listP[k, 6]) <> 0 then list.importeTxt(StrToFloat(listP[k, 6]), 10, 2, True) else list.LineaTxt(' ', True);
               Inc(lineas); if controlarsalto then TitulosIFD(salida);
             end else Begin
               list.LineaTxt(' ', True);
               Inc(lineas); if controlarsalto then TitulosIFD(salida);
             end;
           end;
         end;
       end;

       // Subtotales Montos Facturados Obras Sociales
       if (salida = 'P') or (salida = 'I') then Begin
         list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
         list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
         list.Derecha(97, list.Lineactual, '', '------------------------', 2, 'Arial, negrita, 8');
         list.Linea(98, list.Lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');
         list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
         list.Derecha(70, list.Lineactual, '', 'Subtotal Fact. Obras Sociales:', 2, 'Arial, negrita, 8');
         list.Importe(97, list.Lineactual, '', totales[1], 3, 'Arial, negrita, 8');
         list.Linea(98, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
       end;
       if salida = 'T' then Begin
         if not (exporta_web) then begin
           list.LineaTxt(CHR(18), True); Inc(lineas); if controlarsalto then titulosIFD(salida);
           list.LineaTxt(utiles.espacios(65) + '---------------', True); Inc(lineas); if controlarsalto then titulosIFD(salida);
           list.LineaTxt(utiles.espacios(35) + list.modo_resaltado_seleccionar + 'Subtotal Fact. Obras Sociales:', False);
           list.importeTxt(totales[1], 15, 2, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
         end else begin
           list.LineaTxt(CHR(18), True); Inc(lineas); if controlarsalto then titulosIFD(salida);
           list.LineaTxt(utiles.espacios(91) + '---------------', True); Inc(lineas); if controlarsalto then titulosIFD(salida);
           list.LineaTxt(utiles.espacios(61) + list.modo_resaltado_seleccionar + 'Subtotal Fact. Obras Sociales:', False);
           list.importeTxt(totales[1], 15, 2, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
         end;
       end;

       if not unif_cuit then RegistrarTotal(listSel[i], 'AAA', NroLiq, totales[1], 0);

       if (ExcluirObrasSocialesInscriptas <> 2) and (Becasgan) then Begin
         // Tratamiento Unidades Honorarios
         if (salida = 'P') or (salida = 'I') then Begin
           list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
           list.Derecha(70, list.Lineactual, '', 'Subtotal Unidades Honorarios:', 2, 'Arial, negrita, 8');
           list.Importe(97, list.Lineactual, '', totub, 3, 'Arial, negrita, 8');
           list.Linea(98, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
         end;
         if salida = 'T' then Begin
           list.LineaTxt(utiles.espacios(36) + list.modo_resaltado_seleccionar + 'Subtotal Unidades Honorarios:', False);
           list.importeTxt(totub, 15, 2, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
         end;
       end;
     end;

     totfinal := totales[1];
     if (salida = 'P') or (salida = 'I') then list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
     if salida = 'T'  then Begin
       list.LineaTxt(CHR(18) + list.modo_resaltado_cancelar, True); Inc(lineas);
       if controlarsalto then titulosIFD(salida);
     end;

     // Obras Sociales que pagan porcentajes
     f := False; totales[2] := 0; totales[3] := 0; totales[4] := 0;
     For k := 1 to filas {50} do Begin
       listA[k, 1] := ''; listA[k, 2] := '0'; listA[k, 3] := '0'; listA[k, 4] := ''; listA[k, 5] := ''; listA[k, 6] := '0'; listA[k, 7] := ''; listA[k, 8] := '';
     end;

     l := False; j := 0; totales[5] := 0; f := False; totales[8] := 0;
     lista2.Clear;

     For it := 1 to lista1.Count do Begin
       lista2 := facturacion.setListaTotalFacturadoProfesionales(Copy(lista1.Strings[it-1], 14, 7), listSel[i], Copy(lista1.Strings[it-1], 8, 6));
       f := False;
       For ix := 1 to lista2.Count do Begin
         if Copy(lista1.Strings[it-1], 8, 6) = Copy(lista2.Strings[ix-1], 14, 6) then Begin
         if utiles.verificarItemsLista(plq, Copy(lista1.Strings[it-1], 14, 7) + Copy(lista1.Strings[it-1], 8, 6)) then Begin
           getDatos(Copy(xperiodo, 1, 7), Copy(lista1.Strings[it-1], 8, 6), Copy(lista1.Strings[it-1], 14, 7));
           if ((porcentaje > 0) and (porcentaje < 100)) or (porcentaje > 100) then Begin
             if not l then Begin
               if (salida = 'P') or (salida = 'I') then Begin
                 list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
                 list.Linea(0, 0, 'Ajustes', 1, 'Arial, negrita, 9', salida, 'S');
                 list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
               end;
               if salida = 'T' then Begin
                 list.LineaTxt(CHR(18) + list.modo_resaltado_seleccionar + 'Ajustes' + CHR(15) + list.modo_resaltado_cancelar, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
                 list.LineaTxt(' ', True); Inc(lineas); if controlarsalto then titulosIFD(salida);
               end;
             end;

             for k := 1 to 200 do  // Sicronizamos la Obra Social
               if (trim(porOS[k, 1]) = trim(Copy(lista1.Strings[it-1], 8, 6))) and (trim(porOS[k, 3]) = trim(Copy(lista1.Strings[it-1], 14, 7))) then Break;

             obsocial.getDatos(Copy(lista2.Strings[ix-1], 14, 6));
             if Length(Trim(porOS[k, 2])) > 0 then Begin
               Inc(j);
               listA[j, 1] := obsocial.codos;
               listA[j, 2] := obsocial.nombre;
               if (length(trim(porOS[k, 2])) > 0) then
                 listA[j, 3] := FloatToStr(StrToFloat(porOS[k, 2]) * ((100 - porcentaje) * 0.01));
               listA[j, 7] := 'Ajuste ' + utiles.FormatearNumero(FloatToStr(100 - porcentaje)) + '%';
               listA[j, 4] := porOS[k, 3];
               if (length(trim(porOS[k, 4])) > 0) then
                 listU[j, 1] := FloatToStr(StrToFloat(porOS[k, 4]) * ((100 - porcentaje) * 0.01));

               if (length(trim(listA[j, 3])) > 0) then
                 totales[8]  := totales[8] + StrToFloat(listA[j, 3]);
             end;

             l := True;
           end;
         end;
         end;
       end;
     end;

     if l then Begin
       For k := 1 to j do Begin

         For m := 1 to 50 do Begin
           if (listA[k, 1] = impOS[m, 1]) or (listA[k, 4] = impOS[m, 1]) then Begin
             if Length(Trim(impOS[m, 2])) > 0 then importe := StrToFloat(impOS[m, 2]);
             Break;
           end;
         end;
         importe := 10;

         if Length(Trim(listA[k, 1])) = 0 then Break;

         if (salida = 'P') or (salida = 'I') then Begin
           list.Linea(0, 0, listA[k, 1] + '   ' + Copy(listA[k, 2], 1, 32), 1, 'Arial, normal, 8', salida, 'N');
           list.Linea(51, list.Lineactual, listA[k, 7], 2, 'Arial, normal, 8', salida, 'N');
           list.Linea(63, list.Lineactual, listA[k, 4], 3, 'Arial, normal, 8', salida, 'N');
           list.importe(97, list.Lineactual, '', StrToFloat(listA[k, 3]), 4, 'Arial, normal, 8');
           list.Linea(97, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
         end;
         if salida = 'T' then Begin
           list.LineaTxt(listA[k, 1] + ' ' + Copy(listA[k, 2], 1, 27) + utiles.espacios(28 - Length(TrimRight(Copy(listA[k, 2], 1, 27)))), False);
           list.LineaTxt(Copy(listA[k, 7], 1, 15) + utiles.espacios(16 - Length(TrimRight(Copy(listA[k, 7], 1, 15)))), False);
           list.ImporteTxt(StrToFloat(listA[k, 3]), 10, 2, False);
           list.LineaTxt('  ' + listA[k, 4] + ' ' + Copy(listA[k, 5], 1, 27) + utiles.espacios(28 - Length(TrimRight(Copy(listA[k, 5], 1, 27)))), False);
           list.LineaTxt(listA[k, 8], False);
           if StrToFloat(listA[k, 6]) <> 0 then list.importeTxt(StrToFloat(listA[k, 6]), 10, 2, True) else list.LineaTxt(' ', True);
           Inc(lineas); if controlarsalto then TitulosIFD(salida);
         end;
         totales[5]  := totales[5] + (utiles.setNro2Dec(StrToFloat(listA[k, 3])));
         ajub        := ajub       + (utiles.setNro2Dec(StrToFloat(listU[k, 1])));
        end;
      end;

      // Subtotales Montos Facturados Obras Sociales
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
        list.Derecha(97, list.Lineactual, '', '------------------------', 2, 'Arial, negrita, 8');
        list.Linea(98, list.Lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
        list.Derecha(70, list.Lineactual, '', 'Tot. Ajustes:', 2, 'Arial, negrita, 8');
        list.Importe(97, list.Lineactual, '', totales[5], 3, 'Arial, negrita, 8');
        list.Linea(98, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
      end;
      if salida = 'T' then Begin
        if not (exporta_web) then begin
          list.LineaTxt(CHR(18), True); Inc(lineas); if controlarsalto then titulosIFD(salida);
          list.LineaTxt(utiles.espacios(65) + '---------------', True); Inc(lineas); if controlarsalto then TitulosIFD(salida);
          list.LineaTxt(utiles.espacios(46) + list.modo_resaltado_seleccionar + '      Tot. Ajustes:', False);
          list.importeTxt(totales[5], 15, 2, True); Inc(lineas); if controlarsalto then TitulosIFD(salida);
        end else begin
          list.LineaTxt(CHR(18), True); Inc(lineas); if controlarsalto then titulosIFD(salida);
          list.LineaTxt(utiles.espacios(91) + '---------------', True); Inc(lineas); if controlarsalto then TitulosIFD(salida);
          list.LineaTxt(utiles.espacios(72) + list.modo_resaltado_seleccionar + '      Tot. Ajustes:', False);
          list.importeTxt(totales[5], 15, 2, True); Inc(lineas); if controlarsalto then TitulosIFD(salida);
        end;
      end;

      if (ExcluirObrasSocialesInscriptas <> 2) and (Becasgan) then Begin
        // Tratamiento Unidades Honorarios
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
          list.Derecha(70, list.Lineactual, '', 'Tot. Ajustes Unidades Honorarios:', 2, 'Arial, negrita, 8');
          list.Importe(97, list.Lineactual, '', ajub, 3, 'Arial, negrita, 8');
          list.Linea(98, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
        end;
        if salida = 'T' then Begin
          if not (exporta_web) then begin
            list.LineaTxt(utiles.espacios(36) + list.modo_resaltado_seleccionar + 'Tot. Aj. Unidades Honorarios:', False);
            list.importeTxt(ajub, 15, 2, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
          end else begin
            list.LineaTxt(utiles.espacios(72) + list.modo_resaltado_seleccionar + 'Tot. Aj. Unidades Honorarios:', False);
            list.importeTxt(ajub, 15, 2, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
          end;
        end;

        monto_ub := totub - ajub;
      end;

      if salida = 'T' then Begin
        list.LineaTxt(' ' + list.modo_resaltado_cancelar, True); Inc(lineas); if controlarsalto then TitulosIFD(salida);
      end;

      if totales[1] < 0 then list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S') else Begin
        // Ajustes Individuales
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          list.Linea(0, 0, 'Ajuste Obra Social', 1, 'Arial, negrita, 9', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        end;
        if salida = 'T' then Begin
          list.LineaTxt(CHR(18) + list.modo_resaltado_seleccionar + 'Ajuste Obra Social' + list.modo_resaltado_cancelar + CHR(18), True); Inc(lineas); if controlarsalto then TitulosIFD(salida);
          list.LineaTxt(CHR(15), True); Inc(lineas); if controlarsalto then TitulosIFD(salida);
        end;

        lista2.Clear;
        if ExcluirObrasSocialesInscriptas = 0 then Begin
          lista2 := setListaAjustesIndividualesProfesional(Copy(xperiodo, 1, 7), listSel[i]);
        end else Begin
          profesional.SincronizarListaRetIVA(xperiodo, listSel[i]);

          if ExcluirObrasSocialesInscriptas = 2 then lista2 := setListaAjustesIndividualesProfesionalRetiva(Copy(xperiodo, 1, 7), listSel[i]) else
            if profesional.RetieneIva <> 'S' then lista2 := setListaAjustesIndividualesProfesional(Copy(xperiodo, 1, 7), listSel[i]) else
              lista2 := setListaAjustesIndividualesProfesionalExcluirRetiva(Copy(xperiodo, 1, 7), listSel[i]);
        end;

        // Si el profesional esta Excento de I.V.A., los Ajustes se Listan en la tirada general
        if (profesional.Retieneiva <> 'S') and (ExcluirObrasSocialesInscriptas = 2) then lista2.Clear;

        totales[6] := 0;
        For ix := 1 to lista2.Count do Begin
          p1 := Pos(';1', lista2.Strings[ix-1]);
          obsocial.getDatos(Copy(lista2.Strings[ix-1], 8, 6));

          // 03/04/2009 - Montos para la retencion del centro - Ajustes a Obras sociales
          if (datosdb.Buscar(montosret, 'idprof', 'codos', 'periodo', listSel[i], Copy(lista2.Strings[ix-1], 8, 6), Copy(lista2.Strings[ix-1], 1, 7))) then montosret.Edit else montosret.Append;
          montosret.FieldByName('idprof').AsString  := listSel[i];
          montosret.FieldByName('codos').AsString   := Copy(lista2.Strings[ix-1], 8, 6);
          montosret.FieldByName('periodo').AsString := Copy(lista2.Strings[ix-1], 1, 7);
          montosret.FieldByName('retencion').AsFloat := montosret.FieldByName('retencion').AsFloat + StrToFloat(Trim(Copy(lista2.Strings[ix-1], p1 + 2, 15)));
          try
            montosret.post
           except
            montosret.cancel
          end;
          datosdb.refrescar(montosret);

          if (salida = 'P') or (salida = 'I') then Begin
            list.Linea(0, 0, utiles.espacios(15) + Copy(lista2.Strings[ix-1], 30, p1 - 30), 1, 'Arial, normal, 8', salida, 'N');
            list.Linea(45, list.Lineactual, Copy(lista2.Strings[ix-1], 1, 7) + '  ' + obsocial.Nombre, 2, 'Arial, normal, 8', salida, 'N');
            list.importe(97, list.Lineactual, '', StrToFloat(Trim(Copy(lista2.Strings[ix-1], p1 + 2, 15))), 3, 'Arial, normal, 8');
            list.Linea(98, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
          end;
          if salida = 'T' then Begin
            list.LineaTxt(CHR(15) + utiles.espacios(25) + Copy(Copy(lista2.Strings[ix-1], 30, p1-30), 1, 30) + utiles.espacios(31 - Length(TrimRight(Copy(Copy(lista2.Strings[ix-1], 30, p1-30), 1, 30)))), False);
            list.LineaTxt(Copy(lista2.Strings[ix-1], 1, 7) + '  ' + obsocial.Nombre + utiles.espacios(22 - Length(TrimRight(obsocial.Nombre))) + '    ', False);
            list.ImporteTxt(StrToFloat(Trim(Copy(lista2.Strings[ix-1], p1 + 2, 15))), 15, 2, True); Inc(lineas); Inc(lineas); if controlarsalto then TitulosIFD(salida);
          end;
          totales[6] := totales[6] + StrToFloat(Trim(Copy(lista2.Strings[ix-1], p1 + 2, 15)));

          Inc(indiceot); // 08/11/2008 // Ajustes Manuales para Montos Diferenciales
          difOT1[indiceot] := Copy(lista2.Strings[ix-1], 8, 6);
          difOT2[indiceot] := Copy(lista2.Strings[ix-1], 1, 7);
          difOT3[indiceot] := Trim(Copy(lista2.Strings[ix-1], p1 + 2, 15));

          encontroajuste := False;

          if not encontroajuste then Begin   // Obras Sociales con Ajuste pero sin movimientos
            if not retenciones.setPorcentajeDiferencial(Copy(lista2.Strings[ix-1], 8, 6)) then tot[4] := tot[4] + StrToFloat(Trim(Copy(lista2.Strings[ix-1], p1 + 2, 15))) else
              // Solo acumulamos si la obra social esta sujeta a retencion
              if retenciones.setPorcentajeValor(Copy(lista2.Strings[ix-1], 8, 6)) > 0 then tot[5] := tot[5] + StrToFloat(Trim(Copy(lista2.Strings[ix-1], p1 + 2, 15)));
          end;
        end;

        totfinal := totfinal - totales[8];
        totfinal := totfinal + totales[6];
        totfiva  := totfinal;

        // Monto para la Liquidaci�n de Ganancias
        RegistrarMontoGanancias(listSel[i], Copy(xperiodo, 8, 2), totfinal);

        tf1 := totfinal;
        tf2 := monto_ub;
        tf3 := totganancias;

        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
          list.Derecha(97, list.Lineactual, '', '------------------------', 2, 'Arial, negrita, 8');
          list.Linea(98, list.Lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
          list.Derecha(71, list.Lineactual, '', 'Tot. Ajustes Obra Social:', 2, 'Arial, negrita, 8');
          list.Importe(97, list.Lineactual, '', totales[6], 3, 'Arial, negrita, 8');
          list.Linea(98, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
          list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
          list.Derecha(97, list.Lineactual, '', '------------------------', 2, 'Arial, negrita, 8');
          list.Linea(98, list.Lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
          list.Derecha(71, list.Lineactual, '', 'Subtotal:', 2, 'Arial, negrita, 8');
          list.Importe(97, list.Lineactual, '', totfinal, 3, 'Arial, negrita, 8');
          list.Linea(98, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
          if (ExcluirObrasSocialesInscriptas = 2) then Begin // 19/10/2010
            totretiva := totfinal;
          end;
        end;
        if salida = 'T' then Begin
          if not (exporta_web) then begin
            list.LineaTxt(CHR(18), True); Inc(lineas); if controlarsalto then titulosIFD(salida);
            list.LineaTxt(utiles.espacios(44) + list.modo_resaltado_seleccionar + 'Tot. Aj. Obra Social:', False);
            list.importeTxt(totales[6], 15, 2, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
            list.LineaTxt(utiles.espacios(65) + list.modo_resaltado_cancelar + '---------------', True); Inc(lineas); if controlarsalto then titulosIFD(salida);
            list.LineaTxt(utiles.espacios(46) + list.modo_resaltado_seleccionar + '          Subtotal:', False);
            list.importeTxt(totfinal, 15, 2, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
          end else begin
            list.LineaTxt(CHR(18), True); Inc(lineas); if controlarsalto then titulosIFD(salida);
            list.LineaTxt(utiles.espacios(70) + list.modo_resaltado_seleccionar + 'Tot. Aj. Obra Social:', False);
            list.importeTxt(totales[6], 15, 2, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
            list.LineaTxt(utiles.espacios(91) + list.modo_resaltado_cancelar + '---------------', True); Inc(lineas); if controlarsalto then titulosIFD(salida);
            list.LineaTxt(utiles.espacios(72) + list.modo_resaltado_seleccionar + '          Subtotal:', False);
            list.importeTxt(totfinal, 15, 2, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
          end;

          if ExcluirObrasSocialesInscriptas = 2 then Begin
            totretiva := totfinal;
          end;
        end;

        if (ExcluirObrasSocialesInscriptas <> 2) and (Becasgan) then Begin
          if (salida = 'P') or (salida = 'I') then Begin
            list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
            list.Derecha(71, list.Lineactual, '', 'Subtotal Un. Honorarios:', 2, 'Arial, negrita, 8');
            list.Importe(97, list.Lineactual, '', monto_ub, 3, 'Arial, negrita, 8');
            list.Linea(98, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
          end;
          if salida = 'T' then Begin
            list.LineaTxt(utiles.espacios(41) + list.modo_resaltado_seleccionar +   'Subtotal Un. Honorarios:', False);
            list.importeTxt(monto_ub, 15, 2, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
          end;
        end;

        totganancias := totganancias + totfinal;   // Total Unificado para los CUIT
        monto_g      := totganancias;

        if not unif_cuit then RegistrarTotal(listSel[i], 'BBB', NroLiq, totfinal, 0);

        // Ajustes Personales y Retenciones
        if (salida = 'P') or (salida = 'I')  then Begin
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          list.Linea(0, 0, 'Retenciones', 1, 'Arial, negrita, 9', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        end;
        if salida = 'T' then Begin
          list.LineaTxt(CHR(18) + list.modo_resaltado_cancelar, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
          list.LineaTxt(CHR(18) + list.modo_resaltado_seleccionar + 'Retenciones' + list.modo_resaltado_cancelar, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
          list.LineaTxt(CHR(15), True); Inc(lineas); if controlarsalto then titulosIFD(salida);
        end;

        if ExcluirObrasSocialesInscriptas <> 2 then lista2 := setListaDCProf(xperiodo, listSel[i]) else lista2.Clear;

        totales[7] := 0;
        For ix := 1 to lista2.Count do Begin
          p1 := Pos(';1', lista2.Strings[ix-1]);
          p2 := Pos(';2', lista2.Strings[ix-1]);

          totfinal := tf1; //  17/10/2010 retenciones parciales
          monto_ub := tf2;
          totganancias := tf3;

          if (utiles.verificarItemsLista(listdist, Copy(xperiodo, 8, 2))) or (Copy(lista2.Strings[ix-1], p2 + 2, 1) = 'M') then Begin    // Determina las Distribuciones donde se debe aplicar

            // 26/06/2011 - Para Liquidar las retenciones en planilla separada
            //utiles-+.msgError(Copy(lista2.Strings[ix-1], 17, p1 - 17) + '- ' + lista2.Strings[ix-1]);

            if ((LiquidarRetencionesSeparadas) and (lista4.Strings[ix-1] = 'S')) and not (unif_cuit) then begin
               liqsepa1.Add(Copy(lista2.Strings[ix-1], 17, p1 - 17));
               liqsepa2.Add(Trim(Copy(lista2.Strings[ix-1], p1+2, (p2-p1)-2)));
            end else begin
              if (salida = 'P') or (salida = 'I') then Begin
                list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
                list.Linea(50, list.Lineactual, Copy(lista2.Strings[ix-1], 17, p1 - 17), 2, 'Arial, normal, 8', salida, 'N');
                list.importe(97, list.Lineactual, '', StrToFloat(Trim(Copy(lista2.Strings[ix-1], p1+2, (p2-p1)-2))), 3, 'Arial, normal, 8');
                list.Linea(98, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
              end;
              if salida = 'T' then Begin
                list.LineaTxt(CHR(15) + utiles.espacios(25) + Copy(lista2.Strings[ix-1], 17, p1 - 17) + utiles.espacios(66 - Length(TrimRight(Copy(lista2.Strings[ix-1], 17, p1 - 17)))), False);
                list.ImporteTxt(StrToFloat(Trim(Copy(lista2.Strings[ix-1], p1+2, (p2-p1)-2))), 15, 2, True); Inc(lineas); if controlarsalto then TitulosIFD(salida);
              end;
              totales[7] := totales[7] + StrToFloat(Trim(Copy(lista2.Strings[ix-1], p1+2, (p2-p1)-2)));
              if not unif_cuit then RegistrarTotal(listSel[i], Copy(lista2.Strings[ix-1], 14, 3), NroLiq, StrToFloat(Trim(Copy(lista2.Strings[ix-1], p1+2, (p2-p1)-2))), 0);
            end;
            
          end;
        end;
        lista2.Clear;

        if ExcluirObrasSocialesInscriptas = 2 then lista3 := retenciones.setListaItemsRetienenIVA else
          lista3 := retenciones.setListaItems;

        for ix := 1 to lista3.Count do Begin
          p1 := Pos(';1', lista3.Strings[ix-1]);
          p2 := Pos(';2', lista3.Strings[ix-1]);
          p3 := Pos(';3', lista3.Strings[ix-1]);
          if (utiles.verificarItemsLista(listdist, Copy(xperiodo, 8, 2))) or (Copy(lista3.Strings[ix-1], p3 + 2, 1) = 'S') then Begin
            if not xganancias then listret := True else Begin
              if retenciones.BuscarCuitDependiente(Copy(lista3.Strings[ix-1], 1, 2), listSel[i]) then listret := False else listret := True;
            end;
            if listret then Begin
              zzt := False;
              if (salida = 'P') or (salida = 'I') or (salida = 'T') then Begin
                if StrToFloat(Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2))))) = 0 then Begin

                  // Items que tienen porcentaje de retencion directa
                  if not retenciones.setItemsDiferencial(Copy(lista3.Strings[ix-1], 1, 2)) then Begin

                    // Preguntamos a partir de que se hacen las retenciones 15/10/2010
                    retenciones.getDatos(Copy(lista3.Strings[ix-1], 1, 2));
                    if (retenciones.Honorarios = 'S') then becasgan := true else becasgan := false;

                    if (salida = 'P') or (salida = 'I') then Begin
                      list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
                      list.Linea(50, list.Lineactual, Copy(lista3.Strings[ix-1], 3, p1-3), 2, 'Arial, normal, 8', salida, 'N');
                      if becasgan then   // Retenci�n a partir de Unidades Honorarios
                        list.importe(97, list.Lineactual, '', (monto_ub * (retenciones.PorcentajeTot * 0.01) ) * (StrToFloat(Trim(Copy(lista3.Strings[ix-1], p1 + 2, p2-(p1+2)))) * 0.01), 3, 'Arial, normal, 8')
                      else
                        list.importe(97, list.Lineactual, '', (totfinal * (retenciones.PorcentajeTot * 0.01) ) * (StrToFloat(Trim(Copy(lista3.Strings[ix-1], p1 + 2, p2-(p1+2)))) * 0.01), 3, 'Arial, normal, 8');
                      list.Linea(98, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
                    end;
                    if (salida = 'T') then Begin
                      list.LineaTxt(CHR(15) + utiles.espacios(25) + Copy(lista3.Strings[ix-1], 3, p1-3) + utiles.espacios(66 - Length(TrimRight(Copy(lista3.Strings[ix-1], 3, p1-3)))), False);

                      if becasgan then   // Retenci�n a partir de Unidades Honorarios
                        list.importeTxt(monto_ub * (StrToFloat(Trim(Copy(lista3.Strings[ix-1], p1 + 2, p2-(p1+2)))) * 0.01), 15, 2, True)
                      else
                        list.importeTxt(totfinal * (StrToFloat(Trim(Copy(lista3.Strings[ix-1], p1 + 2, p2-(p1+2)))) * 0.01), 15, 2, True);
                      Inc(lineas); if controlarsalto then titulosIFD(salida);
                    end;

                    if becasgan then   // Retenci�n a partir de Unidades Honorarios
                      totales[7] := totales[7] + (monto_ub * (StrToFloat(Trim(Copy(lista3.Strings[ix-1], p1 + 2, p2-(p1+2)))) * 0.01))
                    else
                      totales[7] := totales[7] + (totfinal * (retenciones.PorcentajeTot * 0.01) ) * (StrToFloat(Trim(Copy(lista3.Strings[ix-1], p1 + 2, p2-(p1+2)))) * 0.01); //      (totfinal * (StrToFloat(Trim(Copy(lista3.Strings[ix-1], p1 + 2, p2-(p1+2)))) * 0.01));

                    if not unif_cuit then begin
                      if (ExcluirObrasSocialesInscriptas <> 2) then RegistrarTotal(listSel[i], 'R' + Copy(lista3.Strings[ix-1], 1, 2), NroLiq, (totfinal * (StrToFloat(Trim(Copy(lista3.Strings[ix-1], p1 + 2, p2-(p1+2)))) * 0.01)), totfinal);
                      if (ExcluirObrasSocialesInscriptas = 2) then RegistrarTotal(listSel[i], 'S' + Copy(lista3.Strings[ix-1], 1, 2), NroLiq, (totfinal * (StrToFloat(Trim(Copy(lista3.Strings[ix-1], p1 + 2, p2-(p1+2)))) * 0.01)), totfinal);
                    end

                  end else Begin

                    tot[6] := 0;  //  07/04/2009 - Porcentajes Diferenciales
                    datosdb.Filtrar(montosret, 'idprof = ' + '''' +  listSel[i] + '''');
                    montosret.First;
                    while not montosret.Eof do begin
                      if not retenciones.setPorcentajeDiferencial(montosret.FieldByName('codos').AsString) then tot[1] := tot[1] + ( montosret.FieldByName('monto').AsFloat + montosret.FieldByName('retencion').AsFloat ) else
                        tot[6] := tot[6] + ( montosret.FieldByName('monto').AsFloat * ( retenciones.setPorcentajeDif(montosret.FieldByName('codos').AsString) * 0.01) );

                      montosret.Next;
                    end;
                    datosdb.QuitarFiltro(montosret);

                    tot[4] := 0;
                    if ExcluirObrasSocialesInscriptas = 2 then tot[1] := totretiva;  // tomamos el total despues de descontar el I.V.A.
                    if (length(trim(Copy(lista3.Strings[ix-1], p1 + 2, p2-(p1+2)))) > 0) then
                      if tot[1] > 0 then tot[2] := (tot[1] + tot[4]) * (StrToFloat(Trim(Copy(lista3.Strings[ix-1], p1 + 2, p2-(p1+2)))) * 0.01);  // Obras sociales que retienen porcentaje normal

                    if (salida = 'P') or (salida = 'I') then Begin
                      list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
                      list.Linea(50, list.Lineactual, Copy(lista3.Strings[ix-1], 3, p1-3), 2, 'Arial, normal, 8', salida, 'N');
                      list.importe(97, list.Lineactual, '', tot[2] + tot[3] + tot[6], 3, 'Arial, normal, 8');
                      list.Linea(98, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
                    end;
                    if (salida = 'T') then Begin
                      list.LineaTxt(CHR(15) + utiles.espacios(25) + Copy(lista3.Strings[ix-1], 3, p1-3) + utiles.espacios(66 - Length(TrimRight(Copy(lista3.Strings[ix-1], 3, p1-3)))), False);
                      list.importeTxt(tot[2] + tot[3] + tot[6], 15, 2, True);
                      Inc(lineas); if controlarsalto then titulosIFD(salida);
                    end;

                    totales[7] := totales[7] + (tot[2] + tot[3] + tot[6]);

                    if not unif_cuit then Begin
                      if ExcluirObrasSocialesInscriptas <> 2 then RegistrarTotal(listSel[i], 'R' + Copy(lista3.Strings[ix-1], 1, 2), NroLiq, (tot[2] + tot[3]), totfinal);
                      if ExcluirObrasSocialesInscriptas = 2 then RegistrarTotal(listSel[i], 'S' + Copy(lista3.Strings[ix-1], 1, 2), NroLiq, (tot[2] + tot[3]), totfinal);
                    end;

                  end;

                  zzt := True;
                end;

                profesional.SincronizarListaRetIVA(xperiodo, listSel[i]);

                if not (zzt) and (profesional.AjusteDC = 'S') then Begin

                  totf := totfinal;

                  // Tratamiento diferencial para Ganancias
                  if not unif_cuit then Begin
                    if xretieneganancias = 'S' then Begin  // Recuperamos el Monto del Periodo
                      totfinal     := totfinal + setMontoParaGanancias(listSel[i], PeriodoGanancias, LiquidacionGanancias);
                      totganancias := totfinal;  // Monto a partir del cual se deducira ganancias, incluye cuit unificados
                      if (ExcluirObrasSocialesInscriptas <> 2) and (Becasgan) then // Para los casos de unidades honorarios
                        totganancias := monto_ub;
                    end;
                    if xretieneganancias = 'N' then Begin
                      if ExcluirObrasSocialesInscriptas <> 2 then RegistrarMontoParaGanancias(listSel[i], '01', totfinal);
                    end;
                  end;

                  //------------------------------------------------------------
                  // Recupera el monto minimo imponible - 08/05/2007
                  minimo_ganancias := StrToFloat(Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2)))));

                  // Si el monto minimo imponible ya se consumio en un periodo anterior, lo ponemos en cero - 08/05/2007
                  if AplicarMinimoGanancias = 1 then Begin
                    if Copy(xperiodo, 8, 2) = '01' then Begin    // Deducimos el periodo para ver si consumio el minimo consumo
                      peranter := utiles.RestarPeriodo(Copy(xperiodo, 1, 7), '1') + '02';
                      if verificarConsumoGanancias(listSel[i], peranter) then minimo_ganancias := 0;
                    end;
                  end;

                  if AplicarMinimoGanancias = 2 then Begin
                    if Copy(xperiodo, 8, 2) = '02' then Begin
                      peranter := Copy(xperiodo, 1, 7) + '01';
                      if verificarConsumoGanancias(listSel[i], peranter) then minimo_ganancias := 0;
                    end;
                  end;

                  //------------------------------------------------------------

                  // Verificamos si retiene ganancias del total o de las unidades honorario, a partir de ahi, vemos el
                  // total que tomamos - 15/10/2010
                  retenciones.getDatos(Copy(lista3.Strings[ix-1], 1, 2));
                  if (retenciones.Honorarios = 'S') then totfinal := monto_ub else totfinal := tf1;
                  totfinal := totfinal * (retenciones.PorcentajeTot * 0.01);  // 17/10/2010 aplicamos porcentaje sobre el total

                  // Verifica si se liquidan los per�odos por Separado
                  if LiqIndi_Ganancias then retenciones.getPorcentaje(Copy(lista3.Strings[ix-1], 1, 2), totfinal - minimo_ganancias) else
                    retenciones.getPorcentaje(Copy(lista3.Strings[ix-1], 1, 2), totfinal - StrToFloat(Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2))))));

                  if not retenciones.BuscarCuitDependiente(listSel[i]) then Begin  // Impuesto a las ganancias si es que el laboratorio No calcula en otro cuit
                    //if (LiqIndi_ganancias) then utiles.msgerror(floattostr(totfinal) + '  ' + Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2)))));

                    if ((StrToFloat(Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2))))) > 0) and (totfinal > StrToFloat(Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2))))))) or (totganancias > StrToFloat(Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2)))))) then Begin
                      if not unifica_ganancias then Begin
                        if (totfinal - StrToFloat(Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2))))) > 0) then Begin

                          if xretieneganancias = 'S' then Begin    // Solo Aplicamos Ganancias si est� estipulado en el Per�odo

                            if retenciones.PorcentajeGan > 0 then
                              monto_ganancias := retenciones.MontoFijo + ( ((totfinal - minimo_ganancias {StrToFloat(Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2)))))}) - retenciones.MontoExedente ) * (retenciones.PorcentajeGan * 0.01));

                            formula_ganancias := '(' + utiles.FormatearNumero(FloatToStr(retenciones.MontoFijo)) + ' + ( ((' + utiles.FormatearNumero(FloatToStr(totfinal)) + ' - ' + utiles.FormatearNumero(FloatToStr(minimo_ganancias)) + ') - ' + utiles.FormatearNumero(FloatToStr(retenciones.MontoExedente)) + ' ) * (' + utiles.FormatearNumero(FloatToStr(retenciones.PorcentajeGan)) + ' * 0.01))';

                            Liq_ganancias := true;

                            if (ExcluirObrasSocialesInscriptas <> 2) and (Becasgan) then // Para los casos de unidades honorarios
                              if monto_ub - StrToFloat(Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2))))) > 0 then Begin
                                retenciones.getPorcentaje(Copy(lista3.Strings[ix-1], 1, 2), monto_ub - StrToFloat(Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2))))));
                                monto_ganancias := retenciones.MontoFijo + ( ((monto_ub - minimo_ganancias) - retenciones.MontoExedente ) * (retenciones.PorcentajeGan * 0.01));
                              end;

                            //--------------------------------------------------
                            // Marcamos el Per�odo de Ganancias Pagado - 08/05/2007
                            if minimo_ganancias > 0 then MarcarConsumoGanancias(listSel[i], Copy(xperiodo, 8, 2), 'S') else
                              MarcarConsumoGanancias(listSel[i], Copy(xperiodo, 8, 2), 'N');
                            //utiles.msgError(listSel[i] + '  ' + Copy(xperiodo, 8, 2));
                            //--------------------------------------------------

                            if (salida = 'P') or (salida = 'I') then Begin
                              list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
                              list.Linea(50, list.Lineactual, Copy(lista3.Strings[ix-1], 3, p1-3), 2, 'Arial, normal, 8', salida, 'N');
                              list.importe(97, list.Lineactual, '', monto_ganancias, 3, 'Arial, normal, 8');
                              list.Linea(98, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');

                              if verFormulaGanancias then Begin
                                list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
                                list.Linea(50, list.Lineactual, formula_ganancias, 2, 'Arial, normal, 8', salida, 'S');
                              end;
                            end;
                            if (salida = 'T') then Begin
                              list.LineaTxt(CHR(15) + utiles.espacios(25) + Copy(lista3.Strings[ix-1], 3, p1-3) + utiles.espacios(66 - Length(TrimRight(Copy(lista3.Strings[ix-1], 3, p1-3)))), False);
                              list.importeTxt(monto_ganancias, 15, 2, True);
                              Inc(lineas); if controlarsalto then titulosIFD(salida);

                              if verFormulaGanancias then Begin
                                list.LineaTxt(CHR(15) + utiles.espacios(25) + formula_ganancias, True);
                                Inc(lineas); if controlarsalto then titulosIFD(salida);
                              end;

                            end;

                            totales[7] := totales[7] + monto_ganancias;

                            if not unif_cuit then RegistrarTotal(listSel[i], 'R' + Copy(lista3.Strings[ix-1], 1, 2), NroLiq, monto_ganancias, totfinal);

                          end;
                        end;

                      end else Begin

                        // Cuit unificados
                        totganancias := monto_g;   // monto_g tiene la sumatoria de los montos de los cuits independientes

                        if xretieneganancias = 'S' then Begin

                          {if totganancias - StrToFloat(Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2))))) > 0 then Begin
                            retenciones.getPorcentaje(Copy(lista3.Strings[ix-1], 1, 2), totganancias - StrToFloat(Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2))))));
                           }
                          {if retenciones.porcentajeGan > 0 then
                            monto_ganancias := retenciones.MontoFijo + ( ((totganancias - StrToFloat(Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2)))))) - retenciones.MontoExedente ) * (retenciones.PorcentajeGan * 0.01));}

                          //------------------------------------------------------------
                          // Recupera el monto minimo imponible - 08/05/2007
                          minimo_ganancias := StrToFloat(Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2)))));

                          // Si el monto minimo imponible ya se consumio en un periodo anterior, lo ponemos en cero - 08/05/2007
                          if AplicarMinimoGanancias = 1 then Begin
                            if Copy(xperiodo, 8, 2) = '01' then Begin
                              peranter := utiles.RestarPeriodo(Copy(xperiodo, 1, 7), '1') + '02';
                              if verificarConsumoGanancias(listSel[i], peranter) then minimo_ganancias := 0;
                            end;
                          end;

                          if AplicarMinimoGanancias = 2 then Begin
                            if Copy(xperiodo, 8, 2) = '02' then Begin
                              peranter := Copy(xperiodo, 1, 7) + '01';
                              if verificarConsumoGanancias(listSel[i], peranter){Copy(xperiodo, 8, 2))} then minimo_ganancias := 0;
                            end;
                          end;

                          if totganancias - StrToFloat(Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2))))) > 0 then Begin
                            retenciones.getPorcentaje(Copy(lista3.Strings[ix-1], 1, 2), totganancias - minimo_ganancias);

                          //------------------------------------------------------------

                          if retenciones.PorcentajeGan > 0 then
                            monto_ganancias := retenciones.MontoFijo + ( ((totganancias - minimo_ganancias {StrToFloat(Trim(Copy(lista3.Strings[ix-1], p2 + 2, (p3 - (p2+2)))))}) - retenciones.MontoExedente ) * (retenciones.PorcentajeGan * 0.01));

                          formula_ganancias := '(' + utiles.FormatearNumero(FloatToStr(retenciones.MontoFijo)) + ' + ( ((' + utiles.FormatearNumero(FloatToStr(totganancias)) + ' - ' + utiles.FormatearNumero(FloatToStr(minimo_ganancias)) + ' - ' + utiles.FormatearNumero(FloatToStr(retenciones.MontoExedente)) + ' ) * (' + utiles.FormatearNumero(FloatToStr(retenciones.PorcentajeGan)) + ' * 0.01))';

                          //--------------------------------------------------
                          // Marcamos el Per�odo de Ganancias Pagado - 08/05/2007
                          if minimo_ganancias > 0 then MarcarConsumoGanancias(listSel[i], Copy(xperiodo, 8, 2), 'S') else
                            MarcarConsumoGanancias(listSel[i], Copy(xperiodo, 8, 2), '');
                          //utiles.msgError(listSel[i] + '  ' + Copy(xperiodo, 8, 2));
                          //--------------------------------------------------

                          if (salida = 'P') or (salida = 'I') then Begin
                            list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
                            list.Linea(50, list.Lineactual, Copy(lista3.Strings[ix-1], 3, p1-3), 2, 'Arial, normal, 8', salida, 'N');
                            list.importe(97, list.Lineactual, '', monto_ganancias, 3, 'Arial, normal, 8');
                            list.Linea(98, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');

                            if verFormulaGanancias then Begin
                              list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
                              list.Linea(50, list.Lineactual, formula_ganancias, 2, 'Arial, normal, 8', salida, 'S');
                            end;
                          end;
                          if (salida = 'T') then Begin
                            list.LineaTxt(CHR(15) + utiles.espacios(25) + Copy(lista3.Strings[ix-1], 3, p1-3) + utiles.espacios(66 - Length(TrimRight(Copy(lista3.Strings[ix-1], 3, p1-3)))), False);
                            list.importeTxt(monto_ganancias, 15, 2, True);
                            Inc(lineas); if controlarsalto then titulosIFD(salida);

                            if verFormulaGanancias then Begin
                              list.LineaTxt(CHR(15) + utiles.espacios(25) + formula_ganancias, True);
                              Inc(lineas); if controlarsalto then titulosIFD(salida);
                            end;
                          end;

                          totales[7] := totales[7] + monto_ganancias;
                          if not unif_cuit then RegistrarTotal(listSel[i], 'R' + Copy(lista3.Strings[ix-1], 1, 2), NroLiq, monto_ganancias, totganancias);
                        end;
                      end;
                    end;
                  end;

                  end;

                  // Verificamos si retiene ganancias del total o de las unidades honorario, a partir de ahi, vemos el
                  // total que tomamos - 15/10/2010
                  retenciones.getDatos(Copy(lista3.Strings[ix-1], 1, 2));
                  if (retenciones.Honorarios = 'S') then totganancias := monto_ub else totganancias := tf1;
                  totganancias := totganancias * (retenciones.PorcentajeTot * 0.01);  // 17/10/2010 aplicamos porcentaje sobre el total

                  // Retenci�n directa de ganancias - 19/05/2009, cuando el monto es inferior a $ 1200
                  // retenciones.BuscarCuitDependiente(listSel[i] agregado el 22/07/2009
                  if (monto_ganancias = 0) and (not Liq_ganancias) and (xretieneganancias = 'S') and (not unif_cuit) and not (retenciones.BuscarCuitDependiente(listSel[i])) then begin
                    retenciones.getPorcentaje(Copy(lista3.Strings[ix-1], 1, 2), totganancias);

                    monto_ganancias := totganancias * (retenciones.PorcentajeGan * 0.01);

                    formula_ganancias := '(' + utiles.FormatearNumero(FloatToStr(totganancias)) + ' * (' + utiles.FormatearNumero(FloatToStr(retenciones.PorcentajeGan)) + ' * 0.01))';

                    if (salida = 'P') or (salida = 'I') then Begin
                      list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
                      list.Linea(50, list.Lineactual, Copy(lista3.Strings[ix-1], 3, p1-3), 2, 'Arial, normal, 8', salida, 'N');
                      list.importe(97, list.Lineactual, '', monto_ganancias, 3, 'Arial, normal, 8');
                      list.Linea(98, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');

                      if verFormulaGanancias then Begin
                       list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
                       list.Linea(50, list.Lineactual, formula_ganancias, 2, 'Arial, normal, 8', salida, 'S');
                      end;
                    end;
                    if (salida = 'T') then Begin
                      list.LineaTxt(CHR(15) + utiles.espacios(25) + Copy(lista3.Strings[ix-1], 3, p1-3) + utiles.espacios(66 - Length(TrimRight(Copy(lista3.Strings[ix-1], 3, p1-3)))), False);
                      list.importeTxt(monto_ganancias, 15, 2, True);
                      Inc(lineas); if controlarsalto then titulosIFD(salida);

                      if verFormulaGanancias then Begin
                        list.LineaTxt(CHR(15) + utiles.espacios(25) + formula_ganancias, True);
                        Inc(lineas); if controlarsalto then titulosIFD(salida);
                      end;
                     end;

                     totales[7] := totales[7] + monto_ganancias;
                     if not unif_cuit then RegistrarTotal(listSel[i], 'R' + Copy(lista3.Strings[ix-1], 1, 2), NroLiq, monto_ganancias, totganancias);

                  end;

                  totfinal := totf;

                end;

              end;
            end;
          end;
        end;

        // Coseguros -----------------------------------------------------------
        // 26/04/2011

        if (ExcluirObrasSocialesInscriptas = 1) then begin

          lcosegurocodos.Clear; lcoseguroperiodo.Clear;
          cabajust.First;
          while not cabajust.eof do begin
            if (coseguro.verificarCoseguro(cabajust.FieldByName('perliq').asstring, cabajust.FieldByName('codos').asstring)) then begin
              lcosegurocodos.Add(cabajust.FieldByName('codos').asstring);
              lcoseguroperiodo.Add(cabajust.FieldByName('perliq').asstring);
            end;
            cabajust.Next;
          end;

          for ncoss := 1 to lcosegurocodos.Count do begin

            if (coseguro.verificarCoseguro(lcoseguroperiodo.Strings[ncoss-1])) then begin
              rcos := auditoriacb.getCoseguros(lcosegurocodos.Strings[ncoss-1], listSel[i], lcoseguroperiodo.Strings[ncoss-1]);
              rcos.Open; tcoss := 0;
              while not rcos.Eof do begin
                coss := coseguro.getCoseguro(lcosegurocodos.Strings[ncoss-1], lcoseguroperiodo.Strings[ncoss-1]);
                montocos := rcos.FieldByName('monto').AsFloat * (coss * 0.01);
                if (salida = 'P') or (salida = 'I') then Begin
                  obsocial.getDatos(rcos.FieldByName('codos').AsString);
                  list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
                  list.Linea(50, list.Lineactual, 'Cos. Per. ' + lcoseguroperiodo.Strings[ncoss-1] + ' ' + rcos.FieldByName('codos').AsString + ' ' + copy(obsocial.Nombre,1, 25), 2, 'Arial, normal, 8', salida, 'N');
                  list.importe(97, list.Lineactual, '', montocos, 3, 'Arial, normal, 8');
                  list.Linea(98, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');

                  RegistrarTotal(listSel[i], 'R04', NroLiq, montocos, 0);
                End;

                tcoss := tcoss + montocos;

                rcos.Next;
              end;
              rcos.Close; rcos.Free;
            end;

          end;

        end;

        //----------------------------------------------------------------------

        totales[7] := totales[7] + tcoss;

        //----------------------------------------------------------------------

        if totales[7] <> 0 then Begin
          if (salida = 'P') or (salida = 'I') then Begin
            list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
            list.Derecha(97, list.Lineactual, '', '------------------------', 2, 'Arial, negrita, 8');
            list.Linea(98, list.Lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');
            list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
            list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
            list.Derecha(72, list.Lineactual, '', 'Subtotal Retenciones:', 2, 'Arial, negrita, 8');
            list.Importe(97, list.Lineactual, '', totales[7], 3, 'Arial, negrita, 8');
            list.Linea(98, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
          end;
          if salida = 'T' then Begin
            if not (exporta_web) then begin
              list.LineaTxt(CHR(18) + utiles.espacios(65) + '---------------', True); Inc(lineas); if controlarsalto then titulosIFD(salida);
              list.LineaTxt(utiles.espacios(44) + list.modo_resaltado_seleccionar + 'Subtotal Retenciones:', False);
              list.ImporteTxt(totales[7], 15, 2, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
            end else begin
              list.LineaTxt(CHR(18) + utiles.espacios(91) + '---------------', True); Inc(lineas); if controlarsalto then titulosIFD(salida);
              list.LineaTxt(utiles.espacios(70) + list.modo_resaltado_seleccionar + 'Subtotal Retenciones:', False);
              list.ImporteTxt(totales[7], 15, 2, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
            end;
          end;
        end;

        if ExcluirObrasSocialesInscriptas = 2 then totfinal := totfiva;
        totfinal := totfinal - totales[7];

        // Verificamos si el saldo final debe ser cero
        if (Length(Trim(conceptoSaldo)) > 0) and (totfinal < 0) then Begin
          if (salida = 'P') or (salida = 'I') then Begin
            list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
            list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
            list.Linea(50, list.Lineactual, conceptoSaldo, 2, 'Arial, normal, 8', salida, 'N');
            list.importe(97, list.Lineactual, '', totfinal, 3, 'Arial, normal, 8');
            list.Linea(98, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
          end;
          if salida = 'T' then Begin
            list.LineaTxt(chr(15), True);  Inc(lineas); if controlarsalto then titulosIFD(salida);
            list.LineaTxt(utiles.espacios(25) + chr(15) + conceptoSaldo + utiles.espacios(66 - Length(TrimRight(conceptoSaldo))), False);
            list.importeTxt(totfinal, 15, 2, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
          end;
          totfinal := 0;
        end;

        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
          list.Derecha(71, list.Lineactual, '', 'Neto Cobrar:', 2, 'Arial, negrita, 8');
          list.Importe(97, list.Lineactual, '', totfinal, 3, 'Arial, negrita, 8');
          list.Linea(98, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          list.Linea(0, 0, 'Son Pesos ' + utiles.xIntToLletras(StrToInt(Copy(utiles.FormatearNumero(FloatToStr(totfinal)), 1, Length(Trim(utiles.FormatearNumero(FloatToStr(totfinal)))) - 3))) + ' con ' + Copy(utiles.FormatearNumero(FloatToStr(totfinal)), Length(Trim(utiles.FormatearNumero(FloatToStr(totfinal)))) - 1, 2) + ' centavos.', 1, 'Arial, negrita, 8', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
          if not (LiquidarRetencionesSeparadas) then begin
            depositos.Open;
            datosdb.Filtrar(depositos, 'idprof = ' + '''' + listSel[i] + '''');
            while not depositos.Eof do Begin
              entbcos.getDatos(depositos.FieldByName('codbco').AsString);
              list.Linea(0, 0, 'Acreditado en  ' + entbcos.descrip + ', fecha  ' + utiles.sFormatoFecha(depositos.FieldByName('fecha').AsString), 1, 'Arial, cursiva, 8', salida, 'S');

              if (length(trim(depositos.FieldByName('observacion').AsString)) > 0) then begin
                if (salida = 'P') or (salida = 'I') then
                  list.Linea(0, 0, depositos.FieldByName('observacion').AsString, 1, 'Arial, negrita, 8', salida, 'S');
                if (salida = 'T') then
                  list.LineaTxt(CHR(15) + depositos.FieldByName('observacion').AsString + CHR(18), True);
              end;

              depositos.Next;
            end;
            datosdb.QuitarFiltro(depositos);
            depositos.Close;
          end;
        end;
        if (salida = 'T') and not (LiquidarRetencionesSeparadas) then Begin
          if not (exporta_web) then begin
            list.LineaTxt(utiles.espacios(65) + list.modo_resaltado_cancelar + '---------------', True); Inc(lineas); if controlarsalto then titulosIFD(salida);
            list.LineaTxt(utiles.espacios(44) + list.modo_resaltado_seleccionar + '       Neto a Cobrar:', False);
            list.ImporteTxt(totfinal, 15, 2, True); inc(lineas); if controlarsalto then titulosIFD(salida);
            list.LineaTxt('' + list.modo_resaltado_cancelar, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
            list.LineaTxt(list.modo_cursivo_seleccionar + 'Son Pesos ' + utiles.xIntToLletras(StrToInt(Copy(utiles.FormatearNumero(FloatToStr(totfinal)), 1, Length(Trim(utiles.FormatearNumero(FloatToStr(totfinal)))) - 3))) + ' con ' + Copy(utiles.FormatearNumero(FloatToStr(totfinal)), Length(Trim(utiles.FormatearNumero(FloatToStr(totfinal)))) - 1, 2) + ' centavos.' + list.modo_cursivo_cancelar, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
            list.LineaTxt(CHR(18) + '', True); if controlarsalto then titulosIFD(salida);
          end else begin
            list.LineaTxt(utiles.espacios(91) + list.modo_resaltado_cancelar + '---------------', True); Inc(lineas); if controlarsalto then titulosIFD(salida);
            list.LineaTxt(utiles.espacios(70) + list.modo_resaltado_seleccionar + '       Neto a Cobrar:', False);
            list.ImporteTxt(totfinal, 15, 2, True); inc(lineas); if controlarsalto then titulosIFD(salida);
            list.LineaTxt('' + list.modo_resaltado_cancelar, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
            list.LineaTxt(list.modo_cursivo_seleccionar + 'Son Pesos ' + utiles.xIntToLletras(StrToInt(Copy(utiles.FormatearNumero(FloatToStr(totfinal)), 1, Length(Trim(utiles.FormatearNumero(FloatToStr(totfinal)))) - 3))) + ' con ' + Copy(utiles.FormatearNumero(FloatToStr(totfinal)), Length(Trim(utiles.FormatearNumero(FloatToStr(totfinal)))) - 1, 2) + ' centavos.' + list.modo_cursivo_cancelar, True); Inc(lineas); if controlarsalto then titulosIFD(salida);
            list.LineaTxt(CHR(18) + '', True); if controlarsalto then titulosIFD(salida);
          end;

          if not (LiquidarRetencionesSeparadas) then begin
            depositos.Open;
            datosdb.Filtrar(depositos, 'idprof = ' + '''' + listSel[i] + '''');
            while not depositos.Eof do Begin
              entbcos.getDatos(depositos.FieldByName('codbco').AsString);
              list.LineaTxt(CHR(15) + 'Acreditado en  ' + entbcos.descrip + ', fecha  ' + utiles.sFormatoFecha(depositos.FieldByName('fecha').AsString) + CHR(18), True);
              depositos.Next;
            end;
            datosdb.QuitarFiltro(depositos);
            depositos.Close;
          end;
        end;

        if (LiquidarRetencionesSeparadas) and not (unif_cuit) then ListarRetencionesSeparadas(listSel[i], salida);

       end;
      end;

    end;

    lista1.Destroy; lista2.Destroy;

    if salida = 'I' then list.FinList;
  end;

end;

procedure TTDistribucionObrasSociales.TitulosIFD(salida: Char);
// Objetivo...: Listar Titulos Informe distribuci�n del personal
Begin
  titulos.conectar;
  titulos.getDatos;
  if (salida = 'P') or (salida = 'I') then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.ListMemoTitulos('actividad', 'Arial, negrita, 11', 0, salida, titulos.tabla, 500);
    list.ListMemoTitulos('direccion', 'Arial, negrita, 10', 0, salida, titulos.tabla, 500);
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
    list.Titulo(0, 0, 'C�digo   Obra Social', 1, 'Arial, cursiva, 8');
    list.Titulo(32, list.Lineactual, 'Per�odo', 2, 'Arial, cursiva, 8');
    list.Titulo(43, list.Lineactual, 'Importe', 3, 'Arial, cursiva, 8');
    list.Titulo(50, list.Lineactual, 'C�digo   Obra Social', 4, 'Arial, cursiva, 8');
    list.Titulo(82, list.Lineactual, 'Per�odo', 5, 'Arial, cursiva, 8');
    list.Titulo(92, list.Lineactual, 'Importe', 6, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, cursiva, 5');
  end;
  if salida = 'T' then Begin
    lineas := 0;
    list.LineaTxt(CHR(18) + list.modo_resaltado_seleccionar, True);
    lineas := lineas + list.ListMemoTitulos('actividad', 'Arial, negrita, 11', 0, salida, titulos.tabla, 500);
    lineas := lineas + list.ListMemoTitulos('direccion', 'Arial, negrita, 11', 0, salida, titulos.tabla, 500);
    list.LineaTxt(list.modo_resaltado_cancelar + CHR(15), True);
    list.LineaTxt('Codigo   Obra Social               Periodo   Importe  Codigo   Obra Social               Periodo   Importe' + CHR(18), True);
    list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-') + CHR(15), True);
    list.LineaTxt(' ', True);
    lineas := lineas + 5;
  end;
  titulos.desconectar;
end;

procedure TTDistribucionObrasSociales.lineaProfesional(xidprof, xperiodo: String; salida: char);
// Objetivo...: Listar Datos de Profesional
var
  tliq: string;
Begin
  if (ExcluirObrasSocialesInscriptas = 2) then tliq := ' (Prepagas)' else tliq := ' (Obras Sociales)';
  
  profesional.getDatos(xidprof);
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, 'Profesional:   ' + profesional.codigo + '   ' + profesional.nombre + tliq, 1, 'Arial, negrita, 9, clNavy', salida, 'S');
    list.Linea(0, 0, 'C.U.I.T. N�:   ' + profesional.Nrocuit, 1, 'Arial, negrita, 9, clNavy', salida, 'N');
    list.Linea(81, list.Lineactual, 'Per�odo:   ' + Copy(xperiodo, 1, 7) + '-' + Copy(xperiodo, 8, 2), 2, 'Arial, negrita, 9, clNavy', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  end;
  if salida = 'T' then Begin
    list.LineaTxt(CHR(18) + list.modo_resaltado_seleccionar + 'Profesional: ' + profesional.codigo + '  ' + profesional.nombre + tliq + list.modo_resaltado_cancelar, True); Inc(lineas); if controlarSalto then TitulosIFD(salida);
    list.LineaTxt(CHR(18) + list.modo_resaltado_seleccionar + 'C.U.I.T.   : ' + profesional.Nrocuit + utiles.espacios(45 - Length(TrimRight('Periodo: ' + xperiodo))) + 'Periodo: ' + Copy(xperiodo, 1, 7) + '-' + Copy(xperiodo, 8, 2) + list.modo_resaltado_cancelar, True); Inc(lineas); if controlarSalto then TitulosIFD(salida);
    list.LineaTxt(' ', True); Inc(lineas); if controlarSalto then TitulosIFD(salida);
  end;
end;

function TTDistribucionObrasSociales.ControlarSalto: boolean;
// Objetivo...: salto de linea para las impresiones basadas en texto
var
  k: Integer;
begin
  Result := False;
  if lineas >= LineasPag then Begin
    if salto = 0 then list.LineaTxt(CHR(12), True) else
      for k := 1 to salto do list.LineaTxt('', True);
    Result := True;
  end;
end;

procedure TTDistribucionObrasSociales.RealizarSalto;
// Objetivo...: imprimir lineas en blanco hasta realizar salto de p�gina
var
  k: Integer;
begin
  if salto = 0 then list.LineaTxt(CHR(12), True) else Begin
    for k := lineas + 1 to LineasPag do list.LineaTxt('', True);
    lineas := LineasPag + 5;
    ControlarSalto;
  end;
end;

procedure TTDistribucionObrasSociales.ConfigurarInforme(xreporte: String; xcopias, xsalto: ShortInt);
// Objetivo...: Configurar datos de informes
begin
  if not ctrlImpr.Active then ctrlImpr.Open;  
  if not ctrlImpr.FindKey([xreporte]) then ctrlImpr.Append else ctrlImpr.Edit;
  ctrlImpr.FieldByName('reporte').AsString := xreporte;
  ctrlImpr.FieldByName('copias').AsInteger := xcopias;
  ctrlImpr.FieldByName('salto').AsInteger  := xsalto;
  try
    ctrlImpr.Post
   except
    ctrlImpr.Cancel
  end;
  if xsalto = 1 then list.visruptura := True else list.visruptura := False;
end;

procedure TTDistribucionObrasSociales.getConfiguracionInforme(xreporte: String);
// Objetivo...: Obtener datos de configuracion
begin
  if not ctrlImpr.Active then ctrlImpr.Open;
  if ctrlImpr.FindKey([xreporte]) then Begin
    copias := ctrlImpr.FieldByName('copias').AsInteger;
    salto  := ctrlImpr.FieldByName('salto').AsInteger;
  end else Begin
    copias := 1; salto := 0;
  end;
end;

procedure TTDistribucionObrasSociales.ListarObrasSocialesLiquidadas(xlista: TStringList; xperiodo: String; salida: Char);
// Objetivo...: Listar Obras Sociales Liquidadas
var
  i, p1, p2: Integer;
Begin
  totales[1] := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida);
    list.altopag := 0; list.m := 0;
    list.IniciarTitulos;
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Inf. Obras Sociales Liquidadas - Per�odo: ' + xperiodo, 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Fecha       Per�odo', 1, 'Arial, cursiva, 8');
    list.Titulo(15, list.Lineactual, 'C�d.        Obra Social', 2, 'Arial, cursiva, 8');
    list.Titulo(77, list.Lineactual, 'Monto Liq.', 3, 'Arial, cursiva, 8');
    list.Titulo(89, list.Lineactual, 'Porcentaje', 4, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  end;
  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto;
    titulo1(xperiodo);
  end;
  lista1 := setItemsLiquidados(xperiodo);
  For i := 1 to lista1.Count do Begin
    if utiles.verificarItemsLista(xlista, Copy(lista1.Strings[i-1], 8, 6)) then Begin
      obsocial.getDatos(Copy(lista1.Strings[i-1], 8, 6));
      p1 := Pos(';1', lista1.Strings[i-1]);
      p2 := Pos(';2', lista1.Strings[i-1]);
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, utiles.sFormatoFecha(Copy(lista1.Strings[i-1], p2+2, 8)) + '   ' + Copy(lista1.Strings[i-1], 14, 7), 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(15, list.Lineactual, obsocial.codos + '  ' + obsocial.Nombre, 2, 'Arial, normal, 8', salida, 'N');
        list.importe(85, list.Lineactual, '', StrToFloat(Copy(lista1.Strings[i-1], 21, (p1-2) - 19)), 3, 'Arial, normal, 8');
        list.importe(95, list.Lineactual, '', StrToFloat(Copy(lista1.Strings[i-1], p1+2, (p2-2) - p1)), 4, 'Arial, normal, 8');
        list.Linea(96, list.Lineactual, '%', 5, 'Arial, normal, 8', salida, 'S');
      end;
      if salida = 'T' then Begin
        list.LineaTxt(utiles.sFormatoFecha(Copy(lista1.Strings[i-1], p2+2, 8)) + ' ' + Copy(lista1.Strings[i-1], 14, 7) + ' ', False);
        list.LineaTxt(obsocial.codos + ' ' + Copy(obsocial.Nombre, 1, 30) + utiles.espacios(32 - Length(TrimRight(Copy(obsocial.Nombre, 1, 30)))), False);
        list.importeTxt(StrToFloat(Copy(lista1.Strings[i-1], 21, (p1-2) - 19)), 10, 2, False);
        list.importeTxt(StrToFloat(Copy(lista1.Strings[i-1], p1+2, (p2-2) - p1)), 10, 2, False);
        list.LineaTxt('%', True);
        Inc(lineas); if controlarsalto then titulo1(xperiodo);
      end;
      totales[1] := totales[1] + StrToFloat(Copy(lista1.Strings[i-1], 21, (p1-2) - 21));
    end;
  end;
  lista1.Destroy;
  if totales[1] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(85, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
      list.Linea(86, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
    end;
    if salida = 'T' then Begin
      list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True); Inc(lineas); if controlarsalto then titulo1(xperiodo);
      list.LineaTxt('Subtotal:' + utiles.espacios(47), False);
      list.importeTxt(totales[1], 10, 2, True); Inc(lineas); if controlarsalto then titulo1(xperiodo);
    end;
  end;

  if (salida = 'P') or (salida = 'I') then list.FinList;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
end;

procedure TTDistribucionObrasSociales.ListarResumenLisquidacion(xperiodo: String; salida: char; xrecalcular_montos: Boolean);
// Objetivo...: Listar Resumen Obras Sociales Liquidadas
Begin
  list.altopag := 0; list.m := 0;
  totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Resumen de la Distribuci�n - Per�odo: ' + Copy(xperiodo, 1, 7) + '-' + Copy(xperiodo, 8, 2), 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Concepto', 1, 'Arial, cursiva, 9');
    list.Titulo(89, list.Lineactual, 'Monto', 2, 'Arial, cursiva, 9');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
  end;
  if (salida = 'T') then Begin
    list.IniciarImpresionModoTexto;
    titulo2(xperiodo);
  end;

  verificarPeriodo(xperiodo);
  InicializarMontos(xperiodo, False);
  retenciones.conectar;
  montos.Open;
  ListarMontos('A', xperiodo, salida);
  ListarMontos('B', xperiodo, salida);
  ListarMontos('R', xperiodo, salida);
  ListarMontos('J', xperiodo, salida);
  datosdb.closeDB(montos);
  retenciones.desconectar;

  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'NETO', 1, 'Arial, negrita, 9', salida, 'N');
    list.Linea(50, list.Lineactual, ':', 2, 'Arial, negrita, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', (totales[3]) - (totales[4] + totales[5]), 3, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  end;
  if (salida = 'T') then Begin
    list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True); Inc(lineas); if controlarsalto then titulo1(xperiodo);
    list.LineaTxt(list.modo_resaltado_seleccionar + 'NETO' + utiles.espacios(32) + ':' + utiles.espacios(30), False);
    list.importeTxt((totales[3]) - (totales[4] + totales[5]), 11, 2, False);
    list.LineaTxt(list.modo_resaltado_cancelar, True); Inc(lineas); if controlarsalto then titulo2(xperiodo);
  end;

  InicializarDepositos(xperiodo);
  depositos.Open;
  while not depositos.Eof do Begin
    if totales[1] = 0 then Begin
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, 'Dep�sitos Efectuados', 1, 'Arial, negrita, 9', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end;
      if (salida = 'T') then Begin
        list.LineaTxt('', True); Inc(lineas); if controlarsalto then titulo1(xperiodo);
        list.LineaTxt(list.modo_resaltado_seleccionar + 'Depositos Efectuados' + list.modo_resaltado_cancelar, True); Inc(lineas); if controlarsalto then titulo2(xperiodo);
      end;
      totales[1] := 1;
    end;
    profesional.getDatos(depositos.FieldByName('idprof').AsString);
    entbcos.getDatos(depositos.FieldByName('codbco').AsString);
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, depositos.FieldByName('idprof').AsString + '  ' + profesional.nombre, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(45, list.Lineactual, entbcos.descrip, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(68, list.Lineactual, utiles.sFormatoFecha(depositos.FieldByName('fecha').AsString), 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(75, list.Lineactual, depositos.FieldByName('observacion').AsString, 4, 'Arial, normal, 8', salida, 'S');
    end;
    if (salida = 'T') then Begin
      list.LineaTxt(CHR(15) + depositos.FieldByName('idprof').AsString + ' ' + Copy(profesional.nombre, 1, 30) + utiles.espacios(31 - Length(TrimRight(Copy(profesional.Nombre, 1, 30)))) +
                    Copy(entbcos.descrip, 1, 25) + utiles.espacios(26 - Length(TrimRight(Copy(entbcos.descrip, 1, 26)))) + utiles.sFormatoFecha(depositos.FieldByName('fecha').AsString) + ' ' +
                    Copy(depositos.FieldByName('observacion').AsString, 1, 20) + CHR(18), True); Inc(lineas); if controlarsalto then titulo2(xperiodo);
    end;
    depositos.Next;
  end;
  depositos.Close;

  if (salida = 'P') or (salida = 'I') then list.FinList;
  if (salida = 'T') then list.FinalizarImpresionModoTexto(1);
end;

procedure TTDistribucionObrasSociales.ListarMontos(xfiltro, xperiodo: String; salida: char);
// Objetivo...: Listar Montos
var
  descrip, idanter: String;
Begin
  montos.IndexFieldNames := 'Items';
  if xfiltro = 'A' then datosdb.Filtrar(montos, 'items = ' + '''' + 'AAA' + '''');
  if xfiltro = 'B' then datosdb.Filtrar(montos, 'items = ' + '''' + 'BBB' + '''');
  if xfiltro = 'R' then datosdb.Filtrar(montos, 'items >= ' + '''' + 'R00' + '''' + ' and items <= ' + '''' + 'S99' + '''');
  if xfiltro = 'J' then datosdb.Filtrar(montos, 'items >= ' + '''' + '000' + '''' + ' and items <= ' + '''' + '999' + '''');

  if xfiltro = 'A' then descrip := 'BRUTO';
  if xfiltro = 'B' then descrip := 'AJUSTE OBRA SOCIAL';

  while not montos.Eof do Begin
    if (xfiltro = 'R') or (xfiltro = 'S') then Begin       // Retenciones
      if (montos.FieldByName('items').AsString <> idanter) and (totales[1] <> 0) then ListItemsRetenciones(idanter, xperiodo, salida);
      idanter := montos.FieldByName('items').AsString;
    end;
    if xfiltro = 'J' then Begin       // Ajustes
      if (montos.FieldByName('items').AsString <> idanter) and (totales[1] <> 0) then ListItemsAjustes(idanter, xperiodo, salida);
      idanter := montos.FieldByName('items').AsString;
    end;
    totales[1] := totales[1] + montos.FieldByName('monto').AsFloat;
    montos.Next;
  end;

  if (xfiltro = 'R') and (totales[1] <> 0) then ListItemsRetenciones(idanter, xperiodo, salida);
  if (xfiltro = 'J') and (totales[1] <> 0) then ListItemsAjustes(idanter, xperiodo, salida);

  datosdb.QuitarFiltro(montos);

  if xfiltro = 'A' then totales[2] := totales[1];
  if xfiltro = 'B' then totales[3] := totales[1];

  if xfiltro = 'A' then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, UpperCase(descrip), 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(50, list.Lineactual, ':', 2, 'Arial, normal, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', totales[1], 3, 'Arial, normal, 9');
      list.Linea(95, list.Lineactual, '', 4, 'Arial, normal, 9', salida, 'S');
    end;
    if (salida = 'T') then Begin
      list.LineaTxt(Copy(UpperCase(descrip), 1, 30) + utiles.espacios(31 - Length(TrimRight(Copy(descrip, 1, 30)))) + '     :' + utiles.espacios(30), False);
      list.importeTxt(totales[1], 11, 2, True); Inc(lineas); if controlarsalto then titulo2(xperiodo);
    end;
  end;

  if (xfiltro = 'B') then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, UpperCase(descrip), 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(50, list.Lineactual, ':', 2, 'Arial, normal, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', totales[2] - totales[3], 3, 'Arial, normal, 9');
      list.Linea(95, list.Lineactual, '', 4, 'Arial, normal, 9', salida, 'S');

      list.Linea(0, 0, 'NETO PARCIAL', 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(50, list.Lineactual, ':', 2, 'Arial, normal, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', totales[1], 3, 'Arial, normal, 9');
      list.Linea(95, list.Lineactual, '', 4, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end;
    if (salida = 'T') then Begin
      list.LineaTxt(Copy(UpperCase(descrip), 1, 30) + utiles.espacios(31 - Length(TrimRight(Copy(descrip, 1, 30)))) + '     :' + utiles.espacios(30), False);
      list.importeTxt(totales[2] - totales[3], 11, 2, True); Inc(lineas); if controlarsalto then titulo2(xperiodo);

      list.LineaTxt(list.modo_resaltado_seleccionar + 'NETO PARCIAL' + utiles.espacios(24) + ':' + utiles.espacios(30), False);
      list.importeTxt(totales[1], 11, 2, False);
      list.LineaTxt(list.modo_resaltado_cancelar, True); Inc(lineas); if controlarsalto then titulo2(xperiodo);
    end;
  end;

  if (xfiltro = 'R') and (totales[1] <> 0) then ListItemsRetenciones(idanter, xperiodo, salida);
  if (xfiltro = 'J') and (totales[1] <> 0) then ListItemsAjustes(idanter, xperiodo, salida);

  montos.IndexFieldNames := 'Idprof;Items';

  totales[1] := 0;
end;

procedure TTDistribucionObrasSociales.ListItemsRetenciones(idanter, xperiodo: String; salida: char);
// Objetivo...: Listar Items
var
  descrip: string;
Begin
  retenciones.getDatos(Copy(idanter, 2, 2));
  if (retenciones.descrip <> '') then descrip := UpperCase(retenciones.Descrip) else begin
    if (idanter = 'R04') then descrip := 'COSEGUROS';
  end;

  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, descrip, 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(50, list.Lineactual, ':', 2, 'Arial, normal, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[1], 3, 'Arial, normal, 9');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, normal, 9', salida, 'S');
  end;
  if (salida = 'T') then Begin
    list.LineaTxt(Copy(UpperCase(descrip), 1, 30) + utiles.espacios(31 - Length(TrimRight(Copy(retenciones.Descrip, 1, 30)))) + '     :' + utiles.espacios(30), False);
    list.importeTxt(totales[1], 11, 2, True); Inc(lineas); if controlarsalto then titulo2(xperiodo);
  end;
  totales[4] := totales[4] + totales[1];
  totales[1] := 0;
end;

procedure TTDistribucionObrasSociales.ListItemsAjustes(idanter, xperiodo: String; salida: char);
// Objetivo...: Listar Items
var
  r: TQuery;
Begin
  r := datosdb.tranSQL(directorio, 'select descripaj from dcprofes where items = ' + '''' + idanter + '''');
  r.Open;
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, UpperCase(r.FieldByName('descripaj').AsString), 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(50, list.Lineactual, ':', 2, 'Arial, normal, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[1], 3, 'Arial, normal, 9');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, normal, 9', salida, 'S');
  end;
  if (salida = 'T') then Begin
    list.LineaTxt(Copy(UpperCase(r.FieldByName('descripaj').AsString), 1, 30) + utiles.espacios(31 - Length(TrimRight(Copy(r.FieldByName('descripaj').AsString, 1, 30)))) + '     :' + utiles.espacios(30), False);
    list.ImporteTxt(totales[1], 11, 2, True); Inc(lineas); if controlarsalto then titulo2(xperiodo);
  end;
  totales[5] := totales[5] + totales[1];
  totales[1] := 0;
end;

procedure TTDistribucionObrasSociales.ListarResumenRetenciones(xperiodo: String; xlista: TStringList; salida: char);
// Objetivo...: Listar Retenciones
var
  idanter, riva: String;
Begin
  totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida); list.m := 0;
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Resumen de Retenciones de la Distribuci�n - Per�odo: ' + Copy(xperiodo, 1, 7) + '-' + Copy(xperiodo, 8, 2), 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, '    C�digo', 1, 'Arial, cursiva, 8');
    list.Titulo(9, list.Lineactual, 'Profesional o Laboratorio', 2, 'Arial, cursiva, 8');
    list.Titulo(45, list.Lineactual, 'C.U.I.T. Nro.', 3, 'Arial, cursiva, 8');
    list.Titulo(57, list.Lineactual, 'Total Sujeto a Retenci�n', 4, 'Arial, cursiva, 8');
    list.Titulo(87, list.Lineactual, 'Retenci�n', 5, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
  end;
  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto;
    titulo3(xperiodo);
  end;

  retenciones.conectar;
  verificarPeriodo(xperiodo);
  InicializarMontos(xperiodo, False);
  montos.Open;
  datosdb.Filtrar(montos, 'items >= ' + '''' + 'R00' + '''' + ' and items <= ' + '''' + 'S99' + '''');

  montos.IndexFieldNames := 'Items';
  montos.First; totales[1] := 0; totales[2] := 0;

  while not montos.Eof do Begin
    if (utiles.verificarItemsLista(xlista, Copy(montos.FieldByName('items').AsString, 2, 2))) and (montos.FieldByName('monto').AsFloat > 0) then Begin
      if not retenciones.BuscarCuitDependiente(Copy(montos.FieldByName('items').AsString, 2, 2), montos.FieldByName('idprof').AsString) then Begin
        if Copy(montos.FieldByName('items').AsString, 2, 2) <> idanter then Begin
          if totales[1] > 0 then ListarTotalRetencion(xperiodo, salida);
          retenciones.getDatos(Copy(montos.FieldByName('items').AsString, 2, 2));
          if (salida = 'P') or (salida = 'I') then Begin
            if Length(Trim(idanter)) > 0 then list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
            list.Linea(0, 0, 'Retenci�n:  ' + retenciones.Items + ' - ' + retenciones.Descrip, 1, 'Arial, negrita, 8', salida, 'S');
          end;
          if salida = 'T' then Begin
            if Length(Trim(idanter)) > 0 then list.LineaTxt('', True);
            Inc(lineas); if controlarsalto then titulo3(xperiodo);
            list.LineaTxt(list.modo_resaltado_seleccionar + 'Retenci�n:  ' + retenciones.Items + ' - ' + retenciones.Descrip + list.modo_resaltado_cancelar, True); Inc(lineas); if controlarsalto then titulo3(xperiodo);
          end;
          idanter := Copy(montos.FieldByName('items').AsString, 2, 2);
        end;

        if Copy(montos.FieldByName('items').AsString, 1, 1) = 'S' then riva := ' - (R.I.)' else riva := '';

        profesional.getDatos(montos.FieldByName('idprof').AsString);
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, '    ' + montos.FieldByName('idprof').AsString, 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(9, list.Lineactual, Copy(profesional.Nombre + riva, 1, 50), 2, 'Arial, normal, 8', salida, 'N');
          list.Linea(45, list.Lineactual, profesional.Nrocuit, 3, 'Arial, normal, 8', salida, 'N');
          list.importe(75, list.Lineactual, '', montos.FieldByName('total').AsFloat, 4, 'Arial, normal, 8');
          list.importe(95, list.Lineactual, '', montos.FieldByName('monto').AsFloat, 5, 'Arial, normal, 8');
          list.Linea(95, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
        end;
        if salida = 'T' then Begin
          list.LineaTxt(CHR(15) + '  ' + montos.FieldByName('idprof').AsString + ' ' + Copy(profesional.Nombre, 1, 40) + utiles.espacios(41 - Length(TrimRight(Copy(profesional.nombre, 1, 40)))) + ' ' + profesional.Nrocuit, False);
          list.ImporteTxt(montos.FieldByName('total').AsFloat, 11, 2, False);
          list.ImporteTxt(montos.FieldByName('monto').AsFloat, 11, 2, True);
          Inc(lineas); if controlarsalto then titulo3(xperiodo);
        end;
        totales[1] := totales[1] + utiles.setNro2Dec(montos.FieldByName('total').AsFloat);
        totales[2] := totales[2] + utiles.setNro2Dec(montos.FieldByName('monto').AsFloat);
      end;
    end;
    montos.Next;
  end;
  if totales[1] > 0 then ListarTotalRetencion(xperiodo, salida);

  datosdb.QuitarFiltro(montos);
  datosdb.closeDB(montos);
  retenciones.desconectar;

  if (salida = 'P') or (salida = 'I') then list.FinList;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
end;

procedure TTDistribucionObrasSociales.ListarTotalRetencion(xperiodo: String; salida: char);
Begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, list.Linealargopagina(salida),  1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(75, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
  end;
  if salida = 'T' then Begin
    list.LineaTxt(CHR(18) + utiles.sLlenarIzquierda(lin, 80, '-'), True);
    Inc(lineas); if controlarsalto then titulo3(xperiodo);
    list.LineaTxt(CHR(15) + 'Subtotal:' + utiles.espacios(55), False);
    list.ImporteTxt(totales[1], 11, 2, False);
    list.ImporteTxt(totales[2], 11, 2, True);
    Inc(lineas); if controlarsalto then titulo3(xperiodo);
  end;
  totales[1] := 0; totales[2] := 0;
end;

procedure TTDistribucionObrasSociales.ListarMontosRetGanancias(xperiodo: String; salida: char);
// Objetivo...: Listar Resumen para el C�lculo de Ganancias
Begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.IniciarTitulos;
    list.Setear(salida); list.m := 0; list.altopag := 0;
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Montos para la Retenci�n de Ganancias - Per�odo: ' + Copy(xperiodo, 1, 7) + '-' + Copy(xperiodo, 8, 2), 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'C�digo', 1, 'Arial, cursiva, 8');
    list.Titulo(8, list.Lineactual, 'Profesional o Laboratorio', 2, 'Arial, cursiva, 8');
    list.Titulo(62, list.Lineactual, 'Total Liq. 1', 3, 'Arial, cursiva, 8');
    list.Titulo(82, list.Lineactual, 'Total Liq. 2', 4, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
  end;
  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto;
    titulo4(xperiodo);
  end;

  ganancias.First; totales[1] := 0;
  while not ganancias.Eof do Begin
    profesional.getDatos(ganancias.FieldByName('idprof').AsString);
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, profesional.codigo + ' - ' + profesional.nombre, 1, 'Arial, normal, 8', salida, 'N');
      list.importe(70, list.Lineactual, '', ganancias.FieldByName('monto').AsFloat, 2, 'Arial, normal, 8');
      list.importe(90, list.Lineactual, '', ganancias.FieldByName('monto1').AsFloat, 3, 'Arial, normal, 8');
      list.Linea(92, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
    end;
    if salida = 'T' then Begin
      list.LineaTxt(profesional.codigo + '-' + Copy(profesional.Nombre, 1, 40) + utiles.espacios(41 - Length(TrimRight(Copy(profesional.nombre, 1, 40)))), False);
      list.ImporteTxt(ganancias.FieldByName('monto').AsFloat, 12, 2, False);
      list.ImporteTxt(ganancias.FieldByName('monto1').AsFloat, 14, 2, True);
      Inc(lineas); if controlarsalto then titulo4(xperiodo);
    end;
    totales[1] := 1;
    ganancias.Next;
  end;

  if totales[1] = 0 then
    if (salida = 'P') or (salida = 'I') then list.Linea(0,0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 12', salida, 'N');

  if (salida = 'P') or (salida = 'I') then list.FinList;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
end;

{-------------------------------------------------------------------------------}

function TTDistribucionObrasSociales.verificarPeriodo(xperiodo: String): Boolean;
Begin
  directorio := dbs.DirSistema + '\distribucion\dist' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 6);
  if not DirectoryExists(directorio) then Result := False else Result := True;
end;

procedure TTDistribucionObrasSociales.PrepararDirectorio(xperiodo: String);
// Objetivo...: Preparar Directorio para Liquidaci�n
Begin
  if Length(Trim(xperiodo)) > 7 then Begin
    directorio := dbs.DirSistema + '\distribucion\dist' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 6);
    Pergan     := Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
    NroLiq     := Copy(xperiodo, 8, 2);
    if not (DirectoryExists(directorio)) {and (Length(Trim(Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 6))) > 8)} then Begin
      utilesarchivos.CrearDirectorio(directorio);
      utilesarchivos.CopiarArchivos(dbs.DirSistema + '\workliq', '*.*', directorio);
    end;
    // Montos para la Liquidacion de Ganancias
    if not DirectoryExists(dbs.DirSistema + '\workliq\Ganancias') then
      utilesarchivos.CrearDirectorio(dbs.DirSistema + '\workliq\Ganancias');

    if not FileExists(dbs.DirSistema + '\workliq\Ganancias\subtotganancias.db') then
      datosdb.tranSQL(dbs.DirSistema + '\workliq\Ganancias', 'create table subtotganancias (idprof char(6), monto numeric, monto1 numeric, primary key(idprof))');
    if not FileExists(dbs.DirSistema + '\workliq\Ganancias\subtotalesLiq.db') then
      datosdb.tranSQL(dbs.DirSistema + '\workliq\Ganancias', 'create table subtotalesLiq (idprof char(6), nroliq char(2), monto numeric, monto1 numeric, consumo char(1), primary key(idprof, nroliq))');

    if not DirectoryExists(dbs.DirSistema + '\distribucion\Ganancias') then utilesarchivos.CrearDirectorio(dbs.DirSistema + '\distribucion\Ganancias');
    if not DirectoryExists(dbs.DirSistema + '\distribucion\Ganancias\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4)) then utilesarchivos.CrearDirectorio(dbs.DirSistema + '\distribucion\Ganancias\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4));

    if not FileExists(dbs.DirSistema + '\distribucion\Ganancias\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4) + '\subtotganancias.db') then
      utilesarchivos.CopiarArchivos(dbs.DirSistema + '\workliq\Ganancias', 'subtotganancias.*', dbs.DirSistema + '\distribucion\Ganancias\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4));
    if not FileExists(dbs.DirSistema + '\distribucion\Ganancias\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4) + '\subtotalesLiq.db') then
      utilesarchivos.CopiarArchivos(dbs.DirSistema + '\workliq\Ganancias', 'subtotalesLiq.*', dbs.DirSistema + '\distribucion\Ganancias\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4));

    utilesarchivos.CopiarArchivos(dbs.DirSistema + '\workliq\temp', 'montosret.*', directorio);

    if (directorio <> diractual) or (diractual = '') then SeleccionarPeriodo(directorio);  // Conectamos al directorio seleccionado
  end;
end;

function  TTDistribucionObrasSociales.setNroDistribucion(xperiodo: String): String;
// Objetivo...: Seleccionar un periodo determinado
var
  dir: String;
Begin
  InicializarDepositos(xperiodo);
  NroLiq := '01';
  dir := dbs.DirSistema + '\distribucion\dist' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
  if DirectoryExists(dir + '02') then NroLiq := '02' else
    if DirectoryExists(dir + '01') then NroLiq := '01';
  directorio := dir + NroLiq;
  Result := NroLiq;
end;

procedure TTDistribucionObrasSociales.SeleccionarPeriodo(xperiodo: String);
// Objetivo...: Seleccionar un periodo determinado
Begin
  directorio := xperiodo;
  InstanciarTablas(directorio);
  diractual  := directorio;
  if not cabajust.Active      then cabajust.Open;
  if not detajust.Active      then detajust.Open;
  if not dcprof.Active        then dcprof.Open;
  if not ganancias.Active     then ganancias.Open;
  if not subtotalesLiq.Active then subtotalesLiq.Open;
end;

procedure TTDistribucionObrasSociales.InstanciarTablas(xperiodo: String);
Begin
  refrescar;
  if cabajust <> Nil then
    if cabajust.Active then datosdb.closeDB(cabajust);
  if detajust <> Nil then
    if detajust.Active then datosdb.closeDB(detajust);
  if dcprof <> Nil then
    if dcprof.Active   then dcprof.Close;
  if ganancias <> Nil then
    if ganancias.Active then ganancias.Close;
  if subtotalesLiq <> Nil then
    if subtotalesLiq.Active then subtotalesLiq.Close;
  cabajust  := nil; detajust := nil; dcprof := nil; ganancias := nil;
  cabajust      := datosdb.openDB('cabajustesind', 'Periodo;Codos', '', xperiodo);
  detajust      := datosdb.openDB('detajindiv', 'Periodo;Codos;Idprof;Items', '', xperiodo);
  dcprof        := datosdb.openDB('dcprofes', 'Periodo;Idprof;Items', '', xperiodo);
  ganancias     := datosdb.openDB('subtotganancias', '', '', dbs.DirSistema + '\distribucion\Ganancias\' + pergan);
  subtotalesLiq := datosdb.openDB('subtotalesLiq', '', '', dbs.DirSistema + '\distribucion\Ganancias\' + pergan);
end;

procedure TTDistribucionObrasSociales.RegistrarTotal(xidprof, xitems, xnrodist: String; xmonto, xtotal: Real);
// Objetivo...: Vaciar Buffer de datos
Begin
  if datosdb.Buscar(montos, 'idprof', 'items', xidprof, xitems) then montos.Edit else montos.Append;
  montos.FieldByName('idprof').AsString  := xidprof;
  montos.FieldByName('items').AsString   := xitems;
  montos.FieldByName('nrodist').AsString := xnrodist;
  montos.FieldByName('monto').AsFloat    := xmonto;
  montos.FieldByName('total').AsFloat    := xtotal;
  try
    montos.Post
   except
    montos.Cancel
  end;
  datosdb.refrescar(montos);
end;

function  TTDistribucionObrasSociales.BuscarControlLiq(xperiodo, xperiodoliq, xcodos: String): Boolean;
// Objetivo...: Buscar Control
Begin
  Result := datosdb.Buscar(controlLiq, 'periodo', 'periodoliq', 'codos', xperiodo, xperiodoliq, xcodos);
end;

procedure TTDistribucionObrasSociales.GuardarControlLiq(xperiodo, xperiodoliq, xcodos: String; xporcentaje: Real);
// Objetivo...: Registrar Control
Begin
  if BuscarControlLiq(xperiodo, xperiodoliq, xcodos) then controlLiq.Edit else controlLiq.Append;
  controlLiq.FieldByName('periodo').AsString    := xperiodo;
  controlLiq.FieldByName('periodoLiq').AsString := xperiodoLiq;
  controlLiq.FieldByName('codos').AsString      := xcodos;
  controlLiq.FieldByName('porcentaje').AsFloat  := xporcentaje;
  try
    controlLiq.Post
   except
    controlLiq.Cancel
  end;
  datosdb.refrescar(controlLiq);
end;

procedure TTDistribucionObrasSociales.BorrarControlLiq(xperiodo, xperiodoliq, xcodos: String);
// Objetivo...: Borrar Controles
Begin
  if BuscarControlLiq(xperiodo, xperiodoliq, xcodos) then controlLiq.Delete;
  datosdb.refrescar(controlLiq);
end;

function  TTDistribucionObrasSociales.verificarPeriodoLiq(xperiodoliq, xcodos: String): Real;
// Objetivo...: verificar si Existe el Per�odo
Begin
  controlLiq.IndexFieldNames := 'periodoliq;codos';
  if datosdb.Buscar(controlLiq, 'Periodoliq', 'Codos', xperiodoliq, xcodos) then Result := controlLiq.FieldByName('porcentaje').AsFloat else Result := -1;
  controlLiq.IndexFieldNames := 'periodo;periodoLiq;codos';
end;

//------------------------------------------------------------------------------

procedure TTDistribucionObrasSociales.ListarTotalesLiquidadosPeriodos(xdesde, xhasta: string; salida: char);
var
  i: integer;
  totales, totpar: TTable;
  per, idanter: string;
  tot: real;

  procedure Total(salida: char);
  begin
    if (tot <> 0) then begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(50, list.Lineactual, '-------------------------------', 2, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'Subtotal Profesional:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(67, list.Lineactual, '', tot, 2, 'Arial, negrita, 9');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
      tot := 0;
    end;
  end;

begin
  utilesarchivos.CopiarArchivos(dbs.DirSistema + '\workliq\distribuciones', 'montos_totales.*', dbs.DirSistema + '\estadisticas');
  totales := datosdb.openDB('montos_totales', '', '', dbs.DirSistema + '\estadisticas');
  totales.Open;
  for i := 1 to 100 do begin
      if i = 1 then per := xdesde else begin
        per := utiles.SumarPeriodo(per, '1');
      end;
      // montos liquidacion 01
      if (DirectoryExists(dbs.DirSistema + '\distribucion\dist' + Copy(per, 1, 2) + Copy(per, 4, 4) + '01')) then begin
      if (FileExists(dbs.DirSistema + '\distribucion\dist' + Copy(per, 1, 2) + Copy(per, 4, 4) + '01\montos.db')) then begin
      totpar := datosdb.openDB('montos', '', '', dbs.DirSistema + '\distribucion\dist' + Copy(per, 1, 2) + Copy(per, 4, 4) + '01');
      totpar.Open;
      datosdb.Filtrar(totpar, 'total > 0');
      totpar.First;
      while not totpar.Eof do begin
        if (datosdb.Buscar(totales, 'idprof', 'periodo', 'nrodist', totpar.FieldByName('idprof').AsString, Copy(per, 4, 4) + Copy(per, 1, 2), '01')) then totales.Edit else totales.Append;
        totales.FieldByName('idprof').AsString  := totpar.FieldByName('idprof').AsString;
        totales.FieldByName('periodo').AsString := Copy(per, 4, 4) + Copy(per, 1, 2);
        totales.FieldByName('nrodist').AsString := '01';
        totales.FieldByName('monto').AsFloat    := totpar.FieldByName('total').AsFloat;
        try
          totales.Post
         except
          totales.Cancel
        end;
        totpar.Next;
      end;
      datosdb.closeDB(totpar);
      end;
      end;

      // montos liquidacion 02
      if (DirectoryExists(dbs.DirSistema + '\distribucion\dist' + Copy(per, 1, 2) + Copy(per, 4, 4) + '02')) then begin
      if (FileExists(dbs.DirSistema + '\distribucion\dist' + Copy(per, 1, 2) + Copy(per, 4, 4) + '02\montos.db')) then begin
      totpar := datosdb.openDB('montos', '', '', dbs.DirSistema + '\distribucion\dist' + Copy(per, 1, 2) + Copy(per, 4, 4) + '02');
      totpar.Open;
      datosdb.Filtrar(totpar, 'total > 0');
      totpar.First;
      while not totpar.Eof do begin
        if (datosdb.Buscar(totales, 'idprof', 'periodo', 'nrodist', totpar.FieldByName('idprof').AsString, Copy(per, 4, 4) + Copy(per, 1, 2), '02')) then totales.Edit else totales.Append;
        totales.FieldByName('idprof').AsString  := totpar.FieldByName('idprof').AsString;
        totales.FieldByName('periodo').AsString := Copy(per, 4, 4) + Copy(per, 1, 2);
        totales.FieldByName('nrodist').AsString := '02';
        totales.FieldByName('monto').AsFloat    := totpar.FieldByName('total').AsFloat;
        try
          totales.Post
         except
          totales.Cancel
        end;
        totpar.Next;
      end;
      datosdb.closeDB(totpar);
      end;
      end;

      if (Copy(per, 1, 2) + Copy(per, 4, 4) = Copy(xhasta, 1, 2) + Copy(xhasta, 4, 4)) then break;
  end;

  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida); list.m := 0; tot := 0; idanter := '';
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Subtotales Liquidados a Profesionales - Lapso: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, '    Per�odo - Liq.', 1, 'Arial, cursiva, 8');
    list.Titulo(60, list.Lineactual, 'Monto Liq.', 2, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
  end;

  totales.First;
  while not totales.Eof do begin
    if (totales.FieldByName('idprof').AsString <> idanter) then begin
      Total(salida);
      profesional.getDatos(totales.FieldByName('idprof').AsString);
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Profesional: ' + profesional.codigo + ' - ' + profesional.nombre, 1, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      idanter := totales.FieldByName('idprof').AsString;
    end;
    list.Linea(0, 0, '     ' + copy(totales.FieldByName('periodo').AsString, 5, 2) + '/' + copy(totales.FieldByName('periodo').AsString, 1, 4) + ' - ' + '(' + totales.FieldByName('nrodist').AsString + ')', 1, 'Arial, normal, 8', salida, 'N');
    list.importe(67, list.Lineactual, '', totales.FieldByName('monto').AsFloat, 2, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
    tot := tot + totales.FieldByName('monto').AsFloat;
    totales.Next;
  end;
  Total(salida);
  datosdb.closeDB(totales);

  list.FinList;
end;

{-------------------------------------------------------------------------------}

procedure TTDistribucionObrasSociales.RealizarBackupDatos;
// Objetivo...: Respaldar Datos
var
  l: TStringList;
  i: Integer;
Begin
  l := backup.setModulos;
  For i := 1 to l.Count do Begin
    if l.Strings[i-1] = 'distribucion' then Begin
      if DirectoryExists(dbs.DirSistema + '\' + l.Strings[i-1] + '\dist' + Copy(utiles.setPeriodoActual, 1, 2) + Copy(utiles.setPeriodoActual, 4, 4) + '01') then
        utilesarchivos.CompactarArchivos(dbs.DirSistema + '\' + l.Strings[i-1] + '\dist' + Copy(utiles.setPeriodoActual, 1, 2) + Copy(utiles.setPeriodoActual, 4, 4) + '01\*.*', dbs.dirSistema + '\backup\' + utiles.sExprFecha2000(utiles.setFechaActual) + '_' + l.Strings[i-1] + '01.bck');
      if DirectoryExists(dbs.DirSistema + '\' + l.Strings[i-1] + '\dist' + Copy(utiles.setPeriodoActual, 1, 2) + Copy(utiles.setPeriodoActual, 4, 4) + '02') then
        utilesarchivos.CompactarArchivos(dbs.DirSistema + '\' + l.Strings[i-1] + '\dist' + Copy(utiles.setPeriodoActual, 1, 2) + Copy(utiles.setPeriodoActual, 4, 4) + '02\*.*', dbs.dirSistema + '\backup\' + utiles.sExprFecha2000(utiles.setFechaActual) + '_' + l.Strings[i-1] + '02.bck');
    end;
  end;
end;

function  TTDistribucionObrasSociales.setBackup(xperiodo: String): TStringList;
// Objetivo...: Devolver lista Backup de Datos
var
  i: Integer;
  l, j: TStringList;
Begin
  j := TStringList.Create;
  l := utilesarchivos.setListaArchivos(dbs.dirSistema + '\backup\', '*.bck');
  l.Sort;
  For i := l.Count downto 1 do
    if LowerCase(Copy(ExtractFileName(l.Strings[i-1]), 10, 3)) = 'dis' then j.Add(ExtractFileName(l.Strings[i-1]));
  l.Free;

  Result := j;
end;

procedure TTDistribucionObrasSociales.RealizarRestauracionLaboratorios(xarchivo: String);
// Objetivo...: Restaurar Distribuciones
begin
  utilesarchivos.RestaurarBackup(dbs.DirSistema  + '\backup\' + xarchivo, dbs.DirSistema + '\distribucion\dist' + Copy(xarchivo, 1, 6) + Copy(xarchivo, 22, 2));
end;

procedure TTDistribucionObrasSociales.titulo1(xperiodo: String);
// Objetivo...: Listar titulo 1
Begin
  Inc(pag);
  list.LineaTxt(CHR(18) + '  ', true);
  list.LineaTxt('Inf. Obras Sociales Liquidadas - Per�odo: ' + xperiodo + utiles.espacios(10) + 'Hoja Nro.: ' + IntToStr(pag), true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  list.LineaTxt('Fecha    Periodo Codigo Obra Social                     Monto Liq. Porcentaje', true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  lineas := 5;
end;

procedure TTDistribucionObrasSociales.titulo2(xperiodo: String);
// Objetivo...: Listar titulo 2
Begin
  Inc(pag);
  list.LineaTxt(CHR(18) + '  ', true);
  list.LineaTxt('Resumen de la Distribuci�n - Per�odo: ' + Copy(xperiodo, 1, 7) + '-' + Copy(xperiodo, 8, 2) + utiles.espacios(10) + 'Hoja Nro.: ' + IntToStr(pag), true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  list.LineaTxt('Concepto                                                                 Monto', true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  lineas := 5;
end;

procedure TTDistribucionObrasSociales.titulo3(xperiodo: String);
// Objetivo...: Listar titulo 3
Begin
  Inc(pag);
  list.LineaTxt(CHR(18) + '  ', true);
  list.LineaTxt('Resumen de Retenciones de la Distribuci�n - Per�odo: ' + Copy(xperiodo, 1, 7) + '-' + Copy(xperiodo, 8, 2) + utiles.espacios(1) + 'Hoja Nro.: ' + IntToStr(pag), true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  list.LineaTxt(CHR(15) + 'Profesional o Laboratorio                           C.U.I.T. Nro. T.Suj.Ret.  Retencion' + CHR(18), true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  lineas := 5;
end;

procedure TTDistribucionObrasSociales.titulo4(xperiodo: String);
// Objetivo...: Listar titulo 4
Begin
  Inc(pag);
  list.LineaTxt(CHR(18) + '  ', true);
  list.LineaTxt('Montos para la Liquidacion de Ganancias - Per�odo: ' + Copy(xperiodo, 1, 7) + '-' + Copy(xperiodo, 8, 2) + utiles.espacios(1) + 'Hoja Nro.: ' + IntToStr(pag), true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  list.LineaTxt('Profesional o Laboratorio                       Monto Liq. 1  Monto Liq. 2', true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
  lineas := 5;
end;

function  TTDistribucionObrasSociales.BuscarMontoGanancias(xidprof, xnroliq: String): Boolean;
// Objetivo...: Recuperar Instancia
Begin
  Result := datosdb.Buscar(subtotalesLiq, 'idprof', 'nroliq', xidprof, xnroliq);
end;

procedure TTDistribucionObrasSociales.RegistrarMontoGanancias(xidprof, xnroliq: String; xmonto: Real);
// Objetivo...: Registrar Monto Liq. Ganancias
Begin
  if BuscarMontoGanancias(xidprof, xnroliq) then subtotalesLiq.Edit else subtotalesLiq.Append;
  subtotalesLiq.FieldByName('idprof').AsString := xidprof;
  subtotalesLiq.FieldByName('nroliq').AsString := xnroliq;
  subtotalesLiq.FieldByName('monto').AsFloat   := xmonto;
  try
    subtotalesLiq.Post
   except
    subtotalesLiq.Cancel
  end;
  datosdb.closeDB(subtotalesLiq); subtotalesLiq.Open;
end;

procedure TTDistribucionObrasSociales.MarcarConsumoGanancias(xidprof, xnroliq, xconsumido: String);
// Objetivo...: Marcar Consumo
Begin
  if BuscarMontoGanancias(xidprof, xnroliq) then Begin
    subtotalesLiq.Edit;
    subtotalesLiq.FieldByName('consumo').AsString := xconsumido;
    try
      subtotalesLiq.Post
     except
      subtotalesLiq.Cancel
    end;
    datosdb.closeDB(subtotalesLiq); subtotalesLiq.Open;
  end;
end;

function TTDistribucionObrasSociales.verificarConsumoGanancias(xidprof, xnroliq: String): Boolean;
// Objetivo...: Verificar Consumo Ganancias
var
  path: String;
Begin
  Result := False;

  path := subtotalesLiq.DatabaseName;
  datosdb.closeDB(subtotalesLiq);
  subtotalesLiq := datosdb.openDB('subtotalesLiq', '', '', dbs.DirSistema + '\distribucion\Ganancias\' + Copy(xnroliq, 1, 2) + Copy(xnroliq, 4, 4));
  subtotalesLiq.Open;

  if BuscarMontoGanancias(xidprof, Copy(xnroliq, 8,2)) then
    if subtotalesLiq.FieldByName('consumo').AsString = 'S' then Result := True;

  datosdb.closeDB(subtotalesLiq);
  subtotalesLiq := datosdb.openDB('subtotalesLiq', '', '', path);
  subtotalesLiq.Open;
end;

procedure TTDistribucionObrasSociales.refrescar;
// Objetivo...: Vaciar Buffer de datos
Begin
  if cabajust <> Nil then datosdb.refrescar(cabajust);
  if detajust <> Nil then datosdb.refrescar(detajust);
  if dcprof   <> Nil then datosdb.refrescar(dcprof);
end;

procedure TTDistribucionObrasSociales.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  profesional.conectar;
  ajustesindiv.conectar;
  retenciones.conectar;
  titulos.conectar;
  obsocial.conectar;
  entbcos.conectar;
  coseguro.conectar;
  if conexiones = 0 then Begin
    if cabajust <> Nil then
      if not cabajust.Active then cabajust.Open;
    if detajust <> Nil then
      if not detajust.Active then detajust.Open;
    if dcprof <> Nil then
      if not dcprof.Active   then dcprof.Open;
    if ganancias <> Nil then
      if not ganancias.Active then ganancias.Open;
    if not ctrlImpr.Active then ctrlImpr.Open;
    if not controlLiq.Active then controlLiq.Open;
  end;
  Inc(conexiones);

  lista4 := TStringList.Create;
end;

procedure TTDistribucionObrasSociales.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  profesional.desconectar;
  ajustesindiv.desconectar;
  retenciones.desconectar;
  titulos.desconectar;
  obsocial.desconectar;
  entbcos.desconectar;
  coseguro.desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    if cabajust <> Nil then
      datosdb.closeDB(cabajust);
    if detajust <> Nil then
      datosdb.closeDB(detajust);
    if dcprof <> Nil then
      datosdb.closeDB(dcprof);
    if ganancias <> Nil then
      datosdb.closeDB(ganancias);
    datosdb.closeDB(ctrlImpr);
    datosdb.closeDB(controlLiq);
  end;
  directorio := '';

  lista4.Destroy; lista4 := nil;
end;

{===============================================================================}

function distribucionos: TTDistribucionObrasSociales;
begin
  if xdistribucionos = nil then
    xdistribucionos := TTDistribucionObrasSociales.Create;
  Result := xdistribucionos;
end;

{===============================================================================}

initialization

finalization
  xdistribucionos.Free;

end.
