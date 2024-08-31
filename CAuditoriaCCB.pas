unit CAuditoriaCCB;

interface

uses CObrasSocialesCCB, CZonasCCB, CPadronOSCCB, CMedicosCCB, CNomeclaCCB, CServers2000_Excel,
     CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes, CFacturacionCCB, CProfesionalCCB,
     CUtilidadesArchivos, CBackup, CNomeclatura_ObraSocial, CDiagnosticosCCB, CDiagnosticosCCBOMS,
     CNBU, CMedicosCabCCB, Contnrs, CMedicosCCBOS, CMedicosCabAO, CFirebird, IBTable, IBQuery, CCoseguros;

const
  cantitems = 300;

type

TTAuditoriaCCB = class
  Nroauditoria, Fecha, Codos, Idzona, Nrodoc, Idprof, Obsdiagnostico, Federivacion, Nroderivacion, Observacion, Entidad,
  IdFact, UltimaOrdenImpresa, Laboratorio, Codosfact, Fepedido, Profcab, Iddiag, Observacfinal, Periodo, Aplica, Codigo,
  Estado, Nompac, Items, Online, Nroautorizacion, Transaccion: String;
  ItemsPorDeterminacion, EtiquetasPorPagina, LineasSeparacionEtiquetas, LineasTxt, SeparacionPaginas: Integer;
  Tope, UB, UG, RIEUB, RIEUG, monto, monto_dif, monto_diferencial, Porcent, montoCoseguro, Nbudif: Real;
  cabauditoria, detauditoria, topes, totalOS, detrec, obsfinal, obsauditoria, porcentaje, montos_dif, apfijos, codigosrech: TTable;
  Existe, ImprimeCodigoBarras, ImpresionModoTexto, SaltarPagina, MontoFijo: Boolean;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xnroauditoria: String): Boolean;
  procedure   Registrar(xnroauditoria, xfecha, xcodos, xidzona, xnrodoc, xpaciente, xidprof, xdiagnostico, xfederivacion, xnroderivacion, xobservacion, xcodosfact, xfepedido, xprofcab, xiddiag, xobservacfinal: String; r_log: Boolean; xonline, xanulada, xnroautorizacion, xnrotransaccion: string);
  procedure   RegistrarItems(xnroauditoria, xitems, xcodigo, xdeterminacion, xestado: String; xmonto, xmontodif: Real; xCantidad: Integer; r_log: Boolean; xonline, xanulada: string; xmontoonline, xcoseguro: real);
  procedure   SincronizarItems(xnroauditoria, xitems, xcodigo, xdeterminacion, xestado: String; xmonto, xmontodif: Real; r_log: Boolean; xonline, xanulada: string; xmontoonline: real);
  procedure   getDatos(xnroauditoria: String);
  procedure   Borrar(xnroauditoria: String);

  function    setOrdenes: TObjectList;
  function    setHistorial(xcodos, xnrodoc: String; xincluir_datos_historicos: Boolean): TStringList;
  function    setItemsHistorial(xnroauditoria: String; xincluir_datos_historicos: Boolean): TObjectList;
  function    setDeterminacionesFecha(xfecha: String): TQuery;
  function    setDeterminacionesObraSocial(xcodos, xfecha: String): TQuery;
  function    setTotalAnalisisMensual(xfecha, xcodos: String; xrecalcularmontos: Boolean): Real;
  function    setRecalcularTotalAnalisisMensual(xfecha, xcodos: String; xrecalcularmontos: Boolean): Real;
  procedure   RegistrarTotalMensual(xcodos, xfecha: String; xtotal: Real);

  function    setOrdenesAuditadas(xperiodo, xcodos: String): TStringList;
  function    setCodidosAuditados(xnroauditoria: String): TStringList;

  procedure   ListarOrden(xdnro, xhnro, xdfecha, xhfecha, xultimonro, xtamanio_fuente: String; salida: char);
  procedure   InfControlOrdenesFacturadas(xdfecha, xhfecha: String; salida: Char);
  procedure   ListarOrdenesAutorizadas(listObSociales: TStringList; xfdesde, xfhasta: String; salida: char; xinf_envio: Boolean);
  procedure   ListarOrdenesRechazadas(listObSociales: TStringList; xfdesde, xfhasta: String; salida: char; xinf_envio: Boolean);
  procedure   ListarTotalesDiariosOS(xfdesde, xfhasta: String; salida, tipoList: char);
  procedure   ListarHistoriaClinica(xcodos, xnrodoc: String; salida: char);
  procedure   ListarEstadisticaMedicos(xlista: TStringList; xdesde, xhasta: String; salida: char);
  procedure   ListarEstadisticaMedicosCabecera(xlista: TStringList; xcodos, xdesde, xhasta: String; salida: char);
  procedure   ListarEstadisticaDiagnostico(xcodos, xdesde, xhasta: String; salida: char);
  procedure   ListarEstadisticaMedicoDiagnostico(xcodos, xdesde, xhasta: String; salida: char);
  procedure   ListarEstadisticaPaciente(xcodos, xnrodoc, xdesde, xhasta: String; salida: char);
  procedure   ListarCoseguros(xperiodo, xcodos, xperiodoliq: string; salida: char);
  procedure   ListCoseguros(xperiodoliq: string; salida: char);

  function    getCoseguros(xcodos, xidprof, xperiodo: string): TQuery;

  function    setNuevoNroAuditoria: String;

  procedure   MarcarAuditoriaComoFacturada(xnroauditoria, xidfact, xfecha, xlaboratorio: String);
  function    setLaboratorioFacturado(xnroauditoria: String): String;
  procedure   BorrarLaboratorioFacturado(xnroauditoria: String);

  function    BuscarTopes(xcodos: String): Boolean;
  procedure   EstablecerTope(xcodos: String; xtope: Real);
  procedure   getTopes(xcodos: String);
  procedure   BorrarTopes(xcodos: String);

  function    Logs(xfecha: String): String;

  procedure   AjustarFecha(xdesdeNro, xhastaNro, xFecha: String);

  function    BuscarDetRechazada(xcodos, xcodanalisis: String): Boolean;
  procedure   RegistrarDetRechazada(xcodos, xcodanalisis: String);
  procedure   BorrarDetRechazada(xcodos, xcodanalisis: String);
  function    setDetRechazadas(xcodos: String): TObjectList;

  procedure   RealizarBackup;
  function    setBackup(xperiodo: String): TStringList;
  procedure   RestaurarBackup(xarchivo: String);

  function    BuscarObs(xcodos: String): Boolean;
  procedure   GuardarObs(xcodos, xobservacion: String);
  procedure   getDatosObs(xcodos: String);

  function    BuscarObsFinal(xnroauditoria: String): Boolean;

  function    BuscarArancelDiferencial(xcodos, xperiodo: String): Boolean;
  procedure   RegistrarArancelDiferencial(xcodos, xperiodo, xaplica: String; xub, xug, xrieub, xrieug, xporcentaje: Real);
  procedure   RegistrarArancelDiferencialNBU(xcodos, xperiodo: String; xnbu: Real);
  procedure   getDatosArancelDiferencial(xcodos, xperiodo: String);
  procedure   BorrarArancelDiferencial(xcodos, xperiodo: String);
  procedure   SincronizarArancelDiferencial(xcodos, xperiodo: String);
  function    setArancelDiferencial(xcodos: String): TQuery;
  function    verificarArancelDiferencial(xcodos: String): Boolean;
  function    getArancelDiferencialNBU(xcodos, xperiodo: String): real;

  procedure   ListarMontosFacturadosDiferenciales(xperiodo, xporcentaje: String; salida: char);
  procedure   ListarResumenMontosFacturadosDiferenciales(xperiodo, xporcentaje: String; salida: char);

  procedure   IniciarMontosDiferenciales(xperiodo: String);
  function    BuscarMontosDiferenciales(xperiodo, xidprof, xcodos: String): Boolean;
  procedure   RegistrarMontosDiferenciales(xperiodo, xidprof, xcodos: String; xmonto: Real);

  function    BuscarItemsMontoFijo(xcodos, xitems: string): boolean;
  procedure   GrabarAnalisisMontoFijo(xcodos, xitems, xcodanalisis, xperiodo, xperiodobaja: string; ximporte: real; xcantitems: Integer);
  procedure   BorrarAnalisisMontoFijo(xcodos, xitems: string);
  function    setAnalisisMontoFijo(xcodos: string): TQuery;
  function    setMontoFijo(xcodos, xcodanalisis, xperiodo: String): Real;

  procedure   GenerarOrdenesXML(xfecha: String);

  function    setOrdenesDepurar(xfecha: String): TStringList;
  procedure   IniciarDepuracion;
  procedure   FinalizarDepuracion;
  procedure   Depurar(xnroauditoria: String);

  function    BuscarCodigoRech(xcodos, xcodigo: string): boolean;
  procedure   RegistrarCodigoRech(xcodos, xcodigo: string);
  procedure   BorrarCodigoRech(xcodos, xcodigo: string);
  function    getCodigosRech(xcodos: string): TStringList;

  procedure   AjustarEstado(xnroauditoria, xestado: string);

  procedure   QuitarMarcaDePendiente;
  procedure   MarcarComoPendiente(xnroauditoria: string);

  function    getPaciente(xnroauditoria: string): string;

  //procedure   vaciarBuffer;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  archivo: TextFile;
  rsql: TQuery;
  directorio, me, fecha_hist: String;
  idanter: array[1..10] of String;
  cp: array[1..cantitems] of String;
  ca, im, ct, i1: array[1..cantitems] of Real;
  mf: array[1..cantitems] of Boolean;
  totales: array[1..10] of Real;
  totgrales: array[1..7] of Real;
  totfinal: array[1..8] of Real;
  historiac: array[1..9] of String;
  rangoceldas: array[1..2] of String;
  iitems, lineas, lh, ke, c4: Integer;
  lceldas, cantpac: TStringList;
  inf_envio, csdat, ldat: Boolean;
  lista2: TStringList;
  cabhist, dethist, obsaudithist, coseguromov: TTable;

  {ffirebird: TTFirebird;
  rsqlIB: TIBQuery;
  lote: TStringList;}

  procedure   IniciarArreglos;
  procedure   ListOrdenes(listObSociales: TStringList; xtitulo, xfdesde, xfhasta, xestado: String; salida: char);
  procedure   IniciarObraSocial(xcodos: String; salida: char);
  procedure   IniciarZona(xidzona: String; salida: char);
  procedure   TotalZona(salida: char);
  procedure   TotalObraSocial(salida: char);
  procedure   LineaDeterminaciones(xitems: Integer; salida: char);
  procedure   LineaHist(salida: char);
  procedure   RupturaMedico(xidprof: String; salida: char);
  procedure   RupturaMedicoCabecera(xcodos, xidprof, xperiodo: String; salida: char);
  procedure   RupturaDiagnostico(xiddiag: String; salida: char);
  procedure   RupturaMedicoDiagnostico(xiddiag: String; salida: char);
  procedure   SubtotalRupturaMedicoDiagnostico(salida: char);
  procedure   SubtotalMontosDiferenciales(xperiodo, xidprof, xcodos: String; salida: char);
  procedure   CargarListaApFijos;
end;

function auditoriacb: TTAuditoriaCCB;

implementation

uses
  CAuditoriaOnLine;

var
  xauditoria: TTAuditoriaCCB = nil;

constructor TTAuditoriaCCB.Create;
begin
  ImprimeCodigoBarras := True;
  if dbs.BaseClientServ = 'N' then directorio := dbs.DirSistema + '\auditoria' else directorio := 'auditoriaccb';

  csdat := False;
  dbs.getParametrosDB1;     // Base de datos adicional 1
  if Length(Trim(dbs.db1)) > 0 then Begin
    dbs.NuevaBaseDeDatos(dbs.db1, dbs.us1, dbs.pa1);
    directorio   := dbs.baseDat_N;
    csdat        := True;
  end else
    directorio := dbs.DirSistema + '\auditoria';

  cabauditoria := datosdb.openDB('cab_auditoria', '', '', directorio);
  detauditoria := datosdb.openDB('det_auditoria', '', '', directorio);
  topes        := datosdb.openDB('topes', '', '', directorio);
  totalOS      := datosdb.openDB('totalOS', '', '', directorio);
  detrec       := datosdb.openDB('detrechazadas', '', '', directorio);
  obsfinal     := datosdb.openDB('obsfinal', '', '', directorio);
  obsauditoria := datosdb.openDB('obsauditoria', '', '', directorio);
  porcentaje   := datosdb.openDB('porcentaje', '', '', directorio);
  montos_dif   := datosdb.openDB('montos_dif', '', '', directorio);
  apfijos      := datosdb.openDB('apfijos_dif', '', '', directorio);
  codigosrech  := datosdb.openDB('estcodigosrech', '', '', directorio);
  coseguromov  := datosdb.openDB('coseguros_montos', '');

  //if csdat then padron.Interbase := 'S';   // Base de Datos CS
  //lote := TStringList.Create;
end;

destructor TTAuditoriaCCB.Destroy;
begin
  inherited Destroy;
end;

function  TTAuditoriaCCB.Buscar(xnroauditoria: String): Boolean;
// Objetivo...: Recuperar una Instancia
Begin
  {rsqlIB := ffirebird.getTransacSQL('select nroauditoria from cab_auditoria where nroauditoria = ' + '''' + xnroauditoria + '''');
  rsqlIB.Open;
  if (rsqlIB.RecordCount > 0) then Existe := true else Existe := false;
  rsqlIB.Close; rsqlIB.Free;
  Result := Existe;}
  if cabauditoria.IndexFieldNames <> 'Nroauditoria' then cabauditoria.IndexFieldNames := 'Nroauditoria';
  Existe := cabauditoria.FindKey([xnroauditoria]);
  Result := Existe;
end;

procedure TTAuditoriaCCB.Registrar(xnroauditoria, xfecha, xcodos, xidzona, xnrodoc, xpaciente, xidprof, xdiagnostico, xfederivacion, xnroderivacion, xobservacion, xcodosfact, xfepedido, xprofcab, xiddiag, xobservacfinal: String; r_log: Boolean; xonline, xanulada, xnroautorizacion, xnrotransaccion: string);
// Objetivo...: Registrar una Instancia
var
 fd: string;
Begin
  {if Length(Trim(xfederivacion)) = 8 then fd := utiles.sExprFecha2000(xfederivacion) else fd := '';

  lote.Clear;
  lote.Add('delete from cab_auditoria where nroauditoria = ' + '''' + xnroauditoria + '''');
  lote.Add('delete from det_auditoria where nroauditoria = ' + '''' + xnroauditoria + '''');
  lote.Add('delete from obsauditoria where nroauditoria = ' + '''' + xnroauditoria + '''');

  lote.Add('insert into cab_auditoria (nroauditoria, fecha, codos, idzona, nrodoc, idprof, diagnostico, ' +
           'federivacion, nroderivacion, observacion, codosfact, fepedido, profcab, iddiag, nombre, online, anulada) values (' +
           '''' + trim(xnroauditoria) + '''' + ', ' +
           '''' + utiles.sExprFecha2000(xfecha) + '''' + ', ' +
           '''' + trim(xcodos) + '''' + ', ' +
           '''' + trim(xidzona) + '''' + ', ' +
           '''' + trim(xnrodoc) + '''' + ', ' +
           '''' + trim(xidprof) + '''' + ', ' +
           '''' + utiles.StringRemplazarCaracteres(xobservacion, '''', '') + '''' + ', ' +
           '''' + trim(fd) + '''' + ', ' +
           '''' + trim(xnroderivacion) + '''' + ', ' +
           '''' + utiles.StringRemplazarCaracteres(xobservacion, '''', '') + '''' + ', ' +
           '''' + trim(xcodosfact) + '''' + ', ' +
           '''' + trim(utiles.sExprFecha2000(xfepedido)) + '''' + ', ' +
           '''' + trim(xprofcab) + '''' + ', ' +
           '''' + trim(xiddiag) + '''' + ', ' +
           '''' + utiles.StringRemplazarCaracteres(xpaciente, '''', '') + '''' + ', ' +
           '''' + trim(xonline) + '''' + ', ' +
           '''' + trim(xanulada) + '''' + ')');

  if Length(Trim(xobservacfinal)) > 0 then Begin
    lote.Add('insert into obsauditoria (nroauditoria, observacion) values (' + '''' + xnroauditoria + '''' + ', ' + '''' + utiles.StringRemplazarCaracteres(xobservacfinal, '''', '') + '''' + ')');
  End;}


  if Buscar(xnroauditoria) then cabauditoria.Edit else cabauditoria.Append;
  cabauditoria.FieldByName('nroauditoria').AsString  := xnroauditoria;
  cabauditoria.FieldByName('fecha').AsString         := utiles.sExprFecha2000(xfecha) ;
  cabauditoria.FieldByName('codos').AsString         := xcodos;
  cabauditoria.FieldByName('idzona').AsString        := xidzona;
  cabauditoria.FieldByName('nrodoc').AsString        := xnrodoc;
  cabauditoria.FieldByName('idprof').AsString        := xidprof;
  cabauditoria.FieldByName('diagnostico').AsString   := xdiagnostico;
  if Length(Trim(xfederivacion)) = 8 then cabauditoria.FieldByName('federivacion').AsString := utiles.sExprFecha2000(xfederivacion) else
    cabauditoria.FieldByName('federivacion').AsString := '';
  cabauditoria.FieldByName('nroderivacion').AsString := xnroderivacion;
  cabauditoria.FieldByName('observacion').AsString   := xobservacion;
  cabauditoria.FieldByName('codosfact').AsString     := xcodosfact;
  cabauditoria.FieldByName('fepedido').AsString      := utiles.sExprFecha2000(xfepedido);
  cabauditoria.FieldByName('profcab').AsString       := xprofcab;
  cabauditoria.FieldByName('iddiag').AsString        := xiddiag;
  cabauditoria.FieldByName('nombre').AsString        := xpaciente;
  cabauditoria.FieldByName('online').AsString        := xonline;
  cabauditoria.FieldByName('anulada').AsString       := xanulada;
  cabauditoria.FieldByName('nroautorizacion').AsString := xnroautorizacion;
  cabauditoria.FieldByName('transaccion').AsString     := xnrotransaccion;
  try
    cabauditoria.Post
   except
    cabauditoria.Cancel
  end;
  datosdb.refrescar(cabauditoria);

  {if not (Existe) and not (r_log) then Begin
    AssignFile(archivo, dbs.DirSistema + '\auditoria\log\log_' + utiles.sExprFecha2000(utiles.setFechaActual) + '.txt');
    if not FileExists(dbs.DirSistema + '\auditoria\log\log_' + utiles.sExprFecha2000(utiles.setFechaActual) + '.txt') then Rewrite(archivo) else Append(archivo);
    WriteLn(archivo, xnroauditoria + '-' + utiles.sExprFecha2000(xfecha) + '-' + xcodos + '-' + xidzona + '-' + utiles.sLlenarDerecha(xnrodoc, 10,  ' ') + '-' + utiles.sLlenarDerecha(xpaciente, 40,  ' ') + '-' + xidprof + '-' + utiles.sLlenarDerecha(xdiagnostico, 40, ' ') + '-' + utiles.sLlenarDerecha(xfederivacion, 8, ' ') + '-' + utiles.sLlenarDerecha(xnroderivacion, 10, ' ') + '-' + xobservacion + '-' + xcodosfact + '-' + xprofcab + '-' + xiddiag);
    closeFile(archivo);
  end;}
  // Observacion Final
  if Length(Trim(xobservacfinal)) = 0 then Begin
    if auditoriacb.BuscarObsFinal(xnroauditoria) then obsauditoria.Delete;
  end else Begin
    if auditoriacb.BuscarObsFinal(xnroauditoria) then obsauditoria.Edit else obsauditoria.Append;
    obsauditoria.FieldByName('nroauditoria').AsString := xnroauditoria;
    obsauditoria.FieldByName('observacion').AsString  := xobservacfinal;
    try
      obsauditoria.Post
     except
      obsauditoria.Cancel
    end;
  end;
  datosdb.refrescar(obsauditoria);
end;

procedure TTAuditoriaCCB.RegistrarItems(xnroauditoria, xitems, xcodigo, xdeterminacion, xestado: String; xmonto, xmontodif: Real; xCantidad: Integer; r_log: Boolean; xonline, xanulada: string; xmontoonline, xcoseguro: real);
// Objetivo...: Recuperar una Instancia
Begin
  {lote.Add('insert into det_auditoria (nroauditoria, items, codigo, estado, monto, montodif, montoonline, online, anulada, coseguro) values (' +
      '''' + xnroauditoria + '''' + ', ' +
      '''' + xitems + '''' + ', ' +
      '''' + xcodigo + '''' + ', ' +
      '''' + xestado + '''' + ', ' +
      utiles.StringRemplazarCaracteres(FloatToStr(xmonto), ',', '.') + ', ' +
      utiles.StringRemplazarCaracteres(FloatToStr(xmontodif), ',', '.') + ', ' +
      utiles.StringRemplazarCaracteres(FloatToStr(xmontoonline), ',', '.') + ', ' +
      '''' + xonline + '''' + ', ' +
      '''' + xanulada + '''' + ', ' +
      utiles.StringRemplazarCaracteres(FloatToStr(xcoseguro), ',', '.') + ')');

  if (xitems = utiles.sLlenarIzquierda(IntToStr(xcantidad), 3, '0')) then ffirebird.TransacSQLBatch(lote);}

  if datosdb.Buscar(detauditoria, 'nroauditoria', 'items', xnroauditoria, xitems) then detauditoria.Edit else detauditoria.Append;
  detauditoria.FieldByName('nroauditoria').AsString  := xnroauditoria;
  detauditoria.FieldByName('items').AsString         := xitems;
  detauditoria.FieldByName('codigo').AsString        := xcodigo;
  detauditoria.FieldByName('estado').AsString        := xestado;
  detauditoria.FieldByName('monto').AsFloat          := xmonto;
  detauditoria.FieldByName('montodif').AsFloat       := xmontodif;
  detauditoria.FieldByName('montoonline').AsFloat    := xmontoonline;
  detauditoria.FieldByName('online').AsString        := xonline;
  detauditoria.FieldByName('anulada').AsString       := xanulada;
  detauditoria.FieldByName('coseguro').AsFloat       := xcoseguro;
  try
    detauditoria.Post
   except
    detauditoria.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantidad), 3, '0') then Begin
    if Existe then datosdb.tranSQL(directorio,  'delete from det_auditoria where nroauditoria = ' + '"' + xnroauditoria + '"' + ' and items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantidad), 3, '0') + '"');
    datosdb.refrescar(detauditoria);
  end;

  {if Not (Existe) and Not (r_log) then Begin
    AssignFile(archivo, dbs.DirSistema + '\auditoria\log\log_' + utiles.sExprFecha2000(utiles.setFechaActual) + '.txt');
    if not FileExists(dbs.DirSistema + '\auditoria\log\log_' + utiles.sExprFecha2000(utiles.setFechaActual) + '.txt') then Rewrite(archivo) else Append(archivo);
    WriteLn(archivo, xcodigo + '-' + xestado + '-' + utiles.sLlenarDerecha(xdeterminacion, 50, ' ') + '-' + utiles.FormatearNumero(FloatToStr(xmonto)));
    closeFile(archivo);
  end;}
end;

procedure TTAuditoriaCCB.SincronizarItems(xnroauditoria, xitems, xcodigo, xdeterminacion, xestado: String; xmonto, xmontodif: Real; r_log: Boolean; xonline, xanulada: string; xmontoonline: real);
// Objetivo...: Recuperar una Instancia
Begin
  //ffirebird.TransacSQL('delete from det_auditoria where nroauditoria = ' + '"' + xnroauditoria + '"');
  {lote.Clear;
  if (xitems = '001') then begin
    lote.Add('delete from det_auditoria where nroauditoria = ' + '"' + xnroauditoria + '"');
    lote.Add('update cab_auditoria set anulada = ' + '''' + xanulada + '''' + ' where nroauditoria = ' + '''' + xnroauditoria + ''''); 
  end;
  lote.Add('insert into det_auditoria (nroauditoria, items, codigo, estado, monto, montodif, montoonline, online, anulada) values (' +
      '''' + xnroauditoria + '''' + ', ' +
      '''' + xitems + '''' + ', ' +
      '''' + xcodigo + '''' + ', ' +
      '''' + xestado + '''' + ', ' +
      utiles.StringRemplazarCaracteres(FloatToStr(xmonto), ',', '.') + ', ' +
      utiles.StringRemplazarCaracteres(FloatToStr(xmontodif), ',', '.') + ', ' +
      utiles.StringRemplazarCaracteres(FloatToStr(xmontoonline), ',', '.') + ', ' +
      '''' + xonline + '''' + ', ' +
      '''' + xanulada + '''' + ', ' + ')');}

  if (xitems = '001') then Begin
    datosdb.tranSQL(directorio,  'delete from det_auditoria where nroauditoria = ' + '"' + xnroauditoria + '"');
    datosdb.refrescar(detauditoria);
    datosdb.closeDB(detauditoria);
    detauditoria.Open;
  end;
  if datosdb.Buscar(detauditoria, 'nroauditoria', 'items', xnroauditoria, xitems) then detauditoria.Edit else detauditoria.Append;
  detauditoria.FieldByName('nroauditoria').AsString  := xnroauditoria;
  detauditoria.FieldByName('items').AsString         := xitems;
  detauditoria.FieldByName('codigo').AsString        := xcodigo;
  detauditoria.FieldByName('estado').AsString        := xestado;
  detauditoria.FieldByName('monto').AsFloat          := xmonto;
  detauditoria.FieldByName('montodif').AsFloat       := xmontodif;
  detauditoria.FieldByName('online').AsString        := xonline;
  detauditoria.FieldByName('anulada').AsString       := xanulada;
  detauditoria.FieldByName('montoonline').AsFloat    := xmontoonline;
  try
    detauditoria.Post
   except
    detauditoria.Cancel
  end;
  datosdb.refrescar(detauditoria);

  if (xanulada = 'S') or (xanulada = 'P') then begin
    if (Buscar(xnroauditoria)) then begin
      cabauditoria.Edit;
      cabauditoria.FieldByName('anulada').AsString := xanulada;
      try
        cabauditoria.Post
       except
        cabauditoria.Cancel
      end;
      datosdb.refrescar(cabauditoria);
    end;
  end;

end;

procedure TTAuditoriaCCB.getDatos(xnroauditoria: String);
// Objetivo...: Cargar una Instancia
Begin
  if Buscar(xnroauditoria) then Begin
    Nroauditoria   := cabauditoria.FieldByName('nroauditoria').AsString;
    Fecha          := utiles.sFormatoFecha(cabauditoria.FieldByName('fecha').AsString);
    Codos          := cabauditoria.FieldByName('codos').AsString;
    Idzona         := cabauditoria.FieldByName('idzona').AsString;
    Nrodoc         := TrimRight(cabauditoria.FieldByName('nrodoc').AsString);
    Idprof         := cabauditoria.FieldByName('idprof').AsString;
    obsdiagnostico := cabauditoria.FieldByName('diagnostico').AsString;
    if Length(Trim(cabauditoria.FieldByName('federivacion').AsString)) = 8 then Federivacion := utiles.sFormatoFecha(cabauditoria.FieldByName('federivacion').AsString);
    Nroderivacion  := cabauditoria.FieldByName('nroderivacion').AsString;
    Observacion    := cabauditoria.FieldByName('observacion').AsString;
    IdFact         := cabauditoria.FieldByName('Idfact').AsString;
    Laboratorio    := cabauditoria.FieldByName('laboratorio').AsString;
    Codosfact      := cabauditoria.FieldByName('codosfact').AsString;
    Fepedido       := utiles.sFormatoFecha(cabauditoria.FieldByName('fepedido').AsString);
    Profcab        := cabauditoria.FieldByName('profcab').AsString;
    Iddiag         := cabauditoria.FieldByName('iddiag').AsString;
    Nompac         := cabauditoria.FieldByName('nombre').AsString;
    Online         := cabauditoria.FieldByName('online').AsString;
    Transaccion    := cabauditoria.FieldByName('transaccion').AsString;
  end else Begin
    Nroauditoria := ''; Fecha := ''; Codos := ''; Idzona := ''; Nrodoc := ''; Idprof := ''; obsdiagnostico := ''; Federivacion := ''; Nroderivacion := ''; Observacion := '';
    IdFact := ''; Laboratorio := ''; Codosfact := ''; Fepedido := ''; Profcab := ''; Iddiag := ''; Nompac := ''; Online := ''; Transaccion := '';
  end;

  if BuscarObsFinal(xnroauditoria) then observacfinal := obsauditoria.FieldByName('observacion').AsString else observacfinal := '';
end;

procedure TTAuditoriaCCB.Borrar(xnroauditoria: String);
// Objetivo...: Borrar una Instancia
Begin
  {lote.clear;
  lote.Add('delete from det_auditoria where nroauditoria = ' + '"' + xnroauditoria + '"');
  lote.Add('delete from cab_auditoria where nroauditoria = ' + '"' + xnroauditoria + '"');
  ffirebird.TransacSQLBatch(lote);}
  if Buscar(xnroauditoria) then Begin
    cabauditoria.Delete;
    datosdb.tranSQL(directorio, 'delete from det_auditoria where nroauditoria = ' + '"' + xnroauditoria + '"');
    datosdb.closeDB(cabauditoria); cabauditoria.Open;
    datosdb.closeDB(detauditoria); detauditoria.Open;
  end;
end;

function  TTAuditoriaCCB.setOrdenes: TObjectList;
// Objetivo...: Retornar ordenes de auditoria
var
  l: TObjectList;
  objeto: TTAuditoriaCCB;
Begin
  l := TObjectList.Create;
  if datosdb.Buscar(detauditoria, 'nroauditoria', 'items', Nroauditoria, '001') then Begin
    while not detauditoria.Eof do Begin
      if detauditoria.FieldByName('nroauditoria').AsString <> Nroauditoria then Break;
      objeto := TTAuditoriaCCB.Create;
      objeto.Items     := detauditoria.FieldByName('items').AsString;
      objeto.Codigo    := detauditoria.FieldByName('codigo').AsString;
      objeto.monto     := detauditoria.FieldByName('monto').AsFloat;
      objeto.monto_dif := detauditoria.FieldByName('montodif').AsFloat;
      objeto.estado    := detauditoria.FieldByName('estado').AsString;
      objeto.montocoseguro  := detauditoria.FieldByName('coseguro').AsFloat;
      l.Add(objeto);
      detauditoria.Next;
    end;
  end;

  {rsqlIB := ffirebird.getTransacSQL('select items, codigo, monto, montodif, estado, coseguro from det_auditoria where nroauditoria = ' + '''' + nroauditoria + '''' + ' order by items');
  rsqlIB.Open;
  while not rsqlIB.Eof do Begin
    objeto := TTAuditoriaCCB.Create;
    objeto.Items     := rsqlIB.FieldByName('items').AsString;
    objeto.Codigo    := rsqlIB.FieldByName('codigo').AsString;
    objeto.monto     := rsqlIB.FieldByName('monto').AsFloat;
    objeto.monto_dif := rsqlIB.FieldByName('montodif').AsFloat;
    objeto.estado    := rsqlIB.FieldByName('estado').AsString;
    objeto.coseguro  := rsqlIB.FieldByName('coseguro').AsFloat;
    l.Add(objeto);
    rsqlIB.Next;
  end;
  rsqlIB.close; rsqlIB := nil;}
  Result := l;
end;

function  TTAuditoriaCCB.setHistorial(xcodos, xnrodoc: String; xincluir_datos_historicos: Boolean): TStringList;
// Objetivo...: Retornar Historial de Paciente
var
  lista, lista1, lista2: TStringList;
  fp, idg, mc: String;
  cab_hist: TTable;
  indice, i: Integer;
Begin
  lista  := TStringList.Create;
  lista1 := TStringList.Create;
  lista2 := TStringList.Create;
  indice := 0;

  if xincluir_datos_historicos then Begin     // Recuperamos Datos Hist�ricos
    cab_hist := datosdb.openDB('cab_auditoria_hist', '', '', directorio);
    cab_hist.Open;
    nroauditoria := cab_hist.FieldByName('nroauditoria').AsString;
    cab_hist.IndexFieldNames := 'Codos;Nrodoc';
    if datosdb.Buscar(cab_hist, 'codos', 'nrodoc', xcodos, xnrodoc) then Begin
      while not cab_hist.Eof do Begin
        if (cab_hist.FieldByName('nrodoc').AsString <> xnrodoc) or (cab_hist.FieldByName('codos').AsString <> xcodos) then Break;
        if Length(Trim(cab_hist.FieldByName('fepedido').AsString)) > 0 then fp := utiles.sFormatoFecha(cab_hist.FieldByName('fepedido').AsString) else fp := 'No Tiene';
        if Length(Trim(cab_hist.FieldByName('iddiag').AsString)) > 0 then idg := cab_hist.FieldByName('iddiag').AsString else idg := '0000';
        if Length(Trim(cab_hist.FieldByName('profcab').AsString)) > 0 then mc := cab_hist.FieldByName('profcab').AsString else mc := '----';
        lista.Add(cab_hist.FieldByName('nroauditoria').AsString + cab_hist.FieldByName('fecha').AsString + cab_hist.FieldByName('idprof').AsString + cab_hist.FieldByName('nroauditoria').AsString + cab_hist.FieldByName('diagnostico').AsString + ';1' + cab_hist.FieldByName('observacion').AsString + ';2' + fp + ';3' + idg + mc);
        Inc(indice);
        lista1.Add(cab_hist.FieldByName('fecha').AsString + IntToStr(indice));
        fecha_hist := cab_hist.FieldByName('fecha').AsString;
        cab_hist.Next;
      end;
      datosdb.closeDB(cab_hist);
    end;
  end;

  nroauditoria := cabauditoria.FieldByName('nroauditoria').AsString;
  cabauditoria.IndexFieldNames := 'Codos;Nrodoc';
  if datosdb.Buscar(cabauditoria, 'codos', 'nrodoc', xcodos, xnrodoc) then Begin
    while not cabauditoria.Eof do Begin
      if (cabauditoria.FieldByName('nrodoc').AsString <> xnrodoc) or (cabauditoria.FieldByName('codos').AsString <> xcodos) then Break;
      if Length(Trim(cabauditoria.FieldByName('fepedido').AsString)) > 0 then fp := utiles.sFormatoFecha(cabauditoria.FieldByName('fepedido').AsString) else fp := 'No Tiene';
      if Length(Trim(cabauditoria.FieldByName('iddiag').AsString)) > 0 then idg := cabauditoria.FieldByName('iddiag').AsString else idg := '00000';
      if Length(Trim(cabauditoria.FieldByName('profcab').AsString)) > 0 then mc := cabauditoria.FieldByName('profcab').AsString else mc := '----';
      idg := utiles.sLlenarDerecha(idg, 6, ' ');
      lista.Add(trim(cabauditoria.FieldByName('nroauditoria').AsString) + cabauditoria.FieldByName('fecha').AsString + utiles.sLlenarDerecha(cabauditoria.FieldByName('idprof').AsString, 5, ' ') + cabauditoria.FieldByName('nroauditoria').AsString + cabauditoria.FieldByName('diagnostico').AsString + ';1' + cabauditoria.FieldByName('observacion').AsString + ';2' + fp + ';3' + idg + mc);
      Inc(indice);
      lista1.Add(cabauditoria.FieldByName('fecha').AsString + IntToStr(indice));
      cabauditoria.Next;
    end;
  end;
  cabauditoria.IndexFieldNames := 'Nroauditoria';
  Buscar(nroauditoria);    // Restablecemos el puntero en la orden actual

  // Ordenamos los datos por fecha
  lista1.Sort;
  for i := 1 to lista1.Count do
    lista2.Add(lista.Strings[StrToInt(Trim(Copy(lista1.Strings[i-1], 9, 15))) - 1]);

  Result := lista2;
end;

function  TTAuditoriaCCB.setItemsHistorial(xnroauditoria: String; xincluir_datos_historicos: Boolean): TObjectList;
// Objetivo...: Devolver un StringList para el historial
var
  l: TObjectList;
  objeto: TTAuditoriaCCB;
  det_hist: TTable;
  _nrodoc, _nroaut, _fecha: string;
  rs: TQuery;
Begin
  l := TObjectList.Create;

  if xincluir_datos_historicos then Begin     // Recuperamos Datos Hist�ricos
    det_hist := datosdb.openDB('det_auditoria_hist', '', '', directorio);
    det_hist.Open;

    monto_diferencial := 0;
    if datosdb.Buscar(det_hist, 'nroauditoria', 'fecha', 'items', xnroauditoria, fecha_hist, '001') then Begin
      while not det_hist.Eof do Begin
        if det_hist.FieldByName('nroauditoria').AsString <> xnroauditoria then Break;
        //lista.Add(det_hist.FieldByName('codigo').AsString + det_hist.FieldByName('estado').AsString);
        objeto := TTAuditoriaCCB.Create;
        objeto.Codigo := det_hist.FieldByName('codigo').AsString;
        objeto.Estado := det_hist.FieldByName('estado').AsString;
        l.Add(objeto);
        if aplica = 'S' then monto_diferencial := monto_diferencial + (det_hist.FieldByName('montodif').AsFloat - det_hist.FieldByName('monto').AsFloat);
        det_hist.Next;
      end;
      datosdb.closeDB(det_hist);
    end;
  end;

  monto_diferencial := 0;
  {rsqlIB := ffirebird.getTransacSQL('select codigo, estado, coseguro from det_auditoria where nroauditoria = ' + '''' + xnroauditoria + '''' + ' order by items');
  rsqlIB.Open;
  while not rsqlIB.Eof do Begin
    objeto := TTAuditoriaCCB.Create;
    objeto.Codigo := rsqlIB.FieldByName('codigo').AsString;
    objeto.Estado := rsqlIB.FieldByName('estado').AsString;
    objeto.Coseguro := rsqlIB.FieldByName('coseguro').AsFloat;
    l.Add(objeto);
    if aplica = 'S' then monto_diferencial := monto_diferencial + (rsqlIB.FieldByName('montodif').AsFloat - rsqlIB.FieldByName('monto').AsFloat);
    rsqlIB.Next;
  end;
  rsqlIB.Close; rsqlIB := nil;}

  if datosdb.Buscar(cabauditoria, 'nroauditoria', xnroauditoria) then begin
    _nrodoc := cabauditoria.FieldByName('nrodoc').AsString;
    _nroaut := cabauditoria.FieldByName('nroautorizacion').AsString;
    _fecha := cabauditoria.FieldByName('fecha').AsString;
  end;

  {
  if datosdb.Buscar(detauditoria, 'nroauditoria', 'items', xnroauditoria, '001') then Begin
    while not detauditoria.Eof do Begin
      if detauditoria.FieldByName('nroauditoria').AsString <> xnroauditoria then Break;
      //lista.Add(detauditoria.FieldByName('codigo').AsString + detauditoria.FieldByName('estado').AsString);
      objeto := TTAuditoriaCCB.Create;
      objeto.Codigo := detauditoria.FieldByName('codigo').AsString;
      objeto.Estado := detauditoria.FieldByName('estado').AsString;
      objeto.montoCoseguro := detauditoria.FieldByName('coseguro').AsFloat;
      objeto.Nrodoc := _nrodoc;
      objeto.Nroautorizacion := _nroaut;
      objeto.Fecha := _fecha;
      l.Add(objeto);
      if aplica = 'S' then monto_diferencial := monto_diferencial + (detauditoria.FieldByName('montodif').AsFloat - detauditoria.FieldByName('monto').AsFloat);
      detauditoria.Next;
    end;
  end;
  }

  rs := datosdb.tranSQL(detauditoria.DatabaseName, 'select codigo, estado, coseguro from det_auditoria where nroauditoria = ' + '''' + xnroauditoria + '''' + ' order by items');
  rs.open; rs.first;
  while not rs.Eof do Begin
    objeto := TTAuditoriaCCB.Create;
    objeto.Codigo := rs.FieldByName('codigo').AsString;
    objeto.Estado := rs.FieldByName('estado').AsString;
    objeto.montoCoseguro := rs.FieldByName('coseguro').AsFloat;
    objeto.Nrodoc := _nrodoc;
    objeto.Nroautorizacion := _nroaut;
    objeto.Fecha := _fecha;
    l.Add(objeto);
    if aplica = 'S' then monto_diferencial := monto_diferencial + (rs.FieldByName('montodif').AsFloat - rs.FieldByName('monto').AsFloat);
    rs.Next;
  end;
  rs.close; rs.free;

  Result := l;
end;

function  TTAuditoriaCCB.setDeterminacionesFecha(xfecha: String): TQuery;
// Objetivo...: Recuperar las ordenes de auditor�a en una fecha
Begin
  Result := datosdb.tranSQL(directorio, 'select * from cab_auditoria where fecha = ' + '"' + utiles.sExprFecha2000(xfecha) + '"');
end;

function  TTAuditoriaCCB.setDeterminacionesObraSocial(xcodos, xfecha: String): TQuery;
// Objetivo...: Recuperar las ordenes de auditor�a de una obra social determinada
Begin
  Result := datosdb.tranSQL(directorio, 'select * from cab_auditoria where codos = ' + '"' + xcodos + '"' + ' and fecha = ' + '"' + utiles.sExprFecha2000(xfecha) + '"');
end;

function TTAuditoriaCCB.setRecalcularTotalAnalisisMensual(xfecha, xcodos: String; xrecalcularmontos: Boolean): Real;
// Objetivo...: Recalcular el total mensual de analisis de una obra social
var
  pf, uf, codanter, codigo: String;
  total, monto: Real;
  rs: TQuery;

  procedure guardarMonto(xcodigo, xdesde, xhasta: string; xmonto: real);
  begin
    //utiles.msgerror('select det_auditoria.nroauditoria, det_auditoria.codigo.items from det_auditoria, cab_auditoria where det_auditoria.nroauditoria = cab_auditoria.nroauditoria and cab_auditoria.fecha >= ' + '''' + pf + '''' + ' and cab_auditoria.fecha <= ' + '''' + uf + '''' + ' and cab_auditoria.nroderivacion = "" and det_auditoria.codigo = ' + '''' + xcodigo + '''');
    rs := datosdb.tranSQL(cabauditoria.DatabaseName, 'select det_auditoria.nroauditoria, det_auditoria.items from det_auditoria, cab_auditoria where det_auditoria.nroauditoria = cab_auditoria.nroauditoria and cab_auditoria.fecha >= ' + '''' + pf + '''' + ' and cab_auditoria.fecha <= ' + '''' + uf + '''' + ' and cab_auditoria.nroderivacion = "" and det_auditoria.codigo = ' + '''' + xcodigo + '''');
    rs.Open;
    while not rs.eof do begin
      if (datosdb.Buscar(detauditoria, 'nroauditoria', 'items', rs.FieldByName('nroauditoria').AsString, rs.FieldByName('items').AsString)) then begin
        detauditoria.Edit;
        detauditoria.FieldByName('monto').AsFloat := xmonto;
        try
          detauditoria.Post
         except
          detauditoria.Cancel
        end;
      end;
      rs.next;    
    end;
    rs.Close; rs.Free;
  end;
  
Begin
  pf   := Copy(utiles.sExprFecha2000(xfecha), 1, 6) + '01';
  uf   := Copy(utiles.sExprFecha2000(xfecha), 1, 6) + Copy(xfecha, 1, 2);

  if xrecalcularmontos then Begin  
    rsql := datosdb.tranSQL(cabauditoria.DatabaseName, 'select det_auditoria.codigo, det_auditoria.estado from det_auditoria, cab_auditoria where det_auditoria.nroauditoria = cab_auditoria.nroauditoria and cab_auditoria.fecha >= ' + '''' + pf + '''' + ' and cab_auditoria.fecha <= ' + '''' + uf + '''' + ' and cab_auditoria.nroderivacion = "" order by codigo');
    rsql.Open; codanter := ''; total := 0;
    while not rsql.eof do begin
      if (rsql.FieldByName('codigo').AsString <> codanter) then begin
        codigo := rsql.FieldByName('codigo').AsString;
        monto := facturacion.setImporteAnalisis(xcodos, rsql.FieldByName('codigo').AsString, Copy(xfecha, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xfecha), 1, 4)) + facturacion.setTot9984;
        guardarMonto(codigo, pf, uf, monto);
      end;
      codanter := rsql.FieldByName('codigo').AsString;
      rsql.Next;
    end;
    rsql.Close; rsql.Free;

    guardarMonto(codigo, pf, uf, monto);
  End;  

  rsql := datosdb.tranSQL(cabauditoria.DatabaseName, 'select sum(det_auditoria.monto) as total from det_auditoria, cab_auditoria where det_auditoria.nroauditoria = cab_auditoria.nroauditoria and cab_auditoria.fecha >= ' + '''' + pf + '''' + ' and cab_auditoria.fecha <= ' + '''' + uf + '''' + ' and cab_auditoria.nroderivacion = "" and estado="A"');
  rsql.Open;
  total := rsql.FieldByName('total').asfloat;
  rsql.Close; rsql.Free;

  RegistrarTotalMensual(xcodos, xfecha, total);  

  
  {datosdb.Filtrar(cabauditoria, 'codos = ' + xcodos + ' and fecha >= ' + pf + ' and fecha <= ' + uf);
  cabauditoria.First; total := 0;
  while not cabauditoria.Eof do Begin
    datosdb.Buscar(detauditoria, 'nroauditoria', 'items', cabauditoria.FieldByName('nroauditoria').AsString, '001');
    while not detauditoria.Eof do Begin
      if detauditoria.FieldByName('nroauditoria').AsString <> cabauditoria.FieldByName('nroauditoria').AsString then Break;
      if Length(Trim(cabauditoria.FieldByName('nroderivacion').AsString)) = 0 then Begin
        if detauditoria.FieldByName('estado').AsString = 'A' then Begin
          if xrecalcularmontos then Begin
            monto := facturacion.setImporteAnalisis(xcodos, detauditoria.FieldByName('codigo').AsString, Copy(xfecha, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xfecha), 1, 4)) + facturacion.setTot9984;
            detauditoria.Edit;
            detauditoria.FieldByName('monto').AsFloat := monto;
            try
              detauditoria.Post
             except
              detauditoria.Cancel
            end;
          end;
          if (detauditoria.FieldByName('anulada').AsString <> 'S') and (detauditoria.FieldByName('anulada').AsString <> 'P') then
            total := total + utiles.setNro2Dec(detauditoria.FieldByName('monto').AsFloat);
        end;
      end;
      detauditoria.Next;
    end;
    cabauditoria.Next;
  end;
  datosdb.QuitarFiltro(cabauditoria);

  RegistrarTotalMensual(xcodos, xfecha, total);

  if xrecalcularmontos then Begin
    datosdb.closeDB(detauditoria);
    detauditoria.Open;
  end;}

  Result := total;
end;

function TTAuditoriaCCB.setTotalAnalisisMensual(xfecha, xcodos: String; xrecalcularmontos: Boolean): Real;
// Objetivo...: Recalcular el total mensual de analisis de una obra social
Begin
  if datosdb.Buscar(totalOS, 'codos', 'periodo', xcodos, utiles.setPeriodo(xfecha)) then Result := totalOS.FieldByName('total').AsFloat else Result := setRecalcularTotalAnalisisMensual(xfecha, xcodos, xrecalcularmontos);
end;

procedure TTAuditoriaCCB.RegistrarTotalMensual(xcodos, xfecha: String; xtotal: Real);
// Objetivo...: Registrar totales mensuales
Begin
  if datosdb.Buscar(totalOS, 'codos', 'periodo', xcodos, utiles.setPeriodo(xfecha)) then totalOS.Edit else totalOS.Append;
  totalOS.FieldByName('codos').AsString   := xcodos;
  totalOS.FieldByName('periodo').AsString := utiles.setPeriodo(xfecha);
  totalOS.FieldByName('total').AsFloat    := xtotal;
  try
    totalOS.Post
   except
    totalOS.Cancel
  end;
  datosdb.refrescar(totalOS);
end;

function TTAuditoriaCCB.setOrdenesAuditadas(xperiodo, xcodos: String): TStringList;
// Objetivo...: Recuperar Ordenes por Fecha
var
  l: TStringList;
Begin
  l := TStringList.Create;
  datosdb.Filtrar(cabauditoria, 'fecha >= ' + '''' +  Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2) + '01' + '''' + ' and fecha <= ' + '''' + Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2) + '31' + '''' + ' and codosfact = ' + '''' + xcodos + '''');
  cabauditoria.First;
  while not cabauditoria.Eof do Begin
    l.Add(cabauditoria.FieldByName('nroauditoria').AsString);
    cabauditoria.Next;
  end;
  datosdb.QuitarFiltro(cabauditoria);

  Result := l;
end;

function TTAuditoriaCCB.setCodidosAuditados(xnroauditoria: String): TStringList;
// Objetivo...: Recuperar Ordenes por Fecha
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if datosdb.Buscar(detauditoria, 'nroauditoria', 'items', xnroauditoria, '001') then Begin
    while not detauditoria.Eof do Begin
      if detauditoria.FieldByName('nroauditoria').AsString <> xnroauditoria then Break;
      if detauditoria.FieldByName('estado').AsString = 'A' then l.Add(detauditoria.FieldByName('codigo').AsString);
      detauditoria.Next;
    end;
  end;
  Result := l;
end;

procedure TTAuditoriaCCB.ListarOrden(xdnro, xhnro, xdfecha, xhfecha, xultimonro, xtamanio_fuente: String; salida: char);
// Objetivo...: Listar Ordenes
const s = '     ';
var
  r: TObjectList;
  objeto: TTAuditoriaCCB;
  f, modo_grafico: Boolean;
  l: array[1..20] of String;
  ll, oobs, ccanter, dpas, npas: String;
  i, j, k, m, n, h, tk: Integer;
  coseguro: real;
Begin
  modo_grafico := False;

  datosdb.closeDB(cabauditoria); cabauditoria.Open;

  if (ImpresionModoTexto) and (salida = 'I') then modo_grafico := False;
  if not ImpresionModoTexto then modo_grafico := True;

  f := False;
  if LineasTxt = 0 then LineasTxt := 65;
  lineas := 0;

  nroauditoria := cabauditoria.FieldByName('nroauditoria').AsString;
  if Length(Trim(xdnro)) > 0 then
    if Buscar(xdnro) then f := True else f := False;

  if Length(Trim(xdfecha)) > 0 then Begin
    cabauditoria.IndexFieldNames := 'Fecha';
    if cabauditoria.FindKey([utiles.sExprFecha2000(xdfecha)]) then f := True else f := False;
  end;

  if f then Begin    // Si los parametros son correctos
    if modo_grafico then Begin
      list.Setear(salida);
      list.NoImprimirPieDePagina;
    end else
      list.IniciarImpresionModoTexto(lineasTxt);

    k := 1;
    while not cabauditoria.Eof do Begin
      if cabauditoria.FieldByName('codos').AsString <> ccanter then Begin
        SincronizarArancelDiferencial(cabauditoria.FieldByName('codos').AsString, Copy(cabauditoria.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(cabauditoria.FieldByName('fecha').AsString, 1, 4));
        ccanter := cabauditoria.FieldByName('codos').AsString;
      end;

      coseguro := 0;
      r := setItemsHistorial(cabauditoria.FieldByName('nroauditoria').AsString, False);
      for h := 1 to r.Count do Begin
        objeto := TTAuditoriaCCB(r.Items[h-1]);
        if objeto.Estado = 'A' then Begin
          if (objeto.montoCoseguro > 0) then coseguro := coseguro + objeto.montoCoseguro;

        end;
      end;

      if Length(Trim(cabauditoria.FieldByName('nombre').AsString)) > 0 then Begin
        dpas := cabauditoria.FieldByName('nrodoc').AsString;
        npas := cabauditoria.FieldByName('nombre').AsString;
      end else Begin
        padron.getDatosExistentes(cabauditoria.FieldByName('codos').AsString, cabauditoria.FieldByName('nrodoc').AsString);
        dpas := padron.Nrodoc;
        npas := padron.Nombre;
      end;
      obsocial.getDatos(cabauditoria.FieldByName('codos').AsString);
      medico.getDatos(cabauditoria.FieldByName('idprof').AsString);
      if monto_diferencial < 0 then monto_diferencial := 0;
      if modo_grafico then Begin
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 14', salida, 'S');
        list.Linea(0, 0, s + Entidad, 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(55, list.Lineactual, obsocial.Nombre, 2, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, s + 'Paciente: ' + npas, 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(55, list.Lineactual, 'Doc.: ' + dpas, 2, 'Arial, normal, 8', salida, 'N');
        if monto_diferencial <> 0 then list.importe(90, list.Lineactual, '', monto_diferencial, 3, 'Arial, negrita, 8') else
          list.importe(90, list.Lineactual, '######.##', monto_diferencial, 3, 'Arial, negrita, 8');
        list.Linea(91, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, s + 'Fecha: ' + utiles.sFormatoFecha(cabauditoria.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(55, list.Lineactual, 'Dr/a.: ' + medico.Nombre, 2, 'Arial, normal, 8', salida, 'S');

        if (coseguro = 0) then
          list.Linea(0, 0, s + 'Dx: ' + cabauditoria.FieldByName('diagnostico').AsString, 1, 'Arial, normal, 8', salida, 'S')
        else begin
          list.Linea(0, 0, s + 'Dx: ' + cabauditoria.FieldByName('diagnostico').AsString, 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(55, list.Lineactual, 'Coseguro: $ ' + utiles.FormatearNumero(floattostr(coseguro)), 2, 'Arial, negrita, 8', salida, 'S');
        end;
      end else Begin
        list.LineaTxt(' ', True); Inc(lineas);
        list.LineaTxt(s + Entidad, True); Inc(lineas);
        list.LineaTxt(obsocial.Nombre, True); Inc(lineas);
        list.LineaTxt('Paciente: ' + padron.Nombre + utiles.espacios(45 - Length(TrimLeft(padron.Nombre))) + 'Doc.: ' + padron.Nrodoc, True); Inc(lineas);
        list.LineaTxt('Fecha: ' + utiles.sFormatoFecha(cabauditoria.FieldByName('fecha').AsString) + '  Dr/a.: ' + medico.Nombre, True); Inc(lineas);
        list.LineaTxt('Dx: ' + cabauditoria.FieldByName('diagnostico').AsString, True); Inc(lineas);
      end;



      i := 1; m := 1;
      for j := 1 to 5 do l[j] := '';
      for h := 1 to r.Count do Begin
        objeto := TTAuditoriaCCB(r.Items[h-1]);
        if objeto.Estado = 'A' then Begin
          if m > ItemsPorDeterminacion then Begin
            m := 1; Inc(i);
          end;
          Inc(m);
          l[i] := l[i] + objeto.Codigo + '  ';
        end;
      end;

      r.Free; r := Nil;

      if modo_grafico then
        list.Linea(0, 0, s + 'Autorizadas: ', 1, 'Arial, normal, 8', salida, 'N')
      else
        list.LineaTxt('Autorizadas: ', False);
      for j := 1 to 5 do Begin
        if Length(Trim(l[j])) = 0 then Break;
        if modo_grafico then Begin
          if j = 1 then list.Linea(15, list.Lineactual, l[j], 2, 'Arial, normal, 8', salida, 'S') else Begin
            list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
            list.Linea(15, list.Lineactual, l[j], 2, 'Arial, normal, 8', salida, 'S');
          end;
        end else Begin
          ll := '';
          for tk := 1 to j do ll := ll + l[tk] + ' ';
          list.LineaTxt( ll, True); Inc(lineas);
        end;
      end;

      if modo_grafico then list.Linea(0, 0, ' ', 1, 'Arial, normal, 12', salida, 'N') else Begin
        list.LineaTxt('', True); Inc(lineas);
      end;

      if modo_grafico then Begin
        if ImprimeCodigoBarras then list.Linea(70, list.Lineactual, '!' + cabauditoria.FieldByName('nroauditoria').AsString + '!', 2, 'IDAutomationCode39, normal, ' + xtamanio_fuente, salida, 'S') else
          list.Linea(70, list.Lineactual, cabauditoria.FieldByName('nroauditoria').AsString, 2, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, s + cabauditoria.FieldByName('observacion').AsString, 1, 'Arial, normal, 8', salida, 'S');
      end else Begin
        list.LineaTxt(utiles.espacios(55) + cabauditoria.FieldByName('nroauditoria').AsString, True); Inc(lineas);
        list.LineaTxt(cabauditoria.FieldByName('observacion').AsString, True); Inc(lineas);
      end;

      // Observacion Final
      if BuscarObsFinal(cabauditoria.FieldByName('nroauditoria').AsString) then oobs := obsauditoria.FieldByName('observacion').AsString else oobs := '';
      if modo_grafico then Begin
        list.Linea(0, 0, s + oobs, 1, 'Arial, negrita, 10', salida, 'S');
      end else Begin
        list.LineaTxt(oobs, True); Inc(lineas);
      end;

      Inc(k);
      if k > EtiquetasPorPagina then Begin
        if modo_grafico then Begin
          list.CompletarPagina;
          list.IniciarNuevaPagina;
        end else Begin
          for tk := lineas to LineasTxt - 1 do list.LineaTxt('', True);
          for tk := 1 to SeparacionPaginas do list.LineaTxt('', True);
          lineas := 0;
        end;
        k := 1;
      end;

      UltimaOrdenImpresa := cabauditoria.FieldByName('nroauditoria').AsString;

      cabauditoria.Next;

      if Length(Trim(xdnro)) > 0 then
        if cabauditoria.FieldByName('nroauditoria').AsString > xhnro then Break;
      if Length(Trim(xhfecha)) > 0 then
        if cabauditoria.FieldByName('fecha').AsString > utiles.sExprFecha2000(xhfecha) then Break;

      for n := 1 to LineasSeparacionEtiquetas do Begin
        if modo_grafico then list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
        if not modo_grafico then
          if lineas > 0 then list.LineaTxt('', True);
      end;
    end;

    if modo_grafico then list.FinList else Begin
      if SaltarPagina then list.FinalizarImpresionModoTexto(1) else list.FinalizarImpresionModoTextoSinSaltarPagina(1);
    end;

  end else
    utiles.msgError('Los Par�metros Suministrados no Arrojaron Ningun Resultado ...!');

  cabauditoria.IndexFieldNames := 'Nroauditoria';
  Buscar(nroauditoria);
end;

function  TTAuditoriaCCB.setNuevoNroAuditoria: String;
// Objetivo...: Recuperar el Ultimo Nro. de Auditor�a Impreso
Begin
  rsql := datosdb.tranSQL(cabauditoria.DatabaseName, 'select max(nroauditoria) as cant from cab_auditoria');
  rsql.Open;
  if Length(Trim(rsql.FieldByName('cant').AsString)) = 0 then Result := '1' else Result := IntToStr(rsql.FieldByName('cant').AsInteger + 1);
  rsql.Close; rsql.free;

  //if cabauditoria.IndexFieldNames <> 'Nroauditoria' then cabauditoria.IndexFieldNames := 'Nroauditoria';
  //cabauditoria.Last;
  //if Length(Trim(cabauditoria.FieldByName('nroauditoria').AsString)) = 0 then Result := '1' else Result := IntToStr(cabauditoria.FieldByName('nroauditoria').AsInteger + 1);
  {rsqlIB := ffirebird.getTransacSQL('select max(nroauditoria) as cant from cab_auditoria');
  rsqlIB.Open;
  if (rsqlIB.RecordCount = 0) then result := '1' else Result := IntToStr(rsqlIB.FieldByName('cant').AsInteger + 1);}
end;

procedure TTAuditoriaCCB.MarcarAuditoriaComoFacturada(xnroauditoria, xidfact, xfecha, xlaboratorio: String);
// Objetivo...: Marcar Orden como Facturada
Begin
  if Buscar(xnroauditoria) then Begin
    cabauditoria.Edit;
    cabauditoria.FieldByName('idfact').AsString      := xidfact;
    cabauditoria.FieldByName('fechafac').AsString    := utiles.sExprFecha2000(xfecha);
    cabauditoria.FieldByName('laboratorio').AsString := xlaboratorio;
    try
      cabauditoria.Post
     except
      cabauditoria.Cancel
    end;
    datosdb.refrescar(cabauditoria);
  end;
end;

function  TTAuditoriaCCB.setLaboratorioFacturado(xnroauditoria: String): String;
// Objetivo...: Devolver Laboratorio Facturado
var
  estado: Boolean;
Begin
  estado := cabauditoria.Active;
  if not cabauditoria.Active then cabauditoria.Open;
  if Buscar(utiles.sLlenarIzquierda(xnroauditoria, 10, '0')) then Result := cabauditoria.FieldByName('laboratorio').AsString else Result := '';
  cabauditoria.Active := estado;
end;

procedure TTAuditoriaCCB.BorrarLaboratorioFacturado(xnroauditoria: String);
// Objetivo...: Devolver Laboratorio Facturado
var
  estado: Boolean;
Begin
  estado := cabauditoria.Active;
  if not cabauditoria.Active then cabauditoria.Open;
  if Buscar(utiles.sLlenarIzquierda(xnroauditoria, 10, '0')) then Begin
    cabauditoria.Edit;
    cabauditoria.FieldByName('idfact').AsString      := '';
    cabauditoria.FieldByName('fechafac').AsString    := '';
    cabauditoria.FieldByName('laboratorio').AsString := '';
    try
      cabauditoria.Post
     except
      cabauditoria.Cancel
    end;
    datosdb.refrescar(cabauditoria);
  end;
  cabauditoria.Active := estado;
end;

procedure TTAuditoriaCCB.InfControlOrdenesFacturadas(xdfecha, xhfecha: String; salida: Char);
// Objetivo...: Facturar ordenes
var
  i, j: Integer;
  r: TObjectList;
  objeto: TTAuditoriaCCB;
  ls: String;
Begin
  list.IniciarTitulos;
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Control de Ordenes de Auditor�a Facturadas', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
  list.Titulo(0, 0, 'N� Auditor�a', 1, 'Arial, cursiva, 8');
  list.Titulo(11, list.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
  list.Titulo(20, list.Lineactual, 'Obra Social', 3, 'Arial, cursiva, 8');
  list.Titulo(60, list.Lineactual, 'Det. Facturadas', 4, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');

  j := 0;
  cabauditoria.IndexFieldNames := 'Fechafac';
  if cabauditoria.FindKey([utiles.sExprFecha2000(xdfecha)]) then Begin
    while not cabauditoria.Eof do Begin
      obsocial.getDatos(cabauditoria.FieldByName('codos').AsString);
      list.Linea(0, 0, cabauditoria.FieldByName('nroauditoria').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(11, list.Lineactual, utiles.sFormatoFecha(cabauditoria.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(20, list.Lineactual, obsocial.Nombre, 3, 'Arial, normal, 8', salida, 'N');
      ls := '';

      r := setItemsHistorial(cabauditoria.FieldByName('nroauditoria').AsString, False);
      for i := 1 to r.Count do Begin
        objeto := TTAuditoriaCCB(r.Items[i-1]);
        if objeto.Codigo = 'A' then ls := ls + objeto.Codigo + '  ';
      end;
      r.Free; r := Nil;

      list.Linea(60, list.Lineactual, ls, 4, 'Arial, normal, 8', salida, 'S');
      Inc(j);

      cabauditoria.Next;
      if (cabauditoria.FieldByName('fechafac').AsString > utiles.sExprFecha2000(xdfecha)) or (Length(Trim(cabauditoria.FieldByName('fechafac').AsString)) = 0) then Break;
    end;
  end;
  cabauditoria.IndexFieldNames := 'Nroauditoria';

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'Cantidad de Ordenes Facturadas:  ' + IntToStr(j), 1, 'Arial, negrita, 8', salida, 'S');

  list.FinList;
end;

procedure TTAuditoriaCCB.ListarOrdenesAutorizadas(listObSociales: TStringList; xfdesde, xfhasta: String; salida: char; xinf_envio: Boolean);
Begin
  inf_envio := xinf_envio;
  ListOrdenes(listObSociales, 'Auditor�a Bioquimica: C�digos Autorizados', xfdesde, xfhasta, 'A', salida);
end;

procedure TTAuditoriaCCB.ListarOrdenesRechazadas(listObSociales: TStringList; xfdesde, xfhasta: String; salida: char; xinf_envio: Boolean);
Begin
  inf_envio := xinf_envio;
  ListOrdenes(listObSociales, 'Auditor�a Bioquimica: C�digos Rechazados', xfdesde, xfhasta, 'R', salida);
end;

procedure TTAuditoriaCCB.IniciarObraSocial(xcodos: String; salida: char);
// Objetivo...: Ruptura por Obra Social
Begin
  LineaDeterminaciones(iitems, salida);
  if (totales[3] <> 0) or (totgrales[1] <> 0) then TotalObraSocial(salida);
  obsocial.getDatos(xcodos);
  if salida <> 'X' then Begin
    list.Linea(0, 0, 'Obra Social: ' + obsocial.Nombre, 1, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
  end else Begin
    Inc(ke); me := IntToStr(ke);
    excel.setString('a' + me, 'a' + me, 'Obra Social:  ' + obsocial.Nombre, 'Arial, negrita, 10');
  end;
  idanter[1] := xcodos;
end;

procedure TTAuditoriaCCB.IniciarZona(xidzona: String; salida: char);
// Objetivo...: Ruptura por Zona
Begin
  //////////////LineaDeterminaciones(iitems, salida);
  if totales[1] <> 0 then TotalZona(salida);
  zonas.getDatos(xidzona);
  if salida <> 'X' then Begin
    list.Linea(0, 0, 'Zona: ' + zonas.Zona, 1, 'Arial, negrita, 8, clNavy', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
  end else Begin
    Inc(ke); me := IntToStr(ke);
    excel.setString('a' + me, 'a' + me, 'Zona:  ' + zonas.Zona, 'Arial, negrita, 9');
    Inc(ke); me := IntToStr(ke);
    rangoceldas[1] := me;
    Dec(ke);
  end;
  idanter[2] := xidzona;
end;

procedure TTAuditoriaCCB.TotalZona(salida: char);
// Objetivo...: Listar Total Zona
Begin
  if not inf_envio then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'N');
      list.derecha(96, list.Lineactual, '', '--------------------------------------------------', 2, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'Total Zona:', 1, 'Arial, negrita, 8, clNavy', salida, 'N');
      list.importe(75, list.Lineactual, '#####', totales[1], 2, 'Arial, negrita, 8, clNavy');
      list.importe(95, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 8, clNavy');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 8, clNavy', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end else Begin
      rangoceldas[2] := me;
      Inc(ke); me := IntToStr(ke);
      excel.setString('b' + me, 'b' + me, 'Total Zona:', 'Arial, negrita, 9');
      excel.setFormulaArray('c' + me, 'c' + me, '=suma(' + 'c' + rangoceldas[1] + '..c' + rangoceldas[2] + ')', 'Arial, negrita, 9');
      excel.setFormulaArray('d' + me, 'd' + me, '=suma(' + 'd' + rangoceldas[1] + '..d' + rangoceldas[2] + ')', 'Arial, negrita, 9');
      lceldas.Add(me);
    end;
    totales[1] := 0; totales[2] := 0;
  end;
  if inf_envio then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'N');
      list.derecha(96, list.Lineactual, '', '------------------------------------------------------------------------------------------------------------------------------------------', 2, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'Total Zona:', 1, 'Arial, negrita, 8, clNavy', salida, 'N');
      list.importe(21, list.Lineactual, '#####', totales[1], 2, 'Arial, negrita, 8, clNavy');
      list.importe(30, list.Lineactual, '', totales[2], 3, 'Arial, normal, 8');
      list.importe(40, list.Lineactual, '', totales[3], 4, 'Arial, normal, 8');
      list.importe(50, list.Lineactual, '', totales[4], 5, 'Arial, normal, 8');
      list.importe(65, list.Lineactual, '', totales[5], 6, 'Arial, normal, 8');
      list.importe(75, list.Lineactual, '', totales[6], 7, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', totales[7], 8, 'Arial, negrita, 8, clNavy');
      list.Linea(96, list.Lineactual, '', 9, 'Arial, negrita, 8, clNavy', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end else Begin
      rangoceldas[2] := me;
      Inc(ke); me := IntToStr(ke);
      excel.setString('b' + me, 'b' + me, 'Total Zona:', 'Arial, negrita, 9');
      excel.setFormulaArray('c' + me, 'c' + me, '=suma(' + 'c' + rangoceldas[1] + '..c' + rangoceldas[2] + ')', 'Arial, negrita, 9');
      excel.setFormulaArray('d' + me, 'd' + me, '=suma(' + 'd' + rangoceldas[1] + '..d' + rangoceldas[2] + ')', 'Arial, negrita, 9');
      lceldas.Add(me);
    end;
    totgrales[1] := totgrales[1] + totales[1];
    totgrales[2] := totgrales[2] + totales[2];
    totgrales[3] := totgrales[3] + totales[3];
    totgrales[4] := totgrales[4] + totales[4];
    totgrales[5] := totgrales[5] + totales[5];
    totgrales[6] := totgrales[6] + totales[6];
    totgrales[7] := totgrales[7] + totales[7];
    totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0;
  end;
end;

procedure TTAuditoriaCCB.TotalObraSocial(salida: char);
// Objetivo...: Listar Total Obra Social
var
  f, g: String; i: Integer;
Begin
  if not inf_envio then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'N');
      list.derecha(96, list.Lineactual, '', '--------------------------------------------------', 2, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'Total Obra Social:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(75, list.Lineactual, '#####', totales[3], 2, 'Arial, normal, 9');
      list.importe(95, list.Lineactual, '', totales[4], 3, 'Arial, normal, 9');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end else Begin
      Inc(ke); me := IntToStr(ke);
      excel.setString('b' + me, 'b' + me, 'Total Obra Social:', 'Arial, negrita, 9');
      f := '';
      for i := 1 to lceldas.Count do f := f + 'c' + lceldas.Strings[i-1] + '+';
      g := '=' + Copy(f, 1, Length(f) -1);
      excel.setFormula('c' + me, 'c' + me, g, 'Arial, negrita, 9');
      f := '';
      for i := 1 to lceldas.Count do f := f + 'd' + lceldas.Strings[i-1] + '+';
      g := '=' + Copy(f, 1, Length(f) -1);
      excel.setFormula('d' + me, 'd' + me, g, 'Arial, negrita, 9');
    end;
    totales[3] := 0; totales[4] := 0;
  end;
  if inf_envio then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'N');
      list.derecha(96, list.Lineactual, '', '------------------------------------------------------------------------------------------------------------------------------------------', 2, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'Tot. Obra Social:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(21, list.Lineactual, '#####', totgrales[1], 2, 'Arial, negrita, 9');
      list.importe(30, list.Lineactual, '', totgrales[2], 3, 'Arial, normal, 9');
      list.importe(40, list.Lineactual, '', totgrales[3], 4, 'Arial, normal, 9');
      list.importe(50, list.Lineactual, '', totgrales[4], 5, 'Arial, normal, 9');
      list.importe(65, list.Lineactual, '', totgrales[5], 6, 'Arial, normal, 9');
      list.importe(75, list.Lineactual, '', totgrales[6], 7, 'Arial, normal, 9');
      list.importe(95, list.Lineactual, '', totgrales[7], 8, 'Arial, negrita, 9');
      list.Linea(96, list.Lineactual, '', 9, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end else Begin
      Inc(ke); me := IntToStr(ke);
      excel.setString('b' + me, 'b' + me, 'Total Obra Social:', 'Arial, negrita, 9');
      f := '';
      for i := 1 to lceldas.Count do f := f + 'c' + lceldas.Strings[i-1] + '+';
      g := '=' + Copy(f, 1, Length(f) -1);
      excel.setFormula('c' + me, 'c' + me, g, 'Arial, negrita, 9');
      f := '';
      for i := 1 to lceldas.Count do f := f + 'd' + lceldas.Strings[i-1] + '+';
      g := '=' + Copy(f, 1, Length(f) -1);
      excel.setFormula('d' + me, 'd' + me, g, 'Arial, negrita, 9');
    end;

    totfinal[1] := totfinal[1] + totgrales[1];
    totfinal[2] := totfinal[2] + totgrales[2];
    totfinal[3] := totfinal[3] + totgrales[3];
    totfinal[4] := totfinal[4] + totgrales[4];
    totfinal[5] := totfinal[5] + totgrales[5];
    totfinal[6] := totfinal[6] + totgrales[6];
    totfinal[7] := totfinal[7] + totgrales[7];
    totgrales[1] := 0; totgrales[2] := 0; totgrales[3] := 0; totgrales[4] := 0; totgrales[5] := 0; totgrales[6] := 0; totgrales[7] := 0;
  end;
end;

procedure TTAuditoriaCCB.LineaDeterminaciones(xitems: Integer; salida: char);
// Objetivo...: Listar Determinaciones
var
  i: Integer;
  r: TQuery;
  c, d: String;
  u: real;
Begin
  if not inf_envio then Begin
    if (obsocial.Factnbu = 'N') or (c4 = 4) then r := nomeclatura.setNomeclatura;
    if (obsocial.Factnbu = 'S') and (c4 = 6) then r := nbu.setDeterminaciones;
    r.Open;
    while not r.Eof do Begin
      for i := 1 to xitems do Begin
        if Trim(r.FieldByName('codigo').AsString) = Trim(cp[i]) then Begin
          if (obsocial.Factnbu = 'N') or (c4 = 4) then begin
            nomeclatura.getDatos(cp[i]);
            d := nomeclatura.descrip;
            u := 0;
          end;
          if (obsocial.Factnbu = 'S') and (c4 = 6) then begin
            nbu.getDatos(cp[i]);
            d := nbu.Descrip;
            u := nbu.unidad;
          end;
          if salida <> 'X' then Begin
            list.Linea(0, 0, cp[i], 1, 'Arial, normal, 8', salida, 'N');
            list.Linea(8, list.Lineactual, d, 2, 'Arial, normal, 8', salida, 'N');
            list.importe(65, list.Lineactual, '####', u, 3, 'Arial, normal, 8');
            list.importe(75, list.Lineactual, '####', ca[i], 4, 'Arial, normal, 8');
            list.importe(95, list.Lineactual, '', im[i], 5, 'Arial, normal, 8');
            list.Linea(96, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
          end else Begin
            Inc(ke); me := IntToStr(ke);
            excel.setString('a' + me, 'a' + me, '''' + cp[i], 'Arial, normal, 9');
            excel.setString('b' + me, 'b' + me, nomeclatura.descrip, 'Arial, normal, 9');
            excel.setReal('c' + me, 'c' + me, u, 'Arial, normal, 9'); 
            excel.setReal('d' + me, 'd' + me, ca[i], 'Arial, normal, 9');
            excel.setReal('z' + me, 'z' + me, im[i] / ca[i], 'Arial, normal, 9');
            excel.setFormula('d' + me, 'd' + me, '=c' + me + '*z' + me, 'Arial, normal, 9');
          end;
          Break;
        end;
      end;
      r.Next;
    end;
    r.Close; r.Free;

    iitems := 0;
    for i := 1 to cantitems do Begin
      cp[i] := ''; ca[i] := 0; im[i] := 0; ct[i] := 0;
    end;
  end;

  if inf_envio then Begin
    if (obsocial.Factnbu = 'N') or (c4 = 4) then r := nomeclatura.setNomeclatura;
    if (obsocial.Factnbu = 'S') and (c4 = 6) then r := nbu.setDeterminaciones;
    r.Open;
    while not r.Eof do Begin
      for i := 1 to xitems do Begin
        if Trim(r.FieldByName('codigo').AsString) = Trim(cp[i]) then Begin
          if (obsocial.Factnbu = 'N') or (c4 = 4) then nomeclatura.getDatos(cp[i]);
          if (obsocial.Factnbu = 'S') and (c4 = 6) then begin
            nbu.getDatos(cp[i]);
            d := nbu.Descrip;
            u := nbu.unidad;
          end;
          if salida <> 'X' then Begin
            c := cp[i];
            list.Linea(0, 0, c, 1, 'Arial, normal, 8', salida, 'N');
            list.importe(21, list.Lineactual, '####', ca[i], 2, 'Arial, normal, 8');
            if not mf[i] then Begin
              if nomeclatura.RIE <> '*' then Begin
                if (obsocial.Factnbu = 'N') and (c4 = 6) then begin
                list.importe(30, list.Lineactual, '', obsocial.UB * nomeclatura.UB, 3, 'Arial, normal, 8');
                list.importe(40, list.Lineactual, '', obsocial.UG * nomeclatura.gastos, 4, 'Arial, normal, 8');
                list.importe(50, list.Lineactual, '', (obsocial.UB * nomeclatura.ub) + (obsocial.UG * nomeclatura.gastos), 5, 'Arial, normal, 8');
                list.importe(65, list.Lineactual, '', (obsocial.UB * nomeclatura.UB) * ca[i], 6, 'Arial, normal, 8');
                list.importe(75, list.Lineactual, '', (obsocial.UG * nomeclatura.gastos) * ca[i], 7, 'Arial, normal, 8');
                end;
                totales[2] := totales[2] + (obsocial.UB * nomeclatura.UB);
                totales[3] := totales[3] + (obsocial.UG * nomeclatura.gastos);
                totales[4] := totales[4] + ((obsocial.UB * nomeclatura.ub) + (obsocial.UG * nomeclatura.gastos));
                totales[5] := totales[5] + ((obsocial.UB * nomeclatura.UB) * ca[i]);
                totales[6] := totales[6] + ((obsocial.UG * nomeclatura.gastos) * ca[i]);
              end else Begin
                if (obsocial.Factnbu = 'S') and (c4 = 6) then begin
                list.importe(30, list.Lineactual, '', obsocial.RIEUB * nomeclatura.UB, 3, 'Arial, normal, 8');
                list.importe(40, list.Lineactual, '', obsocial.RIEUG * nomeclatura.gastos, 4, 'Arial, normal, 8');
                list.importe(50, list.Lineactual, '', ((obsocial.RIEUB * nomeclatura.ub) + (obsocial.RIEUG * nomeclatura.gastos)) * ca[i], 5, 'Arial, normal, 8');
                list.importe(65, list.Lineactual, '', (obsocial.RIEUB * nomeclatura.UB) * ca[i], 6, 'Arial, normal, 8');
                list.importe(75, list.Lineactual, '', (obsocial.RIEUG * nomeclatura.gastos) * ca[i], 7, 'Arial, normal, 8');
                end;
                totales[2] := totales[2] + (obsocial.RIEUB * nomeclatura.UB);
                totales[3] := totales[3] + (obsocial.RIEUG * nomeclatura.gastos);
                totales[4] := totales[4] + ((obsocial.RIEUB * nomeclatura.ub) + (obsocial.RIEUG * nomeclatura.gastos));
              end
            end else Begin
              list.importe(30, list.Lineactual, '', 0, 3, 'Arial, normal, 8');
              list.importe(40, list.Lineactual, '', 0, 4, 'Arial, normal, 8');
              if (im[i] <> 0) and (ca[i] <> 0) then
                list.importe(50, list.Lineactual, '', im[i] / ca[i], 5, 'Arial, normal, 8')  // 20/10/2007
              else
                list.importe(50, list.Lineactual, '', 0, 5, 'Arial, normal, 8');  // 20/10/2007
              list.importe(65, list.Lineactual, '', 0, 6, 'Arial, normal, 8');
              list.importe(75, list.Lineactual, '', 0, 7, 'Arial, normal, 8');
            end;

            // 05/05/2009 -> ajuste al NBU
            if (obsocial.Factnbu = 'S') and (c4 = 6) then begin
              list.importe(30, list.Lineactual, '', nbu.unidad, 3, 'Arial, normal, 8');
              list.importe(40, list.Lineactual, '', obsocial.valorNBU, 4, 'Arial, normal, 8');
              list.importe(50, list.Lineactual, '', (obsocial.valorNBU * nbu.unidad), 5, 'Arial, normal, 8');
              list.importe(65, list.Lineactual, '', nbu.unidad * ca[i], 6, 'Arial, normal, 8');
              list.importe(75, list.Lineactual, '', 0, 7, 'Arial, normal, 8');

              totales[2] := totales[2] + nbu.unidad;
              totales[4] := totales[4] + (obsocial.valorNBU * nbu.unidad);
              totales[5] := totales[5] + (nbu.unidad * ca[i]);
            end;

            if mf[i] then Begin
              list.importe(95, list.Lineactual, '', im[i], 8, 'Arial, normal, 8');
              totales[7] := totales[7] + i1[i];
            end else Begin
              list.importe(95, list.Lineactual, '', im[i], 8, 'Arial, normal, 8');
              totales[7] := totales[7] + i1[i];
            end;
            list.Linea(96, list.Lineactual, '', 9, 'Arial, normal, 8', salida, 'S');
          end else Begin
            Inc(ke); me := IntToStr(ke);
            c := cp[i];
            excel.setString('a' + me, 'a' + me, '''' + c, 'Arial, normal, 9');
            excel.setString('b' + me, 'b' + me, d, 'Arial, normal, 9');
            excel.setReal('c' + me, 'c' + me, ca[i], 'Arial, normal, 9');
            excel.setReal('d' + me, 'd' + me, u, 'Arial, normal, 9');
            excel.setReal('z' + me, 'z' + me, im[i] / ca[i], 'Arial, normal, 9');
            excel.setFormula('e' + me, 'e' + me, '=c' + me + '*z' + me, 'Arial, normal, 9');
          end;
          Break;
        end;
      end;
      r.Next;
    end;
    r.Close; r.Free;

    iitems := 0;
    for i := 1 to cantitems do Begin
      cp[i] := ''; ca[i] := 0; im[i] := 0; ct[i] := 0; i1[i] := 0;
    end;
  end;
end;

procedure TTAuditoriaCCB.ListOrdenes(listObSociales: TStringList; xtitulo, xfdesde, xfhasta, xestado: String; salida: char);
var
  i, k, z: Integer; monto_analisis, cant9984, tot9984, m9984: real;
  cod9984: String; dmf, lista, auditar: Boolean;

  procedure Listar9984(salida: char);
  Begin
    // 20/10/2007 -> > Agregamos el 9984 como linea final
    if Length(Trim(cod9984)) > 0 then Begin
      k     := z+1;
      cp[k] := cod9984;
      ca[k] := cant9984;
      im[k] := tot9984;
      ct[k] := ct[k] + tot9984;
      LineaDeterminaciones(k, salida);
      cod9984 := ''; cant9984 := 0; tot9984 := 0;
    end;
  end;

Begin
  auditonline.conectar;

  list.Setear(salida);
  if salida <> 'X' then Begin
    if inf_envio then Begin
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, 'Prestador: ' + Entidad, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      list.Titulo(0, 0, 'Per�odo: ' + xfdesde + ' - ' + xfhasta, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, negrita, 14');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      list.Titulo(0, 0, '', 1, 'Arial, Cursiva, 8');
      list.Titulo(29, list.Lineactual, 'VALOR UNITARIO', 2, 'Arial, Normal, 8');
      list.Titulo(70, list.Lineactual, 'VALOR TOTAL', 3, 'Arial, Normal, 8');
      list.Titulo(0, 0, '', 1, 'Arial, Cursiva, 5');
      list.Titulo(0, 0, 'C�digo', 1, 'Arial, Cursiva, 8');
      list.Titulo(16, list.Lineactual, 'Cant.', 2, 'Arial, Cursiva, 8');
      list.Titulo(23, list.Lineactual, 'U.B. NBU', 3, 'Arial, Cursiva, 8');
      list.Titulo(35, list.Lineactual, 'U.B. O.S.', 4, 'Arial, Cursiva, 8');
      list.Titulo(46, list.Lineactual, 'Total', 5, 'Arial, Cursiva, 8');
      list.Titulo(58, list.Lineactual, 'U.B. NBU', 6, 'Arial, Cursiva, 8');
      list.Titulo(69, list.Lineactual, 'U.B. O.S.', 7, 'Arial, Cursiva, 8');
      list.Titulo(91, list.Lineactual, 'Total', 8, 'Arial, Cursiva, 8');
    end;
    if not inf_envio then Begin
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, Entidad, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      list.Titulo(0, 0, xtitulo + ', Per�odo: ' + xfdesde + ' - ' + xfhasta, 1, 'Arial, negrita, 14');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      list.Titulo(0, 0, 'C�digo', 1, 'Arial, Cursiva, 8');
      list.Titulo(8, list.Lineactual, 'Determinaci�n', 2, 'Arial, Cursiva, 8');
      list.Titulo(69, list.Lineactual, 'Cantidad', 3, 'Arial, Cursiva, 8');
      list.Titulo(90, list.Lineactual, 'Importe', 4, 'Arial, Cursiva, 8');
    end;
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
  end else Begin
    excel.setString('a1', 'a1', Entidad, 'Arial, normal, 12');
    excel.setString('a2', 'a2', xtitulo + ', Per�odo: ' + xfdesde + ' - ' + xfhasta, 'Arial, negrita, 12');
    excel.setString('a4', 'a4', 'C�digo', 'Arial, negrita, 9');
    excel.setString('b4', 'b4', 'Determinaci�n', 'Arial, negrita, 9');
    excel.FijarAnchoColumna('b4', 'b4', 50);
    excel.setString('c4', 'c4', 'Cantidad', 'Arial, negrita, 9');
    excel.setString('d4', 'd4', 'Unidades', 'Arial, negrita, 9');
    excel.Alinear('d4', 'd4', 'D');
    excel.setString('e4', 'e4', 'Importe', 'Arial, negrita, 9');
    excel.Alinear('e4', 'e4', 'D');
  end;

  rsql := datosdb.tranSQL(cabauditoria.DatabaseName, 'select nroauditoria, fechafac, codos, idzona, nrodoc from cab_auditoria where fecha >= ' + '"' + utiles.sExprFecha2000(xfdesde) + '"' + ' and fecha <= ' + '"' + utiles.sExprFecha2000(xfhasta) + '"' + ' and anulada <> ' + '''' + 'S' + '''' + ' and anulada <> ' + '''' + 'P' + '''' + ' order by codos, idzona');
  rsql.Open;

  idanter[1] := ''; idanter[2] := ''; iitems := 0; ke := 4; idanter[3] := '';
  totfinal[8] := 0;

  for i := 1 to 10 do totales[i] := 0;
  for i := 1 to cantitems do i1[i] := 0;
  lceldas := TStringList.Create;
  cantpac := TStringList.Create;

  c4 := 4;  //02/11/2008 determinamos de acuerdo a la cantidad de digitos si es o no nbu
  rsql.First;
  if detauditoria.FindKey([rsql.FieldByName('nroauditoria').AsString]) then c4 := length(trim(detauditoria.FieldByName('codigo').AsString));

  facturacion.periodo := Copy(xfdesde, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xfdesde), 1, 4);
  rsql.First;
  while not rsql.Eof do Begin
    if utiles.verificarItemsLista(listObSociales, rsql.FieldByName('codos').AsString) then Begin
      obsocial.getDatos(rsql.FieldByName('codos').AsString);
      if rsql.FieldByName('codos').AsString <> idanter[1] then Begin
        LineaDeterminaciones(iitems, salida); // 14/11/2007 -> Total del 9984
        Listar9984(salida);   // 14/11/2007 -> Total del 9984
        IniciarObraSocial(rsql.FieldByName('codos').AsString, salida);
        obsocial.SincronizarArancel(rsql.FieldByname('codos').AsString, Copy(xfdesde, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xfdesde), 1, 4));
        IniciarZona(rsql.FieldByName('idzona').AsString, salida);
      end else
        if rsql.FieldByName('idzona').AsString <> idanter[2] then Begin
          LineaDeterminaciones(iitems, salida); // 14/11/2007 -> Total del 9984
          Listar9984(salida);   // 14/11/2007 -> Total del 9984
          IniciarZona(rsql.FieldByName('idzona').AsString, salida);
        end;


      auditar := true;
      if (auditonline.VerificarSiEstaPendiente(rsql.FieldByName('nroauditoria').AsString)) then auditar := false;

      if (auditar) then begin
        if detauditoria.FindKey([rsql.FieldByName('nroauditoria').AsString]) then Begin
          while not detauditoria.Eof do Begin
            if (xestado = 'A') then lista := true;
            if (xestado = 'R') then
              if (BuscarCodigoRech(rsql.FieldByName('codos').AsString, detauditoria.FieldByName('codigo').AsString)) then lista := false else lista := true;

            if (lista) then begin
              c4 := length(trim(detauditoria.FieldByName('codigo').AsString));
              if detauditoria.FieldByName('estado').AsString = xestado then Begin
                i := utiles.ObtenerItemsEnLista(cp, detauditoria.FieldByName('codigo').AsString);
                if i = -1 then Begin
                  iitems := iitems + 1;
                  k := iitems;
                end else
                  k := i;

                if k > z then z := k;

                obsocial.SincronizarArancel(rsql.FieldByname('codos').AsString, Copy(xfdesde, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xfdesde), 1, 4));
                //monto_analisis := facturacion.setImporteAnalisis(rsql.FieldByName('codos').AsString, detauditoria.FieldByName('codigo').AsString, Copy(xfdesde, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xfdesde), 1, 4)) + facturacion.setTot9984;
                // 20/10/2007 -> sacamos el 9984
                monto_analisis := facturacion.setImporteAnalisis(rsql.FieldByName('codos').AsString, detauditoria.FieldByName('codigo').AsString, Copy(xfdesde, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xfdesde), 1, 4)); // + facturacion.setTot9984;
                if cantpac.Count = 0 then cantpac.Add(rsql.FieldByname('nrodoc').AsString) else
                  if not utiles.verificarItemsLista(cantpac, rsql.FieldByname('nrodoc').AsString) then cantpac.Add(rsql.FieldByname('nrodoc').AsString);

                cp[k] := detauditoria.FieldByName('codigo').AsString;
                ca[k] := ca[k] + 1;
                im[k] := im[k] + monto_analisis;
                m9984 := facturacion.setTot9984;
                i1[k] := i1[k] + (monto_analisis + m9984); // 20/10/2007 -> Para el total final se incluye el 9984
                ct[k] := ct[k] + m9984; //facturacion.setTot9984;
                //mf[k] := obsocial.MontoFijo;
                mf[k] := facturacion.DetMontoFijo;   // 19/08/07

                nomeclatura.getDatos(detauditoria.FieldByName('codigo').AsString);
                if Length(Trim(nomeclatura.cftoma)) > 0 then Begin
                  cant9984   := cant9984 + 1;
                  tot9984    := tot9984  + m9984;
                  cod9984    := nomeclatura.cftoma;
                  totales[1] := totales[1] + 1;
                end;
                totales[1] := totales[1] + 1;   // 27/10/2007 -> Acumulamos todas las pr�cticas + los 9984

                if rsql.FieldByName('nroauditoria').AsString <> idanter[3] then totfinal[8] := totfinal[8] + 1;
                idanter[3] := rsql.FieldByName('nroauditoria').AsString;

                if not inf_envio then Begin
                  totales[3] := totales[3] + 1;
                  totales[5] := totales[5] + 1;

                  totales[2] := totales[2] + monto_analisis;
                  totales[4] := totales[4] + monto_analisis;
                  totales[6] := totales[6] + monto_analisis;
                end;
              end;
            end;

            detauditoria.Next;
            if detauditoria.FieldByName('nroauditoria').AsString <> rsql.FieldByName('nroauditoria').AsString then Break;
          end;
        end;
      end;
    end;

    rsql.Next;
  end;

  rsql.Close; rsql.Free;

  auditonline.desconectar;

  //en noviembre, cargar 1 orden de cada caso y analizar
  LineaDeterminaciones(iitems, salida);
  Listar9984(salida);

  if totales[1] <> 0 then TotalZona(salida);
  if (totales[3] <> 0) or (totgrales[1] <> 0) then TotalObraSocial(salida);

  if inf_envio then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'N');
      list.derecha(96, list.Lineactual, '', '------------------------------------------------------------------------------------------------------------------------------------------', 2, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'TOTAL GENERAL:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(65, list.Lineactual, '', totfinal[5], 2, 'Arial, negrita, 9');
      list.importe(75, list.Lineactual, '', totfinal[6], 3, 'Arial, negrita, 9');
      list.importe(95, list.Lineactual, '', totfinal[7], 4, 'Arial, negrita, 9');
      list.Linea(96, list.Lineactual, '', 9, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, 'Cantidad de Pacientes Atendidos:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(40, list.Lineactual, '#####', StrToFloat(IntToStr(cantpac.Count)), 2, 'Arial, negrita, 9');
      list.Linea(45, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, 'Cantidad de Ordenes:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(40, list.Lineactual, '#####', totfinal[8], 2, 'Arial, negrita, 9');
      list.Linea(45, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');

      list.Linea(0, 0, '', 1, 'Arial, normal, 20', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 20', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 20', salida, 'S');

      list.Linea(0, 0, '-----------------------------------------------', 1, 'Arial, normal, 10', salida, 'N');
      list.Linea(70, list.Lineactual, '-----------------------------------------------', 2, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '             Firma y Sello', 1, 'Arial, normal, 10', salida, 'N');
      list.Linea(72, list.Lineactual, '         Firma y Sello', 2, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '          Representante Legal', 1, 'Arial, normal, 10', salida, 'N');
      list.Linea(72, list.Lineactual, '     Representante Legal', 2, 'Arial, normal, 10', salida, 'S');

      list.Linea(0, 0, '', 1, 'Arial, normal, 40', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 40', salida, 'S');

      list.Linea(0, 0, 'Observaciones:........................................................................................................................................................', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '..............................................................................................................................................................................', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '..............................................................................................................................................................................', 1, 'Arial, normal, 10', salida, 'S');
    end;
    totfinal[1] := 0; totfinal[2] := 0; totfinal[3] := 0; totfinal[4] := 0; totfinal[5] := 0; totfinal[6] := 0; totfinal[7] := 0; totfinal[8] := 0;
  end;
  if not inf_envio then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, 'TOTAL GENERAL:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(75, list.Lineactual, '####', totales[5], 2, 'Arial, negrita, 9');
      list.importe(95, list.Lineactual, '', totales[6], 3, 'Arial, negrita, 9');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
    end else Begin
      Inc(ke); me := IntToStr(ke);
      excel.setString('b' + me, 'b' + me, 'TOTAL GENERAL:', 'Arial, negrita, 11');
      excel.setFormula('c' + me, 'c' + me, '=c' + IntToStr(ke - 1), 'Arial, negrita, 11');
      excel.setFormula('d' + me, 'd' + me, '=d' + IntToStr(ke - 1), 'Arial, negrita, 11');
    end;
  end;

  if salida <> 'X' then list.FinList else Begin
    excel.setString('a3', 'a3', '');
    excel.Visulizar;
  end;
  cantpac.Clear;
end;

procedure TTAuditoriaCCB.ListarTotalesDiariosOS(xfdesde, xfhasta: String; salida, tipoList: char);
// Objetivo...: Listar Obras Sociales, totales diarios
const
  dist = 11;
  items = 20;
var
  r: TQuery;
  i, j, cantos, it: Integer;
  t, x: Real;
  lo: array[1..items] of String;
  im: array[1..31, 1..items] of Real;
Begin
  r := obsocial.setObrasSocialesCapitadas;
  r.Open;
  list.Setear(salida);
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, Entidad, 1, 'Arial, normal, 12');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  list.Titulo(0, 0, 'Montos Auditados Obras Sociales - Per�odo: ' + xfdesde + ' - ' + xfhasta, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  list.Titulo(0, 0, 'D�a', 1, 'Arial, Cursiva, 8');
  i := 0;
  while not r.Eof do Begin
    getTopes(r.FieldByName('codos').AsString);
    if tope > 0 then Begin
      Inc(i);
      list.Titulo(dist * i, list.Lineactual, Copy(r.FieldByName('nombre').AsString, 1, 8), i+1, 'Arial, Cursiva, 8');
      lo[i] := r.FieldByName('codos').AsString;
    end;
    r.Next;
  end;
  cantos := i;
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');

  list.Linea(0, 0, 'Tope:', 1, 'Arial, normal, 8', salida, 'S');

  r.First; i := 0;
  while not r.Eof do Begin
    getTopes(r.FieldByName('codos').AsString);
    if tope > 0 then Begin
      Inc(i);
      list.importe((dist * i) + 8, list.Lineactual, '', tope, i+1, 'Arial, normal, 8');
    end;
    r.Next;
  end;
  r.Close; r.Free;

  for i := 1 to StrToInt(Copy(xfhasta, 1, 2)) do
      for j := 1 to items + 1 do im[i, j] := 0;

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');

  cabauditoria.IndexFieldNames := 'Fecha';
  datosdb.Filtrar(cabauditoria, 'fecha >= ' + utiles.sExprFecha(xfdesde) + ' and fecha <= ' + utiles.sExprFecha(xfhasta));
  cabauditoria.First;
  while not cabauditoria.Eof do Begin
    if detauditoria.FindKey([cabauditoria.FieldByName('nroauditoria').AsString]) then Begin
      while not detauditoria.Eof do Begin
        if cabauditoria.FieldByName('nroauditoria').AsString <> detauditoria.FieldByName('nroauditoria').AsString then Break;
        if detauditoria.FieldByName('estado').AsString = 'A' then Begin
          it := utiles.ObtenerItemsEnLista(lo, cabauditoria.FieldByName('codos').AsString);
          if it > 0 then im[StrToInt(Copy(cabauditoria.FieldByName('fecha').AsString, 7, 2)), it] := im[StrToInt(Copy(cabauditoria.FieldByName('fecha').AsString, 7, 2)), it] + detauditoria.FieldByName('monto').AsFloat;
        end;
        detauditoria.Next;
      end;
    end;
    cabauditoria.Next;
  end;

  if tipoList = '1' then Begin    // Listado Acumulado de Montos Diarios
    t := 0;   // Acumulaci�n
    for j := 1 to cantos do Begin
      for i := 1 to StrToInt(Copy(xfhasta, 1, 2)) do Begin
        t := t + im[i, j];
        im[i, j] := t;
      end;
      t := 0;
    end;

    t := 0;   // Ponemos en 0 los montos que se repiten
    for j := 1 to cantos do Begin
      for i := 1 to StrToInt(Copy(xfhasta, 1, 2)) do Begin
        if t = im[i, j] then im[i, j] := 0 else t := im[i, j];
      end;
      t := 0;
    end;                  

    for i := 1 to StrToInt(Copy(xfhasta, 1, 2)) do Begin
      for j := 1 to cantos + 1 do Begin
        if j = 1 then list.Linea(0, 0, utiles.sLlenarIzquierda(inttostr(i), 2, '0'), 1, 'Arial, normal, 8', salida, 'N') else
          if im[i, j-1] > 0 then list.importe((dist * j) - 2, list.Lineactual, '', im[i, j-1], j, 'Arial, normal, 8') else list.derecha((dist * j) - 4, list.Lineactual, '####', '-', j, 'Arial, normal, 8');
      end;
      list.Linea(99, list.Lineactual, '', j+1, 'Arial, normal, 8', salida, 'S');
    end;
  end;

  if tipoList = '2' then Begin    // Listado de Montos Diarios
    for i := 1 to StrToInt(Copy(xfhasta, 1, 2)) do Begin
      for j := 1 to cantos + 1 do Begin
        if j = 1 then list.Linea(0, 0, utiles.sLlenarIzquierda(inttostr(i), 2, '0'), 1, 'Arial, normal, 8', salida, 'N') else
          if im[i, j-1] > 0 then list.importe((dist * j) - 2, list.Lineactual, '', im[i, j-1], j, 'Arial, normal, 8') else list.importe((dist * j), list.Lineactual, '#####', im[i, j-1], j, 'Arial, normal, 8');
      end;
      list.Linea(99, list.Lineactual, '', j+1, 'Arial, normal, 8', salida, 'S');
    end;
  end;

  datosdb.QuitarFiltro(cabauditoria);
  cabauditoria.IndexFieldNames := 'Nroauditoria';

  list.FinList;
end;

procedure TTAuditoriaCCB.ListarHistoriaClinica(xcodos, xnrodoc: String; salida: char);
// Objetivo...: Listar Historial del Paciente
var
  r: TStringList;
  z: TObjectList;
  objeto: TTAuditoriaCCB;
  idanter: String;
  i, j, k, m, n, o: Integer;
Begin
  obsocial.getDatos(xcodos);
  padron.getDatos(xcodos, xnrodoc);
  list.Setear(salida);
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, Entidad, 1, 'Arial, normal, 12');
  list.Titulo(0, 0, 'Historia Cl�nica', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'Obra Social: ' + obsocial.Nombre, 1, 'Arial, negrita, 12');
  list.Titulo(0, 0, 'Paciente: ' + padron.Nombre, 1, 'Arial, negrita, 12');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');

  r := setHistorial(xcodos, xnrodoc, True);
  lh := 0; idanter := '';
  for j := 0 to r.Count - 1 do Begin
    if Copy(r.Strings[j], 1, 10) <> idanter then Begin
      if Length(Trim(idanter)) > 0 then LineaHist(salida);;
      m := pos(';1', r.Strings[j]);
      n := pos(';2', r.Strings[j]);
      o := pos(';3', r.Strings[j]);
      diagnostico.getDatos(Copy(r.Strings[j], o+2, 4));
      historiac[1] := utiles.sFormatoFecha(Copy(r.Strings[j], 11, 8));
      historiac[2] := diagnostico.Descrip + '(' + Copy(r.Strings[j], 33, m - 33) + ')';
      medico.getDatos(Copy(r.Strings[j], 19, 4));
      historiac[3] := medico.Nombre;
      historiac[6] := '  Orden: ' + Copy(r.Strings[j], 24, 10);
      historiac[7] := Copy(r.Strings[j], m+2, n-(m+2));
      historiac[4] := '';  historiac[5] := '';
      historiac[9] := 'M�d. Cabecera: ' + medcab.setMedicoCabecera(xcodos, Copy(r.Strings[j], o+6, 4));
      idanter      := Copy(r.Strings[j], 1, 10);
      fecha_hist   := Copy(r.Strings[j], 11, 8);
    end;
    z := auditoriacb.setItemsHistorial(Copy(r.Strings[j], 1, 10), True);
    for k := 1 to z.Count do begin
      objeto := TTAuditoriaCCB(z.Items[k-1]);
      if objeto.Estado = 'A' then historiac[4] := historiac[4] + objeto.Codigo + '  ';
      if objeto.Estado = 'R' then historiac[5] := historiac[5] + objeto.Codigo + '  ';
    end;
    z.Free; z := Nil;
  end;

  if Length(Trim(idanter)) > 0 then Begin
    LineaHist(salida);
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  end;

  if r.Count = 0 then list.Linea(0, 0, 'No hay Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');
  r.Free;

  list.FinList;
end;

procedure TTAuditoriaCCB.LineaHist(salida: char);
// Objetivo...: Cargar Linea Historial
Begin
  if lh > 0 then Begin
    Inc(lh);
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  end;
  list.Linea(0, 0, 'Fecha: ' + historiac[1] + historiac[6] + '  Diagn�sitico: ' + historiac[2], 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, 'M�dico: ' + historiac[3], 1, 'Arial, normal, 10', salida, 'N');
  list.Linea(50, list.Lineactual, historiac[9], 2, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'C�d. Autorizados: ' + historiac[4], 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'C�d. Rechazados : ' + historiac[5], 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  if Length(Trim(historiac[7])) > 0 then Begin
    list.Linea(0, 0, 'Observaci�n: ' + historiac[7], 1, 'Arial, normal, 10', salida, 'S');
  end;
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  historiac[7] := '';
end;

procedure TTAuditoriaCCB.ListarEstadisticaMedicos(xlista: TStringList; xdesde, xhasta: String; salida: char);
// Objetivo...: Generar lista acompa�antes
Begin
  list.Setear(salida);
  if salida <> 'X' then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Prestador: ' + Entidad, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Per�odo: ' + xdesde + ' - ' + xhasta, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Estad�stica por Medico', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'M�dico', 1, 'Arial, Cursiva, 8');
    list.Titulo(55, list.Lineactual, 'Cant. An�lisis', 2, 'Arial, Normal, 8');
    list.Titulo(71, list.Lineactual, 'Aceptadas', 3, 'Arial, Normal, 8');
    list.Titulo(81, list.Lineactual, 'Rechazadas', 4, 'Arial, Normal, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, '', 1, 'Arial, Cursiva, 5');
  end else Begin
    excel.setString('a1', 'a1', Entidad, 'Arial, normal, 12');
    excel.setString('a2', 'a2', 'Estad�stica por M�dico' + ', Per�odo: ' + xdesde + ' - ' + xhasta, 'Arial, negrita, 12');
    excel.setString('a4', 'a4', 'M�dico', 'Arial, negrita, 9');
    excel.FijarAnchoColumna('a4', 'a4', 50);
    excel.setString('b4', 'b4', 'Cantidad', 'Arial, negrita, 9');
    excel.Alinear('b4', 'b4', 'D');
    excel.setString('c4', 'c4', 'Aceptadas', 'Arial, negrita, 9');
    excel.Alinear('c4', 'c4', 'D');
    excel.setString('d4', 'd4', 'Rechazadas', 'Arial, negrita, 9');
    excel.Alinear('d4', 'd4', 'D');
  end;

  cabauditoria.IndexFieldNames := 'Idprof;Nroauditoria';
  datosdb.Filtrar(cabauditoria, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and anulada <> ' + '''' + 'S' + '''' + ' and anulada <> ' + '''' + 'P' + '''');
  totales[1] := 0; totales[2] := 0; totales[3] := 0; ke := 4;
  cabauditoria.First;
  while not cabauditoria.Eof do Begin
    if cabauditoria.FieldByName('idprof').AsString <> idanter[1] then Begin
      RupturaMedico(idanter[1], salida);
      idanter[1] := cabauditoria.FieldByName('idprof').AsString;
    end;
    totales[1] := totales[1] + 1;   // Cantidad de Pedidos

    if datosdb.Buscar(detauditoria, 'nroauditoria', 'items', cabauditoria.FieldByName('nroauditoria').AsString, '001') then Begin
      while not detauditoria.Eof do Begin
        if detauditoria.FieldByName('nroauditoria').AsString <> cabauditoria.FieldByName('nroauditoria').AsString then Break;
        if detauditoria.FieldByName('estado').AsString = 'A' then totales[2] := totales[2] + 1 else totales[3] := totales[3] + 1;
        detauditoria.Next;
      end;
    end;
    cabauditoria.Next;
  end;
  RupturaMedico(idanter[1], salida);
  datosdb.QuitarFiltro(cabauditoria);
  cabauditoria.IndexFieldNames := 'Nroauditoria';

  if salida <> 'X' then list.FinList else Begin
    excel.setString('a3', 'a3', '', 'Arial, negrita, 9');
    excel.Visulizar;
  end;
end;

procedure  TTAuditoriaCCB.RupturaMedico(xidprof: String; salida: char);
// Objetivo...: Ruptura por M�dico
Begin
  if (totales[1] > 0) and (medico.Buscar(xidprof))  then Begin
    medico.getDatos(xidprof);
    if salida <> 'X' then Begin
      list.Linea(0, 0, medico.Nombre, 1, 'Arial, normal, 8', salida, 'N');
      list.importe(65, list.Lineactual, '#####', totales[1], 2, 'Arial, normal, 8');
      list.importe(79, list.Lineactual, '######0', totales[2], 3, 'Arial, normal, 8');
      list.importe(90, list.Lineactual, '######0', totales[3], 4, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
    end else Begin
      Inc(ke); me := IntToStr(ke);
      excel.setString('a' + me, 'a' + me, medico.Nombre, 'Arial, normal, 9');
      excel.setInteger('b' + me, 'b' + me, StrToInt(FloatToStr(totales[1])), 'Arial, normal, 9');
      excel.setReal('c' + me, 'c' + me, StrToInt(FloatToStr(totales[2])), 'Arial, normal, 9');
      excel.setReal('d' + me, 'd' + me, StrToInt(FloatToStr(totales[3])), 'Arial, normal, 9');
    end;
  end;
  totales[1] := 0; totales[2] := 0; totales[3] := 0;
end;

//------------------------------------------------------------------------------

procedure TTAuditoriaCCB.ListarEstadisticaMedicosCabecera(xlista: TStringList; xcodos, xdesde, xhasta: String; salida: char);
// Objetivo...: Estadistica por M�dicos de Cabecera
Begin
  list.Setear(salida);
  obsocial.getDatos(xcodos);
  if salida <> 'X' then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Prestador: ' + Entidad, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Per�odo: ' + xdesde + ' - ' + xhasta, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Estad�stica por Medico de Cabecera', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'M�dico', 1, 'Arial, Cursiva, 8');
    list.Titulo(29, list.Lineactual, 'Cant. Solicitudes', 2, 'Arial, Normal, 8');
    list.Titulo(45, list.Lineactual, 'C�pitas', 3, 'Arial, Normal, 8');
    list.Titulo(54, list.Lineactual, 'Porcentaje', 4, 'Arial, Normal, 8');
    list.Titulo(70, list.Lineactual, 'Aceptadas', 5, 'Arial, Normal, 8');
    list.Titulo(79, list.Lineactual, 'Rechazadas', 6, 'Arial, Normal, 8');
    list.Titulo(90, list.Lineactual, 'Promedio', 7, 'Arial, Normal, 8');
    list.Titulo(0, 0, '', 1, 'Arial, Cursiva, 5');
    list.Titulo(0, 0, 'Obra Social: ' + obsocial.Nombre, 1, 'Arial, negrita, 9');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, '', 1, 'Arial, Cursiva, 5');
  end else Begin
    excel.setString('a1', 'a1', Entidad, 'Arial, normal, 12');
    excel.setString('a2', 'a2', 'Estad�stica por M�dico de Cabecera' + ', Per�odo: ' + xdesde + ' - ' + xhasta, 'Arial, negrita, 12');
    excel.setString('a4', 'a4', 'M�dico', 'Arial, negrita, 9');
    excel.FijarAnchoColumna('a4', 'a4', 50);
    excel.setString('b4', 'b4', 'Cantidad', 'Arial, negrita, 9');
    excel.Alinear('b4', 'b4', 'D');
    excel.setString('c4', 'c4', 'C�pitas', 'Arial, negrita, 9');
    excel.Alinear('c4', 'c4', 'D');
    excel.setString('d4', 'd4', 'Porcentaje', 'Arial, negrita, 9');
    excel.Alinear('d4', 'd4', 'D');
    excel.setString('e4', 'e4', 'Aceptadas', 'Arial, negrita, 9');
    excel.Alinear('e4', 'e4', 'D');
    excel.setString('f4', 'f4', 'Rechazadas', 'Arial, negrita, 9');
    excel.Alinear('f4', 'f4', 'D');
    excel.setString('g4', 'g4', 'Promedio', 'Arial, negrita, 9');
    excel.Alinear('g4', 'g4', 'D');
    excel.setString('a5', 'a5', 'Obra Social: ' + obsocial.Nombre, 'Arial, negrita, 10');
  end;

  cabauditoria.IndexFieldNames := 'Profcab;Nroauditoria';
  datosdb.Filtrar(cabauditoria, 'codos = ' + '''' + xcodos + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and anulada <> ' + '''' + 'S' + '''' + ' and anulada <> ' + '''' + 'P' + '''');
  IniciarArreglos;
  ke := 5;
  cabauditoria.First;
  while not cabauditoria.Eof do Begin
    //if (utiles.verificarItemsLista(xlista, cabauditoria.FieldByName('profcab').AsString)) then begin
      if cabauditoria.FieldByName('profcab').AsString <> idanter[1] then Begin
        RupturaMedicoCabecera(xcodos, idanter[1], xdesde, salida);
        idanter[1] := cabauditoria.FieldByName('profcab').AsString;
      end;
      totales[1] := totales[1] + 1;   // Cantidad de Pedidos

      if datosdb.Buscar(detauditoria, 'nroauditoria', 'items', cabauditoria.FieldByName('nroauditoria').AsString, '001') then Begin
        while not detauditoria.Eof do Begin
          if detauditoria.FieldByName('nroauditoria').AsString <> cabauditoria.FieldByName('nroauditoria').AsString then Break;
          if detauditoria.FieldByName('estado').AsString = 'A' then totales[2] := totales[2] + 1 else totales[3] := totales[3] + 1;
          detauditoria.Next;
        end;
      end;
    //end;
    cabauditoria.Next;
  end;
  RupturaMedicoCabecera(xcodos, idanter[1], xdesde, salida);
  datosdb.QuitarFiltro(cabauditoria);
  cabauditoria.IndexFieldNames := 'Nroauditoria';

  if (totales[4] + totales[5] > 0) then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, 'Subtotales:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(40, list.Lineactual, '#####', totales[4], 2, 'Arial, negrita, 8');
      list.importe(50, list.Lineactual, '#####', 0, 3, 'Arial, negrita, 8');
      list.importe(62, list.Lineactual, '#####', 0, 4, 'Arial, negrita, 8');
      list.importe(78, list.Lineactual, '######0', totales[5], 5, 'Arial, negrita, 8');
      list.importe(88, list.Lineactual, '######0', totales[6], 6, 'Arial, negrita, 8');
      list.Linea(95, list.Lineactual, '', 7, 'Arial, negrita, 8', salida, 'S');
    end else Begin
      Inc(ke); me := IntToStr(ke);
      excel.setString('a' + me, 'a' + me, 'Subtotales:', 'Arial, negrita, 9');
      excel.setInteger('b' + me, 'b' + me, StrToInt(FloatToStr(totales[4])), 'Arial, negrita, 9');
      excel.setInteger('c' + me, 'c' + me, StrToInt(FloatToStr(0)), 'Arial, negrita, 9');
      excel.setReal('d' + me, 'd' + me, 0, 'Arial, negrita, 9');
      excel.setReal('e' + me, 'e' + me, StrToInt(FloatToStr(totales[5])), 'Arial, negrita, 9');
      excel.setReal('f' + me, 'f' + me, StrToInt(FloatToStr(totales[6])), 'Arial, negrita, 9');
    end;
  end else
    list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');

  if salida <> 'X' then list.FinList else Begin
    excel.setString('a3', 'a3', '', 'Arial, negrita, 9');
    excel.Visulizar;
  end;
end;

procedure  TTAuditoriaCCB.RupturaMedicoCabecera(xcodos, xidprof, xperiodo: String; salida: char);
// Objetivo...: Ruptura por M�dico
var
 cc, por: Real;
 id, nom: string;
Begin
  if (totales[1] > 0) and ((medico.Buscar(xidprof)) or (medicoos.Buscar(xcodos, xidprof)))  then Begin
    if (medico.Buscar(xidprof)) then begin
      medico.getDatos(xidprof);
      id  := medico.Idprof;
      nom := medico.Nombre;
    end else begin
      medicoos.getDatos(xcodos, xidprof);
      id  := medicoos.Idprof;
      nom := medicoos.Nombre;
    end;

    cc := StrToFloat(medcab.setCantidadCapitas(xcodos, xidprof, utiles.setPeriodoAPartirDeUnaFecha(xperiodo) ));
    if cc = 0 then por := 0 else por := (totales[1] * 100) / cc;
    if salida <> 'X' then Begin
      list.Linea(0, 0, id + ' ' +  nom, 1, 'Arial, normal, 8', salida, 'N');
      list.importe(40, list.Lineactual, '#####', totales[1], 2, 'Arial, normal, 8');
      list.importe(50, list.Lineactual, '#####', cc, 3, 'Arial, normal, 8');
      list.importe(62, list.Lineactual, '#####', por, 4, 'Arial, normal, 8');
      list.importe(78, list.Lineactual, '######0', totales[2], 5, 'Arial, normal, 8');
      list.importe(88, list.Lineactual, '######0', totales[3], 6, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', ( (totales[2] + totales[3]) / totales[1]), 7, 'Arial, negrita, 8');
      list.Linea(95, list.Lineactual, '', 8, 'Arial, normal, 8', salida, 'S');
    end else Begin
      Inc(ke); me := IntToStr(ke);
      excel.setString('a' + me, 'a' + me, medico.Nombre, 'Arial, normal, 9');
      excel.setInteger('b' + me, 'b' + me, StrToInt(FloatToStr(totales[1])), 'Arial, normal, 9');
      excel.setInteger('c' + me, 'c' + me, StrToInt(FloatToStr(cc)), 'Arial, normal, 9');
      excel.setReal('d' + me, 'd' + me, por, 'Arial, normal, 9');
      excel.setReal('e' + me, 'e' + me, StrToInt(FloatToStr(totales[2])), 'Arial, normal, 9');
      excel.setReal('f' + me, 'f' + me, StrToInt(FloatToStr(totales[3])), 'Arial, normal, 9');
      excel.setReal('g' + me, 'g' + me, ( (totales[2] + totales[3]) / totales[1]), 'Arial, normal, 9');
    end;
    totales[4] := totales[4] + totales[1];
    totales[5] := totales[5] + totales[2];
    totales[6] := totales[6] + totales[3];
  end;
  totales[1] := 0; totales[2] := 0; totales[3] := 0;
end;

// -----------------------------------------------------------------------------

procedure TTAuditoriaCCB.ListarEstadisticaDiagnostico(xcodos, xdesde, xhasta: String; salida: char);
// Objetivo...: Estadistica por M�dicos de Cabecera
Begin
  list.Setear(salida);
  obsocial.getDatos(xcodos);
  if salida <> 'X' then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Prestador: ' + Entidad, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Per�odo: ' + xdesde + ' - ' + xhasta, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Estad�stica por Diagn�stico', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'M�dico', 1, 'Arial, Cursiva, 8');
    list.Titulo(54, list.Lineactual, 'Cant. Solicitudes', 2, 'Arial, Normal, 8');
    list.Titulo(71, list.Lineactual, 'Aceptadas', 3, 'Arial, Normal, 8');
    list.Titulo(81, list.Lineactual, 'Rechazadas', 4, 'Arial, Normal, 8');
    list.Titulo(0, 0, '', 1, 'Arial, Cursiva, 5');
    list.Titulo(0, 0, 'Obra Social: ' + obsocial.Nombre, 1, 'Arial, normal, 9');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, '', 1, 'Arial, Cursiva, 5');
  end else Begin
    excel.setString('a1', 'a1', Entidad, 'Arial, normal, 12');
    excel.setString('a2', 'a2', 'Estad�stica por Diagn�stico' + ', Per�odo: ' + xdesde + ' - ' + xhasta, 'Arial, negrita, 12');
    excel.setString('a4', 'a4', 'M�dico', 'Arial, negrita, 9');
    excel.FijarAnchoColumna('a4', 'a4', 50);
    excel.setString('b4', 'b4', 'Cantidad', 'Arial, negrita, 9');
    excel.Alinear('b4', 'b4', 'D');
    excel.setString('c4', 'c4', 'Aceptadas', 'Arial, negrita, 9');
    excel.Alinear('c4', 'c4', 'D');
    excel.setString('d4', 'd4', 'Rechazadas', 'Arial, negrita, 9');
    excel.Alinear('d4', 'd4', 'D');
    excel.setString('a5', 'a5', 'Obra Social: ' + obsocial.Nombre, 'Arial, negrita, 10');
  end;

  cabauditoria.IndexFieldNames := 'Iddiag;Nroauditoria';
  datosdb.Filtrar(cabauditoria, 'codos = ' + '''' + xcodos + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and anulada <> ' + '''' + 'S' + '''' + ' and anulada <> ' + '''' + 'P' + '''');
  IniciarArreglos;
  ke := 5;
  cabauditoria.First;
  while not cabauditoria.Eof do Begin
    if cabauditoria.FieldByName('iddiag').AsString <> idanter[1] then Begin
      RupturaDiagnostico(idanter[1], salida);
      idanter[1] := cabauditoria.FieldByName('iddiag').AsString;
    end;
    totales[1] := totales[1] + 1;   // Cantidad de Pedidos

    if datosdb.Buscar(detauditoria, 'nroauditoria', 'items', cabauditoria.FieldByName('nroauditoria').AsString, '001') then Begin
      while not detauditoria.Eof do Begin
        if detauditoria.FieldByName('nroauditoria').AsString <> cabauditoria.FieldByName('nroauditoria').AsString then Break;
        if detauditoria.FieldByName('estado').AsString = 'A' then totales[2] := totales[2] + 1 else totales[3] := totales[3] + 1;
        detauditoria.Next;
      end;
    end;
    cabauditoria.Next;
  end;
  RupturaDiagnostico(idanter[1], salida);
  datosdb.QuitarFiltro(cabauditoria);
  cabauditoria.IndexFieldNames := 'Nroauditoria';

  if (totales[4] > 0) then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, 'Subtotales:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(65, list.Lineactual, '#####', totales[4], 2, 'Arial, negrita, 8');
      list.importe(79, list.Lineactual, '######0', totales[5], 3, 'Arial, negrita, 8');
      list.importe(90, list.Lineactual, '######0', totales[6], 4, 'Arial, negrita, 8');
      list.Linea(95, list.Lineactual, '', 5, 'Arial, negrita, 8', salida, 'S');
    end else Begin
      Inc(ke); me := IntToStr(ke);
      excel.setString('a' + me, 'a' + me, 'Subtotales:', 'Arial, negrita, 9');
      excel.setInteger('b' + me, 'b' + me, StrToInt(FloatToStr(totales[4])), 'Arial, negrita, 9');
      excel.setReal('c' + me, 'c' + me, StrToInt(FloatToStr(totales[5])), 'Arial, negrita, 9');
      excel.setReal('d' + me, 'd' + me, StrToInt(FloatToStr(totales[6])), 'Arial, negrita, 9');
    end;
  end;

  if salida <> 'X' then list.FinList else Begin
    excel.setString('a3', 'a3', '', 'Arial, negrita, 9');
    excel.Visulizar;
  end;
end;

procedure  TTAuditoriaCCB.RupturaDiagnostico(xiddiag: String; salida: char);
// Objetivo...: Ruptura por M�dico
Begin
  if (totales[1] > 0) and ( (diagnostico.Buscar(xiddiag)) or (diagnosticooms.BuscarCodRap(xiddiag)) )  then Begin
    if Length(Trim(xiddiag)) < 5 then diagnostico.getDatos(xiddiag) else diagnosticooms.getDatosCodRap(xiddiag);
    if salida <> 'X' then Begin
      if Length(Trim(xiddiag)) < 5 then list.Linea(0, 0, diagnostico.Descrip, 1, 'Arial, normal, 8', salida, 'N') else
        list.Linea(0, 0, diagnosticooms.Descrip, 1, 'Arial, normal, 8', salida, 'N');
      list.importe(65, list.Lineactual, '#####', totales[1], 2, 'Arial, normal, 8');
      list.importe(79, list.Lineactual, '######0', totales[2], 3, 'Arial, normal, 8');
      list.importe(90, list.Lineactual, '######0', totales[3], 4, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
    end else Begin
      Inc(ke); me := IntToStr(ke);
      if Length(Trim(xiddiag)) < 5 then  excel.setString('a' + me, 'a' + me, diagnostico.Descrip, 'Arial, normal, 9') else
        excel.setString('a' + me, 'a' + me, diagnosticooms.Descrip, 'Arial, normal, 9');
      excel.setInteger('b' + me, 'b' + me, StrToInt(FloatToStr(totales[1])), 'Arial, normal, 9');
      excel.setReal('c' + me, 'c' + me, StrToInt(FloatToStr(totales[2])), 'Arial, normal, 9');
      excel.setReal('d' + me, 'd' + me, StrToInt(FloatToStr(totales[3])), 'Arial, normal, 9');
    end;
    totales[4] := totales[4] + totales[1];
    totales[5] := totales[5] + totales[2];
    totales[6] := totales[6] + totales[3];
  end;
  totales[1] := 0; totales[2] := 0; totales[3] := 0;
end;

//------------------------------------------------------------------------------

procedure TTAuditoriaCCB.ListarEstadisticaMedicoDiagnostico(xcodos, xdesde, xhasta: String; salida: char);
// Objetivo...: Estadistica por M�dicos de Cabecera
Begin
  list.Setear(salida);
  obsocial.getDatos(xcodos);
  if salida <> 'X' then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Prestador: ' + Entidad, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Per�odo: ' + xdesde + ' - ' + xhasta, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Estad�stica por M�dico y Diagn�stico', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'M�dico', 1, 'Arial, Cursiva, 8');
    list.Titulo(54, list.Lineactual, 'Cant. Solicitudes', 2, 'Arial, Normal, 8');
    list.Titulo(71, list.Lineactual, 'Aceptadas', 3, 'Arial, Normal, 8');
    list.Titulo(81, list.Lineactual, 'Rechazadas', 4, 'Arial, Normal, 8');
    list.Titulo(0, 0, '', 1, 'Arial, Cursiva, 5');
    list.Titulo(0, 0, 'Obra Social: ' + obsocial.Nombre, 1, 'Arial, normal, 9');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, '', 1, 'Arial, Cursiva, 5');
  end else Begin
    excel.setString('a1', 'a1', Entidad, 'Arial, normal, 12');
    excel.setString('a2', 'a2', 'Estad�stica por M�dico y Diagn�stico' + ', Per�odo: ' + xdesde + ' - ' + xhasta, 'Arial, negrita, 12');
    excel.setString('a4', 'a4', 'M�dico', 'Arial, negrita, 9');
    excel.FijarAnchoColumna('a4', 'a4', 50);
    excel.setString('b4', 'b4', 'Cantidad', 'Arial, negrita, 9');
    excel.Alinear('b4', 'b4', 'D');
    excel.setString('c4', 'c4', 'Aceptadas', 'Arial, negrita, 9');
    excel.Alinear('c4', 'c4', 'D');
    excel.setString('d4', 'd4', 'Rechazadas', 'Arial, negrita, 9');
    excel.Alinear('d4', 'd4', 'D');
    excel.setString('a5', 'a5', 'Obra Social: ' + obsocial.Nombre, 'Arial, negrita, 10');
  end;

  cabauditoria.IndexFieldNames := 'Profcab;Iddiag;Nroauditoria';
  datosdb.Filtrar(cabauditoria, 'codos = ' + '''' + xcodos + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and anulada <> ' + '''' + 'S' + '''' + ' and anulada <> ' + '''' + 'P' + '''');
  IniciarArreglos;
  ke := 5;
  cabauditoria.First;
  while not cabauditoria.Eof do Begin
    if cabauditoria.FieldByName('profcab').AsString <> idanter[2] then Begin
      if totales[1] > 0 then RupturaMedicoDiagnostico(idanter[1], salida);

      if totales[4] > 0 then SubtotalRupturaMedicoDiagnostico(salida);

      medico.getDatos(cabauditoria.FieldByName('profcab').AsString);
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, medico.Nombre, 1, 'Arial, negrita, 9', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end;
      if salida = 'X' then Begin
        Inc(ke); me := IntToStr(ke);
        excel.setString('a' + me, 'a' + me, medico.Nombre, 'Arial, negrita, 10');
      end;
      idanter[1] := cabauditoria.FieldByName('iddiag').AsString;
      idanter[2] := cabauditoria.FieldByName('profcab').AsString;
    end;
    if cabauditoria.FieldByName('iddiag').AsString <> idanter[1] then Begin
      RupturaMedicoDiagnostico(idanter[1], salida);
      idanter[1] := cabauditoria.FieldByName('iddiag').AsString;
    end;
    totales[1] := totales[1] + 1;   // Cantidad de Pedidos

    if datosdb.Buscar(detauditoria, 'nroauditoria', 'items', cabauditoria.FieldByName('nroauditoria').AsString, '001') then Begin
      while not detauditoria.Eof do Begin
        if detauditoria.FieldByName('nroauditoria').AsString <> cabauditoria.FieldByName('nroauditoria').AsString then Break;
        if detauditoria.FieldByName('estado').AsString = 'A' then totales[2] := totales[2] + 1 else totales[3] := totales[3] + 1;
        detauditoria.Next;
      end;
    end;
    cabauditoria.Next;
  end;

  RupturaMedicoDiagnostico(idanter[1], salida);
  SubtotalRupturaMedicoDiagnostico(salida);

  datosdb.QuitarFiltro(cabauditoria);
  cabauditoria.IndexFieldNames := 'Nroauditoria';

  if (totales[7] > 0) then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(65, list.Lineactual, '#####', totales[7], 2, 'Arial, negrita, 9');
      list.importe(79, list.Lineactual, '######0', totales[8], 3, 'Arial, negrita, 9');
      list.importe(90, list.Lineactual, '######0', totales[9], 4, 'Arial, negrita, 9');
      list.Linea(95, list.Lineactual, '', 5, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end else Begin
      Inc(ke); me := IntToStr(ke);
      excel.setString('a' + me, 'a' + me, 'Subtotal:', 'Arial, negrita, 9');
      excel.setInteger('b' + me, 'b' + me, StrToInt(FloatToStr(totales[7])), 'Arial, negrita, 9');
      excel.setReal('c' + me, 'c' + me, StrToInt(FloatToStr(totales[8])), 'Arial, negrita, 9');
      excel.setReal('d' + me, 'd' + me, StrToInt(FloatToStr(totales[9])), 'Arial, negrita, 9');
    end;
  end;

  if salida <> 'X' then list.FinList else Begin
    excel.setString('a3', 'a3', '', 'Arial, negrita, 9');
    excel.Visulizar;
  end;
end;

procedure  TTAuditoriaCCB.RupturaMedicoDiagnostico(xiddiag: String; salida: char);
// Objetivo...: Ruptura por M�dico
Begin
  if (totales[1] > 0) and ( (diagnostico.Buscar(xiddiag)) or (diagnosticooms.BuscarCodRap(xiddiag)) ) then Begin
    if salida <> 'X' then Begin
      if Length(Trim(xiddiag)) < 5 then Begin
        diagnostico.getDatos(xiddiag);
        list.Linea(0, 0, diagnostico.Descrip, 1, 'Arial, normal, 8', salida, 'N');
      end else Begin
        diagnosticooms.getDatosCodRap(xiddiag);
        list.Linea(0, 0, diagnosticooms.Descrip, 1, 'Arial, normal, 8', salida, 'N');
      end;
      list.importe(65, list.Lineactual, '#####', totales[1], 2, 'Arial, normal, 8');
      list.importe(79, list.Lineactual, '######0', totales[2], 3, 'Arial, normal, 8');
      list.importe(90, list.Lineactual, '######0', totales[3], 4, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
    end else Begin
      Inc(ke); me := IntToStr(ke);
      excel.setString('a' + me, 'a' + me, diagnostico.Descrip, 'Arial, normal, 9');
      excel.setInteger('b' + me, 'b' + me, StrToInt(FloatToStr(totales[1])), 'Arial, normal, 9');
      excel.setReal('c' + me, 'c' + me, StrToInt(FloatToStr(totales[2])), 'Arial, normal, 9');
      excel.setReal('d' + me, 'd' + me, StrToInt(FloatToStr(totales[3])), 'Arial, normal, 9');
    end;
    totales[4] := totales[4] + totales[1];
    totales[5] := totales[5] + totales[2];
    totales[6] := totales[6] + totales[3];
  end;
  totales[1] := 0; totales[2] := 0; totales[3] := 0;
end;

procedure  TTAuditoriaCCB.SubtotalRupturaMedicoDiagnostico(salida: char);
// Objetivo...: Ruptura por M�dico
Begin
  if (totales[4] > 0) then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(60, list.Lineactual, '--------------------------------------------------------------------------', 2, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(65, list.Lineactual, '#####', totales[4], 2, 'Arial, negrita, 9');
      list.importe(79, list.Lineactual, '######0', totales[5], 3, 'Arial, negrita, 9');
      list.importe(90, list.Lineactual, '######0', totales[6], 4, 'Arial, negrita, 9');
      list.Linea(95, list.Lineactual, '', 5, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end else Begin
      Inc(ke); me := IntToStr(ke);
      excel.setString('a' + me, 'a' + me, 'Subtotal:', 'Arial, negrita, 9');
      excel.setInteger('b' + me, 'b' + me, StrToInt(FloatToStr(totales[4])), 'Arial, negrita, 9');
      excel.setReal('c' + me, 'c' + me, StrToInt(FloatToStr(totales[5])), 'Arial, negrita, 9');
      excel.setReal('d' + me, 'd' + me, StrToInt(FloatToStr(totales[6])), 'Arial, negrita, 9');
    end;
    totales[7] := totales[7] + totales[4];
    totales[8] := totales[8] + totales[5];
    totales[9] := totales[9] + totales[6];
  end;
  totales[4] := 0; totales[5] := 0; totales[6] := 0;
end;

//------------------------------------------------------------------------------

procedure TTAuditoriaCCB.ListarEstadisticaPaciente(xcodos, xnrodoc, xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Estad�sticas por Paciente
var
  l: TObjectList;
  objeto: TTAuditoriaCCB;
  i, j: Integer;
  a, r: String;
Begin
  list.Setear(salida);
  obsocial.getDatos(xcodos);
  padron.getDatos(xcodos, xnrodoc);
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Prestador: ' + Entidad, 1, 'Arial, normal, 12');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  list.Titulo(0, 0, 'Per�odo: ' + xdesde + ' - ' + xhasta, 1, 'Arial, normal, 12');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  list.Titulo(0, 0, 'Movimientos por Paciente - Lapso: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  list.Titulo(0, 0, 'Fecha/Autor.', 1, 'Arial, Cursiva, 8');
  list.Titulo(20, list.Lineactual, 'M�dico', 2, 'Arial, Normal, 8');
  list.Titulo(62, list.Lineactual, 'Diagn�stico', 3, 'Arial, Normal, 8');
  list.Titulo(0, 0, '', 1, 'Arial, Cursiva, 5');
  list.Titulo(0, 0, 'Obra Social: ' + obsocial.Nombre, 1, 'Arial, normal, 9');
  list.Titulo(50, list.Lineactual, 'Paciente: ' + padron.Nrodoc + '  ' + padron.Nombre, 2, 'Arial, normal, 9');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, Cursiva, 5');

  IniciarArreglos;
  datosdb.Filtrar(cabauditoria, 'codos = ' + '''' + xcodos + '''' + ' and nrodoc = ' + '''' + xnrodoc + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and anulada <> ' + '''' + 'S' + '''' + ' and anulada <> ' + '''' + 'P' + '''');
  cabauditoria.First; j := 0;
  while not cabauditoria.Eof do Begin
    a := ''; r := '';
    medico.getDatos(cabauditoria.FieldByName('idprof').AsString);
    list.Linea(0, 0, utiles.sFormatoFecha(cabauditoria.FieldByName('fecha').AsString) + '  ' + cabauditoria.FieldByName('nroauditoria').AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(20, list.Lineactual, medico.Nombre, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(62, list.Lineactual, cabauditoria.FieldByName('diagnostico').AsString, 3, 'Arial, normal, 8', salida, 'S');

    l := setItemsHistorial(cabauditoria.FieldByName('nroauditoria').AsString, True);
    For i := 1 to l.Count do Begin
      objeto := TTAuditoriaCCB(l.Items[i-1]);
      if objeto.Estado = 'A' then a := a + objeto.Codigo + ' ';
    end;
    For i := 1 to l.Count do Begin
      objeto := TTAuditoriaCCB(l.Items[i-1]);
      if objeto.Estado = 'R' then r := r + objeto.Codigo + ' ';
    end;

    list.Linea(0, 0, 'Aut.: ' + a, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(62, list.Lineactual, 'Rech.: ' + r, 2, 'Arial, normal, 8', salida, 'S');

    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    j := 1;

    cabauditoria.Next;
  end;
  datosdb.QuitarFiltro(cabauditoria);

  if j = 0 then list.Linea(0, 0, 'No hay Datos para Listar !', 1, 'Arial, normal, 10', salida, 'S');

  list.FinList;
end;

procedure TTAuditoriaCCB.ListarCoseguros(xperiodo, xcodos, xperiodoliq: string; salida: char);
var
  a: textfile;
  r: TQuery;
  codosanter, fecha, efector, pac, nroauditoria, nroanter, idprofanter: string;
  coseguro, tc, tg, tos: real;

  procedure TotalOS(salida: char);
  begin
    if (tos > 0) then begin
      if (salida <> 'R') then begin
        list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        list.Linea(0, 0, 'Total Coseguros Obra Social:', 1, 'Arial, negrita, 8', salida, 'N');
        list.importe(95, list.Lineactual, '', tos, 2, 'Arial, negrita, 8');
        list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        tos := 0;
      end;
    end;
  end;

  procedure ListarOS(salida: char);
  begin
    if (codosanter <> '') then begin
      TotalOS(salida);
      list.CompletarPaginaConNumeracion;
    end;
    obsocial.getDatos(r.FieldByName('codos').AsString);
    if (salida <> 'R') then begin
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, 'Obra Social: ' + r.FieldByName('codos').AsString + '  ' + obsocial.Nombre, 1, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    end;
    codosanter := r.FieldByName('codos').AsString;
  end;

  procedure Listar(salida: char);
  begin
    if (coseguro > 0) then begin
      list.Linea(0, 0, fecha + '  ' + nroauditoria, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(20, list.Lineactual, pac, 2, 'Arial, normal, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', coseguro, 3, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
      tc := tc + coseguro;
      coseguro := 0;
    end;
  end;

  procedure Total(salida: char);
  begin
    if (tc > 0) then begin
      if (salida <> 'R') then begin
        list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        list.Linea(0, 0, 'Total Coseguros:', 1, 'Arial, negrita, 8', salida, 'N');
        list.importe(95, list.Lineactual, '', tc, 2, 'Arial, negrita, 8');
        list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end;

      coseguromov.Append;
      coseguromov.FieldByName('periodo').AsString    := xperiodo;
      coseguromov.FieldByName('codos').AsString      := codosanter;
      coseguromov.FieldByName('idprof').AsString     := idprofanter;
      coseguromov.FieldByName('monto').AsFloat       := tc;
      coseguromov.FieldByName('tipomov').AsString    := 'COSE1';
      coseguromov.FieldByName('speriodo').AsString   := copy(xperiodo, 4, 4) + copy(xperiodo, 1, 2);
      coseguromov.FieldByName('periodoliq').AsString := xperiodoliq;
      coseguromov.Post;

      tos := tos + tc;
      tg := tg + tc;
    end;

    tc := 0;
  end;

begin
  if (salida <> 'R') then begin
    list.Setear(salida);
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Listado de Coseguros - Lapso: ' + xperiodo, 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Fecha / Orden', 1, 'Arial, Cursiva, 8');
    list.Titulo(20, list.Lineactual, 'Paciente', 2, 'Arial, Normal, 8');
    list.Titulo(90, list.Lineactual, 'Coseguro', 3, 'Arial, Normal, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, '', 1, 'Arial, Cursiva, 5');
  end;

  coseguromov.open;

  datosdb.tranSQL(coseguromov.DatabaseName, 'delete from ' + coseguromov.TableName + ' where periodo = ' + '''' + xperiodo + '''' + ' and codos = ' + '''' + xcodos + '''');
  datosdb.closeDB(coseguromov); coseguromov.open;
  r := datosdb.tranSQL(cabauditoria.DatabaseName, 'select cab_auditoria.nroauditoria, cab_auditoria.nrodoc, cab_auditoria.nombre, cab_auditoria.codos, cab_auditoria.fecha, cab_ref.efector, det_auditoria.monto, det_auditoria.coseguro from cab_auditoria, det_auditoria, cab_ref ' +
                                                  'where cab_auditoria.nroauditoria = det_auditoria.nroauditoria and cab_auditoria.nroauditoria = cab_ref.nroauditoria and cab_ref.fecha >= ' + '''' + copy(xperiodo, 4, 4) + copy(xperiodo, 1, 2) + '01' + '''' + ' ' + ' and cab_auditoria.codos = ' + '''' + xcodos + '''' +
                                                  'and cab_ref.fecha <= ' + '''' + copy(xperiodo, 4, 4) + copy(xperiodo, 1, 2) + '31' + '''' + ' and det_auditoria.coseguro > 0 order by codos, efector');

  //assignfile(a, 'd:\coseguro.txt');
  //rewrite(a);

  //writeln(a, 'select cab_auditoria.nroauditoria, cab_auditoria.nrodoc, cab_auditoria.nombre, cab_auditoria.codos, cab_auditoria.fecha, cab_ref.efector, det_auditoria.monto, det_auditoria.coseguro from cab_auditoria, det_auditoria, cab_ref ' +
  //                                                'where cab_auditoria.nroauditoria = det_auditoria.nroauditoria and cab_auditoria.nroauditoria = cab_ref.nroauditoria and fecha >= ' + '''' + copy(xperiodo, 4, 4) + copy(xperiodo, 1, 2) + '01' + '''' + ' ' +
  //                                                'and fecha <= ' + '''' + copy(xperiodo, 4, 4) + copy(xperiodo, 1, 2) + '31' + '''' + ' and det_auditoria.coseguro > 0 order by codos, efector');

  //closefile(a);
  r.Open; coseguro := 0; tc := 0; tos := 0;

  while not r.Eof do Begin

    if (r.FieldByName('codos').AsString <> codosanter) then begin
      Listar(salida);
      if (tc > 0) then Total(salida);

      ListarOS(salida);
    end;

    if (r.FieldByName('nroauditoria').AsString <> nroanter) and (coseguro > 0) then begin
      Listar(salida);
    end;


    profesional.getDatos(r.FieldByName('efector').AsString);
    efector := profesional.nombre;

    if (r.FieldByName('efector').AsString <> idprofanter) or (idprofanter = '') then begin
      if (tc > 0) then Total(salida);

      idprofanter := r.FieldByName('efector').AsString;

      if (salida <> 'R') then begin
        profesional.getDatos(idprofanter);
        efector := profesional.nombre;
        list.Linea(0, 0, 'Efector: ' + idprofanter + ' ' + efector, 1, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      end;
      idprofanter := r.FieldByName('efector').AsString;
    end;

    fecha := utiles.sFormatoFecha(r.FieldByName('fecha').AsString);
    nroauditoria := r.FieldByName('nroauditoria').AsString;
    pac := r.FieldByName('nombre').AsString;
    coseguro := coseguro + (r.FieldByName('coseguro').AsFloat -  r.FieldByName('monto').AsFloat);
    nroanter := r.FieldByName('nroauditoria').AsString;

    r.next;
  End;
  r.close; r.free;

  Listar(salida);
  if (tc > 0) then Total(salida);
  if (codosanter <> '') then TotalOS(salida);

  if (salida <> 'R') then begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'TOTAL GENERAL:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', tg, 2, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
  end;

  datosdb.closeDB(coseguromov);

  if (salida <> 'R') then list.FinList else begin
    list.Setear('P');
    list.m := 0;
  end;
end;

procedure TTAuditoriaCCB.ListCoseguros(xperiodoliq: string; salida: char);
var
  r: TQuery;
  codosanter, idprofanter: string;
  total1, total2, total3, total4, total5, porcentaje: real;

  procedure TotalOS(salida: char);
  begin
    if (total1 > 0) then begin
      list.Linea(0, 0, '', 1, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, 'Total Obra Social: ', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(75, list.Lineactual, '', total1, 2, 'Arial, negrita, 9');
      list.importe(95, list.Lineactual, '', total4, 3, 'Arial, negrita, 9');
      list.Linea(95, list.Lineactual, '', 4, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      total1 := 0; total4 := 0;
    end;
  end;

  begin
    list.Setear(salida);
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Listado de Coseguros - Per�odo Liquidaci�n: ' + xperiodoliq, 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Profesional', 1, 'Arial, Cursiva, 8');
    list.Titulo(50, list.Lineactual, 'Per�odo / Porcentaje', 2, 'Arial, Normal, 8');
    list.Titulo(68, list.Lineactual, 'Total', 3, 'Arial, Normal, 8');
    list.Titulo(88, list.Lineactual, 'Coseguro', 4, 'Arial, Normal, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, '', 1, 'Arial, Cursiva, 5');

    r := datosdb.tranSQL('select * from coseguros_montos where periodoliq = ' + '''' + xperiodoliq + '''' + ' order by codos, idprof, speriodo');

    r.Open; total1 := 0; total2 := 0; total3 := 0; total4 := 0;

    while not r.Eof do Begin
      if (r.FieldByName('codos').AsString <> codosanter) then begin
        TotalOS(salida);
        list.Linea(0, 0, '', 1, 'Arial, negrita, 9', salida, 'S');
        obsocial.getDatos(r.FieldByName('codos').AsString);
        list.Linea(0, 0, 'Obra Social: ' + obsocial.codos + ' - ' + obsocial.Nombre , 1, 'Arial, negrita, 9', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      end;

      porcentaje := coseguro.getCoseguro(r.FieldByName('codos').AsString, r.FieldByName('periodo').AsString);
      if (porcentaje > 0) then total3 := (r.FieldByName('monto').AsFloat * porcentaje) / 100 else total3 := 0;

      total1 := total1 + r.FieldByName('monto').AsFloat;
      total2 := total2 + r.FieldByName('monto').AsFloat;
      total4 := total4 + total3;
      total5 := total5 + total3;

      profesional.getDatos(r.FieldByName('idprof').AsString);
      list.Linea(0, 0, profesional.codigo + ' ' + profesional.Nombre, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(50, list.lineactual, r.FieldByName('periodo').AsString + ' (' + floattostr(porcentaje) + ' %)', 2, 'Arial, normal, 8', salida, 'N');
      list.importe(75, list.Lineactual, '', r.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', total3, 4, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');

      codosanter := r.FieldByName('codos').AsString;

      r.next;
    End;
    r.close; r.free;

    if (total2 > 0) then begin
      TotalOS(salida);
      //list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, 'Total General: ', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(75, list.Lineactual, '', total2, 2, 'Arial, negrita, 9');
      list.importe(95, list.Lineactual, '', total5, 3, 'Arial, negrita, 9');
      list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
    end;

    list.FinList;

end;

function  TTAuditoriaCCB.getCoseguros(xcodos, xidprof, xperiodo: string): TQuery;
begin
  result := datosdb.tranSQL(coseguromov.DatabaseName, 'select * from ' + coseguromov.TableName + ' where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''' + ' and codos = ' + '''' + xcodos + '''' + ' order by codos');
end;

{===============================================================================}

function  TTAuditoriaCCB.BuscarTopes(xcodos: String): Boolean;
Begin
  Result := topes.FindKey([xcodos]);
end;

procedure TTAuditoriaCCB.EstablecerTope(xcodos: String; xtope: Real);
Begin
  if BuscarTopes(xcodos) then topes.Edit else topes.Append;
  topes.FieldByName('codos').AsString := xcodos;
  topes.FieldByName('tope').AsFloat   := xtope;
  try
    topes.Post
   except
    topes.Cancel
  end;
  datosdb.refrescar(topes);
end;

procedure TTAuditoriaCCB.getTopes(xcodos: String);
Begin
  if BuscarTopes(xcodos) then Tope := topes.FieldByName('tope').AsFloat else Tope := 0;
end;

procedure TTAuditoriaCCB. BorrarTopes(xcodos: String);
Begin
  if BuscarTopes(xcodos) then topes.Delete;
  datosdb.refrescar(topes);
end;

function TTAuditoriaCCB.Logs(xfecha: String): String;
Begin
  if FileExists(dbs.DirSistema + '\auditoria\log\log_' + utiles.sExprFecha2000(xfecha) + '.txt') then Result := dbs.DirSistema + '\auditoria\log\log_' + utiles.sExprFecha2000(xfecha) + '.txt' else Result := '';
end;

procedure TTAuditoriaCCB.AjustarFecha(xdesdeNro, xhastaNro, xFecha: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if Buscar(xdesdeNro) then Begin
    while not cabauditoria.Eof do Begin
      if cabauditoria.FieldByName('nroauditoria').AsString > xhastaNro then Break;
      cabauditoria.Edit;
      cabauditoria.FieldByName('fecha').AsString := utiles.sExprFecha2000(xfecha);
      try
        cabauditoria.Post
       except
        cabauditoria.Cancel
      end;
      cabauditoria.Next;
    end;
    datosdb.closeDB(cabauditoria); cabauditoria.Open;
  end;
end;

function  TTAuditoriaCCB.BuscarDetRechazada(xcodos, xcodanalisis: String): Boolean;
// Objetivo...: Buscar determinacion rechazada
begin
  Result := datosdb.Buscar(detrec, 'codos', 'codanalisis', xcodos, xcodanalisis);
end;

procedure TTAuditoriaCCB.RegistrarDetRechazada(xcodos, xcodanalisis: String);
// Objetivo...: Registrar determinacion rechazada
begin
  if BuscarDetRechazada(xcodos, xcodanalisis) then detrec.Edit else detrec.Append;
  detrec.FieldByName('codos').AsString       := xcodos;
  detrec.FieldByName('codanalisis').AsString := xcodanalisis;
  try
    detrec.Post
   except
    detrec.Cancel
  end;
  datosdb.refrescar(detrec);
end;

procedure TTAuditoriaCCB.BorrarDetRechazada(xcodos, xcodanalisis: String);
// Objetivo...: Borrar Determinacion
begin
  if BuscarDetRechazada(xcodos, xcodanalisis) then detrec.Delete;
end;

function  TTAuditoriaCCB.setDetRechazadas(xcodos: String): TObjectList;
// Objetivo...: Recuperar determinaciones rechazadas
var
  l: TObjectList;
  objeto: TTAuditoriaCCB;
begin
  datosdb.Filtrar(detrec, 'codos = ' + '''' + xcodos + '''');
  l := TObjectList.Create;
  while not detrec.Eof do Begin
    objeto := TTAuditoriaCCB.Create;
    objeto.Codos  := detrec.FieldByName('codos').AsString;
    objeto.Codigo := detrec.FieldByName('codanalisis').AsString;
    l.Add(objeto);
    detrec.Next;
  end;
  datosdb.QuitarFiltro(detrec);
  Result := l;
end;

{ ----------------------------------------------------------------------------- }
procedure TTAuditoriaCCB.RealizarBackup;
// Objetivo...: Realizar Backup
var
  l: TStringList;
  i: Integer;
begin
  l := backup.setModulos;
  For i := 1 to l.Count do Begin
    if l.Strings[i-1] = 'auditoria' then
      if not csdat then utilesarchivos.CompactarArchivos(dbs.DirSistema + '\' + l.Strings[i-1] + '\*.*', dbs.dirSistema + '\backup\' + utiles.sExprFecha(utiles.setFechaActual) + '_' + l.Strings[i-1] + '.bck') else
        utilesarchivos.CompactarArchivos(dbs.DirSistema + '\interbase\auditoria.gdb', dbs.dirSistema + '\backup\' + utiles.sExprFecha(utiles.setFechaActual) + '_' + l.Strings[i-1] + '.bck');
      //if l.Strings[i-1] = 'auditoria' then utiles.msgerror(dbs.DirSistema + '\interbase\auditoria.gdb');
  end;

end;

function TTAuditoriaCCB.setBackup(xperiodo: String): TStringList;
// Objetivo...: Realizar Backup
var
  l, l1: TStringList;
  i: Integer;
begin
  l1 := TStringList.Create;
  l  := utilesarchivos.setListaArchivos(dbs.DirSistema + '\backup', '*.bck');
  For i := 1 to l.Count do
    if (Copy(ExtractFileName(l.Strings[i-1]), 10, 3) = 'aud') and (Copy(ExtractFileName(l.Strings[i-1]), 1, 4) = Copy(xperiodo, 4, 4))
      and (Copy(ExtractFileName(l.Strings[i-1]), 5, 2) = Copy(xperiodo, 1, 2)) then l1.Add(ExtractFileName(l.Strings[i-1]));

  l.Destroy;
  Result := l1;
end;

procedure TTAuditoriaCCB.RestaurarBackup(xarchivo: String);
// Objetivo...: Restaurar Backup
begin
  utilesarchivos.RestaurarBackup(dbs.DirSistema  + '\backup\' + xarchivo, dbs.DirSistema + '\auditoria');
end;

procedure TTAuditoriaCCB.IniciarArreglos;
var
  i: Integer;
Begin
  For i := 1 to 10 do totales[i] := 0;
  For i := 1 to 7 do totgrales[i] := 0;
  For i := 1 to 8 do totfinal[i] := 0;
end;

function  TTAuditoriaCCB.BuscarObs(xcodos: String): Boolean;
Begin
  Result := obsfinal.FindKey([xcodos]);
end;

procedure TTAuditoriaCCB.GuardarObs(xcodos, xobservacion: String);
Begin
  if BuscarObs(xcodos) then obsfinal.Edit else obsfinal.Append;
  obsfinal.FieldByName('codos').AsString       := xcodos;
  obsfinal.FieldByName('observacion').AsString := xobservacion;
  try
    obsfinal.Post
   except
    obsfinal.Cancel
  end;
end;

procedure TTAuditoriaCCB.getDatosObs(xcodos: String);
Begin
  if BuscarObs(xcodos) then Begin
    observacfinal := obsfinal.FieldByName('observacion').AsString;
  end else Begin
    observacfinal := '';
  end;
end;

function  TTAuditoriaCCB.BuscarObsFinal(xnroauditoria: String): Boolean;
Begin
  Result := obsauditoria.FindKey([xnroauditoria]);
end;

function  TTAuditoriaCCB.BuscarArancelDiferencial(xcodos, xperiodo: String): Boolean;
// Objetivo...: Recupera Instancia
Begin
  Result := datosdb.Buscar(porcentaje, 'codos', 'periodo', xcodos, xperiodo);
end;

procedure TTAuditoriaCCB.RegistrarArancelDiferencial(xcodos, xperiodo, xaplica: String; xub, xug, xrieub, xrieug, xporcentaje: Real);
// Objetivo...: Recupera Instancia
Begin
  if BuscarArancelDiferencial(xcodos, xperiodo) then porcentaje.Edit else porcentaje.Append;
  porcentaje.FieldByName('codos').AsString     := xcodos;
  porcentaje.FieldByName('periodo').AsString   := xperiodo;
  porcentaje.FieldByName('aplica').AsString    := xaplica;
  porcentaje.FieldByName('ub').AsFloat         := xub;
  porcentaje.FieldByName('ug').AsFloat         := xug;
  porcentaje.FieldByName('rieub').AsFloat      := xrieub;
  porcentaje.FieldByName('rieug').AsFloat      := xrieug;
  porcentaje.FieldByName('porcentaje').AsFloat := xporcentaje;
  porcentaje.FieldByName('periodo1').AsInteger := strtoint(copy(xperiodo, 4, 4) + copy(xperiodo, 1, 2));
  try
    porcentaje.Post
   except
    porcentaje.Cancel
  end;
  datosdb.closeDB(porcentaje); porcentaje.Open;
  SincronizarArancelDiferencial(xcodos, xperiodo);
end;

procedure TTAuditoriaCCB.RegistrarArancelDiferencialNBU(xcodos, xperiodo: String; xnbu: Real);
// Objetivo...: Recupera Instancia
Begin
  if BuscarArancelDiferencial(xcodos, xperiodo) then porcentaje.Edit else porcentaje.Append;
  porcentaje.FieldByName('codos').AsString     := xcodos;
  porcentaje.FieldByName('periodo').AsString   := xperiodo;
  porcentaje.FieldByName('nbu').AsFloat        := xnbu;
  porcentaje.FieldByName('aplica').AsString    := 'S';
  porcentaje.FieldByName('periodo1').AsInteger := strtoint(copy(xperiodo, 4, 4) + copy(xperiodo, 1, 2));
  try
    porcentaje.Post
   except
    porcentaje.Cancel
  end;
  datosdb.closeDB(porcentaje); porcentaje.Open;
end;

procedure TTAuditoriaCCB.getDatosArancelDiferencial(xcodos, xperiodo: String);
// Objetivo...: Recupera Instancia
Begin
  if BuscarArancelDiferencial(xcodos, xperiodo) then Begin
    codos      := porcentaje.FieldByName('codos').AsString;
    periodo    := porcentaje.FieldByName('periodo').AsString;
    aplica     := porcentaje.FieldByName('aplica').AsString;
    ub         := porcentaje.FieldByName('ub').AsFloat;
    ug         := porcentaje.FieldByName('ug').AsFloat;
    rieub      := porcentaje.FieldByName('rieub').AsFloat;
    rieug      := porcentaje.FieldByName('rieug').AsFloat;
    porcent    := porcentaje.FieldByName('porcentaje').AsFloat;
  end else Begin
    codos := ''; periodo := ''; aplica := ''; ub := 0; ug := 0; rieub := 0; rieug := 0; porcent := 0;
  end;
end;

procedure TTAuditoriaCCB.BorrarArancelDiferencial(xcodos, xperiodo: String);
// Objetivo...: Recupera Instancia
Begin
  if BuscarArancelDiferencial(xcodos, xperiodo) then porcentaje.Delete;
  datosdb.closeDB(porcentaje); porcentaje.Open;
  SincronizarArancelDiferencial(xcodos, xperiodo);
end;

procedure TTAuditoriaCCB.SincronizarArancelDiferencial(xcodos, xperiodo: String);
// Objetivo...: Recupera Instancia
Begin
  UB := 0; UG := 0; RIEUB := 0; RIEUG := 0; aplica := '';
  datosdb.Filtrar(porcentaje, 'codos = ' + '''' + xcodos + '''');
  porcentaje.First;
  while not porcentaje.Eof do Begin
    UB         := porcentaje.FieldByName('ub').AsFloat;
    UG         := porcentaje.FieldByName('ug').AsFloat;
    RIEUB      := porcentaje.FieldByName('rieub').AsFloat;
    RIEUG      := porcentaje.FieldByName('rieug').AsFloat;
    aplica     := porcentaje.FieldByName('aplica').AsString;
    porcent    := porcentaje.FieldByName('porcentaje').AsFloat;
    if (Copy(porcentaje.FieldByName('periodo').AsString, 4, 4) + Copy(porcentaje.FieldByName('periodo').AsString, 1, 2)) >= (Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2)) then Break;
    porcentaje.Next;
  end;
  datosdb.QuitarFiltro(porcentaje);
end;

function TTAuditoriaCCB.setArancelDiferencial(xcodos: String): TQuery;
begin
  result := datosdb.tranSQL(porcentaje.DatabaseName, 'select codos, periodo, ub, ug, rieub, rieug, aplica, nbu, porcentaje from porcentaje where codos = ' + '''' + xcodos + '''' + ' order by periodo1');
end;

function TTAuditoriaCCB.getArancelDiferencialNBU(xcodos, xperiodo: String): real;
var
  r: TQuery;
  s: real;
begin
  s := 0;
  r := datosdb.tranSQL(porcentaje.DatabaseName, 'select codos, periodo, nbu, periodo1 from porcentaje where codos = ' + '''' + xcodos + '''' + ' order by periodo1');
  r.open;
  while not r.eof do begin
    if (r.fieldbyname('periodo1').asinteger <= strtoint(copy(xperiodo, 4, 4) + copy(xperiodo, 1, 2))) then s := r.fieldbyname('nbu').asfloat;
    r.next;
  end;
  r.close; r.free;
  result := s;
end;

{var
  l, l1, l2: TStringList;
  i: Integer;
Begin
  l  := TStringList.Create;
  l1 := TStringList.Create;
  l2 := TStringList.Create;
  i  := 0;
  datosdb.Filtrar(porcentaje, 'codos = ' + '''' + xcodos + '''');
  porcentaje.First;
  while not porcentaje.Eof do Begin
    l.Add(porcentaje.FieldByName('periodo').AsString + ';1' + porcentaje.FieldByName('ub').AsString + ';2' + porcentaje.FieldByName('ug').AsString + ';3' + porcentaje.FieldByName('rieub').AsString + ';4' + porcentaje.FieldByName('rieug').AsString + ';5' + porcentaje.FieldByName('aplica').AsString + porcentaje.FieldByName('porcentaje').AsString);
    l1.Add(Copy(porcentaje.FieldByName('periodo').AsString, 4, 4) + Copy(porcentaje.FieldByName('periodo').AsString, 1, 2) + IntToStr(i));
    Inc(i);
    porcentaje.Next;
  end;
  datosdb.QuitarFiltro(porcentaje);

  l1.Sort;
  for i := 1 to l1.Count do
    l2.Add(l.Strings[StrToInt(Trim(Copy(l1.Strings[i-1], 7, 3)))]);
  l1.Destroy; l.Destroy;
  Result := l2;
end;}

function TTAuditoriaCCB.verificarArancelDiferencial(xcodos: String): Boolean;
// Objetivo...: verificar arancel diferencial
Begin
  porcentaje.IndexFieldNames := 'codos';
  Result := porcentaje.FindKey([xcodos]);
  porcentaje.IndexFieldNames := 'codos;periodo';
end;

procedure TTAuditoriaCCB.ListarMontosFacturadosDiferenciales(xperiodo, xporcentaje: String; salida: char);
Begin
  list.Setear(salida);
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Montos Diferenciales Facturados en el Per�odo - ' + xperiodo, 1, 'Arial, negrita, 12');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
  list.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
  list.Titulo(2, list.Lineactual, 'Nro.Audit.', 2, 'Arial, cursiva, 8');
  list.Titulo(12, list.Lineactual, 'Fecha', 3, 'Arial, cursiva, 8');
  list.Titulo(20, list.Lineactual, 'Nro.Doc.', 4, 'Arial, cursiva, 8');
  list.Titulo(30, list.Lineactual, 'Nombre Afiliado', 5, 'Arial, cursiva, 8');
  list.Titulo(75, list.Lineactual, 'Monto Dif.', 6, 'Arial, cursiva, 8');
  list.Titulo(85, list.Lineactual, xporcentaje + '% .Dif.', 7, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');

  montos_dif.Open;
  IniciarMontosDiferenciales(xperiodo);

  profesional.conectar;
  idanter[1] := ''; idanter[2] := ''; totales[2] := 0; ldat := False; totales[3] := 0; totales[4] := 0; totales[9] := 0;
  cabauditoria.IndexFieldNames := 'codosfact;laboratorio;nroauditoria';
  datosdb.Filtrar(cabauditoria, 'fechafac >= ' + '''' + Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2) + '01' + '''' + ' and fechafac <= ' + '''' + Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2) + utiles.ultimodiames(Copy(xperiodo, 1, 2), Copy(xperiodo, 4, 4)) + '''');
  cabauditoria.First;
  while not cabauditoria.Eof do Begin
    SincronizarArancelDiferencial(cabauditoria.FieldByName('codos').AsString, xperiodo);
    totales[1] := 0; totales[3] := 0;
    if datosdb.Buscar(detauditoria, 'nroauditoria', 'items', cabauditoria.FieldByName('nroauditoria').AsString, '001') and (verificarArancelDiferencial(cabauditoria.FieldByName('codosfact').AsString)) then Begin
      while not detauditoria.Eof do Begin
        if detauditoria.FieldByName('nroauditoria').AsString <> cabauditoria.FieldByName('nroauditoria').AsString then Break;
        if detauditoria.FieldByName('montodif').AsFloat > 0 then Begin
          if (detauditoria.FieldByName('anulada').AsString <> 'S') and (detauditoria.FieldByName('anulada').AsString <> 'P') then begin
            totales[1] := totales[1] + (detauditoria.FieldByName('montodif').AsFloat - detauditoria.FieldByName('monto').AsFloat);
            totales[3] := totales[3] + ((detauditoria.FieldByName('montodif').AsFloat - detauditoria.FieldByName('monto').AsFloat) * (StrToFloat(xporcentaje) * 0.01));
          end;
        end;
        detauditoria.Next;
      end;
    end;

    if totales[1] > 0 then Begin
      totales[10] := totales[10] + 1;
      if cabauditoria.FieldByName('codosfact').AsString <> idanter[1] then Begin
        SubtotalMontosDiferenciales(xperiodo, idanter[2], idanter[1], salida);
        obsocial.getDatos(cabauditoria.FieldByName('codosfact').AsString);
        padron.conectar(cabauditoria.FieldByName('codosfact').AsString);

        list.Linea(0, 0, 'Obra Social: ' + obsocial.codos + '  ' + obsocial.Nombre, 1, 'Arial, negrita, 9, clNavy', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

        idanter[1] := cabauditoria.FieldByName('codosfact').AsString;
      end;
      if cabauditoria.FieldByName('laboratorio').AsString <> idanter[2] then Begin
        SubtotalMontosDiferenciales(xperiodo, idanter[2], idanter[1], salida);
        profesional.getDatos(cabauditoria.FieldByName('laboratorio').AsString);
        list.Linea(0, 0, 'Profesional: ' + profesional.nombre, 1, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        idanter[2] := cabauditoria.FieldByName('laboratorio').AsString;
      end;

      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(2, list.Lineactual, cabauditoria.FieldByName('nroauditoria').AsString, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(12, list.Lineactual, utiles.sFormatoFecha(cabauditoria.FieldByName('fecha').AsString), 3, 'Arial, normal, 8', salida, 'N');
      padron.getDatos(idanter[1], cabauditoria.FieldByName('nrodoc').AsString);
      list.Linea(20, list.Lineactual, padron.Nrodoc, 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(30, list.Lineactual, Copy(padron.Nombre, 1, 30), 5, 'Arial, normal, 8', salida, 'N');
      list.importe(80, list.Lineactual, '', totales[1], 6, 'Arial, normal, 8');
      list.importe(90, list.Lineactual, '', totales[3], 7, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 8, 'Arial, normal, 8', salida, 'S');
      ldat := True;
    end;

    totales[2] := totales[2] + totales[1];
    totales[4] := totales[4] + totales[3];

    cabauditoria.Next;
  end;

  totales[10] := totales[10] + 1;
  SubtotalMontosDiferenciales(xperiodo, idanter[2], idanter[1], salida);

  datosdb.QuitarFiltro(cabauditoria);
  cabauditoria.IndexFieldNames := 'nroauditoria';
  profesional.desconectar;
  datosdb.closeDB(montos_dif);

  if not ldat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 10', salida, 'N');

  list.FinList;
end;

procedure TTAuditoriaCCB.SubtotalMontosDiferenciales(xperiodo, xidprof, xcodos: String; salida: char);
Begin
  if totales[2] > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
    list.derecha(95, list.Lineactual, '', '--------------------------------------------------', 2, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(80, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 8');
    list.importe(90, list.Lineactual, '', totales[4], 3, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '####', totales[10], 4, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 5, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    RegistrarMontosDiferenciales(xperiodo, xidprof, xcodos, totales[2]);
  end;
  totales[2] := 0; totales[4] := 0; totales[9] := 0; totales[10] := 0;
end;

procedure TTAuditoriaCCB.ListarResumenMontosFacturadosDiferenciales(xperiodo, xporcentaje: String; salida: char);

procedure ListarLinea(xidprof: String; salida: char);
Begin
  if totales[2] > 0 then Begin
    profesional.getDatos(xidprof);
    list.Linea(0, 0, xidprof + '  ' + profesional.nombre, 1, 'Arial, normal, 8', salida, 'N');
    list.importe(80, list.Lineactual, '', totales[2], 2, 'Arial, normal, 8');
    list.importe(90, list.Lineactual, '', totales[4], 3, 'Arial, normal, 8');
    list.importe(95, list.Lineactual, '####', totales[10], 4, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
    totales[5] := totales[5] + totales[2];
    totales[6] := totales[6] + totales[4];
    totales[2] := 0; totales[4] := 0; totales[10] := 0;
    ldat := True;
  end;
end;

procedure ListarTotal(salida: char);
Begin
  if totales[5] > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
    list.derecha(95, list.Lineactual, '', '--------------------------------------------', 2, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(80, list.Lineactual, '', totales[5], 2, 'Arial, negrita, 8');
    list.importe(90, list.Lineactual, '', totales[6], 3, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    totales[5] := 0; totales[6] := 0;
  end;
end;

Begin
  list.Setear(salida);
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Resumen Montos Diferenciales Facturados en el Per�odo - ' + xperiodo, 1, 'Arial, negrita, 12');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
  list.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
  list.Titulo(2, list.Lineactual, 'Nro.Auditor�a', 2, 'Arial, cursiva, 8');
  list.Titulo(15, list.Lineactual, 'Fecha', 3, 'Arial, cursiva, 8');
  list.Titulo(72, list.Lineactual, 'Monto Dif.', 4, 'Arial, cursiva, 8');
  list.Titulo(86, list.Lineactual, xporcentaje + '% .Dif / Cant.', 5, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');

  montos_dif.Open;
  IniciarMontosDiferenciales(xperiodo);

  profesional.conectar;
  idanter[1] := ''; idanter[2] := ''; totales[2] := 0; ldat := False; totales[3] := 0; totales[4] := 0; totales[9] := 0; totales[10] := 0;
  cabauditoria.IndexFieldNames := 'codosfact;laboratorio;nroauditoria';
  datosdb.Filtrar(cabauditoria, 'fechafac >= ' + '''' + Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2) + '01' + '''' + ' and fechafac <= ' + '''' + Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2) + '31' + '''' + ' and anulada <> ' + '''' + 'S' + '''' + ' and anulada <> ' + '''' + 'P' + '''');
  cabauditoria.First;
  idanter[2] := cabauditoria.FieldByName('laboratorio').AsString;
  while not cabauditoria.Eof do Begin
    if (datosdb.Buscar(detauditoria, 'nroauditoria', 'items', cabauditoria.FieldByName('nroauditoria').AsString, '001')) and (verificarArancelDiferencial(cabauditoria.FieldByName('codosfact').AsString)) then Begin
      while not detauditoria.Eof do Begin
        if detauditoria.FieldByName('nroauditoria').AsString <> cabauditoria.FieldByName('nroauditoria').AsString then Break;
        if detauditoria.FieldByName('montodif').AsFloat > 0 then Begin
          if (detauditoria.FieldByName('anulada').AsString <> 'S') and (detauditoria.FieldByName('anulada').AsString <> 'P') then begin
            totales[1] := totales[1] + (detauditoria.FieldByName('montodif').AsFloat - detauditoria.FieldByName('monto').AsFloat);
            totales[3] := totales[3] + ((detauditoria.FieldByName('montodif').AsFloat - detauditoria.FieldByName('monto').AsFloat) * (StrToFloat(xporcentaje) * 0.01));
          end;
        end;
        detauditoria.Next;
      end;
    end;

    if totales[1] > 0 then Begin
      totales[10] := totales[10] + 1;
      if cabauditoria.FieldByName('codosfact').AsString <> idanter[1] then Begin
        ListarLinea(idanter[2], salida);
        ListarTotal(salida);
        obsocial.getDatos(cabauditoria.FieldByName('codosfact').AsString);

        list.Linea(0, 0, 'Obra Social: ' + obsocial.codos + '  ' + obsocial.Nombre, 1, 'Arial, negrita, 9, clNavy', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

        idanter[1] := cabauditoria.FieldByName('codosfact').AsString;
      end;

      if cabauditoria.FieldByName('laboratorio').AsString <> idanter[2] then Begin
        ListarLinea(idanter[2], salida);
        idanter[2] := cabauditoria.FieldByName('laboratorio').AsString;
      end;
    end;

    totales[2] := totales[2] + totales[1];
    totales[4] := totales[4] + totales[3];
    totales[1] := 0; totales[3] := 0;

    cabauditoria.Next;
  end;

  totales[10] := totales[10] + 1;
  ListarLinea(idanter[2], salida);
  ListarTotal(salida);

  datosdb.QuitarFiltro(cabauditoria);
  cabauditoria.IndexFieldNames := 'nroauditoria';
  profesional.desconectar;
  datosdb.closeDB(montos_dif);

  if not ldat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 10', salida, 'N');

  list.FinList;
end;

procedure TTAuditoriaCCB.IniciarMontosDiferenciales(xperiodo: String);
// Objetivo...: Buscar Instancia
begin
  datosdb.tranSQL(montos_dif.DataBaseName, 'delete from ' + montos_dif.TableName + ' where periodo = ' + '''' + xperiodo + '''');
end;

function  TTAuditoriaCCB.BuscarMontosDiferenciales(xperiodo, xidprof, xcodos: String): Boolean;
// Objetivo...: buscar instancia
begin
  Result := datosdb.Buscar(montos_dif, 'periodo', 'idprof', 'codos', xperiodo, xidprof, xcodos);
end;

procedure TTAuditoriaCCB.RegistrarMontosDiferenciales(xperiodo, xidprof, xcodos: String; xmonto: Real);
// Objetivo...: guardar instancia
begin
  if BuscarMontosDiferenciales(xperiodo, xidprof, xcodos) then montos_dif.Edit else montos_dif.Append;
  montos_dif.FieldByName('periodo').AsString := xperiodo;
  montos_dif.FieldByName('idprof').AsString  := xidprof;
  montos_dif.FieldByName('codos').AsString   := xcodos;
  montos_dif.FieldByName('monto').AsFloat    := xmonto;
  try
    montos_dif.Post
   except
    montos_dif.Cancel
  end;
end;

function  TTAuditoriaCCB.BuscarItemsMontoFijo(xcodos, xitems: string): boolean;
begin
  if apfijos.IndexFieldNames <> 'codos;items' then apfijos.IndexFieldNames := 'codos;items';
  Result := datosdb.Buscar(apfijos, 'codos', 'items', xcodos, xitems);
end;

procedure TTAuditoriaCCB.GrabarAnalisisMontoFijo(xcodos, xitems, xcodanalisis, xperiodo, xperiodobaja: string; ximporte: real; xcantitems: Integer);
begin
  if BuscarItemsMontoFijo(xcodos, xitems) then apfijos.Edit else apfijos.Append;
  apfijos.FieldByName('codos').AsString       := xcodos;
  apfijos.FieldByName('items').AsString       := xitems;
  apfijos.FieldByName('codanalisis').AsString := xcodanalisis;
  apfijos.FieldByName('periodo').AsString     := xperiodo;
  apfijos.FieldByName('importe').AsFloat      := ximporte;
  apfijos.FieldByName('perhasta').AsString    := xperiodobaja;
  try
    apfijos.Post
  except
    apfijos.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL(apfijos.DatabaseName, 'delete from ' + apfijos.TableName + ' where codos = ' + '''' + xcodos + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(apfijos); apfijos.Open;
    CargarListaApFijos;
  end;
end;

procedure TTAuditoriaCCB.BorrarAnalisisMontoFijo(xcodos, xitems: string);
begin
  if BuscarItemsMontoFijo(xcodos, xitems) then Begin
    apfijos.Delete;
    CargarListaApFijos;
  end;
end;

function  TTAuditoriaCCB.setAnalisisMontoFijo(xcodos: string): TQuery;
begin
  Result := datosdb.tranSQL(apfijos.DatabaseName, 'SELECT * FROM ' + apfijos.TableName + ' WHERE codos = ' + '"' + xcodos + '"' + ' ORDER BY items');
end;

procedure TTAuditoriaCCB.CargarListaApFijos;
// Objetivo...: Cargar una Lista con las referencias de los Aportes Fijos
Begin
  if lista2 = Nil then lista2 := TStringList.Create else lista2.Clear;
  apfijos.IndexFieldNames := 'codos;items';
  apfijos.First;
  while not apfijos.Eof do Begin
    lista2.Add(apfijos.FieldByName('codos').AsString + apfijos.FieldByName('items').AsString + apfijos.FieldByName('codanalisis').AsString + apfijos.FieldByName('importe').AsString + ';1' + apfijos.FieldByName('periodo').AsString + apfijos.FieldByName('perhasta').AsString);
    apfijos.Next;
  end;
end;

function TTAuditoriaCCB.setMontoFijo(xcodos, xcodanalisis, xperiodo: String): Real;
// Objetivo...: Recuperar Monto Fijo An�lisis por Per�odo
var
  i, p, p1, p2, p3: Integer;
  r: Real;
  t: string;
Begin
  r := 0; t := '';
  For i := 1 to lista2.Count do Begin
    p := Pos(';1', lista2.Strings[i-1]);
    if (xcodos = Copy(lista2.Strings[i-1], 1, 6)) and (xcodanalisis = Copy(lista2.Strings[i-1], 10, 4)) then Begin
      if Length(Trim(Copy(lista2.Strings[i-1], p+2, 7))) > 0 then Begin
        p1 := StrToInt(Copy(Copy(lista2.Strings[i-1], p+2, 7), 4, 4) + Copy(Copy(lista2.Strings[i-1], p+2, 7), 1, 2));
        p2 := StrToInt(Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2));
        if  p1 >= p2 then Begin
          if p1 = p2 then t := (Copy(lista2.Strings[i-1], 14, p-14));
          Break;
        end;
        t := (Copy(lista2.Strings[i-1], 14, p-14));
        // Verificamos el per�odo de Baja
        if Length(Trim( Copy( Copy(lista2.Strings[i-1], p+9, 7), 4, 4) + Copy( Copy(lista2.Strings[i-1], p+9, 7), 1, 2) )) > 0 then
          if (Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2)) >= Copy( Copy(lista2.Strings[i-1], p+9, 7), 4, 4) + Copy( Copy(lista2.Strings[i-1], p+9, 7), 1, 2) then t := '';
      end;
    end;
  end;
  if Length(Trim(t)) = 0 then Begin
    MontoFijo := False;
    Result := r;
  end else Begin
    MontoFijo := True;
    Result := StrToFloat(t);
  end;
end;

procedure TTAuditoriaCCB.GenerarOrdenesXML(xfecha: String);
// Objetivo...: Generar Soporte XML
var
  archivo1, archivo2: TextFile;
Begin
  AssignFile(archivo1, dbs.DirSistema + '\actualizaciones_online\upload\ordenes.xml');
  AssignFile(archivo2, dbs.DirSistema + '\actualizaciones_online\upload\cod_ordenes.xml');
  Rewrite(archivo1);
  Rewrite(archivo2);

  WriteLn(archivo1, '<ordenes>');
  WriteLn(archivo2, '<codigos>');

  cabauditoria.IndexFieldNames := 'Fecha';
  if cabauditoria.FindKey([utiles.sExprFecha2000(xfecha)]) then Begin
    while not cabauditoria.Eof do Begin
      if utiles.sExprFecha2000(xfecha) <> cabauditoria.FieldByName('fecha').AsString then Break;
      // Tag XML Cabauditoria
      WriteLn(archivo1, '<registro>');
      WriteLn(archivo1, '<nroauditoria>' + cabauditoria.FieldByName('nroauditoria').AsString + '</nroauditoria>');
      WriteLn(archivo1, '<nrodoc>' + cabauditoria.FieldByName('nrodoc').AsString + '</nrodoc>');
      WriteLn(archivo1, '<codos>' + cabauditoria.FieldByName('codos').AsString + '</codos>');
      WriteLn(archivo1, '<idzona>' + cabauditoria.FieldByName('idzona').AsString + '</idzona>');
      WriteLn(archivo1, '<nombre>' + cabauditoria.FieldByName('nombre').AsString + '</nombre>');
      WriteLn(archivo1, '<fecha>' + cabauditoria.FieldByName('fecha').AsString + '</fecha>');
      WriteLn(archivo1, '</registro>');

      if datosdb.Buscar(detauditoria, 'nroauditoria', 'items', cabauditoria.FieldByName('nroauditoria').AsString, '001') then Begin
        WriteLn(archivo2, '<registro>');
        while not detauditoria.Eof do Begin
          if detauditoria.FieldByName('nroauditoria').AsString <> cabauditoria.FieldByName('nroauditoria').AsString then Break;
          WriteLn(archivo2, '<nroauditoria>' + detauditoria.FieldByName('nroauditoria').AsString + '</nroauditoria>');
          WriteLn(archivo2, '<items>' + detauditoria.FieldByName('items').AsString + '</items>');
          WriteLn(archivo2, '<codigo>' + detauditoria.FieldByName('codigo').AsString + '</codigo>');
          WriteLn(archivo2, '<estado>' + detauditoria.FieldByName('estado').AsString + '</estado>');
          detauditoria.Next;
        end;
        WriteLn(archivo2, '</registro>');
      end;

      cabauditoria.Next;

    end;

  end;

  WriteLn(archivo1, '</ordenes>');
  closeFile(archivo1);
  WriteLn(archivo2, '</codigos>');
  closeFile(archivo2);
end;

function  TTAuditoriaCCB.setOrdenesDepurar(xfecha: String): TStringList;
// Objetivo...: Devolver Ordenes a Depurar
var
  l: TStringList;
  e: Boolean;
begin
  e := cabauditoria.Active;
  if not e then cabauditoria.Open;
  l := TStringList.Create;
  datosdb.Filtrar(cabauditoria, 'fecha <= ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
  cabauditoria.First;
  while not cabauditoria.Eof do Begin
    l.Add(cabauditoria.FieldByName('nroauditoria').AsString);
    cabauditoria.Next;
  end;
  datosdb.QuitarFiltro(cabauditoria);
  cabauditoria.Active := e;
  Result := l;
end;

procedure TTAuditoriaCCB.IniciarDepuracion;
// Objetivo...: Instanciar tablas
Begin
  cabhist      := datosdb.openDB('cab_auditoria_hist', '', '', cabauditoria.DatabaseName);
  dethist      := datosdb.openDB('det_auditoria_hist', '', '', detauditoria.DatabaseName);
  obsaudithist := datosdb.openDB('obsauditoria_hist', '', '', detauditoria.DatabaseName);
  cabhist.Open; dethist.Open; obsaudithist.Open;
end;

procedure TTAuditoriaCCB.FinalizarDepuracion;
// Objetivo...: Cerrar tablas
Begin
  datosdb.closeDB(cabhist); datosdb.closeDB(dethist);
end;

procedure TTAuditoriaCCB.Depurar(xnroauditoria: String);
// Objetivo...: Depurar Ordenes
var
  f: String;
begin
  if Buscar(xnroauditoria) then Begin
    // Transferimos al historico
    // Cabecera
    if datosdb.Buscar(cabhist, 'nroauditoria', 'fecha', cabauditoria.FieldByName('nroauditoria').AsString, cabauditoria.FieldByName('fecha').AsString) then cabhist.Edit else cabhist.Append;
    f                                             := cabauditoria.FieldByName('fecha').AsString;
    cabhist.FieldByName('nroauditoria').AsString  := cabauditoria.FieldByName('nroauditoria').AsString;
    cabhist.FieldByName('fecha').AsString         := cabauditoria.FieldByName('fecha').AsString;
    cabhist.FieldByName('codos').AsString         := cabauditoria.FieldByName('codos').AsString;
    cabhist.FieldByName('idzona').AsString        := cabauditoria.FieldByName('idzona').AsString;
    cabhist.FieldByName('nrodoc').AsString        := cabauditoria.FieldByName('nrodoc').AsString;
    cabhist.FieldByName('idprof').AsString        := cabauditoria.FieldByName('idprof').AsString;
    cabhist.FieldByName('diagnostico').AsString   := cabauditoria.FieldByName('diagnostico').AsString;
    cabhist.FieldByName('federivacion').AsString  := cabauditoria.FieldByName('federivacion').AsString;
    cabhist.FieldByName('nroderivacion').AsString := cabauditoria.FieldByName('nroderivacion').AsString;
    cabhist.FieldByName('observacion').AsString   := cabauditoria.FieldByName('observacion').AsString;
    cabhist.FieldByName('idfact').AsString        := cabauditoria.FieldByName('idfact').AsString;
    cabhist.FieldByName('fechafac').AsString      := cabauditoria.FieldByName('fechafac').AsString;
    cabhist.FieldByName('laboratorio').AsString   := cabauditoria.FieldByName('laboratorio').AsString;
    cabhist.FieldByName('codosfact').AsString     := cabauditoria.FieldByName('codosfact').AsString;
    cabhist.FieldByName('fepedido').AsString      := cabauditoria.FieldByName('fepedido').AsString;
    cabhist.FieldByName('profcab').AsString       := cabauditoria.FieldByName('profcab').AsString;
    cabhist.FieldByName('iddiag').AsString        := cabauditoria.FieldByName('iddiag').AsString;
    cabhist.FieldByName('nombre').AsString        := cabauditoria.FieldByName('nombre').AsString;
    cabhist.FieldByName('anulada').AsString       := cabauditoria.FieldByName('anulada').AsString;
    cabhist.FieldByName('auditada').AsString      := cabauditoria.FieldByName('auditada').AsString;
    cabhist.FieldByName('nroautorizacion').AsString := cabauditoria.FieldByName('nroautorizacion').AsString;
    cabhist.FieldByName('online').AsString        := cabauditoria.FieldByName('online').AsString;
    try
      cabhist.Post
     except
      cabhist.Cancel
    end;
    // Detalle
    if datosdb.Buscar(detauditoria, 'nroauditoria', 'items', xnroauditoria, '001') then Begin
      while not detauditoria.Eof do Begin
        if detauditoria.FieldByName('nroauditoria').AsString <> xnroauditoria then Break;
        if datosdb.Buscar(dethist, 'nroauditoria', 'fecha', 'items', xnroauditoria, f, detauditoria.FieldByName('items').AsString) then dethist.Edit else dethist.Append;
        dethist.FieldByName('nroauditoria').AsString := detauditoria.FieldByName('nroauditoria').AsString;
        dethist.FieldByName('fecha').AsString        := f;
        dethist.FieldByName('items').AsString        := detauditoria.FieldByName('items').AsString;
        dethist.FieldByName('codigo').AsString       := detauditoria.FieldByName('codigo').AsString;
        dethist.FieldByName('monto').AsFloat         := detauditoria.FieldByName('monto').AsFloat;
        dethist.FieldByName('estado').AsString       := detauditoria.FieldByName('estado').AsString;
        dethist.FieldByName('montodif').AsFloat      := detauditoria.FieldByName('montodif').AsFloat;
        dethist.FieldByName('anulada').AsString      := detauditoria.FieldByName('anulada').AsString;
        dethist.FieldByName('montoonline').AsFloat   := detauditoria.FieldByName('montoonline').AsFloat;
        dethist.FieldByName('coseguro').AsFloat      := detauditoria.FieldByName('coseguro').AsFloat;
        try
          dethist.Post
         except
          dethist.Cancel
        end;
        detauditoria.Next;
      end;
    end;
    // Observaciones
    if BuscarObsFinal(xnroauditoria) then Begin
      if datosdb.Buscar(obsaudithist, 'nroauditoria', 'fecha', xnroauditoria, f) then obsaudithist.Edit else obsaudithist.Append;
      obsaudithist.FieldByName('nroauditoria').AsString := xnroauditoria;
      obsaudithist.FieldByName('fecha').AsString        := f;
      obsaudithist.FieldByName('observacion').AsString  := obsauditoria.FieldByName('observacion').AsString;
      try
        obsaudithist.Post
       except
        obsaudithist.Cancel
      end;
      obsauditoria.Delete;
    end;

    cabauditoria.Delete;
    datosdb.tranSQL(detauditoria.DatabaseName, 'delete from ' + detauditoria.TableName + ' where nroauditoria = ' + '''' + xnroauditoria + '''');
    datosdb.refrescar(cabauditoria); datosdb.refrescar(detauditoria); datosdb.refrescar(obsauditoria);
    datosdb.refrescar(cabhist); datosdb.refrescar(dethist); datosdb.refrescar(obsaudithist);
  end;
end;

function  TTAuditoriaCCB.BuscarCodigoRech(xcodos, xcodigo: string): boolean;
// Objetivo...: buscar una instancia
begin
  result := datosdb.Buscar(codigosrech, 'CODOS', 'CODIGO', xcodos, xcodigo);
end;

procedure TTAuditoriaCCB.RegistrarCodigoRech(xcodos, xcodigo: string);
// Objetivo...: registrar una instancia
begin
  if (BuscarCodigoRech(xcodos, xcodigo)) then codigosrech.Edit else codigosrech.Append;
  codigosrech.FieldByName('codos').AsString  := xcodos;
  codigosrech.FieldByName('codigo').AsString := xcodigo;
  datosdb.refrescar(codigosrech);
end;

procedure TTAuditoriaCCB.BorrarCodigoRech(xcodos, xcodigo: string);
// Objetivo...: borrar una instancia
begin
  if (BuscarCodigoRech(xcodos, xcodigo)) then codigosrech.Delete;
  datosdb.refrescar(codigosrech);
end;

function  TTAuditoriaCCB.getCodigosRech(xcodos: string): TStringList;
// Objetivo...: recuperar una instancia
var
  l: TStringList;
begin
  l := TStringList.Create;
  datosdb.Filtrar(codigosrech, 'CODOS = ' + '''' + xcodos + '''');
  codigosrech.First;
  while not codigosrech.eof do begin
    l.Add(codigosrech.FieldByName('codigo').AsString);
    codigosrech.Next;
  end;
  datosdb.QuitarFiltro(codigosrech);
  result := l;
end;

procedure TTAuditoriaCCB.AjustarEstado(xnroauditoria, xestado: string);
// Objetivo...: Ajustar Estados
begin
  if (Buscar(xnroauditoria)) then begin
    cabauditoria.Edit;
    cabauditoria.FieldByName('anulada').AsString := xestado;
    try
      cabauditoria.Post
    except
      cabauditoria.Cancel
    end;
    datosdb.refrescar(cabauditoria);

    datosdb.tranSQL(detauditoria.DatabaseName, 'update ' + detauditoria.TableName + ' set anulada = ' + '''' + xestado + '''' + ' where nroauditoria = ' + '''' + xnroauditoria + '''');
    datosdb.refrescar(detauditoria);
  end;
end;

procedure TTAuditoriaCCB.QuitarMarcaDePendiente;
begin
  datosdb.tranSQL(cabauditoria.DatabaseName, 'update ' + cabauditoria.TableName + ' set auditada = ' + '''' + '''' + ' where auditada = ' + '''' + 'P' + '''' + ' AND fecha >= ' + '''' + '20090801' + '''');
  datosdb.refrescar(cabauditoria);
end;

procedure TTAuditoriaCCB.MarcarComoPendiente(xnroauditoria: string);
begin
  datosdb.tranSQL(cabauditoria.DatabaseName, 'update ' + cabauditoria.TableName + ' set auditada = ' + '''' + 'P' + '''' + ' where nroauditoria = ' + '''' + xnroauditoria + '''');
  datosdb.refrescar(cabauditoria);
end;

function  TTAuditoriaCCB.getPaciente(xnroauditoria: string): string;
begin
  rsql := datosdb.tranSQL(cabauditoria.DatabaseName, 'select bioqafil.nombre from cab_ref, bioqafil where cab_ref.codos = bioqafil.codos and cab_ref.nrodoc = bioqafil.nrodoc and cab_ref.nroauditoria = ' + '''' + xnroauditoria + '''');
  rsql.open;
  result := rsql.Fields[0].asstring;
  rsql.Close; rsql.free;
end;

procedure TTAuditoriaCCB.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  medcab.conectar;
  zonas.conectar;
  medico.conectar;
  nomeclaturaos.conectar;
  diagnostico.conectar;
  nbu.conectar;
  medicoos.conectar;
  medicoscabol.conectar;
  if conexiones = 0 then Begin
    if not cabauditoria.Active then cabauditoria.Open;
    if not detauditoria.Active then detauditoria.Open;
    if not topes.Active then topes.Open;
    if not totalOS.Active then totalOS.Open;
    if not detrec.Active then detrec.Open;
    if not obsfinal.Active then obsfinal.Open;
    if not obsauditoria.Active then obsauditoria.Open;
    if not porcentaje.Active then porcentaje.Open;
    if not apfijos.Active then apfijos.Open;
    if not codigosrech.Active then codigosrech.Open;
  end;
  if not coseguromov.Active then coseguromov.Open;
  Inc(conexiones);
  CargarListaApFijos;

  //ffirebird := TTFirebird.Create;
  //firebird.getModulo('auditoria');

  //ffirebird.Conectar(firebird.Host + 'auditoria.gdb', firebird.Usuario, firebird.Password);
end;

procedure TTAuditoriaCCB.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(cabauditoria);
    datosdb.closeDB(detauditoria);
    datosdb.closeDB(topes);
    datosdb.closeDB(totalOS);
    datosdb.closeDB(detrec);
    datosdb.closeDB(obsfinal);
    datosdb.closeDB(obsauditoria);
    datosdb.closeDB(porcentaje);
    datosdb.closeDB(apfijos);
    datosdb.closeDB(codigosrech);
    datosdb.closeDB(coseguromov);
    if Length(Trim(dbs.DB1)) > 0 then
      if dbs.TDB1.Connected then Begin
        dbs.TDB1.CloseDataSets;
        dbs.TDB1.Close;
      end;
  end;
  nomeclaturaos.desconectar;
  zonas.desconectar;
  medico.desconectar;
  diagnostico.desconectar;
  nbu.desconectar;
  medcab.desconectar;
  medicoos.desconectar;
  medicoscabol.desconectar;

  //ffirebird.desconectar;
end;

{procedure TTAuditoriaCCB.vaciarBuffer;
begin
  ffirebird.TransacSQLBatch(lote);
  lote.clear;
end;}

{===============================================================================}

function auditoriacb: TTAuditoriaCCB;
begin
  if xauditoria = nil then
    xauditoria := TTAuditoriaCCB.Create;
  Result := xauditoria;
end;

{===============================================================================}

initialization

finalization
  xauditoria.Free;

end.
